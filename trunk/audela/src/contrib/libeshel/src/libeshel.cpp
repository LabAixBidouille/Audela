// echelle.cpp : Eshel main functions .
//

#include <windows.h>
#include <math.h>
#include <float.h> // pour _isnan
#include <vector>
#include <limits.h> // pour INT_MAX et INT_MIN


#include <exception>
#define swab _swab  //  replace "swab" by "_swab" because "swab" is deprecaded

#include "infoimage.h"
#include "order.h"
#include "linegap.h"
#include "fitsfile.h"
#include "libeshel.h"
#include "processing.h"

#define DEVIDE_FLAT  1

////////////////////////////////////////
////////////////////////////////////////
// Traitement de l'image "flat-field" //
////////////////////////////////////////
////////////////////////////////////////

void Eshel_processFlat(
   char *ledfileName,      // nom du fichier led (image pretraitee pour la calibration geometrique)
   char *tungstenFileName, // nom du fichier tungsten (image pretraitee pour le blaze)
   char *flatFileName,     // nom du fichier flat traitee  en sortie
   int ordre_ref_y,        // ordonnée du centre de l’ordre de référence
   int ordre_ref,          // numero de l’ordre de référence
   double lambda_ref,      // longueur d’onde de la raie de référence 
   int neon_ref_x,         // abscisse de la raie de référence 
   int wide_y,             // hauteur du binning 
   int step_y,             // écartement moyen des ordres
   int seuil_ordre,        // seuil de détection
   ORDRE *ordre,           // table des ordre (avec la marge gauche, marge droit et slant renseignés)
   INFOSPECTRO &spectro,   // parametres du specto et de la caméra
   ::std::list<double> &lineList, // liste des raies
   int *nb_ordre,          // (OUT) nombre d'ordres trouvés
   double *dx_ref,         // (OUT) écart de l'abcisse de la raie de référence entre la position calculée et la position observée. 
   char *logFileName,      // nom du fichier de log
   short *check)           // nom de l'image de controle
{
   PIC_TYPE *tampon = NULL;
   INFOIMAGE *buffer = NULL;
   FILE *hand_log = openLog(logFileName);
   CCfits::PFitsFile pLedFits = NULL;
   CCfits::PFitsFile pTungstenFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   PROCESS_INFO processInfo;
   try {

      // ----------------
      // controle des ordres
      char message[1024];
      for(int n=0; n<MAX_ORDRE; n++ ) {         
         if (ordre[n].min_x < 0 || ordre[n].min_x > spectro.imax  ) {
            sprintf(message,"order %d : invalid min_x=%d , must be 0 < min_x < %d", n, ordre[n].min_x , spectro.imax);
            throw ::std::exception(message);
         }
         if (ordre[n].max_x < 0 || ordre[n].max_x > spectro.imax  ) {
            sprintf(message,"order %d : invalid max_x=%d , must be 0 < max_x < %d", n, ordre[n].max_x , spectro.imax);
            throw ::std::exception(message);
         }
         if (ordre[n].min_x > ordre[n].max_x   ) {
            sprintf(message,"order %d : invalid min_x=%d max_x=%d  must be min_x < max_x", n, ordre[n].min_x , ordre[n].max_x);
            throw ::std::exception(message);
         }
      }

      // -------------------------------------
      // Lecture de l'image LED 2D pretraitee
      // -------------------------------------  
      // je lis l'image stockee dans le PHDU du fichier d'entree 
      pLedFits = Fits_openFits(ledfileName, false); 

      // je verifie si la table des ORDRES existe deja
      int ordersFound = 1;
      try { 
         Fits_getOrders(pLedFits, ordre, dx_ref);
         // la table des ordres existe
         ordersFound = 1;
         // je lis les autres informations
         Fits_getInfoSpectro(pLedFits, &spectro);
         Fits_getProcessInfo(pLedFits, &processInfo);
         Fits_closeFits(pLedFits);
      } catch( std::exception e ) {
         // la table des ordres n'existe pas 
         ordersFound = 0;
         Fits_closeFits(pLedFits);
      } 

      if ( ordersFound == 1 ) {
         pOutFits = Fits_createFits(ledfileName, flatFileName); 
      } else {
         pOutFits = Fits_createFits(ledfileName, flatFileName); 
         // j'ajoute le mot cle contenant la version de la librairie
         setSoftwareVersionKeyword(pOutFits);
         // je change le type d'image
         Fits_setKeyword(pOutFits,"PRIMARY","IMAGETYP","FLAT","");
         // je lis l'image 2D
         Fits_getImage(pOutFits, &buffer); 

         // On contrôle l'intégrité de la taille de l'image
         if (buffer->imax!=spectro.imax || buffer->jmax!=spectro.jmax) {
            char message[1024];
            sprintf(message, "La taille (%d,%d) de l'image %s est différente de (%d,%d) des parametres du spectrographe.",
               buffer->imax,buffer->jmax, ledfileName, spectro.imax, spectro.jmax);
            throw std::exception(message);
         }
         // ---------------------------------------------------------------------------------------------------
         // Recherche de la position Y des ordres suivant l'axe vertical central de l'image (imax/2)
         // ---------------------------------------------------------------------------------------------------
         find_y_pos(buffer,check,spectro.imax,spectro.jmax,ordre_ref_y,ordre_ref,step_y,seuil_ordre,ordre,nb_ordre,
            spectro.min_order,spectro.max_order,hand_log);
         fprintf(hand_log,"Nombre d'ordres trouve : %d\n",*nb_ordre);

         // ---------------------------------------------------------------------------------------
         // Détection de la ligne de crête des ordres dans l'image flat
         // et modélisation (polynômes de degré 4)
         // ---------------------------------------------------------------------------------------
         fprintf(hand_log,"Polynômes des ordres\n");
         for (int n=spectro.min_order;n<=spectro.max_order;n++)
         {
            if (ordre[n].flag==1)
            {
               track_order(buffer,check,spectro.imax,spectro.jmax,wide_y,ordre,n,hand_log);
            }
         }

         // ----------------------------------------------------------------------------------------------
         // Calcul de la position théorique de raies de calibration dans le profil spectral 
         // On s'appui sur la position observée de la raie Thorium 6584 A à l'ordre 34 
         // pour étalonner le calcul des autres raies. 
         // -----------------------------------------------------------------------------------------------
         double dx;
         if (calib_prediction(lambda_ref,ordre_ref,check,spectro.imax,spectro.jmax,neon_ref_x,ordre,&dx,spectro,lineList)) 
         {
            throw std::exception("calib_prediction error");
         } 
         *dx_ref = dx;
         if ( _isnan(dx) ) {
            *dx_ref = 0;
         }

         // ------------------------------------------------------------------------------------------------
         // Calcule la longueur d'onde du centre de chaque ordre (à imax/2)
         // ------------------------------------------------------------------------------------------------
         for (int n=0;n<MAX_ORDRE;n++)
         {
            if (ordre[n].flag==1)
            { 
               ordre[n].central_lambda=get_central_wave(spectro.imax,(double)spectro.imax/2.0,dx,n,spectro);
            }
         }

         processInfo.referenceOrderNum = ordre_ref;
         processInfo.referenceOrderX =neon_ref_x;
         processInfo.referenceOrderY =ordre_ref_y;
         processInfo.referenceOrderLambda = lambda_ref; 
         processInfo.detectionThreshold = seuil_ordre;
         processInfo.yStep = step_y;
         processInfo.calibrationIteration = 0; 
      }

      // ------------------------------------------------------------------------------------------------
      // Extraction de profils pour la fonction de blaze
      // 
      //  si le fichier ne contient pas les profils 1A
      //     si le fichier tungstenFileName est different de ledFileName
      //         j'ouvre le fichier tungstenFileName et je charge l'image 2D dans le buffer
      //         j'extrais les profils du buffer
      //     sinon
      //         j'extrais les profils du buffer déja charge
      //  sinon 
      //     si le fichier tungstenFileName est different de ledFileName
      //         je copie les profils 1A dans le FLAT
      //     sinon
      //         je copie les profils 1A dans le FLAT
      // ------------------------------------------------------------------------------------------------
      // j'ouvre le fichier tungsten
      pTungstenFits = Fits_openFits(tungstenFileName, false); 

      try { 
         // je copie les profils 1A  s'il exitent. 
         // Si les profils 1A sont absents une exception est retounee et je passe dans le catch
         for (int n=spectro.min_order;n<=spectro.max_order;n++) {
            if (ordre[n].flag==1) {
               int width = ordre[n].max_x - ordre[n].min_x +1;
               ::std::valarray<double> profile(width);
               Fits_getRawProfile(pOutFits, "P_1A_", n, profile, &ordre[n].min_x);
               Fits_setRawProfile(pOutFits, "P_1A_", n, profile, ordre[n].min_x);
            }
         }
      } catch( std::exception e ) {
         if ( strcmp(ledfileName, tungstenFileName) != 0 ) {
            // j'ouvre le fichier TUNGSTEN s'il est different du fichier LED
            freeImage(buffer);
            buffer = NULL;
            // je lis l'image stockee dans le PHDU du fichier d'entree 
            Fits_getImage(pTungstenFits, &buffer);     
            // je contrôle que l'image de l'objet est de la meme taille que l'image de reference
            if (spectro.imax!=buffer->imax || spectro.jmax!=buffer->jmax) {
               sprintf(message,"La taille de l'image du TUNGSTEN %s (%d,%d) est de différente du LED %s (%d,%d)",
                  tungstenFileName, buffer->imax , buffer->jmax, ledfileName, spectro.imax, spectro.jmax);
               throw std::exception(message);
            }
         }
         // -----------------------------------------------------------------------------------------
         // Extraction de chaque ordre trouvé dans l'image TUNGSTEN et sauvegarde
         // du résultat dans des HDU P_1A_n distincts pour chaque ordre 
         // -----------------------------------------------------------------------------------------
         tampon = new PIC_TYPE[spectro.imax*spectro.jmax];
         memmove(tampon,buffer->pic,spectro.imax*spectro.jmax*sizeof(PIC_TYPE)); // tampon de travail

         int profileWidth = spectro.imax;
         int profileHeight = spectro.max_order - spectro.min_order +1;

         for (int n=spectro.min_order;n<=spectro.max_order;n++)
         {
            if (ordre[n].flag==1) 
            {
               int width = ordre[n].max_x - ordre[n].min_x +1;
               ::std::valarray<double> profile(width);

               if (extract_order(buffer,n,spectro.jmax,ordre,profile,NULL,(::std::valarray<int> *) NULL)==1 ) {
                  throw std::exception("extract_order error");
               }

               Fits_setRawProfile(pOutFits, "P_1A_", n, profile, ordre[n].min_x);
               // je restaure l'image 2D
               memmove(buffer->pic,tampon,spectro.imax*spectro.jmax*sizeof(PIC_TYPE));
            }
         }
      }

      // j'ajoute les infos du spectro, les parametres de traitement et la table des ordres dans le fichier de sortie
      Fits_setOrders(pOutFits, &spectro, &processInfo, ordre, *dx_ref);

      // je ferme le fichier tungsten
      Fits_closeFits(pTungstenFits);
      // je ferme le fichier de sortie
      Fits_closeFits( pOutFits);
      delete [] tampon;
      if ( buffer!= NULL) freeImage(buffer);
      if ( hand_log != NULL) fclose(hand_log);
   } catch( std::exception e ) {
      delete [] tampon;
      if ( buffer!= NULL) freeImage(buffer);
      if ( hand_log != NULL) fclose(hand_log);
      if ( pLedFits != NULL) Fits_closeFits(pLedFits);
      if ( pTungstenFits != NULL) Fits_closeFits( pTungstenFits);
      if ( pOutFits != NULL) Fits_closeFits( pOutFits);
      throw e;
   } 
}





////////////////////////////////////////
////////////////////////////////////////
// Traitement de l'image "lamp"       //
////////////////////////////////////////
////////////////////////////////////////

void Eshel_processCalib(
   char *lampNameIn, 
   char *lampNameOut,
   char *flatName,                
   int ordre_ref, 
   double lambda_ref, 
   int neon_ref_x,
   int calibration_iteration,
   char *logFileName, 
   short *check,
   ::std::list<double> &lineList)  
{

   INFOIMAGE *lampBuffer = NULL;
   CCfits::PFitsFile pFlatFits = NULL;
   FILE *hand_log = openLog(logFileName);
   char message[1024];
   PIC_TYPE * tampon = NULL;;
   ORDRE *ordre = NULL;
   INFOSPECTRO spectro;
   PROCESS_INFO processInfo;
   CCfits::PFitsFile pOutFits = NULL;
   ::std::list<LINE_GAP> lineGapList;
   double step=0.1;
   double dx_ref= 0.0;

   try {

      // je lis les parametres spectro 
      pFlatFits = Fits_openFits(flatName, false);
      Fits_getInfoSpectro(pFlatFits, &spectro);

      //je complete les informations du traitement
      Fits_getProcessInfo(pFlatFits, &processInfo);
      processInfo.calibrationIteration = calibration_iteration;

      // je lis la table des ordres
      int nbOrder = spectro.max_order - spectro.min_order +1;
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pFlatFits, ordre, &dx_ref);
      
      // je cree le fichier de sortie
      pOutFits = Fits_createFits(lampNameIn, lampNameOut); 
      // j'ajoute le mot cle contenant la version de la librairie
      setSoftwareVersionKeyword(pOutFits);
      // je lis l'image 2D
      Fits_getImage(pOutFits, &lampBuffer); 

      // je contrôle que l'image de la lampe est de la meme taille que l'image de reference
      if (spectro.imax!=lampBuffer->imax || spectro.jmax!=lampBuffer->jmax) {
         sprintf(message,"La taille de l'image de la lampe %s (%d,%d) est de différente du flat %s (%d,%d)",
            lampNameIn, lampBuffer->imax , lampBuffer->jmax,flatName, spectro.imax, spectro.jmax);
         throw std::exception(message);
      }
      printf("\nEtalonnage spectral :\n");
      fprintf(hand_log, "\nEtalonnage spectral\n");

      // sauvegarde de l'image dans un tampon
      tampon = new PIC_TYPE[spectro.imax * spectro.jmax];
      memmove(tampon,lampBuffer->pic,spectro.imax*spectro.jmax*sizeof(PIC_TYPE)); 
      lineGapList.clear();
      
      for (int n=spectro.min_order;n<=spectro.max_order;n++) {
         if (ordre[n].flag==1) {
             std::valarray<PIC_TYPE> straightLineImage;

            // -----------------------------------------------------------
            // Extraction des ordres de l'image de la lampe spectrale
            // -----------------------------------------------------------  
            int width = ordre[n].max_x - ordre[n].min_x +1;            
            ::std::valarray<double> calibRawProfile(width);
            if (extract_order(lampBuffer,n,spectro.jmax, ordre, calibRawProfile, (char*)NULL, (::std::valarray<PIC_TYPE> *) &straightLineImage )) {
               throw std::exception("extract_order error");
            }
            // j'ajoute l'image 2D des raies redressées dans le fichier de sortie
            Fits_setStraightLineImage(pOutFits, n, straightLineImage , spectro.imax, straightLineImage.size()/spectro.imax);

            // j'ajoute le profil 1A dans le fichier de sortie
            Fits_setRawProfile(pOutFits, "P_1A_", n, calibRawProfile, ordre[n].min_x);

            // je restaure l'image
            memmove(lampBuffer->pic,tampon,spectro.imax*spectro.jmax*sizeof(PIC_TYPE));
            
            // ------------------------------------------------------------------------------
            // Division des profils de calibration par les profils "flat" (ordre après ordre)
            // ------------------------------------------------------------------------------
            std::valarray<double> flatRawProfile;
            if ( DEVIDE_FLAT ) {
               int flat_min_x;
               Fits_getRawProfile(pFlatFits, "P_1A_", n, flatRawProfile, &flat_min_x); 
               for(int i = 0; i < (int) flatRawProfile.size(); i++ ) {
                  if (flatRawProfile[i] !=0  ) {
                     calibRawProfile[i] /= flatRawProfile[i];
                  } else {
                     calibRawProfile[i] = 0;
                  }
               }
               // J'enregistre le profil 1A du flat dans le fichier de calibration 
               Fits_setRawProfile(pOutFits, "FLAT_1A_", n, flatRawProfile, flat_min_x);
            }
            // ------------------------------------------------------------------------------
            // calibration spectrale - calcul des coefficients des polynômes
            // ------------------------------------------------------------------------------            
            calib_spec(n,calibration_iteration,lambda_ref,ordre_ref,calibRawProfile,ordre,
               spectro.imax,spectro.jmax,neon_ref_x,check,spectro,lineList,lineGapList);
            printf("Ordre %d : a3=%.6e a2=%.6e a1=%.6e a0=%.6e rms=%.2e  nb raies=%d\n",
               n,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0,ordre[n].rms_calib_spec,ordre[n].nb_lines);
            fprintf(hand_log,"#%d\ta0=%e\ta1=%e\ta2=%e\ta3=%e\tRMS=%.4f\tnb=%d\n",
               n,ordre[n].a0,ordre[n].a1,ordre[n].a2,ordre[n].a3,ordre[n].rms_calib_spec,ordre[n].nb_lines);
            fflush(hand_log);

            // --------------------------------------------------------------------
            // Etalonnage spectral du spectre de  la lampe
            // au pas de 0,1 A/pixel (interpollation spline)
            // --------------------------------------------------------------------
            // je calcule le profil 1B du flat
            std::valarray<double> calibLinearProfile;
            double lambda1;
            make_interpol(calibRawProfile,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0, step, calibLinearProfile, &lambda1);   
            // j'enregistre le profil 1B de la calibration dans le fichier de calibration
            Fits_setLinearProfile(pOutFits, "P_1B_", n, calibLinearProfile, lambda1, step) ;

            // je calcule le profil 1B du flat
            if ( DEVIDE_FLAT ) {
               std::valarray<double> flatLinearProfile;
               make_interpol(flatRawProfile,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0, step, flatLinearProfile, &lambda1);
               // j'enregistre le profil 1B du flat dans le fichier de calibration
               Fits_setLinearProfile(pOutFits, "FLAT_1B_", n, flatLinearProfile, lambda1, step) ;
            }
         }
      }
      delete [] tampon;
      tampon = NULL;

      // j'ajoute le nom du fichier du Flat dans les mots clefs du fichier de calibration
      char * shortFileName = strrchr(flatName,'/');  // je cherche le dernier slash dans le nom du fichier
      if ( shortFileName == NULL ) {
         shortFileName = strrchr(flatName,'\\');  // je cherche le dernier antislash dans le nom du fichier
         if ( shortFileName == NULL ) {
            // je prends la valeur enière s'il n'y a pas d'antislash
            shortFileName = flatName;
         } else {
            // je pointe le caractere suivant l'antislash
            shortFileName++;
         }
      } else {
         // je pointe le caractere suivant le slash
         shortFileName++;
      }
      // j'ajoute le mot clef contenant le nom du fichier du Flat
      Fits_setKeyword(pOutFits,"PRIMARY","FLATNAME",shortFileName,"FLAT file name");

      // j'enregistre la table des ordres dans le fichier de calibration
      Fits_setOrders(pOutFits,&spectro, &processInfo, ordre, dx_ref);
      // j'enregistre la table des raies de calibration dans le fichier de calibration
      Fits_setLineGap(pOutFits,lineGapList);
      // j'enregistre les profils calibrés dans le fichier de calibration
      //for (int n=spectro.min_order;n<=spectro.max_order;n++) {
      //   if (ordre[n].flag==1) {
      //      Fits_setLinearProfile(pOutFits, n, calibLinearProfile[n], lambda1[n], step);
      //   }
      //}
      
      printf("\nResolution spectrale\n"); 
      fprintf(hand_log,"\nResolution spectrale\n"); 
      for (int n=spectro.min_order;n<=spectro.max_order;n++)  {
         if (ordre[n].flag==1) {
            printf("Ordre %d : fwhm=%.2f pixels   Dispersion=%.3f A/pixel   R=%.1f\n",n,ordre[n].fwhm,ordre[n].disp,ordre[n].central_lambda/(ordre[n].disp*ordre[n].fwhm));
            fprintf(hand_log,"#%d\tfwhm=%.2f\tDisp.=%.3f\tR=%.1f\n",n,ordre[n].fwhm,ordre[n].disp,ordre[n].central_lambda/(ordre[n].disp*ordre[n].fwhm));
         }
      }

      Fits_closeFits(pFlatFits);
      Fits_closeFits(pOutFits);
      freeImage(lampBuffer);
      fclose(hand_log);
      delete [] ordre;
   } catch( std::exception e ) {
      Fits_closeFits(pFlatFits);
      Fits_closeFits(pOutFits);
      if ( ordre != NULL) delete [] ordre;
      if ( tampon != NULL) delete tampon;
      if ( lampBuffer!= NULL) freeImage(lampBuffer);
      if ( hand_log != NULL) fclose(hand_log);
      throw e;
   } 

}

