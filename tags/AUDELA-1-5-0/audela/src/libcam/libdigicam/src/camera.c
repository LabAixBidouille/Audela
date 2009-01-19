/* camera.c
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 *  your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * Ceci est le fichier contenant le driver de la camera
 *
 * La structure "camprop" peut etre adaptee
 * dans le fichier camera.h
 */

// $Id: camera.c,v 1.11 2009-01-12 18:08:06 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#include <crtdbg.h>                 // pour debuggage memoire
#include <usb.h>                    // pour libusb
#endif

#include <string.h>
#include <stdlib.h>

#include "camera.h"
#include <libgphoto2.h>

#ifdef WIN32
#define SLEEP(t)  Sleep(t)
#else
#include <unistd.h>          // for usleep()
#define SLEEP(t)  usleep(t*1000)
#endif


/*
*  Definition of different cameras supported by this driver
*  (see declaration in libstruc.h)
*/

struct camini CAM_INI[] = {
   {"DSLR",			/* camera name */
    "dslr",			/* camera product */
     "cmos",		/* ccd name */
      3088, 2086,			/* maxx maxy */
      0, 0,			/* overscans x */
      0, 0,			/* overscans y */
      7.4e-6, 7.4e-6,		/* photosite dim (m) */
      65535.,			/* observed saturation */
      1.,			/* filling factor */
      2.,			/* gain (e/adu) */
      25.,			/* readnoise (e) */
      1, 1,			/* default bin x,y */
      1.,			/* default exptime */
      1,				/* default state of shutter (1=synchro) */
      1,				/* default num buf for the image */
      1,				/* default num tel for the coordinates taken */
      0,				/* default port index (0=lpt1) */
      1,				/* default cooler index (1=on) */
      -15.,			/* default value for temperature checked */
      1,				/* default color mask if exists (1=cfa) */
      0,				/* default overscan taken in acquisition (0=no) */
      1.				/* default focal lenght of front optic system */
   },   
   CAM_INI_NULL
};

enum  {
   REMOTE_INTERNAL = 0,
   REMOTE_LINK     = 1,
   REMOTE_MANUEL   = 2
};

// j'utilise le niveau de debug declar� dans libcam.c
int debug_level;

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
int cam_setLongExposureDevice(struct camprop *cam, unsigned char value);
int cam_copyImage(struct camprop *cam, char *imageData, unsigned long imageLength, char *imageMime);

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

struct _PrivateParams {
   GPhotoSession *gphotoSession;                // parametres internes libgphoto2
   char gphotoWinDllDir[1024];        // repertoire des DDL gphoto2 pour windows
   int autoLoadFlag;
   int autoDeleteFlag;          // 
   int useCf;                   // 0=ne pas utiliser la carte memoire de l'APN, 1=utiliser la carte memoire de l'APN
   char imageFolder[1024];      // repertoire courant dans la memoire de la camera
   char imageFile[1024];        // nom du fichier en cours de traitement ( entre startExp et read_ccd) 
   int  driveMode;
   char quality[DIGICAM_QUALITY_LENGTH];
   int debug;
};

char *canonQuality[] =
{
      "Large:Fine"    ,
      "Large:Normal" ,
      "Middle:Fine"  ,
      "Middle:Normal",
      "Small:Fine"   ,
      "Small:Normal" ,
      "CRW"  ,
       "" 
};


/*
// Pour debuggage des fuites memoire
#ifdef WIN32
_HFILE hLogFile;
_CrtMemState memState1;
_CrtMemState memState2;
_CrtMemState memStateDiff;

void writeLog( char * message ) {
   DWORD nbByteWritten;
   
   WriteFile(hLogFile, message,strlen(message)+1, &nbByteWritten, NULL);
}
#endif
*/

/*
*  Definition a structure specific for this driver 
*  (see declaration in camera.h)
*/

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
int cam_init(struct camprop *cam, int argc, char **argv)
{
   int i;
   int result;
   char cameraModel[1024];
   char cameraPath[1024];
   
   cam->params = malloc(sizeof(PrivateParams));
   
   cam->authorized = 1;
   cam->params->debug = 0;
   strcpy(cam->params->gphotoWinDllDir, "../bin");            // default DLL directory
   
   // je traite les parametres
   for (i = 3; i < argc - 1; i++) {
      if (strcmp(argv[i], "-gphoto2_win_dll_dir") == 0) {
         strncpy(cam->params->gphotoWinDllDir , argv[i + 1], 1024);
#ifdef WIN32
         {
            unsigned int c;
            for(c=0; c<strlen(cam->params->gphotoWinDllDir); c++ ) {
               if( cam->params->gphotoWinDllDir[c] == '/' ) {
                  cam->params->gphotoWinDllDir[c] = '\\';
               }
            }
         }
#endif
      }
      if (strcmp(argv[i], "-debug_cam") == 0) {
         if ( i +1 <  argc ) {
	         cam->params->debug = atoi(argv[i + 1]);
         }
	   }

   }
   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
   
   // je verifie le repertoire des DLL de gphoto2 
   // ce parametre n'est pas utilise sous Linux car gphoto2 est installe 
   // dans les repertoires systeme /usr/...
   if( strlen(cam->params->gphotoWinDllDir) == 0 ) {
      sprintf(cam->msg, "gphoto2_win_dll_dir is empty");
      return -1;
   }    

   // j'initialise la session
   result = libgphoto_openSession(&cam->params->gphotoSession, cam->params->gphotoWinDllDir, cam->params->debug);
   if ( result != LIBGPHOTO_OK ) {
      strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
      return -1;
   }

   // je detecte la camera
   result = libgphoto_detectCamera(cam->params->gphotoSession, cameraModel, cameraPath);
   if ( result != LIBGPHOTO_OK ) {
      strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
      libgphoto_closeSession(cam->params->gphotoSession);
      return -1;
   }

   // je connecte la camera
   result = libgphoto_openCamera(cam->params->gphotoSession, cameraModel, cameraPath);
   if ( result != LIBGPHOTO_OK ) {
      strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
      libgphoto_closeSession(cam->params->gphotoSession);
      return -1;
   }

   // je configure le mode de declenchement de la pose par defaut
   result = cam_setLonguePose(cam, REMOTE_INTERNAL);
   if ( result != 0 ) {
      cam_close(cam);
      return -1;
   }

   // je verifie si on peut selectionner le temps de pose (depend du modele d'APN)
   result = libgphoto_getTimeValue(cam->params->gphotoSession, &cam->exptime); 
   if ( result != 0 ) {
      cam_close(cam);
      return -1;
   }

   cam_setAutoDeleteFlag(cam, 1);
   cam_setAutoLoadFlag(cam,1);
   cam_setDriveMode(cam, 0);
   cam_setUseCf(cam, 0);
   cam_setQuality(cam, canonQuality[0]);
   cam->exptime = 1;
   return 0;
}


static int cam_close(struct camprop *cam) {   
   // je deconnecte la camera
   libgphoto_closeCamera(cam->params->gphotoSession);
   
   // je liferme la session
   libgphoto_closeSession(cam->params->gphotoSession);

   if( cam->params != NULL) {
      free(cam->params);
      cam->params = NULL;
   }
   
   return 0;
}

int cam_setLonguePose(struct camprop *cam, int value) {   
   int result;

   switch (value) {
         case 1 : 
            cam->longuepose = REMOTE_LINK;
            cam->capabilities.expTimeCommand = 1;
            // je programme le temps de pose  a "bulb"
            if( cam->capabilities.expTimeCommand == 1 ) {
               result = libgphoto_setTimeValue(cam->params->gphotoSession, -1.0);         
            }

            result = 0;
            break;
         case 2 : 
            cam->longuepose = REMOTE_MANUEL;
            cam->capabilities.expTimeCommand = 1;
            result = 0;
            break;
         case 0 : 
            {
               cam->longuepose = REMOTE_INTERNAL;
               cam->capabilities.expTimeCommand = 1;
               result = 0;
               break;
            }
         default :
            result = -1;

         }

   return result;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   int iswap;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;

   if (cam->x1 > cam->x2) {
      iswap= cam->x1;
      cam->x1 = cam->x2;
      cam->x2 = iswap;
   }

   if (cam->x1 < 0) {
      cam->x1 = 0;
   }
   if (cam->x2 > maxx - 1) {
      cam->x2 = maxx - 1;
   }
   
   if (cam->y1 > cam->y2) {
      iswap= cam->y1;
      cam->y1 = cam->y2;
      cam->y2 = iswap;
   }
   if (cam->y1 < 0) {
      cam->y1 = 0;
   }
   if (cam->y2 > maxy - 1) {
      cam->y2 = maxy - 1;
   }
   cam->w = ( cam->x2 - cam->x1) / cam->binx + 1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = ( cam->y2 - cam->y1) / cam->biny + 1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
   int result;

   if (cam->authorized == 1) {
      switch (cam->longuepose) {
      case REMOTE_INTERNAL : 

         if( cam->capabilities.expTimeCommand == 1 ) {
            result = libgphoto_setTimeValue(cam->params->gphotoSession, cam->exptime);  
            if(result == LIBGPHOTO_OK) {
               result = libgphoto_setQuality(cam->params->gphotoSession, cam->params->quality); 
               if(result == LIBGPHOTO_OK) {
                  result = libgphoto_setDriveMode(cam->params->gphotoSession, cam->params->driveMode);         
               }
            }
         } else {
            result = LIBGPHOTO_OK;
         }
         if (result == LIBGPHOTO_OK ) {
            // Comme libgphoto_captureImage est bloquant, on pourra lancer cam_read_ccd  
            // immediatement apres la fin de cam_start_exp
            cam->exptimeTimer = 0.0;
         } else {
            // je retourne un message d'erreur
            strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
         }
        

         break;
      case REMOTE_LINK : 
         if( cam->exptime >= 0.1 ) {
            if( cam->capabilities.expTimeCommand == 1 ) {
               // je programme le temps de pose 
               result = libgphoto_setTimeValue(cam->params->gphotoSession, cam->exptime);         
            }
            result = libgphoto_setQuality(cam->params->gphotoSession, cam->params->quality);         
            result = libgphoto_setDriveMode(cam->params->gphotoSession, cam->params->driveMode);         
            // je lance une longue pose 
            if( cam->params->useCf == 1 ) {
               result = libgphoto_startLongExposure(cam->params->gphotoSession, 8);
            } else {
               result = libgphoto_startLongExposure(cam->params->gphotoSession, 2);
            }
            if (result == LIBGPHOTO_OK ) {
               // je lance une acquisition
               cam_setLongExposureDevice(cam, cam->longueposestart );
            } else {
               // je retourne un message d'erreur
               strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
            }
         } else {
            sprintf( cam->msg, "%f second with remote link is too short.",cam->exptime);
         }
         break;
      case REMOTE_MANUEL :
         if( cam->capabilities.expTimeCommand == 1 ) {
            // je programme le temps de pose 
            result = libgphoto_setTimeValue(cam->params->gphotoSession, cam->exptime);         
         }
         result = libgphoto_setQuality(cam->params->gphotoSession, cam->params->quality);         
         result = libgphoto_setDriveMode(cam->params->gphotoSession, cam->params->driveMode);         
         if (result == LIBGPHOTO_OK) {
            // je demarre la longue pose
            cam_setLongExposureDevice(cam, cam->longueposestart );
            cam->exptime = 0;
         } else {
            // je retourne un message d'erreur
            strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
         }
         break;
      default : 
         break;
      }

   } else {
      // je retourne un message d'erreur
      strcpy(cam->msg, "Camera busy");
   }

}

void cam_stop_exp(struct camprop *cam)
{
   // j'arrete l'acquisition
   if ( cam->longuepose == REMOTE_LINK ) {
      cam_setLongExposureDevice(cam, cam->longueposestop );

   } else if ( cam->longuepose == REMOTE_MANUEL) {
      // rien a faire, c'est l'utilisateur qui arrete la pose 
   } 
}


