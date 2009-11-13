/* Ce script contient des fonctions que j'utilise pour faire des statistiques
sur les étoiles du GCVS : Trouver le numéro de l'étoile dans le fichier bin
et le nombre de mesures avec les 4 filtres*/

#include "aktcl.h"
#include "ak_4.h"

int Cmd_aktcl_starnum(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/**************************************************************************************
** Cette fonction trouve dans un fichier htm, l'etoile la plus proche des coordonnees**
** definies en entree. Elle renvoie l'indice de l'etoile dans le fichier htm_ref, la***
** distance par rapport aux coordonnees en arcsec, et le nombre de mesures >-99.9 dans*
** les filtres B C I R V***************************************************************
*/
{
   char s[100];
   char path[1024];
   char filename[1024],htm[100];
   struct_htmref htmref;
   struct_htmmes htmmes;
   double ra0,dec0,dra,ddec,distance,distance0,coeff,cosdec,mag,ra,dec;
   int indice,starnum,B_mes,C_mes,I_mes,R_mes,V_mes;
   unsigned char filtre;
   FILE *f;
   Tcl_DString dsptr;
   if(argc<5) {
      sprintf(s,"Usage: %s path htm ra0 dec0", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(htm,argv[2]);
	  ra0=atof(argv[3]);
	  dec0=atof(argv[4]);
	  /*Inits*/
	  coeff = 4*atan(1)/180.;
      distance=10000.;
      /* --- Cherche l'étoile la plus proche dans le fichier htmref ---*/
      sprintf(filename,"%s%s_ref.bin",path,htm);
      f=fopen(filename,"rb");
      if (f==NULL) {
         sprintf(s,"filename %s not found",filename);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      while (feof(f)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f)>1) {
            indice  = htmref.indexref;
			ra      = htmref.ra;
			dec     = htmref.dec;
			dra     = ra-ra0;
			cosdec  = cos(coeff*dec);
			dra    *= cosdec*cosdec*dra;
			ddec    = dec-dec0;
			ddec   *= ddec;
			distance0 = 3600*sqrt(dra+ddec);
			if(distance>distance0) {
				distance=distance0;
				starnum=indice;
			}
         }
      }
      fclose(f);
      /* --- Compte le nombre de mesure ---*/
      sprintf(filename,"%s%s_mes.bin",path,htm);
      f=fopen(filename,"rb");
      if (f==NULL) {
         sprintf(s,"filename %s not found",filename);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  B_mes=0;
	  C_mes=0;
	  I_mes=0;
	  R_mes=0;
	  V_mes=0;      
	  while (feof(f)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f)>1) {
            indice  = htmmes.indexref;
			if (indice!=starnum) {
				continue;
			} else {
				filtre = htmmes.codefiltre;
				mag    = htmmes.magcali;
				if (mag>-50.) {
					switch (filtre) {
						case 66 : B_mes++;break;
						case 67 : C_mes++;break;
						case 73 : I_mes++;break;
						case 82 : R_mes++;break;
						case 86 : V_mes++;break;
					}
				}
				break;
			}
		 }
	  }
	  while (feof(f)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f)>1) {
            indice  = htmmes.indexref;
			if (indice!=starnum) {
				break;
			} else {
				filtre = htmmes.codefiltre;
				mag    = htmmes.magcali;
				if (mag>-50.) {
					switch (filtre) {
						case 66 : B_mes++;break;
						case 67 : C_mes++;break;
						case 73 : I_mes++;break;
						case 82 : R_mes++;break;
						case 86 : V_mes++;break;
					}
				}
			}
		 }
	  }
      fclose(f);
      /* --- on renome le fichier ---*/
      sprintf(s,"%10s %4d %6.1f %5d %5d %5d %5d %5d",htm,starnum,distance,B_mes,C_mes,I_mes,R_mes,V_mes);
      Tcl_DStringInit(&dsptr);
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringResult(interp,&dsptr);
	  Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}
