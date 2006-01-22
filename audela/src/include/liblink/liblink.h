/* liblink.h
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
 * Foundation, Inc., 675 Mass Ave, Linkbridge, MA 02139, USA.
 */

#ifndef __LIBLINK_H__
#define __LIBLINK_H__

/*****************************************************************/
/*             This part is common for all cam drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#include "liblink.h"

#include "tcl.h"

#define LINK_OK       0
#define LINK_ERROR    -1


struct cmditem {
    char *cmd;
    Tcl_CmdProc *func;
};


class CLink {

 public:

	//CLink(Tcl_Interp * interp);
	//~CLink();
   int init_common(int argc, char **argv);
   // intialisation specifique
   virtual int init(int argc, char **argv)=0;
   // intialisation specifique
   virtual int close()=0;


   int authorized;
	Tcl_Interp *interp;
   int linkno;
   int index;
   char msg[1024];

 protected:


    };

#endif
