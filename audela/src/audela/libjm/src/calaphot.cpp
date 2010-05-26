/***
 * @file : calaphot.cpp
 * @brief : routines de photométrie et de modélisation
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: calaphot.cpp,v 1.5 2010-05-26 11:55:07 jacquesmichelet Exp $
 *
 * <pre>
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
 * </pre>
 */

#include <iostream>
#include <fstream>
#include <string.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_multifit_nlin.h>
#include <gsl/gsl_histogram.h>

#include "cerror.h"
#include "cbuffer.h"
#include "libjm.h"
#include "calaphot.h"

namespace LibJM {

    Calaphot * Calaphot::_unique_instance = 0;
    int Calaphot::_log_verbosity = Calaphot::Notice_Level;
    std::ofstream Calaphot::log_stream;

    Calaphot::Calaphot()
    {
    	log_stream.open(CALAPHOT_LOG_FILE_NAME, std::ios::trunc);
    	if( !log_stream )
    	{
    		std::cerr << "Error opening the log file " << CALAPHOT_LOG_FILE_NAME << std::endl;
    	}
    }

    Calaphot::~Calaphot()
    {
    	log_stream.close();
    }

    Calaphot * Calaphot::instance ()
    {
        if (_unique_instance == 0)
            _unique_instance = new Calaphot();
        return _unique_instance;
    }



    /*** Pour la mise au point de la modélisation
    #define TRACE_GAUSS
    #define TRACE_FONCTION
    #define TRACE_JACOBIEN
    #define TRACE_AJUSTEMENT
     */

#define NB_PARAM_GAUSS 7
#define CONDITION_ARRET_NORME 1e-12
#define NOMBRE_MAX_ITERATION 500



    /* Utilisation des routines spécifiques GSL non linéaires */
    /* En fait, ça ne marche pas (message d'erreur cryptique, pas d'information claire dans la doc */
    /*
#define GSL_NON_LINEAIRE
     */

    CBuffer * Calaphot::set_buffer (int tampon)
    {
        _buffer = CBuffer::Chercher (tampon);
        calaphot_debug ("tampon = "<< tampon << " buffer = "<< (void*) _buffer);
        if (_buffer)
            return _buffer;
        else
            return 0;
    }


