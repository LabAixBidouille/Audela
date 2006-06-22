/* mc_file1.c
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

/***************************************************************************/
/* MC : Utilitaire de meca celeste                                         */
/* Auteur : Alain Klotz                                                    */
/***************************************************************************/
/* Utilitaires de gestion de fichiers (base de Bowell, tri ...)            */
/***************************************************************************/
#include "mc.h"

void mc_mpc_dec1(char *ligne, struct asterident *aster)
/***************************************************************************/
/* Decode les arguments d'une ligne extraite du fichier de la base de      */
/* MPC et stocke les parametres dans la structure asterindent.          */
/***************************************************************************/
/***************************************************************************/
{
   char texte[300];
   int col1,col2,nt;
   int annee,mois;
   double jour,jj;
   int k;

   strcpy(aster->name,"");
   if ((int)strlen(ligne)<176) {
	     aster->nbobs=-1*(int)strlen(ligne);
         aster->nbjours=-1;
	   return;
   }
   col1=167;col2=172;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   for (col1=0;col1<(int)strlen(texte);col1++) {
      if ((texte[col1]<'0')||(texte[col1]>'9')) { texte[col1]=' '; }
   }
   texte[col1+1]='\0';
   aster->num=atoi(texte);
   aster->h=14.;
   aster->g=.15;
   aster->jj_epoque=J2000; jj=J2000;
   aster->nbjours=100;
   aster->nbobs=3;
   aster->a=1.5;
   aster->m0=300.*(DR);
   aster->jj_m0=J2000;
   aster->i=15.*(DR);
   aster->e=.25;
   aster->o=156.*(DR);
   /*---*/
   col1=175;
   col2=(int)strlen(ligne);
   if ((col2-col1)>20) {col2=col1+20;}
   strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   /* elimine les blancs de debut et de fin sur le nom */
   strcpy(aster->name,texte);
   nt=(int)strlen(texte);
   for (col1=0;col1<nt;col1++) {
      if (texte[col1]!=' ') { break; }
   }
   for (col2=nt;col2>=0;col2--) {
	  if (col2<0) { col2=0; break;}
      if (texte[col2]>' ') { break; }
   }
   if (col1<0) {col1=0;}
   if (col2>20) {col2=20;}
   k=0;
   for (k=col1;k<=col2;k++) {
      aster->name[k-col1]=texte[k];
   }
   aster->name[col2-col1+1]='\0';
   col1=  9;col2= 13;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->h=atof(texte);
   if (aster->h==0.) {aster->h=14.0;}
   col1= 16;col2= 19;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->g=atof(texte);
   if (aster->g==0.) {aster->g=0.15;}
   col1= 21;col2= 21;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   annee=100*((int)(texte[0])-55);
   col1= 22;col2= 23;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   annee+=atoi(texte);
   col1= 24;col2= 24;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   mois=(int)(texte[0])-55;
   if (mois<10) {mois=atoi(texte);}
   col1= 25;col2= 25;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   jour=(double)(texte[0])-55.;
   if (jour<10) {jour=atof(texte);}
   mc_date_jd(annee,mois,jour,&jj);
   aster->jj_epoque=jj;   
   aster->bv=0.;
   aster->rayoniras=0.;
   strcpy(aster->classe,"");
   aster->code1=0;
   aster->code2=0;
   aster->code3=0;
   aster->code4=0;
   aster->code5=0;
   aster->code6=0;
   col1=133;col2=136;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   if (strcmp(texte,"days")==0) {
      col1=128;col2=131;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
      aster->nbjours=atoi(texte);
   } else {
	  annee=atoi(texte);
      col1=128;col2=131;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
      aster->nbjours=(int)((annee-atoi(texte))*365.25);
   }
   col1=118;col2=122;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->nbobs=atoi(texte);
   col1= 27;col2= 35;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->m0=atof(texte)*DR;
   aster->jj_m0=aster->jj_epoque;
   aster->jj_equinoxe=J2000;
   col1= 38;col2= 46;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->w=atof(texte)*DR;
   col1= 49;col2= 57;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->o=atof(texte)*DR;
   col1= 60;col2= 68;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->i=atof(texte)*DR;
   col1= 70;col2= 79;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->e=atof(texte);
   col1= 93;col2=103;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->a=atof(texte);
   aster->ceu0=0.;
   aster->ceut=0.;
   aster->jj_ceu0=jj;
   /*---*/
   if ((fabs(aster->e)>=1.05)||(fabs(aster->a)<.02)||(annee<1800)||(jour<1)||(jour>31)||(mois<1)||(mois>12)||(aster->nbobs==0)||(aster->nbjours==0)) {
	   strcpy(aster->name,"");
   }
}

