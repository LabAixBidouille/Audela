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
   {"MCMT II",    /* telescope name */
    "MCMT II",    /* protocol name */
    "mcmt",    /* product */
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

#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_mcmt.txt","wt");
   fprintf(f,"Demarre une init\n");
	fclose(f);
#endif
   Tcl_CreateCommand(tel->interp,"ThreadMcmt_Init", (Tcl_CmdProc *)ThreadMcmt_Init, (ClientData)NULL, NULL);
   if (Tcl_Eval(tel->interp, "thread::create { thread::wait } ") == TCL_OK) {
		//MessageBox(NULL,"Thread créé","LibTMcmt",MB_OK);
		strcpy(tel->loopThreadId, tel->interp->result);
      sprintf(s,"thread::copycommand %s ThreadMcmt_Init ",tel->loopThreadId);
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
		sprintf(s,"thread::send %s {ThreadMcmt_Init", tel->loopThreadId);
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
#if defined(MOUCHARD)
   f=fopen("mouchard_mcmt.txt","at");
   fprintf(f,"Fin de l'init\n");
	fclose(f);
#endif
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
	sprintf(s,"::thread::send %s { CmdThreadMcmt_radec_init }",tel->loopThreadId);
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
	sprintf(s,"::thread::send %s { CmdThreadMcmt_radec_goto }",tel->loopThreadId);
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
	sprintf(s,"::thread::send %s { CmdThreadMcmt_radec_coord }",tel->loopThreadId);
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
// ::tel::create mcmt -mode 0
int ThreadMcmt_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int kk,k;
	int threadpb=0,resint;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];

	telthread = (struct telprop*) calloc( 1, sizeof(struct telprop) );
	
	telthread->interp = interp;

	// decode les arguments
	telthread->mode = MODE_REEL;
	if (argc >= 1) {
		for (kk = 0; kk < argc-1; kk++) {
			// mode : 0=simulation 1=reel
			if (strcmp(argv[kk], "-mode") == 0) {
				telthread->mode = atoi(argv[kk + 1]);
			}
		}
	}

   /* --- transcode a port argument into comX or into /dev... */
   strcpy(ss,argv[2]);
   sprintf(s,"string range [string toupper %s] 0 2",ss);
   mytel_tcleval(telthread,s);
   strcpy(s,telthread->interp->result);
   if (strcmp(s,"COM")==0) {
      sprintf(s,"string range [string toupper %s] 3 end",ss);
      mytel_tcleval(telthread,s);
      strcpy(s,telthread->interp->result);
      k=(int)atoi(s);
      mytel_tcleval(telthread,"set ::tcl_platform(os)");
      strcpy(s,telthread->interp->result);
      if (strcmp(s,"Linux")==0) {
         sprintf(ss,"/dev/ttyS%d",k-1);
         sprintf(ssusb,"/dev/ttyUSB%d",k-1);
      }
   }
   /* --- open the port and record the channel name ---*/
   sprintf(s,"open \"%s\" r+",ss);
   if (mytel_tcleval(telthread,s)!=TCL_OK) {
      strcpy(ssres,telthread->interp->result);
      mytel_tcleval(telthread,"set ::tcl_platform(os)");
      strcpy(ss,telthread->interp->result);
      if (strcmp(ss,"Linux")==0) {
         /* if ttyS not found, we test ttyUSB */
         sprintf(ss,"open \"%s\" r+",ssusb);
         if (mytel_tcleval(telthread,ss)!=TCL_OK) {
            strcpy(telthread->msg,telthread->interp->result);
            return 1;
         }
      } else {
         strcpy(telthread->msg,ssres);
         return 1;
      }
   }
   strcpy(telthread->channel,telthread->interp->result);
   telthread->tempo = 50;
   
   // j'ouvre le port serie 
   //  # 19200 : vitesse de transmission (bauds)
   //  # 0 : 0 bit de parité
   //  # 8 : 8 bits de données
   //  # 1 : 1 bits de stop
   sprintf(s,"fconfigure %s -mode \"19200,n,8,1\" -buffering none -translation {binary binary} -blocking 0",telthread->channel); mytel_tcleval(telthread,s);
   mytel_flush(telthread);
	mytel_tcl_procs(telthread);

   sprintf(s,"set envoi \"E1 FF\" ; set res [envoi $envoi] ; set clair [mcmthexa_decode $envoi $res]"); mytel_tcleval(telthread,s);
	resint=atoi(telthread->interp->result);
	if (resint==0) {
		// probleme car le moteur ne repond pas !
	}

	// inhibe les corrections de "tel1 radec goto" par libtel
	mytel_tcleval(telthread, "proc mcmt_cat2tel { radec } { return $radec }");
	strcpy(telthread->model_cat2tel,"mcmt_cat2tel");
	mytel_tcleval(telthread, "proc mcmt_tel2cat { radec } { return $radec }");
	strcpy(telthread->model_tel2cat,"mcmt_tel2cat");

	// init home
	strcpy(telthread->home,"GPS 1.7187 E 43.8740 220");
	strcpy(telthread->home0,telthread->home);
	strcpy(telthread->homePosition,telthread->home);
	strcpy(telthread->action_prev, "");
	strcpy(telthread->action_next, "motor_off");
	strcpy(telthread->action_cur, "undefined");
	telthread->status = STATUS_MOTOR_OFF;
	telthread->compteur = 0;

	// Initialisation des commandes effectuees a la volee.
	Tcl_CreateCommand(telthread->interp,"CmdThreadMcmt_radec_init", (Tcl_CmdProc *)CmdThreadMcmt_radec_init, (ClientData)telthread, NULL);
	Tcl_CreateCommand(telthread->interp,"CmdThreadMcmt_radec_coord", (Tcl_CmdProc *)CmdThreadMcmt_radec_coord, (ClientData)telthread, NULL);
	Tcl_CreateCommand(telthread->interp,"CmdThreadMcmt_radec_goto", (Tcl_CmdProc *)CmdThreadMcmt_radec_goto, (ClientData)telthread, NULL);
	Tcl_CreateCommand(telthread->interp,"CmdThreadMcmt_appcoord", (Tcl_CmdProc *)CmdThreadMcmt_appcoord, (ClientData)telthread, NULL);

	// initialisation des commandes tcl necessaires au fonctionnement en boucle.
	Tcl_CreateCommand(telthread->interp,"ThreadMcmt_loop", (Tcl_CmdProc *)ThreadMcmt_loop, (ClientData)telthread, NULL);
	mytel_tcleval(telthread,"proc TMcmt_Loop {} { ThreadMcmt_loop ; after 250 TMcmt_Loop }");

	// Lance le fonctionnement en boucle.
	mytel_tcleval(telthread,"TMcmt_Loop");
	
	return 0;
}

