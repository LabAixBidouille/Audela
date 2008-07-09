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

//#if defined(OS_LIN)
//#   include <unistd.h>
//#   include <asm/io.h>
//#   include <asm/segment.h>
//#   include "../../common/system.h"
//#   include <sys/time.h>
//#   include <sys/perm.h>
//#endif
#include "camera.h"
#include <libcam/util.h>


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"MX516",			/* camera name */
     "starlight",		/* camera product */
     "ICX055AL",		/* ccd name */
     500, 290,			/* maxx maxy */
     23, 14,			/* overscans x */
     9, 4,			/* overscans y */
     9.8e-6, 12.6e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     2.,			/* gain (e/adu) */
     25.,			/* readnoise (e) */
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
    {"HX516",		/* camera name */
     "starlight",	/* camera product */
     "ICX084AL",		/* ccd name */
     659, 499,			/* maxx maxy */
     21, 21,			/* overscans x */
     14, 10,			/* overscans y */
     7.4e-6, 7.4e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     1.,			/* gain (e/adu) */
     15.,			/* readnoise (e) */
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
    {"MX916",		/* camera name */
     "starlight",	/* camera product */
     "ICX083AL",	/* ccd name */
     752, 290,			/* maxx maxy */
     25, 0,			/* overscans x */
     5, 1,			/* overscans y */
     11.6e-6, 5.7e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     0.5,			/* filling factor */
     3.,			/* gain (e/adu) */
     15.,			/* readnoise (e) */
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
    {"MX716",		/* camera name */
     "starlight",	/* camera product */
     "ICX249AK",		/* ccd name */
     752, 582,			/* maxx maxy */
     25, 0,			/* overscans x */
     5, 1,			/* overscans y */
     10.57e-6, 11.57e-6,	/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.0,			/* filling factor */
     3.,			/* gain (e/adu) */
     12.,			/* readnoise (e) */
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
static void cam_ampli_on(struct camprop *cam);
static void cam_ampli_off(struct camprop *cam);
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
    cam_ampli_on,
    cam_ampli_off,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

static void wiper(struct camprop *cam);
static void reader(struct camprop *cam);
static void clearvert(struct camprop *cam);
static void lineread_win(struct camprop *cam, unsigned short *buf);
static void wiper_mx5(struct camprop *cam);
static void reader_mx5(struct camprop *cam);
static void vert_mx5(struct camprop *cam);
static void clearvert_mx5(struct camprop *cam);
static void lineread_mx5(struct camprop *cam, unsigned short *buf);
static void lineread_win_mx5(struct camprop *cam, unsigned short *buf);
static void fastwiper_mx5(struct camprop *cam);
static void fastreader_mx5(struct camprop *cam);
static void fastvert_mx5(struct camprop *cam);
static void fastclearvert_mx5(struct camprop *cam);
static void fastlineread_mx5(struct camprop *cam, unsigned short *buf);
static void fastlineread_win_mx5(struct camprop *cam, unsigned short *buf);
static void wiper_hx5(struct camprop *cam);
static void reader_hx5(struct camprop *cam);
static void vert_hx5(struct camprop *cam);
static void clearvert_hx5(struct camprop *cam);
static void lineread_hx5(struct camprop *cam, unsigned short *buf);
static void lineread_win_hx5(struct camprop *cam, unsigned short *buf);
static void fastwiper_hx5(struct camprop *cam);
static void fastreader_hx5(struct camprop *cam);
static void fastvert_hx5(struct camprop *cam);
static void fastclearvert_hx5(struct camprop *cam);
static void fastlineread_hx5(struct camprop *cam, unsigned short *buf);
static void fastlineread_win_hx5(struct camprop *cam, unsigned short *buf);
static unsigned char libcam_in2(unsigned short a);

/*
 *  Definition a structure specific for this driver 
 *  (see declaration in camera.h)
 */

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
    int i;

#ifdef OS_LIN
    // Astuce pour autoriser l'acces au port parallele
    libcam_bloquer();
    libcam_debloquer();
#endif

    cam->timescale = 1.;
    cam->accelerator = 0;
    for (i = 3; i < argc - 1; i++) {
	if (strcmp(argv[i], "-timescale") == 0) {
	    cam->multdelay = fabs(atof(argv[i + 1]));
	}
	if (strcmp(argv[i], "-accelerator") == 0) {
	    cam->accelerator = atoi(argv[i + 1]);
	}
    }
    cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
    starlight_timetest(cam);
    return 0;
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;
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
/*
   cam->w = ( cam->x2 - cam->x1) / cam->binx + 1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = ( cam->y2 - cam->y1) / cam->biny + 1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;
   */
    cam->w = (cam->x2 - cam->x1 + 1) / cam->binx;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1 + 1) / cam->biny;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* Transfert interligne destructif */
	wiper(cam);
	/* Rincage des interlignes */
	clearvert(cam);
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
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* Transfert interligne non destructif */
	reader(cam);
	/* Lecture et numérisation avec fenetre et binning */
	lineread_win(cam, p);
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

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
{
}

void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}

void cam_measure_temperature(struct camprop *cam)
{
    cam->temperature = 0.;
}

void cam_cooler_on(struct camprop *cam)
{
}

void cam_cooler_off(struct camprop *cam)
{
}

void cam_cooler_check(struct camprop *cam)
{
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
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
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

void starlight_timetest(struct camprop *cam)
/* bd1 : nombre de boucles pour faire 1 microseconde */
{
    unsigned long t1, t2, t3;
    unsigned long n;
    int sortie = 0, b;
    unsigned long x, xx, a[10];
    n = 100000;
    b = 0;
    while (sortie == 0) {
	b++;
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
	t2 = a[0];
	/* t3 : nombre de millisecondes pour effectuer n boucles */
	t3 = (t2 - t1);
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
    cam->bd1 = (int) (cam->timescale * n / t3 * 10);
    cam->bd2 = (int) (cam->timescale * 2 * n / t3 * 10);
    cam->bd5 = (int) (cam->timescale * 5 * n / t3 * 10);
    cam->bd10 = (int) (cam->timescale * 10 * n / t3 * 10);
}

void wiper(struct camprop *cam)
{
    if (cam->index_cam == 1) {
	if (cam->accelerator == 0) {
	    wiper_hx5(cam);
	} else {
	    fastwiper_hx5(cam);
	}
    } else {
	if (cam->accelerator == 0) {
	    wiper_mx5(cam);
	} else {
	    fastwiper_mx5(cam);
	}
    }

}

void reader(struct camprop *cam)
{
    if (cam->index_cam == 1) {
	if (cam->accelerator == 0) {
	    reader_hx5(cam);
	} else {
	    fastreader_hx5(cam);
	}
    } else {
	if (cam->accelerator == 0) {
	    reader_mx5(cam);
	} else {
	    fastreader_mx5(cam);
	}
    }
}

void clearvert(struct camprop *cam)
{
    if (cam->index_cam == 1) {
	if (cam->accelerator == 0) {
	    clearvert_hx5(cam);
	} else {
	    fastclearvert_hx5(cam);
	}
    } else {
	if (cam->accelerator == 0) {
	    clearvert_mx5(cam);
	} else {
	    fastclearvert_mx5(cam);
	}
    }
}

void lineread_win(struct camprop *cam, unsigned short *buf)
{
    if (cam->index_cam == 1) {
	if (cam->accelerator == 0) {
	    lineread_win_hx5(cam, buf);
	} else {
	    fastlineread_win_hx5(cam, buf);
	}
    } else {
	if (cam->accelerator == 0) {
	    lineread_win_mx5(cam, buf);
	} else {
	    fastlineread_win_mx5(cam, buf);
	}
    }
}

/* ================================================================ */
/* Camera MX5 directe. D'apres Terry Platt                          */
/* ================================================================ */

void wiper_mx5(struct camprop *cam)
{
    unsigned short port3;
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    port3 = port + 2;

    /* CCD output amplifier on */
    libcam_out(port3, 4);

    /* clocks quiescent */
    libcam_out(port, 69);

    /* dump pixel charge */
    libcam_out(port, 197);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /* return to quiescent state */
    libcam_out(port, 69);

    /* switch off amplifier */
    libcam_out(port3, 6);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }
}

void reader_mx5(struct camprop *cam)
{
    unsigned short port3;
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    port3 = port + 2;

    /* clocks quiescent */
    libcam_out(port, 69);

    /* amplifier on, vert. clock in clocking mode */
    libcam_out(port3, 4);

    clearvert_mx5(cam);

    /* amplifier on, vert. clock in read mode */
    libcam_out(port3, 0);

    /* SG1 pulse */
    libcam_out(port, 85);
    libcam_out(port, 69);

    /* SG2 pulse */
    libcam_out(port, 73);
    libcam_out(port, 69);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /* amplifier on, vert. clock in clock mode */
    libcam_out(port3, 4);

    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }
}

void vert_mx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    libcam_out(port, 69);

    /* trigger vertical clock cycle */
    libcam_out(port, 65);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    libcam_out(port, 69);

    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

}

