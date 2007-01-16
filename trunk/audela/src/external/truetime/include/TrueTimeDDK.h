/*++

Copyright (c) 1998  The Software Studio Inc.

Module Name:


	TrueTimeDDK.H

Abstract:

	This file defines the structures and defines that are used in the
    TrueTime SDK and DDK for GPS (PCI Plug-In Card).

  	@doc DDK

	@module TrueTimeDDK.H | Defines the SDK-DDK Interface for the TrueTime 560-590x devices.


Author:

    Dattatraya Rajpure (Dats)

Environment:

    WinNT 4.0 Kernel mode / Win95 VxD

Revision History:


--*/

#ifndef TRUETIMEDDK_H_
#define TRUETIMEDDK_H_

#pragma pack(1)

#include "TrueTimeCmn.h"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	@doc Following Declarations and Definitions are Used by SDK and TrueTime Kernel Mode Driver.
//



#if 0
/*
@func The CreateFile function opens the TrueTime driver and returns a handle that can be used to access
devices through <f DeviceIoControl> calls. 

@rdesc If the function succeeds, the return value is an open handle to the TrueTime driver.
If the function fails, the return value is INVALID_HANDLE_VALUE. To get extended error
information, call <f GetLastError>.
*/

HANDLE CreateFile(
  LPCTSTR lpFileName,							// @parm pointer to name of the file (use <t TT_DEVICE_NAME>)
  DWORD dwDesiredAccess,						// @parm access mode (use <t GENERIC_READ> or'd with <t GENERIC_WRITE>)
  DWORD dwShareMode,							// @parm share mode (use <t FILE_SHARE_READ> or none)
  LPSECURITY_ATTRIBUTES lpSecurityAttributes,	// @parm pointer to security attributes (set to <t NULL>)
  DWORD dwCreationDisposition,					// @parm how to create (use <t OPEN_EXISTING>)
  DWORD dwFlagsAndAttributes,					// @parm file attributes (use <t FILE_FLAG_OVERLAPPED>)
  HANDLE hTemplateFile							// @parm handle to file with attributes to copy (set to <t NULL>)
);

