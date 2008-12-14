/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Hi-SIS22-14",/* camera name */
     "hisis",	   /* camera product */
     "kaf400",			/* ccd name */
     768, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     16383.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     14.,			/* readnoise (e) */
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
    {"Hi-SIS22-12",		/* camera name */
     "hisis",		/* camera product */
     "kaf400",			/* ccd name */
     768, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     4095.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     14.,			/* readnoise (e) */
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
    {"Hi-SIS11",		/* camera name */
     "hisis",		   /* camera product */
     "TH7852A",			/* ccd name */
     208, 144,			/* maxx maxy */
     8, 2,			/* overscans x */
     1, 0,			/* overscans y */
     30e-6, 28e-6,		/* photosite dim (m) */
     255.,			/* observed saturation */
     0.93333333,		/* filling factor */
     30.,			/* gain (e/adu) */
     100.,			/* readnoise (e) */
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
    {"Hi-SIS23",		/* camera name */
     "hisis",		   /* camera product */
     "kaf401e",			/* ccd name */
     768, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     12.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS24",		/* camera name */
     "hisis",  		/* camera product */
     "kaf400",			/* ccd name */
     768, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     12.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS33",			/* camera name */
     "hisis",  		/* camera product */
     "TH7895M",			/* ccd name */
     512, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     19e-6, 19e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     12.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS36",			/* camera name */
     "hisis",  		/* camera product */
     "Kaf0261e",		/* ccd name */
     512, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     20e-6, 20e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     15.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS39",			/* camera name */
     "hisis",  		/* camera product */
     "kaf1001e",		/* ccd name */
     1024, 1024,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     24e-6, 24e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     14.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS43",			/* camera name */
     "hisis",  		/* camera product */
     "kaf1602e",		/* ccd name */
     1536, 1024,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     14.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS44",			/* camera name */
     "hisis",  		/* camera product */
     "kaf1600",			/* ccd name */
     1536, 1024,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     14.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Hi-SIS48",			/* camera name */
     "hisis",  		/* camera product */
     "Loral442a",		/* ccd name */
     2048, 2048,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     15e-6, 15e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     2.5,			/* gain (e/adu) */
     12.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
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

static void hisis11_fast_vidage(struct camprop *cam);
static int hisis11_read_image(struct camprop *cam, unsigned short *pix);
static void hisis11_fast_line(struct camprop *cam, unsigned short port);
static void hisis11_fast_line_bis(struct camprop *cam,
				  unsigned short port);
static void hisis11_read_pel_fast(struct camprop *cam,
				  unsigned short port);
static void hisis11_zm_rh(struct camprop *cam, unsigned short port);
static void hisis11_zi_zm(struct camprop *cam, unsigned short port);

static int hisis22_wricap(struct camprop *cam);
static void hisis22_wripar(struct camprop *cam, unsigned char ucPar);
static int hisis22_reset(struct camprop *cam);
static int hisis22_read_image12(struct camprop *cam, unsigned short *pix);
static int hisis22_read_image14(struct camprop *cam, unsigned short *pix);

static void hisis24_start_exp(struct camprop *cam);
static void hisis24_stop_exp(struct camprop *cam);
static int hisis24_read_ccd(struct camprop *cam, short *pix);
static void hisis24_readimage(struct camprop *cam, int Page,
			      short beginning, short *pix, int *result,
			      short imax, short jmax);
static void hisis24_resetccd(struct camprop *cam, int what, int *result);
static void hisis24_stopimage(struct camprop *cam, int *result);
static void hisis24_clearccd(struct camprop *cam, int what, int when,
			     int *result);
static void hisis24_digitize(struct camprop *cam, int vidage, int *result);
static void hisis24_waitcomreadfalse(struct camprop *cam, int temps,
				     int *erreur);
static void hisis24_waitcomreadtrue(struct camprop *cam, int temps,
				    int *rang, int *erreur);
static void hisis24_writebytes(struct camprop *cam, int iA, int iB,
			       int ComValid, int *result);
static void hisis24_writepar2(struct camprop *cam, int param, int address,
			      int *result);
static void hisis24_waitpageaccesstrue(struct camprop *cam, int temps,
				       int Page, int *erreur);
static void hisis24_accessmemorypage(struct camprop *cam, int Page,
				     int *result);
static void hisis24_readbyte(struct camprop *cam, int *param);
static unsigned short asm1(unsigned short P, char A);
static unsigned short asm3(unsigned short P, char B, char C);


/*
 *  Definition a structure specific for this driver
 *  (see declaration in camera.h)
 */

/* ==== Begin for Hisis24 driver ===*/
#define LPT 0
#define ISA 1
#define PORT_0 0
#define PORT_1 1
#define PORT_2 2
#define PORT_3 3
#define OBTU_SYNCHRO 0
#define OBTU_OUVERT  1
#define OBTU_FERME   2
#define False 0
#define True  1
#define PRINT_ZONE1 0x408	/* adresse du port 1 */
#define PRINT_ZONE2 0x40A	/* adresse du port 2 */
#define PRINT_ZONE3 0x40C	/* adresse du port 3 */
/* adresse de base de la carte HiSIS PC pour camera HiSIS */
#define HiSIS 0x3BC
static int imax, jmax;
/* ==== End for Hisis24 driver ===*/

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
{
   char ligne[1024], ligne2[1024];
   unsigned short Port0 = cam->port;
   /*unsigned short Port1 = cam->port+1; */
   unsigned short Port2 = cam->port + 2;
   
#ifdef OS_LIN
    if ( ! libcam_can_access_parport() ) {
	sprintf(cam->msg,"You don't have sufficient privileges to access parallel port. Camera cannot be created.");
	return 1;
    }
#endif
   
   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */

   /* specifique HISIS11 */
   cam->nb_vidages = 4;
   
   /* specifique HISIS22 */
   cam->hisis22_paramloops = 6;
   cam->hisis22_14_synchroloops = 2;
   cam->hisis22_14_readloops = 7;
   cam->hisis22_12_readloops = cam->hisis22_14_readloops;
   
   /* specifique HISI24 */
   cam->hisis24_shutter.raw = 0x94;
   cam->hisis24_bell0.raw = 0xCF;
   cam->hisis24_bell1.raw = 0x6C;
   cam->hisis24_bell2.raw = 0x6F;
   cam->hisis24_bell3.raw = 0xAC;
   cam->hisis24_filterwheel.raw = 0x17;
   cam->hisis24_fan.raw = 0xFF;
   cam->hisis24_gain.raw = 0x00;
   
   libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
   /* initialisation des microcontroleurs */
   if (strcmp(ligne, "Hi-SIS22-12") == 0) {
      if (cam->interrupt == 1) {
         libcam_bloquer();
      }
      if (cam->authorized == 1) {
         libcam_out(Port0, 0xFF);
      }
      if (cam->interrupt == 1) {
         libcam_debloquer();
      }
   }
   if ((strcmp(ligne, "Hi-SIS22-14") == 0)
      || (strcmp(ligne, "Hi-SIS23") == 0)) {
      if (cam->interrupt == 1) {
         libcam_bloquer();
      }
      if (cam->authorized == 1) {
         libcam_out(Port0, 0xFF);
      }
      if (cam->interrupt == 1) {
         libcam_debloquer();
      }
   }
   if ((strcmp(ligne, "Hi-SIS24") == 0) || (strcmp(ligne, "Hi-SIS33") == 0)
      || (strcmp(ligne, "Hi-SIS36") == 0)
      || (strcmp(ligne, "Hi-SIS43") == 0)
      || (strcmp(ligne, "Hi-SIS44") == 0)
      || (strcmp(ligne, "Hi-SIS39") == 0)
      || (strcmp(ligne, "Hi-SIS48") == 0)) {
      /* Pilote par defaut le port parallele 1 (LPT1) */
      cam->typeport = LPT;
      cam->portnum = PORT_1;
      if (argc >= 2) {
         libcam_strlwr(argv[2], ligne2);
         if (strcmp(ligne, "lpt1") == 0) {
            cam->typeport = LPT;
            cam->portnum = PORT_1;
         } else if (strcmp(ligne, "lpt2") == 0) {
            cam->typeport = LPT;
            cam->portnum = PORT_2;
         } else if (strcmp(ligne, "lpt3") == 0) {
            cam->typeport = LPT;
            cam->portnum = PORT_3;
         } else if (strcmp(ligne, "isa") == 0) {
            cam->typeport = ISA;
            cam->portnum = PORT_0;
         }
      }
      if (cam->typeport == LPT) {
         if (cam->interrupt == 1) {
            libcam_bloquer();
         }
         if (cam->authorized == 1) {
            libcam_out(Port0, 0xFF);
            libcam_out(Port2, 0x0C);
         }
         if (cam->interrupt == 1) {
            libcam_debloquer();
         }
      }
   }
   cam->hisis24_shutter.shuttermode.delay = 6;
   return 0;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
    char ligne[1024];
    short i;
    
    int result = 0;

    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* rincage */
	if (strcmp(ligne, "Hi-SIS11") == 0) {
	    cam->nb_vidages = 4;
	    for (i = 0; i < cam->nb_vidages; i++) {
		hisis11_fast_vidage(cam);
	    }
	}
	if (strcmp(ligne, "Hi-SIS22-12") == 0) {
	    result = hisis22_wricap(cam);
	}
	if ((strcmp(ligne, "Hi-SIS22-14") == 0)
	    || (strcmp(ligne, "Hi-SIS23") == 0)) {
	    result = hisis22_wricap(cam);
	}
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_start_exp(cam);
	}
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
    char ligne[256];
    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_stop_exp(cam);
	}
    }
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
    char ligne[1024];
    int result;
    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* lecture et numerisation */
	if (strcmp(ligne, "Hi-SIS11") == 0) {
	    hisis11_read_image(cam, p);
	}
	if (strcmp(ligne, "Hi-SIS22-12") == 0) {
	    result = hisis22_read_image12(cam, p);
	}
	if ((strcmp(ligne, "Hi-SIS22-14") == 0)
	    || (strcmp(ligne, "Hi-SIS23") == 0)) {
	    result = hisis22_read_image14(cam, p);
	}
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_read_ccd(cam, p);
	}
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
    char ligne[256];

    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    switch (cam->shutterindex) {
	    case 0:
		hisis24_shutter(cam, -1, 0, -1);
		break;
	    case 2:
		hisis24_shutter(cam, -1, 1, -1);
		break;
	    default:
	    case 1:
		hisis24_shutter(cam, 1, -1, -1);
	    }
	}
    }
}

