/* contstruct.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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
 * $ID: contstruct.h,v $
 */

#ifndef __CONTSTRUCT_H__
#define __CONTSTRUCT_H__
/*
static char ContinuousSynchroName[] = "ContinuousSynchroName";
*/

typedef struct {
    struct camprop *cam;	// Camera
    unsigned short *bufacq;	//image buffer
    unsigned short *bufdisp;	//image buffer
    unsigned short nbcol;
    unsigned short nbrow;	// 
    unsigned char acqEnable;
    double dt;			// intervalle de temps en millisecondes 
    int mirx;			// mirror x
    int miry;			// mirror y


} ContinuousStruct;


#endif
