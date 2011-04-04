/* tt_util1.c
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

/* ======================================================================== */
/* ==================== declaration variables globales ==================== */
/* ======================================================================== */

char nom_fichier_log[]="tt.log";
char nom_fichier_err[]="tt.err";
char nom_fichier_last_err[]="tt_last.err";

int tt_errmessage(void *args)
/**************************************************************************/
/* Fonction qui renvoie un message d'erreur en clair                      */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *numero (int*)                                                  */
/* ------ sorties                                                         */
/* arg2 : *message (char*)                                                */
/**************************************************************************/
{
   void **argu;
   int numerreur;
   char message[TT_MAXLIGNE];
   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   numerreur=*(int*)(argu[1]);
   strcpy(message,"");
   if (argu[2]==NULL) { return(PB_DLL); }
   tt_errmessage2(numerreur,message);
   strcpy(argu[2],message);
   return(OK_DLL);
}

int tt_errmessage2(int numerreur,char *message)
/**************************************************************************/
/* Fonction qui renvoie un message d'erreur en clair                      */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *numero (int*)                                                  */
/* ------ sorties                                                         */
/* arg2 : *message (char*)                                                */
/**************************************************************************/
{
   char err_fitsio[TT_MAXLIGNE];
   /* --- verification des arguments ---*/
   if (message==NULL) { return(PB_DLL); }
   strcpy(message,"");
   if (numerreur==TT_ERR_SERVICE_NOT_FOUND) {strcat(message,"Service not found");}
   else if (numerreur==TT_ERR_PB_MALLOC) {strcat(message,"Allocation memory error");}
   else if (numerreur==TT_ERR_HDUNUM_OVER) {strcat(message,"Numhdu over limits");}
   else if (numerreur==TT_ERR_REMOVE_FILE) {strcat(message,"File is read only");}   
   else if (numerreur==TT_ERR_HDU_NOT_IMAGE) {strcat(message,"Selected hdu is not an IMAGE");}
   else if (numerreur==TT_ERR_PTR_ALREADY_ALLOC) {strcat(message,"Pointer already allocated");}
   else if (numerreur==TT_ERR_FILENAME_TOO_LONG) {strcat(message,"Filename too long");}
   else if (numerreur==TT_ERR_NOT_ENOUGH_ARGUS) {strcat(message,"Not enough arguments");}
   else if (numerreur==TT_ERR_NOT_ALLOWED_FILENAME) {strcat(message,"File name not allowed");}
   else if (numerreur==TT_ERR_DECREASED_INDEXES) {strcat(message,"Indexes decrease");}
   else if (numerreur==TT_ERR_IMAGES_NOT_SAME_SIZE) {strcat(message,"Images have not the same size");}
   else if (numerreur==TT_ERR_FCT_IS_NOT_AS_SERVICE) {strcat(message,"Function name is not the same as the service number");}
   else if (numerreur==TT_ERR_FCT_NOT_FOUND_IN_IMASTACK) {strcat(message,"Function not found in IMA/STACK");}
   else if (numerreur==TT_ERR_FILE_NOT_FOUND) {strcat(message,"File not found");}
   else if (numerreur==TT_ERR_OBJEFILE_NOT_FOUND) {strcat(message,"Objefile not found");}
   else if (numerreur==TT_ERR_PIXEFILE_NOT_FOUND) {strcat(message,"Pixefile not found");}
   else if (numerreur==TT_ERR_CATAFILE_NOT_FOUND) {strcat(message,"Catafile not found");}
   else if (numerreur==TT_ERR_ALLOC_NUMBER_ZERO) {strcat(message,"Want to allocate with <=0 element");}
   else if (numerreur==TT_ERR_ALLOC_SIZE_ZERO) {strcat(message,"Want to allocate with a size <=0");}
   else if (numerreur==TT_ERR_FILE_CANNOT_BE_WRITED) {strcat(message,"Cannot write on disk (full ?)");}
   else if (numerreur==TT_ERR_TBLDATATYPES) {strcat(message,"Table datatype not valid (float double int short or number for len of char)");}
   else if (numerreur==TT_ERR_NULL_EIGENVALUE) {strcat(message,"Matrix inversion impossible because an eigenvalue is null");}
   else if (numerreur==TT_ERR_MATCHING_MATCH_TRIANG) {strcat(message,"Focas problem when match triangles");}
   else if (numerreur==TT_ERR_MATCHING_CALCUL_TRIANG) {strcat(message,"Focas problem when compute triangles");}
   else if (numerreur==TT_ERR_MATCHING_CALCUL_DIST) {strcat(message,"Focas problem when compute distances");}
   else if (numerreur==TT_ERR_MATCHING_BEST_CORRESP) {strcat(message,"Focas problem when compute best pairs");}
   else if (numerreur==TT_ERR_MATCHING_REGISTER) {strcat(message,"Focas problem during registration");}
   else if (numerreur==TT_ERR_PARAMRESAMPLE_NUMBER) {strcat(message,"Resampling number of parameters is not correct");}
   else if (numerreur==TT_ERR_PARAMRESAMPLE_IRREGULAR) {strcat(message,"Resampling parameters are irregular");}
   else if (numerreur==TT_ERR_MATCHING_NULL_DISTANCES) {strcat(message,"Same star was found two times in the list");}
   else if (numerreur==TT_ERR_NAXIS12_NULL) {strcat(message,"One of axes has zero elements");}
   else if (numerreur==TT_ERR_NAXIS_NULL) {strcat(message,"NAXIS keyword not defined or equal to zero");}
   else if (numerreur==TT_ERR_NAXISN_NULL) {strcat(message,"At less NAXIS* keyword is not defined or equal to zero");}
   else if (numerreur==TT_ERR_BITPIX_NULL) {strcat(message,"BITPIX keyword not defined or a valid value");}
   else if (numerreur==TT_WAR_ALLOC_NOTNULLPTR) {strcat(message,"Want to allocate a not null pointer");}
   else if (numerreur==TT_WAR_FREE_NULLPTR) {strcat(message,"Want to free a null pointer");}
   else if (numerreur==TT_WAR_INDEX_OUTMAX) {strcat(message,"Index out of high limit");}
   else if (numerreur==TT_WAR_INDEX_OUTMIN) {strcat(message,"Index out of low limit");}
   else if ((numerreur>=101)&&(numerreur<=999)) {
      libfiles_main(FS_FITS_GET_ERRSTATUS,2,&numerreur,err_fitsio);
      strcat(message,err_fitsio);
   }
   else {sprintf(message,"Internal error (%d)",numerreur);}
   return(OK_DLL);
}

