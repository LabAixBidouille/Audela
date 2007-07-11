/* camera.h
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef __cplusplus
extern "C" {         /* Assume C declarations for C++ */
#endif            /* __cplusplus */

#if defined(OS_WIN)
#include <vfw.h>
#endif

#if defined(OS_LIN)
#include <sys/mman.h>            // acces direct memoire
#include <linux/videodev.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#if defined(OS_WIN) && defined(__cplusplus)
#include "Capture.h"
#include "CropCapture.h"
#include "GuidingCapture.h"
#endif

/**
 * If you define OS_WIN_USE_LPT_OLD_STYLE, you will use
 * libcam_out function with your lpt port,
 * this function doesn�t work under WinXP and others
 * WinNT systems.
 *
 * If it is not defined, lpt port will be used like printer port, so you
 * will need "null printer" modified plug.
*/
#define OS_WIN_USE_LPT_OLD_STYLE


/**
 * Default value of cam->validFrame parameter.
*/
#define VALID_FRAME 3

/**
 * Frame with any pixel > REQUIRED_MAX_VALUE is detected
 * as valid frame (used in autodetection mode).
*/
#define REQUIRED_MAX_VALUE 150

/**
 * Some definitions for video source functions under Linux.
*/
#if defined(OS_LIN)
#define RESTOREUSER 1
#define GETPICSETTINGS 2
#define RESTOREFACTORY 3
#define GETGAIN 4
#define GETSHARPNESS 5
#define GETSHUTTER 6
#define GETNOISE 7
#define GETCOMPRESSION 8
#define GETWHITEBALANCE 9
#define GETBACKLIGHT 10
#define GETFLICKER 11

#define SETGAIN 12
#define SETSHARPNESS 13
#define SETSHUTTER 14
#define SETNOISE 15
#define SETCOMPRESSION 16
#define SETBACKLIGHT 17
#define SETFLICKER 18

#endif


/**
 * Type of pixels variables. 
 * Should be the same as in cbuffer.h (libaudela).
*/
    typedef float TYPE_PIXELS;

/*
 * Donnees propres a chaque camera.
 *
 * Add specific properties for the camera.
 */


#if defined(OS_WIN) && defined(__cplusplus)
/**
 * class CCaptureListener
 *    implemente l'interface ICaptureListener pour traiter
 *    les erreurs et les messages signalant les changements d'�tat
 */
    class CCaptureListener:public ICaptureListener {

      public:
   CCaptureListener(Tcl_Interp * interp, int camno);
   ~CCaptureListener();
   int onNewStatus(int statusID, char *message);
   int onNewError(int errID, char *message);
   void setTclStatusVariable(char *value);

      protected:
   //char *      tclEndProc;
   char *tclStatusVariable;
   Tcl_Interp *interp;
   int camno;

    };
#endif            /* __cplusplus */


#if defined(OS_WIN) && defined(__cplusplus)
/**
 * class CCaptureListener
 *    implemente l'interface IGuidingCaptureListener pour traiter
 *    les changements des parametres d'autoguidage
 */
    class CGuidingListener:public IGuidingCaptureListener {

      public:

   CGuidingListener(Tcl_Interp * interp);
   ~CGuidingListener();
   void onChangeGuidingStarted(int state);
   void onChangeOrigin(int x0, int y0);
   void onMoveTarget(int x, int y, int alphaDelay, int deltaDelay);
   void setTclStartProc(char *value);
   void setTclChangeOriginProc(char *value);
   void setTclMoveTargetProc(char *value);

      protected:
   char *tclStartProc;
   char *tclChangeOriginProc;
   char *tclMoveTargetProc;
   Tcl_Interp *interp;

    };
#endif



