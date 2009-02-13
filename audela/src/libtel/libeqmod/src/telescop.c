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
   int k,num,res;
   Tcl_DString dsptr;
   char **argvv=NULL;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   FILE *f;

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
   tel->tempo=200;
	/* --- mouchard ---*/
	tel->mouchard=0; /* 0=pas de fichier log */
	if (tel->mouchard==1) {
		f=fopen("mouchard_eqmod.txt","wt");
		fclose(f);
	}
	/* --- inits --- */
   sprintf(s,":e1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	tel->param_e1=num;
   sprintf(s,":e2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	tel->param_e2=num;
   sprintf(s,":a1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	if (num<0) { num=num+(int)pow(2,24); }
	tel->param_a1=num; // Microsteps per axis Revolution
   sprintf(s,":a2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	if (num<0) { num=num+(int)pow(2,24); }
	tel->param_a2=num; // Microsteps per axis Revolution
   sprintf(s,":b1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	tel->param_b1=num;
   sprintf(s,":b2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	tel->param_b2=num;
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
   sprintf(s,":s2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
	tel->param_s2=num; // Microsteps per Worm Revolution
	/* --- Mise en route de l'alimentation des moteurs ---*/
   sprintf(s,":F1"); res=eqmod_putread(tel,s,ss);
   sprintf(s,":F2"); res=eqmod_putread(tel,s,ss);
	/* --- sppeds --- */
	tel->track_diurnal=0.004180983;
	tel->speed_track_ra=tel->track_diurnal; /* (deg/s) */
	tel->speed_track_dec=0.; /* (deg/s) */
	tel->speed_slew_ra=3.; /* (deg/s)  temps mort=4s */
	tel->speed_slew_dec=3.; /* (deg/s)  temps mort=4s */
	tel->radec_speed_dec_conversion=148290.485754; /*  */
	tel->radec_position_conversion=tel->param_a1/360.; /* (ADU)/(deg) */
	tel->radec_move_rate_max=1.0; /* deg/s */
	/* --- Match --- */
   sprintf(s,":j2"); res=eqmod_putread(tel,s,ss);
	if (strcmp(ss,"000080")==1) {
		// On vient d'allumer la monture
		// On suppose qu'elle est a HA=6h DEC=90
		// On place les zero codeurs sur HA=0 et DEC=90
		eqmod_encode(tel,(int)(fabs(6*15*tel->radec_position_conversion)),ss);
	   sprintf(s,":E1%s",ss); res=eqmod_putread(tel,s,ss);
		eqmod_encode(tel,0,ss);
	   sprintf(s,":E2%s",ss); res=eqmod_putread(tel,s,ss);
	}
	tel->ha00=0.;
	tel->roth00=0;
	tel->dec00=90.;
	tel->rotd00=0;
	/* --- stops --- */
	tel->stop_e_uc=-tel->param_a1/2;
	tel->stop_w_uc=tel->param_a1/2;
	/* --- Home --- */
	tel->latitude=43.75203;
	sprintf(tel->home0,"GPS 6.92353 E %+.6f 1320.0",tel->latitude);
   /* --- sortie --- */
   Tcl_DStringFree(&dsptr);
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
   eqmod_delete(tel);
   return 0;
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return mytel_radec_state(tel,result);
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return mytel_radec_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return mytel_radec_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   return mytel_radec_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return mytel_radec_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return mytel_focus_init(tel);
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return mytel_focus_coord(tel,result);
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return mytel_focus_goto(tel);
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return mytel_focus_move(tel,direction);
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return mytel_focus_stop(tel,direction);
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return mytel_focus_motor(tel);
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   return mytel_date_get(tel,ligne);
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return mytel_date_set(tel,y,m,d,h,min,s);
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   return mytel_home_get(tel,ligne);
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   return mytel_home_set(tel,longitude,ew,latitude,altitude);
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
   eqmod_match(tel);
   return 0;
}

int mytel_hadec_init(struct telprop *tel)
{
   eqmod_hadec_match(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   eqmod_stategoto(tel,&state);
   if (state==1) {strcpy(result,"tracking");}
   else if (state==2) {strcpy(result,"pointing");}
   else {strcpy(result,"unknown");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
   int nbgoto=2;
   int p10,p1,p20,p2;
   double tol;

   eqmod_arret_pointage(tel);
   eqmod_goto(tel);
   sate_move_radec='A';
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      eqmod_positions12(tel,&p10,&p20);
      tol=(tel->radec_position_conversion)/3600.*10; /* tolerance +/- 10 arcsec */
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         eqmod_positions12(tel,&p1,&p2);
         if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
         p10=p1;
         p20=p2;
         if (time_in>=time_out) {break;}
      }
	   if (nbgoto>1) {
		   eqmod_goto(tel);
			/* A loop is actived until the telescope is stopped */
			eqmod_positions12(tel,&p10,&p20);
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				eqmod_positions12(tel,&p1,&p2);
				if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
				p10=p1;
				p20=p2;
				if (time_in>=time_out) {break;}
			}
      }
      eqmod_suivi_marche(tel);
      sate_move_radec=' ';
   }
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
   int nbgoto=1;
   int p10,p1,p20,p2;
   double tol;

   eqmod_arret_pointage(tel);
   eqmod_hadec_goto(tel);
   sate_move_radec='A';
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      eqmod_positions12(tel,&p10,&p20);
      tol=(tel->radec_position_conversion)/3600.*10; /* tolerance +/- 10 arcsec */
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         eqmod_positions12(tel,&p1,&p2);
         if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
         p10=p1;
         p20=p2;
         if (time_in>=time_out) {break;}
      }
      sate_move_radec=' ';
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
/*
*/
{
   char s[1024],direc[10],vc[20];
   int res;
   double v;
   char axe,sens,vit;
   
   if (tel->radec_move_rate>1.0) {
      tel->radec_move_rate=1;
   } else if (tel->radec_move_rate<0.) {
      tel->radec_move_rate=0.;
   }
	if (tel->radec_move_rate>0.7) {
		vit='3';
		v=(tel->radec_move_rate-0.7)/0.3;
		v=150+450*tel->radec_move_rate;
		v=(150+450)/v*10;
	} else {
		vit='1';
		v=tel->radec_move_rate/0.7;
		v=0.5+43.1*tel->radec_move_rate;
		v=(0.5+43.1)/v*10;
	}
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   sens='0';
   if (strcmp(direc,"N")==0) {
      axe='2';
      sens='1';
   } else if (strcmp(direc,"S")==0) {
      axe='2';
      sens='0';
   } else if (strcmp(direc,"E")==0) {
      axe='1';
      sens='1';
   } else if (strcmp(direc,"W")==0) {
      axe='1';
      sens='0';
   }
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,":G%c%c%c",axe,vit,sens);
   res=eqmod_putread(tel,s,NULL);
	eqmod_encode(tel,(int)v,vc);
   sprintf(s,":I%c%s",axe,vc);
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,":J%c",axe);
   res=eqmod_putread(tel,s,NULL);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],axe;
   int res;
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      eqmod_stopgoto(tel);
      sate_move_radec=' ';
   } else {
      /* on arrete un MOVE */
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,tel->interp->result);
      if (strcmp(direc,"N")==0) {
         axe='2';
      } else if (strcmp(direc,"S")==0) {
         axe='2';
      } else if (strcmp(direc,"E")==0) {
         axe='1';
      } else if (strcmp(direc,"W")==0) {
         axe='1';
      }
      sprintf(s,":K%c",axe);
      res=eqmod_putread(tel,s,NULL);
      return 0;
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      eqmod_suivi_arret(tel);
   } else {
      /* start the motor */
      eqmod_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   eqmod_coord(tel,result);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   eqmod_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->home0);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
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

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   eqmod_hadec_coord(tel,result);
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
			sprintf(res,"Error ",ss+1);
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
	if (res!=NULL) { strcpy(res,""); }
	sprintf(s,"read -nonewline %s ; puts -nonewline %s \"%s\\r\" ; flush %s ; after %d ; read %s",tel->channel,tel->channel,cmd,tel->channel,tel->tempo,tel->channel);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
	if (res!=NULL) { 
		ss=tel->interp->result;
		if ((int)strlen(ss)>1) {
			if (ss[0]=='!') {
				sprintf(res,"Error ",ss+1);
			} else {
				strcpy(res,ss+1);
			}
		} else {
			strcpy(res,ss);
		}
	}
   return 0;
}

