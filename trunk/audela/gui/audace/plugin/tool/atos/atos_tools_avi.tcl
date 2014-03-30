#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_tools_avi.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_tools_avi.tcl
# Description    : Utilitaires pour la manipulation des AVI
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#

namespace eval ::atos_tools_avi {

   variable avi1
   variable log

   set ::atos_tools_avi::log 0


   # ::atos_tools_avi::list_diff_shift
   # Retourne la liste test epurée de l intersection des deux listes
   proc ::atos_tools_avi::list_diff_shift { ref test }  {

      foreach elemref $ref {
         set new_test ""
         foreach elemtest $test {
            if {$elemref!=$elemtest} {lappend new_test $elemtest}
         }
         set test $new_test
      }
      return $test

   }



   proc ::atos_tools_avi::exist {  } {

      catch {
         set exist [ expr [ llength [info commands ::atos_tools_avi::avi1] ]  == 1 ]
         ::console::affiche_resultat "exists  : $exist\n"
         ::console::affiche_resultat "exists  : [info exists avi1]\n"
         ::console::affiche_resultat "globals : [info globals]\n"
         ::console::affiche_resultat "locals  : [info locals]\n"
         ::console::affiche_resultat "vars    : [info vars avi1]\n"
      }

   }



   proc ::atos_tools_avi::close_flux {  } {

      catch {
         ::atos_tools_avi::avi1 close
         rename ::atos_tools_avi::avi1 {}
      }

   }



   proc ::atos_tools_avi::select { visuNo } {

      global audace panneau

      set frm $::atos_gui::frame(base)

      #--- Fenetre parent
      set fenetre [::confVisu::getBase $visuNo]

      #--- Ouvre la fenetre de choix des images
      set bufNo [ visu$visuNo buf ]
      set ::atos_tools::avi_filename [ ::tkutil::box_load_avi $frm $audace(rep_images) $bufNo "1" ]
      $frm.open.avipath delete 0 end
      $frm.open.avipath insert 0 $::atos_tools::avi_filename

   }



   proc ::atos_tools_avi::open_flux { visuNo } {

      global audace panneau

      set bufNo [ visu$visuNo buf ]
      ::atos_tools_avi::close_flux
      ::avi::create ::atos_tools_avi::avi1
      catch { ::atos_tools_avi::avi1 load $::atos_tools::avi_filename }
      if {[::atos_tools_avi::avi1 status] != 0} {
         ::console::affiche_erreur "Echec du chargement de la video\n"
         catch {
            $::atos_gui::frame(info_load).status   configure -text "Error"
            $::atos_gui::frame(info_load).nbtotal  configure -text "?"
         }
         return
      }

      set ::atos_tools::cur_idframe 0
      set ::atos_tools::nb_open_frames [::atos_tools_avi::avi1 get_nb_frames]
      set ::atos_tools::nb_frames $::atos_tools::nb_open_frames
      set ::atos_tools::frame_begin 1
      set ::atos_tools::frame_end $::atos_tools::nb_frames

      ::atos_tools_avi::next_image
      ::audace::autovisu $audace(visuNo)

   }



   # Verification d un fichier avi
   proc ::atos_tools_avi::verif { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set bufNo [ visu$visuNo buf ]
      ::avi::create ::atos_tools_avi::avi1
      ::atos_tools_avi::avi1 load $::atos_tools::avi_filename
      set ::atos_tools::cur_idframe 0
      ::atos_tools_avi::next_image
      ::atos_tools_avi::exist
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]

      set text [$panneau(atos,$visuNo,atos_verif).frmverif.results.txt cget -text]


      # Lancement des etapes de verification
      set nbimage [::atos_tools_avi::get_nbimage]
      append text "Nb d'images : $nbimage\n"

      append text "Test:"
      append text [::atos_tools_avi::avi1 test]
      append text "\n"
      ::atos_tools_avi::next_image
      append text "Test:"
      append text [::atos_tools_avi::avi1 test]
      append text "\n"

