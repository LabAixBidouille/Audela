/*

  Copyright (c) 2002 Finger Lakes Instrumentation (FLI), L.L.C.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

        Neither the name of Finger Lakes Instrumentation (FLI), LLC
        nor the names of its contributors may be used to endorse or
        promote products derived from this software without specific
        prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  ======================================================================

  Finger Lakes Instrumentation, L.L.C. (FLI)
  web: http://www.fli-cam.com
  email: support@fli-cam.com

*/

#include <errno.h>

#include "..\libfli-libfli.h"
#include "..\libfli-debug.h"
#include "libfli-sys.h"
#include <winioctl.h>
#include "libfli-usb.h"
#include "ezusbsys.h"

enum
{
	FLI_DIRECTION_UNKNOWN = 0,
	FLI_DIRECTION_READ,
	FLI_DIRECTION_WRITE
};

/* #define _USETHREAD_ */

static LARGE_INTEGER time = { -1 };

static DWORD WINAPI usbbulkio(LPVOID _iob)
{
	fliiob_t *iob = _iob;
	flidev_t dev = iob->dev;
	DWORD retval = 0;
	unsigned long tlen = 0;
	LARGE_INTEGER btime, etime, freq;
	double dtime;

	if(iob->pipe.pipeNum == FLI_PIPE_WRITE)
	{
		debug(FLIDEBUG_INFO, "IOW: dev: %02x, len: %04x : [%02x %02x %02x %02x]",
			iob->dev, *iob->len,
			((unsigned char *) iob->buf)[0],
			((unsigned char *) iob->buf)[1],
			((unsigned char *) iob->buf)[2],
			((unsigned char *) iob->buf)[3]);
	}

	QueryPerformanceCounter(&btime);
	if(iob->len > 0)
	{
		retval = DeviceIoControl(((fli_io_t *)DEVICE->io_data)->fd,
														 iob->ioctl_code,
														 &iob->pipe,
														 sizeof(iob->pipe),
														 iob->buf,
														 *iob->len,
														 &tlen,
														 NULL);
		*iob->len = tlen;
	}
	QueryPerformanceCounter(&etime);
	QueryPerformanceFrequency(&freq);

	if(iob->pipe.pipeNum == FLI_PIPE_READ)
	{
		debug(FLIDEBUG_INFO, "IOR: dev: %02x, len: %04x : [%02x %02x %02x %02x]",
			iob->dev, *iob->len,
			((unsigned char *) iob->buf)[0],
			((unsigned char *) iob->buf)[1],
			((unsigned char *) iob->buf)[2],
			((unsigned char *) iob->buf)[3]);
	}

	dtime = ((double) etime.QuadPart - (double) btime.QuadPart ) / (double) freq.QuadPart;
	debug(FLIDEBUG_INFO, "    ret: %02x, len: %04x, dtime: %5.6f",
		retval, tlen, dtime);

	return (retval == 0)?-EIO:0;
}

static long _usbio(flidev_t dev, void *buf, long *len, long dir)
{
	fliiob_t iob;

#ifdef _USETHREAD_
	DWORD ThreadId, ret;
	DWORD ThreadExitCode;
	HANDLE hThread;
	BOOL retval;
#endif

	iob.dev = dev;
	iob.buf = buf;
	iob.len = len;

	switch(dir)
	{
		case FLI_DIRECTION_READ:
			iob.ioctl_code = IOCTL_EZUSB_BULK_READ;
			iob.pipe.pipeNum = FLI_PIPE_READ;
			break;

		case FLI_DIRECTION_WRITE:
			iob.ioctl_code = IOCTL_EZUSB_BULK_WRITE;
			iob.pipe.pipeNum = FLI_PIPE_WRITE;
			break;

		default:
			return -EINVAL;
	}

#ifdef _USETHREAD_
	hThread = CreateThread(NULL, 0, usbbulkio, &iob, 0, &ThreadId);
	if(hThread == NULL)
	{
		debug(FLIDEBUG_INFO, "Could not create read I/O thread, error: %d", GetLastError());
		return -EIO;
	}

	switch (WaitForSingleObject(hThread, DEVICE->io_timeout))
	{
		case WAIT_TIMEOUT:
		{
			HANDLE hfile = CreateFile(DEVICE->name,
		                            GENERIC_WRITE,
		                            FILE_SHARE_WRITE,
		                            NULL,
		                            OPEN_EXISTING,
		                            0,
		                            NULL);

			if(hfile == INVALID_HANDLE_VALUE)
			{
				debug(FLIDEBUG_WARN, "Could not open to abort pipe!");
				return -EIO;
			}

			debug(FLIDEBUG_WARN, "I/O read timeout, aborting pipe.");
			retval = DeviceIoControl(hfile,
															 IOCTL_Ezusb_ABORTPIPE,
															 &iob.pipe.pipeNum,
															 sizeof(ULONG),
															 NULL,
															 0,
															 &ret,
															 NULL);
			CloseHandle(hfile);

			debug(FLIDEBUG_WARN, "I/O abort done.");
			if(retval == FALSE)
			{
				debug(FLIDEBUG_WARN, "Could not abort pipe, error: %d", GetLastError());
				return -EIO;
			}
			if(WaitForSingleObject(hThread, 1000) != WAIT_OBJECT_0)
			{
				debug(FLIDEBUG_WARN, "Thread did not exit, this is _really_ bad.");
				return -EIO;
			}
			break;
		}

		case WAIT_OBJECT_0:
		{
			if(GetExitCodeThread(hThread, &ThreadExitCode) == FALSE)
			{
				debug(FLIDEBUG_WARN, "Could not get thread exit code: %d", GetLastError());
				return -EIO;
			}
			return ThreadExitCode;
			break;
		}

		default:
		{
			debug(FLIDEBUG_WARN, "Error shouldn't have happened: %d.", GetLastError());
			break;
		}
	}

	if (GetExitCodeThread(hThread, &ThreadExitCode) == FALSE)
	{
		debug(FLIDEBUG_WARN, "Could not get thread exit code.");
		return -EIO;
	}

	return ThreadExitCode;
#else
	return usbbulkio(&iob);
#endif
}

static long usbbulkwrite(flidev_t dev, void *buf, long *wlen)
{
	return _usbio(dev, buf, wlen, FLI_DIRECTION_WRITE);
}

static long usbbulkread(flidev_t dev, void *buf, long *rlen)
{
	return _usbio(dev, buf, rlen, FLI_DIRECTION_READ);
}

long usbio(flidev_t dev, void *buf, long *wlen, long *rlen)
{
  int err = 0, locked = 0;
  long org_wlen = *wlen, org_rlen = *rlen;

  if ((err = fli_lock(dev)))
  {
    debug(FLIDEBUG_WARN, "Lock failed");
    goto done;
  }

  locked = 1;

  if ((err = usbbulkwrite(dev, buf, wlen)))
  {
    debug(FLIDEBUG_WARN, "Bulkwrite failed, only %d of %d bytes written",
	  *wlen, org_wlen);
    goto done;
  }

  if (*rlen > 0)
  {
    if ((err = usbbulkread(dev, buf, rlen)))
    {
      debug(FLIDEBUG_WARN, "Bulkread failed, only %d of %d bytes read",
	    *rlen, org_rlen);
      goto done;
    }
  }

 done:

  if (locked)
  {
    int r;

    if ((r = fli_unlock(dev)))
      debug(FLIDEBUG_WARN, "Unlock failed");
    if (err == 0)
      err = r;
  }

  return err;
}
