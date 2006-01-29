// GuidingCapture.cpp: implementation of the CGuidingCapture class.
//
//////////////////////////////////////////////////////////////////////

#include <windows.h>
#include "GuidingCapture.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CGuidingCapture::CGuidingCapture(CCapture * capture)
{
    this->capture = capture;

    oldGuidingPreviewCallback = NULL;

    targetSize     = 40;
    bGuidingStarted = FALSE;
    x0 = capture->getImageWidth() /2;
    y0 = capture->getImageHeight() /2;

    listener = NULL;
    
}

CGuidingCapture::~CGuidingCapture()
{

}

/**
 * startGuidingCapture
 *
 *
 */
int CGuidingCapture::startGuiding() {
    int result = TRUE;

    bGuidingStarted = TRUE;


    return result;
}


/**
 * stopGuidingCapture
 *
 *
 */
 
int CGuidingCapture::stopGuiding() {
    int result = TRUE;
    bGuidingStarted = FALSE;
    return result;
}



/**
 *  guidingCaptureCallbackProc
 *  this callback is called after capturing each frame 
 *
 *  hWnd:            Application main window handle
 *  vhdr:            video header
 */
LRESULT CALLBACK  CGuidingCapture::guidingCaptureCallbackProc(HWND hWnd, VIDEOHDR *vhdr) {
    int result = TRUE;
    
    CGuidingCapture  * thisPtr = (CGuidingCapture *)capGetUserData(hWnd);

    
    return result;
}




/***************************************************************************/

/***************************************************************************/

/**
 *----------------------------------------------------------------------
 *
 * startPreview --
 *    display a target rectangle in the preview window
 *
 * Results:
 *    none
 *
 * Side effects:
 *    changes the preview window callback.
 *
 *----------------------------------------------------------------------
 */
void CGuidingCapture::startPreview()
{
    if (oldGuidingPreviewCallback == NULL ) {
        oldGuidingPreviewCallback = capture->setPreviewWindowCallbackProc(CGuidingCapture::guidingPreviewCallbackProc, (long) this);
        //hTargetBrush = CreateSolidBrush(0x00FFFF);
        hTargetPen =  CreatePen( PS_SOLID, 0, 0x00FFFF);
    }
}

/**
 *----------------------------------------------------------------------
 *
 * stopPreview --
 *    stops drawing a cropping rectangle in the preview window
 *
 * Results:
 *    none
 *
 * Side effects:
 *    restores the preview window callback.
 *
 *----------------------------------------------------------------------
 */
void CGuidingCapture::stopPreview()
{
    if (oldGuidingPreviewCallback != NULL) {
        capture->setPreviewWindowCallbackProc(oldGuidingPreviewCallback, NULL);
        oldGuidingPreviewCallback = NULL;
        //DeleteObject(hTargetBrush);
        DeleteObject(hTargetPen);

    }
}

/**
 *----------------------------------------------------------------------
 *
 * guidingPreviewCallbackProc --
 *
 *  this callback draws a taget rectangle on the preview window
 *
 * Results:
 *  Standard WindowProc return value.
 *
 * Side effects:
 *  displays the current frame 
 *  displays target 
 *  displays origin
 *
 *----------------------------------------------------------------------
 */
LRESULT CALLBACK CGuidingCapture::guidingPreviewCallbackProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    LRESULT     result;
    HDC         hdc;
    POINT       targetRect[5];
    
    // get context object
    CGuidingCapture * thisPtr = (CGuidingCapture *) GetWindowLong(hwnd, GWL_USERDATA);
    
    switch(message) {
        case WM_PAINT:
        
            // find the brightest point in the cuurent target rectangle
            //  and notifies listeners
            hdc = GetDC(hwnd);
            result = thisPtr->findBrightestPoint( hdc );

            // displays the frame 
            result = CallWindowProc(thisPtr->oldGuidingPreviewCallback, hwnd, message, wParam, lParam);
        
            // displays the target rectangle
            SelectObject(hdc, thisPtr->hTargetPen);
            targetRect[0].x = thisPtr->targetXc - thisPtr->targetSize /2;  // top      left
            targetRect[0].y = thisPtr->targetYc - thisPtr->targetSize /2;
            targetRect[1].x = thisPtr->targetXc + thisPtr->targetSize /2;  // top      right
            targetRect[1].y = targetRect[0].y;
            targetRect[2].x = targetRect[1].x;                              // bottom   right
            targetRect[2].y = thisPtr->targetYc + thisPtr->targetSize /2; 
            targetRect[3].x = targetRect[0].x;                              // bottom   left
            targetRect[3].y = targetRect[2].y;
            targetRect[4].x = targetRect[0].x;                              // top      left
            targetRect[4].y = targetRect[0].y;
            Polyline(hdc, &targetRect[0], 5); 

            // displays the origin crosshair  
            MoveToEx(hdc, 0, thisPtr->y0, NULL);
            LineTo(hdc, thisPtr->capture->getImageWidth(), thisPtr->y0);    // horizontal line
            MoveToEx(hdc, thisPtr->x0, 0, NULL);
            LineTo(hdc, thisPtr->x0 , thisPtr->capture->getImageHeight());  // vertical line


            ReleaseDC(hwnd, hdc);
            result = FALSE;
            break;
        
        case WM_LBUTTONDOWN:             
            thisPtr->targetXc = LOWORD(lParam);
            thisPtr->targetYc = HIWORD(lParam);                
            // find the brightest point in the new target rectangle
            hdc = GetDC( hwnd);
            result = thisPtr->findBrightestPoint( hdc );
            ReleaseDC(hwnd, hdc);
            // notifies listeners
            thisPtr->resetOrigin();
            result = FALSE;
            break;
    
        default:
            result = CallWindowProc((WNDPROC)thisPtr->oldGuidingPreviewCallback, hwnd, message, wParam, lParam);
            break;
    }
    
    return result;
}


