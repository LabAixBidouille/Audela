/* camera.h
 * 
 * Copyright (C) 2004 Sylvain GIRARD <sly.girard@wanadoo.fr>
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

/* bits du port parallel */

#define PCDATA 1
#define PCSCLK 2
#define PCSTART  4

#define FIFO1_0 0
#define FIFO1_1 64
#define FIFO2_0 0
#define FIFO2_1 128

#define DLE_0 0
#define DLE_1 1

#define SRCK_0 0
#define SRCK_1 2

#define RSTR_0 4
#define RSTR_1 0

#define FIOE_0 0
#define FIOE_1 8

/* masque ventillateur : */
/*          ABC         */
/*   8 = 00 001 000 : off             */
/*   0 = 00 000 000 : minimal         */
/*  32 : 00 100 000 : moyen           */
/*  16 : 00 010 000 : fot             */
/*  48 : 00 110 000 : maximal         */
#define VENT_OFF 8
#define VENT_MIN 0
#define VENT_MOY 32
#define VENT_FOR 16
#define VENT_MAX 48

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour K2 --- */
    unsigned char vent;		/* masque de l'etat du ventilateur (et de refroidissement) */
};

/*
int cam_init(struct camprop *cam, int argc, char **argv);
void cam_update_window(struct camprop *cam);
void cam_start_exp(struct camprop *cam, char *amplionoff);
void cam_stop_exp(struct camprop *cam);
void cam_read_ccd(struct camprop *cam, unsigned short *p);
void cam_shutter_on(struct camprop *cam);
void cam_shutter_off(struct camprop *cam);
void cam_measure_temperature(struct camprop *cam);
void cam_cooler_on(struct camprop *cam);
void cam_cooler_off(struct camprop *cam);
void cam_cooler_check(struct camprop *cam);
void cam_set_binning(int binx, int biny, struct camprop *cam);
*/

/*
void InitFifo(struct camprop *cam);
void Pose_CCD(struct camprop *cam);
void Read_CCD(struct camprop *cam, unsigned short *buf);
double LectureLM35(struct camprop *cam);
void TestSX28(struct camprop *cam);
unsigned char ChangeSRCK(int change);
*/

void k2_TestSX28(struct camprop *cam);
char *k2_SetABL(struct camprop *cam,int arc, char *argv[]);
char *k2_Version(struct camprop *cam);
char *k2_TestFifo(struct camprop *cam, unsigned char o);
void k2_test_out(struct camprop *cam, unsigned long nb_out);
void k2_TestDG642(struct camprop *cam);

#endif
