/* visu_tcl.cpp
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

#include "cpool.h"
#include "cbuffer.h"
#include "cvisu.h"

//------------------------------------------------------------------------------
// La variable globale est definie de maniere unique ici.
//
CPool *visu_pool;

//------------------------------------------------------------------------------
// Commande internes pour gerer les commandes d'une visu
//
int cmdVisuDisp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuCut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuPal(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuPalDir(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuBuf(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuWindow(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuZoom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);


static struct cmditem cmdlist[] = {
   {"disp", (Tcl_CmdProc *)cmdVisuDisp},
   {"cut", (Tcl_CmdProc *)cmdVisuCut},
   {"pal", (Tcl_CmdProc *)cmdVisuPal},
   {"paldir", (Tcl_CmdProc *)cmdVisuPalDir},
   {"buf", (Tcl_CmdProc *)cmdVisuBuf},
   {"image", (Tcl_CmdProc *)cmdVisuImage},
   {"window", (Tcl_CmdProc *)cmdVisuWindow},
   {"zoom", (Tcl_CmdProc *)cmdVisuZoom},
   {NULL, NULL}
};

int CmdVisu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[1024],ss[50];
   int result = TCL_OK;
   int k;
   struct cmditem *cmd;

   if(argc==1) {
      sprintf(s,"%s choose sub-command among ",argv[0]);
      k=0;
      while (cmdlist[k].cmd!=NULL) {
	      sprintf(ss," %s",cmdlist[k].cmd);
			strcat(s,ss);
			k++;
		}
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      for(cmd=cmdlist;cmd->cmd!=NULL;cmd++) {
         if(strcmp(cmd->cmd,argv[1])==0) {
            result = (*cmd->func)(clientData, interp, argc, argv);
            break;
         }
      }
      if(cmd->cmd==NULL) {
         sprintf(s,"%s %s : sub-command not found among ",argv[0], argv[1]);
         k=0;
		   while (cmdlist[k].cmd!=NULL) {
			   sprintf(ss," %s",cmdlist[k].cmd);
			   strcat(s,ss);
			   k++;
		   }
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdVisuBuf(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   int buf;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?num?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->bufnum);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetInt(interp,argv[2],&buf)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->CreateBuffer(buf);
      }
   }
   free(ligne);
   return result;
}

int cmdVisuImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   int img;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?num?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->imgnum);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetInt(interp,argv[2],&img)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->CreateImage(img);
      }
   }
   free(ligne);
   return result;
}

int cmdVisuPal(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   int res;

   ligne = (char*)calloc(1000,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?pal?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      switch(((CVisu*)clientData)->pal.typ) {
         case Pal_Grey :
            sprintf(ligne,"grey");
            break;
         case Pal_Red1 :
            sprintf(ligne,"red1");
            break;
         case Pal_Red2 :
            sprintf(ligne,"red2");
            break;
         case Pal_Green1 :
            sprintf(ligne,"green1");
            break;
         case Pal_Green2 :
            sprintf(ligne,"green2");
            break;
         case Pal_Blue1 :
            sprintf(ligne,"blue1");
            break;
         case Pal_Blue2 :
            sprintf(ligne,"blue2");
            break;
         case Pal_File :
            sprintf(ligne,((CVisu*)clientData)->pal.filename);
            break;
         case Pal_None :
         default :
            strcpy(ligne,"none");
            break;
     }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(strcmp(argv[2],"grey")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Grey);
      } else if(strcmp(argv[2],"red1")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Red1);
      } else if(strcmp(argv[2],"red2")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Red2);
      } else if(strcmp(argv[2],"green1")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Green1);
      } else if(strcmp(argv[2],"green2")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Green2);
      } else if(strcmp(argv[2],"blue1")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Blue1);
      } else if(strcmp(argv[2],"blue2")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Blue2);
      } else {
         res = ((CVisu*)clientData)->CreatePaletteFromFile(argv[2]);
         if(res!=0) {
            Tcl_SetResult(interp,CError::message(res),TCL_VOLATILE);
            result = TCL_ERROR;
         }
      }
   }
   free(ligne);
   return result;
}

int cmdVisuPalDir(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;

   if((argc!=2)&&(argc!=3)) {
      ligne = (char*)calloc(200,sizeof(char));
      sprintf(ligne,"Usage: %s %s ?path?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      free(ligne);
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      Tcl_SetResult(interp,visu->GetPaletteDir(),TCL_VOLATILE);
   } else {
      visu = (CVisu*)clientData;
      visu->SetPaletteDir(argv[2]);
   }
   return result;
}

int cmdVisuCut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   float fsh, fsb;
   double dSh, dSb;
   CVisu *visu;
   CBuffer *buffer;
   CFitsKeyword *kwd;
   CFitsKeywords *keywords;
   int listArgc;
   char **listArgv;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?cut?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      buffer = (CBuffer*)buf_pool->Chercher(visu->bufnum);
      keywords = buffer->GetKeywords();
      if((keywords!=NULL)&&((kwd=keywords->FindKeyword("MIPS-HI"))!=NULL)) fsh = kwd->GetFloatValue();
      else fsh = 32767.0;
      if((keywords!=NULL)&&((kwd=keywords->FindKeyword("MIPS-LO"))!=NULL)) fsb = kwd->GetFloatValue();
      else fsb = 0.0;
      sprintf(ligne,"%f %f",fsh,fsb);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
         sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else if(listArgc!=2) {
         sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            fsh = (float)dSh;
            fsb = (float)dSb;
            visu = (CVisu*)clientData;
            buffer = (CBuffer*)buf_pool->Chercher(visu->bufnum);
            if(buffer) {
               keywords = buffer->GetKeywords();
               if(keywords) {
                  keywords->Add("MIPS-HI",&fsh,TFLOAT,NULL,NULL);
                  keywords->Add("MIPS-LO",&fsb,TFLOAT,NULL,NULL);
               }
            }
         }
         Tcl_Free((char*)listArgv);
      }
   }
   free(ligne);
   return result;
}

// TODO : Il faut reorganiser cette fonction pour qu'elle adhere au style gloval,
// notamment en terme de gestion du resultat TCL.
int cmdVisuDisp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char *ligne;
   float sh=(float)0., sb=(float)0.;
   double dSh, dSb;
   float shRed=(float)0., sbRed=(float)0.;
   float shGreen=(float)0., sbGreen=(float)0.;
   float shBlue=(float)0., sbBlue=(float)0.;
   int listArgc;
   int i;
   char **listArgv;
   CBuffer *buffer;
   CVisu *visu;
   CFitsKeywords *keywords;
   CFitsKeyword *kwd;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)&&(argc!=5)) {
      sprintf(ligne,"Usage: %s %s ?cut?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else {
      visu = (CVisu*)clientData;
      buffer = (CBuffer*)buf_pool->Chercher(visu->bufnum);

      if(buffer==NULL) {
         sprintf(ligne,"buf%d does not exist",visu->bufnum);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_ERROR;
      }

      keywords = buffer->GetKeywords();
      if(keywords==NULL) {
         sprintf(ligne,"buf%d is empty",visu->bufnum);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_ERROR;
      }

      if(argc==2) {
         // Il faut recuperer les mots cles qui sont dans l'entete FITS.
         if((kwd=keywords->FindKeyword("MIPS-HI"))!=NULL) sh = (Lut_Cut)(kwd->GetIntValue());
         else sh = (float)32767;
         if((kwd=keywords->FindKeyword("MIPS-LO"))!=NULL) sb = (Lut_Cut)(kwd->GetIntValue());
         else sb = (float)0;

         visu->SetGrayCuts(sh, sb);
      } else if(argc==3) {
         if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               sh = (float)dSh;
               sb = (float)dSb;
            }
            Tcl_Free((char*)listArgv);

            visu->SetGrayCuts(sh, sb);
         }

      } else if(argc==5) {
         if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Threshold struct not valid: must be { hicutRed locutRed } { hicutGreen locutGreen } { hicutBlue locutBlue }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Threshold struct not valid: must be { hicutRed locutRed }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_OK;
            } else {
               shRed = (float)dSh;
               sbRed = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
         }
         if(Tcl_SplitList(interp,argv[3],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               shGreen = (float)dSh;
               sbGreen = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
         }
         if(Tcl_SplitList(interp,argv[4],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_OK;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               shBlue = (float)dSh;
               sbBlue = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
         }

         visu->SetRgbCuts(shRed, sbRed, shGreen, sbGreen, shBlue, sbBlue);

      } else {
         // Ya un probleme
      }


      switch(i=visu->UpdateDisplay()) {
         case 0:
            break;
         case 1:
            sprintf(ligne,"buf%d does not exist (abnormal error)",visu->bufnum);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            break;
         case 2:
            sprintf(ligne,"buf%d is empty (abnormal error)",visu->bufnum);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            break;
         case 3:
            sprintf(ligne,"Can not find mandatory NAXIS1 FITS keyword");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            break;
         case 4:
            sprintf(ligne,"Can not find mandatory NAXIS2 FITS keyword");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            break;
         default:
            sprintf(ligne,"Error %d in UpdateDisplay",i);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            break;
      };
   }
   free(ligne);
   return TCL_OK;
}


int cmdVisuWindow(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CBuffer *buffer;
   CVisu *visu;
   int listArgc;
   int x1, y1, x2, y2, i;
   char **listArgv;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?window?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      if(visu->IsFull()==1) {
         sprintf(ligne,"full");
      } else {
         visu->GetWindow(&x1,&y1,&x2,&y2);
         sprintf(ligne,"%d %d %d %d",x1,y1,x2,y2);
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
         sprintf(ligne,"Window struct not valid: must be { x1 y1 x2 y2 } or full");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if(listArgc==1) {
            if(strcmp(listArgv[0],"full")!=0) {
               sprintf(ligne,"Window struct not valid: must be { x1 y1 x2 y2 } or full");
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               visu = (CVisu*)clientData;
               visu->SetWindowFull();
            }
         } else if(listArgc==4) {
            if(Tcl_GetInt(interp,listArgv[0],&x1)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\nx1 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else if(Tcl_GetInt(interp,listArgv[1],&y1)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\ny1 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else if(Tcl_GetInt(interp,listArgv[2],&x2)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\nx2 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else if(Tcl_GetInt(interp,listArgv[3],&y2)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\ny2 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               visu = (CVisu*)clientData;
               if(x1>x2) {
                  i = x2;
                  x2 = x1;
                  x1 = i;
               }
               if(y1>y2) {
                  i = y2;
                  y2 = y1;
                  y1 = i;
               }
               buffer = (CBuffer*)buf_pool->Chercher(visu->bufnum);
               int naxis1 = buffer->GetW();
               int naxis2 = buffer->GetH();
               if((x1>0)&&(x1<=naxis1)&&
                  (y1>0)&&(y1<=naxis2)&&
                  (x2>0)&&(x2<=naxis1)&&
                  (y2>0)&&(y2<=naxis2)) {
                  visu->SetWindow(x1,y1,x2,y2);
               } else {
                  sprintf(ligne,"Window not bound inside original picture");
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
            }
         } else {
            sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}/full\nneeds a 4 element list, or full",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
         Tcl_Free((char*)listArgv);
      }
   }
   free(ligne);
   return result;
}


int cmdVisuZoom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;
   double zoom;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?zoom?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      visu->GetZoom(&zoom);
      if (zoom<1.) {
         sprintf(ligne,"%f",zoom);
      } else {
         sprintf(ligne,"%d",int(zoom));
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetDouble(interp,argv[2],&zoom)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?zoom?\nzoom must be a double in range 0 to 4",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->SetZoom(zoom);
      }
   }
   free(ligne);
   return result;
}