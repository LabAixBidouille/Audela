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
 *   structure pour les fonctions ?tendues
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
      res=eqmod_put(tel,argv[2]);
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
   res=eqmod_read(tel,ligne);
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
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=eqmod_putread(tel,argv[2],ligne);
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
 *   Decode l'hexa
 */
int cmdTelDecode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res,num;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s hexa",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=eqmod_decode(tel,argv[2],&num);
		sprintf(ligne,"%d",num);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Encode l'hexa
 */
int cmdTelEncode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res,num;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s integer",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		num=atoi(argv[2]);
      res=eqmod_encode(tel,num,ligne);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
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
      if (value<-3.) { value=-3.; }
      if (value>3.)  { value=3.; }
      tel->speed_slew_ra=value;
      value=atof(argv[3]);
      if (value<-3.) { value=-3.; }
      if (value>3.)  { value=3.; }
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
   lst=eqmod_tsl(tel,&h,&m,&sec);
   sprintf(ligne,"%.5f",lst);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- --- */
   Tcl_DStringResult(tel->interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return result;
}

/*
 *   Pointage en coordonnees horaires
 */
int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   int h,m;
   double sec;
   double lst;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         // --- init --- //
         if (argc>=4) {
            // - call the pointing model if exists - //
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
            if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
            }
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
            // - end of pointing model - //
            libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
	    eqmod_hadec_match(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ha angle_dec}",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         // --- coord --- //
         eqmod_hadec_coord(tel,texte);
         // - call the pointing model if exists - //
         sprintf(ligne,"set libtel(radec) {%s}",texte);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
         Tcl_Eval(interp,ligne);
         Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
         strcpy(ligne,interp->result);
         // - end of pointing model- //
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"state")==0) {
         // --- state --- //
         tel_radec_state(tel,texte);
         Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         // --- goto --- //
         if (argc>=4) {
            // - call the pointing model if exists - //
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
            if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
            }
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
            // - end of pointing model - //
            libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
            if (argc>=5) {
               for (k=4;k<=argc-1;k++) {
                  if (strcmp(argv[k],"-rate")==0) {
                     tel->radec_goto_rate=atof(argv[k+1]);
                  }
                  if (strcmp(argv[k],"-blocking")==0) {
                     tel->radec_goto_blocking=atoi(argv[k+1]);
                  }
               }
            }
            // Conversion de l'AH (dans tel->ra0) en vrai RA
				// le goto fera l'operation inverse: ca permet d'utiliser la meme fonction
            lst=eqmod_tsl(tel,&h,&m,&sec);
            lst=lst+0./86400*360.; // ajout empirique de 4 secondes pour tenir compte du temps mort de reponse de la monture
            tel->ra0=lst-tel->ra0+360*5;
            tel->ra0=fmod(tel->ra0,360.);
            if (tel->ra0>180) tel->ra0 -= 360.;
            tel->ha_pointing = 1;
            eqmod2_action_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ha angle_dec} ?-rate value? ?-blocking boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         // --- move --- //
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            tel_radec_move(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         // --- stop --- //
         if (argc>=4) {
            tel_radec_stop(tel,argv[3]);
         } else {
            tel_radec_stop(tel,"");
         }
      } else if (strcmp(argv[2],"motor")==0) {
         // --- motor --- //
         if (argc>=4) {
            tel->radec_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->radec_motor=1;
            }
            tel_radec_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         // --- sub command not found --- //
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 *   Limites pour retournements (deg)
 Exemple :
#init avec tube ? l'ouest et pole nord => hadec = {18h 90d}
tel1 limits 23h20m 00h40 ; # default
tel1 hadec goto {02h30m 40d} -blocking 1 ; # tube ? l'est (? l'endroit)
#Si le tube est ? l'est et que le HA ? pointer (22h30) est < ? la limite East alors on retourne le tube ? l'ouest
tel1 hadec goto {22h30m 40d} -blocking 1 ; # tube ? l'ouest (? l'endroit)
#Si le tube est ? l'ouest et que le HA ? pointer (02h30m) est > ? la limite West alors on retourne le tube ? l'est
tel1 hadec goto {02h30m 40d} -blocking 1 ; # tube ? l'est (? l'endroit)
#
tel1 limits 18h 00h40 ; Eastern limit=18h Western limit=0h40m
tel1 hadec goto {02h30m 40d} -blocking 1 ; # tube ? l'est (? l'endroit)
tel1 hadec goto {22h30m 40d} -blocking 1 ; # tube ? l'est (? l'envers)
 */
int cmdTelLimits(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048],s[2048],le[30],lw[30];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?limit_ha_east limit_ha_west?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      sprintf(s,"mc_angle2deg %s",argv[2]); mytel_tcleval(tel,s);
      value=atof(tel->interp->result);
      if (value<90) {
         sprintf(ligne,"Error, Eastern limit asked = %f degrees (must be in the range 180-360)",value);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }
      value-=360;
      value*=fabs(tel->radec_position_conversion);
      tel->stop_e_uc=(int)value;
      sprintf(s,"mc_angle2deg %s",argv[3]); mytel_tcleval(tel,s);
      value=atof(tel->interp->result);
      if (value>270) {
         sprintf(ligne,"Error, Western limit asked = %f degrees (must be in the range 0-270)",value);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }
      value*=fabs(tel->radec_position_conversion);
      tel->stop_w_uc=(int)value;
   }
   sprintf(s,"mc_angle2hms %.8f 360 zero 2 auto string",tel->stop_e_uc/fabs(tel->radec_position_conversion)); mytel_tcleval(tel,s);
   strcpy(le,tel->interp->result);
   sprintf(s,"mc_angle2hms %.8f 360 zero 2 auto string",tel->stop_w_uc/fabs(tel->radec_position_conversion)); mytel_tcleval(tel,s);
   strcpy(lw,tel->interp->result);
   sprintf(ligne,"%s %s",le,lw);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}


