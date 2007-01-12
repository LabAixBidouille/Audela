/*++

Copyright (c) 1998  TrueTime,Inc.

Module Name:

    TrueTimeSDK.h

Abstract:

	The header Include file for TrueTime Applications/SDK
	TrueTime Input API.

	@doc 

	@module TrueTimeSDK.H | Defines the public API for the TrueTime 560-590x devices.

Environment:

    MSVC++ 5.0/Kernel Mode

Revision History:


--*/


#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#ifndef TRUETIMESDK_H_
#define TRUETIMESDK_H_

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include <WTypes.h>
#include "TrueTimeCmn.h"

#define TT_MAX_DEVICE		10		// Maximum number of devices supported



//  Values are 32 bit values layed out as follows:
//
//   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
//   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//  +---+-+-+-----------------------+-------------------------------+
//  |Sev|C|R|     Facility          |               Code            |
//  +---+-+-+-----------------------+-------------------------------+
//
//  where
//
//      Sev - is the severity code
//
//          00 - Success
//          11 - Error
//
//      C - is the Customer code flag
//
//      R - is a reserved bit
//
//      Facility - is the facility code
//
//      Code - is the facility's status code

// @enum TT_STATUS | Status values returned by the SDK.
typedef enum {
	TT_SUCCESS				= 0x0,			// @emem The requested operation was successful
	TT_STATUS_INVALID_ID	= 0xE8430001,	// @emem The requested device doesn't exist
	TT_ERROR_SERVICE_MANAGER,				// @emem Service Manager failed loading driver.
	TT_INVALID_HANDLE,						// @emem The Invalid device handle
	TT_INVALID_ACCESS_REQUESTED,			// @emem The Invalid access requested
	TT_INVALID_ACCESS,						// @emem The process doesn't have valid access for this operation
	TT_INVALID_MODE,						// @emem The Device doesn't have valid Mode set for this operation
	TT_FAIL_UTCTOLOCAL,						// @emem Conversion from UTC to Local File Time failed
	TT_FAIL_LOCALTOUTC,						// @emem Conversion from Local File Time to UTC failed
	TT_SYSTEM_ERROR,						// @emem A system error occured, call GetLastError for details.
	TT_MODE_NOT_SUPPORTED,					// @emem This mode is not supported by the device
	TT_FAILED_TO_CREATE_THREAD,				// @emem An error occurred creating the callback thread.
	TT_ANTENNA_ERROR,						// @emem An antenna is Open/Shorted.
	TT_GPS_SIGNAL_INFO_NOT_AVAILABLE,		// @emem The GPS Signal Info not available.
	TT_TIMEOUT_ERROR						// @emem A function call has timed out.
} TT_STATUS;

#ifdef	TRUETIMESDK_DLL_
#define TT_API __declspec(dllexport)
#else
#define TT_API __declspec(dllimport)
#endif	// TRUETIMESDK_DLL_


// @enum TT_TIME_CONVERT | Values specifying conversion between UTC and local time.
typedef enum {
	TT_CONVERT_NONE,				// @emem No conversion.
	TT_CONVERT_UTC2LOCAL,			// @emem Convert from UTC to local time, using the system <t TIME_ZONE_INFORMATION> values.
	TT_CONVERT_LOCAL2UTC,			// @emem Convert from local to UTC time, using the system <t TIME_ZONE_INFORMATION> values.
} TT_TIME_CONVERT;


#if 0  // this is defined in Microsoft headers, and is included here for documentation purposes
/*
@struct FILETIME | A 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601. A FILETIME
structure can represent time values of approximately 29,000 years.

@comm The FILETIME structure is compatible with the <t LARGE_INTEGER> structure.  Therefore, to perform arithmetic
on FILETIME data, convert it to a LARGE_INTEGER structure.

FILETIME is a standard Win32 time format.  See <f About Windows Time> for more information.
*/

typedef struct _FILETIME { 
    DWORD dwLowDateTime;		// @field Specifies the low-order 32 bits of the file time.
    DWORD dwHighDateTime; 		// @field Specifies the high-order 32 bits of the file time.
} FILETIME; 
#endif

// @struct TT_POSITION | Position data consisting of latitude, longitude, and elevation.
typedef struct _TT_POSITION {
	float	fLatitude;		// @field Latitude in degrees, from -90 (south) to +90 (north).
	float	fLongitude;		// @field Longitude in degrees, from -180 (east) to +180 (west).
	float	fElevation;		// @field Elevation in meters, above and below sea level.
} TT_POSITION;

// @struct TT_GPS_SIGNAL | GPS satellite signal strength.
typedef struct _TT_GPS_SIGNAL {
	DWORD	dwPRN;					// @field Satellite ID.
	float	fSignalStrength;		// @field Signal strength after correlation or de-spreading.
} TT_GPS_SIGNAL;

// @struct TT_GPS_SIGNALS | Signal strength data for up to six satellites.
typedef struct _TT_GPS_SIGNALS {
	DWORD			dwCount;						// @field Number of satellites acquired and locked.
	TT_GPS_SIGNAL	satellite[TT_MAX_SATELLITES];	// @field Signal strength data (see <t TT_GPS_SIGNAL>).
	BOOL			bGPSLock;						// @field Flag to indicate the GPS Lock/Unlock Status
} TT_GPS_SIGNALS;

