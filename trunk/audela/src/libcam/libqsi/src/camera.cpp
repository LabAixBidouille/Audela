/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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
#include <wchar.h>   // pour BSTR
#include <exception>
#include <stdexcept>
#endif

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "camera.h"

#define _WIN32_DCOM  // CoInitializeEx help : You must include the #define _WIN32_DCOM preprocessor directive at the beginning of your code to be able to use CoInitializeEx.
#import "progid:QSICamera.CCDCamera"

#ifdef __cplusplus
extern "C" {
#endif


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"noname",			/* camera name 70 car maxi*/
     "qsi",       /* camera product */
     "",			   /* ccd name */
     768, 512,			/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			   /* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			    /* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			   /* default exptime */
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

static int cam_init(struct camprop *cam, int argc, char **argv);
static int cam_close(struct camprop * cam);
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

struct _PrivateParams {
   QSICameraLib::ICameraEx * pCam;                // parametres internes de la camera
   //QSICameraLib::IFilterWheelEx * pFilterWheel;
   int debug;
};

#ifdef __cplusplus
}
#endif

#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */
#define LOG_NONE    0
#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4
int debug_level = LOG_NONE;
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
void cam_log(int level, const char *fmt, ...)
{
   FILE *f;
   char buf[100];

   va_list mkr;
   va_start(mkr, fmt);

   if (level <= debug_level) {
      getlogdate(buf,100);
      f = fopen("qsi.log","at+");
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

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, char **argv)
{

   HRESULT hr;
   cam->params = (PrivateParams*) malloc(sizeof(PrivateParams));
   cam->params->pCam    = NULL;
   
   // aucune trace n'est générée par défaut dans le fichier qsi.log
   debug_level = LOG_NONE;

   // je recupere les parametres optionnels
   if (argc >= 5) {
      for (int kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-loglevel") == 0) {            
            debug_level = atoi(argv[kk + 1]);
         }
      }
   }

   cam_log(LOG_DEBUG,"cam_init début. Version du %s", __TIMESTAMP__);
   //Initialize COM.
   //hr = CoInitialize(NULL);
   hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);
   if (FAILED(hr)) { 
      sprintf(cam->msg, "cam_init error CoInitializeEx hr=%X",hr);
      return -1;
   }

   hr = ::CoCreateInstance( __uuidof (QSICameraLib::CCDCamera), NULL, CLSCTX_INPROC_SERVER,
      __uuidof( QSICameraLib::ICameraEx) , (void **) &cam->params->pCam);
   if (FAILED(hr)) { 
      if  ( hr == REGDB_E_CLASSNOTREG ) {
         sprintf(cam->msg, "cam_init error REGDB_E_CLASSNOTREG : QSI Class not registered");
         cam_log(LOG_ERROR,cam->msg);
         return -1;
      } else {
         sprintf(cam->msg, "cam_init error CoCreateInstance hr=%X",hr);
         cam_log(LOG_ERROR,cam->msg);
         return -1;
      }
   }

   try
   {
      cam_log(LOG_DEBUG,"cam_init avant connexion");
      cam->params->pCam->Connected = true;
      cam_log(LOG_DEBUG,"cam_init avant GetCameraXSize");
      cam->nb_photox  = cam->params->pCam->CameraXSize;
      cam->nb_photoy  = cam->params->pCam->CameraYSize;
      //cam_log(LOG_DEBUG,"cam_init avant GetDescription");
      //strcpy(CAM_INI[cam->index_cam].name, cam->params->pCam->Name);
      // je recupere la description
      strncpy(CAM_INI[cam->index_cam].name, 
         _com_util::ConvertBSTRToString(cam->params->pCam->Description),
         sizeof(CAM_INI[cam->index_cam].name) -1 );

   } catch (_com_error &e) {
      cam_log(LOG_ERROR,"cam_init connection _com_error=%s",e.ErrorMessage());
      sprintf(cam->msg, "cam_init connection _com_error=%s",e.ErrorMessage());
      return -1;
   } catch (std::exception &e) {
      cam_log(LOG_ERROR,"cam_init connection error=%s",e.what());
      sprintf(cam->msg, "cam_init connection error=%s",e.what());
      return -1;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_init error Connected exception");
      sprintf(cam->msg, "cam_init error Connected exception");
      return -1;
   }
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;
   cam->binx = 1;
   cam->biny = 1;


   cam_update_window(cam);	// met a jour x1,y1,x2,y2,h,w dans cam
   strcpy(cam->date_obs, "2000-01-01T12:00:00");
   strcpy(cam->date_end, cam->date_obs);
   cam->authorized = 1;
   cam_log(LOG_DEBUG,"cam_init fin OK");
   return 0;
}

