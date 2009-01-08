/* telescop.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#include "runtime.h"
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <stdio.h>
#include "telescop.h"
#include <libtel/util.h>


#if defined(OS_WIN)
//Device
OPENPMACDEVICE DeviceOpen;
SETASCIICOMM DeviceSetAsciiComm;
CLOSEPMACDEVICE DeviceClose;
GETRESPONSEA DevicePutGet;
SENDCOMMANDA DeviceSendCommandeA;
#endif

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"Delta Tau",    /* telescope name */
    "Delta Tau",    /* protocol name */
    "delta tau",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

/********************************************************/
/* sate_move_radec                                      */
/* ' ' : pas de mouvement                               */
/* 'A' : mouvement demande en mode Temma (radec goto)   */
/*                                                      */
/********************************************************/
char sate_move_radec;

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{
   unsigned short ip[4];
   char ipstring[50],portstring[50],s[1024];
   int k, kk, kdeb, nbp, klen;
   Tcl_DString dsptr;
   char **argvv=NULL;
   int argcc,res;
   FILE *f;

	/* -ip 127.0.0.1 -port 1025 -type umac|pmac*/
   tel->tempo=200;
   f=fopen("mouchard_deltatau.txt","wt");
   fclose(f);
	/* --- decode type (umac by default) ---*/
	strcpy(s,"umac");
   if (argc >= 1) {
      for (kk = 0; kk < argc; kk++) {
         if (strcmp(argv[kk], "-type") == 0) {
            if ((kk + 1) <= (argc - 1)) {
               strcpy(s, argv[kk + 1]);
            }
         }
      }
   }
	if (strcmp(s,"umac")==0) {
		tel->type=0;
	} else {
		tel->type=1;
	}
	/* ============ */
	/* === UMAC === */
	/* ============ */
	if (tel->type==0) {
		/* --- decode IP  --- */
		ip[0] = 192;
		ip[1] = 168;
		ip[2] = 10;
		ip[3] = 46;
		if (argc >= 1) {
			for (kk = 0; kk < argc; kk++) {
				if (strcmp(argv[kk], "-ip") == 0) {
					if ((kk + 1) <= (argc - 1)) {
						strcpy(ipstring, argv[kk + 1]);
					}
				}
			}
		}
		klen = (int) strlen(ipstring);
		nbp = 0;
		for (k = 0; k < klen; k++) {
			if (ipstring[k] == '.') {
				nbp++;
			}
		}
		if (nbp == 3) {
			kdeb = 0;
			nbp = 0;
			for (k = 0; k <= klen; k++) {
				if ((ipstring[k] == '.') || (ipstring[k] == '\0')) {
					ipstring[k] = '\0';
					ip[nbp] = (unsigned short) (unsigned char) atoi(ipstring + kdeb);
					kdeb = k + 1;
					nbp++;
				}
			}
		}
		sprintf(tel->ip, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
		f=fopen("mouchard_deltatau.txt","at");
		fprintf(f,"IP=%s\n",tel->ip);
		fclose(f);
		/* --- decode port  --- */
		tel->port = 1025;
		if (argc >= 1) {
			for (kk = 0; kk < argc; kk++) {
				if (strcmp(argv[kk], "-port") == 0) {
					if ((kk + 1) <= (argc - 1)) {
						strcpy(portstring, argv[kk + 1]);
						tel->port = atoi(portstring);
					}
				}
			}
		}
		f=fopen("mouchard_deltatau.txt","at");
		fprintf(f,"PORT=%d\n",tel->port);
		fclose(f);
		/* --- open the port and record the channel name ---*/
		sprintf(s,"socket \"%s\" \"%d\"",tel->ip,tel->port);
		//strcpy(s,"open com1 w+");
		if (mytel_tcleval(tel,s)==1) {
			strcpy(tel->msg,tel->interp->result);
			return 1;
		}
		strcpy(tel->channel,tel->interp->result);
		/* --- configuration of the TCP socket ---*/
		sprintf(s,"fconfigure %s -blocking 0 -buffering none -translation binary -encoding binary -buffersize 50",tel->channel); mytel_tcleval(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		/* --- decode init command list --- */
		Tcl_DStringInit(&dsptr);
		if (argc >= 1) {
			for (kk = 0; kk < argc; kk++) {
				if (strcmp(argv[kk], "-init") == 0) {
					if ((kk + 1) <= (argc - 1)) {
						Tcl_DStringAppend(&dsptr,argv[kk + 1],-1);
					}
				}
			}
		}
		if (strcmp(Tcl_DStringValue(&dsptr),"")==0) {
			Tcl_DStringAppend(&dsptr,"M132->X:\\\\$078200,18,1 M140->Y:\\\\$0000C0,0,1 M231->X:\\\\$078208,17,1 M232->X:\\\\$078208,18,1 M240->Y:\\\\$000140,0,1 M245->Y:\\\\$000140,10,1 M331->X:\\\\$078210,17,1 M332->X:\\\\$078210,18,1 M340->Y:\\\\$0001C0,0,1 M345->Y:\\\\$0001C0,10,1 M440->Y:\\\\$000240,0,1",-1);
		}
		/* --- execute init command list--- */
		if (strcmp(Tcl_DStringValue(&dsptr),"")!=0) {
			if (Tcl_SplitList(tel->interp,Tcl_DStringValue(&dsptr),&argcc,&argvv)==TCL_OK) {
				for (k=0;k<argcc;k++) {
					res=deltatau_put(tel,argvv[k]);
					if (res==1) {
						Tcl_Free((char *) argvv);
						return TCL_ERROR;
					}
				}
				Tcl_Free((char *) argvv);
			}
		}
		/* --- sppeds --- */
		tel->track_diurnal=0.004180983;
		tel->speed_track_ra=tel->track_diurnal; /* (deg/s) */
		tel->speed_track_dec=0.; /* (deg/s) */
		tel->speed_slew_ra=20.; /* (deg/s) */
		tel->speed_slew_dec=20.; /* (deg/s) */
		tel->radec_speed_dec_conversion=10.; /* (ADU)/(deg) */
		tel->radec_position_conversion=10000.; /* (ADU)/(deg) */
		tel->radec_move_rate_max=1.0; /* deg/s */
		/* --- Match --- */
		tel->ha00=0.;
		tel->roth00=1507500;
		tel->dec00=-90;
		tel->rotd00=1250000;
		/* --- stops --- */
		tel->stop_e_uc=-13900;
		tel->stop_w_uc=3090000;
		/* --- Home --- */
		tel->latitude=-29.260406;
		sprintf(tel->home0,"GPS 70.732222 W %+.6f 2347",tel->latitude);
	}
	/* ============ */
	/* === PMAC === */
	/* ============ */
#if defined(OS_WIN)
	if (tel->type==1) {
		tel->hPmacLib = LoadLibrary(DRIVERNAME);
		if( tel->hPmacLib  == NULL ) {
			strcpy(tel->msg,"RunTimeLink error");
			return 1;
		}
		//Ouverture des Devices
		DeviceOpen = (OPENPMACDEVICE)GetProcAddress(tel->hPmacLib,"OpenPmacDevice");
		DeviceSetAsciiComm = (SETASCIICOMM)GetProcAddress(tel->hPmacLib,"PmacSetAsciiComm");
		DeviceClose = (CLOSEPMACDEVICE)GetProcAddress(tel->hPmacLib,"ClosePmacDevice");
		DevicePutGet = (GETRESPONSEA)GetProcAddress(tel->hPmacLib,"PmacGetResponseA");
		DeviceSendCommandeA = (SENDCOMMANDA)GetProcAddress(tel->hPmacLib,"PmacSendCommandA");

		if(!DeviceSetAsciiComm)	{
			strcpy(tel->msg,"DeviceSetAsciiComm error");
			return 1;
		}
		if(!DeviceClose) {
			strcpy(tel->msg,"DeviceClose error");
			return 1;
		}
		if(!DeviceSendCommandeA) {
			strcpy(tel->msg,"DeviceSendCommandeA error");
			return 1;
		}
		if(!DevicePutGet) {
			strcpy(tel->msg,"DevicePutGet error");
			return 1;
		}
		if(!DeviceOpen) {
			strcpy(tel->msg,"DeviceOpen error");
			return 1;
		}
		tel->PmacDevice=0;
		sprintf(tel->channel,"%d",tel->PmacDevice);
		res = (*DeviceOpen)(tel->PmacDevice);
		res = (*DeviceSetAsciiComm)(tel->PmacDevice,BUS); /*Set configuration sur bus*/
		sprintf(s,"%s",BUS);

		deltatau_put(tel,"M231->X:$0079,21,1");
		deltatau_put(tel,"M232->X:$0079,22,1");
		deltatau_put(tel,"M240->Y:$08D4,0,1");
		deltatau_put(tel,"M245->Y:$08D4,10,1");
		deltatau_put(tel,"M230->X:$08D4,11,1");

		deltatau_put(tel,"M131->X:$003D,21,1");
		deltatau_put(tel,"M132->X:$003D,22,1");
		deltatau_put(tel,"M140->Y:$0814,0,1");
		//deltatau_put(tel,"M145->Y:$0814,10,1");

		deltatau_put(tel,"M331->X:$00B5,21,1");
		deltatau_put(tel,"M332->X:$00B5,22,1");
		deltatau_put(tel,"M340->Y:$0994,0,1");
		deltatau_put(tel,"M345->Y:$0994,10,1");
		/*
#3I322=4
#3j+
#3home
#3I322=3
#3j=-34615.0
#3homez
*/

		deltatau_put(tel,"M440->Y:$0A54,0,1"); 
		/* --- sppeds --- */
		tel->track_diurnal=0.004180983;
		tel->speed_track_ra=tel->track_diurnal; /* (deg/s) */
		tel->speed_track_dec=0.; /* (deg/s) */
		tel->speed_slew_ra=20.; /* (deg/s) */
		tel->speed_slew_dec=20.; /* (deg/s) */
		tel->radec_speed_dec_conversion=10.; /* (ADU)/(deg) */
		tel->radec_position_conversion=-10000.; /* (ADU)/(deg) */
		tel->radec_move_rate_max=1.0; /* deg/s */
		/* --- Match --- */
		tel->ha00=0.;
		tel->roth00=0;
		tel->dec00=43.75203;
		tel->rotd00=0;
		/* --- stops --- */
		tel->stop_e_uc=-1624651;
		tel->stop_w_uc=1549515;
		/* --- Home --- */
		tel->latitude=43.75203;
		sprintf(tel->home0,"GPS 6.92353 E %+.6f 1320.0",tel->latitude);
	}
#endif
   /* --- sortie --- */
   Tcl_DStringFree(&dsptr);
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return 0;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   deltatau_delete(tel);
   return 0;
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return mytel_radec_state(tel,result);
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return mytel_radec_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return mytel_radec_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   return mytel_radec_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return mytel_radec_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return mytel_focus_init(tel);
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return mytel_focus_coord(tel,result);
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return mytel_focus_goto(tel);
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return mytel_focus_move(tel,direction);
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return mytel_focus_stop(tel,direction);
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return mytel_focus_motor(tel);
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   return mytel_date_get(tel,ligne);
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return mytel_date_set(tel,y,m,d,h,min,s);
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   return mytel_home_get(tel,ligne);
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   return mytel_home_set(tel,longitude,ew,latitude,altitude);
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
   deltatau_match(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   deltatau_stategoto(tel,&state);
   if (state==1) {strcpy(result,"tracking");}
   else if (state==2) {strcpy(result,"pointing");}
   else {strcpy(result,"unknown");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
   int nbgoto=2;
   int p10,p1,p20,p2;
   double tol;

   deltatau_arret_pointage(tel);
   deltatau_goto(tel);
   sate_move_radec='A';
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      deltatau_positions12(tel,&p10,&p20);
      tol=(tel->radec_position_conversion)/3600.*20; /* tolerance +/- 20 arcsec */
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         deltatau_positions12(tel,&p1,&p2);
         if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
         p10=p1;
         p20=p2;
         if (time_in>=time_out) {break;}
      }
	   if (nbgoto>1) {
		   deltatau_goto(tel);
			/* A loop is actived until the telescope is stopped */
			deltatau_positions12(tel,&p10,&p20);
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				deltatau_positions12(tel,&p1,&p2);
				if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
				p10=p1;
				p20=p2;
				if (time_in>=time_out) {break;}
			}
      }
      deltatau_suivi_marche(tel);
      sate_move_radec=' ';
   }
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
   int nbgoto=1;
   int p10,p1,p20,p2;
   double tol;

   deltatau_arret_pointage(tel);
   deltatau_hadec_goto(tel);
   sate_move_radec='A';
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      deltatau_positions12(tel,&p10,&p20);
      tol=(tel->radec_position_conversion)/3600.*20; /* tolerance +/- 20 arcsec */
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         deltatau_positions12(tel,&p1,&p2);
         if ((fabs(p1-p10)<tol)&&(fabs(p2-p20)<tol)) {break;}
         p10=p1;
         p20=p2;
         if (time_in>=time_out) {break;}
      }
      sate_move_radec=' ';
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
/*
* #1I122=v en horaire
* #2I222=v en delta
# v=(deg/s)*10
*/
{
   char s[1024],direc[10];
   int res;
   double v;
   char axe,sens;
   
   if (tel->radec_move_rate>1.0) {
      tel->radec_move_rate=1;
   } else if (tel->radec_move_rate<0.) {
      tel->radec_move_rate=0.;
   }
   v=tel->radec_move_rate*tel->radec_move_rate_max*tel->radec_speed_dec_conversion;
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   sens='+';
   if (strcmp(direc,"N")==0) {
      axe='2';
      sens='-';
   } else if (strcmp(direc,"S")==0) {
      axe='2';
      sens='+';
   } else if (strcmp(direc,"E")==0) {
      axe='1';
      sens='-';
   } else if (strcmp(direc,"W")==0) {
      axe='1';
      sens='+';
   }
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"#%cj%c",axe,sens);
   res=deltatau_put(tel,s);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],axe;
   int res;
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      deltatau_stopgoto(tel);
      sate_move_radec=' ';
   } else {
      /* on arrete un MOVE */
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,tel->interp->result);
      if (strcmp(direc,"N")==0) {
         axe='2';
      } else if (strcmp(direc,"S")==0) {
         axe='2';
      } else if (strcmp(direc,"E")==0) {
         axe='1';
      } else if (strcmp(direc,"W")==0) {
         axe='1';
      }
      sprintf(s,"#%ck",axe);
      res=deltatau_put(tel,s);
      return 0;
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      deltatau_suivi_arret(tel);
   } else {
      /* start the motor */
      deltatau_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   deltatau_coord(tel,result);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   deltatau_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->home0);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   longitude=(double)fabs(longitude);
   if (longitude>360.) { longitude=0.; }
   if ((ew[0]!='w')&&(ew[0]!='W')&&(ew[0]!='e')&&(ew[0]!='E')) {
      ew[0]='E';
   }
   if (latitude>90.) {latitude=90.;}
   if (latitude<-90.) {latitude=-90.;}
   sprintf(tel->home0,"GPS %f %c %f %f",longitude,ew[0],latitude,altitude);
   tel->latitude=latitude;
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   deltatau_hadec_coord(tel,result);
   return 0;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   FILE *f;
   f=fopen("mouchard_deltatau.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   fclose(f);
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
      f=fopen("mouchard_deltatau.txt","at");
      fprintf(f,"RESU-PB <%s>\n",tel->interp->result);
      fclose(f);
      return 1;
   }
   f=fopen("mouchard_deltatau.txt","at");
   fprintf(f,"RESU-OK <%s>\n",tel->interp->result);
   fclose(f);
   return 0;
}