/*
@func The DeviceIoControl function sends a control code directly to the TrueTime driver,
causing it to perform the specified operation. 

@comm Fore special control codes are defined for the TrueTime driver.  They are: <f TT_IOCTL_GETREG>,
<f TT_IOCTL_SETREG>, <f TT_IOCTL_WAIT_ON_INTR>, <f TT_IOCTL_CANCEL_REQ>.

<f TT_IOCTL_GETREG> <em-> Get the specified information from the TrueTime driver about GPS PCI Plug-In Card.

Set <p dwIoControlCode> to TT_IOCTL_GETREG

Set <p lpInBuffer> to <t TT_REG_XXX> the desired function requested. (see <t TT_IOCTL_LOGICAL_REGISTERS>) 

Set <p nInBufferSize> to <t sizeof(long)>

Set <p lpOutBuffer> to the address of a <t TT_BUFFER> structure to receive the desired data

Set <p nOutBufferSize> to <t sizeof(TT_BUFFER)>

Upon successful return, <p lpOutBuffer> will be filled in with specified information depending on the 
function requested by <p lpInBuffer>.

<f TT_IOCTL_SETREG> <em-> Write the GPS PCI Plug-In Card configuration space for desired operation.

Set <p dwIoControlCode> to TT_IOCTL_SETREG

Set <p lpInBuffer> to <t TT_REG_XXX> the desired function requested. (see <t TT_IOCTL_LOGICAL_REGISTERS>)

Set <p nInBufferSize> to <t sizeof(long)>

Set <p lpOutBuffer> to the address of a <t TT_BUFFER> structure containing the desired configuration data

Set <p nOutBufferSize> to <t sizeof(TT_BUFFER)>

Upon successful return, the configuration data for the specified device will be updated depending on the 
function requested by <p lpInBuffer>.

<f TT_IOCTL_WAIT_ON_INTR> <em-> Send the request to receive the notification from TrueTime Driver on an Interrupt
occured for the specified device. This IOCTL is used to receive the notification for all the type of Interrupts 
supported by GPS PCI Plug-In Card.

Set <p dwIoControlCode> to 	TT_IOCTL_WAIT_ON_INTR

Set <p lpInBuffer> to <t NULL>

Set <p nInBufferSize> to <t NULL>

Set <p lpOutBuffer> to the address of <t TT_INTERRUPTINFO>, to receive the Information for interrupt occured.

Set <p nOutBufferSize> to <t sizeof(TT_INTERRUPTINFO)>

Upon successful return, <p lpOutBuffer> will be filled with the information for the interrupt occured.


<f TT_IOCTL_CANCEL_REQ> <em-> Send the request to cancel any outstanding requests for TT_IOCTL_WAIT_ON_INTR. 

Set <p dwIoControlCode> to 	TT_IOCTL_CANCEL_REQ

Set <p lpInBuffer> to <t NULL>

Set <p nInBufferSize> to <t NULL>

Set <p lpOutBuffer> to <t NULL>

Set <p nOutBufferSize> to <t NULL>

Always returns STATUS_SUCCESS.


@rdesc If the function succeeds, the return value is nonzero.
If the function fails, the return value is zero. To get extended error information, call <f GetLastError>. 
*/
BOOL DeviceIoControl(
    HANDLE hDevice,				// @parm handle to device of interest                               
    DWORD dwIoControlCode,		// @parm control code of operation to perform                       
    LPVOID lpInBuffer,			// @parm pointer to buffer to supply input data                     
    DWORD nInBufferSize,		// @parm size of input buffer                                       
    LPVOID lpOutBuffer,			// @parm pointer to buffer to receive output data                   
    DWORD nOutBufferSize,		// @parm size of output buffer                                      
    LPDWORD lpBytesReturned,	// @parm pointer to variable to receive output byte count           
    LPOVERLAPPED lpOverlapped	// @parm pointer to overlapped structure for asynchronous operation 
    );

#endif



//
// Definitions for Logical Registers on  GPS PCI Plug-In Card
// Used by SDK and Kernel-Mode-Driver Interface.
//

/* @enum TT_IOCTL_LOGICAL_REGISTERS | Values specifying the type of functions requested in an IOCTL call.

*/
typedef enum {
	TT_REG_DEVICEINFO			= 0x1000,	// @emem IOCTL to Get Device Info.
	TT_REG_EXTERNALEVENT,					// @emem IOCTL to Get/Set External Event.
	TT_REG_LEAPSECOND,						// @emem IOCTL to Get/Set Leap Second.
	TT_REG_MODE,							// @emem IOCTL to Get/Set current Operating Mode.
	TT_REG_PHASECOMPENSATION,				// @emem IOCTL to Get/Set Phase Compensation for the device.
//	TT_REG_PHASECOMPENSATION_100NS,			// @emem IOCTL to Get/Set 100ns Phase Compensation for the device.
//	TT_REG_FACTORY_CALIBRATION,				// @emem IOCTL to Get/Set Factory settings for the device.
	TT_REG_RATEGENERATOR,					// @emem IOCTL to Get/Set Rate Generator event.
	TT_REG_SYNTHESIZER,						// @emem IOCTL to Get/Set Synthesizer frequency
	TT_REG_SYNTHESIZERRUNSTATUS,			// @emem IOCTL to Get/Set Synthesizer Run status.
	TT_REG_TIMECODEOUTPUT,					// @emem IOCTL to Get/Set Time Code OutPut format for the device.
	TT_REG_TIMECOMPARE,						// @emem IOCTL to Get/Set Time Compare Event.
	TT_REG_PRESETPOSITION,					// @emem IOCTL to Preset the GPS position.
	TT_REG_PRESETTIME,						// @emem IOCTL to Preset the current Time in the device.
	TT_REG_DIAGNOSTIC,						// @emem IOCTL to Get Error & Oscillator values from Diagnostic Reg.
	TT_REG_GPSINFO,							// @emem IOCTL to Get GPS Position Info.
	TT_REG_READTIME,						// @emem IOCTL to Read the current Time in the device.
	TT_REG_GENERATOR,						// @emem IOCTL to Start/Stop Generator.
	TT_REG_TIMECODEINFO,					// @emem IOCTL to Get TimeCode Info.
	TT_REG_VALUE,     						// @emem IOCTL to Get/Set Registers directly.
	TT_REG_OUTPUT_BNC_SOURCE,				// @emem IOCTL to Get/Set Registers directly.
	TT_REG_EXTERNAL_EVENT_TRIGGER_EDGE,		// @emem IOCTL to Get/Set external event trigger polaity.
	TT_REG_EXTERNAL_EVENT_TRIGGER_SOURCE,	// @emem IOCTL to Get/Set external event trigger source.
	TT_REG_HARDWARE_STATUS,					// @emem IOCTL to Get hardware status
	TT_REG_SYNTHESIZER_ON_TIME_EDGE,		// @emem IOCTL to Get/Set synthesizer on-time edge
	TT_REG_CONFIGURATION_SETTINGS			// @emem IOCTL to Save and restore board configuration
} TT_IOCTL_LOGICAL_REGISTERS;



