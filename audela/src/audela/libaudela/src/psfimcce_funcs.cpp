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
// nonlinear least-squares fit, Marquardt's method
#include "psfimcce.h"
#include <math.h>


/*
a[1] = sky
a[2] = intensity
a[3] = x0
a[4] = y0
a[5] = sigx
a[6] = sigy
a[7] = theta
*/

void coeff2param (int npt, float **zs, float *a, float *p)
{

p[0]=a[2];               // maxx 
p[1]=a[3];               // posx 
p[2]=a[5]*2.35482;   // fwhmx
p[3]=a[1];               // fondx
p[4]=a[2];               // maxy 
p[5]=a[4];               // posy 
p[6]=a[6]*2.35482;   // fondy
p[7]=a[1];               // fwhmy

}


void fgauss(float x, float a[], float *y, float dyda[], int na)
{
	int i;
	float fac,ex,arg;

	*y=0.0;
	for (i=1;i<=na-1;i+=3) {
		arg=(x-a[i+1])/a[i+2];
		ex=exp(-arg*arg);
		fac=a[i]*ex*2.0*arg;
		*y += a[i]*ex;
		dyda[i]=ex;
		dyda[i+1]=fac/a[i+2];
		dyda[i+2]=fac*arg/a[i+2];
	}
}


/*
a[1] = sky
a[2] = intensity
a[3] = x0
a[4] = sigx
*/
void fgauss1(float x, float a[], float *y, float dyda[], int na)
{
	float fac,ex,arg;

	*y=0.0;

   //printf("fgauss1 A : %f %f %f %f \n",a[1],a[2],a[3],a[4]);
	arg=(x-a[3])/a[4];
	ex=exp(-arg*arg);
	fac=a[2]*ex*2.0*arg;
	*y = a[1]+a[2]*ex;
	dyda[1]=1;
	dyda[2]=ex;
	dyda[3]=fac/a[4];
	dyda[4]=fac*arg/a[4];

}
void fgauss2(float x, float a[], float *y)
{

	float ex,arg;

	*y=0.0;

	arg=(x-a[3])/a[4];
	ex=exp(-arg*arg);
	*y = a[1]+a[2]*ex;

}
void fgauss3(float x, float a[], float *y, float dyda[], int na)
{

	float fac,ex,arg;

	*y=0.0;

	arg=(x-a[2])/a[3];
	ex=exp(-arg*arg);
	fac=a[1]*ex*2.0*arg;
	*y = a[1]*ex;
	dyda[1]=ex;
	dyda[2]=fac/a[3];
	dyda[3]=fac*arg/a[3];

}




