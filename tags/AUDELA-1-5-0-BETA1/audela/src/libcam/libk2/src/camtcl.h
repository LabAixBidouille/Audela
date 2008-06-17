/* camtcl.h
 * 
 * Copyright (C) 2004 Sylvain GIRARD <sly.girard@wanadoo.fr>
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
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

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#define SPECIFIC_CMDLIST \
    {"outtime", (Tcl_CmdProc *) cmdK2OutTime}, \
    {"abl", (Tcl_CmdProc *) cmdK2SetAntiBlooming}, \
    {"sx28version", (Tcl_CmdProc *) cmdK2SX28Version}, \
    {"sx28test", (Tcl_CmdProc *) cmdK2SX28Test}, \
    {"testdg642", (Tcl_CmdProc *) cmdK2TestDG642}, \
    {"testfifo1", (Tcl_CmdProc *) cmdK2TestFifo1}, \
    {"testfifo2", (Tcl_CmdProc *) cmdK2TestFifo2},

 /* === Specific commands for that camera === */
int cmdK2OutTime(ClientData clientData, Tcl_Interp * interp, int argc,
		 char *argv[]);
int cmdK2SetAntiBlooming(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[]);
int cmdK2SX28Version(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[]);
int cmdK2SX28Test(ClientData clientData, Tcl_Interp * interp, int argc,
		  char *argv[]);
int cmdK2TestDG642(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);
int cmdK2TestFifo1(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);
int cmdK2TestFifo2(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);

#endif
