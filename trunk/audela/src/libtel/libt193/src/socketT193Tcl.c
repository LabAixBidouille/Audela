/* telescop.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include "telescop.h"
#include "socketT193.h"
//#include <pthread.h>       // pcreate_thread()


#define DATA_SOCKET_SIZE 128
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

void mytel_processNotification(struct telprop *tel, char * notification);

void socket_readTelescopeNotificationSocket(ClientData clientData, int mask);

//void *socket_readTelescopeNotification(struct telprop *tel);


//////////////////////////////////////////////////////////////////////
//  gestion de TelescopeCommandSocket
/////////////////////////////////////////////////////////////////////


/**
 * socket_openTelescopeCommandSocket 
 *   ouvre la socket de commande de l'interface de controle du telescope
 * @param tel  
 * @param ethernetHost  
 * @param ethernetPort  
 * @return 0= OK ou 1=ERROR (voir le libelle de l'erreur dans tel->msg)
 */
int socket_openTelescopeCommandSocket(struct telprop *tel, char * ethernetHost, int ethernetPort) {
   int tclResult;
   
   // j'ouvre la socket client de commande vers le PC de controle du T193
   //  parametre 3 myhost = NULL  je laisse la fonction completer avec le nom local de la machine client
   //  parametre 4 myport = 0     je laisse la fonction generer le numero de port des reponses
   //  parametre 4 async  = 0     j'attends le resultat de la connexion 
   tel->telescopeCommandSocket = Tcl_OpenTcpClient(tel->interp, ethernetPort, ethernetHost, NULL, 0, 0) ;
   if ( tel->telescopeCommandSocket == NULL ) {
      sprintf(tel->msg,"Open ethernet connection error %d. %s", Tcl_GetErrno() , tel->interp->result);
      tclResult = TCL_ERROR;
   } else {
      tclResult = TCL_OK;
   }
   
   //fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeCommandSocket, "-buffering", "line");
      if ( tclResult == TCL_OK ) {
         if ( tclResult == TCL_ERROR ) {
            sprintf(tel->msg,"set channel option buffering error %d . %s", Tcl_GetErrno() , tel->interp->result);
         } 
      }      
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeCommandSocket, "-blocking", "true");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option blocking error %d . %s", Tcl_GetErrno() , tel->interp->result);
      }
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeCommandSocket, "-translation", "binary");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option translation error %d . %s", Tcl_GetErrno() , tel->interp->result);
      }
   }
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeCommandSocket, "-encoding", "binary");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option encoding error %d . %s", Tcl_GetErrno() , tel->interp->result);
      }
   }
   
   if ( tclResult == TCL_OK) {
      return 0;
   } else {
      return 1;
   }
   
}


/**
 * socket_closeTelescopeCommandSocket 
 *   ferme  la socket de commande de l'interface de controle du telescope
 * @param tel   structure contenant les attributs du telescope
 * @return 0= OK ou 1=ERROR Le libelle de l'erreur est dans tel->msg
 */
int socket_closeTelescopeCommandSocket(struct telprop *tel) {
   int tclResult;


   tclResult = Tcl_Close( tel->interp, tel->telescopeCommandSocket);
   tel->telescopeCommandSocket = NULL; 
   if ( tclResult != TCL_OK ) {
      sprintf(tel->msg,"Close telescope command socket error: %s", tel->interp->result);
   }

   if ( tclResult == TCL_OK) {
      return 0;
   } else {
      return 1;
   }
   
}



/**
 * socket_readTelescopeCommandSocket 
 *   traite la reponse recue sur la socket de commande du telescope
 * @param tel  
 * @return none
 */
int socket_readTelescopeCommandSocket(struct telprop *tel, char *response, int* len) {
   int tclResult; 

   Tcl_DString responseRead;
   Tcl_DStringInit(&responseRead);
   tclResult = Tcl_Gets(tel->telescopeCommandSocket, &responseRead);
   if ( tclResult != -1 ) {
      strcpy(response, Tcl_DStringValue(&responseRead));
      *len = tclResult;
   } else {
      sprintf(tel->msg,"read telescope command socket error: %s", tel->interp->result); 
      strcpy(response, "");
      *len = 0;
   }
   Tcl_DStringFree(&responseRead);

   
   return tclResult;
}

/**
 * socket_readTelescopeCommandSocket 
 *   envoit une commande sur la socket de commande du telescope
 * @param tel   commande  d'une structure telprop contenant les attributs du telescope 
 * @param command  commmande a envoyer
 * @param response reponse lue
 * @return 0= OK ou 1=ERROR Le libelle de l'erreur est dans tel->msg
 */
int socket_writeTelescopeCommandSocket(struct telprop *tel, char *command, char *response) {
   int tclResult; 
   int result; 

   tclResult = Tcl_WriteChars(tel->telescopeCommandSocket, command, strlen(command));
   if ( tclResult > -1 ) {
      result = 0;
   } else {
      sprintf(tel->msg,"write telescope command socket error: %s", tel->interp->result); 
      result = 1;
   }

   if ( Tcl_Flush(tel->telescopeCommandSocket) == TCL_ERROR ) {
      sprintf(tel->msg,"write telescope command socket error (flush): %s", tel->interp->result); 
      result = 1;
   }
   // je lis la reponse
   if ( result == 0 ) {
      Tcl_DString responseRead;
      Tcl_DStringInit(&responseRead);
      tclResult = Tcl_Gets(tel->telescopeCommandSocket, &responseRead);
      if ( tclResult != -1 ) {
         strcpy(response, Tcl_DStringValue(&responseRead));
         result = 0;
      } else {
         sprintf(tel->msg,"read telescope command socket error: %s", tel->interp->result); 
         strcpy(response, "");
         result = 1;
      }
      Tcl_DStringFree(&responseRead);
   }
   
   return result;
}



//////////////////////////////////////////////////////////////////////
//  gestion de TelescopeNotificationSocket
/////////////////////////////////////////////////////////////////////

/**
 * socket_openTelescopeNotificationSocket 
 *   ouvre la socket de commande de l'interface de controle du telescope
 *   la socket est ouverte en mode bloquant
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope
 * @param host  nom de host (adresse IP ou nom DNS)  
 * @param notificationSocketPort  port de la socket de reception des notifications 
 * @return 0= OK ou 1=ERROR Le libelle de l'erreur est dans tel->msg
 */
int socket_openTelescopeNotificationSocket(struct telprop *tel, char * host, int notificationSocketPort) {
   int tclResult;
   
   
   // j'ouvre la socket client de notification vers l'interface de contole du T193
   tel->telescopeNotificationSocket = Tcl_OpenTcpClient(tel->interp, notificationSocketPort, host, NULL, 0, 1) ;
   if ( tel->telescopeNotificationSocket == NULL ) {
      sprintf(tel->msg,"Open ethernet connection error %d. %s", Tcl_GetErrno() , tel->interp->result);
      tclResult = TCL_ERROR;
   } else {
      tclResult = TCL_OK;
   }
   
   //fconfigure $channel -buffering line -blocking true -translation binary -encoding binary
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeNotificationSocket, "-buffering", "line");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option buffering error %d . %s", Tcl_GetErrno() , tel->interp->result);
      } 
   }      
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeNotificationSocket, "-blocking", "true");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option blocking error %d . %s", Tcl_GetErrno() , tel->interp->result);
      }
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeNotificationSocket, "-translation", "binary");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option translation error %d . %s", Tcl_GetErrno() , tel->interp->result);
      }
   }
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, tel->telescopeNotificationSocket, "-encoding", "binary");
      if ( tclResult == TCL_ERROR ) {
         sprintf(tel->msg,"set channel option encoding error %d . %s", Tcl_GetErrno() , tel->interp->result);
      }
   }
   
   // je declarere la callback qui traite les notifications
   if ( tclResult == TCL_OK ) {
      Tcl_CreateChannelHandler(tel->telescopeNotificationSocket, TCL_READABLE, socket_readTelescopeNotificationSocket, tel);
   }

   
   return tclResult;
   
}


/**
 * socket_closeTelescopeNotificationSocket
 *   ferme socket notification de l'interface de controle du telescope
 * @param tel  structure contenant les attributs du telescope
 * @return 0= OK ou 1=ERROR (voir le libelle de l'erreur est dans tel->msg)
 */
