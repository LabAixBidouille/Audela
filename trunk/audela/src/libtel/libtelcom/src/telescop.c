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
   {"TelCom",    /* telescope name */
    "TelCom",    /* protocol name */
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
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
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
   } else {
      strcpy(s,argv[2]);
      k=(int)strlen(s);
      k=1+(int)atoi(s+k-1);
   }
   tel->numport=k;
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
   # 0 : 0 bit de parité
   # 8 : 8 bits de données
   # 1 : 1 bits de stop
   */
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -blocking 0",tel->channel); mytel_tcleval(tel,s);
   tel->tempo=150;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   telcom_home(tel,"GPS 0 E 45 0");
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   int result=0;
   return result;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   telcom_delete(tel);
   return 0;
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return 0;
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

int mytel_radec_state(struct telprop *tel,char *result)
{
   strcpy(result,"tracking");
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   if (strcmp(direc,"N")==0) {
      sprintf(s,"combit %d 7 1",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 4 1",tel->numport); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"S")==0) {
      sprintf(s,"combit %d 7 1",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 3 1",tel->numport); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"E")==0) {
      sprintf(s,"combit %d 7 0",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 3 1",tel->numport); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"W")==0) {
      sprintf(s,"combit %d 7 0",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 4 1",tel->numport); mytel_tcleval(tel,s);
   }
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   if (strcmp(direc,"N")==0) {
      sprintf(s,"combit %d 4 0",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 7 0",tel->numport); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"S")==0) {
      sprintf(s,"combit %d 3 0",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 7 0",tel->numport); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"E")==0) {
      sprintf(s,"combit %d 3 0",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 7 0",tel->numport); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"W")==0) {
      sprintf(s,"combit %d 4 0",tel->numport); mytel_tcleval(tel,s);
      sprintf(s,"combit %d 7 0",tel->numport); mytel_tcleval(tel,s);
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
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
   telcom_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
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
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   return 0;
}

int telcom_delete(struct telprop *tel)
{
   char s[1024];
   /* --- Fermeture du port com */
   sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage TELCOM -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/


/************************************************************/

int telcom_settsl(struct telprop *tel)
{
   int h,m,sec;
   char s[1024];
   tel->tsl=telcom_tsl(tel,&h,&m,&sec);
   sprintf(s,"puts -nonewline %s \"#SS %02d:%02d:%02d#\"",tel->channel,h,m,sec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int telcom_setdate(struct telprop *tel)
{
   char s[1024];
   char ss[1024];
   telcom_GetCurrentFITSDate_function(tel->interp,s,"::audace::date_sys2ut");
   sprintf(s,"mc_date2ymdhms %s",tel->interp->result); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"format \"%%02d:%%02d:%%02d\" [lindex %s 3] [lindex %s 4] [lindex %s 5]",tel->interp->result,tel->interp->result,tel->interp->result); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"puts -nonewline %s \"#SU %s#\"",tel->channel,ss); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

double telcom_tsl(struct telprop *tel,int *h, int *m,int *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   telcom_home(tel,"");
   telcom_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
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

int telcom_home(struct telprop *tel, char *home_default)
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

void telcom_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
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

