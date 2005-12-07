/* cpixelsrgb.cpp
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

#include "math.h"
#include "libstd.h"
#include "cpixelsrgb.h"



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CPixelsRgb::CPixelsRgb()
{
   pix = NULL;


}

CPixelsRgb::~CPixelsRgb()
{
   if(pix) free(pix);
   pix = NULL;


}

CPixelsRgb::CPixelsRgb(TColorPlane plane, int width, int height, TPixelFormat pixelFormat, TPixelCompression compression, int pixels) 
{
   long size;
   long t, u, x, y, reverse;

   // Le fait de passer une hauteur negative permet de retourner l'image (cas des gif et autres)...
   if (height<0) {
      height = -height;
      reverse = 1;
   } else {
      reverse = 0;
   }

   naxis  = 3;
   naxis1 = width;
   naxis2 = height;

   size = naxis1*naxis2*naxis;
   pix = (TYPE_PIXELS_RGB*)malloc(size * sizeof(TYPE_PIXELS_RGB));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }


   if( pixels != NULL ) {
      t = size;
      
      switch (plane) {
      case PLANE_RGB :
         {
            switch( pixelFormat ) {
            case FORMAT_BYTE:
               {
                  unsigned char * pixelPtr = (unsigned char *) pixels;
                  TYPE_PIXELS_RGB * pixCur = pix;
                  if (reverse == 0) {
                     while(--t>=0) *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);               
                  } else {
                     for (u=0, y=height-1; y>=0; y--) {
                        t = width*y;
                        for (x=0;x<width;x++) {
                           *(pixCur+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                        }
                     }
                  }
               }
               break;
               
            case FORMAT_USHORT:
               {
                  unsigned short * pixelPtr = (unsigned short *) pixels;
                  TYPE_PIXELS_RGB * pixCur = pix;
                  if (reverse == 0) {
                     while(--t>=0) *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);               
                  } else {
                     for (u=0, y=height-1; y>=0; y--) {
                        t = width*y;
                        for (x=0;x<width;x++) {
                           *(pixCur+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                        }
                     }
                  }
               }
               break;
            case FORMAT_FLOAT: 
               {
                  TYPE_PIXELS     * pixelPtr = (float *) pixels;
                  TYPE_PIXELS_RGB * pixCur = pix;
                  if (reverse == 0) {
                     while(--t>=0) *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);               
                  } else {
                     for (u=0, y=height-1; y>=0; y--) {
                        t = width*y;
                        for (x=0;x<width;x++) {
                           *(pixCur+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                        }
                     }
                  }
               }
               break;
            default: 
               free(pix);
               throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
               break;            
            }
            
         }
         break;
         
      case PLANE_R :
         {
            switch( pixelFormat ) {
            case FORMAT_FLOAT: 
               {
                  TYPE_PIXELS     * pixelPtr = (float *) pixels;
                  TYPE_PIXELS_RGB * pixCur = pix;
                  if (reverse == 0) {
                     while(--t>=0) {
                        *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
                        pixelPtr++; // skip green element of pixel
                        pixelPtr++; // skip blue  element of pixel
                     }
                  } else {
                     for (u=0, y=height-1; y>=0; y--) {
                        t = width*y;
                        for (x=0;x<width;x++) {
                           *(pixCur+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                        }
                     }
                  }
               }
               break;
            default: 
               free(pix);
               throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
               break;            
            }
            
         }
         break;
         
      case PLANE_G :
         {
            switch( pixelFormat ) {
            case FORMAT_FLOAT: 
               {
                  TYPE_PIXELS     * pixelPtr = (float *) pixels;
                  TYPE_PIXELS_RGB * pixCur = pix;
                  if (reverse == 0) {
                     while(--t>=0) {
                        pixelPtr++; // skip red
                        *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
                        pixelPtr++; // skip blue
                     }
                  } else {
                     for (u=0, y=height-1; y>=0; y--) {
                        t = width*y;
                        for (x=0;x<width;x++) {
                           *(pixCur+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                        }
                     }
                  }
               }
               break;
            default: 
               free(pix);
               throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
               break;            
            }
            
         }
         break;
         
      case PLANE_B :
         {
            switch( pixelFormat ) {
            case FORMAT_FLOAT: 
               {
                  TYPE_PIXELS     * pixelPtr = (float *) pixels;
                  TYPE_PIXELS_RGB * pixCur = pix;
                  if (reverse == 0) {
                     while(--t>=0) {
                        pixelPtr++; // skip red
                        pixelPtr++; // skip green
                        *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
                     }
                  } else {
                     for (u=0, y=height-1; y>=0; y--) {
                        t = width*y;
                        for (x=0;x<width;x++) {
                           *(pixCur+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                        }
                     }
                  }
               }
               break;
            default: 
               free(pix);
               throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
               break;            
            }
            
         }
         break;
         
      default :
         throw CError(ELIBSTD_NOT_IMPLEMENTED);
         break;
   }
}
}
   


CPixelsRgb::CPixelsRgb(int width, int height, int pixelSize, int offset[4], int pitch, unsigned char * pixels)
{
   long size;
   long base;         
   long reverse = 0;
   

   if (height<0) {
      height = -height;
      reverse = 1;
   }

   naxis  = 3;
   naxis1 = width;
   naxis2 = height;

   size = naxis1*naxis2*naxis;
   pix = (TYPE_PIXELS_RGB*)malloc(size * sizeof(TYPE_PIXELS_RGB));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }
   
   if( pixels != NULL ) {
      if( pixelSize == 3 && offset[0] == 0 &&  offset[1] == 1 && offset[2] == 2 ) {
         // si les octets sont déjà ordonnés , je copie le buffer
         memcpy(pix, pixels, size );
      } else if ( pixelSize == 3 || pixelSize == 4 ) {
         int x, y; 
         TYPE_PIXELS_RGB *pix2 = pix; 
         
         if (reverse = 0) {
            for(y=0;y<naxis2;y++) {
               for(x=0;x<naxis1;x++) {
                  //base=pixelSize*((naxis2-y-1)*naxis1+x);
                  base=(y*naxis1+x)*pixelSize;
                  *(pix2++) =pixels[base+offset[0]];
                  *(pix2++) =pixels[base+offset[1]];
                  *(pix2++) =pixels[base+offset[2]];
               }
            }
         } else {
            for(y=0;y<naxis2;y++) {
               for(x=0;x<naxis1;x++) {
                  base=pixelSize*((naxis2-y-1)*naxis1+x);
                  //base=(y*naxis1+x)*pixelSize;
                  *(pix2++) =pixels[base+offset[0]];
                  *(pix2++) =pixels[base+offset[1]];
                  *(pix2++) =pixels[base+offset[2]];
               }
            }
         }
         
      } else {
         // non implemente pour 2 couleurs
         free(pix);
         throw CError(ELIBSTD_NOT_IMPLEMENTED);
      }
   } else {
      // si les valeurs de pixels ne sont pas fournies , je mets tout à zero
      int t = size;
      while(--t>0) *(pix+t) = 0;
   }
   
}


CPixelsRgb::CPixelsRgb(int width, int height, TYPE_PIXELS_RGB *pixelsR, TYPE_PIXELS_RGB *pixelsG, TYPE_PIXELS_RGB *pixelsB) {
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   long size;
   long t;

   if( pixelsR == NULL || pixelsG==NULL || pixelsB == NULL ) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   naxis  = 3;
   naxis1 = width;
   naxis2 = height;

   size = naxis1*naxis2*naxis;
   pix = (TYPE_PIXELS_RGB*)malloc(size * sizeof(TYPE_PIXELS_RGB));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   pixCurR = pixelsR;
   pixCurG = pixelsG;
   pixCurB = pixelsB;
   pixCur = pix;

   t =  naxis1*naxis2;
   while(--t>0) {
      *(pixCur++) = *(pixCurR++);
      *(pixCur++) = *(pixCurG++);
      *(pixCur++) = *(pixCurB++);
   }
}


void CPixelsRgb::Add(char *filename, float offset)
{
   int msg;
   int datatype;
   char s[512];
   int t;
   
   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   
   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      
      // je recupere l'image a traiter en séparant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB); 
      
      datatype = TFLOAT;
      sprintf(s,"ADD \"file=%s\" offset=%f",filename,offset);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      
      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }      
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);
   } catch (const CError& e) {
      // je libere la memoire reservee avant l'arrivée de l'erreur
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      throw e;
   }
}

/** 
 *  Autocut
 *
 *  retourne les seuils par défaut d'un image couleur 
 *    valeur fixe en première approximation.
 */ 
