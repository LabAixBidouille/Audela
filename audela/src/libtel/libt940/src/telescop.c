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
   {"T940",    /* telescope name */
    "Etel-T940",    /* protocol name */
    "t940",    /* product */
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
   char s[1024];

	int threadpb=0,k;

   Tcl_CreateCommand(tel->interp,"Thread940_Init", (Tcl_CmdProc *)Thread940_Init, (ClientData)NULL, NULL);
   if (Tcl_Eval(tel->interp, "thread::create { thread::wait } ") == TCL_OK) {
		//MessageBox(NULL,"Thread créé","LibT940",MB_OK);
		strcpy(tel->loopThreadId, tel->interp->result);
      sprintf(s,"thread::copycommand %s Thread940_Init ",tel->loopThreadId);
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,tel->interp->result);
			threadpb=2;
      }
      sprintf(s,"foreach mc_proc [info commands mc_*] { thread::copycommand %s $mc_proc }", tel->loopThreadId);
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,tel->interp->result);
			threadpb=3;
      }
		// --- Appel des initialisations qui fait demarrer la boucle 
		sprintf(s,"thread::send %s {Thread940_Init", tel->loopThreadId);
		for (k=0;k<argc;k++) {
			strcat(s," ");
			strcat(s,argv[k]);
		}
		strcat(s,"}");
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,tel->interp->result);
			threadpb=4;
      }
	} else {
		strcpy(tel->msg,tel->interp->result);
		threadpb=2;
	}
	return threadpb;
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

int mytel_radec_init(struct telprop *tel) {
	char s[200];
	sprintf(s,"::thread::send %s { CmdThread940_radec_init }",tel->loopThreadId);
	mytel_tcleval(tel,s);
	//MessageBox(NULL,tel->interp->result,"mytel_radec_init",MB_OK);

   return 0;
}

