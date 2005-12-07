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
   {"Ouranos",    /* telescope name */
    "Ouranos",    /* protocol name */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
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
   char s[1024];
   char ss[256],ssusb[256],ssres[256];
   int k;
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
         /* if ttyS not found, we test ttyUSB */
         sprintf(ss,"open \"%s\" r+",ssusb);
         if (Tcl_Eval(tel->interp,ss)!=TCL_OK) {
            strcpy(tel->msg,tel->interp->result);
            return 1;
         }
      } else {
         strcpy(tel->msg,ssres);
         return 1;
      }
   }
   strcpy(tel->channel,tel->interp->result);
   /*
   # 9600 : vitesse de transmission (bauds)
   # 0 : 0 bit de parit�
   # 8 : 8 bits de donn�es
   # 1 : 1 bits de stop
   */
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -blocking 0",tel->channel); mytel_tcleval(tel,s);
   tel->tempo=100;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   tel->res_ra=32768;
   tel->res_dec=32768;
   tel->inv_ra=1;
   tel->inv_dec=1;
   ouranos_home(tel,"GPS 0 E 45 0");
   /* --- l'init stipule que :               */
   /*     le telescope est au meridien H=TSL */
   /*     et a la declinaison 0d             */
   /* --- lecture des codeurs en pas codeur  */
   tel->ha00=0.;
   tel->dec00=0.;
   ouranos_readcoder(tel,&tel->hai00,&tel->deci00);
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return ouranos_testcom(tel);
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   ouranos_delete(tel);
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
   ouranos_match(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   char s[1024];
   char coord0[50],coord1[50];
   tel_radec_coord(tel,coord0);
   sprintf(s,"after 350"); mytel_tcleval(tel,s);
   tel_radec_coord(tel,coord1);
   if (strcmp(coord0,coord1)==0) {strcpy(result,"tracking");}
   else {strcpy(result,"pointing");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   ouranos_coord(tel,result);
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
   /* se servir de tel->focus_move_rate qui varie de 0 a 1 */
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
   strcpy(result,"0");
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   ouranos_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->home);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   sprintf(tel->home,"GPS %f %s %f %f",longitude,ew,latitude,altitude);
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
   /*
   FILE *f;
   f=fopen("mouchard_ouranos.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   */
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   /*
   fprintf(f,"RESU <%s>\n",tel->interp->result);
   fclose(f);
   */
   return 0;
}


/* ================================================================ */
/* Ces fonctions etaient ecrites par en Tcl par Robert Delmas.      */
/* ================================================================ */

int ouranos_delete(struct telprop *tel)
{
   char s[1024];
   /* --- Fermeture du port com */
   sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage OURANOS -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int ouranos_home(struct telprop *tel, char *home_default)
{
   char s[1024];
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

double ouranos_tsl(struct telprop *tel)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   ouranos_home(tel,"");
   ouranos_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
   sprintf(s,"mc_date2lst %s {%s}",ss,tel->home);
   mytel_tcleval(tel,s);
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",tel->interp->result,tel->interp->result,tel->interp->result);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

int ouranos_readcoder(struct telprop *tel,int *ra, int *dec)
{
   char s[1024];
   char ss[1024];
   /* --- Demande les coordonnees */
   sprintf(s,"puts %s Q",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la chaine de resultat */
   sprintf(s,"gets %s",tel->channel); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   if (strcmp(ss,"")==0) {
      *ra=0;
      *dec=0;
      return 1;
   }
   /* --- decodage en pas codeurs */
   sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
   *ra=(int)atoi(tel->interp->result);
   sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
   *dec=(int)atoi(tel->interp->result);
   return 0;
}

int ouranos_testcom(struct telprop *tel)
{
   char s[1024];
   char ss[1024];
   /* --- Demande les coordonnees */
   sprintf(s,"puts %s Q",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la chaine de resultat */
   sprintf(s,"gets %s",tel->channel); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   if (strcmp(ss,"")==0) {
      return 0;
   }
   return 1;
}

int ouranos_coord(struct telprop *tel,char *result)
{
   char s[1024];
   double ha,ra,dec,tsl;
   int hai,deci;
   /* --- lecture des codeurs en pas codeur */
   ouranos_readcoder(tel,&hai,&deci);
   /* --- temps sideral local en deg*/
   tsl=ouranos_tsl(tel);
   /* --- angle horaire en degres ---*/
   ha=tel->ha00+360.*(hai-tel->hai00)/(double)tel->res_ra*tel->inv_ra;
   /* --- angle horaire en degres ---*/
   ra=tsl-ha;
   /* --- declinaison en degres ---*/
   dec=tel->dec00+360.*(deci-tel->deci00)/(double)tel->res_dec*tel->inv_dec;
   /* --- conversion vers la chaine finale */
   strcpy(result,"0h0m0s 0d0m0s");
   sprintf(s,"mc_angle2hms %f 360 nozero 2 auto string",ra); mytel_tcleval(tel,s);
   strcpy(result,tel->interp->result);
   strcat(result," ");
   sprintf(s,"mc_angle2dms %f 90 nozero 2 + string",dec); mytel_tcleval(tel,s);
   strcat(result,tel->interp->result);
   return 0;
}


int ouranos_match(struct telprop *tel)
{
   int rai,deci;
   double tsl;
   /* --- lecture des codeurs en pas codeur */
   ouranos_readcoder(tel,&rai,&deci);
   tel->hai00=rai;
   tel->deci00=deci;
   /* --- temps sideral local en deg*/
   tsl=ouranos_tsl(tel);
   tel->ha00=tsl-tel->ra0;
   tel->dec00=tel->dec0;
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
void ouranos_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
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