/* @enum TT_INTERRUPT_TYPE | Values specifying the type of Interrupt.

*/
//typedef enum {
//	TT_INT_EXTERNAL_EVENT		= 0x10,		// @emem Interrupt due to External Event.
//	TT_INT_TIME_COMPARE,					// @emem Interrupt due to Time Compare.
//	TT_INT_RATE_GENERATOR,					// @emem Interrupt due to Rate Generator Signal.
//} TT_INTERRUPT_TYPE;


//
// Structures used by SDK and Kernel-Mode-Driver Interface.
//

#define TT_WIN32_SYMBOLIC_NAME		L"TrueTimePCI" // This is the name used by SDK to connect to driver



// @struct TT_GPSPOSITION | The structure is used to read the position consisting of latitude, longitude, 
// and elevation for satellites.
typedef struct _TT_GPSPOSITION{

	// GPS Position
	USHORT	usLatitudeDeg;				// @field Latitude in degrees, from -90 (south) to +90 (north).
	USHORT	usLatitudeMin;				// @field Latitude in minutes.
	UCHAR	ucLatitudeNS;				// @field Latitude 'N'(0x4E)/'S'(0x53) ASCII Byte.
	USHORT	usLatitudeTenthsSec;		// @field Latitude in Tenths of seconds.
	
	USHORT	usLongitudeDeg;				// @field Longitude in degrees, from -180 (east) to +180 (west).
	USHORT	usLongitudeMin;				// @field Longitude in minutes
	UCHAR	ucLongitudeEW;				// @field Longitude 'E'(0x45)/'W'(0x57) ASCII Byte.
	USHORT	usLongitudeTenthsSec;		// @field Longitude in Tenths of seconds

	ULONG	ulElevationTenthsMet;		// @field Elevation in Tenths of meters, above and below sea level.
	UCHAR	ucElevationSign;			// @field Elevation sign '-'(0x2D)/'+'(0x2B) ASCII Byte.

} TT_GPSPOSITION, *PTT_GPSPOSITION;


// @struct TT_INTERRUPTINFO | This structure is used to return the information about the Interrupt
// occured.
typedef struct _TT_INTERRUPTINFO{

	SYSTEMTIME_EX		sSystemTime;	// @field structure <t SYSTEMTIME_EX> containing the time when 
										//  Interrupt occured
	TT_EVENT			eIntType;		// @field Indicates the Type of Interrupt occured.
	ULONG				ulIntMissing;	// @field Indicates the number of Interrupt missed by Application.

} TT_INTERRUPTINFO, *PTT_INTERRUPTINFO;


// @struct TT_DEVICEINFO | This structure is used to get static information about the board.
// 
typedef struct _TT_DEVICEINFO{

	TT_MODEL			eModel;			// @field enum to receive <t TT_MODEL>
	ULONG				ulBus;			// @field <t DWORD> to receive the bus number of the card.
	ULONG				ulSlot;			// @field <t DWORD> to receive the slot number of the card.

} TT_DEVICEINFO, *PTT_DEVICEINFO;



