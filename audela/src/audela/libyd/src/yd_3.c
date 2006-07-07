/* yd_3.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <damerdji@obs-hp.fr>
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

/***************************************************************************/
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Ce fichier contient les sources de Yassine.                             */
/***************************************************************************/
#include "yd_3.h"

int yd_aliasing(gsl_vector *jds, int nmes)
/***************************************************************************/
/* Fonction aliasing                                                        */
/***************************************************************************/
/* Inputs: The jd vector
   Outputs 1 if there is aliasing, 0 else
/***************************************************************************/
{
	/*Nous allons chercher dans ce script toutes les périodes d'aliasing inférieures à 5j
	car leur influence diminue audela de cette limite :
	fréquence d'artefact = frequence +/- x*frequence d'aliasing (x=0.5,1,2)*/
	double dj,maxim,limit_inf,limit_sup,pgcd;
	int *hist=NULL;
	int nhist,kj1,kj2,k_hist,val,kk,temoin,nbad,temoin2,temoin3;
	double *maximums=NULL;
/*FILE *f;*/

	/*Je vais construire 1 histogramme des périodes d'aliasing dand le domaine 18h:4h:20h ncase=116*/
	nhist=116;
	temoin=0;
	temoin3=0;
	limit_inf=18./24;
    limit_sup=20.;
	/*J'alloue la mémoire: je n'utilise pas de vecteur gsl car c'est un vecteur d'entiers*/
	hist=(int*)calloc(nhist,sizeof(int));
	if (hist==NULL) {return 2;}
	/*Je construis mon histogramme*/
/*f=fopen("init.txt","wt");*/
	for (kj1=0;kj1<nmes-1;kj1++) {
		for (kj2=kj1+1;kj2<nmes;kj2++) {
			/*par construction jds est trié*/
            dj=jds->data[kj2]-jds->data[kj1];
/*fprintf(f,"%10.8f\n",dj);*/
			if (dj>limit_sup) {continue;}
			if (dj<limit_inf) {continue;}
			k_hist=(int)floor(6*(dj-limit_inf));
			/*6=24/6*/
			hist[k_hist]++;
			temoin3=1;
		}
	}
/*fclose(f);*/
	if (temoin3==1) {
        /*Je cherche le maximum de l'histogramme*/
		maxim=0.;
		for (k_hist=0;k_hist<nhist;k_hist++) {
			val=hist[k_hist];
			if (val>maxim) {maxim=(double)val;}
		}
		maxim=0.5*maxim;
/*maxim=0.;*/
		/*Je compte le nombre de cases > maxim*/
		kk=0;
		for (k_hist=0;k_hist<nhist;k_hist++) {
			val=hist[k_hist];
			if (val>maxim) {
				kk++;
			}
		}
		nbad=kk;
	   /*Allocation de la memoire : je suis sur que nbad>0 car temoin3>0*/

		maximums=(double*)calloc(nbad,sizeof(double));
		if (maximums==NULL) {return 2;}
		/*Par contre s'il y a une erreur dand l'allocation memoire je ne sais pas comment la remon*/
		kk=0;
		for (k_hist=0;k_hist<nhist;k_hist++) {
			val=hist[k_hist];
			if (val>maxim) {
				maximums[kk]=(k_hist+0.5)/6+limit_inf;
				kk++;
			}
		}
		yd_util_qsort_double(maximums,0,nbad,NULL);
		yd_util_pgcd(maximums,nbad,0.6,0.01,&pgcd,&temoin2);
		if (temoin2==1) {
			/*je normalise le pgcd a 1*/
			pgcd/=ceil(pgcd-0.5);
			if ((pgcd>0.92)&&(pgcd<1.08)) {temoin=1;}
		}
		free(maximums);
	}
	return temoin;
}
/*********************************************************************************************************/
int Cmd_ydtcl_minlong(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction minlong     $jds $mags $poids $longvar $per_range_min $per_range_max $pasfreq $nper1                                                                                */
/*********************************************************************************************************/
/* Inputs: 1) The jd vector
           2) The mag vector
		   3) The mag errors vector
		   4) 1 if we seek a long period - 0 else
		   5) The smallest authorized period per_range_min
		   6) The highest authorized period  per_range_max
		   7) The frequency step
		   8) The period vector if (4)=1 - The number of selected trial periods else
   Outputs 1) The number of kept trial periods
		   2) Total trial periods number
		   3) The best periods vector
	       4) The best "Tetas" vector
/***************************************************************************/
{
	char s[200];
    int code,code2,code3,code4;
    int n_jd,n_mag,nmes,nper;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*errmags,*periods,*tetas,*PERIODS,*TETAS,*phase,*temp,*dtemp;
	double eps,delmag,minmag,maxmag;
	double maxim,phase_prec,phase_suiv,mag_prec,mag_suiv,poids_prec,poids_suiv,delta_mag,delta_phi;
	int k_x,k_xx,kk,k_per;
	gsl_permutation *perm;
    double pasfreq;
	double per_range_min,per_range_max,poids,somme,sommepoids,deltafreq,freq;
	int longvar,nfreqmax,nper2;
    /*FILE *f;*/
    if(argc!=9) {
		sprintf(s,"Usage: %s jds mags poids longvar nper per_range_min per_range_max pasfreq frequencies(or nper)", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&errmags,&n_mag);
		longvar=atoi(argv[4]);
		per_range_min=atof(argv[5]);
		per_range_max=atof(argv[6]);
		pasfreq=atof(argv[7]);
		if (longvar) {
			code4=gsltcltcl_getgslvector(interp,argv[8],&periods,&nper);
		} else {
			nper=atoi(argv[8]);
			periods=gsl_vector_calloc(nper);
		}
        /* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"jds and mags vectors must have the same dimension",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		nmes=n_jd;
		eps=5e-2;
		nfreqmax=80000;
		/*A changer en gsl_vector_minmax*/
		gsl_vector_minmax(mags,&minmag,&maxmag);
		delmag=maxmag-minmag;
		eps=eps/(2*delmag);
/*eps=0.00001;*/
		tetas=gsl_vector_calloc(nper);
		phase=gsl_vector_calloc(nmes);
		temp=gsl_vector_calloc(nmes);
		perm=gsl_permutation_alloc(nmes);
		gsl_vector_add_constant(jds,-jds->data[0]);

		if (longvar) {
			for (k_per=0;k_per<nper;k_per++) {
				gsl_vector_memcpy(temp,jds);
				gsl_vector_scale(temp,1./periods->data[k_per]);
				for (k_x=0;k_x<nmes;k_x++) {
					phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
				}
				gsl_sort_vector_index(perm,phase);
				k_xx=perm->data[0];
				phase_prec=phase->data[k_xx];
				mag_prec=mags->data[k_xx];
				poids_prec=errmags->data[k_xx];
				k_x=1;
				somme=0;
				sommepoids=0;
				while (k_x<nmes) {
					k_xx=perm->data[k_x];
					phase_suiv=phase->data[k_xx];
					mag_suiv=mags->data[k_xx];
					poids_suiv=errmags->data[k_xx];
					delta_phi=phase_suiv-phase_prec+eps;
					delta_mag=fabs(mag_suiv-mag_prec);
					poids=1./(delta_phi*(1e-5+poids_suiv*poids_suiv+poids_prec*poids_prec));
					delta_mag*=poids;
					sommepoids+=poids;
					/*somme+=delta_mag/delta_phi;*/
					somme+=delta_mag;
					k_x++;
					phase_prec=phase_suiv;
					mag_prec=mag_suiv;
					poids_prec=poids_suiv;
				}
				tetas->data[k_per]=somme/sommepoids;
			}
			k_per=nper;
		} else {
			if (per_range_max>20) {per_range_max=20;}
			/*car cest comme ca que nous avons construit Cmd_ydtcl_shortoelong*/
			deltafreq=1./per_range_min-1./per_range_max;
			nper2=(int)(deltafreq/pasfreq);
			if (nper2>nfreqmax) {
				nper2=nfreqmax;
				pasfreq=deltafreq/nper2;
			}
			dtemp=gsl_vector_calloc(nmes);
			gsl_vector_memcpy(dtemp,jds);
			gsl_vector_scale(dtemp,pasfreq);
			gsl_vector_memcpy(temp,jds);
			freq=1./per_range_max;
			gsl_vector_scale(temp,freq);
			k_per=0;
			while (k_per<nper2) {
				for (k_x=0;k_x<nmes;k_x++) {
					phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
				}
				gsl_sort_vector_index(perm,phase);
				k_xx=perm->data[0];
				phase_prec=phase->data[k_xx];
				mag_prec=mags->data[k_xx];
				poids_prec=errmags->data[k_xx];
				k_x=1;
				somme=0;
				sommepoids=0;
				while (k_x<nmes) {
					k_xx=perm->data[k_x];
					phase_suiv=phase->data[k_xx];
					mag_suiv=mags->data[k_xx];
					poids_suiv=errmags->data[k_xx];
					delta_phi=phase_suiv-phase_prec+eps;
					delta_mag=fabs(mag_suiv-mag_prec);
					poids=1./(delta_phi*(1e-5+poids_suiv*poids_suiv+poids_prec*poids_prec));
					delta_mag*=poids;
					sommepoids+=poids;
					/*somme+=delta_mag/delta_phi;*/
					somme+=delta_mag;
					k_x++;
					phase_prec=phase_suiv;
					mag_prec=mag_suiv;
					poids_prec=poids_suiv;
				}
				somme=somme/sommepoids;
				if (k_per<nper) {
					periods->data[k_per]=1./freq;
					tetas->data[k_per]=somme;
				} else {
					kk=gsl_vector_max_index(tetas);
					maxim=tetas->data[kk];
					if (somme<maxim) {
						periods->data[kk]=1./freq;
						tetas->data[kk]=somme;
					}
				}
				k_per++;
				freq+=pasfreq;
				gsl_vector_add(temp,dtemp);
			}
			gsl_vector_free(dtemp);
		}
		nper2=nper;
		if (k_per<nper) {nper2=k_per;}
		PERIODS=gsl_vector_calloc(nper2);
		TETAS=gsl_vector_calloc(nper2);
		if (k_per<nper) {
			for (k_per=0;k_per<nper2;k_per++) {
				PERIODS->data[k_per]=periods->data[k_per];
				TETAS->data[k_per]=tetas->data[k_per];
			}
		} else {
			gsl_vector_memcpy(PERIODS,periods);
			gsl_vector_memcpy(TETAS,tetas);
		}

		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		gsltcltcl_setgslvector(interp,&dsptr,PERIODS,nper2);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,TETAS,nper2);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(phase);
	    gsl_permutation_free(perm);
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(errmags);
		gsl_vector_free(temp);
		gsl_vector_free(periods);
		gsl_vector_free(tetas);
		gsl_vector_free(PERIODS);
		gsl_vector_free(TETAS);
		return TCL_OK;
    }
}

