/* teltcl.h
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

#ifndef __TELTCL_H__
#define __TELTCL_H__

/* ----- defines specifiques aux fonctions de cette camera ----*/
int cmdTelStatus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelHoming(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTest(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTargetPosition(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelGetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTypeMount(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTypeAxis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelIncAxis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif
