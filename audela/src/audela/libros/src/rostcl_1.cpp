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

#if defined(OS_WIN)
#include "Bc637pci.h"
#include <process.h>
//pour gerer la datation par GPS: d�claration des varaiables globales
HANDLE EventThreadGps;
int ThreadGps;
double DateGps;
char DateGpst[50];
double date=-1;
#endif

/***************************************************************************/
/* Define the entry point of the velleman driver to use it               */
/***************************************************************************/

#if defined(OS_WIN)
#define VELLEMAN_NAME "K8055D.dll"
HINSTANCE velleman;
#endif

/*
#if defined(OS_UNX) || defined(OS_LIN) || defined(OS_MACOS)
#define VELLEMAN_NAME "K8055D.so"
void *velleman;
#endif
*/

#if defined(OS_WIN)

#define VELLEMAN_OpenDevice OpenDevice
#define VELLEMAN_OpenDevice_Q "OpenDevice"
typedef __declspec(dllexport) long __stdcall VELLEMAN_OpenDevice_C(long CardAddress);
VELLEMAN_OpenDevice_C *VELLEMAN_OpenDevice;

#define VELLEMAN_CloseDevice CloseDevice
#define VELLEMAN_CloseDevice_Q "CloseDevice"
typedef void __stdcall VELLEMAN_CloseDevice_C();
VELLEMAN_CloseDevice_C *VELLEMAN_CloseDevice;

#define VELLEMAN_ReadAnalogChannel ReadAnalogChannel
#define VELLEMAN_ReadAnalogChannel_Q "ReadAnalogChannel"
typedef __declspec(dllexport) long __stdcall VELLEMAN_ReadAnalogChannel_C(long Channel);
VELLEMAN_ReadAnalogChannel_C *VELLEMAN_ReadAnalogChannel;

#define VELLEMAN_ReadAllAnalog ReadAllAnalog
#define VELLEMAN_ReadAllAnalog_Q "ReadAllAnalog"
typedef void __stdcall VELLEMAN_ReadAllAnalog_C(long *Data1, long *Data2);
VELLEMAN_ReadAllAnalog_C *VELLEMAN_ReadAllAnalog;

#define VELLEMAN_OutputAnalogChannel OutputAnalogChannel
#define VELLEMAN_OutputAnalogChannel_Q "OutputAnalogChannel"
typedef void __stdcall VELLEMAN_OutputAnalogChannel_C(long Channel, long Data);
VELLEMAN_OutputAnalogChannel_C *VELLEMAN_OutputAnalogChannel;

#define VELLEMAN_OutputAllAnalog OutputAllAnalog
#define VELLEMAN_OutputAllAnalog_Q "OutputAllAnalog"
typedef void __stdcall VELLEMAN_OutputAllAnalog_C(long Data1, long Data2);
VELLEMAN_OutputAllAnalog_C *VELLEMAN_OutputAllAnalog;

#define VELLEMAN_ClearAnalogChannel ClearAnalogChannel
#define VELLEMAN_ClearAnalogChannel_Q "ClearAnalogChannel"
typedef void __stdcall VELLEMAN_ClearAnalogChannel_C(long Channel);
VELLEMAN_ClearAnalogChannel_C *VELLEMAN_ClearAnalogChannel;

#define VELLEMAN_ClearAllAnalog ClearAllAnalog
#define VELLEMAN_ClearAllAnalog_Q "ClearAllAnalog"
typedef void __stdcall VELLEMAN_ClearAllAnalog_C();
VELLEMAN_ClearAllAnalog_C *VELLEMAN_ClearAllAnalog;

#define VELLEMAN_SetAnalogChannel SetAnalogChannel
#define VELLEMAN_SetAnalogChannel_Q "SetAnalogChannel"
typedef void __stdcall VELLEMAN_SetAnalogChannel_C(long Channel);
VELLEMAN_SetAnalogChannel_C *VELLEMAN_SetAnalogChannel;

#define VELLEMAN_SetAllAnalog SetAllAnalog
#define VELLEMAN_SetAllAnalog_Q "SetAllAnalog"
typedef void __stdcall VELLEMAN_SetAllAnalog_C();
VELLEMAN_SetAllAnalog_C *VELLEMAN_SetAllAnalog;