      # Fin
      $panneau(atos,$visuNo,atos_verif).frmverif.results.txt configure -text $text

   }



   proc ::atos_tools_avi::get_nbimage { } {
      
      return [::atos_tools_avi::avi1 get_nb_frames]
   
   }



   proc ::atos_tools_avi::next_image { } {

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         return
      }

      if {$::atos_tools_avi::log} { ::console::affiche_resultat "\nnext_image deb : $::atos_tools::cur_idframe \n" }

      set ::atos_tools::cur_idframe [expr int($::atos_tools::cur_idframe + 1)]
      if { $::atos_tools::cur_idframe > $::atos_tools::frame_end } {
         set ::atos_tools::cur_idframe $::atos_tools::frame_end
      } else {
         ::atos_tools_avi::avi1 next
      }

      if {$::atos_tools_avi::log} {
         ::console::affiche_resultat "next_image fin : $::atos_tools::cur_idframe \n"
         set pc [expr ($::atos_tools::cur_idframe-1) / ($::atos_tools::nb_frames+1.0) ]
         ::console::affiche_resultat "next_image idframe = $::atos_tools::cur_idframe ; pc = $pc\n"
      }

   }



   proc ::atos_tools_avi::prev_image { } {

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         return
      }

      if {$::atos_tools_avi::log} { ::console::affiche_resultat "\nprev_image av : $::atos_tools::cur_idframe \n " }

      set idframe [expr int($::atos_tools::cur_idframe - 1)]
      if { $idframe < $::atos_tools::frame_begin } {
         set idframe $::atos_tools::frame_begin
      }
      ::atos_tools_avi::set_frame $idframe

      if {$::atos_tools_avi::log} { ::console::affiche_resultat "prev_image ap : $::atos_tools::cur_idframe \n" }

   }



   proc ::atos_tools_avi::quick_next_image { } {

      set idframe [expr int($::atos_tools::cur_idframe + 100)]
      if { $idframe > $::atos_tools::frame_end } {
         set idframe $::atos_tools::frame_end
      }
      ::atos_tools_avi::set_frame $idframe

   }



   proc ::atos_tools_avi::quick_prev_image { } {

      set idframe [expr int($::atos_tools::cur_idframe - 100)]
      if { $idframe < $::atos_tools::frame_begin } {
         set idframe $::atos_tools::frame_begin
      }
      ::atos_tools_avi::set_frame $idframe

   }



# next_image idframe = 1 ; pc = 0.0
# next_image idframe = 2 ; pc = 8.685079034219212e-05
# next_image idframe = 3 ; pc = 0.00017370158068438424
# next_image idframe = 4 ; pc = 0.00026055237102657632
# next_image idframe = 5 ; pc = 0.00034740316136876848
# next_image idframe = 6 ; pc = 0.00043425395171096059



   proc ::atos_tools_avi::set_frame { idframe } {

      if {![info exists ::atos_tools::nb_open_frames] || $::atos_tools::nb_open_frames == 0} {
         # Rien a faire car pas de video chargee
         return
      }

      if {$::atos_tools_avi::log} {
         ::console::affiche_resultat "$::atos_tools::cur_idframe $::atos_tools::frame_end $::atos_tools::frame_begin\n"
      }

      set nbf [expr $::atos_tools::nb_open_frames * 1.0]

      if {$idframe > $::atos_tools::frame_end} {
         set idframe $::atos_tools::frame_end
      }

      if {$idframe < $::atos_tools::frame_begin} {
         set idframe $::atos_tools::frame_begin
      }

      set ::atos_tools::cur_idframe [expr int($idframe)]

      if {$::atos_tools_avi::log} {
         set pc [expr ($idframe-1) / ($nbf+1.0) ]
         ::console::affiche_resultat "set_frame idframe = $idframe ; pc = $pc\n"
      }

      ::atos_tools_avi::avi1 seektoframe [expr $idframe -1 ]

      set ::atos_tools::cur_idframe [expr $idframe -1]

      ::atos_tools_avi::next_image
      if {$::atos_tools_avi::log} {
         ::console::affiche_resultat "set_frame next_image cur_idframe = $::atos_tools::cur_idframe\n"
      }

      set ::atos_tools::cur_idframe [expr int($idframe)]
      if {$::atos_tools_avi::log} {
         ::console::affiche_resultat "set_frame cur_idframe fin = $::atos_tools::cur_idframe\n"
      }

   }



#   proc ::atos_tools_avi::avi_seek { visuNo arg } {
#      ::console::affiche_resultat "% : [expr $arg / 100.0 ]"
#      ::atos_tools::avi1 seekpercent [expr $arg / 100.0 ]
#      ::atos_tools::avi1 next
#      visu$visuNo disp
#   }