int tt_errlog(int numerreur,char *messageFormat,...)
/**************************************************************************/
/* Ecrit le fichier tt.err qui contient l'erreur trouve au cours de l'exec*/
/**************************************************************************/
{
   FILE *fichier_log,*fichier_err,*fichier_lasterr;
   int long_fic,kk,sortie,milieu;
   int long_mes=TT_MAXLIGNE;
   char car;
   char message_log[TT_MAXLIGNE];
   char message[TT_MAXLIGNE];
   char commande[TT_MAXLIGNE];
   char mode[5];
   time_t ltime;
   va_list mkr;
   
   // je formate le message 
   if ( messageFormat != NULL) {
      va_start(mkr, messageFormat);
      vsprintf(commande, messageFormat, mkr);
	   va_end (mkr);
   } else {
      strcpy(commande,"");
   }

   if ((fichier_err=fopen(nom_fichier_err, "r") ) == NULL) {
      strcpy(mode,"w");
   } else {
      strcpy(mode,"a");
      fclose(fichier_err);
   }
   if ((fichier_err=fopen(nom_fichier_err,mode) ) == NULL) {
      return(PB_DLL);
   }
	if ((fichier_lasterr=fopen(nom_fichier_last_err, "w") ) == NULL) {
      return(PB_DLL);
	}
   strcpy(message,"");
   if ((fichier_log=fopen(nom_fichier_log, "r") ) != NULL) {
      /* --- premiere ligne ---*/
      fseek(fichier_log,0,SEEK_END);
      fseek(fichier_log,ENDFILE_JUMP,SEEK_CUR);
      kk=0;
      do {
	 if (kk<long_mes) {
	    message_log[kk]=(char)fgetc(fichier_log);
	 }
	 fseek(fichier_log,-2,SEEK_CUR);
	 if (kk>=long_mes) sortie=TT_YES; else sortie=TT_NO;
	 if (message_log[kk]=='\n') {
	 sortie=TT_NO;
	 message_log[kk]='\0';
	 } else {
	 sortie=TT_YES;
	 }
	 kk++;
      } while (sortie==TT_YES);
      fclose(fichier_log);
      long_fic=strlen(message_log);
      strcpy(message,"");
      if (long_fic>0) {
	 milieu=(int)(floor(0.5*(double)long_fic)-1);
	 for (kk=0;kk<=milieu;kk++) {
	 car=message_log[kk];
	 message_log[kk]=message_log[long_fic-kk-1];
	 message_log[long_fic-kk-1]=car;
	 }
	 strcpy(message,message_log);
      }
      strcat(message,"\n");
   } else {
      time( &ltime );
      strftime(message,TT_MAXLIGNE,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
      if (numerreur>-1000) {
	 strcat(message," : Error detected in tt.\n");
      } else {
	 strcat(message," : Warning detected in tt.\n");
      }
   }
   fwrite(message,strlen(message),1,fichier_err);
	fwrite(message,strlen(message),1,fichier_lasterr);
   /* --- deuxieme ligne ---*/
   strcpy(message,"");
   tt_errmessage2(numerreur,message);
   strcat(message,"\n");
   fwrite(message,strlen(message),1,fichier_err);
	fwrite(message,strlen(message),1,fichier_lasterr);
   /* --- troisieme ligne ---*/
   strcpy(message,"");
   if (commande!=NULL) {
      strcpy(message,commande);
   }
   strcat(message,"\n");
	/* --- ici on ecrit le message d'erreur dans tt.err ---*/
   fwrite(message,strlen(message),1,fichier_err);
   fclose(fichier_err);
	/* --- ici on ecrit le message d'erreur dans tt_last.err ---*/
	fwrite(message,strlen(message),1,fichier_lasterr);
	fclose(fichier_lasterr);
   return(OK_DLL);
}

int tt_lasterrmessage(void *args)
/**************************************************************************/
/* Fonction qui renvoie un message d'erreur en clair                      */
/**************************************************************************/
/* ------ entrees                                                         */
/* pas d'entree                                                           */
/* ------ sorties                                                         */
/* arg1 : *message (char*)                                                */
/**************************************************************************/
{
   void **argu;
   FILE *fichier_err;
   char *message,c;
	int k=0;
   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
	message=(char*)argu[1];
   if ((fichier_err=fopen(nom_fichier_last_err, "r") ) != NULL) {
		do {
			c = fgetc (fichier_err);
			if (c!=EOF) {
				message[k++]=c;
			}
		} while (c != EOF);
		fclose(fichier_err);
	}
   message[k]='\0';
   return(OK_DLL);
}

int tt_writelog(char *message)
/**************************************************************************/
/* Ecrit un message dans le fichier de log                                */
/**************************************************************************/
{
   FILE *fichier_log;
   time_t ltime;
   //char chaine[TT_MAXLIGNE];
   //char message_log[TT_MAXLIGNE];
   char * chaine = NULL;
   char * message_log = NULL;
   int pos;
   char *car;

   chaine = malloc(TT_MAXLIGNE + strlen(message));
   if ( chaine == NULL ) {
      return(PB_DLL);
   }

   message_log = malloc(TT_MAXLIGNE + strlen(message));
   if ( message_log == NULL ) {
      free(chaine);
      return(PB_DLL);
   }

   if ((fichier_log=fopen(nom_fichier_log, "r") ) == NULL) {
      if ((fichier_log=fopen(nom_fichier_log, "w") ) == NULL) {
      free(chaine);
      free(message_log);
	 return(PB_DLL);
      }
   } else {
      fclose(fichier_log);
      if ((fichier_log=fopen(nom_fichier_log, "a") ) == NULL) {
      free(chaine);
      free(message_log);
	 return(PB_DLL);
      }
   }
   time( &ltime );
   strftime(chaine,TT_MAXLIGNE,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   strcpy(message_log,chaine);
   strcat(message_log," : ");
   strcpy(chaine,message);
   car=NULL;
   car=strstr(chaine,"\n");
   pos=0;
   if (car!=NULL) {
      pos=(int)(car-chaine);
      if (pos>0) {
	 chaine[pos]='\0';
      } else {
	 strcpy(chaine,"");
      }
   }
   strcat(message_log,chaine);
   strcat(message_log,"\n");
   fwrite(message_log,strlen(message_log),1,fichier_log);
   fclose(fichier_log);
   free(chaine);
   free(message_log);
   return(OK_DLL);
}

char *tt_indeximafilecater(char *path, char *name, int index,char *suffix)
/***************************************************************************/
/***************************************************************************/
/* Traite le cas des fichiers .mt                                          */
/***************************************************************************/
{
   static char chaine[FLEN_FILENAME];
   char slash[2], zeros[10];
   int pos_last_slash,len,k;
   int pos_last_aslash;

   len=(int)strlen(path);
   if (len!=0) {
      /* --- repere la position des derniers / \ ---*/
      pos_last_slash=-1;
      pos_last_aslash=-1;
      for (k=0;k<len;k++) {
	 if (path[k]=='\\') {pos_last_aslash=k;}
	 if (path[k]=='/') {pos_last_slash=k;}
      }
      if ((pos_last_aslash==-1)&&(pos_last_slash==-1)) {
#ifdef FILE_DOS
	 strcpy(slash,"\\");
#endif
#ifdef FILE_UNIX
	 strcpy(slash,"/");
#endif
      } else if (pos_last_aslash>pos_last_slash) {
	 strcpy(slash,"\\");
      } else {
	 strcpy(slash,"/");
      }
      if (path[len-1]==slash[0]) {
	 strcpy(slash,"");
      }
   } else {
      strcpy(slash,"");
   }
   strcpy(zeros,"");
   if (strcmp(suffix,".mt")==0) {
      if (index<0)   {index=0;}
      if (index>9999){index=9999;}
      if (index<=9)        { strcpy(zeros,"000"); }
      else if (index<=99)  { strcpy(zeros,"00"); }
      else if (index<=999) { strcpy(zeros,"0"); }
   }
   sprintf(chaine,"%s%s%s%s%d%s",path,slash,name,zeros,index,suffix);
   return(chaine);
}

/***************************************************************************/


int tt_verifargus_getFileNb(char *fileNames )
/***************************************************************************/
/* retourne le nombre de noms de fichier de la serie                       */
/* parametres :                                                            */
/*    fileNames (in) liste des noms de fichiers (separes par un espace)    */
/*      les noms contant un espace doivent etre encadres par des accolades */
/* return :                                                                */
/*    nombre de noms de fichiers  ou -1 si erreur                          */
/***************************************************************************/
{
   int levelBrace  =0;
   int posString = 0;
   int posBeginFileName = 0;
   int posEndFileName   = -1;
   int currentFileIndex = 0;
   int result = -1;


   while(fileNames[posString]!=0  && result == -1) {

      if ( levelBrace == 0) {
         // je chercher un delimiteur
         if ( fileNames[posString] == '{' ) {
            levelBrace = 1;
            // le nom du fichier commence a partir du caractere suivant
            posBeginFileName = posString + 1;
         } else if ( fileNames[posString] == '}' ) {
            // erreur parenthese fermee avant parenthese ouverte
            return -1;
         } else if ( fileNames[posString] == ' ' ) {
            if ( posString == posBeginFileName) {
               // je repousse le debut de fichier au caractere suivant
               posBeginFileName = posString +1;
            } else {
              // c'est la fin d'un nom de fichier
              // le nom du fichier se termine au caractere precedent
              posEndFileName = posString -1;
            }
         }
      } else {
         if ( fileNames[posString] == '{' ) {
            // je n'accepte pas les parantheses imbriquees
            return -1;
         } else if ( fileNames[posString] == '}' ) {
           // c'est la fin d'un nom de fichier
           // le nom du fichier se termine au caractere precedent
           posEndFileName = posString -1;
           levelBrace = 0;
         }
      }

      // je verifie si c'est le dernier caractere
      if ( fileNames[posString+1] == 0 && posEndFileName == -1 ) {
         posEndFileName = posString;
      }

      if ( posEndFileName != -1 ) {
         currentFileIndex++;
         // je cherche le fichier suivant
         posBeginFileName = posString + 1;
         posEndFileName = -1;
      }

      posString++;
   }

   return currentFileIndex;


}

//*************************************************************************
// tt_verifargus_getFileName
//
//    retourne le n'ieme nom de fichier de la serie   
//                        
// parametres :                                                            
//    fileNames (in) liste des noms de fichiers (separes par un espace)    
//      les noms contenant un espace doivent etre encadres par des accolades 
//    filIndex  (in)  numero du nom de fichier                             
//    fileName  (out)  nom du fichier correspondant a fileIndex            
// return :                                                                
//    1 si ok, ou -1 si erreur                                             
//***************************************************************************/
int tt_verifargus_getFileName(char *fileNames, int fileIndex , char* fileName)
{
   int levelBrace  =0;
   int posString = 0;
   int posBeginFileName = 0;
   int posEndFileName   = -1;
   int currentFileIndex = 0;
   int result = -1;


   while(fileNames[posString]!=0  && result == -1) {

      if ( levelBrace == 0) {
         // je chercher un delimiteur
         if ( fileNames[posString] == '{' ) {
            levelBrace = 1;
            // le nom du fichier commence a partir du caractere suivant
            posBeginFileName = posString + 1;
         } else if ( fileNames[posString] == '}' ) {
            // erreur parenthese fermee avant parenthese ouverte
            return -1;
         } else if ( fileNames[posString] == ' ' ) {
           // c'est la fin d'un nom de fichier
           // le nom du fichier se termine au caractere precedent
           posEndFileName = posString -1;
         }

      } else {
         if ( fileNames[posString] == '{' ) {
            // je n'accepte pas les parantheses imbriquees
            return -1;
         } else if ( fileNames[posString] == '}' ) {
            if ( posString == posBeginFileName) {
               // je repousse le debut de fichier au caractere suivant
               posBeginFileName = posString +1;
            } else {
              // c'est la fin d'un nom de fichier
              // le nom du fichier se termine au caractere precedent
              posEndFileName = posString -1;
            }
         }
      }

      // je verifie si c'est le dernier caractere
      if ( fileNames[posString+1] == 0 && posEndFileName == -1 ) {
         posEndFileName = posString;
      }


      if ( posEndFileName != -1 ) {
          currentFileIndex++;
         // j'ai cerne un nom de fichier
         if ( currentFileIndex==fileIndex ) {
            // c'est le bon fichier, je copie son nom dans la variable de sortie
            strncpy(fileName, &fileNames[posBeginFileName], posEndFileName-posBeginFileName+1);
            // j'ajoute le caractere de fin de chaine
            fileName[posEndFileName-posBeginFileName+1]= 0;
            result = 1;
         } else {
            // je cherche le fichier suivant
            posBeginFileName = posString + 1;
            posEndFileName = -1;
         }
      }

      posString++;
   }

   return result;


}


int tt_verifargus_2indices(char **keys,int deb,int *level_index,int *indice_deb,int *indice_fin)
/***************************************************************************/
{
   /* --- deb : nom du repertoire in ---*/
   if (strcmp(keys[deb],".")==0) {
      strcpy(keys[deb],"");
   }
   if (tt_valid_dirname(keys[deb])==TT_NO) {
      return(TT_ERR_NOT_ALLOWED_FILENAME);
   }
   /* --- deb+1 : nom du fichier in ---*/
   if (tt_valid_filename(keys[deb+1])==TT_NO) {
      return(TT_ERR_NOT_ALLOWED_FILENAME);
   }
   /* --- deb+2 : indice de debut in ---*/
   if (keys[deb+2][0]==';') {
      *level_index=2;
      if (keys[deb+2][1]=='\0') {
         *indice_deb=1;
      } else {
         *indice_deb=atoi(keys[deb+2]+(int)(1));
      }
   } else if (keys[deb+2][0]=='.') {
      *level_index=0;
   } else if (keys[deb+2][0]=='*') {
      // si keys[deb+2]=*  alors  keys[deb+1] contient une liste de noms de fichiers
      *level_index=3;
      // je verifie que l'indice de fin vaut aussi *
      if (keys[deb+3][0]!='*') {
         return(TT_ERR_DECREASED_INDEXES);
      }
      *indice_deb=1;
   } else {
      *level_index=1;
      *indice_deb=atoi(keys[deb+2]);
   }
   /* --- deb+3 : indice de fin in ---*/
   if (keys[deb+3][0]==';') {
      if ((*level_index==2)||(*level_index==1)) {
         if (keys[deb+3][1]=='\0') {
            *indice_fin=1;
         } else {
            *indice_fin=atoi(keys[deb+3]+(int)(1));
         }
      } else {
         *indice_fin=atoi(keys[deb+3]);
      }
   } else if (keys[deb+3][0]=='.') {
      if ((*level_index==1)||(*level_index==2)) {
         if (keys[deb+3][1]=='\0') {
            *indice_fin=*indice_deb;
         } else {
            *indice_fin=atoi(keys[deb+3]+(int)(1));
         }
      }
   } else if (keys[deb+3][0]=='*') {
      // l'indice a ete fixe dans l'analyse de keys[deb+2]
      *indice_fin = tt_verifargus_getFileNb(keys[deb+1]);
      if ( *indice_fin == -1 ) {
         return(TT_ERR_DECREASED_INDEXES);
      }
   } else {
      *indice_fin=atoi(keys[deb+3]);
   }


   /* --- deb+4 : extension in ---*/
   if (strcmp(keys[deb+4],".")==0) {
      strcpy(keys[deb+4],"");
   }
   if (tt_valid_filename(keys[deb+4])==TT_NO) {
      return(TT_ERR_NOT_ALLOWED_FILENAME);
   }
   /* --- verif finale sur les indices ---*/
   if (*level_index!=0) {
      if (*indice_fin<*indice_deb) {
         return(TT_ERR_DECREASED_INDEXES);
      }
   }
   return(TT_YES);
}

int tt_verifargus_1indice(char **keys,int deb,int *level_index,int *indice_deb)
/***************************************************************************/
{
   /* --- deb : nom du repertoire in ---*/
   if (strcmp(keys[deb],".")==0) {
      strcpy(keys[deb],"");
   }
   if (tt_valid_dirname(keys[deb])==TT_NO) {
      return(TT_ERR_NOT_ALLOWED_FILENAME);
   }
   /* --- deb+1 : nom du fichier in ---*/
   if (tt_valid_filename(keys[deb+1])==TT_NO) {
      return(TT_ERR_NOT_ALLOWED_FILENAME);
   }
   /* --- deb+2 : indice de debut in ---*/
   if (keys[deb+2][0]==';') {
      *level_index=2;
      if (keys[deb+2][1]=='\0') {
	 *indice_deb=1;
      } else {
	 *indice_deb=atoi(keys[deb+2]+(int)(1));
      }
   } else if (keys[deb+2][0]=='.') {
      *level_index=0;
   } else {
      *level_index=1;
      *indice_deb=atoi(keys[deb+2]);
   }
   /* --- deb+3 : extension in ---*/
   if (strcmp(keys[deb+3],".")==0) {
      strcpy(keys[deb+3],"");
   }
   if (tt_valid_filename(keys[deb+3])==TT_NO) {
      return(TT_ERR_NOT_ALLOWED_FILENAME);
   }
   return(TT_YES);
}

int tt_valid_dirname(char *dirname)
/***************************************************************************/
{
   int len,k;
   char a;
   len=strlen(dirname);
   for (k=0;k<len;k++) {
      a=dirname[k];
      if ((a=='*')||(a=='?')){
	 return(TT_NO);
      }
   }
   return(TT_YES);
}

int tt_valid_filename(char *filename)
/***************************************************************************/
{
   int len,k;
   char a;
   len=strlen(filename);
   for (k=0;k<len;k++) {
      a=filename[k];
      if ((a=='*')||(a=='?')||(a=='/')||(a=='\\')){
	 return(TT_NO);
      }
   }
   return(TT_YES);
}

double tt_atan2(double y, double x)
/***************************************************************************/
/* Calcul de atan2 sans 'domain error'.                                    */
/***************************************************************************/
{
   if (y==0) {
      if (x>=0) { return(0.); }
      else { return(2.*acos(0.)); }
   } else if (x==0) {
      if (y>=0) { return(acos(0.)); }
      else { return(-acos(0.)); }
   } else {
      return(atan2(y,x));
   }
}

int tt_strupr(char *chaine)
/***************************************************************************/
/* transforme une chaine de caracteres en majuscules                       */
/***************************************************************************/
{
   int len,k;
   char a;
   len=strlen(chaine);
   for (k=0;k<len;k++) {
      a=chaine[k];
      if ((a>='a')&&(a<='z')){chaine[k]=(char)(a-32); }
      else {chaine[k]=a; }
   }
   return(OK_DLL);
}


int tt_decodekeys(char *ligne,void ***outkeys,int *numkeys)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,k,kk;
   char **keys;/**ligne;*/
   int lenkeys,nbkeys=TT_MAXKEYS,pos_deb[TT_MAXKEYS],pos_fin[TT_MAXKEYS],len,inmot,quote_opened;
   
   /* --- decodage de la ligne de commandes ---*/
   keys=NULL;
   lenkeys=strlen(ligne);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&keys,&nbkeys,&lenkeys,"keys"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_decodekeys for pointer keys");
      return(msg);
   }
   
   /* Warning corrige par Denis
   *(outkeys)=(char**)(keys);
   */
   *(outkeys)=(void**)(keys);
   len=(int)(strlen(ligne));
   for (k=0;k<TT_MAXKEYS;k++) {
      pos_deb[k]=0;
      pos_fin[k]=0;
   }
   for (inmot=TT_NO,quote_opened=TT_NO,kk=0,k=0;k<len;k++) {
      if (kk>=TT_MAXKEYS) {break;}
      if (ligne[k]=='\"') {
         if (quote_opened==TT_NO) {
            quote_opened=TT_YES;
            inmot=TT_YES;
            pos_deb[kk]=k+1;
         } else {
            quote_opened=TT_NO;
            inmot=TT_NO;
            pos_fin[kk++]=k;
         }
      } else if ((ligne[k]==' ')||(ligne[k]=='\n')) {
         if ((quote_opened==TT_NO)&&(inmot==TT_YES)) {
            inmot=TT_NO;
            pos_fin[kk++]=k;
         }
      } else {
         if ((quote_opened==TT_NO)&&(inmot==TT_NO)) {
            pos_deb[kk]=k;
            inmot=TT_YES;
         }
      }
      /*printf("k=%d kk=%d nbkeys=%d inmot=%d\n",k,kk,nbkeys,inmot);*/
      if (ligne[k]=='\n') {break;}
   }
   if ((pos_deb[kk]==0)&&(pos_fin[kk]==0)) {
      kk--;
   }
   if (inmot==TT_YES) {
      inmot=TT_NO;
      pos_fin[kk]=k;
   }
   nbkeys=(kk>nbkeys)?nbkeys:kk+1;
   /*
   printf("= k=%d kk=%d nbkeys=%d\n",k,kk,nbkeys);
   for (k=0;k<nbkeys;k++) {
   printf("%d-%d ",pos_deb[k],pos_fin[k]);
   }
   printf("\n");
   getch();
   */
   for (k=0;k<nbkeys;k++) {
      len=pos_fin[k]-pos_deb[k];
      if (len<=0) {
         strcpy(keys[k],"");
      } else {
         if (len>=(lenkeys-1)) {len=(lenkeys-2);}
         strncpy(keys[k],ligne+(int)(pos_deb[k]),len);
         keys[k][len]='\0';
      }
      /*printf("keys[%d]=<%s>\n",k,keys[k]);*/
   }
   *numkeys=nbkeys;
   return(OK_DLL);
}


