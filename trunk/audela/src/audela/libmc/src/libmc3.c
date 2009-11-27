/* libmc3.c
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

#include "libmc.h"

int Cmd_mctcl_scheduler(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
/*
mc_scheduler now {GPS 5 E 43 1230}
*/
/****************************************************************************/
{
	double jd,longmpc, rhocosphip, rhosinphip;
	char s[1024];

   if(argc<3) {
      sprintf(s,"Usage: %s Date Home Horizon", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode la date ---*/
	  	mctcl_decode_date(interp,argv[1],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
		/* --- appel aux calculs ---*/
      mctcl_decode_topo(interp,argv[2],&longmpc,&rhocosphip,&rhosinphip);
		mc_scheduler1(jd,longmpc,rhocosphip,rhosinphip);
	}
	return TCL_OK;
}

