/* aktcl_1.c
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
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers ak_*.c.                              */
/***************************************************************************/
/* Le include aktcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "aktcl.h"

int Cmd_aktcl_reduceusno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Troncate the USNO-A1 catalog file to a given R magnitude                 */
/****************************************************************************/
/*
load libak ; ak_reduceusno c:/d/usno/ c:/d/usnoshort ZONE0750 10
*/
/****************************************************************************/
{
   char s[1024],pathname_in[1024],pathname_out[1024];
   char zonename[1024],ligne[1024];
   FILE *catin,*catout,*accout;
   int n,nin,nout,noutold;
   int l,raL,deL,magL,raLL,deLL,magLL;
   double rmaglim,ra,de,mag_red,mag_bleue;
   double rah,rah0,drah;
   if(argc<5) {
      sprintf(s,"Usage: %s pathname_in pathname_out zonename rmaglim", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(ligne,argv[1]);
      n=(int)strlen(ligne);
      if (n==0) {
         return TCL_OK;
      }
      if ((ligne[n-1]!='/')||(ligne[n-1]!='\\')) {
         ligne[n]='/';
         ligne[n+1]='\0';
      }
      strcpy(pathname_in,ligne);
      strcpy(ligne,argv[2]);
      n=(int)strlen(ligne);
      if (n==0) {
         return TCL_OK;
      }
      if ((ligne[n-1]!='/')||(ligne[n-1]!='\\')) {
         ligne[n]='/';
         ligne[n+1]='\0';
      }
      strcpy(pathname_out,ligne);
      strcpy(zonename,argv[3]);
      rmaglim=(double)atof(argv[4]);
      /* -- opens the CAT files ---*/
      sprintf(ligne,"%s%s.CAT",pathname_in,zonename);
      if ((catin=fopen(ligne,"rb"))==NULL) {
         sprintf(s,"File %s not found\n",ligne);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      sprintf(ligne,"%s%s.CAT",pathname_out,zonename);
      if ((catout=fopen(ligne,"wb"))==NULL) {
         sprintf(s,"File %s cannot be created\n",ligne);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         fclose(catin);
         return TCL_ERROR;
      }
      /* -- opens the CAT files ---*/
      sprintf(ligne,"%s%s.ACC",pathname_out,zonename);
      if ((accout=fopen(ligne,"wt"))==NULL) {
         sprintf(s,"File %s cannot be created\n",ligne);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         fclose(catin);
         fclose(catout);
         return TCL_ERROR;
      }
      /* -- loop ---*/
      nin=nout=0;
      rah0=0.;
      drah=0.25;
      noutold=1;
      while (feof(catin)==0) {
         if (fread(&raL,1,4,catin)!=4) break;
         if (fread(&deL,1,4,catin)!=4) break;
         if (fread(&magL,1,4,catin)!=4) break;
         l=raL;
         raLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
         l=deL;
         deLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
         l=magL;
         magLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
         ra=(double)raLL/360000.0;
         de=(double)deLL/360000.0-90.0;
         mag_red=ak_GetUsnoRedMagnitude(magLL);
         mag_bleue=ak_GetUsnoBleueMagnitude(magLL);
         if (mag_red<=rmaglim) {
            nout++;
            fwrite(&raL,sizeof(raL),1,catout);
            fwrite(&deL,sizeof(deL),1,catout);
            fwrite(&magL,sizeof(magL),1,catout);
         }
         rah=ra/15.;
         if (rah>rah0+drah) {
            sprintf(ligne,"%5.2f%12d%12d\n",rah0,noutold,nout);
            fwrite(ligne,strlen(ligne),1,accout);
            noutold+=nout;
            rah0+=drah;
         }
         /*
         if (nin>60000) {
            break;
         }
         */
         nin++;
      }
      /* -- close CAT files --*/
      fclose(catin);
      fclose(catout);
      fclose(accout);
      /* -- opens the catout file and create the ACC file TBD */
      sprintf(s,"%d %d",nin,nout);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
   }
}


int Cmd_aktcl_radecinrefzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Extrait les parametres photometriques de l'etoile de coord ra,dec        */
/* On prend l'etoile la plus proche.                                        */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmref  htmref,htmref0;
   struct_htmmes  htmmes;
   FILE *f_in,*f_out;
   double ra0,dec0,ra,dec,distmin,dist2,dra,ddec;
   double dr;
   int codefiltre,codecam;
   if(argc<6) {
      sprintf(s,"Usage: %s htm_generic_fullname out_fullname ra_deg dec_deg codefilter ?codecam?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(generic_filename,argv[1]); /* c:/toto/N012312312 */
      strcpy(path,argv[2]); /* d:/fufu/mystar.txt */
	   ra0=atof(argv[3]);
	   dec0=atof(argv[4]);
      codefiltre=atoi(argv[5]);
      codecam=-1;
      if (argc>=7) {
         codecam=atoi(argv[6]);
      }
      /* --- Recherche l'indice de l'etoile dans le fichier htm_ref.bin ---*/
      sprintf(filename_in,"%s_ref.bin",generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	   distmin=1e30;
	   dr=atan(1)/45.;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
			   dec=htmref.dec;
			   ddec=dec-dec0;
			   ra=htmref.ra;
			   dra=(ra-ra0)*cos(dr*dec0);
            dist2=dra*dra+ddec*ddec;
			   if (dist2<distmin) { 
               distmin=dist2;
               htmref0=htmref;
            }
         }
      }
      fclose(f_in);
      /* --- Extrait des mesures valides de l'etoile de fichier htm_mes.bin ---*/
      sprintf(filename_in,"%s_mes.bin",generic_filename);
      sprintf(filename_out,"%s",path);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            if (htmmes.indexref<htmref0.indexref) {
               continue;
            }
            if (htmmes.indexref>htmref0.indexref) {
               break;
            }
            if (htmmes.indexref==htmref0.indexref) {
               if ((int)htmmes.codefiltre==codefiltre) {
                  if ((codecam<0)||((int)htmmes.codecam==codecam)) {
                     if (htmmes.magcali>-50) {
                        /*
                        fprintf(f_out,"%5d %5d %15.6f %3d %3d %8.4f %8.4f\n",
                        htmmes.indexref,htmmes.indexzmg,htmmes.jd,htmmes.codecam,htmmes.codefiltre,
                        htmmes.maginst,htmmes.magcali);
                        */
                        if (htmmes.jd>2e6) {
                           fprintf(f_out,"%15.6f %8.4f %7.3f %3d\n",
                           htmmes.jd,htmmes.magcali,htmmes.dmag,htmmes.codecam);
                        }
                     }
                  }
               }
            }
         }
      }
      fclose(f_in);
      fclose(f_out);
   }
   return TCL_OK;
}

int Cmd_aktcl_refzmgmes2vars(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* genere les fichiers des etoiles variables                                */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   struct_htmzmg  htmzmg,*htmzmgs=NULL;
   struct_htmref  htmref,*htmrefs=NULL;
   double *val=NULL;
   float *flt_mes=NULL;
   int *ind_refzmg=NULL;
   int *ind_ref=NULL;
   int n_mes,k,kcam,kfil,n_ref,kk,n_zmg,kref,kzmg;
   int n,kkzmg,n_val,n_ref0;
   unsigned char ukcam,ukfil;
   FILE *f_in,*f_out;
   int codes[256][256];
   double mean,sigma,magmax,magmin;
   /*double sigmoy,sigsig;
   int alljd,sigjd,nstar;*/
   /*modif Yassine 10 devient 2*/
   int critvar[2];
   /*fin*/
   double ra,dec;
   /*rajout Yassine*/
   int kvar,critvartot,kkkzmg,k_iter,k_photo,k_backg;
   double somme_sig_photo,somme_moy_photo,somme_sig_backg,somme_moy_backg;
   double val_droite,pente_photo=0,pente_backg=0,ordo_alorigine_photo,ordo_alorigine_backg;
   double ampli;
   int nstarmin = 20;
   /*fin*/

/*
#define DEBUG_refzmgmes2vars
*/
#if defined DEBUG_refzmgmes2vars
FILE *f;
#endif
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename ?nstarmin?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      if (argc>=4) {
          nstarmin=atoi(argv[3]);
      }
      /* --- init des tableaux ---*/
      for (kcam=0;kcam<256;kcam++) {
         for (kfil=0;kfil<256;kfil++) {
            codes[kcam][kfil]=0;
         }
      }
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","wt");
fprintf(f,"On entre dans Cmd_aktcl_refzmgmes2vars\n");
fclose(f);
#endif
      /* --- compte le nombre de dates-filtre dans HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            n_zmg++;
         }
      }
      fclose(f_in);
      if (n_zmg==0) {
         return TCL_OK;
      }
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," n_zmg=%d\n",n_zmg);
fclose(f);
#endif
      /* --- alloue la memoire ---*/
      htmzmgs=(struct_htmzmg*)malloc(n_zmg*sizeof(struct_htmzmg));
      if (htmzmgs==NULL) {
         sprintf(s,"error : htmzmgs pointer out of memory (%d elements)",n_zmg);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- lecture de htmzmgs a partir de HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            htmzmgs[k]=htmzmg;
            k++;
         }
      }
      fclose(f_in);
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      n_mes=0;
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            codes[(int)htmmes.codecam][(int)htmmes.codefiltre]++;
            n_mes++;
            if (htmmes.indexzmg>n_zmg) {
               n_zmg=htmmes.indexzmg;
            }
         }
      }
      n_ref=htmmes.indexref+1;
      n_zmg+=1;
      fclose(f_in);
      if (n_mes==0) {
         free(htmzmgs);
         return TCL_OK;
      }
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," n_ref=%d\n",n_ref);
fprintf(f," n_zmg=%d\n",n_zmg);
fclose(f);
#endif
      /* --- alloue la memoire pour htmmess---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      /* --- on dimensionne la matrice x=indexref y=indexjd val=kmes */
      /*     ce tableau est utile pour circuler rapidement dans htmmess */
      n=n_ref*n_zmg;
      ind_refzmg=(int*)calloc(n,sizeof(int));
      if (ind_refzmg==NULL) {
         sprintf(s,"error : ind_refzmg pointer out of memory (%d elements)",n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      for (k=0;k<n;k++) { 
         ind_refzmg[k]=-1;
      }
      /* --- lecture des donnees pour htmmess ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmess[k]=htmmes;
            ind_refzmg[htmmes.indexref*n_zmg+htmmes.indexzmg]=k;
            k++;
         }
      }
      fclose(f_in);
      /* --- on dimensionne le tableau de l'histogramme ---*/
      flt_mes=(float*)calloc(n_ref*AK_FLTMES,sizeof(float));
      if (flt_mes==NULL) {
         sprintf(s,"error : flt_mes pointer out of memory (%d elements)",n_ref*AK_FLTMES);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      /* --- compte le nombre d'etoiles dans HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_ref0=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            n_ref0++;
         }
      }
      fclose(f_in);
      if (n_ref0==0) {
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         return TCL_OK;
      }
      /* --- on dimensionne un vecteur pour les tris ---*/
      n_val=(n_ref>n_zmg)?n_ref:n_zmg;
      n_val=(n_ref0>n_val)?n_ref0:n_val;
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," n_ref0=%d\n",n_ref0);
fprintf(f," n_val=%d\n",n_val);
fclose(f);
#endif
      val=(double*)malloc(n_val*sizeof(double));
      if (val==NULL) {
         sprintf(s,"error : val pointer out of memory (%d elements)",n_val);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         return TCL_ERROR;
      }
      /* --- alloue la memoire ---*/
      htmrefs=(struct_htmref*)malloc(n_ref0*sizeof(struct_htmref));
      if (htmrefs==NULL) {
         sprintf(s,"error : htmrefs pointer out of memory (%d elements)",n_ref0);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         free(val);
         return TCL_ERROR;
      }
      ind_ref=(int*)malloc(n_ref0*sizeof(int));
      if (ind_ref==NULL) {
         sprintf(s,"error : ind_ref pointer out of memory (%d elements)",n_ref0);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         free(val);
		 free(htmrefs);
         return TCL_ERROR;
      }
      /* --- lecture de htms a partir de HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         free(val);
		 free(htmrefs);
         free(ind_ref);
         return TCL_ERROR;
      }
      k=0;
	  while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            htmrefs[k]=htmref;
            val[k]=(double)htmref.indexref;
            ind_ref[k]=k;
            k++;
         }
      }
      fclose(f_in);
      ak_util_qsort_double(val,0,n_ref0,ind_ref);
      /* === grande boucle sur les cam+filtre ===*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," GRANDE BOUCLE\n");
fclose(f);
#endif
      for (kcam=0;kcam<256;kcam++) {
         ukcam=(unsigned char)kcam;
         for (kfil=0;kfil<256;kfil++) {
            ukfil=(unsigned char)kfil;
			/*Modif Yassine : puisqu'on exige 10 mes pour 1 seule �toile
			if (codes[kcam][kfil]<2) {*/
			if (codes[kcam][kfil]<11) {
			/*fin*/
                /* --- Pas assez de mesures faites avec cette combinason cam+filtre ---*/
                continue;
			}
			if (ukfil==66) {
				pente_photo=pente_photo_B;
                pente_backg=pente_backg_B;
			} else if (ukfil==67) {
				pente_photo=pente_photo_C;
                pente_backg=pente_backg_C;
			} else if (ukfil==73) {
				pente_photo=pente_photo_I;
                pente_backg=pente_backg_I;
			} else if (ukfil==82) {
				pente_photo=pente_photo_R;
                pente_backg=pente_backg_R;
			} else if (ukfil==86) {
				pente_photo=pente_photo_V;
                pente_backg=pente_backg_V;
			}
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"   kcam=%d  kfil=%d\n",kcam,kfil);
fclose(f);
#endif
            /* --- on commence par initialiser l'histogramme des mesures ---*/
            for (k=0;k<n_ref;k++) {
               flt_mes[AK_NJD*n_ref+k]=(float)0;
            }			
			/* --- on remplit l'histogramme des mesures ---*/
            for (k=0;k<n_mes;k++) {
               if (htmmess[k].codecam!=ukcam) {
                  continue;
               }
               if (htmmess[k].codefiltre!=ukfil) {
                  continue;
               }
               flt_mes[AK_NJD*n_ref+htmmess[k].indexref]+=1.;
            }
            /* --- valeur moyenne et sigma de la magnitude des etoiles ---*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"   VALEUR MOYENNE\n");
fclose(f);
#endif
            for (kref=0;kref<n_ref;kref++) {
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"     kref=%d n_ref=%d\n",kref,n_ref);
fclose(f);
#endif
               /* --- init le vecteur ---*/
               flt_mes[AK_MAGMOY*n_ref+kref]=(float)-99.9;
               flt_mes[AK_SIGMOY*n_ref+kref]=(float)0;
               flt_mes[AK_ALLJD*n_ref+kref]=(float)0;
               flt_mes[AK_SIGJD*n_ref+kref]=(float)0;
			   /*rajout Yassine*/
			   flt_mes[AK_AMPLI*n_ref+kref]=(float)0;
			   flt_mes[AK_FIT*n_ref+kref]=(float)1000;
			   /*fin*/
               /* --- l'etoile doit etre observee au moins 10 fois ---*/
               /*Modif Yassine
			   if (flt_mes[AK_NJD*n_ref+kref]>=(float)3) {*/
               if (flt_mes[AK_NJD*n_ref+kref]>=(float)10) {
			   /*fin*/
                  kk=0;
                  /* --- boucle sur les seuls elements de htmmes concernes ---*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"     DEBUT DE BOUCLE SUR LES DATES\n");
fclose(f);
#endif
                  for (kzmg=0;kzmg<n_zmg;kzmg++) {
                     kkzmg=htmzmgs[kzmg].indexzmg;
                     k=ind_refzmg[kref*n_zmg+kkzmg];
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"       kref=%d kzmg=%d kkzmg=%d k=%d\n",kref,kzmg,kkzmg,k);
fclose(f);
#endif
                     /* --- l'etoile doit etre observee pour cette date ---*/
                     if (k>=0) {
						/* --- l'observation doit etre faite avec les bons filtres ---*/
                        if (htmmess[k].codefiltre!=ukfil) {
                           continue;
						}
                        if (htmmess[k].codecam!=ukcam) {
                           continue;
						}
                        /* --- la mesure de la magnitude doit avoir un sens a cette date ---*/
                        if ((double)htmmess[k].magcali>=-50.0) {
                           /*Modif Yassine
						   val[kk]=(double)htmmess[k].maginst;*/
						   val[kk]=(double)htmmess[k].magcali;
						   /*fin*/
                           kk++;
                        }
                     }
                  }
                  n=kk;
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"     FIN DE BOUCLE SUR LES DATES\n");
fprintf(f,"     n=%d\n",n);
fclose(f);
#endif
                  /*Modif Yassine: Au moins 10 mesures valables
                  if (n>=3) {*/
                  if (n>=10) {
                     /* --- moyenne et ecart type ---*/
                     ak_util_meansigma(val,0,n,&mean,&sigma);
                     flt_mes[AK_MAGMOY*n_ref+kref]=(float)mean;
					 if (mean<-50.) {
						 continue;
					 }
					 /*fin*/
                     flt_mes[AK_SIGMOY*n_ref+kref]=(float)sigma;
                     flt_mes[AK_ALLJD*n_ref+kref]=(float)n;
					 /*rajout Yassine : pour avoir l'amplitude*/
					 ak_util_qsort_double(val,0,n,NULL);
					 ampli = val[n-1]-val[0];
					 flt_mes[AK_AMPLI*n_ref+kref]=(float)ampli;
					 /*fin*/
                     /* --- nb de mesures superieures a 3*sigma ---*/
                     magmax=mean+3*sigma;
                     magmin=mean-3*sigma;
                     kk=0;
                     for (k=0;k<n;k++) {
                        if (val[k]<magmin) kk++;
                        if (val[k]>magmax) kk++;
                     }
                     flt_mes[AK_SIGJD*n_ref+kref]=(float)kk;
                  }
               }
            }
			
			k_iter=0;
			while (k_iter<NB_ITER) {
				somme_sig_photo=0;
				somme_moy_photo=0;
				somme_sig_backg=0;
				somme_moy_backg=0;
				k_photo=0;
				k_backg=0;
				for (kref=0;kref<n_ref;kref++) {
					mean=(double)flt_mes[AK_MAGMOY*n_ref+kref];
					sigma=(double)flt_mes[AK_SIGMOY*n_ref+kref];
					val_droite=(double)flt_mes[AK_FIT*n_ref+kref]*XMOYFIT;
					/*La combinaison mean>-99.9 avec val_droite nous �vite de prendre de mauvais points*/
					/*Au debut je prends tous les points car val_droite=1000 partout*/
					if (sigma<val_droite) {
						if ((mean<=MAG_PHOTO)&&(mean>-99.9)) {
							somme_sig_photo=somme_sig_photo+log(sigma);
							somme_moy_photo=somme_moy_photo+mean;
                            k_photo++;
						} else if ((mean<MAG_BACKG)&&(mean>MAG_PHOTO)) {
							somme_sig_backg=somme_sig_backg+log(sigma);
							somme_moy_backg=somme_moy_backg+mean;
							k_backg++;
						}
					}
				}
				ordo_alorigine_photo=(somme_sig_photo-pente_photo*somme_moy_photo)/k_photo;
				ordo_alorigine_backg=(somme_sig_backg-pente_backg*somme_moy_backg)/k_backg;
                for (kref=0;kref<n_ref;kref++) {
					mean=(double)flt_mes[AK_MAGMOY*n_ref+kref];
					if (mean>-99.9) {
                        val_droite=sqrt(exp(2*(pente_photo*mean+ordo_alorigine_photo))+exp(2*(pente_backg*mean+ordo_alorigine_backg)));
						flt_mes[AK_FIT*n_ref+kref]=(float)val_droite;
					}
				}
                k_iter++;
			}
			for (kref=0;kref<n_ref;kref++) {
				/*Init de critvar*/
				for (kvar=0;kvar<2;kvar++) {
                    critvar[kvar]=0;
				}
				mean=(double)flt_mes[AK_MAGMOY*n_ref+kref];
				sigma=(double)flt_mes[AK_SIGMOY*n_ref+kref];
				val_droite=(double)flt_mes[AK_FIT*n_ref+kref]*XMOY;
				ampli=(float)flt_mes[AK_AMPLI*n_ref+kref];
				n=(int)flt_mes[AK_ALLJD*n_ref+kref];
				if ((sigma>=val_droite)&&(ampli>sigma)&&(n>=nstarmin)) {
                    critvar[0]=1;
				}
				/*sigjd=(int)flt_mes[AK_SIGJD*n_ref+num_etoi];
                alljd=(int)flt_mes[AK_ALLJD*n_ref+num_etoi];
				if ((100.*(double)sigjd/(double)alljd>(100.-99.8))&&(alljd>100)) {
					critvar[1]=0;
				}*/
				critvar[1]=0;
				critvartot=critvar[0];/*+critvar[1];*/
                if (critvartot>0) {
                    ra=(double)htmrefs[ind_ref[kref]].ra;
                    dec=(double)htmrefs[ind_ref[kref]].dec;
                    /* --- ouvre le fichier de sortie ---*/
                    sprintf(filename_out,"%sTN-%s-%d-%d-%d.txt",path,generic_filename,kref,kfil,kcam);
                    f_out=fopen(filename_out,"wt");
				    if (f_out==NULL) {
						free(htmzmgs);
                        free(htmmess);
                        free(ind_refzmg);
                        free(flt_mes);
                        free(val);
                        free(htmrefs);
                        free(ind_ref);
					}
                    /*             123456789 12345678 */
                    fprintf(f_out,"NAME      = TN-%s-%d \n",generic_filename,kref);
                    fprintf(f_out,"RA        = %10.6f \n",ra);
                    fprintf(f_out,"DEC       = %10.6f \n",dec);
                    fprintf(f_out,"EQUINOX   = J2000.0 \n");
                    /*fprintf(f_out,"FILTERNO= %u \n",ukfil);*/
                    fprintf(f_out,"FILTER    = %c \n",ukfil);
                    fprintf(f_out,"CAMERANO  = %u \n",ukcam);
                    fprintf(f_out,"TAROT     = CALERN \n");
                    /*fprintf(f_out,"CRITVAR1= %d \n",critvar[1]);*/
                    fprintf(f_out,"MEAN      = %f \n",mean);
                    fprintf(f_out,"SIGMA     = %f \n",sigma);
                    fprintf(f_out,"AMPLITUDE = %f \n",ampli);
                    /*fprintf(f_out,"SIGMOY  = %f \n",sigmoy);
                    fprintf(f_out,"SIGSIG    = %f \n",sigsig);*/
                    fprintf(f_out,"CRITVAR   = %f \n",val_droite);
                    /*fprintf(f_out,"ALLJD   = %d \n",alljd);
                    fprintf(f_out,"SIGJD     = %d \n",sigjd);
                    fprintf(f_out,"PERCENT   = %f \n",100.*(double)sigjd/(double)alljd);*/
                    fprintf(f_out,"END\n");
                    /* --- boucle sur les seuls elements de htmmes concernes ---*/
                    for (kzmg=0;kzmg<n_zmg;kzmg++) {
						kkzmg=htmzmgs[kzmg].indexzmg;
                        kkkzmg=ind_refzmg[kref*n_zmg+kkzmg];
					    if (kkkzmg>=0) {
							htmmes=htmmess[kkkzmg];
                            if (htmmes.codefiltre!=ukfil) {
								continue;
						    }
                            if (htmmes.codecam!=ukcam) {
                                continue;
							}
                            if (htmmes.magcali>=-50.) {
                                /* --- on imprime les caracteristiques ---*/
                                fprintf(f_out,"%15.6f %7.3f %5.3f %3d\n",
                                htmmes.jd,htmmes.magcali,htmmes.dmag,htmmes.flag);
							}
						}
                    }
					fclose(f_out);
				}
			}

