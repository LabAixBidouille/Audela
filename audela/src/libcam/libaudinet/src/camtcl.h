/* camtcl.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2005/02/12 22:04:17  Administrateur
 * *** empty log message ***
 *
 * Revision 1.7  2003-12-05 00:56:48+01  michel
 * suppression cmdCamStartCont
 *
 * Revision 1.6  2003-06-06 15:53:49+02  michel
 * ajout cmdSetIP
 *
 * Revision 1.5  2003-04-25 13:50:29+02  michel
 * add cmdCamScan, cmdCamBreakScan
 * add  cmdCamStartCont, cmdCamStopCont
 * add cmdCamWipe, cmdCamRead,cmdCamScanLoop
 *
 * Revision 1.4  2003-03-26 11:46:11+01  michel
 * ajouter startScan(), scanReadLine()
 *
 * Revision 1.1  2002-09-27 18:33:44+02  michel
 * ajoute cmdCamShutterType()
 *
 * Revision 1.0  2001-12-10 15:17:40+01  michel
 * initial revision
 *
 */

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#define SPECIFIC_CMDLIST \
   {"scan", (Tcl_CmdProc *)cmdAudinetScan}, \
   {"breakscan", (Tcl_CmdProc *)cmdAudinetBreakScan}, \
   {"scanloop", (Tcl_CmdProc *)cmdAudinetScanLoop}, \
   {"shuttertype", (Tcl_CmdProc *)cmdAudinetShutterType}, \
   {"host", (Tcl_CmdProc *)cmdAudinetHost}, \
   {"wipe", (Tcl_CmdProc *)cmdAudinetWipe}, \
   {"read", (Tcl_CmdProc *)cmdAudinetRead}, \
   {"setip", (Tcl_CmdProc *)cmdAudinetSetIP},

// === Specific commands for that camera ===

//configure
int cmdAudinetHost(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);
int cmdAudinetShutterType(ClientData clientData, Tcl_Interp * interp,
			  int argc, char *argv[]);
int cmdAudinetSetIP(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);

//scan mode
int cmdAudinetScan(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);
int cmdAudinetBreakScan(ClientData clientData, Tcl_Interp * interp,
			int argc, char *argv[]);
int cmdAudinetScanLoop(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);

//other mode
int cmdAudinetRead(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);
int cmdAudinetWipe(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);


#endif
