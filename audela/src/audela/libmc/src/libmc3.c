/* libmc3.c
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

#include "libmc.h"

int Cmd_mctcl_readhip(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Read the Hiparcos catalog                                                */
/****************************************************************************/
/*
set List_hip [mc_readhip c:/d/meo/hip_main.dat -double_stars 0 -plx_max 100 -mu_max 100 -mag_max 35 -mag_min 3 -dec_max 15 -dec_min -5 -max_nbstars 10]
*/
/****************************************************************************/
{
	char s[1024],filename[1024];
	int nstars,k,max_nbstars=0;
	double values[32];
	char flags[32];
	double equinox=2451545.00000,epoch=2448349.06250;
	mc_cata_astrom *hips;
   Tcl_DString dsptr;
   if(argc<2) {
      sprintf(s,"Usage: %s Filename ?-double_stars 0|1? ?-plx_max mas? ?-mu_max mas/yr? ?-mag_max mag? ?-mag_min mag? ?-dec_max deg? ?-dec_min deg? ?-max_nbstars int?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
		strcpy(flags,"0000000");
		values[0]=0;
		values[1]=200000;
		values[2]=200000;
		values[3]=24;
		values[4]=-24;
		values[5]=90;
		values[6]=-90;
	   Tcl_DStringInit(&dsptr);
		strcpy(filename,argv[1]);
		if (argc>=3) {
			for (k=2;k<argc-1;k++) {
				if (strcmp(argv[k],"-double_stars")==0) { flags[0]='1'; values[0]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-plx_max")==0)      { flags[1]='1'; values[1]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-mu_max")==0)       { flags[2]='1'; values[2]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-mag_max")==0)      { flags[3]='1'; values[3]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-mag_min")==0)      { flags[4]='1'; values[4]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-dec_max")==0)      { flags[5]='1'; values[5]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-dec_min")==0)      { flags[6]='1'; values[6]=atof(argv[k+1]); }
				if (strcmp(argv[k],"-max_nbstars")==0)  { max_nbstars=atoi(argv[k+1]); }
			}
		}
		hips=NULL;
		mc_readhip(filename,flags,values,&nstars,hips);
		if (nstars>0) {
			hips=(mc_cata_astrom*)calloc(nstars,sizeof(mc_cata_astrom));
			mc_readhip(filename,flags,values,&nstars,hips);
			if ((nstars>max_nbstars)&&(max_nbstars>0)) {
				nstars=max_nbstars;
			}
			for (k=0;k<nstars;k++) {
				sprintf(s,"%d ",hips[k].id);
				strcat(s,mc_d2s(hips[k].mag));
				strcat(s," ");
				strcat(s,mc_d2s(hips[k].ra));
				strcat(s," ");
				strcat(s,mc_d2s(hips[k].dec));
				strcat(s," ");
				strcat(s,mc_d2s(equinox));
				strcat(s," ");
				strcat(s,mc_d2s(epoch));
				strcat(s," ");
				strcat(s,mc_d2s(hips[k].mura));
				strcat(s," ");
				strcat(s,mc_d2s(hips[k].mudec));
				strcat(s," ");
				strcat(s,mc_d2s(hips[k].plx));
				Tcl_DStringAppendElement(&dsptr,s);
			}
		}
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
		free(hips);
	}
	return TCL_OK;
}

