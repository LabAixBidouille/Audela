// Capture.cpp: implementation of the CCapture class.
//
//////////////////////////////////////////////////////////////////////

#include "Capture.h"

#include <stdio.h>

// macros
#define WIDTHBYTES(bits)        (((bits) + 31) / 32 * 4)


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCapture::CCapture()
{
   lpwfex = NULL;
   bHaveHardware = FALSE;
}

CCapture::~CCapture()
{
   
   if (lpwfex  != NULL ) {
      //GlobalFree(lpwfex) ;
   }
   
   capPreview(hwndCap, FALSE);
   
   
   //capSetCallbackOnYield(hwndCap, NULL) ;
   
   // Disconnect the current capture driver
   if( bHaveHardware == TRUE ) {
      capDriverDisconnect (hwndCap);
   }
   
   DestroyWindow(hwndCap);
   
}

/**
*----------------------------------------------------------------------
*
* create an instance of CCapture
*
*----------------------------------------------------------------------
*/
BOOL CCapture::createWindow(char * appTitle, HWND hwndParent, ICaptureListener *captureListener)
{
   
   this->appTitle = appTitle;
   this->captureListener = captureListener;
   
   // create a capture window within vidframe. 
   // Leave vidframeLayout to do the layout
   hwndCap = capCreateCaptureWindow(
      NULL,
      WS_CHILD | WS_VISIBLE,
      0, 0, 160, 120,
      hwndParent,                 // parent window
      1                           // child window id
      );
   if (hwndCap == NULL) {
      return FALSE;
   }
   
   // Hides the window. It will be automatically shown when preview will start
   ShowWindow(hwndCap, SW_HIDE);
   
   // Get the default setup for video capture from the AVICap window
   capCaptureGetSetup(hwndCap, &capParms, sizeof(CAPTUREPARMS)) ;
   
   // set the context object used by callback functions
   capSetUserData(hwndCap, (long) userDataTablePtr);
   setCallbackUserData(0, (long) this);
   
   // declare callback functions
   capSetCallbackOnError(hwndCap,  errorCallbackProc) ;
   capSetCallbackOnStatus(hwndCap, statusCallbackProc) ;
   
   return TRUE;
   
}


/**
*----------------------------------------------------------------------
*
* accessors
*
*----------------------------------------------------------------------
*/

unsigned int     CCapture::getImageWidth(){ 

   BITMAPINFO bi;
   int   formatSize;
   
   formatSize = capGetVideoFormatSize(hwndCap);

   getVideoFormat(&bi, formatSize);
   return bi.bmiHeader.biWidth;
   //return capStatus.uiImageWidth  ; 

}

unsigned int     CCapture::getImageHeight() { 
   BITMAPINFO bi;
   int   formatSize;
   
   formatSize = capGetVideoFormatSize(hwndCap);
   getVideoFormat(&bi, formatSize);
   return bi.bmiHeader.biHeight;
   //return capStatus.uiImageHeight ; 

}
unsigned long    CCapture::getVideoFormatSize(){ 
   return capGetVideoFormatSize(hwndCap) ; 
}

unsigned long    CCapture::getVideoFormat(BITMAPINFO * pbi, int size ) { 
   return capGetVideoFormat(hwndCap, pbi, size);
}


void CCapture::getCurrentStatus(unsigned long * pcurrentVideoFrame, unsigned long * pcurrentTimeElapsedMS ){ 
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS));
   *pcurrentVideoFrame    =  capStatus.dwCurrentVideoFrame ; 
   *pcurrentTimeElapsedMS =  capStatus.dwCurrentTimeElapsedMS;
}


/**
*----------------------------------------------------------------------
*
* Windows Video capture core fonctions
*
*----------------------------------------------------------------------
*/

BOOL    CCapture::hasAudioHardware( ){ return capStatus.fAudioHardware  ; }

BOOL CCapture::isPreviewEnabled()  { 
   return capStatus.fLiveWindow;
}
BOOL CCapture::setPreview(BOOL value) {
   BOOL result;
   result = capPreview(hwndCap, value) ;
   if( value == TRUE ) {
      ShowWindow(hwndCap, SW_SHOW);
   } else {
      ShowWindow(hwndCap, SW_HIDE);
   }
   
   // update local capStatus
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS));    
   return result;
}

