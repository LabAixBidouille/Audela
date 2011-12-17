/* camtcl.c
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

// $Id: camtcl.c,v 1.11 2010-02-06 11:25:17 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <string.h>
#include <stdlib.h> // for atoi()

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"

// definition STRNCPY : copie de chaine avec protection contre les debordements
#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0

extern struct camini CAM_INI[];



/*
 * -----------------------------------------------------------------------------
 *  cmdCamAutoLoadFlag()
 *
 * Change or returns autoLoadFlag value
 *   if autoLoadFlag = 0  , cam_read_ccd doesn't download image after acquisition with CF
 *   if autoLoadFlag = 1  , cam_read_ccd loads image after acquisition with CF
 * -----------------------------------------------------------------------------
 */
int cmdCamAutoLoadFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getAutoLoadFlag(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam_setAutoLoadFlag(cam, atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamAutoDeleteFlag()
 *
 * Change or returns autoDeleteFlag value
 *   if autoDeleteFlag = 0  , cam_read_ccd doesn't delete image after acquisition with CF
 *   if autoDeleteFlag = 1  , cam_read_ccd deletes image after acquisition with CF
 * -----------------------------------------------------------------------------
 */
int cmdCamAutoDeleteFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getAutoDeleteFlag(cam)  );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam_setAutoDeleteFlag(cam, atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

static int cmdCamDebug(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1? [debugPath]", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam_getDebug(cam));
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      int debug;
      cam = (struct camprop *) clientData;
      if (Tcl_GetInt(interp, argv[2], &debug) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\nvalue must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if ( argc >= 4 ) {
            cam_setDebug(cam,debug, argv[3]);
            Tcl_SetResult(interp, "", TCL_VOLATILE);
            result = TCL_OK;
         } else {
            cam_setDebug(cam,debug, "");
            Tcl_SetResult(interp, "", TCL_VOLATILE);
            result = TCL_OK;
         }
      }
   }
   return result;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamDriveMode()
 *
 * Change or returns drive mode
 *    driveMode = 0   : single shoot
 *    driveMode = 1   : continuous
 *    driveMode = 2   : self timer 
 * -----------------------------------------------------------------------------
 */
int cmdCamDriveMode(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1|2?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getDriveMode(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' || argv[2][0] == '2') {
         cam_setDriveMode(cam,atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1|2?\n Invalid value. Must be in  0,1 or 2", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamQuality()
 *
 * 
 *  cam1 quality
 *    returns current quality
 *
 *  cam1 quality value 
 *    change current quality 
 * 
 *  cam1 quality list
 *    return quality list
 *    example : {"CRW" "Large:Fine" "Large:Normal" "Middle:Fine" "Middle:Normal" }
 * -----------------------------------------------------------------------------
 */
int cmdCamQuality(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?quality?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      char quality[DIGICAM_QUALITY_LENGTH];
      cam_getQuality(cam , quality);
      Tcl_SetResult(interp, quality, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if ( strcmp(argv[2],"list") ==0 ) {
         char list[1024];
         cam_getQualityList( list );
         sprintf(ligne, "%s", list);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } else if( cam_checkQuality(argv[2]) == 0 ) {
         cam_setQuality(cam , argv[2]);
         strcpy(ligne, argv[2]);
         result = TCL_OK;
      } else {      
         char list[1024];
         cam_getQualityList( list );
         sprintf(ligne, "Usage: %s %s ?quality?\n Invalid value. Must be list or in {%s}", argv[0], argv[1], list);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamLoadLastImage()
 *
 * load last image from camera
 *   
 *   
 * -----------------------------------------------------------------------------
 */
int cmdCamLoadLastImage(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]) {
   int result;
   struct camprop *cam;
   char s[1000];
   double ra, dec, exptime = 0.;
   int status;

   cam = (struct camprop *) clientData;
   cam->interp = interp;

   // reset message
   strcpy(cam->msg,"");
   
   // read last image , the result is returned in cam struture :
   //    cam->pixel_data       data pointer
   //    cam->pixel_size       date size
   //    cam->pixels_classe    
   //    cam->pixels_format
   //    cam->pixels_compression
   status = cam_loadLastImage(cam);
   
   if( status == 0) {
      libcam_GetCurrentFITSDate(interp, cam->date_end);
            
      // Ce test permet de savoir si le buffer existe
      sprintf(s, "buf%d bitpix", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         sprintf(s, "buf::create %d", cam->bufno);
         Tcl_Eval(interp, s);
      }
      
      // --- application du miroir horizontal
      if( cam->mirrorh == 1 ) {
         // j'inverse l'orientation de l'image par rapport à un miroir horizontal
         if( cam->pixels_reverse_y == 1 ) {
            cam->pixels_reverse_y = 0; 
         } else {
            cam->pixels_reverse_y = 1; 
         }
      }
      
      // --- application du miroir vertical
      if( cam->mirrorv == 1 ) {
         // j'inverse l'orientation de l'image par rapport à un miroir vertical
         if( cam->pixels_reverse_x == 1 ) {
            cam->pixels_reverse_x = 0; 
         } else {
            cam->pixels_reverse_x = 1; 
         }
      }
      
      //--- set pixels to buffer 
      sprintf(s, "buf%d setpixels %s %d %d %s %s %d -pixels_size %lu -reverse_x %d -reverse_y %d", 
         cam->bufno, cam->pixels_classe, cam->w, cam->h, cam->pixels_format, cam->pixels_compression ,
         (int) cam->pixel_data, cam->pixel_size, cam->pixels_reverse_x, cam->pixels_reverse_y);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         strcpy(s, interp->result);
      }

      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         strcpy(s, interp->result);
      }
      
      // get height after decompression
      sprintf(s, "buf%d getpixelsheight", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_OK) {
         Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &cam->h);
      }   
      
      // get width after decompression
      sprintf(s, "buf%d getpixelswidth", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_OK) {
         Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &cam->w);
      }   
      
      /* Add FITS keywords */
      if ( strcmp(cam->pixels_classe, "CLASS_GRAY")==0 ) {
         sprintf(s, "buf%d setkwd {NAXIS 2 int \"\" \"\"}", cam->bufno);
         Tcl_Eval(interp, s);
      } else if ( strcmp(cam->pixels_classe, "CLASS_RGB")==0 ) {
         sprintf(s, "buf%d setkwd {NAXIS 3 int \"\" \"\"}", cam->bufno);
         Tcl_Eval(interp, s);
         sprintf(s, "buf%d setkwd {NAXIS3 3 int \"\" \"\"}", cam->bufno);
         Tcl_Eval(interp, s);
      }
      sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, cam->w);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, cam->h);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, cam->binx);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, cam->biny);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {CAMERA \"%s %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->date_obs);
      Tcl_Eval(interp, s);
      if (cam->timerExpiration != NULL) {
         sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, cam->exptime);
      } else {
         sprintf(s, "expr (([mc_date2jd %s]-[mc_date2jd %s])*86400.)", cam->date_end, cam->date_obs);
         Tcl_Eval(interp, s);
         exptime = atof(interp->result);
         sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, exptime);
      }
      Tcl_Eval(interp, s);
      
      libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
      if (status == 0) {
         /* Add FITS keywords */
         sprintf(s, "buf%d setkwd {RA %f float \"Right ascension telescope encoder\" \"\"}", cam->bufno, ra);
         Tcl_Eval(interp, s);
         sprintf(s, "buf%d setkwd {DEC %f float \"Declination telescope encoder\" \"\"}", cam->bufno, dec);
         Tcl_Eval(interp, s);
      }
      free(cam->pixel_data);
      

      Tcl_SetResult(interp, "", TCL_VOLATILE);
      result = TCL_OK;
   } else {
      Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamSystemService()
 *
 *  start or stop  hotplug service
 *        Windows : WIA ( Windows Image Acquisition)
 *        Linux   : ???
 *   
 * -----------------------------------------------------------------------------
 */
int cmdCamSystemService(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]) {
    char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getSystemServiceState(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam_setSystemServiceState(cam, atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/**
 * cmdCamUseCf
 * Change or returns the "use CF" state(use memory card CF of DSLR).
 *
 * param : 
 *    0=ne pas utiliser la carte memoire de l'APN, 1=utiliser la carte memoire de l'APN
 */
int cmdCamUseCf(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getUseCf(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         result = cam_setUseCf(cam, atoi(argv[2]));
         if( result == 0) {
            result = TCL_OK;
         } else {
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
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
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      int value;
      if(Tcl_GetInt(interp,argv[2],&value)==TCL_OK) {
         pb = cam_setLonguePose(cam, value);
      } else {
         pb= 1;
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s 0|1|2", argv[0], argv[1]);
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
   cam->interp = interp;


   if (argc < 2  && argc > 3) {
      sprintf(ligne, "Usage: %s %s ?linkno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if ( argc == 2 ) {
         sprintf(ligne, "%d", cam->longueposelinkno);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } else {
      // je memorise le numero du link
      if(Tcl_GetInt(interp,argv[2],&cam->longueposelinkno)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s linkno\n linkno = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
         } else {
            result = TCL_OK;
         }
      } 
   }
   return result;
}


/**
 * cmdCamLonguePoseLinkbit
 * Change the bit number 
*/
int cmdCamLonguePoseLinkbit(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;


   if (argc < 2  && argc > 3) {
      sprintf(ligne, "Usage: %s %s ?numbit", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if ( argc == 2 ) {
         strcpy(ligne, cam->longueposelinkbit);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } else {
         // je memorise le numero du bit
         STRNCPY(cam->longueposelinkbit, argv[2] );
         Tcl_SetResult(interp, cam->longueposelinkbit, TCL_VOLATILE);
         result = TCL_OK;
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
   cam->interp = interp;

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
   cam->interp = interp;

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