void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
   int result;
   char *imageData, *imageMime;
   unsigned long imageLength;

   
   if (cam->authorized == 1) {
      switch (cam->longuepose) {
      case REMOTE_INTERNAL : 
         // rien a faire
         break;
      case REMOTE_LINK : 
         // j'arrete l'acquisition
         cam_setLongExposureDevice(cam, cam->longueposestop );
         break;
      case REMOTE_MANUEL :
         // rien a faire
         break;
      }
      
      if( cam->params->useCf == 1 ) {
         // si la carte CF est utilise 
         result = libgphoto_captureImage(cam->params->gphotoSession, cam->params->imageFolder, cam->params->imageFile);  
         if ( result == LIBGPHOTO_OK ) {
            // je verifie s'il faut charger immediatement
            if( cam->params->autoLoadFlag == 1 ) {
               // je charge l'image  
               result = libgphoto_loadImage(cam->params->gphotoSession, cam->params->imageFolder, cam->params->imageFile, &imageData, &imageLength, &imageMime);
               if (result == LIBGPHOTO_OK) {
                  result = cam_copyImage(cam, imageData, imageLength, imageMime);
                  if (result == LIBGPHOTO_OK  && cam->params->autoDeleteFlag == 1 ) {
                     // je supprime l'image sur la carte memoire de l'appareil
                     result = libgphoto_deleteImage (cam->params->gphotoSession, cam->params->imageFolder, cam->params->imageFile);
                  }
               }
            }
         }
         if ( result != LIBGPHOTO_OK ) {
            // je retourne un message d'erreur
            strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
         }
         // je purge le nom du fichier
         strcpy(cam->params->imageFile, "");
         strcpy(cam->params->imageFolder, "");      
      } else {
         // si la carte CF n'est pas utilisee
         if( cam->params->autoLoadFlag == 1 ) {
            // je capture et charge l'image  
            result = libgphoto_captureAndLoadImageWithoutCF(cam->params->gphotoSession, 
               cam->params->imageFolder, cam->params->imageFile, 
               &imageData, &imageLength, &imageMime);    
            if (result == LIBGPHOTO_OK) {
               result = cam_copyImage(cam, imageData, imageLength, imageMime);
               if (result == LIBGPHOTO_OK ) {
                  // je supprime l'image 
                  result = libgphoto_deleteImage (cam->params->gphotoSession, 
                     cam->params->imageFolder, cam->params->imageFile);
               }
            } 
            // je purge le nom du fichier
            strcpy(cam->params->imageFile, "");
            strcpy(cam->params->imageFolder, "");      
         } else {
            // je capture une image sans la charger
            result = libgphoto_captureImageWithoutCF(cam->params->gphotoSession);    
         }
      }
      if (result != LIBGPHOTO_OK) {
         // je retourne un message d'erreur
         strcpy(cam->msg, libgphoto_getLastErrorMessage(cam->params->gphotoSession));
      }
   } else {
      // je retourne un message d'erreur
      strcpy(cam->msg, "Camera busy");
   }     

}


int cam_loadLastImage(struct camprop *cam)
{
   int result;
   char *imageData, *imageMime;
   unsigned long imageLength;
   
   if(strcmp(cam->params->imageFile, "") != 0) { 
      // je charge l'image   
      result = libgphoto_loadImage(cam->params->gphotoSession, 
         cam->params->imageFolder, cam->params->imageFile, 
         &imageData, &imageLength, &imageMime);
      if (result == LIBGPHOTO_OK )  {
         result = cam_copyImage(cam, imageData, imageLength, imageMime);
         if (result == LIBGPHOTO_OK  && cam->params->autoDeleteFlag == 1 ) {
            // je supprime l'image sur la carte memoire de l'appareil
            result = libgphoto_deleteImage (cam->params->gphotoSession, 
               cam->params->imageFolder, cam->params->imageFile);
         }
      }
      // je purge le nom du fichier
      strcpy(cam->params->imageFile, "");
      strcpy(cam->params->imageFolder, "");
      if ( result != LIBGPHOTO_OK ) {
         // je retourne un message d'erreur
         sprintf(cam->msg, "Error libgphoto_loadImage : %s", libgphoto_getLastErrorMessage(cam->params->gphotoSession));
      }
   } else {
      strcpy(cam->msg, "No last image");
      result = LIBGPHOTO_ERROR;
   }
   return result;
}


int cam_copyImage(struct camprop *cam, char *imageData, unsigned long imageLength, char *imageMime)
{
   int result;

   // je copie les valeurs a retourner
   cam->pixel_data = malloc(imageLength);
   if( cam->pixel_data != NULL) {
      memcpy(cam->pixel_data, imageData, imageLength);
      cam->pixel_size  = imageLength;         
      if (strcmp(imageMime, "image/x-canon-raw" ) == 0 ) {
         strcpy(cam->pixels_classe, "CLASS_GRAY");
         strcpy(cam->pixels_compression, "COMPRESS_RAW");
         strcpy(cam->pixels_format, "FORMAT_SHORT");
         cam->pixels_reverse_x = 0;
         cam->pixels_reverse_y = 0;
         result = LIBGPHOTO_OK;
      } else if ( strcmp(imageMime, "image/jpeg") == 0 ) {
         strcpy(cam->pixels_classe, "CLASS_RGB");
         strcpy(cam->pixels_compression, "COMPRESS_JPEG");
         strcpy(cam->pixels_format, "FORMAT_SHORT");
         cam->pixels_reverse_x = 0;
         cam->pixels_reverse_y = 0;
         result = LIBGPHOTO_OK;
      } else {
         // je retourne un message d'erreur
         sprintf(cam->msg, "unknown format %s", imageMime);
         result = LIBGPHOTO_ERROR;
      }
   } else {
      // je retourne un message d'erreur
      sprintf(cam->msg, "cam_copyImage: Not enougt memory");
      result = LIBGPHOTO_ERROR;
   }
   return result;
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
}



