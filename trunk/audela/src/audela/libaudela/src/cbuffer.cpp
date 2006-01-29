/* cbuffer.cpp
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

#include <math.h>

#include <iostream.h>
#include <fstream.h>

#include "cbuffer.h"
#include "cpixelsgray.h"
#include "cpixelsrgb.h"

#include "libdcjpeg.h"          // decode jpeg  pictures
#include "libdcraw.h"         // decode raw  pictures

/**
 *  constructeur par defaut
 *
 */

CBuffer::CBuffer() : CDevice()
{
   SetSavingType(USHORT_IMG);
   keywords = NULL;
   pix = NULL;
   p_ast = NULL;
   compress_type = BUFCOMPRESS_NONE;
   fitsextension = new char[CHAREXTENSION];

   strcpy(fitsextension,".fit");

   // On fait de la place avant de recreer le contenu du buffer
   FreeBuffer(DONT_KEEP_KEYWORDS);

   // je cree un tableau de pixels par defaut
   SetPixels(PLANE_GREY,0,0,FORMAT_FLOAT,COMPRESS_NONE, NULL, 0, 0, 0);

   initialMipsLo = 0;
   initialMipsHi = 0;

}


CBuffer::~CBuffer()
{
   if (fitsextension != NULL) {
      delete fitsextension;
   }
   FreeBuffer(DONT_KEEP_KEYWORDS);
}


void CBuffer::SetSavingType(int st)
{
   switch(st) {
      case BYTE_IMG:
      case SHORT_IMG:
      case USHORT_IMG:
      case LONG_IMG:
      case ULONG_IMG:
      case FLOAT_IMG:
      case DOUBLE_IMG:
         saving_type = st;
         break;
      default:
         saving_type = SHORT_IMG;
   }

}

void CBuffer::SetCompressType(int st)
{
   switch(st) {
      case BUFCOMPRESS_NONE:
      case BUFCOMPRESS_GZIP:
         compress_type = st;
         break;
      default:
         compress_type = BUFCOMPRESS_NONE;
   }
}

void CBuffer::SetExtension(char *ext)
{
   char ext0[CHAREXTENSION];
   if (ext==NULL) {
      strcpy(ext0,"");
   }
   strcpy(fitsextension,"");
   strcpy(ext0,ext);
   if ((strcmp(ext0,"*")==0)||(strcmp(ext0,"")==0)) {
      // cas ou l'on ne veut pas d'extension
      return;
   }
   if (ext0[0]=='?') {
      strcat(fitsextension,".fit");
      return;
   }
   if (ext0[0]!='.') {
      strcat(fitsextension,".");
   }
   strcat(fitsextension,ext0);
}

int CBuffer::GetSavingType()
{
   return saving_type;
}

char *CBuffer::GetExtension()
{
   static char ext[CHAREXTENSION];
   strcpy(ext,fitsextension);
   return ext;
}

int CBuffer::GetCompressType()
{
   return compress_type;
}


/**
 *----------------------------------------------------------------------
 * IsPixelsReady
 *    informe si une image est presente dans le buffer
 *
 * Parameters: 
 *    none
 * Results:
 *    returns 1 if pixels are ready, otherwise 0.
 * Side effects:
 *    appelle pix->IsPixelsReady()
 *----------------------------------------------------------------------
 */
int CBuffer::IsPixelsReady(void) {
   return pix->IsPixelsReady();
}


void CBuffer::FreeBuffer(int keep_keywords)
{
	if (keep_keywords == DONT_KEEP_KEYWORDS) {
		if(keywords) {
			delete keywords;
		}
      // je cree un objet CFitsKeywords vide
   	keywords = new CFitsKeywords();
		if(p_ast) {
			free(p_ast);
	   }
      // je cree un objet mc_ASTROM vide
   	p_ast = (mc_ASTROM*)calloc(1,sizeof(mc_ASTROM));
	}

   // je cree un tableau de dimension nulle
   SetPixels(PLANE_GREY,0,0,FORMAT_FLOAT,COMPRESS_NONE,  NULL, 0, 0, 0);
}


void CBuffer::GetDataType(TDataType *dt)
{
   *dt = dt_Float;
}

/**
 *  lecture d'un fichier au format FIT
 *
 */
void CBuffer::LoadFits(char *filename)
{
   int msg;                         // Code erreur de libtt
   int datatype;                    // Type du pointeur de l'image
   int naxis1,naxis2,naxis3;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   CFitsKeyword *k;
   TYPE_PIXELS *ppix=NULL;

   
   // Chargement proprement dit de l'image.FITS
   //datatype = TFLOAT;
   //msg = Libtt_main(TT_PTR_LOADIMA,11,filename,&datatype,&ppix,&naxis1,&naxis2,
   //&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   //if(msg) throw CErrorLibtt(msg);
   //  memorisation des pixels
   //SetPixels(PLANE_GREY, naxis1, naxis2, FORMAT_FLOAT, COMPRESS_NONE, (int) ppix, 0, DONT_KEEP_KEYWORDS);

   try {
      int iaxis3 = 3;

      FreeBuffer(DONT_KEEP_KEYWORDS);

      // Chargement proprement dit de l'image.
      datatype = TFLOAT;
      msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&datatype,&iaxis3,&ppix,&naxis1,&naxis2,&naxis3,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) throw CErrorLibtt(msg);

      if(naxis3 == 1) {
         SetPixels(PLANE_GREY, naxis1, naxis2, FORMAT_FLOAT, COMPRESS_NONE, ppix, 0, 0, 0);
         // je recupere les mots cles
         keywords->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
      } else if ( naxis3 == 3 ) {
         // s'il y a 3 plans , je charge les deux autres plans
         TYPE_PIXELS * ppixR = NULL;
         TYPE_PIXELS * ppixG = NULL ;
         TYPE_PIXELS * ppixB = ppix ;  // j'ai deja recupere le troisieme plan
         
         iaxis3 = 1;
         msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&datatype,&iaxis3,&ppixR,&naxis1,&naxis2,&naxis3,
   	      &nb_keys,&keynames,&values,&comments,&units,&datatypes);
         iaxis3 = 2;
         msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&datatype,&iaxis3,&ppixG,&naxis1,&naxis2,&naxis3,
   	      &nb_keys,&keynames,&values,&comments,&units,&datatypes);
         // je cree le tableau de pixels
         pix = new CPixelsRgb(naxis1, naxis2, FORMAT_FLOAT, ppixR, ppixG, ppixB);
         // je recupere les mots cles
         keywords->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
         naxis3 = 3;
         keywords->Add("NAXIS", &naxis3,TINT,"","");
         naxis3 = 3;
         keywords->Add("NAXIS3",&naxis3,TINT,"","");

      } else {
         throw CError("LoadFits error: plane number is not 1 or 3");
      }

      
      // On reinitialise les parametres astrometriques
      p_ast->valid = 0;
      saving_type = keywords->FindKeyword("BITPIX")->GetIntValue();
      if(saving_type==16) {
         k = keywords->FindKeyword("BZERO");
         if((k)&&(k->GetIntValue()==32768)) {
            saving_type = USHORT_IMG;
         }
      } else if(saving_type==32) {
         k = keywords->FindKeyword("BZERO");
         if((k)&&(k->GetIntValue()==-(2^31))) {
            saving_type = ULONG_IMG;
         }
      }
      
      // je sauvegarde les seuils initiaux et je convertis les seuils en float
      k = keywords->FindKeyword("MIPS-HI");      
      if(k != NULL  ) {
         if( k->GetDatatype() == TINT ) {
            // je convertis le seuil en float
            initialMipsHi = (float) k->GetIntValue();
            keywords->Add("MIPS-HI",(char *) &initialMipsHi,TFLOAT,"Hight cut","ADU");
         } else {
            initialMipsHi = (float) k->GetFloatValue();
         }         
      }
      
      k = keywords->FindKeyword("MIPS-LO");
      if(k) {
          // je convertis le seuil en float
         initialMipsLo = k->GetFloatValue();
         keywords->Add("MIPS-LO",&initialMipsLo,TFLOAT,"Low cut","ADU");
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

/**
 *  lecture d'un fichier qui n'est pas au format FIT
 * 
 *   @param pixelSize : taille du pixel en octet ( 1 octet = 256 couleurs, 3 octets = RGB)  
 *   @param pitch  :
 *
 */
void CBuffer::LoadNoFits(int pixelSize, int offset[4], int pitch , int width, int height, unsigned char *pixelPtr)
{
   TYPE_PIXELS *ppix1=NULL;
   double level;
   int x, y;
   int base;
   CFitsKeyword *k;
   int naxis;
   
   
   try {
      FreeBuffer(DONT_KEEP_KEYWORDS);

      if( pixelSize == 1 || (offset[0] == offset[1] && offset[0] == offset[1] && offset[0] == offset[2] ) ) {
         // s'il n'y a qu'un seul plan
         // ou si les trois plans sont les mêmes, je cree un tableau GRAY
         ppix1 = (TYPE_PIXELS*)malloc(width*height * sizeof(TYPE_PIXELS));
         if(ppix1==NULL) {
            throw CError(ELIBSTD_BUF_EMPTY);
         }
         
         // copie d'un seul plan
         for(x=0;x<width;x++) {
            for(y=0;y<height;y++) {
               base=pixelSize*((height-y-1)*width+x);
               level=0.;
               ppix1[y*width+x]=(TYPE_PIXELS)(1.*(pixelPtr[base]));
            }
         }
         
         
         SetPixels(PLANE_GREY, width, height, FORMAT_FLOAT, COMPRESS_NONE, ppix1, 0, 0, 1);
         free(ppix1);
         
         naxis = 2;
         keywords->Add("NAXIS", &naxis,TINT,"","");
         keywords->Add("NAXIS1",&width,TINT,"","");
         keywords->Add("NAXIS2",&height,TINT,"","");
      
      } else {
         int naxis3 = 3;

         // si les plans de couleur sont différents , je cree un tableau RGB
         FreeBuffer(DONT_KEEP_KEYWORDS);
         SetPixels(width, height, pixelSize, offset, pitch, (unsigned char *) pixelPtr);
         naxis = 3;
         keywords->Add("NAXIS", &naxis,TINT,"","");
         keywords->Add("NAXIS1",&width,TINT,"","");
         keywords->Add("NAXIS2",&height,TINT,"","");
         keywords->Add("NAXIS3",&naxis3,TINT,"","");
      }

      // je sauvegarde les seuils initiaux 
      if(keywords) {
         k = keywords->FindKeyword("MIPS-LO");
         if(k) {
            initialMipsLo = k->GetFloatValue();
         }
         k = keywords->FindKeyword("MIPS-HI");
         if(k) {
            initialMipsHi = k->GetFloatValue();
         }
      }
      
      // On reinitialise les parametres astrometriques
      p_ast->valid = 0;
      
      
   } catch (const CError& e) {
      // je libère la mémoire avant de tranmettre l'exception.
      free(ppix1);
      throw e;
   }
   
}

/**
 *  LoadRawFile
 *  lecture d'un fichier contenant une image en mode raw
 * 
 *   @param filename : input file name
 *
 */
void CBuffer::LoadRawFile(char * filename)
{
   int result;

   CFitsKeyword *k;
   int width, height, planes, naxis;
   char * pixels;


   FreeBuffer(DONT_KEEP_KEYWORDS);
   result = libdcraw_decodeFile (filename, &width, &height, &pixels);
   if( result == 0 ) {
      SetPixels(PLANE_RGB, width, height, FORMAT_SHORT, COMPRESS_NONE, pixels, 0, 0, 1);
      libdcraw_freeBuffer(pixels);
   } else {
      throw CError("LoadRawFile: libjpeg_decodeBuffer error=%d", result);
   }
   
   naxis = 3;
   planes = 3;
   keywords->Add("NAXIS", &naxis,TINT,"","");
   keywords->Add("NAXIS1",&width,TINT,"","");
   keywords->Add("NAXIS2",&height,TINT,"","");
   keywords->Add("NAXIS3",&planes,TINT,"","");

   // je sauvegarde les seuils initiaux 
   if(keywords) {
      k = keywords->FindKeyword("MIPS-LO");
      if(k) {
         initialMipsLo = k->GetFloatValue();
      }
      k = keywords->FindKeyword("MIPS-HI");
      if(k) {
         initialMipsHi = k->GetFloatValue();
      }
   }

   // On reinitialise les parametres astrometriques
   p_ast->valid = 0;
}



/**
 *  lecture d'un fichier qui n'est pas au format FIT
 * 
 *   @param filename : nom du fichier
 *   @param i
 *
 */
void CBuffer::Load3d(char *filename,int iaxis3)
{
   int msg;                         // Code erreur de libtt
   int datatype;                    // Type du pointeur de l'image
   int naxis1,naxis2,naxis3;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   CFitsKeyword *k;
   TYPE_PIXELS *ppix=NULL;

   FreeBuffer(DONT_KEEP_KEYWORDS);

   // Chargement proprement dit de l'image.
   datatype = TFLOAT;
   msg = Libtt_main(TT_PTR_LOADIMA3D,13,filename,&datatype,&iaxis3,&ppix,&naxis1,&naxis2,&naxis3,
   	&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);

   // Recopie de pixels dans le buffer
   try {
      SetPixels(PLANE_RGB, naxis1, naxis2, FORMAT_FLOAT, COMPRESS_NONE, ppix, 0, 0, 0);
   } catch (const CError& e) {
      // Liberation de la memoire allouée par libtt
      Libtt_main(TT_PTR_FREEPTR,1,&ppix);
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      // je transmet l'erreur
      throw e;
   }
   // On recupere les mots cles
   keywords->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);

   // On reinitialise les parametres astrometriques
   p_ast->valid = 0;
   saving_type = keywords->FindKeyword("BITPIX")->GetIntValue();
   if(saving_type==16) {
      k = keywords->FindKeyword("BZERO");
      if((k)&&(k->GetIntValue()==32768)) {
         saving_type = USHORT_IMG;
      }
   } else if(saving_type==32) {
      k = keywords->FindKeyword("BZERO");
      if((k)&&(k->GetIntValue()==-(2^31))) {
         saving_type = ULONG_IMG;
      }
   }

   // Liberation de la memoire allouee par libtt
   msg = Libtt_main(TT_PTR_FREEPTR,1,&ppix);
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
}

