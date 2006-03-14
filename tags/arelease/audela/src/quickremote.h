// File   :quickremote.f .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __QUICKREMOTE__H__
#define __QUICKREMOTE__H__


#define QUICKREMOTE_OK 0
#define QUICKREMOTE_ERROR -1

int quickremote_open();
int quickremote_close();
int quickremote_write(char c);


#endif
