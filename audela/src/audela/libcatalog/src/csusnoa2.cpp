#include "csusno.h"
/*
 * csusnoa2.c
 *
 *  Created on: Jul 24, 2012
 *      Author: A. Klotz
 */

int usnoa2_catchart_idx(int index,int nelem);
void usnoa2_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle);
void usnoa2_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA);
double usnoa2_R2D(double a);
double usnoa2_D2R(double a);
int usnoa2_Big2LittleEndianLong(int l);
double usnoa2_GetUsnoBleueMagnitude(int magL);
double usnoa2_GetUsnoRedMagnitude(int magL);
int usnoa2_GetUsnoSign(int magL);
int usnoa2_GetUsnoQflag(int magL);
int usnoa2_GetUsnoField(int magL);

static char outputLogChar[1024];
double PI;

int cmd_tcl_csusnoa2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	PI=4.*(double)atan((double)1);

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeMin(mag) magnitudeMax(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLogChar,"usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeMax(mag) magnitudeMin(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Read inputs */
	char pathOfCatalog[1024];
	strcpy(pathOfCatalog,argv[1]);
	const double ra00    = atof(argv[2]);
	const double dec00   = atof(argv[3]);
	const double radius  = atof(argv[4]);
	double magMin;
	double magMax;
	if(argc == 7) {
		magMin            = atof(argv[5]);
		magMax            = atof(argv[6]);
	} else {
		magMin            = -99.99;
		magMax            = 99.99;
	}

	/***************************************************************************/
	/* Cree une liste a partir de l'USNO                                       */
	/* version Buil                                                            */
	/***************************************************************************/
	/***************************************************************************/
   int k;
   double magr=0.,magv=0.,magb=0.;
	double rayon=radius/60.;
	double rayonrad=rayon*PI/180.0;
   int taille,nombre;
	int nl=20,nk=500,lambdamax=10,kmax=50;
   /* --- ajout Buil */
   double alpha1;
   double alpha2;
   double delta2;
   double delta1;
   double v,r;
   double l_alpha,l_delta;
   double Trad=PI/180.0;
   double Tdeg=180.0/PI;
   int compteur=0,compteur_tyc=0;
   double ra,de,mag_red,mag_bleue;
   double dalpha,ddelta,dalpha2;
   int indexSPD,indexRA;
   USNO2A_INDEX *p_index=NULL;
   int i,j,first,flag;
   char nom[1024];
   FILE *acc,*cat;
   char buf_acc[31];
   int offset,nbObjects;
   int raL,deL,magL;
   double rienf;
   int bordurex=0,bordurey=0;
   int np_index=0;
   double a0,d0;
   char slash[2];
   double magrlim,magblim;
	int sign,qflag,field;
	char result[1024];

   /* --- intialisations ---*/
   strcpy(slash,"/");
   magrlim=magMin;
   magblim=magMax;

   /* ajout d'un separateur a la fin du chemin s'il le separateur est absent */
   if ( strlen(pathOfCatalog) > 0 ) {
	   if ( pathOfCatalog[strlen(pathOfCatalog)-1] != slash[0] ) {
		   strcat(pathOfCatalog,slash);
	   }
   }

	double a0rad,dec0rad,dist,posangle;
	a0rad=usnoa2_D2R(ra00);
	dec0rad=usnoa2_D2R(dec00);

   /*=== alpha en heures ===*/
   a0=ra00/15.0;

   /* On calcul les bornes en alpha du champ
   Les bornes de recherches dependent du lieu dans le ciel ainsi que
   le rayon du champ */
	d0=dec00;
   if (d0==90.0) d0=89.9999;
   if (d0==-90.0) d0=-89.9999;

	l_alpha=l_delta=rayon; // new

   r=l_alpha/2.0;
   v=sin(r*Trad)/cos(d0*Trad);
   if (v>=1.0) {
      /* Si le pole est dans le champ alors on lit de 0 a 24 heures */
      alpha1=0.0;
      alpha2=23.99999999;
   } else {
      /* Si le pole n'est pas dans le champ */
      v=asin(v);
      v*=Tdeg/15.0;
      alpha1=a0-v;
      alpha2=a0+v;
      if (alpha1<0.0) alpha1+=24.0;
      if (alpha2>24.0) alpha2-=24.0;
   }

   r=l_delta/2.0;
   delta2=d0+r;
   delta1=d0-r;
   if (delta2>90.0) delta2=90.0;
   if (delta1<-90.0) delta1=-90.0;

   /*=== recherche les differentes zones presentes dans l'image ===*/
   /* on est a cheval sur 0 heure */
   if (alpha1>alpha2) {
      dalpha=(23.99999999-alpha1)/97.0;
      ddelta=(delta2-delta1)/25.0;
		nombre=3000; /* nombre entier > a ce que vaudra nombre en sortie de boucle */
		taille=sizeof(USNO2A_INDEX);
		p_index=(USNO2A_INDEX*)calloc(nombre,taille);
      j=0;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[usnoa2_catchart_idx(j++,nombre)].flag=-1;
				/*p_index[j++].flag=-1;*/
			}
		}
		dalpha2=alpha2/97.0;
		for (ra=0;ra<=alpha2;ra+=dalpha2) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[usnoa2_catchart_idx(j++,nombre)].flag=-1;
				/*p_index[j++].flag=-1;*/
			}
		}
		nombre=j+5;
		taille=sizeof(USNO2A_INDEX);
		free(p_index);
		p_index=NULL;
		p_index=(USNO2A_INDEX*)calloc(nombre,taille);
		i=0;
		for (ra=alpha1;ra<=23.99999999;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[i++].flag=-1;
			}
		}
		for (ra=0;ra<=alpha2;ra+=dalpha2) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[i++].flag=-1;
			}
		}

      p_index[i++].flag=-1;  // on complete pour bien borner la table
      p_index[i++].flag=-1;
      np_index=i;

      k=0;
      first=1;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				usnoa2_ComputeUsnoIndexs(usnoa2_D2R(15.0*ra),usnoa2_D2R(de),&indexSPD,&indexRA);
				if (first==1) {
					p_index[k].flag=1;
					p_index[k].indexRA=indexRA;
					p_index[k].indexSPD=indexSPD;
					first=0;
				} else {
					flag=0;
					for (i=0;i<np_index;i++) {
						if (p_index[i].flag==-1) {
							break;
						}
						if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD) {
							flag=1;
							break;
						}
					}
					if (flag==0) {
						k++;
						p_index[k].flag=1;
						p_index[k].indexRA=indexRA;
						p_index[k].indexSPD=indexSPD;
					}
				}
			}
		}
		for (ra=0;ra<=alpha2;ra+=dalpha2) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				usnoa2_ComputeUsnoIndexs(usnoa2_D2R(15.0*ra),usnoa2_D2R(de),&indexSPD,&indexRA);
				if (first==1) {
					p_index[k].flag=1;
					p_index[k].indexRA=indexRA;
					p_index[k].indexSPD=indexSPD;
					first=0;
				} else {
					flag=0;
					for (i=0;i<np_index;i++) {
						if (p_index[i].flag==-1) {
							break;
						}
						if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD) {
							flag=1;
							break;
						}
					}
					if (flag==0) {
						k++;
						p_index[k].flag=1;
						p_index[k].indexRA=indexRA;
						p_index[k].indexSPD=indexSPD;
					}
				}
			}
		}
	}
   /*=== recherche les differentes zones presentes dans l'image ===*/
   /* on n'est pas a cheval sur 0 heure */
   else {
		dalpha=(alpha2-alpha1)/97.0;
		ddelta=(delta2-delta1)/25.0;
		nombre=3000; /* nombre entier > a ce que vaudra nombre en sortie de boucle */
		taille=sizeof(USNO2A_INDEX);
		p_index=(USNO2A_INDEX*)calloc(nombre,taille);
		j=0;
		for (ra=alpha1;ra<=alpha2;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[usnoa2_catchart_idx(j++,nombre)].flag=-1;
			}
		}
		nombre=j+5;
		taille=sizeof(USNO2A_INDEX);
		free(p_index);
		p_index=NULL;
		p_index=(USNO2A_INDEX*)calloc(nombre,taille);
		i=0;
		for (ra=alpha1;ra<=alpha2;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[i++].flag=-1;
			}
		}
      p_index[i++].flag=-1;  // on complete pour bien borner la table
      p_index[i++].flag=-1;
      np_index=i;
      k=0;
      first=1;
      for (ra=alpha1;ra<=alpha2;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				usnoa2_ComputeUsnoIndexs(usnoa2_D2R(15.0*ra),usnoa2_D2R(de),&indexSPD,&indexRA);
				if (first==1) {
					p_index[k].flag=1;
					p_index[k].indexRA=indexRA;
					p_index[k].indexSPD=indexSPD;
					first=0;
				} else {
					flag=0;
					for (i=0;i<np_index;i++) {
						if (p_index[i].flag==-1) {
							break;
						}
						if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD) {
							flag=1;
							break;
						}
					}
					if (flag==0) {
						k++;
						p_index[k].flag=1;
						p_index[k].indexRA=indexRA;
						p_index[k].indexSPD=indexSPD;
					}
				}
			}
		}
   }

   /*==== balayage des fichiers des catalogues .CAT ====*/

   a0*=15.0*Trad;
   d0*=Trad;
   j=0;
   compteur=0;
   compteur_tyc=0;

	/* Print the filtered stars */
	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { USNOA2 { } { ra_deg dec_deg sign qflag field magB magR } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{ ",-1); // start of main list

   /* ============================================== */
   /* = On effectue ici le balayage sur le USNO    = */
   /* ============================================== */

   /*=== balayage des zones trouvees .ACC ===*/
	for (k=0;k<np_index;k++) {
		if (p_index[k].flag==-1) {
			break;
		}
      sprintf(nom,"%sZONE%04d.ACC",pathOfCatalog,p_index[k].indexSPD*75);
      if ((acc=fopen(nom,"r"))==NULL) {
         sprintf(result,"File %s from USNO catalog not found\n",nom);
			Tcl_DStringAppend(&dsptr,result,-1);
			Tcl_DStringResult(interp,&dsptr);
			Tcl_DStringFree(&dsptr);
			free(p_index);
         return(TCL_ERROR);
      }
      /*=== on lit 30 caracteres dans le fichier .acc ===*/
      for (i=0;i<=p_index[k].indexRA;i++) {
         if (fread(buf_acc,1,30,acc)!=30) break;
      }
#ifdef OS_LINUX_GCC_SO
      sscanf(buf_acc,"%lf %d %d",&rienf,&offset,&nbObjects);
#else
      sscanf(buf_acc,"%lf %ld %ld",&rienf,&offset,&nbObjects);
#endif
      offset=(offset-1)*12;
      p_index[k].offset=offset;
      p_index[k].nbObjects=nbObjects;
      fclose(acc);
   }

   /*=== balayage des zones trouvees .CAT ===*/
	for (k=0;k<np_index;k++) {

		if (p_index[k].flag==-1) {
			break;
		}
      sprintf(nom,"%sZONE%04d.CAT",pathOfCatalog,p_index[k].indexSPD*75);
      if ((cat=fopen(nom,"rb"))==NULL) {
         sprintf(result,"File %s not found\n",nom);
			Tcl_DStringAppend(&dsptr,result,-1);
			Tcl_DStringResult(interp,&dsptr);
			Tcl_DStringFree(&dsptr);
			free(p_index);
         return(TCL_ERROR);
      }
      /* deplacement sur la premiere etoile */
      fseek(cat,p_index[k].offset,SEEK_SET);
      nbObjects=p_index[k].nbObjects;
      /* lecture de toute les etoiles de la zone */
      for (i=0;i<nbObjects;i++) {
			double rarad, decrad;
         if (fread(&raL,1,4,cat)!=4) break;
         if (fread(&deL,1,4,cat)!=4) break;
         if (fread(&magL,1,4,cat)!=4) break;
         raL=usnoa2_Big2LittleEndianLong(raL);
         deL=usnoa2_Big2LittleEndianLong(deL);
         magL=usnoa2_Big2LittleEndianLong(magL);
         ra=(double)raL/360000.0;
			rarad=ra*PI/180;
         de=(double)deL/360000.0-90.0;
			decrad=de*PI/180;
         mag_red=usnoa2_GetUsnoRedMagnitude(magL);
         mag_bleue=usnoa2_GetUsnoBleueMagnitude(magL);
			sign=usnoa2_GetUsnoSign(magL);
			qflag=usnoa2_GetUsnoQflag(magL);
			field=usnoa2_GetUsnoField(magL);
			usnoa2_sepangle(a0rad,rarad,dec0rad,decrad,&dist,&posangle);
	      if (dist<rayonrad && mag_red>=magMin && mag_red<=magMax ) {
				compteur=compteur+1;
				sprintf(result,"{ { USNOA2 { } {%f %f %d %d %d %.2f %.2f} } } ",ra,de,sign,qflag,field,mag_bleue,mag_red);
				Tcl_DStringAppend(&dsptr,result,-1);
            j++;
         }
      }
      fclose(cat);

   }

   /* --- fin de la routine de Christian ---*/

	 // end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release the memory */
	if (p_index!=NULL) {
		free(p_index);
	}

	return (TCL_OK);
}

int usnoa2_catchart_idx(int index,int nelem) {
	if (index>=nelem) {
		/*printf("Depassement de pointeur %d>=%d\n",index,nelem);*/
		index=nelem-1;
	}
	if (index<0) {
		/*printf("Depassement de pointeur %d<0\n",index);*/
		index=0;
	}
	return index;
}

void usnoa2_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle)
/***************************************************************************/
/* Calcul de l'angle de separation et de l'angle de position au pole nord  */
/* a partir de deux coordonnees spheriques.                                */
/***************************************************************************/
/* Tous les angles sont en radian.                                         */
/***************************************************************************/
{
   double a,b,c,aa,d3,a3;
   d3=PI/2;
   a3=0;
   a=(sin(d2)*sin(d3)+cos(d2)*cos(d3)*cos(a2-a3));
   if (a<-1.) {a=-1.;}
   if (a>1.) {a=1.;}
   a=acos(a);
   b=(sin(d1)*sin(d3)+cos(d1)*cos(d3)*cos(a1-a3));
   if (b<-1.) {b=-1.;}
   if (b>1.) {b=1.;}
   b=acos(b);
   c=(sin(d1)*sin(d2)+cos(d1)*cos(d2)*cos(a1-a2));
   if (c<-1.) {c=-1.;}
   if (c>1.) {c=1.;}
   c=acos(c);
   if (b*c!=0.) {
      aa=((cos(a)-cos(b)*cos(c))/(sin(b)*sin(c)));
      aa=(aa>1)?1.:aa;
      aa=(aa<-1)?-1.:aa;
      aa=acos(aa);
      if (sin(a2-a1)<0) {
         aa=-aa;
      }
      aa=fmod(aa+4*PI,2*PI);
   } else {
	  aa=0.;
   }
   *dist=c;
   *posangle=aa;
}

