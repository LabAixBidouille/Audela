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

#include "cfile.h"
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
 *  loadFile
 *  charge un fichier
 * 
 *  parameters : 
 *    arg1 (IN) : nom du fichier
 *  return :
 *    CFileFormat : file format 
 */
CFileFormat CFile::loadFile(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   CFileFormat fileFormat;

   // je verifie le nom du fichier
   fileFormat = getFormatFromHeader(filename);
   
   switch ( fileFormat ) {
   case CFILE_FITS :
      loadFits(filename, dataTypeOut, pixels, keywords);
      break;
      
   case CFILE_JPEG :
      loadJpeg(filename, dataTypeOut, pixels, keywords);
      break;
            
   //case CFILE_GIF :
   //   break;
      
   //case CFILE_PNG :
   //   break;
      
   case CFILE_RAW :
      loadRaw(filename, dataTypeOut, pixels, keywords);
      break;
      
   default : 
      // unknown format
      throw CError("loadFile %s error : unknown format.",filename );
   }
   
   return fileFormat;
}

/**
 *  saveFile
 *  enregistre dans un fichier
 * 
 *  parameters : 
 *    arg1 (IN) : nom du fichier
 *  return :
 *    CFileFormat : file format 
 */
CFileFormat CFile::saveFile(char * filename, int dataTypeOut, CPixels *pixels, CFitsKeywords *keywords)
{
   CFileFormat fileFormat = CFILE_UNKNOWN;

   
   return fileFormat;
}



void CFile::loadFits(char * filename, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   int msg;                         // Code erreur de libtt
   int naxis,naxis1,naxis2,naxis3;
   int nb_keys;
   TPixelFormat pixelFormat;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   float *ppix=NULL;
   int iaxis3 = 3;

   try {
      // je charge le 3ieme HDU. (iaxis=3)
      //   Libtt_main retourne naxis3=3 si le 3ieme HDU existe  => c'est une image RGB
      //   Libtt_main retourne naxis3=1 si le 3ieme HDU n'existe pas => c'est une image GRAY
      msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&dataTypeOut,&iaxis3,&ppix,&naxis1,&naxis2,&naxis3,
         &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) throw CErrorLibtt(msg);
      
      switch (dataTypeOut) {
         case TBYTE :
            pixelFormat = FORMAT_BYTE;
            break;
         case TUSHORT :
            pixelFormat = FORMAT_SHORT;
            break;
         case TSHORT  :
            pixelFormat = FORMAT_USHORT;
            break;
         case TFLOAT  :
            pixelFormat = FORMAT_FLOAT;
            break;
         default :
            throw CError("LoadFits error: format dataTypeOut=%d not supported.",dataTypeOut);
      }

      if (naxis3 == 1) {
         // je copie les donnees dans la variable de sortie
         *pixels = new CPixelsGray(naxis1, naxis2, pixelFormat, ppix, 0, 0);

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
         *pixels = new CPixelsRgb(naxis1, naxis2, pixelFormat, ppixR, ppixG, ppixB);
         
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

void CFile::saveFits(char * filename, int dataTypeOut, CPixels *pixels, CFitsKeywords *keywords)
{
   int msg;                         // Code erreur de libtt
   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   void *ppix;
   int nb_keys;
   int naxis1, naxis2;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int datatype;

   // petir raccoruci sur les dimensions 
   naxis1 = pixels->GetWidth();
   naxis2 = pixels->GetHeight();

   switch( pixels->getPixelClass() ) {
      case CLASS_RGB :
         ppix = malloc(naxis1*naxis2*pixels->GetPlanes() * sizeof(TYPE_PIXELS_RGB));
         pixelsR = (TYPE_PIXELS_RGB *) ppix;
         pixelsG = pixelsR + naxis1*naxis2; 
         pixelsB = pixelsR + naxis1*naxis2*2; 

         // je recupere l'image RGB a traiter en séparant les 3 plans
         // Yassine
         //pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_R, (int) pixelsR);
         //pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_G, (int) pixelsG);
         //pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_B, (int) pixelsB);
         pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_R, (long) pixelsR);
         pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_G, (long) pixelsG);
         pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_B, (long) pixelsB);
   
         // format des pixels en entree de libtt
         datatype = TSHORT;
         break;
      default : 
         // je recupere l'image GREY a traiter 
         ppix = malloc(naxis1* naxis2 * sizeof(float));
         // Yassine
         //pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);
         pixels->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (long) ppix);
         
         // format des pixels en entree de libtt
         datatype = TFLOAT;         
         break;
   }


   // Collecte de renseignements pour la suite
   nb_keys = keywords->GetKeywordNb();
   
   // Allocation de l'espace memoire pour les tableaux de mots-cles
   if (nb_keys>0) {
      msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         free(ppix);
         throw CErrorLibtt(msg);
      }
   }

   // Conversion keywords vers tableaux 'Made in Klotz'
   keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);

   // j'enregistrement l'image.
   msg = Libtt_main(TT_PTR_SAVEIMAKEYDIM,9,filename,ppix,&datatype,&nb_keys,keynames,values,comments,units,datatypes);
   if(msg) {
      free(ppix);
      throw CErrorLibtt(msg);
   }
   
   // Liberation de la memoire allouee par libtt
   if (nb_keys>0) {
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         free(ppix);
         throw CErrorLibtt(msg);
      }
   }
   free(ppix);
}