/***************************************************************************/
//  tt_scanNextInt (M . Pujol)
// 
//  extrait un entier du d�but d'une chaine de caracteres, 
//  et retourne un pointeur sur le debut de l'entier suivant
//   
//  Return 
//     pointeur sur le debut de l'entier suivant 
///    ou NULL si fin de chaine rencontree
/***************************************************************************/
char * tt_scanNextInt(char* buffer,int *value) {
   char *p = buffer;
   char *p0;
   int resultScan;
   
   if ( p== NULL ) {
      // j'arrete si le pointeur null
      return NULL; 
   }
   
   if ( *p== '\0' ) {
      // j'arrete si j'ai atteint la fin de la chaine de caracteres  
      return NULL; 
   }

   while ( *p ==  ' ' || *p == '{' || *p == '}' ) {
      // je point le caractere suivant
      p++;
      // je commence s'il y a encore un espace
   }

   // je lis l'entier 
   if ( *p == 'P' || *p == 'C' || *p == 'L' ) {
      *value = (int) *p;
      p++;
   } else {
      resultScan = sscanf(p, "%d", value); 
      if (resultScan == 0 ) return NULL;
   }

   // je cherche l'espace suivant 
   p0 = strchr(p,' ');
   if ( p0== NULL ) {
      p0 = strchr(p,'}');
      if ( p0== NULL ) { 
         // j'arrete si j'ai atteint la fin de la chaine de caracteres  
         return NULL; 
      } else {
         p = p0;
      }
   } else {
      p = p0;
   }
   while ( *p ==  ' ' || *p == '{' || *p == '}' ) {
      // je pointe le caractere suivant
      p++;
   }

   return p;
}