#   proc ::atos_tools_avi::avi_seekbyte { arg } {
#      set visuNo 1
#      ::console::affiche_resultat "arg = $arg"
#      ::atos_tools::avi1 seekbyte $arg
#      ::atos_tools::avi1 next
#      visu$visuNo disp
#   }



   proc ::atos_tools_avi::setmin { This } {

      if { ! [info exists ::atos_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmin delete 0 end
      $This.posmin insert 0 $::atos_tools::cur_idframe
      catch { $This.imagecount delete 0 end }

   }



   proc ::atos_tools_avi::setmax { This } {

      if { ! [info exists ::atos_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmax delete 0 end
      $This.posmax insert 0 $::atos_tools::cur_idframe
      catch { $This.imagecount delete 0 end }

   }



   proc ::atos_tools_avi::imagecount {  } {

      set posmin $::atos_gui::frame(posmin)
      set posmax $::atos_gui::frame(posmax)
      set imagecount $::atos_gui::frame(imagecount)

      $imagecount delete 0 end
      set fmin [$posmin get]
      set fmax [$posmax get]
      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::atos_tools::nb_open_frames
      }
      $imagecount insert 0 [ expr $fmax - $fmin + 1 ]

   }



   proc ::atos_tools_avi::acq_is_running { } {

      set avipid ""
      set err [ catch {set avipid [exec sh -c "pgrep av4l-grab"]} msg ]
      if {$avipid == ""} {
          return 0
      } else {
         return 1
      }

   }



   proc ::atos_tools_avi::acq_display { visuNo } {

      global audace
        

      set frm_image        $::atos_gui::frame(image,values) 
      set frm_objet        $::atos_gui::frame(object,values) 
      set frm_reference    $::atos_gui::frame(reference,values) 
      set select_image     $::atos_gui::frame(image,buttons).select
      set select_objet     $::atos_gui::frame(object,buttons).select
      set select_reference $::atos_gui::frame(reference,buttons).select

      set bufNo [ visu$visuNo buf ]
      set avipid ""
      set err [ catch {set avipid [exec sh -c "pgrep av4l-grab"]} msg ]
      if {$avipid == ""} {
         ::console::affiche_resultat "Acquisition finie...\n"
         return
      } else {
         #::console::affiche_resultat "Acquisition PID = $avipid\n"
      }

      if {[ file exists /dev/shm/pict.yuv422 ]} {
         ::avi::convert_shared_image $bufNo /dev/shm/pict.yuv422
         visu$visuNo disp
         ::audace::autovisu $visuNo
         file delete -force /dev/shm/pict.yuv422

         cleanmark
         set statebutton [ $select_objet cget -relief]
         if { $statebutton=="sunken" } {
            set delta [ $frm_objet.delta get]
            ::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $delta
         }
         set statebutton [ $select_reference cget -relief]
         if { $statebutton=="sunken" } {
            set delta [ $frm_reference.delta get]
            ::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $delta
         }
         set statebutton [ $select_image cget -relief]
         if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo
         }

      }
      after $::atos::parametres(atos,$visuNo,screen_refresh) " ::atos_tools_avi::acq_display $visuNo"

   }



   proc ::atos_tools_avi::acq_getdevinfo { visuNo autoflag } {

      global audace
      set frm $::atos_gui::frame(base)

      set bufNo [ visu$visuNo buf ]
      ::console::affiche_resultat "Get device info\n"

      set dev $::atos_acq::frmdevpath

      if { [ string equal $dev ""] } {
         set options "-0"
      } else {
         set options "-0 -i $dev"
      }

      if { [ string equal $autoflag auto ] } {
          set options "$options -a"
      }

      set devparams { }

      set commandline "LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1"
      ::console::affiche_resultat "Appel de : $commandline\n"
      set err [ catch { exec sh -c $commandline } msg ]
      if { $err != 0 } {
         ::console::affiche_erreur "Echec lors de l'appel a av4l-grab\n"
         ::console::affiche_erreur "Code d'erreur : $err\n"
         ::console::affiche_erreur "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            ::console::affiche_erreur "$line\n"
         }
         ::console::affiche_erreur "=== Fin des messages\n"
         $frm.oneshot configure -state disabled
         $frm.oneshot2 configure -state disabled
         $frm.demarre configure -state disabled
         set ::atos_acq::frmdevmodel ?
         set ::atos_acq::frmdevinput ?
         set ::atos_acq::frmdevwidth ?
         set ::atos_acq::frmdevheight ?
         set ::atos_acq::frmdevdimen ?
         return $err
      } else {
         ::console::affiche_resultat "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            set l [split $line "="]
            if { [llength $l] == 2 } {
               lappend devparams [list [string trim [lindex $l 0]] [string trim [lindex $l 1]] ]
            }
            ::console::affiche_resultat "$line\n"
         }
         ::console::affiche_resultat "=== Fin des messages\n"

         $frm.oneshot configure -state normal
         $frm.oneshot2 configure -state normal
         $frm.demarre configure -state normal

         set ::atos_acq::frmdevmodel [lindex [lsearch -index 0 -inline $devparams cap_card] 1]
         set ::atos_acq::frmdevinput [lindex [lsearch -index 0 -inline $devparams video_input_index] 1]
         set ::atos_acq::frmdevwidth [lindex [lsearch -index 0 -inline $devparams format_width] 1]
         set ::atos_acq::frmdevheight [lindex [lsearch -index 0 -inline $devparams format_height] 1]
         set ::atos_acq::frmdevdimen "$::atos_acq::frmdevwidth X $::atos_acq::frmdevheight"
         if { [ string equal $dev ""] } {
            set ::atos_acq::frmdevpath [lindex [lsearch -index 0 -inline $devparams video_device] 1]
         }
      }

   }



   proc ::atos_tools_avi::acq_oneshot { visuNo frm } {

      global audace

      set bufNo [ visu$visuNo buf ]

      if { [acq_is_running] } {
         ::console::affiche_resultat "Acquisition en cours.\n"
         return
      }

      ::console::affiche_resultat "One Shot !\n"

      set dev $::atos_acq::frmdevpath
      if { [ string equal $dev ""] } {
         set options ""
         return
      } else {
         set options "-1 -i $dev"
      }

      set err [ catch { exec sh -c "LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1" } msg ]
      if { $err != 0 } {
         ::console::affiche_erreur "Echec lors de l'appel a av4l-grab\n"
         ::console::affiche_erreur "Code d'erreur : $err\n"
         ::console::affiche_erreur "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            ::console::affiche_erreur "$line\n"
         }
         ::console::affiche_erreur "=== Fin des messages\n"
         return $err
      } else {
         ::console::affiche_resultat "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            ::console::affiche_resultat "$line\n"
         }
         ::console::affiche_resultat "=== Fin des messages\n"
     }

      if { $err == 0 } {
         if {[file exists /dev/shm/pict.yuv422 ]} {
            ::avi::convert_shared_image $bufNo /dev/shm/pict.yuv422
            visu$visuNo disp
            ::audace::autovisu $visuNo
            file delete -force /dev/shm/pict.yuv422
         } else {
            ::console::affiche_erreur "Image inexistante \n"
         }
      }

      set statebutton [ $frm.photom.values.object.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.object.v.r.delta get]
         ::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
      }
      set statebutton [ $frm.photom.values.reference.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.reference.v.r.delta get]
         ::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
      }
      set statebutton [ $frm.photom.values.image.t.select cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
      }

   }



   proc ::atos_tools_avi::acq_oneshotcontinuous { visuNo frm } {

      global audace

      set bufNo [ visu$visuNo buf ]

      if { [acq_is_running] } {
         ::console::affiche_resultat "Acquisition en cours.\n"
         return
      }

      ::console::affiche_resultat "One Shot Continous !\n"

      set dev $::atos_acq::frmdevpath
      if { [ string equal $dev ""] } {
         set options ""
         return
      } else {
         set options "-2 -i $dev"
      }

      #set err [ catch { exec sh -c "LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1" } msg ]
      set err [ catch { set chan [open "|sh -c \"LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options > /dev/null 2>&1\"" r+] } msg ]
      if { $err != 0 } {
         ::console::affiche_erreur "Echec lors de l'appel a av4l-grab\n"
         ::console::affiche_erreur "Code d'erreur : $err\n"
         ::console::affiche_erreur "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            ::console::affiche_erreur "$line\n"
         }
         ::console::affiche_erreur "=== Fin des messages\n"
         return $err
      } else {
         ::console::affiche_resultat "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            ::console::affiche_resultat "$line\n"
         }
         ::console::affiche_resultat "=== Fin des messages\n"
      }

      if { $err == 0 } {
         if {[file exists /dev/shm/pict.yuv422 ]} {
            ::avi::convert_shared_image $bufNo /dev/shm/pict.yuv422
            visu$visuNo disp
            ::audace::autovisu $visuNo
            file delete -force /dev/shm/pict.yuv422
         } else {
            ::console::affiche_erreur "Image inexistante \n"
         }
      }

      set statebutton [ $frm.photom.values.object.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.object.v.r.delta get]
         ::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
      }
      set statebutton [ $frm.photom.values.reference.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.reference.v.r.delta get]
         ::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
      }
      set statebutton [ $frm.photom.values.image.t.select cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
      }

      after 100 " ::atos_tools_avi::acq_display $visuNo"

   }



   proc ::atos_tools_avi::format_seconds { n } {

      set h [expr int($n / 3600)]
      set n [expr $n - $h * 3600]
      set m [expr int($n / 60)]
      set s [expr $n - $m * 60]
      return [format "%02d:%02d:%02d" $h $m $s]

   }



   proc ::atos_tools_avi::acq_grab_read_status {chan frm} {

      if {![eof $chan]} {
         gets $chan line
         if {[string equal -length 4 "tcl:" $line]} {
            set line [string range $line 4 end]
            set free_disk [lindex [lsearch -index 0 -inline $line free_disk] 1]
            $frm.infovideo.right.val.dispo configure -text $free_disk
            set file_size [lindex [lsearch -index 0 -inline $line file_size_mb] 1]
            $frm.infovideo.right.val.size configure -text $file_size
            set frame_count [lindex [lsearch -index 0 -inline $line frame_count] 1]
            $frm.infovideo.left.val.nbi configure -text $frame_count
            set duree [lindex [lsearch -index 0 -inline $line duree] 1]
            $frm.infovideo.left.val.duree configure -text [format_seconds $duree]
            set restduree [lindex [lsearch -index 0 -inline $line duree_rest] 1]
            $frm.infovideo.right.val.restduree configure -text [format_seconds $restduree]
         } else {
            if {[string equal -length 2 "W:" $line] || [string equal -length 2 "E:" $line]} {
               ::console::affiche_erreur "$line\n"
            } else {
               ::console::affiche_resultat "$line\n"
            }
         }
      } else {
         close $chan
      }

   }



   proc ::atos_tools_avi::acq_start { visuNo frm } {

      global audace

      set dev $::atos_acq::frmdevpath
      set destdir [$frm.form.v.destdir get]
      set prefix  [$frm.form.v.prefix get]

      if { [acq_is_running] } {
         ::console::affiche_resultat "Acquisition en cours.\n"
         return
      }

      if { $dev == "" } {
         tk_messageBox -message "Veuillez choisir un peripherique de capture" -type ok
         return
      }
      if { $destdir == "" } {
         tk_messageBox -message "Veuillez choisir un repertoire" -type ok
         return
      }

      set prefix [string trim $prefix]
      set prefix [string map {" " _} $prefix]
      if { $prefix == "" } {
         tk_messageBox -message "Veuillez choisir un nom de fichier" -type ok
         return
      }

      set tag [clock format [clock seconds] -timezone :UTC -format %Y%m%dT%H%M%S]
      set prefix "$prefix-$tag"

      set options "-i $dev -y $::atos::parametres(atos,$visuNo,screen_refresh) -s $::atos::parametres(atos,$visuNo,free_space) -d 120m -c 120m -o $destdir -p $prefix"

      ::console::affiche_resultat "Acquisition demarre ...\n"
      ::console::affiche_resultat "           path   : $destdir\n"
      ::console::affiche_resultat "           prefix : $prefix\n"
      ::console::affiche_resultat "           options: $options\n"

#        set err [catch { exec sh -c "LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options" & } processes]

      set err [ catch { set chan [open "|sh -c \"LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1\"" r+] } msg ]

      if { $err != 0 } {
         ::console::affiche_erreur "Echec lors de l'execution de av4l-grab\n"
         return
      }

      fconfigure $chan -blocking 0
      fileevent $chan readable [list ::atos_tools_avi::acq_grab_read_status $chan $frm]

      after 100 " ::atos_tools_avi::acq_display $visuNo"

   }



   proc ::atos_tools_avi::acq_stop { this } {

      global audace
      set avipid ""
      set err [ catch {set avipid [exec sh -c "pgrep av4l-grab"]} msg ]
      if {$avipid == ""} {
         ::console::affiche_resultat "Aucune acquisition en cours\n"
         return
      } else {

      }

      set err [ catch {[exec pkill -x av4l-grab]} msg ]

      after 2000

      if { [acq_is_running] } {
         ::console::affiche_erreur "L'acquisition n'a pas pu etre arretee\n"
      }

   }

}
