#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_ocr_tools.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_ocr_tools.tcl
# Description    : Utilitaires pour la reconnaissance de caracteres
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#


namespace eval ::atos_ocr_tools {

   variable sortie
   variable active_ocr
   variable nbverif
   variable nbocr
   variable nbinterp
   variable timing



   proc ::atos_ocr_tools::select_time { visuNo frm } {

      global color

      set statebutton [ $frm.datation.values.setup.t.selectbox cget -relief]

      # desactivation
      if {$statebutton=="sunken"} {
         $frm.datation.values.setup.t.selectbox configure -text "Select" -fg $color(black)
         $frm.datation.values.setup.t.selectbox configure -relief raised
         return
      }


      # activation
      if {$statebutton=="raised"} {

         # Recuperation du Rectangle de l image
         set rect [ ::confVisu::getBox $visuNo ]

         # Affichage de la taille de la fenetre
         if {$rect == ""} {
            set ::atos_photom::rect_img ""
         } else {
            set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
            set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
            $frm.datation.values.setup.t.selectbox configure -text "${taillex}x${tailley}" -fg $color(blue)
            set ::atos_photom::rect_img $rect
         }
         $frm.datation.values.setup.t.selectbox configure -relief sunken
         ::atos_ocr_tools::workimage $visuNo $frm
         return
      }

   }







   proc ::atos_ocr_tools::select_ocr { visuNo frm } {

      global color

      # desactivation
      if {$::atos_ocr_tools::active_ocr == "0"} {
         $frm.datation.values.setup.t.typespin  configure -state disabled
         $frm.datation.values.setup.t.selectbox configure -state disabled
         $frm.datation.values.setunset.t.ocr   configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         $frm.datation.values.setunset.t.ocr   configure -state disabled
         return
      } else {
         $frm.datation.values.setup.t.typespin  configure -state normal
         $frm.datation.values.setup.t.selectbox configure -state normal
         $frm.datation.values.setunset.t.ocr    configure -state normal
         ::atos_ocr_tools::workimage $visuNo $frm
         return
      }

   }



   proc ::atos_ocr_tools::ocr_bbox { err msg } {

      # avec deux points comme separateur
      #::console::affiche_resultat "** avec deux points comme separateur \n"
      set poslist [split $msg " "]
      #::console::affiche_resultat "   poslist = $poslist \n"
      set hms [lindex $poslist 0]
      #::console::affiche_resultat "   hms = $hms \n"
      set ms  [lindex $poslist 4]
      set poslist [split $hms "_"]
      #::console::affiche_resultat "   poslist = $poslist \n"
      set h   [lindex $poslist 0]
      set min [lindex $poslist 1]
      set s   [lindex $poslist 2]

      set pass "ok"

      if { $h<0 || $h>24 || $h=="" } {set pass "no"}
      if { $min<0 || $min>59 || $min=="" } {set pass "no"}
      if { $s<0 || $s>59 || $s=="" } {set pass "no"}
      if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

      # avec des espaces comme separateur
      #::console::affiche_resultat "** avec des espaces comme separateur \n"
      if { $pass == "no" } {
         set poslist [split $msg " "]
         #::console::affiche_resultat "   poslist = $poslist \n"
         set h   [lindex $poslist 0]
         set min [lindex $poslist 1]
         set s   [lindex $poslist 2]
         set ms  [lindex $poslist 6]

         set pass "ok"
         if { $h<0 || $h>24 || $h=="" } {set pass "no"}
         if { $min<0 || $min>59 || $min=="" } {set pass "no"}
         if { $s<0 || $s>59 || $s=="" } {set pass "no"}
         if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

      }

      return [list $pass $h $min $s $ms]
   }


   proc ::atos_ocr_tools::ocr_tim10_small_font { err msg } {

      ::console::affiche_erreur "Tim 10 small_font n est pas encore supporté \n"
      ::console::affiche_resultat "err = $err \n"
      ::console::affiche_resultat "msg = $msg \n"
      return [list "no" "XX" "XX" "XX" "XXX"]
   }


   proc ::atos_ocr_tools::ocr_tim10_big_font { } {

      ::console::affiche_erreur "Tim 10 big_font n est pas encore supporté \n"
      ::console::affiche_resultat "err = $err \n"
      ::console::affiche_resultat "msg = $msg \n"
      return [list "no" "XX" "XX" "XX" "XXX"]
   }


   proc ::atos_ocr_tools::ocr_iota_vti { err msg } {

      # avec deux points comme separateur
      set poslist [split $msg " "]
      set t   [split [lindex $poslist 0] ":"]
      set h   [lindex $t 0]
      set min [lindex $t 1]
      set s   [lindex $t 2]
      set ms  [lindex $poslist 1]

      set pass "ok"

      if { $h<0 || $h>24 || $h=="" } {set pass "no"}
      if { $min<0 || $min>59 || $min=="" } {set pass "no"}
      if { $s<0 || $s>59 || $s=="" } {set pass "no"}
      if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

      return [list $pass $h $min $s $ms]
   }




   proc ::atos_ocr_tools::test { visuNo frm } {

   }


   proc ::atos_ocr_tools::workimage { visuNo frm } {

      global color

      set statebutton [ $frm.datation.values.setup.t.selectbox cget -relief]

      # desactivation
      if {$::atos_ocr_tools::active_ocr == "1" && $statebutton == "sunken"} {

          set box [$frm.datation.values.setup.t.typespin get]
          #::console::affiche_resultat "box : $box \n"

          #set rect [$frm.datation.values.setup.t.selectbox get]
          set rect $::atos_photom::rect_img
          #::console::affiche_resultat "rect : $rect \n"

          if { [info exists $rect] } {
             return 0
          }

          set bufNo [ visu$visuNo buf ]
          buf$bufNo window $rect

          set mx [::confVisu::getMirrorX $visuNo]
          if { $mx == 1 } { buf$bufNo mirrorx }

          set my [::confVisu::getMirrorY $visuNo]
          if { $my == 1 } { buf$bufNo mirrory }

          # buf1 save ocr.png
          set stat [buf$bufNo stat]
          gren_info "stat = $stat \n"
          buf$bufNo savejpeg ocr.jpg 100 [lindex $stat 3] [lindex $stat 0]

          switch $box {
             "Black Box" {
               set err [catch {set result [exec jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8]} msg]
             }
             "TIM-10 small font" -
             "TIM-10 big font" {
               set err [catch {set result [exec jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8]} msg]
             }
             "IOTA-VTI" {
               set err [catch {set result [exec gocr -d 6 -C \"0-9:\" -f UTF8 ocr.jpg]} msg]
             }
             default {
               set err [catch {set result [exec jpegtopnm ocr.jpg | gocr -C 0-9: -f UTF8]} msg]
             }
          }

          if {$err == 1} {
            gren_erreur "Failed to extract OCR: $msg \n"
            $frm.datation.values.datetime.h.val   delete 0 end
            $frm.datation.values.datetime.h.val   insert 0 "?"
            $frm.datation.values.datetime.min.val delete 0 end
            $frm.datation.values.datetime.min.val insert 0 "?"
            $frm.datation.values.datetime.s.val   delete 0 end
            $frm.datation.values.datetime.s.val   insert 0 "?"
            $frm.datation.values.datetime.ms.val  delete 0 end
            $frm.datation.values.datetime.ms.val  insert 0 "?"
            $frm.datation.values.setunset.t.ocr   configure -bg $color(red) -fg $color(white)
            return 0
          }

          switch $box {
             "Black Box" {
               set hms [::atos_ocr_tools::ocr_bbox $err $msg]
             }
             "TIM-10 small font" {
               set hms [::atos_ocr_tools::ocr_tim10_small_font $err $msg]
             }
             "TIM-10 big font" {
               set hms [::atos_ocr_tools::ocr_tim10_big_font $err $msg]
             }
             "IOTA-VTI" {
               set hms [::atos_ocr_tools::ocr_iota_vti $err $msg]
             }
             default {
               set hms [list "no" "XX" "XX" "XX" "XXX"]
             }
          }

          gren_info "OCR result: $hms" 

          set pass [lindex $hms 0]
          set h   [return_2digit [lindex $hms 1]]
          set min [return_2digit [lindex $hms 2]]
          set s   [return_2digit [lindex $hms 3]]
          set ms  [return_3digit [lindex $hms 4]]

          if { $pass == "ok" } {

             set err [ catch {

                 regexp {[0-9][0-9]} $h matched
                 if { $h != $matched } {set pass "no"}
                 regexp {[0-9][0-9]} $min matched
                 if { $min != $matched } {set pass "no"}
                 regexp {[0-9][0-9]} $s matched
                 if { $s != $matched } {set pass "no"}
                 regexp {[0-9][0-9][0-9]} $ms matched
                 if { $ms != $matched } {set pass "no"}

             } msg ]

             if { $err != 0 } {set pass "no"}

          }

          # affichage des resultats
          if { $pass == "ok" } {
             #::console::affiche_resultat "OCR = $h:$min:$s.$ms \n"

             $frm.datation.values.datetime.h.val   delete 0 end
             $frm.datation.values.datetime.h.val   insert 0 $h

             $frm.datation.values.datetime.min.val delete 0 end
             $frm.datation.values.datetime.min.val insert 0 $min

             $frm.datation.values.datetime.s.val   delete 0 end
             $frm.datation.values.datetime.s.val   insert 0 $s

             $frm.datation.values.datetime.ms.val  delete 0 end
             $frm.datation.values.datetime.ms.val  insert 0 $ms

             $frm.datation.values.setunset.t.ocr   configure -bg "#00891b" -fg $color(white)
             return 1

          } else {
             #::console::affiche_resultat "OCR Failed \n"
             $frm.datation.values.datetime.h.val   delete 0 end
             $frm.datation.values.datetime.h.val   insert 0 $h

             $frm.datation.values.datetime.min.val delete 0 end
             $frm.datation.values.datetime.min.val insert 0 $min

             $frm.datation.values.datetime.s.val   delete 0 end
             $frm.datation.values.datetime.s.val   insert 0 $s

             $frm.datation.values.datetime.ms.val  delete 0 end
             $frm.datation.values.datetime.ms.val  insert 0 $ms
             $frm.datation.values.setunset.t.ocr   configure -bg $color(red) -fg $color(white)

             return 0
          }


#         23_40_50  9_5  925


      }

   }















   proc ::atos_ocr_tools::getinfofrm { visuNo frm } {

      global color

      set idframe $::atos_tools::cur_idframe

      ::console::affiche_resultat "$idframe - "
      ::console::affiche_resultat "$::atos_ocr_tools::timing($idframe,verif) . "
      ::console::affiche_resultat "$::atos_ocr_tools::timing($idframe,ocr) . "
      ::console::affiche_resultat "$::atos_ocr_tools::timing($idframe,interpol) \n"

      $frm.infofrm.v.nbimage configure -text $::atos_tools::nb_frames

      $frm.infofrm.v.nbverif configure -text $::atos_ocr_tools::nbverif

      set p [format %2.1f [expr $::atos_ocr_tools::nbocr/($::atos_tools::nb_frames*1.0)*100.0]]
      $frm.infofrm.v.nbocr configure -text "$::atos_ocr_tools::nbocr ($p %)"

      set p [format %2.1f [expr $::atos_ocr_tools::nbinterp/($::atos_tools::nb_frames*1.0)*100.0]]
      $frm.infofrm.v.nbinterp configure -text "$::atos_ocr_tools::nbinterp ($p %)"

      if {$::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) == 1} {
         $frm.datation.values.setunset.t.verif configure -bg "#00891b" -fg $color(white)
         $frm.datation.values.setunset.t.verif configure -relief sunken
      } else {
         $frm.datation.values.setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         $frm.datation.values.setunset.t.verif configure -relief raised
      }
      if {$::atos_ocr_tools::timing($::atos_tools::cur_idframe,interpol) == 1} {
         $frm.datation.values.setunset.t.interpol configure -bg "#00891b" -fg $color(white)
         $frm.datation.values.setunset.t.interpol configure -relief sunken
      } else {
         $frm.datation.values.setunset.t.interpol configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         $frm.datation.values.setunset.t.interpol configure -relief raised
      }

      if {$::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) == 1 || $::atos_ocr_tools::timing($::atos_tools::cur_idframe,interpol) == 1} {

         set poslist [split $::atos_ocr_tools::timing($::atos_tools::cur_idframe,dateiso) "T"]
         #::console::affiche_resultat "   poslist = $poslist \n"
         set ymd [lindex $poslist 0]
         set hms [lindex $poslist 1]
         set poslist [split $ymd "-"]
         #::console::affiche_resultat "   poslist ymd = $poslist \n"
         set y [lindex $poslist 0]
         set m [lindex $poslist 1]
         set d [lindex $poslist 2]
         set poslist [split $hms ":"]
         #::console::affiche_resultat "   poslist hms = $poslist \n"
         set h [lindex $poslist 0]
         set min [lindex $poslist 1]
         set sms [lindex $poslist 2]
         set poslist [split $sms "."]
         #::console::affiche_resultat "   poslist hms = $poslist \n"
         set s   [return_2digit [lindex $poslist 0]]
         set ms  [lindex $poslist 1]
         #::console::affiche_resultat "$y-$m-${d}T$h:$min:$s.$ms\n"
         $frm.datation.values.datetime.y.val   delete 0 end
         $frm.datation.values.datetime.y.val   insert 0 $y
   
         $frm.datation.values.datetime.m.val delete 0 end
         $frm.datation.values.datetime.m.val insert 0 $m
   
         $frm.datation.values.datetime.d.val   delete 0 end
         $frm.datation.values.datetime.d.val   insert 0 $d
   
         $frm.datation.values.datetime.h.val   delete 0 end
         $frm.datation.values.datetime.h.val   insert 0 $h
   
         $frm.datation.values.datetime.min.val delete 0 end
         $frm.datation.values.datetime.min.val insert 0 $min
   
         $frm.datation.values.datetime.s.val   delete 0 end
         $frm.datation.values.datetime.s.val   insert 0 $s
   
         $frm.datation.values.datetime.ms.val  delete 0 end
         $frm.datation.values.datetime.ms.val  insert 0 $ms

      }


   }



   proc ::atos_ocr_tools::verif_2numdigit { x } {
          set res [ regexp {[0-9]{1,2}} $x matched ]
          if { ! $res } { return 1 }
          if { $x != $matched } {return 1}
          return 0
   }
   proc ::atos_ocr_tools::verif_yeardigit { x } {
          set res [ regexp {[1-2][0-9]{3}} $x matched ]
          if { ! $res } { return 1 }
          if { $x!=$matched } {return 1}
          return 0
   }
   proc ::atos_ocr_tools::verif_hourdigit { x } {
          set res [ regexp {[0-9]{1,2}} $x matched ]
          if { ! $res } { return 1 }
          if { $x!=$matched } {return 1}
          if { $x<0 || $x>24 || $x=="" } {return 1}
          return 0
   }
   proc ::atos_ocr_tools::verif_msdigit { x } {
          set res [ regexp {[0-9]{1,3}} $x matched ]
          if { ! $res } { return 1 }
          if { $x != $matched } {return 1}
          return 0
   }

   proc ::atos_ocr_tools::return_2digit { x } {
          set res [ regexp {[0-9]{2}} $x matched ]
          if { $res } {
             return $x
          }
          if { ! $res } {
             if { $x==0 } {
                return "00"
             }
             if { $x<10 } {
                return "0$x"
             }
             return "XX"
          }
   }
   proc ::atos_ocr_tools::return_3digit { x } {
          set res [ regexp {[0-9]{3}} $x matched ]
          if { $res } {
             return $x
          }
          if { ! $res } {
             if { $x==0 } {
                return "000"
             }
             if { $x<10 } {
                return "00$x"
             }
             if { $x<100 } {
                return "0$x"
             }
             return "XXX"
          }
   }






   proc ::atos_ocr_tools::verif { visuNo frm } {

      global color


      set statebutton [ $frm.datation.values.setunset.t.verif cget -relief]

      # desactivation
      if {$statebutton == "sunken"} {
         $frm.datation.values.setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         $frm.datation.values.setunset.t.verif configure -relief raised
         incr ::atos_ocr_tools::nbverif -1
         set ::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) 0
         ::atos_ocr_tools::workimage $visuNo $frm
         getinfofrm $visuNo $frm
         return
      }

      set y   [$frm.datation.values.datetime.y.val get]
      set m   [$frm.datation.values.datetime.m.val get]
      set d   [$frm.datation.values.datetime.d.val get]
      set h   [$frm.datation.values.datetime.h.val get]
      set min [$frm.datation.values.datetime.min.val get]
      set s   [$frm.datation.values.datetime.s.val get]
      set ms  [$frm.datation.values.datetime.ms.val get]

      if { [verif_yeardigit $y] } {
          tk_messageBox -message "Veuillez entrer une année valide\n ex : 2012" -type ok
          return
      }
      if { [verif_2numdigit $m] } {
          tk_messageBox -message "Veuillez entrer un mois valide\n ex : 12" -type ok
          return
      }
      if { [verif_2numdigit $d] } {
          tk_messageBox -message "Veuillez entrer un jour valide\n ex : 12" -type ok
          return
      }
      if { [verif_hourdigit $h] } {
          tk_messageBox -message "Veuillez entrer une heure valide\n ex : 12" -type ok
          return
      }
      if { [verif_2numdigit $min] } {
          tk_messageBox -message "Veuillez entrer une minute valide\n ex : 12" -type ok
          return
      }
      if { [verif_2numdigit $s] } {
          tk_messageBox -message "Veuillez entrer une seconde valide\n ex : 12" -type ok
          return
      }
      if { [verif_msdigit $ms] } {
          tk_messageBox -message "Veuillez entrer une milli-seconde valide\n ex : 012" -type ok
          return
      }
      set m   [return_2digit $m]
      set d   [return_2digit $d]
      set h   [return_2digit $h]
      set min [return_2digit $min]
      set s   [return_2digit $s]
      set ms  [return_3digit $ms]

      ::console::affiche_resultat "$y-$m-${d}T$h:$min:$s.$ms\n"
      $frm.datation.values.datetime.y.val   delete 0 end
      $frm.datation.values.datetime.y.val   insert 0 $y

      $frm.datation.values.datetime.m.val delete 0 end
      $frm.datation.values.datetime.m.val insert 0 $m

      $frm.datation.values.datetime.d.val   delete 0 end
      $frm.datation.values.datetime.d.val   insert 0 $d

      $frm.datation.values.datetime.h.val   delete 0 end
      $frm.datation.values.datetime.h.val   insert 0 $h

      $frm.datation.values.datetime.min.val delete 0 end
      $frm.datation.values.datetime.min.val insert 0 $min

      $frm.datation.values.datetime.s.val   delete 0 end
      $frm.datation.values.datetime.s.val   insert 0 $s

      $frm.datation.values.datetime.ms.val  delete 0 end
      $frm.datation.values.datetime.ms.val  insert 0 $ms

      $frm.datation.values.setunset.t.verif configure -bg "#00891b" -fg $color(white)
      $frm.datation.values.setunset.t.verif configure -relief sunken

      incr ::atos_ocr_tools::nbverif
      set ::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) 1
      set ::atos_ocr_tools::timing($::atos_tools::cur_idframe,dateiso) "$y-$m-${d}T$h:$min:$s.$ms"
      #tk_messageBox -message "$caption(bddimages_status,consoleErr3) $msg" -type ok
      getinfofrm $visuNo $frm

   }







   proc ::atos_ocr_tools::stop {  } {
      ::console::affiche_resultat "-- stop \n"
      set ::atos_ocr_tools::sortie 1
   }





   proc ::atos_ocr_tools::select { visuNo frm } {
      ::atos_tools::select $visuNo $frm
      ::atos_ocr_tools::open_flux $visuNo $frm
   }

   proc ::atos_ocr_tools::open_flux { visuNo frm } {
      ::atos_tools::open_flux $visuNo $frm
      for  {set x 1} {$x<=$::atos_tools::nb_open_frames} {incr x} {
         set ::atos_ocr_tools::timing($x,verif) 0
         set ::atos_ocr_tools::timing($x,ocr) 0
         set ::atos_ocr_tools::timing($x,interpol) 0
         set ::atos_ocr_tools::timing($x,jd)  ""
         set ::atos_ocr_tools::timing($x,diff)  ""
         set ::atos_ocr_tools::timing($x,dateiso) ""
      }


   }







   proc ::atos_ocr_tools::start { visuNo frm } {

   # Extraction OCR

      gren_info "Extraction des OCR ...\n"

      set idframedebut $::atos_tools::cur_idframe

      if { $::atos_ocr_tools::timing($idframedebut,verif) != 1 } {
          tk_messageBox -message "Veuillez commencer par une image verifiée" -type ok
          return
      }

      set cpt 0
      $frm.action.start configure -image .stop
      $frm.action.start configure -relief sunken
      $frm.action.start configure -command " ::atos_ocr_tools::stop"

      set ::atos_ocr_tools::sortie 0
      set ::atos_ocr_tools::nbocr 0
      set ::atos_ocr_tools::nbinterp 0

      while {$::atos_ocr_tools::sortie == 0} {

         update
         getinfofrm $visuNo $frm
         set idframe $::atos_tools::cur_idframe
         #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \]\n"

         if {$idframe == $::atos_tools::frame_end} {
            set ::atos_ocr_tools::sortie 1
            gren_info "Ok, last frame ($::atos_tools::frame_end)\n"
         }

         set pass "no"

         set ::atos_tools::scrollbar $idframe

     # Verifié

         if {$::atos_ocr_tools::timing($idframe,verif) == 1} {
            #::console::affiche_resultat "verif: $idframe => $::atos_ocr_tools::timing($idframe,dateiso)\n"
            # calcul jd
            set ::atos_ocr_tools::timing($idframe,jd) [mc_date2jd $::atos_ocr_tools::timing($idframe,dateiso)]
            #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \] V\n"

            ::atos_tools::next_image $visuNo
            set pass "ok"
         }

      # OCR

         if {$pass == "no"} {
            set res [::atos_ocr_tools::workimage $visuNo $frm]
            if {$res == 1} {

               # calcul iso
               set y   [$frm.datation.values.datetime.y.val get]
               set m   [$frm.datation.values.datetime.m.val get]
               set d   [$frm.datation.values.datetime.d.val get]
               set h   [$frm.datation.values.datetime.h.val get]
               set min [$frm.datation.values.datetime.min.val get]
               set s   [$frm.datation.values.datetime.s.val get]
               set ms  [$frm.datation.values.datetime.ms.val get]

               set  pass "ok"
               if { [verif_yeardigit $y] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $m] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $d] } {
                  set  pass "no"
               }
               if { [verif_hourdigit $h] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $min] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $s] } {
                  set  pass "no"
               }
               if { [verif_msdigit $ms] } {
                  set  pass "no"
               }

               if { $pass == "ok" } {
                  set m   [return_2digit $m]
                  set d   [return_2digit $d]
                  set h   [return_2digit $h]
                  set min [return_2digit $min]
                  set s   [return_2digit $s]
                  set ms  [return_3digit $ms]

                  incr ::atos_ocr_tools::nbocr
                  set ::atos_ocr_tools::timing($idframe,dateiso) "$y-$m-${d}T$h:$min:$s.$ms"
                  set ::atos_ocr_tools::timing($idframe,jd) [mc_date2jd $::atos_ocr_tools::timing($idframe,dateiso)]

                  set ::atos_ocr_tools::timing($idframe,ocr) 1
                  set ::atos_ocr_tools::timing($idframe,interpol) 0
                  #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \] O\n"
                  ::atos_tools::next_image $visuNo
                  set pass "ok"
               }
            } 
         }

       # interpolation

         if {$pass == "no"} {
            set ::atos_ocr_tools::timing($idframe,interpol) 1
            set ::atos_ocr_tools::timing($idframe,ocr) 0
            incr ::atos_ocr_tools::nbinterp
            #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \] I\n"
            ::atos_tools::next_image $visuNo
         }

      }

      set idframefin $idframe

