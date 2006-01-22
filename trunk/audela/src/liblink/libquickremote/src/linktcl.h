/* camtcl.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#ifndef __LINKTCL_H__
#define __LINKTCL_H__

int cmdQuickremoteChar (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdQuickremoteBit  (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdQuickremoteIndex  (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#define SPECIFIC_CMDLIST \
   {"char", (Tcl_CmdProc *) cmdQuickremoteChar},   \
   {"bit", (Tcl_CmdProc *)  cmdQuickremoteBit},    \
   {"index", (Tcl_CmdProc *)  cmdQuickremoteIndex},\

 /* === Specific commands for that camera === */
//int cmdParallelAddress(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#endif
