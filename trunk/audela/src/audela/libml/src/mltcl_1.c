/* mltcl_1.c
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

/***************************************************************************/
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers ml_*.c.                              */
/***************************************************************************/
/* Le include mltcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "mltcl.h"

int Cmd_mltcl_geostatreduc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Reduction des objets susceptibles etre des satellites geostationnaires.  */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   char s[1000],ligne[1000];
   char im0[40],im[40];
   double sepmin; /* minimum de distance pour deux objets dans la meme image (degrés) */
   double sepmax; /* maximum de distance pour deux objets dans la des images différentes (degrés) */
   double jjdifmin=0.014; /* differences de jours pour autoriser la comparaison */
   FILE *f_in;
   int k,k1,k2,k3,kimage,nimages,kobject;
   int n_in;
   struct_ligsat *lignes;
   int *kdebs,*kfins;
   double annee, mois, jour, heure, minute, seconde, jd, pi, dr;
   double ha1,ha2,ha3,dec1,dec2,dec3,sep,pos,jd1,jd2,jd3,sep12,pos12,sep23,pos23,dec30,ha30,dha,ddec;
   int ki1,ki2,ki3;
   int matching_poursuit=1,nifin1,nifin2;

   if(argc<3) {
      sprintf(s,"Usage: %s file_00 file_0 ?sepmin? ?sepmax? ?jjdifmin? ?matching_poursuit?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/

      /* --- decode les parametres facultatifs ---*/
      sepmin=3.3*5/3600.; /* default value = 5 pixels pour TAROT */
      if (argc>=4) {
         retour = Tcl_GetDouble(interp,argv[3],&sepmin);
         if(retour!=TCL_OK) return retour;
      }
      sepmax=60./3600.; /* default value = 60 arcsec pour TAROT */
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&sepmax);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&jjdifmin);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=7) {
         retour = Tcl_GetInt(interp,argv[6],&matching_poursuit);
         if(retour!=TCL_OK) return retour;
      }

      /* --- lecture du nombre de lignes dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
            n_in++;
         }
      }
      fclose(f_in);

      /* --- dimensionne la structure des donnees d'entree ---*/
      lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
      if (lignes==NULL) {
         sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      /* --- lecture des donnes ligne par ligne dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      strcpy(im0,"");
      kimage=-1;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
            strcpy(lignes[n_in].texte,ligne);
            lignes[n_in].comment=1;
            lignes[n_in].kimage1=-1;
            lignes[n_in].kobject1=-1;
            lignes[n_in].kimage2=-1;
            lignes[n_in].kobject2=-1;
            lignes[n_in].matched=0;
            if (strlen(ligne)>=3) {
               if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
                  lignes[n_in].comment=0;
               }
            }
            if (lignes[n_in].comment==0) {
               k1=115 ; k2=123 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               lignes[n_in].ha=atof(s);
               k1=104 ; k2=113 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               lignes[n_in].dec=atof(s);
               k1= 83 ; k2= 91 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               lignes[n_in].mag=atof(s);
               k1= 38 ; k2= 41 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               annee=atof(s);
               k1= 43 ; k2= 44 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               mois=atof(s);
               k1= 46 ; k2= 47 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               jour=atof(s);
               k1= 49 ; k2= 50 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               heure=atof(s);
               k1= 52 ; k2= 53 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               minute=atof(s);
               k1= 55 ; k2= 60 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               seconde=atof(s);
               ml_date2jd(annee,mois,jour,heure,minute,seconde,&jd);
               lignes[n_in].jd=jd;
               k1=  0 ; k2= 36 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               strcpy(im,s);
               if (strcmp(im,im0)!=0) {
                  kimage++;
                  kobject=0;
               }
               lignes[n_in].kimage=kimage;
               lignes[n_in].kobject=kobject;
               strcpy(im0,im);
               kobject++;
            } else {
               lignes[n_in].ha=0.;
               lignes[n_in].dec=0.;
               lignes[n_in].jd=0.;
               lignes[n_in].mag=99.;
               lignes[n_in].kimage=-1;
               lignes[n_in].kobject=-1;
            }
            n_in++;
         }
      }
      fclose(f_in);
      nimages=kimage+1;

      /* --- dimensionne les tableaux des indices de debut et de fin d'entree ---*/
      kdebs=(int*)calloc(nimages,sizeof(int));
      if (kdebs==NULL) {
         sprintf(s,"error : kdebs pointer out of memory (%d elements)",nimages);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         return TCL_ERROR;
      }
      for (k=0;k<nimages;k++) {
         kdebs[k]=-1;
      }
      kfins=(int*)calloc(nimages,sizeof(int));
      if (kdebs==NULL) {
         sprintf(s,"error : kfins pointer out of memory (%d elements)",nimages);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         free(kdebs);
         return TCL_ERROR;
      }
      for (k=0;k<nimages;k++) {
         kfins[k]=0;
      }

      /* --- affecte les tableaux des indices de debut et de fin d'entree ---*/
      for (k=0;k<n_in;k++) {
         kimage=lignes[k].kimage;
         if (kimage>=0) {
            if (kdebs[kimage]==-1) {
               kdebs[kimage]=k;
            }
            if (kfins[kimage]<=k) {
               kfins[kimage]=k;
            }
         }
      }

      /* --- premiere passe, on elimine les objets multiples sur chaque pose ---*/
      pi=4.*atan(1.);
      dr=pi/180.;
      for (k=0;k<nimages;k++) {
         for (k1=kdebs[k];k1<=kfins[k]-1;k1++) {
            if (lignes[k1].comment!=0) {
               continue;
            }
            ha1=lignes[k1].ha;
            dec1=lignes[k1].dec;
            for (k2=k1+1;k2<=kfins[k];k2++) {
               if (lignes[k2].comment!=0) {
                  continue;
               }
               ha2=lignes[k2].ha;
               dec2=lignes[k2].dec;
               ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep,&pos);
               sep=sep/dr;
               if (sep<sepmin) {
                  /* --- on elimine le moins brillant ---*/
                  if (lignes[k1].mag<lignes[k2].mag) {
                     lignes[k2].comment=2;
                  } else {
                     lignes[k1].comment=2;
                  }
               }
            }
         }
      }

      /* --- deuxieme passe, on apparie les objects sur les images differentes ---*/
      /* --- avec matching poursuit a 3 dates ---*/
      if (matching_poursuit==1) {
         nifin1=2;
         nifin2=1;
      } else {
         nifin1=1;
         nifin2=0;
      }
      for (ki1=0;ki1<nimages-nifin1;ki1++) {
         for (k1=kdebs[ki1];k1<=kfins[ki1];k1++) {
            if (lignes[k1].comment!=0) {
               continue;
            }
            jd1=lignes[k1].jd;
            ha1=lignes[k1].ha;
            dec1=lignes[k1].dec;
            for (ki2=ki1+1;ki2<nimages-nifin2;ki2++) {
               for (k2=kdebs[ki2];k2<=kfins[ki2];k2++) {
                  if (lignes[k2].comment!=0) {
                     continue;
                  }
                  jd2=lignes[k2].jd;
                  if (fabs(jd2-jd1)>jjdifmin) {
                     continue;
                  }
                  ha2=lignes[k2].ha;
                  dec2=lignes[k2].dec;
                  ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep12,&pos12);
                  sep12=sep12/dr;
                  if (sep12>sepmax) {
                     continue;
                  }
                  if (matching_poursuit==0) {
                     lignes[k1].kimage1=ki2;
                     lignes[k1].kobject1=k2;
                     lignes[k1].matched++;
                     lignes[k2].matched++;
                     continue;
                  }
                  for (ki3=ki2+1;ki3<nimages;ki3++) {
                     for (k3=kdebs[ki3];k3<=kfins[ki3];k3++) {
                        if (lignes[k3].comment!=0) {
                           continue;
                        } 
                        jd3=lignes[k3].jd;
                        if (fabs(jd3-jd2)>jjdifmin) {
                           continue;
                        }
                        ha3=lignes[k3].ha;
                        dec3=lignes[k3].dec;
                        ml_sepangle(ha2*dr,ha3*dr,dec2*dr,dec3*dr,&sep23,&pos23);
                        sep23=sep23/dr;
                        if (sep23>sepmax) {
                            continue;
                        }
                        /* --- matching poursuit --- */
                        dha=(ha2-ha1);
                        if (dha>180) { dha=360.-dha; }
                        if (dha<-180) { dha=360.+dha; }
                        ha30=ha1+(ha2-ha1)*(jd3-jd1)/(jd2-jd1);
                        ddec=(dec2-dec1);
                        dec30=dec1+(dec2-dec1)*(jd3-jd1)/(jd2-jd1);
                        ml_sepangle(ha30*dr,ha3*dr,dec30*dr,dec3*dr,&sep,&pos);
                        sep=sep/dr;
                        if (sep*3600>10.) {
                           continue;
                        }
                        lignes[k1].kimage1=ki2;
                        lignes[k1].kobject1=k2;
                        lignes[k1].kimage2=ki3;
                        lignes[k1].kobject2=k3;
                        lignes[k1].matched++;
                        lignes[k2].matched++;
                        lignes[k3].matched++;
                     }
                  }
               }
            }
         }
      }

      /* --- sauve le resultat dans le fichier de sortie ---*/
      f_in=fopen(argv[2],"wt");
      if (f_in==NULL) {
         sprintf(s,"file_0 %s not created",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         free(kdebs);
         free(kfins);
         return TCL_ERROR;
      }
      fprintf(f_in,"%s",lignes[0].texte);
      fprintf(f_in,"%s",lignes[1].texte);
      fprintf(f_in,"%s",lignes[2].texte);
      kimage=-1;
      for (k=3;k<n_in;k++) {
         if (lignes[k].matched>0) {
            if ((lignes[k].kimage!=kimage)&&(kimage!=-1)) {
               fprintf(f_in,"\n");
            }
            fprintf(f_in,"%s",lignes[k].texte);
            kimage=lignes[k].kimage;
         }
      }
      fclose(f_in);

      /* --- libere les pointeurs --- */
      free(lignes);
      free(kdebs);
      free(kfins);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mltcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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
      ml_date2jd(y,m,d,hh,mm,ss,&jd);
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

int Cmd_mltcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   ml_image image;
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
      result=mltcl_getinfoimage(interp,numbuf,&image);
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

int mltcl_getinfoimage(Tcl_Interp *interp,int numbuf, ml_image *image)
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