void cam_shutter_off(struct camprop *cam)
{
    char ligne[256];

    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    switch (cam->shutterindex) {
	    case 0:
		hisis24_shutter(cam, -1, 0, -1);
		break;
	    case 2:
		hisis24_shutter(cam, -1, 1, -1);
		break;
	    default:
	    case 1:
		hisis24_shutter(cam, 1, -1, -1);
	    }
	}
    }
}

void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}

void cam_measure_temperature(struct camprop *cam)
{
    char ligne[256];
    float temp;

    cam->temperature = 0.;
    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_gettemp(cam, &temp);
	    cam->temperature = temp;
	}
    }
}

void cam_cooler_on(struct camprop *cam)
{
    char ligne[256];

    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_coolermax(cam);
	}
    }
}

void cam_cooler_off(struct camprop *cam)
{
    char ligne[256];

    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_cooleroff(cam);
	}
    }
}

void cam_cooler_check(struct camprop *cam)
{
    char ligne[256];

    if (cam->authorized == 1) {
	libcam_strlwr(CAM_INI[cam->index_cam].name, ligne);
	if ((strcmp(ligne, "Hi-SIS24") == 0)
	    || (strcmp(ligne, "Hi-SIS33") == 0)
	    || (strcmp(ligne, "Hi-SIS36") == 0)
	    || (strcmp(ligne, "Hi-SIS43") == 0)
	    || (strcmp(ligne, "Hi-SIS44") == 0)
	    || (strcmp(ligne, "Hi-SIS39") == 0)
	    || (strcmp(ligne, "Hi-SIS48") == 0)) {
	    hisis24_coolercheck(cam, (float) cam->check_temperature);
	}
    }
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
    if (binx > 9) {
	binx = 9;
    }
    if (biny > 9) {
	biny = 9;
    }
    if (binx < 1) {
	binx = 1;
    }
    if (biny < 1) {
	biny = 1;
    }
    cam->binx = binx;
    cam->biny = biny;
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;
    maxx = cam->nb_photox;
    maxy = cam->nb_photoy;
    /*
       if(cam->x1>cam->x2) libcam_swap(&(cam->x1),&(cam->x2));
       if(cam->x1<0) cam->x1 = 0;
       if(cam->x2>maxx-1) cam->x2 = maxx-1;

       if(cam->y1>cam->y2) libcam_swap(&(cam->y1),&(cam->y2));
       if(cam->y1<0) cam->y1 = 0;
       if(cam->y2>maxy-1) cam->y2 = maxy-1;

       cam->w = ( cam->x2 - cam->x1) / cam->binx + 1;
       cam->x2 = cam->x1 + cam->w * cam->binx - 1;
       cam->h = ( cam->y2 - cam->y1) / cam->biny + 1;
       cam->y2 = cam->y1 + cam->h * cam->biny - 1;
     */
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

    cam->w = (cam->x2 - cam->x1 ) / cam->binx + 1;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1 ) / cam->biny + 1;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;

}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

/* ================================================================ */
/* ================================================================ */
/* ======================== HISIS 11 ============================== */
/* ================================================================ */
/* ================================================================ */

void hisis11_fast_vidage(struct camprop *cam)
{
    int i, j, imax, jmax, decaligne;
    unsigned short p0 = cam->port;

    decaligne = 4;
    /* Calcul des constantes de vidage de la matrice. */
    imax =
	cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
    jmax =
	(cam->nb_photoy + cam->nb_deadbeginphotoy +
	 cam->nb_deadendphotoy) / decaligne + decaligne;

    for (j = 0; j < cam->nb_photoy; j++) {
	libcam_out(p0, 0x1C);
	libcam_out(p0, 0x1C);
	libcam_out(p0, 0x1C);
	libcam_out(p0, 0x1F);
	libcam_out(p0, 0x1F);
	libcam_out(p0, 0x1F);
    }
    for (j = 0; j < jmax; j++) {
	/* Decalage des lignes. */
	for (i = 0; i < decaligne; i++) {
	    libcam_out(p0, 0x5D);
	    libcam_out(p0, 0x5D);
	    libcam_out(p0, 0x5D);
	    libcam_out(p0, 0x5D);
	    libcam_out(p0, 0x5F);
	    libcam_out(p0, 0x5F);
	    libcam_out(p0, 0x5F);
	    libcam_out(p0, 0x5F);
	}
	/* Lecture du registre horizontal. */
	for (i = 0; i < imax; i++) {
	    libcam_out(p0, 0x57);
	    libcam_out(p0, 0x57);
	    libcam_out(p0, 0x5B);
	    libcam_out(p0, 0x5B);
	}
    }
}

int hisis11_read_image(struct camprop *cam, unsigned short *pix)
{
    int pixel;
    int countpixel;
    int x, y, bx, i, j, k;
    unsigned short p0 = cam->port;
    unsigned short p1 = cam->port + 1;
    int imax, jmax, cx1, cx2, cy1;

    countpixel = 0;

    /* Calcul des coordonnees de la    */
    /* fenetre, et du nombre de pixels */
    imax = (cam->x2 - cam->x1 + 1) / cam->binx;
    jmax = (cam->y2 - cam->y1 + 1) / cam->biny;

    cx1 = cam->nb_deadbeginphotox + (cam->x1);
    cx2 = cam->nb_photox - 1 - cam->x2 + cam->nb_deadendphotox;
    cy1 = cam->nb_deadbeginphotoy + (cam->y1);

    /* Transfert ZI->ZM */
    for (y = 0; y < cam->nb_photoy; y++)
	hisis11_zi_zm(cam, p0);

    /* On supprime les cy1 premieres lignes */
    y = 0;
    for (i = 0; i < cy1; i++, y++) {
	hisis11_zm_rh(cam, p0);
	hisis11_fast_line_bis(cam, p0);
    }

    for (i = 1; i < 60; i++) {
	hisis11_fast_line_bis(cam, p0);
    }

    /* boucle sur l'horloge verticale (transfert) */
    for (i = 0; i < jmax; i++) {

	/* Cumul des lignes (binning y) */
	for (k = 0; k < cam->biny; k++, y++)
	    hisis11_zm_rh(cam, p0);

	/* On retire les cx1 premiers pixels avec reset */
	x = 0;
	for (j = 0; j < cx1; j++, x++)
	    hisis11_read_pel_fast(cam, p0);

	/* boucle sur l'horloge horizontale (registre de sortie) */
	for (j = 0; j < imax; j++) {

	    libcam_out(p0, 0x57);
	    libcam_out(p0, 0x57);	/* Reset de la diode flottante */
	    libcam_out(p0, 0x5F);
	    libcam_out(p0, 0x5F);	/* Palier flottant */
	    libcam_out(p0, 0x4F);
	    libcam_out(p0, 0x4F);	/* Clamp on */
	    libcam_out(p0, 0x4F);
	    libcam_out(p0, 0x4F);	/* Clamp on */
	    libcam_out(p0, 0x4F);
	    libcam_out(p0, 0x4F);	/* Clamp on */
	    libcam_out(p0, 0x5F);
	    libcam_out(p0, 0x5F);	/* Clamp off */

	    /* Cumul des colonnes */
	    for (bx = 0; bx < cam->binx; bx++, x++) {
		libcam_out(p0, 0x5F);
		libcam_out(p0, 0x5F);	/* Palier flottant */
		libcam_out(p0, 0x5B);
		libcam_out(p0, 0x5B);	/* Palier video */
	    }

	    /* Conversion puis lecture du pixel */
	    libcam_out(p0, 0x5B);
	    libcam_out(p0, 0x5B);	/* Palier video ( delai supplementaire ) */

	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);	/* Conversion A->N (+delais) */
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);
	    libcam_out(p0, 0x7B);

	    pixel = libcam_in(p1) & 0xF0;	/* Lecture du poids fort + masquage */

	    libcam_out(p0, 0x3B);
	    libcam_out(p0, 0x3B);	/* Demande poids faible */
	    libcam_out(p0, 0x3B);
	    libcam_out(p0, 0x3B);

	    pixel |= ((libcam_in(p1) >> 4) & 0x0F);	/*Lecture du poids faible + masquage */

	    pixel = (pixel ^ 0x0088) & 0x00FF;	/* Inversion bits 7 et 3 */

	    *(pix + countpixel) = (unsigned short) pixel;
	    countpixel++;

	}

	/* Vidage des derniers pixels. */
	for (j = x;
	     j <
	     (cam->nb_photox + cam->nb_deadbeginphotox +
	      cam->nb_deadendphotox); j++)
	    hisis11_read_pel_fast(cam, p0);

    }

    /* Vidage des lignes apres la fenetre. */
    for (i = y;
	 i <
	 (cam->nb_photoy + cam->nb_deadbeginphotoy +
	  cam->nb_deadendphotoy); i++) {
	hisis11_zm_rh(cam, p0);
	hisis11_fast_line(cam, p0);
    }

    /*debloquer(); */

    return countpixel;
}