void CPixelsRgb::Autocut(double *phicut,double *plocut,double *pmode)
{
   *plocut =-1;
   *phicut =256;
   *pmode =0;
}

void CPixelsRgb::BinX(int x1, int x2, int width)
{

   throw CError(ELIBSTD_NOT_IMPLEMENTED);
 }

void CPixelsRgb::BinY(int y1, int y2, int height)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);

   /*
   int temp;
   int x, y;
   TYPE_PIXELS value;
   TYPE_PIXELS *out;

   if (height < 0)
   {
         return ELIBSTD_HEIGHT_POSITIVE;

   } 
   if ((y1 < 0) || (y2 < 0) || (y1 > naxis2-1) || (y2 > naxis2-1))
   {
         return ELIBSTD_Y1Y2_NOT_IN_1NAXIS2;
   } 

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } 

   out = (TYPE_PIXELS*)calloc(naxis1*height,sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      return ELIBSTD_NO_MEMORY_FOR_PIXELS;
   }

   // bining 
   for(x = 0; x < naxis1;x++)
   {
       value = (float)0;
       for(y=y1;y<=y2;y++)
       {
          value += pix[x+y*naxis1];
       } 
       for(y=0;y<height;y++)
       {
          out[x+y*naxis1]=value;
       } 
   } 


   naxis1 = naxis1;
   naxis2 = height; 

   //CreateBuffer(w,height);
   //memcpy(pix,out,w*height*sizeof(TYPE_PIXELS));
   //result = SetPixels( naxis1, height, FORMAT_FLOAT, COMPRESS_NONE, (int) out);
   free(pix);
   pix = out;
   return 0;
   */
}


