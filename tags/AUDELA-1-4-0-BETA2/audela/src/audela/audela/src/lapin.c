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
#define DEFAULT_SCRIPT_TK   "audela.tcl"
#define MAX_STRING       2048

#if defined(OS_WIN)
#define PATH_SEP         '\\'
#define PATH_STRING_SEP  "\\"
#else
#define PATH_SEP         '/'
#define PATH_STRING_SEP  "/"
#endif



/*
 * Global variables
 */
static int gVerbose = 0;
static int gConsole = 0;
static char log_filename[2048];
static char img_filename[2048];
void log_write(char *fmt,...);

#if defined(OS_WIN)
HINSTANCE ghInstance;
#endif


/*
 * Functions prototypes
 */

void load_library(Tcl_Interp *interp, char *s);
int Tk_AppInit(Tcl_Interp *interp);
int Tcl_AppInit(Tcl_Interp *interp);

#if defined(OS_WIN)
//static BOOL __stdcall   sigHandler (DWORD fdwCtrlType);
static void AppInitExitHandler(ClientData clientData);
void createMsdosConsole();
#endif

//------------------------------------------------------------------------------
// Log functions
//
//#define __LOG_AUDELA_
#if defined(__LOG_AUDELA_)
#if defined(OS_LIN) || defined(OS_MACOS)
#define LOG(what...) log_write(what)
#endif
#if defined(OS_WIN)
#define LOG log_write
#endif
#else
#if defined(OS_LIN) || defined(OS_MACOS)
#define LOG(what...)
#endif
#if defined(OS_WIN)
#define LOG
#endif
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

void GetChemin(char *chemin, unsigned long taille,int end)
{
   char *c;
   c = chemin+strlen(chemin);
   while((*c!=PATH_SEP)&&(c>=chemin)) {
      c--;
   }
   if (c<chemin) {
      *chemin=0;
   } else {
      *(c+end)=0;
   }
}

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
 * char* audela_setcwd(char *buf, size_t size)
 *    Set the current working directory in buf.
 */
