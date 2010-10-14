/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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
 *
 * $Id: camera.c,v 1.8 2009-11-06 23:06:50 michelpujol Exp $
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
#include <unistd.h>
#include <ctype.h>		/* DM: for isdigit function */
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/timeb.h>		/* pour timer */
#include <stdio.h>

#include "camera.h"
#include <libcam/util.h>
#include "socketaudinet.h"
#include "log.h"
#include "contstruct.h"
#include "setip.h"

#if defined(OS_MACOS)
#include <sys/time.h>
#endif

// pour tests sans brancher l'interface audinet
//#define SIMUL_AUDINET

// audinet interface definition

#define MODE_MONO    1		// une image
#define MODE_SCAN    2		// drift scan
#define MODE_CONT    4		// lecture d'image continue
#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0

// fonctions locales
static int sendHttpRequest(char *host, int port, char *url);
static int loadImage(struct camprop *cam, int nbcol, int nbrow,
		     unsigned short *p0);

// Gestion de la priorite du thread
static int setHighestPriority();
static void restaurePriority(int priority);

// variables locales
#ifdef SIMUL_AUDINET
static int pixval;		// juste pour changer de couleur entre 2 images
#endif

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Audine",			/* camera name */
     "audine",    /* camera product */
     "kaf401",			/* ccd name */
     768, 512,			/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"audine",			/* camera name */
     "Audine",    /* camera model */
     "kaf1602",			/* ccd name */
     1536, 1024,		/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"audine",			/* camera name */
     "Audine",    /* camera model */
     "kaf3200",			/* ccd name */
     2184, 1472,		/* maxx maxy */
     46, 37,			/* overscans x */
     34, 4,			/* overscans y */
     6.8e-6, 6.8e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
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

static int read_udp_win_inv(struct camprop *cam, unsigned short *buf);
static void ampli_off(struct camprop *cam);
static void ampli_on(struct camprop *cam);
static void setShutter(struct camprop *cam, int value);
static int sendHttpRequest(char *httpHost, int httpPort, char *url);
static void startTimer();
static double stopTimer();
static int loadImage(struct camprop *cam, int nbcol, int nbrow,
		     unsigned short *buf);
static int setHighestPriority();
static void restaurePriority(int priority);

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

/**
 * cam_init permet d'initialiser les variables de la 
 * structure 'camprop' specifiques a cette camera.                  
 * 
 * retourne 0 si OK, sinon retourne une valeur non nulle
 */