///////////////////////////////////////////////////////////////
//  Traitement des pixels chauds ou les lignes defectueuses ou les colonnes defecteuses 
///////////////////////////////////////////////////////////////

//***************************************************************************/
//  tt_parseHotPixelList (M . Pujol)
// 
//  transforme une chaine de caracteres contenant une liste de pixels chauds 
//     en une table d'entiers 
//  
//  Type valeurs 
//   P   x  y    un pixel chaud (3 valeurs)
//   C   x       une colonne defectueuse (2 valeurs)
//   R   y       une ligne defectueuse (2 valeurs)
//   \0          fin de table (1 valeur)
//
//  Exemple : 2 pixels chauds et une colonne defecteuse 
//   chaine en entree : char sHotPixels[] = "P 232 183 P 456 198 C 400 L 200"
//   table en sortie  : int  iHotPixels[] = [50 232 183 50 456 198 43 400 4C 200 0]
//***************************************************************************/
int tt_parseHotPixelList(char* sHotPixels,int **iHotPixels)
{
   char * p = sHotPixels;
   int nbvalues = 0;

   if ( sHotPixels == NULL ) {
      *iHotPixels = NULL;
      return OK_DLL; 
   }
   *iHotPixels = malloc((nbvalues+1)* sizeof(int));
   if ( *iHotPixels == NULL ) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb malloc in tt_parseHotPixelList");
      return TT_ERR_PB_MALLOC;
   }
   
   do { 
      int type , x , y; 
      p = tt_scanNextInt(p, &type);
      if ( p == NULL ) break;

      switch (type) {
      case 'P' : 
         p = tt_scanNextInt(p, &x); 
         if ( p== NULL ) break;
         p = tt_scanNextInt(p, &y); 
         if ( p== NULL ) break;
         nbvalues += 3;
         *iHotPixels = realloc(*iHotPixels,(nbvalues+1)*sizeof(int));
         if ( *iHotPixels == NULL ) {
            tt_errlog(TT_ERR_PB_MALLOC,"Pb realloc in tt_parseHotPixelList");
            return TT_ERR_PB_MALLOC;
         }
         (*iHotPixels)[nbvalues -3] = type;
         (*iHotPixels)[nbvalues -2] = x;
         (*iHotPixels)[nbvalues -1] = y;
         break;
      case 'C' : 
      case 'L' : 
         p = tt_scanNextInt(p, &x); 
         if ( p== NULL ) break;
         nbvalues += 2;
         *iHotPixels = realloc(*iHotPixels,(nbvalues+1)*sizeof(int));
         if ( *iHotPixels == NULL ) {
            tt_errlog(TT_ERR_PB_MALLOC,"Pb realloc in tt_parseHotPixelList");
            return TT_ERR_PB_MALLOC;
         }
         (*iHotPixels)[nbvalues - 2] = type;
         (*iHotPixels)[nbvalues -1] = x;
         break;
      }
      
   } while (p!=NULL);

   // j'ajoute la valeur nulle pour signaler la fin de table
   (*iHotPixels)[nbvalues] = 0;
   return(OK_DLL);
}


