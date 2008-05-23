/* jm_photo.c
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

// Projet      : AudeLA 
// Librairie   : LIBJM
// Fichier     : JM_PHOTO.CPP 
// Auteur      : Jacques Michelet
// Description : Fonctions relatives � la photom�trie
// ==================================================

#include "jm.h"
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_histogram.h>


static float *pointeur_image;
static int largeur_image;
static int hauteur_image;

// ***************** InitTamponImage *******************
// 
// Met en m�moire des �l�ments du tampon d'image courant
// *****************************************************
int InitTamponImage(long pointeur, int largeur, int hauteur)
{
  pointeur_image = (float *) pointeur;
  largeur_image = largeur;
  hauteur_image = hauteur;
  return 0;
}

// ***************** LecturePixel ************
// 
// Retourne la valeur d'un pixel
// *******************************************
int LecturePixel(int x, int y, int *pixel)
{
  float *pointeur;
  
  if ((x <= 0) || (x > largeur_image) || (y <= 0) || (y > hauteur_image))
    {
      return PB;
    }
  x--;
  y--;
  pointeur = pointeur_image + (y * largeur_image) + x;
  *pixel = (int)(* pointeur);
  return 0;
}

// ***************** EcriturePixel ************
// 
// Ecrit la valeur d'un pixel
// ********************************************
int EcriturePixel(int x, int y, int pixel)
{
  float *pointeur;
  
  if ((x <= 0) || (x > largeur_image) || (y <= 0) || (y > hauteur_image))
    {
      return PB;
    }
  x--;
  y--;
  pointeur = pointeur_image + (y * largeur_image) + x;
  *pointeur = (float)pixel;
  return 0;
}

// ***************** FluxEllipse ****************
// 
// Calcul le flux dans une ellipse
// **********************************************
int FluxEllipse(double x0, double y0, double r1x, double r1y, double ro, double r2, double r3, int c, double *flux, double *nb_pixel, double *fond, double *nb_pixel_fond, double *sigma_fond)
{
  double y;
  int yi;
  double x, x2, x3, xmin, xmax;
  int xi;
  double flux_fond, flux_etoile, cinv, cinv2, flux_fond2;
  double delta_x, delta_y, t;
  int pixel;
  
  // Initialisations
  flux_fond = 0.0;
  flux_fond2 = 0.0;
  (*nb_pixel_fond) = 0.0;
  flux_etoile = 0.0;
  (*nb_pixel) = 0.0;
  cinv = 1.0 / (double)c;
  cinv2 = cinv * cinv;
  
  // Recuperation des pixels de la couronne entre r2 et r3
  // ** Bas de la couronne
  for (y = (y0 - r3); y <= (y0 - r2); y++)
    {
      x3 = (r3 * r3) - ((y - y0) * (y - y0));
      if (x3 < 0.0)
	x3 = 0.0;
      xmin = x0 - sqrt(x3);
      xmax = x0 + sqrt(x3);
      
      yi = (int)floor(y + 0.5);
      for (x = xmin; x <= xmax; x++)
	{
	  xi = (int)floor(x + 0.5);
	  LecturePixel (xi, yi, &pixel);
	  flux_fond += pixel;
	  flux_fond2 += (pixel * pixel);
	  (*nb_pixel_fond)++;
	}
    }
  
  // ** Milieu de la couronne (parties gauche et droite)
  for (y = (y0 - r2); y <= (y0 + r2); y++)
    {
      x3 = (r3 * r3) - ((y - y0) * (y - y0));
      if (x3 < 0.0)
	x3 = 0.0;
      x2 = (r2 * r2) - ((y - y0) * (y - y0));
      if (x2 < 0.0)
	x2 = 0.0;
      yi = (int)floor(y + 0.5);
      
      xmin = x0 - sqrt(x3);
      xmax = x0 - sqrt(x2);
      for (x = xmin; x <= xmax; x++)
	{
	  xi = (int)floor(x + 0.5);
	  LecturePixel (xi, yi, &pixel);
	  flux_fond += pixel;
	  flux_fond2 += (pixel * pixel);
	  (*nb_pixel_fond)++;
	}
      
      
      xmin = x0 + sqrt(x2);
      xmax = x0 + sqrt(x3);
      for (x = xmin; x <= xmax; x++)
	{
	  xi = (int)floor(x + 0.5);
	  LecturePixel (xi, yi, &pixel);
	  flux_fond += pixel;
	  flux_fond2 += (pixel * pixel);
	  (*nb_pixel_fond)++;
	}
    }
  
  // ** Haut de la couronne
  for (y = (y0 + r2); y <= (y0 + r3); y++)
    {
      x3 = (r3 * r3) - ((y - y0) * (y - y0));
      if (x3 < 0.0)
	x3 = 0.0;
      xmin = x0 - sqrt(x3);
      xmax = x0 + sqrt(x3);
      
      yi = (int)floor(y + 0.5);
      for (x = xmin; x <= xmax; x++)
	{
	  xi = (int)floor(x + 0.5);
	  LecturePixel (xi, yi, &pixel);
	  flux_fond += pixel;
	  flux_fond2 += (pixel * pixel);
	  (*nb_pixel_fond)++;
	}
    }
  
  // La valeur du flux de fond est la moyenne de toutes les valeurs lues dans la couronne.
  *fond = flux_fond / (double) (*nb_pixel_fond);
  
  
  // Calcul de l'ecart-type (formule de Koenig)
  *sigma_fond = sqrt((flux_fond2 / *nb_pixel_fond) - (*fond) * (*fond));
  
  // Calcul du flux dans l'ellipse (r1x, r1y)


/*  for (y = (y0 - r1y); y <= (y0 + r1y); y += cinv)
    {
      x2 = 1.0 - ((y - y0) * (y - y0) / r1y / r1y);
      if (x2 < 0.0)
	x2 = 0.0;
      x3 = r1x * sqrt(x2);
      yi = (int)floor(y + 0.5);


      for (x = (x0 - x3); x <= (x0 + x3); x += cinv)
	{
	  xi = (int)floor(x + 0.5);
	  LecturePixel (xi, yi, &pixel);
	  flux_etoile += pixel * cinv2;
	  (*nb_pixel) += cinv2;
	}
    }
*/
    
  // Calcul du flux dans l'ellipse (r1x, r1y, ro)
    delta_y = r1y / sqrt(1 - ro*ro);
    delta_x = r1x / sqrt(1 - ro*ro);
    for (y = (y0 - delta_y); y <= (y0 + delta_y); y += cinv)
    {
        yi = (int)floor(y + 0.5);
        /* on pourrait optimiser en calculant la valeur de x sur l'ellipse */
        /* A faire a la retraite, a 85 ans ...*/
        for (x = (x0 - delta_x); x <= (x0 + delta_x); x += cinv)
        {
            t = ((x-x0)*(x-x0))/(r1x*r1x) + ((y-y0)*(y-y0))/(r1y*r1y) - 2.0*ro*(x-x0)*(y-y0)/(r1x*r1y) - 1.0;
            if (t <= 0.0)
            {
                /* Le point (x,y) est dans l'ellipse */
                xi = (int)floor(x + 0.5);
                LecturePixel (xi, yi, &pixel);
                flux_etoile += pixel * cinv2;
                (*nb_pixel) += cinv2;
             }
        }
    }

    *flux = flux_etoile - (*nb_pixel) * (*fond);
      
    return 0;
}

