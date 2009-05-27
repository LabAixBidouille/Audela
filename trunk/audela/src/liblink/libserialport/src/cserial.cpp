/* cserial.cpp
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

// $Id: cserial.cpp,v 1.3 2009-05-27 22:03:06 michelpujol Exp $


#include "sysexp.h"


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "link.h"
#include "util.h"

// =========== local definiton and types ===========

#ifdef OS_WIN
#include <winsock.h>
#define close CloseHandle
#else 
#define ULONG  unsigned long
#define DWORD  unsigned long
#endif

typedef struct _SERIAL_QUEUE_SIZE {
  ULONG  InSize;
  ULONG  OutSize;
} SERIAL_QUEUE_SIZE, *PSERIAL_QUEUE_SIZE;


#define CTL_CODE(DeviceType, Function, Method, Access)( \
  ((DeviceType) << 16) | ((Access) << 14) | ((Function) << 2) | (Method))

#define FILE_DEVICE_SERIAL_PORT           0x0000001b
#define METHOD_BUFFERED                   0
#define BUFFER_SIZE                       16384
#define BAUDRATE                          CBR_300

#define FILE_ANY_ACCESS                   0x00000000
#define FILE_SPECIAL_ACCESS               FILE_ANY_ACCESS
#define FILE_READ_ACCESS                  0x00000001
#define FILE_WRITE_ACCESS                 0x00000002
// contantes d�finies dans serh du DDK
#define IOCTL_SERIAL_CLR_DTR \
  CTL_CODE (FILE_DEVICE_SERIAL_PORT, 10, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_SERIAL_SET_DTR \
  CTL_CODE (FILE_DEVICE_SERIAL_PORT, 9, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_SERIAL_CLR_RTS \
  CTL_CODE (FILE_DEVICE_SERIAL_PORT, 13, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_SERIAL_SET_RTS \
  CTL_CODE (FILE_DEVICE_SERIAL_PORT, 12, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_SERIAL_SET_QUEUE_SIZE \
  CTL_CODE (FILE_DEVICE_SERIAL_PORT, 2, METHOD_BUFFERED, FILE_ANY_ACCESS)



// =========== local functions prototypes ===========

// =========== local variables ===========
#ifdef OS_LIN
char * errorMessage = "";
#endif


// ============= methodes statiques ====================================

/**
 * available
 *    retourne la liste des ports disponibles sur la machine
 *    attention : c'est une methode statique !
 */

int CSerial::getAvailableLinks(unsigned long *pnumDevices, char **list) {
   int result;

#ifdef OS_WIN
   char ligne[1024];
   DWORD pcbNeeded;
   DWORD pcReturned;
   PORT_INFO_2 * portlist;
   int ready;
   void * hDevice;

   *pnumDevices = 0;

   EnumPorts( NULL, 2, 0, 0 , &pcbNeeded, &pcReturned );
   if ( pcbNeeded ) {
      portlist = (PORT_INFO_2*) malloc( pcbNeeded);
      if (EnumPorts( NULL, 2, (unsigned char *) portlist, pcbNeeded , &pcbNeeded, &pcReturned ) != 0 ) {
         *list = (char *) malloc(1024 * pcReturned +1);
         strcpy ( *list, "");
         for(unsigned int i=0 ; i< pcReturned; i++ ) {
            if(strncmp(portlist[i].pPortName, "COM", 3) == 0 ) {
               int index =0;
               sscanf(portlist[i].pPortName,"COM%d:", &index);
               // je teste l'ouverture du port
               hDevice = CreateFile(portlist[i].pPortName,  GENERIC_WRITE|GENERIC_READ, 0, NULL,
               OPEN_EXISTING, 0, NULL);               
               if (hDevice != INVALID_HANDLE_VALUE) {
                  CloseHandle(hDevice);
                  ready = 1;
               } else {
                   ready = 0;
               }
               
               if (ready == 1) {
                  sprintf(ligne, "{ %d \"%s\" } ", index,  portlist[i].pPortName );
                  strcat(*list, ligne);
                  *pnumDevices++;
               }
            }
         } 
         result = LINK_OK;
      } else  {
         result = LINK_ERROR;
      }
   } else  {
      result = LINK_ERROR;
   }
   if( result == LINK_ERROR) {
      // si numDevices = 0, il faut reserver au moins un caractere 
      *list = (char *) malloc(+1);
      strcpy ( *list, "");
   }
   pcbNeeded = pcbNeeded;
   pcReturned = pcReturned;
#endif

#ifdef OS_LIN
  *list = (char *) malloc(1024 * +1);
  sprintf( *list, "{ 0 \"/dev/parport0\" }");
  result = LINK_OK;
#endif
  
   return result;
}