int deltatau_delete(struct telprop *tel)
{
   char s[1024];
	if (tel->type==0) {
		/* --- Fermeture du port com */
		sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
	}
#if defined(OS_WIN)
	if (tel->type==1) {
		(*DeviceClose)(tel->PmacDevice); /* =0 pour une seule carte */
	}
#endif
   return 0;
}

int deltatau_put(struct telprop *tel,char *cmd)
{
   char s[1024];
	/*char ss[1024];*/

	if (tel->type==0) {
		sprintf(s,"puts -nonewline %s \"[binary format H2H2H4H4S 40 BF 0000 0000 [string length \"%s\"]]%s\"",tel->channel,cmd,cmd);
		//sprintf(ss,"puts \"PUT s=<%s> envoye\"",s);
		//mytel_tcleval(tel,ss);
		//mytel_tcleval(tel,s);	
		if (mytel_tcleval(tel,s)==1) {
			return 1;
		}
	}
#if defined(OS_WIN)
	if (tel->type==1) {
		strcpy(tel->pmac_response,"0");
		(*DevicePutGet)(tel->PmacDevice,tel->pmac_response,990,cmd);
	}
#endif
   return 0;
}

int deltatau_read(struct telprop *tel,char *res)
{
   char s[2048];
	if (tel->type==0) {
		/* --- trancoder l'hexad�cimal de res en num�rique ---*/
		strcpy(s,"\
		proc deltatau_transcode { channel } {\
   		set res [read -nonewline $channel];\
   		binary scan $res H* chaine;\
   		set n [string length $chaine] ;\
   		for {set k 0} {$k<$n} {set k [expr $k+2]} {\
				set cars [string range $chaine 0 1] ;\
				if {$cars==\"06\"} { set chaine [string range $chaine 2 end] } else { break } ;\
			};\
   		set n [string length $chaine] ;\
			set cars [string range $chaine [expr $n-2] [expr $n-1]] ;\
			if {$cars==\"06\"} { set chaine [string range $chaine 0 [expr $n-3]] } ;\
   		set n [string length $chaine] ;\
			set cars [string range $chaine [expr $n-2] [expr $n-1]] ;\
			if {$cars==\"0d\"} { set chaine [string range $chaine 0 [expr $n-3]] } ;\
			set n [string length $chaine] ;\
   		set resultat \"\" ;\
   		for {set k 0} {$k<$n} {set k [expr $k+2]} {\
				set h [string range $chaine $k [expr $k+1]] ;\
				if {($h==\"0d\")||($h==\"06\")} {\
					set res \"\\n\";\
				} else {\
					set ligne \"format %c 0x$h\" ;\
					set res [eval $ligne] ;\
				};\
				append resultat $res ;\
			};\
			return $resultat ;\
		}");
		mytel_tcleval(tel,s);
		sprintf(s,"deltatau_transcode %s",tel->channel);
		if (mytel_tcleval(tel,s)==1) {
			strcpy(res,tel->interp->result);
			return 1;
		}
	   strcpy(res,tel->interp->result);
	}
#if defined(OS_WIN)
	if (tel->type==1) {
		sprintf(res,"%s",tel->pmac_response);
	}
#endif
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage DELTATAU   --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int deltatau_arret_pointage(struct telprop *tel)
{
   char s[1024],axe;
   int res;
   /*--- Arret pointage */
   axe='1';
   sprintf(s,"#%ck",axe);
   res=deltatau_put(tel,s);
   axe='2';
   sprintf(s,"#%ck",axe);
   res=deltatau_put(tel,s);
   return 0;
}

int deltatau_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   int res;
   char ras[20];
   char decs[20];   
   int roth_uc,rotd_uc;
   int h,m,retournement=0;
   double sec,lst,ha,dec,ra;
   /* --- Vide le buffer --- */
   res=deltatau_read(tel,s);
   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
   axe='2';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      rotd_uc=atoi(s);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      if (fabs(dec)>90) {
         retournement=1;
         dec=(tel->latitude)/fabs(tel->latitude)*180-dec;
      }
   }
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      roth_uc=atoi(s);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      /* H=TSL-alpha => alpha=TSL-H */
      lst=deltatau_tsl(tel,&h,&m,&sec);
      ra=lst-ha+360*5;
      if (retournement==1) {
         ra+=180.;
      }
      ra=fmod(ra,360.);
   }
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,tel->interp->result);
   sprintf(s,"mc_angle2dms %f 90 zero 0 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,tel->interp->result);
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int deltatau_hadec_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   int res;
   char ras[20];
   char decs[20];   
   int roth_uc,rotd_uc;
   int retournement=0;
   double ha,dec,ra;
   /* --- Vide le buffer --- */
   res=deltatau_read(tel,s);
   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
   axe='2';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      rotd_uc=atoi(s);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      if (fabs(dec)>90) {
         retournement=1;
         dec=(tel->latitude)/fabs(tel->latitude)*180-dec;
      }
   }
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      roth_uc=atoi(s);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      ra=ha+360*5;
      if (retournement==1) {
         ra+=180.;
      }
      ra=fmod(ra,360.);
   }
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,tel->interp->result);
   sprintf(s,"mc_angle2dms %f 90 zero 0 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,tel->interp->result);
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int deltatau_positions12(struct telprop *tel,int *p1,int *p2)
/*
* Coordonn�es en ADU
*/
{
   char s[1024],ss[1024],axe;
   int res;
   
   /* --- Vide le buffer --- */
   res=deltatau_read(tel,s);
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      *p1=atoi(s);
   }
   /* --- Lecture AXE 2 (delta) --- */
   axe='2';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      *p2=atoi(s);
   }
   return 0;
}

