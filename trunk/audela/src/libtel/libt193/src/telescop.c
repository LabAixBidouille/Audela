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

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <sys/timeb.h>		// pour timer 
#include <pthread.h>       // pcreate_thread()

#include <stdio.h>
#include <NIDAQmx.h>       // API pour driver NI-DAQmx (National Intrument)
#include "telescop.h"
#include "socketT193.h"




#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

#define NOTIFICATION_MAX_SIZE 128
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"T193",    /* telescope name */
    "t193",    /* protocol name */
    "t193",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
  	 1.        /* default focal lenght of optic system */
   },
};

// variables locales
 

// fonctions locales
void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) ;
int mytel_readUsbCard(struct telprop *tel, unsigned char *notification);
int mytel_getBit(struct telprop *tel, unsigned char notification, int numbit);
void mytel_startTimer(struct telprop *tel);
double mytel_getTimer(struct telprop *tel);
double mytel_stopTimer(struct telprop *tel);
int mytel_sendUsbCommandTelescop(struct telprop *tel, int command);
int mytel_sendCommandFilter(struct telprop *tel, int command);

int mytel_setRadecNotification(struct telprop *tel, int mode);
int mytel_setFocusNotification(struct telprop *tel, int mode);
void mytel_processNotification(struct telprop *tel, char * notification);

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{

   int         error=0;
	uInt32      notification=0xffffffff;
   char        hpcom[128]={'\0'};
   char        usbCardName[128]     ="Dev1";    // ces valeurs par defaut seront ecras�es par les param�tres optionels
   char        usbTelescopPort[128] ="port0";
   char        usbFilterPort[128]   ="port1";
   int         i;
   int         result = 0;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   int k;
   FILE *flog;
   flog=fopen("mouchard_protocole_T193.txt","wt");
   fclose(flog);

   // j'intialise les variables
   strcpy(tel->channel , "");
   tel->outputTelescopTaskHandle = 0;
   tel->outputFilterTaskHandle = 0;
   tel->inputFilterTaskHandle = 0;   
   tel->outputTelescopNotification = 255;
   tel->outputFilterNotification = 255;
   tel->consoleLog = 0;    
   tel->filterMaxDelay = 10;  
   tel->filterCurrentDelay = 0; 
   tel->startTime = 0.0;
   tel->filterCommand = -1;   // L'indicateur de mouvement du filtre vaut :
                              //    -1=pas de mouvement en cours, 
                              //    tel->decreaseFilterRelay = mouvement "-" en cours
                              //    tel->increaseFilterRelay = mouvement "+" en cours

   tel->northRelay         = 0;
   tel->southRelay         = 1;
   tel->estRelay           = 2;
   tel->westRelay          = 3;
   tel->enabledRelay       = 4;
   tel->decreaseFilterRelay = 0;
   tel->increaseFilterRelay = 1;
   tel->minDetectorFilterInput = 2;
   tel->minDetectorFilterInput = 3;

   tel->telescopeCommandSocket = NULL;
   tel->telescopeNotificationSocket = NULL;
   tel->telescopeNotificationThread = NULL;
   strcpy(tel->telescopeHost,"");
   tel->telescopeCommandPort = 0;
   tel->telescopeNotificationPort = 0;

   strcpy(tel->ra,"00h00m00.00s"); 
   strcpy(tel->dec, "+00d00m00.00s"); 
   //tel->radecNotification = 0;
   tel->radec_motor = 0; 
   tel->radecIsMoving = 0;
   tel->focus_goto_blocking = 0;

   // je lis les parametres optionels
   for (i=3;i<argc-1;i++) {
	   if (strcmp(argv[i],"-hpcom")==0) {
			   strcpy(hpcom, argv[i+1]);
      }
	   if (strcmp(argv[i],"-usbCardName")==0) {
			   strcpy(usbCardName, argv[i+1]);
		}
	   if (strcmp(argv[i],"-usbTelescopPort")==0) {
			   strcpy(usbTelescopPort, argv[i+1]);
		}
	   if (strcmp(argv[i],"-usbFilterPort")==0) {
			   strcpy(usbFilterPort, argv[i+1]);
		}
	   if (strcmp(argv[i],"-northRelay")==0) {
         tel->northRelay = atoi(argv[i+1]); 
         if ( tel->northRelay < 0 && tel->northRelay > 7 ) {
            sprintf(tel->msg,"northRelay=%d Must be beetween 0 and 7", tel->northRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-southRelay")==0) {
         tel->southRelay = atoi(argv[i+1]); 
         if ( tel->southRelay < 0 && tel->southRelay > 7 ) {
            sprintf(tel->msg,"southRelay=%d Must be beetween 0 and 7", tel->southRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-estRelay")==0) {
         tel->estRelay = atoi(argv[i+1]); 
         if ( tel->estRelay < 0 && tel->estRelay > 7 ) {
            sprintf(tel->msg,"estRelay=%d Must be beetween 0 and 7", tel->estRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-westRelay")==0) {
         tel->westRelay = atoi(argv[i+1]); 
         if ( tel->westRelay < 0 && tel->westRelay > 7 ) {
            sprintf(tel->msg,"westRelay=%d Must be beetween 0 and 7", tel->westRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-enabledRelay")==0) {
         tel->enabledRelay = atoi(argv[i+1]); 
         if ( tel->enabledRelay < 0 && tel->enabledRelay > 7 ) {
            sprintf(tel->msg,"enabledRelay=%d Must be beetween 0 and 7", tel->enabledRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-decreaseFilterRelay")==0) {
         tel->decreaseFilterRelay = atoi(argv[i+1]); 
         if ( tel->decreaseFilterRelay < 0 && tel->decreaseFilterRelay > 7 ) {
            sprintf(tel->msg,"decreaseFilterRelay=%d Must be beetween 0 and 7", tel->decreaseFilterRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-increaseFilterRelay")==0) {
         tel->increaseFilterRelay = atoi(argv[i+1]); 
         if ( tel->increaseFilterRelay < 0 && tel->increaseFilterRelay > 7 ) {
            sprintf(tel->msg,"increaseFilterRelay=%d Must be beetween 0 and 7", tel->increaseFilterRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-minDetectorFilterInput")==0) {
         tel->minDetectorFilterInput = atoi(argv[i+1]); 
         if ( tel->minDetectorFilterInput < 0 && tel->minDetectorFilterInput > 7 ) {
            sprintf(tel->msg,"minDetectorFilterInput=%d Must be beetween 0 and 7", tel->minDetectorFilterInput );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-maxDetectorFilterInput")==0) {
         tel->maxDetectorFilterInput = atoi(argv[i+1]); 
         if ( tel->maxDetectorFilterInput < 0 && tel->maxDetectorFilterInput > 7 ) {
            sprintf(tel->msg,"maxDetectorFilterInput=%d Must be beetween 0 and 7", tel->maxDetectorFilterInput );
            return 1;
         }
      }

	   if (strcmp(argv[i],"-filterMaxDelay")==0) {
         tel_filter_setMax(tel,atof(argv[i+1])); 
      }
  	   if (strcmp(argv[i],"-ethernetHost")==0) {
	      strcpy(tel->telescopeHost, argv[i+1]);
         if ( strlen(tel->telescopeHost) == 0 ) {
            sprintf(tel->msg,"telescopeHost=%s is empty", tel->telescopeHost );
            return 1;
         }
      }
  	   if (strcmp(argv[i],"-telescopeCommandPort")==0) {
	      tel->telescopeCommandPort = atoi(argv[i+1]);
         if ( tel->telescopeCommandPort == 0 ) {
            sprintf(tel->msg,"telescopeCommandPort=%d is null", tel->telescopeCommandPort );
            return 1;
         }
      }
  	   if (strcmp(argv[i],"-telescopeNotificationPort")==0) {
	      tel->telescopeNotificationPort = atoi(argv[i+1]);
         if ( tel->telescopeNotificationPort == 0 ) {
            sprintf(tel->msg,"telescopeNotificationPort=%d is null", tel->telescopeNotificationPort );
            return 1;
         }
      }

   }

   if ( result == 1 ) {
      // j'arrete l'init s'il y a eu une erreur
      return 1;
   }

   // argv2 contient le type de connexion du telescope HP1000 ou PC 
   if ( strcmp(argv[2], "HP1000") == 0 ) {
      if ( strcmp(usbCardName, "simulation") !=  0 ) {
         //DAQmxGetSysDevNames

         // je verifie que la carte est presente 
         if( ! DAQmxFailed(error) ) {
	         error = DAQmxSelfTestDevice(usbCardName);
         }

	      // J'ouvre la connexion de la carte USB-6501
         // je cree la tache du telescope en ecriture
         if( ! DAQmxFailed(error) ) {
	         error = DAQmxCreateTask("",&tel->outputTelescopTaskHandle);
         }

         if( ! DAQmxFailed(error) ) {
            char lines[256];

            sprintf(lines, "%s/%s/line%d, %s/%s/line%d, %s/%s/line%d, %s/%s/line%d, %s/%s/line%d",
                 usbCardName,usbTelescopPort, tel->northRelay,
                 usbCardName,usbTelescopPort, tel->southRelay,
                 usbCardName,usbTelescopPort, tel->estRelay,
                 usbCardName,usbTelescopPort, tel->westRelay,
                 usbCardName,usbTelescopPort, tel->enabledRelay);
	         error = DAQmxCreateDOChan(tel->outputTelescopTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
         }

         // je cree la tache de l'attenuateur en ecriture
         if( ! DAQmxFailed(error) ) {
   	      error = DAQmxCreateTask("",&tel->outputFilterTaskHandle);
         }
         if( ! DAQmxFailed(error) ) {
            char lines[256];

            sprintf(lines, "%s/%s/line%d, %s/%s/line%d",
                 usbCardName,usbFilterPort, tel->decreaseFilterRelay,
                 usbCardName,usbFilterPort, tel->increaseFilterRelay);
	         error = DAQmxCreateDOChan(tel->outputFilterTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
         }

         // je cree la tache de l'attenuateur en lecture
         if( ! DAQmxFailed(error) ) {
            // je cree la tache de lecture 
   	      error = DAQmxCreateTask("",&tel->inputFilterTaskHandle);
         }

         if( ! DAQmxFailed(error) ) {
            char lines[256];
            // je cr�e le canal en lecture
            sprintf(lines, "%s/%s/line%d, %s/%s/line%d",
                 usbCardName,usbFilterPort, tel->minDetectorFilterInput,
                 usbCardName,usbFilterPort, tel->maxDetectorFilterInput);
	         error = DAQmxCreateDIChan(tel->inputFilterTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
         }
         
         // je demarre les taches
         if( ! DAQmxFailed(error) ) {
	         error = DAQmxStartTask(tel->outputTelescopTaskHandle);
         }
         // je demarre les taches
         if( ! DAQmxFailed(error) ) {
	         error = DAQmxStartTask(tel->outputFilterTaskHandle);
         }
         if( ! DAQmxFailed(error) ) {
	         // je demarre la tache de lecture
	         error = DAQmxStartTask(tel->inputFilterTaskHandle);
         }
         if( ! DAQmxFailed(error) ) {

            //  je met tous les bits � 1 (position de repos de la commande du t�lescope) 
            tel->outputTelescopNotification = 255;
            result = mytel_sendUsbCommandTelescop(tel , tel->outputTelescopNotification);

            //  je met tous les bits � 1 (position de repos de la commande de l'attenuateur) 
            tel->outputFilterNotification = 255;
            result = mytel_sendCommandFilter(tel , tel->outputFilterNotification);
         } else {
            char errBuff[2001]={'\0'};
            // je recupere le message d'erreur
		      //DAQmxGetExtendedErrorInfo(errBuff,2000);
            DAQmxGetErrorString(error, errBuff, 2000);
            //sprintf(tel->msg, "DAQmx error %d", error);
            sprintf(tel->msg, "Device=%s %s",usbCardName, errBuff) ;
            result = 1;
         } 

      } else {
         //simulation de la carte USB
         mytel_logConsole(tel, "simul open %s OK",usbCardName);
      }

      if ( result == 1 ) {
         // j'arrete l'init s'il y a eu une erreur
   	   tel_close(tel);
         return 1;
      }

 
      // j'ouvre la connexion avec le port serie du HP1000 pour la reception des ccordonnees
      if ( strlen(hpcom) > 0 ) {
         strcpy(ss,hpcom);
         sprintf(s,"string range [string toupper %s] 0 2",ss);
         Tcl_Eval(tel->interp,s);
         strcpy(s,tel->interp->result);
         if (strcmp(s,"COM")==0) {
            sprintf(s,"string range [string toupper %s] 3 end",ss);
            Tcl_Eval(tel->interp,s);
            strcpy(s,tel->interp->result);
            k=(int)atoi(s);
            Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
            strcpy(s,tel->interp->result);
            if (strcmp(s,"Linux")==0) {
               sprintf(ss,"/dev/ttyS%d",k-1);
               sprintf(ssusb,"/dev/ttyUSB%d",k-1);
            }
         }
         /* --- open the port and record the channel name ---*/
         sprintf(s,"open \"%s\" r+",ss);
         if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
            strcpy(ssres,tel->interp->result);
            Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
            strcpy(ss,tel->interp->result);
            if (strcmp(ss,"Linux")==0) {
               /* if ttyS not found, we test ttyUSB */
               sprintf(ss,"open \"%s\" r+",ssusb);
               if (Tcl_Eval(tel->interp,ss)!=TCL_OK) {
                  strcpy(tel->msg,tel->interp->result);
                  result = 1;
               }
            } else {
               strcpy(tel->msg,ssres);
               result = 1;
            }
         }
         strcpy(tel->channel,tel->interp->result);
         
         // je lance la boucle de lecture permanente des coordonn�es
      
         /*
         # 19200 : vitesse de transmission (bauds)
         # 0 : 0 bit de parit�
         # 8 : 8 bits de donn�es
         # 1 : 1 bits de stop
         */
         sprintf(s,"fconfigure %s -mode \"19200,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); 
         mytel_tcleval(tel,s);
      }
   } else if ( strcmp(argv[2], "ETHERNET") == 0 ) { 
      
      // j'ouvre la socket de commande du telescope
      result = socket_openTelescopeCommandSocket(tel, tel->telescopeHost, tel->telescopeCommandPort);
      
      // j'ouvre la socket de notification du telescope
      if ( result == 0 ) {
         result = socket_openTelescopeNotificationSocket(tel, tel->telescopeHost, tel->telescopeNotificationPort);
      }
      
      
      // je demande a recevoir les coordonnees en permanence 
      if ( result == 0 ) {         
         result = mytel_setRadecNotification(tel, 1);
      }
      
      // j'active le suivi
      if ( result == 0 ) {
         // attention, il faut mettre 0 tel->radec_motor pour activer le suici
         tel->radec_motor = 0;
         result = tel_radec_motor(tel);
      }

   } else {
      sprintf(tel->msg,"Invalid connection mode %s", argv[2]);
      result = 1;
   }

   if ( result == 1 ) {
      // s'il y a eu une erreur, je ferme tout 
   	tel_close(tel);
      return 1;
   } else {
      return 0;
   }
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
      return 1;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   // je ferme la tache en ecriture du telescope sur la carte USB
 	if( tel->outputTelescopTaskHandle!=0 ) {
		DAQmxStopTask(tel->outputTelescopTaskHandle);
		DAQmxClearTask(tel->outputTelescopTaskHandle);
      tel->outputTelescopTaskHandle = 0;
	}

   // je ferme la tache en ecriture de l'attenuateur sur la carte USB
 	if( tel->outputFilterTaskHandle!=0 ) {
		DAQmxStopTask(tel->outputFilterTaskHandle);
		DAQmxClearTask(tel->outputFilterTaskHandle);
      tel->outputFilterTaskHandle = 0;
	}
   // je ferme la tache en lecture de l'attenuateur sur la carte USB
 	if( tel->inputFilterTaskHandle!=0 ) {
		DAQmxStopTask(tel->inputFilterTaskHandle);
		DAQmxClearTask(tel->inputFilterTaskHandle);
      tel->inputFilterTaskHandle = 0;
	}

   // je ferme le port de liaison s�rie avec le HP1000
   if( strcmp(tel->channel,"") != 0 ) {
      char s[1024];
      sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
      strcpy(tel->channel,"");
   }   


   // je ferme la socket de commande du telescope
   if ( tel->telescopeCommandSocket != NULL ) {
      // j'arrete les notifications des coordonnees
      mytel_setRadecNotification(tel, 0);
      // je ferme la socket de commande
      socket_closeTelescopeCommandSocket(tel);
   }

   // je ferme la socket de notification du telescope 
   if ( tel->telescopeNotificationSocket != NULL ) {
      socket_closeTelescopeNotificationSocket(tel);
   }

   return 0;
}



/////////////////////////////////////////////////////////////////////////
//
//  commandes RADEC de positionnement de la monture
//
/////////////////////////////////////////////////////////////////////////


/**
 * tel_radec_init
 *   rien a faire pour cette monture
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope
 * @return 0=OK 1=erreur
 */
int tel_radec_init(struct telprop *tel)
{
   return 0;
}


/**
 * tel_radec_coord
 *   retourne les coordonnes alpha et delta
 *
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope
 * @param result  coordonnees "00h00m00.00s +00d00m00s"
 * @return 0=OK 1=erreur
 */
int tel_radec_coord(struct telprop *tel,char *coord)
{
   int result;
   if (tel->telescopeCommandSocket != NULL) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      sprintf(command,"!RADEC COORD 2 @\n" );
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         char ra[NOTIFICATION_MAX_SIZE];
         char dec[NOTIFICATION_MAX_SIZE];

         int readValue = sscanf(response,"!RADEC COORD %d %s %s @", &returnCode, ra, dec);
         if (readValue != 3) {
            sprintf(tel->msg,"tel_radec_coord error: readValue=%d %s", readValue, response );
            result = 1;
         } else {
            if ( returnCode != 0 ) {
               sprintf(tel->msg,"tel_radec_coord error: returnCode=%d", returnCode );
               result = 1;
            } else {
               // je copie les coordonnees dans la variable de sortie
               sprintf(coord,"%s %s", ra, dec);
               result = 0;
            }
         }
      }
   } else {
      // je retourne une reponse par defaut 
      strcpy(coord,"00h00m00.00s +00d00m00.00s");
      result = 0; 
   }


   return result;
}


//-------------------------------------------------------------
// mytel_setRadecNotification
//
// demande a recevoir les coordonnes sur la socket de notification
//
// @param tel   pointeur structure telprop
// @param mode  0 : arret de la notification des coordonnees radec
//              1 : marche de la notification des coordonnees radec
// @return 0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_setRadecNotification(struct telprop *tel, int mode )
{
   int result; 
   
   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      sprintf(command,"!RADEC COORD %d @\n", mode);
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!RADEC COORD %d @", &returnCode);
         if (readValue != 1) {
            sprintf(tel->msg,"setRadecNotification error: readValue=%d %s", readValue, response );
            result = 1;
         } else {
            if ( returnCode != 0 ) {
               sprintf(tel->msg,"setRadecNotification error: returnCode=%d", returnCode );
               result = 1;
            } else {
               // je memorise l'etat des notifications (1=marche 0=arret)
               switch (mode) {
               case 0 : 
               //   tel->radecNotification = 0;
                  break;
               case 1 : 
               //   tel->radecNotification = 1;
                  break; 
               }                  
            }
         }
      }
   } else {
      result = 0; 
   }
   return result;
}


int tel_radec_state(struct telprop *tel,char *text)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   sprintf(text,"");
   return 0;
}

/**
 * tel_radec_goto 
 *
 *   lance un goto vers les coordonnees tel->ra0 tel->dec0
 *   si tel->radec_goto_blocking==1 alors attend que la fin du GOTO
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope            
 * @return 0=OK 1=erreur
 */
int tel_radec_goto(struct telprop *tel) {
	int result; 

   if (tel->telescopeCommandSocket != NULL) {
      char ligne[1024];
      char gotoRa[12];
      char gotoDec[13];
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      result = 0; 

      // je verifie s'il n'y a pas deja un mouvement en cours
      if ( tel->radecIsMoving != 0 ) {
         sprintf(tel->msg, "tel_radec_goto already moving");
         result = 1;          
      }

      if ( result == 0 ) {   
         // je convertis les coordonnees en chaine de caractere
         sprintf(ligne,"mc_angle2hms %.7f 360 zero 2 auto string",tel->ra0); 
         if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
            sprintf(tel->msg, "tel_radec_goto %s error: %s", ligne, tel->interp->result);
            result = 1; 
         } else {
            strcpy(gotoRa,tel->interp->result);
            //F.FILLION : transforme "10h30m20s99" en "10h30m20.99s"
            gotoRa[8]  = '.';
            gotoRa[11] = 's';
            gotoRa[12] = '\0';
         } // gotoRa	= "10h30m20s99" => OK

         sprintf(ligne,"mc_angle2dms %.7f 90 zero 2 + list",tel->dec0);
         if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
            sprintf(tel->msg, "tel_radec_goto %s error: %s", ligne, tel->interp->result);
            result = 1; 
         } else {
            strcpy(gotoDec,tel->interp->result);
            //F.FILLION : transforme "+23d33m43s99" en "+23d33m43.99s"
            gotoDec[9]  = '.';
            gotoDec[12] = 's';
            gotoDec[13] = '\0';
         }
      }

      // j'envoi la commande GOTO
      if ( result == 0 ) {
         sprintf(command,"!RADEC GOTO %s %s@\n", gotoRa, gotoDec );
         result = socket_writeTelescopeCommandSocket(tel,command,response);
      }

      // je traite la reponse
      if ( result == 0 ) {
         int returnCode;
         char newRa[13];
         char newDec[13]; 
         int readValue = sscanf(response,"!RADEC GOTO %d %s %s @", &returnCode, newRa, newDec);
         if (readValue != 3) {
            sprintf(tel->msg,"RADEC GOTO error: readValue=%d response=%s", readValue, response );
            result = 1;
         } else {
            if ( returnCode == 0 ) {
               strcpy(tel->ra , newRa);
               strcpy(tel->dec , newDec);
            } else {
               sprintf(tel->msg,"RADEC GOTO error: returnCode=%d", returnCode );
               result = 1;
            } 
         }
      } else {
         // rien a faire. Le message d'erreur est deja dans tel->msg
      }

      if ( result == 0 ) {
	      if (tel->radec_goto_blocking==1) {
            int foundEvent = 1 ;
            tel->radecIsMoving = 1;
            // j'attend la fin du mouvement (tel->moving est mis a jour par mytel_processNotification ) 
            while (tel->radecIsMoving && foundEvent) {
               foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            }
         }
      }
   } else {
      // cette fonction n'est pas implementee pour le HP1000
      result = 0;
   }
   return result;
}

/**
 * tel_radec_move 
 *
 *   Mouvements en alpha et delta en continu (voir 
 *   la direction est fournie en parametre
 *   la vitesse est dans tel->speed  (valeur entre 0.0 et 1.0)
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope            
 * @param direction  direction= N S E W
 * @return 0=OK 1=erreur
 */
int tel_radec_move(struct telprop *tel,char *direction)
{
   int result = 0;

   if ( tel->outputTelescopTaskHandle != 0 ) {
      char mask; 
      int numbit;

      switch (tolower(direction[0])) {
         case 'n' : 
            numbit = tel->northRelay;
            break;
         case 's' : 
            numbit = tel->southRelay;
            break;
         case 'e' : 
            numbit = tel->estRelay;
            break;
         case 'w' : 
            numbit = tel->westRelay;
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            return 1;
      }

      // je cree le masque de l'octet
      mask = 1 << numbit;
      // je force � 0 le bit correspondant 
      tel->outputTelescopNotification &= ~mask;
      result = mytel_sendUsbCommandTelescop(tel , tel->outputTelescopNotification);
   } else if (tel->telescopeCommandSocket != NULL) {
      char direction2;

      // je verifie s'il n'y a pas deja un mouvement en cours
      if ( tel->radecIsMoving != 0 ) {
         sprintf(tel->msg, "tel_radec_goto already moving");
         result = 1;          
      }

      if ( result == 0 ) {
         // je convertis en majuscule
         direction2 = toupper(direction[0]);

         // je verifie la valeur
         switch (direction2) {
            case 'N' : 
            case 'S' : 
            case 'E' : 
            case 'W' : 
               result = 0; 
               break;
            default : 
               sprintf(tel->msg,"invalid direction %s",direction);
               result = 1;
         }
      }
      
      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         if ( tel->radec_move_rate == 0.0 ) {
            // vitesse de guidage
            sprintf(command,"!RADEC MOVE %c guidage 0 @\n", direction2 );  
         } else if ( tel->radec_move_rate == 0.33 ) {
            // vitesse de centrage
            sprintf(command,"!RADEC MOVE %c centrage 0 @\n", direction2 );
         } else {
            // par defaut vitesse de guidage
            sprintf(command,"!RADEC MOVE %c guidage 0 @\n", direction2 );  
         }
		   //envoi du mouvement et recup�ration du code 0
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
            int returnDirection; 
            int readValue = sscanf(response,"!RADEC MOVE %d %c @", &returnCode, &returnDirection);
            if (readValue != 2) {
               sprintf(tel->msg,"RADEC MOVE error: readValue=%d response=%s", readValue, response );
               result = 1;
            } else {
               if ( returnCode != 0 ) {
                  sprintf(tel->msg,"RADEC MOVE error: returnCode=%d", returnCode );
                  result = 1;
               } 
            }
         }
      }
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec move %s OK",direction);
      result = 0;
   }
   return result;
}

//-------------------------------------------------------------
// tel_radec_stop
//
// arret du mouvement en ascension droite (E ou W) ou en declinaison (N ou S)
// ou arret sur les deux axes (T)
//
// @param tel   pointeur structure telprop
// @param direction direction de la correction N,S, E, W ,T 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_radec_stop(struct telprop *tel,char *direction)
{
   int result ;

   if ( tel->outputTelescopTaskHandle != 0 ) {
      char mask; 
      int numbit;

      if ( strlen(direction) > 0 ) {
         // j'arrete le mouvement dans la direction precisee en parametre
         switch (tolower(direction[0])) {
            case 'n' : 
               numbit = tel->northRelay;
               break;
            case 's' : 
               numbit = tel->southRelay;
               break;
            case 'e' : 
               numbit = tel->estRelay;
               break;
            case 'w' : 
               numbit = tel->westRelay;
               break;
            default : 
               sprintf(tel->msg,"invalid direction %s",direction);
               return 1;
         }

         // je cree le masque 
         mask = 1 << numbit;
         // je force � 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;
      } else {
         // j'arrete le mouvement dans toutes les directions 

         // je cree le masque northRelay
         mask = 1 << tel->northRelay;
         // je force � 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;

         // je cree le masque 
         mask = 1 << tel->southRelay;
         // je force � 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;

         // je cree le masque 
         mask = 1 << tel->estRelay;
         // je force � 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;

         // je cree le masque 
         mask = 1 << tel->westRelay;
         // je force � 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;
      }
      result = mytel_sendUsbCommandTelescop(tel, tel->outputTelescopNotification);
   } else if (tel->telescopeCommandSocket != NULL) {

      // je convertis en majuscule
      char direction2 = toupper(direction[0]);

      // je verifie la valeur
      switch (direction2) {
         case 'N' : 
         case 'S' : 
         case 'E' : 
         case 'W' : 
            result = 0; 
            break;
         case 0 : 
            direction2 = 'T';
            result = 0; 
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            return 1;
      }
      
      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!RADEC STOP %c @\n", direction2 );
         result = socket_writeTelescopeCommandSocket(tel,command,response);
         if ( result == 0 ) {
            int returnCode;
            char returnDirection;
            int readValue = sscanf(response,"!RADEC STOP %d %c @", &returnCode, &returnDirection);
            if (readValue != 2) {
               sprintf(tel->msg,"RADEC STOP error: readValue=%d %s", readValue, response );
               result = 1;
            } else {
               if ( returnCode != 0 ) {
                  sprintf(tel->msg,"RADEC STOP error: returnCode=%d", returnCode );
                  result = 1;
               } 
            }
         }
      }

   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec stop %s OK",direction);
      result = 0; 
   }
   return result;
}

//-------------------------------------------------------------
// mytel_correct
//
// envoie une correction en ascension droite ou en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param direction direction de la correction N,S, E, W  
// @param distance  valeur de la correction en arseconde  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_correct(struct telprop *tel,char *direction, double distance)
{
   int result ;

   if (fabs(distance) < 0.001) return 0; //ajout F.FILLION : pas de JOG continue en guidage (rem: 0.001 arcsec = 0.2 cts de #2)
 
   // je verifie s'il n'y a pas deja un mouvement en cours
   if ( tel->radecIsMoving != 0 ) {
      sprintf(tel->msg, "tel_radec_goto already moving");
      result = 1;          
   } else {
		result = 0;
   }

   if (result == 0 ) {

      if ( tel->telescopeCommandSocket != 0 ) {

         // je convertis en majuscule
         char direction2 = toupper(direction[0]);

         // je verifie la valeur
         switch (direction2) {
         case 'N' : 
         case 'S' : 
         case 'E' : 
         case 'W' : 
            result = 0; 
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            result = 1;
         }

         if ( result == 0 ) {
            char command[NOTIFICATION_MAX_SIZE];
            char response[NOTIFICATION_MAX_SIZE];
            if ( tel->radec_move_rate == 0.0 ) {
               // vitesse de guidage
               sprintf(command,"!RADEC MOVE %c guidage %.3f @\n", direction2, distance );  
            } else if ( tel->radec_move_rate == 0.33 ) {
               // vitesse de centrage
               sprintf(command,"!RADEC MOVE %c centrage %.3f @\n", direction2, distance );
            } else {
               // par defaut vitesse de guidage
               sprintf(command,"!RADEC MOVE %c guidage %.3f @\n", direction2, distance );  
            }

            result = socket_writeTelescopeCommandSocket(tel,command,response);

            if ( result == 0 ) {
               int returnCode;
               int returnDirection; 
               int readValue = sscanf(response,"!RADEC MOVE %d %c @", &returnCode, &returnDirection);
               if (readValue != 2) {
                  sprintf(tel->msg,"RADEC MOVE error: readValue=%d %s", readValue, response );
                  result = 1;
               } else {
                  if ( returnCode != 0 ) {
                     sprintf(tel->msg,"RADEC MOVE error: returnCode=%d", returnCode );
                     result = 1;
                  } else {
                     int foundEvent = 1;
                     tel->radecIsMoving = 1;
                     // j'attend la fin du mouvement (tel->moving est mis a jour par mytel_processNotification ) 
                     while (tel->radecIsMoving && foundEvent) {
                        foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                     }
                  }
               }
            }
         }
      }
   }
   return result;
}

//  thread::send -async [tel1 threadid] [list tel1 correct n 0  10]

//-------------------------------------------------------------
// tel_radec_motor
//
//    commande marche/arret du suivi
//     tel->radec_motor = 0  marche 
//     tel->radec_motor = 1  arret 
//
// @param tel   pointeur structure telprop
// @param mode  0 : arret de la notification des coordonnees radec
//              1 : marche de la notification des coordonnees radec
//              2 : demande de coordonnees radec immediate 
// @return         0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_radec_motor(struct telprop *tel) {
   int result; 

   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      int slew ; 

      if (tel->radec_motor == 0 ) {
         slew = 1; 
      } else {
         slew = 0;
      }

      sprintf(command,"!RADEC SLEW %d @\n", slew);
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!RADEC SLEW %d @", &returnCode);
         if (readValue != 1) {
            sprintf(tel->msg,"tel_radec_motor error: readValue=%d %s", readValue, response );
            result = 1;
         } else {
            if ( returnCode != 0 ) {
               sprintf(tel->msg,"tel_radec_motor error: returnCode=%d", returnCode );
               result = 1;
            }
         }                  
      }
   } else {
      result = 0; 
   }
   return result;
}


////////////////////////////////////////////////////////////////////
//
//  FOCALISATION
//
////////////////////////////////////////////////////////////////////


int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return 0;
}

//-------------------------------------------------------------
// tel_focus_coord
//
//    recupere la position de la focalisation
//
// @param tel   pointeur structure telprop
// @param result 
//          + : augmentation de la foc
//          - : diminution de la foc 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_coord(struct telprop *tel,char *position)
{
   int result;
   if (tel->telescopeCommandSocket != NULL) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      sprintf(command,"!FOC COORD 2 @\n" );
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;

         int readValue = sscanf(response,"!FOC COORD %d %s @", &returnCode, position);
         if (readValue != 2) {
            sprintf(tel->msg,"tel_radec_coord error: readValue=%d %s", readValue, response );
            result = 1;
         } else {
            if ( returnCode != 0 ) {
               sprintf(tel->msg,"tel_radec_coord error: returnCode=%d", returnCode );
               result = 1;
            } else {
               // je copie les coordonnees dans la variable de sortie
               result = 0;
            }
         }
      }
   } else {
      // je retourne une reponse par defaut 
      strcpy(position,"0.0");
      result = 0; 
   }


   return result;
}

//-------------------------------------------------------------
// tel_focus_move
//
//    deplacement a une position qui est dans tel->focus0 
//
// @param tel   pointeur structure telprop
// @param direction 
//          + : augmentation de la foc
//          - : diminution de la foc 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_goto(struct telprop *tel)
{
  int result = 0;

  if (tel->telescopeCommandSocket != NULL) {

      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!FOC GOTO %.2f @\n", tel->focus0 );  
		   //envoi de la commande et recup�ration de la reponse 
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
			   // j'extrait le code retour
            int readValue = sscanf(response,"!FOC GOTO %d @", &returnCode);
            if (readValue != 1) {
               sprintf(tel->msg,"FOC STOP error: readValue=%d response=%s", readValue, response );
               result = 1;
            } else {
               if ( returnCode != 0 ) {
                  sprintf(tel->msg,"FOC GOTO error: returnCode=%d", returnCode );
                  result = 1;
               } else {                  
                  // j'active les notifications de la position du focus
                  result = mytel_setFocusNotification(tel, 1);
                  // si le goto est lance en mode bloquant , j'attends la fin du deplacement
                  if ( tel->focus_goto_blocking == 1 ) {
                     int foundEvent = 1;
                     tel->focusIsMoving = 1;
                     // j'attend la fin du mouvement (tel->moving est mis a jour par mytel_processNotification ) 
                     while (tel->focusIsMoving && foundEvent) {
                        foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                        Tcl_Sleep(1);
                     }
                  }
                  result = 0;
               }
            }
         }
      }
   }
   return result;
}