// @struct TT_EXTERNALEVENT | This structure is either used to get the current status of the external input event 
// OR to enables/disables the external input event.
typedef struct _TT_EXTERNALEVENT{

	BOOL				bEnable;			// @field flag indicates enable/disable external input event.

} TT_EXTERNALEVENT, *PTT_EXTERNALEVENT;



// @struct TT_LEAPSECOND | This structure is either used to get the current status of the hardware
// to add a leap second at the end of the current day.
// OR enables/disables the hardware for leap second.
typedef struct _TT_LEAPSECOND{

	BOOL				bEnable;			// @field flag indicates enable/disable hardware for leap second.

} TT_LEAPSECOND, *PTT_LEAPSECOND;



// @struct TT_REGISTER | This structure is either used to get the value of a register
// or to set it.
typedef struct _TT_REGISTER{

	ULONG				ulRegisterOffset;			// @field the offset address of the register to set or get.
	UCHAR				ucRegisterValue;			// @field the value going to or from the register.

} TT_REGISTER, *PTT_REGISTER;


// @struct TT_MODE | This structure is either used to get the current operating mode, which maintain by the 
// hardware in non-volatile memory. 
// OR to set the current operating mode.
typedef struct _TT_MODE{

	TT_OPERATION_MODE	eOperationMode;	// @field The desired operation mode (see <t TT_OPERATION_MODE>).
	TT_SYNCH_SOURCE		eSynchSource;	// @field When <p eOperationMode> is <t TT_MODE_SYNCHRONIZED>, <p eSynchSource>
										//  specifies the desired synchronization source (see <t TT_SYNCH_SOURCE>).
	TT_TIMECODE			eTimeCode;		// @field When <p eSynchSource> is <t TT_SYNCH_TIMECODE>, <p eTimeCode>
										//  specifies the desired timecode standard (see <t TT_TIMECODE>).
} TT_MODE, *PTT_MODE;



// @struct TT_PHASECOMPENSATION | This structure is used to get/set the phase compensation for the device.
typedef struct _TT_PHASECOMPENSATION{

//	LONG				lOffset;		// @field Specifies the desired/receive compensation from -1000 to +1000 microseconds.
	SHORT				shOffset;		// @field Specifies the desired/receive compensation from -1000 to +1000 microseconds.

} TT_PHASECOMPENSATION, *PTT_PHASECOMPENSATION;


// @struct TT_PHASECOMPENSATION_100NS | This structure is used to get/set the 100 ns phase compensation for the device.
typedef struct _TT_PHASECOMPENSATION_100NS{

	UCHAR				uc100nsOffset;		// @field Specifies the desired/receive compensation from 0 to 900 nanoseconds in 100ns steps.

} TT_PHASECOMPENSATION_100NS, *PTT_PHASECOMPENSATION_100NS;


// @struct FACTORY_CALIBRATION | This structure is used to do factory calibration on the device..
typedef struct _TT_FACTORY_CALIBRATION{

	UCHAR				ucFactoryCalibration;		// @field Specifies the desired/receive compensation from 0 to 900 nanoseconds in 100ns steps.

} TT_FACTORY_CALIBRATION, *PTT_FACTORY_CALIBRATION;

// @struct TT_RATEGENERATOR | The structure is used to enables/disables the rate generator event.
// OR to receive the enable status.
typedef struct _TT_RATEGENERATOR{

	TT_GENERATOR_RATE	eRate;			// @field The rate at which pulses should be generated (see <t TT_GENERATOR_RATE>).
										//  A value of <t TT_RATE_DISABLE> will disable pulse generation.
//	LONG				lVariableRate;	// @field The variable rate to use when <p eRate> is equal to <t TT_RATE_VARIABLE>.
	BOOL				bEnableInterrupt; // The Flag indicate to Enable/Disable Interrupt


} TT_RATEGENERATOR, *PTT_RATEGENERATOR;