//----------------------------------------------------------------------------
// Eshel_processObject
//
// Traitement de l'image d'un objet    
//   contrôle que l'image de l'objet est de la meme taille que l'image de reference
//   Pour chaque ordre :
//     Extraction des ordres de l'image de l'objet
//     ajoute le profil dans le fichier de sortie
//     Divise de profils 1A par le profil du flat 
//     Etalonnage spectral du spectre de l'objet et re-échantillonnage au pas de 
//        step=0,1 A/pixel (interpollation spline)
//     Si la reponse instrumentale est fournie, divise le profil 1B par la reponse 
//        instrumentale et enregsitre les profils 1C
//   Si la reponse instrumentale est fournie, aboute les profil 1C et enregistre le profil P_1C_FULL
//      sinon aboute les profil 1B et enregistre le profil P_1B_FULL
//   enregistre la table des ordres dans le fichier de sortie
//
//  @param objectNameIn nom du fichier contenant l'image 2D de l'objet
//  @param objectNameOut nom du fichier en sortie
//  @param calibName     nom du fichier contant l'image et les paramètres de calibration.
//  @param responseFileName nom du fichier de la réponse instrumentale (si le nom est vide 
//                          le profil P_1C n'est pas calculé
//  @param recordObjectImage  option d'enregistrament de l'image 2D de l'objet. 0=ne pas enregistrer, 1=enregistrer
//  @param logFileName  nom du fichier trace
//  @param check        pointeur de la zone memoire contenant l'image check
//  @return void
// 

void Eshel_processObject(char *objectNameIn, char *objectNameOut, 
                char *calibName,      // nom du fichier de calibration
                char *responseFileName,   // nom du fichier de reponse instrumentale
                int  recordObjectImage,   //  option d'enregistrament de l'image 2D de l'objet
                char *logFileName, short *check)  
{

   INFOIMAGE *objectBuffer = NULL;
   CCfits::PFitsFile pInFits = NULL;
   CCfits::PFitsFile pCalibFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   CCfits::PFitsFile pResponseFits = NULL;
   FILE *hand_log = openLog(logFileName);
   char message[1024];
   PIC_TYPE * tampon = NULL;;
   ORDRE *ordre = NULL;
   INFOSPECTRO spectro;
   PROCESS_INFO processInfo;
   ::std::valarray<::std::valarray<double>> calibLinearProfile(MAX_ORDRE) ;
   ::std::valarray<double> responseProfile ;
   double lambda1[MAX_ORDRE]; 
   double responseLambda1; 
   double responseStep; 
   double step=0.1;
   double dx_ref = 0.0;

   
   try {
      // je lis les parametres du spectrographe et des traitements dans le fichier de calibration
      pCalibFits = Fits_openFits(calibName, false);
      Fits_getInfoSpectro(pCalibFits, &spectro);
      Fits_getProcessInfo(pCalibFits, &processInfo);

      // je lis les parametres des ordres dans le fichier de calibration
      PIC_TYPE nbOrder = spectro.max_order - spectro.min_order +1;
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pCalibFits, ordre, &dx_ref);

      // je lis la reponse instrumentale 
      if ( responseFileName != NULL ) {
         pResponseFits = Fits_openFits(responseFileName, false);
         Fits_getLinearProfile(pResponseFits,(char *) "PRIMARY", responseProfile,&responseLambda1,&responseStep);
         Fits_closeFits(pResponseFits);
         pResponseFits = NULL;
         if ( spectro.alpha > SEUIL_ALPHA ) {
            ////if ( responseStep != step ) {
            ////   sprintf(message,"Eshel_processObject: Instrumental response dispersion = %f . Must be %f", responseStep, step);
            ////   throw std::exception(message);
            ////}
            step =responseStep;
         } else {
            step =responseStep;
         }
      } else {
         responseProfile.resize(0);
         responseStep =step;
      }
 
      // je lis l'image stockee dans le PHDU du fichier d'entree 
      pInFits = Fits_openFits(objectNameIn, false); 
      Fits_getImage(pInFits, &objectBuffer);     

      // je contrôle que l'image de l'objet est de la meme taille que l'image de reference
      if (spectro.imax!=objectBuffer->imax || spectro.jmax!=objectBuffer->jmax) {
         sprintf(message,"La taille de l'image de la lampe %s (%d,%d) est de différente du flat %s (%d,%d)",
            objectNameIn, objectBuffer->imax , objectBuffer->jmax, calibName, spectro.imax, spectro.jmax);
         throw std::exception(message);
      }

      // je cree le fichier de sortie avec le permier HDU
      // je cree le fichier de sortie avec un profil vide dans le premier HDU
      ::std::valarray<double> emptyProfile ;
      emptyProfile.resize(1);
      emptyProfile[0] = 1;
      pOutFits = Fits_createFits(objectNameOut, emptyProfile, 0, step); 
      // je copie les mots dans le PHDU a partir de l'image pretraitee de l'objet
      Fits_setKeyword(pOutFits,pInFits);
      // je ferme l'image pretraitee de l'objet car il n'y en a plus beoin (cela libere la memoire) 
      Fits_closeFits(pInFits);

      // j'ajoute le mot cle contenant la version de la librairie
      setSoftwareVersionKeyword(pOutFits);
            
      // j'ajoute le mot clef FLATNAME contenant le nom du fichier Flat
      ::std::string fileName;
      Fits_getKeyword(pCalibFits,"PRIMARY","FLATNAME",fileName);
      Fits_setKeyword(pOutFits,"PRIMARY","FLATNAME",(char *)fileName.c_str(),"Flat file name");

      // j'ajoute le mot cle CALINAME contenant le nom du fichier de calibration 
      char * shortFileName = strrchr(calibName,'/');  // je cherche le dernier slash dans le nom du fichier
      if ( shortFileName == NULL ) {
         shortFileName = strrchr(calibName,'\\');  // je cherche le dernier antislash dans le nom du fichier
         if ( shortFileName == NULL ) {
            // je prends le nom entier s'il n'y a pas d'antislash
            shortFileName = calibName;
         } else {
            // je pointe le caractere suivant l'antislash
            shortFileName++;
         }
      } else {
         // je pointe le caractere suivant le slash
         shortFileName++;
      }
      Fits_setKeyword(pOutFits,"PRIMARY","CALINAME",shortFileName,"Calibration file name");


      // sauvegarde de l'image 2D pretraitee dans un tampon
      tampon = new PIC_TYPE[spectro.imax * spectro.jmax];
      memmove(tampon,objectBuffer->pic,spectro.imax*spectro.jmax*sizeof(PIC_TYPE)); 
      
      for (int n=spectro.min_order;n<=spectro.max_order;n++) {
         if (ordre[n].flag==1) {
            int width = ordre[n].max_x - ordre[n].min_x +1;
            ::std::valarray<double> objectProfile(width);
            ::std::valarray<double> object1CProfile(width);
            double lambda1C;

            // -----------------------------------------------------------
            // Extraction des ordres de l'image de l'objet
            // -----------------------------------------------------------      
            if (extract_order(objectBuffer,n,spectro.jmax, ordre, objectProfile, (char*)NULL, (::std::valarray<int> *) NULL)) {
               throw std::exception("extract_order error");
            }
            // j'ajoute le profil 1A dans le fichier de sortie
            Fits_setRawProfile(pOutFits, "P_1A_", n, objectProfile, ordre[n].min_x);

            // je restaure l'image
            memmove(objectBuffer->pic,tampon,spectro.imax*spectro.jmax*sizeof(PIC_TYPE));

            // -------------------------------------------
            // Divise de profils 1A par le profil du flat 
            // -------------------------------------------
            std::valarray<double> flatRawProfile;
            if ( DEVIDE_FLAT) {
               int flat_min_x;
               Fits_getRawProfile(pCalibFits, "FLAT_1A_", n, flatRawProfile, &flat_min_x); 
               for(unsigned i = 0; i < flatRawProfile.size(); i++ ) {
                  if (flatRawProfile[i] !=0  ) {
                     objectProfile[i] /= flatRawProfile[i];
                  } else {
                     objectProfile[i] = 0;
                  }
               }
            }

            // --------------------------------------------------------------------
            // Etalonnage spectral du spectre de l'objet et re-échantillonnage 
            // au pas de step=0,1 A/pixel (interpollation spline)
            // --------------------------------------------------------------------
            make_interpol(objectProfile,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0, step, calibLinearProfile[n], &lambda1[n]);            
            Fits_setLinearProfile(pOutFits, "P_1B_", n, calibLinearProfile[n], lambda1[n], step);

            // --------------------------------------------------------------------
            // je divise le profil 1B par la reponse instrumentale
            // --------------------------------------------------------------------
            if ( responseProfile.size() > 0 ) {
               divideResponse(calibLinearProfile[n], lambda1[n], responseProfile, responseLambda1, step, object1CProfile, &lambda1C);     
               if ( object1CProfile.size() > 0 ) {
                  Fits_setLinearProfile(pOutFits, "P_1C_", n, object1CProfile, lambda1C, step);
               }
            }
         }
      }
      delete tampon;
      tampon = NULL;

      if ( responseProfile.size() > 0  ) {
         // j'aboute les profils 1C
         abut1cOrder(spectro.max_order,spectro.min_order,pOutFits,"PRIMARY");
      } else {
         // j'aboute les profils 1B 
         abut1bOrder(spectro.max_order,spectro.min_order,pOutFits,pCalibFits,"PRIMARY");
      }      

      // j'enregistre la table des ordres dans le fichier de sortie
      Fits_setOrders(pOutFits,&spectro, &processInfo, ordre, dx_ref);

      // j'enregistre l'image 2D a la fin du fichier
      if ( recordObjectImage == 1 ) {
         Fits_setImage(pOutFits, objectBuffer);
      } 
      
      Fits_closeFits(pOutFits);
      Fits_closeFits(pCalibFits);
      delete [] ordre;
      freeImage(objectBuffer);
      fclose(hand_log);
   } catch (std::exception &e) {
      if ( tampon != NULL) delete [] tampon;
      Fits_closeFits(pInFits);
      Fits_closeFits(pOutFits);
      Fits_closeFits(pCalibFits);
      Fits_closeFits(pResponseFits);
      if ( ordre != NULL) delete ordre;
      if ( objectBuffer!= NULL) freeImage(objectBuffer);
      if ( hand_log != NULL) fclose(hand_log);
      throw e;
   }
}


////////////////////////////////////////////
////////////////////////////////////////////
// joinSpectra : aboutement des spectres  //
////////////////////////////////////////////
////////////////////////////////////////////
/*
void Eshel_joinSpectra(char *nom_objet_fits, char *nom_calib_fits,
                char *nom_objet_full0_fits, char *nom_objet_full_fits,
                int min_order, int max_order,
                int useFlat,
                short *check)  
{
   if (useFlat==0) {
      aboute_spectres(max_order,min_order,nom_objet_fits,"",nom_objet_full0_fits,useFlat);
   } else {
      aboute_spectres(max_order,min_order,nom_objet_fits,nom_calib_fits,nom_objet_full0_fits,useFlat);
   }
   
   // -----------------------------------------------------------------------------------
   // Corrige la température de couleur de la lampe ayant servie à prendre le flat-field
   // -----------------------------------------------------------------------------------
   planck_correct(nom_objet_fits,nom_objet_full_fits,2800.0);
}
*/

// ---------------------------------------------------
// Eshel_freeData
//    supprime un bloc de donnees de la memoire
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_freeData(void *values) 
{
   if ( values != NULL) {
      free(values);
   }
}


// ---------------------------------------------------
// Eshel_getRawProfile
//    retourne les valeurs d'un profil brut (non calibre)
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getRawProfile(char *fileName, int numOrder, double **values, int *min_x, int *size)  {
   CCfits::PFitsFile pFits = NULL;
   ::std::valarray<double> rawProfile;

   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getRawProfile(pFits, "P_1A_", numOrder, rawProfile, min_x);
      *values = new double[rawProfile.size()];
      // je copie le valarray dans l'aarray
      for (size_t i=0; i<rawProfile.size(); i++) {
         (*values)[i] = rawProfile[i];
      }
      *size = rawProfile.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      Fits_closeFits(pFits);
      throw e;
   }

}

// ---------------------------------------------------
// Eshel_getLinearProfile
//    retourne les valeurs d'un profil calibré lineairement
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getLinearProfile(char *fileName, int order, double **values, double *lambda1, double *step, int *size) 
{
   CCfits::PFitsFile pFits = NULL;
   ::std::valarray<double> linearProfile;
   try {
      pFits = Fits_openFits(fileName, false);
      Fits_getLinearProfile(pFits, "P_1B_", order, linearProfile,lambda1,step);
      *values = new double[linearProfile.size()];
      for (size_t i=0; i<linearProfile.size(); i++) {
         (*values)[i] = linearProfile[i];
      }
      *size = linearProfile.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getProfile
//    retourne les valeurs d'un profil echantillone lineairement
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getProfile(char *fileName, char * hduName, double **values, double *lambda1, double *step, int *size) 
{
   CCfits::PFitsFile pFits = NULL;
   ::std::valarray<double> linearProfile;
   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getFullProfile(pFits, hduName, linearProfile,lambda1,step);
      *values = new double[linearProfile.size()];
      for (size_t i=0; i<linearProfile.size(); i++) {
         (*values)[i] = linearProfile[i];
      }
      *size = linearProfile.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getLineGap
//    retourne les ecarts
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getLineGap(char *fileName, LINE_GAP **lineGap, int *size) 
{
   CCfits::PFitsFile pFits = NULL;
   ::std::list<LINE_GAP> lineGapList;
   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getLineGap(pFits, lineGapList);
      *lineGap = new LINE_GAP[lineGapList.size()];
      int i = 0; 
      for(::std::list<LINE_GAP>::iterator iter  = lineGapList.begin() ; iter != lineGapList.end(); ++iter ) {
         (*lineGap)[i].order = iter->order;
         (*lineGap)[i].l_obs = iter->l_obs;
         (*lineGap)[i].l_calc = iter->l_calc;
         (*lineGap)[i].l_diff = iter->l_diff;
         (*lineGap)[i].l_posx = iter->l_posx;
         (*lineGap)[i].valid = iter->valid;
         i++;
      }
      *size = lineGapList.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getOrderTable
//    retourne la table des ordres
//    et l'abscisse de l'odre de reference
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getOrderTable(char *fileName, ORDRE **pOrders, double *pdx_ref) 
{
   CCfits::PFitsFile pFits = NULL;
   *pOrders = NULL;
   try {
      *pOrders = new ORDRE[MAX_ORDRE];
      memset(*pOrders,0,MAX_ORDRE*sizeof(ORDRE));
      pFits = Fits_openFits(fileName, false);   
      Fits_getOrders(pFits, *pOrders, pdx_ref);
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (*pOrders != NULL) delete [] (*pOrders );
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getInfoSpectro
//   retourne les parametre du spectro contenu dans un fichier FITS
//   dans une structure INFOSPECTRO
// Parameters 
//   fileName : nom complet du fichier FITS
//   InfoSpectro : pointeur sur une structure INFOSPECTRO dejo alloue par le programme appelant
// Return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getInfoSpectro(char *fileName, INFOSPECTRO *pInfoSpectro) 
{
   CCfits::PFitsFile pFits = NULL;
  try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getInfoSpectro(pFits, pInfoSpectro);
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}




//=====================================================
//  Fin des fonctions principales de la DLL
//=====================================================

/*
#include <windows.h>
#include <stdio.h>
#include <stdlib.h> 

#define __BROWSEDLL__ 

#ifndef __BROWSE_LIBRARY__
#define __BROWSE_LIBRARY__
// Evite la création du fichier .DEF
#ifdef __BROWSEDLL__
#define DLLPREFIX __declspec (dllexport)
#else
#define DLLPREFIX __declspec (dllimport)
#endif

 extern "C" {

 enum BL_ERRORS
 {
 BLE_NO_ERROR = 0, //pas d'erreur
 BLE_INVALIDE_DLL_VERSION, // renvoyé lors de la recherche des versions de dlls si aucune version n'est trouvée
 } ;

 typedef struct BROWSEDATA
 {
 VS_FIXEDFILEINFO m_tFileVersion; // version de la ddl (NULL si aucune version)
 char m_acCompanyName[_MAX_PATH]; // toutes les infos sur les dlls : )
 char m_acFileDescription[_MAX_PATH];
 char m_acFileVersion[_MAX_PATH];
 char m_acInternalName[_MAX_PATH];
 char m_acLegalCopyright[_MAX_PATH];
 char m_acOriginalFilename[_MAX_PATH];
 char m_acProductName[_MAX_PATH];
 char m_acProductVersion [_MAX_PATH];
 } BROWSEDATA ;

 DLLPREFIX BL_ERRORS GetDLLVersion
 (
 char* p_pcDllName, // chemin de la dll (path + name)
 VS_FIXEDFILEINFO* p_ptVerInfo, // pointeur sur un type VS_FIXEDFILEINFO (celui de la structure BROWSEDATA pour le garder si on veut
 BROWSEDATA* p_bdDataArray // pointeur sur la strcture qui va recevoir les infos sous forme de char
 );

 } // End extern "C" 

#endif


 // ne pas oublier de rajouter version.lib dans les liens des Settings du projet pour avoir les != fonctions qui vont bien ; )
 DLLPREFIX BL_ERRORS GetDLLVersion
 (
 char* p_pcDllName,
 VS_FIXEDFILEINFO* p_ptVerInfo,
 BROWSEDATA* p_bdDataArray
 )
 {
 // variables pour la version de la dll
 BL_ERRORS l_ErrCode = BLE_NO_ERROR;
 DWORD l_dwVerInfoSize; // Taille de la version.
 DWORD l_dwVerHnd; // Non utilisé.
 // (1) Vérifier si le buffer de réception a été alloué.
 if (p_pcDllName!= NULL)
 {
 l_dwVerInfoSize = GetFileVersionInfoSize(p_pcDllName, &l_dwVerHnd);
 if (l_dwVerInfoSize > 0)
 {
 unsigned char* l_pucVersionBlock ;

 //Allocate memory space for version block
 l_pucVersionBlock = new unsigned char [l_dwVerInfoSize];
 if (l_pucVersionBlock != NULL)
 {
 if (GetFileVersionInfo(p_pcDllName, NULL, l_dwVerInfoSize, (LPVOID) l_pucVersionBlock) > 0 ) // on commence à récupérer les infos dans l_dwVerInfoSize. Si >0, c'est OK
 {
 VS_FIXEDFILEINFO *l_ptVerInfo ;
 BOOL l_bRetCode ;
 unsigned int l_uiVersionLen ;

 l_bRetCode = VerQueryValue (l_pucVersionBlock, "\\", (LPVOID *)&l_ptVerInfo, &l_uiVersionLen); //on récupère encore des infos par VerQueryValue
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }
 else
 {
 memcpy (p_ptVerInfo, l_ptVerInfo, sizeof (VS_FIXEDFILEINFO ));
 // et on copie toutes les infos sur la dll dans la structure
 WORD *l_pwVerInfo ;
 BOOL l_bRetCode ;
 unsigned int l_uiVersionLen ;

 //on récupère les infos de langues et de version (voir msdn sur VerQueryValue)
 l_bRetCode = VerQueryValue (l_pucVersionBlock, "\\VarFileInfo\\Translation", (LPVOID *)&l_pwVerInfo, &l_uiVersionLen);
 if (l_bRetCode && (l_uiVersionLen > 0) && l_ptVerInfo != NULL)
 {
 char* l_pcDllInfos;
 char l_cStartString[30];
 char l_pulLangageRef[50];

 // on concatène les infos langues sous forme de 2 chaines char en hexa
 sprintf(l_cStartString, "\\StringFileInfo\\%04x%04x\\", l_pwVerInfo[0], l_pwVerInfo[1]);

 // on commence par le nom de la compagnie
 sprintf(l_pulLangageRef, "%sCompanyName", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acCompanyName, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on continue par la description du fichier
 sprintf(l_pulLangageRef, "%sFileDescription", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acFileDescription, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on commence par la version du fichier
 sprintf(l_pulLangageRef, "%sFileVersion", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acFileVersion, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on commence par le nom nom interne du produit
 sprintf(l_pulLangageRef, "%sInternalName", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acInternalName, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on commence par le copyright
 sprintf(l_pulLangageRef, "%sLegalCopyright", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acLegalCopyright, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on commence par le nom d'origine
 sprintf(l_pulLangageRef, "%sOriginalFilename", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acOriginalFilename, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on commence par le nom de produit
 sprintf(l_pulLangageRef, "%sProductName", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acProductName, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 // on termine par la version du produit
 sprintf(l_pulLangageRef, "%sProductVersion", l_cStartString);
 l_bRetCode = VerQueryValue (l_pucVersionBlock, l_pulLangageRef, (LPVOID *)&l_pcDllInfos, &l_uiVersionLen);
 strncpy(p_bdDataArray->m_acProductVersion, l_pcDllInfos, l_uiVersionLen);
 if (!( l_bRetCode && (l_uiVersionLen > 0) && (l_ptVerInfo != NULL)))
 {
 return l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }

 }//end if (l_bRetCode && (l_uiVersionLen > 0) && l_ptVerInfo != NULL) deuxieme niveau

 else // si il ne trouve pas de langage set (ie, pas de champs renseignés pour cette dll
 l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }//end if (l_bRetCode && (l_uiVersionLen > 0) && l_ptVerInfo != NULL) premier niveau

 }// end if GetFileVersionInfo
 } // if l_puc
 }// if l_dwVer
 else
 l_ErrCode = BLE_INVALIDE_DLL_VERSION;
 }// if p_pcVersion

 return l_ErrCode;
 } 
 */



/********************************* CALIB_SPEC2 *********************************/
/* Calibration spectrale de l'ordre n (calcul des polynomes de dispersion)    */
/* La position approximative des raies est calculée avec la formule du réseau */
/* V1.4 -> retourne le nombre de raies retenues + nombre itération            */
/******************************************************************************/
void calib_spec2(int n,int nb_iter, std::valarray<double> &calibRawProfile, ORDRE *ordre,
                INFOSPECTRO spectro,::std::list<double> &lineList, ::std::list<LINE_GAP> &lineGapList, 
                int *nbLine, int *nbLineOk, double *rmsOut, double *dispersion)
{

   double coef = 1.5;          // coefficient de réjection du sigma-clipping
   double position[MAX_LINES];
   double table_lambda[MAX_LINES];
   double delta_lambda[MAX_LINES];
   double table_fwhm[MAX_LINES];
   int    table_flag[MAX_LINES];
   double w[MAX_LINES];
   double a[5]; 
   double rms = 0;
   double fwhm = 0.0;
   int ww=ordre[n].wide_x;  // largeur de la zone de recherche d'une raie (en pixels)

   double lambda;
   double alpha=spectro.alpha;
   double gamma=spectro.gamma;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;

   try {
      memset(position,0,MAX_LINES*sizeof(double));
      memset(table_lambda,0,MAX_LINES*sizeof(double));
      memset(delta_lambda,0,MAX_LINES*sizeof(double));
      memset(table_flag,0,MAX_LINES*sizeof(int));
      memset(table_lambda,0,MAX_LINES*sizeof(double));
      memset(table_fwhm,0,MAX_LINES*sizeof(double));
      memset(w,0,MAX_LINES*sizeof(double));

      double psf_posx;
      int pos2;
      double dx=0;
      double px;
      int calib_degre = 3;

      // Calcul de l'écart (dx) entre la position fourni et la position mesurée de 
      // la raie du thorium à 6584 A
      //predic_pos(lambda_ref,ordre_ref,(double)neon_ref_x,imax,ordre,&dx,spectro);      

      /*
      px=compute_pos((double)n,6563,dx,spectro.imax,spectro);
      if ((int)px<(ordre[n].min_x+(ww/2+1)+5) || (int)px>(ordre[n].max_x-(ww/2+1)-5)) {
            *nbLine = 0;
            *nbLineOk = 2;
            *rmsOut = 1;
            *dispersion = 1;
         return;
      }*/

      int nb=0;
      int kk=0;
      int kk2=0;
      double rms2 = 0;
      for (int ni=0;ni<nb_iter;ni++) {
         double coef=1.0;
         double sfwhm=0.0;
         double calc;
         nb=0;
         kk = 0;
         kk2 = 0;
         rms2 = 0;
         


         ::std::list<double>::iterator iter;
         for (iter=lineList.begin(); iter != lineList.end(); ++iter) 
         {
            table_flag[nb] = -1;
            lambda = *iter;
            px=compute_pos((double)n,lambda,dx,spectro.imax,spectro);
            // On vérifie que la position tombe dans l'intervalle spécifié
            // TODO : remplacer 5 par param.bordure
            if ( !_isnan(px) && (int)px>(ordre[n].min_x+(ww/2+1)+5) && (int)px<(ordre[n].max_x-(ww/2+1)-5)) 
            {
               kk2++;
               pos2=(int)px-ordre[n].min_x;
               int pos = 0;
               line_pos_approx(pos2,ww,calibRawProfile,&pos);
               double ecartType;
               if ( spec_gauss(pos,9,calibRawProfile,&psf_posx,&fwhm, &ecartType) == 0 ) { // ajustement gaussien  
                  if ( fwhm > 1 && ecartType > 50 ) {
                  if (ni!=0 && kk >2) { // sigma-clipping au-delà de la première itération
                     calc = 0;
                     for (int index = 0; index <= calib_degre; index++) {
                        calc = calc + a[index] * pow(psf_posx, (double)index);     
                     }
                     double lambda_estime =  calc;

                     if (fabs(lambda-lambda_estime) < coef*rms) { // sigma-clipping
                        sfwhm=sfwhm+fwhm; 
                        table_lambda[kk]=lambda;
                        position[kk]=psf_posx;
                        w[kk]=1.0;

                        double lambda_calcule = compute_px2lambda(position[kk] + (double)ordre[n].min_x, n, dx, spectro);
                        delta_lambda[kk] = table_lambda[kk] - lambda_calcule; // écart entre lambda_effectif et lambda calculé à partir de la position observée
                        rms2 += ecartType * 1/sqrt(px-psf_posx);
                        table_fwhm[kk] =  1/(px-psf_posx);
                        // je memorise le numero de la raie reconnue
                        table_flag[nb] = kk;
                        kk++;  
                        if (kk > MAX_LINES) {
                           kk--;
                           break;
                        }                        
                     }                           
                  } 
                  else {   // première itération                  
                     sfwhm=sfwhm+fwhm; 
                     table_lambda[kk]=lambda;
                     position[kk]=psf_posx;
                     w[kk]=1.0; 

                     double lambda_calcule = compute_px2lambda(position[kk] + (double)ordre[n].min_x, n, dx, spectro);
                     delta_lambda[kk] = table_lambda[kk] - lambda_calcule; // écart entre lambda_effectif et lambda calculé à partir de la position observée
                     rms2 += ecartType * 1/sqrt(px-psf_posx);
                     table_fwhm[kk] =  1/(px-psf_posx);
                     // je memorise le numero de la raie reconnue
                     table_flag[nb] = kk;
                     kk++;
                     if (kk > 500) {
                        kk--;
                        break;
                     }   
                  }
               }             
               }
            } else {
               // cette raie n'est pas dans le spectre
               table_flag[nb] = -1;
            }
            nb++;
         }

         if ( kk < 2 ) {
            *nbLine = kk2;
            *nbLineOk = kk;
            *rmsOut = 0;
            *dispersion = 0;
            return;
         }
         // on ajuste le polynome
         for (int index = 0; index <= calib_degre; index++) a[index] = 0.0;
         if (kk<=2) {
            // on ajuste ordre 1
            fitPoly(kk,1,position,table_lambda,w,a,&rms);
         } else if (kk==3){
            // on ajuste ordre 2
            fitPoly(kk,2,position,table_lambda,w,a,&rms); 
         } else {
            // on ajuste ordre 3 ou plus
            fitPoly(kk,calib_degre,position,table_lambda,w,a,&rms); 
         }

         // je copie le polynome 
         ordre[n].a3=a[3];
         ordre[n].a2=a[2];
         ordre[n].a1=a[1];
         ordre[n].a0=a[0];
         ordre[n].rms_calib_spec=rms;
         ordre[n].fwhm=sfwhm/(double)kk;

      }  // fin for nb_iter

      *nbLine = kk2;
      *nbLineOk = kk;
      //*rmsOut = rms;      
      *rmsOut = rms2*kk;
      
      //if  (kk < 2 || kk != kk2) {
      if  (kk < 2 ) {
         return;
      }
      // on reboucle sur la liste des raies pour trouver les O-C, et production d'un fichier oc_xxx (un par ordre)
      
      // on reboucle sur la liste des raies pour trouver les O-C, et production d'un fichier oc_xxx (un par ordre)
      for (int i=0;i<kk;i++)
      {
         LINE_GAP lineGap;
         lineGap.order  = n;
         lineGap.valid  = 1;
         lineGap.l_obs  = table_lambda[i];
      
         double calc = 0.0;
         for (int index = 0; index <= calib_degre; index++) {
            calc = calc + a[index] * pow(position[i], (double)index);
         }
         lineGap.l_calc = calc;
         lineGap.l_diff = table_lambda[i] - calc;
         lineGap.l_diff = table_fwhm[i];;
         lineGap.l_posx = position[i]+(double)ordre[n].min_x;
         
         int degre = 4; 
         double y=0.0;
         for (int k=0;k<=degre;k++) {
            y=y+ordre[n].poly_order[k]*pow(lineGap.l_posx,(double)k);
         }
         lineGap.l_posy = y;
         lineGapList.push_back(lineGap);
      }
      // on calcule la dispersion moyenne (on ajuste ordre 1)
      fitPoly(kk,1,position,table_lambda,w,a,&rms); 
      ordre[n].disp=a[1];
      *dispersion = a[1];
      // je calcule la resilution
      ordre[n].resolution = ordre[n].central_lambda/(ordre[n].disp*ordre[n].fwhm);
      // je stocke le nombre de raies reconnues
      ordre[n].nb_lines=kk;  // nouveauté v1.4
   } catch (...) {
      // rien a desallouer
      throw;
   } 


}

////////////////////////////////////////
////////////////////////////////////////
// Eshel_findSpectroParametres       //
////////////////////////////////////////
////////////////////////////////////////
void Eshel_findSpectroParameters(char *calibFileName, char *flatFileName, ::std::list<double> &lineList) {
   INFOIMAGE *lampBuffer = NULL;
   CCfits::PFitsFile pFlatFits = NULL;
   FILE *hand_log = openLog("find.log");
   char message[1024];
   PIC_TYPE * tampon = NULL;;
   ORDRE *ordre = NULL;
   INFOSPECTRO spectro;
   PROCESS_INFO processInfo;
   CCfits::PFitsFile pOutFits = NULL;
   ::std::list<LINE_GAP> lineGapList;
   double step=0.1;
   double dx_ref= 0.0;

   try {
      // je lis les parametres spectro 
      pFlatFits = Fits_openFits(flatFileName, false);
      Fits_getInfoSpectro(pFlatFits, &spectro);
      //je complete les informations du traitement
      Fits_getProcessInfo(pFlatFits, &processInfo);
      processInfo.calibrationIteration = 3;

      // je lis la table des ordres
      int nbOrder = spectro.max_order - spectro.min_order +1;
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pFlatFits, ordre, &dx_ref);

      // je cree le fichier de la lampe de calibration
      pOutFits = Fits_openFits(calibFileName, false); 
      Fits_getImage(pOutFits, &lampBuffer);

      // je contrôle que l'image de la lampe est de la meme taille que l'image de reference
      if (spectro.imax!=lampBuffer->imax || spectro.jmax!=lampBuffer->jmax) {
         sprintf(message,"La taille de l'image de la lampe %s (%d,%d) est de différente du flat %s (%d,%d)",
            calibFileName, lampBuffer->imax , lampBuffer->jmax, flatFileName, spectro.imax, spectro.jmax);
         throw std::exception(message);
      }

      // -----------------------------------------------------------
      // Extraction des ordres de l'image de la lampe spectrale
      // ----------------------------------------------------------- 
      int ordreNum = 1;
      int width = ordre[ordreNum].max_x - ordre[ordreNum].min_x +1;            
      ::std::valarray<double> calibRawProfile(width);
      std::valarray<PIC_TYPE> straightLineImage;
      if (extract_order(lampBuffer,ordreNum,spectro.jmax, ordre, calibRawProfile, (char*)NULL, (::std::valarray<PIC_TYPE> *) &straightLineImage )) {
         throw std::exception("extract_order error");
      }
            
      fprintf(hand_log,"===========================================\n");
      fprintf(hand_log,"alpha\t lambdac\t nbLine \t nbLineOk \t rms\t dispersion \n");
      double rms_max =0;
      double alpha_max =0;
      double lambdac_max=0;

      for (double alpha = 20  ; alpha < 59 ; alpha+=0.01 ) {
         int nbLine;
         int nbLineOk; 
         double dispersion = 0;
         double rms = 0; 
         spectro.alpha = alpha;
         lineGapList.clear();
         calib_spec2(ordreNum, processInfo.calibrationIteration, calibRawProfile, ordre,
            spectro, lineList, lineGapList, &nbLine, &nbLineOk, &rms, &dispersion);
         double dx =0;
         double lambdac = get_central_wave(spectro.imax,(double)spectro.imax/2.0,dx,ordreNum,spectro);
         if ( nbLineOk >= 2 && rms >0 && dispersion > 0 ) {
            fprintf(hand_log,"%5.2f\t%8.2f\t%6d\t%6d\t%17.1f",
               alpha,lambdac, nbLine, nbLineOk, rms);

            ::std::list<LINE_GAP>::iterator iter;
            for (iter=lineGapList.begin(); iter != lineGapList.end(); ++iter) 
            {
               LINE_GAP lineGap = *iter;
               fprintf(hand_log," | \t%8.2f\t%8.6f\t%8.6f",
                  lineGap.l_obs,lineGap.l_posx,lineGap.l_diff);
            }
            
            fprintf(hand_log,"\n");
            if (rms > rms_max) {
               rms_max = rms;
               alpha_max= alpha;
               lambdac_max = lambdac;
            }
             
            fflush(hand_log);
         }


      }
      fprintf(hand_log,"=== Resultat : alpha= %5.2f lambdac=%8.2f\n",
         alpha_max,lambdac_max);

      Fits_closeFits(pFlatFits);
      Fits_closeFits(pOutFits);
      freeImage(lampBuffer);
      fclose(hand_log);
      delete [] ordre;
   } catch( std::exception e ) {
      Fits_closeFits(pFlatFits);
      Fits_closeFits(pOutFits);
      if ( ordre != NULL) delete [] ordre;
      if ( tampon != NULL) delete tampon;
      if ( lampBuffer!= NULL) freeImage(lampBuffer);
      if ( hand_log != NULL) fclose(hand_log);
      throw e;
   } 


}