/****************************************************************************/
int Cmd_ydtcl_periodog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction periodog                                                     */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The weigths of mags
			4) The periods vector
   Outputs: The periodogram vector (Scargle 1982)
*/
/***************************************************************************/
{
    char s[200];
    int code,code2,code3,code4;
    int n_jd=0,n_mag=0,nper=0,nmes;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*poids,*periods;
    gsl_vector *Arg,*tem0,*Pxw;
	double Axc,Axs,Ax1,Ax2,Axc_som,Axs_som;
	int i,j;
	double pi,om,tau_s,tau_c,tau;
	double moy,noise;

    if(argc!=7) {
		sprintf(s,"Usage: %s jds mags weigths periods moy noise", argv[0]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
    } else {
		/* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&poids,&n_mag);
		code4=gsltcltcl_getgslvector(interp,argv[4],&periods,&nper);
		moy=atof(argv[5]);
		noise=atof(argv[6]);
		/* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
			Tcl_SetResult(interp,"JDS and MAG vectors must have the same length",TCL_VOLATILE);
			return TCL_ERROR;
		}
		/* --- inits ---*/
        Pxw=gsl_vector_calloc(nper);
		pi   = 4*atan(1);
		nmes=n_jd;
		moy=0.;
        tem0=gsl_vector_calloc(nmes);
		gsl_vector_memcpy(tem0,mags);
		gsl_vector_add_constant(tem0, -moy);
        Arg =gsl_vector_calloc(nmes);
        for (i=0; i<nper;i++){
			om   = 2*pi/periods->data[i];
			tau_s=0;
            tau_c=0;
			for(j=0;j<nmes;j++){
				tau_s += sin(2*om*jds->data[j]);
				tau_c += cos(2*om*jds->data[j]);
			}
			tau = tau_s/tau_c;
			tau =atan(tau)/(2*om);
	 		gsl_vector_memcpy(Arg,jds);
			gsl_vector_add_constant(Arg,-tau);
			gsl_vector_scale (Arg,om);
			Ax1    =0;
			Ax2    =0;
			Axc_som=0;
			Axs_som=0;
			for (j=0;j<nmes;j++){
				Axc = poids->data[j]*cos(Arg->data[j]);
				Ax1 += tem0->data[j]*Axc;
				Axs = poids->data[j]*sin(Arg->data[j]);
				Ax2 += tem0->data[j]*Axs;
				Axc_som += Axc*Axc;
				Axs_som += Axs*Axs;
			}
			Ax1*=Ax1;
			Ax2*=Ax2;
            Pxw->data[i]=0.5*((Ax1/Axc_som)+(Ax2/Axs_som))/noise;
		}
		/* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        gsltcltcl_setgslvector(interp,&dsptr,Pxw,nper);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
	    gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(poids);
		gsl_vector_free(periods);
		gsl_vector_free(Pxw);
		gsl_vector_free(tem0);
		gsl_vector_free(Arg);
		}
	return TCL_OK;
}

/****************************************************************************/
int Cmd_ydtcl_entropie_pdm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction maillage                                                        */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The mags weitghs
			4) The trial periods
   Outputs: 1) The PDM vector (Maraco 1982)
			2) The entropy vector(Cincotta 1995)