//-------------------------------------------------------------
// tel_focus_move
//
//    commande marche/arret de la focalisation
//     tel->radec_motor = 0  marche 
//     tel->radec_motor = 1  arret 
//
// @param tel   pointeur structure telprop
// @param direction 
//          + : augmentation de la foc
//          - : diminution de la foc 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_move(struct telprop *tel,char *direction)
{
  int result = 0;
  char direction2 =direction[0]; 

  if (tel->telescopeCommandSocket != NULL) {
      // je verifie s'il n'y a pas deja un mouvement en cours
      if ( tel->focusIsMoving != 0 ) {
         sprintf(tel->msg, "focalisation already moving");
         result = 1;          
      }

      if ( result == 0 ) {
         
         // je verifie la valeur
         switch (direction2) {
            case '+' : 
            case '-' : 
               result = 0; 
               break;
            default : 
               sprintf(tel->msg,"invalid direction %s",direction);
               result = 1;
         }
      }
      
      // j'active la notification des coordonn�es pendant le deplacement
      // la notification sera desactivee a la fin du deplacement par mytel_processNotification
      if ( result == 0 ) {
         result = mytel_setFocusNotification(tel, 1);
      }

      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         if ( tel->focus_move_rate == 0.0 ) {
            // vitesse lente
            sprintf(command,"!FOC MOVE %c L 0 @\n", direction2 );  
         } else {
            // vitesse de rapide
			   sprintf(command,"!FOC MOVE %c R 0 @\n", direction2 );
         } 
		  //envoi du mouvement et recup�ration du code 0
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
            int readValue = sscanf(response,"!FOC MOVE %d @", &returnCode);
            if (readValue != 1) {
               sprintf(tel->msg,"FOC MOVE error: readValue=%d response=%s", readValue, response );
               result = 1;
            } else {
               if ( returnCode != 0 ) {
                  sprintf(tel->msg,"FOC MOVE error: returnCode=%d", returnCode );
                  result = 1;
               } 
            }
         }
      }
   }
   return result;
}

