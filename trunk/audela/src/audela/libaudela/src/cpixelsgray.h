/* cpixelsgray.h
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

#ifndef __CPIXELSGRAYH__
#define __CPIXELSGRAYH__

#include "cdevice.h"
#include "libstd.h"
#include "cpixels.h"
#include "palette.h"


class CPixelsGray : public CPixels
{
public:
	virtual ~CPixelsGray();
   CPixelsGray(int naxis1, int naxis2, TPixelFormat pixelFormat, TPixelCompression compression, int pixels);

   void Add(char *filename, float offset);
   void Autocut(double *phicut,double *plocut,double *pmode);
   void BinX(int x1, int x2, int width);
   void BinY(int y1, int y2, int height);
   void Clipmax(double value);
   void Clipmin(double value);
   void Div(char *filename, float constante);
   void Fwhm(int x1, int y1, int x2, int y2,
              double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
              double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				  double fwhmx0, double fwhmy0);
   void Fwhm2d(int x1, int y1, int x2, int y2,
                  double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
                  double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				  double fwhmx0, double fwhmy0);
   int  GetHeight(void);
   int  GetPlanes(void);
   int  GetWidth(void);
   void GetPixGray(TYPE_PIXELS *val,int x, int y);
   void GetPixelsPointer(TYPE_PIXELS **pixels);
   void GetPixels(int x1, int x2, int y1, int y2, TPixelFormat pixelFormat, TColorPlane plane, int pixels);
   void GetPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, int pixels);
   void GetPixelsZoom( int x1,int y1,int x2, int y2, double zoom, 
            double hicutRed,   double locutRed, 
            double hicutGreen, double locutGreen,
            double hicutBlue,  double locutBlue,
            Pal_Struct *pal, unsigned char *ptr);
   int  IsPixelsReady(void);
   void Log(float coef, float offset);
   void MergePixels(TColorPlane plane, int pixels);
   void MirX();
   void MirY();
   void NGain(float gain);
   void NOffset(float offset);
   void Offset(float offset);
   void Opt(char *dark, char *offset);
   void Rot(float x0, float y0, float angle);
   void SetPix(TYPE_PIXELS val,int x, int y);
   void Sub(char *filename, float offset);
   CPixels * TtImaSeries(char *s,int *nb_keys,char ***pkeynames,char ***pkeyvalues,
                                 char ***pcomments,char ***punits, int **pdatatypes);
   void Unsmear(float coef);
   void Window(int x1, int y1, int x2, int y2);
   void UnifyBg();

   TPixelClass getPixelClass() ;

protected:
	CPixelsGray(int width, int height, TYPE_PIXELS *ppix);
	CPixelsGray();

   TYPE_PIXELS *pix;
   int naxis1;
   int naxis2;

};

#endif // !defined(AFX_PIXELSGRAY_H__5D055468_26ED_4225_A33D_D9A9A0D314E2__INCLUDED_)
