/* camtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>


extern struct camini CAM_INI[];


int cmdHisisOutTime(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdHisisOutTime()
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
	    hisis_test_out(cam, nb_out);
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


int cmdHisisDelayLoops(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdHisisDelayLoops()
 *
 * Delay of synchronizations between the PC and the camera
 *
 * -----------------------------------------------------------------------------
 */
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3) && (argc != 4) && (argc != 5)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (argc >= 3) {
	    if (strcmp(argv[2], "") != 0) {
		cam->hisis22_paramloops = (int) fabs(atoi(argv[2]));
	    }
	}
	if (argc >= 4) {
	    if (strcmp(argv[2], "") != 0) {
		cam->hisis22_14_synchroloops = (int) fabs(atoi(argv[3]));
	    }
	}
	if (argc >= 5) {
	    if (strcmp(argv[2], "") != 0) {
		cam->hisis22_14_readloops = (int) fabs(atoi(argv[4]));
		cam->hisis22_12_readloops = cam->hisis22_14_readloops;
	    }
	}
	pb = 0;
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ?param? ?synchro? ?read?", argv[0],
		argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	sprintf(ligne, "%d %d %d", cam->hisis22_paramloops,
		cam->hisis22_14_synchroloops, cam->hisis22_14_readloops);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}


/*
 * @COMMAND@
 * cam? register address [data]
 * @DESCRIPTION@
 */
int cmdHisisRegister(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    int res, address;
    int data;
    int tcl_return = TCL_OK;

    cam = (struct camprop *) clientData;
    if (argc == 3) {		/* Lecture registre HISIS24 */
	tcl_return = Tcl_GetInt(interp, argv[2], &address);
	if (tcl_return != TCL_OK)
	    return tcl_return;
	hisis24_readpar(cam, &data, 0, address, &res);
	sprintf(ligne, "res=%d, addr=%d(0x%02X) => data=%d(0x%02X)", res,
		address, address, data, data);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	tcl_return = TCL_OK;
    } else if (argc == 4) {	/* Ecriture registre HISIS24 */
	tcl_return = Tcl_GetInt(interp, argv[2], &address);
	if (tcl_return != TCL_OK)
	    return tcl_return;
	tcl_return = Tcl_GetInt(interp, argv[3], &data);
	if (tcl_return != TCL_OK)
	    return tcl_return;
	if (address < 127)
	    hisis24_writeverparam(cam, address, data, &res);
	else
	    hisis24_writevercom(cam, address, data, &res);
    	sprintf(ligne, "res=%lu, addr=%d(0x%02X) <= data=%d(0x%02X)", res,
		address, address, data, data);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	tcl_return = TCL_OK;
    }
    return tcl_return;
}


/*
 * @COMMAND@
 * cam? bell [on|off]
 * @DESCRIPTION@
 */
