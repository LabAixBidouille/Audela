/* libcatalog.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <yassine.damerdji@gmail.com>
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

#define XTERN

#include "libcatalog.h"

/***************************************************************************/
/*                      Access point to the library                        */
/***************************************************************************/
#if defined(LIBRARY_DLL)
   int __cdecl Catalog_Init(Tcl_Interp *interp)
#endif
#if defined(LIBRARY_SO)
   int Catalog_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libcatalog.",TCL_STATIC);
      return (TCL_ERROR);
   }

   Tcl_PkgProvide(interp,"Catalog","1.0");

   /* Yassine : extraction of stars from catalogs : function for Frederic Vachier */
   Tcl_CreateCommand(interp,"cstycho2",(Tcl_CmdProc *)cmd_tcl_cstycho2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"csucac2" ,(Tcl_CmdProc *)cmd_tcl_csucac2 ,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"csucac3" ,(Tcl_CmdProc *)cmd_tcl_csucac3 ,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"csucac4" ,(Tcl_CmdProc *)cmd_tcl_csucac4 ,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"csusnoa2",(Tcl_CmdProc *)cmd_tcl_csusnoa2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"cs2mass" ,(Tcl_CmdProc *)cmd_tcl_cs2mass ,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"csppmx"  ,(Tcl_CmdProc *)cmd_tcl_csppmx  ,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   return (TCL_OK);
}
