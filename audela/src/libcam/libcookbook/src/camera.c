/* camera.c
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


/*
 * Ceci est le fichier contenant le driver de la camera
 *
 * La structure "camprop" peut etre adaptee
 * dans le fichier camera.h
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <stdio.h>
#include "math.h"

#include "camera.h"
#include <libcam/util.h>

//#define TIME_PROFILING    // Seulement pour linux !!

#if defined(TIME_PROFILING)
#include <asm/msr.h>
#endif

/* ATTENTION : Seul le binning numerique est applique */

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"CB245",	   /* camera name */
     "cookbook",	/* camera product */
     "tc245",			/* ccd name */
     252, 242,			/* maxx maxy */
     11, 29,			/* overscans x */
     2, 0,			/* overscans y */
     25.5e-6, 19.75e-6,		/* photosite dim (m) */
     4095.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, char **argv);
static void cam_start_exp(struct camprop *cam, char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, unsigned short *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,
    NULL,
    cam_set_binning,
    cam_update_window,
    cam_start_exp,
    cam_stop_exp,
    cam_read_ccd,
    cam_shutter_on,
    cam_shutter_off,
    NULL,
    NULL,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

static void timetest(struct camprop *cam);
static void clear_ccd(struct camprop *cam);
static void read_ccd(struct camprop *cam, unsigned short *p);
static void write_out(struct camprop *cam, cookbyte * ptr, short count);
static void shift_line_2(struct camprop *cam);
static void shift_line_1(struct camprop *cam);
static void shift_line_3(struct camprop *cam);
static void shift_line_b(struct camprop *cam);
static void shift_image(struct camprop *cam);
static void clear_storage(struct camprop *cam);
static void clear_image_area(struct camprop *cam);
static void clear_serial_register(struct camprop *cam);
static void delay1(struct camprop *cam);
static void delay2(struct camprop *cam);
static void readout_line(struct camprop *cam, short *data, int shift);
static void readout_line_int(struct camprop *cam, short *data);
static long exposure(struct camprop *cam, unsigned short *p);
static long exposure1(struct camprop *cam);

static void read_ccd_externalbin(struct camprop *cam, unsigned short *p);
static void read_ccd_internalbin(struct camprop *cam, unsigned short *p);


/*
 *  Definition a structure specific for this driver 
 *  (see declaration in camera.h)
 */

 /*-------------------------------------------*/

#define MUX1    16
#define MUX2    32

//#define port    0x378
cookbyte ctrl;

#define CB245_ALL_LOW	0x00
#define	CB245_SRG1	0x01
#define	CB245_SRG2	0x02
#define	CB245_SRG3	0x04
#define	CB245_TRG	0x08
#define	CB245_MUX1	0x10
#define	CB245_MUX2	0x20
#define	CB245_SAG	0x40
#define	CB245_IAG	0x80

#define	CB245_HIGH	(CB245_MUX1)
#define	CB245_MIDDLE	(CB245_MUX2)
#define	CB245_LOW	(CB245_MUX1 | CB245_MUX2)

#define CB245_CONVERT	0x01
#define CB245_CONTROL	0xC0


/*-------------------------------------------*/


/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
int cam_init(struct camprop *cam, int argc, char **argv)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_init\n");

#ifdef OS_LIN
    if ( ! libcam_can_access_parport() ) {
	sprintf(cam->msg,"You don't have sufficient privileges to access parallel port. Camera cannot be created.");
	return 1;
    }
#endif
    
    cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
    timetest(cam);
    cam->readfunc = 0;

    return 0;
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;

    fprintf(stderr, "libcookbook <INFO>: enter cam_update_window\n");

    maxx = cam->nb_photox;
    maxy = cam->nb_photoy;
    if (cam->x1 > cam->x2)
	libcam_swap(&(cam->x1), &(cam->x2));
    if (cam->x1 < 0)
	cam->x1 = 0;
    if (cam->x2 > maxx - 1)
	cam->x2 = maxx - 1;

    if (cam->y1 > cam->y2)
	libcam_swap(&(cam->y1), &(cam->y2));
    if (cam->y1 < 0)
	cam->y1 = 0;
    if (cam->y2 > maxy - 1)
	cam->y2 = maxy - 1;

    cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_start_exp\n");

    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* vidage de la matrice, lance la pose et transfert de la trame */
	clear_ccd(cam);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
    }
}