int Magnitude(double flux_etoile, double flux_ref, double mag_ref, double *mag_etoile)
{
  if ((flux_etoile > 0.0) && (flux_ref > 0.0))
    *mag_etoile = mag_ref - 2.5 * log10(flux_etoile / flux_ref);


  else
    *mag_etoile = 99.99;
  
  return 0;
}

int Incertitude(double flux_etoile, double flux_fond, double nb_pixel, double nb_pixel_fond, double gain, double sigma, double *signal_bruit, double *incertitude, double *bruit_flux)
{
  double q1, q2, q3;
  
  q1 = (flux_fond + sigma * sigma) / flux_etoile;
  q2 = 1.0 + 1.0 / nb_pixel_fond;
  q3 = (nb_pixel * q1 * q2) + (1.0 / gain);
  *signal_bruit = flux_etoile / q3;
  *incertitude = 1.085 / *signal_bruit;
  *bruit_flux = flux_etoile / *signal_bruit;
  
  return 0;
}


void CalculValeursPrincipales (int x1, int y1, int x2, int y2, double *x_source, double *y_source, gsl_vector *vect_s)
{
  int x, y;
  int valeur_pixel, maxi;
  int i = 0;
  
  maxi = -32767;
  *x_source = x1;
  *y_source = y1;
  for (y = y1; y <= y2; y++)
    {
      for (x = x1; x <= x2; x++)
	{
	  LecturePixel(x, y, &valeur_pixel);
	  gsl_vector_set(vect_s, i++, (double)valeur_pixel);
	  if (maxi < valeur_pixel)
	    { 
	      maxi = valeur_pixel;
	      *x_source = x;
	      *y_source = y;
	    }
	}
    }
}


