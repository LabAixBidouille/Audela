/* libsext.h
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

#ifndef __LIBSEXTH__
#define __LIBSEXTH__

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

/*--- Fonctions appelables depuis un interpreteur TCL */
/*--- Les prototypes sont tous les memes */

/*--- Point d'entree de la DLL */
#ifdef LIBRARY_DLL
   __declspec(dllexport) int __cdecl Sext_Init(Tcl_Interp *interp);
#endif 

#ifdef LIBRARY_SO
   extern int Sext_Init(Tcl_Interp *interp);
#endif

#endif
