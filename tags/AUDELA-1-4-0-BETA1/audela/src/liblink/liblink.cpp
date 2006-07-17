/* liblink.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

// $Id: liblink.cpp,v 1.1 2006-07-16 20:57:52 michelpujol Exp $


#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#if defined(_MSC_VER)
#include <sys/timeb.h>
#include <time.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <tcl.h>
#include "liblink/liblink.h"
#include "libname.h"
#include "linktcl.h"
//#include "link.h"

//  protype pour l'utilisation pour un programme C
#if defined(OS_WIN)
extern "C" int __cdecl LINK_ENTRYPOINT(Tcl_Interp * interp);
#else
extern "C" int LINK_ENTRYPOINT(Tcl_Interp * interp);
#endif

extern struct link_drv_t LINK_DRV;
extern struct linkini LINK_INI[];


/*
* Prototypes des differentes fonctions d'interface Tcl/Driver. Ajoutez les
* votres ici.
*/
/* === Common commands for all linkeras ===*/
static int cmdLinkCreate(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdLink(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdLinkDrivername(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
static int cmdLinkClose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#define COMMON_CMDLIST \
   {"drivername", (Tcl_CmdProc *)cmdLinkDrivername},\
   {"close", (Tcl_CmdProc *)cmdLinkClose}, \


static struct cmditem cmdlist[] = {
   /* === Common commands for all linkeras === */
   COMMON_CMDLIST
      /* === Specific commands for that linkera === */
   SPECIFIC_CMDLIST
      /* === Last function terminated by NULL pointers === */
   {NULL, NULL}
};

//static struct linkprop *linkprops = NULL;

#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4

static int debug_level = 4;

static void liblink_log(int level, const char *fmt, ...)
{
   va_list mkr;
   va_start(mkr, fmt);
   if (level <= debug_level) {
      switch (level) {
      case LOG_ERROR:
         printf("%s(%s) <ERROR> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      case LOG_WARNING:
         printf("%s(%s) <WARNING> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      case LOG_INFO:
         printf("%s(%s) <INFO> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      case LOG_DEBUG:
         printf("%s(%s) <DEBUG> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      }
      vprintf(fmt, mkr);
      printf("\n");
      va_end(mkr);
   }
}




/*
* Point d'entree de la librairie, appelle lors de la commande Tcl load.
*/
#if defined(OS_WIN)
int __cdecl LINK_ENTRYPOINT(Tcl_Interp * interp)
#else
int LINK_ENTRYPOINT(Tcl_Interp * interp)
#endif
{
   char s[256];
   struct cmditem *cmd;
   int i;
   
   liblink_log(LOG_INFO, "Calling entrypoint for driver %s", LINK_DRIVNAME);
   
   if (Tcl_InitStubs(interp, "8.3", 0) == NULL) {
      Tcl_SetResult(interp, "Tcl Stubs initialization failed in " LINK_LIBNAME " (" LINK_LIBVER ").", TCL_VOLATILE);
      liblink_log(LOG_ERROR, "Tcl Stubs initialization failed.");
      return TCL_ERROR;
   }
   
   liblink_log(LOG_DEBUG, "cmdLinkCreate = %p", cmdLinkCreate);
   liblink_log(LOG_DEBUG, "cmdLink = %p", cmdLink);
   
   Tcl_CreateCommand(interp, LINK_DRIVNAME, (Tcl_CmdProc *) cmdLinkCreate, NULL, NULL);
   Tcl_PkgProvide(interp, LINK_LIBNAME, LINK_LIBVER);
   
   for (i = 0, cmd = cmdlist; cmd->cmd != NULL; cmd++, i++);
   
#if defined(__BORLANDC__)
   sprintf(s, "Borland C (%s) ...nb commandes = %d", __DATE__, i);
#elif defined(OS_LIN)
   sprintf(s, "Linux (%s) ...nb commandes = %d", __DATE__, i);
#else
   sprintf(s, "VisualC (%s) ...nb commandes = %d", __DATE__, i);
#endif
   
   liblink_log(LOG_INFO, "Driver provides %d functions.", i);
   
   Tcl_SetResult(interp, s, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdLinkCreate(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   int result;
   char s[256];
   int linkno, err, i;
   CLink *link;
   
   if (argc < 2) {
      sprintf(s, "%s driver port ?options?", argv[0]);
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      return TCL_ERROR;
   } else if (argc == 2 && strcmp(argv[1], "available") ==0) {
      char * ligne = NULL;
      unsigned long numDevices;
      // ligne is allocated by listUsbIndex()
      if( available(&numDevices, &ligne) == LINK_OK) {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_OK;
      } else {
         result = TCL_ERROR;
      }
      free(ligne);
   } else {
      // On initialise la linkera sur le port. S'il y a une erreur, alors on
      // renvoie le message qui va bien, en supprimant la structure cree.
      // Si OK, la commande TCL est creee d'apres l'argv[1], et on garde
      // trace de la structure creee.
      
      fprintf(stderr, "%s(%s): LinkCreate(argc=%d", LINK_LIBNAME, LINK_LIBVER, argc);
      for (i = 0; i < argc; i++) {
         fprintf(stderr, ",argv[%d]=%s", i, argv[i]);
      }
      fprintf(stderr, ")\n");
      
      link = createLink();

      fprintf(stderr, "cmdLinkCreate after createLink()\n");
      
      Tcl_Eval(interp, "set ::tcl_platform(os)");
      strcpy(s, interp->result);
      if ((strcmp(s, "Windows 95") == 0)
         || (strcmp(s, "Windows 98") == 0)
         || (strcmp(s, "Linux") == 0)) {
         link->authorized = 1;
      } else {
         link->authorized = 0;
      }

      fprintf(stderr, "cmdLinkCreate after tcl_platform %s\n", s);
      
      link->interp = interp;
      sscanf(argv[1], "link%d", &linkno);
      link->linkno = linkno;
      strcpy(link->msg, "");
      fprintf(stderr, "cmdLinkCreate after linkno=%d\n", linkno);
      if ((err = link->init_common(argc, argv)) != 0) {
        fprintf(stderr, "cmdLinkCreate after init_common error \n");
         Tcl_SetResult(interp, link->msg, TCL_VOLATILE);
         free(link);
         result = TCL_ERROR;
      } else {
         fprintf(stderr, "cmdLinkCreate after init_common ok \n");
         if ((err = link->openLink(argc, argv)) != 0) {
            fprintf(stderr, "cmdLinkCreate after init error \n");
            Tcl_SetResult(interp, link->msg, TCL_VOLATILE);
            free(link);
            result = TCL_ERROR;
         } else {
            fprintf(stderr, "cmdLinkCreate after init ok \n");
            Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdLink, (ClientData) link, NULL);            
            fprintf(stderr, "cmdLinkCreate after Tcl_CreateCommand %s \n", argv[1]);
            liblink_log(LOG_DEBUG, "cmdLinkCreate: create link data at %p\n", link);
            result = TCL_OK;
         }
      }
   }      

   return result;
}

static int cmdLink(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char s[1024], ss[50];
   int retour = TCL_OK, k, i;
   struct cmditem *cmd;
   
   fprintf(stderr, "%s(%s): enter cmdLink(argc=%d", LINK_LIBNAME, LINK_LIBVER, argc);
   for (i = 0; i < argc; i++) {
      fprintf(stderr, ",argv[%d]=%s", i, argv[i]);
   }
   fprintf(stderr, ")\n");
   
   if (argc == 1) {
      sprintf(s, "%s choose sub-command among ", argv[0]);
      k = 0;
      while (cmdlist[k].cmd != NULL) {
         sprintf(ss, " %s", cmdlist[k].cmd);
         strcat(s, ss);
         k++;
      }
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      for (cmd = cmdlist; cmd->cmd != NULL; cmd++) {
         if (strcmp(cmd->cmd, argv[1]) == 0) {
            retour = (*cmd->func) (clientData, interp, argc, argv);
            break;
         }
      }
      if (cmd->cmd == NULL) {
         sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
         k = 0;
         while (cmdlist[k].cmd != NULL) {
            sprintf(ss, " %s", cmdlist[k].cmd);
            strcat(s, ss);
            k++;
         }
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}


static int cmdLinkDrivername(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   sprintf(ligne, "%s {%s}", LINK_DRIVNAME, __DATE__);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdLinkClose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   CLink * link = (CLink *) clientData;
   link->closeLink();
   Tcl_ResetResult(interp);
   return TCL_OK;
}

/*

static int cmdLinkIndex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[64];

   CLink * link = (CLink *) clientData;
   sprintf(ligne, "%d", link->index);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}
*/


CLink::~CLink()
{
}

int CLink::init_common(int argc, char **argv)
/* --------------------------------------------------------- */
/* --- link_init permet d'initialiser les variables de la --- */
/* --- structure 'linkprop'                               --- */
/* --------------------------------------------------------- */
/* argv[1] : symbole du port (link1,etc.)                    */
/* argv[2] : index                                           */
/* --------------------------------------------------------- */
{
   int result;
   //int k;
   //int kk;
   char *ligne;
   
   ligne = (char*)calloc(200,sizeof(char));
   if(argc>2) {     
      if(Tcl_GetInt(interp,argv[2],&index)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?index?\nindex = must be an integer 0 to 255",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         result = TCL_OK;   
      }
   } else {
         sprintf(ligne,"Usage: %s %s index" ,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
   }
   /* --- Decode les options de link::create en fonction de argv[>=3] --- */
   /*
   if (argc >= 5) {
      for (kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-name") == 0) {
            k = 0;
            while (strcmp(LINK_INI[k].name, "") != 0) {
               if (strcmp(LINK_INI[k].name, argv[kk + 1]) == 0) {
                  link->index_link = k;
                  break;
               }
               k++;
            }
         }
      }
   }*/

   free(ligne);

   return result;
}