//-------------------------------------------------------------
// tel_focus_stop
//
// arret du mouvement de focalisation 
// @param tel   pointeur structure telprop
// @param direction parametre non utilis�
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_stop(struct telprop *tel,char * direction)
{
  int result = 0;

  if (tel->telescopeCommandSocket != NULL) {

      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!FOC STOP @\n");  
		   //envoi de la commande et recupere la reponse
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
            int readValue = sscanf(response,"!FOC STOP %d @", &returnCode);
            if (readValue != 1) {
               sprintf(tel->msg,"FOC STOP error: readValue=%d response=%s", readValue, response );
               result = 1;
            } else {
               if ( returnCode != 0 ) {
                  sprintf(tel->msg,"FOC STOP error: returnCode=%d", returnCode );
                  result = 1;
               } 
            }
         }
      }
   }
   return result;
}

//-------------------------------------------------------------
// mytel_setFocusNotification
//
// demande a recevoir la position du focus sur la socket de notification
//
// @param tel   pointeur structure telprop
// @param mode  0 : arret de la notification de la position du focus
//              1 : marche de la notification de la position du focus
// @return 0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_setFocusNotification(struct telprop *tel, int mode )
{
   int result; 
   
   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      sprintf(command,"!FOC COORD %d @\n", mode);
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!FOC COORD %d @", &returnCode);
         if (readValue != 1) {
            sprintf(tel->msg,"tel_radec_coord error: readValue=%d %s", readValue, response );
            result = 1;
         } else {
            if ( returnCode != 0 ) {
               sprintf(tel->msg,"tel_radec_coord error: returnCode=%d", returnCode );
               result = 1;
            } else {
               result = 0;
            }
         }
      }
   } else {
      result = 0; 
   }
   return result;
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return 0;
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   //return mytel_date_get(tel,ligne);
   return 0;
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   //return mytel_date_set(tel,y,m,d,h,min,s);
   return 0;

}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   //return mytel_home_get(tel,ligne);
      return 0;

}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   //return mytel_home_set(tel,longitude,ew,latitude,altitude);
      return 0;

}


