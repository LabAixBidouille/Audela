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

extern struct camini CAM_INI[];

int cmdAndorSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Get|Set SSpeed of the Andor camera                                                  */
/* Returned parameters are :                                                           */
/*  {index_VSSpeed mus_VSSpeed indexmax_VSSpeed} {index_HSSpeed mus_HSSpeed indexmax_HSSpeed} */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK,pb=0;
   int hi,vi,nhi,nvi;
   float h,v;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if((argc!=2)&&(argc!=4)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      vi=(int)fabs(atof(argv[2]));
      hi=(int)fabs(atof(argv[3]));
      GetNumberVSSpeeds(&nvi);
      GetNumberHSSpeeds(0,0,&nhi);
      if (vi<0) {vi=0;}
      if (vi>=nvi) {vi=nvi-1;}
      if (hi<0) {hi=0;}
      if (hi>=nhi) {hi=nhi-1;}
      SetVSSpeed(vi);
      SetHSSpeed(0,hi);
      cam->VSSpeed=vi;
      cam->HSSpeed=hi;
      pb=0;
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?Index_VSSpeed Index_HSSpeed?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      GetNumberVSSpeeds(&nvi);
      GetNumberHSSpeeds(0,0,&nhi);
      vi=cam->VSSpeed;
      hi=cam->HSSpeed;
      GetVSSpeed(vi,&v);
      GetHSSpeed(0,0,hi,&h);
      sprintf(ligne,"{%d %f %d} {%d %f %d}",vi,v,nvi,hi,h,nhi);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdAndorClosingtime(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Get|Set Closing time of the shuffetof the Andor camera                                                  */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if (argc>=3) {
      cam->closingtime=(int)fabs(atoi(argv[2]));
   }
   sprintf(ligne,"%d",cam->closingtime);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdAndorOpeningtime(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Get|Set Opening time of the shuffetof the Andor camera                                                  */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if (argc>=3) {
      cam->openingtime=(int)fabs(atoi(argv[2]));
   }
   sprintf(ligne,"%d",cam->openingtime);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdAndorDev(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* fonction de developpement */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   int emgain,emgain0,res,ngains,k;
   float gain;
   cam = (struct camprop *)clientData;
   if (argc<=2) {
      sprintf(ligne,"Usage: %s %s EMGain",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   // =================================
   res=SetEMGainMode(2);
   if (res==DRV_NOT_INITIALIZED) {
      sprintf(ligne,"Error EMGain %d: DRV_NOT_INITIALIZED",res);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (res==DRV_ACQUIRING) {
      sprintf(ligne,"Error EMGain %d: DRV_ACQUIRING",res);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (res==DRV_P1INVALID) {
      sprintf(ligne,"Error EMGain %d: DRV_P1INVALID",res);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   // =================================
   emgain0=1;
   if (argc>=3) {
      emgain0=(int)fabs(atoi(argv[2]));
      if ((emgain0<1)||(emgain0>255)) {
         strcpy(ligne,"EMGain must lie between 1 and 255");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         SetEMCCDGain(emgain0);
      }
   }
   GetEMCCDGain(&emgain);
   // =================================
   //IsPreAmpGainAvailable
   GetNumberPreAmpGains(&ngains);
   for (k=0;k<ngains;k++) {
      GetPreAmpGain(k,&gain);
   }
   SetPreAmpGain(2);
   // =================================
   cam->HSSpeed=0;
   cam->VSSpeed=1;
   if (emgain0==1) {
      cam->HSEMult=1;
   } else {
      cam->HSEMult=0;
   }
   // =================================
   sprintf(ligne,"%d",emgain);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