/**
 *----------------------------------------------------------------------
 * SaveFits
 *    sauvegarde le buffer dans fichier au format fits
 *
 * Parameters: 
 *    filename : nom du ficher de sortie
 * Results:
 *    none
 * Side effects:
 *    enregistre l'image (niveaux de gris), et les mots cles
 *    avec la fonction SAVEIMA de libtt
 *----------------------------------------------------------------------
 */
void CBuffer::SaveFits(char *filename)
{
   int msg;                         // Code erreur de libtt
   int datatype;                    // Type du pointeur de l'image
   int bitpix;
   int naxis1,naxis2;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   TYPE_PIXELS *ppix = NULL;
   CFitsKeyword *k = NULL;
   float fHi, fLo;
   int iHi, iLo;
 
   datatype=TFLOAT;
   bitpix = saving_type;

   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   ppix = (TYPE_PIXELS *) malloc(naxis1* naxis2 * sizeof(float));

   switch( pix->getPixelClass() ) {
      case CLASS_RGB :  
         SaveFitsRGB(filename);
         return;
      default :
         pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);
         break;
   }

   
   // Collecte de renseignements pour la suite
   nb_keys = keywords->GetKeywordNb();
   
   // Allocation de l'espace memoire pour les tableaux de mots-cles
   msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);   

   // Je transforme les seuils en entier si saving_type vaut byte, short ou ushort
   // Si les mots-cles n'existent pas, alors on ne fait rien. Merci Jacques !
   if( saving_type == BYTE_IMG || saving_type == SHORT_IMG || saving_type == USHORT_IMG ) {
      k = keywords->FindKeyword("MIPS-HI");
      if (k != NULL) {
         fHi = k->GetFloatValue();
         iHi = (int) fHi;
         keywords->Add("MIPS-HI",(void*)&iHi,TINT,"High cut","ADU");
      }
      k = keywords->FindKeyword("MIPS-LO");
      if (k != NULL) {
         fLo = k->GetFloatValue();
         iLo = (int) fLo;
         keywords->Add("MIPS-LO",(void*)&iLo,TINT,"Low cut","ADU");
      }
   }
   
   // Conversion keywords vers tableaux 'Made in Klotz'
   keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);
   
   // je restaure les valeur réelles des seuils 
   if( saving_type == BYTE_IMG || saving_type == SHORT_IMG || saving_type == USHORT_IMG ) {
      k = keywords->FindKeyword("MIPS-HI");
      if (k!=NULL) {
         keywords->Add("MIPS-HI",(void*)&fHi,TFLOAT,"High cut","ADU");
      }
      k = keywords->FindKeyword("MIPS-LO");
      if (k!=NULL) {
         keywords->Add("MIPS-LO",(void*)&fLo,TFLOAT,"Low cut","ADU");
      }
   }

   // Enregistrement proprement dit de l'image.
   msg = Libtt_main(TT_PTR_SAVEIMA,12,filename,ppix,&datatype,&naxis1,&naxis2,
      &bitpix,&nb_keys,keynames,values,comments,units,datatypes);
   if(msg) throw CErrorLibtt(msg);
   
   // Liberation de la memoire allouee par libtt
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

   free(ppix);
}

/**
 *----------------------------------------------------------------------
 * SaveNoFits
 *    sauvegarde le buffer dans fichier au format jpg, tiff, gif, ...
 *
 * Parameters: 
 *    *pixelSize  : taille du pixel (en octets) 1 2 ou 3
 *    *offset     : décalge entre les valeurs de chaque couleur d'un pixel dans lae tableau
 *    *width      : largeur de l'image (en pixels)
 *    *height     : hauteur de l'image (en pixels)
 *    **pixelPtr  : pointeur du tableau de pixels en sortie
 * Results:
 *    none
 * Side effects:
 *    copie les pixels dans le tableau de pixels de sortie . le tableau de sortie doit 
 *    avoir été préalablement réservé par la fonction appelante. 
 *    Les pixels sont enregistrés dans le fichier par la fonction appelante (fonction TCL)
 *    
 *----------------------------------------------------------------------
 */
void CBuffer::SaveNoFits(int *pixelSize, int *offset, int *pitch , int *width, int *height, unsigned char **pixelPtr)
{
   int ww, hh;
   unsigned char *ptr;
   
   ww  = GetW();
   hh  = GetH();
   
   switch( pix->getPixelClass() ) {
   case CLASS_GRAY : 
      {
         // j'optimise la taille : je n'enregistre qu'un plan
         // si c'est une image en niveau de gris.
         ptr = (unsigned char *)malloc(ww*hh * 2);  // deux octets pas pixel
         if(ptr==NULL) throw CError( ELIBSTD_NO_MEMORY_FOR_PIXELS);
         //  je recupere les pixels ( zoom =1, palette normale,   ) 
         pix->GetPixelsReverse(0,0,ww-1,hh-1, FORMAT_SHORT, PLANE_GREY, (int) ptr);                        
         // je prepare les parametres de sortie
         *pixelPtr  = ptr;
         *width      = ww;
         *height     = hh;
         *pitch      = ww*2;
         *pixelSize  = 2;
         *(offset+0) = 0;
         *(offset+1) = 0;
         *(offset+2) = 0;
         *(offset+3) = 0;                        
      }
      break;
   case CLASS_RGB :  
      {  
         ptr = (unsigned char*)malloc(ww*hh * 3);
         if(pixelPtr==NULL) throw CError( ELIBSTD_NO_MEMORY_FOR_PIXELS);                                          
         //  je recupere les pixels ( zoom =1, palette normale  ) 
         pix->GetPixelsReverse(0,0,ww-1,hh-1, FORMAT_BYTE, PLANE_RGB, (int) ptr);                     
         // je prepare parametres de sortie
         *pixelPtr  = ptr;
         *width      = ww;
         *height     = hh;
         *pitch      = ww*3;
         *pixelSize  = 3;
         *(offset+0)  = 0;
         *(offset+1)  = 1;
         *(offset+2)  = 2;
         *(offset+3)  = 0;                        
      }
      break;
   default:
      break;
   }
}



