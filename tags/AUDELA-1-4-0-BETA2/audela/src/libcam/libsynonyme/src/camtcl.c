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
 * camtcl.c
 *
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 *
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


int cmdSynonymeOutTime(ClientData clientData, Tcl_Interp * interp,
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
	    synonyme_test_out(cam, nb_out);
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