int mytel_hadec_init(struct telprop *tel) {
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
	char s[200];
	telthread->ra0=tel->ra0;
	telthread->dec0=tel->dec0;
	sprintf(s,"::thread::send %s { CmdThread940_radec_goto }",tel->loopThreadId);
	mytel_tcleval(tel,s);
   if (tel->radec_goto_blocking==1) {
		libtel_sleep(500);
		while (strcmp(telthread->action_cur,"goto")==0) {
			libtel_sleep(500);
		}
	}
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
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
   if (err = dsa_quick_stop_s(tel->drv[k], 10000)) {
	   mytel_error(tel,k,err);
		return 1;
	}
	*/
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   if (tel->radec_motor==1) {
      /* stop the motor */
		strcpy(telthread->action_next,"motor_off");
   } else {
      /* start the motor */
		strcpy(telthread->action_next,"motor_on");
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
	char s[200];
	sprintf(s,"::thread::send %s { CmdThread940_radec_coord }",tel->loopThreadId);
	mytel_tcleval(tel,s);
	sprintf(result,tel->interp->result);
	//MessageBox(NULL,result,"mytel_radec_coord",MB_OK);
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
	char s[1024];
	double ha,dec;
	if (telthread->status==STATUS_MOTOR_OFF) {
		ha=telthread->app_ha_stopped;
		dec=telthread->app_dec_stopped;
	} else {
		ha=telthread->app_ha;
		dec=telthread->app_dec;
	}
	sprintf(result,"%f %f",ha,dec);
	strcpy(result,s);
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


/*****************************************************************************************/
//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
// TOUTES LES COMMANDES CI-DESSOUS SONT EXECUTEES DANS LE CONTEXTE DU THREAD PERIODIQUE //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////
/*****************************************************************************************/

// Commande d'initialisation du thread (en particulier de la variable telthread)
// ::tel::create t940 -mode 0 -axis1 4 -axis2 5
int Thread940_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char s[1024];
	int err,kk;
	int axisno,kaxisno;
	double raJ2000,decJ2000,jdinit;
	int threadpb=0;
	int axis[3];

	telthread = (struct telprop*) calloc( 1, sizeof(struct telprop) );
	
	telthread->interp = interp;

	// decode les arguments
	telthread->mode = MODE_REEL;
	telthread->mode = 0;
   telthread->type_mount=MOUNT_ALTAZ;
	strcpy(telthread->alignmentMode,"ALTAZ");
	axis[0]=0;
	axis[1]=1; //4
	axis[2]=2; //5
	if (argc >= 1) {
		for (kk = 0; kk < argc-1; kk++) {
			// mode : 0=simulation 1=reel
			if (strcmp(argv[kk], "-mode") == 0) {
				telthread->mode = atoi(argv[kk + 1]);
			}
			// mount : altaz|equatorial
			if (strcmp(argv[kk], "-mount") == 0) {
				if (strcmp(argv[kk + 1],"equatorial")==0) {
					telthread->type_mount = MOUNT_EQUATORIAL;
					strcpy(telthread->alignmentMode,"HADEC");
				}
			}
         if (strcmp(argv[kk], "-axis0") == 0) {
            axis[0]=atoi(argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-axis1") == 0) {
            axis[1]=atoi(argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-axis2") == 0) {
            axis[2]=atoi(argv[kk + 1]);
         }
		}
	}
	
	// inhibe les corrections de "tel1 radec goto" par libtel
	mytel_tcleval(telthread, "proc t940_cat2tel { radec } { return $radec }");
	strcpy(telthread->model_cat2tel,"t940_cat2tel");
	mytel_tcleval(telthread, "proc t940_tel2cat { radec } { return $radec }");
	strcpy(telthread->model_tel2cat,"t940_tel2cat");

	// type des axes
	if (telthread->type_mount==MOUNT_EQUATORIAL) {
		telthread->nb_axis=2;
		telthread->axes[0]=AXIS_HA;
		telthread->axes[1]=AXIS_DEC;
	} else {
		telthread->nb_axis=3;
		telthread->axes[0]=AXIS_AZ;
		telthread->axes[1]=AXIS_ELEV;
		telthread->axes[2]=AXIS_PARALLACTIC;
	}
	for (axisno=0;axisno<5;axisno++) {
	   telthread->axis_param[axisno].type=AXIS_NOTDEFINED;
		telthread->drv[axisno]=NULL;
	}

	// boucle de creation des axes
	if (telthread->mode == MODE_REEL) {
		for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
			axisno=telthread->axes[kaxisno];
			// create drive
			if (err = dsa_create_drive(&telthread->drv[axisno])) {
				mytel_error(telthread,axisno,err);
				return 1;
			}
			sprintf(s,"etb:DSTEB3:%d",axis[kaxisno]);
			if (err = dsa_open_u(telthread->drv[axisno],s)) {
				if (kaxisno==0) {
					mytel_error(telthread,axisno,err);
					sprintf(s," {etb:DSTEB3:%d}",axis[kaxisno]);
					strcat(telthread->msg,s);
					tel_close(telthread);
					return 2;
				} else {
					break;
				}
			} else {
				if (telthread->type_mount == MOUNT_EQUATORIAL) {
					if (kaxisno==0) { telthread->axis_param[axisno].type = telthread->axes[0]; }
					if (kaxisno==1) { telthread->axis_param[axisno].type = telthread->axes[1]; }
				} else {
					if (kaxisno==0) { telthread->axis_param[axisno].type = telthread->axes[0]; }
					if (kaxisno==1) { telthread->axis_param[axisno].type = telthread->axes[1]; }
					if (kaxisno==2) { telthread->axis_param[axisno].type = telthread->axes[2]; }
				}
			}
			// Reset error
			if (err = dsa_reset_error_s(telthread->drv[axisno], 1000)) {
				mytel_error(telthread,axisno,err);
				tel_close(telthread);
				return 3;
			}
			// power on
			if (err = dsa_power_on_s(telthread->drv[axisno], 10000)) {
				mytel_error(telthread,axisno,err);
				tel_close(telthread);
				return 4;
			}
		}
	} else {
		if (telthread->type_mount == MOUNT_EQUATORIAL) {
			telthread->axis_param[0].type = telthread->axes[0];
			telthread->axis_param[1].type = telthread->axes[1];
		} else {
			telthread->axis_param[0].type = telthread->axes[0];
			telthread->axis_param[1].type = telthread->axes[1];
			telthread->axis_param[2].type = telthread->axes[2];
		}
	}
	// extradrift = rattrapage additionnel (arcsec/sec) au suivi diurne
	strcpy(telthread->extradrift_type,"altaz");
	telthread->extradrift_axis0=0;
	telthread->extradrift_axis1=0;
	// init home
	strcpy(telthread->home,"GPS 1.7187 E 43.8740 220");
	strcpy(telthread->home0,telthread->home);
	strcpy(telthread->homePosition,telthread->home);
	if (mytel_loadparams(telthread,-1) == 1) {
		return 1;
	}
	if (telthread->type_mount == MOUNT_ALTAZ) {
		jdinit = (telthread->axis_param[AXIS_AZ].jdinit+telthread->axis_param[AXIS_ELEV].jdinit)/2.;
		mytel_tel2cat(telthread,jdinit,telthread->axis_param[AXIS_AZ].angleinit,telthread->axis_param[AXIS_ELEV].angleinit,&raJ2000,&decJ2000);
	} else {
		jdinit = (telthread->axis_param[AXIS_HA].jdinit+telthread->axis_param[AXIS_DEC].jdinit)/2.;
		mytel_tel2cat(telthread,jdinit,telthread->axis_param[AXIS_HA].angleinit,telthread->axis_param[AXIS_DEC].angleinit,&raJ2000,&decJ2000);
	}
	mytel_cat2tel(telthread,jdinit,raJ2000,decJ2000);
	mytel_coord_stopped(telthread);
	telthread->last_goto_raJ2000 = raJ2000;
	telthread->last_goto_decJ2000 = decJ2000;
	strcpy(telthread->action_prev, "");
	strcpy(telthread->action_next, "motor_off");
	strcpy(telthread->action_cur, "undefined");
	telthread->status = STATUS_MOTOR_OFF;
	telthread->compteur = 0;

	// Initialisation des commandes effectuees a la volee.
	Tcl_CreateCommand(telthread->interp,"CmdThread940_radec_init", (Tcl_CmdProc *)CmdThread940_radec_init, (ClientData)telthread, NULL);
	Tcl_CreateCommand(telthread->interp,"CmdThread940_radec_coord", (Tcl_CmdProc *)CmdThread940_radec_coord, (ClientData)telthread, NULL);
	Tcl_CreateCommand(telthread->interp,"CmdThread940_radec_goto", (Tcl_CmdProc *)CmdThread940_radec_goto, (ClientData)telthread, NULL);
	Tcl_CreateCommand(telthread->interp,"CmdThread940_appcoord", (Tcl_CmdProc *)CmdThread940_appcoord, (ClientData)telthread, NULL);

	// initialisation des commandes tcl necessaires au fonctionnement en boucle.
	Tcl_CreateCommand(telthread->interp,"Thread940_loop", (Tcl_CmdProc *)Thread940_loop, (ClientData)telthread, NULL);
	mytel_tcleval(telthread,"proc T940_Loop {} { Thread940_loop ; after 250 T940_Loop }");

	// Lance le fonctionnement en boucle.
	mytel_tcleval(telthread,"T940_Loop");
	
	return 0;
}

/************************/
/*** Boucle du thread ***/
/************************/
int Thread940_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	int action_ok=0,err,axisno,kaxisno,val,valplus,seqno;
	double jdnow,jdinit;
	double raJ2000,decJ2000;
	char s[1024];

	telthread->compteur++;
	telthread->error=0;
	action_ok=1;
   if (strcmp(telthread->action_next,"motor_off")==0) {
		/*****************/
	   /*** motor_off ***/
		/*****************/
		if (telthread->status!=STATUS_MOTOR_OFF) {
		   strcpy(telthread->action_cur,telthread->action_next);
			mytel_coord_stopped(telthread);
			if (telthread->mode==MODE_REEL) {
				val=0;
				for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
					axisno=telthread->axes[kaxisno];
					if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,(int)val)) { mytel_error(telthread,axisno,err); }
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,72)) { mytel_error(telthread,axisno,err); }
				}
			}
		}
		telthread->status=STATUS_MOTOR_OFF;
		strcpy(telthread->extradrift_type,"altaz");
		telthread->extradrift_axis0=0;
		telthread->extradrift_axis1=0;
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		if (telthread->type_mount==MOUNT_ALTAZ) {
			mytel_tel2cat(telthread,jdnow,telthread->app_az_stopped,telthread->app_elev_stopped,&raJ2000,&decJ2000);
		} else {
			mytel_tel2cat(telthread,jdnow,telthread->app_ha_stopped,telthread->app_dec_stopped,&raJ2000,&decJ2000);
		}
		telthread->last_goto_raJ2000=raJ2000;
		telthread->last_goto_decJ2000=decJ2000;
		mytel_cat2tel(telthread,jdnow,raJ2000,decJ2000);
	} else if (strcmp(telthread->action_next,"move_n")==0) {
		/**************/
	   /*** move_n ***/
		/**************/
		strcpy(telthread->action_cur,telthread->action_next);
		// --- TODO n'actionner la fonction que si elle n'a pas encore été lancée
		if (telthread->mode==MODE_REEL) {
			if (telthread->type_mount==MOUNT_ALTAZ) {
				axisno=AXIS_ELEV;
			} else {
				axisno=AXIS_DEC;
			}
			seqno=79; if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
			seqno=76; if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
		}
	} else if (strcmp(telthread->action_next,"move_n_stop")==0) {
		/*******************/
	   /*** move_n_stop ***/
		/*******************/
		strcpy(telthread->action_cur,telthread->action_next);
		if (telthread->mode==MODE_REEL) {
			if (telthread->type_mount==MOUNT_ALTAZ) {
				axisno=AXIS_ELEV;
			} else {
				axisno=AXIS_DEC;
			}
			seqno=79; if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
		}
	} else if (strcmp(telthread->action_next,"motor_on")==0) {
		/****************/
	   /*** motor_on ***/
		/****************/
		strcpy(telthread->action_cur,telthread->action_next);
		if (telthread->type_mount==MOUNT_ALTAZ) {
			jdinit=(telthread->axis_param[AXIS_AZ].jdinit+telthread->axis_param[AXIS_ELEV].jdinit)/2.;
		} else {
			jdinit=(telthread->axis_param[AXIS_HA].jdinit+telthread->axis_param[AXIS_DEC].jdinit)/2.;
		}
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		raJ2000=telthread->last_goto_raJ2000;
		decJ2000=telthread->last_goto_decJ2000;
		telthread->status=STATUS_MOTOR_ON;
		mytel_cat2tel(telthread,jdnow,raJ2000,decJ2000); // calcul des vitesses instantannees
		if (telthread->mode==MODE_REEL) {
			if (telthread->type_mount==MOUNT_ALTAZ) {
				val=(int)telthread->app_drift_az_adu; axisno=AXIS_AZ;
				valplus=(int)fabs(val);
				if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,valplus)) { mytel_error(telthread,axisno,err); }
				if (val>=0) { seqno = 72; } else { seqno = 71; }
				if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
				val=(int)telthread->app_drift_elev_adu; axisno=AXIS_ELEV;
				if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
				if (val>=0) { seqno = 72; } else { seqno = 71; }
				if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
				val=(int)telthread->app_drift_rot_adu; axisno=AXIS_PARALLACTIC;
				if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
				if (val>=0) { seqno = 72; } else { seqno = 71; }
				if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
			} else {
				val=(int)telthread->app_drift_ha_adu; axisno=AXIS_HA;
				if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
				if (val>=0) { seqno = 72; } else { seqno = 71; }
				if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
				val=(int)telthread->app_drift_dec_adu; axisno=AXIS_DEC;
				if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
				if (val>=0) { seqno = 72; } else { seqno = 71; }
				if (err=mytel_execute_command(telthread,axisno,26,1,0,0,seqno)) { mytel_error(telthread,axisno,err); }
			}
		}
		// --- on arrete les moteurs en cas de depassement des limites ---
		mytel_limites();
		strcpy(telthread->action_prev,telthread->action_next);
		if (((int)fabs(telthread->axis_param[AXIS_AZ].angleovered)==2)||((int)fabs(telthread->axis_param[AXIS_PARALLACTIC].angleovered)==2)||((int)fabs(telthread->axis_param[AXIS_HA].angleovered)==2)) {
			strcpy(telthread->action_next,"motor_off");
		}
	} else {
		action_ok=0;
	}
	if (action_ok==1) {
		strcpy(telthread->action_prev,telthread->action_next);
		strcpy(telthread->action_cur,telthread->action_next);
	}
	return TCL_OK;
}