/************************ HMEDIAN (C Buil) *******************/
/* Retourne la valeur mediane d'un echantillon RA de n point */
/* Attention : l'echantillon est trie apres excecution       */
/*  utilise par tt_repairHotPixel                            */
/*************************************************************/
TT_PTYPE tt_hmedian(TT_PTYPE *table,int n)
{
   int l,j,ir,i;
   TT_PTYPE rtable;
   
   if (n<2)
      return *table;
   table--;
   for (l=((ir=n)>>1)+1;;)
   {
      if (l>1)
         rtable=table[--l];
      else
      {
         rtable=table[ir];
         table[ir]=table[1];
         if (--ir==1)
         {
            table[1]=rtable;
            return n&1? table[n/2+1] : (TT_PTYPE)(((double)table[n/2]+(double)table[n/2+1])/2.0);
         }
      }
      for (j=(i=l)<<1;j<=ir;)
      {
         if (j<ir && table[j]<table[j+1]) ++j;
         if (rtable<table[j])
         {
            table[i]=table[j];
            j+=(i=j);
         }
         else
            j=ir+1;
      }
      table[i]=rtable;
   }   
}

//***************************************************************************/
//  tt_repairHotPixel (M . Pujol)
// 
//  supprime les pixels chauds ou les lignes defectueuses ou les colonnes
//  defecteuses d'un image 2D 
//
// Parametres :
//  int *iHotPixels : tableau de d'entiers contenant les pixels chauds ou les 
//                    lignes defectueuses ou les colonnes defecteuse 
//      Exemple : 2 pixels chauds et une colonne defecteuse 
//      iHotPixels[] = [50 232 183 50 456 198 43 400 52 200 0]
//
//***************************************************************************/
int tt_repairHotPixel(int *iHotPixels, TT_IMA *p)
{

   int *pHotPixel = iHotPixels;
   int type, x, y,adr;
   TT_PTYPE tab[8];

   if (iHotPixels == NULL ) {
      return(OK_DLL);
   }

   do {
      type = *(pHotPixel++);
      switch (type) {
      case 'P' : 
         x = *(pHotPixel++);
         y = *(pHotPixel++);
         if (x>2 && y>2 && x<p->naxis1-2 && y<p->naxis2-2) {
            // je repare un pixel chaud en le rempla�ant par la mediane des points voisins
            adr=(x-1)+(y-1)* p->naxis1;
            tab[0]=p->p[adr-p->naxis1-1];
            tab[1]=p->p[adr          -1];
            tab[2]=p->p[adr+p->naxis1-1];
            tab[3]=p->p[adr-p->naxis1  ];
            tab[4]=p->p[adr+p->naxis1  ];
            tab[5]=p->p[adr-p->naxis1+1];
            tab[6]=p->p[adr          +1];
            tab[7]=p->p[adr+p->naxis1+1];         
            p->p[adr]=tt_hmedian(tab,8);    
         }

         break;
      case 'C' : 
         x = *(pHotPixel++);
         if (x>2 && x<p->naxis1-2 ) {
            // je repare la colonne defectueuse
            int adr=x-1;
            int j;
            for (j=0;j<p->naxis2;j++) {
               int adr2=j* p->naxis1+adr;
               p->p[adr2]=(p->p[adr2-1]+p->p[adr2+1])/2;
            }

         }
      case 'L' : 
         y = *(pHotPixel++);
         if (y>2 && y<p->naxis2-2) {
            // je repare la ligne defectueuse
            int adr=(y-1)* p->naxis1;
            int i;
            for (i=0;i<p->naxis1;i++) {
               int adr2=adr+i;
               p->p[adr2]=(p->p[adr2+p->naxis1]+p->p[adr2-p->naxis1])/2;
            }
         }

         break;
      }
   } while( type != 0);
   return(OK_DLL);
}





