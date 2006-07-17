/** @file camtcl.h
 * 
 * Functions C-Tcl specifics for this camera.
 * 
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 *
 */

#ifndef __CAMTCL_H__
#define __CAMTCL_H__


#define COMMON_FUNCS \
   {"videosource",          (Tcl_CmdProc *)cmdCamVideoSource}, \
   {"videoformat",          (Tcl_CmdProc *)cmdCamVideoFormat}, \
   {"longuepose",           (Tcl_CmdProc *)cmdCamLonguePose}, \
   {"longueposelinkno",     (Tcl_CmdProc *)cmdCamLonguePoseLinkno}, \
   {"longueposelinkbit",    (Tcl_CmdProc *)cmdCamLonguePoseLinkbit}, \
   {"longueposestartvalue", (Tcl_CmdProc *)cmdCamLonguePoseStartValue}, \
   {"longueposestopvalue",  (Tcl_CmdProc *)cmdCamLonguePoseStopValue},

#if defined(OS_WIN)
#define OS_SPECIFIC_FUNCS \
   {"startvideoview",            (Tcl_CmdProc *)cmdCamStartVideoView}, \
   {"stopvideoview",             (Tcl_CmdProc *)cmdCamStopVideoView}, \
   {"startvideocapture",         (Tcl_CmdProc *)cmdCamStartVideoCapture}, \
   {"stopvideocapture",          (Tcl_CmdProc *)cmdCamStopVideoCapture}, \
   {"setvideostatusvariable",    (Tcl_CmdProc *)cmdCamSetVideoSatusVariable}, \
   {"startvideocrop",            (Tcl_CmdProc *)cmdCamStartVideoCrop}, \
   {"stopvideocrop",             (Tcl_CmdProc *)cmdCamStopVideoCrop}, \
   {"setvideocroprect",          (Tcl_CmdProc *)cmdCamSetVideoCropRect}, \
   {"startvideoguiding",         (Tcl_CmdProc *)cmdCamStartVideoGuiding}, \
   {"stopvideoguiding",          (Tcl_CmdProc *)cmdCamStopVideoGuiding}, \
   {"setvideoguidingcallback",   (Tcl_CmdProc *)cmdCamSetVideoGuidingCallback}, \
   {"setvideoguidingtargetsize", (Tcl_CmdProc *)cmdCamSetVideoGuidingTargetSize},
#endif

#if defined(OS_LIN)
#define OS_SPECIFIC_FUNCS \
   {"validframe",     (Tcl_CmdProc *)cmdCamValidFrame}, \
   {"getvideoformat", (Tcl_CmdProc *)cmdCamGetVideoFormat}, \
   {"setvideoformat", (Tcl_CmdProc *)cmdCamSetVideoFormat}, \
   {"getvideosource", (Tcl_CmdProc *)cmdCamGetVideoSource}, \
   {"setvideosource", (Tcl_CmdProc *)cmdCamSetVideoSource},
#endif


#define SPECIFIC_CMDLIST \
   COMMON_FUNCS \
   OS_SPECIFIC_FUNCS



#ifdef __cplusplus
extern "C" {			/* Assume C declarations for C++ */
#endif				/* __cplusplus */

    /* === Specific commands for that camera === */
    int cmdCamVideoSource(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamVideoFormat(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePoseLinkno(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePoseLinkbit(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePoseStartValue(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePoseStopValue(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
/* Some new for Linux */
    int cmdCamValidFrame(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoFormat(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamGetVideoFormat(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamGetVideoSource(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoSource(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

/******************************************************************/
/*  Commandes utilisees pour la capture video (M. Pujol)          */
/*  Pour Windows uniquement                                       */
/******************************************************************/
#if defined(OS_WIN)
    int cmdCamStartVideoView(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoView(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStartVideoCapture(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoCapture(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoSatusVariable(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStartVideoCrop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoCrop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoCropRect(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStartVideoGuiding(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoGuiding(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoGuidingCallback(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoGuidingTargetSize(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#endif				//defined(OS_WIN)

/* ----- defines specifiques aux fonctions de cette camera ----*/

/*
 * -----------------------------------------------------------------------------
 *  TTTTT DDDD   III
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I
 *    T   DDDD   III
 * -----------------------------------------------------------------------------
 */
#if 0
    typedef struct {
	char *dateobs;		/* Date du debut de l'observation (format FITS) */
	char *dateend;		/* Date de fin de l'observation (format FITS) */
	ClientData clientData;	/* Camera (CCamera*) */
	Tcl_Interp *interp;	/* Interpreteur */
	Tcl_TimerToken TimerToken;	/* Handler sur le timer */
	int width;		/* Largeur de l'image */
	int offset;		/* Offset en x (a partir de 1) */
	int height;		/* Hauteur totale de l'image */
	int bin;		/* binning */
	float dt;		/* intervalle de temps en millisecondes */
	int y;			/* nombre de lignes deja lues */
	unsigned long t0;	/* instant de depart en microsecondes */
	unsigned short *pix;	/* stockage de l'image */
	unsigned short *pix2;	/* pointeur defilant sur le contenu de pix */
	int last_delta;		/* dernier delta temporel */
	int blocking;		/* vaut 1 si le scan est bloquant */
	int keep_perfos;	/* vaut 1 si on conserve les dt du scan dans 1 fichier */
	int fileima;		/* vaut 1 si on écrit les pixels dans un fichier */
	FILE *fima;		/* fichier binaire pour stocker les pixels */
	int *dts;		/* tableau des délais */
	unsigned long loopmilli1;	/* nb de boucles pour faire une milliseconde (~10000) */
	int stop;		/* indicateur d'arret (1=>pose arretee au prochain coup) */
	double tumoinstl;	/* TU-TL */
	double ra;		/* RA at the bigining */
	double dec;		/* DEC at the bigining */
    } ScanStruct;

    void ScanCallback(ClientData clientData);
    void ScanLibereStructure();
    void ScanTerminateSequence(ClientData clientData, int camno, char *reason);
    void ScanTransfer(ClientData clientData);
#endif

#ifdef __cplusplus
}				/* End of extern "C" { */
#endif				/* __cplusplus */
#endif
