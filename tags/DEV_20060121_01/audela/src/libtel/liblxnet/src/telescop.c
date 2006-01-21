/* telescop.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

/*
 * telescop.c
 * 
 * Ceci est le fichier contenant le driver de la camera
 *
 * La structure "telprop" peut etre adaptee
 * dans le fichier telescop.h
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2005/02/12 22:04:53  Administrateur
 * *** empty log message ***
 *
 * Revision 1.11  2003-07-02 22:34:11+02  michel
 * <>
 *
 * Revision 1.10  2003-06-20 09:28:11+02  michel
 * remplace :GR# par :GD# dans la simulation de mytel_sendLX()
 *
 * Revision 1.9  2003-06-07 10:38:13+02  michel
 * ajoute setip
 *
 * Revision 1.8  2003-05-21 21:54:10+02  michel
 * ajout SIMUL_AUDINET
 * ajout test tel->radec_goto_blocking dans mytel_radec_goto()
 *
 * Revision 1.7  2003-04-25 13:44:07+02  michel
 * ajouter AutoFlush
 * ajouter appeler socktcp_close() dans sendLX
 *
 * Revision 1.6  2003-03-04 14:03:41+01  michel
 * <>
 *
 * Revision 1.4  2002-09-30 19:33:53+02  michel
 * supprime # au d�but des commandes LX200
 * ajoute mytel_flush()
 *
 * Revision 1.3  2002-09-27 19:19:06+02  michel
 * ajout dans tel_init() : lecture paramete host , test ping , appel  my_tel_flush()
 * ajout tel_radec_state() et mytel_radec_state()
 * ajout appel mytel_flush()  dans mytel_radec_goto(), mytel_date_get(), mytel_date_set(), mytel_home_get(), mytel_home_set()
 * ajout mytel_flush(struct telprop *tel)
 * modif mytel_sendLX : appel de socktcp_send()
 *
 * Revision 1.2  2002-08-22 22:23:21+02  michel
 * ajout cgi-bin
 * ajout retour HTTP standard
 *
 * Revision 1.1  2002-07-28 16:01:18+02  michel
 * supprime l'adresse ip en dur dans tel_init()
 *
 * Revision 1.0  2002-06-28 23:24:57+02  michel
 * initial revision
 *
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

#include <libtel/util.h>
#include "telescop.h"

#include "socketaudinet.h"
#include "log.h"
#include "setip.h"

// pour tests sans brancher l'interface audinet
//#define SIMUL_AUDINET

/* LX200 command type */
#define RETURN_NOTHING	(0)
#define RETURN_OK       (1)
#define RETURN_SHARP    (2)
#define FLUSH           (3)

#ifndef FALSE
#define FALSE           (0)
#endif

#ifndef TRUE
#define TRUE            (1)
#endif
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */
#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0

struct telini tel_ini[] = {
   {"LXNET",    /* telescope name */
    "Lxnet",    /* protocol name */
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
/* --- si OK retourne 0 , sinon retourne -1              --- */
/* --------------------------------------------------------- */
{
   int i;
   int cr = 0;
   char macAddress[18];
   int  ipsetting = 0;    // pour re-inialiser l'adresse IP
   char errorMessage[256];

   //initLog();
   
   tel->tempo=300;  /* en millisecondes */
   tel->httpPort =80;   
   tel->autoflush = FALSE;
	 
         
   for (i=3;i<argc-1;i++) {
	   if (strcmp(argv[i],"-host")==0) {
			   strcpy(tel->host, argv[i+1]);         
		 } 
 	   if (strcmp(argv[i],"-autoflush")==0) {
         if( atoi(argv[i+1]) == 1 ) {
            tel->autoflush= TRUE;
         }
         else {
            tel->autoflush= FALSE;
         }
		 } 

       if (strcmp(argv[i],"-ipsetting")==0) {
         if ((i+1)<=(argc-1)) {
            if( strcmp(argv[i+1], "1")==0) {
               ipsetting= 1;
            } else {
               ipsetting= 0;
            }
         }
         
      }           
      
      if (strcmp(argv[i],"-macaddress")==0) {
         if ((i+1)<=(argc-1)) {
            STRNCPY(macAddress,argv[i+1]);
         }
      }           
     
   }

#ifndef SIMUL_AUDINET
   if( ipsetting == 1) {
      // envoie l'adresse IP a Audinet
      setip(tel->host, macAddress, 0,0, errorMessage);
   }
	// test de la connexion ethernet : essai 3 ping avec timout = 1000 ms 
  if( ping(tel->host, 3, 1000) == TRUE ) {
     //mytel_flush(tel);
     cr = 0;
  }
  else {
     cr = -1;
  }
  return cr;
#else
  return 0;
#endif
  
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   if (mytel_get_format(tel)==1) {
      return 1;
   } else {
      return 0;
   }
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   socktcp_close();
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
   char s[1024];
   char coord0[50],coord1[50];
   tel_radec_coord(tel,coord0);
   sprintf(s,"after 350"); mytel_tcleval(tel,s);
   tel_radec_coord(tel,coord1);
   if (strcmp(coord0,coord1)==0) {strcpy(result,"tracking");}
   else {strcpy(result,"pointing");}
   return 0;
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
   char s[1024],ls[100];
   int nbcar_1,nbcar_2;
   /* get the short|long format */
   mytel_get_format(tel);
   if (tel->longformatindex==0) { 
      strcpy(ls,"-format long"); 
      nbcar_1=9;
      nbcar_2=10;
   } else { 
      strcpy(ls,"-format short"); 
      nbcar_1=8;
      nbcar_2=7;
   } 

   /* Send Sr */
   sprintf(s,"mc_angle2lx200ra %f %s",tel->ra0,ls); mytel_tcleval(tel,s);
   sprintf(s,":Sr %s#",tel->interp->result); 
   if( mytel_sendLX(tel, s , RETURN_OK, ls) <=0 ) {
		/* Receive 1 if it is OK */
		return -1;
   }

   /* Send Sd */
   sprintf(s,"mc_angle2lx200dec %f %s",tel->dec0,ls); mytel_tcleval(tel,s);
   sprintf(s,":Sd %s#",tel->interp->result);
   if( mytel_sendLX(tel, s ,  RETURN_OK, ls) <=0 ) {
		return -1;
   }
	
   sprintf(s,":CM#");
   if( mytel_sendLX(tel, s , RETURN_OK, ls) <=0 ) {
		return -1;
   }
	return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   char s[1024];
   char coord0[50],coord1[50];
   tel_radec_coord(tel,coord0);
   sprintf(s,"after 350"); mytel_tcleval(tel,s);
   tel_radec_coord(tel,coord1);
   if (strcmp(coord0,coord1)==0) {strcpy(result,"tracking");}
   else {strcpy(result,"pointing");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024],ls[100];
   char coord0[50],coord1[50];
   int nbcar_1,nbcar_2,time_in=0,time_out=240;
   /* get the short|long format */
   mytel_get_format(tel);
   if (tel->longformatindex==0) { 
      strcpy(ls,"-format long"); 
      nbcar_1=9;
      nbcar_2=10;
   } else { 
      strcpy(ls,"-format short"); 
      nbcar_1=8;
      nbcar_2=7;
   } 
   

	/* Send Sr */
   sprintf(s,"mc_angle2lx200ra %f %s",tel->ra0,ls); mytel_tcleval(tel,s);
   sprintf(s,":Sr %s#",tel->interp->result); 
   if( mytel_sendLX(tel, s , RETURN_OK, ls) <=0 ) {
      mytel_flush(tel);
	  	return -1;
   }
      
	/* Send Sd */
   sprintf(s,"mc_angle2lx200dec %f %s",tel->dec0,ls); mytel_tcleval(tel,s);
   sprintf(s,":Sd %s#",tel->interp->result); 
   if( mytel_sendLX(tel, s , RETURN_OK, ls) <=0 ) {
      mytel_flush(tel);
      return -1;
   }
   
	/* Send MS */
   if( mytel_sendLX(tel, ":MS#", RETURN_OK, ls) <=0 ) {
      logError("mytel_radec_goto response=%s  goto Error", ls);
      /* The telescope can not complete the slew and tells something*/
      mytel_flush(tel);
   	return -1;
   }
	else {
		switch (ls[0]) {
		case '0' :   
			/* slew OK */
		   //logInfo("mytel_radec_goto response=%s  goto OK", ls);
			break;
		case '1' :   
			/* slew aborted, object is below the horizon or near the Sun */
      logError("mytel_radec_goto response=%s  object is below the horizon or near the Sun", ls);
      mytel_flush(tel);
			return 0;
			break;
		case '2' :   
			/* slew aborted, object is below the 'higher' limit */
		  logError("mytel_radec_goto response=%s  object is below the horizon", ls);
			mytel_flush(tel);
			return 0;
			break;
		default : 
		  logError("mytel_radec_goto response=%s ", ls);
		  mytel_flush(tel);
			return 0;
		}
	}
   
   //logInfo( " mytel_radec_goto radec_goto_blocking=%d",tel->radec_goto_blocking); 
   if (tel->radec_goto_blocking==1) {
      //logInfo( " mytel_radec_goto radec_goto_blocking=%d blocking",tel->radec_goto_blocking); 
      // A loop is actived until the telescope is stopped 
      tel_radec_coord(tel,coord0);
      while (1) {
	      time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         tel_radec_coord(tel,coord1);
         if (strcmp(coord0,coord1)==0) {break;}
         strcpy(coord0,coord1);
	      if (time_in>=time_out) {break;}
      }
   }


   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],ls[1024],direc[10];
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   /* LX200 protocol has 4 motion rates */
   if ((tel->radec_move_rate<=0.25)) {
      /* Guide */
		mytel_sendLX(tel, ":RG#" , RETURN_NOTHING, ls);
   } else if ((tel->radec_move_rate>0.25)&&(tel->radec_move_rate<=0.5)) {
      /* Center */
		mytel_sendLX(tel, ":RC#" , RETURN_NOTHING, ls);
   } else if ((tel->radec_move_rate>0.5)&&(tel->radec_move_rate<=0.75)) {
      /* Find */
		mytel_sendLX(tel, ":RM#" , RETURN_NOTHING, ls);
   } else if ((tel->radec_move_rate>0.75)) {
      /* Slew */
		mytel_sendLX(tel, ":RS#" , RETURN_NOTHING, ls);
   }

   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   if (strcmp(direc,"N")==0) {
      mytel_sendLX(tel, ":Mn#" , RETURN_NOTHING, ls);
   } else if (strcmp(direc,"S")==0) {
      mytel_sendLX(tel, ":Ms#" , RETURN_NOTHING, ls);
   } else if (strcmp(direc,"E")==0) {
      mytel_sendLX(tel, ":Me#" , RETURN_NOTHING, ls);
   } else if (strcmp(direc,"W")==0) {
      mytel_sendLX(tel, ":Mw#" , RETURN_NOTHING, ls);
   }
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],ls[1024],direc[10];
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);

   if (strcmp(direc,"N")==0) {
      mytel_sendLX(tel, ":Qn#" , RETURN_NOTHING, ls);
   } else if (strcmp(direc,"S")==0) {
      mytel_sendLX(tel, ":Qs#" , RETURN_NOTHING, ls);
   } else if (strcmp(direc,"E")==0) {
      mytel_sendLX(tel, ":Qe#" , RETURN_NOTHING, ls);
   } else if (strcmp(direc,"W")==0) {
      mytel_sendLX(tel, ":Qw#" , RETURN_NOTHING, ls);
   } else {
      mytel_sendLX(tel, ":Q#" , RETURN_NOTHING, ls);
      mytel_sendLX(tel, ":Qn#" , RETURN_NOTHING, ls);
      mytel_sendLX(tel, ":Qs#" , RETURN_NOTHING, ls);
      mytel_sendLX(tel, ":Qe#" , RETURN_NOTHING, ls);
      mytel_sendLX(tel, ":Qw#" , RETURN_NOTHING, ls);
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char result[1024];
   if (tel->radec_motor==1) {
      /* stop the motor */
      mytel_sendLX(tel, ":AL#" , RETURN_NOTHING, result);
   } else {
      /* start the motor */
      mytel_sendLX(tel, ":AP#" , RETURN_NOTHING, result);
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[1024],ss[1024],signe[2];
   int h,d,m,sec;
   
	strcpy(result,"");
   
	/* Send GR */
   mytel_sendLX(tel, ":GR#" , RETURN_SHARP, ss);
   
	/* Receive a string terminated by # */
   
	/*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   sprintf(s,"string range \"%s\" 0 1",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   h=atoi(s);
   sprintf(s,"string range \"%s\" 3 4",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   m=atoi(s);
   if (tel->longformatindex==0) { 
      sprintf(s,"string range \"%s\" 6 7",ss); mytel_tcleval(tel,s);
      strcpy(s,tel->interp->result);
      sec=atoi(s);
      sprintf(s,"%02dh%02dm%02ds",h,m,sec);
   } else {
      sprintf(s,"string range \"%s\" 6 6",ss); mytel_tcleval(tel,s);
      strcpy(s,tel->interp->result);
      sec=atoi(s);
      /*sprintf(s,"%02ldh%02ld.%01ldm",h,m,sec);*/
      sprintf(s,"%02dh%02dm%02ds",h,m,sec*6);
   }
   sprintf(result,"%s ",s);
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/

   /* Send GD */
   mytel_sendLX(tel, ":GD#" , RETURN_SHARP, ss);
   
	/* Receive a string terminated by # */
   sprintf(s,"string range \"%s\" 0 0",ss); mytel_tcleval(tel,s);
   strcpy(signe,tel->interp->result);
   if ((strcmp(signe,"-")!=0)&&(strcmp(signe,"+")!=0)) {
      strcpy(signe,"+");
   }
   sprintf(s,"string range \"%s\" 1 2",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   d=atoi(s);
   sprintf(s,"string range \"%s\" 4 5",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   m=atoi(s);
   if (tel->longformatindex==0) { 
      sprintf(s,"string range \"%s\" 7 8",ss); mytel_tcleval(tel,s);
      strcpy(s,tel->interp->result);
      sec=atoi(s);
      sprintf(s,"%s%02dd%02dm%02ds",signe,d,m,sec);
   } else {
      /*sprintf(s,"%s%02ldh%02ldm",signe,d,m);*/
      sprintf(s,"%s%02dd%02dm%02ds",signe,d,m,sec=0);
   }
   strcat(result,s);
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
   /* LX200 protocol has 2 motion rates */
   if (tel->focus_move_rate<=0.5) {
      /* Slow */
      mytel_sendLX(tel, ":FS#" , RETURN_NOTHING,  s);
   } else if (tel->focus_move_rate>0.5) {
      /* Fast */
      mytel_sendLX(tel, ":FF#" , RETURN_NOTHING, s);
   }
   
	sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   
	if (strcmp(direc,"+")==0) {
      mytel_sendLX(tel, ":F+#" , RETURN_NOTHING,  s);
   } else if (strcmp(direc,"-")==0) {
      mytel_sendLX(tel, ":F-#" , RETURN_NOTHING, s);
   }
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   char s[1024];
   mytel_sendLX(tel, ":FQ#" , RETURN_NOTHING, s);
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
   char s[1024],ss[1024];
   int y,m,d,h,min;
   int sec;
   /* Get the time */
    mytel_flush(tel);
  mytel_sendLX(tel, ":GL#" , RETURN_SHARP, ss);
   
	sprintf(s,"string range \"%s\" 0 1",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   h=atoi(s);
   sprintf(s,"string range \"%s\" 3 4",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   min=atoi(s);
   sprintf(s,"string range \"%s\" 6 7",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   sec=atoi(s);
   
	/* Get the date */
   mytel_sendLX(tel, ":GC#" , RETURN_SHARP, ss);
   sprintf(s,"string range \"%s\" 0 1",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   m=atoi(s);
   sprintf(s,"string range \"%s\" 3 4",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   d=atoi(s);
   sprintf(s,"string range \"%s\" 6 7",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   y=atoi(s);
   if (y>91) {
      y=y+1900;
   } else {
      y=y+2000;
   }
   /* Returns the result */
   sprintf(ligne,"%d %d %d %d %d %d.0",y,m,d,h,min,sec);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   char ligne[1024],ligne2[1024], ss[1024];
   int sec;
   /* Set the time */
   mytel_flush(tel);
   sec=(int)(s);
   sprintf(ligne2,"%02d:%02d:%02d",h,min,sec);
   sprintf(ligne,":SL %s#",ligne2); 
   mytel_sendLX(tel, ligne , RETURN_OK, ss);
   
	/* Set the date */
   if (y<1992) {y=1992;}
   if (y>2091) {y=2091;}
   if (y<2000) {
      y=y-1900;
   } else {
      y=y-2000;
   }
   
   sprintf(ligne2,"%02d/%02d/%02d",m,d,y);
   sprintf(ligne,":SC %s#",ligne2); 
   mytel_sendLX(tel, ligne , RETURN_OK, ss);
   
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   char s[1024],ss[1024],signe[3],ew[3];
   int d1,m1,d2,m2;
   double longitude,latitude;
   
	/* Get the longitude */
   mytel_flush(tel);
   mytel_sendLX(tel, ":Gg#" , RETURN_SHARP, ss);
	
	sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"string range \"%s\" 0 2",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   d1=atoi(s);
   sprintf(s,"string range \"%s\" 4 5",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   m1=atoi(s);
   longitude=(double)d1+(double)m1/60.;
   if (longitude>180) {
      longitude=360.-longitude;
      strcpy(ew,"e");
   } else {
      strcpy(ew,"w");
   }
   /* Get the latitude */
   mytel_sendLX(tel, ":Gt#" , RETURN_SHARP, ss);
	
	sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"string range \"%s\" 1 2",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   d2=atoi(s);
   sprintf(s,"string range \"%s\" 4 5",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   m2=atoi(s);
   sprintf(s,"string range \"%s\" 0 0",ss); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   if (strcmp(s,"-")==0) {
      strcpy(signe,"-");
   } else {
      strcpy(signe,"+");
   }
   latitude=fabs((double)d2)+(double)m2/60.;
   /* Returns the result */
   sprintf(ligne,"GPS %f %s %s%f 0",longitude,ew,signe,latitude);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   char ligne[1024],ligne2[1024], s[1024];
   /* Set the longitude */
   mytel_flush(tel);
   if ((strcmp(ew,"E")==0)||(strcmp(ew,"e")==0)) {
      longitude=360.-longitude;
   }
   sprintf(ligne,"mc_angle2dms %f 360 zero 0 + list",longitude); mytel_tcleval(tel,ligne);
   strcpy(ligne2,tel->interp->result);
   sprintf(ligne,"string range \"[string range [lindex {%s} 0] 1 3]\xDF[string range [lindex {%s} 1] 0 1]\" 0 6",ligne2,ligne2); mytel_tcleval(tel,ligne);
   strcpy(ligne2,tel->interp->result);
   
	sprintf(ligne,":Sg %s#",ligne2); 
   mytel_sendLX(tel, ligne , RETURN_OK, s);
	
	/* Set the latitude */
   sprintf(ligne,"mc_angle2dms %f 90 zero 0 + list",latitude); mytel_tcleval(tel,ligne);
   strcpy(ligne2,tel->interp->result);
   sprintf(ligne,"string range \"[string range [lindex {%s} 0] 0 0][string range [lindex {%s} 0] 1 2]\xDF[string range [lindex {%s} 1] 0 1]\" 0 6",ligne2,ligne2,ligne2); mytel_tcleval(tel,ligne);
   strcpy(ligne2,tel->interp->result);
   
	sprintf(ligne,":St %s#",ligne2); 
   mytel_sendLX(tel, ligne , RETURN_OK, s);
	
	return 0;
}
/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_get_format(struct telprop *tel)
{
   char s[1024];
   int len,k;   
   mytel_flush(tel);

   mytel_sendLX(tel, ":GR#" , RETURN_SHARP, s);
	
	len=(int)strlen(s);
   k=0;
   /* 12:34:45# ou 12:34.7# */
   if (len>=7) {
      if (s[5]=='.') {
         tel->longformatindex=1;
         k=1;
      } else if (s[5]==':') {
         tel->longformatindex=0;
         k=1;
      }
   } 

   return k;
}

int mytel_set_format(struct telprop *tel,int longformatindex)
{
   char s[1024];
   int k=0;
   if (mytel_get_format(tel)==1) {
      if (longformatindex!=tel->longformatindex) {        
		   mytel_sendLX(tel, ":U#" , RETURN_NOTHING, s);
			tel->longformatindex=longformatindex;
         k=1;
      }
   }
   
   //logInfo("mytel_set_format format=%d",tel->longformatindex);
   return k;
}

/**
 * mytel_flush
 * flush the input channel until nothing is received
 * return 0 if OK, 
 */
int mytel_flush(struct telprop *tel)
{
   char s[1024];
   int k=0;

   
   if (tel->autoflush == TRUE ) {
      while (1) {
      // send # and read one character 
      mytel_sendLX(tel, "#",FLUSH, s);
      if (strcmp(s,"")==0) {
          //logInfo("mytel_flush k=%",k );
           return k;
      }
        k++;
      }
   }
	return 0;
}

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   return 0;
}

/**
 * sendLX : send a command to the telescop
 *  params :
 *      command : "xxxxx#" string terminated by #
 *      returntype : type of string returned by LX
 *			0 (return nothing)
 *			1 (return one char)
 *			2 (return string terminated by #)
 *
 * return :
 *  if recvWithTimeout OK
 *		cr= 1
 *    if returnType = 0  response = ""
 *    if returnType = 1  response = "0" or "1"
 *    if returnType = 2  response = "...#"
 * if openSocket() or sendRequest() or recvWithTimeout() error
 *		cr = 0
 *
 *  return cr
 */
int mytel_sendLX(struct telprop *tel, char *command, int returnType, char *response) {

	char url[1024];
	char result[256];
	int n;
	int cr = FALSE;

   
	result[0] = 0;
	response[0] = 0;
   
#ifdef SIMUL_AUDINET
   // SIMULATION
	logInfo("sendHttpRequest SIMUL url=http://%s:%d/cgi-bin/sendLX.cgi?r=%d&c=%s",tel->host, tel->httpPort, returnType, command);

   switch( returnType ) {
      case RETURN_NOTHING : 
         strcpy(response,"");
         break;
      case RETURN_OK : 
         if( strcmp(command,":MS#")==0) {
            strcpy(response,"0");  // repond toujours OK pour GOTO
         } 
         else {
            strcpy(response,"1"); // repond toujours OK pour les autres 
            logInfo("mytel_sendLX non:MS#=%s=",command);
         } 
         break;

      case RETURN_SHARP:
         if( strcmp(command,":GR#")==0) {
            strcpy(response,"12:53:59#");  
         }
         else if( strcmp(command,":GD#")==0) {
            strcpy(response,"+27�29:33");  
         }
         else {
            strcpy(response,"0"); 
         }
         break;
      default:
         strcpy(response,"");  
         break;
      }
   logInfo("mytel_sendLX n=%d response=%s", strlen(response)+17, response);
   return TRUE;
#endif

   /* j'ouvre la socket tcp */
   if ( ! socktcp_open( tel->host, tel->httpPort) ) {
      logError("mytel_sendLX socktcp_open");
      cr = FALSE;
   }
   else {
		/* je prepare l'URL */
		sprintf(url,"/cgi-bin/sendLX.cgi?r=%d&c=%s", returnType, command); 
		//logInfo("mytel_sendLX url=http://%s:%d%s", tel->host,tel->httpPort, url);
   
		/* j'envoi la requete */   
		if ( ! socktcp_send(  tel->host, tel->httpPort, url )) {
			logError("mytel_sendLX sendRequestSocket");
			cr = FALSE;       
		}
		else {
			/* je lis la reponse */
			n = socktcp_recv((char *)result,256);
			result[n]=0;
			if( strcmp (result,"HTTP/1.0 200") !=0) {
			   if( n>=14 ) {
				   strcpy(response, &result[17]);
			      //logInfo("mytel_sendLX n=%d response=%s", n, response);
         	   cr = TRUE;
			   }
            else {
               logError("mytel_sendLX n=%d result=%s", n, result);
            }
         }
         else {
           logError("mytel_sendLX n=%d result=%s", n, result);
         }
		}
      // je referme la socket tcp
      socktcp_close();
	}
	return cr;
}