#define VELLEMAN_WriteAllDigital WriteAllDigital
#define VELLEMAN_WriteAllDigital_Q "WriteAllDigital"
typedef void __stdcall VELLEMAN_WriteAllDigital_C(long Data);
VELLEMAN_WriteAllDigital_C *VELLEMAN_WriteAllDigital;

#define VELLEMAN_ClearDigitalChannel ClearDigitalChannel
#define VELLEMAN_ClearDigitalChannel_Q "ClearDigitalChannel"
typedef void __stdcall VELLEMAN_ClearDigitalChannel_C(long Channel);
VELLEMAN_ClearDigitalChannel_C *VELLEMAN_ClearDigitalChannel;

#define VELLEMAN_ClearAllDigital ClearAllDigital
#define VELLEMAN_ClearAllDigital_Q "ClearAllDigital"
typedef void __stdcall VELLEMAN_ClearAllDigital_C();
VELLEMAN_ClearAllDigital_C *VELLEMAN_ClearAllDigital;

#define VELLEMAN_SetDigitalChannel SetDigitalChannel
#define VELLEMAN_SetDigitalChannel_Q "SetDigitalChannel"
typedef void __stdcall VELLEMAN_SetDigitalChannel_C(long Channel);
VELLEMAN_SetDigitalChannel_C *VELLEMAN_SetDigitalChannel;

#define VELLEMAN_SetAllDigital SetAllDigital
#define VELLEMAN_SetAllDigital_Q "SetAllDigital"
typedef void __stdcall VELLEMAN_SetAllDigital_C();
VELLEMAN_SetAllDigital_C *VELLEMAN_SetAllDigital;

#define VELLEMAN_ReadDigitalChannel ReadDigitalChannel
#define VELLEMAN_ReadDigitalChannel_Q "ReadDigitalChannel"
typedef __declspec(dllexport) bool __stdcall VELLEMAN_ReadDigitalChannel_C(long Channel);
VELLEMAN_ReadDigitalChannel_C *VELLEMAN_ReadDigitalChannel;

#define VELLEMAN_ReadAllDigital ReadAllDigital
#define VELLEMAN_ReadAllDigital_Q "ReadAllDigital"
typedef __declspec(dllexport) long __stdcall VELLEMAN_ReadAllDigital_C();
VELLEMAN_ReadAllDigital_C *VELLEMAN_ReadAllDigital;

#define VELLEMAN_ReadCounter ReadCounter
#define VELLEMAN_ReadCounter_Q "ReadCounter"
typedef __declspec(dllexport) long __stdcall VELLEMAN_ReadCounter_C(long CounterNr);
VELLEMAN_ReadCounter_C *VELLEMAN_ReadCounter;

#define VELLEMAN_ResetCounter ResetCounter
#define VELLEMAN_ResetCounter_Q "ResetCounter"
typedef void __stdcall VELLEMAN_ResetCounter_C(long CounterNr);
VELLEMAN_ResetCounter_C *VELLEMAN_ResetCounter;

#define VELLEMAN_SetCounterDebounceTime SetCounterDebounceTime
#define VELLEMAN_SetCounterDebounceTime_Q "SetCounterDebounceTime"
typedef void __stdcall VELLEMAN_SetCounterDebounceTime_C(long CounterNr, long DebounceTime);
VELLEMAN_SetCounterDebounceTime_C *VELLEMAN_SetCounterDebounceTime;

#define VELLEMAN_Version Version
#define VELLEMAN_Version_Q "Version"
typedef void __stdcall VELLEMAN_Version_C();
VELLEMAN_Version_C *VELLEMAN_Version;

#define VELLEMAN_SearchDevices SearchDevices
#define VELLEMAN_SearchDevices_Q "SearchDevices"
typedef __declspec(dllexport) long __stdcall VELLEMAN_SearchDevices_C();
VELLEMAN_SearchDevices_C *VELLEMAN_SearchDevices;

#define VELLEMAN_SetCurrentDevice SetCurrentDevice
#define VELLEMAN_SetCurrentDevice_Q "SetCurrentDevice"
typedef __declspec(dllexport) long __stdcall VELLEMAN_SetCurrentDevice_C(long lngCardAddress);
VELLEMAN_SetCurrentDevice_C *VELLEMAN_SetCurrentDevice;

#endif