void CFile::saveFitsTable(char * outputFileName, CFitsKeywords *keywords, int nbRow, int nbCol, char *columnType, char **columnTitle, char **columnUnits, char **columnData )
{
   int msg;                         // Code erreur de libtt
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char binary[20];

   strcpy(binary,"ascii");
   nb_keys = keywords->GetKeywordNb();   
   // Allocation de l'espace memoire pour les tableaux de mots-cles
   if (nb_keys>0) {
      msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         throw CErrorLibtt(msg);
      }
   }
   // Conversion keywords vers tableaux 'Made in Klotz'
   keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);


/**************************************************************************/
/* Fonction d'interface pour sauver les tables (spectres...)              */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *dtype (char* : datatypes des champs)                           */
/*        short, int, float, double, un nombre de carateres               */
/*        Permet de connaitre aussi le nombre de champs (tfields)         */
/* arg3 : **tunit (char** : unite des champs)                             */
/* arg4 : **ttype (char** : intitule des champs)                          */
/*  A noter que **table, **tunit, **ttype ont ete dimensionnes par        */
/*  tt_ptr_allotbl.                                                       */
/* arg5 : "binary" ou "ascii" en fonction du format de sortie desire.     */
/* ------ entrees facultatives pour l'entete                              */
/* arg6 : *nbkeys (int*)                                                  */
/* arg7 : **keynames (char**)                                             */
/* arg8 : **values (char**)                                               */
/* arg9 : **comments (char**)                                             */
/* arg10 : **units (char**)                                               */
/* arg11 : *datatype (int*)                                               */
/* ------ entrees des donnees des colonnes                                */
/* arg12 *char (char*) chaine de la premiere colonne.                     */
/* arg13 *char (char*) chaine de la deuxieme colonne.                     */
/* ...                                                                    */
/**************************************************************************/

   // j'enregistrement la table
   if ( nbCol == 9 ) {
      msg = Libtt_main(TT_PTR_SAVETBL,20,outputFileName,
         columnType, columnUnits, columnTitle, binary, 
         &nb_keys,keynames,values,comments,units,datatypes,
         columnData[0],columnData[1],columnData[2],columnData[3],
         columnData[4],columnData[5],columnData[6],columnData[7],columnData[8]);
   }
   if ( nbCol == 13 ) {
      msg = Libtt_main(TT_PTR_SAVETBL,24,outputFileName,
         columnType, columnUnits, columnTitle, binary, 
         &nb_keys,keynames,values,comments,units,datatypes,
         columnData[0],columnData[1],columnData[2],columnData[3],
         columnData[4],columnData[5],columnData[6],columnData[7],columnData[8],
         columnData[9],columnData[10],columnData[11],columnData[12],columnData[13]);
   }
   if(msg) {
      throw CErrorLibtt(msg);
   }
   
   // Liberation de la memoire allouee par libtt
   if (nb_keys>0) {
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         throw CErrorLibtt(msg);
      }
   }
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
   
   // TODO : recuperer les donnees EXIF

   result  = libdcjpeg_loadFile(filename, &decodedData, &decodedSize, &naxis3, &width, &height);            
   if (result == 0 )  {

      // je copie les pixels dans la variable de sortie *pixels
      if ( naxis3 == 1 ) {
         *pixels = new CPixelsGray(width, height, FORMAT_BYTE, decodedData, 0, 0);
         naxis = 2;
      } else if ( naxis3 == 3 ) {
         *pixels = new CPixelsRgb(width, height, FORMAT_BYTE, decodedData, 0, 0);
         naxis = 3;
      } else { 
         throw new CError("loadJpeg : unsupported value naxis3=%d ", naxis3);
      }

      // je copie les mots cles dans la variable de sortie *keywords 
      *keywords = new CFitsKeywords();
      initialMipsLo = 0.0 ;
      initialMipsHi = 255.0;

      (*keywords)->Add("NAXIS", &naxis,TINT,"","");
      (*keywords)->Add("NAXIS1",&width,TINT,"","");
      (*keywords)->Add("NAXIS2",&height,TINT,"","");
      if ( naxis3 == 3) (*keywords)->Add("NAXIS3",&naxis3,TINT,"","");
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
   char  gmtDate[70];
   char  camera[70];
   char  filter[70];
      
   if( strlen(filename) == 0 ) {
      throw new CError("loadRaw : filename is empty");
   }
   
   result  = libdcraw_fileRaw2Cfa(filename, &dataInfo, &decodedData);            
   if (result == 0 )  {
      naxis = 2;
      width  = dataInfo.width;
      height = dataInfo.height;
      // je recupere le seuil bas et le seuil haut
      initialMipsLo = (float)dataInfo.black ;
      initialMipsHi = (float)dataInfo.maximum;
      // je recupere la date et je la convertis en temps GMT
      tmtime = gmtime( (const time_t *)&dataInfo.timestamp);
      strftime( gmtDate, 70, "%Y-%m-%dT%H:%M:%S", tmtime );
      // je recupere le nom de la camera
      sprintf(camera, "%s %s",dataInfo.make,dataInfo.model);  
      // je recupere le filtre 
      // la valeur du filtre est convertie en chaine de caracteres Hexadecimale
      // car les mots cles ne supportent pas les entiers non signés sur 4 octets
      sprintf(filter, "%u",dataInfo.filters); 
      
      // je copie les pixels dans la variable de sortie 
      *pixels = new CPixelsGray(dataInfo.width, dataInfo.height, FORMAT_USHORT, decodedData, 0, 0);
                  
      // je copie les mots cles dans la variable de sortie      
      *keywords = new CFitsKeywords();
      (*keywords)->Add("NAXIS", &naxis,TINT,"","");
      (*keywords)->Add("NAXIS1",&width,TINT,"","");
      (*keywords)->Add("NAXIS2",&height,TINT,"","");
      (*keywords)->Add("MIPS-LO",&initialMipsLo,        TFLOAT,  "Low cut","ADU");
      (*keywords)->Add("MIPS-HI",&initialMipsHi,        TFLOAT,  "Hight cut","ADU");
      (*keywords)->Add("DATE-OBS", &gmtDate,            TSTRING, "", "");
      (*keywords)->Add("EXPOSURE", &dataInfo.shutter,   TFLOAT,  "","s");
      (*keywords)->Add("CAMERA",   &camera,             TSTRING, "" , "");
      (*keywords)->Add("RAW_FILTER",  &filter,          TSTRING, "", "" );
      (*keywords)->Add("RAW_COLORS",  &dataInfo.colors,  TINT,    "raw colors", "" );
      (*keywords)->Add("RAW_BLACK",   &dataInfo.black,   TINT,    "raw low cut", "" );
      (*keywords)->Add("RAW_MAXIMUM", &dataInfo.maximum, TINT,   "raw hight cut", "" );

      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloué par cette meme librairie.
      libdcraw_freeBuffer(decodedData);
   } else {
      throw CError("libdcraw_fileRaw2Cfa error=%d", result);
   }      
}


