/*++

Copyright (c) 1998  TrueTime Inc.

Module Name:

    TrueTimeCmn.h

Abstract:

	The header Include file for TrueTime Applications/SDK/DDK

	@doc

	@module TrueTimeCmn.H | Defines the common structures, enums and definitions used by
	Applications/SDK/DDK for the TrueTime 560-590x devices.

Environment:

    MSVC++ 5.0/WinNT Kernel Mode Driver/Win95 VxD

Revision History:


--*/


#ifndef TRUETIMECMN_H_
#define TRUETIMECMN_H_

#define TT_MAX_SATELLITES			6		// Maximum number of Satellites supported

// @enum TT_MODEL | Values specifying the model of the device.
typedef enum {
	TT_MODEL_5900	= 0x5900,			// @emem Model 5900 - PCI bus time card
	TT_MODEL_5901	= 0x5901,			// @emem Model 5901 - PCI bus time card with GPS receiver
	TT_MODEL_5905	= 0x5905,			// @emem Model 5905 - PCI bus time card with Synthesizer
	TT_MODEL_5906	= 0x5906,			// @emem Model 5906 - PCI bus time card with Synthesizer and GPS receiver
	TT_MODEL_5907	= 0x5907,			// @emem Model 5907 - PCI2 bus time card
	TT_MODEL_5908	= 0x5908,			// @emem Model 5908 - PCI2 bus time card with GPS receiver
	TT_MODEL_5950	= 0x5950,			// @emem Model 5950 - Compact PCI bus time card
	TT_MODEL_5951	= 0x5951,			// @emem Model 5951 - Compact PCI bus time card with GPS receiver
} TT_MODEL;


// @enum TT_OPERATION_MODE | Values specifying the operational mode of the device.
typedef enum {
	TT_MODE_GENERATOR	= 0x01,		// @emem The device is running on its internal oscillator
	TT_MODE_SYNCHRONIZED,			// @emem The device is synchronized to an external source
} TT_OPERATION_MODE;

// @enum TT_SYNCH_SOURCE | Values specifying a synchronization source.
typedef enum {
	TT_SYNCH_1PPS		= 0x01,		// @emem The synchronization signal is a 1 pulse per second input.
	TT_SYNCH_GPS,					// @emem The synchronization signal is a global positioning system receiver.
	TT_SYNCH_TIMECODE,				// @emem The synchronization signal is a timecode source.
} TT_SYNCH_SOURCE;

// @enum TT_TIMECODE | Values specifying a timecode standard.
typedef enum {
	TT_TIMECODE_IRIGA_DC = 0x01,	// @emem The timecode is IRIG-A, in DC mode.
	TT_TIMECODE_IRIGA_AM,			// @emem The timecode is IRIG-A, in AM mode.
	TT_TIMECODE_IRIGB_DC,			// @emem The timecode is IRIG-B, in DC mode.
	TT_TIMECODE_IRIGB_AM,			// @emem The timecode is IRIG-B, in AM mode.
} TT_TIMECODE;

// @enum TT_EVENT | Values specifying an event.
typedef enum {
	TT_EVENT_EXTERNAL = 0x01,		// @emem The event is a pulse input on pin 1 of the 9-pin connector.
									//  These events can occur at a maximum rate of 100 pulses per second, and must be
									//  at least 3 ms apart.  
	TT_EVENT_PERIODIC,				// @emem The event is a pulse output on pin 7 of the 9-pin connector with one of 
									//  five fixed rates.  The signal is synchronous with the board timing and the 
									//  rising edge is on time.
	TT_EVENT_TIME_COMPARE,			// @emem The event is a pulse output on pin 9 of the 9-pin connector at a preset time.
									//  The rising edge of this pulse is on-time. 
	TT_EVENT_SYNTHESIZER,			// @emem The event is a pulse output on IRIG OUT of the BNC connector 
									//  The signal is synchronous with the board timing and the trailing edge is on time.
} TT_EVENT;

/*++
// @enum TT_GENERATOR_RATE | Values specifying the rate of generated output pulses.
/*typedef enum {
	TT_RATE_DISABLE = 0x00,			// @emem Disable pulse generation.
	TT_RATE_10KPPS,					// @emem Generate 10,000 pulses per second.
	TT_RATE_1KPPS,					// @emem Generate 1,000 pulses per second.
	TT_RATE_100PPS,					// @emem Generate 100 pulses per second.
	TT_RATE_10PPS,					// @emem Generate 10 pulses per second.
	TT_RATE_1PPS,					// @emem Generate 1 pulse per second.
	TT_RATE_VARIABLE,				// @emem Generate pusles at the specified variable rate.
} TT_GENERATOR_RATE;
--*/
	
// @enum TT_GENERATOR_RATE | Values specifying the rate of generated output pulses.
typedef enum {
	TT_RATE_DISABLE = 0x00,			// @emem Disable pulse generation.
	TT_RATE_10KPPS,					// @emem Generate 10,000 pulses per second.
	TT_RATE_1KPPS,					// @emem Generate 1,000 pulses per second.
	TT_RATE_100PPS,					// @emem Generate 100 pulses per second.
	TT_RATE_10PPS,					// @emem Generate 10 pulses per second.
	TT_RATE_1PPS,					// @emem Generate 1 pulse per second.
	TT_RATE_100KPPS,				// @emem Generate 100,000 pulses per second.
	TT_RATE_1MPPS,					// @emem Generate 1,000,000 pulses per second.
	TT_RATE_5MPPS,					// @emem Generate 5,000,000 pulses per second.
	TT_RATE_10MPPS,					// @emem Generate 10,000,000 pulses per second.
} TT_GENERATOR_RATE;

// @enum TT_TIME_COMPARE | Values specifying the significant digits of a time comparison.
typedef enum {
	TT_TIME_COMPARE_ALL  = 0x00,	// @emem Compare all digits.
	TT_TIME_COMPARE_TDAY = 0x01,	// @emem Compare through tens of days.
	TT_TIME_COMPARE_UDAY = 0x02,	// @emem Compare through units of days.
	TT_TIME_COMPARE_THR  = 0x03,	// @emem Compare through tens of hours.
	TT_TIME_COMPARE_UHR  = 0x04,	// @emem Compare through units of hours.
	TT_TIME_COMPARE_TMIN = 0x05,	// @emem Compare through tens of minutes.
	TT_TIME_COMPARE_UMIN = 0x06,	// @emem Compare through units of minutes.
	TT_TIME_COMPARE_TSEC = 0x07,	// @emem Compare through tens of seconds.
	TT_TIME_COMPARE_USEC = 0x08,	// @emem Compare through units of seconds.
	TT_TIME_COMPARE_HMS  = 0x09,	// @emem Compare through hundreds of milliseconds.
	TT_TIME_COMPARE_TMS  = 0x0A,	// @emem Compare through tens of milliseconds.
	TT_TIME_COMPARE_UMS  = 0x0B,	// @emem Compare through units of milliseconds.
	TT_TIME_COMPARE_DISABLE  = -1,	// @emem Disable the Compare event.
} TT_TIME_COMPARE;

// @struct TT_DIAG_ERROR | Hardware diagnostic register.
typedef struct _TT_DIAG_ERROR {
	BOOL	bClockError;	// @field BOOL | bClockError:1    | Indicates processor clock failure.
	BOOL	bRamError;		// @field BOOL | bRamError:1      | Indicates onboard RAM failure.
	BOOL	bDacLimit;		// @field BOOL | bDacLimit:1      | Indicates DAC setting near the limit.
	BOOL	bHardwareError;	// @field BOOL | bHardwareError:1 | Indicates general hardware error.
} TT_DIAG_ERROR;

/*
@struct SYSTEMTIME_EX | The SYSTEMTIME_EX structure represents a date and time using individual members for the 
month, day, year, weekday, hour, minute, second, millisecond, microsecond, and nanosecond. The first 8 WORDS of 
this structure are identical to, and therefore interchangable with, the Win32 <t SYSTEMTIME> structure.

@comm It is not recommended that you add and subtract values from the SYSTEMTIME_EX structure to obtain relative times.
Instead, you should convert the SYSTEMTIME_EX structure to a FILETIME structure and use normal 64-bit arithmetic 
on the LARGE_INTEGER value.
*/

typedef struct _SYSTEMTIME_EX {
    WORD wYear;				// @field Specifies the current year. 
    WORD wMonth; 			// @field Specifies the current month; January = 1, February = 2, and so on.
    WORD wDayOfWeek; 		// @field Specifies the current day of the week; Sunday = 0, Monday = 1, and so on.
    WORD wDay; 				// @field Specifies the current day of the month. 
    WORD wHour; 			// @field Specifies the current hour.
    WORD wMinute; 			// @field Specifies the current minute.
    WORD wSecond; 			// @field Specifies the current second.
    WORD wMilliseconds; 	// @field Specifies the current millisecond.
    WORD wMicroseconds; 	// @field Specifies the current microsecond.
    WORD wNanoseconds; 		// @field Specifies the current nanosecond.
} SYSTEMTIME_EX; 