int cam_init(struct camprop *cam, int argc, char **argv)
{
   int i;
   char macAddress[18];
   int ipsetting = 0;		// pour re-inialiser l'adresse IP
   int logLevel = 0;
   
   initLog(logLevel);
   
   /* on n'utilise pas les fonctions du port  pour ce driver */
   cam->authorized = 1;
   
   /*  valeurs par defaut */
   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
   
   /* --- pour l'amplificateur des Kaf-401 (synchro by default) --- */
   cam->ampliindex = 0;
   cam->nbampliclean = 60;
   cam->shutteraudinereverse = 0;
   /* --- pour les parametres de l'obturateur de Pierre Thierry --- */
   cam->shuttertypeindex = 0;	/* obturateur Audine par defaut */
   /* --- fichier update.log --- */
   cam->updatelogindex = 0;
   
   /* --- audinet --- */
   cam->httpPort = 80;
   cam->udpSendPort = 99;
   cam->udpRecvPort = 4000;
   
   
   /* je remplace les valeurs par defaut par les valeurs choisies  */
   /* par l'utilisateur dans le panneau de configuration de audace */
   for (i = 3; i < argc - 1; i++) {
      if (strcmp(argv[i], "-host") == 0) {
         strcpy(cam->host, argv[i + 1]);
      }
      
      if (strcmp(argv[i], "-protocole") == 0) {
         strcpy(cam->protocole, argv[i + 1]);
      }
      
      if (strcmp(argv[i], "-debug_cam") == 0) {
         logLevel = atoi( argv[i + 1]);
      }
      if (strcmp(argv[i], "-ipsetting") == 0) {
         if ((i + 1) <= (argc - 1)) {
            if (strcmp(argv[i + 1], "1") == 0) {
               ipsetting = 1;
            } else {
               ipsetting = 0;
            }
         }
         
      }
      
      if (strcmp(argv[i], "-macaddress") == 0) {
         if ((i + 1) <= (argc - 1)) {
            STRNCPY(macAddress, argv[i + 1]);
         }
      }
      
      if (strcmp(argv[i], "-udptempo") == 0) {
         
         int isnumber = 1;
         int ii;
         for (ii = 0; ii < (int) strlen(argv[i + 1]); ii++) {
            if (!isdigit((int) argv[i + 1][ii])
               && argv[i + 1][ii] != ' ') {
               isnumber = 0;
               break;
            }
         }
         
         if (isnumber) {
            cam->udpTempo = atoi(argv[i + 1]);
         } else {
            sprintf(cam->msg, "\n udptempo=%s must be a number !",
               argv[i + 1]);
            return 1;
         }
      }
      
   }

   initLog( logLevel);

#ifndef SIMUL_AUDINET
    if (ipsetting == 1) {
	// envoie l'adresse IP a Audinet
	setip(cam->host, macAddress, 0, 0, cam->msg);
    }
    // test de la connexion ethernet : essai 4 ping avec timout = 1000 ms 
    if (ping(cam->host, 4, 1000) == TRUE) {
	return 0;
    } else {
	sprintf(cam->msg, "\n ping %s failed !", cam->host);
	return 1;
    }
#else
    return 0;
#endif


}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
   if (cam->authorized == 1) {
      /* case : shutter always off (Darks) */
      if (cam->shutterindex == 0) {
         cam_shutter_off(cam);
      }
      
      /* vidage de la matrice */
      audinet_fast_vidage_inv(cam);
      
      /* shutter always on for synchro mode */
      if ((cam->shutterindex == 1)) {
         cam_shutter_on(cam);
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
      /* shutter always off for synchro mode */
      if (cam->shutterindex == 1) {
         cam_shutter_off(cam);
      }
      /* ampli */
      if (cam->ampliindex == 0) {
         ampli_on(cam);
      }
      /* Lecture de l'image */
      read_udp_win_inv(cam, p);
   }
}

void cam_shutter_on(struct camprop *cam)
{
   if (cam->authorized == 1) {
      if (cam->shutteraudinereverse == 0) {
         setShutter(cam, 0);
      } else {
         setShutter(cam, 1);
      }
   }
}

void cam_shutter_off(struct camprop *cam)
{
   if (cam->authorized == 1) {
      if (cam->shutteraudinereverse == 0) {
         setShutter(cam, 1);
      } else {
         setShutter(cam, 0);
      }
   }
}

void cam_ampli_on(struct camprop *cam)
{
   if (cam->authorized == 1) {
      /* ampli off */
      ampli_on(cam);
   }
}