int cam_close(struct camprop * cam)
{
   try {
      cam_log(LOG_DEBUG,"cam_close debut");
      // je deconnecte la camera
      cam->params->pCam->Connected = false;
      // je supprime la camera
      cam->params->pCam->Release();
      cam->params->pCam = NULL;
      CoUninitialize();   // devrait eviter de demarrer dans le thread principal dans libcam.c .. a voir
      if ( cam->params != NULL ) {
         free(cam->params);
         cam->params = NULL;
      }
      cam_log(LOG_DEBUG,"cam_close fin OK");
      return 0;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_close error exception");
      sprintf(cam->msg, "cam_close error exception");
      return -1;
   }
   return 0;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   int x1, x2, y1, y2; 
   
   if (cam->x1 > cam->x2) {
      int x0 = cam->x2;
      cam->x2 = cam->x1;
      cam->x1 = x0;
   }

   if (cam->x1 < 0) {
      cam->x1 = 0;
   }
   if (cam->x2 > maxx - 1) {
      cam->x2 = maxx - 1;
   }

   if (cam->y1 > cam->y2) {
      int y0 = cam->y2;
      cam->y2 = cam->y1;
      cam->y1 = y0;
   }
   if (cam->y1 < 0) {
      cam->y1 = 0;
   }

   if (cam->y2 > maxy - 1) {
      cam->y2 = maxy - 1;
   }

   // je prend en compte le binning
   cam->w = (cam->x2 - cam->x1) / cam->binx +1;
   cam->h = (cam->y2 - cam->y1) / cam->biny +1;
   x1 = cam->x1  / cam->binx;
   x2 = x1 + cam->w -1;
   y1 = cam->y1 / cam->biny;
   y2 = y1 + cam->h -1;

   // je configure la camera.
   // The frame to be captured is defined by four properties, StartX, StartY, which define the upperleft
   // corner of the frame, and NumX and NumY the define the binned size of the frame.
   // If binning is active, value is in binned pixels, start position for the X and Y axis are 0 based.
   //
   // Attention , il faut d'abord mettre a jour l'origine (StartX,StartY) avant la taille de la fenetre
   // car sinon on risque de provoquer une exception (cas de l'ancienne origine hors de la fenetre)



   if ( cam->mirrorv == 1 ) {
      // j'applique un miroir vertical en inversant les ordonnees de la fenetre
      x1 = (maxx / cam->binx ) - x2 -1;
   }

   if ( cam->mirrorh == 1 ) {
      // j'applique un miroir horizontal en inversant les abcisses de la fenetre
      // 0---y1-----y2---------------------(w-1)
      // 0---------------(w-y2)---(w-y1)---(w-1)  
      y1 = (maxy / cam->biny ) - y2 -1;
   }

   cam->params->pCam->StartX = x1 ;
   cam->params->pCam->StartY = y1 ;
   cam->params->pCam->NumX = cam->w;
   cam->params->pCam->NumY = cam->h;
}


void cam_start_exp(struct camprop *cam, char *amplionoff)
{
   HRESULT hr;

   if ( cam->params->pCam == NULL ) {
         cam_log(LOG_ERROR,"cam_start_exp camera not initialized");
         sprintf(cam->msg, "cam_start_exp camera not initialized");
         return;
   }

   if (cam->authorized == 1) {
      try {
         float exptime ;
         if ( cam->exptime <= 0.03f ) {
            exptime = 0.03f;
         } else {
            exptime = cam->exptime ;
         }

         // je lance l'acquisition
         if (cam->shutterindex == 0) {
            // acquisition avec obturateur ferme
            cam_log(LOG_DEBUG,"cam_start_exp apres StartExposure shutter=closed exptime=%f",cam->exptime);
            hr = cam->params->pCam->StartExposure(cam->exptime, VARIANT_FALSE);
         } else {
            // acquisition avec obturateur ouvert
            cam_log(LOG_DEBUG,"cam_start_exp apres StartExposure shutter=synchro exptime=%f",cam->exptime);
            hr = cam->params->pCam->StartExposure(cam->exptime, VARIANT_TRUE);
            cam_log(LOG_DEBUG,"cam_start_exp apres StartExposure");
         }
         if (FAILED(hr)) {  
            cam_log(LOG_DEBUG,"cam_start_exp error StartExposure hr=%X",hr);
            sprintf(cam->msg, "cam_start_exp error StartExposure hr=%X",hr);
            return;
         }
         return;
      } catch (_com_error &e) {
         cam_log(LOG_ERROR,"cam_start_exp  error=%s",e.ErrorMessage());
         sprintf(cam->msg, "cam_start_exp  error=%s",e.ErrorMessage());
         return;
      } catch (...) {
         sprintf(cam->msg, "cam_start_exp error StartExposure exception");
         return;
      }
   }
}

