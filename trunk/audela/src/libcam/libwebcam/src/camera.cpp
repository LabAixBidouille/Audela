/* camera.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <stdio.h>

#include "camera.h"
#include <libcam/util.h>
#include <libcam/libcam.h>

#if defined(OS_LIN)
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/videodev.h>
#include <sys/ioctl.h>
#include "pwc-ioctl.h"

#include <linux/ppdev.h>
#include <linux/parport.h>
#include <errno.h>

extern int errno;

/**
 * Definitions and global variables for yuv420p_to_rgb24 conversion.
 * Code comes from xawtv.
*/

#define CLIP         320

# define RED_NULL    128
# define BLUE_NULL   128
# define LUN_MUL     256
# define RED_MUL     512
# define BLUE_MUL    512

#define GREEN1_MUL  (-RED_MUL/2)
#define GREEN2_MUL  (-BLUE_MUL/6)
#define RED_ADD     (-RED_NULL  * RED_MUL)
#define BLUE_ADD    (-BLUE_NULL * BLUE_MUL)
#define GREEN1_ADD  (-RED_ADD/2)
#define GREEN2_ADD  (-BLUE_ADD/6)

static unsigned int ng_yuv_gray[256];
static unsigned int ng_yuv_red[256];
static unsigned int ng_yuv_blue[256];
static unsigned int ng_yuv_g1[256];
static unsigned int ng_yuv_g2[256];
static unsigned int ng_clip[256 + 2 * CLIP];

#define GRAY(val)               ng_yuv_gray[val]
#define RED(gray,red)           ng_clip[ CLIP + gray + ng_yuv_red[red] ]
#define GREEN(gray,red,blue)    ng_clip[ CLIP + gray + ng_yuv_g1[red] + \
                                                       ng_yuv_g2[blue] ]
#define BLUE(gray,blue)         ng_clip[ CLIP + gray + ng_yuv_blue[blue] ]

#endif


/**
 * Definition of different cameras supported by this driver
 * (see declaration in libstruc.h)
 */
extern "C" struct camini CAM_INI[] = {
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX098BQ-A",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    5.6e-6, 5.6e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    1,               /* default num buf for the image */
    1,               /* default num tel for the coordinates taken */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX098BL-6",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    5.6e-6, 5.6e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    1,               /* default num buf for the image */
    1,               /* default num tel for the coordinates taken */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX424AL-6",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    7.4e-6, 7.4e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    1,               /* default num buf for the image */
    1,               /* default num tel for the coordinates taken */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX414AL-6",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    9.9e-6, 9.9e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    1,               /* default num buf for the image */
    1,               /* default num tel for the coordinates taken */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
     CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, char **argv);