#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"   FIN DE PETITE BOUCLE\n");
fclose(f);
#endif
         }
      }
      /* === fin de la grande boucle sur les cam+filtre ===*/
      /* --- Libere la memoire ---*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," DEBUT DES FREE\n");
fclose(f);
#endif
      free(htmzmgs);
      free(htmmess);
      free(ind_refzmg);
      free(flt_mes);
      free(val);
      free(htmrefs);
      free(ind_ref);
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," FIN DES FREE\n");
fclose(f);
#endif
   }
   return TCL_OK;
}

int Cmd_aktcl_updatezmg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* mise a jour du fichier htm_zmg.bin                                       */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/* cmag est mis a jour.                                                     */
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   struct_htmzmg  htmzmg,*htmzmgs=NULL;
   double *val=NULL;
   double cmag;
   float *flt_mes=NULL;
   int *ind_refzmg=NULL;
   int n_mes,k,kcam,kfil,n_ref,kk,n_zmg,kref,kzmg;
   float maxik,maxik0,magmed;
   int n_selec_ref,n,kkzmg,n_val;
   unsigned char ukcam,ukfil;
   double magmax;
   double magsaturated,magtoofaint;
   FILE *f_in,*f_out;
   int codes[256][256];
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename ?magsaturated? ?magtoofaint?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      magsaturated=-99.9;
      if (argc>=4) {
         magsaturated=(double)atof(argv[3]);
      } 
      magtoofaint=1e10;
      if (argc>=5) {
         magtoofaint=(double)atof(argv[4]);
      } 
      /* --- init des tableaux ---*/
      for (kcam=0;kcam<256;kcam++) {
         for (kfil=0;kfil<256;kfil++) {
            codes[kcam][kfil]=0;
         }
      }
      /* --- compte le nombre de dates-filtre dans HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            n_zmg++;
         }
      }
      fclose(f_in);
      if (n_zmg==0) return TCL_OK;
      /* --- alloue la memoire ---*/
      htmzmgs=(struct_htmzmg*)malloc(n_zmg*sizeof(struct_htmzmg));
      if (htmzmgs==NULL) {
         sprintf(s,"error : htmzmgs pointer out of memory (%d elements)",n_zmg);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- lecture de htmzmgs a partir de HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            htmzmgs[k]=htmzmg;
            k++;
         }
      }
      fclose(f_in);
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      n_mes=0;
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            codes[(int)htmmes.codecam][(int)htmmes.codefiltre]++;
            n_mes++;
            if (htmmes.indexzmg>n_zmg) {
               n_zmg=htmmes.indexzmg;
            }
         }
      }
      n_ref=htmmes.indexref+1;
      n_zmg+=1;
      fclose(f_in);
      if (n_mes==0) return TCL_OK;
      /* --- alloue la memoire pour htmmess---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      /* --- on dimensionne la matrice x=indexref y=indexjd val=kmes */
      /*     ce tableau est utile pour circuler rapidement dans htmmess */
      n=n_ref*n_zmg;
      ind_refzmg=(int*)calloc(n,sizeof(int));
      if (ind_refzmg==NULL) {
         sprintf(s,"error : ind_refzmg pointer out of memory (%d elements)",n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      for (k=0;k<n;k++) { 
         ind_refzmg[k]=-1;
      }
      /* --- lecture des donnees pour htmmess ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmess[k]=htmmes;
            ind_refzmg[htmmes.indexref*n_zmg+htmmes.indexzmg]=k;
            k++;
         }
      }
      fclose(f_in);
      /* --- on dimensionne le tableau de l'histogramme ---*/
      flt_mes=(float*)calloc(n_ref*2,sizeof(float));
      if (flt_mes==NULL) {
         sprintf(s,"error : flt_mes pointer out of memory (%d elements)",n_ref*2);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      /* --- on dimensionne un vecteur pour les tris ---*/
      n_val=(n_ref>n_zmg)?n_ref:n_zmg;
      val=(double*)malloc(n_val*sizeof(double));
      if (val==NULL) {
         sprintf(s,"error : val pointer out of memory (%d elements)",n_val);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         return TCL_ERROR;
      }
      /* === grande boucle sur les cam+filtre ===*/
      for (kcam=0;kcam<256;kcam++) {
         ukcam=(unsigned char)kcam;
         for (kfil=0;kfil<256;kfil++) {
            ukfil=(unsigned char)kfil;
            if (codes[kcam][kfil]<2) {
               /* --- Pas assez de mesures faites avec cette combinason cam+filtre ---*/
               continue;
            }
            /* --- on commence par initialiser l'histogramme des mesures ---*/
            for (k=0;k<n_ref;k++) {
               flt_mes[k]=(float)0;
			   /*Rajout Yassine : par simple pr�caution*/
			   flt_mes[n_ref+k]=(float)-99.9;
			   /*fin*/
            }
            /* --- on remplit l'histogramme des mesures ---*/
            for (k=0;k<n_mes;k++) {
               if (htmmess[k].codecam!=ukcam) {
                  continue;
               }
               if (htmmess[k].codefiltre!=ukfil) {
                  continue;
               }
			   /*Rajout Yassine : Pour le flag Sextractor*/
			   if (htmmess[k].flag==0) {
			   /*fin*/
			       flt_mes[htmmess[k].indexref]+=1.;
			   }

            }
            /* --- on recherche la valeur maximale de l'histogramme ---*/
            maxik=(float)0;
            for (k=0;k<n_ref;k++) {
               if (flt_mes[k]>maxik) {
                  maxik=flt_mes[k];
               }
            }
            /* --- on compte toutes les etoiles qui sont > 0.8*maxi ---*/
            maxik0=(float)(maxik*0.8);
            n_selec_ref=0;
            for (k=0;k<n_ref;k++) {
               if (flt_mes[k]>maxik0) {
                  n_selec_ref++;
                  flt_mes[n_ref+k]=(float)1.;
               } else {
                  flt_mes[n_ref+k]=(float)-99.9;
               }
            }
            /* 
            load libak ; ak_updatezmg c:/d/tarot/tarot6/f/pretraite/im/rrlyr/ N111120220 8 15 ; ak_refzmgmes2ascii c:/d/tarot/tarot6/f/pretraite/im/rrlyr/ N111120220 
            */
            if (n_selec_ref<4) continue;
            /* --- valeur mediane de la magnitude des etoiles selectionnees ---*/
            for (kref=0;kref<n_ref;kref++) {
               /* --- l'etoile doit etre selectionnee pour le calcul de la mediane ---*/
               if (flt_mes[n_ref+kref]>0.) {
                  kk=0;
                  /* --- boucle sur les seuls elements de htmmes concernes ---*/
                  for (kzmg=0;kzmg<n_zmg;kzmg++) {
                     kkzmg=htmzmgs[kzmg].indexzmg;
                     k=ind_refzmg[kref*n_zmg+kkzmg];
                     if (k>=0) {
                        if (htmmess[k].codefiltre!=ukfil) {
                           continue;
                        }
                        if (htmmess[k].codecam!=ukcam) {
                           continue;
                        }
						/*Rajout Yassine : Pour le flag Sextractor*/
						if (htmmess[k].flag==0) {
						/*fin*/
                            val[kk]=(double)htmmess[k].maginst;
                            kk++;
						}
                     }
                  }
                  n=kk;
                  if (n<3) {
                     flt_mes[n_ref+kref]=(float)-99.9;
                  } else {
                     /* --- on trie les donnees ---*/
                     ak_util_qsort_double(val,0,n,NULL);
                     /* --- indice de la valeur mediane ---*/
                     k=(n+1)/2;
                     flt_mes[n_ref+kref]=(float)val[k];
                  }
               }
            }
            /* --- on va determiner automatiquement les seuils de magnitude */
            for (kref=0;kref<n_ref;kref++) {
               magmed=flt_mes[n_ref+kref];
               val[kref]=magmed;
            }
            /* on trie les donnees */
            ak_util_qsort_double(val,0,n_ref,NULL);
            /* seules les val[n_ref-n_selec_ref] a val[n_ref-1] sont valables */
            kk=0;
            magmax=1e10;
            for (k=n_ref-n_selec_ref;k<n_ref;k++) {
               if (val[k]>magsaturated) {
                  kk++;
               }
               if (kk>12) {
                  magmax=val[k];
               }
            }
            /* --- CMAG = valeur mediane de la difference de magnitudes */
            /*     (mediane - instrumentale) des etoiles selectionnees ---*/
            for (kzmg=0;kzmg<n_zmg;kzmg++) {
               kkzmg=htmzmgs[kzmg].indexzmg;
               if (htmzmgs[kkzmg].codefiltre!=ukfil) {
                  continue;
               }
               kk=0;
			   /* --- boucle sur les seuls elements de htmmes concernes ---*/
               for (kref=0;kref<n_ref;kref++) {
				  magmed=flt_mes[n_ref+kref];
                  /*Modif Yassine
				  if ((magmed<magsaturated)) {*/
				  if ((magmed<=magsaturated)) {
				  /*fin*/
                     /* l'etoile risque de saturer */
                     continue;
                  }
                  /*Modif Yassine
				  if ((magmed>magtoofaint)||(magmed>magmax)) {*/
				  if ((magmed>=magtoofaint)||(magmed>magmax)) {
			      /*fin*/
                     /* l'etoile est trop faible */
                     continue;
                  }
				  k=ind_refzmg[kref*n_zmg+kkzmg];
                  if (k>=0) {
                     if (htmmess[k].codefiltre!=ukfil) {
                        continue;
                     }
                     if (htmmess[k].codecam!=ukcam) {
                        continue;
                     }
					 /*Rajout Yassine : Pour le flag Sextractor*/
			         if (htmmess[k].flag==0) {
			         /*fin*/
                         val[kk]=(double)(magmed-htmmess[k].maginst);
                         kk++;
					 }
                  }
               }
               n=kk;
               if (n<5) {
                  htmzmgs[kkzmg].cmag=(float)-99.9;
               } else {
                  /* --- on trie les donnees ---*/
                  ak_util_qsort_double(val,0,n,NULL);
                  /* --- indice de la valeur mediane ---*/
                  k=(n+1)/2;
                  htmzmgs[kkzmg].cmag=(float)val[k];
               }
            }
         }
      }
      /* === fin de la grande boucle sur les cam+filtre ===*/
      sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename);
      f_out=fopen(filename_out,"wb");
      for (k=0;k<n_zmg;k++) {
         fwrite(&htmzmgs[k],1,sizeof(struct_htmzmg),f_out);
      }
      fclose(f_out);
      sprintf(filename_out,"%s%s_mes.bin",path,generic_filename);
      f_out=fopen(filename_out,"wb");
      for (k=0;k<n_mes;k++) {
         kkzmg=htmmess[k].indexzmg;
         cmag=(double)htmzmgs[kkzmg].cmag;
         if (cmag>-50.) {
            htmmess[k].magcali=htmmess[k].maginst+(float)cmag;
         } else {
            htmmess[k].magcali=(float)-99.9;
         }
         fwrite(&htmmess[k],1,sizeof(struct_htmmes),f_out);
      }
      fclose(f_out);
      /* --- Libere la memoire ---*/
      free(htmzmgs);
      free(htmmess);
      free(ind_refzmg);
      free(val);
      free(flt_mes);
   }
   return TCL_OK;
}

