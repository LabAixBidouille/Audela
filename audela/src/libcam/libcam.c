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
 * $Id: libcam.c,v 1.44 2010-09-22 16:51:11 michelpujol Exp $
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */

#if defined(OS_LIN)
#include <sys/time.h>           /* gettimeofday */
#endif

#include "camera.h"

#include <libcam/libcam.h>
#include <libcam/libstruc.h>
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
static int cmdCamAvailable(struct camprop *cam, Tcl_Interp * interp, int argc, const char *argv[]);

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
static int cmdCamCapabilities(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamLastError(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamThreadId(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);


/* --- Action commands ---*/
static int cmdCamName(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamProduct(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamCcd(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamBin(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamDark(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamExptime(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamBuf(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamWindow(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamTel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamRadecFromTel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamStop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamShutter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamCooler(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamFoclen(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamOverscan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamInterrupt(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamDebug(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdCamHeaderProc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

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

static int debug_level = 0;
static char logFileName[1024];

/*
 * char* getlogdate(char *buf, size_t size)
 *   Generates a FITS compliant string into buf representing the date at which
 *   this function is called. Returns buf.
 */
char *getlogdate(char *buf, size_t size)
{
#if defined(OS_WIN)
  #ifdef _MSC_VER
    /* cas special a Microsoft C++ pour avoir les millisecondes */
    struct _timeb timebuffer;
    time_t ltime;
    _ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
  #else
    struct time t1;
    struct date d1;
    getdate(&d1);
    gettime(&t1);
    sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d.%02d : ", d1.da_year,
        d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec,
        t1.ti_hund);
  #endif
#elif defined(OS_LIN)
    struct timeb timebuffer;
    time_t ltime;
    ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
#elif defined(OS_MACOS)
    struct timeval t;
    char message[50];
    char s1[27];
    gettimeofday(&t,NULL);
    strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
    sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);
#else
    sprintf(s1,"[No time functions available]");
#endif

    return buf;
}

static void libcam_log(int level, const char *fmt, ...)
{
   FILE *f;
   char buf[100];

   va_list mkr;
   va_start(mkr, fmt);

   if (level <= debug_level) {
      getlogdate(buf,100);
      f = fopen(logFileName,"at+");
      switch (level) {
      case LOG_ERROR:
         fprintf(f,"%s - %s(%s) <ERROR> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_WARNING:
         fprintf(f,"%s - %s(%s) <WARNING> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_INFO:
         fprintf(f,"%s - %s(%s) <INFO> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_DEBUG:
         fprintf(f,"%s - %s(%s) <DEBUG> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      }
      vfprintf(f,fmt, mkr);
      fprintf(f,"\n");
      va_end(mkr);
      fclose(f);
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
   char s[1024];
   int camno, err, i;
   struct camprop *cam, *camm;
   char camThreadId[20];
   char mainThreadId[20];

   if (argc < 3) {
      if ( argc ==2 && strcmp(argv[1],"available") == 0) {
         return cmdCamAvailable(clientData, interp, argc, argv);
      } else {
         sprintf(s, "%s driver port ?options?", argv[0]);
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
   } else {
      const char *platform;
      const char *threaded;

#ifdef CMD_CAM_SETUP
      if (argc == 3 && strcmp(argv[1],"setup") == 0) {
         return cmdAscomcamSetupDialog(clientData, interp, argc, argv);
      }
#endif

      //
      if((platform=Tcl_GetVar(interp,"tcl_platform(platform)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdCamCreate: Global variable tcl_platform(os) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      if((threaded=Tcl_GetVar(interp,"tcl_platform(threaded)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdCamCreate: Global variable tcl_platform(threaded) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }

      if ( strcmp(argv[argc-2],"mainThreadId") != 0 ) {
         if ( strcmp(threaded,"1") == 0 ) {
            // Cas de l'environnement multi-thread : je cree un thread dediee a la camera ,
            if ( !( strcmp(argv[0],"webcam") == 0 && strcmp(platform,"windows")==0)
               ) {
               // Cas normal en mutlti-thread

               // je recupere l'indentifiant de la thread principale
               Tcl_Eval(interp, "thread::id");
               strcpy(mainThreadId, interp->result);
               // je cree la thread de la camera
               Tcl_Eval(interp, "thread::create");
               strcpy(camThreadId, interp->result);
               // je duplique la commande "cam1" dans la thread de la camera
               sprintf(s,"thread::copycommand %s %s ",camThreadId, argv[0]);
               if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
                  sprintf(s, "cmdCamCreate: %s",interp->result);
                  Tcl_SetResult(interp, s, TCL_VOLATILE);
                  return TCL_ERROR;
               }
               // je duplique la commande de creation de buffer
               sprintf(s,"thread::copycommand %s buf::create ",camThreadId);
               Tcl_Eval(interp, s);
               // je duplique la commande de suppression de buffer
               sprintf(s,"thread::copycommand %s buf::delete ",camThreadId);
               Tcl_Eval(interp, s);

               // je prepare la commande de creation de la camera dans la thread de la camera :
               // thread::send $threadId { {argv0} {argv1} ... {argvn} mainThreadId $mainThreadId }
               sprintf(s,"thread::send %s { ",camThreadId);
               for (i=0;i<argc;i++) {
                  strcat(s," {");
                  strcat(s,argv[i]);
                  strcat(s,"} ");
               }
               // j'ajoute le numero de la thread principale en dernier parametre
               strcat(s,"mainThreadId ");
               strcat(s, mainThreadId);
               strcat(s," }");
               // je lance la creattion de la camera en l'executant dans la thread de la camera
               return Tcl_Eval(interp, s);
            } else {
               // Cas particulier de la webcam avec le driver VFW en multi-thread sous Windows :
               // je cree la camera dans la thread principale a cause de la fenetre du driver
               // par contre les acquisitions seront faites dans la thread de la camera comme
               // pour les autres cameras
               Tcl_Eval(interp, "thread::id");
               strcpy(mainThreadId, interp->result);
               Tcl_Eval(interp, "thread::create");
               strcpy(camThreadId, interp->result);
               // je duplique la commande de creation de buffer
               sprintf(s,"thread::copycommand %s buf::create ",camThreadId);
               Tcl_Eval(interp, s);
               // je duplique la commande de suppression de buffer
               sprintf(s,"thread::copycommand %s buf::delete ",camThreadId);
               Tcl_Eval(interp, s);

            }
         } else {
            // Cas de l'environnement mono-thread
            strcpy(mainThreadId, "");
            strcpy(camThreadId,  "");
         }
      } else {
         // on est dans la thread de la camera
         strcpy(mainThreadId, argv[argc-1]);
         Tcl_Eval(interp, "thread::id");
         strcpy(camThreadId, interp->result);
      }


      // On initialise la camera sur le port. S'il y a une erreur, alors on
      // renvoie le message qui va bien, en supprimant la structure cree.
      // Si OK, la commande TCL est creee d'apres l'argv[1], et on garde
      // trace de la structure creee.

      fprintf(stderr, "%s(%s): CamCreate(argc=%d", CAM_LIBNAME, CAM_LIBVER, argc);
      for (i = 0; i < argc; i++) {
         fprintf(stderr, ",argv[%d]=%s", i, argv[i]);
      }
      fprintf(stderr, ")\n");

      cam = (struct camprop *) calloc(1, sizeof(struct camprop));

      strcpy(cam->mainThreadId, mainThreadId);
      strcpy(cam->camThreadId,  camThreadId);
      fprintf(stderr, "%s(%s): CamCreate mainThreadId=%s camThreadId=%s platform=%s\n", CAM_LIBNAME, CAM_LIBVER, mainThreadId, camThreadId, platform);

      // Je ne sais pas a quoi sert ce test (Michel)
      // Est-ce pour inhiber les cameras sous Windows et Mac ?
      if ( strcmp(platform, "unix") == 0) {
         cam->authorized = 1;
      } else {
         // je n'autorise pas les interuptions usr Windows et sur Mac
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

      cam->bufno = 0;
      cam->telno = 0;
      cam->timerExpiration = NULL;
      camm = camprops;
      if (camm == NULL) {
         camprops = cam;
      } else {
         while (camm->next != NULL)
            camm = camm->next;
         camm->next = cam;
      }

      // Cree la nouvelle commande par le biais de l'unique
      // commande exportee de la librairie libcam.
      Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdCam, (ClientData) cam, NULL);

      // cas du mutltithread
      if ( cam->camThreadId[0] != 0 ) {
         if ( !(strcmp(argv[0],"webcam") == 0 && strcmp(platform,"windows")==0)
            ) {
            // je duplique la commande de la camera dans la thread principale
            sprintf(s,"thread::copycommand %s %s ",mainThreadId, argv[1]);
            Tcl_Eval(interp, s);
            // je cree la variable ::status_cam dans la thread principale
            sprintf(s, "thread::send -async %s { set ::status_cam%d stand }", cam->mainThreadId, cam->camno);
            Tcl_Eval(interp, s);

            // je recupere le thread de la camera
            sprintf(s, "thread::send %s [list tel%d threadid]", cam->camThreadId, cam->telno);
            if ( Tcl_Eval(interp, s) == TCL_OK ) {
               char telThreadId[20] ;
               strcpy(telThreadId, interp->result);
               // je copie la commande du telescope dans le thread de la camera
               sprintf(s, "thread::send -async %s [list thread::copycommand %s tel%d]",
                  telThreadId, cam->camThreadId, cam->telno);
               Tcl_Eval(interp, s);
            }

         } else {
            // cas particulier de la webcam sous windows
            // je duplique la commande de la camera dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",cam->camThreadId, argv[1]);
            Tcl_Eval(interp, s);
            // je cree la variable ::status_cam dans la thread de la camera
            sprintf(s, "thread::send -async %s { set ::status_cam%d stand }", cam->camThreadId, cam->camno);
            Tcl_Eval(interp, s);

            // je recupere le thread de la camera
            sprintf(s, "tel%d threadid", cam->telno);
            if ( Tcl_Eval(interp, s) == TCL_OK ) {
               char telThreadId[20] ;
               strcpy(telThreadId, interp->result);
               // je copie la commande du telescope dans le thread de la camera
               sprintf(s, "thread::send -async %s [list thread::copycommand %s tel%d]",
                  telThreadId, cam->camThreadId, cam->telno);
               Tcl_Eval(interp, s);
            }

         }

      }

      // set TCL global status_camNo
      //sprintf(s, "status_cam%d", cam->camno);
      //Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
      setCameraStatus(cam,interp,"stand");

      libcam_log(LOG_DEBUG, "cmdCamCreate: create camera data at %p\n", cam);
   }
   return TCL_OK;
}

static int cmdCam(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char s[1024], ss[50];
   int retour = TCL_OK, k, i;
   struct cmditem *cmd;
   struct camprop *cam = (struct camprop *) clientData;

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

      if ( cam->camThreadId[0] != 0 ) {
         // cas du mutltithread
         char currentThread[80];
         // je recupere la thread courante
         Tcl_Eval(interp, "thread::id");
         strcpy(currentThread,interp->result);
        if ( (strcmp(argv[1],"timer") == 0 )
#if defined(OS_WIN)
              // ces commandes de webcam doivent s'executer dans la thread principale sous Windows car elles ouvrer une fenetre.
              || (strcmp(CAM_INI[0].product,"webcam") == 0 && (strcmp(argv[1],"close") == 0 || strcmp(argv[1],"videoformat") == 0|| strcmp(argv[1],"videosource") == 0 || strcmp(argv[1],"startvideoview") == 0 || strcmp(argv[1],"stopvideoview") == 0 || strcmp(argv[1],"startvideocapture") == 0 || strcmp(argv[1],"stopvideocapture") == 0 || strcmp(argv[1],"startvideocrop") == 0 || strcmp(argv[1],"stopvideocrop") == 0 ))
#endif
              )
         {
            // je passe a la suite pour executer immediatement la commande dans la thread principale
         } else {
             // si on n'est pas dans la thread de la camera je transmets la commande a la thread de la camera
            if ( strcmp(currentThread, cam->camThreadId) !=0 )  {
               sprintf(s,"thread::send %s {",cam->camThreadId);
               for (k=0;k<argc;k++) {
                  // les accolades servent a delimiter les parametres de type "list", par exemple le binning
                  strcat(s,"{");
                  strcat(s,argv[k]);
                  strcat(s,"} ");
               }
               strcat(s,"}");
               return Tcl_Eval(interp, s);
            }
         }
      }

      if (debug_level > 0) {
         char s1[256], *s2;
         s2 = s1;
         s2 += sprintf(s2,"Enter cmdCam (argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         libcam_log(LOG_INFO, "%s", s1);
      }

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
 * libcam_GetCurrentFITSDate(char s[23])
 *  retourne la date TU avec le 1/1000 de seconde
 *
 */
void libcam_GetCurrentFITSDate(Tcl_Interp * interp, char *s)
{
   int clock = 0;
   char ligne[256];
#if defined(OS_WIN)
#if defined(_Windows)
   /* cas special a Borland Builder pour avoir les millisecondes */
   struct time t1;
   struct date d1;
   clock = 1;
   getdate(&d1);
   gettime(&t1);
   sprintf(s, "%04d-%02d-%02dT%02d:%02d:%02d.%03d", d1.da_year, d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec, t1.ti_hund);
#endif
#if defined(_MSC_VER)
   /* cas special a Microsoft C++ pour avoir les millisecondes */

   struct _timeb timebuffer;
   char message[50];
   time_t ltime;
   clock = 1;
   _ftime(&timebuffer);   // retourne la date GMT
   time(&ltime);          // retourne la date GMT
   strftime(message, 45, "%Y-%m-%dT%H:%M:%S", gmtime(&ltime));
   sprintf(s, "%s.%03d", message, (int) timebuffer.millitm );


   /*
   struct _SYSTEMTIME temps_pc;
   clock = 1;
    GetSystemTime(&temps_pc);
   sprintf(s, "%04d-%02d-%02dT%02d:%02d:%02d.%03d",
      temps_pc.wYear, temps_pc.wMonth, temps_pc.wDay,
      temps_pc.wHour, temps_pc.wMinute, temps_pc.wSecond,
      temps_pc.wMilliseconds);
   */
#endif
#elif defined(OS_LIN)
    char message[50];
    struct timeval t;
    gettimeofday (&t, NULL);  // retourne la date GMT
    strftime (message, 45, "%Y-%m-%dT%H:%M:%S",gmtime ((const time_t*)(&t.tv_sec)));
    //sprintf (s, "%s.%03d : ", message, (int)(t.tv_usec/1000));
    sprintf (s, "%s.%03d", message, (int)(t.tv_usec/1000));
    clock = 1;
#endif
   if (clock == 0) {
      strcpy(ligne, "clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.000\"");
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
   char s[500];
   *ra = 0.;
   *dec = 0.;
   *status = 1;
   if ( cam->telno != 0 ) {
      sprintf(s,"tel%d coord", cam->telno );
      if ( Tcl_Eval(interp, s) == TCL_OK ) {
         int argcc;
         char **argvv = NULL;

         if (Tcl_SplitList(interp, interp->result, &argcc, &argvv) == TCL_OK) {
            if (argcc >= 2) {
               sprintf(s,"mc_angle2deg %s", argvv[0]);
               if ( Tcl_Eval(interp, s) == TCL_OK) {
                  *ra = (double) atof(interp->result);
                  sprintf(s,"mc_angle2deg %s 90", argvv[1]);
                  if ( Tcl_Eval(interp, s) == TCL_OK) {
                     *dec = (double) atof(interp->result);
                     *status = 0;
                  }
               }
            }
         }
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
            cam->msg[0]=0;
            CAM_DRV.set_binning(i_binx, i_biny, cam);
            if ( cam->msg[0] == 0 ) {
               // je met a jour les coordonnees du fenetrage pour prendre en compte le binning
               CAM_DRV.update_window(cam);
               sprintf(ligne, "%d %d", cam->binx, cam->biny);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            } else {
               Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
               result = TCL_ERROR;
            }
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

         if ( cam->camThreadId[0] != 0 ) {
            // cas du mutltithread
            // je duplique la commande du buffer dans la thread de la camera
            sprintf(ligne, "thread::send -async %s { thread::copycommand %s buf%d }", cam->mainThreadId, cam->camThreadId, cam->bufno);
            Tcl_Eval(interp, ligne);
         }

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

   if ( argc < 2 || argc > 4) {
      sprintf(ligne, "Usage: %s %s ?telno? ?telThreadId?", argv[0], argv[1]);
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
         if ( argc >= 4 &&  cam->camThreadId[0] != 0 ) {
            char telThreadId[20] ;
            strcpy(telThreadId, argv[3]);
            // je copie la commande du telescope dans le thread de la camera
            sprintf(ligne, "thread::send -async %s [list thread::copycommand %s tel%d]",
               telThreadId, cam->camThreadId, cam->telno);
            result = Tcl_Eval(interp, ligne);

         }
         if (result == TCL_OK) {
            //--- je retourne le numero du telescope
            sprintf(ligne, "%d", cam->telno);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         }
      }
   }
   return result;
}

static int cmdCamHeaderProc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?kwd_header_proc? ",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam = (struct camprop*)clientData;
        if(argc!=2) {
          sprintf(cam->headerproc,"%s",argv[2]);
        }
      sprintf(ligne,"%s",cam->headerproc);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/*
 * cmdCamTel
 * Lecture/ecriture de l'incateur pour recuperer ou non les coordonnee du telescope
 */
static int cmdCamRadecFromTel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int value, result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->radecFromTel);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_GetInt(interp, argv[2], &value) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be an integer 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if ( value !=0 && value != 1 ) {
            sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be an integer 0 or 1", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            cam = (struct camprop *) clientData;
            cam->radecFromTel = value;
            sprintf(ligne, "%d", cam->radecFromTel);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         }
      }
   }
   return result;
}

static int cmdCamThreadId(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", cam->camThreadId);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/*
 * AcqRead
 * Commande de lecture du CCD.
 */
static void AcqRead(ClientData clientData )
{
   char errorMessage[1024];
   char s[30000];
   unsigned short *p;       /* cameras de 1 a 16 bits non signes */
   double exptime=0.;
   double ra, dec;
   int status;
   struct camprop *cam;
   Tcl_Interp *interp;

   cam = (struct camprop *) clientData;
   interp = cam->interpCam;
   strcpy(errorMessage,"");

   // Information par defaut concernant l'image
   // ATTENTION : la camera peut mettre a jour ces valeurs pendant l'execution de read_ccd()
   strcpy(cam->pixels_classe, "CLASS_GRAY");
   strcpy(cam->pixels_format, "FORMAT_USHORT");
   strcpy(cam->pixels_compression, "COMPRESS_NONE");
   cam->pixels_reverse_x = 0;
   cam->pixels_reverse_y = 0;
   cam->pixel_data = NULL;
   strcpy(cam->msg,"");
   cam->gps_date = 0;    // mis a 1 par CAM_DRV.read_ccd si la camera a une datation avec GPS
   // allocation par defaut du buffer
   p = (unsigned short *) calloc(cam->w * cam->h, sizeof(unsigned short));

   libcam_GetCurrentFITSDate(cam->interpCam, cam->date_end);


   //  capture
   // TODO 2 : une autre solution serait de passer l'adresse de p  comme ceci :
   // CAM_DRV.read_ccd(cam, (unsigned short **)&p);
   // mais il faut modifier toutes les camera !! ( michel pujol)
   CAM_DRV.read_ccd(cam, (unsigned short *) p);

   // si cam->pixel_data n'est pas nul, la camera a mis les pixels dans cam->pixel_data
   if (cam->pixel_data != NULL) {
      if (cam->pixel_data != (void *)-1) {
         // je supprime le buffer par defaut pointe par "p"
         free( p);
         // je fais pointer "p"sur le buffer cree par la camera
         // ATTENTION : le format des donnees est indique dans cam->pixels_classe, cam->pixels_format et cam->pixels_compression
         p =  (unsigned short *) cam->pixel_data;
      }
   }

   if (strlen(cam->msg) == 0) {
      // --- application du miroir horizontal
      if( cam->mirrorh == 1 ) {
         // j'inverse l'orientation de l'image par rapport � un miroir horizontal
         // les pixels seront inverses lors de la recopie dans le buffer par "buf1 setpixels ..."
         if( cam->pixels_reverse_y == 1 ) {
            cam->pixels_reverse_y = 0;
         } else {
            cam->pixels_reverse_y = 1;
         }
      }

      // --- application du miroir vertical
      if( cam->mirrorv == 1 ) {
         // j'inverse l'orientation de l'image par rapport a un miroir vertical
         // les pixels seront inverses lors de la recopie dans le buffer par "buf1 setpixels ..."
         if( cam->pixels_reverse_x == 1 ) {
            cam->pixels_reverse_x = 0;
         } else {
            cam->pixels_reverse_x = 1;
         }
      }

      // Test de l'existence du buffer avant l'acquisition
      // DM: cela permet eventuellement a la fonction read_ccd de creer des
      // mots cles FITS.
      sprintf(s, "buf%d clear", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_WARNING, "error in this command: result='%s'", interp->result);
         sprintf(s, "buf::create %d", cam->bufno);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in the command '%s': result='%s'", __LINE__, s, interp->result);
         }
      }

      //--- set pixels to buffer
      //--- setPixels usage :
      //  required parameters :
      //      class       CLASS_GRAY|CLASS_RGB|CLASS_3D|CLASS_VIDEO
      //      width       columns number
      //      height      lines number
      //      format      FORMAT_BYTE|FORMAT_SHORT|FORMAT_uSHORT|FORMAT_FLOAT
      //      compression COMPRESS_NONE|COMPRESS_I420|COMPRESS_JPEG|COMPRESS_RAW
      //      pixelData   pointer to pixels data  (if pixelData is null, set a black image )
      //  optional parameters
      //      -keep_keywords  keep previous keywords of the buffer
      //      -pixelSize   size of pixelData (if COMPRESS_JPEG,COMPRESS_RAW because with and height are unknown)
      //      -reverseX    if "1" , apply vertical mirror
      //      -reverseY    if "1" , apply horizontal mirror
      // ---
      sprintf(s, "buf%d setpixels %s %d %d %s %s %ld -pixels_size %lu -reverse_x %d -reverse_y %d -keep_keywords",
         cam->bufno, cam->pixels_classe, cam->w, cam->h, cam->pixels_format, cam->pixels_compression ,
                  (long)(void *) p, cam->pixel_size, cam->pixels_reverse_x, cam->pixels_reverse_y);
      /*
      sprintf(s, "buf%d setpixels %s %d %d %s %s %d -pixels_size %lu -reverse_x %d -reverse_y %d",
         cam->bufno, cam->pixels_classe, cam->w, cam->h, cam->pixels_format, cam->pixels_compression ,
         (int)(void *) p, cam->pixel_size, cam->pixels_reverse_x, cam->pixels_reverse_y);
      */
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         sprintf(errorMessage,"Errors setpixels: %s", interp->result);
      }

      //--- get height after decompression .
      //--- Indispensable pour recuperer la taille relle de l'image
      //--- en particulier pour les APN ou l'utilisateur peut changer le format de l'image
      sprintf(s, "buf%d getpixelsheight", cam->bufno);
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_OK) {
         Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &cam->h);
      } else {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         sprintf(errorMessage,"Errors getpixelsheight: %s", interp->result);
      }

      //--- get width after decompression
      sprintf(s, "buf%d getpixelswidth", cam->bufno);
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_OK) {
         Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &cam->w);
      } else {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }


      //--- Add FITS keywords
      if ( strcmp(cam->pixels_classe, "CLASS_GRAY")==0 ) {
         // cas d'une image 2D en niveau de gris
         sprintf(s, "buf%d setkwd {NAXIS 2 int \"\" \"\"}", cam->bufno);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, cam->w);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, cam->h);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
      } else if ( strcmp(cam->pixels_classe, "CLASS_RGB")==0 ) {
         // cas d'une image 2D RGB
         sprintf(s, "buf%d setkwd {NAXIS 3 int \"\" \"\"}", cam->bufno);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, cam->w);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, cam->h);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd {NAXIS3 3 int \"\" \"\"}", cam->bufno);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
      }



      sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, cam->binx);
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }
      sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, cam->biny);
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }
      sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->date_obs);
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }
      sprintf(s, "buf%d setkwd {DATE-END %s string \"\" \"\"}", cam->bufno, cam->date_end);
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }
      if (cam->timerExpiration != NULL) {
         sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, cam->exptime);
      } else {
         sprintf(s, "expr (([mc_date2jd %s]-[mc_date2jd %s])*86400.)", cam->date_end, cam->date_obs);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         exptime = atof(interp->result);
         sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, exptime);
      }
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }

      if (cam->gps_date == 1) {
         sprintf(s, "buf%d setkwd [list GPS-DATE 1 int {1 if datation is derived from GPS, else 0} {}]", cam->bufno);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd {CAMERA \"%s+GPS %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }

      } else {
         sprintf(s, "buf%d setkwd [list GPS-DATE 0 int {1 if datation is derived from GPS, else 0} {}]", cam->bufno);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         sprintf(s, "buf%d setkwd [list CAMERA {%s %s %s} string {} {}]", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
      }

      // je soustrais le dark
      if ( cam->darkBufNo != 0 ) {
         sprintf(s, "buf%d sub %d", cam->bufno, cam->darkBufNo );
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
            sprintf(errorMessage,"Error substract dark: %s", interp->result);
         }
      }



      /* - call the header proc to add additional informations -*/
      if ( cam->headerproc[0] != 0 ) {
         sprintf(s,"set libcam(header) [%s]",cam->headerproc);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
         }
         if (atoi(interp->result)==0) {
            sprintf(s, "foreach header $libcam(header) { buf%d setkwd $header }", cam->bufno);
            libcam_log(LOG_DEBUG, s);
            if (Tcl_Eval(interp, s) == TCL_ERROR) {
               libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
            }
         }
      }
      if ( cam->radecFromTel  == 1 ) {
         libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
         //printf("libcam.c: libcam_get_tel_coord:status=%d\n", status);
         if (status == 0) {
            // Add FITS keywords
            sprintf(s, "buf%d setkwd {RA %7.3f float \"Right ascension telescope encoder\" \"\"}", cam->bufno, ra);
            libcam_log(LOG_DEBUG, s);
            Tcl_Eval(interp, s);
            sprintf(s, "buf%d setkwd {DEC %7.3f float \"Declination telescope encoder\" \"\"}", cam->bufno, dec);
            libcam_log(LOG_DEBUG, s);
            Tcl_Eval(interp, s);
         }
      }
   } else {
      // erreur d'acquisition, on enregistre une image vide
      sprintf(s, "buf%d clear", cam->bufno );
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
      }
   }

   free(p);

   if (cam->timerExpiration != NULL) {
      setCameraStatus(cam,interp,"stand");
   }
   cam->clockbegin = 0;

   if (cam->timerExpiration != NULL) {
      Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
      free(cam->timerExpiration);
      cam->timerExpiration = NULL;
   }

   if ( cam->blockingAcquisition == 1 ) {
      // je prepare le message d'erreur qui sera retourne par cmdCamAcq
      strcpy(cam->msg,errorMessage);
   }
   // je signale a cmdCamAcq que l'acquisition est terminée
   cam->acquisitionInProgress = 0;
}