static int cam_close(struct camprop *cam);
static void cam_start_exp(struct camprop *cam, char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, unsigned short *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_ampli_on(struct camprop *cam);
static void cam_ampli_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,
    cam_close,
    cam_set_binning,
    cam_update_window,
    cam_start_exp,
    cam_stop_exp,
    cam_read_ccd,
    cam_shutter_on,
    cam_shutter_off,
    cam_ampli_on,
    cam_ampli_off,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

static void yuv420p_to_rgb24(unsigned char *yuv, unsigned char *rgb, int width, int height);
static void ng_color_yuv2rgb_init(void);
static int readFrame(struct camprop *cam);
static int cam_stop_longexposure(struct camprop *cam);


/**
 * Definition of a structure specific for this driver 
 * (see declaration in camera.h)
 */

#if defined(OS_WIN)
#pragma pack (1)
#endif

typedef struct {
   char id[2];
   long filesize;
   short reserved[2];
   long headersize;
   long infosize;
   long width;
   long depth;
   short biplanes;
   short bits;
   long bicompression;
   long bisizeimage;
   long bixpelspermeter;
   long biypelspermeter;
   long biclrused;
   long biclrimportant;
} BMPHEAD;

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

/*
 *  Usage acquisition :
 *  - cam::create webcam usb -channel 0...10  -format  large ou small
 *  - cam1 adjust
 *  - cam1 snap
 *  - cam::delete 1
*/

/*!
 * cam_init
 * - cam_init permet d'initialiser les variables de la
 * - structure 'camprop'                               
 * - specifiques a cette camera.                       
 *
 * cam_init
 *  - cam_init initialize variables of structure "camprop" specified
 *  for this camera.
 * - under Linux it opens webcam and parallel port
 * - sets image format on 640 x 480 (max for this camera).
 *  
*/
int cam_init(struct camprop *cam, int argc, char **argv)
{
   char formatname[128];
   int kk;
   Tcl_Interp *interp;

#if defined(OS_WIN)
   char ligne[128];
   HWND hWnd = NULL;
   int box_format = 1;
#endif

#if defined(OS_LIN)
   struct video_capability vcap;
   int type;

   /**
   * Window size, this function sets maximal as possible size,
   * usually it is 640 x 480 pixels.
   */
   struct video_window win = { 0, 0, 640, 480, 0, 0, 0x0, 0 };
   struct pwc_probe probe;
   int IsPhilips;
#endif

   interp = cam->interp;

   strcpy(formatname, "");
   cam->longuepose = 0;
   cam->longueposestart = 0;
   cam->longueposestop = 1;

   /* default settings */

#if defined(OS_LIN)
   strcpy(cam->webcamDevice, "/dev/video0");
   //strcpy(cam->longExposureDevice, "/dev/parport0");
   cam->validFrame = VALID_FRAME;
   cam->rgbBuffer = NULL;
   cam->rgbBufferSize = 0;
   cam->yuvBuffer = NULL;
   cam->yuvBufferSize = 0;
   cam->cam_fd = -1;
   IsPhilips = 0;
   cam->shutterSpeed = -1;
#endif

/*
#if defined(OS_WIN)
   strcpy(cam->longExposureDevice, "lpt1");
   cam->driver = 0;
   cam->hLongExposureDevice = INVALID_HANDLE_VALUE;
   cam->longueposeportindex = 0;
   cam->longueposeport = 0x378;
#endif
*/


/* Decode les options de cam::create */
   if (argc >= 5) {
      for (kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-channel") == 0) {
            cam->driver = atoi(argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-format") == 0) {
            strcpy(formatname, argv[kk + 1]);
         }
/*
         if (strcmp(argv[kk], "-lpport") == 0) {
            strcpy(cam->longExposureDevice, argv[kk + 1]);
#if defined(OS_WIN)
            if (strcmp(argv[kk + 1], cam_ports[1]) == 0) {
               cam->longueposeportindex = 1;
               cam->longueposeport = 0x278;
            }
#endif
         }
*/
         if (strcmp(argv[kk], "-webcamdevice") == 0) {
            strcpy(cam->webcamDevice, argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-validframe") == 0) {
            cam->validFrame = atoi(argv[kk + 1]);
            if (cam->validFrame < 0) {
               cam->validFrame = VALID_FRAME;
               strcpy(cam->msg,
                      "-validFrame invalid parameter, must be integer >= 0");
               return 1;
            }
         }

      }
   }

   cam->imax = cam->nb_photox / cam->binx;      /* valeurs par défauts */
   cam->jmax = cam->nb_photoy / cam->biny;

#if defined(OS_WIN)

   hWnd = GetDesktopWindow();   /* handler du poste de travail */
   

   if (hWnd == NULL) {
      strcpy(cam->msg, "GetDesktopWindow null pointer");
      return 1;
   }

/* On s'assure que la fenêtre vidéo n'est pas déja ouverte */
   if (cam->capture != NULL) {
      delete cam->capture;
      delete cam->captureListener;
      cam->capture = NULL;
   }

/* Création de la fenêtre vidéo avec une taille nulle */
   cam->capture = new CCapture();
   cam->captureListener = new CCaptureListener(cam->interp, cam->camno);
   cam->capture->createWindow("Capture Window", hWnd, cam->captureListener);
   if (cam->capture == NULL) {
      strcpy(cam->msg, "capture is a null pointer. Video not initialized.");
      return 3;
   }


   // On active le driver - Périphérique numéro 0 par défaut
   if (cam->capture->initHardware( cam->driver) == FALSE) {
      delete cam->captureListener;
      delete cam->capture;
      cam->capture = NULL;
      sprintf(ligne, "Driver non trouvé");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      strcpy(cam->msg, "Driver not installed or camera not linked");
      return 4;

      /*return TCL_ERROR; */
   }
   if (strcmp(formatname, "") == 0) {
      strcpy(formatname, "SAME");
   }
   
   /*strcpy(formatname,"VGA");*/
   if (webcam_videoformat(cam, formatname) == 1) {
      delete cam->capture;
      delete cam->captureListener;
      cam->capture = NULL;
      strcpy(cam->msg, "videoformat==1");
      return 5;

   }

   /*
   if (cam->longuepose == 1) {
      if (webcam_initLongExposureDevice(cam)) {
         delete cam->capture;
         delete cam->captureListener;
         cam->capture = NULL;
         return 6;
      }
   } else
      cam->hLongExposureDevice = INVALID_HANDLE_VALUE;
   */

   // pour le mode video
   cam->capture->setPreview(FALSE);
   cam->capture->setCaptureAudio(FALSE);
   cam->videoStatusVarNamePtr[0] = 0;	 
   cam->videoEndCaptureCommandPtr[0] = 0;

   
#endif

#if defined(OS_LIN)


   ng_color_yuv2rgb_init();

   if (-1 == (cam->cam_fd = open(cam->webcamDevice, O_RDWR))) {
      sprintf(cam->msg, "Can't open %s - %s", cam->webcamDevice,
	    strerror(errno));
      return 1;
   }

   /* Get camera capability */
   IsPhilips = 0;
   if (ioctl(cam->cam_fd, VIDIOCGCAP, &vcap)) {
      strcpy(cam->msg, "Can't VIDIOCGCAP");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      return 1;
   }
   /* Check if it is Philips compatible webcam,
    * supported by pwc and pwcx modules.
    */
   if (sscanf(vcap.name, "Philips %d webcam", &type) < 1) {
      /* No match yet; try the PROBE */

      if (ioctl(cam->cam_fd, VIDIOCPWCPROBE, &probe) == 0)
         if (strcmp(vcap.name, probe.name) == 0)
            IsPhilips = 1;
   } else
      IsPhilips = 1;

   if (IsPhilips == 0) {
      sprintf(cam->msg, "%s - is not Philips compatible webcam",
              vcap.name);
      close(cam->cam_fd);
      cam->cam_fd = -1;
      return 1;
   }

   cam->imax = vcap.maxwidth;
   cam->jmax = vcap.maxheight;

   
/*
   if(ioctl(cam->cam_fd, VIDIOCSPICT, &pic) < 0) {      
      strcpy(cam->msg,"Can't VIDIOCSPICT");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      return 1;
   }
*/
	webcam_videoformat(cam, "QCIF");

   win.width = cam->imax;
   win.height = cam->jmax;


   /* Set window settings */
   if (ioctl(cam->cam_fd, VIDIOCSWIN, &win) < 0) {
      strcpy(cam->msg, "Can't VIDIOCSWIN");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      return 1;
   }



   /* Allocate memory for frame buffers: rgbBuffer and yuvBuffer */
   if ((cam->rgbBufferSize = 3 * cam->imax * cam->jmax) < 0) {
      strcpy(cam->msg, "3*cam->imax*cam->jmax is < 0");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      cam->rgbBufferSize = 0;
      return 1;
   }
/*
   if ((cam->rgbBuffer = (unsigned char *) malloc(cam->rgbBufferSize))
       == NULL) {
      strcpy(cam->msg, "Not enougt memory");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      cam->rgbBufferSize = 0;
      return 1;
   }
*/

   if ((cam->yuvBufferSize = (cam->imax * cam->jmax * 12) / 8) < 0) {
      strcpy(cam->msg, "(cam->imax*cam->jmax*12)/8 is < 0");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      //free(cam->rgbBuffer);
      //cam->rgbBuffer = NULL;
      cam->rgbBufferSize = 0;
      cam->yuvBufferSize = 0;
      return 1;
   }
   if ((cam->yuvBuffer = (unsigned char *) malloc(cam->yuvBufferSize))
       == NULL) {
      strcpy(cam->msg, "Not enough memory");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      //free(cam->rgbBuffer);
      //cam->rgbBuffer = NULL;
      cam->rgbBufferSize = 0;
      cam->yuvBufferSize = 0;
      return 1;
   }

   /* Init long exposure device,
    * it uses parport, parport_pc and ppdev modules.
    */
   if (cam->longuepose == 1) {
      if (webcam_initLongExposureDevice(cam)) {
         close(cam->cam_fd);
         cam->cam_fd = -1;
         //free(cam->rgbBuffer);
         //cam->rgbBuffer = NULL;
         cam->rgbBufferSize = 0;
         free(cam->yuvBuffer);
         cam->yuvBuffer = NULL;
         cam->yuvBufferSize = 0;
         return 1;
      }
   } else
      cam->long_fd = -1;


   //printf("%s\n",vcap.name);   

#endif
   cam_update_window(cam);


   return 0;
}


int cam_close(struct camprop *cam)
{
#if defined(OS_WIN)
   if (cam->capture != NULL) {
      delete cam->capture;
      cam->capture = NULL;
   }

/*
#if !defined(OS_WIN_USE_LPT_OLD_STYLE)
   if (cam->hLongExposureDevice != INVALID_HANDLE_VALUE) {
      CloseHandle(cam->hLongExposureDevice);
      cam->hLongExposureDevice = INVALID_HANDLE_VALUE;
   }
#endif
*/

#endif

#if defined(OS_LIN)
   if (cam->cam_fd >= 0) {
      close(cam->cam_fd);
      cam->cam_fd = -1;
   }
   /*
   if (cam->long_fd >= 0) {
      webcam_setLongExposureDevice(cam, cam->longueposestop);
      ioctl(cam->long_fd, PPRELEASE);
      close(cam->long_fd);
      cam->long_fd = -1;
   }
   */

   //if (cam->rgbBuffer != NULL) {
   //   free(cam->rgbBuffer);
   //   cam->rgbBuffer = NULL;
   //}
   //cam->rgbBufferSize = 0;

   if (cam->yuvBuffer != NULL) {
      free(cam->yuvBuffer);
      cam->yuvBuffer = NULL;
   }
   cam->yuvBufferSize = 0;

#endif

   return TCL_OK;
}


/**
 * Function cam_start_exp - starts the exposure.
 * Called by command "acq" (function: cmdCamAcq),
 * after <b>exptime</b> TCL calls cam_read_ccd (function: AcqRead).
 *
 * "acq" -> cmdCamAcq -> cam_start_exp ...
 *
 * -> AcqRead -> cam_read_ccd
 *
 * or
 *
 * "stop" -> cmdCamStop -> AcqRead -> cam_read_ccd.
 *
 * should return a value???
*/
void cam_start_exp(struct camprop *cam, char *amplionoff)
{
//   int naxis1, naxis2, bin1, bin2;
//   Tcl_Interp *interp;

//   interp = cam->interp;
//   naxis1 = cam->imax;
//   naxis2 = cam->jmax;
//   bin1 = cam->binx;
//   bin2 = cam->biny;

   if (cam->longuepose == 0) {
      //cam->exptime = (float) (cam->capture->getTimeLimit() * 1.e-6);
      if (readFrame(cam)) {
         //error description in cam->msg
         return;
      }
   } else {
      /* long exposure */
      if (webcam_setLongExposureDevice(cam, cam->longueposestart)) {
         //error description in cam->msg
         return;
      }
   }
}

/**
 * cam_stop_longexposure stops long exposure.
 * Under Linux this function reads a frame
 * and store it in cam->rgbBuffer,
 * under Windows it saves frame in file "\@0.bmp".
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/
int cam_stop_longexposure(struct camprop *cam)
{
   if (cam->longuepose == 1) {

#if defined(OS_WIN)
   // une première lecture pour se synchroniser 
   cam->capture->grabFrameNoStop();
#endif                          //OS_WIN

   // fin de la pose 
      if (webcam_setLongExposureDevice(cam, cam->longueposestop)) {
         //error description in cam->msg
         return 1;
      }
      if (readFrame(cam)) {
         //error description in cam->msg
         return 1;
      }
   }
   return 0;
}

void cam_stop_exp(struct camprop *cam)
{
}

/**
 * cam_read_ccd - reads a frame.
 * This function store the frame in (unsigned short *)p buffer.
 * 
 * Under:
 * - Linux rgbBuffer is copied to p,
 * - Windows \@0.bmp file is read and copied to p.
 *
 * Calling diagram:
 *
 * "acq" -> cmdCamAcq -> cam_start_exp ...
 *
 * -> AcqRead -> cam_read_ccd
 *
 * or
 *
 * "stop" -> cmdCamStop -> AcqRead -> cam_read_ccd.
 * 
 * should return a value???
*/
void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
   unsigned char *tempRgbBuffer;
   Tcl_Interp *interp;

   interp = cam->interp;
   if (cam->longuepose == 1) {
      if (cam_stop_longexposure(cam)) {
         //If error , cam_stop_longexposure() put error message in cam->msg
         return;
      }
   }

   /* Charge l'image 24 bits */
   strcpy(cam->pixels_classe, "CLASS_RGB");
   strcpy(cam->pixels_format, "FORMAT_BYTE");
   strcpy(cam->pixels_compression, "COMPRESS_NONE");
   cam->pixels_reverse_y = 1;
   cam->pixel_data = (char*)malloc(cam->imax*cam->jmax*3);
   if( cam->pixel_data != NULL) {
      // copy rgbBuffer into cam->pixel_data
      // convert color order  BGR -> RGB
      if( cam->rgbBuffer != NULL ) {
         tempRgbBuffer = (unsigned char *) cam->pixel_data  ;
         unsigned char *ptr = cam->rgbBuffer ;
         for(int y = cam->jmax -1; y >= 0; y-- ) {
            ptr = cam->rgbBuffer + y * cam->imax *3 ;
            for(int x=0; x <cam->imax; x++) {
               *(tempRgbBuffer++)= *(ptr + x*3 +2);
               *(tempRgbBuffer++)= *(ptr + x*3 +1);
               *(tempRgbBuffer++)= *(ptr + x*3 +0);
            }
         }
      } else {
         // je retourne un message d'erreur
         sprintf(cam->msg, "cam_read_ccd: Not enougt memory");
      }
   }

   if (cam->rgbBuffer != NULL) {
      free(cam->rgbBuffer);
      cam->rgbBuffer = NULL;
      cam->rgbBufferSize = 0;
   }
}

void cam_shutter_on(struct camprop *cam)
{

}

void cam_shutter_off(struct camprop *cam)
{

}

void cam_ampli_on(struct camprop *cam)
{

}

void cam_ampli_off(struct camprop *cam)
{

}

void cam_measure_temperature(struct camprop *cam)
{
   cam->temperature = 0.;
}

void cam_cooler_on(struct camprop *cam)
{
}

void cam_cooler_off(struct camprop *cam)
{
}

void cam_cooler_check(struct camprop *cam)
{
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   /*
      cam->binx = binx;
      cam->biny = biny;
    */
}

/**
 * Function cam_set_exptim.
 * Probably never used... ???
*/
void cam_set_exptime(float exptime, struct camprop *cam)
{
   if (cam->longuepose == 1) {
      cam->exptime = exptime;
   } else {
      cam->exptime = (float) (1. / 30.);
   }
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   /*
      if(cam->x1>cam->x2) libcam_swap(&(cam->x1),&(cam->x2));
      if(cam->x1<0) cam->x1 = 0;
      if(cam->x2>maxx-1) cam->x2 = maxx-1;

      if(cam->y1>cam->y2) libcam_swap(&(cam->y1),&(cam->y2));
      if(cam->y1<0) cam->y1 = 0;
      if(cam->y2>maxy-1) cam->y2 = maxy-1;
    */

   cam->x1 = 0;
   cam->x2 = maxx - 1;
   cam->y1 = 0;
   cam->y2 = maxy - 1;
   cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;

}


/**
 * webcam_videoformat - sets video format.
 * Possible format names:
 * - VGA - 640 x 480
 * - CIF - 352 x 288
 * - SIF - 320 x 240
 * - SSIF - 240 x 176
 * - QCIF - 176 x 144
 * - QSIF - 160 x 120
 * - SQCIF - 128 x 96.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/


int webcam_videoformat(struct camprop *cam, char *formatname)
{
   char ligne[128];
   int imax, jmax, box = 1;

#if defined(OS_WIN)
   HWND hWnd = NULL;

   if (cam->capture == NULL)
      return 1;
#endif

#if defined(OS_LIN)
   struct video_window win = { 0, 0, 640, 480, 0, 0, 0x0, 0 };
#endif

   libcam_strupr(formatname, ligne);
   //change to upper: void libcam_strupr(char *chainein, char *chaineout)

   imax = 0;
   jmax = 0;
   if (strcmp(ligne, "SAME") == 0) {
      box = 0;
   }
   if (strcmp(ligne, "VGA") == 0) {
      imax = 640;
      jmax = 480;
   } else if (strcmp(ligne, "CIF") == 0) {
      imax = 352;
      jmax = 288;
   } else if (strcmp(ligne, "SIF") == 0) {
      imax = 320;
      jmax = 240;
   } else if (strcmp(ligne, "SSIF") == 0) {
      imax = 240;
      jmax = 176;
   } else if (strcmp(ligne, "QCIF") == 0) {
      imax = 176;
      jmax = 144;
   } else if (strcmp(ligne, "QSIF") == 0) {
      imax = 160;
      jmax = 120;
   } else if (strcmp(ligne, "SQCIF") == 0) {
      imax = 128;
      jmax = 96;
   }
#if defined(OS_WIN)
   /* On récupère le format courant de l'image vidéo */
   if ((cam->capture->getImageWidth() != (unsigned) imax)
       && (cam->capture->getImageHeight() != (unsigned) jmax)
       && (box == 1)) {
      if (cam->capture->hasDlgVideoFormat()) {
         //BringWindowToTop(cam->g_hWndC);
         //SetForegroundWindow(cam->g_hWndC); 
         cam->capture->openDlgVideoFormat();
      }
   }
   /* On récupère le nouveau format courant de l'image vidéo */
   cam->nb_photox = (int) cam->capture->getImageWidth();
   cam->nb_photoy = (int) cam->capture->getImageHeight();
   cam->binx = 1;
   cam->biny = 1;
   cam->imax = cam->nb_photox / cam->binx;      /* valeurs par défauts */
   cam->jmax = cam->nb_photoy / cam->biny;
   //cam->celldimx = 5080. / cam->nb_photox;
   //cam->celldimy = 3810. / cam->nb_photoy;

#endif

#if defined(OS_LIN)
   if (jmax == 0 || imax == 0) {
      sprintf(cam->msg, "Unknown format: %s", formatname);
      return 1;
   }

   /* New buffer size */
   win.width = imax;
   win.height = jmax;

   /* Set window size */
   if (ioctl(cam->cam_fd, VIDIOCSWIN, &win) < 0) {
      strcpy(cam->msg, "Can't VIDIOCSWIN");
      return 1;
   }

   cam->nb_photox = imax;
   cam->nb_photoy = jmax;
   cam->binx = 1;
   cam->biny = 1;
   cam->imax = cam->nb_photox / cam->binx;      /* valeurs par défauts */
   cam->jmax = cam->nb_photoy / cam->biny;
   cam->celldimx = 5080. / cam->nb_photox;
   cam->celldimy = 3810. / cam->nb_photoy;

   /* Free buffers */
   if( cam->rgbBuffer != NULL ) {
      free(cam->rgbBuffer);
      cam->rgbBuffer = NULL;
   }

   free(cam->yuvBuffer);
   cam->yuvBuffer = NULL;
   cam->rgbBufferSize = 0;
   cam->yuvBufferSize = 0;

   /* Allocate memory for new buffers */
   if ((cam->rgbBufferSize = 3 * cam->imax * cam->jmax) < 0) {
      strcpy(cam->msg, "3*cam->imax*cam->jmax is < 0");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      cam->rgbBufferSize = 0;
      return 1;
   }
   if ((cam->rgbBuffer = (unsigned char *) malloc(cam->rgbBufferSize))
       == NULL) {
      strcpy(cam->msg, "Not enough memory");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      cam->rgbBufferSize = 0;
      return 1;
   }

   if ((cam->yuvBufferSize = (cam->imax * cam->jmax * 12) / 8) < 0) {
      strcpy(cam->msg, "(cam->imax*cam->jmax*12)/8 is < 0");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      //free(cam->rgbBuffer);
      //cam->rgbBuffer = NULL;
      cam->rgbBufferSize = 0;
      cam->yuvBufferSize = 0;
      return 1;
   }
   if ((cam->yuvBuffer = (unsigned char *) malloc(cam->yuvBufferSize))
       == NULL) {
      strcpy(cam->msg, "Not enough memory");
      close(cam->cam_fd);
      cam->cam_fd = -1;
      //free(cam->rgbBuffer);
      //cam->rgbBuffer = NULL;
      cam->rgbBufferSize = 0;
      cam->yuvBufferSize = 0;
      return 1;
   }
#endif

   cam_update_window(cam);

   return 0;

}