typedef TT_API TT_STATUS ( * TT_CALLBACK) (TT_EVENT, FILETIME*, DWORD, PVOID);
	
/*
@doc BASIC
@func Attaches the calling application to the specified TrueTime device.  This function must be called by 
every application using the TrueTime SDK.  The parameter <p dwDeviceID> is the zero-based ID of the desired board.
Board ID's start with the value zero, and increment for each available board.  An application can determine the
number of boards available by incrementing <p dwDeviceID> until the error <t TT_STATUS_INVALID_ID> is returned.
Multiple device support is only available on Windows NT.

This function performs resource allocation and other initialization operations.
Only one application can open a device with <t GENERIC_WRITE> access.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_CloseDevice>

@ex The following example illustrates the use of this function. |
	HANDLE hDevice

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Open is successful with both Read and Write access
		...
	}
*/
TT_API TT_STATUS TT_OpenDevice(
	DWORD		dwDeviceID,			// @parm The zero-based ID of the desired device.
	DWORD		dwDesiredAccess,	// @parm Desired Access - <t GENERIC_READ>, <t GENERIC_WRITE>, or both
	HANDLE*		phDevice			// @parm A poiner to receive the handle to the desired TrueTime device.
	);


/*
@doc BASIC
@func Detaches the calling application from the specified TrueTime device.
This function should be called by every application using the TrueTime SDK, prior to termination.
It performs resource deallocation and other cleanup operations.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_OpenDevice>

@ex The following example illustrates the use of this function. |
	HANDLE hDevice

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// close the desired device
		TT_CloseDevice(hDevice);
	}


*/

TT_API TT_STATUS TT_CloseDevice(
	HANDLE		hDevice			// @parm The handle to the TrueTime device to close.
	);


/*
@doc BASIC
@func This function returns static information about the board associated with the handle provided.  
This function is available in all modes and requires <t FILE_GENERIC_READ> access.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function.	|
	HANDLE hDevice
	TT_MODEL	Model;
	DWORD		dwBus;
	DWORD		dwSlot;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get device info
		if (TT_GetDeviceInfo(hDevice, &Model, &dwBus, &dwSlot) == TT_SUCCESS)
		{
			// the requested information is available
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/



TT_API TT_STATUS TT_GetDeviceInfo(
	HANDLE		hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_MODEL*	pModel,				// @parm Address of buffer to receive <t TT_MODEL>
	DWORD*		pdwBus,				// @parm Address of <t DWORD> to receive the bus number of the card.
	DWORD*		pdwSlot				// @parm Address of <t DWORD> to receive the slot number of the card.
	);


/*
@doc BASIC
@func This function sets the current operating mode, which is maintained by the hardware in non-volatile
memory.  Since the hardware is pre-configured by the factory, it is not necessary for any 
application to call this function.  However, it is available for situations where the factory settings 
must be changed.  This function requires <t FILE_GENERIC_WRITE> access.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetMode>

@ex The following example illustrates the use of this function. |
	HANDLE				hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Set the Current Operating Mode for the desired device
		if (TT_SetMode(hDevice, TT_MODE_SYNCHRONIZED, TT_SYNCH_TIMECODE, TT_TIMECODE_IRIGA_DC) == TT_SUCCESS)
		{
			// The device is successfully synchronized to an external timecode source of 
			// IRIG-A, in DC mode
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/
TT_API TT_STATUS TT_SetMode(
	HANDLE				hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_OPERATION_MODE	eOperationMode,		// @parm The desired operation mode (see <t TT_OPERATION_MODE>).
	TT_SYNCH_SOURCE		eSynchSource,		// @parm When <p eOperationMode> is <t TT_MODE_SYNCHRONIZED>, <p eSynchSource>
											//  specifies the desired synchronization source (see <t TT_SYNCH_SOURCE>).
	TT_TIMECODE			eTimeCode			// @parm When <p eSynchSource> is <t TT_SYNCH_TIMECODE>, <p eTimeCode>
											//  specifies the desired timecode standard (see <t TT_TIMECODE>).
	);


/*
@doc BASIC
@func This function gets the current operating mode, which is maintained by the hardware in non-volatile
memory.  Since the hardware is pre-configured by the factory, it is not necessary for any 
application to call this function.  However, it is available for situations where the factory settings 
must be known.  This function requires <t FILE_GENERIC_READ> access.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetMode>

@ex The following example illustrates the use of this function. |
	HANDLE				hDevice;
	TT_OPERATION_MODE	OperationMode;
	TT_SYNCH_SOURCE		SynchSource;
	TT_TIMECODE			TimeCode;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Get the Current Operating Mode for the desired device
		if (TT_GetMode(hDevice, &OperationMode, &SynchSource, &TimeCode) == TT_SUCCESS)
		{
			// Get Mode for the device is successful
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}

*/
TT_API TT_STATUS TT_GetMode(
	HANDLE				hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_OPERATION_MODE*	peOperationMode,	// @parm Address of <t TT_OPERATION_MODE> to receive the current operation mode.
	TT_SYNCH_SOURCE*	peSynchSource,		// @parm Address of <t TT_SYNCH_SOURCE> to receive the current synchronization
											//  source when <p peOperationMode> is <t TT_MODE_SYNCHRONIZED>).
	TT_TIMECODE*		peTimeCode			// @parm Address of <t TT_TIMECODE> to receive the current timecode standard
											//  when <p peSynchSource> is <t TT_SYNCH_TIMECODE>.
	);



