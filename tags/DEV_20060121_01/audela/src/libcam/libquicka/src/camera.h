/* camera.h
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>


/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    int shuttertypeindex;
    int shutteraudinereverse;
    int ampliindex;
    int nbampliclean;
    double delayshutter;
    short speed;
};


//int quicka_start(struct camprop *cam);
//int quicka_read(struct camprop *cam, unsigned short *p);

/* To open and close the shared library */
//int open_quicka(void);
//int close_quicka(void);

/***************************************************************************/
/* Define the entry point of the driver to use it                          */
/***************************************************************************/

#define USB_LOADLIB      usb_loadlib
#define USB_LOADLIBQ    "usb_loadlib"
#define USB_CLOSELIB     usb_closelib
#define USB_CLOSELIBQ   "usb_closelib"
#define USB_INIT         usb_init
#define USB_INITQ       "usb_init"
#define USB_END          usb_end
#define USB_ENDQ        "usb_end"
#define USB_WRITE        usb_write
#define USB_WRITEQ      "usb_write"
#define USB_START        usb_start
#define USB_STARTQ      "usb_start"
#define USB_READAUDINE   usb_readaudine
#define USB_READAUDINEQ "usb_readaudine"

/*
short usb_loadlib(void);
short usb_closelib(void);
short usb_init(void);
short usb_end(void);
short usb_write(short v);
short usb_start(short KAF,short x1,short y1,short x2,short y2,short bin_x,short bin_y,short shutter,short shutter_mode,short ampli_mode,short acq_mode,short d1,short d2,short *imax, short *jmax);
short usb_readaudine(short imax,short jmax, short *buf);
*/

#if defined(OS_WIN)
/* Windows */
#include <windows.h>
HINSTANCE quicka;
typedef short __stdcall QUICKA_USB_LOADLIB(void);
QUICKA_USB_LOADLIB *USB_LOADLIB;
typedef short __stdcall QUICKA_USB_CLOSELIB(void);
QUICKA_USB_CLOSELIB *USB_CLOSELIB;
typedef short __stdcall QUICKA_USB_INIT(void);
QUICKA_USB_INIT *USB_INIT;
typedef short __stdcall QUICKA_USB_END(void);
QUICKA_USB_END *USB_END;
typedef short __stdcall QUICKA_USB_WRITE(short v);
QUICKA_USB_WRITE *USB_WRITE;
typedef short __stdcall QUICKA_USB_START(short KAF, short x1, short y1,
					 short x2, short y2, short bin_x,
					 short bin_y, short shutter,
					 short shutter_mode,
					 short ampli_mode, short acq_mode,
					 short d1, short d2, short speed,
					 short *imax, short *jmax);
QUICKA_USB_START *USB_START;
typedef short __stdcall QUICKA_USB_READAUDINE(short imax, short jmax,
					      short *buf);
QUICKA_USB_READAUDINE *USB_READAUDINE;
#define QUICKA_NAME "quicka.dll"
#endif

#if defined(OS_UNX) || defined(OS_LIN)
/* Linux */
#include <dlfcn.h>
void *quicka;
typedef short QUICKA_USB_LOADLIB(void);
QUICKA_USB_LOADLIB *USB_LOADLIB;
typedef short QUICKA_USB_CLOSELIB(void);
QUICKA_USB_CLOSELIB *USB_CLOSELIB;
typedef short QUICKA_USB_INIT(void);
QUICKA_USB_INIT *USB_INIT;
typedef short QUICKA_USB_END(void);
QUICKA_USB_END *USB_END;
typedef short QUICKA_USB_WRITE(short v);
QUICKA_USB_WRITE *USB_WRITE;
typedef short QUICKA_USB_START(short KAF, short x1, short y1, short x2,
			       short y2, short bin_x, short bin_y,
			       short shutter, short shutter_mode,
			       short ampli_mode, short acq_mode, short d1,
			       short d2, short speed, short *imax,
			       short *jmax);
QUICKA_USB_START *USB_START;
typedef short QUICKA_USB_READAUDINE(short imax, short jmax, short *buf);
QUICKA_USB_READAUDINE *USB_READAUDINE;
#define QUICKA_NAME "quicka.so"
#endif

#endif