/************************/
/*** Boucle du thread ***/
/************************/
int ThreadMcmt_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	int action_ok=0;
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
			}
		}
		telthread->status=STATUS_MOTOR_OFF;
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		mytel_tel2cat(telthread,jdnow,telthread->app_ha_stopped,telthread->app_dec_stopped,&raJ2000,&decJ2000);
		telthread->last_goto_raJ2000=raJ2000;
		telthread->last_goto_decJ2000=decJ2000;
		mytel_cat2tel(telthread,jdnow,raJ2000,decJ2000);
	} else if (strcmp(telthread->action_next,"move_n")==0) {
		/**************/
	   /*** move_n ***/
		/**************/
		if (strcmp(telthread->action_cur,telthread->action_next)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			strcpy(telthread->action_cur,telthread->action_next);
			if (telthread->mode==MODE_REEL) {
			}
		}
	} else if (strcmp(telthread->action_next,"move_s")==0) {
		/**************/
	   /*** move_s ***/
		/**************/
		if (strcmp(telthread->action_cur,telthread->action_next)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			strcpy(telthread->action_cur,telthread->action_next);
			if (telthread->mode==MODE_REEL) {
			}
		}
	} else if ((strcmp(telthread->action_next,"move_n_stop")==0)||(strcmp(telthread->action_next,"move_s_stop")==0)) {
		/**********************************/
	   /*** move_n_stop OR move_s_stop ***/
		/**********************************/
		strcpy(telthread->action_cur,telthread->action_next);
		if (telthread->mode==MODE_REEL) {
		}
	} else if (strcmp(telthread->action_next,"motor_on")==0) {
		/****************/
	   /*** motor_on ***/
		/****************/
		strcpy(telthread->action_cur,telthread->action_next);
		telthread->status=STATUS_MOTOR_ON;
		// calculer ici le PEC
		if (telthread->mode==MODE_REEL) {
		}
		// --- on arrete les moteurs en cas de depassement des limites ---
		mytel_limites();
		strcpy(telthread->action_prev,telthread->action_next);
		/*
		if (((int)fabs(telthread->axis_param[AXIS_AZ].angleovered)==2)||((int)fabs(telthread->axis_param[AXIS_PARALLACTIC].angleovered)==2)||((int)fabs(telthread->axis_param[AXIS_HA].angleovered)==2)) {
			strcpy(telthread->action_next,"motor_off");
		}
		*/
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
int CmdThreadMcmt_radec_init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
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
		
		raJ2000=telthread->ra0;
		decJ2000=telthread->dec0;
		mytel_cat2tel(telthread,jdnow1,raJ2000,decJ2000);
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
int CmdThreadMcmt_radec_coord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[200];	
	double jdnow;
	double raJ2000,decJ2000;

	//MessageBox(NULL,"Entree dans la fonction","Radec coord",MB_OK);

	sprintf(s,"mc_date2jd now"); 	mytel_tcleval(telthread,s);
	jdnow=atof(telthread->interp->result);
//			mytel_tel2cat(telthread,jdnow,telthread->app_ha,telthread->app_dec,&raJ2000,&decJ2000);
	telthread->coord_raJ2000=raJ2000;
	telthread->coord_decJ2000=decJ2000;

	sprintf(s,"%f %f",telthread->coord_raJ2000,telthread->coord_decJ2000);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	
	return TCL_OK;
}

