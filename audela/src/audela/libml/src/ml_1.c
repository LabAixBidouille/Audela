/* ml_1.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <laas@obs-hp.fr>
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
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Le include ml.h ne contient pas d'infos concernant Tcl.                */
/***************************************************************************/
#include "ml.h"

void ml_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle)
/***************************************************************************/
/* Calcul de l'angle de separation et de l'angle de position au pole nord  */
/* a partir de deux coordonnees spheriques.                                */
/***************************************************************************/
/***************************************************************************/
{
   double a,b,c,aa,d3,a3;
   double pi;
   pi=4.*atan(1);
   d3=pi/2;
   a3=0;
   a=(sin(d2)*sin(d3)+cos(d2)*cos(d3)*cos(a2-a3));
   if (a<-1.) {a=-1.;}
   if (a>1.) {a=1.;}
   a=acos(a);
   b=(sin(d1)*sin(d3)+cos(d1)*cos(d3)*cos(a1-a3));
   if (b<-1.) {b=-1.;}
   if (b>1.) {b=1.;}
   b=acos(b);
   c=(sin(d1)*sin(d2)+cos(d1)*cos(d2)*cos(a1-a2));
   if (c<-1.) {c=-1.;}
   if (c>1.) {c=1.;}
   c=acos(c);
   if (b*c!=0.) {
      aa=((cos(a)-cos(b)*cos(c))/(sin(b)*sin(c)));
      aa=(aa>1)?1.:aa;
      aa=(aa<-1)?-1.:aa;
      aa=acos(aa);
      if (sin(a2-a1)<0) {
         aa=-aa;
      }
      aa=fmod(aa+4*pi,2*pi);
   } else {
	  aa=0.;
   }
   *dist=c;
   *posangle=aa;
}

void ml_date2jd(double annee, double mois, double jour, double heure, double minute, double seconde, double *jj)
/***************************************************************************/
/* Donne le jour julien correspondant a la date                            */
/***************************************************************************/
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   a=annee;
   m=mois;
   j=jour+((((seconde/60.)+minute)/60.)+heure)/24.;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   *jj=jd;
}
