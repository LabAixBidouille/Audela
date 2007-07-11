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
  {"TH7852A",     /* camera name */
   "th7852a",      /* camera product */
   "TH7852A",      /* ccd name */
   208,144,        /* maxx maxy */
   8,2,            /* overscans x */
   1,0,            /* overscans y*/
   30e-6,28e-6,    /* photosite dim (m) */
   4096.,           /* observed saturation */
   0.93333333,     /* filling factor */
   30.,            /* gain (e/adu) */
   100.,           /* readnoise (e) */
   1,1,            /* default bin x,y */
   1.,             /* default exptime */
   1,              /* default state of shutter (1=synchro) */
   1,              /* default num buf for the image */
   1,              /* default num tel for the coordinates taken */
   0,              /* default port index (0=lpt1) */
   1,              /* default cooler index (1=on) */
   -15.,           /* default value for temperature checked */
   1,              /* default color mask if exists (1=cfa) */
   0,              /* default overscan taken in acquisition (0=no) */
   1.              /* default focal lenght of front optic system */
   },
   CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, char **argv);
static void cam_update_window(struct camprop *cam);
static void cam_start_exp(struct camprop *cam,char *amplionoff);
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
static void cam_set_binning(int binx, int biny,struct camprop *cam);

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

static int th7852_attente(struct camprop *cam,int tempo);
static int th7852_vidage(struct camprop *cam);
static int th7852_goto_zm(struct camprop *cam,int tempo);
static int th7852_reset_zm(struct camprop *cam);
static int th7852_zmzh(struct camprop *cam);
static int th7852_init(struct camprop *cam);
static int th7852_readoffset(struct camprop *cam,int *value);
static void th7852_read(struct camprop *cam,unsigned short *buf);


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
    // Astuce pour autoriser l'acces au port parallele
    libcam_bloquer();
    libcam_debloquer();
#endif
 
   cam_update_window(cam); /* met a jour x1,y1,x2,y2,h,w dans cam */
   cam->port=769;
   if (cam->authorized==1) {
      th7852_init(cam);
   }
   cam->nummode=0;
   cam->micro1=loopsmicrosec();
   cam->timescale=1.;
   return 0;
}

void cam_start_exp(struct camprop *cam,char *amplionoff)
{
   char ligne[1024];
   short i;
   short nb_vidages;

   if (cam->authorized==1) {
      libcam_strlwr(CAM_INI[cam->index_cam].name,ligne);
      /* Bloquage des interruptions */
   	  if (cam->interrupt==1) { libcam_bloquer(); }
      /* rincage */
      nb_vidages=7;
      for (i=0;i<nb_vidages;i++) {
         th7852_vidage(cam);
      }
      /* Debloquage des interruptions */
   	  if (cam->interrupt==1) { libcam_debloquer(); }
      /* Remise a l'heure de l'horloge de Windows */
      if (cam->interrupt==1) {update_clock();}
   }
}

