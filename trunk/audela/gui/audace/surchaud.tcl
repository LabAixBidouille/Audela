#
# Fichier : surchaud.tcl
# Description : Surcharge des fonctions de AudeLA pour les rendre compatibles avec l'usage des repertoires de travail
# Auteur  : Alain KLOTZ
# Mise a jour $Id: surchaud.tcl,v 1.3 2006-06-20 17:36:17 robertdelmas Exp $
#
# offset  val
# offset2  in out const nb
# ngain2  in out const nb
# noffset2  in out const nb
# add  operand value
# add2  in operand out const nb
# sub  operand value
# sub2  in operand out const nb
# div  operand value
# div2  in operand out const nb
# opt  dark bias
# opt2  in dark bias out const nb
# delete2  in nb
# register  in out number
# register2  in out number
# registerwcs  in out number
# smedian  in out number
# sadd  in out number
# ssigma  in out number
# smean  in out number
# ssk  in out number
# ssort  in out number
# uncosmic  coef
# uncosmic2  in out number coef
# convgauss  sigma
# convgauss2  in out number sigma
# mult  constant
# mult2  in out const nb
# trans  dx dy
# trans2  in out number dx dy
#

proc offset {args} {
   # constant
   global audace
   global caption

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "OFFSET offset=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage : offset val"
   }
}

proc offset2 {args} {
   # in out const nb
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" OFFSET offset=[lindex $args 2]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : offset2 in out const nb"
   }
}

proc ngain2 {args} {
   # in out const nb
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMGAIN normgain_value=[lindex $args 2]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : ngain2 in out const nb"
   }
}

proc noffset2 {args} {
   # in out const nb
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : noffset2 in out const nb"
   }
}

proc add {args} {
   # image val
   global audace
   global caption

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
      error "Usage : add image val"
   }
}

proc add2 {args} {
   # in operand out const nb
   global audace
   global caption

   set n [llength $args]
   if {($n>=5)&&($n<=6)} {
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
      if {$n==6} {
         set options "[lindex $args 5]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : add2 in operand out const nb ?tt_options?"
   }
}

proc sub {args} {
   # image val
   global audace
   global caption

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
      error "Usage : sub image val"
   }
}

proc sub2 {args} {
   # in operand out const nb
   global audace
   global caption

   if {[llength $args] == 5} {
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
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : sub2 in operand out const nb"
   }
}

proc div {args} {
   # image val
   global audace
   global caption

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
      error "Usage : div image val"
   }
}

proc div2 {args} {
   # in operand out const nb
   global audace
   global caption

   set n [llength $args]
   if {($n>=5)&&($n<=6)} {
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
      if {$n==6} {
         set options "[lindex $args 5]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 2]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : div2 in operand out const nb ?tt_options?"
   }
}

proc opt {args} {
   # dark offset
   global audace
   global caption

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
      error "Usage : opt dark offset"
   }
}

proc opt2 {args} {
   # in dark offset out nb
   global audace
   global caption

   if {[llength $args] == 5} {
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
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}[buf$audace(bufNo) extension]"
      }
      set offset "$operand"
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 3]\" 1 \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" "
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 3]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 3]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : opt2 in dark offset out nb"
   }
}

proc delete2 {args} {
   # in nb
   global audace
   global caption

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
      error "Usage : delete2 in nb"
   }
}

proc register {args} {
   # in out number ?options?
   # options : "tt options" or -box {x1 y1 x2 y2}
   global audace
   global caption

   set argc [llength $args]
   if { $argc < 3} {
      error "Usage : register in out number ?options?"
      return $error;
   }
   # --- decode la ligne de commande
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
         set options [lindex $args 3]
      }
   }
   set ext "[buf$audace(bufNo) extension]"
   set path "$audace(rep_images)"
   if {$method=="tt"} {
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$path\" \"$in\" 1 $number \"$ext\" \"$path\" \"$objefile\" 1 \"$ext\" STAT objefile"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" 1 $number \"$ext\" \"$path\" \"$out\" 1 \"$ext\" REGISTER translate=only $options"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" 1 $number \"$ext\" \"$path\" \"$objefile\" 1 \"$ext\" DELETE"
   } else {
      set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k 1} {$k<=$number} {incr k} {
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
      for {set k 1} {$k<=$number} {incr k} {
         set kk [expr $k-1]
         buf$audace(bufNo) load ${path}/${in}${k}${ext}
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$audace(bufNo) save ${path}/${out}${k}${ext}
      }
   }
}

proc register2 {args} {
   # in out number
   global audace
   global caption

   if {[llength $args] == 3} {
      set ext [buf$audace(bufNo) extension]
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" STAT objefile"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER translate=never"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" DELETE"
   } else {
      error "Usage : register2 in out number"
   }
}

proc registerwcs {args} {
   # in out number
   global audace
   global caption

   if {[llength $args] == 3} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER matchwcs"
   } else {
      error "Usage : registerwcs in out number"
   }
}

proc smedian {args} {
   # in out number
   global audace
   global caption

   if {[llength $args] == 3} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MED"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : smedian in out number"
   }
}

proc sadd {args} {
   # in out number
   global audace
   global caption

   set n [llength $args]
   if {($n>=3)&&($n<=4)} {
      set options ""
      if {$n==4} {
         set options "[lindex $args 3]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" ADD $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : sadd in out number ?tt_options?"
   }
}

proc ssigma {args} {
   # in out number
   global audace
   global caption

   set n [llength $args]
   if {($n>=3)&&($n<=4)} {
      set options ""
      if {$n==4} {
         set options "[lindex $args 3]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SIG $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : ssigma in out number ?tt_options?"
   }
}

proc smean {args} {
   # in out number
   global audace
   global caption

   if {[llength $args] == 3} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MEAN"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : smean in out number"
   }
}

proc ssk {args} {
   # in out number kappa
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SK kappa=[lindex $args 3]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : ssk in out number kappa"
   }
}

proc ssort {args} {
   # in out number percent
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/STACK \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SORT percent=[lindex $args 3]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" . . \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : ssort in out number percent"
   }
}

proc uncosmic {args} {
   # coef
   global audace
   global caption

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage : uncosmic coef"
   }
}

proc uncosmic2 {args} {
   # in out number coef
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 3]"
   } else {
      error "Usage : uncosmic2 in out number coef"
   }
}

proc convgauss {args} {
   # sigma
   global audace
   global caption

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage : convgauss sigma"
   }
}

proc convgauss2 {args} {
   # in out number sigma
   global audace
   global caption

   if {[llength $args] == 4} {
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CONV kernel_type=gaussian sigma=$[lindex $args 3]"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 2] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : convgauss2 in out number sigma"
   }
}

proc mult {args} {
   # constant
   global audace
   global caption

   if {[llength $args] == 1} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "MULT constant=[lindex $args 0]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage : mult constant"
   }
}

proc mult2 {args} {
   # in out const nb
   global audace
   global caption

   set n [llength $args]
   if {($n>=4)&&($n<=5)} {
      set options ""
      if {$n==5} {
         set options "[lindex $args 4]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" MULT constant=[lindex $args 2] $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 3] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : mult2 in out const nb ?tt_options?"
   }
}

proc trans {args} {
   # dx dy
   global audace
   global caption

   if {[llength $args] == 2} {
      set ext [buf$audace(bufNo) extension]
      buf$audace(bufNo) imaseries "TRANS trans_x=[lindex $args 0] trans_y=[lindex $args 1]"
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage : trans dx dy"
   }
}

proc trans2 {args} {
   # in out dx dy nb
   global audace
   global caption

   set n [llength $args]
   if {($n>=5)&&($n<=6)} {
      set options ""
      if {$n==6} {
         set options "[lindex $args 5]"
      }
      set ext [buf$audace(bufNo) extension]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 0]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" TRANS trans_x=[lindex $args 2] trans_y=[lindex $args 3] $options"
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"[lindex $args 1]\" 1 [lindex $args 4] \"$ext\" \"$audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CUTS hicut=MIPS-HI locut=MIPS-LO keytype=INT"
   } else {
      error "Usage : trans2 in out dx dy nb ?tt_options?"
   }
}

