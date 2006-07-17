/* Ce script contient des fonctions que j'utilise pour faire des statistiques
sur les étoiles du GCVS : Trouver le numéro de l'étoile dans le fichier bin
et le nombre de mesures avec les 4 filtres*/

#include "aktcl.h"
#include "ak_4.h"

int Cmd_aktcl_starnum(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/**************************************************************************************
** Cette fonction trouve dans un fichier htm, l'etoile la plus proche des coordonnees**
** definies en entree. Elle renvoie l'indice de l'etoile dans le fichier htm_ref, la***
** distance par rapport aux coordonnees en arcsec, et le nombre de mesures >-99.9 dans*
** les filtres B C I R V***************************************************************
*/
{
   char s[100];
   char path[1024];
   char filename[1024],htm[100];
   struct_htmref htmref;
   struct_htmmes htmmes;
   double ra0,dec0,dra,ddec,distance,distance0,coeff,cosdec,mag,ra,dec;
   int indice,starnum,B_mes,C_mes,I_mes,R_mes,V_mes;
   unsigned char filtre;
   FILE *f;
   Tcl_DString dsptr;
   if(argc<5) {
      sprintf(s,"Usage: %s path htm ra0 dec0", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(htm,argv[2]);
	  ra0=atof(argv[3]);
	  dec0=atof(argv[4]);
	  /*Inits*/
	  coeff = 4*atan(1)/180.;
      distance=10000.;
      /* --- Cherche l'étoile la plus proche dans le fichier htmref ---*/
      sprintf(filename,"%s%s_ref.bin",path,htm);
      f=fopen(filename,"rb");
      if (f==NULL) {
         sprintf(s,"filename %s not found",filename);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      while (feof(f)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f)>1) {
            indice  = htmref.indexref;
			ra      = htmref.ra;
			dec     = htmref.dec;
			dra     = ra-ra0;
			cosdec  = cos(coeff*dec);
			dra    *= cosdec*cosdec*dra;
			ddec    = dec-dec0;
			ddec   *= ddec;
			distance0 = 3600*sqrt(dra+ddec);
			if(distance>distance0) {
				distance=distance0;
				starnum=indice;
			}
         }
      }
      fclose(f);
      /* --- Compte le nombre de mesure ---*/
      sprintf(filename,"%s%s_mes.bin",path,htm);
      f=fopen(filename,"rb");
      if (f==NULL) {
         sprintf(s,"filename %s not found",filename);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  B_mes=0;
	  C_mes=0;
	  I_mes=0;
	  R_mes=0;
	  V_mes=0;      
	  while (feof(f)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f)>1) {
            indice  = htmmes.indexref;
			if (indice!=starnum) {
				continue;
			} else {
				filtre = htmmes.codefiltre;
				mag    = htmmes.magcali;
				if (mag>-50.) {
					switch (filtre) {
						case 66 : B_mes++;break;
						case 67 : C_mes++;break;
						case 73 : I_mes++;break;
						case 82 : R_mes++;break;
						case 86 : V_mes++;break;
					}
				}
				break;
			}
		 }
	  }
	  while (feof(f)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f)>1) {
            indice  = htmmes.indexref;
			if (indice!=starnum) {
				break;
			} else {
				filtre = htmmes.codefiltre;
				mag    = htmmes.magcali;
				if (mag>-50.) {
					switch (filtre) {
						case 66 : B_mes++;break;
						case 67 : C_mes++;break;
						case 73 : I_mes++;break;
						case 82 : R_mes++;break;
						case 86 : V_mes++;break;
					}
				}
			}
		 }
	  }
      fclose(f);
      /* --- on renome le fichier ---*/
      sprintf(s,"%10s %4d %6.1f %5d %5d %5d %5d %5d",htm,starnum,distance,B_mes,C_mes,I_mes,R_mes,V_mes);
      Tcl_DStringInit(&dsptr);
	  Tcl_DStringAppend(&dsptr,s,-1);
	  Tcl_DStringResult(interp,&dsptr);
	  Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}
