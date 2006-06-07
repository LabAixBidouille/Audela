/* camera.h
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
 * Adapter le contenu de ce fichier a votre camera preferee
 * notamment la structure "camprop"
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

// #include <gphoto2-camera.h>         // pour libgphoto2
// #include <gphoto2-abilities-list.h>
// #include <gphoto2-context.h>
// #include <gphoto2-port-log.h>

/*
 *   structure pour les fonctions de la librairie gphoto2
 */
typedef struct _PrivateParams PrivateParams;

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
   /* --- parametres standards, ne pas changer --- */
   COMMON_CAMSTRUCT;
   /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
   /* --- pour DIGICAL --- */
   
   PrivateParams *params;          // parametres prives de la camera
   char cameraFolder[1024];        // repertoire courant dans la memoire de la camera
   char fileName[1024];            // nom du fichier en cours de traitement ( entre startExp et read_ccd) 
   int autoLoadFlag;
   int driverMode;
   char quality[20];
   
   char longuepose;              // 0=interne, 1=link (quickremote or parallel, ..)  , 2= manual remote
   int  longueposelinkno;
   int  longueposelinkbit;
   char longueposestart;
   char longueposestop;
   
   
};

int  cam_loadLastImage(struct camprop *cam);
int  cam_getSystemServiceState(struct camprop *cam);
int  cam_setLonguePose(struct camprop *cam, int value);
void cam_setSystemServiceState(struct camprop *cam, int state);
int  cam_checkQuality(char *quality);
int  cam_getQualityList(char *list);

#endif
