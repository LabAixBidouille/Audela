/***
 * @file : camera_linux.c
 * @brief : routines d'usage général
 * @author : Jacques MICHELET <jacques.michelet@aquitania.org>
 *
 * Mise à jour $Id: divers.cpp,v 1.3 2010-05-26 12:00:17 jacquesmichelet Exp $
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
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

#include <iostream>
#include "sysexp.h"
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "camera.h"
#include <qsiapi.h>


#ifdef __cplusplus
extern "C" {
#endif


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"QSI 632",          /* camera name 70 car maxi*/
     "qsi",              /* camera product */
     "",                 /* ccd name */
     2184, 1472,         /* maxx maxy */
     14, 14,             /* overscans x */
     4, 4,               /* overscans y */
     9e-6, 9e-6,         /* photosite dim (m) */
     65535.,             /* observed saturation */
     1.,                 /* filling factor */
     2.0,                /* gain (e/adu) */
     10.0,               /* readnoise (e) */
     1, 1,               /* default bin x,y */
     1.,                 /* default exptime */
     1,                  /* default state of shutter (1=synchro) */
     0,                  /* default port index (0=lpt1) */
     1,                  /* default cooler index (1=on) */
     -15.,               /* default value for temperature checked */
     1,                  /* default color mask if exists (1=cfa) */
     0,                  /* default overscan taken in acquisition (0=no) */
     2.8                 /* default focal lenght of front optic system */
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
    QSICamera *qsicam;
    int abort;
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
#if defined(OS_LIN)
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
      getlogdate( buf, 100 );
      f = fopen( "qsi.log","at+" );
      switch (level) {
      case LOG_ERROR:
         fprintf( f, "%s - %s(%s) <ERROR> : ", buf, CAM_LIBNAME, CAM_LIBVER );
         break;
      case LOG_WARNING:
         fprintf( f,"%s - %s(%s) <WARNING> : ", buf, CAM_LIBNAME, CAM_LIBVER );
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
    // aucune trace n'est gÃ©nÃ©rÃ©e par dÃ©faut dans le fichier qsi.log
    debug_level = LOG_DEBUG;

    //  RÃ©cuperation des paramÃ¨tres optionnels
    if ( argc >= 5 )
    {
        for ( int kk = 3; kk < argc - 1; kk++ )
        {
            if ( strcmp(argv[kk], "-loglevel" ) == 0 )
                debug_level = atoi( argv[kk + 1] );
        }
    }

    cam_log( LOG_DEBUG, "*********************************************" );
    cam_log( LOG_DEBUG, "cam_init début. Version du %s", __TIMESTAMP__ );
    if ( ( cam->params != 0 ) && ( cam->params->qsicam != 0 ) ) {
        cam_log( LOG_ERROR, "Caméra déjà  initialisée" );
        return 0;
        cam_log( LOG_DEBUG,"cam_init fin OK" );
    }

    cam->params = (PrivateParams*) malloc(sizeof(PrivateParams));
    cam->params->qsicam = new QSICamera();

    // Pour simplifier les Ã©critures
    QSICamera * qsi = cam->params->qsicam;
    if ( qsi == 0 ) {
        sprintf( cam->msg, "Cannot create a camera handler" );
        cam_log( LOG_ERROR, "Cannot create a camera handler" );
        return -1;
    }

    // Utilisation systÃ©matique des mÃ©thodes try/catch
    qsi->put_UseStructuredExceptions( true );

    try
    {
        std::string info("");
        qsi->get_DriverInfo( info );
        cam_log( LOG_INFO, "qsiapi driver : version %s", info.c_str() );

        // Recherche des camÃ©ras QSI branchÃ©es
        int iNumFound;
        std::string camSerial[QSICamera::MAXCAMERAS];
        std::string camDesc[QSICamera::MAXCAMERAS];

        qsi->get_AvailableCameras( camSerial, camDesc, iNumFound );
        for ( int i = 0; i < iNumFound; i++ )
            cam_log( LOG_DEBUG, "Caméras disponibles %s : %s", camSerial[i].c_str(), camDesc[i].c_str() );

        cam_log( LOG_DEBUG, "cam_init avant connexion" );
        // On ne considÃ¨re que la premiÃ¨re. Bogue potentiel.
        qsi->put_SelectCamera( camSerial[0] );

        qsi->put_IsMainCamera( true );

        // Connect to the selected camera and retrieve camera parameters
        qsi->put_Connected( true );
        cam_log( LOG_DEBUG, "cam_init après connexion" );

        // Get Model Number
        std::string modele("");
        qsi->get_ModelNumber( modele );
        strncpy( CAM_INI[cam->index_cam].product, modele.c_str(), sizeof( CAM_INI[cam->index_cam].product ) -1 );
        cam_log( LOG_INFO, "Modèle : %s", modele.c_str() );

        // Get Camera Description
        std::string desc("");
        qsi->get_Description( desc );
        strncpy( CAM_INI[cam->index_cam].name, desc.c_str(), sizeof( CAM_INI[cam->index_cam].name ) -1 );
        cam_log( LOG_INFO, "Descriptif : %s", desc.c_str() );

        // Configuration de la caméra
        // Bipeur
        qsi->put_SoundEnabled( true );
        // Voyant
        qsi->put_LEDEnabled( true );
        // Ventilateurs
        qsi->put_FanMode( QSICamera::fanQuiet );
        // Nettoyage CCD
        qsi->put_PreExposureFlush( QSICamera::FlushNormal );
        // Gain
        bool can_set_gain;
        qsi->get_CanSetGain( &can_set_gain );
        if ( can_set_gain )
            qsi->put_CameraGain( QSICamera::CameraGainLow );
        // Vitesse de lecture
        if ( modele.substr(0,1) == "6")
        {
            cam_log( LOG_INFO, "Modèle de la série 600" );
            qsi->put_ReadoutSpeed( QSICamera::HighImageQuality );
        }

        // Dimensions du capteur en binning 1x1
        qsi->get_CameraXSize( (long *)&cam->nb_photox );
        qsi->get_CameraYSize( (long *)&cam->nb_photoy );
        cam_log( LOG_INFO, "Dimensions du capteur en b1x1 %d x %d", cam->nb_photox, cam->nb_photoy );

        // Dimensions des pixels en micromÃ¨tres
        qsi->get_PixelSizeX( &cam->celldimx );
        qsi->get_PixelSizeY( &cam->celldimy );
        cam_log( LOG_INFO, "Dimensions des pixels en um %f x %f", cam->celldimx, cam->celldimy );
        cam->celldimx *= 1e-6;
        cam->celldimy *= 1e-6;

        // Autres paramÃ¨tres
        qsi->get_ElectronsPerADU( &CAM_INI[cam->index_cam].gain );
        cam_log( LOG_INFO, "Gain (e/adu) = %.3f", CAM_INI[cam->index_cam].gain );
        qsi->get_FullWellCapacity( &cam->fillfactor );
        cam_log( LOG_INFO, "Profondeur des pixels (e) = %.1f", cam->fillfactor );
        if ( modele.substr(0,1) == "6")
        {
            QSICamera::ReadoutSpeed vitesse_lecture;
            qsi->get_ReadoutSpeed( vitesse_lecture );
            cam_log( LOG_INFO, "Vitesse de lecture (lente = 0, rapide = 1) : %d", vitesse_lecture );
        }

        cam->params->abort = 0;
    }
    catch (std::runtime_error &err)
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        sprintf( cam->msg, "%s\n", text.c_str() );
//        std::string last("");
//        cam->params->qsicam->get_LastError( last );
//        sprintf( cam->msg, "%s\n", last.c_str() );
//        cam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
    cam->x1 = 0;
    cam->y1 = 0;
    cam->x2 = cam->nb_photox - 1;
    cam->y2 = cam->nb_photoy - 1;
    cam->binx = 1;
    cam->biny = 1;

    cam_update_window(cam);  // met a jour x1,y1,x2,y2,h,w dans cam
    strcpy( cam->date_obs, "2000-01-01T12:00:00" );
    strcpy( cam->date_end, cam->date_obs );
    cam->authorized = 1;
    cam_log( LOG_DEBUG,"cam_init fin OK" );
    return 0;
}

