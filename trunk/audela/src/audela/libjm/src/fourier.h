/***
 * @file : fourier.h
 * @brief : description de l'objet Fourier
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
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

#ifndef __LIBJM_FOURIER_H__
#define __LIBJM_FOURIER_H__

namespace LibJM
{

/* --- Macros pour générer des traces --- */
#ifndef __FOURIER_STRINGIFY
# define __FOURIER_TSTRHELPER(x) #x
# define __FOURIER_STRINGIFY(y) __FOURIER_TSTRHELPER(y)
#endif /* __FOURIER_STRINGIFY  */

#  define fourier_short_log(level,__s)                                  \
    if (level <= Fourier::_log_verbosity) { fourier_short_log_on_stream(log_stream,__FOURIER_STRINGIFY(level),__s) }

#  define fourier_log(level,__s)                                        \
    if (level <= Fourier::_log_verbosity) { fourier_log_on_stream(log_stream,__FOURIER_STRINGIFY(level),__s) }

#  define fourier_verbose_log(level,__s)                                \
    if (level <= Fourier::_log_verbosity) { fourier_verbose_log_on_stream(log_stream,__FOURIER_STRINGIFY(level),__s) }

#define fourier_short_log_on_stream(__stream, level, str)    \
    {                                                        \
        (__stream) << str ;                                  \
        (__stream).flush();                                  \
    }

#define fourier_log_on_stream(__stream,level,str)   \
    {                                               \
        (__stream) << str << "\n";                  \
        (__stream).flush();                         \
    }
#if defined(__GNUC__)
#   define fourier_verbose_log_on_stream(__stream,level,str)    \
    {                                                                   \
        (__stream) << "[" << level << "] " <<__FILE__ << ":" << __LINE__ << " ("<<__PRETTY_FUNCTION__<<") -" << "- " << str << "\n"; \
        (__stream).flush();                                             \
    }
#   else /* !__GNUC__ */
#   define fourier_verbose_log_on_stream(__stream,level,str)            \
    (__stream) << "[" << level << "] " << __FILE__ << ":" << __LINE__ << " -" << str << "\n"; \
    (__stream).flush();
#  endif /* !__GNUC__*/

# define fourier_error(__s)    fourier_log(Fourier::Error_Level,__s)
# define fourier_warning(__s)  fourier_log(Fourier::Warning_Level,__s)
# define fourier_notice(__s)   fourier_log(Fourier::Notice_Level,__s)
# define fourier_info1(__s)    fourier_verbose_log(Fourier::Info1_Level,__s)
# define fourier_info2(__s)    fourier_verbose_log(Fourier::Info2_Level,__s)
# define fourier_info3(__s)    fourier_verbose_log(Fourier::Info3_Level,__s)
#undef FOURIER_DEBUG_VALIDE
#ifdef FOURIER_DEBUG_VALIDE
# define fourier_debug(__s)    fourier_verbose_log(Fourier::Debug_Level,__s)
# define fourier_debug2(__s)   fourier_short_log(Fourier::Debug_Level,__s)
#else
# define fourier_debug(__s)
# define fourier_debug2(__s)
#endif

class Fourier {
public :
    enum ordre { REGULAR, CENTERED, NO_ORDER };
    enum type { REAL, IMAG, SPECTRUM, PHASE, NO_TYPE };
    enum format { POLAR, POLAR2, CARTESIAN, NO_FORMAT };
    enum operateur { CORRELATION, CONVOLUTION };
    enum multiply { STANDARD, CONJUGATE };
    enum log_level
    {
        Deaf_Level = 0,
        Critical_Level = 1,
        Error_Level = 2,
        Warning_level = 3,
        Notice_Level = 4,
        Info1_Level = 5,
        Info2_Level = 6,
        Info3_Level = 7,
        Debug_Level = 9
    };

    static int _log_verbosity;
    static std::ofstream log_stream;
    static std::string fourier_log_file_name;