// @struct TT_ANTENNA | Satellite Antenna status.
typedef struct _TT_ANTENNA {
	BOOL	bShort;					// @field Flag to indicate if Antenna Shorted
	BOOL	bOpen;					// @field Flag to indicate if Antenna Open
} TT_ANTENNA;

// @enum TT_EXTERNAL_EVENT_TRIGGER_EDGE | Values specifying the external event trigger polarity.
typedef enum {
	TT_FALLING = 0x00,	// @emem Specifies external event falling trigger.
	TT_RISING,			// @emem Specifies external event rising trigger.
}TT_EXTERNAL_EVENT_TRIGGER_EDGE;

// @enum TT_EXTERNAL_EVENT_TRIGGER_SOURCE | Values specifying the external event trigger source.
typedef enum {
	TT_EXTERNAL_EVENT_TRIGGER = 0x00,			// @emem Specifies to trigger the external event with the external trigger.
	TT_SYNTHESIZER_TRIGGER,						// @emem Specifies to trigger the external event with the synthesizer.
	TT_RATE_GENERATOR_TRIGGER,					// @emem Specifies to trigger the external event with the rate generator.
	TT_TIME_COMPARE_TRIGGER,					// @emem Specifies to trigger the external event with the time compare.
}TT_EXTERNAL_EVENT_TRIGGER_SOURCE;

// @enum TT_SYNTHESIZER_ON_TIME_EDGE | Values specifying the synthesizer ontime edge polarity.
typedef enum {
	TT_SYNTHESIZER_FALLING = 0x00,	// @emem Specifies the synthesizer to be ontime on the falling edge.
	TT_SYNTHESIZER_RISING,			// @emem Specifies the synthesizer to be ontime on the rising edge.
}TT_SYNTHESIZER_ON_TIME_EDGE;

// @enum TT_OUTPUT_BNC_SOURCE | Values specifying the source to appear on the output BNC.
typedef enum {
	TT_OUTPUT_IRIG_AM_TIMECODE = 0x00,		// @emem Specifies to send the AM timecode to the output BNC.
	TT_OUTPUT_IRIG_DC_TIMECODE,				// @emem Specifies to send the DC timecode to the output BNC.
	TT_OUTPUT_RATE_GENERATOR,				// @emem Specifies to send the Rate Generator to the output BNC.
	TT_OUTPUT_SYNTHESIZER,					// @emem Specifies to send the synthesizer to the output BNC.
	TT_OUTPUT_TIME_COMPARE,					// @emem Specifies to send the Time compare pulse to the output BNC.
	TT_OUTPUT_1PPS,							// @emem Specifies to send the 1 pps to the output BNC.
}TT_OUTPUT_BNC_SOURCE;

// @struct TT_HARDWARE_STATUS | Hardware status.
typedef struct _TT_HARDWARE_STATUS {
	BOOL	AntennaPositionReady;			// @field Flag to indicate position data is valid
	BOOL	SoftwareTimeRequestReady;		// @field Flag to indicate freeze time data is valid
	BOOL	AntennaShorted;					// @field Flag to indicate the GPS antenna is shorted
	BOOL	AntennaOpen;					// @field Flag to indicate the GPS antenna is open
	BOOL	SynthesizerPulseOccured;		// @field Flag to indicate a pulse occured on the synthesizer
	BOOL	RateGeneratorPulseOccured;		// @field Flag to indicate a pulse occured on the rate generator
	BOOL	TimeComparePulseOccured;		// @field Flag to indicate a pulse occured on the time compare
	BOOL	ExternalEventPulseOccured;		// @field Flag to indicate a pulse occured on the external event
} TT_HARDWARE_STATUS;

// @enum TT_CONFIGURATION_SETTINGS | Values specifying the configuration functions.
typedef enum {
	TT_USE_TIME_QUALITY = 0x0,		// @emem Specifies to use the time quality flags to determine signal validity.
	TT_SAVE_DAC,					// @emem Specifies to save the DAC setings in eeprom.
	TT_SAVE_CURRENT_CONFIGURATION,	// @emem Specifies to save the boards settings in eeprom.
	TT_RESTORE_SAVED_SETTINGS,		// @emem Specifies to restore the board settings saved in eeprom.
	TT_RESTORE_FACTORY_DEFAULTS,	// @emem Specifies to set the board to its factory defaults.
}TT_CONFIGURATION_SETTINGS;

#endif