/*
 *  Orientation initiale du tube
 */
int cmdTelOrientation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100];
	struct telprop *tel;
	char comment[]="Usage: %s %s";
	
	if (argc!=2) {
		sprintf(s,comment,argv[0],argv[1]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	tel = (struct telprop*)clientData;
	if (tel->tubepos == 0) {
		Tcl_SetResult(interp,"west",TCL_STATIC);
	} else {
		Tcl_SetResult(interp,"east",TCL_STATIC);
	}
	return TCL_OK;
}

/*
 *  Temporisation pour les acces au port serie
 */
int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100];
	struct telprop *tel;
	char comment[]="Usage: %s %s ?ms?";
	
	if (argc>3) {
		sprintf(s,comment,argv[0],argv[1]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	tel = (struct telprop*)clientData;
	if (argc == 3) {
		tel->tempo=atoi(argv[2]);
	}
	sprintf(s,"%d",tel->tempo);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

/*
 *  Temporisation pour les appels aux goto bloquants
 */
int cmdTelTempoGoto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100];
	struct telprop *tel;
	char comment[]="Usage: %s %s ?dead_ms read_ms?";
	
	if (argc>4) {
		sprintf(s,comment,argv[0],argv[1]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	tel = (struct telprop*)clientData;
	if ((argc>=3)&&(argc<=4)) {
		tel->gotodead_ms=atoi(argv[2]);
		tel->gotoread_ms=atoi(argv[3]);
	}
	sprintf(s,"%d %d",tel->gotodead_ms,tel->gotoread_ms);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

/*
 *   delai en secondes estime pour un slew sans bouger
 */
int cmdTelDeadDelaySlew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {   
      tel->dead_delay_slew=atof(argv[2]);
   }
   sprintf(s,"%f",tel->dead_delay_slew);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   retourne l'etat logique de tracking
 */
int cmdTelState(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   sprintf(s,"state=%s, old_state=%s\n",state2string(tel->state),state2string(tel->old_state));
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   retourne les parametres de la monture
 */
int cmdTelReadparams(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ss[2048];
   char sss[248];
   char s[12048];
	int res,num;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
	strcpy(s,"");
	sprintf(ss,"{a1 %d {ADU/360deg} {microsteps/360deg}} {a2 %d {ADU/360deg} {microsteps/360deg}} ",tel->param_a1,tel->param_a2); strcat(s,ss);
	sprintf(ss,"{b1 %d {ADU/sec} {velocity parameter}} {b2 %d {ADU/sec} {velocity_parameter}} ",tel->param_b1,tel->param_b2); strcat(s,ss);
	sprintf(ss,"{e1 %d {ADU} {unknown parameter (67585)}} {e2 %d {ADU} {unknown parameter (67585)}} ",tel->param_e1,tel->param_e2); strcat(s,ss);
   sprintf(sss,":f1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
   tel->param_f1=num;
   sprintf(sss,":f2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
   tel->param_f2=num;
	sprintf(ss,"{f1 %d {binary} {motorRA state 0|1= 0|1= 0|1=}} {f2 %d {binary} {motorDEC state 0|1= 0|1= 0|1=}} ",tel->param_f1,tel->param_f2); strcat(s,ss);		
	sprintf(ss,"{g1 %d {binary} {0|1=hemis(S|N) 0|1=track(+|-)}} {g2 %d {binary} {0|1=hemis(S|N) 0|1=track(+|-)}} ",tel->param_g1,tel->param_g2); strcat(s,ss);
	sprintf(ss,"{s1 %d {ADU/turn} {microsteps to a complete turnover of worm}} {s2 %d {ADU/turn} {microsteps to a complete turnover of worm}} ",tel->param_s1,tel->param_s2); strcat(s,ss);
	sprintf(ss,"{speed_track_ra %f {deg/s} {motorRA track speed}} {speed_track_dec %f {deg/s} {motorDEC track speed}} ",tel->speed_track_ra,tel->speed_track_dec); strcat(s,ss);
	sprintf(ss,"{speed_slew_ra %f {deg/s} {motorRA slew speed}} {speed_slew_dec %f {deg/s} {motorDEC slew speed}} ",tel->speed_slew_ra,tel->speed_slew_dec); strcat(s,ss);
	sprintf(ss,"{radec_position_conversion %f {ADU/deg} {motorRA and motorDEC position conversion}} ",tel->radec_position_conversion); strcat(s,ss);
	sprintf(ss,"{track_diurnal %f {deg/s} {motorRA theoretical diurnal track}} ",tel->track_diurnal); strcat(s,ss);
	sprintf(ss,"{stop_w_uc %d {ADU} {motorRA western stop}} {stop_e_uc %d {ADU} {motorRA eastern stop}} ",tel->stop_w_uc,tel->stop_e_uc); strcat(s,ss);
	sprintf(ss,"{radec_move_rate_max %f {deg/s} {motorRA and motorDEC maximum authorized move speed}} ",tel->radec_move_rate_max); strcat(s,ss);
	sprintf(ss,"{slew_axis %d {integer} {motorRA and motorDEC motion states. 0: none, 1: RA, 2: DEC, 3: RA+DEC}} ",tel->slew_axis); strcat(s,ss);
	sprintf(ss,"{tubepos %d {binary} {0|1=tube_position(W|E)}} ",tel->tubepos); strcat(s,ss);
	sprintf(ss,"{gotodead_ms %d {ms} {waiting delay for a complete slew}} ",tel->gotodead_ms); strcat(s,ss);
	sprintf(ss,"{gotoread_ms %d {ms} {waiting delay for a answer}} ",tel->gotoread_ms); strcat(s,ss);
	sprintf(ss,"{dead_delay_slew %f {s} {delay for a GOTO at the same place}} ",tel->dead_delay_slew); strcat(s,ss);
	sprintf(ss,"{tempo %d {ms} {delay before to read a command}} ",tel->tempo); strcat(s,ss);
	sprintf(ss,"{ha_park %f {deg} {motorRA Parking hour angle}} {dec_park %f {deg} {motorDEC Parking declination}} ",tel->ha_park,tel->dec_park); strcat(s,ss);
	sprintf(ss,"{gotoblocking %d {binary} {default GOTO blocking 0|1=non_blocking|blocking}} ",tel->gotoblocking); strcat(s,ss);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   Goto parking
 */
int cmdTelGotoparking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
	sprintf(s,"tel%d hadec goto {%f %f} -blocking 0",tel->telno,tel->ha_park,tel->dec_park);
   Tcl_Eval(interp,s);
   strcpy(s,interp->result);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   GotoBlocking
 */
int cmdTelGotoblocking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {
      tel->gotoblocking=atoi(argv[2]);
   }
   sprintf(s,"%d",tel->gotoblocking);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}
