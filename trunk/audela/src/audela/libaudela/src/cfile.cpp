/* cvisu.cpp
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

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>    // pour gmtime

#include "CFile.h"
#include "cerror.h"
#include "cpixelsgray.h"
#include "cpixelsrgb.h"
#include "libtt.h"         // fichiers FITS
#include "libdcjpeg.h"     // fichiers JPEG
#include "libdcraw.h"      // fichiers RAW

CFile::CFile()
{
}


CFile::~CFile()
{
}


/**
 *  getFormat
 *  identifie le format du fichier
 * 
 *  parameters : 
 *    arg1 (IN) : nom du fichier
 *  return :
 *    TDcFileFormat : file format 
 */
TDcFileFormat CFile::getFormat(char * filename)
{
   int result;
   FILE *fichier_in ;
   char line[11];
   TDcFileFormat fileFormat;
   struct libdcraw_DataInfo dataInfo;

   char FitsHeader[]  = "SIMPLE";
   char JpgHeader[]  = { (char) 0xFF, (char) 0xD8 };


   // je verifie le nom du fichier
   if ( filename == NULL || strlen(filename) == 0 ) {
      throw CError("filename is NULL or empty");
   }

   // j'ouvre le fichier
   if ( (fichier_in=fopen(filename, "rb")) == NULL) {
      throw CError("File %s not found",filename);
   }

   // je lis les 10 premiers  octets
   result = fread( line, 1, 10, fichier_in ); 
   if ( result != 10 ) {
      fclose(fichier_in);
      throw CError("File %s too small (less than 10 bytes)",filename);
   }
   fclose(fichier_in);

   // identify file format
   if ( strncmp(line, FitsHeader , 6 ) == 0 ) {
      fileFormat = DCFILE_FITS;
   } else if ( strncmp(line, JpgHeader , 2 ) == 0 ) {
      fileFormat = DCFILE_JPEG;
   } else if ( libdcraw_getInfoFromFile(filename, &dataInfo) == 0 ) {
      fileFormat = DCFILE_RAW;
   } else {
      fileFormat = DCFILE_UNKNOWN;
   }

   return fileFormat;
}


/**
 *  getFormat
 *  identifie le format du fichier
 * 
 *  parameters : 
 *    arg1 (IN) : nom du fichier
 *  return :
 *    TDcFileFormat : file format 
 */
TDcFileFormat CFile::loadFile(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   TDcFileFormat fileFormat;

   // je verifie le nom du fichier
   fileFormat = getFormat(filename);
   
   switch ( fileFormat ) {
   case DCFILE_FITS :
      loadFits(filename, dataTypeOut, pixels, keywords);
      break;
      
   case DCFILE_JPEG :
      loadJpeg(filename, dataTypeOut, pixels, keywords);
      break;
            
   //case DCFILE_GIF :
   //   break;
      
   //case DCFILE_PNG :
   //   break;
      
   case DCFILE_RAW :
      loadRaw(filename, dataTypeOut, pixels, keywords);
      break;
      
   default : 
      // unknown format
      throw CError("loadFile %s error : unknown format.",filename );
   }
   
   return fileFormat;
}


void CFile::loadFits(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   int msg;                         // Code erreur de libtt
   int naxis,naxis1,naxis2,naxis3;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   float *ppix=NULL;
   int iaxis3 = 3;

   try {
      // je charge le 3ieme HDU. (iaxis=3)
      //   si le 3ieme HDU existe , Libtt_main retourne naxis3=3  => c'est une image RGB
      //   si le 3ieme HDU n'existe pas , Libtt_main retourne naxis3=1 => c'est une image GRAY
      msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&dataTypeOut,&iaxis3,&ppix,&naxis1,&naxis2,&naxis3,
         &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) throw CErrorLibtt(msg);
      

      if (naxis3 == 1) {
         // je copie les donnees dans la variable de sortie
         *pixels = new CPixelsGray(naxis1, naxis2, FORMAT_FLOAT, ppix, 0, 0);

         // je copie les mots cles dans la variable de sortie      
         *keywords = new CFitsKeywords();
         (*keywords)->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);

      } else if ( naxis3 == 3 ) {
         // s'il y a 3 plans , je charge les deux autres plans
         TYPE_PIXELS * ppixR = NULL;
         TYPE_PIXELS * ppixG = NULL ;
         TYPE_PIXELS * ppixB = ppix ;  // j'ai deja recupere le troisieme plan
         
         iaxis3 = 1;
         msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&dataTypeOut,&iaxis3,&ppixR,&naxis1,&naxis2,&naxis3,
   	      &nb_keys,&keynames,&values,&comments,&units,&datatypes);
            iaxis3 = 2;
            msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&dataTypeOut,&iaxis3,&ppixG,&naxis1,&naxis2,&naxis3,
   	         &nb_keys,&keynames,&values,&comments,&units,&datatypes);
         
         // je copie les pixels dans la variable de sortie
         *pixels = new CPixelsRgb(naxis1, naxis2, FORMAT_FLOAT, ppixR, ppixG, ppixB);
         
         // je copie les mots cles dans la variable de sortie      
         *keywords = new CFitsKeywords();
         (*keywords)->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
         // je recupere les mots cles
         (*keywords)->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
         naxis = 3;
         (*keywords)->Add("NAXIS", &naxis,TINT,"","");
         naxis3 = 3;
         (*keywords)->Add("NAXIS3",&naxis3,TINT,"","");
         
      } else {
         throw CError("LoadFits error: plane number is not 1 or 3.");
      }
   } catch (const CError& e) {
      // Liberation de la memoire allouée par libtt
      Libtt_main(TT_PTR_FREEPTR,1,&ppix);
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      // je transmet l'erreur
      throw e;
   }
   
   // Liberation de la memoire allouee par libtt (pas nécessire de catcher les erreurs)
   msg = Libtt_main(TT_PTR_FREEPTR,1,&ppix);
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
}