/**
 * getGenericName
 *    retourne le nom generique de la liaison 
 *    attention : c'est une methode statique !
 */

char * CSerial::getGenericName() {
#ifdef OS_LIN
   return "/dev/ttyS";
#else
   return "COM";
#endif
}


// ============ implementation des methodes de CSerial ==========================
CSerial::CSerial() : CLink()
{
   strcpy(index,"");
   hDevice = NULL;
}

/**
* ~CSerial 
*    ferme le port parallele
*    ( le desctruteur de la classe m�re ~Clink est appel� implicitement)
*/

CSerial::~CSerial() 
{

}

char * CSerial::getLastSystemErrorMessage() {

#ifdef OS_LIN
	// je retourne un message vide par defaut
	return errorMessage;
#else
      LPTSTR lpMsgBuf;

      // je recupere le message syst�me
      FormatMessage( 
          FORMAT_MESSAGE_ALLOCATE_BUFFER | 
          FORMAT_MESSAGE_FROM_SYSTEM | 
          FORMAT_MESSAGE_IGNORE_INSERTS,
          NULL,
          GetLastError(),
          MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
          (LPTSTR) &lpMsgBuf,
          0,
          NULL 
      );
   return lpMsgBuf;
#endif

}

/**
*  init
*    ouvre le port serie
*	  active le mode BitBang
*/
int CSerial::openLink(int argc, char **argv) {
   int result = LINK_OK;
   char name[256];
   int  openFlag = 1;

   sprintf(name, "COM%s",index);
   
   // je lis les parametres optionnels 
   if (argc >= 2) {
      for (int kk = 5; kk < argc; kk++) {

         if (strcmp(argv[kk], "-noopen") == 0) {
            openFlag = 0;
         }
      }
   }

   if ( openFlag == 1 ) {
#ifdef OS_LIN
      setLastMessage("Error openLink->GetCommState : not implemented for Linux");
      result = LINK_ERROR;
#else
   
      DCB dcb;
   	COMMTIMEOUTS commtimeouts;
   	SERIAL_QUEUE_SIZE queueSize;
   	DWORD bytesReturned;

      hDevice = NULL;
      hDevice = CreateFile( name,
         GENERIC_READ | GENERIC_WRITE,
         0,    // must be opened with exclusive-access
         NULL, // no security attributes
         OPEN_EXISTING, // must use OPEN_EXISTING
         FILE_FLAG_OVERLAPPED,    // not overlapped I/O
         NULL  // hTemplate must be NULL for comm devices
         );
      
      if (hDevice == INVALID_HANDLE_VALUE)
      {
         LPVOID lpMsgBuf;
         
         // je recupere le message syst�me
         FormatMessage( 
            FORMAT_MESSAGE_ALLOCATE_BUFFER | 
            FORMAT_MESSAGE_FROM_SYSTEM | 
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
            (LPTSTR) &lpMsgBuf,
            0,
            NULL 
            );
         
         setLastMessage("Error openLink->CreateFile : %s", lpMsgBuf);
         result = LINK_ERROR;
      }
      
      queueSize.InSize = BUFFER_SIZE;
      queueSize.OutSize = BUFFER_SIZE;
      DeviceIoControl(hDevice,IOCTL_SERIAL_SET_QUEUE_SIZE,&queueSize,sizeof(queueSize),NULL,0,&bytesReturned,NULL);
      
      if (!GetCommState (hDevice, &dcb))
      {
         LPVOID lpMsgBuf;
         
         // je recupere le message syst�me
         FormatMessage( 
            FORMAT_MESSAGE_ALLOCATE_BUFFER | 
            FORMAT_MESSAGE_FROM_SYSTEM | 
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
            (LPTSTR) &lpMsgBuf,
            0,
            NULL 
            );
         
         setLastMessage("Error openLink->GetCommState : %s", lpMsgBuf);
         closeLink();
         result = LINK_ERROR;
      }
      
      dcb.DCBlength = sizeof (DCB);
      dcb.BaudRate = BAUDRATE;
      dcb.fBinary = FALSE;
      dcb.fParity = FALSE;
      dcb.fOutxCtsFlow = FALSE;
      dcb.fOutxDsrFlow = FALSE;
      dcb.fDtrControl = DTR_CONTROL_DISABLE;
      dcb.fDsrSensitivity = FALSE;
      dcb.fTXContinueOnXoff = TRUE;
      dcb.fOutX = 0;
      dcb.fInX = 0;
      dcb.fErrorChar = FALSE;
      dcb.fNull = FALSE;
      dcb.fRtsControl = RTS_CONTROL_DISABLE;
      dcb.fAbortOnError = FALSE;
      dcb.XonLim = 0;
      dcb.XoffLim = 0;
      dcb.ByteSize = 8;
      dcb.Parity = NOPARITY;
      dcb.StopBits = ONESTOPBIT;
      dcb.fNull = false;
      dcb.XonChar = NULL;
      dcb.XoffChar = NULL;
      dcb.ErrorChar = NULL;
      dcb.EofChar = NULL;
      dcb.EvtChar = NULL;
      
      if (!SetCommState (hDevice, &dcb))
      {
         LPVOID lpMsgBuf;
         
         // je recupere le message syst�me
         FormatMessage( 
            FORMAT_MESSAGE_ALLOCATE_BUFFER | 
            FORMAT_MESSAGE_FROM_SYSTEM | 
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
            (LPTSTR) &lpMsgBuf,
            0,
            NULL 
            );
         
         setLastMessage("Error openLink->SetCommState : %s", lpMsgBuf);
         closeLink();
         result = LINK_ERROR;
      }
      
      commtimeouts.ReadIntervalTimeout = 0;
      commtimeouts.ReadTotalTimeoutMultiplier = 0;
      commtimeouts.ReadTotalTimeoutConstant = 0;
      commtimeouts.WriteTotalTimeoutConstant = 0;
      commtimeouts.WriteTotalTimeoutMultiplier = 0;
      
      if (!SetCommTimeouts(hDevice, &commtimeouts))
      {
         LPVOID lpMsgBuf;
         
         // je recupere le message syst�me
         FormatMessage( 
            FORMAT_MESSAGE_ALLOCATE_BUFFER | 
            FORMAT_MESSAGE_FROM_SYSTEM | 
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
            (LPTSTR) &lpMsgBuf,
            0,
            NULL 
            );
         
         setLastMessage("Error openLink->SetCommState : %s", lpMsgBuf);
         closeLink();
         result = LINK_ERROR;
      }
#endif
   }
   return LINK_OK;
}

