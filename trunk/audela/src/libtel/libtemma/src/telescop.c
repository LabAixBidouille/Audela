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
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <stdio.h>
#include "telescop.h"
#include <libtel/util.h>

void logConsole(struct telprop *tel, char *messageFormat, ...);

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"Temma",    /* telescope name */
    "Temma",    /* protocol name */
    "temma",    /* product */
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
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   int k;
   int i;
   double longitude,latitude,altitude;
   char ligne[256],ew[3];
   
   tel->consoleLog = 0;

   /*
   FILE *f;
   f=fopen("mouchard_temma.txt","wt");
   fclose(f);
   */
   // j'initialise à vide la position de l'observatoire 
   strcpy(tel->homePosition,"");

   // je recupere la position  de l'observatoire 
   for (i=3;i<argc-1;i++) {
      if (strcmp(argv[i],"-home")==0) {
         strncpy(tel->homePosition, argv[i+1],sizeof(tel->homePosition));
      }
      if (strcmp(argv[i],"-consolelog")==0) {
         tel->consoleLog = atoi( argv[i+1]);
      }
   }


   /* --- transcode a port argument into comX or into /dev... */
   strcpy(ss,argv[2]);
   sprintf(s,"string range [string toupper %s] 0 2",ss);
   Tcl_Eval(tel->interp,s);
   strcpy(s,tel->interp->result);
   if (strcmp(s,"COM")==0) {
      sprintf(s,"string range [string toupper %s] 3 end",ss);
      Tcl_Eval(tel->interp,s);
      strcpy(s,tel->interp->result);
      k=(int)atoi(s);
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(s,tel->interp->result);
      if (strcmp(s,"Linux")==0) {
         sprintf(ss,"/dev/ttyS%d",k-1);
         sprintf(ssusb,"/dev/ttyUSB%d",k-1);
      }
   }
   /* --- open the port and record the channel name ---*/
   sprintf(s,"open \"%s\" r+",ss);
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      strcpy(ssres,tel->interp->result);
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(ss,tel->interp->result);
      if (strcmp(ss,"Linux")==0) {
         /* if ttyS not found, we test ttyUSB */
         sprintf(ss,"open \"%s\" r+",ssusb);
         if (Tcl_Eval(tel->interp,ss)!=TCL_OK) {
            strcpy(tel->msg,tel->interp->result);
            return 1;
         }
      } else {
         strcpy(tel->msg,ssres);
         return 1;
      }
   }
   strcpy(tel->channel,tel->interp->result);
   /*
   # 9600 : vitesse de transmission (bauds)
   # 0 : 0 bit de parité
   # 8 : 8 bits de données
   # 1 : 1 bits de stop
   */
   sprintf(s,"fconfigure %s -mode \"19200,e,8,1\" -buffering none -blocking 0",tel->channel); mytel_tcleval(tel,s);
   tel->tempo=250;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   strcpy(tel->v_firmware,"");
   temma_v_firmware(tel);
   tel->ra_play=(double)0.;
   tel->dec_play=(double)0.;
   tel->slewpathindex=0;
   tel->encoder=(int)1;
   temma_LA(tel,50);
   temma_LB(tel,50);
   sate_move_radec=' ';

   if (strcmp(tel->homePosition,"")!= 0) {
      // je calcule la latitude
      sprintf(ligne,"lindex {%s} 1",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      longitude=(double)atof(tel->interp->result);
      sprintf(ligne,"string toupper [lindex {%s} 2]",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      if (strcmp(tel->interp->result,"W")==0) {
         strcpy(ew,"w");
      } else {
         strcpy(ew,"e");
      }
      sprintf(ligne,"lindex {%s} 3",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      latitude=(double)atof(tel->interp->result);
      sprintf(ligne,"lindex {%s} 4",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      altitude=(double)atof(tel->interp->result);

      // send  latitude to mount
      mytel_home_set(tel, longitude, ew, latitude, altitude);

      /* update site for local sideral time */
      temma_settsl(tel);
      tel->tsl00=tel->tsl;
   }

   temma_setderive(tel,0,0);
   /* update E/W for the german mount */
   temma_coord(tel,ssres);
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   char  s[1024];
   char ss[1024];

   //--- interroge "automatic Introduction motion" juste pour savoir si la monture est connectee 
   sprintf(s,"puts -nonewline %s \"s\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);

   //--- Lit la chaine de resultat
   sprintf(s,"gets %s",tel->channel); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);

   // si la chaine est vide, la monture n'est pas connectee
   if (strcmp(ss,"")==0) {
      return 0;
   }

   return 1;

}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   temma_delete(tel);
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
   return temma_match(tel);
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   temma_stategoto(tel,&state);
   if (state==1) {
      strcpy(result,"tracking");
   } else if (state==2) {
      strcpy(result,"pointing");
   } else {
      strcpy(result,"unknown");
   }
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   char coord0[50],coord1[50];
   int time_in=0,time_out=1000;
   double ra00,dec00,dra,ddec;
   int nbgoto=1,old;
   int result;

   if ((tel->ra_play==0.)&&(tel->dec_play==0.)) {
      result = temma_goto(tel);
      if (result == 0) {
         sate_move_radec='A';
         if (tel->radec_goto_blocking==1) {
            /* A loop is actived until the telescope is stopped */
            tel_radec_coord(tel,coord0);
            while (1==1) {
               time_in++;
               sprintf(s,"after 350"); mytel_tcleval(tel,s);
               tel_radec_coord(tel,coord1);
               if (strcmp(coord0,coord1)==0) {break;}
               strcpy(coord0,coord1);
               if (time_in>=time_out) {break;}
            }
            sate_move_radec=' ';
         }
      }
   } else {
      /* --- rattrapage de jeux ---*/
      /* on est obligatoirement en mode bloquant */
      ra00=tel->ra0;
      dec00=tel->dec0;
      temma_coord(tel,coord0);
      /* --- dra<0 si on doit aller vers l'est */
      /* --- dra>0 si on doit aller vers l'ouest */
      sprintf(s,"expr [mc_anglescomp [lindex {%s} 0] + 360]-%f",coord0,tel->ra0); mytel_tcleval(tel,s);
      dra=(double)atof(tel->interp->result);
      if (dra>=360.) { dra=dra-360.; }
      if (dra>=360.) { dra=dra-360.; }
      if (dra>180.) { dra=dra-360.; }
      /* --- ddec<0 si on doit aller vers le nord */
      /* --- ddec>0 si on doit aller vers le sud */
      sprintf(s,"expr [mc_angle2deg [lindex {%s} 1] ]-%f",coord0,tel->dec0); mytel_tcleval(tel,s);
      ddec=(double)atof(tel->interp->result);
      /* --- on considere qu'il y a un jeu a             */
      /*     rattraper lorsque le raliement met          */
      /*     en jeu un mouvement vers l'est (dra<0) et   */
      /*     un mouvement vers le nord (ddec<0)          */
      /* Table des raliements :                                         */
      /*                     dra>0                 dra<0                */
      /* slewpathindex=0 :                       ra0=ra00-tel->ra_play  */
      /*                   ra0=ra00              ra0=ra00               */
      /* slewpathindex=1 : ra0=ra00-tel->ra_play                        */
      /*                   ra0=ra00              ra0=ra00               */
      nbgoto=1;
      if ((dra<0)&&(tel->slewpathindex==0)) {
         tel->ra0=ra00+tel->ra_play;
         sprintf(s,"mc_angle2deg \"[mc_angle2hms %7f 360] h\"",tel->ra0); mytel_tcleval(tel,s);
         tel->ra0=(double)atof(tel->interp->result);
         nbgoto=2;
      }
      if ((dra>0)&&(tel->slewpathindex==1)) {
         tel->ra0=ra00+tel->ra_play;
         sprintf(s,"mc_angle2deg \"[mc_angle2hms %7f 360] h\"",tel->ra0); mytel_tcleval(tel,s);
         tel->ra0=(double)atof(tel->interp->result);
         nbgoto=2;
      }
      if ((ddec<0)&&(tel->slewpathindex==0)) {
         tel->dec0=dec00-tel->dec_play;
         sprintf(s,"mc_angle2deg [mc_angle2dms %7f 90]",tel->dec0); mytel_tcleval(tel,s);
         tel->dec0=(double)atof(tel->interp->result);
         nbgoto=2;
      }
      if ((ddec>0)&&(tel->slewpathindex==1)) {
         tel->dec0=dec00-tel->dec_play;
         sprintf(s,"mc_angle2deg [mc_angle2dms %7f 90]",tel->dec0); mytel_tcleval(tel,s);
         tel->dec0=(double)atof(tel->interp->result);
         nbgoto=2;
      }
      /* --- premier goto ---*/
      result = temma_goto(tel);
      if (result == 0) {
         sate_move_radec='A';
         /* A loop is actived until the telescope is stopped */
         tel_radec_coord(tel,coord0);
         while (1==1) {
            time_in++;
            sprintf(s,"after 350"); mytel_tcleval(tel,s);
            tel_radec_coord(tel,coord1);
            if (strcmp(coord0,coord1)==0) {break;}
            strcpy(coord0,coord1);
            if (time_in>=time_out) {break;}
         }
         sate_move_radec=' ';
         tel->ra0=ra00;
         tel->dec0=dec00;
         /* --- second goto eventuel ---*/
         if (nbgoto==2) {
            old=tel->slewpathindex;
            tel->slewpathindex=0;
            result = temma_goto(tel);
            if (result == 0) {
               tel->slewpathindex=old;
               sate_move_radec='A';
               /* A loop is actived until the telescope is stopped */
               tel_radec_coord(tel,coord0);
               while (1==1) {
                  time_in++;
                  sprintf(s,"after 350"); mytel_tcleval(tel,s);
                  tel_radec_coord(tel,coord1);
                  if (strcmp(coord0,coord1)==0) {break;}
                  strcpy(coord0,coord1);
                  if (time_in>=time_out) {break;}
               }
               sate_move_radec=' ';
            }
         }
      }
   }
   return result;
}

int mytel_radec_move(struct telprop *tel,char *direction)
/*
* There are two type of speeds: Normal (N) and High (H)
* Normal speed can be parametrized by a value between 10 and 90%
*  on each axes (LA99 for RA and LB99 for DEC).
*
* The libtel parameter -rate is related to Temma speeds by the
* following rule :
* -rate >.90  => High speed mode is activated on each axes
* -rate <=.90 => Normal speed mode is activated on each axes
*               with the same parameters for  LA and LB
*
* Command M is following by an ASCII character which is defined
* by its 8-bits significance:
* Bit: Value = 0 Value = 1
*  1 y=1 Low Speed High Speed
*  2 d=2 RA Right
*  4 c=3 RA Left
*  8 b=4 DEC Up
* 16 a=5 DEC Down
* 32   6 Encoder On Encoder Off (here always On)
* 64   7 Always 1
*128   8 Always 0
*
*/
{
   char s[1024],direc[10];
   int p,total,y=0,a=0,b=0,c=0,d=0;
   total=64; /* 010abcdy */
   if (tel->radec_move_rate>0.9) {
      y=1;
   } else if (tel->radec_move_rate<0.1) {
   } else {
      p=(int)(tel->radec_move_rate*100);
      if (p>90) {p=90;}
      if (p<10) {p=10;}
      temma_LA(tel,p);
      temma_LB(tel,p);
   }
   /*tel1 encoder 1|0 */
   /*
   if (tel->encoder==1) {
      total+=32; 
   }
   */
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   if (strcmp(tel->ew,"W")==0) {
      if (strcmp(direc,"N")==0) {
         b=1;
      } else if (strcmp(direc,"S")==0) {
         a=1;
      } else if (strcmp(direc,"E")==0) {
         c=1;
      } else if (strcmp(direc,"W")==0) {
         d=1;
      }
   } else {
      if (strcmp(direc,"N")==0) {
         a=1;
      } else if (strcmp(direc,"S")==0) {
         b=1;
      } else if (strcmp(direc,"E")==0) {
         c=1;
      } else if (strcmp(direc,"W")==0) {
         d=1;
      }
   }
   total+=(16*a+8*b+4*c+2*d+y);
   sprintf(s,"puts -nonewline %s \"M%c\r\n\"",tel->channel,total); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   int total,y=0,a=0,b=0,c=0,d=0;
   char s[1024],direc[10];
   total=64; /* 010abcdy */
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      temma_stopgoto(tel);
      sate_move_radec=' ';
   } else {
      /* on arrete un MOVE */
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,tel->interp->result);
      if (strcmp(tel->ew,"W")==0) {
         if (strcmp(direc,"N")==0) {
            b=0;
         } else if (strcmp(direc,"S")==0) {
            a=0;
         } else if (strcmp(direc,"E")==0) {
            c=0;
         } else if (strcmp(direc,"W")==0) {
            d=0;
         } else {
            a=b=c=d=0;
         }
      } else {
         if (strcmp(direc,"N")==0) {
            a=0;
         } else if (strcmp(direc,"S")==0) {
            b=0;
         } else if (strcmp(direc,"E")==0) {
            c=0;
         } else if (strcmp(direc,"W")==0) {
            d=0;
         } else {
            a=b=c=d=0;
         }
      }
      a=b=c=d=0;
      total+=(16*a+8*b+4*c+2*d+y);
      sprintf(s,"puts -nonewline %s \"M%c\r\n\"",tel->channel,total); mytel_tcleval(tel,s);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      /* --- Lit la reponse sur le port serie */
      sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      temma_suivi_arret(tel);
   } else {
      /* start the motor */
      temma_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   temma_coord(tel,result);
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
   temma_GetCurrentFITSDate_function(tel->interp,ligne,"::audace::date_sys2ut");
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->homePosition);
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
   temma_setlatitude(tel,latitude);
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
   /*
   FILE *f;
   f=fopen("mouchard_temma.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   */
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   /*
   fprintf(f,"RESU <%s>\n",tel->interp->result);
   fclose(f);
   */
   return 0;
}

