// Projet      : AudeLA 
// Librairie   : libbm
// Fichier     : bm_trt-img.cpp
// Auteur      : Benoît Maugis
// Description : Fonctions de traitement d'image
// ==================================================

#include "bm.h"
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_histogram.h>



// ***************** LecturePixel ************
// 
// Retourne la valeur d'un pixel
// *******************************************
int LecturePixel(descripteur_image image, int x, int y, double *pixel)
{
  float *pointeur;
  
  if ((x <= 0) || (x > image.naxis1) || (y <= 0) || (y > image.naxis2))
    {
      return PB;
  } else {
  x--;
  y--;
  pointeur = image.ptr_audela + (y * image.naxis1) + x;
  *pixel = (double)(*pointeur);
  return 0;
  }
}

// ***************** EcriturePixel ************
// 
// Ecrit la valeur d'un pixel
// ********************************************
int EcriturePixel(descripteur_image image, int x, int y, double pixel)
{
  float *pointeur;
  
  if ((x <= 0) || (x > image.naxis1) || (y <= 0) || (y > image.naxis2))
    {
      return PB;
    }
  x--;
  y--;
  pointeur = image.ptr_audela + (y * image.naxis1) + x;
  *pointeur = (float)pixel;
  return 0;
}

// ******************* pixel_hard2visu *******************
// pixel_hard2visu
// convertit la valeur pixel brute en valeur pixel 
// "affichage" d'après la fonction de transfert.
// *******************************************************

int pixel_hard2visu(double pixel_hard, double seuil_bas, double seuil_haut, double *fonction_transfert, double *pixel_visu)
{
  /* --- variables locales */
  int k;

  /* --- procédure principale */

  /* --- 1er cas : le pixel est complètement noir sur l'image */
  if (pixel_hard<=seuil_bas) {
    *pixel_visu=seuil_bas+((seuil_haut-seuil_bas) * fonction_transfert[0])/255;
    return OK;
  } else {
    /* --- 2nd cas : le pixel est complètement blanc sur l'image */
    /* --- sa valeur n'est pas non plus modifiée */
    if (pixel_hard>=seuil_haut) {
      *pixel_visu=seuil_bas+((seuil_haut-seuil_bas) * fonction_transfert[255])/255;
      return OK;
    } else {
      /* --- dernier cas : la valeur du pixel est modifiée par la */
      /* --- fonction de transfert. */
      k=(int)(255*((pixel_hard-seuil_bas)/(seuil_haut-seuil_bas)));
      *pixel_visu=seuil_bas+((seuil_haut-seuil_bas) * fonction_transfert[k])/255;
      return OK;
      }
    }
}

// ****************** image_hard2visu *********************
// image_hard2visu
// transforme une image brute en image "affichage"
// d'après la fonction de transfert.
// ********************************************************
int image_hard2visu(descripteur_image image, double seuil_haut, double seuil_bas, double *fonction_transfert)
{
  /* --- variables locales */
  int x,y;
  double pixel_hard,pixel_visu;

  /* --- procédure principale */
  for ( x=0 ; x<image.naxis1 ; x++) {
    for ( y=0 ; y<image.naxis2 ; y++) {

      LecturePixel (image, x, y, &pixel_hard);
      pixel_hard2visu (pixel_hard, seuil_bas, seuil_haut, fonction_transfert, &pixel_visu);
      EcriturePixel (image, x, y, pixel_visu);
      }
    }
  return OK;
}

// ****************** soustrait *********************
// soustrait
// Soustrait l'image 2 à l'image 1, le résultat écrase l'image 1.
// ********************************************************
int soustrait(descripteur_image image1, descripteur_image image2)
{
  /* --- variables locales */
  int x,y;
  double pixel_1,pixel_2,pixel_result;

  /* --- procédure principale */
  for ( x=0 ; x<image1.naxis1 ; x++) {
    for ( y=0 ; y<image1.naxis2 ; y++) {

      LecturePixel (image1, x, y, &pixel_1);
      LecturePixel (image2, x, y, &pixel_2);
      pixel_result=pixel_1-pixel_2;
      EcriturePixel (image1, x, y, pixel_result);
      }
    }
  return OK;
}

