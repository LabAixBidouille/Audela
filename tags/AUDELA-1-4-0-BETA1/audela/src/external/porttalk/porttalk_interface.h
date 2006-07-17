/*
 * porttalk_interface.h
 *
 * prototypes des fonctions implementees dans porttalk_interface.c
 *
 */


extern unsigned char OpenPortTalk(int argc, char ** argv, char * resultMessage );
unsigned  char GrantPort( char *port,  char * resultMessage  );
extern void ClosePortTalk( void);