int eqmod_decode(struct telprop *tel,char *chars,int *num)
{
   char s[2048];
	/* --- trancoder l'hexadécimal de res en numérique signe ---*/
	strcpy(s,"\
	proc eqmod_decode { hexa } {\
		set nn [string length $hexa];\
		set n [expr $nn/2];\
		set integ 0;\
		for {set k 0} {$k<$n} {incr k} {\
			set hex [string range $hexa [expr $k*2] [expr $k*2+1]];\
			set ligne \"binary scan \\\\x$hex c1 b\";\
			eval $ligne;\
			if {$b<0} { incr b 256 };\
			set integ [expr $integ+pow(2,[expr $k*8])*$b];\
		};\
		set maxi [expr pow(2,24)];\
		if {$integ>[expr $maxi/2]} {\
			set integ [expr $integ-$maxi];\
		};\
		return $integ;\
	}");
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
	/* --- trancoder le numerique en res hexadécimal ---*/
	strcpy(s,"\
	proc eqmod_encode { integ } {\
		set n 3;\
		set bb \"\";\
		for {set k 0} {$k<$n} {incr k} {;\
			set kk [expr $n-$k-1];\
			set base [expr pow(2,[expr $kk*8])];\
			set b [expr int(floor($integ/$base))];\
			binary scan [format %c $b] H* h;\
			set h [string toupper $h];\
			set integ [expr $integ-$base*$b];\
			set bb \"$h${bb}\";\
		};\
		return $bb;\
	}");
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

int eqmod_arret_pointage(struct telprop *tel)
{
   char s[1024],axe;
   int res;
   /*--- Arret pointage */
   axe='1';
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   axe='2';
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   return 0;
}

int eqmod_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   int res;
   char ras[20];
   char decs[20];   
   int roth_uc,rotd_uc;
   int h,m,retournement=0;
   double sec,lst,ha,dec,ra;
   /* --- Vide le buffer --- */
   res=eqmod_read(tel,s);
   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
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
		eqmod_decode(tel,s,&rotd_uc);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      if (fabs(dec)>90) {
         retournement=1;
         dec=(tel->latitude)/fabs(tel->latitude)*180-dec;
      }
   }
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
		eqmod_decode(tel,s,&roth_uc);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      /* H=TSL-alpha => alpha=TSL-H */
      lst=eqmod_tsl(tel,&h,&m,&sec);
      ra=lst-ha+360*5;
      if (retournement==1) {
         ra+=180.;
      }
      ra=fmod(ra,360.);
   }
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,tel->interp->result);
   sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,tel->interp->result);
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int eqmod_hadec_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   int res;
   char ras[20];
   char decs[20];   
   int roth_uc,rotd_uc;
   int retournement=0;
   double ha,dec,ra;
   /* --- Vide le buffer --- */
   res=eqmod_read(tel,s);
   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
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
		eqmod_decode(tel,s,&rotd_uc);
		if (rotd_uc>180*tel->radec_position_conversion) {
			rotd_uc-=(int)(360*tel->radec_position_conversion);
		}
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      if (fabs(dec)>90) {
         retournement=1;
         dec=(tel->latitude)/fabs(tel->latitude)*180-dec;
      }
   }
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
		eqmod_decode(tel,s,&roth_uc);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      ra=ha+360*5;
      if (retournement==1) {
         ra+=180.;
      }
      ra=fmod(ra,360.);
   }
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,tel->interp->result);
   sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,tel->interp->result);
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int eqmod_positions12(struct telprop *tel,int *p1,int *p2)
/*
* Coordonnées en ADU
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

int eqmod_match(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res;
   
   double ha,lst,sec;
   int h,m;
   /* --- Effectue le pointage RA --- */
   /* H=TSL-alpha => alpha=TSL-H */
   lst=eqmod_tsl(tel,&h,&m,&sec);
   ha=lst-tel->ra0+360*5;
   ha=fmod(ha,360.);
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
		eqmod_decode(tel,s,&tel->roth00);
      tel->ha00=ha;
   }
   /* --- Lecture AXE 2 (delta) --- */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
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
		eqmod_decode(tel,s,&tel->rotd00);
      tel->dec00=tel->dec0;
   }
   /* --- --- */
   return 0;
}