///////////////////////////////////////////////////////////////
//  Traitement des cosmiques 
///////////////////////////////////////////////////////////////


/************************* MEDIAN_LIBRE *****************************/
/* Calcul de la m�diane dans une matrice de dimension quelconque    */
/* (la dimension de la matrice est tout au plus la moiti� de la     */
/* plus petite dimension de l'image - la largeur de la matrice est  */
/* impaire - sont format est carr�)                                 */
/********************************************************************/
int median_libre(TT_PTYPE *image, int imax, int jmax, int dimension, double parametre)
{
   int i,j,k;
   TT_PTYPE v_median;
   TT_PTYPE *p0,*p1,*ptr0,*ptr1,*ptr;
   TT_PTYPE *ker,*buf;
   int *d;
   int l_kernel,largeur2;
   int dim_kernel;
   int longueur,adr;
   
   /* la dimension du kernel doit �tre impaire */
   if (dimension%2==0)
   {
      tt_errlog(TT_ERR_PB_MALLOC,"median_libre : la dimension de la matrice doit �tre impaire");
      return(TT_ERR_PB_MALLOC);
   }
   
   l_kernel= dimension;
   dim_kernel=l_kernel*l_kernel;
   
   longueur=sizeof(TT_PTYPE)*imax*jmax;
   
   if (imax<2*l_kernel || jmax<2*l_kernel)
   {
      tt_errlog(TT_ERR_PB_MALLOC,"median_libre :  kernel trop grand");
      return(TT_ERR_PB_MALLOC);
   }
   
   if ((buf=(TT_PTYPE *)malloc(longueur))==NULL)
   {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc buf in median_libre");
      return TT_ERR_PB_MALLOC;
   }
   
   if ((d=(int *)malloc(dim_kernel*sizeof(int)))==NULL)
   {
      free(buf);
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc d in median_libre");
      return TT_ERR_PB_MALLOC;
   }
   
   if ((ker=(TT_PTYPE *)malloc(dim_kernel*sizeof(TT_PTYPE)))==NULL)
   {
      free(buf);
      free(d);
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc ker in median_libre");
      return TT_ERR_PB_MALLOC;
   }
   
   largeur2=l_kernel/2;
   for (i=0;i<l_kernel;i++)
   {
      for (k=0;k<l_kernel;k++)
      {
         d[i+k*l_kernel]=(largeur2-k)*imax+i-largeur2;
      }
   }
   
   p0=image;
   p1=buf;
   memset(buf,0,longueur);
   
   for (j=largeur2;j<(jmax-largeur2);j++)
   {
      adr=j*imax;
      ptr0=p0+adr;
      ptr1=p1+adr;
      ptr=ptr0+largeur2;
      for (i=largeur2;i<(imax-largeur2);i++,ptr++)
      {
         for (k=0;k<dim_kernel;k++) ker[k]=*(ptr+d[k]);
         v_median=tt_hmedian(ker,dim_kernel);
         if (parametre>0)
         {
            if (fabs(*ptr-v_median) > (TT_PTYPE)(parametre*(double)(ker[dim_kernel-2]-ker[1])))
               *(ptr1+i)=v_median;
            else
               *(ptr1+i)=*ptr;
         }
         else
         {
            *(ptr1+i)=v_median;
         }
      }
   }
   memmove(p0,buf,longueur);
   
   free(buf);
   free(d);
   free(ker);
   
   return OK_DLL;
}