/**
 * Init Lookup tables for yuv to rgb conversion.
 * Code comes from xawtv.
*/
void ng_color_yuv2rgb_init(void)
{
#if defined(OS_LIN)
   int i;

   /* init Lookup tables */
   for (i = 0; i < 256; i++) {
      ng_yuv_gray[i] = i * LUN_MUL >> 8;
      ng_yuv_red[i] = (RED_ADD + i * RED_MUL) >> 8;
      ng_yuv_blue[i] = (BLUE_ADD + i * BLUE_MUL) >> 8;
      ng_yuv_g1[i] = (GREEN1_ADD + i * GREEN1_MUL) >> 8;
      ng_yuv_g2[i] = (GREEN2_ADD + i * GREEN2_MUL) >> 8;
   }
   for (i = 0; i < CLIP; i++)
      ng_clip[i] = 0;
   for (; i < CLIP + 256; i++)
      ng_clip[i] = i - CLIP;
   for (; i < 2 * CLIP + 256; i++)
      ng_clip[i] = 255;
#endif
}


/**
 * Convert from yuv to rgb.
 *
 * Code comes from xawtv, actually it converts to bgr
 * and flips vertically.
*/
void yuv420p_to_rgb24(unsigned char *yuv, unsigned char *rgb,
                      int width, int height)
{
#if defined(OS_LIN)

   unsigned char *y, *u, *v, *d;
   unsigned char *us, *vs;
   unsigned char *dp;
   int i, j;
   int gray;

   dp = rgb + (height - 1) * width * 3;
   y = yuv;
   u = y + width * height;
   v = u + width * height / 4;

   for (i = 0; i < height; i++) {
      d = dp;
      us = u;
      vs = v;
      for (j = 0; j < width; j += 2) {
         gray = GRAY(*y);
         *(d++) = BLUE(gray, *u);
         *(d++) = GREEN(gray, *v, *u);
         *(d++) = RED(gray, *v);
         y++;
         gray = GRAY(*y);
         *(d++) = BLUE(gray, *u);
         *(d++) = GREEN(gray, *v, *u);
         *(d++) = RED(gray, *v);
         y++;
         u++;
         v++;
      }
      if (0 == (i % 2)) {
         u = us;
         v = vs;
      }
      dp -= width * 3;
   }
#endif
}

