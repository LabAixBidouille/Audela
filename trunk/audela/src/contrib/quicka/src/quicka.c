/*====================================================*/
/* QuickAudine project                                */
/* An USB Interface for Audine CCD camera             */
/*                                                    */
/* QUICKA.DLL V1.1.0                                  */
/* 26 January 2003                                    */ 
/*====================================================*/
/* QUICKA.DLL is an utility program for               */
/* command an Audine CCD camera through               */
/* the USB QuickAudine interface.                     */
/*                                                    */
/* Authors : Thierry Maciaszek                        */
/*           Christian Buil                           */
/*           Raymond David                            */
/*                                                    */
/* Last changes : KAF-3200 compatibility by A.Klotz   */
/*                28-jun-2004                         */
/*====================================================*/
/* Some ressources:                                   */
/*                                                    */
/* Audine project Web site:                           */
/* http://www.astrosurf.com/audine                    */
/*                                                    */
/* QuickAudine informations:                          */
/* http://perso.wanadoo.fr/                           */
/*      thierry.maciaszek/Modif_Audine/               */
/*      USB.htm                                       */
/*                                                    */
/* Download free FTDI drivers:                        */
/* http://www.ftdichip.com/index.html                 */
/*                                                    */
/* A commercial version of QuickAudine:               */ 
/* http://www.essentielelectronique.com/index.htm     */
/*                                                    */
/* Iris free software for a fast test of theinterface */
/* http://wwww.astrosurf.com/buil/us/iris/iris.htm    */
/*                                                    */
/* P&C group (technical informations, source codes,   */
/* and many more):                                    */
/* http://pixcas.free.fr                              */
/*====================================================*/

