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

#include <stdlib.h>
#include <string.h>
#include <tk.h>
#include "sysexp.h"  // pour LIBRARY_DLL , LIBRARY_SO
#include "cpool.h"
#include "cbuffer.h"
#include "cvisu.h"

extern "C" int Tkimgvideo_Init(Tcl_Interp *interp);

#define VISU_PREFIXE "visu"

//------------------------------------------------------------------------------
// La variable globale est definie de maniere unique ici.
//
//  pool de visu
CPool *visu_pool;


//------------------------------------------------------------------------------
// fonction pour gerer le pool de visu

int CmdCreateVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdListVisuItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdDeleteVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

//------------------------------------------------------------------------------
// fonction point d'entree pour gerer les commandes d'une visu
//

extern int CmdVisu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);


#if defined(OS_WIN)
extern "C" int __cdecl Audelatk_Init(Tcl_Interp *interp)
#else
extern "C" int Audelatk_Init(Tcl_Interp *interp)
#endif
{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      return TCL_ERROR;
   }
   if(Tk_InitStubs(interp,(char*)"8.3",0)==NULL) {
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"libaudelatk","1.0");
   visu_pool = new CPool(VISU_PREFIXE);
   Tcl_CreateCommand(interp,"::visu::create",(Tcl_CmdProc *)CmdCreateVisuItem,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::list",  (Tcl_CmdProc *)CmdListVisuItems,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::delete",(Tcl_CmdProc *)CmdDeleteVisuItem,(void*)visu_pool,NULL);

#if defined(WIN32)
   // create image type for video (webcam and video recorder)
   Tkimgvideo_Init(interp);
#endif
   return TCL_OK;
}


int CmdListVisuItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   CDevice *device;
   char *ligne;
   char item[10];

   device = ((CPool*)clientData)->dev;
   ligne = (char*)calloc(200,sizeof(char));
   strcpy(ligne,"");
   if(argc==1) {
      while(device) {
         sprintf(item,"%d ",device->no);
         strcat(ligne,item);
         device = device->next;
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      sprintf(ligne,"Usage: %s",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   free(ligne);
   return TCL_OK;
}

int CmdDeleteVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char *ligne;
   CPool *pool;
   CDevice *toto;
   char*classname;
   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(200,sizeof(char));
   if(argc==2) {
      if(Tcl_GetInt(interp,argv[1],&numero)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %snum\n%snum must be an integer",argv[0],classname,classname);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_OK;
      }
      toto = pool->Chercher(numero);
      if(toto) {
         sprintf(ligne,"catch {%s%d close}",classname,numero);
         Tcl_Eval(interp,ligne);
         Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
         pool->RetirerDev(toto);
         sprintf(ligne,"%s%d",classname,numero);
			Tcl_DeleteCommand(interp,ligne);
      } else {
         sprintf(ligne,"%s%d does not exist.",classname,numero);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   } else {
      sprintf(ligne,"Usage: %s %snum",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   free(ligne);
   return TCL_OK;
}


int CmdCreateVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char *ligne;
   CPool *pool;
   CDevice *toto=NULL;
   char *classname;
   int bufno = 1;
   int imgno = 1;
   char s[256];
   int retour;

   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(1000,sizeof(char));
   strcpy(s,"");


   if((argc<3)||(argc>4)) {
      sprintf(ligne,"Usage: %s bufno imgno ?%snum?",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else if(Tcl_GetInt(interp,argv[1],&bufno)!=TCL_OK) {
      sprintf(ligne,"Usage: %s bufno imgno ?%snum?\nbufno must be an integer > 0",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else if(Tcl_GetInt(interp,argv[2],&imgno)!=TCL_OK) {
      sprintf(ligne,"Usage: %s bufno imgno ?%snum?\nimgno must be an integer > 0",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else {
      numero = 0;
      if((argc==4)&&(Tcl_GetInt(interp,argv[3],&numero)!=TCL_OK)) {
         sprintf(ligne,"Usage: %s bufno imgno ?%snum?\n%snum must be an integer > 0",argv[0],classname,classname);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_ERROR;
      }
      toto = visu_pool->Ajouter(numero,new CVisu(interp,bufno,imgno));
      if(toto) {
         sprintf(ligne,"%s%d",classname,toto->no);
         Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)(CmdVisu),(ClientData)toto,(Tcl_CmdDeleteProc*)NULL);
      }
   }

   // termine la creation de l'objet.
   if(toto) {
      sprintf(ligne,"%d",toto->no);
      retour = TCL_OK;
   } else {
      sprintf(ligne,"Could not create the %s.\n%s",classname,s);
      retour = TCL_ERROR;
   }
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);

   free(ligne);
   return retour;
}

