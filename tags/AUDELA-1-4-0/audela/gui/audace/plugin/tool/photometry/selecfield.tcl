#
# Fichier : selecfield.tcl
# Description : Petit utilitaire pour preparer une nuit de mesures photometriques
# Auteur : Alain Klotz
# Mise a jour $Id: selecfield.tcl,v 1.2 2006-08-24 21:52:46 robertdelmas Exp $
#
# set home [list GPS [mc_angle2deg 2d54m17s] E [mc_angle2deg 42d42m03s] 45] ; # site (ici en format GPS)
# set mes(1,name) "nova"
# set mes(1,ra) 19h05m12s
# set mes(1,dec) +5d14m12s
# set date1 2005-06-11T18:00:00
# set date2 2005-06-12T05:00:00
# set path "[file dirname [info script]]"
# set fic_loneos_coord "${path}/loneos_coords.txt"
# set fic_selecfield "selecfield.txt"
#
# photom_selectfield $home $name $ra $dec $date1 $date2 $path $fic_loneos_coord $fic_selecfield
#

# --- le calcul par lui meme
proc photom_snvisibility { ra dec jd home } {
   set res [mc_radec2altaz $ra $dec $home $jd]
   set az [lindex $res 0]
   set h [lindex $res 1]
   if {$h>35.} {
      set airmass [format %5.3f [expr 1./cos((90.-$h)*3.1416/180.)]]
      set h [format %5.2f $h]
      set az [format %5.1f $az]
   } else {
      set airmass -----
      set h -----
      set az -----
   }
   set res "$h $airmass"
   return $res
}