/* 
====================================================
Programmation with QUICKA.DLL - Visual Basic example
====================================================

    ------------------------
(1) Declare QUICKA functions
    ------------------------

Public Declare Function usb_loadlib _
  Lib "QUICKA.DLL" () As Integer

Public Declare Function usb_closelib _
  Lib "QUICKA.DLL" () As Integer

Public Declare Function usb_init _
  Lib "QUICKA.DLL" () As Integer
  
Public Declare Function usb_end _
  Lib "QUICKA.DLL" () As Integer
  
Public Declare Function usb_write _
  Lib "QUICKA.DLL" (ByVal v As Integer) As Integer
 
Public Declare Function usb_start _
  Lib "QUICKA.DLL" (ByVal KAF As Integer, ByVal x1 As Integer, ByVal y1 As Integer, _
  ByVal x2 As Integer, ByVal y2 As Integer, _
  ByVal bin_x As Integer, ByVal bin_y As Integer, _
  ByVal shutter As Integer, ByVal shutter_mode As Integer, _
  ByVal ampli_mode As Integer, ByVal acq_mode As Integer, _
  ByVal d1 As Integer, ByVal d2 As Integer, _
  ByRef imax As Integer, ByRef jmax As Integer) As Integer
  
Public Declare Function usb_readaudine _
  Lib "QUICKA.DLL" (ByVal imax As Integer, ByVal jmax As Integer, _
  ByRef buf As Integer) As Integer

    -----------------------------
(2) Some variable declarations...
    -----------------------------
Dim shutter As Integer, shutter_mode As Integer
Dim ampli_mode As Integer, d1 As Integer, d2 As Integer
Dim x1 As Integer, x2 As Integer, y1 As Integer, y2 As Integer
Dim bin_x As Integer, bin_y As Integer 
Dim KAF As Integer, program as Integer, r As Integer
Dim speed As Integer
Dim imax As Integer, jmax As Integer
Dim delay As Double

    ------------------------------
(3) Load the USB library functions
    ------------------------------
r = usb_loadlib() ' Register the FTDI USB functions
If r <> 0 Then
   MsgBox ("ERROR: QuickAudine USB interface driver not found")
   Exit Sub
End If
   
r = usb_init() ' Check physical presence of QuickAudine interface
If r <> 0 Then
   MsgBox ("ERROR: QuickAudine USB interface not connected")
   Exit Sub
End If
r = usb_end() ' End of the check

    ------------------------------------------------------------------
(4) Configuration of the acquisition, clear the CCD and start exposure
    ------------------------------------------------------------------
shutter = 1 ' Synchro shutter (0 value = close shutter)
shutter_mode = 0 ' Inversion of the shutter command (1 value = inverted mode)
ampli_mode = 1 ' shutdown the CCD amplifier during exposure (0 value = always on)
delay = 1.2 ' delay in seconds between shutter close and effective reading of the images
If delay > 2.4 Then  ' 2.4 seconds is the max. value
   d1 = 0
   d2 = 15
Else
   d1 = 0
   d2 = CInt(6.25 * delay)
End If
x1 = 1 : y1 = 1 : x2 = 768 : y2 = 512 ' digitized image zone (KAF-0400 full frame example)
bin_x = 1 : bin_y = 1 ' binning factor (valid value: 1, 2, 3 and 4)
KAF = 1 ' CCD model (1 = KAF0400 , 2 = KAF1600)
program = 1 ' version of the QuickA internal program version
speed = 6 ' speed of the interface (value between 1...15 - normal value=6)

' Setup of the acquisition 
' Note: the usb_start function return the effective size of the image (imax, jmax)
r = usb_start(KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode, _
              ampli_mode, program, d1, d2, speed, imax, jmax)

If r = 12 Then
   MsgBox ("Error: QuickAudine USB interface USB not ready")
   Exit Sub
ElseIf r = 16 Then
   MsgBox ("Error: Dialog problem with the QuickAudine USB interface")
   Exit Sub
ElseIf r = 17 Then
   MsgBox ("Error: USB data transmission error")
   Exit Sub
End If

    -------------------------------
(5) Gestion of the integration time
    -------------------------------
...
... Your code
...

    -------------------
(6) End of the exposure
    -------------------
r = usb_write(255) ' CCD amplifier on
Sleep (100) ' small delay
r = usb_write(255) ' Close the shutter

    --------------
(7) Read the image
    --------------
' allocate memory (note: option base 0 for the arrays)
ReDim buffer(imax - 1,jmax - 1) As Integer

r = usb_readaudine(imax, jmax, buffer(0, 0))

' Note: The reading start after the delay (d1, d2) relative to the shutter shutdown

    -------------------------------------------
(8) Erase USB FTDI library functions (optional)
    -------------------------------------------
r = usb_closelib()


' The image is now in the 768x512 - 16-bits array BUFFER(i,j)
' It's all !
*/


/*====================================*/
/* Start of the QUICKA.DLL code...    */
/* Compiler: VisualC++ 6.0            */
/*====================================*/
#include <stdlib.h>
#include <stdio.h>

#ifdef _WINDOWS
#include <windows.h>  
typedef DWORD FT_HANDLE;
typedef ULONG FT_STATUS;

static HMODULE g_usb_module;

#define QUICKA_EXPORT _declspec(dllexport)
#define QUICKA_API _stdcall

#endif

#ifdef __linux__
#include <ftd2xx.h>
#include <unistd.h>
#define QUICKA_EXPORT
#define QUICKA_API
#endif

static FT_HANDLE UsbHandle;

#ifdef _WINDOWS
typedef FT_STATUS (WINAPI *PtrToOpen)(PVOID, FT_HANDLE *); 
#endif
#ifdef __linux__
typedef FT_STATUS (WINAPI *PtrToOpen)(INT, FT_HANDLE *); 
#endif
static PtrToOpen g_usb_Open; 
int UsbOpen(PVOID);

typedef FT_STATUS (WINAPI *PtrToOpenEx)(PVOID, DWORD, FT_HANDLE *); 
static PtrToOpenEx g_usb_OpenEx; 
int UsbOpenEx(PVOID, DWORD);

typedef FT_STATUS (WINAPI *PtrToListDevices)(PVOID, PVOID, DWORD);
static PtrToListDevices g_usb_ListDevices; 
int UsbListDevices(PVOID, PVOID, DWORD);

typedef FT_STATUS (WINAPI *PtrToClose)(FT_HANDLE);
static PtrToClose g_usb_Close;
int UsbClose();