int CSerial::closeLink()
{

#if defined(OS_WIN)
   if( hDevice != NULL ) {
      CloseHandle(hDevice);
      hDevice = NULL;
   }
#endif

#if defined(OS_LIN)
   close(fileDescriptor);
#endif


   return LINK_OK;
}


/**
* setChar 
*    ecrit un octet 
*/
int CSerial::setChar(char c)
{
   int result = LINK_OK;   
	setLastMessage("Error CSerial::setChar : not implemented");
   result = LINK_ERROR;
   return result;
}

/**
* getChar 
*    lit un octet 
*/
int CSerial::getChar(char *c) {
 
   int result = LINK_OK;   
	setLastMessage("Error CSerial::getChar : not implemented");
   result = LINK_ERROR;
   return result;

}


int CSerial::writeBit( DWORD dwIoControlCode) {
#if defined(OS_LIN) 
	setLastMessage("Error CSerial::writeBit : not implemented");
   return LINK_ERROR;
#else
   DWORD bytesReturned;
   if ( DeviceIoControl(hDevice,dwIoControlCode,NULL,0,NULL,0,&bytesReturned,NULL) == FALSE ) {
      setLastMessage("Error writeBit DeviceIoControl: %s", getLastSystemErrorMessage());
      return LINK_ERROR;
   } else {
      return LINK_OK;
   }
#endif
}
 
/**
* setBit 
*    modifie un bit et ecrit l'octet 
*/
int CSerial::setBit(int bitNum, int value)
{
   int result; 

   switch (bitNum) {
      case SERIAL_DTR_BIT :
         if (value) {
            result = writeBit(IOCTL_SERIAL_SET_DTR);
         } else {
            result = writeBit(IOCTL_SERIAL_CLR_DTR);
         }
         break;
      case SERIAL_RTS_BIT :
         if (value) {
            result = writeBit(IOCTL_SERIAL_SET_RTS);
         } else {
            result = writeBit(IOCTL_SERIAL_CLR_RTS);
         }
         break;
      default :
         setLastMessage("Error setBit incorrect bit number %d", bitNum);
         result = LINK_ERROR;
         break;
   }
   return result;
}


/**
* getBit 
*    lit un octet  et retourne la valeur d'un bit
*/
int CSerial::getBit(int bitNum, int *value)
{
   setLastMessage("Error getBit NOT IMPLEMENTED");
   return LINK_ERROR;
}