void clearvert_mx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    int z, y, w, wend;
    unsigned long x, xx, a[10];

    for (z = 0; z <= 10; z++) {
	for (y = 0; y <= 30; y++) {
	    /* shift down 31 lines */
	    libcam_out(port, 69);
	    libcam_out(port, 65);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
	wend =
	    cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	    cam->nb_photox + 10;
	for (w = 0; w <= wend; w++) {
	    /* clear horizontal register */
	    /* move pixel charge to output */
	    libcam_out(port, 5);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* reset */
	    libcam_out(port, 37);
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
    }
}

void lineread_mx5(struct camprop *cam, unsigned short *buf)
{
    unsigned short port = cam->port;
    unsigned short port2;
    int z, y, w, wend, w1, w2;
    unsigned long x, xx, a[10];
    int cx, ah, bx, al;
    unsigned short pix;
    port2 = port + 1;

    /*for (y=0;y<=9;y++) { */
    for (y = 0; y <= cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 69);
	libcam_out(port, 65);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    wend =
	cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	cam->nb_photox + 10;
    for (w = 0; w <= wend; w++) {
	/* move pixel charge to output */
	libcam_out(port, 5);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	/* reset */
	libcam_out(port, 37);
	/* next pixel ready */
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    wend =
	cam->nb_deadbeginphotox + cam->nb_deadendphotox + cam->nb_photox;
    w1 = cam->nb_deadbeginphotox;
    w2 = w1 + cam->nb_photox;
    for (z = 0; z < cam->nb_photoy; z++) {

	for (y = 0; y < wend; y++) {
	    /* move pixel charge to output */
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* convert */
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* reset */
	    libcam_out(port, 37);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    if (y < w1)
		continue;
	    if (y >= w2)
		continue;

	    /* A-D Readout routine */
	    cx = 0;
	    ah = 32;
	    libcam_out(port, 68);
	    bx = 16;
	    pix = (unsigned short) 0;

	    /* loop 1 */
	    do {
		libcam_out(port, 69);
		/*al = (int)libcam_in2(port2); */
		pix =
		    ((unsigned short) libcam_in2(port2)) &
		    (unsigned short) ah;
		al = (int) pix;
		if (al != ah) {
		    cx++;
		}
		cx += cx;
		libcam_out(port, 69);
		libcam_out(port, 68);
		bx--;
	    } while (bx > 0);

	    /* *(buf++)=(unsigned short)cx; */
	    *(buf++) = (unsigned short) (65535 - cx);
	}

	/* vertical shift */
	libcam_out(port, 69);
	libcam_out(port, 65);
	for (xx = 0, x = 0; x < cam->bd1; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }
}

void lineread_win_mx5(struct camprop *cam, unsigned short *buf)
{
    unsigned short port = cam->port;
    unsigned short port2;
    int z, y, w, b, wend;
    unsigned long x, xx, a[10];
    int cx, ah, bx, al;
    unsigned short pix;

    port2 = port + 1;

    /* --- phi-V les premieres lignes inutiles du bas --- */
    /*for (y=0;y<=9;y++) { */
    /*DM for (y=0;y<=cam->nb_deadbeginphotoy;y++) { */
    for (y = 0; y <= cam->nb_deadbeginphotoy + cam->y1; y++) {
	libcam_out(port, 69);
	libcam_out(port, 65);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    /* --- phi-H sans numerisation --- */
    wend =
	cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	cam->nb_photox + 10;
    for (w = 0; w <= wend; w++) {
	/* move pixel charge to output */
	libcam_out(port, 5);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	/* reset */
	libcam_out(port, 37);
	/* next pixel ready */
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    /*DM for (z=0;z<=cam->y2;z+=cam->biny) { */
    for (z = cam->y1; z <= cam->y2; z += cam->biny) {
	/* vertical shift */
	for (b = 0; b < cam->biny; b++) {
	    libcam_out(port, 69);
	    libcam_out(port, 65);
	    for (xx = 0, x = 0; x < cam->bd1; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

	/* === vide les pixels inutiles en debut de ligne === */
	for (y = 0; y < cam->nb_deadbeginphotox + cam->x1; y++) {
	    /* move pixel charge to output */
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* convert */
	    /*
	       libcam_out(port,7);
	       for (xx=0,x=0;x<cam->bd2;x++) { a[xx]=(unsigned long)(0); if (++xx>9) { xx=0; } }
	     */
	    /* reset */
	    libcam_out(port, 37);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

	/* === numerise les pixels utiles === */
	/*DM for (y=cam->nb_deadbeginphotox+cam->x1;y<=cam->nb_deadbeginphotox+cam->x2;y+=cam->binx) { */
	for (y = cam->x1; y <= cam->x2; y += cam->binx) {
	    /*for (y=0;y<cam->w;y++) { */
	    /* move pixel charge to output */
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* take account for horizontal binning */
	    for (b = 1; b < cam->binx; b++) {
		libcam_out(port, 69);
		for (xx = 0, x = 0; x < cam->bd2; x++) {
		    a[xx] = (unsigned long) (0);
		    if (++xx > 9) {
			xx = 0;
		    }
		}
		libcam_out(port, 5);
		for (xx = 0, x = 0; x < cam->bd2; x++) {
		    a[xx] = (unsigned long) (0);
		    if (++xx > 9) {
			xx = 0;
		    }
		}
	    }
	    /* convert */
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* reset */
	    libcam_out(port, 37);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    /* A-D Readout routine */
	    cx = 0;
	    ah = 32;
	    libcam_out(port, 68);
	    bx = 16;
	    pix = (unsigned short) 0;

	    /* loop 1 */
	    do {
		libcam_out(port, 69);
		/*al = (int)libcam_in2(port2); */
		pix =
		    ((unsigned short) libcam_in2(port2)) &
		    (unsigned short) ah;
		al = (int) pix;
		if (al != ah) {
		    cx++;
		}
		cx += cx;
		libcam_out(port, 69);
		libcam_out(port, 68);
		bx--;
	    } while (bx > 0);
	    *(buf++) = (unsigned short) (65535 - cx);
	}

	/* === vide les pixels inutiles en fin de ligne === */
	/*DM for (y=cam->nb_deadbeginphotox+1+cam->x2;y<=cam->nb_deadbeginphotox+1+cam->x2+cam->nb_deadendphotox;y++) { */
	for (y = cam->x2; y <= cam->nb_photox + cam->nb_deadendphotox; y++) {
	    /* move pixel charge to output */
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* convert */
	    /*
	       libcam_out(port,7);
	       for (xx=0,x=0;x<cam->bd2;x++) { a[xx]=(unsigned long)(0); if (++xx>9) { xx=0; } }
	     */
	    /* reset */
	    libcam_out(port, 37);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

    }
}

/* ================================================================ */
/* Camera MX5 accelerator. D'apres Terry Platt                      */
/* ================================================================ */

void fastwiper_mx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    /* clocks quiescent */
    libcam_out(port, 69);

    /* dump pixel charge */
    libcam_out(port, 197);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /* return to quiescent state */
    libcam_out(port, 69);
    libcam_out(port, 68);

    /* turn off amplifier */
    libcam_out(port, 2);
    libcam_out(port, 34);
    libcam_out(port, 2);
    libcam_out(port, 69);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }
}

void fastreader_mx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    libcam_out(port, 69);
    libcam_out(port, 68);

    /* amplifier on */
    libcam_out(port, 4);
    libcam_out(port, 36);
    libcam_out(port, 4);

    fastclearvert_mx5(cam);

    /* select read mode */
    libcam_out(port, 4);
    libcam_out(port, 36);
    libcam_out(port, 4);
    libcam_out(port, 84);

    /* SG1 pulse */
    libcam_out(port, 85);
    libcam_out(port, 69);

    /* SG2 pulse */
    libcam_out(port, 73);
    libcam_out(port, 69);
    libcam_out(port, 68);
    libcam_out(port, 6);
    libcam_out(port, 36);
    libcam_out(port, 68);
    libcam_out(port, 69);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

}

void fastvert_mx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    libcam_out(port, 69);

    /* trigger vertical clock cycle */
    libcam_out(port, 65);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    libcam_out(port, 69);

    for (xx = 0, x = 0; x < cam->bd5; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

}

void fastclearvert_mx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    int z, y, w, wend;
    unsigned long x, xx, a[10];

    for (z = 0; z <= 10; z++) {
	for (y = 0; y <= 30; y++) {
	    /* shift down 31 lines */
	    libcam_out(port, 69);
	    libcam_out(port, 65);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
	wend =
	    cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	    cam->nb_photox + 10;
	for (w = 0; w <= wend; w++) {
	    libcam_out(port, 69);
	    /* horizontal clock */
	    libcam_out(port, 5);
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
    }
}

void fastlineread_mx5(struct camprop *cam, unsigned short *buf)
{
    unsigned short port = cam->port;
    unsigned short d1 = 0, d2 = 0, d3 = 0, d4 = 0;
    unsigned short port2;
    int z, y, wend, w1, w2;
    unsigned long x, xx, a[10];
    unsigned short dat, databyte;
    port2 = port + 1;

    libcam_out(port, 69);
    libcam_out(port, 6);
    libcam_out(port, 38);	/* amp on */
    libcam_out(port, 6);
    libcam_out(port, 84);
    libcam_out(port, 85);
    libcam_out(port, 84);

    /*for (y=0;y<=9;y++) { */
    for (y = 0; y <= cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 69);
	libcam_out(port, 65);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    wend =
	cam->nb_deadbeginphotox + cam->nb_deadendphotox + cam->nb_photox;
    w1 = cam->nb_deadbeginphotox;
    w2 = w1 + cam->nb_photox;
    for (z = 0; z < cam->nb_photoy; z++) {

	for (y = 0; y < wend; y++) {
	    /* horizontal clock and trigger data download into FI */
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    if (y < w1)
		goto fastlineread_mx5_misspix2;
	    if (y >= w2)
		goto fastlineread_mx5_misspix2;

	    d2 = d2 * 16;
	    d3 = (unsigned short) (d3 / 8);

	    databyte = (d1 + d2) * 32 + d3 + d4 + d4;
	    *(buf++) = (unsigned short) (databyte);

	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    libcam_out(port, 6);
	    libcam_out(port, 70);	/* shift pixel charge to O/P */
	    libcam_out(port, 102);	/* convert */
	    libcam_out(port, 70);

	    /* read least significant 4 bits from FI register */
	    dat = (unsigned short) libcam_in(port2);
	    d1 = dat & 120;
	    libcam_out(port, 86);
	    libcam_out(port, 118);
	    libcam_out(port, 86);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d2 = dat & 120;
	    libcam_out(port, 134);
	    libcam_out(port, 166);
	    libcam_out(port, 134);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d3 = dat & 120;
	    libcam_out(port, 150);
	    libcam_out(port, 182);
	    libcam_out(port, 150);

	    /* read most significant 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d4 = dat & 120;

	  fastlineread_mx5_misspix2:

	    libcam_out(port, 68);
	    libcam_out(port, 69);

	}

	/* vertical shift */
	libcam_out(port, 69);
	libcam_out(port, 65);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}

    }
}

void fastlineread_win_mx5(struct camprop *cam, unsigned short *buf)
{

    unsigned short port = cam->port;
    unsigned short d1 = 0, d2 = 0, d3 = 0, d4 = 0;
    unsigned short port2;
    int z, y, b;
    unsigned long x, xx, a[10];
    unsigned short dat, databyte;
    port2 = port + 1;

    libcam_out(port, 69);
    libcam_out(port, 6);
    libcam_out(port, 38);	/* amp on */
    libcam_out(port, 6);
    libcam_out(port, 84);
    libcam_out(port, 85);
    libcam_out(port, 84);

    /*for (y=0;y<=9;y++) { */
    for (y = 0; y <= cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 69);
	libcam_out(port, 65);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 69);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    for (z = 0; z < cam->h; z++) {

	/* vertical shift */
	for (b = 0; b < cam->biny; b++) {
	    libcam_out(port, 69);
	    libcam_out(port, 65);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

	/* === vide les pixels inutiles en debut de ligne === */
	for (y = 0; y < cam->nb_deadbeginphotox + cam->x1; y++) {
	    /* horizontal clock and trigger data download into FI */
	    /*libcam_out(port,7);
	       for (xx=0,x=0;x<cam->bd2;x++) { a[xx]=(unsigned long)(0); if (++xx>9) { xx=0; } }
	     */
	    libcam_out(port, 68);
	    libcam_out(port, 69);
	}

	/* === numerise les pixels utiles === */
	for (y = 0; y < cam->w; y++) {
	    /* horizontal clock and trigger data download into FI */
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    d2 = d2 * 16;
	    d3 = (unsigned short) (d3 / 8);

	    databyte = (d1 + d2) * 32 + d3 + d4 + d4;
	    *(buf++) = (unsigned short) (databyte);
	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    /* take account for horizontal binning */
	    for (b = 1; b < cam->binx; b++) {
		libcam_out(port, 6);
		libcam_out(port, 70);
	    }

	    /* convert */
	    libcam_out(port, 102);
	    libcam_out(port, 70);

	    /* read least significant 4 bits from FI register */
	    dat = (unsigned short) libcam_in(port2);
	    d1 = dat & 120;
	    libcam_out(port, 86);
	    libcam_out(port, 118);
	    libcam_out(port, 86);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d2 = dat & 120;
	    libcam_out(port, 134);
	    libcam_out(port, 166);
	    libcam_out(port, 134);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d3 = dat & 120;
	    libcam_out(port, 150);
	    libcam_out(port, 182);
	    libcam_out(port, 150);

	    /* read most significant 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d4 = dat & 120;

	    libcam_out(port, 68);
	    libcam_out(port, 69);
	}

	/* === vide les pixels inutiles en fin de ligne === */
	for (y = cam->nb_deadbeginphotox + 1 + cam->x2;
	     y <=
	     cam->nb_deadbeginphotox + 1 + cam->x2 +
	     cam->nb_deadendphotox; y++) {
	    /* horizontal clock and trigger data download into FI */
	    /*
	       libcam_out(port,7);
	       for (xx=0,x=0;x<cam->bd2;x++) { a[xx]=(unsigned long)(0); if (++xx>9) { xx=0; } }
	     */
	    libcam_out(port, 68);
	    libcam_out(port, 69);
	}
    }
}


/* ================================================================ */
/* Camera HX5 directe. D'apres ?                                    */
/* ================================================================ */

void wiper_hx5(struct camprop *cam)
{
    unsigned short port3;
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    port3 = port + 2;

    /* */
    libcam_out(port, 85);

    /* send pulse for wiper */
    libcam_out(port, 213);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /* */
    libcam_out(port, 85);

    /* switch off amplifier */
    libcam_out(port3, 6);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }
}

void reader_hx5(struct camprop *cam)
{
    unsigned short port3;
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    port3 = port + 2;

    clearvert_hx5(cam);

    /*  */
    libcam_out(port, 21);

    /* ampli on reader mode */
    libcam_out(port3, 0);
    libcam_out(port, 21);

    /*  */
    libcam_out(port, 29);

    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /*  */
    libcam_out(port, 21);
    libcam_out(port, 85);
    /* ampli on clock mode */
    libcam_out(port3, 4);

}

void vert_hx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    libcam_out(port, 5);

    /*  */
    libcam_out(port, 1);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    libcam_out(port, 5);
    libcam_out(port, 85);

    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

}

void clearvert_hx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    int z, y, w, wend;
    unsigned long x, xx, a[10];

    for (z = 0; z <= 9; z++) {
	for (y = 0; y <= 50; y++) {
	    /* shift down 51 lines */
	    libcam_out(port, 5);
	    libcam_out(port, 1);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 5);
	    libcam_out(port, 85);
	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
	wend =
	    cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	    cam->nb_photox;
	for (w = 0; w <= wend; w++) {
	    /* clear horizontal register */
	    /* move pixel charge to output */
	    libcam_out(port, 85);
	    /* next pixel ready */
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* reset */
	    libcam_out(port, 7);
	    libcam_out(port, 39);
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
    }
}

void lineread_hx5(struct camprop *cam, unsigned short *buf)
{
    unsigned short port = cam->port;
    unsigned short port2;
    int z, y, w, wend, w1, w2;
    unsigned long x, xx, a[10];
    int cx, ah, bx, al;
    unsigned short pix;
    port2 = port + 1;

    libcam_out(port, 85);
    /*for (y=0;y<=9;y++) { */
    for (y = 0; y <= cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 5);
	libcam_out(port, 1);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 5);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 85);
    }

    wend =
	2 * (cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	     cam->nb_photox);
    for (w = 0; w <= wend; w++) {
	/* move pixel charge to output */
	libcam_out(port, 5);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	/* reset */
	libcam_out(port, 39);
	/* next pixel ready */
	libcam_out(port, 69);
	libcam_out(port, 85);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    wend =
	cam->nb_deadbeginphotox + cam->nb_deadendphotox + cam->nb_photox;
    w1 = cam->nb_deadbeginphotox;
    w2 = w1 + cam->nb_photox;
    for (z = 0; z < cam->nb_photoy; z++) {

	for (y = 0; y < wend; y++) {
	    /*  */
	    libcam_out(port, 85);
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* convert */
	    libcam_out(port, 7);
	    libcam_out(port, 39);
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /*  */
	    libcam_out(port, 85);

	    if (y < w1)
		goto fastlineread_hx5_misspix2;
	    if (y >= w2)
		goto fastlineread_hx5_misspix2;

	    /* A-D Readout routine */
	    cx = 0;
	    ah = 32;
	    libcam_out(port, 84);
	    bx = 16;
	    pix = (unsigned short) 0;

	    /* loop 1 */
	    do {
		pix =
		    ((unsigned short) libcam_in(port2)) &
		    (unsigned short) ah;
		al = (int) pix;
		if (al != ah) {
		    cx++;
		}
		cx += cx;
		libcam_out(port, 85);
		libcam_out(port, 84);
		bx--;
	    } while (bx > 0);

	    /* *(buf++)=(unsigned short)cx; */
	    *(buf++) = (unsigned short) (65535 - cx);

	  fastlineread_hx5_misspix2:;

	}

	/* vertical shift */
	libcam_out(port, 5);
	libcam_out(port, 1);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 5);
	libcam_out(port, 85);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }
}

void lineread_win_hx5(struct camprop *cam, unsigned short *buf)
{
    unsigned short port = cam->port;
    unsigned short port2;
    int z, y, w, b, wend;
    unsigned long x, xx, a[10];
    int cx, ah, bx, al;
    unsigned short pix;
    port2 = port + 1;

    /* --- phi-V les premieres lignes inutiles du bas --- */
    /*for (y=0;y<=9;y++) { */
    for (y = 0; y < cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 5);
	libcam_out(port, 1);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 5);
	for (xx = 0, x = 0; x < cam->bd5; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 85);
    }

    /* --- phi-H sans numerisation --- */
    wend =
	2 * (cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	     cam->nb_photox);
    for (w = 0; w <= wend; w++) {
	/* move pixel charge to output */
	libcam_out(port, 5);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	/* reset */
	libcam_out(port, 39);
	/* next pixel ready */
	libcam_out(port, 69);
	libcam_out(port, 85);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    for (z = 0; z < cam->h; z++) {

	/* vertical shift */
	for (b = 0; b < cam->biny; b++) {
	    libcam_out(port, 5);
	    libcam_out(port, 1);
	    for (xx = 0, x = 0; x < cam->bd1; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd5; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 85);
	}

	/* === vide les pixels inutiles en debut de ligne === */
	for (y = 0; y < cam->nb_deadbeginphotox + cam->x1; y++) {
	    /* */
	    libcam_out(port, 85);
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* */
	    libcam_out(port, 39);
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

	/* === numerise les pixels utiles === */
	for (y = 0; y < cam->w; y++) {
	    /* move pixel charge to output */
	    libcam_out(port, 85);
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* take account for horizontal binning */
	    for (b = 1; b < cam->binx; b++) {
		libcam_out(port, 69);
		for (xx = 0, x = 0; x < cam->bd2; x++) {
		    a[xx] = (unsigned long) (0);
		    if (++xx > 9) {
			xx = 0;
		    }
		}
		libcam_out(port, 5);
		for (xx = 0, x = 0; x < cam->bd2; x++) {
		    a[xx] = (unsigned long) (0);
		    if (++xx > 9) {
			xx = 0;
		    }
		}
	    }
	    /* convert */
	    libcam_out(port, 7);
	    /*  */
	    libcam_out(port, 39);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 85);

	    /* A-D Readout routine */
	    cx = 0;
	    ah = 32;
	    libcam_out(port, 84);
	    bx = 16;
	    pix = (unsigned short) 0;

	    /* loop 1 */
	    do {
		pix =
		    ((unsigned short) libcam_in2(port2)) &
		    (unsigned short) ah;
		al = (int) pix;
		if (al != ah) {
		    cx++;
		}
		cx += cx;
		libcam_out(port, 85);
		libcam_out(port, 84);
		bx--;
	    } while (bx > 0);

	    *(buf++) = (unsigned short) (65535 - cx);
	}

	/* === vide les pixels inutiles en fin de ligne === */
	for (y = cam->nb_deadbeginphotox + 1 + cam->x2;
	     y <=
	     cam->nb_deadbeginphotox + 1 + cam->x2 +
	     cam->nb_deadendphotox; y++) {
	    /* move pixel charge to output */
	    libcam_out(port, 85);
	    libcam_out(port, 5);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    /* reset */
	    libcam_out(port, 39);
	    /* next pixel ready */
	    libcam_out(port, 69);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

    }
}

/* ================================================================ */
/* Camera HX5 accelerator. D'apres ?                                */
/* ================================================================ */

void fastwiper_hx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    /*  */
    libcam_out(port, 84);

    /* */
    libcam_out(port, 212);
    libcam_out(port, 213);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    /* */
    libcam_out(port, 212);
    libcam_out(port, 2);

    /* turn off amplifier */
    libcam_out(port, 34);
    libcam_out(port, 2);
    libcam_out(port, 84);
    libcam_out(port, 85);
    libcam_out(port, 84);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }
}

void fastreader_hx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    libcam_out(port, 6);

    /* amplifier on */
    libcam_out(port, 4);
    libcam_out(port, 36);
    libcam_out(port, 4);

    /*fastclearvert_hx5(cam); */

    libcam_out(port, 14);
    libcam_out(port, 15);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    libcam_out(port, 14);
    /* ampli on clock mode */
    libcam_out(port, 6);
    libcam_out(port, 7);
    libcam_out(port, 6);
    libcam_out(port, 38);
    libcam_out(port, 6);

    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

}