/************************ COSMIC_MED ************************/
/* D�tection des rayons cosmiques.                          */
/* La carte des rayons (map) est un buffer                  */
/* qui a la taille de l'image trait�e.                      */
/* La position des cosmiques est marqu�e par la valeur      */
/* 32767 dans cette carte (c'est un wildcard)               */
/* Algorithme :                                             */
/* (1) on charge l'image � traiter                          */
/* (2) on r�alise un filtre m�dian 5x5 pond�r�              */
/* (3) on soutrait � l'image trait�e l'image filtr�e        */
/* (4) dans l'image diff�rence, les cosmiques sont          */
/*     les points au dessus d'un seuil (pass� en param�tre) */
/* La fonction retourne le nombre de cosmique trouv�        */
/************************************************************/
int cosmic_med(TT_IMA *pIma, TT_PTYPE *map, double coef, TT_PTYPE seuil, int *nb)
{
   int i,j, k, nbb, adr;
   int imax=pIma->naxis1;
   int jmax=pIma->naxis2;
   int msg;
   
   TT_PTYPE *tampon = NULL; 
   int number = imax*jmax;
   int size  = sizeof(TT_PTYPE); 

   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tampon,&number,&size,"tampon"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in cosmic_med tampon");
      return(TT_ERR_PB_MALLOC);
   }
   
   memmove(tampon, pIma->p, imax * jmax * sizeof(TT_PTYPE));
   
   if (median_libre(tampon, imax, jmax, 5, coef) != OK_DLL) {
      tt_errlog(TT_ERR_PB_MALLOC,"cosmic_med : Pb in median_libre");
      tt_free(tampon,"tampon");
      return(TT_ERR_PB_MALLOC);      
   }

   k=0;
   for (j=0;j<jmax;j++)
   {
      for (i=0;i<imax;i++,k++)
      {
         tampon[k]=pIma->p[k]-tampon[k];
      }
   }
   
   nbb=0;
   
   for (j=3; j<jmax-3; j++)
   {
      for (i=3; i<imax-3; i++)
      {
         adr=i+j*imax;
         if (tampon[adr]>seuil)
         {
            map[adr]=32767;
            nbb++; 
         }
         else
            map[adr]=0;
      }
   }
   
   *nb=nbb;
   
   tt_free(tampon,"tampon");
   return OK_DLL; 
}