/*
 * Lecture rapide d'une ligne, sans numerisation du signal. Les charges sont
 * cumulees par quatre dans le registre de sortie.
*/
void hisis11_fast_line(struct camprop *cam, unsigned short port)
{
    int i;
    for (i = 0; i < 55; i++) {

	libcam_out(port, 0x57);
	libcam_out(port, 0x57);	/* reset #1 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x53);
	libcam_out(port, 0x53);	/* palier flottant #2 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x53);
	libcam_out(port, 0x53);	/* palier flottant #3 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x53);
	libcam_out(port, 0x53);	/* palier flottant #4 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */
    }
}

/*
 * Lecture rapide d'une ligne, sans numerisation du signal. Les charges sont
 * cumulees par quatre dans le registre de sortie + lecture CAN.
 */
void hisis11_fast_line_bis(struct camprop *cam, unsigned short port)
{
    int i;
    for (i = 0; i < 55; i++) {
	libcam_out(port, 0x57);
	libcam_out(port, 0x57);	/* reset #1 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x53);
	libcam_out(port, 0x53);	/* palier flottant #2 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x53);
	libcam_out(port, 0x53);	/* palier flottant #3 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x53);
	libcam_out(port, 0x53);	/* palier flottant #4 */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);	/* palier video */

	libcam_out(port, 0x7B);
	libcam_out(port, 0x7B);	/* conversion A->N */
	libcam_out(port, 0x5B);
	libcam_out(port, 0x5B);
    }
}

/*
 * Transfert d'un site du registre horizontal dans le registre de sortie.
*/
void hisis11_read_pel_fast(struct camprop *cam, unsigned short port)
{
    libcam_out(port, 0x57);
    libcam_out(port, 0x57);
    libcam_out(port, 0x5F);
    libcam_out(port, 0x5F);
    libcam_out(port, 0x5B);
    libcam_out(port, 0x5B);
}

/*
 * Transfert d'une ligne dans le registre horizontal, sans toucher a la zone image.
*/
void hisis11_zm_rh(struct camprop *cam, unsigned short port)
{
    libcam_out(port, 0x5D);
    libcam_out(port, 0x5D);
    libcam_out(port, 0x5D);
    libcam_out(port, 0x5D);
    libcam_out(port, 0x5D);
    libcam_out(port, 0x5F);
    libcam_out(port, 0x5F);
    libcam_out(port, 0x5F);
    libcam_out(port, 0x5F);
    libcam_out(port, 0x5F);
}

/*
 * Transfert d'une ligne de la zone image dans la zone memoire.
*/
void hisis11_zi_zm(struct camprop *cam, unsigned short port)
{
    libcam_out(port, 0x1C);
    libcam_out(port, 0x1C);
    libcam_out(port, 0x1C);
    libcam_out(port, 0x1C);
    libcam_out(port, 0x1F);
    libcam_out(port, 0x1F);
    libcam_out(port, 0x1F);
    libcam_out(port, 0x1F);
}

/* ================================================================ */
/* ================================================================ */
/* ======================== HISIS 22 ============================== */
/* ================================================================ */
/* ================================================================ */

/************************* wricap ****************************/
/* Hisis22                                                   */
/*===========================================================*/
/* Description :                                             */
/*   convert and send parameters                             */
/*   (ecriture des parametres de pose)                       */
/* Arguments :                                               */
/*   double dPoseR in ms                                     */
/*   int hWinX1      window first column base 1              */
/*   int hWinY1      window first line base 1                */
/*   int wWinX2      window last column (included, >= Winx1) */
/*   int wWinY2      window last line (included >= Winy1)    */
/*   int ucBinX      X binning (9 = echantilonnage 1/4)      */
/*   int ucBinY      Y binning (9 = echantilonnage 1/4)      */
/*************************************************************/
int hisis22_wricap(struct camprop *cam)
{
    int nSequence = 1;
    int ucBinX = (int) cam->binx;
    int ucBinY = (int) cam->biny;
    double dPoseR = (double) cam->exptime;
    int hWinX1 = (int) (cam->x1 + 1);
    int hWinY1 = (int) (cam->y1 + 1);
    int wWinX2 = (int) (cam->x2 + 1);
    int wWinY2 = (int) (cam->y2 + 1);
    unsigned char ucCodCom;	/* code commande */
    int result = 0;
    union {
	struct {
	    unsigned char ucPoseLo;
	    unsigned char ucPoseMe;
	    unsigned char ucPoseHi;
	    unsigned char ucDummy;
	} Pose4B;
	unsigned int dwPoseI;
    } uPose;

    uPose.dwPoseI = (long int) (dPoseR * 1000.0f / 3);	/* multiple de 3 ms */
    if (cam->shutterindex == 1) {
	ucCodCom = 0x63;	/* obturateur closed */
    } else {
	ucCodCom = 0x6F;	/* obturateur synchronized */
    }
    ucCodCom = 0x96;		/* obturateur synchronise */
    result = hisis22_reset(cam);	/* envoie ordre reset_camera */
    hisis22_wripar(cam, ucCodCom);	/* send a byte */
    hisis22_wripar(cam, uPose.Pose4B.ucPoseHi);	/* envoi poids fort pose */
    hisis22_wripar(cam, uPose.Pose4B.ucPoseMe);	/* envoi poids moyen pose */
    hisis22_wripar(cam, uPose.Pose4B.ucPoseLo);	/* envoi poids faible pose */
    hisis22_wripar(cam, (unsigned char) ((hWinX1 >> 8) & 0x00ff));	/* window left MSB base 1 */
    hisis22_wripar(cam, (unsigned char) (hWinX1 & 0x00ff));	/* window left LSB */
    hisis22_wripar(cam, (unsigned char) ((hWinY1 >> 8) & 0x00ff));	/* window upper MSB (screen convention, i.e. first line) */
    hisis22_wripar(cam, (unsigned char) (hWinY1 & 0x00ff));	/* window upper MSB */
    hisis22_wripar(cam, (unsigned char) ((wWinX2 >> 8) & 0x00ff));	/* window right MSB (included) */
    hisis22_wripar(cam, (unsigned char) (wWinX2 & 0x00ff));	/* window right LSB */
    hisis22_wripar(cam, (unsigned char) ((wWinY2 >> 8) & 0x00ff));	/* window bottom MSB (bottom is >= top) */
    hisis22_wripar(cam, (unsigned char) (wWinY2 & 0x00ff));	/* window bottom LSB */
    hisis22_wripar(cam, (unsigned char) ((ucBinX << 4) | ucBinY));	/* binning mode */
    hisis22_wripar(cam, (unsigned char) nSequence);	/* nb de poses pour la capture */
    return result;
}

/******************* wripar ******************/
/* Hisis22                                   */
/*===========================================*/
/* Ecriture d'un parametre                   */
/* Description :                             */
/*   send a parameter byte to camera         */
/*********************************************/
void hisis22_wripar(struct camprop *cam, unsigned char ucPar)
{
    unsigned short parport0 = cam->port;
    unsigned short parport1 = cam->port + 1;
    unsigned short parport2 = cam->port + 2;
    unsigned short donnee = parport0;
    unsigned short entree = parport1;
    unsigned short sortie = parport2;
    char res = 0;
    int kk, k, ktimeout;

    kk = 0;
    ktimeout = 60000;
    do {
	for (k = 0; k < cam->hisis22_paramloops; k++) {
	    res = libcam_in(entree);
	}
	if (kk++ > ktimeout) {
	    for (k = 0; k < cam->hisis22_paramloops; k++) {
		libcam_out(sortie, 0x0C);
	    }
	    return;
	}
    } while ((res & 0x40) == 0);

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(donnee, ucPar);
    }

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(sortie, 0x0D);
    }

    kk = 0;
    ktimeout = 100;
    do {
	res = libcam_in(entree);
	if (kk++ > ktimeout) {
	    break;
	}
    } while ((res & 0x40) != 0);

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(sortie, 0x0C);
    }

}

