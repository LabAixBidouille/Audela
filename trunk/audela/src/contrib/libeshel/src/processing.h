// processing.h : processing functions
//

#include <windows.h>
#include <math.h>
#include <float.h> // pour _isnan
#include <vector>
#include <limits.h> // pour INT_MAX et INT_MIN


#include <exception>
#define swab _swab  //  replace "swab" by "_swab" because "swab" is deprecaded

#include "infoimage.h"
#include "order.h"
#include "linegap.h"


// definition des constantes et de macros
#define SGN(x) (x>=0?1:-1)
#define PI M_PI    // j'utilise la valeur de M_PI declaree dans math.h
#define SEUIL_ALPHA 0  // seuil de l'angle ALPHA pour distinguer les spectro echelle (alpha > 60 )



// fonctions locales
void setSoftwareVersionKeyword( CCfits::PFitsFile pFits );
FILE * openLog(char *fileName);

void correctDistorsion( );

int gauss_convol(INFOIMAGE *buffer,double sigma);
int grady(INFOIMAGE *buffer,int flag);
int grady2(INFOIMAGE *buffer, int flag);
int calc_cdg_y(PIC_TYPE *p,int imax,int jmax,int x,int y1,int y2,double *pos_y);
void find_y_pos(INFOIMAGE *buffer, short *check,int imax,int jmax,int y0,
               int ordre0,int wide_y,int seuil,ORDRE *ordre,
               int *nb_ordre,int min_order,int max_order,FILE *hand_log);
void track_order(INFOIMAGE *buffer,short *check,int imax,int jmax,int wide_y,ORDRE *ordre,int n,FILE *hand_log);
void fitPoly(int numpts,int degree,double *x,double *y,double *wt,double *coeffs,double *rms);
int calib_prediction(double lambda0,int ordre0,short *check,int imax,int jmax,double posx0,
                     ORDRE *ordre,double *ddx,INFOSPECTRO spectro,::std::list<double> lineList);
int extract_order(INFOIMAGE *buffer,int n,int jmax0,ORDRE *ordre,std::valarray<double> &profile, char * nom, std::valarray<PIC_TYPE> *straightLineImage);
PIC_TYPE hmedian(PIC_TYPE *ra,int n);
double compute_pos(double k,double lam,double dx,int imax, INFOSPECTRO spectro);
int compute_slant(INFOIMAGE *buffer,int y0,double alpha);
int l_opt(INFOIMAGE *buffer,int lmin,int lmax,int xmin,int xmax,std::valarray<double> &profile, char * nom);
int flat_rectif(int i,char *n_objet,char *n_flat,ORDRE *ordre);
void flat_rectif(std::valarray<double> &object,std::valarray<double> &flat, std::valarray<double> &out);
int make_interpol(std::valarray<double> &table_in, double coef3,double coef2,double coef1,double coef0,
                  double pas,std::valarray<double> &table_out, double *lambda1);
double compute_px2lambda(double px, double k, double dx, INFOSPECTRO spectro);
void calib_spec(int n,int nb_iter,double lambda_ref,int ordre_ref,std::valarray<double> &calibRawProfile,ORDRE *ordre,int imax,int jmax,
               int neon_ref_x,short *check,INFOSPECTRO spectro,
               ::std::list<double> &lineList, ::std::list<LINE_GAP> &lineGapList);
int line_pos_approx(int pos,int wide,std::valarray<double> &buf,int *posx);
int spline(int n,double *x,double *y,double *b,double *c,double *d);
double seval(int n,double u,double *x,double *y,double *b,double *c,double *d);
void aboute_spectres(int max_ordre,int min_ordre,char *nom_objet,char *nom_calib,char *nom_out,int useFlat);
void planck_correct(char *fileNameIn, char *fileNameOut,double temperature);
int find_max(INFOIMAGE *buffer, int *x,int *y);
void MipsParaFit(int n,double *y,double *p,double *ecart);
int spec_gauss(int pos,int wide,std::valarray<double> &buf,double *pos_x,double *fwhm,double *ecartType);
int find_continuum(char *n_spectre,char *n_continuum);
double get_central_wave(int imax,double posx,double dx,int k,INFOSPECTRO spectro);
void divideResponse(std::valarray<double> &profile1b, double lambda1b, std::valarray<double> &responseProfile, double responseLambda, double step,std::valarray<double> &profile1c, double *lambda1c);
void abut1bOrder(int max_ordre,int min_ordre,CCfits::PFitsFile objectFits, char *hduName);
void abut1bOrder(int max_ordre,int min_ordre,CCfits::PFitsFile objectFits, CCfits::PFitsFile calibFits, char *hduName);
void abut1cOrder(int max_ordre,int min_ordre,CCfits::PFitsFile objectFits, char *hduName);


