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

#include "jm_c_tcl.h"

int tcl_InfoImage(Tcl_Interp *interp,int numbuf, descripteur_image *image)
     /****************************************************************************/
     /* Retourne les infos d'une image presente dans le buffer numero numbuf     */
     /* de AudeLA                                                                */
     /****************************************************************************/
     /* Fonction integralement pompee de l'exemple fourni par Alain Klotz        */
     /*  Merci Alain !                                                           */
     /****************************************************************************/
{
  char keyname[10],s[50],lignetcl[50],value_char[100];
  int ptr,datatype;

  strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");
  image->naxis1=0;
  image->naxis2=0;
  strcpy(image->dateobs,"");
  /* -- recherche l'adresse du pointeur de l'image --*/
  sprintf(s,"buf%d pointer",numbuf);
  Tcl_Eval(interp,s);
  Tcl_GetInt(interp,interp->result,&ptr);
  image->ptr_audela=(float*)ptr;
  if (image->ptr_audela==NULL) {
    return(TCL_OK);
  }
  /* -- recherche le mot cle NAXIS1 dans l'entete FITS --*/
  strcpy(keyname,"NAXIS1");
  sprintf(s,lignetcl,numbuf,keyname);
  Tcl_Eval(interp,s);
  strcpy(value_char,Tcl_GetStringResult(interp));
  if (strcmp(value_char,"")==0) {
    datatype=0;
  }
  else {
    datatype=1;
  }
  if (datatype==0) {
    image->naxis1=0;
  } else {
    image->naxis1=atoi(value_char);
  }
  /* -- recherche le mot cle NAXIS2 dans l'entete FITS --*/
  strcpy(keyname,"NAXIS2");
  sprintf(s,lignetcl,numbuf,keyname);
  Tcl_Eval(interp,s);
  strcpy(value_char,Tcl_GetStringResult(interp));
  if (strcmp(value_char,"")==0) {
    datatype=0;
  }
  else {
    datatype=1;
  }
  if (datatype==0) {
    image->naxis2=0;
  } else {
    image->naxis2=atoi(value_char);
  }
  /* -- recherche le mot cle DATE-OBS dans l'entete FITS --*/
  strcpy(keyname,"DATE-OBS");
  sprintf(s,lignetcl,numbuf,keyname);
  Tcl_Eval(interp,s);
  strcpy(value_char,Tcl_GetStringResult(interp));
  if (strcmp(value_char,"")==0) {
    datatype=0;
  }
  else {
    datatype=1;
  }
  if (datatype==0) {
    strcpy(image->dateobs,"");
  } else {
    strcpy(image->dateobs,value_char);
  }
  return(TCL_OK);
}


/*************** CmdDms2deg **************/
/* Conversion des degres/minutes/secondes*/
/* en degres decimaux                    */
/*****************************************/
int CmdDms2deg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
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
  if (dms2deg(atoi(argv[1]),atoi(argv[2]),atof(argv[3]),&angle)==PB)
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

