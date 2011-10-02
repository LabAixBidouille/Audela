/* telescop.h
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

#ifndef __TELESCOP_H__
#define __TELESCOP_H__

#include <tcl.h>
#include <libtel/libstruc.h>

/*
 * Donnees propres a chaque telescope.
 */

#define MODE_SIMULATION 0
#define MODE_REEL 1

#define STATUS_MOTOR_OFF 0
#define STATUS_MOTOR_ON 1

#define MOUCHARD

typedef struct {
   int type;
	int posinit;
	double angleinit;
	double angleturnback; // angle de rebroussement pour GOTO
	double angleover; // limite au dela de l'angle de rebroussement pour l'arret du suivi
	double angleovered; // -2, -1,0,+1 , +2 selon que le suivi a depasse l'angle de rebroussement ou la limite au dela
	int sens;
	double jdinit;
} axis_params;

/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
	int compteur;
   char home[50];
   char home0[50];
	int mode;
	int status;
	int error;
	char action_next[80];
	char action_cur[80];
	char action_prev[80];
	double last_goto_raJ2000;
	double last_goto_decJ2000;
	double jdcalcul;
	double jdstopped;
	double app_ra; 
	double app_dec;
	double app_ha;
	double app_az;
	double app_elev;
	double app_rot;
	double app_ra_adu; 
	double app_dec_adu;
	double app_ha_adu;
	double app_az_adu;
	double app_elev_adu;
	double app_rot_adu;
	double app_ra_stopped; 
	double app_dec_stopped;
	double app_ha_stopped;
	double app_az_stopped;
	double app_elev_stopped;
	double app_rot_stopped;
	double coord_raJ2000;
	double coord_decJ2000;
	char appcoord[1024];
	char loopThreadId[20];
   int tempo;
};

int tel_init(struct telprop *tel, int argc, char **argv);
int tel_goto(struct telprop *tel);
int tel_coord(struct telprop *tel,char *result);
int tel_testcom(struct telprop *tel);
int tel_close(struct telprop *tel);
int tel_radec_init(struct telprop *tel);
int tel_radec_goto(struct telprop *tel);
int tel_radec_state(struct telprop *tel,char *result);
int tel_radec_coord(struct telprop *tel,char *result);
int tel_radec_move(struct telprop *tel,char *direction);
int tel_radec_stop(struct telprop *tel,char *direction);
int tel_radec_motor(struct telprop *tel);
int tel_focus_init(struct telprop *tel);
int tel_focus_goto(struct telprop *tel);
int tel_focus_coord(struct telprop *tel,char *result);
int tel_focus_move(struct telprop *tel,char *direction);
int tel_focus_stop(struct telprop *tel,char *direction);
int tel_focus_motor(struct telprop *tel);
int tel_date_get(struct telprop *tel,char *ligne);
int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int tel_home_get(struct telprop *tel,char *ligne);
int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);

int mytel_radec_init(struct telprop *tel);
int mytel_hadec_init(struct telprop *tel);
int mytel_radec_init_additional(struct telprop *tel);
int mytel_radec_goto(struct telprop *tel);
int mytel_hadec_goto(struct telprop *tel);
int mytel_radec_state(struct telprop *tel,char *result);
int mytel_radec_coord(struct telprop *tel,char *result);
int mytel_hadec_coord(struct telprop *tel,char *result);
int mytel_radec_move(struct telprop *tel,char *direction);
int mytel_radec_stop(struct telprop *tel,char *direction);
int mytel_radec_motor(struct telprop *tel);
int mytel_focus_init(struct telprop *tel);
int mytel_focus_goto(struct telprop *tel);
int mytel_focus_coord(struct telprop *tel,char *result);
int mytel_focus_move(struct telprop *tel,char *direction);
int mytel_focus_stop(struct telprop *tel,char *direction);
int mytel_focus_motor(struct telprop *tel);
int mytel_date_get(struct telprop *tel,char *ligne);
int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int mytel_home_get(struct telprop *tel,char *ligne);
int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);
int mytel_init_mount_default(struct telprop *tel,int mountno);

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);
int mytel_correct(struct telprop *tel,char *direction, int duration);

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout);
void mytel_error(struct telprop *tel,int axisno, int err);
int etel_home(struct telprop *tel, char *home_default);
double etel_tsl(struct telprop *tel,int *h, int *m,int *sec);
void etel_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function);
void etel_radec_coord(struct telprop *tel, int flagha, int *voidangles,double *angledegs,int *angleucs);

int mytel_get_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int *val);
int mytel_execute_command(struct telprop *tel,int axisno,int cmd,int nparams,int typ,int conv,double val);
int mytel_set_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int val);
void mytel_tel2cat(struct telprop *tel, double jd, double coord1, double coord2, double *raJ2000, double *decJ2000);
void mytel_cat2tel(struct telprop *tel, double jd, double raJ2000, double decJ2000);
void mytel_coord_stopped(struct telprop *tel);
int mytel_loadparams(struct telprop *tel,int naxisno);
int mytel_limites(void);

int mytel_convert_base(struct telprop *tel, char *nombre, char *basein, char *baseout, char *result);

// --- thread
struct telprop *telthread;
int ThreadMcmt_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int ThreadMcmt_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int CmdThreadMcmt_radec_init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int CmdThreadMcmt_radec_coord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int CmdThreadMcmt_radec_goto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int CmdThreadMcmt_appcoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif

