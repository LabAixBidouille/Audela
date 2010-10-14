/*
 * porttalk_interface.h
 *
 * prototypes des fonctions implementees dans porttalk_interface.c
 *
 */


unsigned char OpenPortTalk(int argc, char ** argv, char * resultMessage );
unsigned  char GrantPort( char *port,  char * resultMessage  );
void ClosePortTalk( void);
int  GetPortTalkHandle(void);


