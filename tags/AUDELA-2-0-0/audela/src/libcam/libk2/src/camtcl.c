/* camtcl.c
 * 
 * Copyright (C) 2004 Sylvain GIRARD <sly.girard@wanadoo.fr>
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
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
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

/*
 * -----------------------------------------------------------------------------
 *  cmdK2OutTime()
 *
 * Compute the delay for an 'out' instruction for parallel port
 *
 * -----------------------------------------------------------------------------
 */
int cmdK2OutTime(ClientData clientData, Tcl_Interp * interp, int argc,
		 char *argv[])
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
	    k2_test_out(cam, nb_out);
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

/*
 * -----------------------------------------------------------------------------
 *  cmdK2SetAntiBlooming()
 *
 * Return the SX28 software version of the microcontroler
 *
 * -----------------------------------------------------------------------------
 */
int cmdK2SetAntiBlooming(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    Tcl_SetResult(interp, k2_SetABL(cam, argc, argv), TCL_VOLATILE);
    return TCL_OK;
}
/*
 * -----------------------------------------------------------------------------
 *  cmdK2SX28Version()
 *
 * Return the SX28 software version of the microcontroler
 *
 * -----------------------------------------------------------------------------
 */
int cmdK2SX28Version(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    Tcl_SetResult(interp, k2_Version(cam), TCL_VOLATILE);
    return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdK2SX28Test()
 *
 * Make the led on the interface blinking.
 *
 * -----------------------------------------------------------------------------
 */
int cmdK2SX28Test(ClientData clientData, Tcl_Interp * interp, int argc,
		  char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    k2_TestSX28(cam);
    Tcl_SetResult(interp, "Check the LED", TCL_VOLATILE);
    return TCL_OK;
}

int cmdK2TestDG642(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    k2_TestDG642(cam);
    Tcl_SetResult(interp, "OK", TCL_VOLATILE);
    return TCL_OK;
}

int cmdK2TestFifo1(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    Tcl_SetResult(interp, k2_TestFifo(cam, 0), TCL_VOLATILE);
    return TCL_OK;
}

int cmdK2TestFifo2(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    Tcl_SetResult(interp, k2_TestFifo(cam, 0xFF), TCL_VOLATILE);
    return TCL_OK;
}