void CFile::cfa2Rgb(CPixels *cfaPixels, CFitsKeywords *cfaKeywords, int interpolationMethod, CPixels **rgbPixels, CFitsKeywords **rgbKeywords )
{
   unsigned short * cfaData = NULL;
   unsigned short * rgbData = NULL;
   int   naxis, naxis3;
   int result = -1;
   TInterpolationMethod  method;
   struct libdcraw_DataInfo dataInfo;
   CFitsKeyword *kwd;

   // je verifie que la methode d'interpolation est connue
   switch ( interpolationMethod ) {
   case 1 : 
      method = LINEAR;
      break;
   case 2 :
      method = VNG;
      break;
   case 3 :
      method = ADH;
      break;
   default:
       // methode inconue
      throw CError("CFile::cfa2Rgb: interpolationMethod=%d unknown", interpolationMethod);
   }

   // je recupere les parametres indispensable a l'interpolation
   dataInfo.width =  cfaPixels->GetWidth();
   dataInfo.height = cfaPixels->GetHeight();
   if ( (kwd = cfaKeywords->FindKeyword("RAW_COLORS")) != NULL ) {      
      dataInfo.colors = kwd->GetIntValue();
   } else {
      throw CError("CFile::cfa2Rgb: not a RAW image, keyword RAW_COLORS not found");

   }
   if ( (kwd = cfaKeywords->FindKeyword("RAW_BLACK")) != NULL ) {      
      dataInfo.black = kwd->GetIntValue();
   } else {
      throw CError("CFile::cfa2Rgb: not a RAW image, keyword RAW_BLACK not found");
   }
   if ( (kwd = cfaKeywords->FindKeyword("RAW_MAXIMUM")) != NULL ) {      
      dataInfo.maximum = kwd->GetIntValue();
   } else {
      throw CError("CFile::cfa2Rgb: not a RAW image, keyword RAW_MAXIMUM not found");
   }
   if ( (kwd = cfaKeywords->FindKeyword("RAW_FILTER")) != NULL ) {      
      sscanf(kwd->GetStringValue(),"%u",&dataInfo.filters);
   } else {
      throw CError("CFile::cfa2Rgb: not a RAW image, keyword RAW_FILTER not found");
   }

   // je recupere les valeurs des pixels
   cfaData = (unsigned short*) malloc( cfaPixels->GetWidth() * cfaPixels->GetHeight() * sizeof (unsigned short) );
   if( cfaData == NULL ) {
      CError("CFile::cfa2Rgb: enougth memory");
   }
   // Yassine
   //cfaPixels->GetPixels(0, 0, cfaPixels->GetWidth() -1,  cfaPixels->GetHeight() -1, FORMAT_USHORT, PLANE_GREY, (int) cfaData );
   cfaPixels->GetPixels(0, 0, cfaPixels->GetWidth() -1,  cfaPixels->GetHeight() -1, FORMAT_USHORT, PLANE_GREY, (long) cfaData );

   // je convertis l'image CFA en RGB
   result = libdcraw_bufferCfa2Rgb(cfaData, &dataInfo, method, &rgbData);
   if (result == 0 )  {      
      // je copie les pixels dans la variable de sortie (en inversant les Y)
      *rgbPixels = new CPixelsRgb(dataInfo.width, dataInfo.height, FORMAT_USHORT, rgbData, 0, 1);
                  
      // je cree les mots cles en sortie     
      *rgbKeywords = new CFitsKeywords();
      // je copie les mots cles de l'image CFA
      kwd = cfaKeywords->GetFirstKeyword();
      while( kwd != NULL ) {
         (*rgbKeywords)->Add( kwd->GetName(), kwd->GetPtrValue(), kwd->GetDatatype(), 
            kwd->GetComment(), kwd->GetUnit());
         kwd = kwd->next;
      }
      // je modifie les mots cles NAXIS et NAXIS3
      naxis = 3;
      naxis3 = 3;

      (*rgbKeywords)->Add("NAXIS", &naxis,TINT,"","");
      (*rgbKeywords)->Add("NAXIS1", &dataInfo.width,TINT,"","");
      (*rgbKeywords)->Add("NAXIS2", &dataInfo.height,TINT,"","");
      (*rgbKeywords)->Add("NAXIS3",&naxis3,TINT,"","");

      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloué par cette meme librairie.
      libdcraw_freeBuffer(rgbData);
 
      if (cfaData != NULL) free(cfaData);
       
   } else {
      if (cfaData != NULL) free(cfaData);
      if (rgbData != NULL) libdcraw_freeBuffer(rgbData);
      throw CError("libdcraw_fileRaw2Cfa: error=%d", result);
   }      

 
}


