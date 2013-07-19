/* libtel.h
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

#ifndef __LIBTEL_H__
#define __LIBTEL_H__

/*****************************************************************/
/*             This part is common for all tel drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#include "libname.h"
#include "libstruc.h"

#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

struct cmditem {
   char *cmd;
   Tcl_CmdProc *func;
};

#define COMMON_CMDLIST \
   {"alignmentmode", (Tcl_CmdProc *)cmdTelAlignmentMode},\
   {"refraction", (Tcl_CmdProc *)cmdTelRefraction},\
   {"drivername", (Tcl_CmdProc *)cmdTelDrivername},\
   {"name", (Tcl_CmdProc *)cmdTelName},\
   {"protocol", (Tcl_CmdProc *)cmdTelProtocol},\
   {"product", (Tcl_CmdProc *)cmdTelProduct},\
   {"port", (Tcl_CmdProc *)cmdTelPort},\
   {"channel", (Tcl_CmdProc *)cmdTelChannel},\
   {"foclen", (Tcl_CmdProc *)cmdTelFoclen},\
   {"testcom", (Tcl_CmdProc *)cmdTelTestCom},\
   {"radec", (Tcl_CmdProc *)cmdTelRaDec},\
   {"coord", (Tcl_CmdProc *)cmdTelCoord},\
   {"goto", (Tcl_CmdProc *)cmdTelGoto},\
   {"stop", (Tcl_CmdProc *)cmdTelStop},\
   {"match", (Tcl_CmdProc *)cmdTelMatch},\
   {"speed", (Tcl_CmdProc *)cmdTelSpeed},\
   {"move", (Tcl_CmdProc *)cmdTelMove},\
   {"close", (Tcl_CmdProc *)cmdTelClose},\
   {"focus", (Tcl_CmdProc *)cmdTelFocus},\
   {"date", (Tcl_CmdProc *)cmdTelDate},\
   {"home", (Tcl_CmdProc *)cmdTelHome},\
   {"model", (Tcl_CmdProc *)cmdTelModel},\
   {"threadid", (Tcl_CmdProc *)cmdTelThreadId},\
   {"consolelog", (Tcl_CmdProc *)cmdTelConsoleLog},\
 
   /*
   {"obs", cmdTelObs},\
   {"version", cmdTelVersion},\
   {"filter", cmdTelFilter},\
   */

/* --- Information commands ---*/
int cmdTelAlignmentMode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelDrivername(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelPort(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelChannel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelTestCom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelClose(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelRefraction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelThreadId(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

/* --- Obsolete compatible old version commands ---*/
int cmdTelCoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelGoto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelMatch(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelMove(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/* --- Action commands ---*/
int cmdTelName(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelProtocol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelProduct(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelFoclen(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelRaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelFocus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelDate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelHome(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelModel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelConsoleLog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/* --- Utilitaire C-Tcl ---*/
void libtel_GetCurrentUTCDate(Tcl_Interp *interp, char *s);
void libtel_GetCurrentFITSDate(Tcl_Interp *interp, char *s);
void libtel_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function);
int libtel_Getradec(Tcl_Interp *interp,char *tcllist,double *ra,double *dec);

int tel_init_common(struct telprop *tel, int argc, const char **argv);
static void surveyCoord (ClientData clienData);

// ---- fonctions par defaut de struct tel_drv_t TEL_DRV 
int default_tel_correct(struct telprop *tel, char *alphaDirection, double alphaDistance, char *deltaDirection, double deltaDistance);
int default_tel_set_radec_guiding(struct telprop *tel, int guiding) ;
int default_tel_get_radec_guiding(struct telprop *tel, int *guiding) ;

#ifdef __cplusplus
}
#endif

#endif

