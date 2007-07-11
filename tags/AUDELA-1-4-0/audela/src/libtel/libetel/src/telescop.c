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
#include "dsa20.h"
#include "etb10.h"

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
	DSA_DRIVE *drv = NULL;
	DSA_STATUS sta = {sizeof(DSA_STATUS)};
	long i, val;
	ETB_RTM_AXISMASK axis_mask;	/*Array of axismask for */
	ETB *etb = NULL;					/*each realtime channel*/

	/* create drive */
	if (err = dsa_create_drive(&drv)) {
		goto _error;
	}
	if (err = dsa_open_u(drv, "etb:DSTEB3:1")) {
		goto _error;
	}
	/* Reset error */
	if (err = dsa_reset_error_s(drv, 1000)) {
		goto _error;
	}
	return 0;

	/* Error handler. */
_error:
    /* Is the drive pointer valid ? */
    if(dsa_is_valid_drive(drv)) {

        /* Is the drive open ? */
        bool open = 0;
        dsa_is_open(drv, &open);
        if (open) {

            /* Close the connection. */
            dsa_close(drv);
        }

        /* And finally, release all resources to the OS. */
        dsa_destroy(&drv);
    }

    /* Print the first error that occured. */
    sprintf(tel->msg,"error %d: %s.\n", err, dsa_translate_error(err));
    return 1;

    /*
   strcpy(s,"set telcmd $::ascom_variable(1)"); mytel_tcleval(tel,s);
   if (Tcl_Eval(tel->interp,s)==TCL_OK) {
      tel->sDecimal=tel->interp->result[0];
   } else {
      tel->sDecimal='.';
   }
   strcpy(s,"$telcmd Tracking 1"); mytel_tcleval(tel,s);
   tel->rateunity=0.1;
   */
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
