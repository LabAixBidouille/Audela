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



// definition des constantes et de macros
#define SGN(x) (x>=0?1:-1)
#define PI M_PI    // j'utilise la valeur de M_PI declaree dans math.h
#define SEUIL_ALPHA 0  // seuil de l'angle ALPHA pour distinguer les spectro echelle (alpha > 60 )

// fonctions locales
FILE * openLog(char *fileName);


/** 
 * setSoftwareVersionKeyword
 *  ajoute le mot cle 
 */

void setSoftwareVersionKeyword( CCfits::PFitsFile pFits ) {
   char value[70];

   sprintf(value,"libsehel-%s", LIBESHEL_VERSION);
   Fits_setKeyword(pFits,"PRIMARY","SWCREATE",value,"Processing software");
}




// ---------------------------------------------------
// extractOrders
//    retourne les parametres d'un ordre
// Parameter:
//    fileName
//    orderValue
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
/*void extractOrders(char *fileName, ORDRE *orderValue )  {
   CCfits::PFitsFile pFits = NULL;

   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getOrders(pFits, orderValue);
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      Fits_closeFits(pFits);
      throw e;
   }

}

*/

// ---------------------------------------------------
// Cr�ation d'un fichier texte de trace
// ---------------------------------------------------
FILE * openLog(char *fileName) {
   FILE * hand_log;
   if ((hand_log=fopen("reduc.log","a+t"))==NULL) 
      {
 	   printf("Probl�me d'ouverture en ecriture du fichier %s",fileName);
 	   return NULL;
      }
   return hand_log;
}

/*************************** divideResponse ****************************
 * divise un profils par la reponse instrumenale          
 *
 */
void divideResponse(std::valarray<double> &profile1b, double lambda1b, std::valarray<double> &responseProfile, double responseLambda, double step,std::valarray<double> &profile1c, double *lambda1c) {
   double lambdaMin;
   double lambdaMax;

   if ( lambda1b <  responseLambda ) {
      lambdaMin = responseLambda;
   } else {
      lambdaMin = lambda1b;
   }
   *lambda1c = lambdaMin;

   double lambda1bMax = (profile1b.size() -1 ) *step + lambda1b;
   double responseLambdaMax = (responseProfile.size() -1 ) *step + responseLambda;
   if ( lambda1bMax <  responseLambdaMax ) {
      lambdaMax = lambda1bMax;
   } else {
      lambdaMax = responseLambdaMax;
   }
   
   // je ne fais pas la division si le profil 1B et la courbe de reponse n'ont pas de plage commune
   if (lambdaMin > lambdaMax ) {
      profile1c.resize(0);
      return;
   }
   // je calcule le nombre d'echantillons 
   int size = (int) ((lambdaMax - lambdaMin) /step) +1;
   profile1c.resize(size);

   int x1b   = (int) ((lambdaMin - lambda1b)/ step)  ;  
   int xResp = (int) ((lambdaMin - responseLambda)/ step)  ;  
   int x1c   = 0;

   for(x1c = 0 ; x1c <size; x1c++) {
      if (responseProfile[xResp] != 0) {
         profile1c[x1c] = profile1b[x1b] /responseProfile[xResp];
      } else {
         profile1c[x1c] = 0;
      }
      x1b++;
      xResp++;
   }


}


/*************************** FIND_Y_POS ****************************/
/* Recherche de la coordonn�e Y de tous les ordres dont le         */
/* niveau est sup�rieur � seuil.                                   */
/* L'ordre de rang ordre0 est mesur� approximativement � la        */
/* coordonn�e y0 dans l'image d'entr�e.                            */
/* On rempli la structure ordre et on retourne le nombre           */
/* d'ordre trouv� (nb_ordre).                                      */
/* Le point central des ordres est marqu�e par un carr� dans       */
/* l'image de v�rification (check)                                 */
/* Modif V1.6 -> nom de variable wide_y remplac� par step_y        */
/*  retourne une exception conteant le message d'erreur            */
/*******************************************************************/
void find_y_pos(INFOIMAGE *buffer,short *check, int imax,int jmax,int y0,
               int ordre0,int step_y,int seuil,ORDRE *ordre,
               int *nb_ordre,int min_order,int max_order,FILE *hand_log)
{
   int y,yy,n,max,py;
   int x=imax/2;
   int v1,v2,sv1,sv2;
   double pos_y;
   PIC_TYPE *buf = NULL;
   PIC_TYPE *p;
   int delta=1;
   double last_pos_y=0.0;

   p=buffer->pic;

   try {
      // ----------------------------------------------------------
      // tampon image interm�diaire 
      // ----------------------------------------------------------
      if ((buf=(PIC_TYPE *)calloc(imax*jmax,sizeof(PIC_TYPE)))==NULL)
      {
         throw ::std::exception("find_y_pos: Not enougth memory for buf"); 
      }

      // -----------------------------------------------------------
      // on sauvegarde l'image
      // -----------------------------------------------------------
      memmove(buf,p,sizeof(PIC_TYPE)*imax*jmax);

      y0=y0-1;     // on passe en coordonn�es m�moire - origine (0,0)

      // ---------------------------------------------------------
      // gradient vertical de l'image
      // ---------------------------------------------------------
      if (gauss_convol(buffer,2.0)) // on filtre un peu le bruit       
      {
         throw ::std::exception("find_y_pos: gauss_convol error"); 
      }
      // Modif V1.6  : remplace grady par grad2
      //grady(buffer,1);   
      grady2(buffer,1);                       // gradient -> nouvelle version V1.6
      p=buffer->pic;

      // --------------------------------------------------------------
      // Recherche des ordres croissants 
      // Premi�re passe pour trouver la position Y de l'ordre ordre0
      // --------------------------------------------------------------
      n=0;
      double ecart=1e10;
      int rang=0;
      for (y=jmax-3;y>3;y--)
      {
         v1=(int)p[x+(y+delta)*imax];
         v2=(int)p[x+(y-delta)*imax];
         sv1=SGN(v1);
         sv2=SGN(v2);

         if (sv1!=sv2) {
            if (abs(v1-v2)>seuil) {
               max=abs(v1-v2);
               py=y;
               for (yy=0;yy<6;yy++) { // on cherche le max du gradient (�cart max entre v1 et v2)
               
                  v1=(int)p[x+(y-yy+delta)*imax];
                  v2=(int)p[x+(y-yy-delta)*imax];
                  if (abs(v1-v2)>max) py=y-yy;            
               }
               n++;

               int cdgResult = calc_cdg_y(buf,imax,jmax,imax/2,py-step_y/2,py+step_y/2,&pos_y); // centre de gravite suivant Y
               if ( cdgResult == 0 ) {
                  if (fabs(pos_y-(double)y0)<ecart) {
                     ecart=fabs(pos_y-(double)y0);
                     rang=n; 
                  }

                  if (fabs(last_pos_y-pos_y)<(double)step_y-1.0) {
                     char message[1024];
                     sprintf(message, "find_y_pos: Y order position detection aborted. Parameters: last_n=%d last_pos_y=%f pos_y=%f step_y=%d seuil=%d . Seuil may be too low",
                        n,last_pos_y,pos_y,step_y,seuil);
                     throw ::std::exception(message); 
                  }
                  last_pos_y=pos_y;
               } else {
                  // pas d'ordre trouv�
               }


               y=y-step_y;
            }
         }
      }

      fprintf(hand_log,"Nombre d'ordres trouve : %d\n\n",n);

      *nb_ordre=n;

      // ---------------------------------------------------------------------------------
      // Recherche des ordres croissants 
      // Deuxi�me passe - on associe le num�ro de l'ordre et la position Y correspondante
      // ---------------------------------------------------------------------------------
      n=ordre0-rang;
      for (y=jmax-3;y>3;y--)
      {
         v1=(int)p[x+(y+delta)*imax];
         v2=(int)p[x+(y-delta)*imax];
         sv1=SGN(v1);
         sv2=SGN(v2);

         if (sv1!=sv2)
         {
            if (abs(v1-v2)>seuil)
            {
               max=abs(v1-v2);
               py=y;

               for (yy=0;yy<6;yy++) // on cherche le max du gradiant (�cart max entre v1 et v2)
               {
                  v1=(int)p[x+(y-yy+delta)*imax];
                  v2=(int)p[x+(y-yy-delta)*imax];
                  //if (fabs((double)v1-v2)>max) py=y-yy;            
                  if (abs(v1-v2)>max) {
                     py=y-yy;            
                  }
               }

               n++;
               calc_cdg_y(buf,imax,jmax,imax/2,py-step_y/2,py+step_y/2,&pos_y);
               ordre[n].flag=1;         
               ordre[n].yc=pos_y;  // coordonn�es m�moire (0,0)
               y=y-step_y;
            }
         }
      }
      memmove(p,buf,sizeof(PIC_TYPE)*imax*jmax);

      free(buf);

   } catch (std::exception e) {
      free(buf);
      throw e;
   }
}

/****************************** FIND_MAX ***********************************/
/* Retourne les coordonn�es pixel (x,y) du point de plus grande intensit�  */
/* dans l'image - utilis� pour trouver automatiquement la position         */ 
/* de la raie � 5852 A du n�on.                                            */
/***************************************************************************/
int find_max(INFOIMAGE *buffer, int *x,int *y)
{
int i,j,imax,jmax;
PIC_TYPE max;
int px,py;
PIC_TYPE *p;

if (buffer->pic==NULL) return 1;

p=buffer->pic;
imax=buffer->imax;
jmax=buffer->jmax;

max=-32000;

for (j=0;j<jmax;j++)
   {
   for (i=0;i<imax;i++)
      {
      if (p[i+j*imax]>max)
         {
         px=i;
         py=j;
         max=p[i+j*imax]; 
         }
      }
   }

*x=px+1;  // on est en coordonn�es image (origine 1,1)
*y=py+1;
return 0;
}

/******************** GAUSS_CONVOL *********************/
/* Convolution par une fonction gaussienne             */
/*******************************************************/
int gauss_convol(INFOIMAGE *buffer, double sigma)
{
int i,j,k,imax,jmax;
int i1,j1;
double val;
double somme;
int largeur,largeur2;
double filtre[130];
double reste,ilarg;
int longueur,adr,adr2;
PIC_TYPE *p;
double *buf;

if (buffer->pic==NULL) return 1;
 
if (sigma<=0.0) return 0; // on ne convolu pas !

if (sigma>25.0) sigma=25.0; 

largeur=(int)(5.0*sigma+1.0);
if (largeur<3) largeur=3;

reste=(double)fmod((double)largeur,2.0);
if (reste==0.0) largeur=largeur+1;

largeur2=(largeur-1)/2;    // contour de l'image

// ---------------------
// calcul du filtre 
// ---------------------
somme=0.0;
for (i=0;i<largeur;i++)
   {
   ilarg=(double)(i-largeur2);
   filtre[i]=exp(-ilarg*ilarg/2./sigma/sigma);
   somme=somme+filtre[i];
   }
for (i=0;i<largeur;i++) filtre[i]=filtre[i]/somme;

imax=buffer->imax;
jmax=buffer->jmax;
longueur=sizeof(double)*imax*jmax;

if ((buf=(double *)malloc((size_t)longueur))==NULL)
   {
   printf("\nPas assez de m�moire\n");
   return 1;
   }

p=buffer->pic;

// -----------------------------
// balayage suivant l'axe X 
// -----------------------------
for (j=0;j<jmax;j++)
   {
   adr=(int)j*imax;
   for (i=0;i<imax;i++)
      {
      val=0.0;
      for (k=0;k<largeur;k++)
	      {
	      i1=i+k-largeur2;
	      if (i1<0) i1=0;
	      if (i1>imax-1) i1=imax-1;
	      adr2=adr+i1;
	      val+=filtre[k]*(double)(*(p+adr2));
	      }
      *(buf+(adr+i))=val;
      }
   }

// -----------------------------
// balayage suivant l'axe Y 
// -----------------------------
for (i=0;i<imax;i++)
   {
   for (j=0;j<jmax;j++)
      {
      val=0.0;
      adr=j*imax+i;
      for (k=0;k<largeur;k++)
	      {
	      j1=j+k-largeur2;
	      if (j1<0) j1=0;
	      if (j1>jmax-1) j1=jmax-1;
	      adr2=j1*imax+i;
	      val+=filtre[k]*(*(buf+adr2));
	      }
      *(p+adr)=(PIC_TYPE)val;
      }
   }

free(buf);

return 0;
}

/********************* GRADY ***********************/
/* Gradient suivant l'axe Y                        */
/* flag (1 ou 2) = sens du gradient                */ 
/***************************************************/
int grady(INFOIMAGE *buffer, int flag)
{
int imax,jmax,i,j;
PIC_TYPE *buf,*p;
int longueur,adr;

if (buffer->pic==NULL) return 1;

imax=buffer->imax;
jmax=buffer->jmax;

longueur=sizeof(PIC_TYPE)*imax*jmax;
if ((buf=(PIC_TYPE *)calloc(longueur,1))==NULL)
   {
   printf("\nPas assez de memoire\n");
   return 1;
   }

p=buffer->pic;

for (i=0;i<imax;i++)
   {
   for (j=0;j<jmax-1;j++)
      {
      adr=(int)j*imax+(int)i;
      if (flag==1)
	     *(buf+adr)=*(p+adr)-*(p+(adr+imax));
      else
	     *(buf+adr)=*(p+(adr+imax))-*(p+adr);
      }
   }
memmove(p,buf,longueur);
free(buf);
return 0;
}


/********************* GRADY2 **********************/
/* Gradient suivant l'axe Y                        */
/* flag (1 ou 2) = sens du gradient                */
/* Fonction nouvelle V1.6 (d�riv�e mieux liss�e    */
/* et centr�e par rapport � grady)                 */
/***************************************************/
int grady2(INFOIMAGE *buffer, int flag)
{
int imax,jmax,i,j;
PIC_TYPE *buf,*p;
int longueur,adr;

if (buffer->pic==NULL) return 1;

imax=buffer->imax;
jmax=buffer->jmax;

longueur=sizeof(PIC_TYPE)*imax*jmax;
if ((buf=(PIC_TYPE *)calloc(longueur,1))==NULL)
   {
   printf("\nPas assez de memoire\n");
   return 1;
   }

p=buffer->pic;

for (i=0;i<imax;i++)
   {
   for (j=2;j<jmax-2;j++)
      {
      adr=(int)j*imax+(int)i;
      if (flag==1)
	     *(buf+adr)=(PIC_TYPE)(.5*(double)(*(p+adr-imax)-*(p+(adr+imax)))+.25*(double)(*(p+adr-2*imax)-*(p+(adr+2*imax))));
      else
	     *(buf+adr)=(PIC_TYPE)(.5*(double)(*(p+adr+imax)-*(p+(adr-imax)))+.25*(double)(*(p+adr+2*imax)-*(p+(adr-2*imax))));
      }
   }
memmove(p,buf,longueur);
free(buf);
return 0;
}

/******************************** CALC_CDG_Y *************************************/
/* Calcule le centre de gravit� suivant l'axe colonne entre les bornes y1 et y2  */
/* dans l'image point�e par p (coordonn�es m�moire - origine (0,0)).             */
/* La colonne analys�e est de rang x.                                            */
/* La coordonn�es y est retourn�e dans pos_y                                     */
/*********************************************************************************/
int calc_cdg_y(PIC_TYPE *p,int imax,int jmax,int x,int y1,int y2,double *pos_y)
{
int j;
double v;
double s1=0.0;
double s2=0.0;

for (j=y1;j<=y2;j++)
   {
   if (j>=0 && j<jmax)
      {
      v=(double)p[x+j*imax];
      s1=s1+(double)j*v;
      s2=s2+v;
      }
   else
      return 1;
   }
if (s2==0)
   *pos_y=0;
else
   *pos_y=s1/s2;

return 0;
}

