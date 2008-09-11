/* libjm.h
 *
 * This file is part of the libjm library for AudeLA project.
 *
 * Initial author : Jacques MICHELET <jacques.michelet@laposte.net>
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
 * Projet      : AudeLA
 * Librairie   : LIBJM
 * Fichier     : LIBJM.H
 * Description : Point d'entrée de la librairie
 * ============================================
*/

#define NUMERO_VERSION "3.2"


#ifndef __LIBJMH__
#define __LIBJMH__

#include "sysexp.h"

#ifdef LIBRARY_DLL
# include <windows.h>
#endif

#ifdef OS_WIN_BORL_DLL
# include "tcl.h"
# include "tk.h"
#endif

#ifdef OS_WIN_VCPP_DLL
# include "tcl.h"
# include "tk.h"
#endif

#ifdef LIBRARY_SO
# include <tcl.h>
#endif

#include "jm_c_tcl.h"
#include "jm.h"

#ifdef LIBRARY_DLL
   __declspec(dllexport) int __cdecl Jm_Init(Tcl_Interp *interp);
#endif

#ifdef LIBRARY_SO
   extern int Jm_Init(Tcl_Interp *interp);
#endif

#endif


