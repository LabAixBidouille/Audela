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
   strcat(message,". See tt.err");
   return(OK_DLL);
}

int tt_errlog(int numerreur,char *commande)
/**************************************************************************/
/* Ecrit le fichier tt.err qui contient l'erreur trouve au cours de l'exec*/
/**************************************************************************/
{
   FILE *fichier_log,*fichier_err;
   int long_fic,kk,sortie,milieu;
   int long_mes=TT_MAXLIGNE;
   char car;
   char message_log[TT_MAXLIGNE];
   char message[TT_MAXLIGNE];
   char mode[5];
   time_t ltime;
   if ((fichier_err=fopen(nom_fichier_err, "r") ) == NULL) {
      strcpy(mode,"w");
   } else {
      strcpy(mode,"a");
      fclose(fichier_err);
   }
   if ((fichier_err=fopen(nom_fichier_err,mode) ) == NULL) {
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
   /* --- deuxieme ligne ---*/
   strcpy(message,"");
   tt_errmessage2(numerreur,message);
   strcat(message,"\n");
   fwrite(message,strlen(message),1,fichier_err);
   /* --- troisieme ligne ---*/
   strcpy(message,"");
   if (commande!=NULL) {
      strcpy(message,commande);
   }
   strcat(message,"\n");
   fwrite(message,strlen(message),1,fichier_err);
   fclose(fichier_err);
   return(OK_DLL);
}

int tt_writelog(char *message)
/**************************************************************************/
/* Ecrit un message dans le fichier de log                                */
/**************************************************************************/
{
   FILE *fichier_log;
   time_t ltime;
   char chaine[TT_MAXLIGNE];
   char message_log[TT_MAXLIGNE];
   int pos;
   char *car;
   if ((fichier_log=fopen(nom_fichier_log, "r") ) == NULL) {
      if ((fichier_log=fopen(nom_fichier_log, "w") ) == NULL) {
	 return(PB_DLL);
      }
   } else {
      fclose(fichier_log);
      if ((fichier_log=fopen(nom_fichier_log, "a") ) == NULL) {
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

int tt_verifargus_getFileName(char *fileNames, int fileIndex , char* fileName)
/***************************************************************************/
/* retourne le n'ieme nom de fichier de la serie                           */
/* parametres :                                                            */
/*    fileNames (in) liste des noms de fichiers (separes par un espace)    */
/*      les noms contant un espace doivent etre encadres par des accolades */
/*    filIndex  (in)  numero du nom de fichier                             */
/*    fileName  (out)  nom du fichier correspondant a fileIndex            */
/* return :                                                                */
/*    1 si ok, ou -1 si erreur                                             */
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
   lenkeys=500;
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


