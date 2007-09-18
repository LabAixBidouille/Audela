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
#include <libtel/util.h>

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"ETEL",    /* telescope name */
    "Etel",    /* protocol name */
    "etel",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};


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
   //char s[1024];
	int err;
   tel->drv=NULL;
	/* create drive */
	if (err = dsa_create_drive(&tel->drv)) {
		mytel_error(tel,err);
		return 1;
	}
	if (err = dsa_open_u(tel->drv, "etb:DSTEB3:0")) {
		mytel_error(tel,err);
		tel_close(tel);
		return 2;
	}
	/* Reset error */
	if (err = dsa_reset_error_s(tel->drv, 1000)) {
		mytel_error(tel,err);
		tel_close(tel);
		return 3;
	}
	/* power on */
	if (err = dsa_power_on_s(tel->drv, 10000)) {
		mytel_error(tel,err);
		tel_close(tel);
		return 4;
	}
   /* --- init home ---*/
   strcpy(tel->home,"GPS 2 E 48 100");
   strcpy(tel->home0,tel->home);
   /* --- type de monture ---*/
   tel->type_mount=MOUNT_EQUATORIAL;
   /* --- type des axes ---*/
   tel->axis_param[0].type=AXIS_HA;
   tel->axis_param[1].type=AXIS_NOTDEFINED; //AXIS_DEC;
   tel->axis_param[2].type=AXIS_NOTDEFINED;
   /* ---  Nombre de dents sur la roue dentee --- */
   tel->axis_param[0].teeth_per_turn=480;
   tel->axis_param[1].teeth_per_turn=480;
   tel->axis_param[2].teeth_per_turn=480;
	return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
    /* Is the drive pointer valid ? */
    if(dsa_is_valid_drive(tel->drv)) {
      return 1;
	} else {
      return 0;
	}
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
	int err;
	/* power off */
	if (err = dsa_power_off_s(tel->drv, 10000)) {
		//mytel_error(tel,err);
		//return 1;
	}
	/* close and destroy */
	if (err = dsa_close(tel->drv)) {
		//mytel_error(tel,err);
		//return 2;
	}
	if (err = dsa_destroy(&tel->drv)) {
		//mytel_error(tel,err);
		//return 3;
	}
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
   return 0;
}

