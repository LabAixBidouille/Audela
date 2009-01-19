/* libjm.c
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

/* Librairie : LIBJM
 * Fichier : LIBJM.CPP
 * Description : Point d'entree de la librairie
 * ============================================*/

#define XTERN
#include "sysexp.h"
#include "libjm.h"

/* *********** JM_Init **********
 * Point d'entree de la librairie
 * ******************************/
#ifdef LIBRARY_DLL
   int __cdecl Jm_Init(Tcl_Interp *interp)
#endif

#ifdef LIBRARY_SO
   int Jm_Init(Tcl_Interp *interp)
#endif
{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libjm.",TCL_STATIC);
      return TCL_ERROR;
   }

  /* Si les deux DLLs ont bien été chargées, on enregistre
   * les fonctions de la bibliothèque qui seront alors disponibles
   * depuis l'interpreteur TCL, de la meme maniere que toutes les
   * autres fonctions TCL.
   * Ajoutez ici vos propres fonctions externes...
   */
	  /* Premières versions */
      Tcl_CreateCommand(interp,"jm_dms2deg",(Tcl_CmdProc *)CmdDms2deg,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_jd",(Tcl_CmdProc *)CmdJd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_jd2",(Tcl_CmdProc *)CmdJd2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_jc",(Tcl_CmdProc *)CmdJc,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_jc2",(Tcl_CmdProc *)CmdJc2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_heurepc",(Tcl_CmdProc *)CmdHeurePC,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_reglageheurepc",(Tcl_CmdProc *)CmdReglageHeurePC,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      
	  /* Version 2.0 */
      Tcl_CreateCommand(interp,"jm_versionlib",(Tcl_CmdProc *)CmdVersionLib,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

	  /* Version 2.1 */
      Tcl_CreateCommand(interp,"jm_fluxellipse",(Tcl_CmdProc *)CmdFluxEllipse,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_inittamponimage",(Tcl_CmdProc *)CmdInitTamponImage,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_lecturepixel",(Tcl_CmdProc *)CmdLecturePixel,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

	  /* Version 2.2 */
      Tcl_CreateCommand(interp,"jm_infoimage",(Tcl_CmdProc *)CmdInfoImage,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"jm_fitgauss2d",(Tcl_CmdProc *)CmdAjustementGaussien,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
  
  return TCL_OK;
}





