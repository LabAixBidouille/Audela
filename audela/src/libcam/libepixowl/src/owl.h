/* owl.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2013 The AudeLA Core Team
 *
 * Initial author : Matteo SCHIAVON <ilmona89@gmail.com>
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

/*
 * Commands to send to the camera Raptor Photonics OWL:browse confirm wa
 - header
 */

#ifndef H_OWL
#define H_OWL

#include "serial.h"

// State modes
#define	ACK_ON				0x10
#define UNHOLD_FPGA		0x02
#define	ENABLE_COMMS	0x01

// TEC modes
#define TEC_ON	0x01
#define TEC_OFF	0x00
#define AEXP_ON 0x02
#define AEXP_OFF 0x00

// Clock frequency (Hz)
#define CLOCK_EXP 160000000
#define CLOCK_FR 5000000

// NUC state
#define OFFSET_CORRECTED 			0x00
#define OFFSET_GAIN_CORRECTED 0x20
#define NORMAL 								0x40
#define OFFSET_GAIN_DARK			0x60
#define EIGHT_BIT_OFF_32					0x80
#define EIGHT_BIT_DARK						0xa0
#define EIGHT_BIT_GAIN_128				0xc0
#define OFF_GAIN_DARK_BADPIX	0xe0

// PEAK/Average
#define FULL_PEAK 0x00
#define FULL_AVERAGE 0xff

// ROI Appearence
#define GAIN_1_OUT		0x00
#define GAIN_075_OUT	0x80
#define GAIN_1_BOX		0x40

// Trigger modes
#define TRG_EXT		0x40
#define TRG_RISE	0x20
#define TRG_FALL	0x00
#define TRG_INT		0x00

// Dynamic Range
#define HIGH_DYNAMIC 0x01
#define STD_DYNAMIC 0x00

int serialInit();

int microReset();
int setState(uchar mode);
int setTEC_AEXP(uchar mode);
int setFrameRate(double frate);
int setExposure(double exp);
int setTrigger(uchar mode);
int setGain(int gain);
int setTriggerDelay(double delay);
int setDynamicRange(uchar mode);
int setTECtemp(ushort temp);
int setNUC(uchar mode);
int setAutoLevel(int level);
int setPeakAver(uchar mode);
int setAGCspeed(uchar speed);
int setROIappearence(uchar mode);
int setROIxsize(int size);
int setROIxoffset(int offset);
int setROIysize(int size);
int setROIyoffset(int offset);
int setViewNUCmap(uchar mode);

//TODO the get section

int getStatus(uchar *status);
int getTEC_AEXP(uchar *mode);
int getFrameRate(double *frate);
int getExposure(double *exp);
int getGain(int *gain);
int getPCBtemp(double *temp);
int getCMOStemp(int *temp);
int getMicroVersion(uchar *version);
int getFPGAversion(uchar *version);
int getTrigger(uchar *mode);
int getROIxsize(int *size);
int getROIxoffset(int *offset);
int getROIysize(int *size);
int getROIyoffset(int *offset);
int getDynamicRange(uchar *mode);
int getSerialNumber(int *number);
int getManuData(uchar *data);
int getTECtemp(int *temp);
int getNUC(uchar *mode);
int getAutoLevel(int *level);
int getPeakAver(uchar *mode);
int getAGCspeed(uchar *speed);
int getROIappearence(uchar *mode);

#endif //H_OWL