int deltatau_match(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res;
   
   double ha,lst,sec;
   int h,m;
   /* --- Effectue le pointage RA --- */
   /* H=TSL-alpha => alpha=TSL-H */
   lst=deltatau_tsl(tel,&h,&m,&sec);
   ha=lst-tel->ra0+360*5;
   ha=fmod(ha,360.);
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      tel->roth00=atoi(s);
      tel->ha00=ha;
   }
   /* --- Lecture AXE 2 (delta) --- */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='2';
   sprintf(ss,"#%cp",axe);
   res=deltatau_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=deltatau_read(tel,s);
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=deltatau_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=deltatau_read(tel,s);
   }
   if (res==0) {
      tel->rotd00=atoi(s);
      tel->dec00=ha;
   }
   /* --- --- */
   return 0;
}

int deltatau_goto(struct telprop *tel)
{
   char s[1024],axe;
   int res;
   int retournement=0;
   int p;
   double v;
   double ha,lst,sec;
   int h,m;
   /* --- Effectue le pointage RA --- */
   /* H=TSL-alpha => alpha=TSL-H */
   lst=deltatau_tsl(tel,&h,&m,&sec);
   ha=lst-tel->ra0+360*5;
   ha=fmod(ha,360.);
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
   if (p>tel->stop_w_uc) {
      p=(int)(p-fabs(360*tel->radec_position_conversion));
      if (p<tel->stop_e_uc) {
         /* angle mort */
         retournement=1;
         p=(int)(p+180*fabs(tel->radec_position_conversion));
      }
   }
   if (p<tel->stop_e_uc) {
      p=(int)(p+360*fabs(tel->radec_position_conversion));
      if (p>tel->stop_w_uc) {
         /* angle mort */
         retournement=1;
         p=(int)(p-fabs(180*tel->radec_position_conversion));
      }
   }
   axe='1';
   v=tel->speed_slew_ra*tel->radec_speed_dec_conversion;
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"#%cj=%d",axe,p);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Effectue le pointage DEC --- */
   if (retournement==1) {
      v=(tel->latitude)/fabs(tel->latitude)*180-tel->dec0;
   } else {
      v=tel->dec0;
   }
   p=(int)(tel->rotd00-(v-tel->dec00)*tel->radec_position_conversion);
   axe='2';
   v=tel->speed_slew_ra*tel->radec_speed_dec_conversion; 
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"#%cj=%d",axe,p);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- --- */
   return 0;
}

int deltatau_hadec_goto(struct telprop *tel)
{
   char s[1024],axe;
   int res;
   int retournement=0;
   int p;
   double v;
   double ha;
   /* --- Effectue le pointage RA --- */
   ha=tel->ra0+360*5;
   ha=fmod(ha,360.);
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
   if (p>tel->stop_w_uc) {
      p=(int)(p-fabs(360*tel->radec_position_conversion));
      if (p<tel->stop_e_uc) {
         /* angle mort */
         retournement=1;
         p=(int)(p+180*fabs(tel->radec_position_conversion));
      }
   }
   if (p<tel->stop_e_uc) {
      p=(int)(p+360*fabs(tel->radec_position_conversion));
      if (p>tel->stop_w_uc) {
         /* angle mort */
         retournement=1;
         p=(int)(p-fabs(180*tel->radec_position_conversion));
      }
   }
   axe='1';
   v=tel->speed_slew_ra*tel->radec_speed_dec_conversion;
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"#%cj=%d",axe,p);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Effectue le pointage DEC --- */
   if (retournement==1) {
      v=(tel->latitude)/fabs(tel->latitude)*180-tel->dec0;
   } else {
      v=tel->dec0;
   }
   p=(int)(tel->rotd00-(v-tel->dec00)*tel->radec_position_conversion);
   axe='2';
   v=tel->speed_slew_ra*tel->radec_speed_dec_conversion; 
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"#%cj=%d",axe,p);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- --- */
   return 0;
}