*/
/***************************************************************************/
{
    char s[200];
    int code,code2,code3,code4;
    int n_jd=0,n_mag=0,nmes,nper;
    int k_x,k_per;
	Tcl_DString dsptr;
    gsl_vector *phase,*mags,*jds,*poids,*periods,*PDMS,*ENTROPIES;
	double per,PDM,Entropie;

    if(argc!=5) {
		sprintf(s,"Usage: %s jds mags poids period", argv[0]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
     } else {
		/* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&poids,&n_mag);
		code4=gsltcltcl_getgslvector(interp,argv[4],&periods,&nper);
        /* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"jds and mags vectors must have the same length",TCL_VOLATILE);
            return TCL_ERROR;
		}
		nmes=n_jd;
		phase=gsl_vector_calloc(nmes);
		PDMS=gsl_vector_calloc(nper);
		ENTROPIES=gsl_vector_calloc(nper);
		gsl_vector_add_constant(jds,-jds->data[0]);

		for (k_per=0; k_per<nper;k_per++) {
			per=periods->data[k_per];
            gsl_vector_memcpy(phase,jds);
			gsl_vector_scale(phase,1./per);
			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=phase->data[k_x]-floor(phase->data[k_x]);
			}
			yd_pdm_entropie(phase,mags,poids,nmes,&PDM,&Entropie);
			PDMS->data[k_per]=PDM;
			ENTROPIES->data[k_per]=Entropie;
		}
        Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		gsltcltcl_setgslvector(interp,&dsptr,PDMS,nper);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,ENTROPIES,nper);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(phase);
		gsl_vector_free(poids);
		gsl_vector_free(mags);
		gsl_vector_free(jds);
		gsl_vector_free(PDMS);
		gsl_vector_free(ENTROPIES);
		gsl_vector_free(periods);

	}
	return TCL_OK;
}

int yd_pdm_entropie(gsl_vector *phase,gsl_vector *mags,gsl_vector *poids,int nmes,double *PDM, double *Entropie)
/***************************************************************************/
/* Fonction maillage                                                        */
/***************************************************************************/
/* Inputs : 1) The phase vector
			2) The mags vector
			3) The number of bins
   Outputs: 1) The entropy matrix (Cincotta 1995)
			2) The PDM value (Maraco 1982)
*/
/***************************************************************************/
{
    int nlig,ncol,i,j;
    gsl_matrix *EntMat,*ValMat;
	double somlig,err,maxmag,minmag,delmag,valm,valmm,valx,valxx,valp,covar,mag_variance,phase_variance,eps=1e-20;
	int x_pos,y_pos;

	/* --- inits ---*/
	err =0.05;
	gsl_vector_minmax(mags,&minmag,&maxmag);
	delmag=maxmag-minmag;
	ncol=nmes/10;

	nlig   = (int)floor(delmag/err)+1;
    EntMat = gsl_matrix_calloc(nlig,ncol);
	/*ValMat = gsl_matrix_calloc(ncol,7);*/
	ValMat = gsl_matrix_calloc(ncol,3);

	for (i=0;i<nmes;i++) {
		x_pos=(int)floor(phase->data[i]*ncol);
		if (x_pos>=ncol) {
			x_pos=ncol-1;
		}
		if (x_pos<0) {
			x_pos=0;
		}
		y_pos=(int)floor(nlig*(mags->data[i]-minmag)/(delmag+1e-5));
		if (y_pos>=nlig) {
			y_pos=nlig-1;
		}
		if (y_pos<0) {
			y_pos=0;
		}
		gsl_matrix_set(EntMat,y_pos,x_pos,gsl_matrix_get(EntMat,y_pos,x_pos)+1);
		valm=gsl_vector_get(mags,i);
		valp=gsl_vector_get(poids,i);
		/*valx=gsl_vector_get(phase,i);*/
		valmm=valp*valm;
		/*valxx=valp*valx;*/
		/*les poids des phases valent 1*/
		/* Somme des mag*/
		gsl_matrix_set(ValMat,x_pos,0,gsl_matrix_get(ValMat,x_pos,0)+valmm);
        /* Somme des mag^2*/
		gsl_matrix_set(ValMat,x_pos,1,gsl_matrix_get(ValMat,x_pos,1)+valmm*valm);
        /* Somme des phase*/
        /*gsl_matrix_set(ValMat,x_pos,2,gsl_matrix_get(ValMat,x_pos,2)+valxx);*/
		/* Somme des phase^2*/
		/*gsl_matrix_set(ValMat,x_pos,3,gsl_matrix_get(ValMat,x_pos,3)+valx*valxx);*/
		/* Somme des phase*mag*/
		/*gsl_matrix_set(ValMat,x_pos,4,gsl_matrix_get(ValMat,x_pos,4)+valmm*valxx);*/
		/* Somme des poids (mags)*/
		/*gsl_matrix_set(ValMat,x_pos,5,gsl_matrix_get(ValMat,x_pos,5)+valp);*/
		gsl_matrix_set(ValMat,x_pos,2,gsl_matrix_get(ValMat,x_pos,2)+valp);
		/* Somme des poids^2 (mags)*/
		/*gsl_matrix_set(ValMat,x_pos,6,gsl_matrix_get(ValMat,x_pos,6)+valp*valp);*/
	}
	*PDM=0;
	/*on sait que nos poids sont normalises à 1*/
	for (i=0;i<ncol;i++) {
		/*somlig=0.;
		for (j=0;j<nlig;j++) {
			somlig+=gsl_matrix_get(EntMat,j,i);
		}*/
		/*mag_variance=gsl_matrix_get(ValMat,i,1)-gsl_matrix_get(ValMat,i,0)*gsl_matrix_get(ValMat,i,0)/gsl_matrix_get(ValMat,i,5);*/
		mag_variance=gsl_matrix_get(ValMat,i,1)-gsl_matrix_get(ValMat,i,0)*gsl_matrix_get(ValMat,i,0)/(gsl_matrix_get(ValMat,i,2)+eps);
		/*phase_variance=gsl_matrix_get(ValMat,i,3)-gsl_matrix_get(ValMat,i,2)*gsl_matrix_get(ValMat,i,2)/gsl_matrix_get(ValMat,i,5);
		covar = (gsl_matrix_get(ValMat,x_pos,6)*gsl_matrix_get(ValMat,i,4))/gsl_matrix_get(ValMat,x_pos,6)-gsl_matrix_get(ValMat,i,0)*gsl_matrix_get(ValMat,i,2)/(gsl_matrix_get(ValMat,x_pos,5)*gsl_matrix_get(ValMat,x_pos,5));*/
        *PDM+=mag_variance;
		/*-covar*covar/(phase_variance+eps); pour le moment*/
	}
	/*Normalisation*/
	gsl_matrix_scale(EntMat,1./nmes);
	*Entropie=0;
	for (i=0;i<ncol;i++) {
		for (j=0;j<nlig;j++) {
			valx      =gsl_matrix_get(EntMat,j,i);
			*Entropie+=-valx*log(valx+eps);
		}
    }
	/*Normalisation*/
	*Entropie=*Entropie/(log(nlig*ncol));
	gsl_matrix_free(EntMat);
	gsl_matrix_free(ValMat);
	return 0;
}

/***************************************************************************/
int Cmd_ydtcl_classification(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction classification (with periodogram)                             */
/***************************************************************************/
/* Inputs : 1) The periods vector
			2) N (vector,weight): each vector represents a statistic
			3) The number of final periods
   Outputs: Final periods
*/
/***************************************************************************/
{
    char s[200];
    int code,code1,code2,code3,code4;
    int i,j,k=0,nper=0;
	double w_period,w_minlong,w_periodog,w_PDM,w_Entropie,somme_w;
	Tcl_DString dsptr;
    gsl_permutation *perm1,*rank1;
    gsl_permutation *perm2,*rank2;
	gsl_permutation *perm3,*rank3;
	gsl_permutation *perm4,*rank4;
	gsl_permutation *perm5,*rank5;
    gsl_permutation *perm6;
	gsl_vector *periods,*period_temp,*minlong,*periodog,*PDM,*Entropie,*best_periods, *perm;
	if(argc!=12) {
		sprintf(s,"Usage: %s Incorrect number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
      /* --- decodage des arguments ---*/
        code = gsltcltcl_getgslvector(interp,argv[1],&periods,&k);
		code1=gsltcltcl_getgslvector(interp,argv[2],&minlong,&k);
        code2=gsltcltcl_getgslvector(interp,argv[3],&periodog,&k);
	    code3=gsltcltcl_getgslvector(interp,argv[4],&PDM,&k);
		code4=gsltcltcl_getgslvector(interp,argv[5],&Entropie,&k);
		w_period=atof(argv[6]);
		w_minlong=atof(argv[7]);
		w_periodog=atof(argv[8]);
		w_PDM=atof(argv[9]);
		w_Entropie=atof(argv[10]);
        nper = atoi(argv[11]);
		/* --- inits ---*/
		somme_w=w_period+w_minlong+w_periodog+w_PDM+w_Entropie;
		perm1=gsl_permutation_alloc(k);
		perm2=gsl_permutation_alloc(k);
		perm3=gsl_permutation_alloc(k);
		perm4=gsl_permutation_alloc(k);
		perm5=gsl_permutation_alloc(k);
		rank1=gsl_permutation_alloc(k);
		rank2=gsl_permutation_alloc(k);
		rank3=gsl_permutation_alloc(k);
		rank4=gsl_permutation_alloc(k);
		rank5=gsl_permutation_alloc(k);
		perm6=gsl_permutation_alloc(k);
        period_temp=gsl_vector_calloc(k);

		if (w_period!=0) {
			gsl_vector_memcpy(period_temp,periods);
			gsl_vector_scale(period_temp,-1);
			gsl_sort_vector_index(perm1,period_temp);
			gsl_permutation_inverse (rank1,perm1);
		}
		if (w_minlong!=0) {
			gsl_sort_vector_index(perm2,minlong);
			gsl_permutation_inverse (rank2,perm2);
		}
		if (w_periodog!=0) {
			gsl_vector_scale(periodog,-1);
			gsl_sort_vector_index(perm3,periodog);
			gsl_permutation_inverse (rank3,perm3);
		}
		if (w_PDM!=0) {
            gsl_sort_vector_index(perm4,PDM);
		gsl_permutation_inverse (rank4,perm4);
		}
        if (w_Entropie!=0) {
			gsl_sort_vector_index(perm5,Entropie);
			gsl_permutation_inverse (rank5,perm5);
		}

		perm=gsl_vector_alloc(k);
		for (i=0;i<k;i++) {
			perm->data[i]=w_period*rank1->data[i]+w_minlong*rank2->data[i]+w_periodog*rank3->data[i]+w_PDM*rank4->data[i]+w_Entropie*rank5->data[i];
			perm->data[i]=perm->data[i]/somme_w;
		}
		gsl_sort_vector_index(perm6,perm);
		best_periods = gsl_vector_calloc(nper);
		if (k<nper) {nper=k;}
		for (i=0;i<nper;i++){
			j=perm6->data[i];
			best_periods->data[i]=periods->data[j];
        }
        /* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        gsltcltcl_setgslvector(interp,&dsptr,best_periods,nper);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(periods);
        gsl_vector_free(minlong);
		gsl_vector_free(periodog);
        gsl_vector_free(PDM);
        gsl_vector_free(Entropie);
		gsl_permutation_free(perm1);
        gsl_permutation_free(perm2);
		gsl_permutation_free(perm3);
		gsl_permutation_free(perm4);
		gsl_permutation_free(perm5);
		gsl_permutation_free(perm6);
		gsl_permutation_free(rank1);
        gsl_permutation_free(rank2);
		gsl_permutation_free(rank3);
		gsl_permutation_free(rank4);
		gsl_permutation_free(rank5);
		gsl_vector_free(period_temp);
		gsl_vector_free(best_periods);
		gsl_vector_free(perm);

	}
	return TCL_OK;
}
/****************************************************************************/
int Cmd_ydtcl_ajustement(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction ajustement                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) jdphase0 (jd0 to compute phases)
			3) The mags vector
			4) The mags weigth vector
			5) The best periods vector
			6) The number of harmonics in Fourier series
   Outputs: 1) The best periods vector sorted following the chi2 test
			2) The final number of harmonics (only for the best period)
			3) The Fourier coefficients vector (only for the best period)
