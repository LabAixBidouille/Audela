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

/* ========================================================= */
/* This driver is based on an infinite loop that update      */
/* continuously coordinate variables. This loop allows       */
/* to send commands to the mount controler without any       */
/* external action. This is important for speed of motor     */
/* for altaz mount or for periodic error corrections (PEC).  */
/* ========================================================= */
/*
DRIVER INITIALISATION ENTRY POINT (tel::create mcmt COM1)
	tel_init
		ThreadT940_Init
			Open physical connections
			Tcl_CreateCommand CmdThreadT940_loopeval,...
			Then it calls ThreadT940_loop

MAIN LOOP
   ThreadT940_loop
		periodic actions are done according to telthread->action_next
		mutex is not locked

GET HA,DEC COORDS (tel1 hadec coord)
	cmdTelHaDec (defined in teltcl.c)
		mytel_hadec_coord(tel,ligne) (defined in telescope.c)
		   my_pthread_mutex_lock(&mutex);
			...
			my_pthread_mutex_unlock(&mutex);
		Tcl_Eval(interp,ligne);

*/


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
   f=fopen("mouchard_t940.txt","wt");
   fprintf(f,"Demarre une init\n");
	fclose(f);
#endif
	/* - ce clock format permet de debloquer les prochains acces a cette fonction - */
   Tcl_Eval(tel->interp,"clock format 1318667930");

	/* - creates mutex -*/
   pthread_mutexattr_init(&mutexAttr);
   pthread_mutexattr_settype(&mutexAttr, PTHREAD_MUTEX_RECURSIVE);
   pthread_mutex_init(&mutex, &mutexAttr);

   Tcl_CreateCommand(tel->interp,"ThreadT940_Init", (Tcl_CmdProc *)ThreadT940_Init, (ClientData)NULL, NULL);
   if (Tcl_Eval(tel->interp, "thread::create { thread::wait } ") == TCL_OK) {
		//MessageBox(NULL,"Thread créé","LibT940",MB_OK);
		strcpy(tel->loopThreadId, tel->interp->result);
      sprintf(s,"thread::copycommand %s ThreadT940_Init ",tel->loopThreadId);
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
		sprintf(s,"thread::send %s {ThreadT940_Init", tel->loopThreadId);
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
   f=fopen("mouchard_t940.txt","at");
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
	//char s[1024];
   my_pthread_mutex_lock(&mutex);
	telthread->ra0=tel->ra0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"radec_goto");
   my_pthread_mutex_unlock(&mutex);
   return 0;
	/*
   if (tel->radec_goto_blocking==1) {
		libtel_sleep(500);
		while (strcmp(telthread->action_cur,"goto")==0) {
		   my_pthread_mutex_unlock(&mutex);
			libtel_sleep(500);
			my_pthread_mutex_lock(&mutex);
		}
	}
   my_pthread_mutex_unlock(&mutex);
	*/
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
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   my_pthread_mutex_lock(&mutex);
	if (telthread->mode==MODE_REEL) {
		// --- stop motors
		mytel_motor_stop(telthread);
	}
	strcpy(telthread->action_next,"motor_off");
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
	sprintf(result,"{%f %f %f} {%f %f %f}",telthread->coord_app_cod_adu_ha,telthread->coord_app_cod_adu_dec,telthread->coord_app_cod_adu_hapec,telthread->coord_app_sim_adu_ha,telthread->coord_app_sim_adu_dec,telthread->coord_app_sim_adu_hapec);
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
// ::tel::create t940 -mode 0 -axis1 4 -axis2 5
int ThreadT940_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char s[1024];
	int err,kk;
	int axisno,kaxisno;
	int threadpb=0;
	int axis[3];

	telthread = (struct telprop*) calloc( 1, sizeof(struct telprop) );
	
	telthread->interp = interp;

	// decode les arguments
	telthread->mode = MODE_REEL;
   telthread->type_mount=MOUNT_ALTAZ;
	strcpy(telthread->alignmentMode,"ALTAZ");
	axis[0]=0;
	axis[1]=1; //4
	axis[2]=2; //5
	if (argc >= 1) {
		for (kk = 0; kk < argc-1; kk++) {
			// mode : 0=simulation 1=reel 2=simuEtel
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

	telthread->tempo = 50;
	telthread->sideral_sep_per_day=86164;
	// init home (important ici pour le calcul des positions initiales)
	strcpy(telthread->home,"GPS 1.7187 E 43.8740 220");
	strcpy(telthread->home0,telthread->home);
	strcpy(telthread->homePosition,telthread->home);

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
			sprintf(s,"etb:dummy:7:6:19366144:4:0",axis[kaxisno]);
			//sprintf(s,"etb:DSTEB3:%d",axis[kaxisno]);
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
	} else if (telthread->mode == MODE_SIMULATION_ETEL) {
		for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
			axisno=telthread->axes[kaxisno];
			// create drive
			if (err = dsa_create_drive(&telthread->drv[axisno])) {
				mytel_error(telthread,axisno,err);
				return 1;
			}
			sprintf(s,"etb:dummy:1:6:19366144:4:0");
			if (err = dsa_open_u(telthread->drv[axisno],s)) {
				if (kaxisno==0) {
					mytel_error(telthread,axisno,err);
					sprintf(s," {etb:dummy axisno=%d}",axisno);
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

	if (telthread->mode == MODE_SIMULATION_ETEL) {
		telthread->mode = MODE_REEL;
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
	
	// open connections
	if (telthread->mode == MODE_REEL) {

		telthread->N0=(long)telthread->axis_param[AXIS_AZ].coef_xs*360;
		telthread->N1=(long)telthread->axis_param[AXIS_ELEV].coef_xs*360;
		
		// initial position from coders
		telthread->coord_app_cod_deg_ha=0;
		telthread->coord_app_cod_deg_dec=0;
		mytel_app_cod_setadu0(telthread);
		mytel_app2cat_cod_deg0(telthread);
		mytel_app_cod_getadu(telthread);
		mytel_app_cod_adu2deg(telthread);
		mytel_app2cat_cod_deg(telthread);
		mytel_tcl_procs(telthread);

	} else {

		telthread->N0=(long)telthread->axis_param[AXIS_AZ].coef_xs*360;
		telthread->N1=(long)telthread->axis_param[AXIS_ELEV].coef_xs*360;
		telthread->coord_app_sim_adu_cumdha=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumddec=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumdaz=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumdelev=0; // cumulative gotos ADU from/to coder
		telthread->coord_app_sim_adu_cumdrot=0; // cumulative gotos ADU from/to coder
		mytel_tcl_procs(telthread);

	}


	// initial position from coders for simulation
	telthread->coord_app_sim_deg_ha0=0;
	telthread->coord_app_sim_deg_dec0=0;
	telthread->coord_app_sim_adu_ha=0;
	telthread->coord_app_sim_adu_dec=0;
	telthread->coord_app_sim_adu_hapec=0;
	telthread->coord_app_sim_adu_az=(int)pow(2,30);
	telthread->coord_app_sim_adu_elev=(int)pow(2,30);
	telthread->coord_app_sim_adu_rot=(int)pow(2,30);
	telthread->coord_app_sim_adu_hapec=0;
	mytel_app_setutcjd0_now(telthread);
	mytel_app_setutcjd_now(telthread);
	mytel_app_sim_setadu0(telthread);
	mytel_app_sim_adu2deg(telthread);
	mytel_app2cat_sim_deg(telthread);

	strcpy(telthread->action_prev, "");
	strcpy(telthread->action_next, "motor_off");
	strcpy(telthread->action_cur, "undefined");
	telthread->status = STATUS_MOTOR_OFF;
	telthread->compteur = 0;

	// Creation des commandes effectuees a la fin d'une action de la grande boucle
	Tcl_CreateCommand(telthread->interp,"CmdThreadT940_loopeval", (Tcl_CmdProc *)CmdThreadT940_loopeval, (ClientData)telthread, NULL);

	// initialisation des commandes tcl necessaires au fonctionnement en boucle.
	Tcl_CreateCommand(telthread->interp,"ThreadT940_loop", (Tcl_CmdProc *)ThreadT940_loop, (ClientData)telthread, NULL);
	mytel_tcleval(telthread,"proc TT940_Loop {} { ThreadT940_loop ; after 250 TT940_Loop }");
	// Lance le fonctionnement en boucle.
	mytel_tcleval(telthread,"TT940_Loop");

	return 0;
}

/************************/
/*** Boucle du thread ***/
/************************/
int ThreadT940_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	int action_ok=0;
//	double jdnow,jdinit,dt;
//	double raJ2000,decJ2000;
//	char s[1024],ss[1024];
	char action_locale[80];
//   time_t ltime;

   my_pthread_mutex_lock(&mutex);
	strcpy(action_locale,telthread->action_next);

	telthread->compteur++;
	telthread->error=0;
	action_ok=1;
   if (strcmp(action_locale,"motor_off")==0) {
		/*****************/
	   /*** motor_off ***/
		/*****************/
		// === stop motors only if the previous action is not motor_off
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			if (telthread->mode==MODE_REEL) {
				// --- stop motors
				mytel_motor_stop(telthread);
				// --- read adu from coders
				mytel_app_cod_getadu(telthread);
				// --- convert adu to deg
				mytel_app_cod_adu2deg(telthread);
				// --- convert apparent to catalog degs
				mytel_app2cat_cod_deg(telthread);
				// --- store catalog ra,dec coordinates a new initial ones
				telthread->coord_cat_cod_deg_ra0=telthread->coord_cat_cod_deg_ra;
				telthread->coord_cat_cod_deg_dec0=telthread->coord_cat_cod_deg_dec;
			}
			telthread->status=STATUS_MOTOR_OFF;
			// --- stop simulation motors
			// --- compute adu as from coders
			mytel_app_sim_getadu(telthread);
			// --- convert adu to deg
			mytel_app_sim_adu2deg(telthread);
			// --- convert apparent to catalog degs
			mytel_app2cat_sim_deg(telthread);
			// --- store catalog ra,dec coordinates a new initial ones
			telthread->coord_cat_sim_deg_ra0=telthread->coord_cat_sim_deg_ra;
			telthread->coord_cat_sim_deg_dec0=telthread->coord_cat_sim_deg_dec;
		}
		// === update coordinate systems
		// --- update the initial coord dates to be equal to the current date
		mytel_app_setutcjd0_now(telthread);
		// --- update the current coord dates equal to the current date
		mytel_app_setutcjd_now(telthread);
		if (telthread->mode==MODE_REEL) {
			// --- update the initial adus to be equal to the last current adus
			mytel_app_cod_setadu0(telthread);
			// --- get the current real adus
			mytel_app_cod_getadu(telthread);
			// --- convert apparent to catalog degs
			mytel_app2cat_cod_deg(telthread);
		}
		// --- update the initial adus to be equal to the last current adus
		mytel_app_sim_setadu0(telthread);
		// --- compute the current simulated adus
		mytel_app_sim_getadu(telthread);
		// --- convert apparent to catalog degs
		mytel_app2cat_sim_deg(telthread);
	} else if (strcmp(action_locale,"motor_on")==0) {
		/****************/
	   /*** motor_on ***/
		/****************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la mise en route des moteurs que si ils n'ont pas encore été lancés
			if (telthread->mode==MODE_REEL) {
			}
		}
		strcpy(telthread->action_cur,action_locale);
		telthread->status=STATUS_MOTOR_ON;
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
		// --- faire ici les corrections de Pec
		// --- on arrete les moteurs en cas de depassement des limites ---
		mytel_limites();
		strcpy(telthread->action_prev,action_locale);
		/*
		if (((int)fabs(telthread->axis_param[AXIS_AZ].angleovered)==2)||((int)fabs(telthread->axis_param[AXIS_PARALLACTIC].angleovered)==2)||((int)fabs(telthread->axis_param[AXIS_HA].angleovered)==2)) {
			strcpy(telthread->action_next,"motor_off");
		}
		*/
	} else if (strcmp(action_locale,"hadec_init")==0) {
		/******************/
	   /*** hadec_init ***/
		/******************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			telthread->coord_app_cod_deg_ha0=telthread->ha0;
			telthread->coord_app_cod_deg_dec0=telthread->dec0;
			telthread->coord_app_sim_deg_ha0=telthread->ha0;
			telthread->coord_app_sim_deg_dec0=telthread->dec0;
			if (telthread->mode==MODE_REEL) {
				// --- update coordinates from coders
				mytel_app_cod_getadu(telthread);
				mytel_app_cod_setadu0(telthread);
				mytel_app2cat_cod_deg0(telthread);
			}
			// --- update coordinates for simulator
			mytel_app_sim_getadu(telthread);
			mytel_app_sim_setadu0(telthread);
			mytel_app2cat_sim_deg0(telthread);
		}
		// on remet l'action precedente pour la prochain tour de boucle
		strcpy(telthread->action_next,telthread->action_prev);
	} else if (strcmp(action_locale,"radec_init")==0) {
		/******************/
	   /*** radec_init ***/
		/******************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			telthread->coord_app_cod_deg_ra0=telthread->ra0;
			telthread->coord_app_cod_deg_dec0=telthread->dec0;
			telthread->coord_app_sim_deg_ra0=telthread->ra0;
			telthread->coord_app_sim_deg_dec0=telthread->dec0;
			if (telthread->mode==MODE_REEL) {
				// --- update coordinates from coders
				mytel_app_cod_getadu(telthread);
				mytel_app_cod_setadu0(telthread);
				mytel_cat2app_cod_deg0(telthread);
			}
			// --- update coordinates for simulator
			mytel_app_sim_getadu(telthread);
			mytel_app_sim_setadu0(telthread);
			mytel_cat2app_sim_deg0(telthread);
		}
		// on remet l'action precedente pour la prochain tour de boucle
		strcpy(telthread->action_next,telthread->action_prev);
	} else if (strcmp(action_locale,"hadec_goto")==0) {
		/******************/
	   /*** hadec_goto ***/
		/******************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			// --- stop
			if (telthread->mode==MODE_REEL) {
				// --- stop motors
				mytel_motor_stop(telthread);
				mytel_app_cod_getadu(telthread);
				mytel_app_cod_adu2deg(telthread);
				mytel_app2cat_cod_deg(telthread);
				telthread->coord_cat_cod_deg_ra0=telthread->coord_cat_cod_deg_ra;
				telthread->coord_cat_cod_deg_dec0=telthread->coord_cat_cod_deg_dec;
			}
			// --- stop simulation motors
			mytel_app_sim_getadu(telthread);
			mytel_app_sim_adu2deg(telthread);
			mytel_app2cat_sim_deg(telthread);
			telthread->coord_cat_sim_deg_ra0=telthread->coord_cat_sim_deg_ra;
			telthread->coord_cat_sim_deg_dec0=telthread->coord_cat_sim_deg_dec;
			// --- goto
			if (telthread->mode==MODE_REEL) {
				mytel_app_cod_setdadu(telthread);
				// --- send goto
				mytel_app_cod_setadu(telthread);
			}
			// --- update coordinates for simulator
			mytel_app_sim_setdadu(telthread);
			mytel_app_sim_setadu(telthread);
		}
		// on impose l'action motor_off pour le prochain tour de boucle
		strcpy(telthread->action_next,"motor_off");
	} else if (strcmp(action_locale,"radec_goto")==0) {
		/******************/
	   /*** radec_goto ***/
		/******************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			// --- stop
			if (telthread->mode==MODE_REEL) {
				// --- stop motors
				mytel_motor_stop(telthread);
				mytel_app_cod_getadu(telthread);
				mytel_app_cod_adu2deg(telthread);
				mytel_app2cat_cod_deg(telthread);
				telthread->coord_cat_cod_deg_ra0=telthread->coord_cat_cod_deg_ra;
				telthread->coord_cat_cod_deg_dec0=telthread->coord_cat_cod_deg_dec;
			}
			// --- stop simulation motors
			mytel_app_sim_getadu(telthread);
			mytel_app_sim_adu2deg(telthread);
			mytel_app2cat_sim_deg(telthread);
			telthread->coord_cat_sim_deg_ra0=telthread->coord_cat_sim_deg_ra;
			telthread->coord_cat_sim_deg_dec0=telthread->coord_cat_sim_deg_dec;
			// --- goto
			if (telthread->mode==MODE_REEL) {
				mytel_app_cod_setdadu(telthread);
				// --- send goto
				mytel_app_cod_setadu(telthread);
			}
			// --- update coordinates for simulator
			mytel_app_sim_setdadu(telthread);
			mytel_app_sim_setadu(telthread);
		}
		// on impose l'action motor_on pour le prochain tour de boucle
		strcpy(telthread->action_next,"motor_on");
	} else if (strcmp(action_locale,"move_n")==0) {
		/**************/
	   /*** move_n ***/
		/**************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			strcpy(telthread->action_cur,action_locale);
			if (telthread->mode==MODE_REEL) {
			}
		}
	} else if (strcmp(action_locale,"move_s")==0) {
		/**************/
	   /*** move_s ***/
		/**************/
		if (strcmp(telthread->action_cur,action_locale)!=0) {
			// actionne la fonction que si elle n'a pas encore été lancée
			strcpy(telthread->action_cur,action_locale);
			if (telthread->mode==MODE_REEL) {
			}
		}
	} else if ((strcmp(action_locale,"move_n_stop")==0)||(strcmp(action_locale,"move_s_stop")==0)) {
		/**********************************/
	   /*** move_n_stop OR move_s_stop ***/
		/**********************************/
		strcpy(telthread->action_cur,action_locale);
		if (telthread->mode==MODE_REEL) {
		}
	} else {
		action_ok=0;
	}
	if (action_ok==1) {
		strcpy(telthread->action_prev,action_locale);
		strcpy(telthread->action_cur,action_locale);
	}
	my_pthread_mutex_unlock(&mutex);

	return TCL_OK;
}

/******************************
 *** CmdThreadT940_loopeval ***
 ******************************/
int CmdThreadT940_loopeval(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
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
   f=fopen("mouchard_t940.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD_EVAL)
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
#if defined(MOUCHARD)
	FILE *f;
#endif
	err = dsa_get_register_s(tel->drv[axisno],typ,idx,sidx,val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT);
#if defined(MOUCHARD)
   f=fopen("mouchard_t940.txt","at");
   fprintf(f,"dsa_get_register_s(%d=>axe%d,%d,%d,%d) => %d\n",tel->drv[axisno],axisno,typ,idx,sidx,*val);
	fclose(f);
#endif
	return err;
}

int mytel_set_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int val) {
	int err;
#if defined(MOUCHARD)
	FILE *f;
#endif
	err = dsa_set_register_s(tel->drv[axisno],typ,idx,sidx,val,DSA_DEF_TIMEOUT);
#if defined(MOUCHARD)
   f=fopen("mouchard_t940.txt","at");
   fprintf(f,"dsa_set_register_s(%d=>axe%d,%d,%d,%d,%d)\n",tel->drv[axisno],axisno,typ,idx,sidx,val);
	fclose(f);
#endif
	return err;
}

int mytel_execute_command(struct telprop *tel,int axisno,int cmd,int nparams,int typ,int conv,double val) {
	int err;
#if defined(MOUCHARD)
	FILE *f;
#endif
	DSA_COMMAND_PARAM params[] = { {0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0} };
	params[0].typ=typ;
	params[0].conv=conv;
	if (params[0].conv==0) {
		params[0].val.i=(int)(val);
	} else {
		params[0].val.d=val;
	}
#if defined(MOUCHARD)
   f=fopen("mouchard_t940.txt","at");
   fprintf(f,"dsa_execute_command_x_s(%d=>axe%d,%d,%d,%d)\n",tel->drv[axisno],axisno,cmd,params[0].val.i,nparams);
	fclose(f);
#endif
	err = dsa_execute_command_x_s(tel->drv[axisno],cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT);
	return err;
}

int my_pthread_mutex_lock (pthread_mutex_t * mutex) {
   return(pthread_mutex_lock(mutex));
}

int my_pthread_mutex_unlock (pthread_mutex_t * mutex) {
   return(pthread_mutex_unlock(mutex));
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
			if (err=mytel_execute_command(tel,axisno,26,1,0,0,77)) { mytel_error(tel,axisno,err); return 1; }
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

int mytel_motor_stop(struct telprop *tel) {
	//char s[1024];
	int axisno,kaxisno,err;
	double val;
	if (telthread->mode==MODE_REEL) {
		val=0;
		for (kaxisno=0;kaxisno<telthread->nb_axis;kaxisno++) {
			axisno=telthread->axes[kaxisno];
			if (err=mytel_set_register(telthread,axisno,ETEL_X,13,0,(int)val)) { mytel_error(telthread,axisno,err); }
			if (err=mytel_execute_command(telthread,axisno,26,1,0,0,72)) { mytel_error(telthread,axisno,err); }
		}
	}
	return 0;
}

int mytel_tcl_procs(struct telprop *tel) {
	/* --- */
	/*
   Tcl_DString dsptr;
	char s[1024];
	*/
	/* --- */
	/*
	Tcl_DStringInit(&dsptr);
	mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
	*/
	/* --- */
	return 1;
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
   time_t ltime;
   double jd,az,elev,ha,dec,rot;
	int err,axisno,val;
	/* --- */
	axisno=0;
	if (telthread->type_mount==MOUNT_ALTAZ) {
		if (err=mytel_get_register(telthread,AXIS_AZ,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
		az=(double)val;
		tel->utcjd_app_cod_adu_az=mytel_sec2jd((int)time(&ltime));			
		if (err=mytel_get_register(telthread,AXIS_ELEV,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
		elev=(double)val;
		tel->utcjd_app_cod_adu_elev=mytel_sec2jd((int)time(&ltime));			
		if (err=mytel_get_register(telthread,AXIS_PARALLACTIC,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
		rot=(double)val;
		tel->utcjd_app_cod_adu_rot=mytel_sec2jd((int)time(&ltime));			
		jd=mytel_sec2jd((int)time(&ltime));
		tel->coord_app_cod_adu_ha=0;
		tel->coord_app_cod_adu_dec=0;
		tel->utcjd_app_cod_adu_ha=jd;			
		tel->utcjd_app_cod_adu_dec=jd;	
	} else {
		if (err=mytel_get_register(telthread,AXIS_HA,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
		ha=(double)val;
		tel->coord_app_cod_adu_ha=ha;
		tel->utcjd_app_cod_adu_ha=mytel_sec2jd((int)time(&ltime));			
		if (err=mytel_get_register(telthread,AXIS_DEC,ETEL_M,7,0,&val)) { mytel_error(telthread,axisno,err); }
		dec=(double)val;
		tel->coord_app_cod_adu_dec=dec;
		tel->utcjd_app_cod_adu_dec=mytel_sec2jd((int)time(&ltime));	
		jd=mytel_sec2jd((int)time(&ltime));
		tel->coord_app_cod_adu_az=0;
		tel->coord_app_cod_adu_elev=0;
		tel->coord_app_cod_adu_rot=0;
		tel->utcjd_app_cod_adu_az=jd;
		tel->utcjd_app_cod_adu_elev=jd;
		tel->utcjd_app_cod_adu_rot=jd;
	}
	return 0;
}

/***************************************************************************/
/* Set the apparent coordinates from coders (adu) -> goto                  */
/***************************************************************************/
int mytel_app_cod_setadu(struct telprop *tel) {
	char s[1024],ss[1024],serial6[9],signe;
	int dadu;
   time_t ltime;
	/* --- */
	dadu=(int)tel->coord_app_cod_adu_dha;
	signe='0';
	if (dadu<0) {
		dadu=-dadu;
		signe='1';
	}
	sprintf(s,"set binar [convert_base \"%d\" 10 2] ; set binar [string repeat 0 [expr 32-[string length $binar]]]$binar",(int)dadu); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	strcpy(serial6,"00000000");
	if (ss[0] =='1') { serial6[4]='1'; ss[0] ='0'; }
	if (ss[8] =='1') { serial6[5]='1'; ss[8] ='0'; }
	if (ss[16]=='1') { serial6[6]='1'; ss[16]='0'; }
	if (ss[24]=='1') { serial6[7]='1'; ss[24]='0'; }
	serial6[4]=signe;
	sprintf(s,"set hexa [convert_base \"%s%s\" 2 16] ; set hexa [string repeat 0 [expr 10-[string length $hexa]]]$hexa",ss,serial6); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	sprintf(s,"E0 70 %c%c %c%c %c%c %c%c %c%c",ss[0],ss[1],ss[2],ss[3],ss[4],ss[5],ss[6],ss[7],ss[8],ss[9]);
	strcpy(ss,s);
	sprintf(s,"set envoi \"%s\" ; set res [envoi $envoi]",ss); mytel_tcleval(tel,s);
	strcat(ss,tel->interp->result);
	tel->utcjd_app_cod_adu_ha=mytel_sec2jd((int)time(&ltime));	
	/* --- */
	dadu=(int)tel->coord_app_cod_adu_ddec;
	signe='0';
	if (dadu<0) {
		dadu=-dadu;
		signe='1';
	}
	sprintf(s,"set binar [convert_base \"%d\" 10 2] ; set binar [string repeat 0 [expr 32-[string length $binar]]]$binar",(int)dadu); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	strcpy(serial6,"00000000");
	if (ss[0] =='1') { serial6[4]='1'; ss[0] ='0'; }
	if (ss[8] =='1') { serial6[5]='1'; ss[8] ='0'; }
	if (ss[16]=='1') { serial6[6]='1'; ss[16]='0'; }
	if (ss[24]=='1') { serial6[7]='1'; ss[24]='0'; }
	serial6[4]=signe;
	sprintf(s,"set hexa [convert_base \"%s%s\" 2 16] ; set hexa [string repeat 0 [expr 10-[string length $hexa]]]$hexa",ss,serial6); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	sprintf(s,"E0 71 %c%c %c%c %c%c %c%c %c%c",ss[0],ss[1],ss[2],ss[3],ss[4],ss[5],ss[6],ss[7],ss[8],ss[9]);
	strcpy(ss,s);
	sprintf(s,"set envoi \"%s\" ; set res [envoi $envoi]",ss); mytel_tcleval(tel,s);
	strcat(ss,tel->interp->result);
	tel->utcjd_app_cod_adu_dec=mytel_sec2jd((int)time(&ltime));	
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
   coord1 = tel->coord_app_cod_deg_ha0;
   coord2 = tel->coord_app_cod_deg_dec0;   
   jd=tel->utcjd_app_cod_deg_ha0;
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

/***************************************************************************/
/* Converts the apparent coordinates from adu to degrees                   */
/***************************************************************************/
void mytel_app_cod_adu2deg(struct telprop *tel) {
	double dadu,ddeg;
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

/***************************************************************************/
/* Converts the apparent coordinates into catalog for coders (deg)         */
/***************************************************************************/
void mytel_app2cat_cod_deg(struct telprop *tel) {
   char s[1024],ss[1024];
   double coord1, coord2, jd;
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

/***************************************************************************/
/* Converts the catalog coordinates into apparents for coders (deg)        */
/***************************************************************************/
void mytel_cat2app_cod_deg(struct telprop *tel, double jd) {
   char s[1024],ss[1024];
   double raJ2000,decJ2000;
	raJ2000=tel->coord_cat_cod_deg_ra;
	tel->utcjd_cat_cod_deg_ra=jd;
	decJ2000=tel->coord_cat_cod_deg_dec;
	tel->utcjd_cat_cod_deg_dec=jd;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients);
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
}

/***************************************************************************/
/* Converts the apparent coordinates from degrees to adu                   */
/***************************************************************************/
void mytel_app_cod_deg2adu(struct telprop *tel) {
	double dadu,ddeg;
	// tel->N0; // number of ADU for 360 deg
	ddeg=tel->coord_app_cod_deg_ha-tel->coord_app_cod_deg_ha0;
	dadu=ddeg/360*tel->N0;
	tel->coord_app_cod_adu_ha=tel->coord_app_cod_adu_ha0+dadu;
	tel->utcjd_app_cod_adu_ha=tel->utcjd_app_cod_deg_ha;
	ddeg=tel->coord_app_cod_deg_dec-tel->coord_app_cod_deg_dec0;
	dadu=ddeg/360*tel->N0;
	tel->coord_app_cod_adu_dec=tel->coord_app_cod_adu_dec0+dadu;
	tel->utcjd_app_cod_adu_dec=tel->utcjd_app_cod_deg_dec;
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
	tel->utcjd_app_sim_adu_ha=jd;	
	dsec=(jd-tel->utcjd_app_sim_adu_ha0)*86400.;
	tel->coord_app_sim_adu_ha=(int)(tel->coord_app_sim_adu_ha0+dsec/tel->sideral_sep_per_day*tel->N0+telthread->coord_app_sim_adu_cumdha);
	tel->utcjd_app_sim_adu_dec=jd;	
	dsec=(jd-tel->utcjd_app_sim_adu_dec0)*86400.;
	tel->coord_app_sim_adu_dec=tel->coord_app_sim_adu_dec0+telthread->coord_app_sim_adu_cumddec;
	dsec=(jd-tel->utcjd_app_sim_adu_hapec0)*86400.;	
	tel->coord_app_sim_adu_hapec=(int)(fmod(telthread->coord_app_sim_adu_hapec0+25600*dsec/480.,25600));
	tel->coord_app_sim_adu_az=0;
	tel->coord_app_sim_adu_elev=0;
	tel->coord_app_sim_adu_rot=0;
	tel->utcjd_app_sim_adu_az=jd;
	tel->utcjd_app_sim_adu_elev=jd;
	tel->utcjd_app_sim_adu_rot=jd;
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
   coord1 = tel->coord_app_sim_deg_ha0;
   coord2 = tel->coord_app_sim_deg_dec0;   
   jd=tel->utcjd_app_sim_deg_ha0;
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

/***************************************************************************/
/* Converts the apparent coordinates from adu to degrees (simulator)       */
/***************************************************************************/
void mytel_app_sim_adu2deg(struct telprop *tel) {
	double dadu,ddeg;
	// tel->N0; // number of ADU for 360 deg
	dadu=(tel->coord_app_sim_adu_ha-tel->coord_app_sim_adu_ha0);
	ddeg=dadu/tel->N0*360;
	tel->coord_app_sim_deg_ha=fmod(tel->coord_app_sim_deg_ha0+ddeg+720,360);
	tel->utcjd_app_sim_deg_ha=tel->utcjd_app_sim_adu_ha;
	dadu=(tel->coord_app_sim_adu_dec-tel->coord_app_sim_adu_dec0);
	ddeg=dadu/tel->N0*360;
	tel->coord_app_sim_deg_dec=tel->coord_app_sim_deg_dec0+ddeg;
	tel->utcjd_app_sim_deg_dec=tel->utcjd_app_sim_adu_dec;
}

/***************************************************************************/
/* Converts the apparent coordinates into catalog for simulator (deg)      */
/***************************************************************************/
void mytel_app2cat_sim_deg(struct telprop *tel) {
   char s[1024],ss[1024];
   double coord1, coord2, jd;
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

/***************************************************************************/
/* Converts the catalog coordinates into apparents for simulator (deg)     */
/***************************************************************************/
void mytel_cat2app_sim_deg(struct telprop *tel, double jd) {
   char s[1024],ss[1024];
   double raJ2000,decJ2000;
	raJ2000=tel->coord_cat_sim_deg_ra;
	tel->utcjd_cat_sim_deg_ra=jd;
	decJ2000=tel->coord_cat_sim_deg_dec;
	tel->utcjd_cat_sim_deg_dec=jd;
   sprintf(s, "mc_hip2tel { 1 1 %f %f J2000 J2000 0 0 0 } %f {%s} %d %d {%s} {%s}",raJ2000, decJ2000,jd, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature,tel->radec_model_symbols, tel->radec_model_coefficients);
	mytel_tcleval(tel,s);
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
}

/***************************************************************************/
/* Converts the apparent coordinates from degrees to adu (simulator)       */
/***************************************************************************/
void mytel_app_sim_deg2adu(struct telprop *tel) {
	double dadu,ddeg;
	// tel->N0; // number of ADU for 360 deg
	ddeg=tel->coord_app_sim_deg_ha-tel->coord_app_sim_deg_ha0;
	dadu=ddeg/360*tel->N0;
	tel->coord_app_sim_adu_ha=tel->coord_app_sim_adu_ha0+dadu;
	tel->utcjd_app_sim_adu_ha=tel->utcjd_app_sim_deg_ha;
	ddeg=tel->coord_app_sim_deg_dec-tel->coord_app_sim_deg_dec0;
	dadu=ddeg/360*tel->N0;
	tel->coord_app_sim_adu_dec=tel->coord_app_sim_adu_dec0+dadu;
	tel->utcjd_app_sim_adu_dec=tel->utcjd_app_sim_deg_dec;
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
	char s[1024],ss[1024],serial6[9],signe;
	int dadu;
   time_t ltime;
	/*
	set binar [convert_base 128000 10 2]
	set binar [string repeat 0 [expr 32-[string length $binar]]]$binar
	# 0000 0000 0000 0001 1111 0100 0000 0000 0000 1010
	# *         *         *         *         serial6
	set hexa [convert_base "0000 0000 0000 0001 0111 0100 0000 0000 0000 0010" 2 16]
	*/
	/* --- */
	dadu=(int)tel->coord_app_sim_adu_dha;
	signe='0';
	if (dadu<0) {
		dadu=-dadu;
		signe='1';
	}
	sprintf(s,"set binar [convert_base \"%d\" 10 2] ; set binar [string repeat 0 [expr 32-[string length $binar]]]$binar",(int)dadu); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	strcpy(serial6,"00000000");
	if (ss[0] =='1') { serial6[4]='1'; ss[0] ='0'; }
	if (ss[8] =='1') { serial6[5]='1'; ss[8] ='0'; }
	if (ss[16]=='1') { serial6[6]='1'; ss[16]='0'; }
	if (ss[24]=='1') { serial6[7]='1'; ss[24]='0'; }
	serial6[4]=signe;
	sprintf(s,"set hexa [convert_base \"%s%s\" 2 16] ; set hexa [string repeat 0 [expr 10-[string length $hexa]]]$hexa",ss,serial6); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	sprintf(s,"E0 70 %c%c %c%c %c%c %c%c %c%c",ss[0],ss[1],ss[2],ss[3],ss[4],ss[5],ss[6],ss[7],ss[8],ss[9]);
	strcpy(ss,s);
	//sprintf(s,"set envoi \"%s\" ; set res [envoi $envoi]",ss); mytel_tcleval(tel,s);
	//strcat(ss,tel->interp->result);
	tel->coord_app_sim_adu_cumdha+=tel->coord_app_sim_adu_dha;
	tel->utcjd_app_sim_adu_ha=mytel_sec2jd((int)time(&ltime));	
	/* --- */
	dadu=(int)tel->coord_app_sim_adu_ddec;
	signe='0';
	if (dadu<0) {
		dadu=-dadu;
		signe='1';
	}
	sprintf(s,"set binar [convert_base \"%d\" 10 2] ; set binar [string repeat 0 [expr 32-[string length $binar]]]$binar",(int)dadu); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	strcpy(serial6,"00000000");
	if (ss[0] =='1') { serial6[4]='1'; ss[0] ='0'; }
	if (ss[8] =='1') { serial6[5]='1'; ss[8] ='0'; }
	if (ss[16]=='1') { serial6[6]='1'; ss[16]='0'; }
	if (ss[24]=='1') { serial6[7]='1'; ss[24]='0'; }
	serial6[4]=signe;
	sprintf(s,"set hexa [convert_base \"%s%s\" 2 16] ; set hexa [string repeat 0 [expr 10-[string length $hexa]]]$hexa",ss,serial6); mytel_tcleval(tel,s);
	strcpy(ss,tel->interp->result);
	sprintf(s,"E0 71 %c%c %c%c %c%c %c%c %c%c",ss[0],ss[1],ss[2],ss[3],ss[4],ss[5],ss[6],ss[7],ss[8],ss[9]);
	strcpy(ss,s);
	//sprintf(s,"set envoi \"%s\" ; set res [envoi $envoi]",ss); mytel_tcleval(tel,s);
	//strcat(ss,tel->interp->result);
	tel->coord_app_sim_adu_cumddec+=tel->coord_app_sim_adu_ddec;
	tel->utcjd_app_sim_adu_dec=mytel_sec2jd((int)time(&ltime));	
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
}