void fastvert_hx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned long x, xx, a[10];

    libcam_out(port, 0);

    /* trigger vertical clock cycle */
    libcam_out(port, 1);

    for (xx = 0, x = 0; x < cam->bd2; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

    libcam_out(port, 0);
    libcam_out(port, 84);
    libcam_out(port, 85);
    libcam_out(port, 84);

    for (xx = 0, x = 0; x < cam->bd10; x++) {
	a[xx] = (unsigned long) (0);
	if (++xx > 9) {
	    xx = 0;
	}
    }

}

void fastclearvert_hx5(struct camprop *cam)
{
    unsigned short port = cam->port;
    int z, y, w, wend;
    unsigned long x, xx, a[10];

    for (z = 0; z <= 9; z++) {
	for (y = 0; y <= 50; y++) {
	    /* shift down 51 lines */
	    libcam_out(port, 0);
	    libcam_out(port, 1);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 0);
	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);
	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}
	wend =
	    cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	    cam->nb_photox + 10;
	for (w = 0; w <= wend; w++) {
	    libcam_out(port, 6);
	    libcam_out(port, 7);
	    /* horizontal clock */
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 6);
	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);
	}
    }
}

void fastlineread_hx5(struct camprop *cam, unsigned short *buf)
{
    unsigned short port = cam->port;
    unsigned short d1 = 0, d2 = 0, d3 = 0, d4 = 0;
    unsigned short port2;
    int z, y, w, wend, w1, w2;
    unsigned long x, xx, a[10];
    unsigned short dat, databyte;
    port2 = port + 1;

    libcam_out(port, 84);
    libcam_out(port, 6);
    libcam_out(port, 38);	/* amp on */
    libcam_out(port, 6);
    libcam_out(port, 84);
    libcam_out(port, 85);
    libcam_out(port, 84);

    /*for (y=0;y<=9;y++) { */
    for (y = 0; y <= cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 0);
	libcam_out(port, 1);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 0);
	libcam_out(port, 84);
	libcam_out(port, 85);
	libcam_out(port, 84);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    /* --- phi-H sans numerisation --- */
    wend =
	2 * (cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	     cam->nb_photox);
    for (w = 0; w <= wend; w++) {
	libcam_out(port, 6);
	/* move pixel charge to output */
	libcam_out(port, 7);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 84);
	libcam_out(port, 85);
	libcam_out(port, 84);
    }

    wend =
	cam->nb_deadbeginphotox + cam->nb_deadendphotox + cam->nb_photox;
    w1 = cam->nb_deadbeginphotox;
    w2 = w1 + cam->nb_photox;
    for (z = 0; z < cam->nb_photoy; z++) {

	for (y = 0; y < wend; y++) {
	    /* horizontal clock and trigger data download into FI */
	    libcam_out(port, 6);
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    if (y < w1)
		goto fastlineread_hx5_misspix2;
	    if (y >= w2)
		goto fastlineread_hx5_misspix2;

	    d2 = d2 * 16;
	    d3 = (unsigned short) (d3 / 8);

	    databyte = (d1 + d2) * 32 + d3 + d4 + d4;
	    *(buf++) = (unsigned short) (databyte);

	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    libcam_out(port, 6);
	    libcam_out(port, 70);	/* shift pixel charge to O/P */
	    libcam_out(port, 102);	/* convert */
	    libcam_out(port, 70);

	    /* read least significant 4 bits from FI register */
	    dat = (unsigned short) libcam_in(port2);
	    d1 = dat & 120;
	    libcam_out(port, 86);
	    libcam_out(port, 118);
	    libcam_out(port, 86);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d2 = dat & 120;
	    libcam_out(port, 134);
	    libcam_out(port, 166);
	    libcam_out(port, 134);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d3 = dat & 120;
	    libcam_out(port, 150);
	    libcam_out(port, 182);
	    libcam_out(port, 150);

	    /* read most significant 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d4 = dat & 120;

	  fastlineread_hx5_misspix2:

	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);

	}

	/* vertical shift */
	libcam_out(port, 0);
	libcam_out(port, 1);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 0);
	libcam_out(port, 84);
	libcam_out(port, 85);
	libcam_out(port, 84);
	for (xx = 0, x = 0; x < cam->bd10; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}

    }
}