void cam_stop_exp(struct camprop *cam)
{
   HRESULT hr;

   cam_log(LOG_DEBUG,"cam_stop_exp debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_stop_exp camera not initialized");
      sprintf(cam->msg, "cam_stop_exp camera not initialized");
      return;
   }

   try {
      // j'interromps l'acquisition

      hr = cam->params->pCam->StopExposure();
      if (FAILED(hr)) { 
         sprintf(cam->msg, "cam_stop_exp error StopExposure hr=%X",hr);
         return;
      }
      cam_log(LOG_DEBUG,"cam_stop_exp fin OK");
      return;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_stop_exp error StopExposure exception");
      sprintf(cam->msg, "cam_stop_exp error StopExposure exception");
      return;
   }
}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
   cam_log(LOG_DEBUG,"cam_read_ccd debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_read_ccd camera not initialized");
      sprintf(cam->msg, "cam_read_ccd camera not initialized");
      return;
   }
   if (p == NULL)
      return;

   if (cam->authorized == 1) {
      try {
         SAFEARRAY *safeValues;

         long * lValues;
         // j'attends que l'image soit prete
         while (cam->params->pCam->ImageReady == VARIANT_FALSE){
            Sleep(100);
         }
         
         cam_log(LOG_DEBUG,"cam_read_ccd apres attente");
         // je reccupere le pointeur de l'image
         _variant_t variantValues = cam->params->pCam->ImageArray;
         safeValues = variantValues.parray;
         cam_log(LOG_DEBUG,"cam_read_ccd avant SafeArrayAccessData");
         SafeArrayAccessData(safeValues, (void**)&lValues);      
         
         // je copie l'image dans le buffer
         cam_log(LOG_DEBUG,"cam_read_ccd avant copie");
         for( int y=0; y <cam->h; y++) {
            for( int x=0; x <cam->w; x++) {
                p[x+y*cam->w] = (unsigned short) lValues[x+y*cam->w];
            }
         }
         SafeArrayUnaccessData(safeValues);
         cam_log(LOG_DEBUG,"cam_read_ccd OK");      
      } catch (...) {
         cam_log(LOG_ERROR,"cam_read_ccd exception");
         sprintf(cam->msg, "cam_read_ccd exception");
         return;
      }
   }
   cam_log(LOG_DEBUG,"cam_read_ccd fin OK");

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
   cam_log(LOG_DEBUG,"cam_measure_temperature début");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_measure_temperature camera not initialized");
      sprintf(cam->msg, "cam_measure_temperature camera not initialized");
      return;
   }
   cam->temperature = 0.;
   try {
      cam->temperature = cam->params->pCam->CCDTemperature;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_measure_temperature error exception");
      sprintf(cam->msg, "cam_measure_temperature error exception");
   }
   cam_log(LOG_DEBUG,"cam_measure_temperature fin OK.");
}

void cam_cooler_on(struct camprop *cam)
{
   cam_log(LOG_DEBUG,"cam_cooler_on debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_cooler_on camera not initialized");
      sprintf(cam->msg, "cam_cooler_on camera not initialized");
      return;
   }
   try {
      cam->params->pCam->CoolerOn = VARIANT_TRUE;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_cooler_on error exception");
      sprintf(cam->msg, "cam_cooler_on error exception");
   }
   cam_log(LOG_DEBUG,"cam_cooler_on fin OK");
}

