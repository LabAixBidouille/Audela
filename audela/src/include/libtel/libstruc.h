/* libstruc.h
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

#ifndef __LIBSTRUC_H__
#define __LIBSTRUC_H__

#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

/*****************************************************************/
/*             This part is common for all tel drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#define COMMON_TELSTRUCT \
   char msg[2048];\
   Tcl_Interp *interp;\
   char name[128];\
   int authorized;\
   double foclen;\
   int telno;\
   unsigned short port;\
   int portindex;\
   char portname[80];\
   int index_tel;\
   double ra0;\
   double dec0;\
   double radec_goto_rate;\
   int radec_goto_blocking;\
   double radec_move_rate;\
   int    radec_motor; \
   int    radecGuidingState; \
   double radecGuidingSpeed; \
   double focus0;\
   int    focus_motor;\
   double focus_goto_rate;\
   int    focus_goto_blocking;\
   double focus_move_rate;\
   char channel[30];\
   char homeName[128];\
   char homePosition[128];\
   char model_cat2tel[50];\
   char model_tel2cat[50];\
   char radec_model_coefficients[1024]; \
   int  radec_model_enabled; \
   char radec_model_name[255]; \
   char radec_model_date[255]; \
   int  radec_model_pressure; \
   char radec_model_symbols[255]; \
   int  radec_model_temperature; \
   double speed;\
   double focusspeed;\
   int active_backlash;\
   char mainThreadId[20]; \
   char telThreadId[20]; \
   Tcl_Obj *      timerVar; \
   int            timeDone; \
   int            minRadecDelay;  \
   int            consoleLog; \
   char alignmentMode[10]; \
   int refractionCorrection; \
   int coordSurveyState;\
   struct telprop *next;

/*Tcl_TimerToken timerToken; \ */
   

extern char *tel_ports[];

/* --- structure qui accueille les initialisations des parametres---*/
/* Ne pas modifier. */
struct telini {
   /* --- variables communes privees constantes ---*/
   char name[256];
   char protocol[256];
   char product[256];
   /* --- variables communes publiques parametrables depuis Tcl ---*/
   double foclen;
};

/* --- Structure sur la liste des CCD disponibles pour ce ---*/
/* --- telescope et leurs parametres d'initialisation           ---*/
extern struct telini tel_ini[];

struct tel_drv_t {
    int (*tel_correct) (struct telprop *tel, char *alphaDirection, double alphaDistance, char *deltaDirection, double deltaDistance);
    int (*tel_get_radec_guiding) (struct telprop * cam, int *guiding) ;
    int (*tel_set_radec_guiding) (struct telprop * cam, int guiding) ;
};

extern struct tel_drv_t TEL_DRV;

#ifdef __cplusplus
}
#endif

#endif

