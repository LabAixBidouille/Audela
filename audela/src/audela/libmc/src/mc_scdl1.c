/* mc_scdl1.c
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

/***************************************************************************/
/* MC : Utilitaire de meca celeste                                         */
/* Auteur : Alain Klotz                                                    */
/***************************************************************************/
/* Scheduler d'observations                                                */
/***************************************************************************/
#include "mc.h"

/*****************************************************************************/
/*****************************************************************************/
/* Compute the start and end dates for the next observing range.             */
/* The observing range is based on consecutive meridian passages of the Sun. */
/* Outputs : jd_prevmidsun and jd_nextmidsun                                 */
/*****************************************************************************/
int mc_scheduler_windowdates1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,double *jd_prevmidsun, double *jd_nextmidsun) {

	double jd,djd,latitude,altitude,jd_max,jd1,jd2,dt;
	int k,astrometric;
	double ra,dec,delta,mag,diamapp,elong,phase,r,diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north,long1_sun,lati_sun;
	double ha,ha1;

	// --- initialize
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	astrometric=0;
	mc_tdminusut(jd_now,&dt);
	dt/=86400.;

	// --- searching for gross jd_prevmidsun (=previous meridian)
	djd=60./86400;
	jd1=jd_now;
	jd2=jd1-2.;
	for (jd=jd1,k=0;jd>=jd2;jd-=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; if (ha>0.05) { jd=jd-ha/2/(PI)+0.05; } continue; }
		if ((ha1<PI)&&(ha>PI)) { break; }
		ha1=ha;
	}
	jd_max=jd+djd/2;

	// --- searching for fine jd_prevmidsun (=previous meridian)
	djd=1./86400;
	jd1=jd_max+90./86400;
	jd2=jd_max-90./86400;
	for (jd=jd1,k=0;jd>=jd2;jd-=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; continue; }
		if ((ha1<PI)&&(ha>PI)) { break; }
		ha1=ha;
	}
	*jd_prevmidsun=jd+djd/2;

	// --- searching for gross jd_nextmidsun (=next meridian)
	djd=60./86400;
	jd1=jd_now;
	jd2=jd1+2.;
	for (jd=jd1,k=0;jd<=jd2;jd+=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; if (ha>(2*(PI)-0.05)) { jd=jd+ha/2/(PI)-0.05; } continue; }
		if ((ha1>PI)&&(ha<PI)) { break; }
		ha1=ha;
	}
	jd_max=jd-djd/2;

	// --- searching for fine jd_nextmidsun (=next meridian)
	djd=1./86400;
	jd1=jd_max-90./86400;
	jd2=jd_max+90./86400;
	for (jd=jd1,k=0;jd<=jd2;jd+=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
		mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; continue; }
		if ((ha1>PI)&&(ha<PI)) { break; }
		ha1=ha;
	}
	*jd_nextmidsun=jd-djd/2;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Compute the vector of local conditions for Sun and Moon.                  */
