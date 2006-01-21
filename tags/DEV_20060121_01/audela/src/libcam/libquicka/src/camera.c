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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <math.h>

#include "camera.h"
#include <libcam/util.h>

//#define LIBQUICKA_LOGFILE

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"audine",			/* camera name */
     "kaf401",			/* ccd name */
     768, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
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
    {"audine",			/* camera name */
     "kaf1602",			/* ccd name */
     1536, 1024,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
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
    {"audine",			/* camera name */
     "kaf3200",			/* ccd name */
     2184, 1472,		/* maxx maxy 2175, 1442 */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     6.8e-6, 6.8e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
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
static int cam_close(struct camprop *cam);
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
    cam_init,			/* init */
    cam_close,			/* close */
    cam_set_binning,		/* set_binning */
    cam_update_window,		/* update_window */
    cam_start_exp,		/* start_exp */
    cam_stop_exp,		/* stop_exp */
    cam_read_ccd,		/* read_ccd */
    cam_shutter_on,		/* shutter_on */
    cam_shutter_off,		/* shutter_off */
    NULL,			/* ampli_on */
    NULL,			/* ampli_off */
    cam_measure_temperature,	/* measure_temperature */
    cam_cooler_on,		/* cooler_on */
    cam_cooler_off,		/* cooler_off */
    cam_cooler_check		/* cooler_check */
};

static int quicka_start(struct camprop *cam);
static int quicka_read(struct camprop *cam, unsigned short *p);
static int open_quicka(void);
static int close_quicka(void);


/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
/* cam::create quicka usb */
{
    int rr;
    short r;
    rr = open_quicka();		/* load quicka.dll functions */
    if (rr != 0) {
	sprintf(cam->msg, "Can't open quicka.dll : Error number %d", rr);
	return rr;
    }
    r = usb_loadlib();		/* ' Register the FTDI USB functions */
    if (r != 0) {
	sprintf(cam->msg,
		"QuickAudine USB interface driver not found : Error number %d",
		r);
	return r;
    }
    r = usb_init();		/* ' Check physical presence of QuickAudine interface */
    if (r != 0) {
	sprintf(cam->msg,
		"QuickAudine USB interface not connected : Error number %d",
		r);
	return r;
    }
    r = usb_end();		/* ' End of the check */
    if (r != 0) {
	sprintf(cam->msg,
		"QuickAudine USB end check not done : Error number %d", r);
	return r;
    }
    /*cam->delayshutter = 1.2; */
    cam->delayshutter = 0.0;
    cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
    cam->authorized = 1;
    cam->speed = (short) 2;
    return 0;
}

int cam_close(struct camprop *cam)
{
    close_quicka();
    return 0;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
    if (cam->authorized == 1) {
	quicka_start(cam);
    }
}

void cam_stop_exp(struct camprop *cam)
{
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
    short r;
    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	r = usb_write(255);	/*' CCD amplifier on */
	libcam_sleep(100);	/*' small delay */
	/* shutter always off for synchro and closed mode */
	if (cam->shutterindex <= 1) {
	    r = usb_write(255);	/*' Close the shutter */
	}
	quicka_read(cam, p);
    }
}

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
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
    if (binx <= 0)
	binx = 1;
    if (binx == 2)
	binx = 2;
    if (binx == 3)
	binx = 3;
    if (binx >= 4)
	binx = 4;
    if (biny <= 0)
	biny = 1;
    if (biny == 2)
	biny = 2;
    if (biny == 3)
	biny = 3;
    if (biny >= 4)
	biny = 4;
    cam->binx = binx;
    cam->biny = biny;
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

void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

