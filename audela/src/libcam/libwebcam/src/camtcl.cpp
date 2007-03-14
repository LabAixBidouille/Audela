/** @file camtcl.c
 *
 * Functions C-Tcl specifics for this camera.
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
#include <math.h>
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

#if defined(OS_WIN)
#include "GuidingCapture.h"
#endif

#if defined(OS_LIN)
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/ppdev.h>
#include <linux/parport.h>
#include <errno.h>
#endif

/* --- Global variable for TDI acquisition mode ---*/
// ScanStruct *TheScanStruct = NULL;

/**
 *  cmdCamClose.
 *  Ferme la caméra                                
 *  
 *  close the camera.
 */
#if 0
int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc,
                char *argv[])
{
   struct camprop *cam;

   cam = (struct camprop *) clientData;

#if defined(OS_WIN)
   if (cam->capture != NULL) {
      delete cam->capture;
      cam->capture = NULL;
   }  

#if !defined(OS_WIN_USE_LPT_OLD_STYLE)
   if (cam->hLongExposureDevice != INVALID_HANDLE_VALUE) {
      CloseHandle(cam->hLongExposureDevice);
      cam->hLongExposureDevice = INVALID_HANDLE_VALUE;
   }
#endif

#endif

#if defined(OS_LIN)
   if (cam->cam_fd >= 0) {
      close(cam->cam_fd);
      cam->cam_fd = -1;
   }
   if (cam->long_fd >= 0) {
      webcam_setLongExposureDevice(cam, cam->longueposestop);
      ioctl(cam->long_fd, PPRELEASE);
      close(cam->long_fd);
      cam->long_fd = -1;
   }

   if (cam->rgbBuffer != NULL) {
      free(cam->rgbBuffer);
      cam->rgbBuffer = NULL;
   }
   cam->rgbBufferSize = 0;

   if (cam->yuvBuffer != NULL) {
      free(cam->yuvBuffer);
      cam->yuvBuffer = NULL;
   }
   cam->yuvBufferSize = 0;

//   printf("camera close\n");

#endif

   return TCL_OK;
}
#endif

/**
 * cmdCamVideoSource.
 * Réglage des paramètres de la caméra
 *
 * Under Linux it calls <b>::confCam::confVideoSource</b> command
 * and shows VideoSource window dialog.
*/
int cmdCamVideoSource(ClientData clientData, Tcl_Interp * interp, int argc,
                      char *argv[])
{
#if defined(OS_WIN)
   HWND hWnd = NULL;
#endif

#if defined(OS_LIN)
   int num;
   char ligne[128];
#endif

   struct camprop *cam;

   cam = (struct camprop *) clientData;

#if defined(OS_LIN)
   sscanf(argv[0], "cam%d", &num);
   sprintf(ligne, "::confCam::confVideoSource %d", num);
   Tcl_Eval(interp, ligne);
#endif

#if defined(OS_WIN)

   if (cam->capture == NULL) {
      return TCL_ERROR;
   } else {
      cam->capture->openDlgVideoSource();
   }
#endif
   return TCL_OK;
}

/**
 * cmdCamGetVideoSource - returns specified camera settings.
 * Implemented for Linux, use with many options.
*/
int cmdCamGetVideoSource(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
   struct camprop *cam;
   int result = TCL_OK;

#if defined(OS_LIN)
   char returnValue[512], *curValue;
   int i, n;
   char commands[] =
      "-restoreUser -restoreFactory -picSettings -gain -sharpness -shutter -noise -compression -whiteBalance -backlight -flicker";
#endif

   cam = (struct camprop *) clientData;

#if defined(OS_LIN)
   strcpy(returnValue, "");
   curValue = returnValue;

   /* decode the options */
   for (i = 2; i < argc; i++) {
      if ((n = strlen(returnValue)) > 0) {
         curValue = returnValue + n;
         sprintf(curValue, " ");
         curValue++;
      }
      if (strcmp(argv[i], "-restoreUser") == 0) {
         if (webcam_getVideoSource(cam, curValue, RESTOREUSER)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-picSettings") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETPICSETTINGS)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-restoreFactory") == 0) {
         if (webcam_getVideoSource(cam, curValue, RESTOREFACTORY)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-gain") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETGAIN)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-sharpness") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETSHARPNESS)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-shutter") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETSHUTTER)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-noise") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETNOISE)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-compression") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETCOMPRESSION)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-whiteBalance") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETWHITEBALANCE)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-backlight") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETBACKLIGHT)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-flicker") == 0) {
         if (webcam_getVideoSource(cam, curValue, GETFLICKER)) {
            strcpy(returnValue, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }

      sprintf(returnValue, "%s - command unknown. Possible commands: %s",
              argv[i], commands);
      result = TCL_ERROR;
      break;
   }

   if (argc <= 2) {
      sprintf(returnValue, "%s - possible commands: %s",
              argv[1], commands);
      result = TCL_ERROR;
   }

   Tcl_SetResult(interp, returnValue, TCL_VOLATILE);
#endif
   return result;
}


