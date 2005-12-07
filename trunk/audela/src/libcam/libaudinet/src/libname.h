/* libname.h
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
 * Revision 1.1  2005/02/12 22:04:17  Administrateur
 * *** empty log message ***
 *
 * Revision 1.1  2003-04-25 13:45:39+02  michel
 * <>
 *
 * Revision 1.0  2001-12-10 15:17:40+01  michel
 * initial revision
 *
 */

#ifndef __LIBNAME_H__
#define __LIBNAME_H__

/*
 * Nom du point d'entree de la librairie, doit etre Xx_Init pour une librairie libxx
 * (la majuscule est importante pour permettre un chargement par load libxx).
 */
#define CAM_ENTRYPOINT Audinet_Init

/*
 * Informations sur le driver, le nom est celui qui apparait quand on fait "package names"
 * et la version apparait avec la commande Tcl "package require libxx"
 */
#define CAM_LIBNAME "libaudinet"
#define CAM_LIBVER "0.1"

/*
 * Initialisation d'informations indispensables pour la librairie xx.
 */
#define CAM_DRIVNAME "audinet"

#define CAM_INI audinet_cam_ini
#define CAM_DRV audinet_cam_drv

#endif
