// wizard.h : prototype des fonctions du wizard
//
#ifndef _INC_LIBESHEL_WIZARD
#define _INC_LIBESHEL_WIZARD

#include "order.h"

void Eshel_findMargin(
   char *ledfileName,      // nom du fichier led (image pretraitee pour la calibration geometrique)
   char *outputFileName,   // nom du fichier flat traitee  en sortie
   int seuil_ordre,        // seuil de d�tection des ordres
   double snNoise,
   INFOSPECTRO &spectro,   // parametres du specto et de la cam�ra
   char *returnMesssage);  // nom de l'image de controle

#endif