void mc_bow_dec1(char *ligne, struct asterident *aster)
/***************************************************************************/
/* Decode les arguments d'une ligne extraite du fichier de la base de      */
/* Bowell et stocke les parametres dans la structure asterindent.          */
/***************************************************************************/
/***************************************************************************/
{
   char texte[300];
   int col1,col2;
   int annee,mois;
   double jour,jj;
   int k;

   strcpy(aster->name,"");
   if ((int)strlen(ligne)<215) {
	  return;
   }
   col1=  1;col2=  5;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->num=atoi(texte);
   col1=  7;col2= 24;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   /* elimine les blancs de debut et de fin sur le nom */
   for (col1=0;col1<(int)strlen(texte);col1++) {
      if (texte[col1]!=' ') { break; }
   }
   for (col2=(int)strlen(texte)-1;col2>=0;col2--) {
      if (texte[col2]!=' ') { break; }
   }
   col1=(col1>23)?23:col1;
   col2=(col2>23)?23:col2;
   for (k=col1;k<=col2;k++) {
      aster->name[k-col1]=texte[k];
   }
   aster->name[k]='\0';
   col1= 42;col2= 46;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->h=atof(texte);
   col1= 48;col2= 52;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->g=atof(texte);
   col1= 54;col2= 57;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->bv=atof(texte);
   col1= 59;col2= 63;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->rayoniras=atof(texte);
   col1= 65;col2= 66;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   strcpy(aster->classe,texte);
   col1= 70;col2= 73;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->code1=atoi(texte);
   col1= 74;col2= 77;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->code2=atoi(texte);
   col1= 78;col2= 81;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->code3=atoi(texte);
   col1= 82;col2= 85;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->code4=atoi(texte);
   col1= 86;col2= 89;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->code5=atoi(texte);
   col1= 90;col2= 93;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->code6=atoi(texte);
   col1= 94;col2= 99;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->nbjours=atoi(texte);
   col1=100;col2=104;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->nbobs=atoi(texte);
   col1=106;col2=109;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   annee=atoi(texte);
   col1=110;col2=111;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   mois=atoi(texte);
   col1=112;col2=113;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   jour=atof(texte);
   mc_date_jd(annee,mois,jour,&jj);
   aster->jj_epoque=jj;
   col1=115;col2=124;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->m0=atof(texte)*DR;
   aster->jj_m0=aster->jj_epoque;
   aster->jj_equinoxe=J2000;
   col1=126;col2=135;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->w=atof(texte)*DR;
   col1=137;col2=146;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->o=atof(texte)*DR;
   col1=147;col2=156;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->i=atof(texte)*DR;
   col1=158;col2=167;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->e=atof(texte);
   col1=168;col2=180;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->a=atof(texte);
   col1=190;col2=197;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->ceu0=atof(texte);
   col1=199;col2=206;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   aster->ceut=atof(texte);
   col1=208;col2=211;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   annee=atoi(texte);
   col1=212;col2=213;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   mois=atoi(texte);
   col1=214;col2=215;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   jour=atof(texte);
   mc_date_jd(annee,mois,jour,&jj);
   aster->jj_ceu0=jj;
   /*---*/
   if ((aster->a==0.)||(jj==0.)||(aster->nbobs==0)||(aster->nbjours==0)) {
	   strcpy(aster->name,"");
   }
}