/*
@doc BASIC 
@func This function converts a 64-bit file time to system time format.  It only works with <t FILETIME> values that 
are less than 0x8000000000000000. 

@rdesc If the function fails, the return value is zero. To get extended error information, call GetLastError. 

@ex The following example illustrates the use of this function. |
	FILETIME 		FileTime;
	SYSTEMTIME_EX	SystemTime;

	// Convert the FileTime to SystemTimeEx format
	if (TT_FileTimeToSystemTimeEx(&FileTime, &SystemTime) == TT_SUCCESS)
	{
		// FileTime is successfully converted to the SystemTimeEx
		...
	}

*/
TT_API TT_STATUS TT_FileTimeToSystemTimeEx(
	FILETIME*		lpFileTime,			// @parm Pointer to a <t FILETIME> structure containing the file time
										//  to convert to system date and time format.
	SYSTEMTIME_EX*	lpSystemTime		// @parm Pointer to a <t SYSTEMTIME_EX> structure to receive the converted file time.
	);
 
/*
@doc BASIC 
@func This function converts a system time to 64-bit file time format.  The <p wDayOfWeek> member of the 
<t SYSTEMTIME_EX> structure is ignored.  

@rdesc If the function fails, the return value is zero. To get extended error information, call GetLastError. 

@ex The following example illustrates the use of this function. |
	FILETIME 		FileTime;
	SYSTEMTIME_EX	SystemTime;

	// Convert the SystemTimeEx to FileTime format
	if (TT_SystemTimeExToFileTime(&SystemTime, &FileTime) == TT_SUCCESS)
	{
		// SystemTimeEx is successfully converted to the FileTime
		...
	}
*/
TT_API TT_STATUS TT_SystemTimeExToFileTime(
	SYSTEMTIME_EX*	lpSystemTime,		// @parm Pointer to a <t SYSTEMTIME_EX> structure to converted.
	FILETIME*		lpFileTime			// @parm Pointer to a <t FILETIME> structure to receive the converted file time.
	);
 

/*
@doc GEN 1PPS TIMECODE GPS 
@func This function returns the error and oscillator values from the diagnostic register.  

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function. |
	HANDLE			hDevice;
	TT_DIAG_ERROR	Diagnostic;
	WORD			wDAC;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Read the Diagnostic Register for the desired device
		if (TT_ReadDiagnosticRegister(hDevice, &Diagnostic, &wDAC) == TT_SUCCESS)
		{
			// The Diagnostic Information is successfully retrieved from the device
			...
		}
		// Close the device
		TT_CloseDevice(hDevice);
	}

*/
TT_API TT_STATUS  TT_ReadDiagnosticRegister(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_DIAG_ERROR*	peDiagnostic,		// @parm Address of <t TT_DIAG_ERROR> to receive hardware error status flags.
	WORD*			pwDAC				// @parm Address of location to receive current setting of frequency control DAC.
	);
 


/*
@doc GEN 1PPS TIMECODE GPS
@func This function retreives the current time value from the device, converting it as specified by <p bLocalTime>.
In GPS mode, time is always maintained in UTC.  In other modes, time is application specific.
This function requires <t FILE_GENERIC_READ> access.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function. |
	HANDLE		hDevice;
	FILETIME 	FileTime;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Read the current Freeze Time for the desired device
		if (TT_ReadTime(hDevice, &FileTime, TT_CONVERT_UTC2LOCAL) == TT_SUCCESS)
		{
			// The current freeze time is successfully read from the device and 
			// converted it from UTC to Local time.
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}

*/
TT_API TT_STATUS TT_ReadTime(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	FILETIME*		pFileTime,			// @parm Address of <t FILETIME> structure to receive the time
	TT_TIME_CONVERT	eConvertFlag		// @parm The <t TT_TIME_CONVERT> conversion to apply to the time read from
										//  the clock and returned in <p pFileTime>.
	);



/*
@doc GEN
@func This function enables the device to accumulate time.
This function requires <t FILE_GENERIC_WRITE> access and is only available in Generator mode.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_StopGenerator>

@ex The following example illustrates the use of this function. |
	HANDLE hDevice

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// start the device
		if (TT_StartGenerator(hDevice) == TT_SUCCESS)
		{
			// the device is running
			...
		}
	}
*/
TT_API TT_STATUS TT_StartGenerator(
	HANDLE			hDevice			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	);

/*
@doc GEN
@func This function stops time accumulation of the device.
This function requires <t FILE_GENERIC_WRITE> access and is only available in Generator mode.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_StartGenerator>

@ex The following example illustrates the use of this function. |
	HANDLE hDevice

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// stop the device
		if (TT_StopGenerator(hDevice) == TT_SUCCESS)
		{
			// the device is stopped
			...
		}
	}
*/
TT_API TT_STATUS TT_StopGenerator(
	HANDLE			hDevice			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	);