int mytel_radec_init_additional(struct telprop *tel)
 {
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   double deg_per_tooth,angle;
   int traits,interpo,axisno,err,val;
   int uc_per_motorturn,h,m,sec;
   double motorturns,tsl,vit,nbmotorturnpersec;
   double facteur_vitesse;
   int posmax,posmin,pos1,vit1;
   char coord0[50],coord1[50],s[1024];
   int time_in=0,time_out=240;
   /* --- boucle sur les axes valides ---*/
   for (axisno=0;axisno<3;axisno++) {
      if (tel->axis_param[axisno].type==AXIS_NOTDEFINED) {
         continue;
      }
      // = butees
      posmin=0;
      posmax=(int)(pow(2,31));
      facteur_vitesse=10.;
      //= regle une vitesse de pointage
      vit=10.; //deg/s
      deg_per_tooth=360./tel->axis_param[axisno].teeth_per_turn; // teeth/360deg
      nbmotorturnpersec=vit/deg_per_tooth; // motorturn/s
      // = envoi la consigne de la vitesse du moteur
   	if (err = dsa_get_register_s(tel->drv,ETEL_M,239,axisno,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         traits=512;
      } else {
         traits=val;
      }
   	if (err = dsa_get_register_s(tel->drv,ETEL_M,241,axisno,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         interpo=1024;
      } else {
         interpo=val;
      }
      uc_per_motorturn=traits*interpo; // UC/motorturn or UC/tooth
      vit1=(int)(nbmotorturnpersec*uc_per_motorturn/facteur_vitesse); // UC/s
   	if (err = dsa_set_register_s(tel->drv,ETEL_K,211,axisno,vit1,DSA_DEF_TIMEOUT)) {
         return 1;
	   }
      // = decode les coordonnes
      if (tel->axis_param[axisno].type==AXIS_HA) {
         tsl=etel_tsl(tel,&h,&m,&sec);
         angle=tsl-tel->ra0;
         angle=tel->ra0; // verue pour test
      } else if (tel->axis_param[axisno].type==AXIS_DEC) {
         angle=tsl-tel->dec0;
      } else if (tel->axis_param[axisno].type==AXIS_AZ) {
         angle=0.; // a faire
      } else if (tel->axis_param[axisno].type==AXIS_ELEV) {
         angle=0.; // a faire
      } else if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
         angle=0.; // a faire
      }
      // = goto vers des coordonnes
      motorturns=angle/deg_per_tooth; // motorturn
      pos1=(int)(motorturns*uc_per_motorturn); // UC
      if ((pos1>=posmin)&&(pos1>posmax)) {
      	if (err = dsa_set_register_s(tel->drv,ETEL_K,210,axisno,pos1,DSA_DEF_TIMEOUT)) {
            return 1;
	      }
      }
   }
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      tel_radec_coord(tel,coord0);
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         tel_radec_coord(tel,coord1);
         if (strcmp(coord0,coord1)==0) {break;}
         strcpy(coord0,coord1);
	     if (time_in>=time_out) {break;}
      }
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
	/*
	int err;
   if (err = dsa_quick_stop_s(tel->drv, 10000)) {
	   mytel_error(tel,err);
		return 1;
	}
	*/
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
	int err;
   if (tel->radec_motor==1) {
      /* stop the motor */
		if (err = dsa_power_off_s(tel->drv, 10000)) {
			mytel_error(tel,err);
			return 1;
		}
   } else {
      /* start the motor */
		if (err = dsa_power_on_s(tel->drv, 10000)) {
			mytel_error(tel,err);
			return 1;
		}
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   double deg_per_tooth,angle,ra;
   int traits,interpo,axisno,err,val;
   int uc_per_motorturn,h,m,sec,pos;
   double motorturns,tsl;
   char angles[3][30],s[128];
   strcpy(result,"");
   /* --- lecture sur les axes valides ---*/
   for (axisno=0;axisno<3;axisno++) {
      strcpy(angles[axisno],"");
      if (tel->axis_param[axisno].type==AXIS_NOTDEFINED) {
         continue;
      }
      deg_per_tooth=360./tel->axis_param[axisno].teeth_per_turn; // teeth/360deg
   	if (err = dsa_get_register_s(tel->drv,ETEL_M,239,axisno,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         traits=512;
      } else {
         traits=val;
      }
   	if (err = dsa_get_register_s(tel->drv,ETEL_M,241,axisno,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         interpo=1024;
      } else {
         interpo=val;
      }
      uc_per_motorturn=traits*interpo; // UC/motorturn or UC/tooth
   	if (err = dsa_get_register_s(tel->drv,ETEL_M,7,axisno,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         pos=0;
      } else {
         pos=val;
      }
      motorturns=1.*pos/uc_per_motorturn; // motorturn
      angle=motorturns*deg_per_tooth; // deg
      if (tel->axis_param[axisno].type==AXIS_HA) {
         tsl=etel_tsl(tel,&h,&m,&sec);
         ra=tsl-angle;
         ra=angle; // verue pour test
         sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
         sprintf(angles[axisno],"%s ",tel->interp->result);
         continue;
      }
      if (tel->axis_param[axisno].type==AXIS_DEC) {
         sprintf(s,"mc_angle2dms \"%f\" 90 zero 1 + string",angle); mytel_tcleval(tel,s);
         sprintf(angles[axisno],"%s ",tel->interp->result);
         continue;
      }
      if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
         sprintf(s,"mc_angle2dms \"%f\" 360 zero 1 auto string",angle); mytel_tcleval(tel,s);
         sprintf(angles[axisno],"%s ",tel->interp->result);
         continue;
      }
   }
   if (tel->axis_param[0].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_HA) {
            strcat(result,angles[axisno]);
         }
      }
   }
   if (tel->axis_param[1].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_DEC) {
            strcat(result,angles[axisno]);
         }
      }
   } else {
      strcat(result," +00d00m00s");
   }
   if (tel->axis_param[2].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
            strcat(result,angles[axisno]);
         }
      }
   }
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
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   /* Get the longitude */
   strcpy(ligne,tel->home);
   strcpy(ligne,tel->home0);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   /* Set the longitude */
   sprintf(tel->home,"GPS %f %s %f %f",longitude,ew,latitude,altitude);
   strcpy(tel->home0,tel->home);
   return 0;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */


//#define MOUCHARD

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_ascom.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout)
{
   int len,k;
   char car;
   len=(int)strlen(strin);
   if (len==0) {
      strout[0]='\0';
      return;
   }
   for (k=0;k<len;k++) {
      car=strin[k];
      if (car==decin) {
         car=decout;
      }
      strout[k]=car;
   }
   strout[k]='\0';
}

void mytel_error(struct telprop *tel,int err)
{
   DSA_DRIVE *drv;
   drv=tel->drv;
   sprintf(tel->msg,"error %d: %s.\n", err, dsa_translate_error(err));
}

int etel_home(struct telprop *tel, char *home_default)
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

double etel_tsl(struct telprop *tel,int *h, int *m,int *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   etel_home(tel,"");
   etel_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
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
   *sec=(int)atoi(tel->interp->result);
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

void etel_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
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
	}
}