/******************
 *** radec init ***
 ******************/
int CmdThread940_radec_init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[200];	
	double jdnow,jdnow1,jdnow2;
	double raJ2000,decJ2000;
	int axisno,kaxisno;
	int status0,val,err;

	//MessageBox(NULL,"Entree dans la fonction","Radec init",MB_OK);
	
		/************/
	   /*** init ***/
		/************/
		status0=telthread->status;
		
		// --- Date actuelle
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		jdnow1=jdnow2=jdnow;
		
		// --- on stope les moteurs + index au milieu
		for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
			axisno=telthread->axes[kaxisno];
			if (telthread->mode==MODE_REEL) {
				// CMD 26 1 {0 0 77} : arret moteur + index au milieu
				if (err=mytel_execute_command(telthread,axisno,26,1,0,0,77)) { mytel_error(telthread,axisno,err); }
				// M7.0 position au milieu du codeur
				if (err=mytel_get_register(telthread,axisno,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
			} else {
				val=(int)pow(2,30);
			}
			telthread->axis_param[axisno].posinit=val; 
		}
		raJ2000=telthread->ra0;
		decJ2000=telthread->dec0;
		mytel_cat2tel(telthread,jdnow1,raJ2000,decJ2000);
		telthread->axis_param[AXIS_HA].angleinit=telthread->app_ha;
		telthread->axis_param[AXIS_DEC].angleinit=telthread->app_dec;
		telthread->axis_param[AXIS_AZ].angleinit=telthread->app_az;
		telthread->axis_param[AXIS_ELEV].angleinit=telthread->app_elev;
		telthread->axis_param[AXIS_PARALLACTIC].angleinit=telthread->app_rot;
		mytel_coord_stopped(telthread);
		telthread->last_goto_raJ2000=raJ2000;
		telthread->last_goto_decJ2000=decJ2000;
		
		// --- status a jour
		telthread->status=status0;
	
	return TCL_OK;
}

/*******************
 *** radec coord ***
 *******************/
int CmdThread940_radec_coord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[200];	
	double jdnow;
	double raJ2000,decJ2000;

	//MessageBox(NULL,"Entree dans la fonction","Radec coord",MB_OK);

	sprintf(s,"mc_date2jd now"); 	mytel_tcleval(telthread,s);
	//MessageBox(NULL,telthread->interp->result,"CmdThread940_radec_coord: [mc_date2jd now]",MB_OK);	
	jdnow=atof(telthread->interp->result);
	if (telthread->status==STATUS_MOTOR_OFF) {
		if (telthread->type_mount==MOUNT_ALTAZ) {
			mytel_tel2cat(telthread,jdnow,telthread->app_az_stopped,telthread->app_elev_stopped,&raJ2000,&decJ2000);
		} else {
			mytel_tel2cat(telthread,jdnow,telthread->app_ha_stopped,telthread->app_dec_stopped,&raJ2000,&decJ2000);
		}
	} else {
		if (telthread->type_mount==MOUNT_ALTAZ) {
			mytel_tel2cat(telthread,jdnow,telthread->app_az,telthread->app_elev,&raJ2000,&decJ2000);
		} else {
			mytel_tel2cat(telthread,jdnow,telthread->app_ha,telthread->app_dec,&raJ2000,&decJ2000);
		}
	}
	telthread->coord_raJ2000=raJ2000;
	telthread->coord_decJ2000=decJ2000;

	sprintf(s,"%f %f",telthread->coord_raJ2000,telthread->coord_decJ2000);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	
	return TCL_OK;
}

/******************
 *** radec goto ***
 ******************/
