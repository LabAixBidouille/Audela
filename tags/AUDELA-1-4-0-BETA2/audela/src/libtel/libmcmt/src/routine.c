/* routine.c
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

#include "telescop.h"
#include "routine.h"
#include <math.h>

const unsigned short Pas_Moteur=200;
extern T_Parameter_Axe Axe[2];
extern double Vitesse_Siderale;


int Resolution_Factor(int Reso_Int)
/* transform MCMT resolution-> number of µstep in one step */
{
	int Reso;
	Reso=128/Reso_Int;
	return Reso;
}

int CalculRampe(int Pente,int V_Debut,int V_Fin,int *Pas, double *Temps)
{
   int Timer0,Timer1,V,Int_Prov;
   Timer0=0;
   Timer1=0;
   *Pas=0;
   *Temps=0;
   V=V_Debut;
   if (V_Fin<=V_Debut)
   {
      while (V>V_Fin)
      {
         Timer0++;
         Timer1++;
         if (Timer0>=7680)
         {
            Timer0=0;
            Int_Prov = V >> Pente;
            if (Int_Prov==0) Int_Prov=1;
            V=V - Int_Prov;
            *Temps=*Temps+0.012288;
         } /* endif */
         if (Timer1>=V)
         {
            Timer1=0;
            *Pas=*Pas+1;
         } /* end if */
      } /* end while */
   } /* end if */
   else
   {
      while (V<V_Fin)
      {
         Timer0++;
         Timer1++;
         if (Timer0>=7680)
         {
            Timer0=0;
            Int_Prov = V >> Pente;
            if (Int_Prov==0) Int_Prov=1;
            V=V + Int_Prov;
            *Temps=*Temps+0.012288;
         } /* end if */
         if (Timer1>=V)
         {
            Timer1=0;
            *Pas=*Pas+1;
         } /* end if */
      } /* end while */
   } /* end else */
   return 0;
}


T_Parameter_Axe Fill_Vitesse(T_Parameter_Axe Entree)
{
   T_Parameter_Axe Parameter;
   Parameter=Entree;
   if (Parameter.Resolution[Guidage] != 0)
   {
      Parameter.Factor[Guidage]=Pas_Moteur*Resolution_Factor(Parameter.Resolution[Guidage])*
      Parameter.Dent;
      Parameter.Step[Guidage]=1/(Parameter.V_Guidage+Parameter.V_Guidage_LSB/10.0)/
                       0.0000016;
      Parameter.Vitesse[Guidage]=360*Parameter.Step[Guidage]/Parameter.Factor[Guidage];
   }
   else
   {
/*      Parameter.Factor[Guidage]=0;   */
      Parameter.Factor[Guidage]=Pas_Moteur*128*Parameter.Dent;
      Parameter.Step[Guidage]=0.000001;
      Parameter.Vitesse[Guidage]=1e-12;
   }
   if (Parameter.Resolution[Corec_Moins] != 0)
   {
      Parameter.Factor[Corec_Moins]=Pas_Moteur*
      Resolution_Factor(Parameter.Resolution[Corec_Moins])*Parameter.Dent;
      Parameter.Step[Corec_Moins]=1/(Parameter.V_Corec_Moins*0.0000016);
      Parameter.Vitesse[Corec_Moins]=360*Parameter.Step[Corec_Moins]/
                   Parameter.Factor[Corec_Moins];
   }
   else
   {
      Parameter.Factor[Corec_Moins]=0;
      Parameter.Step[Corec_Moins]=1e-6;
      Parameter.Vitesse[Corec_Moins]=1e-12;
   }
   if (Parameter.Resolution[Corec_Plus] != 0)
   {
      Parameter.Factor[Corec_Plus]=Pas_Moteur*
      Resolution_Factor(Parameter.Resolution[Corec_Plus])*Parameter.Dent;
      Parameter.Step[Corec_Plus]=1/(Parameter.V_Corec_Plus*0.0000016);
      Parameter.Vitesse[Corec_Plus]=360*Parameter.Step[Corec_Plus]/
           Parameter.Factor[Corec_Plus];
   }
   else
   {
      Parameter.Factor[Corec_Plus]=0;
      Parameter.Step[Corec_Plus]=1e-6;
      Parameter.Vitesse[Corec_Plus]=1e-12;
   }
   if (Parameter.Resolution[Lent] != 0)
   {
      Parameter.Factor[Lent]=Pas_Moteur*
      Resolution_Factor(Parameter.Resolution[Lent])*Parameter.Dent;
      Parameter.Step[Lent]=1/(Parameter.V_Lent*0.0000016);
      Parameter.Vitesse[Lent]=360*Parameter.Step[Lent]/Parameter.Factor[Lent];
   }
   else
   {
      Parameter.Factor[Lent]=0;
      Parameter.Step[Lent]=1e-6;
      Parameter.Vitesse[Lent]=1e-12;
   }
   if (Parameter.Resolution[Rapide] != 0)
   {
      Parameter.Factor[Rapide]=Pas_Moteur*
      Resolution_Factor(Parameter.Resolution[Rapide])*Parameter.Dent;
      Parameter.Step[Rapide]=1/(Parameter.V_Rapide*0.0000016);
      Parameter.Vitesse[Rapide]=360*Parameter.Step[Rapide]/Parameter.Factor[Rapide];
   }
   else
   {
      Parameter.Factor[Rapide]=0;
      Parameter.Step[Rapide]=1e-6;
      Parameter.Vitesse[Rapide]=1e-12;
   }
   return Parameter;
}

