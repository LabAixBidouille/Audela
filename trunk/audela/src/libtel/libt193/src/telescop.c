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
int mytel_sendCommandTelescop(struct telprop *tel, int command);
int mytel_sendCommandFilter(struct telprop *tel, int command);

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
   char        usbCardName[128]     ="Dev1";    // ces valeurs par defaut seront ecrasées par les paramètres optionels
   char        usbTelescopPort[128] ="port0";
   char        usbFilterPort[128]   ="port1";
   int         i;
   int         result = 0;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   int k;

   // j'intialise les variables
   strcpy(tel->channel , "");
   tel->outputTelescopTaskHandle = 0;
   tel->outputFilterTaskHandle = 0;
   tel->inputFilterTaskHandle = 0;   
   tel->outputTelescopData = 255;
   tel->outputFilterData = 255;
   tel->consoleLog = 0;    // j'active les traces dans la console pour les premiers tests 
   tel->filterMaxDelay = 10;  
   tel->filterCurrentDelay = 0;  

   tel->northRelay         = 0;
   tel->southRelay         = 1;
   tel->estRelay           = 2;
   tel->westRelay          = 3;
   tel->enabledRelay       = 4;
   tel->decreaseFilterRelay = 0;
   tel->increaseFilterRelay = 1;
   tel->minDetectorFilterInput = 2;
   tel->minDetectorFilterInput = 3;


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
            // je crée le canal en lecture
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

            //  je met tous les bits à 1 (position de repos de la commande du télescope) 
            tel->outputTelescopData = 255;
            result = mytel_sendCommandTelescop(tel , tel->outputTelescopData);

            //  je met tous les bits à 1 (position de repos de la commande de l'attenuateur) 
            tel->outputFilterData = 255;
            result = mytel_sendCommandFilter(tel , tel->outputFilterData);
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
         //simulation
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

   // je ferme le port de liaison série avec le HP1000
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

   sprintf(result, "00h00m00.00s +00d00m00s");


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
      // je force à 0 le bit correspondant 
      tel->outputTelescopData &= ~mask;
      result = mytel_sendCommandTelescop(tel , tel->outputTelescopData);
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec move %s OK",direction);
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
         // je force à 1 le bit correspondant 
         tel->outputTelescopData |= mask;
      } else {
         // j'arrete le mouvement dans toutes les directions 

         // je cree le masque northRelay
         mask = 1 << tel->northRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopData |= mask;

         // je cree le masque 
         mask = 1 << tel->southRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopData |= mask;

         // je cree le masque 
         mask = 1 << tel->estRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopData |= mask;

         // je cree le masque 
         mask = 1 << tel->westRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopData |= mask;
      }
      result = mytel_sendCommandTelescop(tel, tel->outputTelescopData);
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec stop %s OK",direction);
      result = 0; 
   }
   return result;
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
// mytel_setControl
//
// Active ou désactive le controle des deplacement du telescope.
// Si le controle n'est pas active, le telescope ne prend pas en compte les mouvements
//
//
// @param tel 
// @param control 0=OFF 1=ON  etat du controle
//
// @return 
//-------------------------------------------------------------

int mytel_setControl(struct telprop *tel,int control) { 
   int result ;

   if ( tel->outputTelescopTaskHandle != 0 ) {
      char mask; 

      if ( control == 1 ) {
         // je cree le masque 
         mask = 1 << tel->enabledRelay;
         // je force à 0 le bit correspondant 
         tel->outputTelescopData &= ~mask;
      } else {
         // je cree le masque 
         mask = 1 << tel->enabledRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopData |= mask;
      }
      result = mytel_sendCommandTelescop(tel , tel->outputTelescopData);
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec control %d OK",control);
      result = 0;
   }
   return result;

}

//-------------------------------------------------------------
// gestion des atténuateurs 
//-------------------------------------------------------------


//-------------------------------------------------------------
// tel_filter_setMax
//
// Inialise la duree de déplement entre les 2 fin de course de l'attenuateur
// Cette durée servira pour calculer le pourcentage d'atténuation
//
// @param tel 
// @param filterMaxDelay  duree de déplacement entre les fin de course (en seconde)
//-------------------------------------------------------------

