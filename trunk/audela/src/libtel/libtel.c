/* libtel.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

// $Id: libtel.c,v 1.34 2011-02-13 15:37:06 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#if defined(_MSC_VER)
#include <sys/timeb.h>
#include <time.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "telescop.h"

#include <libtel/libtel.h>
#include "teltcl.h"
#include "telcmd.h"

/* valeurs des structures tel_* privees */

char *tel_ports[] = {
   "com1",
   "com2",
   "com3",
   "com4",
   "com5",
   "com6",
   "com7",
   "com8",
   NULL
};

// fonctions appelees depuis libtel.c
struct tel_drv_t TEL_DRV = {  
   default_tel_correct,                // tel_correct
   default_tel_get_radec_guiding,      // tel_set_radec_guiding	
   default_tel_set_radec_guiding ,     // tel_get_radec_guiding	
};

#if !defined(OS_WIN)
#define MB_OK 1
void MessageBox(void *handle, char *msg, char *title, int bof)
{
   fprintf(stderr,"%s: %s\n",title,msg);
}
#endif

#define BP(i) MessageBox(NULL,#i,"Libtel",MB_OK)

void logConsole(struct telprop *tel, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   int result;
   
   // j'assemble la commande 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
	va_end (mkr);

   if ( strcmp(tel->telThreadId,"") == 0 ) {
      sprintf(ligne,"::console::disp \"Telescope: %s\" ",message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { ::console::disp \"Telescope: %s\" } " , tel->mainThreadId, message); 
   }
   result = Tcl_Eval(tel->interp,ligne);
}

/*
 * Prototypes des differentes fonctions d'interface Tcl/Driver. Ajoutez les
 * votres ici.
 */
/* === Common commands for all telescopes ===*/
int cmdTelCreate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);


static struct telprop *telprops = NULL;

/*
 * Point d'entree de la librairie, appelle lors de la commande Tcl load.
 */
#if defined(OS_WIN)
int __cdecl TEL_ENTRYPOINT (Tcl_Interp *interp)
#else
int TEL_ENTRYPOINT (Tcl_Interp *interp)
#endif
{
   struct cmditem *cmd;
   int i;

   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in " TEL_LIBNAME " (" TEL_LIBVER ").",TCL_VOLATILE);
      return TCL_ERROR;
   }

   Tcl_CreateCommand(interp,TEL_DRIVNAME,(Tcl_CmdProc *)cmdTelCreate,NULL,NULL);
   Tcl_PkgProvide(interp,TEL_LIBNAME,TEL_LIBVER);

   for(i=0,cmd=cmdlist;cmd->cmd!=NULL;cmd++,i++);

   return TCL_OK;
}

