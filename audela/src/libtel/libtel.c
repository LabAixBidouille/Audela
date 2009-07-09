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

// $Id: libtel.c,v 1.8 2009-07-09 17:34:21 michelpujol Exp $

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

#if !defined(OS_WIN)
#define MB_OK 1
void MessageBox(void *handle, char *msg, char *title, int bof)
{
   fprintf(stderr,"%s: %s\n",title,msg);
}
#endif

#define BP(i) MessageBox(NULL,#i,"Libtel",MB_OK)


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
   char s[2048];
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
         sprintf(s, "cmdCamCreate: Global variable tcl_platform(os) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      if((threaded=Tcl_GetVar(interp,"tcl_platform(threaded)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdCamCreate: Global variable tcl_platform(threaded) not found");
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
            // je cree la thread de la camera
            Tcl_Eval(interp, "thread::create");
            strcpy(telThreadId, interp->result);
            
            // je duplique la commande "cam1" dans la thread du telescope
            sprintf(s,"thread::copycommand %s %s ",telThreadId, argv[0]);
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "::console::disp" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "::console::disp");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_angle2lx200ra" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2lx200ra");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2lx200dec" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2lx200dec");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angle2hms" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2hms");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            // je duplique la commande "mc_angle2deg" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2deg");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }            
            
            // je duplique la commande "mc_date2iso8601" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2iso8601");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            // je duplique la commande "mc_date2ymdhms" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2ymdhms");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_angle2dms" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angle2dms");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_angles2nexstar" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_angles2nexstar");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_date2lst" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_date2lst");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            
            // je duplique la commande "mc_anglesep" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_anglesep");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je duplique la commande "mc_nexstar2angles" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_nexstar2angles");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }
            // je duplique la commande "mc_anglescomp" dans la thread de la camera
            sprintf(s,"thread::copycommand %s %s ",telThreadId, "mc_anglescomp");
            if ( Tcl_Eval(interp, s) == TCL_ERROR ) {
               sprintf(s, "cmdCamCreate: %s",interp->result);
               Tcl_SetResult(interp, s, TCL_VOLATILE);
               return TCL_ERROR;
            }

            // je prepare la commande de creation de la camera dans la thread de la camera :
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
            // je lance la creattion de la camera en l'executant dans la thread de la camera
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
            sprintf(s, "cmdCamCreate: %s",interp->result);
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
         // si on n'est pas dans la thread de la camera je transmets la commande a la thread de la camera
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
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?{GPS long e|w lat alt}?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      /* returns a type {degrees degrees} list */
      /* result is a list : GPS long(deg) e|w lat(deg) alt(m) */
      tel_home_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      tel = (struct telprop*)clientData;
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
   }
   return result;
}

static void timerCallback(ClientData clientData ) {
   ((struct telprop *)clientData)->timeDone = 1;
}

int cmdTelRaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state? ?options?";
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
            tel_radec_init(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ra angle_dec}",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
			tel_radec_coord(tel,texte);
			 /* - call the pointing model if exists -*/
         sprintf(ligne,"set libtel(radec) {%s}",texte);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
         Tcl_Eval(interp,ligne);
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
			 /* - end of pointing model-*/
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"state")==0) {
         /* --- state ---*/
			tel_radec_state(tel,texte);
            Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         tel->active_backlash = 0;
         tel->radec_goto_blocking = 0;

         /* --- goto ---*/
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
            if (argc>=5) {
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
               }
            }
            tel_radec_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ra angle_dec} ?-rate value? ?-blocking boolean? ?-backlash boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            if (argc < 6) {
               tel_radec_move(tel,argv[3]);
               Tcl_SetResult(interp,"",TCL_VOLATILE);
            } else {
               //argv[5] =duree du dépcement en seconde 
               //exemple :  tel1 radec move n 1 4
               int timerDelay = 1000 * atoi(argv[5]);
               int foundEvent;
               tel->timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
               tel_radec_move(tel,argv[3]);

               // j'attends un evenement
               tel->timeDone = 0; 
               foundEvent = 1;
               while (!tel->timeDone && foundEvent) {
                  foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                  //if (Tcl_LimitExceeded(interp)) {
                  //   break;
                  //}
               }
               if (argc>=4) {
                  tel_radec_stop(tel,argv[3]);

               } else {
                  tel_radec_stop(tel,"");
               }

               tel->timeDone = 0;
               tel->timerToken = NULL;
               Tcl_SetResult(interp,"",TCL_VOLATILE);
               result = TCL_OK;
            }            
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?rate? ?delay (ms)?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         tel->timeDone = 2; 
         Tcl_DeleteTimerHandler(tel->timerToken);
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
            tel_radec_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
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
            sprintf(ligne,"Usage: %s %s move +|- ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         if (argc>=4) {
            tel_focus_stop(tel,argv[3]);
         } else {
            tel_focus_stop(tel,"");
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

int cmdTelThreadId(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *) clientData;
   sprintf(ligne, "%s", tel->telThreadId);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}


int tel_init_common(struct telprop *tel, int argc, char **argv)
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
   tel->foclen=tel_ini[tel->index_tel].foclen;
   tel->ra0=0.;
   tel->dec0=0.;
   tel->radec_goto_rate=0.;
   tel->radec_goto_blocking=1;
   tel->radec_move_rate=0.;
   tel->focus0=0.;
   tel->focus_goto_rate=0;
   tel->focus_move_rate=0;
   strcpy(tel->model_cat2tel,"");
   strcpy(tel->model_tel2cat,"");
   return 0;
}