int cam_close(struct camprop * cam)
{
    cam_log(LOG_DEBUG,"cam_close debut");
    try
    {
        // DÃ©connection de la camÃ©ra
        cam->params->qsicam->put_Connected( false ) ;
        // Suppression de la camera
        delete cam->params->qsicam;
        cam->params->qsicam = 0;
        cam_log( LOG_DEBUG, "cam_close fin OK" );
        return 0;
    }
    catch (std::runtime_error &err)
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

void cam_update_window( struct camprop *cam )
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
   cam->w = (cam->x2 - cam->x1 +1) / cam->binx;
   cam->h = (cam->y2 - cam->y1 +1) / cam->biny;
   x1 = cam->x1  / cam->binx;
   x2 = x1 + cam->w -1;
   y1 = cam->y1 / cam->biny;
   y2 = y1 + cam->h -1;

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

   // je configure la camera.
   // ATTENTION : The frame to be captured is defined by four properties, StartX, StartY, which define the upperleft
   // corner of the frame, and NumX and NumY the define the binned size of the frame.
   // If binning is active, value is in binned pixels, start position for the X and Y axis are 0 based.
   //
   // Restrictions on binning are:
   // The properties BinX and BinY specify the number of bits per bin for each axis.
   // If CanAsymmetricBin is False, BinX must equal BinY.
   // MaxXBin and MaxYBin specify the maximum number of bits per bin allowed by the camera for each axis.
   // Therefore, BinX <=MaxXBin and BinY <= MaxYBin.
   // The total number of bits in a image frame must not exceed the CCD dimension. Therefore,
   //    (StartX + NumX) * BinX <= CameraXSize and (StartY + NumY) * BinY <= CameraYSize
   // Attention , il faut d'abord mettre a jour l'origine (StartX,StartY) avant la taille de la nouvelle fenetre
   // car sinon on risque de provoquer une exception si l'ancienne origine hors de la nouvelle fenetre.

   cam->params->qsicam->put_StartX( x1 );
   cam->params->qsicam->put_StartY( y1 );
   cam->params->qsicam->put_NumX( cam->w );
   cam->params->qsicam->put_NumY( cam->h );
}


