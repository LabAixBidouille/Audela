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

#include <stdio.h>
#include <NIDAQmx.h>       // API pour driver NI-DAQmx (National Intrument)
#include "telescop.h"



#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

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


// fonctions locales
void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) ;
int mytel_readUsbCard(struct telprop *tel, unsigned char *data);
int mytel_getBit(struct telprop *tel, unsigned char data, int numbit);
void mytel_startTimer(struct telprop *tel);
double mytel_stopTimer(struct telprop *tel);


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
	uInt32      data=0xffffffff;
   char        hpcom[128]={'\0'};
   char        usbport[128]={'\0'};
	//int32		written;
   int         i;
   int         result = 0;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   int k;

   // j'intialise les variables
   strcpy(tel->channel , "");
   tel->outputTaskHandle = 0;
   tel->inputTaskHandle = 0;   
   tel->consoleLog = 1;    // j'active les traces dans la console pour les premiers tests 
   tel->filterMaxDelay = 10;  
   tel->filterCurrentDelay = 0;  

   tel->northRelay         = 0;
   tel->southRelay         = 1;
   tel->estRelay           = 2;
   tel->westRelay          = 3;
   tel->decreaseFilterRelay = 4;
   tel->increaseFilterRelay = 5;
   tel->minDetectorFilterInput = 6;
   tel->minDetectorFilterInput = 7;
   tel->outputData = 0;


   // je lis les parametres optionels
   for (i=3;i<argc-1;i++) {
	   if (strcmp(argv[i],"-hpcom")==0) {
			   strcpy(hpcom, argv[i+1]);
      }
	   if (strcmp(argv[i],"-usbport")==0) {
			   strcpy(usbport, argv[i+1]);
		}
	   if (strcmp(argv[i],"-usbline")==0) {
         char value;

         // j'initialise northRelay
         value = argv[i+1][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->northRelay = value; 
         } else {
            sprintf(tel->msg,"northRelay=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise southRelay
         value = argv[i+2][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->southRelay = value; 
         } else {
            sprintf(tel->msg,"southRelay=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise estRelay
         value = argv[i+3][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->estRelay = value; 
         } else {
            sprintf(tel->msg,"estRelay=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise westRelay
         value = argv[i+4][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->westRelay = value; 
         } else {
            sprintf(tel->msg,"westRelay=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise decreaseFilterRelay
         value = argv[i+5][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->decreaseFilterRelay = value; 
         } else {
            sprintf(tel->msg,"decreaseFilterRelay=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise increaseFilterRelay
         value = argv[i+6][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->increaseFilterRelay = value; 
         } else {
            sprintf(tel->msg,"increaseFilterRelay=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise minDetectorFilterInput
         value = argv[i+7][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->minDetectorFilterInput = value; 
         } else {
            sprintf(tel->msg,"minDetectorFilterInput=%d Must be beetween 0 and 7", value );
            return 1;
         }

         // j'initialise maxDetectorFilterInput
         value = argv[i+8][0] - '0';
         if ( value >= 0 && value <= 7 ) {
            tel->maxDetectorFilterInput = value; 
         } else {
            sprintf(tel->msg,"maxDetectorFilterInput=%d Must be beetween 0 and 7", value );
            return 1;
         }

         i+=9;
		}
   }

   if ( result == 1 ) {
      return 1;
   }

   if ( strcmp(argv[2], "HP1000") == 0 ) {
      if ( strcmp(usbport, "simulation") !=  0 ) {
	      // J'ouvre la connexion de la carte USB-6501
         // argv2 contient le nom du device et du port de la carte USB-6501
	      error = DAQmxCreateTask("",&tel->outputTaskHandle);
         if( ! DAQmxFailed(error) ) {
            char lines[256];

            // je cree le canal en ecriture
	         //error = DAQmxCreateDOChan(tel->outputTaskHandle,usbport,"",DAQmx_Val_ChanForAllLines);
            sprintf(lines, "%s/line%d, %s/line%d, %s/line%d, %s/line%d, %s/line%d, %s/line%d",
                 usbport, tel->northRelay,
                 usbport, tel->southRelay,
                 usbport, tel->estRelay,
                 usbport, tel->westRelay,
                 usbport, tel->decreaseFilterRelay,
                 usbport, tel->increaseFilterRelay);
	         error = DAQmxCreateDOChan(tel->outputTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
         }

         if( ! DAQmxFailed(error) ) {
            // je cree la tache de lecture 
   	      error = DAQmxCreateTask("",&tel->inputTaskHandle);
         }
         if( ! DAQmxFailed(error) ) {
            char lines[256];
            // je crée le canal en lecture
            sprintf(lines, "%s/line%d, %s/line%d",
                 usbport, tel->minDetectorFilterInput,
                 usbport, tel->maxDetectorFilterInput);
	         error = DAQmxCreateDIChan(tel->inputTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
         }
         if( ! DAQmxFailed(error) ) {
	         // je demarre la tache d'ecriture
	         error = DAQmxStartTask(tel->outputTaskHandle);
         }
         if( ! DAQmxFailed(error) ) {
	         // je demarre la tache de lecture
	         error = DAQmxStartTask(tel->inputTaskHandle);
         }
         if( DAQmxFailed(error) ) {
       	   char errBuff[2048]={'\0'};
            // je recupere le message d'erreur
		      DAQmxGetExtendedErrorInfo(errBuff,2048);
            strcpy(tel->msg, errBuff) ;
            result = 1;
	      }
      } else {
         //simulation
         mytel_logConsole(tel, "simul open %s OK",usbport);
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
         
         // je lance la boucle de lecture permanente des coordonnées
      
         /*
         # 19200 : vitesse de transmission (bauds)
         # 0 : 0 bit de parité
         # 8 : 8 bits de données
         # 1 : 1 bits de stop
         */
         sprintf(s,"fconfigure %s -mode \"19200,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); 
         mytel_tcleval(tel,s);
      }
   } else if ( strcmp(argv[2], "PC") == 0 ) { 
      strcpy(tel->msg,"Connexion PC NOT IMPLEMENTED");
      result = 1;
   } else {
      sprintf(tel->msg,"Connexion %s INVALID", argv[2]);
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
   // je ferme la connexion "output"  de la carte USB
 	if( tel->outputTaskHandle!=0 ) {
		DAQmxStopTask(tel->outputTaskHandle);
		DAQmxClearTask(tel->outputTaskHandle);
      tel->outputTaskHandle = 0;
	}

   // je ferme la connexion "intput"  de la carte USB
 	if( tel->inputTaskHandle!=0 ) {
		DAQmxStopTask(tel->inputTaskHandle);
		DAQmxClearTask(tel->inputTaskHandle);
      tel->inputTaskHandle = 0;
	}

   // je ferme le port serie de liaison avec le HP1000
   if( strcmp(tel->channel,"") != 0 ) {
      char s[1024];
      sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
      strcpy(tel->channel,"");
   }   

   return 0;
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_radec_coord(struct telprop *tel,char *result)
{


//   char command[1024],response[1024],signe[2],ls[100];
//   int h,d,m,sec;
//   int nbcar_1,nbcar_2;
//   strcpy(result,"");


   // j'initialise a reponse a vide
   //strcpy(response,"");
   // j'attend la reponse "1" ou "0"
   //sprintf(command,"read %s 1",tel->channel); mytel_tcleval(tel,s);
   //strcpy(response,tel->interp->result);

   sprintf(result, "01h22m03s +33d43m12s");


   return 0;
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return 0;
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_radec_move(struct telprop *tel,char *direction)
{
   int result ;

   if ( tel->outputTaskHandle != 0 ) {
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

      // je cree le masque 
      mask = 1 << numbit;
      // je force à 1 le bit correspondant 
      tel->outputData |= mask;
      result = mytel_sendCommand(tel , tel->outputData);
   } else {
      // je simule l'envoi de la commande
      mytel_logConsole(tel, "simul radec move %s OK",direction);
      result = 0;
   }
   return result;
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   int result ;

   if ( tel->outputTaskHandle != 0 ) {
      char mask; 
      int numbit;

      if ( strlen(direction) > 0 ) {
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
         // je force à 1 le bit correspondant 
         tel->outputData &= ~mask;
      } else {
         // je cree le masque northRelay
         mask = 1 << tel->northRelay;
         // je force à 1 le bit correspondant 
         tel->outputData &= ~mask;

         // je cree le masque 
         mask = 1 << tel->southRelay;
         // je force à 1 le bit correspondant 
         tel->outputData &= ~mask;

         // je cree le masque 
         mask = 1 << tel->estRelay;
         // je force à 1 le bit correspondant 
         tel->outputData &= ~mask;

         // je cree le masque 
         mask = 1 << tel->westRelay;
         // je force à 1 le bit correspondant 
         tel->outputData &= ~mask;
      }
      result = mytel_sendCommand(tel , tel->outputData);
   } else {
      // je simule l'envoi de la commande
      mytel_logConsole(tel, "simul radec stop %s OK",direction);
   }
   return 0;
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return 0;
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return 0;
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return 0;
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


//-------------------------------------------------------------
// gestion des atténuateurs 
//-------------------------------------------------------------


int tel_filter_init(struct telprop *tel, double filterMaxDelay) {
   

   tel->filterMaxDelay = tel->filterMaxDelay;

   // j'ecrete la valeur courant pour dne pas provoquer une situation incohérente
   if ( tel->filterCurrentDelay > tel->filterMaxDelay ) {
      tel->filterCurrentDelay = tel->filterMaxDelay;
   }

   if ( tel->outputTaskHandle != 0 ) {
      // je simule l'envoi de la commande
      mytel_logConsole(tel, "simul filter init %f OK", filterMaxDelay);
   }

   return 0;
   
}

int tel_filter_coord(struct telprop *tel, char * coord) {
   int result;

   if ( tel->outputTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputData;
      result = mytel_readUsbCard(tel, &inputData);
      if ( result == 0 ) {
         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputData, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputData, tel->maxDetectorFilterInput);

         if ( min == 1 ) {
            tel->filterCurrentDelay = 0;
         } else if (max == 1 ) {
            tel->filterCurrentDelay = tel->filterMaxDelay;
         } 

         // je calcule le pourcentage par raport au delai max
         sprintf(coord, "%d", (int) (tel->filterCurrentDelay * 100.0 / tel->filterMaxDelay) ); 
         result = 0;
      }

   } else {
      strcpy(coord, "23");
      // je simule l'envoi de la commande
      mytel_logConsole(tel, "simul filter coord %s OK", coord);
      result = 0;
   }
   return result;
   
   
}

int tel_filter_move(struct telprop *tel, char * direction) {
   int result = 0;

   if ( tel->outputTaskHandle != 0 ) {
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
      // je force à 1 le bit correspondant 
      tel->outputData |= mask;
      result = mytel_sendCommand(tel, tel->outputData);
      // je memorise l'heure de début du mouvememt
      mytel_startTimer(tel);
      // je memorise le sens du mouvememt
      tel->filterCommand = numbit;      
   } else {
      // je simule l'envoi de la commande
      mytel_logConsole(tel, "simul filter move %s OK",direction);
      result = 0;
   }

   return result;
   
}

int tel_filter_stop(struct telprop *tel) {
   int result;

   if ( tel->outputTaskHandle != 0 ) {
      char mask; 
      double delay;

      // je cree le masque pour decreaseFilterRelay
      mask = 1 << tel->decreaseFilterRelay;
      // je force à 0 le bit correspondant 
      tel->outputData &= ~mask;

      // je cree le masque pour increaseFilterRelay
      mask = 1 << tel->increaseFilterRelay;
      // je force à 0 le bit correspondant 
      tel->outputData &= ~mask;
      // j'enoive la commande sur la carte
      result = mytel_sendCommand(tel, tel->outputData);
      
      // je memorise l'heure de début du mouvememt
      delay = mytel_stopTimer(tel);

      if (tel->filterCommand == tel->decreaseFilterRelay) {
         // diminution de l'attenuateur => je diminue le temps cumulé
         tel->filterCurrentDelay -= delay;
         if (tel->filterCurrentDelay < 0.0 ) {
            tel->filterCurrentDelay = 0.0;
         } 
      } else {
         // augmentation de l'attenuateur => j'augmente le temps cumulé
         tel->filterCurrentDelay += delay;
         if (tel->filterCurrentDelay > tel->filterMaxDelay ) {
            tel->filterCurrentDelay = tel->filterMaxDelay;
         } 
      }


    } else {
      // je simule l'envoi de la commande
      mytel_logConsole(tel, "simul filter stop OK");
      result = 0;
   }
   return result;
   
}





/**
 * mytel_sendCommand : send a command to the telescop
 * @param tel  
 * @param command : long integer 
 * @return 0=OK 1=erreur
 */
int mytel_sendCommand(struct telprop *tel, int command) {
	char     ligne[1024];
	int      cr = 0;
   int      error=0;
   //uInt32   data=0;
   uInt8   data=0;
   int32	   written;

   data = (uInt8) command;

   if ( tel->consoleLog == 1 ) {
      // j'affiche une trace dans la console
      mytel_logConsole(tel, "T193 command: %d",data); 
      Tcl_Eval(tel->interp,ligne);
   }

   // DAQmx Write Code
   // parametres : 
   //    outputTaskHandle outputTaskHandle,  
   //    int32 numSampsPerChan,        1
   //    bool32 autoStart,             1
   //    float64 timeout,              10.0 seconds
   //    bool32 dataLayout,            DAQmx_Val_GroupByChannel
   //    const uInt32 writeArray[],    data 
   //    int32 *sampsPerChanWritten,   written
   //    bool32 *reserved);            NULL
	//error = DAQmxWriteDigitalU32(tel->outputTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&data,&written,NULL);
   error = DAQmxWriteDigitalU8(tel->outputTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&data,&written,NULL);
    

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
int mytel_readUsbCard(struct telprop *tel, unsigned char *data ) {
	char     ligne[1024];
	int      cr = 0;
   int      error=0;
   int32	   readden;

   // DAQmxReadDigitalU8
   // parametres : 
   //    outputTaskHandle outputTaskHandle,  
   //    int32 numSampsPerChan,        1
   //    float64 timeout,              10.0 seconds
   //    bool32 dataLayout,            DAQmx_Val_GroupByChannel
   //    const uInt32 writeArray[],    data 
   //    int32 *sampsPerChanWritten,   readden elements nb
   //    bool32 *reserved);            NULL 
   error = DAQmxReadDigitalU8 (tel->inputTaskHandle, 1, 10.0, DAQmx_Val_GroupByChannel, data, 1, &readden, NULL);

   if( DAQmxFailed(error)) {
      // je copie le message d'erreur
		DAQmxGetExtendedErrorInfo(tel->msg,1024);
      cr = 1;
   } else {
      if ( tel->consoleLog == 1 ) {
         // j'affiche une trace dans la console
         mytel_logConsole(tel,"T193 read USB: %d",*data); 
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
int mytel_getBit(struct telprop *tel, unsigned char data, int numbit)
{
   unsigned char mask; 
   unsigned char tempValue;
   char result;

   if(numbit <0 || numbit >7 ) {
      return 0;
   }

   mask = 1 << numbit;
   
   tempValue = data & mask;

   if( tempValue ==0 ) {
      result = 0;
   } else {
      result = 1;
   }

   return result;
}


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

double mytel_stopTimer(struct telprop *tel)
{
    double stopTime;
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

void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   
   // j'assemble la commande 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
	va_end (mkr);

   sprintf(ligne,"::console::disp \"libT193: %s\n\" ",message); 
   Tcl_Eval(tel->interp,ligne);

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
