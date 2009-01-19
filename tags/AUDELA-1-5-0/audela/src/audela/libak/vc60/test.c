            for (kzmg=0;kzmg<n_zmg;kzmg++) {
               kkzmg=htmzmgs[kzmg].indexzmg;
               kk=0;
               /* --- boucle sur les seuls elements de htmmes concernes ---*/
               for (kref=0;kref<n_ref;kref++) {
                  n=(int)flt_mes[AK_ALLJD*n_ref+kref];
                  if (n<3) {
                     continue;
                  }
                  mean=(double)flt_mes[AK_MAGMOY*n_ref+kref];
                  sigma=(double)flt_mes[AK_SIGMOY*n_ref+kref];
                  /* --- nb de mesures superieures a 3*sigma ---*/
                  magmax=mean+3*sigma;
                  magmin=mean-3*sigma;
                  k=ind_refzmg[kref*n_zmg+kkzmg];
                  if (htmmess[k].codefiltre!=ukfil) {
                     continue;
                  }
                  if (htmmess[k].codecam!=ukcam) {
                     continue;
                  }




                  if (k>=0) {
                     val[kk]=(double)(magmed-htmmess[k].maginst);
                     kk++;
                  }
               }
               n=kk;
               if (n<2) {
                  htmzmgs[kkzmg].cmag=(float)-99.9;
               } else {
                  /* --- on trie les donnees ---*/
                  ak_util_qsort_double(val,0,n,NULL);
                  /* --- indice de la valeur mediane ---*/
                  k=(n+1)/2;
                  htmzmgs[kkzmg].cmag=(float)val[k];
               }
            }