void CPixelsRgb::Clipmin(double value)
{
   int nelem,k;
   unsigned char value2;

   value2 = (unsigned char) value;

   nelem=naxis1*naxis2*naxis;

   for (k=0;k<nelem;k++) {
      if( pix[k]<value) {
         pix[k]= (unsigned char) value;
      }
   }
}

void CPixelsRgb::Clipmax(double value)
{
   int nelem,k;
   unsigned char value2;

   value2 = (unsigned char) value;
   nelem=naxis1*naxis2*naxis;

   for (k=0;k<nelem;k++) {
      if (pix[k]>value) {
         pix[k]=(unsigned char) value;
      }
   }
}

void CPixelsRgb::Div(char *filename, float constante)
{
   int msg;
   int datatype;
   char s[512];
   int t;

   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   
   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      
      // je recupere l'image a traiter en séparant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB); 
      
      datatype = TFLOAT;
      sprintf(s,"DIV \"file=%s\" constant=%f",filename,constante);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      
      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }      
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);
   } catch (const CError& e) {
      // je libere cla memoire attribuée avant l'arrivée de l'erreur
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      throw e;
   }
}


TPixelClass CPixelsRgb::getPixelClass() {
   return CLASS_RGB;
}

int CPixelsRgb::GetHeight(void) {
   return naxis2;
}

//void CPixelsRgb::GetPixels(TYPE_PIXELS **pixels) {
//   throw CError(ELIBSTD_NOT_IMPLEMENTED);
// 
//}

void CPixelsRgb::GetPixels(int x1, int y1, int x2, int y2 , TPixelFormat pixelFormat, TColorPlane plane, int pixels) {
   int x, y;
   int width  = x2-x1+1;
   TYPE_PIXELS_RGB  *ptr;

   switch( pixelFormat ) {
   case FORMAT_BYTE:
      {
         unsigned char * out = (unsigned char *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char)(( (float) *(ptr++) + (float) *(ptr++) + (float) *(ptr++))/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         }
      }
      break;
   case FORMAT_USHORT:
      {
         unsigned short * out = (unsigned short *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  ptr++;   // skip G
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short)(( (float) *(ptr++) + (float) *(ptr++) + (float) *(ptr++))/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         }
      }
      break;
   case FORMAT_FLOAT: 
      {
         float * out = (float *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (float) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float)(( (float) *(ptr++) + (float) *(ptr++) + (float) *(ptr++))/naxis);
                  // *(out++) = (unsigned char)sqrt( (((float)ptr[0] * (float)ptr[0]) + ((float)ptr[1] * (float)ptr[1]) + ((float)ptr[2] * (float)ptr[2]))/3);
                  // ptr += 3;
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         }
      break;
      }
   default: 
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
      break;
      
   }
   


}


void CPixelsRgb::GetPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, int pixels) {
   int x, y;
   int width  = x2-x1+1;
   TYPE_PIXELS_RGB  *ptr;

   switch( pixelFormat ) {
   case FORMAT_BYTE:
      {
         unsigned char * out = (unsigned char *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char)(( (float) *(ptr++) + (float) *(ptr++) + (float) *(ptr++))/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         }
      }
      break;
   case FORMAT_USHORT:
      {
         unsigned short * out = (unsigned short *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  ptr++;   // skip G
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short)(( (float) *(ptr++) + (float) *(ptr++) + (float) *(ptr++))/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         }
      }
      break;
   case FORMAT_FLOAT: 
      {
         float * out = (float *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (float) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);               
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float)(( (float) *(ptr++) + (float) *(ptr++) + (float) *(ptr++))/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         }
      break;
      }
   default: 
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
      break;
      
   }
}


void CPixelsRgb::GetPixels(TYPE_PIXELS_RGB *pixelsR, TYPE_PIXELS_RGB *pixelsG, TYPE_PIXELS_RGB *pixelsB) {
   TYPE_PIXELS_RGB *pixCurR = NULL, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   long t;

   // copie les 3 plans dans trois tableaux
   pixCurR = pixelsR;
   pixCurG = pixelsG;
   pixCurB = pixelsB;
   pixCur = pix;
   t =  naxis1*naxis2;
   while(--t>0) {
      *(pixCurR++) = *(pixCur++);
      *(pixCurG++) = *(pixCur++);
      *(pixCurB++) = *(pixCur++);
   }
}

/* 
 * GetPixGray
 * retourne la somme des 3 couleurs du pixel
 */

void CPixelsRgb::GetPixGray(TYPE_PIXELS *val,int x, int y)
{
   TYPE_PIXELS_RGB * ptr;

   if((x<0)||(x>=naxis1)) {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } else if ((y<0)||(y>=naxis2)) {
      throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }
   //  position des couleur du pixel (x,y): ptr = (y*naxis1+x)*3 + offset
   ptr = pix + (y*naxis1+x)*naxis;
   *val = ((float) *(ptr + 0) + (float) *(ptr + 1) + (float) *(ptr +2))/naxis;
}