int temma_delete(struct telprop *tel)
{
   char s[1024];
   /* --- Fermeture du port com */
   sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage TEMMA   -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int temma_setlatitude(struct telprop *tel,double latitude)
{
   char s[1024];
   char slat[256];
   /* --- transforme en latitude en +/-SDDMMZ */
   sprintf(s,"%f",latitude);
   temma_angle_dms2dec(tel,s,slat);
   /* --- */
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "Set latitude=I%s\n", slat);
   }
   sprintf(s,"puts -nonewline %s \"I%s\r\n\"",tel->channel,slat); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 10",tel->channel); mytel_tcleval(tel,s);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "reponse=%s\n", tel->interp->result);
   }
   
   return 0;
}

int temma_getlatitude(struct telprop *tel,double *latitude)
{
   char s[1024];
   char slat[256];
   /* --- */
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "getlatitude=i\n", slat);
   }

   sprintf(s,"puts -nonewline %s \"i\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 10",tel->channel); mytel_tcleval(tel,s);
   // --- transforme iSDDMMZ en latitude en degré
   // exemple : "i+43559" => mc_angle2deg { +43 55.9 }=> +43.93...
   strcpy(slat,tel->interp->result);
   sprintf(s,"mc_angle2deg {%c%c%c %c%c.%c}",slat[1],slat[2],slat[3],slat[4],slat[5],slat[6]); mytel_tcleval(tel,s);
   *latitude=atof(tel->interp->result);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "reponse=%s latitude=%f\n", slat,*latitude);
   }   
   return 0;
}

int temma_gettsl(struct telprop *tel,double *tsl)
{
   char s[1024];
   char slat[256];
   /* --- */
   sprintf(s,"puts -nonewline %s \"g\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 10",tel->channel); mytel_tcleval(tel,s);
   /* --- transforme HHMMSS en tsl */
   strcpy(slat,tel->interp->result);
   sprintf(s,"mc_angle2deg \"%c%ch%c%cm%c%cs\"",slat[1],slat[2],slat[3],slat[4],slat[5],slat[6]); mytel_tcleval(tel,s);
   *tsl=atof(tel->interp->result);
   return 0;
}

// Retourne l'etat des moteurs
// 1  : Si les moteurs fonctionnent
// 0  : Si les moteurs sont hors tension
// -1 : Si Temma n'est pas connecte
int temma_motorstate(struct telprop *tel)
{
   char s[1024];
   int result;
   /* --- */
   sprintf(s,"puts -nonewline %s \"STN-COD\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "StateMotor=|%s|\n",s);
   }
   if ( strcmp(s,"stn-off\n") == 0 ) {
      result = 1;
   } else if ( strcmp(s,"stn-on\n") == 0 ) {
      result = 0;
   } else {
      result = -1;
   }
   return result;
}
int temma_LA (struct telprop *tel, int value)
{
   char s[1024];
   /* --- ajuste la vitesse RA-move en speed Normal */
   if (value<10) {value=10;}
   if (value>90) {value=90;}
   sprintf(s,"puts -nonewline %s \"LA%02d\r\n\"",tel->channel,value); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

int temma_LB (struct telprop *tel, int value)
{
   char s[1024];
   /* --- ajuste la vitesse DEC-move en speed Normal */
   if (value<10) {value=10;}
   if (value>90) {value=90;}
   sprintf(s,"puts -nonewline %s \"LB%02d\r\n\"",tel->channel,value); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

int temma_lg (struct telprop *tel, int *vra, int *vdec)
{
   char s[1024];
   char ss[256];
   /* --- lit les vitesses RA-move DEC-move en speed Normal */
   sprintf(s,"puts -nonewline %s \"lg\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   /* decode le retour */
   strcpy(s,tel->interp->result);
   *vra=0;
   *vdec=0;
   if (strcmp(s,"")!=0) {
      sprintf(ss,"%c%c",s[2],s[3]);
      *vra=(int)atoi(ss);
      sprintf(ss,"%c%c",s[5],s[6]);
      *vdec=(int)atoi(ss);
   }
   return 0;
}

int temma_v_firmware (struct telprop *tel)
{
   char s[1024];
   /* --- Retourne la version du firmware du microcontroleur */
   /* --- Demande le numero de la version */
   sprintf(s,"puts -nonewline %s \"v\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la version sur le port serie */
   sprintf(s,"read %s 35",tel->channel); mytel_tcleval(tel,s);
   strcpy(tel->v_firmware,tel->interp->result);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int temma_arret_pointage(struct telprop *tel)
{
   char s[1024];
   /*--- Arret pointage */
   sprintf(s,"puts -nonewline %s \"PS\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int temma_coord(struct telprop *tel,char *result)
/*
Reply structure:
0          1
12345678  901234    5
E999999+/-99999E/W/FH
H = Handbox (operational?)
E/W = Side of mount telescope is on
F = Automatic introduction complete after goto operation retour F F F
*/
{
   char s[1024],ss[1024];
   char sra[256],sdec[256];
   int k,kdeb,kfin;
   /*double ra=0.,dec=0.;*/
   /* --- Demande radec */
   sprintf(s,"puts -nonewline %s \"E\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   /* --- transforme RA en HHhMMmSSs */
   kdeb=1;
   kfin=6;
   for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
   ss[k-kdeb]='\0';
   temma_angle_ra2hms(ss,sra);
   /* --- transforme DEC en SDDdMMmSSs */
   kdeb=7;
   kfin=12;
   for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
   ss[k-kdeb]='\0';
   temma_angle_dec2dms(ss,sdec);
   /*sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);*/
   /* -- decoder ici le sens E/W */
   /* --- transforme DEC en SDDdMMmSSs */
   if (s[13]=='E') {
      strcpy(tel->ew,"E");
   } else if (s[13]=='W') {
      strcpy(tel->ew,"W");
   } /* sinon c'est F et on ne modifie rien */
   kdeb=7;
   kfin=12;
   for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
   ss[k-kdeb]='\0';

   if (tel->encoder==0) {
      /* --- update local sideral time */
      temma_settsl(tel);
      sprintf(s,"mc_angle2hms [mc_anglescomp %s + [expr %f - %f]] 360 zero 0 auto string",sra,tel->tsl00,tel->tsl); mytel_tcleval(tel,s);
      strcpy(sra,tel->interp->result);
   }
   sprintf(result,"%s %s",sra,sdec);
   return 0;
}

int temma_match(struct telprop *tel)
{
   char s[1024];
   char sra[256];
   char sdec[256];
   int result=0,len;
   /* --- transforme en tel->ra0 en HHMMZZ */
   sprintf(s,"%f",tel->ra0);
   temma_angle_hms2ra(tel,s,sra);
   /* --- transforme en tel->dec0 en +/-SDDMMZ */
   sprintf(s,"%f",tel->dec0);
   temma_angle_dms2dec(tel,s,sdec);
   /* --- update local sideral time */
   temma_settsl(tel);
   /* --- set Zenith (bug of temma for resync) ---*/
   sprintf(s,"puts -nonewline %s \"Z\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- update local sideral time */
   temma_settsl(tel);
   tel->tsl00=tel->tsl;
   /* --- update radec */
   sprintf(s,"puts -nonewline %s \"D%s%s\r\n\"",tel->channel,sra,sdec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "Error Code Match=|%s|\n",s);
   }
   len=(int)strlen(s);
   if (len>=2) {
      if (strncmp(s,"R0",2)==0) {
         // OK
         result=0;
      } else if (strncmp(s,"R1",2)==0) {
         // error synchro RA
         strcpy(tel->msg, "Error Synchro RA");
         result=1;
      } else if (strncmp(s,"R2",2)==0) {
         // error synchro DEC
         strcpy(tel->msg, "Error Synchro DEC");
         result=2;
      } else if (strncmp(s,"R3",2)==0) {
         // error too many digits
         result=3;
         strcpy(tel->msg, "Error too many Digits");
      } else if (strncmp(s,"R4",2)==0) {
         // error object under horizon
         result=4;
         strcpy(tel->msg, "Object below Horizon");
      }
   }
   if (tel->encoder==0) {
      tel->ha00=tel->ra0;
   }
   return result;
}

int temma_goto(struct telprop *tel)
{
   char s[1024];
   char sra[256];
   char sdec[256];
   int result;
   int len;
   /* --- transforme en tel->ra0 en HHMMZZ */
   sprintf(s,"%f",tel->ra0);
   temma_angle_hms2ra(tel,s,sra);
   /* --- transforme en tel->dec0 en +/-SDDMMZ */
   sprintf(s,"%f",tel->dec0);
   temma_angle_dms2dec(tel,s,sdec);
   /* --- envoie la mise a jour de radec */
   temma_settsl(tel);
   sprintf(s,"puts -nonewline %s \"P%s%s\r\n\"",tel->channel,sra,sdec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "Error Code Goto=|%s|\n",s);
   }
   len=(int)strlen(s);
   if (len>=2) {
      if (strncmp(s,"R0",2)==0) {
         // OK
         result=0;
      } else if (strncmp(s,"R1",2)==0) {
         // error synchro RA
         strcpy(tel->msg, "Error GOTO RA");
         result=1;
      } else if (strncmp(s,"R2",2)==0) {
         // error synchro DEC
         strcpy(tel->msg, "Error GOTO DEC");
         result=2;
      } else if (strncmp(s,"R3",2)==0) {
         // error too many digits
         result=3;
         strcpy(tel->msg, "Error too many Digits");
      } else if (strncmp(s,"R4",2)==0) {
         // error object under horizon
         result=4;
         strcpy(tel->msg, "Object below Horizon");
      } else if (strncmp(s,"R5",2)==0) {
         // sate standby ON
         result=5;
         strcpy(tel->msg, "State Standby ON");
      }
   }
   return result;
}

int temma_initzenith(struct telprop *tel)
{
   char s[1024];
   /* --- update local sideral time */
   temma_settsl(tel);
   /* ---  */
   sprintf(s,"puts -nonewline %s \"Z\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   return 0;
}

int temma_stopgoto(struct telprop *tel)
{
   char s[1024];
   /* ---  */
   sprintf(s,"puts -nonewline %s \"PS\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   return 0;
}

int temma_stategoto(struct telprop *tel,int *state)
{
   char s[1024];
   int result=0,len;
   // ---
   sprintf(s,"puts -nonewline %s \"s\r\n\"",tel->channel); mytel_tcleval(tel,s);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "State=s\n");
   }
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   // --- Lit la reponse sur le port serie
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "State result=|%s|\n", s);
   }
   len=(int)strlen(s);
   if (len>=2) {
      if (strncmp(s,"s0",2)==0) {
         // tracking
         result=1;
      } else if (strncmp(s,"s1",2)==0) {
         // pointing
         result=2;
      }
   }
   *state=result;
   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "Result=|%d|\n", result);
   }
   return result;
}

int temma_suivi_arret (struct telprop *tel)
{
   char s[1024];
   /* --- */
   sprintf(s,"puts -nonewline %s \"STN-ON\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   return 0;
}

int temma_suivi_marche (struct telprop *tel)
{
   char s[1024];
   /* ---  */
   sprintf(s,"puts -nonewline %s \"STN-OFF\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   return 0;
}

int temma_position_tube(struct telprop *tel,char *sens)
{
   char s[1024],ss[50];
   /* --- met a jour tel->ew */
   temma_coord(tel,s);
   /* --- */
   sprintf(s,"lindex [string toupper %s] 0",sens); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   if (ss[0]=='E') { strcpy(ss,"E"); }
   else { strcpy(ss,"W"); }
   if (strcmp(tel->ew,ss)!=0) {
      /*--- switch position W|E du tube */
      sprintf(s,"puts -nonewline %s \"PT\r\n\"",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      /* --- Lit la reponse sur le port serie */
      /*
      sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
      strcpy(s,tel->interp->result);
      */
   }
   return 0;
}

int temma_setderive(struct telprop *tel,int var, int vdec)
{
   char s[1024];
   /*--- Derive du suivi en ar et en dec*/
   if (var<-99999) {var=-99999;}
   if (var>99999) {var=99999;}
   if (vdec<-9999) {vdec=-9999;}
   if (vdec>9999) {vdec=9999;}
   sprintf(s,"puts -nonewline %s \"LM%+d,%+d\r\n\"",tel->channel,var,vdec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   return 0;
}

int temma_getderive(struct telprop *tel,int *var,int *vdec)
/*
* Get Comet Speed
lm Note: This is a lower case "L"
Reply Structure:
0          1
12345  6789012  3456
lmLM+/-99999,+/-9999
RA Speed Adjustment,Dec Speed Adjustment

Note: RA Speed adjustment is how many RA seconds are added/subtracted per 24 hour period,
DEC adjustment is how many Minutes per 24 hour period.

*/
{
   char s[1024],ss[1024];
   int k,kdeb,kfin;
   int len,kf1,kd1,kf2,kd2;
   /* --- Demande radec */
   sprintf(s,"puts -nonewline %s \"lm\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   /* --- */
   len=(int)strlen(s);
   if (len<5) {
      *var=0;
      *vdec=0;
   } else {
      kd1=4;
      kf1=kd1;
      kd2=kd1;
      kf2=kd1;
      for (k=kd1;k<len;k++) {
         if (s[k]==',') {
            kf1=k-1;
            kd2=k+1;
            kf2=len;
            break;
         }
      }
      /* --- extrait dRA en sec/day */
      kdeb=kd1;
      kfin=kf1;
      for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
      ss[k-kdeb]='\0';
      *var=atoi(ss);
      /* --- extrait dDEC en arcmin/day */
      kdeb=kd2;
      kfin=kf2;
      for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
      ss[k-kdeb]='\0';
      *vdec=atoi(ss);
   }
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage TEMMA TOOLS -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int temma_settsl(struct telprop *tel)
{
   int h,m,sec;
   char s[1024];
   tel->tsl=temma_tsl(tel,&h,&m,&sec);
   sprintf(s,"puts -nonewline %s \"T%02d%02d%02d\r\n\"",tel->channel,h,m,sec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   /*
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   */
   return 0;
}

double temma_tsl(struct telprop *tel,int *h, int *m,int *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   temma_GetCurrentFITSDate_function(tel->interp,ss,"::audace::date_sys2ut");
   sprintf(s,"mc_date2lst %s {%s}",ss,tel->homePosition);
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
   *sec=(int)atoi(tel->interp->result);
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

void temma_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function)
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

int temma_angle_ra2hms(char *in, char *out)
{
   char ss[1024];
   int z;
   if ((int)strlen(in)<6) {
      strcpy(in,"000000");
   }
   sprintf(ss,"%c%c",in[4],in[5]);
   z=(int)floor(atof(ss)/100.*60.);
   sprintf(ss,"%02d",z);
   sprintf(out,"%c%ch%c%cm%c%cs",in[0],in[1],in[2],in[3],ss[0],ss[1]);
   return 0;
}

int temma_angle_dec2dms(char *in, char *out)
{
   char ss[1024];
   int z;
   if ((int)strlen(in)<6) {
      strcpy(in,"+00000");
   }
   sprintf(ss,"%c",in[5]);
   z=(int)floor(atof(ss)*6.);
   sprintf(ss,"%02d",z);
   /* --- transforme +SDDMMZ en +DDdMMmSSs */
   sprintf(out,"%c%c%cd%c%cm%c%cs",in[0],in[1],in[2],in[3],in[4],ss[0],ss[1]);
   return 0;
}

int temma_angle_hms2ra(struct telprop *tel, char *in, char *out)
{
   char s[1024],ss[1024];
   int z;
   /* --- transforme Angle en HHhMMmSSs0 */
   sprintf(s,"mc_angle2hms %s 360 zero 0 auto string",in); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   /* --- transforme HHhMMmSSs0 en HHMMZZ ou ZZ sont min/100 */
   sprintf(ss,"%c%c",s[6],s[7]);
   z=(int)floor(atof(ss)/60.*100.);
   sprintf(ss,"%02d",z);
   sprintf(out,"%c%c%c%c%c%c",s[0],s[1],s[3],s[4],ss[0],ss[1]);
   return 0;
}

int temma_angle_dms2dec(struct telprop *tel, char *in, char *out)
{
   char s[1024],ss[1024];
   int z;
   /* --- transforme Angle en +DDdMMmSSs0 */
   sprintf(s,"mc_angle2dms %s 90 zero 0 + string",in); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   /* --- transforme +DDdMMmSSs0 en +DDMMZ ou Z sont arcmin/10 */
   sprintf(ss,"%c%c",s[7],s[8]);
   z=(int)floor(atof(ss)/60.*10.);
   sprintf(ss,"%01d",z);
   if (s[0]=='-') {
      sprintf(out,"-%c%c%c%c%c",s[1],s[2],s[4],s[5],ss[0]);
   } else {
      sprintf(out,"+%c%c%c%c%c",s[1],s[2],s[4],s[5],ss[0]);
   }
   return 0;
}