/************************************* TRACK_ORDER ************************************/
/* D�tecte la trace de l'ordre de rang n, puis la mod�lise par un polyn�me de degr� 4 */
/* wide_y doit �tre inf�rieur � l'�cart minimal typique entre deux ordres             */
/* en pixels suivant l'axe Y.                                                         */
/**************************************************************************************/ 
void track_order(INFOIMAGE *buffer,short *check,int imax, int jmax, int wide_y,ORDRE *ordre,int n,FILE *hand_log)
{
   int i,k,py,size;
   double pos_y;
   double *x,*y,*w,*a;
   int ic=imax/2;
   int degre=4;
   double rms;
   char ligne[512];

   try {
      x= NULL;
      y= NULL;
      w= NULL;
      a= NULL;
      size=abs(ordre[n].max_x-ordre[n].min_x+1);

      if ( ordre[n].yc >= ordre[n].max_x ) {
         sprintf(ligne,"error order #%d: central abcisse is greater than right marging (%f > %f)",
            n, ordre[n].yc, ordre[n].max_x);
         throw std::exception(ligne);
      }
      if ( ordre[n].yc <= ordre[n].min_x ) {
         sprintf(ligne,"error order #%d: central abcisse is lower than left marging (%f < %f)",
            n, ordre[n].yc, ordre[n].min_x);
         throw std::exception(ligne);
      }

      if ((x=(double *)malloc(size*sizeof(double)))==NULL)
      {
         throw std::exception("Pas assez de memoire pour track_order x");
      }

      if ((y=(double *)malloc(size*sizeof(double)))==NULL)
      {
         throw std::exception("Pas assez de memoire pour track_order y");
      }

      if ((w=(double *)malloc(size*sizeof(double)))==NULL)
      {
         throw std::exception("Pas assez de memoire pour track_order w");
      }

      if ((a=(double *)malloc((degre+1)*sizeof(double)))==NULL)
      {
         throw std::exception("Pas assez de memoire pour track_order a");
      }

      // -------------------------------------------
      // D�tection de la trace de l'ordre n
      // -------------------------------------------
      k=0;
      py=int(ordre[n].yc+.5);
      for (i=ic;i<ordre[n].max_x;i++)
      {
         calc_cdg_y(buffer->pic,imax,jmax,i,py-wide_y/2,py+wide_y/2,&pos_y);  // centre de gravit� suivant Y

         if (abs(int(pos_y)-py)>5) continue; // on a d�tect� un point aberrant

         x[k]=(double)i;
         y[k]=pos_y;
         w[k]=1.0;
         py=(int)(pos_y+.5);

         // dessine le point de la ligne de cr�te trouv�e dans l'image de v�rification
///         if ( check != NULL ) {
///            if (i>=0 && i<imax && py>=0 && py<jmax) check[i+py*imax]=1000;    
///         }
         k++;
      } 

      py=int(ordre[n].yc+.5);
      for (i=ic-1;i>=ordre[n].min_x-1;i--)
      {
         calc_cdg_y(buffer->pic,imax,jmax,i,py-wide_y/2,py+wide_y/2,&pos_y); // centre de gravit� suivant Y

         if (abs(int(pos_y)-py)>5) continue; // on a d�tect� un point aberrant

         x[k]=(double)i;
         y[k]=pos_y;
         w[k]=1.0;
         py=(int)(pos_y+.5);

         // dessine le point de la ligne de cr�te trouv�e dans l'image de v�rification
///         if ( check != NULL ) {
///            if (i>=0 && i<imax && py>=0 && py<jmax) check[i+py*imax]=1000;
///         }
         k++;
      } 

      // ---------------------------------------
      // Ajustement du polyn�me
      // ---------------------------------------
      k=size;
      for (i=0;i<=degre;i++) a[i]=0.0;

      fitPoly(k,degre,x,y,w,a,&rms);

      sprintf(ligne,"#%d\t",n);
      fwrite(ligne,strlen(ligne),1,hand_log);

      for (i=0;i<=degre;i++)
      {
         sprintf(ligne,"%e\t",a[i]);
         fwrite(ligne,strlen(ligne),1,hand_log);
         ordre[n].poly_order[i]=a[i];
      }

      sprintf(ligne,"%f\n",rms);
      fwrite(ligne,strlen(ligne),1,hand_log);
      ordre[n].rms_order=rms;

      // ---------------------------------------------------------------------
      // Dessin de la trace de l'ordre mod�lis� dans l'image de v�rification
      // ---------------------------------------------------------------------
      double v;
      for (i=ordre[n].min_x-1;i<ordre[n].max_x;i++)
      {
         v=0.0;
         for (k=0;k<=degre;k++)
         {
            v=v+ordre[n].poly_order[k]*pow((double)i,(double)k);
         }
         py=(int)(v+.5); 
///         if ( check != NULL ) {         
///            if (i>=0 && i<imax && py>=0 && py<jmax) check[i+py*imax]=32000;
///         }
      }

      free(x);
      free(y);
      free(w);
      free(a);

   } catch (std::exception e) {
      if(x) free(x);
      if(y) free(y);
      if(w) free(w);
      if(a) free(a);
   }
}

/**************************************** GET_CENTRAL_WAVE *******************************************/
/* Retourne la longueur d'onde centrale de l'ordre k (� la coordonn�e imax/2)                        */    
/*****************************************************************************************************/
double get_central_wave(int imax,double posx,double dx,int k,INFOSPECTRO spectro)
{
   double alpha=spectro.alpha*PI/180.0;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;
   double lambda;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      double gamma=spectro.gamma*PI/180.0;
      double beta=(posx-(double)imax/2-dx)*pixel/focale;
      lambda=cos(gamma)*(sin(alpha)+sin(beta+alpha))/m/(double)k*1.0e7;
   } else {
      double beta = spectro.beta*PI/180.0;;
      lambda=(sin(alpha)+sin(beta))/m/(double)k*1.0e7;
   }

   return lambda;
}

/********************************* FLAT_RECTIF ***********************************/
/* Division par le flat-field (au niveau profil spectral)                        */
/* Le nom du profil � divis� est n_objet, le nom du profil flat-field est n_flat */
/* La variable i contient le num�ro de l'ordre trait�                            */
/* Le r�sultat est un profil de nom g�n�rique n_objet_xxx                        */
/*********************************************************************************/
int flat_rectif(int i,char *n_objet,char *n_flat,ORDRE *ordre)
{
FILE *hand_objet0,*hand_flat,*hand_objet;
char nom_objet0[_MAX_PATH],nom_flat[_MAX_PATH],nom_objet[_MAX_PATH];
char ligne[256];
int pixel;
double objet0,flat,objet;

if (ordre[i].flag==1)
   {
   sprintf(nom_objet0,"%s0_%d.dat",n_objet,i);
   sprintf(nom_flat,"%s0_%d.dat",n_flat,i);
   sprintf(nom_objet,"%s_%d.dat",n_objet,i);

   if ((hand_objet0=fopen(nom_objet0,"r") ) == NULL) 
      {
      printf("\nLe fichier %s est introuvable.\n",nom_objet0);
      return 1;
      }

   if ((hand_flat=fopen(nom_flat,"r") ) == NULL) 
      {
      printf("\nLe fichier %s est introuvable.\n",nom_flat);
      return 1;
      }

   if ((hand_objet=fopen(nom_objet,"wt"))==NULL) 
      {
      printf("\nProbl�me d'�criture du fichier %s.\n",nom_objet);
      return 1;
      }

   int k=0;
   while (fscanf(hand_objet0,"%d %lf",&pixel,&objet0)!=EOF && k!=20000)
      {
      fscanf(hand_flat,"%d %lf",&pixel,&flat);
      if (flat==0)
         objet=0.0;
      else
         objet=(double)objet0/(double)flat;
      sprintf(ligne,"%d\t%lf\n",pixel,objet);
      fwrite(ligne,strlen(ligne),1,hand_objet);
      k++;
      }

   fclose(hand_objet0);
   fclose(hand_flat);
   fclose(hand_objet);
   }

return 0;
}

/********************************* FLAT_RECTIF ***********************************/
/* Division par le flat-field (au niveau profil spectral)                        */
/* Le nom du profil � divis� est n_objet, le nom du profil flat-field est n_flat */
/* La variable i contient le num�ro de l'ordre trait�                            */
/* Le r�sultat est un profil de nom g�n�rique n_objet_xxx                        */
/*********************************************************************************/
void flat_rectif(std::valarray<double> &object ,std::valarray<double> &flat, std::valarray<double> &out)
{
   for (unsigned i=0; i < object.size(); i++ ) { 
      if (flat[i]==0) {
         out[i]=0.0;
      } 
      else {
         out[i]=object[i]/flat[i];
      }
   }
}