BOOL CCapture::getOverlay()  { 
   return capStatus.fOverlayWindow;
}
void CCapture::setOverlay(BOOL value) {
   capOverlay(hwndCap, value) ;   
   // update local capStatus
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
}

LPWAVEFORMATEX  CCapture::getAudioFormat() {
   DWORD        dwSize ;
   if ( lpwfex == NULL ) {
      dwSize = capGetAudioFormatSize (hwndCap);  
      lpwfex = (LPWAVEFORMATEX) GlobalAlloc(GHND, dwSize) ;
   }
   capGetAudioFormat(hwndCap, lpwfex, (WORD)dwSize) ;
   return lpwfex; 
}

void  CCapture::setAudioFormat(LPWAVEFORMATEX value) {  
   DWORD       dwSize ;
   
   dwSize = capGetAudioFormatSize (hwndCap);  
   capSetAudioFormat(hwndCap, value, (WORD)dwSize) ;
}

DWORD  CCapture::getAudioFormatSize(){  
   return capGetAudioFormatSize (hwndCap);  
}

void CCapture::setPreviewRate(int rate){ 
   capPreviewRate(hwndCap, rate);
}

void CCapture::setPreviewScale(BOOL scale){ 
   capPreviewScale(hwndCap, scale);
}

void CCapture::getCaptureFileName(char * fileName, int maxSize) {
   capFileGetCaptureFile(hwndCap, fileName, maxSize) ;
}
void CCapture::setCaptureFileName(char * fileName) {
   capFileSetCaptureFile(hwndCap, fileName);
}

BOOL CCapture::allocCaptureFileSpace( long fileSize) {
   return capFileAlloc(hwndCap , (long) fileSize * ONEMEG);
}

unsigned long   CCapture::getCaptureRate(){ return capParms.dwRequestMicroSecPerFrame  ; }
void            CCapture::setCaptureRate(unsigned long value){ capParms.dwRequestMicroSecPerFrame  = value; }

unsigned int    CCapture::getTimeLimit(){ return capParms.wTimeLimit  ; }
void            CCapture::setTimeLimit(unsigned int value){ capParms.wTimeLimit  = value; }

BOOL            CCapture::getLimitEnabled() { return capParms.fLimitEnabled; }
void            CCapture::setLimitEnabled(BOOL value){ capParms.fLimitEnabled = value; }

BOOL            CCapture::getCaptureAudio(){ return capParms.fCaptureAudio; }
void CCapture::setCaptureAudio(BOOL value){ 
   capParms.fCaptureAudio = value; 
   capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms));
}

BOOL            CCapture::getCaptureToDisk(){ return capParms.fUsingDOSMemory  ; }
void            CCapture::setCaptureToDisk(BOOL value){ capParms.fUsingDOSMemory  = value; }

BOOL    CCapture::singleFrameCaptureOpen(){ 
   return capCaptureSingleFrameOpen(hwndCap);    
}

BOOL    CCapture::singleFrameCaptureClose(){ 
   return capCaptureSingleFrameClose(hwndCap);    
}

BOOL    CCapture::singleFrameCapture(){ 
   return capCaptureSingleFrame(hwndCap);    
}

BOOL    CCapture::grabFrameNoStop(){ 
   return capGrabFrameNoStop(hwndCap);    
}

BOOL    CCapture::getDriverName( char * driverName) { 
   return capDriverGetName(hwndCap, sizeof(driverName)-1, driverName);    
}

BOOL    CCapture::grabFrame(){ 
   return capGrabFrame(hwndCap);    
}

BOOL CCapture::saveDIBFile(char * fileName) {
   return capFileSaveDIB(hwndCap, fileName);
}


/**
*----------------------------------------------------------------------
*
* MCI control
*
*----------------------------------------------------------------------
*/
void CCapture::getMCIDeviceName(char * deviceName, int maxSize) {
   capGetMCIDeviceName(hwndCap, deviceName, maxSize) ;
}
void CCapture::setMCIDeviceName(char * deviceName) {
   capSetMCIDeviceName(hwndCap, deviceName);
}

BOOL            CCapture::getMCIControl(){ return capParms.fMCIControl  ; }
void            CCapture::setMCIControl(BOOL value){ capParms.fMCIControl  = value; }

BOOL            CCapture::getStepMCIDevice(){ return capParms.fStepMCIDevice  ; }
void            CCapture::setStepMCIDevice(BOOL value){ capParms.fStepMCIDevice  = value; }

