/***
 * @file : calaphot.h
 * @brief : définition des macros et des objets se rapportant à la photométrie et à la modélisation
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: calaphot.h,v 1.8 2010-06-20 12:18:20 jacquesmichelet Exp $
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

/* --- Macros pour générer des traces --- */
#ifndef __CALAPHOT_STRINGIFY
# define __CALAPHOT_TSTRHELPER(x) #x
# define __CALAPHOT_STRINGIFY(y) __CALAPHOT_TSTRHELPER(y)
#endif /* __CALAPHOT_STRINGIFY  */

#  define calaphot_log(level,__s) \
    if (level >= Calaphot::_log_verbosity) { calaphot_log_on_stream(log_stream,__CALAPHOT_STRINGIFY(level),__s) }

#  define calaphot_verbose_log(level,__s) \
    if (level >= Calaphot::_log_verbosity) { calaphot_verbose_log_on_stream(log_stream,__CALAPHOT_STRINGIFY(level),__s) }

#  if defined(__GNUC__)
#   define calaphot_log_on_stream(__stream,level,str) \
                 (__stream) << str << "\n"; \
                 (__stream).flush();
#   define calaphot_verbose_log_on_stream(__stream,level,str) \
                 (__stream) << "[" << level << "] " <<__FILE__ << ":" << __LINE__ << " ("<<__PRETTY_FUNCTION__<<") -" << "- " << str << "\n"; \
                 (__stream).flush();
#   else /* !__GNUC__ */
#   define calaphot_log_on_stream(__stream,level,str) \
                 (__stream) << str << "\n"; \
                 (__stream).flush();
#   define calaphot_verbose_log_on_stream(__stream,level,str) \
                 (__stream) << "[" << level << "] " << __FILE__ << ":" << __LINE__ << " -" << str << "\n"; \
                 (__stream).flush();
#  endif /* !__GNUC__*/

# define calaphot_error(__s)    calaphot_log(Calaphot::Error_Level,__s)
# define calaphot_warning(__s)  calaphot_log(Calaphot::Warning_Level,__s)
# define calaphot_notice(__s)   calaphot_log(Calaphot::Notice_Level,__s)
# define calaphot_info1(__s)    calaphot_verbose_log(Calaphot::Info1_Level,__s)
# define calaphot_info2(__s)    calaphot_verbose_log(Calaphot::Info2_Level,__s)
# define calaphot_info3(__s)    calaphot_verbose_log(Calaphot::Info3_Level,__s)
# define calaphot_debug(__s)    calaphot_verbose_log(Calaphot::Debug_Level,__s)

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
    static int CmdFluxEllipse( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdAjustementGaussien(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdNiveauTraces(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );

    static int _log_verbosity;
    static std::ofstream log_stream;
    static std::string calaphot_log_file_name;

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
    int CmdMagnitude( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    int CmdIncertitude( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );

    int AjustementGaussien( int *, double *, double *, Calaphot::ajustement *, Calaphot::ajustement *, int *, double *, double * );
    int SoustractionGaussienne( int *, Calaphot::ajustement * );
    int Magnitude( double, double, double, double * );
    void niveau_traces( int );

    CBuffer * set_buffer (int);
};

}

#endif // __LIBJM_CALAPHOT_H__