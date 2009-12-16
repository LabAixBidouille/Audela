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

typedef struct {
   double jd;
   double sun_elev;
   double sun_az;
   double moon_elev;
   double moon_az;
   double moon_phase;
   double lst;
} mc_SUNMOON;

typedef struct {
   double elev;
   double az;
   double moon_dist;
   double sun_dist;
   double skylevel550; // -1 = unvisible, >=0 expected skylight in w/m2/sr @ 550 nm
   double skylevel1mu; // -1 = unvisible, >=0 expected skylight in w/m2/sr @ 1 micron
   double skylevel2mu; // -1 = unvisible, >=0 expected skylight in w/m2/sr @ 2 microns
   double ha;
   double dec;
} mc_OBJECTLOCAL;


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
	double jd,latitude,altitude,da;
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
	dummy1s=(double*)calloc(njdm+1,sizeof(double)); // jd sous-ech
	dummy2s=(double*)calloc(njdm+1,sizeof(double)); // ra ou tsl sous-ech
	dummy3s=(double*)calloc(njdm+1,sizeof(double)); // dec sous-ech
	dummy4s=(double*)calloc(njdm+1,sizeof(double)); // phase sous-ech
	for (kjd=0;kjd<=njdm;kjd++) {
		jd=-djdm+jd_prevmidsun+(jd_nextmidsun-jd_prevmidsun)*kjd/njdm;
		dummy1s[kjd]=jd;
	}

	// --- local sideral time during the night
	for (kjd=0;kjd<=njdm;kjd++) {
		jd=dummy1s[kjd];
		mc_tsl(jd,-longmpc,&tsl);
		dummy2s[kjd]=tsl/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360.; }
			if (da>180) { dummy2s[kjd]-=360.; }
		}
	}
	mc_interplin1(0,njdm,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // lst
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy6s[kjd+1]>360) { dummy6s[kjd+1]-=360.; }
		sunmoon[kjd].lst=dummy6s[kjd+1]; // lst
	}

	// --- sun parameters during the night
	for (kjd=0;kjd<=njdm;kjd++) {
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
	mc_interplin1(0,njdm,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // ra
	for (kjd=0;kjd<=njd;kjd++) {
		if (dummy6s[kjd+1]>360) { dummy6s[kjd+1]-=360.; }
		sunmoon[kjd].sun_az=dummy6s[kjd+1]; // ra
	}
	mc_interplin1(0,njdm,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].sun_elev=dummy6s[kjd+1]; // dec
	}
	for (kjd=0;kjd<=njd;kjd++) {
		ra=sunmoon[kjd].sun_az; // ra
		dec=sunmoon[kjd].sun_elev*(DR); // dec
		ha=(sunmoon[kjd].lst-ra)*(DR);
		mc_hd2ah(ha,dec,latrad,&az,&h);
		sunmoon[kjd].sun_az=az/(DR); // az
		sunmoon[kjd].sun_elev=dec/(DR); // elev
	}
   //mc_adlunap(LUNE,jdtt,jd,jdtt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	free(dummy1s);
	free(dummy2s);
	free(dummy3s);
	free(dummy4s);
	free(dummy5s);
	free(dummy6s);
	return 0;
}


/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_scheduler1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec) {

	double jd_prevmidsun,jd_nextmidsun,djd;
	int njd;
	mc_SUNMOON *sunmoon=NULL;
	//mc_OBJECTLOCAL *objectlocal=NULL;

	// --- compute dates of observing range (=the start-end of the schedule)
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

	// --- compute mc_SUNMOON vector for the observing range.
	djd=1./86400.;
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	// --- compute mc_OBJECTLOCAL vector for the observing range.
	/*
	ra=123*(DR);
	dec=23*(DR);
	equinox=J2000;
	mura=0.;
	mudec=0.;
	epoch=(jd_prevmidsun+jd_nextmidsun)/2;
	plx=0.;
	*/
	//mc_scheduler_objectlocal1(longmpc,rhocosphip,rhosinphip,objectdescr,njd,sunmoon,horizon_altaz,horizon_hadec,objectlocal);

/*
typedef struct {
   double elev;
   double az;
   double ha;
   double dec;
   double moon_dist;
   double sun_dist;
   double skylevel; // -1 = masked by horizon limits, >=0 expected skylight in w/m2/sr @ defined microns
} mc_OBJECTLOCAL;
*/
/*
typedef struct {
} mc_OBJECTDESCR;
*/

   //mc_fitspline(n1,n2,x,y,dy,s,nn,xx,ff);
	free(sunmoon);
   return 0;
}