/**
 * cmdCamSetVideoSource - sets specified camera settings.
 * Implemented for Linux, use with many options.
*/
int cmdCamSetVideoSource(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
   struct camprop *cam;
   int result = TCL_OK;

#if defined(OS_LIN)
   char ligne[512], mode[64];
   int i;
   int brightness = 0, contrast = 0, colour = 0, whiteness = 0, param =
      0, red = 0, blue = 0;
   char commands[] =
      "-saveUser -picSettings -gain -sharpness -shutter -noise -compression -whiteBalance -backlight -flicker";
#endif

   cam = (struct camprop *) clientData;

#if defined(OS_LIN)
   strcpy(ligne, "");

   /* decode the options */
   for (i = 2; i < argc; i++) {
      if (strcmp(argv[i], "-saveUser") == 0) {
         if (webcam_saveUser(cam)) {
            strcpy(ligne, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-picSettings") == 0) {
         if (argc > (i + 4)) {
            brightness = atoi(argv[++i]);
            contrast = atoi(argv[++i]);
            colour = atoi(argv[++i]);
            whiteness = atoi(argv[++i]);
            if (brightness >= 0 && brightness <= 65535
                && contrast >= 0 && contrast <= 65535
                && colour >= 0 && colour <= 65535
                && whiteness >= 0 && whiteness <= 65535) {
               if (webcam_setPicSettings
                   (cam, brightness, contrast, colour, whiteness)) {
                  strcpy(ligne, cam->msg);
                  result = TCL_ERROR;
                  break;
               }
            } else {
               strcpy(ligne,
                      "-picSettings - bad arguments, must be numbers");
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-picSettings - not enough arguments\n%s",
                    "Usage: -picSettings brightness contrast colour whiteness");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-gain") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETGAIN)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-gain - not enough arguments\n%s",
                    "Usage: -gain gainValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-sharpness") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETSHARPNESS)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-sharpness - not enough arguments\n%s",
                    "Usage: -sharpness sharpnessValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-shutter") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETSHUTTER)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-shutter - not enough arguments\n%s",
                    "Usage: -shutter shutterValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-noise") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETNOISE)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-noise - not enough arguments\n%s",
                    "Usage: -noise noiseValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-compression") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETCOMPRESSION)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-compression - not enough arguments\n%s",
                    "Usage: -compression compressionValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-whiteBalance") == 0) {
         if (argc > (i + 1)) {
            i++;
            strcpy(mode, argv[i]);
            if (strcmp(mode, "manual") == 0) {
               if (argc > (i + 2)) {
                  red = atoi(argv[++i]);
                  blue = atoi(argv[++i]);
                  if (!(red >= 0 && red <= 65535
                        && blue >= 0 && blue <= 65535)) {
                     strcpy(ligne,
                            "-whiteBalance manual - arguments must be numbers");
                     result = TCL_ERROR;
                     break;
                  }
               } else {
                  sprintf(ligne,
                          "-whiteBalance manual - not enough arguments\n%s",
                          "Usage: -whiteBalance manual redLevel blueLevel");
                  result = TCL_ERROR;
                  break;
               }
            }
            if (webcam_setWhiteBalance(cam, mode, red, blue)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-whiteBalance - not enough arguments\n%s%s",
                    "Usage: -whiteBalance whiteMode ?params?\n",
                    "you can use modes: manual, auto, indoor, outdoor, fl");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-backlight") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETBACKLIGHT)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-backlight - not enough arguments\n%s",
                    "Usage: -backlight 0|1");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-flicker") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoSource(cam, param, SETFLICKER)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-flicker - not enough arguments\n%s",
                    "Usage: -flicker 0|1");
            result = TCL_ERROR;
            break;
         }
         continue;
      }

      sprintf(ligne, "%s - command unknown. Possible commands: %s",
              argv[i], commands);
      result = TCL_ERROR;
      break;
   }

   if (argc <= 2) {
      sprintf(ligne, "%s - possible commands: %s", argv[1], commands);
      result = TCL_ERROR;
   }

   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