/**
 * webcam_setLongExposureDevice - writes <i>value</i>
 * to the parallel port.
 * 
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/


int webcam_setLongExposureDevice(struct camprop *cam, unsigned char value)
{

/*
#if defined(OS_LIN)
   if (cam->long_fd < 0)
      if (webcam_initLongExposureDevice(cam))
         return 1;

   // Write a byte 
   if (ioctl(cam->long_fd, PPWDATA, &value)) {
      ioctl(cam->long_fd, PPRELEASE);
      close(cam->long_fd);
      cam->long_fd = -1;
      sprintf(cam->msg, "Can't set long exposure, PPWDATA");
      return 1;
   }
#endif

#if defined(OS_WIN)

// Old implementation of this function 
#if defined(OS_WIN_USE_LPT_OLD_STYLE)
   unsigned short port;

   port=cam->longueposeport;
   libcam_out(port, value);
   quickremote_setChar(value);
#else

   DWORD nNumberOfBytesWritten = 0;

   if (cam->hLongExposureDevice == INVALID_HANDLE_VALUE)
      if (webcam_initLongExposureDevice(cam))
         return 1;


   // Write a byte
   if (!WriteFile
       (cam->hLongExposureDevice, &value, 1, &nNumberOfBytesWritten, NULL)
       || nNumberOfBytesWritten != 1) {
      CloseHandle(cam->hLongExposureDevice);
      cam->hLongExposureDevice = INVALID_HANDLE_VALUE;
      sprintf(cam->msg, "Can't set long exposure");
      return 1;
   }
#endif
#endif
*/
   char ligne[256];
   int result;

   // exemple "link1 bit 0 1"

   sprintf(ligne, "link%d bit %d %d", cam->longueposelinkno, cam->longueposelinkbit, value);
   if( Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
      result = 1;
   } else {
      result = 0;
   }

   return result;
}