unsigned long   CCapture::getMCIStartTime(){ return capParms.dwMCIStartTime  ; }
void            CCapture::setMCIStartTime(unsigned long value){ capParms.dwMCIStartTime  = value; }

unsigned long   CCapture::getMCIStopTime(){ return capParms.dwMCIStopTime  ; }
void            CCapture::setMCIStopTime(unsigned long value){ capParms.dwMCIStopTime  = value; }


unsigned int    CCapture::getStepCaptureAverageFrames(){ return capParms.wStepCaptureAverageFrames  ; }
void            CCapture::setStepCaptureAverageFrames(unsigned int value){ capParms.wStepCaptureAverageFrames  = value; }

BOOL            CCapture::getStepCaptureAt2x(){ return capParms.fStepCaptureAt2x  ; }
void            CCapture::setStepCaptureAt2x(BOOL value) { capParms.fStepCaptureAt2x  = value; }

unsigned long   CCapture::getIndexSize(){ return capParms.dwIndexSize  ; }
void            CCapture::setIndexSize(unsigned long value){ capParms.dwIndexSize  = value; }

unsigned int    CCapture::getAVStreamMaster(){ return capParms.AVStreamMaster  ; }
void            CCapture::setAVStreamMaster(unsigned int value){ capParms.AVStreamMaster  = value; }



/**
*----------------------------------------------------------------------
*
* palette
*
*----------------------------------------------------------------------
*/
HPALETTE        CCapture::getPalette() { return capStatus.hPalCurrent; }
BOOL            CCapture::isUsingDefaultPalette() { return capStatus.fUsingDefaultPalette;}
BOOL CCapture::openPalette(char * paletteFileName) {
   return capPaletteOpen(hwndCap, paletteFileName);
}

BOOL CCapture::savePalette(char * paletteFileName) {
   return capPaletteSave(hwndCap, paletteFileName);
}

long CCapture::setNewPalette() {
   if (hwndCap != NULL) {
      return SendMessage(hwndCap, WM_QUERYNEWPALETTE, NULL, NULL);
   } else { 
      return NULL;
   }
}

void CCapture::setPaletteManual(BOOL fGrab , int iColors) {
   capPaletteManual(hwndCap, fGrab, iColors);
}


/**
*----------------------------------------------------------------------
*
* clipboard
*
*----------------------------------------------------------------------
*/
void CCapture::editCopy() {
   capEditCopy(hwndCap);
}

void CCapture::palettePaste() {
   capPalettePaste(hwndCap);
}


/**
*----------------------------------------------------------------------
*
* capabilities
*
*----------------------------------------------------------------------
*/

BOOL CCapture::hasOverlay() {
   return capDriverCaps.fHasOverlay;
}

BOOL CCapture::hasDlgVideoFormat() {
   return capDriverCaps.fHasDlgVideoFormat;
}

BOOL CCapture::hasDlgVideoSource() {
   return capDriverCaps.fHasDlgVideoSource;
}

BOOL CCapture::hasHardware() {
   return bHaveHardware;
}

BOOL CCapture::suppliesPalette() {
   return capDriverCaps.fDriverSuppliesPalettes;
}

/**
*----------------------------------------------------------------------
*
* window position
*
*----------------------------------------------------------------------
*/

void CCapture::setScrollPos(POINT *pt) {
   if( hwndCap != NULL) {
      capSetScrollPos(hwndCap, pt);    
   }
}

void CCapture::getWindowPosition(RECT *pRect) {
   GetWindowRect(hwndCap, pRect);
}

void CCapture::setWindowPosition(RECT *pRect) {
   MoveWindow(
      hwndCap,
      pRect->left, 
      pRect->top,         
      pRect->right - pRect->left,
      pRect->bottom - pRect->top,
      TRUE
      );
}

void CCapture::mapWindowPoints(HWND mainWindow, LPPOINT lpPoints, UINT cPoints ) {
   MapWindowPoints(hwndCap, mainWindow, lpPoints,cPoints);
}

HWND CCapture::getHwndCapture() {
   return hwndCap;
}

