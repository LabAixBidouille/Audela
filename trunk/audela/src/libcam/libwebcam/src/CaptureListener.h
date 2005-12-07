// IStatusBar.h: interface for the IStatusBar class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ICAPTURELISTENER_H__A42D6880_78AD_42AD_AB5D_6D1BE7B7DAD4__INCLUDED_)
#define AFX_ICAPTURELISTENER_H__A42D6880_78AD_42AD_AB5D_6D1BE7B7DAD4__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif				// _MSC_VER > 1000

class ICaptureListener {
  public:
    virtual int onNewStatus(int statusID, char *message) = 0;
    virtual int onNewError(int errID, char *message) = 0;
};

#endif				// !defined(AFX_ICAPTURELISTENER_H__A42D6880_78AD_42AD_AB5D_6D1BE7B7DAD4__INCLUDED_)