/******************
 *** radec goto ***
 ******************/
int CmdThreadMcmt_radec_goto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
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
		// --- met à jour les variables de coordonnes 
		sprintf(s,"mc_date2jd now"); mytel_tcleval(telthread,s);
		jdnow=atof(telthread->interp->result);
		mytel_cat2tel(telthread,jdnow,raJ2000,decJ2000);
		mytel_coord_stopped(telthread);
		telthread->last_goto_raJ2000=raJ2000;
		telthread->last_goto_decJ2000=decJ2000;
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
int CmdThreadMcmt_appcoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[1024],ligne[1024];
	strcpy(ligne,"mc_date2iso8601 now");
	mytel_tcleval(telthread,ligne);
	strcpy(s,"");
	sprintf(ligne,"%s {%f %f J2000} ",telthread->interp->result,telthread->last_goto_raJ2000,telthread->last_goto_decJ2000);
	strcat(s,ligne);
	sprintf(ligne,"{%f %f %f %f %f %f} ",telthread->app_ra,telthread->app_dec,telthread->app_ha,telthread->app_az,telthread->app_elev,telthread->app_rot);
	strcat(s,ligne);
	sprintf(ligne,"{%f %f %f %f %f %f} ",telthread->app_ra_adu,telthread->app_dec_adu,telthread->app_ha_adu,telthread->app_az_adu,telthread->app_elev_adu,telthread->app_rot_adu);
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
		if (1==1) {
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


//#define MOUCHARD_EVAL

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD_EVAL)
   FILE *f;
   f=fopen("mouchard_ascom.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD_EVAL)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}

int mytel_flush(struct telprop *tel)
/* flush the input channel until nothing is received */
{
   char s[1024];
   int k=0;
   while (1==1) {
      sprintf(s,"read -nonewline %s",tel->channel); mytel_tcleval(tel,s);
      strcpy(s,tel->interp->result);
      if (strcmp(s,"")==0) {
         return k;
      }
      k++;
   }
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
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients);
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
}

int mytel_loadparams(struct telprop *tel,int naxisno) {
	char s[1024];
	int val;
	/* --- Inits par defaut ---*/
	// --- on met les bonnes valeurs dans le cas du mode reel
	if (tel->mode==MODE_REEL) {
		// --- get value from the controler
	}
	return 0;
}

int mytel_limites(void) {
	struct telprop telbefore,telafter;
	telbefore=*telthread;
	telafter=telbefore;
	return 0;
}