void CBuffer::Save3d(char *filename,int naxis3,int iaxis3_beg,int iaxis3_end)
{
   int msg;                         // Code erreur de libtt
   int datatype;                    // Type du pointeur de l'image
   int bitpix;
   int naxis1,naxis2,nnaxis2;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   TYPE_PIXELS *ppix=NULL;
   TYPE_PIXELS *ppix1=NULL;
   int dummy;

   datatype=TFLOAT;
   bitpix = saving_type;

   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   ppix1 = (TYPE_PIXELS *) malloc(naxis1* naxis2 * naxis3 * sizeof(float));
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_RGB, (int) ppix1);

   // Collecte de renseignements pour la suite
   nb_keys = keywords->GetKeywordNb();

   // Allocation de l'espace memoire pour les tableaux de mots-cles
   msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);

   // Conversion keywords vers tableaux 'Made in Klotz'
   keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);

   // Enregistrement proprement dit de l'image.
   //nnaxis2=(int)floor(1.*naxis2/naxis3);
   nnaxis2= naxis2;

   if ((naxis3<=0)||(nnaxis2<1)) {
      msg = Libtt_main(TT_PTR_SAVEIMA,12,filename,ppix1,&datatype,&naxis1,&naxis2,
         &bitpix,&nb_keys,keynames,values,comments,units,datatypes);
      if(msg) throw CErrorLibtt(msg);
   } else {
      ppix=(TYPE_PIXELS*)(ppix1+(iaxis3_beg-1)*naxis1*nnaxis2);
      if (iaxis3_end<iaxis3_beg) { dummy=iaxis3_beg; iaxis3_beg=iaxis3_end; iaxis3_end=iaxis3_beg;}
      if (iaxis3_beg<1) { iaxis3_beg=1; }
      if (iaxis3_end>naxis3) { iaxis3_end=naxis3; }
      naxis3=iaxis3_end-iaxis3_beg+1;
      msg = Libtt_main(TT_PTR_SAVEIMA3D,13,filename,ppix1,&datatype,&naxis1,&nnaxis2,&naxis3,
         &bitpix,&nb_keys,keynames,values,comments,units,datatypes);
   }
   if(msg) {
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      throw CErrorLibtt(msg);
   }

   // Liberation de la memoire allouee par libtt
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

   free(ppix1);

}


void CBuffer::SaveFitsRGB(char *filename)
{
   int msg;                         // Code erreur de libtt
   int datatype;                    // Type du pointeur de l'image
   int bitpix;
   int naxis1,naxis2,naxis3;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   TYPE_PIXELS_RGB *pixels, *pixelsR, *pixelsG, *pixelsB;
   
   
   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   naxis3 = 3;

   pixels = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2*naxis3 * sizeof(TYPE_PIXELS_RGB));
      pixelsR = pixels;
      pixelsG = pixels + naxis1*naxis2; 
      pixelsB = pixels + naxis1*naxis2*2; 
      
      // je recupere l'image a traiter en séparant les 3 plans
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_R, (int) pixelsR);
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_G, (int) pixelsG);
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_B, (int) pixelsB);
   
   // format des pixels en entree de libtt
   datatype = TSHORT;
   // format des pixels dans le fichier de sortie de libtt
   bitpix = saving_type;

   // Collecte de renseignements pour la suite
   nb_keys = keywords->GetKeywordNb();

   // Allocation de l'espace memoire pour les tableaux de mots-cles
   msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);

   // Conversion keywords vers tableaux 'Made in Klotz'
   keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);

   msg = Libtt_main(TT_PTR_SAVEIMA3D,13,filename,pixels,&datatype,&naxis1,&naxis2,&naxis3,
         &bitpix,&nb_keys,keynames,values,comments,units,datatypes);
   if(msg) {
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      throw CErrorLibtt(msg);
   }

   // Liberation de la memoire allouee par libtt
   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

   free(pixels);

}

void CBuffer::SaveJpg(char *filename,int quality,int sbsh, double sb,double sh)
{
   int msg;                         // Code erreur de libtt
   int datatype;                    // Type du pointeur de l'image
   int naxis1,naxis2;
   CFitsKeyword *k;
   TYPE_PIXELS *ppix=NULL;

   datatype=TFLOAT;

   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   ppix = (TYPE_PIXELS *) malloc(naxis1* naxis2 * sizeof(float));
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);

   // Collecte de renseignements pour la suite
   if (sbsh==0) {
      if(keywords) {
         k = keywords->FindKeyword("MIPS-LO");
         if(k) {
            sb = k->GetFloatValue();
         } else {
            sb=0.0;
         }
         k = keywords->FindKeyword("MIPS-HI");
         if(k) {
            sh = k->GetFloatValue();
         } else {
            sh=32767.0;
         }
      }
   }

   // Enregistrement proprement dit de l'image au format Jpeg
   msg = Libtt_main(TT_PTR_SAVEJPG,8,filename,ppix,&datatype,&naxis1,&naxis2,
   		&sb,&sh,&quality);
   free(ppix);
}


/*
 * int CBuffer::GetW() --
 *  Renvoie la largeur de l'image.
 */
int CBuffer::GetW()
{
   return pix->GetWidth();
}

/*
 * int CBuffer::GetH() --
 *  Renvoie la hauteur de l'image.
 */
int CBuffer::GetH()
{
   return pix->GetHeight();
}


/*
 * tt_atan2
 *   Calcule atan2 sans 'domain error'
 *   Routine issue de libtt, tt_util1 @ 393
 *
 */
double tt_atan2(double y, double x)
{
   if (y==0) {
      if (x>=0) { return(0.); }
      else { return(2.*acos(0.)); }
   } else if (x==0) {
      if (y>=0) { return(acos(0.)); }
      else { return(-acos(0.)); }
   } else {
      return(atan2(y,x));
   }
}

int tt_util_cd2cdelt_new(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2)
/***************************************************************************/
/* Utilitaire qui tranforme les mots wcs de la matrice cd vers les         */
/* vieux mots cle cdelt1, cdelt2 et crota2.                                */
/***************************************************************************/
{
   double cdp1,cdp2,crotap2;
   double deuxpi,pisur2,sina,cosa,sinb,cosb,cosab,sinab,ab,aa,bb,cosr,sinr;
#define TT_PI (atan(1)*4.)

   deuxpi=2.*(TT_PI);
   pisur2=(TT_PI)/2.;

   aa=fmod(deuxpi+atan2(cd21,cd11),deuxpi);
   bb=fmod(deuxpi+atan2(-cd12,cd22),deuxpi);

   cosa=cos(aa);
   sina=sin(aa);
   cosb=cos(bb);
   sinb=sin(bb);

   /* a-b */
   cosab=cosa*cosb+sina*sinb;
   sinab=sina*cosb-cosa*sinb;
   ab=fabs(atan2(sinab,cosab));

   /* cas |a-b| proche de PI */
   if (ab>pisur2) {
	   if (cosa>cosb) {
         bb=fmod((TT_PI)+bb,deuxpi);
      } else {
         aa=fmod((TT_PI)+aa,deuxpi);
      }
   }

   /* mean (a+b)/2 */
   ab=bb-aa;
   if (ab>TT_PI) {
   	aa=aa+deuxpi;
   }
   ab=aa-bb;
   if (ab>TT_PI) {
   	bb=bb+deuxpi;
   }
   crotap2=fmod(deuxpi+(aa+bb)/2.,deuxpi);

   cosr=fabs(cos(crotap2));
   sinr=fabs(sin(crotap2));

   /* cdelt */
   if (cosr>sinr) {
	   cdp1=cd11/cos(crotap2);
	   cdp2=cd22/cos(crotap2);
   } else {
   	cdp1= cd21/sin(crotap2);
   	cdp2=-cd12/sin(crotap2);
   }

   *cdelt1=cdp1;
   *cdelt2=cdp2;
   *crota2=crotap2;
   return(0);
#undef TT_PI
}

int tt_util_cd2cdelt_old(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2)
/***************************************************************************/
/* Utilitaire qui tranforme les mots wcs de la matrice cd vers les         */
/* vieux mots cle cdelt1, cdelt2 et crota2.                                */
/***************************************************************************/
{
   double cdp1,cdp2,crotap2;
   double deuxpi,pisur2,sina,cosa,sinb,cosb,cosab,sinab,ab,aa,bb,cosr,sinr;
   double signr,signc,signd;
#define TT_PI (atan(1)*4.)

   deuxpi=2.*(TT_PI);
   pisur2=(TT_PI)/2.;

   aa=fmod(deuxpi+atan2(cd21,cd11),deuxpi);
   bb=fmod(deuxpi+atan2(-cd12,cd22),deuxpi);

   cosa=cos(aa);
   sina=sin(aa);
   cosb=cos(bb);
   sinb=sin(bb);

   /* a-b */
   cosab=cosa*cosb+sina*sinb;
   sinab=sina*cosb-cosa*sinb;
   ab=fabs(atan2(sinab,cosab));

   /* cas |a-b| proche de PI */
   if (ab>pisur2) {
	   if (cosa>cosb) {
         bb=fmod((TT_PI)+bb,deuxpi);
      } else {
         aa=fmod((TT_PI)+aa,deuxpi);
      }
   }

   /* mean (a+b)/2 */
   ab=bb-aa;
   if (ab>TT_PI) {
   	aa=aa+deuxpi;
   }
   ab=aa-bb;
   if (ab>TT_PI) {
   	bb=bb+deuxpi;
   }
   crotap2=fmod(deuxpi+(aa+bb)/2.,deuxpi);

   cosr=fabs(cos(crotap2));
   sinr=fabs(sin(crotap2));

   /* cdelt */
   if (cosr>sinr) {
	   cdp1=cd11/cos(crotap2);
	   cdp2=cd22/cos(crotap2);
   } else {
   	cdp1=fabs(-cd21/sin(crotap2));
   	cdp2=fabs( cd12/sin(crotap2));
      signr=sinr/fabs(sinr);
      /**/
      signc=cd12/fabs(cd12);
      signd=signc/signr;
      if (signd<0) { cdp1*=-1.; }
      /**/
      signc=cd21/fabs(cd21);
      signd=-signc/signr;
      if (signd<0) { cdp2*=-1.; }
   }

   *cdelt1=cdp1;
   *cdelt2=cdp2;
   *crota2=crotap2;
   return(0);
#undef TT_PI
}


