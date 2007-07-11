/* mc_plnt3.c
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
/* Calculs d'ephemerides precises des planetes, du Soleil ...              */
/***************************************************************************/
#include "mc.h"

void mc_jd2lbr1c(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0)
/***************************************************************************/
/* Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr  */
/* pour l'equinoxe moyen de la date. (longitudes vraies)                   */
/* JUPITER                                                                 */
/***************************************************************************/
/* Les tableaux l, m et u doivent etre dimensiones chacun avec             */
/* 9 elements (0 a 8) et sont initialises dans la fonction mc_jd2lbr1a     */
/***************************************************************************/
{
   double t,l0,b0,r0;
   u[0]*=1.;
   t=(jj-2415020.0)/36525;
      l0=2511+5023*t+19934*sin(m[4])+601*sin(2*m[4])+1093*cos(2*m[4]-5*m[5])
         -479*sin(2*m[4]-5*m[5])-185*sin(2*m[4]-2*m[5])+137*sin(3*m[4]-5*m[5])-131*sin(m[4]-2*m[5])
         +79*cos(m[4]-m[5])-76*cos(2*m[4]-2*m[5])-74*t*cos(m[4])+68*t*sin(m[4]);
      l0+=(+66*cos(2*m[4]-3*m[5])+63*cos(3*m[4]-5*m[5])+53*cos(m[4]-5*m[5])+49*sin(2*m[4]-3*m[5])
         -43*t*sin(2*m[4]-5*m[5])-37*cos(m[4])+25*sin(2*l[4])+25*sin(3*m[4])-23*sin(m[4]-5*m[5])
         -19*t*cos(2*m[4]-5*m[5])+17*cos(2*m[4]-4*m[5]));
      l0+=(+17*cos(3*m[4]-3*m[5])-14*sin(m[4]-m[5]));
      l0+=(-13*sin(3*m[4]-4*m[5])-9*cos(2*l[4])+9*cos(m[5])-9*sin(m[5])-9*sin(3*m[4]-2*m[5])
         +9*sin(4*m[4]-5*m[5])+9*sin(2*m[4]-6*m[5]+3*m[6])-8*cos(4*m[4]-10*m[5])+7*cos(3*m[4]-4*m[5])
         -7*cos(m[4]-3*m[5])-7*sin(4*m[4]-10*m[5]));
      l0+=(-7*sin(m[4]-3*m[5])+6*cos(4*m[4]-5*m[5]));
      l0+=(-6*sin(3*m[4]-3*m[5])+5*cos(2*m[5])-4*sin(4*m[4]-4*m[5])-4*cos(3*m[5])+4*cos(2*m[4]-m[5])
         -4*cos(3*m[4]-2*m[5])-4*t*cos(2*m[4])+3*t*sin(2*m[4])+3*cos(5*m[5])+3*cos(5*m[4]-10*m[5])
         +3*sin(2*m[5])-2*sin(2*l[4]-m[4])+2*sin(2*l[4]+m[4]));
      l0+=(-2*t*sin(3*m[4]-5*m[5])-2*t*sin(m[4]-5*m[5]));
      l0=l[4]+l0/3600*DR;
      b0=-4692*cos(m[4])+259*sin(m[4])+227-227*cos(2*m[4])+30*t*sin(m[4])+21*t*cos(m[4])
         +16*sin(3*m[4]-5*m[5])-13*sin(m[4]-5*m[5])-12*cos(3*m[4])+12*sin(2*m[4])+7*cos(3*m[4]-5*m[5])
         -5*cos(m[4]-5*m[5]);
      b0=b0/3600*DR;
      r0=5.20883-.25122*cos(m[4])-.00604*cos(2*m[4])+.0026*cos(2*m[4]-2*m[5])
         -.00170*cos(3*m[4]-5*m[5])-.0016*sin(2*m[4]-2*m[5])-.00091*t*sin(m[4])
         -.00084*t*cos(m[4])+.00069*sin(2*m[4]-3*m[5])-.00067*sin(m[4]-5*m[5]);
      r0+=(.00066*sin(3*m[4]-5*m[5])+.00063*sin(m[4]-m[5])-.00051*cos(2*m[4]-3*m[5])
         -.00046*sin(m[4])-.00029*cos(m[4]-5*m[5])+.00027*cos(m[4]-2*m[5])
         -.00022*cos(3*m[4])-.00021*sin(2*m[4]-5*m[5]));
   *ll0=l0;
   *bb0=b0;
   *rr0=r0;
}