*/
/***************************************************************************/
{
    char s[200];
    int code,code1,code2,code3;
    int nper=0,nhar=0,nmes=0;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*poids,*best_periods,*coefs,*phases;
	double residu,residu_min0,residu_min00,i_best0,nhar_best0;
    gsl_vector *residu_min,*i_bests, *nhar_bests;
    double res;
    double deltaphasemax,jdphase0;
    int nhar0,i,j,ii,i_bestbest,nhar_bestbest;

	if(argc!=7) {
        sprintf(s,"Usage: %s Incorrect number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
   } else {
        /* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		jdphase0=atof(argv[2]);
		code1=gsltcltcl_getgslvector(interp,argv[3],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[4],&poids,&nmes);
        code3=gsltcltcl_getgslvector(interp,argv[5],&best_periods,&nper);
		nhar =atoi(argv[6]);
		/* --- inits ---*/
   	    residu_min00=1e+90;
		phases=gsl_vector_calloc(nmes);
		residu_min=gsl_vector_calloc(nper);
		i_bests=gsl_vector_calloc(nper);
		nhar_bests=gsl_vector_calloc(nper);
		for (i=0;i<nper;i++) {
			/* --- determine n_har0, le nombre d'harmoniques maximum à prendre ---*/
			for (j=0;j<nmes;j++) {
				res=(jds->data[j]-jdphase0)/best_periods->data[i];
				phases->data[j]=res-floor(res);
			}
			gsl_sort_vector(phases);
			deltaphasemax=0.;
			for (j=0;j<nmes-1;j++) {
				res=phases->data[j+1]-phases->data[j];
				if (res>deltaphasemax) {
					deltaphasemax=res;
				}
			}
			res=phases->data[0]+1.-phases->data[nmes-1];
			if (res>deltaphasemax) {
				deltaphasemax=res;
			}
			nhar0=(int)(1./deltaphasemax/2.);
			if (nhar0>nhar) {
				nhar0=nhar;
			}
			if (nhar0<1) {
				nhar0=1;
			}
/*debug
nhar0=3;
fin*/
			coefs=gsl_vector_calloc(1+2*nhar0);
			yd_moin_carr(jds,jdphase0,mags,poids,best_periods->data[i],nhar0,nmes,coefs,&residu);
			gsl_vector_free(coefs);
			residu_min->data[i]=residu;
			i_bests->data[i]=i;
			nhar_bests->data[i]=nhar0;
		}
		/* --- tri les residus ---*/
		for (i=0;i<nper-1;i++) {
			for (ii=i;ii<nper;ii++) {
				if (residu_min->data[ii]<residu_min->data[i]) {
					residu_min0=residu_min->data[ii];
					residu_min->data[ii]=residu_min->data[i];
					residu_min->data[i]=residu_min0;
					i_best0=i_bests->data[ii];
					i_bests->data[ii]=i_bests->data[i];
					i_bests->data[i]=i_best0;
					nhar_best0=nhar_bests->data[ii];
					nhar_bests->data[ii]=nhar_bests->data[i];
					nhar_bests->data[i]=nhar_best0;
				}
			}
		}
		i_bestbest=(int)i_bests->data[0];
		nhar_bestbest=(int)nhar_bests->data[0];

		/* --- calcule les coefs pour la meilleure periode ---*/
		coefs=gsl_vector_calloc(1+2*nhar_bestbest);
		yd_moin_carr(jds,jdphase0,mags,poids,best_periods->data[i_bestbest],nhar_bestbest,nmes,coefs,&residu);
   		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr," {",-1);
		for (i=0;i<nper;i++) {
			ii=(int)i_bests->data[i];
			sprintf(s,"%.11f ",best_periods->data[ii]);
			Tcl_DStringAppend(&dsptr,s,-1);
		}
		Tcl_DStringAppend(&dsptr,"} ",-1);
		Tcl_DStringAppend(&dsptr," ",-1);
		sprintf(s,"%d",nhar_bestbest);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr," {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,coefs,1+2*nhar_bestbest);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(poids);
		gsl_vector_free(best_periods);
        gsl_vector_free(phases);
		gsl_vector_free(residu_min);
		gsl_vector_free(i_bests);
		gsl_vector_free(coefs);
		gsl_vector_free(nhar_bests);
	}
	return TCL_OK;
}
/************************************************************************************/
int yd_moin_carr(gsl_vector *jds, double jdphase0, gsl_vector *mags,gsl_vector *poids, double per , int n_arm,int nmes, gsl_vector *coefs, double *residu)
/***************************************************************************/
/* Fonction moin_carr                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
            2) jdphase0 (jd0 to compute phases)
			3) The weigth vector
			5) The period
			6) The number of harmonics
			7) The jds length
   Outputs: The chi2 value
*/
/***************************************************************************/
{

    int i,j;
	double pi,w;
	gsl_matrix *A,*W,*Ap,*ApW,*ApWA,*ApWA_inv;
	gsl_vector *Y,*Y_aju;
	gsl_permutation *p;
	int signum;

	/* --- inits ---*/
	/* n_x = nb de points de mesure */
	/* 1+2*n_arm = nb de coefs a determiner */
	Y  =gsl_vector_calloc(nmes);
	Y_aju  =gsl_vector_calloc(nmes);
	A  =gsl_matrix_calloc(nmes,1+2*n_arm);
	Ap =gsl_matrix_calloc(1+2*n_arm,nmes);
	ApW=gsl_matrix_calloc(1+2*n_arm,nmes);
	ApWA=gsl_matrix_calloc(1+2*n_arm,1+2*n_arm);
	ApWA_inv=gsl_matrix_calloc(1+2*n_arm,1+2*n_arm);
	p=gsl_permutation_alloc(1+2*n_arm);
	pi=4*atan(1);
	for (i=1;i<n_arm+1;i++) {
		for (j=0;j<nmes;j++){
			gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*(jds->data[j]-jdphase0)/per));
			gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*(jds->data[j]-jdphase0)/per));
		}
	}
    for (j=0;j<nmes;j++) {
		gsl_matrix_set(A,j,2*n_arm,1.);
	}
    W=gsl_matrix_calloc(nmes,nmes);
	for (j=0;j<nmes;j++) {
		w=poids->data[j];
		/*w=1/(w*w);*/
		gsl_matrix_set(W,j,j,w);
	}
	/* inv(A'*W*A)*A'*W*Y(mag) */
    gsl_matrix_transpose_memcpy(Ap,A);
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,Ap,W,0.0,ApW);
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,ApW,A,0.0,ApWA);
	gsl_linalg_LU_decomp(ApWA,p,&signum);
	gsl_linalg_LU_invert(ApWA,p,ApWA_inv);
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,ApWA_inv,ApW,0.0,Ap);
	gsl_vector_memcpy(Y,mags);
	gsl_blas_dgemv(CblasNoTrans,1.0,Ap,Y,0.0,coefs);
	/**/
	gsl_blas_dgemv(CblasNoTrans,1.0,A,coefs,0.0,Y_aju);
	gsl_vector_sub(Y,Y_aju);
	/**/
	*residu=0;
	for (j=0;j<nmes;j++) {
		*residu+=(Y->data[j]*Y->data[j]*W->data[j*nmes+j]);
	}
	/**/
	gsl_vector_free(Y);
	gsl_vector_free(Y_aju);
	gsl_matrix_free(A);
	gsl_matrix_free(Ap);
	gsl_matrix_free(ApW);
	gsl_matrix_free(ApWA);
	gsl_matrix_free(ApWA_inv);
	gsl_matrix_free(W);
    gsl_permutation_free(p);
	return 0;
}