/**
 * webcam_initLongExposureDevice - initiates a long exposure device
 * and sets cam->longueposestop.
 *
 * Parallel port control:
 * - Linux uses parport, parport_pc and ppdev modules.
 * - Windows uses "lpt1" printer port (with its handshake),
 * so you will need "null printer" modified plug. If you
 * don't like to use "lpt1" printer port you can define
 * OS_WIN_USE_LPT_OLD_STYLE.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/


int webcam_initLongExposureDevice(struct camprop *cam)
{
return 0;

/*
#if defined(OS_LIN)
   int buffer;   // buffer mode of parallel port 

   if (-1 == (cam->long_fd = open(cam->longExposureDevice, O_RDWR))) {
      sprintf(cam->msg, "Can't open: %s", cam->longExposureDevice);
      return 1;
   }
   if (ioctl(cam->long_fd, PPCLAIM)) {
      ioctl(cam->long_fd, PPRELEASE);
      close(cam->long_fd);
      cam->long_fd = -1;
      sprintf(cam->msg, "Can't PPCLAIM: %s", cam->longExposureDevice);
      return 1;
   }

   buffer = IEEE1284_MODE_BYTE;

   if (ioctl(cam->long_fd, PPSETMODE, &buffer)) {
      ioctl(cam->long_fd, PPRELEASE);
      close(cam->long_fd);
      cam->long_fd = -1;
      sprintf(cam->msg, "Can't PPSETMODE: %s", cam->longExposureDevice);
      return 1;
   }

   if (ioctl(cam->long_fd, PPWDATA, &(cam->longueposestop))) {
      ioctl(cam->long_fd, PPRELEASE);
      close(cam->long_fd);
      cam->long_fd = -1;
      sprintf(cam->msg, "Can't set longueposestop");
      return 1;
   }
#endif
*/
/*
#if defined(OS_WIN)
#if defined(OS_WIN_USE_LPT_OLD_STYLE)

   unsigned short port;

   port=cam->longueposeport;
   libcam_out(port, cam->longueposestop);
   quickremote_setChar(cam->longueposestop);

#else

   DWORD nNumberOfBytesWritten = 0;

   cam->hLongExposureDevice =
      CreateFile(cam->longExposureDevice, GENERIC_WRITE, 0, NULL,
                 OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

   if (cam->hLongExposureDevice == INVALID_HANDLE_VALUE) {
      sprintf(cam->msg, "Can't create (open) file: %s",
              cam->longExposureDevice);
      return 1;
   }

   if (!WriteFile
       (cam->hLongExposureDevice, &(cam->longueposestop), 1,
        &nNumberOfBytesWritten, NULL)
       || nNumberOfBytesWritten != 1) {
      CloseHandle(cam->hLongExposureDevice);
      cam->hLongExposureDevice = INVALID_HANDLE_VALUE;
      sprintf(cam->msg, "Can't set longueposestop");
      return 1;
   }
#endif
#endif
*/
   return 0;
}


