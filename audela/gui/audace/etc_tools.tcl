#
# Fichier : etc_tools.tcl
# Description : Exposure Time Calculation
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#
# source "$audace(rep_install)/gui/audace/etc_tools.tcl"
#
# --- initializations
# etc_init
#
# --- display ETC variables
# etc_disp
#
# --- get parameter list
# etc_params_set
#
# --- set a parameter
# etc_params_set msky 20
#
# --- get input list
# etc_inputs_set
#
# --- set inputs
# etc_inputs_set m 12.5
# etc_inputs_set t 120
#
# --- compute SNR from a given time
# etc_t2snr_computations
#
# --- compute time from a given SNR
# etc_snr2t_computations
#
# --- Example. What is the SNR for t=20s ?
# etc_init ; etc_inputs_set t 20 ; etc_disp ; etc_t2snr_computations
#
# --- Example. What is the exposure time for SNR = 5 and magnitude = 18 ?
# etc_init ; etc_inputs_set snr 5 ; etc_inputs_set m 18 ; etc_disp ; etc_snr2t_computations

proc etc_disp { {disptype ""} } {
   global audace

   set names [lsort [array names audace]]
   set ns ""
   set topic0 ""
   foreach name $names {
      set sname [split $name ,]
      set key [lindex $sname 0]
      if {$key!="etc"} { continue }
      set topic "[lindex $sname 1]"
      if {($topic!="comp1")&&($topic!="compsnr")} {
         set topic "[lindex $sname 1]-[lindex $sname 2]"
      }
      if {$topic!=$topic0} {
         ::console::affiche_resultat "\n===== $topic\n"
         set topic0 $topic
      }
      set key [lindex $sname end]
      if {$key=="comment"} { continue }
      set texte "$key = $audace($name) : $audace($name,comment)"
      ::console::affiche_resultat "$texte\n"
   }
   return ""
}

proc etc_init { {band V} {moon_age 0} } {
   etc_params_set_defaults $band $moon_age
   etc_inputs_set_defaults
}

proc etc_set_camera { {typecam ""} } {
   global audace

   if {$typecam=="Andor DW436"} {
      etc_params_set C_th 0.045         ; # Thermic coefficient (electrons/sec/photocell)
      etc_params_set G 2.8              ; # CCD gain (electrons/ADU)
      etc_params_set N_ro 9.2           ; # Readout noise (electrons)
      etc_params_set eta 0.85           ; # CCD Quantum efficiency in the photometric band (electron/photon)
      etc_params_set naxis1 2048        ; # Number of pixels on axis1
      etc_params_set naxis2 2048        ; # Number of pixels on axis2
      etc_params_set photocell1 13.5e-6 ; # Pixel size (m)
      etc_params_set photocell2 13.5e-6 ; # Pixel size (m)
      return ""
   } elseif {$typecam=="Audine Kaf401ME"} {
      etc_params_set C_th 0.2 ; # Thermic coefficient (electrons/sec/photocell)
      etc_params_set G 2.1              ; # CCD gain (electrons/ADU)
      etc_params_set N_ro 12            ; # Readout noise (electrons)
      etc_params_set eta 0.5            ; # CCD Quantum efficiency in the photometric band (electron/photon)
      etc_params_set naxis1 768         ; # Number of pixels on axis1
      etc_params_set naxis2 512         ; # Number of pixels on axis2
      etc_params_set photocell1 9e-6    ; # Pixel size (m)
      etc_params_set photocell2 9e-6    ; # Pixel size (m)
      return ""
   } else {
      set textes ""
      lappend textes "Andor DW436"
      lappend textes "Audine Kaf401ME"
      return $textes
   }
}