/** 
  retourne le pointeur du tableau interne de pixels
  Non implemente pour les pixelzs RGB
*/
void CPixelsRgb::GetPixelsPointer(TYPE_PIXELS **pixels) {
      throw CError(ELIBSTD_NOT_IMPLEMENTED);
}

/*
void CPixelsRgb::GetPixelsZoom( int x1,int y1,int x2, int y2, double zoom, 
            double hicut, double locut, Pal_Struct *pal, unsigned char *ptr) 
{
   TYPE_PIXELS_RGB *ppix;
   int i, j;
   int m, n;
   int ww, wh;              // window width, height multiplied by zoom
   int xx1, yy1, xx2, yy2;  // window coordinates
   int orgw, orgh, orgww, orgwh;        // original window width, height
   float dyn;
   float fsh = (float)hicut;
   float fsb = (float)locut;
   int tzoom;
   int ii,jj;
   long base;

   xx1 = x1;
   yy1 = y1;
   xx2 = x2;
   yy2 = y2;
   orgw = naxis1;
   orgh = naxis2;

   orgww = xx2 - xx1 + 1; // Largeur de la fenetre au depart
   orgwh = yy2 - yy1 + 1; // Hauteur ...
   if (zoom>0) {
      ww = (int)ceil(zoom * orgww);     // Largeur de la fenetre a l'arrivee, en pixels unitaires
      wh = (int)ceil(zoom * orgwh);     // Hauteur ...
   } else {
      ww=1;
      wh=1;
   }

   if(fsh==fsb) {
      fsb -= (float)1e-1;
   }
   dyn = (float)256. / (fsh - fsb);

   if(zoom==1) {
      for(j=yy1;j<=yy2;j++) {
         for(i=xx1;i<=xx2;i++) {
            base = ((naxis2-j-1)*naxis1+i)*naxis;
            *ptr++ = (pal->pal)[0][(unsigned char)min(max(((float)pix[base+0]-fsb)*dyn,0),255)];
            *ptr++ = (pal->pal)[1][(unsigned char)min(max(((float)pix[base+1]-fsb)*dyn,0),255)];
            *ptr++ = (pal->pal)[2][(unsigned char)min(max(((float)pix[base+2]-fsb)*dyn,0),255)];
         }
      }
   } else if (zoom>1) {
      tzoom=(int)zoom;
      ppix = pix + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j++) {
         for(n=0;n<tzoom;n++) {
            for(i=xx1;i<=xx2;i++) {
               base = (j*naxis1+i)*naxis;
               for(m=0;m<tzoom;m++) {
                  *ptr++ = (pal->pal)[0][(unsigned char)min(max(((float)pix[base+0]-fsb)*dyn,0),255)];
                  *ptr++ = (pal->pal)[1][(unsigned char)min(max(((float)pix[base+1]-fsb)*dyn,0),255)];
                  *ptr++ = (pal->pal)[2][(unsigned char)min(max(((float)pix[base+2]-fsb)*dyn,0),255)];
               }
            }
         }
      }
   } else {
      tzoom=(int)(1./zoom);
      for(j=yy1,jj=0;j<=yy2;j+=tzoom,jj++) {
         for(i=xx1,ii=0;i<=xx2;i+=tzoom,ii++) {
            base = (j*naxis1+i)*naxis;
            *ptr++ = (pal->pal)[0][(unsigned char)min(max(((float)pix[base+0]-fsb)*dyn,0),255)];
            *ptr++ = (pal->pal)[1][(unsigned char)min(max(((float)pix[base+1]-fsb)*dyn,0),255)];
            *ptr++ = (pal->pal)[2][(unsigned char)min(max(((float)pix[base+2]-fsb)*dyn,0),255)];
         }
      }
   }
   
}
*/

