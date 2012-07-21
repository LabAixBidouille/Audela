/* cpixels.h
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
#ifndef __CPIXELSH__
#define __CPIXELSH__

#include "cdevice.h"
#include "libstd.h"
#include "cpixels.h"
#include "palette.h"
#include "cerror.h"

typedef float TYPE_PIXELS;

typedef enum { CLASS_GRAY, CLASS_RGB, CLASS_3D, CLASS_VIDEO, CLASS_UNKNOWN} TPixelClass;
typedef enum { FORMAT_BYTE, FORMAT_USHORT, FORMAT_FLOAT, FORMAT_UNKNOWN} TPixelFormat;
typedef enum { COMPRESS_NONE, COMPRESS_RGB, COMPRESS_I420, COMPRESS_UNKNOWN} TPixelCompression;
typedef enum { PLANE_GREY, PLANE_RGB, PLANE_R, PLANE_G, PLANE_B, PLANE_UNKNOWN} TColorPlane;

class CPixels 
{
public:
   virtual ~CPixels();
   virtual void Add(char *filename, float offset)=0;
   void AstroBaricenter(int x1, int y1, int x2, int y2, double *xc, double *yc);
   void AstroCentro(int x1, int y1, int x2, int y2, int xmax, int ymax,
                     TYPE_PIXELS seuil,float* sx, float* sy, float* r);
   void AstroFlux(int x1, int y1, int x2, int y2, 
                     TYPE_PIXELS* flux, TYPE_PIXELS* maxi, int *xmax, int* ymax, 
                     TYPE_PIXELS *moy, TYPE_PIXELS *seuil);
   void AstroPhoto(int x1, int y1, int x2, int y2, int xmax, int ymax, 
                     TYPE_PIXELS moy, double *dFlux, int* ntot);
   void AstroPhotometry(int x1, int y1, int x2, int y2, int method, double r1, double r2,double r3, 
                      double *flux, double* f23, double* fmoy, double* sigma, int *n1);
   virtual void Autocut(double *phicut,double *plocut,double *pmode)=0;
   virtual void BinX(int x1, int x2, int width)=0;
   virtual void BinY(int y1, int y2, int height)=0;
   virtual void Clipmax(double value)=0;
   virtual void Clipmin(double value)=0;
   virtual void Div(char *filename, float constante)=0;
   void Fwhm(int x1, int y1, int x2, int y2,
              double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
              double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				  double fwhmx0, double fwhmy0);
   void Fwhm2d(int x1, int y1, int x2, int y2,
               double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
               double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				   double fwhmx0, double fwhmy0);
   virtual int  GetHeight(void)=0;
   virtual int  GetPlanes(void)=0;
   virtual int  GetWidth(void)=0;
   virtual void GetPixGray(TYPE_PIXELS *val,int x, int y)=0;
   virtual void GetPixelsPointer(TYPE_PIXELS **pixels)=0;
   virtual void GetPixels(int x1, int x2, int y1, int y2, TPixelFormat pixelFormat, TColorPlane plane,int pixels)=0;
   virtual void GetPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, int pixels)=0;
   virtual void GetPixelsZoom( int x1,int y1,int x2, int y2, double zoom, 
                  double hicutRed,   double locutRed, 
                  double hicutGreen, double locutGreen,
                  double hicutBlue,  double locutBlue,
                  Pal_Struct *pal, unsigned char *ptr)=0;
   void         Histogram(int n, float *adus, float *meanadus, long *histo,
                          int ismini,float mini,int ismaxi,float maxi);
   virtual int  IsPixelsReady(void)=0;
   virtual void Log(float coef, float offset)=0;
   virtual void MergePixels(TColorPlane plane, int pixels)=0;
   virtual void MirX()=0;
   virtual void MirY()=0;
   virtual void NGain(float gain)=0;
   virtual void NOffset(float offset)=0;
   virtual void Offset(float offset)=0;
   virtual void Opt(char *dark, char *offset)=0;
   virtual void Rot(float x0, float y0, float angle)=0;
   virtual void SetPix(TYPE_PIXELS val,int x, int y)=0;
   virtual void Sub(char *filename, float offset)=0;
   virtual CPixels *  TtImaSeries(char *s,int *nb_keys,char ***pkeynames,char ***pkeyvalues,
                                 char ***pcomments,char ***punits, int **pdatatypes)=0;
   virtual void Unsmear(float coef)=0;
   virtual void Window(int x1, int y1, int x2, int y2)=0;
   virtual void UnifyBg()=0;

   virtual TPixelClass getPixelClass()=0;
   static TPixelClass getPixelClass(char *);
   static char * getPixelClassName(TPixelClass value);
   static TPixelFormat getPixelFormat(char *);
   static char * getPixelFormatName(TPixelFormat value);
   static TPixelCompression getPixelCompression(char *);
   static char * getPixelCompressionName(TPixelCompression value);
   static TColorPlane getColorPlane(char *);
   
protected:


   int util_qsort_double(double *x,int kdeb,int n,int *index);

   void fitgauss1d(int n,double *y,double *p,double *ecart);
   void fitgauss1d_a(int n,double *y,double *p,double *ecart);
   void fitgauss2d(int sizex, int sizey,double **y,double *p,double *ecart);

   
   static char  *  PixelClassName [];
   static char  *  PixelFormatName [];
   static char  *  CompressionName [];
   static char  *  ColorPlaneName[];
  

};

#endif // __CPIXELSH__
