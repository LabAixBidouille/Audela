/***
 * @file : fourier_services.cpp
 * @brief : Méthodes de l'objet Fourier : gestion des objets
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: fourier_services.cpp,v 1.4 2010-06-19 17:11:50 jacquesmichelet Exp $
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
#include <sysexp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gsl/gsl_fft_complex.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_fft.h>

#include "cerror.h"
#include "libtt.h"
#include "cbuffer.h"
#include "cpixels.h"
#include "cpixelsgray.h"
#include "cfile.h"
#include "libjm.h"
#include "fourier.h"

namespace LibJM {
Fourier * Fourier::_unique_instance = 0;
int Fourier::_log_verbosity = Fourier::Info1_Level;
std::ofstream Fourier::log_stream;
std::string Fourier::fourier_log_file_name("libjm_fourier.log");

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Fourier()
{
    std::string nom_fichier_log;
    if ( LibJM::Generique::repertoire_log )
    {
        nom_fichier_log = LibJM::Generique::repertoire_log;
#if defined(WIN32)
        nom_fichier_log = nom_fichier_log + "\\";
#else
        nom_fichier_log = nom_fichier_log + "/";
#endif
    }
    nom_fichier_log = nom_fichier_log + fourier_log_file_name;

    log_stream.open( nom_fichier_log.c_str(), std::ios::trunc );
    if( !log_stream )
    {
        std::cerr << "Error opening the log file " << nom_fichier_log << std::endl;
    }
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::~Fourier()
{
    log_stream.close();
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier * Fourier::instance ()
{
    if (_unique_instance == 0)
        _unique_instance = new Fourier();
    return _unique_instance;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::niveau_traces( int niveau )
{
    _log_verbosity = niveau;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::type Fourier::analyse_dft_type( const char * type ) {
    if ( strncmp( type, "REAL" , 4 ) == 0 )
        return Fourier::REAL;
    else if ( strncmp( type, "IMAG", 4 ) == 0 )
        return Fourier::IMAG;
    else if ( strncmp( type, "SPECTRUM", 8 ) == 0 )
        return Fourier::SPECTRUM;
    else if ( strncmp( type, "PHASE", 5 ) == 0 )
        return Fourier::PHASE;
    else return Fourier::NO_TYPE;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::ordre Fourier::analyse_dft_ordre( const char * type ) {
    if ( strncmp( type, "CENTERED", 8 ) == 0 )
        return Fourier::CENTERED;
    else if ( strncmp( type, "REGULAR", 7 ) == 0 )
        return Fourier::REGULAR;
    else return Fourier::NO_ORDER;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::Parametres::compteur = 0;
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres::Parametres() :
        largeur(0),
        hauteur(0),
        norm(1.0),
        talon(0.0),
        ordre(Fourier::NO_ORDER),
        type(Fourier::NO_TYPE)
{
    numero = ++compteur;
    set_tab_pixels(0);
    fourier_info3( "constructeur de Fourier::Parametre no " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::copie( Fourier::Parametres & origine )
{
    cfitskeywords = origine.cfitskeywords;
    largeur = origine.largeur;
    hauteur = origine.hauteur;
    norm = origine.norm;
    talon = origine.talon;
    ordre = origine.ordre;
    type = origine.type;
    set_tab_pixels( origine.get_tab_pixels() );
    fourier_info3( "copie de Fourier::Parametre no " << origine.numero << " vers " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres::Parametres( int l, int h, Fourier::ordre o, Fourier::type t ) :
    largeur(l),
    hauteur(h),
    norm(1.0),
    talon(0.0),
    ordre(o),
    type(t)
{
    TableauPixels * tp = new TableauPixels( largeur * hauteur * sizeof(TYPE_PIXELS) );
    set_tab_pixels( tp );
    numero = ++compteur;
    fourier_info3( "constructeur de Fourier::Parametre no " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::init( int l, int h, Fourier::ordre o, Fourier::type t )
{
    largeur = l;
    hauteur = h;
    norm = 1.0;
    talon = 0.0;
    ordre = o;
    type = t;
    if (get_tab_pixels() )
        delete get_tab_pixels();
    TableauPixels * tp = new TableauPixels( largeur * hauteur * sizeof(TYPE_PIXELS) );
    set_tab_pixels( tp );
    fourier_info3( "Init de Fourier::Parametre no " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::set_tab_pixels( TableauPixels * tp )
{
    _tab_pixels = tp ;
    if ( tp )
    {
        tp->incr_ref(1);
        fourier_info3( "Fourier::Parametres no " << numero << " a le Fourier::TableauPixels no " << _tab_pixels->get_num() );
    }
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::set_tab_pixels( TableauPixels * tp, bool do_not_free )
{
    _tab_pixels = tp ;
    if ( tp )
    {
        tp->incr_ref( 1 );
        tp->set_free( do_not_free );
        fourier_info3( "Fourier::Parametres no " << numero << " a le Fourier::TableauPixels no " << _tab_pixels->get_num() );
    }
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
TYPE_PIXELS * Fourier::Parametres::get_tab_pixels_ptr( )
{
    return _tab_pixels->get_ptr();
}


/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres::~Parametres() {
    fourier_info3( "destructeur de Fourier::Parametre no " << numero );
    if ( _tab_pixels )
    {
        _tab_pixels->decr_ref(1);
        if (_tab_pixels->get_ref() == 0)
            delete _tab_pixels;
    }
};

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::TableauPixels::compteur = 0;
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::TableauPixels( )
{
    numero = ++compteur;
    reference = 0;
    pointeur = 0;
    do_not_free = false;
    fourier_info3( "constructeur de Fourier::TableauPixels no " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::TableauPixels( unsigned int taille )
{
    numero = ++compteur;
    pointeur = (TYPE_PIXELS *)malloc( taille );
    reference = 0;
    do_not_free = false;
    fourier_info3( "constructeur de Fourier::TableauPixels no " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::TableauPixels( unsigned int taille, int valeur )
{
    numero = ++compteur;
    pointeur = (TYPE_PIXELS *)malloc( taille );
    memset( pointeur, valeur, taille );
    reference = 0;
    do_not_free = false;
    fourier_info3( "constructeur de Fourier::TableauPixels no " << numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::TableauPixels( TYPE_PIXELS * ptr )
{
    numero = ++compteur;
    pointeur = ptr;
    reference = 0;
    do_not_free = false;
    fourier_info3( "constructeur de Fourier::TableauPixels no " << numero );
}
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::~TableauPixels( )
{
    fourier_info3( "destructeur de Fourier::TableauPixels no " << numero << " ref " << reference);
    if ( ( do_not_free == false ) && ( pointeur != 0 ) )
    {
        fourier_info3( "libération mémoire Fourier::TableauPixels no " << numero );
        free( pointeur );
        pointeur = 0;
    }
    else
        fourier_info3( "Pas de libération mémoire Fourier::TableauPixels no " << numero << " ref=" << reference << " dnf=" << do_not_free );
}
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::TableauPixels::incr_ref( int increment )
{
    if ( pointeur )
        reference += increment;
}
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::TableauPixels::decr_ref( int increment )
{
    if ( pointeur )
        reference -= increment;
}
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::TableauPixels::set_free( bool f )
{
    do_not_free = f;
}

}