/************************************************************************************/
int Cmd_ydtcl_cour_final(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction cour_final                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) jdphase0 (jd0 to compute phases)
            3) The mags vector
			4) The error bars vector
			5) The period
			6) The Fourier series coefficients
			7) The sigma of mags
   Outputs: 1) The mags synthetic vector
			2) The sigma of mags
			3) 0 if k_good*k_bad!=0 - +1 if k_good==0 - -1 if k_bad==0
			4) Index of jdgoods (point lyning on the curve)
			5) Index of jdbads (point don't lyning on the curve)
*/
/***************************************************************************/
{   char s[200];
    int code,code1,code2,code3;
    int i,j,nmes=0,n_arm,k=0,temoin=0;
	Tcl_DString dsptr;
    gsl_vector *coefs;
	double period,pi,stdmodel,deltamag,deltamag2,val1,val2,sigma,sigma2,jdphase0;
	gsl_matrix *A;
	gsl_vector *jds,*mags,*bars,*magpobss,*ind_jdgoods,*ind_jdbads;
	int k_good,k_bad;

	if(argc!=8) {
        sprintf(s,"Usage: %s Invalid number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
        jdphase0=atof(argv[2]);
		code1=gsltcltcl_getgslvector(interp,argv[3],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[4],&bars,&nmes);
	    period =atof(argv[5]);
		code3=gsltcltcl_getgslvector(interp,argv[6],&coefs,&k);
		sigma =atof(argv[7]);
		n_arm=(k-1)/2;
		/*-----init---------*/

	    /* 1+2*n_arm = nb de coefs a determiner */
	    magpobss    =gsl_vector_calloc(nmes);
	    ind_jdgoods =gsl_vector_calloc(nmes);
		ind_jdbads  =gsl_vector_calloc(nmes);

        A=gsl_matrix_calloc(nmes,k);
	    pi=4*atan(1);
	    for (i=1;i<n_arm+1;i++) {
		    for (j=0;j<nmes;j++){
				gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*(jds->data[j]-jds->data[0])/period));
			    gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*(jds->data[j]-jds->data[0])/period));
			}
		}
        for (j=0;j<nmes;j++) {
		    gsl_matrix_set(A,j,2*n_arm,1.);
		}

	    /* AA*coefs */
   	    gsl_blas_dgemv(CblasNoTrans,1.0,A,coefs,0.0,magpobss);
	    /*Calcul de l'esart type de magpobss*/
	    val1=0;
	    val2=0;
	    for (j=0;j<nmes;j++) {
		    val1+=magpobss->data[j];
		    val2+=magpobss->data[j]*magpobss->data[j];
	    }
	    stdmodel=(val2-val1*val1/nmes)/(nmes-1);
	    /*Cherchons maintenant les ind_jdgoods et ind_jdbads*/
		sigma2=sigma/2;
	    k_good=0;
	    k_bad=0;
	    for (j=0;j<nmes;j++) {
		    deltamag=fabs(mags->data[j]-magpobss->data[j])-bars->data[j];
			deltamag2=fabs(mags->data[j]-magpobss->data[j])-sigma2;
		    if ((deltamag>0)&&(deltamag2>0)) {
			    ind_jdbads->data[k_bad]=j;
			    k_bad++;
		    } else {
			    ind_jdgoods->data[k_good]=j;
			    k_good++;
		    }
	    }
		if (k_good==0) {temoin=1;}
		if (k_bad==0) {temoin=-1;}

	    /* Sortie du résultat*/
	    Tcl_DStringInit(&dsptr);
        Tcl_DStringAppend(&dsptr,"{",-1);
        gsltcltcl_setgslvector(interp,&dsptr,magpobss,nmes);
		Tcl_DStringAppend(&dsptr,"} {",-1);
	    sprintf(s,"%f",stdmodel);
	    Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%d",temoin);
		Tcl_DStringAppend(&dsptr,s,-1);
	    if (k_good>0) {
			Tcl_DStringAppend(&dsptr,"} {",-1);
            gsltcltcl_setgslvector(interp,&dsptr,ind_jdgoods,k_good);
	    }
        if (k_bad>0) {
			Tcl_DStringAppend(&dsptr,"} {",-1);
	        gsltcltcl_setgslvector(interp,&dsptr,ind_jdbads,k_bad);
		}
	    Tcl_DStringAppend(&dsptr,"}",-1);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
        /* --- liberation de la memoire ---*/
   	    gsl_vector_free(jds);
	    gsl_vector_free(mags);
	    gsl_vector_free(bars);
		gsl_vector_free(coefs);
        gsl_vector_free(magpobss);
	    gsl_vector_free(ind_jdbads);
	    gsl_vector_free(ind_jdgoods);
		gsl_matrix_free(A);
	}
	return TCL_OK;
}
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/
/*  UTILS                                                                   */
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/

int gsltcltcl_getvector(Tcl_Interp *interp, char *list, double **vec, int *n)
/****************************************************************************/
/* retourne un pointeur (double*) sur le vecteur defini par la liste Tcl.   */
/* retourne n, le nombre d'elements.                                        */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argv=NULL;
   int argc,code;
   int nn,k;
   double *v=NULL;

   *n=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
	  v=(double*)calloc(1,sizeof(double));
	  return TCL_OK;
   }
   nn=argc;
	v=(double*)calloc(nn,sizeof(double));
   for (k=0;k<nn;k++) {
      v[k]=(double)atof(argv[k]);
   }
   Tcl_Free((char *) argv);
   *n=nn;
   *vec=v;
   return TCL_OK;
}

int gsltcltcl_setvector(Tcl_Interp *interp, Tcl_DString *dsptr, double *vec, int n)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur (double*)                    */
/* n est le nombre d'elements.                                              */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int k;
   char s[200];
   for (k=0;k<n;k++) {
      sprintf(s,"%f",vec[k]);
      Tcl_DStringAppendElement(dsptr,s);
   }
   return TCL_OK;
}

int gsltcltcl_getmatrix(Tcl_Interp *interp, char *list, double **mat, int *nl, int *nc)
/****************************************************************************/
/* retourne un pointeur (double*) sur la matrice definie par la liste Tcl.  */
/* retourne nl et nc, respectivement le nombre de lignes et de colonnes.    */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argvv=NULL,**argv=NULL,s[200];
   int argcc,argc,code;
   int nlig,ncol=0,ncol1=0,klig,kcol;
   double *m=NULL;

   argvv=NULL;
   *nl=0;
   *nc=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
     gsltcl_mcalloc(&m,1,1);
	  return TCL_OK;
   }
   nlig=argc;
   for (klig=0;klig<nlig;klig++) {
      argvv=NULL;
      code=Tcl_SplitList(interp,argv[klig],&argcc,&argvv);
      if (argcc<=0) {
         if (m==NULL) {
		   gsltcl_mcalloc(&m,1,1);
		 }
	     return TCL_OK;
      }
      ncol=argcc;
      if (klig>0) {
         if (ncol!=ncol1) {
            sprintf(s,"%d elements instead of %d in line %d",ncol,ncol1,klig);
            Tcl_Free((char *) argv);
            Tcl_Free((char *) argvv);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      } else {
         ncol1=ncol;
		   gsltcl_mcalloc(&m,nlig,ncol);
      }
      for (kcol=0;kcol<ncol;kcol++) {
         m[ncol*klig+kcol]=(double)atof(argvv[kcol]);
      }
      Tcl_Free((char *) argvv);
   }
   Tcl_Free((char *) argv);
   *nl=nlig;
   *nc=ncol;
   *mat=m;
   return TCL_OK;
}


