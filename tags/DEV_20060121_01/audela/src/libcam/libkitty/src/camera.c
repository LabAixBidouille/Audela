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
 * camera.c
 * 
 * Ceci est le fichier contenant le driver de la camera
 *
 * La structure "camprop" peut etre adaptee
 * dans le fichier camera.h
 *
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <stdio.h>
#include "camera.h"
#include <libcam/util.h>

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Kitty255",		/* camera name */
     "tc255",			/* ccd name */
     320, 240,			/* maxx maxy */
     13, 0,			/* overscans x */
     2, 0,			/* overscans y */
     10e-6, 10e-6,		/* photosite dim (m) */
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
    {"Kitty237",		/* camera name */
     "tc237",			/* ccd name */
     650, 490,			/* maxx maxy */
     29, 0,			/* overscans x */
     4, 0,			/* overscans y */
     7.4e-6, 7.4e-6,		/* photosite dim (m) */
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

static void SendData(struct camprop *cam, unsigned char data);
static int efbusy(struct camprop *cam, int timeout_mus);
static unsigned char Lecture_FIFO_4bits(struct camprop *cam);
static unsigned char Lecture_FIFO_8bits(struct camprop *cam);
static unsigned short Lecture_FIFO_12bits(struct camprop *cam);
static unsigned short Lecture_FIFO_16bits(struct camprop *cam);
static void pcdata0(struct camprop *cam);
static void Pose_CCD(struct camprop *cam);
static void TransfertLigne12bits(struct camprop *cam, unsigned char biny);
static void NettoieRegistreHorizontal(struct camprop *cam);
static void TransfertFIFO(struct camprop *cam, unsigned char binx);
static double LectureLM35(struct camprop *cam);
static int TestFIFO(struct camprop *cam);
static void TransfertVidagePixels(struct camprop *cam, int VidageX);
static void TransfertLargX(struct camprop *cam, int LargX);
static void pcdata1111(struct camprop *cam);
static int LecturePose(struct camprop *cam);
static void CCD12bits(struct camprop *cam, unsigned short *buf);
static void CCD8bits(struct camprop *cam, unsigned short *buf);
static void Pose_CCD8bits(struct camprop *cam);


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
    int kk;
    cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */

#ifdef OS_LIN
    // Astuce pour autoriser l'acces au port parallele
    libcam_bloquer();
    libcam_debloquer();
#endif

    /* --- Decode les options de cam::create en fonction de argv[>=3] --- */
    /* --- specifique au driver Kitty --- */
    if (argc >= 5) {
	for (kk = 3; kk < argc - 1; kk++) {
	    if (strcmp(argv[kk], "-canbits") == 0) {
		if (strcmp(argv[kk + 1], "8") == 0) {
		    cam->canbitsindex = 1;
		    CAM_INI[cam->index_cam].maxconvert = 255;
		} else {
		    /* CAN 12 bits par defaut */
		    cam->canbitsindex = 0;
		    CAM_INI[cam->index_cam].maxconvert = 4095;
		}
	    }
	}
    }

    /* converisseur AD7893-AN2 par défaut pour la temperature */
    cam->ad7893index = 0;
    /* SX28 en attente */
    if (cam->canbitsindex == 0) {
	if (cam->authorized == 1) {
	    pcdata0(cam);
	}
    }
    return 0;
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;
    maxx = CAM_INI[cam->index_cam].maxx;
    maxy = CAM_INI[cam->index_cam].maxy;
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
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* vidage de la matrice, lance la pose et transfert de la trame */
	if (cam->canbitsindex == 0) {
	    Pose_CCD(cam);
	} else {
	    Pose_CCD8bits(cam);
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
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
    FILE *f;
    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	f = fopen("kitty.txt", "at");
	fprintf(f, "====== Bloquage des interruptions \n");
	fclose(f);
	/* Lecture de l'image */
	if (cam->canbitsindex == 0) {
	    CCD12bits(cam, p);
	} else {
	    CCD8bits(cam, p);
	}
	f = fopen("kitty.txt", "at");
	fprintf(f, "====== Debloquage des interruptions \n");
	fclose(f);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	f = fopen("kitty.txt", "at");
	fprintf(f, "====== Remise a l'heure de Windows \n");
	fclose(f);
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
	f = fopen("kitty.txt", "at");
	fprintf(f, "====== Sortie de cam_read_ccd \n");
	fclose(f);
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
    if (cam->canbitsindex == 0) {
	cam->temperature = LectureLM35(cam);
    }
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

#define rtcc0   (0)
#define rtcc1   (16)
#define select0 (0)
#define select1 (32)

/* masque ventillateur : */
/*   0 : off             */
/*  64 : minimal         */
/* 128 : moyen           */
/* 192 : maximal         */
#define VENT_OFF (0)
#define VENT_MIN (64)
#define VENT_MOY (128)
#define VENT_MAX (192)


void SendData(struct camprop *cam, unsigned char data)
{
    unsigned char c;

/*
   unsigned char rtcc0=0;
   unsigned char rtcc1=16;
   unsigned char select0=0;
   unsigned char select1=32;
*/
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */

    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;

    data = data & 15;		/* masque 00001111 pour eviter les erreurs */
    c = vent | select1 | rtcc0 | data;	/* xx10 data */
    libcam_out(port, c);
    c = vent | select1 | rtcc1 | data;	/* xx11 data */
    libcam_out(port, c);
    c = vent | select1 | rtcc0 | data;	/* xx10 data */
    libcam_out(port, c);
    c = vent | select1 | rtcc1 | data;	/* xx11 data */
    libcam_out(port, c);
}


int efbusy(struct camprop *cam, int timeout_mus)
/* timeout_mus est le nombre de microsecondes pour le timeout */
/* Retourne le nombre de timeouts effectues */
{
    unsigned short port;
    int timeout = 0;
    port = cam->port + 1;
    /* on ne lit que le bit de poids fort */
    while ((libcam_in(port) & 128) != 0x0) {
	if (timeout++ > timeout_mus)
	    break;		/* time out */
    }
    return timeout;
}

/*
Lecture_FIFO_12bits
  Lecture de la valeur d'un pixel
  Fin du Chronogramme 9
*/

unsigned char Lecture_FIFO_4bits(struct camprop *cam)
{
    unsigned char c, data;
/*
   unsigned char rtcc0=0;
   unsigned char rtcc1=16;
   unsigned char select0=0;
   unsigned char select1=32;
*/
    unsigned char temp;
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;
    unsigned short port1 = cam->port + 1;

    data = 0 & 15;		/* masque 00001111 pour eviter les erreurs */
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids faible */
    temp = (libcam_in(port1) >> 3) & (int) 15;	/* masque 0000 1111 */
    /* c'est fini */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);

    return (temp);

}

unsigned char Lecture_FIFO_8bits(struct camprop *cam)
{
    unsigned char c, data;
/*
   unsigned char rtcc0=0;
   unsigned char rtcc1=16;
   unsigned char select0=0;
   unsigned char select1=32;
*/
    int temp1, temp2;
    unsigned char temp;
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;
    unsigned short port1 = cam->port + 1;

    data = 0 & 15;		/* masque 00001111 pour eviter les erreurs */
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids faible */
    temp1 = (libcam_in(port1) >> 3) & (int) 15;	/* masque 0000 1111 */
    /* au suivant */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids fort */
    temp2 = (libcam_in(port1) << 1) & (int) 240;	/* masque 1111 0000 */
    /* c'est fini */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);

    temp = (unsigned char) (temp1 | temp2);
    return (temp);

}

unsigned short Lecture_FIFO_12bits(struct camprop *cam)
{
    unsigned char c, data;
/*
   unsigned char rtcc0=0;
   unsigned char rtcc1=16;
   unsigned char select0=0;
   unsigned char select1=32;
*/
    int temp1, temp2, temp3;
    unsigned short temp;
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;
    unsigned short port1 = cam->port + 1;

    data = 0 & 15;		/* masque 00001111 pour eviter les erreurs */
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids faible */
    temp1 = (libcam_in(port1) >> 3) & (int) 15;	/* masque 0000 0000 0000 1111 */
    /* au suivant */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids moyen- */
    temp2 = (libcam_in(port1) << 1) & (int) 240;	/* masque 0000 0000 1111 0000 */
    /* au suivant */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids moyen+ */
    temp3 = (libcam_in(port1) << 5) & (int) 3840;	/* masque 0000 1111 0000 0000 */
    /* c'est fini */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);

    temp = (unsigned short) (temp1 | temp2 | temp3);
    return (temp);

}

unsigned short Lecture_FIFO_16bits(struct camprop *cam)
{
    unsigned char c, data;
/*
   unsigned char rtcc0=0;
   unsigned char rtcc1=16;
   unsigned char select0=0;
   unsigned char select1=32;
*/
    int temp1, temp2, temp3, temp4;
    unsigned short temp;
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;
    unsigned short port1 = cam->port + 1;

    data = 0 & 15;		/* masque 00001111 pour eviter les erreurs */
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids faible */
    temp1 = (libcam_in(port1) >> 3) & (int) 15;	/* masque 0000 0000 0000 1111 */
    /* au suivant */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids moyen- */
    temp2 = (libcam_in(port1) << 1) & (int) 240;	/* masque 0000 0000 1111 0000 */
    /* au suivant */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids moyen+ */
    temp3 = (libcam_in(port1) << 5) & (int) 3840;	/* masque 0000 1111 0000 0000 */
    /* au suivant */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    /* recupere le quartet de poids fort */
    temp4 = (libcam_in(port1) << 9) & (int) 61440;	/* masque 1111 0000 0000 0000 */
    /* c'est fini */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);

    temp = (unsigned short) (temp1 | temp2 | temp3 | temp4);
    return (temp);

}

/* =========================================================== */
/*                  C O M M A N D E S    KITTY                 */
/* =========================================================== */

/*
pcdata0
   commande 0000 d'initialisation (?!)
*/
void pcdata0(struct camprop *cam)
{
    unsigned char c;
/*
   unsigned char rtcc0=0;
   unsigned char select1=32;
*/
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;

    c = vent | select1 | rtcc0;	/* xx10 0000 */
    libcam_out(port, c);
}

/*
Pose_CCD
equivalent a fast_vidage_inv(struct camprop *cam) --
  Nettoyage CCD + pose + transfert de trame 
  Chronogramme 6
*/
void Pose_CCD(struct camprop *cam)
{
    unsigned char c, p0lo, p0hi, p1lo, p1hi, p2lo, p2hi;
    unsigned int t;
    FILE *f;
#if defined(OS_LIN)
    int toto;
#endif


    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 0001 === */
    SendData(cam, 1);

    /* === decompose le temps de pose en 3 fois 7 bits === */
    /* on convertit le temps de pose en millisecondes */
    t = (unsigned int) (cam->exptime * 1000.);
    /* on extrait les mots de 7 bits */
    p0lo = (unsigned char) (t & 0x000F);
    p0hi = (unsigned char) ((t >> 4) & 0x0007);
    p1lo = (unsigned char) ((t >> 7) & 0x000F);
    p1hi = (unsigned char) ((t >> 11) & 0x0007);
    p2lo = (unsigned char) ((t >> 14) & 0x000F);
    p2hi = (unsigned char) ((t >> 18) & 0x0007);
    /* === PC-DATA temps de pose === */
    SendData(cam, p0lo);
    SendData(cam, p0hi);
    SendData(cam, p1lo);
    SendData(cam, p1hi);
    SendData(cam, p2lo);
    SendData(cam, p2hi);
    f = fopen("kitty.txt", "at");
    fprintf(f, "====== RINCAGE IMAGE\n");
    fprintf(f, "       cam->exptime*1000=%f flottant\n",
	    cam->exptime * 1000);
    fprintf(f, "       p0lo=%u p0hi=%u p1lo=%u p1hi=%u p2lo=%u p2hi=%u\n",
	    p0lo, p0hi, p1lo, p1hi, p2lo, p2hi);
    fclose(f);

    /* === PC-DATA info === */
    c = 2;			/* on n'annule pas la pose */
    /* pas d'antiblooming */
    if (cam->index_cam == 0) {
	c = c | 0;
    }
    if (cam->index_cam == 1) {
	c = c | 1;
    }
    SendData(cam, c);

    /* === PC-DATA 0000 === */
    pcdata0(cam);
    f = fopen("kitty.txt", "at");
    fprintf(f, "       sortie Rincage\n");
    fclose(f);

}

/*
TransfertLigne12bits
equivalent a zi_zh_inv(struct camprop *cam) --
  Decalage vertical (un nouvelle ligne dans le registre horizontal).
  Chronogramme 7
*/
void TransfertLigne12bits(struct camprop *cam, unsigned char biny)
{
    unsigned char c;

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 0010 === */
    SendData(cam, 2);

    /* === decompose le binning en 3 bits (1 a 4) === */
    biny = biny & 7;		/* masque 00000111 pour eviter les erreurs */

    /* === PC-DATA biny === */
    SendData(cam, biny);

    /* === PC-DATA info === */
    c = 2;			/* on n'annule pas la pose */
    SendData(cam, c);

    /* === EF\ = Busy === */
    efbusy(cam, 1000000);

}

/*
equivalent a fast_line_inv(struct camprop *cam) --
  Nettoyage du registre horizontal
  Chronogramme 8
*/
void NettoieRegistreHorizontal(struct camprop *cam)
{
    unsigned char c;

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 0011 === */
    SendData(cam, 3);

    /* === PC-DATA info === */
    c = 2;			/* on n'annule pas la pose */
    if (cam->index_cam == 0) {
	c = c | 0;
    }
    if (cam->index_cam == 1) {
	c = c | 1;
    }
    SendData(cam, c);

    /* === PC-DATA 0000 === */
    pcdata0(cam);

    /* === EF\ = Busy === */
    efbusy(cam, 1000000);

}

/*
TransfertFIFO
  transfert des pixels d'une ligne dans la memoire FIFO
  Debut du Chronogramme 9
*/
void TransfertFIFO(struct camprop *cam, unsigned char binx)
{
    unsigned char c;

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 0100 === */
    SendData(cam, 4);

    /* === decompose le binning en 3 bits (1 a 4) === */
    binx = binx & 7;		/* masque 00000111 pour eviter les erreurs */

    /* === PC-DATA binx === */
    SendData(cam, binx);

    /* === PC-DATA info === */
    c = 2;			/* on n'annule pas la pose */
    if (cam->index_cam == 0) {
	c = c | 0;
    }
    if (cam->index_cam == 1) {
	c = c | 1;
    }
    SendData(cam, c);

    /* === PC-DATA 0000 === */
    pcdata0(cam);

}

/*
LectureLM35
  Lecture de la temperature
  Chronogramme 2
*/
double LectureLM35(struct camprop *cam)
{
    unsigned short temp;
    double temperature;
    int temp1, temp2;
    char s[100];

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 0101 === */
    SendData(cam, 5);

    /* === EF\ = Busy === */
    efbusy(cam, 1000000);

    /* === Lecture des 16 bits === */
    temp = Lecture_FIFO_16bits(cam);
    if (cam->ad7893index == 0) {
	/* AD7893AN2 */
	temp2 = (temp * 250 / 4096) - 100;
	temp1 = (temp * 2500 / 4096) - 1000 - 10 * temp2;
    } else {
	/* AD7893AN5 */
	temp2 = (temp * 500 / 4096) - 100;
	temp1 = (temp * 5000 / 4096) - 1000 - 10 * temp2;
    }
    temperature = (double) temp2;
    if ((temperature > 150) || (temperature < -50)) {
	temperature = 0.;
    } else {
	sprintf(s, "%d.%d", temp2, temp1);
	temperature = (double) atof(s);
    }
    return (temperature);

}

/*
TestFIFO
  Test de la RAM FIFO
  Retourne 0 s'il n'y a pas d'erreur
  Chronogramme 2
*/
int TestFIFO(struct camprop *cam)
{
    int kerreur, k;

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 0110 === */
    SendData(cam, 6);

    /* === EF\ = Busy === */
    efbusy(cam, 1000000);

    kerreur = 0;
    for (k = 0; k < 2048; k++) {
	if (Lecture_FIFO_4bits(cam) != k) {
	    kerreur++;
	}
    }
    return (kerreur);
}

/*
TransfertVidagePixels(struct camprop *cam) --
  envoi du parametre "pixels a supprimer"
  Chronogramme 5 code 1000
*/
void TransfertVidagePixels(struct camprop *cam, int VidageX)
{
    unsigned char pslo, psmid, pshi;

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 1000 === */
    SendData(cam, 8);

    /* === decompose le nb de pixels en 2 fois 7 bits === */
    /* on extrait les mots de 7 bits */
    pslo = (unsigned char) (VidageX & 0x000F);
    psmid = (unsigned char) ((VidageX >> 4) & 0x0007);
    pshi = (unsigned char) ((VidageX >> 7) & 0x000F);
    /* === PC-DATA PS === */
    SendData(cam, pslo);
    SendData(cam, psmid);
    SendData(cam, pshi);

    /* === PC-DATA 0000 === */
    pcdata0(cam);

}



/*
TransfertLargX(struct camprop *cam) --
  envoi du parametre "pixels utiles / lignes"
  Chronogramme 5 code 1001
*/
void TransfertLargX(struct camprop *cam, int LargX)
{
    unsigned char pulo, pumid, puhi;

#if defined(OS_LIN)
    int toto;
#endif

    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 1001 === */
    SendData(cam, 9);

    /* === decompose le nb de pixels en 2 fois 7 bits === */
    /* on extrait les mots de 7 bits */
    pulo = (unsigned char) (LargX & 0x000F);
    pumid = (unsigned char) ((LargX >> 4) & 0x0007);
    puhi = (unsigned char) ((LargX >> 7) & 0x000F);
    /* === PC-DATA PU === */
    SendData(cam, pulo);
    SendData(cam, pumid);
    SendData(cam, puhi);

    /* === PC-DATA 0000 === */
    pcdata0(cam);

}

/*
kitty_Version
Lecture de la version du logiciel (ex : K1.05)
  Retourne une chaine de 5 caracteres
  Chronogramme 4
*/
char *kitty_Version(struct camprop *cam)
{
    int k;
#if defined(OS_LIN)
    int toto;
#endif
    static char v[10];
    strcpy(v, "");


    /* Demande d'acces aux ports pour linux */
#if defined(OS_LIN)
    toto = iopl(3);
    if (toto != 0) {
	fprintf(stderr, "Impossible d'acceder au port parallele.\n");
	exit(1);
    }
#endif

    /* === PC-DATA 1110 === */
    SendData(cam, 14);

    /* === EF\ = Busy === */
    efbusy(cam, 1000000);

    for (k = 0; k < 5; k++) {
	v[k] = Lecture_FIFO_8bits(cam);
    }
    v[k] = '\0';
    return (v);
}


/*
pcdata1111
   commande 1111 d'annulation (?!)
*/
void pcdata1111(struct camprop *cam)
{
    unsigned char c;
/*
   unsigned char rtcc0=0;
   unsigned char select1=32;
*/
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;

    c = vent | select1 | rtcc0 | 15;	/* xx10 1111 */
    libcam_out(port, c);
}


/*
LecturePose
   retourne le temps de pose restant en millisecondes
*/
int LecturePose(struct camprop *cam)
{
    unsigned char c, data;
/*
   unsigned char rtcc0=0;
   //unsigned char rtcc1=16;
   unsigned char select0=0;
   unsigned char select1=32;
*/
    unsigned short val1 = 0, val2 = 0;
    /* masque ventillateur : */
    /*   0 : off             */
    /*  64 : minimal         */
    /* 128 : moyen           */
    /* 192 : maximal         */
    unsigned char vent = VENT_MAX;
    unsigned short port = cam->port;
    unsigned short port1 = cam->port + 1;

    /* === EF\ = Busy === */
    if (efbusy(cam, 300000) == 300000) {
	return 0;
    }

    data = 0 & 15;		/* masque 00001111 pour eviter les erreurs */
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    libcam_out(port, c);
    val1 = (libcam_in(port1) >> 3) & 0x000F;	/* masque 0000 0000 0000 1111 */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    libcam_out(port, c);
    val1 = val1 | ((libcam_in(port1) << 1) & 0x0070);	/* masque 0000 0000 0111 0000 */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    libcam_out(port, c);
    val2 = (libcam_in(port1) << 4) & 0x0780;	/* masque 0000 0111 1000 0000 */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    c = vent | select0 | rtcc0 | data;	/* xx00 0000 */
    libcam_out(port, c);
    libcam_out(port, c);
    val2 = val2 | ((libcam_in(port1) << 8) & 0x7800);	/* masque 0111 1000 0000 0000 */
    c = vent | select1 | rtcc0 | data;	/* xx10 0000 */
    libcam_out(port, c);
    val1 += val2;
    return (int) val1;
}

/*
CCD12bits
equivalent a read_win_inv(struct camprop *cam,short *buf) --
   Lecture normale du CCD, avec un fenetrage possible.
*/
void CCD12bits(struct camprop *cam, unsigned short *buf)
{
    unsigned char BinningX, BinningY;
    int LargX, LargY, LargeurCCD, HauteurCCD;
    int y, Lignes_Inactives;
    int x, Pixels_Inactifs;
    unsigned short buffer[2048];
    int sortie, k;
    FILE *f;
    unsigned short port;
    int timeout = 0;
    port = cam->port + 1;

    BinningX = (unsigned char) (cam->binx);
    if (cam->binx < 1) {
	BinningX = 1;
    }
    if (cam->binx > 4) {
	BinningX = 4;
    }
    BinningY = (unsigned char) (cam->biny);
    if (cam->biny < 1) {
	BinningY = 1;
    }
    if (cam->biny > 4) {
	BinningY = 4;
    }
    LargeurCCD = cam->nb_photox;
    HauteurCCD = cam->nb_photoy;
    Lignes_Inactives = cam->nb_deadbeginphotoy;
    /*Lignes_Inactives=cam->nb_deadbeginphotoy+(cam->y1-1); */
    Pixels_Inactifs = cam->nb_deadbeginphotox;
    /*Pixels_Inactifs=cam->nb_deadbeginphotox+(cam->x1-1); */

    LargX = LargeurCCD / BinningX;
    /*LargX = (cam->x2-cam->x1+1)/BinningX; */
    LargY = HauteurCCD / BinningY;
    /*LargY = (cam->y2-cam->y1+1)/BinningY; */

    f = fopen("kitty.txt", "at");
    fprintf(f, "===== ENTREE DANS UNE NOUVELLE ACQUSITION ===\n");
    fprintf(f, "BinningX=%u BinningY=%u\n", BinningX, BinningY);
    fprintf(f, "LargeurCCD=%d HauteurCCD=%d\n", LargeurCCD, HauteurCCD);
    fprintf(f, "Lignes_Inactives=%d Pixels_Inactifs=%d\n",
	    Lignes_Inactives, Pixels_Inactifs);
    fprintf(f, "LargX=%d LargY=%d\n", LargX, LargY);
    fprintf(f, "Entrée dans la boucle de reste de pose\n");
    fclose(f);

    /* lire le temps de pose restant et boucler */
    sortie = 0;
    while (sortie == 0) {
	if (LecturePose(cam) <= 0) {
	    sortie = 1;
	}
    }
    f = fopen("kitty.txt", "at");
    fprintf(f, "Sortie de la boucle de reste de pose\n");
    fprintf(f, "====== On supprime les premieres lignes inactives\n");
    fclose(f);

    /* On supprime les premieres lignes inactives */
    for (y = 1; y <= Lignes_Inactives; y++) {
	TransfertLigne12bits(cam, 1);
	NettoieRegistreHorizontal(cam);
    }

    f = fopen("kitty.txt", "at");
    fprintf(f, "====== On lit l'image\n");
    fclose(f);

    /* On lit l'image */
    k = 0;
    for (y = 0; y < LargY; y++) {
	TransfertLigne12bits(cam, BinningY);
	TransfertVidagePixels(cam, Pixels_Inactifs);
	TransfertLargX(cam, LargX + 1);
	TransfertFIFO(cam, BinningX);
	/* attente 1 a 1.5 ms */
	timeout = 0;
	while (timeout++ < 1000) {
	    libcam_in(port);
	}
	f = fopen("kitty.txt", "at");
	fprintf(f, "       %d/%d debut des %d Lecture_FIFO_12bits\n", y,
		LargY, LargX);
	fclose(f);
	for (x = 0; x < LargX; x++) {
	    /* tableau_image[x+LargX*y]=Lecture_FIFO_12bits */
	    buffer[x] = (unsigned short) 0;
	    buffer[x] = Lecture_FIFO_12bits(cam);
	}
	if (y == 100) {
	    f = fopen("kitty.txt", "at");
	    for (x = 0; x < LargX; x++) {
		fprintf(f, "x=%d val=%u \n", x, buffer[x]);
	    }
	    fclose(f);
	}
	for (x = 0; x < LargX; x++) {
	    buf[k++] = buffer[x];
	}
	f = fopen("kitty.txt", "at");
	fprintf(f, "       Transfert buffer->buf\n");
	fclose(f);
    }
    f = fopen("kitty.txt", "at");
    fprintf(f, "====== Remise en attente de la connexion SX28 \n");
    fclose(f);

    f = fopen("kitty.txt", "at");
    fprintf(f, "====== Sortie normale\n");
    fclose(f);

}

void CCD8bits(struct camprop *cam, unsigned short *buf)
{
}

void Pose_CCD8bits(struct camprop *cam)
{
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

void kitty_test_out(struct camprop *cam, unsigned long nb_out)
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
