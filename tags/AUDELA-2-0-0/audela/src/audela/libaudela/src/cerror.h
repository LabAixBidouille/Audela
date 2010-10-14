/* cerror.h
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

#ifndef __CERRORH__
#define __CERRORH__

#include <stdio.h>

#ifdef WIN32
   #ifdef LIBAUDELA_EXPORTS
      #define LIBAUDELA_API __declspec( dllexport )
   #else
      #define LIBAUDELA_API __declspec( dllimport )
   #endif//LIBAUDELA_EXPORTS
#else
   #define LIBAUDELA_API
#endif//WIN32

/*
 * Codes d'erreur de libstd : ils sont negatifs alors que
 * ceux de libtt sont positifs.
 */
extern char* message(int error);
#define ELIBSTD_BUF_EMPTY                  -1
#define ELIBSTD_NO_MEMORY_FOR_PIXELS       -2
#define ELIBSTD_NO_MEMORY_FOR_KWDS         -3
#define ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS -4
#define ELIBSTD_NO_KWDS                    -5
#define ELIBSTD_NO_NAXIS1_KWD              -6
#define ELIBSTD_NO_NAXIS2_KWD              -7
#define ELIBSTD_DEST_BUF_NOT_FOUND         -8
#define ELIBSTD_NO_ASTROMPARAMS            -9
#define ELIBSTD_NO_MEMORY_FOR_LUT          -10
#define ELIBSTD_CANNOT_CREATE_BUFFER       -11
#define ELIBSTD_CANT_GETORCREATE_TKIMAGE   -12
#define ELIBSTD_NO_ASSOCIATED_BUFFER       -13
#define ELIBSTD_NO_TKPHOTO_HANDLE          -14
#define ELIBSTD_NO_MEMORY_FOR_DISPLAY      -15
#define ELIBSTD_WIDTH_POSITIVE             -16
#define ELIBSTD_X1X2_NOT_IN_1NAXIS1        -17
#define ELIBSTD_HEIGHT_POSITIVE            -18
#define ELIBSTD_Y1Y2_NOT_IN_1NAXIS2        -19

#define ELIBSTD_PALETTE_CANT_FIND_FILE     -20
#define ELIBSTD_PALETTE_MALFORMED_FILE     -21
#define ELIBSTD_PALETTE_NOTCOMPLETE        -22
#define ELIBSTD_SUB_WINDOW_ALREADY_EXIST   -23
#define ELIBSTD_PIXEL_FORMAT_UNKNOWN       -24
#define ELIBSTD_CANT_OPEN_FILE				 -25
#define ELIBSTD_NO_NAXIS_KWD               -26

#define ELIBSTD_LIBTT_ERROR    				 -29

#define ELIBSTD_NOT_IMPLEMENTED				 -30

//=====================================================================
//
//  class CError
//
//=====================================================================

class LIBAUDELA_API CError {
private:
	const CError& operator=(const CError&);		// protect against accidents

protected:
	char *buf;

public:
	CError() throw();
	CError(const CError& err) throw();
	CError(const int errnum)  throw();
	CError(const char *f, ...) throw();
	~CError() throw();
//	void assign(const CError& e) throw();
	void setf(const char *f, ...) throw();
	void vsetf(const char *f, va_list val) throw();
	char * gets(void) const throw();
	void discard() throw();
	void TransferFrom(CError& err) throw();
   static char * message(int error); // static pour pouvoir l'utiliser sans créer d'intance  de CError
                                             // cpour compatibilité avec l'ancien système d'erreur
                                             // qui n'utilisait pas les exceptions
};

//=====================================================================
//
//  class CErrorLibtt
//
//=====================================================================

class LIBAUDELA_API CErrorLibtt : public CError{
private:
	const CErrorLibtt& operator=(const CErrorLibtt&);		// protect against accidents

public:
	CErrorLibtt(const int errnum)  throw();
};


#endif
