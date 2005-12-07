// Projet      : AudeLA 
// Librairie   : libbm
// Fichier     : bm_c_tcl.h
// Description : Prototype des fonctions interfaces Tcl et le C  
// ============================================================

#include "libbm.h"
#include <gsl/gsl_sort.h>
#include <gsl/gsl_statistics.h>

int CmdVersionLib(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmLecturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmEcriturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmHard2Visu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmSoustrait(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int DecodeListeDouble(Tcl_Interp *interp, char *list, double *tableau, int *n);
int CmdBmMediane(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