/**
*----------------------------------------------------------------------
*
* configuration dialogs
*
*----------------------------------------------------------------------
*/
BOOL CCapture::openDlgVideoFormat() {
   BOOL result ;
   
   result = capDlgVideoFormat(hwndCap);
   if (result) {  
      // If successful,
      // Get the new image dimension and center capture window
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;         
}

BOOL CCapture::openDlgVideoSource() {
   BOOL result ;
   
   result = capDlgVideoSource(hwndCap);
   if (result) {  
      // If successful,
      // Get the new image dimension and center capture window
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;         
}

BOOL CCapture::hasDlgVideoDisplay() {
   return capDriverCaps.fHasDlgVideoDisplay;
}

BOOL CCapture::openDlgVideoDisplay() {
   BOOL result ;
   
   result = capDlgVideoDisplay(hwndCap);
   if (result) {  
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;         
}

BOOL CCapture::openDlgVideoCompression() {
   BOOL result ;
   
   result = capDlgVideoCompression(hwndCap);
   if (result) {  
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;         
}



BOOL CCapture::initHardware(UINT uIndex) {
   UINT    uError ;
   
 
   // Try connecting to the capture drive r
   if (uError = capDriverConnect(hwndCap, uIndex)) {
      bHaveHardware = TRUE;
      wDeviceIndex = uIndex;
   }
   else {
      bHaveHardware = FALSE;
   }
   
   // Get the capabilities of the capture driver
   capDriverGetCaps(hwndCap, &capDriverCaps, sizeof(CAPDRIVERCAPS)) ;
   
   // Get the settings for the capture window
   capGetStatus(hwndCap, &capStatus , sizeof(CAPSTATUS));
   
   return bHaveHardware;
}


/**
 * allocFileSpace
 *
 *
 */
BOOL CCapture::allocFileSpace() {
   BOOL                result ;
   long                fileSize;
   int                 formatSize;
   BITMAPINFOHEADER    bih;
   
   // allocate file space
   // get video format of capture device
   if ((formatSize = capGetVideoFormatSize(hwndCap))<=0) { 
      return FALSE;
   }
   if (formatSize > sizeof(bih)) { 
      return FALSE;  // Format too large 
   }
   if (!capGetVideoFormat(hwndCap, &bih, formatSize)){
      return -1;
   }
   
   fileSize = capParms.wTimeLimit * (long) ( (1e6 / capParms.dwRequestMicroSecPerFrame) + 0.5) * bih.biSizeImage  ;
   result = capFileAlloc(hwndCap , fileSize );
   
   return result;
}


/**
 *----------------------------------------------------------------------
 * startCapture
 *    starts streaming video capture with default saving method
 *    !!file space allocation must be done before calling startCaptureNoFile 
 *
 * Parameters: 
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    allocate file space
 *    starts the capture sequence with saving file
 *----------------------------------------------------------------------
 */
BOOL CCapture::startCapture() {
   BOOL result ;
   
   // set the defaults we won't bother the user with
   // Don't ask capture confirmation
   capParms.fMakeUserHitOKToCapture = FALSE; 
   capParms.wPercentDropForError = 10;   
   // If "CapturingToMemory", get as many buffers as we can.
   //capParms.wNumVideoRequested = capParms.fUsingDOSMemory ? 32 : 1000;
   capParms.wNumVideoRequested = 64;
   // touche pour interrompre la capture
   capParms.vKeyAbort = VK_ESCAPE; 
   // interdit l'arret la capture avec le boutton gauche de la souris
   capParms.fAbortLeftMouse = FALSE; 
   // interdit l'arret la capture avec le boutton gauche de la souris
   capParms.fAbortRightMouse = FALSE; 
   
   //--- inutilise par Windows         
   //captureParams.fUsingDOSMemory; 
   //captureParams.fDisableWriteCache; 
   
   //--- parametres pour controle MCI inutilises
   //captureParams.fStepMCIDevice; 
   //captureParams.dwMCIStartTime; 
   //captureParams.dwMCIStopTime; 
   //captureParams.fStepCaptureAt2x; 
   //captureParams.wStepCaptureAverageFrames; 
   capParms.AVStreamMaster = AVSTREAMMASTER_NONE; 
   // Don't abort on the left mouse anymore!
   capParms.fAbortLeftMouse = FALSE;
   capParms.fAbortRightMouse = FALSE;
   // allows 10% dropped frames
   capParms.wPercentDropForError = 10; 
   // If wChunkGranularity is zero, the granularity will be set to the
   // disk sector size.(default=0)
   capParms.wChunkGranularity = 0 ;
   // fUsingDefaultPalette will be TRUE even if the
   // current capture format is non-palettised. This is a
   // bizarre decision of Jay's.
   capStatus.fUsingDefaultPalette = TRUE;
   // allocate file space 
   allocFileSpace();
   // allow yield 
   capParms.fYield = TRUE;   // callbacks won't work if Yield is TRUE
   capSetCallbackOnYield(hwndCap, TRUE);   
   // register capture params
   capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms)) ;
   // start capture with saving file 
   result = capCaptureSequence(hwndCap);
    
   return result;
}


/**
 *----------------------------------------------------------------------
 * startCaptureNoFile
 *    starts streaming video capture. Frame are processed by a specific callback
 *    !!file space allocation must be done before calling startCaptureNoFile 
 *
 * Parameters: 
 *    callback : specific callback  (see capSetCallbackOnVideoStream documentation)
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    declare the specific callback on video stream
 *    starts the capture sequence with no file
 *----------------------------------------------------------------------
 */
BOOL CCapture::startCaptureNoFile(FARPROC  callback, long userData) {
   BOOL                result ;
   
   // set the defaults we won't bother the user with
   capParms.fMakeUserHitOKToCapture = !capParms.fMCIControl;
   capParms.wPercentDropForError = 10;  
   capParms.wNumVideoRequested = 64;
   
   // Don't abort on the left mouse anymore!
   capParms.fAbortLeftMouse = FALSE;
   capParms.fAbortRightMouse = TRUE;
   
   // If wChunkGranularity is zero, the granularity will be set to the
   // disk sector size.
   capParms.wChunkGranularity = 32 ;
   capParms.fYield = FALSE;   // callbacks won't work if Yield is TRUE      
   capSetCallbackOnYield(hwndCap, NULL);
   
   // fUsingDefaultPalette will be TRUE even if the
   // current capture format is non-palettised. This is a
   // bizarre decision of Jay's.
   capStatus.fUsingDefaultPalette = TRUE;
   
   //result = capSetUserData(hwndCap, (long) userData);
   result = setCallbackUserData(1,userData);
   
   if( result == TRUE ) {
      // set the callback
      result = capSetCallbackOnVideoStream(hwndCap, callback);
      if( result == TRUE ) {
         // register capture params
         capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms)) ;
         // capture now  
         result = capCaptureSequenceNoFile(hwndCap);
         capCaptureStop(hwndCap);
      }
   }
   
   // reset callback 
   result = capSetCallbackOnVideoStream(hwndCap, NULL);
   
   // restore params
   capParms.fYield = TRUE;   // callbacks won't work if Yield is TRUE
   capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms)) ;
   
   return result;
}

