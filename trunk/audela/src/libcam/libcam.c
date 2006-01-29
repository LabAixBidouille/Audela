/* libcam.c
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

/*
 * $Id: libcam.c,v 1.3 2006-01-29 18:32:02 michelpujol Exp $
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#if defined(_MSC_VER)
#include <sys/timeb.h>
#include <time.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "camera.h"

#include <libcam/libcam.h>
#include "camtcl.h"


extern struct cam_drv_t CAM_DRV;


/* valeurs des structures cam_* privees */
char *cam_shutters[] = {
    "closed",
    "synchro",
    "opened",
    NULL
};

char *cam_rgbs[] = {
    "none",
    "cfa",
    "rgb",
    "gbr",
    "brg",
    NULL
};

char *cam_coolers[] = {
    "off",
    "on",
    "check",
    NULL
};

char *cam_ports[] = {
    "lpt1",
    "lpt2",
    NULL
};

char *cam_overscans[] = {
    "off",
    "on",
    NULL
};

extern struct camini CAM_INI[];

#if !defined(OS_WIN)
#define MB_OK 1
void MessageBox(void *handle, char *msg, char *title, int bof)
{
    fprintf(stderr, "%s: %s\n", title, msg);
}
#endif

#define BP(i) MessageBox(NULL,#i,"Libcam",MB_OK)


/*
 * Prototypes des differentes fonctions d'interface Tcl/Driver. Ajoutez les
 * votres ici.
 */
