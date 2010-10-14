/* camera.h
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
 * Adapter le contenu de ce fichier a votre camera preferee
 * notamment la structure "camprop"
 *
 * $Id: camera.h,v 1.2 2006-01-22 22:01:28 michelpujol Exp $
 */


#ifndef __CAMERA_H__
#define __CAMERA_H__

//#ifdef OS_LIN
//#define __KERNEL__
//#   include <sys/io.h>
//#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>
#include "scanstruct.h"
#include "contstruct.h"


/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour Audine --- */
    /* --- pour l'amplificateur des Kaf-401 --- */
    int ampliindex;
    int nbampliclean;
    /* --- pour l'obturateur Audine --- */
    int shutteraudinereverse;
    /* --- pour l'obturateur a Pierre Thierry --- */
    int shuttertypeindex;	/* 0=audine 1=thierry */
    /* --- flag pour updatelog --- */
    int updatelogindex;
    /* --- pour audinet ---- */
    char host[256];
    char protocole[3];
    int httpPort;
    int udpSendPort;
    int udpRecvPort;
    int udpTempo;		// temporisation de la reception des packets udp

};

int audinet_fast_vidage_inv(struct camprop *cam);
int audinet_startScan(struct camprop *cam, ScanStruct * scan);
int audinet_scanReadLine(struct camprop *cam, ScanStruct * scan,
			 unsigned short *scanbuf);
int audinet_stopScan(struct camprop *cam, ScanStruct * scan);

#define TRUE 1
#define FALSE 0


#endif