/*
 * -----------------------------------------------------------------------------
 *  cam_getSystemServiceState()
 *
 *  retourne l'etat du service systeme d'acquisition des images
 *   
 *  return 
 *     1 systeme d�marr�
 *     0 systeme arrete
 *    -1 erreur 
 * -----------------------------------------------------------------------------
 */
int  cam_getSystemServiceState(struct camprop *cam) {
   int result = -1;

#ifdef WIN32
   SC_HANDLE hManager;
   SC_HANDLE hService;
   SERVICE_STATUS ssStatus;

   hManager = OpenSCManager(NULL,NULL,SC_MANAGER_CONNECT);
   if( hManager == 0 ) {
      sprintf(cam->msg, "OpenSCManager error=%d", GetLastError());
      result = -1;
   } else {
      
      hService = OpenService( hManager,"stisvc", SERVICE_QUERY_STATUS|SERVICE_START|SERVICE_STOP);
      if( hService == 0 ) {
         sprintf(cam->msg, "OpenService error=%d", GetLastError());
         result = -1;
      } else {
         
         if ( QueryServiceStatus( hService, &ssStatus ) ) {      
            if ( ssStatus.dwCurrentState == SERVICE_RUNNING ) {
               result = 1;
            } else {
               result = 0;
            }
            
         } else {
            sprintf(cam->msg, "QueryServiceStatus error=%d", GetLastError());
            result = -1;
         }
         CloseServiceHandle(hService);
      }
      CloseServiceHandle(hManager);
   }
#endif

   return result;
}


/*
 * -----------------------------------------------------------------------------
 *  cam_getSystemServiceState()
 *
 *  retourne l'etat du service systeme d'acquisition des images
 *   
 *  parametre 
 *     si state =1, alors demarrer le service
 *     si state =0, alors arreter le service
 *  return 
 *     0 OK
 *    -1 erreur 
 * -----------------------------------------------------------------------------
 */
int cam_setSystemServiceState(struct camprop *cam, int state) {
   int result = -1;

#ifdef WIN32
   SC_HANDLE hManager;
   SC_HANDLE hService;
   SERVICE_STATUS ssStatus;

   hManager = OpenSCManager(NULL,NULL,SC_MANAGER_CONNECT);
   if( hManager == 0 ) {
      sprintf(cam->msg, "OpenSCManager error=%d", GetLastError());
      result = -1;
   } else {
      
      hService = OpenService( hManager,"stisvc", SERVICE_QUERY_STATUS|SERVICE_START|SERVICE_STOP);
      if( hService == 0 ) {
         sprintf(cam->msg, "OpenService error=%d", GetLastError());
         result = -1;
      } else {
         
         if( state == 0  ) {
            if( ControlService( hService, SERVICE_CONTROL_STOP, &ssStatus) ) {
               result = 0;
            } else {
               sprintf(cam->msg, "stopService error=%d", GetLastError());
               result = -1;
            }            
         } else {
            if (StartService(hService, 0, NULL) )  {
               result = 0;
            } else {
               sprintf(cam->msg, "startService error=%d", GetLastError());
               result = -1;
            }
         }
         
         CloseServiceHandle(hService);
      }
      CloseServiceHandle(hManager);
   }
#endif

return result;
}

/**
 * cam_setLongExposureDevice 
 *    writes <i>value</i> to the parallel port.
 * 
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/
int cam_setLongExposureDevice(struct camprop *cam, unsigned char value)
{
   char ligne[256];
   int result;

   // j'envoie une commande � la liaison
   // exemple "link1 bit 0 1"
   sprintf(ligne, "link%d bit %d %d", cam->longueposelinkno, cam->longueposelinkbit, value);
   if( Tcl_Eval(cam->interpCam, ligne) == TCL_ERROR) {
      result = -1;
   } else {
      result = 0;
   }

   return result;
}

/**
 * cam_checkQuality 
 *    check quality exits
 * 
 * Returns value:
 * - 0 when success.
 * - -1 if quality not found
*/
int  cam_checkQuality(char *quality)
{
   int result;

   int i = 0;
   while ( canonQuality[i][0] != 0 ) {
      if( strcmp(canonQuality[i], quality) == 0  ) {
         result = 0;
         break;
      }
      i++;
   }
   if( canonQuality[i][0] == 0 ) {
        result = -1;
   }

   return result;
}

