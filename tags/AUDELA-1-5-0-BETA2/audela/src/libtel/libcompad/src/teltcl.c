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

int cmdTelInterrupt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0,k=0,choix=1;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc<2)||(argc>4)) {
		pb=1;
   } else if(argc==2) {
		pb=0;
   } else {
      k=0;
		pb=1;
		choix=atoi(argv[2]);
		if (choix==0) { tel->interrupt=0; pb=0; tel->authorized=1; }
		if (choix==1) { tel->interrupt=1; pb=0; tel->authorized=1; }
	}
	if (pb==1) {
      sprintf(ligne,"Usage: %s %s ",argv[0],argv[1]);
	   strcat(ligne," 0|1");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
	} else {
		sprintf(ligne,"%d",tel->interrupt);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}
