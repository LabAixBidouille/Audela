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
   double az;
   double elev;
   double ha;
   double dec;
} mc_HORIZON;

typedef struct {
   double elev;
   double az;
   double moon_dist;
   double sun_dist;
   double skylevel;
   double ha;
   double dec;
} mc_OBJECT;


int mc_scheduler1(double jd_now, double longmpc, double rhocosphip, double rhosinphip) {

	double jd_prevmidsun,jd_nextmidsun,jd,djd,latitude,altitude,jd_max,jd1,jd2;
	int k,astrometric;
	double ra,dec,delta,mag,diamapp,elong,phase,r,diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north,long1_sun,lati_sun;
	double az,elev,ha,ha1,ha2;

	// --- initialize
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	astrometric=0;

	// --- searching for gross jd_prevmidsun (=previous meridian)
	djd=60./86400;
	jd1=jd_now;
	jd2=jd1-2.;
	for (jd=jd1,k=0;jd>=jd2;jd-=djd,k++) {
		mc_adsolap(jd,jd,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
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
		mc_adsolap(jd,jd,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; continue; }
		if ((ha1<PI)&&(ha>PI)) { break; }
		ha1=ha;
	}
	jd_prevmidsun=jd+djd/2;

	// --- searching for gross jd_nextmidsun (=next meridian)
	djd=60./86400;
	jd1=jd_now;
	jd2=jd1+2.;
	for (jd=jd1,k=0;jd<=jd2;jd+=djd,k++) {
		mc_adsolap(jd,jd,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
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
		mc_adsolap(jd,jd,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; continue; }
		if ((ha1>PI)&&(ha<PI)) { break; }
		ha1=ha;
	}
	jd_nextmidsun=jd-djd/2;

   //mc_fitspline(n1,n2,x,y,dy,s,nn,xx,ff);
   return 0;
}