void cam_start_exp( struct camprop *cam, char *amplionoff )
{
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_start_exp camera not initialized" );
         sprintf( cam->msg, "cam_start_exp camera not initialized" );
         return;
    }

    if ( cam->authorized == 1 )
    {
        try
        {
            // Pour simplifier les Ã©critures
            QSICamera * qsi = cam->params->qsicam;

            float exptime ;
            if ( cam->exptime <= 0.06f )
                exptime = 0.06f;
            else
                exptime = cam->exptime ;

            // je lance l'acquisition
            if ( cam->shutterindex == 0 )
            {
                // acquisition avec obturateur ferme
                cam_log( LOG_DEBUG,"cam_start_exp apres StartExposure shutter=closed exptime=%f", cam->exptime );
                qsi->StartExposure( exptime, false );
            }
            else
            {
                // acquisition avec obturateur ouvert
                cam_log( LOG_DEBUG, "cam_start_exp apres StartExposure shutter=synchro exptime=%f", cam->exptime );
                qsi->StartExposure( exptime, true );
                cam_log( LOG_DEBUG, "cam_start_exp apres StartExposure" );
            }
            cam->params->abort = 0;
        }
        catch ( std::runtime_error &err )
        {
            std::string text = err.what();
            cam_log( LOG_ERROR, text.c_str() );
            std::string last("");
            cam->params->qsicam->get_LastError( last );
            sprintf( cam->msg, "%s\n", last.c_str() );
            cam_log( LOG_ERROR, last.c_str() );
        }
    }

}