# ===========================================================================================
# Set default input parameters
#
proc etc_params_set_defaults { {band V} {moon_age 0} } {
   global audace

   set names [lsort [array names audace]]
   foreach name $names {
      set sname [split $name ,]
      set key [lindex $sname 0]
      if {$key!="etc"} { continue }
      unset audace($name)
   }

   set audace(etc,param,object,band,comment) "Photometric system symbol"
   set audace(etc,param,object,band) $band

   etc_params_set_filter $audace(etc,param,object,band)

   set audace(etc,param,local,Elev,comment) "Elevation above horizon (deg)"
   set audace(etc,param,local,Elev) 65

   set audace(etc,param,local,Tatm0,comment) "Zenith transmission of the atmosphere in the photometric band"
   set audace(etc,param,local,Tatm0) 0.5

   set audace(etc,param,local,seeing,comment) "Fwhm of the seeing (arcsec)"
   set audace(etc,param,local,seeing) 3.0

   etc_params_set_msky $audace(etc,param,object,band) $moon_age

   set audace(etc,param,optic,D,comment) "Optic diameter (m)"
   set audace(etc,param,optic,D) 0.3

   set audace(etc,param,optic,FonD,comment) "Focal diameter ratio"
   set audace(etc,param,optic,FonD) 4

   set audace(etc,param,optic,Topt,comment) "Transmission of the optics in the photometric band (Reflec=0.8, Refrac=0.95)"
   set audace(etc,param,optic,Topt) [expr 0.8*0.8*0.95*0.95]

   set audace(etc,param,optic,Fwhm_psf_opt,comment) "Fwhm of the point spread function in the image plane (m)"
   set audace(etc,param,optic,Fwhm_psf_opt) 15e-6

   set audace(etc,param,ccd,naxis1,comment) "Number of pixels on an axis1"
   set audace(etc,param,ccd,naxis1) 2048

   set audace(etc,param,ccd,naxis2,comment) "Number of pixels on an axis2"
   set audace(etc,param,ccd,naxis2) $audace(etc,param,ccd,naxis1)

   set audace(etc,param,ccd,photocell1,comment) "Photocell size on axis1 (m)"
   set audace(etc,param,ccd,photocell1) 13.5e-6

   set audace(etc,param,ccd,photocell2,comment) "Photocell size on axis2 (m)"
   set audace(etc,param,ccd,photocell2) $audace(etc,param,ccd,photocell1)

   set audace(etc,param,ccd,bin1,comment) "Binning on axis1 (photocells/pixel)"
   set audace(etc,param,ccd,bin1) 1

   set audace(etc,param,ccd,bin2,comment) "Binning on axis2 (photocells/pixel)"
   set audace(etc,param,ccd,bin2) $audace(etc,param,ccd,bin1)

   set audace(etc,param,ccd,eta,comment) "CCD Quantum efficiency in the photometric band (electron/photon)"
   set audace(etc,param,ccd,eta) 0.9

   set audace(etc,param,ccd,N_ro,comment) "Readout noise (electrons/pixel)"
   set audace(etc,param,ccd,N_ro) 8.5

   set audace(etc,param,ccd,C_th,comment) "Thermic coefficient (electrons/sec/photocell)"
   set audace(etc,param,ccd,C_th) 0.002

   set audace(etc,param,ccd,G,comment) "CCD gain (electrons/ADU)"
   set audace(etc,param,ccd,G) 1.8

   set audace(etc,param,ccd,Em,comment) "Electron multiplier (>1 if EMCCD, else =1)"
   set audace(etc,param,ccd,Em) 1

   return ""
}

