

/* telescop.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <stdio.h>
#include "telescop.h"
#include <libtel/util.h>
#if defined(OS_LIN)
#include <ctype.h>
#endif

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"EQMOD",    /* telescope name */
    "EQMOD",    /* protocol name */
    "eqmod",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

/********************************************************/
/* sate_move_radec                                      */
/* ' ' : pas de mouvement                               */
/* 'A' : mouvement demande en mode Temma (radec goto)   */
/*                                                      */
/********************************************************/
char sate_move_radec;

#define EQMOD_STATE_NOT_INITIALIZED 0   // On ne sait pas ou on en est
#define EQMOD_STATE_HALT            1   // Init en cours, moteur pas alimente
#define EQMOD_STATE_STOPPED         2   // Moteur alimente, a l'arret
#define EQMOD_STATE_GOTO            3   // GOTO: goto
#define EQMOD_STATE_TRACK           4   // TRACK: suivi permanent
#define EQMOD_STATE_SLEW            5   // SLEW: deplacement manuel, qui interromp le suivi

#define AXE_RA   1
#define AXE_DEC  2

#define axe(c) (((toupper(c)=='N')||(toupper(c)=='S')) ? AXE_DEC : AXE_RA)
#define dir(c) (((toupper(c)=='N')||(toupper(c)=='W')) ? 0 : 1)

#define state2string(s) (s==EQMOD_STATE_NOT_INITIALIZED?"NOT_INITIALIZED":(s==EQMOD_STATE_HALT?"HALT":(s==EQMOD_STATE_STOPPED?"STOPPED":(s==EQMOD_STATE_GOTO?"GOTO":(s==EQMOD_STATE_TRACK?"TRACK":(s==EQMOD_STATE_SLEW?"SLEW":"NOT DEFINED"))))))

#define PRINTF(args...) printf(args)
//#define PRINTF(args,...)