/*
@doc GEN 1PPS TIMECODE
@func This function sets the current time in the device, converting the supplied time as specified by <p eConvertFlag>.
In Timecode mode, this function is used to set the year since year information is not encoded in 
the time code reference.  Year data is necessary to handle end of year rollover correctly for leap years.  
Year information is saved in EEPROM and automatically increments at the end of each year. 

This function requires <t FILE_GENERIC_WRITE> access and is available in Generator,  1 PPS, and Timecode modes.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function. |
	HANDLE		hDevice;
	FILETIME 	FileTime;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Set time for the desired device
		if (TT_PresetTime(hDevice, &FileTime, TT_CONVERT_LOCAL2UTC) == TT_SUCCESS)
		{
			// The specified time is successfully set as the current time in the device, converting
			// it from Local Time to UTC
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}

*/
TT_API TT_STATUS TT_PresetTime(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	FILETIME*		pFileTime,			// @parm Address of <t FILETIME> structure containing the time
	TT_TIME_CONVERT	eConvertFlag		// @parm The <t TT_TIME_CONVERT> conversion to apply to the time specified
										//  by <p pFileTime>.
	);

/*
@doc BASIC
@func Sets the phase compensation for the device.
This function requires <t FILE_GENERIC_WRITE> access, and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetPhaseCompensation>

@ex The following example illustrates the use of this function.	|
	HANDLE hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set phase compensation
		if (TT_SetPhaseCompensation(hDevice, 340) == TT_SUCCESS)
		{
			// the phase compensation is set to +340 microseconds
			...
		}
	}
*/
TT_API TT_STATUS TT_SetPhaseCompensation(
	HANDLE		hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	SHORT		sOffset				// @parm Specifies the desired compensation from -1000 to +1000 microseconds.
	);


/*
@doc BASIC
@func Gets the current phase compensation for the device.
This function requires <t FILE_GENERIC_READ> access, and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetPhaseCompensation>

@ex The following example illustrates the use of this function.	|
	HANDLE hDevice;
	SHORT  sOffset;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get phase compensation
		if (TT_GetPhaseCompensation(hDevice, &sOffset) == TT_SUCCESS)
		{
			// the phase compensation is available in sOffset
			...
		}
	}
*/
TT_API TT_STATUS TT_GetPhaseCompensation(
	HANDLE		hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	SHORT*		plOffset			// @parm Address of <t SHORT> to receive the current compensation from -1000 to +1000 microseconds.
	);


/*
@doc 1PPS
@func This function enables/disables the hardware to add a leap second at the end of the current day.
This function requires <t FILE_GENERIC_WRITE> access and is available in 1 PPS mode.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetLeapSecond>

@ex The following example illustrates the use of this function.	|
	HANDLE hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set the leap second flag
		if (TT_SetLeapSecond(hDevice, TRUE) == TT_SUCCESS)
		{
			// the leap second flag is set
			...
		}
	}
*/
TT_API TT_STATUS TT_SetLeapSecond(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL			bEnable				// @parm Flag to enable/disable the hardware
	);


/*
@doc 1PPS
@func This function returns the current status of the hardware to add a leap second at the end of the current day.
This function requires <t FILE_GENERIC_READ> access and is available in 1 PPS mode.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetLeapSecond>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	BOOL	bEnable;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get the leap second flag
		if (TT_GetLeapSecond(hDevice, &bEnable) == TT_SUCCESS)
		{
			// the leap second flag is now available
			...
		}
	}
*/
TT_API TT_STATUS TT_GetLeapSecond(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL*			pbEnable			// @parm Address of <t BOOL> to receive current enable/disable status.
	);


/*
@doc GPS 
@func This function returns the GPS position consisting of latitude, longitude, and elevation, and satellite signal
information for up to six satellites.

This function requires <t FILE_GENERIC_READ> access and is only available in GPS mode.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function. |
	HANDLE			hDevice;
	TT_POSITION		Position;
	TT_GPS_SIGNALS	GpsSignals;
	TT_ANTENNA		Antenna;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Read the GPS Information for the desired device
		if (TT_ReadGpsInfo(hDevice, &Position, &GpsSignals, &Antenna) == TT_SUCCESS)
		{
			// The GPS information is successfully retrieved from the device
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/


TT_API TT_STATUS TT_ReadGpsInfo(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_POSITION*	pPosition,			// @parm Address of a <t TT_POSITION> structure to receive the current position.
										//  If this value is <t NULL>, no position data is returned.
	TT_GPS_SIGNALS*	pGpsSignals,		// @parm Address of a <t TT_GPS_SIGNALS> structure to receive the current signal data.
										//  If this value is <t NULL>, no signal data is returned.
	TT_ANTENNA*		pAntenna			// @parm Address of a <t TT_ANTENNA> structure to receive the antenna status.
	);

/*
@doc GPS 
@func This function is used to preset the GPS position.	 Presetting an initial position will speed up acquisition 
time by a minute or two.

This function requires <t FILE_GENERIC_WRITE> access and is available in GPS mode.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function.	|
	HANDLE			hDevice;
	TT_POSITION		Position;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set position near San Jose, CA
		Position.fLatitude = 35.0;
		Position.fLongitude = -120.0;
		Position.fElevation = 100.0;

		// preset the GPS initial position
		if (TT_PresetPosition(hDevice, &Position) == TT_SUCCESS)
		{
			// The GPS position has been set
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/
TT_API TT_STATUS TT_PresetPosition(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_POSITION*	pPosition			// @parm Address of a <t TT_POSITION> structure to set the current position.
	);


/*
@doc EVENT
@func This function registers a callback routine to be executed upon external, periodic, or time compare events.

This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.
The calling application must unregister the callback before exit.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_Callback>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	TT_STATUS (MyCallback) (TT_EVENT, FILETIME*, DWORD, PVOID);

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set callback address
		if (TT_RegisterCallback(hDevice, MyCallback, NULL) == TT_SUCCESS)
		{
			// The callback address has been set
			...
		}
	}
*/
TT_API TT_STATUS TT_RegisterCallback(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_CALLBACK		pCallback,			// @parm Address of a <f TT_CALLBACK> routine to call upon hardware events.	A
										// value of <t NULL> cancels callbacks.
	PVOID			pContext			// @parm Address of user-defined context, passed to callback routine.
	);


