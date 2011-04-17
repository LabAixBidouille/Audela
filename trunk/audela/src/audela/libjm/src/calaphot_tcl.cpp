/***
 * @file : calaphot_tcl.cpp
 * @brief : interface TCL pour les routines de photométrie et de modélisation
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: calaphot_tcl.cpp,v 1.7 2011-01-23 16:36:18 jacquesmichelet Exp $
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
#include <sstream>
#include <iomanip>

#include <string.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

#include "cerror.h"
#include "cbuffer.h"
#include "libjm.h"
#include "divers.h"
#include "calaphot.h"

using namespace std;

namespace LibJM {

int Calaphot::CmdNiveauTraces( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    if ( argc < 2 )
    {
        ostringstream oss;
        oss << "Usage: " << argv[0] << "  (0=very verbose, ..., 9=dumb)";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    Calaphot::instance()->niveau_traces( atoi( argv[1] ) );
    return TCL_OK;
}

/******************************************/
/* Calcul du flux dans une ellipse        */
/******************************************/
int Calaphot::CmdFluxEllipse(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    ostringstream oss;
    int retour, tampon;
    double nb_pixel, nb_pixel_fond;
    double flux_etoile, flux_fond, sigma_fond;

    calaphot_info1 ( "argc = " << argc );
    for ( int arg = 0; arg < argc; arg++ )
        calaphot_info1 ( "argv[" << arg << "] = " << argv[arg] );

    /* La facteur de rotation doit impérativement être de module inférieur à 1 */
    if (fabs(atof(argv[6])) >= 1.0)
    {
        oss << "Le facteur de rotation doit avoir un module inférieur a 1.0";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }


    if ((argc == 9) || (argc == 10))
    {
        /* Validite du parametre de buffer */
        retour = Tcl_GetInt(interp, argv[1], &tampon);
        if (retour != TCL_OK)
            return retour;

        /* Récuperation des infos sur l'image */
        if (Calaphot::instance()->set_buffer (tampon) == 0)
        {
            oss << "Pas de buffer nr " << tampon;
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        if (argc == 9)
        {
            try
            {
                Calaphot::instance()->FluxEllipse (atof (argv[2]), atof (argv[3]), atof (argv[4]), atof (argv[5]), atof (argv[6]), atof (argv[7]), atof (argv[8]), 1, &flux_etoile, &nb_pixel, &flux_fond, &nb_pixel_fond, &sigma_fond);
            }
            catch ( const CError& e )
            {
                Tcl_SetResult( interp, e.gets(), TCL_VOLATILE );
                return TCL_ERROR;
            }
        }
        if (argc == 10)
        {
            try
            {
                Calaphot::instance()->FluxEllipse(atof(argv[2]), atof(argv[3]), atof(argv[4]), atof(argv[5]), atof(argv[6]), atof(argv[7]), atol(argv[8]), atol(argv[9]), &flux_etoile, &nb_pixel, &flux_fond, &nb_pixel_fond, &sigma_fond);
            }
            catch ( const CError& e )
            {
                Tcl_SetResult( interp, e.gets(), TCL_VOLATILE );
                return TCL_ERROR;
            }
        }
        int p = oss.precision();
        oss << setprecision( 10 ) << flux_etoile;
        oss << " " << nb_pixel;
        oss << " " << flux_fond;
        oss << " " << nb_pixel_fond;
        oss << " " << " " << sigma_fond;
        oss.precision( p );
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );

        calaphot_info1 ( "retour = " << oss.str().c_str() );

        return TCL_OK;
    }
    else
    {
        oss << "Usage: " << argv[0] << " numero_buffer x_ellipse y_ellipse gd_axe pt axe allongement couronne1 couronne2 [sur_echantillonage]";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
}

/***************************/
/* Magnitude etoile        */
/***************************/
int Calaphot::CmdMagnitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  double magnitude;
  int tampon = 0;  // En fait ce code n'est pas opérationnel. A reprendre...

  calaphot_debug ("argc = " << argc);

  if (argc == 5)
    {
      if (Calaphot::instance()->set_buffer (tampon) == 0)
      {
          sprintf (s, "Pas de buffer nr %d", tampon);
          Tcl_SetResult (interp, s, TCL_VOLATILE);
          return TCL_ERROR;
      }

      if (Calaphot::instance()->Magnitude(atof(argv[1]), atof(argv[2]), atof(argv[3]), &magnitude) == Generique::PB)

        {
          strcpy(s,"Erreur dans la fonction Magnitude");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      sprintf(s,"%7.4f", magnitude);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
    }
  else
    {
      sprintf(s, "Usage: %s flux_etoile flux_etoile_reference magnitude_etoile_reference", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
}


/***************************************************************/
/* Ajustement d'un morceau d'image (etoile) par une gaussienne */
/***************************************************************/
int Calaphot::CmdAjustementGaussien (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    ostringstream oss;
    int carre[4], tampon;
    double fgauss[10], stat[10], chi2, erreur;
    int n_carre, iterations, n_fgauss, n_stat;
    Calaphot::ajustement valeurs, incertitudes;
    int retour;

    calaphot_info1 ( "argc = " << argc );
    for ( int arg = 0; arg < argc; arg++ )
        calaphot_info1 ( "argv[" << arg << "] = " << argv[arg] );

    if((argc < 3) || (argc > 4))
    {
        oss << "Usage: " << argv[0] << " Numero_Buffer Coordonnees_Carre ?-sub?";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    else
    {
        /* Validite du paramètre de buffer */
        retour = Tcl_GetInt (interp, argv[1], &tampon);
        if (retour != TCL_OK)
            return retour;

        /* Validite de la liste des coordonnees */
        Divers::DecodeListeInt (interp, argv[2], &carre[0], &n_carre);
        if (n_carre != 4)
        {
            oss << "Usage: " << argv[0] << " Mauvaises coordonnees";
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        if (argc == 4)
        {
            if (strncmp(argv[3], "-sub", 4) != 0) {
                oss << "Usage: " << argv[0] << " Numero_Buffer Coordonnees_Carre ?-sub?";
                Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
                return TCL_ERROR;
            }
        }

        /* Récupération des infos sur l'image */
        if (Calaphot::instance()->set_buffer (tampon) == 0)
        {
            oss << "Pas de buffer nr " << tampon;
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        try
        {
            /* Appel a bufn fitgauss pour recuperer les valeurs caracteristiques du rectangle*/
            /* Formation de la chaine et appel */
            char s[256];
            sprintf (s, "buf%d fitgauss {%s}", tampon, argv[2]);
            Tcl_Eval (interp, s);
            /* Lecture des resultats */
            Divers::DecodeListeDouble (interp, interp->result, &fgauss[0], &n_fgauss);

            /* Appel a bufn stat pour recuperer les valeurs caracteristiques du rectangle*/
            /* Formation de la chaine et appel */
            sprintf (s, "buf%d stat {%s}", tampon, argv[2]);
            Tcl_Eval (interp, s);
            /* Lecture des resultats */
            Divers::DecodeListeDouble (interp, interp->result, &stat[0], &n_stat);

            /* A partir des valeurs approximatives donnees par bufn stat, calcul d'un profil gaussien plausible */
            Calaphot::instance()->AjustementGaussien (&carre[0], &fgauss[0], &stat[0], &valeurs, &incertitudes, &iterations, &chi2, &erreur);

            if (iterations == 0)
            {
                memset (&valeurs, 0, sizeof(valeurs));
                memset (&incertitudes, 0, sizeof(incertitudes));
            }

            /* Soustraction du modele a l'image originale */
            if ((argc == 4) && (iterations != 0))
                Calaphot::instance()->SoustractionGaussienne (&carre[0], &valeurs);
        }
        catch (const CError& e)
        {
            calaphot_error (e.gets ());
            for (int arg = 0; arg < argc; arg++)
                calaphot_error ("\t argv[" << arg << "] = " << argv[arg]);
            Tcl_SetResult( interp, e.gets(), TCL_VOLATILE );
            return TCL_ERROR;
        }

        int p = oss.precision();
        oss << setprecision( 10 ) << erreur;
        oss << " " << iterations;
        oss << " " << valeurs.X0;
        oss << " " << valeurs.Y0;
        oss << " " << valeurs.Signal;
        oss << " " << valeurs.Fond;
        oss << " " << valeurs.Sigma_X * 1.66511;
        oss << " " << valeurs.Sigma_Y * 1.66511;
        oss << " " << valeurs.Ro;
        oss << " " << valeurs.Alpha;
        oss << " " << valeurs.Sigma_1 * 1.66511;
        oss << " " << valeurs.Sigma_2 * 1.66511;
        oss << " " << valeurs.Flux;
        oss << " " << incertitudes.X0;
        oss << " " << incertitudes.Y0;
        oss << " " << incertitudes.Signal;
        oss << " " << incertitudes.Fond;
        oss << " " << incertitudes.Sigma_X * 1.66511;
        oss << " " << incertitudes.Sigma_Y * 1.66511;
        oss << " " << incertitudes.Ro;
        oss << " " << incertitudes.Alpha;
        oss << " " << incertitudes.Sigma_1 * 1.66511;
        oss << " " << incertitudes.Sigma_2 * 1.66511;
        oss << " " << incertitudes.Flux;
        oss.precision( p );

        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );

        calaphot_info1 ( "retour = " << oss.str().c_str() );

        return TCL_OK;
    }
}


/***************************/
/* Version de la librairie */
/***************************/




}