void cam_stop_exp(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_stop_exp\n");
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
#if defined(TIME_PROFILING)
    long long t1 = 0, t2 = 0;
#endif

    fprintf(stderr, "libcookbook <INFO>: enter cam_read_ccd\n");

    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* Lecture de l'image */
	switch (cam->readfunc) {
	case 0:
#if defined(TIME_PROFILING)
	    rdtscll(t1);
#endif
	    read_ccd_internalbin(cam, p);
#if defined(TIME_PROFILING)
	    rdtscll(t2);
#endif
	    break;
	case 1:
#if defined(TIME_PROFILING)
	    rdtscll(t1);
#endif
	    read_ccd_externalbin(cam, p);
#if defined(TIME_PROFILING)
	    rdtscll(t2);
#endif
	    break;
	default:
	    fprintf(stderr, "libcookbook <ERROR>: invalid cam->readfunc value (%d)\n", cam->readfunc);
	    break;
	}
	if (cam->interrupt == 1) {
	    /* Debloquage des interruptions */
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}

#if defined(TIME_PROFILING)
	t2 -= t1;
	fprintf(stderr, "libcookbook <INFO>: CCD reading took t=%Lu CPU cycles (divide by your CPU frequency in Hz to have a real time).\n", t2);
#endif
    }
}

void cam_shutter_on(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_shutter_on\n");
}

void cam_shutter_off(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_shutter_off\n");
}

void cam_measure_temperature(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_measure_temperature\n");
    cam->temperature = 0.;
}

void cam_cooler_on(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_cooler_on\n");
}

void cam_cooler_off(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_cooler_off\n");
}

void cam_cooler_check(struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_cooler_check\n");
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
    fprintf(stderr, "libcookbook <INFO>: enter cam_set_binning\n");

    if (binx <= 1) {
	binx = 1;
    }
    if (binx >= 4) {
	binx = 4;
    }
    if (biny <= 1) {
	biny = 1;
    }
    if (biny >= 4) {
	biny = 4;
    }
    cam->binx = binx;
    cam->biny = biny;

    // Inhibit binning feature (for test purpose) 
    // TODO: restore binning feature
    fprintf(stderr, "libcookbook <DEBUG>: binning forced to 1x1\n");
    cam->binx = 1;
    cam->biny = 1;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */


/*
 * cookbook_resetref(struct camprop *cam)
 * This function returns the reset and reference levels. It was adapted
 * from Tybee Evans source code (private comm.).
 */
void cookbook_resetref(struct camprop *cam, unsigned short *reset, unsigned short *ref)
{
    unsigned short port[3];
    unsigned short h;
    unsigned short m;
    unsigned short l;

    port[0] = cam->port;
    port[1] = cam->port + 1;
    port[2] = cam->port + 2;

    clear_ccd(cam);
    shift_line_2(cam);
    clear_serial_register(cam);

    /* Lecture de la valeur de reset */
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG1);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG2);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG3);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG1);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG2);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG3);

    delay1(cam);
    libcam_out(port[2], CB245_CONTROL);
    delay2(cam);
    libcam_out(port[2], CB245_CONTROL | CB245_CONVERT);
    delay2(cam);

    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_HIGH | CB245_SRG1);
    h = libcam_in(port[1]) & 0x00f0;

    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_MIDDLE | CB245_SRG2);
    m = libcam_in(port[1]) & 0x00f0;

    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_LOW | CB245_SRG3);
    l = libcam_in(port[1]) & 0x00f0;

    *reset = ((h << 4) | (m) | (l >> 4)) ^ 0x888;

    /* Lecture de la valeur de reference */
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG1);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG2);
    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_SRG1 | CB245_SRG3);

    delay1(cam);
    libcam_out(port[2], CB245_CONTROL);
    delay2(cam);
    libcam_out(port[2], CB245_CONTROL | CB245_CONVERT);
    delay2(cam);

    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_HIGH | CB245_SRG1);
    h = libcam_in(port[1]) & 0x00f0;

    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_MIDDLE | CB245_SRG2);
    m = libcam_in(port[1]) & 0x00f0;

    libcam_out(port[0], CB245_ALL_LOW);
    libcam_out(port[0], CB245_LOW | CB245_SRG3);
    l = libcam_in(port[1]) & 0x00f0;

    *ref = ((h << 4) | (m) | (l >> 4)) ^ 0x888;

}