////////////////////////////////////////////////////////////////////
//
// gestion des att�nuateurs 
//
////////////////////////////////////////////////////////////////////


//-------------------------------------------------------------
// tel_filter_setMax
//
// Inialise la duree de d�plement entre les 2 fin de course de l'attenuateur
// Cette dur�e servira pour calculer le pourcentage d'att�nuation
//
// @param tel 
// @param filterMaxDelay  duree de d�placement entre les fin de course (en seconde)
//-------------------------------------------------------------

int tel_filter_setMax(struct telprop *tel, double filterMaxDelay) {  
   // je memorise la valeur max 
   tel->filterMaxDelay = filterMaxDelay;

   // j'ecrete la valeur courante pour ne pas provoquer une situation incoh�rente
   if ( tel->filterCurrentDelay > tel->filterMaxDelay ) {
      tel->filterCurrentDelay = tel->filterMaxDelay;
   }

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter set max %f OK", filterMaxDelay);
   }
   return 0;   
}

//-------------------------------------------------------------
// tel_filter_getMax
//
// retour,la dur�e de deplacement entre les 2 but�es de fin de course 
//
// @param tel 
// @param filterMaxDelay  duree de d�placement entre les fin de course (en seconde)
//-------------------------------------------------------------

int tel_filter_getMax(struct telprop *tel, double *filterMaxDelay) {   
   *filterMaxDelay     = tel->filterMaxDelay;
   return 0;   
}