void mc_jd2lbr1d(double jj, double *ll0, double *bb0, double *rr0)
/***************************************************************************/
/* Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr  */
/* pour l'equinoxe moyen de la date. (longitudes vraies)                   */
/* LUNE                                                                    */
/***************************************************************************/
/***************************************************************************/
{
int arg_lr[4*60]={
0,0,1,0,
2,0,-1,0,
2,0,0,0,
0,0,2,0,
0,1,0,0,
0,0,0,2,
2,0,-2,0,
2,-1,-1,0,
2,0,1,0,
2,-1,0,0,
0,1,-1,0,
1,0,0,0,
0,1,1,0,
2,0,0,-2,
0,0,1,2,
0,0,1,-2,
4,0,-1,0,
0,0,3,0,
4,0,-2,0,
2,1,-1,0,
2,1,0,0,
1,0,-1,0,
1,1,0,0,
2,-1,1,0,
2,0,2,0,
4,0,0,0,
2,0,-3,0,
0,1,-2,0,
2,0,-1,2,
2,-1,-2,0,
1,0,1,0,
2,-2,0,0,
0,1,2,0,
0,2,0,0,
2,-2,-1,0,
2,0,1,-2,
2,0,0,2,
4,-1,-1,0,
0,0,2,2,
3,0,-1,0,
2,1,1,0,
4,-1,-2,0,
0,2,-1,0,
2,2,-1,0,
2,1,-2,0,
2,-1,0,-2,
4,0,1,0,
0,0,4,0,
4,-1,0,0,
1,0,-2,0,
2,1,0,-2,
0,0,2,-2,
1,1,1,0,
3,0,-2,0,
4,0,-3,0,
2,-1,2,0,
0,2,1,0,
1,1,-1,0,
2,0,3,0,
2,0,-1,-2 };

int sinl[60]={
6288774,
1274027,
658314,
213618,
-185116,
-114332,
58793,
57066,
53322,
45758,
-40923,
-34720,
-30383,
15327,
-12528,
10980,
10675,
10034,
8548,
-7888,
-6766,
-5163,
4987,
4036,
3994,
3861,
3665,
-2689,
-2602,
2390,
-2348,
2236,
-2120,
-2069,
2048,
-1773,
-1595,
1215,
-1110,
-892,
-810,
759,
-713,
-700,
691,
596,
549,
537,
520,
-487,
-399,
-381,
351,
-340,
330,
327,
-323,
299,
294,
0};

int cosr[60]={
-20905355,
-3699111,
-2955968,
-569925,
48888,
-3149,
246158,
-152138,
-170733,
-204586,
-129620,
108743,
104755,
10321,
0,
79661,
-34782,
-23210,
-21636,
24208,
30824,
-8379,
-16675,
-12831,
-10445,
-11650,
14403,
-7003,
0,
10056,
6322,
-9884,
5751,
0,
-4950,
4130,
0,
-3958,
0,
3258,
2616,
-1897,
-2117,
2354,
0,
0,
-1423,
-1117,
-1571,
-1739,
0,
-4421,
0,
0,
0,
0,
1165,
0,
0,
8752
};

int arg_b[4*60]={
0,0,0,1,
0,0,1,1,
0,0,1,-1,
2,0,0,-1,
2,0,-1,1,
2,0,-1,-1,
2,0,0,1,
0,0,2,1,
2,0,1,	-1,
0,0,2,	-1,
2,-1,0,-1,
2,0,-2,-1,
2,0,1,1,
2,1,0,-1,
2,-1,-1,1,
2,-1,0,1,
2,-1,-1,-1,
0,1,-1,-1,
4,0,-1,-1,
0,1,0,1,
0,0,0,3,
0,1,-1,1,
1,0,0,1,
0,1,1,1,
0,1,1,-1,
0,1,0,-1,
1,0,0,-1,
0,0,3,1,
4,0,0,-1,
4,0,-1,1,
0,0,1,-3,
4,0,-2,1,
2,0,0,-3,
2,0,2,-1,
2,-1,1,-1,
2,0,-2,1,
0,0,3,-1,
2,0,2,1,
2,0,-3,-1,
2,1,-1,1,
2,1,0,1,
4,0,0,1,
2,-1,1,1,
2,-2,0,-1,
0,0,1,3,
2,1,1,-1,
1,1,0,-1,
1,1,0,1,
0,1,-2,-1,
2,1,-1,-1,
1,0,1,1,
2,-1,-2	-1,
0,1,2,1,
4,0,-2,-1,
4,-1,-1,-1,
1,0,1,-1,
4,0,1,-1,
1,0,-1,-1,
4,-1,0,-1,
2,-2,0,1
};

int sinb[60]={
5128122,
280602,
277693,
173237,
55413,
46271,
32573,
17198,
9266,
8822,
8216,
4324,
4200,
-3359,
2463,
2211,
2065,
-1870,
1828,
-1794,
-1749,
-1565,
-1491,
-1475,
-1410,
-1344,
-1335,
1107,
1021,
833,
777,
671,
607,
596,
491,
-451,
439,
422,
421,
-366,
-351,
331,
315,
302,
-283,
-229,
223,
223,
-220,
-220,
-185,
181,
-177,
176,
166,
-164,
132,
-119,
115,
107
};






double T,lp,d,m,mp,f,a1,a2,a3,e,e2,xe;
double l,b,r,angle,sina,cosa;
int k;

T=(jj-2451545.)/36525.;
lp=(218.3164591+481267.88134236*T-.0013268*T*T+T*T*T/538841.-T*T*T*T/65194000)*(DR);
d=(297.8502042+445267.1115168*T-.00016300*T*T+T*T*T/545868-T*T*T*T/113065000)*(DR);
m=(357.5291092+35999.0502909*T-.0001536*T*T+T*T*T*T/24490000)*(DR);
mp=(134.9634114+477198.8676313*T+.0089970*T*T+T*T*T/69699.-T*T*T*T/14712000)*(DR);
f=(93.2720993+483202.0175273*T-.0034029*T*T+T*T*T/3526000+T*T*T*T/863310000)*(DR);
a1=(119.75+131.849*T)*(DR);
a2=(53.09+479264.290*T)*(DR);
a3=(313.45+481266.484*T)*(DR);
e=1-.002516*T-.0000074*T*T;
e2=e*e;

/* --- longitude & radius ---*/
l=0.;
r=0.;
for (k=0;k<60;k++) {
   xe=1.;
   if (fabs(arg_lr[k*4+1])==1) {xe=e;}
   else if (fabs(arg_lr[k*4+1])==2) {xe=e2;}
   angle=1.*arg_lr[k*4+0]*d+arg_lr[k*4+1]*m*xe+arg_lr[k*4+2]*mp+arg_lr[k*4+3]*f;
   sina=sin(angle);
   cosa=cos(angle);
   l+=sinl[k]*sina;
   r+=cosr[k]*cosa;
}
l+=3958.*sin(a1)+1962.*sin(lp-f)+318.*sin(a2);

/* --- latitude ---*/
b=0.;
for (k=0;k<60;k++) {
   xe=1.;
   if (fabs(arg_b[k*4+1])==1) {xe=e;}
   else if (fabs(arg_b[k*4+1])==2) {xe=e2;}
   angle=1.*arg_b[k*4+0]*d+arg_b[k*4+1]*m*xe+arg_b[k*4+2]*mp+arg_b[k*4+3]*f;
   sina=sin(angle);
   b+=sinb[k]*sina;
}
b+=-2235.*sin(lp)+382.*sin(a3)+175.*sin(a1-f)+175.*sin(a1+f)+127.*sin(lp-mp)-115.*sin(lp+mp);

l=lp+(l*1.0e-6)*(DR);
b=(b*1.0e-6)*(DR);
r=(385000.56e3+r)/(UA);

*ll0=l;
*bb0=b;
*rr0=r;
return;
}