/*
@doc EVENT
@func This function is a placeholder for a user-defined callback routine to be executed upon external, periodic,
time compare or synthesizer events.

@rdesc The function does not return a value. 

@xref <f TT_RegisterCallback>

@ex The following example illustrates the use of this function.	|
TT_STATUS MyCallback(TT_EVENT eEventType, FILETIME* pFileTime, DWORD, PVOID pContext)
{
	// based on the type of event
	switch(eEventType)
	{
		case TT_EVENT_EXTERNAL:
			// ...
			break;

		case TT_EVENT_PERIODIC:
			// ...
			break;

		case TT_EVENT_TIME_COMPARE:
			// ...
			break;

		case TT_EVENT_SYNTHESIZER:
			// ...
			break;
	}
}
*/
TT_API void TT_Callback(
	TT_EVENT		eEventType,			// @parm Value specifying the type of event callback (see <t TT_EVENT>).
	FILETIME*		pFileTime,			// @parm Address of <t FILETIME> structure containing the event time.  This field
										//  is not defined when <p eEventType> is <t TT_EVENT_PERIODIC>.
	DWORD			dwMissingInterrupts,// @parm number of missing interrupts.
	PVOID			pContext			// @parm Address of user-defined context.
	);



/*
@doc EVENT
@func This function enables/disables the external input event.  If a callback has been registered (<f TT_RegisterCallback>),
it will be called at the external event.

This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_GetExternalEvent>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set external event
		if (TT_SetExternalEvent(hDevice, TRUE) == TT_SUCCESS)
		{
			// external events are enabled
			...
		}
	}
*/
TT_API TT_STATUS TT_SetExternalEvent(
	HANDLE			hDevice, 			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL			bEnable				// @parm If <t TRUE>, the external event input is enabled, and the registered callback
										//  is called upon occurrance.
	);


/*
@doc EVENT
@func This function returns the current status of the external input event.  If a callback has been registered (<f TT_RegisterCallback>),
it will be called at the external event.

This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_SetExternalEvent> 

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	BOOL	bEnableInterrupt;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get external event
		if (TT_GetExternalEvent(hDevice, &bEnableInterrupt) == TT_SUCCESS)
		{
			// external event is available
			...
		}
	}
*/
TT_API TT_STATUS TT_GetExternalEvent(
	HANDLE			hDevice, 			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL*			bEnableInterrupt	// @parm Address of <t BOOL> to receive current enable status.
	);


/*
@doc EVENT
@func This function enables/disables the time compare event.   If a callback has been registered (<f TT_RegisterCallback>),
it will be called at the requested times.

This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_GetTimeCompare>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	FILETIME FileTime;
	BOOL bEnableInterrupt = TRUE;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// initialize Filetime structure
		FileTime ...;

		// set time compare events
		if (TT_SetTimeCompare(hDevice, &FileTime, TT_CONVERT_NONE, TT_TIME_COMPARE_THR, bEnableInterrupt) == TT_SUCCESS)
		{
			// time compare events are enabled
			...
		}
	}
*/
TT_API TT_STATUS TT_SetTimeCompare(
	HANDLE			hDevice, 			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	FILETIME*		pFileTime,			// @parm Address of <t FILETIME> structure containing the event time to match.
	TT_TIME_CONVERT	eConvertFlag,		// @parm The <t TT_TIME_CONVERT> conversion to apply to the time specified
										//  by <p pFileTime>.
	TT_TIME_COMPARE	eCompareFlag,		// @parm Flag indicating the significant digits of <p pFileTime> to compare
										//  see (<t TT_TIME_COMPARE>).
	BOOL			bEnableInterrupt	// @parm A flag to enable or disable the Time Compare interrupt.
	);


