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

int Cmd_mltcl_geostatident(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Identification des satellites en comparant les coordonnees               */
/****************************************************************************/
/****************************************************************************/
/* pour tester dans Audace:*/
/* ml_geostatident "C:/Program Files/Apache Group/Apache2/htdocs/ros/geostat/bdd0_20060927.txt" 
"C:/Program Files/Apache Group/Apache2/htdocs/ros/geostat/bdd_20060927.txt" */
{
	int result,retour,diffjour,n_in,n_in1,kimage,nimages,kimage2,nimages2,k,k1,k2,k3,date,temp,nsat;
	int kmin,kmini,problemetelechargement,pareil;
	int code;
	double distmin,ra0,dec0, ra,dec,dist,angl,anglmin;
	char s[1000],ligne[1000],home[35],im[40],lign[1000],toto[1000],valid[4]; 
	char satelname[26],noradname[10],cosparname[10];
	FILETIME ftCreate, ftAccess, ftWrite; 
	SYSTEMTIME stUTC, stCreateLocal,stWriteLocal;
	FILE *f_in1, *f_in2;
	char lpszCreate[20]; 
	char lpszWrite[20]; 
	char tempspc[20]; 
	SYSTEMTIME St;
	HANDLE hFile ;
	struct_ligsat *lignes,*lignes2;
	char *list, *distang;
	Tcl_Obj *list2, *list3;
	int argcc,argc2;
	char **argvv,**argv2;
	
	
	if(argc<2) {
      sprintf(s,"Usage: %s file_0 file_ident ?path_geo? ?path_http? ?url?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	}  else {
		/* --- decode les parametres obligatoires ---*/

		/* --- decode les parametres facultatifs ---*/
		 /* default: path= "C:\audela\audela\ros\src\grenouille" */
		if(argc == 2) {
			argv[3] = "c:/audela/audela/ros/src/grenouille/geo.txt";
			argv[4] = "c:/Program Files/Apache Group/Apache2/htdocs/ros/tle.txt";
			argv[5] = "celestrak.com/NORAD/elements/geo.txt";
		} 
		if(argc == 3) {
			argv[4] = "c:/Program Files/Apache Group/Apache2/htdocs/ros/tle.txt";
			argv[5] = "celestrak.com/NORAD/elements/geo.txt";
		} 
		if(argc == 4) {
			argv[5] = "celestrak.com/NORAD/elements/geo.txt";
		} 
		problemetelechargement=0;
		/* récupère la date et heure des modifs du fichier */
		hFile = CreateFile(argv[3],0,FILE_SHARE_READ | FILE_SHARE_WRITE,NULL,OPEN_EXISTING,0,NULL); 
		retour = GetFileTime(hFile, &ftCreate, &ftAccess, &ftWrite);
		
		/* Converti le temps de creation en temps local */
		FileTimeToSystemTime(&ftCreate, &stUTC); 
		SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stCreateLocal);  
  
		/* Converti le temps dern.modif en temps local. */
		FileTimeToSystemTime(&ftWrite, &stUTC); 
		SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stWriteLocal); 
			
		wsprintf(lpszCreate, TEXT("%02d/%02d/%d %02d:%02d"), 
		stCreateLocal.wMonth, stCreateLocal.wDay, stCreateLocal.wYear, 
        stCreateLocal.wHour, stCreateLocal.wMinute); 
  
		wsprintf(lpszWrite, TEXT("%02d/%02d/%d %02d:%02d"), 
        stWriteLocal.wMonth, stWriteLocal.wDay, stWriteLocal.wYear, 
        stWriteLocal.wHour, stWriteLocal.wMinute); 

		GetLocalTime(&St);
		wsprintf(tempspc, TEXT("%02d/%02d/%d %02d:%02d"), 
		St.wMonth, St.wDay, St.wYear, 
        St.wHour, St.wMinute); 
			
		/* --- vérifie si le fichier est vieux d'un jour, si oui il y a un pb lors du telechargement --- */
		diffjour = ml_differencejour(stWriteLocal.wDay,stWriteLocal.wMonth,stWriteLocal.wYear,St.wDay,St.wMonth,St.wYear);
		if ( diffjour>1 ){
			problemetelechargement = 1;
		}

		/* --- on fabrique un fichier_tle2=geo2.txt derriere lequel on ajoute les TLE personels --- */
		ml_file_copy ("c:/audela/audela/ros/src/grenouille/geo.txt","c:/audela/audela/ros/src/grenouille/tle2.txt");

		f_in1=fopen(argv[4],"r");
		if (f_in1==NULL) {
			sprintf(s,"file %s not found, pas de fichier tle",argv[4]);		
		} else {
			n_in1=0;
			while (feof(f_in1)==0) {
				if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					n_in1++;
				}
			}
			fclose(f_in1);
			if (n_in1!=0) {	
				f_in2=fopen("c:/audela/audela/ros/src/grenouille/tle2.txt","a+");
				if (f_in2==NULL) {
					sprintf(s,"file %s not found",f_in2);					
				}
				n_in=0;
				while (feof(f_in2)==0) {
					if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
						n_in++;
					}
				}
				/* --- dimensionne la structure des donnees d'entree ---*/
				lignes=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
				if (lignes==NULL) {
					sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_ERROR;
				}
				f_in1=fopen(argv[4],"r");
				if (f_in1==NULL) {
					sprintf(s,"file %s not found, pas de fichier tle",argv[4]);
					Tcl_SetResult(interp,s,TCL_VOLATILE);			
				}  
				n_in1=0;
				while (feof(f_in1)==0) {
					if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
						strcpy(lignes[n_in1].texte,ligne);					
						fprintf(f_in2,"%s",lignes[n_in1].texte);				
						n_in1++;
					}
				}
				fclose(f_in1);
				fclose(f_in2);
				free(lignes);
			}
		}	
		/* est-ce que le fichier bdd exist?*/
		f_in1=fopen(argv[2],"r");
		if (f_in1==NULL) {	
			f_in2=fopen(argv[1],"r");
			if (f_in2==NULL) {
				sprintf(s,"FILE: %s DOESN'T EXIST", argv[1]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				result = TCL_ERROR;
			} else {
			retour = ml_file_copy (argv[1],argv[2]);
			fclose(f_in2);
			}
		} else {
			/* comme on ne recopie pas le fichier, on va chercher les lignes différentes pour compléter le fichier de sortie */
			fclose(f_in1);
			/* --- dimensionne la structure des donnees d'entree ---*/
			n_in=0;
			/* pour le fichier bdd0 */
			f_in1=fopen(argv[1],"rt");
			if (f_in1==NULL) {
				sprintf(s,"file_00 %s not found",argv[1]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			while (feof(f_in1)==0) {
				if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					n_in++;
				}
			}							
			lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
			if (lignes==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			
			fclose(f_in1);
			n_in1=0;
			/* pour le fichier bdd */
			f_in2=fopen(argv[2],"rt");
			if (f_in2==NULL) {
				sprintf(s,"file_00 %s not found",argv[1]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			while (feof(f_in2)==0) {
				if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
					n_in1++;
				}
			}	
			lignes2=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
			if (lignes2==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			fclose(f_in2);

			n_in=0;
			date=0;
			kimage=0;
			k=0;
			f_in1=fopen(argv[1],"rt");
			if (f_in1==NULL) {
				sprintf(s,"file_00 %s not found",argv[1]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* on cherche quand il y a une ligne blanche, correspond a un changement de date */
			while (feof(f_in1)==0) {
				 if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					strcpy(lignes[n_in].texte,ligne);
					if (strlen(ligne)>=3) {
						if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
							lignes[n_in].comment=0;
						}
						kimage++;
						if (date == 0) {
							lignes[n_in].nouvelledate=1;
						} else {
							lignes[n_in].nouvelledate=date;
						}
					
					} else {						
						if (n_in <= 2) {
							date=0;
							lignes[n_in].nouvelledate=1;
						} else {	
							k++;
							date=k+1;
							lignes[n_in].nouvelledate=k;
						}
					}
				}	 
				n_in++;
			}
			fclose(f_in1);
			nimages=kimage-2;
			n_in=n_in-1;
		
			kimage2=0;
			k=0;
			n_in1=0;
			f_in2=fopen(argv[2],"rt");
			if (f_in2==NULL) {
				sprintf(s,"file_00 %s not found",argv[1]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			while (feof(f_in2)==0) {
				 if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
					strcpy(lignes2[n_in1].texte,ligne);
					if (strlen(ligne)>=3) {
						if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
							lignes2[n_in1].comment=0;
						}
						kimage2++;
					}	
				 }
				 n_in1++;
			}
			fclose(f_in2);
			nimages2=kimage2-2;	
			n_in1=n_in1-1;
			/* --- on cherche les lignes qui manquent dans le fichier de sortie --- */	
			/*tester*/
			for (k=0;k<n_in;k++) {
				if (lignes[k].comment!=0) {
					lignes[k].kimage1 = 0;
					continue;
				}
				for (k2=0;k2<n_in1;k2++) {
					if (lignes2[k2].comment!=0) {
						continue;
					}
					if (lignes2[k2].kimage1 == 0) {
						continue;
					}
					pareil=0;
					for (k1=0; k1<140;k1++) {
						if (lignes2[k2].texte [k1] == lignes[k].texte [k1]) {
							pareil++;
						} else {
							break;
						}
						if (pareil>=120) {
							lignes[k].kimage1 = 0;
							lignes2[k2].kimage1 = 0;
							break;		
						}
					}
					if (lignes[k].kimage1 == 0) {
					break;
					}
				}
			}
			/* --- on sauve le resultat dans le fichier de sortie ---*/
			f_in1=fopen(argv[2],"a+");
			if (f_in1==NULL) {
				sprintf(s,"file_0 %s not created",argv[1]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);	
				return TCL_ERROR;
			}
			temp=0;	
			for (k=0;k<n_in;k++) {
				if (lignes[k].kimage1 != 0) {	
					/* on a une nouvelle ligne*/
					/*il faut copier lignes[k1].ligne dans lignes[nimages2+1]*/	
					if (temp == 0) {
						fprintf(f_in1,"\n%s",lignes[k].texte);
					} else {
						
						if ((lignes[k].nouvelledate != lignes[temp].nouvelledate)&&(temp!=0)) {
							fprintf(f_in1,"\n%s",lignes[k].texte);
						} else {
							fprintf(f_in1,"%s",lignes[k].texte);
						}
					}
					temp=k;
				}
			}				
			fclose(f_in1);
			free(lignes); 
			free(lignes2);
		}
		
		f_in2=fopen(argv[2],"rt");
		if (f_in2==NULL) {
			sprintf(s,"file_0 %s not found",argv[2]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		n_in1=0;
		while (feof(f_in2)==0) {
			if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
				n_in1++;
			}
		}
		fclose(f_in2);
		/* --- on recupère les données du fichier de sortie ---*/
		lignes2=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
		if (lignes2==NULL) {
			sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		lignes=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
		if (lignes==NULL) {
			sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		n_in1=0;
		kimage2=0;
		nsat=0;
		strcpy(s,"");
		f_in1=fopen(argv[2],"rt");
		if (f_in1==NULL) {
			sprintf(s,"file_0 %s not found",argv[2]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}

		while (feof(f_in1)==0) {
			if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
				if (n_in1==0) {
					strcpy(lignes2[n_in1].texte,ligne);
					for (k=90;k<130;k++){
						/* on recupère les coordonnées GPS du lieu*/
						if ((ligne[k]=='G')&&(ligne[k+1]=='P')&&(ligne[k+2]=='S')) {
							for (k2=k+4;k2<145;k2++){
								if (ligne[k2]== ')') {
									for (k3=k;k3<k2;k3++) { s[k3-k]=ligne[k3]; } ; s[k3-k]='\0';							
									strcpy(home,s);
									break;
								}
							}
							break;
						}
					}
				}
				if (n_in1==1){
					strcpy(lignes2[n_in1].texte,ligne);
				}
				if (strlen(ligne)>=3) {
					if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
						lignes2[n_in1].comment=1;
						kimage2++;
					} 	
				}
				if (lignes2[n_in1].comment==1) {
					k1=146 ; k2=156 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes2[n_in1].ident,s);	
					result= strlen(lignes2[n_in1].ident);
					retour = strncmp(lignes2[n_in1].ident,"            \0",7);	
					if ((retour==0) || (result<=3)) {
						/* --- le satellite n'est pas identifiée --- */
						k1=0; k2=144; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(lignes2[n_in1].texte,s);
						k1=38; k2=60; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(im,s);
						k1=104; k2=113; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						lignes2[n_in1].dec=atof(s);
						k1=93 ; k2=101; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						lignes2[n_in1].ra=atof(s);
						/* transforme le fichier de tle en ephemeride */
						strcpy(toto,"c:/audela/audela/ros/src/grenouille/tle2.txt");						
						sprintf(lign,"mc_tle2ephem {%s} %s {%s}",im,toto,home);
						result = Tcl_Eval(interp,lign);
						
						if (result==TCL_OK) {
							list=NULL;		
							list2 = Tcl_GetObjResult  (interp);
							list = Tcl_GetString (list2);
							code = Tcl_SplitList(interp,list,&argcc,&argvv);
							if (code != TCL_OK) {
									sprintf(ligne, "Probleme sur le liste des ephemerides");
									Tcl_SetResult(interp, ligne, TCL_VOLATILE);
									return TCL_ERROR;
							}		
							kmin=0;
							kmini=-1;
							distmin=1e20;
							anglmin=0;
							ra0=lignes2[n_in1].ra;
							dec0=lignes2[n_in1].dec;
							for (k=0;k<argcc;k++) {
								k1=63 ; k2=81 ; for (k3=k1;k3<=k2;k3++) { s[k3-k1]=argvv[k][k3]; } ; s[k3-k1]='\0';
								ra=atof(s);
								k1= 83 ; k2= 101 ; for (k3=k1;k3<=k2;k3++) { s[k3-k1]=argvv[k][k3]; } ; s[k3-k1]='\0';
								dec=atof(s);
								/* calcul la distance et angle entre les deux coordonnées */
								sprintf(lign,"mc_anglesep {%14.12f %14.12f %14.12f %14.12f}",ra0,dec0,ra,dec);
								result = Tcl_Eval(interp,lign);
						
								if (result==TCL_OK) {
									list3 = Tcl_GetObjResult  (interp);
									distang = Tcl_GetString (list3);
									code = Tcl_SplitList(interp,distang,&argc2,&argv2);
								}		
								k1= 0 ; k2= 12 ; for (k3=k1;k3<=k2;k3++) { s[k3-k1]=distang[k3]; } ; s[k3-k1]='\0';
								dist=atof(s);
								k1= 14 ; k2= 28 ; for (k3=k1;k3<=k2;k3++) { s[k3-k1]=distang[k3]; } ; s[k3-k1]='\0';
								angl=atof(s);
								if (dist <= distmin) {
									distmin = dist;
									kmini=kmin;
									anglmin=angl;
								}	
								kmin++;
							}
							if (distmin<=0.3) {
								strcpy(valid," 1 ");
							} else {
								strcpy(valid," 0 ");
							}
							if (kmini>=0) {
								/* il faut rajouter à ligne2[].texte satelname,noradname et cosparname*/
								for (k=2;k<30;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<30;k1++){
									if (argvv[kmini][k1]== '}') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';							
										strcpy(satelname,s);
										break;
									}
								}
								for (k=k1+3;k<55;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<60;k1++){
									if (argvv[kmini][k1]== '}') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';							
										strcpy(noradname,s);
										break;
									}
								}
								for (k=k1+3;k<75;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<80;k1++){
									if (argvv[kmini][k1]== ' ') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';							
										strcpy(cosparname,s);
										break;
									}
								}
								k=strlen(satelname);
								k1=24-k;
								strcat(lignes2[n_in1].texte,valid);	
								strcat(lignes2[n_in1].texte,satelname);
						
								for (k2=0;k2<k1;k2++) {
									strcat(lignes2[n_in1].texte," ");
								}
							
								k=strlen(noradname);
								k1=9-k;
								
								if (k1>0) {
									for (k2=0;k2<=k1;k2++) {
										strcat(noradname," ");
									}
								}
								strcpy(lignes2[n_in1].ident,"");
								strcat(lignes2[n_in1].ident,noradname);
								k=strlen(cosparname);
								strcat(lignes2[n_in1].ident,cosparname);
								lignes2[n_in1].distance = distmin;
								lignes2[n_in1].angle = anglmin;
								
							} else {
									/* on rajoute rien à  ligne[].texte*/
							}
						} else {							
							sprintf(ligne, "Probleme avec les tle");
							Tcl_SetResult(interp, ligne, TCL_VOLATILE);
							result = TCL_ERROR;							
						}
					} else {
						/* --- le satellite est deja identifiée --- */
						strcpy(lignes2[n_in1].texte,ligne);
						lignes2[n_in1].kobject=0;
						nsat++;
					}	
				} else {
					strcpy(lignes2[n_in1].texte,ligne);
				}
				n_in1++;
			}
			
		}
		fclose(f_in1);
		/* si on en a qui sont pas identifiés */
		if (kimage2 != nsat) {
			/* delete file argv[2] puis reouvre le même*/
			if (remove(argv[2]))  {
				const char * const msg = strerror(errno); // MSG contient le message d'erreur
			}
			/* on recopie l'identification des satellites dans le fichier bdd */
			f_in1=fopen(argv[2],"w+");
			if (f_in1==NULL) {
				sprintf(s,"file_0 %s not created",argv[2]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);	
				return TCL_ERROR;
			}
			fprintf(f_in1,"%s",lignes2[0].texte);
			fprintf(f_in1,"%s",lignes2[1].texte);
			fprintf(f_in1,"%s",lignes2[2].texte);	
			for (k=3;k<n_in1;k++) {
				if (lignes2[k].comment==1){
					if (lignes2[k].kobject!=0) {
						fprintf(f_in1,"%s %09.5f %07.3f %s\n",lignes2[k].texte,lignes2[k].distance,lignes2[k].angle,lignes2[k].ident);	
					} else {
						fprintf(f_in1,"%s",lignes2[k].texte);
					}
				} else {
					fprintf(f_in1,"\n");
				}
			}
			fclose(f_in1);
		}
		free(lignes2);
		free(lignes);
		result = TCL_OK;
	}
	
	return result;
}


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



//***************************************************************************
//
// InterruptsCallback
//
//***************************************************************************

TT_STATUS InterruptsCallback (TT_EVENT eEventType,FILETIME* pFileTime,DWORD mot,PVOID pContext)
 
{
	SYSTEMTIME_EX	SystemTime;
	char s[100];

	/// Convert the FileTime to SystemTimeEx format
	if (TT_FileTimeToSystemTimeEx(pFileTime, &SystemTime) != TT_SUCCESS)
	{
		sprintf(s,"Error converting time from file time to system time!\n");
		return TT_SUCCESS;	  
	}

	switch(eEventType)
	{
		case TT_EVENT_EXTERNAL:
			printf("\nINTERRUPT: External Event. ");
			break;

		case TT_EVENT_PERIODIC:
			printf("\nINTERRUPT: One Pulse Per Second Periodic. ");
			break;

		case TT_EVENT_TIME_COMPARE:
			printf("\nINTERRUPT: Time Compare. ");
			break;

		case TT_EVENT_SYNTHESIZER:
			printf("\nINTERRUPT: Synthesizer. ");
			break;
    default:
		sprintf(s,"\nUNKNOWN Interrupt!!! ");
		return TT_SUCCESS;
	}
		
	
	printf("\nTime: %d/%02d/%02d %02d:%02d:%02d.%03d%03d", 
            SystemTime.wYear, SystemTime.wMonth, SystemTime.wDay, 
            SystemTime.wHour, SystemTime.wMinute, SystemTime.wSecond, 
            SystemTime.wMilliseconds, SystemTime.wMicroseconds);
			

	return TT_SUCCESS;
}

//***************************************************************************
//
// fonction qui attend l'evenement exterieur
//
//***************************************************************************
double Cmd_mltcl_savedategps(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
	char s[100];
	int Model,result,dateok;
	unsigned long dwBus,dwSlot;
	double sec,min,heu;
	double secm6,secm4, secm2;
	double secm6h,secm4h, secm2h;
	double sech,minh,heuh,date=0;
#if defined(OS_WIN)
	HANDLE hDevice;
	ULONG ulRegisterAddress;
	UCHAR ucRegisterValue;
	TT_POSITION		Position;
	TT_GPS_SIGNALS	GpsSignals;
	TT_ANTENNA		Antenna;

	/// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) != TT_SUCCESS)
	{
		sprintf(s,"Error Opening Device Driver!\n");
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		return -1;
	}
	if (TT_GetDeviceInfo(hDevice, &Model, &dwBus, &dwSlot) != TT_SUCCESS)	
	{
		sprintf(s,"Error getting card info!\n");
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		TT_CloseDevice(hDevice);
		return -1;

	} else {
		sprintf(s,"PCI %x Stress Test @ Bus: %d @ Slot: %d \n ", Model, dwBus, dwSlot);
		Tcl_SetResult(interp, s, TCL_VOLATILE);
	}
	
	/// Register Callback for interrupts
	if (TT_RegisterCallback(hDevice, InterruptsCallback, NULL) != TT_SUCCESS)
	{
		sprintf(s,"Error: failed registering callbacks!\n");
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		TT_CloseDevice(hDevice);
		return -1;
	}
	
	if (TT_ReadGpsInfo(hDevice, &Position, &GpsSignals, &Antenna) == TT_SUCCESS)
		/* si on a de l'info des satellites */
	{
		if (TT_SetExternalEvent(hDevice, TRUE) != TT_SUCCESS)
		{	
			sprintf(s,"Error: ne peut pas recevoir d'evenement exterieur!\n");
			Tcl_SetResult(interp, s, TCL_VOLATILE);
			TT_CloseDevice(hDevice);
			return -1;
		} else {
	
			Sleep (2000); /*attend pdt 2 sec un evenement exterieur*/

			TT_SetExternalEvent(hDevice, FALSE);
			ulRegisterAddress = strtol("0x174",0,16);	
			dateok=0;
			result = TT_GetRegister(hDevice,ulRegisterAddress,&ucRegisterValue);
			if (result == TT_SUCCESS) {	
				printf(" %x 10-6 sec \n",ucRegisterValue);
				secm6=ucRegisterValue;					
			} else {
				dateok=1;
			}
			result = TT_GetRegister(hDevice,ulRegisterAddress + 1,&ucRegisterValue);
			if (result == TT_SUCCESS) {	
				printf(" %x 10-4 sec \n",ucRegisterValue);
				secm4=ucRegisterValue;	//secm devient en decimal alors qu'on veut les deux chiffres de l'hexa			
			} else {
				dateok=1;
			}	
			result = TT_GetRegister(hDevice,ulRegisterAddress + 2,&ucRegisterValue);
			if (result == TT_SUCCESS) {	
				printf(" %x 10-2 sec \n",ucRegisterValue);
				secm2=ucRegisterValue;				
			} else {
				dateok=1;;
			}
			result = TT_GetRegister(hDevice,ulRegisterAddress + 3,&ucRegisterValue);
			if (result == TT_SUCCESS) {	
				printf(" %x sec \n",ucRegisterValue);
				sec=ucRegisterValue;				
			} else {
				dateok=1;
			}
			result = TT_GetRegister(hDevice,ulRegisterAddress + 4,&ucRegisterValue);
			if (result == TT_SUCCESS) {	
				printf(" %x min \n",ucRegisterValue);
				min=ucRegisterValue;				
			} else {
				dateok=1;
			}
			result = TT_GetRegister(hDevice,ulRegisterAddress + 5,&ucRegisterValue);
			if (result == TT_SUCCESS) {	
				printf(" %x heure \n",ucRegisterValue);
				heu=ucRegisterValue;				
			} else {
				dateok=1;
			}

			if (dateok==1){
				return -1;
			}
		
			//la il faut trouver une fonction qui convertise secm6,secm4.... de double decimal à double hexa
			secm6h=ml_conversiondecTohexa(secm6);
			secm4h=ml_conversiondecTohexa(secm4);
			secm2h=ml_conversiondecTohexa(secm2);
			sech=ml_conversiondecTohexa(sec);
			minh=ml_conversiondecTohexa(min);
			heuh=ml_conversiondecTohexa(heu);
			secm6h=secm6h*0.000001;
			secm4h=secm4h*0.0001;
			secm2h=secm2h*0.01;
			minh=minh*60;
			heuh=heuh*60*60;
		
			date=heuh+minh+sech+secm6h+secm4h+secm2h; /*l'heure en seconde à comparer avec celle de date_obs,
													  si trop différentes  (>3 secondes) ne pas en tenir compte!!
														si la fonction ml_savevent retourne -1, c'est qu'il y a un pb avec la carte*/
		}

		/// De-Register the interrupts callbak
		TT_RegisterCallback(hDevice, NULL, NULL);

		/// close device
		TT_CloseDevice(hDevice);


	} else {
		/* pas d'info GPS */
		TT_CloseDevice(hDevice);
		return -1;
	}
#endif
return date;
}