void cam_cooler_off(struct camprop *cam)
{
   cam_log(LOG_DEBUG,"cam_cooler_off debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_cooler_off camera not initialized");
      sprintf(cam->msg, "cam_cooler_off camera not initialized");
      return;
   }
   try {
      cam->params->pCam->CoolerOn = VARIANT_FALSE;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_cooler_off error exception");
      sprintf(cam->msg, "cam_cooler_off error exception");
   }
   cam_log(LOG_DEBUG,"cam_cooler_off fin OK");
}

void cam_cooler_check(struct camprop *cam)
{
   cam_log(LOG_DEBUG,"cam_cooler_check debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_cooler_check camera not initialized");
      sprintf(cam->msg, "cam_cooler_check camera not initialized");
      return;
   }
   try {
      cam->params->pCam->SetCCDTemperature = cam->check_temperature;
   } catch (...) {
      cam_log(LOG_ERROR,"cam_cooler_check error exception");
      sprintf(cam->msg, "cam_cooler_check error exception");
   }
   cam_log(LOG_DEBUG,"cam_cooler_check fin OK");
}

void qsiGetTemperatureInfo(struct camprop *cam, double *setTemperature, double *ccdTemperature, 
                               double *ambientTemperature, int *regulationEnabled, int *power) 
{
   cam_log(LOG_DEBUG,"cam_get_info_temperature debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"qsiGetTemperatureInfo camera not initialized");
      sprintf(cam->msg, "qsiGetTemperatureInfo camera not initialized");
      return;
   }

   try {
      *setTemperature = (float) cam->params->pCam->SetCCDTemperature;
      *ccdTemperature = (float) cam->params->pCam->CCDTemperature;
      *ambientTemperature = 0. ;
      if ( cam->params->pCam->CoolerOn == VARIANT_TRUE) {
         *regulationEnabled = 1;
      } else {
         *regulationEnabled = 0;
      }
      *power = (int)(cam->params->pCam->CoolerPower);
      cam_log(LOG_DEBUG,"cam_get_info_temperature fin ccdTemperature=%f  setTemperature=%f power=%d", *ccdTemperature, *setTemperature, *power);
   } catch (...) {
      cam_log(LOG_ERROR,"cam_get_info_temperature error exception");
      sprintf(cam->msg, "cam_get_info_temperature error exception");
   }

   cam_log(LOG_DEBUG,"cam_get_info_temperature fin OK");
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   cam_log(LOG_DEBUG,"cam_set_binning debut. binx=%d biny=%d",binx, biny);
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"cam_set_binning camera not initialized");
      sprintf(cam->msg, "cam_set_binning camera not initialized");
      return;
   }
   try {
      cam->params->pCam->BinX = binx;
      cam->params->pCam->BinY = biny;
      cam_log(LOG_DEBUG,"cam_set_binning apres binx=%d biny=%d",binx, biny);
      cam->binx = binx;
      cam->biny = biny;
      cam_log(LOG_DEBUG,"cam_set_binning fin OK");
   } catch (_com_error &e) {
      cam_log(LOG_ERROR,"cam_init connection error=%s",e.ErrorMessage());
      sprintf(cam->msg, "cam_init connection error=%s",e.ErrorMessage());
   } catch (std::runtime_error &e) {
      cam_log(LOG_ERROR,"cam_init connection error=%s",e.what());
      sprintf(cam->msg, "cam_init connection error=%s",e.what());
   } catch (std::logic_error &e) {
      cam_log(LOG_ERROR,"cam_init connection error=%s",e.what());
      sprintf(cam->msg, "cam_init connection error=%s",e.what());      
   } catch (std::exception &e) {
      cam_log(LOG_ERROR,"cam_init connection error=%s",e.what());
      sprintf(cam->msg, "cam_init connection error=%s",e.what());      
   }
}



// ---------------------------------------------------------------------------
// qsiSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------