void mc_bow_dec2(char *num_aster, char *nom_fichier_in,struct elemorb *elem,struct asterident *aster,int *concordance)
/***************************************************************************/
/* Decode le *num_aster d'un asteroide de la base de Bowell                */
/* On rentre, soit le numero (ex : 1 pour Ceres) ou bien le numero         */
/* provisoire toutes lettres collees (ex : 1997DQ).                        */
/* Met a jour la structure elem pour l'asteroide trouve.                   */
/***************************************************************************/
{
   FILE *fichier_in;
   char num1[20],num2[20],num0[50],ligne[300],texte[40];
   int numero,provisoire,trouve,col1,col2;

   /*--- decomposition du numero au format Bowell ---*/
   mc_strupr(num_aster,num_aster);
   strcpy(num1,num_aster);
   num1[4]='\0';
   if (strlen(num_aster)>=5) {
      strcpy(num2,num_aster+4);
   } else {
      strcpy(num2,"");
   }
   strcpy(num0,num1);
   provisoire=0;
   if (strcmp(num2,"")!=0) {
      strcat(num0," ");
      strcat(num0,num2);
      provisoire=1;
      numero=-1;
   } else {
      numero=atoi(num1);
   }
   strcat(num0,"                    ");
   num0[18]='\0';
   /* --- recherche de l'asteroide dans la base de Bowell ---*/
   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   trouve=0;
   do {
      fgets(ligne,300,fichier_in);
      col1=  1;col2=  5;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
      aster->num=atoi(texte);
      col1=  7;col2= 24;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
      strcpy(aster->name,texte);
      if ((strcmp(num0,aster->name)==0)||(numero==aster->num)) {
         mc_bow_dec1(ligne,aster);
         mc_aster2elem(*aster,elem);
         trouve=1;
      }
   } while ((feof(fichier_in)==0)&&(trouve==0));
   *concordance=trouve;
   fclose(fichier_in);
}