int gsltcltcl_setmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, double *mat, int nl, int nc)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur sur la matrice               */
/* nl est le nombre de lignes.                                              */
/* nc est le nombre de colonnes.                                            */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int kl,kc;
   char s[200];
   Tcl_DStringInit(dsptr);
   for (kl=0;kl<nl;kl++) {
      /*Tcl_DStringStartSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," { ",3);
      for (kc=0;kc<nc;kc++) {
         sprintf(s,"%f",mat[nc*kl+kc]);
         Tcl_DStringAppendElement(dsptr,s);
      }
      /*Tcl_DStringEndSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," } ",3);
   }
   return TCL_OK;
}

int gsltcltcl_getgslmatrix(Tcl_Interp *interp, char *list, gsl_matrix **gslmat, int *nl, int *nc)
/****************************************************************************/
/* retourne un pointeur (gsl_matrix *) sur la matrice definie par la liste Tcl.  */
/* retourne nl et nc, respectivement le nombre de lignes et de colonnes.    */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argvv=NULL,**argv=NULL,s[200];
   int argcc,argc,code;
   int nlig,ncol=0,ncol1=0,klig,kcol;
   gsl_matrix *m=NULL;

   argvv=NULL;
   *nl=0;
   *nc=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
	  return TCL_ERROR;
   }
   nlig=argc;
   for (klig=0;klig<nlig;klig++) {
      argvv=NULL;
      code=Tcl_SplitList(interp,argv[klig],&argcc,&argvv);
      if (argcc<=0) {
	     return TCL_ERROR;
      }
      ncol=argcc;
      if (klig>0) {
         if (ncol!=ncol1) {
            sprintf(s,"%d elements instead of %d in line %d",ncol,ncol1,klig);
            Tcl_Free((char *) argv);
            Tcl_Free((char *) argvv);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      } else {
         ncol1=ncol;
         m=gsl_matrix_calloc(nlig,ncol);
      }
      for (kcol=0;kcol<ncol;kcol++) {
         /*m[ncol*klig+kcol]=(double)atof(argvv[kcol]);*/
         gsl_matrix_set(m,klig,kcol,(double)atof(argvv[kcol]));
      }
      Tcl_Free((char *) argvv);
   }
   Tcl_Free((char *) argv);
   *nl=nlig;
   *nc=ncol;
   *gslmat=m;
   return TCL_OK;
}

int gsltcltcl_setgslmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_matrix *gslmat, int nl, int nc)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur sur gsl_matrix               */
/* nl est le nombre de lignes.                                              */
/* nc est le nombre de colonnes.                                            */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int kl,kc;
   char s[200];
   for (kl=0;kl<nl;kl++) {
      /* Tcl_DStringStartSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," { ",3);
      for (kc=0;kc<nc;kc++) {
         sprintf(s,"%f",gsl_matrix_get(gslmat,kl,kc));
         Tcl_DStringAppendElement(dsptr,s);
      }
      /*Tcl_DStringEndSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," } ",3);
   }
   return TCL_OK;
}

int gsltcltcl_getgslvector(Tcl_Interp *interp, char *list, gsl_vector **gslvec, int *n)
/****************************************************************************/
/* retourne un pointeur (gsl_vector *) sur la matrice definie par la liste Tcl.  */
/* retourne n le nombre d'elements.                                         */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argv=NULL;
   int argc,code;
   int nn,k;
   gsl_vector *v=NULL;

   *n=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
	  return TCL_ERROR;
   }
   nn=argc;
   v=gsl_vector_calloc(nn);
   for (k=0;k<nn;k++) {
      gsl_vector_set(v,k,(double)atof(argv[k]));
   }
   Tcl_Free((char *) argv);
   *n=nn;
   *gslvec=v;
   return TCL_OK;
}


int gsltcltcl_setgslvector(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_vector *vec, int n)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur sur gsl_vectror              */
/* n est le nombre d'elements.                                              */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int k;
   char s[200];
   for (k=0;k<n;k++) {
      sprintf(s,"%f",gsl_vector_get(vec,k));
      Tcl_DStringAppendElement(dsptr,s);
   }
   return TCL_OK;
}

int gsltcl_mcalloc(double **mat,int nlig,int ncol)
/***************************************************************************/
/* Allocation memoire pour une matrice                                     */
/***************************************************************************/
/***************************************************************************/
{
   double *m=NULL;
   if (*mat==NULL) {
	  if (nlig*ncol==0) {
		  return 2;
	  }
      m=(double*)calloc(nlig*ncol,sizeof(double));
	  if (m==NULL) {
	     return 1;
	  }
   }
   *mat=m;
   return 0;
}

int gsltcl_mfree(double **mat)
/***************************************************************************/
/* Liberation memoire pour une matrice                                     */
/***************************************************************************/
/***************************************************************************/
{
   if (*mat==NULL) {
	   free(*mat);
   }
   return 0;
}


/************************************************************************************/
int yd_perchoice(gsl_vector *jds, int nmes, int *temoin, int *indice_prem_date, int *indice_dern_date)
/***************************************************************************/
/* Fonction perchoice                                                       */
/***************************************************************************/
/* Fonction with the aim to choose trial periods following the criterion ni*delta_Pi=accu*Pi<<Pi,
/* and eliminate aliasing periods
/* Inputs : 1) The jds vector
			2) The length of the jds vector
            2) Aliasing periods histogram
			3) The histogram limit value
			4) The smallest authorized trial period
			5) The highest authorized trial period
   Outputs: 1) Temoin = 0 if data length is shorter than 1 year or there isn't enough data in 1 year
                      = 1 else
			2) The index of the first day of the choosen year (in jds vector)
			3) The index of the last day of the choosen year (in jds vector)
*/
/***************************************************************************/
{
    double delta_t,interval=180.;
	int imes,temoin2;
	int	compteur_date,compteur_date_temp,indice_prem_date_temp,indice_prem_date2,indice_dern_date2;

	compteur_date=0;
    compteur_date_temp=0;
	indice_prem_date2=0;
	indice_dern_date2=0;
	indice_prem_date_temp=0;
    imes=1;
	temoin2=0;

	while (imes<nmes) {
		delta_t=jds->data[imes]-jds->data[indice_prem_date_temp];
		if (delta_t>interval) {
			temoin2=1;
			compteur_date_temp=imes-indice_prem_date_temp;
			/* le +1-1 s'annulent dans compteur_date_temp*/
			if (compteur_date_temp>compteur_date) {
				compteur_date=compteur_date_temp;
				indice_dern_date2=imes-1;
				indice_prem_date2=indice_prem_date_temp;
				indice_prem_date_temp=imes;
				compteur_date_temp=0;
			}
		}
		imes++;
		compteur_date_temp++;
	}
	/*il se peut que dans la derniere annee on a plus d'observavation sans pour autant
	qu'elle soit superieure a 6 mois*/
	compteur_date_temp=imes-indice_prem_date_temp+1;
	if (compteur_date_temp>compteur_date) {
 		compteur_date=compteur_date_temp;
		indice_dern_date2=imes-1;
		indice_prem_date2=indice_prem_date_temp;
	}
	if (temoin2==0) {
		indice_dern_date2=nmes-1;
	}
	/*Si j'ai moins de 10 mesures par an, je prends toutes les mesures*/
	if (compteur_date<11) {
		indice_dern_date2=nmes-1;
		indice_prem_date2=0;
		temoin2=0;
	}
	/*Je sais que cest un peu bête mais j'ai encore (beaucoup) des doutes sur les pointeurs*/
	*indice_prem_date=indice_prem_date2;
	*indice_dern_date=indice_dern_date2;
	*temoin=temoin2;
	return 0;
}
/************************************************************************************/
int Cmd_ydtcl_meansigma(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction meansigma                                                       */
/***************************************************************************/
/* Inputs : A vector
   Outputs: Its mean and sigma
*/
/***************************************************************************/
{
	char **argvv1=NULL,**argvv2=NULL,s[200];
    int argcc1,argcc2;
    int code1,code2,i,n=0;
	double mean=0,sigma=0;
	double *vec=NULL,*err=NULL;
	Tcl_DString dsptr;
	if((argc<2)||(argc>3)) {
        sprintf(s,"Usage: %s Input must be a vector (and its errors) ", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
		code1=Tcl_SplitList(interp,argv[1],&argcc1,&argvv1);
		if (argcc1<=0) {
			Tcl_SetResult(interp,"Le vecteur est nul",TCL_VOLATILE);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			return TCL_ERROR;
        }
		vec=(double*)malloc(argcc1*sizeof(double));
		if (vec==NULL) {
			sprintf(s,"error : vec pointer out of memory (%d elements)",argcc1);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		err=(double*)malloc(argcc1*sizeof(double));
		if (err==NULL) {
			sprintf(s,"error : err pointer out of memory (%d elements)",argcc1);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		if (argc==2) {
			for (i=0;i<argcc1;i++) {
				vec[i]=(double)atof(argvv1[i]);
				err[i]=1.;
			}
			yd_util_meansigma_poids(vec,err,0,argcc1,0,&mean,&sigma);
		} else {
            code2=Tcl_SplitList(interp,argv[2],&argcc2,&argvv2);
			if (argcc1!=argcc2) {
				Tcl_SetResult(interp,"Les 2 vecteurs doivent avoir la meme dimension",TCL_VOLATILE);
				Tcl_Free((char *) argvv1);
				Tcl_Free((char *) argvv2);
				return TCL_ERROR;
			}

			for (i=0;i<argcc1;i++) {
				vec[i]=(double)atof(argvv1[i]);
				err[i]=(double)atof(argvv2[i]);
			}
			yd_util_meansigma_poids(vec,err,0,argcc1,1,&mean,&sigma);
		}
		Tcl_DStringInit(&dsptr);
        Tcl_DStringAppend(&dsptr,"{",-1);
	    sprintf(s,"%f",mean);
	    Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%f",sigma);
	    Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);

		free(vec);
		free(err);
		Tcl_Free((char *) argvv1);
		Tcl_Free((char *) argvv2);
	}
	return TCL_OK;
}
/***************************************************************************/
int Cmd_ydtcl_per_range(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction yd_per_range
   Inputs : 1) The jds vector
			2) The smallest real period
   Outputs: 1) The smallest authorized periog
			2) The highest authorized periog
