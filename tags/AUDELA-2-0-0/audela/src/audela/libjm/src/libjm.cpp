/***
 * @file : libjm.cpp
 * @brief : point d'entrée dans la bibliothèque
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: libjm.cpp,v 1.9 2010-07-22 18:54:35 jacquesmichelet Exp $
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
#include <string.h>     /* strdup() */
#include <stdlib.h>     /* free() */
#include <math.h>
#include <gsl/gsl_vector.h>
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_fft.h"

#include "cbuffer.h"
#include "cpixelsgray.h"
#include "libjm.h"
#include "divers.h"
#include "calaphot.h"
#include "horloge.h"
#include "fourier.h"


/* *********** JM_Init **********
 * Point d'entree de la librairie
 * ******************************/
#ifdef LIBRARY_DLL
extern "C" int __cdecl Jm_Init( Tcl_Interp *interp )
#endif

#ifdef LIBRARY_SO
extern "C" int Jm_Init( Tcl_Interp *interp )
#endif
{
    if( Tcl_InitStubs( interp, "8.3", 0 ) == NULL )
    {
        char * s = strdup( "Tcl Stubs initialization failed in libjm." );
        Tcl_SetResult( interp, s, TCL_STATIC );
        free( s );
        return TCL_ERROR;
    }

    Tcl_CreateCommand( interp, "jm_versionlib", (Tcl_CmdProc *)LibJM::Generique::CmdVersionLib, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL );
    Tcl_CreateCommand( interp, "jm_repertoire_log", (Tcl_CmdProc *)LibJM::Generique::CmdRepertoireLog, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL );

    Tcl_CreateCommand( interp,"jm_inittamponimage", (Tcl_CmdProc *)LibJM::Divers::CmdInitTamponImage, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL );
    Tcl_CreateCommand( interp,"jm_infoimage", (Tcl_CmdProc *)LibJM::Divers::CmdInfoImage, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL );

    Tcl_CreateCommand( interp,"jm_heurepc",(Tcl_CmdProc *)LibJM::Horloge::CmdHeurePC,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
    Tcl_CreateCommand( interp,"jm_reglageheurepc",(Tcl_CmdProc *)LibJM::Horloge::CmdReglageHeurePC,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

    Tcl_CreateCommand( interp, "calaphot_fluxellipse",(Tcl_CmdProc *)LibJM::Calaphot::CmdFluxEllipse,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
    Tcl_CreateCommand( interp, "calaphot_fitgauss2d",(Tcl_CmdProc *)LibJM::Calaphot::CmdAjustementGaussien,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
    Tcl_CreateCommand( interp, "calaphot_niveau_traces", (Tcl_CmdProc *)LibJM::Calaphot::CmdNiveauTraces, NULL, NULL );

    Tcl_CreateCommand( interp, "dft2d", (Tcl_CmdProc *)LibJM::Fourier::CmdFourierDirect, NULL, NULL );
    Tcl_CreateCommand( interp, "idft2d", (Tcl_CmdProc *)LibJM::Fourier::CmdFourierInverse, NULL, NULL );
    Tcl_CreateCommand( interp, "acorr2d", (Tcl_CmdProc *)LibJM::Fourier::CmdAutoCorrelation, NULL, NULL );
    Tcl_CreateCommand( interp, "icorr2d", (Tcl_CmdProc *)LibJM::Fourier::CmdInterCorrelation, NULL, NULL );
    Tcl_CreateCommand( interp, "conv2d", (Tcl_CmdProc *)LibJM::Fourier::CmdConvolution, NULL, NULL );
    Tcl_CreateCommand( interp, "fourier_niveau_traces", (Tcl_CmdProc *)LibJM::Fourier::CmdNiveauTraces, NULL, NULL );

    return TCL_OK;
}

namespace LibJM
{
    const std::string Generique::NUMERO_VERSION("4.0");
    const char * Generique::repertoire_log = 0;

    int Generique::CmdVersionLib( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
    {
        char * s = strdup( NUMERO_VERSION.c_str() );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        free( s );
        return TCL_OK;
    }

    int Generique::CmdRepertoireLog( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
    {
        char s[256];

        if ( argc < 2 ) {
            sprintf( s, "Usage: %s log directory name", argv[0] );
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
        else {
            if ( repertoire_log == 0 )
            {
                repertoire_log =  strdup( argv[1] );
                return TCL_OK;
            }
            else {
                sprintf( s, "%s : log directory already set to %s", argv[0], repertoire_log );
                Tcl_SetResult( interp, s, TCL_VOLATILE );
                return TCL_ERROR;
            }
        }
    }
}