    /*
	 ***************** LecturePixel ************
	 *
	 * Retourne la valeur d'un pixel
	 *******************************************
*/
    int Calaphot::LecturePixel(int x, int y, TYPE_PIXELS *pixel)
    {
        int plane = 0;
        try
        {
            _buffer->GetPix (&plane, pixel, pixel, pixel, x, y);
        }
        catch (const CError& e)
        {
            calaphot_error (e.gets() << "x=" << x << " y=" << y);
            *pixel = 0;
            throw e;
        }
        return 0;
    }

/*
	 ***************** EcriturePixel ************
	 *
	 * Ecrit la valeur d'un pixel
	 ********************************************
*/
    int Calaphot::EcriturePixel(int x, int y, TYPE_PIXELS pixel)
    {
        _buffer->SetPix (static_cast<TColorPlane>(0), pixel, x, y);
        return 0;
    }

/*
	 ***************** FluxEllipse ****************
	 *
	 *Calcul le flux dans une ellipse
	 **********************************************
*/
    void Calaphot::FluxEllipse(double x0, double y0, double r1x, double r1y, double ro, double r2, double r3, int c, double *flux, double *nb_pixel, double *fond, double *nb_pixel_fond, double *sigma_fond)
    {
        double flux_fond, flux_etoile, cinv, cinv2, flux_fond2;
        TYPE_PIXELS pixel;

        /* Initialisations */
        flux_fond = 0.0;
        flux_fond2 = 0.0;
        (*nb_pixel_fond) = 0.0;
        flux_etoile = 0.0;
        (*nb_pixel) = 0.0;
        cinv = 1.0 / (double)c;
        cinv2 = cinv * cinv;

        try
        {
            /* Recuperation des pixels de la couronne entre r2 et r3 */
            /* Bas de la couronne */
           // Les versions VisualC++ anterieures a VC90 ne suportent pas la redefinition des variables dans des boucles for cons�cutives
            for (double yy = (y0 - r3); yy <= (y0 - r2); yy++)
            {
                double x3 = (r3 * r3) - ((yy - y0) * (yy - y0));
                if (x3 < 0.0)
                    x3 = 0.0;
                double xmin = x0 - sqrt(x3);
                double xmax = x0 + sqrt(x3);

                int yi = (int)floor(yy + 0.5);
                for (double xx = xmin; xx <= xmax; xx++)
                {
                    int xi = (int)floor(xx + 0.5);
                    LecturePixel (xi, yi, &pixel);
                    flux_fond += pixel;
                    flux_fond2 += (pixel * pixel);
                    (*nb_pixel_fond)++;
                }
            }

            /* Milieu de la couronne (parties gauche et droite) */
            for (double yyy = (y0 - r2); yyy <= (y0 + r2); yyy++)
            {
                double x3 = (r3 * r3) - ((yyy - y0) * (yyy - y0));
                if (x3 < 0.0)
                    x3 = 0.0;
                double x2 = (r2 * r2) - ((yyy - y0) * (yyy - y0));
                if (x2 < 0.0)
                    x2 = 0.0;
                int yi = (int)floor(yyy + 0.5);

                double xmin = x0 - sqrt(x3);
                double xmax = x0 - sqrt(x2);
                for (double x = xmin; x <= xmax; x++)
                {
                    int xi = (int)floor(x + 0.5);
                    LecturePixel (xi, yi, &pixel);
                    flux_fond += pixel;
                    flux_fond2 += (pixel * pixel);
                    (*nb_pixel_fond)++;
                }

                xmin = x0 + sqrt(x2);
                xmax = x0 + sqrt(x3);
                for (double xx = xmin; xx <= xmax; xx++)
                {
                    int xi = (int)floor(xx + 0.5);
                    LecturePixel (xi, yi, &pixel);
                    flux_fond += pixel;
                    flux_fond2 += (pixel * pixel);
                    (*nb_pixel_fond)++;
                }
            }

            /* Haut de la couronne */
            for (double y = (y0 + r2); y <= (y0 + r3); y++)
            {
                double x3 = (r3 * r3) - ((y - y0) * (y - y0));
                if (x3 < 0.0)
                    x3 = 0.0;
                double xmin = x0 - sqrt(x3);
                double xmax = x0 + sqrt(x3);

                int yi = (int)floor(y + 0.5);
                for (double x = xmin; x <= xmax; x++)
                {
                    int xi = (int)floor(x + 0.5);
                    LecturePixel (xi, yi, &pixel);
                    flux_fond += pixel;
                    flux_fond2 += (pixel * pixel);
                    (*nb_pixel_fond)++;
                }
            }

            /* La valeur du flux de fond est la moyenne de toutes les valeurs lues dans la couronne. */
            *fond = flux_fond / (double) (*nb_pixel_fond);


            /* Calcul de l'ecart-type (formule de Koenig) */
            *sigma_fond = sqrt((flux_fond2 / *nb_pixel_fond) - (*fond) * (*fond));

            /* Calcul du flux dans l'ellipse (r1x, r1y) */


/*	for (y = (y0 - r1y); y <= (y0 + r1y); y += cinv)
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

            /* Calcul du flux dans l'ellipse (r1x, r1y, ro) */
            double delta_y = r1y / sqrt(1 - ro*ro);
            double delta_x = r1x / sqrt(1 - ro*ro);
            for (double y4 = (y0 - delta_y); y4 <= (y0 + delta_y); y4 += cinv)
            {
                int yi = (int)floor(y4 + 0.5);
                /* on pourrait optimiser en calculant la valeur de x sur l'ellipse */
                /* A faire a la retraite, a 85 ans ...*/
                for (double x = (x0 - delta_x); x <= (x0 + delta_x); x += cinv)
                {
                    double t = ((x-x0)*(x-x0))/(r1x*r1x) + ((y4-y0)*(y4-y0))/(r1y*r1y) - 2.0*ro*(x-x0)*(y4-y0)/(r1x*r1y) - 1.0;
                    if (t <= 0.0)
                    {
                        /* Le point (x,y) est dans l'ellipse */
                        int xi = (int)floor(x + 0.5);
                        LecturePixel (xi, yi, &pixel);
                        flux_etoile += pixel * cinv2;
                        (*nb_pixel) += cinv2;
                    }
                }
            }
        }
        catch ( const CError& e )
        {
            calaphot_error (e.gets() << " x0=" << x0 << " y0=" << y0 << " r1x=" << r1x << " r1y=" << r1y << " r2="<< r2 << " r3="<< r3);
            throw e;
        }

        *flux = flux_etoile - (*nb_pixel) * (*fond);
    }

int Calaphot::Magnitude(double flux_etoile, double flux_ref, double mag_ref, double *mag_etoile)
{
	if ((flux_etoile > 0.0) && (flux_ref > 0.0))
		*mag_etoile = mag_ref - 2.5 * log10(flux_etoile / flux_ref);
	else
		*mag_etoile = 99.99;

	return 0;
}

int Calaphot::Incertitude (double flux_etoile, double flux_fond, double nb_pixel, double nb_pixel_fond, double gain, double sigma, double *signal_bruit, double *incertitude, double *bruit_flux)
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


int Calaphot::LectureRectangle (rectangle * rect, gsl_vector *vect_s)
{
    TYPE_PIXELS valeur_pixel;
    int i = 0;

    for (int y = rect->y1; y <= rect->y2; y++)
    {
        for (int x = rect->x1; x <= rect->x2; x++)
        {
            try
            {
                LecturePixel(x, y, &valeur_pixel);
            }
            catch (const CError& e)
            {
                calaphot_error (e.gets() << " x=" << x << " y=" << y << " x1=" << rect->x1 << " y1=" << rect->y1 << " x2=" << rect->x2 << " y2=" << rect->y2);
                throw e;
            }
            gsl_vector_set (vect_s, i++, (double)valeur_pixel);
        }
    }
    return Generique::OK;
}

#ifdef GSL_NON_LINEAIRE
/* voir commantaire en t�te de fichier */
int fonction_minimale (const gsl_vector * param_gauss, void	* data, gsl_vector * f) {
	int x1, y1, x2, y2, nxy;
	double * pixels;
	double x0, y0;
	double sx, sy;
	double signal, fond;
	double ro;
	int x, y, i;
	double dy, dy2, gy, dx, dx2, gx, hxy, fxy;

#ifdef TRACE_FONCTION
	FILE * trace;
	trace = fopen("trace_fonction2.txt", "a");
	fprintf (trace, "------------------------------------\n");
#endif

	nxy = ((struct data *)data)->nxy;
	x1 = ((struct data *)data)->x1;
	y1 = ((struct data *)data)->y1;
	x2 = ((struct data *)data)->x2;
	y2 = ((struct data *)data)->y2;
	pixels = ((struct data *)data)->pixels;

	x0 = gsl_vector_get (param_gauss, 0);
	y0 = gsl_vector_get (param_gauss, 1);
	signal = gsl_vector_get (param_gauss, 2);
	fond = gsl_vector_get (param_gauss, 3);
	sx = gsl_vector_get (param_gauss, 4);
	sy = gsl_vector_get (param_gauss, 5);
	ro = gsl_vector_get (param_gauss, 6);

#ifdef TRACE_FONCTION
	fprintf (trace, "X0=%g|Y0=%g|S=%g|B=%g|Sx=%g|Sy=%g|Ro=%g\n", x0, y0, signal, fond, sx, sy, ro);
#endif

	i = 0;
	for (y = y1; y <= y2; y++) {
		dy = ((double)y - y0) / sy;
		dy2 = dy * dy;
		gy = exp (-dy2);
#ifdef TRACE_FONCTION
		fprintf (trace, "y=%d	", y);
#endif
		for (x = x1; x <= x2; x++) {
			dx = ((double)x - x0) / sx;
			dx2 = dx * dx;
			gx = exp (-dx2);
			hxy = exp (2.0 * ro * dx * dy);
			fxy = gx * gy * hxy;
			/* Vecteur � minimiser */
			gsl_vector_set (f, i, (pixels[i] - (signal * fxy + fond)));
#ifdef TRACE_FONCTION
			fprintf (trace, "%f / %f / %f	", pixels[i], signal * fxy + fond, (pixels[i] - (signal * fxy + fond)));
#endif
			i++;
		}
		fprintf (trace, "\n");
	}
#ifdef TRACE_FONCTION
	fclose (trace);
#endif
	return GSL_SUCCESS;
}

int jacobien (const gsl_vector * param_gauss, void	* data, gsl_matrix * J) {
	int x1, y1, x2, y2, nxy;
	double x0, y0;
	double sx, sy;
	double signal, fond;
	double ro;
	int x, y, i;
	double dy, dy2, gy, dx, dx2, gx, hxy, fxy;

#ifdef TRACE_JACOBIEN
	FILE * trace;
	int j;
	trace = fopen("trace_jacobien2.txt", "a");
	fprintf (trace, "------------------------------------\n");
#endif

	nxy = ((struct data *)data)->nxy;
	x1 = ((struct data *)data)->x1;
	y1 = ((struct data *)data)->y1;
	x2 = ((struct data *)data)->x2;
	y2 = ((struct data *)data)->y2;

	x0 = gsl_vector_get (param_gauss, 0);
	y0 = gsl_vector_get (param_gauss, 1);
	signal = gsl_vector_get (param_gauss, 2);
	fond = gsl_vector_get (param_gauss, 3);
	sx = gsl_vector_get (param_gauss, 4);
	sy = gsl_vector_get (param_gauss, 5);
	ro = gsl_vector_get (param_gauss, 6);

	i = 0;
	for (y = y1; y <= y2; y++) {
		dy = ((double)y - y0) / sy;
		dy2 = dy * dy;
		gy = exp (-dy2);
		for (x = x1; x <= x2; x++) {
			dx = ((double)x - x0) / sx;
			dx2 = dx * dx;
			gx = exp (-dx2);
			hxy = exp (2.0 * ro * dx * dy);
			fxy = gx * gy * hxy;

			/* dF/dX0 */
			gsl_matrix_set (J, i, 0, (2.0 * signal * fxy * ((dx - ro * dy) / sx)));
			/* dF/dY0 */
			gsl_matrix_set (J, i, 1, (2.0 * signal * fxy * ((dy - ro * dx) / sy)));
			/* dF/dS0 */
			gsl_matrix_set (J, i, 2, fxy);
			/* dF/dB */
			gsl_matrix_set (J, i, 3, 1.0);
			/* dF/dFwhmX */
			gsl_matrix_set (J, i, 4, (2.0 * signal * fxy * ((dx2 / sx) - (ro * dx * dy / sx))));
			/* dF/dFwhmY */
			gsl_matrix_set (J, i, 5, (2.0 * signal * fxy * ((dy2 / sy) - (ro * dx * dy / sy))));
			/* dF/dRo */
			gsl_matrix_set (J, i, 6, (2.0 * signal * fxy * dx * dy));

#ifdef TRACE_JACOBIEN
			fprintf (trace, "y=%d x=%d ", y, x);
			for (j=0; j<NB_PARAM_GAUSS; j++) {
				fprintf (trace, "%f ", gsl_matrix_get (J, i, j));
			}
			fprintf (trace, "\n");
#endif
			i++;
		}
	}
#ifdef TRACE_JACOBIEN
	fclose (trace);
#endif
	return GSL_SUCCESS;
}

int nappe_gaussienne (const gsl_vector * param_gauss, void * data, gsl_vector * f, gsl_matrix * J) {
	fonction_minimale (param_gauss, data, f);
	jacobien (param_gauss, data, J);

	return GSL_SUCCESS;
}

void print_state (FILE *trace, int iter, gsl_multifit_fdfsolver * s) {
	fprintf(trace, "iter=%d X0=%f|Y0=%f|S=%f|B=%f|Sx=%f|Sy=%f|Ro=%f|chi2=%f\n",
		iter,
		gsl_vector_get (s->x, 0),
		gsl_vector_get (s->x, 1),
		gsl_vector_get (s->x, 2),
		gsl_vector_get (s->x, 3),
		gsl_vector_get (s->x, 4),
		gsl_vector_get (s->x, 5),
		gsl_vector_get (s->x, 6),
		gsl_blas_dnrm2 (s->f)
		);
	fprintf(trace, "iter=%d dX0=%f|dY0=%f|dS=%f|dB=%f|dSx=%f|dSy=%f|dRo=%f|chi2=%f\n",
		iter,
		gsl_vector_get (s->dx, 0),
		gsl_vector_get (s->dx, 1),
		gsl_vector_get (s->dx, 2),
		gsl_vector_get (s->dx, 3),
		gsl_vector_get (s->dx, 4),
		gsl_vector_get (s->dx, 5),
		gsl_vector_get (s->dx, 6),
		gsl_blas_dnrm2 (s->f));
}

/* Algorithme de modelisation par		 */
/* S(x,y) = S0 * f(x,y) + B0, o�			*/
/* f(x,y) = exp(-X^2 - Y^2 + 2*Ro*X*Y) */
/* avec X = (x-x0)/sx								 */
/*			Y = (y-y0)/sy								 */
/*			(x0,y0) centroide						 */
/*			sx et sy ecart-types					*/
/*			|Ro| < 1											*/
void Gauss2(int x1, int y1, int x2, int y2, gsl_vector *vect_s, gsl_vector *vect_w, gsl_matrix *mat_x, gsl_vector *vect_c, gsl_matrix *covar, double *chi2, double *me1, struct ajustement *p, struct ajustement *incert, int *iter, int *convergence)
{
	const gsl_multifit_fdfsolver_type *T;
	gsl_multifit_fdfsolver *s;
	int nxy;
	gsl_multifit_function_fdf f;
	gsl_vector *param_gauss;
	struct data d;
	int status;

#ifdef TRACE_FONCTION
	FILE * trace_fonction;
	trace_fonction = fopen("trace_fonction2.txt", "w");
	fclose (trace_fonction);
#endif

#ifdef TRACE_JACOBIEN
	FILE * trace_jacobien;
	trace_jacobien = fopen("trace_jacobien2.txt", "w");
	fclose (trace_jacobien);
#endif

	FILE * trace;
	trace = fopen("trace_gauss2.txt", "w");

	param_gauss = gsl_vector_alloc(NB_PARAM_GAUSS);
	gsl_vector_set (param_gauss, 0, p->X0);
	gsl_vector_set (param_gauss, 1, p->Y0);
	gsl_vector_set (param_gauss, 2, p->Signal);
	gsl_vector_set (param_gauss, 3, p->Fond);
	gsl_vector_set (param_gauss, 4, p->Sigma_X);
	gsl_vector_set (param_gauss, 5, p->Sigma_Y);
	gsl_vector_set (param_gauss, 6, p->Ro);

	fprintf (trace, "---------param_gauss :---------\n");
	gsl_vector_fprintf (trace, param_gauss, "%f");

	nxy = (size_t)(x2 - x1 + 1) * (size_t)(y2 - y1 + 1);
	d.nxy = nxy;
	d.x1 = x1;
	d.x2 = x2;
	d.y1 = y1;
	d.y2 = y2;
	d.pixels = vect_s->data;

	f.f = &fonction_minimale;
	f.df = &jacobien;
	f.fdf = &nappe_gaussienne;
	f.n = nxy;
	f.p = NB_PARAM_GAUSS;
	f.params = &d;

	T = gsl_multifit_fdfsolver_lmsder;
	s = gsl_multifit_fdfsolver_alloc (T, nxy, NB_PARAM_GAUSS);
	if (s == 0) {
		fprintf (trace, "Mauvaise alloc\n");
		return;
	}
	status = gsl_multifit_fdfsolver_set (s, &f, param_gauss);
	fprintf (trace, "status=%d : %s\n", status, gsl_strerror (status));
	fprintf (trace, "s est un resolveur de type %s\n", gsl_multifit_fdfsolver_name (s));

	*iter = 0;
	print_state (trace, *iter, s);

	do {
		(*iter) ++;

		status = gsl_multifit_fdfsolver_iterate (s);
		fprintf (trace, "status=%d : %s\n", status, gsl_strerror (status));

		print_state (trace, (*iter), s);
		if (status) {
			break;
		}

		status = gsl_multifit_test_delta (s->dx, s->x, 0.0, 1e-6);

	} while (status == GSL_CONTINUE && (*iter) < 50);

	gsl_multifit_covar (s->J, 0.0, covar);

	gsl_multifit_fdfsolver_free (s);

	fclose(trace);
}

#endif /* GSL_NON_LINEAIRE */


/* Algorithme de modelisation par		 */
/* S(x,y) = S0 * f(x,y) + B0, ou			*/
/* f(x,y) = exp(-X^2 - Y^2 + 2*Ro*X*Y) */
/* avec X = (x-x0)/sx								 */
/*			Y = (y-y0)/sy								 */
/*			(x0,y0) centroide						 */
/*			sx et sy ecart-types					*/
/*			|Ro| < 1											*/
void Calaphot::Gauss (rectangle * rect, gsl_vector *vect_s, gsl_vector *vect_w, gsl_matrix *mat_x, gsl_vector *vect_c, gsl_matrix *mat_cov, double *chi2, double *me1, struct ajustement *p, struct ajustement *incert, int *iter)
{
    int x, y;
    double dy, dy2, gy, dx, dx2, gx, hxy, fxy, pxy;
    double norme = 0;
    size_t i;
    ajustement t;
    int erreur;
    double ancienne_norme = 1e9;
    int convergence;
    gsl_vector *vect_y;
    gsl_multifit_linear_workspace *bac;
    gsl_matrix *temp_cov;
    size_t nxy;

    memset (&t, 0, sizeof(struct ajustement));

#ifdef TRACE_GAUSS
    FILE * trace_gauss;
    trace_gauss = fopen("trace_gauss.txt", "w");
    fprintf(trace_gauss, "X0=%g|Y0=%g|S=%g|B=%g|Sx=%g|Sy=%g|Ro=%g\n", p->X0, p->Y0, p->Signal, p->Fond, p->Sigma_X, p->Sigma_Y, p->Ro);
#endif

#ifdef TRACE_FONCTION
    FILE * trace_fonction;
    trace_fonction = fopen("trace_fonction.txt", "w");
#endif

#ifdef TRACE_JACOBIEN
    int j;
    FILE * trace_jacobien;
    trace_jacobien = fopen("trace_jacobien.txt", "w");
#endif

    nxy = rect->nxy;

    vect_y = gsl_vector_alloc(nxy);
    bac = gsl_multifit_linear_alloc(nxy, 7);
    temp_cov = gsl_matrix_alloc(7, 7);

    convergence = -1;
    *iter = 0;
    while (convergence < 0)
    {
        i = 0;
        (*iter) ++;
#ifdef TRACE_FONCTION
        fprintf (trace_fonction, "-------iter = %d-----------------------------\n", *iter);
#endif
#ifdef TRACE_JACOBIEN
        fprintf (trace_jacobien, "------------------------------------\n");
#endif
        for (y = rect->y1; y <= rect->y2; y++)
        {
            dy = ((double)y - p->Y0) / p->Sigma_Y;
            dy2 = dy * dy;
            gy = exp (-dy2);
            for (x = rect->x1; x <= rect->x2; x++)
            {
                dx = ((double)x - p->X0) / p->Sigma_X;
                dx2 = dx * dx;
                gx = exp (-dx2);
                pxy = exp (p->Ro * dx * dy);
                if (pxy > 1e+130)
                {
                    /* risque de d�passement de hxy (+inf) */
                    convergence = 0; /* pour bloquer la boucle */
                    *iter = 0; /* signale une erreur */
#ifdef TRACE_FONCTION
                    fprintf (trace_fonction, "y=%d x=%d D�passement sur hxy !\n", y, x);
#endif
                    goto sortie;
                }
                hxy = pxy * pxy; /* c.a.d. hxy = exp(2.0 * p->Ro * dx * dy) */
                fxy = gx * gy * hxy;

                /* Matrice des points a faire correspondre */
                gsl_vector_set(vect_y, i, (gsl_vector_get(vect_s, i) - (p->Signal * fxy + p->Fond)));

#ifdef TRACE_FONCTION
                fprintf (trace_fonction, "y=%d x=%d dy=%f / dy2=%f / gy=%f / dx=%f / dx2=%f / gx=%e / hxy=%e / fxy=%e\n", y, x, dy, dy2, gy, dx, dx2, gx, hxy, fxy);
                fprintf (trace_fonction, "y=%d x=%d %f / %f / %f\n", y, x, gsl_vector_get(vect_s, i), (p->Signal * fxy + p->Fond), (gsl_vector_get(vect_s, i) - (p->Signal * fxy + p->Fond)));
#endif
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

#ifdef TRACE_JACOBIEN
                fprintf (trace_jacobien, "y=%d x=%d ", y, x);
                for (j=0; j<7; j++) {
                    fprintf (trace_jacobien, "%f ", gsl_matrix_get (mat_x, i, j));
                }
                fprintf (trace_jacobien, "\n");
#endif

                i++;

            }
#ifdef TRACE_FONCTION
            fprintf (trace_fonction, "\n");
#endif
        }
        erreur = gsl_multifit_wlinear(mat_x, vect_w, vect_y, vect_c, temp_cov, chi2, bac);
        if (erreur)
        {
            convergence = 0; /* pour bloquer la boucle */
            *iter = 0; /* signale une erreur */
            goto sortie;
        }

        /*
         * Le fait de n'additionner qu'une fraction de l'erreur de modelisation retarde la convergence
         * mais assure une convergence plus lin�aire (moins d'oscillations sur la valeur de la norme)
         */
        t.X0 = p->X0 + gsl_vector_get(vect_c,0) / 1.5;
        t.Y0 = p->Y0 + gsl_vector_get(vect_c,1) / 1.5;
        t.Signal = p->Signal + gsl_vector_get(vect_c,2) / 1.5;
        t.Fond = p->Fond + gsl_vector_get(vect_c,3) / 1.5;
        t.Sigma_X = p->Sigma_X + gsl_vector_get(vect_c,4) / 1.5;
        t.Sigma_Y = p->Sigma_Y + gsl_vector_get(vect_c,5) / 1.5;
        if (fabs(t.Ro) > .9)
            t.Ro = p->Ro + (gsl_vector_get(vect_c,6) / 10.0);
        else
            t.Ro = p->Ro + gsl_vector_get(vect_c,6) / 1.5;

        norme = gsl_blas_dnrm2(vect_y);

#ifdef TRACE_GAUSS
        fprintf (trace_gauss, "dX0=%f|dY0=%f|dS=%f|dB=%f|dSx=%f|dSy=%f|dRo=%f|chi2=%g| ||F||=%g dF=%e\n",
                gsl_vector_get(vect_c,0) / 1.5,
                gsl_vector_get(vect_c,1) / 1.5,
                gsl_vector_get(vect_c,2) / 1.5,
                gsl_vector_get(vect_c,3) / 1.5,
                gsl_vector_get(vect_c,4) / 1.5,
                gsl_vector_get(vect_c,5) / 1.5,
                gsl_vector_get(vect_c,6) / 1.5,
                *chi2, norme, fabs(norme - ancienne_norme));
        fprintf (trace_gauss, " X0=%f| Y0=%f| S=%f| B=%f| Sx=%f| Sy=%f| Ro=%f|chi2=%g| ||F||=%g dF=%e\n", t.X0, t.Y0, t.Signal, t.Fond, t.Sigma_X, t.Sigma_Y, t.Ro, *chi2, norme, fabs(norme - ancienne_norme));
#endif
        /* Detection des cas d'arret */
        if ( (norme > ancienne_norme) || (fabs(norme - ancienne_norme) < CONDITION_ARRET_NORME) )
            convergence = 1;
        else {
            ancienne_norme = norme;

            if ((t.X0 < rect->x1)				 /* la modelisation sort du cadre entourant l'image */
                    || (t.X0 > rect->x2)
                    || (t.Y0 < rect->y1)
                    || (t.Y0 > rect->y2)
                    || (t.Sigma_X < 0.25)		/* l'ecart-type ne peut pas etre trop petit (et encore moins negatif) */
                    || (t.Sigma_Y < 0.25)
                    || (fabs(t.Ro) >= 0.985)	/* |ro| est forcement < 1 */
                    || (*iter > NOMBRE_MAX_ITERATION)			 /* Convergence qui prendrait un temps "infini" */
                    || ((t.Sigma_X / t.Sigma_Y) >= 50.0)
                    || ((t.Sigma_Y / t.Sigma_X) >= 50.0))
            {
                convergence = 1;
            } else {
                p->X0 = t.X0;
                p->Y0 = t.Y0;
                p->Signal = t.Signal;
                p->Fond = t.Fond;
                p->Sigma_X = t.Sigma_X;
                p->Sigma_Y = t.Sigma_Y;
                p->Ro = t.Ro;

                gsl_matrix_memcpy(mat_cov, temp_cov);
            }
        }
    }

    *me1 = sqrt(*chi2 / (nxy - 7));

    incert->X0 = *me1 * sqrt(gsl_matrix_get(mat_cov, 0, 0));
    incert->Y0 = *me1 * sqrt(gsl_matrix_get(mat_cov, 1, 1));
    incert->Signal = *me1 * sqrt(gsl_matrix_get(mat_cov, 2, 2));
    incert->Fond = *me1 * sqrt(gsl_matrix_get(mat_cov, 3, 3));
    incert->Sigma_X = *me1 * sqrt(gsl_matrix_get(mat_cov, 4, 4));
    incert->Sigma_Y = *me1 * sqrt(gsl_matrix_get(mat_cov, 5, 5));
    incert->Ro = *me1 * sqrt(gsl_matrix_get(mat_cov, 6, 6));

sortie :
    gsl_multifit_linear_free(bac);
    gsl_vector_free(vect_y);
    gsl_matrix_free(temp_cov);

#ifdef TRACE_FONCTION
    fclose (trace_fonction);
#endif
#ifdef TRACE_JACOBIEN
    fclose (trace_jacobien);
#endif
#ifdef TRACE_GAUSS
    fclose (trace_gauss);
#endif
}

void Calaphot::InitRectangle (int * cadre, rectangle * rect) {

	/* Tri des x1, x2 et y1, y2 */
	if (cadre[0] > cadre[2]) {
		rect->x1 = cadre[2];
		rect->x2 = cadre[0];

	} else {
		rect->x2 = cadre[2];
		rect->x1 = cadre[0];
	}

	if (cadre[1] > cadre[3]) {
		rect->y1 = cadre[3];
		rect->y2 = cadre[1];
	} else {
		rect->y2 = cadre[3];
		rect->y1 = cadre[1];
	}

	rect->nx = rect->x2 - rect->x1 + 1;
	rect->ny = rect->y2 - rect->y1 + 1;
	rect->nxy = (size_t) (rect->nx * rect->ny);
 }

/**************************************************************/
/* Ajustement d'un morceau d'image par une surface gaussienne */
/* Calcul du flux donne par le modele												 */
/**************************************************************/
int Calaphot::AjustementGaussien(int *carre, double *fgauss, double *stat, ajustement *valeurs, ajustement *incertitudes, int *iter, double *chi2, double *erreur)
{
	rectangle rect;
	double sx, sx2, sy, sy2, alpha2, alpha, p, q, sxp, syp, ro;
	double dro, dsx, dsy, a, b, c, da, db, dc, temp_a, dalpha_da, dalpha_db, dalpha_dc, dalpha;
	gsl_vector *vect_w, *vect_s, *vect_c;
	gsl_matrix *mat_x, *mat_cov;

#ifdef TRACE_AJUSTEMENT
	FILE * trace;
	trace = fopen("ajustement_gaussien.txt", "a");
#endif

	InitRectangle (carre, &rect);

#ifdef TRACE_AJUSTEMENT
	fprintf (trace, "**********************************************************\n");
	fprintf (trace, "[%d-%d]-[%d-%d]\n", rect.x1, rect.y1, rect.x2, rect.y2);
#endif

    if (rect.nxy <= 7)
    {
        /*
		Par définition, le nombre d'échantillons doit être au moins égal au nombre de paramètres du modèle (7 en l'occurence)
         */
        *iter = 0;
        return 0;
    }

    /* Creation des objets gsl */
    vect_w = gsl_vector_alloc(rect.nxy);
    vect_s = gsl_vector_alloc(rect.nxy);
    vect_c = gsl_vector_alloc(7);
    mat_x = gsl_matrix_alloc(rect.nxy, 7);
    mat_cov = gsl_matrix_alloc(7, 7);

    /* Lecture du rectangle et */
    /* stockage des valeurs des pixels dans le vecteur s */
    try
    {
        LectureRectangle (&rect, vect_s);
    }
    catch (const CError& e)
    {
        calaphot_error (e.gets ());
        *iter = 0;
        gsl_matrix_free(mat_cov);
        gsl_matrix_free(mat_x);
        gsl_vector_free(vect_c);
        gsl_vector_free(vect_s);
        gsl_vector_free(vect_w);
        throw e;
    }

#ifdef TRACE_AJUSTEMENT
	fprintf (trace, "fitgauss : Axe X S=%f X0=%f fwhm=%f fond=%f\n",
		fgauss[0], fgauss[1], fgauss[2], fgauss[3]);

	fprintf (trace, "fitgauss : Axe Y S=%f Y0=%f fwhm=%f fond=%f\n",
		fgauss[4], fgauss[5], fgauss[6], fgauss[7]);
#endif

	/* Valeurs pour l'initialisation de la boucle de calcul */
	/* Fond = fond */
	valeurs->Fond = (fgauss[3] + fgauss[7]) / 2.0;
	/* Signal = max - fond */
	valeurs->Signal = (double)(fgauss[0] + fgauss[4]) / 2.0;
	/* Centroide potentiel */
	/*
	* Si fitgauss retourne un centroide trop desaxé par rapport à la fenêtre
	* (dans le 1er ou le dernier quart), la valeur de départ sera le bête centre de la fenêtre
	*/

	if ((fgauss[1] < (3*rect.x1 + rect.x2) /4) || (fgauss[1] > (rect.x1 + 3*rect.x2)/4)) {
		valeurs->X0 = (rect.x1 + rect.x2) / 2;
	}
	else {
		valeurs->X0 = fgauss[1];
	}

	if ((fgauss[5] < (3*rect.y1 + rect.y2) /4) || (fgauss[5] > (rect.y1 + 3*rect.y2)/4)) {
		valeurs->Y0 = (rect.y1 + rect.y2) / 2;
	}
	else {
		valeurs->Y0 = fgauss[5];
	}

	/* Les FWHM doivent �tre convertis en sigma*/
	valeurs->Sigma_X = fgauss[2] / 1.66511;
	valeurs->Sigma_Y = fgauss[6] / 1.66511;
	/* Au hasard */
	valeurs->Ro = 0.0;

	*chi2 = 0.0;

#ifdef TRACE_AJUSTEMENT
	fprintf (trace, "Avant : X0=%f Y0=%f Ampl=%f Fond=%f Sx=%f Sy=%f Ro=%f\n",
		valeurs->X0,
		valeurs->Y0,
		valeurs->Signal,
		valeurs->Fond,
		valeurs->Sigma_X,
		valeurs->Sigma_Y,
		valeurs->Ro);
#endif

	/* Initialisations du vecteur de ponderation */
	if (stat[7] != 0.0)
		gsl_vector_set_all(vect_w, 1.0 / stat[7] / stat[7]);
	else
		gsl_vector_set_all(vect_w, 1.0);

	/* Cas d'une image constante : on sort tout de suite, la modelisation n'a pas de sens */
	if (valeurs->Signal == 0) {
		*iter = 0;
		gsl_matrix_free(mat_cov);
		gsl_matrix_free(mat_x);
		gsl_vector_free(vect_c);
		gsl_vector_free(vect_s);
		gsl_vector_free(vect_w);
		return 0;
	}

	Gauss (&rect, vect_s, vect_w, mat_x, vect_c, mat_cov, chi2, erreur, valeurs, incertitudes, iter);

/*
	Gauss2 (x1, y1, x2, y2, vect_s, vect_w, mat_x, vect_c, mat_cov, chi2, &me1, valeurs, incertitudes, iter, convergence);
*/

#ifdef TRACE_AJUSTEMENT
	fprintf (trace, "%d iterrations, erreur = %f\n", *iter, *erreur);

	fprintf (trace, "Apr�s : X0=%f Y0=%f Ampl=%f Fond=%f Sx=%f Sy=%f Ro=%f\n",
		valeurs->X0,
		valeurs->Y0,
		valeurs->Signal,
		valeurs->Fond,
		valeurs->Sigma_X,
		valeurs->Sigma_Y,
		valeurs->Ro);
#endif

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
	}
	else {
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

	gsl_matrix_free(mat_cov);
	gsl_matrix_free(mat_x);
	gsl_vector_free(vect_c);
	gsl_vector_free(vect_s);
	gsl_vector_free(vect_w);

#ifdef TRACE_AJUSTEMENT
	fclose (trace);
#endif

	return 0;
}


int Calaphot::SoustractionGaussienne(int *carre, ajustement *p)
{
    int x1, y1, x2, y2;
    TYPE_PIXELS valeur_pixel;

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

    try
    {
        for ( int y = y1; y <= y2; y++) {
            double dy = ((double)y - p->Y0) / p->Sigma_Y;
            double dy2 = dy * dy;
            double gy = exp(-dy2);
            for (int x = x1; x <= x2; x++) {
                double dx = ((double)x - p->X0) / p->Sigma_X;
                double dx2 = dx * dx;
                double gx = exp(-dx2);
                double hxy = exp(2.0 * p->Ro * dx * dy);
                double fxy = gx * gy * hxy;
                /* On calcule la gaussienne, mais on ne tient pas compte du fond de ciel ! */
                int gaussienne = (int)(p->Signal * fxy);

                LecturePixel(x, y, &valeur_pixel);
                valeur_pixel -= gaussienne;
                if (valeur_pixel < 0)
                    valeur_pixel = 0;
                EcriturePixel(x, y, valeur_pixel);
            }
        }
    }
    catch ( const CError& e )
    {
        calaphot_error (e.gets() << " x1=" << carre[0] << " y1=" << carre[1] << " x2=" << carre[2] << " y2=" << carre[3]);
        throw e;
    }
    return 0;
}

}