void CPixelsRgb::GetPixelsZoom( int x1,int y1,int x2, int y2, double zoom, 
            double hicutRed,   double locutRed, 
            double hicutGreen, double locutGreen,
            double hicutBlue,  double locutBlue,
            Pal_Struct *pal, unsigned char *ptr) 
{
   TYPE_PIXELS_RGB *ppix;
   int i, j;
   int m, n;
   int ww, wh;              // window width, height multiplied by zoom
   int xx1, yy1, xx2, yy2;  // window coordinates
   int orgw, orgh, orgww, orgwh;        // original window width, height
   float dynRed, dynGreen, dynBlue;
   float fshRed = (float)hicutRed;
   float fsbRed = (float)locutRed;
   float fshGreen = (float)hicutGreen;
   float fsbGreen = (float)locutGreen;
   float fshBlue = (float)hicutBlue;
   float fsbBlue = (float)locutBlue;
   int tzoom;
   int ii,jj;
   long base;

   xx1 = x1;
   yy1 = y1;
   xx2 = x2;
   yy2 = y2;
   orgw = naxis1;
   orgh = naxis2;

   orgww = xx2 - xx1 + 1; // Largeur de la fenetre au depart
   orgwh = yy2 - yy1 + 1; // Hauteur ...
   if (zoom>0) {
      ww = (int)ceil(zoom * orgww);     // Largeur de la fenetre a l'arrivee, en pixels unitaires
      wh = (int)ceil(zoom * orgwh);     // Hauteur ...
   } else {
      ww=1;
      wh=1;
   }


   if(fshRed==fsbRed) { fsbRed -= (float)1e-1; }
   dynRed = (float)256. / (fshRed - fsbRed);
   if(fshGreen==fsbGreen) { fsbGreen -= (float)1e-1; }
   dynGreen = (float)256. / (fshGreen - fsbGreen);
   if(fshBlue==fsbBlue) { fsbBlue -= (float)1e-1; }
   dynBlue = (float)256. / (fshBlue - fsbBlue);

   if(zoom==1) {
      for(j=yy1;j<=yy2;j++) {
         for(i=xx1;i<=xx2;i++) {
            base = ((naxis2-j-1)*naxis1+i)*naxis;
            *ptr++ = (pal->pal)[0][(unsigned char)min(max(((float)pix[base+0]-fsbRed)*dynRed,0),255)];
            *ptr++ = (pal->pal)[1][(unsigned char)min(max(((float)pix[base+1]-fsbGreen)*dynGreen,0),255)];
            *ptr++ = (pal->pal)[2][(unsigned char)min(max(((float)pix[base+2]-fsbBlue)*dynBlue,0),255)];
         }
      }
   } else if (zoom>1) {
      tzoom=(int)zoom;
      ppix = pix + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j++) {
         for(n=0;n<tzoom;n++) {
            for(i=xx1;i<=xx2;i++) {
               base = (j*naxis1+i)*naxis;
               for(m=0;m<tzoom;m++) {
                  *ptr++ = (pal->pal)[0][(unsigned char)min(max(((float)pix[base+0]-fsbRed)*dynRed,0),255)];
                  *ptr++ = (pal->pal)[1][(unsigned char)min(max(((float)pix[base+1]-fsbGreen)*dynGreen,0),255)];
                  *ptr++ = (pal->pal)[2][(unsigned char)min(max(((float)pix[base+2]-fsbBlue)*dynBlue,0),255)];
               }
            }
         }
      }
   } else {
      tzoom=(int)(1./zoom);
      for(j=yy1,jj=0;j<=yy2;j+=tzoom,jj++) {
         for(i=xx1,ii=0;i<=xx2;i+=tzoom,ii++) {
            base = (j*naxis1+i)*naxis;
            *ptr++ = (pal->pal)[0][(unsigned char)min(max(((float)pix[base+0]-fsbRed)*dynRed,0),255)];
            *ptr++ = (pal->pal)[1][(unsigned char)min(max(((float)pix[base+1]-fsbGreen)*dynGreen,0),255)];
            *ptr++ = (pal->pal)[2][(unsigned char)min(max(((float)pix[base+2]-fsbBlue)*dynBlue,0),255)];
         }
      }
   }
   
}

int CPixelsRgb::GetWidth(void) {
   return naxis1;
}

int CPixelsRgb::GetPlanes(void) {
   return naxis;
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
 *    verifie si une image est chargée c.a.d si la taille est superieure a 1x1
 *----------------------------------------------------------------------
 */
int CPixelsRgb::IsPixelsReady(void) {
   if( naxis1 != 1 && naxis2 != 1 ) {
      return 1;
   } else {
      return 0;
   }
}


void CPixelsRgb::Log(float coef, float offset)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg,datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"LOG coeff=%f offsetlog=%f",coef,offset);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::MergePixels(TColorPlane plane, int pixels)
{
   long t;
   
   t = naxis1*naxis2;

   switch (plane) {
      
      case PLANE_R :
      {
         TYPE_PIXELS     * pixelPtr = (float *) pixels;
         TYPE_PIXELS_RGB * pixCur = pix;
         while(--t>=0) {
            *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
            pixCur++; // skip green element of pixel
            pixCur++; // skip blue  element of pixel
         }
         
      }
      break;
      
      case PLANE_G :
      {
         TYPE_PIXELS     * pixelPtr = (float *) pixels;
         TYPE_PIXELS_RGB * pixCur = pix;
         while(--t>=0) {
            pixCur++; // skip red
            *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
            pixCur++; // skip blue
         }
         break;
      }
      break;
      
      case PLANE_B :
      {
         TYPE_PIXELS     * pixelPtr = (float *) pixels;
         TYPE_PIXELS_RGB * pixCur = pix;
         while(--t>=0) {
            pixCur++; // skip red
            pixCur++; // skip green
            *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
         }
      }
      break;
      
   
      default :
      {
         throw CError(ELIBSTD_NOT_IMPLEMENTED);
      }
      break;
   }
}
   