int eqmod_hadec_match(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res,p;
   
   double ha;
   /* --- HA --- */
   /* H=TSL-alpha => alpha=TSL-H */
   ha=tel->ra0+360*5;
   ha=fmod(ha,360.);
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
		eqmod_decode(tel,s,&tel->roth00);
      tel->ha00=ha;
   }
   /* --- Init AXE 1 (horaire) 0 UC pour HA = 0h --- */
	p=(int)(0+(ha-0)*tel->radec_position_conversion);
	eqmod_encode(tel,p,s);
   sprintf(ss,":E%c%s",axe,s);
   res=eqmod_putread(tel,ss,s);
	tel->roth00=0;
	tel->ha00=0.;
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
		eqmod_decode(tel,s,&tel->rotd00);
      tel->dec00=tel->dec0;
   }
   /* --- Init AXE 2 (declinaison) 0 UC pour DEC = 90° --- */
	p=(int)(0-(tel->dec00-90)*tel->radec_position_conversion);
	eqmod_encode(tel,p,s);
   sprintf(ss,":E%c%s",axe,s);
   res=eqmod_putread(tel,ss,s);
	tel->rotd00=0;
	tel->dec00=90.;
   /* --- --- */
   return 0;
}

int eqmod_goto(struct telprop *tel)
{
   char s[1024],ss[1024],axe,sens;
   int res;
   int retournement=0;
   int p,p0,dp;
   double v;
   double ha,lst,sec;
   int h,m;
   /* --- Effectue le pointage RA --- */
   /* H=TSL-alpha => alpha=TSL-H */
   lst=eqmod_tsl(tel,&h,&m,&sec);
	lst=lst+4./86400*360.; // ajout empirique de 4 secondes pour tenir compte du temps mort de reponse de la monture
   ha=lst-tel->ra0+360*5;
   ha=fmod(ha,360.);
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
	if (p>fabs(360*tel->radec_position_conversion)/2) {
		// --- on passe au dela du meridien descendant (nord) ---*/
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
   /* --- Effectue le pointage DEC --- */
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
   /* --- --- */
   return 0;
}

int eqmod_hadec_goto(struct telprop *tel)
{
   char s[1024],ss[1024],axe,sens;
   int res;
   int retournement=0;
   int p,p0,dp;
   double v;
   double ha;
   /* --- Effectue le pointage HA --- */
   ha=tel->ra0+360*5;
   ha=fmod(ha,360.);
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
	if (p>fabs(360*tel->radec_position_conversion)/2) {
		// --- on passe au dela du meridien descendant (nord) ---*/
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
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,ss);
   /* --- Effectue le pointage DEC --- */
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
   /* --- --- */
   return 0;
}

int eqmod_initzenith(struct telprop *tel)
{
   return 0;
}

int eqmod_stopgoto(struct telprop *tel)
{
   char s[1024],axe;
   int res;
   /*--- Arret pointage */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='1';
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='2';
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   return 0;
}

int eqmod_stategoto(struct telprop *tel,int *state)
{
   return 0;
}

int eqmod_suivi_arret (struct telprop *tel)
{
   char s[1024],axe;
   int res;
   /*--- Arret pointage */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='1';
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='2';
   sprintf(s,":K%c",axe);
   res=eqmod_putread(tel,s,NULL);
   return 0;
}

int eqmod_suivi_marche (struct telprop *tel)
{
   /* ==== suivi sidéral ===*/
   char s[1024],ss[1024],axe;
   int res;
   double v;
   /*--- Track alpha */
   strcpy(s,":F1");
   res=eqmod_putread(tel,s,NULL);
   strcpy(s,":K1");
   res=eqmod_putread(tel,s,NULL);
   v=tel->speed_track_ra*tel->radec_speed_dec_conversion;
   axe='1';
	eqmod_encode(tel,(int)(v),ss);
   sprintf(s,":I%c%s",axe,ss);
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   if (tel->speed_track_ra>0) {
		sprintf(s,":G%c10",axe);
		res=eqmod_putread(tel,s,NULL);
   } else if (tel->speed_track_ra<0) {
		sprintf(s,":G%c11",axe);
		res=eqmod_putread(tel,s,NULL);
   }
   strcpy(s,":J1");
   res=eqmod_putread(tel,s,NULL);
   /*--- Track delta */
   strcpy(s,":F2");
   res=eqmod_putread(tel,s,NULL);
   strcpy(s,":K2");
   res=eqmod_putread(tel,s,NULL);
   v=tel->speed_track_dec*tel->radec_speed_dec_conversion;
   axe='2';
	eqmod_encode(tel,(int)(v),ss);
   sprintf(s,":I%c%s",axe,ss);
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   if (tel->speed_track_ra>0) {
		sprintf(s,":G%c10",axe);
		res=eqmod_putread(tel,s,NULL);
   } else if (tel->speed_track_ra<0) {
		sprintf(s,":G%c11",axe);
		res=eqmod_putread(tel,s,NULL);
   }
   strcpy(s,":J2");
   res=eqmod_putread(tel,s,NULL);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int eqmod_position_tube(struct telprop *tel,char *sens)
{
   return 0;
}

int eqmod_setderive(struct telprop *tel,int var, int vdec)
{
   return 0;
}

int eqmod_getderive(struct telprop *tel,int *var,int *vdec)
{
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
      sprintf(ligne,"mc_date2iso8601 now",function);
      Tcl_Eval(interp,ligne);
      strcpy(s,interp->result);
   }
}

