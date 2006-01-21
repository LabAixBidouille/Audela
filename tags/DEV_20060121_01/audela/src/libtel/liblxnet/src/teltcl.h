/* teltcl.h
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
 * Fonctions C-Tcl specifiques a ce telescope. A programmer.
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2005/02/12 22:04:53  Administrateur
 * *** empty log message ***
 *
 * Revision 1.2  2003-12-27 16:30:22+01  michel
 * ajout cmdHost et cmdSetIP
 *
 * Revision 1.1  2003-04-25 13:40:02+02  michel
 * ajouter cmdTelAutoFlush
 *
 * Revision 1.0  2002-06-28 23:25:42+02  michel
 * initial revision
 *
 */

#ifndef __TELTCL_H__
#define __TELTCL_H__

/* ----- defines specifiques aux fonctions de cette camera ----*/
int cmdTelLongFormat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelAutoFlush(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int cmdTelHost(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSetIP(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif
