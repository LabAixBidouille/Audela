#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_tools_fits.tcl
#--------------------------------------------------
#
# Fichier        : av4l_tools_fits.tcl
# Description    : Utilitaires pour la manipulation des images fits
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#

namespace eval ::av4l_tools_fits {






   proc ::av4l_tools_fits::open_flux { visuNo frm } {

      global audace panneau

      set bufNo [ visu$visuNo buf ]

      set destdir [ $frm.form.field.v.destdir get ]
      set prefix  [ $frm.form.field.v.prefix get  ]

      set sortie 0
      set idframe 1
      while {$sortie == 0} {
         set filename [file join ${destdir} "${prefix}$idframe.fits"]
         if {![file exist $filename]} {
            break
         }
         incr idframe
         
      }
      incr idframe -1
      
      if {$idframe == 0} {
         catch {
            $frm.status.v.status configure -text "Pas d'image"
            $frm.status.v.nbtotal configure -text 0
         }
         return
      }

      set ::av4l_tools::cur_idframe 0
      set ::av4l_tools::destdir ${destdir}
      set ::av4l_tools::prefix ${prefix}
      set ::av4l_tools::nb_open_frames $idframe
      set ::av4l_tools::nb_frames $idframe
      set ::av4l_tools::frame_begin 1
      set ::av4l_tools::frame_end $idframe



      ::av4l_tools_fits::next_image $visuNo

      catch {
         $frm.status.v.status  configure -text "Loaded"
         $frm.status.v.nbtotal configure -text $::av4l_tools::nb_frames
      }

      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
      set ::av4l_tools::scrollbar 1   
      $frm.scrollbar configure -from 1
      $frm.scrollbar configure -to $::av4l_tools::nb_frames
      $frm.scrollbar configure -tickinterval [expr $::av4l_tools::nb_frames / 5]
      $frm.scrollbar configure -command "::av4l_tools::slide $visuNo"
      $frm.scrollbar configure -state normal
      $frm.scrollbar configure -variable ::av4l_tools::scrollbar
      return
   }







# Verification d un fichier avi
   proc ::av4l_tools_fits::verif { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set bufNo [ visu$visuNo buf ]
      ::avi::create ::av4l_tools_fits::avi1
      ::av4l_tools_fits::avi1 load $::av4l_tools::avi_filename
      set ::av4l_tools::cur_idframe 0
      ::av4l_tools_fits::next_image
      ::av4l_tools_fits::exist
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
 
      set text [$panneau(av4l,$visuNo,av4l_verif).frmverif.results.txt cget -text]


      # Lancement des etapes de verification      
      append text "Nb d'images : $::av4l_tools::nb_frames\n"
       
      append text "Test:"
      append text [::av4l_tools_fits::avi1 test]
      append text "\n"
      ::av4l_tools_fits::next_image
      append text "Test:"
      append text [::av4l_tools_fits::avi1 test]
      append text "\n"
             
      # Fin
      $panneau(av4l,$visuNo,av4l_verif).frmverif.results.txt configure -text $text

   }





















   proc ::av4l_tools_fits::next_image { visuNo } {

      incr idframe [expr $::av4l_tools::cur_idframe + 1]
      if { $idframe > $::av4l_tools::nb_frames } {
        set idframe $::av4l_tools::nb_frames
      }
      ::av4l_tools_fits::set_frame $visuNo $idframe

   }


   proc ::av4l_tools_fits::prev_image { visuNo } {

      set idframe [expr $::av4l_tools::cur_idframe - 1]
      if { $idframe < 1 } {
         set idframe 1
      }
      ::av4l_tools_fits::set_frame $visuNo $idframe
   }



   proc ::av4l_tools_fits::quick_next_image { visuNo } {

      set idframe [expr $::av4l_tools::cur_idframe + 100]
      if { $idframe > $::av4l_tools::nb_frames } {
         set idframe $::av4l_tools::nb_frames
      }
      ::av4l_tools_fits::set_frame $visuNo $idframe
   }



   proc ::av4l_tools_fits::quick_prev_image { visuNo } {

      set idframe [expr $::av4l_tools::cur_idframe - 100]
      if { $idframe < 1 } {
         set idframe 1
      }
      ::av4l_tools_fits::set_frame $visuNo $idframe
   }














   proc ::av4l_tools_fits::set_frame { visuNo idframe } {

      set ::av4l_tools::cur_idframe $idframe
      set filename [file join ${::av4l_tools::destdir} "${::av4l_tools::prefix}${::av4l_tools::cur_idframe}.fits"]
      set bufNo [ visu$visuNo buf ]
      buf$bufNo load $filename

   }
















#   proc ::av4l_tools_fits::avi_seek { visuNo arg } {
#      ::console::affiche_resultat "% : [expr $arg / 100.0 ]"
#      ::av4l_tools::avi1 seekpercent [expr $arg / 100.0 ]
#      ::av4l_tools::avi1 next
#      visu$visuNo disp
#   }













#   proc ::av4l_tools_fits::avi_seekbyte { arg } {
#      set visuNo 1
#      ::console::affiche_resultat "arg = $arg"
#      ::av4l_tools::avi1 seekbyte $arg
#      ::av4l_tools::avi1 next
#      visu$visuNo disp
#   }













   proc ::av4l_tools_fits::setmin { This } {

      if { ! [info exists ::av4l_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmin delete 0 end
      $This.posmin insert 0 $::av4l_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc ::av4l_tools_fits::setmax { This } {

      if { ! [info exists ::av4l_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmax delete 0 end
      $This.posmax insert 0 $::av4l_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc ::av4l_tools_fits::imagecount { This } {
      global audace
      $This.imagecount delete 0 end
      set fmin [ $This.posmin get ]
      set fmax [ $This.posmax get ]
      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::av4l_tools::nb_frames
      }
      $This.imagecount insert 0 [ expr $fmax - $fmin + 1 ]

   }


























































}
