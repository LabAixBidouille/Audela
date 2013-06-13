/* cbuffer.h
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

//------------------------------------------------------------------------------
// Definition de la classe de gestion des Implementation TCL de la classe CBuffer. Cette ne se traduit implementation
// que par quelques fonctions TCL. Une pour creer l'objet BUF, une pour lister
// tous les objets buf presents, et une pour acceder directement aux methodes
// publiques de l'objet.
//


#ifndef __BUFH__
#define __BUFH__

#include "cdevice.h"
//#include "libstd.h"
#include "pthread.h"
#include "cpixels.h"
#include "fitskw.h"

#define BUFCOMPRESS_NONE      0
#define BUFCOMPRESS_GZIP      1

#define KEEP_KEYWORDS         0
#define DONT_KEEP_KEYWORDS    1


#define CHAREXTENSION 128


typedef enum {dt_Short, dt_Int, dt_Float} TDataType;

typedef struct {
   int valid;
   /*-----*/
   double foclen; /* focale en m*/
   double px;     /* pixel en m */
   double py;
   double crota2;
   double cd11;
   double cd12;
   double cd21;
   double cd22;
   double crpix1;
   double crpix2;
   double crval1;
   double crval2;
   double cdelta1;
   double cdelta2;
   double dec0;
   double ra0;
   /*-----*/
   int pv_valid;
   double pv[3][11];
   /*-----*/
   int naxis1;
   int naxis2;
   int astromcatalog;
   char path_astromcatalog[255];
   double bordure;
   double magrsup;
   double magrinf;
   double magbsup;
   double magbinf;
   int tycho_only;
} mc_ASTROM;

