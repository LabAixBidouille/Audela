/* teltcl.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "telescop.h"
#include <libtel/libtel.h>
#include "teltcl.h"
#include <libtel/util.h>


/*
 *   structure pour les fonctions étendues
 */


int cmdTelAppCoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[200];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
	sprintf(s,"::thread::send %s { CmdThread940_appcoord }",tel->loopThreadId);
	mytel_tcleval(tel,s);
	return TCL_OK;
}

int cmdTelAction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   if (argc<2) {
   	sprintf(ligne,"usage: %s %s action",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (argc==2) {
		sprintf(ligne,"%s %d",telthread->action_cur,telthread->compteur);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	} else {
		strcpy(telthread->action_next,argv[2]);
		Tcl_SetResult(interp,telthread->action_next,TCL_VOLATILE);
	}
	return TCL_OK;
}

