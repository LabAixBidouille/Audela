/* coordserver.h
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
// Mise a jour $Id: coordserver.h,v 1.1 2009-12-08 22:56:13 michelpujol Exp $

#ifndef __COORD_SERVER_H__
#define __COORD_SERVER_H__

int socket_openCoordServerSocket(struct telprop *tel, int coordServerPort);
int socket_closeCoordServerSocket(struct telprop *tel) ;
void socket_writeCoordServerSocket(struct telprop *tel, char * notification);

#endif