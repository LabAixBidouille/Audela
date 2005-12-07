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

 
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"compad",    /* telescope name */
    "compad",    /* protocol name */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
	1.        /* default focal lenght of optic system */
   },
};


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
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary}",tel->channel); mytel_tcleval(tel,s);
   */
   sprintf(s,"string toupper %s",argv[2]);
   Tcl_Eval(tel->interp,s);
   strcpy(s,tel->interp->result);
   tel->comadress=0x03F8;
   if (strcmp(s,"COM1")==0) {
      tel->comadress=0x03F8;
   } 
   if (strcmp(s,"COM2")==0) {
      tel->comadress=0x02F8;
   }
   Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
   strcpy(s,tel->interp->result);
   if (strcmp(s,"Windows NT")==0) {
      tel->interrupt=0;
   }
   InitCom(tel);
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
   char s[1024];
   sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   strcpy(result,"unknown");
   return mytel_radec_state(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
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
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   return 0;
}

int mytel_radec_state(struct telprop *tel)
{
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   int res=0;
   if (tel->authorized==1) {
      res=mytel_radec_init(tel);
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,tel->interp->result);
      if (strcmp(direc,"N")==0) {
         /* ComPad protocol has 2 motion rates */
         if ((tel->radec_move_rate<=0.5)) {
            /* Slow */
            DecPlus(tel);
         } else {
            /* Fast */
            DecPlusFast(tel);
         }
      } else if (strcmp(direc,"S")==0) {
         if ((tel->radec_move_rate<=0.5)) {
            /* Slow */
            DecMoins(tel);
         } else {
            /* Fast */
            DecMoinsFast(tel);
         }
      } else if (strcmp(direc,"E")==0) {
         if ((tel->radec_move_rate<=0.5)) {
            /* Slow */
            AdMoins(tel);
         } else {
            /* Fast */
            AdMoinsFast(tel);
         }
      } else if (strcmp(direc,"W")==0) {
         if ((tel->radec_move_rate<=0.5)) {
            /* Slow */
            AdPlus(tel);
         } else {
            /* Fast */
            AdPlusFast(tel);
         }
      }
   }
   return res;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   if (tel->authorized==1) {
      RazComFast(tel);
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   strcpy(result,"00h00m00s +00d00m00s");
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
   char s[1024],direc[10];
   if (tel->authorized==1) {
      /* Compad protocol has 2 motion rates */
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,tel->interp->result);
      if (strcmp(direc,"+")==0) {
         if (tel->focus_move_rate<=0.5) {
            /* Slow */
	        FocusPlus(tel);
         } else {
            /* Fast */
	        FocusPlusFast(tel);
         }
      } else if (strcmp(direc,"-")==0) {
         if (tel->focus_move_rate<=0.5) {
            /* Slow */
	        FocusMoins(tel);
         } else {
            /* Fast */
	        FocusMoinsFast(tel);
         }
      }
   }
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   if (tel->authorized==1) {
      RazComFast(tel);
   }
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   strcpy(result,"0");
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,"2000 01 01 0 0 0");
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   char signe[3],ew[3];
   double longitude,latitude;
   longitude=0.;
   latitude=0.;
   strcpy(ew,"E");
   strcpy(signe,"+");
   /* Returns the result */
   sprintf(ligne,"GPS %f %s %s%f 0",longitude,ew,signe,latitude);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
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
   f=fopen("mouchard.txt","at");
   fprintf(f,"%s\n",ligne);
   fclose(f);
   */
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   return 0;
}

void writebit0(struct telprop *tel,int valeur)
/* DRT = broche 4 (bit0 du registre 4) */
{
   unsigned short a;
   unsigned char d;
   if (tel->interrupt==0) { return; }
   a=(unsigned short)(tel->comadress+4);
   if (valeur==0) {
	  d=libtel_in(a)&0x00FE;
      libtel_out(a,d);
      libtel_out(a,d);
      libtel_out(a,d);
   } else {
	  d=libtel_in(a)|0x0001;
      libtel_out(a,d);
      libtel_out(a,d);
      libtel_out(a,d);
   }
}

void writebit1(struct telprop *tel,int valeur)
/* RTS = broche 7 (bit1 du registre 4) */
{
   unsigned short a;
   unsigned char d;
   if (tel->interrupt==0) { return; }
   a=(unsigned short)(tel->comadress+4);
   if (valeur==0) {
	  d=libtel_in(a)&0x00FD;
      libtel_out(a,d);
      libtel_out(a,d);
      libtel_out(a,d);
   } else {
	  d=libtel_in(a)|0x0002;
      libtel_out(a,d);
      libtel_out(a,d);
      libtel_out(a,d);
   }
}

void writebit2(struct telprop *tel,int valeur)
/* TxD = broche 3 (bit6 du registre 3) */
{
   unsigned short a;
   unsigned char d;
   if (tel->interrupt==0) { return; }
   a=(unsigned short)(tel->comadress+3);
   if (valeur==0) {
	  d=libtel_in(a)&191;
      libtel_out(a,d);
      libtel_out(a,d);
      libtel_out(a,d);
   } else {
	  d=libtel_in(a)|64;
      libtel_out(a,d);
      libtel_out(a,d);
      libtel_out(a,d);
   }
}

void InitCom(struct telprop *tel)
/* Impulsion  sur le bit 3 registre 4 */
{
   unsigned short a;
   int i;
   if (tel->interrupt==0) { return; }
   a=(unsigned short)(tel->comadress+4);
   libtel_out(a,0);
   libtel_out(a,0);
   libtel_out(a,0);
   libtel_out(a,8);
   libtel_out(a,8);
   libtel_out(a,8);
   libtel_out(a,0);
   libtel_out(a,0);
   libtel_out(a,0);
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   writebit2(tel,1);
}

void RazCom(struct telprop *tel)
/* Met a zero tous les bits du registre a decalage */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   writebit2(tel,1);
}

void RazComFast(struct telprop *tel)
/* Met a zero tous les bits du registre a decalage */
/* sauf le bit 4 (vitesse lente ou rapide) */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit2(tel,1);
}

void AdPlus(struct telprop *tel)
/* RA+ */
/* 0000 0001 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void AdMoins(struct telprop *tel)
/* RA- */
/* 0000 0010 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit2(tel,1);
}

void DecPlus(struct telprop *tel)
/* DEC+ */
/* 0000 0100 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit2(tel,1);
}

void DecMoins(struct telprop *tel)
/* DEC- */
/* 0000 1000 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit2(tel,1);
}

void AdPlusFast(struct telprop *tel)
/* RA++ */
/* 0001 0001 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void AdMoinsFast(struct telprop *tel)
/* RA-- */
/* 0001 0010 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void DecPlusFast(struct telprop *tel)
/* DEC++ */
/* 0001 0100 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void DecMoinsFast(struct telprop *tel)
/* DEC-- */
/* 0001 1000 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void FocusPlus(struct telprop *tel)
/* F+ */
/* 0010 0000 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void FocusMoins(struct telprop *tel)
/* F- */
/* 0100 0000 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void FocusPlusFast(struct telprop *tel)
/* F++ */
/* 0011 0000 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}

void FocusMoinsFast(struct telprop *tel)
/* F-- */
/* 0101 0000 */
{
   int i;
   writebit2(tel,0);
   for (i=0;i<8;i++) {
      writebit0(tel,0);
      writebit1(tel,0);
      writebit1(tel,1);
   }
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,1); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);

   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit0(tel,0); /* pousse d'un cran */
   writebit1(tel,1);
   writebit1(tel,0);
   
   writebit2(tel,1);
}