//-------------------------------------------------------------
// tel_filter_coord
//
// Retourne la position du filtre d'attenuation (entre 0.0 et 10.0) 
//
// @param tel    pointeur struture telprop
// @param coord  chaine de caractere contenant la valeur d'attenuation (entre 0.0 et 10.0) 
//-------------------------------------------------------------
int tel_filter_coord(struct telprop *tel, char * coord) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputNotification;
      result = mytel_readUsbCard(tel, &inputNotification);
      if ( result == 0 ) {
         double delay ; 


         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputNotification, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputNotification, tel->maxDetectorFilterInput);

         if ( min == 0 ) {
            // la butee MIN est au niveau 0 quand elle est rencontr�e
            delay= 0;
            tel->filterCurrentDelay = delay; 
         } else if (max == 0 ) {
            // la butee MAX est au niveau 0 quand elle est rencontr�e
            delay = tel->filterMaxDelay;
            tel->filterCurrentDelay = delay; 
         } else {
            // la position est entre les deux butees
            if (tel->filterCommand == tel->decreaseFilterRelay) {
               // si un mouvement "-" en cours , je soustrais la dur�e ecoulee depuis le d�but du mouvement
               delay =  tel->filterCurrentDelay -  mytel_getTimer(tel);
            } else if (tel->filterCommand == tel->increaseFilterRelay) {
               // si un mouvement "-" en cours , j'ajoute la dur�e ecoulee depuis le d�but du mouvement
               delay =  tel->filterCurrentDelay +  mytel_getTimer(tel);
            } else {
               // si pas de un mouvement en cours, je retourne le delai courant
               delay = tel->filterCurrentDelay;
            }

            if (delay< 0.0 ) {
               delay = 0.0;
            } else if (delay > tel->filterMaxDelay ) {
               delay = tel->filterMaxDelay;
            }
         }

         // je calcule le pourcentage par rapport au delai max
         sprintf(coord, "%3.1f", ( delay * 10.0 / tel->filterMaxDelay)); 
         result = 0;
      }
   } else {
      strcpy(coord, "5.0");
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter coord %s OK", coord);
      result = 0;
   }
   return result;
}


