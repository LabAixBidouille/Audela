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
#include <stdlib.h> 	/*atoi, atof*/
#include "cerror.h"
#include "libjm.h"
#include "horloge.h"

namespace LibJM {
/****************** CmdJd *****************/
/* Calcul du jour Julien                  */
/******************************************/
int Horloge::CmdJd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
  char s[256];
  double jj;

  /* Vérifie que la commande a le bon nombre d'argument
   * --------------------------------------------------
   */
  if (argc!=4)
    {
      sprintf(s,"Usage: %s annee mois jour", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Calcul de la conversion
   * -----------------------
   */
  if (jd(atoi(argv[1]),atoi(argv[2]),atof(argv[3]),&jj) == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction jd");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Sortie du résultat sur la console
   * ---------------------------------
   */
  sprintf(s,"%f",jj);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;
}

/***************** CmdJd2 *****************/
/* Calcul du jour Julien                  */
/******************************************/
int Horloge::CmdJd2(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
  char s[256];
  double jj;

  /* Vérifie que la commande a le bon nombre d'argument
   * --------------------------------------------------
   */
  if (argc!=8)
    {
      sprintf(s,"Usage: %s ann�e mois jour heure minute seconde milliseconde", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Calcul de la conversion
   * -----------------------
   */
  if (jd2(atoi(argv[1]),atoi(argv[2]),atoi(argv[3]),atoi(argv[4]),
          atoi(argv[5]),atoi(argv[6]),atoi(argv[7]),&jj) == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction jd2");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Sortie du resultat sur la console
   * ---------------------------------
   */
  sprintf(s,"%f",jj);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;
}

/******************************************/
/* Conversion en jour calendaire          */
/******************************************/
int Horloge::CmdJc(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int annee, mois;
  double jour;

  if (argc != 2)
    {
      sprintf(s, "Usage: %s jour_julien", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  if (jc(&annee, &mois, &jour, atof(argv[1])) == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction jc");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  sprintf(s,"%04d %02d %09.7f", annee, mois, jour);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;
}


/******************************************/
/* Conversion en jour calendaire          */
/******************************************/
int Horloge::CmdJc2(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int annee, mois, jour, heure, minute, seconde, milli;

  if (argc != 2)
    {
      sprintf(s, "Usage: %s jour_julien", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  if (jc2(&annee, &mois, &jour, &heure, &minute, &seconde, &milli, atof(argv[1])) == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction jc2");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  sprintf(s,"%04d %02d %02d %02d %02d %02d %03d", annee, mois, jour, heure, minute, seconde, milli);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;
}
/******************************************/
/* Gestion de l'heure PC                  */
/******************************************/
int Horloge::CmdHeurePC(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int annee, mois, jour, heure, minute, seconde, milli;
  int erreur;

  /* Vérifie que la commande a le bon nombre d'argument
   * --------------------------------------------------
   */
  if ((argc != 1) && (argc != 8))
    {
      sprintf(s, "Usage: %s ?yyyy MM dd hh mm ss lll?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Lecture de l'heure
   * ------------------
   */
   if (argc == 1)
    {
      if (LitHeurePC(&annee, &mois, &jour, &heure, &minute, &seconde, &milli) == Generique::PB)
        {
          strcpy(s,"Erreur dans la fonction LitHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      sprintf(s,"%04d %02d %02d %02d %02d %02d %03d", annee, mois, jour, heure, minute, seconde, milli);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
    }

  /* Lecture de l'heure */
  if (argc == 8)
    {
      erreur = EcritHeurePC(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), atoi(argv[7]));

      if (erreur == Generique::PB)
        {
          strcpy(s,"Erreur dans la fonction EcritHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      if (erreur == Generique::PB2)
        {
          strcpy(s,"Probl�me de droit d'acc�s pour la fonction EcritHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }

      sprintf(s,"%04d %02d %02d %02d %02d %02d %03d", atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), atoi(argv[7]));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
    }
  return TCL_OK;
}

/******************************************/
/* Reglage de l'heure PC                  */
/******************************************/
int Horloge::CmdReglageHeurePC(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  long decalage;
  int erreur;

  if (argc != 2)
    {
      sprintf(s, "Usage: %s decalage en ms", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
    erreur = ReglageHeurePC(&decalage, atol(argv[1]));
  if (erreur == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction ReglageHeurePC");

      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  if (erreur == Generique::PB2)
    {
       strcpy(s,"Probl�me de droit d'acc�s pour la fonction ReglageHeurePC");
       Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
    }

  sprintf(s,"%ld", decalage);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;

}


}
