/* coordserver.c
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
// Mise a jour $Id: coordserver.c,v 1.1 2009-12-08 22:56:13 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include "telescop.h"
#include "coordserver.h"


#define DATA_SOCKET_SIZE 128

void socket_acceptCoordServerSocket(ClientData clientData, Tcl_Channel channel, char *hostName, int port);
void socket_readTelescopeNotificationSocket(ClientData clientData, int mask);

#define MAX_CLIENT_COORD 10
Tcl_Channel clientCoordSocketList[MAX_CLIENT_COORD];

//////////////////////////////////////////////////////////////////////
//  gestion de coordServerSocket
/////////////////////////////////////////////////////////////////////


/**
 * socket_openCoordServerSocket 
 *   ouvre la socket de notification des coordonnees
 * @param tel  
 * @param ethernetHost  
 * @param ethernetPort  
 * @return 0= OK ou 1=ERROR (voir le libelle de l'erreur dans tel->msg)
 */
int socket_openCoordServerSocket(struct telprop *tel, int coordServerPort) {
   int tclResult;
   int index; 

   // j'intialise la liste des clients à vide 
   for(index = 0; index < MAX_CLIENT_COORD; index++ ) {
      clientCoordSocketList[index] = NULL;
   }
   
   // j'ouvre la socket client de notification vers les PC d'affichage des coordonnees
   //  parametre 1 interp      interpreteur TCP associe au telescope
   //  parametre 2 myport      port de reception des connexions des clients
   //  parametre 3 myapp       Nom du host client. If NULL the special address INADDR_ANY should be used to allow connections from any network interface
   //  parametre 4 proc        Pointer to a procedure to invoke each time a new connection is accepted via the socket. 
   //  parametre 5 ClientData  Arbitrary one-word value to pass to proc
   tel->telescopeCoordServerSocket = Tcl_OpenTcpServer(tel->interp, coordServerPort, NULL, socket_acceptCoordServerSocket, (ClientData) tel) ;
   if ( tel->telescopeCoordServerSocket == NULL ) {
      sprintf(tel->msg,"Open ethernet connection error %d. %s", Tcl_GetErrno() , tel->interp->result);
      tclResult = TCL_ERROR;
   } else {
      tclResult = TCL_OK;
   }
   
   if ( tclResult == TCL_OK) {
      return 0;
   } else {
      return 1;
   }
   
}


/**
 * socket_closeCoordServerSocket 
 *   ferme  la socket de notification des coordonnees
 * @param tel   structure contenant les attributs du telescope
 * @return 0= OK ou 1=ERROR Le libelle de l'erreur est dans tel->msg
 */
int socket_closeCoordServerSocket(struct telprop *tel) {
   int tclResult;
   int index;
   // je deconnecte le clients
   for( index=0; index < MAX_CLIENT_COORD; index++ ) {
      if ( clientCoordSocketList[index] != NULL ) {    
         Tcl_Close( tel->interp, clientCoordSocketList[index]);
         clientCoordSocketList[index] = NULL;
      }
   }

   // je ferme la socket de connexion du serveur
   tclResult = Tcl_Close( tel->interp, tel->telescopeCoordServerSocket);
   tel->telescopeCoordServerSocket = NULL; 
   if ( tclResult != TCL_OK ) {
      sprintf(tel->msg,"Close telescope coord socket error: %s", tel->interp->result);
   }

   if ( tclResult == TCL_OK) {
      return 0;
   } else {
      return 1;
   }
   
}

/**
 * socket_acceptCoordServerSocket 
 *   accepte la connexion d'un client
 * @param tel  
 * @return none
 */
void socket_acceptCoordServerSocket(ClientData clientData, Tcl_Channel clientSocket, char *hostName, int port) {
   int tclResult = TCL_OK; 
   struct telprop *tel = (struct telprop *) clientData;
   
   //  je configure la gestion des buffer -buffering none -blocking false -translation binary -encoding binary
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-buffering", "line");
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-blocking", "false");
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-translation", "binary");
   }
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-encoding", "binary");
   }
   
   if ( tclResult == TCL_OK ) {
      int index;
      // j'ajoute la socket dans la liste de clients à notifier 
      for( index=0; index < MAX_CLIENT_COORD; index++ ) {
         if ( clientCoordSocketList[index] == NULL ) {    
            clientCoordSocketList[index] = clientSocket;
            break;
         }
      }
      if ( index >= MAX_CLIENT_COORD ) {
         tclResult = TCL_ERROR;
      }

   }
   if ( tclResult == TCL_ERROR) {
      // je referme la socket du client
      Tcl_Close( tel->interp, tel->telescopeCommandSocket);
   }
}



/**
 * socket_writeCoordServerSocket 
 *   envoie la 
 * @param tel  
 * @return none
 */
void socket_writeCoordServerSocket(struct telprop *tel, char * notification) {
   int index;

   for( index=0; index < MAX_CLIENT_COORD; index++ ) {
      if ( clientCoordSocketList[index] != NULL ) { 
         int writeResult;
         writeResult = Tcl_WriteChars(clientCoordSocketList[index], notification, strlen(notification));
         if ( writeResult == -1) {
            Tcl_Close( tel->interp, clientCoordSocketList[index]);
            // je supprime la socket client de la liste            
            clientCoordSocketList[index] = NULL;
         } else {
            Tcl_Flush(clientCoordSocketList[index]);
         }
      }
   }
}
