#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_tools_fits.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_tools_fits.tcl
# Description    : Utilitaires pour la manipulation des images fits
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#


namespace eval ::atos_tools_fits {






   proc ::atos_tools_fits::open_flux { visuNo frm } {

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

      set ::atos_tools::cur_idframe 0
      set ::atos_tools::destdir ${destdir}
      set ::atos_tools::prefix ${prefix}
      set ::atos_tools::nb_open_frames $idframe
      set ::atos_tools::nb_frames $idframe
      set ::atos_tools::frame_begin 1
      set ::atos_tools::frame_end $idframe



      ::atos_tools_fits::next_image $visuNo

      catch {
         $frm.status.v.status  configure -text "Loaded"
         $frm.status.v.nbtotal configure -text $::atos_tools::nb_frames
      }

      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
      set ::atos_tools::scrollbar 1   
      $frm.scrollbar configure -from 1
      $frm.scrollbar configure -to $::atos_tools::nb_frames
      $frm.scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]
      $frm.scrollbar configure -command "::atos_tools::slide $visuNo"
      $frm.scrollbar configure -state normal
      $frm.scrollbar configure -variable ::atos_tools::scrollbar
      return
   }







# Verification d un fichier avi
   proc ::atos_tools_fits::verif { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set bufNo [ visu$visuNo buf ]
      ::avi::create ::atos_tools_fits::avi1
      ::atos_tools_fits::avi1 load $::atos_tools::avi_filename
      set ::atos_tools::cur_idframe 0
      ::atos_tools_fits::next_image
      ::atos_tools_fits::exist
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
 
      set text [$panneau(atos,$visuNo,atos_verif).frmverif.results.txt cget -text]


      # Lancement des etapes de verification      
      append text "Nb d'images : $::atos_tools::nb_frames\n"
       
      append text "Test:"
      append text [::atos_tools_fits::avi1 test]
      append text "\n"
      ::atos_tools_fits::next_image
      append text "Test:"
      append text [::atos_tools_fits::avi1 test]
      append text "\n"
             
      # Fin
      $panneau(atos,$visuNo,atos_verif).frmverif.results.txt configure -text $text

   }





















   proc ::atos_tools_fits::next_image { visuNo } {

      incr idframe [expr $::atos_tools::cur_idframe + 1]
      if { $idframe > $::atos_tools::nb_frames } {
        set idframe $::atos_tools::nb_frames
      }
      ::atos_tools_fits::set_frame $visuNo $idframe

   }


   proc ::atos_tools_fits::prev_image { visuNo } {

      set idframe [expr $::atos_tools::cur_idframe - 1]
      if { $idframe < 1 } {
         set idframe 1
      }
      ::atos_tools_fits::set_frame $visuNo $idframe
   }



   proc ::atos_tools_fits::quick_next_image { visuNo } {

      set idframe [expr $::atos_tools::cur_idframe + 100]
      if { $idframe > $::atos_tools::nb_frames } {
         set idframe $::atos_tools::nb_frames
      }
      ::atos_tools_fits::set_frame $visuNo $idframe
   }



   proc ::atos_tools_fits::quick_prev_image { visuNo } {

      set idframe [expr $::atos_tools::cur_idframe - 100]
      if { $idframe < 1 } {
         set idframe 1
      }
      ::atos_tools_fits::set_frame $visuNo $idframe
   }














   proc ::atos_tools_fits::set_frame { visuNo idframe } {

      set ::atos_tools::cur_idframe $idframe
      set filename [file join ${::atos_tools::destdir} "${::atos_tools::prefix}${::atos_tools::cur_idframe}.fits"]
      set bufNo [ visu$visuNo buf ]
      buf$bufNo load $filename

   }
















#   proc ::atos_tools_fits::avi_seek { visuNo arg } {
#      ::console::affiche_resultat "% : [expr $arg / 100.0 ]"
#      ::atos_tools::avi1 seekpercent [expr $arg / 100.0 ]
#      ::atos_tools::avi1 next
#      visu$visuNo disp
#   }













#   proc ::atos_tools_fits::avi_seekbyte { arg } {
#      set visuNo 1
#      ::console::affiche_resultat "arg = $arg"
#      ::atos_tools::avi1 seekbyte $arg
#      ::atos_tools::avi1 next
#      visu$visuNo disp
#   }













   proc ::atos_tools_fits::setmin { This } {

      if { ! [info exists ::atos_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmin delete 0 end
      $This.posmin insert 0 $::atos_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc ::atos_tools_fits::setmax { This } {

      if { ! [info exists ::atos_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmax delete 0 end
      $This.posmax insert 0 $::atos_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc ::atos_tools_fits::imagecount { This } {
      global audace
      $This.imagecount delete 0 end
      set fmin [ $This.posmin get ]
      set fmax [ $This.posmax get ]
      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::atos_tools::nb_frames
      }
      $This.imagecount insert 0 [ expr $fmax - $fmin + 1 ]

   }


























































}
