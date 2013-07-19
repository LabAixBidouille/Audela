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
#include <libtel/libtel.h>
#include <libtel/util.h>

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"ETEL",    /* telescope name */
    "Etel",    /* protocol name */
    "etel",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
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
   char s[1024];
	int err,k,kk,axis[3];
	char etel_driver[50];
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_etel.txt","wt");
   fprintf(f,"Demarre une init\n");
	fclose(f);
#endif
	axis[0]=0;
	axis[1]=1; //4
	axis[2]=2; //5
	strcpy(etel_driver,"DSTEB3");
   if (argc >= 1) {
      for (kk = 0; kk < argc-1; kk++) {
         if (strcmp(argv[kk], "-driver") == 0) {
            strcpy(etel_driver,argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-axis0") == 0) {
            axis[0]=atoi(argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-axis1") == 0) {
            axis[1]=atoi(argv[kk + 1]);
         }
         if (strcmp(argv[kk], "-axis2") == 0) {
            axis[2]=atoi(argv[kk + 1]);
         }
      }
   }
   /* --- type de monture ---*/
   tel->type_mount=MOUNT_EQUATORIAL;
   /* --- type des axes ---*/
   tel->axis_param[0].type=AXIS_NOTDEFINED;
   tel->axis_param[1].type=AXIS_NOTDEFINED;
   tel->axis_param[2].type=AXIS_NOTDEFINED;
	/* --- boucle de creation des axes ---*/
	for (k=0;k<3;k++) {
	   tel->drv[k]=NULL;
		/* create drive */
		if (err = dsa_create_drive(&tel->drv[k])) {
			mytel_error(tel,k,err);
			return 1;
		}
		sprintf(s,"etb:%s:%d",etel_driver,axis[k]);
		if (err = dsa_open_u(tel->drv[k],s)) {
			if (k==0) {
				mytel_error(tel,k,err);
				sprintf(s," {etb:%s:%d}",etel_driver,axis[k]);
				strcat(tel->msg,s);
				tel_close(tel);
				return 2;
			} else {
				break;
			}
		} else {
			if (k==0) { tel->axis_param[k].type=AXIS_DEC; }
			if (k==1) { tel->axis_param[k].type=AXIS_HA; }
			if (k==2) { tel->axis_param[k].type=AXIS_PARALLACTIC; }
			/* Reset error */
			if (err = dsa_reset_error_s(tel->drv[k], 1000)) {
				mytel_error(tel,k,err);
				tel_close(tel);
				return 3;
			}
			/* power on */
			if (err = dsa_power_on_s(tel->drv[k], 10000)) {
				mytel_error(tel,k,err);
				tel_close(tel);
				return 4;
			}
		}
	}
   /* --- init home ---*/
   strcpy(tel->home,"GPS 2 E 48 100");
   strcpy(tel->home0,tel->home);
   /* --- Nombre de dents sur la roue dentee --- */
   tel->axis_param[0].teeth_per_turn=480;
   tel->axis_param[1].teeth_per_turn=480;
   tel->axis_param[2].teeth_per_turn=480;
   /* --- Sens du codeur (UC croissants) / unites physiques croissantes --- */
   tel->axis_param[0].sens=1;
   tel->axis_param[1].sens=1;
   tel->axis_param[2].sens=1;
	/* --- Inits par defaut ---*/
	for (k=0;k<3;k++) {
		tel->axis_param[0].posinit=0;
		tel->axis_param[0].angleinit=0.;
	}
	/* --- init special T193 ---*/
	mytel_init_mount_default(tel,0);
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"Fin de l'init\n");
	fclose(f);
#endif
	return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
    /* Is the drive pointer valid ? */
    if(dsa_is_valid_drive(tel->drv)) {
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
	int k,err;
	/* --- boucle sur les axes ---*/
	for (k=0;k<3;k++) {
		if (tel->axis_param[k].type==AXIS_NOTDEFINED) {
			continue;
		}
		/* power off */
		if (err = dsa_power_off_s(tel->drv[k], 10000)) {
			//mytel_error(tel,k,err);
			//return 1;
		}
		/* close and destroy */
		if (err = dsa_close(tel->drv[k])) {
			//mytel_error(tel,k,err);
			//return 2;
		}
		if (err = dsa_destroy(&tel->drv[k])) {
			//mytel_error(tel,k,err);
			//return 3;
		}
	}
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
   int axisno,k;
   char angles[3][30];
	double angledegs[3];
	int angleucs[3];
	int voidangles[3];
	int h,m,sec;
	double tsl,angle;
   /* --- lecture sur les axes valides ---*/
	for (k=0;k<3;k++) {
		voidangles[k]=(int)&angles[k];
	}
	etel_radec_coord(tel,0,voidangles,angledegs,angleucs);
	/* --- mise en forme du resultat ---*/
   if (tel->axis_param[0].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_HA) {
				tel->axis_param[axisno].posinit=angleucs[axisno];
				tsl=etel_tsl(tel,&h,&m,&sec);
				angle=tsl-tel->ra0;
				angle+=720.;
				angle=angle-360*floor(angle/360);
				tel->axis_param[axisno].angleinit=angle;
         }
         if (tel->axis_param[axisno].type==AXIS_DEC) {
				tel->axis_param[axisno].posinit=angleucs[axisno];
				tel->axis_param[axisno].angleinit=tel->dec0;
         }
         if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
				tel->axis_param[axisno].posinit=angleucs[axisno];
				tel->axis_param[axisno].angleinit=0.;
         }
      }
   }
   return 0;
}