/*************** COMPUTEUSNOINDEXS ********************/
/* Calcul de la zone d'ascension droite et de la zone */
/* de South Polar Declination a partir de l'ascension */
/* droite et de la declinaison.                       */
/*====================================================*/
void usnoa2_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA)
{
/*-------------------------------------------*/
/* On determine la bande de declinaison      */
/* Il y a 24 bandes de 7.5d a partir de -90d */
/*-------------------------------------------*/
if (de>=(PI)/2.-1.0e-9)
   *indexSPD=23;
else
   *indexSPD=(int)floor(usnoa2_R2D(de+(PI)/2.)/7.5);

/*---------------------------------------------------*/
/* On determine l'index dans les 96 zones de 15' en  */
/* ascension droite. ((ra/15)*60)/15: transformation */
/* en heures puis en minutes puis calcul de l'index  */
/*---------------------------------------------------*/
*indexRA=(int)floor((4.0*usnoa2_R2D(ra))/15.0);
}

/*************** R2D ***************/
/* Conversion de radiant en degres */
/***********************************/
double usnoa2_R2D(double a)
{
return(a*57.29577951);
}

/*************** D2R ***************/
/* Conversion de radiant en degres */
/***********************************/
double usnoa2_D2R(double a)
{
return(a/57.29577951);
}

