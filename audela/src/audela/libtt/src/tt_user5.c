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
int tt_ima_series_morphomath_1(TT_IMA_SERIES *pseries);
int tt_geo_defilant_1(TT_IMA_SERIES *pseries);
int tt_ima_masque_catalogue(TT_IMA_SERIES *pseries);

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
   else if (strcmp(keys10,"MORPHOMATH")==0) { pseries->numfct=TT_IMASERIES_USER5_MORPHOMATH;}
   else if (strcmp(keys10,"GEOGTO")==0) { pseries->numfct=TT_IMASERIES_USER5_GEOGTO;}
   else if (strcmp(keys10,"MASQUECATA")==0) { pseries->numfct=TT_IMASERIES_USER5_MASQUECATA;}
   return(OK_DLL);
}

int tt_user5_ima_series_builder2(TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pseries->user5.param1=0.;
   return(OK_DLL);
}

int tt_user5_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TRAINEE")==0) {
	 pseries->user5.param1=(double)(atof(argu));
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
   } else if (pseries->numfct==TT_IMASERIES_USER5_MORPHOMATH){
	  *msg=tt_ima_series_morphomath_1(pseries);
      *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_MASQUECATA){
	  *msg=tt_ima_masque_catalogue(pseries);
      *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_GEOGTO) {
	   *msg=tt_geo_defilant_1(pseries);
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
/* remplace les trainées d'étoiles par le fond de ciel                     */
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
/* detecte les trainées d'étoiles sur une image trainee                    */
/***************************************************************************/
/*														                   */
/* sortie = fichier														   */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index;
   double fwhmsat,seuil,seuil0,seuil1,seuila;
   double xc,yc,radius;
   char filenamesat[FLEN_FILENAME];
   double exposure;	
   double mode,mini,maxi;
  
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
   tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode,&maxi,&mini);
	
   /* seuils prédéfinis pour les pixels noirs et balncs */
    seuil0 = mode + 0.1*mode;
	seuil1 = pseries->hicut + 0.06*pseries->hicut;
	// attention il ne faut pas que seuil0 > seuil 1
	if ((seuil0 >= seuil1)||(seuil1<=seuil0+100)) {
		seuil0 = mode ;
		seuil1 = pseries->hicut+ 0.1*pseries->hicut;
	}

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

   seuil=pseries->threshold; // voir le calcul a faire en fonction du niveau de bruit
   if (seuil<=0) {
      seuil=100.;
   }
   seuila = seuil;
   seuil = seuil+mode;
   
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
	  if (dvalue <= seuil0) {
		 p_out->p[kkk]= 0;
	  } 
	  if (dvalue >= seuil1) {
		 p_out->p[kkk]= 1;
	  } 	  
	  if ((dvalue > seuil0)&&(dvalue < seuil1)) {
		 dvalue=dvalue/seuil1;
		 p_out->p[kkk]=(TT_PTYPE)(dvalue);
	  } 
   }
	
   /* --- calcul ---*/
   tt_util_chercher_trainee(p_in,p_out,filenamesat,fwhmsat,seuil,seuil1,seuila,xc,yc,exposure);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/***************************************************************************/
/* detecte le début des trainées d'étoiles sur une image trainee           */
/***************************************************************************/
/*														                   */
/* 																		   */
/***************************************************************************/

int tt_util_chercher_trainee(TT_IMA *pin,TT_IMA *pout,char *filename,double fwhmsat,double seuil,double seuil1,double seuila, double xc0, double yc0, double exposure)