int deltatau_initzenith(struct telprop *tel)
{
   return 0;
}

int deltatau_stopgoto(struct telprop *tel)
{
   char s[1024],axe;
   int res;
   /*--- Arret pointage */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='1';
   sprintf(s,"#%ck",axe);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='2';
   sprintf(s,"#%ck",axe);
   res=deltatau_put(tel,s);
   return 0;
}

int deltatau_stategoto(struct telprop *tel,int *state)
{
   return 0;
}

int deltatau_suivi_arret (struct telprop *tel)
{
   char s[1024],axe;
   int res;
   /*--- Arret pointage */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='1';
   sprintf(s,"#%ck",axe);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='2';
   sprintf(s,"#%ck",axe);
   res=deltatau_put(tel,s);
   return 0;
}

int deltatau_suivi_marche (struct telprop *tel)
{
   /* ==== suivi sid�ral ===*/
   char s[1024],axe;
   int res;
   double v;
   /*--- Track alpha */
   v=tel->speed_track_ra*tel->radec_speed_dec_conversion;
   axe='1';
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   if (tel->speed_track_ra>0) {
      sprintf(s,"#%cj+",axe);
   } else if (tel->speed_track_ra<0) {
      sprintf(s,"#%cj-",axe);
   }
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /*--- Track delta */
   v=tel->speed_track_dec*tel->radec_speed_dec_conversion;
   axe='2';
   sprintf(s,"#%cI%c22=%.12f",axe,axe,v);
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   if (tel->speed_track_dec>0) {
      sprintf(s,"#%cj-",axe);
   } else if (tel->speed_track_ra<0) {
      sprintf(s,"#%cj+",axe);
   }
   res=deltatau_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int deltatau_position_tube(struct telprop *tel,char *sens)
{
   return 0;
}

int deltatau_setderive(struct telprop *tel,int var, int vdec)
{
   return 0;
}

int deltatau_getderive(struct telprop *tel,int *var,int *vdec)
{
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage DELTATAU TOOLS ----------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int deltatau_home(struct telprop *tel, char *home_default)
{
   char s[1024];
   if (strcmp(tel->home0,"")!=0) {
      strcpy(tel->home,tel->home0);
      return 0;
   }
   sprintf(s,"info exists audace(posobs,observateur,gps)");
   mytel_tcleval(tel,s);
   if (strcmp(tel->interp->result,"1")==0) {
      sprintf(s,"set audace(posobs,observateur,gps)");
      mytel_tcleval(tel,s);
      strcpy(tel->home,tel->interp->result);
	} else {
      if (strcmp(home_default,"")!=0) {
         strcpy(tel->home,home_default);
      }
   }
   return 0;
}

double deltatau_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   deltatau_home(tel,"");
   deltatau_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
   sprintf(s,"mc_date2lst %s {%s}",ss,tel->home);
   mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   sprintf(s,"lindex {%s} 0",ss);
   mytel_tcleval(tel,s);
   *h=(int)atoi(tel->interp->result);
   sprintf(s,"lindex {%s} 1",ss);
   mytel_tcleval(tel,s);
   *m=(int)atoi(tel->interp->result);
   sprintf(s,"lindex {%s} 2",ss);
   mytel_tcleval(tel,s);
   *sec=(double)atof(tel->interp->result);
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

void deltatau_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
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
   } else {
      sprintf(ligne,"mc_date2iso8601 now",function);
      Tcl_Eval(interp,ligne);
      strcpy(s,interp->result);
   }
}