typedef FT_STATUS (WINAPI *PtrToRead)(FT_HANDLE, LPVOID, DWORD, LPDWORD);
static PtrToRead g_usb_Read;
int UsbRead(LPVOID, DWORD, LPDWORD);

typedef FT_STATUS (WINAPI *PtrToWrite)(FT_HANDLE, LPVOID, DWORD, LPDWORD);
static PtrToWrite g_usb_Write;
int UsbWrite(LPVOID, DWORD, LPDWORD);

typedef FT_STATUS (WINAPI *PtrToResetDevice)(FT_HANDLE);
static PtrToResetDevice g_usb_ResetDevice;
int UsbResetDevice();
	
typedef FT_STATUS (WINAPI *PtrToPurge)(FT_HANDLE, ULONG);
static PtrToPurge g_usb_Purge;
int UsbPurge(ULONG);
	
typedef FT_STATUS (WINAPI *PtrToSetTimeouts)(FT_HANDLE, ULONG, ULONG);
static PtrToSetTimeouts g_usb_SetTimeouts;
int UsbSetTimeouts(ULONG, ULONG);

typedef FT_STATUS (WINAPI *PtrToGetQueueStatus)(FT_HANDLE, LPDWORD);
static PtrToGetQueueStatus g_usb_GetQueueStatus;
int UsbGetQueueStatus(LPDWORD);


/****************** USB_LOADLIB ******************/
/* Load the FTDI USB library                     */
/*************************************************/
QUICKA_EXPORT short QUICKA_API usb_loadlib(void)
{
#ifdef _WINDOWS
g_usb_module=LoadLibrary("Ftd2xx.dll");	
if (g_usb_module == NULL)
  {
  // Error: Can't load Ftd2xx.dll;
  return 1;
  }

g_usb_Write=(PtrToWrite)GetProcAddress(g_usb_module,"FT_Write");
if (g_usb_Write == NULL)
   {
	// Error: Can't Find FT_Write
	return 2;
   }

g_usb_Read = (PtrToRead)GetProcAddress(g_usb_module,"FT_Read");
if (g_usb_Read == NULL)
   {
	// Error: Can't Find FT_Read
	return 3;
   }

g_usb_Open = (PtrToOpen)GetProcAddress(g_usb_module,"FT_Open");
if (g_usb_Open == NULL)
   {
	// Error: Can't Find FT_Open
	return 4;
   }

g_usb_OpenEx = (PtrToOpenEx)GetProcAddress(g_usb_module,"FT_OpenEx");
if (g_usb_OpenEx == NULL)
   {
	// Error: Can't Find FT_OpenEx
	return 5;
   }

g_usb_ListDevices = (PtrToListDevices)GetProcAddress(g_usb_module,"FT_ListDevices");
if(g_usb_ListDevices == NULL)
	{
	// Error: Can't Find FT_ListDevices
	return 6;
	}

g_usb_Close = (PtrToClose)GetProcAddress(g_usb_module,"FT_Close");
if (g_usb_Close == NULL)
   {
	// Error: Can't Find FT_Close
	return 7;
   }

g_usb_ResetDevice = (PtrToResetDevice)GetProcAddress(g_usb_module,"FT_ResetDevice");
if (g_usb_ResetDevice == NULL)
   {
	// Error: Can't Find FT_ResetDevice
	return 8;
   }

g_usb_Purge = (PtrToPurge)GetProcAddress(g_usb_module,"FT_Purge");
if (g_usb_Purge == NULL)
   {
	// Error: Can't Find FT_Purge
	return 9;
   }

g_usb_SetTimeouts = (PtrToSetTimeouts)GetProcAddress(g_usb_module,"FT_SetTimeouts");
if (g_usb_SetTimeouts == NULL)
   {
	// Error: Can't Find FT_SetTimeouts
	return 10;
   }

g_usb_GetQueueStatus = (PtrToGetQueueStatus)GetProcAddress(g_usb_module,"FT_GetQueueStatus");
if (g_usb_GetQueueStatus == NULL)
   {
	// Error: Can't Find FT_GetQueueStatus
	return 11;
   }
#endif
#ifdef __linux__
g_usb_Write = FT_Write;
g_usb_Read = FT_Read;
g_usb_Open = FT_Open;
g_usb_OpenEx = FT_OpenEx;
g_usb_ListDevices = FT_ListDevices;
g_usb_Close = FT_Close;
g_usb_ResetDevice = FT_ResetDevice;
g_usb_Purge = FT_Purge;
g_usb_SetTimeouts = FT_SetTimeouts;
g_usb_GetQueueStatus = FT_GetQueueStatus;
#endif
return 0;
}

