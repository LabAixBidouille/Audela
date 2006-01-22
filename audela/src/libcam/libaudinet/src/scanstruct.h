/* scanstruct.h
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
 * $Id: scanstruct.h,v 1.2 2006-01-22 22:01:28 michelpujol Exp $
 */

#ifndef __SCANSTRUCT_H__
#define __SCANSTRUCT_H__


typedef struct {
    char *dateobs;		/* Date du debut de l'observation (format FITS) */
    char *dateend;		/* Date de fin de l'observation (format FITS) */
    ClientData clientData;	/* Camera (CCamera*) */
    Tcl_Interp *interp;		/* Interpreteur */
    Tcl_TimerToken TimerToken;	/* Handler sur le timer */
    int width;			/* Largeur de l'image */
    int offset;			/* Offset en x (a partir de 1) */
    int height;			/* Hauteur totale de l'image */
    int bin;			/* binning */
    float dt;			/* intervalle de temps en millisecondes */
    int y;			/* nombre de lignes deja lues */
    unsigned long t0;		/* instant de depart en microsecondes */
    unsigned short *pix;	/* stockage de l'image */
    unsigned short *pix2;	/* pointeur defilant sur le contenu de pix */
    int last_delta;		/* dernier delta temporel */
    int blocking;		/* vaut 1 si le scan est bloquant */
    int keep_perfos;		/* vaut 1 si on conserve les dt du scan dans 1 fichier */
    int fileima;		/* vaut 1 si on écrit les pixels dans un fichier */
    FILE *fima;			/* fichier binaire pour stocker les pixels */
    int *dts;			/* tableau des délais */
    unsigned long loopmilli1;	/* nb de boucles pour faire une milliseconde (~10000) */
    int stop;			/* indicateur d'arret (1=>pose arretee au prochain coup) */
    double tumoinstl;		/* TU-TL */
    double ra;			/* RA at the bigining */
    double dec;			/* DEC at the bigining */
} ScanStruct;


#endif
