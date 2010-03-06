/* jm_c_tcl.c
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
 * Fichier     : JM_C_TCL.CPP
 * Auteur      : Jacques Michelet
 * Description : Fonctions interfaces entre TCL et C
 * =================================================
*/
#include <string.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

#include "cerror.h"
#include "cbuffer.h"
#include "libjm.h"
#include "divers.h"
#include "calaphot.h"

namespace LibJM {
/******************************************/
/* Calcul du flux dans une ellipse        */
/******************************************/
int Calaphot::CmdFluxEllipse(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[256];
    int retour, tampon;
    double nb_pixel, nb_pixel_fond;
    double flux_etoile, flux_fond, sigma_fond;

    CALAPHOT_DEBUG ("argc = %d\n", argc);

    /* La facteur de rotation doit imperativement etre de module inferieur a 1 */
    if (fabs(atof(argv[6])) >= 1.0)
    {
        sprintf(s, "Le facteur de rotation doit avoir un module inferieur a 1.0");
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }


    if ((argc == 9) || (argc == 10))
    {
        /* Validite du parametre de buffer */
        retour = Tcl_GetInt(interp, argv[1], &tampon);
        if (retour != TCL_OK)
            return retour;

        /* Recuperation des infos sur l'image */
        if (Calaphot::instance()->set_buffer (tampon) == 0)
        {
            sprintf (s, "Pas de buffer nr %d", tampon);
            Tcl_SetResult (interp, s, TCL_VOLATILE);
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
        sprintf (s, "%19.8f %10.4f %19.8f %8.2f %8.2f", flux_etoile, nb_pixel, flux_fond, nb_pixel_fond, sigma_fond);
        Tcl_SetResult (interp, s, TCL_VOLATILE);
        return TCL_OK;
    }
    else
    {
        sprintf (s, "Usage: %s x_ellipse y_ellipse gd_axe pt axe allongement couronne1 couronne2 [sur_echantillonage]", argv[0]);
        Tcl_SetResult (interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }
}

/***************************/
/* Magnitude etoile        */
/***************************/
int CmdMagnitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  double magnitude;
  int tampon = 0;  // En fait ce code n'est pas opérationnel. A reprendre...

  CALAPHOT_DEBUG ("argc = %d\n", argc);

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
    char s[256];
    int carre[4], tampon;
    double fgauss[10], stat[10], chi2, erreur;
    int n_carre, iterations, n_fgauss, n_stat;
    Calaphot::ajustement valeurs, incertitudes;
    int retour;

    CALAPHOT_DEBUG ("argc = %d\n", argc);
    for (int arg = 0; arg < argc; arg++)
        CALAPHOT_DEBUG ("argv[%d] = %s\n", arg, argv[arg]);

    if((argc < 3) || (argc > 4))
    {
        sprintf (s, "Usage: %s Numero_Buffer Coordonnees_Carre ?-sub?", argv[0]);
        Tcl_SetResult (interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }
    else
    {
        /* Validite du parametre de buffer */
        retour = Tcl_GetInt (interp, argv[1], &tampon);
        if (retour != TCL_OK)
            return retour;

        /* Validite de la liste des coordonnees */
        Divers::DecodeListeInt (interp, argv[2], &carre[0], &n_carre);
        if (n_carre != 4)
        {
            sprintf (s,"Usage: %s Mauvaises coordonnees", argv[0]);
            Tcl_SetResult (interp, s, TCL_VOLATILE);
            return TCL_ERROR;
        }

        if (argc == 4)
        {
            if (strncmp(argv[3], "-sub", 4) != 0) {
                sprintf (s,"Usage: %s Numero_Buffer Coordonnees_Carre ?-sub?", argv[0]);
                Tcl_SetResult (interp, s, TCL_VOLATILE);
                return TCL_ERROR;
            }
        }

        /* Recuperation des infos sur l'image */
        if (Calaphot::instance()->set_buffer (tampon) == 0)
        {
            sprintf (s, "Pas de buffer nr %d", tampon);
            Tcl_SetResult (interp, s, TCL_VOLATILE);
            return TCL_ERROR;
        }

        try
        {
            /* Appel a bufn fitgauss pour recuperer les valeurs caracteristiques du rectangle*/
            /* Formation de la chaine et appel */
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
            CALAPHOT_ERROR ("%s\n",e.gets ());
            for (int arg = 0; arg < argc; arg++)
                CALAPHOT_ERROR ("\t argv[%d] = %s\n", arg, argv[arg]);
            Tcl_SetResult( interp, e.gets(), TCL_VOLATILE );
            return TCL_ERROR;
        }

        sprintf(s, "%10.4f %d %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f",
                erreur,
                iterations,
                valeurs.X0,
                valeurs.Y0,
                valeurs.Signal,
                valeurs.Fond,
                valeurs.Sigma_X * 1.66511,
                valeurs.Sigma_Y * 1.66511,
                valeurs.Ro,
                valeurs.Alpha,
                valeurs.Sigma_1 * 1.66511,
                valeurs.Sigma_2 * 1.66511,
                valeurs.Flux,
                incertitudes.X0,
                incertitudes.Y0,
                incertitudes.Signal,
                incertitudes.Fond,
                incertitudes.Sigma_X * 1.66511,
                incertitudes.Sigma_Y * 1.66511,
                incertitudes.Ro,
                incertitudes.Alpha,
                incertitudes.Sigma_1 * 1.66511,
                incertitudes.Sigma_2 * 1.66511,
                incertitudes.Flux);
        Tcl_SetResult (interp, s, TCL_VOLATILE);
        return TCL_OK;
    }
}


/***************************/
/* Version de la librairie */
/***************************/




}
