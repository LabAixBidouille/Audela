
#include <valarray>

#ifndef _INC_LIBESHEL_ORDER
#define _INC_LIBESHEL_ORDER

#define MAX_ORDRE 100
#define MAX_LINES 400 
#define POLY_ORDER_DEGREE 5

typedef struct
   {
   int flag;
   int min_x;
   int max_x;
   int yc;
   double poly_order[POLY_ORDER_DEGREE+1];   // 
   double rms_order;
   int wide_y;
   int wide_sky;
   int wide_x;             // largeur d'incertitude pour recherche raies n�on
   double slant;
   double a0;              //
   double a1;
   double a2;
   double a3;
   double rms_calib_spec;
   double fwhm;            // largeur � mi-hauteur moyenne en pixel
   double central_lambda;  // longueur centrale d'un ordre
   double disp;            // dispersion moyenne en A/pixel
   double resolution;      // 
   int nb_lines;           // nombre de raies utilis�es pour la calibration spectrale (v1.4) 
   //int position_lines[MAX_LINES];  
      //double dx;              // position th�orique de raie de calibration dans le profil spectral  
} ORDRE;

typedef struct {
   double alpha;  // angle d'incidence (en degr�s)
   double beta;   // angle de difraction (en degr�s)
   double gamma;  // angle d'�chappement (en degr�s)
   double m;      // nombre de traits par millim�tre de la gravure du r�seau
   double focale; // distance focale de la cam�ra (en millim�tres)
   double pixel;  // taille des pixels (en millim�tres)
   int imax;      // nombre de pixels suivant X (axe spatial)
   int jmax;      // nombre de pixels suivant Y (axe spatial)
   int min_order; // num�ro du premier ordre � d�tecter
   int max_order; // num�ro du dernier ordre � d�tecter
   ::std::valarray<double> distorsion;  // polynome de correction de la distorsion optique
   double version; //version du header de la table des ordres
} INFOSPECTRO;



typedef struct {
    int referenceOrderNum;    // reference order num
    int referenceOrderX;      // reference order x
    int referenceOrderY;      // reference order y
    double referenceOrderLambda; //reference order lambda 
    int detectionThreshold;   // dectection threshold
    int yStep;                // y step between orders
    int calibrationIteration; // nombre d'iteration du traitement de la calibration
    int bordure;              // Valeur du crop des bords de spectre apr�s la correction g�om�trique
    double version;           // version du header
} PROCESS_INFO;

typedef struct {
    double minLambda;    // min wave length
    double maxLambda;      //  max wave length
} CROP_LAMBDA;

void startTimer();
double stopTimer(char * lpFormat, ...);

#endif