int mytel_hadec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
   int axisno,k;
   char angles[3][30];
	double angledegs[3];
	int angleucs[3];
	int voidangles[3];
   /* --- lecture sur les axes valides ---*/
	for (k=0;k<3;k++) {
		voidangles[k]=(int)&angles[k];
	}
	etel_radec_coord(tel,0,voidangles,angledegs,angleucs);
	/* --- mise en forme du resultat ---*/
   if (tel->axis_param[0].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_HA) {
				tel->axis_param[axisno].posinit=angleucs[axisno];
				/*
				tsl=etel_tsl(tel,&h,&m,&sec);
				angle=tsl-tel->ra0;
				angle+=720.;
				angle=angle-360*floor(angle/360);
				tel->axis_param[axisno].angleinit=angle;
				*/
				tel->axis_param[axisno].angleinit=tel->ra0;
         }
         if (tel->axis_param[axisno].type==AXIS_DEC) {
				tel->axis_param[axisno].posinit=angleucs[axisno];
				tel->axis_param[axisno].angleinit=tel->dec0;
         }
         if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
				tel->axis_param[axisno].posinit=angleucs[axisno];
				tel->axis_param[axisno].angleinit=0.;
         }
      }
   }
   return 0;
}

int mytel_radec_init_additional(struct telprop *tel)
 {
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   return 0;
}