/*
 * int CBuffer::FillAstromParams() --
 *   Complete les parametres astrometriques d'une image en fonction de
 *   ceux deja presents, pour les transformations carto/image.
 *
 */
void CBuffer::FillAstromParams()
{
   #define YES 1
   #define NO 0
   #define PI (atan(1)*4.)
   CFitsKeyword *k;
   // Debut des declarations MC
   char unit[50];
   int crval1found=NO,crval2found=NO,crota2found=NO;
   int crpix1found=NO,crpix2found=NO;
   int valid_optic=0,valid_crvp=0,valid_cd=0;
   int valid_pv=0,k1,k2;
//   int msg;
   double dvalue;
   int result=0;
   // Fin des declarations MC

   p_ast->crota2=0.;
   p_ast->foclen=0.;
   p_ast->px=0.;
   p_ast->py=0.;
   p_ast->crota2=0.;
   p_ast->cd11=0.;
   p_ast->cd12=0.;
   p_ast->cd21=0.;
   p_ast->cd22=0.;
   p_ast->crpix1=0.;
   p_ast->crpix2=0.;
   p_ast->crval1=0.;
   p_ast->crval2=0.;
   p_ast->cdelta1=0.;
   p_ast->cdelta2=0.;
   p_ast->dec0=-100.;
   p_ast->ra0=-100.;
   for (k1=1;k1<=2;k1++) {
      for (k2=0;k2<=10;k2++) {
         p_ast->pv[k1][k2]=0.;
      }
   }
   p_ast->pv[1][1]=1.;
   p_ast->pv[2][1]=1.;
   p_ast->pv_valid=0;

   /* -- recherche des mots cles d'astrometrie '_optic' dans l'entete FITS --*/
   if((k=keywords->FindKeyword("FOCLEN"))!=NULL) {
      valid_optic++;
      dvalue = k->GetDoubleValue();
      if(dvalue>0) {
         p_ast->foclen = dvalue;
      }
   }
   if((k=keywords->FindKeyword("PIXSIZE1"))!=NULL) {
      valid_optic++;
      dvalue = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if(dvalue>0) {
         p_ast->px = dvalue;
      }
      if(strcmp(unit,"m")==0) {
         p_ast->px *= 1.;
      } else if(strcmp(unit,"mm")==0) {
         p_ast->px *= 1e-3;
      } else {
         p_ast->px *= 1e-6;
      }
   }
   if((k=keywords->FindKeyword("PIXSIZE2"))!=NULL) {
      valid_optic++;
      dvalue = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if(dvalue>0) {
         p_ast->py=dvalue;
      }
      if(strcmp(unit,"m")==0) {
         p_ast->py *= 1.;
      } else if(strcmp(unit,"mm")==0) {
         p_ast->py *= 1e-3;
      } else {
         p_ast->py *= 1e-6;
      }
   }
   if((k=keywords->FindKeyword("RA"))!=NULL) {
      valid_optic++;
      dvalue = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if(dvalue>0) {
         p_ast->ra0 = dvalue;
      }
      if((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) {
         p_ast->ra0 *= (PI/180.);
      } else if(strcmp(unit,"h")==0) {
         p_ast->ra0 *= (15.*(PI)/180.);
      } else {
         p_ast->ra0 *= (PI/180.);
      }
      p_ast->crval1 = p_ast->ra0;
      crval1found = YES;
   }
   if((k=keywords->FindKeyword("DEC"))!=NULL) {
      valid_optic++;
      dvalue = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if((dvalue>=-90)&&(dvalue<=90)) {
         p_ast->dec0 = dvalue;
      }
      if((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) {
         p_ast->dec0 *= (PI/180.);
      } else {
         p_ast->dec0 *= (PI/180.);
      }
      p_ast->crval2=p_ast->dec0;
      crval2found=YES;
   }
   /* -- recherche des mots cles d'astrometrie '_cd' dans l'entete FITS --*/
   if((k=keywords->FindKeyword("CD1_1"))!=NULL) {
      valid_cd++;
      p_ast->cd11 = k->GetDoubleValue() * (PI) / 180.;
      if((k=keywords->FindKeyword("CD1_2"))!=NULL) {
         valid_cd++;
         p_ast->cd12 = k->GetDoubleValue() * (PI) / 180.;
      }
      if((k=keywords->FindKeyword("CD2_1"))!=NULL) {
         valid_cd++;
         p_ast->cd21 = k->GetDoubleValue() * (PI) / 180.;
      }
      if((k=keywords->FindKeyword("CD2_2"))!=NULL) {
         valid_cd++;
         p_ast->cd22 = k->GetDoubleValue() * (PI) / 180.;
      }
   }
   /* -- recherche des mots cles d'astrometrie '_crvp' dans l'entete FITS --*/
   if((k=keywords->FindKeyword("CDELT1"))!=NULL) {
      valid_crvp++;
      p_ast->cdelta1 = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if(strcmp(unit,"deg/pixel")==0) {
         p_ast->cdelta1 *= (PI/180.);
      } else {
         p_ast->cdelta1 *= (PI/180.);
      }
   }
   if((k=keywords->FindKeyword("CDELT2"))!=NULL) {
      valid_crvp++;
      p_ast->cdelta2 = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if(strcmp(unit,"deg/pixel")==0) {
         p_ast->cdelta2 *= (PI/180.);
      } else {
         p_ast->cdelta2 *= (PI/180.);
      }
   }
   if((k=keywords->FindKeyword("CROTA2"))!=NULL) {
      crota2found=YES;
      valid_crvp++;
      valid_optic++;
      p_ast->crota2 = k->GetDoubleValue();
      strcpy(unit,k->GetUnit());
      if(strcmp(unit,"deg")==0) {
         p_ast->crota2 *= (PI/180.);
      } else if(strcmp(unit,"radian")==0) {
         p_ast->crota2 *= (1.);
      } else {
         p_ast->crota2 *= (PI/180.);
      }
   }
   /* -- recherche des mots cles d'astrometrie '_crvp' '_cd' '_optic' dans l'entete FITS --*/
   if((k=keywords->FindKeyword("CRPIX1"))!=NULL) {
      crpix1found=YES;
      valid_crvp++;
      valid_cd++;
      valid_optic++;
      p_ast->crpix1 = k->GetDoubleValue();
   }
   if((k=keywords->FindKeyword("CRPIX2"))!=NULL) {
      crpix2found=YES;
      valid_crvp++;
      valid_cd++;
      valid_optic++;
      p_ast->crpix2 = k->GetDoubleValue();
   }
   if((k=keywords->FindKeyword("CRVAL1"))!=NULL) {
      valid_crvp++;
      valid_cd++;
      if(crval1found==NO) {
         valid_optic++;
      }
      dvalue = k->GetDoubleValue();
      if(dvalue>0) {
         p_ast->crval1 = dvalue;
      }
      if((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) {
         p_ast->crval1 *= (PI/180.);
      } else if(strcmp(unit,"h")==0) {
         p_ast->crval1 *= (15.*(PI)/180.);
      } else {
         p_ast->crval1 *= (PI/180.);
      }
      if(dvalue<=0) {
         p_ast->crval1 = p_ast->ra0;
      }
   } else {
      p_ast->crval1 = p_ast->ra0;
   }
   if((k=keywords->FindKeyword("CRVAL2"))!=NULL) {
      valid_crvp++;
      valid_cd++;
      dvalue = k->GetDoubleValue();
      if(crval2found==NO) {
         valid_optic++;
      }
      if((dvalue>=-90)&&(dvalue<=90)) {
         p_ast->crval2 = dvalue;
      }
      if((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) {
         p_ast->crval2 *= (PI/180.);
      } else {
         p_ast->crval2 *= (PI/180.);
      }
   } else {
      p_ast->crval2 = p_ast->dec0;
   }

   /* --- complete les validites --- */
   if(crota2found==NO) {
      p_ast->crota2 = 0.;
      valid_optic++;
      valid_crvp++;
   }
   if((crpix1found==NO)) {
      p_ast->crpix1 = p_ast->naxis1/2.;
      valid_optic++;
   }
   if ((crpix2found==NO)) {
      p_ast->crpix2 = p_ast->naxis2/2.;
      valid_optic++;
   }
   /* -- condition de validite --- */
   if((valid_optic>=8)||(valid_cd>=8)||(valid_crvp>=7)) {
      // v = YES;
      p_ast->valid = 1;
   } else {
      // v = NO;
      p_ast->valid = 0;
   }
   // *valid=v;

   /* --- transcodage --- */
   if ((valid_optic>=8)&&(valid_crvp<7)) {
      if ((p_ast->foclen!=0)&&(p_ast->px!=0)&&(p_ast->py!=0)) {
         p_ast->cdelta1=-2*atan(p_ast->px/2./p_ast->foclen);
         p_ast->cdelta2=2*atan(p_ast->py/2./p_ast->foclen);
      }
      result=1;
   }

   if (valid_cd>=8) {
      /*
      p_ast->cdelta1 = sqrt(p_ast->cd11*p_ast->cd11+p_ast->cd21*p_ast->cd21);
      det = p_ast->cd11*cos(p_ast->crota2);
      if(det<0) {p_ast->cdelta1 *= -1.;}
      p_ast->cdelta2 = sqrt(p_ast->cd12*p_ast->cd12+p_ast->cd22*p_ast->cd22);
      det = p_ast->cd22*cos(p_ast->crota2);
      if(det<0) {p_ast->cdelta2*=-1.;}
      p_ast->crota2 = tt_atan2((p_ast->cd12-p_ast->cd21),(p_ast->cd11+p_ast->cd22));
      */
      tt_util_cd2cdelt_old(p_ast->cd11,p_ast->cd12,p_ast->cd21,p_ast->cd22,&p_ast->cdelta1,&p_ast->cdelta2,&p_ast->crota2);
      result=1;
   } else if ((valid_optic>=8)||(valid_crvp>=7)) {

      p_ast->cd11 = p_ast->cdelta1*cos(p_ast->crota2);
      p_ast->cd12 = fabs(p_ast->cdelta2)*p_ast->cdelta1/fabs(p_ast->cdelta1)*sin(p_ast->crota2);
      p_ast->cd21 = -fabs(p_ast->cdelta1)*p_ast->cdelta2/fabs(p_ast->cdelta2)*sin(p_ast->crota2);
      p_ast->cd22 = p_ast->cdelta2*cos(p_ast->crota2);
      /*
      p_ast->cd11= p_ast->cdelta1*cos(p_ast->crota2);
      p_ast->cd12=-p_ast->cdelta2*sin(p_ast->crota2);
      p_ast->cd21= p_ast->cdelta1*sin(p_ast->crota2);
      p_ast->cd22= p_ast->cdelta2*cos(p_ast->crota2);
      */
      result=1;
   }

   if ((p_ast->foclen==0.)&&(p_ast->px!=0.)&&(p_ast->py!=0.)&&(p_ast->cdelta1!=0.)&&(p_ast->cdelta2!=0.)) {
      p_ast->foclen=fabs(p_ast->px/2./tan(p_ast->cdelta1/2.));
      p_ast->foclen+=fabs(p_ast->py/2./tan(p_ast->cdelta2/2.));
      p_ast->foclen/=2.;
   }

   valid_pv=0;
   for (k1=1;k1<=2;k1++) {
      for (k2=1;k2<=10;k2++) {
         if((k=keywords->FindKeyword("CRVAL2"))!=NULL) {
            valid_pv++;
         }
      }
   }
   if (valid_pv>=20) {
      for (k1=1;k1<=2;k1++) {
         for (k2=0;k2<=10;k2++) {
            sprintf(unit,"PV%d_%d",k1,k2);
            if((k=keywords->FindKeyword(unit))!=NULL) {
               dvalue = k->GetDoubleValue();
               p_ast->pv[k1][k2]=dvalue;
            }
         }
      }
      p_ast->pv_valid=1;
   }

   if (result!=1) {
      throw CError(ELIBSTD_NO_ASTROMPARAMS);
   }
   #undef YES
   #undef NO
   #undef PI
}

void CBuffer::MergePixels(TColorPlane plane, int pixels) 
{
   
   pix->MergePixels(plane, pixels);

}



/*
 * int CBuffer::SetPix(TYPE_PIXELS val, int x, int y) --
 *  Affecte la valeur du pixel aux coordonnees passes en parametres.
 *  Les valeurs des coordonnees vont de (0,0) a (NAXIS1-1,NAXIS2-1).
 *  La valeur de retour est :
 *    - '1'  si pas de pixels (pix=NULL)
 *    - '-1' si pas de mots-cles
 *    - '-2' si pas de mot-cle 'NAXIS1'
 *
 */
void CBuffer::SetPix(TYPE_PIXELS val,int x, int y)
{
    pix->SetPix(val, x, y);
}


/*
 * SetPixels
 *  Affecte le tableau de pixels 
 *  
 *  Return : 0
 *
 */
void CBuffer::SetPixels(TColorPlane plane, int width, int height, TPixelFormat pixelFormat, TPixelCompression compression, void * pixels, long pixelSize, int reverseX, int reverseY) {
   CPixels  * pixTemp;   

   if( plane == PLANE_GREY) {
      // cas d'une image grise
      pixTemp = new CPixelsGray(width, height, pixelFormat, pixels, reverseX, reverseY);
   } else {
      // cas d'un image couleur
      switch (compression) {
      case COMPRESS_NONE:
         {
            pixTemp = new CPixelsRgb(plane, width, height, pixelFormat, pixels, reverseX, reverseY);
            break;
         }         
      case COMPRESS_JPEG :
         {
            char * decodedData;
            long   decodedSize;
            int   width, height;
            int result = -1;

            result  = libdcjpeg_decodeBuffer((char*) pixels, pixelSize, &decodedData, &decodedSize, &width, &height);            
            if (result == 0 )  {
               pixTemp = new CPixelsRgb(PLANE_RGB, width, height, FORMAT_BYTE, decodedData, reverseX, reverseY);
               // l'espace memoire cree par la librairie doit etre desalloué par cette meme librairie.
               libdcjpeg_freeBuffer(decodedData);
            } else {
               throw CError("libjpeg_decodeBuffer error=%d", result);
            }
            break;
         } 
      case COMPRESS_RAW :
         {
            int width, height;
            int result = -1;
            char * decodedData;
            
            //  ATTENTION : libdcraw_decodeBuffer peut réduire les dimensions de quelques pixels en largeur et hauteur
            //  Exemple: dans le cas de certains fichiers .CRW  width et height ont deux pixels de moins.
            result = libdcraw_decodeBuffer ((char*) pixels, pixelSize, &width, &height, &decodedData);
            if (result == 0 )  {
                pixTemp = new CPixelsRgb(plane, width, height, FORMAT_SHORT, decodedData, reverseX, reverseY);
                libdcraw_freeBuffer(decodedData);
            } else {
               throw CError("libdcraw_decodeBuffer error=%d", result);
            }
            break;
         }   
      default :
         {
            throw CError("SetPixels not implemented for compression=%s", CPixels::getPixelCompressionName(compression));
            break;
         }
      }
               
   }

   // s'il n'y a pas eu d'exception pendant la creation de pixTemp, je detruis l'ancienne image 
	if (pix != NULL) {
	   delete pix ;
	   pix = NULL;
	}

   // j'affecte la nouvelle image
   pix = pixTemp;

}


void CBuffer::SetPixels(int width, int height, int pixelSize, int offset[4], int pitch, unsigned char * pixels) {
   CPixels  * pixTemp;   

   // On fait de la place avant de recreer le contenu du buffer
   //FreeBuffer(keep_keywords);

   pixTemp = new CPixelsRgb(width, height, pixelSize, offset, pitch, pixels);

   // s'il n'y a pas eu d'exception pendant la creation de pixTemp, je detruis l'ancienne image 
	if (pix != NULL) {
	   delete pix ;
	   pix = NULL;
	}

   pix = pixTemp;   
}


void CBuffer::SetKeyword(char *nom, char *data, char *datatype, char *comment, char *unit)
{
   int iDatatype;
   int iInt;
   double dDouble;
   float fFloat;
   void *pvData;

   if(keywords==NULL) {
      throw CError(ELIBSTD_NO_KWDS); ;
   } else {
      if(strcmp(datatype,"float")==0) {
         iDatatype = TFLOAT;
         sscanf(data,"%f",&fFloat);
         pvData = (void*)&fFloat;
      } else if(strcmp(datatype,"double")==0) {
         iDatatype = TDOUBLE;
         sscanf(data,"%lf",&dDouble);
         pvData = (void*)&dDouble;
      } else if(strcmp(datatype,"string")==0) {
         iDatatype = TSTRING;
         pvData = (void*)&(data);
      } else {
         iDatatype = TINT;
         sscanf(data,"%d",&iInt);
         pvData = (void*)&iInt;
      }
      keywords->Add(nom,pvData,iDatatype,comment,unit);
   }
}

void CBuffer::CopyTo(CBuffer*dest)
{
   int naxis1, naxis2, naxis;
   TYPE_PIXELS *ppix = NULL;


   if(dest==NULL) throw CError(ELIBSTD_DEST_BUF_NOT_FOUND);
   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   naxis  = pix->GetPlanes();
   ppix = (TYPE_PIXELS *) malloc(naxis1* naxis2 * naxis * sizeof(float));

   if(naxis == 1) {
      pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);
      dest->CopyFrom(keywords, PLANE_GREY, ppix);
   }else {
      pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_RGB, (int) ppix);
      dest->CopyFrom(keywords,PLANE_RGB, ppix);
   }
   free(ppix);
}

void CBuffer::CopyFrom(CFitsKeywords*hdr, TColorPlane plane, TYPE_PIXELS*pixels)
{
   int naxis1, naxis2, naxis;
   int nb_keys, msg;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   if(hdr==NULL) throw CError(ELIBSTD_NO_KWDS);

   naxis  = hdr->FindKeyword("NAXIS")->GetIntValue();
   naxis1 = hdr->FindKeyword("NAXIS1")->GetIntValue();
   naxis2 = hdr->FindKeyword("NAXIS2")->GetIntValue();

   FreeBuffer(DONT_KEEP_KEYWORDS);
   SetPixels(plane, naxis1, naxis2, FORMAT_FLOAT, COMPRESS_NONE, pixels, 0, 0, 0);

   // La recopie des mots cles s'effectue en passant par les tableaux
   // format KLOTZ (j'ai pas envie de me faire chier a la main !
   nb_keys = hdr->GetKeywordNb();

   msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);

   hdr->SetToArray(&keynames,&values,&comments,&units,&datatypes);
   keywords->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);

   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
}

