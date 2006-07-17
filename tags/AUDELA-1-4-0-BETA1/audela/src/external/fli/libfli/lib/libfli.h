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

#define DllImport  __declspec( dllimport )
#define DllExport  __declspec( dllexport )

#ifndef _LIBFLI_H_
#define _LIBFLI_H_

#include <sys/types.h>

/**
   An opaque handle used by library functions to refer to FLI
   hardware.
*/
typedef long flidev_t;

/**
   The domain of an FLI device.  This consists of a bitwise ORed
   combination of interface method and device type.  Valid interfaces
   are \texttt{FLIDOMAIN_PARALLEL_PORT}, \texttt{FLIDOMAIN_USB},
   \texttt{FLIDOMAIN_SERIAL}, and \texttt{FLIDOMAIN_INET}.  Valid
   device types are \texttt{FLIDEVICE_CAMERA},
   \texttt{FLIDOMAIN_FILTERWHEEL}, and \texttt{FLIDOMAIN_FOCUSER}.

   @see FLIOpen
   @see FLIList
 */
typedef long flidomain_t;

#define FLIDOMAIN_NONE (0x00)
#define FLIDOMAIN_PARALLEL_PORT (0x01)
#define FLIDOMAIN_USB (0x02)
#define FLIDOMAIN_SERIAL (0x03)
#define FLIDOMAIN_INET (0x04)

#define FLIDEVICE_NONE (0x000)
#define FLIDEVICE_CAMERA (0x100)
#define FLIDEVICE_FILTERWHEEL (0x200)
#define FLIDEVICE_FOCUSER (0x300)

/**
   The frame type for an FLI CCD camera device.  Valid frame types are
   \texttt{FLI_FRAME_TYPE_NORMAL} and \texttt{FLI_FRAME_TYPE_DARK}.

   @see FLISetFrameType
*/
typedef long fliframe_t;

#define FLI_FRAME_TYPE_NORMAL (0)
#define FLI_FRAME_TYPE_DARK (1)

/**
   The gray-scale bit depth for an FLI camera device.  Valid bit
   depths are \texttt{FLI_MODE_8BIT} and \texttt{FLI_MODE_16BIT}.

   @see FLISetBitDepth
*/
typedef long flibitdepth_t;

#define FLI_MODE_8BIT (0)
#define FLI_MODE_16BIT (1)

/**
   Type used for shutter operations for an FLI camera device.  Valid
   shutter types are \texttt{FLI_SHUTTER_CLOSE},
   \texttt{FLI_SHUTTER_OPEN},
   \texttt{FLI_SHUTTER_EXTERNAL_TRIGGER},
   \texttt{FLI_SHUTTER_EXTERNAL_TRIGGER_LOW}, and
   \texttt{FLI_SHUTTER_EXTERNAL_TRIGGER_HIGH}.

   @see FLIControlShutter
*/
typedef long flishutter_t;

#define FLI_SHUTTER_CLOSE (0x0000)
#define FLI_SHUTTER_OPEN (0x0001)
#define FLI_SHUTTER_EXTERNAL_TRIGGER (0x0002)
#define FLI_SHUTTER_EXTERNAL_TRIGGER_LOW (0x0002)
#define FLI_SHUTTER_EXTERNAL_TRIGGER_HIGH (0x0004)

/**
   Type used for background flush operations for an FLI camera device.  Valid
   bgflush types are \texttt{FLI_BGFLUSH_STOP} and
   \texttt{FLI_BGFLUSH_START}.

   @see FLIControlBackgroundFlush
*/
typedef long flibgflush_t;

#define FLI_BGFLUSH_STOP (0x0000)
#define FLI_BGFLUSH_START (0x0001)

/**
   Type specifying library debug levels.  Valid debug levels are
   \texttt{FLIDEBUG_NONE}, \texttt{FLIDEBUG_INFO},
   \texttt{FLIDEBUG_WARN}, and \texttt{FLIDEBUG_FAIL}.

   @see FLISetDebugLevel
*/
typedef long flidebug_t;

#define FLIDEBUG_NONE (0x00)
#define FLIDEBUG_INFO (0x01)
#define FLIDEBUG_WARN (0x02)
#define FLIDEBUG_FAIL (0x04)
#define FLIDEBUG_ALL (FLIDEBUG_INFO | FLIDEBUG_WARN | FLIDEBUG_FAIL)