int cmdTelCreate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[2048],cmd[256];
   int telno, err;
   struct telprop *tel, *tell;
   if(argc<3) {
      sprintf(s,"%s driver port ?options?",argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char telThreadId[20];
      char mainThreadId[20];
      const char *platform;
      const char *threaded;

      /*
       * On initialise le telescope sur le port. S'il y a une erreur, alors on
       * renvoie le message qui va bien, en supprimant la structure cree.
       * Si OK, la commande TCL est creee d'apres l'argv[1], et on garde
       * trace de la structure creee.
       */
	   tel = (struct telprop*)calloc(1,sizeof(struct telprop));
      strcpy(tel->msg,"");
      /* --- verify the platform ---*/
      Tcl_Eval(interp,"set ::tcl_platform(os)");
      strcpy(s,interp->result);
      if ((strcmp(s,"Windows 95")==0)||(strcmp(s,"Windows 98")==0)||(strcmp(s,"Windows NT")==0)||(strcmp(s,"Linux")==0)) {
         tel->authorized=1;
      } else {
         tel->authorized=0;
      }

      // 
      if((platform=Tcl_GetVar(interp,"tcl_platform(platform)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdTelCreate: Global variable tcl_platform(os) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      if((threaded=Tcl_GetVar(interp,"tcl_platform(threaded)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdTelCreate: Global variable tcl_platform(threaded) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }


      if ( strcmp(argv[argc-2],"mainThreadId") != 0 ) {
         if ( strcmp(threaded,"1") == 0 ) {
            // Cas de l'environnement multi-thread : je cree un thread dediee au telescope
            int i;
            // Cas normal en mutlti-thread

            // je recupere l'indentifiant de la thread principale
            Tcl_Eval(interp, "thread::id");
            strcpy(mainThreadId, interp->result);
            // je cree la thread du telescope
            Tcl_Eval(interp, "thread::create");
            strcpy(telThreadId, interp->result);
            
            // je duplique la commande "tel1" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, argv[0]);
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "::console::disp" dans la thread du telescope
			strcpy(cmd,"::console::disp");
			sprintf(s,"info command %s",cmd);
			Tcl_Eval(interp,s);
			if (strcmp(interp->result,cmd)==0) {
				sprintf(s,"thread::copycommand %s %s ",telThreadId,cmd);
				if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
					sprintf(s, "cmdTelCreate: %s",interp->result);
					Tcl_SetResult(interp, s, TCL_VOLATILE);
					return TCL_ERROR;
				}  
			}

            // je duplique la commande "::audace::date_sys2ut" dans la thread du telescope
			strcpy(cmd,"::audace::date_sys2ut");
			sprintf(s,"info command %s",cmd);
			Tcl_Eval(interp,s);
			if (strcmp(interp->result,cmd)==0) {
				sprintf(s,"thread::copycommand %s %s ",telThreadId,cmd);
				if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
					sprintf(s, "cmdTelCreate: %s",interp->result);
					Tcl_SetResult(interp, s, TCL_VOLATILE);
					return TCL_ERROR;
				}  
			}

            // je duplique la commande "mc_angle2lx200ra" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2lx200ra");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2lx200dec" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2lx200dec");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2hms" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2hms");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2deg" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2deg");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }            
            
            // je duplique la commande "mc_date2iso8601" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2iso8601");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_date2ymdhms" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2ymdhms");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_date2jd" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2jd");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2dms" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2dms");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angles2nexstar" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angles2nexstar");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_date2lst" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2lst");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_anglesep" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_anglesep");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_nexstar2angles" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_nexstar2angles");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            // je duplique la commande "mc_anglescomp" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_anglescomp");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2rad" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2rad");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_radec2altaz" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_radec2altaz");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_sepangle" dans la thread du telescope
				strcpy(cmd,"mc_sepangle");
				sprintf(s,"info command %s",cmd);
				Tcl_Eval(interp,s);
				if (strcmp(interp->result,cmd)==0) {
					sprintf(s,"thread::copycommand %s %s ",telThreadId,cmd);
					if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
						sprintf(s, "cmdTelCreate: %s",interp->result);
						Tcl_SetResult(interp, s, TCL_VOLATILE);
						return TCL_ERROR;
					}  
				}

            // je duplique la commande "mc_hip2tel" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_hip2tel");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_tel2cat" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_tel2cat");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdTelCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }


            // je prepare la commande de creation du telescope dans la thread du telescope :
            // thread::send $threadId { {argv0} {argv1} ... {argvn} mainThreadId $mainThreadId }
            sprintf(s,"thread::send %s { ",telThreadId);
            for (i=0;i<argc;i++) {
               strcat(s," {");
               strcat(s,argv[i]);
               strcat(s,"} ");
            }
            // j'ajoute le numero de la thread principale en dernier parametre
            strcat(s,"mainThreadId ");
            strcat(s, mainThreadId);
            strcat(s," }");
            // je lance la creattion du telescope en l'executant dans la thread du telescope
            return Tcl_Eval(interp, s);
         } else {
            // Cas de l'environnement mono-thread
            strcpy(mainThreadId, "");
            strcpy(telThreadId,  "");
            // je memorise l'interpreteur du thread principal
        	   tel->interp=interp;  
         }
      } else {
         // on est dans le thread du telescope
         strcpy(mainThreadId, argv[argc-1]);
         Tcl_Eval(interp, "thread::id");
         strcpy(telThreadId, interp->result);
         // je memorise l'interpreteur du thread du telescope
     	   tel->interp=interp;
      }

      // je copie les identifiants de thread dans la structure du telescope
      strcpy(tel->mainThreadId, mainThreadId);
      strcpy(tel->telThreadId,  telThreadId);

      /* --- internal init ---*/
      if((err=tel_init_common(tel,argc,argv))!=0) {
         Tcl_SetResult(interp,"init error",TCL_VOLATILE);
         free(tel);
         return TCL_ERROR;
      }
      /* --- external init defined in the telescop.c file ---*/
      if((err=tel_init(tel,argc,argv))!=0) {
         Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
         free(tel);
         return TCL_ERROR;
      }
      /* --- record the telescope as a new AudeLA object ---*/
      sscanf(argv[1],"tel%d",&telno);
      tel->telno = telno;
      tell = telprops;
      if(tell==NULL) {
         telprops = tel;
      } else {
         while(tell->next!=NULL) tell = tell->next;
         tell->next = tel;
      }
      Tcl_CreateCommand(interp,argv[1],(Tcl_CmdProc *)cmdTel,(ClientData)tel,NULL);

      if ( strcmp(telThreadId,"") != 0 ) {
         // je duplique la commande "tel1" dans le thread principal
         sprintf(s,"thread::copycommand %s %s ",mainThreadId, argv[1]);
         if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
            sprintf(s, "cmdTelCreate: %s",interp->result);
            Tcl_SetResult(interp, s, TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
   }
   return TCL_OK;
}

int cmdTel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[1024],ss[50];
   int retour = TCL_OK,k;
   struct cmditem *cmd;
   if(argc==1) {
      sprintf(s,"%s choose sub-command among ",argv[0]);
      k=0;
      while (cmdlist[k].cmd!=NULL) {
         sprintf(ss," %s",cmdlist[k].cmd);
         strcat(s,ss);
         k++;
      }
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      struct telprop *tel;
      tel = (struct telprop *)clientData;
      if ( tel->telThreadId[0] != 0 ) {
         // cas du mutltithread
         char currentThread[80];
         // je recupere la thread courante
         Tcl_Eval(interp, "thread::id");
         strcpy(currentThread,interp->result);
         // si on n'est pas dans la thread du telescope je transmets la commande a la thread du telescope
         if ( strcmp(currentThread, tel->telThreadId) !=0 )  {
            sprintf(s,"thread::send %s {",tel->telThreadId);
            for (k=0;k<argc;k++) {
               // les accolades servent a delimiter les parametres de type "list"
               strcat(s,"{");
               strcat(s,argv[k]);
               strcat(s,"} ");
            }
            strcat(s,"}");
            return Tcl_Eval(interp, s);
         }
      }


      for(cmd=cmdlist;cmd->cmd!=NULL;cmd++) {
         if(strcmp(cmd->cmd,argv[1])==0) {
            retour = (*cmd->func)(clientData, interp, argc, argv);
            break;
         }
      }
      if(cmd->cmd==NULL) {
         sprintf(s,"%s %s : sub-command not found among ",argv[0], argv[1]);
         k=0;
         while (cmdlist[k].cmd!=NULL) {
            sprintf(ss," %s",cmdlist[k].cmd);
            strcat(s,ss);
            k++;
         }
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}

/* ========================= */
/* === Utility functions === */
/* ========================= */

/*
 * GetCurrentFITSDate(char s[23])
 *
 */
void libtel_GetCurrentFITSDate(Tcl_Interp *interp, char s[23])
{
   int clock=0;
#if defined(_Windows)
   /* cas special a Borland Builder pour avoir les millisecondes */
   struct time t1;
   struct date d1;
   clock=1;
   getdate(&d1);
   gettime(&t1);
   sprintf(s,"%04d-%02d-%02dT%02d:%02d:%02d.%02d",
      d1.da_year,d1.da_mon,d1.da_day,t1.ti_hour,t1.ti_min,t1.ti_sec,t1.ti_hund);
#endif
#if defined(_MSC_VER)
   /* cas special a Microsoft C++ pour avoir les millisecondes */
   struct _timeb timebuffer;
   char message[50];
   time_t ltime;
   clock=1;
   _ftime( &timebuffer );
   time( &ltime );
   strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   sprintf(s,"%s.%02d",message,(int)(timebuffer.millitm/10));
#endif
   if (clock==0) {
      Tcl_Eval(interp,"clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.00\"");
      strcpy(s,interp->result);
   }
}

void libtel_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
{
   /* --- conversion TSystem -> TU pour l'interface Aud'ACE par exemple ---*/
	/*     (function = ::audace::date_sys2ut) */
   char ligne[1024];
   sprintf(ligne,"info commands  %s",function);
   Tcl_Eval(interp,ligne);
   if (strcmp(interp->result,function)==0) {
      sprintf(ligne,"mc_date2iso8601 [%s now]",function);
      Tcl_Eval(interp,ligne);
      strcpy(s,interp->result);
	}
}

int libtel_Getradec(Tcl_Interp *interp,char *tcllist,double *ra,double *dec)
/*
 * Decode a Tcl list of two elements -> ra,dec (in float degrees)
 */
{
   char ligne[256];
   char **listArgv;
   int listArgc;
   int result = TCL_OK;
   if(Tcl_SplitList(interp,tcllist,&listArgc,&listArgv)!=TCL_OK) {
      sprintf(ligne,"Angle struct not valid: must be {angle_ra angle_dec}");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(listArgc!=2) {
      sprintf(ligne,"Angle struct not valid: must be {angle_ra angle_dec}");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   if (result==TCL_OK) {
      sprintf(ligne,"mc_angle2deg %s",listArgv[0]);
      if (Tcl_Eval(interp,ligne)==TCL_OK) {
         *ra=atof(interp->result);
      }
      sprintf(ligne,"mc_angle2deg %s 90",listArgv[1]);
      if (Tcl_Eval(interp,ligne)==TCL_OK) {
         *dec=atof(interp->result);
      }
   }
   Tcl_Free((char*)listArgv);
   return result;
}

/* ================================================================= */
/* === Obsolete functions but used for old version compatibility === */
/* ================================================================= */

int cmdTelGoto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec goto {");
   if (argc>=3) {
      strcat(ligne,argv[2]);
   }
   strcat(ligne,"}");
   result=Tcl_Eval(interp,ligne);
   return result;
}

int cmdTelCoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   /*
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   result=tel_radec_coord(tel,ligne);
   if (result==0) {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result=TCL_OK;
   } else {
      Tcl_SetResult(interp,"",TCL_VOLATILE);
      result = TCL_ERROR;
   }
   */
   sprintf(ligne,"%s radec %s",argv[0],argv[1]);
   result=Tcl_Eval(interp,ligne);
   return result;
}

int cmdTelStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec stop ");
   if (argc>=3) {
      strcat(ligne,argv[2]);
   }
   result=Tcl_Eval(interp,ligne);
   return result;
}

int cmdTelSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=3) {
      tel->speed=1.;
      Tcl_SetResult(interp,"slew",TCL_VOLATILE);
      if (strcmp(argv[2],"guide")==0) {
         tel->speed=0.25;
         Tcl_SetResult(interp,argv[2],TCL_VOLATILE);
      }
      if (strcmp(argv[2],"center")==0) {
         tel->speed=0.5;
         Tcl_SetResult(interp,argv[2],TCL_VOLATILE);
      }
      if (strcmp(argv[2],"find")==0) {
         tel->speed=0.75;
         Tcl_SetResult(interp,argv[2],TCL_VOLATILE);
	}
   } else {
      Tcl_SetResult(interp,"slew",TCL_VOLATILE);
      if (tel->speed<=0.25) {
         Tcl_SetResult(interp,"guide",TCL_VOLATILE);
      } else if ((tel->speed>0.25)&&(tel->speed<=0.5)) {
         Tcl_SetResult(interp,"center",TCL_VOLATILE);
      } else if ((tel->speed>0.5)&&(tel->speed<=0.75)) {
         Tcl_SetResult(interp,"find",TCL_VOLATILE);
      }
   }
   return TCL_OK;
}

