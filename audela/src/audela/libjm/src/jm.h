/* jm.h
 *
 * This file is part of the libjm libfrary for AudeLA project.
 *
 * Initial author : Jacques MICHELET <jacques.michelet@laposte.net>
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

/*
 * Projet      : AudeLA
 * Librairie   : LIBJM
 * Fichier     : JM.H
 * Description : Déclaration des fonctions exportées
 =================================================
*/

#include "sysexp.h"
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#ifdef LIBRARY_DLL
#include <io.h>
#include <windows.h>
#endif

#define OK  0
#define PB  1
#define PB2 2

/* Declaration des structures */
struct ajustement {
  double X0;
  double Y0;
  double Signal;
  double Fond;
  double Sigma_X;
  double Sigma_Y;
  double Ro;
  double Sigma_1;
  double Sigma_2;
  double Alpha;
  double Flux;
};

typedef struct {
   float *ptr;           /* adresse du pointeur de l'image en interne */
   float *ptr_audela;    /* adresse du pointeur de l'image dans AudeLA */
   int naxis1;           /* nombre de pixels sur l'axe x */
   int naxis2;           /* nombre de pixels sur l'axe y */
   char dateobs[30];     /* date du debut de pose au format Fits */
} descripteur_image;

struct data {
	int nxy;
	int x1;
	int y1;
	int x2;
	int y2;
	double * pixels;
};

struct rectangle {
	int x1;
	int x2;
	int y1;
	int y2;
	int nx;
	int ny;
	size_t nxy;
};


/* --- Déclaration des fonctions --- */
int dms2deg(int d,int m,double s,double *angle);
int jd(int annee,int jour,double heure,double *jj);
int jd2(int annee, int mois, int jour, int heure, int minute, int seconde, int milli,double*jj);
int jc (int *annee, int *mois, double *jour, double jj);
int jc2(int *annee, int *mois, int *jour, int *heure, int *minute, int *seconde, int *milli, double jj);
int LitHeurePC(int *annee, int *mois, int *jour, int *heure, int *minute, int *seconde, int *milli);
int EcritHeurePC(int annee, int mois, int jour, int heure, int minute, int seconde, int milli);
int ReglageHeurePC(long *decalage_reel, long decalage);
int FluxEllipse(double x0, double y0, double r1x, double r1y, double ro, double r2, double r3, int c, double *flux, double *nb_pixel, double *fond, double *nb_pixel_fond, double *sigma_fond);
int InitTamponImage(long pointer, int largeur, int hauteur);
int LecturePixel(int x, int y, int *pixel);
int Incertitude(double flux_etoile, double flux_fond, double nb_pixel, double nb_pixel_fond, double gain, double sigma, double *signal_bruit, double *incertitude, double *bruit_flux);
int Magnitude(double flux_etoile, double flux_ref, double mag_ref, double *mag_etoile);
int AjustementGaussien(int *carre, double *fgauss, double *stat, struct ajustement *valeur, struct ajustement *incertitude, int *iter, double *chi2, double*erreur);
int SoustractionGaussienne(int *carre, struct ajustement *p);


 