/**
 *----------------------------------------------------------------------
 *
 * findBrightestPoint --
 *
 *    finds the brightest point in the taget
 *
 * Results:
 *  Standard WindowProc return value.
 *
 * Side effects:
 *  updates targetXc, targetYc
 *  notifies guiding listeners    
 *
 *----------------------------------------------------------------------
 */
int CGuidingCapture::findBrightestPoint( HDC hdc) {
    int         x, y;
    COLORREF    colorref;
    int *       pix;
    int         valmax, xmax, ymax;
    int         pixval;
    int         areaValmax ;
    WORD        imageWidth ;
    WORD        imageHeight ;
    
    imageWidth = capture->getImageWidth();
    imageHeight = capture->getImageHeight();

    if((pix = (int*) malloc(targetSize * targetSize * sizeof(int)))==NULL) {
        //MessageBox( NULL, "Unable to Allocate Bitmap Memory", "Error", MB_OK|MB_ICONERROR);
        return 1;
    }            
    
    // je recupere la valeur des pixels dans le viseur
    for(x = 0; x < targetSize; x++ ) {
        for(y = 0; y < targetSize; y++ ) {
            colorref = GetPixel(hdc, x + targetXc - targetSize /2, y + targetYc - targetSize /2);
            pix[x+y*targetSize] = GetRValue(colorref) + GetGValue(colorref) + GetBValue(colorref);
        }
    }
    
    // je recherche la valeur la plus forte
    valmax = 0; 
    xmax = targetSize;
    ymax = targetSize;
    for(x = 1; x < targetSize -1; x++ ) {
        for(y = 1; y < targetSize -1; y++ ) {
            pixval = pix[x+y*targetSize]
                + (int) (0.2 * ( pix[x-1 +y*targetSize] + pix[x+1 +y*targetSize] 
                + pix[x  +(y+1)*targetSize] + pix[x +(y-1)*targetSize] ) );
            if ( pixval > valmax ) {
                valmax = pixval; 
                xmax = x;
                ymax = y;
            }
        }
    }
    
    areaValmax = valmax;   
    
    targetXc = xmax + targetXc - targetSize /2;
    targetYc = ymax + targetYc - targetSize /2;
    
    if (targetXc < targetSize /2  ) targetXc = targetSize /2;
    if (( targetXc + targetSize /2) > (int) imageWidth ) {
        targetXc = imageWidth - targetSize /2;
    }
    
    if (targetYc < targetSize/2 ) targetYc = targetSize/2;
    if (( targetYc + targetSize/2) > (int)imageHeight) {
        targetYc = imageHeight - targetSize/2;
    }
    
    // notify listeners
    if(listener != NULL) {
        listener->onMoveTarget(targetXc, targetYc, 0, 0);
    }
    
    return 0;
    
}

void CGuidingCapture::resetOrigin(void) {
    x0 = targetXc;
    y0 = targetYc;


    // notify listeners
    if(listener != NULL) {
        listener->onChangeOrigin(x0, y0);
    }

}

BOOL CGuidingCapture::isGuidingStarted(void) {
    return bGuidingStarted;
}

int CGuidingCapture::getTargetSize(void) {
    return targetSize;
}

void CGuidingCapture::setTargetSize(int size) {
    targetSize = size;
}



BOOL CGuidingCapture::setGuidingListener(IGuidingCaptureListener * newListener) {
    listener = newListener ;
    return TRUE;
}