int Angle2Step(double Angle,int Factor)
/* number of steps need to turn telescope of Angle, in function of factor also */
{
   int Step;
   Step=(int)((Angle*Factor)/360);
   return Step;
}

int StepAjust_Alpha(double Angle,int Resolution)
/* loop to calculate the number of steps need to turn the telescope of
   Angle in RIGHT ASCENCION, because the sky turn during the move!! */
{
   int Step_Acc,Step_Cruse,Step_Dec,V_Fast,Boucle;
   double Time_Acc,Time_Cruse,Time_Dec,Time_Total,Angle_Siderale,Angle_Total;
   if (Resolution == Lent) V_Fast=Axe[Asc].V_Lent;
   if (Resolution == Rapide) V_Fast=Axe[Asc].V_Rapide;
   CalculRampe(Axe[Asc].V_Acc,Axe[Asc].V_Guidage,V_Fast,&Step_Acc,&Time_Acc);
   CalculRampe(Axe[Asc].V_Acc,V_Fast,Axe[Asc].V_Guidage,&Step_Dec,&Time_Dec);
   Angle_Total=Angle;
   printf("Angle Total=%.10f\n",Angle_Total);
   for (Boucle=0;Boucle<4;Boucle++)
      {
      Step_Cruse=Angle2Step(fabs(Angle_Total),Axe[Asc].Factor[Resolution])-Step_Acc-Step_Dec;
      printf("Step Cruse=%d\n",Step_Cruse);
      printf("Step Total=%d\n",Step_Acc+Step_Cruse+Step_Dec);
      Time_Cruse=Step_Cruse/Axe[Asc].Vitesse[Resolution]/Axe[Asc].Factor[Resolution]*360;
      Time_Total=Time_Acc+Time_Cruse+Time_Dec;
      printf("Time Total=%.10f\n",Time_Total);
      Angle_Siderale=Vitesse_Siderale*Time_Total;
      Angle_Total=Angle+Angle_Siderale;
      printf("Angle Total=%.10f\n",Angle_Total);
      }
   return (Step_Acc+Step_Cruse+Step_Dec);
}

T_Parameter_Axe Fill_Parameter(unsigned char Buffer[31])
{
	T_Parameter_Axe Parameter;
	Parameter.V_Guidage=Buffer[0]+256*Buffer[1];
	Parameter.V_Guidage_LSB=Buffer[2];
	Parameter.V_Corec_Plus=Buffer[3]+256*Buffer[4];
	Parameter.V_Corec_Moins=Buffer[5]+256*Buffer[6];
	Parameter.V_Lent=Buffer[7]+256*Buffer[8];
	Parameter.V_Rapide=Buffer[9]+256*Buffer[10];
	Parameter.V_Acc=Buffer[11];
	Parameter.D_Guidage=Buffer[12];
	Parameter.D_Corec_Plus=Buffer[13];
	Parameter.D_Corec_Moins=Buffer[14];
	Parameter.D_Lent_Plus=Buffer[15];
	Parameter.D_Lent_Moins=Buffer[16];
	Parameter.D_Rapide_Plus=Buffer[17];
	Parameter.D_Rapide_Moins=Buffer[18];
	Parameter.Resolution[Guidage]=Buffer[19];
	Parameter.Resolution[Corec_Plus]=Buffer[20];
	Parameter.Resolution[Corec_Moins]=Buffer[21];
	Parameter.Resolution[Lent]=Buffer[22];
	Parameter.Resolution[Rapide]=Buffer[23];
	Parameter.C_Guidage=Buffer[24];
	Parameter.C_Lent=Buffer[25];
	Parameter.C_Rapide=Buffer[26];
	Parameter.S_Led=Buffer[27];
	return Parameter;
}

int Debug(struct telprop *tel,char ss[200])
{
	char s[400];
	sprintf(s,"::console::affiche_resultat %s",ss);
	mytel_tcleval(tel,s);
	return 0;
}
