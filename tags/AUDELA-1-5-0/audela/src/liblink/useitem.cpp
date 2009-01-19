/* liblink.cpp
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

// $Id: useitem.cpp,v 1.1 2006-09-29 19:53:43 michelpujol Exp $

#include <stdlib.h>
#include <string.h>         //pour strdup
#include "liblink/useitem.h"


CUseItem::CUseItem(CUseItem *item1, char* deviceId, char* usage, char *comment) {
   this->deviceId = strdup(deviceId);
   this->usage  = strdup(usage);
   this->comment  = strdup(comment);

   //     prev1=null  item1  next1
   //     prev1=null  this item1 next1
   this->prev = NULL;
   this->next = item1;

   if( item1 != NULL ) {
      item1->prev = this ;     
   } 

}

CUseItem::~CUseItem() {
   if(deviceId != NULL) free(deviceId);
   if(usage != NULL) free(usage);
   if(comment != NULL) free(comment);
   
   //     prev1 <=> this <=> next1
   //     prev1    <=>  next1
   if( prev != NULL ) {
      prev->next = this->next;     
   }

   if( next != NULL ) {
      next->prev = this->prev;     
   }
}


CUseItem * CUseItem::getNext() {
   return next;
}
  
CUseItem * CUseItem::getPrev() {
   return prev;
}

char * CUseItem::getDeviceId() {
   return this->deviceId;
}

char * CUseItem::getUsage() {
   return this->usage;
}
char * CUseItem::getComment() {
   return this->comment;
}


void CUseItem::setNext(CUseItem *item) {
   next = item;
}

void CUseItem::setPrev(CUseItem *item) {
   prev = item;
}
