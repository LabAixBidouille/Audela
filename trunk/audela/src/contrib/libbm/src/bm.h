// Projet      : AudeLA 
// Librairie   : libbm
// Fichier     : bm.h
// Description : Déclaration des fonctions exportées
// =================================================

#include "sysexp.h"
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#ifdef LIBRARY_DLL
#include <io.h>
#include <windows.h>
#endif

#define OK  0
#define PB  1
#define PB2 2

/* Declaration des structures */
typedef struct {
   float *ptr;           /* adresse du pointeur de l'image en interne */
   float *ptr_audela;    /* adresse du pointeur de l'image dans AudeLA */
   int naxis1;           /* nombre de pixels sur l'axe x */
   int naxis2;           /* nombre de pixels sur l'axe y */
   char dateobs[30];     /* date du debut de pose au format Fits */
} descripteur_image;


// --- Déclaration des fonctions ---
int LecturePixel(descripteur_image image, int x, int y, double *pixel);
int EcriturePixel(descripteur_image image, int x, int y, double pixel);
int image_hard2visu(descripteur_image image, double seuil_haut, double seuil_bas, double *fonction_transfert);
int soustrait(descripteur_image image1, descripteur_image image2);