void cam_stop_exp(struct camprop *cam)
{
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
   char ligne[1024];
   if(p==NULL) return ;
   if (cam->authorized==1) {
      libcam_strlwr(CAM_INI[cam->index_cam].name,ligne);
      /* Bloquage des interruptions */
   	  if (cam->interrupt==1) { libcam_bloquer(); }
      /* lecture et numerisation de l'image */
      cam->nummode=0;
      th7852_read(cam,p);
      /* Debloquage des interruptions */
   	  if (cam->interrupt==1) { libcam_debloquer(); }
      /* Remise a l'heure de l'horloge de Windows */
      if (cam->interrupt==1) {update_clock();}
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
   cam->temperature=0.;
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

void cam_set_binning(int binx, int biny,struct camprop *cam)
{
   if (binx>9) { binx=9; }
   if (biny>9) { biny=9; }
   if (binx<1) { binx=1; }
   if (biny<1) { biny=1; }
   cam->binx = binx;
   cam->biny = biny;
}

void cam_update_window(struct camprop *cam)
{
   int maxx,maxy;
   maxx=cam->nb_photox;
   maxy=cam->nb_photoy;
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
/* ========================   CAMTH  ============================== */
/* ================================================================ */
/* ================================================================ */
/* bits du port B (769) 87654321 : Astronomie CCD page 86           */
/* bit 1 : phi P (zizm)                                             */
/* bit 2 : phi M (zmzh)                                             */
/* bit 3 : phi L (pixout)                                           */
/* bit 4 : signal Gate (*)                                          */
/* bit 5 : Start Convert                                            */
/*                                                                  */
/* (*) Si G est au niveau haut et si le bit phi L est au niveau bas */
/* l'horloge est produite par la carte a 500KHz.                    */
/* Si G est au niveau bas, l'horloge est crée par le chronogramme.  */
/* ref : Astronomie CCD page 85                                     */
/*                                                                  */
/* ================================================================ */

int th7852_attente(struct camprop *cam,int tempo)
{
   unsigned long micro,muloop,muloop10,muloops[10];
   micro=(unsigned long)(cam->timescale*(double)cam->micro1*(double)tempo);
   for (muloop10=0,muloop=0;muloop<micro;muloop++) { muloops[muloop10]=(unsigned long)(0); if (++muloop10>9) { muloop10=0; } }
   return 0;
}

int th7852_vidage(struct camprop *cam)
{
   th7852_goto_zm(cam,3);
   th7852_reset_zm(cam);
   return 0;
}

int th7852_goto_zm(struct camprop *cam,int tempo)
/* tranfere toute l'image dans la zone memoire */
{
   unsigned short p0 = cam->port;
   int ymax,i;
   ymax=cam->nb_photoy;
   for (i=1;i<=ymax;i++) {
      /*Transfert d'une ligne de zone image a zone memoire*/
      libcam_out(p0,(unsigned char)3); /* 00000011 */
      th7852_attente(cam,tempo);
      libcam_out(p0,(unsigned char)0); /* 00000000 */
      th7852_attente(cam,tempo);
   }
   return 0;
}

int th7852_reset_zm(struct camprop *cam)
/* Razmemoire. Vide toutes les charges de la zone memoire */
/* et nettoie le registre horizontal a chaque ligne */
{
   unsigned short p0 = cam->port;
   int ymax,i;
   ymax=cam->nb_photox;
   for (i=1;i<=ymax;i++) {
      /*Transfert zone memoire au registre horizontal*/
      libcam_out(p0,(unsigned char)2); /* 00000010 */
      th7852_attente(cam,3);
      libcam_out(p0,(unsigned char)0); /* 00000000 */
      th7852_attente(cam,3);
      /*Lecture du registre horizontal (Signal G a 1) sans numerisation*/
      libcam_out(p0,(unsigned char)8); /* 00001000 */
      th7852_attente(cam,6);
      libcam_out(p0,(unsigned char)0); /* 00000000 */
   }
   return 0;
}

int th7852_zmzh(struct camprop *cam)
/* Equivalent du zizh dans une camera pleine trame. */
/* Transfere une ligne de la zone M vers le registre horizontal. */
{
   unsigned short p0 = cam->port;
   libcam_out(p0,(unsigned char)2); /* 00000010 */
   th7852_attente(cam,3);
   libcam_out(p0,(unsigned char)0); /* 00000000 */
   th7852_attente(cam,3);
   return 0;
}

int th7852_init(struct camprop *cam)
{
   unsigned short p2 = cam->port+2;
   /*Initialisation du PIO*/
   libcam_out(p2,(unsigned char)153);
   return 0;
}

int th7852_readoffset(struct camprop *cam,int *value)
{
   unsigned short p0 = cam->port;
   unsigned short p770 = cam->port+1;
   unsigned short p768 = cam->port-1;
   int val=0;
   libcam_out(p0,(unsigned char)0);
   th7852_attente(cam,7);
   libcam_out(p0,(unsigned char)16); /* start convert */
   th7852_attente(cam,7);
   val=256*(int)libcam_in(p770)+(int)libcam_in(p768);
   *value=val;
   return 0;
}

/*
   Lecture normale du CCD, avec un fenetrage possible.
*/
void th7852_read(struct camprop *cam,unsigned short *buf)
{
   int i,j;
   int k;
   int imax,jmax;
   int cx1,cx2,cy1;
   unsigned short port0;
   unsigned short buffer[10000];
   unsigned short *p0;
   int x,ref;
   unsigned short p770 = cam->port+1;
   unsigned short p768 = cam->port-1;

   p0=buf;
   port0 = cam->port;

   /* Calcul des coordonnees de la    */
   /* fenetre, et du nombre de pixels */
   imax = (cam->x2-cam->x1+1)/cam->binx;
   jmax = (cam->y2-cam->y1+1)/cam->biny;
   cx1 = cam->nb_deadbeginphotox+(cam->x1);
   cx2 = cam->nb_photox-1-cam->x2+cam->nb_deadendphotox;
   cy1 = cam->nb_deadbeginphotoy+(cam->y1);

   /* transfert vers la zone memoire */
   th7852_goto_zm(cam,7);

   /* On supprime les cy1 premieres lignes */
   for(i=0;i<cy1;i++) {
      th7852_zmzh(cam);
   }

   /* On nettoie le registre horizontal */
   for (i=0;i<3;i++) {
      /*Lecture du registre horizontal (Signal G a 1) sans numerisation*/
      libcam_out(port0,(unsigned char)8); /* 00001000 */
      th7852_attente(cam,6);
      libcam_out(port0,(unsigned char)0); /* 00000000 */
   }

   /* boucle sur l'horloge verticale (transfert) */
   for (i=0;i<jmax;i++) {

      /* Rincage du registre horizontal */
      libcam_out(port0,(unsigned char)8); /* 00001000 */
      th7852_attente(cam,1);
      libcam_out(port0,(unsigned char)0); /* 00000000 */

      /* Cumul des lignes (binning y) */
      for(k=0;k<cam->biny;k++) th7852_zmzh(cam);

      /* On retire les cx1 premiers pixels sans numérisation */
      for (j=0;j<cx1;j++) {
         libcam_out(port0,(unsigned char)16); /* 00010000 */
         th7852_attente(cam,4);
         libcam_out(port0,(unsigned char)20); /* 00010100 */
         th7852_attente(cam,5);
      }

      /* boucle sur l'horloge horizontale (registre de sortie) */
      for(j=0;j<imax;j++) {

         /* A ce moment, le front de l'horloge phi L est descendant. */
         /* Cela déclenche automatiquement un Reset pendant environ  */
         /* 0,1us. La durée optimale du niveau bas de phi L devrait  */
         /* etre de l'ordre de 0,3us. */

         /* On digitalise juste avant le niveau de reset (?)     */
         /* Cela bloque l'échantillonneur bloqueur afin d'éviter */
         /* de transmettre le Reset vers l'ampli.                */
         libcam_out(port0,(unsigned char)16); /* 00010000 */
         th7852_attente(cam,4);
         libcam_out(port0,(unsigned char)0);  /* 00000000 */
         /* Delai d'établissement du palier de reference */
         th7852_attente(cam,7);
         /* On digitalise le niveau de reference */
         libcam_out(port0,(unsigned char)16); /* 00010000 */
         /* Delais de stabilisation du CAN */
         th7852_attente(cam,7);
         /* On lit le niveau de reference */
         ref=256*(int)libcam_in(p770)+(int)libcam_in(p768);

         /* Maintenant on va monter le niveau de phi L pour transférer */
         /* les charges du pixel vers l'étage de sortie.               */

         /* Quelques lignes inutiles a mon avis... */
         libcam_out(port0,(unsigned char)20); /* 00010100 */
         th7852_attente(cam,4);
         libcam_out(port0,(unsigned char)4);  /* 00000100 */
         th7852_attente(cam,9);
         /* On digitalise le niveau du palier video */
         libcam_out(port0,(unsigned char)20); /* 00010100 */
         /* Delais de stabilisation du CAN */
         th7852_attente(cam,7);
         /* On lit le niveau video */
         x=256*(int)libcam_in(p770)+(int)libcam_in(p768);

         /* difference du double echantillonnage numerique */
         if (cam->nummode==0) {
            x=x-ref;
         } else {
            x=ref;
         }
         if (x>4095) x=4095;
         if (x<0) x=0;

         /* Stockage dans un buffer dans la meme page mem */
         buffer[j] = (unsigned short)x;
      }

      /* On retire cx2 pixels à la fin */

      for (j=0;j<cx2;j++) {
         libcam_out(port0,(unsigned char)16); /* 00010000 */
         th7852_attente(cam,4);
         libcam_out(port0,(unsigned char)20); /* 00010100 */
         th7852_attente(cam,5);
      }

      /*
	  Ca c'est pour stocker les pixels dans la memoire
      centrale. Notons que ca pose PB car il peut y avoir
      un swap memoire et ca fait sauter le cli. On ne fait
      le transfert qu'une fois par ligne, pour eviter les
      cochonneries.
	  */
      for(j=0;j<imax;j++) {
         *(p0++)=buffer[j];
      }
   }
}
