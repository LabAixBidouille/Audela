/* telescop.c
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

/* test
load $::audela_start_dir/libascom.dll
ascom select
*/ 
#include "sysexp.h"

#if defined(OS_WIN)
//#include <windows.h>
#endif
#define _WIN32_DCOM 

#include <Objbase.h>

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
//#include <wchar.h>   // pour BSTR
//#include <StdString.h> // pour A2COL, OLE2A


#include <stdio.h>
#include "telescop.h"
#include <libtel/util.h>

// import des header"C" ASCOM
#import "file:..\..\..\external\lib\AscomMasterInterfaces.tlb"

/*
// import des header"C" ASCOM
#import "file:..\..\..\external\lib\AscomMasterInterfaces.tlb"

#import "file:C:\\Windows\\System32\\ScrRun.dll" \
	no_namespace \
	rename("DeleteFile","DeleteFileItem") \
	rename("MoveFile","MoveFileItem") \
	rename("CopyFile","CopyFileItem") \
	rename("FreeSpace","FreeDriveSpace") \
	rename("Unknown","UnknownDiskType") \
	rename("Folder","DiskFolder")

#import "progid:DriverHelper.Chooser" \
	rename("Yield","ASCOMYield") \
	rename("MessageBox","ASCOMMessageBox")
*/

#ifdef __cplusplus
extern "C" {
#endif


extern void logConsole(struct telprop *tel, char *messageFormat, ...);
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"ASCOM",    /* telescope name */
    "Ascom",    /* protocol name */
    "ascom",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

struct _PrivateParams {
   AscomInterfacesLib::ITelescopePtr telescopePtr;
   int debug;
};


#ifdef __cplusplus
}
#endif

// load $audela_start_dir/libascom.dll
// ascom select ""