int mytel_radec_goto0(struct telprop *tel)
{
   double deg_per_tooth,angle;
   int traits,interpo,axisno,err,val;
   int uc_per_motorturn,h,m,sec;
   double motorturns,tsl,vit,nbmotorturnpersec;
   double facteur_vitesse;
   int posmax,posmin,pos1,vit1;
   char s[1024];
   int time_in=0,time_out=240,k;
   int time_in0=0,time_out0=240;
	double dr,da;
	double angledeg0s[3],angledeg1s[3];
	double angledeg00s[3],angledeg11s[3];
	int angleucs[3];
   /* --- boucle sur les axes valides ---*/
   if (tel->radec_goto_blocking==1) {
		etel_radec_coord(tel,1,NULL,angledeg00s,angleucs);
	}
	while (1==1) {
		/* --- boucle sur les axes valides ---*/
		for (axisno=0;axisno<3;axisno++) {
		   if (tel->axis_param[axisno].type==AXIS_NOTDEFINED) {
				continue;
			}
			// = butees
			posmin=0;
			posmax=(int)(pow(2,31)-1);
			facteur_vitesse=10.;
			//= regle une vitesse de pointage
			vit=10.; //deg/s
			deg_per_tooth=360./tel->axis_param[axisno].teeth_per_turn; // teeth/360deg
			nbmotorturnpersec=vit/deg_per_tooth; // motorturn/s
			// = envoi la consigne de la vitesse du moteur
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,239,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				traits=512;
			} else {
				traits=val;
			}
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,241,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				interpo=1024;
			} else {
				interpo=val;
			}
			uc_per_motorturn=traits*interpo; // UC/motorturn or UC/tooth
			vit1=(int)(nbmotorturnpersec*uc_per_motorturn/facteur_vitesse); // UC/s
   		if (err = dsa_set_register_s(tel->drv[axisno],ETEL_K,211,0,vit1,DSA_DEF_TIMEOUT)) {
				return 1;
			}
			// = decode les coordonnes
			if (tel->axis_param[axisno].type==AXIS_HA) {
				tsl=etel_tsl(tel,&h,&m,&sec);
				angle=tsl-tel->ra0;
				angle+=720.;
				angle=angle-360*floor(angle/360);
				//angle=tel->ra0; // verue pour test
			} else if (tel->axis_param[axisno].type==AXIS_DEC) {
				angle=tel->dec0;
			} else if (tel->axis_param[axisno].type==AXIS_AZ) {
				angle=0.; // a faire
			} else if (tel->axis_param[axisno].type==AXIS_ELEV) {
				angle=0.; // a faire
			} else if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
				angle=0.; // a faire
			}
			// = goto vers des coordonnes
			motorturns=tel->axis_param[axisno].sens*(angle-tel->axis_param[axisno].angleinit)/deg_per_tooth; // motorturn
			pos1=(int)(motorturns*uc_per_motorturn+tel->axis_param[axisno].posinit); // UC
			if (pos1<posmin)  {
				pos1+=(posmax+1);
			}
			if ((pos1>=posmin)&&(pos1<=posmax)) {
      		if (err = dsa_set_register_s(tel->drv[axisno],ETEL_K,210,0,pos1,DSA_DEF_TIMEOUT)) {
					return 1;
				}
			}
		}
		/* --- condition de fin de raliement ---*/
		if (tel->radec_goto_blocking==0) {
			break;
		} else {
			/* A loop is actived until the telescope is stopped */
			//tel_radec_coord(tel,coord0);
			dr=4*atan(1)/180.;
			etel_radec_coord(tel,1,NULL,angledeg0s,angleucs);
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				etel_radec_coord(tel,1,NULL,angledeg1s,angleucs);
				da=0.;
				for (k=0;k<3;k++) {
					da=da+fabs(asin(sin(angledeg1s[k]-angledeg0s[k]))/dr*3600.);
				}
				if (da<3.) {break;} // sortie avec un residu a 3 arcsec
				for (k=0;k<3;k++) {
					angledeg0s[k]=angledeg1s[k];
				}
				if (time_in>=time_out) {break;}
			}
		}
   	time_in0++;
		etel_radec_coord(tel,1,NULL,angledeg11s,angleucs);
		da=0.;
		for (k=0;k<3;k++) {
			da=da+fabs(asin(sin(angledeg11s[k]-angledeg00s[k]))/dr*3600.);
		}
		if (da<1000) {break;} // sortie avec un residu a 1000 arcsec !!!!
		for (k=0;k<3;k++) {
			angledeg00s[k]=angledeg11s[k];
		}
		if (time_in0>=time_out0) {break;}
	}
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   double deg_per_tooth,angle;
   int traits,interpo,axisno,err,val;
   int uc_per_motorturn;
   double motorturns,vit,nbmotorturnpersec;
   double facteur_vitesse;
   int posmax,posmin,pos1,vit1;
   char s[1024];
   int time_in=0,time_out=240,k;
   int time_in0=0,time_out0=240;
	double dr,da;
	double angledeg0s[3],angledeg1s[3];
	double angledeg00s[3],angledeg11s[3];
	int angleucs[3];
   /* --- boucle sur les axes valides ---*/
   if (tel->radec_goto_blocking==1) {
		etel_radec_coord(tel,1,NULL,angledeg00s,angleucs);
	}
	while (1==1) {
		/* --- boucle sur les axes valides ---*/
		for (axisno=0;axisno<3;axisno++) {
		   if (tel->axis_param[axisno].type==AXIS_NOTDEFINED) {
				continue;
			}
			// = butees
			posmin=0;
			posmax=(int)(pow(2,31)-1);
			facteur_vitesse=10.;
			//= regle une vitesse de pointage
			vit=10.; //deg/s
			deg_per_tooth=360./tel->axis_param[axisno].teeth_per_turn; // teeth/360deg
			nbmotorturnpersec=vit/deg_per_tooth; // motorturn/s
			// = envoi la consigne de la vitesse du moteur
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,239,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				traits=512;
			} else {
				traits=val;
			}
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,241,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				interpo=1024;
			} else {
				interpo=val;
			}
			uc_per_motorturn=traits*interpo; // UC/motorturn or UC/tooth
			vit1=(int)(nbmotorturnpersec*uc_per_motorturn/facteur_vitesse); // UC/s
   		if (err = dsa_set_register_s(tel->drv[k],ETEL_K,211,0,vit1,DSA_DEF_TIMEOUT)) {
				return 1;
			}
			// = decode les coordonnes
			if (tel->axis_param[axisno].type==AXIS_HA) {
				/*
				tsl=etel_tsl(tel,&h,&m,&sec);
				angle=tsl-tel->ra0;
				angle+=720.;
				angle=angle-360*floor(angle/360);
				*/
				angle=tel->ra0;
			} else if (tel->axis_param[axisno].type==AXIS_DEC) {
				angle=tel->dec0;
			} else if (tel->axis_param[axisno].type==AXIS_AZ) {
				angle=0.; // a faire
			} else if (tel->axis_param[axisno].type==AXIS_ELEV) {
				angle=0.; // a faire
			} else if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
				angle=0.; // a faire
			}
			// = goto vers des coordonnes
			motorturns=tel->axis_param[axisno].sens*(angle-tel->axis_param[axisno].angleinit)/deg_per_tooth; // motorturn
			pos1=(int)(motorturns*uc_per_motorturn+tel->axis_param[axisno].posinit); // UC
			if (pos1<posmin)  {
				pos1+=(posmax+1);
			}
			if ((pos1>=posmin)&&(pos1<=posmax)) {
      		if (err = dsa_set_register_s(tel->drv[axisno],ETEL_K,210,0,pos1,DSA_DEF_TIMEOUT)) {
					return 1;
				}
			}
		}
		/* --- condition de fin de raliement ---*/
		if (tel->radec_goto_blocking==0) {
			break;
		} else {
			/* A loop is actived until the telescope is stopped */
			//tel_radec_coord(tel,coord0);
			dr=4*atan(1)/180.;
			etel_radec_coord(tel,1,NULL,angledeg0s,angleucs);
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				etel_radec_coord(tel,1,NULL,angledeg1s,angleucs);
				da=0.;
				for (k=0;k<3;k++) {
					da=da+fabs(asin(sin(angledeg1s[k]-angledeg0s[k]))/dr*3600.);
				}
				if (da<3.) {break;} // sortie avec un residu a 3 arcsec
				for (k=0;k<3;k++) {
					angledeg0s[k]=angledeg1s[k];
				}
				if (time_in>=time_out) {break;}
			}
		}
   	time_in0++;
		etel_radec_coord(tel,1,NULL,angledeg11s,angleucs);
		da=0.;
		for (k=0;k<3;k++) {
			da=da+fabs(asin(sin(angledeg11s[k]-angledeg00s[k]))/dr*3600.);
		}
		if (da<1000) {break;} // sortie avec un residu a 1000 arcsec !!!!
		for (k=0;k<3;k++) {
			angledeg00s[k]=angledeg11s[k];
		}
		if (time_in0>=time_out0) {break;}
	}
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
	/*
	int err;
   if (err = dsa_quick_stop_s(tel->drv[k], DSA_QS_PROGRAMMED_DEC, DSA_QS_BYPASS | DSA_QS_STOP_SEQUENCE, DSA_DEF_TIMEOUT)) {
	   mytel_error(tel,k,err);
		return 1;
	}
	*/
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
	int k,err;
	k=0;
   if (tel->radec_motor==1) {
      /* stop the motor */
		if (err = dsa_power_off_s(tel->drv[k], 10000)) {
			mytel_error(tel,k,err);
			return 1;
		}
   } else {
      /* start the motor */
		if (err = dsa_power_on_s(tel->drv[k], 10000)) {
			mytel_error(tel,k,err);
			return 1;
		}
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   int axisno,k;
   char angles[3][30];
	double angledegs[3];
	int angleucs[3];
	int voidangles[3];
   strcpy(result,"");
   /* --- lecture sur les axes valides ---*/
	for (k=0;k<3;k++) {
		voidangles[k]=(int)&angles[k];
	}
	etel_radec_coord(tel,0,voidangles,angledegs,angleucs);
	/* --- mise en forme du resultat ---*/
   if (tel->axis_param[0].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_HA) {
            strcat(result,angles[axisno]);
         }
      }
   }
   if (tel->axis_param[1].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_DEC) {
            strcat(result,angles[axisno]);
         }
      }
   } else {
      strcat(result," +00d00m00s");
   }
   if (tel->axis_param[2].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
            strcat(result,angles[axisno]);
         }
      }
   }
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   int axisno,k;
   char angles[3][30];
	double angledegs[3];
	int angleucs[3];
	int voidangles[3];
   strcpy(result,"");
   /* --- lecture sur les axes valides ---*/
	for (k=0;k<3;k++) {
		voidangles[k]=(int)&angles[k];
	}
	etel_radec_coord(tel,1,voidangles,angledegs,angleucs);
	/* --- mise en forme du resultat ---*/
   if (tel->axis_param[0].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_HA) {
            strcat(result,angles[axisno]);
         }
      }
   }
   if (tel->axis_param[1].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_DEC) {
            strcat(result,angles[axisno]);
         }
      }
   } else {
      strcat(result," +00d00m00s");
   }
   if (tel->axis_param[2].type!=AXIS_NOTDEFINED) {
      for (axisno=0;axisno<3;axisno++) {
         if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
            strcat(result,angles[axisno]);
         }
      }
   }
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
   /* Get the longitude */
   strcpy(ligne,tel->home);
   strcpy(ligne,tel->home0);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   /* Set the longitude */
   sprintf(tel->home,"GPS %f %s %f %f",longitude,ew,latitude,altitude);
   strcpy(tel->home0,tel->home);
   return 0;
}

