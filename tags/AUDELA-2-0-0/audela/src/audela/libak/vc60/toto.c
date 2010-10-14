   char s[100];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   struct_htmzmg  htmzmg,*htmzmgs=NULL;
   int *ind_mes=NULL;
   int *ind_jd=NULL;
   int n_mes,k,kcam,kfil,n_index,kk,n_zmg,kmaxi,kmaxi0;
   int n_selec_index,n_selec_jd;
   unsigned char ukcam,ukfil;
   FILE *f_in,*f_out;
   int codes[256][256];
   if(argc<2) {
      sprintf(s,"Usage: %s generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(generic_filename,argv[1]);
      /* --- init des tableaux ---*/
      for (kcam=0;kcam<256;kcam++) {
         for (kfil=0;kfil<256;kfil++) {
            codes[kcam][kfil]=0;
         }
      }
      /* --- compte le nombre de dates-filtre dans HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s_zmg.bin",generic_filename);
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
      sprintf(filename_in,"%s_zmg.bin",generic_filename);
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
      sprintf(filename_in,"%s_mes.bin",generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      n_mes=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            codes[(int)htmmes.codecam][(int)htmmes.filtre]++;
            n_mes++;
         }
      }
      n_index=htmmes.index;
      fclose(f_in);
      if (n_mes==0) return TCL_OK;
      /* --- alloue la memoire ---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      /* --- lecture des donnees ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmess[k]=htmmes;
            k++;
         }
      }
      fclose(f_in);
      /* --- on dimensionne le tableau de l'histogramme ---*/
      int_mes=(int*)calloc(n_index*3,*sizeof(int));
      if (int_mes==NULL) {
         sprintf(s,"error : int_mes pointer out of memory (%d elements)",n_index*3);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      /* --- on remplit la ligne 0 de l'histogramme par les */
      /*     numero de ligne de htmmess de debut de nouvelle date */
      kk=-1;
      for (k=0;k<=n_mes;k++) {
         if (htmmess[k].index>kk) {
            kk++;
            int_mes[kk]=k;
         }
      }
      /* --- on dimensionne le tableau de jd ---*/
      int_jd=(int*)calloc(n_zmg,*sizeof(int));
      if (int_mes==NULL) {
         sprintf(s,"error : int_mes pointer out of memory (%d elements)",n_index*3);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      /* === grande boucle sur les cam+filtre ===*/
      for (kcam=0;kcam<256;kcam++) {
         ukcam=(unsigned char)kcam;
         for (kfil=0;kfil<256;kfil++) {
            ukfil=(unsigned char)kfil;
            if (codes[kcam][kfil]==0) {
               continue;
            }
            /* --- des mesures ont été faites avec ce cam+filtre ---*/
            /* --- on commence par initialiser l'histogramme des mesures ---*/
            for (k=0;k<=n_index;k++) {
               int_mes[n_index+k]=0;
            }
            /* --- on remplit l'histogramme des mesures ---*/
            for (k=0;k<=n_mes;k++) {
               if ((htmmess[k].codecam==ukcam)&&(htmmess[k].filtre==ukfil)) {
                  int_mes[n_index+htmmess[k]]++;
               }
            }
            /* --- on recherche la valeur maximale de l'histogramme ---*/
            kmaxi=0;
            for (k=0;k<=n_index;k++) {
               if (int_mes[n_index+k]>kmaxi) kmaxi=k;
            }
            /* --- on compte toutes les etoiles qui sont > 0.8*maxi ---*/
            kmaxi0=(int)(0.8*kmaxi);
            n_selec_index=0;
            for (k=0;k<=n_index;k++) {
               if (int_mes[n_index+k]>kmaxi0) {
                  n_selec_index++;
                  int_mes[2*n_index+k]=1;
               } else {
                  int_mes[2*n_index+k]=0;
               }
            }
            if (n_selec_index<4) continue;            
            /* --- on dimensionne le tableau x=index y=jd --- */
            mags=(*float)calloc(n_selec*n_zmg); /* n_zmg est plus grand que la dimension effective */
            if (mags==NULL) continue;

         }
      }

         }
      }
      /* === fin de la grande boucle sur les cam+filtre ===*/
   }
   return TCL_OK;
