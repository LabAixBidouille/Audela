/* libyd.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <damerdji@obs-hp.fr>
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

#ifndef __LIBCATALOGH__
#define __LIBCATALOGH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libxx.c     */
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/**             include qui permet de connaitre l'OS utilise              **/
/***************************************************************************/

#include "sysexp.h"

#if defined(LIBRARY_DLL)
#include <windows.h>
#include "tcl.h"
#endif

#if defined(LIBRARY_SO)
#include <tcl.h>
#endif

/*--- Point d'entree de la librairie */
#if defined(LIBRARY_DLL)
   __declspec(dllexport) int __cdecl yd_Init(Tcl_Interp *interp);
#endif
#if defined(LIBRARY_SO)
   extern int yd_Init(Tcl_Interp *interp);
#endif

#if defined(OS_WIN_VCPP_DLL)
#define FILE_DOS
#define LIBRARY_DLL
#endif

#if defined(OS_LINUX_GCC_SO)
#define FILE_UNIX
#define LIBRARY_SO
#endif

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers ydtcl_*.c */
/***************************************************************************/
/***************************************************************************/

#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/

/* Yassine : extraction of stars from catalogs : function for Frederic Vachier */
int cmd_tcl_cstycho2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmd_tcl_csucac2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmd_tcl_csucac3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmd_tcl_csusnoa2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif /* __LIBCATALOGH__ */

