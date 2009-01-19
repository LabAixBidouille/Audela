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
 * D'apr�s l'exemple de dll "SCR1300XT_DLL.CPP"
 * de la soci�t� SYNONYME Conseil et R�alisation
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

/* ATTENTION : Seul le binning numerique est applique */

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"SCR1300XTC",		/* camera name */
     "scr1300xtc",		/* camera product */
     "kac1310",			/* ccd name */
     1280, 1024,		/* maxx maxy */
     8, 8,			/* overscans x */
     16, 6,			/* overscans y */
     6e-6, 6e-6,		/* photosite dim (m) */
     4095.,			/* observed saturation */
     0.64,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     1,				/* default num buf for the image */
     1,				/* default num tel for the coordinates taken */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     0.,			/* default value for temperature checked */
     6,				/* default color mask if exists (1=cfa-rgb, 6=cfa-cmy) */
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

static void timetest(struct camprop *cam);

static void InitPort(unsigned short port);
static int mclk(int nb);
static long scr_fin(void);
static int envoi(char bytei2c);
static void testack(void);
static void start(void);
static void stop(void);
static int sendParameters(char adr, char reg, char data);
static int reset(void);
static int scr_init(unsigned short port);
static int scr_start_exp(int nbx, int nby, int binx, int posX, int posY,
			 float pause_s, int gain, int offset);
static int scr_read_ccd(int nbx, int nby, int binx, short *pixels);


/*
 *  Definition a structure specific for this driver 
 *  (see declaration in camera.h)
 */
/*====================================================*/
/*		Variables globales  						*/
/*====================================================*/
static unsigned short Port, Portc, Porte, eppdata, ecr;	// LPT1
static unsigned char reg;
static float Sec;		// Base de temps pour une exposition de 1 seconde

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
    timetest(cam);
    //Sec=scr_fin();
    //Sec=(float)172.0;            // 0x5A Asus PII 266Mhz
    Sec = (float) 90.0;		// HP Pavilion N5442 PIII 900MHz
    scr_init(cam->port);
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

    cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
    int w = cam->w;
    int h = cam->h;
    int b = cam->binx;
    int x = cam->x1;
    int y = cam->y1;
    float e = cam->exptime;
    int g = cam->gain;
    int o = cam->offset;

    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* vidage de la matrice, lance la pose et transfert de la trame */
	scr_start_exp(w, h, b, x, y, e, g, o);
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
    int w = cam->w;
    int h = cam->h;
    int b = cam->binx;

    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* Lecture de l'image */
	scr_read_ccd(w, h, b, p);
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
    cam->temperature = (float) scr_fin();
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

void timetest(struct camprop *cam)
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
    cam->bd1 = n / t3 * 10;
    cam->bd2 = 2 * cam->bd1;
    cam->bd5 = 5 * cam->bd1;
    cam->bd10 = 10 * cam->bd1;
}

/*====================================================*/
/*		Fonction speciale  						*/
/*====================================================*/

void InitPort(unsigned short port)
{
    Port = port;
    Porte = (unsigned short) (Port + 1);
    Portc = (unsigned short) (Port + 2);
    eppdata = (unsigned short) (Port + 4);
    ecr = (unsigned short) (Port + 0x402);
// port para en lecture
// mode ibm
    libcam_out(ecr, 0x20);	   //ecp = ps2
    reg = libcam_in(Portc);	// reg commande
    libcam_out(Portc, 0x24);	//CAM ==> PC ps2
    //port en lecture n
}

/*************************************************/
int mclk(int nb)
{
    long i;
    for (i = 0; i < nb; i++) {
	reg = libcam_in(Portc);
	reg |= 0x02;		// mclk invers�
	libcam_out(Portc, reg);
	reg ^= 0x02;
	libcam_out(Portc, reg);
    }
    return 0;
}

/*************************************************/
long scr_fin()
{

    long i, j, lsec;
    int tfin;
    time_t first, second;
    first = time(NULL);
    // horloge mclk pour 1 ere image
    for (i = 0; i < 250; i++) {
	for (j = 0; j < 400; j++) {
	    mclk(100);
	}
    }
    second = time(NULL);
    tfin = (int) difftime(second, first);
    lsec = ((tfin * 4096) / 1500);
    return lsec;
}


/*************************************************/
int envoi(char bytei2c)
{
    long i;
    for (i = 0; i < 8; i++) {
	// scl 0
	reg = libcam_in(Portc);
	reg &= 0xfe;		// scl 0
	libcam_out(Portc, reg);
	mclk(10);
	reg = libcam_in(Portc);
	if (bytei2c & 0x80)
	    reg |= 0x08;	// envoi 1
	else
	    reg &= 0xf7;	// envoi 0
	libcam_out(Portc, reg);
	mclk(6);
	reg = libcam_in(Portc);
	reg |= 0x01;		// scl 1
	libcam_out(Portc, reg);
	mclk(10);
	bytei2c <<= 1;
    }
    return (0);
}