*/
/***************************************************************************/
{
	char s[200];
    int code,nmes=0,i,temoin,nmes2;
	double per_range_minmin,per_range_max,per_range_min,pgcd;
	Tcl_DString dsptr;
    gsl_vector *jds;
	double *dt;
	if(argc!=3) {
		sprintf(s,"Usage: %s Invalid input : must be a vector", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		per_range_minmin=atof(argv[2]);
		nmes2=nmes-1;
		/*Je calcule les différences entre dates successives*/
		dt=(double*)calloc(nmes-1,sizeof(double));
		if (dt==NULL) {
			sprintf(s,"error : dt pointer out of memory (%d elements)",nmes2);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            gsl_vector_free(jds);
            return TCL_ERROR;
        }
		for (i=0;i<nmes2;i++) {
			dt[i]=jds->data[i+1]-jds->data[i];
		}
		/*on trie le vecteur dt et on cherche le pgcd de ses elements*/
		yd_util_qsort_double(dt,0,nmes2,NULL);
		yd_util_pgcd(dt,nmes2,per_range_minmin/2.,0.01,&pgcd,&temoin);
		if (temoin==1) {
			per_range_min=2.*pgcd;
		} else {
			per_range_min=per_range_minmin;
		}
		per_range_max=2*(jds->data[nmes-1]-jds->data[0]);

		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		sprintf(s,"%f",per_range_min);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%f",per_range_max);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		gsl_vector_free(jds);
		free(dt);
	}
    return TCL_OK;
}
/***************************************************************************/
int Cmd_ydtcl_moy_bars_comp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction yd_per_range
   Inputs : 1) The mags vector
			2) The error bars vector
			3) The mags mean
   Outputs: The ratio of bad points