int Cmd_mctcl_horizon(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la ligne d'horizon                                              */
/****************************************************************************/
/*
mc_horizon Type_coords List_coords

Type_coords = "HADEC" ou "ALTAZ"

List_coords = {dec ha_rise ha_set} ou {az elev} (degrees)

Sortie : {az elev} pour az=0 à 360 par pas de 1 deg.

Exemple :

set res [mc_horizon {GPS 5 E 43 1230} ALTAZ { {0 0} {90 15} {135 15} {150 16} {170 20} {180 35} {190 20} {225 15} {270 10} }]

set ros(trireq,horizon,coords) ""
lappend ros(trireq,horizon,coords) [list -38 350 10]
lappend ros(trireq,horizon,coords) [list -30 [mc_angle2deg 23h00] [mc_angle2deg 2h55]]
lappend ros(trireq,horizon,coords) [list -15 [mc_angle2deg 20h50] [mc_angle2deg 4h50]]
lappend ros(trireq,horizon,coords) [list   0 [mc_angle2deg 19h35] [mc_angle2deg 5h30]]
lappend ros(trireq,horizon,coords) [list  20 [mc_angle2deg 19h30] [mc_angle2deg 7h00]]
lappend ros(trireq,horizon,coords) [list  30 [mc_angle2deg 19h10] [mc_angle2deg 8h15]]
lappend ros(trireq,horizon,coords) [list  40 [mc_angle2deg 16h35] [mc_angle2deg 8h50]]
set res [mc_horizon {GPS 5 E 43 1230} HADEC $ros(trireq,horizon,coords)]
set xs [lindex $res 0]
set ys [lindex $res 1]
::plotxy::plot $xs $ys r
*/
/****************************************************************************/
{
	char s[1024];
   Tcl_DString dsptr;

   if(argc<2) {
      sprintf(s,"Usage: %s Home Type_coords List_coords", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
		/* --- decode args ---*/
		mctcl_decode_horizon(interp,argv[1],argv[2],argv[3],&dsptr,NULL,NULL);
		/* === libere les pointeurs generaux === */
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	}
	return TCL_OK;
}

int Cmd_mctcl_nearesthip(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* List of the nearest stars in the Hiparcos catalog                        */
/****************************************************************************/
/*
set List_hip [mc_readhip c:/d/meo/hip_main.dat -double_stars 0 -plx_max 100 -mu_max 100 -mag_max 35 -mag_min 3 -dec_max 15 -dec_min -5 -max_nbstars 20]
mc_nearesthip 120.45 -60.23 $List_hip -max_nbstars 10
*/
/****************************************************************************/
{
	char s[1024];
	int nstars,k,max_nbstars=0;
	double equinox=2451545.00000,epoch=2448349.06250;
	mc_cata_astrom *hips;
	double ra,dec,ra0,dec0,c,cosd0,sind0;
	char **argvv=NULL;
	char **argvvv=NULL;
	int argcc,argccc;
	double *arr;
	int *karr,code,ks;
   Tcl_DString dsptr;

   if(argc<4) {
      sprintf(s,"Usage: %s Angle_Ra Angle_Dec List_Hip ?-max_nbstars nbstars?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	   Tcl_DStringInit(&dsptr);
      /* --- decode l'angle RA ---*/
      mctcl_decode_angle(interp,argv[1],&ra0);
      ra0*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[2],&dec0);
      dec0*=(DR);
		cosd0=cos(dec0);
		sind0=sin(dec0);
      /* --- decode le catalogue ---*/
      code=Tcl_SplitList(interp,argv[3],&argcc,&argvv);
		nstars=argcc;
		hips=(mc_cata_astrom*)calloc(nstars,sizeof(mc_cata_astrom));
		arr=(double*)calloc(nstars,sizeof(double));
		karr=(int*)calloc(nstars,sizeof(int));
		for (ks=0;ks<nstars;ks++) {
	      code=Tcl_SplitList(interp,argvv[ks],&argccc,&argvvv);
			if (argccc>=1) { hips[ks].id  = atoi(argvvv[0]); }
			if (argccc>=2) { hips[ks].mag = atof(argvvv[1]); }
			if (argccc>=3) { hips[ks].ra  = atof(argvvv[2]); }
			if (argccc>=4) { hips[ks].dec = atof(argvvv[3]); }
			if (argccc>=7) { hips[ks].mura = atoi(argvvv[6]); }
			if (argccc>=8) { hips[ks].mudec = atoi(argvvv[7]); }
			if (argccc>=9) { hips[ks].plx = atoi(argvvv[8]); }
			if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
			karr[ks]=ks;
	      /* --- sepangle ---*/
			ra= hips[ks].ra*(DR);
			dec= hips[ks].dec*(DR);
			c=(sind0*sin(dec)+cosd0*cos(dec)*cos(ra0-ra));
			if (c<-1.) {c=-1.;}
			if (c>1.) {c=1.;}
			c=acos(c);
			arr[ks]=c;
		}
	   if (argvv!=NULL) { Tcl_Free((char *) argvv); }
		/* --- decode les options ---*/
		if (argc>=6) {
			for (k=4;k<argc-1;k++) {
				if (strcmp(argv[k],"-max_nbstars")==0)  { max_nbstars=atoi(argv[k+1]); }
			}
		}
      /* --- tri sepangle croissant ---*/
		mc_quicksort_double(arr,0,nstars-1,karr);
      /* --- sortie des resultats ---*/
		if ((nstars>max_nbstars)&&(max_nbstars>0)) {
			nstars=max_nbstars;
		}
		for (ks=0;ks<nstars;ks++) {
			k=karr[ks];
			sprintf(s,"%d ",hips[k].id);
			strcat(s,mc_d2s(hips[k].mag));
			strcat(s," ");
			strcat(s,mc_d2s(hips[k].ra));
			strcat(s," ");
			strcat(s,mc_d2s(hips[k].dec));
			strcat(s," ");
			strcat(s,mc_d2s(equinox));
			strcat(s," ");
			strcat(s,mc_d2s(epoch));
			strcat(s," ");
			strcat(s,mc_d2s(hips[k].mura));
			strcat(s," ");
			strcat(s,mc_d2s(hips[k].mudec));
			strcat(s," ");
			strcat(s,mc_d2s(hips[k].plx));
			strcat(s," ");
			strcat(s,mc_d2s(arr[ks]/(DR)));
			Tcl_DStringAppendElement(&dsptr,s);
		}
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
		free(hips);
		free(arr);
		free(karr);
	}
	return TCL_OK;
}

int Cmd_mctcl_listamers(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Compute a list of amer positions to perform a regular grid for a pointing model */
/****************************************************************************/
/*
mc_listamers EQUATORIAL 10 4 now {GPS 5 E 43 1230}
mc_listamers ALTAZ 12 3 now {GPS 5 E 43 1230} 7.5 367.5 10 90

set List_hip [mc_readhip c:/d/meo/hip_main.dat -double_stars 0 -plx_max 100 -mu_max 100 -mag_max 35 -mag_min 3 -dec_min -45]
set n [llength $List_hip]

set coords [lindex [mc_listamers EQUATORIAL 10 4 now {GPS 5 E 43 1230}] 0]
set ra [lindex $coords 0]
set dec [lindex $coords 1]
set hip [mc_nearesthip $ra $dec $List_hip -max_nbstars 5]
mc_hip2tel [lindex $hip 0] now {GPS 5 E 43 1230} 101325 290
*/
{
	char s[1024];
	int type=0; // =0 equatorial, =1 altaz
	int naxis1,k1,naxis2,k2,k;
	double mini1,maxi1,mini2,maxi2,d1,d2,c1,c2;
   double rhocosphip=0.,rhosinphip=0.,longmpc=0.;
   double latitude,altitude,latrad,jd,ra,dec,ha,az,h;
   Tcl_DString dsptr;
	double *hazs,*helevs,*hdecs,*hha_rises,*hha_sets;
	int hnaz,hndec,valid;
	char **argvv=NULL,**argvvv=NULL;
	int argcc,argccc,code;

   if(argc<6) {
      sprintf(s,"Usage: %s type_axis naxis1 naxis2 Date Home ?mini1 maxi1 mini2 maxi2?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
	   Tcl_DStringInit(&dsptr);
      /* --- decode les coordonnees catalogue ---*/
		mc_strupr(argv[1],s);
		if (s[0]=='A') {
			type=1;
		}
		naxis1=atoi(argv[2]);
		naxis2=atoi(argv[3]);
      /* --- decode la Date ---*/
	  	mctcl_decode_date(interp,argv[4],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[5],&longmpc,&rhocosphip,&rhosinphip);
		mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
		latrad=latitude*(DR);
		/* --- limits ---*/
		mini1=0;
		maxi1=360.;
		if (type==1) {
			mini2=0.;
			maxi2=90.;
		} else {
			if (latitude>=0) {
				mini2=latitude-90.;
				maxi2=90.;
			} else {
				mini2=-90.;
				maxi2=90.+latitude;
			}
		}
		if (argc>9) {
			if (strcmp(argv[6],"*")!=0) { mini1=atof(argv[6]); }
			if (strcmp(argv[7],"*")!=0) { maxi1=atof(argv[7]); }
			if (strcmp(argv[8],"*")!=0) { mini2=atof(argv[8]); }
			if (strcmp(argv[9],"*")!=0) { maxi2=atof(argv[9]); }
		}
		/* --- horizon ---*/
		hnaz=0;
		hndec=0;
		if (argc>10) {
	      code=Tcl_SplitList(interp,argv[10],&argcc,&argvv);
			if (argcc>=5) {
				/* --- az --*/
				code=Tcl_SplitList(interp,argvv[0],&argccc,&argvvv);
				hnaz=argccc;
				hazs=(double*)calloc(hnaz,sizeof(double));
				for (k=0;k<hnaz;k++) {
					hazs[k]=atof(argvvv[k]);
				}
				if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
				/* --- elev --*/
				code=Tcl_SplitList(interp,argvv[1],&argccc,&argvvv);
				hnaz=argccc;
				helevs=(double*)calloc(hnaz,sizeof(double));
				for (k=0;k<hnaz;k++) {
					helevs[k]=atof(argvvv[k]);
				}
				if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
				/* --- dec --*/
				code=Tcl_SplitList(interp,argvv[2],&argccc,&argvvv);
				hndec=argccc;
				hdecs=(double*)calloc(hndec,sizeof(double));
				for (k=0;k<hndec;k++) {
					hdecs[k]=atof(argvvv[k]);
				}
				if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
				/* --- ha_set --*/
				code=Tcl_SplitList(interp,argvv[3],&argccc,&argvvv);
				hndec=argccc;
				hha_sets=(double*)calloc(hndec,sizeof(double));
				for (k=0;k<hndec;k++) {
					hha_sets[k]=atof(argvvv[k]);
				}
				if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
				/* --- ha_rise --*/
				code=Tcl_SplitList(interp,argvv[4],&argccc,&argvvv);
				hndec=argccc;
				hha_rises=(double*)calloc(hndec,sizeof(double));
				for (k=0;k<hndec;k++) {
					hha_rises[k]=atof(argvvv[k]);
				}
				if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
			}
			if (argvv!=NULL) { Tcl_Free((char *) argvv); }
		}
		d1=(maxi1-mini1)/naxis1;
		d2=(maxi2-mini2)/naxis2;
		for (k1=0;k1<naxis1;k1++) {
			c1=mini1+d1*(0.5+k1);
			for (k2=0;k2<naxis2;k2++) {
				c2=mini2+d2*(0.5+k2);
				if (type==0) {
					ha=c1*(DR);
					dec=c2*(DR);
					mc_hd2ad(jd,longmpc,ha,&ra);
					mc_hd2ah(ha,dec,latrad,&az,&h);
				} else {
					az=c1*(DR);
					h=c2*(DR);
					mc_ah2hd(az,h,latrad,&ha,&dec);
					mc_hd2ad(jd,longmpc,ha,&ra);
				}
				ra/=(DR);
				dec/=(DR);
				ha/=(DR);
				az/=(DR);
				h/=(DR);
				valid=1;
				if (hnaz>0) {
					/* --- condition sur l'elevation ---*/
					for (k=0;k<hnaz-1;k++) {
						if ((az>hazs[k])&&(az<=hazs[k+1])) {
							if (h<helevs[k]) { 
								valid=0; 
							}
							break;
						}
					}
					/* --- condition sur l'angle horaire ---*/
					for (k=0;k<hndec-1;k++) {
						if ((dec>hdecs[k])&&(dec<=hdecs[k+1])) {
							if ((ha<=hha_rises[k])&&(ha>=hha_sets[k])) {
								valid=0; 
							}
							break;
						}
					}
				}
				if ((h>0)&&(valid==1)) {
					strcpy(s,"");
					strcat(s,mc_d2s(ra));
					strcat(s," ");
					strcat(s,mc_d2s(dec));
					strcat(s," ");
					strcat(s,mc_d2s(ha));
					strcat(s," ");
					strcat(s,mc_d2s(az));
					strcat(s," ");
					strcat(s,mc_d2s(h));
					Tcl_DStringAppendElement(&dsptr,s);
				}
			}
		}
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
		if (hnaz>0) {
			free(hazs);
			free(helevs);
			free(hdecs);
			free(hha_rises);
			free(hha_sets);
		}
	}
	return TCL_OK;
}

int Cmd_mctcl_hip2tel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convert (RA,DEC) coordinates into telescope coordinates                  */
/****************************************************************************/
/*
mc_hip2tel {0 2.5 10 40 J2000 J2000 0 0 0} now {GPS 5 E 43 1230} 101325 290

List_coords = {id mag ra dec equinox epoch mura mudec plx}
Date
Home
Pressure 101325
Temperature 290
List_ModelSymbols
List_ModelValues
*/
{
	char s[1024];
	double equinox=2451545.00000,epoch=2448349.06250;
	mc_cata_astrom hips;
	int code,argcc;
	char **argvv=NULL;
	double jd,longmpc;
	mc_modpoi_matx *matx=NULL; /* 2*nb_star */
	mc_modpoi_vecy *vecy=NULL; /* nb_coef */
	int nb_coef,nb_star,k;
   double rhocosphip=0.,rhosinphip=0.;
   double latitude,altitude,latrad;
	double ra,cosdec,mura,mudec,parallax,temperature,pressure;
	double dec,asd2,dec2;
	double ha,az,h,ddec=0.,dha=0.,refraction=0.;
	double dh=0.,daz=0.;
	double rat,dect,hat,ht,azt,dra;

   if(argc<4) {
      sprintf(s,"Usage: %s List_coords Date_UTC Home Pressure Temperature ?List_ModelSymbols List_ModelValues?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode les coordonnees catalogue ---*/
      code=Tcl_SplitList(interp,argv[1],&argcc,&argvv);
		if (argcc>8) {
			hips.id  = atoi(argvv[0]);
			hips.mag = atof(argvv[1]);
			hips.ra  = atof(argvv[2]);
			hips.dec = atof(argvv[3]);
	  	   mctcl_decode_date(interp,argvv[4],&equinox);
	  	   mctcl_decode_date(interp,argvv[5],&epoch);
			hips.mura = atoi(argvv[6]);
			hips.mudec = atoi(argvv[7]);
			hips.plx = atoi(argvv[8]);
			if (argvv!=NULL) { Tcl_Free((char *) argvv); }
		} else {
			// traite l'erreur
			return TCL_ERROR;
		}
      /* --- decode la Date ---*/
	  	mctcl_decode_date(interp,argv[2],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[3],&longmpc,&rhocosphip,&rhosinphip);
		mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
		latrad=latitude*(DR);
		/* --- Pressure ---*/
		pressure=atof(argv[4]);
		/* --- Temperature ---*/
		temperature=atof(argv[5]);
		/* --- decode le Modele de pointage ---*/
		nb_coef=0;
		if (argc>=8) {
			code=Tcl_SplitList(interp,argv[6],&argcc,&argvv);
			if (argcc>0) {
				nb_coef=argcc;
				vecy=(mc_modpoi_vecy*)calloc(nb_coef,sizeof(mc_modpoi_vecy));
				for (k=0;k<argcc;k++) {
					vecy[k].k=k;
					strcpy(vecy[k].type,argvv[k]);
				}
				if (argvv!=NULL) { Tcl_Free((char *) argvv); }
				code=Tcl_SplitList(interp,argv[7],&argcc,&argvv);
				if (argcc!=nb_coef) {
					// Traite l'erreur nb_symbol == nb_coef
					return TCL_ERROR;
				}
				for (k=0;k<argcc;k++) {
					vecy[k].coef=atof(argvv[k]);
				}
				if (argvv!=NULL) { Tcl_Free((char *) argvv); }
			} else {
				if (argvv!=NULL) { Tcl_Free((char *) argvv); }
			}
		}
		/* === CALCULS === */
      ra=hips.ra*(DR);
      dec=hips.dec*(DR);
		cosdec=cos(dec);
		mura=hips.mura*1e-3/86400/cosdec;
		mudec=hips.mudec*1e-3/86400;
		parallax=hips.plx;
		/* --- aberration annuelle ---*/
		mc_aberration_annuelle(jd,ra,dec,&asd2,&dec2,1);
		ra=asd2;
		dec=dec2;
		/* --- calcul de mouvement propre ---*/
		ra+=(jd-epoch)/365.25*mura;
		dec+=(jd-epoch)/365.25*mudec;
		/* --- calcul de la precession ---*/
		mc_precad(equinox,ra,dec,jd,&asd2,&dec2);
		ra=asd2;
		dec=dec2;
		/* --- correction de parallaxe stellaire*/
		if (parallax>0) {
		   mc_parallaxe_stellaire(jd,ra,dec,&asd2,&dec2,parallax);
			ra=asd2;
			dec=dec2;
		}
		/* --- correction de nutation */
		mc_nutradec(jd,ra,dec,&asd2,&dec2,1);
		ra=asd2;
		dec=dec2;
		/* --- aberration de l'aberration diurne*/
		mc_aberration_diurne(jd,ra,dec,longmpc,rhocosphip,rhosinphip,&asd2,&dec2,1);
		ra=asd2;
		dec=dec2;
		/* --- coordonnees horizontales---*/
		mc_ad2hd(jd,longmpc,ra,&ha);
		mc_hd2ah(ha,dec,latrad,&az,&h);
		/* --- refraction ---*/
		mc_refraction(h,1,temperature,pressure,&refraction);
		h+=refraction;
		mc_ah2hd(az,h,latrad,&ha,&dec);
		rat=ra;
		dect=dec;
		hat=ha;
		ht=h;
		azt=az;
		/* --- Modele de pointage ---*/
		if (nb_coef>0) {
			nb_star=1;
			matx=(mc_modpoi_matx*)malloc(2*nb_star*nb_coef*sizeof(mc_modpoi_matx));
			/* --- altaz corrections ---*/
			daz=mc_modpoi_addobs_az(az,h,nb_coef,vecy,matx);
			dh=mc_modpoi_addobs_h(az,h,nb_coef,vecy,matx);
			/* --- hadec corrections ---*/
			dha=mc_modpoi_addobs_ha(ha,dec,latrad,nb_coef,vecy,matx);
			ddec=mc_modpoi_addobs_dec(ha,dec,latrad,nb_coef,vecy,matx);
			/* --- corrections pure EQU of coordinates ---*/
			if (((dha!=0)||(ddec!=0))&&(daz==0)&&(dh==0)) {
				ha=hat+dha/60*(DR);
				dec=dect+ddec/60*(DR);
				if (dec>PISUR2)  { dec=PISUR2-(dec-PISUR2); ha+=(PI); }
				if (dec<-PISUR2) { dec=-PISUR2+(-PISUR2-dec); ha+=(PI); }
			   ha=fmod(4*PI+ha,2*PI);
				mc_hd2ah(ha,dec,latrad,&az,&h);
				mc_hd2ad(jd,longmpc,ha,&ra);
				daz=az-azt;
				if (daz<-PI) { daz+=2*(PI); }
				if (daz>PI)  { daz-=2*(PI); }
				dh=h-ht;
				dra=ra-rat;
				if (dra<-PI) { dra+=2*(PI); }
				if (dra>PI)  { dra-=2*(PI); }
			}
			/* --- corrections pure ALTAZ of coordinates ---*/
			if (((daz!=0)||(dh!=0))&&(dha==0)&&(ddec==0)) {
				az=azt+daz/60*(DR);
				h=ht+dh/60*(DR);
				if (h>PISUR2)  { h=PISUR2-(h-PISUR2); az+=(PI); }
				if (h<-PISUR2) { h=-PISUR2+(-PISUR2-h); az+=(PI); }
			   az=fmod(4*PI+az,2*PI);
				mc_ah2hd(az,h,latrad,&ha,&dec);
				mc_hd2ad(jd,longmpc,ha,&ra);
				dha=ha-hat;
				if (dha<-PI) { dha+=2*(PI); }
				if (dha>PI)  { dha-=2*(PI); }
				ddec=dec-dect;
				dra=ra-rat;
				if (dra<-PI) { dra+=2*(PI); }
				if (dra>PI)  { dra-=2*(PI); }
			}
			/* --- free pointers ---*/
			if (matx!=NULL) { free(matx); }
			if (vecy!=NULL) { free(vecy); }
		}
		strcpy(s,"");
		strcat(s,mc_d2s(rat/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(dect/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(hat/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(azt/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(ht/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(dra/60));
		strcat(s," ");
		strcat(s,mc_d2s(ddec/60));
		strcat(s," ");
		strcat(s,mc_d2s(dha/60));
		strcat(s," ");
		strcat(s,mc_d2s(daz/60));
		strcat(s," ");
		strcat(s,mc_d2s(dh/60));
		strcat(s," ");
		strcat(s,mc_d2s(ra/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(dec/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(ha/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(az/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(h/(DR)));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
	}
	return TCL_OK;
}

int Cmd_mctcl_tel2cat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convert telescope coordinates into (RA,DEC)                              */
/****************************************************************************/
/*
mc_tel2cat {12h 36d} EQUATORIAL now {GPS 5 E 43 1230} 101325 290

List_coords = {ra dec}
Type
Date
Home
Pressure 101325
Temperature 290
List_ModelSymbols
List_ModelValues
*/
{
	char s[1024];
	double equinox=2451545.00000;
	int code,argcc;
	char **argvv=NULL;
	double jd,longmpc;
	mc_modpoi_matx *matx=NULL; /* 2*nb_star */
	mc_modpoi_vecy *vecy=NULL; /* nb_coef */
	int nb_coef,nb_star,k;
   double rhocosphip=0.,rhosinphip=0.;
   double latitude,altitude,latrad;
	double ra,temperature,pressure;
	double dec,asd2,dec2;
	double ha,az,h,ddec=0.,dha=0.,refraction=0.;
	double dh=0.,daz=0.;
	int type=0;
	double az0,ra0,dec0,h0,ha0;

   if(argc<5) {
      sprintf(s,"Usage: %s Coords TypeObs Date_UTC Home Pressure Temperature ?Type List_ModelSymbols List_ModelValues?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode les coordonnees catalogue ---*/
      code=Tcl_SplitList(interp,argv[1],&argcc,&argvv);
		if (argcc>1) {
			/* --- decode l'angle RA ou AZ ---*/
			mctcl_decode_angle(interp,argvv[0],&ra0);
			ra0*=(DR);
			az0=ra0;
			ha0=ra0;
			/* --- decode l'angle DEC ou ELEV ---*/
			mctcl_decode_angle(interp,argvv[1],&dec0);
			dec0*=(DR);
			h0=dec0;
			if (argvv!=NULL) { Tcl_Free((char *) argvv); }
		} else {
			// traite l'erreur
			return TCL_ERROR;
		}
      /* --- decode le type de coordonnees d'entree ---*/
		mc_strupr(argv[2],s);
		if (s[0]=='A') {
			type=1;
		}
		if (s[0]=='H') {
			type=2;
		}
      /* --- decode la Date ---*/
	  	mctcl_decode_date(interp,argv[3],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[4],&longmpc,&rhocosphip,&rhosinphip);
		mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
		latrad=latitude*(DR);
		/* --- Pressure ---*/
		pressure=atof(argv[5]);
		/* --- Temperature ---*/
		temperature=atof(argv[6]);
		/* --- decode le Modele de pointage ---*/
		nb_coef=0;
		if (argc>=9) {
			code=Tcl_SplitList(interp,argv[7],&argcc,&argvv);
			if (argcc>0) {
				nb_coef=argcc;
				vecy=(mc_modpoi_vecy*)calloc(nb_coef,sizeof(mc_modpoi_vecy));
				for (k=0;k<argcc;k++) {
					vecy[k].k=k;
					strcpy(vecy[k].type,argvv[k]);
				}
				if (argvv!=NULL) { Tcl_Free((char *) argvv); }
				code=Tcl_SplitList(interp,argv[8],&argcc,&argvv);
				if (argcc!=nb_coef) {
					// Traite l'erreur nb_symbol == nb_coef
					return TCL_ERROR;
				}
				for (k=0;k<argcc;k++) {
					vecy[k].coef=atof(argvv[k]);
				}
				if (argvv!=NULL) { Tcl_Free((char *) argvv); }
			} else {
				if (argvv!=NULL) { Tcl_Free((char *) argvv); }
			}
		}
		if (type==0) {
			mc_ad2hd(jd,longmpc,ra0,&ha0);
		}
		ha=ha0; az=az0; h=h0; dec=dec0; ra=ra0;
		/* --- Modele de pointage ---*/
		if (nb_coef>0) {
			nb_star=1;
			matx=(mc_modpoi_matx*)malloc(2*nb_star*nb_coef*sizeof(mc_modpoi_matx));
			if (type==1) {
				/* --- altaz corrections ---*/
				daz=mc_modpoi_addobs_az(az,h,nb_coef,vecy,matx);
				dh=mc_modpoi_addobs_h(az,h,nb_coef,vecy,matx);
				az=az0-daz/60*(DR);
				h=h0-dh/60*(DR);
				daz=mc_modpoi_addobs_az(az,h,nb_coef,vecy,matx);
				dh=mc_modpoi_addobs_h(az,h,nb_coef,vecy,matx);
				az=az0-daz/60*(DR);
				h=h0-dh/60*(DR);
				if (h>PISUR2)  { h=PISUR2-(h-PISUR2); az+=(PI); }
				if (h<-PISUR2) { h=-PISUR2+(-PISUR2-h); az+=(PI); }
			   az=fmod(4*PI+az,2*PI);
				mc_ah2hd(az,h,latrad,&ha,&dec);
				mc_hd2ad(jd,longmpc,ha,&ra);
			}
			if ((type==0)||(type==2)) {
				/* --- hadec corrections ---*/
				dha=mc_modpoi_addobs_ha(ha,dec,latrad,nb_coef,vecy,matx);
				ddec=mc_modpoi_addobs_dec(ha,dec,latrad,nb_coef,vecy,matx);
				ha=ha0-dha/60*(DR);
				dec=dec0-ddec/60*(DR);
				dha=mc_modpoi_addobs_ha(ha,dec,latrad,nb_coef,vecy,matx);
				ddec=mc_modpoi_addobs_dec(ha,dec,latrad,nb_coef,vecy,matx);
				ha=ha0-dha/60*(DR);
				dec=dec0-ddec/60*(DR);
				if (dec>PISUR2)  { dec=PISUR2-(dec-PISUR2); ha+=(PI); }
				if (dec<-PISUR2) { dec=-PISUR2+(-PISUR2-dec); ha+=(PI); }
			   ha=fmod(4*PI+ha,2*PI);
				mc_hd2ah(ha,dec,latrad,&az,&h);
				mc_hd2ad(jd,longmpc,ha,&ra);
			}
			/* --- free pointers ---*/
			if (matx!=NULL) { free(matx); }
			if (vecy!=NULL) { free(vecy); }
		}
		/* === CALCULS === */
		/* --- refraction ---*/
		mc_refraction(h,-1,temperature,pressure,&refraction);
		h-=refraction;
		/* --- coordonnees equatoriales ---*/
		mc_hd2ad(jd,longmpc,ha,&ra);
		ra0=ra;
		dec0=dec;
		/* --- correction de nutation */
		mc_nutradec(jd,ra,dec,&asd2,&dec2,-1);
		ra=asd2;
		dec=dec2;
		/* --- aberration de l'aberration diurne*/
		mc_aberration_diurne(jd,ra,dec,longmpc,rhocosphip,rhosinphip,&asd2,&dec2,-1);
		/* --- calcul de la precession ---*/
		mc_precad(jd,ra,dec,equinox,&asd2,&dec2);
		ra=asd2;
		dec=dec2;
		/* --- aberration annuelle ---*/
		mc_aberration_annuelle(jd,ra,dec,&asd2,&dec2,-1);
		ra=asd2;
		dec=dec2;
		//
		strcpy(s,"");
		strcat(s,mc_d2s(ra/(DR)));
		strcat(s," ");
		strcat(s,mc_d2s(dec/(DR)));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
	}
	return TCL_OK;
}

int Cmd_mctcl_compute_matrix_modpoi(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Compute the pointing model from an observation file                      */
/****************************************************************************/
/*
mc_compute_modpoi $decalages ALTAZ $home {IA IE NPAE CA AN AW ACEC ECEC ACES ECES NRX NRY ACEC2 ACES2 ACEC3 ACES3 AN2 AW2 AN3 AW3 ACEC4 ACES4 AN4 AW4 ACEC5 ACES5 AN5 AW5 ACEC6 ACES6 AN6 AW6}

ListeObs {id jd coord1 coord2 dcoord1 dcoord2 pressure temperature}
TypeObs EQUATORIAL || ALTAZ
Home
List_ModelSymbols
*/
{
	char s[1024];
	int code,argcc,argccc;
	char **argvv=NULL,**argvvv=NULL;
	double longmpc;
	mc_modpoi_matx *matx=NULL; /* 2*nb_star */
	mc_modpoi_vecy *vecy=NULL; /* nb_coef */
	int nb_coef,nb_star,k,kc;
   double rhocosphip=0.,rhosinphip=0.;
   double latitude,altitude,latrad;
	int type,pb,desc[4],kmax=4,nb_desc;
	double *coord1s=NULL,*coord2s=NULL;
	double *dcoord1s=NULL,*dcoord2s=NULL;
   Tcl_DString dsptr_mat;
   Tcl_DString dsptr_vec;
   Tcl_DString dsptr_vecw;

   if(argc<4) {
      sprintf(s,"Usage: %s ListeObs TypeObs Home List_ModelSymbols ?DescObs?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
		/* --- decode la liste du descripteur des observations ---*/
		desc[0]=0; // az ou ha
		desc[1]=1; // elev ou dec
		desc[2]=2; // daz ou dha
		desc[3]=3; // delev ou ddec
		if (argc>5) {
			code=Tcl_SplitList(interp,argv[5],&argcc,&argvv);
			nb_desc=argcc;
			if (nb_desc>=4) {
				desc[0]=atoi(argvv[0]);
				desc[1]=atoi(argvv[1]);
				desc[2]=atoi(argvv[2]);
				desc[3]=atoi(argvv[3]);
			}
			if (argvv!=NULL) { Tcl_Free((char *) argvv); }
		}
		for (k=0;k<4;k++) {
			if (desc[k]>kmax) {kmax=desc[k];}
		}
		/* --- decode la liste des observations ---*/
		nb_star=0;
		code=Tcl_SplitList(interp,argv[1],&argcc,&argvv);
		nb_star=argcc;
		pb=0;
		if (nb_star>0) {
			coord1s=(double*)calloc(nb_star,sizeof(double));
			coord2s=(double*)calloc(nb_star,sizeof(double));
			dcoord1s=(double*)calloc(nb_star,sizeof(double));
			dcoord2s=(double*)calloc(nb_star,sizeof(double));
			for (k=0;k<nb_star;k++) {
				code=Tcl_SplitList(interp,argvv[k],&argccc,&argvvv);
				if (argccc<kmax) {
					// traiter l'erreur
					pb=1;
					if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
					break;
				}
				coord1s[k]=atof(argvvv[desc[0]])*(DR);
				coord2s[k]=atof(argvvv[desc[1]])*(DR);
				dcoord1s[k]=atof(argvvv[desc[2]]);
				dcoord2s[k]=atof(argvvv[desc[3]]);
				if (argvvv!=NULL) { Tcl_Free((char *) argvvv); }
			}
		} else {
			// traiter l'erreur
			return TCL_ERROR;
		}
		if (pb==1) {
			// traiter l'erreur
			return TCL_ERROR;
		}
		if (argvv!=NULL) { Tcl_Free((char *) argvv); }
      /* --- decode le type de coordonnees d'entree ---*/
		mc_strupr(argv[2],s);
		if (s[0]=='A') {
			type=1;
		}
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[3],&longmpc,&rhocosphip,&rhosinphip);
		mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
		latrad=latitude*(DR);
		/* --- decode les termes du modele de pointage ---*/
		nb_coef=0;
		code=Tcl_SplitList(interp,argv[4],&argcc,&argvv);
		nb_coef=argcc;
		if (nb_coef>0) {
			vecy=(mc_modpoi_vecy*)calloc(nb_coef,sizeof(mc_modpoi_vecy));
			for (k=0;k<argcc;k++) {
				vecy[k].k=k;
				strcpy(vecy[k].type,argvv[k]);
				vecy[k].coef=0;
			}
		}
		if (argvv!=NULL) { Tcl_Free((char *) argvv); }
		/* --- analyse les observations ---*/
	   Tcl_DStringInit(&dsptr_mat);
	   Tcl_DStringInit(&dsptr_vec);
	   Tcl_DStringInit(&dsptr_vecw);
		//matx=(mc_modpoi_matx*)malloc(2*nb_star*nb_coef*sizeof(mc_modpoi_matx));
		matx=(mc_modpoi_matx*)malloc(nb_coef*sizeof(mc_modpoi_matx));
		Tcl_DStringAppend(&dsptr_vec,"{",-1);
		Tcl_DStringAppend(&dsptr_vecw,"{",-1);
		Tcl_DStringAppend(&dsptr_mat,"{",-1);
		for (k=0;k<nb_star;k++) {
			if (type==0) {
				/* --- ha corrections ---*/
				mc_modpoi_addobs_ha(coord1s[k],coord2s[k],latrad,nb_coef,vecy,matx);
				Tcl_DStringAppend(&dsptr_mat,"{",-1);
				for (kc=0;kc<nb_coef;kc++) {
					sprintf(s,"%s ",mc_d2s(matx[k].coef));
					Tcl_DStringAppend(&dsptr_mat,s,-1);
				}
				Tcl_DStringAppend(&dsptr_mat,"} ",-1);
				sprintf(s,"%s ",mc_d2s(dcoord1s[k]));
				Tcl_DStringAppend(&dsptr_vec,s,-1);
				sprintf(s,"%s ",mc_d2s(0.5));
				Tcl_DStringAppend(&dsptr_vecw,s,-1);
				/* --- dec corrections ---*/
				mc_modpoi_addobs_dec(coord1s[k],coord2s[k],latrad,nb_coef,vecy,matx);
				Tcl_DStringAppend(&dsptr_mat,"{",-1);
				for (kc=0;kc<nb_coef;kc++) {
					sprintf(s,"%s ",mc_d2s(matx[k].coef));
					Tcl_DStringAppend(&dsptr_mat,s,-1);
				}
				Tcl_DStringAppend(&dsptr_mat,"} ",-1);
				sprintf(s,"%s ",mc_d2s(dcoord2s[k]));
				Tcl_DStringAppend(&dsptr_vec,s,-1);
				sprintf(s,"%s ",mc_d2s(0.5));
				Tcl_DStringAppend(&dsptr_vecw,s,-1);
			}
			if (type==1) {
				/* --- az corrections ---*/
				for (kc=0;kc<nb_coef;kc++) {
					matx[kc].coef=0;
				}
				mc_modpoi_addobs_az(coord1s[k],coord2s[k],nb_coef,vecy,matx);
				Tcl_DStringAppend(&dsptr_mat,"{",-1);
				for (kc=0;kc<nb_coef;kc++) {
					sprintf(s,"%s ",mc_d2s(matx[kc].coef));
					Tcl_DStringAppend(&dsptr_mat,s,-1);
				}
				Tcl_DStringAppend(&dsptr_mat,"} ",-1);
				sprintf(s,"%s ",mc_d2s(dcoord1s[k]));
				Tcl_DStringAppend(&dsptr_vec,s,-1);
				sprintf(s,"%s ",mc_d2s(0.5));
				Tcl_DStringAppend(&dsptr_vecw,s,-1);
				/* --- elev corrections ---*/
				for (kc=0;kc<nb_coef;kc++) {
					matx[kc].coef=0;
				}
				mc_modpoi_addobs_h(coord1s[k],coord2s[k],nb_coef,vecy,matx);
				Tcl_DStringAppend(&dsptr_mat,"{",-1);
				for (kc=0;kc<nb_coef;kc++) {
					sprintf(s,"%s ",mc_d2s(matx[kc].coef));
					Tcl_DStringAppend(&dsptr_mat,s,-1);
				}
				Tcl_DStringAppend(&dsptr_mat,"} ",-1);
				sprintf(s,"%s ",mc_d2s(dcoord2s[k]));
				Tcl_DStringAppend(&dsptr_vec,s,-1);
				sprintf(s,"%s ",mc_d2s(0.5));
				Tcl_DStringAppend(&dsptr_vecw,s,-1);
			}

		}
		Tcl_DStringAppend(&dsptr_vec,"} ",-1);
		Tcl_DStringAppend(&dsptr_vecw,"} ",-1);
		Tcl_DStringAppend(&dsptr_mat,"} ",-1);
		Tcl_DStringAppend(&dsptr_mat,dsptr_vec.string,-1);
		Tcl_DStringAppend(&dsptr_mat,dsptr_vecw.string,-1);
      Tcl_DStringResult(interp,&dsptr_mat);
      Tcl_DStringFree(&dsptr_mat);
      Tcl_DStringFree(&dsptr_vec);
      Tcl_DStringFree(&dsptr_vecw);
		free(matx);
		free(vecy);
		free(coord1s);
		free(coord2s);
		free(dcoord1s);
		free(dcoord2s);
	}
	return TCL_OK;
}

int Cmd_mctcl_nextnight(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
/*
mc_nextnight now {GPS 5 E 43 1230} ?elevset? ?elevtwilight?
*
* Always jdset<jdrise
*/
/****************************************************************************/
{
	double jd,longmpc, rhocosphip, rhosinphip,jdprev,jdset,jdrise,jddusk,jddawn,jdnext,elev_set=0.,elev_twilight;
	char s[1024];
   Tcl_DString dsptr;

   if(argc<3) {
      sprintf(s,"Usage: %s Date Home ?elev_sun_set? ?elev_sun_twilight?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode la date ---*/
	  	mctcl_decode_date(interp,argv[1],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[2],&longmpc,&rhocosphip,&rhosinphip);
      /* --- decode l'angle elev_set ---*/
		if (argc>=4) {
			mctcl_decode_angle(interp,argv[3],&elev_set);
		}
		elev_twilight=elev_set;
      /* --- decode l'angle elev_set ---*/
		if (argc>=5) {
			mctcl_decode_angle(interp,argv[4],&elev_twilight);
		}
		/* --- appel aux calculs ---*/
		mc_nextnight1(jd,longmpc,rhocosphip,rhosinphip,elev_set,elev_twilight,&jdprev,&jdset,&jdrise,&jddusk,&jddawn,&jdnext);
	   Tcl_DStringInit(&dsptr);
		sprintf(s,"%s ",mc_d2s(jdprev));
		Tcl_DStringAppend(&dsptr,s,-1);
		sprintf(s,"%s ",mc_d2s(jdset));
		Tcl_DStringAppend(&dsptr,s,-1);
		sprintf(s,"%s ",mc_d2s(jddusk));
		Tcl_DStringAppend(&dsptr,s,-1);
		sprintf(s,"%s ",mc_d2s(jddawn));
		Tcl_DStringAppend(&dsptr,s,-1);
		sprintf(s,"%s ",mc_d2s(jdrise));
		Tcl_DStringAppend(&dsptr,s,-1);
		sprintf(s,"%s ",mc_d2s(jdnext));
		Tcl_DStringAppend(&dsptr,s,-1);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	}	
	return TCL_OK;
}

int Cmd_mctcl_obsconditions(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
/*
mc_obsconditions now {GPS 5 E 43 1230} {  { {AXE_TYPE 0} {AXES_0 2009-12-12T00:00:00 80 +26} {AXES_1 2009-12-31T00:00:00 100 -15} } } [expr 60./86400] "c:/d/audela/dev/test.txt"
*/
/****************************************************************************/
{
	double jd,longmpc, rhocosphip, rhosinphip,djd;
	char s[1024];
	mc_HORIZON_ALTAZ *horizon_altaz=NULL;
	mc_HORIZON_HADEC *horizon_hadec=NULL;
	mc_OBJECTDESCR *objectdescr=NULL;
	int nobj=0;

   if(argc<5) {
      sprintf(s,"Usage: %s Date Home ListCandidates step_day output_filename ?type_Horizon Horizon?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode la date ---*/
	  	mctcl_decode_date(interp,argv[1],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[2],&longmpc,&rhocosphip,&rhosinphip);
		/* --- decode les sequences ---*/
		mctcl_decode_sequences(interp,&argv[3],&nobj,&objectdescr);
		/* --- decode le pas de calcul (jours) ---*/
		djd=atof(argv[4]);
		if (djd<=0) {
			djd=60./86400.;
		}
		/* --- decode l'horizon ---*/
		if (argc>7) {
			mctcl_decode_horizon(interp,argv[2],argv[6],argv[7],NULL,&horizon_altaz,&horizon_hadec);
		} else {
			mctcl_decode_horizon(interp,argv[2],"ALTAZ","{0 0} {90 0} {180 0} {270 0} {365 0}",NULL,&horizon_altaz,&horizon_hadec);
		}
		/* --- appel aux calculs ---*/
		mc_obsconditions1(jd,longmpc,rhocosphip,rhosinphip,horizon_altaz,horizon_hadec,nobj,objectdescr,djd,argv[5]);
		free(horizon_altaz);
		free(horizon_hadec);
		free(objectdescr);
	}	return TCL_OK;
}

int Cmd_mctcl_scheduler(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
/*
mc_scheduler now {GPS 5 E 43 1230} {  { {AXE_TYPE 0} {AXES_0 now 14h34m 26d45'} {AXES_1 now 14h34m -16d45'} } { {AXE_TYPE 0} {AXES_0 now 15h +16d} }  } 
*/
/****************************************************************************/
{
	double jd,longmpc, rhocosphip, rhosinphip;
	char s[1024];
	mc_HORIZON_ALTAZ *horizon_altaz=NULL;
	mc_HORIZON_HADEC *horizon_hadec=NULL;
	mc_OBJECTDESCR *objectdescr=NULL;
	int nobj=0;

   if(argc<3) {
      sprintf(s,"Usage: %s Date Home ListCandidates ?type_Horizon Horizon?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode la date ---*/
	  	mctcl_decode_date(interp,argv[1],&jd);
      /* --- decode le Home ---*/
      longmpc=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      mctcl_decode_topo(interp,argv[2],&longmpc,&rhocosphip,&rhosinphip);
		/* --- decode les sequences ---*/
		mctcl_decode_sequences(interp,&argv[3],&nobj,&objectdescr);
		/* --- decode l'horizon ---*/
		if (argc>5) {
			mctcl_decode_horizon(interp,argv[2],argv[4],argv[5],NULL,&horizon_altaz,&horizon_hadec);
		} else {
			mctcl_decode_horizon(interp,argv[2],"ALTAZ","{0 0} {90 0} {180 0} {270 0} {365 0}",NULL,&horizon_altaz,&horizon_hadec);
		}
		/* --- appel aux calculs ---*/
		mc_scheduler1(jd,longmpc,rhocosphip,rhosinphip,horizon_altaz,horizon_hadec,nobj,objectdescr);
		free(horizon_altaz);
		free(horizon_hadec);
		free(objectdescr);
	}	return TCL_OK;
}