/*************************************************/
void testack()
{
    // scl 0
    reg = libcam_in(Portc);
    reg &= 0xfe;		// scl 0
    libcam_out(Portc, reg);
    mclk(4);
    // sda 0
    reg = libcam_in(Portc);
    reg |= 0x08;		// sda 1
    libcam_out(Portc, reg);
    mclk(10);
    reg = libcam_in(Portc);
    reg |= 0x01;		// scl 1
    libcam_out(Portc, reg);
//      mclk(16);
    do {
	mclk(10);
	reg = libcam_in(Porte);
    } while (!(reg & 0x08));	// sda avec 7405
    // bcl si sda a 1
    return;
}

/*************************************************/
void start()
{
    reg = libcam_in(Portc);
    reg |= 0x08;		// sda 1
    libcam_out(Portc, reg);
    mclk(6);
    reg = libcam_in(Portc);
    reg |= 0x01;		// scl 1
    libcam_out(Portc, reg);
    mclk(10);
    reg = libcam_in(Portc);
    reg &= 0xf7;		// sda 0
    libcam_out(Portc, reg);
    mclk(10);
    reg = libcam_in(Portc);
    reg &= 0xfe;		// scl 0
    libcam_out(Portc, reg);
    mclk(10);
    return;
}

/*************************************************/
void stop()
{
    reg = libcam_in(Portc);
    reg &= 0xfe;		// scl 0
    libcam_out(Portc, reg);
    mclk(10);
    reg = libcam_in(Portc);
    reg &= 0xf7;		// sda 0
    libcam_out(Portc, reg);
    mclk(10);
    reg = libcam_in(Portc);
    reg |= 0x01;		// scl 1
    libcam_out(Portc, reg);
    mclk(10);
    reg = libcam_in(Portc);
    reg |= 0x08;		// sda 1
    libcam_out(Portc, reg);
    mclk(6);
    return;
}

/*************************************************/
int sendParameters(char adr, char reg, char data)
{
    start();
    envoi(adr);
    testack();
    envoi(reg);
    testack();
    envoi(data);
    testack();
    stop();
    return 0;
}

/*************************************************/
int reset()
{
    reg = libcam_in(Portc);
    reg |= 0x01;		// scl 1
    libcam_out(Portc, reg);
    mclk(255);
    reg = libcam_in(Portc);
    reg |= 0x08;		// sda 1
    libcam_out(Portc, reg);
    mclk(255);
    reg = libcam_in(Portc);
    reg &= 0xfb;		// reset = 0 = reset
    libcam_out(Portc, reg);
//      InitTempo();
    mclk(100);
    reg = libcam_in(Portc);
    reg |= 0x04;		// reset = 1 = marche
    libcam_out(Portc, reg);
    sendParameters(0x66, 0x0e, 0x02);
    mclk(100);
    sendParameters(0x66, 0x0e, 0x00);
    mclk(100);
    return 0;
}

/*************************************************/
int scr_init(unsigned short port)
{
    InitPort(port);
    reset();
    sendParameters(0x66, 0x40, 0x6A);
    sendParameters(0x66, 0x42, 0x01);
    mclk(100);
    return 0;			// pas d'erreur
}