int tel_filter_setMax(struct telprop *tel, double filterMaxDelay) {   
   tel->filterMaxDelay = filterMaxDelay;

   // j'ecrete la valeur courante pour ne pas provoquer une situation incohérente
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
// retour,la durée de depalcement entre les 2 butées de fin de course 
//
// @param tel 
// @param filterMaxDelay  duree de déplacement entre les fin de course (en seconde)
//-------------------------------------------------------------

int tel_filter_getMax(struct telprop *tel, double *filterMaxDelay) {   
   tel->filterMaxDelay = tel->filterMaxDelay;

   *filterMaxDelay = tel->filterMaxDelay;

   return 0;   
}


//-------------------------------------------------------------
// tel_filter_coord
//
// Retourner les coordonnee
// Cette durée servira pour calculer le pourcentage d'atténuation
//
// @param tel    pointeur struture telprop
// @param coord  chaine de caractere contenant 1 valeurs
//                - le pourcentage d'attenuation ( entre 0 et 100) 
//                -  l'état des butées MIN , MED , MAX
//-------------------------------------------------------------
int tel_filter_coord(struct telprop *tel, char * coord) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputData;
      result = mytel_readUsbCard(tel, &inputData);
      if ( result == 0 ) {
         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputData, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputData, tel->maxDetectorFilterInput);

         // la fin de course est au niveau 0 quand elle est rencontrée
         if ( min == 0 ) {
            tel->filterCurrentDelay = 0;
         } else if (max == 0 ) {
            tel->filterCurrentDelay = tel->filterMaxDelay;
         }

         // je calcule le pourcentage par raport au delai max
         sprintf(coord, "%d", (int) (tel->filterCurrentDelay * 100.0 / tel->filterMaxDelay)); 
         result = 0;
      }

   } else {
      strcpy(coord, "23");
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter coord %s OK", coord);
      result = 0;
   }
   return result;
}


//-------------------------------------------------------------
// tel_filter_extremity
//
// Retourner l'etat des butees aux extremités
//
// @param tel    pointeur struture telprop
// @param extremity  chaine de caractere contenant l'état des butées (MIN , MED , MAX)
//                
//-------------------------------------------------------------
int tel_filter_extremity(struct telprop *tel, char * extremity) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputData;
      result = mytel_readUsbCard(tel, &inputData);
      if ( result == 0 ) {
         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputData, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputData, tel->maxDetectorFilterInput);

         // la fin de course est au niveau 0 quand elle est rencontrée
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
// modifie la position de l'atténuateur
// Cette durée servira pour calculer le pourcentage d'atténuation
//
// @param tel    pointeur struture telprop
// @param coord  chaine de caractere contenant le pourcentage d'attenuation ( entre 0 et 100)
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
      // je force à 0 le bit correspondant 
      tel->outputFilterData &= ~mask;
      result = mytel_sendCommandFilter(tel, tel->outputFilterData);
      // je memorise l'heure de début du mouvememt
      mytel_startTimer(tel);
      // je memorise le sens du mouvememt qui sera utilisé par tel_filter_stop
      tel->filterCommand = numbit;      
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter move %s OK",direction);
      result = 0;
   }

   return result;
   
}

int tel_filter_stop(struct telprop *tel) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      char mask; 
      double delay;

      // je cree le masque pour decreaseFilterRelay
      mask = 1 << tel->decreaseFilterRelay;
      // je force à 1 le bit correspondant 
      tel->outputFilterData |= mask;

      // je cree le masque pour increaseFilterRelay
      mask = 1 << tel->increaseFilterRelay;
      // je force à 1 le bit correspondant 
      tel->outputFilterData |= mask;
      // j'enoive la commande sur la carte
      result = mytel_sendCommandFilter(tel, tel->outputFilterData);
      
      // je memorise l'heure de fin du mouvememt et je calule le délai en millisecondes
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
      //mytel_logConsole(tel, "simul filter stop OK");
      result = 0;
   }
   return result;
   
}





/**
 * mytel_sendCommandTelescop : send a command to the telescop
 * @param tel  
 * @param command : long integer 
 * @return 0=OK 1=erreur
 */
int mytel_sendCommandTelescop(struct telprop *tel, int command) {
	int      cr = 0;
   int      error=0;
   uInt8    data=0;
   int32	   written;

   data = (uInt8) command;

   if ( tel->consoleLog == 1 ) {
      // j'affiche une trace dans la console
      mytel_logConsole(tel, "T193 command: %d",data); 
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
   error = DAQmxWriteDigitalU8(tel->outputTelescopTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&data,&written,NULL);
    

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
 * mytel_sendCommandTelescop : send a command to the telescop
 * @param tel  
 * @param command : long integer 
 * @return 0=OK 1=erreur
 */
int mytel_sendCommandFilter(struct telprop *tel, int command) {
	char     ligne[1024];
	int      cr = 0;
   uInt8   data=0;
   int32	   written;
   int      error=0;
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
   error = DAQmxWriteDigitalU8(tel->outputFilterTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&data,&written,NULL);
    

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
   error = DAQmxReadDigitalU8 (tel->inputFilterTaskHandle, 1, 10.0, DAQmx_Val_GroupByChannel, data, 1, &readden, NULL);

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
