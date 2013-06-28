/* owl.c 
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
 * Commands to send to the camera Raptor Photonics OWL
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include "owl.h"
#include "serial.h"
#include "xcliball.h"

/* int serialInit()

	Arguments:

	Return:
		0		all ok
		<0	error

	Behaviour:
		initialize serial link
*/
int serialInit() {
	return ser_config();
}

/* int microReset()

	Arguments:

	Return:
		0		all ok
		<0	error

	Behaviour:
		send the Micro RESET command and perform the whole reset protocol
*/
int microReset() {
	int ret;
	uchar status;

	ret = ser_reset();
	if (ret<0)
		return ret;

	usleep(10000);

	do {
		ret = ser_set_state(ACK_ON|ENABLE_COMMS,2);
	} while (ret != 0);

	ret = ser_set_state(ACK_ON|UNHOLD_FPGA,2);
	printf("%d\n",ret);
	if (ret<0)
		return ret;

	do {
		ret = ser_get_status(&status,2);
		if (ret<0)
			return ret;
	} while ( ! (status & FPGA_BOOTED) );

	ret = ser_set_state(ACK_ON|UNHOLD_FPGA,2);
	if (ret<0)
		return ret;

	return 0;
		
}

/* int setState(uchar mode)

	Arguments:
		mode		state mode required

	Return:
		0		all ok
		<0	error

	Behaviour:
		set the system state (checksum, ack, FPGA reset, comms to FPGA EPROM)
*/
int setState(uchar mode) {
	return ser_set_state(mode,2);
}

/* int setTEC_AEXP(uchar mode)

	Arguments:
		mode		TEC mode (TEC_ON or TEC_OFF) | AEXP mode (AEXP_ON or AEXP_OFF)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		enables or disables TEC and Auto Exp
*/
int setTEC_AEXP(uchar mode) {
	return ser_write_reg(0x00,mode,2);
}

/* int setFrameRate(double frate)

	Arguments:
		frate		frame rate (in fps)

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the frame rate
*/
int setFrameRate(double frate) {
	int r;
	uchar i;
	uint32 cycles;
	uchar *p_cycles;

	cycles = (uint32)(CLOCK_FR/frate);
	p_cycles = (uchar *)&cycles;

	for (i=0; i<4; i++) {
		r = ser_write_reg(0xdd+i,p_cycles[3-i],2);
		if ( r<0 )
			return r;
	}
	
	return 0;
}

/* int setExposure(double exp)

	Arguments:
		exp		exposure time [in s]

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the exposure time
*/
int setExposure(double exp) {
	int r;
	uchar i;
	uint64 cycles;
	uchar *p_cycles;

	cycles = (uint64)((CLOCK_EXP)*exp);
	p_cycles = (uchar *)&cycles;

	for (i=0; i<5; i++) {
		r = ser_write_reg(0xee+i,p_cycles[4-i],2);
		if ( r<0 )
			return r;
	}
	
	return 0;
}

/* int setTrigger(uchar mode)

	Arguments:
		mode		trigger mode (list defined in owl.h)

	Return:
		0			all ok
		<0		error

	Behaviour:
		possible modes: TRG_EXT + (TRG_RISE or TRG_FALL) or TRG_INT
*/
int setTrigger(uchar mode) {
	return ser_write_reg(0xd4,mode,2);
}