/* Algorithme de modelisation par     */
/* f(x,y) = exp(-X^2 - Y^2 + 2*Ro*X*Y) */
/* avec X = (x-x0)/sx                 */
/*      Y = (y-y0)/sy                 */
/*      (x0,y0) centroide             */
/*      sx et sy ecart-types          */
/*      |Ro| < 1                      */
void Gauss(int x1, int y1, int x2, int y2, gsl_vector *vect_s, gsl_vector *vect_w, gsl_matrix *mat_x, gsl_vector *vect_c, gsl_matrix *mat_cov, double *chi2, double *me1, struct ajustement *p, struct ajustement *incert, int *iter, int *convergence)
{
	int x, y;
	double dy, dy2, gy, dx, dx2, gx, hxy, fxy;
	size_t i;
	int erreur;
	struct ajustement t;

	// Initialisations
	x = 0;
	y = 0;
	dy = 0.0;
	dy2 = 0.0;
	gy = 0.0;
	dx = 0.0;
	dx2 = 0.0;
	gx = 0.0;
	hxy = 0.0;
	fxy = 0.0;
	i = 0;
	erreur = 0;

	memset (&t, 0, sizeof(struct ajustement));

	//  printf("X0=%g|Y0=%g|S=%g|B=%g|Sx=%g|Sy=%g|Ro=%g\n", p->X0, p->Y0, p->Signal, p->Fond, p->Sigma_X, p->Sigma_Y, p->Ro);
  
	size_t nxy = (size_t)(x2 - x1 + 1) * (size_t)(y2 - y1 + 1);
 
	gsl_vector *vect_y = gsl_vector_alloc(nxy);
	gsl_multifit_linear_workspace *bac = gsl_multifit_linear_alloc(nxy, 7);
	gsl_matrix *temp_cov = gsl_matrix_alloc(7, 7);

	double ancien_chi2 = 1e9;
	double chi2_temporaire = 1e9;
   
	*convergence = -1;
	*iter = 0;
	while (*convergence < 0)
	{
		i = 0;
		(*iter) ++;
		for (y = y1; y <= y2; y++)
		{
			dy = ((double)y - p->Y0) / p->Sigma_Y;
			dy2 = dy * dy;
			gy = exp(-dy2);
			for (x = x1; x <= x2; x++)
			{
				dx = ((double)x - p->X0) / p->Sigma_X;
				dx2 = dx * dx;
				gx = exp(-dx2);
				hxy = exp(2.0 * p->Ro * dx * dy);
				fxy = gx * gy * hxy;

				/* Matrice des points a faire correspondre */
				gsl_vector_set(vect_y, i, (gsl_vector_get(vect_s, i) - (p->Signal * fxy + p->Fond)));

				/* Matrice du modele (Jacobien) */
				/* dF/dX0 */
				gsl_matrix_set(mat_x, i, 0, (2.0 * p->Signal * fxy * ((dx - p->Ro * dy) / p->Sigma_X)));
				/* dF/dY0 */
				gsl_matrix_set(mat_x, i, 1, (2.0 * p->Signal * fxy * ((dy - p->Ro * dx) / p->Sigma_Y)));
				/* dF/dS0 */
				gsl_matrix_set(mat_x, i, 2, fxy);
				/* dF/dB */
				gsl_matrix_set(mat_x, i, 3, 1.0);
				/* dF/dFwhmX */
				gsl_matrix_set(mat_x, i, 4, (2.0 * p->Signal * fxy * ((dx2 / p->Sigma_X) - (p->Ro * dx * dy / p->Sigma_X))));
				/* dF/dFwhmY */
				gsl_matrix_set(mat_x, i, 5, (2.0 * p->Signal * fxy * ((dy2 / p->Sigma_Y) - (p->Ro * dx * dy / p->Sigma_Y))));
				/* dF/dRo */
				gsl_matrix_set(mat_x, i, 6, (2.0 * p->Signal * fxy * dx * dy));
 
				i++;

			}
		}
		erreur = gsl_multifit_wlinear(mat_x, vect_w, vect_y, vect_c, temp_cov, chi2, bac);
		if (erreur) {
			*convergence = 0;
			return;
		}

		t.X0 = p->X0 + gsl_vector_get(vect_c,0);
		t.Y0 = p->Y0 + gsl_vector_get(vect_c,1);
		t.Signal = p->Signal + gsl_vector_get(vect_c,2);
		t.Fond = p->Fond + gsl_vector_get(vect_c,3);
		t.Sigma_X = p->Sigma_X + gsl_vector_get(vect_c,4);
		t.Sigma_Y = p->Sigma_Y + gsl_vector_get(vect_c,5);
		if (fabs(t.Ro) > .9) {
			t.Ro = p->Ro + (gsl_vector_get(vect_c,6) / 10.0);
		} else {
			t.Ro = p->Ro + gsl_vector_get(vect_c,6);
		}

		/* Detection des cas d'arret */
		/* !! on ne compare que les chi2 "pairs". En effet, dans certains cas, la modelisation */
		/* oscille sans fin entre 2 valeurs, vraisemblablement a cause de problemes d'arrondis */
		/* C'est pourquoi existe la variable chi2_temporaire */
		if (fabs(ancien_chi2 - *chi2) < 1e-10)
		{
			*convergence = 1;
		}

		if ((t.X0 < x1)         /* la modelisation sort du cadre entourant l'image */
		|| (t.X0 > x2)
		|| (t.Y0 < y1)
		|| (t.Y0 > y2)
		|| (t.Sigma_X < 0.0)    /* l'ecart-type ne peut pas etre negatif */
		|| (t.Sigma_Y < 0.0)
		|| (t.Signal < 0.0)     /* le signal doit rester dans les limites de la numerisation */
		|| (t.Signal > 32767.0)
		|| (t.Fond > 32767.0)
		|| (fabs(t.Ro) >= 0.98)  /* |ro| est forcement < 1 */
		|| (*iter > 100)       /* Convergence qui prend un temps "infini" */
		|| ((t.Sigma_X / t.Sigma_Y) >= 10.0)
		|| ((t.Sigma_Y / t.Sigma_X) >= 10.0)
		|| (t.Sigma_X < 0.25)
		|| (t.Sigma_Y < 0.25))
		{
			*convergence = 0;
		} else {
			ancien_chi2 = chi2_temporaire;
			chi2_temporaire = *chi2;
			p->X0 = t.X0;
			p->Y0 = t.Y0;
			p->Signal = t.Signal;
			p->Fond = t.Fond;
			p->Sigma_X = t.Sigma_X;
			p->Sigma_Y = t.Sigma_Y;
			p->Ro = t.Ro;

			gsl_matrix_memcpy(mat_cov, temp_cov);

			//	printf("X0=%g|Y0=%g|S=%g|B=%g|Sx=%g|Sy=%g|Ro=%g\n", p->X0, p->Y0, p->Signal, p->Fond, p->Sigma_X, p->Sigma_Y, p->Ro);
		}
	}

	*chi2 = ancien_chi2;
	*me1 = sqrt(*chi2 / (nxy - 7));

	incert->X0 = *me1 * sqrt(gsl_matrix_get(mat_cov, 0, 0));
	incert->Y0 = *me1 * sqrt(gsl_matrix_get(mat_cov, 1, 1));
	incert->Signal = *me1 * sqrt(gsl_matrix_get(mat_cov, 2, 2));
	incert->Fond = *me1 * sqrt(gsl_matrix_get(mat_cov, 3, 3));
	incert->Sigma_X = *me1 * sqrt(gsl_matrix_get(mat_cov, 4, 4));
	incert->Sigma_Y = *me1 * sqrt(gsl_matrix_get(mat_cov, 5, 5));
	incert->Ro = *me1 * sqrt(gsl_matrix_get(mat_cov, 6, 6));

	//  printf("iX0=%g|iY0=%g|iS=%g|iB=%g|iSx=%g|iSy=%g|iRo=%g\n", incert->X0, incert->Y0, incert->Signal, incert->Fond, incert->Sigma_X, incert->Sigma_Y, incert->Ro);
	//  printf("Iter = %d\n", *iter);

	gsl_multifit_linear_free(bac);
	gsl_vector_free(vect_y);
	gsl_matrix_free(temp_cov);
}