/*
@doc EVENT
@func This function returns the current settings for the time compare event. 

This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_SetTimeCompare>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	FILETIME FileTime;
	TT_TIME_COMPARE	eCompareFlag;
	BOOL bEnableInterrupt;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set time compare events
		if (TT_SetTimeCompare(hDevice, &FileTime, TT_CONVERT_NONE, &eCompareFlag, &bEnableInterrupt) == TT_SUCCESS)
		{
			// time compare events status is available
			...
		}
	}
*/
TT_API TT_STATUS TT_GetTimeCompare(
	HANDLE				hDevice, 			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	FILETIME*			pFileTime,			// @parm Address of <t FILETIME> structure returning the event time to match.
	TT_TIME_CONVERT		eConvertFlag,		// @parm The <t TT_TIME_CONVERT> conversion to apply to the time returned
											//  in <p pFileTime>.
	TT_TIME_COMPARE*	peCompareFlag,		// @parm Address of <t TT_TIME_COMPARE> to receive flag indicating the
											//  significant digits of <p pFileTime> to compare.
	BOOL*				pbEnableInterrupt	// @parm Address of <t BOOL> to receive current Time Compare interrupt status.
	);


/*
@doc EVENT
@func This function enables/disables the rate generator event.  If a callback has been registered (<f TT_RegisterCallback>),
it will be called at the requested rate.

This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_GetRateGenerator>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set rate generator events
		if (TT_SetRateGenerator(hDevice, TT_RATE_10PPS, TRUE) == TT_SUCCESS)
		{
			// 10 PPS rate generator events are enabled
			...
		}
	}
*/
TT_API TT_STATUS TT_SetRateGenerator(
	HANDLE				hDevice, 		// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_GENERATOR_RATE	eRate,			// @parm The rate at which pulses should be generated (see <t TT_GENERATOR_RATE>).
										//  A value of <t TT_RATE_DISABLE> will disable pulse generation.
	BOOL				bEnableInterrupt // @parm A flag to enable or disable the rate generator interrupt.
										//    The rate generator interupt will be automatically turned off if 
										//    interrupts arrive faster than the system can process them.
	);


/*
@doc EVENT
@func This function obtains the current generator event settings.

This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_SetRateGenerator>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	TT_GENERATOR_RATE	eRate;
	BOOL bEnableInterrupt;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get rate generator events
		if (TT_GetRateGenerator(hDevice, &eRate, &bEnableInterrupt) == TT_SUCCESS)
		{
			// the status rate generator events is available
			...
		}
	}
*/
TT_API TT_STATUS TT_GetRateGenerator(
	HANDLE				hDevice, 		// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_GENERATOR_RATE*	peRate,			// @parm Address of <t TT_GENERATOR_RATE> to receive the rate at which pulses are generated.
										//  A value of <t TT_RATE_DISABLE> indicates that pulse generation is disabled.
	BOOL*				pbEnableInterrupt // @parm The address to receive the status of the rate generator interrupt.
	);

/*
@doc SYNTHESIZER
@func This function sets the frequency and enables/disables the synthesizer event.  If a callback has been registered
(<f TT_RegisterCallback>), it will be called at the requested frequency.

This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_GetSynthesizer> <f TT_SetSynthesizerRunStatus>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set synthesizer settings
		if (TT_SetSynthesizer(hDevice, 1000, TRUE) == TT_SUCCESS)
		{
			// Synthesizer is set to 1000 Hz and events are enabled
			...
		}
	}
*/
TT_API TT_STATUS TT_SetSynthesizer(
	HANDLE				hDevice, 		// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	DWORD				dwFrequency,	// @parm The frequency at which pulses should be generated.
										//  A value of 0 will disable pulse generation.
	BOOL				bEnableInterrupt // @parm A flag to enable or disable the synthesizer interrupt.
										//    The synthesizer interupt will be automatically turned off if 
										//    interrupts arrive faster than the system can process them.
	);

/*

@doc SYNTHESIZER
@func This function gets the current synthesizer settings.

This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_RegisterCallback> <f TT_SetSynthesizer> <f TT_GetSynthesizerRunStatus>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	DWORD	dwFrequency;
	BOOL	bEnableInterrupt;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice == TT_SUCCESS)
	{
		// get synthesizer settings
		if (TT_GetSynthesizer(hDevice, &dwFrequency, &bEnableInterrupt) == TT_SUCCESS)
		{
			// the synthesizer settings are now available
			...
		}
	}
*/
TT_API TT_STATUS TT_GetSynthesizer(
	HANDLE				hDevice, 		// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	DWORD*				pdwFrequency,	// @parm Address of <t DWORD > to receive the rate at which pulses are generated.
	BOOL*				bEnableInterrupt // @parm The address to receive the status of the synthesizer interrupt.
);

/*
@doc SYNTHESIZER
@func This function sets Run/Stop status of the synthesizer

This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetSynthesizerRunStatus> <f TT_GetSynthesizer> <f TT_SetSynthesizer>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Stop the synthesizer
		if (TT_SetSynthesizerRunStatus(hDevice,FALSE) == TT_SUCCESS)
		{
			// Synthesizer is stopped 
			...
		}
	}
*/
TT_API TT_STATUS TT_SetSynthesizerRunStatus(
	HANDLE				hDevice, 	// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL				bRun		// @parm A flag to Start or Stop the synthesizer.
	);