int CmdThread940_radec_goto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	int action_ok=0,err,axisno,kaxisno,kgoto,status0,val;
	double jdnow,jdnow1,jdnow2;
	double raJ2000,decJ2000;
	struct telprop telbefore,telafter;
	char s[1024];
	double daz,delev,drot,dha,ddec;
	double az1,elev1,rot1,ha1,dec1;
	double az2,elev2,rot2,ha2,dec2;
	double az,elev,rot,ha,dec;

	//MessageBox(NULL,"Entree dans la fonction","Radec goto",MB_OK);
	
		/************/
	   /*** goto ***/
		/************/
		status0=telthread->status;
	   strcpy(telthread->action_cur,"radec_goto");
		// --- Date actuelle
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		jdnow1=jdnow2=jdnow;
		// --- Arret des moteurs, index au milieu et angles init
		for (kgoto=1;kgoto<=2;kgoto++) {
			// --- on recupere les positions celestes juste avant d'arreter les moteurs
			raJ2000=telthread->last_goto_raJ2000;
			decJ2000=telthread->last_goto_decJ2000;
			mytel_cat2tel(telthread,jdnow1,raJ2000,decJ2000);
			telthread->axis_param[AXIS_HA].angleinit=telthread->app_ha;
			telthread->axis_param[AXIS_DEC].angleinit=telthread->app_dec;
			telthread->axis_param[AXIS_AZ].angleinit=telthread->app_az;
			telthread->axis_param[AXIS_ELEV].angleinit=telthread->app_elev;
			telthread->axis_param[AXIS_PARALLACTIC].angleinit=telthread->app_rot;
			// --- on stope les moteurs + index au milieu
			for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
				axisno=telthread->axes[kaxisno];
				if (telthread->mode==MODE_REEL) {
					// CMD 26 1 {0 0 77} : arret moteur + index au milieu
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,77)) { mytel_error(telthread,axisno,err); }
					// M7.0 position au milieu du codeur
					if (err=mytel_get_register(telthread,axisno,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
				} else {
					val=(int)pow(2,30);
				}
				telthread->axis_param[axisno].posinit=val; 
			}
			// --- position actuelle
			raJ2000=telthread->last_goto_raJ2000;
			decJ2000=telthread->last_goto_decJ2000;
			mytel_cat2tel(telthread,jdnow1,raJ2000,decJ2000);
			// --- stocke la position actuelle dans telbefore
			telbefore=*telthread;
			// --- position a ralier
			raJ2000=telthread->ra0;
			decJ2000=telthread->dec0;
			mytel_cat2tel(telthread,jdnow2,raJ2000,decJ2000);
			// --- stocke la position a ralier dans telafter
			telafter=*telthread;
			// --- corrections de turnback
			if (telthread->axis_param[AXIS_AZ].angleovered==0) {
				if (telbefore.app_az>telthread->axis_param[AXIS_AZ].angleturnback) { telbefore.app_az-=360; }
			} else if (telthread->axis_param[AXIS_AZ].angleovered<0) {
				telbefore.app_az-=360;
			}
			if (telthread->axis_param[AXIS_PARALLACTIC].angleovered==0) {
				if (telbefore.app_rot>telthread->axis_param[AXIS_PARALLACTIC].angleturnback) { telbefore.app_rot-=360; }
			} else if (telthread->axis_param[AXIS_AZ].angleovered<0) {
				telbefore.app_rot-=360;
			}
			if (telthread->axis_param[AXIS_HA].angleovered==0) {
				if (telbefore.app_ha>telthread->axis_param[AXIS_HA].angleturnback) { telbefore.app_ha-=360; }
			} else if (telthread->axis_param[AXIS_AZ].angleovered<0) {
				telbefore.app_ha-=360;
			}
			if (telafter.app_az>telthread->axis_param[AXIS_AZ].angleturnback) { telafter.app_az-=360; }
			if (telafter.app_rot>telthread->axis_param[AXIS_PARALLACTIC].angleturnback) { telafter.app_rot-=360; }
			if (telafter.app_ha>telthread->axis_param[AXIS_HA].angleturnback) { telafter.app_ha-=360; }
			// --- chemins a parcourir
			daz=telafter.app_az-telbefore.app_az;
			delev=telafter.app_elev-telbefore.app_elev;
			drot=telafter.app_rot-telbefore.app_rot;
			dha=telafter.app_ha-telbefore.app_ha;
			ddec=telafter.app_dec-telbefore.app_dec;
			// --- ADU de depart
			az1=telthread->axis_param[AXIS_AZ].posinit;
			elev1=telthread->axis_param[AXIS_ELEV].posinit;
			rot1=telthread->axis_param[AXIS_PARALLACTIC].posinit;
			ha1=telthread->axis_param[AXIS_HA].posinit;
			dec1=telthread->axis_param[AXIS_DEC].posinit;
			// --- ADU d'arrivee
			if (daz<0) {
				az2=az1+daz*telthread->axis_param[AXIS_AZ].coef_xsm;
			} else {
				az2=az1+daz*telthread->axis_param[AXIS_AZ].coef_xsp;
			}
			if (daz<0) {
				elev2=elev1+delev*telthread->axis_param[AXIS_ELEV].coef_xsm;
			} else {
				elev2=elev1+delev*telthread->axis_param[AXIS_ELEV].coef_xsp;
			}
			if (drot<0) {
				rot2=rot1+drot*telthread->axis_param[AXIS_PARALLACTIC].coef_xsm;
			} else {
				rot2=rot1+drot*telthread->axis_param[AXIS_PARALLACTIC].coef_xsp;
			}
			if (dha<0) {
				ha2=ha1+dha*telthread->axis_param[AXIS_HA].coef_xsm;
			} else {
				ha2=ha1+dha*telthread->axis_param[AXIS_HA].coef_xsp;
			}
			if (ddec<0) {
				dec2=dec1+ddec*telthread->axis_param[AXIS_DEC].coef_xs;
			} else {
				dec2=dec1+ddec*telthread->axis_param[AXIS_DEC].coef_xs;
			}
			// --- lance le GOTO
			if (telthread->mode==MODE_REEL) {
				if (telthread->type_mount==MOUNT_ALTAZ) {
					val=(int)az2; axisno=AXIS_AZ;
					if (err=mytel_set_register(telthread,axisno,ETEL_X,21,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,73)) { mytel_error(telthread,axisno,err); }
					val=(int)elev2; axisno=AXIS_ELEV;
					if (err=mytel_set_register(telthread,axisno,ETEL_X,21,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,73)) { mytel_error(telthread,axisno,err); }
					val=(int)rot2; axisno=AXIS_PARALLACTIC;
					/*
					if (err=mytel_set_register(telthread,axisno,ETEL_X,21,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,73)) { mytel_error(telthread,axisno,err); }
					*/
				} else {
					val=(int)ha2; axisno=AXIS_HA;
					if (err=mytel_set_register(telthread,axisno,ETEL_X,21,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,73)) { mytel_error(telthread,axisno,err); }
					val=(int)dec2; axisno=AXIS_DEC;
					if (err=mytel_set_register(telthread,axisno,ETEL_X,21,0,(int)fabs(val))) { mytel_error(telthread,axisno,err); }
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,73)) { mytel_error(telthread,axisno,err); }
				}
			}
			// --- attente
			if (telthread->mode==MODE_REEL) {
				while (1==1) {
					if (telthread->type_mount==MOUNT_ALTAZ) {
						if (err=mytel_get_register(telthread,AXIS_AZ,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); break;}
						az=(double)val;
						if (err=mytel_get_register(telthread,AXIS_ELEV,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); break;}
						elev=(double)val;
						if (err=mytel_get_register(telthread,AXIS_PARALLACTIC,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); break;}
						rot=(double)val;
						daz=az-az2;
						delev=elev-elev2;
						drot=rot-rot2;
						if ((fabs(daz)<2000)&&(fabs(delev)<2000)) {
							break;
						}
					} else {
						if (err=mytel_get_register(telthread,AXIS_HA,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); break;}
						ha=(double)val;
						if (err=mytel_get_register(telthread,AXIS_DEC,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); break;}
						dec=(double)val;
						dha=ha-ha2;
						ddec=dec-dec2;
						if ((fabs(dha)<2000)&&(fabs(ddec)<2000)) {
							break;
						}
					}
				}
				for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
					axisno=telthread->axes[kaxisno];
					if (err=mytel_execute_command(telthread,axisno,26,1,0,0,79)) { mytel_error(telthread,axisno,err); }
				}
			} else {
				if (kgoto==1) { libtel_sleep(5000); } else { libtel_sleep(1000); } 
			}
			sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
			jdnow=atof(telthread->interp->result);
			// --- Dates pour le second pointage 
			jdnow1=jdnow2;
			jdnow2=jdnow+1./86400;
			// --- Coordonnees pour le second pointage 
			telthread->last_goto_raJ2000=telthread->ra0;
			telthread->last_goto_decJ2000=telthread->dec0;
		}
		// --- met à jour les variables de coordonnes 
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		mytel_cat2tel(telthread,jdnow,raJ2000,decJ2000);
		mytel_coord_stopped(telthread);
		telthread->last_goto_raJ2000=raJ2000;
		telthread->last_goto_decJ2000=decJ2000;
		telthread->axis_param[AXIS_AZ].angleovered=0;
		telthread->axis_param[AXIS_PARALLACTIC].angleovered=0;
		telthread->axis_param[AXIS_HA].angleovered=0;
		// --- status a jour
		telthread->status=status0;
		if (telthread->status==STATUS_MOTOR_OFF) {
			strcpy(telthread->action_next,"motor_off");
		} else {
			strcpy(telthread->action_next,"motor_on");
		}
	
	return TCL_OK;
}

