/* libtt.h
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

/***************************************************************************/
/* Ce programme permet l'acces aux fonctions de la bibliotheque de         */
/* traitement de donnees (images et autres) pour l'astronomie.             */
/***************************************************************************/
/* Ce programme peut etre compile selon diverses possibilites :            */
/***************************************************************************/
/* Il n'y a qu'un seul point d'entree pour acceder a l'ensemble des        */
/* fonctions. De cette facon, le programme appelant n'a besoin de definir  */
/* Uniquement que la fonction d'entree definie comme suit :                */
/*                                                                         */
/* int libtt_main(int service, ...)                                        */
/*                                                                         */
/* En entree :                                                             */
/*  service : est un nombre entier qui designe la fonction                 */
/* En entree/sortie                                                        */
/*  ... : une suite de parametres d'entree ou de sortie suivant le cas     */
/* En sortie :                                                             */
/*  int : retourne un code d'erreur ou zero si tout c'est bien passe       */
/***************************************************************************/
#ifndef __LIBTTH__
#define __LIBTTH__

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/
#include "sysexp.h"

/* --- definition communes a tous les OS ---*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
#include <varargs.h>
#else
#include <stdarg.h>
#endif

/* --- definitions specifiques a l'OS pour l'appel de la fonction d'entree  ---*/

/**************************************************************/
/* Directives d'utilisation depuis Borland C++ Builder v3.pro */
/*------------------------------------------------------------*/
/* Pour utiliser le point d'entree libtt depuis un autre      */
/* logiciel, il faut y inclure la ligne suivante :            */
/* LIBTT *libtt_main                                          */
/* et affecter cette variable par l'adresse dans la dll       */
/* (fonction GetProcAddress(HINSTANCE,LPVOID) )               */
/**************************************************************/
#ifdef OS_WIN_BORLB_DLL
typedef int LIBTT(int,...);
#define FILE_DOS
#define OS_WIN32
#include <windows.h>
int __export __stdcall libtt_main(int,...);
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_WIN_BORL_DLL
typedef int LIBTT(int,...);
#define FILE_DOS
#define OS_WIN32
#include <windows.h>
int __export __stdcall libtt_main(int,...);
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_WIN_VCPP_DLL
#define FILE_DOS
#define OS_WIN32
typedef int LIBTT(int,...);
#include <windows.h>
__declspec(dllexport) int __stdcall _libtt_main(int,...);
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_UNIX_CC
#define OS_UNIX
int libtt_main(int service, ...);
#endif

#ifdef OS_UNIX_CC_HP_SL
#define OS_UNIX
extern int libtt_main(int service, ...);
#endif

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
#define OS_UNIX
extern int libtt_main(...);
#endif

#ifdef OS_LINUX_GCC_SO
#define OS_UNIX
#include <dlfcn.h>
typedef int LIBTT(int,...);
#endif

#ifdef OS_UNIX_GCC_DEC_SO
#define OS_UNIX
#include <dlfcn.h>
typedef int LIBTT(int,...);
#endif

#ifdef OS_DOS_WATC
#define OS_WIN16
int libtt_main(int service, ...);
#endif

#ifdef OS_DOS_WATC_LIB
#define OS_WIN16
extern int libtt_main(int service, ...);
#endif

#ifdef OS_WIN_VCPP
#define OS_WIN32
int libtt_main(int service, ...);
#endif

// Librairie de traitement d'images
extern LIBTT *Libtt_main;

void load_libtt(void);


/***************************************************************************/
/************** variables utiles pour les fonctions de FITSIO **************/
/***************************************************************************/
/*                     ne pas changer ces valeurs                          */
/***************************************************************************/

#ifndef FLEN_FILENAME 
#define FLEN_FILENAME 1025 /* max length of a filename  */
/*#define FLEN_FILENAME 161*/ /* max length of a filename  */
#endif

#ifndef FLEN_KEYWORD 
#define FLEN_KEYWORD   72  /* max length of a keyword (HIERARCH convention) */
/*#define FLEN_KEYWORD    9*/  /* max length of a keyword */
#endif

#define FLEN_CARD      81  /* length of a FITS header card */
#define FLEN_VALUE     71  /* max length of a keyword value string */
#define FLEN_COMMENT   73  /* max length of a keyword comment string */
#define FLEN_ERRMSG    81  /* max length of a FITSIO error message */
#define FLEN_STATUS    31  /* max length of a FITSIO status text string */

#define TBIT          1  /* codes for FITS table data types */
#define TBYTE        11
#define TLOGICAL     14
#define TSTRING      16
#define TUSHORT      20
#define TSHORT       21
#define TINT         31
#define TULONG       40
#define TLONG        41
#define TFLOAT       42
#define TDOUBLE      82
#define TCOMPLEX     83
#define TDBLCOMPLEX 163

#define BYTE_IMG      8  /* BITPIX code values for FITS image types */
#define SHORT_IMG    16
#define LONG_IMG     32
#define FLOAT_IMG   -32
#define DOUBLE_IMG  -64
			 /* The following 2 codes are not true FITS         */
			 /* datatypes; these codes are only used internally */
			 /* within cfitsio to make it easier for users      */
			 /* to deal with unsigned integers.                 */
#define USHORT_IMG   20
#define ULONG_IMG    40

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

#define TT_ERROR_MESSAGE                100
#define TT_SCRIPT_2                     102
#define TT_SCRIPT_3                     103

#define TT_PTR_LOADIMA                  201
#define TT_PTR_LOADKEYS                 202
#define TT_PTR_ALLOKEYS                 203
#define TT_PTR_STATIMA                  204
#define TT_PTR_SAVEIMA                  205
#define TT_PTR_SAVEKEYS                 206
#define TT_PTR_SAVEJPG                  207
#define TT_PTR_FREEPTR                  208
#define TT_PTR_FREEKEYS                 209
#define TT_PTR_SAVEJPGCOLOR             211
#define TT_PTR_CUTSIMA                  212
#define TT_PTR_SAVEIMA3D                213
#define TT_PTR_LOADIMA3D                214
#define TT_PTR_SAVEIMA1D                215
#define TT_PTR_SAVEIMAKEYDIM            216

#define TT_PTR_IMASERIES                210

#define TT_PTR_ALLOTBL                  220
#define TT_PTR_FREETBL                  221
#define TT_PTR_SAVETBL                  222

#define TT_UTIL_FREE_PTR              20203
#define TT_UTIL_CALLOC_PTRPTR_CHAR    20204
#define TT_UTIL_CALLOC_PTR            20205

#define TT_FCT_IMA_STACK               1001
#define TT_FCT_IMA_SERIES              1002

/***************************************************************************/
#endif

