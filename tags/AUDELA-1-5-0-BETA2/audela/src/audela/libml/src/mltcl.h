/* mltcl.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <Myrtille.Laas@oamp.fr>
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

/***************************************************************************/
/* Ce fichier d'inclusion contient                                         */
/* - l'interfacage avec Tcl/Tk et initialise                               */
/* - l'initialisation la librairie                                         */
/* - les fonctions d'interfacage entre Tcl et le C                         */
/***************************************************************************/
#ifndef __MLTCLH__
#define __MLTCLH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libml.c     */
/***************************************************************************/
/***************************************************************************/

#include "libml.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#if defined(LIBRARY_SO)
#include <unistd.h>    /* getcwd */
#endif

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers mltcl_*.c */
/***************************************************************************/
/***************************************************************************/
#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

#define ML_STAT_LIG_MAX 1000

typedef struct {
   char texte[ML_STAT_LIG_MAX];
   int comment;
   double ha;
   double ra;
   double dec;
   double jd;
   double mag;
   double distance;
   double angle;
   char ident[21];
   int kimage;
   int kimage1;
   int kimage2;
   int kobject;
   int kobject1;
   int kobject2;
   int matched;
   int nouvelledate;
   char matching_id[16];
   double sep;
   double pos;
   double jour;
   double minute;
   double heure;
   double seconde;
} struct_ligsat ;

typedef struct {
   char texte[ML_STAT_LIG_MAX];
   int nbligne;
} struct_texte_fichier;

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/
/*--- Les prototypes sont tous les memes */
int Cmd_mltcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mltcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mltcl_geostatreduc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mltcl_geostatident(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mltcl_residutycho2usno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/***************************************************************************/
/*      Prototypes des fonctions utiles qui melangent C et Tcl             */
/***************************************************************************/
int mltcl_getinfoimage(Tcl_Interp *interp,int numbuf, ml_image *image);
int WriteDisk(char *Chaine);


#endif