void timetest(struct camprop *cam)
/* bd1 : nombre de boucles pour faire 1 microseconde */
{
    unsigned long t1, t2, t3;
#if defined(TIME_PROFILING)
    unsigned long t11, t22;
#endif
    unsigned long n;
    int sortie = 0, b;
    unsigned long x, xx, a[10];
    n = 100000;
    b = 0;
    while (sortie == 0) {
	b++;

#if defined(TIME_PROFILING)
	rdtscl(t11);
#endif

	t1 = libcam_getms();
	/* La boucle suivante est obligee d'etre effectuee */
	/* en entier meme si le compilateur optimise */
	for (xx = 0, x = 0; x < n; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	a[0] = libcam_getms();

#if defined(TIME_PROFILING)
	rdtscl(t22);
#endif

	t2 = a[0];
	/* t3 : nombre de millisecondes pour effectuer n boucles */
	t3 = (t2 - t1);

#if defined(TIME_PROFILING)
	printf("t22-t11=%lu\n", t22 - t11);
#endif
	printf("n=%lu / t1=%lu t2=%lu t3=%lu\n", n, t1, t2, t3);

	if (t3 < (unsigned long) 30) {
	    n = (unsigned long) 10 *n;
	} else {
	    sortie = 1;
	    break;
	}
	if (b > 10) {
	    t3 = 1;
	    sortie = 1;
	    break;
	}
    }
    /* nombre de microsecondes pour effectuer n boucles */
    t3 *= (unsigned long) 1000;
    /* nombre de boucles a effectuer pour 1 microseconde */
    //cam->bd1 = n / t3 * 10;
    cam->bd1 = n / t3;
    cam->bd2 = 2 * cam->bd1;
    cam->bd5 = 5 * cam->bd1;
    cam->bd10 = 10 * cam->bd1;
    fprintf(stderr, "t1=%lu\n", t1);
    fprintf(stderr, "t2=%lu\n", t2);
    fprintf(stderr, "t3=%lu\n", t3);
    fprintf(stderr, "cam->bd1 = %lu\n", cam->bd1);
    fprintf(stderr, "cam->bd2 = %lu\n", cam->bd2);
    fprintf(stderr, "cam->bd5 = %lu\n", cam->bd5);
    fprintf(stderr, "cam->bd10 = %lu\n", cam->bd10);

    for (n = 0; n < 10; n++) {
#if defined(TIME_PROFILING)
	rdtsc(t1, t2);
#endif
	delay1(cam);
#if defined(TIME_PROFILING)
	rdtsc(t3, t4);
#endif

#if defined(TIME_PROFILING)
	if (t2 == t4) {
	    fprintf(stderr, "t1=%08lX t3=%08lX : t3-t1=%f\n", t1, t3, (t3 - t1) / 400.);
	} else {
	    fprintf(stderr, "t1=%08lX t3=%08lX : t1-t3=%f\n", t1, t3, (t1 - t3 + 1) / 400.);
	}
#endif
    }
}

void clear_ccd(struct camprop *cam)
{
    long i;
    for (i = 0; i < 3; i++) {
	clear_storage(cam);
	clear_serial_register(cam);
	clear_image_area(cam);
    }

}

void read_ccd(struct camprop *cam, unsigned short *p)
{

    long i;
    long j, jj;
    unsigned short data[1000];
    int b;

    shift_image(cam);

    /* shift unused lines for the defined window */
    for (i = 0; i < cam->y1; i++) {
	clear_serial_register(cam);
	shift_line_1(cam);
	shift_line_2(cam);
	shift_line_3(cam);
    }

    for (i = 0; i < cam->h; i++) {
	for (b = 0; b < cam->biny; b++) {
	    /*
	       if (i*cam->biny>cam->h) {
	       return;
	       }
	     */
	    for (j = 0; j < cam->nb_photox; j++) {
		data[j] = 0;
	    }
	    clear_serial_register(cam);
	    shift_line_1(cam);
	    readout_line(cam, data, 0);
	    for (j = 0, jj = 0; j < cam->w; j += 3, jj++) {
		for (b = 0; b < cam->binx; b++) {
		    p[i * cam->w + j] += data[jj * cam->binx + b];
		}
	    }
	    shift_line_2(cam);
	    readout_line(cam, 1 + data, 1);
	    for (j = 1, jj = 0; j < cam->w; j += 3, jj++) {
		for (b = 0; b < cam->binx; b++) {
		    p[i * cam->w + j] += data[jj * cam->binx + b];
		}
	    }
	    shift_line_3(cam);
	    readout_line(cam, 2 + data, 2);
	    for (j = 2, jj = 0; j < cam->w; j += 3, jj++) {
		for (b = 0; b < cam->binx; b++) {
		    p[i * cam->w + j] += data[jj * cam->binx + b];
		}
	    }
	}
    }
}


void read_ccd_externalbin(struct camprop *cam, unsigned short *p)
{

    long i;
    long j, jj;
    unsigned short data[1000];
    int b;

    fprintf(stderr, "libcookbook <INFO>: use read_ccd_externalbin\n");

    shift_image(cam);

    /* shift unused lines for the defined window */
    for (i = 0; i < cam->y1; i++) {
	clear_serial_register(cam);
	shift_line_1(cam);
	shift_line_2(cam);
	shift_line_3(cam);
    }

    for (i = 0; i < cam->h; i++) {
	for (j = 0; j < cam->nb_photox; j++) {
	    data[j] = 0;
	}
	clear_serial_register(cam);
	shift_line_1(cam);
	readout_line(cam, data, 0);
	for (j = 0, jj = 0; j < cam->w; j += 3, jj++) {
	    for (b = 0; b < cam->binx; b++) {
		p[i * cam->w + j] += data[jj * cam->binx + b];
	    }
	}
	shift_line_2(cam);
	readout_line(cam, 1 + data, 1);
	for (j = 1, jj = 0; j < cam->w; j += 3, jj++) {
	    for (b = 0; b < cam->binx; b++) {
		p[i * cam->w + j] += data[jj * cam->binx + b];
	    }
	}
	shift_line_3(cam);
	readout_line(cam, 2 + data, 2);
	for (j = 2, jj = 0; j < cam->w; j += 3, jj++) {
	    for (b = 0; b < cam->binx; b++) {
		p[i * cam->w + j] += data[jj * cam->binx + b];
	    }
	}
    }
}

void read_ccd_internalbin(struct camprop *cam, unsigned short *p)
{

    long i;
    long j;
    short port;
    short port1;
    unsigned short data;
    unsigned char b1, b2, b3;

    fprintf(stderr, "libcookbook <INFO>: use read_ccd_internalbin\n");

    port = cam->port;
    port1 = port + 1;

    shift_image(cam);

    // shift unused lines for the defined window
    for (i = 0; i < cam->y1; i++) {
	clear_serial_register(cam);
	shift_line_1(cam);
	shift_line_2(cam);
	shift_line_3(cam);
    }

    for (i = 0; i < cam->h; i++) {
	// Transfert de la ligne dans le registre horizontal
	shift_line_b(cam);
	// Vidage des pixels de prescan + prewindow
	for (j = 0; j < cam->nb_deadbeginphotox + cam->x1; j++) {
	    write_out(cam, "\x10\x11\x20\x22\x30\x34", 6);
	}
	// Lecture des pixels dans la fenetre
	for (j = cam->x1; j <= cam->x2; j++) {

	    libcam_out(port, CB245_ALL_LOW);
	    libcam_out(port, CB245_SRG1);
	    libcam_out(port, CB245_ALL_LOW);
	    libcam_out(port, CB245_SRG2);
	    libcam_out(port, CB245_ALL_LOW);
	    libcam_out(port, CB245_SRG3);

	    delay1(cam);
	    libcam_out((unsigned short) (port + 2), 0x0c);
	    delay2(cam);
	    libcam_out((unsigned short) (port + 2), 0x0d);

	    libcam_out(port, CB245_HIGH);
	    b1 = libcam_in(port1) & 0xF0;
	    libcam_out(port, CB245_MIDDLE);
	    b2 = libcam_in(port1) & 0xF0;
	    libcam_out(port, CB245_LOW);
	    b3 = libcam_in(port1) & 0xF0;

	    data = ((b1 << 4) | b2 | (b3 >> 4)) ^ 0x888;

/*
	    libcam_out(port, 0x10);
	    libcam_out(port, 0x11);
	    b1 = libcam_in(port1) & 0xF0;
	    libcam_out(port, 0x20);
	    libcam_out(port, 0x22);
	    b2 = libcam_in(port1) & 0xF0;
	    libcam_out(port, 0x30);
	    libcam_out(port, 0x34);
	    b3 = libcam_in(port1) & 0xF0;
	    delay1(cam);
	    libcam_out((unsigned short) (port + 2), 0x0c);
	    delay2(cam);
	    libcam_out((unsigned short) (port + 2), 0x0d);

	    data = ((b3 << 4) | b2 | (b1 >> 4)) ^ 0x888;
*/

	    *p++ = data;
	}
    }
}


/*
//
//---------------------------------------------------------
//  FORMAT TAB 8.
//	Cookbook camera driver code for 245 based version.
//	This code does handle internal binning or full 745x242
//	resolution for external binning.
//
//	Copyright 1994, Benoit Schillings, All Rights Reserved.
//
//---------------------------------------------------------
//
//	THIS CODE CAN BE USED FOR EXPERIMENTAL PURPOSE BUT
//  CANNOT BE USED IN A COMMERCIAL OR PUBLIC APPLICATION
//  WITHOUT THE AUTORISATION FROM THE AUTHOR.
//  THE AUTHOR WOULD BE GLAD TO RECEIVE ANY COMMENT/CHANGE
//  MADE TO THIS CODE.
//
// 	More seriously there might be some bug left in this
//  code and anybody which would find some improvement would
//  be nice to send it back to the ccd list.
//
//
//
//	email to : benoit@be.com or benoit@netcom.com or CPS 72662,3356
//---------------------------------------------------------
*/


void write_out(struct camprop *cam, cookbyte * ptr, short count)
{
    unsigned char c;
    unsigned short port = cam->port;
    while (count--) {
	/*outportb(port, *ptr++); */
	c = (unsigned char) (*ptr++);
	libcam_out(port, c);
    }
}

/*
//-------------------------------------------
//	0x38		mux1, mux2, trg.
//	0x30		mux1, mux2.
//	0x37		mux1, mux2, srg1, srg2, srg3.
//	0x30		mux1, myx2.
//-------------------------------------------
*/

void shift_line_2(struct camprop *cam)
{
    write_out(cam, "\x38\x30\x37\x30", 4);
}

/*
//-------------------------------------------
//	0x70		sag, mux1, mux2.
//	0x30		mux1, myx2.
//	0x38		mux1, mux2, trg
//	0x30		mux1, mux2.
//	0x37		mux1, mux2, srg1, srg2, srg3
//	0x30		mux1, mux2.
//-------------------------------------------
*/

void shift_line_1(struct camprop *cam)
{
    write_out(cam, "\x70\x30\x38\x30\x37\x30", 6);
}

/*
//-------------------------------------------
//	0x38		mux1, mux2, trg
//	0x30		mux1, mux2.
//	0x37		mux1, mux2, srg1, srg2, srg3
//	0x30		mux1, mux2.
//-------------------------------------------
*/

void shift_line_3(struct camprop *cam)
{
    write_out(cam, "\x38\x30\x37\x30", 4);
}

/*
//-------------------------------------------
//	0x38		mux1, mux2, trg
//	0x30		mux1, mux2.
//	0x38		mux1, mux2, trg
//	0x30		mux1, mux2.
//	0x38		mux1, mux2, trg
//	0x37		mux1, mux2, srg1, srg2, srg3
//	0x70		sag, mux1, mux2.
//	0x30		mux1, mux2.
//-------------------------------------------
*/
void shift_line_b(struct camprop *cam)
{
    write_out(cam, "\x38\x30\x38\x30\x38\x37\x70\x30", 8);
}

/*
//-------------------------------------------
//	0x38		mux1, mux2, trg.
//	0x78		sag, mux1, mux2, trg.
//	0xf7		iag, sag, mux1, mux2, srg1, srg2, srg3.
//	0xb7		iag, mux1, mux2, srg1, srg2, srg3.
//-------------------------------------------
*/

void shift_image(struct camprop *cam)
{
    long i;

    for (i = 0; i < 245; i++)
	write_out(cam, "\x38\x78\xf7\xb7", 4);
}

/*
//-------------------------------------------
//	0x38		mux1, mux2, trg.
//	0x78		sag, mux1, mux2, trg.
//	0x77		sag, mux1, mux2, srg1, srg2, srg3.
//	0x37		mux1, mux2, srg1, srg2, srg3.
//-------------------------------------------
*/

void clear_storage(struct camprop *cam)
{
    long i;

    for (i = 0; i < 248; i++)
	write_out(cam, "\x38\x78\x77\x37", 4);
}

/*
//-------------------------------------------
//	0x38		mux1, mux2, trg.
//	0x78		sag, mux1, mux2, trg.
//	0xf7		iag, sag, mux1, mux2, srg1, srg2, srg3.
//	0x37		iag, mux1, mux2, srg1, srg2, srg3.
//-------------------------------------------
*/

void clear_image_area(struct camprop *cam)
{
    long i;
    unsigned short port = cam->port;

    for (i = 0; i < 500; i++)
	write_out(cam, "\x38\x78\xf7\xb7", 4);

    libcam_out(port, 0x00);
}

/*
//-------------------------------------------
//	0x31		mux1, mux2, srg1.
//	0x31		mux1, mux2, srg2.
//	0x31		mux1, mux2, srg3.
//-------------------------------------------
*/

void clear_serial_register(struct camprop *cam)
{
    long i;

    for (i = 0; i < 274; i++)
	write_out(cam, "\x31\x32\x34", 3);
}

/*-------------------------------------------*/

void delay1(struct camprop *cam)
{
    /*long    i; */
    unsigned long x, xx, a[10];
    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /*for (i = 0; i < 50; i++); */

}

/*-------------------------------------------*/

void delay2(struct camprop *cam)
{
    /*long    i; */
    unsigned long x, xx, a[10];
    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /*for (i = 0; i < 50; i++); */
}

/*
//-------------------------------------------
// non binned readout of a line.
//-------------------------------------------
//	0x10	mux1
//	0x11	mux1, srg1.
//	0x20	mux2.
//	0x22	mux2, srg2.
//	0x30	mux1, mux2.
//	0x34	mux1, mux2, srg3.
//-------------------------------------------
*/

void readout_line(struct camprop *cam, short *data, int shift)
{
    long i;
    long v;
    cookbyte b1, b2, b3;
    long v1, v2, v3;
    unsigned short port = cam->port;
    int k, cx1, cx2;

    cx1 = (cam->nb_deadbeginphotox + cam->x1);
    cx2 = cx1 + cam->w * cam->binx;
    k = 0;
    for (i = shift; i < cx2; i += 3) {
	if (i < cx1) {
	    write_out(cam, "\x10\x11\x20\x22\x30\x34", 6);
	} else {
	    libcam_out(port, 0x10);
	    libcam_out(port, 0x11);
	    b1 = libcam_in((unsigned short) (port + 1));
	    libcam_out(port, 0x20);
	    libcam_out(port, 0x22);
	    b2 = libcam_in((unsigned short) (port + 1));
	    libcam_out(port, 0x30);
	    libcam_out(port, 0x34);
	    b3 = libcam_in((unsigned short) (port + 1));

	    delay1(cam);
	    libcam_out((unsigned short) (port + 2), 0x0c);
	    delay2(cam);
	    libcam_out((unsigned short) (port + 2), 0x0d);

	    v1 = (b1 >> 4);
	    v2 = (b2 >> 4);
	    v3 = (b3 >> 4);

	    v = 0;
	    v = (v1 << 8) | (v2 << 4) | v3;
	    v ^= 0x444;
	    data[k] = (short) v;
	    k++;
	}
    }

    /*
       i = cam->nb_deadbeginphotox; // 11
       while(i--) {
       write_out(cam,"\x10\x11\x20\x22\x30\x34", 6);
       }
       i = (int)ceil(cam->nb_photox/3.); // 242
       k=0;
       while(i--) {
       libcam_out(port, 0x10);
       libcam_out(port, 0x11);
       b1 = libcam_in((unsigned short)(port + 1));
       libcam_out(port, 0x20);
       libcam_out(port, 0x22);
       b2 = libcam_in((unsigned short)(port + 1));
       libcam_out(port, 0x30);
       libcam_out(port, 0x34);
       b3 = libcam_in((unsigned short)(port + 1));

       delay1(cam);
       libcam_out((unsigned short)(port + 2), 0x0c);
       delay2(cam);
       libcam_out((unsigned short)(port + 2), 0x0d);

       v1 = (b1 >> 4);
       v2 = (b2 >> 4);
       v3 = (b3 >> 4);

       v=0;
       v = (v1 << 8) | (v2 << 4) | v3;
       v ^= 0x888;
       data[k] = (short)v;
       k++;
       }
     */
}

/*
//-------------------------------------------
// binned by 3 horizontal readout of a line.
//-------------------------------------------
//	0x10	mux1
//	0x11	mux1, srg1.
//	0x20	mux2.
//	0x22	mux2, srg2.
//	0x30	mux1, mux2.
//	0x34	mux1, mux2, srg3.
//-------------------------------------------
*/
void readout_line_int(struct camprop *cam, short *data)
{
    long i;
    long v;
    cookbyte b1, b2, b3;
    long v1, v2, v3;
    unsigned short port = cam->port;

    i = 11;
    while (i--)
	write_out(cam, "\x10\x11\x20\x22\x30\x34", 6);

    i = 242;

    while (i--) {
	libcam_out(port, 0x10);
	libcam_out(port, 0x11);
	b1 = libcam_in((unsigned short) (port + 1));
	libcam_out(port, 0x20);
	libcam_out(port, 0x22);
	b2 = libcam_in((unsigned short) (port + 1));
	libcam_out(port, 0x30);
	libcam_out(port, 0x34);
	b3 = libcam_in((unsigned short) (port + 1));
	delay1(cam);
	libcam_out((unsigned short) (port + 2), 0x0c);
	delay2(cam);
	libcam_out((unsigned short) (port + 2), 0x0d);

	v1 = (b1 >> 4);
	v2 = (b2 >> 4);
	v3 = (b3 >> 4);

	v = (v1 << 8) | (v2 << 4) | v3;
	/*v ^= 0x040404; */
	v ^= 0x888;
	*data++ = (short) v;
    }
}

/*
//-------------------------------------------
// exposure + 750 x 242 readout
*/

long exposure(struct camprop *cam, unsigned short *p)
{
    long i;
/*	long    	j;*/
    unsigned short data[780];


    for (i = 0; i < 3; i++) {
	clear_storage(cam);
	clear_serial_register(cam);
	clear_image_area(cam);
    }

/*	delay(cam,j);*/

    shift_image(cam);


    for (i = 0; i < 242; i++) {
	clear_serial_register(cam);
	shift_line_1(cam);
	readout_line(cam, 0 + data, 0);
	shift_line_2(cam);
	readout_line(cam, 1 + data, 1);
	shift_line_3(cam);
	readout_line(cam, 2 + data, 2);
	/*
	   for (j = 0; j < 750; j++)
	   bb->set_pixel(i, j, data[j]);
	   }
	 */
    }

    return 0;
}

/*
//-------------------------------------------
// exposure + binned readout
*/
long exposure1(struct camprop *cam)
{
    long i;
/*	long    	j;*/
    unsigned short data[780];

    for (i = 0; i < 3; i++) {
	clear_storage(cam);
	clear_serial_register(cam);
	clear_image_area(cam);
    }

    for (i = 0; i < 10; i++)
/*		delay(cam,j);*/

	clear_storage(cam);
    shift_image(cam);

    for (i = 0; i < 242; i++) {
	shift_line_b(cam);
	readout_line_int(cam, (short *) data);
	/*
	   for (j = 0; j < 250; j++)
	   bb->set_pixel(i, j, data[j]);
	 */
    }
    return 0;
}

/*-------------------------------------------*/



/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

void cookbook_cam_test_out(struct camprop *cam, unsigned long nb_out)
{
    unsigned short port;
    if (cam->authorized == 1) {
	port = cam->port;
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* Mesure du temps de out */
	test_out_time(port, nb_out, (unsigned long) 0);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
    }
}