/******************** hisis22_reset_camera ********************/
/* Envoie le code de RESET a la camera.                       */
/**************************************************************/
int hisis22_reset(struct camprop *cam)
{
    unsigned short parport0 = cam->port;
    unsigned short parport1 = cam->port + 1;
    unsigned short parport2 = cam->port + 2;
    unsigned short donnee = parport0;
    unsigned short entree = parport1;
    unsigned short sortie = parport2;
    short cptr = 5000;
    int k;

    char res = 0;

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(donnee, 0x81);
    }

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(sortie, 0x0C);
    }

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(sortie, 0x0D);
    }

    do {
	for (k = 0; k < cam->hisis22_paramloops; k++) {
	    res = libcam_in(entree);
	}
	cptr--;
    } while (((res & 0x40) != 0) || (cptr == 0));

    if (cptr == 0) {
	return 1;
/*       printf("Hisis22 reset failed!\n"); */
/*       printf("Check the camera or its link.\n"); */
/*       printf("Abnormal AudeLA termination ...\n"); */
/*      exit(1);*/
    }

    for (k = 0; k < cam->hisis22_paramloops; k++) {
	libcam_out(sortie, 0x0C);
    }
    return 0;
}

int hisis22_read_image12(struct camprop *cam, unsigned short *pix)
/* --- a verifier ---*/
{
    /*unsigned short parport0=cam->port; */
    unsigned short parport1 = cam->port + 1;
    unsigned short parport2 = cam->port + 2;
    /*unsigned short donnee = parport0; */
    unsigned short entree = parport1;
    unsigned short sortie = parport2;
    unsigned short a;
    unsigned char res;
    short buffer[2048];
    int i, j;
    int countpixel = 0;
    int synchro;
    int h, w, ktimeout, k, kk;
    int hisis22_12_readloops, result = 0;

    hisis22_12_readloops = cam->hisis22_12_readloops;

    w = cam->w;
    h = cam->h;

    /*  Demande de poids fort */
    libcam_out(sortie, 0x0C);

    ktimeout = 5000000;
    for (j = 0; j < h; j++) {

	/*bloquer(); */

	for (i = 0; i < w; i++) {

	    kk = 0;
	    do {
		res = libcam_in(entree);
		if (kk++ > ktimeout) {
		    result = 1;
		    break;
		}
	    } while ((res & 0x80) == 0);
	    synchro = (res & 0x40);

	    /*  Demande du poids moyen fort */
	    libcam_out(sortie, 0x04);
	    for (k = 0; k < hisis22_12_readloops; k++) {
		res = libcam_in(entree);
	    }
	    a = ((unsigned short) res & 0x00F0) << 4;

	    /*  Demande du poids faible */
	    libcam_out(sortie, 0x00);
	    for (k = 0; k < hisis22_12_readloops; k++) {
		res = libcam_in(entree);
	    }
	    a += ((unsigned short) res & 0x00F0) >> 4;

	    /*  Demande du poids moyen faible + passage pix suivant */
	    libcam_out(sortie, 0x0A);
	    for (k = 0; k < hisis22_12_readloops; k++) {
		res = libcam_in(entree);
	    }
	    a += ((unsigned short) res & 0x00F0);

	    /*  Demande du poids fort + passage pix suivant */
	    libcam_out(sortie, 0x0E);

	    /*  Bricolage pixel */
	    a ^= 0x0888;
	    buffer[i] = a;

	    kk = 0;
	    ktimeout = 1000;
	    do {
		for (k = 0; k < hisis22_12_readloops; k++) {
		    res = libcam_in(entree);
		}
		if (kk++ > ktimeout) {
		    result = 1;
		    break;
		}
	    } while ((res & 0x80) != 0);

	    /*  Demande du poids fort */
	    libcam_out(sortie, 0x0C);

	}

	/*debloquer(); */

	for (i = 0; i < w; i++)
	    *(pix + countpixel++) = buffer[i];

    }

    libcam_out(sortie, 0x04);
    return result;

}

/* ------------------------------------------------------------------------------ */
int hisis22_read_image14(struct camprop *cam, unsigned short *pix)
{
    /*unsigned short parport0=cam->port; */
    unsigned short parport1 = cam->port + 1;
    unsigned short parport2 = cam->port + 2;
    /*unsigned short donnee = parport0; */
    unsigned short entree = parport1;
    unsigned short sortie = parport2;
    unsigned short a;
    unsigned char res;
    int countpixel = 0;
    short buffer[2048];
    int i, j, ktimeout, k, kk;
    int h, w;
    int hisis22_14_readloops, result = 0;

    hisis22_14_readloops = cam->hisis22_14_readloops;

    w = cam->w;
    h = cam->h;

    ktimeout = 5000000;
    for (j = 0; j < h; j++) {

	/*bloquer(); */

	for (i = 0; i < w; i++) {

	    for (k = 0; k < cam->hisis22_14_synchroloops; k++) {
		libcam_out(sortie, 0x04);
	    }

	    kk = 0;
	    do {
		res = libcam_in(entree);
		if (kk++ > ktimeout) {
		    result = 1;
		    break;
		}
	    } while ((res & 0x10) != 0);

	    a = (res & 0xF0) >> 4;

	    libcam_out(sortie, 0x0C);
	    for (k = 0; k < hisis22_14_readloops; k++) {
		res = libcam_in(entree);
	    }
	    a = a + (res & 0xF0);

	    libcam_out(sortie, 0x08);
	    for (k = 0; k < hisis22_14_readloops; k++) {
		res = libcam_in(entree);
	    }
	    a = a + ((res & 0xF0) << 8);

	    libcam_out(sortie, 0x02);
	    for (k = 0; k < hisis22_14_readloops; k++) {
		res = libcam_in(entree);
	    }
	    a = a + ((res & 0xF0) << 4);

	    libcam_out(sortie, 0x06);
	    a = (a >> 2) ^ 0x2222;
	    buffer[i] = a;

	    kk = 0;
	    ktimeout = 1000;
	    do {
		res = libcam_in(entree);
		if (kk++ > ktimeout) {
		    result = 1;
		    break;
		}
	    } while ((res & 0x10) == 0);

	}

/*       debloquer(); */

	for (i = 0; i < w; i++)
	    *(pix + countpixel++) = buffer[i];

    }

    libcam_out(sortie, 0x04);
    return result;
}

/* ================================================================ */
/* ================================================================ */
/* ======================== HISIS 24 ============================== */
/* ================================================================ */
/* ================================================================ */

/*#define DEBUG_HISIS24(s) MessageBox(NULL,"Hisis24 Debug",s,MB_OK)*/
#define DEBUG_HISIS24(s)

void hisis24_start_exp(struct camprop *cam)
{
#define SETPARAM(address,value)                                 \
   hisis24_writebytes(cam,address,value,1,&result);             \
   if(result!=0) {                                              \
      sprintf(s,"PB @%s,%s => %d\n",#address,#value,result);    \
      /*MessageBox(NULL,s,"HISIS-24,33,44",MB_OK+MB_ICONERROR);*/   \
      return;                                                   \
   }
#define TESTNEXIT(function)                        \
   if(result!=0) {                                 \
      sprintf(s,"PB %s => %d\n",#function,result); \
      /*MessageBox(NULL,s,"HISIS-24,33,44",MB_OK);*/   \
      return;                                      \
   }
#define BYTE0(x) ((x) & (0xFF))
#define BYTE1(x) (((x) & (0xFF00))>>8)
#define BYTE2(x) (((x) & (0xFF0000))>>16)

    int exposure, result;
    /*int PageImage = 1; */
    /*int bell=1; */
    int status;
    char s[256];

    struct {
	struct {
	    int hi;
	    int med;
	    int lo;
	} exptime;
	int binx;
	int biny;
	struct {
	    int hi;
	    int lo;
	} x1;
	struct {
	    int hi;
	    int lo;
	} y1;
	struct {
	    int hi;
	    int lo;
	} width;
	struct {
	    int hi;
	    int lo;
	} height;
    } params;

    exposure = (int) (1000. * cam->exptime);
    params.exptime.hi = BYTE2(exposure);
    params.exptime.med = BYTE1(exposure);
    params.exptime.lo = BYTE0(exposure);
    params.binx = (int) cam->binx;
    params.biny = (int) cam->biny;
    params.x1.hi = BYTE1(cam->x1 + 1);
    params.x1.lo = BYTE0(cam->x1 + 1);
    params.y1.hi = BYTE1(cam->y1 + 1);
    params.y1.lo = BYTE0(cam->y1 + 1);

    /* Cadrage en X et Y */
    imax = cam->x2 - cam->x1 + 1;
    jmax = cam->y2 - cam->y1 + 1;
    params.width.hi = BYTE1(imax);
    params.width.lo = BYTE0(imax);
    params.height.hi = BYTE1(jmax);
    params.height.lo = BYTE0(jmax);
    imax = (cam->x2 - cam->x1) / cam->binx + 1;
    if (imax < 1)
	imax = 1;
    jmax = (cam->y2 - cam->y1) / cam->biny + 1;
    if (jmax < 1)
	jmax = 1;

    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_EXPTIME_HI, params.exptime.hi);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_EXPTIME_MED, params.exptime.med);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_EXPTIME_LO, params.exptime.lo);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_BINX, params.binx);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_BINY, params.biny);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINX0_HI, params.x1.hi);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINX0_LO, params.x1.lo);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINY0_HI, params.y1.hi);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINY0_LO, params.y1.lo);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINWIDTH_HI, params.width.hi);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINWIDTH_LO, params.width.lo);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINHEIGTH_HI, params.height.hi);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    SETPARAM(HISIS24_PARAM_WINHEIGTH_LO, params.height.lo);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    hisis24_accessmemorypage(cam, 2, &result);
    TESTNEXIT(AccessMemoryPage2);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    hisis24_accessmemorypage(cam, 1, &result);
    TESTNEXIT(AccessMemoryPage1);
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);

    hisis24_digitize(cam, 1, &result);
    TESTNEXIT(Digitize);

    result = -1;
    do {
	result++;
	libcam_sleep(2);
	status = hisis24_readstatus(cam);
    } while ((status != HISIS24_STATUS_EXPOSURE)
	     && (status != HISIS24_STATUS_DIGITIZE));

}