int Cmd_aktcl_sortmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Trie les mesures selon les indices d'etoile et selon les dates.          */
/* Mise a jour du fichier htm_mes.bin                                       */
/* a partir du fichier htm_mes.bin                                          */
/****************************************************************************/
/* Doit etre effectue apres une serie de ak_file2refzmgmes et avant updates */
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   int *ind_ind_mes=NULL;
   double *val_ind_mes=NULL;
   int n_mes,k;
   FILE *f_in,*f_out;
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_mes=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            n_mes++;
         }
      }
      fclose(f_in);
      if (n_mes==0) return TCL_OK;
      /* --- alloue la memoire ---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_ind_mes=(int*)malloc(n_mes*sizeof(int));
      if (ind_ind_mes==NULL) {
         sprintf(s,"error : ind_ind_mes pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmmess);
         return TCL_ERROR;
      }
      val_ind_mes=(double*)malloc(n_mes*sizeof(double));
      if (val_ind_mes==NULL) {
         sprintf(s,"error : val_ind_mes pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmmess);
         free(ind_ind_mes);
         return TCL_ERROR;
      }
      /* --- lecture des donnees ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmess[k]=htmmes;
            sprintf(s,"%d%f",htmmes.indexref,htmmes.jd);
            val_ind_mes[k]=(double)atof(s);
            ind_ind_mes[k]=k;
            k++;
         }
      }
      fclose(f_in);
      /* --- on trie les donnees ---*/
      ak_util_qsort_double(val_ind_mes,0,n_mes,ind_ind_mes);
      /* --- ecriture des donnees triees ---*/
      sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename);
      f_out=fopen(filename_out,"wb");
      if (f_out==NULL) {
         sprintf(s,"filename_out %s not found",filename_out);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      for (k=0;k<n_mes;k++) {
         fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
      }
      fclose(f_out);
      /* --- on renome le fichier ---*/
      sprintf(filename_in,"%s%s_mes.bin0",path,generic_filename);
      sprintf(filename_out,"%s%s_mes.bin",path,generic_filename);
      remove(filename_out);
      rename(filename_in,filename_out);
      /* --- libere la memoire ---*/
      free(val_ind_mes);
      free(ind_ind_mes);
      free(htmmess);
   }
   return TCL_OK;
}

int Cmd_aktcl_refzmgmes2ascii(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Genere les trois fichiers htm_ref.txt, htm_zmg.txt, htm_ref.txt,         */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/* Fonction utile pour le debuggogage.                                      */
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmref  htmref;
   struct_htmzmg  htmzmg;
   struct_htmmes  htmmes;
   FILE *f_in,*f_out;
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      /* --- transcode le fichier htm_ref.bin => htm_ref.txt  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      sprintf(filename_out,"%s%s_ref.txt",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            fprintf(f_out,"%5d %5d %10.6f %10.6f %3d %3d %8.4f %3d %3d %8.4f %3d %3d %8.4f %3d %3d %8.4f\n",
               htmref.indexref,htmref.nbmes,htmref.ra,htmref.dec,
               htmref.codecat[0],htmref.codefiltre[0],htmref.mag[0],
               htmref.codecat[1],htmref.codefiltre[1],htmref.mag[1],
               htmref.codecat[2],htmref.codefiltre[2],htmref.mag[2],
               htmref.codecat[3],htmref.codefiltre[3],htmref.mag[3]);
         }
      }
      fclose(f_in);
      fclose(f_out);
      /* --- transcode le fichier htm_zmg.bin => htm_zmg.txt  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      sprintf(filename_out,"%s%s_zmg.txt",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
             /*Modif Yassine annulee
			 fprintf(f_out,"%5d %15.6f %3d %8.4f %6.2f %5.3f\n",
               htmzmg.indexzmg,htmzmg.jd,htmzmg.codefiltre,htmzmg.cmag,htmzmg.exposure,htmzmg.airmass);*/
			 fprintf(f_out,"%5d %15.6f %2d %3d %8.4f %6.2f %5.3f\n",
               htmzmg.indexzmg,htmzmg.jd,htmzmg.codecam,htmzmg.codefiltre,htmzmg.cmag,htmzmg.exposure,htmzmg.airmass);
              /*fin*/
         }
      }
      fclose(f_in);
      fclose(f_out);
      /* --- transcode le fichier htm_mes.bin => htm_mes.txt  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      sprintf(filename_out,"%s%s_mes.txt",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            /*modif Yassine
			fprintf(f_out,"%5d %5d %15.6f %3d %3d %8.4f %8.4f\n",
            htmmes.indexref,htmmes.indexzmg,htmmes.jd,htmmes.codecam,htmmes.codefiltre,
            htmmes.maginst,htmmes.magcali);*/
            fprintf(f_out,"%5d %5d %15.6f %3d %3d %8.4f %8.4f %5.3f %3d\n",
            htmmes.indexref,htmmes.indexzmg,htmmes.jd,htmmes.codecam,htmmes.codefiltre,
            htmmes.maginst,htmmes.magcali,htmmes.dmag,htmmes.flag);
			/*fin*/
         }
      }
      fclose(f_in);
      fclose(f_out);
   }
   return TCL_OK;
}