//-------------------------------------------------------------
// tel_filter_extremity
//
// Retourne l'etat des butees aux extremit�s
//    retourne MIN si la position est sur la but�e MIN
//    retourne MAX si la position est sur la but�e MAX
//    retourne MED si la position est entre les deux but�es
//
// @param tel    pointeur struture telprop
// @param extremity  chaine de caractere contenant l'�tat de la position (MIN , MED , MAX)
//                
//-------------------------------------------------------------
int tel_filter_extremity(struct telprop *tel, char * extremity) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputNotification;
      result = mytel_readUsbCard(tel, &inputNotification);
      if ( result == 0 ) {
         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputNotification, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputNotification, tel->maxDetectorFilterInput);

         // la fin de course est au niveau 0 quand elle est rencontr�e
         if ( min == 0 ) {
            strcpy(extremity,"MIN");
         } else if (max == 0 ) {
            strcpy(extremity,"MAX");
         }  else {
            strcpy(extremity,"MED");
         }
         result = 0;
      }
   } else {
      strcpy(extremity, "MED");
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter coord %s OK", coord);
      result = 0;
   }
   return result;
   
   
}

//-------------------------------------------------------------
// tel_filter_move
//
// demarrer le changement de position de l'att�nuateur
//
// @param tel    pointeur structure telprop
// @param direction  sens du deplacement ( "-" ou "+" )
// @return      0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_filter_move(struct telprop *tel, char * direction) {
   int result = 0;

   if ( tel->outputFilterTaskHandle != 0 ) {
      char mask; 
      int numbit;

      switch (tolower(direction[0])) {
         case '-' : 
            numbit = tel->decreaseFilterRelay;
            break;
         case '+' : 
            numbit = tel->increaseFilterRelay;
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            return 1;
      }

      // je cree le masque 
      mask = 1 << numbit;
      // je force � 0 le bit correspondant 
      tel->outputFilterNotification &= ~mask;
      result = mytel_sendCommandFilter(tel, tel->outputFilterNotification);
      // je memorise l'heure de d�but du mouvememt
      mytel_startTimer(tel);
      // je memorise le sens du mouvememt qui sera utilis� par tel_filter_stop
      tel->filterCommand = numbit;      
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter move %s OK",direction);
      result = 0;
   }

   return result;   
}