void hisis24_stop_exp(struct camprop *cam)
{
    int result;
    hisis24_stopimage(cam, &result);
}

int hisis24_read_ccd(struct camprop *cam, short *pix)
{
    int result;

    if (pix == NULL)
	return -1;
    while (hisis24_readstatus(cam) != HISIS24_STATUS_IDLE)
	libcam_sleep(2);
    hisis24_readimage(cam, 2, 0, pix, &result, (short) imax, (short) jmax);
    return 0;
}

void hisis24_readimage(struct camprop *cam, int Page, short beginning,
		       short *pix, int *result, short imax, short jmax)
{
    char A, B, C;
    int adr;
    unsigned short P0, P1 = 0, P2 = 0;
    int erreur;
    short i, j;
    unsigned short v;
    int Request;

    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    /* demander l'acces a la page a lire */
    *result = 4;
    if (Page == 0 || Page > 2 || beginning > 1) {
	*result = 3;
    } else {

	/* On demande l'acces a la page memoire voulue */
	Request = (Page << 5) ^ 0xFF;
	A = (char) Request;
	if (typeport == LPT) {
	    P0 = portnum;
	    P2 = (unsigned short) (P0 + 2);
	    libcam_out(P2, 0x0D);	/* fermeture du bus de controle, Latch=0 */
	    libcam_out(P0, 0xFC);
	    libcam_out(P0, 0xFC);
	    libcam_out(P2, 0x0C);	/* ouverture du bus de controle, Latch=1 */
	} else {
	    P0 = HiSIS;
	    P1 = (unsigned short) (P0 + 1);
	    libcam_out(P1, 0x01);	/* fermeture du bus de controle, Latch=0 */
	    libcam_out(P0, 0xFC);
	    libcam_out(P0, 0xFC);
	    libcam_out(P1, 0x03);	/* ouverture du bus de controle, Latch=1 */
	}
	libcam_out(P0, (char) (Request & 0xFC));

	/* attendre l'acces a la page */
	hisis24_waitpageaccesstrue(cam, 100, Page, &erreur);

	if (erreur == True) {
	    *result = 7;
	} else {
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xFC & A));
	    libcam_out(P0, (char) (0xFC & A));
	    libcam_out(P0, (char) (0xFC & A));
	    libcam_out(P0, (char) (0xFC & A));

	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xEC & A));
	    libcam_out(P0, (char) (0xFC & A));
	    libcam_out(P0, (char) (0xFC & A));
	    libcam_out(P0, (char) (0xFC & A));
	    libcam_out(P0, (char) (0xFC & A));


	    if (typeport == LPT) {
		adr = 0;
		for (j = 0; j < jmax; j++)
		    for (i = 0; i < imax; i++)
			pix[adr++] = asm1(P0, A);
	    } else {
		B = (char) (Request & 0xF0);
		C = (char) (Request & 0xF8);
		for (j = 0; j < jmax; j++) {
		    adr = (jmax - j - 1) * imax;
		    for (i = 0; i < imax; i++, adr++) {
			/* v=asm2(HiSIS,A); */
			v = asm3(HiSIS, B, C);
			if (v > 32767)
			    v = 32767;
			*(pix + adr) = (short) v;
		    }
		}
	    }

	    *result = 0;

	    libcam_out(P0, (char) (0xFC & Request));
	    libcam_out(P0, (char) (0xFC & Request));

	    /* fermeture du bus de controle, Latch=0 */
	    if (typeport == LPT) {
		libcam_out(P2, 0x0D);
	    } else {
		libcam_out(P1, 0x01);
	    }
	}
    }
}

void hisis24_resetccd(struct camprop *cam, int what, int *result)
{
    int A, B;

    *result = 4;
    if ((what & 0xA8) != 0)
	*result = 3;
    if (*result != 3) {
	A = 0xE0;
	B = what;
	hisis24_writevercom(cam, A, B, result);
    }
}

void hisis24_stopimage(struct camprop *cam, int *result)
{
    int A, B;

    *result = 4;
    A = 0xF0;
    B = 0;
    hisis24_writevercom(cam, A, B, result);
}

void hisis24_clearccd(struct camprop *cam, int what, int when, int *result)
{
    int A, B;

    *result = 4;
    if (what != 1 && what != 4 && what != 8 && what != 9 && what != 12)
	*result = 3;
    if (when != 0x10 && when != 0x40)
	*result = 3;
    if (*result != 3) {
	A = 0xB0;
	B = what + when;
	hisis24_writevercom(cam, A, B, result);
    }
}

void hisis24_digitize(struct camprop *cam, int vidage, int *result)
{
    int A, B;

    *result = 4;
    A = 0xC0;
    if (vidage == 0)
	A = 0xC1;
    B = 0x0F;
    hisis24_writevercom(cam, A, B, result);
}

/************** WaitComReadFalse *************/
/* Hisis24                                   */
/*===========================================*/
/* Procedure de verification du niveau logi- */
/* que de la ligne ComRead.                  */
/* Le niveau logique souhaite est attendu    */
/* pendant "temps" x 1ms. Une erreur est     */
/* generee si le niveau logique souhaite n'  */
/* existe toujours pas au terme de la tempo- */
/* risation choisie                          */
/*********************************************/
void hisis24_waitcomreadfalse(struct camprop *cam, int temps, int *erreur)
{
    int Fin, Count, A;
    unsigned short P0 = 0, P1 = 0;
    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    switch (typeport) {
    case LPT:
	P0 = portnum;
	P1 = (unsigned short) (P0 + 1);
	break;
    case ISA:
	P0 = HiSIS;
	break;
    }
    *erreur = False;
    Fin = False;
    Count = 0;

    do {
	switch (typeport) {
	case LPT:
	    A = libcam_in(P1);
	    if ((A & 0x40) == 0x40) {
		Fin = True;
		libcam_out(P0, 0xFC);	/* ou 0xFF */
		libcam_out(P0, 0xFC);	/* ou 0xFF */
		libcam_out(P0, 0xFC);	/* ou 0xFF */
		A = libcam_in(P1) ^ 0x80;
	    }
	    break;
	case ISA:
	    A = libcam_in(P0);
	    if ((A & 0x04) == 0x04)
		Fin = True;	/* test ComRead */
	    break;
	}
	if (Fin == False) {
	    libcam_sleep(1);
	    Count++;
	    if (Count >= temps) {
		*erreur = True;
		Fin = True;
	    }
	}
    } while (Fin != True);	/* controle ComRead=1 */
}


/************** WaitComReadTrue **************/
/* Hisis24                                   */
/*===========================================*/
/* Procedure de verification du niveau logi- */
/* que de la ligne ComRead.                  */
/* Le niveau logique souhaite est attendu    */
/* pendant "temps" x 1ms. Une erreur est     */
/* generee si le niveau logique souhaite n'  */
/* existe toujours pas au terme de la tempo- */
/* risation choisie                          */
/*********************************************/
void hisis24_waitcomreadtrue(struct camprop *cam, int temps, int *rang,
			     int *erreur)
{
    int Fin, Count, A = 0;
    unsigned short P0 = 0, P1 = 0;
    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    switch (typeport) {
    case LPT:
	P0 = portnum;
	P1 = (unsigned short) (P0 + 1);
	break;
    case ISA:
	P0 = HiSIS;
	break;
    }

    *erreur = False;
    Fin = False;
    Count = 0;

    do {
	switch (typeport) {
	case LPT:{
		A = libcam_in(P1);
		if ((A & 0x40) == 0) {
		    Fin = True;
		    libcam_out(P0, 0x7D);	/* ou 0x7F */
		    libcam_out(P0, 0x7D);	/* ou 0x7F */
		    libcam_out(P0, 0x7D);	/* ou 0x7F */
		    A = libcam_in(P1) ^ 0x80;
		    libcam_out(P0, 0x7C);	/* ou 0x7C */
		}
		break;
	    }
	case ISA:{
		A = libcam_in(P0);
		if ((A & 0x04) == 0)
		    Fin = True;
		break;
	    }
	}
	if (Fin == False) {
	    libcam_sleep(1);
	    Count++;
	    if (Count >= temps) {
		*erreur = True;
		Fin = True;
	    }
	}
    } while (Fin != True);	/* controle ComRead=1 */

    A = A >> 4;
    switch (A) {
    case 12:
	*rang = 1;
	break;
    case 10:
	*rang = 2;
	break;
    case 6:
	*rang = 3;
	break;
    default:
	*rang = 0;
    }
}