/**
 * cam_getQualityList 
 *    returns quality list values
 * 
 * Returns value:
 *  0 
 *  
*/
int  cam_getQualityList(char *list)
{

   int i = 0;
   strcpy(list, "");
   while ( canonQuality[i][0] != 0 ) {
      strcat( list, canonQuality[i]);
      strcat( list, " ");
      i++;
   }

   return 0;
}

/**
 * cam_getAutoLoadFlag 
 *    returns "autoDeleteFlag" state
 * 
 * Returns value:
 *  0 or 1 , or -1 if errror
 *  
*/
int  cam_getAutoLoadFlag(struct camprop *cam) {
   return cam->params->autoLoadFlag; 
}

/**
 * cam_setAutoDeleteFlag 
 *    set "autoLoadFlag" state
 * 
 * Returns value:
 *  0 if OK , -1 if error
 *  
*/
int  cam_setAutoLoadFlag(struct camprop *cam, int value) {
   int result = 0;
   cam->params->autoLoadFlag  = value;
   return result;
}

/**
 * cam_getAutoDeleteFlag 
 *    returns "autoDeleteFlag" state
 * 
 * Returns value:
 *  0 or 1 , or -1 if error
 *  
*/
int  cam_getAutoDeleteFlag(struct camprop *cam) {
   return cam->params->autoDeleteFlag; 
}

/**
 * cam_setAutoDeleteFlag 
 *    set "autoDeleteFlag" state
 * 
 * Returns value:
 *  0 if OK , -1 if error
 *  
*/
int  cam_setAutoDeleteFlag(struct camprop *cam, int value) {
   int result = 0;
   cam->params->autoDeleteFlag  = value;
   return result;
}

/**
 * cam_getDriverMode 
 *    returns "driverMode" state
 * 
 * Returns value:
 *  0 or 1 , or -1 if error
 *  
*/
int  cam_getDriveMode(struct camprop *cam) {
   return cam->params->driveMode; 
}

/**
 * cam_setDriverMode 
 *    set "driverMode" state
 * 
 * Returns value:
 *  0 if OK , -1 if error
 *  
*/
int  cam_setDriveMode(struct camprop *cam, int value) {
   int result = 0;
   cam->params->driveMode  = value;
   return result;
}

/**
 * cam_getQuality 
 *    returns "driverMode" state
 * 
 * Returns value:
 *  0 or 1 , or -1 if error
 *  
*/
int cam_getQuality(struct camprop *cam, char * value) {
   int result = 0;
   strcpy(value, cam->params->quality);
   return result; 
}

/**
 * cam_setQuality 
 *    set "driverMode" state
 * 
 * Returns value:
 *  0 if OK , -1 if error
 *  
*/
int cam_setQuality(struct camprop *cam, char * value) {
   int result = 0;
   strcpy(cam->params->quality, value);
   return result;
}


/**
 * cam_getUseCF 
 *    returns "useCF" state
 * 
 * Returns value:
 *  0 
 *  
*/
int  cam_getUseCf(struct camprop *cam) {
   return cam->params->useCf; 
}

/**
 * cam_setUseCF 
 *    returns quality list values
 * 
 * Returns value:
 *  0 
 *  
*/
int  cam_setUseCf(struct camprop *cam, int value) {
   int result = -1;


   // je verifie que le nouveau mode est applicable, en particulier dans le cas ou
   // la carte memoire CF  est requise
   if ( value == 0 ) {
      result = libgphoto_setTransfertMode(cam->params->gphotoSession,0);
   } else {
      result = libgphoto_setTransfertMode(cam->params->gphotoSession,8);
   }

   if (result == LIBGPHOTO_OK) {
      cam->params->useCf  = value;
   } else {
      if( value == 1 ) {
         sprintf(cam->msg, "Memory CF is missing. %s", libgphoto_getLastErrorMessage(cam->params->gphotoSession));
      }
   }
   return result;
}

/**
 * cam_getDebug 
 *    get debug level ( 0 or 1 )
 * 
 * Returns value:
 *   debug level
 *  
*/
int  cam_getDebug(struct camprop *cam) {
   return cam->params->debug;
}

/**
 * cam_setDebug 
 *    set debug level ( 0 or 1 )
 * 
 * Returns value:
 *   debug level
 *  
*/
void cam_setDebug(struct camprop *cam, int value) {
   libgphoto_setDebugLog(cam->params->gphotoSession, value);
   cam->params->debug = value;
}
