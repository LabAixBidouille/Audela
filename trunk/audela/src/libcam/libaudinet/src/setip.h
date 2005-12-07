/* setip.h
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
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2005/02/12 22:04:18  Administrateur
 * *** empty log message ***
 *
 * Revision 1.2  2003-12-27 13:05:27+01  michel
 * suppression des warning Linux signalees par Remi (ajout ligne vide en fin de fichier)
 *
 * Revision 1.1  2003-06-07 10:28:12+02  michel
 * ajout errorMessage en sortie de setip()
 *
 * Revision 1.0  2003-06-06 14:46:07+02  michel
 * Initial revision
 *
 *
 */

#ifndef __SETIP_H__
#define __SETIP_H__

int setip(char *szClientIP, char *szClientMAC, char *szClientNM,
	  char *szClientGW, char *errorMessage);

#endif
