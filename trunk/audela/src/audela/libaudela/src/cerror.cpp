/* cerrors.cpp
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
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

//=====================================================================
//
//  CError , CErrorLibtt
//
//=====================================================================

#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "libstd.h"
#include "cerror.h"

//=====================================================================
//
//  class CError
//
//=====================================================================


CError::CError() throw(){
	buf = NULL;
}

CError::CError(const CError& err) throw(){
	buf = strdup(err.buf);
}

CError::CError(const int errnum) throw(){
	buf = new char[1024];
   strcpy(buf, message(errnum));
}

CError::CError(const char *f, ...) throw(){
	va_list val;

	va_start(val, f);
	vsetf(f, val);
	va_end(val);
}

CError::~CError()  throw() {
	delete[] buf;
}

char * CError::gets() const throw(){
   return buf;
}

void CError::setf(const char *f, ...) throw(){
	va_list val;

	va_start(val, f);
	vsetf(f,val);
	va_end(val);
}

void CError::vsetf(const char *f, va_list val) throw(){
	buf = new char[1024];
	if (buf) {
		buf[1023] = 0;
		//sprintf(buf, f, val);
      vsprintf(buf,f,val);

	}
}

void CError::discard() throw(){
	buf = NULL;
}

void CError::TransferFrom(CError& err) throw(){
	if (buf)
		free(buf);

	buf = err.buf;
	err.buf = NULL;
}

//------------------------------------------------------------------------------
// Messages d'erreur.
//
char* CError::message(int error)
{
   switch(error) {
      case ELIBSTD_BUF_EMPTY :
         return "buffer is empty";
      case ELIBSTD_NO_MEMORY_FOR_PIXELS :
         return "not enough memory for pixel allocation";
      case ELIBSTD_NO_MEMORY_FOR_KWDS :
         return "not enough memory for keywords allocation";
      case ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS :
         return "not enough memory for astrometric parameters allocation";
      case ELIBSTD_NO_NAXIS_KWD :
         return "image does not have mandatory FITS NAXIS1 keyword";
      case ELIBSTD_NO_NAXIS1_KWD :
         return "image does not have mandatory FITS NAXIS1 keyword";
      case ELIBSTD_NO_NAXIS2_KWD :
         return "image does not have mandatory FITS NAXIS2 keyword";
      case ELIBSTD_DEST_BUF_NOT_FOUND :
         return "destination buffer does not exist";
      case ELIBSTD_NO_ASTROMPARAMS :
         return "can not find astrometric parameters";
      case ELIBSTD_NO_MEMORY_FOR_LUT :
         return "not enough memory for LUT allocation";
      case ELIBSTD_CANNOT_CREATE_BUFFER :
         return "visu can not create buffer";
      case ELIBSTD_CANT_GETORCREATE_TKIMAGE :
         return "visu can not get or create TkImage";
      case ELIBSTD_NO_ASSOCIATED_BUFFER :
         return "visu has no associated buffer";
      case ELIBSTD_NO_TKPHOTO_HANDLE :
         return "can not find TkPhotoHandle";
      case ELIBSTD_NO_MEMORY_FOR_DISPLAY :
         return "not enough memory for image transformation";
      case ELIBSTD_WIDTH_POSITIVE :
         return "width must be positive";
      case ELIBSTD_X1X2_NOT_IN_1NAXIS1 :
         return "x1 and x2 must be contained between 1 and naxis1";
      case ELIBSTD_HEIGHT_POSITIVE :
         return "height must be positive";
      case ELIBSTD_Y1Y2_NOT_IN_1NAXIS2 :
         return "y1 and y2 must be contained between 1 and naxis2";
      case ELIBSTD_PALETTE_CANT_FIND_FILE:
         return "can't find palette file";
      case ELIBSTD_PALETTE_MALFORMED_FILE:
         return "the palette file doesn't contain 3 numbers per line";
      case ELIBSTD_PALETTE_NOTCOMPLETE:
         return "the palette file doesn't contain 256 entries";
      case ELIBSTD_NO_KWDS:
         return "image does not contain any keyword";
      case ELIBSTD_CANT_OPEN_FILE:
	   	return "can't open file";
      case ELIBSTD_NOT_IMPLEMENTED:
	   	return "not implemented";         

      default :
         return "unknown error code";
   }
}

//=====================================================================
//
//  class CErrorLibtt
//
//=====================================================================

CErrorLibtt::CErrorLibtt(const int errnum) throw(){
	buf = new char[1024];
   Libtt_main(TT_ERROR_MESSAGE,2,&errnum,buf);
}