void qsiSetupDialog(struct camprop *cam)
{
   cam_log(LOG_DEBUG,"qsiSetupDialog avant SetupDialog");
   if ( cam->params->pCam == NULL ) {
      sprintf(cam->msg, "qsiSetupDialog camera not initialized");
      cam_log(LOG_ERROR,cam->msg);
      return;
   }
   try {
      cam->params->pCam->Connected = false;
      cam->params->pCam->SetupDialog();
      cam->params->pCam->Connected = true;
   } catch (...) {
      sprintf(cam->msg, "cam_cooler_check error exception");
      cam_log(LOG_ERROR,cam->msg);
   }
}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition 
//    change la position de la roue a filtre
// @ param  pointeur des donnees de la camera
// @ param  position  Position is a  number between 0 and N-1, where N is the number of filter slots (see Filter.Names). 
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiSetWheelPosition(struct camprop *cam, int position)
{
   cam_log(LOG_DEBUG,"qsiSetWheelPosition debut. Position=%d",position);
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"qsiSetWheelPosition camera not initialized");
      sprintf(cam->msg, "qsiSetWheelPosition camera not initialized");
      return -1;
   }
   try {
      if ( cam->params->pCam->HasFilterWheel) {
         // Position : Starts filter wheel rotation immediately when written. 
         // Reading the property gives current slot number (if wheel stationary) 
         // or -1 if wheel is moving.
         cam->params->pCam->Position = position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
      return 0;
   } catch (...) {
      cam_log(LOG_ERROR,"qsiSetWheelPosition error exception");
      sprintf(cam->msg, "qsiSetWheelPosition error exception");
      return -1;
   }
   cam_log(LOG_DEBUG,"qsiSetWheelPosition fin OK");
}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition 
//    change la position de la roue a filtre
// return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelPosition(struct camprop *cam, int *position)
{
   cam_log(LOG_DEBUG,"qsiGetWheelPosition debut");
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"qsiGetWheelPosition camera not initialized");
      sprintf(cam->msg, "qsiGetWheelPosition camera not initialized");
      return -1;
   }
   try {
      VARIANT_BOOL filter = cam->params->pCam->HasFilterWheel;
      if ( filter) {
         *position = cam->params->pCam->Position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
      return 0;
   } catch (...) {
      cam_log(LOG_ERROR,"qsiSetWheelPosition error exception");
      sprintf(cam->msg, "qsiSetWheelPosition error exception");
      return -1;
   }
   cam_log(LOG_DEBUG,"qsiGetWheelPosition fin OK. Position=%d",*position);
}

// ---------------------------------------------------------------------------
// qsiGetWheelNames 
//    retourne les noms des positions de la roue filtre 
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return 
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelNames(struct camprop *cam, char **names)
{
   cam_log(LOG_DEBUG,"qsiGetWheelNames debut");      
   if ( cam->params->pCam == NULL ) {
      cam_log(LOG_ERROR,"qsiGetWheelNames camera not initialized");
      sprintf(cam->msg, "qsiGetWheelNames camera not initialized");
      return -1;
   }
   try {
      VARIANT_BOOL filter = cam->params->pCam->HasFilterWheel;
      if ( filter ) {
         SAFEARRAY *safeValues;
         cam_log(LOG_DEBUG,"qsiGetWheelNames avant GetNames filter Wheel");      
         safeValues = cam->params->pCam->Names;
         *names = (char*) calloc(safeValues->cbElements, 256);
         //_bstr_t  *bstrValue ;
         BSTR *bstrArray ;
         cam_log(LOG_DEBUG,"qsiGetWheelNames avant SafeArrayAccessData");      
         SafeArrayAccessData(safeValues, (void**)&bstrArray); 
         cam_log(LOG_DEBUG,"qsiGetWheelNames nb filters=%ld",safeValues->cbElements);      
         for (unsigned int i=0; i <= safeValues->cbElements ; i++ ) {
            //SafeArrayAccessData(&safeValues[i], (void**)&bstrValue); 
            strcat(*names, "{ ");
            strcat(*names, _com_util::ConvertBSTRToString(bstrArray[i]));
            strcat(*names, " } ");
            //SafeArrayUnaccessData(&safeValues[i]);
         }
         cam_log(LOG_DEBUG,"qsiGetWheelNames avant SafeArrayUnaccessData");      
         SafeArrayUnaccessData(safeValues);
         cam_log(LOG_DEBUG,"qsiGetWheelNames fin. filters=%s",*names);
         return 0;
      } else {
         cam_log(LOG_DEBUG,"qsiGetWheelNames fin. No filters name");
         *names = (char*) NULL;
         return 0;
      }
      cam_log(LOG_DEBUG,"qsiGetWheelNames fin OK"); 
      return 0;
   } catch (...) {
      cam_log(LOG_ERROR,"qsiGetWheelNames error exception");
      sprintf(cam->msg, "qsiGetWheelNames error exception");
      return -1;
   }
}