/****************************************************************************************/
int Cmd_aktcl_statcata(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************************
** Cette fonction etablie un histogramme des mesures valables (>-99.9) dans un htm dans**
** les filtres B C I R V. Elle renvoie un histogramme de 20 cases (4 par filtres)avec ***
** [filtre_inf10,filtre_inf50,filtre_inf100, filtre_sup100]******************************
*/
{
   char s[400];
   char path[1024];
   char filename[1024],htm[100];
   struct_htmmes htmmes;
   double mag;
   int k_hist,indice,indice0,B_mes,C_mes,I_mes,R_mes,V_mes;
   unsigned char filtre;
   FILE *f;
   int histo[20];
   Tcl_DString dsptr;
   if(argc<3) {
      sprintf(s,"Usage: %s path htm", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(htm,argv[2]);
	  /*Inits*/
	  for (k_hist=0;k_hist<20;k_hist++) {
          histo[k_hist]=0;
	  }
      /* --- Compte le nombre de mesure ---*/
      sprintf(filename,"%s%s_mes.bin",path,htm);
      f=fopen(filename,"rb");
      if (f==NULL) {
         sprintf(s,"filename %s not found",filename);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  B_mes=0;
	  C_mes=0;
	  I_mes=0;
	  R_mes=0;
	  V_mes=0;
	  indice0 = 0;
	  while (feof(f)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f)>1) {
			mag    = htmmes.magcali;
			if (mag>-50.) {
				filtre = htmmes.codefiltre;
                indice  = htmmes.indexref;
				if (indice==indice0) {				
					switch (filtre) {
						case 66 : B_mes++;break;
						case 67 : C_mes++;break;
						case 73 : I_mes++;break;
						case 82 : R_mes++;break;
						case 86 : V_mes++;break;
					}
				}else {
					if ((B_mes>0)&&(B_mes<=10)) {
						histo[0]++;
					} else if ((B_mes>10)&&(B_mes<=50)){
						histo[1]++;
					} else if ((B_mes>50)&&(B_mes<=100)){
						histo[2]++;
					} else if (B_mes>100){
						histo[3]++;
					}
					if ((C_mes>0)&&(C_mes<=10)) {
						histo[4]++;
					} else if ((C_mes>10)&&(C_mes<=50)){
						histo[5]++;
					} else if ((C_mes>50)&&(C_mes<=100)){
						histo[6]++;
					} else if (C_mes>100){
						histo[7]++;
					}
					if ((I_mes>0)&&(I_mes<=10)) {
						histo[8]++;
					} else if ((I_mes>10)&&(I_mes<=50)){
						histo[9]++;
					} else if ((I_mes>50)&&(I_mes<=100)){
						histo[10]++;
					} else if (I_mes>100){
						histo[11]++;
					}
					if ((R_mes>0)&&(R_mes<=10)) {
						histo[12]++;
					} else if ((R_mes>10)&&(R_mes<=50)){
						histo[13]++;
					} else if ((R_mes>50)&&(R_mes<=100)){
						histo[14]++;
					} else if (R_mes>100){
						histo[15]++;
					}
					if ((V_mes>0)&&(V_mes<=10)) {
						histo[16]++;
					} else if ((V_mes>10)&&(V_mes<=50)){
						histo[17]++;
					} else if ((V_mes>50)&&(V_mes<=100)){
						histo[18]++;
					} else if (V_mes>100){
						histo[19]++;
					}
					B_mes=1;
					C_mes=1;
					I_mes=1;
					R_mes=1;
					V_mes=1;
					indice0=indice;
				}				
			}
		 }
	  }
      fclose(f);
	  /*Sortie*/ 
	  Tcl_DStringInit(&dsptr);

	  for (k_hist=0;k_hist<20;k_hist++) {
          sprintf(s,"%6d",histo[k_hist]);
		  Tcl_DStringAppend(&dsptr,s,-1);
	  }	  
	  Tcl_DStringResult(interp,&dsptr);
	  Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

/****************************************************************************************/
int ak_fitspline(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff)
/****************************************************************************************
/* Entrees :                                                                            */
/*  x[0..n1..n2]                                                                        */
/*  y[0..n1..n2]                                                                        */
/*  dy[0..n1..n2]                                                                       */
/*  s = parametre 0-1                                                                   */
/* Sorties :                                                                            */
/*  xx[0..nn]                                                                           */
/*  ff[0..nn]                                                                           */
/*                                                                                      */
/* x et xx doivent etre pralablement tries en ordre croissants                          */
/****************************************************************************************/
{
	int i,m1,m2,n,ii;
	double e,f,f2,g,h,p;
	double *r,*r1,*r2,*t,*t1,*u,*v;
	double *a,*b,*c,*d;

	n=(n2+1)-(n1-1)+1;
	r=(double*)calloc(n,sizeof(double));
	if (r==NULL) { return 1; }
	r1=(double*)calloc(n,sizeof(double));
	if (r1==NULL) { free(r); return 1; }
	r2=(double*)calloc(n,sizeof(double));
	if (r2==NULL) { free(r); free(r1); return 1; }
	t=(double*)calloc(n,sizeof(double));
	if (t==NULL) { free(r); free(r1); free(r2); return 1; }
	t1=(double*)calloc(n,sizeof(double));
	if (t1==NULL) { free(r); free(r1); free(r2); free(t); return 1; }
	u=(double*)calloc(n,sizeof(double));
	if (u==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; return 1; }
	v=(double*)calloc(n,sizeof(double));
	if (v==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); return 1; }
	a=(double*)calloc(n,sizeof(double));
	if (a==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; return 1; }
	b=(double*)calloc(n,sizeof(double));
	if (b==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); return 1; }
	c=(double*)calloc(n,sizeof(double));
	if (c==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); free(b) ; return 1; }
	d=(double*)calloc(n,sizeof(double));
	if (d==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); free(b); free(c) ; return 1; }

	m1=n1-1;
	m2=n2+1;
	r[m1]=r[n1]=r1[n2]=r2[n2]=r2[m2]=u[m1]=u[n1]=u[n2]=u[m2]=p=0;
	m1=n1+1;
	m2=n2-1;
	h=x[m1]-x[n1];
	f=(y[m1]-y[n1])/h;
	for (i=m1;i<=m2;i++) {
		g=h;
		h=x[i+1]-x[i];
		e=f;
		f=(y[i+1]-y[i])/h;
		a[i]=f-e;
		t[i]=2*(g+h)/3;
		t1[i]=h/3;
		r2[i]=dy[i-1]/g;
		r[i]=dy[i+1]/h;
	}
	for (i=m1;i<=m2;i++) {
		b[i]=r[i]*r[i]+r1[i]*r1[i]+r2[i]*r2[i];
		c[i]=r[i]*r1[i+1]+r1[i]*r2[i+1];
		d[i]=r[i]*r2[i+2];
	}
	f2=-s;
	while (1==1) {
		//:next_interation
		for (i=m1;i<=m2;i++) {
			r1[i-1]=f*r[i-1];
			r2[i-2]=g*r[i-2];
			r[i]=1/(p*b[i]+t[i]-f*r1[i-1]-g*r2[i-2]);
			u[i]=a[i]-r1[i-1]*u[i-1]-r2[i-2]*u[i-2];
			f=p*c[i]+t1[i]-h*r1[i-1];
			g=h;
			h=d[i]*p;
		}
		for (i=m2;i>=m1;i--) {
			u[i]=r[i]*u[i]-r1[i]*u[i+1]-r2[i]*u[i+2];
		}
		e=h=0;
		for (i=n1;i<=m2;i++) {
			g=h;
			h=(u[i+1]-u[i])/(x[i+1]-x[i]);
			v[i]=(h-g)*dy[i]*dy[i];
			e=e+v[i]*(h-g);
		}
		g=v[n2]=-h*dy[n2]*dy[n2];
		e=e-g*h;
		g=f2;
		f2=e*p*p;
		if ((f2>=s)||(f2<=g)) {
			break;
		}
		f=0;
		h=(v[m1]-v[n1])/(x[m1]-x[n1]);
		for (i=m1;i<=m2;i++) {
			g=h;
			h=(v[i+1]-v[i])/(x[i+1]-x[i]);
			g=h-g-r1[i-1]*r[i-1]-r2[i-2]*r[i-2];
			f=f+g*r[i]*g;
			r[i]=g;
		}
		h=e-p*f;
		if (h<=0) {
			break;
		}
		p=p+(s-f2)/((sqrt(s/e)+p)*h);
		//goto next_iteration;
	}
	// use negative branch of square root, if the sequence of absissae x[i] is strictly decreasing
	for (i=n1;i<=n2;i++) {
		a[i]=y[i]-p*v[i];
		c[i]=u[i];
	}
	for (i=n1;i<=m2;i++) {
		h=x[i+1]-x[i];
		d[i]=(c[i+1]-c[i])/(3*h);
		b[i]=(a[i+1]-a[i])/h-(h*d[i]+c[i])*h;
	}
	// --- compute the final vector
	for (ii=0;ii<nn;ii++) {
		for (i=n1;i<=n2;i++) {
			if ((xx[ii]>=x[i])&&(xx[ii]<x[i+1])) {
				h=xx[ii]-x[i];
				ff[ii]=((d[i]*h+c[i])*h+b[i])*h+a[i];
				break;
			}
		}
	}
	free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); free(b); free(c) ; free(d);
	return 0;
}
