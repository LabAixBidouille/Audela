/* tt_user5.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <laas@obs-hp.fr>
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
void fittrainee (int sizex, int sizey,double **mat,double *p,double *ecart,double exposure);
void fittrainee2 (int sizex, int sizey,double **mat,double *p,double *ecart,double exposure);

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






int tt_ima_series_trainee_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* detecte les train�es d'�toiles sur une image trainee                    */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* 
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index;
   double fwhmsat,seuil,seuil0,seuil1;
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
	
   /* seuils pr�d�finis pour les pixels noirs et balncs */
    seuil0 = mode + 0.1*mode;
	seuil1 = pseries->hicut + 0.25*pseries->hicut;
	// attention il ne faut pas que seuil0 > seuil 1
	if (seuil0 >= seuil1) {
		seuil0 = mode ;
		seuil1 = pseries->hicut+ 0.5*pseries->hicut;
	}

   if (radius<=0) {
       xc=p_in->naxis1/2;
       yc=p_in->naxis2/2;
       radius=1.1*sqrt(xc*xc+yc*yc);
   }
   if (fwhmsat<=0) {
      fwhmsat=1.;
   }
   //strcpy(filenamesat,pseries->objefile);
   //if (strcmp(filenamesat,"")==0) {
    strcpy(filenamesat,"C:/audela-1.4.0-beta1/ros/src/grenouille/trainees.txt");
   //}
   seuil=pseries->threshold; // voir le calcul a faire en fonction du niveau de bruit
   if (seuil<=0) {
      seuil=100.;
   }

   
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
	//Buffer->SaveFits(nom_fichier);
   /* --- raz des variables a calculer ---*/
   
   /* --- calcul ---*/
   tt_util_chercher_trainee(p_in,p_out,filenamesat,fwhmsat,seuil,seuil1,xc,yc,radius,exposure);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_util_chercher_trainee(TT_IMA *pin,TT_IMA *pout,char *filename,double fwhmsat,double seuil,double seuil1,double xc0, double yc0, double radius, double exposure)

{	
	int xmax,ymax,ntrainee,sizex,sizey,nb;
	double d0,lt,fwhmyh,fwhmyb,posx,posy,fwhmx,fwhmy,dvalue;
	int k,k2,y,x,ltt,fwhmybi,fwhmyhi,fwhm,nelem;
	double *matx;
	FILE *fic;
	double **mat, *p, *ecart, *temp;
	
	
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
	

	ecart = (double*)calloc(1,sizeof(double));
	ntrainee=1;

	/* --- grande boucle sur l'image ---*/
	d0=radius*radius;
	seuil=seuil/seuil1;
	for (y=3;y<ymax-3;y++) {
		if ((y>ymax)||(y<0)) { continue; }	
		for (x=3;x<(xmax-ltt-3);x++) {
			//mat[x-3]=0;
			if (temp[y*ymax+x]==-1) {continue;}
			for (k=0;k<ltt;k++) {
				matx[x]+=pout->p[y*ymax+x+k];
			}
			if (matx[x]>=(ltt-1)) {	
				fwhmyh=0;
				fwhmyb=0;
				//rechercche approximative des param�tres de la train�es
				for (k=0;k<ltt;k++) {
					for (k2=1;k2<40;k2++) {
						if ((k2+y)>= ymax) break;
						if (pout->p[(y+k2)*ymax+x+k]>0.5) {fwhmyh++;}
						else break;
					}
					for (k2=1;k2<40;k2++) {
						if (k2 < y) break;
						if (pout->p[(y-k2)*ymax+x+k]>0.5) {fwhmyb++;}
						else break;
					}
				}
				fwhmyh=fwhmyh/ltt;
				fwhmyb=fwhmyb/ltt;
				fwhmyhi =(int) fwhmyh;
				fwhmybi =(int) fwhmyb;
				sizex=ltt+fwhmyhi+fwhmybi+8;
				sizey=fwhmybi+fwhmyhi+8;
				fwhm= (int) ((fwhmybi+fwhmyhi)/2);

				//pour les bords d'image
				if (fwhm>x) fwhm=x;
				if ((fwhm + x) > xmax) fwhm=(xmax-x);
				if ((sizex + x) > xmax) sizex=(xmax-x);
				if ((sizex + x) > xmax) sizex=(xmax-x);
				nb=y-fwhmybi;
				if (nb > 4) nb = 4;
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
					 mat[k][k2] = pin->p[xmax*(y-fwhmybi-nb+k2)+x-fwhm+k];
					 temp[xmax*(y-fwhmybi-nb+k2)+x-fwhm+k]=-1;// pour ne pas repasser sur la meme etoile
				  }
				}
					
				fittrainee2 (sizex, sizey, mat, p, ecart, exposure); 
				posx  = p[1]+x;
				fwhmx = p[2];
				//*fondx = p[3];
				//*fondy = p[3];
				posy  = p[4]+y;
				fwhmy = p[5];
				/* --- sortie du resultat ---*/
				fprintf(fic,"%d %f %f %f %f\n",
				ntrainee,posx,posy,fwhmx,fwhmy);
				ntrainee++;
				tt_free2((double**)&mat,"mat");
				x=x+ltt;
			}
		}
	}
	free(matx);
	free(p);
	free(temp);
	free(ecart);
	return 1;
}

void fittrainee (int sizex, int sizey,double **mat,double *p,double *ecart, double exposure) {

	double *matx,*maty, intensite,moyx,*addx,lt,matyy;
	int jx,jxx,jy,moyjx,ltt,posmaty;
	
	p = (double*)calloc(6,sizeof(double));

	//longueur des trainees pour la camera Andor de TAROT
	lt=0.004180983*exposure/(9.1441235255136e-4);
	ltt = (int) lt;

	matx = (double*)calloc(sizex,sizeof(double));
	maty = (double*)calloc((sizex-ltt),sizeof(double));
	addx = (double*)calloc(sizex,sizeof(double));

	for (jx=0;jx<sizex;jx++) {
		matx[jx]=0.;
	}
	for (jy=0;jy<(sizex-ltt);jy++) {
		maty[jy]=0.;
	}
	for (jx=0;jx<sizex;jx++) {
		addx[jx]=0.;
	}

	moyx=0;
	
	// recherche du max d'intensit� pour chaque colonne
	for (jx=0;jx<sizex;jx++) {
		intensite=0.;
		for (jy=0;jy<sizey;jy++) {
			if (mat[jx][jy]>intensite) {intensite=mat[jx][jy]; matx[jx]=1.*jy; }
			moyx+=1.*jy;
			addx[jx]+=mat[jx][jy];
		}
	}
	moyx=moyx/sizex;
	moyjx = (int)moyx;
	matyy=0;
	//moyxx=0.;
	for (jx=0;jx<(sizex-ltt);jx++) {
		for (jxx=0;jxx<ltt;jxx++) {
			maty[jx]+=mat[jx+jxx][moyjx];
		}
		if (maty[jx]>matyy) {
			matyy=maty[jx];posmaty=jx;
			 
		}
	}

	free(matx);
	free(maty);
	free(addx);
}

int tt_util_chercher_trainee2(TT_IMA *pin,TT_IMA *pout,char *filename,double fwhmsat,double seuil,double seuil1,double xc0, double yc0, double radius, double exposure)
/***************************************************************************/
/* Analyse des pixels de l'image pour detecter les satellites geostats     */
/***************************************************************************/
/* Boucle generale.                                                        */
/***************************************************************************/
/*                                                                         */
/* fwhmsat est la longueur des trainees                                    */
/* !!!! Les coordonnees pixels commencent en (0,0) !!!!                    */
/* 31 37 */
/***************************************************************************/
{
   int k,y,x,ya,yb,yc,xxd,yyd,xxf,yyf;
   double fwhmx,fwhmy,fond[4],detection,intensite;
   int xmax,ymax;
   double *v,*vec,valfond;
   int ntrainee;
   int nombre,nombre2,taille,msg;
   int trainee,k1,k2,kk;
   double detection2=0.;
   double ra,dec,xcc,ycc,r1,r11,r2,r22,r3,r33,r4,sx,sy,flux,fwhmxy;
   double dx,dy,dx2,dy2,d2,value,fmoy,fmed,seuilf,f23,sigma;
   int xx1,xx2,yy1,yy2,n23,n23d,n23f,i,j,valid_ast;
   double dx0,dy0,d0;
   TT_ASTROM p_ast;
   FILE *fic;
   int sizex, sizey;
   double **mat, *p, *ecart;
   double posx,posy;
   //double *maxx,*posx,*fwhmxx,*fondx,*maxy,*posy,*fwhmyy,*fondy; 
   //maxx=NULL; posx=NULL; fwhmxx=NULL; fondx=NULL;  maxy=NULL; posy=NULL; fwhmyy=NULL; fondy=NULL;
   
   
   /* --- chercher les dimensions de l'image ---*/
   xmax=pin->naxis1;
   ymax=pin->naxis2;
   /* --- lit les parametres astrometriques de l'image ---*/
   valid_ast=1;
   tt_util_getkey0_astrometry(pin,&p_ast,&valid_ast);
	

   /* --- Calcul du critere de qualite stellaire ---*/
   ntrainee=0;
   nombre=10;
   nombre2=1;
   taille=sizeof(double);
   v=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&v,&nombre,&taille,"v"))!=OK_DLL) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_util_geostat (pointer v)");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- ouvre le fichier en ecriture ---*/
   fic=fopen(filename,"wt");
   /* --- grande boucle sur l'image ---*/
   d0=radius*radius;
   seuil=seuil/seuil1;
   for (y=1;y<ymax-1;y++) {
      if ((y>ymax)||(y<0)) { continue; }
      ya=xmax*(y-1);
      yb=xmax*y;
      yc=xmax*(y+1);
      dy0=(y-yc0)*(y-yc0);
      for (x=1;x<xmax;x++) {
		 if(pout->p[yb+x+1] == 0) { continue; }
		 //if(pout->p[yb+x+1] == 1) { continue; }
         if ((x>xmax)||(x<0)) { continue; }
         dx0=(x-xc0)*(x-xc0);
         if ((dy0+dx0)>d0) { continue; }
	      v[1]=pin->p[ya+x-1];
	      v[6]=pin->p[yb+x+1 ];
	      if (v[6]>v[1]) {
	         v[2]=pin->p[ya+x  ];
			 v[7]=pin->p[yc+x-1]; 
	         v[4]=pin->p[yb+x-1];
	         if ((v[6]>v[2])&&(v[6]>v[7])&&(v[6]>v[4])) {
				v[8]=pin->p[yc+x  ];
				v[5]=pin->p[yb+x  ];
				 if ((v[6]>v[8])&&(v[6]>=v[5])) {	            
					v[3]=pin->p[ya+x+1];
					v[9]=pin->p[yc+x+1];
					if (((v[6]>=v[3])&&(v[6]>=v[9]))||((v[6]>=v[3])&&(v[6]>=0.9*v[9]))||((v[6]>=v[9])&&(v[6]>=0.9*v[3]))||((v[6]>=0.9*v[9])&&(v[6]>=0.9*v[3]))) {
						/* --- maximum local detecte = pixel au milieu � droite sur matrice 3*3---*/
  						/* --- recherche le fond local ---*/
						fwhmx=0;
						for (k=x;k<=(xmax-2);k++) {
							if ((pin->p[xmax*y+k]-pin->p[xmax*y+k+1])<=0) break;
							else fwhmx+=1;
						}
						k--;
           				xxf=k;
						/*printf("-> %d/%d\n",xmax*y+k+1,longueur);*/
						fond[0]=pin->p[xmax*y+k+1];
						for (k=x;k>=1;k--) {
						if ((pin->p[xmax*y+k]-pin->p[xmax*y+k-1])<=0) break;
							else fwhmx+=1;
						}
						k++;
						xxd=k;
						fwhmx/=2.;
						/*printf("-> %d/%d\n",xmax*y+k-1,longueur);*/
						fond[1]=pin->p[xmax*y+k-1];
						fwhmy=0;
           				for (k=y;k<=(ymax-2);k++) {
							if ((pin->p[xmax*k+x]-pin->p[xmax*(k+1)+x])<=0) break;
							else fwhmy+=1;
						}
						k--;
						yyf=k;
						/*printf("-> %d/%d\n",xmax*(k+1)+x,longueur);*/
						fond[2]=pin->p[xmax*(k+1)+x];
						for (k=y;k>=1;k--) {
							if ((pin->p[xmax*k+x]-pin->p[xmax*(k-1)+x])<=0) break;
						else fwhmy+=1;
						}
						k++;
						yyd=k;
						fwhmy/=2.;
						/*printf("-> %d %d/%d\n",k,xmax*(k-1)+x,longueur);*/
						fond[3]=pin->p[xmax*(k-1)+x];
						/* valfond est le fond mini */
						valfond=fond[0];
						for (k=1;k<4;k++) {
							if (fond[k]<valfond) {
								valfond=fond[k];
							}
						}
						valfond=valfond/seuil1;	  
						detection=valfond+seuil;
						/* maximum local>detect ET ce n'est pas un cosmique */
						if ((v[6]/seuil1>=detection)&&(fwhmx>1.)&&(fwhmy>1.)) {
							detection2=valfond+0.5*(v[6]/seuil1-valfond);
							trainee=0;
						/* on recherche une trainee a gauche */
						k1=(int)((double)x-0.4*fwhmsat);
						if (k1<0) {k1=0;}
						k2=x;
   						for (kk=0,k=k1;k<=k2;k++) {
							if (pin->p[xmax*y+k]>=detection2) {
								kk++;
							}
						}
						if (kk>(int)(0.8*(k2-k1))) {
							trainee=-1;
						}
						/* on recherche une trainee a droite */
						k1=x;
						k2=(int)((double)x+0.4*fwhmsat);
						if (k2>(xmax-1)) {k2=xmax-1;}
   						for (kk=0,k=k1;k<=k2;k++) {
							if (pin->p[xmax*y+k]>=detection2) {
								kk++;
							}
						}
						if (kk>(int)(0.8*(k2-k1))) {
							trainee=1;
						}

						if (trainee==1) {
		                  /* --- une train�e a �t� d�tect�e ---*/
							ntrainee++;
							intensite=v[6]/seuil1-valfond;
							/* --- parametres de mesure precise ---*/

// il faut fitter avec la forme d'une train�e, et trouver sa largeur et sa longueur qui doivent �tre coh�rentes:
// longueur = largeur + train�e
						

							xcc=(double)x;
							ycc=(double)y;
							fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;//on prend la plus grande valeur des 2
							r1=1.5*fwhmxy;
							r2=2.0*fwhmxy;
							r3=55;
							r4=14;
							r11=r1*r1;
							r22=r2*r2;
							r33=r3*r3;
							/* --- fond de ciel precis (fmoy,fmed,sigma) ---*/
							xx1=(int)(xcc-r3/12);
							xx2=(int)(xcc+r3);
							yy1=(int)(ycc-r4);
							yy2=(int)(ycc+r4);
							if (xx1<0) xx1=0;
							if (xx1>=xmax) xx1=xmax-1;
							if (xx2<0) xx2=0;
							if (xx2>=xmax) xx2=xmax-1;
							if (yy1<0) yy1=0;
							if (yy1>=ymax) yy1=ymax-1;
							if (yy2<0) yy2=0;
							if (yy2>=ymax) yy2=ymax-1;
							
							sizex=xx2-xx1;
							sizey=yy2-yy1;
							mat=NULL;
							p=NULL;
							
							mat = (double**)calloc(sizex,sizeof(double));
							for(i=0;i<sizex;i++) {
								*(mat+i) = (double*)calloc(sizey,sizeof(double));
							}

							//--- Mise a zero des deux buffers de binning
						    for(i=0;i<sizex;i++) {
							  for(j=0;j<sizey;j++) {
								 mat[i][j]=(double)0.;
							  }
							}
						    for(j=0;j<sizey;j++) {
							  for(i=0;i<sizex;i++) {
								 mat[i][j] = pin->p[xmax*(yy1+j)+xx1+i];
							  }
							}

						    ecart = (double*)calloc(1,sizeof(double));
							p = (double*)calloc(6,sizeof(double));

							//on r�cup�re la bonne position en y, mais pas en x, il faut add xx1 et yy1 au valeurs obtenues!!
							fittrainee2 (sizex, sizey, mat, p, ecart, exposure);
						    
							//*maxy  = p[0];
						    //*maxx  = p[0];
						    posx  = p[1]+xx1;
						    fwhmx = p[2];
						    //*fondx = p[3];
						    //*fondy = p[3];
						    posy  = p[4]+yy1;
						    fwhmy = p[5];

							nombre=(xx2-xx1+1)*(yy2-yy1+1);
							taille=sizeof(double);
							vec=NULL;
							if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec,&nombre,&taille,"vf"))!=OK_DLL) {
								tt_free(v,"v");
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
										vec[n23]=(double)pin->p[xmax*j+i];
										f23 += (double)pin->p[xmax*j+i];
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
							tt_free(vec,"vec");
							/* --- photocentre (xc,yc) ---*/
							/*xx1=(int)(xcc-r1);
							xx2=(int)(xcc+r1);
							yy1=(int)(ycc-r1);
							yy2=(int)(ycc+r1);
							if (xx1<0) xx1=0;
							if (xx1>=xmax) xx1=xmax-1;
							if (xx2<0) xx2=0;
							if (xx2>=xmax) xx2=xmax-1;
							if (yy1<0) yy1=0;
							if (yy1>=ymax) yy1=ymax-1;
							if (yy2<0) yy2=0;
							if (yy2>=ymax) yy2=ymax-1;*/
							seuilf=0.2*(v[6]-fmed);
							sx=0.;
							sy=0.;
							flux=0.;
							for (j=yy1;j<=yy2;j++) {
								dy=1.*j-ycc;
								dy2=dy*dy;
								for (i=xx1;i<=xx2;i++) {
									dx=1.*i-xcc;
									dx2=dx*dx;
									d2=dx2+dy2;
									value=(double)pin->p[xmax*j+i]-fmed;
									if ((d2<=r11)&&(value>=seuilf)) {
										flux += value;
										sx += (double)(i * value);
										sy += (double)(j * value);
										pout->p[xmax*j+i] = 1;
									} else {
										pout->p[xmax*j+i] = 0;
									}
								}
							}
							if (flux!=0.) {
								xcc = sx / flux ;
								ycc = sy / flux ;
							}
							/* --- photometrie (flux) ---*/
							/*xx1=(int)(xcc-r1);
							xx2=(int)(xcc+r1);
							yy1=(int)(ycc-r1);
							yy2=(int)(ycc+r1);
							if (xx1<0) xx1=0;
							if (xx1>=xmax) xx1=xmax-1;
							if (xx2<0) xx2=0;
							if (xx2>=xmax) xx2=xmax-1;
							if (yy1<0) yy1=0;
							if (yy1>=ymax) yy1=ymax-1;
							if (yy2<0) yy2=0;
							if (yy2>=ymax) yy2=ymax-1;
							flux=0.;
							for (j=yy1;j<=yy2;j++) {
								dy=1.*j-ycc;
								dy2=dy*dy;
								for (i=xx1;i<=xx2;i++) {
									dx=1.*i-xcc;
									dx2=dx*dx;
									d2=dx2+dy2;
									value=(double)pin->p[xmax*j+i]-fmed;
									if ((d2<=r11)) {
										flux += value;
									}
								}
							}*/
							/* --- astrometrie (ra,dec) ---*/
							ra=0.;
							dec=0.;
							if (valid_ast==TT_YES) {
								tt_util_astrom_xy2radec(&p_ast,xcc,ycc,&ra,&dec);
							}
							ra*=180./(TT_PI);
							dec*=180./(TT_PI);
							/* --- sortie du resultat ---*/
							fprintf(fic,"%d %f %f %f %f %f %f %f %f %f %f\n",
							ntrainee,xcc+1.,posx,ycc+1.,posy,flux,fmed,ra,dec,fwhmx,fwhmy);
// on met � 1 ou 0 les pixels dans pout que l'on a utlis�es pour aller plus vite et pas retravaill� dessus
							tt_free2((double**)&mat,"mat");
							free(ecart);
							free(p);
						}
					}
               
				}
			  }

            }
         }
      }
   }
   tt_free(v,"v");  
   fclose(fic);
 
   return(OK_DLL);
}




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
void fittrainee2 (int sizex, int sizey,double **mat,double *p,double *ecart,double exposure) {

   int l,nbmax,m;
   double l1,l2,a0;
   double e,er1,y0;
   double m0,m1;
   double e1[6]; /* ici ajout */
   int i,jx,jy;
   double rr2;
   double xx,yy;

   p[0]=mat[0][0];
   p[1]=0.;
   p[3]=mat[0][0];
   p[4]=0.;

  				
   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
	     if (mat[jx][jy]>p[0]) {p[0]=mat[jx][jy]; p[1]=1.*jx; p[4]=1.*jy; }
         if (mat[jx][jy]<p[3]) {p[3]=mat[jx][jy]; }
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
//				y0=y0*Mask[jx][jy];
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
				rr2=(xx-p[1])*(xx-p[1])+(yy-p[4])*(yy-p[4]);
				y0=p[0]*exp(-rr2/p[2]/p[5])+p[3];
//				y0=y0*Mask[jx][jy];
				l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
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