/************************************* CALIB_PREDICTION **************************************/
/* Calcul de la position (en pixel) dans un ordre donn� d'un longueur d'onde donn�e.         */
/* Il faut fournir en entr�e la position X de la raie de r�f�rence (posx0).                  */
/* lambda0 et ordre0 sont les longueurs d'onde de la raie de r�f�rence et l'ordre nominal    */
/* La fonction retourne le d�calage en X entre la position th�rorique attendue de cette      */
/* raie et la position effectivement observ�e (ddx).                                         */
/* La position th�orique est marqu�e dans l'image de v�rification par un carr� en pointill�. */
/*********************************************************************************************/
int calib_prediction(double lambda0,int ordre0,short *check,int imax, int jmax,double posx0,
                     ORDRE *ordre,double *ddx,INFOSPECTRO spectro,::std::list<double> lineList )
{
   double k;
   k=(double)ordre0;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;
   double alpha=spectro.alpha*PI/180.0;     
   double beta,beta2,posx;
   double x_mesure=posx0;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      double gamma=spectro.gamma*PI/180.0;
      beta=asin((k*m*lambda0/1.0e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      posx=focale*beta2/pixel+(double)imax/2.0;
   } else {
      double beta = spectro.beta*PI/180.0;       
      posx = (lambda0 - (sin(alpha)+sin(beta))*1.0e7/ (k*m)) / (pixel *1.0e7 *cos(beta)/(m *k * focale)) + imax/2.0;
   }
   double dx=x_mesure-posx;
   *ddx=dx;

   return(0);
}

/******************************************* COMPUTE_POS *****************************************/
/* Calcule la position d'une raie de longueur d'onde lam pour l'ordre k dans le profil spectral. */
/* Tiens compte du d�calage dx trouv�e avec la raie du Ne � 5852 A.                              */
/*************************************************************************************************/
double compute_pos(double k,double lambda,double dx,int imax, INFOSPECTRO spectro)
{
   
   double alpha=spectro.alpha*PI/180.;
   int xc=imax/2;
   double beta,beta2,posx;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      double gamma=spectro.gamma*PI/180.0;
      beta=asin((k*spectro.m*lambda/1.0e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      posx=spectro.focale*beta2/spectro.pixel+(double)xc+dx;
   } else {
      beta = spectro.beta*PI/180.0;       
      posx = (lambda - (sin(alpha)+sin(beta))*1.0e7/(k*spectro.m)) / (spectro.pixel *1.0e7 *cos(beta)/(spectro.m *k * spectro.focale)) + (double) xc +dx;
   }
   return(posx);
}


/******************* TRANSLATE_LINE *******************/
/* Translation d'une ligne de l'image                 */
/* Line : numero de la ligne (en coordonnees m�moire) */
/* delta_x : valeur de la translation                 */
/******************************************************/
int translate_line(INFOIMAGE *buffer,int line,double delta_x)
{
double frac_x;
PIC_TYPE d_x;
double poids1,poids3;
int i,imax,jmax,i0,j0;
PIC_TYPE l1,l3;
PIC_TYPE *ptr,*p,*buf;
double level2;
int adr,longueur;

if (buffer->pic==NULL) return 1;

delta_x=-delta_x;
d_x=(PIC_TYPE)floor(delta_x);  /* partie entiere de la translation sur X */
frac_x=delta_x-d_x;         /* partie fractionnaire sur X */

poids1=(1-frac_x);   /* en bas a gauche */
poids3=frac_x;       /* en bas a droite */

imax=buffer->imax;
jmax=buffer->jmax;

longueur=(int)imax;

if ((buf=(PIC_TYPE *)calloc(longueur,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

p=buffer->pic;

j0=line;
if (j0>=0 && j0<jmax-1)
   {
   adr=(int)j0*imax;
   for (i=0;i<imax;i++)
	   {
	   i0=i+d_x;
	   if (i0>=0 && i0<imax-1) /* test dans image depart */
	      {
	      l1=*(ptr=p+(adr+i0));
	      l3=*(++ptr);
	      level2=poids1*(double)l1+poids3*(double)l3+.5;
	      buf[i]=(PIC_TYPE)level2;
	      }
	   }
   }

for (i=0;i<imax;i++)
   {
   adr=(int)j0*imax+(int)i;
   *(p+adr)=buf[i];
   }

free(buf);

return 0;
}


///////////////////////////////////////////////////////
#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif
///////////////////////////////////////////////////////

/***************** INTPOL_SPLINE16 ******************/
/* Fonction d'interpollation spline d'ordre 16      */
/****************************************************/
void intpol_spline16(double x,double *a,int ndim)
{ 
a[3] = ( ( 1.0/3.0  * x - 1.0/5.0 ) * x -   2.0/15.0 ) * x;	
a[2] = ( ( 6.0/5.0 - x     ) * x +   4.0/5.0 ) * x;				
a[1] = ( ( x - 9.0/5.0 ) * x -   1.0/5.0     ) * x + 1.0;		
a[0] = ( ( -1.0/3.0 * x + 4.0/5.0     ) * x -   7.0/15.0 ) * x ;
}

// Polyn�me cubique avec param�tre A
// A = -1: traitement dur; A = - 0.5 traitement homog�ne (recommand� !)
// attention x >= 0
#define	A	(-0.5)
// 0 <= x < 1
static double cubic01( double x )
{
return	(( A + 2.0 )*x - ( A + 3.0 ))*x*x +1.0;
}
// 1 <= x < 2
static double cubic12( double x )
{
return	(( A * x - 5.0 * A ) * x + 8.0 * A ) * x - 4.0 * A;
}
#undef A

/****************** INTPOL_CUBIC *******************/
/* Fonction d'interpollation bicubique             */
/***************************************************/ 
void intpol_cubic(double x,double *a,int ndim)														
{											
a[3] = cubic12( 2.0 - x);
a[2] = cubic01( 1.0 - x);
a[1] = cubic01( x );
a[0] = cubic12( x + 1.0);
}

/////////////// SINC0  ///////////////////
double sinc0( double x )
{
x*=PI;
if(x != 0.0) return(sin(x) / x);
return(1.0);
}

/****************** INTPOL_SINC ********************/
/* Fonction d'interpollation sinc                  */
/***************************************************/
void intpol_sinc(double x,double *a,int ndim)														
{																
int idx;
double xadd;
for (idx=0,xadd=ndim/2-1.0+x;idx<ndim/2;xadd-=1.0)			
   {						
	a[idx++] = sinc0( xadd ) * sinc0( xadd / ( ndim / 2 ));	
	}				
for (xadd=1.0-x;idx<ndim;xadd+=1.0)
   {					
	a[idx++] = sinc0( xadd ) * sinc0( xadd / ( ndim / 2 ));	
   }
}

/******************* TRANSLATE_COL_1 *********************/
/* Translation d'une colonne de l'image                */
/* Colonne : num�ro de la colonne (en coord. m�moire)  */
/* delta_y : valeur de la translation                  */
/* Version 1.6 (V1.6)                                  */
/* Plusieurs modes d'interpollation disponibles        */
/* via la variable interne mode :                      */
/* mode = 0 -> bilineaire simple                       */
/* mode = 1 -> bicubique (bon choix avec A = 0.5)      */
/* mode = 2 -> spline 32 pixels (bons r�sultats aussi) */
/* mode = 3 -> sinc (trop lent)                        */
/*******************************************************/
 int translate_col_1(INFOIMAGE *buffer,int colonne,double delta_y)
{
int imax,jmax,i,j,adr;
PIC_TYPE *p,*p2,*tampon;
double x,y;

int mode=1;

if (buffer->pic==NULL) return 1;

imax=buffer->imax;
jmax=buffer->jmax;
int imax1=imax-1;
int jmax1=jmax-1;

if ((tampon=(PIC_TYPE *)calloc(jmax,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

p=buffer->pic;
p2=tampon;

i=colonne;

for (j=0;j<jmax;j++,p2++)
	{
   x=(double)i;
	y=(double)j-delta_y;
  
   if ((y>=0) && (y<(double)jmax))
      {
      if (mode==0) // bilin�aire standard
         {
         int ii,jj,ii1,jj1;
         double val1,val2,val3,val4,value;
         PIC_TYPE v1,v2,v3,v4;
 
	      ii=(int)x;
	      jj=(int)y;
	      ii1=min(ii+1,imax1);
	      jj1=min(jj+1,jmax1);
         val1=0.0;
         val2=1.0;
	      val3=y-(double)jj;
	      val4=1.0-val3;
 
         adr=(int)ii+(int)jj*imax;
	      v1=*(p+adr);
	      adr=(int)ii1+(int)jj*imax;
	      v2=*(p+adr);
	      adr=(int)ii+(int)jj1*imax;
	      v3=*(p+adr);
	      adr=(int)ii1+(int)jj1*imax;
	      v4=*(p+adr);
	      value=val2*(val4*(double)v1 + val3*(double)v3)
	            +val1*(val4*(double)v2 + val3*(double)v4);
	      if (value>INT_MAX)
	         *p2=INT_MAX;
	      else if (value<INT_MIN)
	         *p2=INT_MIN;
	      else
	         *p2=(PIC_TYPE)(value+.5);
         }
      else if (mode==1) // bicubique
         { 
         double Dx,Dy;
         double w[16],yr[16],rd;
         double weight;
         int xc,yc,xs,ys,n2;
         int k,kk,ii2,jj2;
         int ndim;

         ndim=4;
         n2=ndim/2;

  		   xc=(int)floor(x);
         Dx=0.0;
	 	   yc=(int)floor(y);
         Dy=y-(double)yc;
		   ys=yc+1-n2; 
		   xs=xc+1-n2; 
         intpol_cubic(Dx,w,ndim);
		   for (k=0;k<ndim;k++)										
		      {																
            rd=0.0;																		
			   for (kk=0;kk<ndim;kk++)										
			      {															
				   weight=w[kk];
               ii2=min(xs+kk,imax1);
					jj2=min(ys+k,jmax1);				
               ii2=max(ii2,0);
					jj2=max(jj2,0);				
	            adr=(int)ii2+(int)(jj2)*imax;
               rd+=(double)*(p+adr)*weight;
               }
            yr[k]=rd;
            }
         intpol_cubic(Dy,w,ndim);
		   rd=0.0;																												
		   for (kk=0;kk<ndim;kk++)											
		      {																
			   weight=w[kk];											
			   rd+=yr[kk]*weight;										
		      }
	      if (rd>INT_MAX)
	         *p2=INT_MAX;
	      else if (rd<INT_MIN)
	         *p2=INT_MIN;
	      else
	         *p2=(PIC_TYPE)(rd+.5);
         }
      else if (mode==2)  // spline 16 pixels
         {
         double Dx,Dy;
         double w[16],yr[16],rd;
         double weight;
         int xc,yc,xs,ys,n2;
         int k,kk,ii2,jj2;
         int ndim;

         ndim=4;
         n2=ndim/2;

         xc=(int)floor(x);
         Dx=0.0;
         yc=(int)floor(y);
         Dy=y-(double)yc;
         ys=yc+1-n2; 
         xs=xc+1-n2;
         intpol_spline16(Dx,w,ndim);
         for (k=0;k<ndim;k++)										
            {																
            rd=0.0;																		
            for (kk=0;kk<ndim;kk++)										
	            {															
	            weight=w[kk];
               ii2=min(xs+kk,imax1);
	            jj2=min(ys+k,jmax1);				
               ii2=max(ii2,0);
	            jj2=max(jj2,0);				
	            adr=(int)ii2+(int)(jj2)*imax;
               rd+=(double)*(p+adr)*weight;
               }
            yr[k]=rd;
            }
         intpol_spline16(Dy,w,ndim);
         rd=0.0;																												
         for (kk=0;kk<ndim;kk++)											
            {																
            weight=w[kk];											
            rd+=yr[kk]*weight;										
            }
         if (rd>INT_MAX)
         *p2=INT_MAX;
         else if (rd<INT_MIN)
         *p2=INT_MIN;
         else
         *p2=(PIC_TYPE)(rd+.5);
         }
      else if (mode==3)  // sinc
         {
         double Dx,Dy;
         double w[16],yr[16],rd;
         double weight;
         int xc,yc,xs,ys,n2;
         int k,kk,ii2,jj2;
         int ndim;

         ndim=16;
         n2=ndim/2;

  		   xc=(int)floor(x);
         Dx=0.0;
	 	   yc=(int)floor(y);
         Dy=y-(double)yc;
		   ys=yc+1-n2; // smallest y-index used for interpolation
		   xs=xc+1-n2; // smallest x-index used for interpolation
         intpol_sinc(Dx,w,ndim);
		   for (k=0;k<ndim;k++)										
		      {																
            rd=0.0;																		
			   for (kk=0;kk<ndim;kk++)										
			      {															
				   weight=w[kk];
               ii2=min(xs+kk,imax1);
					jj2=min(ys+k,jmax1);				
               ii2=max(ii2,0);
					jj2=max(jj2,0);				
	            adr=(int)ii2+(int)(jj2)*imax;
               rd+=(double)*(p+adr)*weight;
               }
            yr[k]=rd;
            }
         intpol_sinc(Dy,w,ndim);
		   rd=0.0;																												
		   for (kk=0;kk<ndim;kk++)											
		      {																
			   weight=w[kk];											
			   rd+=yr[kk]*weight;										
		      }
	      if (rd>INT_MAX)
	         *p2=INT_MAX;
	      else if (rd<INT_MIN)
	         *p2=INT_MIN;
	      else
	         *p2=(PIC_TYPE)(rd+.5);
         }
      }
	}

for (j=0;j<jmax;j++)
   {
   adr=(int)j*imax+(int)i;
   *(p+adr)=tampon[j];
   }

free(tampon);
return 0;
}


/******************** TRANSLATE_COL_0******************/
/* Translation d'une colonne de l'image               */
/* Colonne : num�ro de la colonne (en coord. m�moire) */
/* delta_y : valeur de la translation                 */
/******************************************************/
int translate_col_0(INFOIMAGE *buffer,int colonne,double delta_y)
{
double frac_y;
int d_y;
double poids1,poids3;
int j,imax,jmax,i0,j0;
int l1,l3;
PIC_TYPE *p,*buf;
double level2;
int adr,longueur;

if (buffer->pic==NULL) return 1;

delta_y=-delta_y;
d_y=(int)floor(delta_y);  // partie enti�re de la translation suivant Y 
frac_y=delta_y-d_y;         // partie fractionnaire de la translation

poids1=(1-frac_y);   
poids3=frac_y;       

imax=buffer->imax;
jmax=buffer->jmax;

longueur=jmax;
if ((buf=(PIC_TYPE *)calloc(longueur,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

p=buffer->pic;

i0=colonne;
if (i0>=0 && i0<imax-1)
   {
   for (j=0;j<jmax;j++)
	   {
	   j0=j+d_y;
	   if (j0>=0 && j0<jmax-1) // test dans image depart
	      {
         adr=j0*imax+i0;
         //l1=*(p+adr);
         l1=p[adr];
         adr=adr+imax;
         //l3=*(p+adr);
         l3=p[adr];
	      level2=poids1*(double)l1+poids3*(double)l3+.5;
         adr=j*imax+i0;
         buf[j]=(PIC_TYPE)level2;
	      }
	   }
   }

for (j=0;j<jmax;j++)
   {
   adr=j*imax+i0;
   p[adr]=buf[j];
   }

free(buf);
return 0;
}

/************************************** L_SKY_SUB ****************************************/
/* Calcul de la m�diane dans deux zones de part et d'autre de la trace du spectre,       */ 
/* puis soustraction de la moyenne de ces deux mesures (y1,y2,y3,y4 = coordonn�es image) */
/*****************************************************************************************/
int l_sky_sub(INFOIMAGE *buffer,int y1,int y2,int y3,int y4)
{
PIC_TYPE *p;
int imax,jmax,adr,i,j,ptc;
PIC_TYPE *buf1,*buf2;
int nb_ligne1,nb_ligne2;
int tempo;
int m1,m2;
PIC_TYPE m;

if (buffer->pic==NULL) return 1;

p=buffer->pic;
imax=buffer->imax;
jmax=buffer->jmax;

// zone 1
if (y2<y1)
   {
   tempo=y2;
   y2=y1;
   y1=tempo;
   }
if (y2>jmax) y2=jmax;
if (y1<1) y1=1;
nb_ligne1=y2-y1+1;
if ((buf1=(PIC_TYPE *)calloc(nb_ligne1,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

// zone 2
if (y4<y3)
   {
   tempo=y4;
   y4=y3;
   y3=tempo;
   }
if (y4>jmax) y4=jmax;
if (y3<1) y3=1;
nb_ligne2=y4-y3+1;
if ((buf2=(PIC_TYPE *)calloc(nb_ligne2,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

for (i=0;i<imax;i++)
   {
   // zone 1
   ptc=0;
   for (j=y1-1;j<y2;j++)
      {
      adr=j*imax+i;
      buf1[ptc]=p[j*imax+i];
      ptc++;
      }
   m1=(int)hmedian(buf1,nb_ligne1);

   // zone 2
   ptc=0;
   for (j=y3-1;j<y4;j++)
      {
      adr=j*imax+i;
      buf2[ptc]=p[j*imax+i];
      ptc++;
      }
   m2=(int)hmedian(buf2,nb_ligne2);

   m=(PIC_TYPE)(((double)m1+(double)m2)/2.0+.5);

   for (j=0;j<jmax;j++)
      {
      p[j*imax+i]=p[j*imax+i]-m; 
      }
   }

free(buf1);
free(buf2);
return 0;
}

/********************************* L_OPT ***********************************/
/* Calcul la somme normalis�e et optimis� entre les lignes lmax et lmin    */
/* Version simplifli� sans r�jection des pixels aberrants                  */
/* Variance constante (ind�pendante du signal)                             */
/* Dans ce cas                                                             */
/*    F = S(P.(D-ciel)) / S(P . P)                                         */
/*                                                                         */
/* Voir J. G. Robertson, PASP 98, 1220-1231, November 1986                 */
/* Le domaine de binning suivant l'axe spatial est donn� par (lmin - lmax) */
/* (ligne min et ligne max ( origine 1,1).                                 */
/* Le calcul est fait entre les colonnes xmin et xmax (origine 1,1)        */
/* Le nom du profil spectral (extension .dat) est nom                      */
/***************************************************************************/
int l_opt(INFOIMAGE *buffer,int lmin,int lmax,int xmin,int xmax,std::valarray<double> &profile)
{
   int i,j,k;
   int imax,jmax;
   int tempo;
   PIC_TYPE *p;
   double somme,norme;
   double v,w,s;
   PIC_TYPE vv[50]; 

   if (buffer->pic==NULL) return 1;

   imax=buffer->imax;
   jmax=buffer->jmax;

   if (lmax<lmin)
   {
      tempo=lmax;
      lmax=lmin;
      lmin=tempo;
   }

   if (lmax>jmax || lmin<1) 
   {
      printf("\n Erreur interne L_OPT.\n");
      return 1;
   }

   if ((lmax-lmin)<4)
   {
      printf("\n Erreur interne L_OPT.\n");
      return 1;
   }

   if (xmax<xmin)
   {
      tempo=xmax;
      xmax=xmin;
      xmin=tempo;
   }

   if (xmax>imax) xmax=imax;
   if (xmin<1) xmin=1;

   // Profil spectral monodimentionnel (f)
   double *f;
   if ((f=(double *)calloc(imax,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

   // Mod�le profil spectral colonne (P)
   double *P;
   if ((P=(double *)calloc(lmax-lmin+1,sizeof(double)))==NULL)
   {
      printf("\nPas assez de memoire.\n");
      free(f);
      return 1;
   }

   p=buffer->pic;

   // --------------------------------------
   // Calcul du profil spectral optimis�
   // --------------------------------------

   // On g�re les 3 premi�res colonnes
   for (i=xmin-1;i<xmin+2;i++)
   {
      somme=0.0;
      k=0;
      // Calcul de la fonction de poids
      for (j=lmin-1;j<lmax;j++,k++)
      {
         P[k]=(double)p[j*imax+i];
      }

      // La fonction de poids est rendue strictement positive et normalis�e
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         if (P[k]<0) P[k]=0;
         s=s+P[k];
      }  
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         P[k]=P[k]/s;
      }

      // Calcul de la norme
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         s=s+P[k]*P[k];
      }  
      norme=s;

      // Calcul du profil optimis�
      if (norme!=0.0 && _isnan(norme)==0)
      {
         k=0;
         for (j=lmin-1;j<lmax;j++,k++)
         {
            v=(double)p[j*imax+i];
            w=P[k];
            somme+=w*v;
         }
         f[i]=somme/norme;
      }
      else
         f[i]=0.0;
   }

   // On g�re les 3 derni�res colonne
   i=imax-3;
   for (i=xmax-3;i<xmax;i++)
   {
      somme=0.0;
      k=0;
      // Calcul de la fonction de poids
      for (j=lmin-1;j<lmax;j++,k++)
      {
         P[k]=(double)p[j*imax+i];
      }

      // La fonction de poids est rendue strictement positive et noormalis�e
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         if (P[k]<0) P[k]=0;
         s=s+P[k];
      }  
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         P[k]=P[k]/s;
      }

      // Calcul de la norme
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         s=s+P[k]*P[k];
      }  
      norme=s;

      // Calcul du profil optimis�
      if (norme!=0.0 && _isnan(norme)==0)
      {
         k=0;
         for (j=lmin-1;j<lmax;j++,k++)
         {
            v=(double)p[j*imax+i];
            w=P[k];
            somme+=w*v;
         }
         f[i]=somme/norme;
      }
      else
         f[i]=0.0;
   }

   // On g�re le reste du profil...
   for (i=xmin+2;i<xmax-3;i++)
   {
      somme=0.0;
      k=0;
      // Calcul de la fonction de poids = m�diane sur 7 colonnes
      for (j=lmin-1;j<lmax;j++,k++)
      {
         vv[0]=p[j*imax+i-3];
         vv[1]=p[j*imax+i-2];
         vv[2]=p[j*imax+i-1];
         vv[3]=p[j*imax+i];
         vv[4]=p[j*imax+i+1];
         vv[5]=p[j*imax+i+2];
         vv[6]=p[j*imax+i+3];
         P[k]=(double)hmedian(vv,7);
      }

      // La fonction de poids est rendue strictement positive et noormalis�e
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         if (P[k]<0) P[k]=0;
         s=s+P[k];
      }  
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         P[k]=P[k]/s;
      }

      // Calcul de la norme
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++)
      {      
         s=s+P[k]*P[k];
      }  
      norme=s;

      // Calcul du profil optimis�
      if (norme!=0.0 && _isnan(norme)==0)
      {
         k=0;
         for (j=lmin-1;j<lmax;j++,k++)
         {
            v=(double)p[j*imax+i];
            w=P[k];
            somme+=w*v;
         }
         f[i]=somme/norme;
      }
      else
         f[i]=0.0;
   }

   // -----------------------------------------------------
   // Sauvegarde du profil spectral (en comptes num�riques)
   // -----------------------------------------------------
   for (i=xmin;i<=xmax;i++) { 
      profile[i-xmin] = f[i-1];
   }

   free(f);
   free(P);

   return 0;
}

/******************************** EXTRACT_ORDER **************************************/
/* Corrige la courbure d'un ordre (le spectre est rendu rectiligne), puis            */
/* extraction du profil spectrale apr�s l'op�ration de binning suivant l'axe spatial */
/* Le num�ro de l'ordre trait� est contenu dans la variable n.                       */                
/*************************************************************************************/
int extract_order(INFOIMAGE *buffer,int n,int jmax0,ORDRE *ordre, std::valarray<double> &profile, std::valarray<PIC_TYPE> *straightLineImage )
{
   int i,k,yc;
   int degre=4;
   double delta_y;
   double v;
   int y1,y2,y3,y4;

   for (i=ordre[n].min_x-1;i<ordre[n].max_x;i++)
   {
      v=0.0;
      for (k=0;k<=degre;k++)
      {
         v=v+ordre[n].poly_order[k]*pow((double)i,(double)k);
      }
      delta_y=v-ordre[n].yc;

      // rectification g�om�trique colonne par colonne
      if (translate_col_1(buffer,i,-delta_y)==1) return 1;  // nouvelle version V1.6
   }

   // retrait du fond
   yc=(int)(ordre[n].yc+.5);
   y1=yc+ordre[n].wide_y/2;
   y2=yc+ordre[n].wide_y/2+ordre[n].wide_sky;    
   y3=yc-ordre[n].wide_y/2;
   y4=yc-ordre[n].wide_y/2-ordre[n].wide_sky;  
   if (l_sky_sub(buffer,y1,y2,y3,y4)==1) return 1;

   // redressement des raies
   if (compute_slant(buffer,yc,ordre[n].slant)==1) return 1;

   if ( straightLineImage != NULL ) {
      int adr1, adr2;
      int jj = 0;
      straightLineImage->resize(buffer->imax * (y2-y4+1) );
      for (int j=y4;j<y2;j++) 
      {
         for (int i=0;i<buffer->imax;i++) 
         {
            adr1=(j+1)*buffer->imax+i;
            adr2=jj*buffer->imax+i;
            (*straightLineImage)[adr2]=buffer->pic[adr1];
         }
         jj++;
      }
   }
   
   // binning du profil et sauvegarde sur le disque du profil spectral calcul�
   y1=yc-ordre[n].wide_y/2;
   y2=yc+ordre[n].wide_y/2;
   if (l_opt(buffer,y1,y2,ordre[n].min_x,ordre[n].max_x, profile)==1) return 1;

   return 0;
}

/***************************** COMPUTE_SLANT *************************************/
/* Fait "glisser" diff�rentiellement les lignes d'une image                      */
/* La ligne neutre est y0. Compense le tit des raies par rapport                 */ 
/* d'un angle alpha � l'axe de dispersion                                        */
/*********************************************************************************/
int compute_slant(INFOIMAGE *buffer,int y0,double alpha)
{
int j,jmax;
double alpha_rd,dx,dy;

if (buffer->pic==NULL) return 1;
jmax=buffer->jmax;
alpha_rd=alpha*PI/180.0;

for (j=0;j<jmax;j++)
   {
   dy=(double)((j+1)-y0);
   dx=dy*tan(alpha_rd);
   if (translate_line(buffer,j,dx)==1) return 1;
   }

return 0;
}

/************************************ PREDIC_POS **********************************/
/* Pr�dit la position d'une raie dans l'image                                     */
/* et retourne l'offset suivant X par rapport � la position effectivement mesur�e */
/* (lambda, order) sont la longueur et l'ordre nominal de la raie                 */
/**********************************************************************************/
int predic_pos(double lambda,int order,double x_mesure,int imax,ORDRE *ordre,double *dx, INFOSPECTRO spectro)
{
double k=(double)order;

double gamma=spectro.gamma*PI/180.0;
double alpha=spectro.alpha*PI/180;
double beta,beta2,posx;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      beta=asin((k*spectro.m*lambda/1e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      posx=spectro.focale*beta2/spectro.pixel+(double)imax/2.0;
   } else {      
      beta = spectro.beta*PI/180;
      posx = (lambda - (sin(alpha)+sin(beta))*1.0e7/ (k*spectro.m)) / (spectro.pixel *1.0e7 *cos(beta)/(spectro.m *k * spectro.focale)) + imax/2.0;
   }
   *dx=x_mesure-posx;

   return 0;
}



/************************ LINE_POS_APPROX *****************************/
/* Dans le vecteur buf, retourne la position du pixel d'intensit�     */
/* maximale, recherch�e dans une fen�tre                              */ 
/* de largeur wide (pixel) centr�e sur la coordonn�es pos.            */
/* La longueur du vecteur est taille.                                 */
/* Le resultat est retourn� dans la variable posx                     */
/**********************************************************************/
int line_pos_approx(int pos,int wide,std::valarray<double> &buf,int *posx)
{
   int i;
   int x1,x2,wide2;

   wide2=wide/2;
   x1=pos-wide2;
   x2=pos+wide2;

   if (x1<0)
   {
      x1=0;
      x2=x1+wide;
   }

   if (x2>(int)buf.size()-1)
   {
      x2=(int)buf.size()-1;
      x1=x2-wide;
   }

   double max=-1e-10;
   for (i=x1;i<x2;i++)
   {
      if (buf[i]>max)
      {
         max=buf[i];
         *posx=i;  // origine (0) 
      }
   } 
   return 0;
}

/***************************** SPEC_CDG ********************************/
/* Calcule le centre de gravit� dans un profil                         */
/* La fen�tre de calcul est centr�e sur pos et de la largeur wide      */
/* La taille du vecteur analys� est taille.                            */
/* Le vecteur est point� par buf. Le r�sultat est retrourn� dans pos_x */                        
/***********************************************************************/
int spec_cdg(int pos,int wide,int taille,double *buf,double *pos_x)
{
int i;
int x1,x2,wide2;
double v;
double s1=0.0;
double s2=0.0;

wide2=wide/2;
x1=pos-wide2;
x2=pos+wide2;

if (x1<0)
   {
   x1=0;
   x2=x1+wide;
   }

if (x2>taille-1)
   {
   x2=taille-1;
   x1=x2-wide;
   }
   
for (i=x1;i<x2;i++)
   {
   if (i>=0 && i<taille)
      {
      v=buf[i];
      s1=s1+(double)i*v;
      s2=s2+v;
      }
   else
      return 1;
   }

if (s2==0)
   *pos_x=0;
else
   *pos_x=s1/s2;

return 0;
}

// ///////////////////////////////////////////////////////////////////////////////
// Retourne la longueur d'onde th�orique � partir de la position px dans l'image
// ///////////////////////////////////////////////////////////////////////////////
double compute_px2lambda(double px, double k, double dx, INFOSPECTRO spectro)
{
   double gamma = spectro.gamma * PI / 180.0;
   double alpha = spectro.alpha * PI / 180.0;
   double beta, beta2;
   double xc = (double)spectro.imax / 2.0;

   beta2 = (px - xc - dx) * spectro.pixel / spectro.focale;
   beta = beta2 + alpha;
   double lambda = 1.0e7 * cos(gamma) * (sin(alpha) + sin(beta)) / k / spectro.m;
   return lambda;
}


/********************************* CALIB_SPEC *********************************/
/* Calibration spectrale de l'ordre n (calcul des polynomes de dispersion)    */
/* La position approximative des raies est calcul�e avec la formule du r�seau */
/* V1.4 -> retourne le nombre de raies retenues + nombre it�ration            */
/******************************************************************************/
void calib_spec(int n,int nb_iter,double lambda_ref,int ordre_ref,std::valarray<double> &calibRawProfile, ORDRE *ordre,
                int imax,int jmax,int neon_ref_x,short *check,INFOSPECTRO spectro,::std::list<double> &lineList, ::std::list<LINE_GAP> &lineGapList)
{

   double coef = 1.5;          // coefficient de r�jection du sigma-clipping
   double position[MAX_LINES];
   double table_lambda[MAX_LINES];
   double result_lambda[MAX_LINES];    // table des longueur d'onde des raies analysees
   double result_position[MAX_LINES];   // table des positions des raies analysees
   int    result_flag[MAX_LINES];     // table des resultats d'analyse 1=OK 0=erreur 
   double w[MAX_LINES];
   double a[5]; 
   double rms = 0;
   double fwhm = 0.0;
   int wide_x=ordre[n].wide_x;  // largeur de la zone de recherche d'une raie (en pixels)

   double lambda;
   double alpha=spectro.alpha;
   double gamma=spectro.gamma;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;

   try {
      memset(position,0,MAX_LINES*sizeof(double));
      memset(table_lambda,0,MAX_LINES*sizeof(double));
      memset(result_lambda,0,MAX_LINES*sizeof(double));
      memset(result_position,0,MAX_LINES*sizeof(double));
      memset(result_flag,0,MAX_LINES*sizeof(int));
      memset(w,0,MAX_LINES*sizeof(double));
      memset(a,0,5*sizeof(double));

      double psf_posx;
      int pos2;
      double dx=0;
      double px;
      int calib_degre = 3;
      double sfwhm = 0;

      ordre[n].a0 = 0; 
      ordre[n].a1 = 0;
      ordre[n].a2 = 0; 
      ordre[n].a3 = 0; 

      // Calcul de l'�cart (dx) entre la position fourni et la position mesur�e de 
      // la raie du thorium � 6584 A
      predic_pos(lambda_ref,ordre_ref,(double)neon_ref_x,imax,ordre,&dx,spectro);      

      int nb_analyse=0;
      int kk=0;
      for (int ni=0;ni<nb_iter;ni++) {
         sfwhm=0.0;
         nb_analyse=0;      // nombre de raies analysees dans l'ordre
         kk = 0;            // nombre de raies reconnues dans l'ordre
         
         ::std::list<double>::iterator iter;
         for (iter=lineList.begin(); iter != lineList.end(); ++iter) 
         {            
            lambda = *iter;
            double px0=compute_pos((double)n,lambda,dx,imax,spectro);
            // correction de la distorsion;
            px = 0 ;
            if (spectro.distorsion.size() > 0 ) {
               for (unsigned int index = 0; index < spectro.distorsion.size(); index++) {
                  px = px + spectro.distorsion[index] * pow(px0, (double)index);
               }
            } else {
               px = px0;
            }
            
            // On v�rifie que la position tombe dans l'intervalle sp�cifi�
            // TODO : remplacer 5 par param.bordure
            if ((int)px>(ordre[n].min_x+(wide_x/2+1)+5) && (int)px<(ordre[n].max_x-(wide_x/2+1)-5)) 
            {                                                       
               pos2=(int)px-ordre[n].min_x;
               int pos = 0;
               // je recherche la position approximative de la raie (pixel le plus intense) dans la zone de largeur wide_x 
               line_pos_approx(pos2,wide_x,calibRawProfile,&pos);
               
               // ajustement gaussien 
               double ecartType;               
               if ( spec_gauss(pos,9,calibRawProfile,&psf_posx,&fwhm,&ecartType) == 0 ) { 
                  if (ni!=0) { 
                     // sigma-clipping au-del� de la premi�re it�ration
                     double lambda_estime = 0;
                     // je calcule la longueur d'onde correspondant � position observee
                     for (int index = 0; index <= calib_degre; index++) {
                        lambda_estime = lambda_estime + a[index] * pow(psf_posx, (double)index);     
                     }

                     if (fabs(lambda-lambda_estime) < coef*rms) { // sigma-clipping
                        sfwhm=sfwhm+fwhm; 
                        table_lambda[kk]=lambda;
                        position[kk]=psf_posx;
                        w[kk]=1.0;

                        // je memorise le resultat de l'analyse
                        result_lambda[nb_analyse]=lambda; 
                        result_position[nb_analyse]=psf_posx; 
                        result_flag[nb_analyse] = 1;

                        kk++;  
                        if (kk > MAX_LINES) {
                           kk--;
                           break;
                        }                        
                     } else {
                       // je memorise le resultat de l'analyse
                        result_lambda[nb_analyse]=lambda; 
                        result_position[nb_analyse]=psf_posx; 
                        result_flag[nb_analyse] = -2;
                     }
                  } else {   // premi�re it�ration                  
                     sfwhm=sfwhm+fwhm; 
                     table_lambda[kk]=lambda;
                     position[kk]=psf_posx;
                     w[kk]=1.0; 

                     kk++;
                     if (kk > 500) {
                        kk--;
                        break;
                     }   
                  }
               } else {
                  // je memorise le resultat de l'analyse
                  result_lambda[nb_analyse]=lambda;
                  result_position[nb_analyse]=pos;
                  result_flag[nb_analyse] = 0; 
               }
               nb_analyse++;
            }
         }

         if ( kk < 2 ) {
            char message[1024];
            sprintf(message, " %d lines detected on order %d. Must be >=2 lines.",kk,n);
            throw ::std::exception(message);
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
            // on ajuste ordre 3 
            fitPoly(kk,3,position,table_lambda,w,a,&rms); 
         }         
      }  // fin for nb_iter
      
      // je copie le polynome dans les parametres de l'ordre
      ordre[n].a0=a[0];
      ordre[n].a1=a[1];
      ordre[n].a2=a[2];
      ordre[n].a3=a[3];
      ordre[n].rms_calib_spec=rms;
      ordre[n].fwhm=sfwhm/(double)kk;
      // on reboucle sur la liste des raies pour trouver les ecarts O-C (observe - calcule)
      for (int i=0;i<nb_analyse;i++)
      {
         LINE_GAP lineGap;
         lineGap.order  = n;
         lineGap.l_obs  = result_lambda[i];
         lineGap.valid  = result_flag[i];

         double lambda_estime = 0.0;
         for (int index = 0; index <= calib_degre; index++) {
            lambda_estime = lambda_estime + a[index] * pow(result_position[i], (double)index);
         }
         lineGap.l_calc = lambda_estime;
         lineGap.l_diff = result_lambda[i] - lambda_estime;
         lineGap.l_posx = result_position[i]+(double)ordre[n].min_x;
         
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
      // je calcule la resolution
      ordre[n].resolution = ordre[n].central_lambda/(ordre[n].disp*ordre[n].fwhm);
      // je stocke le nombre de raies reconnues
      ordre[n].nb_lines=kk;  // nouveaut� v1.4
      
   } catch (std::exception &e) {
      // rien a desallouer
      throw e;
   } 

}


/********************************* CALIB_SPEC *********************************/
/* Calibration spectrale de l'ordre n (calcul des polynomes de dispersion)    */
/* La position approximative des raies est calcul�e avec la formule du r�seau */
/* V1.4 -> retourne le nombre de raies retenues + nombre it�ration            */
/******************************************************************************/

/*************************** MAKE_INTERPOL *****************************/
/* On re-interpolle le spectre table_in avec un polynome de degr� 3    */
/* dont les coefficient sont donn� en param�tres. Le pas du spectres   */
/* r�sultat est donn� par la variable pas. Le r�sutat est le profil    */
/* spectral nom_out.                                                   */
/* On normalise les intensit� au point max.                            */
/***********************************************************************/
int make_interpol(std::valarray<double> &table_in, 
                  double coef3,double coef2,double coef1,double coef0,
                  double pas, std::valarray<double> &table_out, double *lambda1)
{
   int taille0;
   double x,max;
   double *rx = NULL;
   double *ry = NULL;
   double *a = NULL;
   double *b = NULL;
   double *c = NULL;
   double *result = NULL;
   double *lamb = NULL;

   try {
      int taille = table_in.size();
      rx = new double[taille];
      ry = new double[taille];
      a  = new double[taille];
      b  = new double[taille];
      c  = new double[taille];
      lamb = new double[taille];

      // Associe une longueur d'onde � chaque pixel
      for (int i=0;i<taille;i++) {
         x=(double)i;
         lamb[i]=coef3*x*x*x + coef2*x*x + coef1*x + coef0;
         if ( lamb[i] > 20000) {
            char message[1024];
            sprintf(message, "Error make_interpol Invalid Lambda > 20000 coef0=%f coef1=%f coef2=%f coef3=%f",coef0,coef1,coef2,coef3);
            throw ::std::exception(message);
         }
      }

      // Calcul des coefficients de spline
      for (int i=0;i<taille;i++)
         {
         rx[i]=lamb[i];
         ry[i]=table_in[i];
         }
      spline(taille,rx,ry,a,b,c);

      // Calcul de la taille du profil de sortie
      taille0=taille;
      taille=int((lamb[taille0-1]-lamb[0])/pas);
      result = new double[taille];
      table_out.resize(taille);

      // Interpollation spline 
      double lambda0=(double)((int)lamb[0]+1);  // on commence par un nombre entier (juste sup�rieur)
      for (int i=0;i<taille;i++)
         {
         x=lambda0+(double)i*pas;
         if (x<lamb[0] || x>lamb[taille0-1])
            result[i]=0.0;
         else
            result[i]=seval(taille0,x,rx,ry,a,b,c);
         }

      // Recherche de la valeur max dans le profil
      max=-1e10;
      for (int i=0;i<taille;i++)
         {
         if (result[i]>max) max=result[i];
         }

      //  je calcule la taille du profil resultat
      if ( taille-2 < (lamb[taille0-1]-lambda0)/pas ) {
         table_out.resize(taille-2);
      } else {
         table_out.resize(int((lamb[taille0-1]-lambda0)/pas));
      }
      //  Sauvegarde du profil
      for (int i=1;i<taille-1;i++) {         
         x=lambda0+(double)i*pas;
         if (x>lamb[taille0-1]) break;  // on ne couvre que le domaine spectral d'entr�e
         table_out[i-1]= result[i]/max;
      }
      *lambda1 =lambda0+pas;

      delete [] rx;
      delete [] ry;
      delete [] a;
      delete [] b;
      delete [] c;
      delete [] lamb;
      delete [] result;
   } catch (std::exception &e) {
      delete [] rx;
      delete [] ry;
      delete [] a;
      delete [] b;
      delete [] c;
      delete [] lamb;
      delete [] result;
      throw e;
   }

   return 0;
}

/*************************** INTERPOL_SPEC ****************************/
/* Interpolle un profil spectral � partir de coefficients de          */
/* dispersion polynomiaux (degr�s 3).                                 */
/* L'ordre du profil trait� est n.                                    */
/* Le profil d'entr�e est n_entree, le profil de sortie est n_sortie. */
/**********************************************************************/
void Eshel_interpolProfile(char *fileName)
{
   CCfits::PFitsFile pFits = NULL;
   PIC_TYPE * tampon = NULL;;
   ORDRE *ordre = NULL;
   double *profile = NULL;
   INFOSPECTRO spectro;
   double dx_ref=0.0;

   try {
      pFits = Fits_openFits(fileName, true);
      // je lis les parametres spectro 
      Fits_getInfoSpectro(pFits, &spectro);
      // je lis les parametres des ordres
      int nbOrder = spectro.max_order - spectro.min_order +1;
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pFits, ordre,&dx_ref);

      for (int n=spectro.min_order;n<=spectro.max_order;n++) {
         if (ordre[n].flag==1) {
            double lambda1; 
            std::valarray<double> rawProfile;
            std::valarray<double> linProfile;
            double step=0.1;
            int min_x; 
            // je recupere le profil brut
            Fits_getRawProfile(pFits, "P_1A_",n,rawProfile, &min_x); 
            // j'echantillone lineairement le profil
            make_interpol(rawProfile,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0,step,linProfile, &lambda1);
            // j'enregistre le profil dans le fichier
            Fits_setLinearProfile(pFits, "P_1B_",n,linProfile, lambda1, step) ;
         }
      }
      delete [] ordre;
      delete [] profile;
      Fits_closeFits(pFits);
   } catch (std::exception &e) {
      delete [] ordre;
      delete [] profile;
      Fits_closeFits(pFits);
      throw e;
   }
}

/******************************** MERGE_SPECTRE ********************************/
/* Met bout � bout deux ordres contigues (nom1) et (nom2), et produit le       */
/* le profil spectral mosa�que (out).                                          */
/* La zone commun est utilis� pour harmoniser les intensit�s.                  */
/* On calcule l'intensit� moyenne dans les zones communes (pas de pond�ration) */
/*******************************************************************************/ 
void merge_spectre(::std::valarray<double> &value1, double lambda1, double step1, 
                   ::std::valarray<double> &value2, double lambda2, double step2, 
                   ::std::list<double> &joinProfile)
{
   int i,j;
   int nb1,nb2;
   double v;
   
   nb1 = value1.size();
   nb2 = value2.size();

   double *wave1 = new double[nb1];
   double *wave2 = new double[nb2];

   for(int i=0; i<nb1; i++ ) { wave1[i] = lambda1 + step1*i; }
   for(int i=0; i<nb2; i++ ) { wave2[i] = lambda2 + step2*i; }

   double s1=0.0;
   double s2=0.0;
   for (i=0;i<nb1;i++)
      {
      for (j=0;j<nb2;j++)
         {
         if ((int)(100.0*wave1[i])==(int)(100.0*wave2[j]))
            {
            s1=s1+value1[i];
            s2=s2+value2[j];
            }       
         } 
      }

   double coef=s1/s2;

   int flag;
   for (i=0;i<nb1;i++)
      {
      flag=0;
      for (j=0;j<nb2;j++)
         {
         if ((int)(100.0*wave1[i])==(int)(100.0*wave2[j]) && value1[i]!=-32000.0 && value2[j]!=-32000.0)  // zone commune
            {
            v=(value1[i]+value2[j]*coef)/2.0;
            value1[i]=-32000.0;
            value2[j]=-32000.0;
            flag=1;
            }
         }
      if (flag==0)
         { 
         joinProfile.push_back(value1[i]); 
         }
      else
         { 
         joinProfile.push_back(v); 
         }
      }
   for (i=0;i<nb2;i++)
      {
      if (value2[i]!=-32000.0)
         {
         joinProfile.push_back(value2[i]*coef);
         }
      }

   delete wave1;
   delete wave2;
}


/******************************** MERGE_SPECTRE2 *******************************/
/* Met bout � bout deux ordres contigues (nom1) et (nom2), et produit le       */
/* le profil spectral mosa�que (out).                                          */
/* La zone commun est utilis� pour harmoniser les intensit�s.                  */
/* On calcule une intensit� pond�r�e dans les zones communes                   */
/*******************************************************************************/ 
void merge_spectre2(::std::valarray<double> &value1, double lambda1, double step1, 
                    ::std::valarray<double> &value2, double lambda2, double step2, 
                    ::std::valarray<double> &value_flat1, double lambdaFlat1, double stepFlat1, 
                    ::std::valarray<double> &value_flat2, double lambdaFlat2, double stepFlat2, 
                    ::std::list<double> &joinProfile)
{
   int i,j,k;
   int nb1,nb2,nbflat1,nbflat2;
   double v;
   
   nb1 = value1.size();
   nb2 = value2.size();
   nbflat1 = value_flat1.size();
   nbflat2 = value_flat2.size();

   double *wave1 = new double[nb1];
   double *wave2 = new double[nb2];
   double *wave_flat1 = new double[nbflat1];
   double *wave_flat2 = new double[nbflat2];

   for(int i=0; i<nb1; i++ ) { wave1[i] = lambda1 + step1*i; }
   for(int i=0; i<nb2; i++ ) { wave2[i] = lambda2 + step2*i; }
   for(int i=0; i<nbflat1; i++ ) { wave_flat1[i] = lambdaFlat1 + stepFlat1*i; }
   for(int i=0; i<nbflat2; i++ ) { wave_flat2[i] = lambdaFlat2 + stepFlat2*i; }

   // Calcul du ratio des deux spectres dans la zone de recouvrement
   double s1=0.0;
   double s2=0.0;
   for (i=0;i<nb1;i++)
   {
      for (j=0;j<nb2;j++)
      {
         if ((int)(100.0*wave1[i])==(int)(100.0*wave2[j]))
         {
            s1=s1+value1[i];
            s2=s2+value2[j];
         }       
      } 
   }

   double coef=s1/s2;
   int flag;
   for (i=0;i<nb1;i++)
   {
      flag=0;
      for (j=0;j<nb2;j++)
      {
         if ((int)(100.0*wave1[i])==(int)(100.0*wave2[j]) && value1[i]!=-32000.0 && value2[j]!=-32000.0)  // zone commune
         {
            // on recherche le niveau dans flat1 pour la longueur d'onde correspondante
            double p1=1.0;    // poids par d�faut
            for (k=0;k<nbflat1;k++)
            {
               if ((int)(100.0*wave1[i])==(int)(100.0*wave_flat1[k])) p1=value_flat1[k];
            } 
            // on recherche le niveau dans flat2 pour la longueur d'onde correspondante
            double p2=1.0;    // poids par d�faut
            for (k=0;k<nbflat2;k++)
            {
               if ((int)(100.0*wave2[j])==(int)(100.0*wave_flat2[k])) p2=value_flat2[k];
            } 
            double pp=p1+p2; // on normalise la fonction de poids
            p1=p1/pp;
            p2=p2/pp;
            double norme=p1*p1+p2*p2;
            v=(value1[i]*p1*p1+coef*value2[j]*p2*p2)/norme; // somme pond�r�e (au sens des moindes carr�s)

            value1[i]=-32000.0;
            value2[j]=-32000.0;
            flag=1;
         }
      }
      if (flag==0) { 
         joinProfile.push_back(value1[i]); 
      } else { 
         joinProfile.push_back(v); 
      }
   }
   for (i=0;i<nb2;i++)
   {
      if (value2[i]!=-32000.0)
      {
         joinProfile.push_back(value2[i]*coef);
      }
   }

   delete wave1;
   delete wave2;
   delete wave_flat1;
   delete wave_flat2;
}

/*********************************** ABOUTE_SPECTRES *************************************/
/* Aboute les ordres 32, 33, 34, 35, 36, 37 et 38 -> zone couverte par les raies du n�on */
/* Le r�sultat est un spectre ayant pour nom objet_full0.dat                             */
/*****************************************************************************************/
/*
void aboute_spectres(int max_ordre,int min_ordre,char *objectName,char *calibName,char *nom_out,int useFlat)
{
   CCfits::PFitsFile calibFits = NULL;
   CCfits::PFitsFile objectFits = NULL;
   CCfits::PFitsFile outFits = NULL;

   try {
      objectFits = Fits_openFits(objectName, true);
      if (useFlat==0)
      {
         abut1bOrder(max_ordre,min_ordre,objectFits);
      }
      else
      {
         calibFits = Fits_openFits(calibName, false);
         abut1bOrder(max_ordre,min_ordre,objectFits,calibFits);
         //j'enregistre le resultat dans le fichier de sortie 
      }


      if ( nom_out != NULL) {
         //j'enregistre le resultat dans le fichier de sortie independant
         ::std::valarray<double> value1;
         double lambda1;
         double step1;
         Fits_getFullProfile(objectFits,"P_1B_FULL",value1, &lambda1, &step1);
         outFits = Fits_createFits(nom_out,value1,lambda1, step1);
         Fits_closeFits(outFits);
      }
   }
   catch (::std::exception &e) {
      Fits_closeFits(outFits);
      Fits_closeFits(objectFits);
      Fits_closeFits(calibFits);
      throw e;
  }
}
*/

/*********************************** abut1bOrder ************************************
* Aboute les ordres des profils calibr�s 
* 
* @param 
*/
void abut1bOrder(int max_ordre,int min_ordre,CCfits::PFitsFile objectFits, char *hduName)
{
   try {
      ::std::list<double> mergeProfile;
      ::std::valarray<double> value1;
      ::std::valarray<double> value2;
      double step1, step2;
      double lambda1, lambda2;

      // je recupere le premier ordre (max_ordre)
      Fits_getLinearProfile(objectFits, "P_1B_", max_ordre, value1, &lambda1, &step1);

      for (int n=max_ordre-1;n>=min_ordre;n--) {
         // je recupere l'ordre suivant
         Fits_getLinearProfile(objectFits, "P_1B_", n, value2, &lambda2, &step2);
         // j'aboute les 2 profils
         merge_spectre(value1, lambda1, step1,
            value2, lambda2, step2, 
            mergeProfile);
         // je copie le resultat dans value1
         value1.resize(mergeProfile.size());
         ::std::list <double> ::iterator iter;
         size_t i = 0;
         for (iter= mergeProfile.begin(); iter != mergeProfile.end(); iter++ ) {
            value1[i++] = *iter; 
         }
         mergeProfile.clear();
      }
      // j'enregistre le profil aboute 
      Fits_setFullProfile(objectFits,"P_1B_FULL",value1,lambda1, step1);     
   }
   catch (::std::exception &e) {
      Fits_closeFits(objectFits);
     throw e;
  }
}

/*********************************** abutOrderWithFlat *************************************/
/* Aboute les ordres 32, 33, 34, 35, 36, 37 et 38 -> zone couverte par les raies du n�on */
/*                         */
/*****************************************************************************************/
void abut1bOrder(int max_ordre,int min_ordre,CCfits::PFitsFile objectFits, CCfits::PFitsFile calibFits, char *hduName )
{
   try {
      
      ::std::list<double> mergeProfile;
      ::std::valarray<double> value1;
      ::std::valarray<double> value2;
      ::std::valarray<double> valueFlat1;
      ::std::valarray<double> valueFlat2;
      double step1, step2, stepFlat1, stepFlat2;
      double lambda1, lambda2, lambdaFlat1, lambdaFlat2;

      int savedMaxOrdre = max_ordre;         
      do {
         try {
            // je recupere le premier ordre (max_ordre)         
            Fits_getLinearProfile(objectFits, "P_1B_", max_ordre, value1, &lambda1, &step1);
         } catch  (::std::exception &e) {
            // si le profil n'existe pas , je decremente max_ordre pour essayer avec le suivant
            e.what();
            max_ordre--; 
         }
      } while (value1.size() == 0 && max_ordre > min_ordre +1); 

      if (value1.size() == 0 ) {
         // aucun profil n'existe
         char message [1024] ; 
         sprintf(message,"No profile found from min_order=%d to max_order=%d", min_ordre, max_ordre);
         throw ::std::exception(message);
      }

      for (int n=max_ordre-1;n>=min_ordre;n--) {
         // je recupere l'ordre suivant du flat
         Fits_getLinearProfile(calibFits, "FLAT_1B_", n+1, valueFlat1, &lambdaFlat1, &stepFlat1);
         try {
            // je recupere l'ordre suivant
            Fits_getLinearProfile(objectFits, "P_1B_", n, value2, &lambda2, &step2);
         } catch  (::std::exception &e) {
            // si le profil suivant n'existe pas, j'arrete d'abouter les profils 
            // et j'enregistre le profil FULL tel quel.
            e.what();
            break;
         }

         Fits_getLinearProfile(calibFits, "FLAT_1B_", n, valueFlat2, &lambdaFlat2, &stepFlat2);
         // j'aboute les 2 profils
         merge_spectre2(value1, lambda1, step1,
            value2, lambda2, step2, 
            valueFlat1, lambdaFlat1, stepFlat1, 
            valueFlat2, lambdaFlat2, stepFlat2, 
            mergeProfile);
         // je copie le resultat dans value1
         value1.resize(mergeProfile.size());
         ::std::list <double> ::iterator iter;
         size_t i = 0;
         for (iter= mergeProfile.begin(); iter != mergeProfile.end(); iter++ ) {
            value1[i++] = *iter; 
         }
         mergeProfile.clear();
      }
      //j'enregistre le resultat dans le fichier d'entree
      Fits_setFullProfile(objectFits,hduName,value1,lambda1, step1);
   }
   catch (::std::exception &e) {
      throw e;
   }
}

/*********************************** abut1cOrder ************************************
* Aboute les ordres des profils calibr�s 
* 
* @param 
*/
void abut1cOrder(int max_ordre,int min_ordre,CCfits::PFitsFile objectFits, char * hduName)
{
   try {
      ::std::list<double> mergeProfile;
      ::std::valarray<double> value1;
      ::std::valarray<double> value2;
      double step1, step2;
      double lambda1, lambda2;

      do {
         try {
            // je recupere le premier ordre (max_ordre)         
            Fits_getLinearProfile(objectFits, "P_1C_", max_ordre, value1, &lambda1, &step1);
         } catch  (::std::exception &e) {
            // si le profil n'existe pas , je decremente max_ordre pour essayer avec le suivant
            e.what();
            max_ordre--; 
         }
      } while (value1.size() == 0 && max_ordre > min_ordre +1); 

      for (int n=max_ordre-1;n>=min_ordre;n--) {
         // je recupere l'ordre suivant
         Fits_getLinearProfile(objectFits, "P_1C_", n, value2, &lambda2, &step2);
         // j'aboute les 2 profils
         merge_spectre(value1, lambda1, step1,
            value2, lambda2, step2, 
            mergeProfile);
         // je copie le resultat dans value1
         value1.resize(mergeProfile.size());
         ::std::list <double> ::iterator iter;
         size_t i = 0;
         for (iter= mergeProfile.begin(); iter != mergeProfile.end(); iter++ ) {
            value1[i++] = *iter; 
         }
         mergeProfile.clear();
      }
      // j'enregistre le profil aboute 
      Fits_setFullProfile(objectFits,hduName,value1,lambda1, step1);     
   }
   catch (::std::exception &e) {
      throw e;
   }
}



/*********************************** ABOUTE_SPECTRES *************************************/
/* Aboute les ordres 32, 33, 34, 35, 36, 37 et 38 -> zone couverte par les raies du n�on */
/* Le r�sultat est un spectre ayant pour nom objet_full0.dat                             */
/*****************************************************************************************/
int aboute_spectres2(char *nom_objet,char *nom_flat,char *nom_out,int useFlat)
{
/*
char nom1[_MAX_PATH],nom2[_MAX_PATH],nom3[_MAX_PATH];
char nom_f1[_MAX_PATH],nom_f2[_MAX_PATH];
sprintf(nom3,"%s_full0",nom_objet);

if (useFlat==0)
   {
   sprintf(nom1,"%s_%d",nom_objet,50);
   sprintf(nom2,"%s_%d",nom_objet,49);
   if (merge_spectre(nom1,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,48);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;n
   sprintf(nom2,"%s_%d",nom_objet,47);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,46);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,45);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,44);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,43);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,42);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,41);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,40);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,39);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,38);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,37);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,36);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,35);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,34);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,33);
   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

//   sprintf(nom2,"%s_%d",nom_objet,32);
//   if (merge_spectre(nom3,nom2,nom3)==1) return 1;

//   sprintf(nom2,"%s_%d",nom_objet,31);
//   if (merge_spectre(nom3,nom2,nom3)==1) return 1;
   }
else
   {
   sprintf(nom1,"%s_%d",nom_objet,50);
   sprintf(nom2,"%s_%d",nom_objet,49);
   sprintf(nom_f1,"%s_%d",nom_flat,50);
   sprintf(nom_f2,"%s_%d",nom_flat,49);
   if (merge_spectre2(nom1,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,48);
   sprintf(nom_f1,"%s_%d",nom_flat,49);
   sprintf(nom_f2,"%s_%d",nom_flat,48);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,47);
   sprintf(nom_f1,"%s_%d",nom_flat,48);
   sprintf(nom_f2,"%s_%d",nom_flat,47);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,46);
   sprintf(nom_f1,"%s_%d",nom_flat,47);
   sprintf(nom_f2,"%s_%d",nom_flat,46);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,45);
   sprintf(nom_f1,"%s_%d",nom_flat,46);
   sprintf(nom_f2,"%s_%d",nom_flat,45);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,44);
   sprintf(nom_f1,"%s_%d",nom_flat,45);
   sprintf(nom_f2,"%s_%d",nom_flat,44);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,43);
   sprintf(nom_f1,"%s_%d",nom_flat,44);
   sprintf(nom_f2,"%s_%d",nom_flat,43);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,42);
   sprintf(nom_f1,"%s_%d",nom_flat,43);
   sprintf(nom_f2,"%s_%d",nom_flat,42);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,41);
   sprintf(nom_f1,"%s_%d",nom_flat,42);
   sprintf(nom_f2,"%s_%d",nom_flat,41);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,40);
   sprintf(nom_f1,"%s_%d",nom_flat,41);
   sprintf(nom_f2,"%s_%d",nom_flat,40);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,39);
   sprintf(nom_f1,"%s_%d",nom_flat,40);
   sprintf(nom_f2,"%s_%d",nom_flat,39);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,38);
   sprintf(nom_f1,"%s_%d",nom_flat,39);
   sprintf(nom_f2,"%s_%d",nom_flat,38);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,37);
   sprintf(nom_f1,"%s_%d",nom_flat,38);
   sprintf(nom_f2,"%s_%d",nom_flat,37);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,36);
   sprintf(nom_f1,"%s_%d",nom_flat,37);
   sprintf(nom_f2,"%s_%d",nom_flat,36);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,35);
   sprintf(nom_f1,"%s_%d",nom_flat,36);
   sprintf(nom_f2,"%s_%d",nom_flat,35);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,34);
   sprintf(nom_f1,"%s_%d",nom_flat,35);
   sprintf(nom_f2,"%s_%d",nom_flat,34);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,33);
   sprintf(nom_f1,"%s_%d",nom_flat,34);
   sprintf(nom_f2,"%s_%d",nom_flat,33);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,32);
   sprintf(nom_f1,"%s_%d",nom_flat,33);
   sprintf(nom_f2,"%s_%d",nom_flat,32);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;

   sprintf(nom2,"%s_%d",nom_objet,31);
   sprintf(nom_f1,"%s_%d",nom_flat,32);
   sprintf(nom_f2,"%s_%d",nom_flat,31);
   if (merge_spectre2(nom3,nom2,nom_f1,nom_f2,nom3)==1) return 1;
// buil3
   }
*/
return 0;
}

/********************** COMPUTE_BLACK_BODY ***********************/
/* Retourne l'�mittance d'un corps noir en w/cm2/micron          */
/*****************************************************************/
double compute_black_body(double lambda,double temperature)
{
double c1=3.739876e4;
double c2=1.438769e4;
double v;

lambda=lambda/10000.0; // conversion des A en microns
v=c1/pow(lambda,5.0)*(1.0/(exp(c2/lambda/temperature)-1));
return v;
}

/********************************* PLANCK_CORRECT *********************************/
/* Mutiplie le profil d'entr�e (in) par la courbe du corps noir pour              */
/* la temp�rature (en K) donn� en param�tre. Le profil r�sultat est (out).        */
/* Utile pour compenser la temp�rature de couleur de la lampe tungst�ne utilis�e  */
/* pour r�aliser le flat-field.                                                   */
/**********************************************************************************/
void planck_correct(char *fileNameIn, char *fileNameOut, double temperature)
{
   double wave,coef,norme;
   ::std::valarray<double> valueIn;
   ::std::valarray<double> valueOut;
   double lambda1, step1;
   int nb1;
   CCfits::PFitsFile inFits = NULL;
   CCfits::PFitsFile outFits = NULL;

   try {
      inFits = Fits_openFits(fileNameIn, true);
      // je recupere le profil
      Fits_getFullProfile(inFits, "P_FULL0", valueIn, &lambda1, &step1);      
      
      // Premi�re passe pour calculer la norme � 6690 A 
      // (zone sans raies dans le spectre solaire)
      nb1 = valueIn.size();
      norme=1.0;
      for(int i=0; i<nb1; i++ ) { 
         wave = lambda1 + step1*i; 
         if ((int)(100.0*wave)==669000) {
            coef=compute_black_body(wave,temperature);
            norme=valueIn[i]*coef;
         }
      }

      // Deuxi�me passe et �criture du fichier trait�
      valueOut.resize(valueIn.size());
      for(int i=0; i<nb1; i++ ) { 
         wave = lambda1 + step1*i; 
         coef=compute_black_body(wave,temperature);
         valueOut[i] =  valueIn[i]*coef/norme;         
      }

      //j'enregistre le resultat dans le fichier d'entree 
      Fits_setFullProfile(inFits, "P_FULL", valueOut, lambda1, step1);      
      Fits_closeFits(inFits);

      //j'enregistre le profile  dans un fichier de sortie a part
      if ( fileNameOut != NULL) {
         outFits = Fits_createFits(fileNameOut, valueOut, lambda1, step1);
         Fits_closeFits(outFits);
      }
   }
   catch (::std::exception &e) {
      Fits_closeFits(inFits);
      Fits_closeFits(outFits);
      throw e;
   }
}

/************************ HMEDIAN ****************************/
/* Retourne la valeur m�diane d'un �chantillon RA de n point */
/* Attention : l'�chantillon est trie apr�s excecution       */
/*************************************************************/
PIC_TYPE hmedian(PIC_TYPE *ra,int n)
{
int l,j,ir,i;
PIC_TYPE rra;

if (n<2)
   return *ra;
ra--;
for (l=((ir=n)>>1)+1;;)
   {
   if (l>1)
      rra=ra[--l];
   else
      {
      rra=ra[ir];
      ra[ir]=ra[1];
      if (--ir==1)
	 {
	 ra[1]=rra;
	 return n&1? ra[n/2+1] : (PIC_TYPE)(((double)ra[n/2]+(double)ra[n/2+1])/2.0);
	 }
      }
   for (j=(i=l)<<1;j<=ir;)
     {
     if (j<ir && ra[j]<ra[j+1]) ++j;
     if (rra<ra[j])
	{
	ra[i]=ra[j];
	j+=(i=j);
	}
     else
	j=ir+1;
     }
   ra[i]=rra;
   }
/* (le 'return' n'est pas � la fin de la boucle et c'est normal !) */
}

/******************* INTPOWER ********************/
/* Calcule x � la puissance d'un nombre entier   */
/*************************************************/
double intPower(double x,int const_val)
{
double sum;
int i;
int neg;

neg=(const_val < 0 ? 1 : 0);
const_val*=(neg ? -1 : 1);

sum=1.0;
for (i=0;i<const_val;++i) sum*=x;
return (neg ? 1 / sum : sum);
}

/*************************** LINCHOLESKYDECOMP *************************/
/* R�soud le syst�me Ax = b via une d�composition de Cholesky          */
/*                                                                     */
/* Retourne  0 = si succ�s,                                            */
/*           k = la kth colonne o� une singularit�e est trouv�e.       */
/*                                                                     */ 
/* Maxdim => Max. dimension de la matrice "A" declared in main.        */
/* order => order de la matrice matrix "A".                            */
/*                   a => matrice sym�trique positive                  */
/*                   b => vecteur de droite                            */
/* En sortie :                                                         */
/*                   b => vecteur solution (calcul� en place)          */
/***********************************************************************/
#undef A
#define A(X,Y) *(a+(X)*dim+(Y))

int linCholeskyDecomp(int dim,int order,double *a,double *b)
{
   double t,s,temp2;
   int info,l,j,jm1,k,kb;

   if (order>dim) return 1;

   for (j=0;j<order;++j)
   {
      info=j+1;
      s=0.0;
      jm1=j-1;
      if (jm1>=0)
      {
         for (k=0;k<=jm1;++k)
         {
            temp2=0.0;
            for (l=0;l<=k-1;++l)
            {
               if ( l >4 ) { 
                  printf( "linCholeskyDecomp l=%d\n",l);
               }
               temp2+=A(l,k)*A (l,j);
            }
            if ( j >4 ) { 
               printf( "linCholeskyDecomp j=%d\n",j);
            }
            if ( k >4 ) { 
               printf( "linCholeskyDecomp k=%d\n",k);
            }

            t=A(k,j)-temp2;
            if ( A(k,k) == 0 ) { 
               printf( "linCholeskyDecomp 1a A(%d,%d)=0\n",k,k);
            }

            t/=A(k,k);
            A(k,j)=t;
            s+=t*t;
         }
      }
      s=A(j,j)-s;
      if (s<=0.0) return info;
      A(j,j)=sqrt(s);
   }

   for (k=0;k<order;++k)
   {
      temp2=0.0;
      for (l=0;l<=k-1;++l)
      {
         temp2+=A(l,k)*b[l];
      }
      t=temp2;
      if ( A(k,k) == 0 ) { 
         printf( "linCholeskyDecomp 1 A(%d,%d)=0\n",k,k);
      }

      b[k]=(b[k]-t)/A(k,k);
   }

   //printf( "linCholeskyDecomp a[3]=%d ",b[3]);
   for (kb=0;kb<order;++kb)
   {
      k=order-kb-1;
      if ( A(k,k) == 0 ) { 
         printf( "linCholeskyDecomp 2 A(%d,%d)=0",k,k);
      }

      b[k]/=A(k,k);
      t=-b[k];
      for (l=0;l<=k-1;++l) b[l]+=t*A(l,k);
   }
   //printf( "  %d\n",b[3]);
   return 0;
}

/**************************** FITPOLY ****************************/
/* R�gression polynomiale                                        */
/*                                                               */
/* On donne le jeu de points (x,y) et le poids de chaque point.  */
/* Retourne les coefficients (a0,a1) de l'�quation :             */
/*             y[i] = a0 + a1 * x[i] + a2 * x[i]^2               */
/* et l'erreur RMS de la r�gression                              */
/*                                                               */ 
/* Param�tres d'entr�e :                                         */
/*                  n     => nombre de paires (x,y)              */
/*                 degree => degr� du polyn�me                   */
/*                  (x,y) => tableau de donn�es                  */
/*                  w     => poids de chaque points              */
/* Param�tres de sortie :                                        */ 
/*                  a[i]  => tableau des coefficients            */
/*                  rms   => erreur RMS                          */
/*****************************************************************/
#undef A
#define A(I,J) *(a+(I)*degplus1+(J))

void fitPoly(int numpts,int degree,double *x,double *y,double *wt,double *coeffs,double *rms)
{
   int i,j,k,flag;
   double *a;
   int degplus1;
   double valu1,valu2,linBasisFunc (),ypred,err;

   degplus1=degree+1;
   if ((a=(double *)calloc(degplus1*degplus1,sizeof(double)))==NULL)
   {
      throw std::exception("Pas assez de memoire pour fitPoly()");
   }

   for (i=0;i<=degree;++i)
   {
      for (j=i;j<=degree;++j) A(i,j)=0.0;
      coeffs[i]=0.0;
   }

   for (i=0;i<numpts;++i)
   {
      for (j=0;j<= degree;++j)
      {
         valu1=intPower(x[i],j);
         for (k=j;k<=degree;++k)
         {
            valu2=intPower(x[i],k);
            if ( j >degree ) { 
               printf( "fitPoly j=%d\n",j);
            }
            if ( k >degree ) { 
               printf( "fitPoly k=%d\n",k);
            }
            A(j,k)+=valu1*valu2*wt[i];
         }
         coeffs[j]+=y[i]*valu1*wt[i];
      }
   }

   flag=linCholeskyDecomp(degplus1,degplus1,a,coeffs);
   if (flag==1) 
   {
      throw std::exception("Erreur linCholeskyDecomp");
   }

   *rms=0.0;
   for (i=0;i<numpts;++i)
   {
      ypred = coeffs[0];
      for (j=1;j<=degree;++j) ypred+=coeffs[j]*intPower(x[i],j);
      err=ypred-y[i];
      *rms+=err*err;
   }

   if (numpts<=degplus1)
      *rms=sqrt(*rms/numpts);
   else
      *rms=sqrt(*rms/(numpts-(degplus1)));

   free(a);
}

/******************** SPLINE ***********************/
/* Calcul des coefficients de spline               */
/* A utiliser avec SEVAL pour faire                */
/* l'interpolation spline                          */
/* Les data sont dans (x,y) (premier indice est 0) */
/* Les tables b, c, d contiennent les              */
/* coefficients de spline                          */
/***************************************************/
int spline(int n,double *x,double *y,double *b,double *c,double *d)
{
int i,ip1,nm1,nm2,nm3,nm4,ib;
double t;
nm1=n-1;
nm2=n-2;
nm3=n-3;
nm4=n-4;
if (n<2) return 1;
if (n<3) goto L50;
d[0]=x[1]-x[0];
c[1]=(y[1]-y[0])/d[0];
for (i=1;i<nm1;i++)
   {
   ip1=i+1;
   d[i]=x[ip1]-x[i];
   b[i]=2.0*(d[i-1]+d[i]);
   c[ip1]=(y[ip1]-y[i])/d[i];
   c[i]=c[ip1]-c[i];
   }
b[0]=-d[0];
b[nm1]=-d[nm2];
c[0]=0.0;
c[nm1]=0.0;
if (n!=3)
   {
   c[0]=c[2]/(x[3]-x[1])-c[1]/(x[2]-x[0]);
   c[nm1]=c[nm2]/(x[nm1]-x[nm3])-c[nm3]/(x[nm2]-x[nm4]);
   c[0]*=d[0]*d[0]/(x[3]-x[0]);
   c[nm1]*=-d[nm2]*d[nm2]/(x[nm1]-x[nm4]);
   }
for (i=0;i<nm1;i++)
   {
   ip1=i+1;
   t=d[i]/b[i];
   b[ip1]-=t*d[i];
   c[ip1]-=t*c[i];
   }
c[nm1]/=b[nm1];
for (ib=1;ib<=nm1;ib++)
   {
   i=n-ib-1;
   c[i]=(c[i]-d[i]*c[i+1])/b[i];
   }
b[nm1]=(y[nm1]-y[nm2])/d[nm2]+d[nm2]*(c[nm2]+2.0*c[nm1]);
for (i=0;i<nm1;i++)
   {
   ip1=i+1;
   b[i]=(y[ip1]-y[i])/d[i]-d[i]*(c[ip1]+2.0*c[i]);
   d[i]=(c[ip1]-c[i])/d[i];
   c[i]=3.0*c[i];
   }
c[nm1]*=3.0;
d[nm1]=d[nm2];
return 0;
L50: ;
b[0]=(y[1]-y[0])/(x[1]-x[0]);
c[0]=0.0;
d[0]=0.0;
b[1]=b[0];
c[1]=0.0;
d[1]=0.0;
return 0;
}

/****************** SEVAL *******************/
/* Interpolation spline                     */
/* u = coordonn�e du point � interpoler     */
/* Retourne la valeur interpol�e            */
/********************************************/
double seval(int n,double u,double *x,double *y,double *b,double *c,double *d)
{
int j,k,im1,i;
double s,dx;

i=1;
if (i>=n) i=1;
if (u<x[i-1]) goto L10;
if(u<=x[i]) goto L30;

L10: ;
i=1;
j=n+1;
do
   {
   k=(i+j) >> 1;
   if (u<x[k-1]) j=k;
   if (u>=x[k-1]) i=k;
   } while(j>(i+1));

L30: ;
im1=i-1;
dx=u-x[im1];
s=y[im1]+dx*(b[im1]+dx*(c[im1]+dx*d[im1]));
return(s);
}

/***************************** SPEC_GAUSS ******************************/
/* Ajuste le profil par une gaussienne dans un profil                  */
/* La fen�tre de calcul est centr�e sur pos et de la largeur wide      */
/* La taille du vecteur analys� est taille.                            */
/* Le vecteur est point� par buf. Le r�sultat est retrourn� dans pos_x */                        
/***********************************************************************/
int spec_gauss(int pos,int wide,std::valarray<double> &buf,double *pos_x,double *fwhm,double *ecartType)
{
   double profil[512];
   double py[4];
   double ecarty;
   int i;


   int w2=wide/2;

   int n=0;
   for (i=pos-w2;i<pos+w2;i++,n++)
   {
      if (i<0 || i>(int)buf.size()-1) return(-1);       
      profil[n]=buf[i];
   }

   py[0]=-32000.0;
   py[1]=0;
   for (i=0;i<n;i++)
   {
      if (profil[i]>py[0])
      {
         py[0]=profil[i];
         py[1]=i;
      }
   }
   py[2]=2.0; // �quivalent � un FWHM de 3.32 pixel
   py[3]=(profil[0]+profil[n-1])/2;
   py[0]=py[0]-py[3];

   MipsParaFit(n,profil,py,&ecarty);

   double sigy=sqrt(py[2]/2.0);
   *fwhm=2.3548*sigy;       // constante = 2 x sqr(2*ln(2)) -> profil 1D
   *ecartType = ecarty;
   // i0=py[0];
   *pos_x=py[1]+(double)(pos-w2);

   return(0);
}

/******************* MipsParaFit *******************/
/* Fittage de l'�quation S=I0*exp(-r2/sigma2)+fond */
/* n=nombre de points � fitter                     */
/* y()=tableau des points                          */
/* p()=tableau des variables:                      */
/*     p[0]=I0                                     */
/*     p[1]=r                                      */
/*     p[2]=sigma2                                 */
/*     p[3]=fond                                   */
/* ecart=ecart-type                                */
/***************************************************/
void MipsParaFit(int n,double *y,double *p,double *ecart)
{
int l,nbmax,m;
double l1,l2,a0;
double e,er1,x,y0;
double m0,m1;
double e1[4];
int i,j;

*ecart=1.0;

l=4;        /* nombre d'inconnues */
e=(float).005;     /* erreur maxi. */
er1=(float).5;     /* dumping factor */
nbmax=250;  /* nombre maximum d'it�rations */

for (i=0;i<l;i++)
   {
   e1[i]=er1;
   }
m=0;
l1=(double)1e10;

b1:
for (i=0;i<l;i++)
   {
   a0=p[i];
b2:
   l2=0;
   for (j=0;j<n;j++)
      {
      x=(double)j;
      if (p[2]<.05) return; // contr�le d�bordement � cause d'un petit sigma
      y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
      l2=l2+(y[j]-y0)*(y[j]-y0);
      }
   m0=l2;
   p[i]=a0*(1-e1[i]);
   l2=0;
   for (j=0;j<n;j++)
      {
      x=(float)j;
      if (p[2]<.05) return; // contr�le d�bordement � cause d'un petit sigma
      y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
      l2=l2+(y[j]-y0)*(y[j]-y0);
      }
   *ecart=sqrt((double)l2/(n-l));
   m1=l2;
   if (m1>m0) e1[i]=-e1[i]/2;
   if (m1<m0) e1[i]=(float)1.2*e1[i];
   if (m1>m0) p[i]=a0;
   if (m1>m0) goto b2;
   }
m++;
if (m==nbmax) return;
if (l2==0) return;
if (fabs((l1-l2)/l2)<e) return;

l1=l2;
goto b1;
}

//=== fin du source 1.2


/********************************************************************
 * Function: polynomialCoefficients                                 *
 *                                                                  * *                                                                  *
 * Purpose:  Given a set of data points, this function determines   *
 *           the coefficients of an Nth-order polynomial :          *
 *                                                                  *
 *           y = a0 + a1*x + a2*x*x + a3*x*x*x + ........           *
 *                                                                  *
 * Returns:  point evaluated at middle of numpts.                   *
 *                                                                  *
 * Call:     y = polynomialCoefficients ( n, d, x, y, w ) where:    *
 *                                                                  *
 *           input :                                                *
 *                   n => number of data points                     *
 *                   d => degree of regression                      *
 *                   x => one-dimensional x-array                   *
 *                   y => one-dimensional y-array                   *
 *                   w => one-dimensional weights per x-y point     *
 *           output :                                               *
 *                   none                                           *
 ********************************************************************/
#undef  A
#define A(I,J) *(a+(I)*degplus1+(J))
double polynomialCoefficients (int numpts, int degree,
                               double *x,double *y,double *wt)

{
int i,j,k,flag,degplus1;
double *a,*coeffs;
double valu1,valu2,xval,yval;

degplus1 = degree + 1;

if ((a = (double *) calloc (degplus1 * degplus1, sizeof (double))) == NULL) 
   {
   printf("\nPas assez de memoire.\n");
   return 0.0;
   }

if ((coeffs = (double *) calloc (degplus1, sizeof (double))) == NULL) 
   {
   printf("\nPas assez de memoire.\n");
   return 0.0;
   }

for (i = 0; i <= degree; ++i) 
   {
   for (j = i; j <= degree; ++j) 
      {
		A (i, j) = 0.0;
      }
   coeffs[i] = 0.0;
   }

for (i = 0; i < numpts; ++i) 
   {
   for (j = 0; j <= degree; ++j) 
      {
	   valu1 = intPower (x[i], j);
      for (k = j; k <= degree; ++k) 
         {
		   valu2 = intPower (x[i], k);
		   A (j, k) += valu1 * valu2 * wt[i];
	      }
	   coeffs[j] += y[i] * valu1 * wt[i];
      }
   }

flag = linCholeskyDecomp (degplus1, degplus1, a, coeffs);

/* evaluate y at middle of span */
xval = x[numpts / 2];
yval = 0;
for (i = 0; i < degplus1; ++i) 
   {
   yval += coeffs[i] * intPower (xval, i);
   }

free(a);
free(coeffs);
return yval;
}

/********************************************************************
 * Function: smthPolyAverage                                        *
 *                                                                  *
 * Purpose:  Smoothing via Nth-order polynomial(least-squares)      *
 *                                                                  *
 * Call:                                                            *
 *           smthPolyAverage( numpts, span, degree, x, y, ynew, wt )*
 *                                                                  *
 *           input :                                                *
 *              numpts => number of data points                     *
 *                span => portion of x,y vector to fit (must be odd)*
 *              degree => degree of fit desired (2 = parabolic)     *
 *                   x => one-dimensional x-array                   *
 *                   y => one-dimensional y-array                   *
 *                  wt => one-dimensional weights per x-y point     *
 *           output :                                               *
 *                 ynew=> predicted y-values based on smooth        *
 ********************************************************************/
int smthPolyAverage(int numpts,int span,int degree, 
                    double *x, double *y, double *ynew, double *wt)
{
int i,startspan,midspan,numloops;

if (span % 2 == 0) 
   {
	printf ("smthPolyAverage:The span can't be an even number.\n");
	return 1;
   }

if (span > numpts)
   {
	printf ("smthPolyAverage:The span can't be greater than numpts.\n");
   return 1;
   }

if (degree + 2 > numpts) 
   {
	printf ("smthPolyAverage:Degree+2 can't be greater than numpts");
   return 1;
   }

startspan = 0;
midspan = span / 2;
numloops = numpts - span + 1;

/* fill in all of ynew array */
for (i = 0; i < numpts; ++i) 
   {
	ynew[i] = y[i];
   }
    
for (i = 0; i < numloops; ++i) 
   {
	ynew[midspan] = polynomialCoefficients (span, degree, &x[startspan],
				     &y[startspan], &wt[startspan]);
	++startspan;
	++midspan;
   }

return 0;
}

/********************************************************************
 *  Function: smthMovingAverage                                     *
 *                                                                  *
 *  Purpose:  Perform a n-point moving average on the data array    *
 *            passed to the function. The average is done in-place  *
 *            so the original data is lost. Nothing is done to the  *
 *            end points.                                           *
 *                                                                  *
 *  Call:     smthMovingAverage ( pts, n, data )                    *
 *                                                                  *
 *       input:                                                     *
 *            pts = number of data points in array data[].          *
 *              n = number of points used in average, must be odd.  *
 *           data = array of data to be averaged.                   *
 *                                                                  *
 *       output:                                                    *
 *           data = contains the averaged data. The n/2 end points  *
 *                  are not changed. The original data is lost.     *
 ********************************************************************/
int smthMovingAverage (int pts, int n,double *data)
{
int i,halfn,j;
double *work,worksum,datasum;

if ((n % 2 == 0) || (n < 3) || (n > pts)) 
   {
   printf ("smthMovingAverage: Invalid smoothing parameter.");
   return 1;
   }

if ((work = (double *) calloc ((n / 2 + 1), sizeof (double))) == NULL) 
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

halfn = (n - 1) / 2;
    
for (i = 0; i < halfn; ++i) 
   {
	work[i] = data[halfn - i - 1];
   }

for (i = halfn; i < pts - halfn; ++i) 
   {
	worksum = 0.0;
	datasum = data[i];
	for (j = 0; j < halfn; ++j) 
      {
	   worksum += work[j];
	   datasum += data[i + j + 1];
	   }

   for (j = halfn - 1; j > 0; --j) 
      {
	   work[j] = work[j - 1];
   	}
   work[0] = data[i];

   data[i] = (worksum + datasum) / n;
   }

free(work);

return 0;
} 

/********************************************************************
 *      Function: crvLinearLeastSqr                                 *
 *                                                                  *
 *      Purpose:  Given a set of x, y data points, and a weight     *
 *                at each point, two coefficients, a0 and           *
 *                a1 are calculated such that                       *
 *                    y[i] = a0 + a1 * x[i]                         *
 *                in the least squares sense.                       *
 *                The root-mean-square-error of regression is also  *
 *                calculated.                                       *
 *                                                                  *
 *      Returns:  status (0 = sucessful, 1 = failure)               *
 *                                                                  *
 *      Call:     status = crvLinearLeastSqr			                 *
 *				( n, x, y, w, &a0, &a1, &rms )                          *
 *                                                                  *
 *                input :                                           *
 *                        n => number of x, y data pairs,           *
 *                        x => x-values data array,                 *
 *                        y => y-values data array,                 *
 *                        w => weight at each point.                *
 *                output :                                          *
 *                       a0 => slope,                               *
 *                       a1 => y-intercept.                         *
 *                      rms => root-mean-square-error of regression *
 ********************************************************************/
int crvLinearLeastSqr(int numpts,double *xarray,double *yarray,double *wt,
                      double *a0,double *a1,double *rms)
{
int  i;
double y1sum,x1sum,y2sum,x2sum,x1y1sum,determ;
double *x,*y,sum,err,ypred;

sum = y1sum = x1sum = y2sum = x2sum = x1y1sum = 0.0;

x = xarray;
y = yarray;

for (i = 0; i < numpts; ++i, ++x, ++y, ++wt)
   {
	sum += (*wt);
	y1sum += (*y) * (*wt);
	x1sum += (*x) * (*wt);
	y2sum += (*y) * (*y) * (*wt);
	x2sum += (*x) * (*x) * (*wt);
	x1y1sum += (*y) * (*x) * (*wt);
   }

/* calculate determinant */
determ = sum * x2sum - x1sum * x1sum;
if (determ == 0.0) 
   {
	return 1;
   }

/* find regression coefficients */
(*a0) = (y1sum * x2sum - x1y1sum * x1sum) / determ;
(*a1) = (sum * x1y1sum - x1sum * y1sum) / determ;

/* re-initialize pointers */
x = xarray;
y = yarray;

/* calculate rms */
(*rms) = 0.0;
for (i = 0; i < numpts; ++i, ++x, ++y) 
   {
	ypred = (*a0) + (*a1) * (*x);
	err = ypred - (*y);
	(*rms) += err * err;
   }

if (numpts <= 2) 
   {
	(*rms) = sqrt ((*rms) / numpts);
   }
else 
   {
	(*rms) = sqrt ((*rms) / (numpts - 2.0));
   }

return 0;
}

/*************************** HMEDIAN2 *************************/
/* Retourne la valeur m�diane d'un �chantillon RA de n point  */
/* Le trie croissant est effectu� sur ra et t2 est d�place    */
/* simultan�ment.                                             */
/**************************************************************/
double hmedian2(double *ra,double *t2,int n)
{
int l,j,ir,i;
double rra,rt2;

if (n<2)
   return *ra;
ra--;
t2--;
for (l=((ir=n)>>1)+1;;)
   {
   if (l>1)
      {
      rra=ra[--l];
      rt2=t2[l];
      }
   else
      {
      rra=ra[ir];
      rt2=t2[ir];
      ra[ir]=ra[1];
      t2[ir]=t2[1];
      if (--ir==1)
	     {
	     ra[1]=rra;
	     t2[1]=rt2;
	     return n&1? ra[n/2+1] : (short)(((double)ra[n/2]+(double)ra[n/2+1])/2.0);
	     }
      }
   for (j=(i=l)<<1;j<=ir;)
     {
     if (j<ir && ra[j]<ra[j+1]) ++j;
     if (rra<ra[j])
	    {
	    ra[i]=ra[j];
	    t2[i]=t2[j];
	    j+=(i=j);
	    }
     else
	 j=ir+1;
     }
   ra[i]=rra;
   t2[i]=rt2;
   }
/* (le 'return' n'est pas � la fin de la boucle et c'est normal !) */
}

/********************************* FIND_CONTINUUM ********************************/
// D�tection automantique du continuum             
// V1.3
/*********************************************************************************/
int find_continuum(char *n_spectre,char *n_continuum)
{
FILE *hand_spectre,*hand_out;
char nom_spectre[_MAX_PATH];
char ligne[256];
double lambda,value;
double *x,*y,*yref,*a,*wt;
double *xx,*yy,*wwt;
double *xxx,*yyy;
int i,it;

sprintf(nom_spectre,"%s.dat",n_spectre);

if ((hand_spectre=fopen(nom_spectre,"r") ) == NULL) 
   {
   printf("\nLe fichier %s est introuvable.\n",nom_spectre);
   return 1;
   }

// On compte le nombre de lignes   
int k=0;
while (fscanf(hand_spectre,"%lf %lf",&lambda,&value)!=EOF && k!=50000)
   {
   k++;
   }
fclose(hand_spectre);

// Allocations m�moire
if ((x=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }
if ((y=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   return 1;
   }
if ((yref=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   return 1;
   }
if ((wt=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   return 1;
   }
if ((a=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt); 
   return 1;
   }
if ((xx=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   return 1;
   }
if ((yy=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   return 1;
   }
if ((wwt=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   return 1;
   }
if ((xxx=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   return 1;
   }
if ((yyy=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   return 1;
   }

// Lecture du spectre
hand_spectre=fopen(nom_spectre,"r");
k=0;
while (fscanf(hand_spectre,"%lf %lf",&lambda,&value)!=EOF && k!=50000)
   {
   x[k]=lambda;
   yref[k]=y[k]=value;
   wt[k]=1.0;
   k++;
   }
fclose(hand_spectre);

// Ellimination de certaines zones (elles correspondes aux grosses raies dans une �toile de type B, A)
double pos1,pos2,p1,p2,p3,p4;
int n,nn;
int n2;
double a0,a1,rms;

// --------------------------------
// Exemple de la zone Halpha ...
// --------------------------------
pos1=6501.0;
pos2=6620.0;

p1=pos1-10.0;
p2=pos1;
p3=pos2;
p4=pos2+10.0;

// Traitement de la partie gauche de la zone
n=0;
nn=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p2))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne s�lectionne que la moiti� sup�rieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++) // on en profite pour elliminer les points le plus d�viants
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// Traitement de la partie droite de la zone
n=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p3 && x[i]<p4))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne s�lectionne que la moiti� sup�rieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// fit lin�aire de la zone marqu�e
crvLinearLeastSqr(nn,xxx,yyy,wwt,&a0,&a1,&rms);
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p4))
      {
      y[i]=a1*x[i]+a0;
      }
   } 

// --------------------------------
// Exemple de la zone Hbeta ...
// --------------------------------
pos1=4785.0;
pos2=4940.0;

p1=pos1-10.0;
p2=pos1;
p3=pos2;
p4=pos2+10.0;

// Traitement de la partie gauche de la zone
n=0;
nn=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p2))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne s�lectionne que la moiti� sup�rieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++) // on en profite pour elliminer les points le plus d�viants
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// Traitement de la partie droite de la zone
n=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p3 && x[i]<p4))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne s�lectionne que la moiti� sup�rieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// fit lin�aire de la zone marqu�e
crvLinearLeastSqr(nn,xxx,yyy,wwt,&a0,&a1,&rms);
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p4))
      {
      y[i]=a1*x[i]+a0;
      }
   } 

// --------------------------------
// Exemple de la zone H2O ...
// --------------------------------
pos1=5860.0;
pos2=6000.0;

p1=pos1-10.0;
p2=pos1;
p3=pos2;
p4=pos2+10.0;

// Traitement de la partie gauche de la zone
n=0;
nn=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p2))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne s�lectionne que la moiti� sup�rieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++) // on en profite pour elliminer les points le plus d�viants
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// Traitement de la partie droite de la zone
n=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p3 && x[i]<p4))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne s�lectionne que la moiti� sup�rieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// fit lin�aire de la zone marqu�e
crvLinearLeastSqr(nn,xxx,yyy,wwt,&a0,&a1,&rms);
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p4))
      {
      y[i]=a1*x[i]+a0;
      }
   } 

