/* jm_util.cpp
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

/* Projet      : AudeLA
 * Librairie   : LIBJM
 * Fichier     : JM_UTIL.C
 * Description : Fonctions utilitaires
 */
#include <sysexp.h>
#include <stdlib.h>

#include "libjm.h"
#include "divers.h"

namespace LibJM {
/* ***************** dms2deg *******************
 * dms2deg
 * Convertie un angle en degrés/minutes/secondes
 * en degrés décimaux
 * *********************************************/
int Divers::dms2deg(int d,int m,double s,double *angle)
{
    *angle=((s/60.0+(double)m)/60)+(double)d;
    return Generique::OK;
}

int Divers::DecodeListeDouble(Tcl_Interp *interp, char *list, double *tableau, int *n)
     /*****************************************************************************/
     /* retourne un pointeur (double*) sur les valeurs contenues par la liste Tcl.*/
     /* retourne n, le nombre d'elements.                                         */
     /*                                                                           */
     /*****************************************************************************/
{
#if defined(OS_WIN)
    const char **argv;
#else
    char **argv;
#endif
    int argc, code;
    int nn, k;

    argv = NULL;
    *n = 0;
    code = Tcl_SplitList(interp, list, &argc, &argv);
    if (argc <= 0)
    {
        return TCL_OK;
    }
    nn = argc;
    for (k = 0; k < nn; k++)
        tableau[k] = atof(argv[k]);

    Tcl_Free((char *) argv);
    *n = nn;
    return TCL_OK;
}

int Divers::DecodeListeInt(Tcl_Interp *interp, char *list, int *tableau, int *n)
     /*****************************************************************************/
     /* retourne un pointeur (int*) sur les valeurs contenues par la liste Tcl.   */
     /* retourne n, le nombre d'elements.                                         */
     /*                                                                           */
     /*****************************************************************************/
{
#if defined(OS_WIN)
    const char **argv;
#else
    char **argv;
#endif
    int argc,code;
    int nn,k;

    argv = NULL;
    *n = 0;
    code = Tcl_SplitList(interp,list,&argc,&argv);
    if (argc <= 0)
        return TCL_OK;
    nn = argc;
    for (k = 0; k < nn; k++)
        tableau[k]=atoi(argv[k]);
    Tcl_Free((char *) argv);
    *n = nn;
    return TCL_OK;
}


}