// @struct TT_SYNTHESIZER | The structure is used to set the frequency or enable/disable the synthesizer event.
// OR to receive the frequency and the enable status.
typedef struct _TT_SYNTHESIZER{

	DWORD		dwFrequency;	// @field The frequency at which pulses should be generated.
								//  A value of 0 will disable pulse generation.
	BOOL		bEnableInterrupt; // The Flag indicating to Enable/Disable Interrupt

} TT_SYNTHESIZER, *PTT_SYNTHESIZER;

// @struct TT_SYNTHESIZERRUNSTATUS | The structure is used to set the Run/Stop status of the synthesizer.
typedef struct _TT_SYNTHESIZERRUNSTATUS{

	BOOL		bRun; // The Flag indicating Run/Stop status

} TT_SYNTHESIZERRUNSTATUS, *PTT_SYNTHESIZERRUNSTATUS;


// @struct TT_TIMECODEOUTPUT | The structure is used to get/set the current timecode output format for the device.
typedef struct _TT_TIMECODEOUTPUT{

	TT_TIMECODE			eTimeCode;		// @field Specifies-desired/Receive timecode standard (see <t TT_TIMECODE>).

} TT_TIMECODEOUTPUT, *PTT_TIMECODEOUTPUT;



// @struct TT_TIMECOMPARE | The structure is used either to enables/disables the time compare event 
// OR to receive the current settings for time compare event.
typedef struct _TT_TIMECOMPARE{

	SYSTEMTIME_EX		sSystemTime;	// @field <t SYSTEMTIME_EX> structure containing the event time to match.
	TT_TIME_COMPARE		eCompareFlag;	// @field Flag indicating the significant digits of <t pSystemTime> to compare
										//  see (<t TT_TIME_COMPARE>).
	BOOL				bEnableInterrupt;// Address of <t BOOL> with interrupt status

} TT_TIMECOMPARE, *PTT_TIMECOMPARE;



// @struct TT_PRESETPOSITION | This structure is used to preset the GPS position.
typedef struct _TT_PRESETPOSITION{

	TT_GPSPOSITION		sPosition;			// @field structure <t TT_GPSPOSITION> containing the Position Info

} TT_PRESETPOSITION, *PTT_PRESETPOSITION;



// @struct TT_PRESETTIME | This structure is used to preset the Generator time in the device by writing 
// the Preset Time Resgister, converting it as specified by eConvertFlag.
typedef struct _TT_PRESETTIME{

	SYSTEMTIME_EX		sSystemTime;	// @field <t SYSTEMTIME_EX> structure containing the time

} TT_PRESETTIME, *PTT_PRESETTIME;



// @struct TT_DIAGNOSTIC | The structure is used to read the error and oscillator values from the 
// diagnostic register.
typedef struct _TT_DIAGNOSTIC{

	TT_DIAG_ERROR		eDiagnostic;	// @field <t TT_DIAG_ERROR> to receive hardware error status flags.
	UCHAR				ucDACCtl;
	USHORT				usDAC;			// @field receive current setting of frequency control DAC.

} TT_DIAGNOSTIC, *PTT_DIAGNOSTIC;



// @struct TT_GPSSIGNAL | GPS satellite signal strength.
typedef struct _TT_GPSSIGNAL {
	
	ULONG				ulPRN;					// @field Satellite ID.
	ULONG				ulHundredthsStrength;	// @field Hundredths of Signal strength after correlation or de-spreading.

} TT_GPSSIGNAL;

// @struct TT_GPSSIGNALS | Signal strength data for up to six satellites.
typedef struct _TT_GPSSIGNALS {

	ULONG				ulCount;						// @field Number of satellites acquired and locked.
	TT_GPSSIGNAL		sSatellite[TT_MAX_SATELLITES];	// @field Signal strength data (see <t TT_GPSSIGNAL>).
	BOOL				bGPSLock;						// @field Flag to indicate the GPS Lock/Unlock Status

} TT_GPSSIGNALS;