/**
 *----------------------------------------------------------------------
 * abortCapture
 *    abort the current capture
 *
 * Parameters: 
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    halt step capture at the current position
 *----------------------------------------------------------------------
 */
BOOL CCapture::abortCapture() {
   return capCaptureAbort(hwndCap);
}

/**
 *----------------------------------------------------------------------
 * isCapturingNow
 *    return TRUE if capture is running
 *
 * Parameters: 
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    refresh capStatus structure 
 *
 *----------------------------------------------------------------------
 */
int CCapture::isCapturingNow()
{
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS));
   return capStatus.fCapturingNow;
}


/**
 *----------------------------------------------------------------------
 * readFrame
 *    
 *
 * Parameters: 
 *    rgbBuffer : must be allocated 
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    
 *
 *----------------------------------------------------------------------
 */
int CCapture::readFrame( unsigned char * rgbBuffer)
{
   int result = FALSE;

   if( rgbBuffer != NULL ) {
      grabBuffer = rgbBuffer;
      // enable grab callback
      result = capSetCallbackOnFrame(hwndCap, grabFrameCallbackProc);
      if (result == TRUE)  {
         // execute grab callback
         //result = grabFrameNoStop(); 
         result = grabFrameNoStop(); 
         //result = grabFrame();
         // disable grab callback
         capSetCallbackOnFrame(hwndCap, NULL);
      }
   }
   return result;
}

