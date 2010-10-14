/* telescop.h
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

#ifndef __TELESCOP_H__
#define __TELESCOP_H__

#include <tcl.h>
#include <libtel/libstruc.h>

/* #define DEBUG */
#define Asc 0
#define Dec 1
#define Carte_Asc 30
#define Carte_Dec 31
#define Guidage     0
#define Corec_Moins 1
#define Corec_Plus  2
#define Lent        3
#define Rapide      4

#define Read_Table 'K'
#define Codeur     'C'
#define Etat       'E'
#define Version    'V'
#define Siderale   'S'
#define FastPos    'P'
#define SlowPos    'p'


/* the clock clicks fonction overflow at 2147483647 +1 -> -2147483648 */


/*
 * Donnees propres a chaque telescope.
 */
/* Valeur entiere dans l'EEPROM de MCMT */
/* Vitesses en deg/s */
typedef struct Parameter_Axe{				/* V=Vitesse, temps entre chaque µpas en 1600ns */
	unsigned short V_Guidage;
	unsigned char V_Guidage_LSB;
	unsigned short V_Corec_Plus,V_Corec_Moins,V_Lent,V_Rapide;
	unsigned char V_Acc,D_Guidage,D_Corec_Plus,D_Corec_Moins, /* D=Direction */
	D_Lent_Plus,D_Lent_Moins,D_Rapide_Plus,D_Rapide_Moins,
	Resolution[5],	/* R=Resolution */
	C_Guidage,C_Lent,C_Rapide,S_Led, /* C=Courant S=Sens raquette */
	Dummy1,Dummy2,Dummy3;
	unsigned short Dent;
	int Factor[5];     /* (µstep) */
	/* number of micro-step for 360° of telescope, for each speed */

    double Vitesse[5]; /* Speed of different mode (deg/s) */
	double Step[5];    /* Speed of different mode (µstep/s) */
	double Angle_Rampes_Rapide,Angle_Rampes_Lent; /* Angle made when you start from sky
Speed, go to Rapide(Lent) speed, and next
go back to sky speed, plus a majoration
 of 2% */
	int Adjust_Rapide,Adjust_Lent;
    double Ref_Angle;
    int Ref_Step,Ref_Time;
} T_Parameter_Axe;

/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
};

int tel_init(struct telprop *tel, int argc, char **argv);
int tel_goto(struct telprop *tel);
int tel_coord(struct telprop *tel,char *result);
int tel_testcom(struct telprop *tel);
int tel_close(struct telprop *tel);
int tel_radec_init(struct telprop *tel);
int tel_radec_goto(struct telprop *tel);
int tel_radec_state(struct telprop *tel,char *result);
int tel_radec_coord(struct telprop *tel,char *result);
int tel_radec_move(struct telprop *tel,char *direction);
int tel_radec_stop(struct telprop *tel,char *direction);
int tel_radec_motor(struct telprop *tel);
int tel_focus_init(struct telprop *tel);
int tel_focus_goto(struct telprop *tel);
int tel_focus_coord(struct telprop *tel,char *result);
int tel_focus_move(struct telprop *tel,char *direction);
int tel_focus_stop(struct telprop *tel,char *direction);
int tel_focus_motor(struct telprop *tel);
int tel_date_get(struct telprop *tel,char *ligne);
int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int tel_home_get(struct telprop *tel,char *ligne);
int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);

int mytel_radec_init(struct telprop *tel);
int mytel_radec_goto(struct telprop *tel);
int mytel_radec_state(struct telprop *tel,char *result);
int mytel_radec_coord(struct telprop *tel,char *result);
int mytel_radec_move(struct telprop *tel,char *direction);
int mytel_radec_stop(struct telprop *tel,char *direction);
int mytel_radec_motor(struct telprop *tel);
int mytel_focus_init(struct telprop *tel);
int mytel_focus_goto(struct telprop *tel);
int mytel_focus_coord(struct telprop *tel,char *result);
int mytel_focus_move(struct telprop *tel,char *direction);
int mytel_focus_stop(struct telprop *tel,char *direction);
int mytel_focus_motor(struct telprop *tel);
int mytel_date_get(struct telprop *tel,char *ligne);
int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int mytel_home_get(struct telprop *tel,char *ligne);
int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);

void chars2uword(unsigned char a,unsigned char b,unsigned char c,unsigned char d,unsigned int *i);
void word2chars(int i,unsigned char *a,unsigned char *b,unsigned char *c,unsigned char *d);

int mytel_version(struct telprop *tel,char *result);
int mytel_readtable(struct telprop *tel,int numcard, char *result);
int mytel_debug(struct telprop *tel,char *result);

#define Carte_Asc 30
#define Carte_Dec 31

#define Guidage     0
#define Corec_Moins 1
#define Corec_Plus  2
#define Lent        3
#define Rapide      4


#endif