int Cmd_rostcl_meteo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* I/O with meteo stations                                                  */
/****************************************************************************/
/*
ros_meteo open vantage 1 19200
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
#else
   char * message;
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
      else if (strcmp(argv[1],"test")==0) {
         mode=4;
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
         port=5;
         vitesse=19200;
         if (argc>=5) {
            port=atoi(argv[3]);
            vitesse=atoi(argv[4]);
         }
         CloseCommPort_V();
		 /* http://www.davisnet.com/support/weather/software_dllsdk.asp */
         // Meteo 1 19200 0 1 2 1 0.2 1
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
		 SetVantageTimeoutVal_V(TO_DUMP_AFTER);
      	SetCommTimeoutVal_V(4000,4000);
      	Valeur=(double)InitStation_V();
		if (Valeur!=0) {
            sprintf(s,"connection problem with meteostation (error code is %d)",(int)Valeur);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
		}

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
		LoadCurrentVantageData_V ();
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
	         sprintf(Buf,"%.2d} ",TimeStamp.minute);
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
      if ((mode==4)&&(modele==1)) {
   	   Tcl_DStringInit(&dsptr);
         /* --- ---*/
      	Valeur = GetOutsideTemp_V();
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
#else
      message = strdup( "function not available" );
      Tcl_SetResult(interp, message, TCL_VOLATILE);
      free( message );
      return TCL_ERROR;
#endif
   }
}