/** 
 * structure qui accueille les parametres.
 *
 * Structure which contains camera's parameters.
 * - COMMON_CAMSTRUCT - standard parameters, don't change.
*/
    struct camprop {

/*
 * parametres standards, ne pas changer.
 *
 * standard parameters, don't change.
*/
   COMMON_CAMSTRUCT;
/*
 *  Ajoutez ici les variables necessaires a votre camera 
 *  (mode d'obturateur, etc). 
 *  pour Webcam
 *
 *  Add here necessary variables for your camera (Webcam).
*/
#if defined(OS_WIN) && defined(__cplusplus)
   CCapture *capture;
   CCaptureListener *captureListener;
   CCropCapture *cropCapture;
   CGuidingCapture *guidingCapture;
   CGuidingListener *guidingListener;
#endif

   int imax;
   int jmax;
   int driver;
   int longuepose;
   int longueposelinkno;
   int longueposelinkbit;
   char longueposestart;
   char longueposestop;

/**
 * webcam device (only for Linux). uses pwc and pwcx modules
 * - default: /dev/video0
 */
   char webcamDevice[128];

/**
 * long exposure device.
 * default:
 * - Linux - "/dev/parport0"
 * - Windows - "lpt1"
 */
 //  char longExposureDevice[128];

/**
 * Valid image number (used under Linux).
 * Pwc kernel module has some buffers and
 * when you take long exposure you
 * need to find which buffer contains your frame.
 * 
 * This parameter says which frame is your valid frame
 * (how many read() calls you need), if is 0
 * auto detection is performed (less then 20 read() calls).
 * - dafault: 3
 */
   int validFrame;

/**
 * cam_fd, webcam device file descriptor.
 */
   int cam_fd;

/**
 * long_fd, long exposure device file descriptor.
 */
   int long_fd;

/**
 * Buffer for rgb frame.
 * Used under Linux for keeping rgb frame
 *
 * In cam_init memory
 * is allocated and dislocated
 * in cmdCamClose, also video format functions
 * change buffers sizes and allocates new memory
 * for them.
 */
   unsigned char *rgbBuffer;

/**
 * rgbBufferSize is size in bytes of rgbBuffer.
 */
   int rgbBufferSize;

/**
 * Buffer for yuv frame.
 * Used under Linux for keeping yuv frame
 */
   unsigned char *yuvBuffer;

/**
 * yuvBufferSize is size in bytes of yuvBuffer.
 */
   int yuvBufferSize;

/**
 * shutterSpeed remember the shutter speed.
 *
 * A negative value sets the shutter speed to automatic
 * (controlled by the camera's firmware).
 * A value of 0..65535 will set manual mode, where the values have
 * been calibrated such that 65535 is the longest possible exposure
 * time that I could find on any camera model. It is not a linear
 * scale, where a value of '1' is 1/65536th of a second, etc.
 *
 * Used under Linux.
 */
   int shutterSpeed;

/**
 * sensorColor : color=1 , black and white= 0
 */
   int sensorColor;


/******************************************************************/
/*  variable  d'acces direct a la memoire video LINUX (M. Pujol)  */
/*                                                                */
/*  Pour LINUX uniquement                                         */
/******************************************************************/
#if defined(OS_LIN)
   struct video_mbuf mmap_mbuf ;
   unsigned char * mmap_buffer;
   long mmap_last_sync_buff;
   long mmap_last_capture_buff;
#endif


/******************************************************************/
/*  Variables utilisees pour la capture video (M. Pujol)          */
/*  Pour Windows uniquement                                       */
/******************************************************************/
#if defined(OS_WIN)
   int videonum;      // numero de l'image video
   char videoStatusVarNamePtr[256];   // variable pour transmettre l'etat de la camera
   char videoEndCaptureCommandPtr[256];   // command a executer en fin de capture
   // remarque : ces deux variables ne sont pas allouees dynamiquement a cause d'une erreur de heap
   // quand je libere la memoire avec free()
#endif

/*****************************************************************/

};  // end of  struct camprop


int webcam_initLongExposureDevice(struct camprop *cam);
int webcam_setLongExposureDevice(struct camprop *cam, unsigned char value);
int webcam_saveUser(struct camprop *cam);
int webcam_setPicSettings(struct camprop *cam, int brightness, int contrast, int colour, int whiteness);
int webcam_getVideoFormat(struct camprop *cam, char *formatname);
int webcam_setVideoFormat(struct camprop *cam, char *formatname);



#if defined(OS_WIN)
   int startVideoPreview(struct camprop *cam, int previewRate);
   int stopVideoPreview(struct camprop *cam);
   int startVideoCapture(struct camprop *cam, unsigned short exptime, unsigned long microSecPerFrame, char *fileName);
   int stopVideoCapture(struct camprop *cam);
   int startVideoCrop(struct camprop *cam);
   int stopVideoCrop(struct camprop *cam);
   int setVideoCropRect(struct camprop *cam, long x1, long y1, long x2, long y2);

#endif            //defined(OS_WIN)

#if defined(OS_LIN)
   int webcam_getFrameRate(struct camprop *cam, int *value);
   int webcam_setFrameRate(struct camprop *cam, int value);
   int webcam_getVideoParameter(struct camprop *cam, char *result, int command);
   int webcam_setVideoParameter(struct camprop *cam, int paramValue, int command);
   int webcam_setWhiteBalance(struct camprop *cam, char *mode, int red, int blue);
#endif

#ifdef __cplusplus
}            /* End of extern "C" { */
#endif            /* __cplusplus */
#endif
