/* lapin.c
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

#include <version.h>
#include "sysexp.h"    /* definition de OS_* */

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>    /* atoi, calloc, free, putenv, getenv */
#include <time.h>      /* time, ftime, strftime, localtime */
#include <sys/timeb.h> /* ftime, struct timebuffer */
#include <stdarg.h>    /* va_list, etc. */
#include <string.h>    /* pour strcat, strcpy */
#include <tcl.h>
#include <tk.h>
#if defined(OS_LIN) || defined(OS_MACOS)
#include <unistd.h>    /* getcwd */
#endif

/*
 * Defines
 */
#define LOG_FILENAME     "audela.log"
#define EXE_NAME         "audela.exe"
#define DEFAULT_SCRIPT   "audela.tcl"
#define MAX_STRING       256
// #define AUDELA_VERSION   "1.333"

#if defined(OS_WIN)
#define PATH_SEP         '\\'
#define PATH_STRING_SEP  "\\"
#else
#define PATH_SEP         '/'
#define PATH_STRING_SEP  "/"
#endif

#define __DEBUG_AUDELA__


/*
 * Global variables
 */
static int gVerbose = 0;
static char log_filename[256];
void log_write(char *fmt,...);

#if defined(OS_WIN)
HINSTANCE ghInstance;
#endif

/*
 * Functions prototypes
 */

#ifdef _Windows
int PASCAL WinMain(HINSTANCE,HINSTANCE,LPSTR,int);
#else
int main(int argc, char **argv);
#endif
void load_library(Tcl_Interp *interp, char *s);
int Tk_AppInit(Tcl_Interp *interp);


//------------------------------------------------------------------------------
// Log functions
//
#if defined(OS_LIN) || defined(OS_MACOS)
#define LOG(what...) log_write(what)
#endif
#if defined(OS_WIN)
#define LOG log_write
#endif

#if defined(__DEBUG_AUDELA__)
#define LOGDEBUG LOG
#else
#if defined(OS_LIN) || defined(OS_MACOS)
#define LOGDEBUG(what...)
#endif
#if defined(OS_WIN)
#define LOGDEBUG
#endif
#endif


/*
 * char* audela_getfitsdate(char *buf, size_t size)
 *   Generates a FITS compliant string into buf representing the date at which
 *   this function is called. Returns buf.
 */
