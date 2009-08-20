
/* camtcl.c
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
 
#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>


extern struct camini CAM_INI[];

int cmdAndorClosingtime(ClientData clientData, Tcl_Interp * interp, int argc,
                        char *argv[])
{
/***************************************************************************************/

/* Get|Set Closing time of the shuffetof the Andor camera                                                  */

/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if(argc >= 3)
   {
      cam->closingtime = (int) fabs(atoi(argv[2]));
   }
   sprintf(ligne, "%d", cam->closingtime);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}














int cmdAndorOpeningtime(ClientData clientData, Tcl_Interp * interp, int argc,
                        char *argv[])
{
/***************************************************************************************/

/* Get|Set Opening time of the shuffetof the Andor camera                                                  */

/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if(argc >= 3)
   {
      cam->openingtime = (int) fabs(atoi(argv[2]));
   }
   sprintf(ligne, "%d", cam->openingtime);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}










int cmdAndorNative(ClientData clientData, Tcl_Interp * interp, int argc,
                   char *argv[])
{
/***************************************************************************************/

/* appel direct aux fonctions natives du driver Andor */

/***************************************************************************************/
   char ligne[1024];
   int found, res;
   struct camprop *cam;
   int param_int[10];
   long param_long[10];
   unsigned long param_ulong[10];
   float param_float[10];
   unsigned long param_DWORD[10];
   /*unsigned short param_ushort[10]; */
   ColorDemosaicInfo param_cdemo[10];
   unsigned short param_WORD[10];
   unsigned char param_BYTE[10];
   WhiteBalanceInfo param_wbal[10];
   AndorCapabilities param_acap[10];
   char param_char[10][100];
   double param_double[10];
   short param_stime[10];
   unsigned char param_uchar[10][100];
   short param_short[10];
   cam = (struct camprop *) clientData;
   Tcl_SetResult(interp, "", TCL_VOLATILE);


   if(argc > 2)
   {
      if(strcmp(argv[2], "AbortAcquisition") == 0)
      {
         res = AbortAcquisition();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: AbortAcquisition()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }
      else if(strcmp(argv[2], "CancelWait") == 0)
      {
         res = CancelWait();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: CancelWait()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }
      else if(strcmp(argv[2], "CoolerOFF") == 0)
      {
         res = CoolerOFF();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: CoolerOFF()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }
      else if(strcmp(argv[2], "CoolerON") == 0)
      {
         res = CoolerON();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: CoolerON()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }
      else if(strcmp(argv[2], "DemosaicImage") == 0)
      {
         sprintf(ligne, "Info: DemosaicImage() not implemented. For colour sensors only.");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_OK;   
      }
      else if(strcmp(argv[2], "FreeInternalMemory") == 0)
      {
         res = FreeInternalMemory();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: FreeInternalMemory()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }
      else if(strcmp(argv[2], "GetAcquiredData") == 0){
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s unsigned long ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            param_ulong[1] = (unsigned long) atol(argv[3]);
            res = GetAcquiredData((int *) &param_long[0], param_ulong[1]);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "%ld %ld ", param_long[0], param_ulong[1]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }


      }
      else if(strcmp(argv[2], "GetAcquiredData16") == 0){
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s unsigned long ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            param_ulong[1] = (unsigned long) atol(argv[3]);
            res = GetAcquiredData16(&param_WORD[0], param_ulong[1]);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "%d %ld ", param_WORD[0], param_ulong[1]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }     
      }
      else if(strcmp(argv[2], "GetAcquiredFloatData") == 0){}
      else if(strcmp(argv[2], "GetAcquisitionProgress") == 0){}
      else if(strcmp(argv[2], "GetAcquisitionTimings") == 0){}
      else if(strcmp(argv[2], "GetAdjustedRingExposureTimes") == 0){}
      else if(strcmp(argv[2], "GetAllDMAData") == 0){}
      else if(strcmp(argv[2], "GetAmpDesc") == 0){}
      else if(strcmp(argv[2], "GetAmpMaxSpeed") == 0){}
      else if(strcmp(argv[2], "GetAvailableCameras") == 0){}
      else if(strcmp(argv[2], "GetBackground") == 0){}
      else if(strcmp(argv[2], "GetBitDepth") == 0){}
      else if(strcmp(argv[2], "GetCameraEventStatus") == 0){}
      else if(strcmp(argv[2], "GetCameraHandle") == 0){}
      else if(strcmp(argv[2], "GetCameraInformation") == 0){}
      else if(strcmp(argv[2], "GetCameraSerialNumber") == 0){}
      else if(strcmp(argv[2], "GetCapabilities") == 0){}
      else if(strcmp(argv[2], "GetControllerCardModel") == 0){}
      else if(strcmp(argv[2], "GetCurrentCamera") == 0){}
      else if(strcmp(argv[2], "GetDDGPulse") == 0){}
      else if(strcmp(argv[2], "GetDDGIOCFrequency") == 0){}
      else if(strcmp(argv[2], "GetDDGIOCNumber") == 0){}
      else if(strcmp(argv[2], "GetDDGIOCPulses") == 0){}
      else if(strcmp(argv[2], "GetDetector") == 0){
         int width,height;
         res = GetDetector(&width, &height);
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: GetDetector(width=%d, height=%d);",width,height);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
        }
      else if(strcmp(argv[2], "GetDICameraInfo") == 0){}
      else if(strcmp(argv[2], "GetEMCCDGain") == 0){}
      else if(strcmp(argv[2], "GetEMGainRange") == 0){}
      else if(strcmp(argv[2], "GetFastestRecommendedVSSpeed") == 0){}
      else if(strcmp(argv[2], "GetFIFOUsage") == 0){}
      else if(strcmp(argv[2], "GetFilterMode") == 0){}
      else if(strcmp(argv[2], "GetFKExposureTime") == 0){}
      else if(strcmp(argv[2], "GetFKVShiftSpeed") == 0){}
      else if(strcmp(argv[2], "GetFKVShiftSpeedF") == 0){}
      else if(strcmp(argv[2], "GetHardwareVersion") == 0){}
      else if(strcmp(argv[2], "GetHeadModel") == 0){}
      else if(strcmp(argv[2], "GetHorizontalSpeed") == 0){}
      else if(strcmp(argv[2], "GetHSSpeed") == 0){}
      else if(strcmp(argv[2], "GetHVflag") == 0){}
      else if(strcmp(argv[2], "GetID") == 0){}
      else if(strcmp(argv[2], "GetImages ") == 0){}
      else if(strcmp(argv[2], "GetImages16 ") == 0){}
      else if(strcmp(argv[2], "GetImagesPerDMA") == 0){}
      else if(strcmp(argv[2], "GetIRQ") == 0){}
      else if(strcmp(argv[2], "GetKeepCleanTime") == 0){}
      else if(strcmp(argv[2], "GetMaximumBinning") == 0){}
      else if(strcmp(argv[2], "GetMaximumExposure") == 0){}
      else if(strcmp(argv[2], "GetMCPGain") == 0){}
      else if(strcmp(argv[2], "GetMCPGainRange") == 0){}
      else if(strcmp(argv[2], "GetMCPVoltage") == 0){}
      else if(strcmp(argv[2], "GetMetaDataInfo") == 0){}
      else if(strcmp(argv[2], "GetMinimumImageLength") == 0){}
      else if(strcmp(argv[2], "GetMostRecentColorImage16 ") == 0){}
      else if(strcmp(argv[2], "GetMostRecentImage ") == 0){}
      else if(strcmp(argv[2], "GetMostRecentImage16 ") == 0){}
      else if(strcmp(argv[2], "GetMSTimingsData") == 0){}
      else if(strcmp(argv[2], "GetMSTimingsEnabled") == 0){}
      else if(strcmp(argv[2], "GetNewData") == 0){}
      else if(strcmp(argv[2], "GetNewData16") == 0){}
      else if(strcmp(argv[2], "GetNewData8") == 0){}
      else if(strcmp(argv[2], "GetNewFloatData") == 0){}
      else if(strcmp(argv[2], "GetNumberADChannels") == 0){}
      else if(strcmp(argv[2], "GetNumberAmp") == 0){}
      else if(strcmp(argv[2], "GetNumberAvailableImages ") == 0){}
      else if(strcmp(argv[2], "GetNumberDevices") == 0){}
      else if(strcmp(argv[2], "GetNumberFKVShiftSpeeds") == 0){}
      else if(strcmp(argv[2], "GetNumberHorizontalSpeeds") == 0){}
      else if(strcmp(argv[2], "GetNumberHSSpeeds") == 0){}
      else if(strcmp(argv[2], "GetNumberNewImages ") == 0){}
      else if(strcmp(argv[2], "GetNumberPreAmpGains") == 0){}
      else if(strcmp(argv[2], "GetNumberRingExposureTimes") == 0){}
      else if(strcmp(argv[2], "GetNumberIO") == 0){}
      else if(strcmp(argv[2], "GetNumberVerticalSpeeds") == 0){}
      else if(strcmp(argv[2], "GetNumberVSAmplitudes") == 0){}
      else if(strcmp(argv[2], "GetNumberVSSpeeds") == 0){}
      else if(strcmp(argv[2], "GetOldestImage ") == 0){}
      else if(strcmp(argv[2], "GetOldestImage16 ") == 0){}
      else if(strcmp(argv[2], "GetPhysicalDMAAddress") == 0){}
      else if(strcmp(argv[2], "GetPixelSize") == 0){}
      else if(strcmp(argv[2], "GetPreAmpGain") == 0){}
      else if(strcmp(argv[2], "GetRegisterDump") == 0){}
      else if(strcmp(argv[2], "GetRingExposureRange") == 0){}
      else if(strcmp(argv[2], "GetSizeOfCircularBuffer ") == 0){}
      else if(strcmp(argv[2], "GetSlotBusDeviceFunction") == 0){}
      else if(strcmp(argv[2], "GetSoftwareVersion") == 0){}
      else if(strcmp(argv[2], "GetSpoolProgress") == 0){}
      else if(strcmp(argv[2], "GetStatus") == 0){}
      else if(strcmp(argv[2], "GetTemperature") == 0){
         int temperature;
         res = GetTemperature(&temperature);
         sprintf(ligne, "Info: GetTemperature %d (%d)",temperature,res);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_OK;
         }
      else if(strcmp(argv[2], "GetTemperatureF") == 0){
         float temperatureF;
         res = GetTemperatureF(&temperatureF);
         sprintf(ligne, "Info: GetTemperatureF %f (%d)",temperatureF,res);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_OK;
         }
      else if(strcmp(argv[2], "GetTemperatureRange") == 0){
         int mintemp,maxtemp;
         res = GetTemperatureRange(&mintemp,&maxtemp);
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: GetTemperatureRange(mintemp=%d, maxtemp=%d);",mintemp,maxtemp);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
         }
      else if(strcmp(argv[2], "GetTemperatureStatus") == 0){}
      else if(strcmp(argv[2], "GetTotalNumberImagesAcquired") == 0){
         int index;
         res = GetTotalNumberImagesAcquired(&index);
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: GetTotalNumberImagesAcquired (nbimg=%d);",index);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
       
      
      }
      else if(strcmp(argv[2], "GetIODirection") == 0){}
      else if(strcmp(argv[2], "GetIOLevel") == 0){}
      else if(strcmp(argv[2], "GetVersionInfo") == 0){}
      else if(strcmp(argv[2], "GetVerticalSpeed") == 0){}
      else if(strcmp(argv[2], "GetVirtualDMAAdress") == 0){}
      else if(strcmp(argv[2], "GetVSSpeed") == 0){}
      else if(strcmp(argv[2], "GPIBReceive") == 0){}
      else if(strcmp(argv[2], "GPIBSend") == 0){}
      else if(strcmp(argv[2], "I2CBurstRead") == 0){}
      else if(strcmp(argv[2], "I2CBurstWrite") == 0){}
      else if(strcmp(argv[2], "I2CRead") == 0){}
      else if(strcmp(argv[2], "I2CReset") == 0){}
      else if(strcmp(argv[2], "I2CWrite") == 0){}
      else if(strcmp(argv[2], "IdAndorDll") == 0){}
      else if(strcmp(argv[2], "InAuxPort") == 0){}
      else if(strcmp(argv[2], "Initialize") == 0){
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s path", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            char * path = argv[3];
            sprintf(ligne, "Info: begin Initialize (%s)", path);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            res = Initialize(path);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error(%d)", res);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "Info: Initialize(%s)", path);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }
      else if(strcmp(argv[2], "InitializeDevice") == 0){}
      else if(strcmp(argv[2], "IsCoolerON") == 0){
      
      }
      else if(strcmp(argv[2], "IsInternalMechanicalShutter") == 0){}
      else if(strcmp(argv[2], "IsAmplifierAvailable") == 0){}
      else if(strcmp(argv[2], "IsPreAmpGainAvailable") == 0){}
      else if(strcmp(argv[2], "IsTriggerModeAvailable") == 0){}
      else if(strcmp(argv[2], "Merge") == 0){}
      else if(strcmp(argv[2], "OutAuxPort") == 0){}
      else if(strcmp(argv[2], "PrepareAcquisition") == 0){}
      else if(strcmp(argv[2], "SaveAsBmp") == 0){}
      else if(strcmp(argv[2], "SaveAsCommentedSif") == 0){}
      else if(strcmp(argv[2], "SaveAsEDF") == 0){}
      else if(strcmp(argv[2], "SaveAsFITS") == 0){
         if(argc < 5)
         {
            sprintf(ligne, "Usage: %s %s %s char* int ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            strcpy(param_char[0], argv[0]);
            param_int[1] = (int) atoi(argv[1]);
            res = SaveAsFITS(param_char[0], param_int[1]);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "%s %d ", param_char[0], param_int[1]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }      
      }
      else if(strcmp(argv[2], "SaveAsRaw") == 0){}
      else if(strcmp(argv[2], "SaveAsSif") == 0){}
      else if(strcmp(argv[2], "SaveAsSPC") == 0){}
      else if(strcmp(argv[2], "SaveAsTiff") == 0){}
      else if(strcmp(argv[2], "SaveAsTiffEx") == 0){}
      else if(strcmp(argv[2], "SaveEEPROMToFile") == 0){}
      else if(strcmp(argv[2], "SaveToClipBoard") == 0){}
      else if(strcmp(argv[2], "SelectDevice") == 0){}
      else if(strcmp(argv[2], "SendSoftwareTrigger") == 0){}
      else if(strcmp(argv[2], "SetAccumulationCycleTime") == 0){}
      else if(strcmp(argv[2], "SetAcqStatusEvent") == 0){}
      else if(strcmp(argv[2], "SetAcquisitionMode") == 0){}
      else if(strcmp(argv[2], "SetAcquisitionType") == 0){}
      else if(strcmp(argv[2], "SetADChannel") == 0){}
      else if(strcmp(argv[2], "SetAdvancedTriggerModeState") == 0){}
      else if(strcmp(argv[2], "SetBackground") == 0){}
      else if(strcmp(argv[2], "SetBaselineClamp") == 0){}
      else if(strcmp(argv[2], "SetBaselineOffset") == 0){}
      else if(strcmp(argv[2], "SetCameraStatusEnable") == 0){}
      else if(strcmp(argv[2], "SetComplexImage") == 0){}
      else if(strcmp(argv[2], "SetCoolerMode") == 0){}
      else if(strcmp(argv[2], "SetCropMode") == 0){}
      else if(strcmp(argv[2], "SetCurrentCamera") == 0){}
      else if(strcmp(argv[2], "SetCustomTrackHBin") == 0){}
      else if(strcmp(argv[2], "SetDACOutputScale") == 0){}
      else if(strcmp(argv[2], "SetDACOutput") == 0){}
      else if(strcmp(argv[2], "SetDataType") == 0){}
      else if(strcmp(argv[2], "SetDDGAddress") == 0){}
      else if(strcmp(argv[2], "SetDDGGain") == 0){}
      else if(strcmp(argv[2], "SetDDGGateStep") == 0){}
      else if(strcmp(argv[2], "SetDDGInsertionDelay") == 0){}
      else if(strcmp(argv[2], "SetDDGIntelligate") == 0){}
      else if(strcmp(argv[2], "SetDDGIOC") == 0){}
      else if(strcmp(argv[2], "SetDDGIOCFrequency") == 0){}
      else if(strcmp(argv[2], "SetDDGIOCNumber") == 0){}
      else if(strcmp(argv[2], "SetDDGTimes") == 0){}
      else if(strcmp(argv[2], "SetDDGTriggerMode") == 0){}
      else if(strcmp(argv[2], "SetDDGVariableGateStep") == 0){}
      else if(strcmp(argv[2], "SetDelayGenerator") == 0){}
      else if(strcmp(argv[2], "SetDMAParameters") == 0){}
      else if(strcmp(argv[2], "SetDriverEvent") == 0){}
      else if(strcmp(argv[2], "SetEMAdvanced") == 0){}
      else if(strcmp(argv[2], "SetEMCCDGain") == 0){}
      else if(strcmp(argv[2], "SetEMClockCompensation") == 0){}
      else if(strcmp(argv[2], "SetEMGainMode") == 0){}
      else if(strcmp(argv[2], "SetExposureTime") == 0){}
      else if(strcmp(argv[2], "SetFanMode") == 0){}
      else if(strcmp(argv[2], "SetFastKinetics") == 0){}
      else if(strcmp(argv[2], "SetFastKineticsEx") == 0){}
      else if(strcmp(argv[2], "SetFilterMode") == 0){}
      else if(strcmp(argv[2], "SetFilterParameters") == 0){}
      else if(strcmp(argv[2], "SetFKVShiftSpeed") == 0){}
      else if(strcmp(argv[2], "SetFPDP") == 0){}
      else if(strcmp(argv[2], "SetFrameTransferMode") == 0){}
      else if(strcmp(argv[2], "SetFullImage") == 0){}
      else if(strcmp(argv[2], "SetFVBHBin") == 0){}
      else if(strcmp(argv[2], "SetGain") == 0){}
      else if(strcmp(argv[2], "SetGate") == 0){}
      else if(strcmp(argv[2], "SetGateMode") == 0){}
      else if(strcmp(argv[2], "SetHighCapacity") == 0){}
      else if(strcmp(argv[2], "SetHorizontalSpeed") == 0){}
      else if(strcmp(argv[2], "SetHSSpeed") == 0){}
      else if(strcmp(argv[2], "SetImage") == 0){}
      else if(strcmp(argv[2], "SetImageFlip") == 0){}
      else if(strcmp(argv[2], "SetImageRotate") == 0){}
      else if(strcmp(argv[2], "SetIsolatedCropMode ") == 0){}
      else if(strcmp(argv[2], "SetKineticCycleTime") == 0){}
      else if(strcmp(argv[2], "SetMCPGain") == 0){}
      else if(strcmp(argv[2], "SetMCPGating") == 0){}
      else if(strcmp(argv[2], "SetMessageWindow") == 0){}
      else if(strcmp(argv[2], "SetMetaData") == 0){}
      else if(strcmp(argv[2], "SetMultiTrack") == 0){}
      else if(strcmp(argv[2], "SetMultiTrackHBin") == 0){}
      else if(strcmp(argv[2], "SetMultiTrackHRange") == 0){}
      else if(strcmp(argv[2], "SetNextAddress") == 0){}
      else if(strcmp(argv[2], "SetNextAddress16") == 0){}
      else if(strcmp(argv[2], "SetNumberAccumulations") == 0){}
      else if(strcmp(argv[2], "SetNumberKinetics") == 0){}
      else if(strcmp(argv[2], "SetNumberPrescans") == 0){}
      else if(strcmp(argv[2], "SetOutputAmplifier") == 0){}
      else if(strcmp(argv[2], "SetOverlapMode") == 0){}
      else if(strcmp(argv[2], "SetPCIMode") == 0){}
      else if(strcmp(argv[2], "SetPhotonCounting") == 0){}
      else if(strcmp(argv[2], "SetPhotonCountingThreshold") == 0){}
      else if(strcmp(argv[2], "SetPixelMode") == 0){}
      else if(strcmp(argv[2], "SetPreAmpGain") == 0){}
      else if(strcmp(argv[2], "SetRandomTracks") == 0){}
      else if(strcmp(argv[2], "SetReadMode") == 0){}
      else if(strcmp(argv[2], "SetRegisterDump") == 0){}
      else if(strcmp(argv[2], "SetRingExposureTimes") == 0){}
      else if(strcmp(argv[2], "SetSaturationEvent") == 0){}
      else if(strcmp(argv[2], "SetShutter") == 0){}
      else if(strcmp(argv[2], "SetShutterEx") == 0){}
      else if(strcmp(argv[2], "SetShutters") == 0){}
      else if(strcmp(argv[2], "SetSifComment") == 0){}
      else if(strcmp(argv[2], "SetSingleTrack") == 0){}
      else if(strcmp(argv[2], "SetSingleTrackHBin") == 0){}
      else if(strcmp(argv[2], "SetSpool") == 0){}
      else if(strcmp(argv[2], "SetStorageMode") == 0){}
      else if(strcmp(argv[2], "SetTemperature") == 0){
         int temperature;
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s int ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            temperature = (int) atoi(argv[3]);
            res = SetTemperature(temperature);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error(%d) %d", res,temperature);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "Info: SetTemperature fixed to %d °C (%d);",temperature,res);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }

         }


         
      }
      else if(strcmp(argv[2], "SetTriggerInvert") == 0){}
      else if(strcmp(argv[2], "SetTriggerMode") == 0){}
      else if(strcmp(argv[2], "SetIODirection") == 0){}
      else if(strcmp(argv[2], "SetIOLevel") == 0){}
      else if(strcmp(argv[2], "SetUSEvent") == 0){}
      else if(strcmp(argv[2], "SetUSGenomics") == 0){}
      else if(strcmp(argv[2], "SetVerticalRowBuffer") == 0){}
      else if(strcmp(argv[2], "SetVerticalSpeed") == 0){}
      else if(strcmp(argv[2], "SetVirtualChip") == 0){}
      else if(strcmp(argv[2], "SetVSAmplitude") == 0){}
      else if(strcmp(argv[2], "SetVSSpeed") == 0){}
      else if(strcmp(argv[2], "ShutDown") == 0)
      {
         res = ShutDown();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: ShutDown()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }
      else if(strcmp(argv[2], "StartAcquisition") == 0){}
      else if(strcmp(argv[2], "UnMapPhysicalAddress") == 0){}
      else if(strcmp(argv[2], "WaitForAcquisition") == 0){}
      else if(strcmp(argv[2], "WaitForAcquisitionByHandle") == 0){}
      else if(strcmp(argv[2], "WaitForAcquisitionByHandleTimeOut") == 0){}
      else if(strcmp(argv[2], "WaitForAcquisitionTimeOut") == 0){}
      else if(strcmp(argv[2], "WhiteBalance") == 0){}
   }
   else
   {
      // SDK version 2.84.30003.0
      
      Tcl_SetResult(interp, "Available functions are: ", TCL_VOLATILE);
      Tcl_AppendResult(interp, "AbortAcquisition ", NULL);
      Tcl_AppendResult(interp, "CancelWait ", NULL);
      Tcl_AppendResult(interp, "CoolerOFF ", NULL);
      Tcl_AppendResult(interp, "CoolerON ", NULL);
      Tcl_AppendResult(interp, "DemosaicImage ", NULL);
      Tcl_AppendResult(interp, "FreeInternalMemory ", NULL);
      Tcl_AppendResult(interp, "GetAcquiredData ", NULL);
      Tcl_AppendResult(interp, "GetAcquiredData16 ", NULL);
      Tcl_AppendResult(interp, "GetAcquiredFloatData ", NULL);
      Tcl_AppendResult(interp, "GetAcquisitionProgress ", NULL);
      Tcl_AppendResult(interp, "GetAcquisitionTimings ", NULL);
      Tcl_AppendResult(interp, "GetAdjustedRingExposureTimes ", NULL);
      Tcl_AppendResult(interp, "GetAllDMAData ", NULL);
      Tcl_AppendResult(interp, "GetAmpDesc ", NULL);
      Tcl_AppendResult(interp, "GetAmpMaxSpeed ", NULL);
      Tcl_AppendResult(interp, "GetAvailableCameras ", NULL);
      Tcl_AppendResult(interp, "GetBackground ", NULL);
      Tcl_AppendResult(interp, "GetBitDepth ", NULL);
      Tcl_AppendResult(interp, "GetCameraEventStatus ", NULL);
      Tcl_AppendResult(interp, "GetCameraHandle ", NULL);
      Tcl_AppendResult(interp, "GetCameraInformation ", NULL);
      Tcl_AppendResult(interp, "GetCameraSerialNumber ", NULL);
      Tcl_AppendResult(interp, "GetCapabilities ", NULL);
      Tcl_AppendResult(interp, "GetControllerCardModel ", NULL);
      Tcl_AppendResult(interp, "GetCurrentCamera ", NULL);
      Tcl_AppendResult(interp, "GetDDGPulse ", NULL);
      Tcl_AppendResult(interp, "GetDDGIOCFrequency ", NULL);
      Tcl_AppendResult(interp, "GetDDGIOCNumber ", NULL);
      Tcl_AppendResult(interp, "GetDDGIOCPulses ", NULL);
      Tcl_AppendResult(interp, "GetDetector ", NULL);
      Tcl_AppendResult(interp, "GetDICameraInfo", NULL);
      Tcl_AppendResult(interp, "GetEMCCDGain ", NULL);
      Tcl_AppendResult(interp, "GetEMGainRange ", NULL);
      Tcl_AppendResult(interp, "GetFastestRecommendedVSSpeed ", NULL);
      Tcl_AppendResult(interp, "GetFIFOUsage ", NULL);
      Tcl_AppendResult(interp, "GetFilterMode ", NULL);
      Tcl_AppendResult(interp, "GetFKExposureTime ", NULL);
      Tcl_AppendResult(interp, "GetFKVShiftSpeed ", NULL);
      Tcl_AppendResult(interp, "GetFKVShiftSpeedF ", NULL);
      Tcl_AppendResult(interp, "GetHardwareVersion ", NULL);
      Tcl_AppendResult(interp, "GetHeadModel ", NULL);
      Tcl_AppendResult(interp, "GetHorizontalSpeed ", NULL);
      Tcl_AppendResult(interp, "GetHSSpeed ", NULL);
      Tcl_AppendResult(interp, "GetHVflag ", NULL);
      Tcl_AppendResult(interp, "GetID ", NULL);
      Tcl_AppendResult(interp, "GetImages  ", NULL);
      Tcl_AppendResult(interp, "GetImages16  ", NULL);
      Tcl_AppendResult(interp, "GetImagesPerDMA ", NULL);
      Tcl_AppendResult(interp, "GetIRQ ", NULL);
      Tcl_AppendResult(interp, "GetKeepCleanTime ", NULL);
      Tcl_AppendResult(interp, "GetMaximumBinning ", NULL);
      Tcl_AppendResult(interp, "GetMaximumExposure ", NULL);
      Tcl_AppendResult(interp, "GetMCPGain ", NULL);
      Tcl_AppendResult(interp, "GetMCPGainRange ", NULL);
      Tcl_AppendResult(interp, "GetMCPVoltage ", NULL);
      Tcl_AppendResult(interp, "GetMetaDataInfo ", NULL);
      Tcl_AppendResult(interp, "GetMinimumImageLength ", NULL);
      Tcl_AppendResult(interp, "GetMostRecentColorImage16  ", NULL);
      Tcl_AppendResult(interp, "GetMostRecentImage  ", NULL);
      Tcl_AppendResult(interp, "GetMostRecentImage16  ", NULL);
      Tcl_AppendResult(interp, "GetMSTimingsData ", NULL);
      Tcl_AppendResult(interp, "GetMSTimingsEnabled ", NULL);
      Tcl_AppendResult(interp, "GetNewData ", NULL);
      Tcl_AppendResult(interp, "GetNewData16 ", NULL);
      Tcl_AppendResult(interp, "GetNewData8 ", NULL);
      Tcl_AppendResult(interp, "GetNewFloatData ", NULL);
      Tcl_AppendResult(interp, "GetNumberADChannels ", NULL);
      Tcl_AppendResult(interp, "GetNumberAmp ", NULL);
      Tcl_AppendResult(interp, "GetNumberAvailableImages  ", NULL);
      Tcl_AppendResult(interp, "GetNumberDevices ", NULL);
      Tcl_AppendResult(interp, "GetNumberFKVShiftSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberHorizontalSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberHSSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberNewImages  ", NULL);
      Tcl_AppendResult(interp, "GetNumberPreAmpGains ", NULL);
      Tcl_AppendResult(interp, "GetNumberRingExposureTimes ", NULL);
      Tcl_AppendResult(interp, "GetNumberIO ", NULL);
      Tcl_AppendResult(interp, "GetNumberVerticalSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberVSAmplitudes ", NULL);
      Tcl_AppendResult(interp, "GetNumberVSSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetOldestImage  ", NULL);
      Tcl_AppendResult(interp, "GetOldestImage16  ", NULL);
      Tcl_AppendResult(interp, "GetPhysicalDMAAddress ", NULL);
      Tcl_AppendResult(interp, "GetPixelSize ", NULL);
      Tcl_AppendResult(interp, "GetPreAmpGain ", NULL);
      Tcl_AppendResult(interp, "GetRegisterDump ", NULL);
      Tcl_AppendResult(interp, "GetRingExposureRange ", NULL);
      Tcl_AppendResult(interp, "GetSizeOfCircularBuffer  ", NULL);
      Tcl_AppendResult(interp, "GetSlotBusDeviceFunction ", NULL);
      Tcl_AppendResult(interp, "GetSoftwareVersion ", NULL);
      Tcl_AppendResult(interp, "GetSpoolProgress ", NULL);
      Tcl_AppendResult(interp, "GetStatus ", NULL);
      Tcl_AppendResult(interp, "GetTemperature ", NULL);
      Tcl_AppendResult(interp, "GetTemperatureF ", NULL);
      Tcl_AppendResult(interp, "GetTemperatureRange ", NULL);
      Tcl_AppendResult(interp, "GetTemperatureStatus ", NULL);
      Tcl_AppendResult(interp, "GetTotalNumberImagesAcquired  ", NULL);
      Tcl_AppendResult(interp, "GetIODirection ", NULL);
      Tcl_AppendResult(interp, "GetIOLevel ", NULL);
      Tcl_AppendResult(interp, "GetVersionInfo ", NULL);
      Tcl_AppendResult(interp, "GetVerticalSpeed ", NULL);
      Tcl_AppendResult(interp, "GetVirtualDMAAdress ", NULL);
      Tcl_AppendResult(interp, "GetVSSpeed ", NULL);
      Tcl_AppendResult(interp, "GPIBReceive ", NULL);
      Tcl_AppendResult(interp, "GPIBSend ", NULL);
      Tcl_AppendResult(interp, "I2CBurstRead ", NULL);
      Tcl_AppendResult(interp, "I2CBurstWrite ", NULL);
      Tcl_AppendResult(interp, "I2CRead ", NULL);
      Tcl_AppendResult(interp, "I2CReset ", NULL);
      Tcl_AppendResult(interp, "I2CWrite ", NULL);
      Tcl_AppendResult(interp, "IdAndorDll ", NULL);
      Tcl_AppendResult(interp, "InAuxPort ", NULL);
      Tcl_AppendResult(interp, "Initialize ", NULL);
      Tcl_AppendResult(interp, "InitializeDevice ", NULL);
      Tcl_AppendResult(interp, "IsInternalMechanicalShutter ", NULL);
      Tcl_AppendResult(interp, "IsAmplifierAvailable ", NULL);
      Tcl_AppendResult(interp, "IsPreAmpGainAvailable ", NULL);
      Tcl_AppendResult(interp, "IsTriggerModeAvailable ", NULL);
      Tcl_AppendResult(interp, "Merge ", NULL);
      Tcl_AppendResult(interp, "OutAuxPort ", NULL);
      Tcl_AppendResult(interp, "PrepareAcquisition ", NULL);
      Tcl_AppendResult(interp, "SaveAsBmp ", NULL);
      Tcl_AppendResult(interp, "SaveAsCommentedSif ", NULL);
      Tcl_AppendResult(interp, "SaveAsEDF ", NULL);
      Tcl_AppendResult(interp, "SaveAsFITS ", NULL);
      Tcl_AppendResult(interp, "SaveAsRaw ", NULL);
      Tcl_AppendResult(interp, "SaveAsSif ", NULL);
      Tcl_AppendResult(interp, "SaveAsSPC ", NULL);
      Tcl_AppendResult(interp, "SaveAsTiff ", NULL);
      Tcl_AppendResult(interp, "SaveAsTiffEx ", NULL);
      Tcl_AppendResult(interp, "SaveEEPROMToFile ", NULL);
      Tcl_AppendResult(interp, "SaveToClipBoard ", NULL);
      Tcl_AppendResult(interp, "SelectDevice ", NULL);
      Tcl_AppendResult(interp, "SendSoftwareTrigger ", NULL);
      Tcl_AppendResult(interp, "SetAccumulationCycleTime ", NULL);
      Tcl_AppendResult(interp, "SetAcqStatusEvent ", NULL);
      Tcl_AppendResult(interp, "SetAcquisitionMode ", NULL);
      Tcl_AppendResult(interp, "SetAcquisitionType ", NULL);
      Tcl_AppendResult(interp, "SetADChannel ", NULL);
      Tcl_AppendResult(interp, "SetAdvancedTriggerModeState ", NULL);
      Tcl_AppendResult(interp, "SetBackground ", NULL);
      Tcl_AppendResult(interp, "SetBaselineClamp ", NULL);
      Tcl_AppendResult(interp, "SetBaselineOffset ", NULL);
      Tcl_AppendResult(interp, "SetCameraStatusEnable ", NULL);
      Tcl_AppendResult(interp, "SetComplexImage ", NULL);
      Tcl_AppendResult(interp, "SetCoolerMode ", NULL);
      Tcl_AppendResult(interp, "SetCropMode ", NULL);
      Tcl_AppendResult(interp, "SetCurrentCamera ", NULL);
      Tcl_AppendResult(interp, "SetCustomTrackHBin ", NULL);
      Tcl_AppendResult(interp, "SetDACOutputScale ", NULL);
      Tcl_AppendResult(interp, "SetDACOutput ", NULL);
      Tcl_AppendResult(interp, "SetDataType ", NULL);
      Tcl_AppendResult(interp, "SetDDGAddress ", NULL);
      Tcl_AppendResult(interp, "SetDDGGain ", NULL);
      Tcl_AppendResult(interp, "SetDDGGateStep ", NULL);
      Tcl_AppendResult(interp, "SetDDGInsertionDelay ", NULL);
      Tcl_AppendResult(interp, "SetDDGIntelligate ", NULL);
      Tcl_AppendResult(interp, "SetDDGIOC ", NULL);
      Tcl_AppendResult(interp, "SetDDGIOCFrequency ", NULL);
      Tcl_AppendResult(interp, "SetDDGIOCNumber ", NULL);
      Tcl_AppendResult(interp, "SetDDGTimes ", NULL);
      Tcl_AppendResult(interp, "SetDDGTriggerMode ", NULL);
      Tcl_AppendResult(interp, "SetDDGVariableGateStep ", NULL);
      Tcl_AppendResult(interp, "SetDelayGenerator ", NULL);
      Tcl_AppendResult(interp, "SetDMAParameters ", NULL);
      Tcl_AppendResult(interp, "SetDriverEvent ", NULL);
      Tcl_AppendResult(interp, "SetEMAdvanced ", NULL);
      Tcl_AppendResult(interp, "SetEMCCDGain ", NULL);
      Tcl_AppendResult(interp, "SetEMClockCompensation ", NULL);
      Tcl_AppendResult(interp, "SetEMGainMode ", NULL);
      Tcl_AppendResult(interp, "SetExposureTime ", NULL);
      Tcl_AppendResult(interp, "SetFanMode ", NULL);
      Tcl_AppendResult(interp, "SetFastKinetics ", NULL);
      Tcl_AppendResult(interp, "SetFastKineticsEx ", NULL);
      Tcl_AppendResult(interp, "SetFilterMode ", NULL);
      Tcl_AppendResult(interp, "SetFilterParameters ", NULL);
      Tcl_AppendResult(interp, "SetFKVShiftSpeed ", NULL);
      Tcl_AppendResult(interp, "SetFPDP ", NULL);
      Tcl_AppendResult(interp, "SetFrameTransferMode ", NULL);
      Tcl_AppendResult(interp, "SetFullImage ", NULL);
      Tcl_AppendResult(interp, "SetFVBHBin ", NULL);
      Tcl_AppendResult(interp, "SetGain ", NULL);
      Tcl_AppendResult(interp, "SetGate ", NULL);
      Tcl_AppendResult(interp, "SetGateMode ", NULL);
      Tcl_AppendResult(interp, "SetHighCapacity ", NULL);
      Tcl_AppendResult(interp, "SetHorizontalSpeed ", NULL);
      Tcl_AppendResult(interp, "SetHSSpeed ", NULL);
      Tcl_AppendResult(interp, "SetImage ", NULL);
      Tcl_AppendResult(interp, "SetImageFlip ", NULL);
      Tcl_AppendResult(interp, "SetImageRotate ", NULL);
      Tcl_AppendResult(interp, "SetIsolatedCropMode  ", NULL);
      Tcl_AppendResult(interp, "SetKineticCycleTime ", NULL);
      Tcl_AppendResult(interp, "SetMCPGain ", NULL);
      Tcl_AppendResult(interp, "SetMCPGating ", NULL);
      Tcl_AppendResult(interp, "SetMessageWindow ", NULL);
      Tcl_AppendResult(interp, "SetMetaData ", NULL);
      Tcl_AppendResult(interp, "SetMultiTrack ", NULL);
      Tcl_AppendResult(interp, "SetMultiTrackHBin ", NULL);
      Tcl_AppendResult(interp, "SetMultiTrackHRange ", NULL);
      Tcl_AppendResult(interp, "SetNextAddress ", NULL);
      Tcl_AppendResult(interp, "SetNextAddress16 ", NULL);
      Tcl_AppendResult(interp, "SetNumberAccumulations ", NULL);
      Tcl_AppendResult(interp, "SetNumberKinetics ", NULL);
      Tcl_AppendResult(interp, "SetNumberPrescans ", NULL);
      Tcl_AppendResult(interp, "SetOutputAmplifier ", NULL);
      Tcl_AppendResult(interp, "SetOverlapMode ", NULL);
      Tcl_AppendResult(interp, "SetPCIMode ", NULL);
      Tcl_AppendResult(interp, "SetPhotonCounting ", NULL);
      Tcl_AppendResult(interp, "SetPhotonCountingThreshold ", NULL);
      Tcl_AppendResult(interp, "SetPixelMode ", NULL);
      Tcl_AppendResult(interp, "SetPreAmpGain ", NULL);
      Tcl_AppendResult(interp, "SetRandomTracks ", NULL);
      Tcl_AppendResult(interp, "SetReadMode ", NULL);
      Tcl_AppendResult(interp, "SetRegisterDump ", NULL);
      Tcl_AppendResult(interp, "SetRingExposureTimes ", NULL);
      Tcl_AppendResult(interp, "SetSaturationEvent ", NULL);
      Tcl_AppendResult(interp, "SetShutter ", NULL);
      Tcl_AppendResult(interp, "SetShutterEx ", NULL);
      Tcl_AppendResult(interp, "SetShutters ", NULL);
      Tcl_AppendResult(interp, "SetSifComment ", NULL);
      Tcl_AppendResult(interp, "SetSingleTrack ", NULL);
      Tcl_AppendResult(interp, "SetSingleTrackHBin ", NULL);
      Tcl_AppendResult(interp, "SetSpool ", NULL);
      Tcl_AppendResult(interp, "SetStorageMode ", NULL);
      Tcl_AppendResult(interp, "SetTemperature ", NULL);
      Tcl_AppendResult(interp, "SetTriggerInvert ", NULL);
      Tcl_AppendResult(interp, "SetTriggerMode ", NULL);
      Tcl_AppendResult(interp, "SetIODirection ", NULL);
      Tcl_AppendResult(interp, "SetIOLevel ", NULL);
      Tcl_AppendResult(interp, "SetUSEvent ", NULL);
      Tcl_AppendResult(interp, "SetUSGenomics ", NULL);
      Tcl_AppendResult(interp, "SetVerticalRowBuffer ", NULL);
      Tcl_AppendResult(interp, "SetVerticalSpeed ", NULL);
      Tcl_AppendResult(interp, "SetVirtualChip ", NULL);
      Tcl_AppendResult(interp, "SetVSAmplitude ", NULL);
      Tcl_AppendResult(interp, "SetVSSpeed ", NULL);
      Tcl_AppendResult(interp, "ShutDown ", NULL);
      Tcl_AppendResult(interp, "StartAcquisition ", NULL);
      Tcl_AppendResult(interp, "UnMapPhysicalAddress ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisition ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisitionByHandle ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisitionByHandleTimeOut ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisitionTimeOut ", NULL);
      Tcl_AppendResult(interp, "WhiteBalance ", NULL);
      
      return TCL_ERROR;
   }
   
   return TCL_OK;
}

int cmdAndorAcqmode(ClientData clientData, Tcl_Interp * interp, int argc,
                    char *argv[])
{
   return 0;
}

int cmdAndorElectronic(ClientData clientData, Tcl_Interp * interp, int argc,
                       char *argv[])
{
   return 0;
}
