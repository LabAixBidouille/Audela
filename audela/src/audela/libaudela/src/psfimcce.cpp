/* 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Frederic Vachier <fv@imcce.fr>
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
#include <stdio.h>
#include "cpixels.h"
#include "psfimcce.h"
#include <math.h>

// loadima i
// buf1 psfimcce {426 863 477 903}
void CPixels::call_psfimcce(int npt, double **z, double *p)
{
   float *a, *pr;
   float **zs;
   int i,j;
   
   a  = vector(1,MA);
   pr  = vector(0,7);
	zs = matrix(1,npt,1,npt);

   for(i=1;i<=npt;i++) {
      for(j=1;j<=npt;j++) {
         zs[i][j] = (float)z[i][j];
      }
   }

   //printf("calcul = %d\n",npt);
   fit_gauss2D(npt,zs,a); 
   coeff2param(npt, zs, a, pr);

   p[0] = pr[0];
   p[1] = pr[1];
   p[2] = pr[2];
   p[3] = pr[3];
   p[4] = pr[4];
   p[5] = pr[5];
   p[6] = pr[6];
   p[7] = pr[7];

/*
   printf("coeff\n");
	for (i=1;i<=MA;i++) printf("  a[%d]  ",i); printf("\n");
	for (i=1;i<=MA-1;i++) printf("%9.4f ",a[i]); 
   printf("%9.4f ",a[7] / M_PI * (float)180 ); 
   printf("\n");
*/
   free_vector(a,1,MA);
   free_vector(pr,0,7);
	free_matrix(zs,1,npt,1,npt);


//   printf("toto = %d\n", MA);
   return;
}
