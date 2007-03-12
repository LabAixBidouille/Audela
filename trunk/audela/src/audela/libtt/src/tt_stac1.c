/* tt_stac1.c
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

int tt_fct_ima_stack(void *arg1)
/***************************************************************************/
/* Fonction generale pour l'empilage des images.                           */
/***************************************************************************/
/* Cette fonction sert a synthetiser une image a partir d'un empilement    */
/* d'images de memes dimensions.                                           */
/*                                                                         */
/* # Pour la programmation :                                               */
/* -------------------------                                               */
/*                                                                         */
/* L'ajout d'une fonction consiste a effectuer un appel dans la partie :   */
/* 'Calcul de l'image finale pour la zone concernee'                       */
/*                                                                         */
/* # Pour l'utilisation :                                                  */
/* ----------------------                                                  */
/*                                                                         */
/* void *arg1 est une chaine de caracteres contenant un ligne de commandes */
/*  dont le codage doit etre realise ainsi :                               */
/*                                                                         */
/* Le codage est une suite d'arguments separes par des blancs. Si l'on ne  */
/* veut pas designer l'arguement, mettre un point.                         */
/* Les 11 premiers arguements sont obligatoires dans l'ordre suivant :     */
/*                                                                         */
/*  1) Obligatoirement IMA/STACK, nom de la fonction.                      */
/*  2) Nom du chemin d'acces aux images a traiter. La barre finale est     */
/*     automatiquement rajoutee si elle manque.                            */
/*     Placer un point si on cherche les images a traiter dans le chemin   */
/*     courant.                                                            */
/*  3) Nom generique (sans indice) de l'image a traiter.                   */
/*  4) Valeur de l'indice de la 1ere image a traiter.                      */
/*     NB : s'il n'y a qu'une seule image qui n'a pas d'indice alors       */
/*     mettre un point pour les arguments 4) et 5).                        */
/*  5) Valeur de l'indice de la derniere image a traiter.                  */
/*     NB : si les indices sont precedes de ; alors cela signifie que      */
/*     l'on demande d'acceder au fichier de nom defini par l'argument 3)   */
/*     et que l'on va explorer les images contenues dans les entetes       */
/*     etendues (HDUs de la norme FITS) de numeros 4) a 5).                */
/*  6) Nom de l'extension du fichier. Le point n'est pas automatiquement   */
/*     rajoute. Ainsi pour l'image toto.fits, indiquer .fits pour 6).      */
/*     NB : si l'extension est .mt alors les indices sont formates selon   */
/*     la avec quatre digits de 0001 a 9999.                               */
/*  7) Nom du chemin d'acces a l'image traitee. La barre finale est        */
/*     automatiquement rajoutee si elle manque.                            */
/*  8) Nom generique (sans indice) de l'image traitee.                     */
/*  9) Valeur de l'indice de l'image traitee.                              */
/*     NB : si les indices sont precedes de ; alors cela signifie que      */
/*     l'on demande d'acceder au fichier de nom defini par l'argument 3)   */
/*     et que l'on va ajouter l'image traitee apres l'entete de numero 9). */
/*     NB : si l'on ne veut pas d'indice alors mettre un point pour 9).    */
/* 10) Nom de l'extension du fichier. Le point n'est pas automatiquement   */
/*     rajoute. Ainsi pour l'image toto.fits, indiquer .fits pour 6).      */
/*     NB : si l'extension est .mt alors les indices sont formates selon   */
/*     la avec quatre digits de 0001 a 9999.                               */
/* 11) Nom de la sous-fonction a utiliser.                                 */
/*     MOY : moyenne                                                       */
/*     ADD : addition                                                      */
/*     MED : mediane                                                       */
/*     SORT : choix trie                                                   */
/*     KS : kappa-sigma                                                    */
/*                                                                         */
/* Les arguements suivants peuvent apparaitre dans n'importe quel ordre.   */
/*                                                                         */
/* Le parametre optionel 'bitpix' permet de choisir la valeur de BITPIX    */
/* pour l'image de sortie :                                                */
/*  bitpix=8   pour (unsigned char)                                        */
/*  bitpix=16  pour (short)                                                */
/*  bitpix=+16 pour (unsigned short)                                       */
/*  bitpix=32  pour (int)                                                  */
/*  bitpix=+32 pour (unsigned int)                                         */
/*  bitpix=-32 pour (float)                                                */
/*  bitpix=-64 pour (double)                                               */
/*                                                                         */
/* Les autres parametres dependent de la sous-fonction.                    */
/***************************************************************************/
{
   int msg;
   int naxis,naxis1_1,naxis2_1,k,kk,kkk,nbzones;
   long nelements,firstelem,nelem,n,nelem0;
   char **keys,*ligne,fonction[80];
   char fullname[(FLEN_FILENAME)+5];
   char fullname0[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   int nbkeys,nbima,base_adr;
   TT_IMA p_in,p_tmp,p_out;
   int load_indice_fin,load_indice_deb,save_indice_deb;
   int load_level_index; /* =0 si pas d'indices */
			 /* =1 pour un indice dans le nom */
			 /* =2 pour un indice d'entete avec le meme nom */
   int save_level_index;
   char date_obs_stack[FLEN_VALUE];
   char xvalue[FLEN_VALUE],yvalue[FLEN_VALUE];
   double *jj,*exptime,exptime_stack,jj_stack;
   double *poids,poids_total;
   TT_IMA_STACK pstack;
   char fullname2[FLEN_FILENAME];
   char path[FLEN_FILENAME];
   char name[FLEN_FILENAME];
   char suffix[FLEN_FILENAME];
   int hdunum,dimx,dimy,choix;
   char sb[]="MIPS-LO";
   char sh[]="MIPS-HI";
   int nombre,taille;

   /* ======================================== */
   /* === decodage de la ligne d'arguments === */
   /* ======================================== */
   ligne=(char*)arg1;
   /*printf("<%s>\n",ligne);*/
   tt_writelog(ligne);
   tt_decodekeys(ligne,(void***)(&keys),&nbkeys);

   /* ================================== */
   /* === verification des arguments === */
   /* ================================== */
   /* --- 0 :mot cle ---*/
   tt_strupr(keys[0]);
   if (strcmp(keys[0],"IMA/STACK")!=0) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(TT_ERR_FCT_IS_NOT_AS_SERVICE,NULL);
      return(TT_ERR_FCT_IS_NOT_AS_SERVICE);
   }
   if (nbkeys<11) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(TT_ERR_NOT_ENOUGH_ARGUS,NULL);
      return(TT_ERR_NOT_ENOUGH_ARGUS);
   }
   /* --- 1 a 5 : fichiers in ---*/
   if ((msg=tt_verifargus_2indices(keys,1,&load_level_index,&load_indice_deb,&load_indice_fin))!=TT_YES) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(msg,"Pb in input image indexes");
      return(msg);
   }
   if (load_level_index==0) { load_indice_fin=0; load_indice_deb=0; }
   nbima=1+load_indice_fin-load_indice_deb;
   /* --- 6 a 9 : fichiers out ---*/
   if ((msg=tt_verifargus_1indice(keys,6,&save_level_index,&save_indice_deb))!=TT_YES) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(msg,"Pb in output image index");
      return(msg);
   }
   /* --- 10 : nom de la fonction d'empilement ---*/
   tt_strupr(keys[10]);
   strcpy(fonction,keys[10]);
   /*
   for (k=0;k<nbkeys;k++) {printf("keys[%d]=<%s>\n",k,keys[k]);}
   printf("load_level_index=%d load_indice_deb=%d load_indice_fin=%d\n",load_level_index,load_indice_deb,load_indice_fin);
   printf("save_level_index=%d save_indice_deb=%d\n",save_level_index,save_indice_deb);
   */
   pstack.nbkeys=nbkeys;
   tt_ima_stack_builder(keys,&pstack);

   /* ======================= */
   /* === initialisations === */
   /* ======================= */

   /* --- analyse la premiere image et cree le tampon ---*/
   /* --- cree le fullname in ---*/
   if (load_level_index==1) {
      strcpy(fullname,tt_indeximafilecater(keys[1],keys[2],load_indice_deb,keys[5]));
   } else if (load_level_index==2) {
      sprintf(fullname,"%s;%d",tt_imafilecater(keys[1],keys[2],keys[5]),load_indice_deb);
   } else {
      sprintf(fullname,"%s",tt_imafilecater(keys[1],keys[2],keys[5]));
   }
   /* --- charge completement la premiere image ---*/
   tt_imabuilder(&p_in);
   if ((msg=tt_imaloader(&p_in,fullname,(long)(0),(long)(0)))!=0) {
      tt_imadestroyer(&p_in);
      tt_util_free_ptrptr((void**)keys,"keys");
      sprintf(message,"Problem concerning file %s ",fullname);
      tt_errlog(msg,message);
      return(msg);
   }
   strcpy(fullname0,fullname);
   naxis=p_in.naxis;
   naxis1_1=p_in.naxis1;
   naxis2_1=p_in.naxis2;
   if (pstack.bitpix==0) {
      pstack.bitpix=p_in.load_bitpix;
   }
   /* --- alloue l'espace de l'image tampon ---*/
   nelements=((long)naxis1_1)*((long)(naxis2_1));
   firstelem=(long)(0);
   nelem=(long)(floor((double)nelements/(double)(nbima)));
   /*
   printf("naxis1_1=%d naxis2_1=%d bitpix=%d nelements=%d nelem=%d\n",naxis1_1,naxis2_1,pstack.bitpix,nelements,nelem);
   getch();
   */
   tt_imabuilder(&p_tmp);
   tt_imacreater(&p_tmp,(int)(nbima),(int)(nelem));
   /* --- nombre de zones sur chaque image ---*/
   nbzones=1;
   n=nelem;
   while (n<nelements) {nbzones++; n+=nelem;}
   tt_imadestroyer(&p_in);
   /* --- alloue de l'espace pour l'image out ---*/
   tt_imabuilder(&p_out);
   tt_imacreater(&p_out,(int)(naxis1_1),(int)(naxis2_1));
   /* --- alloue de la place pour les parametres de temps ---*/
   nombre=nbima;
   taille=sizeof(double);
   jj=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&jj,&nombre,&taille,"jj"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_fct_ima_stack (pointer jj)");
      tt_imadestroyer(&p_in);
      tt_imadestroyer(&p_tmp);
      tt_imadestroyer(&p_out);
      tt_util_free_ptrptr((void**)keys,"keys");
      return(TT_ERR_PB_MALLOC);
   }
   exptime=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&exptime,&nombre,&taille,"exptime"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_fct_ima_stack (pointer exptime)");
      tt_imadestroyer(&p_in);
      tt_imadestroyer(&p_tmp);
      tt_imadestroyer(&p_out);
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_free(jj,"jj");
      return(TT_ERR_PB_MALLOC);
   }
   poids=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&poids,&nombre,&taille,"poids"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb alloc in tt_fct_ima_stack (pointer poids)");
      tt_imadestroyer(&p_in);
      tt_imadestroyer(&p_tmp);
      tt_imadestroyer(&p_out);
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_free(jj,"jj");
      tt_free(exptime,"exptime");
      return(TT_ERR_PB_MALLOC);
   }

   /* =================================== */
   /* === boucle de la premiere passe === */
   /* =================================== */

   /* --- boucle sur les zones ---*/
   for (nelem0=nelem,k=0;k<nbzones;k++) {
      /*printf("zone de stack=%d/%d\n",k,nbzones-1);*/
      firstelem=(long)(k)*nelem0;
      if ((firstelem+nelem0)>nelements) {
	 nelem=nelements-firstelem;
      } else {
	 nelem=nelem0;
      }
      /* --- boucle sur les images pour remplir le tampon ---*/
      for (kk=load_indice_deb;kk<=load_indice_fin;kk++) {
	 /* --- cree le fullname in ---*/
	 if (load_level_index==1) {
	    strcpy(fullname,tt_indeximafilecater(keys[1],keys[2],kk,keys[5]));
	 } else if (load_level_index==2) {
	    sprintf(fullname,"%s;%d",tt_imafilecater(keys[1],keys[2],keys[5]),kk);
	 } else {
	    sprintf(fullname,"%s",tt_imafilecater(keys[1],keys[2],keys[5]));
	 }
	 /* --- charge une partie de l'image ---*/
	 tt_imabuilder(&p_in);
	 if ((msg=tt_imaloader(&p_in,fullname,firstelem+1,nelem))!=0) {
	    sprintf(message,"Problem concerning file %s",fullname);
	    tt_errlog(msg,message);
	    tt_imadestroyer(&p_out);
	    tt_imadestroyer(&p_tmp);
	    tt_imadestroyer(&p_in);
	    tt_util_free_ptrptr((void**)keys,"keys");
	    tt_free(jj,"jj");
	    tt_free(exptime,"exptime");
	    tt_free(poids,"poids");
	    return(msg);
	 }
	 /* --- verification des dimensions ---*/
	 if (k==0) {
	    if ((naxis1_1!=p_in.naxis1)||(naxis2_1!=p_in.naxis2)) {
	       sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_in.naxis1,p_in.naxis2,fullname,naxis1_1,naxis2_1,fullname0);
	       tt_errlog(TT_ERR_IMAGES_NOT_SAME_SIZE,message);
	       tt_imadestroyer(&p_out);
	       tt_imadestroyer(&p_tmp);
	       tt_imadestroyer(&p_in);
	       tt_util_free_ptrptr((void**)keys,"keys");
	       tt_free(jj,"jj");
	       tt_free(exptime,"exptime");
	       tt_free(poids,"poids");
	       return(TT_ERR_IMAGES_NOT_SAME_SIZE);
	    }
	    tt_ima2jd(&p_in,2,&jj[kk-load_indice_deb]);
	    tt_ima2exposure(&p_in,2,&exptime[kk-load_indice_deb]);
	 }
	 /* --- copie la zone de l'image vers le tampon ---*/
	 base_adr=(int)(nelem0)*(kk-load_indice_deb);
	 for (kkk=0;kkk<(int)(nelem);kkk++) {
	    p_tmp.p[base_adr+kkk]=p_in.p[kkk];
	 }
	 tt_imadestroyer(&p_in);
      }
      /* --- heritage des donnees pour la structure de pstack ---*/
      pstack.p_tmp=&p_tmp;
      pstack.p_out=&p_out;
      pstack.firstelem=firstelem;
      pstack.nelements=nelements;
      pstack.nelem=nelem;
      pstack.nelem0=nelem0;
      pstack.nbima=nbima;
      pstack.poids=poids;
      pstack.exptimes=exptime;

      /* --- calcul de l'image finale pour la zone concernee ---*/
      if (pstack.numfct==TT_IMASTACK_MOY) {
	 msg=tt_ima_stack_moy_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_ADD) {
	 msg=tt_ima_stack_add_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_MED) {
	 msg=tt_ima_stack_med_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_SORT) {
	 msg=tt_ima_stack_sort_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_KS) {
	 msg=tt_ima_stack_sk_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_SIG) {
	 msg=tt_ima_stack_sig_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_SHUTTER) {
	 msg=tt_ima_stack_shutter_1(&pstack);
      } else if (pstack.numfct==TT_IMASTACK_PROD) {
	 msg=tt_ima_stack_prod_1(&pstack);
      } else {
	 tt_imadestroyer(&p_in);
	 tt_imadestroyer(&p_tmp);
	 tt_imadestroyer(&p_out);
	 tt_util_free_ptrptr((void**)keys,"keys");
	 tt_free(jj,"jj");
	 tt_free(exptime,"exptime");
	 tt_free(poids,"poids");
	 sprintf(message,"Function %s is not implemented in IMA/STACK",keys[10]);
	 tt_errlog(TT_ERR_FCT_NOT_FOUND_IN_IMASTACK,message);
	 return(TT_ERR_FCT_NOT_FOUND_IN_IMASTACK);
      }
   }
   tt_imadestroyer(&p_tmp);

   /* --- cree le fullname out ---*/
   if (save_level_index==0) {
      strcpy(fullname,tt_imafilecater(keys[6],keys[7],keys[9]));
   } else if (save_level_index==1) {
      strcpy(fullname,tt_indeximafilecater(keys[6],keys[7],save_indice_deb,keys[9]));
   } else if (save_level_index==2) {
      sprintf(fullname,"%s;%d",tt_imafilecater(keys[6],keys[7],keys[9]),save_indice_deb);
   }

   /* --- complete l'entete de l'image a sauver ---*/
   exptime_stack=(double)(0);
   jj_stack=(double)(0.);
   for (poids_total=(double)(0.),k=0;k<nbima;k++) {
      exptime_stack+=(poids[k]*exptime[k]);
      jj_stack+=(poids[k]*(jj[k]+exptime[k]/2/86400));
      poids_total+=poids[k];
   }
   jj_stack/=(double)(poids_total);
   jj_stack-=(double)(exptime_stack/2/86400);
   tt_jd2dateobs(jj_stack,date_obs_stack);
   tt_imanewkey(&p_out,"DATE-OBS",date_obs_stack,TSTRING,"Start of exposure. FITS standard","Iso 8601");
   tt_imanewkey(&p_out,"EXPOSURE",&exptime_stack,TDOUBLE,"Total time of exposure","s");

   /* --- complete l'entete avec celle de la premiere image ---*/
   if ((msg=tt_imarefheader(&p_out,fullname0))!=0) {
      tt_imadestroyer(&p_out);
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_free(jj,"jj");
      tt_free(exptime,"exptime");
      tt_free(poids,"poids");
      sprintf(message,"Problem concerning file %s for reference keywords",fullname);
      tt_errlog(msg,message);
      return(msg);
   }

   /* --- complete l'entete avec l'historique de ce traitement ---*/
   sprintf(xvalue,"%s %s",keys[0],keys[10]);
   tt_imanewkeytt(&p_out,xvalue,"TT History","");
   strcpy(xvalue," ");
   for (k=0;k<nbima;k++) {
      sprintf(yvalue,"%d",(int)(poids[k]*100.));
      strcat(xvalue,yvalue);
      if (strlen(xvalue)>((FLEN_VALUE)-10)) {
	 strcat(xvalue,"...");
	 break;
      }
      strcat(xvalue," ");
   }
   tt_imanewkeytt(&p_out,xvalue,"TT History","");

   /* --- on force le nombre d'axes = a celui de la premiere image  ---*/
   p_out.naxis=naxis;

   /* --- sauve l'image ---*/
   if ((msg=tt_imasaver(&p_out,fullname,pstack.bitpix))!=0) {
      tt_imadestroyer(&p_out);
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_free(jj,"jj");
      tt_free(exptime,"exptime");
      tt_free(poids,"poids");
      sprintf(message,"File %s cannot be saved",fullname);
      tt_errlog(msg,message);
      return(msg);
   }
   tt_imadestroyer(&p_out);

   /* --- sauve une image JPEG ---*/
   if (pstack.jpegfile_make==TT_YES) {
      strcpy(fullname2,pstack.jpegfile);
      if (strcmp(pstack.jpegfile,"")==0) {
	 /* --- identification du nom de fichier ---*/
	 if ((msg=tt_imafilenamespliter(fullname,path,name,suffix,&hdunum))!=0) { return(msg); }
	 strcpy(suffix,".jpg");
	 strcpy(fullname2,tt_imafilecater(path,name,suffix));
      }
      choix=0;dimx=dimy=0;
      /*if ((msg=libfiles_main(FS_MACR_FITS2JPG,7,fullname,fullname2,&choix,&sb,&sh,&dimx,&dimy))!=OK_DLL) {*/
      if ((msg=libfiles_main(FS_MACR_FITS2JPG,7,fullname,fullname2,&choix,sb,sh,&dimx,&dimy))!=OK_DLL) {
	 sprintf(message,"Problem concerning creation of JPEG file %s ",fullname2);
	 tt_errlog(msg,message);
	 return(msg);
      }
   }

   /* ======================================= */
   /* === on libere la memoire et on sort === */
   /* ======================================= */
   tt_util_free_ptrptr((void**)keys,"keys");
   tt_free(jj,"jj");
   tt_free(exptime,"exptime");
   tt_free(poids,"poids");
   return(OK_DLL);
}

