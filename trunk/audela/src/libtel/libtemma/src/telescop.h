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
   double ra_play;
   double dec_play;
   int slewpathindex;
   char home[60];  /* home as it is decoded by temma_home function */
   char home0[60]; /* home used by tel1 home */
   char v_firmware[30];
   int encoder; /* 0 if no encoders, 1 if encoders are installed */
   double tsl;  /* TSL du dernier appel a la mise a jour du TSL de Temma */
   double ha00; /* angle horaire du dernier Match */
   double tsl00; /* TSL du dernier Match */
   char ew[2]; /* German mounts */
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
int mytel_radec_goto(struct telprop *tel);
int mytel_radec_state(struct telprop *tel,char *result);
int mytel_radec_coord(struct telprop *tel,char *result);
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

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);

int temma_position_tube(struct telprop *tel,char *sens);
int temma_setlatitude(struct telprop *tel,double latitude);
int temma_getlatitude(struct telprop *tel,double *latitude);
int temma_gettsl(struct telprop *tel,double *tsl);
int temma_LA (struct telprop *tel, int value);
int temma_LB (struct telprop *tel, int value);
int temma_lg (struct telprop *tel, int *vra, int *vdec);
int temma_v_firmware (struct telprop *tel) ;
int temma_arret_pointage(struct telprop *tel) ;
int temma_suivi_arret (struct telprop *tel);
int temma_suivi_marche (struct telprop *tel);
int temma_coord(struct telprop *tel,char *result);
int temma_match(struct telprop *tel);
int temma_goto(struct telprop *tel);
int temma_initzenith(struct telprop *tel);
int temma_stopgoto(struct telprop *tel);
int temma_stategoto(struct telprop *tel,int *state);

int temma_angle_ra2hms(char *in, char *out);
int temma_angle_dec2dms(char *in, char *out);
int temma_angle_hms2ra(struct telprop *tel, char *in, char *out);
int temma_angle_dms2dec(struct telprop *tel, char *in, char *out);
int temma_delete(struct telprop *tel);

int temma_setderive(struct telprop *tel,int var,int vdec);
int temma_getderive(struct telprop *tel,int *var,int *vdec);

int temma_settsl(struct telprop *tel);
double temma_tsl(struct telprop *tel,int *h, int *m,int *sec);
void temma_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function);

#endif

