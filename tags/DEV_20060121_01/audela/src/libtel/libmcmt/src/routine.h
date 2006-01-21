/* routine.h
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

/*
 * Routines specifiques a ce telescope. A programmer.
 *
 */

#ifndef __ROUTINE_H__
#define __ROUTINE_H__



int Resolution_Factor(int Reso_Int);
int CalculRampe(int Pente,int V_Debut,int V_Fin,int *Pas, double *Temps);
T_Parameter_Axe Fill_Parameter(unsigned char Buffer[31]);
T_Parameter_Axe Fill_Vitesse(T_Parameter_Axe Entree);
int StepAjust_Alpha(double Angle,int Resolution);
int Debug(struct telprop *tel,char ss[200]);


#endif /* #ifndef __ROUTINE_H__ */