/***************** WriteBytes ****************/
/* Hisis24                                   */
/*===========================================*/
/* Procedure de verification du niveau logi- */
/* Procedure d'ecriture et de lecture de     */
/* commandes ou parametres. A et B contie-   */
/* nnent les informations a transmettre, et  */
/* result retourne le resultat de la communi */
/* cation. La procedure d'ecriture calcule   */
/* la checksum a transmettre et controle la  */
/* checksum calculee par la camera que de la */
/* ligne ComRead.                            */
/*********************************************/
void hisis24_writebytes(struct camprop *cam, int iA, int iB, int ComValid,
			int *result)
{
    int T1 = 100;		/* temporisation avant reponse camera */
    int T2 = 20;		/* temporisation communication */
    int erreur, rang;
    char Sum;
    char A = (char) iA;
    char B = (char) iB;
    unsigned short P0, P1, P2;
    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    *result = 4;
    rang = 0;

    if (typeport == LPT) {
	P0 = portnum;
	P1 = (unsigned short) (P0 + 1);
	P2 = (unsigned short) (P0 + 2);
	libcam_out(P2, 0x09);	/* fermeture du bus de controle, Latch=0 */
	libcam_out(P0, A);	/* premier octet a transmettre */
	libcam_out(P0, A);
	libcam_out(P0, A);
	libcam_out(P2, 0x0D);	/* generation front montant Clock */
	libcam_out(P2, 0x0D);
	libcam_out(P0, 0xFC);	/* ou 0xFE */
	libcam_out(P0, 0xFC);	/* ou 0xFE */
	libcam_out(P2, 0x0C);	/* ouverture du bus de controle, Latch=1 */
    } else {
	P0 = HiSIS;
	P1 = (unsigned short) (P0 + 1);
	P2 = (unsigned short) (P0 + 2);
	libcam_out(P1, 0x00);	/* fermeture du bus de controle, Latch=0 */
	libcam_out(P0, A);	/* premier octet a transmettre */
	libcam_out(P0, A);
	libcam_out(P0, A);
	libcam_out(P1, 0x01);	/* generation front montant Clock */
	libcam_out(P1, 0x01);
	libcam_out(P0, 0xFC);
	libcam_out(P0, 0xFC);
	libcam_out(P1, 0x03);	/* ouverture du bus de controle, Latch=1 */
    }

    hisis24_waitcomreadfalse(cam, T1, &erreur);
    if (erreur == False) {
	libcam_out(P0, 0x7C);	/* ou 0x7E */
	libcam_out(P0, 0x7C);	/* ou 0x7E */
	hisis24_waitcomreadtrue(cam, T1, &rang, &erreur);	/* attendre ComRead=0 */
	if ((erreur == True) || (rang != 1))
	    *result = 1;
	libcam_out(P0, 0xFC);	/* ou 0xFE */
	libcam_out(P0, 0xFC);	/* ou 0xFE */
	switch (typeport) {
	case LPT:
	    libcam_out(P2, 0x09);	/* fermeture du bus de controle, Latch=0 */
	    break;
	case ISA:
	    libcam_out(P1, 0);	/* fermeture du bus de controle, Latch=0 */
	    break;
	}
    } else {
	*result = 1;
    }

    if (*result != 1) {
	libcam_out(P0, B);	/* deuxieme octet a transmettre */
	libcam_out(P0, B);
	libcam_out(P0, B);
	if (typeport == LPT) {
	    libcam_out(P2, 0x0D);	/* generation front montant Clock */
	    libcam_out(P2, 0x0D);
	    libcam_out(P0, 0xFC);	/* ou 0xFE */
	    libcam_out(P0, 0xFC);	/* ou 0xFE */
	    libcam_out(P2, 0x0C);	/* ouverture du bus de controle, Latch=1 */
	    libcam_out(P2, 0x0C);
	} else {
	    libcam_out(P1, 0x01);	/* generation front montant Clock */
	    libcam_out(P1, 0x01);
	    libcam_out(P0, 0xFC);	/* ou 0xFE */
	    libcam_out(P0, 0xFC);	/* ou 0xFE */
	    libcam_out(P1, 0x03);	/* ouverture du bus de controle, Latch=1 */
	    libcam_out(P1, 0x03);
	}

	hisis24_waitcomreadfalse(cam, T2, &erreur);

	if (erreur == False) {
	    libcam_out(P0, 0x7C);	/* ou 0x7E */
	    libcam_out(P0, 0x7C);	/* ou 0x7E */
	    hisis24_waitcomreadtrue(cam, T2, &rang, &erreur);	/* attendre ComRead=0 */

	    if (erreur == True)
		*result = 2;
	    libcam_out(P0, 0xFC);	/* ou 0xFE */
	    libcam_out(P0, 0xFC);	/* ou 0xFE */
	    if (typeport == LPT) {
		libcam_out(P2, 9);	/* fermeture du bus de controle, Latch=0 */
	    } else {
		libcam_out(P1, 0);	/* fermeture du bus de controle, Latch=0 */
	    }
	} else {
	    *result = 2;
	}

	if (*result != 2) {
	    Sum = (char) (A + B);	/* calcul checksum */
	    libcam_out(P0, Sum);	/* checksum a transmettre */
	    libcam_out(P0, Sum);
	    libcam_out(P0, Sum);
	    if (typeport == LPT) {
		libcam_out(P2, 0x0D);	/* generation front montant Clock */
		libcam_out(P2, 0x0D);
		libcam_out(P0, 0xFC);	/* ou 0xFE */
		libcam_out(P0, 0xFC);	/* ou 0xFE */
		libcam_out(P2, 0x0C);	/* ouverture du bus de controle, Latch=1 */
		libcam_out(P2, 0x0C);
	    } else {
		libcam_out(P1, 1);	/* generation front montant Clock */
		libcam_out(P1, 1);
		libcam_out(P0, 0xFC);	/* ou 0xFE */
		libcam_out(P0, 0xFC);	/* ou 0xFE */
		libcam_out(P1, 3);	/* ouverture du bus de controle, Latch=1 */
		libcam_out(P1, 3);
	    }

	    hisis24_waitcomreadfalse(cam, T2, &erreur);

	    if (erreur == False) {
		libcam_out(P0, 0x7C);	/* ou 0x7E */
		libcam_out(P0, 0x7C);	/* ou 0x7E */
		hisis24_waitcomreadtrue(cam, T2, &rang, &erreur);	/* attendre ComRead=0 */
		if (erreur == True)
		    *result = 2;
	    } else {
		*result = 2;
	    }

	    if (*result != 2) {
		if (typeport == LPT) {
		    Sum = (char) libcam_in(P1);
		    if ((Sum & 0x80) == 0x80)
			*result = 0;	/* controle checksum */
		    else
			*result = 2;
		} else {
		    Sum = (char) libcam_in(P0);
		    if ((Sum & 8) == 0)
			*result = 0;	/* controle checksum */
		    else
			*result = 2;
		}
	    }

	    if (ComValid == 1) {
		libcam_out(P0, 0xFC);	/* ou 0xFE */
		libcam_out(P0, 0xFC);	/* ou 0xFE */
		hisis24_waitcomreadfalse(cam, T2, &erreur);	/* debug */
	    }
	}
    }

    if (ComValid == 1) {
	if (typeport) {
	    libcam_out(P2, 0x0D);
	} else {
	    libcam_out(P1, 0x01);	/* fermeture du bus de controle, Latch=0 */
	}
    }
}

void hisis24_writepar2(struct camprop *cam, int address, int param,
		       int *result)
{
    int A, B;

    if (address >= 0 && address <= 63) {
	if ((address >= 0 && address <= 8)
	    || (address >= 11 && address <= 49) || (address >= 52
						    && address <= 58)
	    || (address >= 62 && address <= 63)) {
	    *result = 4;
	    A = address;
	    B = param;
	    hisis24_writebytes(cam, A, B, 1, result);
	} else {
	    *result = 6;
	}
    } else {
	*result = 5;
    }
}

void hisis24_writevercom(struct camprop *cam, int A, int B, int *result)
{
    hisis24_writebytes(cam, A, B, 1, result);
    if (*result != 0) {
	libcam_sleep(20);
	hisis24_writebytes(cam, A, B, 1, result);
	if (*result != 0) {
	    libcam_sleep(20);
	    hisis24_writebytes(cam, A, B, 1, result);
	}
    }
}

void hisis24_writeverparam(struct camprop *cam, int A, int B, int *result)
{
    hisis24_writepar2(cam, A, B, result);
    if (*result != 0) {
	libcam_sleep(20);
	hisis24_writepar2(cam, A, B, result);
	if (*result != 0) {
	    libcam_sleep(20);
	    hisis24_writepar2(cam, A, B, result);
	}
    }
}

