/* libesheltcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol 
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

#include <tcl.h>
#include <stdlib.h>  // pour calloc
#include <exception>
#include <string>
#include <sstream>   // pour ostringstream
#include "order.h"
#include "libeshel.h"

// fonctions locales
void makeCheck(char *fileName,::std::list<double> &lineList);

void log(const char *fmt, ...)
{
   FILE *f;   
   va_list mkr;
   va_start(mkr, fmt);

   f = fopen("reduc.log","at+");
   vfprintf(f,fmt, mkr);
   fprintf(f,"\n");
   va_end(mkr);
   fclose(f);

}
int cmdEshelInit(ClientData clientData, Tcl_Interp *interp,int argc, char *argv[]) {
   char s[200];

   if(argc!=1) {
      sprintf(s,"Usage: %s double l m ", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      //writeAscii();
      return TCL_OK;
   }
   return TCL_OK;
}


// ---------------------------------------------------------------------------
// cmdEshelFlat
//    traite un flat
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelProcessFlat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_flat ledFileName tungstenFileName flatFileName Out alpha beta gamma focale m pixel width height wide_x wide_y seuil_ordre min_order max_order neon_ref_x ordre_ref_y ordre_ref lambda_ref {def_ordres} {line_list} {distorsion_polynom}";
   if(argc!=24) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * ledfileName ;
      char * tungstenFileName;
      char * flatFileName;
      INFOSPECTRO spectro;
      int wide_x, wide_y, seuil_ordre;
      int neon_ref_x, ordre_ref_y, ordre_ref;
      double lambda_ref;
      ORDRE * ordre;
      ::std::list<double> lineList;

      int ordreArgc;
      char **ordreArgv;
      int paramArgc;
      char **paramArgv;
      int distorsionArgc;
      char **distorsionArgv;

      int nb_ordre = 0;

      ledfileName = argv[1];
      tungstenFileName = argv[2];
      flatFileName = argv[3];

      int paramNo  = 3;
      // parametres du specrographe
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.alpha)!=TCL_OK) {
         sprintf(s,"%s\n Invalid alpha=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.beta)!=TCL_OK) {
         sprintf(s,"%s\n Invalid beta=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.gamma)!=TCL_OK) {
         sprintf(s,"%s\n Invalid gamma=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.focale)!=TCL_OK) {
         sprintf(s,"%s\n Invalid focale=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.m)!=TCL_OK) {
         sprintf(s,"%s\n Invalid m=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.pixel)!=TCL_OK) {
         sprintf(s,"%s\n Invalid pixel=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.imax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid width=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }         
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.jmax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid height=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // parametres de detection des raies
      if(Tcl_GetInt(interp,argv[++paramNo],&wide_x)!=TCL_OK) {
         sprintf(s,"%s\n Invalid wide_x=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&wide_y)!=TCL_OK) {
         sprintf(s,"%s\n Invalid wide_y=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&seuil_ordre)!=TCL_OK) {
         sprintf(s,"%s\n Invalid seuil_ordre=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.min_order)!=TCL_OK) {
         sprintf(s,"%s\n Invalid min_order=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.max_order)!=TCL_OK) {
         sprintf(s,"%s\n Invalid max_order=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // parametre de calibration ( raie de réference)
      if(Tcl_GetInt(interp,argv[++paramNo],&neon_ref_x)!=TCL_OK) {
         sprintf(s,"%s\n Invalid neon_ref_x=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&ordre_ref_y)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref_y=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&ordre_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&lambda_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid lambda_ref=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // liste des parametres des ordes (num, marge gauche, marge droit, slant)
      if(Tcl_SplitList(interp,argv[++paramNo],&ordreArgc,(const char***) &ordreArgv)!=TCL_OK) {
         sprintf(s,"%s\n ordre list=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         // On alloue la place pour 100 ordres
         if ((ordre=(ORDRE *)calloc(MAX_ORDRE,sizeof(ORDRE)))==NULL) {
            return NULL;
         }
         for (int i=0 ; i< ordreArgc && result!= TCL_ERROR; i++) {
            if(Tcl_SplitList(interp,ordreArgv[i],&paramArgc,(const char***) &paramArgv)!=TCL_OK) {
               sprintf(s,"%s\n Invalid ordre line %d value=%s", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;            
            } else if (paramArgc != 4 ){
               sprintf(s,"%s\n Invalid ordre line %d value=%s .\nMust contain {num_order min_x max_x slant}", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;            
            } else {
               int n;
               if(Tcl_GetInt(interp,paramArgv[0],&n)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d num_order=%s is not an integer", usage, i, paramArgv[0]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }

               if(Tcl_GetInt(interp,paramArgv[1],&ordre[n].min_x)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d min_x is not an integer", usage, i, paramArgv[1]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
               if(Tcl_GetInt(interp,paramArgv[2],&ordre[n].max_x)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d max_x=%s is not an integer", usage, i, paramArgv[2]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
               if(Tcl_GetDouble(interp,paramArgv[3],&ordre[n].slant)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d slant=%s is not a float", usage, i, paramArgv[3]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
               Tcl_Free((char*)paramArgv);
            }
            if ( result == TCL_ERROR) {
               return TCL_ERROR;
            }
         } 
         Tcl_Free((char*)ordreArgv);
      }

      // liste des raies de calibration
      if(Tcl_SplitList(interp,argv[++paramNo],&ordreArgc,(const char***) &ordreArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid line list=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         double lambda;
         for (int i=0 ; i< ordreArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,ordreArgv[i],&lambda)!=TCL_OK) {
               sprintf(s,"%s\n Invalid line %d lambda=%s is not an integer", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               lineList.push_back(lambda);
            }             
         }
         Tcl_Free((char*)ordreArgv);
      }

      // Polynome de correction de la distorsion optique  
      //spectro.distorsion.resize(4);
      //spectro.distorsion[0]=  26.4525309312253 ;
      //spectro.distorsion[1]=  0.951178287573155 ;
      //spectro.distorsion[2]=  0.0000346251616269773 ;
      //spectro.distorsion[3]=  -1.11329993513915e-08;
      if(Tcl_SplitList(interp,argv[++paramNo],&distorsionArgc,(const char***) &distorsionArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid distorsion polynom=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         spectro.distorsion.resize(distorsionArgc);
         double coefficient;
         for (int i=0 ; i< distorsionArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,distorsionArgv[i],&coefficient)!=TCL_OK) {
               sprintf(s,"%s\n Invalid coefficient[%d]=%s is not a double ", usage, i, distorsionArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               spectro.distorsion[i]=coefficient;
            }             
         }
         Tcl_Free((char*)distorsionArgv);
      }
      
      // la largeur de la zone de binning et de calcul du ciel est la même pour tous les ordres (simplification)
      for (int i=0;i<MAX_ORDRE;i++) {
         ordre[i].wide_y=wide_y;
         ordre[i].wide_x=wide_x;      // largeur de la boite de recherche des raies du néon en pixels (en dur - param sensible)
      }

      try {
         double dx_ref;
         char returnMessage[1024];
         Eshel_processFlat(ledfileName, tungstenFileName, flatFileName,
            ordre_ref_y, ordre_ref, lambda_ref, neon_ref_x, 
            wide_y, seuil_ordre, ordre, 
            spectro,
            lineList,
            &nb_ordre, &dx_ref,
            "reduc.log",
            returnMessage);
         // je copie le nombre d'ordres trouves dans la reponse
         sprintf(s,"%d  %s", nb_ordre, returnMessage);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }
      
      return result;
   }
}

// ---------------------------------------------------------------------------
// cmdEshelCalib
//    traite un lampe de calibration
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelProcessCalib(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_flat calibIn calibOut flatIn lamp_ref_x ordre_ref_y ordre_ref lambda_ref iteration {line_list}";
   if(argc!=9) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * lampNameIn ;
      char * lampNameOut;
      char * flatName;
      int neon_ref_x, ordre_ref;
      double lambda_ref;
      ::std::list<double> lineList;
      int ordreArgc;
      char **ordreArgv;
      int nb_ordre = 0;
      int iteration;

      lampNameIn = argv[1];
      lampNameOut = argv[2];
      flatName = argv[3];

      // parametre de calibration ( raie de réference)
      if(Tcl_GetInt(interp,argv[4],&neon_ref_x)!=TCL_OK) {
         sprintf(s,"%s\n Invalid neon_ref_x=%s", usage, argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[5],&ordre_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref=%s", usage, argv[5]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[6],&lambda_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid lambda_ref=%s", usage, argv[6]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[7],&iteration)!=TCL_OK) {
         sprintf(s,"%s\n Invalid neon_ref_x=%s", usage, argv[7]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }


      if(Tcl_SplitList(interp,argv[8],&ordreArgc,(const char***) &ordreArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid line list=%s", usage, argv[8]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         double lambda;
         for (int i=0 ; i< ordreArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,ordreArgv[i],&lambda)!=TCL_OK) {
               sprintf(s,"%s\n Invalid line %d lambda=%s is not an integer", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               lineList.push_back(lambda);
            }             
         }
         Tcl_Free((char*)ordreArgv);
      }

      
      try {
         Eshel_processCalib(lampNameIn, lampNameOut, flatName,
            ordre_ref, lambda_ref, neon_ref_x, iteration,
            "reduc.log",(short*)NULL, lineList);
         // je fabrique l'image check
         // makeCheck(lampNameOut, lineList);
         // je calibre flat
         //  Eshel_interpolProfile(flatName);
         Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }

      // je prepare la reponse
      return result;
   }
}

// ---------------------------------------------------------------------------
// cmdEshelProcessObject
//    traite l'image d'un objet :
//    
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelProcessObject(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_processObject fileIn fileOut calibFileName minOrder maxOrder {-merge 0|1} {-response responseFileName} {-exportfull0 fullFileName} {-exportfull fullFileName} {-objectimage 0|1}";
   if(argc<5) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * objectFileNameIn = NULL;
      char * objectFileNameOut = NULL;
      char * calibFileName = NULL;
      char * responseFileName = NULL;
      int minOrder = 0;
      int maxOrder = 0;
      char * fullFileName0 = NULL;
      char * fullFileName = NULL;
      int  useFlat = 1;
      int  recordObjectImage = 1; 
      ::std::valarray<CROP_LAMBDA> cropLambda(0);

      objectFileNameIn = argv[1];
      objectFileNameOut = argv[2];
      calibFileName = argv[3];

      if(Tcl_GetInt(interp,argv[4],&minOrder)!=TCL_OK) {
         sprintf(s,"%s\n Invalid minOrder=%s", usage, argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[5],&maxOrder)!=TCL_OK) {
         sprintf(s,"%s\n Invalid maxOrder=%s", usage, argv[5]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // je decode les parametres optionels
      for (int kk = 6; kk < argc ; kk++) {
         if (strcmp(argv[kk], "-merge") == 0 && kk+1 < argc ) {
            if(Tcl_GetInt(interp,argv[kk + 1],&useFlat)!=TCL_OK) {
               sprintf(s,"%s\n Invalid -merge=%s", usage, argv[kk]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
         if (strcmp(argv[kk], "-exportfull") == 0 && kk+1 < argc ) {
            fullFileName = argv[kk + 1];
         }
         if (strcmp(argv[kk], "-exportfull0") == 0 && kk+1 < argc ) {
            fullFileName0 = argv[kk + 1];
         }
         if (strcmp(argv[kk], "-response") == 0 && kk+1 < argc ) {
            responseFileName = argv[kk + 1];
         }
         if (strcmp(argv[kk], "-objectimage") == 0 && kk+1 < argc ) {
            if(Tcl_GetInt(interp,argv[kk + 1],&recordObjectImage)!=TCL_OK) {
               sprintf(s,"%s\n Invalid -objectimage=%s", usage, argv[kk]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
         if (strcmp(argv[kk], "-croplambda") == 0 && kk+1 < argc ) {
 
            int cropArgc;
            char **cropArgv;

            // liste des parametres des ordes (num, marge gauche, marge droit, slant)
            if(Tcl_SplitList(interp,argv[kk+1],&cropArgc,(const char***) &cropArgv)!=TCL_OK) {
               sprintf(s,"%s\n croplmabda list=%s", usage, argv[kk+1]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               result = TCL_OK;
               
               if ( cropArgc > 0 ) {
                  // j'alloue la place pour tous les ordres
                  cropLambda.resize(MAX_ORDRE);
                  // je copie les bornes de detrourage dans la table 
                  for (int i=0 ; i< cropArgc && result!= TCL_ERROR; i++) {
                     int paramArgc;
                     char **paramArgv;
                     if(Tcl_SplitList(interp,cropArgv[i],&paramArgc,(const char***) &paramArgv)!=TCL_OK) {
                        sprintf(s,"%s\n Invalid crop lambda %d value=%s", usage, i, cropArgv[i]);
                        Tcl_SetResult(interp,s,TCL_VOLATILE);
                        result = TCL_ERROR;            
                     } else if (paramArgc != 3 ){
                        sprintf(s,"%s\n Invalid crop lambda %d value=%s .\nMust contain {orderNum minLmanda maxLmabda}", usage, i, cropArgv[i]);
                        Tcl_SetResult(interp,s,TCL_VOLATILE);
                        result = TCL_ERROR;            
                     } else {
                        int n;
                        if(Tcl_GetInt(interp,paramArgv[0],&n)!=TCL_OK) {
                           sprintf(s,"%s\n Invalid crop lambda %d num_order=%s is not an integer", usage, i, paramArgv[0]);
                           Tcl_SetResult(interp,s,TCL_VOLATILE);
                           result = TCL_ERROR;
                        }
                        if(Tcl_GetDouble(interp,paramArgv[1],&cropLambda[n].minLambda)!=TCL_OK) {
                           sprintf(s,"%s\n Invalid crop lambda %d min lambda=%s is not a float", usage, i, paramArgv[1]);
                           Tcl_SetResult(interp,s,TCL_VOLATILE);
                           result = TCL_ERROR;
                        }
                        if(Tcl_GetDouble(interp,paramArgv[2],&cropLambda[n].maxLambda)!=TCL_OK) {
                           sprintf(s,"%s\n Invalid crop lambda %d max lambda=%s is not a float", usage, i, paramArgv[2]);
                           Tcl_SetResult(interp,s,TCL_VOLATILE);
                           result = TCL_ERROR;
                        }
                        Tcl_Free((char*)paramArgv);
                     }
                  }
               } 
               Tcl_Free((char*)cropArgv);
               if ( result == TCL_ERROR) {
                  return TCL_ERROR;
               }
            }
         }
      }
    
      try {
         Eshel_processObject(objectFileNameIn, objectFileNameOut, calibFileName, responseFileName,
            minOrder, maxOrder, recordObjectImage,
            cropLambda,
            "reduc.log",(short*)NULL);

         //Eshel_joinSpectra(objectFileNameOut, calibFileName,
         //       fullFileName0, fullFileName,
         //       minOrder, maxOrder,
         //       useFlat, (short *) NULL)  ;
         Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);         
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }

      return result;
   }
}


////////////////////////////////////////////////////////////////////////
// fonctions pour fabriquer l'image check
////////////////////////////////////////////////////////////////////////


#define swab _swab  // swab is deprecaded => replaced by _swab
#define PI 3.141592653589793
//****************************************** COMPUTE_POS ****************************************
// Calcule la position d'une raie de longueur d'onde lam pour l'ordre k dans le profil spectral. 
// Tiens compte du décalage dx trouvée avec la raie du Ne à 5852 A.                              
//***********************************************************************************************
double compute_pos(double k,double lambda,double dx,int imax,
                   double alpha,double gamma,double m,double focale,double pixel)
{
   gamma=gamma*PI/180.0;
   alpha=alpha*PI/180;
   double beta,beta2,posx;
   int xc=imax/2;

   beta=asin((k*m*lambda/1.0e7-cos(gamma)*sin(alpha))/cos(gamma));
   beta2=beta-alpha;
   posx=focale*beta2/pixel+(double)xc+dx;

   if ( lambda == 6242.941 ) {
      log("lambda=%f gamma=%f alpha=%f focale=%f pixel=%f m=%f\n",lambda,gamma,alpha,focale,pixel,m);
      log("lambda=%f beta=%f beta2=%f xc=%d dx=%f posx=%f\n",lambda,beta,beta2,xc,dx,posx);
   }
   return posx;
}

//************* LIGNEFITS_NUM ***************
// Ecriture d'une ligne dans le header FITS 
// (argument numérique)                     
//******************************************
void lignefits_num(char *mot,char *argu,FILE *fich_dest)
{
char buf[85];
char espaces[81];
int i;

for (i=0;i<80;*(espaces + i++)=' ');
*(espaces+80)='\0';
strcpy(buf,espaces);
strcpy(buf,mot);

*(buf+strlen(mot))=32;
*(buf+8)='=';
strcpy(buf+30-strlen(argu),argu);
*(buf+30)=32;
fwrite(buf,1,80,fich_dest);
}

//************ LIGNEFITS_LIBRE *****************
// Ecriture d'une ligne dans le header FITS     
// (ligne libre)                                
//**********************************************
void lignefits_libre(char *mot, FILE *fich_dest)
{
char buf[85];
char espaces[81];
int i;

for(i=0;i<80;*(espaces + i++)=' ');
*(espaces+80)='\0';
strcpy(buf,espaces);
strcpy(buf,mot);

*(buf+strlen(mot))=32;
fwrite(buf,1,80,fich_dest);
}




//****************** SAVE_FITS ********************
// Ecriture d'un fichier FITS                      
//*************************************************
int save_fits(char *nom, short * pic, int imax, int jmax,char *imageType)
{
char name[256],buf[128];
int bitpix,naxis;
int nb_lignes,nb_octets;
int i,longueur;
FILE *fich_dest;

sprintf(name,"%s.fit",nom);

if ((fich_dest=fopen(name,"wb"))==NULL)
   {
   printf("Sauvegarde du fichier %s impossible.",name);
   return 1;
   }

// ----------------------------------
// Sauvegarde de l'entête
// ----------------------------------
bitpix=16;
naxis=2;
lignefits_num("SIMPLE","T",fich_dest);
sprintf(buf,"%d",bitpix);
lignefits_num("BITPIX",buf,fich_dest);
sprintf(buf,"%d",naxis);
lignefits_num("NAXIS",buf,fich_dest);
sprintf(buf,"%d",imax);
lignefits_num("NAXIS1",buf,fich_dest);
sprintf(buf,"%d",jmax);
lignefits_num("NAXIS2",buf,fich_dest);
sprintf(buf,"0");
lignefits_num("MIPS-LO",buf,fich_dest);
sprintf(buf,"32100");
lignefits_num("MIPS-HI",buf,fich_dest);
nb_lignes = 7;
if ( imageType != NULL ) {
   sprintf(buf,"IMAGETYP= %s",imageType);
   lignefits_libre(buf,fich_dest);
   nb_lignes++;
} 
lignefits_libre("END",fich_dest);
nb_lignes++;

nb_lignes=nb_lignes % 36;
if (nb_lignes!=0) for (i=0;i<(36-nb_lignes);i++) lignefits_libre(" ",fich_dest);
 
// -----------------------------
// Sauvegarde de l'image
// -----------------------------
longueur=imax*jmax;
swab((char *)pic,(char *)pic,2*longueur);
if ((int)fwrite(pic,2,longueur,fich_dest)!=longueur)
   {
   printf("Sauvegarde du fichier %s impossible.",name);
   fclose(fich_dest);
   return 1;
   }
swab((char *)pic,(char *)pic,2*longueur);
nb_octets=2*longueur;
nb_octets=nb_octets % 2880;
if (nb_octets!=0L) for (i=0;i<(2880L-nb_octets);i++) fwrite(" ",1,1,fich_dest);

fclose(fich_dest);

return 0;
}

//********************* RETURN_CHAR *******************
// En entrée, un caractère 'c'                         
// En sortie une chaîne qui contient le bitmap du      
// caractère dans une matrice 8x9                      
//*****************************************************
void return_char(char c,char *s)
{
int v;

v=(int)c;

if (v==95) v=0;     // caractère '_'
if (v==-23) v=130;  // caractère 'é'

switch(v) 
   {
   case 0:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 1:
      strcpy(s,"0111111011000011100000011010010110000001101111011001100111000011011111100000000000000000");
      break;
   case 2:
      strcpy(s,"0111111011111111111111111101101111111111110000111110011111111111011111100000000000000000");
      break;
   case 3:
      strcpy(s,"0000000001000100111011101111111011111110111111100111110000111000000100000000000000000000");
      break;
   case 4:
      strcpy(s,"0001000000111000011111001111111011111110011111000011100000010000000000000000000000000000");
      break;
   case 5:
      strcpy(s,"0001100000111100001111001111111111100111111001110001100000011000011111100000000000000000");
      break;
   case 6:
      strcpy(s,"0001100000111100011111101111111111111111011111100001100000011000011111100000000000000000");
      break;
   case 7:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 8:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 9:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 10:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 11:
      strcpy(s,"0011111000001110001110100111001011111000110011001100110011001100011110000000000000000000");
      break;
   case 12:
      strcpy(s,"0011110001100110011001100110011000111100000110000111111000011000000110000000000000000000");
      break;
   case 13:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 14:
      strcpy(s,"0111111101100011011111110110001101100011011000110110011111100111111001101100000000000000");
      break;
   case 15:
      strcpy(s,"0000000000011000110110110111111011100111111001110111111011011011000110000000000000000000");
      break;
   case 16:
      strcpy(s,"1000000011000000111000001111100011111110111110001110000011000000100000000000000000000000");
      break;
   case 17:
      strcpy(s,"0000001000000110000011100011111011111110001111100000111000000110000000100000000000000000");
      break;
   case 18:
      strcpy(s,"0001100000111100011111100001100000011000000110000111111000111100000110000000000000000000");
      break;
   case 19:
      strcpy(s,"0110011001100110011001100110011001100110000000000000000001100110011001100000000000000000");
      break;
   case 20:
      strcpy(s,"0111111111011011110110111101101101111011000110110001101100011011000110110000000000000000");
      break;
   case 21:
      strcpy(s,"0111111001100011001100000011110001100110011001100011110000001100110001100111111000000000");
      break;
   case 22:
      strcpy(s,"0000000000000000000000000000000000000000000000001111111011111110111111100000000000000000");
      break;
   case 23:
      strcpy(s,"0001100000111100011111100001100000011000000110000111111000111100000110000111111000000000");
      break;
   case 24:
      strcpy(s,"0001100000111100011111100001100000011000000110000001100000011000000110000000000000000000");
      break;
   case 25:
      strcpy(s,"0001100000011000000110000001100000011000000110000111111000111100000110000000000000000000");
      break;
   case 26:
      strcpy(s,"0000000000000000000110000000110011111110000011000001100000000000000000000000000000000000");
      break;
   case 27:
      strcpy(s,"0000000000000000001100000110000011111110011000000011000000000000000000000000000000000000");
      break;
   case 28:
      strcpy(s,"0000000000000000000000001100000011000000110000001111111000000000000000000000000000000000");
      break;
   case 29:
      strcpy(s,"0000000000000000001001000110011011111111011001100010010000000000000000000000000000000000");
      break;
   case 30:
      strcpy(s,"0000000000010000000100000011100000111000011111000111110011111110111111100000000000000000");
      break;
   case 31:
      strcpy(s,"0000000011111110111111100111110001111100001110000011100000010000000100000000000000000000");
      break;
   case 32:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 33:
      strcpy(s,"0011000001111000011110000111100000110000001100000000000000110000001100000000000000000000");
      break;
   case 34:
      strcpy(s,"0110011001100110011001100010010000000000000000000000000000000000000000000000000000000000");
      break;
   case 35:
      strcpy(s,"0110110001101100111111100110110001101100011011001111111001101100011011000000000000000000");
      break;
   case 36:
      strcpy(s,"0011000001111100110000001100000001111000000011000000110011111000001100000011000000000000");
      break;
   case 37:
      strcpy(s,"0000000000000000110001001100110000011000001100000110000011001100100011000000000000000000");
      break;
   case 38:
      strcpy(s,"0111000011011000110110000111000011111010110111101100110011011100011101100000000000000000");
      break;
   case 39:
      strcpy(s,"0011000000110000001100000110000000000000000000000000000000000000000000000000000000000000");
      break;
   case 40:
      strcpy(s,"0000110000011000001100000110000001100000011000000011000000011000000011000000000000000000");
      break;
   case 41:
      strcpy(s,"0110000000110000000110000000110000001100000011000001100000110000011000000000000000000000");
      break;
   case 42:
      strcpy(s,"0000000000000000011001100011110011111111001111000110011000000000000000000000000000000000");
      break;
   case 43:
      strcpy(s,"0000000000000000000110000001100001111110000110000001100000000000000000000000000000000000");
      break;
   case 44:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000111000001110000110000000000000");
      break;
   case 45:
      strcpy(s,"0000000000000000000000000000000011111110000000000000000000000000000000000000000000000000");
      break;
   case 46:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000111000001110000000000000000000");
      break;
   case 47:
      strcpy(s,"0000000000000010000001100000110000011000001100000110000011000000100000000000000000000000");
      break;
   case 48:
      strcpy(s,"0111110011000110110011101101111011010110111101101110011011000110011111000000000000000000");
      break;
   case 49:
      strcpy(s,"0001000000110000111100000011000000110000001100000011000000110000111111000000000000000000");
      break;
   case 50:
      strcpy(s,"0111100011001100110011000000110000011000001100000110000011001100111111000000000000000000");
      break;
   case 51:
      strcpy(s,"0111100011001100000011000000110000111000000011000000110011001100011110000000000000000000");
      break;
   case 52:
      strcpy(s,"0000110000011100001111000110110011001100111111100000110000001100000111100000000000000000");
      break;
   case 53:
      strcpy(s,"1111110011000000110000001100000011111000000011000000110011001100011110000000000000000000");
      break;
   case 54:
      strcpy(s,"0011100001100000110000001100000011111000110011001100110011001100011110000000000000000000");
      break;
   case 55:
      strcpy(s,"1111111011000110110001100000011000001100000110000011000000110000001100000000000000000000");
      break;
   case 56:
      strcpy(s,"0111100011001100110011001110110001111000110111001100110011001100011110000000000000000000");
      break;
   case 57:
      strcpy(s,"0111100011001100110011001100110001111100000110000001100000110000011100000000000000000000");
      break;
   case 58:
      strcpy(s,"0000000000000000001110000011100000000000000000000011100000111000000000000000000000000000");
      break;
   case 59:
      strcpy(s,"0000000000000000001110000011100000000000000000000011100000111000000110000011000000000000");
      break;
   case 60:
      strcpy(s,"0000110000011000001100000110000011000000011000000011000000011000000011000000000000000000");
      break;
   case 61:
      strcpy(s,"0000000000000000000000000111111000000000011111100000000000000000000000000000000000000000");
      break;
   case 62:
      strcpy(s,"0110000000110000000110000000110000000110000011000001100000110000011000000000000000000000");
      break;
   case 63:
      strcpy(s,"0111100011001100000011000001100000110000001100000000000000110000001100000000000000000000");
      break;
   case 64:
      strcpy(s,"0111110011000110110001101101111011011110110111101100000011000000011111000000000000000000");
      break;
   case 65:
      strcpy(s,"0011000001111000110011001100110011001100111111001100110011001100110011000000000000000000");
      break;
   case 66:
      strcpy(s,"1111110001100110011001100110011001111100011001100110011001100110111111000000000000000000");
      break;
   case 67:
      strcpy(s,"0011110001100110110001101100000011000000110000001100011001100110001111000000000000000000");
      break;
   case 68:
      strcpy(s,"1111100001101100011001100110011001100110011001100110011001101100111110000000000000000000");
      break;
   case 69:
      strcpy(s,"1111111001100010011000000110010001111100011001000110000001100010111111100000000000000000");
      break;
   case 70:
      strcpy(s,"1111111001100110011000100110010001111100011001000110000001100000111100000000000000000000");
      break;
   case 71:
      strcpy(s,"0011110001100110110001101100000011000000110011101100011001100110001111100000000000000000");
      break;
   case 72:
      strcpy(s,"1100110011001100110011001100110011111100110011001100110011001100110011000000000000000000");
      break;
   case 73:
      strcpy(s,"0111100000110000001100000011000000110000001100000011000000110000011110000000000000000000");
      break;
   case 74:
      strcpy(s,"0001111000001100000011000000110000001100110011001100110011001100011110000000000000000000");
      break;
   case 75:
      strcpy(s,"1110011001100110011011000110110001111000011011000110110001100110111001100000000000000000");
      break;
   case 76:
      strcpy(s,"1111000001100000011000000110000001100000011000100110011001100110111111100000000000000000");
      break;
   case 77:
      strcpy(s,"1100011011101110111111101111111011010110110001101100011011000110110001100000000000000000");
      break;
   case 78:
      strcpy(s,"1100011011000110111001101111011011111110110111101100111011000110110001100000000000000000");
      break;
   case 79:
      strcpy(s,"0011100001101100110001101100011011000110110001101100011001101100001110000000000000000000");
      break;
   case 80:
      strcpy(s,"1111110001100110011001100110011001111100011000000110000001100000111100000000000000000000");
      break;
   case 81:
      strcpy(s,"0011100001101100110001101100011011000110110011101101111001111100000011000001111000000000");
      break;
   case 82:
      strcpy(s,"1111110001100110011001100110011001111100011011000110011001100110111001100000000000000000");
      break;
   case 83:
      strcpy(s,"0111100011001100110011001100000001110000000110001100110011001100011110000000000000000000");
      break;
   case 84:
      strcpy(s,"1111110010110100001100000011000000110000001100000011000000110000011110000000000000000000");
      break;
   case 85:
      strcpy(s,"1100110011001100110011001100110011001100110011001100110011001100011110000000000000000000");
      break;
   case 86:
      strcpy(s,"1100110011001100110011001100110011001100110011001100110001111000001100000000000000000000");
      break;
   case 87:
      strcpy(s,"1100011011000110110001101100011011010110110101100110110001101100011011000000000000000000");
      break;
   case 88:
      strcpy(s,"1100110011001100110011000111100000110000011110001100110011001100110011000000000000000000");
      break;
   case 89:
      strcpy(s,"1100110011001100110011001100110001111000001100000011000000110000011110000000000000000000");
      break;
   case 90:
      strcpy(s,"1111111011001110100110000001100000110000011000000110001011000110111111100000000000000000");
      break;
   case 91:
      strcpy(s,"0011110000110000001100000011000000110000001100000011000000110000001111000000000000000000");
      break;
   case 92:
      strcpy(s,"0000000010000000110000000110000000110000000110000000110000000110000000100000000000000000");
      break;
   case 93:
      strcpy(s,"0011110000001100000011000000110000001100000011000000110000001100001111000000000000000000");
      break;
   case 94:
      strcpy(s,"0011100001101100110001100000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 95:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000001111111100000000");
      break;
   case 96:
      strcpy(s,"0011000000011000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 97:
      strcpy(s,"0000000000000000000000000111100000001100011111001100110011001100011101100000000000000000");
      break;
   case 98:
      strcpy(s,"1110000001100000011000000111110001100110011001100110011001100110110111000000000000000000");
      break;
   case 99:
      strcpy(s,"0000000000000000000000000111100011001100110000001100000011001100011110000000000000000000");
      break;
   case 100:
      strcpy(s,"0001110000001100000011000111110011001100110011001100110011001100011101100000000000000000");
      break;
   case 101:
      strcpy(s,"0000000000000000000000000111100011001100111111001100000011001100011110000000000000000000");
      break;
   case 102:
      strcpy(s,"0011100001101100011000000110000011111000011000000110000001100000111100000000000000000000");
      break;
   case 103:
      strcpy(s,"0000000000000000000000000111011011001100110011001100110001111100000011001100110001111000");
      break;
   case 104:
      strcpy(s,"1110000001100000011000000110110001110110011001100110011001100110111001100000000000000000");
      break;
   case 105:
      strcpy(s,"0001100000011000000000000111100000011000000110000001100000011000011111100000000000000000");
      break;
   case 106:
      strcpy(s,"0000110000001100000000000011110000001100000011000000110000001100110011001100110001111000");
      break;
   case 107:
      strcpy(s,"1110000001100000011000000110011001101100011110000110110001100110111001100000000000000000");
      break;
   case 108:
      strcpy(s,"0111100000011000000110000001100000011000000110000001100000011000011111100000000000000000");
      break;
   case 109:
      strcpy(s,"0000000000000000000000001111110011010110110101101101011011010110110001100000000000000000");
      break;
   case 110:
      strcpy(s,"0000000000000000000000001111100011001100110011001100110011001100110011000000000000000000");
      break;
   case 111:
      strcpy(s,"0000000000000000000000000111100011001100110011001100110011001100011110000000000000000000");
      break;
   case 112:
      strcpy(s,"0000000000000000000000001101110001100110011001100110011001100110011111000110000011110000");
      break;
   case 113:
      strcpy(s,"0000000000000000000000000111011011001100110011001100110011001100011111000000110000011110");
      break;
   case 114:
      strcpy(s,"0000000000000000000000001110110001101110011101100110000001100000111100000000000000000000");
      break;
   case 115:
      strcpy(s,"0000000000000000000000000111100011001100011000000001100011001100011110000000000000000000");
      break;
   case 116:
      strcpy(s,"0000000000100000011000001111110001100000011000000110000001101100001110000000000000000000");
      break;
   case 117:
      strcpy(s,"0000000000000000000000001100110011001100110011001100110011001100011101100000000000000000");
      break;
   case 118:
      strcpy(s,"0000000000000000000000001100110011001100110011001100110001111000001100000000000000000000");
      break;
   case 119:
      strcpy(s,"0000000000000000000000001100011011000110110101101101011001101100011011000000000000000000");
      break;
   case 120:
      strcpy(s,"0000000000000000000000001100011001101100001110000011100001101100110001100000000000000000");
      break;
   case 121:
      strcpy(s,"0000000000000000000000000110011001100110011001100110011000111100000011000001100011110000");
      break;
   case 122:
      strcpy(s,"0000000000000000000000001111110010001100000110000110000011000100111111000000000000000000");
      break;
   case 123:
      strcpy(s,"0001110000110000001100000110000011000000011000000011000000110000000111000000000000000000");
      break;
   case 124:
      strcpy(s,"0001100000011000000110000001100000000000000110000001100000011000000110000000000000000000");
      break;
   case 125:
      strcpy(s,"1110000000110000001100000001100000001100000110000011000000110000111000000000000000000000");
      break;
   case 126:
      strcpy(s,"0111001111011010110011100000000000000000000000000000000000000000000000000000000000000000");
      break;
   case 127:
      strcpy(s,"0000000000000000000100000011100001101100110001101100011011111110000000000000000000000000");
      break;
   case 128:
      strcpy(s,"0111100011001100110011001100000011000000110000001100110011001100011110000011000011110000");
      break;
   case 129:
      strcpy(s,"1100110011001100000000001100110011001100110011001100110011001100011101100000000000000000");
      break;
   case 130:
      strcpy(s,"0001100000110000000000000111100011001100111111001100000011001100011110000000000000000000");
      break;
   case 131:
      strcpy(s,"0111100011001100000000000111100000001100011111001100110011001100011101100000000000000000");
      break;
   case 132:
      strcpy(s,"1100110011001100000000000111100000001100011111001100110011001100011101100000000000000000");
      break;
   case 133:
      strcpy(s,"0110000000110000000000000111100000001100011111001100110011001100011101100000000000000000");
      break;
   case 134:
      strcpy(s,"0110110001101100001110001111100000001100011111001100110011001100011101100000000000000000");
      break;
   case 135:
      strcpy(s,"0000000000000000000000000111100011001100110000001100000011001100011110000011000011110000");
      break;
   case 136:
      strcpy(s,"0111100011001100000000000111100011001100111111001100000011000000011111000000000000000000");
      break;
   case 137:
      strcpy(s,"1100110011001100000000000111100011001100111111001100000011000000011111000000000000000000");
      break;
   case 138:
      strcpy(s,"0110000000110000000000000111100011001100111111001100000011000000011111000000000000000000");
      break;
   case 139:
      strcpy(s,"0110110001101100000000000111100000011000000110000001100000011000011111100000000000000000");
      break;
   case 140:
      strcpy(s,"0011100001101100000000000111100000011000000110000001100000011000011111100000000000000000");
      break;
   case 141:
      strcpy(s,"0011000000011000000000000111100000011000000110000001100000011000011111100000000000000000");
      break;
   case 142:
      strcpy(s,"1100110000000000001100000111100011001100110011001111110011001100110011000000000000000000");
      break;
   case 143:
      strcpy(s,"1100110011001100011110000111100011001100110011001111110011001100110011000000000000000000");
      break;
   case 144:
      strcpy(s,"0001100000110000111111001100010011000000111110001100000011000100111111000000000000000000");
      break;
   case 145:
      strcpy(s,"0000000000000000000000001111111000011011011111111101100011011000111011110000000000000000");
      break;
   case 146:
      strcpy(s,"0011111001111000110110001101100011111110110110001101100011011000110111100000000000000000");
      break;
   case 147:
      strcpy(s,"0111100011001100000000000111100011001100110011001100110011001100011110000000000000000000");
      break;
   case 148:
      strcpy(s,"1100110011001100000000000111100011001100110011001100110011001100011110000000000000000000");
      break;
   case 149:
      strcpy(s,"0110000000110000000000000111100011001100110011001100110011001100011110000000000000000000");
      break;
   case 150:
      strcpy(s,"0111100011001100000000001100110011001100110011001100110011001100011101100000000000000000");
      break;
   case 151:
      strcpy(s,"0110000000110000000000001100110011001100110011001100110011001100011101100000000000000000");
      break;
   case 152:
      strcpy(s,"0110011001100110000000000110011001100110011001100110011000111100000011000001100011110000");
      break;
   case 153:
      strcpy(s,"0000000001111000110011001100110011001100110011001100110011001100011110000000000000000000");
      break;
   case 154:
      strcpy(s,"0000000011001100110011001100110011001100110011001100110011001100011110000000000000000000");
      break;
   case 155:
      strcpy(s,"0011000000110000011110001100110011000000110000001100110001111000001100000011000000000000");
      break;
   case 156:
      strcpy(s,"0110011001100000011000000110000011111100011000000110000011000000111111100000000000000000");
      break;
   case 157:
      strcpy(s,"1100110011001100110011000111100011111100001100001111110000110000001100000000000000000000");
      break;
   case 158:
      strcpy(s,"1000100010001000100010001111000010001000100111101000110010001101100001100000000000000000");
      break;
   case 159:
      strcpy(s,"0001101100011000000110000111111000011000000110000001100011011000011100000000000000000000");
      break;
   case 160:
      strcpy(s,"0001100000110000000000000111100000001100011111001100110011001100011101100000000000000000");
      break;
   case 161:
      strcpy(s,"0001100000110000000000000111100000011000000110000001100000011000011111100000000000000000");
      break;
   case 162:
      strcpy(s,"0001100000110000000000000111100011001100110011001100110011001100011110000000000000000000");
      break;
   case 163:
      strcpy(s,"0001100000110000000000001100110011001100110011001100110011001100011101100000000000000000");
      break;
   case 164:
      strcpy(s,"0111011011011100000000001111100011001100110011001100110011001100110011000000000000000000");
      break;
   case 165:
      strcpy(s,"1101110000000000110001101110011011110110110111101100111011000110110001100000000000000000");
      break;
   case 166:
      strcpy(s,"0111100011001100110011000111111000000000111111100000000000000000000000000000000000000000");
      break;
   case 167:
      strcpy(s,"0111100011001100110011000111100000000000111111100000000000000000000000000000000000000000");
      break;
   case 168:
      strcpy(s,"0011000000110000000000000011000001100000110000001100000011001100011110000000000000000000");
      break;
   case 169:
      strcpy(s,"0000000000000000000000000000000011111100110000001100000011000000000000000000000000000000");
      break;
   case 170:
      strcpy(s,"0000000000000000000000000000000011111100000011000000110000001100000000000000000000000000");
      break;
   case 171:
      strcpy(s,"0100001011000110110011001101100000110000011011101100001110000110000011000001111100000000");
      break;
   case 172:
      strcpy(s,"0110001111100110011011000111100000110111011011111101101110110011001111110000001100000000");
      break;
   case 173:
      strcpy(s,"0011000000110000000000000011000000110000011110000111100001111000001100000000000000000000");
      break;
   case 174:
      strcpy(s,"0000000000000000000000000011001101100110110011001100110001100110001100110000000000000000");
      break;
   case 175:
      strcpy(s,"0000000000000000000000001100110001100110001100110011001101100110110011000000000000000000");
      break;
   case 176:
      strcpy(s,"1001001001001001001001001001001001001001001001001001001001001001001001001001001001001001");
      break;
   case 177:
      strcpy(s,"1010101001010101101010100101010110101010010101011010101001010101101010100101010110101010");
      break;
   case 178:
      strcpy(s,"1101101110110110011011011101101110110110011011011101101110110110011011011101101110110110");
      break;
   case 179:
      strcpy(s,"0001100000011000000110000001100000011000000110000001100000011000000110000001100000011000");
      break;
   case 180:
      strcpy(s,"0001100000011000000110000001100011111000000110000001100000011000000110000001100000011000");
      break;
   case 181:
      strcpy(s,"0001100000011000000110001111100000011000000110001111100000011000000110000001100000011000");
      break;
   case 182:
      strcpy(s,"0110011001100110011001100110011011100110011001100110011001100110011001100110011001100110");
      break;
   case 183:
      strcpy(s,"0000000000000000000000000000000011111110011001100110011001100110011001100110011001100110");
      break;
   case 184:
      strcpy(s,"0000000000000000000000001111100000011000000110001111100000011000000110000001100000011000");
      break;
   case 185:
      strcpy(s,"0110011001100110011001101110011000000110000001101110011001100110011001100110011001100110");
      break;
   case 186:
      strcpy(s,"0110011001100110011001100110011001100110011001100110011001100110011001100110011001100110");
      break;
   case 187:
      strcpy(s,"0000000000000000000000001111111000000110000001101110011001100110011001100110011001100110");
      break;
   case 188:
      strcpy(s,"0110011001100110011001101110011000000110000001101111111000000000000000000000000000000000");
      break;
   case 189:
      strcpy(s,"0110011001100110011001100110011011111110000000000000000000000000000000000000000000000000");
      break;
   case 190:
      strcpy(s,"0001100000011000000110001111100000011000000110001111100000000000000000000000000000000000");
      break;
   case 191:
      strcpy(s,"0000000000000000000000000000000011111000000110000001100000011000000110000001100000011000");
      break;
   case 192:
      strcpy(s,"0001100000011000000110000001100000011111000000000000000000000000000000000000000000000000");
      break;
   case 193:
      strcpy(s,"0001100000011000000110000001100011111111000000000000000000000000000000000000000000000000");
      break;
   case 194:
      strcpy(s,"0000000000000000000000000000000011111111000110000001100000011000000110000001100000011000");
      break;
   case 195:
      strcpy(s,"0001100000011000000110000001100000011111000110000001100000011000000110000001100000011000");
      break;
   case 196:
      strcpy(s,"0000000000000000000000000000000011111111000000000000000000000000000000000000000000000000");
      break;
   case 197:
      strcpy(s,"0001100000011000000110000001100011111111000110000001100000011000000110000001100000011000");
      break;
   case 198:
      strcpy(s,"0001100000011000000110000001111100011000000110000001111100011000000110000001100000011000");
      break;
   case 199:
      strcpy(s,"0110011001100110011001100110011001100111011001100110011001100110011001100110011001100110");
      break;
   case 200:
      strcpy(s,"0110011001100110011001100110011101100000011000000111111100000000000000000000000000000000");
      break;
   case 201:
      strcpy(s,"0000000000000000000000000111111101100000011000000110011101100110011001100110011001100110");
      break;
   case 202:
      strcpy(s,"0110011001100110011001101110011100000000000000001111111100000000000000000000000000000000");
      break;
   case 203:
      strcpy(s,"0000000000000000000000001111111100000000000000001110011101100110011001100110011001100110");
      break;
   case 204:
      strcpy(s,"0110011001100110011001100110011101100000011000000110011101100110011001100110011001100110");
      break;
   case 205:
      strcpy(s,"0000000000000000000000001111111100000000000000001111111100000000000000000000000000000000");
      break;
   case 206:
      strcpy(s,"0110011001100110011001101110011100000000000000001110011101100110011001100110011001100110");
      break;
   case 207:
      strcpy(s,"0001100000011000000110001111111100000000000000001111111100000000000000000000000000000000");
      break;
   case 208:
      strcpy(s,"0110011001100110011001100110011011111111000000000000000000000000000000000000000000000000");
      break;
   case 209:
      strcpy(s,"0000000000000000000000001111111100000000000000001111111100011000000110000001100000011000");
      break;
   case 210:
      strcpy(s,"0000000000000000000000000000000011111111011001100110011001100110011001100110011001100110");
      break;
   case 211:
      strcpy(s,"0110011001100110011001100110011001111111000000000000000000000000000000000000000000000000");
      break;
   case 212:
      strcpy(s,"0001100000011000000110000001111100011000000110000001111100000000000000000000000000000000");
      break;
   case 213:
      strcpy(s,"0000000000000000000000000001111100011000000110000001111100011000000110000001100000011000");
      break;
   case 214:
      strcpy(s,"0000000000000000000000000000000001111111011001100110011001100110011001100110011001100110");
      break;
   case 215:
      strcpy(s,"0110011001100110011001100110011011100111011001100110011001100110011001100110011001100110");
      break;
   case 216:
      strcpy(s,"0001100000011000000110001111111100000000000000001111111100011000000110000001100000011000");
      break;
   case 217:
      strcpy(s,"0001100000011000000110000001100011111000000000000000000000000000000000000000000000000000");
      break;
   case 218:
      strcpy(s,"0000000000000000000000000000000000011111000110000001100000011000000110000001100000011000");
      break;
   case 219:
      strcpy(s,"1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
      break;
   case 220:
      strcpy(s,"0000000000000000000000000000000000000000111111111111111111111111111111111111111111111111");
      break;
   case 221:
      strcpy(s,"1111000011110000111100001111000011110000111100001111000011110000111100001111000011110000");
      break;
   case 222:
      strcpy(s,"0000111100001111000011110000111100001111000011110000111100001111000011110000111100001111");
      break;
   case 223:
      strcpy(s,"1111111111111111111111111111111111111111000000000000000000000000000000000000000000000000");
      break;
   case 224:
      strcpy(s,"0000000000000000000000000111011011011110110011001100110011011110011101100000000000000000");
      break;
   case 225:
      strcpy(s,"0111100011001100110011001101100011001100110011001100110011111000110000000110000000000000");
      break;
   case 226:
      strcpy(s,"1111110011001100110011001100000011000000110000001100000011000000110000000000000000000000");
      break;
   case 227:
      strcpy(s,"1111111001101100011011000110110001101100011011000110110001101100011001100000000000000000");
      break;
   case 228:
      strcpy(s,"1111110011000100011001000110000000110000011000000110010011000100111111000000000000000000");
      break;
   case 229:
      strcpy(s,"0000000000000000000000000111111011001000110011001100110011001100011110000000000000000000");
      break;
   case 230:
      strcpy(s,"0000000000000000000000000110011001100110011001100110011001100110011110110110000011000000");
      break;
   case 231:
      strcpy(s,"0000000000000000011101101101110000011000000110000001100000011000000011100000000000000000");
      break;
   case 232:
      strcpy(s,"1111110000110000011110001100110011001100110011000111100000110000111111000000000000000000");
      break;
   case 233:
      strcpy(s,"0111100011001100110011001100110011111100110011001100110011001100011110000000000000000000");
      break;
   case 234:
      strcpy(s,"0111110011000110110001101100011011000110011011000110110001101100111011100000000000000000");
      break;
   case 235:
      strcpy(s,"0011110001100000001100000111100011001100110011001100110011001100011110000000000000000000");
      break;
   case 236:
      strcpy(s,"0000000000000000011101101101101111011011110110110110111000000000000000000000000000000000");
      break;
   case 237:
      strcpy(s,"0000000000000110011111001101111011010110111101100111110011000000000000000000000000000000");
      break;
   case 238:
      strcpy(s,"0011110001100000110000001100000011111100110000001100000001100000001111000000000000000000");
      break;
   case 239:
      strcpy(s,"0000000001111000110011001100110011001100110011001100110011001100110011000000000000000000");
      break;
   case 240:
      strcpy(s,"0000000011111100000000000000000011111100000000000000000011111100000000000000000000000000");
      break;
   case 241:
      strcpy(s,"0000000000110000001100001111110000110000001100000000000011111100000000000000000000000000");
      break;
   case 242:
      strcpy(s,"0110000000110000000110000001100000110000011000000000000011111100000000000000000000000000");
      break;
   case 243:
      strcpy(s,"0001100000110000011000000110000000110000000110000000000011111100000000000000000000000000");
      break;
   case 244:
      strcpy(s,"0000000000001110000110110001101100011000000110000001100000011000000110000001100000011000");
      break;
   case 245:
      strcpy(s,"0001100000011000000110000001100000011000000110001101100011011000011100000000000000000000");
      break;
   case 246:
      strcpy(s,"0000000000110000001100000000000011111100000000000011000000110000000000000000000000000000");
      break;
   case 247:
      strcpy(s,"0000000001110011110110111100111000000000011100111101101111001110000000000000000000000000");
      break;
   case 248:
      strcpy(s,"0011110001100110011001100110011000111100000000000000000000000000000000000000000000000000");
      break;
   case 249:
      strcpy(s,"0000000000000000000000000001110000011100000000000000000000000000000000000000000000000000");
      break;
   case 250:
      strcpy(s,"0000000000000000000000000000000000011000000000000000000000000000000000000000000000000000");
      break;
   case 251:
      strcpy(s,"0000011100000100000001000000010001000100011001000011010000011100000011000000000000000000");
      break;
   case 252:
      strcpy(s,"1101100001101100011011000110110001101100000000000000000000000000000000000000000000000000");
      break;
   case 253:
      strcpy(s,"0111100000001100000110000011000001111100000000000000000000000000000000000000000000000000");
      break;
   case 254:
      strcpy(s,"0000000000111100001111000011110000111100001111000011110000111100001111000000000000000000");
      break;
   case 255:
      strcpy(s,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      break;
   }
}



//*************************** WRITE_TEXT *************************s
// Ecrit un texte dans l'image pointée par p aux cooronnées (x,y)  
// avec le niveau intensité .                                      
//*****************************************************************
int write_text(short *check, int imax, int jmax, char *text,int x,int y,double intensite)
{
//PIC_TYPE v;
short v;
int i,j,k,pos,dx,adr,size,px,py;
char c;
char s[128];

size=strlen(text);

if (intensite>32767.0) 
   v=32767;
else if (intensite<-32768.0) 
   v=-32768;
else 
   v=(short)intensite;

x=x-1;
y=y+9;

dx=0;

for (k=0;k<size;k++)
   {
   c=(char)text[k];
   return_char(c,s);
   pos=0;
   for (j=0;j<11;j++)
      {
      for (i=0;i<8;i++,pos++)
         {
         if (s[pos]=='1')
            {
            px=x+i+dx;
            py=y-j;
            if (px<0 || px>imax-9 || py<0 || py>jmax-8) break;
            adr=px+py*imax;
            check[adr]=v;
            }
         }
      }
   dx=dx+8;
   }
    
return 1;
}

//*************************************** WRITE_WAVE **********************************************
// Inscrit dans l'image de vérification (check) la longueur centrale (pour imax/2) pour l'ordre k. 
// La décalage dx trouvé avec la raie Ne 5852 est pris en compte.                                  
//*************************************************************************************************
int write_wave( short *check, int imax, int jmax, double posx,double dx,int k,ORDRE *ordre,INFOSPECTRO spectro)
{
double alpha=spectro.alpha*PI/180.0;
double gamma=spectro.gamma*PI/180.0;
double m=spectro.m;
double focale=spectro.focale;
double pixel=spectro.pixel;
char ligne[256];

int py=(int)ordre[k].yc;
int px=(int)posx;

double beta=(posx-(double)imax/2-dx)*pixel/focale;

double lambda;
lambda=cos(gamma)*(sin(alpha)+sin(beta+alpha))/m/(double)k*1.0e7;

sprintf(ligne,"%.1f A",lambda);
//write_text(check,imax,jmax,ligne,px-25,py-25,32000);
write_text(check,imax,jmax,ligne,px+20,py+4,32000);
 
return 0;
}


//***************************** DRAW_RECT_CALIB ************************************
// Trace dans l'image 2D de vérification un carré à la position px pour l'ordre n   
// (en trait continu). La fonction tiens compte de la courbure                      
// des ordres, calculée précédemment.                                               
//**********************************************************************************
int draw_rect_calib(short *check,int imax, int jmax, int n,double px,ORDRE *ordre,int taille)
{
int degre=4;
int k;
int ii,jj;
double v;

v=0.0;
for (k=0;k<=degre;k++)
   {
   v=v+ordre[n].poly_order[k]*pow(px+(double)ordre[n].min_x-1.0,(double)k);
   }
double py=v;
int px2=(int)(px+.5)+ordre[n].min_x-1;
int py2=(int)(py+.5);

for (jj=py2-taille;jj<=py2+taille;jj++)
   {
   ii=px2-taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
   ii=px2+taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
   }
for (ii=px2-taille;ii<=px2+taille;ii++)
   {
   jj=py2-taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
   jj=py2+taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
   }

return 0;
}



//***************************** DRAW_RECT_CALIB2 ***********************************
// Trace dans l'image 2D de vérification un carré à la position px pour l'ordre n   
// (en pointillé). La fonction tiens compte de la courbure                          
// des ordres, calculée précédemment.                                               
//********************************************************************************** 
int draw_rect_calib2(short *check,int imax, int jmax, int n,double px,ORDRE *ordre,int taille)
{
int degre=4;
int k;
int ii,jj;
double v;

v=0.0;
for (k=0;k<=degre;k++)
   {
   v=v+ordre[n].poly_order[k]*pow(px+(double)ordre[n].min_x-1.0,(double)k);
   }
double py=v;
int px2=(int)(px+.5)+ordre[n].min_x-1;
int py2=(int)(py+.5);

for (jj=py2-taille;jj<=py2+taille;jj+=2)
   {
   ii=px2-taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=20000;
   ii=px2+taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=20000;
   }
for (ii=px2-taille;ii<=px2+taille;ii+=2)
   {
   jj=py2-taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=20000;
   jj=py2+taille;
   if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=20000;
   }

return 0;
}

//***************************** makeCheck ***********************************
// genere une image check.fit  
//********************************************************************************** 
void makeCheck(char *fileName, ::std::list<double> &lineList) {

   short * check = NULL;
   ORDRE *ordre = NULL;
   try {
      INFOSPECTRO spectro;
      double dx_ref;

      Eshel_getInfoSpectro(fileName,&spectro);
      Eshel_getOrderTable(fileName,&ordre, &dx_ref);
      int min_order = spectro.min_order;
      int max_order = spectro.max_order;

      check = new short[spectro.imax*spectro.jmax];
      memset(check,0,spectro.imax*spectro.jmax*sizeof(short));

      // Image check  : j'ajoute le numero des ordres
      for (int n=0;n<MAX_ORDRE;n++)
      {
         if (ordre[n].flag==1)
         { 
            write_wave(check,spectro.imax,spectro.jmax,(double)spectro.imax/2.0,dx_ref,n,ordre,spectro);
         }
      }

      // ------------------------------------------------------------------------------------------------
      // j'ajoute les numeros d'ordre dans l'image check (c'était dans find_y_pos)
      // ------------------------------------------------------------------------------------------------
      for (int n=0;n<MAX_ORDRE;n++)
      {
         if (ordre[n].flag==1)
         { 
            char ligne[256];
            int imax = spectro.imax;
            int jmax = spectro.jmax;
            int ii,jj,py,px;
            double pos_y;

            // marque le point trouvé dans chaque ordre dans l'image de vérif (find_y_pos)
            if (n>=min_order && n<=max_order)
            {
               pos_y=ordre[n].yc;
               px=imax/2-1;   
               py=(int)(pos_y+.5); 
               for (jj=py-3;jj<=py+3;jj++)
               {
                  ii=px-3;
                  if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
                  ii=px+3;
                  if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
               }
               for (ii=px-3;ii<=px+3;ii++)
               {
                  jj=py-3;
                  if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
                  jj=py+3;
                  if (ii>=0 && ii<imax && jj>=0 && jj<jmax) check[ii+jj*imax]=32000;
               }

               // inscrit le numéro de l'ordre dans l'image de vérif
               sprintf(ligne,"#%d",n);
               write_text(check,imax,jmax,ligne,px-10,py+4,32000);
            }

         }
      }

      // Je dessine les prediction des positions des raies dans l'image check ( c'était dans calib_prediction)
      for (int n=spectro.min_order;n<=spectro.max_order;n++)
      {  
         if ( ordre[n].flag == 1 ) {
            ::std::list<double>::iterator i;
            for (i=lineList.begin(); i != lineList.end(); ++i) 
            {
               double lambda = *i;
               double px=compute_pos((double)n,lambda,dx_ref,spectro.imax,spectro.alpha,spectro.gamma,spectro.m,spectro.focale,spectro.pixel);
               if (px>ordre[n].min_x && px<ordre[n].max_x) {
                  draw_rect_calib2(check,spectro.imax,spectro.jmax,n,px-(double)ordre[n].min_x,ordre,11);
                  if ( lambda == 6242.941 ) {
                     log("lambda=%f  px = %f \n",lambda,px);
                  }
               }
            }
         }
      }


      
      // ------------------------------------------------------------------------------------------------
      // j'ajoute les lignes de crete des ordres dans l'image check
      // ------------------------------------------------------------------------------------------------
      // voir track_order()
      for (int n=0;n<MAX_ORDRE;n++)
      {
         int imax = spectro.imax;
         int jmax = spectro.jmax;

         for (int x=ordre[n].min_x;x<ordre[n].max_x;x++) {
            double y = ordre[n].poly_order[0] + ordre[n].poly_order[1]*x + ordre[n].poly_order[2]*x*x + ordre[n].poly_order[3]*x*x*x +  ordre[n].poly_order[4]*x*x*x*x; 
            check[x+(int)(y)*imax]=1000;
         }
      }

      // ------------------------------------------------------------------------------------------------
      // j'ajoute les carres autour des raies trouvées dans l'image check (c'était dans calib_spec)
      // ------------------------------------------------------------------------------------------------
      LINE_GAP *lineGap;
      int  size;
      // je resupere les ecarts dans le fichier de la lampe
      Eshel_getLineGap(fileName, &lineGap, &size);

      for(int i = 0; i < size; i++) {
         if (lineGap[i].valid == 1 ) {
            int psf_posx = (int)(lineGap[i].l_posx +0.5);
            int n = lineGap[i].order;
            draw_rect_calib(check,spectro.imax,spectro.jmax,n,psf_posx-ordre[n].min_x,ordre,ordre[n].wide_x/2);
         }
      }
      // je libere le buffer alloue par la DLL
      Eshel_freeData(lineGap);


      // -------------------------------------------------------
      // Sauvegarde de l'image de vérification (image check.fit)
      // -------------------------------------------------------
      char checkFileName[1024];
      strcpy(checkFileName,fileName); 
      // je remplace .fit par -check.fit
      char * pos = strchr(checkFileName,'.');
      if ( pos != NULL ) {
         strcpy(pos,"-check");
      } else {
         strcat(pos,"-check");
      }
      save_fits(checkFileName,check, spectro.imax, spectro.jmax,"CHECK");
      if ( check != NULL) delete [] check;
      Eshel_freeData(ordre);

   } catch (std::exception e) {
      if ( check != NULL) delete [] check;
      Eshel_freeData(ordre);
      throw e;
   }
}





/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#ifdef WIN32
   int __cdecl Eshel_Init(Tcl_Interp *interp)
#else
   int Esheltcl_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.4",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization in libeshel_tcl.",TCL_STATIC);
      return TCL_ERROR;
   }

   /* ajouter ici les autres fonctions d'extension que vous allez creer */
   Tcl_CreateCommand(interp,"eshel_processFlat",(Tcl_CmdProc *)cmdEshelProcessFlat,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_processCalib",(Tcl_CmdProc *)cmdEshelProcessCalib,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_processObject",(Tcl_CmdProc *)cmdEshelProcessObject,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   //Tcl_CreateCommand(interp,"eshel_findSpectroParameters",(Tcl_CmdProc *)cmdEshelFindSpectroParameters,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);   
   
   Tcl_SetVar((Tcl_Interp*) interp, "libesheltcl_version", "1.0", TCL_GLOBAL_ONLY);


   return TCL_OK;
}