/******************
 *** appcoord ***
 ******************/
int CmdThread940_appcoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[1024],ligne[1024];
	strcpy(ligne,"mc_date2iso8601 now");
	mytel_tcleval(telthread,ligne);
	strcpy(s,"");
	sprintf(ligne,"%s {%f %f J2000} ",telthread->interp->result,telthread->last_goto_raJ2000,telthread->last_goto_decJ2000);
	strcat(s,ligne);
	sprintf(ligne,"{%f %f %f %f %f %f} ",telthread->app_ra,telthread->app_dec,telthread->app_ha,telthread->app_az,telthread->app_elev,telthread->app_rot);
	strcat(s,ligne);
	sprintf(ligne,"{%f %f %f %f %f %f} ",telthread->app_drift_ra,telthread->app_drift_dec,telthread->app_drift_ha,telthread->app_drift_az,telthread->app_drift_elev,telthread->app_drift_rot);
	strcat(s,ligne);
	sprintf(ligne,"{%f %f %f %f %f %f} ",telthread->app_ra_adu,telthread->app_dec_adu,telthread->app_ha_adu,telthread->app_az_adu,telthread->app_elev_adu,telthread->app_rot_adu);
	strcat(s,ligne);
	sprintf(ligne,"{%f %f %f %f %f %f} ",telthread->app_drift_ra_adu,telthread->app_drift_dec_adu,telthread->app_drift_ha_adu,telthread->app_drift_az_adu,telthread->app_drift_elev_adu,telthread->app_drift_rot_adu);
	strcat(s,ligne);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}





int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
    /* Is the drive pointer valid ? */
	if (tel->mode==MODE_REEL) {
		 if(dsa_is_valid_drive(tel->drv)) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 1;
	}
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
	char s[1024];
	int k,err;
	if (tel->mode==MODE_REEL) {
		/* --- boucle sur les axes ---*/
		for (k=0;k<tel->nb_axis;k++) {
			if (tel->axis_param[k].type==AXIS_NOTDEFINED) {
				continue;
			}
			/* power off */
			if (err = dsa_power_off_s(tel->drv[k], 10000)) {
				//mytel_error(tel,k,err);
				//return 1;
			}
			/* close and destroy */
			if (err = dsa_close(tel->drv[k])) {
				//mytel_error(tel,k,err);
				//return 2;
			}
			if (err = dsa_destroy(&tel->drv[k])) {
				//mytel_error(tel,k,err);
				//return 3;
			}
		}
	}
	free(telthread);
   sprintf(s,"thread::release %s ",tel->loopThreadId);
   Tcl_Eval(tel->interp, s);
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

void mytel_error(struct telprop *tel,int axisno, int err)
{
   DSA_DRIVE *drv;
   drv=tel->drv[axisno];
   sprintf(tel->msg,"error %d: %s.\n", err, dsa_translate_error(err));
}

int mytel_get_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int *val) {
	int err;
	err = dsa_get_register_s(tel->drv[axisno],typ,idx,sidx,val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT);
	return err;
}

int mytel_set_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int val) {
	int err;
	err = dsa_set_register_s(tel->drv[axisno],typ,idx,sidx,val,DSA_DEF_TIMEOUT);
	return err;
}

int mytel_execute_command(struct telprop *tel,int axisno,int cmd,int nparams,int typ,int conv,double val) {
	int err;
	DSA_COMMAND_PARAM params[] = { {0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0} };
	params[0].typ=typ;
	params[0].conv=conv;
	if (params[0].conv==0) {
		params[0].val.i=(int)(val);
	} else {
		params[0].val.d=val;
	}
	err = dsa_execute_command_x_s(tel->drv[axisno],cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT);
	return err;
}

