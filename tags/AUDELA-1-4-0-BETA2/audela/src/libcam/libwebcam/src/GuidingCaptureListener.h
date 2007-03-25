// GuidingCaptureListener.h: interface for the GuidingCaptureListener class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_IGUIDINGCAPTURELISTENER_H__9B5C043F_E17F_42ED_AAB8_CD1085A9FE3D__INCLUDED_)
#define AFX_IGUIDINGCAPTURELISTENER_H__9B5C043F_E17F_42ED_AAB8_CD1085A9FE3D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif				// _MSC_VER > 1000

class IGuidingCaptureListener {
  public:

    virtual void onChangeOrigin(int x0, int y0) = 0;
    virtual void onMoveTarget(int x, int y, int alphaDelay, int deltaDelay) = 0;
    virtual void onChangeGuidingStarted(int state) = 0;

};

#endif				// !defined(AFX_CGUIDINGCAPTURELISTENER_H__9B5C043F_E17F_42ED_AAB8_CD1085A9FE3D__INCLUDED_)
