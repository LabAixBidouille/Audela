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
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2005/02/12 22:04:18  Administrateur
 * *** empty log message ***
 *
 * Revision 1.4  2003-12-05 00:58:58+01  michel
 * ajout une ligne vide a la fin du fichier
 *
 * Revision 1.3  2003-04-25 13:50:45+02  michel
 * add sockudp_shutdown()
 *
 * Revision 1.2  2002-09-04 21:47:36+02  michel
 * ajoute ping
 *
 * Revision 1.1  2002-08-22 22:22:30+02  michel
 * change les parametres de socktcp_send
 *
 * Revision 1.0  2001-12-10 15:17:41+01  michel
 * initial revision
 *
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
