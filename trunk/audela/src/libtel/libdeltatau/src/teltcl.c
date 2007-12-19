/* teltcl.c
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
#include "telescop.h"
#include <libtel/libtel.h>
#include "teltcl.h"
#include <libtel/util.h>

/*
 *   structure pour les fonctions étendues
 */


/*
 *   Envoie une commande
 */
int cmdTelPut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=deltatau_put(tel,argv[2]);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Lit une reponse
 */
int cmdTelRead(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   res=deltatau_read(tel,ligne);
   if (res==1) {
      result = TCL_ERROR;
   } else {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/*
 *   Envoie une commande et retourne la reponse
 */
int cmdTelPutread(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048],s[1024];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=deltatau_put(tel,argv[2]);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,ligne);
      if (res==1) {
         Tcl_SetResult(interp,"connection problem",TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Envoie une Init
 */
int cmdTelInit(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   int axe_min=1,axe_max=4;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s AxeNo",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=atoi(argv[2]);
      if ((res<axe_min)||(res>axe_max)) { 
         sprintf(ligne,"AxeNo must be between %d and %d",axe_min,axe_max);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
      sprintf(ligne,"P%d00=9",res);
      res=deltatau_put(tel,ligne);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Retourne les positions des axes
 */
int cmdTelPosition(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   int axe_min=1,axe_max=4;
   char s[1024],ss[1024],axe;
   double ha,lst,sec,ra,dec;
   int h,m;
   Tcl_DString dsptr;
   double roth_uc,rotd_uc;

   tel = (struct telprop *)clientData;
   if (argc<2) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   Tcl_DStringInit(&dsptr);
   /* --- Vide le buffer --- */
   res=deltatau_read(tel,s);
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{position_1 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_1 %f degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_1 %d ADU} ",tel->roth00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_1 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{hour_angle_match %f degrees} ",tel->ha00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      roth_uc=atof(s);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      ha=fmod(ha+720,360.);
      sprintf(ligne,"{hour_angle %.5f degrees} ",ha);
      Tcl_DStringAppend(&dsptr,ligne,-1);
      lst=deltatau_tsl(tel,&h,&m,&sec);
      sprintf(ligne,"{local_sideral_time %.5f degrees} ",lst);
      Tcl_DStringAppend(&dsptr,ligne,-1);
      ra=lst-ha+360*5;
      ra=fmod(ra,360.);
      sprintf(ligne,"{ra %.5f degrees} ",ra);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   sprintf(ss,"#%cv",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{speed_1 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{speed_deg_1 %e ADU/s} ",atof(s)/tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- Lecture AXE 2 (delta) --- */
   axe='2';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{position_2 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_2 %f degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_2 %d ADU} ",tel->rotd00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_2 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{dec_match %f degrees} ",tel->dec00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      rotd_uc=atof(s);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      sprintf(ligne,"{dec %.5f degrees} ",dec);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   sprintf(ss,"#%cv",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{speed_2 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{speed_deg_2 %e ADU/s} ",atof(s)/tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- Lecture AXE 3 (focus) --- */
   axe='3';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{position_3 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{position_deg_3 %s degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_3 %d ADU} ",tel->rotd00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_3 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{dec_match_3 %f degrees} ",tel->dec00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      rotd_uc=atof(s);
      dec=tel->dec00+1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      sprintf(ligne,"{dec %.5f degrees} ",dec);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   */
   sprintf(ss,"#%cv",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{speed_3 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{speed_deg_3 %e ADU/s} ",atof(s)tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   */
   /* --- Lecture AXE 4 (filter wheel) --- */
   axe='4';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{position_4 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{position_deg_4 %s degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_4 %d ADU} ",tel->rotd00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_4 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{dec_match_4 %f degrees} ",tel->dec00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      rotd_uc=atof(s);
      dec=tel->dec00+1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      sprintf(ligne,"{dec %.5f degrees} ",dec);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   */
   sprintf(ss,"#%cv",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   sprintf(ligne,"{speed_4 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{speed_deg_4 %e ADU/s} ",atof(s)tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   */
   /* --- --- */
   Tcl_DStringResult(tel->interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return result;
}

/*
 *   Valeurs des vitesses de pointage (deg/s)
 */
int cmdTelSpeedslew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?speed_slew_ra speed_slew_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      value=atof(argv[2]);
      if (value<-100.) { value=-100.; }
      if (value>100.)  { value=100.; }
      tel->speed_slew_ra=value;
      value=atof(argv[3]);
      if (value<-100.) { value=-100.; }
      if (value>100.)  { value=100.; }
      tel->speed_slew_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_slew_ra,tel->speed_slew_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Valeurs des vitesses de suivi (deg/s)
 */
int cmdTelSpeedtrack(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?speed_track_ra|diurnal speed_track_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      if (strcmp(argv[2],"diurnal")==0) {
         value=tel->track_diurnal;
      } else {
         value=atof(argv[2]);
      }
      if (value<-5.) { value=-5.; }
      if (value>5.)  { value=5.; }
      tel->speed_track_ra=value;
      value=atof(argv[3]);
      if (value<-5.) { value=-5.; }
      if (value>5.)  { value=5.; }
      tel->speed_track_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_track_ra,tel->speed_track_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Retourne le temps sideral actuel
 */
int cmdTelLst(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   struct telprop *tel;
   double lst,sec;
   int h,m;
   Tcl_DString dsptr;

   tel = (struct telprop *)clientData;
   if (argc<2) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   Tcl_DStringInit(&dsptr);
   /* --- Lecture AXE 1 (horaire) --- */
   lst=deltatau_tsl(tel,&h,&m,&sec);
   sprintf(ligne,"%.5f",lst);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- --- */
   Tcl_DStringResult(tel->interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return result;
}