void hisis24_readbyte(struct camprop *cam, int *param)
{
    unsigned short P0, P1, P2;
    int portnum, typeport;
    int p;

    portnum = cam->port;
    typeport = cam->typeport;

    if (typeport == LPT) {
	P0 = portnum;
	P1 = (unsigned short) (P0 + 1);
	P2 = (unsigned short) (P0 + 2);
	libcam_out(P0, 0x7D);	/* ou 0x7F */
	libcam_out(P0, 0x7D);	/* ou 0x7F */
	libcam_out(P2, 0x0C);	/*////////// */
	p = libcam_in(P1);
	p = libcam_in(P1);
	libcam_out(P0, 0xFD);	/* ou 0xFF */
	libcam_out(P0, 0xFD);	/* ou 0xFF */
	libcam_out(P2, 0x0D);
	*param = ((p ^ 0x80) & 0xF0) >> 4;
    } else {
	P0 = HiSIS;
	P1 = (unsigned short) (P0 + 1);
	P2 = (unsigned short) (P0 + 2);
	libcam_out(P0, 0x7D);
	libcam_out(P0, 0x7D);
	libcam_out(P1, 0x03);
	p = libcam_in(P0);
	p = libcam_in(P0);
	libcam_out(P0, 0xFD);
	libcam_out(P0, 0xFD);
	libcam_out(P1, 0x01);
	*param = p;
    }
}

void hisis24_readpar(struct camprop *cam, int *param, int nibble,
		     int address, int *result)
{
    int A, B;
    if (address >= 0 && address <= 63) {
	*result = 4;
	A = 0x40 + address;
	B = nibble;
	if (B != 1)
	    B = 0;
	hisis24_writebytes(cam, A, B, 0, result);
	if (*result == 0) {
	    hisis24_readbyte(cam, param);
	}
    } else {
	*result = 5;
    }
}

void hisis24_waitpageaccesstrue(struct camprop *cam, int temps, int Page,
				int *erreur)
{
    short Fin, Count;
    unsigned short P0, P1;
    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    Fin = False;
    Count = 0;
    *erreur = False;

    do {
	if (typeport == LPT) {
	    P1 = portnum + 1;
	    if ((libcam_in(P1) & (Page << 4)) == 0)
		Fin = True;
	} else {
	    P0 = HiSIS;
	    if ((libcam_in(P0) & Page) == 0)
		Fin = True;
	}
	if (Fin == False) {
	    libcam_sleep(2);
	    Count++;
	    if (Count >= temps) {
		*erreur = True;
		Fin = True;
	    }
	}
    } while (Fin != True);	/* attendre Page1 ou Page2=0 */
}

void hisis24_accessmemorypage(struct camprop *cam, int Page, int *result)
{
    int Request, erreur;
    unsigned short P0, P1 = 0, P2 = 0;
    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    /* demander l'acces a la page a lire */
    *result = 4;
    erreur = False;
    if ((Page == 0) || (Page > 2)) {
	*result = 3;
    } else {
	Request = (Page << 5) ^ 0xFF;
	if (typeport == LPT) {
	    P0 = portnum;
	    P2 = (unsigned short) (P0 + 2);
	    libcam_out(P2, 0x0D);	/* fermeture du bus de controle, Latch=0 */
	    libcam_out(P0, 0xFC);
	    libcam_out(P0, 0xFC);
	    libcam_out(P2, 0x0C);	/* ouverture du bus de controle, Latch=1 */
	} else {
	    P0 = HiSIS;
	    P1 = (unsigned short) (P0 + 1);
	    libcam_out(P1, 1);	/* fermeture du bus de controle, Latch=0 */
	    libcam_out(P0, 0xFC);
	    libcam_out(P0, 0xFC);
	    libcam_out(P1, 3);	/* ouverture du bus de controle, Latch=1 */
	}
	libcam_out(P0, (char) (Request & 0xFC));

	hisis24_waitpageaccesstrue(cam, 100, Page, &erreur);
	if (erreur == True)
	    *result = 7;
	else
	    *result = 0;

	/* fermeture des bus */
	libcam_out(P0, (char) (0xFC & Request));
	libcam_out(P0, (char) (0xFC & Request));
	if (typeport == LPT) {
	    libcam_out(P2, 0x0D);	/* fermeture du bus de controle, Latch=0 */
	} else {
	    libcam_out(P1, 1);	/* fermeture du bus de controle, Latch=0 */
	}
    }
}

/************************* PORTADR **************************/
/* Retourne l'adresse de base d'un port imprimante          */
/************************************************************/
/*
unsigned short PortAdr(int numero)
{
   unsigned short port;
   short *ptr;

   switch(numero) {
      case PORT_2:
         ptr=(short *)PRINT_ZONE2;
         port=(unsigned short)*ptr;
         break;
      case PORT_3:
         ptr=(short *)PRINT_ZONE3;
         port=(unsigned short)*ptr;
         break;
      case PORT_1:
      default:
         ptr=(short *)PRINT_ZONE1;
         port=(unsigned short)*ptr;
         // port=0x378;
   }

   return port;
}
*/
/************************* HI *************************/
/* Retourne l'octet de poids fort d'un entier 16 bits */
/******************************************************/
/*char Hi(int valeur)
{
   return (char)((valeur>>8)&0xFF);
}
*/
/************************** LO **************************/
/* Retourne l'octet de poids faible d'un entier 16 bits */
/********************************************************/
/*
char Lo(int valeur)
{
   return (char)(valeur&0xFF);
}
*/

/*====== Lecture memoire via le port parallele =======*/
/*
unsigned short asm1(unsigned short P,char A)
{
   _asm {
      mov dx, P
      mov ah, A
      mov al,ah
      and al,0F0h
      out dx,al
      inc dx
      in  al,dx
      mov bl,al
      mov cl,4
      shr bl,cl
      dec dx
      mov al,ah
      and al,0F1h
      out dx,al
      inc dx
      in  al,dx
      and al,0F0h
      add bl,al
      dec dx
      mov al,ah
      and al,0F3h
      out dx,al
      inc dx
      in  al,dx
      and al,0F0h
      mov bh,al
      dec dx
      mov al,ah
      and al,0F2h
      out dx,al
      inc dx
      in  al,dx
      mov cl,4
      shr al,cl
      add bh,al
      xor bx,8888h
      dec dx
      mov al,ah
      and al,0F8h
      out dx,al
      mov ax,bx
   }
}
*/

/*====== Lecture memoire via la carte PC =======*/
/*
unsigned short asm2(unsigned short P,char A)
{
   __asm {
      mov dx, P
      mov cl, A
      mov al,cl
      and al,0F0h
      out dx,al
      in  ax,dx
      mov bx,ax
      mov al,cl
      and al,0F8h
      out dx,al
      mov ax,bx
   }
}*/

/*====== Lecture memoire via la carte PC =======*/
/*====== version rapide                  =======*/
/*
unsigned short asm3(unsigned short P,char B,char C)
{
   __asm {
      mov dx, P
      mov ch, B
      mov cl, C
      mov al,ch
      out dx,al
      in  ax,dx
      mov bx,ax
      mov al,cl
      out dx,al
      mov ax,bx
   }
}
*/

unsigned short asm1(unsigned short P, char A)
{
    unsigned short pix;
    unsigned short P1 = P + 1;
    unsigned short a, b, c, d;

    libcam_out(P, (unsigned char) (A & 0xF0));
    a = (unsigned short) libcam_in(P1) & 0xF0;
    libcam_out(P, (unsigned char) (A & 0xF1));
    b = (unsigned short) libcam_in(P1) & 0xF0;
    libcam_out(P, (unsigned char) (A & 0xF3));
    d = (unsigned short) libcam_in(P1) & 0xF0;
    libcam_out(P, (unsigned char) (A & 0xF2));
    c = (unsigned short) libcam_in(P1) & 0xF0;
    pix = ((d << 8) | (c << 4) | b | (a >> 4)) ^ 0x8888;
    libcam_out(P, (unsigned char) (A & 0xF8));
    return pix;
}

unsigned short asm3(unsigned short P, char B, char C)
{
    unsigned short ret;
    libcam_out(P, B);
    ret = libcam_inw(P);
    libcam_out(P, C);
    return ret;
}


/* ================================================================ */
/* ================================================================ */
/* ======================== TEST     ============================== */
/* ================================================================ */
/* ================================================================ */

void hisis_test_out(struct camprop *cam, unsigned long nb_out)
{
    unsigned short port;
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

int hisis24_fan(struct camprop *cam, int on, int pwr)
{
    int access = 0;
    int data;
    int result = -1;

    if (on >= 0) {
	cam->hisis24_fan.fanmode.on = on;
	access = 1;
    }
    if ((pwr >= HISIS24_FAN_PWRMIN) && (pwr <= HISIS24_FAN_PWRMAX)) {
	cam->hisis24_fan.fanmode.pwr = pwr;
	access = 1;
    }
    if (access == 1) {
	data = cam->hisis24_fan.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_FAN, data, &result);
    }
    return result;
}

