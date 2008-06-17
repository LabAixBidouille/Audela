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
#include "routine.h"


const double pi=3.14159265359;
/* La Terre tourne en 23h56min4.2s=86164.2s */

T_Parameter_Axe Axe[2];
double Step_Siderale;
double Vitesse_Siderale;
unsigned short Dent_ASC;
unsigned short Dent_DEC;

char String_Debug[200];   /* A VIRER */


int debug(struct telprop *tel,char *Result);
void Write_MCMT(struct telprop *tel,char* Buffer,int Nombre);
void Read_MCMT(struct telprop *tel,char* Buffer,int Nombre);
int Captor(struct telprop *tel,int N_Carte);
int GetReference(struct telprop *tel,int * t_asc,int * c_asc,int * t_dec,int * c_dec);
int GetCoord(struct telprop *tel,double * Coord_Asc,double * Coord_Dec);
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"MCMT",    /* telescope name */
    "MCMT",    /* protocol name */
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
   int Step1,Step2;
   double Time;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   int len,k;
   /* --- transcode comX -> /dev/ttyS(X-1) for Linux ---*/
   Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
   strcpy(s,tel->interp->result);
   strcpy(ss,argv[2]);
   strcpy(ssusb,argv[2]);
   if (strcmp(s,"Linux")==0) {
      sprintf(s,"string toupper %s",ss);
      Tcl_Eval(tel->interp,s);
      strcpy(s,tel->interp->result);
      len=(int)strlen(s);
      if (len>3) {
         for (k=0;k<=2;k++) { ss[k]=s[k]; }
         ss[3]='\0';
         if (strcmp(ss,"COM")==0) {
            if (len>=4) {
               for (k=3;k<=len;k++) { ss[k-3]=s[k]; }
               ss[k]='\0';
               k=(int)atoi(ss);
               if ((k>=1)&&(k<=4)) {
                  sprintf(ss,"/dev/ttyS%d",k-1);
                  sprintf(ssusb,"/dev/ttyUSB%d",k-1);
               }
            }
         }
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



   sprintf(s,"fconfigure %s -mode 9600,n,8,1",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"fconfigure %s -buffering none -buffersize 2000 -blocking 0",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"fconfigure %s -timeout 500 -translation {binary binary}",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"fconfigure %s -encoding binary",tel->channel); mytel_tcleval(tel,s);
   tel_testcom(tel);
   if (tel_testcom(tel)!=0) return 1;

   s[0]=Carte_Asc;s[1]=Read_Table;s[2]=0xFF;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   Read_MCMT(tel,s,31);
   Axe[Asc]=Fill_Parameter(s);

   sprintf(s,"expr  $confTel(conf_mcmt,nbr_dent_ad)"); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   Dent_ASC=atoi(s);
   Axe[Asc].Dent=Dent_ASC;
   Axe[Asc]=Fill_Vitesse(Axe[Asc]);

   Vitesse_Siderale=360/86164.2;
   Step_Siderale=Axe[Asc].Factor[Guidage]/86164.2;

   CalculRampe(Axe[Asc].V_Acc,Axe[Asc].V_Guidage,Axe[Asc].V_Rapide,&Step1,&Time);
   CalculRampe(Axe[Asc].V_Acc,Axe[Asc].V_Rapide,Axe[Asc].V_Guidage,&Step2,&Time);

   Axe[Asc].Adjust_Rapide=(Step2-Step1) >> 1;

   sprintf(String_Debug,"Adjust=%d\n",Axe[Asc].Adjust_Rapide);
   Debug(tel,String_Debug);
   sprintf(String_Debug,"Step2=%d\n",Step2);
   Debug(tel,String_Debug);
   Axe[Asc].Angle_Rampes_Rapide=(Step1+Step2)*360*1.02/Axe[Asc].Factor[Rapide];
   CalculRampe(Axe[Asc].V_Acc,Axe[Asc].V_Guidage,Axe[Asc].V_Lent,&Step1,&Time);
   CalculRampe(Axe[Asc].V_Acc,Axe[Asc].V_Lent,Axe[Asc].V_Guidage,&Step2,&Time);
   Axe[Asc].Angle_Rampes_Lent=(Step1+Step2)*360*1.02/Axe[Asc].Factor[Lent];

   s[0]=Carte_Dec;s[1]=Read_Table;s[2]=0xFF;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   Read_MCMT(tel,s,31);
   Axe[Dec]=Fill_Parameter(s);

   sprintf(s,"expr  $confTel(conf_mcmt,nbr_dent_dec)"); mytel_tcleval(tel,s);
   strcpy(s,tel->interp->result);
   Dent_DEC=atoi(s);
   Axe[Dec].Dent=Dent_DEC;

   Axe[Dec]=Fill_Vitesse(Axe[Dec]);
   CalculRampe(Axe[Dec].V_Acc,Axe[Dec].V_Guidage,Axe[Dec].V_Rapide,&Step1,&Time);
   CalculRampe(Axe[Dec].V_Acc,Axe[Dec].V_Rapide,Axe[Dec].V_Guidage,&Step2,&Time);
   Axe[Dec].Angle_Rampes_Rapide=(Step1+Step2)*360*1.02/Axe[Dec].Factor[Rapide];
   CalculRampe(Axe[Dec].V_Acc,Axe[Dec].V_Guidage,Axe[Dec].V_Lent,&Step1,&Time);
   CalculRampe(Axe[Dec].V_Acc,Axe[Dec].V_Lent,Axe[Dec].V_Guidage,&Step2,&Time);
   Axe[Dec].Angle_Rampes_Lent=(Step1+Step2)*360*1.02/Axe[Dec].Factor[Lent];

   GetReference(tel,&Axe[Asc].Ref_Time,
                    &Axe[Asc].Ref_Step,
                    &Axe[Dec].Ref_Time,
                    &Axe[Dec].Ref_Step);
   Axe[Asc].Ref_Angle=0;
   Axe[Dec].Ref_Angle=0;

   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   if (Captor(tel,Carte_Asc)==Captor(tel,Carte_Asc)) return 1;
   else return 0;
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
   GetReference(tel,&Axe[Asc].Ref_Time,
                    &Axe[Asc].Ref_Step,
                    &Axe[Dec].Ref_Time,
                    &Axe[Dec].Ref_Step);
   Axe[Asc].Ref_Angle=tel->ra0;
   Axe[Dec].Ref_Angle=tel->dec0;
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
	return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[10];
   int Step_Move;
   double Coord_Asc,Coord_Dec,Delta;
   GetCoord(tel,&Coord_Asc,&Coord_Dec);
   Delta=Coord_Asc-tel->ra0;
   if (fabs(Delta)>Axe[Asc].Angle_Rampes_Rapide)
   {
      Step_Move=StepAjust_Alpha(Coord_Asc-tel->ra0,Rapide)/2 /* +Axe[Asc].Adjust_Rapide */ ;
      s[0]=Carte_Asc;s[1]=FastPos;
      s[2]=(Step_Move & 0xFF000000) >> 24;
      s[3]=(Step_Move & 0x00FF0000) >> 16;
      s[4]=(Step_Move & 0x0000FF00) >> 8;
      s[5]=Step_Move & 0x000000FF;
      if (Delta<0) s[2]|=0x80;
   }
   else
   {
      Step_Move=StepAjust_Alpha(Coord_Asc-tel->ra0,Lent)/2 /* +Axe[Asc].Adjust_Rapide */ ;
      s[0]=Carte_Asc;s[1]=SlowPos;
      s[2]=(Step_Move & 0xFF000000) >> 24;
      s[3]=(Step_Move & 0x00FF0000) >> 16;
      s[4]=(Step_Move & 0x0000FF00) >> 8;
      s[5]=Step_Move & 0x000000FF;
      if (Delta<0) s[2]|=0x80;
   }
   Write_MCMT(tel,s,6);
   do
   {
      s[0]=Carte_Asc;s[1]=Etat;s[2]=0xFF;s[3]=0x00;s[4]=0x00;s[5]=0x00;
      Write_MCMT(tel,s,6);
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      Read_MCMT(tel,s,6);
      s[1]&= 0x78;
   } while (s[1]!=0);
   GetCoord(tel,&Coord_Asc,&Coord_Dec);
   Delta=Coord_Asc-tel->ra0;
   Step_Move=StepAjust_Alpha(Coord_Asc-tel->ra0,Lent)/2;
   s[0]=Carte_Asc;s[1]=SlowPos;
   s[2]=(Step_Move & 0xFF000000) >> 24;
   s[3]=(Step_Move & 0x00FF0000) >> 16;
   s[4]=(Step_Move & 0x0000FF00) >> 8;
   s[5]=Step_Move & 0x000000FF;
   if (Delta<0) s[2]|=0x80;
   Write_MCMT(tel,s,6);
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],Carte,Sens;
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   Carte=Carte_Asc;Sens='S';
   if ((tel->radec_move_rate<=0.25)) {
      /* Guide */
      if (strcmp(direc,"N")==0) {
         Carte=Carte_Dec;Sens='D';
      } else if (strcmp(direc,"S")==0) {
         Carte=Carte_Dec;Sens='Q';
      } else if (strcmp(direc,"E")==0) {
         Carte=Carte_Asc;Sens='Q';
      } else if (strcmp(direc,"W")==0) {
         Carte=Carte_Asc;Sens='D';
      }
   } else if ((tel->radec_move_rate>0.25)&&(tel->radec_move_rate<=0.75)) {
      /* Center */
      if (strcmp(direc,"N")==0) {
         Carte=Carte_Dec;Sens='G';
      } else if (strcmp(direc,"S")==0) {
         Carte=Carte_Dec;Sens='F';
      } else if (strcmp(direc,"E")==0) {
         Carte=Carte_Asc;Sens='F';
      } else if (strcmp(direc,"W")==0) {
         Carte=Carte_Asc;Sens='G';
      }
   } else if ((tel->radec_move_rate>0.75)) {
      /* Slew */
      if (strcmp(direc,"N")==0) {
         Carte=Carte_Dec;Sens='X';
      } else if (strcmp(direc,"S")==0) {
         Carte=Carte_Dec;Sens='W';
      } else if (strcmp(direc,"E")==0) {
         Carte=Carte_Asc;Sens='W';
      } else if (strcmp(direc,"W")==0) {
         Carte=Carte_Asc;Sens='X';
      }
   }
   s[0]=Carte;s[1]=Sens;s[2]=0xFF;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[100];
   s[0]=Carte_Asc;s[1]=Siderale;s[2]=0xFF;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   s[0]=Carte_Dec;s[1]=Siderale;s[2]=0xFF;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[100];
   double Coord_Asc,Coord_Dec;
   strcpy(result,"");
   GetCoord(tel,&Coord_Asc,&Coord_Dec);

   sprintf(s,"mc_angle2hms %f 360 zero 1 + string",Coord_Asc); mytel_tcleval(tel,s);
   strcat(result,tel->interp->result);
   strcat(result," ");

   sprintf(s,"mc_angle2dms %f 90 zero 1 auto string",Coord_Dec); mytel_tcleval(tel,s);
   strcat(result,tel->interp->result);
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
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
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

int mytel_get_format(struct telprop *tel)
{
   return 0;
}

int mytel_set_format(struct telprop *tel,int longformatindex)
{
   return 0;
}

int mytel_flush(struct telprop *tel)
/* flush the input channel until nothing is received */
{
   char s[1024];
   int k=0;
   while (1==1) {
      sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
      strcpy(s,tel->interp->result);
      if (strcmp(s,"")==0) {
         return k;
      }
      k++;
   }
}

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

void chars2uword(unsigned char a,unsigned char b,unsigned char c,unsigned char d,unsigned int *i)
{
   unsigned int i0,ia,ib,ic,id;
   ia=(unsigned int)a;
   ib=(unsigned int)b;
   ic=(unsigned int)c;
   id=(unsigned int)d;
   i0=0;
   i0+=ia;
   i0+=(ib<<8);
   i0+=(ic<<16);
   i0+=(id<<24);
   *i=i0;
}

void word2chars(int i,unsigned char *a,unsigned char *b,unsigned char *c,unsigned char *d)
{
   int ia,ib,ic,id;
   ia=(i&0x000000FF);
   ib=(i&0x0000FF00)>>8;
   ic=(i&0x00FF0000)>>16;
   id=(i&0xFF000000)>>24;
   *a=(unsigned char)ia;
   *b=(unsigned char)ib;
   *c=(unsigned char)ic;
   *d=(unsigned char)id;
}

int mytel_version(struct telprop *tel,char *result)
{
   char s[200];
   int nb,k;
   nb=1;
   strcpy(result,"");
   /* Send 6 bytes */
   s[0]=Carte_Asc;s[1]=Version;s[2]=0x00;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   Read_MCMT(tel,s,1);
   /* Receive 1 bytes */
   for (k=0;k<nb;k++) {
      result[k]=s[k];
   }
   return 0;
}

int mytel_readtable(struct telprop *tel,int numcard, char *result)
{
   char s[1024];
   int nb,k;
   nb=1;
   strcpy(result,"");
   /* Send 6 bytes */
   s[0]=Carte_Asc;s[1]=Read_Table;s[2]=0x00;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   Read_MCMT(tel,s,31);
   /* Receive 31 bytes */
   for (k=0;k<nb;k++) {
      result[k]=s[k];
   }
   return 0;
}

void Write_MCMT2(struct telprop *tel,char* Buffer,int Nombre)
{
   int i;
   char s[100],ss[100],sss[100];
   strcpy(ss,"");
   for (i=0;i<Nombre;i++)
   {
	  if (Buffer[i]==0) sprintf(s,"puts -nonewline %s %s",tel->channel,"\\x00");
	  else sprintf(s,"puts -nonewline %s %c",tel->channel,Buffer[i]);
	  mytel_tcleval(tel,s);
   }
   sprintf(String_Debug,"s=%X%X%2X \n",Buffer[0],Buffer[1],Buffer[2]);
   Debug(tel,String_Debug);
   sprintf(String_Debug,"s=%X%X%X \n",Buffer[3],Buffer[4],Buffer[5]);
   Debug(tel,String_Debug);
}

void Write_MCMT(struct telprop *tel,char* Buffer,int Nombre)
{
   int i;
   char s[100],ss[100],sss[100];
   strcpy(ss,"");
   for (i=0;i<Nombre;i++)
   {
      strcpy(sss,"");
	  if (Buffer[i]==0) strcat(ss,"\\x00");
	  else
	  {
		  sss[0]=Buffer[i];
		  sss[1]=0;
		  strcat(ss,sss);
	  }
   }
   sprintf(s,"puts -nonewline %s \"%s\"",tel->channel,ss);
   mytel_tcleval(tel,s);
}

void Read_MCMT(struct telprop *tel,char* Buffer,int Nombre)
{
   int i;
   char s[100],ss[100];
   strcpy(ss,"");
   sprintf(s,"after 100"); mytel_tcleval(tel,s);
   for (i=0;i<Nombre;i++)
   {
      /* Read 1 octets */
      sprintf(s,"uplevel #0 read %s 1",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,tel->interp->result);
      if ( (ss[0] & 0x80)!=0)    /* shit utf8 de merde */
      {
      ss[0]&=0x03; /* we only keep the 2 highest bits */
      ss[0]<<=6;
      ss[1]&=0x3F; /* we only keep the 6 lowest bits */
      ss[0]|=ss[1];
      }
      Buffer[i]=ss[0];
   }

}

int Captor(struct telprop *tel,int N_Carte)
/* ask to MCMT the position of motor of N_Carte */
{
   int Cap;
   char s[100];
   s[0]=N_Carte;s[1]=Codeur;s[2]=0x80;s[3]=0x00;s[4]=0x82;s[5]=0x83;
   Write_MCMT(tel,s,6);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   Read_MCMT(tel,s,4);
   Cap=((s[0]&0x000000FF)<<24) + ((s[1]&0x000000FF)<<16) + ((s[2]&0x000000FF)<<8) + (s[3]&0x000000FF);
   return Cap;
}

int GetReference(struct telprop *tel,int * t_asc,int * c_asc,int * t_dec,int * c_dec)
/* ask to MCMT the position of encoders and at what time */
{
   char s[100],ss[100];
   s[0]=Carte_Asc;s[1]=Codeur;s[2]=0x00;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   sprintf(s,"clock clicks -milliseconds"); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   *t_asc=atoi(ss);
   Read_MCMT(tel,s,4);
   *c_asc=((s[0]&0x000000FF)<<24) + ((s[1]&0x000000FF)<<16) + ((s[2]&0x000000FF)<<8) + (s[3]&0x000000FF);
   s[0]=Carte_Dec;s[1]=Codeur;s[2]=0x00;s[3]=0x00;s[4]=0x00;s[5]=0x00;
   Write_MCMT(tel,s,6);
   sprintf(s,"clock clicks -milliseconds"); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   *t_dec=atoi(ss);
   Read_MCMT(tel,s,4);
   *c_dec=((s[0]&0x000000FF)<<24) + ((s[1]&0x000000FF)<<16) + ((s[2]&0x000000FF)<<8) + (s[3]&0x000000FF);
   return 0;
}

int GetCoord(struct telprop *tel,double * Coord_Asc,double * Coord_Dec)
/* ask to MCMT the position of encoders and at what time */
{
   int Step_A,Time_A,Step_D,Time_D;
   double Posit;
   GetReference(tel,&Time_A,&Step_A,&Time_D,&Step_D);

   Posit=(((Step_A-Axe[Asc].Ref_Step)% Axe[Asc].Factor[Guidage])*360.0/
         Axe[Asc].Factor[Guidage]);
   Posit=Posit+(Time_A-Axe[Asc].Ref_Time)*Vitesse_Siderale/1000;
   if (Axe[Asc].D_Lent_Plus!=0) Posit=-Posit;
   *Coord_Asc=Posit+Axe[Asc].Ref_Angle;

   Posit=(((Step_D-Axe[Dec].Ref_Step)% Axe[Dec].Factor[Guidage])*360.0/
         Axe[Dec].Factor[Guidage]);
   if (Axe[Dec].D_Lent_Plus==0) Posit=-Posit;
   *Coord_Dec=Posit+Axe[Dec].Ref_Angle;
   return 0;
}

