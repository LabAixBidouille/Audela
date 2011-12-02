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

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */


/* ----- defines specifiques aux fonctions de cette monture ----*/
int cmdTelPut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelRead(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelPutread(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelInit(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelPosition(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSpeedslew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSpeedtrack(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelLst(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTolPos(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSimultaneus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelDeadDelaySlew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelRot0(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif
