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
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

/*
 * Donnees propres a chaque telescope.
 */
/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
   int waitResponse;
   int longformatindex;
   int tempo;
	char autostar_char[3];
   int reponseSRSD;
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
int mytel_radec_init_additional(struct telprop *tel);
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
int mytel_correct(struct telprop *tel,char *direction, int duration);
int mytel_sendLX(struct telprop *tel, int returnType, char *response,  char *commandFormat, ...);
int mytel_sendLXTempo(struct telprop *tel, int returnType, char *response, int nbLoopMax, char *commandFormat, ...);
#ifdef __cplusplus
}
#endif

#endif