/********************** COSMIC_REPAIR (C. Buil) **********/
/* R�paration des rayons cosmiques                       */
/* Un cosmique dans l'image map est flagg� par           */
/* la valeur 32767                                       */
/* Le cosmique est bouch� par la valeur m�diane          */
/* des 8 plus proches voisins (sauf si c'est un cosmiqe) */
/*********************************************************/
int cosmic_repair(TT_IMA *pIma, TT_PTYPE *map)
{
   int i,j,adr;
   TT_PTYPE table[8];
   
   int imax=pIma->naxis1;
   int jmax=pIma->naxis2;
   
   for (j=3; j<jmax-3; j++)
   {
      for (i=3; i<imax-3; i++)
      {
         adr=i+j*imax;
         if (map[adr]==32767)
         {         
            int n=0;
            if (map[adr-imax-1]!=32767)
            {
               table[n]=pIma->p[adr-imax-1];
               n++;
            }
            if (map[adr     -1]!=32767)
            {
               table[n]=pIma->p[adr     -1];
               n++;
            }
            if (map[adr+imax-1]!=32767)
            {   
               table[n]=pIma->p[adr+imax-1];
               n++;
            }
            if (map[adr-imax  ]!=32767)
            { 
               table[n]=pIma->p[adr-imax  ];
               n++;
            }
            if (map[adr+imax  ]!=32767)
            {
               table[n]=pIma->p[adr+imax  ];
               n++;
            }
            if (map[adr-imax+1]!=32767)
            {
               table[n]=pIma->p[adr-imax+1];
               n++;
            }
            if (map[adr     +1]!=32767)
            {  
               table[n]=pIma->p[adr     +1];
               n++;
            }
            if (map[adr+imax+1]!=32767)
            { 
               table[n]=pIma->p[adr+imax+1];
               n++;
            } 
            pIma->p[adr]=tt_hmedian(table,n);    
         }
      }
   }
   return OK_DLL;
}



//***************************************************************************/
//  tt_repairCosmic (M . Pujol)
// 
//  supprime les cosmiques d'un image 2D 
//
// Parametres :
//  TT_PTYPE cosmicThreshold : seuil de detection des cosmiques (typiquement entre 100 et 500) 
//
//***************************************************************************/
int tt_repairCosmic(TT_PTYPE cosmicThreshold, TT_IMA *pIma)
{

   TT_PTYPE *map = NULL;           // carte des cosmiques (� l'it�ration courante)
   TT_PTYPE *map_total = NULL;     // carte cumul�e
   int msg;
   int adr;
   int nb=0;
   int nb_total=0;
   int i,j,k;
   int nb_iter=5;   // nombre d'it�rations (fix�e par l'exp�rience)
   int imax=pIma->naxis1;
   int jmax=pIma->naxis2;
   int number = imax*jmax;
   int size  = sizeof(TT_PTYPE); 

   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&map,&number,&size,"map"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_repairCosmic map");
      return(TT_ERR_PB_MALLOC);
   }
   
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&map_total,&number,&size,"map_total"))!=0) {
      tt_errlog(TT_ERR_PB_MALLOC,"Pb calloc in tt_repairCosmic map_total");
      tt_free(map,"map");
      return(TT_ERR_PB_MALLOC);
   }

   // Boucle de calcul...
   for (k=0;k<nb_iter;k++)
   {
      if (cosmic_med(pIma,map,0.6,cosmicThreshold,&nb)!=OK_DLL) {
         tt_free(map,"map");
         tt_free(map_total,"map_total");
         tt_errlog(TT_ERR_PB_MALLOC,"tt_repairCosmic: Pb calloc in cosmic_med ");
         return(TT_ERR_PB_MALLOC);
      }
      if (cosmic_repair(pIma,map)!=OK_DLL) {
         tt_free(map,"map");
         tt_free(map_total,"map_total");
         tt_errlog(TT_ERR_PB_MALLOC,"tt_repairCosmic: Pb calloc in cosmic_repair ");
         return(TT_ERR_PB_MALLOC);
      }
      for (j=3; j<jmax-3; j++)
      {
         for (i=3; i<imax-3; i++)
         {
            adr=i+j*imax;
            if (map_total[adr]==0 && map[adr]==32767) // si un point n'est pas d�j� flagg�, il est ajout� dans la carte de cumul 
            {
               map_total[adr]=32767;
               nb_total++;
            }
         } 
      }
   }
   
   //memmove(pIma->p,map_total,number*size);
   
   // .......
   // .......
   // sauvegarde de la carte des cosmiques (map_total)      
   //bufTotal = createImage(map_total, imax, jmax);
   //pMapFits = Fits_createFits("@map.fit", bufTotal ); 
   //Fits_closeFits( pMapFits);
   //freeImage(bufTotal);

   {   /* --- sauve l'image avec une entete minimale ---*/
      int typehdu=IMAGE_HDU;
      int hdunum=0;

      if ((msg=libfiles_main(FS_MACR_WRITE,11,"@map.fit",hdunum,&typehdu,
            NULL,NULL,NULL,
            &pIma->naxis,pIma->naxes,&pIma->save_bitpix,&pIma->datatype,map_total))!=0) {
      }
   }



   printf("\nNombre de cosmiques trouv� : %d\n",nb_total);

   tt_free(map,"map");
   tt_free(map_total,"map_total");

   

   return(OK_DLL);
}

/************************************************************************/
/* Compute a cumulative distribution function (fonction de repartition) */
/* in case of a gaussian distribution function.                         */
/* double sigmax=5;                                                     */
/* int repartitions[10000],n=10000;                                     */
/* tt_gaussian_cdf(repartitions,n,sigmax);                              */
/************************************************************************/
int tt_gaussian_cdf(double *repartitions,int n,double sigmax)
{
	int k;
	double xsig,norm;
	repartitions[0]=0;
	for (k=1;k<n;k++) {
		xsig=sigmax*2*k/n-sigmax;
		if (k%100==0) {
			k+=0;
		}
		repartitions[k]=repartitions[k-1]+exp(-xsig*xsig/2);
	}
	norm=repartitions[n-1];
	for (k=0;k<n;k++) {
		repartitions[k]=repartitions[k]/norm*32767.;
	}
   return(OK_DLL);
}

/*************************************************************************/
/* Compute a random number that follows a gaussian distribution function.*/
/* double sigmax=5;                                                     */
/* int repartitions[10000],n=10000;                                     */
/* tt_gaussian_cdf(repartitions,n,sigmax);                              */
/* rand=tt_gaussian_rand(repartitions,n,sigmax);                        */
/*************************************************************************/
double tt_gaussian_rand(double *repartitions,int n,double sigmax)
{
	int k1,k2,k3,a,m;
	double b;
   a=rand();
   k1=1;
   k3=n;
   m=0;
   while ((k3-k1)>1) {
      k2=(int)floor((k1+k3)/2.);
		if (a<repartitions[k2]) {
         k3=k2;
      } else {
         k1=k2;
      }
      m=m+1;
	}
   b=sigmax*(k2-n/2)/(n/2);
   return(b);
}
