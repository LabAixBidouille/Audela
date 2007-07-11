/* libstd.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#define __DLL__
#include "libstd.h"
#include "audela.h"
#include "libtt.h"            // for TFLOAT, LONG_IMG, TT_PTR_...

#if defined(OS_LIN) || defined(OS_UNX) || defined(OS_MACOS)
   #include <sys/timeb.h>
   #include <stdlib.h>
   #include <string.h>
   #include <dlfcn.h>
   #include <unistd.h>
   #include <stdio.h>
   #include <sys/types.h>
   #include <sys/socket.h>
   #include <netinet/in.h>
   #include <netdb.h>
#endif
#if defined(OS_UNX) || defined(OS_MACOS)
   #include <sys/time.h>
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   #include <time.h>
#endif

#if defined(OS_WIN)
   #include <windows.h>
   #include <dos.h>
   #include <stdarg.h>    /* pour les vaarg */
   #if defined(_MSC_VER)
      #include <sys/timeb.h>
      #include <time.h>
   #endif
   #include <winsock.h>
   #include <iostream.h>
   #include <porttalk_interface.h>
#endif

//------------------------------------------------------------------------------
// Prototypes
//
#if defined(OS_WIN)
extern "C" int __stdcall Std_Init(Tcl_Interp*);
#endif /* defined(OS_WIN) */

#if defined(OS_LIN) || defined(OS_MACOS)
extern "C" int Std_Init(Tcl_Interp*interp);
#endif /* defined(OS_LIN) */

static char default_log_filename[] = "libstd.log";
char *libstd_log_filename;
void LogFile(char*s);
void vlogfile(char *fmt, ...);