/**************************************************************/
/* Ajustement d'un morceau d'image par une surface gaussienne */
/* Calcul du flux donne par le modele                         */
/**************************************************************/
int AjustementGaussien(int *carre, double *param, struct ajustement *valeurs, struct ajustement *incertitudes, int *iter, double *chi2, int *convergence)
{
  //  int mini, maxi;
  int x1, y1, x2, y2, nx, ny;
  double x_source, y_source;
  double sx, sx2, sy, sy2, alpha2, alpha, p, q, sxp, syp, ro;
  double dro, dsx, dsy, a, b, c, da, db, dc, temp_a, dalpha_da, dalpha_db, dalpha_dc, dalpha;
  double me1 = 0.0;
  gsl_vector *vect_w, *vect_s, *vect_c;
  gsl_matrix *mat_x, *mat_cov;
  size_t nxy;

  /* Tri des x1, x2 et y1, y2 */
  if (carre[0] > carre[2]) {
    x1 = carre[2];
    x2 = carre[0];

  } else {
    x2 = carre[2];
    x1 = carre[0];
  }

  if (carre[1] > carre[3]) {
    y1 = carre[3];
    y2 = carre[1];
  } else {
    y2 = carre[3];
    y1 = carre[1];
  }
 
  nx = x2 - x1 + 1;
  ny = y2 - y1 + 1;
  nxy = (size_t) (nx * ny);

  /* Creation des objets gsl */
  vect_w = gsl_vector_alloc(nxy);
  vect_s = gsl_vector_alloc(nxy);
  vect_c = gsl_vector_alloc(7);
  mat_x = gsl_matrix_alloc(nxy, 7);
  mat_cov = gsl_matrix_alloc(7, 7);

  /* Lecture du carre, et recuperation du centroide potentiel */
  /* Stockage des valeurs des pixels dans le vecteur s */
  CalculValeursPrincipales (x1, y1, x2, y2, &x_source, &y_source, vect_s);

  /* Valeurs pour l'initialisation de la boucle de calcul */
  /* Signal = max - fond */
  valeurs->Signal = (double)(param[2] - param[6]);
  /* Fond = fond */
  valeurs->Fond = param[6];
  /* Centroide potentiel */
  valeurs->X0 = x_source;
  valeurs->Y0 = y_source;
  /* Au hasard */
  valeurs->Sigma_X = 1.0;
  valeurs->Sigma_Y = 1.0;
  valeurs->Ro = 0.0;

  *chi2 = 0.0;

  /* Initialisations du vecteur de ponderation */
  if (param[7] != 0.0)
	  gsl_vector_set_all(vect_w, 1.0 / param[7] / param[7]);
  else
	  gsl_vector_set_all(vect_w, 1.0);

  /* Cas d'une image constante : on sort tout de suite, la modelisation n'a pas de sens */
  if (valeurs->Signal == 0) {
	  *convergence = 0;
	  gsl_matrix_free(mat_cov);
	  gsl_matrix_free(mat_x);
	  gsl_vector_free(vect_c);
	  gsl_vector_free(vect_s);
	  gsl_vector_free(vect_w);
	  return 0;
  }

  Gauss (x1, y1, x2, y2, vect_s, vect_w, mat_x, vect_c, mat_cov, chi2, &me1, valeurs, incertitudes, iter, convergence); 
  
  /* Calcul du flux */
  valeurs->Flux = M_PI * valeurs->Signal * valeurs->Sigma_X * valeurs->Sigma_Y / sqrt(1.0 - (valeurs->Ro * valeurs->Ro));

  /* Manips pour simplifier les calculs et les ecritures */
  sx = valeurs->Sigma_X;
  sy = valeurs->Sigma_Y;
  ro = valeurs->Ro;
  sx2 = sx * sx;
  sy2 = sy * sy;
  a = 1.0 / sx2;
  c = 1.0 / sy2;
  b = -ro / sx / sy;
  dsx = incertitudes->Sigma_X;
  dsy = incertitudes->Sigma_Y;
  dro = incertitudes->Ro;
  da = fabs(-2.0 * dsx / sx / sx / sx);
  dc = fabs(-2.0 * dsy / sy / sy / sy);
  db = fabs((- dro / sx / sy) + (dsx * ro / sx2 / sy) + (dsy * ro / sx / sy2));

  /* Calcul des valeurs principales et de leur incertitudes*/
  if (sx != sy) {
    alpha2 = atan2((2.0 * ro * sx * sy), (sx2 - sy2));
    p = a + c;
    q = (a - c) * cos(alpha2) + (2.0 * b * sin(alpha2));
    
    /* Valeur principale */
    alpha = alpha2 / 2.0;
    sxp = 1.0 / sqrt((p + q) / 2.0);
    syp = 1.0 / sqrt((p - q) / 2.0);

    /* Pour alpha */
    temp_a = (a - c) * (a - c) + (4 * b * b);
    dalpha_da = fabs(-b / temp_a);
    dalpha_dc = dalpha_da;
    dalpha_db = fabs((a - c) / temp_a);
    dalpha = (dalpha_da * da) + (dalpha_dc * dc) + (dalpha_db) * db;
  } else {
    /* Valeur principale */
    alpha = 0; /* en fait alpha n'a pas de sens, puisqu'il s'agit d'un cercle parfait */
    sxp = sx;
    syp = sy;

    /* Pour alpha */
    dalpha = 0;
  }
  /* Pour le flux */
  incertitudes->Flux = (valeurs->Flux / valeurs->Signal) * incertitudes->Signal +
    (valeurs->Flux / valeurs->Sigma_X) * incertitudes->Sigma_X +
    (valeurs->Flux / valeurs->Sigma_Y) * incertitudes->Sigma_Y +
    (valeurs->Flux * valeurs->Ro / (1.0 - valeurs->Ro * valeurs->Ro)) * incertitudes->Ro;

  valeurs->Sigma_1 = sxp;
  valeurs->Sigma_2 = syp;
  incertitudes->Sigma_1 = incertitudes->Sigma_X * valeurs->Sigma_1 / valeurs->Sigma_X;
  incertitudes->Sigma_2 = incertitudes->Sigma_Y * valeurs->Sigma_2 / valeurs->Sigma_Y;

  /* Conversion en degres */
  valeurs->Alpha = 57.29578 * alpha;
  incertitudes->Alpha = 57.29578 * dalpha;

  //  printf("Iter = %d | ME1 = %f |Chi2 = %f | ecart_type = %f| ecart_fond = %f\n", *iter, me1, *chi2, param[5], param[7]);

  gsl_matrix_free(mat_cov);
  gsl_matrix_free(mat_x);
  gsl_vector_free(vect_c);
  gsl_vector_free(vect_s);
  gsl_vector_free(vect_w);
  
  return 0;
}