/**
 *  grabFrameCallbackProc
 *  this callback is called after capturing each frame 
 *
 *  hWnd:            Application main window handle
 *  vhdr:            video header
 * Side effects:
 *    converts I420 frame to DIB frame with ICDecompress standard function
 *    crops DIB frame 
 *    save the cropped frame into AVI file
 *    display frame count in the status bar with capture->setStatusMessage()
 */
LRESULT CALLBACK  CCapture::grabFrameCallbackProc(HWND hWnd, VIDEOHDR *vhdr) {
    int        result;
    BITMAPINFO inputbi;
    BITMAPINFO tempbi;
    int        inputFormatSize = NULL;
    HIC        hic;
//    HDC        hdc;
//    HBITMAP    htempBitmap;

    
    CCapture  * capture = (CCapture *) CCapture::getCallbackUserData(hWnd, 0);

    if(capture->grabBuffer == NULL ) {
       // grabBuffer must be allocated yet
       return FALSE;
    }

    if ((inputFormatSize = capture->getVideoFormatSize())<=0) {
        return FALSE;
    }

    if (inputFormatSize > sizeof(inputbi)) // Format too large? 
        return FALSE; 


    if (!capture->getVideoFormat(&inputbi, inputFormatSize)){
        return FALSE;
    }

    // prepare temporary BITMAPINFO
    tempbi.bmiHeader.biSize =           sizeof(BITMAPINFOHEADER);
    tempbi.bmiHeader.biWidth =          inputbi.bmiHeader.biWidth;
    tempbi.bmiHeader.biHeight =         inputbi.bmiHeader.biHeight;
    tempbi.bmiHeader.biPlanes =         1;
    tempbi.bmiHeader.biBitCount =       24;
    tempbi.bmiHeader.biCompression =    BI_RGB;        // BI_RGB=0;
    tempbi.bmiHeader.biSizeImage =      WIDTHBYTES((DWORD)tempbi.bmiHeader.biWidth * tempbi.bmiHeader.biBitCount) * tempbi.bmiHeader.biHeight;
    tempbi.bmiHeader.biXPelsPerMeter =  0;
    tempbi.bmiHeader.biYPelsPerMeter =  0;
    tempbi.bmiHeader.biClrImportant =   0;
    tempbi.bmiHeader.biClrUsed =        0;    // no palette
    // alloc buffers
    //grabBuffer = (unsigned char *) GlobalAlloc(GMEM_FIXED, tempbi.bmiHeader.biSizeImage ); 

  /*
  // prepare tempoprary bitmap 
    hdc = GetDC (NULL);     
    htempBitmap = CreateDIBitmap(hdc, &tempbi.bmiHeader, CBM_INIT, capture->grabBuffer, &tempbi, DIB_RGB_COLORS);
    if (htempBitmap == NULL) {
        result = FALSE;
    }
*/
    // open decompression I420(YUY2) to DIB
    hic = ICDecompressOpen(ICTYPE_VIDEO, 0, &inputbi.bmiHeader, &tempbi.bmiHeader);
    if (!hic) {   // Image dimensions outside of maximum limit
        return FALSE ;
    }

    result = ICDecompressBegin(hic, &inputbi, &tempbi);
    if (result != ICERR_OK) {
        return FALSE;
    }

    // conversion I420 to DIB
    result = ICDecompress(hic, 0, &inputbi.bmiHeader, vhdr->lpData, &tempbi.bmiHeader, capture->grabBuffer);
    if (result != ICERR_OK) {
        MessageBeep(0);
        return FALSE;
    }

    /*

    hdc = GetDC (NULL);     
    htempBitmap = CreateDIBitmap(hdc, &tempbi.bmiHeader, CBM_INIT, capture->grabBuffer, &tempbi, DIB_RGB_COLORS);
    if (htempBitmap == NULL) {
        result = FALSE;
    }

    // get bits of output bitmap  (returned value is the number of scan lines )
    result = GetDIBits(
        hdc,                                // handle to device context
        htempBitmap,                      // handle to bitmap
        0,                                  // first scan line to set in destination bitmap
        tempbi.bmiHeader.biHeight,        // number of scan lines to copy
        capture->grabBuffer,                // address of array for bitmap bits
        &tempbi,                          // address of structure with bitmap data
        DIB_RGB_COLORS                      // RGB or palette index
        );
    

    ReleaseDC(NULL, hdc);
*/
/*
    // set bitmap bits (return value is the number of scan lines copied)    
    result = SetDIBits(
        hdc,                                // handle to device context
        htempBitmap,                        // handle to bitmap
        0,                                  // starting scan line
        tempbi.bmiHeader.biHeight,          // number of scan lines
        capture->grabBuffer,                // array of bitmap bits
        &tempbi,                            // address of structure with bitmap data
        DIB_RGB_COLORS                      // type of color indexes to use
        );

    ReleaseDC(NULL, hdc);
*/
    if ( hic) {
        ICDecompressEnd(hic); 
        ICClose(hic);
        hic = NULL;
    }
    
    return TRUE;
}



