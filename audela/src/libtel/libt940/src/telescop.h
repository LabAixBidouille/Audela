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
#include "dsa20.h"
#include "etb10.h"
#include <dmd10.h>

#define MODE_SIMULATION 0
#define MODE_REEL 1
#define MODE_SIMULATION_ETEL 2

#define STATUS_MOTOR_OFF 0
#define STATUS_MOTOR_ON 1

#define MOUNT_UNKNOWN 0
#define MOUNT_EQUATORIAL 1
#define MOUNT_ALTAZ 2

#define AXIS_NOTDEFINED -1
#define AXIS_HA 0
#define AXIS_DEC 1
#define AXIS_AZ 0
#define AXIS_ELEV 1
#define AXIS_PARALLACTIC 2

#define ETEL_X 1
#define ETEL_K 2
#define ETEL_M 3

#define MOUCHARD

typedef struct {
   int type;
	int posinit;
	double angleinit;
	double angleturnback; // angle de rebroussement pour GOTO
	double angleover; // limite au dela de l'angle de rebroussement pour l'arret du suivi
	double angleovered; // -2, -1,0,+1 , +2 selon que le suivi a depasse l'angle de rebroussement ou la limite au dela
	int sens;
	double coef_vs; /* coefficient vitesse suivi azimuth, elevation, derotateur (ADU/ratio_sideral) */
	double coef_xs; /* coefficient pointage azimuth, elevation, derotateur (ADU/deg) */
	double jdinit;
	double coef_vsm; /* coefficient vitesse suivi MOINS azimuth, elevation, derotateur (ADU/ratio_sideral) */
	double coef_vsp; /* coefficient vitesse suivi PLUS azimuth, elevation, derotateur (ADU/ratio_sideral) */
	double coef_xsm; /* coefficient pointage MOINS azimuth, elevation, derotateur (ADU/deg) */
	double coef_xsp; /* coefficient pointage PLUS azimuth, elevation, derotateur (ADU/deg) */
	double temperature;
} axis_params;

/***************************************************************************************/
/* There are five fields to define coordinates:                                        */
/* ----------------------------------------------------------------------------------- */
/* frame_corrections_source_units_angle                                                */
/* ----------------------------------------------------------------------------------- */
/*                                                                                     */
/* frame : coord, utcjd	                                                               */
/*    coord : coordinate frame                                                         */
/*    utcjd : time frame expressed in UTC julian day                                   */
/* corrections : cat, tru, app                                                         */
/*    cat : astrometric topocentric coordinates at current epoch (= ra,dec,J2000)      */
/*    tru : true coordinates (cat + precession, nutation, aberration, annual parallax) */
/*    app : apparent coordinates (tru + refraction + pointing model included)          */
/* source : cod, sim                                                                   */
/*    sim : computed theoretically using initial parameters and current time           */
/*    cod : computed from/for coder current time informations                          */
/* units : deg, adu                                                                    */
/*    deg : degrees                                                                    */
/*    adu : analog-digital-units (coder, microsteps)                                   */
/* angle :                                                                             */
/*    ha : Hour angle                                                                  */
/*    dec : Declination                                                                */
/*    ra : Right ascension                                                             */
/*    az : Azimuth                                                                     */
/*    elev : Elevation                                                                 */
/*    rot : Parallactic angle for altaz mount                                          */
/***************************************************************************************/

