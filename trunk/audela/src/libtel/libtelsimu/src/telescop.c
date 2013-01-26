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
 *
 * ----------------------------
 * Tester le non redemarrage des moteurs apres une correction en tel1 motor off
 * ----------------------------
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
Definition of multitelescope supported by the open loop code
Please use only one of these define before compiling
*/

#define CONTROLLER_TELSIMU

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
#if defined CONTROLLER_TELSIMU
   {"Telescope Simulator",    /* telescope name */
    "Telescope Simulator",    /* protocol name */
    "telsimu",    /* product */
     1.         /* default focal lenght of optic system */
   },
#endif
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
   f=fopen("mouchard_tel.txt","wt");
   fprintf(f,"Demarre une init\n");
	fclose(f);
#endif
	/* - ce clock format permet de debloquer les prochains acces a cette fonction - */
   Tcl_Eval(tel->interp,"clock format 1318667930");

	/* - creates mutex -*/
   pthread_mutexattr_init(&mutexAttr);
   pthread_mutexattr_settype(&mutexAttr, PTHREAD_MUTEX_RECURSIVE);
   pthread_mutex_init(&mutex, &mutexAttr);

   Tcl_CreateCommand(tel->interp,"ThreadTel_Init", (Tcl_CmdProc *)ThreadTel_Init, (ClientData)NULL, NULL);
   if (Tcl_Eval(tel->interp, "thread::create { thread::wait } ") == TCL_OK) {
		strcpy(tel->loopThreadId, tel->interp->result);
      sprintf(s,"thread::copycommand %s ThreadTel_Init ",tel->loopThreadId);
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
		sprintf(s,"thread::send %s {ThreadTel_Init", tel->loopThreadId);
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
   f=fopen("mouchard_tel.txt","at");
   fprintf(f,"Fin de l'init. threadpb=%d\n",threadpb);
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
/* --- called by : tel1 home {GPS long e|w lat alt} --- */
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
   my_pthread_mutex_lock(&mutex);
	telthread->ra0=tel->ra0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"radec_init");
   my_pthread_mutex_unlock(&mutex);
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
	int sortie,t0,dt,time_out=300;
	time_t ltime;
   my_pthread_mutex_lock(&mutex);
	telthread->ra0=tel->ra0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"radec_goto");
   my_pthread_mutex_unlock(&mutex);
   if (tel->radec_goto_blocking==1) {
		sortie=0;
		t0=(int)time(&ltime);
		while (sortie=0) {
			libtel_sleep(500);
			my_pthread_mutex_lock(&mutex);
			if (telthread->status!=STATUS_RADEC_SLEWING) {
				sortie=1;
			}
		   my_pthread_mutex_unlock(&mutex);
			dt=(int)time(&ltime);
			if (dt>time_out) {
				sortie=2;
			}
		}
	}
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   my_pthread_mutex_lock(&mutex);
	telthread->ha0=tel->ha0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"hadec_goto");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   my_pthread_mutex_lock(&mutex);
	telthread->radec_move_rate=tel->radec_move_rate;
	strcpy(telthread->move_direction,direction);
	strcpy(telthread->action_next,"move_start");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   my_pthread_mutex_lock(&mutex);
	strcpy(telthread->move_direction,direction);
	strcpy(telthread->action_next,"motor_stop");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   my_pthread_mutex_lock(&mutex);
   if (tel->radec_motor==1) {
      /* stop the motor */
		strcpy(telthread->action_next,"motor_off");
   } else {
      /* start the motor */
		strcpy(telthread->action_next,"motor_on");
   }
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   my_pthread_mutex_lock(&mutex);
	if (telthread->mode==MODE_REEL) {
		sprintf(result,"%f %f",telthread->coord_cat_cod_deg_ra,telthread->coord_cat_cod_deg_dec);
	} else {
		sprintf(result,"%f %f",telthread->coord_cat_sim_deg_ra,telthread->coord_cat_sim_deg_dec);
	}
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   my_pthread_mutex_lock(&mutex);
	if (telthread->mode==MODE_REEL) {
		sprintf(result,"%f %f",telthread->coord_app_cod_deg_ha,telthread->coord_app_cod_deg_dec);
	} else {
		sprintf(result,"%f %f",telthread->coord_app_sim_deg_ha,telthread->coord_app_sim_deg_dec);
	}
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_adu_coord(struct telprop *tel,char *result)
{
   my_pthread_mutex_lock(&mutex);
	if (tel->type_mount==MOUNT_EQUATORIAL) {
		sprintf(result,"{%f %f %f} {%f %f %f}",telthread->coord_app_cod_adu_ha,telthread->coord_app_cod_adu_dec,telthread->coord_app_cod_adu_hapec,telthread->coord_app_sim_adu_ha,telthread->coord_app_sim_adu_dec,telthread->coord_app_sim_adu_hapec);
	} else {
		sprintf(result,"{%f %f %f} {%f %f %f}",telthread->coord_app_cod_adu_az,telthread->coord_app_cod_adu_elev,telthread->coord_app_cod_adu_rot,telthread->coord_app_sim_adu_az,telthread->coord_app_sim_adu_elev,telthread->coord_app_sim_adu_rot);
	}
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_hadec_init(struct telprop *tel)
{
   my_pthread_mutex_lock(&mutex);
	telthread->ha0=tel->ha0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"hadec_init");
   my_pthread_mutex_unlock(&mutex);
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
// ::tel::create telsimu com1 -mode 0|1
int ThreadTel_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

#if defined CONTROLLER_TELSIMU
	int kk; //,k;
	int threadpb=0; //,resint;
	/*
   char s[1024],ssres[1024];
   char ss[256],ssusb[256],portnum[256];
	*/
#endif
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_tel.txt","at");
   fprintf(f,"Debut de ThreadTel_Init\n",threadpb);
	fclose(f);
#endif

	telthread = (struct telprop*) calloc( 1, sizeof(struct telprop) );
	telthread->interp = interp;
#if defined CONTROLLER_TELSIMU
	// decode les arguments
	telthread->mode = MODE_SIMULATION;
	if (argc >= 1) {
		for (kk = 0; kk < argc-1; kk++) {
			// mode : 0=simulation 1=reel
			if (strcmp(argv[kk], "-mode") == 0) {
				telthread->mode = atoi(argv[kk + 1]);
			}
		}
	}

	telthread->tempo = 50;
	telthread->sideral_sec_per_day=86164;
	telthread->sideral_deg_per_sec=360./86164;
   // init home (important ici pour le calcul des positions initiales)
	strcpy(telthread->home,"GPS 1.7187 E 43.8740 220");
	strcpy(telthread->home0,telthread->home);
	strcpy(telthread->homePosition,telthread->home);

	if (telthread->mode == MODE_REEL) {
   	// open connections

	} else {

		strcpy(telthread->channel,"simulation");
		telthread->N0=-4608000;
		telthread->N1=-4608000;
		telthread->coord_app_sim_adu_cumdha=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumddec=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumdaz=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumdelev=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumdrot=0; // cumulative gotos ADU from/to coder

		// motor off
		mytel_motor_off(telthread);

		// import useful Tcl procs
		strcpy(telthread->channel,"stdout");
		mytel_tcl_procs(telthread);	

	}

	// initial position from coders for simulation
	telthread->speed_app_sim_adu_ha=0;
	telthread->speed_app_sim_adu_dec=0;
	telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
	telthread->speed_app_sim_adu_az=0;
	telthread->speed_app_sim_adu_elev=0;
	telthread->speed_app_sim_adu_rot=0;
	//
	telthread->coord_app_sim_deg_ha0=0;
	telthread->coord_app_sim_deg_dec0=0;
	telthread->coord_app_sim_adu_ha=1073485824; // FARO
	telthread->coord_app_sim_adu_dec=1073485824; // FARO
	telthread->coord_app_sim_adu_ha=1074057335; // T60Makes
	telthread->coord_app_sim_adu_dec=1073741824; // T60Makes
	telthread->coord_app_sim_adu_hapec=0;
	telthread->coord_app_sim_adu_az=0;
	telthread->coord_app_sim_adu_elev=0;
	telthread->coord_app_sim_adu_rot=0;
	telthread->coord_app_sim_adu_hapec=0;
	mytel_app_setutcjd0_now(telthread);
	mytel_app_setutcjd_now(telthread);
	mytel_app_sim_setadu0(telthread);
	mytel_app_sim_adu2deg(telthread);
	mytel_app2cat_sim_deg(telthread);

	// inhibe les corrections de "tel1 radec goto" par libtel
	// car ces corrections sont faites par telescop.c
	mytel_tcleval(telthread, "proc mcmt_cat2tel { radec } { return $radec }");
	strcpy(telthread->model_cat2tel,"mcmt_cat2tel");
	mytel_tcleval(telthread, "proc mcmt_tel2cat { radec } { return $radec }");
	strcpy(telthread->model_tel2cat,"mcmt_tel2cat");

	strcpy(telthread->action_prev, "");
	strcpy(telthread->action_next, "motor_off");
	strcpy(telthread->action_cur, "undefined");
	telthread->status = STATUS_MOTOR_OFF;
	telthread->motor = MOTION_TYPE_STOPED;
	telthread->compteur = 0;
	telthread->exit=0;

#endif

	// Creation des commandes effectuees a la fin d'une action de la grande boucle
	Tcl_CreateCommand(telthread->interp,"CmdThreadTel_loopeval", (Tcl_CmdProc *)CmdThreadTel_loopeval, (ClientData)telthread, NULL);
	strcpy(telthread->mcmt_hexa_command_line,"");

	// initialisation des commandes tcl necessaires au fonctionnement en boucle.
	Tcl_CreateCommand(telthread->interp,"ThreadTel_loop", (Tcl_CmdProc *)ThreadTel_loop, (ClientData)telthread, NULL);
	mytel_tcleval(telthread,"proc TTel_Loop {} { ThreadTel_loop ; after 250 TTel_Loop }");

	// Lance le fonctionnement en boucle.
	mytel_tcleval(telthread,"TTel_Loop");

	return 0;
}

