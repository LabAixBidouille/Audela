/* rostcl_1.c
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
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers ros_*.cpp.                           */
/***************************************************************************/
/* Le include rostcl.h ne contient des infos concernant Tcl.               */
/***************************************************************************/
#include "rostcl.h"

int Cmd_rostcl_meteo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* I/O with meteo stations                                                  */
/****************************************************************************/
/*
ros_meteo open vantage
ros_meteo read vantage
ros_meteo close vantage
*/
/****************************************************************************/
{
   char s[100];
#if defined OS_WIN
   int mode,modele;
   int port,vitesse;
   WeatherUnits Unites;
   DateTimeStamp DateTimeStation;
   time_t ltime;
   char text[50];
   int y,m,d,hh,mm;
   char Buf[200];
   double Valeur;
   DateTimeStamp TimeStamp;
   Tcl_DString dsptr;
#endif

   if(argc<3) {
      sprintf(s,"Usage: %s open|read|close meteostation", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      strcpy(s,"");
#if defined OS_WIN
      /* --- decodage des arguments ---*/
      mode=0;
      if (strcmp(argv[1],"open")==0) {
         mode=1;
      }
      else if (strcmp(argv[1],"read")==0) {
         mode=2;
      }
      else if (strcmp(argv[1],"close")==0) {
         mode=3;
      }
      if (mode==0) {
         sprintf(s,"Usage: %s open|read|close meteostation", argv[0]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      modele=0;
      if (strcmp(argv[2],"vantage")==0) {
         modele=1;
      }
      if (modele==0) {
         strcpy(s,"meteostation must be vantage");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- ---*/
      if ((mode==1)&&(modele==1)) {
         port=3;
         vitesse=19200;
         if (argc>=5) {
            port=atoi(argv[3]);
            vitesse=atoi(argv[4]);
         }
         CloseCommPort_V();
         // Meteo 3 19200 0 1 2 1 0.2 1
         // TableEtat.Port = atoi(argv_tcl[1]);    3 
	      // TableEtat.Vitesse = atoi(argv_tcl[2]); 19200
	      // TableEtat.Temp = atoi(argv_tcl[3]);    0
	      // TableEtat.Rain = atoi(argv_tcl[4]);    1
	      // TableEtat.Barom = atoi(argv_tcl[5]);   2
	      // TableEtat.Wind = atoi(argv_tcl[6]);    1
	      // TableEtat.RainInc = atof(argv_tcl[7]); 0.2
	      // TableEtat.Elev = atof(argv_tcl[8]);    1
         if(OpenCommPort_V(port,vitesse) != 0) {
            strcpy(s,"no connection with meteostation");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      	InitStation_V();
      	SetCommTimeoutVal_V(4000,4000);
      	Unites.TempUnit = 0;
	      Unites.RainUnit = 1;
	      Unites.BaromUnit = 2;
	      Unites.WindUnit = 1;
	      Unites.elevUnit = 1;
         if (SetUnits_V(&Unites) != 0) {
            strcpy(s,"no units for meteostation");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         if (SetRainCollectorModel_V(METRIC_1) != 0) {
            strcpy(s,"error SetRainCollectorModel_V for meteostation");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         time( &ltime );
         strftime(text,50,"%Y %m %d %H %M %S",localtime( &ltime ));
         strftime(text,50,"%Y",localtime( &ltime )); y=atoi(text);
         strftime(text,50,"%m",localtime( &ltime )); m=atoi(text);
         strftime(text,50,"%d",localtime( &ltime )); d=atoi(text);
         strftime(text,50,"%H",localtime( &ltime )); hh=atoi(text);
         strftime(text,50,"%M",localtime( &ltime )); mm=atoi(text);
         //strftime(text,50,"%S",localtime( &ltime )); ss=atof(text);
	      DateTimeStation.year = y;
      	DateTimeStation.month = m;
	      DateTimeStation.day = d;
	      DateTimeStation.hour = hh;
	      DateTimeStation.minute = mm;
         if (SetStationTime_V(&DateTimeStation)!= 0) {
            strcpy(s,"error SetStationTime_V for meteostation");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         sprintf(s,"Connection with %s is opened",argv[2]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- ---*/
      if ((mode==2)&&(modele==1)) {
   	   Tcl_DStringInit(&dsptr);
         /* --- ---*/	
         if(GetStationTime_V ( &TimeStamp) == 0) {
         	sprintf(Buf,"{%.2d ",TimeStamp.month);
	         Tcl_DStringAppend(&dsptr,Buf,-1);
	         sprintf(Buf,"%.2d ",TimeStamp.day);
	         Tcl_DStringAppend(&dsptr,Buf,-1);
	         sprintf(Buf,"%.2d ",TimeStamp.year);
	         Tcl_DStringAppend(&dsptr,Buf,-1);
	         sprintf(Buf,"%.2d ",TimeStamp.hour);
	         Tcl_DStringAppend(&dsptr,Buf,-1);
	         sprintf(Buf,"%.2d}",TimeStamp.minute);
	         Tcl_DStringAppend(&dsptr,Buf,-1);
         }
         /* --- ---*/
      	Valeur = GetOutsideTemp_V();
      	Valeur = (5.0/9.0)*(Valeur-32);
	      sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/
         Valeur = GetInsideTemp_V();
      	Valeur = (5.0/9.0)*(Valeur-32);
	      sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/
         Valeur = GetOutsideHumidity_V();
      	sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/
         Valeur = GetInsideHumidity_V();
      	sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/
         Valeur = GetBarometer_V();
      	//Valeur = Valeur*33.8639;
	      sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/	
      	Valeur = GetRainRate_V();
      	sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/	
         Valeur = GetWindSpeed_V();
         Valeur = Valeur /1.944;
      	sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/	
      	Valeur = GetWindDir_V();
      	sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/	
         Valeur = GetDewPt_V();
      	Valeur = (5.0/9.0)*(Valeur-32);
	      sprintf(Buf,"%.2f ",Valeur);
	      Tcl_DStringAppend(&dsptr,Buf,-1);
         /* --- ---*/	
         Tcl_DStringResult(interp,&dsptr);
         Tcl_DStringFree(&dsptr);
         return TCL_OK;
      }
      /* --- ---*/
      if ((mode==3)&&(modele==1)) {
         CloseCommPort_V();
         sprintf(s,"Connection with %s is closed",argv[2]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- ---*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
#elif
      Tcl_SetResult(interp,"function not available",TCL_VOLATILE);
      return TCL_ERROR;
#endif
   }
}
