/* log.h
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
 * fonctions de trace
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2005/02/12 22:04:17  Administrateur
 * *** empty log message ***
 *
 * Revision 1.1  2003-04-25 13:45:58+02  michel
 * <>
 *
 * Revision 1.0  2001-12-10 15:17:41+01  michel
 * initial revision
 *
 */

#ifndef __LOG_H__
#define __LOG_H__

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif


void initLog();
void logInfo(char *fmt, ...);
void logError(char *fmt, ...);
void logImage(unsigned short *p0, int imax, int jmax);


#endif