int SoustractionGaussienne(int *carre, struct ajustement *p)
{
  int x, y;
  int x1, y1, x2, y2;
  double dy, dy2, gy, dx, dx2, gx, hxy, fxy;
  int valeur_pixel, gaussienne;

  /* Tri des x1, x2 et y1, y2 */
  if (carre[0] > carre[2]) {
    x1 = carre[2];
    x2 = carre[0];
  } else {
    x2 = carre[2];
    x1 = carre[0];
  }

  if (carre[1] > carre[3]) {
    y1 = carre[3];
    y2 = carre[1];
  } else {
    y2 = carre[3];
    y1 = carre[1];
  }

  for (y = y1; y <= y2; y++) {
      dy = ((double)y - p->Y0) / p->Sigma_Y;
      dy2 = dy * dy;
      gy = exp(-dy2);
      for (x = x1; x <= x2; x++) {
		dx = ((double)x - p->X0) / p->Sigma_X;
		dx2 = dx * dx;
		gx = exp(-dx2);
		hxy = exp(2.0 * p->Ro * dx * dy);
		fxy = gx * gy * hxy;
		/* On calcule la gaussienne, mais ne tient pas compte du fond de ciel ! */
		gaussienne = (int)(p->Signal * fxy);

		LecturePixel(x, y, &valeur_pixel);
		valeur_pixel -= gaussienne;
		if (valeur_pixel < 0) 
			valeur_pixel = 0;
		EcriturePixel(x, y, valeur_pixel);
		}
    }
  return 0;
}
