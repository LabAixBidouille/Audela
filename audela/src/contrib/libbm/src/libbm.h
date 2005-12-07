// Projet      : AudeLA
// Librairie   : LIBBM
// Fichier     : libbm.h
// Description : Point d'entrée de la librairie
// ============================================

#define NUMERO_VERSION "1.02"


#ifndef __LIBBMH__
#define __LIBBMH__

#include "sysexp.h"

#ifdef LIBRARY_DLL
# include <windows.h>
#endif

#ifdef OS_WIN_BORL_DLL
# include "tcl.h"
# include "tk.h"
#endif

#ifdef OS_WIN_VCPP_DLL
# include "tcl.h"
# include "tk.h"
#endif

#include <tcl.h>

#include "bm_c_tcl.h"
#include "bm.h"

//#ifdef LIBRARY_DLL
//   __declspec(dllexport) int __cdecl Bm_Init(Tcl_Interp *interp);
//#endif

//#ifdef LIBRARY_SO
//   extern int Bm_Init(Tcl_Interp *interp);
//#endif

#endif