/* Outputs : njd, sunmoon                                                    */
/*****************************************************************************/
int mc_scheduler_sunmoon1(double longmpc, double rhocosphip, double rhosinphip,double jd_prevmidsun, double jd_nextmidsun,double djd, int *pnjd, mc_SUNMOON **psunmoon) {
	double jd,latitude,altitude,da,dh;
	int astrometric,njd,njdm;
	double ra,dec,delta,mag,diamapp,elong,phase,r,diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north,long1_sun,lati_sun;
	double ha,az,h,dt,jdtt,latrad,tsl,djdm;
	mc_SUNMOON *sunmoon=NULL;
	double *dummy1s,*dummy2s,*dummy3s,*dummy4s,*dummy5s,*dummy6s;
	int kjd;

	// --- initialize
	*pnjd=0;
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latrad=latitude*(DR);
	astrometric=0;

	// --- prepare sur-ech vectors
	//djd=1./86400.;
	njd=(int)ceil((jd_nextmidsun-jd_prevmidsun)/djd);
	sunmoon=(mc_SUNMOON*)calloc(njd+1,sizeof(mc_SUNMOON));
	*psunmoon=sunmoon;
	*pnjd=njd;
	for (kjd=0;kjd<=njd;kjd++) {
		jd=jd_prevmidsun+(jd_nextmidsun-jd_prevmidsun)*kjd/njd;
		sunmoon[kjd].jd=jd;
	}
	dummy5s=(double*)calloc(njd+2,sizeof(double)); // jd sur-ech
	for (kjd=0;kjd<=njd;kjd++) {
		dummy5s[kjd+1]=sunmoon[kjd].jd;
	}
	dummy6s=(double*)calloc(njd+2,sizeof(double)); // angle sur-ech

	// --- prepare sous-ech vectors
	djdm=1./24.;
	njdm=2+(int)ceil((jd_nextmidsun-jd_prevmidsun)/djdm);
	mc_tdminusut(jd_prevmidsun,&dt);
	dt/=86400.;
	dummy1s=(double*)calloc(njdm+2,sizeof(double)); // jd sous-ech
	dummy2s=(double*)calloc(njdm+2,sizeof(double)); // ra ou tsl sous-ech
	dummy3s=(double*)calloc(njdm+2,sizeof(double)); // dec sous-ech
	dummy4s=(double*)calloc(njdm+2,sizeof(double)); // phase sous-ech
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=-djdm/2+jd_prevmidsun+(jd_nextmidsun-jd_prevmidsun)*kjd/njdm;
		dummy1s[kjd]=jd;
	}

	// --- local sideral time during the night
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=dummy1s[kjd];
		mc_tsl(jd,-longmpc,&tsl);
		dummy2s[kjd]=tsl/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360.; }
			if (da>180) { dummy2s[kjd]-=360.; }
		}
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // lst
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy6s[kjd+1]>360) { dummy6s[kjd+1]-=360.; }
		sunmoon[kjd].lst=dummy6s[kjd+1]; // lst
	}

	// --- sun parameters during the night
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=dummy1s[kjd];
		jdtt=jd+dt;
		mc_adsolap(jdtt,jdtt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
		dummy2s[kjd]=ra/(DR);
		dummy3s[kjd]=dec/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360.; }
			if (da>180) { dummy2s[kjd]-=360.; }
		}
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // ra
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy6s[kjd+1]>360) { dummy6s[kjd+1]-=360.; }
		sunmoon[kjd].sun_az=dummy6s[kjd+1]; // ra
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].sun_elev=dummy6s[kjd+1]; // dec
	}
	for (kjd=0;kjd<=njd;kjd++) {
		ra=sunmoon[kjd].sun_az; // ra
		dec=sunmoon[kjd].sun_elev*(DR); // dec
		ha=(sunmoon[kjd].lst-ra)*(DR);
		mc_hd2ah(ha,dec,latrad,&az,&h);
		sunmoon[kjd].sun_az=az/(DR); // az
		mc_refraction(h,1,283,101325,&dh);
		sunmoon[kjd].sun_elev=(h+dh)/(DR); // elev

	}

	// --- moon parameters during the night
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=dummy1s[kjd];
		jdtt=jd+dt;
		mc_adlunap(LUNE,jdtt,jd,jdtt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
		dummy2s[kjd]=ra/(DR);
		dummy3s[kjd]=dec/(DR);
		dummy4s[kjd]=phase/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360.; }
			if (da>180) { dummy2s[kjd]-=360.; }
		}
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // ra
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy6s[kjd+1]>360) { dummy6s[kjd+1]-=360.; }
		sunmoon[kjd].moon_az=dummy6s[kjd+1]; // ra
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].moon_elev=dummy6s[kjd+1]; // dec
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy4s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].moon_phase=dummy6s[kjd+1]; // dec
	}
	for (kjd=0;kjd<=njd;kjd++) {
		ra=sunmoon[kjd].moon_az; // ra
		dec=sunmoon[kjd].moon_elev*(DR); // dec
		ha=(sunmoon[kjd].lst-ra)*(DR);
		mc_hd2ah(ha,dec,latrad,&az,&h);
		sunmoon[kjd].moon_az=az/(DR); // az
		sunmoon[kjd].moon_elev=h/(DR); // elev
		mc_refraction(h,1,283,101325,&dh);
		sunmoon[kjd].moon_elev=(h+dh)/(DR); // elev
	}

	free(dummy1s);
	free(dummy2s);
	free(dummy3s);
	free(dummy4s);
	free(dummy5s);
	free(dummy6s);
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Correction of coordinates                                                 */
/* Outputs : objectdescr                                                     */
/*****************************************************************************/
int mc_sheduler_corccoords(mc_OBJECTDESCR *objectdescr) {
	int n,k;
	double ra,cosdec,mura,mudec,parallax;
	double dec,asd2,dec2;
	double jd;
	n=objectdescr->axe_njd;
	if (objectdescr->axe_type==0) {
		for (k=0;k<n;k++) {
			jd=objectdescr->axe_jd[k];
			/* === CALCULS === */
			ra=objectdescr->axe_pos1[k]*(DR);
			dec=objectdescr->axe_pos2[k]*(DR);
			cosdec=cos(dec);
			mura=objectdescr->axe_mura*1e-3/86400/cosdec;
			mudec=objectdescr->axe_mudec*1e-3/86400;
			parallax=objectdescr->axe_plx;
			/* --- aberration annuelle ---*/
			mc_aberration_annuelle(jd,ra,dec,&asd2,&dec2,1);
			ra=asd2;
			dec=dec2;
			/* --- calcul de mouvement propre ---*/
			ra+=(jd-objectdescr->axe_epoch)/365.25*mura;
			dec+=(jd-objectdescr->axe_epoch)/365.25*mudec;
			/* --- calcul de la precession ---*/
			mc_precad(objectdescr->axe_equinox,ra,dec,jd,&asd2,&dec2);
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
			/*
			mc_aberration_diurne(jd,ra,dec,longmpc,rhocosphip,rhosinphip,&asd2,&dec2,1);
			ra=asd2;
			dec=dec2;
			*/
			objectdescr->axe_pos1[k]=ra/(DR);
			objectdescr->axe_pos2[k]=dec/(DR);
		}
	}
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Interpolation of coordinates                                              */
/* Outputs : objectlocal                                                     */
/*****************************************************************************/
int mc_sheduler_interpcoords(mc_OBJECTDESCR *objectdescr,double jd,double *pos1,double *pos2) {
	int n,k;
	double p1,p2,da,djd,jdfrac;
	n=objectdescr->axe_njd;
	for (k=1;k<n;k++) {
		da=objectdescr->axe_pos1[k]-objectdescr->axe_pos1[k-1];
		if (da<-180) { objectdescr->axe_pos1[k]+=360.; }
		if (da>180) { objectdescr->axe_pos1[k]-=360.; }
	}
	if ((jd>objectdescr->axe_jd[0]==0)||(n==1)) {
		p1=objectdescr->axe_pos1[0];
		p2=objectdescr->axe_pos2[0];
	} else {
		for (k=1;k<n;k++) {
			if (jd<=objectdescr->axe_jd[k]) {
				djd=objectdescr->axe_jd[k]-objectdescr->axe_jd[k-1];
				if (djd!=0) {
					jdfrac=(jd-objectdescr->axe_jd[k-1])/djd;
					p1=objectdescr->axe_pos1[k-1]+jdfrac*(objectdescr->axe_pos1[k]-objectdescr->axe_pos1[k-1]);
					p2=objectdescr->axe_pos2[k-1]+jdfrac*(objectdescr->axe_pos2[k]-objectdescr->axe_pos2[k-1]);
				} else {
					p1=(objectdescr->axe_pos1[k]+objectdescr->axe_pos1[k-1])/2;
					p2=(objectdescr->axe_pos2[k]+objectdescr->axe_pos2[k-1])/2;
				}
			}
		}
	}
	*pos1=p1;
	*pos2=p2;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Compute the vector of local conditions for an Object.                     */
/* Outputs : objectlocal                                                     */
/* elevation is corrected by refraction but not ra,dec,ha,az                 */
/*****************************************************************************/
int mc_scheduler_objectlocal1(double longmpc, double rhocosphip, double rhosinphip, mc_OBJECTDESCR *objectdescr,int njd, mc_SUNMOON *sunmoon,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadecint,mc_OBJECTLOCAL **pobjectlocal) {
	double latitude,altitude;
	int astrometric,njdm;
	double *dummy1s,*dummy2s,*dummy3s,*dummy4s,*dummy5s,*dummy6s,*dummy7s,*dummy8s,*dummy9s;
	double *dummy01s,*dummy02s;
	int kjd,sousech,k;
	double ra,dec,ha,elev,az,da,c,moon_dist_phase,dh;
	mc_OBJECTLOCAL *objectlocal;
	double latrad,h,moon_az,moon_elev,sun_az,sun_elev,moon_dist,sun_dist,helev;
	double moon_age,brillance_ciel_bleu,luminance_ciel_bleu,brillance_ciel_nocturne,luminance_ciel_nocturne,brillance_diffusion_soleil,luminance_diffusion_soleil,brillance_diffusion_lune,luminance_diffusion_lune;
	double luminance_totale,brillance_totale;

	// --- initialize
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latrad=latitude*(DR);
	astrometric=0;

	// --- prepare sur-ech vectors
	objectlocal=(mc_OBJECTLOCAL*)calloc(njd+1,sizeof(mc_OBJECTLOCAL));
	*pobjectlocal=objectlocal;

	// --- prepare sous-ech vectors
	sousech=60;
	//sousech=3600;
	njdm=(int)ceil(1.*njd/sousech);
	dummy1s=(double*)calloc(njdm+1,sizeof(double)); // jd sous-ech
	dummy2s=(double*)calloc(njdm+1,sizeof(double)); // ha sous-ech
	dummy3s=(double*)calloc(njdm+1,sizeof(double)); // elev sous-ech
	dummy4s=(double*)calloc(njdm+1,sizeof(double)); // az sous-ech
	dummy5s=(double*)calloc(njdm+1,sizeof(double)); // dec sous-ech
	dummy6s=(double*)calloc(njdm+1,sizeof(double)); // moon_dist sous-ech
	dummy7s=(double*)calloc(njdm+1,sizeof(double)); // sun_dist sous-ech
	dummy8s=(double*)calloc(njdm+1,sizeof(double)); // skylevel sous-ech
	dummy9s=(double*)calloc(njdm+1,sizeof(double)); // ra sous-ech
	for (kjd=0;kjd<=njdm;kjd++) {
		k=kjd*sousech; if (k>njd) { k=njd; }
		dummy1s[kjd]=sunmoon[k].jd;
		moon_az=sunmoon[k].moon_az*(DR);
		moon_elev=sunmoon[k].moon_elev*(DR);
		sun_az=sunmoon[k].sun_az*(DR);
		sun_elev=sunmoon[k].sun_elev*(DR);
		if (objectdescr->axe_type==0) {
			// --- type = RADEC
			mc_sheduler_interpcoords(objectdescr,dummy1s[kjd],&ra,&dec);
			ha=sunmoon[k].lst-ra;
			if (ha<-360) { ha+=360.; }
			if (ha>360) { ha-=360.; }
			dummy2s[kjd]=ha;
			if (kjd>0) {
				da=dummy2s[kjd]-dummy2s[kjd-1];
				if (da<-180) { dummy2s[kjd]+=360.; }
				if (da>180) { dummy2s[kjd]-=360.; }
			}
			dummy9s[kjd]=ra; // laisser apres ha
			if (kjd>0) {
				da=dummy9s[kjd]-dummy9s[kjd-1];
				if (da<-180) { dummy9s[kjd]+=360.; }
				if (da>180) { dummy9s[kjd]-=360.; }
			}
			mc_hd2ah(ha*(DR),dec*(DR),latrad,&az,&h);
			mc_refraction(h,1,283,101325,&dh);
			h+=dh;
			dummy3s[kjd]=h/(DR); elev=h;
			dummy4s[kjd]=az/(DR); // az
			if (kjd>0) {
				da=dummy4s[kjd]-dummy4s[kjd-1];
				if (da<-180) { dummy4s[kjd]+=360.; }
				if (da>180) { dummy4s[kjd]-=360.; }
			}
			dummy5s[kjd]=dec;
		}
		if (objectdescr->axe_type==1) {
			// --- type = HADEC
			mc_sheduler_interpcoords(objectdescr,dummy1s[kjd],&ha,&dec);
			ra=sunmoon[k].lst-ha;
			if (ra<-360) { ra+=360.; }
			if (ra>360) { ra-=360.; }
			dummy9s[kjd]=ra;
			if (kjd>0) {
				da=dummy9s[kjd]-dummy9s[kjd-1];
				if (da<-180) { dummy9s[kjd]+=360.; }
				if (da>180) { dummy9s[kjd]-=360.; }
			}
			dummy2s[kjd]=ha; // laisser apres ra
			if (kjd>0) {
				da=dummy2s[kjd]-dummy2s[kjd-1];
				if (da<-180) { dummy2s[kjd]+=360.; }
				if (da>180) { dummy2s[kjd]-=360.; }
			}
			mc_hd2ah(ha*(DR),dec*(DR),latrad,&az,&h);
			mc_refraction(h,1,283,101325,&dh);
			h+=dh;
			dummy3s[kjd]=h/(DR); elev=h;
			dummy4s[kjd]=az/(DR); // az
			if (kjd>0) {
				da=dummy4s[kjd]-dummy4s[kjd-1];
				if (da<-180) { dummy4s[kjd]+=360.; }
				if (da>180) { dummy4s[kjd]-=360.; }
			}
			dummy5s[kjd]=dec;
		}
		if (objectdescr->axe_type==2) {
			// --- type = ALTAZ
			mc_sheduler_interpcoords(objectdescr,dummy1s[kjd],&az,&h);
			mc_ah2hd(az*(DR),h*(DR),latrad,&ha,&dec);
			ra=sunmoon[k].lst-ha;
			if (ra<-360) { ra+=360.; }
			if (ra>360) { ra-=360.; }
			dummy9s[kjd]=ra;
			if (kjd>0) {
				da=dummy9s[kjd]-dummy9s[kjd-1];
				if (da<-180) { dummy9s[kjd]+=360.; }
				if (da>180) { dummy9s[kjd]-=360.; }
			}
			dummy2s[kjd]=ha; // laisser apres ra
			if (kjd>0) {
				da=dummy2s[kjd]-dummy2s[kjd-1];
				if (da<-180) { dummy2s[kjd]+=360.; }
				if (da>180) { dummy2s[kjd]-=360.; }
			}
			mc_refraction(h,1,283,101325,&dh);
			h+=dh;
			dummy3s[kjd]=h/(DR); elev=h;
			dummy4s[kjd]=az/(DR); // az
			if (kjd>0) {
				da=dummy4s[kjd]-dummy4s[kjd-1];
				if (da<-180) { dummy4s[kjd]+=360.; }
				if (da>180) { dummy4s[kjd]-=360.; }
			}
			dummy5s[kjd]=dec;
		}
		// --- moon_dist
		c=(sin(elev)*sin(moon_elev)+cos(elev)*cos(moon_elev)*cos(az-moon_az));
		if (c<-1.) {c=-1.;}
		if (c>1.) {c=1.;}
		moon_dist=acos(c)/(DR);
		dummy6s[kjd]=moon_dist;
		// --- moon_dist
		c=(sin(elev)*sin(sun_elev)+cos(elev)*cos(sun_elev)*cos(az-sun_az));
		if (c<-1.) {c=-1.;}
		if (c>1.) {c=1.;}
		sun_dist=acos(c)/(DR);
		dummy7s[kjd]=sun_dist;
		// --- skylevel
		k=(int)(az/(DR));
		if (k>360) {k-=360;}
		if (k<0) {k+=360;}
		helev=horizon_altaz[k].elev;
		elev/=(DR);
		moon_dist_phase=objectdescr->const_fullmoondist*(sqrt(fabs(moon_dist)/180.));
		if (elev<helev) {
			dummy8s[kjd]=-50;
		} else if (elev<objectdescr->const_elev) {
			dummy8s[kjd]=-50;
		} else if (sun_dist<=objectdescr->const_sundist) {
			dummy8s[kjd]=-50;
		} else if (moon_dist<=moon_dist_phase) {
			dummy8s[kjd]=-50;
		} else {
			moon_age=sunmoon[k].moon_phase*(DR)/180*14;
			brillance_ciel_bleu=28-23.7/(1+exp(-((sun_elev/(DR)+8)/8)))-1.3*cos(elev*(DR))/(1+exp(-(sun_elev/(DR)/2)));
			luminance_ciel_bleu=pow(10.,-(brillance_ciel_bleu-13)/2.5);
			brillance_ciel_nocturne=20.0-0.13*(moon_age-14);
			luminance_ciel_nocturne=pow(10.,-(brillance_ciel_nocturne-13)/2.5);
			brillance_diffusion_soleil=-10.7+10.2+15*log10(0.1+sun_dist);
			luminance_diffusion_soleil=pow(10.,-(brillance_diffusion_soleil-13)/2.5);
			brillance_diffusion_lune=3.6-0.13*(moon_age-14)+4.2+10*log10(0.1+moon_dist)+20/(1+exp((moon_elev/2)));
			luminance_diffusion_lune=pow(10.,-(brillance_diffusion_lune-13)/2.5);
			luminance_totale=luminance_ciel_bleu+luminance_ciel_nocturne+luminance_diffusion_soleil+luminance_diffusion_lune;
			brillance_totale=13-2.5*log10(luminance_totale);
			dummy8s[kjd]=brillance_totale;
		}
	}

	// --- interpolations
	dummy01s=(double*)calloc(njd+2,sizeof(double)); // jd
	dummy02s=(double*)calloc(njd+2,sizeof(double));
	for (kjd=0;kjd<=njd;kjd++) {
		dummy01s[kjd+1]=sunmoon[kjd].jd;
	}
	mc_interplin1(0,njdm,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
		objectlocal[kjd].ha=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		objectlocal[kjd].elev=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy4s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
		objectlocal[kjd].az=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy5s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
		objectlocal[kjd].dec=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy6s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		objectlocal[kjd].moon_dist=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy7s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		objectlocal[kjd].sun_dist=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy8s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		objectlocal[kjd].skylevel=dummy02s[kjd+1];
	}
	mc_interplin1(0,njdm,dummy1s,dummy9s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
		objectlocal[kjd].ra=dummy02s[kjd+1];
	}
	free(dummy1s);
	free(dummy2s);
	free(dummy3s);
	free(dummy4s);
	free(dummy5s);
	free(dummy6s);
	free(dummy7s);
	free(dummy8s);
	free(dummy9s);
	free(dummy01s);
	free(dummy02s);
	return 0;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_obsconditions1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec,int nobj,mc_OBJECTDESCR *objectdescr,double djd,char *fullfilename) {

	double jd_prevmidsun,jd_nextmidsun;
	int njd,kjd;
	mc_SUNMOON *sunmoon=NULL;
	mc_OBJECTLOCAL *objectlocal=NULL;
	FILE *fid;

	// --- compute dates of observing range (=the start-end of the schedule)
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

	// --- compute mc_SUNMOON vector for the observing range.
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	// --- compute mc_OBJECTLOCAL vector for the observing range.
	mc_sheduler_corccoords(&objectdescr[0]);
	mc_scheduler_objectlocal1(longmpc,rhocosphip,rhosinphip,&objectdescr[0],njd,sunmoon,horizon_altaz,horizon_hadec,&objectlocal);

	// --- output file
	fid=fopen(fullfilename,"wt");
	if (fid!=NULL) {
		for (kjd=0;kjd<njd;kjd++) {
			fprintf(fid,"%.5f %6.2f  %6.2f %+6.2f  %6.2f %+6.2f %6.2f  %6.2f %+6.2f %6.2f %6.2f %+6.2f  %+6.2f %6.2f %6.2f\n",sunmoon[kjd].jd,sunmoon[kjd].lst, sunmoon[kjd].sun_az,sunmoon[kjd].sun_elev, sunmoon[kjd].moon_az,sunmoon[kjd].moon_elev,sunmoon[kjd].moon_phase, objectlocal[kjd].az,objectlocal[kjd].elev,objectlocal[kjd].ha,objectlocal[kjd].ra,objectlocal[kjd].dec,objectlocal[kjd].skylevel,objectlocal[kjd].sun_dist,objectlocal[kjd].moon_dist);
		}
		fclose(fid);
	} else {
		return 1;
	}

	free(sunmoon);
	free(objectlocal);
   return 0;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_scheduler1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec,int nobj,mc_OBJECTDESCR *objectdescr) {

	double jd_prevmidsun,jd_nextmidsun,djd;
	int njd;
	mc_SUNMOON *sunmoon=NULL;
	mc_OBJECTLOCAL *objectlocal=NULL;

	// --- compute dates of observing range (=the start-end of the schedule)
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

	// --- compute mc_SUNMOON vector for the observing range.
	djd=60./86400.;
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	// --- compute mc_OBJECTLOCAL vector for the observing range.
	mc_sheduler_corccoords(&objectdescr[0]);
	mc_scheduler_objectlocal1(longmpc,rhocosphip,rhosinphip,&objectdescr[0],njd,sunmoon,horizon_altaz,horizon_hadec,&objectlocal);

   //mc_fitspline(n1,n2,x,y,dy,s,nn,xx,ff);
	free(sunmoon);
	free(objectlocal);
   return 0;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_nextnight1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,double elev_set,double elev_twilight, double *jdprev, double *jdset,double *jdrise,double *jddusk,double *jddawn,double *jdnext) {
	double jd_prevmidsun,jd_nextmidsun,djd;
	int njd,kjd;
	mc_SUNMOON *sunmoon=NULL;

	// --- compute dates of observing range (=the start-end of the schedule)
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

	// --- compute mc_SUNMOON vector for the observing range.
	djd=600./86400.;
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	*jdprev=jd_prevmidsun;
	*jdset=jd_prevmidsun;
	*jddusk=jd_prevmidsun;
	*jdrise=jd_nextmidsun;
	*jddawn=jd_nextmidsun;
	*jdnext=jd_nextmidsun;
	for (kjd=1;kjd<njd;kjd++) {
		if ((sunmoon[kjd-1].sun_elev>=elev_twilight)&&(sunmoon[kjd].sun_elev<elev_twilight)) {
			*jddusk=sunmoon[kjd-1].jd;
		}
		if ((sunmoon[kjd-1].sun_elev>=elev_set)&&(sunmoon[kjd].sun_elev<elev_set)) {
			*jdset=sunmoon[kjd-1].jd;
		}
		if ((sunmoon[kjd-1].sun_elev<=elev_set)&&(sunmoon[kjd].sun_elev>elev_set)) {
			*jdrise=sunmoon[kjd-1].jd;
		}
		if ((sunmoon[kjd-1].sun_elev<=elev_twilight)&&(sunmoon[kjd].sun_elev>elev_twilight)) {
			*jddawn=sunmoon[kjd-1].jd;
		}
	}
	free(sunmoon);
   return 0;
}