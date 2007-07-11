/* camera.h
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
 * Adapter le contenu de ce fichier a votre camera preferee
 * notamment la structure "camprop"
 *
 * $Id: socketaudinet.h,v 1.2 2006-01-22 22:01:28 michelpujol Exp $
 */

#ifndef __SOCKETHTTP_H__
#define __SOCKETHTTP_H__

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include <libcam/libstruc.h>

#define false 0
#define true  1

int socktcp_open(char *sHost, int httpport);
int socktcp_close();
//int socktcp_send(char * sURL );
int socktcp_send(char *ipAdress, int port, char *uri);
int socktcp_recv(char *buffer, int len);

int sockudp_open(char *destIP, int destport, int listenport);
int sockudp_close();
int sockudp_send(char *sURL);
int sockudp_recv(char *buffer, int len);
int sockudp_shutdown();

int ping(char *hostName, int nbTry, int receivedTimeOut);

#endif