void CBuffer::CopyKwdFrom(CBuffer*bufOrg)
{
   int i;
   int nb_keys;
   int msg;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   CFitsKeyword *kwd;

   nb_keys = bufOrg->keywords->GetKeywordNb();

   msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);

   bufOrg->keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);

   for(i=0;i<nb_keys;i++) {
      if((strcmp(keynames[i],"SIMPLE")!=0)&&(strcmp(keynames[i],"BITPIX")!=0)&&
         (strcmp(keynames[i],"NAXIS")!=0)&&(strcmp(keynames[i],"NAXIS1")!=0)&&
         (strcmp(keynames[i],"NAXIS2")!=0)) {
         kwd = keywords->AddKeyword(keynames[i]);
         kwd->GetFromArray(i,&keynames,&values,&comments,&units,&datatypes);
      }
   }

   msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
   if(msg) throw CErrorLibtt(msg);
}

/**
* definiton ajoute un constante au fichier
*
*/

void CBuffer::Add(char *filename, float offset)
{
   pix->Add(filename, offset);
}

void CBuffer::AstroBaricenter(int x1, int y1, int x2, int y2, double *xc, double *yc) {
   pix->AstroBaricenter(x1, y1, x2, y2, xc, yc);
}

void CBuffer::AstroCentro(int x1, int y1, int x2, int y2, int xmax, int ymax,
                     TYPE_PIXELS seuil,float* sx, float* sy, float* r){
   pix->AstroCentro(x1, y1, x2, y2, xmax, ymax, seuil, sx, sy, r);
}

void CBuffer::AstroFlux(int x1, int y1, int x2, int y2, 
                     TYPE_PIXELS* flux, TYPE_PIXELS* maxi, int *xmax, int* ymax, 
                     TYPE_PIXELS *moy, TYPE_PIXELS *seuil, int * nbpix){
   pix->AstroFlux(x1, y1, x2, y2, flux, maxi, xmax, ymax, moy, seuil, nbpix);
}

