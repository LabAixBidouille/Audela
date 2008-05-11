/* teltcl.h
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

/*
 * teltcl.c
 *
 * Fonctions C-Tcl specifiques a ce telescope. A programmer.
 *
 * $Id: teltcl.c,v 1.4 2008-05-11 12:46:11 jacquesmichelet Exp $
 *
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#if defined(OS_LIN)
#include <unistd.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "telescop.h"
#include <libtel/libtel.h>
#include "teltcl.h"
#include <libtel/util.h>
#include "setip.h"

/*
 *   structure pour les fonctions étendues
 */
char *tel_longformat[] = {
   "on",
   "off",
   NULL
};


#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0


int cmdTelLongFormat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0,comok=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      comok=1;
      pb=0;
   } else {
      if (strcmp(argv[2],tel_longformat[0])==0) {
         tel->longformatindex=0;
         comok=mytel_set_format(tel,tel->longformatindex);
         pb=0;
      } else if (strcmp(argv[2],tel_longformat[1])==0) {
         tel->longformatindex=1;
         comok=mytel_set_format(tel,tel->longformatindex);
         pb=0;
      } else {
         pb=1;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s %s|%s",argv[0],argv[1],tel_longformat[0],tel_longformat[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      if (comok==0) {
         Tcl_SetResult(interp,"-1",TCL_VOLATILE);
      } else {
         if (tel->longformatindex==0) {
            sprintf(ligne,"%s",tel_longformat[0]);
         } else if (tel->longformatindex==1) {
            sprintf(ligne,"%s",tel_longformat[1]);
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      tel->tempo=(int)fabs((double)atoi(argv[2]));
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?ms?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->tempo);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/**
 * cmdTelAutoFlush
 *   set tel->autoflush value (0= no flush, 1= do flush)
 */
int cmdTelAutoFlush(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      if( atoi(argv[2]) == 1 ) {
         tel->autoflush= TRUE;
      }
      else {
         tel->autoflush= FALSE;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s 0|1",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->tempo);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdHost()
 *
 * Change or returns the IP host
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelHost(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      STRNCPY(tel->host, argv[2] );
      pb=0;
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?host?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      sprintf(ligne,"%s",tel->host);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}



/*
 * -----------------------------------------------------------------------------
 *  cmdSetIP()
 *
 *  Envoie une nouvelle adresse IP à l'interface Audinet ayant l'adresse MAC specifiee
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelSetIP(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char errorMessage[256];
   int result = TCL_OK;
   char macAddress[20];
   char ipAddress[20];
   char networkmask[20];
   char gateway[20];


   if((argc<4)) {
      sprintf(errorMessage,"Usage: %s %s ?macaddress? ?ipaddress? [?networkmask? ?gateway?]",argv[0],argv[1]);
      Tcl_SetResult(interp,errorMessage,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {

      STRNCPY(macAddress, argv[2] );
      STRNCPY(ipAddress, argv[3] );
      if( argc >= 5) {
         STRNCPY(networkmask, argv[4] );
         STRNCPY(gateway, argv[5] );
         result = setip(ipAddress, macAddress, networkmask, gateway, errorMessage);
      }
      else {
         result = setip(ipAddress, macAddress, NULL, NULL, errorMessage);
      }

      if ( result == 0 ) {
         sprintf(errorMessage, "setip %s OK", ipAddress);
         // j'attends une seconde pour laisser Audinet prendre en compte le changement d'adresse
         #if defined(OS_WIN)
	         Sleep(1000);
         #endif
         #if defined(OS_LIN)
	         sleep(1);
         #endif
         result = TCL_OK;
      } else {
         sprintf(errorMessage, "ERROR setip ipadress=%s macadress=%s ", ipAddress, macAddress);
         result = TCL_ERROR;
      }
      Tcl_SetResult(interp, errorMessage,TCL_VOLATILE);
   }
   return result;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdTelSendCommand()
 *
 *  envoie une commande qu
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelSendCommand(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result;
   char *usage= "Usage: %s %s command ?command? ?returnType:none|ok|sharp?";
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if(argc!=4) {
      sprintf(ligne,usage,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      int returnType = -1;

      if ( strcmp(argv[3],"none")==0) {
         returnType =0;
      } else if (strcmp(argv[3],"ok")==0) {
         returnType =1;
      } else if (strcmp(argv[3],"sharp")==0) {
         returnType =2;
      }

      if (returnType == -1 ) {
         sprintf(ligne,"%s . Error: bad return type %s ",usage, argv[3]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         int result;
         char response[1024];
         result = mytel_sendLX(tel, argv[2], returnType, response);
         if ( result == 1 ) {
            Tcl_SetResult(interp,(char*)response,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            // le libelle de l'erreur est dans le parametre response
            Tcl_SetResult(interp,(char*)response,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      }
   }
   return result;
}


