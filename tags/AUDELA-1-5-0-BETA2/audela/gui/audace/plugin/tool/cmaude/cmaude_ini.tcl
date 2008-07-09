#--- Sun altitude under that the aquisition is on (degrees)
set cmconf(haurore) -10
#--- End of the astronomical twilight and begining of the "real" night (-18°)
set cmconf(hastwilight) -18
#--- Altitude under which the Moon is considered as non-disturbing
set cmconf(hmooncritic) 7
#--- Exposure time 1 for CCD (seconds) - without Moon
set cmconf(exptime1) 120
#--- Exposure time 2 for CCD (seconds) - with Moon or during twilight
set cmconf(exptime2) 15
#--- Rythm of the images (second)
set cmconf(rythm) 10
#--- Binning factor (1x1, 2x2)
set cmconf(binning) 1x1
#--- Windowing in binning 1x1 - size of image must remain 580x512
set cmconf(win11) {106 0 685 512}
#--- Windowing in binning 2x2
set cmconf(win22) {53 0 343 256}
#--- Position of zenith in binning 1x1
set cmconf(zenith11) {290 250}
#--- Position of zenith in binning 2x2
set cmconf(zenith22) {145 125}
#--- FITS Keywords
set cmconf(fits,OPTICS) "180 Degrees Fisheye Lens"
set cmconf(fits,UT1) "Altaz position of UT1"
set cmconf(fits,UT2) "Altaz position of UT2"
set cmconf(fits,UT3) "Altaz position of UT3"
set cmconf(fits,UT4) "Altaz position of UT4"