*/
/***************************************************************************/
{
	char s[200];
    int code,code2,nmes=0,i,temoin=0,compteur;
	double moyenne,res;
	Tcl_DString dsptr;
    gsl_vector *bars,*mags;
	if(argc!=4) {
		sprintf(s,"Usage: %s Invalid input : must be 2 vector and a scalar", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[2],&bars,&nmes);
		moyenne=atof(argv[3]);
		compteur=0;
		for (i=0;i<nmes;i++) {
			res=mags->data[i]-moyenne;
			if (res<bars->data[i]) {
				compteur++;
			}
		}
		res=compteur/nmes;
		if (res>=0.8) {
			temoin=1;
		}
		Tcl_DStringInit(&dsptr);
	    sprintf(s,"%d",temoin);
	    Tcl_DStringAppend(&dsptr,s,-1);
	    Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
	    gsl_vector_free(mags);
	    gsl_vector_free(bars);
	}
    return TCL_OK;
}
/************************************************************************************************************************************************************/
int yd_dichotomie(double per, gsl_vector *badpers, gsl_vector *deltabadpers, int nbad, int *temoin2, int *k_bad)
/*************************************************************************************************************************************************************/
/* Fonction que j'utilise dans yd_nettoyage, elle me sert de retrouver les éléments d'un vecteur
   grace à l'algo de dichotomie utilisé par Alain dans yd_filehtm2refzmgmes
*/
{
	int k,k_per,k_per1,k_per2,sortie;
	double dper,badper,deltaper,badpersmax;

    *temoin2=0;
	badpersmax=badpers->data[nbad-1]+deltabadpers->data[nbad-1];
	/** badpersmax voir yd_aliasing*/
	if (per>badpersmax) {
		return 0;
	}

	k_per=0;
    k_per1=*k_bad;
    k_per2=nbad-1;
	sortie=0;
	while(sortie==0) {
        if ((k_per2-k_per1)<=1) { break; }
		k_per=(k_per1+k_per2+1)/2;
        badper=badpers->data[k_per];
        if (per<=badper) {
			k_per2=k_per;
        } else {
            k_per1=k_per;
        }
    }
    for (k=k_per;k>=0;k--) {
		badper=badpers->data[k];
		deltaper=deltabadpers->data[k];
		/*On determine le deltaper (largeur de l'histogramme)*/
        dper=per-badper;
        if (dper>deltaper) { break; }
		if (dper<-deltaper) { continue; }
        if (dper<deltaper) {
            *temoin2=1 ;
			*k_bad=k;
			return 0;
        }
    }
 	for (k=k_per+1;k<nbad;k++) {
		badper=badpers->data[k];
		deltaper=deltabadpers->data[k];
		/*On determine le deltaper (largeur de l'histogramme)*/
		dper=badper-per;
        if (dper>deltaper) { break; }
		if (dper<-deltaper) { continue; }
		if (dper<deltaper) {
			*temoin2=1 ;
			*k_bad=k;
			return 0;
		}
    }
	return 0;
}
/************************************************************************************************************************************************************/
int yd_util_pgcd(double *vecteur, int taille, double limit,double tolerance,double *pgcd, int *temoin)
/*************************************************************************************************************************************************************/
/*Fonction pour calculer le PGCD
Inputs : 1) vecteur
		 2) Sa taille
		 3) La limite inferieure du pgcd
		 4) La tolerance
Outputs: 1) le PGCD (s'il existe)
		 2) 1 si PGCD existe, 0 sinon*/
{
	int i,j,sortie,temoin2;
	double delta,res,eps,eps2;
	/*Init*/
	eps=tolerance;
	eps2=1.-tolerance;
	/**/
	i=1;
	sortie=0;
	temoin2=0;
	delta=vecteur[0]/i;
	*pgcd=delta;
	*temoin=0;
	while (sortie==0) {
		delta=vecteur[0]/i;
		if (delta<limit) {break;}
		for (j=0;j<taille;j++) {
			res=vecteur[j]/delta;
			res=res-(int)floor(res);
			if((res<eps)||(res>eps2)) {
				temoin2=1;
			} else {
				temoin2=0;
				break;
			}
		}
		if (temoin2>0) {
			*temoin=1;
			*pgcd=delta;
			break;
		}
		i++;
	}
	return 0;
}
int Cmd_ydtcl_shortorlong(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction shortorlong  : determine si on doit chercher une longue iu une courte periode                                                                                     */
/*********************************************************************************************************/
/* Inputs: 1) The jd vector
           2) The mag vector
		   3) The mag weitghs
		   4) The mag amplitude
		   5) The mag sigma
		   6) The highest authorized period  per_range_max
		   7) The number of kept periods
/***************************************************************************/
{
	char s[200];
    int code,code2,code3;
    int nmes;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*poids,*PERIODS,*PDM,*ENTROPIE,*PERIODS2,*PDM2,*ENTROPIE2,*phase,*temp,*dtemp;
	double amplitude,sigma,freq;
	double pdmmin,pdm,entropie,pdmalias,pdmlong;
	double per_range_max,limit,pi,pasfreq,pasfreq2,maxim;
	int temoin,nper,k_x,k_per,nper2,kk;
    /*FILE *f;*/
    if(argc!=8) {
		sprintf(s,"Usage: %s jds mags poids amplitude sigma per_range_max", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&nmes);
		code3=gsltcltcl_getgslvector(interp,argv[3],&poids,&nmes);
		amplitude=atof(argv[4]);
		sigma=atof(argv[5]);
		per_range_max=atof(argv[6]);
		nper=atoi(argv[7]);

		/* --- inits ---*/
		limit=0.4;
		pi=atan(1)*4;
		/*on calcule le pas de frequence*/
        pasfreq=2*sqrt(6./nmes)*sigma/(pi*per_range_max*amplitude);
		pasfreq2=(1e-4>pasfreq)?1e-4:pasfreq;
		if (per_range_max<20) {
			/*Nous chercherons une courte periode*/
			temoin=0;
			Tcl_DStringInit(&dsptr);
			Tcl_DStringAppend(&dsptr,"{",-1);
			sprintf(s,"%1d",temoin);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			sprintf(s,"%6.5e",pasfreq);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr,"}",-1);
			Tcl_DStringResult(interp,&dsptr);
			Tcl_DStringFree(&dsptr);
			return TCL_OK;
		}
		gsl_vector_add_constant(jds,-jds->data[0]);
		temp=gsl_vector_calloc(nmes);
		dtemp=gsl_vector_calloc(nmes);
		phase=gsl_vector_calloc(nmes);
		/*Je cherche le PDM minimum pour P proche de 0.5j : on testera au maximum 1000 frequences*/
		freq=1.95;
		pdmmin=1e30;
		gsl_vector_memcpy(temp,jds);
		gsl_vector_scale(temp,freq);
		gsl_vector_memcpy(dtemp,jds);
		gsl_vector_scale(dtemp,pasfreq2);
		while (freq<2.05) {
			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
			}
			yd_pdm_entropie(phase,mags,poids,nmes,&pdm,&entropie);
			if (pdmmin>pdm) {pdmmin=pdm;}
			freq+=pasfreq2;
			gsl_vector_add(temp,dtemp);
		}
		/*Je cherche le PDM minimum pour P proche de 1j : on testera au maximum 1000 frequences*/
		freq=0.95;
		gsl_vector_memcpy(temp,jds);
		gsl_vector_scale(temp,freq);
		gsl_vector_memcpy(dtemp,jds);
		gsl_vector_scale(dtemp,pasfreq2);
		while (freq<1.05) {
			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
			}
			yd_pdm_entropie(phase,mags,poids,nmes,&pdm,&entropie);
			if (pdmmin>pdm) {pdmmin=pdm;}
			freq+=pasfreq2;
			gsl_vector_add(temp,dtemp);
		}
		/*J'ai trouve donc la valeur du pic daliasing de 1j et de 0.5j
		Je le compare avec le plus petit pic pour les longues periodes*/
		pdmalias=pdmmin/(sigma*sigma);
		/*Je cherche le PDM minimum pour les longues peiodes (de 20j à per_max*/
		PERIODS=gsl_vector_calloc(nper);
		PDM=gsl_vector_calloc(nper);
		ENTROPIE=gsl_vector_calloc(nper);
		freq=1./per_range_max;
		pdmmin=1e30;
		k_per=0;
		gsl_vector_memcpy(temp,jds);
		gsl_vector_scale(temp,freq);
		gsl_vector_memcpy(dtemp,jds);
		gsl_vector_scale(dtemp,pasfreq);
		while (freq<0.05) {
			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
			}
			yd_pdm_entropie(phase,mags,poids,nmes,&pdm,&entropie);
			pdm=pdm/(sigma*sigma);
			if (k_per<nper) {
				PERIODS->data[k_per]=1./freq;
                PDM->data[k_per]=pdm;
				ENTROPIE->data[k_per]=entropie;
			} else {
				kk=gsl_vector_max_index(PDM);
				maxim=PDM->data[kk];
				if (pdm<maxim) {
					PERIODS->data[kk]=1./freq;
					PDM->data[kk]=pdm;
					ENTROPIE->data[kk]=entropie;
				}
			}
			k_per++;
			if (pdmmin>pdm) {pdmmin=pdm;}
			freq+=pasfreq;
			gsl_vector_add(temp,dtemp);
		}
		/*J'ai trouve donc la valeur du pic daliasing de 1j et de 0.5j
		Je le compare avec le plus petit pic pour les longues periodes*/
		pdmlong=pdmmin;
		nper2=nper;
		if (k_per<nper) {nper2=k_per;}
		PERIODS2=gsl_vector_calloc(nper2);
		PDM2=gsl_vector_calloc(nper2);
		ENTROPIE2=gsl_vector_calloc(nper2);
		if (k_per<nper) {
			for (k_per=0;k_per<nper2;k_per++) {
				PERIODS2->data[k_per]=PERIODS->data[k_per];
				PDM2->data[k_per]=PDM->data[k_per];
				ENTROPIE2->data[k_per]=ENTROPIE->data[k_per];
			}
		} else {
			gsl_vector_memcpy(PDM2,PDM);
			gsl_vector_memcpy(PERIODS2,PERIODS);
			gsl_vector_memcpy(ENTROPIE2,ENTROPIE);
		}
		gsl_vector_free(PDM);
		gsl_vector_free(PERIODS);
        gsl_vector_free(ENTROPIE);

		if ((pdmlong<limit)&&(pdmalias<limit)) {
			if (pdmlong<1.5*pdmalias){
				temoin=1;
			} else {
				temoin=0;
			}
		} else if (pdmlong<limit) {
			temoin=1;
		} else {
			temoin=0;
		}
		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		sprintf(s,"%1d",temoin);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%6.5e",pasfreq);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		if (temoin) {
			Tcl_DStringAppend(&dsptr," {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,PERIODS2,nper2);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,PDM2,nper2);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,ENTROPIE2,nper2);
			Tcl_DStringAppend(&dsptr,"}",-1);
		}
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);

		gsl_vector_free(mags);
		gsl_vector_free(jds);
		gsl_vector_free(poids);
		gsl_vector_free(temp);
		gsl_vector_free(dtemp);
		gsl_vector_free(phase);
        gsl_vector_free(PERIODS2);
		gsl_vector_free(PDM2);
		gsl_vector_free(ENTROPIE2);
    }
	return TCL_OK;
}
int Cmd_ydtcl_poids(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction meansigma                                                       */
/***************************************************************************/
/* Inputs : A vector
   Outputs: Its mean and sigma
*/
/***************************************************************************/
{
	char **argvv1=NULL,**argvv2=NULL,s[200];
    int argcc1,argcc2;
    int code1,code2,i;
	double somme_poids;
	double *bars=NULL;
	int *flags=NULL;
	Tcl_DString dsptr;
	if(argc=!3) {
        sprintf(s,"Usage: %s bars flags (and its errors) ", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
		code1=Tcl_SplitList(interp,argv[1],&argcc1,&argvv1);
		if (argcc1<=0) {
			Tcl_SetResult(interp,"Le vecteur est nul",TCL_VOLATILE);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			return TCL_ERROR;
        }
		bars=(double*)malloc(argcc1*sizeof(double));
		if (bars==NULL) {
			sprintf(s,"error : bars pointer out of memory (%d elements)",argcc1);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		code2=Tcl_SplitList(interp,argv[2],&argcc2,&argvv2);
		if (argcc2<=0) {
			Tcl_SetResult(interp,"Les 2 vecteurs doivent avoir la meme dimension",TCL_VOLATILE);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			return TCL_ERROR;
		}
		if (argcc1!=argcc2) {
			sprintf(s,"Usage: %s bars flags have not the same size ", argv[0]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		flags=(int*)malloc(argcc2*sizeof(int));
		if (flags==NULL) {
			sprintf(s,"error : flags pointer out of memory (%d elements)",argcc2);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		for (i=0;i<argcc1;i++) {
			bars[i]=(double)atof(argvv1[i]);
			flags[i]=(int)atoi(argvv2[i]);
		}
		for (i=0;i<argcc1;i++) {
			bars[i]=1./(0.0001+bars[i]*bars[i]);
			if((flags[i]>0)&&(flags[i]<4)) {
				bars[i]=bars[i]/4.;
			}
		}
		/*On calcule la somme des poids*/
		somme_poids=0;
		for (i=0;i<argcc1;i++) {
			somme_poids+=bars[i];
		}
		/*On normalise*/
		for (i=0;i<argcc1;i++) {
			bars[i]=bars[i]/somme_poids;
		}
		Tcl_DStringInit(&dsptr);
        /*Tcl_DStringAppend(&dsptr,"{",-1);*/
		for (i=0;i<argcc1;i++) {
			sprintf(s,"%12.10f ",bars[i]);
			Tcl_DStringAppend(&dsptr,s,-1);
		}
		/*Tcl_DStringAppend(&dsptr,"}",-1);*/
		Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);

		free(bars);
		free(flags);
		Tcl_Free((char *) argvv1);
		Tcl_Free((char *) argvv2);
	}
	return TCL_OK;
}