    struct TableauPixels {
    public :
        static int compteur;
        TYPE_PIXELS * get_ptr() { return pointeur; };
        int get_ref() { return reference; };
        unsigned int get_num() { return numero; };
        void incr_ref( int );
        void decr_ref( int );
        void set_free( bool );
        TableauPixels( );
        TableauPixels( unsigned int );
        TableauPixels( unsigned int, int );
        TableauPixels( TYPE_PIXELS * );
        ~TableauPixels( );
    private :
        TYPE_PIXELS* pointeur;
        unsigned int reference;
        bool do_not_free;
        unsigned int numero;
    };

    class Parametres {
    public :
        static int compteur;
        CFitsKeywords * cfitskeywords;
        int largeur;
        int hauteur;
        float norm;
        float talon;
        Fourier::ordre ordre;
        Fourier::type type;
    private :
        int numero;
        TableauPixels * _tab_pixels;
    public :
        void set_tab_pixels( TableauPixels * );
        void set_tab_pixels( TableauPixels *, bool );
        TableauPixels * get_tab_pixels() { return _tab_pixels; };
        TYPE_PIXELS * get_tab_pixels_ptr( );
        Parametres( );
        Parametres( int, int, Fourier::ordre, Fourier::type );
        ~Parametres( );
        void init( int, int, Fourier::ordre, Fourier::type );
        void copie( Fourier::Parametres & );
    };
    Fourier( );
    ~Fourier( );
    static Fourier * _unique_instance;
    static Fourier * instance( );


    static int CmdFourierDirect( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdFourierInverse( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdAutoCorrelation( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdInterCorrelation( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdConvolution( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdNiveauTraces( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    template<class T>
        static inline T& REAL_PART( T* z, int i ) { return z[2 * i]; };
    template<class T>
        static inline T& IMAG_PART( T* z, int i ) { return z[2 * i + 1]; };
    static inline double module ( double* z, int i ) { return hypot( REAL_PART( z, i), IMAG_PART( z, i) ); }
    static inline double argument( double* z, int i ) { return atan2( IMAG_PART( z, i), REAL_PART( z, i) ); }
    static inline double module_carre ( double* z, int i ) { return REAL_PART( z, i) * REAL_PART( z, i) + IMAG_PART( z, i) * IMAG_PART( z, i ); }
    void niveau_traces( int );

private :
    /* Algorithmes sur les images */
    void tfd_directe_image( const char *, const char *, const char *, Fourier::format, Fourier::ordre );
    void tfd_inverse_image( const char * src_1, const char * src_2, const char * dest );
    void correl_convol_image ( const char * src_1, const char * src_2, const char * dest, Fourier::operateur op, Fourier::ordre, bool );
    void coherence_images_tfd( Fourier::Parametres * param_1, Fourier::Parametres * param_2 );
    void ouverture_image(const char * nom, Fourier::Parametres * param );

    /* Calculs de TFD et autres */
    double * tfd_2d( double *, int, int, gsl_fft_direction );
    int tfd_2d_inverse_complete( Fourier::Parametres *, Fourier::Parametres *, TYPE_PIXELS *, int ) ;
    int tfd_2d_directe_complete( Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres *, int ) ;
    int tfd_2d_directe_simple( Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres * ) ;
    int tfd_2d_inverse_simple( Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres * ) ;
    void produit_complexe( Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres *, Fourier::Parametres *, Fourier::multiply );
    void normalisation( Fourier::Parametres *, TYPE_PIXELS, TYPE_PIXELS, Fourier::ordre );
    void extrema( Fourier::Parametres *, TYPE_PIXELS *, TYPE_PIXELS * );
    Fourier::Parametres * inclusion( Fourier::Parametres * p1, Fourier::Parametres * p2 );

    /* Autres routines */
    Fourier::type analyse_dft_type( const char * );
    Fourier::ordre analyse_dft_ordre( const char * );

};


#define REAL(z,i) ((z)[2*(i)])
#define IMAG(z,i) ((z)[2*(i)+1])
}

#endif // __LIBJM_FOURIER_H__