/**
 * readFrame - reads one frame from webcam
 * and stores it in cam->rgbBuffer.
 * If longexposure is set, function looks for valid frame.
 *
 * Function is implemented only for Linux.
 * 
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg. 
*/
int readFrame(struct camprop *cam)
{
   cam->rgbBufferSize = cam->imax * cam->jmax *3;
   cam->rgbBuffer = (unsigned char*)malloc(cam->rgbBufferSize);

#if defined(OS_WIN)
   // on prie pour que ca soit la bonne image, sinon régler framerate à moins de 5 img/sec 
   cam->capture->readFrame(cam->rgbBuffer);
#endif


#if defined(OS_LIN)
   int i = 0, n = 0;

   if (cam->cam_fd < 0) {
      strcpy(cam->msg, "cam_fd is < 0");
      return -1;
   }

   if (cam->longuepose == 0) {
      /* acquisition normale 
       * normal exposure
       */
      if (cam->yuvBufferSize != read(cam->cam_fd,
                                     cam->yuvBuffer, cam->yuvBufferSize)) {
         strcpy(cam->msg, "error while reading frame: read()");
         return -1;
      }
   } else if (cam->longuepose == 1) {
      /* acquisition longue pose 
       * long exposure
       */
      if (cam->validFrame > 0) {
         for (i = 0; i < cam->validFrame; i++) {
            if (cam->yuvBufferSize != read(cam->cam_fd,
                                           cam->yuvBuffer,
                                           cam->yuvBufferSize)) {
               strcpy(cam->msg, "error while reading frame: read()");
               return -1;
            }
         }
      } else if (cam->validFrame == 0) {
         //auto detection, (less then 20 read() calls).
         for (i = 0; i < 20; i++) {
            if (cam->yuvBufferSize
                != read(cam->cam_fd, cam->yuvBuffer, cam->yuvBufferSize)) {
               strcpy(cam->msg, "error while reading frame: read()");
               return -1;
            }
            yuv420p_to_rgb24(cam->yuvBuffer, cam->rgbBuffer,
                             cam->imax, cam->jmax);
            for (n = 0; n < cam->rgbBufferSize; n++) {
               /* 
                * I've done some tests and finding if there is any pixel
                * brighter than REQUIRED_MAX_VALUE occurred the best 
                * way of detecting valid frame.
                * Mean value or mean-square deviation weren't
                * a good criterion, because mean value is almost the same
                * for dark and valid frame, mean-square deviation
                * depends on camera settings - especially noise
                * reduction level.
                */
               if (cam->rgbBuffer[n] > REQUIRED_MAX_VALUE)
                  break;
            }
            if (cam->rgbBuffer[n] > REQUIRED_MAX_VALUE)
               break;
         }
         if (i >= 20) {
            strcpy(cam->msg, "impossible to find valid frame");
            return -1;
         }
      } else {
         strcpy(cam->msg, "validFrame has invalid value");
         return -1;
      }
   }

   // Convert yuv to rgb 
   yuv420p_to_rgb24(cam->yuvBuffer, cam->rgbBuffer, cam->imax, cam->jmax);

#endif
   return 0;
}

/**
 * webcam_getVideoSource - returns asked parameters.
 * command is defined by <i>command</i>,
 * result is copied to <i>result</i> string,
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/
int webcam_getVideoSource(struct camprop *cam, char *result, int command)
{
   int ret = 0;

#if defined(OS_LIN)
   struct video_picture pic;
   struct pwc_whitebalance whiteBalance;
   int param;

   switch (command) {

   case RESTOREUSER:
      if (ioctl(cam->cam_fd, VIDIOCPWCRUSER, NULL)) {
         strcpy(cam->msg, "Can't VIDIOCPWCRUSER");
         ret = 1;
      }
      break;

   case GETPICSETTINGS:
      if (ioctl(cam->cam_fd, VIDIOCGPICT, &pic)) {
         strcpy(cam->msg, "Can't VIDIOCGPICT");
         ret = 1;
      } else {
         sprintf(result, "%d %d %d %d", pic.brightness, pic.contrast,
                 pic.colour, pic.whiteness);
      }
      break;

   case RESTOREFACTORY:
      if (ioctl(cam->cam_fd, VIDIOCPWCFACTORY, NULL)) {
         strcpy(cam->msg, "Can't VIDIOCPWCFACTORY");
         ret = 1;
      }
      break;

   case GETGAIN:
      if (ioctl(cam->cam_fd, VIDIOCPWCGAGC, &param)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGAGC");
         ret = 1;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETSHARPNESS:
      if (ioctl(cam->cam_fd, VIDIOCPWCGCONTOUR, &param)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGCONTOUR");
         ret = 1;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETSHUTTER:
      sprintf(result, "%d", cam->shutterSpeed);
      break;

   case GETNOISE:
      if (ioctl(cam->cam_fd, VIDIOCPWCGDYNNOISE, &param)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGDYNNOISE");
         ret = 1;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETCOMPRESSION:
      if (ioctl(cam->cam_fd, VIDIOCPWCGCQUAL, &param)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGCQUAL");
         ret = 1;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETWHITEBALANCE:
      if (ioctl(cam->cam_fd, VIDIOCPWCGAWB, &whiteBalance)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGAWB");
         ret = 1;
      } else {
         switch (whiteBalance.mode) {
         case PWC_WB_AUTO:
            sprintf(result, "auto %d %d", whiteBalance.read_red,
                    whiteBalance.read_blue);
            break;
         case PWC_WB_MANUAL:
            sprintf(result, "manual %d %d", whiteBalance.manual_red,
                    whiteBalance.manual_blue);
            break;
         case PWC_WB_INDOOR:
            sprintf(result, "indoor");
            break;
         case PWC_WB_OUTDOOR:
            sprintf(result, "outdoor");
            break;
         case PWC_WB_FL:
            sprintf(result, "fl");
            break;
         default:
            break;
         }
      }
      break;

   case GETBACKLIGHT:
      if (ioctl(cam->cam_fd, VIDIOCPWCGBACKLIGHT, &param)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGBACKLIGHT");
         ret = 1;
      } else {
         if (param) {
            sprintf(result, "1");
         } else {
            sprintf(result, "0");
         }
      }
      break;

   case GETFLICKER:
      if (ioctl(cam->cam_fd, VIDIOCPWCGFLICKER, &param)) {
         strcpy(cam->msg, "Can't VIDIOCPWCGFLICKER");
         ret = 1;
      } else {
         if (param) {
            sprintf(result, "1");
         } else {
            sprintf(result, "0");
         }
      }
      break;

   default:
      strcpy(cam->msg, "command not found");
      ret = 1;
      break;
   }
#endif
   return ret;
}


/**
 * webcam_saveUser.
 * This function will write the current brightness, contrast,
 * colour and whiteness (gamma) settings into
 * the camera's internal EEPROM.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_saveUser(struct camprop *cam)
{

#if defined(OS_LIN)
   if (ioctl(cam->cam_fd, VIDIOCPWCSUSER, NULL)) {
      strcpy(cam->msg, "Can't VIDIOCPWCSUSER");
      return 1;
   }
#endif
   return 0;
}

/**
 * webcam_setPicSettings - sets brightness, contrast, 
 * colour and whiteness (gamma).
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_setPicSettings(struct camprop *cam, int brightness, int contrast,
                   int colour, int whiteness)
{

#if defined(OS_LIN)
   struct video_picture pic;

   if (ioctl(cam->cam_fd, VIDIOCGPICT, &pic)) {
      strcpy(cam->msg, "Can't VIDIOCGPICT");
      return 1;
   }

   pic.brightness = brightness;
   pic.contrast = contrast;
   pic.colour = colour;
   pic.whiteness = whiteness;

   if (ioctl(cam->cam_fd, VIDIOCSPICT, &pic)) {
      strcpy(cam->msg, "Can't VIDIOCSPICT");
      return 1;
   }
#endif
   return 0;
}

/**
 * webcam_setVideoSource - sets some video source parameters.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_setVideoSource(struct camprop *cam, int paramValue, int command)
{
   int ret = 0;

#if defined(OS_LIN)
   switch (command) {

   case SETGAIN:
      if (ioctl(cam->cam_fd, VIDIOCPWCSAGC, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSAGC");
         ret = 1;

      }
      break;

   case SETSHARPNESS:
      if (ioctl(cam->cam_fd, VIDIOCPWCSCONTOUR, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSCONTOUR");
         ret = 1;
      }
      break;

   case SETSHUTTER:
      if (ioctl(cam->cam_fd, VIDIOCPWCSSHUTTER, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSSHUTTER");
         ret = 1;
      }
      cam->shutterSpeed = paramValue;
      break;

   case SETNOISE:
      if (ioctl(cam->cam_fd, VIDIOCPWCSDYNNOISE, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSDYNNOISE");
         ret = 1;
      }
      break;

   case SETCOMPRESSION:
      if (ioctl(cam->cam_fd, VIDIOCPWCSCQUAL, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSCQUAL");
         ret = 1;
      }
      break;

   case SETBACKLIGHT:
      if (ioctl(cam->cam_fd, VIDIOCPWCSBACKLIGHT, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSBACKLIGHT");
         ret = 1;

      }
      break;

   case SETFLICKER:
      if (ioctl(cam->cam_fd, VIDIOCPWCSFLICKER, &paramValue)) {
         strcpy(cam->msg, "Can't VIDIOCPWCSFLICKER");
         ret = 1;
      }
      break;

   default:
      strcpy(cam->msg, "command not found");
      ret = 1;
      break;
   }
#endif

   return ret;
}

/**
 * setWhiteBalance sets White Balance.
 * Arguments:
 * - mode - mode name
 * - red, blue - red and blue levels - valid only when mode is "manual"
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_setWhiteBalance(struct camprop *cam, char *mode, int red, int blue)
{

#if defined(OS_LIN)
   struct pwc_whitebalance whiteBalance;

   whiteBalance.manual_red = red;
   whiteBalance.manual_blue = blue;

   if (strcmp(mode, "manual") == 0) {
      whiteBalance.mode = PWC_WB_MANUAL;
   } else if (strcmp(mode, "auto") == 0) {
      whiteBalance.mode = PWC_WB_AUTO;
   } else if (strcmp(mode, "indoor") == 0) {
      whiteBalance.mode = PWC_WB_INDOOR;
   } else if (strcmp(mode, "outdoor") == 0) {
      whiteBalance.mode = PWC_WB_OUTDOOR;
   } else if (strcmp(mode, "fl") == 0) {
      whiteBalance.mode = PWC_WB_FL;
   } else {
      sprintf(cam->msg, "%s - unknown whiteBalance mode\n%s", mode,
              "you can use modes: manual, auto, indoor, outdoor, fl");
      return 1;
   }

   if (ioctl(cam->cam_fd, VIDIOCPWCSAWB, &whiteBalance)) {
      strcpy(cam->msg, "Can't VIDIOCPWCSAWB");
      return 1;
   }
#endif

   return 0;
}


/******************************************************************/
/*  Fonctions d'affichage et de capture video (M. Pujol)          */
/*                                                                */
/*  Pour Windows uniquement                                       */
/******************************************************************/
#if defined(OS_WIN)


