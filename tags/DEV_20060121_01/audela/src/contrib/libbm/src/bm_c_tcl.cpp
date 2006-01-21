// Projet      : AudeLA
// Librairie   : libbm
// Fichier     : bm_c_tcl.cpp 
// Description : Fonctions interfaces entre TCL et C
// =================================================

#include "bm_c_tcl.h"


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


     /****************************************************************************/
     /* Retourne les infos d'une image presente dans le buffer numero numbuf     */
     /* de AudeLA                                                                */
     /****************************************************************************/
     /* Fonction integralement pompee de l'exemple fourni par Alain Klotz        */
     /*  Merci Alain !                                                           */
     /****************************************************************************/
int tcl_InfoImage(Tcl_Interp *interp, int numbuf, descripteur_image *image)
{
  int result,retour;
  char keyname[10],s[50],lignetcl[50],value_char[100];
  int ptr,datatype;

  result=TCL_ERROR;

  strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");
  image->naxis1=0;
  image->naxis2=0;
  strcpy(image->dateobs,"");
  /* -- recherche l'adresse du pointeur de l'image --*/
  sprintf(s,"buf%d pointer",numbuf);
  Tcl_Eval(interp,s);
  retour = Tcl_GetInt(interp,interp->result,&ptr);
  if(retour!=TCL_OK) return retour;
  image->ptr_audela=(float*)ptr;
  if (image->ptr_audela==NULL) {
    return(TCL_ERROR);
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

int CmdBmLecturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
     /****************************************************************************/
     /* Retourne la valeur d'un pixel d'une image presente dans un buffer de AudeLA         */
     /****************************************************************************/
     /****************************************************************************/
{
  int result,retour;
  Tcl_DString dsptr;
  char s[100];
  descripteur_image image;
  int numbuf,x,y;
  double valeur;  

  if(argc<4) {
    sprintf(s,"Usage: %s numbuf x y", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&x);
    if(retour!=TCL_OK) return retour;
    /* --- decode le troisième parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[3],&y);
    if(retour!=TCL_OK) return retour;
    /*--- initialise la dynamic string ---*/
    Tcl_DStringInit(&dsptr);
    /* --- recherche les infos du tampon image---*/ 
    result=tcl_InfoImage(interp,numbuf,&image);
    if(retour!=TCL_OK) return retour;
    /* --- récupère la valeur du pixel---*/
    retour=LecturePixel(image, x, y, &valeur);
    if(retour!=0) return retour;
    /* --- On met en forme le resultat dans une chaine de caracteres ---*/
    sprintf(s,"%e",valeur);
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


int CmdBmEcriturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  /*********************************************/
  /* Ecrit la valeur d'un pixel d'une image    */
  /* presente dans un buffer de AudeLA         */
  /*********************************************/
  /*********************************************/
{
  int result,retour;
  char s[100];
  descripteur_image image;
  int numbuf,x,y;
  double valeur;

  result=TCL_ERROR;
  if(argc<5) {
    sprintf(s,"Usage: %s numbuf x y valeur", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
  } else {
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&x);
    if(retour!=TCL_OK) return retour;
    /* --- decode le troisième parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[3],&y);
    if(retour!=TCL_OK) return retour;
    /* --- decode le quatrième parametre obligatoire ---*/
    retour = Tcl_GetDouble(interp,argv[4],&valeur);
    if(retour!=TCL_OK) return retour;
    /* --- recherche les infos du tampon image---*/ 
    result=tcl_InfoImage(interp,numbuf,&image);
    if(retour!=TCL_OK) return retour;
    /* --- enregistre la valeur du pixel---*/
    retour=EcriturePixel(image, x, y, valeur);
    if(retour!=0) return retour;
    result = TCL_OK;
  }
  return result;
}

int CmdBmHard2Visu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Transforme une image par sa fonction de transfert
  //
  // *************************************************
{
  // Variables locales
  int result,retour;
  char s[100];
  descripteur_image image;
  int numbuf;
  double seuil_haut,seuil_bas;
  double *fonction_transfert;
  int k;
  char **argvv;          // Liste fonction de transfert.
  int argcc;             // Nombre d'elements dans la liste de fonction transfert.

  // Procédure principale
  if(argc<4) {
    sprintf(s,"Usage: %s numbuf seuil_haut seuil_bas fonction_transfert", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetDouble(interp,argv[2],&seuil_haut);
    if(retour!=TCL_OK) return retour;
    /* --- decode le troisième parametre obligatoire ---*/
    retour = Tcl_GetDouble(interp,argv[3],&seuil_bas);
    if(retour!=TCL_OK) return retour;
    /* --- decode le quatrième parametre obligatoire ---*/
    // attention, il s'agit d'une liste !
    if(Tcl_SplitList(interp,argv[4],&argcc,&argvv)!=TCL_OK) {
      // sprintf(ligne,"Position struct not valid: must be {x y}");
      retour = TCL_ERROR;
      return retour;
    } else if(argcc!=256) {
      // sprintf(ligne,"Position struct not valid: must be {x y}");
      retour = TCL_ERROR;
      return retour;
    } else {
      // Tcl_Eval(interp,argv[4]);
      // strcpy(liste,Tcl_GetStringResult(interp));
      // On attribue la mémoire nécessaire au tableau "fonction_transfert"
      if ( (fonction_transfert=(double*)calloc(257,sizeof(double)))==NULL) {
        retour = TCL_ERROR;
        // a verifier
        return retour;
        }
      // On remplit ce tableau
      for (k=0;k<256;k++) {
        fonction_transfert[k]=atof(argvv[k]);
        }
      }

    // On renvoie ça sous forme de liste.
    // DecodeListeDouble(interp,liste,fonction_transfert,llength);
    /* --- recherche les infos du tampon image---*/
    result=tcl_InfoImage(interp,numbuf,&image);
    if(retour!=TCL_OK) return retour;
    /* --- enregistre la valeur du pixel---*/
    retour=image_hard2visu(image, seuil_haut, seuil_bas, fonction_transfert);
    // On libère la mémoire nécessaire au tableau "fonction_transfert"
    free(fonction_transfert);
    if(retour!=0) return retour;
  }
  return result;
}

int CmdBmSoustrait(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Soustraction entre deux tampons images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  descripteur_image image1,image2;
  char s[100];

  // Procédure principale
  if(argc<2) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons images---*/
    result=tcl_InfoImage(interp,numbuf1,&image1);
    if(retour!=TCL_OK) return retour;
    result=tcl_InfoImage(interp,numbuf2,&image2);
    if(retour!=TCL_OK) return retour;
    /* --- soustraction (image1 = image1 - image2)---*/
    retour=soustrait(image1, image2);
    if(retour!=0) return retour;
  }
  return result;
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
  char **argv=NULL;
  int argc,code;
  int nn,k;
  
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
  char **argv=NULL;
  int argc,code;
  int nn,k;
  
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

int CmdBmMediane(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Calcule la médiane d'une série d'images
  //
  // *************************************************
{
  // Variables locales
  int result,retour;
  char s[100];
  char **argvv; // Liste des buffers.
  int argcc; // Nombre d'elements dans la liste précitée.
  int *liste_numbuf; // Liste des numéros de buffers de la série d'images.
  int numbuf_mediane;
  descripteur_image *liste_images; // Liste des paramètres de la série d'images.
  descripteur_image image_mediane,image_tmp;
  int k,x,y;
  double *liste_pixels;
  double valeur;

  // Procédure principale
  if(argc<3) {
    sprintf(s,"Usage: %s liste_buffers numbuf_mediane", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    // attention, il s'agit d'une liste !
    if(Tcl_SplitList(interp,argv[1],&argcc,&argvv)!=TCL_OK) {
      // sprintf(ligne,"Position struct not valid: must be {x y}");
      retour = TCL_ERROR;
      return retour;
    } else {
      // On attribue la mémoire nécessaire au tableau "liste_num_buf"
      if ( (liste_numbuf=(int*)calloc(argcc,sizeof(int)))==NULL) {
        retour = TCL_ERROR;
        // a verifier
        return retour;
        }
      // On remplit ce tableau
      for (k=0;k<argcc;k++) {
        liste_numbuf[k]=atoi(argvv[k]);
        }
      }

    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf_mediane);
    if(retour!=TCL_OK) return retour;


    // On attribue la mémoire nécessaire au tableau "liste_images"
    if ( (liste_images=(descripteur_image*)calloc(argcc,sizeof(descripteur_image)))==NULL) {
      retour = TCL_ERROR;
      // a verifier
      return retour;
      }
    // On remplit ce tableau
    for (k=0;k<argcc;k++) {
      result=tcl_InfoImage(interp,liste_numbuf[k],&image_tmp);
      if(retour!=TCL_OK) return retour;
      liste_images[k]=image_tmp;
      }

    /* --- recherche les infos du tampon image de destination --- */
    /* --- on initialise le tampon image de destination --- */
    sprintf(s,"buf%d format %d %d",numbuf_mediane,liste_images[0].naxis1,liste_images[0].naxis2);
    Tcl_Eval(interp,s);

    result=tcl_InfoImage(interp,numbuf_mediane,&image_mediane);
    if(retour!=TCL_OK) return retour;

    /* --- procédure principale---*/
    /* --- création d'une liste des valeurs de pixels --- */
    if ( (liste_pixels=(double*)calloc(argcc,sizeof(double)))==NULL) {
      retour = TCL_ERROR;
      // a verifier
      return retour;
      }

    for (x=1;x<=liste_images[0].naxis1;x++) {
      for (y=1;y<=liste_images[0].naxis2;y++) {        
        for (k=0;k<argcc;k++) {
          LecturePixel(liste_images[k],x,y,&valeur);
          liste_pixels[k]=valeur;
          }
        /* --- on calcule la médiane --*/
        gsl_sort(liste_pixels,1,argcc);
        valeur=gsl_stats_median_from_sorted_data(liste_pixels,1,argcc);
        EcriturePixel(image_mediane,x,y,valeur);
        }
      }

    // On libère la mémoire utilisée par le tableau "liste_pixels"
    free(liste_pixels);
    // On libère la mémoire utilisée par le tableau "liste_images"
    free(liste_images);
    // On libère la mémoire nécessaire au tableau "liste_numbuf"
    free(liste_numbuf);
    if(retour!=0) return retour;
  }
  return result;
}