/*
a[1] = sky
a[2] = intensity
a[3] = x0
a[4] = y0
a[5] = sigx
a[6] = sigy
a[7] = theta
*/
void fgauss1_2d(float x1, float x2, float a[], float *y, float dyda[], int na)
{
	float ex;
	float ga,gb,gc;

   //printf("fgauss1_2d A : %f %f %f %f %f %f %f\n",a[1],a[2],a[3],a[4],a[5],a[6],a[7]);

	*y=0.0;

   ga = pow(cos(a[7]), 2) * pow(a[5], -2) / 2 + pow(sin(a[7]), 2) * pow(a[6], -2) / 2;
   gb = -sin(2 * a[7]) * pow(a[5], -2) / 4 + sin(2 * a[7]) * pow(a[6], -2) / 4;
   gc = pow(sin(a[7]), 2) * pow(a[5], -2) / 2 + pow(cos(a[7]), 2) * pow(a[6], -2) / 2;
   ex = exp(- ga * pow(x1 - a[3], 2) - 2 * gb * (x1 - a[3]) * (x2 - a[4]) - gc * pow(x2 - a[4], 2));


   *y = a[1] + a[2] * ex;

   dyda[1] = 1;
   dyda[2] = ex;
   dyda[3] = a[2] * (2 * ga * (x1 - a[3]) + 2 * gb * (x2 - a[4])) * ex;
   dyda[4] = a[2] * (2 * gb * (x1 - a[3]) + 2 * gc * (x2 - a[4])) * ex;
   dyda[5] = a[2] * (pow(cos(a[7]), 2) * pow(x1 - a[3], 2) * pow(a[5], -3) 
             - sin(2 * a[7]) * (x1 - a[3]) * (x2 - a[4]) * pow(a[5], -3) 
             + pow(sin(a[7]), 2) * pow(x2 - a[4], 2) * pow(a[5], -3)) * ex;
   dyda[6] = a[2] * (pow(sin(a[7]), 2) * pow(a[6], -3) * pow(x1 - a[3], 2) 
             + sin(2 * a[7]) * pow(a[6], -3) * (x1 - a[3]) * (x2 - a[4]) 
             + pow(cos(a[7]), 2) * pow(a[6], -3) * pow(x2 - a[4], 2)) * ex;
   dyda[7] = a[2] * (-(-cos(a[7]) * pow(a[5], -2) * sin(a[7]) + sin(a[7]) 
             * pow(a[6], -2) * cos(a[7])) * pow(x1 - a[3], 2) - 2 
             * (-cos(2 * a[7]) * pow(a[5], -2) / 2 + cos(2 * a[7]) 
             * pow(a[6], -2) / 2) * (x1 - a[3]) * (x2 - a[4]) - (cos(a[7]) 
             * pow(a[5], -2) * sin(a[7]) - sin(a[7]) * pow(a[6], -2) * cos(a[7])) 
             * pow(x2 - a[4], 2)) * ex;

}








void myprint (float  **z, int npt) 
{
   int i, j;


   printf("       "); for(i=1;i<=npt;i++) printf("%2d   ",i); printf("\n");

   for(i=1;i<=npt;i++) {
      printf("%2d : ",i);
      for(j=1;j<=npt;j++) {
         printf("%4.0f ",z[i][j]);
      }
      printf("\n");
   }

}



void minmax (float  **z, float *min, float *max, float *x, float *y, int npt) 
{

   int i, j;

   *min = z[1][1];
   *max = z[1][1];
   for (i=1; i <= npt; i++) {
      for (j=1; j <= npt; j++) {
         if (*min > z[i][j]) *min = z[i][j];
         if (*max < z[i][j]) {
            *max = z[i][j];
            *x = i;
            *y = j;
         }
      }
   }
}



