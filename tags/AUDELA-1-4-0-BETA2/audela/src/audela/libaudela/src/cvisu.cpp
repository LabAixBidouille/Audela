/* cvisu.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#include "cvisu.h"

#include <math.h>

CVisu::CVisu(Tcl_Interp *Interp, int buf, int img)
{
   interp = Interp;
   x1 = y1 = x2 = y2 = 0;
   full = 1;
   box_set = 0;
   mirrorX = 0;
   mirrorY = 0;
   mirrorDiag = 0;
   zoom = 1.;
   locutRed = (Lut_Cut)0;
   hicutRed = (Lut_Cut)32767;
   locutGreen = (Lut_Cut)0;
   hicutGreen = (Lut_Cut)32767;
   locutBlue = (Lut_Cut)0;
   hicutBlue = (Lut_Cut)32767;
   palette_dir = NULL;
   thickness_1d = 20;

   // Initialisation eventuelle de la Tk_Image
   CreateImage(img);

   // Initialisation eventuelle du buffer
   CreateBuffer(buf);

   // Initialisation Palette
   pal.typ = Pal_None;
   pal.filename = NULL;
   (pal.pal)[0] = NULL;
   (pal.pal)[1] = NULL;
   (pal.pal)[2] = NULL;
   CreatePalette(Pal_Grey);

}


CVisu::~CVisu()
{
}


int CVisu::GetMirrorDiag()
{
   return mirrorDiag;
}

char* CVisu::GetPaletteDir()
{
   return palette_dir;
}

int CVisu::GetMirrorX()
{
   return mirrorX;
}

int CVisu::GetMirrorY()
{
   return mirrorY;
}

int CVisu::GetThickness()
{
   return thickness_1d;
}

void CVisu::GetZoom(double *z)
{
   *z = zoom;
}


int CVisu::IsFull()
{
   return full;
}


int CVisu::GetWindow(int *xx1, int *yy1, int *xx2, int *yy2)
{
   CBuffer *buffer;
   int naxis1, naxis2;

   if(full==1) {
      buffer = (CBuffer*)buf_pool->Chercher(bufnum);
      if(buffer==NULL) {
         return ELIBSTD_BUF_EMPTY;
      }
      naxis1 = buffer->GetW();
      naxis2 = buffer->GetH();

      *xx1 = 1;
      *yy1 = 1;
      *xx2 = naxis1;
      *yy2 = naxis2;
   } else {
      *xx1 = x1;
      *yy1 = y1;
      *xx2 = x2;
      *yy2 = y2;
   }

   return 0;
}

int CVisu::ClearImage()
{
   Tk_PhotoHandle ph;
   char *ligne;

   ligne = new char[40];
   sprintf(ligne,"image%d",imgnum);
   ph = Tk_FindPhoto(interp,ligne);
   if(ph!=NULL) {
      sprintf(ligne,"image delete image%d",imgnum);
      Tcl_Eval(interp,ligne);
      sprintf(ligne,"image create photo image%d",imgnum);
      Tcl_Eval(interp,ligne);
      sprintf(ligne,"image%d",imgnum);
      ph = Tk_FindPhoto(interp,ligne);
      if(ph==NULL) {
         delete ligne;
         return ELIBSTD_CANT_GETORCREATE_TKIMAGE;
      }
   }

   delete ligne;
   return 0;
}



int CVisu::CreateBuffer(int num)
{
   char *ligne;


   if(buf_pool->Chercher(num)==NULL) {
      ligne = new char[256];
      sprintf(ligne,"::buf::create %d",num);
      Tcl_Eval(interp,ligne);
      delete ligne;
      if(buf_pool->Chercher(num)==NULL) {
         return ELIBSTD_CANNOT_CREATE_BUFFER;
      }
      // Creer ici le buffer.
   }
   bufnum = num;
   return 0;
}

int CVisu::CreateImage(int num)
{
   Tk_PhotoHandle ph;
   char *ligne;

   ligne = new char[40];
   sprintf(ligne,"image%d",num);
   ph = Tk_FindPhoto(interp,ligne);
   if(ph==NULL) {
      sprintf(ligne,"image create photo image%d",num);
      Tcl_Eval(interp,ligne);
      sprintf(ligne,"image%d",num);
      ph = Tk_FindPhoto(interp,ligne);
      if(ph==NULL) {
         delete ligne;
         return ELIBSTD_CANT_GETORCREATE_TKIMAGE;
      }
   }
   imgnum = num;

   delete ligne;
   return 0;
}


int CVisu::CreatePaletteFromFile(char *filename)
{
   FILE *paletteFile = NULL;
   Pal_Element *palette[3] = {NULL, NULL, NULL};
   char inputBuffer[256], *charIndex;
   int i;
   float red, green, blue;
   int nb = 0;
   int index = 0;
   char *path = NULL;
   int palette_dir_len, audela_start_dir_len;
   
   // Charge le fichier de palette et verifie s'il est correct.
   // Le fichier de palette est un fichier texte de 256 lignes, 
   // chacune faite de 4 nombres : l'index dans la palette (0..255),
   // suivi de l'intensite du rouge, du vert, et du bleu. Chaque 
   // valeur doit etre comprise entre 0 (noir) et 255 (saturation). 
   // Des commentaires peuvent etre ajoutes, apres le signe # (comme en TCL),
   // Exemple:
   // # Ce fichier definit une palette inversee
   // 0   255 255 255
   // 1   254 254 254
   // ...
   // 255 0   0   0

   // si %palettename% est nom passe en parametre, les fichiers recherches
   // sont par ordre de priorite :
   // ./%palettename%.pal
   // palette_dir/%palettename%.pal
   // audela_start_dir/../%palettename%.pal
   palette_dir_len = palette_dir==NULL ? 0 : strlen(palette_dir);
   audela_start_dir_len = audela_start_dir==NULL ? 0 : strlen(audela_start_dir);
   path = (char*)calloc(audela_start_dir_len+palette_dir_len+strlen(filename)+10,1);
   sprintf(path,"./%s.pal",filename);
   paletteFile = fopen(path,"rt");
   if(paletteFile==NULL) {
      if(palette_dir!=NULL) {
         sprintf(path,"%s/%s.pal",palette_dir,filename);
         paletteFile = fopen(path,"rt");
      }
      if(paletteFile==NULL) {
         if(audela_start_dir!=NULL) {
            sprintf(path,"%s/../%s.pal",audela_start_dir,filename);
            paletteFile = fopen(path,"rt");
         }
         if(paletteFile==NULL) {
            free(path);
            return ELIBSTD_PALETTE_CANT_FIND_FILE;
         }
      }
   }
   free(path);

   // Lecture du fichier palette
   for(i=0;i<3;i++) palette[i] = new Pal_Element[256];
   while(fgets(inputBuffer,256,paletteFile) != NULL) {
      if((charIndex = strchr(inputBuffer,'#'))!=NULL)
         *charIndex = 0;
      if((inputBuffer[0]!=0)&&(index!=256)) {
         nb = sscanf(inputBuffer, "%f %f %f", &red, &green, &blue);
         if(nb != 3) {
            for(i=0;i<3;i++) delete palette[i];
            fclose(paletteFile);
            return ELIBSTD_PALETTE_MALFORMED_FILE;
         }
         palette[0][index] = (Pal_Element)red;
         palette[1][index] = (Pal_Element)green;
         palette[2][index] = (Pal_Element)blue;
         index++;
      }
   }
   fclose(paletteFile);
 
   // Si OK, alors recopier la palette.
   if (index==256) {
      // Si la palette existe deja, elle est detruite
      if((pal.pal)[0]!=NULL) {
         for(i=0;i<3;i++) {
            delete (pal.pal)[i];
         }
      }
      if(pal.filename!=NULL) {
         delete pal.filename;
      }
      // Recopie de la palette
      pal.typ = Pal_File;
      pal.filename = new char[strlen(filename)+1];
      strcpy(pal.filename,filename);
      for(i=0;i<3;i++) {
         (pal.pal)[i] = palette[i];
      }
      // Mise a jour de l'image
      UpdateDisplay();
   } else {
      for(i=0;i<3;i++) delete palette[i];
      return ELIBSTD_PALETTE_NOTCOMPLETE;
   }

   return 0;
}


int CVisu::CreatePalette(Pal_Type t)
{
   int i;

   if(t==pal.typ) return 0;

   if((pal.pal)[0]==NULL) {
      for(i=0;i<3;i++) {
         (pal.pal)[i] = new Pal_Element[256];
      }
   }

   switch(t) {
      case Pal_Red1 :
         pal.typ = Pal_Red1;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i);
            (pal.pal)[1][i] = (Pal_Element)(2*i/3);
            (pal.pal)[2][i] = (Pal_Element)(i/3);
         };
         break;
      case Pal_Red2 :
         pal.typ = Pal_Red2;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i);
            (pal.pal)[1][i] = (Pal_Element)(i/3);
            (pal.pal)[2][i] = (Pal_Element)(2*i/3);
         };
         break;
      case Pal_Green1 :
         pal.typ = Pal_Green1;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(2*i/3);
            (pal.pal)[1][i] = (Pal_Element)(i);
            (pal.pal)[2][i] = (Pal_Element)(i/3);
         };
         break;
      case Pal_Green2 :
         pal.typ = Pal_Green2;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i/3);
            (pal.pal)[1][i] = (Pal_Element)(i);
            (pal.pal)[2][i] = (Pal_Element)(2*i/3);
         };
         break;
      case Pal_Blue1 :
         pal.typ = Pal_Blue1;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(2*i/3);
            (pal.pal)[1][i] = (Pal_Element)(i/3);
            (pal.pal)[2][i] = (Pal_Element)(i);
         };
         break;
      case Pal_Blue2 :
         pal.typ = Pal_Blue2;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i/3);
            (pal.pal)[1][i] = (Pal_Element)(2*i/3);
            (pal.pal)[2][i] = (Pal_Element)(i);
         };
         break;
      case Pal_Grey:
      default:
         pal.typ = Pal_Grey;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i);
            (pal.pal)[1][i] = (Pal_Element)(i);
            (pal.pal)[2][i] = (Pal_Element)(i);
         };
         break;
   };

   UpdateDisplay();

   return 0;
}

/**
 *  GetGrayHicut()
 *  returns  hight cut for gray image
 */