/**
 * startVideoPreview
 *    starts video preview
 *    
 * Parameters:
 *    cam : camera struct
 *    previewRate : expoure time (frame/seconds)
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    show the preview window
 */
int startVideoPreview(struct camprop *cam, int previewRate) {
   int result;
   RECT rect;

   // je fixe la frequence de images 
   cam->capture->setPreviewRate(previewRate); 
   // j'autorise les changements d'echelle
   cam->capture->setPreviewScale(TRUE);
   // je desactive le mode overlay, au cas ou il serait actif
   cam->capture->setOverlay(FALSE);
   // j'adapte la taille de la fenetre
   rect.left = 0;          // position relative par rapport à la fenetre parent
   rect.top  = 0;
   rect.right = cam->capture->getImageWidth();
   rect.bottom = cam->capture->getImageHeight();
   cam->capture->setWindowPosition(&rect);

   // j'active la prévisualisation
   result = cam->capture->setPreview(TRUE);
   return result;
}

/**
 * stopVideoPreview
 *    stops video preview
 *    
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    hide the preview window
 */
int stopVideoPreview(struct camprop *cam) {
   int result;

   // j'arrete la prévisualisation
   result = cam->capture->setPreview(FALSE);

   return result;
}

    
/**
 * startVideoCapture
 *    starts video capture
 *    
 * Parameters:
 *    cam : camera struct
 *    extime : exposure time (seconds)
 *    microSecPerFrame : rate (milliseconds per frame)
 *    fileName  : output film name (AVI)
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int startVideoCapture(struct camprop *cam, unsigned short exptime, unsigned long microSecPerFrame, char * fileName) {
   int result;

   char ligne [255];
   // je change le status de la camera
   sprintf(ligne, "status_cam%d", cam->camno);
   Tcl_SetVar(cam->interp, ligne, "exp", TCL_GLOBAL_ONLY);

   // duree de la capture limitee dans le temps(en seconde)
   cam->capture->setLimitEnabled(TRUE);
   cam->capture->setTimeLimit(exptime);
   // fréquence de la capture (millisecondes par frame)
   cam->capture->setCaptureRate( microSecPerFrame);
   // nombre maxi de frames dans le fichier AVI (32000 par defaut)
   cam->capture->setIndexSize (32767); 
   // ne pas enregistrer le son
   cam->capture->setCaptureAudio(FALSE); 
   // ne pas utiliser le controle de peripheriques  MCI
   cam->capture->setMCIControl(FALSE); 
   // je declare le nom du fichier de capture AVI
   cam->capture->setCaptureFileName(fileName);
   // je lance la capture
   if( cam->cropCapture == NULL ) {
      result =  cam->capture->startCapture();
   } else {
      result =  cam->cropCapture->startCropCapture();
   }

   return result;

}

/**
 * stopVideoCapture
 *    stops video capture
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    disable the callback  and stop capture 
 */
int stopVideoCapture(struct camprop *cam) {
   return cam->capture->abortCapture();
}


/**
 * startVideoCrop
 *    start cropped mode  
 *    the crop rectangle is specified with setVideoCropRect()
 *    before starting or when video is running
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int startVideoCrop(struct camprop *cam) {

   cam->cropCapture = new CCropCapture(cam->capture);
   cam->cropCapture->startCropPreview();

   return TRUE; 

}

/**
 * stopVideoCrop
 *    stop cropped mode
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    disable the callback  and stop video
 */
int stopVideoCrop(struct camprop *cam) {

   cam->cropCapture->stopCropPreview();
   delete cam->cropCapture;
   cam->cropCapture = NULL;

   return TRUE; 
}