void mytel_tel2cat(struct telprop *tel, double jd, double coord1, double coord2, double *raJ2000, double *decJ2000) {
   char s[1024],ss[1024];
   // j'applique le modèle de pointage inverse , pas de changement d'equinoxe a faire (modele seulement)
   // usage: mc_tel2cat {12h 36d} EQUATORIAL 2010-06-03T20:10:00 {GPS 5 E 43 1230} 101325 290 { symbols } { values }
   // ATTENTION : si on utilise utDate="now" , il faut d'abord mettre l'ordinateur a l'heure TU
   sprintf(s,"mc_tel2cat {%.6f %.6f} {%s} {%f} {%s} %d %d {%s} {%s}",coord1,coord2, tel->alignmentMode, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
	mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
	*raJ2000=atof(tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
	*decJ2000=atof(tel->interp->result);
}

void mytel_cat2tel(struct telprop *tel, double jd, double raJ2000, double decJ2000) {
   char s[1024],ss[1024];
	double coef,delta;
	coef=15.0410686;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s} -drift %s -driftvalues {%f %f}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients,tel->extradrift_type,tel->extradrift_axis0,tel->extradrift_axis1);
	mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	tel->jdcalcul=jd;
	// --- deg
	sprintf(s,"string trim [lindex {%s} 10]",ss); mytel_tcleval(tel,s);
	tel->app_ra=atof(tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 11]",ss); mytel_tcleval(tel,s);
	tel->app_dec=atof(tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 12]",ss); mytel_tcleval(tel,s);
	tel->app_ha=atof(tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 13]",ss); mytel_tcleval(tel,s);
	tel->app_az=atof(tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 14]",ss); mytel_tcleval(tel,s);
	tel->app_elev=atof(tel->interp->result);
	sprintf(s,"string trim [lindex {%s} 15]",ss); mytel_tcleval(tel,s);
	tel->app_rot=atof(tel->interp->result);
	// --- arcsec/sec
	if (tel->status==STATUS_MOTOR_OFF) {
		tel->app_drift_ra=coef;
		tel->app_drift_dec=0;
		tel->app_drift_ha=0;
		tel->app_drift_az=0;
		tel->app_drift_elev=0;
		tel->app_drift_rot=0;
	} else {
		sprintf(s,"string trim [lindex {%s} 16]",ss); mytel_tcleval(tel,s);
		tel->app_drift_ra=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 17]",ss); mytel_tcleval(tel,s);
		tel->app_drift_dec=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 18]",ss); mytel_tcleval(tel,s);
		tel->app_drift_ha=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 19]",ss); mytel_tcleval(tel,s);
		tel->app_drift_az=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 20]",ss); mytel_tcleval(tel,s);
		tel->app_drift_elev=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 21]",ss); mytel_tcleval(tel,s);
		tel->app_drift_rot=atof(tel->interp->result);
	}
	// --- deg => UC
	if (tel->type_mount==MOUNT_ALTAZ) {
		tel->app_ra_adu=0;
		tel->app_ha_adu=0;
		tel->app_dec_adu=0;
		delta=tel->app_az-tel->axis_param[AXIS_AZ].angleinit;
		if (delta>0) {
			tel->app_az_adu=tel->axis_param[AXIS_AZ].posinit+delta*tel->axis_param[AXIS_AZ].coef_xsp;
		} else {
			tel->app_az_adu=tel->axis_param[AXIS_AZ].posinit+delta*tel->axis_param[AXIS_AZ].coef_xsm;
		}
		delta=tel->app_elev-tel->axis_param[AXIS_ELEV].angleinit;
		if (delta>0) {
			tel->app_elev_adu=tel->axis_param[AXIS_ELEV].posinit+delta*tel->axis_param[AXIS_ELEV].coef_xsp;
		} else {
			tel->app_elev_adu=tel->axis_param[AXIS_ELEV].posinit+delta*tel->axis_param[AXIS_ELEV].coef_xsm;
		}
		delta=tel->app_rot-tel->axis_param[AXIS_PARALLACTIC].angleinit;
		if (delta>0) {
			tel->app_rot_adu=tel->axis_param[AXIS_PARALLACTIC].posinit+delta*tel->axis_param[AXIS_PARALLACTIC].coef_xsp;
		} else {
			tel->app_rot_adu=tel->axis_param[AXIS_PARALLACTIC].posinit+delta*tel->axis_param[AXIS_PARALLACTIC].coef_xsm;
		}
	} else {
		tel->app_ra_adu=0;
		delta=tel->app_ha-tel->axis_param[AXIS_HA].angleinit;
		if (delta>0) {
			tel->app_ha_adu=tel->axis_param[AXIS_HA].posinit+delta*tel->axis_param[AXIS_HA].coef_xsp;
		} else {
			tel->app_ha_adu=tel->axis_param[AXIS_HA].posinit+delta*tel->axis_param[AXIS_HA].coef_xsm;
		}
		delta=tel->app_dec-tel->axis_param[AXIS_DEC].angleinit;
		if (delta>0) {
			tel->app_dec_adu=tel->axis_param[AXIS_DEC].posinit+delta*tel->axis_param[AXIS_DEC].coef_xsp;
		} else {
			tel->app_dec_adu=tel->axis_param[AXIS_DEC].posinit+delta*tel->axis_param[AXIS_DEC].coef_xsm;
		}
		tel->app_az_adu=0;
		tel->app_elev_adu=0;
		tel->app_rot_adu=0;
	}
	// --- arcsec/sec => UC
	if (tel->type_mount==MOUNT_ALTAZ) {
		tel->app_drift_ra_adu=0;
		tel->app_drift_ha_adu=0;
		tel->app_drift_dec_adu=0;
		if (tel->app_drift_az>0) {
			tel->app_drift_az_adu=-tel->app_drift_az/coef*tel->axis_param[AXIS_AZ].coef_vsp/1000;
		} else {
			tel->app_drift_az_adu=-tel->app_drift_az/coef*tel->axis_param[AXIS_AZ].coef_vsm/1000;
		}
		if (tel->app_drift_elev>0) {
			tel->app_drift_elev_adu=-tel->app_drift_elev/coef*tel->axis_param[AXIS_ELEV].coef_vsp/1000;
		} else {
			tel->app_drift_elev_adu=-tel->app_drift_elev/coef*tel->axis_param[AXIS_ELEV].coef_vsm/1000;
		}
		if (tel->app_drift_rot>0) {
			tel->app_drift_rot_adu=-tel->app_drift_rot/coef*tel->axis_param[AXIS_PARALLACTIC].coef_vsp/1000;
		} else {
			tel->app_drift_rot_adu=-tel->app_drift_rot/coef*tel->axis_param[AXIS_PARALLACTIC].coef_vsm/1000;
		}
	} else {
		tel->app_drift_ra_adu=0;
		if (tel->app_drift_ha>0) {
			tel->app_drift_ha_adu=-tel->app_drift_ha/coef*tel->axis_param[AXIS_HA].coef_vsp/1000;
		} else {
			tel->app_drift_ha_adu=-tel->app_drift_ha/coef*tel->axis_param[AXIS_HA].coef_vsm/1000;
		}
		if (tel->app_drift_dec>0) {
			tel->app_drift_dec_adu=-tel->app_drift_dec/coef*tel->axis_param[AXIS_DEC].coef_vsp/1000;
		} else {
			tel->app_drift_dec_adu=-tel->app_drift_dec/coef*tel->axis_param[AXIS_DEC].coef_vsm/1000;
		}
		tel->app_drift_az_adu=0;
		tel->app_drift_elev_adu=0;
		tel->app_drift_rot_adu=0;
	}
}

void mytel_coord_stopped(struct telprop *tel) {
	double coef;
	coef=15.0410686;
	tel->jdstopped=tel->jdcalcul;
	tel->app_ra_stopped=tel->app_ra; 
	tel->app_dec_stopped=tel->app_dec;
	tel->app_ha_stopped=tel->app_ha;
	tel->app_az_stopped=tel->app_az;
	tel->app_elev_stopped=tel->app_elev;
	tel->app_rot_stopped=tel->app_rot;
	tel->app_drift_ra=coef;
	tel->app_drift_dec=0;
	tel->app_drift_ha=0;
	tel->app_drift_az=0;
	tel->app_drift_elev=0;
	tel->app_drift_rot=0;
}