Lut_Cut CVisu::GetGrayHicut()
{
   return hicutRed;
}

/**
 *  GetGrayLocut()
 *  returns  low cut for gray image
 */
Lut_Cut CVisu::GetGrayLocut()
{
   return locutRed;
}

void CVisu::GetRgbCuts(Lut_Cut *hcRed, Lut_Cut *lcRed, Lut_Cut *hcGreen, Lut_Cut *lcGreen, Lut_Cut *hcBlue, Lut_Cut *lcBlue)
{
   *hcRed = hicutRed;
   *lcRed = locutRed;
   *hcGreen = hicutGreen;
   *lcGreen = locutGreen;
   *hcBlue = hicutBlue;
   *lcBlue = locutBlue;
}

void CVisu::SetGrayCuts(Lut_Cut hc, Lut_Cut lc)
{
   hicutRed = hc;
   locutRed = lc;
   hicutGreen = hc;
   locutGreen = lc;
   hicutBlue = hc;
   locutBlue = lc;
}

void CVisu::SetRgbCuts(Lut_Cut hcRed, Lut_Cut lcRed, Lut_Cut hcGreen, Lut_Cut lcGreen, Lut_Cut hcBlue, Lut_Cut lcBlue)
{
   hicutRed = hcRed;
   locutRed = lcRed;
   hicutGreen = hcGreen;
   locutGreen = lcGreen;
   hicutBlue = hcBlue;
   locutBlue = lcBlue;
}

