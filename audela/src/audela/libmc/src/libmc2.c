/* libmc2.c
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

#include "libmc.h"

struct obsreq {
   double quota_user;
   double priority;
   double totalexptime;
   double jd1;
   double jd2;
   double jmeridien;
   double jstart;
};

int Cmd_mctcl_obsreq(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[10000];
   int *p0=NULL,*p=NULL,res,nscenes,k,*occupations=NULL,flag=0;
   char file_scenes[1024],file_users[1024],file_out[1024];
   double jd1min,jd2max,jd1,jd2;
   int ndt,kl,kc,k1,k2;
   double dt,occupiedtime,occupiedtime0,scenestime,totaltime;
   struct obsreq *paramscenes;
   /*FILE *fic;*/
   int nscenesplaced=0;
   int k11,k22,kcc,k111,k222;
   double jd111,jd10,jd20;
   Tcl_DString dsptr;

   if(argc<=3) {
      sprintf(s,"Usage: %s file_scenes file_users file_out", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(file_scenes,argv[1]);
      strcpy(file_users,argv[2]);
      strcpy(file_out,argv[3]);
      /**/
      /* --- Fichier des scenes ---*/
      sprintf(s,"set obsreq(res) [catch {open \"%s\" r} obsreq(f)]",file_scenes);
      res=Tcl_Eval(interp,s);
      if (res==TCL_ERROR) {
         strcpy(s,"set obsreq(f)");
         res=Tcl_Eval(interp,s);
         Tcl_SetResult(interp,interp->result,TCL_VOLATILE);
         return TCL_ERROR;
      }
      strcpy(s,"set obsreq(scenes) [split [read $obsreq(f)] \\n]");
      res=Tcl_Eval(interp,s);
      strcpy(s,"close $obsreq(f)");
      res=Tcl_Eval(interp,s);
      sprintf(s,"set obsreq(nscenes) [llength $obsreq(scenes)]");
      res=Tcl_Eval(interp,s);
      nscenes=atoi(interp->result); 
      /* -- recherche des debut/fin d'observation */
      jd1min=1e9;
      jd2max=-1e9;
      nscenes--;
      for (k=0;k<nscenes;k++) {
         sprintf(s,"set obsreq(scene) [lindex $obsreq(scenes) %d]",k);
         res=Tcl_Eval(interp,s);
         sprintf(s,"set obsreq(jd1) [mc_date2jd [lindex [lindex $obsreq(scene) 1] 0] ]");
         res=Tcl_Eval(interp,s);
         jd1=atof(interp->result);
         sprintf(s,"set obsreq(jd2) [mc_datescomp [mc_date2jd [lindex [lindex $obsreq(scene) 1] 1]] + [expr 1.*[lindex $obsreq(scene) 2]/86400.] ]");
         res=Tcl_Eval(interp,s);
         jd2=atof(interp->result);
         if (jd1<jd1min) {jd1min=jd1;}
         if (jd2>jd2max) {jd2max=jd2;}
      }
      /**/
      dt=6.;
      ndt=(int)ceil((jd2max-jd1min)*86400./dt);
      /**/
      p0=(int*)calloc(nscenes*ndt,sizeof(int));
      if (p0==NULL) {
         sprintf(s,"p0 too large for memory (%d,%d)",nscenes,ndt);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /**/
      paramscenes=(struct obsreq *)calloc(nscenes,sizeof(struct obsreq));
      if (paramscenes==NULL) {
         sprintf(s,"paramscenes too large for memory (%d)",nscenes);
         free(p0);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /**/
      occupations=(int *)calloc((ndt+1),sizeof(int));
      if (occupations==NULL) {
         sprintf(s,"occupations too large for memory (%d)",ndt);
         free(p0);
         free(paramscenes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- on lit le fichier d'entree dans la structure C */
      for (k=0;k<nscenes;k++) {
         sprintf(s,"set obsreq(scene) [lindex $obsreq(scenes) %d]",k);
         res=Tcl_Eval(interp,s);
         sprintf(s,"mc_date2jd [lindex [lindex $obsreq(scene) 1] 0]");
         res=Tcl_Eval(interp,s);
         paramscenes[k].jd1=atof(interp->result);
         sprintf(s,"mc_date2jd [lindex [lindex $obsreq(scene) 1] 1]");
         res=Tcl_Eval(interp,s);
         paramscenes[k].jd2=atof(interp->result);
         sprintf(s,"mc_date2jd [lindex [lindex $obsreq(scene) 1] 2]");
         res=Tcl_Eval(interp,s);
         paramscenes[k].jmeridien=atof(interp->result);
         sprintf(s,"lindex $obsreq(scene) 2");
         res=Tcl_Eval(interp,s);
         paramscenes[k].totalexptime=atof(interp->result);
         sprintf(s,"lindex $obsreq(scene) 3");
         res=Tcl_Eval(interp,s);
         paramscenes[k].quota_user=atof(interp->result);
         sprintf(s,"lindex $obsreq(scene) 4");
         res=Tcl_Eval(interp,s);
         paramscenes[k].priority=atof(interp->result);
         paramscenes[k].jstart=0.;
      }
      /* ===== statistics for all scenes ===== */
      totaltime=dt*ndt;
      scenestime=0.;
      for (kc=0;kc<ndt;kc++) {
         occupations[kc]=0;
      }
      for (kl=0;kl<nscenes;kl++) {
         jd1=paramscenes[kl].jmeridien;
         jd2=paramscenes[kl].jmeridien+paramscenes[kl].totalexptime/86400.;
         k1=(int)(floor((jd1-jd1min)*86400./dt));
         k2=(int)(ceil((jd2-jd1min)*86400./dt));
         for (kc=k1;kc<=k2;kc++) {
            occupations[kc]+=1;
         }
         scenestime+=dt*(k2-k1+1);
      }
      scenestime/=totaltime;
      occupiedtime0=0.;
      for (kc=0;kc<=ndt;kc++) {
         if (occupations[kc]>0) {
            occupiedtime0+=dt;
         }
      }
      occupiedtime0/=totaltime;
      /* ===== init of the scheduling ===== */
      for (kc=0;kc<ndt;kc++) {
         occupations[kc]=-1;
      }
      /* ===== loop to place scenes ==== */
      nscenesplaced=0;
      kl=0;
      flag=0; /* =0 pas de conflit | =1 conflit regl� | =-1 conflit pas regl� */
      while (kl<nscenes) {
         if (flag==0) {
            jd1=paramscenes[kl].jmeridien;
            jd2=paramscenes[kl].jmeridien+paramscenes[kl].totalexptime/86400.;
            k1=(int)(floor((jd1-jd1min)*86400./dt));
            k2=(int)(ceil((jd2-jd1min)*86400./dt));
         }
         /* --- debut de recherche d'un conflit eventuel avec d'autres scenes + prioritaires --- */
         for (kc=k1;kc<=k2;kc++) {
            if (occupations[kc]>=0) {
               /*
               flag=-1;
               break;
               */
               /* --- cette proposition est en conflit avec au moins une autre scene ---*/
               jd10=paramscenes[kl].jd1;
               jd20=paramscenes[kl].jd2;
               /* --- recherche de k11, k22 des autres scenes dans les occupations ---*/
               for (k22=ndt,kcc=kc;kcc<=ndt;kcc++) {
                  if (occupations[kcc]==-1) {
                     k22=kcc-1;
                     break;
                  }
               }
               for (k11=0,kcc=kc;kcc>=0;kcc--) {
                  if (occupations[kcc]==-1) {
                     k11=kcc+1;
                     break;
                  }
               }
               /* === 1) on cherche a placer la scene avant celles en conflit ---*/
               k111 =k11-1-(k2-k1);
               k222 =k111+(k2-k1);
               jd111=jd1min+k111*dt/86400.;
               flag=1;
               if (jd111>=jd10) {
                  /* --- le debut de scene est observable ---*/
                  /* --- On verifie un eventuel conflit avec toutes les autres scenes deja plac�es ---*/
                  for (kcc=k111;kcc<=k222;kcc++) {
                     if (occupations[kcc]>=0) {
                        /* --- une autre scene occupe deja la position ---*/
                        flag=-1;
                        break;
                     }
                  }
               }
               if (flag==1) {
                  /* --- Le conflit est r�gl� et cette scene peut etre plac�e dans les occupations ---*/
                  k1=k111;
                  k2=k222;
                  break;
               }
               /* === 2) on cherche a placer la scene apres celles en conflit ---*/
               k111 =k22+1;
               k222 =k111+(k2-k1);
               jd111=jd1min+k111*dt/86400.;
               flag=1;
               if (jd111<=jd20) {
                  /* --- la fin de scene est observable ---*/
                  /* --- On verifie un eventuel conflit avec toutes les autres scenes deja plac�es ---*/
                  for (kcc=k111;kcc<=k222;kcc++) {
                     if (occupations[kcc]>=0) {
                        /* --- une autre scene occupe deja la position ---*/
                        flag=-1;
                        break;
                     }
                  }
               }
               if (flag==1) {
                  /* --- Cette scene peut etre plac�e dans les occupations ---*/
                  k1=k111;
                  k2=k222;
                  break;
               }
            }
         } /* --- fin de recherche d'un conflit eventuel avec une scene + prioritaire --- */
         if (flag>=0) {
            nscenesplaced++;
            for (kc=k1;kc<=k2;kc++) {
               p0[kl*ndt+kc]=1;
               occupations[kc]=kl;
            }
            if (flag==1) {
               paramscenes[kl].jstart=jd111;
            } else {
               paramscenes[kl].jstart=paramscenes[kl].jmeridien;
            }
         }
         flag=0;
         kl++;
      }
      /* ===== final statistics ===== */
      occupiedtime=0.;
      for (kc=0;kc<=ndt;kc++) {
         if (occupations[kc]>=0) {
            occupiedtime+=dt;
         }
      }
      occupiedtime/=totaltime;
      /* mc_obsreq scene3s.txt f f.txt */
      /* set a [::plotxy::fileread f.txt] ; ::plotxy::plot [lindex $a 0] [lindex $a 1] */
      free(p0);
      free(paramscenes);
      free(occupations);
      sprintf(s,"%d %d %f %f %f %f %f",
         nscenes,nscenesplaced,
         scenestime,occupiedtime0,occupiedtime,    
         jd1min,jd2max);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
      /**/
	   Tcl_DStringInit(&dsptr);
      /* --- on ecrit le fichier de sortie */
      /**/
      /*
      fic=fopen(file_out,"wt");
      for (kc=0;kc<ndt;kc++) {
         jd1=jd1min+kc*dt/86400.;
         fprintf(fic,"%f %d\n",jd1,occupations[kc]);
      }
      fclose(fic);
      */
      for (k=0;k<nscenes;k++) {
         if (paramscenes[kl].jstart>0.) {
         }
      }
      /*
	  Tcl_DStringAppend(&dsptr,"{Ok",-1);
	  sprintf(s," {J2000.0 coordinates} %d",kp);
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringAppend(&dsptr,"}",-1);
   }
      Tcl_DStringResult(interp,&dsptr);
      */
      Tcl_DStringFree(&dsptr);
	}
	return(result);
}

int Cmd_mctcl_menu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
{
   int result;
   struct mcvar param;
   char s[256];

   strcpy(param.repertoire1,""); /* repertoire des bases de donnees (Bowell) */
   strcpy(param.repertoire2,""); /* repertoire de travail */
   strcpy(param.repertoire3,""); /* repertoire des fichiers temporaires */
   param.choix=(int)0;                   /* numero du menu d'appel */
   param.langage=(int)0;                 /* choix de la langue */
   strcpy(param.erreur,"");      /* message d'erreur en retour de mc */
   strcpy(param.chaine1,"");
   strcpy(param.chaine2,"");
   strcpy(param.chaine3,"");
   param.reel1=(double)0.0;
   param.reel2=(double)0.0;
   param.reel3=(double)0.0;
   param.reel4=(double)0.0;
   param.reel5=(double)0.0;
   param.reel6=(double)0.0;
   param.reel7=(double)0.0;
   param.entier1=(int)0;
   param.entier2=(int)0;
   param.entier3=(int)0;
   strcpy(param.date1,"");
   strcpy(param.date2,"");
   param.jj1=(double)0.0;
   param.jj2=(double)0.0;

   result = TCL_ERROR;
   if(argc<2) {
      sprintf(s,"Usage: %s num Options", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   } else {
      param.choix=(int)atoi(argv[1]);
      switch (param.choix) {
      case 11:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 1. methode MVC 2 observations (orbite de Vaisala,      */
         /*    distance contrainte)                                */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* reel1   : valeur de la distance Terre-Astre (en ua)    */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 11_MVC2e filename_obs_MPC_in delta_AU_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            param.reel1=atof(argv[3]);
            strcpy(param.chaine2,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 12:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 2. methode MVC 2 observations (orbite de Vaisala,      */
         /*    grand axe contraint                                 */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* reel1   : valeur du demi grand axe de l'orbite (en ua) */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 12_MVC2a filename_obs_MPC_in a_AU_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            param.reel1=atof(argv[3]);
            strcpy(param.chaine2,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 13:
         /*********************************************************/
         /* 1. observations -> elements d'orbite                  */
         /* 3. methode MVC 2 observations (orbite circulaire)     */
         /*********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC */
         /* chaine2 : nom du fichier de sortie des elements       */
         /*********************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 13_MVC2c filename_obs_MPC_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 14:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 4. methode GEM 3/2 observations                        */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* reel1   : offset de courbure en arcsec (+/- 0)         */
         /* reel2   : offset de longitude en arcsec (+/- 0)        */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<6) {
            sprintf(s,"Usage: %s 14_GEM32 filename_obs_MPC_in offset_curvature_arcsec offset_longitude_arcsec filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            param.reel1=atof(argv[3]);
            param.reel2=atof(argv[4]);
            strcpy(param.chaine2,argv[5]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 15:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 5. methode GEM 3 observations                          */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 15_GEM3 filename_obs_MPC_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 16:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 6. methode MVC 3 observations (algorithme AA)          */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 16_MVC3AA filename_obs_MPC_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 17:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 7. traitement automatique d'un lot d'observations      */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 17_series filename_obs_MPC_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 18:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 8. methode MVC 3 observations (algorithme B)           */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 18_MVC3B filename_obs_MPC_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 19:
         /***********************************************************/
         /* 1. observations -> elements d'orbite                    */
         /* 9. methode MVC 2 observations (excentricite contrainte) */
         /***********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC   */
         /* reel1   : valeur de l'excentricite                      */
         /* chaine2 : nom du fichier de sortie des elements         */
         /***********************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 19_MVC2e filename_obs_MPC_in excentricity_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            param.reel1=atof(argv[3]);
            strcpy(param.chaine2,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 21:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 1. base de Bowell -> format MC                             */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* chaine2 : numero d'identification de l'asteroide           */
         /* chaine3 : nom du fichier de sortie des elements d'orbite   */
         /**************************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 21_Bowell2mc filename_astorb_in designation filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            strcpy(param.chaine3,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 22:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 2. format MPEC Daily Orbit Update -> format MC             */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MPEC D.O.U.             */
         /* chaine2 : nom du fichier au format MC                      */
         /**************************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 22_MPECDOU2mc filename_MPECDOU_in filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 23:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 3. format MPEC -> format MC                                */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MPEC                    */
         /* chaine2 : nom du fichier au format MC                      */
         /**************************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 23_MPEC2mc filename_MPEC_in designation filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 24:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 4. format MC -> format MPEC Daily Orbit Update             */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MC                      */
         /* chaine2 : nom du fichier au format MPEC D.O.U.             */
         /**************************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 24_mc2MPECDOU filename_elm_in filename_MPECDOU_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 25:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 5. format MC -> format MPEC                                */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MC                      */
         /* chaine2 : nom du fichier au format MPEC                    */
         /**************************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 25_mc2MPEC filename_elm_in designation filename_MPEC_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 31:
         /*************************************************************/
         /* 3. changement d'epoque des elements d'orbite par          */
         /*    integration numerique                                  */
         /* 1. changement d'epoque par la methode de Cowell           */
         /*************************************************************/
         /* chaine1 : nom du fichier d'entree des elements d'orbite   */
         /* date1   : date de l'epoque a calculer (aaaammjj)          */
         /* chaine2 : nom du fichier de sortie des elements d'orbite  */
         /*************************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 31_elmint filename_elm_in epoch_aaaammjj_out filename_elm_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            strcpy(param.chaine2,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 41:
         /***********************************************************/
         /* 4. elements d'orbite -> ephemeride d'un astre           */
         /*    par probleme a deux corps                            */
         /* 1. ephemeride entre deux dates                          */
         /***********************************************************/
         /* chaine1 : nom du fichier des elements d'orbite          */
         /* date1   : code du premier jour d'observation (aaaammjj) */
         /* date2   : code du dernier jour d'observation (aaaammjj) */
         /* reel1   : pas de calcul (en fraction de jours)          */
         /* chaine2 : nom du fichier de sortie de l'ephemeride      */
         /***********************************************************/
         if (argc<7) {
            sprintf(s,"Usage: %s 41_eph filename_elm_in aaaammjj_begin aaaammjj_end step_day filename_eph_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            strcpy(param.date2,argv[4]);
            param.reel1=atof(argv[5]);
            strcpy(param.chaine2,argv[6]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 42:
         /***********************************************************/
         /* 4. elements d'orbite -> ephemeride d'un astre           */
         /*    par probleme a deux corps                            */
         /* 2. ephemeride pour une date et variation du perihelie   */
         /***********************************************************/
         /* chaine1 : nom du fichier des elements d'orbite          */
         /* date1   : code du jour d'observation (aaaammjj)         */
         /* reel1   : heure TU de l'observation (hh.mmss)           */
         /* reel2   : etendue de variation de Tq (en jours)         */
         /* reel3   : pas de variation de Tq (en fraction de jours) */
         /* chaine2 : nom du fichier de sortie de l'ephemeride      */
         /***********************************************************/
         if (argc<8) {
            sprintf(s,"Usage: %s 42_ephvarTq filename_elm_in aaaammjj hh.mmss rangeTq_day stepTq_day filename_eph_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            param.reel1=atof(argv[4]);
            param.reel2=atof(argv[5]);
            param.reel3=atof(argv[6]);
            strcpy(param.chaine2,argv[7]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 43:
         /***********************************************************/
         /* 4. elements d'orbite -> ephemeride d'un astre           */
         /*    par probleme a deux corps                            */
         /* 3. ephemeride d'un lot d'astres entre deux dates        */
         /***********************************************************/
         /* chaine1 : nom du fichier des elements d'orbite          */
         /* date1   : code du premier jour d'observation (aaaammjj) */
         /* date2   : code du dernier jour d'observation (aaaammjj) */
         /* reel1   : pas de calcul (en fraction de jours)          */
         /* chaine2 : nom du fichier de sortie de l'ephemeride      */
         /***********************************************************/
         if (argc<7) {
            sprintf(s,"Usage: %s 43_ephseries filename_elm_in aaaammjj_begin aaaammdd_end step_day equinox filename_eph_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            strcpy(param.date2,argv[4]);
            param.reel1=atof(argv[5]);
            strcpy(param.chaine2,argv[6]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 51:
         /***************************************************************/
         /* 5. elements d'orbite -> ephemeride d'un astre               */
         /*    par integration numerique                                */
         /* 1. element d'orbite -> ephemeride par la methode de Cowell  */
         /***************************************************************/
         /* chaine1 : nom du fichier des elements d'orbite              */
         /* date1   : code du premier jour d'observation (aaaammjj)     */
         /* date2   : code du dernier jour d'observation (aaaammjj)     */
         /* reel1   : pas de calcul (en fraction de jours)              */
         /* chaine2 : nom du fichier de sortie de l'ephemeride          */
         /***************************************************************/
         if (argc<7) {
            sprintf(s,"Usage: %s 51_ephint filename_elm_in aaaammjj_begin aaaammdd_end step_day equinox filename_eph_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            strcpy(param.date2,argv[4]);
            param.reel1=atof(argv[5]);
            strcpy(param.chaine2,argv[6]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 61:
         /**************************************************************/
         /* 6. utilitaires (fichiers, etc...)                          */
         /* 1. simplification de la base de Bowell                     */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* chaine2 : nom du fichier de sortie                         */
         /**************************************************************/
         if (argc<4) {
            sprintf(s,"Usage: %s 61_Bowellsimplifier filename_Bowell_in filename_Bowell_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 62:
      	 /**************************************************************/
	       /* 6. utilitaires (fichiers, etc...)                          */
	       /* 2. calculs automatiques de paradist                        */
	       /**************************************************************/
	       /* chaine1 : nom du fichier d'entree (obs format MPC)         */
	       /* chaine2 : nom du fichier d'elements d'orbite               */
	       /* chaine3 : nom du fichier de sortie                         */
	       /**************************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 61_paradist filename_obs_in filename_elm_in filename_result_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.chaine2,argv[3]);
            strcpy(param.chaine3,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 71:
         /**************************************************************/
         /* 7. base de Bowell -> ephemerides quotidiennes d'asteroides */
         /* 1. selection par des criteres par defaut                   */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* date1   : code du premier jour d'observation (aaaammjj)    */
         /* date2   : code du dernier jour d'observation (aaaammjj)    */
         /**************************************************************/
         if (argc<5) {
            sprintf(s,"Usage: %s 71_ephdatabase filename_Bowell_in aaaammjj_begin aaaammjj_end", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            strcpy(param.date2,argv[4]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 72:
         /***********************************************************************/
         /* 7. base de Bowell -> ephemerides quotidiennes d'asteroides          */
         /* 2. selection par des criteres manuels                               */
         /***********************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat)          */
         /* date1   : code du premier jour d'observation (aaaammjj)             */
         /* date2   : code du dernier jour d'observation (aaaammjj)             */
         /* reel1   : limite de la magnitude minimum                            */
         /* reel2   : limite de la magnitude maximum                            */
         /* reel3   : limite en elongation                                      */
         /* reel4   : limite de la declinaison minimum                          */
         /* reel5   : limite de la declinaison maximum                          */
         /* reel6   : limite de l'incertitude minimum                           */
         /* reel7   : limite de l'incertitude maximum                           */
         /* entier1 : flag1 :  =0  par defaut                                   */
         /*                 : +=1  calculer les asteroides numerotes            */
         /*                 : +=2  calculer les asteroides provisoires          */
         /* entier2 : flag2 :  =0  pour calculer tous les types d'orbite, sinon */
         /*                 : +=2  asteroides lointains                         */
         /*                 : +=4  asteroides troyens                           */
         /*                 : +=8  Mars crossers                                */
         /*                 : +=16 Earth Grazers                                */
         /*                 : +=32 Earth Crossers                               */
         /* entier3 : flag3 :  =0  tous les types d'incertitude                 */
         /*                 : +=2  critical list                                */
         /*                 : +=4  orbites a ameliorer                          */
         /*                 : +=8  asteroides a explorer ou mesure de la masse  */
         /***********************************************************************/
         if (argc<15) {
            sprintf(s,"Usage: %s 72_ephdatabaseselect filename_Bowell_in aaaammjj_begin aaaammjj_end magmax magmin limelong_deg decmin_deg decmax_deg uncertmin uncertmax flag1 flag2 flag3", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            strcpy(param.date2,argv[4]);
            param.reel1=atof(argv[5]);
            param.reel2=atof(argv[6]);
            param.reel3=atof(argv[7]);
            param.reel4=atof(argv[8]);
            param.reel5=atof(argv[9]);
            param.reel6=atof(argv[10]);
            param.reel7=atof(argv[11]);
            param.entier1=atoi(argv[12]);
            param.entier2=atoi(argv[13]);
            param.entier3=atoi(argv[14]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      case 81:
         /**************************************************************/
         /* 8. base de Bowell -> asteroides dans un champ              */
         /* 1. tous les asteroides dans un champ circulaire            */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* date1   : code du jour de l'observation (aaaammjj)         */
         /* reel1   : heure TU de l'observation (hh.mmss)              */
         /* reel2   : ascension droite J2000 du centre (hh.mmss)       */
         /* reel3   : declinaison J2000 du centre (+dd.''ss)           */
         /* reel4   : rayon du champ (arcmin)                          */
         /* chaine2 : nom du fichier de sortie                         */
         /**************************************************************/
         if (argc<9) {
            sprintf(s,"Usage: %s 81_ephfield filename_Bowell_in aaaammjj_begin hh.mmss ra2000_hh.mmss dec2000_+dd.mmss radiusfield_arcmin filename_eph_out", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
         } else {
            strcpy(param.chaine1,argv[2]);
            strcpy(param.date1,argv[3]);
            param.reel1=atof(argv[4]);
            param.reel2=atof(argv[5]);
            param.reel3=atof(argv[6]);
            param.reel4=atof(argv[7]);
            strcpy(param.chaine2,argv[8]);
            mc_entree(&param);
            result = TCL_OK;
         }
         break;
      default :
         sprintf(s,"Usage: %s ?11|12|13|14|15|16|17|18|19|21|22|23|24|25|31|41|42|43|51|61|62|71|72|81? ?options?", argv[0]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
      } /* fin du switch */
	}
	return(result);
}


int mctcl_decode_planet(Tcl_Interp *interp, char *argv0,int *planetnum, char *planetname, char *orbitformat, char *orbitstring)
/****************************************************************************/
/* Decode automatiquement le type et le nom de la planete.          	    */
/****************************************************************************/
/* SORTIES :																*/
/* Planetnum : definit dans mc.h											*/
/* Planetname : nom complet de la planete.									*/
/* Orbitformat : nom du format de l'orbite									*/
/* Orbitstring : Definition de l'orbite										*/
/****************************************************************************/
{
   int result,code;
   char **argvv=NULL;
   int argcc;
   char name[100];

   code=Tcl_SplitList(interp,argv0,&argcc,&argvv);
   if (code==TCL_OK) {
	  /* decode le premier element */
	  strcpy(name,argvv[0]);
	  mc_strupr(name,name);
	  name[3]='\0';
	  *planetnum=OTHERPLANET;
	  if (strcmp(name,"SUN")==0) { *planetnum=SOLEIL; strcpy(planetname,"Sun"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"MOO")==0) { *planetnum=LUNE; strcpy(planetname,"Moon"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"MER")==0) { *planetnum=MERCURE; strcpy(planetname,"Mercury"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"VEN")==0) { *planetnum=VENUS; strcpy(planetname,"Venus"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"MAR")==0) { *planetnum=MARS; strcpy(planetname,"Mars"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"JUP")==0) { *planetnum=JUPITER; strcpy(planetname,"Jupiter"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"SAT")==0) { *planetnum=SATURNE; strcpy(planetname,"Saturn"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"URA")==0) { *planetnum=URANUS; strcpy(planetname,"Uranus"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"NEP")==0) { *planetnum=NEPTUNE; strcpy(planetname,"Neptune"); strcpy(orbitformat,"INTERNAL");}
	  else if (strcmp(name,"PLU")==0) { *planetnum=PLUTON; strcpy(planetname,"Pluto"); strcpy(orbitformat,"INTERNAL");}
     else {
 	    if (name[0]=='*') { *planetnum=ALLPLANETS; strcpy(planetname,""); strcpy(orbitformat,"INTERNAL");}
		 /* decode les elements suivants */
		 if (argcc>=2) {
    	    strcpy(orbitformat,argvv[1]);
	 		 mc_strupr(orbitformat,orbitformat);
          if (strcmp(orbitformat,"INTERNAL")==0) {
             strcpy(planetname,argvv[0]);
          } else {
    	       strcpy(orbitformat,argvv[argcc-2]);
	 		    mc_strupr(orbitformat,orbitformat);
  	          *planetnum=OTHERPLANET;
             strcpy(planetname,argvv[0]);
          }
		 }
		 if (argcc>=1) {
		    strcpy(orbitstring,argvv[argcc-1]);
		 } else {
			 strcpy(orbitstring,"NOTDEFINED");
		 }
	  }
      result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }
   if (argvv!=NULL) {
      Tcl_Free((char *) argvv);
   }
   return(result);
}

int mctcl_decode_topo(Tcl_Interp *interp, char *argv0,double *longmpc, double *rhocosphip,double *rhosinphip)
/*******************************************************************************/
/* Decode automatiquement la position topocentrique MPC � partir du type Home. */
/*******************************************************************************/
/* SORTIES :																                */
/* Longmpc : longitude (en radian) positive vers l'est.						    */
/* Rhocosphip : rho*cos(phi')												             */
/* Rhosinphip : rho*sin(phi')												             */
/****************************************************************************/
{
   int result,code;
   char **argvv=NULL;
   int argcc;
   char name[100],site[10],filename[255];
   double longitude,latitude,altitude;

   code=Tcl_SplitList(interp,argv0,&argcc,&argvv);
   if (code==TCL_OK) {
	  /* decode le premier element */
	  strcpy(name,argvv[0]);
	  mc_strupr(name,name);
	  longitude=0.;
	  latitude=0.;
	  altitude=0.;
	  *longmpc=0.;
	  *rhocosphip=0.;
	  *rhosinphip=0.;
	  strcpy(site,"500"); /* geocentrique */
	  strcpy(filename,"stations.txt");
	  if (strcmp(name,"GPS")==0) {
	     if (argcc>=2) { longitude=fabs(atof(argvv[1])); }
	     if (argcc>=3) {
			  strcpy(name,argvv[2]);
			  mc_strupr(name,name);
           if (name[0]=='W') { longitude*=-1.; }
		  }
	     if (argcc>=4) { latitude=atof(argvv[3]); }
	     if (argcc>=5) { altitude=atof(argvv[4]); }
		  *longmpc=longitude*(DR);
        mc_latalt2rhophi(latitude,altitude,rhosinphip,rhocosphip);
        result=TCL_OK;
	  }
	  else if (strcmp(name,"MPC")==0) {
	     if (argcc>=2) { *longmpc=fabs(atof(argvv[1]))*(DR); }
	     if (argcc>=3) { *rhocosphip=atof(argvv[2]); }
	     if (argcc>=4) { *rhosinphip=atof(argvv[3]); }
        result=TCL_OK;
	  }
	  else if (strcmp(name,"MPCSTATION")==0) {
	     if (argcc>=2) { strcpy(site,argvv[1]); }
	     if (argcc>=3) { strcpy(filename,argvv[2]); }
		  mc_lec_station_mpc(filename,site,longmpc,rhocosphip,rhosinphip);
		  result=TCL_OK;
	  }
     result=TCL_OK;
   } else {
      result = TCL_ERROR;
   }
   if (argvv!=NULL) {
      Tcl_Free((char *) argvv);
   }
   return(result);
}


int mctcl_decode_home(Tcl_Interp *interp, char *argv0,double *longitude ,char *sens, double *latitude, double *altitude, double *longmpc, double *rhocosphip,double *rhosinphip)
/****************************************************************************/
/* Decode automatiquement le type Home.                                     */
/****************************************************************************/
/* ENTREE :																                   */
/* argv0 : chaine de caracteres de type Home.                               */
/*        																                   */
/* SORTIES :																                */
/* Longitude : longitude (en radian) >=0 et <=180.                          */
/* Sens : E|W                                                               */
/* Latitude : latitude (en radian) >=-90 et <=+90.                          */
/* Longmpc : longitude (en radian) positive vers l'est.						    */
/* Rhocosphip : rho*cos(phi')												             */
/* Rhosinphip : rho*sin(phi')												             */
/****************************************************************************/
{
   int result=TCL_ERROR,code;
   char **argvv=NULL;
   int argcc;
   char name[100],site[10],filename[255];

   *longitude=0.;
	strcpy(sens,"+");
	*latitude=0.;
	*altitude=0.;
	*longmpc=0.;
	*rhocosphip=0.;
	*rhosinphip=0.;
   code=Tcl_SplitList(interp,argv0,&argcc,&argvv);
   if (code==TCL_OK) {
      /* decode le premier element */
	   strcpy(name,argvv[0]);
	   mc_strupr(name,name);
      strcpy(site,"500"); /* geocentrique */
      strcpy(filename,"stations.txt");
      result=TCL_ERROR;
      if (strcmp(name,"GPS")==0) {
         if (argcc>=2) { *longitude=fabs(atof(argvv[1])); }
	      if (argcc>=3) {
			   strcpy(name,argvv[2]);
			   mc_strupr(name,name);
            if (name[0]=='W') {
					(*longitude)*=-1.;
				}
		   }
	      if (argcc>=4) { *latitude=atof(argvv[3]); }
	      if (argcc>=5) { *altitude=atof(argvv[4]); }
		   *longmpc=*longitude*(DR);
         mc_latalt2rhophi(*latitude,*altitude,rhosinphip,rhocosphip);
         result=TCL_OK;
	   }
	   else if (strcmp(name,"MPC")==0) {
   	   if (argcc>=2) { *longmpc=fabs(atof(argvv[1]))*(DR); }
	      if (argcc>=3) { *rhocosphip=atof(argvv[2]); }
	      if (argcc>=4) { *rhosinphip=atof(argvv[3]); }
         mc_rhophi2latalt(*rhosinphip,*rhocosphip,latitude,altitude);
         result=TCL_OK;
      }
	   else if (strcmp(name,"MPCSTATION")==0) {
	      if (argcc>=2) { strcpy(site,argvv[1]); }
	      if (argcc>=3) { strcpy(filename,argvv[2]); }
		   mc_lec_station_mpc(filename,site,longmpc,rhocosphip,rhosinphip);
         mc_rhophi2latalt(*rhosinphip,*rhocosphip,latitude,altitude);
		   result=TCL_OK;
	   }
		(*latitude)*=(DR);
		if (*longmpc>PI) {
			*longitude=2*PI-*longmpc;
			strcpy(sens,"W");
		} else {
			*longitude=*longmpc;
			strcpy(sens,"E");
		}
      if (argvv!=NULL) {
         Tcl_Free((char *) argvv);
      }
   }
   return(result);
}

int Cmd_mctcl_home2gps(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Transcope le type Home en format GPS                                     */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[255],sens[10];
   double longitude,latitude,altitude,longmpc,rhocosphip,rhosinphip;

   if(argc<=1) {
      sprintf(s,"Usage: %s Home", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result=mctcl_decode_home(interp,argv[1],&longitude,sens,&latitude,&altitude,&longmpc,&rhocosphip,&rhosinphip);
		if (result==TCL_ERROR) {
         Tcl_SetResult(interp,"Input string is not regonized amongst Home type",TCL_VOLATILE);
		} else {
         sprintf(s,"GPS %12f %s %12f %f",longitude/(DR),sens,latitude/(DR),altitude);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_OK;
		}
	}
	return(result);
}

int Cmd_mctcl_home2mpc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Transcope le type Home en format MPC                                     */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[255],sens[10];
   double longitude,latitude,altitude,longmpc,rhocosphip,rhosinphip;

   if(argc<=1) {
      sprintf(s,"Usage: %s Home", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result=mctcl_decode_home(interp,argv[1],&longitude,sens,&latitude,&altitude,&longmpc,&rhocosphip,&rhosinphip);
		if (result==TCL_ERROR) {
         Tcl_SetResult(interp,"Input string is not regonized amongst Home type",TCL_VOLATILE);
		} else {
         sprintf(s,"MPC %12f %12f %12f",longmpc/(DR),rhocosphip,rhosinphip);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_OK;
		}
	}
	return(result);
}


int mctcl_debug(char *filename,char *type,char *string)
/****************************************************************************/
/* Pour debugger */
/****************************************************************************/
{
   FILE *fid;
   fid=fopen(filename,type);
   fprintf(fid,"%s\n",string);
   fclose(fid);
   return(1);
}

int Cmd_mctcl_libration(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* calcule les parametres de la libration de la Lune.                       */
/****************************************************************************/
/* mc_libration Date ?Home?                                                 */
/* ex : mc_libration 1992-04-12T00:00:00 {GPS 2 E 43 148}                   */
/* lonc : longitude selenographique du centre topocentrique                 */
/* latc : latitude selenographique du centre topocentrique                  */
/* p    : position de l'angle de l'axe de rotation (axe des poles)          */
/* lons : longitude selenographique du centre heliocentrique                */
/* lats : latitude selenographique du centre heliocentrique                 */
/* c0   : colongitude selenographique du centre heliocentrique              */
/****************************************************************************/
{
   double longi=0.,rhocosphip=0.,rhosinphip=0.;
   char s[100];
   double jj,lonc,latc,p,lons,lats,c0;

   if(argc<=1) {
      sprintf(s,"Usage: %s Date ?Home?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	  /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      if (argc==3) {
         /* --- decode le Home ---*/
         mctcl_decode_topo(interp,argv[2],&longi,&rhocosphip,&rhosinphip);
      }
      mc_libration(jj,longi,rhocosphip,rhosinphip,&lonc,&latc,&p,&lons,&lats);
      lons/=(DR);
      c0=90.-lons;
      c0=fmod(720+c0,360.);
      sprintf(s,"%10f %10f %10f %10f %10f %10f",lonc/(DR),latc/(DR),p/(DR),lons,lats/(DR),c0);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_ephem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* calcule l'ephemeride d'une liste de dates et de planetes.                */
/****************************************************************************/
/* ephem ListPlanets ?ListDates ListFormat?                                 */
/*       -topo ListSites													             */
/*       -format value ...                                                  */
/*                                                                          */
/* Entrees :                 												             */
/* {ListPlanets}                   											          */
/*   Le 1er element contient le nom de la planete :							    */
/*    * pour toutes les planetes, sinon,									          */
/*    SUN MOON MERCURY VENUS MARS JUPITER SATURN URANUS NEPTUNE PLUTO       */
/*    Name pour un astre dont les elements sont definits par les 2eme et    */
/*     et 3eme elements :													             */
/*   Le 2eme element contient le format des elements d'orbite               */
/*    INTERNAL (defaut) pour les planetes classiques.						       */
/*    BOWELL pour le format de Bowell 									             */
/*    BOWELLFILE pour le format de Bowell sous forme d'un fichier			    */
/*    DAILYMPECFILE Daily MPEC sous forme d'un fichier						    */
/*    DAILYMPEC Daily MPEC													             */
/*   Le 3eme element contient la definition des elements d'orbite :			 */
/*    Rien pour INTERNAL													             */
/*    NameFile pour designer le fichier des elements						       */
/*    String pour la chaine qui contient les elements.						    */
/*																			                   */
/* {ListDates}														                      */
/*  Le 1er element contient le debut de la date.                            */
/*    NOW (defauf) pour designer l'instant actuel. 							    */
/*    NOW0 : Pour designer la date actuelle a 0h   							    */
/*    NOW1 : Pour designer la date de demain a 0h   						       */
/*    YYYY-MM-DDThh:mm:ss.ss : Format Iso du Fits.						          */
/*    nombre decimal >= 1000000 : Jour Julien								       */
/*    nombre decimal <  1000000 : Jour Julien Modifie						       */
/*    Year : suivi des elements facultatifs suivants, dans l'ordre :		    */
/*     Month Day Hour Minute Second (Format style Iso mais avec les espaces)*/
/*																			                   */
/* {ListFormat}																             */
/*   nombre quelconque d'elements suivants :                                */
/*   {OBJENAME RA DEC} par defaut.											          */
/*   OBJENAME : nom de l'astre												          */
/*   RA : Ascension droite J2000.0 en degres decimaux.						    */
/*   RAH : Ascension droite J2000.0 en heure entiere						       */
/*   RAH.H : Ascension droite J2000.0 en heure decimale						    */
/*   RAM : Ascension droite J2000.0 en minute de temps entiere				    */
/*   RAM.M : Ascension droite J2000.0 en minute decimale    				    */
/*   RAS : Ascension droite J2000.0 en seconde de temps entiere     		    */
/*   RAS.S : Ascension droite J2000.0 en seconde de temps decimale			 */
/*   DEC : Declinaison J2000.0 en degres decimaux.							       */
/*   DECD : Declinaison J2000.0 en degre entier								       */
/*   DECM : Declinaison J2000.0 en minute de degre entiere					    */
/*   DECM.M : Declinaison J2000.0 en minute de degre decimale				    */
/*   DECS : Declinaison J2000.0 en seconde de temps entiere 				    */
/*   DECS.S : Declinaison J2000.0 en seconde de temps decimale				    */
/*   MAG : Magnitude														                */
/*   DELTA : Distance a la Terre en U.A.									          */
/*   R : Distance Astre-Soleil en U.A.										          */
/*   ELONG : Elongation par rapport au Soleil								       */
/*   MOONELONG : distance angulaire a la Lune								       */
/*   PHASE : Phase de l'astre.												          */
/*   APPDIAM : diametre apparent en degres.									       */
/*   AZIMUTH : azinuth en degres (utiliser l'option -toto)                  */
/*   ALTITUDE : hauteur sur l'horizon (utiliser l'option -topo)             */
/*   HA : Angle horaire en degres (utiliser l'option -topo)                 */
/*   APPDIAMEQU : diametre apparent equatorial (degres).                    */
/*   APPDIAMPOL : diametre apparent equatorial (degres).                    */
/*   LONGI : longitude du meridien central de l'astre dans le systeme I     */
/*   LONGII : longitude du meridien central de l'astre dans le systeme II   */
/*   LONGIII : longitude du meridien central de l'astre dans le systeme III */
/*   LATI : latitude planetocentrique du centre de l'astre                  */
/*   POSNORTH : angle de position du pole nord de l'astre.                  */
/*   POSSUN : angle de position du limbe brillant.                          */
/*																			                   */
/* -topo {ListSites}														                */
/*   Le 1er element definit le type de coordonnees :						       */
/*    GPS : pour des coordonnees longitude,latitude,altitude.				    */
/*    MPC : Pour LongitudeMPC rhocosphip rhosinphip							    */
/*    MPCSTATION : pour un site connu du MPC.								       */
/*   Les arguments suivants dependant du type de coordonnees.				    */
/*    Si GPS : 																             */
/*     2eme element : Longitude (degres, positive entre 0 et 180)			    */
/*     3eme element : Sens (E ou W pour la longitude)						       */
/*     4eme element : Latitude (en degres, pos. pour nord, neg. pour sud).	 */
/*    Si MPC : 																             */
/*     2eme element : LongitudeMPC (degres, positive vers l'est de 0 a 360) */
/*     3eme element : Rhocosphip											             */
/*     4eme element : Rhosinphip											             */
/*    Si MPCSTATION : 														             */
/*     2eme element : Indice de la station									       */
/*     3eme element : FileName du fichier contenant la base de donnees.		 */
/*																			                   */
/* -dec> Value 																             */
/*   Designe que la sortie ne contient que les astres ayant une declinaison */
/*   superieure a Value.													             */
/*																			                   */
/* -dec< Value 																             */
/*   Designe que la sortie ne contient que les astres ayant une declinaison */
/*   inferieure a Value.													             */
/*																			                   */
/* Les autres options, du meme style sont :									       */
/* -mag> -mag< -delta< -delta> -r< -r> -elong< -elong> -moonelong<			 */
/* -moonelong> -altitude< -altitude> -azimuth< -azimuth> -ha< -ha>       	 */
/*	                                                                         */
/* Les options valides acvec les bases de donnees d'asteroides :            */
/* -prov 0 : pour ne pas calculer les ast. a designation provisioire        */
/* -numb 0 : pour ne pas calculer les ast. numerotes                        */
/*                                                                          */
/* Sorties :																                */
/* Liste formatee comme definit en entree par ListFormat					       */
/* Un dernier element est toujours ajoute et contient un comentaire.        */
/****************************************************************************/
   double jj,jour=0.;
   double *jds=NULL;
   int result,code,planetnum,kd,kf,kp=0,ko,sortie=NO,kpp,k1,k2,kppp=0;
   char s0[100],s[1024],name[50],name2[50];
   char objename[10000],orbitformat[15],orbitstring[300],orbitfile[1024];
   char **dates=NULL,**formats=NULL,**planets=NULL;
   char charsigne[2];
   int nbdates,nbformats,year,month,nbplanets,stationfilefound,stationfound;
   double asd,dec,delta,ras,decs;
   int rah,ram,decd,decm,ok4compute,ok4print,ok4moonelong;
   double mag,phase,elong,diamapp,r,asdmoon,decmoon,moonelong,posangle;
   double longmpc=0.,rhocosphip=0.,rhosinphip=0.;
   int ok4azimcoord,nextindex,orbitfilefound=YES,orbitisgood=NO;
   double latitude,altitude,tsl;
   double ha,az,h;
   struct asterident aster;
   struct elemorb elem;
   double diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north,long1_sun,lati_sun;
   FILE *fichier_in=NULL;
   double timelim=1e3;
   time_t ltime;
   long t0,t1;
   Tcl_DString dsptr;

   if(argc<=1) {
      sprintf(s,"Usage: %s ListObjects ?ListDates ListFormat? ?-topo Home? ?-dec> value? ?-dec< value? ?-mag> value? ?-mag< value? ?-delta< value? ?-delta> value? ?-r< value? ?-r> value? ?-elong< value? ?-elong> value? ?-moonelong< value? ?-moonelong> value? ?-altitude< value? ?-altitude> value? ?-azimuth< value? ?-azimuth> value? ?-ha< value? ?-ha>value? ? ?-prov 0|1? ?-numb 0|1?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);;
   } else {
	   result=TCL_OK;
      t0=time(&ltime);
	   Tcl_DStringInit(&dsptr);
	   /* --- decode le type de planete ---*/
      mctcl_decode_planet(interp,argv[1],&planetnum,objename,orbitformat,orbitfile);
      if ((planetnum>=SOLEIL)&&(planetnum<=LUNE)) {
   	   /* --- lit la liste des planetes */
         strcpy(objename,argv[1]);
		} else if (planetnum==ALLPLANETS) {
         /* --- lit la liste de toutes les planetes */
         strcpy(objename,"sun moo mer ven mar jup sat ura nep plu");
      }
      /* --- lit la liste de tous les astres demandes */
      Tcl_SplitList(interp,objename,&nbplanets,&planets);
      /* --- decode les dates ---*/
	   nextindex=2;
	   if (argc<=2) {
		   code=Tcl_SplitList(interp,"NOW",&nbdates,&dates);
	   } else if (argv[nextindex][0]=='-') {
		   /* on decode une option en 2eme element */
		   code=Tcl_SplitList(interp,"NOW",&nbdates,&dates);
		   nextindex--;
	   } else {
		   code=Tcl_SplitList(interp,argv[2],&nbdates,&dates);
	   }
      if (code==TCL_OK) {
         jds=(double*)calloc(nbdates,sizeof(double));
	      for (kd=0;kd<nbdates;kd++) {
	  	      mctcl_decode_date(interp,dates[kd],&jds[kd]);
		   }
	   } else {
		   result=TCL_ERROR;
	   }
      /* --- decode le format de sortie ---*/
	   nextindex++;
	   if (argc<=3) {
         code=Tcl_SplitList(interp,"OBJENAME RA DEC",&nbformats,&formats);
	   } else if (argv[nextindex][0]=='-') {
		   /* on decode une option en 2eme element */
		   code=Tcl_SplitList(interp,"OBJENAME RA DEC",&nbformats,&formats);
		   nextindex--;
	   } else {
	      strcpy(s,argv[3]);
		   mc_strupr(s,s);
         if ((int)strlen(s)>3) {s[3]='\0';}
		   if (strcmp(s,"DEF")==0) {
            code=Tcl_SplitList(interp,"OBJENAME RA DEC",&nbformats,&formats);
		   } else {
            code=Tcl_SplitList(interp,argv[3],&nbformats,&formats);
		   }
	   }
	   /* --- fin de decodage ---*/
	   ok4moonelong=NO;
	   ok4azimcoord=NO;
	   if (code==TCL_OK) {
  	      for (kf=0;kf<nbformats;kf++) {
	         mc_strupr(formats[kf],formats[kf]);
            if (strcmp(formats[kf],"MOONELONG")==0) { ok4moonelong=YES; }
            else if ((strcmp(formats[kf],"AZIMUTH")==0)||(strcmp(formats[kf],"AZIMUT")==0)) { ok4azimcoord=YES; }
            else if (strcmp(formats[kf],"ALTITUDE")==0) { ok4azimcoord=YES; }
            else if ((strcmp(formats[kf],"AZIMUTH")==0)||(strcmp(formats[kf],"AZIMUT")==0)) { ok4azimcoord=YES; }
            else if ((strcmp(formats[kf],"AZIMUTH")==0)||(strcmp(formats[kf],"AZIMUT")==0)) { ok4azimcoord=YES; }
            else if (strcmp(formats[kf],"HA")==0) { ok4azimcoord=YES; }
            else if (strcmp(formats[kf],"HA")==0) { ok4azimcoord=YES; }
		   }
	   } else {
         result=TCL_ERROR;
	   }
      /* --- decode l'option topocentrique -topo ---*/
	   /* --- repere si moonelong etc. fait partie des options ---*/
	   longmpc=0.;
	   rhocosphip=0.;
	   rhosinphip=0.;
	   stationfilefound=YES;
	   stationfound=YES;
      for (ko=nextindex;ko<argc-1;ko++) {
	      strcpy(s,argv[ko]);
		   mc_strupr(s,s);
	      if (strcmp(s,"-TOPO")==0) {
			   mctcl_decode_topo(interp,argv[ko+1],&longmpc,&rhocosphip,&rhosinphip);
			   if (longmpc==10.) { stationfilefound=NO; longmpc=0.; }
			   if (longmpc==15.) { stationfound=NO; longmpc=0.; }
		   }
         else if (strcmp(s,"-MOONELONG>")==0) { ok4moonelong=YES; }
         else if (strcmp(s,"-MOONELONG<")==0) { ok4moonelong=YES; }
         else if (strcmp(s,"-ALTITUDE>")==0) { ok4azimcoord=YES; }
         else if (strcmp(s,"-ALTITUDE<")==0) { ok4azimcoord=YES; }
         else if ((strcmp(s,"-AZIMUTH>")==0)||(strcmp(s,"-AZIMUT>")==0)) { ok4azimcoord=YES; }
         else if ((strcmp(s,"-AZIMUTH<")==0)||(strcmp(s,"-AZIMUT<")==0)) { ok4azimcoord=YES; }
         else if (strcmp(s,"-HA>")==0) { ok4azimcoord=YES; }
         else if (strcmp(s,"-HA<")==0) { ok4azimcoord=YES; }
         else if (strcmp(s,"-TIMELIM")==0) { timelim=atof(argv[ko+1]); }
	   }
	   /* === calculs ===*/
      /* ============================*/
	   /* --- boucle sur les dates ---*/
      /* ============================*/
	   for (kd=0;kd<nbdates;kd++) {
		   jj=jds[kd];
		   /* --- position de la Lune si on veut l'elongation par rapport a la Lune ---*/
		   if (ok4moonelong==YES) {
            mc_adlunap(jj,longmpc,rhocosphip,rhosinphip,&asdmoon,&decmoon,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
         }
 		   /* --- Temps sideral et latitude si on veut l'azimuth et la hauteur ---*/
		   if (ok4azimcoord==YES) {
            mc_tsl(jj,-longmpc,&tsl);
            mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
			   latitude*=((PI)/180);
         }
		   /* =============================*/
 		   /* -- boucle sur les planetes --*/
		   /* =============================*/
		   kp=0;
  	      ok4compute=NO;
		   do {
   			asd=0.;
            dec=0.;
            delta=0.;
            mag=0.;
            diamapp=0.;
            elong=0.;
            phase=0.;
            r=0.;
            diamapp_equ=0.;
            diamapp_pol=0.;
            long1=0.;
            long2=0.;
            long3=0.;
            lati=0.;
            posangle_sun=0.;
            posangle_north=0.;
            strcpy(objename,"");
			   /* --------------------------------*/
			   /* --- cas de planetes INTERNAL ---*/
			   /* --------------------------------*/
            if (((planetnum>=SOLEIL)&&(planetnum<=LUNE))||(planetnum==ALLPLANETS)) {
			      sortie=NO;
			      if (kp>=nbplanets) { sortie=YES; break; }
      	      strcpy(name,planets[kp]);
			      mc_strupr(name,name);
	            name[3]='\0';
 	            if (strcmp(name,"SUN")==0) { planetnum=SOLEIL; strcpy(objename,"Sun"); }
	            else if (strcmp(name,"MOO")==0) { planetnum=LUNE; strcpy(objename,"Moon"); }
	            else if (strcmp(name,"MER")==0) { planetnum=MERCURE; strcpy(objename,"Mercury"); }
	            else if (strcmp(name,"VEN")==0) { planetnum=VENUS; strcpy(objename,"Venus"); }
	            else if (strcmp(name,"MAR")==0) { planetnum=MARS; strcpy(objename,"Mars"); }
	            else if (strcmp(name,"JUP")==0) { planetnum=JUPITER; strcpy(objename,"Jupiter"); }
	            else if (strcmp(name,"SAT")==0) { planetnum=SATURNE; strcpy(objename,"Saturn"); }
	            else if (strcmp(name,"URA")==0) { planetnum=URANUS; strcpy(objename,"Uranus"); }
	            else if (strcmp(name,"NEP")==0) { planetnum=NEPTUNE; strcpy(objename,"Neptune"); }
	            else if (strcmp(name,"PLU")==0) { planetnum=PLUTON; strcpy(objename,"Pluto"); }
	            /* --- calcule les coordonnees topocentriques ---*/
		         if (planetnum==SOLEIL) {
   			      mc_adsolap(jj,longmpc,rhocosphip,rhosinphip,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
			         ok4compute=OK;
		         } else if ((planetnum>=MERCURE)&&(planetnum<=PLUTON)) {
                  mc_adplaap(jj,longmpc,rhocosphip,rhosinphip,planetnum,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
			         ok4compute=OK;
		         } else if (planetnum==LUNE) {
          	      mc_adlunap(jj,longmpc,rhocosphip,rhosinphip,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
			         ok4compute=OK;
		         }
               kp++;

			   /* ---------------------------*/
			   /* --- cas d'asteroides *  ---*/
			   /* ---------------------------*/
		      } else if (planetnum==OTHERPLANET) {
			      sortie=NO;
               t1=time(&ltime)-t0;
               if (t1>timelim) { sortie=YES; break; }
               if ((strcmp(planets[0],"*")!=0)&&(kp>=nbplanets)) { sortie=YES; break; }
			      if (strcmp(planets[0],"*")!=0) { 
       	         strcpy(name,planets[kp]);
			         mc_strupr(name,name);
               } else {
       	         strcpy(name,"*");
               }
			      /* --- ouverture du fichier de la base d'orbite ---*/
			      if (fichier_in==NULL) {
   				   if ((strcmp(orbitformat,"BOWELLFILE")==0)||(strcmp(orbitformat,"MPCFILE")==0)) {
                     if ((fichier_in=fopen(orbitfile,"rt") ) == NULL) {
					         orbitfilefound=NO;
					         sortie=YES;
					         orbitisgood=NO;
						      kp=-1;
					         break;
					      }
                  }
               }
      	      /* --- lecture d'une ligne de la base d'orbite ---*/
			      if (strcmp(orbitformat,"BOWELLFILE")==0) {
      			   if (feof(fichier_in)!=0) { sortie=YES;break;}
                  if (fgets(orbitstring,300,fichier_in)==0) {
			            strcpy(orbitstring,"");
			         }
                  mc_bow_dec1(orbitstring,&aster);
			         if (strcmp(aster.name,"")==0) {
	  			         orbitisgood=NO;
			         } else {
	  			         orbitisgood=YES;
				      }
			      } else if (strcmp(orbitformat,"MPCFILE")==0) {
    			      if (feof(fichier_in)!=0) {sortie=YES;break;}
                  if (fgets(orbitstring,300,fichier_in)==0) {
			            strcpy(orbitstring,"");
			         }
				      mc_mpc_dec1(orbitstring,&aster);
   	            if (strcmp(aster.name,"")==0) {
  	  			         orbitisgood=NO;
			         } else {
					      orbitisgood=YES;
				      }
			      } else {
				      orbitisgood=NO;
			      }
			      /* --- selection des options pour les bases de donnees ---*/
			      if (orbitisgood==YES) {
                  for (kpp=0;kpp<nbplanets;kpp++) {
      	            strcpy(name,planets[kpp]);
			            mc_strupr(name,name);
                     if (strcmp(planets[0],"*")==0) {
                        orbitisgood=YES;
                        break;
                     } else {
		                  mc_strupr(aster.name,name2);
                        orbitisgood=NO;
                        if (strcmp(name,name2)==0) {
                           orbitisgood=YES;
                           break;
                        }
                        for (k1=0,k2=0;k1<(int)strlen(name2);k1++) {
                           if (name2[k1]!=' ') { name2[k2]=name2[k1]; k2++; }
                        }
                        name2[k2]='\0';
                        if (strcmp(name,name2)==0) {
                           orbitisgood=YES;
                           break;
                        }
                        sprintf(name2,"%d",aster.num);
                        if (strcmp(name,name2)==0) {
                           orbitisgood=YES;
                           break;
                        }
                     }
                  }
 			         for (ko=nextindex;ko<argc-1;ko++) {
			            strcpy(name,argv[ko]);
			            mc_strupr(name,name);
			            if (strcmp(name,"-NUMB")==0) { if (atof(argv[ko+1])==0) { if (aster.num>0) { orbitisgood=NO; }}}
			            if (strcmp(name,"-PROV")==0) { if (atof(argv[ko+1])==0) { if (aster.num<=0) { orbitisgood=NO; }}}
				      }

               }
			      /* --- calcul ---*/
			      ok4compute=PB;
			      if (orbitisgood==YES) {
                  kp++;
   			      mc_aster2elem(aster,&elem);
			         sprintf(objename,elem.designation);
			         mc_adasaap(jj,longmpc,rhocosphip,rhosinphip,elem,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
			         ok4compute=OK;
			      }
			   }

			/* ------------------------*/
			/* --- format de sortie ---*/
			/* ------------------------*/
			if (ok4compute==OK) {
			   if (ok4moonelong==YES) {
			      mc_sepangle(asd,asdmoon,dec,decmoon,&moonelong,&posangle);
			   }
			   ha=0.;
			   h=0.;
			   az=0.;
			   if (ok4azimcoord==YES) {
			      ha=tsl-asd;
			      ha=fmod(4*PI+ha,2*PI);
			      mc_hd2ah(ha,dec,latitude,&az,&h);
	           }
			   ok4print=YES;
			   for (ko=nextindex;ko<argc-1;ko++) {
			      strcpy(s,argv[ko]);
			      mc_strupr(s,s);
			      if (strcmp(s,"-DEC>")==0) { if ((dec/(DR))<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-DEC<")==0) { if ((dec/(DR))>atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-ELONG>")==0) { if ((elong/(DR))<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-ELONG<")==0) { if ((elong/(DR))>atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-DELTA>")==0) { if ((delta)<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-DELTA<")==0) { if ((delta)>atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-R>")==0) { if ((r)<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-R<")==0) { if ((r)>atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-MAG>")==0) { if ((mag)<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-MAG<")==0) { if ((mag)>atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-MOONELONG>")==0) { if ((moonelong/(DR))<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-MOONELONG<")==0) { if ((moonelong/(DR))>atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-ALTITUDE>")==0) { if ((h/(DR))<atof(argv[ko+1])) { ok4print=NO; }}
			      if (strcmp(s,"-ALTITUDE<")==0) { if ((h/(DR))>atof(argv[ko+1])) { ok4print=NO; }}
			      if ((strcmp(s,"-AZIMUTH>")==0)||(strcmp(s,"-AZIMUT>")==0)) { if (((az/(DR))<atof(argv[ko+1]))||((az/(DR))>360.-atof(argv[ko+1]))) { ok4print=NO; }}
			      if ((strcmp(s,"-AZIMUTH<")==0)||(strcmp(s,"-AZIMUT<")==0)) { if (((az/(DR))>atof(argv[ko+1]))&&((az/(DR))<360.-atof(argv[ko+1]))) { ok4print=NO; }}
			      if (strcmp(s,"-HA>")==0) { if (((ha/(DR))<atof(argv[ko+1]))||((ha/(DR))>360.-atof(argv[ko+1]))) { ok4print=NO; }}
			      if (strcmp(s,"-HA<")==0) { if (((ha/(DR))>atof(argv[ko+1]))&&((ha/(DR))<360.-atof(argv[ko+1]))) { ok4print=NO; }}
			   }
			   if ((ok4print==YES)&&(ok4compute==OK)) {
                kppp++;
                mc_deg2h_m_s(asd/(DR),&rah,&ram,&ras);
                mc_deg2d_m_s(dec/(DR),charsigne,&decd,&decm,&decs);
		          mc_jd_date(jj,&year,&month,&jour);
		          strcpy(s,"");
	             Tcl_DStringAppend(&dsptr,"{",-1);
		          for (kf=0;kf<nbformats;kf++) {
                   if (strcmp(formats[kf],"RAH")==0) { sprintf(s0,"%d",(int)rah); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"RAH.H")==0) { sprintf(s0,"%.11f",rah+(ram+ras/60)/60); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"RAM")==0) { sprintf(s0,"%d",(int)ram); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"RAM.M")==0) { sprintf(s0,"%.8f",ram+ras/60); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"RAS")==0) { sprintf(s0,"%d",(int)ras); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"RAS.S")==0) { sprintf(s0,"%f",ras); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"RA")==0) { sprintf(s0,"%.12f",asd/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DEC")==0) { sprintf(s0,"%.12f",dec/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
     	             else if (strcmp(formats[kf],"DECD")==0) { sprintf(s0,"%s%d",charsigne,(int)decd); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DECM")==0) { sprintf(s0,"%d",(int)decm); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DECM.M")==0) { sprintf(s0,"%.8f",decm+decs/60); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DECS")==0) { sprintf(s0,"%d",(int)decs); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DECS.S")==0) { sprintf(s0,"%f",decs); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"JD")==0) { sprintf(s0,"%15f",jj); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"YEAR")==0) { sprintf(s0,"%d",year); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"MONTH")==0) { sprintf(s0,"%d",month); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DAY")==0) { sprintf(s0,"%.12f",jour); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"R")==0) { sprintf(s0,"%.12f",r); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"DELTA")==0) { sprintf(s0,"%.12f",delta); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"ELONG")==0) { sprintf(s0,"%.12f",elong/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"MOONELONG")==0) { sprintf(s0,"%.12f",moonelong/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"HA")==0) { sprintf(s0,"%.12f",ha/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if ((strcmp(formats[kf],"AZIMUTH")==0)||((strcmp(formats[kf],"AZIMUT")==0))) { sprintf(s0,"%.12f",az/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"ALTITUDE")==0) { sprintf(s0,"%.12f",h/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"PHASE")==0) { sprintf(s0,"%.12f",phase/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"MAG")==0) { sprintf(s0,"%f",mag); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"APPDIAM")==0) { sprintf(s0,"%.12f",diamapp/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"APPDIAMEQU")==0) { sprintf(s0,"%.12f",diamapp_equ/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"APPDIAMPOL")==0) { sprintf(s0,"%.12f",diamapp_pol/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"LONGI")==0) { sprintf(s0,"%.12f",long1/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"LONGII")==0) { sprintf(s0,"%.12f",long2/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"LONGIII")==0) { sprintf(s0,"%.12f",long3/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"LATI")==0) { sprintf(s0,"%.12f",lati/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"LATI_SUN")==0) { sprintf(s0,"%.12f",lati_sun/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"LONGI_SUN")==0) { sprintf(s0,"%.12f",long1_sun/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"POSNORTH")==0) { sprintf(s0,"%.12f",posangle_north/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"POSSUN")==0) { sprintf(s0,"%.12f",posangle_sun/(DR)); Tcl_DStringAppend(&dsptr,s0,-1); }
		             else if (strcmp(formats[kf],"OBJENAME")==0) { sprintf(s0,"%s",objename); Tcl_DStringAppend(&dsptr,s0,-1); }
				       Tcl_DStringAppend(&dsptr," ",-1);
		          }
			       Tcl_DStringAppend(&dsptr,"} ",-1);
                result = TCL_OK;
            }
			} /* fin de formatage des resultats */
		 } while (sortie==NO); /* fin de boucle sur les planetes pour une date donnee */
       if (fichier_in!=NULL) {
          fclose(fichier_in);
          fichier_in=NULL;
       }
	  } /* fin de boucle sur la date */
	  /* === sortie et destructeurs ===*/
	  if (jds!=NULL) { free(jds); }
      if (dates!=NULL) { Tcl_Free((char *) dates); }
      if (formats!=NULL) { Tcl_Free((char *) formats); }
      if (planets!=NULL) { Tcl_Free((char *) planets); }
   }
   /* --- le dernier element de la liste contient un commentaire ---*/
   if (stationfilefound==NO) {
	  Tcl_DStringAppend(&dsptr,"{Pb",-1);
	  strcpy(s," {StationFile not found. J2000.0 ooordinates are geocentric.}");
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringAppend(&dsptr,"}",-1);
   } else if (stationfound==NO) {
	  Tcl_DStringAppend(&dsptr,"{Pb",-1);
	  strcpy(s," {Station not found. J2000.0 ooordinates are geocentric.}");
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringAppend(&dsptr,"}",-1);
   } else if (orbitfilefound==NO) {
	  Tcl_DStringAppend(&dsptr,"{Pb",-1);
	  sprintf(s," {OrbitFile %s not found}",orbitfile);
	  Tcl_DStringAppend(&dsptr,s,-1);
	  sprintf(s," %d",kp);
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringAppend(&dsptr,"}",-1);
   } else {
	  Tcl_DStringAppend(&dsptr,"{Ok",-1);
	  sprintf(s," {J2000.0 coordinates} %d",kppp);
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringAppend(&dsptr,"}",-1);
   }
   Tcl_DStringResult(interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return result;
}

int Cmd_mctcl_readcat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Lit les donnees de catalogues d'etoiles.                                 */
/****************************************************************************/
/* readcat {Listfield} {ListObjects} {ListOutput}                           */
/*         -date                                                            */
/*         -topo                                                            */
/*         -objmax                                                          */
/*         -format value                                                    */
/*                                                                          */
/*                                                                          */
/* Entrees :                 												             */
/* {ListField}                                                              */
/*   Le 1er argument contient le type de definition de champ.               */
/*    BUFFER : pour un buffer de Audela (lecture de l'entete d'image).      */
/*             Le deuxieme argument contient le numero de buffer.           */
/*    OPTIC : pour entrer manuellement les valeurs avec les parametres      */
/*           optiques instrumentaux (focale, etc.)                          */
/*           Les arguments suivants definissent le champ :                  */
/*           NAXIS1 nombre de pixels sur x                                  */
/*           NAXIS2 nombre de pixels sur y                                  */
/*           FOCLEN focale de l'objectif (en m)                             */
/*           PIXSIZE1 taille du pixel sur x (en m/pixel)                    */
/*                    n�gatif si RA croissant avec x decroissant.           */
/*           PIXSIZE2 taille du pixel sur y (en m/pixel)                    */
/*                    n�gatif si DEC croissant avec y decroissant.          */
/*           CROTA2 angle de rotation du champ (degres partir du nord->est) */
/*           RA Ascension droite du centre (degres)                         */
/*           DEC Declinaison du centre (degres)                             */
/*                                                                          */
/* {ListObjects}                   											          */
/*   Le 1er element contient le nom de l'objet :	   						    */
/*    * pour toutes les objets, sinon,									             */
/*    SUN MOON MERCURY VENUS MARS JUPITER SATURN URANUS NEPTUNE PLUTO       */
/*    Name pour un astre dont les elements sont definits par les 2eme et    */
/*     et 3eme elements :													             */
/*   Le 2eme element contient le format des elements d'orbite               */
/*    INTERNAL (defaut) pour les planetes classiques.						       */
/*    BOWELL pour le format de Bowell 									             */
/*    BOWELLFILE pour le format de Bowell sous forme d'un fichier			    */
/*    DAILYMPECFILE Daily MPEC sous forme d'un fichier						    */
/*    DAILYMPEC Daily MPEC													             */
/*    ASTROMMICROCAT pour le format Microcat astrometrique                  */
/*    LONEOSMICROCAT pour le format Microcat du Loneos seulement.           */
/*    TYCHOMICROCAT pour le format Microcat du Tycho seulement.             */
/*    USNO pour le format USNO                                              */
/*   Le 3eme element contient la definition des elements d'orbite :			 */
/*    Rien pour INTERNAL													             */
/*    NameFile pour designer le fichier            						       */
/*    String pour la chaine qui contient les elements.						    */
/*																			                   */
/* {ListOutput}                   											          */
/*   Le 1er element contient Type de donnees en sortie: 						    */
/*   FILE : pour une sortie sous forme d'un fichier.						       */
/*          Dans ce cas, un second argument precise le nom du fichier		 */
/*          de sortie.														             */
/*   LIST : pour une sortie en memoire sous forme de liste.					    */
/*                                                                          */
/* -date {ListDates}														                */
/*   Le 1er element contient le debut de la date.                           */
/*    NOW (defauf) pour designer l'instant actuel. 							    */
/*    NOW0 : Pour designer la date actuelle a 0h   							    */
/*    NOW1 : Pour designer la date de demain a 0h   						       */
/*    YYYY-MM-DDThh:mm:ss.ss : Format Iso du Fits.						          */
/*    nombre decimal >= 1000000 : Jour Julien								       */
/*    nombre decimal <  1000000 : Jour Julien Modifie						       */
/*    Year : suivi des elements facultatifs suivants, dans l'ordre :		    */
/*     Month Day Hour Minute Second (Format style Iso mais avec les espaces)*/
/*    NB: Ici, seule la premiere date est prise en compte                   */
/*																			                   */
/* -topo {ListSites}														                */
/*   Le 1er element definit le type de coordonnees :						       */
/*    GPS : pour des coordonnees longitude,latitude,altitude.				    */
/*    MPC : Pour LongitudeMPC rhocosphip rhosinphip							    */
/*    MPCSTATION : pour un site connu du MPC.								       */
/*   Les arguments suivants dependant du type de coordonnees.				    */
/*    Si GPS : 																             */
/*     2eme element : Longitude (degres, positive entre 0 et 180)			    */
/*     3eme element : Sens (E ou W pour la longitude)						       */
/*     4eme element : Latitude (en degres, pos. pour nord, neg. pour sud).	 */
/*    Si MPC : 																             */
/*     2eme element : LongitudeMPC (degres, positive vers l'est de 0 a 360) */
/*     3eme element : Rhocosphip											             */
/*     4eme element : Rhosinphip											             */
/*    Si MPCSTATION : 														             */
/*     2eme element : Indice de la station									       */
/*     3eme element : FileName du fichier contenant la base de donnees.		 */
/*                                                                          */
/* -objmax Number                                                           */
/*   Indique le nombre maximum d'objets lus dans le catalogue.              */
/*   1000 par defaut.                                                       */
/*                                                                          */
/* -format value :                                                          */
/*   -MAGR<                                                                 */
/*   -MAGR>                                                                 */
/*   -MAGB<                                                                 */
/*   -MAGB>                                                                 */
/*                                                                          */
/****************************************************************************/
{
   mc_ASTROM p;
   Tcl_DString dsptr;
   char s[524],ss[524];
   int nboutputdatas,sortie;
   char **outputdatas=NULL/*, *pres=NULL,*car=NULL */;
   int nbobjs,nbobjmax=1000,k,msg,result,code;
   objetype *objs=NULL;
   char **dates=NULL;
   int nbdates=0;
   FILE *fichier_out=NULL,*fichier_in;
   char filename_out_default[]="cat.dat";
   double longmpc,rhocosphip,rhosinphip,jj;
   double asd,dec,delta,mag,diamapp,elong,phase,r;
   double x,y;
   int ko,kp,planetnum,stationfilefound,stationfound;
   char objename[100],orbitformat[50],orbitstring[300],orbitfile[1024];
   struct asterident aster;
   struct elemorb elem;
   int /*orbitfilefound=YES,*/orbitisgood=NO;
   double dist,posangle;
   double diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north;
   double long1_sun=0.,lati_sun=0.;

   if(argc<=3) {
      sprintf(s,"Usage: %s Field ListObjects Output", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	  return(result);
   } else {
	  result=TCL_OK;
	  Tcl_DStringInit(&dsptr);

     /* --- decode les options ---*/
     p.tycho_only=0;
     p.magbinf=-30.;
     p.magbsup=1e6;
     p.magrinf=-30.;
     p.magrsup=1e6;
	  longmpc=0.;
	  rhocosphip=0.;
	  rhosinphip=0.;
	  stationfilefound=YES;
	  stationfound=YES;
 	  code=Tcl_SplitList(interp,"NOW",&nbdates,&dates);
     for (ko=1;ko<argc-1;ko++) {
	     strcpy(s,argv[ko]);
		  mc_strupr(s,s);
        if (strcmp(s,"-OBJMAX")==0) { nbobjmax=atoi(argv[ko+1]); }
        else if (strcmp(s,"-MAGR<")==0) { p.magrsup=atof(argv[ko+1]); }
        else if (strcmp(s,"-MAGR>")==0) { p.magrinf=atof(argv[ko+1]); }
        else if (strcmp(s,"-MAGB<")==0) { p.magbsup=atof(argv[ko+1]); }
        else if (strcmp(s,"-MAGB>")==0) { p.magbinf=atof(argv[ko+1]); }
        else if (strcmp(s,"-TOPO")==0) {
			 mctcl_decode_topo(interp,argv[ko+1],&longmpc,&rhocosphip,&rhosinphip);
			 if (longmpc==10.) { stationfilefound=NO; longmpc=0.; }
			 if (longmpc==15.) { stationfound=NO; longmpc=0.; }
		  } else if (strcmp(s,"-DATE")==0) {
          mctcl_decode_date(interp,argv[ko+1],&jj);
		  }
	  }
     if (dates!=NULL) { Tcl_Free((char *) dates); }

     /* --- decode le {ListField} ---*/
     if (mctcl_listfield2mc_astrom(interp,argv[1],&p)==TCL_ERROR) {
      Tcl_DStringFree(&dsptr);
      Tcl_SetResult(interp,"No image loaded in the buffer",TCL_VOLATILE);
      result = TCL_ERROR;
      return(result);
     }

     /* --- decode le {ListObjects} ---*/
     mctcl_decode_planet(interp,argv[2],&planetnum,objename,orbitformat,orbitfile);
	  mc_strupr(orbitformat,orbitformat);
	  strcpy(s,orbitformat);
	  if (strcmp(s,"USNO")==0) {
	     p.astromcatalog=mc_USNO;
		  strcpy(p.path_astromcatalog,orbitfile);
	  } else if (strcmp(s,"ASTROMMICROCAT")==0) {
		  p.astromcatalog=mc_USNOCOMP;
        p.tycho_only=0;
		  strcpy(p.path_astromcatalog,orbitfile);
	  } else if (strcmp(s,"TYCHOMICROCAT")==0) {
		  p.astromcatalog=mc_USNOCOMP;
        p.tycho_only=1;
		  strcpy(p.path_astromcatalog,orbitfile);
	  } else if (strcmp(s,"LONEOSMICROCAT")==0) {
		  p.astromcatalog=mc_LONEOSCOMP;
        p.tycho_only=0;
		  strcpy(p.path_astromcatalog,orbitfile);
	  }

     /* --- decode le {ListOutput} ---*/
     code=Tcl_SplitList(interp,argv[3],&nboutputdatas,&outputdatas);

     /* --- effectue les calculs ---*/

     /* --------------------------------- */
     /* --- catalogues astrometriques --- */
     /* --------------------------------- */
     msg=0;
     nbobjs=0;
     if ((strcmp(orbitformat,"USNO")==0)||
         (strcmp(orbitformat,"ASTROMMICROCAT")==0)||
         (strcmp(orbitformat,"LONEOSMICROCAT")==0)||
         (strcmp(orbitformat,"TYCHOMICROCAT")==0)) {
  	     strcpy(s,outputdatas[0]);
	     mc_strupr(s,s);
	     if (strcmp(s,"FILE")==0) {
		     nbobjs=0;
		     if (nboutputdatas<=1) {
              msg=mc_ima_series_catchart_2(p,&nbobjs,nbobjmax,objs,filename_out_default);
		     } else {
              msg=mc_ima_series_catchart_2(p,&nbobjs,nbobjmax,objs,outputdatas[1]);
           }
	     } else {
		     nbobjs=-1;
           msg=mc_ima_series_catchart_2(p,&nbobjs,nbobjmax,objs,NULL);
		     if (nbobjs>0) {
		        objs=(objetype*)calloc(nbobjs,sizeof(objetype));
              msg=mc_ima_series_catchart_2(p,&nbobjs,nbobjmax,objs,NULL);
              if (strcmp(orbitformat,"LONEOSMICROCAT")!=0) {
                 for (k=0;k<nbobjs;k++) {
                    sprintf(s,"{%.12f %.12f %2.1f %2.1f %5.2f %5.2f %c} ",objs[k].ra,objs[k].dec,0.01*objs[k].magb,0.01*objs[k].magr,objs[k].x+1.,objs[k].y+1.,objs[k].origin);
                    Tcl_DStringAppend(&dsptr,s,-1);
                 }
              } else {
                 for (k=0;k<nbobjs;k++) {
                    sprintf(s,"{%.12f %.12f %.3f %.3f %.3f %.3f %5.2f %5.2f %c} ",objs[k].ra,objs[k].dec,0.001*objs[k].magb,0.001*objs[k].magv,0.001*objs[k].magr,0.001*objs[k].magi,objs[k].x+1.,objs[k].y+1.,objs[k].origin);
                    Tcl_DStringAppend(&dsptr,s,-1);
                 }
              }
              free(objs);
		     }
	     }
     }

     /* ------------------------- */
     /* --- planetes Internal --- */
     /* ------------------------- */
     else if ((strcmp(orbitformat,"INTERNAL")==0)) {
  	     strcpy(ss,outputdatas[0]);
	     mc_strupr(ss,ss);
  	     if (strcmp(ss,"FILE")==0) {
		     if (nboutputdatas<=1) {
              if ((fichier_out=fopen(filename_out_default,"wt"))==NULL) {
                 msg=2;
              }
           } else {
              if ((fichier_out=fopen(outputdatas[1],"wt"))==NULL) {
                 msg=2;
              }
           }
        }
        nbobjs=0;
        for (kp=SOLEIL;kp<=LUNE;kp++) {
           if (msg!=0) {break;}
           if (kp==TERRE) {continue;}
           if (kp==SOLEIL) {
   		     mc_adsolap(jj,longmpc,rhocosphip,rhosinphip,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
              strcpy(objename,"Sun");
  	        } else if ((kp>=MERCURE)&&(kp<=PLUTON)) {
              mc_adplaap(jj,longmpc,rhocosphip,rhosinphip,kp,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
              if (kp==MERCURE) strcpy(objename,"Mercury");
              if (kp==VENUS) strcpy(objename,"Venus");
              if (kp==MARS) strcpy(objename,"Mars");
              if (kp==JUPITER) strcpy(objename,"Jupiter");
              if (kp==SATURNE) strcpy(objename,"Saturn");
              if (kp==URANUS) strcpy(objename,"Uranus");
              if (kp==NEPTUNE) strcpy(objename,"Neptune");
              if (kp==PLUTON) strcpy(objename,"Pluto");
		     } else if (kp==LUNE) {
              mc_adlunap(jj,longmpc,rhocosphip,rhosinphip,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
              strcpy(objename,"Moon");
  	        }
           mc_util_astrom_radec2xy(&p,asd,dec,&x,&y);
           mc_sepangle(asd,p.crval1,dec,p.crval2,&dist,&posangle);
	        if ((x>=0 && x<p.naxis1 && y>=0 && y<p.naxis2)&&(nbobjs<nbobjmax)&&(dist<(PISUR2))) {
              if ((mag>=p.magbinf)&&(mag<=p.magbsup)&&(mag>=p.magrinf)&&(mag<=p.magrsup)) {
				     nbobjs++;
     	           if (strcmp(ss,"FILE")==0) {
                    if ((fprintf(fichier_out,"%.12f %.12f %2.1f %2.1f %.2f %.2f {%s} \n",
			                   asd*(180/(PI)),dec*(180/(PI)),mag,mag,x+1.,y+1.,objename))<0) {
                       msg=10;
                    }
                 } else {
                    sprintf(s,"{%.12f %.12f %2.1f %2.1f %5.2f %5.2f {%s}} ",asd*(180/(PI)),dec*(180/(PI)),mag,mag,x+1.,y+1.,objename);
                    Tcl_DStringAppend(&dsptr,s,-1);
                 }
              }
           }

        }
  	     if (strcmp(ss,"FILE")==0) {
           if (fichier_out!=NULL) {fclose(fichier_out);}
        }
     }

     /* ------------------ */
     /* --- asteroides --- */
     /* ------------------ */
     else if ((strcmp(orbitformat,"BOWELLFILE")==0)||(strcmp(orbitformat,"MPCFILE")==0)) {
        if ((fichier_in=fopen(orbitfile,"rt") ) == NULL) {
		     msg=11;
        }
  	     strcpy(ss,outputdatas[0]);
	     mc_strupr(ss,ss);
  	     if (strcmp(ss,"FILE")==0) {
		     if (nboutputdatas<=1) {
              if ((fichier_out=fopen(filename_out_default,"wt"))==NULL) {
                 msg=2;
              }
           } else {
              if ((fichier_out=fopen(outputdatas[1],"wt"))==NULL) {
                 msg=2;
              }
           }
        }
        nbobjs=0;
		  sortie=NO;
        kp=0;
        do {
         if (msg!=0) {break;}
		   if (strcmp(orbitformat,"BOWELLFILE")==0) {
   		   if (feof(fichier_in)!=0) { fclose(fichier_in);sortie=YES;break;}
              if (fgets(orbitstring,300,fichier_in)==0) {
			     strcpy(orbitstring,"");
		      }
              mc_bow_dec1(orbitstring,&aster);
		      if (strcmp(aster.name,"")==0) {
	  		     orbitisgood=NO;
		      } else {
	  		     orbitisgood=YES;
		      }
		   } else if (strcmp(orbitformat,"MPCFILE")==0) {
    	      if (feof(fichier_in)!=0) {fclose(fichier_in);sortie=YES;break;}
              if (fgets(orbitstring,300,fichier_in)==0) {
		         strcpy(orbitstring,"");
		      }
		      mc_mpc_dec1(orbitstring,&aster);
			  if (strcmp(aster.name,"")==0) {
	  			 orbitisgood=NO;
			  } else {
	  			 orbitisgood=YES;
			  }
		   } else {
			  orbitisgood=NO;
		   }
		   if (orbitisgood==YES) {
			   /* --- calcul ---*/
			   if (orbitisgood==YES) {
			      mc_aster2elem(aster,&elem);
			      sprintf(objename,elem.designation);
			      mc_adasaap(jj,longmpc,rhocosphip,rhosinphip,elem,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
			   }
		   }
         mc_util_astrom_radec2xy(&p,asd,dec,&x,&y);
         mc_sepangle(asd,p.crval1,dec,p.crval2,&dist,&posangle);
	      if ((x>=0 && x<p.naxis1 && y>=0 && y<p.naxis2)&&(nbobjs<nbobjmax)&&(dist<(PISUR2))) {
            if ((mag>=p.magbinf)&&(mag<=p.magbsup)&&(mag>=p.magrinf)&&(mag<=p.magrsup)) {
				   nbobjs++;
     	         if (strcmp(ss,"FILE")==0) {
                  if ((fprintf(fichier_out,"%.12f %.12f %2.1f %2.1f %.2f %.2f {%s} \n",
			                   asd*(180/(PI)),dec*(180/(PI)),mag,mag,x+1.,y+1.,objename))<0) {
                       msg=10;
                  }
               } else {
                  sprintf(s,"{%.12f %.12f %2.1f %2.1f %5.2f %5.2f %s} ",asd*(180/(PI)),dec*(180/(PI)),mag,mag,x+1.,y+1.,objename);
                  Tcl_DStringAppend(&dsptr,s,-1);
               }
            }
         }
         kp++;
		} while (sortie==NO); /* fin de boucle sur les planetes pour une date donnee */
  	    if (strcmp(ss,"FILE")==0) {
           if (fichier_out!=NULL) {fclose(fichier_out);}
        }
      if (fichier_in!=NULL) {fclose(fichier_in);}
     }
   }

   /* --- donnees finales ---*/
   if (msg==0) {
      sprintf(s,"{Ok %d} ",nbobjs);
      Tcl_DStringAppend(&dsptr,s,-1);
   } else {
      Tcl_DStringAppend(&dsptr,"{Pb {",-1);
      if (msg==1) { Tcl_DStringAppend(&dsptr,"Memory Allocation Error",-1); }
      else if (msg==2) { Tcl_DStringAppend(&dsptr,"Can not create output file",-1); }
      else if (msg==3) { Tcl_DStringAppend(&dsptr,"Did not found *.acc of Tycho microcat",-1); }
      else if (msg==4) { Tcl_DStringAppend(&dsptr,"Did not found *.cat of Tycho microcat",-1); }
      else if (msg==5) { Tcl_DStringAppend(&dsptr,"Did not found *.acc of GSC microcat",-1); }
      else if (msg==6) { Tcl_DStringAppend(&dsptr,"Did not found *.cat of GSC microcat",-1); }
      else if (msg==7) { Tcl_DStringAppend(&dsptr,"Did not found *.acc of Usno",-1); }
      else if (msg==8) { Tcl_DStringAppend(&dsptr,"Did not found *.cat of Usno",-1); }
      else if (msg==10) { Tcl_DStringAppend(&dsptr,"Can not write the next line in the output file",-1); }
      else if (msg==11) { Tcl_DStringAppend(&dsptr,"Did not found the database file",-1); }
      else if (msg==12) { Tcl_DStringAppend(&dsptr,"Did not found *.acc of Loneos microcat",-1); }
      else if (msg==13) { Tcl_DStringAppend(&dsptr,"Did not found *.cat of Loneos microcat",-1); }
      else if (msg==14) { Tcl_DStringAppend(&dsptr,"Invalid astrnometric parameters",-1); }
      else {Tcl_DStringAppend(&dsptr,"Unidentified error",-1); }
      Tcl_DStringAppend(&dsptr,"}}",-1);
   }
   Tcl_DStringResult(interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   if (outputdatas!=NULL) { Tcl_Free((char *) outputdatas); }

   return(TCL_OK);
}


int Cmd_mctcl_tle2ephem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   Tcl_DString dsptr;
   int result,valid,k;
   char s[524];
   char ss[524];
   char sss[524];
   char name[524];
   struct elemorb elem;
   double jj,jj0,a,n=0.0,k_gauss;
   double longmpc,rhocosphip,rhosinphip;
   double diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north;
   double long1_sun=0.,lati_sun=0.;
   double asd,dec,delta,mag,diamapp,elong,phase,rr;
   FILE *ftle;

   if(argc<4) {
      /*
      set date 2003-09-23T20:30:00.00 ; set res [mc_tle2ephem [mc_date2tt $date] d:/geostat/gps24/geo.tle {gps 6.92389 e 43.75222 1270} "TELECOM 2D"]
      set texte ""
      foreach ligne $res { set res2 [mc_radec2altaz [lindex $ligne 1] [lindex $ligne 2] {gps 6.92389 e 43.75222 1270} $date] ; set gis [expr [lindex $res2 0]+180.] ; if {$gis>360} {set gis [expr $gis-360.]} ; append texte "[lindex $ligne 0] [lindex $ligne 1] [lindex $ligne 2] $gis [lindex $res2 1]\n" }
      set f [open d:/geostat/sat.txt w] ; puts -nonewline $f $texte ; close $f
      */
      sprintf(s,"Usage: %s Date file_tle Home ?satname?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
      /* --- decode la Date---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      if (argc>=4) {
         mctcl_decode_topo(interp,argv[3],&longmpc,&rhocosphip,&rhosinphip);
      }
      strcpy(name,"");
      if (argc>=5) {
         strcpy(name,argv[4]);
      }
      /* --- decode le fichier TLE ---*/
      ftle=fopen(argv[2],"rt");
      if (ftle==NULL) {
         Tcl_SetResult(interp,"File not found",TCL_VOLATILE);
         result = TCL_ERROR;
	      return(result);
      }
      /*
      0         1         2         3         4         5         6         7
       123456789 123456789 123456789 123456789 123456789 123456789 123456789
      TELECOM 2D
      1 24209U 96044B   03262.91033065 -.00000065  00000-0  00000+0 0  8956
      2 24209   0.0626 123.5457 0004535  56.5151 138.1659  1.00273036 26182
      */
	   result=TCL_OK;
	   Tcl_DStringInit(&dsptr);
      while (feof(ftle)==0) {
         fgets(s,255,ftle);
         valid=0;
         if (s!=NULL) {
            if (s[0]=='1') {
               strcpy(ss,s+1); ss[7-1+1]='\0';
               strcpy(elem.id_norad,ss);
               strcpy(ss,s+8); ss[17-1+1]='\0';
               strcpy(elem.id_cospar,ss);
               strcpy(ss,s+18); ss[2]='\0';
               sprintf(sss,"20%s-01-01T00:00:00",ss);
               mctcl_decode_date(interp,sss,&jj0);
               strcpy(ss,s+20); ss[12]='\0';
               jj0+=(atof(ss)-1.);
            } else if (s[0]=='2') {
               strcpy(ss,s+8); ss[15-8+1]='\0';
               elem.i=atof(ss)*(DR);
               strcpy(ss,s+17); ss[24-17+1]='\0';
               elem.o=atof(ss)*(DR);
               strcpy(ss,s+26); ss[32-26+1]='\0';
               elem.e=1e-7*atof(ss);
               strcpy(ss,s+34); ss[41-34+1]='\0';
               elem.w=atof(ss)*(DR);
               strcpy(ss,s+43); ss[43-50+1]='\0';
               elem.m0=atof(ss)*(DR);
               strcpy(ss,s+52); ss[62-52+1]='\0';
               n=atof(ss);
               if (strcmp(name,"")==0) {
                  valid=1;
               } else if (strstr(elem.designation,name)!=NULL) {
                  valid=1;
               }
            } else {
               k=(int)strlen(s);
               strcpy(elem.designation,s);
               if (k>0) {
                  elem.designation[k-1]='\0';
               }
            }
         }
         if (valid==1) {
            elem.jj_m0=jj0;
            elem.jj_equinoxe=jj0;
            elem.jj_epoque=jj0;
            elem.type=4;
            elem.h0=0.;
            elem.g=0.;
            elem.n=0.;
            elem.h=0.;
            elem.nbjours=0;
            elem.nbobs=0;
            elem.ceu0=0.;
            elem.ceut=0.;
            elem.jj_ceu0=jj0;
            elem.code1=0;
            elem.code2=0;
            elem.code3=0;
            elem.code4=0;
            elem.code5=0;
            elem.code6=0;
            elem.residu_rms=0.;
            if (elem.type==4) {
               k_gauss=KGEOS;
            } else {
               k_gauss=K;
            }
            n=n*360.; /* deg/day */
            a=pow(k_gauss/(DR)/n,2./3.);
            elem.q=a*(1-elem.e);
            /* --- on lance le calcul ---*/
            mc_adelemap(jj,elem,longmpc,rhocosphip,rhosinphip,0,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&rr,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
            sprintf(s,"{{{%20s} {%15s} {%15s}} %.15f %.15f %.15g %.15f} ",elem.designation,elem.id_norad,elem.id_cospar,asd/(DR),dec/(DR),delta,elong/(DR));
            Tcl_DStringAppend(&dsptr,s,-1);
         }
      }
      fclose(ftle);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return result;
}

int Cmd_mctcl_tle2xyz(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   Tcl_DString dsptr;
   int result,valid,k;
   char s[524];
   char ss[524];
   char sss[524];
   char name[524];
   struct elemorb elem;
   double jj,jj0,a,n=0.0,k_gauss;
   double longmpc,rhocosphip,rhosinphip;
   /*
   double diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north;
   double long1_sun=0.,lati_sun=0.;
   double asd,dec,delta,mag,diamapp,elong,phase,rr;
   */
   FILE *ftle;
   double xageo,yageo,zageo,xtgeo,ytgeo,ztgeo,xsgeo,ysgeo,zsgeo,xlgeo,ylgeo,zlgeo;

   if(argc<4) {
      /*
      set date 2003-09-23T20:30:00.00 ; set res [mc_tle2ephem [mc_date2tt $date] d:/geostat/gps24/geo.tle {gps 6.92389 e 43.75222 1270} "TELECOM 2D"]
      set texte ""
      foreach ligne $res { set res2 [mc_radec2altaz [lindex $ligne 1] [lindex $ligne 2] {gps 6.92389 e 43.75222 1270} $date] ; set gis [expr [lindex $res2 0]+180.] ; if {$gis>360} {set gis [expr $gis-360.]} ; append texte "[lindex $ligne 0] [lindex $ligne 1] [lindex $ligne 2] $gis [lindex $res2 1]\n" }
      set f [open d:/geostat/sat.txt w] ; puts -nonewline $f $texte ; close $f
      */
      sprintf(s,"Usage: %s Date file_tle Home ?satname?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
      /* --- decode la Date---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      if (argc>=4) {
         mctcl_decode_topo(interp,argv[3],&longmpc,&rhocosphip,&rhosinphip);
      }
      strcpy(name,"");
      if (argc>=5) {
         strcpy(name,argv[4]);
      }
      /* --- decode le fichier TLE ---*/
      ftle=fopen(argv[2],"rt");
      if (ftle==NULL) {
         Tcl_SetResult(interp,"File not found",TCL_VOLATILE);
         result = TCL_ERROR;
	      return(result);
      }
      /*
      0         1         2         3         4         5         6         7
       123456789 123456789 123456789 123456789 123456789 123456789 123456789
      TELECOM 2D
      1 24209U 96044B   03262.91033065 -.00000065  00000-0  00000+0 0  8956
      2 24209   0.0626 123.5457 0004535  56.5151 138.1659  1.00273036 26182
      */
	   result=TCL_OK;
	   Tcl_DStringInit(&dsptr);
      while (feof(ftle)==0) {
         fgets(s,255,ftle);
         valid=0;
         if (s!=NULL) {
            if (s[0]=='1') {
               strcpy(ss,s+1); ss[7-1+1]='\0';
               strcpy(elem.id_norad,ss);
               strcpy(ss,s+8); ss[17-1+1]='\0';
               strcpy(elem.id_cospar,ss);
               strcpy(ss,s+18); ss[2]='\0';
               sprintf(sss,"20%s-01-01T00:00:00",ss);
               mctcl_decode_date(interp,sss,&jj0);
               strcpy(ss,s+20); ss[12]='\0';
               jj0+=(atof(ss)-1.);
            } else if (s[0]=='2') {
               strcpy(ss,s+8); ss[15-8+1]='\0';
               elem.i=atof(ss)*(DR);
               strcpy(ss,s+17); ss[24-17+1]='\0';
               elem.o=atof(ss)*(DR);
               strcpy(ss,s+26); ss[32-26+1]='\0';
               elem.e=1e-7*atof(ss);
               strcpy(ss,s+34); ss[41-34+1]='\0';
               elem.w=atof(ss)*(DR);
               strcpy(ss,s+43); ss[43-50+1]='\0';
               elem.m0=atof(ss)*(DR);
               strcpy(ss,s+52); ss[62-52+1]='\0';
               n=atof(ss);
               if (strcmp(name,"")==0) {
                  valid=1;
               } else if (strstr(elem.designation,name)!=NULL) {
                  valid=1;
               }
            } else {
               k=(int)strlen(s);
               strcpy(elem.designation,s);
               if (k>0) {
                  elem.designation[k-1]='\0';
               }
            }
         }
         if (valid==1) {
            elem.jj_m0=jj0;
            elem.jj_equinoxe=jj0;
            elem.jj_epoque=jj0;
            elem.type=4;
            elem.h0=0.;
            elem.g=0.;
            elem.n=0.;
            elem.h=0.;
            elem.nbjours=0;
            elem.nbobs=0;
            elem.ceu0=0.;
            elem.ceut=0.;
            elem.jj_ceu0=jj0;
            elem.code1=0;
            elem.code2=0;
            elem.code3=0;
            elem.code4=0;
            elem.code5=0;
            elem.code6=0;
            elem.residu_rms=0.;
            if (elem.type==4) {
               k_gauss=KGEOS;
            } else {
               k_gauss=K;
            }
            n=n*360.; /* deg/day */
            a=pow(k_gauss/(DR)/n,2./3.);
            elem.q=a*(1-elem.e);
            /* --- on lance le calcul ---*/
            mc_xyzgeoelem(jj,elem,longmpc,rhocosphip,rhosinphip,0,&xageo,&yageo,&zageo,&xtgeo,&ytgeo,&ztgeo,&xsgeo,&ysgeo,&zsgeo,&xlgeo,&ylgeo,&zlgeo);
            sprintf(s,"{{{%20s} {%15s} {%15s}} %.15f %.15f %.15f %.15f %.15f %.15f %.15f %.15f %.15f %.15f %.15f %.15f} ",elem.designation,elem.id_norad,elem.id_cospar,xageo,yageo,zageo,xtgeo,ytgeo,ztgeo,xsgeo,ysgeo,zsgeo,xlgeo,ylgeo,zlgeo);
            Tcl_DStringAppend(&dsptr,s,-1);
         }
      }
      fclose(ftle);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return result;
}

int Cmd_mctcl_simurelief(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Synthese de cartes de relief et d'albedo pour courbes de rotations.      */
/****************************************************************************/
/* Cette fonction prepare une carte de relief et une carte d'albedo pour    */
/* etre utilis�es par mc_simulc.                                            */
/*																			                   */
/*	ENTREES               											                   */
/*	=======               											                   */
/* a_m    : demi grand axe equatorial (m)                                   */
/* b_m    : demi petit axe equatorial (m)                                   */
/* c_m    : demi axe polaire (m)                                            */
/* filename_relief : carte de relief creee avec mc_simurelief               */
/* albedo : valeur de l'albedo geometrique.                                 */
/* filename_albedo : carte d'albedo creee avec mc_simurelief                */
/*																			                   */
/*	SORTIES               											                   */
/*	=======               											                   */
/* Deux fichiers ASCII avec une resolution de 1 deg/point                   */
/****************************************************************************/
{
   char s[1024];
   double *relief=NULL,albedo;
   FILE *fichier_relief=NULL;
   FILE *fichier_albedo=NULL;
   int klon,klat,nlon,nlat;
   double a,b,c,aa,bb,cc,lon,lat,cosl,sinl,cosb,sinb,coslcosb,sinlcosb,alt;
   double lonc,latc,dist,posangle,angc,angin,alt0,diamc,profc;
   if(argc<7) {
      sprintf(s,"Usage: %s a_m b_m c_m filename_relief albedo filename_albedo", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* === */
	   /* === Decode des arguments de la ligne de commande ===*/
      /* === */
      a=atof(argv[1]);
      b=atof(argv[2]);
      c=atof(argv[3]);
      /* === */
	   /* === Calcul de la carte de relief ===*/
      /* === */
      nlon=360;
      nlat=181;
      relief=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         strcpy(s,"Error : memory allocation for relief");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      aa=a*a;
      bb=b*b;
      cc=c*c;
      lonc=90.*(DR);
      latc=0.*(DR);
      angc=60.*(DR);
      diamc=2*a*sin(angc);
      profc=0.2*diamc;
      for (klon=0;klon<nlon;klon++) {
         lon=(1.*klon)*(DR);
         cosl=cos(lon);
         sinl=sin(lon);
         for (klat=0;klat<nlat;klat++) {
            lat=(1.*klat)*(DR)-(PI)/2;
            cosb=cos(lat);
            sinb=sin(lat);
            coslcosb=cosl*cosb;
            sinlcosb=sinl*cosb;
            alt=1./sqrt(coslcosb*coslcosb/aa+sinlcosb*sinlcosb/bb+sinb*sinb/cc);
            mc_sepangle(lon,lonc,lat,latc,&dist,&posangle);
            /* --- one crater ---*/
            if (dist<angc) {
               alt0=alt;
               // --- fond plat ---
               alt=alt0*cos(angc)/cos(dist);
               // --- cuvette ---
               angin=(0.5+0.5*(angc-dist)/angc)*(PI)/2.;
               alt=alt-profc/sin(angin);;
               alt=alt0;
            }
            /*
            if ((lon>(PI)-0.1)&&(lon<(PI)+0.1)&&(lat>-0.1)&&(lat<0.1)) {
               alt=3.;
            }
            */
            relief[klon*nlat+klat]=alt;
         }
      }
      /* === */
	   /* === Enregistre sur disque la carte de relief ===*/
      /* === */
      if ((fichier_relief=fopen(argv[4],"wt") ) == NULL) {
         free(relief);
         sprintf(s,"Error : file %s cannot be created",argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         for (klon=0;klon<nlon;klon++) {
            fprintf(fichier_relief,"%e ",relief[klon*nlat+klat]);
         }
         fprintf(fichier_relief,"\n");
      }
      fclose(fichier_relief);
      /* === */
	   /* === Enregistre sur disque la carte d'albedo ===*/
      /* === */
      if ((fichier_albedo=fopen(argv[6],"wt") ) == NULL) {
         free(relief);
         sprintf(s,"Error : file %s cannot be created",argv[6]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      albedo=atof(argv[5]);
      if (albedo<0.) { albedo=0.; }
      if (albedo>1.) { albedo=1.; }
      for (klat=0;klat<nlat;klat++) {
         for (klon=0;klon<nlon;klon++) {
            //if ((klon<10)||(klon>350)||((klat>85)&&(klat<96))) {
            //   fprintf(fichier_albedo,"%f ",1.0);
            //} else {
               fprintf(fichier_albedo,"%f ",albedo);
            //}
         }
         fprintf(fichier_albedo,"\n");
      }
      fclose(fichier_albedo);
      /* === sortie et destructeurs ===*/
      free(relief);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_simulc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Simulation de la courbe de lumiere d'un asteroide                        */
/****************************************************************************/
/* Cette fonction simule la courbe de rotation d'un asteroide dans          */
/* l'intevalle [Date_phase0;Date_phase0+sideral_period_h].                  */
/* Il faut pr�alablement avoir utilis� mc_simurelief                        */
/*																			                   */
/*	ENTREES               											                   */
/*	=======               											                   */
/* Planet                   											                */
/*   Le 1er element contient le nom de la planete :							    */
/*    Name pour un astre dont les elements sont definis par les 2eme et     */
/*     et 3eme elements :													             */
/*   Le 2eme element contient le format des elements d'orbite               */
/*    INTERNAL (defaut) pour les planetes classiques.						       */
/*    BOWELL pour le format de Bowell 									             */
/*    BOWELLFILE pour le format de Bowell sous forme d'un fichier			    */
/*    DAILYMPECFILE Daily MPEC sous forme d'un fichier						    */
/*    DAILYMPEC Daily MPEC													             */
/*   Le 3eme element contient la definition des elements d'orbite :			 */
/*    Rien pour INTERNAL													             */
/*    NameFile pour designer le fichier des elements						       */
/*    String pour la chaine qui contient les elements.						    */
/* Date 													                               */
/*  Le 1er element contient le debut de la date.                            */
/*    NOW (defauf) pour designer l'instant actuel. 							    */
/*    NOW0 : Pour designer la date actuelle a 0h   							    */
/*    NOW1 : Pour designer la date de demain a 0h   						       */
/*    YYYY-MM-DDThh:mm:ss.ss : Format Iso du Fits.						          */
/*    nombre decimal >= 1000000 : Jour Julien								       */
/*    nombre decimal <  1000000 : Jour Julien Modifie						       */
/*    Year : suivi des elements facultatifs suivants, dans l'ordre :		    */
/*     Month Day Hour Minute Second (Format style Iso mais avec les espaces)*/
/* HTM_level  : niveau du d�coupage HTM                                     */
/* filename_relief : carte de relief creee avec mc_simurelief               */
/* filename_albedo : carte d'albedo creee avec mc_simurelief                */
/* frame_coord : referentiel de coordonnees (=0=ecliptique =1=equatorial)   */
/* frame_center : referentiel de coordonnees (=0=helio =1=geo)              */
/* lon_phase0 : longitude de la phase nulle de la cdr (deg)                 */
/* Date_phase0 : Date de reference de la phase nulle de la cdr (Date)       */
/* sideral_period_h : periode de rotation sid�rale (h)                      */
/* lonpole     : longitude du pole (deg) dans frame_coord                   */
/* latpole     : latitude du pole (deg) dans frame_coord                    */
/* density_g/cm3 : masse volumique de la planete (g/cm3)                    */
/* ?genefilename? : nom generique des images de simulation de l'astre.      */
/*																			                   */
/*	SORTIES               											                   */
/*	=======               											                   */
/* Liste jd : liste des jours juliens                                       */
/* Liste phases : liste des phases                                          */
/* Liste mag1 : liste des magnitudes pour un diffuseur lambertien           */
/* Liste mag2 : liste des magnitudes pour un diffuseur Lommel-Seeliger      */
/****************************************************************************/
{
   double jj;
   int planetnum;
   char s[65000];
   char objename[100],orbitformat[15],orbitstring[300],orbitfile[1024],filename_relief[1024],filename_albedo[1024];
   double asd,dec,delta;
   double mag,phase,elong,diamapp,r;
   double longmpc=0.,rhocosphip=0.,rhosinphip=0.;
   int orbitfilefound=YES,orbitisgood=NO;
   struct asterident aster;
   struct elemorb elem;
   FILE *fichier_in=NULL;
   FILE *fichier_relief=NULL;
   FILE *fichier_albedo=NULL;
   char *token,*genefilename=NULL;
   Tcl_DString dsptr;

   double xearth,yearth,zearth,xaster,yaster,zaster;
   double dl,phi;
   int n,k;
   mc_cdrpos *cdrpos;
   mc_cdr cdr;
   double *relief=NULL;
   double *albedo=NULL;
   int klon,klat,nlon,nlat;
//double dlt;

   if(argc<14) {
      sprintf(s,"Usage: %s Planet Date_TT HTM_level filename_relief filename_albedo frame_coord frame_center lon_phase0 Date_phase0_TT sideral_period_h lonpole latpole density_g/cm3 ?genefilename?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	   Tcl_DStringInit(&dsptr);
      /* === */
	   /* === Decode des arguments de la ligne de commande ===*/
      /* === */
	   /* --- decode la planete ---*/
      mctcl_decode_planet(interp,argv[1],&planetnum,objename,orbitformat,orbitfile);
	   if (planetnum!=OTHERPLANET) {
         /* --- pb planete non reconnue ---*/
         sprintf(s,"Error : Planet %s (type %d) not found",objename,planetnum);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- decode la date ---*/
	  	mctcl_decode_date(interp,argv[2],&jj);
      /* --- decode les parametres physiques ---*/
      cdr.htmlevel=atoi(argv[3]);
      strcpy(filename_relief,argv[4]);
      strcpy(filename_albedo,argv[5]);
      cdr.frame_coord=atoi(argv[6]);  /* =0 pole defined /ecliptic.  =1 pole defined /equator. */
      cdr.frame_center=atoi(argv[7]);  /* =0 heliocentric.  =1 geocentric. */
      cdr.lon_phase0=atof(argv[8]);
      mctcl_decode_date(interp,argv[9],&cdr.jd_phase0);
      cdr.period=atof(argv[10])/24.;
      cdr.lonpole=atof(argv[11]);
      cdr.latpole=atof(argv[12]);
      cdr.density=atof(argv[13]); /* density g/cm3 */
      if (argc>=15) {
         genefilename=argv[14];
      } else {
         genefilename=NULL;
      }
      /* --- */
      dl=0.5*sqrt(41253./(8*pow(4,cdr.htmlevel)));
      dl=5.;
	   longmpc=0.;
	   rhocosphip=0.;
	   rhosinphip=0.;
      /* === */
	   /* === Lecture de la carte de relief ===*/
      /* === */
      nlon=360;
      nlat=181;
      relief=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         strcpy(s,"Error : memory allocation for relief");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((fichier_relief=fopen(filename_relief,"rt") ) == NULL) {
         free(relief);
         sprintf(s,"Error : file %s cannot be read",argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_relief)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         }
         token=strtok(s," ");
         for (klon=0;klon<nlon;klon++) {
            if (token==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            }
            relief[klon*nlat+klat]=atof(token);
            token=strtok(NULL," ");
         }
      }
      fclose(fichier_relief);
      /* === */
	   /* === Lecture de la carte d'albedo ===*/
      /* === */
      albedo=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         free(relief);
         strcpy(s,"Error : memory allocation for albedo");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((fichier_albedo=fopen(filename_albedo,"rt") ) == NULL) {
         free(relief);
         free(albedo);
         sprintf(s,"Error : file %s cannot be read",argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_albedo)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         }
         token=strtok(s," ");
         for (klon=0;klon<nlon;klon++) {
            if (token==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            }
            albedo[klon*nlat+klat]=atof(token);
            token=strtok(NULL," ");
         }
      }
      fclose(fichier_albedo);
      /* === */
	   /* === Lecture des elements d'orbite de la planete ===*/
      /* === */
      /* --- ouverture du fichier de la base d'orbite ---*/
  		if ((strcmp(orbitformat,"BOWELLFILE")==0)||(strcmp(orbitformat,"MPCFILE")==0)) {
         if ((fichier_in=fopen(orbitfile,"rt") ) == NULL) {
  	   	   orbitfilefound=NO;
		      orbitisgood=NO;
            /* --- le fichier d'orbite n'est pas trouve : il faut sortir ---*/
            sprintf(s,"Error : Orbit file %s (type=%d) not found",orbitfile,orbitformat);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            free(relief);
            return TCL_ERROR;
		   }
      }
      do {
         /* --- lecture d'une ligne de la base d'orbite ---*/
  			orbitisgood=NO;
   		if (strcmp(orbitformat,"BOWELLFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
		         strcpy(orbitstring,"");
   	      }
            mc_bow_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
  			} else if (strcmp(orbitformat,"MPCFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
   		      strcpy(orbitstring,"");
		      }
			   mc_mpc_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
         } else {
            break;
         }
      } while (feof(fichier_in)==0);
      fclose(fichier_in);
      if (orbitisgood==NO) {
         /* --- la planete n'a pas ete trouvee dans fichier d'orbite : il faut sortir ---*/
         sprintf(s,"Error : Planet %s (type %d) not found in the file %s",objename,planetnum,orbitfile);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         return TCL_ERROR;
      }
      mc_aster2elem(aster,&elem);
      /* === */
	   /* === Calcul des coordonnes heliocentriques de la planete et de la Terre pour chaque phase ===*/
      /* === */
      n=(int)ceil(360./dl);
      cdrpos=(mc_cdrpos*)malloc(n*sizeof(mc_cdrpos));
      if (cdrpos==NULL) {
         strcpy(s,"Error : memory allocation for cdrpos");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         return TCL_ERROR;
      }
      /*phi=cdr.jd_phase0-cdr.period*floor((jj-cdr.jd_phase0)/cdr.period);*/
      phi=cdr.jd_phase0+cdr.period*floor((jj-cdr.jd_phase0)/cdr.period);
      for (k=0;k<n;k++) {
         cdrpos[k].phase=1.*k/n;
         cdrpos[k].jd=phi+1.*k/n*cdr.period;
		   mc_xyzasaaphelio(cdrpos[k].jd,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         /*
          xearth=1.;
          yearth=0.;
          zearth=0.;
          delta=1.;
          dlt=0.*(DR);
          xaster=xearth+delta*cos(dlt);
          yaster=yearth+delta*sin(dlt);
          zaster=zearth;
          */
         cdrpos[k].xaster=xaster;
         cdrpos[k].yaster=yaster;
         cdrpos[k].zaster=zaster;
         cdrpos[k].xearth=xearth;
         cdrpos[k].yearth=yearth;
         cdrpos[k].zearth=zearth;
         cdrpos[k].delta=delta;
         cdrpos[k].r=r;
         cdrpos[k].mag1=mag;
         cdrpos[k].mag2=mag;
      }
      /* === */
	   /* === Calcul de la courbe de lumiere ===*/
      /* === */
      mc_simulc(cdr,relief,albedo,cdrpos,n,genefilename);
      /* === */
	   /* === Sortie des resultats ===*/
      /* === */
      Tcl_DStringAppend(&dsptr,"{",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].jd);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].phase);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag1);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag2);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} ",-1);
      /* === sortie et destructeurs ===*/
      free(cdrpos);
      free(relief);
      free(albedo);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

int Cmd_mctcl_simulcbin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Simulation de la courbe de lumiere d'asteroides binaires (SSB)           */
/****************************************************************************/
/* Cette fonction simule la courbe de rotation d'un asteroide SSB dans      */
/* l'intevalle [Date_phase0;Date_phase0+sideral_period_h].                  */
/* Il faut pr�alablement avoir utilis� mc_simurelief                        */
/*																			                   */
/*	ENTREES               											                   */
/*	=======               											                   */
/* Planet                   											                */
/*   Le 1er element contient le nom de la planete :							    */
/*    Name pour un astre dont les elements sont definis par les 2eme et     */
/*     et 3eme elements :													             */
/*   Le 2eme element contient le format des elements d'orbite               */
/*    INTERNAL (defaut) pour les planetes classiques.						       */
/*    BOWELL pour le format de Bowell 									             */
/*    BOWELLFILE pour le format de Bowell sous forme d'un fichier			    */
/*    DAILYMPECFILE Daily MPEC sous forme d'un fichier						    */
/*    DAILYMPEC Daily MPEC													             */
/*   Le 3eme element contient la definition des elements d'orbite :			 */
/*    Rien pour INTERNAL													             */
/*    NameFile pour designer le fichier des elements						       */
/*    String pour la chaine qui contient les elements.						    */
/* Date 													                               */
/*  Le 1er element contient le debut de la date.                            */
/*    NOW (defauf) pour designer l'instant actuel. 							    */
/*    NOW0 : Pour designer la date actuelle a 0h   							    */
/*    NOW1 : Pour designer la date de demain a 0h   						       */
/*    YYYY-MM-DDThh:mm:ss.ss : Format Iso du Fits.						          */
/*    nombre decimal >= 1000000 : Jour Julien								       */
/*    nombre decimal <  1000000 : Jour Julien Modifie						       */
/*    Year : suivi des elements facultatifs suivants, dans l'ordre :		    */
/*     Month Day Hour Minute Second (Format style Iso mais avec les espaces)*/
/* HTM_level  : niveau du d�coupage HTM                                     */
/* filename_relief : carte de relief creee avec mc_simurelief               */
/* filename_albedo : carte d'albedo creee avec mc_simurelief                */
/* frame_coord : referentiel de coordonnees (=0=ecliptique =1=equatorial)   */
/* frame_center : referentiel de coordonnees (=0=helio =1=geo)              */
/* lon_phase0 : longitude de la phase nulle de la cdr (deg)                 */
/* Date_phase0 : Date de reference de la phase nulle de la cdr (Date)       */
/* sideral_period_h : periode de rotation sid�rale (h)                      */
/* lonpole     : longitude du pole (deg) dans frame_coord                   */
/* latpole     : latitude du pole (deg) dans frame_coord                    */
/* a_m : demi-grand axe de l'orbite des binaires (m)                        */
/* ?genefilename? : nom generique des images de simulation de l'astre.      */
/*																			                   */
/*	SORTIES               											                   */
/*	=======               											                   */
/* Liste jd : liste des jours juliens                                       */
/* Liste phases : liste des phases                                          */
/* Liste mag1 : liste des magnitudes pour un diffuseur lambertien           */
/* Liste mag2 : liste des magnitudes pour un diffuseur Lommel-Seeliger      */
/****************************************************************************/
{
   double jj;
   int planetnum;
   char s[65000];
   char objename[100],orbitformat[15],orbitstring[300],orbitfile[1024],filename_relief[1024],filename_albedo[1024];
   double asd,dec,delta;
   double mag,phase,elong,diamapp,r;
   double longmpc=0.,rhocosphip=0.,rhosinphip=0.;
   int orbitfilefound=YES,orbitisgood=NO;
   struct asterident aster;
   struct elemorb elem;
   FILE *fichier_in=NULL;
   FILE *fichier_relief=NULL;
   FILE *fichier_albedo=NULL;
   char *token,*genefilename=NULL;
   Tcl_DString dsptr;

   double xearth,yearth,zearth,xaster,yaster,zaster;
   double dl,phi;
   int n,k;
   mc_cdrpos *cdrpos=NULL;
   mc_cdr cdr;
   double *relief=NULL;
   double *albedo=NULL;
   int klon,klat,nlon,nlat;
//double dlt;

   if(argc<14) {
      sprintf(s,"Usage: %s Planet Date_TT HTM_level filename_relief filename_albedo frame_coord frame_center lon_phase0 Date_phase0_TT sideral_period_h lonpole latpole a_m ?genefilename?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	   Tcl_DStringInit(&dsptr);
      /* === */
	   /* === Decode des arguments de la ligne de commande ===*/
      /* === */
	   /* --- decode la planete ---*/
      mctcl_decode_planet(interp,argv[1],&planetnum,objename,orbitformat,orbitfile);
	   if (planetnum!=OTHERPLANET) {
         /* --- pb planete non reconnue ---*/
         sprintf(s,"Error : Planet %s (type %d) not found",objename,planetnum);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- decode la date ---*/
	  	mctcl_decode_date(interp,argv[2],&jj);
      /* --- decode les parametres physiques ---*/
      cdr.htmlevel=atoi(argv[3]);
      strcpy(filename_relief,argv[4]);
      strcpy(filename_albedo,argv[5]);
      cdr.frame_coord=atoi(argv[6]);  /* =0 pole defined /ecliptic.  =1 pole defined /equator. */
      cdr.frame_center=atoi(argv[7]);  /* =0 heliocentric.  =1 geocentric. */
      cdr.lon_phase0=atof(argv[8]);
      /*cdr.lon_phase0=0.;*/
      mctcl_decode_date(interp,argv[9],&cdr.jd_phase0);
      cdr.period=atof(argv[10])/24.;
      cdr.lonpole=atof(argv[11]);
      cdr.latpole=atof(argv[12]);
      cdr.a=atof(argv[13]); /* demi-grand axe */
      cdr.density=1.; /* assumed but will be recomputed */
      if (argc>=15) {
         genefilename=argv[14];
      } else {
         genefilename=NULL;
      }
      /* --- */
      dl=0.5*sqrt(41253./(8*pow(4,cdr.htmlevel)));
      dl=5.;
	   longmpc=0.;
	   rhocosphip=0.;
	   rhosinphip=0.;
      /* === */
	   /* === Lecture de la carte de relief ===*/
      /* === */
      nlon=360;
      nlat=181;
      relief=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         strcpy(s,"Error : memory allocation for relief");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((fichier_relief=fopen(filename_relief,"rt") ) == NULL) {
         free(relief);
         sprintf(s,"Error : file %s cannot be read: %s",argv[4],strerror( errno ));
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_relief)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         } else {
            token=strtok(s," ");
            for (klon=0;klon<nlon;klon++) {
               if (token==NULL) {
                  /*--- pb dans le fichier de  la carte de relief ---*/
               }
               relief[klon*nlat+klat]=atof(token);
               token=strtok(NULL," ");
            }
         }
      }
      if (fclose(fichier_relief)!=0) {
         free(relief);
         sprintf(s,"Error : file %s cannot be closed: %s",argv[4],strerror( errno ));
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* === */
	   /* === Lecture de la carte d'albedo ===*/
      /* === */
      albedo=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         free(relief);
         strcpy(s,"Error : memory allocation for albedo");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((fichier_albedo=fopen(filename_albedo,"rt") ) == NULL) {
         free(relief);
         free(albedo);
         sprintf(s,"Error : file %s cannot be read",argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_albedo)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         }
         token=strtok(s," ");
         for (klon=0;klon<nlon;klon++) {
            if (token==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            }
            albedo[klon*nlat+klat]=atof(token);
            token=strtok(NULL," ");
         }
      }
      fclose(fichier_albedo);
      /* === */
	   /* === Lecture des elements d'orbite de la planete ===*/
      /* === */
      /* --- ouverture du fichier de la base d'orbite ---*/
  		if ((strcmp(orbitformat,"BOWELLFILE")==0)||(strcmp(orbitformat,"MPCFILE")==0)) {
         if ((fichier_in=fopen(orbitfile,"rt") ) == NULL) {
  	   	   orbitfilefound=NO;
		      orbitisgood=NO;
            /* --- le fichier d'orbite n'est pas trouve : il faut sortir ---*/
            sprintf(s,"Error : Orbit file %s (type=%d) not found",orbitfile,orbitformat);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            free(relief);
            return TCL_ERROR;
		   }
      }
      do {
         /* --- lecture d'une ligne de la base d'orbite ---*/
  			orbitisgood=NO;
   		if (strcmp(orbitformat,"BOWELLFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
		         strcpy(orbitstring,"");
   	      }
            mc_bow_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
  			} else if (strcmp(orbitformat,"MPCFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
   		      strcpy(orbitstring,"");
		      }
			   mc_mpc_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
         } else {
            break;
         }
      } while (feof(fichier_in)==0);
      fclose(fichier_in);
      if (orbitisgood==NO) {
         /* --- la planete n'a pas ete trouvee dans fichier d'orbite : il faut sortir ---*/
         sprintf(s,"Error : Planet %s (type %d) not found in the file %s",objename,planetnum,orbitfile);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         return TCL_ERROR;
      }
      mc_aster2elem(aster,&elem);
      /* === */
	   /* === Calcul des coordonnes heliocentriques de la planete et de la Terre pour chaque phase ===*/
      /* === */
      n=(int)ceil(360./dl);
      cdrpos=(mc_cdrpos*)malloc(n*sizeof(mc_cdrpos));
      if (cdrpos==NULL) {
         strcpy(s,"Error : memory allocation for cdrpos");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         return TCL_ERROR;
      }
      /*phi=cdr.jd_phase0-cdr.period*floor((jj-cdr.jd_phase0)/cdr.period);*/
      phi=cdr.jd_phase0+cdr.period*floor((jj-cdr.jd_phase0)/cdr.period);
      for (k=0;k<n;k++) {
         cdrpos[k].phase=1.*k/n;
         cdrpos[k].jd=phi+1.*k/n*cdr.period;
		   mc_xyzasaaphelio(cdrpos[k].jd,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         /*
          xearth=1.;
          yearth=0.;
          zearth=0.;
          delta=1.;
          dlt=0.*(DR);
          xaster=xearth+delta*cos(dlt);
          yaster=yearth+delta*sin(dlt);
          zaster=zearth;
          */
         cdrpos[k].xaster=xaster;
         cdrpos[k].yaster=yaster;
         cdrpos[k].zaster=zaster;
         cdrpos[k].r=r;
         cdrpos[k].mag1=mag;
         cdrpos[k].mag2=mag;
         if (cdr.frame_center==0) { 
            /* heliocentric */
            cdrpos[k].xearth=0.;
            cdrpos[k].yearth=0.;
            cdrpos[k].zearth=0.;
            cdrpos[k].delta=r;
         } else {
            /* geocentric */
            cdrpos[k].xearth=xearth;
            cdrpos[k].yearth=yearth;
            cdrpos[k].zearth=zearth;
            cdrpos[k].delta=delta;
         }
      }
      /* === */
	   /* === Calcul de la courbe de lumiere ===*/
      /* === */
      mc_simulcbin(cdr,relief,albedo,cdrpos,n,genefilename);
      /* === */
	   /* === Sortie des resultats ===*/
      /* === */
      Tcl_DStringAppend(&dsptr,"{",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].jd);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].phase);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag1);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag2);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} ",-1);
      /* === sortie et destructeurs ===*/
      free(cdrpos);
      free(relief);
      free(albedo);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

int Cmd_mctcl_simumagbin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Simulation de magnitudes d'asteroides binaires (SSB)           */
/****************************************************************************/
/* Cette fonction simule la courbe de rotation d'un asteroide SSB dans      */
/* l'intevalle [Date_phase0;Date_phase0+sideral_period_h].                  */
/* Il faut pr�alablement avoir utilis� mc_simurelief                        */
/*																			                   */
/*	ENTREES               											                   */
/*	=======               											                   */
/* Planet                   											                */
/*   Le 1er element contient le nom de la planete :							    */
/*    Name pour un astre dont les elements sont definis par les 2eme et     */
/*     et 3eme elements :													             */
/*   Le 2eme element contient le format des elements d'orbite               */
/*    INTERNAL (defaut) pour les planetes classiques.						       */
/*    BOWELL pour le format de Bowell 									             */
/*    BOWELLFILE pour le format de Bowell sous forme d'un fichier			    */
/*    DAILYMPECFILE Daily MPEC sous forme d'un fichier						    */
/*    DAILYMPEC Daily MPEC													             */
/*   Le 3eme element contient la definition des elements d'orbite :			 */
/*    Rien pour INTERNAL													             */
/*    NameFile pour designer le fichier des elements						       */
/*    String pour la chaine qui contient les elements.						    */
/* Dates 													                               */
/*  Le 1er element contient le debut de la date.                            */
/*    NOW (defauf) pour designer l'instant actuel. 							    */
/*    NOW0 : Pour designer la date actuelle a 0h   							    */
/*    NOW1 : Pour designer la date de demain a 0h   						       */
/*    YYYY-MM-DDThh:mm:ss.ss : Format Iso du Fits.						          */
/*    nombre decimal >= 1000000 : Jour Julien								       */
/*    nombre decimal <  1000000 : Jour Julien Modifie						       */
/*    Year : suivi des elements facultatifs suivants, dans l'ordre :		    */
/*     Month Day Hour Minute Second (Format style Iso mais avec les espaces)*/
/* Refdates : =0 TT, =1 dans le repere de l'asteroide */
/* HTM_level  : niveau du d�coupage HTM                                     */
/* filename_relief : carte de relief creee avec mc_simurelief               */
/* filename_albedo : carte d'albedo creee avec mc_simurelief                */
/* frame_coord : referentiel de coordonnees (=0=ecliptique =1=equatorial)   */
/* frame_center : referentiel de coordonnees (=0=helio =1=geo)              */
/* lon_phase0 : longitude de la phase nulle de la cdr (deg)                 */
/* Date_phase0 : Date de reference de la phase nulle de la cdr (Date)       */
/*               Ce parametre doit etre celcul� dans le repere de date      */
/*               donn� par Refdates.                                        */
/* sideral_period_h : periode de rotation sid�rale (h)                      */
/* lonpole     : longitude du pole (deg) dans frame_coord                   */
/* latpole     : latitude du pole (deg) dans frame_coord                    */
/* a_m : demi-grand axe de l'orbite des binaires (m)                        */
/* ?genefilename? : nom generique des images de simulation de l'astre.      */
/*																			                   */
/*	SORTIES               											                   */
/*	=======               											                   */
/* Liste jd : liste des jours juliens                                       */
/* Liste phases : liste des phases                                          */
/* Liste mag1 : liste des magnitudes pour un diffuseur lambertien           */
/* Liste mag2 : liste des magnitudes pour un diffuseur Lommel-Seeliger      */
/****************************************************************************/
{
   int planetnum;
   char s[65000];
   char objename[100],orbitformat[15],orbitstring[300],orbitfile[1024],filename_relief[1024],filename_albedo[1024];
   double asd,dec,delta;
   double mag,phase,elong,diamapp,r;
   double longmpc=0.,rhocosphip=0.,rhosinphip=0.;
   int orbitfilefound=YES,orbitisgood=NO;
   struct asterident aster;
   struct elemorb elem;
   FILE *fichier_in=NULL;
   FILE *fichier_relief=NULL;
   FILE *fichier_albedo=NULL;
   char *token,*genefilename=NULL;
   Tcl_DString dsptr;

   double xearth,yearth,zearth,xaster,yaster,zaster;
   double dl;
   int n,k;
   mc_cdrpos *cdrpos=NULL;
   mc_cdr cdr;
   double *relief=NULL;
   double *albedo=NULL;
   int klon,klat,nlon,nlat;
   char **argvv=NULL;
   int argcc,njd,code;
   double *jds,jdk;
//double dlt;

   if(argc<15) {
      sprintf(s,"Usage: %s Planet Dates Ref_dates HTM_level filename_relief filename_albedo frame_coord frame_center lon_phase0 Date_phase0 sideral_period_h lonpole latpole a_m ?genefilename?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	   Tcl_DStringInit(&dsptr);
      /* === */
	   /* === Decode des arguments de la ligne de commande ===*/
      /* === */
	   /* --- decode la planete ---*/
      mctcl_decode_planet(interp,argv[1],&planetnum,objename,orbitformat,orbitfile);
	   if (planetnum!=OTHERPLANET) {
         /* --- pb planete non reconnue ---*/
         sprintf(s,"Error : Planet %s (type %d) not found",objename,planetnum);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
 	  /* --- decode les dates ---*/
      code=Tcl_SplitList(interp,argv[2],&argcc,&argvv);
      njd=argcc;
      if (code==TCL_OK) {
         jds=(double*)calloc(argcc,sizeof(double));
         if (jds==NULL) {
            return TCL_ERROR;
         }
         for (k=0;k<njd;k++) {
            mctcl_decode_date(interp,argvv[k],&jds[k]);
         }
         Tcl_Free((char *) argvv);
      } else {
         return TCL_ERROR;
      }
      /* --- decode le referentiel des dates ---*/
      cdr.frame_time=atoi(argv[3]);
      /* --- decode les parametres physiques ---*/
      cdr.htmlevel=atoi(argv[4]);
      strcpy(filename_relief,argv[5]);
      strcpy(filename_albedo,argv[6]);
      cdr.frame_coord=atoi(argv[7]);  /* =0 pole defined /ecliptic.  =1 pole defined /equator. */
      cdr.frame_center=atoi(argv[8]);  /* =0 heliocentric.  =1 geocentric. */
      cdr.lon_phase0=atof(argv[9]);
      mctcl_decode_date(interp,argv[10],&cdr.jd_phase0);
      cdr.period=atof(argv[11])/24.;
      cdr.lonpole=atof(argv[12]);
      cdr.latpole=atof(argv[13]);
      cdr.a=atof(argv[14]); /* demi-grand axe */
      cdr.density=1.; /* assumed but will be recomputed */
      if (argc>=16) {
         genefilename=argv[15];
      } else {
         genefilename=NULL;
      }
      /* --- */
      dl=0.5*sqrt(41253./(8*pow(4,cdr.htmlevel)));
      dl=5.;
	   longmpc=0.;
	   rhocosphip=0.;
	   rhosinphip=0.;
      /* === */
	   /* === Lecture de la carte de relief ===*/
      /* === */
      nlon=360;
      nlat=181;
      relief=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         strcpy(s,"Error : memory allocation for relief");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(jds);
         return TCL_ERROR;
      }
      if ((fichier_relief=fopen(filename_relief,"rt") ) == NULL) {
         free(relief);
         sprintf(s,"Error : file %s cannot be read: %s",argv[5],strerror( errno ));
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(jds);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_relief)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         } else {
            token=strtok(s," ");
            for (klon=0;klon<nlon;klon++) {
               if (token==NULL) {
                  /*--- pb dans le fichier de  la carte de relief ---*/
               }
               relief[klon*nlat+klat]=atof(token);
               token=strtok(NULL," ");
            }
         }
      }
      if (fclose(fichier_relief)!=0) {
         free(relief);
         sprintf(s,"Error : file %s cannot be closed: %s",argv[6],strerror( errno ));
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(jds);
         return TCL_ERROR;
      }
      /* === */
	   /* === Lecture de la carte d'albedo ===*/
      /* === */
      albedo=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         free(relief);
         strcpy(s,"Error : memory allocation for albedo");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(jds);
         return TCL_ERROR;
      }
      if ((fichier_albedo=fopen(filename_albedo,"rt") ) == NULL) {
         free(relief);
         free(albedo);
         sprintf(s,"Error : file %s cannot be read",argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(jds);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_albedo)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         }
         token=strtok(s," ");
         for (klon=0;klon<nlon;klon++) {
            if (token==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            }
            albedo[klon*nlat+klat]=atof(token);
            token=strtok(NULL," ");
         }
      }
      fclose(fichier_albedo);
      /* === */
	   /* === Lecture des elements d'orbite de la planete ===*/
      /* === */
      /* --- ouverture du fichier de la base d'orbite ---*/
  		if ((strcmp(orbitformat,"BOWELLFILE")==0)||(strcmp(orbitformat,"MPCFILE")==0)) {
         if ((fichier_in=fopen(orbitfile,"rt") ) == NULL) {
  	   	   orbitfilefound=NO;
		      orbitisgood=NO;
            /* --- le fichier d'orbite n'est pas trouve : il faut sortir ---*/
            sprintf(s,"Error : Orbit file %s (type=%d) not found",orbitfile,orbitformat);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            free(relief);
            free(jds);
            return TCL_ERROR;
		   }
      }
      do {
         /* --- lecture d'une ligne de la base d'orbite ---*/
  			orbitisgood=NO;
   		if (strcmp(orbitformat,"BOWELLFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
		         strcpy(orbitstring,"");
   	      }
            mc_bow_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
  			} else if (strcmp(orbitformat,"MPCFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
   		      strcpy(orbitstring,"");
		      }
			   mc_mpc_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
         } else {
            break;
         }
      } while (feof(fichier_in)==0);
      fclose(fichier_in);
      if (orbitisgood==NO) {
         /* --- la planete n'a pas ete trouvee dans fichier d'orbite : il faut sortir ---*/
         sprintf(s,"Error : Planet %s (type %d) not found in the file %s",objename,planetnum,orbitfile);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         free(jds);
         return TCL_ERROR;
      }
      mc_aster2elem(aster,&elem);
      /* === */
	   /* === Calcul des coordonnes heliocentriques de la planete et de la Terre pour chaque phase ===*/
      /* === */
      n=argcc;
      cdrpos=(mc_cdrpos*)malloc(n*sizeof(mc_cdrpos));
      if (cdrpos==NULL) {
         strcpy(s,"Error : memory allocation for cdrpos");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         free(jds);
         return TCL_ERROR;
      }
      /*phi=cdr.jd_phase0-cdr.period*floor((jj-cdr.jd_phase0)/cdr.period);*/
      /* --- calcule jd_phase0 dans le repere de l'asteroide ---*/
      if (cdr.frame_time==0) {
         cdr.jd_phase0tt=cdr.jd_phase0;
         mc_xyzasaaphelio(cdr.jd_phase0,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         /* On transforme jd_phase0 dans le repere de l'asteroide */
         mc_aberpla(cdr.jd_phase0,delta,&cdr.jd_phase0);
      }
      /* --- calcule jd_phase0tt dans le repere terrestre ---*/
      if (cdr.frame_time==1) {
         mc_xyzasaaphelio(cdr.jd_phase0,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         /* On transforme jd_phase0 dans le repere de terrestre */
         mc_aberpla(cdr.jd_phase0,delta,&cdr.jd_phase0tt);
      }
      /* --- calcule tous les parametres de l'asteroide pour chaque date ---*/
      for (k=0;k<n;k++) {
         cdrpos[k].jd=jds[k];
         /* jd doit etre en TT */
		   mc_xyzasaaphelio(cdrpos[k].jd,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         if (cdr.frame_time==1) {
            /* cdrpos[k].jd etait entre dans le repere de l'asteroide */
            /* Il faut donc soustraire la duree -delta pour savoir quand on l'a vu depuis la Terre en TT */
            mc_aberpla(cdrpos[k].jd,-delta,&jdk);
            cdrpos[k].jdtt=jdk;
   		   mc_xyzasaaphelio(jdk,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
            cdrpos[k].jd=jds[k];
         } else {
            cdrpos[k].jdtt=cdrpos[k].jd;
            /* On transforme JD dans le repere de l'asteroide */
            mc_aberpla(cdrpos[k].jd,delta,&cdrpos[k].jd);
         }
         /* --- la phase est calculee dans le repere de l'asteroide ---*/
         cdrpos[k].phase=(cdrpos[k].jd-cdr.jd_phase0)/cdr.period;
         cdrpos[k].phase=cdrpos[k].phase-floor(cdrpos[k].phase);
         /* --- la phase est calculee dans le repere terrestre ---*/
         cdrpos[k].phasett=(cdrpos[k].jdtt-cdr.jd_phase0tt)/cdr.period;
         cdrpos[k].phasett=cdrpos[k].phasett-floor(cdrpos[k].phasett);
         /*
          xearth=1.;
          yearth=0.;
          zearth=0.;
          delta=1.;
          dlt=0.*(DR);
          xaster=xearth+delta*cos(dlt);
          yaster=yearth+delta*sin(dlt);
          zaster=zearth;
          */
         cdrpos[k].xaster=xaster;
         cdrpos[k].yaster=yaster;
         cdrpos[k].zaster=zaster;
         cdrpos[k].r=r;
         cdrpos[k].angelong=elong;
         cdrpos[k].angphase=phase;
         cdrpos[k].mag0=mag;
         cdrpos[k].mag1=mag;
         cdrpos[k].mag2=mag;
         if (cdr.frame_center==0) { 
            /* heliocentric */
            cdrpos[k].xearth=0.;
            cdrpos[k].yearth=0.;
            cdrpos[k].zearth=0.;
            cdrpos[k].delta=r;
         } else {
            /* geocentric */
            cdrpos[k].xearth=xearth;
            cdrpos[k].yearth=yearth;
            cdrpos[k].zearth=zearth;
            cdrpos[k].delta=delta;
         }
      }
      /* === */
	   /* === Calcul de la courbe de lumiere ===*/
      /* === */
      mc_simulcbin(cdr,relief,albedo,cdrpos,n,genefilename);
      /* === */
	   /* === Sortie des resultats ===*/
      /* === */
      Tcl_DStringAppend(&dsptr,"{",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].jd);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].phase);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag1);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag2);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].mag0);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].xearth);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].yearth);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].zearth);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].xaster);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].yaster);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].zaster);
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].angelong/(DR));
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      for (k=0;k<n;k++) {
         sprintf(s,"%f ",cdrpos[k].angphase/(DR));
         Tcl_DStringAppend(&dsptr,s,-1);
      }
      Tcl_DStringAppend(&dsptr,"} ",-1);
      /* === sortie et destructeurs ===*/
      free(jds);
      free(cdrpos);
      free(relief);
      free(albedo);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

int Cmd_mctcl_optiparamlc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Optimize the light curve parameters */
/****************************************************************************/
/* Cette fonction simule la courbe de rotation d'un asteroide SSB dans      */
/* l'intevalle [Date_phase0;Date_phase0+sideral_period_h].                  */
/* Il faut pr�alablement avoir utilis� mc_simurelief                        */
/*																			                   */
/*	ENTREES               											                   */
/*	=======               											                   */
/* Planet                   											                */
/*   Le 1er element contient le nom de la planete :							    */
/*    Name pour un astre dont les elements sont definis par les 2eme et     */
/*     et 3eme elements :													             */
/*   Le 2eme element contient le format des elements d'orbite               */
/*    INTERNAL (defaut) pour les planetes classiques.						       */
/*    BOWELL pour le format de Bowell 									             */
/*    BOWELLFILE pour le format de Bowell sous forme d'un fichier			    */
/*    DAILYMPECFILE Daily MPEC sous forme d'un fichier						    */
/*    DAILYMPEC Daily MPEC													             */
/*   Le 3eme element contient la definition des elements d'orbite :			 */
/*    Rien pour INTERNAL													             */
/*    NameFile pour designer le fichier des elements						       */
/*    String pour la chaine qui contient les elements.						    */
/* ListObs nom de l'array qui contient les series d'observations (ex. mes) */
/*    mes(n) : contient le nombre de series. */
/*    mes(jd,1) : liste Dates TT de la premiere serie d'observations. */
/*    mes(mag,1) : liste magnitudes differentielles de la premiere serie d'observations. */
/*    ... */
/*    mes(jd,n) : liste Dates TT de la derniere serie d'observations. */
/*    mes(mag,n) : liste magnitudes differentielles de la derniere serie d'observations. */
/* Dates 													                               */
/*  Le 1er element contient le debut de la date.                            */
/*    NOW (defauf) pour designer l'instant actuel. 							    */
/*    NOW0 : Pour designer la date actuelle a 0h   							    */
/*    NOW1 : Pour designer la date de demain a 0h   						       */
/*    YYYY-MM-DDThh:mm:ss.ss : Format Iso du Fits.						          */
/*    nombre decimal >= 1000000 : Jour Julien								       */
/*    nombre decimal <  1000000 : Jour Julien Modifie						       */
/*    Year : suivi des elements facultatifs suivants, dans l'ordre :		    */
/*     Month Day Hour Minute Second (Format style Iso mais avec les espaces)*/
/* Refdates : =0 UTC, =1 dans le repere de l'asteroide */
/* HTM_level  : niveau du d�coupage HTM                                     */
/* filename_relief : carte de relief creee avec mc_simurelief               */
/* filename_albedo : carte d'albedo creee avec mc_simurelief                */
/* frame_coord : referentiel de coordonnees (=0=ecliptique =1=equatorial)   */
/* frame_center : referentiel de coordonnees (=0=helio =1=geo)              */
/* lon_phase0 : longitude de la phase nulle de la cdr (deg)                 */
/* Date_phase0 : Date de reference de la phase nulle de la cdr (Date)       */
/* sideral_period_h : periode de rotation sid�rale (h)                      */
/* lonpole     : longitude du pole (deg) dans frame_coord                   */
/* latpole     : latitude du pole (deg) dans frame_coord                    */
/* a_m : demi-grand axe de l'orbite des binaires (m)                        */
/* ?genefilename? : nom generique des images de simulation de l'astre.      */
/*																			                   */
/*	SORTIES               											                   */
/*	=======               											                   */
/* Liste jd : liste des jours juliens                                       */
/* Liste phases : liste des phases                                          */
/* Liste mag1 : liste des magnitudes pour un diffuseur lambertien           */
/* Liste mag2 : liste des magnitudes pour un diffuseur Lommel-Seeliger      */
/****************************************************************************/
{
   int planetnum;
   char s[65000];
   char objename[100],orbitformat[15],orbitstring[300],orbitfile[1024],filename_relief[1024],filename_albedo[1024];
   double asd,dec,delta;
   double mag,phase,elong,diamapp,r;
   double longmpc=0.,rhocosphip=0.,rhosinphip=0.;
   int orbitfilefound=YES,orbitisgood=NO;
   struct asterident aster;
   struct elemorb elem;
   FILE *fichier_in=NULL;
   FILE *fichier_relief=NULL;
   FILE *fichier_albedo=NULL;
   char *token,*genefilename=NULL;
   Tcl_DString dsptr;

   double xearth,yearth,zearth,xaster,yaster,zaster;
   double dl;
   int n,k,nk,kseries,nseries,kjd,kjdd,kjds0,kjdbest;
   mc_cdrpos *cdrpos=NULL;
   mc_cdr cdr;
   double *relief=NULL;
   double *albedo=NULL;
   double *lonpoles=NULL;
   double *latpoles=NULL;
   int klon,klat,nlon,nlat,nlonpole,nlatpole;
   char **argvv=NULL;
   int argcc,code,res;
   double jdk,tot,dif,offmag,stdmag;
   double jd1,jd2,jdmed,djd;
   double stdmagmin,offmagmin;
   int kjdmin;
   char mesures[]="mes";

   int njd=100;
   mc_cdrpos cdrpos100[100];
   int kjds[100]; 

   if(argc<15) {
      sprintf(s,"Usage: %s Planet ListObs Ref_dates HTM_level filename_relief filename_albedo frame_coord frame_center lon_phase0 Date_phase0 sideral_period_h List_lonpole List_latpole a_m", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	   Tcl_DStringInit(&dsptr);
      /* === */
	   /* === Decode des arguments de la ligne de commande ===*/
      /* === */
	   /* --- decode la planete ---*/
      mctcl_decode_planet(interp,argv[1],&planetnum,objename,orbitformat,orbitfile);
	   if (planetnum!=OTHERPLANET) {
         /* --- pb planete non reconnue ---*/
         sprintf(s,"Error : Planet %s (type %d) not found",objename,planetnum);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- verifie les dates & mags ---*/
      sprintf(s,"source %s",argv[2]);
      res=Tcl_Eval(interp,s);
      if (res==TCL_ERROR) {
         sprintf(s,"File %s not found",argv[2]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      sprintf(s,"expr int($%s(n))",mesures);
      res=Tcl_Eval(interp,s);
      if (res==TCL_ERROR) {
         sprintf(s,"Variable %s not defined",mesures);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n=(int)atoi(interp->result);
      if (n<=0) {
         sprintf(s,"%s(n)=%d must be strictly positive",mesures,n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      for (k=1;k<=n;k++) {
         sprintf(s,"llength $%s(jd,%d)",mesures,k);
         res=Tcl_Eval(interp,s);
         if (res==TCL_ERROR) {
            sprintf(s,"List %s(jd,%d) contains no element",mesures,k);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         nk=atoi(interp->result);
         sprintf(s,"llength $%s(mag,%d)",mesures,k);
         res=Tcl_Eval(interp,s);
         if (res==TCL_ERROR) {
            sprintf(s,"List %s(jd,%d) contains no element",mesures,k);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         if (nk!=atoi(interp->result)) {
            sprintf(s,"Lists %s(jd,%d) and %s(jd,%d) must have same number of elements",mesures,k,mesures,k);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      nseries=n;
      /* --- decode le referentiel des dates ---*/
      cdr.frame_time=atoi(argv[3]);
      /* --- decode les parametres physiques ---*/
      cdr.htmlevel=atoi(argv[4]);
      strcpy(filename_relief,argv[5]);
      strcpy(filename_albedo,argv[6]);
      cdr.frame_coord=atoi(argv[7]);  /* =0 pole defined /ecliptic.  =1 pole defined /equator. */
      cdr.frame_center=atoi(argv[8]);  /* =0 heliocentric.  =1 geocentric. */
      cdr.lon_phase0=atof(argv[9]);
      mctcl_decode_date(interp,argv[10],&cdr.jd_phase0);
      cdr.period=atof(argv[11])/24.;
 	  /* --- decode la liste des longitudes de pole a tester ---*/
      code=Tcl_SplitList(interp,argv[12],&argcc,&argvv);
      nlonpole=argcc;
      if (code==TCL_OK) {
         lonpoles=(double*)calloc(argcc,sizeof(double));
         if (lonpoles==NULL) {
            return TCL_ERROR;
         }
         for (k=0;k<argcc;k++) {
            lonpoles[k]=(double)atof(argvv[k]);
         }
         Tcl_Free((char *) argvv);
      } else {
         return TCL_ERROR;
      }
 	  /* --- decode la liste des latitudes de pole a tester ---*/
      code=Tcl_SplitList(interp,argv[13],&argcc,&argvv);
      nlatpole=argcc;
      if (code==TCL_OK) {
         latpoles=(double*)calloc(argcc,sizeof(double));
         if (latpoles==NULL) {
            return TCL_ERROR;
         }
         for (k=0;k<argcc;k++) {
            latpoles[k]=(double)atof(argvv[k]);
         }
         Tcl_Free((char *) argvv);
      } else {
         return TCL_ERROR;
      }
      /**/
      cdr.a=atof(argv[14]); /* demi-grand axe */
      cdr.density=1.; /* assumed but will be recomputed */
      /* --- */
      dl=0.5*sqrt(41253./(8*pow(4,cdr.htmlevel)));
      dl=5.;
	   longmpc=0.;
	   rhocosphip=0.;
	   rhosinphip=0.;
      /* === */
	   /* === Lecture de la carte de relief ===*/
      /* === */
      nlon=360;
      nlat=181;
      relief=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         strcpy(s,"Error : memory allocation for relief");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((fichier_relief=fopen(filename_relief,"rt") ) == NULL) {
         free(relief);
         sprintf(s,"Error : file %s cannot be read: %s",argv[4],strerror( errno ));
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_relief)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         } else {
            token=strtok(s," ");
            for (klon=0;klon<nlon;klon++) {
               if (token==NULL) {
                  /*--- pb dans le fichier de  la carte de relief ---*/
               }
               relief[klon*nlat+klat]=atof(token);
               token=strtok(NULL," ");
            }
         }
      }
      if (fclose(fichier_relief)!=0) {
         free(relief);
         sprintf(s,"Error : file %s cannot be closed: %s",argv[4],strerror( errno ));
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* === */
	   /* === Lecture de la carte d'albedo ===*/
      /* === */
      albedo=(double*)calloc(nlon*nlat,sizeof(double));
      if (relief==NULL) {
         free(relief);
         strcpy(s,"Error : memory allocation for albedo");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((fichier_albedo=fopen(filename_albedo,"rt") ) == NULL) {
         free(relief);
         free(albedo);
         sprintf(s,"Error : file %s cannot be read",argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;

      }
      for (klat=0;klat<nlat;klat++) {
         if (fgets(s,65000,fichier_albedo)==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            nlon=nlon;
         }
         token=strtok(s," ");
         for (klon=0;klon<nlon;klon++) {
            if (token==NULL) {
               /*--- pb dans le fichier de  la carte de relief ---*/
            }
            albedo[klon*nlat+klat]=atof(token);
            token=strtok(NULL," ");
         }
      }
      fclose(fichier_albedo);
      /* === */
	   /* === Lecture des elements d'orbite de la planete ===*/
      /* === */
      /* --- ouverture du fichier de la base d'orbite ---*/
  		if ((strcmp(orbitformat,"BOWELLFILE")==0)||(strcmp(orbitformat,"MPCFILE")==0)) {
         if ((fichier_in=fopen(orbitfile,"rt") ) == NULL) {
  	   	   orbitfilefound=NO;
		      orbitisgood=NO;
            /* --- le fichier d'orbite n'est pas trouve : il faut sortir ---*/
            sprintf(s,"Error : Orbit file %s (type=%d) not found",orbitfile,orbitformat);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            free(relief);
            return TCL_ERROR;
		   }
      }
      do {
         /* --- lecture d'une ligne de la base d'orbite ---*/
  			orbitisgood=NO;
   		if (strcmp(orbitformat,"BOWELLFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
		         strcpy(orbitstring,"");
   	      }
            mc_bow_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
  			} else if (strcmp(orbitformat,"MPCFILE")==0) {
            if (fgets(orbitstring,300,fichier_in)==0) {
   		      strcpy(orbitstring,"");
		      }
			   mc_mpc_dec1(orbitstring,&aster);
   	      if ((strcmp(aster.name,objename)==0)||(aster.num==atoi(objename))) {
     			   orbitisgood=YES;
               break;
			   }
         } else {
            break;
         }
      } while (feof(fichier_in)==0);
      fclose(fichier_in);
      if (orbitisgood==NO) {
         /* --- la planete n'a pas ete trouvee dans fichier d'orbite : il faut sortir ---*/
         sprintf(s,"Error : Planet %s (type %d) not found in the file %s",objename,planetnum,orbitfile);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(relief);
         free(albedo);
         return TCL_ERROR;
      }
      mc_aster2elem(aster,&elem);
      /* --- calcule jd_phase0 dans le repere de l'asteroide ---*/
      if (cdr.frame_time==0) {
         cdr.jd_phase0tt=cdr.jd_phase0;
         mc_xyzasaaphelio(cdr.jd_phase0,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         /* On transforme jd_phase0 dans le repere de l'asteroide */
         mc_aberpla(cdr.jd_phase0,delta,&cdr.jd_phase0);
      }
      /* --- calcule jd_phase0tt dans le repere terrestre ---*/
      if (cdr.frame_time==1) {
         mc_xyzasaaphelio(cdr.jd_phase0,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
         /* On transforme jd_phase0 dans le repere de terrestre */
         mc_aberpla(cdr.jd_phase0,delta,&cdr.jd_phase0tt);
      }
      /* === */
	   /* === Grande boucle sur les series ===*/
      /* === */
      for (kseries=2;kseries<=2;kseries++) {
      //for (kseries=1;kseries<=nseries;kseries++) {
         sprintf(s,"llength $%s(jd,%d)",mesures,kseries);
         res=Tcl_Eval(interp,s);
         n=(int)atoi(interp->result);
         /* === */
	      /* === Calcul des coordonnes heliocentriques de la planete et de la Terre pour chaque phase ===*/
         /* === */
         cdrpos=(mc_cdrpos*)malloc(n*sizeof(mc_cdrpos));
         if (cdrpos==NULL) {
            strcpy(s,"Error : memory allocation for cdrpos");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            free(relief);
            free(albedo);
            return TCL_ERROR;
         }
         /* --- calcule la date de la premiere et de la derniere observation ---*/
         for (k=0;k<n;k+=n-1) {
            sprintf(s,"mc_date2jd [lindex $%s(jd,%d) %d]",mesures,kseries,k);
            res=Tcl_Eval(interp,s);
            cdrpos[k].jd=(double)atof(interp->result);
            cdrpos[k].jdtt=cdrpos[k].jd;
            if (cdr.frame_time==1) {
   		      mc_xyzasaaphelio(cdrpos[k].jd,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
               /* cdrpos[k].jd etait entre dans le repere de l'asteroide */
               /* Il faut donc soustraire la duree -delta pour savoir quand on l'a vu depuis la Terre en TT */
               mc_aberpla(cdrpos[k].jd,-delta,&jdk);
               cdrpos[k].jdtt=jdk;
            }
         }
	      /* === Calcule les njd(=100) dates qui encadrent le mieux l'observation ===*/
         jdmed=(cdrpos[0].jdtt+cdrpos[n-1].jdtt)/2;
         jd1=jdmed-cdr.period/2.;
         jd2=jd1+cdr.period;
         djd=cdr.period*njd/(njd-1); /* pour obtenir la meme phase au debut et a la fin */
         /* --- calcule tous les parametres de l'asteroide pour les njd(=100) dates TT couvrant une periode complete  ---*/
         for (k=0;k<njd;k++) {
            cdrpos100[k].jdtt=jd1+(djd*k)/njd; /* Formule lin1 */
            /* jd est toujours en TT ici */
		      mc_xyzasaaphelio(cdrpos100[k].jdtt,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
            if (cdr.frame_time==0) {
               /* On transforme JD dans le repere de l'asteroide */
               mc_aberpla(cdrpos100[k].jdtt,delta,&cdrpos100[k].jd);
            }
            /* --- la phase est calculee dans le repere de l'asteroide ---*/
            cdrpos100[k].phase=(cdrpos100[k].jd-cdr.jd_phase0)/cdr.period;
            cdrpos100[k].phase=cdrpos100[k].phase-floor(cdrpos100[k].phase);
            /* --- la phase est calculee dans le repere terrestre ---*/
            cdrpos100[k].phasett=(cdrpos100[k].jdtt-cdr.jd_phase0tt)/cdr.period;
            cdrpos100[k].phasett=cdrpos100[k].phasett-floor(cdrpos100[k].phasett);
            cdrpos100[k].xaster=xaster;
            cdrpos100[k].yaster=yaster;
            cdrpos100[k].zaster=zaster;
            cdrpos100[k].r=r;
            cdrpos100[k].angelong=elong;
            cdrpos100[k].angphase=phase;
            cdrpos100[k].mag1=mag;
            cdrpos100[k].mag2=mag;
            if (cdr.frame_center==0) { 
               /* heliocentric */
               cdrpos100[k].xearth=0.;
               cdrpos100[k].yearth=0.;
               cdrpos100[k].zearth=0.;
               cdrpos100[k].delta=r;
            } else {
               /* geocentric */
               cdrpos100[k].xearth=xearth;
               cdrpos100[k].yearth=yearth;
               cdrpos100[k].zearth=zearth;
               cdrpos100[k].delta=delta;
            }
         }
         /* --- calcule les parametres observes de l'asteroide ---*/
         for (k=0;k<n;k++) {
            sprintf(s,"mc_date2jd [lindex $%s(jd,%d) %d]",mesures,kseries,k);
            res=Tcl_Eval(interp,s);
            cdrpos[k].jd=(double)atof(interp->result);
            sprintf(s,"lindex $%s(mag,%d) %d",mesures,kseries,k);
            res=Tcl_Eval(interp,s);
            cdrpos[k].mag0=(double)atof(interp->result);
            /* jd doit etre en TT pour mc_xyzasaaphelio */
		      mc_xyzasaaphelio(cdrpos[k].jd,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
            if (cdr.frame_time==1) {
               /* cdrpos[k].jd etait entre dans le repere de l'asteroide */
               /* Il faut donc soustraire la duree -delta pour savoir quand on l'a vu depuis la Terre en TT */
               mc_aberpla(cdrpos[k].jd,-delta,&cdrpos[k].jdtt);
   		      mc_xyzasaaphelio(cdrpos[k].jdtt,longmpc,rhocosphip,rhosinphip,elem,cdr.frame_coord,&xearth,&yearth,&zearth,&xaster,&yaster,&zaster,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&r);
            } else {
               /* On transforme JD dans le repere de l'asteroide */
               cdrpos[k].jdtt=cdrpos[k].jd;
               mc_aberpla(cdrpos[k].jdtt,delta,&cdrpos[k].jd);
            }
            /* --- la phase est calculee dans le repere de l'asteroide ---*/
            cdrpos[k].phase=(cdrpos[k].jd-cdr.jd_phase0)/cdr.period;
            cdrpos[k].phase=cdrpos[k].phase-floor(cdrpos[k].phase);
            /* --- la phase est calculee dans le repere terrestre ---*/
            cdrpos[k].phasett=(cdrpos[k].jdtt-cdr.jd_phase0tt)/cdr.period;
            cdrpos[k].phasett=cdrpos[k].phasett-floor(cdrpos[k].phasett);
            cdrpos[k].xaster=xaster;
            cdrpos[k].yaster=yaster;
            cdrpos[k].zaster=zaster;
            cdrpos[k].r=r;
            cdrpos[k].angelong=elong;
            cdrpos[k].angphase=phase;
            cdrpos[k].mag1=mag;
            cdrpos[k].mag2=mag;
            if (cdr.frame_center==0) { 
               /* heliocentric */
               cdrpos[k].xearth=0.;
               cdrpos[k].yearth=0.;
               cdrpos[k].zearth=0.;
               cdrpos[k].delta=r;
            } else {
               /* geocentric */
               cdrpos[k].xearth=xearth;
               cdrpos[k].yearth=yearth;
               cdrpos[k].zearth=zearth;
               cdrpos[k].delta=delta;
            }
         }
         /* === */
	      /* === Boucles sur les couples (lon,lat) ===*/
         /* === */
         for (kjd=0;kjd<njd;kjd++) {
            kjds[kjd]=kjd;
         }
         for (klon=0;klon<nlonpole;klon++) {
            for (klat=0;klat<nlatpole;klat++) {
               /* === */
	            /* === Calcul de la courbe de lumiere ===*/
               /* === */
               cdr.lonpole=lonpoles[klon];
               cdr.latpole=latpoles[klat];
               mc_simulcbin(cdr,relief,albedo,cdrpos100,njd,genefilename);
               /* --- boucle sur les longitudes initiales ---*/
               stdmagmin=1e20;
               for (kjd=0;kjd<njd;kjd++) {
                  /* === */
	               /* === Calcul l'offset a appliquer sur les mesures de magnitude ===*/
                  /* === */
                  tot=0;
                  for (k=0;k<n;k++) {
                     kjdbest=(int)((cdrpos[k].jdtt-jd1)/djd*njd); /* Formule lin1 inverse */
                     if (kjdbest<0) {kjdbest=0;}
                     if (kjdbest>=njd) {kjdbest=njd-1;}
                     tot+=(cdrpos[k].mag0-cdrpos100[kjds[kjdbest]].mag2);
                  }
                  offmag=tot/n;
                  /* === */
	               /* === Calcul l'ecart type o-c ===*/
                  /* === */
                  tot=0;
                  for (k=0;k<n;k++) {
                     kjdbest=(int)((cdrpos[k].jdtt-jd1)/djd*njd); /* Formule lin1 inverse */
                     if (kjdbest<0) {kjdbest=0;}
                     if (kjdbest>=njd) {kjdbest=njd-1;}
                     dif=(cdrpos[k].mag0-offmag-cdrpos100[kjds[kjdbest]].mag2);
                     tot+=dif*dif;
                  }
                  stdmag=sqrt(tot/n);
                  if (stdmag<stdmagmin) {
                     stdmagmin=stdmag;
                     offmagmin=offmag;
                     kjdmin=kjds[0];
                  }
                  /* --- on fait tourner les indices d'un cran ---*/
                  kjds0=kjds[0];
                  for (kjdd=0;kjdd<njd-1;kjdd++) {
                     kjds[kjdd]=kjds[kjdd+1];
                  }
                  kjds[njd-1]=kjds0;
               }
               Tcl_DStringAppend(&dsptr,"{",-1);
               sprintf(s,"%f %f %d %e",cdr.lonpole,cdr.latpole,kseries,stdmagmin);
               Tcl_DStringAppend(&dsptr,s,-1);
               for (kjd=0;kjd<njd;kjd++) {
                  kjds[kjd]=kjdmin+kjd;
                  if (kjds[kjd]>=njd) {
                     kjds[kjd]-=njd;
                  }
               }
               for (k=0;k<n;k++) {
                  kjdbest=(int)((cdrpos[k].jdtt-jd1)/djd*njd); /* Formule lin1 inverse */
                  if (kjdbest<0) {kjdbest=0;}
                  if (kjdbest>=njd) {kjdbest=njd-1;}
                  Tcl_DStringAppend(&dsptr,"{",-1);
                  sprintf(s,"%f %f",cdrpos[k].mag0-offmagmin,cdrpos100[kjds[kjdbest]].mag2);
                  Tcl_DStringAppend(&dsptr,"} ",-1);
               }
               Tcl_DStringAppend(&dsptr,"} ",-1);
            }
         }
         /* === */
	      /* === Libere la memoire de cette serie ===*/
         /* === */
         free(cdrpos);
      } /*=== fin de la boucle sur les series ===*/
      /* === sortie et destructeurs ===*/
      free(relief);
      free(albedo);
      free(lonpoles);
      free(latpoles);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

