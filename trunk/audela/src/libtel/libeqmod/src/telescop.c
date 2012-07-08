

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
#define state2string(s) (s==EQMOD_STATE_NOT_INITIALIZED?"NOT_INITIALIZED":(s==EQMOD_STATE_HALT?"HALT":(s==EQMOD_STATE_STOPPED?"STOPPED":(s==EQMOD_STATE_GOTO?"GOTO":(s==EQMOD_STATE_TRACK?"TRACK":(s==EQMOD_STATE_SLEW?"SLEW":"NOT DEFINED"))))))

#define AXE_RA   1
#define AXE_DEC  2

#define axe(c) (((toupper(c)=='N')||(toupper(c)=='S')) ? AXE_DEC : AXE_RA)
#define dir(c) (((toupper(c)=='N')||(toupper(c)=='W')) ? 0 : 1)

#define TUBE_OUEST   0
#define TUBE_EST     1
#define TubePos2string(s) ( s == TUBE_OUEST ? "W" : "E" )

#define PRINTF printf
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
   int k,num,res, i, j, start_motor;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   double ha, dec;
	int mode_debug = 0;
   FILE *f;

   tel->state               = EQMOD_STATE_NOT_INITIALIZED;
   tel->old_state           = tel->state;
   tel->tubepos             = TUBE_OUEST;
   tel->track_diurnal       = 360.0/86164.; // 0.00417807901212;
   tel->speed_track_ra      = tel->track_diurnal; // (deg/s)
   tel->speed_track_dec     = 0.;  // (deg/s)
   tel->speed_slew_ra       = 3.;  // (deg/s)  temps mort=4s
   tel->speed_slew_dec      = 3.;  // (deg/s)  temps mort=4s
   tel->radec_move_rate_max = 1.0; // deg/s
   tel->tempo=50;
   tel->ha_pointing=0; // Le mettre a 1 avant action_goto pour ne pas re-enclencher le suivi.
   tel->mouchard=0; // 0=pas de fichier log
   tel->latitude=43.75203;
   sprintf(tel->home,"GPS 6.92353 E %+.6f 1320.0",tel->latitude);

   start_motor = 0;
   ha = 0.0;
   dec = 0.0;
   
   printf("*** tel_init(");
   for(i=0;i<argc;i++) {
      if (i>0) {
         printf(",");
      }
      printf("%s",argv[i]);
   }
   printf(")\n");

   // transcode a port argument into comX or into /dev...
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

   // Open the port and record the channel name
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

   // Transcoder l'hexadecimal de res en numerique signe
   strcpy(s,"proc eqmod_decode {s} {return [ expr int(0x[ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]00) / 256 ]}");
   mytel_tcleval(tel,s);

   // Transcoder le numerique en res hexadecimal
   strcpy(s,"proc eqmod_encode {int} {set s [ string range [ format %08X $int ] 2 end ];return [ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]}");
   mytel_tcleval(tel,s);


   PRINTF("Options:\n");
   for (i=0;i<argc;i++) {
      if ( ! strcmp(argv[i],"-mouchard") ) {
         PRINTF("  Mouchard active\n");
         tel->mouchard = 1;
      }
      if ( ! strcmp(argv[i],"-east") ) {
         PRINTF("  Tube a l'est\n");
         tel->tubepos = TUBE_EST;
      }
      if ( ! strcmp(argv[i],"-gps") ) {
         PRINTF("  Localisation de la monture: %s\n",argv[i+1]);
         sprintf(tel->home,"%s %s %s %s %s",argv[i+1],argv[i+2],argv[i+3],argv[i+4],argv[i+5]);
         tel->latitude = atof(argv[i+4]);
      }
      if ( ! strcmp(argv[i],"-point") ) {
         if ( ! strcmp(argv[i+1],"east") ) {
            PRINTF("  Tube pointe a l'est\n");
            ha = ( tel->tubepos == TUBE_EST ) ? -90.0 : 90.0 ;
            dec = ( tel->tubepos == TUBE_EST ) ? 180.0 : 0.0;
         } else if ( ! strcmp(argv[i+1],"west") ) {
            PRINTF("  Tube pointe a l'ouest\n");
            ha = ( tel->tubepos == TUBE_EST ) ? 90.0 : -90.0;
            dec = ( tel->tubepos == TUBE_EST ) ? 180.0 : 0.0;
         } else if ( ! strcmp(argv[i+1],"south") ) {
            PRINTF("  Tube pointe au sud\n");
            ha = 0.0;
            dec = ( tel->tubepos == TUBE_EST ) ? 180.0 : 0.0;
         } else if ( ! strcmp(argv[i+1],"north") ) {
            PRINTF("  Tube pointe au nord\n");
            ha = ( tel->tubepos == TUBE_EST ) ? 90.0 : -90.0;
            dec = 90.0;
         } else if ( ! strcmp(argv[i+1],"north_pole") ) {
            PRINTF("  Tube pointe au pole N\n");
            ha = ( tel->tubepos == TUBE_EST ) ? 90.0 : -90.0;
            dec = ( tel->tubepos == TUBE_EST ) ? 90.01 : 89.99; // 90° est un point appartenant a la zone 'non retournee', donc tube a l'ouest.
         } else if ( ! strcmp(argv[i+1],"south_pole") ) {
            PRINTF("  Tube pointe au pole N\n");
            ha = ( tel->tubepos == TUBE_EST ) ? 90.0 : -90.0;
            dec = ( tel->tubepos == TUBE_EST ) ? -90.01 : 89.99; // 90° est un point appartenant a la zone 'non retournee', donc tube a l'ouest.
         }
      }
      if ( ! strcmp(argv[i],"-startmotor") ) {
         PRINTF("  Demarrage du suivi\n");
         start_motor = 1;
      }
      if ( ! strcmp(argv[i],"-debug") ) {
         PRINTF("  Debug mode\n");
         mode_debug = 1;
      }
   }

   // Initialisation du fichier mouchard
   if (tel->mouchard==1) {
      f=fopen("mouchard_eqmod.txt","wt");
      fclose(f);
         sprintf(s,"puts %d",argc);
         mytel_tcleval(tel,s);
	 for (j=0;j<argc;j++) {
            sprintf(s,"puts \"%s\"",argv[j]);
            mytel_tcleval(tel,s);
         }
   }

   // Initialisation de la communication avec la monture
   PRINTF("Init:\n");
   sprintf(s,":f1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   PRINTF("  :f1(=%3s)\n",ss);
   sprintf(s,":f2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   PRINTF("  :f2(=%3s)\n",ss);
   
   sprintf(s,":e1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_e1=num;
   PRINTF("  :e1(=%6X,%d)\n",num,num);

	if (mode_debug == 0 ) {
		if ( strlen(ss) == 0 ) {
			sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
			return 1;
		}
	}

   sprintf(s,":e2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_e2=num;
   PRINTF("  :e2(=%6X,%d)\n",num,num);

   sprintf(s,":a1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	if (num==0) { num=1 ; } ; // avoid division by zero
   if (num<0) { num= num + (1<<24); }
   tel->param_a1=num; // Microsteps per axis Revolution
   PRINTF("  :a1(=%6X,%d)\n",num,num);

   sprintf(s,":a2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	if (num==0) { num=1 ; } ; // avoid division by zero
   if (num<0) { num = num + (1<<24); }
   tel->param_a2=num; // Microsteps per axis Revolution
   PRINTF("  :a2(=%6X,%d)\n",num,num);

   sprintf(s,":b1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_b1=num;
   PRINTF("  :b1(=%6X,%d)\n",num,num);

   sprintf(s,":b2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_b2=num;
   PRINTF("  :b2(=%6X,%d)\n",num,num);

   sprintf(s,":g1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_g1=num;
   PRINTF("  :g1(=%6X,%d)\n",num,num);

   sprintf(s,":g2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_g2=num;
   PRINTF("  :g2(=%6X,%d)\n",num,num);

   sprintf(s,":f1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_f1=num;
   PRINTF("  :f1(=%6X,%d)\n",num,num);

   sprintf(s,":f2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_f2=num;
   PRINTF("  :f2(=%6X,%d)\n",num,num);

   sprintf(s,":s1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_s1=num; // Microsteps per Worm Revolution
   PRINTF("  :s1(=%6X,%d)\n",num,num);

   sprintf(s,":s2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
   tel->param_s2=num; // Microsteps per Worm Revolution
   PRINTF("  :s2(=%6X,%d)\n",num,num);

   // Facteur de conversion deg vers step: step = deg * tel->radec_position_conversion
   tel->radec_position_conversion = 1.0 * tel->param_a1 / 360.;

   // Init des positions moteurs
   sprintf(s,":j1"); eqmod_putread(tel,s,ss);
   PRINTF("  :j1 --> '%6s'\n",ss);
   sprintf(s,":j2"); eqmod_putread(tel,s,ss);
   PRINTF("  :j2 --> '%6s'\n",ss);
   if ( ! strncmp(ss,"000080",6) ) {
      // On vient d'allumer la monture. Les deux positions sont sur 800000.
      // Le sens de rotation des moteurs est le suivant:
      //    AD: commande + (les codeurs incrementent) = CCW  AH augm, RA dim
      //    AD: commande - (les codeurs decrementent) = CW  AH dim, RA augm
      //    DEC: commande + (les codeurs incrementent) = CCW.
      //    DEC: commande - (les codeurs decrementent) = CW
      // Codeurs initialises en HA=0, DEC=0
      eqmod_encode(tel,(int)(ha * tel->radec_position_conversion),ss);
      sprintf(s,":E1%s",ss); eqmod_putread(tel,s,ss);
      PRINTF("  %s\n",s);
      eqmod_encode(tel,(int)(dec * tel->radec_position_conversion),ss);
      sprintf(s,":E2%s",ss); eqmod_putread(tel,s,ss);
      PRINTF("  %s\n",s);
   } else {
      // La monture etait deja allumee ; mais si on a retourne le tube,
      // il faut reactualiser le codeur dec.
      PRINTF("  Monture deja initialisee, recherche de l'orientation du tube\n");
      eqmod_decode(tel,ss,&res);

   }
   sprintf(s,":j1"); eqmod_putread(tel,s,ss);
   PRINTF("  :j1 --> '%6s'\n",ss);
   sprintf(s,":j2"); eqmod_putread(tel,s,ss);
   PRINTF("  :j2 --> '%6s'\n",ss);

   eqmod_putread(tel,":K1",NULL);
   eqmod_putread(tel,":K2",NULL);
   PRINTF("\n");

   // Limites de pointage
   //tel->stop_e_uc=-tel->param_a1/2;
   //tel->stop_w_uc=tel->param_a1/2;
   tel->stop_e_uc = (int)(-10.0 * tel->radec_position_conversion);
   tel->stop_w_uc = (int)(10.0 * tel->radec_position_conversion);
   
   tel->old_state = tel->state;
   tel->state = EQMOD_STATE_HALT;

   // Mise en route de l'alimentation des moteurs
   sprintf(s,":F1"); res=eqmod_putread(tel,s,ss);
   sprintf(s,":F2"); res=eqmod_putread(tel,s,ss);

   tel->old_state = tel->state;
   tel->state = EQMOD_STATE_STOPPED;

   if ( start_motor )
		tel->radec_motor=0;
      eqmod2_action_motor(tel);

	tel->dead_delay_slew=1.8; /* delai en secondes estime pour un slew sans bouger */
	tel->gotodead_ms=900;
	tel->gotoread_ms=350;

	if (strcmp(tel->home,"")==0) {
		strcpy(tel->home,"GPS 0 E 45 100");
	}
	strcpy(tel->homePosition,tel->home);
   eqmod_radec_coord(tel,NULL);

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
   return eqmod_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   sprintf(result,"%s %d",state2string(tel->state),tel->tubepos);
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
   //eqmod_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
   time_t ltime;
   double jd;
   char s[100];
	jd=mytel_sec2jd((int)time(&ltime));
	sprintf(s,"mc_date2iso8601 %f",jd);
	Tcl_Eval(tel->interp,s);
	strcpy(ligne,tel->interp->result);
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
   strcpy(ligne,tel->home);
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
   sprintf(tel->home,"GPS %f %c %f %f",longitude,ew[0],latitude,altitude);
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
   return 0;
}

int eqmod_decode(struct telprop *tel,char *chars,int *num)
{
   char s[2048];
   sprintf(s,"eqmod_decode %s",chars);
   if (mytel_tcleval(tel,s)==1) {
      *num=0;
      return 1;
   }
   *num=atoi(tel->interp->result);
   return 0;
}

int eqmod_encode(struct telprop *tel,int num,char *chars)
{
   char s[2048];
   sprintf(s,"eqmod_encode %d",num);
   if (mytel_tcleval(tel,s)==1) {
      strcpy(chars,tel->interp->result);
      return 1;
   }
   strcpy(chars,tel->interp->result);
   return 0;
}

/*
 * Coordonnees en ADU
 */
int eqmod_positions12(struct telprop *tel,int *p1,int *p2)
{
   char s[1024],ss[1024],axe;
   int res;

   // Vide le buffer
   res=eqmod_read(tel,s);

   // Lecture AXE 1 (axe horaire)
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

   // Lecture AXE 2 (axe declinaison)
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

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage EQMOD      --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

void eqmod_codeur2skypos(struct telprop *tel, int hastep, int decstep, double *ha, double *ra, double *dec)
{
   double lst, int_ha, int_dec, int_ra;
   const int deg90 = (int)(90.0 * tel->radec_position_conversion);

   PRINTF("  Conversion codeur->radec (PosTube=%s , k=%f steps/°, 90°=%d)\n",TubePos2string(tel->tubepos),tel->radec_position_conversion,deg90);

   // Conversion de l'axe horaire
   int_ha = hastep / tel->radec_position_conversion;
   PRINTF("  ha_step=%d (90°=%d) ha_initial=%f\n",hastep, deg90, int_ha);

   // Conversion de l'axe declinaison, et traitement du retournement
   int_dec = decstep / tel->radec_position_conversion;
   PRINTF("  dec_step=%d (90°=%d) dec_initial=%f\n",decstep, deg90, int_dec);

   // Traitement du retournement:
   // 1.  Si le codeur dec est dans la zone etendue (<-90° ou >90°), il faut ramener la declinaison dans -90°,+90°
   // 2.  Si le cadran de la declinaison ne correspond au cadran de l'initialisation, alors la monture est retournee,
   //     et il faut ramener ha dans -180°,180°.
   if ( ( decstep > deg90 ) || ( decstep < -deg90 ) ) {
      if (tel->latitude >= 0.0 ) {
         int_dec = 180.0 - int_dec;
      } else {
         int_dec = -180.0 - int_dec;
      }
      PRINTF("    -> dec retourne.\n");
      if ( tel->tubepos == TUBE_OUEST ) {
         // Cette configuration correspond a un tube initialise a l'ouest, mais qui est passe a l'est.
         int_ha -= 180.0;
      }
   } else {
      if ( tel->tubepos == TUBE_EST ) {
         // Cette configuration correspond a un tube initialise a l'est, mais qui est passe a l'ouest.
         int_ha += 180.0;
      }
   }

   // Recadrage de l'angle horaire entre -180°,180°.
   if ( int_ha < -180.0 ) {
      int_ha += 360.0;
      PRINTF("    -> ha retourne.\n");
   }
   if ( int_ha > 180.0 ) {
      int_ha -= 360.0;
      PRINTF("    -> ha retourne.\n");
   }

   lst = eqmod_tsl(tel,NULL,NULL,NULL);
   int_ra = lst - int_ha + 360 * 5; // Remember: H=TSL-alpha => alpha=TSL-H
   int_ra = fmod(int_ra,360.);
   PRINTF("  valeurs finales: ha=%f, ra=%f, dec=%f\n",int_ha,int_ra,int_dec);

   if (ha) {
      *ha = int_ha;
   }
   if (ra) {
      *ra = int_ra;
   }
   if (dec) {
      *dec = int_dec;
   }
}


int eqmod_radec_coord(struct telprop *tel,char *result)
{
   char s[1024], ras[20], decs[20];
   int hastep, decstep;
   double ra, dec;

   PRINTF("*** eqmod_radec_coord\n");
   eqmod_positions12(tel, &hastep, &decstep);
   eqmod_codeur2skypos(tel, hastep, decstep, NULL, &ra, &dec);

   // Elaboration de la chaine de caracteres en sortie, si besoin
   if ( NULL != result ) {
      sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
      strcpy(ras,tel->interp->result);
      sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
      strcpy(decs,tel->interp->result);
      sprintf(result,"%s %s",ras,decs);
   }

   return 0;
}

int eqmod_hadec_coord(struct telprop *tel,char *result)
{
   char s[1024], ras[20], decs[20];
   int hastep, decstep;
   double ha, dec;

   PRINTF("*** eqmod_hadec_coord\n");
   eqmod_positions12(tel, &hastep, &decstep);
   eqmod_codeur2skypos(tel, hastep, decstep, &ha, NULL, &dec);

   // Elaboration de la chaine de caracteres en sortie, si besoin
   if ( NULL != result ) {
      sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ha); mytel_tcleval(tel,s);
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
		tel->radec_motor=1;
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

/***************************************************************************/
/* Return the julian day from seconds elapsed from Jan. 1st 1970           */
/***************************************************************************/
double mytel_sec2jd(time_t secs1970)
{
	return(2440587.5+(int)secs1970/86400.);
}

// eqmod_tsl
//  Calcule le temps sideral local.
//  Si non NULL, les parametres h, m, sec sont mis a jour.
//  La fonction renvoie le TSL en degres.
double eqmod_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
   double tsl;
   time_t ltime;
   double jd;
	double dt;

	dt=tel->dead_delay_slew/86400;
   //eqmod_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
	jd=mytel_sec2jd((int)time(&ltime));
   sprintf(s,"mc_date2lst [expr %f + %f] {%s}",jd,dt,tel->home);
   mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   sprintf(s,"lindex {%s} 0",ss);
   mytel_tcleval(tel,s);
   if (h) {
	   *h=(int)atoi(tel->interp->result);
   }
   sprintf(s,"lindex {%s} 1",ss);
   mytel_tcleval(tel,s);
   if (m) {
		*m=(int)atoi(tel->interp->result);
   }
   sprintf(s,"lindex {%s} 2",ss);
   mytel_tcleval(tel,s);
   if (sec) {
		*sec=(double)atof(tel->interp->result);
   }
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

void eqmod_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
{
   // Conversion TSystem -> TU pour l'interface Aud'ACE par exemple
   // (function = ::audace::date_sys2ut)
   char ligne[1024];
   sprintf(ligne,"info commands %s",function);
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
   printf("\n");
   eqmod_radec_coord(tel,NULL); // Permet de verifier le retournement

   return 0;
}

int eqmod2_stopmotor_old(struct telprop *tel, int axes)
{
   char s[1024],ss[1024],axe;
   int res;
   double v;
	double speed_track_ra=0,speed_track_dec=0;

   PRINTF("Track motor to zero\n");

   if ( axes & AXE_RA ) {
		// Track Hour Axis
		PRINTF("  ra: ");
		axe='1';
		if (speed_track_ra>0) {
			PRINTF("dir>0 ");
			sprintf(s,":G%c10",axe);
			res=eqmod_putread(tel,s,NULL);
		} else if (speed_track_ra<0) {
			PRINTF("dir<0 ");
			sprintf(s,":G%c11",axe);
			res=eqmod_putread(tel,s,NULL);
		}
			v = fabs(((float)tel->param_b1) * 360.0 / ((float)speed_track_ra) / ((float)tel->param_a1));
			PRINTF("speed=%d ",(int)v);
			eqmod_encode(tel,(int)v,ss);
			sprintf(s,":I%c%s",axe,ss);
			res=eqmod_putread(tel,s,NULL);
			sprintf(s,":J%c",axe);
			res=eqmod_putread(tel,s,NULL);
		PRINTF("\n");
	}

   // Track Declination Axis
   if ( axes & AXE_DEC ) {
		PRINTF("  dec: ");
		axe='2';
		if (speed_track_dec>0) {
			PRINTF("dir>0 ");
			sprintf(s,":G%c10",axe);
			res=eqmod_putread(tel,s,NULL);
		} else if (speed_track_dec<0) {
			PRINTF("dir<0 ");
			sprintf(s,":G%c11",axe);
			res=eqmod_putread(tel,s,NULL);
		}
			v = fabs(((float)tel->param_b2) * 360.0 / ((float)speed_track_dec) / ((float)tel->param_a2));
			PRINTF("speed=%d ",(int)v);
			eqmod_encode(tel,(int)(v),ss);
			sprintf(s,":I%c%s",axe,ss);
			res=eqmod_putread(tel,s,NULL);
			sprintf(s,":J%c",axe);
			res=eqmod_putread(tel,s,NULL);
		PRINTF("\n");
	}

   return 0;
}

int eqmod2_track(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res;
   double v;

   PRINTF("Track motor\n");

   // Track Hour Axis
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

   // Track Declination Axis
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

   if ( ( axe(direction) == AXE_DEC ) && ( tel->tubepos == TUBE_EST ) ) {
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
   double ha,lst,sec,dec;
   int h,m;
   int HA0, DEC0;
   double ha0, dec0, dha, ddec;
   int retournement;
   const int DEG90 = (int)(90.0 * tel->radec_position_conversion);
   
   printf("GOTO:\n");
   	
   // Etape1: savoir ou on est
   eqmod_positions12(tel,&HA0,&DEC0);

   PRINTF("*** eqmod_radec_coord\n");
   eqmod_positions12(tel, &HA0, &DEC0);
   eqmod_codeur2skypos(tel, HA0, DEC0, &ha0, NULL, &dec0);
   printf("  position initiale: (%d,%d) / (%f,%f)\n",HA0,DEC0,ha0,dec0);

   // Etape2: Calculer le pointage a effectuer
   lst = eqmod_tsl(tel,&h,&m,&sec) + 4./86164*360.;  // ajout empirique de 4 secondes pour tenir compte du temps mort de reponse de la monture
   ha = fmod( lst-tel->ra0+360*5 , 360.0 );
   dec = tel->dec0;
   if ( ha > 180.0 ) ha -= 360.;
   printf("  destination: (%f,%f)\n",ha,dec);
   
   // Etape3: evaluer le besoin de retournement
   if ( DEC0 > 90.0 * tel->radec_position_conversion ) {
      printf("     retournement cas 1\n");
      retournement = ha < ( tel->stop_e_uc / tel->radec_position_conversion ) ? 1 : 0;
   } else {
      printf("     retournement cas 2\n");
      retournement = ha > ( tel->stop_w_uc / tel->radec_position_conversion ) ? 1 : 0;
   }
   printf("  retournement = %d\n",retournement);

   // Etape 4: calcul du trajet a parcourir
   dha = ha - ha0;
   ddec = dec - dec0;
   if ( retournement ) {
      if ( DEC0 > DEG90 ) {
         dha = ha - ha0 + 180.0;
      } else {
         dha = ha - ha0 - 180.0;
      }
      if (tel->latitude >= 0.0 ) {
         ddec = 180.0 - ( dec + dec0 );
      } else {
         ddec = dec + dec0 - 180.0;
      }
   }
   printf("  destination recalculee: (%f,%f) soit un delta (%f,%f)\n",ha,dec,dha,ddec);

   // Etape 5: Pointage de la monture
   if ( DEC0 > DEG90 ) {
      sens = '1';
   } else {
      sens = '0';
   }
   
   axe='1';
   sprintf(s,":G%c0%c",axe,'0'); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
   eqmod_encode(tel,(int)(dha * tel->radec_position_conversion),ss);
   sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL); printf("%s \n",s);

   axe='2';
   sprintf(s,":G%c0%c",axe,sens); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
   eqmod_encode(tel,(int)(ddec * tel->radec_position_conversion),ss);
   sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL); printf("%s ",s);
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL); printf("%s \n",s);

   return 0;
   
}

int eqmod2_waitgoto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
   int nbgoto=2;
   int p10,p1,p20,p2,dp1,dp2;
   double tol;
	long clk_tck = CLOCKS_PER_SEC;
   clock_t clock0,clock00;
	double dt1,dt2;
	FILE *f;

   if (tel->radec_goto_blocking==1) {
      // A loop is actived until the telescope is stopped
      eqmod_positions12(tel,&p10,&p20);
      PRINTF("  wait: %d %d\n",p10,p20);
      tol=(tel->radec_position_conversion)/3600.*10; // tolerance +/- 10 arcsec
		clock00 = clock();
      while (1==1) {
         time_in++;
         sprintf(s,"after %d",tel->gotodead_ms); mytel_tcleval(tel,s);
         eqmod_positions12(tel,&p1,&p2);
         PRINTF("  wait: %d %d\n",p10,p20);
			dp1=p1-p10;
			dp2=p2-p20;
			f=fopen("mouchard_eqmod.txt","at");
			fprintf(f,"DP A dp1=%d dp2=%d tol=%f\n",dp1,dp2,tol);
			fclose(f);
			if ((fabs(dp1)<tol)&&(fabs(dp2)<tol)) {break;}
         p10=p1;
         p20=p2;
         if (time_in>=time_out) {break;}
      }
		dt1=(double)(clock()-clock00)/(double)clk_tck;
		clock0 = clock();
      if (nbgoto>1) {
         eqmod2_goto(tel);
         // A loop is actived until the telescope is stopped
         eqmod_positions12(tel,&p10,&p20);
         PRINTF("  wait: %d %d\n",p10,p20);
         while (1==1) {
            time_in++;
            sprintf(s,"after %d",tel->gotoread_ms); mytel_tcleval(tel,s);
            eqmod_positions12(tel,&p1,&p2);
            PRINTF("  wait: %d %d\n",p10,p20);
				dp1=p1-p10;
				dp2=p2-p20;
				f=fopen("mouchard_eqmod.txt","at");
				fprintf(f,"DP B dp1=%d dp2=%d tol=%f\n",dp1,dp2,tol);
				fclose(f);
				if ((fabs(dp1)<tol)&&(fabs(dp2)<tol)) {break;}
            p10=p1;
            p20=p2;
            if (time_in>=time_out) {break;}
         }
         sprintf(s,"after %d",tel->gotoread_ms); mytel_tcleval(tel,s);
      }
		dt2=(double)(clock()-clock0)/(double)clk_tck;
		f=fopen("mouchard_eqmod.txt","at");
		fprintf(f,"dt1=%f (%d) dt2=%f\n",dt1,nbgoto,dt2);
		fprintf(f,"\n");
		fclose(f);
   }
   return 0;
}


int eqmod2_match(struct telprop *tel, char dir)
{
   char s[1024],ss[1024],axe;
   int res;
   double ha, lst, dec;
   int HA0, DEC0;
   int p;

   if ( ( tel->state != EQMOD_STATE_STOPPED ) && ( tel->state != EQMOD_STATE_TRACK ) ) {
      return -1;
   }

   eqmod_positions12(tel,&HA0,&DEC0);
   
   // Calcul de l'angle horaire correspondant a la position de match
   // Meme si le tube est retourne, on travaille toujours entre -180° et +180°.
   // Remember: H=TSL-alpha
   lst = eqmod_tsl(tel,NULL,NULL,NULL);
   ha = fmod(lst-tel->ra0+360*5,360.);
   if ( ha > 180.0 ) {
      ha -= 360;
   }
   dec = tel->dec0;
   // On place la declinaison dans le meme quadran que la declinaison actuelle
   if ( DEC0 > ( 90.0 * tel->radec_position_conversion ) ) {
      dec = 180.0 - dec;
   } else if ( DEC0 < ( -90.0 * tel->radec_position_conversion ) ) {
      dec = -180.0 + dec;
   }

   PRINTF("Match: ha=%f dec=%f pos_tube=%s\n",ha,dec,TubePos2string(tel->tubepos));

   if ( tel->state == EQMOD_STATE_TRACK ) {
      eqmod2_stopmotor(tel,AXE_RA | AXE_DEC);
   }

   // Encodage axe horaire
   //   angle horaire entre -180 et 180
   //   codeur entre -a1/2 et a1/2
   axe='1';
   p = (int)(ha * tel->radec_position_conversion); PRINTF("  AH Souhaite: [[ha=%d]] ",p);
   eqmod_encode(tel,p,ss);
   sprintf(s,":E%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);

   // Encodage declinaison
   //   angle entre -90 et +90 pour tube a l'ouest (codeur entre -a1/4 et a1/4)
   //   angle entre -90 et -270 pour tube a l'est dans l'hemisphere sud
   //   angle entre +90 et +270 pour tube a l'est dans l'hemisphere nord
   axe='2';
   p = (int)(dec * tel->radec_position_conversion); PRINTF("  Dec souhaitee: [[%d]] ",p);
   eqmod_encode(tel,p,ss);
   sprintf(s,":E%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);

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
	if (tel->radec_motor==0) {
      eqmod2_track(tel);
      tel->old_state = tel->state;
      tel->state = EQMOD_STATE_TRACK;
	} else {
      eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
      tel->old_state = tel->state;
      tel->state = EQMOD_STATE_STOPPED;
	}
	/*
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
	*/
   printf("CMD_MOTOR: state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));

   return 0;
}


int eqmod2_action_goto(struct telprop *tel)
{
	char ligne[300];
   // On impose toujours un goto bloquant sinon le moteur 
	// ne fait pas le suivi apres pointage.
   tel->radec_goto_blocking = 1;
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
			if (tel->radec_goto_blocking == 1) {
				eqmod2_waitgoto(tel);
			}
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
			if (tel->radec_goto_blocking == 1) {
				eqmod2_waitgoto(tel);
			}
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

   sprintf(ligne,"CMD_GOTO: state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));
	printf("%s",ligne);

   return 0;
}

