#if !defined(__atmcd32d_h)
#define __atmcd32d_h
#pragma hdrstop

#include "windows.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef EXPNETFUNCS
#define EXPNETTYPE __declspec(dllexport)
#else
#define EXPNETTYPE __declspec(dllimport)
#endif

#define at_32 long
#define at_u32 unsigned long 

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
  ULONG ulPCICard;
  ULONG ulEMGainCapability;
} AndorCapabilities;

typedef struct COLORDEMOSAICINFO
{
  int iX; // Number of X pixels. Must be >2.
  int iY; // Number of Y pixels. Must be >2.
  int iAlgorithm;  // Algorithm to demosaic image.
  int iXPhase;   // First pixel in data (Cyan or Yellow/Magenta or Green). For Luca/SurCam = 1.
  int iYPhase;   // First pixel in data (Cyan or Yellow/Magenta or Green). For Luca/SurCam = 0.
  int iBackground;  // Background to remove from raw data when demosaicing. Internal Fixed Baseline Clamp for Luca/SurCam is 512
} ColorDemosaicInfo;

typedef struct WHITEBALANCEINFO
{
  int iSize;  // Structure size
  int iX; // Number of X pixels. Must be >2.
  int iY; // Number of Y pixels. Must be >2.
  int iAlgorithm;  // Algorithm to calculate white balance.
  int iROI_left;   // Region Of Interest from which the White Balance is calculated
  int iROI_right;  // Region Of Interest from which the White Balance is calculated
  int iROI_top;    // Region Of Interest from which the White Balance is calculated
  int iROI_bottom; // Region Of Interest from which the White Balance is calculated
  int iOperation; // 0: do NOT calculate white balance, apply given relative factors to colour fields
                  // 1: calculate white balance, do NOT apply calculated relative factors to colour fields
                  // 2: calculate white balance, apply calculated relative factors to colour fields
} WhiteBalanceInfo;

