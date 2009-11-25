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
/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
   int tempo;
	//int type; /* =0:UMAC =1:PMAC-PCI */
   //char ip[50];
   char home0[60]; /* home used by tel1 home */
   char home[60]; /* home */
   double latitude; /* degrees */
	int mouchard;
	int param_e1;
	int param_e2;
	int param_a1;
	int param_a2;
	int param_b1;
	int param_b2;
	int param_g1;
	int param_g2;
	int param_f1;
	int param_f2;
	int param_s1;
	int param_s2;
   double ha00; /* ha (degrees) at a given roth00 */
   double dec00; /* dec (degrees) at a given rotd00 */
   int roth00; /* (uc) */
   int rotd00; /* (uc) */
   double speed_track_ra; /* (deg/s) */
   double speed_track_dec; /* (deg/s) */
   double speed_slew_ra; /* (deg/s) */
   double speed_slew_dec; /* (deg/s) */
   double radec_speed_dec_conversion; /* (UC)/(deg/s) */
   double radec_position_conversion; /* (UC)/(deg) */
   double track_diurnal; /* (deg/s) */
   int stop_e_uc; /* butee mecanique est */
   int stop_w_uc; /* butee mecanique ouest */
   double radec_move_rate_max; /* vitesse max (deg/s) pour move -rate 1 */
   int state;
   int old_state;
   int slew_axis; // variable qui indique que est l'axe en cours de slew 0: aucun, 1: RA, 2: DEC, 3: RA+DEC.
   int tubepos; // 0: tube a l'ouest ; 1: tube a l'est
   int ha_pointing;
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

int eqmod_put(struct telprop *tel,char *cmd);
int eqmod_putread(struct telprop *tel,char *cmd, char *res);
int eqmod_read(struct telprop *tel,char *res);
int eqmod_delete(struct telprop *tel);
int eqmod_decode(struct telprop *tel,char *chars,int *num);
int eqmod_encode(struct telprop *tel,int num,char *chars);
int eqmod_positions12(struct telprop *tel,int *p1,int *p2);
void eqmod_codeur2skypos(struct telprop *tel, int hastep, int decstep, double *ha, double *ra, double *dec);

int mytel_tcleval(struct telprop *tel,char *ligne);

int eqmod_radec_coord(struct telprop *tel,char *result);
int eqmod_hadec_match(struct telprop *tel);
int eqmod_hadec_coord(struct telprop *tel,char *result);


int eqmod_settsl(struct telprop *tel);
int eqmod_home(struct telprop *tel, char *home_default);
double eqmod_tsl(struct telprop *tel,int *h, int *m,double *sec);
void eqmod_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function);

int eqmod2_match(struct telprop *tel, char dir);

int eqmod2_action_move(struct telprop *tel, char *direction);
int eqmod2_action_stop(struct telprop *tel, char *direction);
int eqmod2_action_motor(struct telprop *tel);
int eqmod2_action_goto(struct telprop *tel);

#endif

