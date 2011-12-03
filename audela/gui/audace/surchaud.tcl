#
# Fichier : surchaud.tcl
# Description : Surcharge des fonctions de AudeLA pour les rendre compatibles avec l'usage des repertoires de travail
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#
# add  operand value
# add1  in operand out const ?tt_options?
# add2  in operand out const number ?first_index? ?tt_options?
# convgauss  sigma
# convgauss2  in out number sigma ?first_index? ?tt_options?
# delete2  in number
# div  operand value
# div1  in operand out const ?tt_options?
# div2  in operand out const number ?first_index? ?tt_options?
# mult  const
# mult1  in out const ?tt_options?
# mult2  in out const number ?first_index? ?tt_options?
# ngain1  in out const ?tt_options?
# ngain2  in out const number ?first_index? ?tt_options?
# noffset1  in out const ?tt_options?
# noffset2  in out const number ?first_index? ?tt_options?
# offset  value
# offset1  in out const ?tt_options?
# offset2  in out const number ?first_index? ?tt_options?
# opt  dark offset
# opt1  in dark offset out const ?tt_options?
# opt2  in dark offset out const number ?first_index? ?tt_options?
# prod  operand value
# register  in out number ?-box {x1 y1 x2 y2}? ?tt_options?
# register2  in out number ?first_index? ?tt_options?
# registerbox  in out number ?first_index? ?tt_options?
# registerfine  in out number ?delta? ?oversampling? ?first_index? ?tt_options?
# registerwcs  in out number ?first_index? ?tt_options?
# sadd  in out number ?first_index? ?tt_options?
# scale1  in out scale_x scale_y ?tt_options?
# scale2  in out number scale_x scale_y ?first_index? ?tt_options?
# smean  in out number ?first_index? ?tt_options?
# smedian  in out number ?first_index? ?tt_options?
# sprod  in out number ?first_index? ?tt_options?
# spythagore  in out number ?first_index? ?tt_options?
# ssigma  in out number ?first_index? ?tt_options?
# ssk  in out number kappa ?first_index? ?tt_options?
# ssort  in out number percent ?first_index? ?tt_options?
# sub  operand value
# sub1  in operand out const ?tt_options?
# sub2  in operand out const number ?first_index? ?tt_options?
# subdark2  in dark offset out number exptime dexptime ?first_index?
# subsky  back_kernel back_threshold  ?tt_options?
# subsky1  in out back_kernel back_threshold ?tt_options?
# subsky2  in out number back_kernel back_threshold ?first_index? ?tt_options?
# trans  dx dy
# trans2  in out dx dy number ?first_index? ?tt_options?
# uncosmic  coef
# uncosmic2  in out number coef ?first_index? ?tt_options?
# window1  in out {x1 y1 x2 y2} ?tt_options?
# window2  in out number {x1 y1 x2 y2} ?first_index? ?tt_options?
#
# calibwcs  Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder
# calibwcs2  Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder number ?first_index?
# simulimage Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type? ?newstar_type? ?newstar_ra? ?newstar_dec? ?newstar_mag?
# simulimage2 out ListDatesObsUTC variable_type Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type?
#

proc add {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) add "$operand" [lindex $args 1]
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: add operand value"
   }
}

proc add1 {args} {
   #--- in operand out const ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: add1 in operand out const ?tt_options?"
   }
}

proc add2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: add2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc convgauss {args} {
   #--- sigma
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: convgauss sigma"
   }
}

proc convgauss2 {args} {
   #--- in out number sigma ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CONV kernel_type=gaussian sigma=$[lindex $args 3] $options"
   } else {
      error "Usage: convgauss2 in out number sigma ?first_index? ?tt_options?"
   }
}

proc delete2 {args} {
   #--- in number
   if {[llength $args] == 2} {
      set ext $::conf(extension,defaut)
      set cmp [buf$::audace(bufNo) compress]
      if {$cmp=="none"} {
         set cmp ""
      } else {
         set cmp ".gz"
      }
      set kdeb 1
      set kfin [lindex $args 1]
      for {set k $kdeb} {$k<=$kfin} {incr k} {
         set filename [ file join $::audace(rep_images) [lindex $args 0]${k}${ext}${cmp} ]
         catch {
            file delete "$filename"
         }
      }
   } else {
      error "Usage: delete2 in number"
   }
}

proc div {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) div "$operand" [lindex $args 1]
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: div operand value"
   }
}

proc div1 {args} {
   #--- in operand out const ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
   } else {
      error "Usage: div1 in operand out const ?tt_options?"
   }
}

proc div2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
   } else {
      error "Usage: div2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc mult {args} {
   #--- const
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "MULT constant=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: mult const"
   }
}

proc mult1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MULT constant=[lindex $args 2] $options"
   } else {
      error "Usage: mult1 in out const ?tt_options?"
   }
}

proc mult2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" MULT constant=[lindex $args 2] $options"
   } else {
      error "Usage: mult2 in out const number ?first_index? ?tt_options?"
   }
}

proc ngain1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {($n>=3)} {
      set ext $::conf(extension,defaut)
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" NORMGAIN normgain_value=[lindex $args 2] $options"
   } else {
      error "Usage: ngain1 in out const ?tt_options?"
   }
}

proc ngain2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {($n>=4)} {
      set ext $::conf(extension,defaut)
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMGAIN normgain_value=[lindex $args 2] $options"
   } else {
      error "Usage: ngain2 in out const number ?first_index? ?tt_options?"
   }
}

proc noffset1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {($n>=3)} {
      set ext $::conf(extension,defaut)
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2] $options"
   } else {
      error "Usage: noffset1 in out const ?tt_options?"
   }
}

proc noffset2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {($n>=4)} {
      set ext $::conf(extension,defaut)
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2] $options"
   } else {
      error "Usage: noffset2 in out const number ?first_index? ?tt_options?"
   }
}

proc offset {args} {
   #--- value
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "OFFSET offset=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: offset value"
   }
}

proc offset1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {($n>=3)} {
      set ext $::conf(extension,defaut)
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" OFFSET offset=[lindex $args 2] $options"
   } else {
      error "Usage: offset1 in out const ?tt_options?"
   }
}

proc offset2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {($n>=4)} {
      set ext $::conf(extension,defaut)
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" OFFSET offset=[lindex $args 2] $options"
   } else {
      error "Usage: offset2 in out const number ?first_index? ?tt_options?"
   }
}

proc opt {args} {
   #--- dark offset
   if {[llength $args] == 2} {
      set len [expr [string length $::audace(rep_images)]-1]
      set dark [lindex $args 0]
      set dirdark [file dirname "$dark"]
      if {($len>=0)&&($dirdark==".")} {
         set dark [ file join $::audace(rep_images) $dark ]
      }
      set ext [file extension "$dark"]
      if {$ext==""} {
         set dark "${dark}$::conf(extension,defaut)"
      }
      set offset [lindex $args 1]
      set diroffset [file dirname "$offset"]
      if {($len>=0)&&($diroffset==".")} {
         set offset [ file join $::audace(rep_images) $offset ]
      }
      set ext [file extension "$offset"]
      if {$ext==""} {
         set offset "${offset}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) opt "$dark" "$offset"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: opt dark offset"
   }
}

proc opt1 {args} {
   #--- in dark offset out ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set dark "$operand"
      set operand [lindex $args 2]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set offset "$operand"
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 3]\" . \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" $options"
   } else {
      error "Usage: opt1 in dark offset out ?tt_options?"
   }
}

proc opt2 {args} {
   #--- in dark offset out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set dark "$operand"
      set operand [lindex $args 2]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set offset "$operand"
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 3]\" 1 \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" $options"
   } else {
      error "Usage: opt2 in dark offset out number ?first_index? ?tt_options?"
   }
}

proc prod {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) imaseries "PROD \"file=$operand\" constant=[lindex $args 1]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: prod operand value"
   }
}

proc register {args} {
   #--- in out number ?-box {x1 y1 x2 y2}? ?tt_options?
   #--- options : "tt options" or -box {x1 y1 x2 y2}
   set argc [llength $args]
   if { $argc < 3} {
      error "Usage: register in out number ?-box {x1 y1 x2 y2}? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set number [lindex $args 2]
   set method tt
   set box ""
   set options ""
   if {$argc > 3} {
      for {set k 3} {$k<[expr $argc-1]} {incr k} {
         set argu [lindex $args $k]
         if {$argu=="-box"} {
            set method box
            set box [lindex $args [expr $k+1]]
         }
      }
      if {$method=="tt"} {
         set options [lrange $args 3 end]
      }
   }
   set first 1
   set number [expr $number+$first-1]
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   if {$method=="tt"} {
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$path\" \"$in\" $first $number \"$ext\" \"$path\" \"$objefile\" $first \"$ext\" STAT objefile"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" $first $number \"$ext\" \"$path\" \"$out\" $first \"$ext\" REGISTER translate=only $options"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" $first $number \"$ext\" \"$path\" \"$objefile\" $first \"$ext\" DELETE"
   } else {
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$number} {incr k} {
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set res [buf$::audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$::audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
      }
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$number} {incr k} {
         set kk [expr $k-$first]
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$::audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$::audace(bufNo) save [ file join ${path} ${out}${k}${ext} ]
      }
   }
}

proc register2 {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"$objefile\" 1 \"$ext\" STAT objefile $options"
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER translate=never $options"
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$::audace(rep_images)\" \"$objefile\" 1 \"$ext\" DELETE $options"
   } else {
      error "Usage: register2 in out number ?first_index? ?tt_options?"
   }
}

proc registerbox {args} {
   #--- in out number ?visuNo? ?first_index? ?tt_options?
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set n [llength $args]
   if {$n>=3} {
      set visuno 1
      if {$n>=4} {
         set visuno "[lindex $args 3]"
      }
      set box [::confVisu::getBox $visuno]
      set first 1
      if {$n>=5} {
         set first "[lindex $args 4]"
      }
      set number [lindex $args 2]
      set options ""
      if {$n>=6} {
         set options "[lrange $args 5 end]"
      }
      set ni [expr $number+$first-1]
      set ext $::conf(extension,defaut)
      set path "$::audace(rep_images)"
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$ni} {incr k} {
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set res [buf$::audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$::audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
      }
      ::console::affiche_saut "\n"
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$ni} {incr k} {
         set kk [expr $k-$first]
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$::audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$::audace(bufNo) save [ file join ${path} ${out}${k}${ext} ]
      }
   } else {
      error "Usage: registerbox in out number ?visuNo? ?first_index? ?tt_options?"
      return $error;
   }
}

proc registerfine {args} {
   #--- in out number ?delta? ?oversampling? ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set delta 1
      if {$n==4} {
         set delta "[lindex $args 3]"
      }
      set oversampling 10
      if {$n==5} {
         set delta "[lindex $args 3]"
         set oversampling "[lindex $args 4]"
      }
      set first 1
      if {$n==6} {
         set delta "[lindex $args 3]"
         set oversampling "[lindex $args 4]"
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set delta "[lindex $args 3]"
         set oversampling "[lindex $args 4]"
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTERFINE oversampling=$oversampling delta=$delta \"file=$::audace(rep_images)/[lindex $args 0]${first}${ext}\" $options"
   } else {
      error "Usage: registerfine in out number ?delta? ?oversampling? ?first_index? ?tt_options?"
   }
}

proc registerwcs {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER matchwcs $options"
   } else {
      error "Usage: registerwcs in out number ?first_index? ?tt_options?"
   }
}

proc sadd {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" ADD $options"
   } else {
      error "Usage: sadd in out number ?first_index? ?tt_options?"
   }
}

proc scale1 {args} {
   #--- in out scale_x scale_y ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" RESAMPLE \"paramresample=[lindex $args 2] 0 0 0 [lindex $args 3] 0\" normaflux=1 $options"
   } else {
      error "Usage: scale1 in out scale_x scale_y ?tt_options?"
   }
}

proc scale2 {args} {
   #--- in out number scale_x scale_y ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" RESAMPLE \"paramresample=[lindex $args 3] 0 0 0 [lindex $args 4] 0\" normaflux=1 $options"
   } else {
      error "Usage: scale2 in out number scale_x scale_y ?first_index? ?tt_options?"
   }
}

proc smean {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MEAN $options"
   } else {
      error "Usage: smean in out number ?first_index? ?tt_options?"
   }
}

proc smedian {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MED $options"
   } else {
      error "Usage: smedian in out number ?first_index? ?tt_options?"
   }
}

proc sprod {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" PROD $options"
   } else {
      error "Usage: sprod in out number ?first_index? ?tt_options?"
   }
}

proc spythagore {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" PYTHAGORE $options"
   } else {
      error "Usage: spythagore in out number ?first_index? ?tt_options?"
   }
}

proc ssigma {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SIG $options"
   } else {
      error "Usage: ssigma in out number ?first_index? ?tt_options?"
   }
}

proc ssk {args} {
   #--- in out number kappa ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SK kappa=[lindex $args 3] $options"
   } else {
      error "Usage: ssk in out number kappa ?first_index? ?tt_options?"
   }
}

proc ssort {args} {
   #--- in out number percent ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SORT percent=[lindex $args 3] $options"
   } else {
      error "Usage: ssort in out number percent ?first_index? ?tt_options?"
   }
}

proc sub {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) sub "$operand" [lindex $args 1]
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: sub operand value"
   }
}

proc sub1 {args} {
   #--- in operand out const ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: sub1 in operand out const ?tt_options?"
   }
}

proc sub2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: sub2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc subdark2 {args} {
   #--- in dark offset out number exptime dexptime ?first_index?
   set n [llength $args]
   if {$n>=7} {
      set in         "[lindex $args 0]"
      set dark       "[lindex $args 1]"
      set offset     "[lindex $args 2]"
      set out        "[lindex $args 3]"
      set number     "[lindex $args 4]"
      set exptime    "[lindex $args 5]"
      set dexptime   "[lindex $args 6]"

      if {$n>=8} {
         set first "[lindex $args 7]"
      } else {
         set first 1
      }

      if {$n>=9} {
         set unsmearing "[lindex $args 8]"
      } else {
         set unsmearing 1
      }

      if {[file dirname $dark]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set dark [ file join $::audace(rep_images) $dark ]
         }
      }

      if {[file dirname $offset]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set offset [ file join $::audace(rep_images) $offset ]
         }
      }

      set ext [file extension "$dark"]
      if {$ext==""} {
         set operand "${dark}$::conf(extension,defaut)"
      }

      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      set command "IMA/SERIES \"$::audace(rep_images)\" \"$in\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"$out\" 1 \"$ext\" SUBDARK \"dark=$dark\" \"bias=$offset\" \"exptime=$exptime\" \"dexptime=$dexptime\" "
      ::console::disp "subdark2 : $command\n"
      ttscript2 $command
   } else {
      #---                    0  1     2     3    4       5      6           7            8
      error "Usage: subdark2 in dark offset out number exptime dexptime ?first_index?"
   }
}

proc subsky {args} {
   #--- back_kernel back_threshold ?tt_options?
   set argc [llength $args]
   if { $argc < 2} {
      error "Usage: subsky back_kernel back_threshold ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set back_kernel [lindex $args 0]
   set back_threshold [lindex $args 1]
   if {$back_threshold<0} {
      set back_threshold 0
   }
   if {$back_threshold>1} {
      set back_threshold 1
   }
   set options ""
   if {$argc>=3} {
      set options "[lrange $args 2 end]"
   }
   buf$::audace(bufNo) imaseries "back back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
}

proc subsky1 {args} {
   #--- in out back_kernel back_threshold ?tt_options?
   set argc [llength $args]
   if { $argc < 4} {
      error "Usage: subsky1 in out back_kernel back_threshold ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set back_kernel [lindex $args 2]
   set back_threshold [lindex $args 3]
   if {$back_threshold<0} {
      set back_threshold 0
   }
   if {$back_threshold>1} {
      set back_threshold 1
   }
   set options ""
   if {$argc>=5} {
      set options "[lrange $args 4 end]"
   }
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\" BACK back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
   ttscript2 $script
}

proc subsky2 {args} {
   #--- in out number back_kernel back_threshold ?first_index? ?tt_options?"
   set argc [llength $args]
   if { $argc < 5} {
      error "Usage: subsky2 in out number back_kernel back_threshold ?first_index? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set number [lindex $args 2]
   set back_kernel [lindex $args 3]
   set back_threshold [lindex $args 4]
   if {$back_threshold<0} {
      set back_threshold 0
   }
   if {$back_threshold>1} {
      set back_threshold 1
   }
   set first 1
   set options ""
   if {$argc>=6} {
      set first "[lindex $args 5]"
      if {$argc>=7} {
         set options "[lrange $args 6 end]"
      }
   }
   set ni [expr $number+$first-1]
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" $first $ni \"$ext\" \"$path\" \"$out\" 1 \"$ext\" BACK back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
   ttscript2 $script
}

proc trans {args} {
   #--- dx dy
   if {[llength $args] == 2} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "TRANS trans_x=[lindex $args 0] trans_y=[lindex $args 1]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: trans dx dy"
   }
}

proc trans2 {args} {
   #--- in out dx dy number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" TRANS trans_x=[lindex $args 2] trans_y=[lindex $args 3] $options"
   } else {
      error "Usage: trans2 in out dx dy number ?first_index? ?tt_options?"
   }
}

proc uncosmic {args} {
   #--- coef
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: uncosmic coef"
   }
}

proc uncosmic2 {args} {
   #--- in out number coef ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 3] $options"
   } else {
      error "Usage: uncosmic2 in out number coef ?first_index? ?tt_options?"
   }
}

proc window1 {args} {
   #--- in out {x1 y1 x2 y2} ?tt_options?
   set argc [llength $args]
   if { $argc < 3} {
      error "Usage: window1 in out {x1 y1 x2 y2} ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set box [lindex $args 2]
   set x1 [lindex $box 0]
   set y1 [lindex $box 1]
   set x2 [lindex $box 2]
   set y2 [lindex $box 3]
   if {$x2<$x1} {
      set dummy $x1
      set x1 $x2
      set x2 $dummy
   }
   if {$y2<$y1} {
      set dummy $y1
      set y1 $y2
      set y2 $dummy
   }
   set options ""
   if {$argc>=4} {
      set options "[lrange $args 3 end]"
   }
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\"  WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"
   ttscript2 $script
}

proc window2 {args} {
   #--- in out number {x1 y1 x2 y2} ?first_index? ?tt_options?
   set argc [llength $args]
   if { $argc < 4} {
      error "Usage: window2 in out number {x1 y1 x2 y2} ?first_index? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set number [lindex $args 2]
   set box [lindex $args 3]
   set x1 [lindex $box 0]
   set y1 [lindex $box 1]
   set x2 [lindex $box 2]
   set y2 [lindex $box 3]
   if {$x2<$x1} {
      set dummy $x1
      set x1 $x2
      set x2 $dummy
   }
   if {$y2<$y1} {
      set dummy $y1
      set y1 $y2
      set y2 $dummy
   }
   set first 1
   set options ""
   if {$argc>=5} {
      set first "[lindex $args 4]"
      if {$argc>=6} {
         set options "[lrange $args 5 end]"
      }
   }
   set ni [expr $number+$first-1]
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" $first $ni \"$ext\" \"$path\" \"$out\" 1 \"$ext\"  WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"
   ttscript2 $script
}

proc calibwcs {args} {
   if {[llength $args] >= 5} {
      #--- Chargement des arguments
      set Angle_ra    [lindex $args 0]
      set Angle_dec   [lindex $args 1]
      set valpixsize1 [lindex $args 2]
      set valpixsize2 [lindex $args 3]
      set valfoclen   [lindex $args 4]
      set cat_format ""
      set cat_folder ""
      if {[llength $args] >= 7} {
         set cat_format [lindex $args 5]
         set cat_folder [lindex $args 6]
      }

      set pi [expr 4*atan(1.)]
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]

      if {$Angle_ra=="*"} {
         set Angle_ra [lindex [buf$::audace(bufNo) getkwd RA] 1]
      }
      if {$Angle_dec=="*"} {
         set Angle_dec [lindex [buf$::audace(bufNo) getkwd DEC] 1]
      }
      if {$valpixsize1=="*"} {
         set valpixsize1 [lindex [buf$::audace(bufNo) getkwd PIXSIZE1] 1]
      }
      if {$valpixsize2=="*"} {
         set valpixsize2 [lindex [buf$::audace(bufNo) getkwd PIXSIZE2] 1]
      }
      if {$valfoclen=="*"} {
         set valfoclen [lindex [buf$::audace(bufNo) getkwd FOCLEN] 1]
      }

      #--- Construction des parametres WCS
      set val(CRPIX1) [expr $naxis1/2]
      set val(CRPIX2) [expr $naxis2/2]
      set val(RA) [mc_angle2deg $Angle_ra 360]
      set val(DEC) [mc_angle2deg $Angle_dec 90]
      set val(CRVAL1) $val(RA)
      set val(CRVAL2) $val(DEC)
      set mult 1e-6
      set val(CDELT1) [expr -2*atan($valpixsize1/$valfoclen*$mult/2.)*180/$pi]
      set val(CDELT2) [expr  2*atan($valpixsize2/$valfoclen*$mult/2.)*180/$pi]
      set val(CROTA2) 0
      set val(FOCLEN) $valfoclen
      set val(PIXSIZE1) $valpixsize1
      set val(PIXSIZE2) $valpixsize2
      set cosr [expr cos($val(CROTA2)*$pi/180.)]
      set sinr [expr sin($val(CROTA2)*$pi/180.)]
      set val(CD1_1) [expr $val(CDELT1)*$cosr ]
      set val(CD1_2) [expr  abs($val(CDELT2))*$val(CDELT1)/abs($val(CDELT1))*$sinr ]
      set val(CD2_1) [expr -abs($val(CDELT1))*$val(CDELT2)/abs($val(CDELT2))*$sinr ]
      set val(CD2_2) [expr $val(CDELT2)*$cosr ]

      #--- Mise a jour du Header Fits
      set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2}
      set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              um                              um}
      set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        double         double                          double}
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included"}

      set n [llength $astrom(kwds)]
      for {set k 0 } { $k<$n } {incr k} {
         set kwd [lindex $astrom(kwds) $k]
         set value [eval set val($kwd)]
         set type [lindex $astrom(types) $k]
         set unit [lindex $astrom(units) $k]
         set comment [lindex $astrom(comments) $k]
         buf$::audace(bufNo) setkwd [list $kwd $value $type $unit $comment]
      }

      buf$::audace(bufNo) setkwd [list EQUINOX 2000 int "" "System of equatorial coordinates"]
      buf$::audace(bufNo) setkwd [list RADESYS FK5 string ""  "Mean Place IAU 1984 system"]
      buf$::audace(bufNo) setkwd [list LONPOLE 180 float "" "Long. of the celest.NP in native coor.sys" ]
      buf$::audace(bufNo) setkwd [list CTYPE1 RA---TAN string "" "Gnomonic projection" ]
      buf$::audace(bufNo) setkwd [list CTYPE2 DEC--TAN string "" "Gnomonic projection" ]
      buf$::audace(bufNo) setkwd [list CUNIT1 deg string  ""    "Angles are degrees always"   ]
      buf$::audace(bufNo) setkwd [list CUNIT2 deg string  ""    "Angles are degrees always"   ]
      buf$::audace(bufNo) setkwd [list CATASTAR 0 int ""    "Nb stars matched"   ]

      #--- check les catalogues
      if {[string toupper $cat_format] ni [list USNO MICROCAT]} {
         set comment "This catalog ($cat_format) is not valid. It must be only USNO or MICROCAT!"
         error $comment
      }
      if {[file exists $cat_folder]==1} {
         if {[string toupper $cat_format] eq "USNO"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain [file join $cat_folder "*.ACC"]]
            if {[llength $fics]==0} {
               error $comment
            }
            set fics [glob -nocomplain [file join $cat_folder "*.CAT"]]
            if {[llength $fics]==0} {
               error $comment
            }
         } elseif {[string toupper $cat_format] eq "MICROCAT"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain -dir [file join $cat_folder usno] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain -dir [file join $cat_folder tyc] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
         }
      } else {
         set comment "Path to the catalog does not exists:\n$cat_folder\n"
         error $comment
      }

      #--- Identification des sources
      if {($cat_format!="")} {
         set ext $::conf(extension,defaut)
         #--- Remplacement de "$::audace(rep_images)" par "." dans "mypath" - Cela permet a
         #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
         #--- espaces et ayant une longueur superieure a 70 caracteres
         set mypath "."
         set sky0 dummy0
         set cattype $cat_format
         set cdpath "$cat_folder"
         if { ( [ string length $cdpath ] > 0 ) && ( [ string index "$cdpath" end ] != "/" ) } {
            append cdpath "/"
         }
         set sky dummy
         catch {buf$::audace(bufNo) delkwd CATASTAR}
         buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         createFileConfigSextractor
         buf$::audace(bufNo) save [ file join ${mypath} ${sky}$ext ]
         sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"
         set erreur [ catch { ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}a.jpg\" " } msg ]
         if {$erreur==0} {
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY objefile=catalog.cat nullpixel=-10000 delta=5 epsilon=0.0002 file_ascii=ascii.txt"
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"z$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}b.jpg\" "
            ttscript2 "IMA/SERIES \"$mypath\" \"x$sky\" . . \"$ext\" . . . \"$ext\" DELETE"
            ttscript2 "IMA/SERIES \"$mypath\" \"c$sky\" . . \"$ext\" . . . \"$ext\" DELETE"
            buf$::audace(bufNo) load [ file join ${mypath} ${sky}$ext ]
         }
         ::astrometry::delete_lst
         ::astrometry::delete_dummy
         #---
      }
      #---
      ::audace::autovisu $::audace(visuNo)
      set catastar [lindex [buf$::audace(bufNo) getkwd CATASTAR] 1]
      return $catastar
   } else {
      error "Usage: calibwcs Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder"
   }
}

proc calibwcs2 {args} {
   if {[llength $args] >= 5} {
      set in [lindex $args 0]
      set out [lindex $args 1]
      set number [lindex $args 2]
      set Angle_ra [lindex $args 3]
      set Angle_dec [lindex $args 4]
      set valpixsize1 [lindex $args 5]
      set valpixsize2 [lindex $args 6]
      set valfoclen [lindex $args 7]
      set cat_format [lindex $args 8]
      set cat_folder [lindex $args 9]
      set first_index 1
      if {[llength $args] >= 9} {
         set first_index [lindex $args 10]
      }
      #---
      set kdeb $first_index
      set kfin [expr $kdeb+$number-1]
      for {set k $kdeb } { $k<=$kfin } {incr k} {
         #::console::affiche_resultat "Calibration WCS for ${out}${k}...\n"
         loadima ${in}${k}
         set catastar [calibwcs $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen $cat_format $cat_folder]
         saveima ${out}${k}
         ::console::affiche_resultat "Image ${out}${k} WCS calibrated with $catastar matched stars.\n"
      }
   } else {
      error "Usage: calibwcs2 in out number Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?first_index?"
   }
}

#--- Example : simulimage * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
#--- Example : simulimage * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0 REPLACE 164.630566 67.529504 8
proc simulimage {args} {
   if {[llength $args] >= 5} {
      set Angle_ra [lindex $args 0]
      set Angle_dec [lindex $args 1]
      set valpixsize1 [lindex $args 2]
      set valpixsize2 [lindex $args 3]
      set valfoclen [lindex $args 4]
      set cat_format ""
      set cat_folder ""
      if {[llength $args] >= 7} {
         set cat_format [lindex $args 5]
         set cat_folder [lindex $args 6]
      }
      set k 6
      incr k ; set exposure 1             ; if {[llength $args] >= [expr 1+$k]} { set exposure [lindex $args $k] }
      incr k ; set fwhm 2.5               ; if {[llength $args] >= [expr 1+$k]} { set fwhm [lindex $args $k] }
      incr k ; set teldiam 1              ; if {[llength $args] >= [expr 1+$k]} { set teldiam [lindex $args $k] }
      incr k ; set colfilter R            ; if {[llength $args] >= [expr 1+$k]} { set colfilter [lindex $args $k] }
      incr k ; set sky_brightness 20.9    ; if {[llength $args] >= [expr 1+$k]} { set sky_brightness [lindex $args $k] }
      incr k ; set quantum_efficiency 0.8 ; if {[llength $args] >= [expr 1+$k]} { set quantum_efficiency [lindex $args $k] }
      incr k ; set gain 2.5               ; if {[llength $args] >= [expr 1+$k]} { set gain [lindex $args $k] }
      incr k ; set readout_noise 10       ; if {[llength $args] >= [expr 1+$k]} { set readout_noise [lindex $args $k] }
      incr k ; set shutter_mode 1         ; if {[llength $args] >= [expr 1+$k]} { set shutter_mode [lindex $args $k] }
      incr k ; set bias_level 0           ; if {[llength $args] >= [expr 1+$k]} { set bias_level [lindex $args $k] }
      incr k ; set thermic_response 0     ; if {[llength $args] >= [expr 1+$k]} { set thermic_response [lindex $args $k] }
      incr k ; set tatm 0.6               ; if {[llength $args] >= [expr 1+$k]} { set tatm [lindex $args $k] }
      incr k ; set topt 0.85              ; if {[llength $args] >= [expr 1+$k]} { set topt [lindex $args $k] }
      incr k ; set elecmult 1             ; if {[llength $args] >= [expr 1+$k]} { set elecmult [lindex $args $k] }
      incr k ; set flat_type 0            ; if {[llength $args] >= [expr 1+$k]} { set flat_type [lindex $args $k] }
      incr k ; set newstar_type NONE      ; if {[llength $args] >= [expr 1+$k]} { set newstar_type [lindex $args $k] }
      incr k ; set newstar_ra 0           ; if {[llength $args] >= [expr 1+$k]} { set newstar_ra [string trim [mc_angle2deg [lindex $args $k]]] }
      incr k ; set newstar_dec 0          ; if {[llength $args] >= [expr 1+$k]} { set newstar_dec [string trim [mc_angle2deg [lindex $args $k] 90]] }
      incr k ; set newstar_mag 0          ; if {[llength $args] >= [expr 1+$k]} { set newstar_mag [lindex $args $k] }

      #--- check les catalogues
      if {[string toupper $cat_format] ni [list USNO MICROCAT]} {
         set comment "This catalog ($cat_format) is not valid. It must be only USNO or MICROCAT!"
         error $comment
      }
      if {[file exists $cat_folder]==1} {
         if {[string toupper $cat_format] eq "USNO"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain [file join $cat_folder "*.ACC"]]
            if {[llength $fics]==0} {
               error $comment
            }
            set fics [glob -nocomplain [file join $cat_folder "*.CAT"]]
            if {[llength $fics]==0} {
               error $comment
            }
         } elseif {[string toupper $cat_format] eq "MICROCAT"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain -dir [file join $cat_folder usno] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain -dir [file join $cat_folder tyc] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
         }
      } else {
         set comment "Path to the catalog does not exists:\n$cat_folder\n"
         error $comment
      }

      #---
      set pi [expr 4*atan(1.)]
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      if {$Angle_ra!="*"} {
         set val(CRPIX1) [expr $naxis1/2]
         set val(CRPIX2) [expr $naxis2/2]
         set val(RA) [mc_angle2deg $Angle_ra 360]
         set val(DEC) [mc_angle2deg $Angle_dec 90]
         set val(CRVAL1) $val(RA)
         set val(CRVAL2) $val(DEC)
         set mult 1e-6
         set val(CDELT1) [expr -2*atan($valpixsize1/$valfoclen*$mult/2.)*180/$pi]
         set val(CDELT2) [expr  2*atan($valpixsize2/$valfoclen*$mult/2.)*180/$pi]
         set val(CROTA2) 0
         set val(FOCLEN) valfoclen
         set val(PIXSIZE1) valpixsize1
         set val(PIXSIZE2) valpixsize2
         set cosr [expr cos($val(CROTA2)*$pi/180.)]
         set sinr [expr sin($val(CROTA2)*$pi/180.)]
         set val(CD1_1) [expr $val(CDELT1)*$cosr ]
         set val(CD1_2) [expr  abs($val(CDELT2))*$val(CDELT1)/abs($val(CDELT1))*$sinr ]
         set val(CD2_1) [expr -abs($val(CDELT1))*$val(CDELT2)/abs($val(CDELT2))*$sinr ]
         set val(CD2_2) [expr $val(CDELT2)*$cosr ]
         #---
         set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2}
         set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              um                              um}
         set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        double         double                          double}
         set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included"}
         #---
         set n [llength $astrom(kwds)]
         for {set k 0 } { $k<$n } {incr k} {
            set kwd [lindex $astrom(kwds) $k]
            set value [eval set val($kwd)]
            set type [lindex $astrom(types) $k]
            set unit [lindex $astrom(units) $k]
            set comment [lindex $astrom(comments) $k]
            buf$::audace(bufNo) setkwd [list $kwd $value $type $unit $comment]
         }
      }
      buf$::audace(bufNo) setkwd [list EQUINOX 2000 int "" "System of equatorial coordinates"]
      buf$::audace(bufNo) setkwd [list RADESYS FK5 string "" "Mean Place IAU 1984 system"]
      buf$::audace(bufNo) setkwd [list LONPOLE 180 float "" "Long. of the celest.NP in native coor.sys"]
      buf$::audace(bufNo) setkwd [list CTYPE1 RA---TAN string "" "Gnomonic projection"]
      buf$::audace(bufNo) setkwd [list CTYPE2 DEC--TAN string "" "Gnomonic projection"]
      buf$::audace(bufNo) setkwd [list CUNIT1 deg string "" "Angles are degrees always"]
      buf$::audace(bufNo) setkwd [list CUNIT2 deg string "" "Angles are degrees always"]
      buf$::audace(bufNo) setkwd [list CATASTAR 0 int "" "Nb stars matched"]
      #---
      if {($cat_format!="")} {
         set mypath "."
         set cattype $cat_format
         set cdpath "$cat_folder"
         if { ( [ string length $cdpath ] > 0 ) && ( [ string index "$cdpath" end ] != "/" ) } {
            append cdpath "/"
         }
         #::console::affiche_resultat "CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/cata.fit\" simulimage exposure=$exposure fwhmx=$fwhm  fwhmy=$fwhm teldiam=$teldiam colfilter=$colfilter sky_brightness=$sky_brightness qe=$quantum_efficiency gain=$gain readout_noise=$readout_noise shutter_mode=$shutter_mode bias_level=$bias_level thermic_response=$thermic_response tatm=$tatm topt=$topt elecmult=$elecmult flat_type=$flat_type newstar=$newstar_type ra=$newstar_ra dec=$newstar_dec mag=$newstar_mag"
         buf$::audace(bufNo) imaseries "CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/cata.fit\" simulimage exposure=$exposure fwhmx=$fwhm  fwhmy=$fwhm teldiam=$teldiam colfilter=$colfilter sky_brightness=$sky_brightness qe=$quantum_efficiency gain=$gain readout_noise=$readout_noise shutter_mode=$shutter_mode bias_level=$bias_level thermic_response=$thermic_response tatm=$tatm topt=$topt elecmult=$elecmult flat_type=$flat_type newstar=$newstar_type ra=$newstar_ra dec=$newstar_dec mag=$newstar_mag"
         file delete [ file join ${mypath} cata.fit ]
      }
      ::audace::autovisu $::audace(visuNo)
      #set catastar [lindex [buf$::audace(bufNo) getkwd CATASTAR] 1]
      return ""
   } else {
      error "Usage: simulimage Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type? ?newstar_type? ?newstar_ra? ?newstar_dec? ?newstar_mag?"
   }
}

#--- Example 1 : from an images ever loaded
# source "$audace(rep_install)/gui/audace/surchaud.tcl" ; simulimage2 test [mc_date2listdates 2011-11-11T00:00:00 0.021 100] {FOURIER 164.630566 67.529504 2011-11-08T00:00:00 0.28 12.5 -0.86 -0.53 -0.45 0.32 0.039 0.021} * * * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
#--- Example 2 :  from scratch
# source "$audace(rep_install)/gui/audace/surchaud.tcl"
# simulimage2 test [mc_date2listdates 2011-11-11T00:00:00 0.021 100] {FOURIER 164.630566 67.529504 2011-11-08T00:00:00 0.28 12.5 -0.86 -0.53 -0.45 0.32 0.039 0.021} 200 200 164.589733 67.515479 13.5 13.5 0.84587 USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
# photrel_wcs2cat test 100 new ; photrel_cat2var test ; photrel_cat2per test test 164.630637 67.529499 C 0
proc simulimage2 {args} {
   set pi [expr 4.*atan(1)]
   if {[llength $args] >= 5} {
      set arg0s [lrange $args 5 end]
      set naxis1 [lindex $args 3]
      set naxis2 [lindex $args 4]
      if {($naxis1!="*")&&($naxis2!="*")} {
         buf$::audace(bufNo) new CLASS_GRAY $naxis1 $naxis2 FORMAT_SHORT COMPRESS_NONE
         buf$::audace(bufNo) setkwd { NAXIS 2 int "" "" }
      }
      saveima tmp
      set out [lindex $args 0]
      set ListDates [lindex $args 1] ; # dates-obs UTC
      set variable_type [lindex $args 2]
      set exposure [lindex $arg0s 7]
      if {$exposure==""} {
         set exposure [lindex [buf$::audace(bufNo) getkwd EXPOSURE] 1]
      }
      if {$exposure==""} {
         set exposure [lindex [buf$::audace(bufNo) getkwd EXPTIME] 1]
      }
      if {$exposure==""} {
         set exposure 1
      }
      set filter [lindex $arg0s 10]
      if {$filter==""} {
         set filter [lindex [buf$::audace(bufNo) getkwd FILTER] 1]
      }
      if {$filter==""} {
         set filter R
      }
      set key [string toupper [lindex $variable_type 0]]
      set ra 0
      set dec 0
      if {$key=="FOURIER"} {
         # FOURIER ra dec jdphase c ?a1? ?b1? ?a2? ?b2? ?a3? ?b3? ?a4? ?b4? ?a5? ?b5?
         set ra [mc_angle2deg [lindex $variable_type 1]]
         set dec [mc_angle2deg [lindex $variable_type 2] 90]
         set jdphase [mc_date2jd [lindex $variable_type 3]] ; # HJD
         set period [lindex $variable_type 4] ; # day
         set four_c [lindex $variable_type 5] ; # mag
         set kk 1
         for {set k 6} {$k<[expr 6+5*2]} {incr k 2} {
            set four_a($kk) [lindex $variable_type [expr $k+0]] ; # mag
            set four_b($kk) [lindex $variable_type [expr $k+1]] ; # mag
            if {$four_a($kk)==""} { set four_a($kk) 0 }
            if {$four_b($kk)==""} { set four_b($kk) 0 }
            incr kk
         }
      }
      if {$key=="SN"} {
         # SN Ia ra dec jdmax magVmax
         set sntype [string toupper [lindex $variable_type 1]]
         set ra [mc_angle2deg [lindex $variable_type 2]]
         set dec [mc_angle2deg [lindex $variable_type 3] 90]
         set jdmax [mc_date2jd [lindex $variable_type 4]]
         set magmax [lindex $variable_type 5]
      }
      # --- Compute HJD
      set nd [llength $ListDates]
      set dates ""
      for {set k 0} {$k<$nd} {incr k} {
         set date [lindex $ListDates $k] ; # date-obs UTC
         set date [mc_datescomp $date + [expr $exposure/2./86400.]]
         lappend dates $date
      }
      # --- correction of time : JD UT-terrestrial -> barycentrical of the solar system
      set hjds [mc_dates_ut2bary $dates $ra $dec J2000.0]
      # --- Compute mags
      set mags ""
      if {$key=="FOURIER"} {
         for {set kk 1} {$kk<=5} {incr kk} {
            #::console::affiche_resultat "$kk => $four_a($kk) $four_b($kk)\n"
         }
         for {set k 0} {$k<$nd} {incr k} {
            set hjd [lindex $hjds $k]
            set phase [expr 1.*($hjd-$jdphase)/$period]
            set phase [expr $phase-floor($phase)]
            set mag $four_c
            for {set kk 1} {$kk<=5} {incr kk} {
               set mag [expr $mag + $four_a($kk)*cos(2*$pi*$kk*$phase) + $four_a($kk)*sin(2*$pi*$kk*$phase)]
            }
            lappend mags $mag
         }
      } elseif {$key=="SN"} {
         # From http://supernova.lbl.gov/~nugent/nugent_templates.html
         # template $audace(rep_catalogues)/cataphotom/sn1a_lc.v1.2.dat
         set fic sn1a_lc.v1.2.dat ; set ffs [list U B V R I J H K]
         if {$sntype=="IA"} { set fic sn1a_lc.v1.2.dat ; set ffs [list U B V R I J H K] }
         if {$sntype=="IBC"} { set fic sn1bc_lc.v1.1.dat ; set ffs [list U B V R I] }
         if {$sntype=="IC"} { set fic hyper_lc.v1.2.dat  ; set ffs [list V]}
         if {$sntype=="IIP"} { set fic sn2p_lc.v1.2.dat  ; set ffs [list V]}
         if {$sntype=="IIL"} { set fic sn2l_lc.v1.2.dat  ; set ffs [list V]}
         if {$sntype=="IIN"} { set fic sn2n_lc.v2.1.dat  ; set ffs [list V]}
         if {$sntype=="91BG"} { set fic sn91bg_lc.v1.1.dat ; set ffs [list U B V R I] }
         if {$sntype=="91T"} { set fic sn91t_lc.v1.1.dat ; set ffs [list U B V R I] }
         set kf [lsearch -exact $ffs $filter]
         if {$kf==-1} { set kf 0 }
         incr kf
         set f [open $::audace(rep_catalogues)/cataphotom/$fic r]
         set lignes [split [read $f] \n]
         close $f
         set template_dts ""
         set template_mags ""
         set nt 0
         foreach ligne $lignes {
            if {[llength $ligne]<=1} { continue }
            lappend template_dts [lindex $ligne 0]
            lappend template_mags [lindex $ligne $kf]
            incr nt
         }
         set template_dt1 [lindex $template_dts 0]
         set template_dt2 [lindex $template_dts end]
         set template_dt20 [lindex $template_dts end-1]
         set template_mag2 [lindex $template_mags end]
         set template_mag20 [lindex $template_mags end-1]
         for {set k 0} {$k<$nd} {incr k} {
            set hjd [lindex $hjds $k]
            set dt [expr $hjd-$jdmax]
            if {$dt<=$template_dt1} {
               set mag [expr $magmax+[lindex $template_mags 0]]
            } elseif {$dt>=$template_dt20} {
               set frac [expr 1.*($dt-$template_dt20)/($template_dt2-$template_dt20)]
               set mag [expr $magmax+$template_mag20 + $frac * ($template_mag2-$template_mag20)]
            } else {
               for {set kt 0} {$kt<[expr $nt-1]} {incr kt} {
                  set template_dt0 [lindex $template_dts $kt]
                  set template_dt [lindex $template_dts [expr $kt+1]]
                  if {($dt>=$template_dt0)&&($dt<$template_dt)} {
                     set template_mag0 [lindex $template_mags $kt]
                     set template_mag [lindex $template_mags [expr $kt+1]]
                     set frac [expr 1.*($dt-$template_dt0)/($template_dt-$template_dt0)]
                     set mag [expr $magmax+$template_mag0 + $frac * ($template_mag-$template_mag0)]
                     break
                  }
               }
            }
            lappend mags $mag
         }
      } else {
         for {set k 0} {$k<$nd} {incr k} {
            lappend mags 12.5
         }
      }
      catch {::plotxy::clf}
      ::plotxy::plot $hjds $mags o
      ::plotxy::ydir reverse
      # --- Loop over images
      for {set k 0} {$k<$nd} {incr k} {
         set k1 [expr $k+1]
         buf$::audace(bufNo) load $::audace(rep_images)/tmp
         set mag [lindex $mags $k]
         set dateobs [mc_date2iso8601 [lindex $ListDates $k]]
         ::console::affiche_resultat "Build image ${out}$k1 : $dateobs $mag\n"
         buf$::audace(bufNo) setkwd [list DATE-OBS $dateobs string ISO8601 "Star of exposure"]
         buf$::audace(bufNo) setkwd [list EXPOSURE $exposure double s "Time of exposure"]
         set toeval "simulimage"
         foreach arg0 $arg0s {
            append toeval " \{$arg0\}"
         }
         append toeval " REPLACE $ra $dec $mag"
         #::console::affiche_resultat "$toeval\n"
         eval $toeval
         saveima ${out}$k1
         update
      }
   } else {
      error "Usage: simulimage2 out ListDatesObsUTC variable_type naxis1 naxis2 Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type?"
   }
}