/****************** CmdJd *****************/
/* Calcul du jour Julien                  */
/******************************************/
int CmdJd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
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
  if (jd(atoi(argv[1]),atoi(argv[2]),atof(argv[3]),&jj)==PB)
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
int CmdJd2(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
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
          atoi(argv[5]),atoi(argv[6]),atoi(argv[7]),&jj)==PB)
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
int CmdJc(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
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
  if (jc(&annee, &mois, &jour, atof(argv[1])) == PB)
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
int CmdJc2(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int annee, mois, jour, heure, minute, seconde, milli;

  if (argc != 2)
    {
      sprintf(s, "Usage: %s jour_julien", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  if (jc2(&annee, &mois, &jour, &heure, &minute, &seconde, &milli, atof(argv[1])) == PB)
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
int CmdHeurePC(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
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
      if (LitHeurePC(&annee, &mois, &jour, &heure, &minute, &seconde, &milli) == PB)
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

      if (erreur == PB)
        {
          strcpy(s,"Erreur dans la fonction EcritHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      if (erreur == PB2)
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
int CmdReglageHeurePC(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
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
  if (erreur == PB)
    {
      strcpy(s,"Erreur dans la fonction ReglageHeurePC");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  if (erreur == PB2)
    {
       strcpy(s,"Probl�me de droit d'acc�s pour la fonction ReglageHeurePC");
       Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
    }

  sprintf(s,"%ld", decalage);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;

}

/******************************************/
/* Calcul du flux dans une ellipse        */
/******************************************/
int CmdFluxEllipse(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[256];
    int retour, tampon;
    double nb_pixel, nb_pixel_fond;
    double flux_etoile, flux_fond, sigma_fond;
    descripteur_image image;

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
        retour = tcl_InfoImage(interp, tampon, &image);

        /* Positionne les variables statiques de l'image */
        /*  Cette facon de proceder n'est pas elegante, mais garantit la compatibilite avec les versions anterieures de la libjm */
        if (InitTamponImage((int)image.ptr_audela, image.naxis1, image.naxis2) == PB) {
            strcpy(s,"Erreur dans la fonction InitTamponImage");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
        }
        if (argc == 9)
        {
            if (FluxEllipse(atof(argv[2]), atof(argv[3]), atof(argv[4]), atof(argv[5]), atof(argv[6]), atof(argv[7]), atof(argv[8]), 1, &flux_etoile, &nb_pixel, &flux_fond, &nb_pixel_fond, &sigma_fond) == PB)
                {
                     strcpy(s,"Erreur dans la fonction FluxEllipse");
                    Tcl_SetResult(interp,s,TCL_VOLATILE);
                return TCL_ERROR;
            }
        }
        if (argc == 10)
        {
            if (FluxEllipse(atof(argv[2]), atof(argv[3]), atof(argv[4]), atof(argv[5]), atof(argv[6]), atof(argv[7]), atol(argv[8]), atol(argv[9]), &flux_etoile, &nb_pixel, &flux_fond, &nb_pixel_fond, &sigma_fond) == PB)
                {
                    strcpy(s,"Erreur dans la fonction FluxEllipse");
                    Tcl_SetResult(interp,s,TCL_VOLATILE);
                return TCL_ERROR;
                }
        }
        sprintf(s, "%19.8f %10.4f %19.8f %8.2f %8.2f", flux_etoile, nb_pixel, flux_fond, nb_pixel_fond, sigma_fond);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_OK;
    }
    else
    {
        sprintf(s, "Usage: %s x_ellipse y_ellipse gd_axe pt axe allongement couronne1 couronne2 [sur_echantillonage]", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
}

/************************************************************/
/* Initialisation des parametres d'un tampon d'image        */
/************************************************************/
int CmdInitTamponImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[256];
    if (argc == 4)
    {
        if (InitTamponImage(atol(argv[1]), atoi(argv[2]), atoi(argv[3])) == PB)
            {
                strcpy(s,"Erreur dans la fonction InitTamponImage");
                Tcl_SetResult(interp,s,TCL_VOLATILE);
                return TCL_ERROR;
            }
        strcpy(s,"0");
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_OK;
    }
    else
    {
        sprintf(s, "Usage: %s pointeur_image largeur_image (ou naxis 1) hauteur_image (ou naxis2)", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
}

int CmdInfoImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
     /****************************************************************************/
     /* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
     /****************************************************************************/
     /****************************************************************************/
{
  int result,retour;
  Tcl_DString dsptr;
  char s[100];
  descripteur_image image;
  int numbuf;

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
  return result;
}


/*****************************/
/* Lecture d'un pixel        */
/*****************************/
int CmdLecturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int pixel;

  if (argc == 3)
    {
      if (LecturePixel(atoi(argv[1]), atoi(argv[2]), &pixel) == PB)
        {
          strcpy(s,"Erreur dans la fonction LecturePixel");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      sprintf(s,"%ld", (unsigned long)pixel);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
    }
  else
    {
      sprintf(s, "Usage: %s abscisse ordonn�e", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
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

  if (argc == 5)
    {
      if (Magnitude(atof(argv[1]), atof(argv[2]), atof(argv[3]), &magnitude) == PB)

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
int CmdAjustementGaussien(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int carre[4], tampon;
  double param[10], chi2;
  int n_carre, iterations, n_param, convergence;
  struct ajustement valeurs, incertitudes;
  int retour;
  descripteur_image image;

  if((argc < 3) || (argc > 4)) {
    sprintf(s,"Usage: %s Numero_Buffer Coordonnees_Carre ?-sub?", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    return TCL_ERROR;
  } else {
    /* Validite du parametre de buffer */
    retour = Tcl_GetInt(interp, argv[1], &tampon);
    if (retour != TCL_OK)
      return retour;

    /* Validite de la liste des coordonnees */
    DecodeListeInt(interp, argv[2], &carre[0], &n_carre);
    if (n_carre != 4) {
      sprintf(s,"Usage: %s Mauvaises coordonnees", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

    if (argc == 4) {
      if (strncmp(argv[3], "-sub", 4) != 0) {
        sprintf(s,"Usage: %s Numero_Buffer Coordonnees_Carre ?-sub?", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
      }
    }


    /* Recuperation des infos sur l'image */
    retour = tcl_InfoImage(interp, tampon, &image);


    /* Positionne les variables statiques de l'image */
    /*  Cette facon de proceder n'est pas elegante, mais garantit la compatibilite avec les versions anterieures de la libjm */
    if (InitTamponImage((int)image.ptr_audela, image.naxis1, image.naxis2) == PB) {
      strcpy(s,"Erreur dans la fonction InitTamponImage");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

    /* Appel a bufn stat pour recuperer les valeurs caracteristiques du rectangle*/
    /* Formation de la chaine et appel */
    sprintf(s, "buf%d stat {%s}", tampon, argv[2]);
    Tcl_Eval(interp, s);
    /* Lecture des resultats */
    DecodeListeDouble(interp, interp->result, &param[0], &n_param);

    /* A partir des valeurs approximatives donnees par bufn stat, calcul d'un profil gaussien plausible */
    AjustementGaussien (&carre[0], &param[0], &valeurs, &incertitudes, &iterations, &chi2, &convergence);

        if (convergence == 0) {
                memset (&valeurs, 0, sizeof(valeurs));
                memset (&incertitudes, 0, sizeof(incertitudes));
        }

    /* Soustraction du modele a l'image originale */
    if ((argc == 4) && (convergence != 0)) {
      SoustractionGaussienne (&carre[0], &valeurs);
    }

    sprintf(s, "%d %d %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f",
            convergence,
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
    Tcl_SetResult(interp,s,TCL_VOLATILE);

    return TCL_OK;
  }

}


/***************************/
/* Version de la librairie */
/***************************/
int CmdVersionLib(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
        char s[256];

        strcpy(s, NUMERO_VERSION);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_OK;
}



/**************************************************/
/* Fonction utilitaires pour interfacer C <-> TCL */
/**************************************************/

int DecodeListeInt(Tcl_Interp *interp, char *list, int *tableau, int *n)
     /*****************************************************************************/
     /* retourne un pointeur (int*) sur les valeurs contenues par la liste Tcl.   */
     /* retourne n, le nombre d'elements.                                         */
     /*                                                                           */
     /*****************************************************************************/
{
  char **argv;
  int argc,code;
  int nn,k;

  argv = NULL;
  *n=0;
  code=Tcl_SplitList(interp,list,&argc,&argv);
  if (argc<=0) {
    return TCL_OK;
  }
   nn=argc;
   for (k=0;k<nn;k++) {
     tableau[k]=atoi(argv[k]);
   }
   Tcl_Free((char *) argv);
   *n=nn;
   return TCL_OK;
}

int DecodeListeDouble(Tcl_Interp *interp, char *list, double *tableau, int *n)
     /*****************************************************************************/
     /* retourne un pointeur (double*) sur les valeurs contenues par la liste Tcl.*/
     /* retourne n, le nombre d'elements.                                         */
     /*                                                                           */
     /*****************************************************************************/
{
  char **argv;
  int argc,code;
  int nn,k;

  argv = NULL;
  *n=0;
  code=Tcl_SplitList(interp,list,&argc,&argv);
  if (argc<=0) {
    return TCL_OK;
  }
   nn=argc;
   for (k=0;k<nn;k++) {
     tableau[k]=atof(argv[k]);
   }
   Tcl_Free((char *) argv);
   *n=nn;
   return TCL_OK;
}