int socket_closeTelescopeNotificationSocket(struct telprop *tel) {
   int tclResult;


   if ( tel->telescopeNotificationSocket != NULL) {
      Tcl_DeleteChannelHandler(tel->telescopeNotificationSocket, socket_readTelescopeNotificationSocket, tel);

      tclResult = Tcl_Close( tel->interp, tel->telescopeNotificationSocket);
      tel->telescopeNotificationSocket = NULL; 
      if ( tclResult != TCL_OK ) {
         sprintf(tel->msg,"Close telescope socket error: %s", tel->interp->result);
      }
   } else {
      tclResult = 0;
   }
   return tclResult;
}


/**
 * socket_readTelescopeNotificationSocket
 *   traite les notifications recues sur la socket notification de l'interface de controle du telescope
 * @param tel  
 * @return none
 */
void socket_readTelescopeNotificationSocket(ClientData clientData, int mask) {
   struct telprop *tel = (struct telprop *)clientData;
   int tclResult; 

   Tcl_DString lineRead;
   Tcl_DStringInit(&lineRead);
   tclResult = Tcl_Gets(tel->telescopeNotificationSocket, &lineRead);
   if ( tclResult != -1 ) {
      mytel_processNotification(tel, Tcl_DStringValue(&lineRead));
   }
   Tcl_DStringFree(&lineRead);


   return ;
}


//////////////////////////////////////////////////////////////////////
//  gestion de la thread de lecture des notifications 
/////////////////////////////////////////////////////////////////////

/**
 * socket_readTelescopeNotification
 *   traite les notifications recues sur la socket notification de l'interface de controle du telescope
 * @param tel  
 * @return none
 */
/*
void * socket_readTelescopeNotification(struct telprop *tel) {
   int tclResult;
   int result;
   Tcl_DString lineRead;
   int  nbArrayElements;
   char notifArray0[DATA_SOCKET_SIZE];
   char notifArray1[DATA_SOCKET_SIZE];
   char notifArray2[DATA_SOCKET_SIZE];
   char notifArray3[DATA_SOCKET_SIZE];
   char notifArray4[DATA_SOCKET_SIZE];
   char notifArray5[DATA_SOCKET_SIZE];
   
   Tcl_DStringInit(&lineRead);
    // j'ouvre la socket de lecture des donnees
   result = socket_openTelescopeNotificationSocket(tel, tel->telescopeHost, tel->telescopeNotificationPort);

   // je traite les notifications
   
   
   while (tel->telescopeNotificationSocket != NULL ) {
      tclResult = Tcl_Gets(tel->telescopeNotificationSocket, &lineRead);
      if ( tclResult != -1 ) {
         nbArrayElements = sscanf(Tcl_DStringValue(&lineRead), "!%s %s %s %s %s %s@", 
            notifArray0, notifArray1, notifArray2, notifArray3, notifArray4, notifArray5);

         if ( nbArrayElements < 2 ) {
            // 
            continue;
         }

         // je traite la notification
         if ( strcmp( notifArray0, "RADEC")==0 ) {
            //sprintf(command,"!RADEC STOP %c @\n", direction2 );
            if ( strcmp( notifArray1, "COORD")==0 ) {
            
            
            } else if ( strcmp( notifArray1, "COORD")==0 ) {

            }

         } else if ( strcmp( notifArray0 , "FOC")==0 ) {
            //strcpy(notification, Tcl_DStringValue(&lineRead));
         } else if ( strcmp( notifArray0 , "CLOSE_SOCKET")==0 ) {
            Tcl_Close(tel->interp, tel->telescopeNotificationSocket);
         }
         result = 0;
      } else {
         if ( Tcl_Eof(tel->telescopeNotificationSocket) != 0 ) {
            // la socket a ete fermee par le serveur , j'arrete la lecture
            break;
         } else {
            // j'envoi un message d'erreur pour tracer l'erreur imprevue.
         }
      }
      Tcl_DStringFree(&lineRead);

   }
   
   // j'attend que le mutex soir debloque par la thread principale pour fermer la socket 
   pthread_mutex_lock(&tel->mutex);
   socket_closeTelescopeNotificationSocket(tel);
   pthread_mutex_unlock(&tel->mutex);

   // je termine le thread
   return NULL;
}
*/