void cam_ampli_off(struct camprop *cam)
{
   if (cam->authorized == 1) {
      /* ampli off */
      ampli_off(cam);
   }
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

    cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */


/**
 * audinet_fast_vidage_inv
 *
 * Vidage rapide de la matrice. Le decalage des lignes s'effectue
 * ici par groupe de 4, mais est le seul parametre a regler ici.
 * 
 * Requete envoyee a audinet :
 * http://xxx.xxx.xxx.xxx:pp/razccd.cgi?col=%d&row=%d&grp=%d
 * avec :
 *     xxx.xxx.xxx.xxx : adresse IP
 *     pp              : numero de port TCP
 *     col             : nombre de colonnes 
 *     grp             : nombre de groupe de lignes 
 *     gsiz            : nombre de lignes par groupe 
 *
 * si OK, la requete retourne 'K'  
 * si erreur, la requete retourne 'E', suivi d'un message 
 */

int audinet_fast_vidage_inv(struct camprop *cam)
{
   int result;
   char url[512];
   
   int imax, jmax, decaligne;
   
   /* Nombre de lignes decalees a chaque iteration. */
   decaligne = 4;
   
   /* Calcul des constantes de vidage de la matrice. */
   imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
   jmax = (cam->nb_photoy + cam->nb_deadbeginphotoy +
      cam->nb_deadendphotoy) / decaligne + 1;
   
   /* je prepare l'URL */
   sprintf(url, "/cgi-bin/razccd.cgi?col=%d&grp=%d&gsiz=%d",
      imax, jmax, decaligne);
   
   logInfo("audinet_fast_vidage_inv url=http://%s:%d%s", cam->host,
      cam->httpPort, url);
   
   result = sendHttpRequest(cam->host, cam->httpPort, url);
   return result;

}


/**
 * read_udp_win_inv
 *
 * Lecture d'une image complete ou partielle (mode fenetre)
 *
 * Requete envoyee a audinet :
 * http://xxx.xxx.xxx.xxx:pp/getImage.cgi?bx=%d&by=%d&cx1=%d&cx2=%d&cy1=%d&col=%d&row=%d
 * avec :
 *     xxx.xxx.xxx.xxx : adresse IP
 *     pp              : numero de port TCP
 *     bx              : binning x  (cumul des lignes)
 *     by              : binning y  (cumul des colonnes)
 *     cx1             : nombre de colonnes a ignorer au debut
 *     cx2             : nombre de colonnes a ignorer a la fin
 *     cy1             : nombre de lignes a ignorer au debut
 *     col             : nombre de colonnes à lire
 *     row             : nombre de lignes à lire
 */
int read_udp_win_inv(struct camprop *cam, unsigned short *buf)
{
    int result = TRUE;
    char url[256];
    int nbcol, nbrow, colmax;
    int cx1, cx2, cy1;
    
    
    colmax =
       cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
    // Calcul des coordonnees de la  fenetre, et du nombre de pixels 
    nbcol = (cam->x2 - cam->x1 + 1) / cam->binx;
    nbrow = (cam->y2 - cam->y1 + 1) / cam->biny;
    
    
    cx1 = cam->nb_deadbeginphotox + (cam->x1);
    cx2 = cam->nb_photox - 1 - cam->x2 + cam->nb_deadendphotox;
    cy1 = cam->nb_deadbeginphotoy + (cam->y1);
    
    /* je prepare l'url */
    sprintf(url,
       "/cgi-bin/getImage.cgi?bx=%d&by=%d&cx1=%d&cx2=%d&cy1=%d&col=%d&row=%d&colm=%d&ut=%d&mode=%d",
       cam->binx, cam->biny, cx1, cx2, cy1, nbcol, nbrow, colmax,
       cam->udpTempo, MODE_MONO);
    logInfo("read_udp_win_inv url=http://%s:%d%s", cam->host,
       cam->httpPort, url);
    result = sendHttpRequest(cam->host, cam->httpPort, url);
    
    if (result == TRUE) {
       int threadPriority;
       threadPriority = setHighestPriority();
       result = loadImage(cam, nbcol, nbrow, buf);
       restaurePriority(threadPriority);
    }
    return result;
}

/* ================================================================ 
 * DRIFTSCAN
 * ================================================================ 
 */

/**
 * audinet_startScan 
 *  Démarre la lecture du CCD en mode drift scan avec un positionnement
 *  possible en abscisse.
 *  parametres : 
 *    scan->offset : position du premier pixel en x (commence a 1)
 *    scan->width  : largeur de la bande
 *    scan->bin :    facteur de binning (identique en x et y)
 *    scan->buf :    buffer de stockage de la ligne
 */
int audinet_startScan(struct camprop *cam, ScanStruct * scan)
{
   int result = TRUE;
   char url[256];
   int nbcol, nbcolmax;
   int cx1, cx2, cy1;
   int audinetCounter;
   
   
   nbcolmax =
      cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
   /* Calcul des coordonnees de la fenetre, et du nombre de pixels */
   nbcol = scan->width / scan->bin;
   
   cx1 = cam->nb_deadbeginphotox + (scan->offset - 1);
   cx2 =
      cam->nb_photox - scan->width - (scan->offset - 1) +
      cam->nb_deadendphotox;
   cy1 = cam->nb_deadbeginphotoy + cam->y1;
   
   audinetCounter = (int) (7372. * (float) scan->dt / 1024.);
   /* je calcule la valeur du compteur de l'interface audinet */
   
   /* je prepare l'url */
   sprintf(url,
      "/cgi-bin/getImage.cgi?bx=%d&by=%d&cx1=%d&cx2=%d&cy1=%d&col=%d&row=1&colm=%d&ut=%d&mode=%d",
      cam->binx, cam->biny, cx1, cx2, cy1, nbcol, nbcolmax,
      audinetCounter, MODE_SCAN);
   logInfo("audinet_startScan url=http://%s:%d%s", cam->host,
      cam->httpPort, url);
   result = sendHttpRequest(cam->host, cam->httpPort, url);
   
   if (result == TRUE) {
      /* j'ouvre la socket UDP */
      if (!sockudp_open(cam->host, cam->udpSendPort, cam->udpRecvPort)) {
         logError
            ("audinet_startScan udpSocket->openSocket host=%s udpSendPort=%d udpRecvPort=%d",
            cam->host, cam->udpSendPort, cam->udpRecvPort);
         result = FALSE;
      }
   }
   
   return result;
}

/**
 * audinet_scanReadLine
 */
int audinet_scanReadLine(struct camprop *cam, ScanStruct * scan,
			 unsigned short *scanbuf)
{
   unsigned char data[3840];
   int i;
   int n, nTotalRecv;
   int nbcol = scan->width / scan->bin;
   
   unsigned short *p0 = scanbuf;
   
   for (nTotalRecv = 0; nTotalRecv < nbcol * 2;) {
      /* je lis un packet UDP */
      n = sockudp_recv((char *) data, sizeof data);
      if (n <= 0) {
         logError
            ("audinet_startScan packet null sockudp_recv=%d nTotalRecv=%ld host=%s udpSendPort=%d udpRecvPort=%d",
            n, scan->y, cam->host, cam->udpSendPort,
            cam->udpRecvPort);
         /* si erreur ou paquet vide, j'arrete la lecture */
         break;
      } else {
         if (n > nbcol * 2)
            n = nbcol * 2;
         /* je copie les octets dans le tableau des pixels */
         for (i = 0; i < n; i += 2) {
            /* je reconstitue la valeur du pixel  */
            /* formule :  pixel value = low byte + 256 * hight byte */
            *p0 =
               (unsigned short) data[i] +
               ((unsigned short) (data[i + 1]) << 8);
            /* je modifie la valeur du pixel si elle depasse 32767  */
            if (*p0 > 32767)
               *p0 = 32767;
            p0++;
            
         }
         //logImage(scanbuf,nbcol,1); 
         //logInfo("audinet_scanReadLine scan->y=%d, nbcol=%d, n=%d",scan->y,nbcol,n);
      }
      nTotalRecv += n;
   }
   return TRUE;
}


int audinet_stopScan(struct camprop *cam, ScanStruct * scan)
{
   int result = TRUE;
   char url[256];
   
   /* je prepare l'url */
   sprintf(url, "/cgi-bin/stopScan.cgi");
   logInfo("audinet_stopScan url=http://%s:%d%s", cam->host,
      cam->httpPort, url);
   result = sendHttpRequest(cam->host, cam->httpPort, url);
   logInfo("audinet_startScan received rows=%d ", scan->y);
   return result;
}


/**
 * ampli_off
 *
 * inutilise car le host audinet gere directement l'amplificateur 
 */
void ampli_off(struct camprop *cam)
{

}

/**
 * ampli_off
 *
 * inutilise car le host audinet gere directement l'amplificateur 
 */
void ampli_on(struct camprop *cam)
{

}

/**
 * setShutter
 * met la commande de l'obturateur au niveau logique 1 (+5V)
 * 
 * requete envoyee a audinet :
 * http://xxx.xxx.xxx.xxx:pp/setShutter.cgi?val=0|1
 *
 */
void setShutter(struct camprop *cam, int value)
{
   char url[256];
   int result = TRUE;
   
   
   /* je prepare l'url */
   sprintf(url, "/cgi-bin/setShutter.cgi?val=%d", value);
   logInfo("setShutter url=http://%s:%d%s", cam->host, cam->httpPort,
      url);
   // j'envoie la commande
   result = sendHttpRequest(cam->host, cam->httpPort, url);
   
}





/**
 * sendHttpRequest
 *   envoit la requete HTTP a l'interface Audinet
 *   retourne TRUE si la reponse commence par "HTTP/1.1 200"   
 *   retourne FALSE dasn les autres cas.
 */
int sendHttpRequest(char *httpHost, int httpPort, char *url)
{
   
   int result = TRUE;
   char data[3072];
   int n;
   
   
#ifdef SIMUL_AUDINET
   logInfo("sendHttpRequest url=http://%s:%d%s", httpHost, httpPort, url);
   return TRUE;
#endif
   
   
   /* j'ouvre la socket tcp */
   if (!socktcp_open(httpHost, httpPort)) {
      result = FALSE;
   } else {
      /* j'envoi la requete HTTP sur la socket TCP */
      if (!socktcp_send(httpHost, httpPort, url)) {
         logError("sendHttpRequest socktcp_send");
         result = FALSE;
      } else {
         /* je lis le debut de la  reponse */
         n = socktcp_recv(data, sizeof data);
         
         /* je verifie que l'envoi de la requete est OK  */
         if (n >= 12) {
            if (strcmp(data, "HTTP/1.1 200") != 0) {
               //logInfo("sendHttpRequest OK");
               result = TRUE;
            } else {
               /* make null terminated string */
               data[n] = 0;
               logError("sendHttpRequest : %s", data);
               result = FALSE;
            }
         } else {
            logError("sendHttpRequest data n=%d ", n);
            result = FALSE;
         }
      }
      /* je referme la socket tcp */
      socktcp_close();
   }
   return result;
}

static double _startTime;

void startTimer()
{
#if defined(OS_WIN)
    struct _timeb timebuffer;
    _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
    struct timeb timebuffer;
    ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
    _startTime =
	((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
    struct timeval date;
    gettimeofday(&date, NULL);
    _startTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
}

double stopTimer()
{
    double stopTime;
#if defined(OS_WIN)
    struct _timeb timebuffer;
    _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
    struct timeb timebuffer;
    ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
    stopTime =
	((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
    struct timeval date;
    gettimeofday(&date, NULL);
    stopTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
    return stopTime - _startTime;

}


/**
 * loadImage
 *
 * lit les pixeles d'une image qui arrivent dans des paquets UDP 
 */
int loadImage(struct camprop *cam, int nbcol, int nbrow,unsigned short *buf)
{
   
   int result = TRUE;
   long nTotalExpected;
   long nTotalRecv;
   unsigned short *p0 = buf;
   int npacket = 0;
   long npixel = 0;
   int i;
   double elapse_time;
   unsigned char data[3072];
   
   nTotalExpected = nbrow * nbcol * 2;
   
   
   startTimer();
   
#ifndef SIMUL_AUDINET
   // j'ouvre la socket UDP 
   if (!sockudp_open(cam->host, cam->udpSendPort, cam->udpRecvPort)) {
      logError
         ("audinet_startScan udpSocket->openSocket host=%s udpSendPort=%d udpRecvPort=%d",
         cam->host, cam->udpSendPort, cam->udpRecvPort);
      result = FALSE;
   } else {
      //logInfo("loadImage begin avant for");
      /* je lis les pixels sur la socket UDP  */
      for (nTotalRecv = 0; nTotalRecv < nTotalExpected + 1;) {
         int n = 0;
         /* je lis un packet UDP */
         n = sockudp_recv((char *) data, sizeof data);
         //logInfo("loadImage npacket=%d n=%d ", npacket, n);
         if (n <= 1) {
            if (n == 1 && data[0] == 'K') {
               // fin de trame  
               //logInfo("loadImage fin de trame ");
               result = TRUE;
               break;
            } else {
               logError
                  ("loadImage sockudp_recv=%d nTotalRecv=%d nTotalExpected=%d host=%s udpSendPort=%d udpRecvPort=%d",
                  n, nTotalRecv, nTotalExpected, cam->host,
                  cam->udpSendPort, cam->udpRecvPort);
               // si erreur ou paquet vide, j'arrete la lecture 
               result = FALSE;
               break;
            }
         } else {
            if (nTotalRecv + n > nTotalExpected) {
               /* si le dernier packet est trop gros,alors je ne lis que les n premiers octets */
               n = nTotalExpected - nTotalRecv;
               result = TRUE;
            } else {
               nTotalRecv += n;
            }
            npacket++;
            //logInfo("loadImage copy image");
            
            /* je copie les octets dans le tableau des pixels */
            for (i = 0; i < n; i += 2) {
               /* je reconstitue la valeur du pixel  */
               /* formule :  pixel value = low byte + 256 * hight byte */
               p0[npixel] =
                  (unsigned short) data[i] +
                  ((unsigned short) (data[i + 1]) << 8);
               /* je modifie la valeur du pixel si elle depasse 32767  */
               if (p0[npixel] > 32767)
                  p0[npixel] = 32767;
               
               npixel++;
            }
         }
      }			// end for 
   }
      
   // je ferme la socket UDP
   sockudp_close();
#else
   //  SIMULATION
   for (nTotalRecv = 0; nTotalRecv < nTotalExpected;) {
      int n;
      int pixval2;
      
      // je genere des paquets de données , comme envoyés par audinet
      n = nbcol * 2;
      for (i = 0; i < n; i += 2) {
         pixval2 = pixval + i / 2;
         data[i] = (unsigned char) (pixval2 & 255);
         data[i + 1] = (unsigned char) (pixval2 >> 8);
         
      }
      nTotalRecv += n;
      npacket++;
#if defined(OS_WIN)
      // je simule le temps de lecture du kaf
      Sleep((nbcol / 50));
#endif
      
      /* je copie les octets dans le tableau des pixels */
      for (i = 0; i < n; i += 2) {
         /* je reconstitue la valeur du pixel  */
         /* formule :  pixel value = low byte + 256 * hight byte */
         p0[npixel] =
            (unsigned short) data[i] +
            ((unsigned short) (data[i + 1]) << 8);
         /* je modifie la valeur du pixel si elle depasse 32767  */
         if (p0[npixel] > 32767)
            p0[npixel] = 32767;
         
         npixel++;
      }
      //logInfo("loadImage npacket=%d n=%d ", npacket, n);
   }
   logInfo("loadImage pixval=%d", pixval);
   // je change le niveau de gris pour l'image suivante
   pixval += 1000;
   if (pixval > 32000)
      pixval = 0;
#endif
   
   elapse_time = stopTimer();
   //logInfo("loadImage nbrow=%d nbcol=%d nTotalExpected=%ld nTotalRecv=%ld npacket=%d",
   //cont->nbrow, cont->nbcol, nTotalExpected, nTotalRecv, npacket );
   logInfo("loadImage elapse time=%6.2f ", elapse_time);
   
   return result;
}

/*
 * -----------------------------------------------------------------------------
 * setHighestPriority
 * change la priorité de la thread courante
 * 
 * -----------------------------------------------------------------------------
 */
int setHighestPriority()
{
   
#if defined(OS_WIN)
   int priority;
   // je memorise l'anciene priorite
   priority = GetThreadPriority(GetCurrentThread());
   // j'attribue la priorite maximale
   SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_HIGHEST);
   return priority;
#endif
   
#if defined(OS_LIN) || defined(OS_MACOS)
   // a etudier ( utiliser nice ?)
   // j'augmente la priority de 20 points
   // si c'est deja au maxi, ce n'est pas grave Linux gere...
   //nice(-20);  // le test va etre fait par B Minster
   return 1;
#endif
}

/*
 * -----------------------------------------------------------------------------
 * restaurePriority
 * change la priorité de la thread courante
 * 
 * -----------------------------------------------------------------------------
 */
void restaurePriority(int priority)
{

#if defined(OS_WIN)
    // je restaure l'ancienne priorite
    SetThreadPriority(GetCurrentThread(), priority);
#endif

#if defined(OS_LIN)
    // a etudier ( utiliser nice ?)
    // je diminue la priority de 20 points 
    // risque de ne pas marcher , car il faut etre superuser pour diminuer la priorite
    //nice(20); // le test va etre fait par B Minster
    return;
#endif



}