/**
*----------------------------------------------------------------------
*
* setPreviewWindowCallbackProc
*
*  callbackProc:  new callback proc
*  userData:      userdata used by the callback 
*----------------------------------------------------------------------
*/

WNDPROC CCapture::setPreviewWindowCallbackProc(WNDPROC callbackProc,long userData){
   SetWindowLong(hwndCap, GWL_USERDATA, userData);
   return (WNDPROC)SetWindowLong(hwndCap, GWL_WNDPROC,(DWORD) callbackProc);
}


/**
*----------------------------------------------------------------------
*
* setCallbackUserData
*
*  callbackProc:  new callback proc
*----------------------------------------------------------------------
*/
int CCapture::setCallbackUserData(int position, long newUserData){
   
   if( newUserData != NULL ) {
      userDataTablePtr[position] = newUserData;
   } else { 
      userDataTablePtr[position] = newUserData;
   }
   
   return TRUE;
}

/**
*----------------------------------------------------------------------
*
* getCallbackUserData
*
*  callbackProc:  new callback proc
*----------------------------------------------------------------------
*/
long CCapture::getCallbackUserData(HWND hwnd, int position){
   
   
   long * tablePtr =  (long*) capGetUserData(hwnd);
   long ptr = (long) (tablePtr[position]);
   return ptr;
}

/**
 * errorCallbackProc
 *    process error messages
 * Parameters:
 *    hWnd:           Application main window handle
 *    nErrID:         Error code for the encountered error
 *    lpErrorText:    Error text string for the encountered error
 * Results:
 *    TRUE or FALSE
 * Side effects:
 *    call captureListener->onNewError  
 */
LRESULT FAR PASCAL CCapture::errorCallbackProc(HWND hWnd, int nErrID, LPSTR lpErrorText)
{
   int result;
   CCapture * thisPtr = (CCapture *) CCapture::getCallbackUserData(hWnd, 0);

   if (thisPtr->captureListener != NULL && nErrID!=0) {
      result = thisPtr->captureListener->onNewError(nErrID, lpErrorText);
   } else {
      result = TRUE;
   }
   return result ;
}


/**
 * statusCallbackProc
 *    process status messages
 *       IDS_CAP_BEGIN
 *       IDS_CAP_STAT_CAP_INIT
 *       IDS_CAP_SEQ_MSGSTOP        
 *       IDS_CAP_STAT_VIDEOCURRENT (un message par trame)
 *       IDS_CAP_STAT_CAP_FINI     (un message par trame)
 *       IDS_CAP_STAT_VIDEOONLY
 *       IDS_CAP_END
 * Parameters:
 *    hWnd:           Application main window handle
 *    nID:            Status code for the current status
 *    lpStatusText:   Status text string for the current status
 * Results:
 *    TRUE or FALSE
 * Side effects:
 *    call captureListener->onNewStatus   
 */
LRESULT FAR PASCAL CCapture::statusCallbackProc(HWND hWnd, int nID, LPSTR lpStatusText)
{
   int result;
   CCapture * thisPtr = (CCapture *) CCapture::getCallbackUserData(hWnd, 0);

   if (thisPtr->captureListener != NULL ) {
      result = thisPtr->captureListener->onNewStatus(nID, lpStatusText);
   } else {
      result = TRUE;
   }
   
   return result;
}




/**
 * setStatusMessage
 *    transmit message status
 *    This method is used by specific callback on video stream
 * Parameters:
 *    statusType:    Status code for the current status
 *    message:       Status text string for the current status
 * Results:
 *    TRUE or FALSE
 * Side effects:
 *    call captureListener->onNewStatus   
 */

int CCapture::setStatusMessage( int statusType, char * message ) {

   return captureListener->onNewStatus(statusType, message);

}