//-------------------------------------------------------------
// tel_filter_move
//
// arrete le changement de position de l'att�nuateur
//
// @param tel    pointeur structure telprop
// @return      0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_filter_stop(struct telprop *tel) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      char mask; 
      double delay;

      // je cree le masque pour decreaseFilterRelay
      mask = 1 << tel->decreaseFilterRelay;
      // je force � 1 le bit correspondant 
      tel->outputFilterNotification |= mask;

      // je cree le masque pour increaseFilterRelay
      mask = 1 << tel->increaseFilterRelay;
      // je force � 1 le bit correspondant 
      tel->outputFilterNotification |= mask;
      // j'enoive la commande sur la carte
      result = mytel_sendCommandFilter(tel, tel->outputFilterNotification);
      
      // je memorise l'heure de fin du mouvememt et je calule le d�lai en millisecondes
      delay = mytel_stopTimer(tel);

      if (tel->filterCommand == tel->decreaseFilterRelay) {
         // diminution de l'attenuateur => je diminue le temps cumul�
         tel->filterCurrentDelay -= delay;
         if (tel->filterCurrentDelay < 0.0 ) {
            tel->filterCurrentDelay = 0.0;
         } 
      } else {
         // augmentation de l'attenuateur => j'augmente le temps cumul�
         tel->filterCurrentDelay += delay;
         if (tel->filterCurrentDelay > tel->filterMaxDelay ) {
            tel->filterCurrentDelay = tel->filterMaxDelay;
         } 
      }
      // Raz de la commande pour indiquer que le mouvement est arrete
      tel->filterCommand = -1;
    } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter stop OK");
      result = 0;
   }
   return result;   
}

//-------------------------------------------------------------
// mytel_sendUsbCommandTelescop
//
// envoie une commande au telescope sur le port tel->outputTelescopTaskHandle
//
// @param tel     pointeur structure telprop
// @param command integer contenant la conmmande  
// @return        0 = OK,  1= erreur
//-------------------------------------------------------------

int mytel_sendUsbCommandTelescop(struct telprop *tel, int command) {
	int      cr = 0;
   int      error=0;
   uInt8    notification=0;
   int32	   written;

   notification = (uInt8) command;

   if ( tel->consoleLog >= 2 ) {
      // j'affiche une trace dans la console
      mytel_logConsole(tel, "T193 command: %d",notification); 
   }

   // DAQmx Write Code
   // parametres : 
   //    outputTaskHandle outputTaskHandle,  
   //    int32 numSampsPerChan,        1
   //    bool32 autoStart,             1
   //    float64 timeout,              10.0 seconds
   //    bool32 notificationLayout,            DAQmx_Val_GroupByChannel
   //    const uInt32 writeArray[],    notification 
   //    int32 *sampsPerChanWritten,   written
   //    bool32 *reserved);            NULL
	//error = DAQmxWriteDigitalU32(tel->outputTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
   error = DAQmxWriteDigitalU8(tel->outputTelescopTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
    

   if( DAQmxFailed(error)) {
      // je copie le message d'erreur
		DAQmxGetExtendedErrorInfo(tel->msg,1024);
      cr = 1;
   } else {
		strcpy(tel->msg,"");
      cr = 0;
   }

	return cr;
}

//-------------------------------------------------------------
// mytel_sendCommandFilter
//
// envoie une commande au filtre sur le port tel->outputFilterTaskHandle
//
// @param tel      pointeur structure telprop
// @param command  integer contenant la conmmande 
// @return         0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_sendCommandFilter(struct telprop *tel, int command) {
	char     ligne[1024];
	int      cr = 0;
   uInt8   notification=0;
   int32	   written;
   int      error=0;
   notification = (uInt8) command;

   if ( tel->consoleLog >= 2 ) {
      // j'affiche une trace dans la console
      mytel_logConsole(tel, "T193 command: %d",notification); 
      Tcl_Eval(tel->interp,ligne);
   }

   // DAQmx Write Code
   // parametres : 
   //    outputTaskHandle outputTaskHandle,  
   //    int32 numSampsPerChan,        1
   //    bool32 autoStart,             1
   //    float64 timeout,              10.0 seconds
   //    bool32 notificationLayout,            DAQmx_Val_GroupByChannel
   //    const uInt32 writeArray[],    notification 
   //    int32 *sampsPerChanWritten,   written
   //    bool32 *reserved);            NULL
	//error = DAQmxWriteDigitalU32(tel->outputTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
   error = DAQmxWriteDigitalU8(tel->outputFilterTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);

   if( DAQmxFailed(error)) {
      // je copie le message d'erreur
		DAQmxGetExtendedErrorInfo(tel->msg,1024);
      cr = 1;
   } else {
		strcpy(tel->msg,"");
      cr = 0;
   }

	return cr;
}

/**
 * mytel_readUsb : send a command to the telescop
 * @param tel  
 * @param command : long integer 
 * @return 0=OK 1=erreur
 */
int mytel_readUsbCard(struct telprop *tel, unsigned char *notification ) {
	char     ligne[1024];
	int      cr = 0;
   int      error=0;
   int32	   readden;

   // DAQmxReadDigitalU8
   // parametres : 
   //    outputTaskHandle outputTaskHandle,  
   //    int32 numSampsPerChan,        1
   //    float64 timeout,              10.0 seconds
   //    bool32 notificationLayout,            DAQmx_Val_GroupByChannel
   //    const uInt32 writeArray[],    notification 
   //    int32 *sampsPerChanWritten,   readden elements nb
   //    bool32 *reserved);            NULL 
   error = DAQmxReadDigitalU8 (tel->inputFilterTaskHandle, 1, 10.0, DAQmx_Val_GroupByChannel, notification, 1, &readden, NULL);

   if( DAQmxFailed(error)) {
      // je copie le message d'erreur
		DAQmxGetExtendedErrorInfo(tel->msg,1024);
      cr = 1;
   } else {
      if ( tel->consoleLog >= 2 ) {
         // j'affiche une trace dans la console
         mytel_logConsole(tel,"T193 read USB: %d",*notification); 
         Tcl_Eval(tel->interp,ligne);
      }

		strcpy(tel->msg,"");
      cr = 0;
   }

	return cr;
}


