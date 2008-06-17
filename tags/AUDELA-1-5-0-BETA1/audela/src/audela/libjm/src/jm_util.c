/* jm_util.c
 *
 * This file is part of the libjm libfrary for AudeLA project.
 *
 * Initial author : Jacques MICHELET <jacques.michelet@laposte.net>
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

/* Projet      : AudeLA
 * Librairie   : LIBJM
 * Fichier     : JM_UTIL.C
 * Description : Fonctions utilitaires
 */

#include "jm.h"

/* ***************** dms2deg *******************
 * dms2deg
 * Convertie un angle en degrés/minutes/secondes
 * en degrés décimaux
 * *********************************************/
int dms2deg(int d,int m,double s,double *angle)
{
	*angle=((s/60.0+(double)m)/60)+(double)d;
return OK;
}

/* ******************* jd *********************
 * Donne le jour julien correspondant a la date
 * annee : valeur de l'annee correspondante
 * mois  : valeur du mois correspondant
 * jour  : valeur du jour decimal correspondant
 * *jj   : valeur du jour julien converti
 * ********************************************/
int jd(int annee,int mois,double jour,double *jj)
{
double a,m,j,aa,bb;

a=(double)annee;
m=(double)mois;
j=jour;
   
if (m<=2) 
   {
   a=a-1;
   m=m+12;
   }

aa=floor(a/100);
bb=2-aa+floor(aa/4);
*jj=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
return OK;
}

/* ******************* jd2 *********************
 * Donne le jour julien correspondant a la date
 * annee   : valeur de l'annee correspondante
 * mois    : valeur du mois correspondant
 * jour    : valeur du jour correspondant
 * heure   : valeur des heures correspondantes
 * minute  : valeur des minutes correspondantes
 * minute  : valeur des secondes correspondantes
 * seconde : valeur des milli-secondes correspondantes
 * *jj   : valeur du jour julien converti
 * ********************************************/
int jd2 (int annee,int mois,int jour,int heure,int minute,int seconde,int milli,double *jj)
{
	double jour_decimal;
	jour_decimal = jour + (heure / 24.0) + (minute / 1440.0)
		+ (seconde / 86400.0) + (milli / 86400000.0);
	return jd(annee, mois, jour_decimal, jj);
}

int jc (int *annee, int *mois, double *jour, double jj)
{
	double jjj, z, f, a, alpha, b, c, d, e;

	jjj = jj + 0.5;
	z = floor(jjj);
	f = jjj - z;

	if (z < 2299161.0)
		a = z;
	else
	{
		alpha = floor((z - 1867216.25)/36524.25);
		a = z + 1 + alpha - floor(alpha / 4);
	}

	b = a + 1524;
	c = floor((b - 121.1) / 365.25);
	d = floor(365.25 * c);
	e = floor((b - d) / 30.6001);

	*jour = b - d - floor(30.6001 * e) + f;
	if (e < 14)
		*mois = (int)(e - 1);
	else
		*mois = (int)(e - 13);
	if (*mois > 2)
		*annee = (int)(c - 4716);
	else
		*annee = (int)(c - 4715);

	return OK;
}

/* ***************** jc2 ****************************
 * Conversion d'un jour julien en jour calendaire
 * **************************************************/
int jc2(int *annee, int *mois, int *jour, int *heure, int *minute, int *seconde, int *milli, double jj)
{
  double jour_decimal, t;
  
  
  /* Conversion en date calendaire */
  jc(annee, mois, &jour_decimal, jj);
  *jour = (int)floor(jour_decimal);
  t = 24.0 * (jour_decimal - (double)(*jour));
  *heure = (int)floor(t);
  t = 60.0 * (t - (double)(*heure));
  *minute = (int)floor(t);
  t = 60.0 * (t - (double)(*minute));
  *seconde = (int)floor(t);
  t = 1000.0 * (t - (double)(*seconde));
  *milli = (int)floor(t);
  return OK;
}