int cmdHisisBell(ClientData clientData, Tcl_Interp * interp, int argc,
		 char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    int res;
    int tcl_return = TCL_OK;

    cam = (struct camprop *) clientData;
    if (argc == 2) {
	goto usage;
    } else if (argc == 3) {
	if (strcmp(argv[2], "on") == 0) {
	    res = hisis24_bell(cam, 1);
	    if (res) {
		sprintf(ligne, "%d", res);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		tcl_return = TCL_ERROR;
	    }
	} else if (strcmp(argv[2], "off") == 0) {
	    res = hisis24_bell(cam, 0);
	    if (res) {
		sprintf(ligne, "%d", res);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		tcl_return = TCL_ERROR;
	    }
	} else {
	    goto usage;
	}
    } else {
	goto usage;
    }

    return tcl_return;

  usage:
    sprintf(ligne, "%s %s on|off", argv[0], argv[1]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_ERROR;
}

/*
 * @COMMAND@
 * cam? fan [on|off] [0..127]
 * @DESCRIPTION@
 */
int cmdHisisFan(ClientData clientData, Tcl_Interp * interp, int argc,
		char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    int res, data;
    int tcl_return = TCL_OK;

    cam = (struct camprop *) clientData;
    if (argc == 2) {
	sprintf(ligne, "{%s %d}",
		cam->hisis24_fan.fanmode.on == 1 ? "on" : "off",
		cam->hisis24_fan.fanmode.pwr);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else if (argc == 3) {	/* Lecture registre HISIS24 */
	if (strcmp(argv[2], "on") == 0) {
	    res = hisis24_fan(cam, 1, -1);
	    if (res) {
		sprintf(ligne, "%d", res);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		tcl_return = TCL_ERROR;
	    }
	} else if (strcmp(argv[2], "off") == 0) {
	    res = hisis24_fan(cam, 0, -1);
	    if (res) {
		sprintf(ligne, "%d", res);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		tcl_return = TCL_ERROR;
	    }
	} else {
	    goto usage;
	}
    } else if (argc == 4) {
	if (strcmp(argv[2], "on") == 0) {
	    res = Tcl_GetInt(interp, argv[3], &data);
	    if (res != TCL_OK)
		return res;
	    res = hisis24_fan(cam, 1, data);
	    if (res) {
		sprintf(ligne, "%d", res);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		tcl_return = TCL_ERROR;
	    }
	} else {
	    goto usage;
	}
    } else {
	goto usage;
    }

    return tcl_return;

  usage:
    sprintf(ligne, "%s %s [on|off] [pwr=0..127]", argv[0], argv[1]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_ERROR;
}

/*
 * @COMMAND@
 * cam? filterwheel [enable|disable|filter=1..6]
 * @DESCRIPTION@
 * Si un nombre est passe en parametre, alors la roue a filtres est positionnee
 * sur ce filtre.
 * Sans parametre, cette commande renvoie soit le filtre actuellement selectionne
 * si la roue a filtres est activee, sinon elle renvoie disable.
 */
#if 1
int cmdHisisFilterWheel(ClientData clientData, Tcl_Interp * interp,
			int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    int res;
    int data;
    int tcl_return = TCL_OK;

    cam = (struct camprop *) clientData;
    if (argc == 2) {
	res = hisis24_filterwheel(cam, -1, -1, &data);
	sprintf(ligne, "{%s %d}", ((data & 8) != 0) ? "enable" : "disable",
		data & 7);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else if (argc == 3) {
	if (strcmp(argv[2], "enable") == 0) {
	    res = hisis24_filterwheel(cam, 1, -1, NULL);
	    switch (res) {
	    case HISIS24_DRV_FW_NO_FW:
		sprintf(ligne, "no filterwheel %d", res);
		tcl_return = TCL_ERROR;
		break;
	    case HISIS24_DRV_OK:
		sprintf(ligne, "enable");
		tcl_return = TCL_OK;
		break;
	    default:
		sprintf(ligne, "%d", res);
		tcl_return = TCL_ERROR;
	    }
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	} else if (strcmp(argv[2], "disable") == 0) {
	    res = hisis24_filterwheel(cam, 0, -1, NULL);
	    switch (res) {
	    case HISIS24_DRV_FW_NO_FW:
		sprintf(ligne, "no filterwheel %d", res);
		tcl_return = TCL_ERROR;
		break;
	    case HISIS24_DRV_OK:
		sprintf(ligne, "disable");
		tcl_return = TCL_OK;
		break;
	    default:
		sprintf(ligne, "%d", res);
		tcl_return = TCL_ERROR;
	    }
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	} else {
	    res = Tcl_GetInt(interp, argv[2], &data);
	    if (res != TCL_OK)
		return res;
	    res = hisis24_filterwheel(cam, 1, data, NULL);
	    switch (res) {
	    case HISIS24_DRV_FW_NO_FW:
		sprintf(ligne, "no filterwheel %d", res);
		tcl_return = TCL_ERROR;
		break;
	    case HISIS24_DRV_OK:
		sprintf(ligne, "%s", argv[2]);
		tcl_return = TCL_OK;
		break;
	    default:
		sprintf(ligne, "%d", res);
		tcl_return = TCL_ERROR;
	    }
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
    } else {
	goto usage;
    }

    return tcl_return;

  usage:
    sprintf(ligne, "%s %s [enable|disable|filter=1..6]", argv[0], argv[1]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_ERROR;
}
#endif

/*
 * @COMMAND@
 * cam? shutterdelay [0..63]
 * @DESCRIPTION@
 * Si un nombre est passe en parametre, il s'agit du nombre de millisecondes
 * qu'il doit s'ecouler entre l'emission de la fermeture de l'obturateur, et
 * le debut de la numerisation de l'image CCD.
 * Si aucun parametre n'est fourni, la commande renvoie la valeur actuelle.
 */
int cmdHisisShutterDelay(ClientData clientData, Tcl_Interp * interp,
			 int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    int res, data;
    int tcl_return = TCL_OK;

    cam = (struct camprop *) clientData;
    if (argc == 2) {
	sprintf(ligne, "%d", cam->hisis24_shutter.shuttermode.delay);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else if (argc == 3) {
	res = Tcl_GetInt(interp, argv[2], &data);
	if (res != TCL_OK)
	    return res;
	res = hisis24_shutter(cam, -1, -1, data);
	switch (res) {
	case HISIS24_DRV_SHUTTER_EXCEED_DELAY:
	    sprintf(ligne, "Shutter delay must be in [%d...%d] ms",
		    HISIS24_SHUTTER_DLYMIN, HISIS24_SHUTTER_DLYMAX);
	    tcl_return = TCL_ERROR;
	    break;
	case HISIS24_DRV_OK:
	    *ligne = 0;
	    break;
	default:
	    sprintf(ligne, "%d", res);
	    tcl_return = TCL_ERROR;
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	goto usage;
    }

    return tcl_return;

  usage:
    sprintf(ligne, "%s %s [0..63]", argv[0], argv[1]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_ERROR;
}

int cmdHisisReset(ClientData clientData, Tcl_Interp * interp, int argc,
		  char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    hisis24_resetall(cam);
    return TCL_OK;
}

int cmdHisisStatus(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
{
    struct camprop *cam;
    char s[32];
    int status;
    int result = TCL_OK;

    cam = (struct camprop *) clientData;
    status = hisis24_readstatus(cam);
    switch (status) {
    case HISIS24_STATUS_IDLE:
	sprintf(s, "idle");
	break;
    case HISIS24_STATUS_PAUSE:
	sprintf(s, "pause");
	break;
    case HISIS24_STATUS_CLEANCCD:
	sprintf(s, "clean ccd");
	break;
    case HISIS24_STATUS_EXPOSURE:
	sprintf(s, "exposure");
	break;
    case HISIS24_STATUS_DIGITIZE:
	sprintf(s, "digitize");
	break;
    case HISIS24_STATUS_CMD1:
	sprintf(s, "cmd1");
	break;
    case HISIS24_STATUS_CMD2:
	sprintf(s, "cmd2");
	break;
    case HISIS24_STATUS_CMD3:
	sprintf(s, "cmd3");
	break;
    default:
	sprintf(s, "Bad status value (%d)", status);
    }
    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return result;
}

int cmdHisisGainAmpli(ClientData clientData, Tcl_Interp * interp, int argc,
		      char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    int res;
    double data;
    int tcl_return = TCL_OK;

    cam = (struct camprop *) clientData;
    if (argc == 2) {
	sprintf(ligne, "%f", hisis24_gain(cam));
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else if (argc == 3) {
	res = Tcl_GetDouble(interp, argv[2], &data);
	if (res != TCL_OK)
	    return res;
	res = hisis24_gainampli(cam, (float) data);
	switch (res) {
	case HISIS24_DRV_OK:
	    sprintf(ligne, "%f", (float) hisis24_gain(cam));
	    break;
	case HISIS24_DRV_PB_OUTBOUND_PARAM:
	    sprintf(ligne, "Gain must be in [%f...%f] ms",
		    HISIS24_GAIN_MIN, HISIS24_GAIN_MAX);
	    tcl_return = TCL_ERROR;
	    break;
	default:
	    sprintf(ligne, "%d", res);
	    tcl_return = TCL_ERROR;
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	goto usage;
    }

    return tcl_return;

  usage:
    sprintf(ligne, "%s %s [1..8]", argv[0], argv[1]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_ERROR;
}

int cmdHisisNbVidage(ClientData clientData, Tcl_Interp * interp, int argc,
		      char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   int tcl_return = TCL_OK;
   
   cam = (struct camprop *) clientData;
   if (argc == 2) {
      sprintf(ligne, "%d", cam->nb_vidages);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      tcl_return = TCL_OK;
   } else if (argc == 3) {
      tcl_return = Tcl_GetInt(interp, argv[2], &cam->nb_vidages);
      // je retoune la valeur, quelle soit modifiee ou pas
      sprintf(ligne, "%d", cam->nb_vidages);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      sprintf(ligne, "%s %s ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      tcl_return = TCL_ERROR;
   }   
   return tcl_return;
}