/*
 * cmdCamAcq()
 * Commande de demarrage d'une acquisition.
 */
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[100];
   int i;
   struct camprop *cam;
   int result = TCL_OK;

   if (argc != 2 && argc != 3) {
      sprintf(ligne, "Usage: %s %s ?-blocking?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam = (struct camprop *) clientData;
      if ( argc == 3 ) {
         cam->blockingAcquisition = 1;
      } else {
         cam->blockingAcquisition = 0;
      }

      if (cam->timerExpiration == NULL) {
         /* Pour avertir les gens du status de la camera. */
         //setCameraStatus(cam,interp,"exp");

         // set current interp for multithread
         cam->interpCam = interp;
         cam->exptimeTimer = cam->exptime;
         cam->timerExpiration = (struct TimerExpirationStruct *) calloc(1, sizeof(struct TimerExpirationStruct));
         cam->timerExpiration->clientData = clientData;
         cam->timerExpiration->interp = interp;
         strcpy(cam->msg,"");

         Tcl_Eval(interp, "clock seconds");
         cam->clockbegin = (unsigned long) atoi(interp->result);

         CAM_DRV.start_exp(cam, "amplioff");

         if(strcmp(cam->msg,"")!= 0 ) {
            // erreur pendant start_exp
            if (cam->timerExpiration != NULL) {
               Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
               free(cam->timerExpiration);
               cam->timerExpiration = NULL;
            }
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            // je teste cam->timerExpiration car il peut etre nul si cmdCamStop a ete appele entre temps
            if( cam->timerExpiration != NULL ) {
               libcam_GetCurrentFITSDate(cam->interpCam, cam->date_obs);
               /* Creation du timer pour realiser le temps de pose. */
               i = (int) (1000 * cam->exptimeTimer);
               cam->timerExpiration->TimerToken = Tcl_CreateTimerHandler(i, AcqRead, (ClientData) cam);
            } else {
               Tcl_SetResult(interp, "", TCL_VOLATILE);
               result = TCL_OK;
            }

            if(cam->blockingAcquisition == 1 ) {
               // j'attend la fin de l'acquisition
               int foundEvent = 1;
               cam->acquisitionInProgress = 1;
               while (cam->acquisitionInProgress != 0 && foundEvent) {
                  foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                  //if (Tcl_LimitExceeded(interp)) {
                  //   break;
                  //}
               }
               if( cam->timerExpiration != NULL ) {
                  Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
                  if (cam->timerExpiration != NULL) {
                     free(cam->timerExpiration);
                     cam->timerExpiration = NULL;
                  }
               }
               if ( cam->msg[0] != 0 ) {
                  // je transmet le message d'erreure au scipt TCL
                  Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
                  result = TCL_ERROR;
               } else {
                  Tcl_SetResult(interp, "", TCL_VOLATILE);
                  result = TCL_OK;
               }
            }
         }
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
    int retour = TCL_OK;

    cam = (struct camprop *) clientData;
    cam->acquisitionInProgress = 2;

    if (cam->timerExpiration != NULL ) {
        Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
        if (cam->timerExpiration != NULL) {
            free(cam->timerExpiration);
            cam->timerExpiration = NULL;
        }
        CAM_DRV.stop_exp(cam);
        AcqRead((ClientData) cam);
    }
    else if ( cam->capabilities.videoMode == 1 ) {
        CAM_DRV.stop_exp(cam);
    }
    else {
        setCameraStatus(cam,interp,"stand");
    }

    return retour;
}

static int cmdCamCapabilities(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "expTimeCommand %d expTimeList %d videoMode %d",
      cam->capabilities.expTimeCommand,
      cam->capabilities.expTimeList,
      cam->capabilities.videoMode
      );
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
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

static int cmdCamProduct(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", CAM_INI[cam->index_cam].product);
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
   int retour;
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if ((argc != 2) && (argc != 4)) {
      sprintf(ligne, "Usage: %s %s ?celldimx? ?celldimy?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else if (argc == 2) {
      sprintf(ligne, "%g %g", cam->celldimx, cam->celldimy);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_OK;
   } else {
      double celldimx, celldimy;
      if (Tcl_GetDouble(interp, argv[2], &celldimx) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?num?\ncelldimx must be a float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_ERROR;
      } else if (Tcl_GetDouble(interp, argv[3], &celldimy) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?num?\ncelldimy must be a float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_ERROR;
      } else {
         cam->celldimx = celldimx;
         cam->celldimy = celldimy;
         sprintf(ligne, "%g %g", cam->celldimx, cam->celldimy);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_OK;
      }
   }
   return retour;


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
   sprintf(ligne, "%s", cam->portname);
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
      cam->nb_photox = CAM_INI[cam->index_cam].maxx;    /* nombre de photosites sur X */
      cam->nb_photoy = CAM_INI[cam->index_cam].maxy;    /* nombre de photosites sur Y */
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
         sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         // je met a jour les coordonnees du fenetrage pour prendre en compte le miroir
         CAM_DRV.update_window(cam);
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
         sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         // je met a jour les coordonnees du fenetrage pour prendre en compte le miroir
         CAM_DRV.update_window(cam);
         Tcl_SetResult(interp, "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   struct camprop *cam;
   char s[256];

   cam = (struct camprop *) clientData;
   if (CAM_DRV.close != NULL) {
      CAM_DRV.close(cam);
   }

   // je supprime la variable globale contenant le status de la camera
   sprintf(s, "status_cam%d", cam->camno);
   Tcl_UnsetVar(interp, s, TCL_GLOBAL_ONLY);
   if ( cam->camThreadId[0] != 0 ) {
      // cas du mutltithread
      // Pas necesaire de changer l'etat de la variable dans la thread de la camera  car la thread est supprimee juste apres
      //sprintf(s, "thread::send -async %s { unset status_cam%d }", cam->camThreadId, cam->camno);
      //Tcl_Eval(interp, s);

      // je supprime la thread de la camera
      if ( strcmp(cam->camThreadId,"")!= 0 ) {
         sprintf(s,"thread::release %s" , cam->camThreadId);
         Tcl_Eval(interp, s);
      }
   }

   // je supprime le buffer du dark
   if ( cam->darkBufNo != 0 ) {
       sprintf(s, "buf::delete %d", cam->darkBufNo);
       Tcl_Eval(interp, s);
   }
   // je supprime le nom du fichier du dark
   if ( cam->darkFileName != NULL ) {
      free(cam->darkFileName);
      cam->darkFileName = NULL;
   }
   Tcl_ResetResult(interp);
   return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamLastError()
 *
 *  retourne le dernier message d'erreur de la camera
 *
 *  cette commande est particulierement utile pour savoir s'il y eu une erreur
 *  pendant une acquisition car la commande "cam1 ne retourne pas d'exception
 *  pour signaler d'eventuelle erreur
 *
 *  param
 *     pas de parametre
 *  return
 *     retourn le dernier message d'erreur, ou une chaine vide s'il n'y a pas d'erreur
 * -----------------------------------------------------------------------------
 */
static int cmdCamLastError(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   int retour = TCL_OK;
   char ligne[1024];
   struct camprop *cam;

   if (argc != 2) {
      sprintf(ligne, "Usage: %s %s", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%s", cam->msg);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return retour;
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
   strcpy(cam->portname,"unknown");
   strcpy(logFileName,"libcam.log");
   if (argc >= 5) {
      // je copie le nom du port en limitant le nombre de caractères à la taille maximal de cam->portname
      strncpy(cam->portname,argv[2], sizeof(cam->portname) -1);
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
         if (strcmp(argv[kk], "-debug_directory") == 0) {
            if ( kk +1 <  argc ) {
               char fileTempName[1024];
               // je conserve le nom du fichier de log
               strcpy(fileTempName,logFileName);
               // je recupere le repertoire du fichier de traces
	            strcpy(logFileName, argv[kk + 1]);
               // je concatene un "/" a la fin du repertoire s'il n'y est pas deja
               if ( logFileName[strlen(logFileName)-1]!= '\\' && logFileName[strlen(logFileName)-1]!= '/' && strlen(logFileName)!=0 ) {
                  strcat(logFileName,"/");
               }
               // je concatene le nom du fichier de trace 
               strcat(logFileName, fileTempName);
#ifdef WIN32
               {
                  unsigned int c;
                  for(c=0; c<strlen(logFileName); c++ ) {
                     if( logFileName[c] == '/' ) {
                        logFileName[c] = '\\';
                     }
                  }
               }
#endif
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
   cam->nb_photox = CAM_INI[cam->index_cam].maxx;   /* nombre de photosites sur X */
   cam->nb_photoy = CAM_INI[cam->index_cam].maxy;   /* nombre de photosites sur Y */
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
   cam->celldimx = CAM_INI[cam->index_cam].celldimx;    /* taille d'un photosite sur X (en metre) */
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;    /* taille d'un photosite sur Y (en metre) */
   cam->fillfactor = CAM_INI[cam->index_cam].fillfactor;    /* fraction du photosite sensible a la lumiere */
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
   cam->port = 0x378;       /* lpt1 par defaut */
   if (argc >= 2) {
      if (strcmp(argv[2], cam_ports[1]) == 0) {
         cam->portindex = 1;
         cam->port = 0x278;
      }
   }
   cam->check_temperature = CAM_INI[cam->index_cam].check_temperature;
   cam->timerExpiration = NULL;
   cam->radecFromTel = 1;
   strcpy(cam->headerproc,"");
   cam->blockingAcquisition = 0;
   //---  valeurs par defaut des capacites offertes par la camera
   cam->capabilities.expTimeCommand = 1;  // existence  du choix du temps de pose
   cam->capabilities.expTimeList    = 0;  // existence  de la liste des temps de pose predefini
   cam->capabilities.videoMode      = 0;  // existence  du mode video
   cam->acquisitionInProgress = 0;
   cam->gps_date = 0;
   cam->darkBufNo = 0;                // buffer contenant l'image du dark a soustraire apres chaque acquisition
   cam->darkFileName = NULL;
   return 0;
}

static int cmdCamDebug(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1|2|3|4?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", debug_level);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      cam = (struct camprop *) clientData;
      if (Tcl_GetInt(interp, argv[2], &debug_level) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1|2|3|4?\n   Value must be 0 to 4", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp, "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}



void setCameraStatus(struct camprop *cam, Tcl_Interp * interp, char * status)
{
   char s[256];
   sprintf(s, "status_cam%d", cam->camno);
   Tcl_SetVar(interp, s, status, TCL_GLOBAL_ONLY);
   if ( cam->camThreadId[0] != 0 ) {
      // cas du mutltithread
      // je change l'etat de la variable dans la thread principale
      sprintf(s, "thread::send -async %s { set ::status_cam%d {%s} }", cam->mainThreadId, cam->camno, status);
      Tcl_Eval(interp, s);
   }
}

void setScanResult(struct camprop *cam, Tcl_Interp * interp, char * status)
{
   char s[256];
   sprintf(s, "scan_result%d", cam->camno);
   Tcl_SetVar(interp, s, status, TCL_GLOBAL_ONLY);
   if ( cam->camThreadId[0] != 0 ) {
      // cas du mutltithread
      // je change l'etat de la variable dans la thread principale
      sprintf(s, "thread::send -async %s { set ::scan_result%d {%s} }", cam->mainThreadId, cam->camno, status);
      Tcl_Eval(interp, s);
   }
}

static int cmdCamDark(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[1024];
   int result = TCL_OK;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?filename? ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      // je retourne le nom du fichier
      struct camprop *cam = (struct camprop *) clientData;
      if ( cam->darkFileName == NULL) {
         Tcl_SetResult(interp, "", TCL_VOLATILE);;
      } else {
         Tcl_SetResult(interp, cam->darkFileName, TCL_VOLATILE);
      }
      result = TCL_OK;
   } else {
      struct camprop *cam = (struct camprop *) clientData;

      // je supprime le buffer
      if ( cam->darkBufNo != 0 ) {
          sprintf(ligne, "buf::delete %d", cam->darkBufNo);
          if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
            sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], interp->result );
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            cam->darkBufNo = 0;
            Tcl_SetResult(interp, "", TCL_VOLATILE);
            result = TCL_OK;
         }
      }
      // je supprime le nom du fichier
      if ( cam->darkFileName != NULL ) {
         free(cam->darkFileName);
         cam->darkFileName = NULL;
      }

      if ( strcmp(argv[2],"") != 0) {
         // je cree le buffer
         if ( cam->darkBufNo == 0 ) {
            sprintf(ligne, "buf::create");
            if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
               sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], interp->result );
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               cam->darkBufNo = atoi(interp->result);
            }
         }
         // je charge l'image
         if ( result==TCL_OK) {
            sprintf(ligne, "buf%d load {%s}", cam->darkBufNo,argv[2]);
            if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
               sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], interp->result );
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               // je verifie que le dark a les memes dimensions que le capteur de la camera
               sprintf(ligne, "buf%d getpixelswidth", cam->darkBufNo);
               if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
                  sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], interp->result );
                  Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                  result = TCL_ERROR;
               } else {
                  int darkWidth = atoi(interp->result);
                  if ( darkWidth != cam->nb_photox / cam->binx ) {
                     sprintf(ligne, "%s %s %s \nError : dark width (%d) is different from camera width (%d)",
                        argv[0], argv[1], argv[2], darkWidth, cam->nb_photox / cam->binx);
                     Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                     result = TCL_ERROR;
                  }
               }
               if ( result == TCL_OK) {
                  sprintf(ligne, "buf%d getpixelsheight", cam->darkBufNo);
                  if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
                     sprintf(ligne, "%s %s %s \nError :%s", argv[0], argv[1], argv[2], interp->result );
                     Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                     result = TCL_ERROR;
                  } else {
                     int darkHeight = atoi(interp->result);
                     if ( darkHeight != cam->nb_photoy / cam->biny ) {
                        sprintf(ligne, "%s %s %s : dark width (%d) is different from camera width (%d) ",
                           argv[0], argv[1], argv[2], darkHeight, cam->nb_photoy / cam->biny);
                        Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                        result = TCL_ERROR;
                     }
                  }
               }
               if ( result == TCL_OK) {
                  // je memorise le nom du fichier
                  if ( cam->darkFileName != NULL ) {
                     free(cam->darkFileName);
                     cam->darkFileName = NULL;
                  }
                  cam->darkFileName = (char*) malloc(strlen(argv[2])+1);
                  strcpy(cam->darkFileName, argv[2]);
                  Tcl_SetResult(interp, "", TCL_VOLATILE);
               } else {
                  // je supprime le buffer
                  if ( cam->darkBufNo != 0 ) {
                     sprintf(ligne, "buf::delete %d", cam->darkBufNo);
                     Tcl_Eval(interp, ligne);
                     cam->darkBufNo = 0;
                  }
                  // je supprime le nom du fichier
                  if ( cam->darkFileName != NULL ) {
                     free(cam->darkFileName);
                     cam->darkFileName = NULL;
                  }

               }
            }
         }
      }
   }
   return result;
}

int cmdCamAvailable(struct camprop *cam, Tcl_Interp * interp, int argc, const char *argv[])
{
#ifdef CMD_CAM_AVAILABLE
   int result;
   // cette commande n'est utilisable que par les cameras qui
   // sont compilés avec l'option CMD_CAM_AVAILABLE
   char * ligne = NULL;
   // ligne is allocated by cam_getAvailableCameraList()
  if( webcam_getAvailableCameraList(&ligne) == 0 ) {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_OK;
   } else {
      // la variable "ligne" contient le message d'erreur
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   free(ligne);
   return result;
#else
   Tcl_SetResult(interp, "command \"available\" not implemented for this camera", TCL_VOLATILE);
   return TCL_ERROR;
#endif
}