/************************/
/*** Boucle du thread ***/
/************************/
int ThreadTel_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	int action_ok=0,arrivedha,arriveddec;
	char action_locale[80],s[1024],ss[1024];
	double coord_cat_cod_deg_ra0;
	double coord_cat_cod_deg_dec0;
	double utcjd_cat_cod_deg_ra0;
	double coord_app_cod_deg_ha0;
	double coord_app_cod_deg_dec0;
	double ang1,ang0,dang,dangtotal;
	time_t ltime;

	if (telthread->exit==1) {
		free(telthread);
		telthread=NULL;
		return TCL_ERROR;
	}
   my_pthread_mutex_lock(&mutex);
	strcpy(action_locale,telthread->action_next);

	telthread->compteur++;
	telthread->error=0;
	action_ok=1;

	if (strcmp(telthread->action_next,"")!=0) {
		action_ok=action_ok;
	}

	/*****************************/
   /*** check lecture codeurs ***/
	/*****************************/
	// mise a jour des coordonnées (app_ha,app_dec)
	if (telthread->mode==MODE_REEL) {
		// --- get the current real adus
		mytel_app_cod_getadu(telthread);
		// --- convert adu to deg
		mytel_app_cod_adu2deg(telthread);
		// --- convert apparent to catalog degs
		mytel_app2cat_cod_deg(telthread);
	}
	// --- compute the current simulated adus
	mytel_app_sim_getadu(telthread);
	// --- convert adu to deg
	mytel_app_sim_adu2deg(telthread);
	// --- convert apparent to catalog degs
	mytel_app2cat_sim_deg(telthread);

	/******************************/
   /*** check limites securite ***/
	/******************************/
	// --- on arrete les moteurs en cas de depassement des limites ---
	mytel_limites();

	/*************************/
   /*** check fin de slew ***/
	/*************************/
	if ((telthread->status==STATUS_HADEC_SLEWING)||(telthread->status==STATUS_RADEC_SLEWING)) {
		if (telthread->mode==MODE_REEL) {
			sprintf(s,"lindex [mc_sepangle %f %f %f %f]",telthread->coord_app_cod_deg_ha,telthread->coord_app_cod_deg_dec,telthread->ha0,telthread->dec0); mytel_tcleval(telthread,s);
			telthread->sepangle_curdec=atof(telthread->interp->result);
			arrivedha=0;
			if (telthread->sepangle_curha<0.001) {
				arrivedha=1;
			}
			if (telthread->sepangle_curdec<0.001) {
				arriveddec=1;
			}
		} else {
			dangtotal=telthread->coord_app_sim_adu_dha*360./telthread->N0;
			// --- les ha sont comprises entre 0 et 360 deg
			// start angle = ang0
			ang0=fmod(720+telthread->coord_app_sim_deg_ha,360);
			// arrive angle = ang1
			ang1=fmod(720+telthread->ha0,360);
			if ((ang1<180)&&(ang0>180)) {
				// start before meridian, arrive after meridian
				dang=ang1+360-ang0;
			} else if ((ang1>180)&&(ang0>180)) {
				// start before meridian, arrive before meridian
				dang=ang1-ang0;
			} else if ((ang1<180)&&(ang0<180)) {
				// start after meridian, arrive after meridian
				dang=ang1-ang0;
			} else if ((ang1>180)&&(ang0<180)) {
				// start after meridian, arrive before meridian
				dang=ang1-360-ang0;
			}
			if (dang*dangtotal<0) {
				arrivedha=1;
			}
			if (dangtotal==0) {
				arrivedha=1;
			}
			dangtotal=telthread->coord_app_sim_adu_ddec*360./telthread->N1;
			// --- les dec sont comprises entre -90 et +90 deg
			// start angle = ang0
			ang0=telthread->coord_app_sim_deg_dec;
			if (ang0>90) { ang0=90; }
			if (ang0<-90) { ang0=-90; }
			// arrive angle = ang1
			ang1=telthread->dec0;
			if (ang1>90) { ang1=90; }
			if (ang1<-90) { ang1=-90; }
			dang=ang1-ang0;
			if (dang*dangtotal<0) {
				arriveddec=1;
			}
			if (dangtotal==0) {
				arriveddec=1;
			}
		}
		if (arrivedha==1) {
			telthread->speed_app_sim_adu_ha=0;
			telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
		}
		if (arriveddec==1) {
			telthread->speed_app_sim_adu_dec=0;
		}
		if ((arrivedha==1)&&(arriveddec==1)) {
			// on est arrive: motor off -> radec|hadec init -> (motor on)
			// motor off
			if (telthread->mode==MODE_REEL) {
				if (telthread->status==STATUS_HADEC_SLEWING) {
					// --- stop motors
					mytel_motor_stop(telthread);
					mytel_motor_off(telthread);
				}
			}
			telthread->speed_app_sim_adu_ha=0;
			telthread->speed_app_sim_adu_dec=0;
			telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
			telthread->speed_app_sim_adu_az=0; // a calculer
			telthread->speed_app_sim_adu_elev=0; // a calculer
			telthread->speed_app_sim_adu_rot=0; // a calculer
			// radec init for simu
			if (telthread->status==STATUS_RADEC_SLEWING) {
				telthread->coord_cat_sim_deg_ra0=telthread->ra0;
				telthread->coord_cat_sim_deg_dec0=telthread->dec0;
				// --- update coordinates for simulator
				mytel_app_sim_getadu(telthread);
				telthread->utcjd_cat_sim_deg_ra0=mytel_sec2jd(time(&ltime));
				mytel_cat2app_sim_deg0(telthread);
				mytel_app_sim_setadu0(telthread);
			}
			// hadec init for simu
			if (telthread->status==STATUS_HADEC_SLEWING) {
				telthread->coord_app_sim_deg_ha0=telthread->ha0;
				telthread->coord_app_sim_deg_dec0=telthread->dec0;
				// --- update coordinates for simulator
				mytel_app_sim_getadu(telthread);
				mytel_app_sim_setadu0(telthread);
				telthread->utcjd_cat_sim_deg_ra0=mytel_sec2jd(time(&ltime));
				mytel_app2cat_sim_deg0(telthread);
			}
			if (telthread->status==STATUS_RADEC_SLEWING) {
				// motor on
				/*
				if (telthread->mode==MODE_REEL) {
					// --- start motors
					mytel_motor_on(telthread);
				}
				*/
				telthread->status=STATUS_MOTOR_ON;
				telthread->speed_app_sim_adu_ha=telthread->sideral_deg_per_sec;
				telthread->speed_app_sim_adu_dec=0;
				telthread->speed_app_sim_adu_ra=0;
				telthread->speed_app_sim_adu_az=0; // a calculer
				telthread->speed_app_sim_adu_elev=0; // a calculer
				telthread->speed_app_sim_adu_rot=0; // a calculer
			} else {
				telthread->status=STATUS_MOTOR_OFF;
			}
		} else {
			//telthread->sepangle_prevha=telthread->sepangle_curha;
			//telthread->sepangle_prevdec=telthread->sepangle_curdec;
		}
	}

	/*****************************/
   /*** check PEC corrections ***/
	/*****************************/
	// --- corrections de vitesse (Pec, altaz, etc.)
	// uniquement en mode motor on, pas de move et pas de slew
	mytel_speed_corrections(telthread);

	/****************************************/
   /*** check and execute a command line ***/
	/****************************************/
	// --- eval une ligne au protocole MCMT hexa
	if (strcmp(telthread->mcmt_hexa_command_line,"")!=0) {
		sprintf(s,"%s",telthread->mcmt_hexa_command_line);
		strcpy(ss,s);
		sprintf(s,"set envoi \"%s\" ; set res [envoi $envoi]",ss); mytel_tcleval(telthread,s);
		strcpy(telthread->mcmt_hexa_result,telthread->interp->result);
		strcpy(telthread->mcmt_hexa_command_line,"");
	}
	// --- eval une ligne Tcl
	if (strcmp(telthread->eval_command_line,"")!=0) {
		mytel_tcleval(telthread,telthread->eval_command_line);
		strcpy(telthread->eval_result,telthread->interp->result);
		strcpy(telthread->eval_command_line,"");
	}

	/***************/
   /*** actions ***/
	/***************/

   if (strcmp(action_locale,"motor_off")==0) {
		/*****************/
	   /*** motor_off ***/
		/*****************/
		if (telthread->mode==MODE_REEL) {
			// --- stop motors
			mytel_motor_stop(telthread);
			mytel_motor_off(telthread);
		}
		telthread->motor=MOTOR_STOPED;
		telthread->status=STATUS_MOTOR_OFF;
		telthread->speed_app_sim_adu_ha=0;
		telthread->speed_app_sim_adu_dec=0;
		telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
		telthread->speed_app_sim_adu_az=0; // a calculer
		telthread->speed_app_sim_adu_elev=0; // a calculer
		telthread->speed_app_sim_adu_rot=0; // a calculer
	} else if (strcmp(action_locale,"motor_stop")==0) {
		/******************/
	   /*** motor_stop ***/
		/******************/
		if (telthread->mode==MODE_REEL) {
			// --- stop motors
			if ((telthread->status==STATUS_MOVE_SLOW)||(telthread->status==STATUS_MOVE_MEDIUM)||(telthread->status==STATUS_MOVE_FAST)) {
				mytel_motor_move_stop(telthread);
			} else {
				mytel_motor_stop(telthread);
			}
		}
		if ((telthread->status==STATUS_MOVE_SLOW)||(telthread->status==STATUS_MOVE_MEDIUM)||(telthread->status==STATUS_MOVE_FAST)) {
			// completer pour la simu de fin de move
		} else {
			telthread->status=STATUS_MOTOR_OFF;
			telthread->speed_app_sim_adu_ha=0;
			telthread->speed_app_sim_adu_dec=0;
			telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
			telthread->speed_app_sim_adu_az=0; // a calculer
			telthread->speed_app_sim_adu_elev=0; // a calculer
			telthread->speed_app_sim_adu_rot=0; // a calculer
		}
	} else if (strcmp(action_locale,"motor_on")==0) {
		/****************/
	   /*** motor_on ***/
		/****************/
		if (telthread->mode==MODE_REEL) {
			// --- start motors
			mytel_motor_on(telthread);
		}
		telthread->motor=MOTOR_INFINITE;
		telthread->status=STATUS_MOTOR_ON;
		telthread->speed_app_sim_adu_ha=telthread->sideral_deg_per_sec;
		telthread->speed_app_sim_adu_dec=0;
		telthread->speed_app_sim_adu_ra=0;
		telthread->speed_app_sim_adu_az=0; // a calculer
		telthread->speed_app_sim_adu_elev=0; // a calculer
		telthread->speed_app_sim_adu_rot=0; // a calculer
	} else if (strcmp(action_locale,"hadec_init")==0) {
		/******************/
	   /*** hadec_init ***/
		/******************/
		telthread->coord_app_cod_deg_ha0=telthread->ha0;
		telthread->coord_app_cod_deg_dec0=telthread->dec0;
		telthread->coord_app_sim_deg_ha0=telthread->ha0;
		telthread->coord_app_sim_deg_dec0=telthread->dec0;
		if (telthread->mode==MODE_REEL) {
			// --- update coordinates from coders
			mytel_app_cod_getadu(telthread);
			mytel_app_cod_setadu0(telthread);
			telthread->utcjd_cat_cod_deg_ra0=mytel_sec2jd(time(&ltime));
			mytel_app2cat_cod_deg0(telthread);
		}
		// --- update coordinates for simulator
		mytel_app_sim_getadu(telthread);
		mytel_app_sim_setadu0(telthread);
		telthread->utcjd_cat_sim_deg_ra0=mytel_sec2jd(time(&ltime));
		mytel_app2cat_sim_deg0(telthread);
	} else if (strcmp(action_locale,"radec_init")==0) {
		/******************/
	   /*** radec_init ***/
		/******************/
		telthread->coord_cat_cod_deg_ra0=telthread->ra0;
		telthread->coord_cat_cod_deg_dec0=telthread->dec0;
		telthread->coord_cat_sim_deg_ra0=telthread->ra0;
		telthread->coord_cat_sim_deg_dec0=telthread->dec0;
		if (telthread->mode==MODE_REEL) {
			// --- update coordinates from coders
			mytel_app_cod_getadu(telthread);
			telthread->utcjd_cat_cod_deg_ra0=mytel_sec2jd(time(&ltime));
			mytel_cat2app_cod_deg0(telthread);
			mytel_app_cod_setadu0(telthread);
		}
		// --- update coordinates for simulator
		mytel_app_sim_getadu(telthread);
		telthread->utcjd_cat_sim_deg_ra0=mytel_sec2jd(time(&ltime));
		mytel_cat2app_sim_deg0(telthread);
		mytel_app_sim_setadu0(telthread);
	} else if (strcmp(action_locale,"hadec_goto")==0) {
		/******************/
	   /*** hadec_goto ***/
		/******************/
		telthread->status=STATUS_MOTOR_OFF;
		if (telthread->mode==MODE_REEL) {
			// --- stop motors
			mytel_motor_stop(telthread);
			mytel_motor_off(telthread);
		}
		telthread->speed_app_sim_adu_ha=0;
		telthread->speed_app_sim_adu_dec=0;
		telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
		telthread->speed_app_sim_adu_az=0; // a calculer
		telthread->speed_app_sim_adu_elev=0; // a calculer
		telthread->speed_app_sim_adu_rot=0; // a calculer
		// --- goto
		telthread->status=STATUS_HADEC_SLEWING;
		if (telthread->mode==MODE_REEL) {
			mytel_app_cod_setdadu(telthread);
			// --- send goto
			mytel_app_cod_setadu(telthread);
		}
		// --- update coordinates for simulator
		mytel_app_sim_setdadu(telthread);
		mytel_app_sim_setadu(telthread);
		//telthread->sepangle_prevha=360;
		//telthread->sepangle_prevdec=360;
	} else if (strcmp(action_locale,"radec_goto")==0) {
		/******************/
	   /*** radec_goto ***/
		/******************/
		if (telthread->mode==MODE_REEL) {
			// --- stop motors
			mytel_motor_stop(telthread);
		}
		telthread->status=STATUS_MOTOR_OFF;
		telthread->speed_app_sim_adu_ha=0;
		telthread->speed_app_sim_adu_dec=0;
		telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
		telthread->speed_app_sim_adu_az=0; // a calculer
		telthread->speed_app_sim_adu_elev=0; // a calculer
		telthread->speed_app_sim_adu_rot=0; // a calculer
		// --- goto
		telthread->motor=MOTION_TYPE_GOTO;
		telthread->status=STATUS_RADEC_SLEWING;
		if (telthread->mode==MODE_REEL) {
			// --- coversion (ra0,dec0) J2000 cat en (ha0,dec0) app
			coord_app_cod_deg_ha0=telthread->coord_app_cod_deg_ha0;
			coord_app_cod_deg_dec0=telthread->coord_app_cod_deg_dec0;
			coord_cat_cod_deg_ra0=telthread->coord_cat_cod_deg_ra0;
			coord_cat_cod_deg_dec0=telthread->coord_cat_cod_deg_dec0;
			utcjd_cat_cod_deg_ra0=telthread->utcjd_cat_cod_deg_ra0;
			telthread->coord_cat_cod_deg_ra0=telthread->ra0;
			telthread->coord_cat_cod_deg_dec0=telthread->dec0;
			telthread->utcjd_cat_cod_deg_ra0=mytel_sec2jd(time(&ltime));
			mytel_cat2app_cod_deg0(telthread);
			telthread->ha0=telthread->coord_app_cod_deg_ha0;
			telthread->dec0=telthread->coord_app_cod_deg_dec0;
			telthread->coord_app_cod_deg_ha0=coord_app_cod_deg_ha0;
			telthread->coord_app_cod_deg_dec0=coord_app_cod_deg_dec0;
			telthread->coord_cat_cod_deg_ra0=coord_cat_cod_deg_ra0;
			telthread->coord_cat_cod_deg_dec0=coord_cat_cod_deg_dec0;
			telthread->utcjd_cat_cod_deg_ra0=utcjd_cat_cod_deg_ra0;
			// --- compute the path
			mytel_app_cod_setdadu(telthread);
			// --- send goto
			mytel_app_cod_setadu(telthread);
		}
		// --- update coordinates for simulator
		telthread->coord_cat_sim_deg_ra0=telthread->ra0;
		telthread->coord_cat_sim_deg_dec0=telthread->dec0;
		telthread->utcjd_cat_sim_deg_ra0=mytel_sec2jd(time(&ltime));
		mytel_cat2app_sim_deg0(telthread);
		mytel_app_sim_setdadu(telthread);
		mytel_app_sim_setadu(telthread);
		//telthread->sepangle_prevha=360;
		//telthread->sepangle_prevdec=360;
	} else if (strcmp(telthread->action_next,"move_start")==0) {
		/******************/
	   /*** move_start ***/
		/******************/
		if (telthread->radec_move_rate<0.33) {
			telthread->status=STATUS_MOVE_SLOW;
		} else if (telthread->radec_move_rate<0.66) {
			telthread->status=STATUS_MOVE_MEDIUM;
		} else {
			telthread->status=STATUS_MOVE_FAST;
		}
		if (telthread->mode==MODE_REEL) {
			mytel_motor_move_start(telthread);
		}
	} else {
		action_ok=0;
	}
	if (action_ok==1) {
		strcpy(telthread->action_prev,action_locale);
		strcpy(telthread->action_cur,action_locale);
		strcpy(telthread->action_next,"");
	}
	my_pthread_mutex_unlock(&mutex);

	return TCL_OK;
}