// @struct TT_GPSINFO | The structure is used to read the GPS position consisting of latitude, longitude, 
// and elevation, and satellite signal information for up to six satellites.
typedef struct _TT_GPSINFO{

	TT_GPSPOSITION		sPosition;			// @field structure <t TT_GPSPOSITION> containing the Position Info
	TT_GPSSIGNALS		sSignals;			// @field structure <t TT_GPSSIGNALS> containing the Signal Info
	TT_ANTENNA			sAntenna;			// @field structure <t TT_GPSSIGNALS> containing the Antenna status
} TT_GPSINFO, *PTT_GPSINFO;



// @struct TT_READTIME | This structure is used to retrive the current time value from the device  
// Time Freeze Register, converting it as specified by eConvertFlag.
typedef struct _TT_READTIME{

	SYSTEMTIME_EX		sSystemTime;	// @field <t SYSTEMTIME_EX> structure containing the time

} TT_READTIME, *PTT_READTIME;



// @struct TT_GENERATOR | The structure is used to enable/disable the device to accumulate time.
typedef struct _TT_GENERATOR{
	
	BOOL				bStart;			// @field if <t TRUE> then enable the device to accumulate time otherwise
										// stop accumulation of the device.

} TT_GENERATOR, *PTT_GENERATOR;


// @struct TT_TIMECODEINFO | The structure is used to enable/disable the device to accumulate time.
typedef struct _TT_TIMECODEINFO{
	
	BOOL		 bLocked;				// @field if <t TRUE> then GPS is phaselocked to TimeCode or External 1PPS
	BOOL		 bValid;				// @field if <t TRUE> then TimeCode or External 1PPS is valid

} TT_TIMECODEINFO, *PTT_TIMECODEINFO;

// @struct TT_OUTPUTBNCSOURCE | The structure is used to set/get the output BNC source.
typedef struct _TT_OUTPUTBNCSOURCE{
	
	TT_OUTPUT_BNC_SOURCE	eOutputBncSource; // @field <t TT_OUTPUT_BNC_SOURCE> containing the selections for the output BNC source

} TT_OUTPUTBNCSOURCE, *PTT_OUTPUTBNCSOURCE;

// @struct TT_EXTERNAL_EVENT_TRIGGER_EDGE | The structure is used to set/get the trigger polarity of the external event.
typedef struct _TT_EXTERNAL_EVENT_TRIGGER_EDGE{

	TT_EXTERNAL_EVENT_TRIGGER_EDGE	eExternalEventTriggerEdge; // @field <t TT_EXTERNAL_EVENT_TRIGGER_EDGE> contains the rising and falling selections

} TT_EXTERNALEVENTTRIGGEREDGE, *PTT_EXTERNALEVENTTRIGGEREDGE;

// @struct TT_EXTERNAL_EVENT_TRIGGER_SOURCE | The structure is used to set/get the external event trigger source
typedef struct _TT_EXTERNAL_EVENT_TRIGGER_SOURCE{

	TT_EXTERNAL_EVENT_TRIGGER_SOURCE	eExternalEventTriggerSource;	// @field <t TT_EXTERNAL_EVENT_TRIGGER_SOURCE> contains the trigger sources for the external event

} TT_EXTERNALEVENTTRIGGERSOURCE, *PTT_EXTERNALEVENTTRIGGERSOURCE;

// @struct TT_HARDWARESTATUS | The structure is used to get the hardware status
typedef struct _TT_HARDWARESTATUS{

	TT_HARDWARE_STATUS	eHardwareStatus;	// @field <t TT_HARDWARE_STATUS> contains the hardware status

} TT_HARDWARESTATUS, *PTT_HARDWARESTATUS;

// @struct TT_CONFIGURATIONSETTINGS | The structure is used to send configuration functions
typedef struct _TT_CONFIGURATIONSETTINGS{

	TT_CONFIGURATION_SETTINGS	eConfigurationSettings;	// @field <t TT_HARDWARE_STATUS> contains the hardware status

} TT_CONFIGURATIONSETTINGS, *PTT_CONFIGURATIONSETTINGS;