/****************************************************************************************/
int Cmd_aktcl_statcata(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************************
** Cette fonction etablie un histogramme des mesures valables (>-99.9) dans un htm dans**
** les filtres B C I R V. Elle renvoie un histogramme de 20 cases (4 par filtres)avec ***
** [filtre_inf10,filtre_inf50,filtre_inf100, filtre_sup100]******************************
*/
{
   char s[400];
   char path[1024];
   char filename[1024],htm[100];
   struct_htmmes htmmes;
   double mag;
   int k_hist,indice,indice0,B_mes,C_mes,I_mes,R_mes,V_mes;
   unsigned char filtre;
   FILE *f;
   int histo[20];
   Tcl_DString dsptr;
   if(argc<3) {
      sprintf(s,"Usage: %s path htm", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(htm,argv[2]);
	  /*Inits*/
	  for (k_hist=0;k_hist<20;k_hist++) {
          histo[k_hist]=0;
	  }
      /* --- Compte le nombre de mesure ---*/
      sprintf(filename,"%s%s_mes.bin",path,htm);
      f=fopen(filename,"rb");
      if (f==NULL) {
         sprintf(s,"filename %s not found",filename);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  B_mes=0;
	  C_mes=0;
	  I_mes=0;
	  R_mes=0;
	  V_mes=0;
	  indice0 = 0;
	  while (feof(f)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f)>1) {
			mag    = htmmes.magcali;
			if (mag>-50.) {
				filtre = htmmes.codefiltre;
                indice  = htmmes.indexref;
				if (indice==indice0) {				
					switch (filtre) {
						case 66 : B_mes++;break;
						case 67 : C_mes++;break;
						case 73 : I_mes++;break;
						case 82 : R_mes++;break;
						case 86 : V_mes++;break;
					}
				}else {
					if ((B_mes>0)&&(B_mes<=10)) {
						histo[0]++;
					} else if ((B_mes>10)&&(B_mes<=50)){
						histo[1]++;
					} else if ((B_mes>50)&&(B_mes<=100)){
						histo[2]++;
					} else if (B_mes>100){
						histo[3]++;
					}
					if ((C_mes>0)&&(C_mes<=10)) {
						histo[4]++;
					} else if ((C_mes>10)&&(C_mes<=50)){
						histo[5]++;
					} else if ((C_mes>50)&&(C_mes<=100)){
						histo[6]++;
					} else if (C_mes>100){
						histo[7]++;
					}
					if ((I_mes>0)&&(I_mes<=10)) {
						histo[8]++;
					} else if ((I_mes>10)&&(I_mes<=50)){
						histo[9]++;
					} else if ((I_mes>50)&&(I_mes<=100)){
						histo[10]++;
					} else if (I_mes>100){
						histo[11]++;
					}
					if ((R_mes>0)&&(R_mes<=10)) {
						histo[12]++;
					} else if ((R_mes>10)&&(R_mes<=50)){
						histo[13]++;
					} else if ((R_mes>50)&&(R_mes<=100)){
						histo[14]++;
					} else if (R_mes>100){
						histo[15]++;
					}
					if ((V_mes>0)&&(V_mes<=10)) {
						histo[16]++;
					} else if ((V_mes>10)&&(V_mes<=50)){
						histo[17]++;
					} else if ((V_mes>50)&&(V_mes<=100)){
						histo[18]++;
					} else if (V_mes>100){
						histo[19]++;
					}
					B_mes=1;
					C_mes=1;
					I_mes=1;
					R_mes=1;
					V_mes=1;
					indice0=indice;
				}				
			}
		 }
	  }
      fclose(f);
	  /*Sortie*/ 
	  Tcl_DStringInit(&dsptr);

	  for (k_hist=0;k_hist<20;k_hist++) {
          sprintf(s,"%6d",histo[k_hist]);
		  Tcl_DStringAppend(&dsptr,s,-1);
	  }	  
	  Tcl_DStringResult(interp,&dsptr);
	  Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}