/******************************
 *** CmdThreadTel_loopeval ***
 ******************************/
int CmdThreadTel_loopeval(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char result;	
	result=mytel_tcleval(telthread,argv[1]);
	return result;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
	/* Is the drive pointer valid ? */
	if (tel->mode==MODE_REEL) {
#if defined CONTROLLER_TELSIMU
		return 1;
#endif
	} else {
		return 1;
	}
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
	//char s[1024];
	if (tel->mode==MODE_REEL) {
#if defined CONTROLLER_TELSIMU
		if (tel->mode==MODE_REEL) {
			// close the channel
		}
#endif
	}
	telthread->exit=1; // envoie un signal de sortie
	my_pthread_mutex_unlock(&mutex);
   pthread_mutexattr_destroy(&mutexAttr);
   pthread_mutex_destroy(&mutex);
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
   f=fopen("mouchard_tel.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD_EVAL)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}

int my_pthread_mutex_lock (pthread_mutex_t * mutex) {
   return(pthread_mutex_lock(mutex));
}

int my_pthread_mutex_unlock (pthread_mutex_t * mutex) {
   return(pthread_mutex_unlock(mutex));
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */

/***************************************************************************/
/* Return the julian day from seconds elapsed from Jan. 1st 1970           */
/***************************************************************************/
double mytel_sec2jd(time_t secs1970)
{
	return(2440587.5+(int)secs1970/86400.);
}

/***************************************************************************/
/* Get the apparent coordinates from coders (adu)                          */
/***************************************************************************/
int mytel_app_cod_getadu(struct telprop *tel) {
#if defined CONTROLLER_TELSIMU
	/*
	char s[1024],ss[1024];
   time_t ltime;
   double jd;
	tel->coord_app_cod_adu_dec=(int)atoi(tel->interp->result);
	tel->utcjd_app_cod_adu_dec=mytel_sec2jd((int)time(&ltime));	
	tel->coord_app_cod_adu_ha=(int)atoi(tel->interp->result);
	tel->utcjd_app_cod_adu_ha=mytel_sec2jd((int)time(&ltime));	
	tel->coord_app_cod_adu_hapec=atoi(tel->interp->result);
	tel->utcjd_app_cod_adu_hapec=mytel_sec2jd((int)time(&ltime));
	jd=mytel_sec2jd((int)time(&ltime));
	tel->coord_app_cod_adu_az=0;
	tel->coord_app_cod_adu_elev=0;
	tel->coord_app_cod_adu_rot=0;
	tel->utcjd_app_cod_adu_az=jd;
	tel->utcjd_app_cod_adu_elev=jd;
	tel->utcjd_app_cod_adu_rot=jd;
	*/
#endif
	return 0;
}

/***************************************************************************/
/* Set the apparent coordinates from coders (adu) -> goto                  */
/***************************************************************************/
int mytel_app_cod_setadu(struct telprop *tel) {
#if defined CONTROLLER_TELSIMU
	/*
	char s[1024],ss[1024],serial6[9],signe;
	int dadu;
   time_t ltime;
	tel->utcjd_app_cod_adu_ha=mytel_sec2jd((int)time(&ltime));	
	tel->utcjd_app_cod_adu_dec=mytel_sec2jd((int)time(&ltime));	
	*/
#endif
	return 0;
}

/***************************************************************************/
/* Set the apparent initial adu for coders (adu)                           */
/***************************************************************************/
void mytel_app_cod_setadu0(struct telprop *tel) {
	tel->coord_app_cod_adu_ha0=tel->coord_app_cod_adu_ha;
	tel->coord_app_cod_adu_dec0=tel->coord_app_cod_adu_dec;
	tel->coord_app_cod_adu_az0=tel->coord_app_cod_adu_az;
	tel->coord_app_cod_adu_elev0=tel->coord_app_cod_adu_elev;
	tel->coord_app_cod_adu_rot0=tel->coord_app_cod_adu_rot;
	tel->utcjd_app_cod_adu_ha0=tel->utcjd_app_cod_adu_ha;
	tel->utcjd_app_cod_adu_dec0=tel->utcjd_app_cod_adu_dec;
	tel->utcjd_app_cod_adu_az0=tel->utcjd_app_cod_adu_az;
	tel->utcjd_app_cod_adu_elev0=tel->utcjd_app_cod_adu_elev;
	tel->utcjd_app_cod_adu_rot0=tel->utcjd_app_cod_adu_rot;
}

/***************************************************************************/
/* Converts the apparent initial coordinates into catalog for coders (deg) */
/***************************************************************************/
void mytel_app2cat_cod_deg0(struct telprop *tel) {
   char s[1024],ss[1024];
   double coord1, coord2, jd;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		coord1 = tel->coord_app_cod_deg_az0;
		coord2 = tel->coord_app_cod_deg_elev0;   
		jd=tel->utcjd_app_cod_deg_az0;
		sprintf(s,"mc_tel2cat {%.6f %.6f} ALTAZ {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_ra0=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_ra0=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_dec0=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_dec0=jd;	
	} else {
		coord1 = tel->coord_app_cod_deg_ha0;
		coord2 = tel->coord_app_cod_deg_dec0;   
		jd=tel->utcjd_app_cod_deg_ha0;
		sprintf(s,"mc_tel2cat {%.6f %.6f} HADEC {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_ra0=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_ra0=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_dec0=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_dec0=jd;	
	}
}

/***************************************************************************/
/* Converts the apparent coordinates from adu to degrees                   */
/***************************************************************************/
void mytel_app_cod_adu2deg(struct telprop *tel) {
	double dadu,ddeg;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		// tel->N0; // number of ADU for 360 deg
		dadu=(tel->coord_app_cod_adu_az-tel->coord_app_cod_adu_az0);
		ddeg=dadu/tel->N0*360;
		tel->coord_app_cod_deg_az=fmod(tel->coord_app_cod_deg_az0+ddeg+720,360);
		tel->utcjd_app_cod_deg_az=tel->utcjd_app_cod_adu_az;
		dadu=(tel->coord_app_cod_adu_elev-tel->coord_app_cod_adu_elev0);
		ddeg=dadu/tel->N1*360;
		tel->coord_app_cod_deg_elev=tel->coord_app_cod_deg_elev0+ddeg;
		tel->utcjd_app_cod_deg_elev=tel->utcjd_app_cod_adu_elev;
		dadu=(tel->coord_app_cod_adu_rot-tel->coord_app_cod_adu_rot0);
		ddeg=dadu/tel->N2*360;
		tel->coord_app_cod_deg_rot=tel->coord_app_cod_deg_rot0+ddeg;
		tel->utcjd_app_cod_deg_rot=tel->utcjd_app_cod_adu_rot;
	} else {
		// tel->N0; // number of ADU for 360 deg
		dadu=(tel->coord_app_cod_adu_ha-tel->coord_app_cod_adu_ha0);
		ddeg=dadu/tel->N0*360;
		tel->coord_app_cod_deg_ha=fmod(tel->coord_app_cod_deg_ha0+ddeg+720,360);
		tel->utcjd_app_cod_deg_ha=tel->utcjd_app_cod_adu_ha;
		dadu=(tel->coord_app_cod_adu_dec-tel->coord_app_cod_adu_dec0);
		ddeg=dadu/tel->N1*360;
		tel->coord_app_cod_deg_dec=tel->coord_app_cod_deg_dec0+ddeg;
		tel->utcjd_app_cod_deg_dec=tel->utcjd_app_cod_adu_dec;
	}
}

/***************************************************************************/
/* Converts the apparent coordinates into catalog for coders (deg)         */
/***************************************************************************/
void mytel_app2cat_cod_deg(struct telprop *tel) {
   char s[1024],ss[1024];
   double coord1, coord2, jd;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		coord1 = tel->coord_app_cod_deg_az;
		coord2 = tel->coord_app_cod_deg_elev;   
		jd=tel->utcjd_app_cod_deg_az;
		sprintf(s,"mc_tel2cat {%.6f %.6f} ALTAZ {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_ra=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_ra=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_dec=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_dec=jd;	
	} else {
		coord1 = tel->coord_app_cod_deg_ha;
		coord2 = tel->coord_app_cod_deg_dec;   
		jd=tel->utcjd_app_cod_deg_ha;
		sprintf(s,"mc_tel2cat {%.6f %.6f} HADEC {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_ra=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_ra=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_cod_deg_dec=atof(tel->interp->result);
		tel->utcjd_cat_cod_deg_dec=jd;	
	}
}

/***************************************************************************/
/* Converts the catalog coordinates into apparents for coders (deg)        */
/***************************************************************************/
void mytel_cat2app_cod_deg(struct telprop *tel, double jd) {
   char s[1024],ss[1024];
   double raJ2000,decJ2000;
	double coef=tel->sideral_deg_per_sec;
	raJ2000=tel->coord_cat_cod_deg_ra;
	tel->utcjd_cat_cod_deg_ra=jd;
	decJ2000=tel->coord_cat_cod_deg_dec;
	tel->utcjd_cat_cod_deg_dec=jd;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s} -drift %s -driftvalues {%f %f}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients,tel->extradrift_type,tel->extradrift_axis0,tel->extradrift_axis1);
	mytel_tcleval(tel,s);
	// --- deg
	sprintf(s,"string trim [lindex {%s} 10]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_ra=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_ra=jd;
	sprintf(s,"string trim [lindex {%s} 11]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_dec=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_dec=jd;
	sprintf(s,"string trim [lindex {%s} 12]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_ha=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_ha=jd;
	sprintf(s,"string trim [lindex {%s} 13]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_az=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_az=jd;	
	sprintf(s,"string trim [lindex {%s} 14]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_elev=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_elev=jd;
	sprintf(s,"string trim [lindex {%s} 15]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_rot=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_rot=jd;

	// --- speed (arcsec/sec)
	if (tel->status==STATUS_MOTOR_OFF) {
		tel->speed_app_cod_deg_ra=tel->sideral_deg_per_sec;
		tel->speed_app_cod_deg_dec=0;
		tel->speed_app_cod_deg_ha=0;
		tel->speed_app_cod_deg_az=0;
		tel->speed_app_cod_deg_elev=0;
		tel->speed_app_cod_deg_rot=0;
	} else {
		sprintf(s,"string trim [lindex {%s} 16]",ss); mytel_tcleval(tel,s);
		tel->speed_app_cod_deg_ra=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 17]",ss); mytel_tcleval(tel,s);
		tel->speed_app_cod_deg_dec=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 18]",ss); mytel_tcleval(tel,s);
		tel->speed_app_cod_deg_ha=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 19]",ss); mytel_tcleval(tel,s);
		tel->speed_app_cod_deg_az=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 20]",ss); mytel_tcleval(tel,s);
		tel->speed_app_cod_deg_elev=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 21]",ss); mytel_tcleval(tel,s);
		tel->speed_app_cod_deg_rot=atof(tel->interp->result);
	}
}

/***************************************************************************/
/* Converts the apparent coordinates from degrees to adu                   */
/***************************************************************************/
void mytel_app_cod_deg2adu(struct telprop *tel) {
	double dadu,ddeg;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		// tel->N0; // number of ADU for 360 deg
		ddeg=tel->coord_app_cod_deg_az-tel->coord_app_cod_deg_az0;
		dadu=ddeg/360*tel->N0;
		tel->coord_app_cod_adu_az=tel->coord_app_cod_adu_az0+dadu;
		tel->utcjd_app_cod_adu_az=tel->utcjd_app_cod_deg_az;
		ddeg=tel->coord_app_cod_deg_elev-tel->coord_app_cod_deg_elev0;
		dadu=ddeg/360*tel->N1;
		tel->coord_app_cod_adu_elev=tel->coord_app_cod_adu_elev0+dadu;
		tel->utcjd_app_cod_adu_elev=tel->utcjd_app_cod_deg_elev;
		ddeg=tel->coord_app_cod_deg_rot-tel->coord_app_cod_deg_rot0;
		dadu=ddeg/360*tel->N2;
		tel->coord_app_cod_adu_rot=tel->coord_app_cod_adu_rot0+dadu;
		tel->utcjd_app_cod_adu_rot=tel->utcjd_app_cod_deg_rot;
	} else {
		// tel->N0; // number of ADU for 360 deg
		ddeg=tel->coord_app_cod_deg_ha-tel->coord_app_cod_deg_ha0;
		dadu=ddeg/360*tel->N0;
		tel->coord_app_cod_adu_ha=tel->coord_app_cod_adu_ha0+dadu;
		tel->utcjd_app_cod_adu_ha=tel->utcjd_app_cod_deg_ha;
		ddeg=tel->coord_app_cod_deg_dec-tel->coord_app_cod_deg_dec0;
		dadu=ddeg/360*tel->N1;
		tel->coord_app_cod_adu_dec=tel->coord_app_cod_adu_dec0+dadu;
		tel->utcjd_app_cod_adu_dec=tel->utcjd_app_cod_deg_dec;
	}
}

/***************************************************************************/
/* Converts the catalog initial coordinates into apparents for coders (deg)*/
/***************************************************************************/
void mytel_cat2app_cod_deg0(struct telprop *tel) {
   char s[1024],ss[1024];
   double raJ2000,decJ2000,jd;
   jd=tel->utcjd_cat_cod_deg_ra0;
	raJ2000=tel->coord_cat_cod_deg_ra0;
	tel->utcjd_cat_cod_deg_ra0=jd;
	decJ2000=tel->coord_cat_cod_deg_dec0;
	tel->utcjd_cat_cod_deg_dec0=jd;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients);
	mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	// --- deg
	sprintf(s,"string trim [lindex {%s} 10]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_ra0=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_ra0=jd;
	sprintf(s,"string trim [lindex {%s} 11]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_dec0=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_dec0=jd;
	sprintf(s,"string trim [lindex {%s} 12]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_ha0=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_ha0=jd;
	sprintf(s,"string trim [lindex {%s} 13]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_az0=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_az0=jd;
	sprintf(s,"string trim [lindex {%s} 14]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_elev0=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_elev0=jd;
	sprintf(s,"string trim [lindex {%s} 15]",ss); mytel_tcleval(tel,s);
	tel->coord_app_cod_deg_rot0=atof(tel->interp->result);
	tel->utcjd_app_cod_deg_rot0=jd;
}

/***************************************************************************/
/* Get the apparent coordinates from simulator (adu)                       */
/***************************************************************************/
int mytel_app_sim_getadu(struct telprop *tel) {
   time_t ltime;
   double jd,dsec;
	/* --- */
	jd=mytel_sec2jd(time(&ltime));
	if (telthread->type_mount==MOUNT_ALTAZ) {
		tel->utcjd_app_sim_adu_az=jd;	
		tel->coord_app_sim_adu_az=1;
		tel->utcjd_app_sim_adu_elev=jd;	
		tel->coord_app_sim_adu_elev=1;
		tel->utcjd_app_sim_adu_rot=jd;	
		tel->coord_app_sim_adu_rot=1;
		/* --- a remplacer par un calcul theorique hip2tel
		tel->utcjd_app_sim_adu_az=jd;	
		dsec=(jd-tel->utcjd_app_sim_adu_az0)*86400.;
		tel->coord_app_sim_adu_az=(int)(tel->coord_app_sim_adu_az0+dsec/tel->sideral_sec_per_day*tel->N0+telthread->coord_app_sim_adu_cumdaz);
		tel->utcjd_app_sim_adu_elev=jd;	
		dsec=(jd-tel->utcjd_app_sim_adu_elev0)*86400.;
		tel->coord_app_sim_adu_elev=(int)(tel->coord_app_sim_adu_elev0+dsec/tel->sideral_sec_per_day*tel->N1+telthread->coord_app_sim_adu_cumdelev);
		tel->utcjd_app_sim_adu_rot=jd;	
		dsec=(jd-tel->utcjd_app_sim_adu_rot0)*86400.;
		tel->coord_app_sim_adu_rot=(int)(tel->coord_app_sim_adu_rot0+dsec/tel->sideral_sec_per_day*tel->N2+telthread->coord_app_sim_adu_cumdrot);
		*/
		tel->coord_app_sim_adu_ha=0;
		tel->coord_app_sim_adu_dec=0;
		tel->utcjd_app_sim_adu_ha=jd;			
		tel->utcjd_app_sim_adu_dec=jd;	
	} else {
#define MOTION_TYPE_STOPED 0
#define MOTION_TYPE_INFINITE 1
#define MOTION_TYPE_GOTO 2

		dsec=(jd-tel->utcjd_app_sim_adu_ha)*86400.;
		// --- compute the new HA position
		pos1=tel->coord_app_sim_adu_ha;
		pos2=pos1+tel->speed_app_sim_adu_ha*dsec*tel->N0/360.;
		if (tel->motor=MOTION_TYPE_GOTO) {
			test=(pos1-tel1->coord_cat_sim_deg_ra0)*(pos2-tel1->coord_cat_sim_deg_ra0);
			if (test<0) {
				// --- GOTO arrived in HA position
				pos2=pos1;
				telthread->speed_app_sim_adu_ha=0;
				telthread->speed_app_sim_adu_ra=telthread->sideral_deg_per_sec;
			}
		}
		tel->coord_app_sim_adu_ha=pos2;
		tel->utcjd_app_sim_adu_ha=jd;


		tel->coord_app_sim_adu_hapec=(int)(fmod(telthread->coord_app_sim_adu_hapec+25600*dsec/480.,25600));
		tel->utcjd_app_sim_adu_hapec=jd;
		// --- compute the new DEC position
		pos1=tel->coord_app_sim_adu_dec;
		pos2=pos1+tel->speed_app_sim_adu_dec*dsec*tel->N1/360.;
		if (tel->motor=MOTION_TYPE_GOTO) {
			test=(pos1-tel1->coord_cat_sim_deg_dec0)*(pos2-tel1->coord_cat_sim_deg_dec0);
			if (test<0) {
				// --- GOTO arrived in DEC position
				pos2=pos1;
				telthread->speed_app_sim_adu_dec=0;
			}
		}
		tel->coord_app_sim_adu_dec=pos2;
		tel->utcjd_app_sim_adu_dec=jd;	
		//
		tel->coord_app_sim_adu_az=0;
		tel->coord_app_sim_adu_elev=0;
		tel->coord_app_sim_adu_rot=0;
		tel->utcjd_app_sim_adu_az=jd;
		tel->utcjd_app_sim_adu_elev=jd;
		tel->utcjd_app_sim_adu_rot=jd;
	}
	return 0;
}

/***************************************************************************/
/* Set the apparent initial adu for simulator (adu)                        */
/***************************************************************************/
void mytel_app_sim_setadu0(struct telprop *tel) {
	tel->coord_app_sim_adu_ha0=tel->coord_app_sim_adu_ha;
	tel->coord_app_sim_adu_dec0=tel->coord_app_sim_adu_dec;
	tel->coord_app_sim_adu_az0=tel->coord_app_sim_adu_az;
	tel->coord_app_sim_adu_elev0=tel->coord_app_sim_adu_elev;
	tel->coord_app_sim_adu_rot0=tel->coord_app_sim_adu_rot;
	tel->coord_app_sim_adu_hapec0=tel->coord_app_sim_adu_hapec;
	tel->utcjd_app_sim_adu_ha0=tel->utcjd_app_sim_adu_ha;
	tel->utcjd_app_sim_adu_dec0=tel->utcjd_app_sim_adu_dec;
	tel->utcjd_app_sim_adu_az0=tel->utcjd_app_sim_adu_az;
	tel->utcjd_app_sim_adu_elev0=tel->utcjd_app_sim_adu_elev;
	tel->utcjd_app_sim_adu_rot0=tel->utcjd_app_sim_adu_rot;
	tel->utcjd_app_sim_adu_hapec0=tel->utcjd_app_sim_adu_hapec;
}

/***************************************************************************/
/* Converts the apparent initial coordinates into catalog for coders (deg) */
/***************************************************************************/
void mytel_app2cat_sim_deg0(struct telprop *tel) {
   char s[1024],ss[1024];
   double coord1, coord2, jd;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		coord1 = tel->coord_app_sim_deg_az0;
		coord2 = tel->coord_app_sim_deg_elev0;   
		jd=tel->utcjd_app_sim_deg_az0;
		sprintf(s,"mc_tel2cat {%.6f %.6f} ALTAZ {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_ra0=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_ra0=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_dec0=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_dec0=jd;	
	} else {
		coord1 = tel->coord_app_sim_deg_ha0;
		coord2 = tel->coord_app_sim_deg_dec0;   
		jd=tel->utcjd_app_sim_deg_ha0;
		sprintf(s,"mc_tel2cat {%.6f %.6f} HADEC {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_ra0=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_ra0=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_dec0=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_dec0=jd;
	}
}

/***************************************************************************/
/* Converts the apparent coordinates from adu to degrees (simulator)       */
/***************************************************************************/
void mytel_app_sim_adu2deg(struct telprop *tel) {
	double dadu,ddeg;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		// tel->N0; // number of ADU for 360 deg
		dadu=(tel->coord_app_sim_adu_az-tel->coord_app_sim_adu_az0);
		ddeg=dadu/tel->N0*360;
		tel->coord_app_sim_deg_az=fmod(tel->coord_app_sim_deg_az0+ddeg+720,360);
		tel->utcjd_app_sim_deg_az=tel->utcjd_app_sim_adu_az;
		dadu=(tel->coord_app_sim_adu_elev-tel->coord_app_sim_adu_elev0);
		ddeg=dadu/tel->N1*360;
		tel->coord_app_sim_deg_elev=tel->coord_app_sim_deg_elev0+ddeg;
		tel->utcjd_app_sim_deg_elev=tel->utcjd_app_sim_adu_elev;
		dadu=(tel->coord_app_sim_adu_rot-tel->coord_app_sim_adu_rot0);
		ddeg=dadu/tel->N2*360;
		tel->coord_app_sim_deg_rot=tel->coord_app_sim_deg_rot0+ddeg;
		tel->utcjd_app_sim_deg_rot=tel->utcjd_app_sim_adu_rot;
	} else {
		// tel->N0; // number of ADU for 360 deg
		dadu=(tel->coord_app_sim_adu_ha-tel->coord_app_sim_adu_ha0);
		ddeg=dadu/tel->N0*360;
		tel->coord_app_sim_deg_ha=fmod(tel->coord_app_sim_deg_ha0+ddeg+720,360);
		tel->utcjd_app_sim_deg_ha=tel->utcjd_app_sim_adu_ha;
		dadu=(tel->coord_app_sim_adu_dec-tel->coord_app_sim_adu_dec0);
		ddeg=dadu/tel->N1*360;
		tel->coord_app_sim_deg_dec=tel->coord_app_sim_deg_dec0+ddeg;
		tel->utcjd_app_sim_deg_dec=tel->utcjd_app_sim_adu_dec;
	}
}

/***************************************************************************/
/* Converts the apparent coordinates into catalog for simulator (deg)      */
/***************************************************************************/
void mytel_app2cat_sim_deg(struct telprop *tel) {
   char s[1024],ss[1024];
   double coord1, coord2, jd;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		coord1 = tel->coord_app_sim_deg_az;
		coord2 = tel->coord_app_sim_deg_elev;   
		jd=tel->utcjd_app_sim_deg_az;
		sprintf(s,"mc_tel2cat {%.6f %.6f} ALTAZ {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_ra=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_ra=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_dec=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_dec=jd;	
	} else {
		coord1 = tel->coord_app_sim_deg_ha;
		coord2 = tel->coord_app_sim_deg_dec;   
		jd=tel->utcjd_app_sim_deg_ha;
		sprintf(s,"mc_tel2cat {%.6f %.6f} HADEC {%f} {%s} %d %d {%s} {%s}",coord1,coord2, jd, tel->homePosition,tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients);
		mytel_tcleval(tel,s);
		strcpy(ss,tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_ra=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_ra=jd;	
		sprintf(s,"string trim [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
		tel->coord_cat_sim_deg_dec=atof(tel->interp->result);
		tel->utcjd_cat_sim_deg_dec=jd;	
	}
}

/***************************************************************************/
/* Converts the catalog coordinates into apparents for simulator (deg)     */
/***************************************************************************/
void mytel_cat2app_sim_deg(struct telprop *tel, double jd) {
   char s[1024],ss[1024];
   double raJ2000,decJ2000;
	double coef=15.0410686;
	raJ2000=tel->coord_cat_sim_deg_ra;
	tel->utcjd_cat_sim_deg_ra=jd;
	decJ2000=tel->coord_cat_sim_deg_dec;
	tel->utcjd_cat_sim_deg_dec=jd;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients);
	mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	// --- deg
	sprintf(s,"string trim [lindex {%s} 10]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_ra=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_ra=jd;
	sprintf(s,"string trim [lindex {%s} 11]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_dec=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_dec=jd;
	sprintf(s,"string trim [lindex {%s} 12]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_ha=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_ha=jd;
	sprintf(s,"string trim [lindex {%s} 13]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_az=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_az=jd;	
	sprintf(s,"string trim [lindex {%s} 14]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_elev=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_elev=jd;
	sprintf(s,"string trim [lindex {%s} 15]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_rot=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_rot=jd;
	// --- arcsec/sec
	if (tel->status==STATUS_MOTOR_OFF) {
		tel->speed_app_sim_deg_ra=tel->sideral_deg_per_sec;
		tel->speed_app_sim_deg_dec=0;
		tel->speed_app_sim_deg_ha=0;
		tel->speed_app_sim_deg_az=0;
		tel->speed_app_sim_deg_elev=0;
		tel->speed_app_sim_deg_rot=0;
	} else {
		sprintf(s,"string trim [lindex {%s} 16]",ss); mytel_tcleval(tel,s);
		tel->speed_app_sim_deg_ra=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 17]",ss); mytel_tcleval(tel,s);
		tel->speed_app_sim_deg_dec=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 18]",ss); mytel_tcleval(tel,s);
		tel->speed_app_sim_deg_ha=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 19]",ss); mytel_tcleval(tel,s);
		tel->speed_app_sim_deg_az=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 20]",ss); mytel_tcleval(tel,s);
		tel->speed_app_sim_deg_elev=atof(tel->interp->result);
		sprintf(s,"string trim [lindex {%s} 21]",ss); mytel_tcleval(tel,s);
		tel->speed_app_sim_deg_rot=atof(tel->interp->result);
	}
}

/***************************************************************************/
/* Converts the apparent coordinates from degrees to adu (simulator)       */
/***************************************************************************/
void mytel_app_sim_deg2adu(struct telprop *tel) {
	double dadu,ddeg;
	double coef=tel->sideral_deg_per_sec;
	if (tel->type_mount==MOUNT_ALTAZ) {
		// coords
		// tel->N0; // number of ADU for 360 deg
		ddeg=tel->coord_app_sim_deg_az-tel->coord_app_sim_deg_az0;
		dadu=ddeg/360*tel->N0;
		tel->coord_app_sim_adu_az=tel->coord_app_sim_adu_az0+dadu;
		tel->utcjd_app_sim_adu_az=tel->utcjd_app_sim_deg_az;
		// tel->N1; // number of ADU for 360 deg
		ddeg=tel->coord_app_sim_deg_elev-tel->coord_app_sim_deg_elev0;
		dadu=ddeg/360*tel->N1;
		tel->coord_app_sim_adu_elev=tel->coord_app_sim_adu_elev0+dadu;
		tel->utcjd_app_sim_adu_elev=tel->utcjd_app_sim_deg_elev;
		// tel->N0; // number of ADU for 360 deg
		ddeg=tel->coord_app_sim_deg_rot-tel->coord_app_sim_deg_rot0;
		dadu=ddeg/360*tel->N2;
		tel->coord_app_sim_adu_rot=tel->coord_app_sim_adu_rot0+dadu;
		tel->utcjd_app_sim_adu_rot=tel->utcjd_app_sim_deg_rot;
		// speeds
		tel->speed_app_sim_adu_ra=0;
		tel->speed_app_sim_adu_ha=0;
		tel->speed_app_sim_adu_dec=0;
	} else {
		// coords
		// tel->N0; // number of ADU for 360 deg
		ddeg=tel->coord_app_sim_deg_ha-tel->coord_app_sim_deg_ha0;
		dadu=ddeg/360*tel->N0;
		tel->coord_app_sim_adu_ha=tel->coord_app_sim_adu_ha0+dadu;
		tel->utcjd_app_sim_adu_ha=tel->utcjd_app_sim_deg_ha;
		ddeg=tel->coord_app_sim_deg_dec-tel->coord_app_sim_deg_dec0;
		dadu=ddeg/360*tel->N1;
		tel->coord_app_sim_adu_dec=tel->coord_app_sim_adu_dec0+dadu;
		tel->utcjd_app_sim_adu_dec=tel->utcjd_app_sim_deg_dec;
		// speeds
		tel->speed_app_sim_deg_ra=0;
		tel->speed_app_sim_deg_az=0;
		tel->speed_app_sim_deg_elev=0;
		tel->speed_app_sim_deg_rot=0;
	}
}

/***************************************************************************/
/* Converts the catalog initial coordinates into apparents for coders (deg)*/
/***************************************************************************/
void mytel_cat2app_sim_deg0(struct telprop *tel) {
   char s[1024],ss[1024];
   double raJ2000,decJ2000,jd;
   jd=tel->utcjd_cat_sim_deg_ra0;
	raJ2000=tel->coord_cat_sim_deg_ra0;
	tel->utcjd_cat_sim_deg_ra0=jd;
	decJ2000=tel->coord_cat_sim_deg_dec0;
	tel->utcjd_cat_sim_deg_dec0=jd;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients);
	mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	// --- deg
	sprintf(s,"string trim [lindex {%s} 10]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_ra0=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_ra0=jd;
	sprintf(s,"string trim [lindex {%s} 11]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_dec0=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_dec0=jd;
	sprintf(s,"string trim [lindex {%s} 12]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_ha0=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_ha0=jd;
	sprintf(s,"string trim [lindex {%s} 13]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_az0=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_az0=jd;
	sprintf(s,"string trim [lindex {%s} 14]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_elev0=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_elev0=jd;
	sprintf(s,"string trim [lindex {%s} 15]",ss); mytel_tcleval(tel,s);
	tel->coord_app_sim_deg_rot0=atof(tel->interp->result);
	tel->utcjd_app_sim_deg_rot0=jd;
}

/***************************************************************************/
/* Set the apparent coordinates from coders (adu) -> goto                  */
/***************************************************************************/
int mytel_app_sim_setadu(struct telprop *tel) {
#if defined CONTROLLER_TELSIMU
	int dadu;
   time_t ltime;
	/* --- */
	dadu=(int)tel->coord_app_sim_adu_dha;
//	tel->coord_app_sim_adu_cumdha+=tel->coord_app_sim_adu_dha;
	tel->utcjd_app_sim_adu_ha=mytel_sec2jd((int)time(&ltime));	
	/* --- */
	dadu=(int)tel->coord_app_sim_adu_ddec;
//	tel->coord_app_sim_adu_cumddec+=tel->coord_app_sim_adu_ddec;
	tel->utcjd_app_sim_adu_dec=mytel_sec2jd((int)time(&ltime));	
#endif
	return 0;
}

/******************************************************************************/
/* Set all utcjd initial coordinates to the current date (motors are stopped) */
/******************************************************************************/
void mytel_app_setutcjd0_now(struct telprop *tel) {
   time_t ltime;
   double jd;
	jd=mytel_sec2jd(time(&ltime));
	/* --- */
	tel->utcjd_app_sim_deg_ra0=jd;
	tel->utcjd_app_sim_deg_dec0=jd;
	tel->utcjd_app_sim_deg_ha0=jd;
	tel->utcjd_app_sim_deg_az0=jd;
	tel->utcjd_app_sim_deg_elev0=jd;
	tel->utcjd_app_sim_deg_rot0=jd;
	/* --- */
	tel->utcjd_app_cod_deg_ra0=jd;
	tel->utcjd_app_cod_deg_dec0=jd;
	tel->utcjd_app_cod_deg_ha0=jd;
	tel->utcjd_app_cod_deg_az0=jd;
	tel->utcjd_app_cod_deg_elev0=jd;
	tel->utcjd_app_cod_deg_rot0=jd;
	/* --- */
	tel->utcjd_cat_cod_deg_ra0=jd;
	tel->utcjd_cat_cod_deg_dec0=jd;
	/* --- */
	tel->utcjd_app_sim_adu_dec0=jd;
	tel->utcjd_app_sim_adu_ha0=jd;
	tel->utcjd_app_sim_adu_az0=jd;
	tel->utcjd_app_sim_adu_elev0=jd;
	tel->utcjd_app_sim_adu_rot0=jd;
	/* --- */
	tel->utcjd_app_cod_adu_dec0=jd;
	tel->utcjd_app_cod_adu_ha0=jd;
	tel->utcjd_app_cod_adu_az0=jd;
	tel->utcjd_app_cod_adu_elev0=jd;
	tel->utcjd_app_cod_adu_rot0=jd;
}

/******************************************************************************/
/* Set all utcjd current coordinates to the current date (motors are stopped) */
/******************************************************************************/
void mytel_app_setutcjd_now(struct telprop *tel) {
   time_t ltime;
   double jd;
	jd=mytel_sec2jd(time(&ltime));
	/* --- */
	tel->utcjd_app_sim_deg_ra=jd;
	tel->utcjd_app_sim_deg_dec=jd;
	tel->utcjd_app_sim_deg_ha=jd;
	tel->utcjd_app_sim_deg_az=jd;
	tel->utcjd_app_sim_deg_elev=jd;
	tel->utcjd_app_sim_deg_rot=jd;
	/* --- */
	tel->utcjd_app_cod_deg_ra=jd;
	tel->utcjd_app_cod_deg_dec=jd;
	tel->utcjd_app_cod_deg_ha=jd;
	tel->utcjd_app_cod_deg_az=jd;
	tel->utcjd_app_cod_deg_elev=jd;
	tel->utcjd_app_cod_deg_rot=jd;
	/* --- */
	tel->utcjd_cat_cod_deg_ra=jd;
	tel->utcjd_cat_cod_deg_dec=jd;
	/* --- */
	tel->utcjd_app_sim_adu_dec=jd;
	tel->utcjd_app_sim_adu_ha=jd;
	tel->utcjd_app_sim_adu_az=jd;
	tel->utcjd_app_sim_adu_elev=jd;
	tel->utcjd_app_sim_adu_rot=jd;
	tel->utcjd_app_sim_adu_hapec=jd;
	/* --- */
	tel->utcjd_app_cod_adu_dec=jd;
	tel->utcjd_app_cod_adu_ha=jd;
	tel->utcjd_app_cod_adu_az=jd;
	tel->utcjd_app_cod_adu_elev=jd;
	tel->utcjd_app_cod_adu_rot=jd;
}

/******************************************************************************/
/* Set adu increments to prepare a goto */
/******************************************************************************/
void mytel_app_cod_setdadu(struct telprop *tel) {
	double ang1,ang0,dang;
	// --- les ha sont comprises entre 0 et 360 deg
	// start angle = ang0
	ang0=fmod(720+telthread->coord_app_cod_deg_ha,360);
	// arrive angle = ang1
	ang1=fmod(720+telthread->ha0,360);
	if ((ang1<180)&&(ang0>180)) {
		// start before meridian, arrive after meridian
		dang=ang1+360-ang0;
	} else if ((ang1>180)&&(ang0>180)) {
		// start before meridian, arrive before meridian
		dang=ang1-ang0;
	} else if ((ang1<180)&&(ang0<180)) {
		// start after meridian, arrive after meridian
		dang=ang1-ang0;
	} else if ((ang1>180)&&(ang0<180)) {
		// start after meridian, arrive before meridian
		dang=ang1-360-ang0;
	}
	tel->coord_app_cod_adu_dha=dang/360.*tel->N0;
	// --- les dec sont comprises entre -90 et +90 deg
	// start angle = ang0
	ang0=telthread->coord_app_cod_deg_dec;
	if (ang0>90) { ang0=90; }
	if (ang0<-90) { ang0=-90; }
	// arrive angle = ang1
	ang1=telthread->dec0;
	if (ang1>90) { ang1=90; }
	if (ang1<-90) { ang1=-90; }
	dang=ang1-ang0;
	tel->coord_app_cod_adu_ddec=dang/360.*tel->N1;
	tel->coord_app_cod_adu_daz=0;
	tel->coord_app_cod_adu_delev=0;
	tel->coord_app_cod_adu_drot=0;
}

/******************************************************************************/
/* Set adu increments to prepare a goto for the simulator */
/******************************************************************************/
void mytel_app_sim_setdadu(struct telprop *tel) {
	double ang1,ang0,dang;
	// --- les ha sont comprises entre 0 et 360 deg
	// start angle = ang0
	ang0=fmod(720+telthread->coord_app_sim_deg_ha,360);
	// arrive angle = ang1
	ang1=fmod(720+telthread->ha0,360);
	if ((ang1<180)&&(ang0>180)) {
		// start before meridian, arrive after meridian
		dang=ang1+360-ang0;
	} else if ((ang1>180)&&(ang0>180)) {
		// start before meridian, arrive before meridian
		dang=ang1-ang0;
	} else if ((ang1<180)&&(ang0<180)) {
		// start after meridian, arrive after meridian
		dang=ang1-ang0;
	} else if ((ang1>180)&&(ang0<180)) {
		// start after meridian, arrive before meridian
		dang=ang1-360-ang0;
	}
	tel->coord_app_sim_adu_dha=dang/360.*tel->N0;
	// --- les dec sont comprises entre -90 et +90 deg
	// start angle = ang0
	ang0=telthread->coord_app_sim_deg_dec;
	if (ang0>90) { ang0=90; }
	if (ang0<-90) { ang0=-90; }
	// arrive angle = ang1
	ang1=telthread->dec0;
	if (ang1>90) { ang1=90; }
	if (ang1<-90) { ang1=-90; }
	dang=ang1-ang0;
	tel->coord_app_sim_adu_ddec=dang/360.*tel->N1;
	tel->coord_app_sim_adu_daz=0;
	tel->coord_app_sim_adu_delev=0;
	tel->coord_app_sim_adu_drot=0;
	//
	tel->speed_app_sim_adu_ha=2;
	if (tel->coord_app_sim_adu_dha>0) {
		tel->speed_app_sim_adu_ha*=-1;
	}
	tel->speed_app_sim_adu_dec=2;
	if (tel->coord_app_sim_adu_ddec>0) {
		tel->speed_app_sim_adu_dec*=-1;
	}
	tel->speed_app_sim_adu_ra=0;
	tel->speed_app_sim_adu_az=0; // a calculer
	tel->speed_app_sim_adu_elev=0; // a calculer
	tel->speed_app_sim_adu_rot=0; // a calculer
}

/******************************************************************************/
/* Set speeds to the motors for take count for corrections (Pec, altaz, etc.) */
/******************************************************************************/
void mytel_speed_corrections(struct telprop *tel) {
}

/* ================================================================ */
/* Fonctions speciales MCMT                                         */
/* ================================================================ */
#if defined CONTROLLER_TELSIMU

int mytel_limites(void) {
	return 0;
}

int mytel_motor_move_start(struct telprop *tel) {
	//char s[1024];
	if ((tel->move_direction[0]=='n')||(tel->move_direction[0]=='N')) {
		if (tel->status==STATUS_MOVE_SLOW) {
		} else if (tel->status==STATUS_MOVE_MEDIUM) {
		} else {
		}
	}
	if ((tel->move_direction[0]=='s')||(tel->move_direction[0]=='S')) {
		if (tel->status==STATUS_MOVE_SLOW) {
		} else if (tel->status==STATUS_MOVE_MEDIUM) {
		} else {
		}
	}
	if ((tel->move_direction[0]=='w')||(tel->move_direction[0]=='W')) {
		if (tel->status==STATUS_MOVE_SLOW) {
		} else if (tel->status==STATUS_MOVE_MEDIUM) {
		} else {
		}
	}
	if ((tel->move_direction[0]=='e')||(tel->move_direction[0]=='E')) {
		if (tel->status==STATUS_MOVE_SLOW) {
		} else if (tel->status==STATUS_MOVE_MEDIUM) {
		} else {
		}
	}
	return 0;
}

int mytel_motor_move_stop(struct telprop *tel) {
	//char s[1024];
	if ((tel->move_direction[0]=='n')||(tel->move_direction[0]=='N')||(tel->move_direction[0]=='s')||(tel->move_direction[0]=='S')) {
		if ((tel->status==STATUS_MOVE_SLOW)&&(telthread->motor!=MOTOR_STOPED)) {
		} else {
		}
	} else if ((tel->move_direction[0]=='e')||(tel->move_direction[0]=='E')||(tel->move_direction[0]=='w')||(tel->move_direction[0]=='W')) {
		if ((tel->status==STATUS_MOVE_SLOW)&&(telthread->motor!=MOTOR_STOPED)) {
		} else {
		}
	} else {
		if ((tel->status==STATUS_MOVE_SLOW)&&(telthread->motor!=MOTOR_STOPED)) {
		} else {
		}
	}
	return 0;
}

int mytel_motor_stop(struct telprop *tel) {
	//char s[1024];
	// stop slewing
	return 0;
}

int mytel_motor_off(struct telprop *tel) {
	//char s[1024];
	// stop sideral drift
	return 0;
}

int mytel_motor_on(struct telprop *tel) {
	//char s[1024];
	// start sideral drift
	return 0;
}

int mytel_tcl_procs(struct telprop *tel) {
   Tcl_DString dsptr;
	char s[1024];
	/* --- */
	Tcl_DStringInit(&dsptr);
	sprintf(s,"proc envoi { command } {\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   puts -nonewline %s $command ; flush %s\n",telthread->channel,telthread->channel);Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   after %d\n",telthread->tempo);Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   set res [string trim [read %s]]\n",telthread->channel);Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"   return $res\n");Tcl_DStringAppend(&dsptr,s,-1);
	sprintf(s,"}\n");Tcl_DStringAppend(&dsptr,s,-1);
	mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
	/* --- */
	return 1;
}

int mytel_flush(struct telprop *tel) {
	char s[50];
	sprintf(s,"flush %s ",telthread->channel); mytel_tcleval(telthread,s);
	return 1;
}

#endif
