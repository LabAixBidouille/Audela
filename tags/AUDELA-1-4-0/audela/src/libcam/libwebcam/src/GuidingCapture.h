// GuidingCapture.h: interface for the CGuidingCapture class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_GUIDINGCAPTURE_H__8F19E0F0_6A65_4531_97B5_A4FBB1C6BECC__INCLUDED_)
#define AFX_GUIDINGCAPTURE_H__8F19E0F0_6A65_4531_97B5_A4FBB1C6BECC__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif				// _MSC_VER > 1000


#include "Capture.h"
#include "GuidingCaptureListener.h"

#define   MAX_LISTENER_NB  10

class CGuidingCapture {
  public:
    CGuidingCapture(CCapture * capture);
    virtual ~ CGuidingCapture();

    void startPreview(void);
    void stopPreview(void);

    int startGuiding(void);
    int stopGuiding(void);

    void resetOrigin(void);
    BOOL isGuidingStarted(void);
    int getTargetSize();
    void setTargetSize(int size);

    static LRESULT CALLBACK guidingPreviewCallbackProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
    static LRESULT CALLBACK guidingCaptureCallbackProc(HWND hwnd, VIDEOHDR * vhdr);

    BOOL setGuidingListener(IGuidingCaptureListener * listener);

     protected: CCapture * capture;
    BOOL bGuidingStarted;

    int targetSize;
    int targetXc;		// target center
    int targetYc;

    int x0;			// origin center
    int y0;
    IGuidingCaptureListener *listener;

    int findBrightestPoint(HDC hdc);
    HBRUSH hTargetBrush;
    HPEN hTargetPen;

    WNDPROC oldGuidingPreviewCallback;
};

#endif				// !defined(AFX_GUIDINGCAPTURE_H__8F19E0F0_6A65_4531_97B5_A4FBB1C6BECC__INCLUDED_)