/************ USB_CLOSELIB ***************/
/* Download the FTDI                     */
/*****************************************/
QUICKA_EXPORT short QUICKA_API usb_closelib(void)
{
#ifdef _WINDOWS
FreeLibrary(g_usb_module);
#endif
return 0;
}

/************* USB_INIT ***********/
/* Initiate USB interface         */
/**********************************/
QUICKA_EXPORT short QUICKA_API usb_init(void)
{
if (UsbOpen(0)!=0)
   {
   // Error: USB interface not ready
   return 12;
   }

UsbResetDevice();
return 0;
}

/************ USB_END *************/
/* Initiate USB interface         */
/**********************************/
QUICKA_EXPORT short QUICKA_API usb_end(void)
{
if (UsbClose()!=0)
   {
   // Error: USB closing problem
   return 15;
   }
return 0;
}

/********** USB_WRITE *************/
/* Write onto USB interface       */
/**********************************/
QUICKA_EXPORT short QUICKA_API usb_write(short v)
{
unsigned char tx[2];
unsigned long Nb_RxOctets;

tx[0]=0;
tx[1]=(unsigned char)v;  
UsbWrite(tx,2,&Nb_RxOctets);
return 0;
}

/************************* USB_START ******************************/
/* Initiate image parameters, clear CCD and start exposure        */
/* KAF=1 : KAF0400 CCD - KAF=2 : KAF1600 CCD                      */
/* KAF=3 : KAF3200 CCD                                            */
/* (x1,y1)-(x2,y2) : subframe coordinates                         */
/* (bin_x, bin_y) : binning factors                               */
/* shutter=0 : shutter always closed - shutter=1 : synchro        */
/* shutter_mode=0 : no inverted - shutter_mode=1 : inverted       */
/* ampli_mode=0 : amplifier on during exposure                    */
/* ampli_mode=1 : amplifier off during exposure                   */
/* acq_mode=1 (default mode)                                      */
/* (d1, d2) : delay between shutter activation and image reading  */
/*            duration = (d1+16.d2)*10 ms                         */
/* speed=6 : speed of the interface (between 1...15)              */ 
/* (imax, jmax) : pointers to calculated image format             */ 
/* Note: overscan mode -> negative value for x1                   */
/*                     -> y2>nx                                   */
/******************************************************************/
QUICKA_EXPORT short QUICKA_API usb_start(short KAF,short x1,short y1,short x2,short y2,
                                              short bin_x,short bin_y,short shutter,
                                              short shutter_mode,short ampli_mode,
                                              short acq_mode,short d1,short d2,short speed,
                                              short *imax,short *jmax)
{
short nb_fastclear,tmp,k;
short X1_H_1,X1_L_2,X1_L_1;
short X2_H_1,X2_L_2,X2_L_1;
short Y1_H_1,Y1_L_2,Y1_L_1;
short Y2_H_1,Y2_L_2,Y2_L_1;
unsigned char tx[2],rx[2];
unsigned long Nb_RxOctets;
short nx=0;

if (KAF==4) 
   {
   // Error: CCD not supported
   return 13;
   }

nb_fastclear=2;  // number of clear CCD cycle - max. value: 15

if (x1>x2)  // Protect bad entry
   {
   tmp=x1;
   x1=x2;
   x2=tmp;
   }  

if (y1>y2)  // Protect bad entry
   {
   tmp=y1;
   y1=y2;
   y2=tmp;
   }  


if (KAF==1) nx=768; 
if (KAF==2) nx=1536; 
if (KAF==3) nx=2184; 
if (x2>nx) return 14; // Error: Bad image format  
if (y1<=0) return 14; 
if (speed>15) speed=15;
if (speed<1) speed=1;

tmp=nx/bin_x-x2+1;  // Invert x1 & x2
x2=nx/bin_x-x1+1;
x1=tmp;

*imax=x2-x1+1; // Actual size of the image
*jmax=y2-y1+1;

// y2++; // first line purge procedure (add internaly one line)

if (UsbOpen(0)!=0)
   {
   // Error: USB interface not ready
   return 12;
   }

UsbResetDevice(); // Reset the USB interface

X1_H_1 = x1 / 256;
X1_L_2 = (x1 - X1_H_1 * 256) / 16;
X1_L_1 = x1-X1_H_1 * 256 - X1_L_2 * 16;

X2_H_1 = x2 / 256;
X2_L_2 = (x2 - X2_H_1 * 256) / 16;
X2_L_1 = x2 - X2_H_1 * 256 - X2_L_2 * 16;

Y1_H_1 = y1 / 256;
Y1_L_2 = (y1 - Y1_H_1 * 256) / 16;
Y1_L_1 = y1-Y1_H_1 * 256 - Y1_L_2 * 16;

Y2_H_1 = y2 / 256;
Y2_L_2 = (y2 - Y2_H_1 * 256) / 16;
Y2_L_1 = y2 - Y2_H_1 * 256 - Y2_L_2 * 16;

tx[0]=0;
tx[1]=acq_mode * 16;
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=KAF * 16;
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=bin_x * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=bin_y * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=X1_L_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=X1_L_2 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=X1_H_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=X2_L_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=X2_L_2 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=X2_H_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=Y1_L_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=Y1_L_2 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=Y1_H_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=Y2_L_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=Y2_L_2 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=Y2_H_1 * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=nb_fastclear * 16;      
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=shutter * 16;             
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=shutter_mode * 16;             
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=d1 * 16;         
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=d2 * 16;       
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=ampli_mode * 16;             
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=speed * 16;           
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=0 * 16;    // Reserved         
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=0 * 16;    // Reserved         
UsbWrite(tx,2,&Nb_RxOctets);

tx[0]=0;
tx[1]=0 * 16;   // Reserved                    
UsbWrite(tx,2,&Nb_RxOctets);

// Data ready ?
k=0;
UsbGetQueueStatus(&Nb_RxOctets);
while (Nb_RxOctets==0) 
   {
   UsbGetQueueStatus(&Nb_RxOctets);
#ifdef _WINDOWS
   Sleep(10); // TimeOut
#endif
#ifdef __linux__
   usleep(10000);
#endif
   k++;
   if (k==2000) /* 200 changed by 2000 by A. Klotz on Jul. 2003 18th (k=308) */ 
      {
      // Error: Dialog problem with the USB interface
      UsbClose();
      return 16;  
      }
   }
UsbRead(rx,1,&Nb_RxOctets); // CheckSum
if ((rx[0] & 240) / 16 != 11)
   {
   // Error: Data transmission error
   UsbClose();
   return 17;
   }

return 0;
}

