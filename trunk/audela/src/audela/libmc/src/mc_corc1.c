/* mc_corc1.c
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
/* Corrections de precession, nutation, aberration ...                     */
/***************************************************************************/
#include "mc.h"

void mc_aberration_annuelle(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de l'aberration annuelle et retourne asd2 et dec2     */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p81-82    */
/* Formule sans les E-terms                                                */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],ls,bs,rs,eps,dpsi,deps;
   int planete;
   double k=20.49552; /* constant of annual aberration */
   double c,cc,d,dd,secd,cp,dp,dasd,ddec;

   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- longitude vraie du soleil ---*/
   planete=SOLEIL;
   mc_jd2lbr1a(jj,llp,mmp,uup);
   mc_jd2lbr1b(jj,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_nutation(jj,1,&dpsi,&deps);
   ls+=dpsi;

   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
   c=cos(asd1)*secd;
   d=sin(asd1)*secd;
   cp=tan(eps)*cos(dec1)-sin(asd1)*sin(dec1);
   dp=cos(asd1)*sin(dec1);
   cc=-k*cos(eps)*cos(ls);
   dd=-k*sin(ls);
   dasd=(cc*c+dd*d)/3600.*(DR);
   ddec=(cc*cp+dd*dp)/3600.*(DR);
   dasd*=(double)signe;
   ddec*=(double)signe;
   asd1+=dasd;
   dec1+=ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberration_eterms(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de l'aberration eterms et retourne asd2 et dec2       */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p82-83    */
/* Formule des E-terms                                                     */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],ls,bs,rs,eps,dpsi,deps;
   int planete;
   double k=20.49552; /* constant of annual aberration */
   double c,cc,d,dd,secd,cp,dp,dasd,ddec;
   double t,e,w;

   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- longitude vraie du soleil ---*/
   planete=SOLEIL;
   mc_jd2lbr1a(jj,llp,mmp,uup);
   mc_jd2lbr1b(jj,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_nutation(jj,1,&dpsi,&deps);
   ls+=dpsi;

   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
   c=cos(asd1)*secd;
   d=sin(asd1)*secd;
   cp=tan(eps)*cos(dec1)-sin(asd1)*sin(dec1);
   dp=cos(asd1)*sin(dec1);
   t=(jj-2451545.)/36525.;
   e=0.016708320-0.000042229*t-0.000000126*t*t;
   w=102.938346+1.719457*t;
   cc=k*e*cos(eps)*cos(w);
   dd=k*e*sin(w);
   dasd=(cc*c+dd*d)/3600.*(DR);
   ddec=(cc*cp+dd*dp)/3600.*(DR);
   dasd*=(double)signe;
   ddec*=(double)signe;
   asd1+=dasd;
   dec1+=ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberration_diurne(double jj,double asd1,double dec1, double longuai, double rhocosphip, double rhosinphip,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de l'aberration diurne et retourne asd2 et dec2       */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p83-84    */
/***************************************************************************/
{
   double secd,dasd,ddec;
   double tsl,latitude,altitude,phip,a=6378.140,sinphi,r,h;
   mc_tsl(jj,-longuai,&tsl);
   h=tsl-asd1;
   mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
   if (rhocosphip==0.) {
      if (rhosinphip>0) {
         phip=(PI)/2.;
      } else {
         phip=-(PI)/2.;
      }
   } else {
      phip=mc_atan2(rhosinphip,rhocosphip);
   }
   sinphi=sin(latitude);
   r=(21*sinphi*sinphi+a)/a;
   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
   dasd=(0.320*r*cos(phip)*cos(h)*secd)/3600.*(DR);
   ddec=(0.320*r*cos(phip)*sin(h)*sin(dec1))/3600.*(DR);
   dasd*=(double)signe;
   ddec*=(double)signe;
   asd1+=dasd;
   dec1+=ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberpla(double jj1, double delta, double *jj2)
/***************************************************************************/
/* Corrige jj1 de l'aberration de la lumiere et retourne jj2               */
/***************************************************************************/
/***************************************************************************/
{
   *jj2=jj1-0.0057755*delta;
}

void mc_latalt2rhophi(double latitude,double altitude,double *rhosinphip,double *rhocosphip)
/***************************************************************************/
/* Retourne les valeurs de rhocosphi' et rhosinphi' (en rayons equatorial  */
/* terrestres) a partir de la latitude et de l'altitude.                   */
/***************************************************************************/
/* Latitude en degres decimaux.                                            */
/* Altitude en metres.                                                     */
/* Algo : Meeus "Astronomical Algorithms" p78                              */
/***************************************************************************/
{
   double aa,ff,bb,a,b,u,lat,alt;
   lat=latitude*(DR);
   alt=altitude;
   aa=6378140;
   ff=1./298.257;
   bb=aa*(1-ff);
   u=atan(bb/aa*tan(lat));
   a=bb/aa*sin(u)+alt/aa*sin(lat);
   b=      cos(u)+alt/aa*cos(lat);
   *rhocosphip=b;
   *rhosinphip=a;
}

void mc_nutation(double jj, int precision, double *dpsi, double *deps)
/***************************************************************************/
/* Retourne la valeur de la nutation pour jj donne                         */
/***************************************************************************/
/* precision=0 pour une incertitude de 0"5 sur dpsi 0"1 sur deps           */
/* precision=1 pour de la tres haute precision (environ 0.01")             */
/***************************************************************************/
{
   double t,d,m,mp,f,o,l,lp,dpsi0,deps0;
   t=(jj-2451545.0)/36525;
   o=125.04452-1934.136261*t+.0020708*t*t+t*t*t/450000;
   o=fmod(o*DR,2*PI);
   if (precision==0) {
      l=280.4665+36000.7698*t;
      lp=218.3165+481267.8813*t;
      l=fmod(l*DR,2*PI);
      lp=fmod(lp*DR,2*PI);
      dpsi0=-17.20*sin(o)-1.32*sin(2*l)-.23*sin(2*lp)+.21*sin(2*o);
      dpsi0=dpsi0/3600*DR;
      deps0=9.20*cos(o)+.57*cos(2*l)+.10*cos(2*lp)-.09*cos(2*o);
      deps0=deps0/3600*DR;
   } else /* if (precision==1) */ {
      d=297.85036+445267.111480*t-.0019142*t*t+t*t*t/189474;
      m=357.52772+35999.050340*t-.0001603*t*t-t*t*t/300000;
      mp=134.96298+477198.867398*t+.0086972*t*t+t*t*t/56250;
      f=93.27191+483202.017538*t-.0036825*t*t+t*t*t/327270;
      d=fmod(d*DR,2*PI);
      m=fmod(m*DR,2*PI);
      mp=fmod(mp*DR,2*PI);
      f=fmod(f*DR,2*PI);
      dpsi0=(-171996-174.2*t)*sin(o)+(-13187-1.6*t)*sin(-2*d+2*f+2*o)
         +(-2274-.02*t)*sin(2*f+2*o)+(2062+.2*t)*sin(2*o)
         +(1426-3.4*t)*sin(m)+(712+.1*t)*sin(mp);
      dpsi0+=((-517+1.2*t)*sin(-2*d+m+2*f+2*o)-(386-.4*t)*sin(2*f+o)
         -301*sin(mp+2*f+2*o)+(217-.5*t)*sin(-2*d-m+2*f+2*o)
         -158*sin(-2*d+mp)+(129+.1*t)*sin(-2*d+2*f+o));
      dpsi0+=(123*sin(-mp+2*f+2*o)+63*sin(2*d)+(63+.1*t)*sin(mp+o)
         -59*sin(2*d-mp+2*f+2*o)+(-58-.1*t)*sin(-mp+o)-51*sin(mp+2*f+o)
         +48*sin(-2*d+2*mp)+46*sin(-2*mp+2*f+o)-38*sin(2*d+2*f+2*o));
      dpsi0=dpsi0*1e-4/3600*DR;
      deps0=(92025+8.9*t)*cos(o)+(5736-3.1*t)*cos(-2*d+2*f+2*o)
         +(977-.5*t)*cos(2*f+2*o)+(-895+.5*t)*cos(2*o)+(54-.1*t)*cos(m)
         -7*cos(mp)+(224-.6*t)*cos(-2*d+m+2*f+2*o)+200*cos(2*f+o);
      deps0+=((129-.1*t)*cos(mp+2*f+2*o)+(-95+.3*t)*cos(-2*d-m+2*f+2*o)
         -70*cos(-2*d+2*f+o)-53*cos(-mp+2*f+2*o)-33*cos(mp+o)
         +26*cos(2*d-mp+2*f+2*o)+32*cos(-mp+o)+27*cos(mp+2*f+o));
      deps0=deps0*1e-4/3600*DR;
   }
   *dpsi=dpsi0;
   *deps=deps0;
}

void mc_nutradec(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de la nutation et retourne asd2 et dec2               */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p71       */
/***************************************************************************/
{
   double eps,tand,dasd,ddec,dpsi,deps;
   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- nutation ---*/
   mc_nutation(jj,1,&dpsi,&deps);

   if (fabs(dec1)>=(PI)/2.) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   tand=tan(dec1);
   dasd=(cos(eps)+sin(eps)*sin(asd1)*tand)*dpsi-cos(asd1)*tand*deps;
   ddec=sin(eps)*cos(asd1)*dpsi+sin(asd1)*deps;
   dasd*=(double)signe;
   ddec*=(double)signe;
   asd1+=dasd;
   dec1+=ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;

}

void mc_obliqmoy(double jj, double *eps)
/***************************************************************************/
/* Retourne la valeur de l'obliquite terrestre moyenne pour jj             */
/***************************************************************************/
/* formule de Laskar (JM)                                                  */
/***************************************************************************/
{
   double t,u,eps0;
   t=(jj-2451545.0)/36525;
   u=t/100;
   eps0=u*(-4680.93-u*(1.55+u*(1999.25-u*(51.38-u*(249.67-u*(39.05+u*(7.12+u*(27.87+u*(5.79+u*(2.45))))))))));
   eps0=(23.4392911111+eps0/3600)*DR;
   *eps=eps0;
}

void mc_paraldxyzeq(double jj, double longuai, double rhocosphip, double rhosinphip, double *dxeq, double *dyeq, double *dzeq)
/***************************************************************************/
/* Calcul des corrections cartesiennes equatoriales de la parallaxe        */
/* Xtopo = Xgeo - *dxeq etc...                                             */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules (6.17.1) pp 208                                                */
/***************************************************************************/
{
   double tsl,cst=4.26356e-5;
   mc_tsl(jj,-longuai,&tsl);
   *dxeq=(cst*rhocosphip*cos(tsl));
   *dyeq=(cst*rhocosphip*sin(tsl));
   *dzeq=(cst*rhosinphip);
}

void mc_precelem(struct elemorb elem1, double jd1, double jd2, struct elemorb *elem2)
/***************************************************************************/
/* Passage des elements de l'orbite d'un equinoxe a un autre               */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,eta,pi,p,i0,o0,w0,i,o,w,dw,psi,a;
   double cosi0,sini0,coso0pi,sino0pi,coseta,sineta,sini,sina,cosa;

   t=(jd2-jd1)/36525;
   tt=(jd1-2451545.0)/36525;
   eta=(47.0029-0.06603*tt+0.000598*tt*tt)*t+(-0.03302+0.000598*tt)*t*t+.000060*t*t*t;
   eta=eta/3600*DR;
   pi=174.876384+(3289.4789*tt+0.60622*tt*tt-(869.8089+.50491*tt)*t+.03536*t*t)/3600;
   pi=pi*DR;
   p=(5029.0966+2.22226*tt-.000042*tt*tt)*t+(1.11113-.000042*tt)*t*t-.000006*t*t*t;
   p=p/3600*DR;
   psi=p+pi;
   i0=elem1.i;
   o0=elem1.o;
   w0=elem1.w;
   cosi0=cos(i0);
   sini0=sin(i0);
   coseta=cos(eta);
   sineta=sin(eta);
   coso0pi=cos(o0-pi);
   sino0pi=sin(o0-pi);
   if (fabs(i0/(DR))<1e-6) {
      i=eta;
      sini=sin(i);
      o=psi+PI/2;
   } else {
      i=acos(cosi0*coseta+sini0*sineta*coso0pi);
      sini=sin(i);
      sina=sini0*sino0pi/sini;
      cosa=(-sineta*cosi0+coseta*sini0*coso0pi)/sini;
      a=atan2(sina,cosa);
      o=psi+a;
   }
   sina=-sineta*sino0pi/sini;
   cosa=(sini0*coseta-cosi0*sineta*coso0pi)/sini;
   dw=atan2(sina,cosa);
   w=w0+dw;
   i=fmod(4*PI+i,2*PI);
   o=fmod(4*PI+o,2*PI);
   w=fmod(4*PI+w,2*PI);
   mc_copyelem(elem1,elem2);
   elem2->i=i;
   elem2->o=o;
   elem2->w=w;
   elem2->jj_equinoxe=jd2;
}

void mc_precxyz(double jd1, double x1, double y1, double z1, double jd2, double *x2, double *y2, double *z2)
/***************************************************************************/
/* Passage des coordonnees cartes. equatoriales d'un equinoxe a un autre   */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,dz,zz,th,cosdz,sindz,coszz,sinzz,costh,sinth,a,b,c,x20,y20,z20;

   t=(jd2-jd1)/36525;
   tt=(jd1-2451545.0)/36525;
   dz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(0.30188-.000344*tt)*t*t+.017998*t*t*t;
   dz=dz/3600*DR;
   zz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(1.09468+.000066*tt)*t*t+.018203*t*t*t;
   zz=zz/3600*DR;
   th=(2004.3109-0.85330*tt-.000217*tt*tt)*t-(0.42665+.000217*tt)*t*t-.041833*t*t*t;
   th=th/3600*DR;
   cosdz=cos(dz);
   sindz=sin(dz);
   coszz=cos(zz);
   sinzz=sin(zz);
   costh=cos(th);
   sinth=sin(th);
   a= cosdz*costh*coszz-sindz*sinzz;
   b=-sindz*costh*coszz-cosdz*sinzz;
   c=-sinth*coszz;
   x20=x1*a+y1*b+z1*c;
   a= cosdz*costh*sinzz+sindz*coszz;
   b=-sindz*costh*sinzz+cosdz*coszz;
   c=-sinth*sinzz;
   y20=x1*a+y1*b+z1*c;
   a= cosdz*sinth;
   b=-sindz*sinth;
   c= costh;
   z20=x1*a+y1*b+z1*c;
   *x2=x20;
   *y2=y20;
   *z2=z20;
}

void mc_precad(double jd1, double asd1, double dec1, double jd2, double *asd2, double *dec2)
/***************************************************************************/
/* Passage des coordonnees spheri. equatoriales d'un equinoxe a un autre   */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,dz,zz,th,cosasddz,sinasddz,costh,sinth,cosdec,sindec,a,b,c;

   t=(jd2-jd1)/36525.;
   tt=(jd1-2451545.0)/36525.;
   dz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(0.30188-.000344*tt)*t*t+.017998*t*t*t;
   dz=dz/3600*DR;
   zz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(1.09468+.000066*tt)*t*t+.018203*t*t*t;
   zz=zz/3600*DR;
   th=(2004.3109-0.85330*tt-.000217*tt*tt)*t-(0.42665+.000217*tt)*t*t-.041833*t*t*t;
   th=th/3600*DR;
   cosasddz=cos(asd1+dz);
   sinasddz=sin(asd1+dz);
   costh=cos(th);
   sinth=sin(th);
   cosdec=cos(dec1);
   sindec=sin(dec1);
   a=cosdec*sinasddz;
   b=costh*cosdec*cosasddz-sinth*sindec;
   c=sinth*cosdec*cosasddz+costh*sindec;
   a=atan2(a,b)+zz;
   *asd2=fmod(4*PI+a,2*PI);
   *dec2=asin(c);
}

void mc_preclb(double jd1, double lon1, double lat1, double jd2, double *lon2, double *lat2)
/***************************************************************************/
/* Passage des coord. sph. ecliptiques d'un equinoxe a un autre            */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,eta,pi,p,psi,a,b,c;
   double coseta,sineta,coslonpi,sinlonpi,coslat,sinlat;

   t=(jd2-jd1)/36525;
   tt=(jd1-2451545.0)/36525;
   eta=(47.0029-0.06603*tt+0.000598*tt*tt)*t+(-0.03302+0.000598*tt)*t*t+.000060*t*t*t;
   eta=eta/3600*DR;
   pi=174.876384+(3289.4789*tt+0.60622*tt*tt-(869.8089+.50491*tt)*t+.03536*t*t)/3600;
   pi=pi*DR;
   p=(5029.0966+2.22226*tt-.000042*tt*tt)*t+(1.11113-.000042*tt)*t*t-.000006*t*t*t;
   p=p/3600*DR;
   psi=p+pi;
   coslonpi=cos(pi-lon1);
   sinlonpi=sin(pi-lon1);
   coseta=cos(eta);
   sineta=sin(eta);
   coslat=cos(lat1);
   sinlat=sin(lat1);
   a=coseta*coslat*sinlonpi-sineta*sinlat;
   b=coslat*coslonpi;
   c=coseta*sinlat+sineta*coslat*sinlonpi;
   a=psi-mc_atan2(a,b);
   *lon2=fmod(4*PI+a,2*PI);
   *lat2=mc_asin(c);
}

void mc_rhophi2latalt(double rhosinphip,double rhocosphip,double *latitude,double *altitude)
/***************************************************************************/
/* Retourne les valeurs de la latitude et de l'altitude a partir de        */
/* rhocosphi' et rhosinphi' (en rayons equatorial terrestres)              */
/***************************************************************************/
/* Latitude en degres decimaux.                                            */
/* Altitude en metres.                                                     */
/* Algo : Meeus "Astronomical Algorithms" p78                              */
/* On impose ici une altitude=0. A completer...                            */
/***************************************************************************/
{
   double aa,ff,bb,lat,alt,phip,rho,phi0,u0,rhosinphip0,rhocosphip0,rho0;
   double sinu0,cosu0,sinphi0,cosphi0,phip0;
   aa=6378140;
   ff=1./298.257;
   bb=aa*(1-ff);
   rho=sqrt(rhosinphip*rhosinphip+rhocosphip*rhocosphip);
   if (rho==0.) {
      *latitude=0.;
      *altitude=-aa;
      return;
   }
   phip=atan2(rhosinphip,rhocosphip);
   phi0=atan(aa*aa/bb/bb*tan(phip)); /* alt=0 */
   u0=atan(bb/aa*tan(phi0));
   sinu0=sin(u0);
   cosu0=cos(u0);
   sinphi0=sin(phi0);
   cosphi0=cos(phi0);
   for (alt=-1000;alt<20000.;alt+=0.1) {
      rhosinphip0 = bb/aa*sinu0 + alt/aa*sinphi0 ;
      rhocosphip0 =       cosu0 + alt/aa*cosphi0 ;
      rho0=sqrt(rhosinphip0*rhosinphip0+rhocosphip0*rhocosphip0);
      phip0=atan2(rhosinphip0,rhocosphip0);
      if ((rho-rho0)<0) {
         break;
      }
   }
   lat=phi0;
   alt-=0.1;
   *latitude=lat/(DR);
   *altitude=alt;
}

void mc_refraction(double h,int inout,double temperature,double pressure,double *refraction)
/***************************************************************************/
/* Retourne la valeur de la refraction.                                    */
/***************************************************************************/
/* h hauteur sur l'horizon (radians)                                       */
/* inout = +1 pour le sens "sans air" -> "apparent"                        */
/*            alors h est la hauteur vraie sans air                        */
/*         -1 pour le sens "apparent" -> "sans air"                        */
/*            alors h est la hauteur apparente                             */
/* temperature en K                                                        */
/* Pressure en Pascal                                                      */
/* refraction en radians                                                   */
/* Algo : Meeus "Astronomical Algorithms" p101-103                         */
/***************************************************************************/
{
   double r,angle;
   if (inout==-1) {
      h=h/(DR);
	  angle=(h+7.31/(h+4.4))*(DR);
	  r=1./tan(angle);
	  r=r-0.06*sin((14.7*r+13)*(DR));
	  r=r/60.*(DR);
   } else {
      h=h/(DR);
	  angle=(h+10.3/(h+5.11))*(DR);
	  r=1.02/tan(angle);
	  r=r/60.*(DR);
   }
   if (temperature>0.) {
      r=r*fabs(pressure)/101000.*283/temperature;
   }
   *refraction=r;
}