/* === Common commands for all cameras ===*/
static int cmdCamCreate(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCam(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

/* --- Information commands ---*/
static int cmdCamDrivername(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamNbcells(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamNbpix(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamCelldim(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamPixdim(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamMaxdyn(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamFillfactor(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamRgb(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamInfo(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamPort(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamTimer(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamGain(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamReadnoise(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamTemperature(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamMirrorH(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamMirrorV(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

/* --- Action commands ---*/
static int cmdCamName(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamModel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamCcd(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamBin(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamExptime(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamBuf(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamWindow(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamTel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamStop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamShutter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamCooler(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamFoclen(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamOverscan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamInterrupt(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

static int cam_init_common(struct camprop *cam, int argc, char **argv);


static struct cmditem cmdlist[] = {
    /* === Common commands for all cameras === */
    COMMON_CMDLIST
	/* === Specific commands for that camera === */
	SPECIFIC_CMDLIST
	/* === Last function terminated by NULL pointers === */
    {NULL, NULL}
};

static struct camprop *camprops = NULL;

#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4

static int debug_level = 4;

static void libcam_log(int level, const char *fmt, ...)
{
    va_list mkr;
    va_start(mkr, fmt);
    if (level <= debug_level) {
	switch (level) {
	case LOG_ERROR:
	    printf("%s(%s) <ERROR> : ", CAM_LIBNAME, CAM_LIBVER);
	    break;
	case LOG_WARNING:
	    printf("%s(%s) <WARNING> : ", CAM_LIBNAME, CAM_LIBVER);
	    break;
	case LOG_INFO:
	    printf("%s(%s) <INFO> : ", CAM_LIBNAME, CAM_LIBVER);
	    break;
	case LOG_DEBUG:
	    printf("%s(%s) <DEBUG> : ", CAM_LIBNAME, CAM_LIBVER);
	    break;
	}
	vprintf(fmt, mkr);
	printf("\n");
	va_end(mkr);
    }
}




/*
 * Point d'entree de la librairie, appelle lors de la commande Tcl load.
 */
#if defined(OS_WIN)
int __cdecl CAM_ENTRYPOINT(Tcl_Interp * interp)
#else
int CAM_ENTRYPOINT(Tcl_Interp * interp)
#endif
{
    char s[256];
    struct cmditem *cmd;
    int i;

    libcam_log(LOG_INFO, "Calling entrypoint for driver %s", CAM_DRIVNAME);

    if (Tcl_InitStubs(interp, "8.3", 0) == NULL) {
	Tcl_SetResult(interp, "Tcl Stubs initialization failed in " CAM_LIBNAME " (" CAM_LIBVER ").", TCL_VOLATILE);
	libcam_log(LOG_ERROR, "Tcl Stubs initialization failed.");
	return TCL_ERROR;
    }

    libcam_log(LOG_DEBUG, "cmdCamCreate = %p", cmdCamCreate);
    libcam_log(LOG_DEBUG, "cmdCam = %p", cmdCam);

    Tcl_CreateCommand(interp, CAM_DRIVNAME, (Tcl_CmdProc *) cmdCamCreate, NULL, NULL);
    Tcl_PkgProvide(interp, CAM_LIBNAME, CAM_LIBVER);

    for (i = 0, cmd = cmdlist; cmd->cmd != NULL; cmd++, i++);

#if defined(__BORLANDC__)
    sprintf(s, "Borland C (%s) ...nb commandes = %d", __DATE__, i);
#elif defined(OS_LIN)
    sprintf(s, "Linux (%s) ...nb commandes = %d", __DATE__, i);
#else
    sprintf(s, "VisualC (%s) ...nb commandes = %d", __DATE__, i);
#endif

    libcam_log(LOG_INFO, "Driver provides %d functions.", i);

    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamCreate(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char s[256];
    int camno, err, i;
    struct camprop *cam, *camm;

    if (argc < 3) {
	sprintf(s, "%s driver port ?options?", argv[0]);
	Tcl_SetResult(interp, s, TCL_VOLATILE);
	return TCL_ERROR;
    } else {
	/*
	 * On initialise la camera sur le port. S'il y a une erreur, alors on
	 * renvoie le message qui va bien, en supprimant la structure cree.
	 * Si OK, la commande TCL est creee d'apres l'argv[1], et on garde
	 * trace de la structure creee.
	 */
	fprintf(stderr, "%s(%s): CamCreate(argc=%d", CAM_LIBNAME, CAM_LIBVER, argc);
	for (i = 0; i < argc; i++) {
	    fprintf(stderr, ",argv[%d]=%s", i, argv[i]);
	}
	fprintf(stderr, ")\n");

	cam = (struct camprop *) calloc(1, sizeof(struct camprop));
	Tcl_Eval(interp, "set ::tcl_platform(os)");
	strcpy(s, interp->result);
	if ((strcmp(s, "Windows 95") == 0)
	    || (strcmp(s, "Windows 98") == 0)
	    || (strcmp(s, "Linux") == 0)) {
	    cam->authorized = 1;
	} else {
	    cam->authorized = 0;
	}
	cam->interp = interp;
	sscanf(argv[1], "cam%d", &camno);
	cam->camno = camno;
	strcpy(cam->msg, "");
	if ((err = cam_init_common(cam, argc, argv)) != 0) {
	    Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
	    free(cam);
	    return TCL_ERROR;
	}
	if ((err = CAM_DRV.init(cam, argc, argv)) != 0) {
	    Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
	    free(cam);
	    return TCL_ERROR;
	}
	cam->bufno = CAM_INI[0].numbuf;
	cam->telno = CAM_INI[0].numtel;
	cam->timerExpiration = NULL;
	camm = camprops;
	if (camm == NULL) {
	    camprops = cam;
	} else {
	    while (camm->next != NULL)
		camm = camm->next;
	    camm->next = cam;
	}
	Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdCam, (ClientData) cam, NULL);

	libcam_log(LOG_DEBUG, "cmdCamCreate: create camera data at %p\n", cam);

    }
    return TCL_OK;
}

static int cmdCam(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char s[1024], ss[50];
    int retour = TCL_OK, k, i;
    struct cmditem *cmd;

    fprintf(stderr, "%s(%s): enter cmdCam(argc=%d", CAM_LIBNAME, CAM_LIBVER, argc);
    for (i = 0; i < argc; i++) {
	fprintf(stderr, ",argv[%d]=%s", i, argv[i]);
    }
    fprintf(stderr, ")\n");

    if (argc == 1) {
	sprintf(s, "%s choose sub-command among ", argv[0]);
	k = 0;
	while (cmdlist[k].cmd != NULL) {
	    sprintf(ss, " %s", cmdlist[k].cmd);
	    strcat(s, ss);
	    k++;
	}
	Tcl_SetResult(interp, s, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	for (cmd = cmdlist; cmd->cmd != NULL; cmd++) {
	    if (strcmp(cmd->cmd, argv[1]) == 0) {
		retour = (*cmd->func) (clientData, interp, argc, argv);
		break;
	    }
	}
	if (cmd->cmd == NULL) {
	    sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
	    k = 0;
	    while (cmdlist[k].cmd != NULL) {
		sprintf(ss, " %s", cmdlist[k].cmd);
		strcat(s, ss);
		k++;
	    }
	    Tcl_SetResult(interp, s, TCL_VOLATILE);
	    retour = TCL_ERROR;
	}
    }
    return retour;
}


/*
 * GetCurrentFITSDate(char s[23])
 *
 */
void libcam_GetCurrentFITSDate(Tcl_Interp * interp, char *s)
{
    int clock = 0;
    char ligne[256];
#if defined(_Windows)
    /* cas special a Borland Builder pour avoir les millisecondes */
    struct time t1;
    struct date d1;
    clock = 1;
    getdate(&d1);
    gettime(&t1);
    sprintf(s, "%04d-%02d-%02dT%02d:%02d:%02d.%02d", d1.da_year, d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec, t1.ti_hund);
#endif
#if defined(_MSC_VER)
    /* cas special a Microsoft C++ pour avoir les millisecondes */
    struct _timeb timebuffer;
    char message[50];
    time_t ltime;
    clock = 1;
    _ftime(&timebuffer);
    time(&ltime);
    strftime(message, 45, "%Y-%m-%dT%H:%M:%S", localtime(&ltime));
    sprintf(s, "%s.%02d", message, (int) (timebuffer.millitm / 10));
#endif
    if (clock == 0) {
	strcpy(ligne, "clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.00\"");
	Tcl_Eval(interp, ligne);
	strcpy(s, interp->result);
    }
}


/*
 * GetCurrentFITSDate_variable(char s[23])
 *
 */
void libcam_GetCurrentFITSDate_function(Tcl_Interp * interp, char *s, char *function)
{
    /* --- conversion TSystem -> TU pour l'interface Aud'ACE par exemple --- */
    /*     (function = ::audace::date_sys2ut) */
    char ligne[1024];
    sprintf(ligne, "info commands  %s", function);
    Tcl_Eval(interp, ligne);
    if (strcmp(interp->result, function) == 0) {
       sprintf(ligne, "mc_date2iso8601 [%s now]", function);
       Tcl_Eval(interp, ligne);
       strcpy(s, interp->result);
    }
}

/*
 * libcam_get_tel_coord : lecture des coordonnes du telescope associe
 *
 * status=0 : les coordonnees on ete lues avec succes
 * status=1 : les coordonnees on ete lues avec erreur
 */
void libcam_get_tel_coord(Tcl_Interp * interp, double *ra, double *dec, struct camprop *cam, int *status)
{
    char s[200];
    int k, argcc;
    char **argvv = NULL;
    /* Try to read telescop coordinates (k!=-1 if telescop exists) */
    strcpy(s, "tel::list");
    Tcl_Eval(interp, s);
    *status = 1;
    k = -1;
    if (Tcl_SplitList(interp, interp->result, &argcc, &argvv) == TCL_OK) {
	if (argcc > 0) {
	    for (k = 0; k < argcc; k++) {
		if (atoi(argvv[k]) == cam->telno) {
		    break;
		}
	    }
	}
	if (k >= argcc) {
	    k = -1;
	}
	Tcl_Free((char *) argvv);
    }
    *ra = 0.;
    *dec = 0.;
    if (k != -1) {
	/* Read the coordinates */
	sprintf(s, "tel%d coord", cam->telno);
	Tcl_Eval(interp, s);
	*ra = 0.;
	*dec = 0.;
	if (Tcl_SplitList(interp, interp->result, &argcc, &argvv) == TCL_OK) {
	    if (argcc >= 2) {
		*status = 0;
		sprintf(s, "mc_angle2deg %s", argvv[0]);
		Tcl_Eval(interp, s);
		*ra = (double) atof(interp->result);
		sprintf(s, "mc_angle2deg %s 90", argvv[1]);
		Tcl_Eval(interp, s);
		*dec = (double) atof(interp->result);
	    }
	    Tcl_Free((char *) argvv);
	}
    }
}


static int cmdCamBin(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    char **listArgv;
    int listArgc;
    int i_binx, i_biny, result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?{binx biny}?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d %d", cam->binx, cam->biny);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
	    sprintf(ligne, "Binning struct not valid: must be {binx biny}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else if (listArgc != 2) {
	    sprintf(ligne, "Binning struct not valid: must be {binx biny}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    if (Tcl_GetInt(interp, listArgv[0], &i_binx) != TCL_OK) {
		sprintf(ligne, "Usage: %s %s {binx biny}\nbinx : must be an integer", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[1], &i_biny) != TCL_OK) {
		sprintf(ligne, "Usage: %s %s {binx biny}\nbiny : must be an integer", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else {
		cam = (struct camprop *) clientData;
		CAM_DRV.set_binning(i_binx, i_biny, cam);
		CAM_DRV.update_window(cam);
		sprintf(ligne, "%d %d", cam->binx, cam->biny);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    }
	    Tcl_Free((char *) listArgv);
	}
    }
    return result;
}

static int cmdCamExptime(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int retour = TCL_OK;
    char ligne[256];
    double d_exptime;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?exptime?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%.2f", cam->exptime);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_GetDouble(interp, argv[2], &d_exptime) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?num?\nnum = must be a float > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    cam->exptime = (float) d_exptime;
	    sprintf(ligne, "%.2f", cam->exptime);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
    }
    return retour;
}

static int cmdCamWindow(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    char **listArgv;
    int listArgc;
    int i_x1, i_y1, i_x2, i_y2;
    int result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?{x1 y1 x2 y2}?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d %d %d %d", cam->x1 + 1, cam->y1 + 1, cam->x2 + 1, cam->y2 + 1);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
	    sprintf(ligne, "Window struct not valid: must be {x1 y1 x2 y2}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else if (listArgc != 4) {
	    sprintf(ligne, "Window struct not valid: must be {x1 y1 x2 y2}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    if (Tcl_GetInt(interp, listArgv[0], &i_x1) != TCL_OK) {
		sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\nx1 : must be an integer", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[1], &i_y1) != TCL_OK) {
		sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\ny1 : must be an integer", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[2], &i_x2) != TCL_OK) {
		sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\nx2 : must be an integer", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[3], &i_y2) != TCL_OK) {
		sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\ny2 : must be an integer", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else {
		cam = (struct camprop *) clientData;
		cam->x1 = i_x1 - 1;
		cam->y1 = i_y1 - 1;
		cam->x2 = i_x2 - 1;
		cam->y2 = i_y2 - 1;
		CAM_DRV.update_window(cam);
		sprintf(ligne, "%d %d %d %d", cam->x1 + 1, cam->y1 + 1, cam->x2 + 1, cam->y2 + 1);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    }
	    Tcl_Free((char *) listArgv);
	}
    }
    return result;
}


/*
 * cmdCamBuf
 * Lecture/ecriture du numero de buffer associe a la camera.
 */
static int cmdCamBuf(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int i_bufno, result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?bufno?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d", cam->bufno);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_GetInt(interp, argv[2], &i_bufno) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?bufno?\nbufno : must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    cam->bufno = i_bufno;
	    sprintf(ligne, "%d", cam->bufno);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
    }
    return result;
}


/*
 * cmdCamTel
 * Lecture/ecriture du numero de telescope associe a la camera.
 */
static int cmdCamTel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int i_telno, result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?telno?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d", cam->telno);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_GetInt(interp, argv[2], &i_telno) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?telno?\ntelno : must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    cam->telno = i_telno;
	    sprintf(ligne, "%d", cam->telno);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
    }
    return result;
}


/*
 * AcqRead
 * Commande de lecture du CCD.
 */
static void AcqRead(ClientData clientData)
{
   char s[1000];
   //unsigned short *p;		/* cameras de 1 a 16 bits non signes */
   char *p;		/* cameras de 1 a 16 bits non signes */
   double ra, dec, exptime = 0.;
   int status;
   struct camprop *cam;
   Tcl_Interp *interp;
   
   cam = (struct camprop *) clientData;
   interp = cam->interp;
   

   // Information par defaut concernant l'image 
   // ATTENTION : la camera peut mettre a jour ces valeurs pendant l'execution de read_ccd()
   strcpy(cam->pixels_classe, "CLASS_GRAY");
   strcpy(cam->pixels_format, "FORMAT_SHORT");
   strcpy(cam->pixels_compression, "COMPRESS_NONE");
   cam->pixels_reverse_x = 0;
   cam->pixels_reverse_y = 0;
   cam->pixel_data = NULL;

   // allocation par defaut du buffer
   //p = (unsigned short *) calloc(cam->w * cam->h *4, sizeof(unsigned short));
   p = (char *) calloc(cam->w * cam->h *4, sizeof(unsigned short));
   
   libcam_GetCurrentFITSDate(interp, cam->date_end);
   libcam_GetCurrentFITSDate_function(interp, cam->date_end, "::audace::date_sys2ut");
   

   // set TCL global status_read_camNo
   sprintf(s, "status_read_cam%d", cam->camno);
   Tcl_SetVar(interp, s, "read", TCL_GLOBAL_ONLY);
   
   // reset message
   strcpy(cam->msg,"");

   //  capture 
   // TODO 2 : une autre solution serait de passer l'adresse de p comme ceci :
   // CAM_DRV.read_ccd(cam, &p); 
   // mais il faut modifier toutes les camera !! ( michel pujol)
   CAM_DRV.read_ccd(cam, (unsigned short *) p);
   
   
   // unset TCL global status_read_camNo
   sprintf(s, "status_read_cam%d", cam->camno);
   Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
   

   // si la taille alloue par defaut a p ne convient pas, la camera cr�e un nouveau buffer adress� par cam->pixels
   if(cam->pixel_data != NULL) {
      if ( (int) cam->pixel_data != -1 ) {
         // les pixels sont dans le buffer cam->pixel_data
         free( p);
         p =  cam->pixel_data;
      }
   }

   if (strlen(cam->msg) == 0) {
 
     
      // Ce test permet de savoir si le buffer existe
      sprintf(s, "buf%d bitpix", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         sprintf(s, "buf::create %d", cam->bufno);
         Tcl_Eval(interp, s);
      }
      
      // --- application du miroir horizontal
      if( cam->mirrorh == 1 ) {
         // j'inverse l'orientation de l'image par rapport � un miroir horizontal
         if( cam->pixels_reverse_y == 1 ) {
            cam->pixels_reverse_y = 0; 
         } else {
            cam->pixels_reverse_y = 1; 
         }
      }

      // --- application du miroir vertical
      if( cam->mirrorv == 1 ) {
         // j'inverse l'orientation de l'image par rapport � un miroir vertical
         if( cam->pixels_reverse_x == 1 ) {
            cam->pixels_reverse_x = 0; 
         } else {
            cam->pixels_reverse_x = 1; 
         }
      }
      
      //--- set pixels to buffer 
      sprintf(s, "buf%d setpixels %s %d %d %s %s %d -pixels_size %lu -reverse_x %d -reverse_y %d", 
         cam->bufno, cam->pixels_classe, cam->w, cam->h, cam->pixels_format, cam->pixels_compression ,
         (void *) p, cam->pixel_size, cam->pixels_reverse_x, cam->pixels_reverse_y);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         strcpy(s, interp->result);
      }
      
      //--- get height after decompression
      sprintf(s, "buf%d getpixelsheight", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_OK) {
         Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &cam->h);
      }   
      
      //--- get width after decompression
      sprintf(s, "buf%d getpixelswidth", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_OK) {
         Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &cam->w);
      }   

      
      //--- Add FITS keywords 
      if ( strcmp(cam->pixels_classe, "CLASS_GRAY")==0 ) {
         sprintf(s, "buf%d setkwd {NAXIS 2 int \"\" \"\"}", cam->bufno);
         Tcl_Eval(interp, s);
      } else if ( strcmp(cam->pixels_classe, "CLASS_RGB")==0 ) {
         sprintf(s, "buf%d setkwd {NAXIS 3 int \"\" \"\"}", cam->bufno);
         Tcl_Eval(interp, s);
         sprintf(s, "buf%d setkwd {NAXIS3 3 int \"\" \"\"}", cam->bufno);
         Tcl_Eval(interp, s);
      }
      sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, cam->w);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, cam->h);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, cam->binx);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, cam->biny);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {CAMERA \"%s %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
      Tcl_Eval(interp, s);
      if (cam->timerExpiration != NULL) {
         sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->timerExpiration->dateobs);
      } else {
         sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->date_obs);
      }
      Tcl_Eval(interp, s);
      if (cam->timerExpiration != NULL) {
         sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, cam->exptime);
      } else {
         sprintf(s, "expr (([mc_date2jd %s]-[mc_date2jd %s])*86400.)", cam->date_end, cam->date_obs);
         Tcl_Eval(interp, s);
         exptime = atof(interp->result);
         sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, exptime);
      }
      Tcl_Eval(interp, s);
      
      libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
      if (status == 0) {
         // Add FITS keywords 
         sprintf(s, "buf%d setkwd {RA %f float \"Right ascension telescope encoder\" \"\"}", cam->bufno, ra);
         Tcl_Eval(interp, s);
         sprintf(s, "buf%d setkwd {DEC %f float \"Declination telescope encoder\" \"\"}", cam->bufno, dec);
         Tcl_Eval(interp, s);
      }    
   } 
   
   free(p);

   if (cam->timerExpiration != NULL) {
      sprintf(s, "status_cam%d", cam->camno);
      Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
   }
   cam->clockbegin = 0;
   
   if (cam->timerExpiration != NULL) {
      free(cam->timerExpiration->dateobs);
      free(cam->timerExpiration);
      cam->timerExpiration = NULL;
   }
}


/*
 * cmdCamAcq()
 * Commande de demarrage d'une acquisition.
 */
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char *ligne;
    int i;
    struct camprop *cam;
    int result = TCL_OK;


    ligne = (char *) calloc(100, sizeof(char));
    if (argc != 2) {
       sprintf(ligne, "Usage: %s %s", argv[0], argv[1]);
       Tcl_SetResult(interp, ligne, TCL_VOLATILE);
       result = TCL_ERROR;
    } else {
       cam = (struct camprop *) clientData;
       if (cam->timerExpiration == NULL) {
          /* Pour avertir les gens du status de la camera. */
          sprintf(ligne, "status_cam%d", cam->camno);
          Tcl_SetVar(interp, ligne, "exp", TCL_GLOBAL_ONLY);
          
          i = (int) (1000 * cam->exptime);
          cam->timerExpiration = (struct TimerExpirationStruct *) calloc(1, sizeof(struct TimerExpirationStruct));
          cam->timerExpiration->clientData = clientData;
          cam->timerExpiration->interp = interp;
          cam->timerExpiration->dateobs = (char *) calloc(32, sizeof(char));
          CAM_DRV.start_exp(cam, "amplioff");
          Tcl_Eval(interp, "clock seconds");
          cam->clockbegin = (unsigned long) atoi(interp->result);
          /*
          cam->timerExpiration->datebegin=(int)atoi(interp->result);
          Tcl_Eval(interp,"clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.00\"");
          strcpy(cam->timerExpiration->dateobs,interp->result);
          */
          libcam_GetCurrentFITSDate(interp, cam->timerExpiration->dateobs);
          libcam_GetCurrentFITSDate_function(interp, cam->timerExpiration->dateobs, "::audace::date_sys2ut");
          /* Creation du timer pour realiser le temps de pose. */
          cam->timerExpiration->TimerToken = Tcl_CreateTimerHandler(i, AcqRead, (ClientData) cam);
       } else {
          sprintf(ligne, "Camera already in use");
          Tcl_SetResult(interp, ligne, TCL_VOLATILE);
          result = TCL_ERROR;
       }
    }
    return result;
}


/*
 * cmdCamStop()
 * Commande d'arret d'une acquisition.
 */
static int cmdCamStop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   struct camprop *cam;
   char s[100];
   int retour = TCL_OK;
   
   cam = (struct camprop *) clientData;
   if (cam->timerExpiration) {
      strcpy(cam->date_obs, cam->timerExpiration->dateobs);
      Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
      if (cam->timerExpiration != NULL) {
         free(cam->timerExpiration->dateobs);
         free(cam->timerExpiration);
         cam->timerExpiration = NULL;
      }
      CAM_DRV.stop_exp(cam);
      AcqRead((ClientData) cam);
      
   } else {
      Tcl_SetResult(interp, "No current exposure", TCL_VOLATILE);
      retour = TCL_ERROR;
   }
   
   sprintf(s, "status_cam%d", cam->camno);
   Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
   
   return retour;
}

static int cmdCamDrivername(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    sprintf(ligne, "%s {%s}", CAM_LIBNAME, __DATE__);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}


static int cmdCamName(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", CAM_INI[cam->index_cam].name);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamModel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", CAM_INI[cam->index_cam].model);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}


static int cmdCamCcd(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", CAM_INI[cam->index_cam].ccd);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamNbcells(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%d %d", cam->nb_photox, cam->nb_photoy);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamNbpix(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%d %d", cam->nb_photox / cam->binx, cam->nb_photoy / cam->biny);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamCelldim(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%g %g", cam->celldimx, cam->celldimy);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamPixdim(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%g %g", cam->celldimx * cam->binx, cam->celldimy * cam->biny);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamMaxdyn(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%f", CAM_INI[cam->index_cam].maxconvert);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamFillfactor(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%f", cam->fillfactor);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamInfo(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s %s %s", CAM_LIBNAME, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamPort(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", cam_ports[cam->portindex]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamTimer(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    /* --- renvoie le nombre de secondes ecoulees depuis le debut de pose --- */
    char ligne[256];
    struct camprop *cam;
    int sec, count;
    cam = (struct camprop *) clientData;
    count = 1;
    if (argc >= 3) {
	if (strcmp(argv[2], "-countdown") == 0) {
	    count = -1;
	}
	if (strcmp(argv[2], "-1") == 0) {
	    count = -1;
	}
    }
    if (cam->clockbegin != 0) {
	/*if(cam->timerExpiration!=NULL) { */
	Tcl_Eval(interp, "clock seconds");
	sec = (int) ((unsigned long) atol(interp->result) - cam->clockbegin);
	if (count == -1) {
	    sec = (int) (cam->exptime) - sec;
	}
	sprintf(ligne, "%d", sec);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	strcpy(ligne, "-1");
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return TCL_OK;
}

static int cmdCamGain(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%f", CAM_INI[cam->index_cam].gain);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamReadnoise(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%f", CAM_INI[cam->index_cam].readnoise);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamTemperature(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    CAM_DRV.measure_temperature(cam);
    sprintf(ligne, "%f", cam->temperature);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

static int cmdCamRgb(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", cam_rgbs[cam->rgbindex]);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

/* --- Action commands ---*/

static int cmdCamShutter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256], ligne2[50];
    int result = TCL_OK, pb = 0, k = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	k = 0;
	pb = 1;
	while (cam_shutters[k] != NULL) {
	    if (strcmp(argv[2], cam_shutters[k]) == 0) {
		cam->shutterindex = k;
		pb = 0;
		break;
	    }
	    k++;
	}
	if ((cam->shutterindex == 0) || (cam->shutterindex == 1)) {
	    CAM_DRV.shutter_off(cam);
	}
	if (cam->shutterindex == 2) {
	    CAM_DRV.shutter_on(cam);
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
	k = 0;
	while (cam_shutters[k] != NULL) {
	    sprintf(ligne2, "%s", cam_shutters[k]);
	    strcat(ligne, ligne2);
	    if (cam_shutters[++k] != NULL) {
		strcat(ligne, "|");
	    }
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	sprintf(ligne, "%s", cam_shutters[cam->shutterindex]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

static int cmdCamCooler(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256], ligne2[50];
    int result = TCL_OK, pb = 0, k = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc < 2) || (argc > 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	k = 0;
	pb = 1;
	while (cam_coolers[k] != NULL) {
	    if (strcmp(argv[2], cam_coolers[k]) == 0) {
		cam->coolerindex = k;
		pb = 0;
		break;
	    }
	    k++;
	}
	if (argc == 4) {
	    cam->check_temperature = atof(argv[3]);
	}
	if (cam->coolerindex == 0) {
	    CAM_DRV.cooler_off(cam);
	}
	if (cam->coolerindex == 1) {
	    CAM_DRV.cooler_on(cam);
	}
	if (cam->coolerindex == 2) {
	    CAM_DRV.cooler_check(cam);
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
	k = 0;
	while (cam_coolers[k] != NULL) {
	    sprintf(ligne2, "%s", cam_coolers[k]);
	    strcat(ligne, ligne2);
	    if (cam_coolers[++k] != NULL) {
		strcat(ligne, "|");
	    }
	    strcat(ligne, " ?temperature?");
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%s", cam_coolers[cam->coolerindex]);
	if (strcmp(cam_coolers[cam->coolerindex], "check") == 0) {
	    sprintf(ligne2, " %f", cam->check_temperature);
	    strcat(ligne, ligne2);
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

static int cmdCamInterrupt(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0, k = 0, choix = 1;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      k = 0;
      pb = 1;
      choix = atoi(argv[2]);
      if (choix == 0) {
         cam->interrupt = 0;
         pb = 0;
         cam->authorized = 1;
      }
      if (choix == 1) {
         cam->interrupt = 1;
         pb = 0;
         cam->authorized = 1;
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      strcat(ligne, " 0|1");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne, "%d", cam->interrupt);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

static int cmdCamOverscan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256], ligne2[50];
    int result = TCL_OK, pb = 0, k = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc < 2) || (argc > 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	k = 0;
	pb = 1;
	while (cam_overscans[k] != NULL) {
	    if (strcmp(argv[2], cam_overscans[k]) == 0) {
		cam->overscanindex = k;
		pb = 0;
		break;
	    }
	    k++;
	}
	cam->nb_photox = CAM_INI[cam->index_cam].maxx;	/* nombre de photosites sur X */
	cam->nb_photoy = CAM_INI[cam->index_cam].maxy;	/* nombre de photosites sur Y */
	if (cam->overscanindex == 0) {
	    /* nb photosites masques autour du CCD */
	    cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
	    cam->nb_deadendphotox = CAM_INI[cam->index_cam].overscanxend;
	    cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
	    cam->nb_deadendphotoy = CAM_INI[cam->index_cam].overscanyend;
	} else {
	    cam->nb_photox += (CAM_INI[cam->index_cam].overscanxbeg + CAM_INI[cam->index_cam].overscanxend);
	    cam->nb_photoy += (CAM_INI[cam->index_cam].overscanybeg + CAM_INI[cam->index_cam].overscanyend);
	    /* nb photosites masques autour du CCD */
	    cam->nb_deadbeginphotox = 0;
	    cam->nb_deadendphotox = 0;
	    cam->nb_deadbeginphotoy = 0;
	    cam->nb_deadendphotoy = 0;
	}
	/* --- initialisation de la fenetre par defaut --- */
	cam->x1 = 0;
	cam->y1 = 0;
	cam->x2 = cam->nb_photox - 1;
	cam->y2 = cam->nb_photoy - 1;
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
	k = 0;
	while (cam_overscans[k] != NULL) {
	    sprintf(ligne2, "%s", cam_overscans[k]);
	    strcat(ligne, ligne2);
	    if (cam_overscans[++k] != NULL) {
		strcat(ligne, "|");
	    }
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%s", cam_overscans[cam->overscanindex]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

static int cmdCamFoclen(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   double d;
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?focal_length_(meters)?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%f", cam->foclen);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      pb = 0;
      if (Tcl_GetDouble(interp, argv[2], &d) != TCL_OK) {
         pb = 1;
      }
      if (pb == 0) {
         if (d <= 0.0) {
            pb = 1;
         }
      }
      if (pb == 1) {
         sprintf(ligne, "Usage: %s %s ?focal_length_(meters)?\nfocal_length : must be an float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         cam = (struct camprop *) clientData;
         cam->foclen = d;
         sprintf(ligne, "%f", cam->foclen);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      }
   }
   return result;
}

static int cmdCamMirrorH(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->mirrorh);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      cam = (struct camprop *) clientData;
      if (Tcl_GetInt(interp, argv[2], &cam->mirrorh) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\nvalues must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp, "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

static int cmdCamMirrorV(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->mirrorv);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      cam = (struct camprop *) clientData;
      if (Tcl_GetInt(interp, argv[2], &cam->mirrorv) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\nvalue must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp, "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if (CAM_DRV.close != NULL) {
      CAM_DRV.close(cam);
   }
   Tcl_ResetResult(interp);
   return TCL_OK;
}


static int cam_init_common(struct camprop *cam, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --------------------------------------------------------- */
/* argv[2] : symbole du port (lpt1,etc.)                     */
/* argv[>=3] : optionnels : -ccd -num -name                  */
/* --------------------------------------------------------- */
{
   int k, kk;
   
   /* --- Decode les options de cam::create en fonction de argv[>=3] --- */
   cam->index_cam = 0;
   if (argc >= 5) {
      for (kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-name") == 0) {
            k = 0;
            while (strcmp(CAM_INI[k].name, "") != 0) {
               if (strcmp(CAM_INI[k].name, argv[kk + 1]) == 0) {
                  cam->index_cam = k;
                  break;
               }
               k++;
            }
         }
         if (strcmp(argv[kk], "-ccd") == 0) {
            k = 0;
            while (strcmp(CAM_INI[k].name, "") != 0) {
               if (strcmp(CAM_INI[k].ccd, argv[kk + 1]) == 0) {
                  cam->index_cam = k;
                  break;
               }
               k++;
            }
         }
      }
   }
   /* --- authorize the sti/cli functions --- */
   if (cam->authorized == 0) {
      cam->interrupt = 0;
   } else {
      cam->interrupt = 1;
   }
   /* --- L'axe X est choisi parallele au registre horizontal. --- */
   cam->overscanindex = CAM_INI[cam->index_cam].overscanindex;
   cam->nb_photox = CAM_INI[cam->index_cam].maxx;	/* nombre de photosites sur X */
   cam->nb_photoy = CAM_INI[cam->index_cam].maxy;	/* nombre de photosites sur Y */
   if (cam->overscanindex == 0) {
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
      cam->nb_deadendphotox = CAM_INI[cam->index_cam].overscanxend;
      cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
      cam->nb_deadendphotoy = CAM_INI[cam->index_cam].overscanyend;
   } else {
      cam->nb_photox += (CAM_INI[cam->index_cam].overscanxbeg + CAM_INI[cam->index_cam].overscanxend);
      cam->nb_photoy += (CAM_INI[cam->index_cam].overscanybeg + CAM_INI[cam->index_cam].overscanyend);
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = 0;
      cam->nb_deadendphotox = 0;
      cam->nb_deadbeginphotoy = 0;
      cam->nb_deadendphotoy = 0;
   }
   cam->celldimx = CAM_INI[cam->index_cam].celldimx;	/* taille d'un photosite sur X (en metre) */
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;	/* taille d'un photosite sur Y (en metre) */
   cam->fillfactor = CAM_INI[cam->index_cam].fillfactor;	/* fraction du photosite sensible a la lumiere */
   cam->foclen = CAM_INI[cam->index_cam].foclen;
   /* --- initialisation de la fenetre par defaut --- */
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;
   /* --- initialisation du mode de binning par defaut --- */
   cam->binx = CAM_INI[cam->index_cam].binx;
   cam->biny = CAM_INI[cam->index_cam].biny;
   /* --- initialisation du temps de pose par defaut --- */
   cam->exptime = (float) CAM_INI[cam->index_cam].exptime;

   /* --- initialisation des retournements par defaut --- */
   cam->mirrorh = 0;
   cam->mirrorv = 0;
   /* --- initialisation du numero de port parallele du PC --- */
   cam->portindex = 0;
   cam->port = 0x378;		/* lpt1 par defaut */
   if (argc >= 2) {
      if (strcmp(argv[2], cam_ports[1]) == 0) {
         cam->portindex = 1;
         cam->port = 0x278;
      }
   }
   cam->check_temperature = CAM_INI[cam->index_cam].check_temperature;
   cam->timerExpiration = NULL;
   
   return 0;
}