// @struct TT_SYNTHESIZERONTIMEEDGE | The structure is used to get the polarity of the synthesizers on-time edge
typedef struct _TT_SYNTHESIZERONTIMEEDGE{

	TT_SYNTHESIZER_ON_TIME_EDGE	eSynthesizerOnTimeEdge;	// @field <t TT_SYNTHESIZER_ON_TIME_EDGE> contains the the rising and falling selections

} TT_SYNTHESIZERONTIMEEDGE, *PTT_SYNTHESIZERONTIMEEDGE;


// @union TT_BUFFER | 
typedef union _BUFFER{
	
		TT_DEVICEINFO			sDeviceInfo;		// @field Structure Get Device Information.
		TT_EXTERNALEVENT		sExternalEvent;		// @field Structure Get/Enable-Disable External Event.
		TT_LEAPSECOND			sLeapSecond;		// @field Structure Get/Enable-Disable Leap Second.
		TT_SYNTHESIZERRUNSTATUS	sSynthesizerRunStatus;// @field Structure Get/Set systhesizer run status.
		TT_REGISTER				sRegister;			// @field Structure Get/Set Register Value.
		TT_MODE					sMode;				// @field Structure Get/Set Mode.
		TT_PHASECOMPENSATION	sPhaseCompensation;	// @field Structure Get/Set Pahse Compensation.
		TT_PHASECOMPENSATION_100NS	sPhaseCompensation_100ns;	// @field Structure Get/Set Pahse Compensation.
		TT_FACTORY_CALIBRATION	sFactoryCalibration;
		TT_RATEGENERATOR		sRateGenerator;		// @field Structure Get/Set Rate Generator.
		TT_SYNTHESIZER			sSynthesizer;		// @field Structure Get/Set Rate Generator.
		TT_TIMECODEOUTPUT		sTimeCodeOutput;	// @field Structure Get/Set Time Code Output.
		TT_TIMECOMPARE			sTimeCompare;		// @field Structure Get/Set Time Compare.
		TT_PRESETPOSITION		sPresetPosition;	// @field Structure Preset Position.
		TT_PRESETTIME			sPresetTime;		// @field Structure Preset Time.
		TT_DIAGNOSTIC			sDiagnostic;		// @field Structure Get Diagnostic.
		TT_GPSINFO				sGPSInfo;			// @field Structure Read GPS Information.
		TT_READTIME				sReadTime;			// @field Structure Read Time from Time Freeze Reg.
		TT_GENERATOR			sGenerator;			// @field Structure Start Stop Generator
		TT_TIMECODEINFO			sTimeCodeInfo;		// @field Structure returns Timecode Information
		TT_OUTPUTBNCSOURCE		sOutputBncSource;	// @field Structure Get/Set BNC output source
		TT_EXTERNALEVENTTRIGGEREDGE sExternalEventTriggerEdge; // @field Structure Get/Set external event trigger polarity
		TT_EXTERNALEVENTTRIGGERSOURCE sExternalEventTriggerSource; // @field Structure Get/Set external event trigger source
		TT_HARDWARESTATUS sHardwareStatus; // @field Structure Get hardware status 
		TT_CONFIGURATIONSETTINGS sConfigurationSettings; // @field Structure for Configuration Function 
		TT_SYNTHESIZERONTIMEEDGE sSynthesizerOnTimeEdge; // @field Structure Get/Set sythesizer on time edge polarity 
} TT_BUFFER, *PTT_BUFFER;


//
// Macro definition for defining IOCTL function control codes.
//
#define FILE_DEVICE_TRUETIME	0x8180
#define TT_IOCTL_WAIT_ON_INTR	CTL_CODE(FILE_DEVICE_TRUETIME, 0x803, METHOD_OUT_DIRECT, FILE_ANY_ACCESS)
#define TT_IOCTL_CANCEL_REQ		CTL_CODE(FILE_DEVICE_TRUETIME, 0x804, METHOD_OUT_DIRECT, FILE_ANY_ACCESS)
#define DEVIOCTL_ERROR			1

#endif