int mytel_loadparams(struct telprop *tel,int naxisno) {
	char s[1024];
	int err,axisno,kaxisno;
	int val;
	/* --- Inits par defaut ---*/
	if (tel->type_mount==MOUNT_ALTAZ) {
		if ((naxisno<0)||(naxisno==AXIS_AZ)) {
			tel->axis_param[AXIS_AZ].coef_vs=655050; /* coefficient vitesse suivi azimuth (ADU/ratio_sideral) */
			tel->axis_param[AXIS_AZ].coef_vsm=655050; /* coefficient vitesse suivi MOINS azimuth (ADU/ratio_sideral) */
			tel->axis_param[AXIS_AZ].coef_vsp=655273; /* coefficient vitesse suivi PLUS azimuth (ADU/ratio_sideral) */
			tel->axis_param[AXIS_AZ].coef_xs=3661000; /* coefficient pointage azimuth (ADU/deg) */
			tel->axis_param[AXIS_AZ].coef_xsm=3674614; /* coefficient pointage MOINS azimuth (ADU/deg) */
			tel->axis_param[AXIS_AZ].coef_xsp=3675864; /* coefficient pointage PLUS azimuth (ADU/deg) */
			tel->axis_param[AXIS_AZ].posinit=(int)pow(2,30);
			tel->axis_param[AXIS_AZ].angleinit=0.;
			tel->axis_param[AXIS_AZ].angleturnback=20.;
			tel->axis_param[AXIS_AZ].angleover=1;
			tel->axis_param[AXIS_AZ].angleovered=0;
			sprintf(s,"mc_date2jd now"); mytel_tcleval(tel,s);
			tel->axis_param[AXIS_AZ].jdinit=atof(tel->interp->result);
			tel->axis_param[AXIS_AZ].temperature=20;
		}
		if ((naxisno<0)||(naxisno==AXIS_ELEV)) {
			tel->axis_param[AXIS_ELEV].coef_vs=1298651; /* coefficient vitesse suivi elevation (ADU/ratio_sideral) */
			tel->axis_param[AXIS_ELEV].coef_vsm=1298651; /* coefficient vitesse suivi MOINS elevation (ADU/ratio_sideral) */
			tel->axis_param[AXIS_ELEV].coef_vsp=1297414; /* coefficient vitesse suivi PLUS elevation (ADU/ratio_sideral) */
			tel->axis_param[AXIS_ELEV].coef_xs=7285000; /* coefficient pointage elevation (ADU/deg) */
			tel->axis_param[AXIS_ELEV].coef_xsm=7285000; /* coefficient pointage MOINS elevation (ADU/deg) */
			tel->axis_param[AXIS_ELEV].coef_xsp=7278062; /* coefficient pointage PLUS elevation (ADU/deg) */
			tel->axis_param[AXIS_ELEV].posinit=(int)pow(2,30);
			tel->axis_param[AXIS_ELEV].angleinit=90-43.8740-40;
			tel->axis_param[AXIS_ELEV].angleturnback=180.;
			tel->axis_param[AXIS_ELEV].angleover=10;
			tel->axis_param[AXIS_ELEV].angleovered=0;
			sprintf(s,"mc_date2jd now"); mytel_tcleval(tel,s);
			tel->axis_param[AXIS_ELEV].jdinit=atof(tel->interp->result);
			tel->axis_param[AXIS_ELEV].temperature=20;
		}
		if ((naxisno<0)||(naxisno==AXIS_PARALLACTIC)) {
			tel->axis_param[AXIS_PARALLACTIC].coef_vs=924492; /* coefficient vitesse suivi derotateur (ADU/ratio_sideral) */
			tel->axis_param[AXIS_PARALLACTIC].coef_vsm=924492; /* coefficient vitesse suivi MOINS derotateur (ADU/ratio_sideral) */
			tel->axis_param[AXIS_PARALLACTIC].coef_vsp=924492; /* coefficient vitesse suivi PLUS derotateur (ADU/ratio_sideral) */
			tel->axis_param[AXIS_PARALLACTIC].coef_xs=1728694; /* coefficient pointage derotateur (ADU/deg) */
			tel->axis_param[AXIS_PARALLACTIC].coef_xsm=1728694; /* coefficient pointage MOINS derotateur (ADU/deg) */
			tel->axis_param[AXIS_PARALLACTIC].coef_xsp=1728694; /* coefficient pointage PLUS derotateur (ADU/deg) */
			tel->axis_param[AXIS_PARALLACTIC].posinit=(int)pow(2,30)-25165807;
			tel->axis_param[AXIS_PARALLACTIC].angleinit=0.;
			tel->axis_param[AXIS_PARALLACTIC].angleturnback=180.;
			tel->axis_param[AXIS_PARALLACTIC].angleover=30;
			tel->axis_param[AXIS_PARALLACTIC].angleovered=0;
			sprintf(s,"mc_date2jd now"); mytel_tcleval(tel,s);
			tel->axis_param[AXIS_PARALLACTIC].jdinit=atof(tel->interp->result);
			tel->axis_param[AXIS_PARALLACTIC].temperature=20;
		}
	} else {
		if ((naxisno<0)||(naxisno==AXIS_HA)) {
			tel->axis_param[AXIS_HA].coef_vs=645000; /* coefficient vitesse suivi angle horaire (ADU/ratio_sideral) */
			tel->axis_param[AXIS_HA].coef_vsm=645000; /* coefficient vitesse suivi angle horaire (ADU/ratio_sideral) */
			tel->axis_param[AXIS_HA].coef_vsp=645000; /* coefficient vitesse suivi angle horaire (ADU/ratio_sideral) */
			tel->axis_param[AXIS_HA].coef_xs=3661000; /* coefficient pointage angle horaire (ADU/deg) */
			tel->axis_param[AXIS_HA].coef_xsm=3661000; /* coefficient pointage angle horaire (ADU/deg) */
			tel->axis_param[AXIS_HA].coef_xsp=3661000; /* coefficient pointage angle horaire (ADU/deg) */
			tel->axis_param[AXIS_HA].posinit=(int)pow(2,30);
			tel->axis_param[AXIS_HA].angleinit=0.;
			tel->axis_param[AXIS_HA].angleturnback=180.;
			tel->axis_param[AXIS_HA].angleover=10;
			tel->axis_param[AXIS_HA].angleovered=0;
			sprintf(s,"mc_date2jd now"); mytel_tcleval(tel,s);
			tel->axis_param[AXIS_HA].jdinit=atof(tel->interp->result);
			tel->axis_param[AXIS_HA].temperature=20;
		}
		if ((naxisno<0)||(naxisno==AXIS_DEC)) {
			tel->axis_param[AXIS_DEC].coef_vs=1300000; /* coefficient vitesse suivi declinaison (ADU/ratio_sideral) */
			tel->axis_param[AXIS_DEC].coef_vsm=1300000; /* coefficient vitesse suivi declinaison (ADU/ratio_sideral) */
			tel->axis_param[AXIS_DEC].coef_vsp=1300000; /* coefficient vitesse suivi declinaison (ADU/ratio_sideral) */
			tel->axis_param[AXIS_DEC].coef_xs=7285000; /* coefficient pointage declinaison (ADU/deg) */
			tel->axis_param[AXIS_DEC].coef_xsm=7285000; /* coefficient pointage declinaison (ADU/deg) */
			tel->axis_param[AXIS_DEC].coef_xsp=7285000; /* coefficient pointage declinaison (ADU/deg) */
			tel->axis_param[AXIS_DEC].posinit=(int)pow(2,30);
			tel->axis_param[AXIS_DEC].angleinit=0.;
			tel->axis_param[AXIS_DEC].angleturnback=180.;
			tel->axis_param[AXIS_DEC].angleover=10;
			tel->axis_param[AXIS_DEC].angleovered=0;
			sprintf(s,"mc_date2jd now"); mytel_tcleval(tel,s);
			tel->axis_param[AXIS_DEC].jdinit=atof(tel->interp->result);
			tel->axis_param[AXIS_DEC].temperature=20;
		}
	}
	// --- on met les bonnes valeurs dans le cas du mode reel
	if (tel->mode==MODE_REEL) {
		// --- get value from the controler
		for (kaxisno=0;kaxisno<tel->nb_axis;kaxisno++) {
			axisno=tel->axes[kaxisno];
			if ((naxisno>=0)&&(naxisno!=axisno)) {
				continue;
			}
			// CMD 26 1 {0 0 79} : init
//			if (err=mytel_execute_command(tel,axisno,26,1,0,0,79)) { mytel_error(tel,axisno,err); return 1; }
			// X22.0 coefficients des vitesses
			if (err=mytel_get_register(tel,axisno,ETEL_X,22,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].coef_vs=val;
			// X23.0 coefficients des pointages
			if (err=mytel_get_register(tel,axisno,ETEL_X,23,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].coef_xs=val;
			// X26.0 coefficients des vitesses MOINS
			if (err=mytel_get_register(tel,axisno,ETEL_X,26,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].coef_vsm=val;
			// X27.0 coefficients des vitesses PLUS
			if (err=mytel_get_register(tel,axisno,ETEL_X,27,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].coef_vsp=val;
			// X28.0 coefficients des pointages MOINS
			if (err=mytel_get_register(tel,axisno,ETEL_X,28,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].coef_xsm=val;
			// X29.0 coefficients des pointages PLUS
			if (err=mytel_get_register(tel,axisno,ETEL_X,29,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].coef_xsp=val;
			// M90.0 temperature du controleur
			if (err=mytel_get_register(tel,axisno,ETEL_M,90,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].temperature=val;
			// CMD 26 1 {0 0 77} : arret moteur + index au milieu
//			if (err=mytel_execute_command(tel,axisno,26,1,0,0,77)) { mytel_error(tel,axisno,err); return 1; }
			// M7.0 position au milieu du codeur
			if (err=mytel_get_register(tel,axisno,ETEL_M,7,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].posinit=val; 
			sprintf(s,"mc_date2jd now"); mytel_tcleval(tel,s);
			tel->axis_param[axisno].jdinit=atof(tel->interp->result);
			if ((tel->type_mount==MOUNT_EQUATORIAL)&&(axisno==AXIS_HA)) {
				tel->axis_param[axisno].angleinit=0.;
				tel->axis_param[axisno].angleturnback=180.;
				tel->axis_param[axisno].angleover=10.;
			}
			if ((tel->type_mount==MOUNT_EQUATORIAL)&&(axisno==AXIS_DEC)) {
				tel->axis_param[axisno].angleinit=0.;
				tel->axis_param[axisno].angleturnback=180.;
				tel->axis_param[axisno].angleover=10.;
			}
			if ((tel->type_mount==MOUNT_ALTAZ)&&(axisno==AXIS_AZ)) {
				tel->axis_param[axisno].angleinit=0.;
				tel->axis_param[axisno].angleturnback=130.;
				tel->axis_param[axisno].angleover=10.;
			}
			if ((tel->type_mount==MOUNT_ALTAZ)&&(axisno==AXIS_ELEV)) {
				tel->axis_param[axisno].angleinit=90-43.8740-40;
				tel->axis_param[axisno].angleturnback=180.;
				tel->axis_param[axisno].angleover=10.;
			}
			if ((tel->type_mount==MOUNT_ALTAZ)&&(axisno==AXIS_PARALLACTIC)) {
				tel->axis_param[axisno].angleinit=0.;
				tel->axis_param[axisno].angleturnback=180.;
				tel->axis_param[axisno].angleover=10.;
			}
		}
	}
	return 0;
}

int mytel_limites(void) {
	struct telprop telbefore,telafter;
	telbefore=*telthread;
	telafter=telbefore;
	// --- calcul des positions extrapolees lineairement 1 sec plus tard
	if (telthread->type_mount==MOUNT_ALTAZ) {
		telafter.app_az+=(telafter.app_drift_az/3600);
		telafter.app_elev+=(telafter.app_drift_elev/3600);
		telafter.app_rot+=(telafter.app_drift_rot/3600);
	} else {
		telafter.app_ha+=(telafter.app_drift_ha/3600);
		telafter.app_dec+=(telafter.app_drift_dec/3600);
	}
	// --- corrections de turnback
	if (telbefore.app_az>telthread->axis_param[AXIS_AZ].angleturnback) { telbefore.app_az-=360; }
	if (telbefore.app_rot>telthread->axis_param[AXIS_PARALLACTIC].angleturnback) { telbefore.app_rot-=360; }
	if (telbefore.app_ha>telthread->axis_param[AXIS_HA].angleturnback) { telbefore.app_ha-=360; }
	if (telafter.app_az>telthread->axis_param[AXIS_AZ].angleturnback) { telafter.app_az-=360; }
	if (telafter.app_rot>telthread->axis_param[AXIS_PARALLACTIC].angleturnback) { telafter.app_rot-=360; }
	if (telafter.app_ha>telthread->axis_param[AXIS_HA].angleturnback) { telafter.app_ha-=360; }
	// --- detection des limites over pour les securites en mode suivi ---
	if (telthread->type_mount==MOUNT_ALTAZ) {
		if (telthread->axis_param[AXIS_AZ].angleovered==0) {
			if (telafter.app_az-telbefore.app_az<-180) {
				// --- on passe l'angle de turnback en azimuth croissant
				telthread->axis_param[AXIS_AZ].angleovered=1;
			}
			if (telafter.app_az-telbefore.app_az>180) {
				// --- on passe l'angle de turnback en azimuth decroissant
				telthread->axis_param[AXIS_AZ].angleovered=-1;
			}
		}
		if (telthread->axis_param[AXIS_PARALLACTIC].angleover==0) {
			if (telafter.app_rot-telbefore.app_rot<-180) {
				// --- on passe l'angle de turnback en parallactic croissant
				telthread->axis_param[AXIS_PARALLACTIC].angleovered=1;
			}
			if (telafter.app_rot-telbefore.app_rot>180) {
				// --- on passe l'angle de turnback en parallactic decroissant
				telthread->axis_param[AXIS_PARALLACTIC].angleovered=-1;
			}
		}
	} else {
		if (telthread->axis_param[AXIS_HA].angleovered==0) {
			if (telafter.app_ha-telbefore.app_ha<-180) {
				// --- on passe l'angle de turnback en angle horaire croissant
				telthread->axis_param[AXIS_HA].angleovered=1;
			}
			if (telafter.app_ha-telbefore.app_ha>180) {
				// --- on passe l'angle de turnback en angle horaire decroissant
				telthread->axis_param[AXIS_HA].angleovered=-1;
			}
		}
	}
	// --- detection de limite finale de securite ---
	if (telthread->type_mount==MOUNT_ALTAZ) {
		if ((telthread->axis_param[AXIS_AZ].angleovered==1)&&(telafter.app_az>=telthread->axis_param[AXIS_AZ].angleturnback-360+telthread->axis_param[AXIS_AZ].angleover)) {
			// --- on depasse l'angle de turnback+angleover en azimuth croissant
			telthread->axis_param[AXIS_AZ].angleovered=2;
		}
		if ((telthread->axis_param[AXIS_AZ].angleovered==-1)&&(telafter.app_az<=telthread->axis_param[AXIS_AZ].angleturnback-telthread->axis_param[AXIS_AZ].angleover)) {
			// --- on depasse l'angle de turnback+angleover en azimuth decroissant
			telthread->axis_param[AXIS_AZ].angleovered=-2;
		}
		if ((telthread->axis_param[AXIS_PARALLACTIC].angleovered==1)&&(telafter.app_rot>=telthread->axis_param[AXIS_PARALLACTIC].angleturnback-360+telthread->axis_param[AXIS_PARALLACTIC].angleover)) {
			// --- on depasse l'angle de turnback+angleover en parallactic croissant
			telthread->axis_param[AXIS_PARALLACTIC].angleovered=2;
		}
		if ((telthread->axis_param[AXIS_PARALLACTIC].angleovered==-1)&&(telafter.app_rot<=telthread->axis_param[AXIS_PARALLACTIC].angleturnback-telthread->axis_param[AXIS_PARALLACTIC].angleover)) {
			// --- on depasse l'angle de turnback+angleover en parallactic decroissant
			telthread->axis_param[AXIS_PARALLACTIC].angleovered=-2;
		}
	} else {
		if ((telthread->axis_param[AXIS_HA].angleovered==1)&&(telafter.app_ha>=telthread->axis_param[AXIS_HA].angleturnback-360+telthread->axis_param[AXIS_HA].angleover)) {
			// --- on depasse l'angle de turnback+angleover en angle horaire croissant
			telthread->axis_param[AXIS_HA].angleovered=2;
		}
		if ((telthread->axis_param[AXIS_HA].angleovered==-1)&&(telafter.app_ha<=telthread->axis_param[AXIS_HA].angleturnback-telthread->axis_param[AXIS_HA].angleover)) {
			// --- on depasse l'angle de turnback+angleover en angle horaire decroissant
			telthread->axis_param[AXIS_HA].angleovered=-2;
		}
	}
	return 0;
}