void cam_stop_exp( struct camprop *cam )
{
    cam_log(LOG_DEBUG,"cam_stop_exp debut");
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_start_exp camera not initialized" );
         sprintf( cam->msg, "cam_start_exp camera not initialized" );
         return;
    }

    // Si la camÃ©ra ne supporte pas l 'arrÃªt brutal d'acquisition, il y aura une exception gÃ©nÃ©rÃ©e
    // Pas besoin donc de tester via camAbortExposure()
    try
    {
        cam->params->qsicam->AbortExposure();
        cam->params->abort = 1;
    }
    catch (std::runtime_error &err)
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
}

void cam_read_ccd( struct camprop *cam, unsigned short *p )
{
    cam_log( LOG_DEBUG, "cam_read_ccd debut" );
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_read_ccd camera not initialized" );
         sprintf( cam->msg, "cam_read_ccd camera not initialized" );
         return;
    }
    if ( p == NULL )
        return;

    if ( cam->params->abort == 1 )
    {
        cam->params->abort = 0;
        sprintf(cam->msg, "acq stopped by usr");
        return;
    }

    if ( cam->authorized == 1 )
    {
        try
        {
            // attente que l'image soit prete
            bool image_prete = false;
            cam->params->qsicam->get_ImageReady( &image_prete );
            while( !image_prete )
            {
                usleep( 5000 );
                cam->params->qsicam->get_ImageReady( &image_prete );
            }

            cam->params->qsicam->get_ImageArray( p );
            cam_log(LOG_DEBUG, "cam_read_ccd OK");
        }
        catch ( std::runtime_error &err )
        {
            std::string text = err.what();
            cam_log( LOG_ERROR, text.c_str() );
            std::string last("");
            cam->params->qsicam->get_LastError( last );
            sprintf( cam->msg, "%s\n", last.c_str() );
            cam_log( LOG_ERROR, last.c_str() );
        }
    }
    cam_log( LOG_DEBUG, "cam_read_ccd fin" );
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

void cam_measure_temperature( struct camprop *cam )
{
    cam_log( LOG_DEBUG, "cam_measure_temperature dÃ©but" );
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_measure_temperature camera not initialized" );
         sprintf( cam->msg, "cam_measure_temperature camera not initialized" );
         return;
    }
    cam->temperature = 0.0;
    try
    {
        cam->params->qsicam->get_CCDTemperature( &cam->temperature );
        cam_log( LOG_DEBUG,"temperature = %.1f", cam->temperature );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
    cam_log( LOG_DEBUG,"cam_measure_temperature fin OK." );
}

void cam_cooler_on( struct camprop *cam )
{
    cam_log( LOG_DEBUG,"cam_cooler_on debut" );
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_cooler_on camera not initialized" );
         sprintf( cam->msg, "cam_cooler_on camera not initialized" );
         return;
    }
    try
    {
        cam->params->qsicam->put_CoolerOn( true );
        cam_log( LOG_DEBUG, "cam_cooler_on fin OK" );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
}

void cam_cooler_off( struct camprop *cam )
{
    cam_log( LOG_DEBUG,"cam_cooler_off debut" );
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_cooler_off camera not initialized" );
         sprintf( cam->msg, "cam_cooler_off camera not initialized" );
         return;
    }
    try
    {
        cam->params->qsicam->put_CoolerOn( false );
        cam_log( LOG_DEBUG, "cam_cooler_off fin OK" );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
}

void cam_cooler_check( struct camprop *cam )
{
    cam_log( LOG_DEBUG, "cam_cooler_check debut" );
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_cooler_check camera not initialized" );
         sprintf( cam->msg, "cam_cooler_check camera not initialized" );
         return;
    }
    try
    {
        cam_log( LOG_DEBUG, "TempÃ©rature de consigne = %.1f", cam->check_temperature );
        cam->params->qsicam->put_SetCCDTemperature( cam->check_temperature );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
    cam_log( LOG_DEBUG, "cam_cooler_check fin OK" );
}