int Cmd_aktcl_filehtm2refzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Genere les trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin,         */
/* a partir d'un fichier texte de catalogue d'observation d'un HTM donne.   */
/****************************************************************************/
/* Input : (issu de ak_file2htm                                             */
/* ra dec jd codecam codefiltre maginst exposure airmass dmag(en binaires)  */
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char filename_in[1024],generic_filename_out[1024],filename_out[1024];
   FILE *f_in,*f_out;
   int n,n_file,n_ref,n_zmg;
   int k,k_file,k_ref,k_zmg,sortie;
   struct_htmfile htmfile,*htmfiles=NULL;
   struct_htmref  htmref, *htmrefs=NULL;
   struct_htmzmg  htmzmg, *htmzmgs=NULL;
   struct_htmmes  htmmes, *htmmess=NULL;
   int *ind_dec_file=NULL,*ind_dec_ref=NULL,*ind_jd_zmg=NULL,*ind_ind_mes=NULL;
   double *val_dec_file=NULL,*val_dec_ref=NULL,*val_jd_zmg=NULL,*val_ind_mes=NULL;
   int newref=0,newzmg=0;
   int newreffiltre,index_ref,index_zmg,index_mes;
   double dec0,ra0,dec,ra,cosdec0;
   double dr,ddec,dra,dangle,dangle2;
   int k_ref1,k_ref2,k_ref_prog;
   int saveref=0,savezmg=0,savemes=0;
   int k_zmg1,k_zmg2;
   double djd,jd,jd0;
   unsigned char codefiltre0;
   float exposure0,airmass0;
   /* rajout Yassine*/
   unsigned char codecam0;
   unsigned char flagsext0;
   float dmag0;
   int nouvdate;
   /*fin*/
   int index_in=0;
   double jd_in=0.;
   unsigned char codecam_in=0x00,codefiltre_in=0x00;
   int index_out;
   double jd_out;
   unsigned char codecam_out,codefiltre_out;
   int lecture,sortie2;

   if(argc<5) {
      sprintf(s,"Usage: %s filename_in path generic_filename_out angle", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(filename_in,argv[1]);
      strcpy(path,argv[2]);
      strcpy(generic_filename_out,argv[3]);
      dr=4*atan(1.)/180.;
      dangle=fabs(atof(argv[4]));
      if (dangle==0) { dangle=10.; }
      dangle2=dangle*dangle;
      /* --- decode le fichier input ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n=0;
      do {
         fread(&htmfile,1,sizeof(struct_htmfile),f_in);
         n++;
      } while (feof(f_in)==0) ;
      fclose(f_in);
      n--;
      n_file=n;
      htmfiles=(struct_htmfile*)malloc(n*sizeof(struct_htmfile));
      if (htmfiles==NULL) {
         sprintf(s,"error : htmfiles pointer out of memory (%d elements)",n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_in=fopen(filename_in,"rb");
      for (k=0;k<n;k++) {
         fread(&htmfiles[k],1,sizeof(struct_htmfile),f_in);
      }
      fclose(f_in);
      /* --- decode le fichier HTM_ref.bin ---*/
      sprintf(filename_out,"%s%s_ref.bin",path,generic_filename_out);
      f_out=fopen(filename_out,"rb");
      n=0;
      if (f_out!=NULL) {
         do {
            fread(&htmref,1,sizeof(struct_htmref),f_out);
            n++;
         } while (feof(f_out)==0) ;
         fclose(f_out);
         n--;
      }
      n_ref=n;
      n+=n_file;
      if (n>0) {
         htmrefs=(struct_htmref*)malloc(n*sizeof(struct_htmref));
         if (htmrefs==NULL) {
            sprintf(s,"error : htmrefs pointer out of memory (%d elements)",n);
            free(htmfiles);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         if (n_ref>0) {
            f_in=fopen(filename_out,"rb");
            for (k=0;k<n_ref;k++) {
               fread(&htmrefs[k],1,sizeof(struct_htmref),f_out);
            }
            fclose(f_out);
         }
      }
      /* --- decode le fichier HTM_zmg.bin ---*/
      sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename_out);
      f_out=fopen(filename_out,"rb");
      n=0;
      if (f_out!=NULL) {
         do {
            fread(&htmzmg,1,sizeof(struct_htmzmg),f_out);
            n++;
         } while (feof(f_out)==0) ;
         fclose(f_out);
         n--;
      }
      n_zmg=n;
	  /*Modif Yassine : on va rajouter une date au plus
	  n+=n_file;*/
	  n+=1;
	  /*fin*/
      if (n>0) {
         htmzmgs=(struct_htmzmg*)malloc(n*sizeof(struct_htmzmg));
         if (htmzmgs==NULL) {
            sprintf(s,"error : htmzmgs pointer out of memory (%d elements)",n);
            free(htmfiles);
            free(htmrefs);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         if (n_zmg>0) {
            f_in=fopen(filename_out,"rb");
            for (k=0;k<n_zmg;k++) {
               fread(&htmzmgs[k],1,sizeof(struct_htmzmg),f_out);
            }
            fclose(f_out);
         }
      }
      /* --- tri de filehtm selon les DEC croissantes ---*/
      n=n_file;
      val_dec_file=(double*)malloc((n+1)*sizeof(double));
      if (val_dec_file==NULL) {
         sprintf(s,"error : val_dec_file pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_dec_file=(int*)malloc((n+1)*sizeof(int));
      if (val_dec_file==NULL) {
         sprintf(s,"error : ind_dec_file pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  if (n_file>0) {
         n=n_file;
         for (k=0;k<n;k++) {
            val_dec_file[k]=htmfiles[k].dec;
            ind_dec_file[k]=k;
         }
         ak_util_qsort_double(val_dec_file,0,n,ind_dec_file);         
      }
      /* --- tri de ref selon les DEC croissantes ---*/
      n=n_ref;
      n+=n_file;
      val_dec_ref=(double*)malloc((n+1)*sizeof(double));
      if (val_dec_ref==NULL) {
         sprintf(s,"error : val_dec_ref pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_dec_ref=(int*)malloc((n+1)*sizeof(int));
      if (val_dec_ref==NULL) {
         sprintf(s,"error : ind_dec_ref pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         free(val_dec_ref);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  if (n_ref>0) {
         n=n_ref;
         for (k=0;k<n;k++) {
            val_dec_ref[k]=htmrefs[k].dec;
            ind_dec_ref[k]=k;
         }
         ak_util_qsort_double(val_dec_ref,0,n,ind_dec_ref);         
      }
      /* --- tri de zmg selon les JD croissantes ---*/
      n=n_zmg;
	  /*Modif Yassine : on va rajouter une date au plus
	  n+=n_file;*/
	  n+=1;
	  /*fin*/
      val_jd_zmg=(double*)malloc((n+1)*sizeof(double));
      if (val_jd_zmg==NULL) {
         sprintf(s,"error : val_jd_zmg pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         free(val_dec_ref);
         free(ind_dec_ref);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_jd_zmg=(int*)malloc((n+1)*sizeof(int));
      if (val_jd_zmg==NULL) {
         sprintf(s,"error : ind_jd_zmg pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         free(val_dec_ref);
         free(ind_dec_ref);
         free(val_jd_zmg);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  if (n_zmg>0) {
         n=n_zmg;
         for (k=0;k<n;k++) {
            val_jd_zmg[k]=htmzmgs[k].jd;
            ind_jd_zmg[k]=k;
         }
         ak_util_qsort_double(val_jd_zmg,0,n,ind_jd_zmg);         
      }
      /* --- Alloue de la memoire pour les nouvelles etoiles a ---*/
      /*     ajouter dans HTM_mes.txt */
      n=n_file;
      if (n>0) {
         htmmess=(struct_htmmes*)malloc(n*sizeof(struct_htmmes));
         if (htmmess==NULL) {
            sprintf(s,"error : htmmess pointer out of memory (%d elements)",n);
            free(htmfiles);
            free(htmrefs);
            free(htmzmgs);
            free(val_dec_file);
            free(ind_dec_file);
            free(val_dec_ref);
            free(ind_dec_ref);
            free(val_jd_zmg);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      /* ==--- grande boucle sur les etoiles ---==*/
      index_ref=n_ref-1;
      index_zmg=n_zmg-1;
      index_mes=-1;
      /*Rajout Yassine: pour enlever le bug des dates anterieures a la derniere date de zmg*/
	  nouvdate=0;
	  /*fin*/
	  k_ref_prog=0;
	  for (k_file=0;k_file<n_file;k_file++) {
		 dec0=htmfiles[ind_dec_file[k_file]].dec;
         ra0=htmfiles[ind_dec_file[k_file]].ra;
         jd0=htmfiles[ind_dec_file[k_file]].jd;
	     codefiltre0=htmfiles[ind_dec_file[k_file]].codefiltre;
         exposure0=htmfiles[ind_dec_file[k_file]].exposure;
         airmass0=htmfiles[ind_dec_file[k_file]].airmass;
		 /*Rajout yassine*/
		 codecam0=htmfiles[ind_dec_file[k_file]].codecam;
		 dmag0=htmfiles[ind_dec_file[k_file]].dmag;
		 flagsext0=htmfiles[ind_dec_file[k_file]].flag;
		 /*fin*/
		 
         /* === On ajoute eventuellement l'etoile a HTM_ref.bin */
         newref=-1;
         if (n_ref>0) {
            cosdec0=cos(dec0*dr);
            /* --- on recherche si l'etoile existe deja dans ref ---*/
            /* --- on commence par chercher DEC le plus proche ---*/
			k_ref1=k_ref_prog;
            k_ref2=n_ref-1;
			sortie=0;
			while(sortie==0) {
               k_ref=(k_ref1+k_ref2+1)/2;
               if ((k_ref2-k_ref1)<=1) { break; }
               dec=htmrefs[ind_dec_ref[k_ref]].dec;
               if (dec0<=dec) {
                  k_ref2=k_ref;
               } else {
                  k_ref1=k_ref;
               }
            }
            newref=-1;
            for (k=k_ref;k>=0;k--) {
               dec=htmrefs[ind_dec_ref[k]].dec;
			   ddec=(dec0-dec)*3600.;
               if (ddec>dangle) { break; }
               if (ddec<-dangle) { continue; }
               ddec*=ddec;
               ra=htmrefs[ind_dec_ref[k]].ra;
               /*modif Yassine
			   dra=(ra-ra0)*3600./cosdec0;  */
               dra=(ra-ra0)*3600.*cosdec0;
			   /*fin*/
               dra*=dra;
               if ((dra+ddec)<dangle2) { 
                  newref=ind_dec_ref[k] ;
				  k_ref_prog=k;
				  break; 
               }
            }
            if (newref==-1) {
				for (k=k_ref+1;k<n_ref;k++) {
                  dec=htmrefs[ind_dec_ref[k]].dec;
				  ddec=(dec-dec0)*3600.;
                  if (ddec>dangle) { break; }
                  if (ddec<-dangle) { continue; }
                  ddec*=ddec;
                  ra=htmrefs[ind_dec_ref[k]].ra;
                  /*modif Yassine
			      dra=(ra-ra0)*3600./cosdec0; */
                  dra=(ra-ra0)*3600.*cosdec0;
			      /*fin*/
                  dra*=dra;
                  if ((dra+ddec)<dangle2) { 
                     newref=ind_dec_ref[k] ; 
					 k_ref_prog=k;
					 break; 
                  }
               }
            }
         } else {
            newref=-2;
         }
         if (newref<=-1) {
            /* --- L'etoile n'existe pas dans le catalogue ref ---*/
            /* --- on ajoute une etoile de reference ---*/
            index_ref++;
            htmrefs[index_ref].indexref=index_ref;
            htmrefs[index_ref].nbmes=1;
            htmrefs[index_ref].ra=ra0;
            htmrefs[index_ref].dec=dec0;
            htmrefs[index_ref].codecat[0]=(unsigned char)1;
            htmrefs[index_ref].codefiltre[0]=codefiltre0;
			htmrefs[index_ref].mag[0]=htmfiles[ind_dec_file[k_file]].maginst;
            for (k=1;k<4;k++) {
               htmrefs[index_ref].codecat[k]=(unsigned char)0;
               htmrefs[index_ref].codefiltre[k]=(unsigned char)0;
               htmrefs[index_ref].mag[k]=(float)-99.9;
            }
            saveref=1;
            newref=index_ref;
         } else if (newref>=0) {
            /* --- L'etoile existe dans le catalogue ref ---*/
            /* --- on affine les coordonn�es ---*/
            n=htmrefs[newref].nbmes;
            htmrefs[newref].nbmes++;
            dra=fabs(htmrefs[newref].ra-ra0);
            if (dra>180.) {
               ra0+=360.;
            }
            htmrefs[newref].ra=(htmrefs[newref].ra*n+ra0)/(double)(n+1);
            if (htmrefs[newref].ra>360.) htmrefs[newref].ra-=360.;
            if (htmrefs[newref].ra<0.) htmrefs[newref].ra+=360.;
            htmrefs[newref].dec=(htmrefs[newref].dec*n+dec0)/(double)(n+1);
            /* --- on verifie le code du filtre ---*/
            newreffiltre=-2;
            for (k=0;k<4;k++) {
               if (htmrefs[newref].codefiltre[k]==codefiltre0) {
                  newreffiltre=k;
                  break;
               }
            }
            if (newreffiltre==-2) {
               /* --- Le filtre n'existe pas dans le catalogue ref ---*/
               /* --- on ajoute le code du filtre ---*/
               for (k=0;k<4;k++) {
                  if (htmrefs[newref].codefiltre[k]==0) {
                     htmrefs[newref].codecat[k]=(unsigned char)1;
                     htmrefs[newref].codefiltre[k]=codefiltre0;
					 htmrefs[newref].mag[k]=htmfiles[ind_dec_file[k_file]].maginst;
                     saveref=1;
                     break;
                  }
               } 
            }
            newref=htmrefs[newref].indexref;
         }
         /* --- ici newref est l'indice de l'etoile courante ---*/
         /*     dans HTM_ref.bin --- */
         /* === On ajoute eventuellement le JD,FILTRE,CMAG a HTM_zmg.bin */
		 /*Rajout Yassine : je fais ce test "if (nouvdate==0)" pour enlever le bug des dates 
		 anterieurs a la derniere date de zmg: car par construction filename_in contient une seul date*/
		 if (nouvdate==0) {
			 newzmg=-1;
		     if (n_zmg>0) {
                /* --- on recherche si le jd existe deja dans zmg ---*/
                /* --- on commence par chercher JD le plus proche ---*/
                k_zmg1=0;
                k_zmg2=n_zmg-1;
			    sortie=0;
                while(sortie==0) {
                   k_zmg=(k_zmg1+k_zmg2+1)/2;
                   if ((k_zmg2-k_zmg1)<=1) { break; }
                   jd=htmzmgs[ind_jd_zmg[k_zmg]].jd;
                   if (jd0<=jd) {
                       k_zmg2=k_zmg;
                   } else {
                       k_zmg1=k_zmg;
                   }
                }
                for (k=k_zmg;k>=0;k--) {
                   jd=htmzmgs[ind_jd_zmg[k]].jd;
                   djd=(jd0-jd)*86400.;
                   if (djd>1.) { break; }
                   if (djd<-1.) { continue; }
			       if (htmzmgs[ind_jd_zmg[k]].codefiltre==codefiltre0) {
                       newzmg=ind_jd_zmg[k] ; break; 
                   }
                }
                if (newzmg==-1) {
                   for (k=k_zmg+1;k<n_zmg;k++) {
                       jd=htmzmgs[ind_jd_zmg[k]].jd;
                       djd=(jd-jd0)*86400.;
                       if (djd>1.) { break; }
                       if (djd<-1.) { continue; }
			           if (htmzmgs[ind_jd_zmg[k]].codefiltre==codefiltre0) {
                           newzmg=ind_jd_zmg[k] ; break; 
                       }
                   }
                }
             } else {
                newzmg=-2;
             }
		     if (newzmg<=-1) {
                /*Par construction: le fichier d'entree contient une seule date*/
			    nouvdate=1;
			    /*fin de la modif*/
			    /* --- La date+filtre n'existe pas dans le catalogue zmg ---*/
                /* --- on ajoute une date+filtre pour le point zero ---*/
			    index_zmg++;
                htmzmgs[index_zmg].indexzmg=index_zmg;
                htmzmgs[index_zmg].jd=jd0;
                /*rajout Yassine: ca peut etre util*/
                htmzmgs[index_zmg].codecam=codecam0;
                /*fin*/
			    htmzmgs[index_zmg].codefiltre=codefiltre0;
                htmzmgs[index_zmg].cmag=(float)-99.9;
                htmzmgs[index_zmg].exposure=(float)exposure0;
                htmzmgs[index_zmg].airmass=(float)airmass0;
                savezmg=1;
                n_zmg++;
                for (k=0;k<n_zmg;k++) {
                    val_jd_zmg[k]=htmzmgs[k].jd;
                    ind_jd_zmg[k]=k;
                }
                ak_util_qsort_double(val_jd_zmg,0,n_zmg-1,ind_jd_zmg);
                newzmg=index_zmg;
             } else if (newref>=0) {
                /* --- La date+filtre  existe dans le catalogue zmg ---*/
               newzmg=htmzmgs[newzmg].indexzmg;
             }
		 } /*fin du test sur nouvedate : Modif Yassine
		 /* === On ajoute l'etoile a HTM_mes.bin */
         index_mes++;
         htmmess[index_mes].indexref=newref;
         htmmess[index_mes].indexzmg=newzmg;
         htmmess[index_mes].jd=jd0;
		 htmmess[index_mes].codecam=codecam0;
		 htmmess[index_mes].codefiltre=codefiltre0;
         htmmess[index_mes].maginst=htmfiles[ind_dec_file[k_file]].maginst;
         htmmess[index_mes].magcali=(float)-99.9;
		 /*rajout Yassine*/
         htmmess[index_mes].dmag=dmag0;
		 htmmess[index_mes].flag=flagsext0;
		 /*fin*/
         savemes=1;
      } /* ==--- fin de grande boucle sur les etoiles ---==*/
      /* --- mise a jour du fichier de reference si necessaire ---*/
      if (saveref==1) {
         n=index_ref+1;
         for (k=0;k<n;k++) {
            val_dec_ref[k]=htmrefs[k].dec;
            ind_dec_ref[k]=k;
         }
         ak_util_qsort_double(val_dec_ref,0,n,ind_dec_ref);
         sprintf(filename_out,"%s%s_ref.bin",path,generic_filename_out);
         f_out=fopen(filename_out,"wb");
         for (k=0;k<n;k++) {
            fwrite(&htmrefs[ind_dec_ref[k]],1,sizeof(struct_htmref),f_out);
         }
         fclose(f_out);
      }
      /* --- mise a jour du fichier de point zero de magnitudes si necessaire ---*/
      if (savezmg==1) {
         n=index_zmg+1;
         for (k=0;k<n;k++) {
            val_jd_zmg[k]=htmzmgs[k].jd;
            ind_jd_zmg[k]=k;
         }
         ak_util_qsort_double(val_jd_zmg,0,n,ind_jd_zmg);
         sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename_out);
         f_out=fopen(filename_out,"wb");
         for (k=0;k<n;k++) {
            fwrite(&htmzmgs[ind_jd_zmg[k]],1,sizeof(struct_htmzmg),f_out);
         }
         fclose(f_out);
      }
      /* --- mise a jour du fichier de mesures si necessaire ---*/
      if (savemes==1) {
         n=index_mes+1;
         /* on utilise l'adresse de val_dec_file pour economiser de la place */
         val_ind_mes=val_dec_file;
         ind_ind_mes=ind_dec_file;
         for (k=0;k<n;k++) {
            val_ind_mes[k]=(double)htmmess[k].indexref;
            ind_ind_mes[k]=k;
         }
         ak_util_qsort_double(val_ind_mes,0,n,ind_ind_mes);
         sprintf(filename_in,"%s%s_mes.bin",path,generic_filename_out);
         f_in=fopen(filename_in,"rb");
         sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename_out);
         f_out=fopen(filename_out,"wb");
         if (f_in!=NULL) {
            k=0;
            lecture=1;
            while (0==0) {
               if ((feof(f_in)!=0)&&(k>=n)) {
                  break;
               }
               sortie2=0;
               if (lecture==1) {
                  if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)<1) {
                     index_in+=(1+n);
                     sortie2++;
                  } else {
                     index_in=htmmes.indexref;
                     jd_in=htmmes.jd;
                     codecam_in=htmmes.codecam;
                     codefiltre_in=htmmes.codefiltre;
                     lecture=0;
                  }
               }
               if (k<n) {
                  index_out=htmmess[ind_ind_mes[k]].indexref;
               } else {
                  index_out=100000000;
                  sortie2++;
               }
               if (sortie2==2) { break; }
               if (index_in<index_out) {
                  /* on garde l'ancienne mesure */
                  fwrite(&htmmes,1,sizeof(struct_htmmes),f_out);
                  lecture=1;
                  continue;
               }
               if (index_in>index_out) {
                  /* la nouvelle mesure s'inserere dans les anciennes */
                  fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
                  k++;
                  lecture=0;
                  continue;
               }
               if (index_in==index_out) {
                  jd_out=htmmess[ind_ind_mes[k]].jd;
                  /* on garde l'ancienne mesure a priori */
                  sortie=0;
                  if (jd_in==jd_out) {
                     codecam_out=htmmess[ind_ind_mes[k]].codecam;
                     if (codecam_in==codecam_out) {
                        codefiltre_out=htmmess[ind_ind_mes[k]].codefiltre;
                        if (codefiltre_in==codefiltre_out) {
                           /* la nouvelle mesure remplace l'ancienne */
                           sortie=1;
                        }
                     }
                  }
                  if (sortie==0) {
                     fwrite(&htmmes,1,sizeof(struct_htmmes),f_out);
                     lecture=1;
                     continue;
                  } else {
                     fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
                     k++;
                     lecture=1;
                     continue;
                  }
               }
            }
            fclose(f_in);
            fclose(f_out);
         } else {
            fclose(f_out);
            remove(filename_out);
            /* premiere creation du fichier */
            sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename_out);
            f_out=fopen(filename_out,"wb");
            for (k=0;k<n;k++) {
               fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
            }
            fclose(f_out);
         }
         sprintf(filename_in,"%s%s_mes.bin0",path,generic_filename_out);
         sprintf(filename_out,"%s%s_mes.bin",path,generic_filename_out);
         remove(filename_out);
         rename(filename_in,filename_out);
      }
      /* --- libere la memoire ---*/
      free(htmfiles);
      free(htmrefs);
      free(htmzmgs);
      free(val_dec_file);
      free(ind_dec_file);
      free(val_dec_ref);
      free(ind_dec_ref);
      free(val_jd_zmg);
      free(ind_jd_zmg);
      free(htmmess);
      /* --- nombre de nouvelles sources ---*/
      sprintf(s,"%d",index_mes+1);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_aktcl_file2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Explose le fichier texte de catalogue d'observation en leur equivalents  */
/* binaires rassembl�s par meme HTM.                                        */
/****************************************************************************/
/* Input :                                                                  */
/* ra dec jd codecam codefiltre maginst exposure airmass (ASCII)            */
/* Output : un fichier pour chaque HTM (ou tout le ciel si htm_level=-1     */
/* ra dec jd codecam codefiltre maginst exposure airmass  (binaire)         */
/****************************************************************************/
{
   char s[1024];
   char path[1024];
   char ligne[2000],texte[2000],filename_in[1024],generic_filename_out[1024],filename_out[1024];
   char htm[80],htm_only[80];
   FILE *f_in,*f_out;
   int htm_level,n;
   double ra, dec, jd, codecam, codefiltre, maginst, exposure, airmass;
   /*rajout Yassine*/
   double dmag,flagsext;
   /*fin*/
   double dr;
   int htm_onlyflag=0,gofile;
   struct_htmfile htmfile;

   if(argc<5) {
      sprintf(s,"Usage: %s filename_in path generic_filename_out htm_level|-1 ?htm_only?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(filename_in,argv[1]);
      strcpy(path,argv[2]);
      strcpy(generic_filename_out,argv[3]);
      htm_level=(int)atoi(argv[4]);
      if (htm_level>12) { htm_level=12; }
      strcpy(htm_only,"");
      if (argc>=6) {
         htm_onlyflag=1;
         strcpy(htm_only,argv[5]);
      }
      /* --- ouverture du fichier d'entree ---*/
      f_in=fopen(filename_in,"rt");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      memset(htm,'\0',80*sizeof(char));
      dr=4*atan(1.)/180.;
      n=0;
      do {
         
		 if (fgets(ligne,255,f_in)!=NULL) {
	         strcpy(texte,"");
   	      sscanf(ligne,"%s",texte);
	         if ( (strcmp(texte,"")!=0) ) {
               /* ra dec jd codecam codefiltre maginst exposure airmass   /* 
			   /* modif Yassine*/
			   sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %lf %lf %lf",
               &ra,&dec,&jd,&codecam,&codefiltre,&maginst,&exposure,&airmass,&dmag,&flagsext);
               /* fin*/
                if (htm_level>=0) {
                    ak_radec2htm(ra*dr,dec*dr,htm_level,htm);
                } else {
                    strcpy(htm,"allsky");
                }
               /* === fichier (generic)_htm.bin === */
               sprintf(filename_out,"%s%s_%s.bin",path,generic_filename_out,htm);
               gofile=0;
               if (htm_onlyflag==0) {
                  gofile=1;
               } else if (strcmp(htm_only,htm)==0) {
                  gofile=1;
               } else if (htm_level<0) {
                   gofile=1;
               }
               if (gofile==1) {
                  f_out=fopen(filename_out,"ab");
                  if (f_out==NULL) {
                     sprintf(s,"filename_out %s not found",filename_out);
                     Tcl_SetResult(interp,s,TCL_VOLATILE);
                     fclose(f_in);
                     return TCL_ERROR;
                  }
                  htmfile.ra=(double)ra;
                  htmfile.dec=(double)dec;
                  htmfile.jd=(double)jd;
                  htmfile.codecam=(unsigned char)codecam;
                  htmfile.codefiltre=(unsigned char)codefiltre;
                  htmfile.maginst=(float)maginst;
                  htmfile.exposure=(float)exposure;
                  htmfile.airmass=(float)airmass;
				  /*rajout Yassine*/
				  htmfile.dmag=(float)dmag;
				  htmfile.flag=(unsigned char)flagsext;
				  /*fin*/
                  fwrite(&htmfile,1,sizeof(struct_htmfile),f_out);
                  fclose(f_out);
                  n++;
               }
            }
         }
      } while (feof(f_in)==0) ;
      fclose(f_in);
   }
   return TCL_OK;
}

int Cmd_aktcl_bugbias(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Ajoute le mot cle END a la fin de l'entete FITS d'images mal ecrites     */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[1024];
   char ligne[2000],filename_in[1024],filename_out[1024];
   FILE *f_in,*f_out;
   int sortie,n;
   unsigned char c;

   if(argc<3) {
      sprintf(s,"Usage: %s filename_in filename_out", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      strcpy(filename_in,argv[1]);
      strcpy(filename_out,argv[2]);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wb");
      if (f_out==NULL) {
         sprintf(s,"filename_out %s cannot be created",filename_out);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         fclose(f_in);
         return TCL_ERROR;
      }
      result = TCL_OK;
      sortie=0;
      while (sortie==0) {
         n=fread(ligne,sizeof(char),80,f_in);
         if (n<80) {
            break;
         }
         if (ligne[0]==' ') {
            ligne[0]='E';
            ligne[1]='N';
            ligne[2]='D';
            sortie=1;
         }
         fwrite(ligne,sizeof(char),80,f_out);
      }
      sortie=0;
      while (sortie==0) {
         n=fread(&c,sizeof(unsigned char),1,f_in);
         if (n<1) {
            break;
         }
         fwrite(&c,sizeof(unsigned char),1,f_out);
      }
      fclose(f_in);
      fclose(f_out);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_aktcl_radec2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le code Hierarchical Triangle Mesh.                             */
/****************************************************************************/
/*
load libak ; ak_radec2htm 12 45 4
*/
/****************************************************************************/
{
   int result,retour;
   char s[100];
   double dr;
   double ra,dec;
   int niter;
   char htm[80];

   if(argc<4) {
      sprintf(s,"Usage: %s ra dec niter", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      dr=4*atan(1.)/180.;
      memset(htm,'\0',80*sizeof(char));
      /* --- decode les parametres obligatoires ---*/
      retour = Tcl_GetDouble(interp,argv[1],&ra);
      if(retour!=TCL_OK) return retour;
      ra*=dr;
      retour = Tcl_GetDouble(interp,argv[2],&dec);
      if(retour!=TCL_OK) return retour;
      dec*=dr;
      retour = Tcl_GetInt(interp,argv[3],&niter);
      if(retour!=TCL_OK) return retour;
      if (niter>25) {niter=25;}
      ak_radec2htm(ra,dec,niter,htm);
      Tcl_SetResult(interp,htm,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_aktcl_htm2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le ra,dec a partir du code Hierarchical Triangle Mesh.                             */
/****************************************************************************/
/*
load libak ; ak_htm2radec N120321
*/
/****************************************************************************/
{
   int result;
   char s[1000];
   double dr;
   double ra,dec;
   double ra0,dec0;
   double ra1,dec1;
   double ra2,dec2;
   int niter;
   char htm[80];

   if(argc<2) {
      sprintf(s,"Usage: %s htm", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      dr=4*atan(1.)/180.;
      /* --- decode les parametres obligatoires ---*/
      strcpy(htm,argv[1]);
      ak_htm2radec(htm,&ra,&dec,&niter,&ra0,&dec0,&ra1,&dec1,&ra2,&dec2);
      sprintf(s,"%12f %12f %d %12f %12f %12f %12f %12f %12f ",ra/dr,dec/dr,niter,ra0/dr,dec0/dr,ra1/dr,dec1/dr,ra2/dr,dec2/dr);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_aktcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le jour julien a partir des la date en clair.                   */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   double y=0.,m=0.,d=0.,hh=0.,mm=0.,ss=0.,jd=0.;

   if(argc<4) {
      sprintf(s,"Usage: %s year month day ?hour min sec?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/
      retour = Tcl_GetDouble(interp,argv[1],&y);
      if(retour!=TCL_OK) return retour;
      retour = Tcl_GetDouble(interp,argv[2],&m);
      if(retour!=TCL_OK) return retour;
      retour = Tcl_GetDouble(interp,argv[3],&d);
      if(retour!=TCL_OK) return retour;
      /* --- decode les parametres facultatifs ---*/
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&hh);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&mm);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=7) {
         retour = Tcl_GetDouble(interp,argv[6],&ss);
         if(retour!=TCL_OK) return retour;
      }
      /* --- le type DString (dynamic string) est une fonction de */
      /* --- l'interpreteur Tcl. Elle est tres utile pour remplir */
      /* --- une chaine de caracteres dont on ne connait pas longueur */
      /* --- a l'avance. On s'en sert ici pour stocker le resultat */
      /* --- qui sera retourne. */
      Tcl_DStringInit(&dsptr);
      /* --- calcule le jour julien ---*/
      ak_date2jd(y,m,d,hh,mm,ss,&jd);
      /* --- met en forme le resultat dans une chaine de caracteres ---*/
      sprintf(s,"%f",jd);
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
      /* --- retourne le code de succes a l'interpreteur Tcl */
      result = TCL_OK;
   }
   return result;
}

int Cmd_aktcl_addcol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Ajoute n colonnes de fond de ciel a partir de la ligne m                 */
/*
load libak
ak_addcol 1 4 1034
*/
/****************************************************************************/
{
   int result;
   Tcl_DString dsptr;
   char s[100];
   ak_image image;
   int numbuf,ncols,begcol,col,lig;
   float value;
   double valuedeb,valuefin;
   int coldeb,colfin;

   if(argc<4) {
      sprintf(s,"Usage: %s numbuf ncols begcol", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      /* --- decode le parametre obligatoire ---*/
      numbuf=(int)atoi(argv[1]);
      ncols=(int)atoi(argv[2]);
      begcol=(int)atoi(argv[3])-1;
      /*value=(float)atof(argv[4]);*/
      /*--- initialise la dynamic string ---*/
      Tcl_DStringInit(&dsptr);
      /* --- recherche les infos ---*/
      result=aktcl_getinfoimage(interp,numbuf,&image);
      for (col=image.naxis1-1;col>begcol;col--) {
         if (col<0) break;
         if ((col-ncols)<0) break;
         if (col>(begcol+ncols)) {
            for (lig=0;lig<image.naxis2;lig++) {
               image.ptr_audela[lig*image.naxis1+col]=image.ptr_audela[lig*image.naxis1+col-ncols];
            }
         } else {
            for (lig=0;lig<image.naxis2;lig++) {
               coldeb=begcol;
               colfin=begcol+ncols+1;
               valuedeb=image.ptr_audela[lig*image.naxis1+coldeb];
               valuefin=image.ptr_audela[lig*image.naxis1+colfin];
               value=(float)valuedeb+(float)(valuefin-valuedeb)*(float)(col-coldeb)/(float)(colfin-coldeb);
               image.ptr_audela[lig*image.naxis1+col]=value;
            }
         }
      }
      strcpy(s,"");
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
   }
   return result;

}

int Cmd_aktcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   ak_image image;
   int numbuf;

   if(argc<2) {
      sprintf(s,"Usage: %s numbuf", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      /* --- decode le parametre obligatoire ---*/
      retour = Tcl_GetInt(interp,argv[1],&numbuf);
      if(retour!=TCL_OK) return retour;
      /*--- initialise la dynamic string ---*/
      Tcl_DStringInit(&dsptr);
      /* --- recherche les infos ---*/
      result=aktcl_getinfoimage(interp,numbuf,&image);
      /* --- met en forme le resultat dans une chaine de caracteres ---*/
      sprintf(s,"%p %d %d %s",image.ptr_audela,image.naxis1,image.naxis2,image.dateobs);
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
   }
   return result;
}

int aktcl_getinfoimage(Tcl_Interp *interp,int numbuf, ak_image *image)
/****************************************************************************/
/* Retourne les infos d'une image presente dans le buffer numero numbuf     */
/* de AudeLA                                                                */
/****************************************************************************/
/* Note : ce type de fonction utilitaire est indispensable dans une         */
/* extension pour AudeLA.                                                   */
/****************************************************************************/
{
   char keyname[10],s[50],lignetcl[50],value_char[100];
   int ptr,datatype;

   strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");
   image->naxis1=0;
   image->naxis2=0;
   strcpy(image->dateobs,"");
   /* -- recherche l'adresse du pointeur de l'image --*/
   sprintf(s,"buf%d pointer",numbuf);
   Tcl_Eval(interp,s);
   Tcl_GetInt(interp,interp->result,&ptr);
   image->ptr_audela=(float*)ptr;
   if (image->ptr_audela==NULL) {
      return(TCL_OK);
   }
   /* -- recherche le mot cle NAXIS1 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      image->naxis1=0;
   } else {
      image->naxis1=atoi(value_char);
   }
   /* -- recherche le mot cle NAXIS2 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      image->naxis2=0;
   } else {
      image->naxis2=atoi(value_char);
   }
   /* -- recherche le mot cle DATE-OBS dans l'entete FITS --*/
   strcpy(keyname,"DATE-OBS");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      strcpy(image->dateobs,"");
   } else {
      strcpy(image->dateobs,value_char);
   }
   return(TCL_OK);
}

/*int Cmd_aktcl_photometric_parallax(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Construit les images (MD,Av) pour les etoiles mesurees dans les bandes   */
/* BVRIJHK.                                                                 */
/****************************************************************************/
/* Entrees :                                                                */
/* Fichier texte : 1 etoile/ligne, format index,b,v,r,i,j,h,k               */
/* Fichier texte : couples (H-K,J-H)                                        */
/* Fichier texte : couples (H-K,K)                                          */
/*
load libak; ak_photometric_parallax stars.txt colcol.txt colmag.txt ; buf1 load colcol1.fit ; mult 10 ;visu {1 0}
load libak; ak_photometric_parallax stars.txt colcol.txt colmag.txt ; buf1 load avmd1.fit ; visu {1 0}
load libak; ak_photometric_parallax stars.txt colcol.txt colmag.txt ; buf1 load colmag.fit ; visu {1 0}
*/
/****************************************************************************/
/*
{
   char stringresult[1024];
   char s[100];
   char ascii_star[1024],ascii_colcol[1024],ascii_colmag[1024];
   int result=TCL_ERROR;
   if(argc<4) {
      sprintf(s,"Usage: %s ascii_(index,b,v,r,i,j,h,k) ascii_(H-K,J-H) ascii_(H-K,K)", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
 /*     strcpy(ascii_star,argv[1]);
      strcpy(ascii_colcol,argv[2]);
      strcpy(ascii_colmag,argv[3]);
      strcpy(stringresult,ak_photometric_parallax(ascii_star,ascii_colcol,ascii_colmag));
      if (strcmp(stringresult,"")==0) {
         result=0;
      } else {
         result=1;
      }
      Tcl_SetResult(interp,stringresult,TCL_VOLATILE);
   }
   return result;
}
/*********************************************************************************************/
int Cmd_aktcl_rectification(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
	char s[100];
    char path[1024];
    char filename_in[1024],generic_filename[1024],filename_out[1024];
    struct_htmmes htmmes;
    struct_htmzmg htmzmg;
    FILE *f_in,*f_out;
    if(argc<3) {
		sprintf(s,"Usage: %s path generic_filename", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
    /* --- decodage des arguments ---*/
    strcpy(path,argv[1]);
    strcpy(generic_filename,argv[2]);

	sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
    f_in=fopen(filename_in,"rb");
    if (f_in==NULL) {
		sprintf(s,"filename_in %s not found",filename_in);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
	sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename);
    f_out=fopen(filename_out,"wb");
    if (f_out==NULL) {
		sprintf(s,"filename_out %s not found",filename_out);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
    while (feof(f_in)==0) {
		if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmes.codecam=(unsigned char)1;
			fwrite(&htmmes,1,sizeof(struct_htmmes),f_out);

        }
    }
    fclose(f_in);
	fclose(f_out);
	sprintf(filename_in,"%s%s_mes.bin0",path,generic_filename);
    sprintf(filename_out,"%s%s_mes.bin",path,generic_filename);
    remove(filename_out);
    rename(filename_in,filename_out);
	/*Meme chose pour les _zmg.bin*/
	sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
    f_in=fopen(filename_in,"rb");
    if (f_in==NULL) {
		sprintf(s,"filename_in %s not found",filename_in);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
	sprintf(filename_out,"%s%s_zmg.bin0",path,generic_filename);
    f_out=fopen(filename_out,"wb");
    if (f_out==NULL) {
		sprintf(s,"filename_out %s not found",filename_out);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
    while (feof(f_in)==0) {
		if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            htmzmg.codecam=(unsigned char)1;
			fwrite(&htmzmg,1,sizeof(struct_htmzmg),f_out);

        }
    }
    fclose(f_in);
	fclose(f_out);     
    sprintf(filename_in,"%s%s_zmg.bin0",path,generic_filename);
    sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename);
    remove(filename_out);
    rename(filename_in,filename_out);
      
   }
   return TCL_OK;
}
/*int Cmd_aktcl_photometric_parallax_avmap(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])*/
/****************************************************************************/
/* Construit l'image de la carte d'extinction */
/****************************************************************************/
/* Entrees :                                                                */
/* extr-faible-av.dat
set date0 [clock seconds]
load libak; ak_photometric_parallax ./ cat-2mass-upper-taurus-aaa.dat 2 11 0 htmav.txt colcol.txt colmag.txt
set date1 [clock seconds]
::console::affiche_resultat "[expr $date1-$date0] secondes \n"
load libak; ak_photometric_parallax_avmap ./ htmav.txt htmav.fit htmdm.fit 300 300 ; loadima htmav
  compter 39s pour 1000 etoiles
*/
/****************************************************************************/
/*
{
   char stringresult[1024];
   char s[100];
   char ascii_htmav[1024],fitsfilenameav[1024],fitsfilenamedm[1024],path[1024];
   int naxis1,naxis2;
   int result=TCL_ERROR;
   if(argc<6) {
      sprintf(s,"Usage: %s path ascii_in(HTM,Av) fitsfile_Av fitsfile_DM naxis1 naxis2", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
/*      strcpy(path,argv[1]);
      strcpy(ascii_htmav,argv[2]);
      strcpy(fitsfilenameav,argv[3]);
      strcpy(fitsfilenamedm,argv[4]);
      naxis1=(int)atoi(argv[5]);
      naxis2=(int)atoi(argv[6]);
      strcpy(stringresult,ak_photometric_parallax_avmap(path,ascii_htmav,fitsfilenameav,fitsfilenamedm,naxis1,naxis2));
      if (strcmp(stringresult,"")==0) {
         result=0;
      } else {
         result=1;
      }
      Tcl_SetResult(interp,stringresult,TCL_VOLATILE);
   }
   return result;
}
*/