int CVisu::UpdateDisplay()
{
   Tk_PhotoHandle ph;
   Tk_PhotoImageBlock pib;
   CBuffer *buffer;
   unsigned char *ptr;
   char *ligne;
   //int ww, wh;              // window width, height multiplied by zoom
   int xx1, yy1, xx2, yy2;  // window coordinates
   int orgw, orgh;          // picture width, height
   int orgww, orgwh;        // original window width, height

   buffer = (CBuffer*)buf_pool->Chercher(bufnum);
   if(buffer==NULL) {
      return ELIBSTD_NO_ASSOCIATED_BUFFER;
   }

   orgw = buffer->GetW();
   orgh = buffer->GetH();

   if(full==1) {
      xx1 = 0;
      yy1 = 0;
      xx2 = orgw - 1;
      yy2 = orgh - 1;
   } else {
      //if( x1>orgw || x2>orgw) {
      //   return ELIBSTD_X1X2_NOT_IN_1NAXIS1;
      //}

      //if( y1>orgh || y2>orgh ) {
      //   return ELIBSTD_Y1Y2_NOT_IN_1NAXIS2;
      //}

      xx1 = x1-1;
      yy1 = y1-1;
      xx2 = x2-1;
      yy2 = y2-1;
   }

   
   if( buffer->GetNaxis() == 1 ) {
      orgww = xx2 - xx1 + 1; // Largeur 
      orgwh = thickness_1d;
      yy1 = 0;
      yy2 = 0;
   } else {
      orgww = xx2 - xx1 + 1; // Largeur 
      orgwh = yy2 - yy1 + 1; // Hauteur 
   }

   ptr = (unsigned char*)calloc(orgww*orgwh,3);
   if(ptr==NULL) {
      return ELIBSTD_NO_MEMORY_FOR_DISPLAY;
   }

   buffer->GetPixelsVisu(xx1,yy1,xx2,yy2, mirrorX, mirrorY, 
      hicutRed, locutRed, hicutGreen, locutGreen, hicutBlue, locutBlue,
      &pal, ptr);

   if( buffer->GetNaxis() == 1 ) {
      unsigned char *ptr2;
      ptr2 = (unsigned char*)calloc(orgww*thickness_1d,3);
      if(ptr2==NULL) {
         free(ptr);
         return ELIBSTD_NO_MEMORY_FOR_DISPLAY;
      }
      for(int y=0 ; y < thickness_1d; y++) {
         memcpy(ptr2+y*orgww*3, ptr, orgww*3);
      }
      free(ptr);
      ptr = ptr2;
   }
      
   // Preparation de la structure a passer a TCL/TK pour afficher l'image.
   pib.pixelPtr = ptr;
   pib.width = orgww;
   pib.height = orgwh;
   pib.pitch = orgww*3;
   pib.pixelSize = 3;
   pib.offset[0] = 0;
   pib.offset[1] = 1;
   pib.offset[2] = 2;
   pib.offset[3] = 0;

   // Affichage de l'image dans 'image$imgnum'.
   ligne = new char[32];
   sprintf(ligne,"image%d",imgnum);
   ph = Tk_FindPhoto(interp,ligne);
   delete ligne;

   if(ph==NULL) {
      free(ptr);
      return ELIBSTD_NO_TKPHOTO_HANDLE;
   }

   //Tk_PhotoPutBlock(ph,&pib,0,0, ww,wh);
   if( zoom == 1 ) {
      Tk_PhotoPutBlock(ph,&pib,0,0, orgww,orgwh);
   } else if( zoom > 1) {
      Tk_PhotoPutZoomedBlock(ph, &pib, 0, 0, (int) (orgww*zoom), (int) (orgwh*zoom), (int) zoom, (int) zoom, 1, 1);
   } else {
      Tk_PhotoPutZoomedBlock(ph, &pib, 0, 0, (int) (orgww*zoom), (int) (orgwh*zoom), 1, 1, (int) (1./zoom), (int) (1./zoom));
   }


   if(ptr != NULL) {
      free(ptr);
   }
   return 0;
}


