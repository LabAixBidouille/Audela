/* camtcl.c
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
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
 *  Definition a structure specific for this driver
 */

char *cam_shuttertypes[] = {
    "audine",
    "thierry",
    NULL
};

/*
 * -----------------------------------------------------------------------------
 * -----------------------------------------------------------------------------
 */

int cmdEthernaudeDirectClear(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int res;
    int result = TCL_OK;
    struct camprop *cam;
    unsigned char a;
    cam = (struct camprop *) clientData;
    if (cam->direct == 1) {
	if (argc != 3) {
	    sprintf(ligne, "Usage: %s %s nb_wipe", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    a = (unsigned char) argv[2][0];
	    res = ETHERNAUDE_DIRECTMAIN(DIRECT_SERVICE_CLEARCCD, 1, &a);
	    sprintf(ligne, "%d", res);
	}
    } else {
	result = TCL_ERROR;
	sprintf(ligne, "This function cannot be used with this driver");
    }
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return result;
}

int cmdEthernaudeDirectReset(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    char ligne2[256];
    int res;
    int result = TCL_OK;
    struct camprop *cam;
    unsigned char a[2];
    int n = 2, k;
    cam = (struct camprop *) clientData;
    if (cam->direct == 1) {
	res = ETHERNAUDE_DIRECTMAIN(DIRECT_SERVICE_RESET, n, &a[0], &a[1]);
	sprintf(ligne, "%d", res);
	if (res == DIRECT_OK) {
	    sprintf(ligne, "{%d} {", res);
	    for (k = 0; k < n; k++) {
		strcpy(ligne2, ligne);
		sprintf(ligne, "%s %u", ligne2, a[k]);
	    }
	    strcpy(ligne2, ligne);
	    sprintf(ligne, "%s}", ligne2);
	}
    } else {
	result = TCL_ERROR;
	sprintf(ligne, "This function cannot be used with this driver");
    }
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return result;
}

int cmdEthernaudeDirectIdentity(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    char ligne2[256];
    int res;
    int result = TCL_OK;
    struct camprop *cam;
    unsigned char a[28];
    int n = 28, k;
    cam = (struct camprop *) clientData;
    if (cam->direct == 1) {
	res = ETHERNAUDE_DIRECTMAIN(DIRECT_SERVICE_IDENTITY, n, &a[0], &a[1], &a[2], &a[3], &a[4], &a[5], &a[6], &a[7], &a[8], &a[9], &a[10], &a[11], &a[12], &a[13], &a[14], &a[15], &a[16], &a[17], &a[18], &a[19], &a[20], &a[21], &a[22], &a[23], &a[24], &a[25], &a[26], &a[27]);
	sprintf(ligne, "%d", res);
	if (res == DIRECT_OK) {
	    sprintf(ligne, "{%d} {", res);
	    for (k = 0; k < n; k++) {
		strcpy(ligne2, ligne);
		sprintf(ligne, "%s %u", ligne2, a[k]);
	    }
	    strcpy(ligne2, ligne);
	    sprintf(ligne, "%s}", ligne2);
	}
    } else {
	result = TCL_ERROR;
	sprintf(ligne, "This function cannot be used with this driver");
    }
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return result;
}

/* ============================================================================= */

int cmdEthernaudeChannel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", cam->channel);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}


int cmdEthernaudeReinit(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
#ifdef CAMTCL_DEBUG
    printf("close dans cmdEthernaudeReinit\n");
#endif
    CAM_DRV.close(cam);
    if (CAM_DRV.init(cam, argc, argv) != 0) {
	Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
	return TCL_ERROR;
    }
    Tcl_SetResult(interp, "", TCL_VOLATILE);
    return TCL_OK;
    /* cam1 reinit -ip 192.168.0.123 */
}


/*
 * -----------------------------------------------------------------------------
 *  TTTTT DDDD   III
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I    acquisition mode
 *    T   D   D   I
 *    T   D   D   I
 *    T   DDDD   III
 * -----------------------------------------------------------------------------
 */

/*
Paramètres d'entrée (ParamCCDInt.Param):
*[]= " CCD# = 1 " :Int32 Numéro du CCD auquel on s'adresse.
*[]= " LineExposure = 133 " : Int32Temps de pose en ms pour chaque ligne.
[]= " X1 = 10 " : int32Définition de fenêtre.
[]= " X2 = 100 " :int32Définition de fenêtre.
[]= " BinningX = 3 " : int32Définition de binning X
*[]= " BufferDisplayLinesY = 500 " : int32 Définition du buffer de visualisation,
une fois les N lignes atteintes, le système reboucle sur la première ligne.
*[]= " PathImageSaved = C:\temp\toto.dat " :StringFichier ou l'image est
sauvegardee de facon brute...
*[]= " PathLogSaved = C:\temp\Log.dat " :StringFichier ou des informations
sont sauvegardees...
[]= " ShutterOpen = TRUE " :boolean Shutter doit s'ouvrir pd la pose.

Le mode TDI commence immédiatement et est arrête par une commande  AbortExposure
*/

 /*
  * -----------------------------------------------------------------------------
  *  cmdEthernaudeScan()
  *
  *  Lance un scan.
  *
  *  buf scan width height bin dt
  *    - width : largeur de l'image
  *    - height : largeur de l'image
  *    - bin : facteur de binning
  *    - dt : intervalle de temps entre chaque lecture de ligne (en ms, float)
  *    - -firstpix index : la fenetre commence au pixel numéro (1 a DimX).
  *
  *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
  * -----------------------------------------------------------------------------
  */
int cmdEthernaudeScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int w;			/* parametre d'appel : largeur */
    int h;			/* parametre d'appel : hauteur */
    int b;			/* parametre d'appel : binning */
    double dt;			/* parametre d'appel : intervalle de temps */
    int retour = TCL_OK;
    struct camprop *cam;
    char *ligne;		/* Texte pour le retour */
    char *ligne2;		/* Texte pour le retour */
    int offset = 1;
    int i, ok, x1, x2, k;
    char result[256];
    char msgtcl[] = "Usage: %s %s width height bin dt ?-firstpix index?";
    ligne = (char *) calloc(200, sizeof(char));
    ligne2 = (char *) calloc(200, sizeof(char));
    if (argc < 6) {
	sprintf(ligne, msgtcl, argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
/*      if(TheScanStruct==NULL) {*/
	if (Tcl_GetInt(interp, argv[2], &w) != TCL_OK) {
	    sprintf(ligne2, "%s\nwidth : must be an integer between 1 and %d", msgtcl, cam->nb_photox);
	    sprintf(ligne, ligne2, argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else if (Tcl_GetInt(interp, argv[3], &h) != TCL_OK) {
	    sprintf(ligne2, "%s\nheight : must be an integer >= 1", msgtcl);
	    sprintf(ligne, ligne2, argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else if (Tcl_GetInt(interp, argv[4], &b) != TCL_OK) {
	    sprintf(ligne2, "%s\nbin : must be an integer >= 1", msgtcl);
	    sprintf(ligne, ligne2, argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else if (Tcl_GetDouble(interp, argv[5], &dt) != TCL_OK) {
	    sprintf(ligne2, "%s\ndt : must be an floating point number >= 0, expressed in milliseconds", msgtcl);
	    sprintf(ligne, ligne2, argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else {
	    for (i = 6; i < argc; i++) {
		if ((strcmp(argv[i], "-offset") == 0) || (strcmp(argv[i], "-firstpix") == 0)) {
		    if (Tcl_GetInt(interp, argv[++i], &offset) != TCL_OK) {
			sprintf(ligne, "Usage: %s %s width height bin dt ?-firstpix index? ?-blocking? ?-perfo?\nfirstpix index \"%s\" must be an integer", argv[0], argv[1], argv[i]);
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			ok = 0;
		    }
		}
		/*else if(strcmp(argv[i],"-fast")==0) {
		   loopmilli1=0.;
		   if (i<argc-1) {
		   loopmilli1=atof(argv[i+1]);
		   }
		   blocking = 1;
		   } else if(strcmp(argv[i],"-perfo")==0) {
		   keep_perfos = 1;
		   } else if(strcmp(argv[i],"-tmpfile")==0) {
		   fileima = 1;
		   }
		 */
	    }
	}
	/* --- c'est parti pour l'Ethernaude -- */
	x1 = offset;
	x2 = w + offset;
	/* - InitTDIExposure sur le CCD numero 1 - */
	paramCCD_clearall(&ParamCCDIn, 1);
	paramCCD_put(-1, "InitTDIExposure", &ParamCCDIn, 1);
	paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
	sprintf(ligne, "LineExposure=%d", (int) dt);
	paramCCD_put(-1, ligne, &ParamCCDIn, 1);
	sprintf(ligne, "X1=%d", x1);
	paramCCD_put(-1, ligne, &ParamCCDIn, 1);
	sprintf(ligne, "X2=%d", x2);
	paramCCD_put(-1, ligne, &ParamCCDIn, 1);
	sprintf(ligne, "BinningX=%d", b);
	paramCCD_put(-1, ligne, &ParamCCDIn, 1);
	strcpy(ligne, "PathImageSaved=D:/audela/toto.dat");
	paramCCD_put(-1, ligne, &ParamCCDIn, 1);
	if (cam->shutterindex == 0) {
	    if (cam->shutteraudinereverse == 0) {
		strcpy(ligne, "ShutterOpen=0");
	    } else {
		strcpy(ligne, "ShutterOpen=1");
	    }
	} else {
	    if (cam->shutteraudinereverse == 0) {
		strcpy(ligne, "ShutterOpen=1");
	    } else {
		strcpy(ligne, "ShutterOpen=0");
	    }
	}
	paramCCD_put(-1, ligne, &ParamCCDIn, 1);
	util_log("", 1);
	for (k = 0; k < ParamCCDIn.NbreParam; k++) {
	    paramCCD_get(k, result, &ParamCCDIn);
	    util_log(result, 0);
	}
	AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
	util_log("", 2);
	for (k = 0; k < ParamCCDOut.NbreParam; k++) {
	    paramCCD_get(k, result, &ParamCCDOut);
	    util_log(result, 0);
	}
	util_log("\n", 0);
	libcam_sleep(5000);
	/* - InitTDIExposure sur le CCD numero 1 - */
	paramCCD_clearall(&ParamCCDIn, 1);
	paramCCD_put(-1, "AbortExposure", &ParamCCDIn, 1);
	paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
	AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);

/*
      } else {
         sprintf(ligne,"Camera already in use");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
      }
*/
    }
    free(ligne);
    free(ligne2);
    return retour;
}



/*
 * -----------------------------------------------------------------------------
 *  cmdEthernaudeBreakScan --
 *
 *  Commande d'arret d'acquisition de scan.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdEthernaudeBreakScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int retour = TCL_OK;
    char result[MAXLENGTH];
    int k;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    /* - InitExposure sur le CCD numero 1 clock mode 1- */
    paramCCD_clearall(&ParamCCDIn, 1);
    paramCCD_put(-1, "AbortExposure", &ParamCCDIn, 1);
    paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
    util_log("", 1);
    for (k = 0; k < ParamCCDIn.NbreParam; k++) {
	paramCCD_get(k, result, &ParamCCDIn);
	util_log(result, 0);
    }
    AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
    util_log("", 2);
    for (k = 0; k < ParamCCDOut.NbreParam; k++) {
	paramCCD_get(k, result, &ParamCCDOut);
	util_log(result, 0);
    }
    util_log("\n", 0);
    if (ParamCCDOut.NbreParam >= 1) {
	paramCCD_get(0, result, &ParamCCDOut);
	strcpy(cam->msg, "");
	if (strcmp(result, "FAILED") == 0) {
	    retour = TCL_ERROR;
	    if (ParamCCDOut.NbreParam >= 2) {
		paramCCD_get(1, result, &ParamCCDOut);
		sprintf(cam->msg, "AbortExposure Failed : %s", result);
	    } else {
		strcpy(cam->msg, "AbortExposure Failed");
	    }
	}
    }
    return retour;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdEthernaudeShutterType()
 *
 * Setect the type of shutter. 2 shutter types are supported :
 *  audine : build by Raymond David (Essentiel Electronic)
 *  thierry : build by Pierre Thierry.
 *
 * -----------------------------------------------------------------------------
 */
int cmdEthernaudeShutterType(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    char ligne2[256];
    char **argvv = NULL;
    int argcc;
    int result = TCL_OK, pb = 0, reinit = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc > 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (strcmp(argv[2], "audine") == 0) {
	    cam->shuttertypeindex = 0;
	    cam->shutteraudinereverse = 0;
	    if (argc >= 4) {
		if (strcmp(argv[3], "reverse") == 0) {
		    cam->shutteraudinereverse = 1;
		}
	    }
	    reinit = 1;
	    pb = 0;
	    /*
	       } else if (strcmp(argv[2],"thierry")==0) {
	       cam->shuttertypeindex=1;
	       pb=0;
	     */
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	/*sprintf(ligne,"Usage: %s %s audine|thierry ?options?",argv[0],argv[1]); */
	sprintf(ligne, "Usage: %s %s audine ?options?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	if (cam->shuttertypeindex == 0) {
	    if (cam->shutteraudinereverse == 0) {
		sprintf(ligne, "audine");
	    } else {
		sprintf(ligne, "audine reverse");
	    }
	} else if (cam->shuttertypeindex == 1) {
	    sprintf(ligne, "thierry");
	}
	if (reinit == 1) {
#ifdef CAMTCL_DEBUG
	    printf("close dans cmdEthernaudeShutterType\n");
#endif
	    CAM_DRV.close(cam);
	    sprintf(ligne2, "-ip %d.%d.%d.%d -shutterinvert %d -canspeed %d ", cam->inparams.ip[0], cam->inparams.ip[1], cam->inparams.ip[2], cam->inparams.ip[3], cam->shutteraudinereverse, cam->inparams.canspeed);
	    util_splitline(ligne2, &argcc, &argvv);
	    if (CAM_DRV.init(cam, argcc, argvv) != 0) {
		Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
		util_free((char *) argvv);
		return TCL_ERROR;
	    }
	    util_free((char *) argvv);
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdEthernaudeCanSpeed()
 *
 * Setect the speed parameter for the CAN:
 *  value between 0 and 150 (default 4)
 *
 * -----------------------------------------------------------------------------
 */
int cmdEthernaudeCanSpeed(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    char ligne2[256];
    char **argvv = NULL;
    int argcc;
    int result = TCL_OK, pb = 0, reinit = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc > 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	cam->canspeed = atoi(argv[2]);
	reinit = 1;
	pb = 0;
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ?value?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	sprintf(ligne, "%d", cam->canspeed);
	if (reinit == 1) {
#ifdef CAMTCL_DEBUG
	    printf("close dans cmdEthernaudeCanSpeed\n");
#endif
	    
	    CAM_DRV.close(cam);
	    sprintf(ligne2, "-ip %d.%d.%d.%d -shutterinvert %d -canspeed %d ", cam->inparams.ip[0], cam->inparams.ip[1], cam->inparams.ip[2], cam->inparams.ip[3], cam->inparams.shutterinvert, cam->canspeed);
	    util_splitline(ligne2, &argcc, &argvv);
	    if (CAM_DRV.init(cam, argcc, argvv) != 0) {
		Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
		util_free((char *) argvv);
		return TCL_ERROR;
	    }
	    util_free((char *) argvv);
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}