int tt_ima_stack_builder(char **keys,TT_IMA_STACK *pstack)
/***************************************************************************/
/* Constructeur des valeurs de la structure TT_IMA_STACK                   */
/***************************************************************************/
/* A completer pour tout ajout d'une fonction de type IMA/STACK            */
/* au minimum en ajoutant un 'else if' dans la premiere serie.             */
/* C'est ici que l'on decode les mots optionels de fin de ligne.           */
/* Il n'y a pas de destructeur car aucune allocation memoire n'est realisee*/
/***************************************************************************/
{
   int k;
   int pos;
   char *car;
   char mot[80];
   char argu[80];
   pstack->numfct=0;
   if (strcmp(keys[10],"MEAN")==0) { pstack->numfct=TT_IMASTACK_MOY; }
   else if (strcmp(keys[10],"ADD")==0) { pstack->numfct=TT_IMASTACK_ADD; }
   else if (strcmp(keys[10],"MED")==0) { pstack->numfct=TT_IMASTACK_MED; }
   else if (strcmp(keys[10],"SORT")==0) { pstack->numfct=TT_IMASTACK_SORT; }
   else if (strcmp(keys[10],"KS")==0) { pstack->numfct=TT_IMASTACK_KS; }
   else if (strcmp(keys[10],"SK")==0) { pstack->numfct=TT_IMASTACK_KS; }
   else if (strcmp(keys[10],"SIG")==0) { pstack->numfct=TT_IMASTACK_SIG; }
   else if (strcmp(keys[10],"SHUTTER")==0) { pstack->numfct=TT_IMASTACK_SHUTTER; }
   else if (strcmp(keys[10],"PROD")==0) { pstack->numfct=TT_IMASTACK_PROD; }

   /* --- decodage des parametres optionels ---*/
   pstack->bitpix=0;
   pstack->percent=50.;
   pstack->kappa=3.;
   pstack->nullpix_exist=TT_NO;
   pstack->nullpix_value=0.;
   pstack->jpegfile_make=TT_NO;
   strcpy(pstack->jpegfile,"");

   for (k=11;k<(pstack->nbkeys);k++) {
      /* --- extrait le mot cle ---*/
      strcpy(mot,keys[k]);
      tt_strupr(mot);
      car=strstr(mot,"=");
      pos=0;
      if (car!=NULL) {
	 pos=(int)(car-mot);
	 mot[pos]='\0';
	 strcpy(argu,keys[k]+pos+1);
      } else {
	 /* --- mot sans argument ---*/
	 strcpy(argu,"");
      }

      /* --- extrait la valeur de l'argument ---*/
      if (strcmp(mot,"BITPIX")==0) {
	 if (strcmp(argu,"8")==0) {
	    pstack->bitpix=BYTE_IMG;
	 } else if (strcmp(argu,"16")==0) {
	    pstack->bitpix=SHORT_IMG;
	 } else if (strcmp(argu,"+16")==0) {
	    pstack->bitpix=USHORT_IMG;
	 } else if (strcmp(argu,"32")==0) {
	    pstack->bitpix=LONG_IMG;
	 } else if (strcmp(argu,"+32")==0) {
	    pstack->bitpix=ULONG_IMG;
	 } else if (strcmp(argu,"-32")==0) {
	    pstack->bitpix=FLOAT_IMG;
	 } else if (strcmp(argu,"-64")==0) {
	    pstack->bitpix=DOUBLE_IMG;
	 } else {
	    pstack->bitpix=0;
	 }
      }
      else if (strcmp(mot,"NULLPIXEL")==0) {
	 pstack->nullpix_exist=TT_YES;
	 pstack->nullpix_value=(double)(atof(argu));
      }
      else if (strcmp(mot,"PERCENT")==0) {
	 if (strcmp(argu,"")!=0) {
	    pstack->percent=(double)(fabs(atof(argu)));
	 }
      }
      else if (strcmp(mot,"JPEGFILE")==0) {
	 pstack->jpegfile_make=TT_YES;
	 if (strcmp(argu,"")!=0) {
	    strcpy(pstack->jpegfile,argu);
	 }
      }
      else if (strcmp(mot,"KAPPA")==0) {
	 if (strcmp(argu,"")!=0) {
	    pstack->kappa=(double)(fabs(atof(argu)));
	 }
      }
   }
   return(OK_DLL);
}