proc photom_selectfield { home name ra dec date1 date2 path fic_loneos_coord fic_selecfield} {

# --- entrees utilisateur
set home [list GPS [mc_angle2deg 2d54m17s] E [mc_angle2deg 42d42m03s] 45] ; # site (ici en format GPS)

set nmes 1
set mes(1,name) $name
set mes(1,ra) $ra
set mes(1,dec) $dec

#set date1 2005-06-11T18:00:00
#set date2 2005-06-12T05:00:00

set decmin -90.
set decmax 80.

# --- champs photometriques
#set path "[file dirname [info script]]"
#set fic_loneos_coord "${path}/loneos_coords.txt"
set f [open $fic_loneos_coord r]
set cs [split [read $f] \n]
close $f
set ncalib 0
catch {unset calib}
set latitude [string trim [lindex $home 3]]
foreach c $cs {
   set ra  [lindex $c 0]
   set dec [lindex $c 1]
   set htm [lindex $c 3]
   set name [lindex $c 4]
   if {$dec<$decmin} {
      continue
   }
   if {$dec>$decmax} {
      continue
   }
   if {$latitude>=0.} {
      set declim [expr $latitude-90.+30.]
      if {$dec<$declim} {
         continue
      }
   } else {
      set declim [expr $latitude+90.-30.]
      if {$dec>$declim} {
         continue
      }
   }
   if {$ra==""} {
      break
   }
   incr ncalib
   set calib($ncalib,name) "$name"
   set calib($ncalib,ra) $ra
   set calib($ncalib,dec) $dec
   set calib($ncalib,htm) "$htm"
}
#incr ncalib
#set calib(1,name) "2E 0106.2-0356 G"
#set calib(1,ra) 1h08m38.4s
#set calib(1,dec) -03d46m50s
#set calib($ncalib,name) "M67"
#set calib($ncalib,ra) 08h50.4m
#set calib($ncalib,dec) +11d49m
#set calib($ncalib,htm) "---"

set texte "\n"
append texte "Visibility for location : long.=[string trim [lindex $home 1]]°[string trim [lindex $home 2]] lat.=[string trim [lindex $home 3]]° alt.=[string trim [lindex $home 4]]m\n"
append texte "$nmes fields to measure.\n\n"
#append texte "                          "
#for {set kmes 1} {$kmes<=$nmes} {incr kmes} {
#  set htm "---"
#  append texte "[format %13s $htm] "
#}
#for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
#  set htm [string range $calib($kcalib,htm) 0 end]
#  append texte "[format %13s $htm] "
#}
#append texte "\n"
append texte "                          "
for {set kmes 1} {$kmes<=$nmes} {incr kmes} {
   set name "[string range $mes($kmes,name) 0 9]"
   append texte "[format %13s $name] "
}
#::console::affiche_resultat "$ncalib\n"
for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
   set name "[string trim [string range $calib($kcalib,name) 0 8]]"
   if {[string length $calib($kcalib,name)]>9} {
      append name "..."
   }
   append texte "[format %13s $name] "
}
append texte "\n"
append texte "                          "
for {set kmes 1} {$kmes<=$nmes} {incr kmes} {
   append texte "[format %13s [mc_angle2hms $mes($kmes,ra) 360 zero 1 auto string]] "
}
for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
   append texte "[format %13s [mc_angle2hms $calib($kcalib,ra) 360 zero 1 auto string]] "
}
append texte "\n"
append texte "                          "
for {set kmes 1} {$kmes<=$nmes} {incr kmes} {
   append texte "[format %13s [mc_angle2dms $mes($kmes,dec) 90 zero 1 + string]] "
}
for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
   append texte "[format %13s [mc_angle2dms $calib($kcalib,dec) 90 zero 1 + string]] "
}
append texte "\n"
append texte "                          "
set h h.
set airmass a.m.
set f "  %5s %5s"
for {set kmes 1} {$kmes<=$nmes} {incr kmes} {
   append texte "[format $f $h $airmass] "
}
for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
   append texte "[format $f $h $airmass] "
}
append texte "\n"
set jd1 [mc_date2jd $date1]
set jd2 [mc_date2jd $date2]
set djd [expr 0.5/24.]
for {set jd $jd1} {$jd<=$jd2} {set jd [expr $jd+$djd]} {
   set texte_date "[mc_date2iso8601 $jd] :"
   set texte_calib ""
   set airmass ""
   for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
      set res [photom_snvisibility $calib($kcalib,ra)  $calib($kcalib,dec) $jd $home]
      append texte_calib "  $res "
      set dummy [lindex $res 1]
      if {$dummy=="-----"} {
         set dummy 100.
      }
      lappend airmass $dummy
   }
   set texte_mes ""
   set hmesmin 90.
   set hmesmax 0.
   for {set kmes 1} {$kmes<=$nmes} {incr kmes} {
      set res [photom_snvisibility $mes($kmes,ra)  $mes($kmes,dec) $jd $home]
      set dummy [lindex $res 1]
      if {$dummy=="-----"} {
         set dummy 100.
      }
      set up 0
      set down 0
      set upma 100.
      set downma 0.
      if {$dummy<100. } {
         foreach airmas $airmass {
            if {$airmas>=100.} { continue; }
            if {$dummy<=$airmas} {
               incr up
               if {$airmas<=$upma} {
                  set upma $airmas
               }
            }
            if {$dummy>=$airmas} {
               incr down
               if {$airmas>=$downma} {
                  set downma $airmas
               }
            }
         }
      }
      set dma [expr $upma-$downma]
      if {($up>0)&&($down>0)&&($dma>0.15)} {
         set obs "*"
         set h [string range $res 0 4]
         if {$h>$hmesmax} {
            set hmesmax $h
         }
         if {$h<$hmesmin} {
            set hmesmin $h
         }
      } else {
         set obs " "
      }
      append texte_mes "$obs $res "
   }
   set texte0 ""
   if {$hmesmax>0} {
      set dhmin 90.
      set dhmax 90.
      set khmin -1
      set khmax -1
      for {set kcalib 1} {$kcalib<=$ncalib} {incr kcalib} {
         set k1 [expr ($kcalib-1)*14]
         set k2 [expr $k1+13]
         set texte0 [string range ${texte_calib} $k1 $k2]
         set h [string range $texte0 2 6]
         if {$h!="-----"} {
            if {$h>$hmesmax} {
               set dhmax0 [expr $h-$hmesmax]
               if {$dhmax0<$dhmax} {
                  set khmax $kcalib
                  set dhmax $dhmax0
               }
            }
            if {$h<$hmesmin} {
               set dhmin0 [expr $hmesmin-$h]
               if {$dhmin0<$dhmin} {
                  set khmin $kcalib
                  set dhmin $dhmin0
               }
            }
         }
      }
      if {$khmin>=0} {
         set k1 [expr ($khmin-1)*14]
         set texte_calib [string replace ${texte_calib} $k1 $k1 "*"] ; # -
      }
      if {$khmax>=0} {
         set k1 [expr ($khmax-1)*14]
         set texte_calib [string replace ${texte_calib} $k1 $k1 "*"] ; # +
      }
   }
   append texte "$texte_date ${texte_mes}${texte_calib}\n"
}

set f [open $fic_selecfield w]
puts -nonewline $f $texte
close $f

return $texte
}

