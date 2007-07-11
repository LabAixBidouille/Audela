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
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

extern struct camini CAM_INI[];


/*
 *  Definition a structure specific for this driver
 *  (see declaration in camera.h)
 */

static char *cam_ANtypes[] = {
    "AN2",
    "AN5",
    NULL
};

static char *cam_canbitstypes[] = {
    "12",
    "8",
    NULL
};


int cmdKittyOutTime(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdKittyOutTime()
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
	    kitty_test_out(cam, nb_out);
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

int cmdKittySX28Version(ClientData clientData, Tcl_Interp * interp,
			int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdKittySX28Version()
 *
 * Return the SX28 software version of the microcontraler
 *
 * -----------------------------------------------------------------------------
 */
{
    /*char ligne[100]; */
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    Tcl_SetResult(interp, kitty_Version(cam), TCL_VOLATILE);
    return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdKittyAD7893()
 *
 * Setect the type of AD7893 for temperature measurement. 2 types are supported :
 *  AN2 : (0-2V)
 *  AN5 : (0-5V)
 *
 * -----------------------------------------------------------------------------
 */
int cmdKittyAD7893(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
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
	if (strcmp(argv[2], cam_ANtypes[0]) == 0) {
	    cam->ad7893index = 0;
	    pb = 0;
	} else if (strcmp(argv[2], cam_ANtypes[1]) == 0) {
	    cam->ad7893index = 1;
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s %s|%s", argv[0], argv[1],
		cam_ANtypes[0], cam_ANtypes[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, cam_ANtypes[cam->ad7893index]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdKittyCanBits()
 *
 * Setect the type of CAN. 2 types are supported :
 *  12 : 12 bits
 *   8 : 8 bits
 *
 * -----------------------------------------------------------------------------
 */
int cmdKittyCanBits(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
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
	if (strcmp(argv[2], cam_canbitstypes[0]) == 0) {
	    // CAN 12 bits
	    cam->canbitsindex = 0;
	    CAM_INI[cam->index_cam].maxconvert = 4095;
	    pb = 0;
	} else if (strcmp(argv[2], cam_canbitstypes[1]) == 0) {
	    // CAN 8 bits
	    cam->canbitsindex = 1;
	    CAM_INI[cam->index_cam].maxconvert = 255;
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s %s|%s", argv[0], argv[1],
		cam_canbitstypes[0], cam_canbitstypes[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, cam_canbitstypes[cam->canbitsindex]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}