proc etc_params_set_msky { {band V} {moon_age 0} } {
   global audace

   set audace(etc,param,local,msky,comment) "Sky brightness in the $band band at moon age $moon_age day (mag/arcsec2)"
   if {$moon_age<=1.5} {
      if {$band=="U"} { set audace(etc,param,local,msky) 22.0 }
      if {$band=="B"} { set audace(etc,param,local,msky) 22.7 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 21.8 }
      if {$band=="C"} { set audace(etc,param,local,msky) 21.4 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.9 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.9 }
   } elseif {$moon_age<=5} {
      if {$band=="U"} { set audace(etc,param,local,msky) 21.5 }
      if {$band=="B"} { set audace(etc,param,local,msky) 22.4 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 21.7 }
      if {$band=="C"} { set audace(etc,param,local,msky) 20.3 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.8 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.9 }
   } elseif {$moon_age<=8.5} {
      if {$band=="U"} { set audace(etc,param,local,msky) 19.9 }
      if {$band=="B"} { set audace(etc,param,local,msky) 21.6 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 21.4 }
      if {$band=="C"} { set audace(etc,param,local,msky) 21.0 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.6 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.7 }
   } elseif {$moon_age<=12} {
      if {$band=="U"} { set audace(etc,param,local,msky) 18.5 }
      if {$band=="B"} { set audace(etc,param,local,msky) 20.7 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 20.7 }
      if {$band=="C"} { set audace(etc,param,local,msky) 20.5 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.3 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.5 }
   } else {
      if {$band=="U"} { set audace(etc,param,local,msky) 17.0 }
      if {$band=="B"} { set audace(etc,param,local,msky) 19.5 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 20.0 }
      if {$band=="C"} { set audace(etc,param,local,msky) 19.9 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 19.9 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.2 }
   }
   if {$band=="z"} { set audace(etc,param,local,msky) 17.0 }
   if {$band=="J"} { set audace(etc,param,local,msky) 15.7 }
   if {$band=="H"} { set audace(etc,param,local,msky) 14.1 }
   if {$band=="K"} { set audace(etc,param,local,msky) 13.0 }

   return ""
}