char* audela_getfitsdate(char *buf, size_t size)
{
#if defined(OS_WIN)
   #ifdef _MSC_VER
      /* cas special a Microsoft C++ pour avoir les millisecondes */
      struct _timeb timebuffer;
      time_t ltime;
      _ftime( &timebuffer );
      time( &ltime );
      strftime(buf,size-3,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
      sprintf(buf,"%s.%02d",buf,(int)(timebuffer.millitm/10));
   #else
      struct time t1;
      struct date d1;
      getdate(&d1);
      gettime(&t1);
      sprintf(buf,"%04d-%02d-%02dT%02d:%02d:%02d.%02d : ",d1.da_year,d1.da_mon,d1.da_day,t1.ti_hour,t1.ti_min,t1.ti_sec,t1.ti_hund);
   #endif
#endif
#if defined(OS_LIN)
   struct timeb timebuffer;
   time_t ltime;
   ftime( &timebuffer );
   time( &ltime );
   strftime(buf,size-3,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   sprintf(buf,"%s.%02d",buf,(int)(timebuffer.millitm/10));
#endif
   return buf;
}


/*
 * char* audela_getcwd(char *buf, size_t size)
 *    Stores the current working directory in buf.
 *    Returns buf.
 */
char* audela_getcwd(char *buf, size_t size)
{
#if defined(OS_WIN)
   GetCurrentDirectory(size,buf);
   return buf;
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   return getcwd(buf,size);
#endif
}


/*
 * char* audela_join_filename(char *root, char *tail)
 *    Add tail to the root path using the right path separator according
 *    to the operating system. Returns a pointer to the result string, that
 *    is root.
 */
char* audela_join_filename(char *root, char *tail)
{
   strcat(root,PATH_STRING_SEP);
   strcat(root,tail);
   return root;
}


/*
 * void log_write(char *fmt,...)
 *    Writes data to the log files. Works likes printf functions, with
 *    a format string, plus the correspondings arguments.
 */
void log_write(char *fmt,...)
{

   char fitsdate[25], s[1024];
   va_list va;
   FILE *f;

   if((f=fopen(log_filename,"at+"))!=NULL) {
      va_start(va,fmt);
      vsprintf(s,fmt,va);
      va_end(va);
      audela_getfitsdate(fitsdate,25);
      fprintf(f,fitsdate);
      fprintf(f," : %s",s);
      fclose(f);
   }

}


/*
 * void audela_parsecmdline(char *cmdline, int *argc, char ***argv)
 *    Break a command line into an array of strings.
 *    Side effect : the array of strings is malloced.
 */
void audela_parsecmdline(char *cmdline, int *argc, char ***argv)
{
   int  i;
   int  indblquotes=0;
   int  index=0;
   char tmparg[256];
   int  tmparg_index = 0;
   int  nb_spaces=0;
   #define COPYARGV {char *s; s =(char*)calloc(1,tmparg_index+1); strcpy(s,tmparg); (*argv)[*argc] = s; *argc += 1; tmparg_index=0; for(i=0;i<256;i++) tmparg[i] = 0;}

   /* Computes an approximation of the number of arguments (find how !!), and
      allocates the array of pointers (tip from tcl sources) */
   while(cmdline[index]!=0) {
      nb_spaces = (cmdline[index]==' ') ? nb_spaces+1 : nb_spaces;
      index++;
   }
   *argv = (char**)calloc(sizeof(char**),nb_spaces+1);

   /* Parse the command line */
   *argc = 0;
   for(i=0;i<256;i++) tmparg[i] = 0;
   index=0;
   while(cmdline[index]!=0) {
      if((index>0) && (cmdline[index]=='\"') && (cmdline[index-1]!='\\')) {
         indblquotes = !indblquotes;
         if (cmdline[index+1]==0) {
            COPYARGV;
         }
         index ++;
         continue;
      }
      if(indblquotes || (cmdline[index]!=' ')) {
         tmparg[tmparg_index++] = cmdline[index];
         if (cmdline[index+1]==0) {
            COPYARGV;
         }
         index++;
         continue;
      }
      if((cmdline[index+1]!=' ') || (cmdline[index+1]==0)) {
         COPYARGV;
      }
      index++;
   }
}


//------------------------------------------------------------------------------
// Point d'entree du logiciel
//
#if defined(OS_WIN)
int PASCAL WinMain(HINSTANCE hCurInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
#else
int main(int argc , char **argv)
#endif
{
   int i, k;
   int default_tcltk_libs = 0;
   char rootpath[MAX_STRING];
   char env_var[MAX_STRING];
   int tcl_argc = 1;
   char *tcl_argv[2];
#if defined(OS_WIN)
   char exename[1024] = EXE_NAME" ";
   int argc;
   char **argv;
   ghInstance=hCurInstance;
#endif

   if(audela_getcwd(rootpath,MAX_STRING-1)==NULL) {
      printf("AudeLA: can't get current working directory. Exiting.\n");
      exit(1);
   }
   strcpy(log_filename,rootpath);
   audela_join_filename(log_filename,LOG_FILENAME);

   LOG("*******************************************************\n");

   /* Parse command line options and create tcl command line */
   /* with the file to source at startup. Under Windows, the */
   /* (argc,argv) are build from the entire command line.    */
#if defined(OS_WIN)
   audela_parsecmdline(strcat(exename,lpCmdLine),&argc,&argv);
#endif
   tcl_argc = 2;
   tcl_argv[0] = argv[0];
   tcl_argv[1] = DEFAULT_SCRIPT;
   for(i=1;i<argc;i++) {
      if(strcmp(argv[i],"--file")==0) {
         tcl_argv[1] = argv[++i];
      } else if(strcmp(argv[i],"--verbose")==0) {
         gVerbose = 1;
      } else if(strcmp(argv[i],"--default-tcltk")==0) {
         default_tcltk_libs = 1;
      } else if(strcmp(argv[i],"--version")==0) {
         printf(AUDELA_VERSION"\n");
         return 0;
      } else if(strcmp(argv[i],"--help")==0) {
         printf("Usage: %s [options]\n",argv[0]);
         printf("Options:\n");
         printf("  --file [fichier]  Utilise [fichier] au lieu de audela.tcl pour demarrer.\n");	 
         printf("  --help            Affiche ce message.\n");	 
         printf("  --verbose         Affiche des messages de debug.\n");
         printf("  --version         Version de AudeLA.\n");
         return 0;
      }
   }
   LOG("Starting new AudeLA session (initial file=%s).\n",tcl_argv[1]);

   /* Assignment of environment variables allows to locate */
   /* the Tcl/Tk libraries and AudeLA+users' libraries     */
   if(default_tcltk_libs==0) {
      sprintf(env_var,"TCL_LIBRARY=%s%c..%clib%ctcl8.0",rootpath,PATH_SEP,PATH_SEP,PATH_SEP);
      putenv(env_var);
      sprintf(env_var,"TK_LIBRARY=%s%c..%clib%ctk8.0",rootpath,PATH_SEP,PATH_SEP,PATH_SEP);
      putenv(env_var);
   }
   sprintf(env_var,"LD_LIBRARY_PATH=%s",rootpath);
   putenv(env_var);

   if(gVerbose) {
      LOG("Environment variable TCL_LIBRARY=%s\n",getenv("TCL_LIBRARY"));
      LOG("Environment variable TK_LIBRARY=%s\n",getenv("TK_LIBRARY"));
      LOG("Environment variable LD_LIBRARY_PATH=%s\n",getenv("LD_LIBRARY_PATH"));
      for(k=0;k<tcl_argc;k++) {
         LOG("argv[%d]=%s\n",k,tcl_argv[k]);
      }
   }

   // Boucle principale de TK, et lancement du programme
   Tk_Main(tcl_argc,tcl_argv,Tk_AppInit);

   // On renvoie 0 pour eviter un warning du compilateur, mais
   // le logiciel ne passe jamais ici !
   return 0;
}


//------------------------------------------------------------------------------
// Chargement d'une librairie dans AudeLA, avec consignation d'erreurs
// dans le fichier audela.log
//
void load_library(Tcl_Interp *interp, char *s)
{
   char t[256];
   sprintf(t,"catch {load %s[info sharedlibextension]} msg",s);
   LOGDEBUG("commande = %s\n",t);
   LOGDEBUG("Tcl_Eval=%p\n",Tcl_Eval);
   //Tcl_Eval(interp,"");
   //LOGDEBUG("result=%s\n",interp->result);
   Tcl_Eval(interp,t);
   LOGDEBUG("result=%s\n",interp->result);
   if(atoi(interp->result)==1) {
      Tcl_Eval(interp,"set msg");
      LOG("%s\n",interp->result);
   } else {
      if(gVerbose) LOG("%s: ok\n",s);
   }
}

//------------------------------------------------------------------------------
// Fonction callback d'initialisation de l'application TK.
//
int Tk_AppInit(Tcl_Interp *interp)
{
#if defined(OS_WIN)
   char ligne[50];
#endif
   LOGDEBUG("interp=%p\n",interp);

   /* Initialisation of TCL and TK libraries */
   if(Tcl_Init(interp)!=TCL_OK) {
      LOG("Tcl initialization failed.\n");
      return TCL_ERROR;
   }
   if(Tk_Init(interp)!=TCL_OK) {
      LOG("Tk initialization failed.\n");
      return TCL_ERROR;
   }

   LOGDEBUG("log_filename=%s\n",log_filename);

   /* Log filename available in the interp, through variable "audelog_filename" */
   Tcl_SetVar(interp,"audelog_filename",log_filename,TCL_GLOBAL_ONLY);

   LOGDEBUG("will load libraries\n");

   /* Standard libraries for AudeLA */
   load_library(interp,"libak");      // Misc. from Alain Klotz
   load_library(interp,"libaudela");  // Acquisition, and preprocssing
   load_library(interp,"libgsltcl");  // Gnu Scientific Library extension for Tcl
   load_library(interp,"libgzip");    // Gzip compression
   load_library(interp,"libjm");      // Misc. from Jacques Michelet
   load_library(interp,"libbm");      // Misc. from Benjamin Mauclaire
   load_library(interp,"libmc");      // Celestial mechanics
   load_library(interp,"librgb");     // Extraction of tri-colored planes from a CCD image
   load_library(interp,"libsext");    // Sextractor code from Bertin
   load_library(interp,"libyd");      // Misc. from Yassine Damerdji
   load_library(interp,"libml");      // Misc. from Myrtille Laas

#if defined(OS_WIN)
   sprintf(ligne,"set audela(hInstance) %d",&ghInstance);
   Tcl_Eval(interp,ligne);
#endif

   return TCL_OK;
}