int tel_select(char * productName)
{
   /*
   //CoInitialize(NULL);
   CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   ::DriverHelper::_ChooserPtr chooser = NULL;		
	chooser.CreateInstance("DriverHelper.Chooser");						
   chooser->DeviceTypeV = "Telescope";

	if(chooser == NULL)	{
      strcpy(productName, "Error open DriverHelper.Chooser");    
      return -1;
   }
	_bstr_t  drvrId ;
   drvrId = chooser->Choose(productName);
   chooser.Release();	
   CoUninitialize();
   
   if ( drvrId.length() == 0 ) {
      strcpy(productName, "No telescop selected");    
      return 1;
   } else {
      strcpy(productName, drvrId);
      return 0;
   }
   */
   return 0;
}

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{
   HRESULT hr;
   // j'autorise l'access aux objets COM
   //CoInitialize(NULL);
   //hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);
   hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);   
   if (FAILED(hr)) { 
      sprintf(tel->msg, "tel_init error CoInitializeEx hr=%X",hr);
      return -1;
   }
   
   // je cree les variables 
   tel->params = (PrivateParams*) calloc(sizeof(PrivateParams), 1);   
   
   AscomInterfacesLib::ITelescopePtr T = NULL;
   T.CreateInstance((LPCSTR)argv[2]); 
   
   tel->params->telescopePtr = T;
   if ( tel->params->telescopePtr == NULL) {
      return 1;
   }

   try {
      // je connecte le telescope
      tel->params->telescopePtr->Connected = true;
      //tel->rateunity=0.1;           //  deg/s when rate=1   
      tel->rateunity=1;     // vitesse siderale = 15 arsec/sec = 0.004166667 deg/sec           
      long nbRates = 0;
      //T->TrackingRates->get_Count( &nbRates);
      tel_home_get(tel,tel->homePosition);
      return 0;
   } catch( _com_error &e ) {
      sprintf(tel->msg, "tel_init error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return 1;
   }
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return 0;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{

   try {
      // je deconnecte le telescope
      tel->params->telescopePtr->Connected = false;
      // je supprime l'objet COM
      tel->params->telescopePtr->Release();
      CoUninitialize();
      // je supprime les variables créées par Audela
      if ( tel->params != NULL ) {
         free(tel->params);
         tel->params = NULL;
      }
      return 0;
   } catch( _com_error &e ) {
      sprintf(tel->msg, "tel_close error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   } catch (...) {
      sprintf(tel->msg, "tel_close error exception");
      return -1;
   }
   return 0;
}

// ---------------------------------------------------------------------------
// mytel_connectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return void
//    
// ---------------------------------------------------------------------------

int mytel_connectedSetupDialog(struct telprop *tel )
{
   try {
      tel->params->telescopePtr->SetupDialog();
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_connectedSetupDialog error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0; 
}


// ---------------------------------------------------------------------------
// mytel_setupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return 0=OK 1=error
//    
// ---------------------------------------------------------------------------
int mytel_setupDialog(const char * ascomDiverName, char * errorMsg )
{
   HRESULT hr;
   hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   if (FAILED(hr)) { 
      sprintf(errorMsg, "setupDialog error CoInitializeEx hr=%X",hr);
      return 1;
   }
   
   AscomInterfacesLib::ITelescopePtr telescopePtr = NULL;
   hr = telescopePtr.CreateInstance((LPCSTR)ascomDiverName);
   if ( FAILED(hr) ) {
      sprintf(errorMsg, "setupDialog error CreateInstance hr=%X",hr);
      CoUninitialize();
      return 1;    
   } 
   telescopePtr->SetupDialog();
   telescopePtr->Release();
   telescopePtr = NULL;
   CoUninitialize();
   return 0; 
}

/*
 CString LogCrackHR( HRESULT hr )
   {
      LPVOID  lpMsgBuf;
      CString strTmp;

      ::FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER |
                       FORMAT_MESSAGE_FROM_SYSTEM,
                       NULL,
                       hr,
                       MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       (LPTSTR) &lpMsgBuf,
                       0,
                       NULL );

        // STR_TMP is defined within LOG.CPP to provide safe format string
        // for both ANSI and UNICODE
        strTmp.Format( "%s", (char *) lpMsgBuf );


      // Free the buffer.
      ::LocalFree( lpMsgBuf );

      return strTmp;
   }


*/

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return mytel_radec_state(tel,result);
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return mytel_radec_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return mytel_radec_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   return mytel_radec_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return mytel_radec_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return mytel_focus_init(tel);
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return mytel_focus_coord(tel,result);
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return mytel_focus_goto(tel);
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return mytel_focus_move(tel,direction);
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return mytel_focus_stop(tel,direction);
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return mytel_focus_motor(tel);
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   return mytel_date_get(tel,ligne);
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return mytel_date_set(tel,y,m,d,h,min,s);
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   return mytel_home_get(tel,ligne);
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   return mytel_home_set(tel,longitude,ew,latitude,altitude);
}



/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel)
{
   try {
      if ( tel->params->telescopePtr->CanSync == false ) {
         sprintf(tel->msg, "This telescope can not synchonize");
         return 1;
      }
      HRESULT hr = tel->params->telescopePtr->SyncToCoordinates(tel->ra0/15,tel->dec0);
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_radec_init error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int slewing=0,tracking=0,connected=0;
   try {
      connected = ( tel->params->telescopePtr->Connected == VARIANT_TRUE); 
      slewing   = ( tel->params->telescopePtr->Slewing == VARIANT_TRUE);
      tracking  = ( tel->params->telescopePtr->Tracking == VARIANT_TRUE);
      sprintf(result,"{connected %d} {slewing %d} {tracking %d}",connected,slewing,tracking);
      return 0;
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_radec_state error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }

   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   try {
      if (tel->params->telescopePtr->CanSlew == VARIANT_FALSE) {
         sprintf(tel->msg, "This telescope can not slew");
         return 1;
      }
      if (tel->radec_goto_blocking==1) {
         tel->params->telescopePtr->SlewToCoordinates(tel->ra0/15, tel->dec0);         
      } else {
         tel->params->telescopePtr->SlewToCoordinatesAsync(tel->ra0/15, tel->dec0);  
      }

      return 0;
   } catch (_com_error &e) {
      sprintf(tel->msg, "mytel_radec_goto error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return 1;
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];

   //	      arcs/sec    deg/s
   //    1	   15	     0.004166667
   //   100	 1500	     0.416666667
   //   200	 3000	     0.833333333
   //   800	 12000	  3.333333333

   //long rate = (long) tel->radec_move_rate ;
   double rate=tel->rateunity*tel->radec_move_rate;
   //rate = 2;
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   try {    
      /*
      if (tel->params->telescopePtr->CanMoveAxis(AscomInterfacesLib::axisPrimary) == VARIANT_FALSE) {
         sprintf(tel->msg, "This telescope can not move RA axis");
         return 1;
      }
      if (tel->params->telescopePtr->CanMoveAxis(AscomInterfacesLib::axisSecondary)  == VARIANT_FALSE) {
         sprintf(tel->msg, "This telescope can not move DEC axis ");
         return 1;
      }
      */
      
      //tel->params->telescopePtr->TrackingRates->GetItem(rate)
      if (strcmp(direc,"N")==0) {
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,rate);         
      } else if (strcmp(direc,"S")==0) {
         rate *= -1;
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,rate);
      } else if (strcmp(direc,"E")==0) {
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,rate);
      } else if (strcmp(direc,"W")==0) {
         rate *= -1;
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,rate);
      }
	  // Reactivate tracking - seems mandatory for ASCOM scopes
      // tel->params->telescopePtr->Tracking = true;
      return 0;
   } catch (_com_error &e) {
      sprintf(tel->msg, "mytel_radec_move error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return 1;
   }

   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   if ( direction[0] != 0 ) {
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,tel->interp->result);
   }
   try {
      
      if (strcmp(direc,"N")==0 || strcmp(direc,"S")==0) {
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,tel->params->telescopePtr->TrackingRate);      
      } else if (strcmp(direc,"E")==0 || strcmp(direc,"W")==0) {
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,tel->params->telescopePtr->TrackingRate);         
      } else {
         tel->params->telescopePtr->AbortSlew();
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,0); 
         tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,0); 
         // je restaure la vitesse de suivi
          tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,tel->params->telescopePtr->TrackingRate);   
          tel->params->telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,tel->params->telescopePtr->TrackingRate); 
      }
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_radec_stop error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{

   try {
      if (tel->radec_motor==1) {
         tel->params->telescopePtr->Tracking = false;   
      } else {
         /* start the motor */
         if ( tel->params->telescopePtr->CanPark == VARIANT_TRUE ) {
            if ( tel->params->telescopePtr->AtPark  == VARIANT_TRUE ) {
               tel->params->telescopePtr->Unpark();
            }
         }
         // j'active le suivi
         tel->params->telescopePtr->Tracking = true;
      }
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_radec_motor error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[1024];
   char ss[1024];

   try {
      sprintf(s,"mc_angle2hms {%f } 360 zero 2 auto string",tel->params->telescopePtr->RightAscension * 15 ); 
      mytel_tcleval(tel,s);
      strcpy(ss,tel->interp->result);
      sprintf(s,"mc_angle2dms %f 90 zero 1 + string",tel->params->telescopePtr->Declination); 
      mytel_tcleval(tel,s);
      sprintf(result,"%s %s",ss,tel->interp->result);
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_radec_coord error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }

   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   char s[1024];
   
   try {
      strcpy(s,"mc_date2ymdhms [expr [mc_date2jd 1899-12-30T00:00:00]+[$telcmd UTCDate]]"); 
      mytel_tcleval(tel,s);
      sprintf(ligne,"%s",tel->interp->result);
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_date_get error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   char ss[1024];
   try {
      sprintf(ss,"$telcmd UTCDate [expr [mc_date2jd [list %d %d %d %d %d %f]]-[mc_date2jd 1899-12-30T00:00:00]]",
         y,m,d,h,min,s); 
      mytel_tcleval(tel,ss);
      tel->params->telescopePtr->UTCDate = atof(tel->interp->result);
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_date_set error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   double longitude;
   char ew;
   double latitude;
   double altitude;

   try {
      altitude=tel->params->telescopePtr->SiteElevation;
      latitude=tel->params->telescopePtr->SiteLatitude;
      longitude=tel->params->telescopePtr->SiteLongitude;
      if (longitude>0) {
         ew = 'E';
      } else {
         ew = 'W';
      }
      longitude=fabs(longitude);
      sprintf(ligne,"GPS %f %c %f %f",longitude,ew,latitude,altitude);   
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_home_get error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   try {
      longitude=fabs(longitude);
      if (strcmp(ew,"W")==0) {
         longitude=-longitude;
      }
      tel->params->telescopePtr->SiteElevation = altitude;
      tel->params->telescopePtr->SiteLatitude = latitude;
      tel->params->telescopePtr->SiteLongitude = longitude;
   } catch( _com_error &e ) {
      sprintf(tel->msg, "mytel_home_set error=%s",_com_util::ConvertBSTRToString(e.Description()));
      return -1;
   }
   return 0;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_ascom.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout)
{
   int len,k;
   char car;
   len=(int)strlen(strin);
   if (len==0) {
      strout[0]='\0';
      return;
   }
   for (k=0;k<len;k++) {
      car=strin[k];
      if (car==decin) {
         car=decout;
      }
      strout[k]=car;
   }
   strout[k]='\0';
}