void CBuffer::AstroPhoto(int x1, int y1, int x2, int y2, int xmax, int ymax, 
                    TYPE_PIXELS moy, double *dFlux, int* ntot){
   pix->AstroPhoto(x1, y1, x2, y2, xmax, ymax, moy, dFlux, ntot);
}

void CBuffer::AstroPhotom(int x1, int y1, int x2, int y2, int method, double r1, double r2,double r3, 
                      double *flux, double* f23, double* fmoy, double* sigma, int *n1){
   pix->AstroPhotometry(x1, y1, x2, y2, method, r1, r2, r3, flux, f23, fmoy, sigma, n1);
}

void CBuffer::Autocut(double *phicut,double *plocut,double *pmode)
{
   pix->Autocut( phicut, plocut, pmode);
}

void CBuffer::BinX(int x1, int x2, int width)
{
   pix->BinX(x1, x2, width);
}

void CBuffer::BinY(int y1, int y2, int height)
{
   pix->BinY(y1,y2, height);
}

void CBuffer::Clipmin(double value)
{
   pix->Clipmin(value);
}

void CBuffer::Clipmax(double value)
{
   pix->Clipmax(value);
}

void CBuffer::Div(char *filename, float constante)
{
   pix->Div(filename, constante);
}



/*
 * int CBuffer::GetPix(TYPE_PIXELS *val, int x, int y) --
 *  Renvoie la valeur du pixel aux coordonnees passes en parametres,
 *  dans le pointeur val. Les valeurs des coordonnees vont de (0,0) a
 * (NAXIS1-1,NAXIS2-1).
 *  La valeur de retour est :
 *    - '1'  si pas de pixels (pix=NULL)
 *    - '-1' si pas de mots-cles
 *    - '-2' si pas de mot-cle 'NAXIS1'
 *
 */
void CBuffer::GetPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y)
{
   pix->GetPix(plane , val1, val2, val3, x, y);
}


/**
 *----------------------------------------------------------------------
 * GetPixels(TYPE_PIXELS *pixels)
 *    retourne les pixels au format float, non compressé 
 *    (retourne des niveaux de gris si l'image est en couleur)
 *
 * Parameters: 
 *    pixels :  pointeur de l'espace memoire préalablement alloué par l'appelant
 * Results:
 *    exception CError
 * Side effects:
 *    appelle pix->GetPixels(0, 0, width -1, height -1, FORMAT_FLOAT, PLANE_GREY, TColorPlane plane, int pixels)
 *----------------------------------------------------------------------
 */
void CBuffer::GetPixels(TYPE_PIXELS *pixels)
{
   int width = pix->GetWidth();
   int height = pix->GetHeight();
   pix->GetPixels(0, 0, width -1, height -1, FORMAT_FLOAT, PLANE_GREY, (int) pixels);
}

void CBuffer::GetPixels(TYPE_PIXELS *pixels, TColorPlane colorPlane)
{
   int width = pix->GetWidth();
   int height = pix->GetHeight();
   pix->GetPixels(0, 0, width -1, height -1, FORMAT_FLOAT, colorPlane, (int) pixels);
}

void CBuffer::GetPixelsPointer(TYPE_PIXELS **ppixels)
{
   pix->GetPixelsPointer(ppixels);
}


void CBuffer::GetPixelsVisu( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY,
            double hicutRed,   double locutRed, 
            double hicutGreen, double locutGreen,
            double hicutBlue,  double locutBlue, 
            Pal_Struct *pal, unsigned char *ptr)
{
   pix->GetPixelsVisu(x1,y1,x2, y2, mirrorX, mirrorY, 
      hicutRed, locutRed, hicutGreen, locutGreen, hicutBlue, locutBlue, 
      pal, ptr);
}

void CBuffer::Log(float coef, float offset)
{
   pix->Log(coef, offset);
}

void CBuffer::MirX()
{
   pix->MirX();
}

void CBuffer::MirY()
{
   pix->MirY();
}

void CBuffer::NGain(float gain)
{
   pix->NGain(gain);
}

void CBuffer::NOffset(float offset)
{
   pix->NOffset(offset);
}

void CBuffer::Offset(float offset)
{
   pix->Offset(offset);
}

void CBuffer::Opt(char *dark, char *offset)
{
   pix->Opt(dark, offset);
}

/**
 *----------------------------------------------------------------------
 * RestoreInitialCut
 *    restaure les seuils initiaux 
 *        - soit les seuils initiaux récupérés
 *
 * Parameters: 
 *    none
 * Results:
 *    none
 * Side effects:
 *    si les seuils initiaux n'existaien pas, 
 *    ils sont calcules avec la méthode Stat()
 *----------------------------------------------------------------------
 */
void CBuffer::RestoreInitialCut()
{
   float hicut;
   float locut;
   float mini, maxi, mean, sigma, bgmean, bgsigma, contrast;
   
   if (initialMipsLo==0 && initialMipsHi==0 ) { 
      // je calcule les seuils initiaux
      Stat( -1, -1, -1, -1,
           &locut,  &hicut,   &maxi,
           &mini, &mean, &sigma,
           &bgmean, &bgsigma, &contrast);
      initialMipsHi = hicut;
      initialMipsLo = locut;
   }
   keywords->Add("MIPS-HI",&initialMipsHi,TFLOAT,"Hight cut","ADU");
   keywords->Add("MIPS-LO",&initialMipsLo,TFLOAT,"Low cut","ADU");
}

void CBuffer::Rot(float x0, float y0, float angle)
{
   pix->Rot(x0, y0, angle);
}

void CBuffer::Sub(char *filename, float offset)
{
   pix->Sub(filename, offset);
}

void CBuffer::Unsmear(float coef)
{
   pix->Unsmear(coef);
}


void CBuffer::TtImaSeries(char *s)
{
   CFitsKeyword *k;
   int msg;
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char valchar[80];
   TYPE_PIXELS *ppixOut=NULL;
   //TYPE_PIXELS *ppixIn=NULL;
   CPixels * pixelsOut;


   nb_keys = keywords->GetKeywordNb();

   try {
      // Allocation de l'espace memoire pour les tableaux de mots-cles
      msg = Libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) throw CErrorLibtt(msg);
      
      // Conversion keywords vers tableaux 'Made in Klotz'
      keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);
      
      // traitement de l'image
      pixelsOut = pix->TtImaSeries(s, &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      delete pix;
      pix = pixelsOut;
      
      // On recupere les mots cles
      keywords->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
      sprintf(valchar,"%d",pix->GetWidth() );
      SetKeyword("NAXIS1",valchar,"int","","");
      sprintf(valchar,"%d",pix->GetHeight());
      SetKeyword("NAXIS2",valchar,"isnt","","");
      
      // On reinitialise les parametres astrometriques
      p_ast->valid = 0;
      k = keywords->FindKeyword("BITPIX");
      if(k==0) {
         saving_type = USHORT_IMG;
      } else {
         saving_type = keywords->FindKeyword("BITPIX")->GetIntValue();
      }
      if(saving_type==16) {
         k = keywords->FindKeyword("BZERO");
         if((k)&&(k->GetIntValue()==32768)) {
            saving_type = USHORT_IMG;
         }
      } else if(saving_type==32) {
         k = keywords->FindKeyword("BZERO");
         if((k)&&(k->GetIntValue()==-(2^31))) {
            saving_type = ULONG_IMG;
         }
      }
      // Liberation de la memoire allouee par libtt
      msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);   
      msg = Libtt_main(TT_PTR_FREEPTR,1,&ppixOut);
      
   } catch (const CError& e) {
      // je libere la mémoire
      msg = Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      msg = Libtt_main(TT_PTR_FREEPTR,1,&ppixOut);
      // je transmets l'exception
      throw e;
   }

}

void CBuffer::Stat( int x1,int y1,int x2,int y2, 
                   float *locut,  float *hicut,   float *maxi,
                   float *mini,   float *mean,    float *sigma,
                   float *bgmean, float *bgsigma, float *contrast)
{
   int msg, naxis1, naxis2;
   int datatype, iMin, iMax;
   float fHi, fLo;
   double dlocut, dhicut, dmaxi, dmini, dmean, dsigma, dbgmean,dbgsigma,dcontrast;
   int i,naxis11,naxis22;
   TYPE_PIXELS *ppix= NULL;

   naxis1=GetW();
   naxis2=GetH();

   datatype = TFLOAT;
   if ((x1==-1)&&(y1==-1)&&(x2==-1)&&(y2==-1)) {
      // x1=y1=x2=y2=-1 si l'on souhaite traiter toute l'image
      ppix = (TYPE_PIXELS*)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS));
      if (ppix==NULL) throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
      pix->GetPixels(0, 0, naxis1-1, naxis2-1 , FORMAT_FLOAT, PLANE_GREY, (int) ppix);
      msg = Libtt_main(TT_PTR_STATIMA,13,ppix,&datatype,&naxis1,&naxis2,
                  &dlocut,&dhicut,&dmaxi,&dmini,&dmean,&dsigma,&dbgmean,&dbgsigma,&dcontrast);
      free(ppix);
      if(msg) throw CErrorLibtt(msg);
   } else {
      // traite une fenetre dans l'image
      if((x1<0)||(x2<0)||(x1>naxis1-1)||(x2>naxis1-1)) {throw CError(ELIBSTD_X1X2_NOT_IN_1NAXIS1);}
      if((y1<0)||(y2<0)||(y1>naxis2-1)||(y2>naxis2-1)) {throw CError(ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);}
      if(x1>x2) {i = x2; x2 = x1; x1 = i;}
      if(y1>y2) {i = y2; y2 = y1; y1 = i;}
      naxis11 = x2-x1+1;
      naxis22 = y2-y1+1;
      ppix = (TYPE_PIXELS*)malloc(naxis11*naxis22 * sizeof(TYPE_PIXELS));
      if (ppix==NULL) throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
      pix->GetPixels(x1, y1, x2, y2 , FORMAT_FLOAT, PLANE_GREY, (int) ppix);
      msg = Libtt_main(TT_PTR_STATIMA,13,ppix,&datatype,&naxis11,&naxis22,
                  &dlocut,&dhicut,&dmaxi,&dmini,&dmean,&dsigma,&dbgmean,&dbgsigma,&dcontrast);
      free(ppix);
      if(msg) throw CErrorLibtt(msg);
   }

   *locut = (float)dlocut; *hicut = (float)dhicut;
   *maxi = (float)dmaxi; *mini = (float)dmini;
   *mean = (float)dmean; *sigma = (float)dsigma;
   *bgmean = (float)dbgmean; *bgsigma = (float)dbgsigma;
   *contrast = (float)dcontrast;

   if ((x1==-1)&&(y1==-1)&&(x2==-1)&&(y2==-1)) {
      fLo = (float) dlocut;
      fHi = (float) dhicut;
      iMin = (int)dmini;
      iMax = (int)dmaxi;
      keywords->Add("MIPS-HI",(void*)&fHi,TFLOAT,"High cut","ADU");
      keywords->Add("MIPS-LO",(void*)&fLo,TFLOAT,"Low cut","ADU");
      keywords->Add("CONTRAST",(void*)contrast,TFLOAT,"Pixel contrast","ADU");
      keywords->Add("MEAN",(void*)mean,TFLOAT,"Mean value","ADU");
      keywords->Add("SIGMA",(void*)sigma,TFLOAT,"Standard deviation","ADU");
      keywords->Add("DATAMAX",(void*)&iMax,TINT,"Maximum value","ADU");
      keywords->Add("DATAMIN",(void*)&iMin,TINT,"Minimum value","ADU");
      keywords->Add("BGMEAN",(void*)bgmean,TFLOAT,"Background mean value","ADU");
      keywords->Add("BGSIGMA",(void*)bgsigma,TFLOAT,"Background standard deviation","ADU");
   }

}

