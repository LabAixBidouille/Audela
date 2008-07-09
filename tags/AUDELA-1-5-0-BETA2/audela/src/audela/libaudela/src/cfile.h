/* cvisu.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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

#ifndef __CDCFILEH__
#define __CDCFILEH__

#include "fitskw.h"
#include "cpixels.h"

typedef enum { CFILE_FITS, CFILE_JPEG, CFILE_GIF, CFILE_PNG, CFILE_RAW, CFILE_UNKNOWN} CFileFormat;


class CFile  {

public:
   CFile();
   ~CFile();

   static CFileFormat getFormatFromHeader(char * filename);
   static CFileFormat loadFile(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   static CFileFormat saveFile(char * filename, int dataTypeOut, CPixels *pixels, CFitsKeywords *keywords);   


   static void loadFits(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   static void saveFits(char * filename, int dataTypeOut, CPixels *pixels, CFitsKeywords *keywords);
   static void saveFitsTable(char * outputFileName, CFitsKeywords *keywords, int nbRow, int nbCol, char *columnType, char **columnTitle, char **columnUnits, char **columnData );

   //static void loadBmp(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   //static void saveBmp(char * filename, unsigned char *dataIn, CFitsKeywords *keywords, int planes,int width, int height, int quality);

   static void loadJpeg(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   static void saveJpeg(char * filename, unsigned char *dataIn, CFitsKeywords *keywords, int planes,int width, int height, int quality);

   //static void loadGif(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   //static void saveGif(char * filename, unsigned char *dataIn, CFitsKeywords *keywords, int planes,int width, int height, int quality);

   //static void loadPng(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   //static void savePng(char * filename, unsigned char *dataIn, CFitsKeywords *keywords, int planes,int width, int height, int quality);

   static void loadRaw(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   //static void saveRaw(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords);
   static void cfa2Rgb(CPixels *cfaPixels, CFitsKeywords *cfaKeywords, int interpolationMethod, CPixels **rgbPixels, CFitsKeywords **rgbKeywords );

};

#endif