proc etc_params_set_filter { {band V} } {
   global audace

   set audace(etc,param,filter,l,comment) "Central wavelength of the filter (micrometers)"
   set audace(etc,param,filter,Dl,comment) "Wavelength bandpass of the filter (micrometers)"
   set audace(etc,param,filter,Fm0,comment) "Flux for magnitude zero for the filter (Jy)"
   if {$band=="C"} {
      set audace(etc,param,filter,l) 0.6
      set audace(etc,param,filter,Dl) 0.3
      set audace(etc,param,filter,Fm0) 3100
   } elseif {$band=="U"} {
      set audace(etc,param,filter,l) 0.36
      set audace(etc,param,filter,Dl) [expr 0.15*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 1810
   } elseif {$band=="B"} {
      set audace(etc,param,filter,l) 0.44
      set audace(etc,param,filter,Dl) [expr 0.22*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4260
   } elseif {$band=="V"} {
      set audace(etc,param,filter,l) 0.55
      set audace(etc,param,filter,Dl) [expr 0.16*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 3640
   } elseif {$band=="R"} {
      set audace(etc,param,filter,l) 0.64
      set audace(etc,param,filter,Dl) [expr 0.23*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 3080
   } elseif {$band=="I"} {
      set audace(etc,param,filter,l) 0.79
      set audace(etc,param,filter,Dl) [expr 0.19*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 2550
   } elseif {$band=="J"} {
      set audace(etc,param,filter,l) 1.26
      set audace(etc,param,filter,Dl) [expr 0.16*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 1600
   } elseif {$band=="H"} {
      set audace(etc,param,filter,l) 1.60
      set audace(etc,param,filter,Dl) [expr 0.23*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 1080
   } elseif {$band=="K"} {
      set audace(etc,param,filter,l) 2.22
      set audace(etc,param,filter,Dl) [expr 0.23*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 670
   } elseif {$band=="g"} {
      set audace(etc,param,filter,l) 0.52
      set audace(etc,param,filter,Dl) [expr 0.14*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 3730
   } elseif {$band=="r"} {
      set audace(etc,param,filter,l) 0.67
      set audace(etc,param,filter,Dl) [expr 0.14*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4490
   } elseif {$band=="i"} {
      set audace(etc,param,filter,l) 0.79
      set audace(etc,param,filter,Dl) [expr 0.16*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4760
   } elseif {$band=="z"} {
      set audace(etc,param,filter,l) 0.91
      set audace(etc,param,filter,Dl) [expr 0.13*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4810
   } else {
      error "Filter $band not found"
   }
}

proc etc_inputs_set { args } {
   global audace

   set names [lsort [array names audace]]
   set topic0 ""
   set res ""
   set name0 ""

   if {[llength $args] > 0} {

      set key0 [lindex $args 0]
      set val0 [lindex $args 1]
      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="input"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         if {$key==$key0} {
            set name0 $name
            if {[catch {expr $val0}]==0} {
               set audace($name) $val0
               if {($key0=="M")||($key0=="DL_pc")} {
                  set audace(etc,input,object,m) [expr $audace(etc,input,object,M) + 5. * log10 ($audace(etc,input,object,DL_pc) / 10.)]
               }
            } elseif {$val0=="?"} {
               return $audace($name,comment)
            }
            return "$audace($name) \"$audace($name,comment)\""
         }
      }

   }

   if {$name0==""} {

      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="input"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         append res "$key "
      }
      return $res

   }

}

proc etc_inputs_set_defaults { } {
   global audace

   set band $audace(etc,param,object,band)

   set audace(etc,input,object,M,comment) "Absolute stellar magnitude in the $band band"
   set audace(etc,input,object,M) -21

   set audace(etc,input,object,DL_pc,comment) "Distance luminosity (pc)"
   set audace(etc,input,object,DL_pc) 40e6

   set audace(etc,input,object,m,comment) "Apparent stellar magnitude in the $band band"
   set audace(etc,input,object,m) [expr $audace(etc,input,object,M) + 5. * log10 ($audace(etc,input,object,DL_pc) / 10.)]

   set audace(etc,input,ccd,t,comment) "Exposure time (sec)"
   set audace(etc,input,ccd,t) 30

   set audace(etc,input,constraint,snr,comment) "SNR constrained"
   set audace(etc,input,constraint,snr) 5

   return ""
}

proc etc_params_set { args } {
   global audace

   set names [lsort [array names audace]]
   set topic0 ""
   set res ""
   set name0 ""

   if {[llength $args] > 0} {

      set key0 [lindex $args 0]
      set val0 [lindex $args 1]
      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="param"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         if {$key==$key0} {
            set name0 $name
            if {[catch {expr $val0}]==0} {
               set audace($name) $val0
            } elseif {$val0=="?"} {
               return $audace($name,comment)
            }
            return "$audace($name) \"$audace($name,comment)\""
         }
      }

   }

   if {$name0==""} {

      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="param"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         append res "$key "
      }
      return $res

   }

}

proc etc_preliminary_computations { } {
   global audace

   set pi [expr 4*atan(1)]

   # --- Optics
   set audace(etc,comp1,Foclen,comment) "Focal length (m)"
   set audace(etc,comp1,Foclen) [expr $audace(etc,param,optic,FonD) * $audace(etc,param,optic,D)]

   set audace(etc,comp1,pixsize1,comment) "Pixel length on axis1 (m)"
   set audace(etc,comp1,pixsize1) [expr $audace(etc,param,ccd,photocell1) * $audace(etc,param,ccd,bin1)]

   set audace(etc,comp1,pixsize2,comment) "Pixel length on axis2 (m)"
   set audace(etc,comp1,pixsize2) [expr $audace(etc,param,ccd,photocell2) * $audace(etc,param,ccd,bin2)]

   set audace(etc,comp1,cdelt1,comment) "Pixel spatial sampling on axis1 (arcsec/pix)"
   set audace(etc,comp1,cdelt1) [expr 2 * atan ( $audace(etc,comp1,pixsize1) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi * 3600.]

   set audace(etc,comp1,cdelt2,comment) "Pixel spatial sampling on axis2 (arcsec/pix)"
   set audace(etc,comp1,cdelt2) [expr 2 * atan ( $audace(etc,comp1,pixsize2) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi * 3600.]

   set audace(etc,comp1,W,comment) "Pixel solid angle (arcsec2/pix)"
   set audace(etc,comp1,W) [expr $audace(etc,comp1,cdelt1) * $audace(etc,comp1,cdelt2)]

   set audace(etc,comp1,FoV1,comment) "Field of view of the CCD image on axis1 (deg)"
   set audace(etc,comp1,FoV1) [expr 2 * atan ( $audace(etc,param,ccd,naxis1) * $audace(etc,comp1,pixsize1) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi]

   set audace(etc,comp1,FoV2,comment) "Field of view of the CCD image on axis2 (deg)"
   set audace(etc,comp1,FoV2) [expr 2 * atan ( $audace(etc,param,ccd,naxis2) * $audace(etc,comp1,pixsize2) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi]

   set audace(etc,comp1,Fwhm_psf_seeing,comment) "Fwhm of the seeing in the image plane (m)"
   set audace(etc,comp1,Fwhm_psf_seeing) [expr $audace(etc,param,local,seeing) / 3600. * $pi / 180 * $audace(etc,comp1,Foclen)]

   set audace(etc,comp1,Fwhm_psf,comment) "Fwhm of the PSF in the image plane (m)"
   set audace(etc,comp1,Fwhm_psf) [expr sqrt ( $audace(etc,param,optic,Fwhm_psf_opt)*$audace(etc,param,optic,Fwhm_psf_opt) + $audace(etc,comp1,Fwhm_psf_seeing)*$audace(etc,comp1,Fwhm_psf_seeing) )]

   # --- Optics : computation of the gaussian fraction covered by the brightest pixel
   set oversampling 12 ; # must be even and >10 to ensure a good resolution
   if {$audace(etc,comp1,pixsize1)>=$audace(etc,comp1,pixsize2)} {
      set p $audace(etc,comp1,pixsize2)
      set P $audace(etc,comp1,pixsize1)
   } else {
      set p $audace(etc,comp1,pixsize1)
      set P $audace(etc,comp1,pixsize2)
   }
   set dp [expr $p/$oversampling]
   set sigma [expr $audace(etc,comp1,Fwhm_psf) / (2*sqrt(2*log(2)))]
   set sigma2 [expr $sigma*$sigma]
   set a1d [expr 1 / $sigma / sqrt(2*$pi)]
   set a2d [expr $a1d*$a1d]

   set audace(etc,comp1,fpix1,comment) "Flux fraction in the brightest pixel in the favorable case (max flux at the center of the pixel)"
   set x1 [expr -$p/2.] ; set x2 [expr $x1+$p]
   set y1 [expr -$P/2.] ; set y2 [expr $y1+$P]
   set som 0
   for {set x $x1} {$x<=$x2} {set x [expr $x+$dp]} {
      set dx2 [expr $x*$x]
      for {set y $y1} {$y<=$y2} {set y [expr $y+$dp]} {
         set dy2 [expr $y*$y]
         set d2 [expr $dx2+$dy2]
         set som [expr $som+exp(-0.5*$d2/$sigma2)]
      }
   }
   set audace(etc,comp1,fpix1) [expr $a2d*$dp*$dp*$som]

   set audace(etc,comp1,fpix3,comment) "Flux fraction in the brightest pixel in the worst case (max flux at the corner of the pixel)"
   set x1 [expr 0.] ; set x2 [expr $x1+$p]
   set y1 [expr 0.] ; set y2 [expr $y1+$P]
   set som 0
   for {set x $x1} {$x<=$x2} {set x [expr $x+$dp]} {
      set dx2 [expr $x*$x]
      for {set y $y1} {$y<=$y2} {set y [expr $y+$dp]} {
         set dy2 [expr $y*$y]
         set d2 [expr $dx2+$dy2]
         set som [expr $som+exp(-0.5*$d2/$sigma2)]
      }
   }
   set audace(etc,comp1,fpix3) [expr $a2d*$dp*$dp*$som]

   set audace(etc,comp1,fpix2,comment) "Flux fraction in the brightest pixel in the intermediate case"
   set x1 [expr 0.] ; set x2 [expr $x1+$p]
   set y1 [expr -$P/2.] ; set y2 [expr $y1+$P]
   set som 0
   for {set x $x1} {$x<=$x2} {set x [expr $x+$dp]} {
      set dx2 [expr $x*$x]
      for {set y $y1} {$y<=$y2} {set y [expr $y+$dp]} {
         set dy2 [expr $y*$y]
         set d2 [expr $dx2+$dy2]
         set som [expr $som+exp(-0.5*$d2/$sigma2)]
      }
   }
   set audace(etc,comp1,fpix2) [expr $a2d*$dp*$dp*$som]

   # --- Object
   set audace(etc,comp1,F_Jy,comment) "Total flux of the object outside atmosphere (Jy)"
   set audace(etc,comp1,F_Jy) [expr $audace(etc,param,filter,Fm0) * pow(10,-0.4 * $audace(etc,input,object,m)) ]

   set audace(etc,comp1,F_ph,comment) "Total flux of the object outside atmosphere (photons / sec /m2)"
   set audace(etc,comp1,F_ph) [expr $audace(etc,comp1,F_Jy) * 1.51e7 * $audace(etc,param,filter,Dl)/$audace(etc,param,filter,l)]

   set audace(etc,comp1,Tatm,comment) "Transmission of the atmosphere at elevation"
   set audace(etc,comp1,Tatm) [expr $audace(etc,param,local,Tatm0) * sin($audace(etc,param,local,Elev)*$pi/180.)]

   set audace(etc,comp1,Ftot_ph,comment) "Total flux of the object after passed thru the optics (photons / object)"
   set audace(etc,comp1,Ftot_ph) [expr $audace(etc,comp1,F_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,input,ccd,t)]

   set audace(etc,comp1,Ftot_el,comment) "Total flux of the object after passed thru the optics (electrons / object)"
   set audace(etc,comp1,Ftot_el) [expr $audace(etc,comp1,Ftot_ph) * $audace(etc,param,ccd,eta)]

   set audace(etc,comp1,Fpix_el,comment) "Brightest pixel flux of the object after passed thru the optics (electrons / pixel)"
   set audace(etc,comp1,Fpix_el) [expr $audace(etc,comp1,Ftot_el) * $audace(etc,comp1,fpix1)]

   # --- Sky brightness
   set audace(etc,comp1,Sky_Jy,comment) "Brightness of the sky (Jy/arsec2)"
   set audace(etc,comp1,Sky_Jy) [expr $audace(etc,param,filter,Fm0) * pow(10,-0.4 * $audace(etc,param,local,msky)) ]

   set audace(etc,comp1,Sky_ph,comment) "Brightness of the sky (photons / sec /m2)"
   set audace(etc,comp1,Sky_ph) [expr $audace(etc,comp1,Sky_Jy) * 1.51e7 * $audace(etc,param,filter,Dl)/$audace(etc,param,filter,l)]

   set audace(etc,comp1,Skypix_ph,comment) "Brightness of the sky after passed thru the optics (photons / pixel)"
   set audace(etc,comp1,Skypix_ph) [expr $audace(etc,comp1,Sky_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,W) * $audace(etc,input,ccd,t)]

   set audace(etc,comp1,Skypix_el,comment) "Brightness of the sky after passed thru the optics (electrons / pixel)"
   set audace(etc,comp1,Skypix_el) [expr $audace(etc,comp1,Skypix_ph) * $audace(etc,param,ccd,eta)]

   # --- EMCCD
   set audace(etc,comp1,fex,comment) "EMCCD excess noise factor (empirical formula derived from a figure of a paper)"
   set audace(etc,comp1,fex) [expr 1. + pow( 2./$pi * atan( ($audace(etc,param,ccd,Em)-1)*3 ) ,3)]

   return ""
}

proc etc_t2snr_computations {} {
   global audace

   etc_preliminary_computations

   set audace(etc,compsnr,S_th,comment) "Thermic signal (electrons/pixel)"
   set audace(etc,compsnr,S_th) [expr $audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,input,ccd,t) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,S_sk,comment) "Sky signal (electrons/pixel)"
   set audace(etc,compsnr,S_sk) [expr $audace(etc,comp1,Skypix_el) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,S_ph,comment) "Object signal (electrons/pixel)"
   set audace(etc,compsnr,S_ph) [expr $audace(etc,comp1,Fpix_el) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_th,comment) "Thermic noise (electrons/pixel)"
   set audace(etc,compsnr,N_th) [expr sqrt($audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,input,ccd,t) * $audace(etc,comp1,fex)) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_sk,comment) "Sky noise (electrons/pixel)"
   set audace(etc,compsnr,N_sk) [expr sqrt($audace(etc,comp1,Skypix_el) * $audace(etc,comp1,fex)) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_ph,comment) "Object noise (electrons/pixel) = shot noise"
   set audace(etc,compsnr,N_ph) [expr sqrt($audace(etc,comp1,Fpix_el) * $audace(etc,comp1,fex)) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_tot,comment) "Total noise (electrons/pixels)"
   set audace(etc,compsnr,N_tot) [expr sqrt ( $audace(etc,param,ccd,N_ro)*$audace(etc,param,ccd,N_ro) + $audace(etc,compsnr,N_th)*$audace(etc,compsnr,N_th) + $audace(etc,compsnr,N_sk)*$audace(etc,compsnr,N_sk) + $audace(etc,compsnr,N_ph)*$audace(etc,compsnr,N_ph) )]

   set audace(etc,compsnr,SNR_obj,comment) "Object signal/noise at the brightest pixel"
   set audace(etc,compsnr,SNR_obj) [expr $audace(etc,compsnr,S_ph) / $audace(etc,compsnr,N_tot)]

   set audace(etc,compsnr,S_th_adu,comment) "Thermic signal (ADU/pixel)"
   set audace(etc,compsnr,S_th_adu) [expr $audace(etc,compsnr,S_th) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,S_sk_adu,comment) "Sky signal (ADU/pixel)"
   set audace(etc,compsnr,S_sk_adu) [expr $audace(etc,compsnr,S_sk) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,S_ph_adu,comment) "Object signal (ADU/pixel)"
   set audace(etc,compsnr,S_ph_adu) [expr $audace(etc,compsnr,S_ph) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_th_adu,comment) "Thermic noise (ADU/pixel)"
   set audace(etc,compsnr,N_th_adu) [expr $audace(etc,compsnr,N_th) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_sk_adu,comment) "Sky noise (ADU/pixel)"
   set audace(etc,compsnr,N_sk_adu) [expr $audace(etc,compsnr,N_sk) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_ph_adu,comment) "Object noise (ADU/pixel) = shot noise"
   set audace(etc,compsnr,N_ph_adu) [expr $audace(etc,compsnr,N_ph) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_tot_adu,comment) "Total noise (ADU/pixels)"
   set audace(etc,compsnr,N_tot_adu) [expr $audace(etc,compsnr,N_tot) / $audace(etc,param,ccd,G)]

   return $audace(etc,compsnr,SNR_obj)
}

proc etc_snr2t_computations {} {
   global audace

   etc_preliminary_computations

   set pi [expr 4*atan(1)]
   set C [expr $audace(etc,input,constraint,snr)*$audace(etc,input,constraint,snr) * $audace(etc,param,ccd,N_ro)*$audace(etc,param,ccd,N_ro)]
   set B [expr $audace(etc,input,constraint,snr)*$audace(etc,input,constraint,snr) * ( ($audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)) + ($audace(etc,comp1,Sky_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,W) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)) + ($audace(etc,comp1,F_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fpix1) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)) )]
   set A [expr -pow( $audace(etc,comp1,F_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fpix1) * $audace(etc,param,ccd,Em) , 2) ]
   # We have A<0, B>0 and C >0. From the equation A*t^2 + B*t + C = 0, we can find the t value:
   set D [expr $B*$B - 4*$A*$C] ; # (always positive)
   set t [expr ( -$B - sqrt($D) ) / (2.*$A)]
   set audace(etc,compsnr,t,comment) "Exposure time computer from a SNR value constrained"
   set audace(etc,compsnr,t) $t
   return $t
}

etc_init