/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
	int compteur;
	int axes[5];
   axis_params axis_param[5];
   DSA_DRIVE *drv[5];
   int type_mount;
	int nb_axis;
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
	double app_drift_ra;
	double app_drift_dec;
	double app_drift_ha;
	double app_drift_az;
	double app_drift_elev;
	double app_drift_rot;
	double app_ra_adu; 
	double app_dec_adu;
	double app_ha_adu;
	double app_az_adu;
	double app_elev_adu;
	double app_rot_adu;
	double app_drift_ra_adu;
	double app_drift_dec_adu;
	double app_drift_ha_adu;
	double app_drift_az_adu;
	double app_drift_elev_adu;
	double app_drift_rot_adu;
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
	char extradrift_type[20];
	double extradrift_axis0;
	double extradrift_axis1;
   int tempo;
	long N0;
	long N1;
	long N2;
	double sideral_sep_per_day;
	double ha0;

	// START OF COORDSYS (do not delete this comment)
	double coord_cat_cod_deg_ra; // current catalog coordinates computed from coders
	double coord_cat_cod_deg_dec; // current catalog coordinates computed from coders
	double utcjd_cat_cod_deg_ra; // date of catalog coordinates computed from coders
	double utcjd_cat_cod_deg_dec; // date of catalog coordinates computed from coders
	
	double coord_cat_cod_deg_ra0; // initial catalog coordinates computed from coders
	double coord_cat_cod_deg_dec0; // initial catalog coordinates computed from coders
	double utcjd_cat_cod_deg_ra0; // date of initial catalog coordinates computed from coders
	double utcjd_cat_cod_deg_dec0; // date of initial catalog coordinates computed from coders

	double coord_app_cod_deg_ha; // current apparent coordinates computed from coders
	double coord_app_cod_deg_dec; // current apparent coordinates computed from coders
	double coord_app_cod_deg_ra; // current apparent coordinates computed from coders
	double coord_app_cod_deg_az; // current apparent coordinates computed from coders
	double coord_app_cod_deg_elev; // current apparent coordinates computed from coders
	double coord_app_cod_deg_rot; // current apparent coordinates computed from coders	
	double utcjd_app_cod_deg_ha; // date of current apparent coordinates computed from coders
	double utcjd_app_cod_deg_dec; // date of current apparent coordinates computed from coders
	double utcjd_app_cod_deg_ra; // date of current apparent coordinates computed from coders
	double utcjd_app_cod_deg_az; // date of current apparent coordinates computed from coders
	double utcjd_app_cod_deg_elev; // date of current apparent coordinates computed from coders
	double utcjd_app_cod_deg_rot; // date of current apparent coordinates computed from coders

   double speed_app_cod_deg_ra; // current apparent speed computed for coders
   double speed_app_cod_deg_dec; // current apparent speed computed for coders
   double speed_app_cod_deg_ha; // current apparent speed computed for coders
   double speed_app_cod_deg_az; // current apparent speed computed for coders
   double speed_app_cod_deg_elev; // current apparent speed computed for coders
   double speed_app_cod_deg_rot; // current apparent speed computed for coders

   double speed_app_sim_deg_ra; // current apparent speed computed from simulation
   double speed_app_sim_deg_dec; // current apparent speed computed from simulation
   double speed_app_sim_deg_ha; // current apparent speed computed from simulation
   double speed_app_sim_deg_az; // current apparent speed computed from simulation
   double speed_app_sim_deg_elev; // current apparent speed computed from simulation
   double speed_app_sim_deg_rot; // current apparent speed computed from simulation

	double coord_app_cod_deg_ha0; // initial apparent coordinates computed from coders
	double coord_app_cod_deg_dec0; // initial apparent coordinates computed from coders
	double coord_app_cod_deg_ra0; // initial apparent coordinates computed from coders
	double coord_app_cod_deg_az0; // initial apparent coordinates computed from coders
	double coord_app_cod_deg_elev0; // initial apparent coordinates computed from coders
	double coord_app_cod_deg_rot0; // initial apparent coordinates computed from coders	
	double utcjd_app_cod_deg_ha0; // date of initial apparent coordinates computed from coders
	double utcjd_app_cod_deg_dec0; // date of initial apparent coordinates computed from coders
	double utcjd_app_cod_deg_ra0; // date of initial apparent coordinates computed from coders
	double utcjd_app_cod_deg_az0; // date of initial apparent coordinates computed from coders
	double utcjd_app_cod_deg_elev0; // date of initial apparent coordinates computed from coders
	double utcjd_app_cod_deg_rot0; // date of initial apparent coordinates computed from coders

	double coord_app_cod_adu_ha; // current ADU from/to coder
	double coord_app_cod_adu_dec; // current ADU from/to coder
	double coord_app_cod_adu_az; // current ADU from/to coder
	double coord_app_cod_adu_elev; // current ADU from/to coder
	double coord_app_cod_adu_rot; // current ADU from/to coder
	double coord_app_cod_adu_hapec; // current ADU from/to coder	
	double utcjd_app_cod_adu_ha; // date of current ADU from/to coder
	double utcjd_app_cod_adu_dec; // date of current ADU from/to coder
	double utcjd_app_cod_adu_az; // current ADU from/to coder
	double utcjd_app_cod_adu_elev; // current ADU from/to coder
	double utcjd_app_cod_adu_rot; // current ADU from/to coder
	double utcjd_app_cod_adu_hapec; // current ADU from/to coder
	
	double coord_app_cod_adu_ha0; // initial ADU from/to coder
	double coord_app_cod_adu_dec0; // initial ADU from/to coder
	double coord_app_cod_adu_az0; // initial ADU from/to coder
	double coord_app_cod_adu_elev0; // initial ADU from/to coder
	double coord_app_cod_adu_rot0; // initial ADU from/to coder
	double utcjd_app_cod_adu_ha0; // date of initial ADU from/to coder
	double utcjd_app_cod_adu_dec0; // date of initial ADU from/to coder
	double utcjd_app_cod_adu_az0; // date of initial ADU from/to coder
	double utcjd_app_cod_adu_elev0; // date of initial ADU from/to coder
	double utcjd_app_cod_adu_rot0; // date of initial ADU from/to coder

   double speed_app_cod_adu_ra; // current apparent ADU speed computed for coders
   double speed_app_cod_adu_dec; // current apparent ADU speed computed for coders
   double speed_app_cod_adu_ha; // current apparent ADU speed computed for coders
   double speed_app_cod_adu_az; // current apparent ADU speed computed for coders
   double speed_app_cod_adu_elev; // current apparent ADU speed computed for coders
   double speed_app_cod_adu_rot; // current apparent ADU speed computed for coders

   double speed_app_sim_adu_ra; // current apparent ADU speed computed from simulation
   double speed_app_sim_adu_dec; // current apparent ADU speed computed from simulation
   double speed_app_sim_adu_ha; // current apparent ADU speed computed from simulation
   double speed_app_sim_adu_az; // current apparent ADU speed computed from simulation
   double speed_app_sim_adu_elev; // current apparent ADU speed computed from simulation
   double speed_app_sim_adu_rot; // current apparent ADU speed computed from simulation

	double coord_cat_sim_deg_ra; // current catalog coordinates computed from coders
	double coord_cat_sim_deg_dec; // current catalog coordinates computed from coders
	double utcjd_cat_sim_deg_ra; // date of catalog coordinates computed from coders
	double utcjd_cat_sim_deg_dec; // date of catalog coordinates computed from coders
	
	double coord_cat_sim_deg_ra0; // initial catalog coordinates computed from coders
	double coord_cat_sim_deg_dec0; // initial catalog coordinates computed from coders
	double utcjd_cat_sim_deg_ra0; // date of initial catalog coordinates computed from coders
	double utcjd_cat_sim_deg_dec0; // date of initial catalog coordinates computed from coders

	double coord_app_sim_deg_ha; // current apparent coordinates computed from coders
	double coord_app_sim_deg_dec; // current apparent coordinates computed from coders
	double coord_app_sim_deg_ra; // current apparent coordinates computed from coders
	double coord_app_sim_deg_az; // current apparent coordinates computed from coders
	double coord_app_sim_deg_elev; // current apparent coordinates computed from coders
	double coord_app_sim_deg_rot; // current apparent coordinates computed from coders	
	double utcjd_app_sim_deg_ha; // date of current apparent coordinates computed from coders
	double utcjd_app_sim_deg_dec; // date of current apparent coordinates computed from coders
	double utcjd_app_sim_deg_ra; // date of current apparent coordinates computed from coders
	double utcjd_app_sim_deg_az; // date of current apparent coordinates computed from coders
	double utcjd_app_sim_deg_elev; // date of current apparent coordinates computed from coders
	double utcjd_app_sim_deg_rot; // date of current apparent coordinates computed from coders
	
	double coord_app_sim_deg_ha0; // initial apparent coordinates computed from coders
	double coord_app_sim_deg_dec0; // initial apparent coordinates computed from coders
	double coord_app_sim_deg_ra0; // initial apparent coordinates computed from coders
	double coord_app_sim_deg_az0; // initial apparent coordinates computed from coders
	double coord_app_sim_deg_elev0; // initial apparent coordinates computed from coders
	double coord_app_sim_deg_rot0; // initial apparent coordinates computed from coders	
	double utcjd_app_sim_deg_ha0; // date of initial apparent coordinates computed from coders
	double utcjd_app_sim_deg_dec0; // date of initial apparent coordinates computed from coders
	double utcjd_app_sim_deg_ra0; // date of initial apparent coordinates computed from coders
	double utcjd_app_sim_deg_az0; // date of initial apparent coordinates computed from coders
	double utcjd_app_sim_deg_elev0; // date of initial apparent coordinates computed from coders
	double utcjd_app_sim_deg_rot0; // date of initial apparent coordinates computed from coders

	double coord_app_sim_adu_ha; // current ADU from/to coder
	double coord_app_sim_adu_dec; // current ADU from/to coder
	double coord_app_sim_adu_az; // current ADU from/to coder
	double coord_app_sim_adu_elev; // current ADU from/to coder
	double coord_app_sim_adu_rot; // current ADU from/to coder
	double coord_app_sim_adu_hapec; // current ADU from/to coder	
	double utcjd_app_sim_adu_ha; // date of current ADU from/to coder
	double utcjd_app_sim_adu_dec; // date of current ADU from/to coder
	double utcjd_app_sim_adu_az; // current ADU from/to coder
	double utcjd_app_sim_adu_elev; // current ADU from/to coder
	double utcjd_app_sim_adu_rot; // current ADU from/to coder
	double utcjd_app_sim_adu_hapec; // current ADU from/to coder
	
	double coord_app_sim_adu_ha0; // initial ADU from/to coder
	double coord_app_sim_adu_dec0; // initial ADU from/to coder
	double coord_app_sim_adu_az0; // initial ADU from/to coder
	double coord_app_sim_adu_elev0; // initial ADU from/to coder
	double coord_app_sim_adu_rot0; // initial ADU from/to coder
	double coord_app_sim_adu_hapec0; // initial ADU from/to coder
	double utcjd_app_sim_adu_ha0; // date of initial ADU from/to coder
	double utcjd_app_sim_adu_dec0; // date of initial ADU from/to coder
	double utcjd_app_sim_adu_az0; // date of initial ADU from/to coder
	double utcjd_app_sim_adu_elev0; // date of initial ADU from/to coder
	double utcjd_app_sim_adu_rot0; // date of initial ADU from/to coder
	double utcjd_app_sim_adu_hapec0; // date of initial ADU from/to coder

	double coord_app_cod_adu_dha; // next goto ADU from/to coder
	double coord_app_cod_adu_ddec; // next goto ADU from/to coder
	double coord_app_cod_adu_daz; // next goto ADU from/to coder
	double coord_app_cod_adu_delev; // next goto ADU from/to coder
	double coord_app_cod_adu_drot; // next goto ADU from/to coder

	double coord_app_sim_adu_dha; // next goto ADU from/to coder
	double coord_app_sim_adu_ddec; // next goto ADU from/to coder
	double coord_app_sim_adu_daz; // next goto ADU from/to coder
	double coord_app_sim_adu_delev; // next goto ADU from/to coder
	double coord_app_sim_adu_drot; // next goto ADU from/to coder

	double coord_app_sim_adu_cumdha; // cumulative gotos ADU from/to coder
	double coord_app_sim_adu_cumddec; // cumulative gotos ADU from/to coder
	double coord_app_sim_adu_cumdaz; // cumulative gotos ADU from/to coder
	double coord_app_sim_adu_cumdelev; // cumulative gotos ADU from/to coder
	double coord_app_sim_adu_cumdrot; // cumulative gotos ADU from/to coder
	// END OF COORDSYS (do not delete this comment)
};