# Verification des OCR

      gren_info "Verification des OCR ...\n"

      set ::atos_ocr_tools::sortie 0

      set idframe $idframedebut
      while {$::atos_ocr_tools::sortie == 0} {

         update
         #::console::affiche_resultat "."
         if {$idframe == $idframefin} {
            set ::atos_ocr_tools::sortie 1
         }

         if {$::atos_ocr_tools::timing($idframe,ocr) == 1} {

           # OK on interpole !

            set idfrmav [ get_idfrmav $idframe 2]
            set idfrmap [ get_idfrmap $idframe 1]
            #::console::affiche_resultat "$idfrmav < $idfrmap"
            if { $idfrmav == -1 || $idfrmap == -1 } {
               set idfrmav [ get_idfrmap 0 1]
               set idfrmap [ get_idfrmav [expr $::atos_tools::nb_frames + 1] 1]
            }
            #::console::affiche_resultat "VO : $idframe ($idfrmav<$idfrmap)  "

            set jdav $::atos_ocr_tools::timing($idfrmav,jd)
            set jdap $::atos_ocr_tools::timing($idfrmap,jd)

            set jd [expr $jdav+($jdap-$jdav)/($idfrmap-$idfrmav)*($idframe-$idfrmav)]
            set jd [ format "%6.10f" $jd]

            set diff [ expr   abs(($::atos_ocr_tools::timing($idframe,jd) - $jd ) * 86400.0) ]
            #::console::affiche_resultat "diff = $diff\n"
            if { $diff > 0.5 } {
               ::console::affiche_erreur "Warning! ($idframe) $::atos_ocr_tools::timing($idframe,dateiso)\n"
               set ::atos_ocr_tools::timing($idframe,ocr) 0
               set ::atos_ocr_tools::timing($idframe,interpol) 1
            }

         }
         incr idframe
      }