/************* USB_READAUDINE *************/
/* Transfer the image to the computer     */
/* (imax, jmax) : image format            */
/* p : pointer to the image               */
/******************************************/
QUICKA_EXPORT short QUICKA_API usb_readaudine(short imax,short jmax,short *p)
{
int j=0;
int k=0;
int v1,v2,v3,v4,v;
int nb_pixel;
int longueur_buffer=1024;  
char ReadBuffer[1024];
unsigned long Nb_RxOctets,i;
// unsigned long ii;
// int kk;

nb_pixel=(unsigned long)imax*jmax;

// ii=0;
while (j<=4*nb_pixel-longueur_buffer)
   {
   UsbGetQueueStatus(&Nb_RxOctets);
   while((int)Nb_RxOctets<longueur_buffer) UsbGetQueueStatus(&Nb_RxOctets);

/*
   kk=0; // time out procedure
   while ((int)Nb_RxOctets<longueur_buffer) 
      {
      UsbGetQueueStatus(&Nb_RxOctets);
      kk++;
      if (kk>65535)
         {
         // Error: Data transmission error
         UsbClose();
         return 50;
         }
      }
*/

   UsbRead(ReadBuffer,longueur_buffer,&Nb_RxOctets);

   for (i=0;i<Nb_RxOctets;i+=4)
      { 
      v1=(int)ReadBuffer[i] & 15;
      v2=(int)ReadBuffer[i+1] & 15;
      v3=(int)ReadBuffer[i+2] & 15;
      v4=(int)ReadBuffer[i+3] & 15;
      v=v1+16*v2+256*v3+4096*v4;
      if (v>32767)
         p[k]=32767;
      else
         p[k]=(short)v;
   //   ii++;
     // if (ii>(unsigned long)imax) k++; // purge the first line            
k++;
      }
   j=j+longueur_buffer;
   } 

if (j!=4*nb_pixel)
   {
   UsbGetQueueStatus(&Nb_RxOctets);
   while ((int)Nb_RxOctets<4*nb_pixel-j) UsbGetQueueStatus(&Nb_RxOctets);

/*
   kk=0; // time out procedure
   while ((int)Nb_RxOctets<4*nb_pixel-j)
      {
      UsbGetQueueStatus(&Nb_RxOctets);
      kk++;
      if (kk>65535)
         {
         // Error: Data transmission error
         UsbClose();
         return 51;
         }
      }
*/

   UsbRead(ReadBuffer,4*nb_pixel-j,&Nb_RxOctets);

   for (i=0;i<Nb_RxOctets;i+=4)
      { 
      v1=(int)ReadBuffer[i] & 15;
      v2=(int)ReadBuffer[i+1] & 15;
      v3=(int)ReadBuffer[i+2] & 15;
      v4=(int)ReadBuffer[i+3] & 15;
      v=v1+16*v2+256*v3+4096*v4;
      if (v>32767)
         p[k]=32767;
      else
         p[k]=(short)v;
      k++;
      }
   }

UsbClose();

return 0;
}