void CBuffer::Scar( int x1,int y1,int x2,int y2)
{
   int naxis1, naxis2;
   int i,j;
   double dltadu,dltpix,deb,fin;
   TYPE_PIXELS *ppix= NULL;

   naxis1=GetW();
   naxis2=GetH();

   // seulement pour les images non couleur
   if( pix->getPixelClass() != CLASS_GRAY) {
      throw CError(ELIBSTD_NOT_IMPLEMENTED);
   }
   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   ppix = (TYPE_PIXELS *) malloc(naxis1* naxis2 * sizeof(float));
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);


   // traite une fenetre dans l'image
   if((x1<0)||(x2<0)||(x1>naxis1-1)||(x2>naxis1-1)) {throw CError(ELIBSTD_X1X2_NOT_IN_1NAXIS1);}
   if((y1<0)||(y2<0)||(y1>naxis2-1)||(y2>naxis2-1)) {throw CError(ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);}
   if(x1>x2) {i = x2; x2 = x1; x1 = i;}
   if(y1>y2) {i = y2; y2 = y1; y1 = i;}
   if (x2>x1+1) {
      if (y2>y1+1) {
         // couture horizontale
         dltpix=(double)(x2-x1);
         for(j=y1+1;j<y2;j++) {
            deb=(double)*(ppix+naxis1*j+x1);
            fin=(double)*(ppix+naxis1*j+x2);
            dltadu=(double)(fin-deb);
            for(i=x1+1;i<x2;i++) {
               *(ppix+naxis1*j+i)=(TYPE_PIXELS)(deb+dltadu*(i-x1)/dltpix);
            }
         }
         // couture verticale
         dltpix=(double)(y2-y1);
         for(i=x1+1;i<x2;i++) {
            deb=(double)*(ppix+naxis1*y1+i);
            fin=(double)*(ppix+naxis1*y2+i);
            dltadu=(double)(fin-deb);
            for(j=y1+1;j<y2;j++) {
              *(ppix+naxis1*j+i)=(TYPE_PIXELS) (( *(ppix+naxis1*j+i) + (deb+dltadu*(j-y1)/dltpix) )/2.);
            }
         }
      }
   }

   //  memorisation des pixels
   //FreeBuffer(DONT_KEEP_KEYWORDS);
   SetPixels(PLANE_GREY, naxis1, naxis2, FORMAT_FLOAT, COMPRESS_NONE, ppix, 0, 0, 0);

   free(ppix);
}

