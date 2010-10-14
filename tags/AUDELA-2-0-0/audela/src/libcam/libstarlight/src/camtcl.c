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

extern struct camini CAM_INI[];

/*
 * -----------------------------------------------------------------------------
 *  cmdCamAccelerator()
 *
 * Setect if the camera is linked through an accelerator
 *
 * -----------------------------------------------------------------------------
 */
int cmdStarlightAccelerator(ClientData clientData, Tcl_Interp * interp,
			    int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (strcmp(argv[2], "0") == 0) {
	    cam->accelerator = 0;
	    pb = 0;
	} else if (strcmp(argv[2], "1") == 0) {
	    cam->accelerator = 1;
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s 0|1", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	sprintf(ligne, "%d", cam->accelerator);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}


int cmdStarlightOutTime(ClientData clientData, Tcl_Interp * interp,
			int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdCamOutTime()
 *
 * Compute the delay for an 'out' instruction for parallel port
 *
 * -----------------------------------------------------------------------------
 */
{
    char ligne[100];
    int retour = TCL_OK;
    struct camprop *cam;
    unsigned long billion;
    int date1, date2;
    double tout;
    unsigned long nb_out;

    if (argc <= 2) {
	sprintf(ligne, "Usage %s %s ?billion_out?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	billion = 1000000;
	if (strcmp(argv[2], "?") == 0) {
	    nb_out = 10 * billion;
	} else {
	    nb_out = (unsigned long) (atof(argv[2]) * billion);
	    if (nb_out <= (unsigned long) 0) {
		nb_out = (unsigned long) 1;
	    }
	}
	cam = (struct camprop *) clientData;
	Tcl_Eval(interp, "clock seconds");
	date1 = atoi(interp->result);
	if (cam->authorized == 1) {
	    starlight_cam_test_out(cam, nb_out);
	}
	Tcl_Eval(interp, "clock seconds");
	date2 = atoi(interp->result);
	tout = (double) (date2 - date1) / (double) nb_out *1.e6;
	sprintf(ligne, "%f", tout);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_OK;
    }
    return retour;
}

int cmdStarlightTimescale(ClientData clientData, Tcl_Interp * interp,
			  int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdCamTimescale()
 *
 * Time scaling factor of synchronizations between the PC and the camera
 *
 * -----------------------------------------------------------------------------
 */
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (argc >= 3) {
	    if (strcmp(argv[2], "") != 0) {
		cam->timescale = fabs(atof(argv[2]));
		starlight_timetest(cam);
	    }
	}
	pb = 0;
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ?timescale?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	sprintf(ligne, "%f", cam->timescale);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}