void fit_gauss2D (int npt, float **zs, float *a) 
{
   int i, j, k, itst, n, cpt, log;
   float *dyda;
	float alamda, chisq, ochisq, mean;
	float **covar,**alpha, **z, **residus;
   float  min, max, sky;
	int *ia;
	float **sig;
	float x0,y0;
	float *x,*y;
   
   log = 0;

   dyda    = vector(1,MA);
	covar   = matrix(1,MA,1,MA);
	alpha   = matrix(1,MA,1,MA);
	z       = matrix(1,npt,1,npt);
	residus = matrix(1,npt,1,npt);
	ia      = ivector(1,MA);
	sig     = matrix(1,npt,1,npt);
	x       = vector(1,npt);
	y       = vector(1,npt);


   /* Calcul mini maxi de z */
   minmax (zs,&min,&max, &x0, &y0, npt);
   if (log) printf("min = %f max = %f\n",min,max);

   /*
     Nouvelle forme de la gaussienne a ajuster. on lui retire un fond.
   */
   for (i=1; i <= npt; i++) {
      x[i] = i;
      y[i] = i;
   }
   for (i=1; i <= npt; i++) {
      for (j=1; j <= npt; j++) {
         z[i][j] = zs[i][j] - min;
      }
   }

   for(i=1;i<=npt;i++) {
      for(j=1;j<=npt;j++) {
         sig[i][j]=0.001;
      }
   }
//   myprint(sig,npt);

	for (i=1;i<=MA;i++) ia[i]=1;
   ia[1]=1;
   ia[2]=1;
   ia[3]=1;
   ia[4]=1;
   ia[5]=1;
   ia[6]=1;
   ia[7]=1;

   /*
     Nouvelle forme des parametres a ajuster (on a soustrait le fond)
   */
   a[1] = 0;
   a[2] = max-min;
   a[3] = x0;
   a[4] = y0;
   a[5] = 1.1;
   a[6] = 1.0;
   a[7] = 0 * M_PI / (float)180;

   sky = min;

   /*
     Lancement des iterations generales
   */
   cpt=0;
	for (n=1;n<=4;n++) {

      k = 0;

      /*
        Ajustement Initial
      */
      alamda = -1;
      mrqmin2D(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda);
      cpt++;

      /*
        Lancement des iterations pour un sky fixé
      */
      k = 1;
	   itst=0;

	   for (;;) {

         if (log) { 
	         printf("\n%s %2d %17s %10.4f %10s %9.2e\n","Iteration #",k,
	            "chi-squared:",chisq,"alamda:",alamda);
	         for (i=1;i<=MA;i++) printf("  a[%d]  ",i); printf("\n");
	         for (i=1;i<=MA;i++) printf("%9.4f",a[i]);
	         printf("\n");
         }
         
         k++;
		   ochisq=chisq;

         mrqmin2D(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda);
         cpt++;

		   if (chisq > ochisq)
			   itst=0;
		   else if (fabs(ochisq-chisq) < 0.001)
			   itst++;
		   if (itst < 4) continue;

		   alamda=0.0;
         mrqmin2D(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda);
         cpt++;

         if (log) { 
		      printf("\nUncertainties:\n");
	         for (i=1;i<=MA;i++) printf(" dea[%d] ",i); printf("\n");
		      for (i=1;i<=MA;i++) printf("%9.4f",sqrt(covar[i][i]));
		      printf("\n");
         }

         /*
         printf("press return to continue with constraint\n");
         (void) getchar();
         */

		   break;
      }

      /*
        Calcul du nouveau sky
      */
      mean = 0;
      for(i=1;i<=npt;i++) {
         for(j=1;j<=npt;j++) {
            fgauss1_2d(x[i], y[j], a, &z[i][j], dyda, MA);
            residus[i][j] = sky + z[i][j] - zs[i][j];
            mean += residus[i][j];
         }
      }
      mean = mean / pow(npt,2) ;
      
      if (log) printf("mean = %f a1 = %f\n",mean,a[1]);

      a[1] += mean;
      sky += a[1];
      if (log) printf("sky = %f \n",sky);
      

      /*
        On enleve le sky
      */
      for(i=1;i<=npt;i++) {
         for(j=1;j<=npt;j++) {
            z[i][j] = zs[i][j] - sky;
         }
      }

      if (fabs(a[1])<0.01) break;
         
      a[1] = 0;
      /*
       printf("press return to continue with constraint\n");
       (void) getchar();
      */
   }
   a[1] = sky;

   if (log) { 
      printf("chisq: %f \n",chisq);
      printf("nb mrqmin: %d \n",cpt);
      printf("nb loop: %d \n",n);
	   printf("\nUncertainties:\n");
	   for (i=1;i<=MA;i++) printf("      %d   ",ia[i]);  printf("\n");
	   for (i=1;i<=MA;i++) printf("    a[%d]  ",i); printf("\n");
	   for (i=1;i<=MA;i++) printf("%9.4f ",sqrt(covar[i][i]));
	   printf("\n");
   }
   
	free_matrix(z,1,npt,1,npt);
	free_matrix(residus,1,npt,1,npt);
	free_matrix(sig,1,npt,1,npt);

   free_vector(dyda,1,MA);
	free_matrix(alpha,1,MA,1,MA);
	free_matrix(covar,1,MA,1,MA);
	free_ivector(ia,1,MA);
	free_vector(y,1,npt);
	free_vector(x,1,npt);
   return;

 }