/****************************************************************************
 * utilitaires
 ****************************************************************************/
 
 /**
 *  getFormatFromHeader
 *  identifie le format du fichier
 * 
 *  parameters : 
 *    arg1 (IN) : nom du fichier
 *  return :
 *    CFileFormat : file format 
 */
CFileFormat CFile::getFormatFromHeader(char * filename)
{
   int result;
   FILE *fichier_in ;
   char line[11],*filename0;
   CFileFormat fileFormat;
   struct libdcraw_DataInfo dataInfo;
   int n,k,kb=0;

   char FitsHeader[]  = "SIMPLE";
   char JpgHeader[]  = { (char) 0xFF, (char) 0xD8 };
   char GzipHeader[]  = { (char) 0x1F, (char) 0x8B, (char) 0x08 };
   

   // je verifie le nom du fichier
   if ( filename == NULL || strlen(filename) == 0 ) {
      throw CError("filename is NULL or empty");
   }

   // je retire l'extension [ ou ; pour le format etendu de FITSIO
   n=strlen(filename);
   kb=n;
   for (k=0;k<n;k++) {
      if ((filename[k]=='[')||(filename[k]==';')) {
         kb=k;
         break;
      }
   }
   filename0=(char*)malloc((kb+1)*sizeof(char));
   if (filename0==NULL) {
      throw CError("Filename0 for %s not allocated",filename);
   }
   strncpy(filename0,filename,kb);
   filename0[kb]='\0';

   // j'ouvre le fichier
   if ( (fichier_in=fopen(filename0, "rb")) == NULL) {
      free(filename0);
      throw CError("File %s not found",filename);
   }
   free(filename0);

   // je lis les 10 premiers  octets
   result = fread( line, 1, 10, fichier_in ); 
   if ( result != 10 ) {
      fclose(fichier_in);
      throw CError("File %s too small (less than 10 bytes)",filename);
   }
   fclose(fichier_in);

   // identify file format
   if ( strncmp(line, FitsHeader , 6 ) == 0 ) {
      fileFormat = CFILE_FITS;
   } else if ( strncmp(line, JpgHeader , 2 ) == 0 ) {
      fileFormat = CFILE_JPEG;
   } else if ( libdcraw_getInfoFromFile(filename, &dataInfo) == 0 ) {
      fileFormat = CFILE_RAW;
   } else if ( strncmp(line, GzipHeader , sizeof GzipHeader ) == 0) {
      // fichier fits comresse
      fileFormat = CFILE_FITS;
   } else {
      fileFormat = CFILE_UNKNOWN;
   }

   return fileFormat;
}