/*=========================================================*/
/* Transformation de Big en Little Endian (et le contraire */
/* d'ailleurs...!!!). L'entier 32 bits ABCD est transforme */
/* en DCBA.                                                */
/*=========================================================*/
int usnoa2_Big2LittleEndianLong(int l)
{
return(l << 24) | ((l << 8) & 0x00FF0000) |
      ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On prend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double usnoa2_GetUsnoBleueMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];
double TT_EPS_DOUBLE=2.225073858507203e-308;

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+4,3); *(buf2+3)='\0';
mag = (double)atof(buf2)/10.0;
if (mag<=TT_EPS_DOUBLE)
   {
   strncpy(buf2,buf+1,3);
   *(buf2+3)='\0';
   if ((double)atof(buf2)<=TT_EPS_DOUBLE)
      {
      strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
      mag = (double)atof(buf2)/10.0;
      }
   }
return mag;
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On rpend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double usnoa2_GetUsnoRedMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
mag=(double)atof(buf2)/10.0;
if (mag==999.0)
   {
   strncpy(buf2,buf+4,3); *(buf2+3) = '\0';
   mag=(double)atof(buf2)/10.0;
   }
return mag;
}

/*=======================================================================*/
/* The third 32-bit integer has been packed according to the following   */
/* format. SQFFFBBBRRR   (decimal), where                                */
/*  S = sign is - if this entry is correlated with an ACT star.  For     */
/*      these objects, the PMM's position and magnitude are quoted.  If  */
/*      you want the ACT values, use the ACT.  Please note that we have  */ 
/*      not preserved the identification of the ACT star.  Since there   */
/*      are so few ACT stars, spatial correlation alone is sufficient    */
/*      to do the cross-identification should it be needed.  {DIFFERENT} */
/*=======================================================================*/
int usnoa2_GetUsnoSign(int magL)
{
int sign;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+0,1); *(buf2+1) = '\0';
sign=(int)atoi(buf2);
return sign;
}

/*=======================================================================*/
/* The third 32-bit integer has been packed according to the following   */
/* format. SQFFFBBBRRR   (decimal), where                                */
/*  Q = 1 if internal PMM flags indicate that the magnitude(s) might be  */
/*      in error, or is 0 if things looked OK.  As discussed in read.pht,*/
/*      the PMM gets confused on bright stars.  If more than 40% of the  */
/*      pixels in the image were saturated, our experience is that the   */
/*      image fitting process has failed, and that the listed magnitude  */
/*      can be off by 3 magnitudes or more.  The Q flag is set if either */
/*      the blue or red image failed this test.  In general, this is a   */
/*      problem for bright (<12th mag) stars only. {SAME}                */
/*=======================================================================*/
int usnoa2_GetUsnoQflag(int magL)
{
int qflag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+1,1); *(buf2+1) = '\0';
qflag=(int)atoi(buf2);
return qflag;
}

/*=======================================================================*/
/* The third 32-bit integer has been packed according to the following   */
/* format. SQFFFBBBRRR   (decimal), where                                */
/*  FFF = field on which this object was detected.  In the north, we     */
/*    adopted the MLP numbers for POSS-I.  These start at 1 at the       */
/*    north pole (1 and 2 are degenerate) and end at 825 in the -20      */
/*    degree zone.  Note that fields 723 and 724 are degenerate, and we  */
/*    measured but omitted 723 in favor of 724 which corresponds to the  */
/*    print in the paper POSS-I atlas.  In the south, the fields start   */
/*    at 1 at the south pole and the -20 zone ends at 606.  To avoid     */
/*    wasting space, the field numbers were not put on a common system.  */
/*                                                                       */
/*    Instead, you should use the following test                         */
/*          IF ((zone.lt.750).and.(field.le.606)) THEN                   */
/*         south(field)                                                  */
/*       ELSE                                                            */
/*         north(field)                                                  */
/*       ENDIF                                                           */
/*    DIFFERENT only in that A1.0 changed from south to north at -30     */
/*    and A2.0 changes at -20 (south)/-18 (north).  The actual boundary  */
/*    is pretty close to -17.5 degrees, depending on actual plate center.*/
/*=======================================================================*/
int usnoa2_GetUsnoField(int magL)
{
int field;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+2,3); *(buf2+3) = '\0';
field=(int)atoi(buf2);
return field;
}