char* message(int error);
int CmdTestGetClicks(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdHistory(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdLibstdId(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdAudelaVersion(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int ping(char * hostName, int nbTry, int receivedTimeOut, char *result);

extern int CmdCfa2rgb(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static char audela_version[] = AUDELA_VERSION;


//------------------------------------------------------------------------------
// Divers
//
char *audela_start_dir;
TPlatform gPlatform;

//------------------------------------------------------------------------------
// Gestion du fichier journal.
//
//#define LOG vlogfile
#define LOG
//#define LOGDEBUG LOG
//#define LOGDEBUG
void LogFile(char*s)
{
   FILE *f;
   char s1[27];
   #if defined(OS_WIN)
      #if defined(_MSC_VER)
         /* cas special a Microsoft C++ pour avoir les millisecondes */
         struct _timeb timebuffer;
         char message[50];
         time_t ltime;
         _ftime( &timebuffer );
         time( &ltime );
         strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
         sprintf(s1,"%s.%02d : ",message,(int)(timebuffer.millitm/10));
      #else
         struct time t1;
         struct date d1;
         getdate(&d1);
         gettime(&t1);
         sprintf(s1,"%04d-%02d-%02dT%02d:%02d:%02d.%02d : ",
            d1.da_year,d1.da_mon,d1.da_day,t1.ti_hour,t1.ti_min,t1.ti_sec,t1.ti_hund);
      #endif
   #elif defined(OS_LIN)
      struct timeb timebuffer;
      char message[50];
      time_t ltime;
      ftime( &timebuffer );
      time( &ltime );
      strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
      sprintf(s1,"%s.%02d : ",message,(int)(timebuffer.millitm/10));
   #elif defined(OS_MACOS)
      struct timeval t;
      char message[50];
	  gettimeofday(&t,NULL);
	  strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
      sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);
   #else
      sprintf(s1,"[No time functions available]");
   #endif
   f = fopen(libstd_log_filename,"at+");
   if(f!=NULL) {
      fprintf(f,s1);
      fprintf(f,s);
      fflush(f);
      fclose(f);
   }
}
void vlogfile(char *fmt, ...)
{
   char s[256];
   va_list va;

   va_start(va,fmt);
   vsprintf(s,fmt,va);
   va_end(va);
   LogFile(s);
}

int CmdAudelaVersion(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  Tcl_SetResult(interp,audela_version,TCL_STATIC);
  return TCL_OK;
}

//------------------------------------------------------------------------------
//
//
int CmdTestGetClicks(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[256];
   sprintf(s,"%lu",audela_getms());
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

//------------------------------------------------------------------------------
//
//
int CmdHostaddress(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ip[256];
   char result[256];
   char s[256],*ss;
   unsigned char a0,a1,a2,a3;
   int k;
   struct hostent *p;
   strcpy(result,"{0 0 0 0} {}");
#if defined(OS_WIN)
   WORD        wVer ;
   WSADATA     wsaData ;
   wVer = MAKEWORD(1,1) ;                  // request WinSock version 1.1
   if (WSAStartup(wVer,&wsaData) != 0)  {  // if startup failed
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_OK;
   }
#endif
   if (gethostname(ip,sizeof(ip))==0) {
      p=gethostbyname(ip);
      strcpy(result,"");
      if (p!=NULL) {
         k=0;
         while (p->h_addr_list[k]!=NULL) {
            ss=p->h_addr_list[k];
            a0=(unsigned char)ss[0];
            a1=(unsigned char)ss[1];
            a2=(unsigned char)ss[2];
            a3=(unsigned char)ss[3];
            sprintf(s,"{%u %u %u %u} ",a0,a1,a2,a3);
            strcat(result,s);
            k++;
         }
      } else {
         strcpy(result,"{127 0 0 1} ");
      }
      sprintf(s,"{%s}",ip);
      strcat(result,s);
   }
   Tcl_SetResult(interp,result,TCL_VOLATILE);
   return TCL_OK;
}

//------------------------------------------------------------------------------
//
//
int CmdPing(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[256],ip[256];
   char result[256];
   int res,timeout=1;
   if (argc<2) {
	   sprintf(s,"usage : %s IPAddress ?timeout?",argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
	   strcpy(ip,argv[1]);
      if (argc>=3) {
         timeout=atoi(argv[2]);
         if (timeout<1) { timeout=1; }
         if (timeout>60) {timeout=60;}
      }
      res=ping(ip,1,timeout,s);
      sprintf(result,"{%d} {%s}",res,s);
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_OK;
   }
}

//------------------------------------------------------------------------------
//
//
int CmdPortTalk(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char result[256];
#if defined(OS_WIN)
   int res,timeout=1;
   int i;
   char **ptargv;

   if(argc<2) {
      sprintf(result,"Usage: %s open|close|grant",argv[0]);
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if(strcmp(argv[1],"open")==0) {
      if(argc<3) {
         sprintf(result,"Usage: %s %s {all | ports address}",argv[0],argv[1]);
         Tcl_SetResult(interp,result,TCL_VOLATILE);
         return TCL_ERROR;
      } else {

         ptargv = (char**) calloc(argc - 2,sizeof(char*));
         // je copie les arguments
         for( i = 0; i<(argc-2); i++ ) {
            //strcpy(ptemp+(256*i), argv[i+2] );
            ptargv[i]= argv[i+2];
         }
         res = OpenPortTalk(argc-2, ptargv, result);
         //res =-1;
         //strcpy(result," test");
         free(ptargv);

         if( res == 0 ) {
            Tcl_SetResult(interp,result,TCL_VOLATILE);
         } else {
            Tcl_SetResult(interp,result,TCL_VOLATILE);
            return TCL_ERROR;
         }

      }
   } else if(strcmp(argv[1],"grant")==0) {
      if(argc!=4) {
         sprintf(result,"Usage: %s %s port",argv[0],argv[1]);
         Tcl_SetResult(interp,result,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         GrantPort( argv[2], result);
         Tcl_SetResult(interp,"result",TCL_VOLATILE);
      }
   } else if(strcmp(argv[1],"close")==0) {
      if(argc!=2) {
         sprintf(result,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,result,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         ClosePortTalk();
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      }
   }
   return TCL_OK;

#else
   strcpy(result,"Error : not Windows OS");
   Tcl_SetResult(interp,result,TCL_VOLATILE);
   return TCL_ERROR;
#endif
}


//------------------------------------------------------------------------------
// history --
//   Management d'un historique de chaines de caracteres.
//   Syntaxe : history option ...
//      option = add chaine -> ajoute une chaine de caracteres.
//      option = before     -> renvoie la chaine avant la pos. courante.
//      option = after      -> renvoie la chaine apres la pos. courante.
//      option = synchro    -> synchro du pt courant sur le pt d'insertion et de lecajoute une chaine de caracteres.
//      option = list       -> renvoie la liste des commandes entrees.
//   Reste a faire :
//      option = get num    -> recupere le nieme element relatif.
//      option = dim n      -> dimensionne le buffer.
//      option = clear      -> reinitialise le buffer.
//

#define HISTORYCLASS CHistoryLC
HISTORYCLASS *History=NULL;

int CmdHistory(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];

   if(History==NULL) History = new HISTORYCLASS;

   if(argc<2||argc>3) {
      sprintf(ligne,"Usage: %s add|before|after|synchro|list",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if(strcmp(argv[1],"add")==0) {
      if(argc!=3) {
         sprintf(ligne,"Usage: %s %s chaine",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         History->Add(argv[2]);
      }
   } else if(strcmp(argv[1],"before")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         Tcl_SetResult(interp,History->Backward(),TCL_VOLATILE);
      }
   } else if(strcmp(argv[1],"after")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         Tcl_SetResult(interp,History->Forward(),TCL_VOLATILE);
      }
   } else if(strcmp(argv[1],"synchro")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         History->Synchro();
      }
   } else if(strcmp(argv[1],"list")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         int i = History->List(NULL);
         char *s = (char*)calloc(i,sizeof(char));
         History->List(s);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(s);
      }
   }
   return TCL_OK;
}

int CmdLibstdId(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   Tcl_SetResult(interp,__DATE__,TCL_VOLATILE);
   return TCL_OK;
}

void audelaInit(Tcl_Interp *interp)
{
   char s[256];

   //LOGDEBUG("interp=0x%p\n",interp);

   // Chargement de libtt
   load_libtt();

   // Creation des pools de devices
   buf_pool = new CPool(BUF_PREFIXE);
   tel_pool = new CPool(TEL_PREFIXE);
   cam_pool = new CPool(CAM_PREFIXE);
   //visu_pool = new CPool(VISU_PREFIXE);
   link_pool = new CPool(LINK_PREFIXE);
/*
   // Initialisation du timer pour les temps de pose
   TimerExpiration = NULL;
*/

   // TODO : ca ne sert pas a grand'chose, a verifier, puis supprimer.
   // On utilise getvar2 car getvar genere un core dump sous Linux, avec la 8.3.4
   //sprintf(s,"%s",Tcl_GetVar(interp,"tcl_platform(os)",TCL_GLOBAL_ONLY));
   sprintf(s,"%s",Tcl_GetVar2(interp,"tcl_platform","os",TCL_GLOBAL_ONLY));
   if(strcmp(s,"Windows NT")==0) {
      gPlatform = PF_WINNT;
   } else if(strcmp(s,"Windows 95")==0) {
      gPlatform = PF_WIN95;
   } else if(strcmp(s,"Linux")==0) {
      gPlatform = PF_LINUX;
   }

   Tcl_Eval(interp,"pwd");
   audela_start_dir = (char*)calloc(strlen(interp->result)+5,sizeof(char));
   strcpy(audela_start_dir,interp->result);
   Tcl_SetVar(interp,"audela_start_dir",audela_start_dir,TCL_GLOBAL_ONLY);

   // libstd.cpp : Fonctions de traitement par lots 
   Tcl_CreateCommand(interp,"libstd_id",(Tcl_CmdProc *)CmdLibstdId,NULL,NULL);
   Tcl_CreateCommand(interp,"historik",(Tcl_CmdProc *)CmdHistory,NULL,NULL);

   // tt.cpp : Fonctions de traitement par lots 
   Tcl_CreateCommand(interp,"ttscript",(Tcl_CmdProc *)CmdTtScript3,NULL,NULL);
   Tcl_CreateCommand(interp,"ttscript2",(Tcl_CmdProc *)CmdTtScript2,NULL,NULL);

   Tcl_CreateCommand(interp,"fits2colorjpeg",(Tcl_CmdProc *)CmdFits2ColorJpg,NULL,NULL);
   Tcl_CreateCommand(interp,"fitsheader",(Tcl_CmdProc *)CmdFitsHeader,NULL,NULL);
   Tcl_CreateCommand(interp,"fitsconvert3d",(Tcl_CmdProc *)CmdFitsConvert3d,NULL,NULL);

   Tcl_CreateCommand(interp,"getclicks",(Tcl_CmdProc *)CmdTestGetClicks,NULL,NULL);
   Tcl_CreateCommand(interp,"hostaddress",(Tcl_CmdProc *)CmdHostaddress,NULL,NULL);
   Tcl_CreateCommand(interp,"ping",(Tcl_CmdProc *)CmdPing,NULL,NULL);

   // file_tcl.cpp : Gestion des fichiers RAW, JPEG, PNG
   Tcl_CreateCommand(interp,"cfa2rgb",(Tcl_CmdProc *)CmdCfa2rgb,(void*)link_pool,NULL);

   // Access aux port parallele et serie pour Windows NT, 2000, XP
   Tcl_CreateCommand(interp,"porttalk",(Tcl_CmdProc *)CmdPortTalk,NULL,NULL);

   // pool_tcl.cpp : Gestion de la liste des buffers
   Tcl_CreateCommand(interp,"::buf::create",(Tcl_CmdProc *)CmdCreatePoolItem,(void*)buf_pool,NULL);
   Tcl_CreateCommand(interp,"::buf::list",(Tcl_CmdProc *)CmdListPoolItems,(void*)buf_pool,NULL);
   Tcl_CreateCommand(interp,"::buf::delete",(Tcl_CmdProc *)CmdDeletePoolItem,(void*)buf_pool,NULL);

   // pool_tcl.cpp : Gestion de la liste des cameras
   Tcl_CreateCommand(interp,"::cam::create",(Tcl_CmdProc *)CmdCreatePoolItem,(void*)cam_pool,NULL);
   Tcl_CreateCommand(interp,"::cam::list",(Tcl_CmdProc *)CmdListPoolItems,(void*)cam_pool,NULL);
   Tcl_CreateCommand(interp,"::cam::delete",(Tcl_CmdProc *)CmdDeletePoolItem,(void*)cam_pool,NULL);

   // pool_tcl.cpp : Gestion de la liste des telescopes
   Tcl_CreateCommand(interp,"::tel::create",(Tcl_CmdProc *)CmdCreatePoolItem,(void*)tel_pool,NULL);
   Tcl_CreateCommand(interp,"::tel::list",(Tcl_CmdProc *)CmdListPoolItems,(void*)tel_pool,NULL);
   Tcl_CreateCommand(interp,"::tel::delete",(Tcl_CmdProc *)CmdDeletePoolItem,(void*)tel_pool,NULL);

   // pool_tcl.cpp : Gestion de la liste des liaisons
   Tcl_CreateCommand(interp,"::link::create",(Tcl_CmdProc *)CmdCreatePoolItem,(void*)link_pool,NULL);
   Tcl_CreateCommand(interp,"::link::list",(Tcl_CmdProc *)CmdListPoolItems,(void*)link_pool,NULL);
   Tcl_CreateCommand(interp,"::link::delete",(Tcl_CmdProc *)CmdDeletePoolItem,(void*)link_pool,NULL);
   Tcl_CreateCommand(interp,"::link::available",(Tcl_CmdProc *)CmdAvailablePoolItem,(void*)link_pool,NULL);
   Tcl_CreateCommand(interp,"::link::genericname",(Tcl_CmdProc *)CmdGetGenericNamePoolItem,(void*)link_pool,NULL);


   Tcl_CreateCommand(interp,"audela_version",(Tcl_CmdProc *)CmdAudelaVersion,(void*)NULL,NULL);

   sprintf(s,"%d.%d.%d",AUDELA_VERSION_MAJOR,AUDELA_VERSION_MINOR,AUDELA_VERSION_PATCH);
   Tcl_PkgProvide(interp,"Audela",s);

   sprintf(s,"%d",AUDELA_VERSION_MAJOR);
   Tcl_SetVar2(interp, "audela", "major", s, TCL_GLOBAL_ONLY);
   sprintf(s,"%d",AUDELA_VERSION_MINOR);
   Tcl_SetVar2(interp, "audela", "minor", s, TCL_GLOBAL_ONLY);
   sprintf(s,"%d",AUDELA_VERSION_PATCH);
   Tcl_SetVar2(interp, "audela", "patch", s, TCL_GLOBAL_ONLY);
   Tcl_SetVar2(interp, "audela", "extra", AUDELA_VERSION_EXTRA, TCL_GLOBAL_ONLY);
   Tcl_SetVar2(interp, "audela", "version", AUDELA_VERSION, TCL_GLOBAL_ONLY);
}

//------------------------------------------------------------------------------
// Point d'entree de libaudela en tant que librairie TCL.
//
#if defined(OS_WIN)
extern "C" int __cdecl Audela_Init(Tcl_Interp*interp)
#else
extern "C" int Audela_Init(Tcl_Interp*interp)
#endif
{
   char *s;

   if(interp==NULL) return TCL_ERROR;

   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libaudela.",TCL_STATIC);
      return TCL_ERROR;
   }
   if((s=(char*)Tcl_GetVar(interp,"audelog_filename",0))==NULL) s = default_log_filename;
   libstd_log_filename = (char*)calloc(sizeof(char),strlen(s)+1);
   strcpy(libstd_log_filename,s);

   //LOGDEBUG("-----------------------\n");
   //LOGDEBUG("Entering libstd library\n");

   audelaInit(interp);

   //LOGDEBUG("End of libstd init.\n");

   return TCL_OK;
}

