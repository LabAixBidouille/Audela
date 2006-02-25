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

// $Id: camtcl.c,v 1.1 2006-02-25 17:08:22 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <string.h>
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"


extern struct camini CAM_INI[];



/*
 * -----------------------------------------------------------------------------
 *  cmdAutoLoadFlag()
 *
 * Change or returns autoLoadFlag value
 *   if autoLoadFlag = 0  , cam_read_ccd doesn't download image after acquisition
 *   if autoLoadFlag = 1  , cam_read_ccd download image after acquisition
 * -----------------------------------------------------------------------------
 */
int cmdAutoLoadFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam->autoLoadFlag );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam->autoLoadFlag = atoi(argv[2]);
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
 *  cmdAutoLoadFlag()
 *
 * load last image from camera
 *   
 *   
 * -----------------------------------------------------------------------------
 */
int cmdLoadLastImage(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]) {
   int result;
   struct camprop *cam;
   char s[100];
   char *p;		/* cameras de 1 a 16 bits non signes */
   double ra, dec, exptime = 0.;
   int status;

   cam = (struct camprop *) clientData;
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
      libcam_GetCurrentFITSDate_function(interp, cam->date_end, "::audace::date_sys2ut");
      
      p =  cam->pixel_data;
      
      
      // Ce test permet de savoir si le buffer existe
      sprintf(s, "buf%d bitpix", cam->bufno);
      if (Tcl_Eval(interp, s) == TCL_ERROR) {
         sprintf(s, "buf::create %d", cam->bufno);
         Tcl_Eval(interp, s);
      }
      
      // decompress and store pixels into the buffer
      sprintf(s, "buf%d setpixels %s %d %d %s %s %d -pixels_size %lu", 
         cam->bufno, cam->pixels_classe, cam->w, cam->h, cam->pixels_format, cam->pixels_compression ,(int) p, cam->pixel_size);
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
      if (cam->timerExpiration != NULL) {
         sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->timerExpiration->dateobs);
      } else {
         sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->date_obs);
      }
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
      free(p);
      

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
 *  cmdDefaultService()
 *
 *  start or stop  hotplug service
 *        Windows : WIA ( Windows Image Acquisition)
 *        Linux   : ???
 *   
 * -----------------------------------------------------------------------------
 */
int cmdSystemService(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]) {
    char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
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
      } else if (strcmp(argv[2], "2") == 0) {
         cam->longuepose = 2;
         pb = 0;
      } else {
         pb = 1;
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
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if (argc != 3) {
      sprintf(ligne, "Usage: %s %s ?linkno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
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
 * Change the bit number 
*/
int cmdCamLonguePoseLinkbit(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if (argc != 3) {
      sprintf(ligne, "Usage: %s %s ?numbit", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
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