// --------------------------------------------------
// Ajustement principal
// --------------------------------------------------
// int w=191; // param�tres d'ajustement polynomial
int w=231; // param�tres d'ajustement polynomial
int degre=2;

double start=x[0];
for (i=0;i<k;i++)
   {
   x[i]=x[i]-start;
   }

// Ajustement par polynome glissant...
if (smthPolyAverage(k,w,degre,x,y,a,wt))
   {
   printf("\nErreur d'ajutement\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   free(yyy);
   return 1;
   }

// it�rations...
for (it=0;it<29;it++)
   {
   for (i=0;i<k;i++)
      {
      if (y[i]<a[i]) y[i]=a[i];
      }

   // Ajustement par polynome (ou moyenne...) glissant...
   for (i=0;i<=k;++i) a[i]=y[i];

   if (smthMovingAverage(k,w,a))
   // if (smthPolyAverage(k,w,degre,x,y,a,wt))
      {
      printf("\nErreur d'ajutement\n");
      free(x);
      free(y);
      free(yref);
      free(wt);
      free(a); 
      free(xx); 
      free(yy);
      free(wwt); 
      free(xxx);
      free(yyy);
      return 1;
      }
   }

// Sauvegarde du continuum
sprintf(nom_spectre,"%s.dat",n_continuum);

if ((hand_out=fopen(nom_spectre,"wt"))==NULL)
   {
   printf("Sauvegarde du fichier impossible.");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   free(yyy);
   return 1;
   }

for (i=0;i<k;i++)
   {
   sprintf(ligne,"%lf\t%lf\n",x[i]+start,a[i]);
   fwrite(ligne,strlen(ligne),1,hand_out);
   }
fclose(hand_out);

// Sauvegarde du profil / continuum (provisoire - pour v�rif
if ((hand_out=fopen("div.dat","wt"))==NULL)
   {
   printf("Sauvegarde du fichier impossible.");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   free(yyy);
   return 1;
   }

for (i=0;i<k;i++)
   {
   sprintf(ligne,"%lf\t%lf\n",x[i]+start,yref[i]/a[i]);
   fwrite(ligne,strlen(ligne),1,hand_out);
   }
fclose(hand_out);

free(x);
free(y);
free(yref);
free(wt);
free(a); 
free(xx); 
free(yy);
free(wwt); 
free(xxx);
free(yyy);

return 0;
}