void CPixelsRgb::MirX()
{
   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[32];
   int t;
   
   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      
      // je recupere l'image a traiter en séparant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB); 
      
      // mirroir
      datatype = TFLOAT;
      strcpy(s,"INVERT mirror");
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      
      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      throw e;
   }
}


void CPixelsRgb::MirY()
{
   TYPE_PIXELS_RGB *pixelsR = NULL;
   TYPE_PIXELS_RGB *pixelsG = NULL;
   TYPE_PIXELS_RGB *pixelsB = NULL;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[32];
   int t;
   
   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      
      // je recupere l'image a traiter en séparant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB); 
            
      // mirroir
      datatype = TFLOAT;
      strcpy(s,"INVERT flip");
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      
      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      // je libere la mémoire
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      // je transmets l'exception
      throw e;
   }

}


void CPixelsRgb::NGain(float gain)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg;
   char *s;
   int datatype;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"NORMGAIN normgain_value=%f",gain);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::NOffset(float offset)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, naxis1, naxis2, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"NORMOFFSET normoffset_value=%f",offset);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::Offset(float offset)
{
   
   int datatype;
   char *s;

   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   
   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"OFFSET offset=%f",offset);

   delete s;
}

void CPixelsRgb::Opt(char *dark, char *offset)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[256];
   sprintf(s,"OPT dark=%s bias=%s",dark,offset);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::Rot(float x0, float y0, float angle)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"ROT x0=%f y0=%f angle=%f",x0,y0,angle);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

/*
 * SetPix
 *  Affecte la valeur du pixel aux coordonnees passes en parametres.
 *  Les valeurs des coordonnees vont de (0,0) a (NAXIS1-1,NAXIS2-1).
 *  La valeur de retour est :
 *    - '1'  si pas de pixels (pix=NULL)
 *    - '-1' si pas de mots-cles
 *    - '-2' si pas de mot-cle 'NAXIS1'
 *
 */
void CPixelsRgb::SetPix(TYPE_PIXELS val,int x, int y)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);

/*
   if((x<0)||(x>=naxis1)) {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } else if ((y<0)||(y>=naxis2)) {
      throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }
   *(pix+y*naxis1+x+0) = (unsigned char)  val;
   *(pix+y*naxis1+x+1) = (unsigned char)  val;
   *(pix+y*naxis1+x+2) = (unsigned char)  val;
*/
}


void CPixelsRgb::Sub(char *filename, float offset)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, naxis1, naxis2, datatype;
   char *s;

   if(pix==NULL) {return ELIBSTD_BUF_EMPTY;}

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"SUB \"file=%s\" offset=%f",filename,offset);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */

   /*
       TYPE_PIXELS_RGB *pixelsR = NULL;
   TYPE_PIXELS_RGB *pixelsG = NULL;
   TYPE_PIXELS_RGB *pixelsB = NULL;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[32];
   int t;
   

    try {
      pixelsR = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      
      // je recupere l'image a traiter en séparant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB); 
            
      // mirroir
      datatype = TFLOAT;
      strcpy(s,"SUB \"file=%s\" offset=%f");
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      
      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      // je libere la mémoire
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      // je transmets l'exception
      throw e;
   }
   */
}