{	
	int xmax,ymax,ntrainee,sizex,sizey,nb,background,flags;
	double fwhmyh,fwhmyb,posx,posy,fwhmx,fwhmy,dvalue,lt,xc,yc,flux,fluxerr,fwhmd,a,b;
	double magnitude, magnitudeerr,theta,classstar;
	int k,k2,y,x,ltt,fwhmybi,fwhmyhi,fwhm,nelem;
	double *matx;
	FILE *fic;
	double **mat, *p, *carac, *temp;

	nelem=pin->nelements;
	/* --- calcul de la fonction ---*/
	temp = (double*)calloc(nelem,sizeof(double));
    for (k=0;k<(int)(nelem);k++) {
		dvalue=(double)pout->p[k];
		if (dvalue == 1.0) {
			temp[k]=0;
		} else {
			temp[k]=-1;
		}
    }

	p = (double*)calloc(6,sizeof(double));
	
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
	if (seuil>=seuil1) {
		seuil=1.0;
	} else {
		seuil=seuil/seuil1;
	}
	for (y=3;y<ymax-3;y++) {
		if ((y>ymax)||(y<0)) { continue; }	
		for (x=3;x<(xmax-ltt-3);x++) {
			
			if (temp[y*ymax+x]==-1) {continue;}
			matx[x]=0;
			for (k=0;k<ltt;k++) {
				matx[x]+=pout->p[y*ymax+x+k];
			}
			if (matx[x]>=ltt) {	
				fwhmyh=0;
				fwhmyb=0;
				//recherche approximative des paramètres de la trainées
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
				fwhmyhi =(int) fwhmyh+1;
				fwhmybi =(int) fwhmyb+1;
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

				//fixe la taille de la fenêtre de travail: sizex et sizey
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
					 temp[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k]=-1;// pour ne pas repasser sur la meme etoile
				  }
				}
				//recherche de la position du photocentre
				xc=2*fwhm+nb;
				yc=fwhmybi+nb;
				flux=0.0;

				fittrainee2 (seuila,lt,fwhm,xc,yc,nb,sizex, sizey, mat, p, carac, exposure); 				
				//fittrainee3 (seuila,lt,xc,yc,nb,sizex, sizey, mat, p, carac, exposure); 
				//posx  = p[1]+x-fwhm-nb;
				posx  = p[1]+1.0*x+1.0;
				posy  = p[4]-fwhmybi-1.0*nb+1.0*y;
				
				//paramètres calculés rapidement ou pas du tout, pour que le fichier de sortie ressemble à celui de SExtractor
				flux=carac[1];
				fluxerr=0.2*flux;
				if (flux<=50.0) { flux = 50;}
				magnitude = -2.5*log10(flux) + 23.92;
				magnitudeerr = 0.2*magnitude;
				background = 2;
				theta =0.0;
				flags=0;
				classstar=0.90;
				b=2.0*fwhm;
				a=lt/2+2*fwhm;

				/*fittrainee (lt,fwhm,x,sizex, sizey, mat, p, carac, exposure); 
				posx  = (p[1]-fwhm-nb+2*x)/2;
				posy  = p[4]-fwhmybi-nb+y;*/

				fwhmx = p[2];						
				fwhmy = p[5];
				//*fondx = p[3];
				//*fondy = p[3];

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
	free(matx);
	free(p);
	free(temp);
	free(carac);	
	fclose(fic);
	return 1;
}

/*********************************************************************************************/
/* fitte les trainées avec une ellipse														 */
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des traînées															 */
/*		fwhm = largeur à mi-hauteur de la fonction d'étalement de l'étoile non trainée		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		x = numero du pixel en x du debut de la zone										 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone à fitter						 */
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
	// recherche du max d'intensité pour chaque colonne et ligne pour avoir une valeur approchée du centre de l'etoile
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
	//posx et moyy représentent le pixel d'intensité la plus forte sur la ligne définie par y=moyy
	//moyy représente la ligne moyenne d'intensité maximale dans la zone 
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
/* fitte les trainées avec une gaussienne convoluée avec une un trait (= forme d'une trainée)*/
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des traînées															 */
/*		fwhm = largeur à mi-hauteur de la fonction d'étalement de l'étoile non trainée		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone à fitter						 */
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
				if ((((jx-p[1]-fwhm-nb)*(jx-p[1]-fwhm-nb) + (jy-p[4])*(jy-p[4]))<=c*c)&&(value>=seuil/2)) {
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
/* fitte les trainées avec une gaussienne convolué avec une un trait (= forme d'une trainée) */
/*	approximation de la fonction erf													     */
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des traînées															 */
/*		fwhm = largeur à mi-hauteur de la fonction d'étalement de l'étoile non trainée		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone à fitter						 */
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

   //vitesse sidérale
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
int tt_geo_defilant_1(TT_IMA_SERIES *pseries)
{
	TT_IMA *p_in,*p_out, *p_tmp1;
	int result,kkk,x,y;
	int nelem,index,x1,y1,naxis1,naxis2;
	int *se = NULL;
	double dvalue;
	double mode2,mini2,maxi2;

	/* --- intialisations ---*/
	p_in=pseries->p_in; 
	p_out=pseries->p_out;
	p_tmp1=pseries->p_tmp1;
	nelem=pseries->nelements;
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	index=pseries->index;
	x1=pseries->x1;
	y1=pseries->y1;

	/* --- calcul de la fonction ---*/
	tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_out->p[kkk]=(TT_PTYPE)(dvalue);	 
	}
	tt_imacreater(p_tmp1,p_in->naxis1,p_in->naxis2);
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_tmp1->p[kkk]=(TT_PTYPE)(dvalue);	 
	}
	
//	tt_ima_series_morphomath_1(p_in,TOPHAT,RECTANGLE,10,1);





			for (kkk=0;kkk<(int)(nelem);kkk++) {
				p_tmp1->p[kkk]=p_out->p[kkk];	 
			}
			//binarisation de l'image en fonction de l'histogramme
			tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
			
			//seuillage haut pour récupérer seulement les géostationnaires
			for (y=0;y<naxis2;y++) {
				for (x=0;x<naxis1;x++) {
					if (p_out->p[y*naxis1+x]<(pseries->hicut)*0.88) {
						p_out->p[y*naxis1+x]=0;				
					} 
				}
			}
			//sauve image pour recherche de geo
			tt_imasaver(p_out,"D:/geo.fit",8);

			//seuillage bas pour garder les éventuelles traînées faibles
			for (y=0;y<naxis2;y++) {
				for (x=0;x<naxis1;x++) {
					if (p_tmp1->p[y*naxis1+x]<(pseries->hicut)*0.4) {
						p_tmp1->p[y*naxis1+x]=0;				
					} 
				}
			}
			//sauve image pour recherche de gto et défilants
			tt_imasaver(p_tmp1,"D:/gto.fit",8);

			//filtre médian
			//tt_ima_series_filter_1("FILTER kernel_type=MED kernel_coef=0.0");


	/* --- calcul des temps ---*/
	pseries->jj_stack=pseries->jj[index-1];
	pseries->exptime_stack=pseries->exptime[index-1];

	result=0;
	return result ;

}



