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

// $Id: camera.c,v 1.2 2006-06-07 18:22:41 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#include <crtdbg.h>                 // pour debuggage memoire
#include <usb.h>                    // pour libusb
#endif

#include <string.h>
#include <stdlib.h>

#include "camera.h"
#include "gp_api.h"

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
      1536, 1024,			/* maxx maxy */
      23, 14,			/* overscans x */
      0, 0,			/* overscans y */
      9.8e-6, 12.6e-6,		/* photosite dim (m) */
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

#define GPAPI_OK     0
#define GPAPI_ERROR -1

struct _PrivateParams {
   GPParams *gpparams;                // parametres internes libgphoto2
   char gphotoWinDllDir[1024];        // repertoire des DDL gphoto2 pour windows

};

char *canonQuality[] =
{
      { "Large:Fine"    },
      { "Large:Normal"  },
      { "Middle:Fine"   },
      { "Middle:Normal" },
      { "Small:Fine"    },
      { "Small:Normal"  },
      { "CRW"  },
      { "" }
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
   cam->autoLoadFlag = 1;
   strcpy(cam->params->gphotoWinDllDir, "../bin");            // default DLL directory

   // je traite les parametres
   for (i = 3; i < argc - 1; i++) {
      if (strcmp(argv[i], "-gphoto2_win_dll_dir") == 0) {
         strncpy(cam->params->gphotoWinDllDir , argv[i + 1], 1024);
      }
   }


   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
   
#ifdef WIN32
   // je verifie le repertoire des DLL de gphoto2 
   // ce parametre n'est pas utilise sous Linux car gphoto2 est installe 
   // dans les repertoires systeme /usr/...
   if( strlen(cam->params->gphotoWinDllDir) == 0 ) {
      sprintf(cam->msg, "gphoto2_win_dll_dir is empty");
      return -1;
   }   
#endif

   // j'initialise le contexte GPAPI
   result = gpapi_init(&cam->params->gpparams, cam->params->gphotoWinDllDir);
   if ( result != GPAPI_OK ) {
      strcpy(cam->msg, gpapi_getLastErrorMessage(cam->params->gpparams));
      return -1;
   }
   
   // je detecte la camera
   result = gpapi_detect(cam->params->gpparams, cameraModel, cameraPath);
   if ( result != GPAPI_OK ) {
      strcpy(cam->msg, gpapi_getLastErrorMessage(cam->params->gpparams));
      return -1;
   }

   // je connecte la camera
   result = gpapi_open(cam->params->gpparams, cameraModel, cameraPath);
   if ( result != GPAPI_OK ) {
      strcpy(cam->msg, gpapi_getLastErrorMessage(cam->params->gpparams));
      return -1;
   }

   // je configure le mode de declenchement de la pose par defaut
   result = cam_setLonguePose(cam, REMOTE_INTERNAL);
   if ( result != 0 ) {
      return -1;
   }

   // je verifie si on peut selectionner le temps de pose (depend du modele d'APN)
   result = gpapi_getTimeValue(cam->params->gpparams, &cam->exptime, &cam->driverMode, cam->quality); 
   if ( result != 0 ) {
      return -1;
   }

   return 0;
}


