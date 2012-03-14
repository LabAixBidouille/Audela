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

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */

#define EQMOD_STATE_NOT_INITIALIZED 0   // On ne sait pas ou on en est
#define EQMOD_STATE_HALT            1   // Init en cours, moteur pas alimente
#define EQMOD_STATE_STOPPED         2   // Moteur alimente, a l'arret
#define EQMOD_STATE_GOTO            3   // GOTO: goto
#define EQMOD_STATE_TRACK           4   // TRACK: suivi permanent
#define EQMOD_STATE_SLEW            5   // SLEW: deplacement manuel, qui interromp le suivi
#define state2string(s) (s==EQMOD_STATE_NOT_INITIALIZED?"NOT_INITIALIZED":(s==EQMOD_STATE_HALT?"HALT":(s==EQMOD_STATE_STOPPED?"STOPPED":(s==EQMOD_STATE_GOTO?"GOTO":(s==EQMOD_STATE_TRACK?"TRACK":(s==EQMOD_STATE_SLEW?"SLEW":"NOT DEFINED"))))))

#define AXE_RA   1
#define AXE_DEC  2

#define axe(c) (((toupper(c)=='N')||(toupper(c)=='S')) ? AXE_DEC : AXE_RA)
#define dir(c) (((toupper(c)=='N')||(toupper(c)=='W')) ? 0 : 1)

#define TUBE_OUEST   0
#define TUBE_EST     1
#define TubePos2string(s) ( s == TUBE_OUEST ? "W" : "E" )

#define PRINTF printf

/*
 * Donnees propres a chaque telescope.
 */
/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
   int tempo;
   char home[60];                     // location of the pier, conforming to libmc's GPS standard
   double latitude;                   // degrees
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
   double speed_track_ra;             // (deg/s)
   double speed_track_dec;            // (deg/s)
   double speed_slew_ra;              // (deg/s)
   double speed_slew_dec;             // (deg/s)
   double radec_speed_dec_conversion; // (UC)/(deg/s) */
   double radec_position_conversion;  // (UC)/(deg) */
   double track_diurnal;              // (deg/s)
   int stop_e_uc;                     // butee mecanique est (en pas codeurs)
   int stop_w_uc;                     // butee mecanique ouest (en pas codeurs)
   double radec_move_rate_max;        // vitesse max (deg/s) pour move -rate 1
   int state;
   int old_state;
   int slew_axis;                     // variable qui indique que est l'axe en cours de slew 0: aucun, 1: RA, 2: DEC, 3: RA+DEC.
   int tubepos;                       // 0: tube a l'ouest ; 1: tube a l'est
   int ha_pointing;
	int gotodead_ms;
	int gotoread_ms;
	double dead_delay_slew; /* delai en secondes estime pour un slew sans bouger */
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
double mytel_sec2jd(time_t secs1970);

int eqmod_radec_coord(struct telprop *tel,char *result);
int eqmod_hadec_match(struct telprop *tel);
int eqmod_hadec_coord(struct telprop *tel,char *result);


int eqmod_settsl(struct telprop *tel);
double eqmod_tsl(struct telprop *tel,int *h, int *m,double *sec);
void eqmod_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function);

int eqmod2_match(struct telprop *tel, char dir);

int eqmod2_action_move(struct telprop *tel, char *direction);
int eqmod2_action_stop(struct telprop *tel, char *direction);
int eqmod2_action_motor(struct telprop *tel);
int eqmod2_action_goto(struct telprop *tel);

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif

