#
# Fichier : surchaud.tcl
# Description : Surcharge des fonctions de AudeLA pour les rendre compatibles avec l'usage des repertoires de travail
# Auteur : Alain KLOTZ
# Mise a jour $Id: surchaud.tcl,v 1.31 2008-05-29 21:43:26 robertdelmas Exp $
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
# window1 in out {x1 y1 x2 y2} ?tt_options?
# window2 in out number {x1 y1 x2 y2} ?first_index? ?tt_options?
#

proc add {args} {
   #--- operand value
   global audace

   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $audace(rep_images)]-1]
      if {(($len>=0)&&($diroperand=="."))} {
         set car [string index $audace(rep_images) $len]
         if {$car!="/"} {
            set operand "$audace(rep_images)/$operand"
         } else {
            set operand "$audace(rep_images)$operand"
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      buf$audace(bufNo) add "$operand" [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: add operand value"
   }
}

proc add1 {args} {
   #--- in operand out const ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: add1 in operand out const ?tt_options?"
   }
}

proc add2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
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
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: add2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc convgauss {args} {
   #--- sigma
   global audace

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: convgauss sigma"
   }
}

proc convgauss2 {args} {
   #--- in out number sigma ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CONV kernel_type=gaussian sigma=$[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: convgauss2 in out number sigma ?first_index? ?tt_options?"
   }
}

proc delete2 {args} {
   #--- in number
   global audace

   if {[llength $args] == 2} {
      set ext [buf$audace(bufNo) extension]
      set cmp [buf$audace(bufNo) compress]
      if {$cmp=="none"} {
         set cmp ""
      } else {
         set cmp ".gz"
      }
      set kdeb 1
      set kfin [lindex $args 1]
      for {set k $kdeb} {$k<=$kfin} {incr k} {
         set filename "$audace(rep_images)/[lindex $args 0]${k}${ext}${cmp}"
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
   global audace

   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $audace(rep_images)]-1]
      if {(($len>=0)&&($diroperand=="."))} {
         set car [string index $audace(rep_images) $len]
         if {$car!="/"} {
            set operand "$audace(rep_images)/$operand"
         } else {
            set operand "$audace(rep_images)$operand"
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      buf$audace(bufNo) div "$operand" [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: div operand value"
   }
}

proc div1 {args} {
   #--- in operand out const ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: div1 in operand out const ?tt_options?"
   }
}

proc div2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
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
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: div2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc mult {args} {
   #--- const
   global audace

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "MULT constant=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mult const"
   }
}

proc mult1 {args} {
   #--- in out const ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=3} {
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MULT constant=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: mult1 in out const ?tt_options?"
   }
}

proc mult2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" MULT constant=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: mult2 in out const number ?first_index? ?tt_options?"
   }
}

proc ngain1 {args} {
   #--- in out const ?tt_options?
   global audace

   set n [llength $args]
   if {($n>=3)} {
      set ext [buf$audace(bufNo) extension]
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" NORMGAIN normgain_value=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: ngain1 in out const ?tt_options?"
   }
}

proc ngain2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {($n>=4)} {
      set ext [buf$audace(bufNo) extension]
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
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMGAIN normgain_value=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: ngain2 in out const number ?first_index? ?tt_options?"
   }
}

proc noffset1 {args} {
   #--- in out const ?tt_options?
   global audace

   set n [llength $args]
   if {($n>=3)} {
      set ext [buf$audace(bufNo) extension]
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: noffset1 in out const ?tt_options?"
   }
}

proc noffset2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {($n>=4)} {
      set ext [buf$audace(bufNo) extension]
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
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: noffset2 in out const number ?first_index? ?tt_options?"
   }
}

proc offset {args} {
   #--- value
   global audace

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "OFFSET offset=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: offset value"
   }
}

proc offset1 {args} {
   #--- in out const ?tt_options?
   global audace

   set n [llength $args]
   if {($n>=3)} {
      set ext [buf$audace(bufNo) extension]
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" OFFSET offset=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: offset1 in out const ?tt_options?"
   }
}

proc offset2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {($n>=4)} {
      set ext [buf$audace(bufNo) extension]
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
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" OFFSET offset=[lindex $args 2] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: offset2 in out const number ?first_index? ?tt_options?"
   }
}

proc opt {args} {
   #--- dark offset
   global audace

   if {[llength $args] == 2} {
      set len [expr [string length $audace(rep_images)]-1]
      set dark [lindex $args 0]
      set dirdark [file dirname "$dark"]
      if {(($len>=0)&&($dirdark=="."))} {
         set car [string index $audace(rep_images) $len]
         if {$car!="/"} {
            set dark   "$audace(rep_images)/$dark"
         } else {
            set dark   "$audace(rep_images)$dark"
         }
      }
      set ext [file extension "$dark"]
      if {$ext==""} {
         set dark "${dark}[buf$audace(bufNo) extension]"
      }
      set offset [lindex $args 1]
      set diroffset [file dirname "$offset"]
      if {(($len>=0)&&($diroffset=="."))} {
         set car [string index $audace(rep_images) $len]
         if {$car!="/"} {
            set offset "$audace(rep_images)/$offset"
         } else {
            set offset "$audace(rep_images)$offset"
         }
      }
      set ext [file extension "$offset"]
      if {$ext==""} {
         set offset "${offset}[buf$audace(bufNo) extension]"
      }
      buf$audace(bufNo) opt "$dark" "$offset"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: opt dark offset"
   }
}

proc opt1 {args} {
   #--- in dark offset out ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set dark "$operand"
      set operand [lindex $args 2]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set offset "$operand"
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 3]\" . \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 3]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 3]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: opt1 in dark offset out ?tt_options?"
   }
}

proc opt2 {args} {
   #--- in dark offset out number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set dark "$operand"
      set operand [lindex $args 2]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
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
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set offset "$operand"
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 3]\" 1 \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 3]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 3]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: opt2 in dark offset out number ?first_index? ?tt_options?"
   }
}

proc prod {args} {
   #--- operand value
   global audace

   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $audace(rep_images)]-1]
      if {(($len>=0)&&($diroperand=="."))} {
         set car [string index $audace(rep_images) $len]
         if {$car!="/"} {
            set operand "$audace(rep_images)/$operand"
         } else {
            set operand "$audace(rep_images)$operand"
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      buf$audace(bufNo) imaseries "PROD \"file=$operand\" constant=[lindex $args 1]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: prod operand value"
   }
}

proc register {args} {
   #--- in out number ?-box {x1 y1 x2 y2}? ?tt_options?
   #--- options : "tt options" or -box {x1 y1 x2 y2}
   global audace

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
   set ext "[buf$audace(bufNo) extension]"
   set path "$audace(rep_images)"
   if {$method=="tt"} {
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$path\" \"$in\" $first $number \"$ext\" \"$path\" \"$objefile\" $first \"$ext\" STAT objefile"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" $first $number \"$ext\" \"$path\" \"$out\" $first \"$ext\" REGISTER translate=only $options"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" $first $number \"$ext\" \"$path\" \"$objefile\" $first \"$ext\" DELETE"
   } else {
      set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$number} {incr k} {
         buf$audace(bufNo) load ${path}/${in}${k}${ext}
         set res [buf$audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
      }
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$number} {incr k} {
         set kk [expr $k-$first]
         buf$audace(bufNo) load ${path}/${in}${k}${ext}
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$audace(bufNo) save ${path}/${out}${k}${ext}
      }
   }
}

proc register2 {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" STAT objefile $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER translate=never $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" DELETE $options"
   } else {
      error "Usage: register2 in out number ?first_index? ?tt_options?"
   }
}

proc registerbox {args} {
   #--- in out number ?visuNo? ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      set path "$audace(rep_images)"
      set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$ni} {incr k} {
         buf$audace(bufNo) load ${path}/${in}${k}${ext}
         set res [buf$audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
      }
      ::console::affiche_saut "\n"
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$ni} {incr k} {
         set kk [expr $k-$first]
         buf$audace(bufNo) load ${path}/${in}${k}${ext}
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$audace(bufNo) save ${path}/${out}${k}${ext}
      }
   } else {
      error "Usage: registerbox in out number ?visuNo? ?first_index? ?tt_options?"
      return $error;
   }
}

proc registerfine {args} {
   #--- in out number ?delta? ?oversampling? ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTERFINE oversampling=$oversampling delta=$delta \"file=$audace(rep_images)/[lindex $args 0]${first}${ext}\" $options"
   } else {
      error "Usage: registerfine in out number ?delta? ?oversampling? ?first_index? ?tt_options?"
   }
}

proc registerwcs {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER matchwcs $options"
   } else {
      error "Usage: registerwcs in out number ?first_index? ?tt_options?"
   }
}

proc sadd {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" ADD $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: sadd in out number ?first_index? ?tt_options?"
   }
}

proc scale1 {args} {
   #--- in out scale_x scale_y ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=4} {
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" RESAMPLE \"paramresample=[lindex $args 2] 0 0 0 [lindex $args 3] 0\" normaflux=1 $options"
   } else {
      error "Usage: scale1 in out scale_x scale_y ?tt_options?"
   }
}

proc scale2 {args} {
   #--- in out number scale_x scale_y ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" RESAMPLE \"paramresample=[lindex $args 3] 0 0 0 [lindex $args 4] 0\" normaflux=1 $options"
   } else {
      error "Usage: scale2 in out number scale_x scale_y ?first_index? ?tt_options?"
   }
}

proc smean {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MEAN $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: smean in out number ?first_index? ?tt_options?"
   }
}

proc smedian {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MED $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: smedian in out number ?first_index? ?tt_options?"
   }
}

proc sprod {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" PROD $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: sprod in out number ?first_index? ?tt_options?"
   }
}

proc spythagore {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" PYTHAGORE $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: spythagore in out number ?first_index? ?tt_options?"
   }
}

proc ssigma {args} {
   #--- in out number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SIG $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: ssigma in out number ?first_index? ?tt_options?"
   }
}

proc ssk {args} {
   #--- in out number kappa ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SK kappa=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: ssk in out number kappa ?first_index? ?tt_options?"
   }
}

proc ssort {args} {
   #--- in out number percent ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SORT percent=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: ssort in out number percent ?first_index? ?tt_options?"
   }
}

proc sub {args} {
   #--- operand value
   global audace

   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $audace(rep_images)]-1]
      if {(($len>=0)&&($diroperand=="."))} {
         set car [string index $audace(rep_images) $len]
         if {$car!="/"} {
            set operand "$audace(rep_images)/$operand"
         } else {
            set operand "$audace(rep_images)$operand"
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      buf$audace(bufNo) sub "$operand" [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: sub operand value"
   }
}

proc sub1 {args} {
   #--- in operand out const ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: sub1 in operand out const ?tt_options?"
   }
}

proc sub2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   global audace

   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set operand "$audace(rep_images)/$operand"
            } else {
               set operand "$audace(rep_images)$operand"
            }
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
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: sub2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc subdark2 {args} {
   #--- in dark offset out number exptime dexptime ?first_index?
   global audace

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
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set dark "$audace(rep_images)/$dark"
            } else {
               set dark "$audace(rep_images)$dark"
            }
         }
      }

      if {[file dirname $offset]=="."} {
         set len [expr [string length $audace(rep_images)]-1]
         if {$len>=0} {
            set car [string index $audace(rep_images) $len]
            if {$car!="/"} {
               set offset "$audace(rep_images)/$offset"
            } else {
               set offset "$audace(rep_images)$offset"
            }
         }
      }

      set ext [file extension "$dark"]
      if {$ext==""} {
         set operand "${dark}[buf$audace(bufNo) extension]"
      }

      set ni [expr [lindex $args 4]+$first-1]
      set ext [buf$audace(bufNo) extension]
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
      set command "IMA/SERIES \"$audace(rep_images)\" \"$in\" $first $ni \"$ext\" \"$audace(rep_images)\" \"$out\" 1 \"$ext\" SUBDARK \"dark=$dark\" \"bias=$offset\" \"exptime=$exptime\" \"dexptime=$dexptime\" "
      ::console::disp "subdark2 : $command\n"
      ttscript2 $command
   } else {
      #---                    0  1     2     3    4       5      6           7            8
      error "Usage: subdark2 in dark offset out number exptime dexptime ?first_index?"
   }
}

proc subsky {args} {
   #--- back_kernel back_threshold ?tt_options?
   global audace

   set argc [llength $args]
   if { $argc < 2} {
      error "Usage: subsky back_kernel back_threshold ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande source audace/surchaud.tcl ; subsky 20 0.20 40
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
   buf$audace(bufNo) imaseries "back back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
}

proc subsky1 {args} {
   #--- in out back_kernel back_threshold ?tt_options?
   global audace

   set argc [llength $args]
   if { $argc < 4} {
      error "Usage: subsky1 in out back_kernel back_threshold ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande source audace/surchaud.tcl ; subsky2 ic a 20 0.20 40
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
   set ext "[buf$audace(bufNo) extension]"
   set path "$audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\" BACK back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
   #::console::affiche_resultat "$script\n"
   ttscript2 $script
  ### ttscript2  "IMA/SERIES \"$path\" \"$out\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO $options"
}

proc subsky2 {args} {
   #--- in out number back_kernel back_threshold ?first_index? ?tt_options?"
   global audace

   set argc [llength $args]
   if { $argc < 5} {
      error "Usage: subsky2 in out number back_kernel back_threshold ?first_index? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande source audace/surchaud.tcl ; subsky2 ic a 10 20 0.20 40
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
   set ext "[buf$audace(bufNo) extension]"
   set path "$audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" $first $ni \"$ext\" \"$path\" \"$out\" 1 \"$ext\" BACK back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
   #::console::affiche_resultat "$script\n"
   ttscript2 $script
  ### ttscript2  "IMA/SERIES \"$path\" \"$out\" 1 $number \"$ext\" \"$path\" \"$out\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO $options"
}

proc trans {args} {
   #--- dx dy
   global audace

   if {[llength $args] == 2} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "TRANS trans_x=[lindex $args 0] trans_y=[lindex $args 1]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: trans dx dy"
   }
}

proc trans2 {args} {
   #--- in out dx dy number ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" TRANS trans_x=[lindex $args 2] trans_y=[lindex $args 3] $options"
     ### ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT $options"
   } else {
      error "Usage: trans2 in out dx dy number ?first_index? ?tt_options?"
   }
}

proc uncosmic {args} {
   #--- coef
   global audace

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: uncosmic coef"
   }
}

proc uncosmic2 {args} {
   #--- in out number coef ?first_index? ?tt_options?
   global audace

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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 3] $options"
   } else {
      error "Usage: uncosmic2 in out number coef ?first_index? ?tt_options?"
   }
}

proc window1 {args} {
   #--- in out {x1 y1 x2 y2} ?tt_options?
   global audace

   set argc [llength $args]
   if { $argc < 3} {
      error "Usage: window1 in out {x1 y1 x2 y2} ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande source audace/surchaud.tcl ; window2 ic a {50 50 100 100}
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
   set ext "[buf$audace(bufNo) extension]"
   set path "$audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\"  WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"
   #::console::affiche_resultat "$script\n"
   ttscript2 $script
  ### ttscript2  "IMA/SERIES \"$path\" \"$out\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO $options"
}

proc window2 {args} {
   #--- in out number {x1 y1 x2 y2} ?first_index? ?tt_options?
   global audace

   set argc [llength $args]
   if { $argc < 4} {
      error "Usage: window2 in out number {x1 y1 x2 y2} ?first_index? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande source audace/surchaud.tcl ; window2 ic a 2 {50 50 100 100}
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
   set ext "[buf$audace(bufNo) extension]"
   set path "$audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" $first $ni \"$ext\" \"$path\" \"$out\" 1 \"$ext\"  WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"
   #::console::affiche_resultat "$script\n"
   ttscript2 $script
  ### ttscript2  "IMA/SERIES \"$path\" \"$out\" 1 $number \"$ext\" \"$path\" \"$out\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO $options"
}