//********************************************************************
int UsbRead(LPVOID lpvBuffer, DWORD dwBuffSize, LPDWORD lpdwBytesRead)
{
return (*g_usb_Read)(UsbHandle,lpvBuffer,dwBuffSize,lpdwBytesRead);
}	

//********************************************************************
int UsbWrite(LPVOID lpvBuffer,DWORD dwBuffSize,LPDWORD lpdwBytes)
{
return (*g_usb_Write)(UsbHandle,lpvBuffer,dwBuffSize,lpdwBytes);
}	

//********************************************************************
int UsbOpen(PVOID pvDevice)
{
#ifdef _WINDOWS
return (*g_usb_Open)(pvDevice,&UsbHandle);
#endif
#ifdef __linux__
return (*g_usb_Open)((int)pvDevice,&UsbHandle);
#endif
}	

//********************************************************************
int UsbOpenEx(PVOID pArg1,DWORD dwFlags)
{
return (*g_usb_OpenEx)(pArg1,dwFlags,&UsbHandle);
}	

//********************************************************************
int UsbListDevices(PVOID pArg1,PVOID pArg2,DWORD dwFlags)
{
return (*g_usb_ListDevices)(pArg1,pArg2,dwFlags);
}	

//********************************************************************
int UsbClose()
{	
return (*g_usb_Close)(UsbHandle);
}	

//********************************************************************
int UsbResetDevice()
{
return (*g_usb_ResetDevice)(UsbHandle);
}	

//********************************************************************
int UsbPurge(ULONG dwMask)
{
return (*g_usb_Purge)(UsbHandle,dwMask);
}	

//********************************************************************
int UsbSetTimeouts(ULONG dwReadTimeout,ULONG dwWriteTimeout)
{
return (*g_usb_SetTimeouts)(UsbHandle,dwReadTimeout,dwWriteTimeout);
}	

//*********************************************************************
int UsbGetQueueStatus(LPDWORD lpdwAmountInRxQueue)
{
return (*g_usb_GetQueueStatus)(UsbHandle,lpdwAmountInRxQueue);
}