/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{
   int k,num,res, i, start_motor;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   FILE *f;

   tel->state = EQMOD_STATE_NOT_INITIALIZED;
   tel->old_state = tel->state;
   tel->retournement = 0; // par defaut: tube a l'ouest
   tel->track_diurnal=0.00417807901212; // 0.0004180983;
   tel->speed_track_ra=tel->track_diurnal; // (deg/s)
   tel->speed_track_dec=0.; // (deg/s)
   tel->speed_slew_ra=3.; // (deg/s)  temps mort=4s
   tel->speed_slew_dec=3.; // (deg/s)  temps mort=4s
   tel->radec_move_rate_max=1.0; // deg/s
   tel->ha00=0.;
   tel->roth00=0;
   tel->dec00=0.;
   tel->rotd00=0;
   tel->tempo=200;
   tel->ha_pointing=0; // Le mettre a 1 avant action_goto pour ne pas re-enclencher le suivi.
   tel->mouchard=0; // 0=pas de fichier log
   start_motor = 0;
   
   /* --- transcode a port argument into comX or into /dev... */
   strcpy(ss,argv[2]);
   sprintf(s,"string range [string toupper %s] 0 2",ss);
   Tcl_Eval(tel->interp,s);
   strcpy(s,tel->interp->result);
   if (strcmp(s,"COM")==0) {
      sprintf(s,"string range [string toupper %s] 3 end",ss);
      Tcl_Eval(tel->interp,s);
      strcpy(s,tel->interp->result);
      k=(int)atoi(s);
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(s,tel->interp->result);
      if (strcmp(s,"Linux")==0) {
         sprintf(ss,"/dev/ttyS%d",k-1);
         sprintf(ssusb,"/dev/ttyUSB%d",k-1);
      }
   }

   /* --- open the port and record the channel name ---*/
   sprintf(s,"open \"%s\" r+",ss);
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      strcpy(ssres,tel->interp->result);
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(ss,tel->interp->result);
      if (strcmp(ss,"Linux")==0) {
         // if ttyS not found, we test ttyUSB
         sprintf(ss,"open \"%s\" r+",ssusb);
         if (Tcl_Eval(tel->interp,ss)!=TCL_OK) {
            strcpy(tel->msg,tel->interp->result);
            return 1;
         }
         strcpy(ss,ssusb);
      } else {
         strcpy(tel->msg,ssres);
         return 1;
      }
   }
   strcpy(tel->channel,tel->interp->result);   
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);

   for (i=0;i<argc;i++) {
      if ( ! strcmp(argv[i],"-mouchard") ) {
         tel->mouchard = 1;
      }
      if ( ! strcmp(argv[i],"-east") ) {
         tel->retournement = 1;
      }
      if ( ! strcmp(argv[i],"-startmotor") ) {
         start_motor = 1;
      }
   }
   
   /* --- mouchard ---*/
   if (tel->mouchard==1) {
      f=fopen("mouchard_eqmod.txt","wt");
      fclose(f);
   }

   /* --- inits --- */
   PRINTF("Init: ");
   sprintf(s,":e1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_e1=num;
   //printf(":e1(=%6X,%d)\n",num,num);
   sprintf(s,":e2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_e2=num;
   //printf(":e2(=%6X,%d)\n",num,num);

   sprintf(s,":a1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   if (num<0) { num= num + (1<<24); }
   tel->param_a1=num; // Microsteps per axis Revolution
   printf(":a1(=%6X,%d)\n",num,num);

   sprintf(s,":a2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   if (num<0) { num = num + (1<<24); }
   tel->param_a2=num; // Microsteps per axis Revolution
   printf(":a2(=%6X,%d)\n",num,num);

   sprintf(s,":b1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_b1=num;
   //printf(":b1(=%6X,%d)\n",num,num);

   sprintf(s,":b2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_b2=num;
   //printf(":b2(=%6X,%d)\n",num,num);

   sprintf(s,":g1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_g1=num;

   sprintf(s,":g2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_g2=num;

   sprintf(s,":f1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_f1=num;

   sprintf(s,":f2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_f2=num;

   sprintf(s,":s1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_s1=num; // Microsteps per Worm Revolution
//   printf(":s1(=%6X,%d)\n",num,num);

   sprintf(s,":s2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_s2=num; // Microsteps per Worm Revolution
 //  printf(":s1(=%6X,%d)\n",num,num);

   /* --- speeds --- */
   tel->radec_position_conversion = 1.0 * tel->param_a1 / 360.; /* (ADU)/(deg) */

   /* --- Match --- */
   sprintf(s,":j2"); res=eqmod_putread(tel,s,ss);
   if ( ! strcmp(ss,"000080")) {
      // On vient d'allumer la monture.
      // Le sens de rotation des moteurs est le suivant:
      //    AD: commande + (les codeurs incrementent) = CCW  AH augm, RA dim
      //    AD: commande - (les codeurs decrementent) = CW  AH dim, RA augm
      //    DEC: commande + (les codeurs incrementent) = CCW.
      //    DEC: commande - (les codeurs decrementent) = CW
      // Les zero codeurs sont HA=0 et DEC=90
      // On suppose que le scope pointe la polaire.
      //   tube a l'ouest (par defaut): HA=-6h DEC=90
      //   tube a l'est : HA=6h DEC=90
      // Meme avec le tube a l'est, compte tenu du retournement, il faut toujours initialiser de la meme maniere
      eqmod_encode(tel,(int)(-6*15*tel->radec_position_conversion),ss);
      sprintf(s,":E1%s",ss); res=eqmod_putread(tel,s,ss);
      eqmod_encode(tel,(int)(90*tel->radec_position_conversion),ss);
      sprintf(s,":E2%s",ss); res=eqmod_putread(tel,s,ss);
   }

   res=eqmod_putread(tel,":K1",NULL);
   res=eqmod_putread(tel,":K2",NULL);
   PRINTF("\n");

   /* --- stops --- */
   tel->stop_e_uc=-tel->param_a1/2;
   tel->stop_w_uc=tel->param_a1/2;

   /* --- Home --- */
   tel->latitude=43.75203;
   sprintf(tel->home0,"GPS 6.92353 E %+.6f 1320.0",tel->latitude);

   tel->old_state = tel->state;
   tel->state = EQMOD_STATE_HALT;

   /* --- Mise en route de l'alimentation des moteurs ---*/
   sprintf(s,":F1"); res=eqmod_putread(tel,s,ss);
   sprintf(s,":F2"); res=eqmod_putread(tel,s,ss);

   tel->old_state = tel->state;
   tel->state = EQMOD_STATE_STOPPED;

   if ( start_motor )
	   eqmod2_action_motor(tel);
   
   eqmod_coord(tel,NULL);
   
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return 0;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   return eqmod_delete(tel);
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return eqmod2_match(tel,'W');
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return eqmod_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   sprintf(result,"%s %d",state2string(tel->state),tel->retournement);
   return 0;
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
	return eqmod2_action_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
	return eqmod2_action_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
	return eqmod2_action_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
	return eqmod2_action_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
	return 0;
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
	return 0;
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
	return 0;
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
	return 0;
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
	return 0;
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
	return 0;
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   eqmod_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
   return 0;
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return 0;
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   strcpy(ligne,tel->home0);
   return 0;
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {GPS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   longitude=(double)fabs(longitude);
   if (longitude>360.) { longitude=0.; }
   if ((ew[0]!='w')&&(ew[0]!='W')&&(ew[0]!='e')&&(ew[0]!='E')) {
      ew[0]='E';
   }
   if (latitude>90.) {latitude=90.;}
   if (latitude<-90.) {latitude=-90.;}
   sprintf(tel->home0,"GPS %f %c %f %f",longitude,ew[0],latitude,altitude);
   tel->latitude=latitude;
   return 0;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
	FILE *f;
	if (tel->mouchard==1) {
		f=fopen("mouchard_eqmod.txt","at");
		fprintf(f,"EVAL <%s>\n",ligne);
		fclose(f);
	}
	if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
		if (tel->mouchard==1) {
			f=fopen("mouchard_eqmod.txt","at");
			fprintf(f,"RESU-PB <%s>\n",tel->interp->result);
			fclose(f);
		}
		return 1;
	}
	if (tel->mouchard==1) {
		f=fopen("mouchard_eqmod.txt","at");
		fprintf(f,"RESU-OK <%s>\n",tel->interp->result);
		fclose(f);
	}
	return 0;
}

int eqmod_delete(struct telprop *tel)
{
	char s[1024];
	// --- Fermeture du port com 
	sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
	return 0;
}

int eqmod_put(struct telprop *tel,char *cmd)
{
	char s[1024];
	sprintf(s,"read -nonewline %s ; puts -nonewline %s \"%s\\r\" ; flush %s",tel->channel,tel->channel,cmd,tel->channel);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
	return 0;
}

int eqmod_read(struct telprop *tel,char *res)
{
	char s[2048],*ss;
	strcpy(res,"");
	sprintf(s,"read %s",tel->channel);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
	ss=tel->interp->result;
	if ((int)strlen(ss)>1) {
		if (ss[0]=='!') {
			sprintf(res,"Error %s",ss+1);
		} else {
			strcpy(res,ss+1);
		}
	} else {
		strcpy(res,ss);
	}
	return 0;
}

int eqmod_putread(struct telprop *tel,char *cmd,char *res)
{
	char s[1024],*ss;
	if (res!=NULL)
		*res = 0;
	sprintf(s,"read -nonewline %s ; puts -nonewline %s \"%s\\r\" ; flush %s ; after %d ; read %s",tel->channel,tel->channel,cmd,tel->channel,tel->tempo,tel->channel);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
	if (res!=NULL) {
		ss=tel->interp->result;
		if ((int)strlen(ss)>1) {
			if (ss[0]=='!') {
				sprintf(res,"Error %s",ss+1);
			} else {
				strcpy(res,ss+1);
			}
		} else {
			strcpy(res,ss);
		}
	}
	strcpy(s,tel->interp->result);
	if (strlen(s)>0) s[strlen(s)-1] = 0;
	printf("%s (%d,%s) ",cmd,strlen(s),s);
	return 0;
}

int eqmod_decode(struct telprop *tel,char *chars,int *num)
{
	char s[2048];
	/* --- trancoder l'hexad�cimal de res en num�rique signe ---*/
	strcpy(s,"proc eqmod_decode {s} {return [ expr int(0x[ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]00) / 256 ]}");
	mytel_tcleval(tel,s);
	sprintf(s,"eqmod_decode %s",chars);
	if (mytel_tcleval(tel,s)==1) {
		*num=0;
		//strcpy(chars,tel->interp->result);
		return 1;
	}
	*num=atoi(tel->interp->result);
	return 0;
}

int eqmod_encode(struct telprop *tel,int num,char *chars)
{
	char s[2048];
	/* --- trancoder le numerique en res hexad�cimal ---*/
	strcpy(s,"proc eqmod_encode {int} {set s [ string range [ format %08X $int ] 2 end ];return [ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]}");
	mytel_tcleval(tel,s);
	sprintf(s,"eqmod_encode %d",num);
	if (mytel_tcleval(tel,s)==1) {
		strcpy(chars,tel->interp->result);
		return 1;
	}
	strcpy(chars,tel->interp->result);
	return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage EQMOD      --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

			     
int eqmod_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   char ras[20];
   char decs[20];   
   int motor_step;
   int h,m;
   double sec,lst,ha,dec,ra;
   int deg90;
   int res;

   /* --- Vide le buffer --- */
   //res=eqmod_read(tel,s);
   deg90 = 90.0 * tel->radec_position_conversion;

   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
   axe='2';
   sprintf(ss,":j%c",axe);
   res = eqmod_putread(tel,ss,s);
   printf("eqmod_coord: res=%d\n",res);
   if ( res ) {
	   if (NULL != result) {
		   sprintf(result,"0 0");
	   }
	   return -1;
   }
   eqmod_decode(tel,s,&motor_step);
   dec = tel->dec00 + ( motor_step - tel->rotd00 ) / tel->radec_position_conversion;
   printf(" motor_step=%d, limite=%d\n",motor_step, deg90);
   if ( ( motor_step > deg90 ) || ( motor_step < -deg90 ) ) {
	   tel->retournement = 1; // Le tube pointe vers l'est
	   dec = (tel->latitude) / fabs(tel->latitude) * 180 - dec;
   } else {
	   tel->retournement=0;
   }

   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,":j%c",axe);
   if ( eqmod_putread(tel,ss,s) ) {
	   if (NULL != result) {
		   sprintf(result,"0 0");
	   }
	   return -1;
   }
   eqmod_decode(tel,s,&motor_step);
   ha = tel->ha00 + ( motor_step - tel->roth00 ) / tel->radec_position_conversion;
   /* H=TSL-alpha => alpha=TSL-H */
   lst = eqmod_tsl(tel,&h,&m,&sec);
   ra = lst - ha + 360 * 5;
   if ( tel->retournement == 1 ) {
	   ra += 180.;
   }
   ra = fmod(ra,360.);

   printf("a1=%d\n",tel->param_a1);
   printf("radec_position_conversion=%f\n",tel->radec_position_conversion);
   printf("deg90=%d\n",deg90);
   printf("retournement=%d\n",tel->retournement);

   /* --- --- */
   if ( NULL != result ) {
	   sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
	   strcpy(ras,tel->interp->result);
	   sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
	   strcpy(decs,tel->interp->result);
	   sprintf(result,"%s %s",ras,decs);
   }
   
   return 0;
}


int eqmod_positions12(struct telprop *tel,int *p1,int *p2)
/*
* Coordonn�es en ADU
*/
{
   char s[1024],ss[1024],axe;
   int res;

   /* --- Vide le buffer --- */
   res=eqmod_read(tel,s);

   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,":j%c",axe);
   res=eqmod_putread(tel,ss,s);
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (res==0) {
      eqmod_decode(tel,s,&res);
      *p1=res;
   }

   /* --- Lecture AXE 2 (delta) --- */
   axe='2';
   sprintf(ss,":j%c",axe);
   res=eqmod_putread(tel,ss,s);
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (res==0) {
      eqmod_decode(tel,s,&res);
      *p2=res;
   }
   return 0;
}

/*
int eqmod_goto(struct telprop *tel)
{
   char s[1024],ss[1024],axe,sens;
   int res;
   int retournement=0;
   int p,p0,dp;
   double v;
   double ha,lst,sec;
   int h,m;

   // --- Effectue le pointage RA --- //
   // H=TSL-alpha => alpha=TSL-H //
   lst=eqmod_tsl(tel,&h,&m,&sec);
   lst=lst+4./86400*360.; // ajout empirique de 4 secondes pour tenir compte du temps mort de reponse de la monture
   ha=lst-tel->ra0+360*5;
   ha=fmod(ha,360.);
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
   if (p>fabs(360*tel->radec_position_conversion)/2) {
      // --- on passe au dela du meridien descendant (nord) --- //
      p-=(int)fabs(360*tel->radec_position_conversion);
   }
   if (p>tel->stop_w_uc) {
      p=(int)(p-fabs(360*tel->radec_position_conversion));
      if (p<tel->stop_e_uc) {
         // angle mort
         retournement=1;
         p=(int)(p+180*fabs(tel->radec_position_conversion));
      }
   }
   if (p<tel->stop_e_uc) {
      p=(int)(p+360*fabs(tel->radec_position_conversion));
      if (p>tel->stop_w_uc) {
         // angle mort
         retournement=1;
         p=(int)(p-fabs(180*tel->radec_position_conversion));
      }
   }
   axe='1';
   sprintf(s,":K%c",axe); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":j%c",axe); res=eqmod_putread(tel,s,ss);
   eqmod_decode(tel,ss,&p0);
   dp=p-p0;
   if (dp>=0) {
      sens='0';
   } else {
      sens='1';
   }
   sprintf(s,":G%c2%c",axe,sens); res=eqmod_putread(tel,s,NULL);
   eqmod_encode(tel,(int)(abs(dp)),ss);
   sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);
   eqmod_encode(tel,90,ss);
   sprintf(s,":M%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL);

   // --- Effectue le pointage DEC --- //
   if (retournement==1) {
      v=(tel->latitude)/fabs(tel->latitude)*180-tel->dec0;
   } else {
      v=tel->dec0;
   }
   p=(int)(tel->rotd00-(v-tel->dec00)*tel->radec_position_conversion);
   axe='2';
   sprintf(s,":K%c",axe); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":j%c",axe); res=eqmod_putread(tel,s,ss);
   eqmod_decode(tel,ss,&p0);
   dp=p-p0;
   if (dp>=0) {
      sens='0';
   } else {
      sens='1';
   }
   sprintf(s,":G%c2%c",axe,sens); res=eqmod_putread(tel,s,NULL);
   eqmod_encode(tel,(int)(abs(dp)),ss);
   sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);
   eqmod_encode(tel,90,ss);
   sprintf(s,":M%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL);

   // --- --- //
   return 0;
}
*/

/******************************************************************************/
/* Fonctions HADEC                                                            */
/******************************************************************************/

int eqmod_hadec_coord(struct telprop *tel,char *result)
{
   char s[1024],ss[1024],axe;
   char ras[20];
   char decs[20];   
   int motor_step;
   double ha,dec,ra;
   int deg90;
   
   deg90 = 90.0 * tel->radec_position_conversion;

   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
   axe='2';
   sprintf(ss,":j%c",axe);
   if ( eqmod_putread(tel,ss,s) ) {
	   if (NULL != result) {
		   sprintf(result,"0 0");
	   }
	   return -1;
   }
   eqmod_decode(tel,s,&motor_step);
   dec = tel->dec00 + ( motor_step - tel->rotd00 ) / tel->radec_position_conversion;
   if ( ( motor_step > deg90 ) || ( motor_step < -deg90 ) ) {
	   tel->retournement = 1;
	   dec = (tel->latitude) / fabs(tel->latitude) * 180.0 - dec;
   } else {
	   tel->retournement = 0;
   }

   /* --- Lecture AXE 1 (horaire) --- */
   axe = '1';
   sprintf(ss,":j%c",axe);
   if ( eqmod_putread(tel,ss,s) ) {
	   if (NULL != result) {
		   sprintf(result,"0 0");
	   }
	   return -1;
   }
   eqmod_decode(tel,s,&motor_step);
   ha = tel->ha00 + ( motor_step - tel->roth00 ) / tel->radec_position_conversion;
   ra = ha + 360*5;
   if ( tel->retournement == 1 ) {
	   ra += 180.;
   }
   ra = fmod(ra,360.);

   printf("eqmod_hadec_coord: a1=%d\n",tel->param_a1);
   printf("eqmod_hadec_coord: radec_position_conversion=%f\n",tel->radec_position_conversion);
   printf("eqmod_hadec_coord: deg90=%d\n",deg90);
   printf("eqmod_hadec_coord: retournement=%d\n",tel->retournement);

   /* --- --- */
   if ( NULL != result ) {
	sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
	strcpy(ras,tel->interp->result);
	sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
	strcpy(decs,tel->interp->result);
	sprintf(result,"%s %s",ras,decs);
   }
   
   return 0;
}

/* Initialisation des codeurs, avec :
 *  ah passe par: tel->ra0
 *  dec passee par: tel->dec0
 */
int eqmod_hadec_match(struct telprop *tel)
{
   char s[1024],ss[1024];
   int p;
   double ha;

   if ( ( tel->state != EQMOD_STATE_STOPPED ) && ( tel->state != EQMOD_STATE_TRACK ) ) {
      return -1;
   }

   if ( tel->state == EQMOD_STATE_TRACK ) {
      eqmod2_action_motor(tel);
   }
   
   // --- HA ---
   // H=TSL-alpha => alpha=TSL-H
   ha=tel->ra0+360*5;
   ha=fmod(ha,360.);

   // --- Init AXE 1 (horaire) 0 UC pour HA = 0h ---
   p = ( int ) ( ha * tel->radec_position_conversion );
   eqmod_encode(tel,p,s);
   sprintf(ss,":E1%s",s);
   if ( eqmod_putread(tel,ss,s) ) {
	return -1;
   }

   // --- Init AXE 2 (declinaison) 0 UC pour DEC = 0 deg ---
   p = ( int ) ( tel->dec0 * tel->radec_position_conversion );
   eqmod_encode(tel,p,s);
   sprintf(ss,":E2%s",s);
   if ( eqmod_putread(tel,ss,s) ) {
	return -2;
   }

   // --- ---
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage EQMOD    TOOLS ----------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int eqmod_home(struct telprop *tel, char *home_default)
{
   char s[1024];
   if (strcmp(tel->home0,"")!=0) {
      strcpy(tel->home,tel->home0);
      return 0;
   }
   sprintf(s,"info exists audace(posobs,observateur,gps)");
   mytel_tcleval(tel,s);
   if (strcmp(tel->interp->result,"1")==0) {
      sprintf(s,"set audace(posobs,observateur,gps)");
      mytel_tcleval(tel,s);
      strcpy(tel->home,tel->interp->result);
	} else {
      if (strcmp(home_default,"")!=0) {
         strcpy(tel->home,home_default);
      }
   }
   return 0;
}

double eqmod_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   eqmod_home(tel,"");
   eqmod_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
   sprintf(s,"mc_date2lst %s {%s}",ss,tel->home);
   mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   sprintf(s,"lindex {%s} 0",ss);
   mytel_tcleval(tel,s);
   *h=(int)atoi(tel->interp->result);
   sprintf(s,"lindex {%s} 1",ss);
   mytel_tcleval(tel,s);
   *m=(int)atoi(tel->interp->result);
   sprintf(s,"lindex {%s} 2",ss);
   mytel_tcleval(tel,s);
   *sec=(double)atof(tel->interp->result);
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

void eqmod_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
{
   /* --- conversion TSystem -> TU pour l'interface Aud'ACE par exemple ---*/
	/*     (function = ::audace::date_sys2ut) */
   char ligne[1024];
   sprintf(ligne,"info commands  %s",function);
   Tcl_Eval(interp,ligne);
   if (strcmp(interp->result,function)==0) {
      sprintf(ligne,"mc_date2iso8601 [%s now]",function);
      Tcl_Eval(interp,ligne);
      strcpy(s,interp->result);
   } else {
      Tcl_Eval(interp,"mc_date2iso8601 now");
      strcpy(s,interp->result);
   }
}









int eqmod2_stopmotor(struct telprop *tel, int axe)
{
	int res;

	PRINTF("Stop motor, axe=%d ",axe);
	if ( axe & AXE_RA ) {
		res = eqmod_putread(tel,":K1",NULL);
	}
	if ( axe & AXE_DEC ) {
		res = eqmod_putread(tel,":K2",NULL);
	}
	
	eqmod_coord(tel,NULL); // Permet de verifier le retournement
	printf("\n");
	
	return 0;
}

int eqmod2_track(struct telprop *tel)
{
	char s[1024],ss[1024],axe;
	int res;
	double v;

	PRINTF("Track motor\n");
	/*--- Track alpha */
	PRINTF("  ra: ");
	axe='1';
	if (tel->speed_track_ra>0) {
		PRINTF("dir>0 ");
		sprintf(s,":G%c10",axe);
		res=eqmod_putread(tel,s,NULL);
	} else if (tel->speed_track_ra<0) {
		PRINTF("dir<0 ");
		sprintf(s,":G%c11",axe);
		res=eqmod_putread(tel,s,NULL);
	}
	if (tel->speed_track_ra != 0) {
		v = fabs(((float)tel->param_b1) * 360.0 / ((float)tel->speed_track_ra) / ((float)tel->param_a1));
		PRINTF("speed=%d ",(int)v);
		eqmod_encode(tel,(int)v,ss);
		sprintf(s,":I%c%s",axe,ss);
		res=eqmod_putread(tel,s,NULL);
		sprintf(s,":J%c",axe);
		res=eqmod_putread(tel,s,NULL);
	}
	printf("\n");

	/*--- Track delta */
	PRINTF("  dec: ");
	axe='2';
	if (tel->speed_track_dec>0) {
		PRINTF("dir>0 ");
		sprintf(s,":G%c10",axe);
		res=eqmod_putread(tel,s,NULL);
	} else if (tel->speed_track_dec<0) {
		PRINTF("dir<0 ");
		sprintf(s,":G%c11",axe);
		res=eqmod_putread(tel,s,NULL);
	}
	if (tel->speed_track_dec != 0) {
		v = fabs(((float)tel->param_b2) * 360.0 / ((float)tel->speed_track_dec) / ((float)tel->param_a2));
		PRINTF("speed=%d ",(int)v);
		eqmod_encode(tel,(int)(v),ss);
		sprintf(s,":I%c%s",axe,ss);
		res=eqmod_putread(tel,s,NULL);
		sprintf(s,":J%c",axe);
		res=eqmod_putread(tel,s,NULL);
	}
	PRINTF("\n");

	return 0;
}

int eqmod2_move(struct telprop *tel, char direction)
{
	char s[1024],vc[20];
	int res;
	double v;
	char vit;

	printf("Move %c, speed=%f, speedmax=%f", direction, tel->radec_move_rate, tel->radec_move_rate_max);
	
	if (tel->radec_move_rate > tel->radec_move_rate_max) {
		tel->radec_move_rate = tel->radec_move_rate_max;
	} else if (tel->radec_move_rate < 0.) {
		tel->radec_move_rate = 0.;
	}
	if (tel->radec_move_rate>0.7) {
		vit='3';
		v = ((float)tel->param_b1) * 360.0 / ((float)tel->radec_move_rate) / ((float)tel->param_a1) * 16.0;
	} else {
		vit='1';
		v = ((float)tel->param_b1) * 360.0 / ((float)tel->radec_move_rate) / ((float)tel->param_a1);
	}
	
	printf(", dir=%c, speed=%f, param=%06X ", direction, tel->radec_move_rate, (int)v);

	if ( ( axe(direction) == AXE_DEC ) && ( tel->retournement == 1 ) ) {
		// Mouvement axe delta et tube a l'est
		sprintf(s,":G%d%c%d",axe(direction),vit,1-dir(direction));
	} else {
		// Mouvement axe alpha, ou delta tube a l'ouest
		sprintf(s,":G%d%c%d",axe(direction),vit,dir(direction));
	}
	res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	eqmod_encode(tel,(int)v,vc);
	sprintf(s,":I%d%s",axe(direction),vc);
	res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	sprintf(s,":J%d",axe(direction));
	res=eqmod_putread(tel,s,NULL); printf("%s\n",s);
	
	return 0;
}

//#define SIMU

int eqmod2_goto(struct telprop *tel)
{
	char s[1024],ss[1024],axe,sens;
	int res;
	//int retournement=0;
	int p,p0,dp;
	//double v;
	double ha,lst,sec;
	int h,m;

	printf("GOTO:\n");
	
	/* --- Effectue le pointage RA --- */
	/* H=TSL-alpha => alpha=TSL-H */
	lst=eqmod_tsl(tel,&h,&m,&sec);
	lst=lst+4./86400*360.; // ajout empirique de 4 secondes pour tenir compte du temps mort de reponse de la monture
	ha=lst-tel->ra0+360*5;
	ha=fmod(ha,360.);
	if (ha>180) ha -= 360.;
	p=(int)(ha*tel->radec_position_conversion);
	printf("  ha=%f p_initial=%d ",ha,p);
	if (p>fabs(360*tel->radec_position_conversion)/2) {
		// --- on passe au dela du meridien descendant (nord) ---*/
		p-=(int)fabs(360*tel->radec_position_conversion);
	}
	if (p>tel->stop_w_uc) {
		p=(int)(p-fabs(360*tel->radec_position_conversion));
		if (p<tel->stop_e_uc) {
		         // angle mort
			tel->retournement=1;
			p=(int)(p+180*fabs(tel->radec_position_conversion));
		}
	}
	if (p<tel->stop_e_uc) {
		p=(int)(p+360*fabs(tel->radec_position_conversion));
		if (p>tel->stop_w_uc) {
         		// angle mort
			tel->retournement=1;
			p=(int)(p-fabs(180*tel->radec_position_conversion));
		}
	}
	printf("p final=%d ",p);
	axe='1';
	sprintf(s,":j%c",axe); res=eqmod_putread(tel,s,ss);
	eqmod_decode(tel,ss,&p0); printf("%s (%d) ",s,p0);
	dp=p-p0;
	if (dp>=0) {
		sens='0';
	} else {
		sens='1';
	}
	printf("  ha: target=%d (current=%d) dp=T-C=%d  ",p,p0,dp);
#if !defined(SIMU)
	sprintf(s,":G%c2%c",axe,sens); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	eqmod_encode(tel,(int)(abs(dp)),ss);
	sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	eqmod_encode(tel,(int)(abs(dp))*0.90,ss);
	sprintf(s,":M%c%s",axe,ss); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL); printf("%s \n",s);
#endif
		
	/* --- Effectue le pointage DEC --- */
	axe='2';
	p=(int)(tel->dec0*tel->radec_position_conversion);
	sprintf(s,":j%c",axe); res=eqmod_putread(tel,s,ss);
	eqmod_decode(tel,ss,&p0); printf("%s (%d) ",s,p0);
	dp=p-p0;
	if (tel->retournement==1) {
		dp = - dp;
	}
	if (dp>=0) {
		sens='0';
	} else {
		sens='1';
	}
	printf("  dec: target=%d (current=%d) dp=T-C=%d  ",p,p0,dp);
#if !defined(SIMU)
	sprintf(s,":G%c2%c",axe,sens); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	eqmod_encode(tel,(int)(abs(dp)),ss);
	sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	eqmod_encode(tel,(int)(abs(dp))*0.90,ss);
	sprintf(s,":M%c%s",axe,ss); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
	sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL); printf("%s \n",s);
#endif
	
	/* --- --- */
	return 0;
}

int eqmod2_waitgoto(struct telprop *tel)
{
	char s[1024];
	int time_in=0,time_out=70;
	int nbgoto=2;
	int p10,p1,p20,p2;
	double tol;

	// Pour l'instant: goto bloquant
	tel->radec_goto_blocking = 1;
			
	if (tel->radec_goto_blocking==1) {
		/* A loop is actived until the telescope is stopped */
		eqmod_positions12(tel,&p10,&p20);
		PRINTF("  wait: %d %d\n",p10,p20);
		tol=(tel->radec_position_conversion)/3600.*10; /* tolerance +/- 10 arcsec */
		while (1==1) {
			time_in++;
			sprintf(s,"after 350"); mytel_tcleval(tel,s);
			eqmod_positions12(tel,&p1,&p2);
			PRINTF("  wait: %d %d\n",p10,p20);
			if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
			p10=p1;
			p20=p2;
			if (time_in>=time_out) {break;}
		}
		if (nbgoto>1) {
			eqmod2_goto(tel);
			/* A loop is actived until the telescope is stopped */
			eqmod_positions12(tel,&p10,&p20);
			PRINTF("  wait: %d %d\n",p10,p20);
			while (1==1) {
				time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				eqmod_positions12(tel,&p1,&p2);
				PRINTF("  wait: %d %d\n",p10,p20);
				if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {
					break;
				}
				p10=p1;
				p20=p2;
				if (time_in>=time_out) {break;}
			}
		}
	}
	return 0;
}


int eqmod2_match(struct telprop *tel, char dir)
{
	char s[1024],ss[1024],axe;
	int res;
	double ha,lst,sec;
	int h,m,d;
	int p;

	if ( ( tel->state != EQMOD_STATE_STOPPED ) && ( tel->state != EQMOD_STATE_TRACK ) ) {
		return -1;
	}

	/* --- Effectue le pointage RA --- */
	/* H=TSL-alpha => alpha=TSL-H */
	lst=eqmod_tsl(tel,&h,&m,&sec);
	ha=lst-tel->ra0+360*5;
	ha=fmod(ha,360.);
	if (ha>180.) ha -= 360;
	PRINTF("Match: ha=%f dec=%f ",ha,tel->dec0);

	if ( tel->state == EQMOD_STATE_TRACK ) {
		eqmod2_stopmotor(tel,AXE_RA | AXE_DEC);
	}
	
	/* --- Lecture AXE 1 (horaire) --- */
	// Encodage:
	//   angle horaire entre -180 et 180
	//   codeur entre -a1/2 et a1/2
	axe='1';
	if ( dir == 'E' ) {
		if ( ha > 0 )
			ha -= 180.0;
		if ( ha < 0 )
			ha += 180.0;
	}
	p = (int)(ha * tel->radec_position_conversion); PRINTF("[[ha=%d]] ",tel->roth00);
	eqmod_encode(tel,p,ss);
	sprintf(s,":E%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);

	sprintf(ss,":j%c",axe); res=eqmod_putread(tel,ss,s); eqmod_decode(tel,s,&d);
	PRINTF("[[ha=%d]] ",d);
	
	/* --- Lecture AXE 2 (delta) --- */
	// Encodage:
	//   angle entre -90 et +90
	//   codeur entre -a1/4 et a1/4
	axe='2';
	if ( dir == 'E' ) {
	   tel->retournement = 1; // Le tube pointe vers l'est
	   tel->dec0 = (tel->latitude) / fabs(tel->latitude) * 180 - tel->dec0;
	} else {
	   tel->retournement = 0; // Le tube pointe vers l'ouest
	}
	p = (int)(tel->dec0 * tel->radec_position_conversion); PRINTF("[[dec=%d]] ",tel->rotd00);
	eqmod_encode(tel,p,ss);
	sprintf(s,":E%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);

	sprintf(ss,":j%c",axe); res=eqmod_putread(tel,ss,s); eqmod_decode(tel,s,&d);
	PRINTF("[[dec=%d]] ",d);

	if ( dir == 'W' ) {
		PRINTF("Dir=W\n");
	} else {
		PRINTF("Dir=E\n");
	}
	
	if ( tel->state == EQMOD_STATE_TRACK ) {
		eqmod2_track(tel);
	}

	return 0;
}


/*****************************************************************************/
/* Les fonctions eqmod2_action_* correspondent aux commandes tel radec *.    */
/* Elles authorisent ou non l'action correspondante sur les moteurs en       */
/* fonction de l'etat actuel des moteurs, symbolise par une machine a etats. */
/* Les fonctions peripheriques (match, etc) se servent de l'etat des moteurs */
/* pour decider de la faisabitilite ou non de l'action.                      */
/*****************************************************************************/

int eqmod2_action_move(struct telprop *tel, char *direction)
{
	switch ( tel->state ) {
		case EQMOD_STATE_NOT_INITIALIZED:
			return -1;
		case EQMOD_STATE_HALT:
			return -1;
		case EQMOD_STATE_GOTO:
			return -1;
		case EQMOD_STATE_STOPPED:
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_SLEW;
			eqmod2_move(tel,direction[0]);
			break;
		case EQMOD_STATE_TRACK:
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_SLEW;
			eqmod2_stopmotor(tel,AXE_RA|AXE_DEC);
			eqmod2_move(tel,direction[0]);
			break;
		case EQMOD_STATE_SLEW:
			if ( ( tel->slew_axis & AXE_RA ) == axe(direction[0]) ) {
				// L'axe RA est en slew, et on demande une modif sur cet axe
				eqmod2_stopmotor(tel,AXE_RA);
			}
			if ( ( tel->slew_axis & AXE_DEC ) == axe(direction[0]) ) {
				// L'axe DEC est en slew, et on demande une modif sur cet axe
				eqmod2_stopmotor(tel,AXE_DEC);
			}
			eqmod2_move(tel,direction[0]);
			break;
	}
	
	tel->slew_axis = tel->slew_axis | axe(direction[0]);

	printf("CMD_MOVE: state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));
	return 0;
}

int eqmod2_action_stop(struct telprop *tel, char *direction)
{
	switch ( tel->state ) {
		case EQMOD_STATE_NOT_INITIALIZED:
			return -1;
		case EQMOD_STATE_HALT:
			return -1;
		case EQMOD_STATE_GOTO:
			// Tester s'il n'y avait pas un goto asynchrone en route...
			return -1;
		case EQMOD_STATE_STOPPED:
			// Monture deja arretee
			return -2;
		case EQMOD_STATE_TRACK:
			// Pour arreter le moteur, il faut faire action_motor
			return -1;
		case EQMOD_STATE_SLEW:
			eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
			if ( tel->old_state == EQMOD_STATE_TRACK ) {
				// On vient de track, il faut re-enclencher le moteur
				eqmod2_track(tel);
				tel->old_state = tel->state;
				tel->state = EQMOD_STATE_TRACK;
			} else {
				tel->old_state = tel->state;
				tel->state = EQMOD_STATE_STOPPED;
			}
			break;
	}
	
	printf("CMD_STOP: state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));

	return 0;
}

int eqmod2_action_motor(struct telprop *tel)
{
	switch ( tel->state ) {
		case EQMOD_STATE_NOT_INITIALIZED:
			return -1;
		case EQMOD_STATE_HALT:
			return -1;
		case EQMOD_STATE_GOTO:
			return -1;
		case EQMOD_STATE_STOPPED: // On passe en TRACK.
			eqmod2_track(tel);
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_TRACK;
			break;
		case EQMOD_STATE_TRACK: // On arrete les deux moteurs, on passe en STOPPED.
			eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_STOPPED;
			break;
		case EQMOD_STATE_SLEW:
			return -1;
	}
	
	printf("CMD_MOTOR: state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));

	return 0;
}


int eqmod2_action_goto(struct telprop *tel)
{
	switch ( tel->state ) {
		case EQMOD_STATE_NOT_INITIALIZED:
			return -1;
		case EQMOD_STATE_HALT:
			return -1;
		case EQMOD_STATE_STOPPED:
			// Monture deja arretee
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_GOTO;
			eqmod2_goto(tel);
#if !defined(SIMU)
			eqmod2_waitgoto(tel);
#endif
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_STOPPED;
			break;
		case EQMOD_STATE_GOTO:
			return -1; // Ne devrait jamais arriver
		case EQMOD_STATE_TRACK:
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_GOTO;
			eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
			eqmod2_goto(tel);
#if !defined(SIMU)
			eqmod2_waitgoto(tel);
#endif
			if ( tel->ha_pointing == 1 ) {
				// En cas de pointage hadec, on ne re-enclenche pas le moteur de suivi.
				tel->old_state = tel->state;
				tel->state = EQMOD_STATE_STOPPED;
				tel->ha_pointing = 0;
			} else {
				eqmod2_track(tel);
				tel->old_state = tel->state;
				tel->state = EQMOD_STATE_TRACK;
			}
			break;
		case EQMOD_STATE_SLEW:
			return -1;
	}
	
	printf("CMD_GOTO: state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));

	return 0;
}


