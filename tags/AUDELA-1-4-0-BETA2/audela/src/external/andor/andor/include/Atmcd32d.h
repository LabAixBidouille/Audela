// protypes for the  bit functions on the -bit side of the thunk
#if !defined(__atmcd32d_h)     // Sentry, use file only if it's not already included.
#define __atmcd32d_h
#pragma hdrstop

#include <windows.h>
#ifdef __cplusplus
extern "C" {
#endif


#ifdef EXPNETFUNCS
#define EXPNETTYPE __declspec(dllexport)
#else
#define EXPNETTYPE __declspec(dllimport)
#endif

typedef struct ANDORCAPS
{
	ULONG ulSize;

	ULONG ulAcqModes;
	ULONG ulReadModes;
	ULONG ulTriggerModes;
	ULONG ulCameraType;
  ULONG ulPixelMode;
  ULONG ulSetFunctions;
  ULONG ulGetFunctions;
  ULONG ulFeatures;
} AndorCapabilities;


EXPNETTYPE unsigned int  WINAPI SetExposureTime(float time);
EXPNETTYPE unsigned int  WINAPI SetNumberAccumulations(int number);
EXPNETTYPE unsigned int  WINAPI SetAccumulationCycleTime(float time);
EXPNETTYPE unsigned int  WINAPI SetNumberKinetics(int number);
EXPNETTYPE unsigned int  WINAPI SetKineticCycleTime(float time);
EXPNETTYPE unsigned int  WINAPI SetAcquisitionMode(int mode);
EXPNETTYPE unsigned int  WINAPI SetHorizontalSpeed(int index);
EXPNETTYPE unsigned int  WINAPI SetVerticalSpeed(int index);
EXPNETTYPE unsigned int  WINAPI SetReadMode(int mode);
EXPNETTYPE unsigned int  WINAPI SetPhotonCounting(int state);
EXPNETTYPE unsigned int  WINAPI SetPhotonCountingThreshold(long min, long max);
EXPNETTYPE unsigned int  WINAPI SetMultiTrack(int number, int height, int offset,int* bottom,int* gap);
EXPNETTYPE unsigned int  WINAPI SetSingleTrack(int centre, int height);
EXPNETTYPE unsigned int  WINAPI SetFullImage(int hbin, int vbin);
EXPNETTYPE unsigned int  WINAPI GetAcquisitionTimings(float* exposure, float* accumulate, float* kinetic);
EXPNETTYPE unsigned int  WINAPI PrepareAcquisition();
EXPNETTYPE unsigned int  WINAPI FreeInternalMemory();
EXPNETTYPE unsigned int  WINAPI StartAcquisition(void);
EXPNETTYPE unsigned int  WINAPI AbortAcquisition(void);
EXPNETTYPE unsigned int  WINAPI GetAcquiredData(long * array, unsigned long size);
EXPNETTYPE unsigned int  WINAPI GetStatus(int* status);
EXPNETTYPE unsigned int  WINAPI SetTriggerMode(int mode);
EXPNETTYPE unsigned int  WINAPI Initialize(char * dir);	 //	read ini file to get head and card
EXPNETTYPE unsigned int  WINAPI ShutDown(void);
EXPNETTYPE unsigned int  WINAPI SetTemperature(int temperature);
EXPNETTYPE unsigned int  WINAPI GetTemperature(int* temperature);
EXPNETTYPE unsigned int  WINAPI GetTemperatureF(float* temperature);
EXPNETTYPE unsigned int  WINAPI GetTemperatureRange(int* mintemp,int* maxtemp);
EXPNETTYPE unsigned int  WINAPI CoolerON(void);
EXPNETTYPE unsigned int  WINAPI CoolerOFF(void);
EXPNETTYPE unsigned int  WINAPI SetShutter(int type, int mode, int closingtime, int openingtime);
EXPNETTYPE unsigned int  WINAPI OutAuxPort(int port, int state);
EXPNETTYPE unsigned int  WINAPI InAuxPort(int port, int* state);
EXPNETTYPE unsigned int  WINAPI GetNumberHorizontalSpeeds(int* number);
EXPNETTYPE unsigned int  WINAPI GetHorizontalSpeed(int index, int* speed);
EXPNETTYPE unsigned int  WINAPI GetNumberVerticalSpeeds(int* number);
EXPNETTYPE unsigned int  WINAPI GetVerticalSpeed(int index, int* speed);
EXPNETTYPE unsigned int  WINAPI GetDetector(int* xpixels, int* ypixels);
EXPNETTYPE unsigned int  WINAPI GetSoftwareVersion(unsigned int* eprom, unsigned int* coffile, unsigned int* vxdrev, unsigned int* vxdver, unsigned int* dllrev, unsigned int* dllver);
EXPNETTYPE unsigned int  WINAPI GetHardwareVersion(unsigned int* PCB, unsigned int* Decode, unsigned int* SerPar, unsigned int* Clocks, unsigned int* dummy1, unsigned int* dummy2);
EXPNETTYPE unsigned int WINAPI SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend);
EXPNETTYPE unsigned int WINAPI SetFastKinetics(int exposedRows, int seriesLength, float time, int mode, int hbin, int vbin);
EXPNETTYPE unsigned int WINAPI SetFastKineticsEx(int exposedRows, int seriesLength, float time, int mode, int hbin, int vbin, int offset);
EXPNETTYPE unsigned int WINAPI GetFKExposureTime(float* time);
EXPNETTYPE unsigned int WINAPI GetNumberFKVShiftSpeeds(int* number);
EXPNETTYPE unsigned int WINAPI SetFKVShiftSpeed(int index);
EXPNETTYPE unsigned int WINAPI GetFKVShiftSpeed(int index, int* speed);
EXPNETTYPE unsigned int WINAPI GetFKVShiftSpeedF(int index, float* speed);
EXPNETTYPE unsigned int WINAPI SetComplexImage(int numAreas, int* areas);
EXPNETTYPE unsigned int WINAPI SetRandomTracks(int numTracks, int* areas);
EXPNETTYPE unsigned int WINAPI SetDriverEvent(HANDLE event);
EXPNETTYPE unsigned int WINAPI I2CBurstWrite(BYTE i2cAddress, long nBytes, BYTE* data);
EXPNETTYPE unsigned int WINAPI I2CBurstRead(BYTE i2cAddress, long nBytes, BYTE* data);
EXPNETTYPE unsigned int WINAPI I2CReset(void);
EXPNETTYPE unsigned int WINAPI I2CRead(BYTE deviceID, BYTE intAddress, BYTE* pdata);
EXPNETTYPE unsigned int WINAPI I2CWrite(BYTE deviceID, BYTE intAddress, BYTE data);
EXPNETTYPE unsigned int WINAPI SetGain(int gain);
EXPNETTYPE unsigned int WINAPI SetMCPGating(int gating);
EXPNETTYPE unsigned int WINAPI SetGateMode(int gatemode);
#if defined(__SHAMROCK__) || defined(__NICOLET__)
EXPNETTYPE unsigned int WINAPI ReadSpectConfig(char * path);
EXPNETTYPE unsigned int WINAPI SetGrating(int grating);
EXPNETTYPE unsigned int WINAPI GetWavelengthLimits(int grating, float* minWavelength, float* maxWavelength);
EXPNETTYPE unsigned int WINAPI SetWavelength(float wavelength);
EXPNETTYPE unsigned int WINAPI SetAperture(int aperture);
EXPNETTYPE unsigned int WINAPI SetCalLamp(int state);
EXPNETTYPE unsigned int WINAPI ReadShutter(int* state);
EXPNETTYPE unsigned int WINAPI ResetGrating(void);
EXPNETTYPE unsigned int WINAPI ResetWavelength(void);
EXPNETTYPE unsigned int WINAPI Park(void);
EXPNETTYPE unsigned int WINAPI ResetAperture(void);
EXPNETTYPE unsigned int WINAPI I2CStepperMove(BYTE i2cAddress, long delay, long nBytesPattern, BYTE* data, long nSteps);
EXPNETTYPE unsigned int WINAPI I2CRampStepperMove(BYTE i2cAddress,long TotalPulses, long minDummies, long startDummies, long deltaDummies, BYTE* data);
EXPNETTYPE unsigned int WINAPI GetAperture(int* aperture);
EXPNETTYPE unsigned int WINAPI GetApertureLabel(int ap, char* label, int size);
EXPNETTYPE unsigned int WINAPI GetGrating(int* grating);
EXPNETTYPE unsigned int WINAPI GetGratingInfo(int grating, float* lines, float* blaze);
EXPNETTYPE unsigned int WINAPI GetOpticalParams(float* focallen, float* angdev, float* focaltlt);
EXPNETTYPE unsigned int WINAPI GetWavelength(float* wavelength);
#endif
EXPNETTYPE unsigned int WINAPI SetFilterMode(int mode);
EXPNETTYPE unsigned int WINAPI GetFilterMode(int* mode);
EXPNETTYPE unsigned int WINAPI SetFilterParameters(int width, float sensitivity, int range, float accept, int smooth, int noise);
EXPNETTYPE unsigned int WINAPI GPIBSend(int id, short address, char* text);
EXPNETTYPE unsigned int WINAPI GPIBReceive(int id, short address, char* text, int size);
EXPNETTYPE unsigned int WINAPI SaveAsSif(char* path);
EXPNETTYPE unsigned int WINAPI SaveAsTiff(char* path, char* palette, int position, int type);
EXPNETTYPE unsigned int WINAPI SaveAsCommentedSif(char* path, char* comment);
EXPNETTYPE unsigned int WINAPI SetSifComment(char* comment);
EXPNETTYPE unsigned int WINAPI SetCurrentSystem(int system);
EXPNETTYPE unsigned int WINAPI SetDelayGenerator(int board, short address, int type);
EXPNETTYPE unsigned int WINAPI SetGate(float delay, float width, float step);
EXPNETTYPE unsigned int WINAPI SetSingleTrackHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetMultiTrackHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetFVBHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetCustomTrackHBin(int bin);
EXPNETTYPE unsigned int WINAPI GetNewData(long* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetDDGIOCPulses(int* pulses);
EXPNETTYPE unsigned int WINAPI GetDDGPulse(double width, double resolution, double* Delay, double *Width);
EXPNETTYPE unsigned int WINAPI SetDDGAddress(BYTE t0, BYTE t1, BYTE t2, BYTE tt, BYTE address);
EXPNETTYPE unsigned int WINAPI SetDDGGain(int gain);
EXPNETTYPE unsigned int WINAPI SetDDGGateStep(double step);
EXPNETTYPE unsigned int WINAPI SetDDGInsertionDelay(int state);
EXPNETTYPE unsigned int WINAPI SetDDGIntelligate(int state);
EXPNETTYPE unsigned int WINAPI SetDDGIOC(int state);
EXPNETTYPE unsigned int WINAPI SetDDGIOCFrequency(double frequency);
EXPNETTYPE unsigned int WINAPI SetDDGTimes(double t0, double t1, double t2);
EXPNETTYPE unsigned int WINAPI SetDDGTriggerMode(int mode);
EXPNETTYPE unsigned int WINAPI SetDDGVariableGateStep(int mode, double p1, double p2);
EXPNETTYPE unsigned int WINAPI SetEMCCDGain(int gain);
EXPNETTYPE unsigned int WINAPI SaveAsBmp(char* path, char* palette, long ymin, long ymax);
EXPNETTYPE unsigned int WINAPI SetSpool(int active, int method, char* path, int framebuffersize);
EXPNETTYPE unsigned int WINAPI SetFastExtTrigger(int mode);
EXPNETTYPE unsigned int WINAPI GetAcquisitionProgress(long* acc, long* series);
EXPNETTYPE unsigned int WINAPI Merge(const long* array, long nOrder, long nPoint, long nPixel, float* coeff, long fit, long hbin,
                          long* output, float* start, float* step);

EXPNETTYPE unsigned int WINAPI GetNumberADChannels(int* channels);
EXPNETTYPE unsigned int WINAPI SetADChannel(int channel);
EXPNETTYPE unsigned int WINAPI GetNumberHSSpeeds(int channel, int type, int* speeds);
EXPNETTYPE unsigned int WINAPI GetHSSpeed(int channel, int type, int index, float* speed);
EXPNETTYPE unsigned int WINAPI SetHSSpeed(int type, int index);
EXPNETTYPE unsigned int WINAPI GetNumberVSSpeeds(int* speeds);
EXPNETTYPE unsigned int WINAPI GetVSSpeed(int index, float* speed);
EXPNETTYPE unsigned int WINAPI SetVSSpeed(int index);
EXPNETTYPE unsigned int WINAPI SetVSAmplitude(int index);
EXPNETTYPE unsigned int WINAPI SetFanMode(int mode);
EXPNETTYPE unsigned int WINAPI GetNumberAmp(int* amp);
EXPNETTYPE unsigned int WINAPI GetAmpMaxSpeed(int index, float* speed);
EXPNETTYPE unsigned int WINAPI GetAmpDesc(int index, char* name, int len);
EXPNETTYPE unsigned int WINAPI SetVerticalRowBuffer(int rows);
EXPNETTYPE unsigned int WINAPI GetRegisterDump(int* mode);
EXPNETTYPE unsigned int WINAPI SetRegisterDump(int mode);
EXPNETTYPE unsigned int WINAPI SetBaselineClamp(int state);
EXPNETTYPE unsigned int WINAPI SetOutputAmplifier(int type);
EXPNETTYPE unsigned int WINAPI GetNumberPreAmpGains(int* noGains);
EXPNETTYPE unsigned int WINAPI GetPreAmpGain(int index, float* gain);
EXPNETTYPE unsigned int WINAPI SetPreAmpGain(int index);
EXPNETTYPE unsigned int WINAPI GetCameraSerialNumber(int* number);
EXPNETTYPE unsigned int WINAPI GetPixelSize(float* xSize, float* ySize);
EXPNETTYPE unsigned int WINAPI GetHeadModel(char* name);
EXPNETTYPE unsigned int WINAPI GetNewData16(WORD* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetAcquiredData16(WORD* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetNewData8(unsigned char* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetCapabilities(AndorCapabilities* caps);
EXPNETTYPE unsigned int WINAPI SetMessageWindow(HWND wnd);
EXPNETTYPE unsigned int WINAPI SelectDevice(int devNum);
EXPNETTYPE unsigned int WINAPI GetNumberDevices(int* numDevs);
EXPNETTYPE unsigned int WINAPI GetID(int devNum, int* id);
EXPNETTYPE unsigned int WINAPI SetPixelMode(int bitdepth, int colormode);
EXPNETTYPE unsigned int WINAPI IdAndorDll();

EXPNETTYPE unsigned int WINAPI SetAcquisitionType(int type);
EXPNETTYPE unsigned int WINAPI SetDataType(int type);
EXPNETTYPE unsigned int WINAPI SetBackground(long* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetBackground(long* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetAcquiredFloatData(float* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetNewFloatData(float* array, unsigned long size);


#define DRV_ERROR_CODES	20001
#define DRV_SUCCESS	20002
#define DRV_VXDNOTINSTALLED	20003
#define DRV_ERROR_SCAN	20004
#define DRV_ERROR_CHECK_SUM	20005
#define DRV_ERROR_FILELOAD	20006
#define DRV_UNKNOWN_FUNCTION	20007
#define DRV_ERROR_VXD_INIT	20008
#define DRV_ERROR_ADDRESS	20009
#define DRV_ERROR_PAGELOCK	20010
#define DRV_ERROR_PAGEUNLOCK	20011
#define DRV_ERROR_BOARDTEST	20012
#define DRV_ERROR_ACK	20013
#define DRV_ERROR_UP_FIFO	20014
#define DRV_ERROR_PATTERN	20015

#define DRV_ACQUISITION_ERRORS	20017
#define DRV_ACQ_BUFFER	20018
#define DRV_ACQ_DOWNFIFO_FULL	20019
#define DRV_PROC_UNKONWN_INSTRUCTION	20020
#define DRV_ILLEGAL_OP_CODE	20021
#define DRV_KINETIC_TIME_NOT_MET	20022
#define DRV_ACCUM_TIME_NOT_MET	20023
#define DRV_NO_NEW_DATA	20024
#define DRV_SPOOLERROR 20026

#define DRV_TEMPERATURE_CODES	20033
#define DRV_TEMPERATURE_OFF	20034
#define DRV_TEMPERATURE_NOT_STABILIZED	20035
#define DRV_TEMPERATURE_STABILIZED	20036
#define DRV_TEMPERATURE_NOT_REACHED	20037
#define DRV_TEMPERATURE_OUT_RANGE	20038
#define DRV_TEMPERATURE_NOT_SUPPORTED	20039
#define DRV_TEMPERATURE_DRIFT	20040


#define DRV_TEMP_CODES	20033
#define DRV_TEMP_OFF	20034
#define DRV_TEMP_NOT_STABILIZED	20035
#define DRV_TEMP_STABILIZED	20036
#define DRV_TEMP_NOT_REACHED	20037
#define DRV_TEMP_OUT_RANGE	20038
#define DRV_TEMP_NOT_SUPPORTED	20039
#define DRV_TEMP_DRIFT	20040


#define DRV_GENERAL_ERRORS	20049
#define DRV_INVALID_AUX	20050
#define DRV_COF_NOTLOADED	20051
#define DRV_FPGAPROG 20052
#define DRV_FLEXERROR 20053
#define DRV_GPIBERROR 20054

#define DRV_DATATYPE	20064
#define DRV_DRIVER_ERRORS	20065
#define DRV_P1INVALID	20066
#define DRV_P2INVALID	20067
#define DRV_P3INVALID	20068
#define DRV_P4INVALID	20069
#define DRV_INIERROR	20070
#define DRV_COFERROR	20071
#define DRV_ACQUIRING	20072
#define DRV_IDLE	20073
#define DRV_TEMPCYCLE	20074
#define DRV_NOT_INITIALIZED 20075
#define DRV_P5INVALID	20076
#define DRV_P6INVALID	20077
#define DRV_INVALID_MODE	20078
#define DRV_INVALID_FILTER 20079

#define DRV_I2CERRORS	20080
#define DRV_I2CDEVNOTFOUND	20081
#define DRV_I2CTIMEOUT	20082
#define DRV_P7INVALID	20083

#define DRV_IOCERROR 20090
#define DRV_VRMVERSIONERROR 20091

#define DRV_ERROR_NOCAMERA 20990
#define DRV_NOT_SUPPORTED 20991

#define AC_ACQMODE_SINGLE 1
#define AC_ACQMODE_VIDEO 2
#define AC_ACQMODE_ACCUMULATE 4
#define AC_ACQMODE_KINETIC 8
#define AC_ACQMODE_FRAMETRANSFER 16
#define AC_ACQMODE_FASTKINETICS 32

#define AC_READMODE_FULLIMAGE 1
#define AC_READMODE_SUBIMAGE 2
#define AC_READMODE_SINGLETRACK 4
#define AC_READMODE_FVB 8
#define AC_READMODE_MULTITRACK 16
#define AC_READMODE_RANDOMTRACK 32

#define AC_TRIGGERMODE_INTERNAL 1
#define AC_TRIGGERMODE_EXTERNAL 2

#define AC_CAMERATYPE_PDA 0
#define AC_CAMERATYPE_IXON 1
#define AC_CAMERATYPE_ICCD 2
#define AC_CAMERATYPE_EMCCD 3
#define AC_CAMERATYPE_CCD 4
#define AC_CAMERATYPE_ISTAR 5
#define AC_CAMERATYPE_VIDEO 6

#define AC_PIXELMODE_8BIT  1
#define AC_PIXELMODE_14BIT 2
#define AC_PIXELMODE_16BIT 4
#define AC_PIXELMODE_32BIT 8

#define AC_PIXELMODE_MONO 0
#define AC_PIXELMODE_RGB (1 << 16)
#define AC_PIXELMODE_CMY (2 << 16)

#define AC_SETFUNCTION_VREADOUT 1
#define AC_SETFUNCTION_HREADOUT 2
#define AC_SETFUNCTION_TEMPERATURE 4
#define AC_SETFUNCTION_GAIN 8
#define AC_SETFUNCTION_EMCCDGAIN 16

#define AC_GETFUNCTION_TEMPERATURE 1
#define AC_GETFUNCTION_TARGETTEMPERATURE 2
#define AC_GETFUNCTION_TEMPERATURERANGE 4
#define AC_GETFUNCTION_DETECTORSIZE 8
#define AC_GETFUNCTION_GAIN 16
#define AC_GETFUNCTION_EMCCDGAIN 32

#define AC_FEATURES_POLLING 1
#define AC_FEATURES_EVENTS 2
#define AC_FEATURES_SPOOLING 4
#define AC_FEATURES_SHUTTER 8


#ifdef __cplusplus
}
#endif

#endif