/*
@doc SYNTHESIZER
@func This function gets Run/Stop status of the synthesizer


This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref  <f TT_SetSynthesizerRunStatus> <f TT_GetSynthesizer> <f TT_SetSynthesizer>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	BOOL	bRun

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Get the run status of the synthesizer
		if (TT_GetSynthesizerRunStatus(hDevice,&bRun) == TT_SUCCESS)
		{
			// Run status of synthesizer is now available 
			...
		}
	}
*/
TT_API TT_STATUS TT_GetSynthesizerRunStatus(
	HANDLE				hDevice,	// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL*				bRun		// @parm A flag to Start or Stop the synthesizer.
	);


/*
  
@doc TIMECODE
@func This function reads the Locked/Valid status for the TimeCode Input

This function requires <t FILE_GENERIC_READ> access and is available in timecode mode.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	BOOL	bLocked;
	BOOL	bValid;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get timecode information
		if (TT_ReadTimecodeInfo(hDevice, &bLocked, &bValid) == TT_SUCCESS)
		{
			// the timecode information is available
			...
		}
	}
*/

TT_API TT_STATUS TT_ReadTimecodeInfo(
	HANDLE				hDevice, 		// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	BOOL*				bLocked,		// @parm Address of <t BOOL> to receive TimeCode Locked status.
	BOOL*				bValid			// @parm Address of <t BOOL> to receive TimeCode Valid status.
	);


