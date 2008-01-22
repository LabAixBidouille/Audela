/* tt_user5.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <Myrtille.Laas@oamp.fr>
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

#include "tt.h"
#include <math.h>


/***** prototypes des fonctions internes du user5 ***********/
int tt_ima_stack_5_tutu(TT_IMA_STACK *pstack);
int tt_ima_series_trainee_1(TT_IMA_SERIES *pseries);
int tt_geo_defilant_1(TT_IMA_SERIES *pseries);
int tt_ima_masque_catalogue(TT_IMA_SERIES *pseries);

void tt_ima_series_hough_myrtille(TT_IMA* pin,TT_IMA* pout,int naxis1, int naxis2, int threshold , double *eq);
int tt_histocuts_precis(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode,double *minim,double *maxim);
int tt_histocuts_myrtille(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,double *mode,double *mini,double *maxi);

int tt_morphomath_1 (TT_IMA_SERIES *pseries);
void fittrainee (double lt, double fwhm,int x, int sizex, int sizey,double **mat,double *p,double *carac,double exposure);
void fittrainee2 (double seuil,double lt, double fwhm,double xc,double yc,int nb,int sizex, int sizey,double **mat,double *p,double *carac,double exposure);
void fittrainee3 (double seuil,double lt,double xc,double yc,int nb,int sizex, int sizey,double **mat,double *p,double *carac,double exposure);
double erf( double x );

void dilate (TT_IMA* pout,TT_IMA* p_in,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2);
void erode (TT_IMA* pout,TT_IMA* p_in,int* se,int dim1,int dim2,int sizex,int sizey, int naxis1,int naxis2);



/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user5 pour IMA/SERIES                  */
/**************************************************************************/
/**************************************************************************/

int tt_user5_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"TRAINEE")==0) { pseries->numfct=TT_IMASERIES_USER5_TRAINEE; }
   else if (strcmp(keys10,"GEOGTO")==0) { pseries->numfct=TT_IMASERIES_USER5_GEOGTO;}
   else if (strcmp(keys10,"MORPHOMATH")==0) { pseries->numfct=TT_IMASERIES_USER5_MORPHOMATH;}
   else if (strcmp(keys10,"MASQUECATA")==0) { pseries->numfct=TT_IMASERIES_USER5_MASQUECATA;}
   return(OK_DLL);
}

int tt_user5_ima_series_builder2(TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pseries->user5.param1=0.;
   strcpy(pseries->user5.filename,"./");
   return(OK_DLL);
}

int tt_user5_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TRAINEE")==0) {
	 pseries->user5.param1=(double)(atof(argu));
   } else if (strcmp(mot,"FILENAME")==0) {   
      strcpy(pseries->user5.filename,argu);
   } 
   return(OK_DLL);
}

int tt_user5_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pseries->numfct==TT_IMASERIES_USER5_TRAINEE) {
      *msg=tt_ima_series_trainee_1(pseries);
      *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_MASQUECATA){
	  *msg=tt_ima_masque_catalogue(pseries);
      *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_GEOGTO) {
	   *msg=tt_geo_defilant_1(pseries);
	   *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_MORPHOMATH) {
	   *msg=tt_morphomath_1(pseries);
	   *fct_found=TT_YES;
   }
   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user5 pour IMA/STACK                   */
/**************************************************************************/
/**************************************************************************/

int tt_user5_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"TUTU")==0) { pstack->numfct=TT_IMASTACK_USER5_TUTU; }
   return(OK_DLL);
}

int tt_user5_ima_stack_builder2(TT_IMA_STACK *pstack)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pstack->user5.param1=0.;
   return(OK_DLL);
}

int tt_user5_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TUTU_PARAM")==0) {
      pstack->user5.param1=(double)(atof(argu));
   } 
   return(OK_DLL);
}

int tt_user5_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pstack->numfct==TT_IMASTACK_USER5_TUTU) {
      *msg=tt_ima_stack_5_tutu(pstack);
      *fct_found=TT_YES;
   }
   return(OK_DLL);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int tt_ima_masque_catalogue(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* remplace les train�es d'�toiles par le fond de ciel                     */
/***************************************************************************/
{
	TT_IMA *p_in,*p_out;
	double x,y,magn,nb;
	int kx,ky;
	long nelem;
    double dvalue,fond;
	int ymax,xmax;
 

	p_in=pseries->p_in;
	p_out=pseries->p_out;
	x=pseries->xcenter;
	y=pseries->ycenter;
	magn=pseries->magrlim;
	nelem=pseries->nelements;
	fond=pseries->threshold;
	ymax=p_in->naxis2;
	xmax=p_in->naxis1;

	if (magn >= 12) {
		nb=4;
	} else if ((magn >= 11)&&(magn <12)) {
		nb=6;
	} else if ((magn >= 10)&&(magn <11)) {
		nb=8;
	} else if ((magn >= 9)&&(magn <10)) {
		nb=10;
	} else if ((magn >= 8)&&(magn <9)) {
		nb=11;
	} else if ((magn >= 7)&&(magn <8)) {
		nb=12;
	} else if (magn<7) {
		nb=15;
	}

	nb=nb/2.;

	/* --- calcul de la fonction ---*/
    tt_imacreater(p_out,xmax,ymax);
    for (kx=0;kx<p_in->naxis1;kx++) {
		for (ky=0;ky<p_in->naxis2;ky++) {
			if ( ( ((kx-1-x)*(kx-1-x)+(ky-y)*(ky-y)) <= (nb+1)*(nb+1) ) || ( ((kx-x-47)*(kx-x-47)+(ky-y)*(ky-y)) <= (nb +1)*(nb+1)) || ( (ky>=(y-nb-1))&&(ky<=(y+nb+1))&&(kx>=x)&&(kx<=(x+47)) ) ){
				if (fond==0) {
					fond = 980;
				}
				p_out->p[ky*ymax+kx]=(TT_PTYPE)(fond);
			} else {
				 dvalue=(double)p_in->p[ky*ymax+kx];
				 p_out->p[ky*ymax+kx]=(TT_PTYPE)(dvalue);	 
			}
		}

     
    }

	return 0;
}


int tt_ima_series_trainee_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* detecte les train�es d'�toiles sur une image trainee                    */
/***************************************************************************/
/*														                   */
/* sortie = fichier														   */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index;
   double fwhmsat,seuil,sigma,seuila;
   double xc,yc,radius;
   char filenamesat[FLEN_FILENAME];
   double exposure;	
  // double mode,mini,maxi;
  
   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   fwhmsat=pseries->fwhmsat;
   radius=pseries->radius;
   exposure=pseries->exposure;

	/* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
	  p_out->p[kkk]=(TT_PTYPE)(dvalue);	 
   }
   /* --- raz des variables a calculer ---*/
   pseries->hicut=1.;
   pseries->locut=0.;             
   pseries->cutscontrast=1.0; //pour diminuer le contraste       

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   
   //seuils pr�d�finis
	sigma=pseries->bgsigma;
	seuil=pseries->bgmean+10*sigma;
	seuila=pseries->bgmean+8.5*sigma;
	
   if (radius<=0) {
       xc=p_in->naxis1/2;
       yc=p_in->naxis2/2;
       radius=1.1*sqrt(xc*xc+yc*yc);
   }
   if (fwhmsat<=0) {
      fwhmsat=1.;
   }
   
   //strcpy(filenamesat,"../ros/src/grenouille/catalog.cat");
	strcpy(filenamesat,"./catalog.cat");

   //tt_imasaver(p_out,"D:/pout_algo2.fit",16);
   /* --- calcul ---*/
   tt_util_chercher_trainee(p_in,p_out,filenamesat,fwhmsat,seuil,seuila,xc,yc,exposure);
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/***************************************************************************/
/* detecte le d�but des train�es d'�toiles sur une image trainee           */
/***************************************************************************/
/*														                   */
/* 																		   */
/***************************************************************************/

int tt_util_chercher_trainee(TT_IMA *pin,TT_IMA *pout,char *filename,double fwhmsat,double seuil,double seuila, double xc0, double yc0, double exposure)

{	
	int xmax,ymax,ntrainee,sizex,sizey,nb,background,flags;
	double fwhmyh,fwhmyb,posx,posy,posxanc,posyanc,fwhmx,fwhmy,lt,xc,yc,flux,fluxerr,fwhmd,a,b;
	double magnitude, magnitudeerr,theta,classstar;
	int k,k2,y,x,ltt,fwhmybi,fwhmyhi,fwhm,nelem;
	double *matx;
	FILE *fic;
	double **mat, *para, *carac;

	nelem=pin->nelements;
	posxanc=0;
	posyanc=0;
	para = (double*)calloc(6,sizeof(double));
	
	/* --- chercher les dimensions de l'image ---*/
	xmax=pin->naxis1;
	ymax=pin->naxis2;
	
	/* --- ouvre le fichier en ecriture ---*/
	fic=fopen(filename,"wt");

	/* --- longueur des trainees pour la camera Andor de TAROT*/
	lt=0.004180983*exposure/(9.1441235255136e-4);
	ltt = (int) lt;

	matx = (double*)calloc((xmax-ltt-3),sizeof(double));
	

	carac = (double*)calloc(5,sizeof(double));
	for (k=0;k<=4;k++) {
		carac[k]=0.0;
	}
	ntrainee=1;

	/* --- grande boucle sur l'image ---*/
	for (y=3;y<ymax-3;y++) {
		if ((y>ymax)||(y<0)) { continue; }	
		for (x=3;x<(xmax-ltt-3);x++) {
			
			//if (temp[y*ymax+x]==-1) {continue;}
			if (pout->p[y*ymax+x]<=seuil) {continue;}
			matx[x]=0;
			for (k=0;k<ltt;k++) {
				matx[x]+=pout->p[y*ymax+x+k];
			}
			if (matx[x]>=ltt*(seuil)) {	
				fwhmyh=0;
				fwhmyb=0;
				//recherche approximative des param�tres de la train�es
				for (k=0;k<ltt;k++) {
					for (k2=1;k2<40;k2++) {
						if ((k2+y)>= ymax) break;
						if (pout->p[(y+k2)*ymax+x+k]>seuil) {fwhmyh++;}
						else break;
					}
					for (k2=1;k2<40;k2++) {
						if (k2 > y) break;
						if (pout->p[(y-k2)*ymax+x+k]>seuil) {fwhmyb++;}
						else break;
					}
				}
				fwhmyh=fwhmyh/ltt;
				fwhmyb=fwhmyb/ltt;
				fwhmyhi =(int) (1.5*(fwhmyh+1));
				fwhmybi =(int) (1.5*(fwhmyb+1));
				sizex=ltt+fwhmyhi+fwhmybi+10;
				sizey=fwhmybi+fwhmyhi+10;
				fwhm= (int) ((fwhmybi+fwhmyhi)/2);
				if (fwhm == 0) {fwhm=1;}

				fwhmd = ((fwhmybi+fwhmyhi)/2);
				//pour les bords d'image
				if (fwhm>x) fwhm=x;
				if ((fwhm + x) > xmax) fwhm=(xmax-x);
				if ((sizex + x) > xmax) sizex=(xmax-x);
				if ((sizex + x) > xmax) sizex=(xmax-x);
				nb=y-fwhmybi;
				if (nb > 5) nb = 5;
				if ((sizey + y) > ymax) sizey=(ymax-y);

				//fixe la taille de la fen�tre de travail: sizex et sizey
				mat = (double**)calloc(sizex,sizeof(double));
				for(k=0;k<sizex;k++) {
					*(mat+k) = (double*)calloc(sizey,sizeof(double));
				}
				//--- Mise a zero des deux buffers 
				for(k=0;k<sizex;k++) {
				  for(k2=0;k2<sizey;k2++) {
					 mat[k][k2]=(double)0.;
				  }
				}
				for(k2=0;k2<sizey;k2++) {
				  for(k=0;k<sizex;k++) {
					 mat[k][k2] = pin->p[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k];
					 //temp[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k]=-1;// pour ne pas repasser sur la meme etoile
					 if ((y-fwhmybi-nb+k2<ymax-1)&&(x-fwhm-nb+k<xmax-ltt-1)&&(y-fwhmybi-nb+k2>1)&&(x-fwhm-nb+k>1)) {
						pout->p[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k]=(float)seuila;// pour ne pas repasser sur la meme etoile
					 }
				  }
				}
				//recherche de la position du photocentre
				xc=2*(fwhm/1.5)+nb;
				yc=(fwhmybi/1.5)+nb;
				flux=0.0;

				fittrainee2 (seuila,lt,fwhm,xc,yc,nb,sizex, sizey, mat, para, carac, exposure); 				
				//fittrainee3 (seuila,lt,xc,yc,nb,sizex, sizey, mat, para, carac, exposure); 
				//posx  = para[1]+x-fwhm-nb;
				posx  = para[1]+1.0*x+1.0;
				posy  = para[4]-(fwhmybi/1.5)-1.0*nb+1.0*y;
				
				/* --- pour ne pas avoir des �toiles doubles --- */
				if (((posx-posxanc)<0.05)&&((posy-posyanc)<0.05)) { continue;}
	
				posxanc=posx;
				posyanc=posy;

				//param�tres calcul�s rapidement ou pas du tout, pour que le fichier de sortie ressemble � celui de SExtractor
				flux=carac[1];
				fluxerr=0.2*flux;
				if (flux<=50.0) { flux = 50;}
				magnitude = -2.5*log10(flux) + 23.92;
				magnitudeerr = 0.2*magnitude;
				background = 2;
				theta =0.0;
				flags=0;
				classstar=0.90;
				b=2.0*fwhm/1.5;
				a=lt/2+2*fwhm/1.5;

				/*fittrainee (lt,fwhm,x,sizex, sizey, mat, para, carac, exposure); 
				posx  = (para[1]-fwhm-nb+2*x)/2;
				posy  = para[4]-fwhmybi-nb+y;*/

				fwhmx = para[2];						
				fwhmy = para[5];
				//*fondx = para[3];
				//*fondy = para[3];

				/* --- sortie du resultat ---*/
// attention matrice image commence au pixel 1,1 alors que l'analyse se fait avec 0,0 dans cette fonction !!
// catalog.cat: numero flux_best fluxerr_best magn_best magnerr_best background X Y X2 Y2 XY A B theta FWHM flags class_star
				fprintf(fic,"	%-d			%-9.1f		%-9.1f		%-9.1f		%-9.1f	%d	%9f		%9f		%8e	%8e	%8e	%f	%5.3f	%5.3f	%4.1f %d	%4.2f\n",
				ntrainee,flux,fluxerr,magnitude,magnitudeerr,background,posx,posy,carac[2],carac[3],carac[4],
				a,b,theta,fwhmd,flags, classstar);
				ntrainee++;
				tt_free2((double**)&mat,"mat");
				x=x+ltt;
			}
		}
	}
	tt_imasaver(pout,"D:/pout_algo2.fit",16);
	free(matx);
	free(para);
	//free(temp);
	free(carac);	
	fclose(fic);
	return 1;
}

/*********************************************************************************************/
/* fitte les train�es avec une ellipse														 */
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des tra�n�es															 */
/*		fwhm = largeur � mi-hauteur de la fonction d'�talement de l'�toile non train�e		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		x = numero du pixel en x du debut de la zone										 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone � fitter						 */
/*	SORTIES																					 */
/*  p()=tableau des variables:																 */
/*     p[0]=intensite maximum de la gaussienne												 */
/*     p[1]=indice X du maximum de la gaussienne											 */
/*     p[2]=fwhm X																			 */
/*     p[3]=fond																			 */
/*     p[4]=indice Y du maximum de la gaussienne											 */
/*     p[5]=fwhm Y																			 */
/*  carac[0]=ecart-type																		 */
/*  carac[1]=flux																	         */
/*  carac[2]=X2																				 */
/*  carac[3]=Y2																				 */
/*  carac[4]=XY																				 */
/*********************************************************************************************/
void fittrainee (double lt, double fwhm,int x, int sizex, int sizey,double **mat,double *p,double *carac, double exposure) {

	double *matx,*maty, intensite,moyy,*addx,matyy,posx,inten,flux,flux2;
	int jx,jxx,jy,moyjx,ltt,posmaty;
	int n23;
	double value,sx,sy,fmoy,fmed,seuilf,f23,a,b,c,xcc,ycc;
	double *vec;
	
	ltt = (int) lt;

	matx = (double*)calloc(sizex,sizeof(double));
	maty = (double*)calloc((sizex-ltt+7),sizeof(double));
	addx = (double*)calloc(sizex,sizeof(double));

	for (jx=0;jx<sizex;jx++) {
		matx[jx]=0.;
	}
	for (jy=0;jy<(sizex-ltt+7);jy++) {
		maty[jy]=0.;
	}
	for (jx=0;jx<sizex;jx++) {
		addx[jx]=0.;
	}

	moyy=0;
	inten=0.;
	// recherche du max d'intensit� pour chaque colonne et ligne pour avoir une valeur approch�e du centre de l'etoile
	for (jx=0;jx<sizex;jx++) {
		intensite=0.;
		for (jy=0;jy<sizey;jy++) {
			if (mat[jx][jy]>intensite) {
				intensite=mat[jx][jy]; matx[jx]=1.*jy; 
				
			}	
			if (intensite>inten) {inten=intensite;}
		}
		moyy+=matx[jx];
		addx[jx]+=mat[jx][jy];
	}
	moyy=moyy/sizex;
	moyjx = (int)moyy;
	if (moyy-moyjx>0.5) {moyjx+=1;}
	matyy=0;
	
	for (jx=0;jx<(sizex-ltt+6);jx++) {
		for (jxx=0;jxx<(ltt-6);jxx++) {
			maty[jx]+=mat[jx+jxx][moyjx];
		}
		if (maty[jx]>matyy) {
			matyy=maty[jx];posmaty=jx;
			 
		}
	}
	//posx et moyy repr�sentent le pixel d'intensit� la plus forte sur la ligne d�finie par y=moyy
	//moyy repr�sente la ligne moyenne d'intensit� maximale dans la zone 
	posx=(double)posmaty;
	p[1]=posx;
	p[2]=1;//a calculer
	p[4]=moyy;
	p[5]=1;//a calculer


	vec=NULL;
	vec = (double*)calloc(sizex*sizey,sizeof(double));
	n23=0;
	f23=0.;
	b=2*fwhm;
	a=ltt/2;
	c=1.5*fwhm;

	//definir une ellipse dont un des foyers est def par posmaty et moyx
	for (jy=0;jy<sizey;jy++) {	
		for (jx=0;jx<sizex;jx++) {			
			if (((jx-posx-a)*(jx-posx-a)/(a*a) + (jy-moyy)*(jy-moyy)/(b*b))<=1) {
				vec[n23]=mat[jx][jy];
				f23 += mat[jx][jy];
				n23++;
			}
		}
	}

	tt_util_qsort_double(vec,0,n23,NULL);

	fmoy=vec[0];
	if (n23!=0) {fmoy=f23/n23;}
	/* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
	fmed=(float)vec[(int)(0.5*n23)];
	free(vec);
	seuilf=0.2*(inten-fmed);
	sx=0.;
	sy=0.;
	flux=0.;
	for (jy=0;jy<sizey;jy++) {	
		for (jx=0;jx<sizex;jx++) {					
			value=mat[jx][jy]-fmed;
			if ((((jx-posx-a)*(jx-posx-a)/(a*a) + (jy-moyy)*(jy-moyy)/(c*c))<=1)&&(value>=seuilf)) {
				flux += value;
				sx += (double)(jx * value);
				sy += (double)(jy * value);			
			} 
			if ((((jx-posx)*(jx-posx) + (jy-moyy)*(jy-moyy))<=c*c)&&(value>=seuilf)) {
				flux2 += value;
						
			} 
		}
	}
	if (flux!=0.) {
		xcc = sx / flux -ltt/2;
		ycc = sy / flux ;
	}
	
	p[1]=xcc;
	p[4]=ycc;
	carac[1]= flux2;
	
	free(matx);
	free(maty);
	free(addx);

}

/*********************************************************************************************/
/* fitte les train�es avec une gaussienne convolu�e avec une un trait (= forme d'une train�e)*/
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des tra�n�es															 */
/*		fwhm = largeur � mi-hauteur de la fonction d'�talement de l'�toile non train�e		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone � fitter						 */
/*	SORTIES																					 */
/*  p()=tableau des variables:																 */
/*     p[0]=intensite maximum de la gaussienne												 */
/*     p[1]=indice X du maximum de la gaussienne											 */
/*     p[2]=fwhm X																			 */
/*     p[3]=fond																			 */
/*     p[4]=indice Y du maximum de la gaussienne											 */
/*     p[5]=fwhm Y																			 */
/*  carac[0]=ecart-type																		 */
/*  carac[1]=flux																	         */
/*  carac[2]=X2																				 */
/*  carac[3]=Y2																				 */
/*  carac[4]=XY																				 */
/*********************************************************************************************/

void fittrainee2 (double seuil,double lt, double fwhm,double xc,double yc,int nb, int sizex, int sizey,double **mat,double *p,double *carac,double exposure) {

   int l,nbmax,m,ltt;
   double l1,l2,a0,f,kk;
   double e,er1,y0;
   double m0,m1;
   double e1[6]; /* ici ajout */
   int i,jx,jy,k;
   double rr2;
   double xx,yy,flux,x2,y2,xy,xxx,yyy;
   double *F;

   int n23;
   double value,fmoy,fmed,f23,a,b,c;
   double *vec;

   ltt = (int) lt;
   
   F = (double*)calloc(sizex,sizeof(double));
   

   p[0]=mat[0][0];
   p[1]=xc;
   p[3]=mat[0][0];
   p[4]=yc;

  				
   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
		 if (mat[jx][jy]>p[0]) {p[0]=mat[jx][jy]; }
         if (mat[jx][jy]<p[3]) {p[3]=mat[jx][jy]; }
      }
   }

   p[0]-=p[3];
   p[2]=1.;
   p[5]=1.;
   carac[0]=1.0;
   carac[1]=0.0;

   l=6;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=250;         /* nombre maximum d'iterations */

   for (i=0;i<l;i++) {
	 e1[i]=er1;
   }

   m=0;
   l1=(double)1e10;

   fitgauss2d_b1:

	for (i=0;i<l;i++) {
		a0=p[i];

		fitgauss2d_b2:

		l2=0;
		for (jx=0;jx<sizex;jx++) {
			F[jx]=0.0;
		}
		

		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			f=0.0;
			for (k=0; k<=ltt; k++) {
				kk=(double)k;
				if (k==0) {
					f=-0.5*exp(-(xx-kk-p[1])*(xx-kk-p[1])/(p[2]*p[5]));
				}
				if (k==ltt) {
					f+=exp(-(xx-kk-p[1])*(xx-kk-p[1])/(p[2]*p[5]));
				}
				if ((k!=0)&&(k!=ltt)) {
					f+=0.5*exp(-(xx-kk-p[1])*(xx-kk-p[1])/(p[2]*p[5]));
				}
			}
			F[jx]=f;
			for (jy=0;jy<sizey;jy++) {
				yy=(double)jy;
				rr2=(yy-p[4])*(yy-p[4]);
				y0=F[jx]*p[0]*exp(-rr2/p[2]/p[5])+p[3];
				l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
			}
		}

		m0=l2;
		p[i]=a0*(1-e1[i]);
		l2=0;

		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			for (jy=0;jy<sizey;jy++) {
				yy=(double)jy;
				rr2=(yy-p[4])*(yy-p[4]);
				y0=F[jx]*p[0]*exp(-rr2/p[2]/p[5])+p[3];
				l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
			}
		}

		carac[0]=sqrt((double)l2/(sizex*sizey-l)); 
		m1=l2;
		if (m1>m0) e1[i]=-e1[i]/2;
		if (m1<m0) e1[i]=(float)1.2*e1[i];
		if (m1>m0) p[i]=a0;
		if (m1>m0) goto fitgauss2d_b2;
	}

	m++;
	if ((m==nbmax)||(l2==0)||(fabs((l1-l2)/l2)<e)) {

		vec=NULL;
		vec = (double*)calloc(sizex*sizey,sizeof(double));
		n23=0;
		f23=0.;
		b=2*(fwhm+1);
		a=ltt/2+2*(fwhm+1);
		c=1.5*(fwhm+1);

		//definir une ellipse dont un des foyers est def par posmaty et moyx
		for (jy=0;jy<sizey;jy++) {	
			for (jx=0;jx<sizex;jx++) {			
				if (((jx-a)*(jx-a)/(a*a) + (jy-p[4])*(jy-p[4])/(b*b))>1) {
					vec[n23]=mat[jx][jy];
					f23 += mat[jx][jy];
					n23++;
				}
			}
		}

		tt_util_qsort_double(vec,0,n23,NULL);

		fmoy=vec[0];
		if (n23!=0) {fmoy=f23/n23;}
		/* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
		fmed=(float)vec[(int)(0.5*n23)];
		free(vec);
		//seuilf=0.2*(p[0]+p[3]-fmed);
		n23=0;xxx=0;yyy=0;
		x2=0.0; y2=0.0;
		flux=0.;
		for (jy=0;jy<sizey;jy++) {	
			for (jx=0;jx<(int)(sizex/3);jx++) {	
				value=mat[jx][jy]-fmed;
				if ((((jx-p[1]-fwhm-nb)*(jx-p[1]-fwhm-nb) + (jy-p[4])*(jy-p[4]))<=c*c)&&(mat[jx][jy]>fmed/2+seuil/2)) {
					flux += mat[jx][jy];
					x2+=value*(jx-p[1])*(jx-p[1]);
					y2+=value*(jy-p[4])*(jy-p[4]);
					xy+=value*(jy-p[4])*(jx-p[1]);
					n23++;
					xxx+=1.0*(jx-p[1]);
					yyy+=1.0*(jy-p[4]);
				} 
			}
		}
		if (flux<=10.0) {
				flux=10.0;
				carac[2]=0.0;
				carac[3]=0.0;
				carac[4]=0.0;
			} else {
				carac[2]=x2/flux-(xxx/n23)*(xxx/n23);
				carac[3]=y2/flux-(yyy/n23)*(yyy/n23);
				carac[4]=xy/flux-(xxx/n23)*(yyy/n23);
			}
		carac[1]= flux;
		if (flux==0.0) {
			for (jy=0;jy<sizey;jy++) {	
				for (jx=0;jx<sizex;jx++) {					
					value=mat[jx][jy]-fmed;
					if ((((jx-p[1]-fwhm-nb)*(jx-p[1]-fwhm-nb) + (jy-p[4])*(jy-p[4]))<=b*b)&&(value>=0)) {
						flux += value;
						x2+=value*(jx-p[1])*(jx-p[1]);
						y2+=value*(jy-p[4])*(jy-p[4]);
						xy+=value*(jy-p[4])*(jx-p[1]);
						n23++;
						xxx+=1.0*(jx-p[1]);
						yyy+=1.0*(jy-p[4]);
					} 
				}
			}
			if (flux<=10.0){
				flux=10.0;
				carac[2]=0.0;
				carac[3]=0.0;
				carac[4]=0.0;
			} else {
				carac[2]=x2/flux-(xxx/n23)*(xxx/n23);
				carac[3]=y2/flux-(yyy/n23)*(yyy/n23);
				carac[4]=xy/flux-(xxx/n23)*(yyy/n23);
			}
			carac[1]= flux;
		}

		p[2]=p[2]/.601;p[5]=p[5]/.601; free(F);return;
	
	} else {

		l1=l2;
		goto fitgauss2d_b1;
	}
}
	

/*********************************************************************************************/
/* fitte les train�es avec une gaussienne convolu� avec une un trait (= forme d'une train�e) */
/*	approximation de la fonction erf													     */
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des tra�n�es															 */
/*		fwhm = largeur � mi-hauteur de la fonction d'�talement de l'�toile non train�e		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone � fitter						 */
/*	SORTIES																					 */
/*  p()=tableau des variables:																 */
/*     p[0]=intensite maximum de la gaussienne												 */
/*     p[1]=indice X du maximum de la gaussienne											 */
/*     p[2]=fwhm X																			 */
/*     p[3]=fond																			 */
/*     p[4]=indice Y du maximum de la gaussienne											 */
/*     p[5]=fwhm Y																			 */
/*  ecart=ecart-type																		 */
/*********************************************************************************************/

void fittrainee3 (double seuil,double lt,double xc,double yc,int nb,int sizex, int sizey,double **mat,double *p,double *carac,double exposure) {
   
   int l,nbmax,m,ltt;
   double l1,l2,a0;
   double e,er1,y0;
   double m0,m1,vs;
   double e1[6]; /* ici ajout */
   int i,jx,jy;
   double rr2;
   double xx,yy;

   //vitesse sid�rale
   vs = 0.004180983;
   ltt = (int) lt;

   p[0]=mat[0][0];
   p[1]=xc;
   p[3]=mat[0][0];
   p[4]=yc;

  				
   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
		 if (mat[jx][jy]>p[0]) {p[0]=mat[jx][jy]; }
         if (mat[jx][jy]<p[3]) {p[3]=mat[jx][jy]; }
      }
   }

   p[0]-=p[3];
   p[2]=1.;
   p[5]=1.;
   carac[0]=1.0;
   l=6;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=50;         /* nombre maximum d'iterations */

   for (i=0;i<l;i++) {
	 e1[i]=er1;
   }

   m=0;
   l1=(double)1e10;

   fitgauss2d_b1:

	for (i=0;i<l;i++) {
		a0=p[i];

		fitgauss2d_b2:

		l2=0;
		
		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			if (xx<=xc) {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(-erf((p[1]-jx)/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			} else {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(erf((jx-p[1])/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			}
		}

		m0=l2;
		p[i]=a0*(1-e1[i]);
		l2=0;

		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			if (xx<=xc) {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(-erf((p[1]-jx)/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			} else {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(erf((jx-p[1])/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			}
		}

		carac[0]=sqrt((double)l2/(sizex*sizey-l)); 
		m1=l2;
		if (m1>m0) e1[i]=-e1[i]/2;
		if (m1<m0) e1[i]=(float)1.2*e1[i];
		if (m1>m0) p[i]=a0;
		if (m1>m0) goto fitgauss2d_b2;
	}
	m++;
	if (m==nbmax) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
	if (l2==0) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
	if (fabs((l1-l2)/l2)<e) {p[2]=p[2]/.601;p[5]=p[5]/.601;return; }
	l1=l2;
	goto fitgauss2d_b1;
}

double erf( double x ) {

    double t, z, retval;
    
    z = fabs( x );
    t = 1.0 / ( 1.0 + 0.5 * z );
    retval = t * exp( -z * z - 1.26551223 + t *
		      ( 1.00002368 + t *
			( 0.37409196 + t *
			  ( 0.09678418 + t *
			    ( -0.18628806 + t *
			      ( 0.27886807 + t *
				( -1.13520398 + t *
				  ( 1.48851587 + t *
				    ( -0.82215223 + t *
				      0.1708727 ) ) ) ) ) ) ) ) );
    if( x < 0.0 )
	return retval - 1.0;
    
    return 1.0 - retval;
}


//###############################################################################################################################
//###############################################################################################################################
//												MORPHO MATHS
//###############################################################################################################################
//###############################################################################################################################
//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//set chemin "D:/"
//buf1 imaseries "GEOGTO filename=$chemin nom_trait=TOPHATE struct_elem=RECTANGLE x1=10 y1=1"
//buf1 imaseries "GEOGTO filename=$chemin nom_trait=$nom_Trait struct_elem=$struct_Elem x1=$dim1 y1=$dim2"
//pour le moment les SE seront de dimensions impaires pour avoir un centre centr�!

int tt_geo_defilant_1(TT_IMA_SERIES *pseries)
{
	TT_IMA *p_in,*p_out,*p_tmp1,*p_tmp2,*p_tmp3,*p_tmp4;
	int kkk,kk,x,y,k1,k2,k3,k5,n2,n1,nbnul,i,x0,y0;
	double xfin,yfin,xdebut,ydebut,l;
	int result,nelem,index,naxis1,naxis2,x1,y1,nb_ss_image1,nb_ss_image2,k,ngto,bord;
	int *se = NULL;
	double dvalue,somme_value,somme_x,somme_y,somme_value2,somme_x2,somme_y2;
	double mode2,mini2,maxi2,bg,seuil_gto,seuil_geo;
	double *bgmean = NULL, *bgsigma =NULL;
	char filenamegto[FLEN_FILENAME],filenamegeo[FLEN_FILENAME];
	FILE *fic;
	double *eq;
	double bary_x[300], bary_y[300], somme[300];
	double sommexy,sommex,sommey,sommexx;
	double fwhmx,fwhmy,xcc,fwhmxy,ycc,r1,r2,r3,r11,r22,r33,dx,dy,dx2,dy2,d2,fmoy,fmed,f23,sigma,flux,ra,dec;
	int nombre, taille,xx1,xx2,yy1,yy2,msg,n23,j,n23d,n23f,nsats,valid_ast;
	double *vec;
	double **mat, *pp, *ecart;
	int sizex, sizey,nb,largxx,largx;
	TT_ASTROM p_ast;

	/* --- intialisations ---*/
	p_in=pseries->p_in; 
	p_tmp4=pseries->p_tmp4; 
	p_out=pseries->p_out;
	p_tmp1=pseries->p_tmp1;
	p_tmp2=pseries->p_tmp2;
	p_tmp3=pseries->p_tmp3;
	nelem=pseries->nelements;
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	index=pseries->index;
	x1=pseries->x1;
	y1=pseries->y1;

	if (strcmp(pseries->user5.filename,"")!=0) {
		strcpy(filenamegto,pseries->user5.filename);
		strcat(filenamegto,"gto.txt");
		strcpy(filenamegeo,pseries->user5.filename);
		strcat(filenamegeo,"geo.txt");
	} else {
		strcpy(filenamegto,"gto.txt");
		strcpy(filenamegeo,"geo.txt");
	}

	eq = (double*)calloc(3,sizeof(double));
	

	/* --- calcul de la fonction ---*/
	tt_imacreater(p_out,naxis1,naxis2);
	tt_imadestroyer(p_tmp1);
	tt_imabuilder(p_tmp1);
	tt_imacreater(p_tmp1,naxis1,naxis2);

	tt_morphomath_1(pseries);	
	//pour visualiser le tophat 
	//tt_imasaver(p_out,"D:/tophat.fit",16);
	
	//binarisation de l'image en fonction de l'histogramme
	tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
	tt_util_statima(p_out,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
	tt_histocuts_myrtille(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
	if (strcmp (pseries->nom_trait,"TOPHATE")==0) {
		/*seuil_gto=(pseries->hicut)+1.0*(pseries->sigma);
		if (seuil_gto>((pseries->hicut)+(pseries->maxi-pseries->hicut)*1.0/4.0)) {
			seuil_gto=(pseries->hicut)+(pseries->maxi-pseries->hicut)*1.0/4.0; 
		}*/
		seuil_gto=(pseries->hicut)*0.78;
		//seuil_geo=(pseries->hicut)*2.4;
		//formule �tablie sur des tests sur des images...
		//seuil_geo=((pseries->maxi)+(pseries->hicut)-2*(pseries->locut))/2.0;
		seuil_geo=((pseries->maxi)+(pseries->hicut))/2.0;
		if (seuil_geo>(pseries->maxi)*(1-2.5/10)) {
			seuil_geo=(pseries->maxi)*(1-2.5/10);
		}
		//seuil_geo=((pseries->maxi)+(pseries->hicut))*3.0/5.0;
	
	} else {
		seuil_gto=(pseries->hicut)*0.8;
		seuil_geo=(pseries->hicut)*1.8;
	}
	for (y=0;y<naxis2;y++) {
		for (x=0;x<naxis1;x++) {
			//seuillage haut pour r�cup�rer seulement les g�ostationnaires
			if (p_out->p[y*naxis1+x]<seuil_geo) {
				p_tmp1->p[y*naxis1+x]=0;	
				//seuillage bas pour garder les �ventuelles tra�n�es faibles
				if (p_out->p[y*naxis1+x]<seuil_gto) {
					p_tmp2->p[y*naxis1+x]=0;				
				}  else {
					p_tmp2->p[y*naxis1+x]=p_out->p[y*naxis1+x];
				}
			} else {
				p_tmp1->p[y*naxis1+x]=p_out->p[y*naxis1+x];
			}
		}
	}
	
	tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));

	/* --- definition du seuil de detection --- */
	if (strcmp (pseries->nom_trait,"TOPHATE")==0) {
		bg=(pseries->bgmean)+2.5*(pseries->bgsigma);
	} else {
		bg=(pseries->bgmean)+2.5*(pseries->bgsigma);
	}

	//---------------------------------------------------/
	//sauve images pour recherche de geo gto et d�filants
	//p_out = gto seuill� et p_tmp1 = geo seuill�
	//tt_imasaver(p_tmp1,"D:/geo.fit",16);
	//tt_imasaver(p_tmp2,"D:/gto.fit",16);

/* ----------------------------------------- */
/* --- recherche des tra�n�es dans p_out --- */
/* ----------------------------------------- */
	//couper l'image en 64 sous-images de 256*256 pixels 
	nb_ss_image1=8;nb_ss_image2=8;
	n2=(int)naxis2/nb_ss_image2;
	n1=(int)naxis1/nb_ss_image1;
	pseries->threshold=1;
	ngto=1;
	//definition de la zone de la sous_image
	p_tmp3->naxis1=n1;
	p_tmp3->naxis2=n2;
	tt_imacreater(p_tmp3,n1,n2);

	/* --- ouvre le fichier en ecriture ---*/
	fic=fopen(filenamegto,"wt");
	for (kk=0;kk<2;kk++) {//kk=1 pour imagette d�cal�e, c'est le deuxi�me passage
		k=0;
		k3=0;k5=0;
		for (kkk=0;kkk<(nb_ss_image1-2*kk)*(nb_ss_image2-2*kk);kkk++) {	
			//gestion des bord du chapeau haut de forme = fausse d�tections
			x0=0,y0=0;
			if (kk==0) {
				if (kkk<nb_ss_image1) {
					y0=y1+1;
				}
				if (kkk>nb_ss_image1*(nb_ss_image1-1)) {
					y0=y1+1;
				}
				if (kkk%nb_ss_image1==0) {
					x0=x1+1;
				}
				if (kkk%nb_ss_image1==7) {
					x0=x1+1;
				}
			}
			//premi�re imagette en bas � gauche, derni�re en haut � droite
			for (k1=0;k1<n1;k1++) {
				for (k2=0;k2<n2;k2++) {
					if ((k1>=n1-x0)||(k1<=x0)||(k2<=y0)||(k2>=n2-y0)) {
						p_tmp3->p[n2*k2+k1]=0;
					} else {
						dvalue=(double)p_tmp2->p[naxis2*(k2+k3*n2+kk*n2/2)+k1+k5+kk*n1/2];
						p_tmp3->p[n2*k2+k1]=(TT_PTYPE)(dvalue);
					}
				}
			}
			//tt_imasaver(p_tmp3,"D:/gtopetite.fit",16);
			tt_ima_series_hough_myrtille(p_tmp3,p_tmp4,n1,n2,1,eq);

			//recup�re les coordonn�es de la droite d�tect�e y=a0*x+b0
			if ((eq[0]!=0)||(eq[1]!=0)||(eq[2]!=0)) {		
				somme_value=0;somme_x=0;somme_y=0;ydebut=0;ydebut=0;xfin=0;yfin=0;
				//recherche du centre de la trace
				for (k1=0;k1<n1;k1++) {
					for (k2=0;k2<n2;k2++) {
						if (eq[2]!=0) { //cas des droites verticales
							if (k1<eq[2]-2) {continue;}	
							if (k1>eq[2]+2) {break;}
						} else if (eq[0]<-1) {//cas des fortes pentes n�gatives
							if (eq[0]*(k1+2)+eq[1]>n2) break;
							if (eq[0]*(k1+2)+eq[1]<0) continue;
							if (k2<eq[0]*(k1+2)+eq[1]) {continue;}	
							if (k2>eq[0]*(k1-2)+eq[1]) {break;}
						} else if ((eq[0]<1)&&(eq[0]>-1)) {//cas des droites a faibles pentes
							if (eq[0]*k1+eq[1]-2<0) continue;
							if (k2<eq[0]*k1+eq[1]-2) continue;
							if (k2>eq[0]*k1+eq[1]+2) break;

						} else if ((eq[0]==0)&&(eq[2]==0)) { //cas des droites horizontales
							if (k2<eq[1]-2) {continue;}	
							if (k2>eq[1]+2) {break;}
						} else { //cas des droites a fortes pentes positives
							if (k2<eq[0]*(k1-2)+eq[1]) {continue;}	
							if (k2>eq[0]*(k1+2)+eq[1]) {break;}
						}
						dvalue=(double)p_tmp3->p[n2*k2+k1];
						somme_value= somme_value+dvalue;
						somme_x=somme_x+k1*dvalue;	
						somme_y=somme_y+k2*dvalue;	
					}
				}			
				if (somme_value!=0) {
					// coordonn�es du centre dans la grande image
					somme_x=somme_x*1.0/somme_value;
					somme_y=somme_y*1.0/somme_value;
					nbnul=0;
					if (somme_x<0) somme_x=0;
					if (somme_x>n1) somme_x=n1-1;
					if (somme_y<0) somme_y=0;
					if (somme_y>n2) somme_y=n2-1;
					for (k1=(int)somme_x;k1>0;k1--) {
						if (nbnul>40) break;
						k2=(int)somme_y;
						while (1) {
							if (eq[0]<0) {
								if (k2<n2) k2++;
								else break;
							} else {
								if (k2>0) k2--;
								else break;
							}							
							if (nbnul>40) break;
							if (eq[2]!=0) {//droites verticales
								if (k1<eq[2]-1) {break;}	
								if (k1>eq[2]+1) {continue;}
							} else if (eq[0]<-1) {
								if (k2<eq[0]*(k1+1)+eq[1]) {continue;}	
								if (k2>eq[0]*(k1-1)+eq[1]) {break;}
							} else if ((eq[0]<1)&&(eq[0]>-1)) {//cas des droites a tr�s faibles pentes
								if (eq[0]>0) {
									if (eq[0]*k1+eq[1]-1<0) break;
									if (k2<eq[0]*k1+eq[1]-1) break;
									if (k2>eq[0]*k1+eq[1]+1) continue;
								} else {
									if (eq[0]*k1+eq[1]+1>n2) break;
									if (k2<eq[0]*k1+eq[1]-1) continue;
									if (k2>eq[0]*k1+eq[1]+1) break;
								}
							} else if ((eq[0]==0)&&(eq[2]==0)) { //cas des droites horizontales
								if (k2<eq[1]-2) {break;}	
								if (k2>eq[1]+2) {continue;}
							} else {
								if (k2<eq[0]*(k1-1)+eq[1]) {break;}	
								if (k2>eq[0]*(k1+1)+eq[1]) {continue;}
							}
							//debut tra�n�e quand p_out->p = fond de ciel
							dvalue=(double)p_out->p[naxis2*(k2+k3*n2+(kk)*n2/2)+k1+k5+(kk)*n1/2];
							if (dvalue<=bg) {
								nbnul++;
								if (nbnul==1) {
									xdebut=k1;
									ydebut=k2;
								} 
							}
							if ((dvalue>bg)&&(nbnul<40)) {
								nbnul=(int)(nbnul/3.0);
							}	
						}
					}
					nbnul=0;
					for (k1=(int)somme_x;k1<n1;k1++) {
						if (nbnul>40) break;
						k2=(int)somme_y;
						while (1) {
							if (eq[0]<0) {
								if (k2>0) k2--;
								else break;
							} else {
								if (k2<n2) k2++;
								else break;
							}						
							if (nbnul>40) break;
							if (eq[2]!=0) {
								if (k1<eq[2]-1) {continue;}	
								if (k1>eq[2]+1) {break;}
							} else if (eq[0]<-1) {
								if (k2<eq[0]*(k1+1)+eq[1]) {break;}	
								if (k2>eq[0]*(k1-1)+eq[1]) {continue;}
							} else if ((eq[0]<1)&&(eq[0]>-1)) {//cas des droites a tr�s faibles pentes
								if (eq[0]>0) {
									if (eq[0]*k1+eq[1]+1>n2) break;
									if (k2<eq[0]*k1+eq[1]-1) continue;
									if (k2>eq[0]*k1+eq[1]+1) break;
								} else {
									if (eq[0]*k1+eq[1]-1<0) break;
									if (k2<eq[0]*k1+eq[1]-1) break;
									if (k2>eq[0]*k1+eq[1]+1) continue;
								}
							} else if ((eq[0]==0)&&(eq[2]==0)) { //cas des droites horizontales
								if (k2<eq[1]-2) {continue;}	
								if (k2>eq[1]+2) {break;}
							} else {
								if (k2<eq[0]*(k1-1)+eq[1]) {continue;}	
								if (k2>eq[0]*(k1+1)+eq[1]) {break;}
							}
							//recherche la fin de la tra�n�e				
							dvalue=(double)p_out->p[naxis2*(k2+k3*n2+(kk)*n2/2)+k1+k5+(kk)*n1/2];
							if (dvalue<=bg) {
								nbnul++;
								if (nbnul==1) {
									xfin=k1;
									yfin=k2;
								} 
							}
							if ((dvalue>bg)&&(nbnul<40)) {
								nbnul=(int)(nbnul/3.0);
							}	
						}				
					}
					if (xdebut<0) {xdebut=0;}
					if (xfin<0) {xfin=0; xdebut=0;}
					if (ydebut<0) {ydebut=0;}
					if (yfin<0) {yfin=0; ydebut=0;}
					if (xfin>n1) {xfin=n1-1;}
					if (xdebut>n1) {xfin=n1-1;xdebut=n1-1;}
					if (yfin>n2) {yfin=n2-1;}
					if (ydebut>n2) {yfin=n2-1;ydebut=n2-1;}

				} else {
					somme_x=0;xdebut=0;xfin=0;
					somme_y=0;ydebut=0;yfin=0;
				}
				
				/* -------------------------------------------------- */
				/* --- si la trace deborde sur une autre imagette --- */
				/* -------------------------------------------------- */				
				if ((xfin>n1-10)||(yfin>n2-10)||(xdebut<10)||(ydebut<10)||(xdebut>n1-10)||(ydebut>n2-10)||(xfin<10)||(yfin<10)) {	
					bord=0;

					if (kkk%nb_ss_image1==1) {
						if (somme_y<n2/2) bord=1;
					}				
					if (kkk%nb_ss_image1==(nb_ss_image1-1)) {
						if (somme_y>n2/2) bord=1;
					}

					if (kkk<nb_ss_image1) {
						if (somme_y<n2/2) bord=1;
						if (kkk==0) {
							if (somme_x<n1/2) bord=1;
						}
						if (kkk==7) {
							if (somme_x>n1/2) bord=1;
						}
					}
					if (kkk>=nb_ss_image1*(nb_ss_image2-1)) {
						if (somme_y>n2/2) bord=1;
						if (kkk==nb_ss_image1*(nb_ss_image2-1)) {
							if (somme_x<n1/2) bord=1;
						}
						if (kkk==nb_ss_image1*nb_ss_image2-1) {
							if (somme_x>n1/2) bord=1;
						}
					}	
					
					if (bord!=1) {
						//on prend une nouvelle imagette centr�e sur le barycentre calcul� pr�c�dement
						for (k1=0;k1<n1;k1++) {
							for (k2=0;k2<n2;k2++) {
								dvalue=(double)p_tmp2->p[naxis2*(k2+k3*n2+(kk-1)*n2/2+(int)somme_y)+k1+k5+(int)somme_x+(kk-1)*n1/2];
								p_tmp3->p[n2*k2+k1]=(TT_PTYPE)(dvalue);
							}
						}
				
						tt_ima_series_hough_myrtille(p_tmp3,p_tmp4,n1,n2,1,eq);
						//tt_imasaver(p_tmp3,"D:/gtopetite2.fit",16);
						//recup�re les coordonn�es de la droite d�tect�e y=a0*x+b0
						if ((eq[0]!=0)||(eq[1]!=0)||(eq[2]!=0)) {
							somme_value2=0;somme_x2=0;somme_y2=0;xdebut=0;ydebut=0;
							//recherche du centre de la trace
								for (k1=0;k1<n1;k1++) {
									for (k2=0;k2<n2;k2++) {
										if (eq[2]!=0) {
											if (k1<eq[2]-2) {continue;}	
											if (k1>eq[2]+2) {break;}
										} else if (eq[0]<-1) {
											if (eq[0]*(k1+2)+eq[1]>n2) break;
											if (eq[0]*(k1+2)+eq[1]<0) continue;
											if (k2<eq[0]*(k1+2)+eq[1]) {continue;}	
											if (k2>eq[0]*(k1-2)+eq[1]) {break;}
										} else if ((eq[0]<=1)&&(eq[0]>=-1)) {//cas des droites a tr�s faibles pentes
											if (eq[0]*k1+eq[1]-2<0) continue;
											if (eq[0]*k1+eq[1]-2>n2) break;
											if (k2<eq[0]*k1+eq[1]-2) continue;
											if (k2>eq[0]*k1+eq[1]+2) break;
										} else if ((eq[0]==0)&&(eq[2]==0)) { //cas des droites horizontales
											if (k2<eq[1]-2) {continue;}	
											if (k2>eq[1]+2) {break;}
										} else {
											if (k2<eq[0]*(k1-2)+eq[1]) {continue;}	
											if (k2>eq[0]*(k1+2)+eq[1]) {break;}
										}
										dvalue=(double)p_tmp3->p[n2*k2+k1];
										somme_value2= somme_value2+dvalue;
										somme_x2=somme_x2+k1*dvalue;
										somme_y2=somme_y2+k2*dvalue;
									}
								}
							if (somme_value2!=0) {
								// coordonn�es du centre dans la grande image
								somme_x2=somme_x2*1.0/somme_value2;
								somme_y2=somme_y2*1.0/somme_value2;
								nbnul=0;
								for (k1=(int)somme_x2;k1>0;k1--) {
									if (nbnul>40) break;
									k2=(int)somme_y2;
									while (1) {
										if (eq[0]<0) {
											if (k2<n2) k2++;
											else break;
										} else {
											if (k2>0) k2--;
											else break;
										}							
										if (nbnul>40) break;
										if (eq[2]!=0) {
											if (k1<eq[2]-1) {break;}	
											if (k1>eq[2]+1) {continue;}
										} else if (eq[0]<-1) {
											if (k2<eq[0]*(k1+1)+eq[1]) {continue;}	
											if (k2>eq[0]*(k1-1)+eq[1]) {break;}
										} else if ((eq[0]<1)&&(eq[0]>-1)) {//cas des droites a tr�s faibles pentes
											if (eq[0]>0) {
												if (eq[0]*k1+eq[1]-1<0) break;
												if (k2<eq[0]*k1+eq[1]-1) break;
												if (k2>eq[0]*k1+eq[1]+1) continue;
											} else {
												if (eq[0]*k1+eq[1]+1>n2) break;
												if (k2<eq[0]*k1+eq[1]-1) continue;
												if (k2>eq[0]*k1+eq[1]+1) break;
											}
										} else if ((eq[0]==0)&&(eq[2]==0)) { //cas des droites horizontales
											if (k2<eq[1]-2) {break;}	
											if (k2>eq[1]+2) {continue;}
										} else {
											if (k2<eq[0]*(k1-1)+eq[1]) {break;}	
											if (k2>eq[0]*(k1+1)+eq[1]) {continue;}
										}
										//debut tra�n�e quand p_in->p = fond de ciel
										dvalue=(double)p_out->p[naxis2*(k2+k3*n2+(kk-1)*n2/2+(int)somme_y)+k1+k5+(int)somme_x+(kk-1)*n1/2];
										if (dvalue<=bg) {
											nbnul++;
											if (nbnul==1) {
												xdebut=k1;
												ydebut=k2;
											} 
										}
										if ((dvalue>bg)&&(nbnul<40)) {
											nbnul=(int)(nbnul/3.0);
										}
										
									}
								}
								nbnul=0;
								for (k1=(int)somme_x2;k1<n1;k1++) {
									if (nbnul>40) break;
									k2=(int)somme_y2;
									while (1) {
										if (eq[0]<0) {
											if (k2>0) k2--;
											else break;
										} else {
											if (k2<n2) k2++;
											else break;
										}		
										if (nbnul>40) break;
										if (eq[2]!=0) {
											if (k1<eq[2]-1) {continue;}	
											if (k1>eq[2]+1) {break;}
										} else if (eq[0]<-1) {
											if (k2>eq[0]*(k1-1)+eq[1]) {continue;}
											if (k2<eq[0]*(k1+1)+eq[1]) {break;}
										} else if ((eq[0]<1)&&(eq[0]>-1)) {//cas des droites a tr�s faibles pentes
											if (eq[0]>0) {
												if (eq[0]*k1+eq[1]+1>n2) break;
												if (k2<eq[0]*k1+eq[1]-1) continue;
												if (k2>eq[0]*k1+eq[1]+1) break;
											} else {
												if (eq[0]*k1+eq[1]-1<0) break;
												if (k2<eq[0]*k1+eq[1]-1) break;
												if (k2>eq[0]*k1+eq[1]+1) continue;
											}
										} else if ((eq[0]==0)&&(eq[2]==0)) { //cas des droites horizontales
											if (k2<eq[1]-2) {continue;}	
											if (k2>eq[1]+2) {break;}
										} else {
											if (k2<eq[0]*(k1-3)+eq[1]) {continue;}
											if (k2>eq[0]*(k1+3)+eq[1]) {break;}
										}
										//recherche la fin de la tra�n�e				
										dvalue=(double)p_out->p[naxis2*(k2+k3*n2+(kk-1)*n2/2+(int)somme_y)+k1+k5+(int)somme_x+(kk-1)*n1/2];
										if (dvalue<=bg) {
											nbnul++;
											if (nbnul==1) {
												xfin=k1;
												yfin=k2;
											} 
										}
										if ((dvalue>bg)&&(nbnul<40)) {
											nbnul=(int)(nbnul/3.0);
										}										
									}
								}			
							} else {
								somme_x=0;xdebut=0;xfin=0;
								somme_y=0;ydebut=0;yfin=0;
							}
							//changement de rep�re: 
							if (eq[2]==0) {
								eq[1]=somme_y-n2/2+eq[1]-eq[0]*(somme_x-n1/2);	
							}									
							xdebut=xdebut+somme_x-n1/2;
							ydebut=ydebut+somme_y-n2/2;
							xfin=xfin+somme_x-n1/2;
							yfin=yfin+somme_y-n2/2;
							somme_x=somme_x2+somme_x-n1/2;
							somme_y=somme_y2+somme_y-n2/2;
						}	
					}
				}
				//changement de rep�re: petite image -> grande image
				if (eq[2]==0) {
					eq[1]=eq[1]-(k5+kk*n1/2)*eq[0]+(k3)*256+kk*n2/2;
				}
				if ((somme_x!=0)&&(somme_y!=0)) {
					somme_x=somme_x+k5+kk*n1/2;
					somme_y=somme_y+(k3)*256+kk*n2/2;
					xdebut=xdebut+k5+kk*n1/2;
					ydebut=ydebut+(k3)*256+kk*n2/2;
					xfin=xfin+k5+kk*n1/2;
					yfin=yfin+(k3)*256+kk*n2/2;
					
					/* --- calcul de la longueur de la tra�n�e --- */
					l=sqrt((xdebut-xfin)*(xdebut-xfin)+(ydebut-yfin)*(ydebut-yfin));

					if (l>4) {
						/* ------------------------------------------ */
						/* --- ajustement par les moindres carr�s --- */
						/* ------------------------------------------ */
						for (nb=0;nb<300;nb++) {
								bary_x[nb]=0;
								bary_y[nb]=0;
								somme[nb]=0;
						}
						/* --- recherche de la largeur des train�es --- */
						if ((eq[0]>1)||(eq[0]<-1)||(eq[2]!=0)) { // droites non horizontales, droites verticales
							largx=0;nb=0;
							k2=(int)ydebut;
							while (1) {
								if (eq[0]<0) {
									if (k2>yfin) k2--;
									else break;
								} else {
									if (k2<yfin) k2++;
									else break;
								}	
								largxx=0;
								if (eq[2]!=0) { //droites verticales
									for (k1=(int)(eq[2]);k1<=(int)(eq[2]+10);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										if (p_tmp2->p[naxis1*k2+k1]>0) largxx++;
									}
										for (k1=(int)(eq[2]-10);k1<(int)(eq[2]);k1++) {						
										if (k1<0) continue;
										if (k1>=naxis1) break;
										if (p_tmp2->p[naxis1*k2+k1]>0) largxx++;
									}
									if (largxx!=0) {
										largx+=largxx;
										nb++;
									}
								} else {
									for (k1=(int)((k2-eq[1])/eq[0]-10);k1<(int)((k2-eq[1])/eq[0]);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										if (p_tmp2->p[naxis1*k2+k1]>0) largxx++;
									}
									for (k1=(int)((k2-eq[1])/eq[0]);k1<=(int)((k2-eq[1])/eq[0]+10);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										if (p_tmp2->p[naxis1*k2+k1]>0) largxx++;
									}
									if (largxx!=0) {
										largx+=largxx;
										nb++;
									}
								}	
							}							
							if (nb != 0) {
								largx=(int)(largx*1.0/(2.0*nb))+1;
							}
							
						} else {
							largx=0;nb=0;
							for (k1=(int)xdebut;k1<(int)xfin;k1++) {
								largxx=0;
								for (k2=(int)(eq[0]*k1+eq[1]-10);k2<(int)(eq[0]*k1+eq[1]);k2++) {
									if (k2<0) continue;
									if (k2>=naxis2) break;
									if (p_tmp2->p[naxis1*k2+k1]>0) largxx++;									
								}
								for (k2=(int)(eq[0]*k1+eq[1]);k2<=(int)(eq[0]*k1+eq[1]+10);k2++) {		
									if (k2<0) continue;
									if (k2>=naxis2) break;
									if (p_tmp2->p[naxis1*k2+k1]>0) largxx++;
								}
								if (largxx!=0) {
									largx+=largxx;
									nb++;
								}												
							}
							if (nb != 0) {
								largx=(int)(largx*1.0/(2.0*nb))+1;
							}
						}
						
						if (largx<3) { largx=3;}

						// echantillon des barycentres sur chaque ligne de pixel
						if ((eq[0]>1)||(eq[0]<-1)||(eq[2]!=0)) { // droites non horizontales, droites verticales, droites forte pente
							i=0;
							k2=(int)ydebut;
							while (1) {
								if (eq[0]<0) {
									if (k2>yfin) k2--;
									else break;
								} else {
									if (k2<yfin) k2++;
									else break;
								}	
								if (eq[2]==0) {
									for (k1=(int)((k2-eq[1])/eq[0]-largx);k1<=(int)((k2-eq[1])/eq[0]+largx);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										dvalue=(double)p_out->p[naxis1*k2+k1];
										if (dvalue>2) {
											somme[i]= somme[i]+dvalue;
											bary_x[i]=bary_x[i]+k1*dvalue;
										}
									}	
									if ((somme[i]!=0)&&(bary_x[i]!=0)) {
										i++;
									}
								} else  {
									for (k1=(int)(eq[2]-largx);k1<=(int)(eq[2]+largx);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										dvalue=(double)p_out->p[naxis1*k2+k1];
										if (dvalue>2) {
											somme[i]= somme[i]+dvalue;
											bary_x[i]=bary_x[i]+k1*dvalue;
										}
									}	
									if ((somme[i]!=0)&&(bary_x[i]!=0)) {
										i++;
									}
								}
							} 
							sommexy=0;sommex=0;sommey=0;sommexx=0;
							if (eq[0]<0) {
								for (nb=0; nb<i; nb++) {
									if (somme[nb]!=0) {
										bary_x[nb]=bary_x[nb]*1.0/somme[nb];
										sommexy=sommexy+bary_x[nb]*(ydebut-nb);
										sommex=sommex+bary_x[nb];
										sommey=sommey+(ydebut-nb);
										sommexx=sommexx+bary_x[nb]*bary_x[nb];
									} else {
										bary_x[nb]=0;
									}
								}
							} else {
								for (nb=0; nb<i; nb++) {
									if (somme[nb]!=0) {
										bary_x[nb]=bary_x[nb]*1.0/somme[nb];
										sommexy=sommexy+bary_x[nb]*(ydebut+nb);
										sommex=sommex+bary_x[nb];
										sommey=sommey+(ydebut+nb);
										sommexx=sommexx+bary_x[nb]*bary_x[nb];
									} else {
										bary_x[nb]=0;
									}
								}
							}
						} else  { 
							i=0;
							for (k1=(int)xdebut;k1<(int)xfin;k1++) {
								for (k2=(int)(eq[0]*k1+eq[1]-largx);k2<=(int)(eq[0]*k1+eq[1]+largx);k2++) {
									if (k2<0) continue;
									if (k2>=naxis2) break;
									dvalue=(double)p_out->p[naxis1*k2+k1];
									if (dvalue>2) {
										somme[i]= somme[i]+dvalue;
										bary_y[i]=bary_y[i]+k2*dvalue;
									}
								}	
								if ((somme[i]!=0)&&(bary_y[i]!=0)) {
									i++;
								}
							} 
							sommexy=0;sommex=0;sommey=0;sommexx=0;							
							for (nb=0; nb<i; nb++) {		
								if (somme[nb]!=0) {
									bary_y[nb]=bary_y[nb]*1.0/somme[nb];
									sommexy=sommexy+(xdebut+nb)*bary_y[nb];
									sommex=sommex+(xdebut+nb);
									sommey=sommey+bary_y[nb];
									sommexx=sommexx+(xdebut+nb)*(xdebut+nb);
								} else {
									bary_y[nb]=0;
								}
							}	
						}
						
						if ((eq[2]==0)&&((sommexx!=0)||(sommex!=0))) {
							if ((i*sommexx-sommex*sommex)!=0) {								
								eq[0]=(i*sommexy-sommex*sommey)/(i*sommexx-sommex*sommex);		
								eq[1]=(sommey*sommexx-sommex*sommexy)/(i*sommexx-sommex*sommex);
							}
						} else if (eq[2]!=0) {
							eq[2]=sommex/i;
						}

						/* --- recherche plus fine des bouts du segment --- */
						if (eq[2]==0) {
							if (eq[0]!=0) { 
								dvalue=ydebut;
								ydebut=(eq[1]/(eq[0]*eq[0])+ydebut+xdebut/eq[0])/(1+1/(eq[0]*eq[0]));
								xdebut=(dvalue-eq[1])/eq[0];
								dvalue=yfin;
								yfin=(eq[1]/(eq[0]*eq[0])+yfin+xfin/eq[0])/(1+1/(eq[0]*eq[0]));
								xfin=(dvalue-eq[1])/eq[0];
							} else {
								ydebut=eq[1];
								yfin=eq[1];
							}
						} else {
							xdebut=eq[2];
							xfin=eq[2];
						}

						/* --- mise a zero pour la d�tection des geo --- */
						if (eq[0]>=0) {
							for (k1=(int)xdebut-largx-2;k1<(int)xfin+largx+2;k1++) {
								for (k2=(int)ydebut-largx-2;k2<(int)yfin+largx+2;k2++) {
									if ((k1<0)||(k2<0)) continue;
									if (k1>=naxis1) break;
									if (k2>=naxis2) break;
									//mettre a zero les pixels concern�s pour ne pour ne pas avoir deux fois la tra�n�es
									if (eq[2]!=0) {
										if (k2<eq[2]-largx-2) {continue;}
										if (k2>eq[2]+largx+2) break;
									} else if (eq[0]<1) {
										if (k2<eq[0]*k1-largx-2+eq[1]) {continue;}
										if (k2>eq[0]*k1+largx+2+eq[1]) break;
									} else {
										if (k2<eq[0]*(k1-largx-2)+eq[1]) {continue;}
										if (k2>eq[0]*(k1+largx+2)+eq[1]) break;
									}
									p_tmp1->p[naxis2*(k2)+k1]=0;
									p_tmp2->p[naxis2*(k2)+k1]=0;
								}
							}	
						} else {//ydebut>yfin
							for (k1=(int)xdebut-largx-2;k1<(int)xfin+largx+2;k1++) {
								for (k2=(int)yfin-largx-2;k2<(int)ydebut+largx+2;k2++) {
									if ((k1<0)||(k2<0)) continue;
									if (k1>=naxis1) break;
									if (k2>=naxis2) break;
									if (eq[0]<=-1) {
										if (k2<eq[0]*(k1+largx+2)+eq[1]) {continue;}
										if (k2>eq[0]*(k1-largx-2)+eq[1]) break;
										p_tmp1->p[naxis2*(k2)+k1]=0;
										p_tmp2->p[naxis2*(k2)+k1]=0;
									} else {
										if (k2<eq[0]*k1+largx+2+eq[1]) {continue;}
										if (k2>eq[0]*k1-largx-2+eq[1]) break;
										p_tmp1->p[naxis2*(k2)+k1]=0;
										p_tmp2->p[naxis2*(k2)+k1]=0;
									}
								}
							}
						}
						//tt_imasaver(p_tmp2,"D:/gto2.fit",16);
						/* ---------------------------------------------------- */
						/* --- enregistrer l'equation de la droite d�tect�e --- */
						/* ---------------------------------------------------- */					
						fprintf(fic,"%d %f %f %f %f %f %f %f %f %f\n",ngto,eq[0],eq[1],eq[2],somme_x,somme_y,xdebut,ydebut,xfin,yfin);	
						ngto++;
					}
				}
			}	
			k=k+n1;
			k5=k-k3*(naxis1-2*kk*n1);
			k3=(int)(kkk+1)/(8-2*kk);
		}
	}
	fclose(fic);

/* ------------------------------- */
/* --- sortir la liste des geo --- */
/* ------------------------------- */
	// se servir des tra�n�es d�tect�es pour les �liminer de la liste des geo
	//geo - gto = tmp1, il faut eliminer les bords pour une largeur de SE
	//tt_imasaver(p_tmp1,"D:/geo2.fit",16);
	fic=fopen(filenamegeo,"wt");
	/* --- lit les parametres astrometriques de l'image ---*/
	valid_ast=1;
	tt_util_getkey0_astrometry(p_in,&p_ast,&valid_ast);
	nsats=0;
	//boucle de recherche sur l'image
	for (y=y1+1;y<naxis2-y1-1;y++) {
		for (x=x1+1;x<naxis1-x1-1;x++) {
			if (p_tmp1->p[y*naxis2+x]==0) {	continue;}
			//elimine les cosmiques
			fwhmx=0;
			for (k=x;k<=(naxis1-2);k++) {
				if ((p_in->p[naxis1*y+k]-p_in->p[naxis1*y+k+1])<=0) break;
				else fwhmx+=1;
		    }		           
		    for (k=x;k>=1+x1;k--) {
				if ((p_in->p[naxis1*y+k]-p_in->p[naxis1*y+k-1])<=0) break;
		        else fwhmx+=1;
		    }  
            fwhmx/=2.;
		        
		    fwhmy=0;
           	for (k=y;k<(naxis2-y1);k++) {
				if ((p_in->p[naxis1*k+x]-p_in->p[naxis1*(k+1)+x])<=0) break;
		        else fwhmy+=1;
		    }		         
		    for (k=y;k>=1+y1;k--) {
		        if ((p_in->p[naxis1*k+x]-p_in->p[naxis1*(k-1)+x])<=0) break;
		        else fwhmy+=1;
		    }
			fwhmy/=2.;

			if ((fwhmx>1.)&&(fwhmy>1.)) {//ce n'est pas un cosmique
				/* --- parametres de mesure precise ---*/
                xcc=(double)x;
                ycc=(double)y;
                fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
                r1=1.5*fwhmxy;
                r2=2.0*fwhmxy;
                r3=2.5*fwhmxy;
                r11=r1*r1;
                r22=r2*r2;
                r33=r3*r3;
                /* --- fond de ciel precis (fmoy,fmed,sigma) ---*/
                xx1=(int)(xcc-r3);
                xx2=(int)(xcc+r3);
                yy1=(int)(ycc-r3);
                yy2=(int)(ycc+r3);
                if (xx1<0) xx1=0;
                if (xx1>=naxis1) xx1=naxis1-1;
                if (xx2<0) xx2=0;
                if (xx2>=naxis1) xx2=naxis1-1;
                if (yy1<0) yy1=0;
                if (yy1>=naxis2) yy1=naxis2-1;
                if (yy2<0) yy2=0;
                if (yy2>=naxis2) yy2=naxis2-1;
                nombre=(xx2-xx1+1)*(yy2-yy1+1);
                taille=sizeof(double);
                vec=NULL;
				if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec,&nombre,&taille,"vf"))!=OK_DLL) {
                   fclose(fic);
                   tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_util_geostat (pointer vec)");
                   return(TT_ERR_PB_MALLOC);
                }
                n23=0;
                f23=0.;
                for (j=yy1;j<=yy2;j++) {
                   dy=1.*j-ycc;
                   dy2=dy*dy;
                   for (i=xx1;i<=xx2;i++) {
                      dx=1.*i-xcc;
                      dx2=dx*dx;
                      d2=dx2+dy2;
                      if ((d2>=r22)&&(d2<=r33)) {
	                      vec[n23]=(double)p_in->p[naxis1*j+i];
                         f23 += (double)p_in->p[naxis1*j+i];
                         n23++;
                      }
                   }
                }
                tt_util_qsort_double(vec,0,n23,NULL);
                fmoy=vec[0];
                if (n23!=0) {fmoy=f23/n23;}
                /* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
                fmed=(float)vec[(int)(0.5*n23)];
                /*  calcul de l'ecart type du fond de ciel*/
                /*  en excluant les extremes a +/- 10 %*/
                sigma=0.;
                n23d=(int)(0.1*(n23-1));
                n23f=(int)(0.9*(n23-1));
                for (i=n23d;i<=n23f;i++) {
                   d2=(vec[i]-fmed);
                   sigma+=(d2*d2);
                }
                if ((n23f-n23d)!=0) {
                   sigma=sqrt(sigma/(n23f-n23d));
                }
                free(vec);
			
				//fitte une gaussienne pour la recherche du centroide
				xx1=(int)(xcc-r2);
                xx2=(int)(xcc+r2);
                yy1=(int)(ycc-r2);
                yy2=(int)(ycc+r2);
                if (xx1<0) xx1=0;
                if (xx1>=naxis1) xx1=naxis1-1;
                if (xx2<0) xx2=0;
                if (xx2>=naxis1) xx2=naxis1-1;
                if (yy1<0) yy1=0;
                if (yy1>=naxis2) yy1=naxis2-1;
                if (yy2<0) yy2=0;
                if (yy2>=naxis2) yy2=naxis2-1;
      
				pp = (double*)calloc(6,sizeof(double));
				ecart = (double*)calloc(1,sizeof(double));
				sizex=xx2-xx1+1;
				sizey=yy2-yy1+1;

				//fixe la taille de la fen�tre de travail: sizex et sizey
				mat = (double**)calloc(sizex,sizeof(double));
				for(k=0;k<sizex;k++) {
					*(mat+k) = (double*)calloc(sizey,sizeof(double));
				}
				//--- Mise a zero des deux buffers 
				for(k=0;k<sizex;k++) {
					for(k2=0;k2<sizey;k2++) {
						mat[k][k2]=(double)0.;
					}
				}
				for (j=0;j<sizey;j++) {  
				   for (i=0;i<sizex;i++) {	  
					  mat[i][j]=p_in->p[naxis1*(j+yy1)+i+xx1];
				   }
				}

				tt_fitgauss2d (sizex,sizey,mat,pp,ecart);
				xcc=pp[1]+xx1;
				ycc=pp[4]+yy1;

				//avec le vrai centroide
				fwhmx=0;
				for (k=(int)xcc;k<=(naxis1-2);k++) {
					if ((p_in->p[naxis1*(int)ycc+k]-p_in->p[naxis1*(int)ycc+k+1])<=0) break;
					else fwhmx+=1;
				}		           
				for (k=(int)xcc;k>=1+x1;k--) {
					if ((p_in->p[naxis1*(int)ycc+k]-p_in->p[naxis1*(int)ycc+k-1])<=0) break;
					else fwhmx+=1;
				}  
				fwhmx/=2.;
					
				fwhmy=0;
           		for (k=(int)ycc;k<(naxis2-y1);k++) {
					if ((p_in->p[naxis1*k+(int)xcc]-p_in->p[naxis1*(k+1)+(int)xcc])<=0) break;
					else fwhmy+=1;
				}		         
				for (k=(int)ycc;k>=1+y1;k--) {
					if ((p_in->p[naxis1*k+(int)xcc]-p_in->p[naxis1*(k-1)+(int)xcc])<=0) break;
					else fwhmy+=1;
				}
				fwhmy/=2.;
				fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
                r1=1.5*fwhmxy;
                r2=2.0*fwhmxy;
            
				/* --- photometrie (flux) ---*/
                xx1=(int)(xcc-r1);
                xx2=(int)(xcc+r1);
                yy1=(int)(ycc-r1);
                yy2=(int)(ycc+r1);
                if (xx1<0) xx1=0;
                if (xx1>=naxis1) xx1=naxis1-1;
                if (xx2<0) xx2=0;
                if (xx2>=naxis1) xx2=naxis1-1;
                if (yy1<0) yy1=0;
                if (yy1>=naxis2) yy1=naxis2-1;
                if (yy2<0) yy2=0;
                if (yy2>=naxis2) yy2=naxis2-1;
                flux=0.;
                for (j=yy1;j<=yy2;j++) {
                   dy=1.*j-ycc;
                   dy2=dy*dy;
                   for (i=xx1;i<=xx2;i++) {
                      dx=1.*i-xcc;
                      dx2=dx*dx;
                      d2=dx2+dy2;
                      dvalue=(double)p_in->p[naxis1*j+i]-fmed;
                      if ((d2<=r11)) {
                         flux += dvalue;
                      }
                   }
                }
                /* --- astrometrie (ra,dec) ---*/
                ra=0.;
                dec=0.;
                if (valid_ast==TT_YES) {
                   tt_util_astrom_xy2radec(&p_ast,xcc,ycc,&ra,&dec);
                }
                ra*=180./(TT_PI);
                dec*=180./(TT_PI);
                /* --- sortie du resultat ---*/
			    fprintf(fic,"%d %f %f %f %f %f %f %f %f\n",nsats,xcc+1.,ycc+1.,flux,fmed,ra,dec,fwhmx,fwhmy);
				nsats++;

				xx1=(int)(xcc-r2);
				xx2=(int)(xcc+r2);
				if (x<xx1) {xx1=(int)(x-r2);}
				if (x>xx2) {xx2=(int)(x+r2);}
				yy1=(int)(ycc-r2);
				yy2=(int)(ycc+r2);
				if (y<yy1) {yy1=(int)(y-r2);}
				if (y>yy2) {yy2=(int)(y+r2);}
				if (xx1<0) xx1=0;
				if (xx1>=naxis1) xx1=naxis1-1;
				if (xx2<0) xx2=0;
				if (xx2>=naxis1) xx2=naxis1-1;
				if (yy1<0) yy1=0;
				if (yy1>=naxis2) yy1=naxis2-1;
				if (yy2<0) yy2=0;
				if (yy2>=naxis2) yy2=naxis2-1;
				sizex=xx2-xx1+1;
				sizey=yy2-yy1+1;
				for (j=0;j<sizey;j++) {  
					for (i=0;i<sizex;i++) {	  
						  p_tmp1->p[naxis1*(j+yy1)+i+xx1]=0;
					 }
				}
			}
		}
	}
	fclose(fic);

	/* --- calcul des temps ---*/
	pseries->jj_stack=pseries->jj[index-1];
	pseries->exptime_stack=pseries->exptime[index-1];

	result=0;
	return result ;
}



//void morphomath (TT_IMA_SERIES *pseries,TT_IMA* p_in,TT_IMA* p_out,char* nom_trait, char* struct_elem,int x1,int y1)
int tt_morphomath_1 (TT_IMA_SERIES *pseries)
/****************************************************************************/
/* trait morpho math sur image dans buffer						            */
/****************************************************************************/
/****************************************************************************/
//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 imaseries "MORPHOMATH nom_trait=TOPHAT struct_elem=RECTANGLE x1=10 y1=1"
//buf1 imaseries "MORPHOMATH nom_trait=$nom_Trait struct_elem=$struct_Elem x1=$dim1 y1=$dim2"
//pour le moment les SE seront de dimensions impaires pour avoir un centre centr�!

{
	TT_IMA *p_tmp1, *p_tmp2, *p_in, *p_out;
	int i,kkk,x,y,j;
	int size, nelem,naxis1,naxis2,sizex,sizey, sizex2,sizey2,size2;
	int *se = NULL,*medindice=NULL,*se2 = NULL;
	double *med =NULL;
	double dvalue;//hicuttemp,locuttemp,sigma;
	double mode1,mini1,maxi1,mode2,mini2,maxi2,seuil;
	char *nom_trait, *struct_elem;
	int x1,y1,x2,y2,result;
	int cx,cy,xx,yy,nb_test,k_test;
	double inf,hicut,locut;

	p_in=pseries->p_in; 
	p_out=pseries->p_out;
	p_tmp1=pseries->p_tmp1;
	p_tmp2=pseries->p_tmp2;
	nelem=pseries->nelements;
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	x1=pseries->x1;
	y1=pseries->y1;
	nom_trait=pseries->nom_trait;
	struct_elem=pseries->struct_elem;

	/* --- intialisations ---*/
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	nelem=naxis1*naxis2;


	/* --- calcul de la fonction ---*/
	if (p_out->naxis1==0) {
		tt_imacreater(p_out,naxis1,naxis2);
	}
	if (p_tmp1->naxis1==0) {
		tt_imacreater(p_tmp1,naxis1,naxis2);
	}
	tt_imacreater(p_tmp2,naxis1,naxis2);
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_out->p[kkk]=(TT_PTYPE)(dvalue);	
		p_tmp1->p[kkk]=(TT_PTYPE)(dvalue);
		p_tmp2->p[kkk]=(TT_PTYPE)(dvalue);
	}
	

	if (x1%2 != 1) {
		x1=x1+1;
	}
	if (y1%2 != 1) {
		y1=y1+1;
	}

	/* ------------------------------------------- */
	/* ---- creation de l'�l�ment structurant ---- */
	/* ------------------------------------------- */
	
	if (strcmp (struct_elem,"RECTANGLE")==0) {	
		size=x1*y1;
		se=calloc(size,sizeof(int));	
		for (i=0; i<size;i++) {
				se[i]=1;
		}	
		sizex = x1;
		sizey = y1;
		
	} else if (strcmp (struct_elem,"DIAMOND")==0){
		size=x1*y1;
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=0;
		}	
		for (i=0;i<y1;i++) {	
			if (i<y1/2) {
				for (kkk=0;kkk<(2*i+1);kkk++) {
					se[i*(x1-1)+(x1-1)/2+kkk]=1;					
				}
			} else if (i== y1/2) {
				for(kkk=0;kkk<x1;kkk++) {
					se[i*x1-1+kkk]=1;
				}
			} else {
				for (kkk=0;kkk<(2*(y1-i-1)+1);kkk++) {
					se[i*x1+(x1-1)/2+kkk - i+(y1-1)/2]=1;			
				}
			}	
		}		
		sizex = x1;
		sizey = y1;
		
	} else if (strcmp (struct_elem,"CERCLE")==0) {
		// x1 =rayon du cercle
		size=(2*x1+1)*(2*x1+1);
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=0;
		}	
		for (i=0; i<(2*x1+1);i++) {
			for (j=0; j<(2*x1+1);j++) {
				if (((i-x1)*(i-x1)+(j-x1)*(j-x1))<(x1+0.5)*(x1+0.5)) {
						se[j*(2*x1+1)+i]=1;
				}
			}
		}		
		sizex = x1;
		sizey = x1;
		
	} else {
		//forme libre � donner
		//se[0] est en bas � gauche de SE

		x1=13;
		y1=1;
		size=x1*y1;
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=1;
		}
		sizex = x1;
		sizey = y1;
	}
	
	
	/* --------------------------------------------------------- */
	/* --- appel de la fonction de traitement de morpho_math --- */
	/* --------------------------------------------------------- */
	i=strcmp (nom_trait,"DILATE");

	if (i==0) {
			dilate (p_out,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 
	i=strcmp (nom_trait,"ERODE");
	if (i==0) {
			erode (p_out,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 	
	i=strcmp (nom_trait,"OPEN");
	if (i==0) {
			erode (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 
	i=strcmp (nom_trait,"CLOSE");
	if (i==0) {
			dilate (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
			erode (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 

	i=strcmp (nom_trait,"TOPHAT");
	//filtre chapeau de haut forme classique
	if (i==0) {
		//ouverture de l'image initiale
		erode (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
		dilate (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);

		//r�duction de la dynamique des images et calcul des seuils de visu
		tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
		hicut=pseries->hicut;
		locut=pseries->locut;
		tt_util_histocuts(p_in,pseries,&(pseries->hicut),&(pseries->locut),&mode1,&mini1,&maxi1);
		tt_util_statima(p_in,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
		//reajustement de l'histogramme en 8bit
		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x])*(float)mode1/(float)mode2;

				if (p_out->p[y*naxis1+x]<mode1-pseries->sigma) {
					p_out->p[y*naxis1+x]=0;
				} else if (p_out->p[y*naxis1+x]>mode1+(pseries->sigma)/2.0) {
					p_out->p[y*naxis1+x]=255;
				} else {
					//p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./(float)(2.0*pseries->sigma);
					/*if (p_out->p[y*naxis1+x]<mode1) {
						if (pseries->locut/locut<1) {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)(pseries->locut/locut);
						} else {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)0.97;
						}
					} else if (p_out->p[y*naxis1+x]>mode1) {
						if (pseries->hicut/hicut>1) {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)(pseries->hicut/hicut);
						} else {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)1.06;
						}
					} else {*/
						p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma));
					//}
				}

				
				if (p_tmp2->p[y*naxis1+x]<mode1-pseries->sigma) {					
					p_tmp2->p[y*naxis1+x]=0;	
				} else if (p_tmp2->p[y*naxis1+x]>mode1+(pseries->sigma)/2.0) {
					p_tmp2->p[y*naxis1+x]=255;
				} else {
					p_tmp2->p[y*naxis1+x]=(p_tmp2->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./(float)(3.0/2.0*pseries->sigma);
				}
				p_out->p[y*naxis1+x]=p_tmp2->p[y*naxis1+x]-p_out->p[y*naxis1+x];		
			}
		}
		//tt_imasaver(p_tmp2,"D:/init2.fit",8);
		//tt_imasaver(p_out,"D:/ouv_de_ferm2.fit",8);

	}
	
	i=strcmp (nom_trait,"TOPHATE");
	if (i==0) {
		//extension du tophat : ouverture d'une fermeture
		// pour traiter le cas des satellites proches (compromis entre tophat excellent et d�tection de satellites proches)
		if (strcmp (struct_elem,"RECTANGLE")==0) {
			x2=(int)(x1*2.0/3.0);
			y2=(int)(y1*2.0/3.0);
			//x2=x1/2;
			//y2=y1/2;
			if (x2%2 != 1) {
				x2=x2+1;
			}
			if (y2%2 != 1) {
				y2=y2+1;
			}
			size2=x2*y2;
			if (size2==0) {size2=1;}
			se2=calloc(size2,sizeof(int));	
			for (i=0; i<size2;i++) {
					se2[i]=1;
			}	
			sizex2 = x2;
			sizey2 = y2;
		} else {
			size2=x1*y1;
			se2=calloc(size2,sizeof(int));
			for (i=0; i<size2;i++) {
				se2[i]=se[i];
			}
			sizex2 = x1;
			sizey2 = y1;
		}
			//fermeture
		dilate (p_tmp1,p_in,se2,x2,y2,sizex2,sizey2,naxis1,naxis2);
		erode (p_out,p_tmp1,se2,x2,y2,sizex2,sizey2,naxis1,naxis2);
			//ouverture
		erode (p_tmp1,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);		
		dilate (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
		
		/* --- Calcul des seuils de visualisation ---*/
		//r�duction de la dynamique des images
		tt_histocuts_myrtille(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
		hicut=pseries->hicut;
		locut=pseries->locut;
		tt_histocuts_myrtille(p_in,pseries,&(pseries->hicut),&(pseries->locut),&mode1,&mini1,&maxi1);
		tt_util_statima(p_in,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
		
		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x])*(float)mode1/(float)mode2;

				if (p_out->p[y*naxis1+x]<mode1-pseries->sigma) {
					p_out->p[y*naxis1+x]=0;
				} else if (p_out->p[y*naxis1+x]>mode1+(pseries->sigma)/2.0) {
					p_out->p[y*naxis1+x]=255;
				} else {
					//p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./(float)(2.0*pseries->sigma);
					if (p_out->p[y*naxis1+x]<mode1) {
						if (pseries->locut/locut<1) {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)(pseries->locut/locut);
						} else {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)0.97;
						}
					} else if (p_out->p[y*naxis1+x]>mode1) {
						if (pseries->hicut/hicut>1) {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)(pseries->hicut/hicut);
						} else {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma))*(float)1.06;
						}
					} else {
						p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma));
					}
				}

				
				if (p_tmp2->p[y*naxis1+x]<mode1-pseries->sigma) {					
					p_tmp2->p[y*naxis1+x]=0;	
				} else if (p_tmp2->p[y*naxis1+x]>mode1+(pseries->sigma)/2.0) {
					p_tmp2->p[y*naxis1+x]=255;
				} else {
					p_tmp2->p[y*naxis1+x]=(p_tmp2->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./(float)(3.0/2.0*pseries->sigma);
				}
				p_out->p[y*naxis1+x]=p_tmp2->p[y*naxis1+x]-p_out->p[y*naxis1+x];		
			}
		}
		//tt_imasaver(p_tmp2,"D:/init2.fit",8);
		//tt_imasaver(p_out,"D:/ouv_de_ferm2.fit",8);
	} 

	i=strcmp (nom_trait,"GRADIENT");
	if (i==0) {
		erode (p_tmp2,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
		dilate (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				p_out->p[y*naxis1+x]=(float)0.5*(p_tmp1->p[y*naxis1+x]-p_tmp2->p[y*naxis1+x]);
			}
		}
	}

	i=strcmp (nom_trait,"CIEL");//m�diane sous condition pour faire une carte du fond de ciel
	if (i==0) {
		//defini le nombre de fois que l'image subit ce traitement
		nb_test=2;
		//calcul du gradient morpho
		for (k_test=1;k_test<=nb_test;k_test++) {
			erode (p_tmp2,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
			for (y=0;y<naxis2;y++) {
				for (x=0;x<naxis1;x++) {
					p_tmp1->p[y*naxis1+x]=(float)0.5*(p_tmp1->p[y*naxis1+x]-p_tmp2->p[y*naxis1+x]);
				}
			}
			tt_util_histocuts(p_tmp1,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
			seuil =(pseries->hicut)*0.4;
			tt_util_histocuts(p_in,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
	
			//enregistre l'image apr�s le traitement de morphologie math�matique
			//	tt_imasaver(p_tmp1,"D:/gradient.fit",16);	

			//erosion par la m�diane si gradient sup�rieur � seuil
			// d�finition du centre de l'�l�ment structurant
			// SE est au milieu du rectangle sizex*sizey
			sizex2=90;
			sizey2=3;
			cx=(sizex2-1)/2;
			cy=(sizey2-1)/2;
			size=sizex2*sizey2;
			med=calloc(size,sizeof(double));
			for (i=0; i<size;i++) {
				med[i]=1;
			}
			//on commence par le coin en bas � gauche de l'image p_out [0][0]
			for (y=cy;y<(naxis2-cy-1);y++) {
				for (x=cx;x<(naxis1-cx);x++) {
					if (p_tmp1->p[y*naxis1+x]<seuil) {continue;}
					//boucle dans la boite englobant le SE
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=-cx;xx<(sizex2-cx);xx++) {	
							med[i]=p_in->p[(yy+y+cy)*naxis1+xx+x+cx];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			//pour les pixel a droite de l'image
			for (y=cy;y<(naxis2-cy-1);y++) {
				for (x=naxis1-cx;x<naxis1;x++) {

					if (p_tmp1->p[y*naxis1+x]<seuil*0.4) {continue;}
					//boucle dans la boite englobant le SE
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=(1-sizex2);xx<=0;xx++) {	
							med[i]=p_in->p[(yy+y+cy)*naxis1+xx+x];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			//pour les pixel a gauche de l'image
			for (y=cy;y<(naxis2-cy-1);y++) {
				for (x=0;x<cx;x++) {

					if (p_tmp1->p[y*naxis1+x]<seuil*0.4) {continue;}
					//boucle dans la boite englobant le SE
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=x;xx<x+sizex2;xx++) {	
							med[i]=p_in->p[(yy+y+cy)*naxis1+xx+x];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			free(medindice);
			free(med);
			if (nb_test>k_test) {
				for (y=0;y<naxis2;y++) {
					for (x=0;x<naxis1;x++) {
						p_in->p[y*naxis1+x]=p_out->p[y*naxis1+x];
					}	
				}
			}
		}
	}
	//enregistre l'image apr�s le traitement de morphologie math�matique
	//tt_imasaver(p_out,"D:/ima_morphomaths.fit",16);	
	free(se);
	result=0;
	return result;

}

/************* MM: DILATE **************/
void dilate (TT_IMA* pout,TT_IMA* pin,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2)
{	
	int cx,cy,x,y,xx,yy;
	double sup;

	// d�finition du centre de l'�l�ment structurant
	// SE est au milieu du rectangle sizex*sizey
	cx=(sizex-1)/2;
	cy=(sizey-1)/2;

	//on commence par le coin en bas � gauche de l'image p_out [0][0]
	for (y=cy;y<(naxis2-cy);y++) {
		for (x=cx;x<(naxis1-cx);x++) {
			sup=pin->p[y*naxis1+x];
			//boucle dans la boite englobant le SE
			for (yy=0;yy<sizey;yy++) {
				for (xx=0;xx<sizex;xx++) {
					// si le pixel appartient a SE
					if ((se[(yy)*dim1+xx]==1)&&(pin->p[(yy+y-cy)*naxis1+xx+x-cx]>sup)) {
						sup=pin->p[(yy+y-cy)*naxis1+xx+x-cx];
					}
				}
			}
			pout->p[y*naxis1+x]=(TT_PTYPE)(sup);
		}
	}			
}


/************* MM: ERODE **************/
void erode (TT_IMA* pout,TT_IMA* pin,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2)
{
	int cx,cy,x,y,xx,yy;
	double inf;

	// d�finition du centre de l'�l�ment structurant
	// SE est au milieu du rectangle sizex*sizey
	cx=(sizex-1)/2;
	cy=(sizey-1)/2;
	
	//on commence par le coin en bas � gauche de l'image p_out [0][0]
	for (y=cy;y<(naxis2-cy);y++) {
		for (x=cx;x<(naxis1-cx);x++) {
			inf=pin->p[y*naxis1+x];
			//boucle dans la boite englobant le SE
			for (yy=0;yy<sizey;yy++) {
				for (xx=0;xx<sizex;xx++) {
					// si le pixel appartient a SE
					if ((se[(yy)*dim1+xx]==1)&&(pin->p[(yy+y-cy)*naxis1+xx+x-cx]<inf)) {
						inf=pin->p[(yy+y-cy)*naxis1+xx+x-cx];
					}
				}
			}
			pout->p[y*naxis1+x]=(TT_PTYPE)(inf);
		}
	}
}


int tt_histocuts_myrtille(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,double *mode,double *mini,double *maxi)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/***************************************************************************/
/* Il faut que soient deja calculees les donnees suivantes :               */
/*  pseries->                                                              */
/*                                                                         */
/* pseries->lofrac=0.05 le seuil bas dans l'histogramme                    */
/* pseries->hifrac=0.97 le seuil haut dans l'histogramme                   */
/* pseries->cutscontrast=1.0 pour diminuer le contraste                    */
/***************************************************************************/
{
   double sb,sh,bg,mi,ma;
   int msg;

   if (pseries->lofrac>1.) {pseries->lofrac=1.;}
   if (pseries->lofrac<0.) {pseries->lofrac=0.;}
   if (pseries->hifrac>1.) {pseries->hifrac=1.;}
   if (pseries->hifrac<0.) {pseries->hifrac=0.;}
   if (pseries->lofrac>pseries->hifrac) {
      pseries->lofrac=0.05;
      pseries->hifrac=0.97;
   }
   if ((msg=tt_histocuts_precis(p,pseries,pseries->lofrac,pseries->hifrac,&sb,&sh,&bg,&mi,&ma))!=OK_DLL) {
      return(msg);
   }
   /* --- amplification de constraste ---*/
   sb-=((bg-sb)*pseries->cutscontrast);
   sh-=((bg-sh)*pseries->cutscontrast);
   *hicut=sh;
   *locut=sb;
   *mode=bg;
   *mini=mi;
   *maxi=ma;
   return(OK_DLL);
}

int tt_histocuts_precis(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode,double *minim,double *maxim)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/* Le pendant de la fonction tt_util_cuts2.                                */
/***************************************************************************/
{
   double sb,sh,sb0,sh0,delta;
   int *histo,k,sortie,modemax,taille,msg,nombre;
   int nb,nelem,nelem0=0,nullpix_exist,index_histo,nbtours;
   double mini,maxi,nullpix_value,valeur,*seuil,moyenne,deltam,rapport;

   nelem=(p->naxis1)*(p->naxis2);
   nullpix_exist=pseries->nullpix_exist;
   nullpix_value=pseries->nullpix_value;
   if (nullpix_exist==TT_NO) {
      nullpix_value=TT_MIN_DOUBLE;
   }
   nb=50;
   nombre=nb;
   taille=sizeof(int);
   histo=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&histo,&nombre,&taille,"histo"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_histocuts_precis (pointer histo)");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nb+1;
   taille=sizeof(double);
   seuil=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&seuil,&nombre,&taille,"seuil"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_histocuts_precis (pointer seuil)");
      tt_free(histo,"histo");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- calcul du mini et maxi ---*/
   pseries->maxi=TT_MIN_FLOAT;
   pseries->mini=TT_MAX_FLOAT;
   for (k=0;k<nelem;k++) {
      valeur=(double)(p->p[k]);
      if (valeur!=nullpix_value) {
         if (valeur>pseries->maxi) {pseries->maxi=valeur;}
   	     if (valeur<pseries->mini) {pseries->mini=valeur;}
	  }
   }
   *minim=pseries->mini;
   *maxim=pseries->maxi;
   delta=fabs(pseries->maxi-pseries->mini);
   if ((delta!=0)&&(delta<1e-5)) {
      pseries->maxi=pseries->mini+1e-5;
   }
   sb0=mini=pseries->mini;
   sh0=maxi=pseries->maxi;
   sortie=TT_NO;
   nbtours=0;
   /* --- boucle sur l'histogramme ---*/
   do {
      nbtours++;
      if (mini==maxi) {
	     *hicut=maxi;
	     *locut=mini;
         *mode=(maxi+mini)/2.;
	     tt_free(seuil,"seuil");
	     tt_free(histo,"histo");
	     return(OK_DLL);
      }
      /* --- initialise les seuils ---*/
      sb=mini;
      sh=maxi;
      /* --- remplit l'histogramme ---*/
      for (k=0;k<nb;k++) {
	     histo[k]=0;
      }
      deltam=fabs(maxi-mini);
      if (deltam>1e-10) {
         for (k=0,nelem0=0,moyenne=0.;k<nelem;k++) {
   	        valeur=(double)(p->p[k]);
	        if (valeur!=nullpix_value) {
	           nelem0++;
               deltam=(valeur-mini)/(maxi-mini);
	           index_histo=(int)(fabs(floor(deltam*nb)));
	           if (index_histo>=nb) { index_histo=nb-1; }
	           else if (index_histo<0) { index_histo=0; }
	           histo[index_histo]++;
	           moyenne+=valeur;
	        }
         }
      } else {
         histo[0]=nelem;
	     moyenne=(double)(p->p[0]);
      }
      /* --- calcule la moyenne ---*/
      if (nelem0==0) {
	     *hicut=sh;
	     *locut=sb;
         *mode=(sb+sh)/2.;
	     return(OK_DLL);
      }
      moyenne/=nelem0;
      /* --- remplit les valeurs de seuil inf pour chaque baton ---*/
      for (k=0;k<=nb;k++) {
	     seuil[k]=mini+(maxi-mini)*k/nb;
      }
      /* --- calcule le mode ---*/
      modemax=0;
      for (k=0;k<nb-1;k++) {
   	     if (histo[k]>modemax) {
	        modemax=histo[k];
	        *mode=(seuil[k+1]+seuil[k])/2.;
         }
      }
      /* --- calcule l'histogramme cumule ---*/
      for (k=1;k<nb;k++) {
	     histo[k]+=histo[k-1];
      }
      /* --- calcule des nouveaux seuils plus serres ---*/
      for (k=0;k<nb;k++) {
	     valeur=(double)(histo[k])/(double)(histo[nb-1]);
	     if (valeur<=percent_sb) {sb=seuil[k];}
	     if (valeur>=percent_sh) {sh=seuil[k+1];break;}
      }
      mini=sb-(sh-sb); if (mini<sb0) {mini=sb0;}
      maxi=sh+(sh-sb); if (maxi>sh0) {maxi=sh0;}
      if ((sh-sb)==0) {
	     sortie=TT_YES;
      } else {
         rapport=fabs(1-(sh0-sb0)/(sh-sb));
	     if (rapport<0.1) {
	        sortie=TT_YES;
	     }
      }
      if (nbtours>3) {
         sortie=TT_YES;
      }
      /*printf("seuils histo : sb=%f sh=%f mode=%f\n",sb,sh,mode);getch();*/
      sb0=sb;
      sh0=sh;
   } while (sortie==TT_NO);
   *hicut=sh;
   *locut=sb;
   tt_free(seuil,"seuil");
   tt_free(histo,"histo");
   return(OK_DLL);
}


void tt_ima_series_hough_myrtille(TT_IMA* pin,TT_IMA* pout,int naxis1, int naxis2, int threshold , double *eq)
/***************************************************************************/
/* Transformee de Hough arrang�e pour la detection des GTO                 */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   
   long nelem2;
   int msg,k,kkk,x,y,adr;
   double value,*cost,*sint,rho,theta,rho_int;
   int naxis11,naxis12,naxis21,naxis22,nombre,taille,naxis222,naxis122,adr_max;
   double threshold_ligne,seuil_max,somme_value,somme_theta,somme_ro,theta0,ro0;
   int ymax, xmax,kl,kc;

   /* --- intialisations ---*/
   naxis11=naxis1;
   naxis21=naxis2;
   naxis12=180*2;
   naxis22=(int)ceil(sqrt(naxis11*naxis11+naxis21*naxis21));
   naxis122=2*naxis12;
   naxis222=2*naxis22;
   nelem2=(long)(naxis12*naxis222);
   
   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(pout,naxis12,naxis222);

   /* --- mise a zero de l'image de sortie ---*/
   for (kkk=0;kkk<(int)(nelem2);kkk++) {
      value=0.;
      pout->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- on trace une ligne mediane ---*/
   for(k=0;k<naxis12;k++) {
      rho_int=naxis22;
      adr=(int)(rho_int*naxis12+k);
      pout->p[adr]+=(TT_PTYPE)(1);
   }

   /* --- table de cos, sin ---*/
   nombre=naxis12;
   taille=sizeof(double);
   cost=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cost,&nombre,&taille,"cost"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_myrtille for pointer cost");
   }
   sint=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&sint,&nombre,&taille,"sint"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_myrtille for pointer sint");
      tt_free2((void**)&cost,"cost");
   }
   for(k=0;k<naxis12;k++) {
      //theta=(1.*k-90.)*(TT_PI)/180.;
      theta=(1.*k/2-90.)*(TT_PI)/180.; //pour avoir une r�solution 2 fois plus grande
      cost[k]=cos(theta);
      sint[k]=sin(theta);
   }

   
   /* --- balayage ---*/
   for(x=0;x<naxis11;x++) {
      for(y=0;y<naxis21;y++) {
         adr=y*naxis11+x;
         value=pin->p[adr];
         if (value>=threshold) {
            for(k=0;k<naxis12;k++) {
               rho=-x*sint[k]+y*cost[k];
               rho_int=(int)rho;
               rho_int=naxis22+(int)rho;
               if ((rho_int>=0)&&(rho_int<naxis222)) {
                  adr=(int)(rho_int*naxis12+k);
                  //if (pseries->binary_yesno==TT_NO) {
                   //  pout->p[adr]+=(TT_PTYPE)(value);
                  //} else {
                     pout->p[adr]+=(TT_PTYPE)(1.);
                  //}
               }
            }
         }
      }
   }

   /* --- on libere les pointeurs ---*/
   tt_free2((void**)&cost,"cost");
   tt_free2((void**)&sint,"sint");
   
   /* --- calcul du seuil en fonction du maximum de l'image --- */
   seuil_max=0;
   adr_max=0;
	for(x=0;x<naxis12;x++) {
		for(y=0;y<naxis222;y++) {
			adr=y*naxis12+x;
			value=pout->p[adr];
			if (value>seuil_max) {
				seuil_max=value;
				adr_max=adr;
				ymax=y;
				xmax=x;
			}
		}
	 }
	//enregistre l'image de hough
	//tt_imasaver(pout,"D:/hough.fit",16);
	//seuil de d�tection fix� arbitrairement � 25 points align�s
	if (seuil_max>20) {
		threshold_ligne=seuil_max/2;
		somme_value=0;
		somme_theta=0;
		somme_ro=0;
		//recherche du barycentre de la tra�n�e d�tect�e
		for (kl=-20; kl<=20;kl++) { //attention � ymax!
			if (ymax+kl<0) continue;
			if (ymax+kl>=naxis222) break;
			for (kc=-20;kc<=20;kc++) { //attention � xmin!
				if (xmax+kc<0) continue;
				if (xmax+kc>=naxis12) break;
				adr=kl*naxis12+adr_max+kc;
				if (pout->p[adr]>threshold_ligne) {
					somme_value=somme_value+pout->p[adr];
					somme_theta=somme_theta+(xmax+kc)*1.0*pout->p[adr];
					somme_ro=somme_ro+(ymax+kl)*1.0*pout->p[adr];
				}
			}
		}
		if (somme_value!=0) {
			theta0=	somme_theta/somme_value;
			ro0= somme_ro/somme_value;
		} else {
			theta0=xmax;
			ro0=ymax;
		}
		
		//coordonn�es du point dans le plan de hough
		//theta0=(theta0-naxis12/2.)*(TT_PI)/180.;
		theta0=(theta0/2.0-naxis12/4)*(TT_PI)/180.;
		ro0=ro0-naxis22;

		//pour angle diff�rent de 90�
		if (theta0==(TT_PI)/2.) {
			eq[0]=0;
			eq[1]=0;
			eq[2]=-ro0;
		} else {
			eq[0]=tan(theta0);
			eq[1]=ro0/(cos(theta0));
			eq[2]=0;
		}
	} else {
		//pas de detection dans le plan de hough
		eq[0]=0;
		eq[1]=0;
		eq[2]=0;
	}


	//equation de la droite sous la forme y=a0*x+b0
	tt_imadestroyer(pout);
	
}



//###############################################################################################################################
//###############################################################################################################################
//											COPIE DE FOCNTIONS UTILENT DANS CPIXELS.CPP
//###############################################################################################################################
//###############################################################################################################################




/***************************************************/
/* Ajuste une gaussienne 2d:                       */
/* ENTREES :                                       */
/*  **y=matrice des points                         */
/*  sizex=nombre de points sur cote 1 de y         */
/*  sizey=nombre de points sur cote 2 de y         */
/* SORTIES                                         */
/*  p()=tableau des variables:                     */
/*     p[0]=intensite maximum de la gaussienne     */
/*     p[1]=indice X du maximum de la gaussienne   */
/*     p[2]=fwhm X                                 */
/*     p[3]=fond                                   */
/*     p[4]=indice Y du maximum de la gaussienne   */
/*     p[5]=fwhm Y                                 */
/*  ecart=ecart-type                               */
/***************************************************/
void tt_fitgauss2d(int sizex, int sizey,double **y,double *p,double *ecart) {

   int l,nbmax,m;
   double l1,l2,a0;
   double e,er1,y0;
   double m0,m1;
   double e1[6]; /* ici ajout */
   int i,jx,jy;
   double rr2;
   double xx,yy;
   p[0]=y[0][0];
   p[1]=0.;
   p[3]=y[0][0];
   p[4]=0.;

   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
	      if (y[jx][jy]>p[0]) {p[0]=y[jx][jy]; p[1]=1.*jx; p[4]=1.*jy; }
         if (y[jx][jy]<p[3]) {p[3]=y[jx][jy]; }
      }
   }

   p[0]-=p[3];
   p[2]=1.;
   p[5]=1.;
   *ecart=1.0;
   l=6;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=250;         /* nombre maximum d'iterations */

   for (i=0;i<l;i++) {
	 e1[i]=er1;
   }

   m=0;
   l1=(double)1e10;
   fitgauss2d_b1:

   for (i=0;i<l;i++) {
	   a0=p[i];
      fitgauss2d_b2:
	   l2=0;
	   for (jx=0;jx<sizex;jx++) {
	      xx=(double)jx;
	      for (jy=0;jy<sizey;jy++) {
	         yy=(double)jy;
	         rr2=(xx-p[1])*(xx-p[1])+(yy-p[4])*(yy-p[4]);
	         y0=p[0]*exp(-rr2/p[2]/p[5])+p[3];
//	         y0=y0*Mask[jx][jy];
	         l2=l2+(y[jx][jy]-y0)*(y[jx][jy]-y0);
         }
	   }

      m0=l2;
      p[i]=a0*(1-e1[i]);
      l2=0;

	   for (jx=0;jx<sizex;jx++) {
	      xx=(double)jx;
	      for (jy=0;jy<sizey;jy++) {
	         yy=(double)jy;
	         rr2=(xx-p[1])*(xx-p[1])+(yy-p[4])*(yy-p[4]);
	         y0=p[0]*exp(-rr2/p[2]/p[5])+p[3];
//	         y0=y0*Mask[jx][jy];
	         l2=l2+(y[jx][jy]-y0)*(y[jx][jy]-y0);
         }
	   }

      *ecart=sqrt((double)l2/(sizex*sizey-l)); /* ici ajout */
      m1=l2;
      if (m1>m0) e1[i]=-e1[i]/2;
      if (m1<m0) e1[i]=(float)1.2*e1[i];
      if (m1>m0) p[i]=a0;
      if (m1>m0) goto fitgauss2d_b2;
   }
   m++;
   if (m==nbmax) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
   if (l2==0) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
   if (fabs((l1-l2)/l2)<e) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
   l1=l2;
   goto fitgauss2d_b1;
}
















/**************************************************************************/
/**************************************************************************/
/* exemple de la fonction user TUTU implantee dans IMA/STACK              */
/**************************************************************************/
/* Pile d'addition d'image (equivalent a ADD2 de Qmips32).                */
/* Subtil tour de force pour tenir compte des pixels non definis et pour  */
/* calculer l'heure de l'image synthetisee au prorata des images.         */
/**************************************************************************/
int tt_ima_stack_5_tutu(TT_IMA_STACK *pstack)
{
   int kk,kkk;
   double poids_pondere,value;
   int base_adr;
   TT_IMA *p_tmp=pstack->p_tmp;
   TT_IMA *p_out=pstack->p_out;
   long firstelem=pstack->firstelem;
   long nelements=pstack->nelements;
   long nelem=pstack->nelem;
   long nelem0=pstack->nelem0;
   int nbima=pstack->nbima;
   double *poids=pstack->poids;
   double val;
   int *index0,nbima0;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_tutu (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(nbima)/(double)(nelements);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (value=0,nbima0=0,kk=0;kk<nbima;kk++) {
         base_adr=(int)(nelem0)*kk;
         val=(double)(p_tmp->p[base_adr+kkk]);
         if (pstack->nullpix_exist==TT_YES) {
            if (val>pstack->nullpix_value) {
               index0[kk]=TT_YES;
               value+=val;
               nbima0++;
            } else {
               index0[kk]=TT_NO;
            }
         } else {
            index0[kk]=TT_YES;
            value+=val;
            nbima0++;
         }
      }
      value=(nbima0==0)?pstack->nullpix_value:value*((double)(nbima)/(double)(nbima0));
      if (nbima0==0) {
         for (kk=0;kk<nbima;kk++) {
            poids[kk]+=(poids_pondere/(double)(nbima));
         }
      } else {
        for (kk=0;kk<nbima;kk++) {
	       if (index0[kk]==TT_YES) {
	          poids[kk]+=(poids_pondere/(double)(nbima0));
           }
        }
     }
     p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(index0,"index0");

   return(OK_DLL);
}