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

// $Id: liblink.h,v 1.4 2009-01-12 18:02:29 michelpujol Exp $

#ifndef __LIBLINK_H__
#define __LIBLINK_H__

/*****************************************************************/
/*             This part is common for all cam drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

//#include "liblink.h"

#include "liblink/useitem.h"

#define LINK_OK       0
#define LINK_ERROR    -1


class CLink {

 public:
   CLink();
   virtual ~CLink();
   virtual int openLink(int argc, char **argv)=0;
   virtual int closeLink()=0;
   int init_common(int argc, char **argv);
   int addUse(char *deviceId, char *usage, char *comment);
   int removeUse(char *deviceId, char *usage);
   int getUse(char **list);

   int getIndex();
   void setLastMessage(const char *format, ...);
   char * getLastMessage();
   void setAuthorized(int value);
   void setLinkNo(int value);


 protected:
   int authorized;
   int index;
   char msg[1024];
   int linkno;
   CUseItem *useItem;

};

struct cmditem {
    char *cmd;
    Tcl_CmdProc *func;
};




#endif
