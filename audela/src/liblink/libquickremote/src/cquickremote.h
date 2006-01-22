// File   :link.h .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __QUICKREMOTE__H__
#define __QUICKREMOTE__H__

#include <liblink/liblink.h>

class CQuickremote : public CLink {
   
public:
   CQuickremote();
   virtual ~ CQuickremote();
   
   int open(int usb_index);
   int close();
   int setChar(char c);
   int getChar(char *c);
   int setBit(int numbit, int value);
   int getBit(int numbit, int *value);
   static int listUsb(unsigned long *numDevices, char **list);
   void getLastError(char *message);
   int getIndex(int * usb_index);
   
protected :
   int    index;
   void * ftHandle ;
   char  currentValue;
   unsigned long lastStatus;
   
   
};


#endif
