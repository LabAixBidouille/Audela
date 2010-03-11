/* calaphot.h
 *
 * This file is part of the libjm library for AudeLA project.
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

#ifndef __LIBJM_CALAPHOT_H__
#define __LIBJM_CALAPHOT_H__

namespace LibJM {
/* Declaration des structures */


struct data {
	int nxy;
	int x1;
	int y1;
	int x2;
	int y2;
	double * pixels;
};

#define CALAPHOT_LOG_FILE_NAME "libjm_calaphot.log"

/* --- Macros pour générer des traces --- */
#ifndef __CALAPHOT_STRINGIFY
# define __CALAPHOT_TSTRHELPER(x) #x
# define __CALAPHOT_STRINGIFY(y) __CALAPHOT_TSTRHELPER(y)
#endif /* __CALAPHOT_STRINGIFY  */

#  define sdsp_log(level,__s) \
    if (level >= Calaphot::_log_verbosity) { sdsp_log_on_stream(log_stream,__CALAPHOT_STRINGIFY(level),__s) }

#  define sdsp_verbose_log(level,__s) \
    if (level >= Calaphot::_log_verbosity) { sdsp_verbose_log_on_stream(log_stream,__CALAPHOT_STRINGIFY(level),__s) }

#  if defined(__GNUC__)
#   define sdsp_log_on_stream(__stream,level,str) \
                 (__stream) << str << "\n"; \
                 (__stream).flush();
#   define sdsp_verbose_log_on_stream(__stream,level,str) \
                 (__stream) << "[" << level << "] " <<__FILE__ << ":" << __LINE__ << " ("<<__PRETTY_FUNCTION__<<") -" << "- " << str << "\n"; \
                 (__stream).flush();
#  else /* !__GNUC__ */
#   define sdsp_log_on_stream(__stream,level,str) \
                 (__stream) << str << "\n"; \
                 (__stream).flush();
#   define sdsp_verbose_log_on_stream(__stream,level,str) \
                 (__stream) << "[" << level << "] " << __FILE__ << ":" << __LINE__ << " -" << str << "\n"; \
                 (__stream).flush();
#  endif /* !__GNUC__*/

#if 0
#if defined(WIN32) && defined(_MSC_VER) &&( _MSC_VER < 1500)
// Les versions VisualC++ anterieures a VC90 ne suportent pas les macros avec un nombre de parametre variable
#define CALAPHOT_LOG_FILE
#define CALAPHOT_LOG
# define calaphot_error
# define calaphot_warning
# define calaphot_notice
# define calaphot_info_1
# define calaphot_info_2
# define calaphot_info_3
# define calaphot_debug
#else
#endif
#endif

# define calaphot_error(__s)    sdsp_log(Calaphot::Error_Level,__s)
# define calaphot_warning(__s)  sdsp_log(Calaphot::Warning_Level,__s)
# define calaphot_notice(__s)   sdsp_log(Calaphot::Notice_Level,__s)
# define calaphot_info1(__s)    sdsp_verbose_log(Calaphot::Info1_Level,__s)
# define calaphot_info2(__s)    sdsp_verbose_log(Calaphot::Info2_Level,__s)
# define calaphot_info3(__s)    sdsp_verbose_log(Calaphot::Info3_Level,__s)
# define calaphot_debug(__s)    sdsp_verbose_log(Calaphot::Debug_Level,__s)




class Calaphot
{
public :
    struct ajustement
    {
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
    struct rectangle {
        int x1;
        int x2;
        int y1;
        int y2;
        int nx;
        int ny;
        size_t nxy;
    };

    enum log_level
    {
        Error_Level = 7,
        Warning_level = 6,
        Notice_Level = 5,
        Info1_Level = 4,
        Info2_Level = 3,
        Info3_Level = 2,
        Debug_Level = 1
    };
    static Calaphot * instance();
    static int CmdFluxEllipse (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    static int CmdAjustementGaussien (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    static int CmdVersionLib (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    int CmdMagnitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    int CmdIncertitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

    int AjustementGaussien (int *carre, double *fgauss, double *stat, Calaphot::ajustement *valeur, Calaphot::ajustement *incertitude, int *iter, double *chi2, double*erreur);
    int SoustractionGaussienne (int *carre, Calaphot::ajustement *p);
    int Magnitude(double flux_etoile, double flux_ref, double mag_ref, double *mag_etoile);
    CBuffer * set_buffer (int);
    static int _log_verbosity;
    static std::ofstream log_stream;

private :
    Calaphot();
    ~Calaphot();
    static Calaphot * _unique_instance;
    CBuffer * _buffer;
    void Gauss (struct rectangle * rect, gsl_vector *vect_s, gsl_vector *vect_w, gsl_matrix *mat_x, gsl_vector *vect_c, gsl_matrix *mat_cov, double *chi2, double *me1, Calaphot::ajustement *p, Calaphot::ajustement *incert, int *iter);
    int LecturePixel (int x, int y, TYPE_PIXELS *pixel);
    int EcriturePixel (int x, int y, TYPE_PIXELS pixel);
    void FluxEllipse (double x0, double y0, double r1x, double r1y, double ro, double r2, double r3, int c, double *flux, double *nb_pixel, double *fond, double *nb_pixel_fond, double *sigma_fond);
    int LectureRectangle (struct rectangle * rect, gsl_vector *vect_s);
    int Incertitude (double flux_etoile, double flux_fond, double nb_pixel, double nb_pixel_fond, double gain, double sigma, double *signal_bruit, double *incertitude, double *bruit_flux);
    void InitRectangle (int * cadre, rectangle * rect);
};

}

#endif // __LIBJM_CALAPHOT_H__