#ifdef WIN32
	#ifndef LIBFLIAPI
		//#define LIBFLIAPI __declspec(dllimport) long __stdcall
		#define LIBFLIAPI __declspec(dllexport) long __stdcall
	#endif
#else
#define LIBFLIAPI long
#endif

/* Library API Function prototypes */

#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif

LIBFLIAPI FLIOpen(flidev_t *dev, char *name, flidomain_t domain);
LIBFLIAPI FLISetDebugLevel(char *host, flidebug_t level);
LIBFLIAPI FLIClose(flidev_t dev);
LIBFLIAPI FLIGetLibVersion(char* ver, size_t len);
LIBFLIAPI FLIGetModel(flidev_t dev, char* model, size_t len);
LIBFLIAPI FLIGetPixelSize(flidev_t dev, double *pixel_x, double *pixel_y);
LIBFLIAPI FLIGetHWRevision(flidev_t dev, long *hwrev);
LIBFLIAPI FLIGetFWRevision(flidev_t dev, long *fwrev);
LIBFLIAPI FLIGetArrayArea(flidev_t dev, long* ul_x, long* ul_y,
			  long* lr_x, long* lr_y);
LIBFLIAPI FLIGetVisibleArea(flidev_t dev, long* ul_x, long* ul_y,
			    long* lr_x, long* lr_y);
LIBFLIAPI FLISetExposureTime(flidev_t dev, long exptime);
LIBFLIAPI FLISetImageArea(flidev_t dev, long ul_x, long ul_y,
			  long lr_x, long lr_y);
LIBFLIAPI FLISetHBin(flidev_t dev, long hbin);
LIBFLIAPI FLISetVBin(flidev_t dev, long vbin);
LIBFLIAPI FLISetFrameType(flidev_t dev, fliframe_t frametype);
LIBFLIAPI FLICancelExposure(flidev_t dev);
LIBFLIAPI FLIGetExposureStatus(flidev_t dev, long *timeleft);
LIBFLIAPI FLISetTemperature(flidev_t dev, double temperature);
LIBFLIAPI FLIGetTemperature(flidev_t dev, double *temperature);
LIBFLIAPI FLIGrabRow(flidev_t dev, void *buff, size_t width);
LIBFLIAPI FLIExposeFrame(flidev_t dev);
LIBFLIAPI FLIFlushRow(flidev_t dev, long rows, long repeat);
LIBFLIAPI FLISetNFlushes(flidev_t dev, long nflushes);
LIBFLIAPI FLISetBitDepth(flidev_t dev, flibitdepth_t bitdepth);
LIBFLIAPI FLIReadIOPort(flidev_t dev, long *ioportset);
LIBFLIAPI FLIWriteIOPort(flidev_t dev, long ioportset);
LIBFLIAPI FLIConfigureIOPort(flidev_t dev, long ioportset);
LIBFLIAPI FLILockDevice(flidev_t dev);
LIBFLIAPI FLIUnlockDevice(flidev_t dev);
LIBFLIAPI FLIControlShutter(flidev_t dev, flishutter_t shutter);
LIBFLIAPI FLIControlBackgroundFlush(flidev_t dev, flibgflush_t bgflush);
LIBFLIAPI FLIList(flidomain_t domain, char ***names);
LIBFLIAPI FLIFreeList(char **names);
LIBFLIAPI FLISetFilterPos(flidev_t dev, long filter);
LIBFLIAPI FLIGetFilterPos(flidev_t dev, long *filter);
LIBFLIAPI FLIGetFilterCount(flidev_t dev, long *filter);
LIBFLIAPI FLIStepMotor(flidev_t dev, long steps);
LIBFLIAPI FLIGetStepperPosition(flidev_t dev, long *position);
LIBFLIAPI FLIHomeFocuser(flidev_t dev);
LIBFLIAPI FLICreateList(flidomain_t domain);
LIBFLIAPI FLIDeleteList(void);
LIBFLIAPI FLIListFirst(flidomain_t *domain, char *filename,
		       size_t fnlen, char *name, size_t namelen);
LIBFLIAPI FLIListNext(flidomain_t *domain, char *filename,
		      size_t fnlen, char *name, size_t namelen);


#ifdef __cplusplus
}
#endif

#endif /* _LIBFLI_H_ */