#endif
   return result;
}


/**
 *  cmdCamVideoFormat -  Réglage des paramètres de la caméra.
 *
 *  Under Linux it shows a window dialog where you can
 *  chose image format.
*/
int cmdCamVideoFormat(ClientData clientData, Tcl_Interp * interp, int argc,
                      char *argv[])
{
   struct camprop *cam;

#if defined(OS_LIN)
   char ligne[128];
   int num;
#endif

   cam = (struct camprop *) clientData;

#if defined(OS_LIN)
   sscanf(argv[0], "cam%d", &num);
   sprintf(ligne, "::confCam::confvideoformat %d", num);
   Tcl_Eval(interp, ligne);
#endif

#if defined(OS_WIN)
   if (argc >= 3) {
      webcam_videoformat(cam, argv[2]);
   } else {
      webcam_videoformat(cam, "");
   }
#endif

   return TCL_OK;
}

/**
 * cmdCamSetVideoFormat - implemented under Linux.
 * Sets image format, argument must be format name (one of):
 * - SQCIF - 128x96
 * - QSIF - 160x120
 * - QCIF - 176x144 
 * - SSIF  - 240x176
 * - SIF - 320x240 
 * - CIF - 352x288
 * - VGA - 640x480.
*/
int cmdCamSetVideoFormat(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{

   int result = TCL_OK;

#if defined(OS_LIN)
   char ligne[128];
   struct camprop *cam;

   cam = (struct camprop *) clientData;

   if (argc == 3) {
      if (webcam_videoformat(cam, argv[2])) {
         strcpy(ligne, cam->msg);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   } else {
      sprintf(ligne, "Usage: %s %s format_name", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   }
#endif

   return result;
}

/**
 * cmdCamGetVideoFormat - implemented under Linux.
 * It returns actual video format.
*/
int cmdCamGetVideoFormat(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{

#if defined(OS_LIN)
   char ligne[128], format[32];
   struct camprop *cam;

   cam = (struct camprop *) clientData;

   if (cam->imax == 640 && cam->jmax == 480)
      strcpy(format, "VGA");
   else if (cam->imax == 352 && cam->jmax == 288)
      strcpy(format, "CIF");
   else if (cam->imax == 320 && cam->jmax == 240)
      strcpy(format, "SIF");
   else if (cam->imax == 240 && cam->jmax == 176)
      strcpy(format, "SSIF");
   else if (cam->imax == 176 && cam->jmax == 144)
      strcpy(format, "QCIF");
   else if (cam->imax == 160 && cam->jmax == 120)
      strcpy(format, "QSIF");
   else if (cam->imax == 128 && cam->jmax == 96)
      strcpy(format, "SQCIF");
   else
      strcpy(format, "");

   sprintf(ligne, "%s %dx%d", format, cam->imax, cam->jmax);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
#endif

   return TCL_OK;
}

/**
 * cmdCamLonguePose - Réglage du mode longue pose.
 *
 * Declare if use long or normal exposure,
 * with no parameters returns actual setting.
*/
int cmdCamLonguePose(ClientData clientData, Tcl_Interp * interp, int argc,
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
      if (strcmp(argv[2], "0") == 0) {
         cam->longuepose = 0;
         pb = 0;
      } else if (strcmp(argv[2], "1") == 0) {
         cam->longuepose = 1;
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
      sprintf(ligne, "%d", cam->longuepose);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

/**
 * cmdCamLonguePoseLinkno
 * Change or returns the long exposure port name (long exposure device).
*/
int cmdCamLonguePoseLinkno(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if (argc != 2 && argc != 3) {
      sprintf(ligne, "Usage: %s %s ?linkno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else  if (argc == 2 ) {
      // je retourne le numero du link
      sprintf(ligne,"%d",cam->longueposelinkno);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
   } else {
      // je memorise le numero du link
      if(Tcl_GetInt(interp,argv[2],&cam->longueposelinkno)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s linkno\n linkno = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } 
   }
   return result;
}


/**
 * cmdCamLonguePoseLinkbit
 * Changes or returns the bit number 
*/
int cmdCamLonguePoseLinkbit(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if (argc != 2 && argc != 3) {
      sprintf(ligne, "Usage: %s %s ?numbit", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else  if (argc == 2 ) {
      // je retourne le numero du bit
      sprintf(ligne,"%d",cam->longueposelinkbit);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
   } else {
      // je memorise le numero du bit
      if(Tcl_GetInt(interp,argv[2],&cam->longueposelinkbit)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s  numbit\n numbit = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } 
   }
   return result;
}



/**
 * cmdCamLonguePoseStartValue - définition du caractere de debut de pose.
*/
int cmdCamLonguePoseStartValue(ClientData clientData, Tcl_Interp * interp,
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
      cam->longueposestart = (int) atoi(argv[2]);
      pb = 0;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ?decimal_number?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam->longueposestart);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

/**
 * cmdCamLonguePoseStopValue - définition du caracter de fin de pose.
*/
int cmdCamLonguePoseStopValue(ClientData clientData, Tcl_Interp * interp,
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
      cam->longueposestop = (int) atoi(argv[2]);
      pb = 0;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ?decimal_number?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam->longueposestop);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

/**
 * cmdCamValidFrame - set valid frame number.
 * Possible arguments:
 * - no argument - returns actual setting,
 * - number > 0 - set valid frame on number,
 * - number = 0 - set auto detection mode.
*/
int cmdCamValidFrame(ClientData clientData, Tcl_Interp * interp, int argc,
                     char *argv[])
{

   int result = TCL_OK;

#if defined(OS_LIN)
   char ligne[256];
   int pb = 0, value;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   value = cam->validFrame;

   if ((argc < 2) || (argc > 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      if ((value = atoi(argv[2])) < 0)
         pb = 1;
      else
         pb = 0;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ?valid_frame_number?\n - %s",
              argv[0], argv[1], "if = 0 autodetection");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam->validFrame = value;
      sprintf(ligne, "%d", cam->validFrame);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }

#endif

   return result;
}



/******************************************************************/
/*  Fonctions d'affichage et de capture video (M. Pujol)          */
/*                                                                */
/*  Pour Windows uniquement                                       */
/******************************************************************/
#if defined(OS_WIN)
/******************************************************************/

/**
 *  cmdCamStartVideoView
 *  active l'affichage de la video (preview)
 *
 *  Parametres :
 *    imgno : numero de l'image de type "video" dans laquelle est affichee la video
 */
int cmdCamStartVideoView(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   int imgno;
   WORD previewRate = 33;

   cam = (struct camprop *) clientData;

   if ( argc != 3) {
      sprintf(ligne, "Usage: %s %s ?imgno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      // je recupere le numero de l'image dans laquelle va etre affichee la video
      imgno = (int) atoi(argv[2]);
      // je verifie que l'image est du type "video"
      sprintf(ligne, "image type image%d", imgno);
      if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
         // l'image n'existe pas
         sprintf(ligne, "Error connect webcam to image%d : %s", imgno, Tcl_GetStringResult(interp) );
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      } else { 
         if ( strcmp(Tcl_GetStringResult(interp), "video") != 0 ) {
            // l'image n'est du type video
            sprintf(ligne, "Error connect webcam to image%d : %s wrong image type, must be video", imgno, Tcl_GetStringResult(interp) );
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
   }

   if( cam->capture->isPreviewEnabled() == 1 ) {
      sprintf(ligne, "view already in use");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   // je connecte la fenetre de visualisation a l'image TK
   sprintf(ligne, "image%d configure -source %ld", imgno, (long)cam->capture->getHwndCapture());
   if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
      // je retourne le message d'erreur fourni par l'interpreteur
      sprintf(ligne, "Error configure image%d : %s", imgno, Tcl_GetStringResult(interp) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   cam->videonum = imgno;


   if ( startVideoPreview(cam, previewRate) == TRUE ) {
      return TCL_OK;
   } else {
      return TCL_ERROR;
   }
 
}

/**
 *  cmdCamStopVideoView
 *  arrete l'affichage de la video (preview)
 *
 *  Parametres :
 *    aucun
 */
int cmdCamStopVideoView(ClientData clientData, Tcl_Interp * interp, int argc,
                char *argv[])
{
   struct camprop *cam;
   char ligne[256];

   cam = (struct camprop *) clientData;

   if( cam->capture->isPreviewEnabled() == 0 ) {
      // preview is already stopped
      return TCL_OK;
   }

   // je deconnecte la fenetre de visualisation de l'image TK
   sprintf(ligne, "image%d configure -source %ld", cam->videonum, 0);
   Tcl_Eval(interp, ligne);


   stopVideoPreview(cam);


   return TCL_OK;
}




/**
 *  cmdCamStartVideoCapture
 *  demarre une aquisition video avec enregistrement dans un fichier AVI
 *
 *  Parametres :
 *    filename :  nom du fichier AVI (chemin complet avec l'extension) 
 *    exptime  :  duree de la capture en secondes
 *    framerate:  frequence des images en image/seconde
 *    preallocdisk : pre-allouer le fichier sur disque (1=oui, 0=non)
 *    
 */
int cmdCamStartVideoCapture(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   
   unsigned long microSecPerFrame;
   double frameRate;
   unsigned short exptime;
   int result;
   char fileName [_MAX_PATH];
   int  bPreallocDisk;
   //unsigned long  fileSize;

   cam = (struct camprop *) clientData;

   sprintf(ligne, "%ld %ld", cam->capture->getCaptureRate() , cam->capture->getTimeLimit());

   if ( argc != 6) {
      sprintf(ligne, "Usage: %s %s ?filename? ?exptime? ?framerate? ?preallocdisk?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      // je recupere le nom du fichier
      strcpy(fileName, argv[2]);

      // je recupere la duree de la capture (en secondes)
      exptime =  atoi(argv[3]);
      if( exptime == 0 ) {
         sprintf(ligne, "exptime=\"%s\"  is null or invalid ", argv[3]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      }

      // je recupere la freqence des images (en image par seconde)
      frameRate = (double) (1. * atoi(argv[4]));

      if( frameRate == 0. ) {
         sprintf(ligne, "Error : frameRate is null or invalid");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      }

      // je transforme la fréquence en periode ( en micro-seconde par image)
      if (frameRate < 0.0001) {
		   microSecPerFrame = 0L;
	   } else {
		   microSecPerFrame = (DWORD) /*floor*/((1e6 / frameRate) + 0.5);
      }

      // je recupere le flag de preallocation de l'espace disque
      if ( strcmp(argv[5], "1") == 0 ) {
         bPreallocDisk = 1;
      } else  {
         bPreallocDisk = 0;
      }
   }
    
   if( cam->capture->isCapturingNow() == 1 ) {
      sprintf(ligne, "capture already in use");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   result = startVideoCapture(cam, exptime, microSecPerFrame, fileName);
   
   if(result == TRUE ) {
         result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }

   return result;
}

/**
 *  cmdCamStopVideoCapture
 *  arrete une aquisition video dans un fichier AVI
 *
 *  Parametres :
 *    aucun
 */
int cmdCamStopVideoCapture(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{   
   struct camprop *cam;
   int result;

   cam = (struct camprop *) clientData;

   if( cam->capture->isCapturingNow() == 0 ) {
      // rien a faire la capture est deja arretee
      result = TCL_OK;
   }

   // j'arrete la capture
   if(stopVideoCapture(cam) == TRUE ) {
      result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }


   return result;
}

/**
 * cmdCamSetVideoSatusVariable.
 * declare la variable TCL 
 *
 *  Parametres :
 *    variable : nom de la variable TCL qui reçoit le status pendant la capture
 */
int cmdCamSetVideoSatusVariable(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   if (argc != 3) {
      sprintf(ligne, "Usage: %s %s variable ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      // store the TCL variable name
      cam->captureListener->setTclStatusVariable(argv[2]);
      result = TCL_OK;
   }
   return result;
}


/**
 *  cmdCamStartVideoCrop
 *  demarre le mode d'acquisition video fenetree
 *
 *  Parametres :
 *    
 */
int cmdCamStartVideoCrop(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   int result;
   char ligne[256];
   struct camprop *cam;
   
   cam = (struct camprop *) clientData;
    
   if( cam->cropCapture != NULL ) {
      sprintf(ligne, "cropped preview already enable");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   result = startVideoCrop(cam);

   if(result == TRUE ) {
         result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }

   return result;
}

/**
 *  cmdCamStopVideoCrop
 *  arrete le mode d'acquisition video fenetree
 *
 *  Parametres :
 *    
 */
int cmdCamStopVideoCrop(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   int result;
   char ligne[256];
   struct camprop *cam;
   
   cam = (struct camprop *) clientData;
    
   if( cam->cropCapture == NULL ) {
      sprintf(ligne, "cropped preview already disabled");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   result = stopVideoCrop(cam);

   if(result == TRUE ) {
         result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }

   return result;
}



/**
 *  cmdCamSetVideoCropRect
 *  change la taille de la fenetre d'acquisition video fenetree
 *
 *  Parametres :
 *    
 */
int cmdCamSetVideoCropRect(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   int result;
   char ligne[256];
   struct camprop *cam;
   long     x1, y1, x2, y2;   
   
   cam = (struct camprop *) clientData;
    
   if( cam->cropCapture == NULL ) {
      sprintf(ligne, "cropped mode is disabled");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   if ( argc != 6) {
      sprintf(ligne, "Usage: %s %s x1 y1 x2 y2 ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   
   x1    =  atol(argv[2]);
   y1    =  atol(argv[3]);
   x2    =  atol(argv[4]);
   y2    =  atol(argv[5]);
   

   result = setVideoCropRect(cam, x1, y1, x2, y2);

   if(result == TRUE ) {
      result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }

   return result;
}


/**
 *  cmdCamStartVideoGuiding
 *  demarre le mode d'acquisition video fenetree
 *
 *  Parametres :
 *    
 */
int cmdCamStartVideoGuiding(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   
   cam = (struct camprop *) clientData;
    
   if( cam->guidingCapture != NULL ) {
      sprintf(ligne, "guiding preview already enable");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   cam->guidingListener = new CGuidingListener(interp);
   cam->guidingCapture = new CGuidingCapture(cam->capture);
   cam->guidingCapture->setGuidingListener(cam->guidingListener);
   cam->guidingCapture->startPreview();

   return TCL_OK;
}

/**
 *  cmdCamStopVideoGuiding
 *  arrete le mode d'acquisition video fenetree
 *
 *  Parametres :
 *    
 */
int cmdCamStopVideoGuiding(ClientData clientData, Tcl_Interp * interp, 
                int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   
   cam = (struct camprop *) clientData;
    
   if( cam->guidingCapture == NULL ) {
      sprintf(ligne, "guiding preview already disabled");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   cam->guidingCapture->stopPreview();
   delete cam->guidingCapture;
   cam->guidingCapture = NULL;

   delete  cam->guidingListener;
   cam->guidingListener = NULL;


   return TCL_OK;
}

/**
 * cmdCamSetVideoGuidingCallback.
 * renseigne la command TCL qui est appelee a la fin de la capture
 *
 *  Parametres :
 *    command : nom de la commande TCL 
 */
int cmdCamSetVideoGuidingCallback(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   if( cam->guidingCapture == NULL ) {
      sprintf(ligne, "guiding is not started");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   cam = (struct camprop *) clientData;
   if (argc != 5) {
      sprintf(ligne, "Usage: %s %s setvideoguidingcallback startProc changeOriginProc movePointproc", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      // store the TCL procedure name
      if( strcmp(argv[2], "null") == 0 ) {  
         cam->guidingListener->setTclStartProc("");
      } else {
         cam->guidingListener->setTclStartProc(argv[2]);
      }
      if( strcmp(argv[3], "null") == 0 ) {         
         cam->guidingListener->setTclChangeOriginProc("");
      } else {
         cam->guidingListener->setTclChangeOriginProc(argv[3]);
      }
      if( strcmp(argv[4], "null") == 0 ) {         
         cam->guidingListener->setTclMoveTargetProc("");
      } else {
         cam->guidingListener->setTclMoveTargetProc(argv[4]);
      }
      result = TCL_OK;
   }
   return result;
}

/**
 * cmdCamSetVideoGuidingCallback.
 * renseigne la command TCL qui est appelee a la fin de la capture
 *
 *  Parametres :
 *    command : nom de la commande TCL 
 */
int cmdCamSetVideoGuidingTargetSize(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   int size;

   cam = (struct camprop *) clientData;
   if( cam->guidingCapture == NULL ) {
      sprintf(ligne, "guiding is not started");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   cam = (struct camprop *) clientData;
   if (argc != 3) {
      sprintf(ligne, "Usage: %s %s setvideoguidingtargetsize size", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if(Tcl_GetInt(interp,argv[2],&size)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s setvideoguidingtargetsize size\nsize = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
	  }		
	  if (size > cam->imax || size > cam->jmax ) {
        sprintf(ligne,"Usage: %s %s setvideoguidingtargetsize size\nsize = too large",argv[0],argv[1]);
        Tcl_SetResult(interp,ligne,TCL_VOLATILE);
        return TCL_ERROR;
     }
      // store the size
      cam->guidingCapture->setTargetSize(size);
      result = TCL_OK;
   }
   return result;
}


/*****************************************************************/
#endif  //defined(OS_WIN)
/*****************************************************************/


