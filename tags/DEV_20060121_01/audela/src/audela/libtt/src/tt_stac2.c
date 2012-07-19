/* tt_stac2.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

int tt_ima_stack_moy_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une moyenne                                       */
/***************************************************************************/
/***************************************************************************/
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
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_moy_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
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
      value=(nbima0==0)?pstack->nullpix_value:value/nbima0;
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

int tt_ima_stack_sig_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant un ecart type                                     */
/***************************************************************************/
/***************************************************************************/
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
   double i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_moy_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      i=0.;mu_i=0.;mu_ii=0.;sx_i=0.;sx_ii=0.;
      for (value=0,nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
    	       /* --- algo de la valeur moy et ecart type de Miller ---*/
	       if (nbima0==0) {mu_i=val;}
	       i=(double) (nbima0+1);
	       delta=val-mu_i;
	       mu_ii=mu_i+delta/(i);
	       sx_ii=sx_i+delta*(val-mu_ii);
	       mu_i=mu_ii;
	       sx_i=sx_ii;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
  	    /* --- algo de la valeur moy et ecart type de Miller ---*/
	    if (nbima0==0) {mu_i=val;}
	    i=(double) (nbima0+1);
	    delta=val-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(val-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
	    nbima0++;
	 }
      }
      value=0.;
      if (i!=0.) {
         value=sqrt(sx_ii/i);
      }
      value=(nbima0==0)?pstack->nullpix_value:value;
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

int tt_ima_stack_add_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une somme                                         */
/***************************************************************************/
/***************************************************************************/
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
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_add_1 (pointer index0)");
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

int tt_ima_stack_med_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une mediane                                       */
/***************************************************************************/
/***************************************************************************/
{
   int kk,kkk,kmedian;
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
   double *piletri,val;
   int *index,ni;
   int *index0,nbima0,k;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_med_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   nombre=nbima;
   taille=sizeof(double);
   piletri=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&piletri,&nombre,&taille,"piletri"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_med_1 (pointer piletri)");
      tt_free(index0,"index0");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(int);
   index=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index,&nombre,&taille,"index"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_med_1 (pointer index)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");
      return(TT_ERR_PB_MALLOC);
   }
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
	       piletri[nbima0]=val;
	       index[nbima0]=kk;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    piletri[nbima0]=val;
	    index[nbima0]=kk;
	    nbima0++;
	 }
      }
      if (nbima0==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(poids_pondere/(double)(nbima));
	 }
	 value=pstack->nullpix_value;
      } else {
	 kmedian=(int)(floor(50./100.*((double)nbima0+0.5)));
	 tt_util_qsort_double(piletri,0,nbima0,index);
	 for (ni=0,k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {ni++;}
	 }
	 if (ni==0) {ni=1;}
	 for (k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {poids[index[k]]+=(poids_pondere/ni);}
	 }
	 value=piletri[kmedian];
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(piletri,"piletri");
   tt_free(index,"index");
   tt_free(index0,"index0");
   return(OK_DLL);
}

int tt_ima_stack_sort_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant un tri                                            */
/***************************************************************************/
/* 1) Les valeurs sont triees dans l'ordre croissant,                      */
/* 2) Le pixel de l'image finale se voit affect� la valeur choisie a       */
/*    'percent' pourcent dans les valeurs triees.                          */
/* si percent=0   : l'image finale sera le minimum des pixels.             */
/* si percent=50  : l'image finale sera la mediane des pixels (donc        */
/*                  rigoureusement equivalent a tt_ima_stack_med_1).       */
/* si percent=100 : l'image finale sera le maximum des pixels.             */
/*                                                                         */
/***************************************************************************/
{
   int kk,kkk,kmedian;
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
   double *piletri;
   int *index,ni;
   double val;
   int *index0,nbima0,k;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sort_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   nombre=nbima;
   taille=sizeof(double);
   piletri=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&piletri,&nombre,&taille,"piletri"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sort_1 (pointer piletri)");
      tt_free(index0,"index0");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(int);
   index=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index,&nombre,&taille,"index"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sort_1 (pointer index)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");
      return(TT_ERR_PB_MALLOC);
   }
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
	       piletri[nbima0]=val;
	       index[nbima0]=kk;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    piletri[nbima0]=val;
	    index[nbima0]=kk;
	    nbima0++;
	 }
      }
      if (nbima0==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(poids_pondere/(double)(nbima));
	 }
	 value=pstack->nullpix_value;
      } else {
	 kmedian=(int)(floor(pstack->percent/100.*((double)nbima0+0.5)));
	 kmedian=(kmedian<0)?0:kmedian;
	 kmedian=(kmedian>=nbima0)?nbima0-1:kmedian;
	 tt_util_qsort_double(piletri,0,nbima0,index);
	 for (ni=0,k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {ni++;}
	 }
	 if (ni==0) {ni=1;}
	 for (k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {poids[index[k]]+=(poids_pondere/ni);}
	 }
	 value=piletri[kmedian];
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(piletri,"piletri");
   tt_free(index,"index");
   tt_free(index0,"index0");
   return(OK_DLL);
}