void CVisu::SetMirrorDiag(int val)
{
   mirrorDiag = val;
}

void CVisu::SetMirrorX(int val)
{
   mirrorX = val;
}

void CVisu::SetMirrorY(int val)
{
   mirrorY = val;
}

void CVisu::SetPaletteDir(char *dir)
{
   if(palette_dir!=NULL) {
      free(palette_dir);
   }
   palette_dir = (char*)malloc(strlen(dir)+1);
   palette_dir[0] = 0;
   strcpy(palette_dir,dir);
}

void CVisu::SetThickness(int val)
{
   thickness_1d = val;
}

int CVisu::SetWindow(int xx1, int yy1, int xx2, int yy2)
{
   CBuffer *buffer;

   buffer = (CBuffer*)buf_pool->Chercher(bufnum);
   if(buffer==NULL) {
      return ELIBSTD_NO_ASSOCIATED_BUFFER;
   }

   //petite protection pour eviter les cas tordus
   if( full == 0) {
      return ELIBSTD_SUB_WINDOW_ALREADY_EXIST;
   }

   if (mirrorX == 0) {
      x1 = xx1;
      x2 = xx2;
   } else {      
      x1 = buffer->GetW() - xx2 -1;
      x2 = buffer->GetW() - xx1 -1;
   }

   if (mirrorY == 0) {
      y1 = yy1;
      y2 = yy2;
   } else {      
      y1 = buffer->GetH() - yy2 -1 ;
      y2 = buffer->GetH() - yy1 -1;
   }

   full = 0;

   return 0;

}

void CVisu::SetWindowFull()
{
   full = 1;
}


double CVisu::SetZoom(double z)
{
   if((z!=.125)&&(z!=.25)&&(z!=.5)&&(z!=2)&&(z!=3)&&(z!=4)&&(z!=8)) {
      z = 1.;
   }
   zoom=z;
   return zoom;
}