int cmdTelMove(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[1024],ligne2[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec move ");
   strcpy(ligne2,"none");
   if (argc>=3) {
      strcpy(ligne2,argv[2]);
   }
   strcat(ligne,ligne2);
   sprintf(ligne2,"%s %f",ligne,tel->speed);
   result=Tcl_Eval(interp,ligne2);
   return result;
}

int cmdTelMatch(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec init {");
   if (argc>=3) {
      strcat(ligne,argv[2]);
   }
   strcat(ligne,"}");
   result=Tcl_Eval(interp,ligne);
   return result;
}


/* ========================== */
/* === Official functions === */
/* ========================== */

int cmdTelAlignmentMode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   Tcl_SetResult(interp,tel->alignmentMode,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelRefraction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;
   struct telprop *tel;
   char ligne[256];
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0|1?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      sprintf(ligne,"%d", tel->refractionCorrection);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_OK;
   } else {
      int refractionFlag = 0; 
      if(Tcl_GetInt(interp,argv[2],&refractionFlag)!=TCL_OK) {
	      sprintf(ligne,"Usage: %s %s ?0|1?\ninvalid value '%s'. Must be 0 or 1",argv[0],argv[1],argv[2]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if ( refractionFlag != 0 && refractionFlag != 1 ) {
            sprintf(ligne,"Usage: %s %s ?0|1?\ninvalid value '%s'. Must be 0 or 1",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            tel->refractionCorrection = refractionFlag;
            Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         }
      }
   }
   return result;
}

int cmdTelDrivername(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   sprintf(ligne,"%s {%s}",TEL_LIBNAME,__DATE__);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelClose(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   struct telprop *tel;
   char ligne[256];
   tel = (struct telprop *)clientData;
   tel_close(tel);
   
   // je supprime le thread du telescope
   if ( strcmp(tel->telThreadId,"")!= 0 ) {
      sprintf(ligne,"thread::release %s" , tel->telThreadId);
      Tcl_Eval(interp, ligne);
   }

   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelName(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel_ini[tel->index_tel].name);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelProtocol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel_ini[tel->index_tel].protocol);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelProduct(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel_ini[tel->index_tel].product);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelPort(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel->portname);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelChannel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel->channel);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelTestCom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%d",tel_testcom(tel));
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

/* --- Action commands ---*/

int cmdTelFoclen(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   double d;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?focal_length_(meters)?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      sprintf(ligne,"%f",tel->foclen);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      pb=0;
      if(Tcl_GetDouble(interp,argv[2],&d)!=TCL_OK) {
         pb=1;
      }
      if (pb==0) {
         if (d<=0.0) {
            pb=1;
         }
      }
      if (pb==1) {
         sprintf(ligne,"Usage: %s %s ?focal_length_(meters)?\nfocal_length : must be an float > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         tel = (struct telprop*)clientData;
         tel->foclen = d;
         sprintf(ligne,"%f",tel->foclen);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

int cmdTelDate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],ligne2[256];
   int result = TCL_OK;
   struct telprop *tel;
   int y,m,d,h,min;
   double s;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?Date?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      /* returns a type hmdhms list */
      tel_date_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      tel = (struct telprop*)clientData;
	  sprintf(ligne,"mc_date2ymdhms {%s}",argv[2]);
      if (Tcl_Eval(interp,ligne)==TCL_OK) {
         strcpy(ligne2,interp->result);
      } else {
         strcpy(ligne2,"2000 1 1 0 0 0.0");
      }
	  sprintf(ligne,"lindex {%s} 0",ligne2);
      Tcl_Eval(interp,ligne);
      y=(int)atoi(interp->result);
	  sprintf(ligne,"lindex {%s} 1",ligne2);
      Tcl_Eval(interp,ligne);
      m=(int)atoi(interp->result);
	  sprintf(ligne,"lindex {%s} 2",ligne2);
      Tcl_Eval(interp,ligne);
      d=(int)atoi(interp->result);
	  sprintf(ligne,"lindex {%s} 3",ligne2);
      Tcl_Eval(interp,ligne);
      h=(int)atoi(interp->result);
	  sprintf(ligne,"lindex {%s} 4",ligne2);
      Tcl_Eval(interp,ligne);
      min=(int)atoi(interp->result);
	  sprintf(ligne,"lindex {%s} 5",ligne2);
      Tcl_Eval(interp,ligne);
      s=(double)atof(interp->result);
      tel_date_set(tel,y,m,d,h,min,s);
      /* returns a type hmdhms list */
      tel_date_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelHome(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],ew[3];
   int result = TCL_OK;
   struct telprop *tel;
   double longitude,latitude,altitude;
   if((argc!=2)&&(argc!=3)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s ?{GPS long e|w lat alt}? ?{-name xxx}",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      /* returns a type {degrees degrees} list */
      /* result is a list : GPS long(deg) e|w lat(deg) alt(m) */
      tel_home_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      // je memorise la position pour eviter d'envoyer une nouvelle requete au
      // telescope chaque fois qu'on utilise "tel radec coord" ou "tel radec goto"
      strcpy(tel->homePosition,ligne);
   } else {
      tel = (struct telprop*)clientData;
      if ( strcmp(argv[2],"name") == 0) {
         if ( argc == 3) {
            // je retoune le nom du site
            Tcl_SetResult(interp,tel->homeName,TCL_VOLATILE);
         } else {
            // je memorise le nom du site
            strncpy( tel->homeName, argv[3], sizeof(tel->homeName));
            Tcl_SetResult(interp,tel->homeName,TCL_VOLATILE);
         }
      } else {
         // je memorise la position
         sprintf(ligne,"lindex {%s} 1",argv[2]);
         Tcl_Eval(interp,ligne);
         longitude=(double)atof(interp->result);
         sprintf(ligne,"string toupper [lindex {%s} 2]",argv[2]);
         Tcl_Eval(interp,ligne);
         if (strcmp(interp->result,"W")==0) {
            strcpy(ew,"w");
         } else {
            strcpy(ew,"e");
         }
         sprintf(ligne,"lindex {%s} 3",argv[2]);
         Tcl_Eval(interp,ligne);
         latitude=(double)atof(interp->result);
         sprintf(ligne,"lindex {%s} 4",argv[2]);
         Tcl_Eval(interp,ligne);
         altitude=(double)atof(interp->result);
         tel_home_set(tel,longitude,ew,latitude,altitude);
         tel_home_get(tel,ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         // je memorise la position pour eviter d'envoyer une nouvelle requete au
         // telescope chaque fois qu'on utilise "tel radec coord" ou "tel radec goto"
         strcpy(tel->homePosition,ligne);
      }
   }
   return result;
}

int cmdTelRaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|correct|coord|motor|init|state|model|mindelay(ms)? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
            /* - call the pointing model if exists -*/
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
            if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
            }
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
            /* - end of pointing model-*/
            libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
            if ( tel_radec_init(tel) == 0 ) {
               Tcl_SetResult(interp,"",TCL_VOLATILE);
               result = TCL_OK;
            } else {
               Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
               result = TCL_ERROR;
            }

         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ra angle_dec}",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
         char outputEquinox[20];
         strcpy(outputEquinox,"NOW");

         // je lis les parametres optionnels
         for (k=3;k<=argc-1;k++) {
            if (strcmp(argv[k],"-equinox")==0) {
               strncpy(outputEquinox,argv[k+1], sizeof(outputEquinox));
            }
         }
         if ( strcmp(tel->model_tel2cat,"") == 0 ) {
            // je recupere les coordonnnees du telescope
            if ( tel_radec_coord(tel,texte) == 0 ) {
               char utDate[20];
               // il n'y a pas d'erreur, je traite les coordonnees
               if ( tel->consoleLog >= 1 ) {
                  logConsole(tel, "radec coord: telescope coord(now)=%s\n", texte);
               }
               //--- je convertis les coordonnees HMS,DMS en degres 
               if ( result == TCL_OK) {
                  sprintf(ligne,"list [mc_angle2deg [lindex {%s} 0]] [mc_angle2deg [lindex {%s} 1]]",texte, texte); 
                  if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                     sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, tel->interp->result);
                     result = TCL_ERROR; 
                  } else {
                     strcpy(texte,interp->result);
                  } 
               }
               // je recupere la date courante TU
               result = Tcl_Eval(interp,"clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC");
               if ( result == TCL_OK) {
                  char refractionOption[15];
                  strncpy(utDate, interp->result,sizeof(utDate)); 
                  if ( tel->refractionCorrection == 1 ) {
                     // mc_tel2cat doit pas corriger la refraction si la monture corrige la refraction.
                     strcpy(refractionOption, "-refraction 0");
                  } else {
                     strcpy(refractionOption,"");
                  }
                              
                  if (tel->radec_model_enabled == 1 ) {
                     if ( strcmp(outputEquinox,"NOW")==0 ) {
                        // j'applique le modèle de pointage inverse , pas de changement d'equinoxe a faire (modele seulement)
                        // usage: mc_tel2cat {12h 36d} EQUATORIAL 2010-06-03T20:10:00 {GPS 5 E 43 1230} 101325 290 { symbols } { values }
                        // ATTENTION : si on utilise utDate="now" , il faut d'abord mettre l'ordinateur a l'heure TU
                        sprintf(ligne, "mc_tel2cat {%s} {%s} {%s} {%s} %d %d {%s} {%s} -model_only 1 %s", 
                           texte, tel->alignmentMode, utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           tel->radec_model_symbols, tel->radec_model_coefficients,
                           refractionOption);
                     } else {
                        // j'applique le modèle de pointage inverse et je change d'equinoxe (equinoxe du jour -> J2000)
                        // usage: mc_tel2cat {12h 36d} EQUATORIAL 2010-06-03T20:10:00 {GPS 5 E 43 1230} 101325 290 { symbols } { values }
                        // ATTENTION : si on utilise utDate="now" , il faut d'abord mettre l'ordinateur a l'heure TU
                        sprintf(ligne, "mc_tel2cat {%s} {%s} {%s} {%s} %d %d {%s} {%s} %s", 
                           texte, tel->alignmentMode, utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           tel->radec_model_symbols, tel->radec_model_coefficients,
                           refractionOption);
                     }
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec coord: %s\n", ligne);
                     }
                     result = Tcl_Eval(interp,ligne);
                     if ( result == TCL_OK) {                     
                        // je convertis les angles en HMS et DMS
                        sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string]  [mc_angle2dms [lindex {%s} 1] 90 zero 1 + string]",interp->result, interp->result); 
                        if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                           sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, tel->interp->result);
                           result = TCL_ERROR; 
                        } else {
                           strcpy(ligne,interp->result);
                           result = TCL_OK; 
                        } 
                     } else {
                        // erreur de mc_tel2cat 
                        strcpy(ligne, interp->result);
                        result = TCL_ERROR; 
                     }
                  } else {
                     if ( strcmp(outputEquinox,"NOW")==0 ) {
                        // pas de modele de pointage, pas de changement d'equinoxe
                        // je convertis les angles en HMS et DMS
                        sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string]  [mc_angle2dms [lindex {%s} 1] 90 zero 1 + string]",texte, texte); 
                        if ( mytel_tcleval(tel,ligne) == TCL_OK) {
                           strcpy(ligne,interp->result);
                           result = TCL_OK; 
                        } else {
                           sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, tel->interp->result);
                           result = TCL_ERROR; 
                        } 
                     } else {
                        // je convertis les coordonnes du telescope (equinox du jour) en coordonnes catalogue (equinox=J2000) 
                        // sans appliquer le modele de pointage (les parametres symbols et values sont absents) 
                        sprintf(ligne, "mc_tel2cat { %s } { %s } { %s } { %s } %d %d %s", 
                           texte, tel->alignmentMode, utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature,
                           refractionOption);
                        if ( tel->consoleLog >= 1 ) {
                           logConsole(tel, "radec coord: %s\n", ligne);
                        }
                        result = Tcl_Eval(interp,ligne);
                        if ( result == TCL_OK) {                     
                           // je convertis les angles en HMS et DMS
                           sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string] [mc_angle2dms [lindex {%s} 1] 90 zero 1 + string]",interp->result, interp->result); 
                           if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                              sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, tel->interp->result);
                              result = TCL_ERROR; 
                           } else {
                              strcpy(ligne,interp->result);
                              result = TCL_OK; 
                           } 
                        } else {
                           // erreur de mc_tel2cat 
                           strcpy(ligne, interp->result);
                           result = TCL_ERROR; 
                        }   
                     }
                  }
                  if ( result == TCL_OK ) {   
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec coord: catalogue coord(%s): %s\n", outputEquinox,ligne);
                     }
                  }
               } else {
                  // erreur de clock format ...
                  strcpy(ligne, interp->result);
                  result = TCL_ERROR;
               }
            } else {
               // erreur de tel_radec_coord 
               strcpy(ligne, tel->msg);
               result = TCL_ERROR;
            }            
         } else {
            // je recupere les coordonnnees du telescope
            if ( tel_radec_coord(tel,texte) == 0 ) {
					// j'applique le modele de pointage avec la procedure modpoi_tel2cat du TCL
					// ========================================================================
					sprintf(ligne,"set libtel(radec) {%s}",texte);
					Tcl_Eval(interp,ligne);
					sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
					Tcl_Eval(interp,ligne);
					Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
					strcpy(ligne,interp->result);
					/* - end of pointing model-*/
				}
         } 

         Tcl_SetResult(interp,ligne,TCL_VOLATILE);

      } else if (strcmp(argv[2],"state")==0) {
         /* --- state ---*/
         tel_radec_state(tel,texte);
         Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         char inputEquinox[20];
         strcpy(inputEquinox,"J2000.0");
         tel->active_backlash = 0;
         tel->radec_goto_blocking = 0;        
         if (argc>=4) {
            for (k=4;k<=argc-1;k++) {
               if (strcmp(argv[k],"-rate")==0) {
                  tel->radec_goto_rate=atof(argv[k+1]);
               }
               if (strcmp(argv[k],"-blocking")==0) {
                  tel->radec_goto_blocking=atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-backlash")==0) {
                  tel->active_backlash=atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-equinox")==0) {
                  strncpy(inputEquinox,argv[k+1], sizeof(inputEquinox));
               }
            }
                    
            // j'affiche une trace des coordonnees du catalogue dans la console
            if ( tel->consoleLog >= 1 ) {
               logConsole(tel, "radec goto: catalog coord (%s): %s\n", inputEquinox, argv[3]);
            }          
            
            if (strcmp(tel->model_cat2tel,"")==0) {
               // je convertis les coordonnes en double
               libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
               if ( result == TCL_OK) {
                  // je recupere la date courante TU
                  result = Tcl_Eval(interp,"clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC");
                  if ( result == TCL_OK) {
                     char utDate[20];
                     char refractionOption[15];
                     strncpy(utDate, interp->result,sizeof(utDate)); 
                     if ( tel->refractionCorrection == 1 ) {
                        // mc_tel2cat doit pas corriger la refraction si la monture corrige la refraction.
                        strcpy(refractionOption, "-refraction 0");
                     } else {
                        strcpy(refractionOption,"");
                     }
                  
                     // usage mc_hip2tel $hiprecord $date $home $pressure $temperature $modpoi_symbols $modpoi_coefs
                     // avec hipRecord = 
                     //   0 id   : identifiant hyparcos de l'etoile (nombre entier), si non utilisé =0  
                     //   1 mag  : magnitude , si non utilisé = 0.0  (nombre décimal)
                     //   2 ra   : ascension droite (en degrés décimaux)
                     //   3 dec  : declinaison (en degrés décimaux)
                     //   4 equinox : date de l'equinoxe , date du jour=now, ou foramt ISO8601
                     //   5 epoch   : date de l'epoque d'origine des mouvements propres , inutilise si mura et mudec sont nuls
                     //   6 mura : mouvement propre ra (en degré par an) 
                     //   7 mudec : mouvement propre dec (en degré par an)
                     //   8 plx   : parallaxe , =0 si inconnu (en mas=milliseconde d'arc)s

                     // ATTENTION: changement non documenté de hip2tel depuis le 08/06/2010 
                     // si identifiant hyparcos = 0 , alors 
                     //   0 id = indicateur type_liste 1
                     //   1 ha : angle horaire ?
                     //   2 dec : declinaison ?
                     //   3 ??  : parametre obligatoire non utilisé
                     //   4 ??  : parametre obligatoire non utilisé
                     //   5 ??  : parametre obligatoire non utilisé
                     //   6 ??  : parametre obligatoire non utilisé
                     //   7 ??  : parametre obligatoire non utilisé
                     //   8 ??  : parametre obligatoire non utilisé                  

                     if (tel->radec_model_enabled == 1 ) {
                        // correction avec le modele de pointage 
                        sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } {%s} {%s} %d %d {%s} {%s} %s", 
                           tel->ra0, tel->dec0, inputEquinox,
                           utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           tel->radec_model_symbols, tel->radec_model_coefficients,
                           refractionOption);
                     } else {
                        // je convertis les coordonnees a la date du jour, sans appliquer de modele de pointage
                        //  mc_hip2tel {id mag ra dec equinox epoch mura mudec plx } dateTu home pressure temperature
                        // ATTENTION : il ne faut pas utiliser "now" pour la date (ou bien mettre l'ordinateur a l'heure TU)
                        sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } { %s } { %s } %d %d %s", 
                           tel->ra0, tel->dec0, inputEquinox, 
                           utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature,
                           refractionOption);
                     }
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec goto: %s\n", ligne);
                     }
                     result = Tcl_Eval(interp,ligne);

                     if (result == TCL_OK) {
                        char **listArgv;
                        int listArgc;

                        //  je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
                        result = Tcl_SplitList(tel->interp,tel->interp->result,&listArgc,&listArgv) ;
                        if(result == TCL_OK) {
                           if ( listArgc >= 11 ) {
                              tel->ra0 = atof ( listArgv[10] ); 
                              tel->dec0 = atof ( listArgv[11] ); 
                           } else { 
                              sprintf(ligne,"radec goto error : mc_hip2tel doesn't return { ra0 dec0 } , returned value=%s",tel->interp->result);
                              Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                              result = TCL_ERROR;
                           }
                        } else { 
                           // rien a faire car la fonction Tcl_SplitList a deja renseigne les message d'erreur
                           result = TCL_ERROR;
                        } 
                        Tcl_Free((char*)listArgv);
                     }
                  } else {
                     // erreur de la commande clock format ...
                     strcpy(ligne,interp->result);
                  }
               } else {
                  // erreur de libtel_Getradec()
                  // rien a faire car la fonction libtel_Getradec a deja renseigne les message d'erreur
               }
            } else {
               // j'applique le modele de pointage avec la procedure modpoi_cat2tel du TCL
               // ========================================================================
               sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
               Tcl_Eval(interp,ligne);
               sprintf(ligne,"set libtel(radec) [%s {%s}]",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
               Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
               strcpy(ligne,interp->result);
               libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
               /* - end of pointing model-*/
            }

            if ( result == TCL_OK)  {
               if ( tel_radec_goto(tel) == 0 ) {
                  Tcl_SetResult(interp,"",TCL_VOLATILE);
                  result = TCL_OK;
                  // j'affiche une trace dans la console
                  if ( tel->consoleLog >= 1 ) {
                      sprintf(ligne,"list [mc_angle2hms %f 360 zero 2 auto string]  [mc_angle2dms %f 90 zero 1 + string]",tel->ra0, tel->dec0); 
                      Tcl_Eval(interp,ligne);
                      logConsole(tel, "radec goto: catalog coord (now): %s \n", interp->result);                     
                  }          
               } else {
                  Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
            }
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ra angle_dec} ?-rate value? ?-blocking boolean? ?-backlash boolean? ?-equinox Jxxxx.x|now?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            if ( tel_radec_move(tel,argv[3]) == 0 ) {
               Tcl_SetResult(interp,"",TCL_VOLATILE);
               result = TCL_OK;
            } else {
               Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
               result = TCL_ERROR;
            }
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?-rate value?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"correct")==0) {
         // correction pour le guidage en ascension droite et en declinaison
         // cette commande permet de faire des corrections simultanees sur les deux axes par les telescopes qui
         // en sont capables.
         char   alphaDirection[2];
         double alphaDistance;
         char   deltaDirection[2];
         double deltaDistance;

         if(argc!=8) {
            sprintf(ligne,"Usage: %s %s %s {e|w|} distanceAlpha {n|s} distanceDelta speed",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            switch(argv[3][0]) {
            case 'e':
            case 'E':
               alphaDirection[0] = 'E';
               alphaDirection[1] =  0;
               break;
            case 'w':
            case 'W':
               alphaDirection[0] = 'W';
               alphaDirection[1] =  0;
               break;
            default:
               sprintf(ligne,"Usage: %s %s %s direction time\nalpahaDirection shall be e|w",argv[0],argv[1],argv[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_ERROR;
            }
            
            if ( result == TCL_OK) {
               if (Tcl_GetDouble(interp, argv[4], &alphaDistance) != TCL_OK) {
                  sprintf(ligne,"Usage: %s %s %s distance \nalphaDistance shall be a decimal number",argv[0],argv[1],argv[2]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  return TCL_ERROR;
               }
               switch(argv[5][0]) {
               case 'n':
               case 'N':
                  deltaDirection[0] = 'N';
                  deltaDirection[1] =  0;
                  break;
               case 's':
               case 'S':
                  deltaDirection[0]= 'S';
                  deltaDirection[1]=  0;
                  break;
               default:
                  sprintf(ligne,"Usage: %s %s %s direction time\ndirection shall be n|s",argv[0],argv[1],argv[2]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
            }
            
            if ( result == TCL_OK) {
               if (Tcl_GetDouble(interp, argv[6], &deltaDistance) != TCL_OK) {
                  sprintf(ligne,"Usage: %s %s %s distance \ndistance shall be a decimal number",argv[0],argv[1],argv[2]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
            }
            
            if ( result == TCL_OK) {
               if (Tcl_GetDouble(interp, argv[7], &tel->radec_move_rate) != TCL_OK) {
                  sprintf(ligne,"Usage: %s %s %s speed \nspeed shall be a decimal number between 0.0 and 1.0",argv[0],argv[1],argv[2]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
            }
            
            // j'applique la correction
            if ( result == TCL_OK) {
               int correctResult = TEL_DRV.tel_correct(tel,alphaDirection,alphaDistance,deltaDirection,deltaDistance);
               if ( correctResult == 0 ) {
                  Tcl_SetResult(interp,"",TCL_VOLATILE);
                  result =  TCL_OK;
               } else {
                  Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
            }
         }         
      } else if (strcmp(argv[2],"model")==0) {
         /* --- model ---*/
         if (argc>=5) {
            Tcl_ResetResult(interp);
            result =  TCL_OK;
            for (k=3;k<=argc-1;k++) {
               if (strcmp(argv[k],"-coefficients")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_coefficients) ) {
                     strcpy(tel->radec_model_coefficients, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_symbols), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-enabled")==0) {
                  tel->radec_model_enabled =atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-name")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_name) ) {
                     strcpy(tel->radec_model_name, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_name), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-date")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_date) ) {
                     strcpy(tel->radec_model_date, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_date), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-pressure")==0) {
                  tel->radec_model_pressure =atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-symbols")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_symbols) ) {
                     strcpy(tel->radec_model_symbols, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_symbols), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-temperature")==0) {
                  tel->radec_model_temperature =atoi(argv[k+1]);
               }
            }
            
         } else if (argc==4) {
            // je retourne les valeurs des parametres
            if (strcmp(argv[3],"-enabled")==0) {
               sprintf(ligne,"%d",tel->radec_model_enabled);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-coefficients")==0) {
               Tcl_SetResult(interp,tel->radec_model_coefficients,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-name")==0) {
               Tcl_SetResult(interp,tel->radec_model_name,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-date")==0) {
               Tcl_SetResult(interp,tel->radec_model_date,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-pressure")==0) {
               sprintf(ligne,"%d",tel->radec_model_pressure);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_OK;
            } else if ( strcmp(argv[3],"-symbols")==0) {
               Tcl_SetResult(interp,tel->radec_model_symbols,TCL_VOLATILE); 
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-temperature")==0) {
               sprintf(ligne,"%d",tel->radec_model_temperature);
               result =  TCL_OK;
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            } else {
               sprintf(ligne,"Usage: %s %s model -enabled 0|1 -name ?value? -date ?value? -symbols {IH ID ... } -coefficients ?values? -temperature ?value? -pressure ?value?",argv[0],argv[1]);            
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_ERROR;
            }
               
         } else {
            sprintf(ligne,"Usage: %s %s model -enabled 0|1 -name ?value? -date ?value? -symbols {IH ID ... } -coefficients ?values? -temperature ?value? -pressure ?value?",argv[0],argv[1]);            
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         // j'arrete le timer utilise par tel_correct 
         tel->timeDone = 1; 
         if (argc>=4) {
            tel_radec_stop(tel,argv[3]);
         } else {
            tel_radec_stop(tel,"");
         }
      } else if (strcmp(argv[2],"motor")==0) {
         /* --- motor ---*/
         if (argc>=4) {
            tel->radec_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->radec_motor=1;
            }
            if ( tel_radec_motor(tel) == 0 ) {
               Tcl_SetResult(interp,"",TCL_VOLATILE);
            } else {
               Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
               result = TCL_ERROR;
            }
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"mindelay")==0) {
         /* --- mindelay delay minimal de correction ---*/
         if (argc>=4) {
            // je memorise la nouvelle valeur
            tel->minRadecDelay=atoi(argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            // je retourne la valeur courante
            sprintf(ligne,"%d", tel->minRadecDelay);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         }
      } else if (strcmp(argv[2],"guiding")==0) {
         if(argc!=3 && argc!=4) {
            sprintf(ligne,"Usage: %s %s {0|1}",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            if (argc == 3 ) {
               sprintf(ligne,"%d",tel->radecGuidingState);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_OK;
            } else {
               int guiding;
               if (Tcl_GetInt(interp, argv[3], &guiding) != TCL_OK) {
                  sprintf(ligne,"Usage: %s %s \nguiding shall be {0|1]}",argv[0],argv[1]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result = TCL_ERROR;
               } else {
                  if ( guiding != 0 && guiding != 1 ) {
                     sprintf(ligne,"Usage: %s %s \nguiding shall be {0|1]}",argv[0],argv[1]);
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                     result = TCL_ERROR;
                  } else {
                     result = TEL_DRV.tel_set_radec_guiding(tel, guiding) ;
                     if ( result == 1 ) {
                        Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                        result = TCL_ERROR;
                     } else {
                        // je memorise la nouvelle valeur 
                        tel->radecGuidingState = guiding;
                        // je retourne la nouvelle valeur au TCL
                        sprintf(ligne,"%d",tel->radecGuidingState);
                        Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                        result = TCL_OK;
                     }
                  }
               }
            }
         }
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelFocus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
            tel->focus0=atof(argv[3]);
            tel_focus_init(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
         tel_focus_coord(tel,ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         if (argc>=4) {
            tel->focus0=atof(argv[3]);
            if (argc>=5) {
               for (k=4;k<=argc-1;k++) {
                  if (strcmp(argv[k],"-rate")==0) {
                     tel->focus_goto_rate=atof(argv[k+1]);
                  }
                  if (strcmp(argv[k],"-blocking")==0) {
                     tel->focus_goto_blocking=atoi(argv[k+1]);
                  }
               }
            }
            tel_focus_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto number ?-rate value? ?-blocking boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->focus_move_rate=atof(argv[4]);
            }
            tel_focus_move(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s move +|- ?-rate value?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         if (argc>=4) {
            tel_focus_stop(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            tel_focus_stop(tel,"");
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         }
      } else if (strcmp(argv[2],"motor")==0) {
         /* --- motor ---*/
         if (argc>=4) {
            tel->focus_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->focus_motor=1;
            }
            tel_focus_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if(strcmp(argv[2],"out")==0) {
         /* obsolete function */
         sprintf(ligne,"%s focus move - %f",argv[0],tel->focus_move_rate);
         result=Tcl_Eval(interp,ligne);
      } else if(strcmp(argv[2],"in")==0) {
         /* obsolete function */
         sprintf(ligne,"%s focus move + %f",argv[0],tel->focus_move_rate);
         result=Tcl_Eval(interp,ligne);
      } else if(strcmp(argv[2],"fast")==0) {
         /* obsolete funstion */
         tel->focus_move_rate=1.;
      } else if(strcmp(argv[2],"slow")==0) {
         /* obsolete funstion */
         tel->focus_move_rate=0.;
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelModel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   if((argc!=2)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s ?function_cat2tel function_tel2cat? ",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
		if(argc!=2) {
	      sprintf(tel->model_cat2tel,"%s",argv[2]);
	      sprintf(tel->model_tel2cat,"%s",argv[3]);
		}
      sprintf(ligne,"%s %s",tel->model_cat2tel,tel->model_tel2cat);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}


/* -----------------------------------------------------------------------------
 *  cmdTelThreadId()
 *
 *  retourne le nuemro du thread du telescope
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelThreadId(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *) clientData;
   sprintf(ligne, "%s", tel->telThreadId);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/* -----------------------------------------------------------------------------
 *  cmdTelConsoleLog()
 *
 *  active/desactive les traces dans la console
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelConsoleLog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      tel->consoleLog=atoi(argv[2]);
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?0|1|2?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->consoleLog);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

//-------------------------------------------------------------
//
// FONCTIONS PAR DEFAUT de struct tel_drv_t TEL_DRV
//
//-------------------------------------------------------------

static void timerCallback(ClientData tel ) {
  ((struct telprop *)tel)->timeDone  = 1;
}



//-------------------------------------------------------------
// default_tel_correct
//
// envoie une correction en ascension droite et en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param direction direction de la correction sur l'axe alpha E, W  
// @param distance  valeur de la correction sur l'axe alpha en arseconde  
// @param direction direction de la correction sur l'axe delta N ,S  
// @param distance  valeur de la correction sur l'axe delta en arseconde  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_correct(struct telprop *tel, char *alphaDirection, double alphaDistance, char *deltaDirection, double deltaDistance)
{
   char alphaLog[1024];
   char deltaLog[1024];
   
   if ( alphaDistance > 0 ) { 
      // je calcule le delai de deplacement en milliseconde sur l'axe alpha
      // delai(miliseconde) = 1000 * distance(arcsec) * vitesse(arsec/seconde)
      int timerDelay = (int) (1000.0 * alphaDistance / tel->radecGuidingSpeed);
      
      if ( timerDelay >= tel->minRadecDelay ) {
         int foundEvent= 1;
         Tcl_TimerToken timerToken;
         tel->timeDone = 0;

         // je cree un timer
         timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
         // je demarre le mouvement
         tel_radec_move(tel,alphaDirection);
         
         // j'attends un evenement de fin du timer

         while ( tel->timeDone == 0) {
            foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            //if (Tcl_LimitExceeded(interp)) {
            //   break;
            //}
         }
         // j'arrete le mouvement
         tel_radec_stop(tel,alphaDirection);            
         // je ssupprime le timer
         Tcl_DeleteTimerHandler(timerToken);
         
         if ( tel->consoleLog >= 1 ) {
            sprintf(alphaLog, "%s %.3fs",  alphaDirection, (float)timerDelay/1000);
         }
         
      } else {
         if ( tel->consoleLog >= 1 ) {
            sprintf(alphaLog, "%s %.3fs ignored (<%.3fs)", alphaDirection, (float)timerDelay/1000,(float) tel->minRadecDelay/1000);
         }
      } 
   } else {
      strcpy(alphaLog,"");
   }
   if ( deltaDistance > 0 ) { 
      // je calcule le delai de deplacement en milliseconde sur l'axe delta
      // delai(miliseconde) = 1000 * distance(arcsec) * vitesse(arsec/seconde)
      int timerDelay = (int) (1000.0 * deltaDistance / tel->radecGuidingSpeed);
      
      if ( timerDelay >= tel->minRadecDelay ) {
         int foundEvent= 1;
         Tcl_TimerToken timerToken;
         tel->timeDone = 0;

         // je cree un timer
         timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
         // je demarre le mouvement
         tel_radec_move(tel,deltaDirection);
         
         // j'attends un evenement de fin du timer
         while (tel->timeDone == 0) {
            foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            //if (Tcl_LimitExceeded(interp)) {
            //   break;
            //}
         }
         // j'arrete le mouvement
         tel_radec_stop(tel,deltaDirection);            
         // je ssupprime le timer
         Tcl_DeleteTimerHandler(timerToken);
         
         if ( tel->consoleLog >= 1 ) {
            sprintf(deltaLog, "%s %.3fs", deltaDirection, (float)timerDelay/1000);
         }
         
      } else {
         if ( tel->consoleLog >= 1 ) {
            sprintf(deltaLog, "%s %.3fs ignored (<%.3fs)", deltaDirection, (float)timerDelay/1000,(float) tel->minRadecDelay/1000);
         }
      } 
   } else {
      strcpy(deltaLog,"");
   }
   
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "move to %s %s\n", alphaLog, deltaLog);
   }
   return 0;
}

//-------------------------------------------------------------
// tel_get_radec_guiding 
//
//  retourne l'etat de l'autoguidage 
//
// @param tel   pointeur structure telprop
// @param guiding  0 : auto guidage arrete, 1 : auto guidage actif
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_get_radec_guiding(struct telprop *tel, int *guiding) {   
   *guiding = tel->radecGuidingState;   
   return 0;  
}

//-------------------------------------------------------------
// tel_set_radec_guiding 
//
//  commande marche/arret du guidage
//  Avertit l'interface de controle Audela est en auto-guidage (checkbox du bandeau sophie dans AudeLA)
//  pour inhiber les raquettes physiques au T193 pendant l'uto-guidage
//
// @param tel   pointeur structure telprop
// @param guiding  0 : auto guidage arrete, 1 : auto guidage actif
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_set_radec_guiding(struct telprop *tel, int guiding) {
   tel->radecGuidingState = guiding;
   return 0;
}

int tel_init_common(struct telprop *tel, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --------------------------------------------------------- */
/* argv[2] : symbole du port (com1,etc.)                     */
/* argv[>=3] : optionnels : -protocol -name                  */
/* --------------------------------------------------------- */
{
   int k,kk;
   tel->speed=1;
   /* --- Decode les options de tel::create en fonction de argv[>=3] ---*/
   tel->index_tel=0;
   if (argc>=5) {
      for (kk=3;kk<argc-1;kk++) {
         if (strcmp(argv[kk],"-name")==0) {
            // je copie le nom dans tel->name pour determiner 
            // si la monture a la correction de la refraction , 
            // meme si son nom n'est pas dans le tableau tel_ini[k].name
            strncpy(tel->name, argv[kk+1], sizeof(tel->name));
            // je cherche le nom dans le tableau tel_ini[k]
            k=0;
            while (strcmp(tel_ini[k].name,"")!=0) {
               if (strcmp(tel_ini[k].name,argv[kk+1])==0) {
                  tel->index_tel=k;
                  break;
               }
               k++;
            }
        }
      }
   }

   /* --- initialisation du numero de port du PC ---*/
   strcpy(tel->portname,"unknown");
   tel->portindex = 0;
   if (argc>=2) {
      if(strcmp(argv[2],tel_ports[1])==0) {
         tel->portindex = 1;
      }
      strcpy(tel->portname,argv[2]);
   }
   /* --- init of general variables for the telescope --- */
   strcpy(tel->alignmentMode,"EQUATORIAL");
   tel->refractionCorrection = 0 ;          // par defaut la monture n'a pas de correction de la refraction
   tel->foclen=tel_ini[tel->index_tel].foclen;
   tel->ra0=0.;
   tel->dec0=0.;
   tel->radec_goto_rate=0.;
   tel->radec_goto_blocking=1;
   tel->radec_move_rate=0.;
   tel->focus0=0.;
   tel->focus_goto_rate=0;
   tel->focus_move_rate=0;
   tel->radecGuidingState = 0;   // etat de la session de guidage par defaut
   tel->radecGuidingSpeed = 5;   // vitesse de guidage par defaut (arcsec/seconde)
   tel->minRadecDelay = 0;
   tel->consoleLog = 0;    
   tel->radec_model_enabled = 0;
   strcpy(tel->radec_model_name,""); 
   strcpy(tel->radec_model_symbols,""); 
   strcpy(tel->radec_model_coefficients,"");
   tel->radec_model_temperature = 290;  // temperatature par defaut 
   tel->radec_model_pressure = 101325;  // pression par defaut

   strcpy(tel->model_cat2tel,"");
   strcpy(tel->model_tel2cat,"");
   strcpy(tel->homeName,"");
   strcpy(tel->homePosition,"");
   return 0;
}