int tt_ima_stack_sk_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* kappa = 3                                                               */
/***************************************************************************/

{
   int kk,kkk;
   double poids_pondere,value,val;
   int base_adr;
   TT_IMA *p_tmp=pstack->p_tmp;
   TT_IMA *p_out=pstack->p_out;
   long firstelem=pstack->firstelem;
   long nelements=pstack->nelements;
   long nelem=pstack->nelem;
   long nelem0=pstack->nelem0;
   int nbima=pstack->nbima;
   double *poids=pstack->poids;
   double kappa=pstack->kappa;
   double ks_moyenne,ks_sigma,ks_dif;
   int ks_nbpoints,nbima0;
   int *index0;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sk_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
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
      /* --- condition no-filling ---*/
      /*
      for (kk=0;kk<nbima;kk++) {
	 if (index0[kk]==TT_NO) {
	    for (k=0;k<nbima;k++) {
	       index0[k]=TT_NO;
	    }
	    nbima0=0;
	    break;
	 }
      }
      */
      ks_moyenne=(nbima0==0)?pstack->nullpix_value:value/nbima0;
      ks_sigma=0.;
      for (value=0,kk=0;kk<nbima;kk++) {
	 if (index0[kk]==TT_YES) {
	    base_adr=(int)(nelem0)*kk;
	    ks_dif=(ks_moyenne-(double)(p_tmp->p[base_adr+kkk]));
	    value+=(ks_dif*ks_dif);
	 }
      }
      ks_sigma=(nbima0==0)?0.:sqrt(value/(double)nbima0);
      ks_nbpoints=0;
      for (value=0,kk=0;kk<nbima;kk++) {
	 if (index0[kk]==TT_YES) {
	    base_adr=(int)(nelem0)*kk;
	    ks_dif=fabs(ks_moyenne-(double)(p_tmp->p[base_adr+kkk]));
	    if (ks_dif<=(kappa*ks_sigma)) {
	       value+=(double)(p_tmp->p[base_adr+kkk]);
	       ks_nbpoints++;
	    }
	 }
      }
      if (ks_nbpoints==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(nbima0==0)?(poids_pondere/(double)(nbima)):(poids_pondere/(double)(nbima0));
	 }
      } else {
	 for (kk=0;kk<nbima;kk++) {
	    if (index0[kk]==TT_YES) {
	       base_adr=(int)(nelem0)*kk;
	       ks_dif=fabs(ks_moyenne-(double)(p_tmp->p[base_adr+kkk]));
	       if (ks_dif<=(kappa*ks_sigma)) {
		  poids[kk]+=(poids_pondere/(double)(ks_nbpoints));
	       }
	    }
	 }
	 ks_moyenne=value/ks_nbpoints;
	 if (nbima0==0) {
	    for (kk=0;kk<nbima;kk++) {
	       poids[kk]+=(poids_pondere/(double)(nbima));
	    }
	 }
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(ks_moyenne);
   }
   tt_free(index0,"index0");
   return(OK_DLL);
}

