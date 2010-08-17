
#include <valarray>

#ifndef _INC_ORDER
#define _INC_ORDER
#define MAX_ORDRE 100
#define MAX_LINES 400 

typedef struct
   {
   int flag;
   int min_x;
   int max_x;
   double yc;
   double poly_order[5];   // 
   double rms_order;
   int wide_y;
   int wide_sky;
   int wide_x;             // largeur d'incertitude pour recherche raies néon
   double slant;
   double a0;              //
   double a1;
   double a2;
   double a3;
   double rms_calib_spec;
   double fwhm;            // largeur à mi-hauteur moyenne en pixel
   double central_lambda;  // longueur centrale d'un ordre
   double disp;            // dispersion moyenne en A/pixel
   double resolution;      // 
   int nb_lines;           // nombre de raies utilisées pour la calibration spectrale (v1.4) 
   //int position_lines[MAX_LINES];  
   //double dx;              // position théorique de raie de calibration dans le profil spectral  
} ORDRE;

typedef struct {
   double alpha;  // angle d'incidence (en degrès)
   double beta;   // angle de difraction (en degrès)
   double gamma;  // angle d'échappement (en degrès)
   double m;      // nombre de traits par millimètre de la gravure du réseau
   double focale; // distance focale de la caméra (en millimètres)
   double pixel;  // taille des pixels (en millimètres)
   int imax;      // nombre de pixels suivant X (axe spectral)
   int jmax;      // nombre de pixels suivant Y (axe spatial)
   int min_order;
   int max_order;
   ::std::valarray<double> distorsion;  // polynome de correction de la distorsion optique
} INFOSPECTRO;



typedef struct {
    int referenceOrderNum;    // reference order num
    int referenceOrderX;      // reference order x
    int referenceOrderY;      // reference order y
    double referenceOrderLambda; //reference order lambda 
    int detectionThreshold;   // dectection threshold
    int yStep;                // y step between orders
    int calibrationIteration; // nombre d'iteration du traitement de la calibration
} PROCESS_INFO;

#endif