class LIBAUDELA_API CBuffer : public CDevice {
protected:
   mc_ASTROM *p_ast;
   int saving_type;
   /* utilise les définitions suivantes :
   #define BYTE_IMG      8
   #define SHORT_IMG    16
   #define LONG_IMG     32
   #define FLOAT_IMG   -32
   #define DOUBLE_IMG  -64
   */
   int compress_type;
   /* utilise les définitions suivantes :
   #define BUFCOMPRESS_NONE      0
   #define BUFCOMPRESS_GZIP      1
   */
   char *fitsextension;
   CPixels        *pix;
   CFitsKeywords  *keywords;
   float          initialMipsLo;
   float          initialMipsHi;
   static char    *FileFormatName [];
   char           temporaryRawFileName[255];
   pthread_mutex_t mutex;
   pthread_mutexattr_t mutexAttr;
   void BoxBackground(TYPE_PIXELS *ppix, double xc,double yc,double radius,double percent,int *nb, double *bg);
   int util_qsort_double(double *x,int kdeb,int n,int *index);

public:
   CBuffer();
   ~CBuffer();
   int A_filtrGauss (TYPE_PIXELS fwhm, int radius, TYPE_PIXELS threshin,
						   TYPE_PIXELS threshold, char *filename, int fileFormat,
						   TYPE_PIXELS *picture,TYPE_PIXELS *temp_pic,TYPE_PIXELS *gauss_matrix,
						   int size_x,int size_y,int gmsize,int border);
   int A_StarList(int x1, int y1, int x2, int y2, double threshin,char *filename, int fileFormat, double fwhm,int radius,
						int border,double threshold,int after_gauss);
   int A_filtrGauss2 (TYPE_PIXELS fwhm, int radius, TYPE_PIXELS threshin,
						   TYPE_PIXELS threshold, TYPE_PIXELS *picture,
						   int size_x,int size_y,int border, double *xCenter, double *yCenter);
   void Add(char *filename, float offset);
   void AstroFlux(int x1, int y1, int x2, int y2,
                     TYPE_PIXELS* flux, TYPE_PIXELS* maxi, int *xmax, int* ymax,
                     TYPE_PIXELS *moy, TYPE_PIXELS *seuil, int *nbpix);
   void AstroCentro(int x1, int y1, int x2, int y2, int xmax, int ymax,
                     TYPE_PIXELS seuil,float* sx, float* sy, float* r);
   void AstroPhoto(int x1, int y1, int x2, int y2, int xmax, int ymax,
                     TYPE_PIXELS moy, double *dFlux, int* ntot);
   void AstroPhotom(int x1, int y1, int x2, int y2, int method, double r1, double r2,double r3,
                      double *flux, double* f23, double* fmoy, double* sigma, int *n1);
   void AstroBaricenter(int x1, int y1, int x2, int y2, double *xc, double *yc);
   void AstroSlitCentro(int x1, int y1, int x2, int y2,
                        int starDetectionMode, int pixelMinCount,
                        int slitWidth, double signalRatio,
                        char *starStatus, double *xc, double *yc,
                        TYPE_PIXELS* maxIntensity, char * message);
   void AstroFiberCentro(int x1, int y1, int x2, int y2,
                          int starDetectionMode, int fiberDetectionMode,
                          int integratedImage, int findFiber,
                          int maskBufNo, int sumBufNo, int fiberBufNo,
                          int maskRadius, double maskFwhm, double maskPercent,
                          int originSumMinCounter, int originSumCounter,
                          double previousFiberX, double previousFiberY,
                          int pixelMinCount, double biasValue,
                          char *starStatus,  double *starX,  double *starY,
                          char *fiberStatus, double *fiberX, double *fiberY,
                          double *measuredFwhmX, double *measuredFwhmY,
                          double *background, double *maxIntensity,
                          double *starFlux, char *message);
   void Autocut(double *phicut,double *plocut,double *pmode);
   void BinX(int x1, int x2, int width);
   void BinY(int y1, int y2, int height);
   void Cfa2Rgb(int method);
   void Clipmax(double value);
   void Clipmin(double value);
   static CBuffer * Chercher(int bufNo);
   void CopyTo(CBuffer*dest);
   void CopyFrom(CFitsKeywords*hdr, TColorPlane plane, TYPE_PIXELS*pix);
   void CopyKwdFrom(CBuffer*org);
   void Create3d(char *filename,int init, int nbtot, int index,int *naxis10, int *naxis20, int *errcode);
   void Div(char *filename, float constante);
   void FillAstromParams();
   void FreeBuffer(int keep_keywords);
   void Fwhm(int x1, int y1, int x2, int y2,
             double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
             double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
             double fwhmx0, double fwhmy0);
   void Fwhm2d(int x1, int y1, int x2, int y2,
               double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
               double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
               double fwhmx0, double fwhmy0);
   void psfimcce(int x1, int y1, int x2, int y2,
                 double *xsm, double *ysm, double *err_xsm, double *err_ysm,
                 double *fwhmx, double *fwhmy, double *fwhm, double *flux,
                 double *err_flux, double *pixmax, double *intensity, double *sky,
                 double *err_sky, double *snint, int *radius, int *err_psf,
                 float **residus, float **synthetic);
   void GetDataType(TDataType *dt);
   int  GetHeight();
   CFitsKeywords* GetKeywords() {return keywords;};
   int  GetNaxis();
   void GetPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y);
   void GetPixels(TYPE_PIXELS* pixels);
   void GetPixels(TYPE_PIXELS *pixels, TColorPlane colorPlane);
   void GetPixels(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, long pixelsPtr);
   void GetPixelsPointer(TYPE_PIXELS **ppixels);
   void GetPixelsRgb( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY, float *cuts,
            unsigned char *palette[3], unsigned char *ptr);
   void GetPixelsVisu( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY, float *cuts,
            unsigned char *palette[3], unsigned char *ptr);
   int  GetSavingType();
   int  GetCompressType();
   char * GetExtension();
   int  GetWidth();
   int  IsPixelsReady(void) ;
   void Histogram(int n, float *adus, float *meanadus, long *histo,
                     int ismini,float mini,int ismaxi,float maxi);
   void LoadFile(char *filename);
   void LoadFits(char *filename);
   void Load3d(char *filename,int iaxis3);
   void Log(float coef, float offset);
   void MergePixels(TColorPlane plane, int pixels);
   void NGain(float gain);
   void NOffset(float offset);
   void Unsmear(float coef);
   void MedX(int x1, int x2, int width);
   void MedY(int y1, int y2, int height);
   /*
   void MirX();
   void MirY();
   */
   void Offset(TYPE_PIXELS offset);
   void Opt(char *dark, char *offset);
   void RestoreInitialCut();
   void Rot(float x0, float y0, float angle);
   void SaveFits(char *filename);
   void Save1d(char *filename,int iaxis2);
   void Save3d(char *filename,int naxis3,int iaxis3_beg,int iaxis3_end);
   void SaveJpg(char *filename,int quality,int sbsh, double sb,double sh);
   void SaveJpg(char *filename,int quality, unsigned char *palette[3], int mirrorx, int mirrory);
   void SaveRawFile(char *filename);
   void SaveTkImg(char *filename, unsigned char *palette[3], int mirrorx, int mirrory);
   void SetCompressType(int st);
   void SetExtension(char *ext);
   void SetKeyword(char *nom, char *data, char *datatype, char *comment, char *unit);
   void SetPix(TColorPlane plane, TYPE_PIXELS,int,int);
   void SetPixels(TColorPlane plane, int width, int height, TPixelFormat pixelFormat, TPixelCompression compression, void * pixels, long pixelSize, int reverse_x, int reverse_y);
   void SetPixels(int width, int height, int pixelSize, int offset[4], int pitch, unsigned char * pixels);
   void SetSavingType(int st);
   void Sub(char *filename, float offset);
   void Sub(int bufNo, float offset);
   void TtImaSeries(char *s);
   void Stat(int x1,int y1,int x2,int y2,
            float *locut, float *hicut,  float *maxi,    float *mini,   float *mean,
            float *sigma, float *bgmean, float *bgsigma, float *contrast);
   void Scar( int x1,int y1,int x2,int y2);
   void SyntheGauss(double xc, double yc, double imax, double jmax, double fwhmx, double fwhmy, double limitadu);
   void radec2xy(double ra, double dec, double *x, double *y,int order);
   void xy2radec(double x, double y, double *ra, double *dec,int order);

   void UnifyBg();
   void SubStars(FILE *fascii, int indexcol_x, int indexcol_y, int indexcol_bg, double radius, double xc_exclu, double yc_exclu, double radius_exclu,int *n);
   void Window(int x1, int y1, int x2, int y2);
};

#endif