void audela_setcwd(char *buf)
{
#if defined(OS_WIN)
   SetCurrentDirectory(buf);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   chdir(buf);
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
void audela_parsecmdline(char *executableFullPath, char *cmdline, int *argc, char ***argv)
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

   // copy executable full path into argv[0] (it main contain spaces)
   //  
   *argv = (char**)calloc(sizeof(char**),nb_spaces+1);
   (*argv)[0]=(char*)calloc(1,strlen(executableFullPath)+1);
   strcpy((*argv)[0],executableFullPath);

   // Parse the command line 
   // ATTENTION :The executable full name must NOT be parsed here because it may contain spaces
   *argc = 1;
   for(i=0;i<256;i++) tmparg[i] = 0;
   index=0;
   while(cmdline[index]!=0) {
      if( (cmdline[index]=='\"') && ((index>0 && cmdline[index-1]!='\\') || (index==0)) ) {
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
// Point d'entree du logiciel pour LINUX ou MAC
//
int main(int argc , char **argv)
{
   int i, k;
   int default_tcltk_libs = 0;
   char rootpath[MAX_STRING];

   char env_var[MAX_STRING];
   int tcl_argc = 1;
   char *tcl_argv[2];

   strcpy(rootpath,argv[0]);
   GetChemin(rootpath,MAX_STRING,0);
   if (strcmp(rootpath,"")==0) {
      if(audela_getcwd(rootpath,MAX_STRING-1)==NULL) {
         printf("AudeLA: can't get current working directory. Exiting.\n");
         exit(1);
      }
   }
   strcpy(log_filename,rootpath);
   audela_join_filename(log_filename,LOG_FILENAME);
   audela_setcwd(rootpath);

   LOG("*******************************************************\n");

   /* Parse command line options and create tcl command line */
   /* with the file to source at startup. Under Windows, the */
   /* (argc,argv) are build from the entire command line.    */

   tcl_argc = 1;
   tcl_argv[0] = argv[0];

   strcpy(img_filename,"");
   for(i=1;i<argc;i++) {
      if(strcmp(argv[i],"--file")==0) {
         tcl_argv[1] = argv[++i];
         tcl_argc = 2;
      } else if(strcmp(argv[i],"--verbose")==0) {
         gVerbose = 1;
      } else if(strcmp(argv[i],"--console")==0) {
         gConsole = 1;
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
         printf("  --console         use console GUI (no TK).\n");
         printf("  --version         Version de AudeLA.\n");
         return 0;
      } else {
         if (i==1) {
            strcpy(img_filename,argv[i]);
         }
      }
   }

#if defined(OS_WIN)
   if ( gConsole == 1 ) {
      // create a Msdos console
      createMsdosConsole();
   }
#endif

   // set default script
   if ( tcl_argc==1 ) {
      if (gConsole == 0 ) {
         // set default script for tk GUI
         tcl_argv[1] = DEFAULT_SCRIPT_TK;
         tcl_argc = 2;
      } else {
         // no default script for console GUI
         tcl_argv[1] = NULL;
      }
   }

   if ( tcl_argv[1] != NULL) {
   LOG("Starting new AudeLA session (initial file=%s).\n",tcl_argv[1]);
   } else {
      LOG("Starting new AudeLA session (no initial file).\n");
   }

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

   // Boucle principale et lancement du programme
   if ( gConsole == 1 ) {
      Tcl_Main(tcl_argc,tcl_argv,Tcl_AppInit);
   } else {
   Tk_Main(tcl_argc,tcl_argv,Tk_AppInit);
   }

   // On renvoie 0 pour eviter un warning du compilateur, mais
   // le logiciel ne passe jamais ici !
   return 0;
}


//------------------------------------------------------------------------------
// Point d'entree du logiciel pour WINDOWS
//
#if defined(OS_WIN)
int PASCAL WinMain(HINSTANCE hCurInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
   int argc;
   char **argv;
   char executableFullPath[MAX_STRING];

   GetModuleFileName(NULL,executableFullPath,MAX_PATH);
   ghInstance=hCurInstance;
   audela_parsecmdline(executableFullPath,lpCmdLine,&argc,&argv);

   // Do the real work.
   return main( argc, argv );
   return 0;
}
#endif


//------------------------------------------------------------------------------
// Chargement d'une librairie dans AudeLA, avec consignation d'erreurs
// dans le fichier audela.log
//
void load_library(Tcl_Interp *interp, char *s)
{
   char t[256];
   sprintf(t,"catch {load %s[info sharedlibextension]} msg",s);
   LOGDEBUG("commande = %s\n",t);
   Tcl_Eval(interp,t);
   LOGDEBUG("result=%s\n",interp->result);
   if(atoi(interp->result)==1) {
      Tcl_Eval(interp,"set msg");
      LOG("%s\n",interp->result);
      printf("%s\n",interp->result);
   } else {
      if(gVerbose) LOG("%s: ok\n",s);
   }
}

//------------------------------------------------------------------------------
// Fonction callback d'initialisation de l'application TK.
//
int Tk_AppInit(Tcl_Interp *interp)
{
   char ligne[1000];
   int k;

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
   load_library(interp,"libaudelatk"); // visu with TK 
   load_library(interp,"libgsltcl");  // Gnu Scientific Library extension for Tcl
   load_library(interp,"libgzip");    // Gzip compression
   load_library(interp,"libjm");      // Misc. from Jacques Michelet
   load_library(interp,"libbm");      // Misc. from Benjamin Mauclaire
   load_library(interp,"libmc");      // Celestial mechanics
   load_library(interp,"librgb");     // Extraction of tri-colored planes from a CCD image
   load_library(interp,"libsext");    // Sextractor code from Bertin
   load_library(interp,"libyd");      // Misc. from Yassine Damerdji
#if !defined(OS_LIN)
   load_library(interp,"libml");      // Misc. from Myrtille Laas
#endif

#if defined(OS_WIN)
   sprintf(ligne,"set audela(hInstance) %d",&ghInstance);
   Tcl_Eval(interp,ligne);
#endif
   if (strcmp(img_filename,"")!=0) {
      for (k=0;k<(int)strlen(img_filename);k++) {
         if (img_filename[k]=='\\') {
            img_filename[k]='/';
         }
      }
   }
   sprintf(ligne,"set audela(img_filename) \"%s\"",img_filename);
   Tcl_Eval(interp,ligne);

   return TCL_OK;
}

//------------------------------------------------------------------------------
// Fonction callback d'initialisation de l'application TCL.
//
int Tcl_AppInit(Tcl_Interp *interp)
{
   if (Tcl_Init(interp) == TCL_ERROR) {
      return TCL_ERROR;
   }
   
#if defined(OS_WIN)
   //-- Install a signal handler to the win32 console 
   //SetConsoleCtrlHandler(sigHandler, TRUE);
   //-- This exit handler will be used to free the resources allocated in this file.
   Tcl_CreateExitHandler(AppInitExitHandler, interp);
#endif   
   
   load_library(interp,"libak");      // Misc. from Alain Klotz
   load_library(interp,"libaudela");  // Acquisition, and preprocssing
   load_library(interp,"libgsltcl");  // Gnu Scientific Library extension for Tcl
   load_library(interp,"libgzip");    // Gzip compression
   load_library(interp,"libjm");      // Misc. from Jacques Michelet
   load_library(interp,"libbm");      // Misc. from Benjamin Mauclaire
   load_library(interp,"libmc");      // Celestial mechanics
   load_library(interp,"libsext");    // Sextractor code from Bertin
   load_library(interp,"libyd");      // Misc. from Yassine Damerdji
#if !defined(OS_LIN)
   load_library(interp,"libml");      // Misc. from Myrtille Laas
#endif

   return TCL_OK;
}
 


#if defined(OS_WIN)

/*
*----------------------------------------------------------------------
*
* AppInitExitHandler --
*
*       This function is called to cleanup the app init resources before
*       Tcl is unloaded.
*
* Results:
*       None.
*
* Side effects:
*       wait for key pressed if error occurs.
*
*----------------------------------------------------------------------
*/

static void AppInitExitHandler(ClientData clientData)
{
   char pause[1024];
   Tcl_Interp *interp = (Tcl_Interp *)clientData;
   if ( interp->errorLine != 1 ) {
      // let's read the error message before closing the console
      printf("Press any key to close ..." );
      gets(pause);
   } else {
      // no error , nothing to do
   }
}


/*
 *----------------------------------------------------------------------
 *
 * createMsdosConsole  (for WIN32 only)
 *
 *	Creates a Msdos console.
 *
 * Results:
 *	none.
 *
 * Side effects:
 *	stdin, stdout , stderr are redirected to the console
 *
 *----------------------------------------------------------------------
 */
#include <stdio.h>
#include <fcntl.h>
#include <io.h>      // for _open_osfhandle
#define MAX_CONSOLE_LINES 80

void createMsdosConsole() {
   
   int hConHandle;
   long lStdHandle;
   CONSOLE_SCREEN_BUFFER_INFO coninfo;
   FILE *fp;
   
   // allocate a console for this app
   AllocConsole();
   
   // set the screen buffer to be big enough to let us scroll text
   GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE),&coninfo); 
   coninfo.dwSize.Y = MAX_CONSOLE_LINES;
   SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE),coninfo.dwSize);
   
   // redirect unbuffered STDOUT to the console
   lStdHandle = (long)GetStdHandle(STD_OUTPUT_HANDLE);
   hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);
   fp = _fdopen( hConHandle, "w" );
   *stdout = *fp;
   setvbuf( stdout, NULL, _IONBF, 0 );
   
   // redirect unbuffered STDIN to the console
   lStdHandle = (long)GetStdHandle(STD_INPUT_HANDLE);
   hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);
   fp = _fdopen( hConHandle, "r" );
   *stdin = *fp;
   setvbuf( stdin, NULL, _IONBF, 0 );
   
   // redirect unbuffered STDERR to the console
   lStdHandle = (long)GetStdHandle(STD_ERROR_HANDLE);
   hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);
   fp = _fdopen( hConHandle, "w" );
   *stderr = *fp;
   setvbuf( stderr, NULL, _IONBF, 0 );
   
}
#endif