#include "pthread.h"
pthread_mutex_t mutex;
pthread_mutexattr_t mutexAttr;

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

int mytel_adu_coord(struct telprop *tel,char *result);

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);
int mytel_correct(struct telprop *tel,char *direction, int duration);

int my_pthread_mutex_lock (pthread_mutex_t * mutex);
int my_pthread_mutex_unlock (pthread_mutex_t * mutex);

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

// --- 
int mytel_motor_stop(struct telprop *tel);
int mytel_tcl_procs(struct telprop *tel);

// --- cod and sim coordinate systems
double mytel_sec2jd(time_t secs1970);
int mytel_app_cod_getadu(struct telprop *tel);
int mytel_app_cod_setadu(struct telprop *tel);
void mytel_app_cod_setadu0(struct telprop *tel);
void mytel_app_cod_setdadu(struct telprop *tel);
void mytel_app_cod_adu2deg(struct telprop *tel);
void mytel_app2cat_cod_deg(struct telprop *tel);
void mytel_cat2app_cod_deg(struct telprop *tel, double jd);
void mytel_app_cod_deg2adu(struct telprop *tel);
void mytel_app2cat_cod_deg0(struct telprop *tel);
void mytel_cat2app_cod_deg0(struct telprop *tel);
int mytel_app_sim_getadu(struct telprop *tel);
void mytel_app_sim_setadu0(struct telprop *tel);
int mytel_app_sim_setadu(struct telprop *tel);
void mytel_app_sim_setdadu(struct telprop *tel);
void mytel_app_sim_adu2deg(struct telprop *tel);
void mytel_app2cat_sim_deg(struct telprop *tel);
void mytel_cat2app_sim_deg(struct telprop *tel, double jd);
void mytel_app_sim_deg2adu(struct telprop *tel);
void mytel_app2cat_sim_deg0(struct telprop *tel);
void mytel_cat2app_sim_deg0(struct telprop *tel);
void mytel_app_setutcjd0_now(struct telprop *tel);
void mytel_app_setutcjd_now(struct telprop *tel);
void mytel_speed_corrections(struct telprop *tel);

// --- thread
struct telprop *telthread;
int ThreadT940_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int ThreadT940_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int CmdThreadT940_loopeval(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif

