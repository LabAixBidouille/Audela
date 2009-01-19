/* camera.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <stdio.h>
#include "camera.h"
#include <libcam/util.h>

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] =
{
    {
		"K2",			/* camera name */
		"K2",	 	   /* camera product */
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
//static int cam_close(struct camprop *cam);
static void cam_start_exp(struct camprop *cam, char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, unsigned short *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
//static void cam_ampli_on(struct camprop *cam);
//static void cam_ampli_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV =
    {
        cam_init,			/* init */
        NULL,			/* close */
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


static void SendCmd(struct camprop *cam, unsigned char data);
static void SendData(struct camprop *cam, unsigned char data);
static int ReadData(struct camprop *cam, int nbbits);
static void WaitFifo(struct camprop *cam);
static unsigned char ChangeSRCK(int change);
static void MoveSRCK(struct camprop *cam);
static void InitFifo(struct camprop *cam);
static void ResetFifo(struct camprop *cam);
static void SelectFifo(struct camprop *cam, int num);
static void TransfertVidageX(int VidageX, struct camprop *cam);
static void TransfertLargX(int LargeurX, struct camprop *cam);
static void TransfertVidageY(int VidageY, struct camprop *cam);
static void TransfertLargY(int LargeurY, struct camprop *cam);
static void TransfertBinXY(unsigned char BinningX, unsigned char BinningY,
                           struct camprop *cam);
static void SendDelay(struct camprop *cam);
static void SendPose(struct camprop *cam);
static void Pose_CCD(struct camprop *cam);
static void Read_CCD(struct camprop *cam, unsigned short *buf);
static double LectureLM35(struct camprop *cam);

static unsigned char k2_AntiBlooming = 0;

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
#ifdef OS_LIN
    if ( ! libcam_can_access_parport() ) {
	sprintf(cam->msg,"You don't have sufficient privileges to access parallel port. Camera cannot be created.");
	return 1;
    }
#endif

    cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */

    CAM_INI[cam->index_cam].maxconvert = 4095;
    cam->vent = VENT_OFF;
    InitFifo(cam);
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
    if (cam->authorized == 1)
    {
        /* Bloquage des interruptions */
        if (cam->interrupt == 1)
            libcam_bloquer();
        /* vidage de la matrice, lance la pose et transfert de la trame */
        Pose_CCD(cam);
        /* Debloquage des interruptions */
        if (cam->interrupt == 1)
            libcam_debloquer();
        /* Remise a l'heure de l'horloge de Windows */
        if (cam->interrupt == 1)
            update_clock();
    }
}

void cam_stop_exp(struct camprop *cam)
{
    unsigned char d, c;
    unsigned char vent = cam->vent;
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    c = DLE_1 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);
    d = FIFO2_0 | FIFO1_0 | vent | 3;
    libcam_out(port, d);
    c = DLE_0 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();

}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
    if (p == NULL)
        return;
    if (cam->authorized == 1)
    {
        Read_CCD(cam, p);
    }
}

void cam_shutter_on(struct camprop *cam)
{}

void cam_shutter_off(struct camprop *cam)
{}

void cam_measure_temperature(struct camprop *cam)
{
    cam->temperature = LectureLM35(cam);
}

void cam_cooler_on(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;
    unsigned char d, c;

    c = DLE_1 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);

    switch ((int) cam->check_temperature)
    {
    case 1:
        cam->vent = VENT_MIN;
        break;
    case 2:
        cam->vent = VENT_MOY;
        break;
    case 3:
        cam->vent = VENT_FOR;
        break;
    case 4:
        cam->vent = VENT_MAX;
        break;
    default:
        cam->vent = VENT_MAX;
        break;
    }
    d = FIFO2_0 | FIFO1_0 | cam->vent;
    libcam_out(port, d);

    c = DLE_0 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);
}

void cam_cooler_off(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;
    unsigned char d, c;

    c = DLE_1 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);

    cam->vent = VENT_OFF;
    d = FIFO2_0 | FIFO1_0 | cam->vent;
    libcam_out(port, d);

    c = DLE_0 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);
}

void cam_cooler_check(struct camprop *cam)
{
    cam_cooler_on(cam);
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

/****************************************************/
/* SendCmd : envoi d'une commande (4 bits) au SX28 */
/****************************************************/
void SendCmd(struct camprop *cam, unsigned char data)
{
    unsigned char d, c;
    int i, b = 0;
    unsigned char vent = cam->vent;
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    data = data & 15;		/* masque 00001111 pour eviter les erreurs */
    d = FIFO2_0 | FIFO1_0 | vent;
    c = DLE_1 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);
    d = FIFO2_0 | FIFO1_0 | vent | PCSTART;
    libcam_out(port, d);
    for (i = 0; i < 4; i++)
    {
        d = FIFO2_0 | FIFO1_0 | vent | b;
        libcam_out(port, d);
        b = (data << i) & 8 ? 1 : 0;
        d = FIFO2_0 | FIFO1_0 | vent | b | PCSCLK;
        libcam_out(port, d);
        d = FIFO2_0 | FIFO1_0 | vent | b;
        libcam_out(port, d);
    }
    d = FIFO2_0 | FIFO1_0 | vent;
    libcam_out(port, d);
    c = DLE_0 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();
}

/****************************************************/
/* SendData : envoi d'un param�tre (8 bits) au SX28 */
/****************************************************/
void SendData(struct camprop *cam, unsigned char data)
{
    unsigned char d, c;
    int i, b = 0;
    unsigned char vent = cam->vent;
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    d = FIFO2_0 | FIFO1_0 | vent;
    c = DLE_1 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);
    d = FIFO2_0 | FIFO1_0 | vent | PCSTART;
    libcam_out(port, d);
    for (i = 0; i < 8; i++)
    {
        d = FIFO2_0 | FIFO1_0 | vent | b;
        libcam_out(port, d);
        b = (data << i) & 128 ? 1 : 0;
        d = FIFO2_0 | FIFO1_0 | vent | b | PCSCLK;
        libcam_out(port, d);
        d = FIFO2_0 | FIFO1_0 | vent | b;
        libcam_out(port, d);
    }
    d = FIFO2_0 | FIFO1_0 | vent;
    libcam_out(port, d);
    c = DLE_0 | ChangeSRCK(0) | RSTR_0 | FIOE_0;
    libcam_out(port2, c);

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();
}

/***************************************************************/
/* ReadData : lecture d'un mot de nbbits en provenance du SX28 */
/***************************************************************/
int ReadData(struct camprop *cam, int nbbits)
{
    unsigned short port = cam->port + 1;
    int timeout = 0;
    int i, tmp;
    int res = 0;

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    for (i = 0; i < nbbits; i++)
    {
        tmp = libcam_in(port);
        while ((tmp & 128) != 0x0)
        {	/* boucle d'attente de \SXSCLK � 1 */
            if (timeout++ > 1000)
                return -1;	/* time out */
            tmp = libcam_in(port);
        }
        res |= tmp & 64 ? (1 << (nbbits - 1)) >> i : 0;
        while ((libcam_in(port) & 128) == 0x0)
        {	/* boucle d'attente de \SXSCLK � 0 */
            if (timeout++ > 1000)
                return -1;	/* time out */
        }
    }

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();

    return res;
}

/**********************************************/
/* WaitFifo : attente de la fin de la pose et */
/* du remplissage des FIFO                    */
/**********************************************/
void WaitFifo(struct camprop *cam)
{
    unsigned short port = cam->port + 1;
    unsigned char status;
//  unsigned char busy;

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    do
    {
        status = libcam_in(port) & 0xC0;
//        busy = status & 0x80;
        //status &= 0x40;
    }
	while (status != 0x80);
//    while (!busy && status);
	libcam_sleep(200);

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();
}

unsigned char ChangeSRCK(int change)
{
    static int s = 0;

    if (change)
        s = ~s;
    if (s)
        return SRCK_1;
    return SRCK_0;
}

void MoveSRCK(struct camprop *cam)
{
    unsigned short port2 = cam->port + 2;

    libcam_out(port2,
               (unsigned char) (32 | FIOE_1 | RSTR_0 | ChangeSRCK(1) |
                                DLE_0));
}

void InitFifo(struct camprop *cam)
{
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;
    int i;

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    /* Init FIFO 1 */
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_1);
    libcam_out(port, FIFO1_1 | FIFO2_0 | cam->vent);
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_0);

    libcam_out(port2, 32 | FIOE_1 | RSTR_0 | ChangeSRCK(0) | DLE_0);
    for (i = 0; i < 80; i++)
        libcam_out(port2, 32 | FIOE_1 | RSTR_0 | ChangeSRCK(1) | DLE_0);	/* 80 impulsions SRCK */

    libcam_out(port2, FIOE_0 | RSTR_1 | ChangeSRCK(0) | DLE_0);	/* Reset */
    libcam_out(port2, FIOE_0 | RSTR_1 | ChangeSRCK(1) | DLE_0);
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_0);

    /* Init FIFO 2 */
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_1);
    libcam_out(port, FIFO1_0 | FIFO2_1 | cam->vent);
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_0);

    libcam_out(port2, 32 | FIOE_1 | RSTR_0 | ChangeSRCK(0) | DLE_0);
    for (i = 0; i < 80; i++)
        libcam_out(port2, 32 | FIOE_1 | RSTR_0 | ChangeSRCK(1) | DLE_0);	/* 80 impulsions SRCK */

    libcam_out(port2, FIOE_0 | RSTR_1 | ChangeSRCK(0) | DLE_0);	/* Reset */
    libcam_out(port2, FIOE_0 | RSTR_1 | ChangeSRCK(1) | DLE_0);
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_0);

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();
}

void ResetFifo(struct camprop *cam)
{
    unsigned short port2 = cam->port + 2;

    libcam_out(port2, FIOE_0 | RSTR_1 | ChangeSRCK(0) | DLE_0);	/* Reset */
    libcam_out(port2, FIOE_0 | RSTR_1 | ChangeSRCK(1) | DLE_0);
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_0);
}

void SelectFifo(struct camprop *cam, int num)
{
    unsigned short port = cam->port;
    unsigned short port2 = cam->port + 2;

    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_1);
    if (num == 1)
        libcam_out(port, FIFO1_1 | FIFO2_0 | cam->vent);
    else
        libcam_out(port, FIFO1_0 | FIFO2_1 | cam->vent);
    libcam_out(port2, FIOE_0 | RSTR_0 | ChangeSRCK(0) | DLE_0);

    libcam_out(port2, FIOE_1 | RSTR_0 | ChangeSRCK(0) | DLE_0);
    libcam_out(port2, FIOE_1 | RSTR_0 | ChangeSRCK(1) | DLE_0);	/* decale de 2 cases m�moires */
    libcam_out(port2, FIOE_1 | RSTR_0 | ChangeSRCK(1) | DLE_0);	/* avant d'effectuer en reset */

    ResetFifo(cam);
    libcam_out(port2, FIOE_1 | RSTR_0 | ChangeSRCK(0) | DLE_0);

    MoveSRCK(cam);		/* decale de 2 cases m�moires */
    MoveSRCK(cam);		/* avant la lecture de la FIFO */
}

/*********************************************/
/* Transfert du nombre de pixels � supprimer */
/*     Envoi d'une trame: %1000 + VidageX    */
/*     ATTENTION: VidageX est modulo 128!    */
/*********************************************/
void TransfertVidageX(int VidageX, struct camprop *cam)
{
    unsigned char data;

    /* === PC-DATA 1000 === */
    SendCmd(cam, 8);
    /* === PC-DATA Vidage X === */
    data = VidageX & 0x7F;
    SendData(cam, data);
    data = (VidageX >> 7) & 0x0F;
    SendData(cam, data);
}

/*********************************************/
/* Transfert du nombre de pixels � acqu�rir  */
/*      Envoi d'une trame: %1001 + LargX     */
/*      ATTENTION: LargX est modulo 128!     */
/*********************************************/
void TransfertLargX(int LargeurX, struct camprop *cam)
{
    unsigned char data;

    /* === PC-DATA 1001 === */
    SendCmd(cam, 9);
    /* === PC-DATA Largeur X === */
    data = LargeurX & 0x7F;
    SendData(cam, data);
    data = (LargeurX >> 7) & 0x0F;
    SendData(cam, data);
}

/*********************************************/
/* Transfert du nombre de pixels � supprimer */
/*     Envoi d'une trame: %1010 + VidageY    */
/*     ATTENTION: VidageY est modulo 128!    */
/*********************************************/
void TransfertVidageY(int VidageY, struct camprop *cam)
{
    unsigned char data;

    /* === PC-DATA 1010 === */
    SendCmd(cam, 10);
    /* === PC-DATA Vidage Y === */
    data = VidageY & 0x7F;
    SendData(cam, data);
    data = (VidageY >> 7) & 0x0F;
    SendData(cam, data);
}

/*********************************************/
/* Transfert du nombre de pixels � acqu�rir  */
/*      Envoi d'une trame: %1011 + LargY     */
/*      ATTENTION: LargY est modulo 128!     */
/*********************************************/
void TransfertLargY(int LargeurY, struct camprop *cam)
{
    unsigned char data;

    /* === PC-DATA 1011 === */
    SendCmd(cam, 11);
    /* === PC-DATA Largeur Y === */
    data = LargeurY & 0x7F;
    SendData(cam, data);
    data = (LargeurY >> 7) & 0x0F;
    SendData(cam, data);
}

/*********************************************/
/* Transfert du binning et de l'antiblooming */
/*   Envoi d'une trame: %1100 + BinXY + ABG  */
/*********************************************/
void TransfertBinXY(unsigned char BinningX, unsigned char BinningY,
                    struct camprop *cam)
{
    unsigned char data;
    /* === PC-DATA 1100 === */

    SendCmd(cam, 0xC);
    /* === PC-DATA binning + pas d'antiblooming === */
    data = (BinningX << 4) | BinningY;
    SendData(cam, data);
    SendData(cam, k2_AntiBlooming);
}

/*****************************************/
/* Envoi d'un param�tre de temporisation */
/*****************************************/
void SendDelay(struct camprop *cam)
{
    /* === PC-DATA 1110 Delay = 8 === */
    SendCmd(cam, 0xE);
    SendData(cam, 8);
}

/***************************************************/
/* Envoi d'une trame: %1101 + temps de pose (3oct) */
/***************************************************/
void SendPose(struct camprop *cam)
{
    unsigned char data;
    unsigned int pose;
    double tmp;

    /* on convertit le temps de pose en millisecondes */
    tmp = cam->exptime * 1000.0;
    pose = (unsigned int) tmp;
    /* === PC-DATA 1101 === */
    SendCmd(cam, 0xD);
    /* === PC-DATA temps de pose === */
    data = pose & 0x7F;
    SendData(cam, data);
    data = (pose >> 7) & 0x7F;
    SendData(cam, data);
    data = (pose >> 14) & 0x7F;
    SendData(cam, data);
}

/* =========================================================== */
/*                  C O M M A N D E S    KITTY                 */
/* =========================================================== */

/*************************************************/
/* Pose_CCD : envoi des param�tres d'acquisition */
/* et d�clenchement de la pose                   */
/*************************************************/
void Pose_CCD(struct camprop *cam)
{
    unsigned char BinningX, BinningY;
    int LargeurX, LargeurY, VidageX, VidageY;
    // unsigned int tmp = 0;
    //FILE *f;

    BinningX = (unsigned char) (cam->binx);
    if (cam->binx < 1)
    {
        BinningX = 1;
    }
    if (cam->binx > 4)
    {
        BinningX = 4;
    }
    BinningY = (unsigned char) (cam->biny);
    if (cam->biny < 1)
    {
        BinningY = 1;
    }
    if (cam->biny > 4)
    {
        BinningY = 4;
    }

    /*f = fopen("k2.txt", "a");
    fprintf(f, "====== DEBUT Pose_CCD\n");
    fprintf(f, "       binning=%dx%d\n", cam->binx, cam->biny);
    fprintf(f, "       %dx%d -> %dx%d w=%d h=%d\n", cam->x1, cam->y1,
     cam->x2, cam->y2, cam->w, cam->h);
    fprintf(f, "       cam->exptime*1000=%f flottant\n",
     cam->exptime * 1000);*/

    LargeurX = (cam->x2 - cam->x1 + 1) / BinningX;
    LargeurY = (cam->y2 - cam->y1 + 1) / BinningY;
    VidageX = cam->x1 + 26;
    VidageY = cam->y1 + 7;

    //fprintf(f, "       Vidage X = %d Largeur X = %d\n", cam->x1, LargeurX);
    //fprintf(f, "       Vidage Y = %d Largeur Y = %d\n", cam->y1, LargeurY);

    SendPose(cam);
    SendDelay(cam);
    TransfertVidageX(VidageX, cam);
    TransfertLargX(LargeurX >> 1, cam);
    TransfertVidageY(VidageY, cam);
    TransfertLargY(LargeurY, cam);
    TransfertBinXY(BinningX, BinningY, cam);
    /* === PC-DATA 0100 Lancement de la pose === */
    SendCmd(cam, 4);

    /*fprintf(f, "       pose mesur� : %dms\n", tmp);
    fprintf(f, "       FIN Pose_CCD\n");
    fclose(f);*/
}

/***************************************************************/
/* Read_CCD : attente de la fin de la pose et du remplissage   */
/* des m�moire FIFO puis lecture des FIFO dans le buffer image */
/***************************************************************/
void Read_CCD(struct camprop *cam, unsigned short *buf)
{
    unsigned char BinningX, BinningY;
    int LargX, LargY;
    int x, y, impair = 0;
    unsigned short port, d;
    //unsigned short *tmp;

   port = cam->port;
    BinningX = (unsigned char) (cam->binx);
    if (cam->binx < 1)
        BinningX = 1;
    if (cam->binx > 4)
        BinningX = 4;
    BinningY = (unsigned char) (cam->biny);
    if (cam->biny < 1)
        BinningY = 1;
    if (cam->biny > 4)
        BinningY = 4;
    LargX = (cam->x2 - cam->x1 + 1) / BinningX;
    LargY = (cam->y2 - cam->y1 + 1) / BinningY;
    if (LargX & 1)
        impair = 1;
    LargX &= 0xFFFE;
    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

	/*tmp = buf;
    for (y = 0; y < LargY; y++)
    {
        for (x = 0; x < LargX; x++)
        {
            *buf = 0;
            buf++;
            if (impair && x == LargX - 2)
                *buf++ = 0;
        }
    }
	buf = tmp;
	impair = 0;*/

    WaitFifo(cam);
    ResetFifo(cam);
    SelectFifo(cam, 1);
    for (y = 0; y < LargY; y++)
    {
        if (y == 250)
        {
            ResetFifo(cam);
            SelectFifo(cam, 2);
        }
        for (x = 0; x < LargX; x += 2)
        {
            d = (unsigned short) libcam_in(port);
            *buf = (d << 4) & 0xFF0;
            MoveSRCK(cam);
            d = (unsigned short) libcam_in(port);
            *buf |= (d >> 4) & 0x00F;
            buf++;
            *buf = (d << 8) & 0xF00;
            MoveSRCK(cam);
            d = (unsigned short) libcam_in(port);
            *buf |= d & 0x0FF;
            MoveSRCK(cam);
            buf++;
            if (impair && x == LargX - 2)
                *buf++ = 0;
        }
    }
    ResetFifo(cam);
    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();
}

/**********************************************************/
/* LectureLM35 : lecture de la temp�rature du capteur CCD */
/**********************************************************/
double LectureLM35(struct camprop *cam)
{
    unsigned short temp;
    double temperature;
    int temp1, temp2;
    char s[100];

    /* === PC-DATA 0101 === */
    SendCmd(cam, 5);

    /* === Lecture des 12 bits === */
    temp = ReadData(cam, 12);
    temp2 = (temp * 500 / 4096) - 100;
    temp1 = (temp * 5000 / 4096) - 1000 - 10 * temp2;
    temperature = (double) temp2;
    if ((temperature > 150) || (temperature < -50))
    {
        temperature = 0.;
    }
    else
    {
        sprintf(s, "%d.%d", temp2, temp1);
        temperature = (double) atof(s);
    }

    return (temperature);
}

/************************************************************/
/* Version : Lecture de la version du logiciel (ex : K2.02) */
/*  Retourne une chaine de 5 caracteres                     */
/************************************************************/
char *k2_SetABL(struct camprop *cam,int argc, char *argv[])
{
	if (argc < 3) return k2_AntiBlooming ? "on" : "off";
	if (argv[2][1] == 'n') k2_AntiBlooming = 1;			// on
	else if (argv[2][1] == 'f') k2_AntiBlooming = 0;	// off
	return k2_AntiBlooming ? "on" : "off";
}

/***********************�*************************************/
/* Version : Lecture de la version du logiciel (ex : K2.02) */
/*  Retourne une chaine de 5 caracteres                     */
/************************************************************/
char *k2_Version(struct camprop *cam)
{
    int k, t;
    static char v[5];

    v[0] = 0;

    /* === PC-DATA 0110 === */
    SendCmd(cam, 6);

    for (k = 0; k < 5; k++)
    {
        if ((t = ReadData(cam, 8)) < 0)
            v[k] = '-';
        else
            v[k] = t;
    }
    v[k] = '\0';

    return v;
}

/*********************************************************************/
/* TestSX28 : commande 0111 de test du SX28 (clignotement d'une LED) */
/*********************************************************************/
void k2_TestSX28(struct camprop *cam)
{
    /* === PC-DATA 0110 === */
    SendCmd(cam, 7);
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

void k2_test_out(struct camprop *cam, unsigned long nb_out)
{
    unsigned short port;
    if (cam->authorized == 1)
    {
        port = cam->port;
        /* Bloquage des interruptions */
        if (cam->interrupt == 1)
            libcam_bloquer();
        /* Mesure du temps de out */
        test_out_time(port, nb_out, (unsigned long) 0);
        /* Debloquage des interruptions */
        if (cam->interrupt == 1)
            libcam_debloquer();
        /* Remise a l'heure de l'horloge de Windows */
        if (cam->interrupt == 1)
            update_clock();
    }
}

/**********************************************/
/* TestDG642 : Test du commutateur analogique */
/* �quivalent au test 6 de Kool               */
/**********************************************/
void k2_TestDG642(struct camprop *cam)
{
    static char d = 0;

    SendCmd(cam, 2);
    SendData(cam, d);
    d = ~d;
}

/*************************************************************************/
/* TestFifo : test des m�moire FIFO en demandant au SX28 de les remplirs */
/* d'octet o puis lecture des FIFO pour comparer                         */
/*************************************************************************/
char *k2_TestFifo(struct camprop *cam, unsigned char o)
{
    int y, bad = 0;
    unsigned char d;
    static char msg[128];
    unsigned short port = cam->port;

    SendCmd(cam, 3);
    SendData(cam, o);

    /* Bloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_bloquer();

    libcam_sleep(2);
    SelectFifo(cam, 1);
    for (y = 0; y < 250000; y++)
    {
        d = libcam_in(port);
        if (d != o)
            bad++;
        MoveSRCK(cam);
    }
    ResetFifo(cam);
    if (bad)
        sprintf(msg, "FIFO1 : %d bad bytes", bad);
    else
        sprintf(msg, "FIFO1 Ok");
    bad = 0;
    SelectFifo(cam, 2);
    for (y = 0; y < 250000; y++)
    {
        d = libcam_in(port);
        if (d != o)
            bad++;
        MoveSRCK(cam);
    }
    ResetFifo(cam);

    /* Debloquage des interruptions */
    if (cam->interrupt == 1)
        libcam_debloquer();

    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1)
        update_clock();

    if (bad)
        sprintf(msg, "%s FIFO2 : %d bad bytes", msg, bad);
    else
        sprintf(msg, "%s FIFO2 Ok", msg);

    return msg;
}