void qsiGetTemperatureInfo( struct camprop *cam, double *setTemperature, double *ccdTemperature, double *ambientTemperature, int *regulationEnabled, int *power )
{
    cam_log( LOG_DEBUG, "cam_get_info_temperature debut" );
    if ( cam->params->qsicam == 0 )
    {
         cam_log( LOG_ERROR, "cam_get_info_temperature camera not initialized" );
         sprintf( cam->msg, "cam_get_info_temperature camera not initialized" );
         return;
    }

    try
    {
        // Temp. de consigne du capteur
        cam->params->qsicam->get_SetCCDTemperature( setTemperature );
        // Temp. rÃ©elle du capteur
        cam->params->qsicam->get_CCDTemperature( ccdTemperature );
        // Temp. du dissipateur
        cam->params->qsicam->get_HeatSinkTemperature( ambientTemperature );

        *regulationEnabled = 0;
        bool cooler_on = false;
        cam->params->qsicam->get_CoolerOn( &cooler_on );
        cam_log( LOG_DEBUG, "Refroidissement = %d", cooler_on );
        if ( cooler_on )
            *regulationEnabled = 1;

        // La puissance de refroidissement est exprimÃ©e directement en pourcentage
        double puissance;
        cam->params->qsicam->get_CoolerPower( &puissance );
        *power = (int)puissance;
        cam_log( LOG_INFO, "cam_get_info_temperature fin Temp. CCD=%.1f  Temp. consigne=%.1f Temp. dissipateur=%.1f puissance=%d regulation=%d",
            *ccdTemperature,
            *setTemperature,
            *ambientTemperature,
            *power,
            *regulationEnabled );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
    cam_log( LOG_DEBUG,"cam_get_info_temperature fin OK" );
}

void cam_set_binning( int binx, int biny, struct camprop *cam )
{
    int previousBinX;
    int previousBinY;
    cam_log( LOG_DEBUG, "cam_set_binning debut. binx=%d biny=%d", binx, biny );
    if ( cam->params->qsicam == 0 ) {
        cam_log( LOG_ERROR,"cam_set_binning camera not initialized" );
        sprintf( cam->msg, "cam_set_binning camera not initialized" );
        return;
    }
    try {
        previousBinX = cam->binx;
        previousBinY = cam->biny;

        short max_binx;
        cam->params->qsicam->get_MaxBinX( &max_binx );
        if ( binx >  max_binx )
        {
            cam_log( LOG_ERROR, "Error: binning X is greater than %d", max_binx );
            sprintf( cam->msg, "Error: binning X is greater than %d", max_binx );
            return;
        }

        short max_biny;
        cam->params->qsicam->get_MaxBinY( &max_biny );
        if ( biny > max_biny )
        {
            cam_log( LOG_ERROR, "Error: binning Y is greater than %d", max_biny );
            sprintf( cam->msg, "Error: binning Y is greater than %d", max_biny );
            return;
        }
        cam->binx = binx;
        cam->biny = biny;
        cam->w = ( cam->x2 - cam->x1 + 1 ) / cam->binx;
        cam->h = ( cam->y2 - cam->y1 + 1 ) / cam->biny;
        cam->params->qsicam->put_NumX( cam->w );
        cam->params->qsicam->put_NumY( cam->h );
        cam->params->qsicam->put_BinX( binx );
        cam->params->qsicam->put_BinY( biny );
        cam_log( LOG_DEBUG, "cam_set_binning apres binx=%d biny=%d", binx, biny );
        cam_log( LOG_DEBUG, "cam_set_binning fin OK" );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
    }
}



// ---------------------------------------------------------------------------
// qsiSetupDialog
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------

void qsiSetupDialog(struct camprop *cam) {}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition
//    change la position de la roue a filtre
// @ param  pointeur des donnees de la camera
// @ param  position  Position is a  number between 0 and N-1, where N is the number of filter slots (see Filter.Names).
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiSetWheelPosition( struct camprop *cam, int position )
{
    cam_log( LOG_DEBUG, "qsiSetWheelPosition debut. Position=%d", position );
   if ( cam->params->qsicam == 0 )
   {
        cam_log( LOG_ERROR,"qsiSetWheelPosition camera not initialized" );
        sprintf( cam->msg, "qsiSetWheelPosition camera not initialized" );
        return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            // Position : Starts filter wheel rotation immediately when written.
            // Reading the property gives current slot number (if wheel stationary)
            // or -1 if wheel is moving.
            cam->params->qsicam->put_Position( (short)position );
            return 0;
        }
        else
        {
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition
//    change la position de la roue a filtre
// return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelPosition( struct camprop *cam, int *position )
{
    cam_log( LOG_DEBUG, "qsiGetWheelPosition debut." );
    if ( cam->params->qsicam == 0 )
    {
        cam_log( LOG_ERROR,"qsiGetWheelPosition camera not initialized" );
        sprintf( cam->msg, "qsiGetWheelPosition camera not initialized" );
        return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            // Position : Starts filter wheel rotation immediately when written.
            // Reading the property gives current slot number (if wheel stationary)
            // or -1 if wheel is moving.
            cam->params->qsicam->get_Position( (short*)position );
            return 0;
        }
        else
        {
            *position = -1;
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

// ---------------------------------------------------------------------------
// qsiGetWheelNames
//    retourne les noms des positions de la roue filtre
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelNames( struct camprop *cam, char **names )
{
    cam_log( LOG_DEBUG, "qsiGetWheelNames debut" );
    if ( cam->params->qsicam == 0 ) {
        cam_log( LOG_ERROR, "qsiGetWheelNames camera not initialized" );
        sprintf( cam->msg, "qsiGetWheelNames camera not initialized" );
       return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            int filtres;
            cam->params->qsicam->get_FilterCount( filtres );
            cam_log( LOG_DEBUG, "Nombre de position de la roue Ã  filtre : %d", filtres );
            std::string * noms = new std::string[filtres];
            long * dec_map = new long[filtres];
            /* Allocation. La lbÃ©ration sera fait dans la routine appelante */
            *names = (char*) calloc( filtres, 256 );
            cam_log( LOG_DEBUG, "qsiGetWheelNames avant GetNames filter Wheel : noms = %p, dec_map = %p", noms, dec_map );
            cam->params->qsicam->get_Names( noms );
            cam->params->qsicam->get_FocusOffset( dec_map );
            for ( int i = 0; i < filtres ; i++ )
            {
                strcat( *names, "{ " );
                if ( noms[i].length() > 0 )
                {
                    strncat( *names, noms[i].c_str(), 253 );
                    cam_log( LOG_DEBUG, "nom_filtre[%d] = %s", i, noms[i].c_str() );
                }
                else
                    cam_log( LOG_DEBUG, "nom_filtre[%d] = <vide>" );
                strcat( *names, " } ");
            }
            cam_log( LOG_DEBUG, "Nom des filtres=%s", *names );
            cam_log( LOG_DEBUG, "qsiGetWheelNames fin" );
            return 0;
        }
        else
        {
            cam_log( LOG_DEBUG,"Pas de roue Ã  filtre" );
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
//        std::string last("");
//        cam->params->qsicam->get_LastError( last );
//        sprintf( cam->msg, "%s\n", last.c_str() );
//        cam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

// ---------------------------------------------------------------------------
// qsiGetWheelNames
//    retourne les noms des positions de la roue filtre
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetProperty( struct camprop *cam, char *propertyName, char *propertyValue )
{
    if ( cam->params->qsicam == 0 ) {
        cam_log( LOG_ERROR, "qsiGetProperty camera not initialized");
        sprintf(cam->msg, "qsiGetProperty camera not initialized");
        return -1;
    }
    try
    {
        if ( strcmp( propertyName, "MaxBinX" ) == 0 ) {
            short max_binx;
            cam->params->qsicam->get_MaxBinX( &max_binx );
            sprintf( propertyValue,"%d", max_binx );
        }
        else if ( strcmp( propertyName, "MaxBinY" ) == 0 ) {
            short max_biny;
            cam->params->qsicam->get_MaxBinY( &max_biny );
            sprintf( propertyValue,"%d", max_biny );
        }
        return 0;
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        cam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        cam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}




