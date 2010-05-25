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
 * Librairie   : LibJM
 * Fichier     : divers_tcl.cpp
 * Auteur      : Jacques Michelet
 * Description : Fonctions interfaces entre TCL et C
 * =================================================
*/

#include <string.h>
#include <stdlib.h>
#include "cerror.h"
#include "libjm.h"
#include "divers.h"


namespace LibJM {
/*************** CmdDms2deg **************/
/* Conversion des degres/minutes/secondes*/
/* en degres decimaux                    */
/*****************************************/
int Divers::CmdDms2deg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
  char s[256];
  double angle;

  /* Verifie que la commande a le bon nombre d'argument
   * --------------------------------------------------
   */
  if (argc!=4)
    {
      sprintf(s,"Usage: %s d m s", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Calcul de la convertion
   * -----------------------
   */
  if (dms2deg(atoi(argv[1]),atoi(argv[2]),atof(argv[3]),&angle) == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction dms2deg");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Sortie du résultat sur la console
   * ---------------------------------
   */
  sprintf(s,"%f",angle);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;
}

/************************************************************/
/* Initialisation des parametres d'un tampon d'image        */
/************************************************************/
int Divers::CmdInitTamponImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[256];
    sprintf (s, "Usage: %s has been obsoleted", argv[0]);
    Tcl_SetResult (interp, s, TCL_VOLATILE);
    return TCL_ERROR;
}

int Divers::CmdInfoImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
     /****************************************************************************/
     /* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
     /****************************************************************************/
     /****************************************************************************/
{
    int result = 0;
#if 0
    int result,retour;
  Tcl_DString dsptr;
  char s[100];
  descripteur_image image;
  int numbuf;

  CALAPHOT_DEBUG ("argc = %d\n", argc);

  if(argc<2) {
    sprintf(s,"Usage: %s numbuf", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /*--- initialise la dynamic string ---*/
    Tcl_DStringInit(&dsptr);
    /* --- recherche les infos ---*/
    result=tcl_InfoImage(interp,numbuf,&image);
    /* --- met en forme le resultat dans une chaine de caracteres ---*/
    sprintf(s,"%p %d %d %s",(void*)image.ptr_audela,image.naxis1,image.naxis2,image.dateobs);
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- a la fin, on envoie le contenu de la dynamic string dans */
    /* --- le Result qui sera retourne a l'utilisateur. */
    Tcl_DStringResult(interp,&dsptr);
    /* --- desaloue la dynamic string. */
    Tcl_DStringFree(&dsptr);
  }
#endif
  return result;
}


}