///////////////////////////////////////////////////////////////
//  Traitement des cosmiques 
///////////////////////////////////////////////////////////////



/************************* MEDIAN_LIBRE *****************************/
/* Calcul de la m�diane dans une matrice de dimension quelconque    */
/* (la dimension de la matrice est tout au plus la moiti� de la     */
/* plus petite dimension de l'image - la largeur de la matrice est  */
/* impaire - sont format est carr�)                                 */
/********************************************************************/
int median_libre(PIC_TYPE *image, int imax, int jmax, int dimension, double parametre)
{
PIC_TYPE i,j,k,v_median;
PIC_TYPE *p0,*p1,*ptr0,*ptr1,*ptr;
PIC_TYPE *d,*ker,*buf;
PIC_TYPE l_kernel,dim_kernel,largeur2;
int longueur,adr;

/* la dimension du kernel doit �tre impaire */
if (dimension%2==0)
   {
   printf("\nFiltre median : la dimension de la matrice doit �tre impaire\n");
   return 1;
   }

l_kernel=dimension;
dim_kernel=l_kernel*l_kernel;

longueur=sizeof(PIC_TYPE)*imax*jmax;

if (imax<2*l_kernel || jmax<2*l_kernel)
   {
   printf("\nFiltre median : kernel trop grand\n");
   return 1;
   }

if ((buf=(PIC_TYPE *)malloc(longueur))==NULL)
   {
   printf("\nFiltre median : pas assez de memoire\n");
   return 1;
   }

if ((d=(PIC_TYPE *)malloc(dim_kernel*sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nFiltre median : pas assez de memoire\n");
   free(buf);
   return 1;
   }

if ((ker=(PIC_TYPE *)malloc(dim_kernel*sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nFiltre median : pas assez de memoire\n");
   free(buf);
   free(d);
   return 1;
   }

largeur2=l_kernel/2;
for (i=0;i<l_kernel;i++)
  {
  for (k=0;k<l_kernel;k++)
     {
     d[i+k*l_kernel]=(largeur2-k)*imax+i-largeur2;
     }
  }

p0=image;
p1=buf;
memset(buf,0,longueur);

for (j=largeur2;j<(jmax-largeur2);j++)
   {
   adr=j*imax;
   ptr0=p0+adr;
   ptr1=p1+adr;
   ptr=ptr0+largeur2;
   for (i=largeur2;i<(imax-largeur2);i++,ptr++)
      {
      for (k=0;k<dim_kernel;k++) ker[k]=*(ptr+d[k]);
      v_median=hmedian(ker,dim_kernel);
      if (parametre>0)
	     {
	     if (abs(*ptr-v_median) > (PIC_TYPE)(parametre*(double)(ker[dim_kernel-2]-ker[1])))
	        *(ptr1+i)=v_median;
	     else
	        *(ptr1+i)=*ptr;
	     }
      else
	     {
	     *(ptr1+i)=v_median;
	     }
      }
   }
memmove(p0,buf,longueur);

free(buf);
free(d);
free(ker);

return 0;
}

/************************ COSMIC_MED ************************/
/* D�tection des rayons cosmiques.                          */
/* La carte des rayons (map) est un buffer                  */
/* qui a la taille de l'image trait�e.                      */
/* La position des cosmiques est marqu�e par la valeur      */
/* 32767 dans cette carte (c'est un wildcard)               */
/* Algorithme :                                             */
/* (1) on charge l'image � traiter                          */
/* (2) on r�alise un filtre m�dian 5x5 pond�r�              */
/* (3) on soutrait � l'image trait�e l'image filtr�e        */
/* (4) dans l'image diff�rence, les cosmiques sont          */
/*     les points au dessus d'un seuil (pass� en param�tre) */
/* La fonction retourne le nombre de cosmique trouv�        */
/************************************************************/
int cosmic_med(INFOIMAGE *buffer, PIC_TYPE *map, double coef, PIC_TYPE seuil, int *nb)
{
int i,j,adr;
int imax=buffer->imax;
int jmax=buffer->jmax;
PIC_TYPE *p=buffer->pic;

PIC_TYPE *tampon = new PIC_TYPE[imax * jmax];
memmove(tampon, p, imax * jmax * sizeof(PIC_TYPE));

if (median_libre(tampon, imax, jmax, 5, coef) == 1) return 1;

int k=0;
for (j=0;j<jmax;j++)
   {
   for (i=0;i<imax;i++,k++)
      {
      tampon[k]=p[k]-tampon[k];
      }
   }

int nbb=0;

for (j=3; j<jmax-3; j++)
   {
   for (i=3; i<imax-3; i++)
      {
      adr=i+j*imax;
      if (p[adr]>seuil)
         {
         map[adr]=32767;
         nbb++; 
         }
      else
         map[adr]=0;
      }
   }

*nb=nbb;

delete [] tampon;
return 0; 
}

/********************** COSMIC_REPAIR ********************/
/* R�paration des rayons cosmiques                       */
/* Un cosmique dans l'image map est flagg� par           */
/* la valeur 32767                                       */
/* Le cosmique est bouch� par la valeur m�diane          */
/* des 8 plus proches voisins (sauf si c'est un cosmiqe) */
/*********************************************************/
int cosmic_repair(INFOIMAGE *buffer, PIC_TYPE *map)
{
int i,j,adr;
PIC_TYPE table[8];

int imax=buffer->imax;
int jmax=buffer->jmax;
PIC_TYPE *p=buffer->pic;

for (j=3; j<jmax-3; j++)
   {
   for (i=3; i<imax-3; i++)
      {
      adr=i+j*imax;
      if (map[adr]==32767)
         {         
         int n=0;
         if (map[adr-imax-1]!=32767)
            {
            table[n]=p[adr-imax-1];
            n++;
            }
         if (map[adr     -1]!=32767)
            {
            table[n]=p[adr     -1];
            n++;
            }
         if (map[adr+imax-1]!=32767)
            {   
            table[n]=p[adr+imax-1];
            n++;
            }
         if (map[adr-imax  ]!=32767)
            { 
            table[n]=p[adr-imax  ];
            n++;
            }
         if (map[adr+imax  ]!=32767)
            {
            table[n]=p[adr+imax  ];
            n++;
            }
         if (map[adr-imax+1]!=32767)
            {
            table[n]=p[adr-imax+1];
            n++;
            }
         if (map[adr     +1]!=32767)
            {  
            table[n]=p[adr     +1];
            n++;
            }
         if (map[adr+imax+1]!=32767)
            { 
            table[n]=p[adr+imax+1];
            n++;
            } 
         p[adr]=hmedian(table,n);    
         }
      }
   }
return 0;
}

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
// D�tection automatique et retrait des rayons cosmiques dans l'image 'buffer'
// cosmic2_med -> d�tection des cosmiques             
// cosmic2_repair -> r�paration des cosmiques         
// On passe le seuil de d�tection des cosmiques (valeur typiquement entre 100 et 500)                     
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
void Eshel_cosmic_removal(char *name_in, char *name_out, int seuil)
{
   PIC_TYPE *map;           // carte des cosmiques (� l'it�ration courante)
   PIC_TYPE *map_total;     // carte cumul�e
   int adr;
   int nb=0;
   int nb_total=0;
   int i,j,k;
   int nb_iter=5;   // nombre d'it�rations (fix�e par l'exp�rience)

   CCfits::PFitsFile pInFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   CCfits::PFitsFile pMapFits = NULL;
   INFOIMAGE *buffer = NULL;
   INFOIMAGE *bufTotal = NULL;

   try {
      // Lecture de l'image
      pOutFits = Fits_openFits(name_in, false); 
      Fits_getImage(pOutFits, &buffer); 

      int imax=buffer->imax;
      int jmax=buffer->jmax;
      PIC_TYPE *p=buffer->pic;

      map = new PIC_TYPE[imax*jmax];
      map_total = new PIC_TYPE[imax*jmax];

      // Boucle de calcul...
      for (k=0;k<nb_iter;k++)
      {
         if (cosmic_med(buffer,map,0.6,seuil,&nb)!=0) {
            throw std::exception("Eshel_cosmic_removal : erreur dans cosmic_med");
         }
         if (cosmic_repair(buffer,map)!=0) {
            throw std::exception("Eshel_cosmic_removal : erreur dans cosmic_repair");
         }
         for (j=3; j<jmax-3; j++)
         {
            for (i=3; i<imax-3; i++)
            {
               adr=i+j*imax;
               if (map_total[adr]==0 && map[adr]==32767) // si un point n'est pas d�j� flagg�, il est ajout� dans la carte de cumul 
               {
                  map_total[adr]=32767;
                  nb_total++;
               }
            } 
         }
      }

      // Sauvegarde de l'image filtr�e (buffer) ??
      pOutFits = Fits_createFits(name_out, buffer ); 
      Fits_closeFits( pOutFits);


      // .......
      // .......
      // sauvegarde de la carte des cosmiques (map_total)      
      // A ce stade il faudrait sauvegarder la table map_total comme une
      // image de v�rification (fichier FITS 2D comme check). Je lui donne dans Iris le nom @map
      // sur le disque, mais on peut choisir ce qu'on veut...
      bufTotal = createImage(map_total, imax, jmax);
      pMapFits = Fits_createFits("@map.fit", bufTotal ); 
      Fits_closeFits( pMapFits);
      freeImage(bufTotal);

      printf("\nNombre de cosmiques trouv� : %d\n",nb_total);

      freeImage(buffer);
      delete [] map;
      delete [] map_total;
   } catch (std::exception &e) {
      // je desalloue tout ce qui a pu etre alloue dynamiquement
      Fits_closeFits(pInFits);
      Fits_closeFits(pOutFits);
      Fits_closeFits(pMapFits);
      freeImage(bufTotal);
      freeImage(buffer);
      delete [] map;
      delete [] map_total;
      // je transmets l'exception a la fonction appelante
      throw e;
   }
}

void correctDistorsion( ) {

   int nbElement = 10;
   int polynomOrder = 3;
   double positionIn[] = {
      324.39,
      537.16 ,
      596.94 ,
      632.75 ,
      789.57 ,
      963.5 ,
      1109.3 ,
      1254.66 ,
      1418.21 ,
      1431.64 
   } ;
   double positionOut[] = {
      337.96 ,
      546.89 ,
      603.96 ,
      639.04 ,
      793 ,
      964.99  ,
      1109.21 ,
      1252.72 ,
      1413.17 ,
      1426.42
   };
   double *w; 
   double *a; 
   double rms = 0;
   
   w = new double[nbElement];
   a = new double[polynomOrder+1];
   
   for (int i=0 ; i< nbElement; i++) {
     w[i] = 1.0;
   }
 
   fitPoly(nbElement,polynomOrder,positionIn,positionOut,w,a,&rms);

   delete [] w;
   delete [] a;

}