int mytel_init_mount_default(struct telprop *tel,int mountno)
{
	if (mountno==0) {
		/* --- DEC special T193 ---*/
		tel->axis_param[0].posinit= 108175977; 
		tel->axis_param[0].angleinit=30.;
		tel->axis_param[0].teeth_per_turn=1;
		tel->axis_param[0].sens=-1;
		/* --- HA special T193 ---*/
		tel->axis_param[1].posinit=99793995;
		tel->axis_param[1].angleinit=0.;
		tel->axis_param[1].teeth_per_turn=1;
	}
	return 0;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */


//#define MOUCHARD_EVAL

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD_EVAL)
   FILE *f;
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD_EVAL)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout)
{
   int len,k;
   char car;
   len=(int)strlen(strin);
   if (len==0) {
      strout[0]='\0';
      return;
   }
   for (k=0;k<len;k++) {
      car=strin[k];
      if (car==decin) {
         car=decout;
      }
      strout[k]=car;
   }
   strout[k]='\0';
}

void mytel_error(struct telprop *tel,int axisno, int err)
{
   DSA_DRIVE *drv;
   drv=tel->drv[axisno];
   sprintf(tel->msg,"error %d: %s.\n", err, dsa_translate_error(err));
}

int etel_home(struct telprop *tel, char *home_default)
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

double etel_tsl(struct telprop *tel,int *h, int *m,int *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   etel_home(tel,"");
   libtel_GetCurrentUTCDate(tel->interp,ss);
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
   *sec=(int)atoi(tel->interp->result);
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(tel->interp->result); /* en degres */
   return tsl;
}

/* flagha=0 si on veut retourner en ascension droite */
/* flagha=1 si on veut retourner en angle horaire */
void etel_radec_coord(struct telprop *tel, int flagha, int *voidangles,double *angledegs,int *angleucs)
{
   double deg_per_tooth,angle,ra;
   int traits,interpo,axisno,err,val;
   int uc_per_motorturn,h,m,sec,pos;
   double motorturns,tsl;
	char s[128];
	char *angles;
   /* --- lecture sur les axes valides ---*/
   for (axisno=0;axisno<3;axisno++) {
		if (voidangles!=NULL) {
			angles=(char*)voidangles[axisno];
			strcpy(angles,"");
		}
		angleucs[axisno]=(int)0;
		angledegs[axisno]=(double)0;
      if (tel->axis_param[axisno].type==AXIS_NOTDEFINED) {
         continue;
      }
      deg_per_tooth=360./tel->axis_param[axisno].teeth_per_turn; // teeth/360deg
   	if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,239,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         traits=512;
      } else {
         traits=val;
      }
   	if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,241,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         interpo=1024;
      } else {
         interpo=val;
      }
      uc_per_motorturn=traits*interpo; // UC/motorturn or UC/tooth
   	if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,7,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
         pos=0;
      } else {
         pos=val;
      }
		angleucs[axisno]=pos;
      motorturns=1.*tel->axis_param[axisno].sens*(pos-tel->axis_param[axisno].posinit)/uc_per_motorturn; // motorturn
      angle=motorturns*deg_per_tooth+tel->axis_param[axisno].angleinit; // deg
      if (tel->axis_param[axisno].type==AXIS_HA) {
         tsl=etel_tsl(tel,&h,&m,&sec);
         ra=tsl-angle;
			if (flagha==1) {
	         ra=angle;
			}
			ra+=720.;
			ra=ra-360*floor(ra/360);
			angledegs[axisno]=ra;
			if (voidangles!=NULL) {
	         sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
				sprintf(angles,"%s ",tel->interp->result);
			}
         continue;
      }
      if (tel->axis_param[axisno].type==AXIS_DEC) {
         sprintf(s,"mc_angle2deg %f 90",angle); mytel_tcleval(tel,s);
			angledegs[axisno]=atof(tel->interp->result);
			if (voidangles!=NULL) {
				sprintf(s,"mc_angle2dms \"%f\" 90 zero 1 + string",angle); mytel_tcleval(tel,s);
				sprintf(angles,"%s ",tel->interp->result);
			}
         continue;
      }
      if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
			angle+=720.;
			angle=angle-360*floor(angle/360);
			angledegs[axisno]=angle;
			if (voidangles!=NULL) {
	         sprintf(s,"mc_angle2dms \"%f\" 360 zero 1 auto string",angle); mytel_tcleval(tel,s);
		      sprintf(angles,"%s ",tel->interp->result);
			}
         continue;
      }
   }
	return;
}