# interpolation des dates

      gren_info "Interpolation des dates\n"


      set ::atos_ocr_tools::sortie 0

      set idframe $idframedebut
      while {$::atos_ocr_tools::sortie == 0} {

         update
         #::console::affiche_resultat "."
         if {$idframe == $idframefin} {
            set ::atos_ocr_tools::sortie 1
         }

         if {$::atos_ocr_tools::timing($idframe,interpol) == 1} {

            set idfrmav [ get_idfrmav $idframe 2]
            set idfrmap [ get_idfrmap $idframe 2]
            #::console::affiche_resultat "$idfrmav < $idfrmap"
            if { $idfrmav == -1 } {
               # il faut interpoler par 2 a droite
               set idfrmav $idfrmap
               set idfrmap [ get_idfrmap $idfrmap 2]
            }
            if { $idfrmap == -1 } {
               # il faut interpoler par 2 a gauche
               set idfrmap $idfrmav
               set idfrmav [ get_idfrmav $idfrmav 2]
            }
            if { $idfrmav == -1 || $idfrmap == -1 } {
               set idfrmav [ get_idfrmap 0 1]
               set idfrmap [ get_idfrmav [expr $::atos_tools::nb_frames + 1] 1]
            }
            #::console::affiche_resultat "I : $idframe ($idfrmav<$idfrmap)  "
            set jdav $::atos_ocr_tools::timing($idfrmav,jd)
            set jdap $::atos_ocr_tools::timing($idfrmap,jd)

            set jd [expr $jdav+($jdap-$jdav)/($idfrmap-$idfrmav)*($idframe-$idfrmav)]
            set jd [ format "%6.10f" $jd]

            #::console::affiche_resultat "JD=$jd"
            set dateiso [mc_date2iso8601 $jd]
            set ::atos_ocr_tools::timing($idframe,jd) $jd
            set ::atos_ocr_tools::timing($idframe,dateiso) $dateiso

         }
         incr idframe

      }