/*==========================================================*/
/*				Acquisition complete d'une image				  		*/
/* 				programmee par SetCamParam							*/
/*==========================================================*/
/*																				*/
/* mem : un pointeur sur une zone de taille suffisante		*/
/*	 		pour recevoir l'image										*/
/*	maxtime : nombre de secondes d'attente	avant erreur		*/
/*				 (temps de numerisation)								*/
/*				 valeur conseillee : 30									*/
/*																				*/
/*==========================================================*/
/* Il y a erreur si la valeur retournee est non nulle			*/
/*==========================================================*/
int scr_start_exp(int nbx, int nby, int binx, int posX, int posY,
		  float pause_s, int gain, int offset)
{
    int nbxw, nbyw;
    unsigned expo;
    unsigned char *paux;
    int option3 = 0;
    nbxw = nbx;

    // if (binx==2) nbxw=nbx*2;
    expo = (unsigned int) (pause_s * Sec);
    //
    if (!expo)
	expo = 1;
    sendParameters(0x66, 0x0e, 0x02);
    mclk(100);
    sendParameters(0x66, 0x0e, 0x00);
    mclk(100);

    sendParameters(0x66, 0x40, 0x6a);

// bin
    if (binx == 1)
	sendParameters(0x66, 0x41, 0x10);
//      if (binx == 2)sendParameters(0x66, 0x41, 0x15);
    if (binx == 4)
	sendParameters(0x66, 0x41, 0x26);
    if (binx == 2)
	sendParameters(0x66, 0x41, 0x20);

// wf

    nbxw = (nbx * binx) + 20;
    nbyw = nby + 44;
    paux = (unsigned char *) &nbyw;
    sendParameters(0x66, 0x50, paux[1]);
    sendParameters(0x66, 0x51, paux[0]);
    paux = (unsigned char *) &nbxw;
    sendParameters(0x66, 0x52, paux[1]);
    sendParameters(0x66, 0x53, paux[0]);


// WOI
    {
	int dxw = (posX * binx) + 8;
	paux = (unsigned char *) &dxw;
	sendParameters(0x66, 0x49, paux[1]);
	sendParameters(0x66, 0x4a, paux[0]);

	nbxw = nbx * binx;
	paux = (unsigned char *) &nbxw;
	sendParameters(0x66, 0x4b, paux[1]);
	sendParameters(0x66, 0x4c, paux[0]);
    }
//
    {
	int dyw = (posY * binx) + 16;
	paux = (unsigned char *) &dyw;
	sendParameters(0x66, 0x45, paux[1]);
	sendParameters(0x66, 0x46, paux[0]);
	nbyw = nby * binx;
	paux = (unsigned char *) &nbyw;
	sendParameters(0x66, 0x47, paux[1]);
	sendParameters(0x66, 0x48, paux[0]);
    }

    if (option3) {
	sendParameters(0x66, 0x22, 0x02);
	sendParameters(0x66, 0x20, 0x1f);
    } else {
	sendParameters(0x66, 0x22, 0x00);
	sendParameters(0x66, 0x20, 0x00);
    }
    paux = (unsigned char *) &expo;
    sendParameters(0x66, 0x4f, paux[0]);
    sendParameters(0x66, 0x4e, paux[1]);
    sendParameters(0x66, 0x4e, (char) (paux[1] + 0x40));

    //
    sendParameters(0x66, 0x10, (char) gain);
    sendParameters(0x66, 0x23, (char) offset);
    //
    sendParameters(0x66, 0x42, 0x01);
    sendParameters(0x66, 0x42, 0x0);

    return (0);
}

int scr_read_ccd(int nbx, int nby, int binx, short *pixels)
{
    int valn;
    int i;
    long j;
    unsigned char val;
    int option2 = 0;

    if (!option2) {
	for (i = 0; i < (nby * (nbx - 1));) {
	    do {
		mclk(1);
		reg = libcam_in(Porte);
	    } while (!(reg & 0x20));	// non bcl sans i
	    reg |= 0x01;	// vclk (data) sur un mclk haut ?
	    libcam_out(Portc, reg);
	    // mvt de data
	    for (j = 0; j < nbx;) {
		libcam_out(Portc, 0xef);
		libcam_out(Portc, 0xed);
		reg = libcam_in(Port);	// sauvegarde de data
		val = libcam_in(Port);
		valn = val;
		if (binx == 2) {
		    // deuxi�me lecture pour bin
		    libcam_out(Portc, 0xef);
		    libcam_out(Portc, 0xed);
		    reg = libcam_in(Port);	// sauvegarde de data
		    val = libcam_in(Port);
		    // et addition
		    valn = valn + val;
		}		// fin bin
		i++;
		j++;
		if (valn > 255)
		    valn = 255;
		*pixels++ = (short) (valn * 128);
	    }			// fin boucle data
	}			// fin de l'acquisition
    }				// fin du if ok

/**********************************************/
    else {
	//  lecture epp
	for (i = 0; i < (nby * (nbx - 1));) {
	    do {
		// mclk par lecture epp
		reg = libcam_in(eppdata);
		reg = libcam_in(Porte);
	    } while (!(reg & 0x20));	// vclk (data) sur un mclk haut ?

	    // mvt de data
	    for (j = 0; j < nbx;) {
		val = libcam_in(eppdata);	// mclk epp
		valn = val;
		if (binx == 2) {
		    // deuxi�me lecture pour bin
		    val = libcam_in(eppdata);	// mclk epp
		    valn = valn + val;
		}		// fin bin
		j++;
		i++;
		if (valn > 255)
		    valn = 255;
		*pixels++ = (short) (valn * 128);
	    }			// fin boucle data
	}			// fin bcl image
    }				// fin du else epp
    return (0);
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

void synonyme_test_out(struct camprop *cam, unsigned long nb_out)
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
