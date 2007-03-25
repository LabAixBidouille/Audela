/* telcmd.h
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
 * $Id: telcmd.h,v 1.2 2006-02-05 10:27:21 michelpujol Exp $
 */

static struct cmditem cmdlist[] = {
   /* === Common commands for all telescopes ===*/
   COMMON_CMDLIST
   /* === Specific commands for that telescope ===*/
   {"longformat", (Tcl_CmdProc *)cmdTelLongFormat},\
   {"tempo", (Tcl_CmdProc *)cmdTelTempo},\
   {"autoflush", (Tcl_CmdProc *)cmdTelAutoFlush},\
   {"host", (Tcl_CmdProc *)cmdTelHost},\
   {"setip", (Tcl_CmdProc *)cmdTelSetIP},\
   /* === Last function terminated by NULL pointers ===*/
   {NULL, NULL}
};
