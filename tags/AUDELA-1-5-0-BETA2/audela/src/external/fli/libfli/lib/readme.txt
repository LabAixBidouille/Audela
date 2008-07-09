Current Version 1.13

1.12 -> 1.13
	-unix\libfli-sys.h
		Set USB_READ_SIZ_MAX to a reasonable number (65536)
	-unix\linux\libfli-usb-sys.c
		Added detection for other types of FLI devices.
		Allowed for transfers greater than 4096 bytes.

1.11 -> 1.12 (Windows and Linux both)
	-libfli-windows.c
		Added debugging message box in DllMain
		in fli_connect added an else section for when if(OS == VER_PLATFORM_WIN32_NT) fails
		(JM)
	-libfli-usb.c 
		in usbbulkio(LPVOID _iob) ,added pipe ID checking system to the method
		added a #ifdef TESTT at the end of the file
		(JM)
	- libfli-filter-focuser.c
		Added support for 12 position filterwheel to libfli-filter-focuser.c
	- libfli-camera.c : fli_camera_set_flushes (McK)
		updated function so max Flushes is 16 (to match documentation).
		(McK)
	- libfli.c
		updated doc info on FLISetNFlushes for clarity.
		(McK)
	- libfli-camera-usb.c :  fli_camera_usb_expose_frame:
		added errorchecking for a divide by 0 error
		(McK)
	-lubfli-camera-usb : fli_camera_usb_expose_frame
		added debug info containing flushing bin information.
		(McK)
	- Added support for canceling exposures in different manners depending on
		the cameara Firmware and hardware. Eariler cameras do not proprley abort exposures.
		(McK)

Changes since 1.1
	- Corrected documentation for function FLIConfigureIOPort()
	- Added some bounds checking on FLISetImageArea()
		Note that on cameras with a FWRev < 0x0300 exceeding the set image
		area will lead to VERY SLOW grabs
	- Added some bounds checking on FLIGrabRow()
	- Removed function FLIGrabFrame(), it was never supported anyways
	- Added FLI_SHUTTER_EXTERNAL_TRIGGER to documentation for FLIControlShutter()
	- Added FLI_SHUTTER_EXTERNAL_TRIGGER_LOW and FLI_SHUTTER_EXTERNAL_TRIGGER_HIGH
	- Added FLIStartBackgroundFlush()
	- Repaired temperature settungs under Linux
	- Made temperature conversion more portable
	
