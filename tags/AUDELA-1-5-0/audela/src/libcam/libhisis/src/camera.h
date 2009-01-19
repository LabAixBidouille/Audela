/* camera.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

/*
 *   structure pour les fonctions étendues
 */
/*char *cam_shuttertypes[];*/


/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour Hisis 11 --- */
    int nb_vidages;
    /* --- pour Hisis 24 --- */
    int typeport;
    int portnum;
    /* --- boucles pour Hisis --- */
    int hisis22_paramloops;
    int hisis22_14_synchroloops;
    int hisis22_12_readloops;
    int hisis22_14_readloops;
    /* --- parametres Hisis24/33/44 --- */
    union {
	unsigned char raw;
	struct {
	    unsigned char delay:6;	/* Duree d'ouverture de l'obturateur, en millisecondes */
	    unsigned char open:1;	/* Etat de l'obturateur quand synchro=0 (1:ouvert, 0:ferme) */
	    unsigned char synchro:1;	/* Obturateur synchronise pendant la pose */
	} shuttermode;
    } hisis24_shutter;

    union {
	unsigned char raw;
    } hisis24_bell0;
    union {
	unsigned char raw;
    } hisis24_bell1;
    union {
	unsigned char raw;
    } hisis24_bell2;
    union {
	unsigned char raw;
    } hisis24_bell3;

    union {
	unsigned char raw;
	struct {
	    unsigned char read_filter:3;	/* poids faible */
	    unsigned char enabled:1;
	    unsigned char filter:3;
	    unsigned char enable:1;	/* poids fort */
	} filterwheelmode;
    } hisis24_filterwheel;


    union {
	unsigned char raw;
	struct {
	    unsigned char pwr:7;	/* Puissance du ventilateur, entre 0 et 127 */
	    unsigned char on:1;	/* Alimentation de l'obturateur (1:on, 0:off) */
	} fanmode;
    } hisis24_fan;
    /*
       int hisis24_fan_on;
       int hisis24_fan_pwr;
     */
    union {
	unsigned char raw;
    } hisis24_gain;


};


#define HISIS24_PARAM_EXPTIME_HI          0
#define HISIS24_PARAM_EXPTIME_MED         1
#define HISIS24_PARAM_EXPTIME_LO          2
#define HISIS24_PARAM_PAUSETIME_HI        3
#define HISIS24_PARAM_PAUSETIME_MED       4
#define HISIS24_PARAM_PAUSETIME_LO        5
#define HISIS24_PARAM_BINX                6
#define HISIS24_PARAM_BINY                7
#define HISIS24_PARAM_CCDTEMPCHECK        8
#define HISIS24_PARAM_CCDTEMP_HI          9
#define HISIS24_PARAM_CCDTEMP_LO          10
#define HISIS24_PARAM_CCDOFFSET           11
#define HISIS24_PARAM_CCDGAIN             12
#define HISIS24_PARAM_FAN                 13
#define HISIS24_PARAM_DRIFTSCAN_HI        14
#define HISIS24_PARAM_DRIFTSCAN_LO        15
#define HISIS24_PARAM_WINX0_HI            16
#define HISIS24_PARAM_WINX0_LO            17
#define HISIS24_PARAM_WINY0_HI            18
#define HISIS24_PARAM_WINY0_LO            19
#define HISIS24_PARAM_WINWIDTH_HI         20
#define HISIS24_PARAM_WINWIDTH_LO         21
#define HISIS24_PARAM_WINHEIGTH_HI        22
#define HISIS24_PARAM_WINHEIGTH_LO        23
#define HISIS24_PARAM_SEQUENCE            24
#define HISIS24_PARAM_SHUTTER             25
#define HISIS24_PARAM_BUZZER_0            26
#define HISIS24_PARAM_BUZZER_1            27
#define HISIS24_PARAM_BUZZER_2            28
#define HISIS24_PARAM_BUZZER_3            29
#define HISIS24_PARAM_LED                 30
#define HISIS24_PARAM_MEMPAGE             31
#define HISIS24_PARAM_EXTSYNCH_DB9        32
#define HISIS24_PARAM_EXTSYNCH_RCA        33
#define HISIS24_PARAM_RTC_YY              34
#define HISIS24_PARAM_RTC_MM              35
#define HISIS24_PARAM_RTC_DD              36
#define HISIS24_PARAM_RTC_H               37
#define HISIS24_PARAM_RTC_M               38
#define HISIS24_PARAM_RTC_S               39
#define HISIS24_PARAM_FILTERWHEEL         40
#define HISIS24_PARAM_ADVSHUTTER_0        41
#define HISIS24_PARAM_ADVSHUTTER_1        42
#define HISIS24_PARAM_ADVSHUTTER_2        43
#define HISIS24_PARAM_ADVSHUTTER_3        44
#define HISIS24_PARAM_ADVSHUTTER_4        45
#define HISIS24_PARAM_ADVSHUTTER_5        46
#define HISIS24_PARAM_ADVSHUTTER_6        47
#define HISIS24_PARAM_CCDDEFROST          48
#define HISIS24_PARAM_GLASSDEFROST        49
#define HISIS24_PARAM_COOLERTEMP_HI       50
#define HISIS24_PARAM_COOLERTEMP_LO       51
#define HISIS24_PARAM_PWRMAXLED0          52
#define HISIS24_PARAM_PWRMINLED0          53
#define HISIS24_PARAM_PWRMAXLED1          54
#define HISIS24_PARAM_PWRMINLED1          55
#define HISIS24_PARAM_PWRMAXLED2          56
#define HISIS24_PARAM_PWRMINLED2          57
#define HISIS24_PARAM_IMGHEADER           58
#define HISIS24_PARAM_CAMINFO_HI          59
#define HISIS24_PARAM_CAMINFO_MED         60
#define HISIS24_PARAM_CAMINFO_LO          61
#define HISIS24_PARAM_AUTOGUIDE           62
#define HISIS24_PARAM_ERRORS              63

#define HISIS24_FAN_ON                    (1<<7)
#define HISIS24_FAN_OFF                   (0<<7)
#define HISIS24_FAN_PWRMAX                127
#define HISIS24_FAN_PWRMIN                0

#define HISIS24_SHUTTER_DLYMAX            63
#define HISIS24_SHUTTER_DLYMIN            0

#define SHUTTER_MASK_SYNCHRO              0x80
#define SHUTTER_MASK_STATE                0x40
#define SHUTTER_MASK_DELAY                0x3F

#define FILTERWHEEL_NB_MIN                1
#define FILTERWHEEL_NB_MAX                6

#define HISIS24_COOLER_MAXTEMP            (10.0)
#define HISIS24_COOLER_MINTEMP            (-40.0)

#define HISIS24_GAIN_MIN                  1.0f
#define HISIS24_GAIN_MAX                  8.0f

#define HISIS24_DRV_OK                    0x00
#define HISIS24_DRV_PB_BAD_CONNEXION      0x01
#define HISIS24_DRV_PB_BAD_CHECKSUM       0x02
#define HISIS24_DRV_PB_OUTBOUND_PARAM     0x03
#define HISIS24_DRV_PB_UNKNOWN            0x04
#define HISIS24_DRV_PB_OUTBOUND_ADDRESS   0x05
#define HISIS24_DRV_PB_UNWRITABLE_PARAM   0x06
#define HISIS24_DRV_FW_NOT_ENABLED        0x10
#define HISIS24_DRV_FW_NO_FW              0x11
#define HISIS24_DRV_SHUTTER_EXCEED_DELAY  0x20
#define HISIS24_DRV_COOLER_UNDERFLOW      0x30
#define HISIS24_DRV_COOLER_OVERFLOW       0x31
#define HISIS24_DRV_COOLER_NO_MEASURE     0x32


#define HISIS24_STATUS_IDLE               14
#define HISIS24_STATUS_PAUSE              13
#define HISIS24_STATUS_CLEANCCD           9
#define HISIS24_STATUS_EXPOSURE           11
#define HISIS24_STATUS_DIGITIZE           7
#define HISIS24_STATUS_CMD1               12
#define HISIS24_STATUS_CMD2               10
#define HISIS24_STATUS_CMD3               6


void hisis_test_out(struct camprop *cam, unsigned long nb_out);

void hisis24_writevercom(struct camprop *cam, int A, int B, int *result);
void hisis24_writeverparam(struct camprop *cam, int A, int B, int *result);
void hisis24_readpar(struct camprop *cam, int *param, int nibble,
		     int address, int *result);
int hisis24_fan(struct camprop *cam, int on, int pwr);
int hisis24_shutter(struct camprop *cam, int synchro, int open, int delay);
int hisis24_bell(struct camprop *cam, int bell);
int hisis24_filterwheel(struct camprop *cam, int enable, int nb, int *fnb);
int hisis24_coolermax(struct camprop *cam);
int hisis24_cooleroff(struct camprop *cam);
int hisis24_coolercheck(struct camprop *cam, float temp);
int hisis24_gettemp(struct camprop *cam, float *temp);
int hisis24_resetall(struct camprop *cam);
int hisis24_readstatus(struct camprop *cam);
int hisis24_gainampli(struct camprop *cam, float gain);
float hisis24_gain(struct camprop *cam);


#endif