/**
 * setVideoCropRect
 *    modifies the size of the crop rectangle  
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int setVideoCropRect(struct camprop *cam, long x1, long y1, long x2, long y2) {
   int result = TRUE;

   if(result==TRUE) { cam->cropCapture->setX1(x1); }
   if(result==TRUE) { cam->cropCapture->setY1(y1); }
   if(result==TRUE) { cam->cropCapture->setX2(x2); }
   if(result==TRUE) { cam->cropCapture->setY2(y2); }

   return result;

}


//==================================================================
//
// Implementation des methodes de CGuidingListener
//
//==================================================================

CGuidingListener::CGuidingListener(Tcl_Interp * interp)  {
   this->interp  = interp;
   tclStartProc         = NULL;
   tclChangeOriginProc  = NULL;
   tclMoveTargetProc    = NULL;
};

CGuidingListener::~CGuidingListener() { 
   free(tclStartProc);
   free(tclChangeOriginProc);
   free(tclMoveTargetProc);
};

void CGuidingListener::setTclStartProc(char * value) {
   if(tclStartProc != NULL ) free(tclStartProc);
   tclStartProc = strdup(value);
}

void CGuidingListener::setTclChangeOriginProc(char * value) {
   if(tclChangeOriginProc != NULL ) free(tclChangeOriginProc);
   tclChangeOriginProc = strdup(value);
}

void CGuidingListener::setTclMoveTargetProc(char * value) {
   if(tclMoveTargetProc != NULL ) free(tclMoveTargetProc);
   tclMoveTargetProc = strdup(value);
}

/**
 * onChangeGuidingStarted
 *    call TCL procedure on start/stop 
 * Parameters:
 *    state : 1=start , stop=0
 * Results:
 *    none
 * Side effects:
 *    calls tclStartProc  with state parameter
 *    example : "mynamespace::onStartStop 1"
 */
void CGuidingListener::onChangeGuidingStarted(int state) {
   char ligne[512];

   // j'execute la commande TCL
   if(tclStartProc != NULL ) {
      sprintf( ligne, "%s %d", tclStartProc, state);
      if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
         // Traitement d'un erreur TCL dans un process en background :
         // En cas d'erreur dans la commande TCL, je force l'interpreteur
         // a signaler l'erreur par le process en foreground 
         // pour eviter que l'erreur ne passe inapercue
         Tcl_BackgroundError(interp);
      }
   }
}

void CGuidingListener::onChangeOrigin(int x0, int y0) {
   char ligne[1024];
   
   
   // j'execute la commande TCL
   if( tclChangeOriginProc != NULL ) {
      sprintf( ligne, "%s %d %d", tclChangeOriginProc, x0, y0);
      if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
         // Traitement d'un erreur TCL dans un process en background :
         // En cas d'erreur dans la commande TCL, je force l'interpreteur
         // a signaler l'erreur par le process en foreground 
         // pour eviter que l'erreur ne passe inapercue
         Tcl_BackgroundError(interp);
      }
   }
   
   
}

void CGuidingListener::onMoveTarget(int x, int y, int alphaDelay, int deltaDelay) {
   char ligne[1024];

   // j'execute la commande TCL
   if( tclMoveTargetProc != NULL ) {
      sprintf( ligne, "%s %ld %ld %ld %ld ", tclMoveTargetProc, x , y, alphaDelay, deltaDelay);
      if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
         // Traitement d'un erreur TCL dans un process en background :
         // En cas d'erreur dans la commande TCL, je force l'interpreteur
         // a signaler l'erreur par le process en foreground 
         // pour eviter que l'erreur ne passe inapercue
         Tcl_BackgroundError(interp);
      }
   }

}


//==================================================================
//
// Implementation des methodes de CCaptureListener
//
//==================================================================

CCaptureListener::CCaptureListener(Tcl_Interp * interp, int camno)  {
   this->interp  = interp;
   this->camno   = camno;
   tclStatusVariable = NULL;
}

CCaptureListener::~CCaptureListener() { 
   //if(tclEndProc)  free(tclEndProc);
}

void CCaptureListener::setTclStatusVariable(char * value) {
   if(tclStatusVariable != NULL ) free(tclStatusVariable);
   tclStatusVariable = strdup(value);
}



/**
 * startVideoCrop
 *    start cropped mode
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int  CCaptureListener::onNewStatus(int statusID, char * message) {

   switch (statusID) {
   case IDS_CAP_BEGIN :
      
      break;
   case IDS_CAP_STAT_CAP_INIT:
   case IDS_CAP_SEQ_MSGSTOP :
      // rien a faire
      break;

   case IDS_CAP_STAT_VIDEOCURRENT:
      // nb de trames capturees en cours / nb trames ignorees

      // je mets a jour la variable TCL
      if( tclStatusVariable != NULL ) {
         if( Tcl_SetVar2(interp, tclStatusVariable, (char *) NULL, message, TCL_GLOBAL_ONLY) == NULL ) {
            // Traitement d'un erreur TCL dans un process en background :
            // En cas d'erreur dans la commande TCL, je force l'interpreteur
            // a signaler l'erreur par le process en foreground 
            // pour eviter que l'erreur ne passe inapercue
            Tcl_BackgroundError(interp);
         }
         Tcl_Eval(interp, "update");

      }

          
      break;

   case IDS_CAP_STAT_VIDEOONLY :
      // bilan de la capture (nb trames capturees / nb trames ignorees)
      // je mets a jour la variable TCL
      if( tclStatusVariable != NULL ) {
         if( Tcl_SetVar2(interp, tclStatusVariable, (char *) NULL, message, TCL_GLOBAL_ONLY) == NULL ) {
            // Traitement d'un erreur TCL dans un process en background :
            // En cas d'erreur dans la commande TCL, je force l'interpreteur
            // a signaler l'erreur par le process en foreground 
            // pour eviter que l'erreur ne passe inapercue
            Tcl_BackgroundError(interp);
         }
         Tcl_Eval(interp, "update");

      }

      break;

   //case IDS_CAP_STAT_CAP_FINI:
   case IDS_CAP_END :
      {
         char ligne [255];
         
         // je change le status de la camera
         sprintf(ligne, "status_cam%d", this->camno);
         Tcl_SetVar(this->interp, ligne, "stand", TCL_GLOBAL_ONLY);
      }

      /*
      // j'execute la commande TCL
      if( tclEndProc != NULL ) {
         result = Tcl_Eval(interp, tclEndProc);
         if( result == TCL_ERROR) {
            // Traitement d'un erreur TCL dans un process en background :
            // En cas d'erreur dans la commande TCL, je force l'interpreteur
            // a signaler l'erreur par le process en foreground 
            // pour eviter que l'erreur ne passe inapercue
            Tcl_BackgroundError(interp);
         }
      }
      */
      break;

    }

   return TRUE;
}

int  CCaptureListener::onNewError(int errID, char * message) {
   int result = TRUE;

   MessageBox(NULL, message, "capture", MB_OK | MB_ICONEXCLAMATION) ;
   return result;

}



/*****************************************************************/
#endif  //defined(OS_WIN)
/*****************************************************************/