/*
@doc BASIC

@func This function returns the contents of the register at the address specified.  
This function requires <t FILE_GENERIC_READ> access and is available in all modes.


@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetRegister>

@ex The following example illustrates the use of this function.	|
	HANDLE		hDevice
	ULONG		RegisterOffset;
	UCHAR*		RegisterValue;
	
	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// get device info
		if (TT_GetRegister(hDevice, RegisterOffset, &RegisterValue) == TT_SUCCESS)
		{
			// the contents of the register is available
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_GetRegister(
	HANDLE		hDevice,			// @parm The handle to the TrueTime device.
	ULONG		ulRegisterOffset,	// @parm The address of the register to read.
	UCHAR*		pucRegisterValue	// @parm The address of the byte to receive the register contents. 
	);


/*
@doc BASIC
@func This function sets the contents of the register at the address specified.
This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetRegister>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	ULONG	RegisterOffset;
	UCHAR	RegisterValue;


	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set the register data
		if (TT_SetRegister(hDevice, RegisterOffset, RegisterValue) == TT_SUCCESS)
		{
			// the register has now been set
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_SetRegister(
	HANDLE			hDevice,			// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	ULONG			ulRegisterOffset,	// @parm The address of the register to write. 
	UCHAR			ucRegisterValue		// @parm The address of the byte to write to the register.
	);

/*@doc EVENT
@func This function gets the polarity of the trigger to the external event
This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetExternalEventTriggerEdge>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	TT_EXTERNAL_EVENT_TRIGGER_EDGE eExternalEventTriggerEdge;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Get the polarity of the trigger to the synthesizer
		if (TT_GetExternalEventSource(hDevice, &eExternalEventTriggerEdge) == TT_SUCCESS)
		{
			if (eExternalEventTriggerEdge == TT_FALLING)
				// the external event is being triggered on the falling edge
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_GetExternalEventTriggerEdge(
	HANDLE							hDevice,					// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_EXTERNAL_EVENT_TRIGGER_EDGE*	peExternalEventTriggerEdge	// @parm The external event trigger polarity (see <f TT_EXTERNAL_EVENT_TRIGGER_EDGE>).
	);


/*@doc EVENT
@func This function sets the trigger of the external event to rising or falling
This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetExternalEventTriggerEdge>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set the trigger to falling
		if (TT_SetExternalEventEdge(hDevice, TT_FALLING) == TT_SUCCESS)
		{
			// the external event if now set to trigger on the falling edge
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_SetExternalEventTriggerEdge(
	HANDLE							hDevice,					// @parm A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_EXTERNAL_EVENT_TRIGGER_EDGE	eExternalEventTriggerEdge	// @parm The external event trigger polarity (see <f TT_EXTERNAL_EVENT_TRIGGER_EDGE>).
	);


/*@doc EVENT
@func This function gets the source of the trigger for the external event. 
This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetExternalEventTriggerSource>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	TT_EXTERNAL_EVENT_TRIGGER_SOURCE eExternalEventTriggerSource;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Get the trigger source
		if (TT_GetExternalEventSource(hDevice, &eExternalEventTriggerSource) == TT_SUCCESS)
		{
			if (eExternalEventTriggerSource == TT_SYNTHESIZER(
				// the external event is being triggered by the synthesizer
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_GetExternalEventTriggerSource(
	HANDLE								hDevice,					// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_EXTERNAL_EVENT_TRIGGER_SOURCE*	peExternalEventTriggerEdge	// @parm  The external event trigger source <f TT_EXTERNAL_EVENT_TRIGGER_SOURCE>.
	);

/*@doc EVENT
@func This function sets the source of the trigger for the external event This allows more accurate 
real time triggers to freeze the time and removes the PCI buss latency inherent in a software freeze.
This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetExternalEventTriggerSource>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set the trigger source to the synthesizer
		if (TT_SetExternalEventSource(hDevice, TT_SYNTHESIZER) == TT_SUCCESS)
		{
			// the external event will now be triggered by the synthesizer
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_SetExternalEventTriggerSource(
	HANDLE								hDevice,					// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_EXTERNAL_EVENT_TRIGGER_SOURCE	eExternalEventTriggerSource	// @parm  The external event trigger source <f TT_EXTERNAL_EVENT_TRIGGER_SOURCE>.
	);


/*@doc SYNTHESIZER
@func This function gets the on time edge polarity of the synthesizer
This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetSynthesizerOnTimeEdge>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	TT_SYNTHESIZER_ON_TIME_EDGE eSynthesizerOnTimeEdge;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set the on time edge of the synthesizer to falling
		if (TT_GetSynthesizerOnTimeEdge(hDevice, &eSynthesizerOnTimeEdge) == TT_SUCCESS)
		{
			if (eSynthesizerOnTimeEdge == TT_SYNTHESIZER_FALLING)
				// the synthesizer is set to be on time on the falling edge
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_GetSynthesizerOnTimeEdge(
	HANDLE							hDevice,				// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_SYNTHESIZER_ON_TIME_EDGE*	peSynthesizerOnTimeEdge // @parm  The syntesizer on-time edge polarity <f TT_SYNTHESIZER_ON_TIME_EDGE>.
	);


/*@doc SYNTHESIZER
@func This function sets the polarity of the on time edge of the synthesizer
This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetSynthesizerOnTimeEdge>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// set the on time edge of the synthesizer to falling
		if (TT_SetSynthesizerOnTimeEdge(hDevice,TT_SYNTHESIZER_FALLING) == TT_SUCCESS)
		{
			// the synthesizer will now be on time on the falling edge
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_SetSynthesizerOnTimeEdge(
	HANDLE						hDevice,				// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_SYNTHESIZER_ON_TIME_EDGE	eSynthesizerOnTimeEdge	// @parm  The syntesizer on-time edge polarity <f TT_SYNTHESIZER_ON_TIME_EDGE>.
	);

/*@doc BASIC
@func This function allows the saving and restoring of board configuration settings. 
	This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_ReadDiagnosticRegister>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
	TT_CONFIGURATION_SETTINGS eFunction;
	
	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Save the DAC value
		if (TT_ConfigurationSettings(hDevice,eFunction) == TT_SUCCESS)
		{
			// the board configuration has been saved/changed
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_ConfigurationSettings(
	HANDLE				hDevice,	// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_CONFIGURATION_SETTINGS eFunction// @parm  The functions available for board configuration <f TT_CONFIGURATION_SETTINGS>.
	);

/*@doc BASIC
@func This function gets the source that will be available on the output BNC
This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_SetOutputBNCSource>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;
    TT_OUTPUT_BNC_SOURCE eOutputBncSource;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Get the source that is connected to the output BNC
		if (TT_GetOutputBNCSource(hDevice,&eOutputBncSource) == TT_SUCCESS)
		{
			if (eOutputBncSource == TT_OUTPUT_SYNTHESIZER)
				// the synthesizer is being output at the output BNC
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_GetOutputBNCSource(
	HANDLE				hDevice,	// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_OUTPUT_BNC_SOURCE* peOutputBncSource // @parm The varible to receive the output BNC source setting as specified in <f TT_OUTPUT_BNC_SOURCE>.
	);

/*@doc BASIC
@func This function sets the source that will be available on the output BNC
This function requires <t FILE_GENERIC_WRITE> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@xref <f TT_GetOutputBNCSource>

@ex The following example illustrates the use of this function.	|
	HANDLE	hDevice;

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Select the sunthesizer to go out of the output BNC
		if (TT_SetOutputBNCSource(hDevice,TT_OUTPUT_SYNTHESIZER) == TT_SUCCESS)
		{
			// the synthesizer is now being output at the output BNC
			...
		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_SetOutputBNCSource(
	HANDLE				hDevice,	// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_OUTPUT_BNC_SOURCE eOutputBncSource // @parm The source setting for the output BNC as specified in <f TT_OUTPUT_BNC_SOURCE>.
	);

/*@doc BASIC
@func This function returns the contents of the status register
This function requires <t FILE_GENERIC_READ> access and is available in all modes.

@rdesc The function returns <t TT_STATUS>. 

@ex The following example illustrates the use of this function.	|
	HANDLE					hDevice;
	TT_HARDWARE_STATUS		HardwareStatus

	// open device 0 for Read/Write access
	if (TT_OpenDevice(0, GENERIC_READ | GENERIC_WRITE, &hDevice) == TT_SUCCESS)
	{
		// Get the board status
		if (TT_GetStatus(hDevice,&HardwareStatus) == TT_SUCCESS)
		{
			// Check the antenna
			if (HardwareStatus.AntennaShorted)
				// The antenna is shorted

		}
		// close the device
		TT_CloseDevice(hDevice);
	}
*/

TT_API TT_STATUS TT_GetHardwareStatus(
	HANDLE					hDevice,			// @parm  A handle to the TrueTime device, returned by <f TT_OpenDevice>.
	TT_HARDWARE_STATUS*		pHardwareStatus		// @parm  A structure <f TT_HARDWARE_STATUS> that will contain the status of the device.
	);

BOOL TT_API_SUCCESSFUL(LPCSTR pAPIName, TT_STATUS tt_status);

#ifdef __cplusplus
}

#endif  // __cplusplus

#endif