/**
* getBit 
*    lit un octet  et retourne la valeur d'un bit
*/
int mytel_getBit(struct telprop *tel, unsigned char notification, int numbit)
{
   unsigned char mask; 
   unsigned char tempValue;
   char result;

   if(numbit <0 || numbit >7 ) {
      return 0;
   }

   mask = 1 << numbit;
   
   tempValue = notification & mask;

   if( tempValue ==0 ) {
      result = 0;
   } else {
      result = 1;
   }

   return result;
}


//-------------------------------------------------------------
// mytel_sendNotificationError
//
// affiche une erreur dans la console pour signaler une notification erronee
//
// @param tel   pointeur structure telprop
// @param notification  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
void mytel_sendNotificationError(struct telprop *tel, int errorNo, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   
   // je formate le message 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
	va_end (mkr);

   // j'affiche une erreur dans la console
   if ( strcmp(tel->telThreadId,"") == 0 ) {
      sprintf(ligne,"error \"t193 error=%d notification=%s \" ",errorNo, message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { error \"t193 error=%d notification=%s \" }" , tel->mainThreadId, errorNo, message ); 
   }
   Tcl_Eval(tel->interp,ligne);   
}

//-------------------------------------------------------------
// mytel_processNotification
//
// traite les notifications suivantes : 
// 
//   
//     "!RADEC COORD [Code retour] [mouvement] [suivi] [alpha] [delta] @"
//     "!RADEC FOC [Code retour] [mouvement] [position] @"
//
// @param tel   pointeur structure telprop
// @param notification  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
void mytel_processNotification(struct telprop *tel, char * notification) {
   int  nbArrayElements;
   char command1[NOTIFICATION_MAX_SIZE]= {'\0'} ;
   char command2[NOTIFICATION_MAX_SIZE];
      
   nbArrayElements = sscanf(notification, "!%s %s @", command1, command2);
   
   if ( nbArrayElements == 2 ) {
      // je traite la notification
      if ( strcmp( command1, "RADEC")==0) {
         if ( strcmp( command2, "COORD")==0 ) {
            int returnCode;
            int moveCode;
            int slewCode;
            char ra[NOTIFICATION_MAX_SIZE];
            char dec[NOTIFICATION_MAX_SIZE];
            // traitement de "!RADEC COORD [Code retour] [mouvement] [suivi] [alpha] [delta] @"
            nbArrayElements = sscanf(notification, "!RADEC COORD %d %d %d %s %s @", &returnCode, &moveCode, &slewCode, ra, dec);
            // je verifie que le nombre de valeurs lues
            if ( nbArrayElements == 5 ) {
               // je verifie le code retour 
               if ( returnCode == 0) {
                  char ligne[1024];                  
                  // je memorise le mouvement
                  tel->radecIsMoving = moveCode;
                  // je notifie les nouvelles coordonnes au thread principal                
                  if ( strcmp(tel->telThreadId,"") == 0 ) {
                     sprintf(ligne,"set ::audace(telescope,getra) \"%s\" ; set ::audace(telescope,getdec) \"%s\" ",ra, dec); 
                  } else {
                     sprintf(ligne,"::thread::send -async %s { set ::audace(telescope,getra) \"%s\" ; set ::audace(telescope,getdec) \"%s\" ;update} " , tel->mainThreadId, ra , dec); 
                  }
                  Tcl_Eval(tel->interp,ligne);
               }
            } else {
               mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
            }
            
         } else {
            mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
         }
      } else if ( strcmp( command1, "FOC")==0) {
         if ( strcmp( command2, "COORD")==0 ) {
            int returnCode;
            int moveCode;
            float position;

            // traitement de "!FOC COORD [Code retour] [mouvement] [position] @"
            nbArrayElements = sscanf(notification, "!FOC COORD %d %d %f @", &returnCode, &moveCode, &position);
            // je verifie que le nombre de valeurs lues est 5
            if ( nbArrayElements >= 3 ) {
               // je verifie le code retour 
               if ( returnCode == 0) {
                  char ligne[1024];
                  
                  // je memorise le mouvement
                  tel->focusIsMoving = moveCode;
                  // j'arrete la notification si le mouvement est termine
                  if ( tel->focusIsMoving == 0 ) {
                     mytel_setFocusNotification(tel, 0);
                  }
                  // je notifie les nouvelles coordonnes au thread principal                
                  if ( strcmp(tel->telThreadId,"") == 0 ) {
                     sprintf(ligne,"set ::audace(telescope,currentFocus) %s", position); 
                  } else {
                     sprintf(ligne,"::thread::send -async %s { set ::audace(telescope,currentFocus) %6.2f ; update }" , tel->mainThreadId, position); 
                  }
                  Tcl_Eval(tel->interp,ligne);
               }
            } else {
               mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
            }   
         } else {
            mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
         }
	  }
   } else {
      mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
   }
}


//////////////////////////////////////////////////////////////////////
//  gestion du timers
/////////////////////////////////////////////////////////////////////

/**
 * mytel_startTimer : enregistre l'heure courante comme heure de demarrage du timer
 * @param tel  
 * @return none
 */
void mytel_startTimer(struct telprop *tel)
{
#if defined(OS_WIN)
    struct _timeb timebuffer;
    _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
    struct timeb timebuffer;
    ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
    tel->startTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
    struct timeval date;
    gettimeofday(&date, NULL);
    _startTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
}


/**
 * mytel_getTimer : retourne le delay 
 * @param tel  
 * @return  delay ecoule entre le demarrage et l'arret du timer (en seconde)
 */

double mytel_getTimer(struct telprop *tel)
{
    double stopTime;
    if ( tel->startTime == 0.0 ) {
       // je retourne une valeur nulle si le timer est arrete
       return 0.0;
    } else {
#if defined(OS_WIN)
      struct _timeb timebuffer;
      _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
      struct timeb timebuffer;
      ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
      stopTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
      struct timeval date;
      gettimeofday(&date, NULL);
      stopTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
      return stopTime - tel->startTime;
   }
}


/**
 * mytel_startTimer : enregistre l'heure courante comme heure de demarrage du timer
 * @param tel  
 * @return  delay ecoule entre le demarrage et l'arret du timer (en seconde)
 */

double mytel_stopTimer(struct telprop *tel)
{
    double stopTime;
    double delay;

#if defined(OS_WIN)
   struct _timeb timebuffer;
   _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
   struct timeb timebuffer;
   ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
   stopTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
   struct timeval date;
   gettimeofday(&date, NULL);
   stopTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
   delay = stopTime - tel->startTime;
   // RAZ de l'heure de debut pour indiquer qque le timer est arrete
   tel->startTime = 0.0; 
   return delay;

}


//////////////////////////////////////////////////////////////////////
//  gestion des traces
/////////////////////////////////////////////////////////////////////

void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   int result;
   
   // j'assemble la commande 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
	va_end (mkr);

   if ( strcmp(tel->telThreadId,"") == 0 ) {
      sprintf(ligne,"::console::disp \"libT193: %s\n\" ",message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { ::console::disp \"libT193: %s \n\" } " , tel->mainThreadId, message); 
   }
   result = Tcl_Eval(tel->interp,ligne);

   
}


//#define MOUCHARD

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_lx200.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}
