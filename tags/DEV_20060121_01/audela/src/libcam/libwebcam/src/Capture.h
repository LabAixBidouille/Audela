// Capture.h: interface for the CCapture class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CAPTURE_H__15DE327D_A32E_45E9_ABA6_FAA48FD17C91__INCLUDED_)
#define AFX_CAPTURE_H__15DE327D_A32E_45E9_ABA6_FAA48FD17C91__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif				// _MSC_VER > 1000


#include <windows.h>
#include <vfw.h>
#include "CaptureListener.h"

// defines
#define FPS_TO_MS(f)             ((DWORD) ((double)1.0e6 / f))

#define DEF_CAPTURE_FPS          15
#define MIN_CAPTURE_FPS          (1.0 / 60)	// one frame per minute
#define MAX_CAPTURE_FPS          100

#define FPS_TO_MS(f)             ((DWORD) ((double)1.0e6 / f))
#define DEF_CAPTURE_RATE         FPS_TO_MS(DEF_CAPTURE_FPS)
#define MIN_CAPTURE_RATE         FPS_TO_MS(MIN_CAPTURE_FPS)
#define MAX_CAPTURE_RATE         FPS_TO_MS(MAX_CAPTURE_FPS)

//standard index size options
#define CAP_LARGE_INDEX          (30 * 60 * 60 * 3)	// 3 hrs @ 30fps
#define CAP_SMALL_INDEX          (30 * 60 * 15)	// 15 minutes @ 30fps

#define ONEMEG                   (1024L * 1024L)

#ifndef AVSTREAMMASTER_AUDIO
#define AVSTREAMMASTER_AUDIO            0	/* Audio master (VFW 1.0, 1.1) */
#endif
#ifndef AVSTREAMMASTER_NONE
#define AVSTREAMMASTER_NONE             1	/* No master */
#endif

// class
class CCapture {
  public:
    int isCapturingNow();
     CCapture();
     virtual ~ CCapture();

    BOOL createWindow(char *appTitle, HWND hwndParent, ICaptureListener * captureListener);

    // status 
    BOOL hasOverlay();
    BOOL getOverlay();
    void setOverlay(BOOL value);

    BOOL hasHardware();
    BOOL hasAudioHardware();
    BOOL hasDlgVideoFormat();
    BOOL hasDlgVideoSource();
    BOOL hasDlgVideoDisplay();

    BOOL openDlgVideoFormat();
    BOOL openDlgVideoSource();
    BOOL openDlgVideoDisplay();
    BOOL openDlgVideoCompression();
    BOOL initHardware(UINT uIndex);

    BOOL suppliesPalette();
    unsigned int getImageWidth();
    unsigned int getImageHeight();
    unsigned long getVideoFormatSize();
    unsigned long getVideoFormat(BITMAPINFO * pbi, int size);
    void getCurrentStatus(unsigned long *currentVideoFrame, unsigned long *currentTimeElapsedMS);


    // capture parameters
    void getCaptureFileName(char *fileName, int maxSize);
    void setCaptureFileName(char *fileName);
    long getCaptureFileSize();
    void setCaptureFileSize(long value);
    BOOL allocCaptureFileSpace(long fileSize);
    BOOL allocFileSpace();
    BOOL getLimitEnabled();
    void setLimitEnabled(BOOL value);
    BOOL getCaptureAudio();
    void setCaptureAudio(BOOL value);
    BOOL getCaptureToDisk();
    void setCaptureToDisk(BOOL value);
    unsigned long getCaptureRate();
    void setCaptureRate(unsigned long value);
    unsigned int getTimeLimit();
    void setTimeLimit(unsigned int value);
    unsigned int getStepCaptureAverageFrames();
    void setStepCaptureAverageFrames(unsigned int value);
    unsigned long getIndexSize();
    void setIndexSize(unsigned long value);
    BOOL getStepCaptureAt2x();
    void setStepCaptureAt2x(BOOL value);
    void setAudioFormat(LPWAVEFORMATEX value);
    LPWAVEFORMATEX getAudioFormat();
    DWORD getAudioFormatSize();
    unsigned int getAVStreamMaster();
    void setAVStreamMaster(unsigned int value);

    // Preview parameters and commands
    void setPreviewRate(int rate);
    void setPreviewScale(BOOL scale);
    BOOL isPreviewEnabled();
    BOOL setPreview(BOOL value);

    // single frame capture 
    BOOL singleFrameCaptureOpen();
    BOOL singleFrameCaptureClose();
    BOOL singleFrameCapture();
    BOOL grabFrameNoStop();
    BOOL grabFrame();
    BOOL saveDIBFile(char *fileName);

    // AVI capture command
    BOOL startCapture(void);
    BOOL startCaptureNoFile(FARPROC callback, long userData);
    BOOL abortCapture(void);

    //  MCI control command
    BOOL getMCIControl();
    void setMCIControl(BOOL value);
    void getMCIDeviceName(char *fileName, int maxSize);
    void setMCIDeviceName(char *fileName);
    BOOL getStepMCIDevice();
    void setStepMCIDevice(BOOL value);
    unsigned long getMCIStartTime();
    void setMCIStartTime(unsigned long value);
    unsigned long getMCIStopTime();
    void setMCIStopTime(unsigned long value);

    //palette
    HPALETTE getPalette();
    BOOL isUsingDefaultPalette();
    BOOL openPalette(char *paletteFileName);
    BOOL savePalette(char *paletteFileName);
    void setPaletteManual(BOOL fGrab, int iColors);
    long setNewPalette();

    // window position
    void getWindowPosition(RECT * pRect);
    void setWindowPosition(RECT * pRect);
    void setScrollPos(POINT * pt);
    void mapWindowPoints(HWND mainWindow, LPPOINT lpPoints, UINT cPoints);
    HWND getHwndCapture();

    // clipboard functions
    void editCopy(void);
    void palettePaste(void);

    //callbacks
    WNDPROC setPreviewWindowCallbackProc(WNDPROC callbackProc, long userData);
    //void            setErrorCallbackProc(LPVOID newCallbackProc);
    //void            setStatusCallbackProc(LPVOID newCallbackProc, long userData);
    int setStatusMessage(int statusType, char *message);


    static long getCallbackUserData(HWND hwnd, int position);

     protected:HWND hwndCap;
    char *appTitle;
    ICaptureListener *captureListener;

    CAPSTATUS capStatus;
    CAPDRIVERCAPS capDriverCaps;
    CAPTUREPARMS capParms;
    LPWAVEFORMATEX lpwfex;
    BOOL bHaveHardware;
    unsigned int wDeviceIndex;

    static LRESULT FAR PASCAL errorCallbackProc(HWND hWnd, int nErrID, LPSTR lpErrorText);
    static LRESULT FAR PASCAL statusCallbackProc(HWND hWnd, int nID, LPSTR lpStatusText);
    long userDataTablePtr[4];
    int setCallbackUserData(int position, long newUserData);


};

#endif				// !defined(AFX_CAPTURE_H__15DE327D_A32E_45E9_ABA6_FAA48FD17C91__INCLUDED_)