CPixels * CPixelsRgb::TtImaSeries(char *s,int *nb_keys,char ***pkeynames,char ***pkeyvalues,
                                 char ***pcomments,char ***punits, int **pdatatypes)
{
   TYPE_PIXELS_RGB *pixInR = NULL;
   TYPE_PIXELS_RGB *pixInG = NULL;
   TYPE_PIXELS_RGB *pixInB = NULL;
   TYPE_PIXELS_RGB *pixOutR = NULL;
   TYPE_PIXELS_RGB *pixOutG = NULL;
   TYPE_PIXELS_RGB *pixOutB = NULL;
   int msg, datatype;
   int width, height;
   CPixels * newPixels;
   
   try {
      pixInR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixInG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixInB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      
      // je recupere l'image a traiter en séparant les 3 plans
      GetPixels( pixInR, pixInG, pixInB); 
            
      // traitement
      datatype = TFLOAT;      
      width  = naxis1;
      height = naxis2;      
      msg = Libtt_main(TT_PTR_IMASERIES,13,&pixInR,&datatype,&width,&height,&pixOutR,&datatype,s,
               nb_keys,pkeynames,pkeyvalues,pcomments,punits,pdatatypes);
      if(msg) throw CErrorLibtt(msg);
      width  = naxis1;
      height = naxis2;
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixInG,&datatype,&width,&height,&pixOutG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      width  = naxis1;
      height = naxis2;
      msg = Libtt_main(TT_PTR_IMASERIES,7,&pixInB,&datatype,&width,&height,&pixOutB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // nouvelle taille en sortie du traitement
      naxis1 = width;
      naxis2 = height;
      // j'enregistre la nouvelle image
      newPixels = new CPixelsRgb( naxis1, naxis2, pixOutR, pixOutG, pixOutB);            
      free(pixInR);
      free(pixInG);
      free(pixInB);
      Libtt_main(TT_PTR_FREEPTR,1,&pixOutR);
      Libtt_main(TT_PTR_FREEPTR,1,&pixOutG);
      Libtt_main(TT_PTR_FREEPTR,1,&pixOutB);
      return newPixels;
      
   } catch (const CError& e) {
      // je libere la mémoire
      if(pixInR) free(pixInR);
      if(pixInG) free(pixInG);
      if(pixInB) free(pixInB);
      Libtt_main(TT_PTR_FREEPTR,1,&pixOutR);
      Libtt_main(TT_PTR_FREEPTR,1,&pixOutG);
      Libtt_main(TT_PTR_FREEPTR,1,&pixOutB);
      // je transmets l'exception
      throw e;
   }

 
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

void  CPixelsRgb::UnifyBg()
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg;                         // Code erreur de libtt
   int i, j, x, y, x1, y1, x2, y2, xc, xc1, xc2, yc, yc1, yc2;
   TYPE_PIXELS  *pixel, val;
   int wRect, hRect, naxis11, naxis22;
   int datatype;
   int nbCol = 10;   // nombre de rectanglex horizontaux
   int nbLine = 10;   // nombre de rectangles verticaux

   double *matbg, a ,b , v1, v2;
   double dlocut, dhicut, dmaxi, dmini, dmean, dsigma, dbgmean,dbgsigma,dcontrast;
   double sumBgmean=0;
   double nbBgmean=0;
   double meanBgmean;
   int *columns, *lines, colIndex, lineIndex;


   // je calcule la taille des fenetres
   wRect = naxis1 / nbCol;
   if ( wRect < 50 ) wRect = 50;
   hRect = naxis2 / nbLine;
   if ( hRect < 50 ) hRect = 50;

   // je cree la matrice du fond de ciel
   matbg = (double*)calloc(naxis1*naxis2,sizeof(double));
   // raz matrice
   for(x=0; x < naxis1 ; x++) {
      for(y=0; y < naxis2 ; y++) {
         matbg[y*naxis1+ x] = 0;
      }
   }

   // lines des centres des fenetres 
   lines = (int*)calloc(nbLine,sizeof(int));
   
   // columns des centres des fenetres
   columns = (int*)calloc(nbCol,sizeof(int));
   

   // -----------------------------------------------------------
   // je calcule le fond du ciel de chaque fenetre (x,y)(x+wRect,y+hRect)
   // -----------------------------------------------------------
   colIndex=0;
   for(x1=0; x1 < naxis1 ; x1 +=wRect) {
      lineIndex=0;
      for(y1=0; y1 < naxis2 ; y1 +=hRect) {
      
         // calcul de coordonnées de la fenetre
         if( x1 + wRect < naxis1) {
            x2 = x1 + wRect;
         } else {
            // cas du dernier rectangle à droite
            x2 = naxis1-1;
         }
         if( y1 + hRect < naxis2) {
            y2 = y1 + hRect;
         } else {
            // cas du dernier rectangle en bas
            y2 = naxis2-1;
         }

         // calcul des coord. du centre de la fenetre
         xc = (x2-x1)/2 +x1;
         yc = (y2-y1)/2 +y1;
        
         // je copie les pixels de la fenetre 
         naxis11 = x2-x1+1;
         naxis22 = y2-y1+1;
         pixel = (TYPE_PIXELS*)calloc(naxis11*naxis22,sizeof(TYPE_PIXELS));
         for(j=y1;j<=y2;j++) {
            for(i=x1;i<=x2;i++) {
               *(pixel+naxis11*(j-y1)+(i-x1)) = *(pix+naxis1*j+i);
            }
         }
         // je calcule le fond du ciel
         datatype = TFLOAT;
         msg = Libtt_main(TT_PTR_STATIMA,13,pixel,&datatype,&naxis11,&naxis22,
                  &dlocut,&dhicut,&dmaxi,&dmini,&dmean,&dsigma,&dbgmean,&dbgsigma,&dcontrast);
         free(pixel);
         if(msg) {
            return msg;
         }

         // je place la valeur du fond du ciel dans le pixel au centre du rectangle
         matbg[yc*naxis1+ xc ] = dbgmean;

         // je cumule les nbgmean pour calculer la moyenne globale plus tard
         sumBgmean +=dbgmean;
         nbBgmean++;

         // je memorise les coordonnées du centre le fenetre
         columns[colIndex]= xc;
         lines[lineIndex] = yc;

         lineIndex++;

         //logInfo("1 x1=%d y1=%d x2=%d y2=%d bg=%f", x1, y1, x2, y2, dbgmean);

      }
      
      colIndex++;
   }

   nbCol = colIndex;
   nbLine = lineIndex;
   //logInfo("nbCol=%d nbLine=%d", nbCol, nbLine);

   // -----------------------------------------------------------
   // je calcule le fond du ciel pour les points intermédiaires
   // -----------------------------------------------------------

   // calcul des columns
   for(colIndex=0; colIndex<nbCol; colIndex++) {
      xc = columns[colIndex];
      for(lineIndex=0; lineIndex<nbLine-1; lineIndex++ ) {

         // je recupere les coordonness des deux points pour calculer la droite
         yc1 = lines[lineIndex];
         yc2 = lines[lineIndex+1];

         // je calcule les coefs de la droite de regression v = ay +b
         // la doite passe par les 2 points (yc1,v1) et (yc2, v2)
         v1 = matbg[yc1*naxis1+ xc ];
         v2 = matbg[yc2*naxis1+ xc ];
         a = (v2 - v1)/(yc2 - yc1);
         b = v1 - a * yc1;
 
         // je calcule les bornes de la droite de regression  y1, y2
         if(lineIndex == 0 ) {
            y1 = 0 ;          // première fenetre en haut
         } else {
            y1 = yc1;
         }
         if(lineIndex >= nbLine - 2 ) {
            y2 = naxis2 ;   // deniere fenetre en bas
         } else {
            y2 = yc2;          
         }
         
         // je calcule les points entre les deux bornes 
         for( y = y1; y < y2 ; y++) {
            matbg[y*naxis1+ xc ]  = a * y + b; 
         }

         //logInfo("col xc=%d yc1=%d yc2=%d y1=%d y2=%d", xc, yc1, yc2, y1, y2);
      }
   }
                 
   
   //  calcul des lignes
   for(yc=0; yc<naxis2; yc++ ) {
      for(colIndex=0; colIndex<nbCol-1; colIndex++) {
         
         // je recupere les coordonness des deux points pour calculer la droite
         xc1 = columns[colIndex];
         xc2 = columns[colIndex+1];
      
         // je calcule les coefs de la droite de regression v = ax +b
         // la doite passe par les 2 points (xc1,v1) et (xc2, v2)
         v1 = matbg[yc*naxis1+ xc1 ];
         v2 = matbg[yc*naxis1+ xc2 ];
         a = (v2 - v1)/(xc2 - xc1);
         b = v1 - a*xc1;
 
         // je calcule les bornes de la droite de regression  x1, x2
         if(colIndex == 0 ) {
            x1 = 0 ;          // première fenetre a gauche
         } else {
            x1 = xc1;
         }
         if(colIndex == nbCol -2 ) {
            x2 = naxis1;   // deniere fenetre a droite
         } else {
            x2 = xc2;          
         }
         
         for( x = x1; x < x2 ; x++) {
            matbg[yc*naxis1+ x ]  = a * x + b; 
         }
         //logInfo("line yc=%d xc1=%d xc2=%d x1=%d x2=%d v1=%f v2=%f", yc, xc1, xc2, x1, x2, v1, v2);
      }
   }

   // je calcule la moyenne globale du fond du ciel
   meanBgmean = sumBgmean / nbBgmean;

   // -----------------------------------------------------------
   // je soustrait le fond du ciel à l'image originale
   // -----------------------------------------------------------
   for(x=0; x < naxis1 ; x++) {
      for(y=0; y < naxis2 ; y++) {
         float ppix, pbg;
         ppix = *(pix+naxis1*y+x);
         pbg = (float) matbg[y*naxis1+ x];
         val = (float) ( ppix - pbg + meanBgmean) ;
         if ( val<0 ) val = 0;
         *(pix+naxis1*y+x) = val;
      }
   }

   return 0;
   */
}


void CPixelsRgb::Unsmear(float coef)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"UNSMEARING unsmearing=%f",coef);
   msg = Libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::Window(int x1, int y1, int x2, int y2)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int temp;
   int x, y, diff_x, diff_y;
   TYPE_PIXELS *out;

   if ((x1 < 0) || (x2 < 0) || (x1 > naxis1-1) || (x2 > naxis1-1))
   {
         return ELIBSTD_X1X2_NOT_IN_1NAXIS1;
   } 
   if ((y1 < 0) || (y2 < 0) || (y1 > naxis2-1) || (y2 > naxis2-1))
   {
         return ELIBSTD_Y1Y2_NOT_IN_1NAXIS2;
   } 

   if(x1 > x2)
   {
       temp = x1;
       x1 = x2;
       x2 = temp;
   }

   if(y1 > y2)
   {
       temp = y1;
       y1 = y2;
       y2 = temp;
   }

   diff_x = x2 - x1 + 1;
   diff_y = y2 - y1 + 1;

   // --- initialisation ---
   out = (TYPE_PIXELS*)calloc(diff_x*diff_y,sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      return ELIBSTD_NO_MEMORY_FOR_PIXELS;
   }

   // window 
   for(x = 0; x < diff_x;x++)
   {
       for(y = 0;y < diff_y;y++)
       {
         out[x + y * diff_x] =  pix[(x1 + x) + (y1 + y) * naxis1];
       } 
   } 

   naxis1 = diff_x;
   naxis2 = diff_y; 
   //memcpy(pix,out,diff_x*diff_y*sizeof(TYPE_PIXELS));
   free(pix);
   pix = out;
   return 0;
   */
}


