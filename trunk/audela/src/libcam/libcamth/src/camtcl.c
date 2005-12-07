/* camtcl.c
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

/*
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

/* video : default digitalzation mode */
/* reset : digitalize only the reset level */
char *cam_nummode[] = {
   "video",
   "reset",
   NULL
};

extern struct camini CAM_INI[];

/*
 * -----------------------------------------------------------------------------
 *  cmdCamthDigitmode()
 *
 * Setect the mode of digitalization
 *
 * -----------------------------------------------------------------------------
 */
int cmdCamthDigitmode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
		pb=1;
   } else if(argc==2) {
		pb=0;
   } else {
	   if (strcmp(argv[2],cam_nummode[0])==0) {
			cam->nummode=0;
			pb=0;
		} else if (strcmp(argv[2],cam_nummode[1])==0) {
			cam->nummode=1;
			pb=0;
      } else {
			pb=1;
		}
	}
	if (pb==1) {
      sprintf(ligne,"Usage: %s %s %s|%s",argv[0],argv[1],cam_nummode[0],cam_nummode[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
	} else {
	   strcpy(ligne,"");
      sprintf(ligne,"%s",cam_nummode[cam->nummode]);
       Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdCamthTimescale(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdCamthTimescale()
 *
 * Time scaling factor of synchronizations between the PC and the camera
 *
 * -----------------------------------------------------------------------------
 */
{
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      if (argc>=3) {
         if (strcmp(argv[2],"")!=0) {
            cam->timescale=fabs(atof(argv[2]));
         }
      }
      pb=0;
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?timescale?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
       sprintf(ligne,"%f",cam->timescale);
       Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

