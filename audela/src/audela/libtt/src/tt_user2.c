/* tt_user2.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Benjamin MAUCLAIRE <bmauclaire@underlands.org>
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

/***** prototypes des fonctions internes du user2 ***********/
int tt_ima_stack_2_tutu(TT_IMA_STACK *pstack);

int tt_ima_series_profile2(TT_IMA_SERIES *pseries);
int tt_ima_series_mediany2(TT_IMA_SERIES *pseries);


/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user2 pour IMA/SERIES                  */
/**************************************************************************/
/**************************************************************************/

int tt_user2_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"PROFILE2")==0) { pseries->numfct=TT_IMASERIES_USER2_PROFILE2; }
   else if (strcmp(keys10,"MEDIANY2")==0) { pseries->numfct=TT_IMASERIES_USER2_MEDIANY2; }
   return(OK_DLL);
}

int tt_user2_ima_series_builder2(TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pseries->user2.y1=1;
   pseries->user2.y2=1;
   pseries->user2.height=20;
   strcpy(pseries->user2.direction,"x");
   strcpy(pseries->user2.filename,"profil.dat");
   return(OK_DLL);
}

int tt_user2_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"Y1")==0) {
      pseries->user2.y1=(int)(atof(argu));
   } else if (strcmp(mot,"Y2")==0) {
      pseries->user2.y2=(int)(atof(argu));
   } else if (strcmp(mot,"HEIGHT")==0) {
      pseries->user2.height=(int)(atof(argu));
   } else if (strcmp(mot,"DIRECTION")==0) {
      strcpy(pseries->user2.direction,argu);
   } else if (strcmp(mot,"FILENAME")==0) {
      strcpy(pseries->user2.filename,argu);
   }
   return(OK_DLL);
}

int tt_user2_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pseries->numfct==TT_IMASERIES_USER2_PROFILE2) {
      *msg=tt_ima_series_profile2(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER2_MEDIANY2) {
      *msg=tt_ima_series_mediany2(pseries);
      *fct_found=TT_YES;
   }
   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user2 pour IMA/STACK                   */
/**************************************************************************/
/**************************************************************************/

int tt_user2_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"TUTU")==0) { pstack->numfct=TT_IMASTACK_USER2_TUTU; }
   return(OK_DLL);
}

int tt_user2_ima_stack_builder2(TT_IMA_STACK *pstack)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pstack->user2.param1=0.;
   return(OK_DLL);
}

int tt_user2_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TUTU_PARAM")==0) {
      pstack->user2.param1=(double)(atof(argu));
   }
   return(OK_DLL);
}

int tt_user2_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pstack->numfct==TT_IMASTACK_USER2_TUTU) {
      *msg=tt_ima_stack_2_tutu(pstack);
      *fct_found=TT_YES;
   }
   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* exemple de la fonction user TUTU implantee dans IMA/STACK              */
/**************************************************************************/
/* Pile d'addition d'image (equivalent a ADD2 de Qmips32).                */
/* Subtil tour de force pour tenir compte des pixels non definis et pour  */
/* calculer l'heure de l'image synthetisee au prorata des images.         */
/**************************************************************************/
int tt_ima_stack_2_tutu(TT_IMA_STACK *pstack)
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


/**************************************************************************/
/* Fonction Profil                                                        */
/* Modifée par Benji                                                      */
/* arguments possibles:direction,nom du fichier,offset                    */
/**************************************************************************/
int tt_ima_series_profile2(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int i,x,y;              /* loop variable */
   int offset;
   FILE *file;

   char message[TT_MAXLIGNE];


   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   w=p_in->naxis1;
   h=p_in->naxis2;
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for(x = 0; x < w;x++)
   {
       for(y = 0;y < h;y++)
       {
           p_out->p[x + y * w] =  p_in->p[x + y * w];
       } /* end of y-loop */
   } /* end of x-loop */
   index=pseries->index;
   offset=(int)pseries->offset-1;

    /* verification des donnees */
   if((strcmp(pseries->user2.direction,"x")!=0)&&(strcmp(pseries->user2.direction,"y")!=0))
   {
         sprintf(message,"direction must be x or y");
         tt_errlog(TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   }


   if(strcmp(pseries->user2.direction,"x")==0)
   {
   	if (offset < 0)
   	{
         sprintf(message,"offset must be contained between 1 and %d",w);
         tt_errlog(TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   	} /* end of if-statement */
   }
   else if (strcmp(pseries->user2.direction,"y")==0)
   	if (offset < 0)
   	{
         sprintf(message,"offset must be contained between 1 and %d",h);
         tt_errlog(TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   	} /* end of if-statement */

   /* write in a file */
   file = fopen(pseries->user2.filename,"wt");
   /*   fprintf(file,"%s"\n","pixel            value of the pixel");*/
   /* Pas de label des colonnes. BM 20/06/2006 */
   /* fprintf(file,"%s\t%s\n","pixel","value of the pixel"); */
   /* fprintf(file,"%d\t%f\n",0,0.0); */
   if(strcmp(pseries->user2.direction,"x")==0)
   {
       for(i = 0;i < w;i++)
       fprintf(file,"%d\t%f\n",(i+1),p_in->p[i + offset * w]);
   }
   else
   {
       for(i = 0;i < h;i++)
       fprintf(file,"%d\t%f\n",(i+1),p_in->p[i * w + offset]);
   }
   fclose(file);


   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction MedianY                                                      */
/* arguments possibles : y1,y2,height                                     */
/**************************************************************************/
int tt_ima_series_mediany2(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int height;
   int y1,y2;
   int x,y;              /* loop variable */
   double value;          /* temporary variable */
   int temp;             /* temporary variable */
   int diff_y,diff_y_2;
   double *tab=NULL;

   char message[TT_MAXLIGNE];
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;


   w=p_in->naxis1;
   h=p_in->naxis2;
   height=pseries->user2.height;
   y1=pseries->user2.y1-1;
   y2=pseries->user2.y2-1;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,height);


   /* verification des donnees */
   if (height < 0)
   {
         sprintf(message,"height must be positive");
         tt_errlog(TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((y1 < 0) || (y2 < 0) || (y1 >h -1) || (y2 > h-1))
   {
         sprintf(message,"y1 and y2 must be contained between 1 and %d",h);
         tt_errlog(TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } /* end of if-statement */


   /* mediany */
   diff_y = (y2 - y1) + 1;
   diff_y_2 = (int) (diff_y / 2);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tab,&diff_y,&taille,"tab"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_mediany for pointer tab");
      return(TT_ERR_PB_MALLOC);
   }

   for(x = 0; x < w;x++)
   {
       for(y = 0;y < diff_y;y++)
       {
           *(tab + y) = p_in->p[x + ((y + y1) * w)];
       } /* end of x-loop */
       tt_util_qsort_double(tab,0,diff_y,NULL);
       if ((diff_y % 2) == 1)
           value = *(tab + diff_y_2);
       else value =  (*(tab + diff_y_2) + *(tab + diff_y_2 - 1)) / 2;
       for(y = 0; y < height;y++)
       {
           p_out->p[x + y * w] = (TT_PTYPE)value;
       } /* end of x-loop */
   } /* end of y-loop */

   tt_free(tab,"tab");

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