int tt_ima_series_morphomath_1(TT_IMA_SERIES *pseries)
/****************************************************************************/
/* trait morpho math sur image dans buffer						            */
/****************************************************************************/
/****************************************************************************/
//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 

//buf1 imaseries "MORPHOMATH nom_trait=TOPHAT struct_elem=RECTANGLE x1=10 y1=1"

//buf1 imaseries "MORPHOMATH nom_trait=$nom_Trait struct_elem=$struct_Elem x1=$dim1 y1=$dim2"
//pour le moment les SE seront de dimensions impaires pour avoir un centre centré!

{
	TT_IMA *p_in,*p_out, *p_tmp1, *p_tmp2;
	int result,i,kkk,x,y;
	int size,sizex,sizey, nelem,index,x1,y1,naxis1,naxis2;
	int *se = NULL;
	double dvalue,hicuttemp,locuttemp;
	double mode1,mini1,maxi1,mode2,mini2,maxi2;


	/* --- intialisations ---*/
	p_in=pseries->p_in; 
	p_out=pseries->p_out;
	p_tmp1=pseries->p_tmp1;
	p_tmp2=pseries->p_tmp2;
	nelem=pseries->nelements;
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	index=pseries->index;
	x1=pseries->x1;
	y1=pseries->y1;

	/* --- calcul de la fonction ---*/
	tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_out->p[kkk]=(TT_PTYPE)(dvalue);	 
	}
	tt_imacreater(p_tmp1,p_in->naxis1,p_in->naxis2);
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_tmp1->p[kkk]=(TT_PTYPE)(dvalue);	 
	}
	tt_imacreater(p_tmp2,p_in->naxis1,p_in->naxis2);
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_tmp2->p[kkk]=(TT_PTYPE)(dvalue);	 
	}

	if (x1%2 != 1) {
		x1=x1+1;
	}
	if (y1%2 != 1) {
		y1=y1+1;
	}

	//creation de l'élément structurant
	if (strcmp (pseries->struct_elem,"RECTANGLE")==0) {
		
		size=x1*y1;
		se=calloc(size,sizeof(int));	
		for (i=0; i<size;i++) {
				se[i]=1;
		}
		
		// attention c'est valable que pour un rectangle mais il faut calculer 
		//pour cercle ou autre SE pour avoir les dimensions de la matrice SE
		sizex = x1;
		sizey = y1;
		
	}  else if (strcmp (pseries->struct_elem,"DIAMOND")==0){
		size=x1*y1;
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=0;
		}	
		for (i=0; i<y1;i++) {	
			if (i< y1/2) {
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
		
	} else {
		//forme libre à donner
		//se[0] est en bas à gauche de SE

		x1=13;
		y1=1;
		size=x1*y1;
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=1;
		}
	}
	
	//appel de la fonction de traitement de morpho_math
	i=strcmp (pseries->nom_trait,"DILATE");

	if (i==0) {
			dilate (p_out,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 
	i=strcmp (pseries->nom_trait,"ERODE");
	if (i==0) {
			erode (p_out,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 	
	i=strcmp (pseries->nom_trait,"OPEN");
	if (i==0) {
			erode (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 
	i=strcmp (pseries->nom_trait,"CLOSE");
	if (i==0) {
			dilate (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
			erode (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
	} 
	i=strcmp (pseries->nom_trait,"TOPHAT");
	if (i==0) {
		erode (p_tmp1,p_in,se,x1,y1,sizex,sizey,naxis1,naxis2);
		dilate (p_out,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);

		/* --- Calcul des seuils de visualisation ---*/
		//réduction de la dynamique des images

		tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
		hicuttemp =pseries->hicut;
		locuttemp=pseries->locut;
		tt_util_histocuts(p_in,pseries,&(pseries->hicut),&(pseries->locut),&mode1,&mini1,&maxi1);

		//tt_util_cuts(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,int dejastat)

		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x])*(float)mode1/(float)mode2;

				if (p_out->p[y*naxis1+x]<locuttemp) {
					p_out->p[y*naxis1+x]=0;
				} else if (p_out->p[y*naxis1+x]>hicuttemp) {
					p_out->p[y*naxis1+x]=255;
				} else {
					p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)locuttemp)*(float)255./(float)(hicuttemp-locuttemp);
				}
				
				if (p_tmp2->p[y*naxis1+x]<pseries->locut) {					
					p_tmp2->p[y*naxis1+x]=0;	
				} else if (p_tmp2->p[y*naxis1+x]>pseries->hicut) {
					p_tmp2->p[y*naxis1+x]=255;
				} else {
					p_tmp2->p[y*naxis1+x]=(p_tmp2->p[y*naxis1+x]-(float)pseries->locut)*(float)255./(float)(pseries->hicut-pseries->locut);
				}
				if ((p_out->p[y*naxis1+x]/((mode1-(float)pseries->locut)*255./(float)(pseries->hicut-pseries->locut))<1)&&(locuttemp > pseries->locut)) {
					p_out->p[y*naxis1+x]=(float)1.1*(p_out->p[y*naxis1+x])*(float)pseries->locut/(float)locuttemp;
				} else if ((p_out->p[y*naxis1+x]/((mode1-(float)pseries->locut)*255./(float)(pseries->hicut-pseries->locut))>1)&&(pseries->hicut> hicuttemp)) {
					p_out->p[y*naxis1+x]=(float)1.1*(p_out->p[y*naxis1+x])*(float)pseries->hicut/(float)hicuttemp;
				}
				p_out->p[y*naxis1+x]=p_tmp2->p[y*naxis1+x]-p_out->p[y*naxis1+x];	
			}
		}
	} 
		
	free(se);

	/* --- calcul des temps ---*/
	pseries->jj_stack=pseries->jj[index-1];
	pseries->exptime_stack=pseries->exptime[index-1];

	result=0;
	return result ;
}


void dilate (TT_IMA* pout,TT_IMA* pin,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2)
{	
	int cx,cy,x,y,xx,yy;
	double sup;


	// définition du centre de l'élément structurant
	// SE est au milieu du rectangle sizex*sizey

	cx=(sizex-1)/2;
	cy=(sizey-1)/2;

	
	//on commence par le coin en bas à gauche de l'image p_out [0][0]
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



void erode (TT_IMA* pout,TT_IMA* pin,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2)
{
	int cx,cy,x,y,xx,yy;
	double inf;


	// définition du centre de l'élément structurant
	// SE est au milieu du rectangle sizex*sizey

	cx=(sizex-1)/2;
	cy=(sizey-1)/2;

	
	//on commence par le coin en bas à gauche de l'image p_out [0][0]
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


int tt_ima_series_hough_myrtille(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Transformee de Hough arrangée pour la detection des GTO                 */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem2;
   int msg,k,kkk,x,y,adr,index;
   double value,*cost,*sint,rho,theta,rho_int;
   int naxis11,naxis12,naxis21,naxis22,nombre,taille,naxis222,naxis122,adr_max;
   double threshold,threshold_ligne,seuil_max,somme_value,somme_theta,somme_ro,theta0,ro0,a0,b0;
   int ymax, xmax,kl,kc;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   naxis11=p_in->naxis1;
   naxis21=p_in->naxis2;
   naxis12=180;
   naxis22=(int)ceil(sqrt(naxis11*naxis11+naxis21*naxis21));
   naxis122=2*naxis12;
   naxis222=2*naxis22;
   nelem2=(long)(naxis12*naxis222);
   threshold=pseries->threshold;
   threshold_ligne=30;	//définition d'un nombre mini de points pour avoir une droite

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,naxis12,naxis222);

   /* --- mise a zero de l'image de sortie ---*/
   for (kkk=0;kkk<(int)(nelem2);kkk++) {
      value=0.;
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- on trace une ligne mediane ---*/
   for(k=0;k<naxis12;k++) {
      rho_int=naxis22;
      adr=(int)(rho_int*naxis12+k);
      p_out->p[adr]+=(TT_PTYPE)(1);
   }

   /* --- table de cos, sin ---*/
   nombre=naxis12;
   taille=sizeof(double);
   cost=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cost,&nombre,&taille,"cost"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_myrtille for pointer cost");
      return(msg);
   }
   sint=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&sint,&nombre,&taille,"sint"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_myrtille for pointer sint");
      tt_free2((void**)&cost,"cost");
      return(msg);
   }
   for(k=0;k<naxis12;k++) {
      theta=(1.*k-90.)*(TT_PI)/180.;
      //theta=(1.*k-90.)*(TT_PI)/360.; //pour avoir une résolution 2 fois plus grande
      cost[k]=cos(theta);
      sint[k]=sin(theta);
   }

   
   /* --- balayage ---*/
   for(x=0;x<naxis11;x++) {
      for(y=0;y<naxis21;y++) {
         adr=y*naxis11+x;
         value=p_in->p[adr];
         if (value>=threshold) {
            for(k=0;k<naxis12;k++) {
               rho=-x*sint[k]+y*cost[k];
               rho_int=(int)rho;
               rho_int=naxis22+(int)rho;
               if ((rho_int>=0)&&(rho_int<naxis222)) {
                  adr=(int)(rho_int*naxis12+k);
                  //if (pseries->binary_yesno==TT_NO) {
                   //  p_out->p[adr]+=(TT_PTYPE)(value);
                  //} else {
                     p_out->p[adr]+=(TT_PTYPE)(1.);
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
			value=p_out->p[adr];
			if (value>seuil_max) {
				seuil_max=value;
				adr_max=adr;
				ymax=y;
				xmax=x;
			}
		}
	 }
	threshold_ligne=seuil_max/2;
	somme_value=0;
	somme_theta=0;
	somme_ro=0;
	for (kl=-20; kl<=20;kl++) { //attention à ymax!
		if (ymax+kl<0) continue;
		if (ymax+kl>=naxis222) break;
		for (kc=-20;kc<=20;kc++) { //attention à xmin!
			if (xmax+kc<0) continue;
			if (xmax+kc>=naxis12) break;
			adr=kl*naxis12+adr_max+kc;
			if (p_out->p[adr]>threshold_ligne) {
				somme_value=somme_value+p_out->p[adr];
				somme_theta=somme_theta+(xmax+kc)*p_out->p[adr];
				somme_ro=somme_ro+(ymax+kl)*p_out->p[adr];
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
	
	//coordonnées du point dans le plan de hough
	theta0=(theta0-naxis12/2.)*(TT_PI)/180.;
	ro0=ro0-naxis22;

	//pour angle différent de 90°
	if (theta0==(TT_PI)/2.) {
		//tourner image
	} else {
		a0=tan(theta0);
		b0=ro0/(cos(theta0));
	}
	pseries->xcenter=a0;
	pseries->ycenter=b0;
		

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
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