int mytel_tcl_procs(struct telprop *tel) {
   Tcl_DString dsptr;
	char s[1024];
	/* --- */
	Tcl_DStringInit(&dsptr);
	sprintf(s,"proc convert_base { nombre basein baseout } {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set symbols {0 1 2 3 4 5 6 7 8 9 A B C D E F}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"# --- conversion vers la base decimale\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"if {$basein==\"ascii\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set nombre [string index $nombre 0]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   if {$nombre==\"\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set nombre \" \"\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   for {set k 0} {$k<256} {incr k} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set car [format %c $k]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      if {$car==$nombre} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"         set integ_decimal $k\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"} else {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set nombre [regsub -all \" \" $nombre \"\"]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set symbins [lrange $symbols 0 [expr $basein-1]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set n [expr [string length $nombre]-1]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set integ_decimal 0\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   for {set k $n} {$k>=0} {incr k -1} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set mult [expr pow($basein,$n-$k)]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set digit [string index $nombre $k]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set kk [lsearch -exact $symbins $digit]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      if {$kk==-1} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"         break\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      } else {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"         set digit $kk\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set integ_decimal [expr $integ_decimal+$digit*$mult]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"# --- conversion vers la base de sortie\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set symbols {0 1 2 3 4 5 6 7 8 9 A B C D E F}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set integ [expr abs(int($integ_decimal))]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"if {$baseout==\"ascii\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   if {$integ>255} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set integ 255\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set bb [format %c $integ]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"} else {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set sortie 0\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set bb ""\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set k 0\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   while {$sortie==0} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set b [expr int(floor($integ/$baseout))]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set reste [lindex $symbols [expr $integ-$baseout*$b]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set bb \"${reste}${bb}\"\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set integ $b\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      if {$b<1} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"         set sortie 1\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"         break\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      incr k\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   if {($baseout==16)&&([string length $bb]%2==1)} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"      set bb \"0${bb}\"\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   } \n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"return $bb\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
	/* --- */
	Tcl_DStringInit(&dsptr);
	sprintf(s,"proc mcmthexa2ascii { mcmthexa } {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set carte  [lindex $mcmthexa 0]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set cmd    [lindex $mcmthexa 1]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set param2 [lindex $mcmthexa 2] ; if {$param2==\"\"} { set param2 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set param3 [lindex $mcmthexa 3] ; if {$param3==\"\"} { set param3 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set param4 [lindex $mcmthexa 4] ; if {$param4==\"\"} { set param4 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set param5 [lindex $mcmthexa 5] ; if {$param5==\"\"} { set param5 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set param6 [lindex $mcmthexa 6] ; if {$param6==\"\"} { set param6 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"set msg \"\"\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"if {$cmd==\"FF\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set hexa \"$carte $cmd\"\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $carte 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $cmd   16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"} else {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total 0\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $carte  16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $cmd    16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $param2 16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $param3 16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $param4 16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $param5 16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set total [expr $total+[convert_base $param6 16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set checksum [expr $total%256]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set hexa \"$carte $cmd $param2 $param3 $param4 $param5 $param6 [convert_base $checksum 10 16]\"\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $carte  16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $cmd    16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $param2 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $param3 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $param4 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $param5 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $param6 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	append msg [convert_base $checksum 10 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"return [list $msg $hexa]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
	/* --- */
	Tcl_DStringInit(&dsptr);
	sprintf(s,"proc mcmthexa_decode { mcmthexa_in mcmthexa_out} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set carte  [lindex $mcmthexa_in 0]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set cmd    [lindex $mcmthexa_in 1]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set param2 [lindex $mcmthexa_in 2] ; if {$param2==""} { set param2 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set param3 [lindex $mcmthexa_in 3] ; if {$param3==""} { set param3 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set param4 [lindex $mcmthexa_in 4] ; if {$param4==""} { set param4 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set param5 [lindex $mcmthexa_in 5] ; if {$param5==""} { set param5 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set param6 [lindex $mcmthexa_in 6] ; if {$param6==""} { set param6 00 }\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	set res ""\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	if {$cmd==\"FF\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		set res [convert_base [lindex $mcmthexa_out 0] 16 10]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		return $res\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	if {$cmd==\"56\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		if {[convert_base [lindex $mcmthexa_out 0] 16 10]!=6} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"			return ""\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		set n [expr [llength $mcmthexa_out]-1]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		for {set k 1} {$k<$n} {incr k} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"			append res [convert_base [lindex $mcmthexa_out $k] 16 ascii]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		return $res\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	if {$cmd==\"4B\"} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		if {[convert_base [lindex $mcmthexa_out 0] 16 10]!=6} {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"			return ""\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		# nb de micropas pour 360 deg\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		set res [expr 100*[convert_base \"[lindex $mcmthexa_out 30][lindex $mcmthexa_out 29]\" 16 10]]\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"		return $res\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	}\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"	return $res\n");Tcl_DStringAppend(&dsptr,s,-1);
	mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
	/* --- */
	Tcl_DStringInit(&dsptr);
	sprintf(s,"proc envoi { mcmthexa } {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   puts -nonewline %s [lindex [mcmthexa2ascii $mcmthexa] 0] ; flush %s\n",telthread->channel,telthread->channel);Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   after %d\n",telthread->tempo);Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set res [ascii2mcmthexa [read $%s]]\n",telthread->channel);Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   return $res\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
	/* --- */
	return 1;
}