int quicka_start(struct camprop *cam)
{
    short r;
    short KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode,
	ampli_mode, program, d1, d2, speed, imax, jmax;
    double delay;
#if defined(LIBQUICKA_LOGFILE)
    FILE * f;
    f = fopen("quicka.txt", "at");
    fprintf(f, "========================================\n");
    fclose(f);
#endif
    KAF = (short) (1 + cam->index_cam);
    bin_x = cam->binx;
    bin_y = cam->biny;
    x1 = (short) (1 + 1. * cam->x1 / bin_x);
    x2 = (short) (1 + 1. * cam->x2 / bin_x);
    y1 = (short) (1 + 1. * cam->y1 / bin_y);
    y2 = (short) (1 + 1. * cam->y2 / bin_y);
    if (cam->shutterindex == 0) {
	shutter = 0;
    } else {
	shutter = 1;
    }
    if (cam->shutteraudinereverse == 0) {
	shutter_mode = 0;
    } else {
	shutter_mode = 1;
    }
    if ((cam->ampliindex == 0) || (cam->ampliindex == 2)) {
	ampli_mode = 1;
    } else {
	ampli_mode = 0;
    }
    program = 1;		/* version of the QuickA internal program version */
    delay = cam->delayshutter;	/*delay in seconds between shutter close and effective reading of the images */
    if (delay > 2.4) {
	/*2.4 seconds is the max. value */
	d1 = (short) 0;
	d2 = (short) 15;
    } else {
	d1 = (short) 0;
	d2 = (short) (6.25 * delay);
    }
    speed = cam->speed;
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    fprintf(f, "Parametres passés à usb_start :\n");
    fprintf(f,
	    " KAF=%d fen=(%d %d %d %d) bin=(%d %d) shutter=(%d %d) ampli=%d program=%d d=(%d %d) speed=%d\n",
	    KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode,
	    ampli_mode, program, d1, d2, speed);
    fclose(f);
#endif
	r =
	usb_start(KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode,
		  ampli_mode, program, d1, d2, speed, &imax, &jmax);
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    fprintf(f, "Sortie de usb_start :\n");
    fprintf(f, " (%d %d)\n", imax, jmax);
    fprintf(f, " r=%d\n", r);
    fclose(f);
#endif
    if (imax != (short) cam->w) {
	cam->w = (int) imax;
	cam->x2 = cam->x1 + cam->w;
    }
    if (jmax != (short) cam->h) {
	cam->h = (int) jmax;
	cam->y2 = cam->y1 + cam->h;
    }
    if (r == 12) {
	sprintf(cam->msg,
		"QuickAudine USB interface USB not ready : Error number %d",
		r);
	return r;
    }
    if (r == 16) {
	sprintf(cam->msg,
		"Dialog problem with the QuickAudine USB interface : Error number %d",
		r);
	usb_init();
	return r;
    }
    if (r == 17) {
	sprintf(cam->msg,
		"Error: USB data transmission error : Error number %d", r);
	return r;
    }
    return 0;
}

int quicka_read(struct camprop *cam, unsigned short *p)
{
    short r;
    short imax, jmax;
    imax = (short) cam->w;
    jmax = (short) cam->h;
    r = usb_readaudine(imax, jmax, p);
    return 0;
}

/***************************************************************************/
/* open_quicka                                                         */
/***************************************************************************/
/* Returned integer value :                                                */
/* =0 : library anb import function are well loaded.                       */
/* =1 : error : did not find the library file.                             */
/*              causes can be an invalid pathname or a LD_LIBRARY_PATH not */
/*              initialized in the Unix environnements.                    */
/* =2 : error : libray file is well loaded but not the import functions not*/
/***************************************************************************/
int open_quicka(void)
{
#if defined(OS_WIN)
    quicka = LoadLibrary(QUICKA_NAME);
    if ((quicka != NULL)) {
	USB_LOADLIB =
	    (QUICKA_USB_LOADLIB *) GetProcAddress(quicka, USB_LOADLIBQ);
	if (USB_LOADLIB == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_CLOSELIB =
	    (QUICKA_USB_CLOSELIB *) GetProcAddress(quicka, USB_CLOSELIBQ);
	if (USB_CLOSELIB == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_INIT = (QUICKA_USB_INIT *) GetProcAddress(quicka, USB_INITQ);
	if (USB_INIT == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_END = (QUICKA_USB_END *) GetProcAddress(quicka, USB_ENDQ);
	if (USB_END == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_WRITE =
	    (QUICKA_USB_WRITE *) GetProcAddress(quicka, USB_WRITEQ);
	if (USB_WRITE == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_START =
	    (QUICKA_USB_START *) GetProcAddress(quicka, USB_STARTQ);
	if (USB_START == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_READAUDINE =
	    (QUICKA_USB_READAUDINE *) GetProcAddress(quicka,
						     USB_READAUDINEQ);
	if (USB_READAUDINE == NULL) {
	    close_quicka();
	    return (2);
	}
    } else {
	return (1);
    }
#endif
#if defined(OS_LIN)
    quicka = dlopen(QUICKA_NAME, RTLD_LAZY);
    if (quicka != NULL) {
	USB_LOADLIB = dlsym(quicka, USB_LOADLIBQ);
	if (USB_LOADLIB == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_CLOSELIB = dlsym(quicka, USB_CLOSELIBQ);
	if (USB_CLOSELIB == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_INIT = dlsym(quicka, USB_INITQ);
	if (USB_INIT == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_END = dlsym(quicka, USB_ENDQ);
	if (USB_END == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_WRITE = dlsym(quicka, USB_WRITEQ);
	if (USB_WRITE == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_START = dlsym(quicka, USB_STARTQ);
	if (USB_START == NULL) {
	    close_quicka();
	    return (2);
	}
	USB_READAUDINE = dlsym(quicka, USB_READAUDINEQ);
	if (USB_READAUDINE == NULL) {
	    close_quicka();
	    return (2);
	}
    } else {
	return (1);
    }
#endif
    return (0);
}

/***************************************************************************/
/* close_quicka                                                            */
/***************************************************************************/
/* Returned integer value :                                                */
/* =0 : library anb import function are well closed.                       */
/***************************************************************************/
int close_quicka(void)
{
#if defined(OS_WIN)
    FreeLibrary(quicka);
#endif
#if defined(OS_LIN)
    dlclose(quicka);
#endif
    return 0;
}
