/* mc_cata1.c
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
/* Calculs utilitaires avec le catalogue Hipparcos                         */
/***************************************************************************/
#include "mc.h"

/* Equinox=2451545.00000 Epoch=2448349.06250 */
/*
          1         2         3         4         5         6         7         8         9        10
 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
H|           1| |00 00 00.22|+01 05 20.4| 9.10| |H|000.00091185|+01.08901332| |   3.54|   -5.20|   -1.88|  1.32|  0.74|  1.39|  1.36|  0.81| 0.32|-0.07|-0.11|-0.24| 0.09|-0.01| 0.10|-0.01| 0.01| 0.34|  0| 0.74|     1| 9.643|0.020| 9.130|0.019| | 0.482|0.025|T|0.55|0.03|L| | 9.2043|0.0020|0.017| 87| | 9.17| 9.24|       | | | |          | |  | 1| | | |  |   |       |     |     |    |S| | |224700|B+00 5077 |          |          |0.66|F5          |S 
*/

int mc_readhip(char *hip_main_file, int *nstars, mc_cata_astrom *hips) {
   FILE *f;
   char ligne[1024];
   char temp1[10];
   int k,n;
   /* --- read the WCS ascii file ---*/
   f=fopen(hip_main_file,"rt");
   if (f==NULL) {
      return 1;
   }
   k=0;
   while (feof(f)==0) {
      if (fgets(ligne,1024,f)==NULL) {
         continue;
      }
      if (strlen(ligne)>2) {
         n=62-51+1;
         strncpy(temp1,ligne+51,n);
         temp1[n]='\0';
         hips[k].ra=atof(temp1);
         n=75-64+1;
         strncpy(temp1,ligne+64,n);
         temp1[n]='\0';
         hips[k].dec=atof(temp1);
         k++;
      }
   }
   fclose(f);
	return 0;
}
