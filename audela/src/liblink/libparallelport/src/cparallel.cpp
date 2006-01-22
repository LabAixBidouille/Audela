// File   :quickremote.c .
// Date   :05/08/2005
// Author :Michel Pujol
// Description : simple API for FTDI library

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#include <winspool.h>   // for EnumPorts
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "link.h"

#define OS_WIN_USE_PARRALLEL_OLD_STYLE

// =========== local definiton and types ===========

// =========== local functions prototypes ===========

// =========== local variables ===========
#define INCORRECT_BIT         1
#define INCORRECT_VALUE       2
#define HANDLE_ALREADY_OPEN   3


// ============= methodes statiques ====================================
//  appel au construteur local
CLink * createLink() {
   return new CParallel();
}

/**
 * available
 *    retourn la liste des ports disponibles sur la machine
 */

int available(unsigned long *pnumDevices, char **list) {
#ifdef OS_WIN
   int result;
   DWORD pcbNeeded;
   DWORD pcReturned;
   PORT_INFO_2 * portlist;
   char ligne[1024];

   *pnumDevices = 0;

   EnumPorts( NULL, 2, 0, 0 , &pcbNeeded, &pcReturned );
   if ( pcbNeeded ) {
      portlist = (PORT_INFO_2*) malloc( pcbNeeded);
      if (EnumPorts( NULL, 2, (unsigned char *) portlist, pcbNeeded , &pcbNeeded, &pcReturned ) != 0 ) {
         *list = (char *) malloc(1024 * pcReturned +1);
         strcpy ( *list, "");
         for(unsigned int i=0 ; i< pcReturned; i++ ) {
            if(strncmp(portlist[i].pPortName, "LPT", 3) == 0 ) {
               int index =0;
               sscanf(portlist[i].pPortName,"LPT%d:", &index);
               sprintf(ligne, "{ %d \"%s\" } ", index,  portlist[i].pPortName );
               strcat(*list, ligne);
               *pnumDevices++;
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

#ifdef OS_WIN
   // not implemented
  result = LINK_ERROR;
#endif
  
   return result;
}


// ============ implementation des methodes de CParallel ==========================

CParallel::CParallel()
{

}

CParallel::~CParallel()
{


}


/**
*  init
*    ouvre le port parallele
*	  active le mode BitBang
*/
int CParallel::init(int argc, char **argv) {
   int result = LINK_OK;


#if defined(OS_LIN)
   int buffer; /**< buffer mode of parallel port */
   char name[128];

   sprintf(name, "/dev/parport%d", index);
   
   if (-1 == (fileDescriptor = open(name, O_RDWR))) {
      result = LINK_ERROR;
   } else if (ioctl(fileDescriptor, PPCLAIM)) {
      ioctl(fileDescriptor, PPRELEASE);
      close(fileDescriptor);
      fileDescriptor = -1;
      result = LINK_ERROR;
   } else {

      buffer = IEEE1284_MODE_BYTE;

      if (ioctl(fileDescriptor, PPSETMODE, &buffer)) {
         ioctl(fileDescriptor, PPRELEASE);
         close(fileDescriptor);
         fileDescriptor = -1;
         result = LINK_ERROR;
      }
   }

#endif

#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)

   address = 0x378;

#else

   DWORD nNumberOfBytesWritten = 0;
   char name[128];
   
   sprintf(name, "LPT%d", index);
   hLongExposureDevice =
      CreateFile(name, GENERIC_WRITE, 0, NULL,
                 OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (hLongExposureDevice == INVALID_HANDLE_VALUE) {
      result = LINK_ERROR;
   } 

#endif
#endif


   if( result == LINK_OK) {
      // j'initialise la sortie à 0
      result = setChar((char)0);
   }
   return result;
   
}

int CParallel::close()
{

#if defined(OS_LIN)
   close(fileDescriptor);
#endif

#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)

#else 
   if( hLongExposureDevice != INVALID_HANDLE_VALUE ) {
      CloseHandle(hLongExposureDevice);
   }
#endif
#endif
   
   return LINK_OK;
}


/*
 * Sortie sur un port donne.
 */
void parallel_out(unsigned short a, unsigned char d)
{
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        mov dx, a 
        mov al, d 
        out dx, al
    }
/* *INDENT-ON* */
#elif defined(OS_LIN)
    outb(d, a);
#elif defined(OS_MACOS)
#endif
}


/**
* ftdipapi_write 
*    ecrit un octet 
*/
int CParallel::setChar(char c)
{
   int result = LINK_OK;

#if defined(OS_LIN)
   // Write a byte 
   if (ioctl(fileDescriptor, PPWDATA, &c)) {
      ioctl(fileDescriptor, PPRELEASE);
      close(fileDescriptor);
      fileDescriptor = -1;
      result = LINK_ERROR;
   }
#endif


#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)
   parallel_out(address, c);
#else
   DWORD nNumberOfBytesWritten = 0;

   if (!WriteFile (hLongExposureDevice,  &c, 1, &nNumberOfBytesWritten, NULL)
       || nNumberOfBytesWritten != 1) {
      CloseHandle(hLongExposureDevice);
      hLongExposureDevice = INVALID_HANDLE_VALUE;
      result = LINK_ERROR;
   }
#endif
#endif

   if( result == LINK_OK) {
      currentValue = c;
   }
   return result;
}

/**
* ftdipapi_write 
*    ecrit un octet 
*/
int CParallel::getChar(char *c) {
   
   
   // not implemented
   return LINK_ERROR;

}

/**
* ftdipapi_write 
*    ecrit un octet 
*/
int CParallel::setBit(int numbit, int value)
{
   unsigned long  bytesWritten = 0;
   char mask; 
   char tempValue;
   int result;
   
   
   if(numbit <0 || numbit >7 ) {
      lastStatus = INCORRECT_BIT;
      return LINK_ERROR;
   }

   mask = 1 << numbit;
   tempValue = currentValue;
   
   if (value == 1 ) {
       tempValue |= mask;
   } else if( value == 0) {
      tempValue &= ~mask;
   } else {
      lastStatus = INCORRECT_VALUE; 
      return LINK_ERROR;
   }

   result = setChar(tempValue);
   if( result == LINK_OK) {
      currentValue = tempValue;
   }
      
   return result;
}


/**
* ftdipapi_write 
*    ecrit un octet 
*/
int CParallel::getBit(int numbit, int *value)
{
   unsigned long  bytesWritten = 0;
   char mask; 
   char tempValue;

   if(numbit <0 || numbit >7 ) {
      return LINK_ERROR;
   }

   mask = 1 << numbit;
   
   tempValue = (int) (currentValue && mask );

   if( tempValue ==0 ) {
      *value = 0;
   } else {
      *value = 1;
   }

   return LINK_OK;
}


void CParallel::getLastError(char *message) {
   
   switch( lastStatus) {
   case  INCORRECT_BIT:
      strcpy(message,"INCORRECT BIT ");
      break;

   case  INCORRECT_VALUE:
      strcpy(message,"INCORRECT VALUE");
      break;

   case  HANDLE_ALREADY_OPEN:
      strcpy(message,"HANDLE ALREADY OPEN");
      break;

          
   }


}



/**
*  getAdress
*    retourne l'adress du port parallele
*/
int CParallel::getAddress( int *a_address)
{
   *a_address = address;
   return LINK_OK;
}

/**
*  getName
*    retourne l'adress du port parallele
*/
int CParallel::getIndex( int *pindex)
{
   *pindex = index;
   return LINK_OK;
}