void CBuffer::SyntheGauss(double xc, double yc, double imax, double fwhmx, double fwhmy, double limitadu)
{
   int naxis1, naxis2;
   int i,j,x1,x2,y1,y2;
   double sigx,sigy,rx,ry,r;
   TYPE_PIXELS *ppix= NULL;

   naxis1=GetW();
   naxis2=GetH();

   // seulement pour les images non couleur
   if( pix->getPixelClass() != CLASS_GRAY) {
      throw CError(ELIBSTD_NOT_IMPLEMENTED);
   }
   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   ppix = (TYPE_PIXELS *) malloc(naxis1* naxis2 * sizeof(float));
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);

   // sig2 = 0.601*0.601*fwhmx,fwhmy
   // r2 = (x-xc)*(x-xc) + (y-yc)*(y-yc)
   // i(x,y) = i(x,y) + ( imax * exp ( -r2/sig2 ) )
   // imax peut etre negatif pour soustraire la gaussienne
   if ((fwhmx<=0.)||(fwhmy<=0.)||(imax==0.)) {
      return ;
   }
   sigx=fwhmx*0.601;
   sigy=fwhmy*0.601;
   if (limitadu==0.) {
      limitadu=1.;
   }
   r=-log(fabs(limitadu/imax));
   if (r<=0.) {return ;}
   rx=sigx*sqrt(r);
   ry=sigy*sqrt(r);
   x1=(int)floor(xc-rx);
   x2=(int)ceil(xc+rx);
   y1=(int)floor(yc-ry);
   y2=(int)ceil(yc+ry);
   if (x1<0) {x1=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (y1<0) {y1=0;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (x2<0) {x2=0;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y2<0) {y2=0;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   sigx*=sigx;
   sigy*=sigy;
   for(j=y1;j<=y2;j++) {
      ry=(double)j-yc;
      ry*=ry;
      for(i=x1;i<=x2;i++) {
         rx=(double)i-xc;
         rx*=rx;
         *(ppix+naxis1*j+i)=(TYPE_PIXELS)( *(ppix+naxis1*j+i) + imax*exp(-rx/sigx-ry/sigy) );
      }
   }

   //  memorisation des pixels
   SetPixels(PLANE_GREY, naxis1, naxis2, FORMAT_FLOAT, COMPRESS_NONE, ppix, 0, 0, 0);

   free(ppix);

}

void CBuffer::Histogram(int n, float *adus, float *meanadus, long *histo,
                       int ismini,float mini,int ismaxi,float maxi)
{

    pix->Histogram(n, adus, meanadus, histo, ismini, mini, ismaxi, maxi);
}

void CBuffer::radec2xy(double ra, double dec, double *x, double *y,int order)
{
   double sindec,cosdec,sindec0,cosdec0,cosrara0,sinrara0;
   double h,det;
   double dra,ddec;
   double PI = (atan(1)*4.);
   double x0,y0,xp,yp;

   if (p_ast==NULL) {
      throw CError(ELIBSTD_NO_ASTROMPARAMS) ;
   }

   if(p_ast->valid==0) {
       FillAstromParams();
   }


   /* --- Conversion deg -> rad --- */
   ra *= (double)(PI/180.);
   dec *= (double)(PI/180.);

   /* --- passage ra,dec -> x,y ---*/
   sindec=sin(dec);
   cosdec=cos(dec);
   sindec0 = sin(p_ast->crval2);
   cosdec0 = cos(p_ast->crval2);
   cosrara0 = cos(ra-p_ast->crval1);
   sinrara0 = sin(ra-p_ast->crval1);
   h = sindec*sindec0+cosdec*cosdec0*cosrara0;
   dra = cosdec*sinrara0/h;
   ddec = (sindec*cosdec0-cosdec*sindec0*cosrara0)/h;
   det = p_ast->cd22 * p_ast->cd11 - p_ast->cd12 * p_ast->cd21;
   if(det==0) {
      *x = *y = (double)0.;
   } else {
      *x = (double)(p_ast->crpix1 - (p_ast->cd12*ddec-p_ast->cd22*dra) / det -0.5);
      *y = (double)(p_ast->crpix2 + (p_ast->cd11*ddec-p_ast->cd21*dra) / det -0.5);
   }
   /* --- cas de distorsion ---*/
   if ((order==2)&&(p_ast->pv_valid=1)) {
      x0=*x;
      y0=*y;
      xp = p_ast->pv[1][1]*x0 + p_ast->pv[1][2]*y0 + p_ast->pv[1][0] + p_ast->pv[1][5]*x0*y0 + p_ast->pv[1][4]*x0*x0 + p_ast->pv[1][6]*y0*y0 + p_ast->pv[1][7]*x0*x0*x0 + p_ast->pv[1][8]*x0*x0*y0 + p_ast->pv[1][9]*x0*y0*y0 + p_ast->pv[1][10]*y0*y0*y0;
      yp = p_ast->pv[2][2]*x0 + p_ast->pv[2][1]*y0 + p_ast->pv[2][0] + p_ast->pv[2][5]*x0*y0 + p_ast->pv[2][6]*x0*x0 + p_ast->pv[2][4]*y0*y0 + p_ast->pv[2][10]*x0*x0*x0 + p_ast->pv[2][9]*x0*x0*y0 + p_ast->pv[2][8]*x0*y0*y0 + p_ast->pv[2][7]*y0*y0*y0;
      x0-=(xp-x0);
      y0-=(yp-y0);
      *x=x0;
      *y=y0;
   }
}


void CBuffer::xy2radec(double x, double y, double *ra, double *dec,int order)
{
   double delta,gamma;
   double dra,ddec;
   double PI = (atan(1)*4.);
   double xp,yp;

   if (p_ast==NULL) {
      throw CError(ELIBSTD_NO_ASTROMPARAMS);
   }
   if(p_ast->valid==0) {
      FillAstromParams();
   }

   /* --- cas de distorsion ---*/
   if ((order==2)&&(p_ast->pv_valid==1)) {
      xp = p_ast->pv[1][1]*x + p_ast->pv[1][2]*y + p_ast->pv[1][0] + p_ast->pv[1][5]*x*y + p_ast->pv[1][4]*x*x + p_ast->pv[1][6]*y*y + p_ast->pv[1][7]*x*x*x + p_ast->pv[1][8]*x*x*y + p_ast->pv[1][9]*x*y*y + p_ast->pv[1][10]*y*y*y;
      yp = p_ast->pv[2][2]*x + p_ast->pv[2][1]*y + p_ast->pv[2][0] + p_ast->pv[2][5]*x*y + p_ast->pv[2][6]*x*x + p_ast->pv[2][4]*y*y + p_ast->pv[2][10]*x*x*x + p_ast->pv[2][9]*x*x*y + p_ast->pv[2][8]*x*y*y + p_ast->pv[2][7]*y*y*y;
      if ((y>100)&&(y<200)) {
         x=1.*x;
      }
      x=xp;
      y=yp;
   }
   /* --- passage x,y -> ra,dec ---*/
   x=x+.5;
   y=y+.5;
   dra = p_ast->cd11*(x-p_ast->crpix1) + p_ast->cd12*(y-p_ast->crpix2);
   ddec = p_ast->cd21*(x-p_ast->crpix1) + p_ast->cd22*(y-p_ast->crpix2);
   delta = cos(p_ast->crval2) - ddec*sin(p_ast->crval2);
   gamma = sqrt(dra*dra+delta*delta);
   *ra = (double)(p_ast->crval1 + atan(dra/delta));
   if(*ra<0) {
      *ra += (double)(2*PI);
   }
   if(*ra>(double)(2*PI)) {
      *ra -= (double)(2*PI);
   }
   *dec = (double)(atan((sin(p_ast->crval2)+ddec*cos(p_ast->crval2))/gamma));

   /* --- Conversion rad -> deg --- */
   *ra *= (double)(180./PI);
   *dec *= (double)(180./PI);

}



void CBuffer::Fwhm(int x1, int y1, int x2, int y2,
                  double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
                  double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				  double fwhmx0, double fwhmy0)
{
   pix->Fwhm(x1, y1, x2, y2,
                  maxx, posx, fwhmx, fondx, errx,
                  maxy, posy, fwhmy, fondy, erry,
				  fwhmx0, fwhmy0);
}


void CBuffer::MedX(int x1, int x2, int width)
{
#if 0
   int temp;
   int w, h, x, y;
   TYPE_PIXELS value;
   TYPE_PIXELS *out;

   w=GetW();
   h=GetH();

   if (width < 0)
   {
      throw CError(ELIBSTD_WIDTH_POSITIVE);
   } 

   if ((x1 < 0) || (x2 < 0) || (x1 > w-1) || (x2 > w-1))
   {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } 

   if(x1 > x2)
   {
       temp = x2;
       x2 = x1;
       x1 = temp;
   } 

//   out = (TYPE_PIXELS*)calloc(width*h,sizeof(TYPE_PIXELS));

   // Mettre ici le traitement.

//   memcpy(pix,out,width*h*sizeof(TYPE_PIXELS));
//   free(out);
#endif
}


void CBuffer::MedY(int y1, int y2, int height)
{
#if 0
   int temp;
   int w, h, x, y;
   TYPE_PIXELS value;
   TYPE_PIXELS *out;

   if(pix==NULL) {return ELIBSTD_BUF_EMPTY;}
   w=GetW();
   h=GetH();

   
   if (height < 0)
   {
         throw CError(  ELIBSTD_HEIGHT_POSITIVE);

   } 
   if ((y1 < 0) || (y2 < 0) || (y1 > h-1) || (y2 > h-1))
   {
         throw CError(  ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   } 

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } 

#endif
}


void CBuffer::Window(int x1, int y1, int x2, int y2)
{
   pix->Window(x1, y1, x2, y2);
}

int CBuffer::A_StarList(double threshin,char *filename,double fwhm,int radius,
						int border,double threshold,int after_gauss)
{
   int i,retour;
   int gmsize = 2*radius + 1;
   TYPE_PIXELS *temp_pic,*gauss_matrix;
   TYPE_PIXELS *ppix= NULL;
   int naxis1,naxis2;

   // seulement pour les images non couleur

   naxis1 = pix->GetWidth();
   naxis2 = pix->GetHeight();
   ppix = (TYPE_PIXELS *) malloc(naxis1* naxis2 * sizeof(float));
   pix->GetPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (int) ppix);

   if((temp_pic = (TYPE_PIXELS *)malloc(sizeof(TYPE_PIXELS)*naxis1*naxis2))==NULL)
	   throw CError(ELIBSTD_NO_MEMORY_FOR_KWDS);
   if((gauss_matrix = (TYPE_PIXELS *)malloc(sizeof(TYPE_PIXELS)*gmsize*gmsize))==NULL) {
      free(temp_pic);
      throw CError(ELIBSTD_NO_MEMORY_FOR_KWDS);
   }

   for(i=0; i < (naxis1*naxis2) ; i++)
		   temp_pic[i] = (float)0.0;

   retour = A_filtrGauss ((TYPE_PIXELS)fwhm, radius, (TYPE_PIXELS)threshin,
	                      (TYPE_PIXELS)threshold, filename,
	                      ppix,temp_pic,gauss_matrix,
	                      naxis1,naxis2,gmsize,border);

   if(after_gauss!=0 && retour>=0)
   {
      CPixelsGray * newpix;
      newpix = new CPixelsGray(naxis1, naxis2, FORMAT_SHORT, temp_pic, 0, 0);

      delete pix;
      pix = newpix;

   }
	free(temp_pic);
   free(gauss_matrix);
   free(ppix);

   return retour;

}

int CBuffer::A_filtrGauss (TYPE_PIXELS fwhm, int radius, TYPE_PIXELS threshin,
						   TYPE_PIXELS threshold, char *filename,
						   TYPE_PIXELS *picture,TYPE_PIXELS *temp_pic,TYPE_PIXELS *gauss_matrix,
						   int size_x,int size_y,int gmsize,int border)
{

/*
  Authors: Bogumil and Dorota
*/
//#if defined (OS_WIN)

   int x, y, i;
   int center = radius;
   double sig = 0.4246*fwhm;
   double dsig2 = 2*sig*sig;
   double dpisig2 = 3.14159265358979*dsig2; //=2*pi*sig^2
   double summ = 0.0;

   /* Creation of matrix with Gauss/normal distribution values */
   for (y=0; y<gmsize; y++)
   {
	   for (x=0; x<gmsize; x++)
	   {
		   gauss_matrix[x+y*gmsize] = (TYPE_PIXELS)(
			   exp( -((x-center)*(x-center) + (y-center)*(y-center)) / dsig2)
			   /dpisig2);
		   summ += gauss_matrix[x+y*gmsize];
	   }
   }

   double summa = 0.0;

   /* Dodatkowa normalizacja wynikajaca z nie nieskonczonej macierzy
   i sprowadzenie do postaci, w ktorej suma elem. rowna jest zero */

   /* Additional normalization - sum of elements is zero */
   for (y=0; y<gmsize; y++)
   {
	   for (x=0; x<gmsize; x++)
	   {
		   gauss_matrix[x+y*gmsize] = (TYPE_PIXELS)(gauss_matrix[x+y*gmsize]/summ
			   - (1.0 / (gmsize*gmsize)));
		   summa += gauss_matrix[x+y*gmsize];
	   }
   }

//   long pixcount=0; //stores 'how many pixel were calculated' information

   /* For each pixel that is above 'threshin' multiply surrounding
   pixels by corresponding 'gauss_matrix' values and store
   the summation in 'temp_pic' table (float) */

   for (y=radius; y < (size_y-radius) ; y++)
		for (x=radius; x < (size_x-radius) ; x++)
		{
			if ( picture[x+y*size_x] > threshin)
			{
				for (int j=0; j<gmsize; j++)
					for (int i=0; i<gmsize; i++)
					{
						temp_pic[x+y*size_x] +=
							picture[x-center+i+(y-center+j)*size_x]*gauss_matrix[i+j*gmsize];
					}
//					pixcount++;
			}
			else temp_pic[x+y*size_x] = (float)0.0;
		}

   i = 1;
   int border1 = border + 1;    // +1 because when searching for maksimum,
   // we use surrounding pixels

   ofstream fout;

   if(filename != NULL)
   {
	   fout.open( filename );
	   if (!fout)
		   return ELIBSTD_CANT_OPEN_FILE; //
	   fout<<"Lp.    X     Y          light      22-2.5log10(light)"<<endl<<endl;
   }

   //looking for stars (max. values), now is not very precise
   for (y=border1; y < size_y-border1; y++)
	   for (x=border1; x < size_x-border1; x++)
	   {
		   TYPE_PIXELS temp_p=temp_pic[x+y*size_x];
		   if(
			   (threshold < temp_p)
			   && (temp_pic[x-1+y*size_x] < temp_p)
			   && (temp_pic[x+1+y*size_x] < temp_p)
			   && (temp_pic[x+(y-1)*size_x] < temp_p)
			   && (temp_pic[x+(y+1)*size_x] < temp_p)
			   && (temp_pic[x+1+(y+1)*size_x] < temp_p)
			   && (temp_pic[x-1+(y+1)*size_x] < temp_p)
			   && (temp_pic[x-1+(y-1)*size_x] < temp_p)
			   && (temp_pic[x+1+(y-1)*size_x] < temp_p)
			   )
		   {
			   if(filename != NULL)
				   fout<<i<<"     "<< x <<"     "<< y <<"       "
				   <<temp_p<<"       "
				   <<(22-2.5*log10(temp_p))
				   <<endl;
			   i++;
		   }
	   }

   if(filename != NULL)
		   fout.close();

   return i-1;  //number of stars
}


void CBuffer::Fwhm2d(int x1, int y1, int x2, int y2,
                  double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
                  double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				  double fwhmx0, double fwhmy0)
{
   pix->Fwhm2d(x1, y1, x2, y2,
                  maxx, posx, fwhmx, fondx, errx,
                  maxy, posy, fwhmy, fondy, erry,
				      fwhmx0, fwhmy0);
}


//***************************************************
// unifybg                      
//                                         
// - decoupe l'image en fentres
// - calcule le fond de ciel pour chaque fenetre 
// - construit une matrice du fond du ciel pour chaque pixel
//   par interpolation entre les centres des rectangles
//
//***************************************************

void CBuffer::UnifyBg()
{
   pix->UnifyBg();
}