EXPNETTYPE unsigned int WINAPI AbortAcquisition(void);
EXPNETTYPE unsigned int WINAPI CancelWait(void);
EXPNETTYPE unsigned int WINAPI CoolerOFF(void);
EXPNETTYPE unsigned int WINAPI CoolerON(void);
EXPNETTYPE unsigned int WINAPI DemosaicImage(WORD* _input, WORD* _red, WORD* _green, WORD* _blue, ColorDemosaicInfo* _info);
EXPNETTYPE unsigned int WINAPI FreeInternalMemory(void);
EXPNETTYPE unsigned int WINAPI GetAcquiredData(at_32 * array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetAcquiredData16(WORD* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetAcquiredFloatData(float* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetAcquisitionProgress(long* acc, long* series);
EXPNETTYPE unsigned int WINAPI GetAcquisitionTimings(float* exposure, float* accumulate, float* kinetic);
EXPNETTYPE unsigned int WINAPI GetAdjustedRingExposureTimes(int _inumTimes, float *_fptimes);
EXPNETTYPE unsigned int WINAPI GetAllDMAData(at_32* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetAmpDesc(int index, char* name, int len);
EXPNETTYPE unsigned int WINAPI GetAmpMaxSpeed(int index, float* speed);
EXPNETTYPE unsigned int WINAPI GetAvailableCameras(long* totalCameras);
EXPNETTYPE unsigned int WINAPI GetBackground(at_32* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetBitDepth(int channel, int* depth);
EXPNETTYPE unsigned int WINAPI GetCameraEventStatus(DWORD *cam_status);
EXPNETTYPE unsigned int WINAPI GetCameraHandle(long cameraIndex, long* cameraHandle);
EXPNETTYPE unsigned int WINAPI GetCameraInformation(int index, long *information);
EXPNETTYPE unsigned int WINAPI GetCameraSerialNumber(int* number);
EXPNETTYPE unsigned int WINAPI GetCapabilities(AndorCapabilities* caps);
EXPNETTYPE unsigned int WINAPI GetControllerCardModel(char* controllerCardModel);
EXPNETTYPE unsigned int WINAPI GetCurrentCamera(long* cameraHandle);
EXPNETTYPE unsigned int WINAPI GetCYMGShift(int * _iXshift, int * _iYshift);
EXPNETTYPE unsigned int WINAPI GetDDGIOCFrequency(double* frequency);
EXPNETTYPE unsigned int WINAPI GetDDGIOCNumber(unsigned long* number_pulses);
EXPNETTYPE unsigned int WINAPI GetDDGIOCPulses(int* pulses);
EXPNETTYPE unsigned int WINAPI GetDDGPulse(double width, double resolution, double* Delay, double *Width);
EXPNETTYPE unsigned int WINAPI GetDetector(int* xpixels, int* ypixels);
EXPNETTYPE unsigned int WINAPI GetDICameraInfo(void *info);
EXPNETTYPE unsigned int WINAPI GetEMCCDGain(int* gain);
EXPNETTYPE unsigned int WINAPI GetEMGainRange(int* low, int* high);
EXPNETTYPE unsigned int WINAPI GetFastestRecommendedVSSpeed(int *index, float* speed);
EXPNETTYPE unsigned int WINAPI GetFIFOUsage(int* FIFOusage);
EXPNETTYPE unsigned int WINAPI GetFilterMode(int* mode);
EXPNETTYPE unsigned int WINAPI GetFKExposureTime(float* time);
EXPNETTYPE unsigned int WINAPI GetFKVShiftSpeed(int index, int* speed);
EXPNETTYPE unsigned int WINAPI GetFKVShiftSpeedF(int index, float* speed);
EXPNETTYPE unsigned int WINAPI GetHardwareVersion(unsigned int* PCB, unsigned int* Decode, unsigned int* SerPar, unsigned int* Clocks, unsigned int* dummy1, unsigned int* dummy2);
EXPNETTYPE unsigned int WINAPI GetHeadModel(char* name);
EXPNETTYPE unsigned int WINAPI GetHorizontalSpeed(int index, int* speed);
EXPNETTYPE unsigned int WINAPI GetHSSpeed(int channel, int type, int index, float* speed);
EXPNETTYPE unsigned int WINAPI GetHVflag(int *bFlag);
EXPNETTYPE unsigned int WINAPI GetID(int devNum, int* id);
EXPNETTYPE unsigned int WINAPI GetImages (long first, long last, at_32* array, unsigned long size, long* validfirst, long* validlast);
EXPNETTYPE unsigned int WINAPI GetImages16 (long first, long last, WORD* array, unsigned long size, long* validfirst, long* validlast);
EXPNETTYPE unsigned int WINAPI GetImagesPerDMA(unsigned long* images);
EXPNETTYPE unsigned int WINAPI GetIRQ(int* IRQ);
EXPNETTYPE unsigned int WINAPI GetMaximumBinning(int ReadMode, int HorzVert, int* MaxBinning);
EXPNETTYPE unsigned int WINAPI GetMaximumExposure(float* MaxExp);
EXPNETTYPE unsigned int WINAPI GetMCPGain(int iNum, int *iGain, float *fPhotoepc);
EXPNETTYPE unsigned int WINAPI GetMCPVoltage(int *iVoltage);
EXPNETTYPE unsigned int WINAPI GetMinimumImageLength(int* MinImageLength);
EXPNETTYPE unsigned int WINAPI GetMostRecentColorImage16 (unsigned long size, int algorithm, WORD* red, WORD* green, WORD* blue);
EXPNETTYPE unsigned int WINAPI GetMostRecentImage (at_32* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetMostRecentImage16 (WORD* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetMSTimingsData(SYSTEMTIME *TimeOfStart,float *_pfDifferences, int _inoOfimages);
EXPNETTYPE unsigned int WINAPI GetMSTimingsEnabled(void);
EXPNETTYPE unsigned int WINAPI GetNewData(at_32* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetNewData16(WORD* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetNewData8(unsigned char* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetNewFloatData(float* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetNumberADChannels(int* channels);
EXPNETTYPE unsigned int WINAPI GetNumberAmp(int* amp);
EXPNETTYPE unsigned int WINAPI GetNumberAvailableImages (at_32* first, at_32* last);
EXPNETTYPE unsigned int WINAPI GetNumberDevices(int* numDevs);
EXPNETTYPE unsigned int WINAPI GetNumberFKVShiftSpeeds(int* number);
EXPNETTYPE unsigned int WINAPI GetNumberHorizontalSpeeds(int* number);
EXPNETTYPE unsigned int WINAPI GetNumberHSSpeeds(int channel, int type, int* speeds);
EXPNETTYPE unsigned int WINAPI GetNumberNewImages (long* first, long* last);
EXPNETTYPE unsigned int WINAPI GetNumberPreAmpGains(int* noGains);
EXPNETTYPE unsigned int WINAPI GetNumberRingExposureTimes(int *_ipnumTimes);
EXPNETTYPE unsigned int WINAPI GetNumberVerticalSpeeds(int* number);
EXPNETTYPE unsigned int WINAPI GetNumberVSAmplitudes(int* number);
EXPNETTYPE unsigned int WINAPI GetNumberVSSpeeds(int* speeds);
EXPNETTYPE unsigned int WINAPI GetOldestImage (at_32* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetOldestImage16 (WORD* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI GetPhysicalDMAAddress(unsigned long* Address1, unsigned long* Address2);
EXPNETTYPE unsigned int WINAPI GetPixelSize(float* xSize, float* ySize);
EXPNETTYPE unsigned int WINAPI GetPreAmpGain(int index, float* gain);
EXPNETTYPE unsigned int WINAPI GetRegisterDump(int* mode);
EXPNETTYPE unsigned int WINAPI GetRingExposureRange(float *_fpMin, float *_fpMax);
EXPNETTYPE unsigned int WINAPI GetSizeOfCircularBuffer (long* index);
EXPNETTYPE unsigned int WINAPI GetSlotBusDeviceFunction(DWORD *dwSlot, DWORD *dwBus, DWORD *dwDevice, DWORD *dwFunction);
EXPNETTYPE unsigned int WINAPI GetSoftwareVersion(unsigned int* eprom, unsigned int* coffile, unsigned int* vxdrev, unsigned int* vxdver, unsigned int* dllrev, unsigned int* dllver);
EXPNETTYPE unsigned int WINAPI GetSpoolProgress(long* index);
EXPNETTYPE unsigned int WINAPI GetStatus(int* status);
EXPNETTYPE unsigned int WINAPI GetTemperature(int* temperature);
EXPNETTYPE unsigned int WINAPI GetTemperatureF(float* temperature);
EXPNETTYPE unsigned int WINAPI GetTemperatureRange(int* mintemp,int* maxtemp);
EXPNETTYPE unsigned int WINAPI GetTemperatureStatus(float *SensorTemp, float *TargetTemp, float *AmbientTemp, float *CoolerVolts);
EXPNETTYPE unsigned int WINAPI GetTotalNumberImagesAcquired (long* index);
EXPNETTYPE unsigned int WINAPI GetVerticalSpeed(int index, int* speed);
EXPNETTYPE unsigned int WINAPI GetVirtualDMAAddress(void** Address1, void** Address2);
EXPNETTYPE unsigned int WINAPI GetVSSpeed(int index, float* speed);
EXPNETTYPE unsigned int WINAPI GPIBReceive(int id, short address, char* text, int size);
EXPNETTYPE unsigned int WINAPI GPIBSend(int id, short address, char* text);
EXPNETTYPE unsigned int WINAPI I2CBurstRead(BYTE i2cAddress, long nBytes, BYTE* data);
EXPNETTYPE unsigned int WINAPI I2CBurstWrite(BYTE i2cAddress, long nBytes, BYTE* data);
EXPNETTYPE unsigned int WINAPI I2CRead(BYTE deviceID, BYTE intAddress, BYTE* pdata);
EXPNETTYPE unsigned int WINAPI I2CReset(void);
EXPNETTYPE unsigned int WINAPI I2CWrite(BYTE deviceID, BYTE intAddress, BYTE data);
EXPNETTYPE unsigned int WINAPI IdAndorDll(void);
EXPNETTYPE unsigned int WINAPI InAuxPort(int port, int* state);
EXPNETTYPE unsigned int WINAPI Initialize(char * dir); // read ini file to get head and card
EXPNETTYPE unsigned int WINAPI InitializeDevice(char * dir);
EXPNETTYPE unsigned int WINAPI IsInternalMechanicalShutter(int *InternalShutter);
EXPNETTYPE unsigned int WINAPI IsPreAmpGainAvailable(int channel, int amplifier, int index, int pa, int* status);
EXPNETTYPE unsigned int WINAPI IsTriggerModeAvailable(int _itriggerMode);
EXPNETTYPE unsigned int WINAPI Merge(const at_32* array, long nOrder, long nPoint, long nPixel, float* coeff, long fit, long hbin, at_32* output, float* start, float* step);
EXPNETTYPE unsigned int WINAPI OutAuxPort(int port, int state);
EXPNETTYPE unsigned int WINAPI PrepareAcquisition(void);
EXPNETTYPE unsigned int WINAPI SaveAsBmp(char* path, char* palette, long ymin, long ymax);
EXPNETTYPE unsigned int WINAPI SaveAsCommentedSif(char* path, char* comment);
EXPNETTYPE unsigned int WINAPI SaveAsEDF(char* _szPath, int _iMode);
EXPNETTYPE unsigned int WINAPI SaveAsFITS(char* szFileTitle, int type);
EXPNETTYPE unsigned int WINAPI SaveAsRaw(char* szFileTitle, int type);
EXPNETTYPE unsigned int WINAPI SaveAsSif(char* path);
EXPNETTYPE unsigned int WINAPI SaveAsSPC(char* path);
EXPNETTYPE unsigned int WINAPI SaveAsTiff(char* path, char* palette, int position, int type);
EXPNETTYPE unsigned int WINAPI SaveAsTiffEx(char* path, char* palette, int position, int type, int _mode);
EXPNETTYPE unsigned int WINAPI SaveEEPROMToFile(char *cFileName);
EXPNETTYPE unsigned int WINAPI SaveToClipBoard(char* palette);
EXPNETTYPE unsigned int WINAPI SelectDevice(int devNum);
EXPNETTYPE unsigned int WINAPI SendSoftwareTrigger(void);
EXPNETTYPE unsigned int WINAPI SetAccumulationCycleTime(float time);
EXPNETTYPE unsigned int WINAPI SetAcqStatusEvent(HANDLE event);
EXPNETTYPE unsigned int WINAPI SetAcquisitionMode(int mode);
EXPNETTYPE unsigned int WINAPI SetAcquisitionType(int type);
EXPNETTYPE unsigned int WINAPI SetADChannel(int channel);
EXPNETTYPE unsigned int WINAPI SetAdvancedTriggerModeState(int _istate);
EXPNETTYPE unsigned int WINAPI SetBackground(at_32* array, unsigned long size);
EXPNETTYPE unsigned int WINAPI SetBaselineClamp(int state);
EXPNETTYPE unsigned int WINAPI SetBaselineOffset(int offset);
EXPNETTYPE unsigned int WINAPI SetCameraStatusEnable(DWORD Enable);
EXPNETTYPE unsigned int WINAPI SetComplexImage(int numAreas, int* areas);
EXPNETTYPE unsigned int WINAPI SetCoolerMode(int mode);
EXPNETTYPE unsigned int WINAPI SetCropMode(int active, int cropheight, int reserved);
EXPNETTYPE unsigned int WINAPI SetCurrentCamera(long cameraHandle);
EXPNETTYPE unsigned int WINAPI SetCustomTrackHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetDataType(int type);
EXPNETTYPE unsigned int WINAPI SetDDGAddress(BYTE t0, BYTE t1, BYTE t2, BYTE tt, BYTE address);
EXPNETTYPE unsigned int WINAPI SetDDGGain(int gain);
EXPNETTYPE unsigned int WINAPI SetDDGGateStep(double step);
EXPNETTYPE unsigned int WINAPI SetDDGInsertionDelay(int state);
EXPNETTYPE unsigned int WINAPI SetDDGIntelligate(int state);
EXPNETTYPE unsigned int WINAPI SetDDGIOC(int state);
EXPNETTYPE unsigned int WINAPI SetDDGIOCFrequency(double frequency);
EXPNETTYPE unsigned int WINAPI SetDDGIOCNumber(unsigned long number_pulses);
EXPNETTYPE unsigned int WINAPI SetDDGTimes(double t0, double t1, double t2);
EXPNETTYPE unsigned int WINAPI SetDDGTriggerMode(int mode);
EXPNETTYPE unsigned int WINAPI SetDDGVariableGateStep(int mode, double p1, double p2);
EXPNETTYPE unsigned int WINAPI SetDelayGenerator(int board, short address, int type);
EXPNETTYPE unsigned int WINAPI SetDMAParameters(int MaxImagesPerDMA, float SecondsPerDMA);
EXPNETTYPE unsigned int WINAPI SetDriverEvent(HANDLE event);
EXPNETTYPE unsigned int WINAPI SetEMAdvanced(int state);
EXPNETTYPE unsigned int WINAPI SetEMCCDGain(int gain);
EXPNETTYPE unsigned int WINAPI SetEMClockCompensation(int EMClockCompensationFlag);
EXPNETTYPE unsigned int WINAPI SetEMGainMode(int mode);
EXPNETTYPE unsigned int WINAPI SetExposureTime(float time);
EXPNETTYPE unsigned int WINAPI SetFanMode(int mode);
EXPNETTYPE unsigned int WINAPI SetFastExtTrigger(int mode);
EXPNETTYPE unsigned int WINAPI SetFastKinetics(int exposedRows, int seriesLength, float time, int mode, int hbin, int vbin);
EXPNETTYPE unsigned int WINAPI SetFastKineticsEx(int exposedRows, int seriesLength, float time, int mode, int hbin, int vbin, int offset);
EXPNETTYPE unsigned int WINAPI SetFilterMode(int mode);
EXPNETTYPE unsigned int WINAPI SetFilterParameters(int width, float sensitivity, int range, float accept, int smooth, int noise);
EXPNETTYPE unsigned int WINAPI SetFKVShiftSpeed(int index);
EXPNETTYPE unsigned int WINAPI SetFPDP(int state);
EXPNETTYPE unsigned int WINAPI SetFrameTransferMode(int mode);
EXPNETTYPE unsigned int WINAPI SetFullImage(int hbin, int vbin);
EXPNETTYPE unsigned int WINAPI SetFVBHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetGain(int gain);
EXPNETTYPE unsigned int WINAPI SetGate(float delay, float width, float step);
EXPNETTYPE unsigned int WINAPI SetGateMode(int gatemode);
EXPNETTYPE unsigned int WINAPI SetHighCapacity(int state);
EXPNETTYPE unsigned int WINAPI SetHorizontalSpeed(int index);
EXPNETTYPE unsigned int WINAPI SetHSSpeed(int type, int index);
EXPNETTYPE unsigned int WINAPI SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend);
EXPNETTYPE unsigned int WINAPI SetImageFlip(int iHFlip, int iVFlip);
EXPNETTYPE unsigned int WINAPI SetImageRotate(int iRotate);
EXPNETTYPE unsigned int WINAPI SetIsolatedCropMode (int active, int cropheight, int cropwidth, int vbin, int hbin);
EXPNETTYPE unsigned int WINAPI SetKineticCycleTime(float time);
EXPNETTYPE unsigned int WINAPI SetMCPGating(int gating);
EXPNETTYPE unsigned int WINAPI SetMessageWindow(HWND wnd);
EXPNETTYPE unsigned int WINAPI SetMultiTrack(int number, int height, int offset,int* bottom,int* gap);
EXPNETTYPE unsigned int WINAPI SetMultiTrackHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetNextAddress(at_32* data, long lowAdd, long highAdd, long len, long physical);
EXPNETTYPE unsigned int WINAPI SetNextAddress16(at_32* data, long lowAdd, long highAdd, long len, long physical);
EXPNETTYPE unsigned int WINAPI SetNumberAccumulations(int number);
EXPNETTYPE unsigned int WINAPI SetNumberKinetics(int number);
EXPNETTYPE unsigned int WINAPI SetOutputAmplifier(int type);
EXPNETTYPE unsigned int WINAPI SetPCIMode(int mode,int value);
EXPNETTYPE unsigned int WINAPI SetPhotonCounting(int state);
EXPNETTYPE unsigned int WINAPI SetPhotonCountingThreshold(long min, long max);
EXPNETTYPE unsigned int WINAPI SetPixelMode(int bitdepth, int colormode);
EXPNETTYPE unsigned int WINAPI SetPreAmpGain(int index);
EXPNETTYPE unsigned int WINAPI SetRandomTracks(int numTracks, int* areas);
EXPNETTYPE unsigned int WINAPI SetReadMode(int mode);
EXPNETTYPE unsigned int WINAPI SetRegisterDump(int mode);
EXPNETTYPE unsigned int WINAPI SetRingExposureTimes(int numTimes, float *times);
EXPNETTYPE unsigned int WINAPI SetSaturationEvent(HANDLE event);
EXPNETTYPE unsigned int WINAPI SetShutter(int type, int mode, int closingtime, int openingtime);
EXPNETTYPE unsigned int WINAPI SetShutterEx(int type, int mode, int closingtime, int openingtime, int ext_mode);
EXPNETTYPE unsigned int WINAPI SetShutters(int type, int mode, int closingtime, int openingtime, int ext_type, int ext_mode, int dummy1, int dummy2);
EXPNETTYPE unsigned int WINAPI SetSifComment(char* comment);
EXPNETTYPE unsigned int WINAPI SetSingleTrack(int centre, int height);
EXPNETTYPE unsigned int WINAPI SetSingleTrackHBin(int bin);
EXPNETTYPE unsigned int WINAPI SetSpool(int active, int method, char* path, int framebuffersize);
EXPNETTYPE unsigned int WINAPI SetStorageMode(long mode);
EXPNETTYPE unsigned int WINAPI SetTemperature(int temperature);
EXPNETTYPE unsigned int WINAPI SetTriggerMode(int mode);
EXPNETTYPE unsigned int WINAPI SetUserEvent(HANDLE event);
EXPNETTYPE unsigned int WINAPI SetUSGenomics(long width, long height);
EXPNETTYPE unsigned int WINAPI SetVerticalRowBuffer(int rows);
EXPNETTYPE unsigned int WINAPI SetVerticalSpeed(int index);
EXPNETTYPE unsigned int WINAPI SetVirtualChip(int state);
EXPNETTYPE unsigned int WINAPI SetVSAmplitude(int index);
EXPNETTYPE unsigned int WINAPI SetVSSpeed(int index);
EXPNETTYPE unsigned int WINAPI ShutDown(void);
EXPNETTYPE unsigned int WINAPI StartAcquisition(void);
EXPNETTYPE unsigned int WINAPI UnMapPhysicalAddress(void);
EXPNETTYPE unsigned int WINAPI WaitForAcquisition(void);
EXPNETTYPE unsigned int WINAPI WaitForAcquisitionByHandle(long cameraHandle);
EXPNETTYPE unsigned int WINAPI WaitForAcquisitionByHandleTimeOut(long cameraHandle, int _iTimeOutMs);
EXPNETTYPE unsigned int WINAPI WaitForAcquisitionTimeOut(int _iTimeOutMs);
EXPNETTYPE unsigned int WINAPI WhiteBalance(WORD* _wRed, WORD* _wGreen, WORD* _wBlue, float *_fRelR, float *_fRelB, WhiteBalanceInfo *_info);

#define DRV_ERROR_CODES 20001
#define DRV_SUCCESS 20002
#define DRV_VXDNOTINSTALLED 20003
#define DRV_ERROR_SCAN 20004
#define DRV_ERROR_CHECK_SUM 20005
#define DRV_ERROR_FILELOAD 20006
#define DRV_UNKNOWN_FUNCTION 20007
#define DRV_ERROR_VXD_INIT 20008
#define DRV_ERROR_ADDRESS 20009
#define DRV_ERROR_PAGELOCK 20010
#define DRV_ERROR_PAGEUNLOCK 20011
#define DRV_ERROR_BOARDTEST 20012
#define DRV_ERROR_ACK 20013
#define DRV_ERROR_UP_FIFO 20014
#define DRV_ERROR_PATTERN 20015

#define DRV_ACQUISITION_ERRORS 20017
#define DRV_ACQ_BUFFER 20018
#define DRV_ACQ_DOWNFIFO_FULL 20019
#define DRV_PROC_UNKONWN_INSTRUCTION 20020
#define DRV_ILLEGAL_OP_CODE 20021
#define DRV_KINETIC_TIME_NOT_MET 20022
#define DRV_ACCUM_TIME_NOT_MET 20023
#define DRV_NO_NEW_DATA 20024
#define DRV_PCI_DMA_FAIL	20025
#define DRV_SPOOLERROR 20026
#define DRV_SPOOLSETUPERROR 20027
#define DRV_FILESIZELIMITERROR 20028
#define DRV_ERROR_FILESAVE 20029

#define DRV_TEMPERATURE_CODES 20033
#define DRV_TEMPERATURE_OFF 20034
#define DRV_TEMPERATURE_NOT_STABILIZED 20035
#define DRV_TEMPERATURE_STABILIZED 20036
#define DRV_TEMPERATURE_NOT_REACHED 20037
#define DRV_TEMPERATURE_OUT_RANGE 20038
#define DRV_TEMPERATURE_NOT_SUPPORTED 20039
#define DRV_TEMPERATURE_DRIFT 20040

#define DRV_TEMP_CODES 20033
#define DRV_TEMP_OFF 20034
#define DRV_TEMP_NOT_STABILIZED 20035
#define DRV_TEMP_STABILIZED 20036
#define DRV_TEMP_NOT_REACHED 20037
#define DRV_TEMP_OUT_RANGE 20038
#define DRV_TEMP_NOT_SUPPORTED 20039
#define DRV_TEMP_DRIFT 20040

#define DRV_GENERAL_ERRORS 20049
#define DRV_INVALID_AUX 20050
#define DRV_COF_NOTLOADED 20051
#define DRV_FPGAPROG 20052
#define DRV_FLEXERROR 20053
#define DRV_GPIBERROR 20054
#define DRV_EEPROMVERSIONERROR 20055

#define DRV_DATATYPE 20064
#define DRV_DRIVER_ERRORS 20065
#define DRV_P1INVALID 20066
#define DRV_P2INVALID 20067
#define DRV_P3INVALID 20068
#define DRV_P4INVALID 20069
#define DRV_INIERROR 20070
#define DRV_COFERROR 20071
#define DRV_ACQUIRING 20072
#define DRV_IDLE 20073
#define DRV_TEMPCYCLE 20074
#define DRV_NOT_INITIALIZED 20075
#define DRV_P5INVALID 20076
#define DRV_P6INVALID 20077
#define DRV_INVALID_MODE 20078
#define DRV_INVALID_FILTER 20079

#define DRV_I2CERRORS 20080
#define DRV_I2CDEVNOTFOUND 20081
#define DRV_I2CTIMEOUT 20082
#define DRV_P7INVALID 20083
#define DRV_USBERROR 20089
#define DRV_IOCERROR 20090
#define DRV_VRMVERSIONERROR 20091
#define DRV_USB_INTERRUPT_ENDPOINT_ERROR 20093
#define DRV_RANDOM_TRACK_ERROR 20094
#define DRV_INVALID_TRIGGER_MODE 20095
#define DRV_LOAD_FIRMWARE_ERROR 20096
#define DRV_DIVIDE_BY_ZERO_ERROR 20097
#define DRV_INVALID_RINGEXPOSURES 20098

#define DRV_ERROR_NOCAMERA 20990
#define DRV_NOT_SUPPORTED 20991
#define DRV_NOT_AVAILABLE 20992

#define DRV_ERROR_MAP 20115
#define DRV_ERROR_UNMAP 20116
#define DRV_ERROR_MDL 20117
#define DRV_ERROR_UNMDL 20118
#define DRV_ERROR_BUFFSIZE 20119
#define DRV_ERROR_NOHANDLE 20121

#define DRV_GATING_NOT_AVAILABLE 20130
#define DRV_FPGA_VOLTAGE_ERROR 20131

#define DRV_MSTIMINGS_ERROR 20156


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
#define AC_TRIGGERMODE_EXTERNAL_FVB_EM 4
#define AC_TRIGGERMODE_CONTINUOUS 8
#define AC_TRIGGERMODE_EXTERNALSTART 16
#define AC_TRIGGERMODE_BULB 32

#define AC_CAMERATYPE_PDA 0
#define AC_CAMERATYPE_IXON 1
#define AC_CAMERATYPE_ICCD 2
#define AC_CAMERATYPE_EMCCD 3
#define AC_CAMERATYPE_CCD 4
#define AC_CAMERATYPE_ISTAR 5
#define AC_CAMERATYPE_VIDEO 6
#define AC_CAMERATYPE_IDUS 7
#define AC_CAMERATYPE_NEWTON 8
#define AC_CAMERATYPE_SURCAM 9
#define AC_CAMERATYPE_USBISTAR 10
#define AC_CAMERATYPE_LUCA 11
#define AC_CAMERATYPE_RESERVED 12
#define AC_CAMERATYPE_IKON 13
#define AC_CAMERATYPE_INGAAS 14

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
#define AC_SETFUNCTION_ICCDGAIN 8
#define AC_SETFUNCTION_EMCCDGAIN 16
#define AC_SETFUNCTION_BASELINECLAMP 32
#define AC_SETFUNCTION_VSAMPLITUDE 64
#define AC_SETFUNCTION_HIGHCAPACITY 128
#define AC_SETFUNCTION_BASELINEOFFSET 256
#define AC_SETFUNCTION_PREAMPGAIN 512
#define AC_SETFUNCTION_CROPMODE 1024
#define AC_SETFUNCTION_DMAPARAMETERS 2048

#define AC_GETFUNCTION_TEMPERATURE 1
#define AC_GETFUNCTION_TARGETTEMPERATURE 2
#define AC_GETFUNCTION_TEMPERATURERANGE 4
#define AC_GETFUNCTION_DETECTORSIZE 8
#define AC_GETFUNCTION_GAIN 16
#define AC_GETFUNCTION_ICCDGAIN 16
#define AC_GETFUNCTION_EMCCDGAIN 32

#define AC_FEATURES_POLLING 1
#define AC_FEATURES_EVENTS 2
#define AC_FEATURES_SPOOLING 4
#define AC_FEATURES_SHUTTER 8
#define AC_FEATURES_SHUTTEREX 16
#define AC_FEATURES_EXTERNAL_I2C 32
#define AC_FEATURES_SATURATIONEVENT 64
#define AC_FEATURES_FANCONTROL 128
#define AC_FEATURES_MIDFANCONTROL 256
#define AC_FEATURES_TEMPERATUREDURINGACQUISITION 512

#define AC_EMGAIN_8BIT 1
#define AC_EMGAIN_12BIT 2
#define AC_EMGAIN_LINEAR12 4
#define AC_EMGAIN_REAL12 8

#ifdef __cplusplus
}
#endif

#endif