int hisis24_shutter(struct camprop *cam, int synchro, int open, int delay)
{
    int access = 0;
    int data;
    int result = -1;

    if (synchro >= 0) {
	cam->hisis24_shutter.shuttermode.synchro = synchro;
	cam->hisis24_shutter.shuttermode.open = 0;
	access = 1;
    }
    if (open >= 0) {
	cam->hisis24_shutter.shuttermode.synchro = 0;
	cam->hisis24_shutter.shuttermode.open = open;
	access = 1;
    }
    if ((delay >= HISIS24_SHUTTER_DLYMIN)
	&& (delay <= HISIS24_SHUTTER_DLYMAX)) {
	cam->hisis24_shutter.shuttermode.delay = delay;
	access = 1;
    } else if (delay > HISIS24_SHUTTER_DLYMAX) {
	access = 0;
	result = HISIS24_DRV_SHUTTER_EXCEED_DELAY;
    }

    if (access == 1) {
	data = cam->hisis24_shutter.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_SHUTTER, data, &result);
    }
    return result;
}

int hisis24_bell(struct camprop *cam, int bell)
{
    int access = 0;
    int result = -1;
    int data;

    if (bell == 1) {
	cam->hisis24_bell0.raw = 0xCF;
	cam->hisis24_bell1.raw = 0x6C;
	cam->hisis24_bell2.raw = 0x6F;
	cam->hisis24_bell3.raw = 0xAC;
	access = 1;
    } else if (bell == 0) {
	cam->hisis24_bell0.raw = 0x00;
	cam->hisis24_bell1.raw = 0x00;
	cam->hisis24_bell2.raw = 0x00;
	cam->hisis24_bell3.raw = 0x00;
	access = 1;
    }
    if (access == 1) {
	data = cam->hisis24_bell0.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_BUZZER_0, data, &result);
	data = cam->hisis24_bell1.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_BUZZER_1, data, &result);
	data = cam->hisis24_bell2.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_BUZZER_2, data, &result);
	data = cam->hisis24_bell3.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_BUZZER_3, data, &result);
    }
    return result;
}

int hisis24_filterwheel(struct camprop *cam, int enable, int nb, int *fnb)
{
    /*int access = 0; */
    int data;
    int result = -1;

    int cond1, cond2;

    cond1 = (enable == 0) || (enable == 1);
    cond2 = (nb >= FILTERWHEEL_NB_MIN) && (nb <= FILTERWHEEL_NB_MAX);

    if (cond1 || cond2) {
	hisis24_readpar(cam, &data, 0, HISIS24_PARAM_FILTERWHEEL, &result);
	cam->hisis24_filterwheel.raw =
	    (cam->hisis24_filterwheel.raw & 0xF0) | (data & 0xF);
	if (result != 0)
	    return result;
	/* On teste si la camera est equipee d'une roue a filtres */
	if ((data & 7) == 7)
	    return HISIS24_DRV_FW_NO_FW;

	if (cond1)
	    cam->hisis24_filterwheel.filterwheelmode.enable = enable;
	if (cond2) {
	    if (cam->hisis24_filterwheel.filterwheelmode.enable) {
		cam->hisis24_filterwheel.filterwheelmode.filter = nb;
	    } else {
		return HISIS24_DRV_FW_NOT_ENABLED;
	    }
	}
	data = cam->hisis24_filterwheel.raw;
	hisis24_writeverparam(cam, HISIS24_PARAM_FILTERWHEEL, data,
			      &result);
	if (result != 0)
	    return result;
    } else if (fnb != NULL) {
	hisis24_readpar(cam, &data, 0, HISIS24_PARAM_FILTERWHEEL, &result);
	if (result != 0)
	    return result;
	*fnb = data;
    }
    return result;
}

int hisis24_coolermax(struct camprop *cam)
{
    int result;
    int data;
    data = 0;
    /*{
       FILE *f;
       f = fopen("toto.exp","at+");
       fprintf(f,"CCDTEMPCHECK = %02X\n",data);
       fclose(f);
       } */
    hisis24_writeverparam(cam, HISIS24_PARAM_CCDTEMPCHECK, data, &result);
    return result;
}

int hisis24_cooleroff(struct camprop *cam)
{
    int result;
    int data;
    data = 4;
    /*{
       FILE *f;
       f = fopen("toto.exp","at+");
       fprintf(f,"CCDTEMPCHECK = %02X\n",data);
       fclose(f);
       } */
    hisis24_writeverparam(cam, HISIS24_PARAM_CCDTEMPCHECK, data, &result);
    return result;
}

int hisis24_coolercheck(struct camprop *cam, float temp)
{
    int result = 0;
    int data;
    if ((temp >= HISIS24_COOLER_MINTEMP)
	&& (temp <= HISIS24_COOLER_MAXTEMP)) {
	data = (int) ((temp + 41.) * 5);
	if (data > 255)
	    data = 255;
	if (data < 5)
	    data = 5;
	/*{
	   FILE *f;
	   f = fopen("toto.exp","at+");
	   fprintf(f,"CCDTEMPCHECK = %02X\n",data);
	   fclose(f);
	   } */
	hisis24_writeverparam(cam, HISIS24_PARAM_CCDTEMPCHECK, data,
			      &result);
    } else {
	if (temp < HISIS24_COOLER_MINTEMP)
	    cam->check_temperature = HISIS24_COOLER_MINTEMP;
	if (temp > HISIS24_COOLER_MAXTEMP)
	    cam->check_temperature = HISIS24_COOLER_MAXTEMP;
	result = HISIS24_DRV_PB_OUTBOUND_PARAM;
    }
    return result;
}

int hisis24_gettemp(struct camprop *cam, float *temp)
{
    int result;
    int itemp_hi, itemp_lo, itemp;

    hisis24_readpar(cam, &itemp_hi, 0, HISIS24_PARAM_CCDTEMP_HI, &result);
    if (result)
	return result;

    hisis24_readpar(cam, &itemp_lo, 0, HISIS24_PARAM_CCDTEMP_LO, &result);
    if (result)
	return result;

    itemp = ((itemp_hi & 0xF) << 4) | (itemp_lo & 0xF);
    switch (itemp) {
    case 1:
	*temp = (float) -100.0;
	result = HISIS24_DRV_COOLER_UNDERFLOW;
	break;
    case 4:
	*temp = (float) 100.0;
	result = HISIS24_DRV_COOLER_OVERFLOW;
	break;
    case 0:
	*temp = (float) -1000.0;
	result = HISIS24_DRV_COOLER_NO_MEASURE;
	break;
    default:
	*temp = (float) (-41.0 + 0.2 * itemp);
    }
    cam->temperature = *temp;
    return result;
}

int hisis24_resetall(struct camprop *cam)
{
    int A, B, result;
    A = 0xE0;
    B = 0x57;
    hisis24_writevercom(cam, A, B, &result);
    return result;
}

int hisis24_readstatus(struct camprop *cam)
{
    unsigned short P0, P1, P2;
    int status;
    int portnum, typeport;
    portnum = cam->port;
    typeport = cam->typeport;

    if (typeport == LPT) {
	P0 = portnum;
	P1 = (unsigned short) (P0 + 1);
	P2 = (unsigned short) (P0 + 2);
	libcam_out(P2, 0x0D);	/* fermeture du bus de controle, Latch=0 */
	libcam_out(P0, 0xFD);	/* etat lignes de controle */
	libcam_out(P0, 0xFD);	/* delay */
	libcam_out(P2, 0x0C);	/* ouverture du bus de controle, Latch=1 */
	status = libcam_in(P1);	/* lecture du status */
	status = status ^ 0x80;
	libcam_out(P2, 0x0D);	/* fermeture du bus de controle, Latch=0 */
    } else {
	P0 = HiSIS;
	P1 = (unsigned short) (P0 + 1);
	libcam_out(P1, 1);	/* fermeture du bus de controle, Latch=0 */
	libcam_out(P0, 0xFC);	/* etat lignes de controle */
	libcam_out(P0, 0xFC);	/* delay */
	libcam_out(P1, 3);	/* ouverture du bus de controle, Latch=1 */
	status = libcam_in(P0);
	status = libcam_in(P0);
	libcam_out(P1, 1);	/* fermeture du bus de controle, Latch=0 */
    }
    status = status >> 4;

    return status;
}

int hisis24_gainampli(struct camprop *cam, float gain)
{
    int result = 0;
    int data;
    if ((gain >= HISIS24_GAIN_MIN) && (gain <= HISIS24_GAIN_MAX)) {
	data = (int) (log(gain) / log(pow(8., 1. / 64.)));
	/*{
	   FILE *f;
	   f = fopen("toto.exp","at+");
	   fprintf(f,"CCDGAIN = %02X (%f)\n",data,gain);
	   fclose(f);
	   } */
	hisis24_writeverparam(cam, HISIS24_PARAM_CCDGAIN, data, &result);
	cam->hisis24_gain.raw = data;
    } else {
	if (gain < HISIS24_GAIN_MIN)
	    cam->hisis24_gain.raw = 0;
	if (gain > HISIS24_GAIN_MAX)
	    cam->hisis24_gain.raw = 64;
	result = HISIS24_DRV_PB_OUTBOUND_PARAM;
    }
    return result;
}

float hisis24_gain(struct camprop *cam)
{
    return (float) pow(8., ((float) (cam->hisis24_gain.raw)) / 64.);
}