/* int setGain(int gain)

	Arguments:
		gain		digital video gain

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the digital video gain
*/
int setGain(int gain) {
	int r;
	uchar i;
	uint16 g;
	uchar *pg;

	g = (uint16)gain*256;
	pg = (uchar *)&g;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xd5+i,pg[1-i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setTriggerDelay(double delay)

	Arguments:
		delay		trigger delay (in s)

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the external trigger delay
*/
int setTriggerDelay(double delay) {
	int r;
	uchar i;
	uint64 cycles;
	uchar *p_cycles;

	cycles = (uint64)((CLOCK_EXP)*delay);
	p_cycles = (uchar *)&cycles;

	for (i=0; i<5; i++) {
		r = ser_write_reg(0xe9+i,p_cycles[4-i],2);
		if ( r<0 )
			return r;
	}
	
	return 0;
}

/* int setDynamicRange(uchar mode)

	Arguments:
		mode		Dynamic range mode (HIGH_DYNAMIC or STD_DYNAMIC)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		enables or disables High Dynamic Range
*/
int setDynamicRange(uchar mode) {
	int r;
	uchar i;
	uchar std[4] = { 0x2f, 0xfc, 0x00, 0x04 };
	uchar high[4] = { 0x3f, 0xfc, 0x00, 0x04 };
	uchar *selected = NULL;

	if ( mode == HIGH_DYNAMIC )
		selected = high;
	else if ( mode == STD_DYNAMIC )
		selected = std;
	else
		return -5;

	for (i=0; i<5; i++) {
		r = ser_write_reg(0xe4+i,selected[i],2);
		if ( r<0 )
			return r;
	}
	
	return 0;

}

/* int setTECtemp(int temp)

	Arguments:
		temp		temperature (2 bytes)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		set the TEC temperature
*/
int setTECtemp(int temp) {
	ushort t;

	t = (ushort)temp;

	t = t << 4;
	return ser_set_tec_point(&temp,2);
}

/* int setNUC(uchar mode)

	Arguments:
		mode	NUC mode (see owl.h and the OWL manual)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		set the NUC mode
*/
int setNUC(uchar mode) {
	return ser_write_reg(0xf9,mode,2);
}

/* int setAutoLevel(int level)

	Arguments:
		level		value between 0 and 0x3fff

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the average video level detector
*/
int setAutoLevel(int level) {
	int r;
	uchar i;
	uint16 l;
	uchar *pg;

	l = (uint16)level;
	l = l << 2;
	pl = (uchar *)&l;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0x23+i,pl[1-i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setPeakAver(uchar mode)

	Arguments:
		mode	FULL_PEAK or FULL_AVERAGE

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the PEAK/Average option
*/
int setPeakAver(uchar mode) {
	return ser_write_reg(0x2d,mode,2);
}

/* int setAGCspeed(uchar speed)

	Arguments:
		speed		bits 7..4 GAIN speed, bits 3..0 EXP speed

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the AGC speed
*/
int setAGCspeed(uchar speed) {
	return ser_write_reg(0x2f,speed,2);
}

/* int setROIappearance(uchar mode)

	Arguments:
		mode	GAIN_1_OUT, GAIN_075_OUT, GAIN_1_BOX

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the ROI appearance
*/
int setROIappearence(uchar mode) {
	return ser_write_reg(0x31,mode,2);
}


/* int setROIxsize(int size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the x size of the ROI
*/
int setROIxsize(int size) {
	uchar s;
	s = (uchar)(size/4);
	return ser_write_reg(0x35,s,2);
}

/* int setROIxoffset(int offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the x offset of the ROI
*/
int setROIxoffset(int offset) {
	uchar o;
	o = (uchar)(offset/4);
	return ser_write_reg(0x32,o,2);
}

/* int setROIysize(int size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the y size of the ROI
*/
int setROIysize(int size) {
	uchar s;
	s = (uchar)(size/4);
	return ser_write_reg(0x36,s,2);
}

/* int setROIyoffset(int offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the y offset of the ROI
*/
int setROIyoffset(int offset) {
	uchar o;
	o = (uchar)(offset/4);
	return ser_write_reg(0x33,o,2);
}

/* START OF THE GET FUNCTIONS */

/* int getStatus(uchar *status)

	Arguments:
		status		system status (see Osprey documentation) - 1 byte

	Return:
		0		all ok
		<0	error

	Behaviour:
		read system status (checksum, ack, FPGA booted ok, ...)
*/
int getStatus(uchar *status) {
	return ser_get_status(status,2);
}

/* int getTEC_AEXP(uchar *mode)

	Arguments:
		mode		tec on/off (TEC_ON=0x01 or TEC_OFF=0x00) and 
						aexp on/off (AEXP_ON=0x02 or AEXP_OFF=0x00) - 1 byte

	Return:
		0		all ok
		<0	error

	Behaviour:
		return if TEC and Auto Exposure are enabled or not
*/
int getTEC_AEXP(uchar *mode) {
	return ser_read_reg(0x00,mode,2);
}

/* int getFrameRate(double *frate)

	Arguments:
		frate		frame rate (in fps)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current frame rate
*/
int getFrameRate(double *frate) {
	int r;
	uchar i;
	uint32 cycles;
	uchar *p_cycles;

	p_cycles = (uchar *)&cycles;

	for (i=0; i<4; i++) {
		r = ser_read_reg(0xdd+i,&p_cycles[3-i],2);
		if ( r<0 )
			return r;
	}
	
	*frate=CLOCK_FR/(double)cycles;
	return 0;
}

/* int getExposure(double *exp)

	Arguments:
		exp		exposure time [in s]

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the exposure time
*/
int getExposure(double *exp) {
	int r;
	uchar i;
	uint64 cycles=0;
	uchar *p_cycles;

	p_cycles = (uchar *)&cycles;

	for (i=0; i<5; i++) {
		r = ser_read_reg(0xed+i,&p_cycles[4-i],2);
		if ( r<0 )
			return r;
	}

	*exp = (cycles)/(double)CLOCK_EXP;
	
	return 0;
}

/* int getGain(int *gain)

	Arguments:
		gain		digital video gain

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current digital video gain
*/
int getGain(int *gain) {
	int r;
	uchar i;
	uint16 g;
	uchar *pg;

	pg = (uchar *)&g;

	for (i=0; i<2; i++) {
		r = ser_read_reg(0xd5+i,&pg[1-i],2);
		if ( r<0 )
			return r;
	}

	*gain=g/256;

	return 0;
}

/* int getPCBtemp(double *temp)

	Arguments:
		temp		PCB temperature (Celsius)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current temperature of the electronics
*/
int getPCBtemp(double *temp) {
	int r;
	uchar i;
	uchar data[2];
	double t;

	r = ser_read_temp_reg(0x97,data,2);
	if ( r<0 )
		return r;

	t = 0.5*( (data[0]&0x80) >> 7 )
	t += (double)data[1]

	*temp = t;

	return 0;
}

/* int getCMOStemp(int *temp)

	Arguments:
		temp		CMOS sensor temperature (to be extract -> see doc)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current temperature of the CMOS sensor
*/
int getCMOStemp(int *temp) {
	int r;
	uchar i;
	uchar data[2];
	ushort *t;

	r = ser_read_temp_reg(0x91,data,2);
	if ( r<0 )
		return r;

	t = (ushort *)data;

	*temp=t;

	return 0;
}

/* int getMicroVersion(uchar *version)

	Arguments:
		version		buffer where to put the version - 2 bytes

	Return:
		0		all ok
		<0	error

	Behaviour:
		version = {major_version, minor_version}
*/
int getMicroVersion(uchar *version) {
	return ser_get_micro(version,2);
}

/* int getFPGAversion(uchar *version)

	Arguments:
		version		FPGA version - 2 bytes

	Return:
		0			all ok
		<0		error

	Behaviour:
		version = {major_version, minor_version}
*/
int getFPGAversion(uchar *version) {
	int r;
	uchar i;

	for (i=0; i<2; i++) {
		r = ser_read_reg(0x7e + i,version+i,2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int getTrigger(uchar *mode)

	Arguments:
		mode		trigger mode (list defined in owl.h)

	Return:
		0			all ok
		<0		error

	Behaviour:
		return current trigger mode
		possible modes: TRG_RISE, TRG_EXT
*/
int getTrigger(uchar *mode) {
	return ser_read_reg(0xf2,mode,2);
}

/* int getROIxsize(int *size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current x size of the ROI
*/
int getROIxsize(int *size) {
	int r;
	uchar s;

	r = ser_read_reg(0x35,&s,2);
	if ( r<0 )
		return r;

	*size = (int)s*4;

	return 0;
}

/* int getROIxoffset(int *offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current x offset of the ROI
*/
int getROIxoffset(int *offset) {
	int r;
	uchar o;

	r = ser_read_reg(0x32,&o,2);
	if ( r<0 )
		return r;

	*offset = (int)o*4;

	return 0;
}

/* int getROIysize(int *size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current y size of the ROI
*/
int getROIysize(int *size) {
	int r;
	uchar s;

	r = ser_read_reg(0x36,&s,2);
	if ( r<0 )
		return r;

	*size = (int)s*4;

	return 0;
}

/* int getROIyoffset(int *offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current y offset of the ROI
*/
int getROIyoffset(int *offset) {
	int r;
	uchar o;

	r = ser_read_reg(0x33,&o,2);
	if ( r<0 )
		return r;

	*offset = (int)o*4;

	return 0;

}

/* int getSerialNumber(int *number)

	Arguments:
		number		serial number

	Return:
		0		all ok
		<0	error

	Behaviour:
		get the current Unit Serial Number
*/
int getSerialNumber(int *number) {
	return ser_read_eeprom((uchar *)number,2,2);
}

/* int getManuData(uchar *data)

	Arguments:
		data		manufacturer data - 18 bytes (see Osprey doc)

	Return:
		0		all ok
		<0	error

	Behaviour:
		get the manufacturers data
*/
int getManuData(uchar *data) {
	int r;

	r = setState(ACK_ON|ENABLE_COMMS|UNHOLD_FPGA);
	if ( r<0 )
		return r;

	r = ser_read_eeprom(data,0x12,2);
	if ( r<0 )
		return r;

	r = setState(ACK_ON|UNHOLD_FPGA);
	if ( r<0 )
		return r;

	return 0;
}

/* int getTECtemp(int *temp)

	Arguments:
		temp		temperature (2 bytes)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		get the TEC temperature
*/
int getTECtemp(int *temp) {
	uchar data[2];
	ushort *pt;
	int r;

	r = ser_get_tec_point(&data,2);
	if (r<0)
		return r;

	pt = (ushort *)data;
	*pt = *pt >> 4;
	*temp = (int)(*pt);

	return 0;
}

/* int getNUC(uchar *mode)

	Arguments:
		mode	NUC mode (see owl.h and the OWL manual) -- 1 byte

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		get the NUC mode
*/
int getNUC(uchar *mode) {
	return ser_read_reg(0xf9,mode,2);
}

/* int getAutoLevel(int *level)

	Arguments:
		level		value between 0 and 0x3fff

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the average video level detector
*/
int getAutoLevel(int *level) {
	int r;
	uchar i;
	uint16 *pl;
	uchar data[2];

	for (i=0; i<2; i++) {
		r = ser_read_reg(0x23+i,data[1-i],2);
		if ( r<0 )
			return r;
	}

	*pl = *pl >> 2;
	*level = *pl;

	return 0;
}

/* int getPeakAver(uchar *mode)

	Arguments:
		mode	FULL_PEAK or FULL_AVERAGE -- 1 byte

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the PEAK/Average option
*/
int getPeakAver(uchar *mode) {
	return ser_read_reg(0x2d,mode,2);
}

/* int setAGCspeed(uchar *speed)

	Arguments:
		speed		bits 7..4 GAIN speed, bits 3..0 EXP speed

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the AGC speed
*/
#ifndef H_RAPTOR
int getAGCspeed(uchar *speed) {
	return ser_read_reg(0x2f,speed,2);
}

/* int getROIappearance(uchar *mode)

	Arguments:
		mode	GAIN_1_OUT, GAIN_075_OUT, GAIN_1_BOX

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the ROI appearance
*/
int setROIappearence(uchar *mode) {
	return ser_read_reg(0x31,mode,2);
}
