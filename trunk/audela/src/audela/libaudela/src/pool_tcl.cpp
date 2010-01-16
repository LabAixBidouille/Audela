/* pool_tcl.cpp
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

#include "libstd.h"
#include "cpool.h"
#include "cbuffer.h"

//------------------------------------------------------------------------------
// Commandes externes TCL pour gerer des listes de devices
//
int CmdCreatePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdListPoolItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdDeletePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdAvailablePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdGetGenericNamePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);


int CmdListPoolItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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

int CmdDeletePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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
         if ( strcmp(classname,"buf") != 0 ) {
            sprintf(ligne,"catch {%s%d close}",classname,numero);
            Tcl_Eval(interp,ligne);
            Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
         }
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

int CmdGetGenericNamePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result;
   char *ligne;
   CPool *pool;
   char*classname;
   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(200,sizeof(char));
   if(argc==2) {
      // chargement de la lib'argv[1]'
      sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"",audela_start_dir,argv[1]);
      if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
         sprintf(ligne,"Error: %s", interp->result);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_ERROR;
      } else {
         sprintf(ligne,"%s genericname",argv[1]);
         result = Tcl_Eval(interp,ligne);
      }
   } else {
      sprintf(ligne,"Usage: %s liblink_driver ?options?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   free(ligne);
   return result;
}

int CmdAvailablePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result;
   char *ligne;
   CPool *pool;
   char*classname;
   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(500,sizeof(char));
   if(argc==2) {
      // chargement de la lib'argv[1]'
      sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"",audela_start_dir,argv[1]);
      if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
         sprintf(ligne,"Error: %s", interp->result);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         sprintf(ligne,"%s available",argv[1]);
         Tcl_Eval(interp,ligne);
         result = TCL_OK;
      }
   } else {
      sprintf(ligne,"Usage: %s driver_name ?options?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   free(ligne);
   return result;
}



#define ENREGISTRER_CMD(cmd) {sprintf(ligne,"%s%d",classname,toto->no);\
 Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)(cmd),(ClientData)toto,(Tcl_CmdDeleteProc*)NULL);}

#define CASE_BUFFER    1
#define CASE_VISU      2
#define CASE_CAMERA    3
#define CASE_TELESCOPE 4
#define CASE_LINK      5

int CmdCreatePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char *ligne;
   CPool *pool;
   CDevice *toto=NULL;
   CBuffer *newBuffer;
   char *classname;
   int CASE=0;
   int dontCreateCommand = 0;
   int retour,kk;
   char s[256];

   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(1000,sizeof(char));
   strcpy(s,"");

   if(strcmp(classname,BUF_PREFIXE)==0)         CASE = CASE_BUFFER;
   //else if(strcmp(classname,VISU_PREFIXE)==0)   CASE = CASE_VISU;
   else if(strcmp(classname,CAM_PREFIXE)==0)    CASE = CASE_CAMERA;
   else if(strcmp(classname,TEL_PREFIXE)==0)    CASE = CASE_TELESCOPE;
   else if(strcmp(classname,LINK_PREFIXE)==0)   CASE = CASE_LINK;

   switch(CASE) {
      case CASE_BUFFER :
         if(argc>2) {
            sprintf(ligne,"Usage: %s ?%snum?",argv[0],classname);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            numero = 0;
            if((argc==2)&&(Tcl_GetInt(interp,argv[1],&numero)!=TCL_OK)) {
               sprintf(ligne,"Usage: %s ?%snum?\n%snum must be an integer > 0",argv[0],classname,classname);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            }
            newBuffer = new CBuffer();
            toto = pool->Ajouter(numero,newBuffer);
            if(toto) ENREGISTRER_CMD(CmdBuf);
         }
         break;
      case CASE_CAMERA :
         if(argc<2) {
            sprintf(ligne,"Usage: %s libcam_driver ?options?",argv[0]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            // chargement de la lib'argv[1]'
            sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"",audela_start_dir,argv[1]);
            if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
               sprintf(ligne,"Usage: %s libcam_driver ?options?",argv[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   	         free(ligne);
               return TCL_ERROR;
            }
            // Lecture du numero de camera voulu
            numero = 0;
	         if (argc>=5) {
		         for (kk=3;kk<argc-1;kk++) {
			         if (strcmp(argv[kk],"-num")==0) {
			            numero=(int)atoi(argv[kk+1]);
                     if (numero<1) { numero=1; }
                  }
               }
            }
            // Instancie de l'objet en fonction de la camera demandee
            toto = new CDevice();
            pool->Ajouter(numero,toto);
            dontCreateCommand = 1;
            // Cree la nouvelle commande par le biais de l'unique
            // commande exportee de la librairie libcam.
            sprintf(ligne,"%s cam%d %s ",argv[1],toto->no,argv[2]);
            for (kk=0;kk<argc;kk++) {
               strcat(ligne,argv[kk]);
               strcat(ligne," ");
            }
            if (Tcl_Eval(interp,ligne)==TCL_OK) {
               sprintf(ligne,"cam%d channel",toto->no);
               if (Tcl_Eval(interp,ligne)==TCL_OK) {
                  strcpy(toto->channel,interp->result);
               } else {
                  strcpy(toto->channel,"");
               }
               break;
            } else {
               strcpy(s,interp->result);
               sprintf(ligne,"::cam::delete %d",toto->no);
               Tcl_Eval(interp,ligne);
               toto=NULL;
               break;
            }
            // Enregistrement de la commande dans TCL si objet cree
//            if((toto!=NULL)&&(dontCreateCommand==0)) ENREGISTRER_CMD(CmdCam);
         }
         break;
      case CASE_TELESCOPE :
         if(argc<3) {
            sprintf(ligne,"Usage: %s libtel_driver ?options?",argv[0]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            // chargement de la lib'argv[1]'
            sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"",audela_start_dir,argv[1]);
            if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
               sprintf(ligne,"Error: %s \nUsage: %s libtel_driver ?options?",interp->result, argv[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            }
            // Lecture du numero de telescope voulu
            numero = 0;
	         if (argc>=5) {
		         for (kk=3;kk<argc-1;kk++) {
			         if (strcmp(argv[kk],"-num")==0) {
			            numero=(int)atoi(argv[kk+1]);
                     if (numero<1) { numero=1; }
                  }
               }
            }
            // Instancie de l'objet en fonction du telescope demande
            toto = new CDevice();
            pool->Ajouter(numero,toto);
            dontCreateCommand = 1;
            // Cree la nouvelle commande par le biais de l'unique
            // commande exportee de la librairie libtel.
            sprintf(ligne,"%s tel%d %s ",argv[1],toto->no,argv[2]);
            for (kk=0;kk<argc;kk++) {
               strcat(ligne,argv[kk]);
               strcat(ligne," ");
            }
            if (Tcl_Eval(interp,ligne)==TCL_OK) {
               sprintf(ligne,"tel%d channel",toto->no);
               if (Tcl_Eval(interp,ligne)==TCL_OK) {
                  strcpy(toto->channel,interp->result);
               } else {
                  strcpy(toto->channel,"");
               }
               break;
            } else {
               strcpy(s,interp->result);
               sprintf(ligne,"::tel::delete %d",toto->no);
               Tcl_Eval(interp,ligne);
               toto=NULL;
               break;
            }
            // Enregistrement de la commande dans TCL si objet cree
  //          if((toto!=NULL)&&(dontCreateCommand==0)) ENREGISTRER_CMD(CmdTel);
         }
      case CASE_LINK :
         if(argc<3) {
            sprintf(ligne,"Usage: %s liblink_driver ?options?",argv[0]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            // chargement de la lib'argv[1]'
            sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"",audela_start_dir,argv[1]);
            if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
               sprintf(ligne,"Error: %s", interp->result);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               char temp_drivername[64];
               char temp_index[64];
               int linkNo = 1 ;

               // je cherche si le link est deja cree (meme drivername et meme index)
               toto = ((CPool*)clientData)->dev;

               while(toto) {
                  sprintf(ligne,"lindex [::link%d drivername] 0",toto->no);
                  if (Tcl_Eval(interp,ligne)==TCL_OK) {
                     // interp->result contient l'index du link existant
                     strcpy(temp_drivername, interp->result);
                     sprintf(ligne,"::link%d index",toto->no);
                     if (Tcl_Eval(interp,ligne)==TCL_OK) {
                        // interp->result contient l'index du link existant
                        strcpy(temp_index, interp->result);

                        if( strcmp(argv[1], temp_drivername)==0 && strcmp(argv[2], temp_index)==0 ) {
                           // le link existe deja , je retourne son numero
                           sprintf(ligne,"%d", toto->no);
                           Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                           free(ligne);
                           return TCL_OK;
                        }
                     }
                  }
                  toto = toto->next;
               }

               // je cherche le premier numero de link libre (certains link peuvent etre cree en TCL)
               while( 1 ) {
                  sprintf(ligne,"lindex [::link%d drivername] 0",linkNo);
                  if (Tcl_Eval(interp,ligne)==TCL_ERROR ) {
                     // le link n'existe pas , je vais utiliser ce numero
                     break;
                  }
                  linkNo += 1;
               }

               // Instancie de l'objet en fonction du link demande
               toto = new CDevice();
               pool->Ajouter(linkNo,toto);
               dontCreateCommand = 1;
               // Cree la nouvelle commande par le biais de l'unique
               // commande exportee de la librairie liblink.
               sprintf(ligne,"%s link%d %s ",argv[1],toto->no,argv[2]);
               for (kk=0;kk<argc;kk++) {
                  strcat(ligne,argv[kk]);
                  strcat(ligne," ");
               }
               if (Tcl_Eval(interp,ligne)==TCL_OK) {
                  sprintf(ligne,"link%d channel",toto->no);
                  if (Tcl_Eval(interp,ligne)==TCL_OK) {
                     strcpy(toto->channel,interp->result);
                  } else {
                     strcpy(toto->channel,"");
                  }
                  break;
               } else {
                  strcpy(s,interp->result);
                  sprintf(ligne,"::link::delete %d",toto->no);
                  Tcl_Eval(interp,ligne);
                  toto=NULL;
                  break;
               }
            }
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
#undef AJOUTER
#undef ENREGISTRER_CMD
