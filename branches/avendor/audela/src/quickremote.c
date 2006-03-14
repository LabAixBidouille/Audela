// File   :gp_api.c .
// Date   :05/08/2005
// Author :Michel Pujol
// Description : simple API for FTDI library

#ifdef WIN32
#include <windows.h>
#endif
#include <stdio.h>

#include "ftd2xx.h"
#include "quickremote.h"

// =========== local definiton and types ===========

// =========== local functions prototypes ===========

// =========== local variables ===========
FT_HANDLE ftHandle = NULL;

/**
 *  quickremote_init
 *    ouvre le port FTDI
 *	  active le mode BitBang
 */
int quickremote_open()
{

    FT_STATUS ftStatus ;

    
    ftStatus = FT_Open(0,&ftHandle);
    if (ftStatus != FT_OK) {
        printf("quickremote_open failed!\n");
        return  QUICKREMOTE_ERROR;
    }
    // j'active le mode BitBang avec tous les bits en OUTPUT
    ftStatus = FT_SetBitMode(ftHandle, 0xff, 1);
    if (ftStatus != FT_OK) {
        printf("FT_SetBitMode failed!\n");
        return QUICKREMOTE_ERROR;
    }
    return QUICKREMOTE_OK;

}

int quickremote_close()
{
   FT_STATUS ftStatus ;
   
   if( ftHandle != NULL ) {
      ftStatus = FT_Close(ftHandle);
      if (ftStatus != FT_OK) {
         printf("Open quickremote failed!\n");
         return  QUICKREMOTE_ERROR;
      }
   }
   return QUICKREMOTE_OK;
}


/**
 * ftdipapi_write 
 *    ecrit un octet 
 */
int quickremote_write(char c)
{
    FT_STATUS ftStatus ;
    unsigned long  bytesWritten = 0;

    ftStatus = FT_Write(ftHandle, &c, 1, &bytesWritten);
    if (ftStatus != FT_OK && bytesWritten !=1 ) {
        printf("quickremote_write failed!\n");
        return QUICKREMOTE_ERROR;
    }
    return QUICKREMOTE_OK;


}