void fastlineread_win_hx5(struct camprop *cam, unsigned short *buf)
{

    unsigned short port = cam->port;
    unsigned short d1 = 0, d2 = 0, d3 = 0, d4 = 0;
    unsigned short port2;
    int z, y, b, wend, w;
    unsigned long x, xx, a[10];
    unsigned short dat, databyte;
    port2 = port + 1;

    libcam_out(port, 84);
    libcam_out(port, 6);
    libcam_out(port, 38);	/* amp on */
    libcam_out(port, 6);
    libcam_out(port, 84);
    libcam_out(port, 85);
    libcam_out(port, 84);

    /*for (y=0;y<=9;y++) { */
    for (y = 0; y < cam->nb_deadbeginphotoy; y++) {
	libcam_out(port, 0);
	libcam_out(port, 1);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 0);
	libcam_out(port, 84);
	libcam_out(port, 85);
	libcam_out(port, 84);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
    }

    /* --- phi-H sans numerisation --- */
    wend =
	2 * (cam->nb_deadbeginphotox + cam->nb_deadendphotox +
	     cam->nb_photox);
    for (w = 0; w <= wend; w++) {
	libcam_out(port, 6);
	/* move pixel charge to output */
	libcam_out(port, 7);
	for (xx = 0, x = 0; x < cam->bd2; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	libcam_out(port, 84);
	libcam_out(port, 85);
	libcam_out(port, 84);
    }

    for (z = 0; z < cam->h; z++) {

	for (b = 0; b < cam->biny; b++) {
	    /* vertical shift */
	    libcam_out(port, 0);
	    libcam_out(port, 1);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 0);
	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	}

	/* === vide les pixels inutiles en debut de ligne === */
	for (y = 0; y < cam->nb_deadbeginphotox + cam->x1; y++) {
	    /* horizontal clock and trigger data download into FI */
	    libcam_out(port, 6);
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);
	}

	/* === numerise les pixels utiles === */
	for (y = 0; y < cam->w; y++) {
	    /* horizontal clock and trigger data download into FI */
	    libcam_out(port, 6);
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    d2 = d2 * 16;
	    d3 = (unsigned short) (d3 / 8);

	    databyte = (d1 + d2) * 32 + d3 + d4 + d4;
	    *(buf++) = (unsigned short) (databyte);
	    for (xx = 0, x = 0; x < cam->bd10; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }

	    /* take account for horizontal binning */
	    for (b = 1; b < cam->binx; b++) {
		libcam_out(port, 6);
		libcam_out(port, 70);
	    }

	    /* convert */
	    libcam_out(port, 102);
	    libcam_out(port, 70);

	    /* read least significant 4 bits from FI register */
	    dat = (unsigned short) libcam_in(port2);
	    d1 = dat & 120;
	    libcam_out(port, 86);
	    libcam_out(port, 118);
	    libcam_out(port, 86);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d2 = dat & 120;
	    libcam_out(port, 134);
	    libcam_out(port, 166);
	    libcam_out(port, 134);

	    /* read next 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d3 = dat & 120;
	    libcam_out(port, 150);
	    libcam_out(port, 182);
	    libcam_out(port, 150);

	    /* read most significant 4 bits */
	    dat = (unsigned short) libcam_in(port2);
	    d4 = dat & 120;

	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);
	}

	/* === vide les pixels inutiles en fin de ligne === */
	for (y = cam->nb_deadbeginphotox + 1 + cam->x2;
	     y <=
	     cam->nb_deadbeginphotox + 1 + cam->x2 +
	     cam->nb_deadendphotox; y++) {
	    /* horizontal clock and trigger data download into FI */
	    libcam_out(port, 6);
	    libcam_out(port, 7);
	    for (xx = 0, x = 0; x < cam->bd2; x++) {
		a[xx] = (unsigned long) (0);
		if (++xx > 9) {
		    xx = 0;
		}
	    }
	    libcam_out(port, 84);
	    libcam_out(port, 85);
	    libcam_out(port, 84);
	}
    }
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

void starlight_cam_test_out(struct camprop *cam, unsigned long nb_out)
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

/*
 * Entree sur un port.
 */
unsigned char libcam_in2(unsigned short a)
{
#if defined(__linux__)
   inb(a);
   return inb(a);
#else
   _asm {
      mov dx, a 
	  in al, dx 
	  in al, dx
   }
#endif
    /* ne pas mettre de return */ }