static int cam_close(struct camprop *cam) {   
   // je deconnecte la camera
   gpapi_close(cam->params->gpparams);
   
   // je libere les ressources du contgexte GPAPI
   gpapi_exit(cam->params->gpparams);

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
               result = gpapi_setTimeValue(cam->params->gpparams, -1.0 , cam->driverMode, cam->quality);         
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
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   if (cam->x1 > cam->x2)
      //libcam_swap(&(cam->x1), &(cam->x2));
      if (cam->x1 < 0)
         cam->x1 = 0;
      if (cam->x2 > maxx - 1)
         cam->x2 = maxx - 1;
      
      if (cam->y1 > cam->y2)
         //libcam_swap(&(cam->y1), &(cam->y2));
         if (cam->y1 < 0)
            cam->y1 = 0;
         if (cam->y2 > maxy - 1)
            cam->y2 = maxy - 1;
            /*
            cam->w = ( cam->x2 - cam->x1) / cam->binx + 1;
            cam->x2 = cam->x1 + cam->w * cam->binx - 1;
            cam->h = ( cam->y2 - cam->y1) / cam->biny + 1;
            cam->y2 = cam->y1 + cam->h * cam->biny - 1;
         */
         cam->w = (cam->x2 - cam->x1 + 1) / cam->binx;
         cam->x2 = cam->x1 + cam->w * cam->binx - 1;
         cam->h = (cam->y2 - cam->y1 + 1) / cam->biny;
         cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
   int result;

   if (cam->authorized == 1) {
      switch (cam->longuepose) {
      case REMOTE_INTERNAL : 

         if( cam->capabilities.expTimeCommand == 1 ) {
            // je programme le temps de pose 
            result = gpapi_setTimeValue(cam->params->gpparams, cam->exptime, cam->driverMode, cam->quality);         
         }
         
         // je lance l'acquisition 
         result = gpapi_captureImage(cam->params->gpparams, cam->cameraFolder, cam->fileName);         
         if (result != GPAPI_OK) {
            strcpy(cam->cameraFolder, "");
            strcpy(cam->fileName, "");
         }
         // Comme gpapi_captureImage est bloquant, on pourra lancer cam_read_ccd  
         // immediatement apres la fin de cam_start_exp
         cam->exptimeTimer = 0.0;

         break;
      case REMOTE_LINK : 
         if( cam->capabilities.expTimeCommand == 1 ) {
            // je programme le temps de pose 
            result = gpapi_setTimeValue(cam->params->gpparams, -1, cam->driverMode, cam->quality);         
         }
         // je prepare l'appareil photo 
         result = gpapi_setExternalRemoteCapture(cam->params->gpparams,1);
         if (result == GPAPI_OK ) {
            // je lance une acquisition
            cam_setLongExposureDevice(cam, cam->longueposestart );
         }
         
         break;
      case REMOTE_MANUEL :
         if( cam->capabilities.expTimeCommand == 1 ) {
            // je programme le temps de pose 
            result = gpapi_setTimeValue(cam->params->gpparams, -1, cam->driverMode, cam->quality);         
         }
         // je prepare l'appareil photo
         gpapi_setExternalRemoteCapture(cam->params->gpparams,1);
         cam->exptime = 0;
         break;
      default : 
         break;
      }
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

   if (p == NULL)
      return;
   
   if (cam->authorized == 1) {

      
      switch (cam->longuepose) {
      case REMOTE_INTERNAL : 
         if ( strcmp(cam->cameraFolder, "")!=0 && strcmp(cam->fileName,"") != 0 ) {
            result = GPAPI_OK;
         } else {
            result = GPAPI_ERROR;
         }
         break;
      case REMOTE_LINK : 
         // j'arrete l'acquisition
         cam_setLongExposureDevice(cam, cam->longueposestop );
         // je recupere le nom de l'image dans la carte memoire de l'appareil photo
         result = gpapi_captureImage(cam->params->gpparams, cam->cameraFolder, cam->fileName);
         gpapi_setExternalRemoteCapture(cam->params->gpparams,0);
         break;
      case REMOTE_MANUEL :
         // je recupere le nom de l'image dans la carte memoire de l'appareil photo
         result = gpapi_captureImage(cam->params->gpparams, cam->cameraFolder, cam->fileName);
         gpapi_setExternalRemoteCapture(cam->params->gpparams,0);
         break;
      default : 
         result = GPAPI_ERROR;
         break;
      }

      if (result == GPAPI_OK) {
         if( cam->autoLoadFlag == 1 ) {
            result = cam_loadLastImage(cam);
         }
         
      } else {
         // je retourne un message d'erreur
         strcpy(cam->msg, "read_ccd : gpapi_captureImage ERROR");
      }
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
}

int cam_loadLastImage(struct camprop *cam)
{
   int result;
   char mimeType[64];
   char *imageData;
   unsigned long imageSize;
   
   if(strcmp(cam->fileName, "") != 0) { 
      // je charge l'image   
      result = gpapi_loadImage(cam->params->gpparams, cam->cameraFolder, cam->fileName, &imageData, &imageSize, mimeType);
      if (result == GPAPI_OK )  {
         // je copie les valeurs a retourner
         cam->pixel_data  = imageData;
         cam->pixel_size  = imageSize;         
         strcpy(cam->pixels_classe, "CLASS_RGB");
         strcpy(cam->pixels_format, "FORMAT_SHORT");
         if (strcmp(mimeType, "image/x-canon-raw" ) == 0 ) {
            strcpy(cam->pixels_compression, "COMPRESS_RAW");
            cam->pixels_reverse_x = 0;
            cam->pixels_reverse_y = 1;
         } else if ( strcmp(mimeType, "image/jpeg") == 0 ) {
            strcpy(cam->pixels_compression, "COMPRESS_JPEG");
            cam->pixels_reverse_x = 0;
            cam->pixels_reverse_y = 0;
         }
         
         // je supprime l'image sur la carte memoire de l'appareil
         result = gpapi_deleteImage (cam->params->gpparams, cam->cameraFolder, cam->fileName);

         // je purge le nom du fichier
         strcpy(cam->fileName, "");

      } else {
         // je retourne un message d'erreur
         sprintf(cam->msg, "Error gpapi_loadImage : %s", gpapi_getLastErrorMessage(cam->params->gpparams));
      }
   } else {
      strcpy(cam->msg, "No last image");
   }

   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cam_getSystemServiceState()
 *
 *  retourne l'etat du service systeme d'acquisition des images
 *   
 *  return 
 *     1 systeme démarré
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
void cam_setSystemServiceState(struct camprop *cam, int state) {
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

   // j'envoie une commande à la liaison
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
 * cam_checkQuality 
 *    check quality exits
 * 
 * Returns value:
 * - 0 when success.
 * - 0 if quality not found
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
        result = 1;
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