void CFile::loadJpeg(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   unsigned char * decodedData;
   long   decodedSize;
   int   naxis, width, height, naxis3;
   float initialMipsLo, initialMipsHi;
   int result = -1;
      
   if( strlen(filename) == 0 ) {
      throw new CError("loadJpeg : filename is empty");
   }
   
   result  = libdcjpeg_loadFile(filename, &decodedData, &decodedSize, &naxis3, &width, &height);            
   if (result == 0 )  {

      if ( naxis3 == 1 ) {
         *pixels = new CPixelsGray(width, height, FORMAT_BYTE, decodedData, 0, 0);
         naxis = 1;
      } else if ( naxis3 == 3 ) {
         *pixels = new CPixelsRgb(PLANE_RGB, width, height, FORMAT_BYTE, decodedData, 0, 0);
         naxis = 3;
      } else { 
         throw new CError("loadJpeg : unsupported value naxis3=%d ", naxis3);
      }
      // je copie les mots cles dans la variable de sortie      
      *keywords = new CFitsKeywords();
      initialMipsLo = 0.0 ;
      initialMipsHi = 255.0;

      (*keywords)->Add("NAXIS", &naxis,TINT,"","");
      (*keywords)->Add("NAXIS1",&width,TINT,"","");
      (*keywords)->Add("NAXIS2",&height,TINT,"","");
      if ( naxis3 == 13) (*keywords)->Add("NAXIS3",&naxis3,TINT,"","");
      (*keywords)->Add("MIPS-LO",&initialMipsLo,TFLOAT,"Low cut","ADU");
      (*keywords)->Add("MIPS-HI",&initialMipsHi,TFLOAT,"Hight cut","ADU");

      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloué par cette meme librairie.
      libdcjpeg_freeBuffer(decodedData);
   } else {
      throw CError("libjpeg_decodeBuffer error=%d", result);
   }
}

void CFile::saveJpeg(char * filename, unsigned char *dataIn, CFitsKeywords *keywords, int planes,  int width, int height, int quality)
{
   
   // TODO : copier les motclé dans les donnees EXIF

   libdcjpeg_saveFile(filename, dataIn, planes, width, height, quality);

}


void CFile::loadRaw(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{

   unsigned short * decodedData;
   int   naxis, width, height;
   float initialMipsLo, initialMipsHi;
   int result = -1;
   struct libdcraw_DataInfo dataInfo;
   struct tm *tmtime;
   char  gmtDate[256];
   char  camera[256];

      
   if( strlen(filename) == 0 ) {
      throw new CError("loadRaw : filename is empty");
   }
   
   result  = libdcraw_fileRaw2Cfa(filename, &dataInfo, &decodedData);            
   if (result == 0 )  {
      naxis = 2;
      width  = dataInfo.width;
      height = dataInfo.height;
      initialMipsLo = (float)dataInfo.black ;
      initialMipsHi = (float)dataInfo.maximum;
      // je recupere la date en temps GMT
      tmtime = gmtime( &dataInfo.timestamp);
      strftime( gmtDate, 256, "%d/%m/%Y %H:%M:%S", tmtime );
      // je recupere le nom de la camera
      sprintf(camera, "%s %s",dataInfo.make,dataInfo.model);      
      
      // je copie les pixels dans la variable de sortie 
      *pixels = new CPixelsGray(dataInfo.width, dataInfo.height, FORMAT_USHORT, decodedData, 0, 0);
                  
      // je copie les mots cles dans la variable de sortie      
      *keywords = new CFitsKeywords();
      (*keywords)->Add("NAXIS", &naxis,TINT,"","");
      (*keywords)->Add("NAXIS1",&width,TINT,"","");
      (*keywords)->Add("NAXIS2",&height,TINT,"","");
      (*keywords)->Add("MIPS-LO",&initialMipsLo,TFLOAT,"Low cut","ADU");
      (*keywords)->Add("MIPS-HI",&initialMipsHi,TFLOAT,"Hight cut","ADU");
      (*keywords)->Add("DATE-OBS", gmtDate, "string", "", "UT");
      (*keywords)->Add("EXPOSURE",&dataInfo.shutter,TFLOAT,"","s");
      (*keywords)->Add("CAMERA", camera, "string", "" , "");
      
      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloué par cette meme librairie.
      libdcraw_freeBuffer(decodedData);
   } else {
      throw CError("libdcraw_fileRaw2Cfa error=%d", result);
   }      

  
}