int Cmd_rostcl_gps(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* I/O with GPS cards                                                  */
/****************************************************************************/
/*
ros_gps open symmetricom
ros_gps reset symmetricom
ros_gps read symmetricom
ros_gps close symmetricom
*/
/****************************************************************************/
{
   char s[100];
#if defined OS_WIN
   int mode,modele,i;
	//ULONG maj,min;
//	ULONG evt_enable;
//	struct tm *majtime;
//	long majc;
	//OtherData otherdata;
	HANDLE EventThreadGps;
	//HANDLE hIntThrd;
	//DWORD threadID;
#else
	char * message;
#endif

   if(argc<3) {
      sprintf(s,"Usage: %s open|reset|read|close gpsdevice", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      strcpy(s,"");
#if defined OS_WIN
		EventThreadGps = CreateEvent(NULL,false,false,NULL);
      /* --- decodage des arguments ---*/
      mode=0;
      if (strcmp(argv[1],"open")==0) {
         mode=1;
      }
      else if (strcmp(argv[1],"reset")==0) {
         mode=2;
      }
      else if (strcmp(argv[1],"read")==0) {
         mode=3;
      }
      else if (strcmp(argv[1],"close")==0) {
         mode=4;
      }
      if (mode==0) {
         sprintf(s,"Usage: %s open|read|close gps", argv[0]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      modele=0;
      if (strcmp(argv[2],"symmetricom")==0) {
         modele=1;
      }
      if (modele==0) {
         strcpy(s,"GPS device must be symmetricom");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- open ---*/
      if ((mode==1)&&(modele==1)) {
			if ( bcStartPCI (0) != RC_OK ) {
				printf(s,"Error opening device %s",argv[2]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			bcSetMode(MODE_GPS);
			_beginthread(ServeurGps,0,NULL);
         sprintf(s,"Connection with %s is opened",argv[2]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- reset ---*/
      if ((mode==2)&&(modele==1)) {
			//SetEvent(EventThreadGps); //Declenche le thread gps
			//WaitForSingleObject(EventThreadGps,INFINITE); //Attende de demande d'image
			//_beginthread(ServeurGps,0,NULL);
			ThreadGps = 1;
			SetEvent(EventThreadGps); //Declenche le thread gps
			while (ThreadGps != 0)
				{//Attendre pour la datation de l'obturateur
					i++;
					Sleep(50);//Attendre 10ms
					if(i>=40) //Attendre 2s
					{
						printf("\nThread datation non declench");
						break; //Probleme pour la datation gps
					}
				}
			return TCL_OK;
	     }
      /* --- read time ---*/
      if ((mode==3)&&(modele==1)) {
		  if (date==0) {
			 sprintf(s,"Error GPS date");
			 Tcl_SetResult(interp,s,TCL_VOLATILE);
			 return TCL_ERROR;
		  } else {
			 sprintf(s,"%s",DateGpst);
			 Tcl_SetResult(interp,s,TCL_VOLATILE);
			 return TCL_OK;
		  }
      }
      /* --- close ---*/
      if ((mode==4)&&(modele==1)) {
		 _endthread();
		 CloseHandle(EventThreadGps);
		 bcStopPCI();
         sprintf(s,"Connection with %s is closed",argv[2]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- ---*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
#else
      message = strdup( "function not available" );
      Tcl_SetResult(interp, message, TCL_VOLATILE);
      free( message );
      return TCL_ERROR;
#endif
   }
}

//***************************************************************************
//
// fonction qui attend l'evenement exterieur
//
//***************************************************************************
void ServeurGps(void *Parametre)
{
	// Start Device
#if defined OS_WIN
	if ( bcStartPCI (0) != RC_OK ){
		printf ("Error openning device!!!");
	}

	bcSetMode( MODE_GPS );

	while(1)
	{
		//ThreadGps = 1; //Disponible
		WaitForSingleObject(EventThreadGps,INFINITE); //Attende de demande d'image
		ThreadGps = 0; //Traitement
		DateGps = ml_getGpsDate();

	}

	// Stop Device
	bcStopPCI ();
#endif
}
//***************************************************************************
//
// fonction qui donne la date du dernier evenement exterieur
//
//***************************************************************************
double ml_getGpsDate ()
{
#if defined(OS_WIN)
	double diff;
    ULONG maj, evtmaj, evtmin, min;
	ULONG evt_enable;
	int first_reading = 1;
	struct tm *majtime;
	SYSTEMTIME Su;
	double maintenant;


	// Set the HeartBeat Counters and the mode to Sync -> 100 Hz
	if ( bcSetHbt(1, 100, 100) == RC_ERROR )
		printf("\nError setting HeartBeat Counters!");

	// Enable Event, Rising Edge and Disable Lockout -> See Table 5-3 in manual
	evt_enable = 0x08;
	if ( bcSetReg (PCI_OFFSET_CTL, &evt_enable) == RC_ERROR )
		printf("\nError setting Control Register!");

	evtmaj = evtmin = 0;

	Sleep (2000);

	GetLocalTime(&Su);
	maintenant =Su.wHour*3600.+Su.wMinute*60.+Su.wSecond+Su.wMilliseconds/1000.;

	if ( bcReadEventTime (&maj, &min) == RC_OK){

		if ( maj != evtmaj || min != evtmin){

			// Convert Binary Time to structure
			majtime = gmtime( (const long *)&maj );

			//pour la precision au millime de seconde et pas plus
			min=(unsigned long int)(min*0.001);

			sprintf(DateGpst,"%.2d-%.2d-%.2dT%.2d:%.2d:%.2d.%.2i",
				majtime->tm_year+1900, majtime->tm_mon+1, majtime->tm_mday,
				majtime->tm_hour, majtime->tm_min, majtime->tm_sec, min);

			date= (majtime->tm_hour)*3600. + (majtime->tm_min)*60. + majtime->tm_sec + min*0.001;

			//test if the datePc and the dateGps are different (>60 sec)
			diff = maintenant-date;
			if (diff>60 || diff<-60) {
				sprintf(DateGpst,"0000-00-00T00:00:00.000");
				date=0;
			}
		}
	} else {
		date = 0;
	}
	return date;
#else
	return 0;
#endif
}

int Cmd_rostcl_velleman(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* I/O with Velleman cards                                                  */
/****************************************************************************/
/*
ros_velleman open
ros_velleman close
*/
/****************************************************************************/
{
   char s[100];
#if defined OS_WIN
   int mode,modele,funcfound;
	long CardAddress;
	long Channel;
	long lres;
	long Data1,Data2,Data;
	long CounterNr;
	long DebounceTime;
#else
	char * message;
#endif

   if(argc<2) {
      sprintf(s,"Usage: %s open|function|close ?options?", argv[0]);
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
      else if (strcmp(argv[1],"function")==0) {
         mode=2;
      }
      else if (strcmp(argv[1],"close")==0) {
         mode=3;
      }
      if (mode==0) {
         sprintf(s,"Usage: %s open|read|close", argv[0]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      modele=1;
      /* --- open ---*/
      if ((mode==1)&&(modele==1)) {
			velleman = LoadLibrary(VELLEMAN_NAME);
			if ((velleman != NULL)) {
				VELLEMAN_OpenDevice = (VELLEMAN_OpenDevice_C *) GetProcAddress(velleman,VELLEMAN_OpenDevice_Q);
				if (VELLEMAN_OpenDevice == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_OpenDevice_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_CloseDevice = (VELLEMAN_CloseDevice_C *) GetProcAddress(velleman,VELLEMAN_CloseDevice_Q);
				if (VELLEMAN_CloseDevice == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_CloseDevice_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ReadAnalogChannel = (VELLEMAN_ReadAnalogChannel_C *) GetProcAddress(velleman,VELLEMAN_ReadAnalogChannel_Q);
				if (VELLEMAN_ReadAnalogChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ReadAnalogChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ReadAllAnalog = (VELLEMAN_ReadAllAnalog_C *) GetProcAddress(velleman,VELLEMAN_ReadAllAnalog_Q);
				if (VELLEMAN_ReadAllAnalog == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ReadAllAnalog_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_OutputAnalogChannel = (VELLEMAN_OutputAnalogChannel_C *) GetProcAddress(velleman,VELLEMAN_OutputAnalogChannel_Q);
				if (VELLEMAN_OutputAnalogChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_OutputAnalogChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_OutputAllAnalog = (VELLEMAN_OutputAllAnalog_C *) GetProcAddress(velleman,VELLEMAN_OutputAllAnalog_Q);
				if (VELLEMAN_OutputAllAnalog == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_OutputAllAnalog_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ClearAnalogChannel = (VELLEMAN_ClearAnalogChannel_C *) GetProcAddress(velleman,VELLEMAN_ClearAnalogChannel_Q);
				if (VELLEMAN_ClearAnalogChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ClearAnalogChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ClearAllAnalog = (VELLEMAN_ClearAllAnalog_C *) GetProcAddress(velleman,VELLEMAN_ClearAllAnalog_Q);
				if (VELLEMAN_ClearAllAnalog == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ClearAllAnalog_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SetAnalogChannel = (VELLEMAN_SetAnalogChannel_C *) GetProcAddress(velleman,VELLEMAN_SetAnalogChannel_Q);
				if (VELLEMAN_SetAnalogChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SetAnalogChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SetAllAnalog = (VELLEMAN_SetAllAnalog_C *) GetProcAddress(velleman,VELLEMAN_SetAllAnalog_Q);
				if (VELLEMAN_SetAllAnalog == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SetAllAnalog_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_WriteAllDigital = (VELLEMAN_WriteAllDigital_C *) GetProcAddress(velleman,VELLEMAN_WriteAllDigital_Q);
				if (VELLEMAN_WriteAllDigital == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_WriteAllDigital_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ClearDigitalChannel = (VELLEMAN_ClearDigitalChannel_C *) GetProcAddress(velleman,VELLEMAN_ClearDigitalChannel_Q);
				if (VELLEMAN_ClearDigitalChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ClearDigitalChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ClearAllDigital = (VELLEMAN_ClearAllDigital_C *) GetProcAddress(velleman,VELLEMAN_ClearAllDigital_Q);
				if (VELLEMAN_ClearAllDigital == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ClearAllDigital_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SetDigitalChannel = (VELLEMAN_SetDigitalChannel_C *) GetProcAddress(velleman,VELLEMAN_SetDigitalChannel_Q);
				if (VELLEMAN_SetDigitalChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SetDigitalChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SetAllDigital = (VELLEMAN_SetAllDigital_C *) GetProcAddress(velleman,VELLEMAN_SetAllDigital_Q);
				if (VELLEMAN_SetAllDigital == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SetAllDigital_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ReadDigitalChannel = (VELLEMAN_ReadDigitalChannel_C *) GetProcAddress(velleman,VELLEMAN_ReadDigitalChannel_Q);
				if (VELLEMAN_ReadDigitalChannel == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ReadDigitalChannel_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ReadAllDigital = (VELLEMAN_ReadAllDigital_C *) GetProcAddress(velleman,VELLEMAN_ReadAllDigital_Q);
				if (VELLEMAN_ReadAllDigital == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ReadAllDigital_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ReadCounter = (VELLEMAN_ReadCounter_C *) GetProcAddress(velleman,VELLEMAN_ReadCounter_Q);
				if (VELLEMAN_ReadCounter == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ReadCounter_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_ResetCounter = (VELLEMAN_ResetCounter_C *) GetProcAddress(velleman,VELLEMAN_ResetCounter_Q);
				if (VELLEMAN_ResetCounter == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_ResetCounter_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SetCounterDebounceTime = (VELLEMAN_SetCounterDebounceTime_C *) GetProcAddress(velleman,VELLEMAN_SetCounterDebounceTime_Q);
				if (VELLEMAN_SetCounterDebounceTime == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SetCounterDebounceTime_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_Version = (VELLEMAN_Version_C *) GetProcAddress(velleman,VELLEMAN_Version_Q);
				if (VELLEMAN_Version == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_Version_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SearchDevices = (VELLEMAN_SearchDevices_C *) GetProcAddress(velleman,VELLEMAN_SearchDevices_Q);
				if (VELLEMAN_SearchDevices == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SearchDevices_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
				VELLEMAN_SetCurrentDevice = (VELLEMAN_SetCurrentDevice_C *) GetProcAddress(velleman,VELLEMAN_SetCurrentDevice_Q);
				if (VELLEMAN_SetCurrentDevice == NULL) {
					sprintf(s,"Function %s not found in library %s.",VELLEMAN_SetCurrentDevice_Q,VELLEMAN_NAME);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				   FreeLibrary(velleman);
               return TCL_ERROR;
				}
			} else {
				sprintf(s,"Library %s not loaded", VELLEMAN_NAME);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
			}
	      /* --- ---*/
			CardAddress=(long)0;
			if (argc>=3) {
				CardAddress=(long)atoi(argv[2]);
			}
			if (VELLEMAN_OpenDevice(CardAddress)==-1) {
				sprintf(s,"Card K8055D not found at address %d using library %s.",CardAddress,VELLEMAN_NAME);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				FreeLibrary(velleman);
            return TCL_ERROR;
			}
         return TCL_OK;
		}
      /* --- function ---*/
      if ((mode==2)&&(modele==1)) {
			if ((velleman == NULL)) {
				Tcl_SetResult(interp,"Driver not ever openend !!!",TCL_VOLATILE);
				return TCL_ERROR;
			}
			funcfound=0;
			if (argc>=3) {
				funcfound=1;
				/* --- ReadAnalogChannel ---*/
				if (strcmp(argv[2],"ReadAnalogChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>2) Channel=2;
					lres=VELLEMAN_ReadAnalogChannel(Channel);
					sprintf(s,"%d",lres);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ReadAllAnalog ---*/
				else if (strcmp(argv[2],"ReadAllAnalog")==0) {
					VELLEMAN_ReadAllAnalog(&Data1,&Data2);
					sprintf(s,"%d %d",Data1,Data2);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- OutputAnalogChannel ---*/
				else if (strcmp(argv[2],"OutputAnalogChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>2) Channel=2;
					Data=(long)0;
					if (argc>=5) {
						Data=(long)atoi(argv[4]);
					}
					VELLEMAN_OutputAnalogChannel(Channel,Data);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- OutputAllAnalog ---*/
				else if (strcmp(argv[2],"OutputAllAnalog")==0) {
					Data1=(long)0;
					if (argc>=4) {
						Data1=(long)atoi(argv[3]);
					}
					Data2=(long)0;
					if (argc>=5) {
						Data2=(long)atoi(argv[4]);
					}
					VELLEMAN_OutputAllAnalog(Data1,Data2);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ClearAnalogChannel ---*/
				else if (strcmp(argv[2],"ClearAnalogChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>2) Channel=2;
					VELLEMAN_ClearAnalogChannel(Channel);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ClearAllAnalog ---*/
				else if (strcmp(argv[2],"ClearAllAnalog")==0) {
					VELLEMAN_ClearAllAnalog();
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SetAnalogChannel ---*/
				else if (strcmp(argv[2],"SetAnalogChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>2) Channel=2;
					VELLEMAN_SetAnalogChannel(Channel);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SetAllAnalog ---*/
				else if (strcmp(argv[2],"SetAllAnalog")==0) {
					VELLEMAN_SetAllAnalog();
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- WriteAllDigital ---*/
				else if (strcmp(argv[2],"WriteAllDigital")==0) {
					Data=(long)0;
					if (argc>=4) {
						Data=(long)atoi(argv[3]);
					}
					if (Data<0) Data=0;
					if (Data>255) Data=255;
					VELLEMAN_WriteAllDigital(Data);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ClearDigitalChannel ---*/
				else if (strcmp(argv[2],"ClearDigitalChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>8) Channel=8;
					VELLEMAN_ClearDigitalChannel(Channel);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ClearAllDigital ---*/
				else if (strcmp(argv[2],"ClearAllDigital")==0) {
					VELLEMAN_ClearAllDigital();
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SetDigitalChannel ---*/
				else if (strcmp(argv[2],"SetDigitalChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>8) Channel=8;
					VELLEMAN_SetDigitalChannel(Channel);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SetAllDigital ---*/
				else if (strcmp(argv[2],"SetAllDigital")==0) {
					VELLEMAN_SetAllDigital();
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ReadDigitalChannel ---*/
				else if (strcmp(argv[2],"ReadDigitalChannel")==0) {
					Channel=(long)1;
					if (argc>=4) {
						Channel=(long)atoi(argv[3]);
					}
					if (Channel<1) Channel=1;
					if (Channel>5) Channel=5;
					lres=(long)VELLEMAN_ReadDigitalChannel(Channel);
					sprintf(s,"%d",lres);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ReadAllDigital ---*/
				else if (strcmp(argv[2],"ReadAllDigital")==0) {
					lres=VELLEMAN_ReadAllDigital();
					sprintf(s,"%d",lres);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ReadCounter ---*/
				else if (strcmp(argv[2],"ReadCounter")==0) {
					CounterNr=(long)1;
					if (argc>=4) {
						CounterNr=(long)atoi(argv[3]);
					}
					if (CounterNr<1) CounterNr=1;
					if (CounterNr>2) CounterNr=2;
					lres=VELLEMAN_ReadCounter(CounterNr);
					sprintf(s,"%d",lres);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- ResetCounter ---*/
				else if (strcmp(argv[2],"ResetCounter")==0) {
					CounterNr=(long)1;
					if (argc>=4) {
						CounterNr=(long)atoi(argv[3]);
					}
					if (CounterNr<1) CounterNr=1;
					if (CounterNr>2) CounterNr=2;
					VELLEMAN_ResetCounter(CounterNr);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SetCounterDebounceTime ---*/
				else if (strcmp(argv[2],"SetCounterDebounceTime")==0) {
					CounterNr=(long)1;
					if (argc>=4) {
						CounterNr=(long)atoi(argv[3]);
					}
					if (CounterNr<1) CounterNr=1;
					if (CounterNr>2) CounterNr=2;
					DebounceTime=(long)0;
					if (argc>=4) {
						DebounceTime=(long)atoi(argv[3]);
					}
					if (DebounceTime<0) DebounceTime=0;
					if (DebounceTime>5000) DebounceTime=5000;
					VELLEMAN_SetCounterDebounceTime(CounterNr,DebounceTime);
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- Version ---*/
				else if (strcmp(argv[2],"Version")==0) {
					VELLEMAN_Version();
					Tcl_SetResult(interp,"",TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SearchDevices ---*/
				else if (strcmp(argv[2],"SearchDevices")==0) {
					lres=VELLEMAN_SearchDevices();
					sprintf(s,"%d",lres);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- SetCurrentDevice ---*/
				else if (strcmp(argv[2],"SetCurrentDevice")==0) {
					CardAddress=(long)1;
					if (argc>=4) {
						CardAddress=(long)atoi(argv[3]);
					}
					if (CardAddress<1) CardAddress=1;
					if (CardAddress>2) CardAddress=2;
					lres=(long)VELLEMAN_SetCurrentDevice(CardAddress);
					sprintf(s,"%d",lres);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					return TCL_OK;
				}
				/* --- Function not found ---*/
				else {
					funcfound=0;
				}
			}
			if (funcfound==0) {
				Tcl_SetResult(interp,"Function not found amongst: ReadAnalogChannel, ReadAllAnalog, OutputAnalogChannel, OutputAllAnalog, ClearAnalogChannel, ClearAllAnalog, SetAnalogChannel, SetAllAnalog, WriteAllDigital, ClearDigitalChannel, ClearAllDigital, SetDigitalChannel, SetAllDigital, ReadDigitalChannel, ReadAllDigital, ReadCounter, ResetCounter, SetCounterDebounceTime, Version, SearchDevices, SetCurrentDevice",TCL_VOLATILE);
				return TCL_ERROR;
			}
		}
      /* --- close ---*/
      if ((mode==3)&&(modele==1)) {
			if (velleman!=NULL) {
				VELLEMAN_CloseDevice();
				FreeLibrary(velleman);
				velleman=NULL;
			}
         return TCL_OK;
		}
      /* --- ---*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
#else
      message = strdup( "function not available" );
      Tcl_SetResult(interp, message, TCL_VOLATILE);
      free( message );
      return TCL_ERROR;
#endif
	}
}