#   #  Calcul des moyennes
#
#          ::console::affiche_resultat "Calcul des moyennes : "
#
#          set x_avg 0
#          set y_avg 0
#          set cpt 0
#          set ::atos_ocr_tools::sortie 0
#          set idframe $idframedebut
#          while {$::atos_ocr_tools::sortie == 0} {
#             if {$idframe == $idframefin} {
#                set ::atos_ocr_tools::sortie 1
#             }
#             if {$::atos_ocr_tools::timing($idframe,verif) == 1 || $::atos_ocr_tools::timing($idframe,ocr) == 1} {
#                set x_avg [expr $x_avg+$idframe]
#                set y_avg [expr $y_avg+$::atos_ocr_tools::timing($idframe,jd)]
#                incr cpt
#             }
#             incr idframe
#          }
#          set x_avg [expr $x_avg/($cpt*1.0)]
#          set y_avg [expr $y_avg/($cpt*1.0)]
#          ::console::affiche_resultat "x_avg $x_avg y_avg $y_avg\n"
#
#   #  Calcul des coefficients lineaires
#
#          ::console::affiche_resultat "Calcul des coefficients lineaires : "
#
#          set sum1 0
#          set sum2 0
#          set cpt 0
#          set ::atos_ocr_tools::sortie 0
#          set idframe $idframedebut
#          while {$::atos_ocr_tools::sortie == 0} {
#             if {$idframe == $idframefin} {
#                set ::atos_ocr_tools::sortie 1
#             }
#             if {$::atos_ocr_tools::timing($idframe,verif) == 1 || $::atos_ocr_tools::timing($idframe,ocr) == 1} {
#                set sum1 [expr $sum1 + ($idframe-$x_avg)*($::atos_ocr_tools::timing($idframe,jd)-$y_avg)]
#                set sum2 [expr $sum2 + pow(($idframe-$x_avg),2)]
#                incr cpt
#             }
#             incr idframe
#          }
#          set b1 [expr $sum1/$sum2]
#          set b0 [expr $y_avg - $b1 * $x_avg]
#          ::console::affiche_resultat "b1 $b1 b0 $b0\n"
#
#   #  comparaison
#
#
#          ::console::affiche_resultat "Comparaison\n"
#
#          set ::atos_ocr_tools::sortie 0
#          set idframe $idframedebut
#          while {$::atos_ocr_tools::sortie == 0} {
#             if {$idframe == $idframefin} {
#                set ::atos_ocr_tools::sortie 1
#             }
#             set y [ expr $b1 * $idframe + $b0 ]
#             set diff [expr ($::atos_ocr_tools::timing($idframe,jd)-$y)*86400.0]
#             set ::atos_ocr_tools::timing($idframe,diff) $diff
#             if { $diff > 1.0 } {
#                if {$::atos_ocr_tools::timing($idframe,ocr) == 1} {
#                    set ::atos_ocr_tools::timing($idframe,ocr) 0
#                    set ::atos_ocr_tools::timing($idframe,interpol) 1
#                    incr ::atos_ocr_tools::nbinterp
#                    incr ::atos_ocr_tools::nbocr -1
#                   ::console::affiche_resultat "REJECTED ($idframe) $::atos_ocr_tools::timing($idframe,dateiso)\n"
#
#                }
#                if {$::atos_ocr_tools::timing($idframe,ocr) == 1} {
#                   ::console::affiche_erreur "***\n"
#                   ::console::affiche_erreur "Attention une erreur de datation risque de flinguer le pocessus\n"
#                   ::console::affiche_erreur "IDFRAME = $idframe\n"
#                   ::console::affiche_erreur "DATEVERIF = $::atos_ocr_tools::timing($idframe,dateiso)\n"
#                   ::console::affiche_erreur "DIFF = $diff\n"
#                   ::console::affiche_erreur "***\n"
#                }
#             }
#
#             incr idframe
#          }


      $frm.action.start configure -image .start
      $frm.action.start configure -relief raised
      $frm.action.start configure -command "::atos_ocr_tools::start $visuNo $frm"
      ::console::affiche_resultat "Fin\n"

      update
   }












   proc ::atos_ocr_tools::get_idfrmav { idframe gtype } {

       set stop 0
       set id $idframe
       while {$stop == 0} {
          incr id -1
          if {$id == 0} { return -1 }
          if { $gtype == 1 } {
             if {$::atos_ocr_tools::timing($id,verif) == 1} {
                return $id
             }
          }
          if { $gtype == 2 } {
             if {$::atos_ocr_tools::timing($id,verif) == 1 || $::atos_ocr_tools::timing($id,ocr) == 1 } {
                return $id
             }
          }
       }
       return -1
   }









   proc ::atos_ocr_tools::get_idfrmap { idframe gtype } {

       set stop 0
       set id $idframe
       while {$stop == 0} {
          incr id
          if {$id > $::atos_tools::nb_frames} { break }
          if { $gtype == 1 } {
             if {$::atos_ocr_tools::timing($id,verif) == 1} {
                return $id
             }
          }
          if { $gtype == 2 } {
             if {$::atos_ocr_tools::timing($id,verif) == 1 || $::atos_ocr_tools::timing($id,ocr) == 1 } {
                return $id
             }
          }
       }
       return -1
   }



   proc ::atos_ocr_tools::get_filename_time { } {

      if { $::atos_tools::traitement=="fits" } {
         set filename [file join ${::atos_tools::destdir} "${::atos_tools::prefix}"]
      }

      if { $::atos_tools::traitement=="avi" }  {
         set filename $::atos_tools::avi_filename
         if { ! [file exists $filename] } {
         ::console::affiche_erreur "Charger une video ...\n"
         }
      }

      return "${filename}.time"

   }





   proc ::atos_ocr_tools::save { visuNo frm } {


      set filename [::atos_ocr_tools::get_filename_time]

      ::console::affiche_resultat "Sauvegarde dans ${filename} ..."
      set f1 [open $filename "w"]
      puts $f1 "# ** atos - Audela - Linux  * "
      puts $f1 "#FPS = 25"
      set line "idframe, jd, dateiso, verif, ocr, interpol"
      puts $f1 $line

      set sortie 0
      set idframe 0
      set cpt 0
      while {$sortie == 0} {

         incr idframe

         if {$idframe == $::atos_tools::nb_frames} {
            set sortie 1
         }

         set line "$idframe,"

         if { ! [info exists ::atos_ocr_tools::timing($idframe,jd)] ||  $::atos_ocr_tools::timing($idframe,jd) == ""} { continue }

         append line [ format %6.10f $::atos_ocr_tools::timing($idframe,jd)] "  ,"
#         append line "$::atos_ocr_tools::timing($idframe,diff)     ,"


         append line "$::atos_ocr_tools::timing($idframe,dateiso)     ,"
         append line "$::atos_ocr_tools::timing($idframe,verif)     ,"
         append line "$::atos_ocr_tools::timing($idframe,ocr)     ,"
         append line "$::atos_ocr_tools::timing($idframe,interpol)"

         puts $f1 $line
      }

      close $f1
      ::console::affiche_resultat "nb frame save = $idframe   .. Fin  ..\n"


   }





   #
   # Passe a l image suivante
   #
   proc ::atos_ocr_tools::next_image { visuNo frm } {

      cleanmark
      ::atos_tools::next_image $visuNo
      ::atos_ocr_tools::workimage $visuNo $frm
      ::atos_ocr_tools::getinfofrm $visuNo $frm

   }





   #
   # Passe a l image precedente
   #
   proc ::atos_ocr_tools::prev_image { visuNo frm } {

      ::atos_tools::prev_image $visuNo
      ::atos_ocr_tools::workimage $visuNo $frm
      ::atos_ocr_tools::getinfofrm $visuNo $frm

   }




   #
   # Passe a l image suivante
   #
   proc ::atos_ocr_tools::quick_next_image { visuNo frm } {

      ::atos_tools::quick_next_image $visuNo
      ::atos_ocr_tools::workimage $visuNo $frm
      ::atos_ocr_tools::getinfofrm $visuNo $frm

   }




   #
   # retour rapide
   #
   proc ::atos_ocr_tools::quick_prev_image { visuNo frm } {

      ::atos_tools::quick_prev_image $visuNo
      ::atos_ocr_tools::workimage $visuNo $frm
      ::atos_ocr_tools::getinfofrm $visuNo $frm

   }




   #
   #
   #
   proc ::atos_ocr_tools::move_scroll { visuNo frm } {

      ::atos_ocr_tools::workimage $visuNo $frm
      ::atos_ocr_tools::getinfofrm $visuNo $frm
   }



# Fin du namespace
}