void mc_bow_dec3(char *num_aster, char *nom_fichier_in,int *concordance,char *nom_fichier_ele)
/***************************************************************************/
/* Decode le *num_aster d'un asteroide de la base de Bowell                */
/* On rentre, soit le numero (ex : 1 pour Ceres) ou bien le numero         */
/* provisoire toutes lettres collees (ex : 1997DQ).                        */
/* Met a jour le fichier elem pour l'asteroide trouve.                     */
/***************************************************************************/
{
   FILE *fichier_in;
   char num1[20],num2[20],num0[50],ligne[300];
   int numero,provisoire,trouve;
   struct asterident aster;
   struct elemorb elem;

   /*--- decomposition du numero au format Bowell ---*/
   mc_strupr(num_aster,num_aster);
   strcpy(num1,num_aster);
   num1[5]='\0';
   if (strlen(num_aster)>=5) {
      strcpy(num2,num_aster+5);
   } else {
      strcpy(num2,"");
   }
   strcpy(num0,num1);
   provisoire=0;
   if (strcmp(num2,"")!=0) {
      strcat(num0," ");
      strcat(num0,num2);
      provisoire=1;
      numero=-1;
   } else {
      numero=atoi(num1);
   }
   strcat(num0,"                    ");
   num0[18]='\0';
   /* --- recherche de l'asteroide dans la base de Bowell ---*/
   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   trouve=0;
   do {
      fgets(ligne,300,fichier_in);
      mc_bow_dec1(ligne,&aster);
      if ((strcmp(num0,aster.name)==0)||(numero==aster.num)) {
      trouve=1;
      }
   } while ((feof(fichier_in)==0)&&(trouve==0));
   *concordance=trouve;
   fclose(fichier_in);
   if (trouve==1) {
      mc_aster2elem(aster,&elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_lec_obs_mpc(char *nom_fichier_in, struct observ *obs, int *nbobs)
/***************************************************************************/
/* Converti les donnees d'observation format MPC vers format interne.      */
/* Si nbobs==0 : alors on renvoi juste le nbobs afin de pouvoir            */
/* dimensionner le nombre d'element du vecteur *obs.                       */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_station;
   char ligne[120],texte[120],texte2[120],nom_fichier_station[120];
   double a,b,c;
   int len,n,mpc_format,k,col1,col2,conv,check_station,cod;
   int nn,nbstati=0;
   struct observ *stati=NULL;

   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   strcpy(nom_fichier_station,"stations.txt");
   if (( fichier_station=fopen(nom_fichier_station,"r") ) == NULL) {
      check_station=PB;
   } else {
      check_station=OK;
      nbstati=0;
      do {
         if (fgets(ligne,120,fichier_station)!=NULL) {
            nbstati++;
         }
      } while (feof(fichier_station)==0);
      rewind(fichier_station);
      stati = (struct observ *) calloc(nbstati+1,sizeof(struct observ));
      nn=0;
      do {
         if (fgets(ligne,120,fichier_station)!=NULL) {
            nn++;
            col1=1;col2=3;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            strcpy((stati+nn)->codmpc,texte);
            col1=5;col2=12;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            (stati+nn)->longuai=atof(texte)*DR;
            col1=14;col2=20;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            (stati+nn)->rhocosphip=atof(texte);
            col1=22;col2=29;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            (stati+nn)->rhosinphip=atof(texte);
         }
      } while (feof(fichier_station)==0);
      fclose(fichier_station);
   }
   n=0;
   if (*nbobs==0) {
      conv=PB;
   } else {
      conv=OK;
   }
   do {
      if (fgets(ligne,120,fichier_in)!=NULL) {
         len=strlen(ligne);
         strcpy(texte,ligne);
         for (k=0;k<=len;k++) {
            if (ligne[k]==' ') {
               texte[k]=' ';
            } else if (ligne[k]=='.') {
               texte[k]='.';
            } else if ((ligne[k]>='0')&&(ligne[k]<='9')) {
               texte[k]='x';
            } else {
               texte[k]='a';
            }
         }
         texte[k]='\0';
         mpc_format=PB;
         if (strlen(texte)>=65) {
            col1= 15;col2= 65;strncpy(texte2,texte+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
            if (strcmp(texte2,"axxxx xx xx.xxxxx xx xx xx.xx axx xx xx.x          ")==0) {
               mpc_format=OK;
               n++;
               if ((conv==OK)&&(n<=*nbobs)) {
                  memset(texte,' ',13);texte[13]='\0';
                  col1= 1;col2=12;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  strcpy((obs+n)->designation,texte);
                  col1=16;col2=19;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  a=atof(texte);
                  col1=21;col2=22;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  b=atof(texte);
                  col1=24;col2=31;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  c=atof(texte);
                  mc_date_jd((int)(a),(int)(b),c,&(obs+n)->jjtu);
                  mc_tu2td((obs+n)->jjtu,&(obs+n)->jjtd);
                  col1=33;col2=34;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  a=atof(texte);
                  col1=36;col2=37;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  b=atof(texte);
                  col1=39;col2=44;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  c=atof(texte);
                  (obs+n)->asd=(a+b/60+c/3600)*15*DR;
                  col1=46;col2=47;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  a=atof(texte);
                  col1=49;col2=50;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  b=atof(texte);
                  col1=52;col2=56;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  c=atof(texte);
                  (obs+n)->dec=(a+b/60+c/3600)*DR;
                  col1=45;col2=45;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  if (strcmp(texte,"-")==0) {
                     (obs+n)->dec=-(obs+n)->dec;
                  }
                  (obs+n)->jj_equinoxe=J2000;
                  col1=66;col2=70;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  a=atof(texte);
                  if (a!=0) {
                     (obs+n)->mag1=a;
                  } else {
                     (obs+n)->mag1=MAGNULL;
                  }
                  col1=78;col2=80;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                  strcpy((obs+n)->codmpc,texte);
                  if ((check_station==PB)||(strcmp((obs+n)->codmpc,"   ")==0)) {
                     cod=PB;
                  } else {
                     rewind(fichier_station);
                     cod=PB;
                     nn=0;
                     do {
                        nn++;
                        if (strcmp((obs+n)->codmpc,(stati+nn)->codmpc)==0) {
                           cod=OK;
                           strcpy((obs+n)->codmpc,(stati+nn)->codmpc);
                           (obs+n)->longuai=(stati+nn)->longuai;
                           (obs+n)->rhocosphip=(stati+nn)->rhocosphip;
                           (obs+n)->rhosinphip=(stati+nn)->rhosinphip;
                        }
                     } while ((nn<=nbstati)&&(cod==PB));
                  }
                  if (cod==PB) {
                     strcpy((obs+n)->codmpc,"500");
                     (obs+n)->longuai=0.0;
                     (obs+n)->rhocosphip=0.0;
                     (obs+n)->rhosinphip=0.0;
                  }
               }
            }
         }
      }
   } while (feof(fichier_in)==0);
   fclose(fichier_in);
   if (check_station==OK) {
      free(stati);
   }
   *nbobs=n;
}

void mc_lec_station_mpc(char *nom_fichier_station, char *station, double *longmpc, double *rhocosphip, double *rhosinphip)
/***************************************************************************/
/* Fourni les coordonnees MPC s'un site a partir du fichier de station     */
/* Longmpc est donne en radians.                                           */
/***************************************************************************/
/* Retourne longmpc=10 si le fichier n'est pas trouve.                     */
/* Retourne longmpc=15 si la station n'est pas trouvee.                    */
/***************************************************************************/
{
   FILE *fichier_station;
   char ligne[120],texte[120];
   int check_station,col1,col2;
   int nn,nbstati;
   struct observ *stati;

   if (( fichier_station=fopen(nom_fichier_station,"r") ) == NULL) {
      check_station=PB;
	  *longmpc=10.;
	  *rhocosphip=0.;
	  *rhosinphip=0.;
	  return;
   } else {
	  *longmpc=15.;
      check_station=OK;
      nbstati=0;
      do {
         if (fgets(ligne,120,fichier_station)!=NULL) {
            nbstati++;
         }
      } while (feof(fichier_station)==0);
      rewind(fichier_station);
      stati = (struct observ *) calloc(nbstati+1,sizeof(struct observ));
      nn=0;
      do {
         if (fgets(ligne,120,fichier_station)!=NULL) {
            nn++;
            col1=1;col2=3;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            strcpy((stati+nn)->codmpc,texte);
            col1=5;col2=12;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            (stati+nn)->longuai=atof(texte)*(DR);
            col1=14;col2=20;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            (stati+nn)->rhocosphip=atof(texte);
            col1=22;col2=29;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
            (stati+nn)->rhosinphip=atof(texte);
         }
      } while (feof(fichier_station)==0);
      fclose(fichier_station);
   }
   for (nn=0;nn<nbstati;nn++) {
      if (strcmp(station,(stati+nn)->codmpc)==0) {
         *longmpc=((stati+nn)->longuai);
         *rhocosphip=(stati+nn)->rhocosphip;
         *rhosinphip=(stati+nn)->rhosinphip;
		 break;
      }
   } 
   if (check_station==OK) {
      free(stati);
   }
}


void mc_readelem(char *nom_fichier_in,struct elemorb *elem)
/***************************************************************************/
/* Lit les elements d'orbites sur le disque.                               */
/***************************************************************************/
{
   int concordance,ligdeb=1;
   mc_lec_ele_mpec1(nom_fichier_in,elem,&concordance,&ligdeb);
   /*
   FILE *fichier_in;
   char ligne[255];
   char texte[255];
   int col1,col2,k,len;
   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      return;
   }
   col1=30;
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   *(texte+22)='\0';
   len=strlen(texte);
   for (k=1;k<=len;k++) {
      if ((texte[k]==13)||(texte[k]==10)) {
         texte[k]='\0';
      }
   }
   strcpy(elem->designation,texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->m0=atof(texte)*DR;
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->jj_m0=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->e=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->q=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->jj_perihelie=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->i=atof(texte)*DR;
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->o=atof(texte)*DR;
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->w=atof(texte)*DR;
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->jj_equinoxe=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->jj_epoque=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->type=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->h0=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->n=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->h=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->g=atof(texte);
   fgets(ligne,254,fichier_in);
   fgets(ligne,254,fichier_in);
   fgets(ligne,254,fichier_in);
   fgets(ligne,254,fichier_in);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->nbjours=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->nbobs=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->ceu0=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpyexte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->ceut=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->jj_ceu0=atof(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->code1=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->code2=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->code3=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->code4=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->code5=atoi(texte);
   fgets(ligne,254,fichier_in);col2=strlen(ligne);strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
   elem->code6=atoi(texte);
   fclose(fichier_in);
   */
}

void mc_select_observ(struct observ *obsin, int nbobsin,char *designation,struct observ *obsout,int *nbobsout)
/***************************************************************************/
/* Isole une serie d'observations qui ont la meme designation et trie ces  */
/* observations dans l'ordre chronologique croissant                       */
/***************************************************************************/
{
   int k,n,conv;
   int qsort_r[31],qsort_l[31];
   int s,l,r,i,j;
   double v,w;
   char ligne[30];
   conv=PB;
   if (*nbobsout>0) {
      conv=OK;
   }
   for (n=0,k=1;k<=nbobsin;k++) {
      /*
      printf("<%s><%s>\n",(obsin+k)->designation,designation);
      */
      if (strstr((obsin+k)->designation,designation)!=NULL) {
         n++;
         if (conv==OK) {
            strcpy((obsout+n)->designation,(obsin+k)->designation);
            (obsout+n)->jjtu=(obsin+k)->jjtu;
            (obsout+n)->jjtd=(obsin+k)->jjtd;
            (obsout+n)->asd=(obsin+k)->asd;
            (obsout+n)->dec=(obsin+k)->dec;
            (obsout+n)->jj_equinoxe=(obsin+k)->jj_equinoxe;
            strcpy((obsout+n)->codmpc,(obsin+k)->codmpc);
            (obsout+n)->longuai=(obsin+k)->longuai;
            (obsout+n)->rhocosphip=(obsin+k)->rhocosphip;
            (obsout+n)->rhosinphip=(obsin+k)->rhosinphip;
            (obsout+n)->mag1=(obsin+k)->mag1;
         }
      }
   }
   *nbobsout=n;
   if (conv==OK) {
      /*--- trie le tableau dans l'ordre croissant des dates jjtd ---*/
      s=1; qsort_l[1]=1; qsort_r[1]=n;
      do {
         l=qsort_l[s]; r=qsort_r[s];
         s=s-1;
         do {
            i=l; j=r;
            v=(obsout+(int) (floor((l+r)/2)))->jjtd;
            do {
               while ((obsout+i)->jjtd<v) {i++;}
               while (v<(obsout+j)->jjtd) {j--;}
               if (i<=j) {
                  strcpy(ligne,(obsout+i)->designation);strcpy((obsout+i)->designation,(obsout+j)->designation);strcpy((obsout+j)->designation,ligne);
                  w=(obsout+i)->jjtu;(obsout+i)->jjtu=(obsout+j)->jjtu;(obsout+j)->jjtu=w;
                  w=(obsout+i)->jjtd;(obsout+i)->jjtd=(obsout+j)->jjtd;(obsout+j)->jjtd=w;
                  w=(obsout+i)->asd;(obsout+i)->asd=(obsout+j)->asd;(obsout+j)->asd=w;
                  w=(obsout+i)->dec;(obsout+i)->dec=(obsout+j)->dec;(obsout+j)->dec=w;
                  w=(obsout+i)->jj_equinoxe;(obsout+i)->jj_equinoxe=(obsout+j)->jj_equinoxe;(obsout+j)->jj_equinoxe=w;
                  strcpy(ligne,(obsout+i)->codmpc);strcpy((obsout+i)->codmpc,(obsout+j)->codmpc);strcpy((obsout+j)->codmpc,ligne);
                  w=(obsout+i)->longuai;(obsout+i)->longuai=(obsout+j)->longuai;(obsout+j)->longuai=w;
                  w=(obsout+i)->rhocosphip;(obsout+i)->rhocosphip=(obsout+j)->rhocosphip;(obsout+j)->rhocosphip=w;
                  w=(obsout+i)->rhosinphip;(obsout+i)->rhosinphip=(obsout+j)->rhosinphip;(obsout+j)->rhosinphip=w;
                  w=(obsout+i)->mag1;(obsout+i)->mag1=(obsout+j)->mag1;(obsout+j)->mag1=w;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
         } while (l<r);
      } while (s!=0) ;
   }
}

void mc_select32_observ(struct observ *obsin, int nbobsin,struct observ *obsout,int *nbobsout,int contrainte)
/***************************************************************************/
/* Isole une serie de deux ou trois observations prealablement triee en    */
/* ordre chronologique par mc_select_observ.                               */
/* L'observation du milieu est celle ecartee la plus des deux extremes.    */
/***************************************************************************/
{
   int k,nn,n,conv,indice[4],kmax;
   double dt1,dt2,dt,dtmax;
   conv=OK;
   if (*nbobsout==0) {
      conv=PB;
   }
   if ((nbobsin<=2)||(contrainte==2)) {
      indice[1]=1;
      indice[2]=nbobsin;
      if (contrainte==2) {
         nn=2;
      } else {
         nn=nbobsin;
      }
   } else {
      indice[1]=1;
      indice[3]=nbobsin;
      nn=3;
      dtmax=0.;
      for (k=2,kmax=2;k<=nbobsin-1;k++) {
         dt1=((obsin+k)->jjtd)-((obsin+1)->jjtd);
         dt2=((obsin+nbobsin)->jjtd)-((obsin+k)->jjtd);
         dt=dt1*dt2;
         if (dt>dtmax) {
            kmax=k;
            dtmax=dt;
         }
      }
      indice[2]=kmax;
   }
   *nbobsout=nn;
   if (conv==OK) {
      for (n=1;n<=nn;n++) {
         k=indice[n];
         strcpy((obsout+n)->designation,(obsin+k)->designation);
         (obsout+n)->jjtu=(obsin+k)->jjtu;
         (obsout+n)->jjtd=(obsin+k)->jjtd;
         (obsout+n)->asd=(obsin+k)->asd;
         (obsout+n)->dec=(obsin+k)->dec;
         (obsout+n)->jj_equinoxe=(obsin+k)->jj_equinoxe;
         strcpy((obsout+n)->codmpc,(obsin+k)->codmpc);
         (obsout+n)->longuai=(obsin+k)->longuai;
         (obsout+n)->rhocosphip=(obsin+k)->rhocosphip;
         (obsout+n)->rhosinphip=(obsin+k)->rhosinphip;
         (obsout+n)->mag1=(obsin+k)->mag1;
      }
   }
}

void mc_tri1(char *nom_in, char *nom_out)
/***************************************************************************/
/* Genere un fichier de reference pour effectuer un tri croissant.         */
/* Le fichier in comporte deux colonnes : 1/ un indice incremental entier  */
/* 2/ une valeur numerique (decimale) servant de critere de tri.           */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_out;
   int qsort_r[31],qsort_l[31];
   double *valeur,*indice;
   int s,l,r,i,j,n;
   double v,w;
   char ligne[30];

   if (( fichier_in=fopen(nom_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   n=0;
   do {
      if (fgets(ligne,30,fichier_in)!=NULL) {
         n++;
      }
   } while (feof(fichier_in)==0);
   rewind(fichier_in);
   if ((indice = (double *) calloc(n+1,sizeof(double)) )==NULL) {}
   if ((valeur = (double *) calloc(n+1,sizeof(double)) )==NULL) {}
   n=0;
   do {
      if (fgets(ligne,30,fichier_in)!=NULL) {
         n++;
         sscanf(ligne,"%lf %lf",&indice[n],&valeur[n]);
      }
   } while (feof(fichier_in)==0);
   fclose(fichier_in);
   /*--- trie le tableau dans l'ordre croissant ---*/
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=qsort_l[s]; r=qsort_r[s];
      s=s-1;
      do {
         i=l; j=r;
         v=valeur[(int) (floor((l+r)/2))];
         do {
            while (valeur[i]<v) {i++;}
            while (v<valeur[j]) {j--;}
            if (i<=j) {
               w=valeur[i]; valeur[i]=valeur[j]; valeur[j]=w;
               w=indice[i]; indice[i]=indice[j]; indice[j]=w;
               i++; j--;
            }
         } while (i<=j);
         if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   if (( fichier_out=fopen(nom_out,"w") ) == NULL) {
      return;
   }
   for (i=1;i<=n;i++) {
      fprintf(fichier_out,"%.0f %f\n",indice[i],valeur[i]);
   }
   fclose(fichier_out);
   free(valeur);
   free(indice);
}

void mc_tri2(char *nom_in, char *nom_out,char *nom_ref)
/***************************************************************************/
/* Trie les lignes du fichier in pour generer le fichier out a partir      */
/* de l'ordre des indices lus sequentiellement dans le fichier ref         */
/* (genere par mc_tri1).                                                   */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_out,*fichier_ref;
   char ligne[300];
   int k,indice;

   if (( fichier_ref=fopen(nom_ref,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   if (( fichier_in=fopen(nom_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   if (( fichier_out=fopen(nom_out,"w") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   do {
      if (fgets(ligne,300,fichier_ref)!=NULL) {
         sscanf(ligne,"%d",&indice);
         rewind(fichier_in);
         for (k=1;k<=indice;k++) {
            fgets(ligne,300,fichier_in);
         }
         fprintf(fichier_out,"%s",ligne);
      }
   } while (feof(fichier_ref)==0);
   fclose(fichier_ref);
   fclose(fichier_in);
   fclose(fichier_out);
}

int mc_util_comptelignes(char *nom,int *nblignes)
/**************************************************************************/
/* Compte les *nblignes non vides dans le fichier texte *nom              */
/**************************************************************************/
{
   int k;
   FILE *fichier_in ;
   char texte[81],ligne[81],nom_fichier_in[255];

   strcpy(nom_fichier_in,nom);
   if ((fichier_in=fopen(nom_fichier_in, "r") ) == NULL)
      {
      return(PB);
      }
   k=0;
   do
      {
      if (fgets(ligne,80,fichier_in)!=NULL)
         {
         strcpy(texte,"");
         sscanf(ligne,"%s",texte);
         if ( (strcmp(texte,"")!=0) )
            {
            k++;
            }
         }
      }
   while (feof(fichier_in)==0);
   fclose(fichier_in );
   *nblignes=k;
   return(OK);
}

void mc_writeelem(struct elemorb *elem,char *nom_fichier_out)
/***************************************************************************/
/* Ecrit les elements d'orbites sur le disque.                             */
/***************************************************************************/
{
   mc_wri_ele_mpec1(nom_fichier_out,*elem,WRITE);
   /*
   FILE *fichier_out;
   double periode,a;
   if (( fichier_out=fopen(nom_fichier_out,"w") ) == NULL) {
      return;
   }
   fprintf(fichier_out," designation de l'objet    : %s\n",elem->designation);
   fprintf(fichier_out," anomalie moyenne          : %f\n",elem->m0/(DR));
   fprintf(fichier_out," jj de l'anomalie moyenne  : %f\n",elem->jj_m0);
   fprintf(fichier_out," excentricite              : %f\n",elem->e);
   fprintf(fichier_out," distance au perihelie     : %f\n",elem->q);
   fprintf(fichier_out," jj de passage au perihelie: %f\n",elem->jj_perihelie);
   fprintf(fichier_out," inclinaison               : %f\n",elem->i/(DR));
   fprintf(fichier_out," longitude du noeud asc.   : %f\n",elem->o/(DR));
   fprintf(fichier_out," argument du perihelie     : %f\n",elem->w/(DR));
   fprintf(fichier_out," jj equinoxe des elements  : %f\n",elem->jj_equinoxe);
   fprintf(fichier_out," jj epoque des elements    : %f\n",elem->jj_epoque);
   fprintf(fichier_out," type d'objet              : %d\n",elem->type);
   fprintf(fichier_out," magnitude absolue (comete): %f\n",elem->h0);
   fprintf(fichier_out," coef d'activite (comete)  : %f\n",elem->n);
   fprintf(fichier_out," magnitude absolue (aster) : %f\n",elem->h);
   fprintf(fichier_out," coef. de phase (aster)    : %f\n",elem->g);
   if (elem->e!=1) {
      fprintf(fichier_out," \n INFORMATIONS COMPLEMENTAIRES :\n");
      a=elem->q/(1-elem->e);
      fprintf(fichier_out," demi grand axe (ua)       : %f\n",a);
      if (elem->e<1) {
         periode=sqrt(a*a*a);
         fprintf(fichier_out," periode orbitale (ans)    : %f\n",periode);
      }
   } else {
      fprintf(fichier_out,"\n\n\n");
   }
   fprintf(fichier_out," nombre de jours de suivi  : %d\n",elem->nbjours);
   fprintf(fichier_out," nombre d'observations     : %d\n",elem->nbobs);
   fprintf(fichier_out," incertitude initiale      : %e\n",elem->ceu0);
   fprintf(fichier_out," variation d'incertitude   : %e\n",elem->ceut);
   fprintf(fichier_out," jj de l'incertitude init. : %f\n",elem->jj_ceu0);
   fprintf(fichier_out," code type objet colonne 1 : %d\n",elem->code1);
   fprintf(fichier_out," code type objet colonne 2 : %d\n",elem->code2);
   fprintf(fichier_out," code type objet colonne 3 : %d\n",elem->code3);
   fprintf(fichier_out," code type objet colonne 4 : %d\n",elem->code4);
   fprintf(fichier_out," code type objet colonne 5 : %d\n",elem->code5);
   fprintf(fichier_out," code type objet colonne 6 : %d\n",elem->code6);
   fclose(fichier_out);
   */
}
