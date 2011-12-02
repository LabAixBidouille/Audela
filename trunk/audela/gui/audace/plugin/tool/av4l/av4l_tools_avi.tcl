#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_tools_avi.tcl
#--------------------------------------------------
#
# Fichier        : av4l_tools_avi.tcl
# Description    : Utilitaires pour la manipulation des AVI
# Auteur         : Frederic Vachier
# Mise à jour $Id: av4l_ocr_gui.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::av4l_tools_avi {


   variable avi1




   # ::av4l_tools_avi::list_diff_shift
   # Retourne la liste test epurée de l intersection des deux listes
   proc ::av4l_tools_avi::list_diff_shift { ref test }  {
      foreach elemref $ref {
         set new_test ""
         foreach elemtest $test {
            if {$elemref!=$elemtest} {lappend new_test $elemtest}
         }
         set test $new_test
      }
      return $test
   }




   # ::av4l_tools_avi::verif
   # Verification des donnees
   proc ::av4l_tools_avi::verif { } {
   
   
   }





   proc ::av4l_tools_avi::exist {  } {

      catch {
         set exist [info exists ::av4l_tools_avi::avi1]
         ::console::affiche_resultat "exists  : $exist\n"
         ::console::affiche_resultat "exists  : [info exists avi1]\n"
         ::console::affiche_resultat "globals : [info globals]\n"
         ::console::affiche_resultat "locals  : [info locals]\n"
         ::console::affiche_resultat "vars    : [info vars avi1]\n"
      }

   }





   proc ::av4l_tools_avi::close_flux {  } {


      catch {
         ::av4l_tools_avi::avi1 close
         unset ::av4l_tools_avi::avi1
      }

   }





   proc ::av4l_tools_avi::select { visuNo frm } {

      global audace panneau

      #--- Fenetre parent
      set fenetre [::confVisu::getBase $visuNo]
      
      #--- Ouvre la fenetre de choix des images
      set bufNo [ visu$visuNo buf ]
      set ::av4l_tools::avi_filename [ ::tkutil::box_load_avi $fenetre $audace(rep_images) $bufNo "1" ]
      $frm.open.avipath delete 0 end
      $frm.open.avipath insert 0 $::av4l_tools::avi_filename
      
   }







   proc ::av4l_tools_avi::open_flux { visuNo frm } {

      global audace panneau

      set bufNo [ visu$visuNo buf ]
      ::avi::create ::av4l_tools_avi::avi1
      catch { ::av4l_tools_avi::avi1 load $::av4l_tools::avi_filename }
      if {[::av4l_tools_avi::avi1 status] != 0} {
         ::console::affiche_erreur "Echec du chargement de la video\n"
         catch {
            $frm.status.v.status configure -text Error
            $frm.status.v.nbtotal configure -text ?
         }
         return
      }

      set ::av4l_tools::cur_idframe 0
      set ::av4l_tools::nb_open_frames [::av4l_tools_avi::avi1 get_nb_frames]
      set ::av4l_tools::nb_frames $::av4l_tools::nb_open_frames
      set ::av4l_tools::frame_begin 1
      set ::av4l_tools::frame_end $::av4l_tools::nb_frames

      ::av4l_tools_avi::next_image

   }







# Verification d un fichier avi
   proc ::av4l_tools_avi::verif { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set bufNo [ visu$visuNo buf ]
      ::avi::create ::av4l_tools_avi::avi1
      ::av4l_tools_avi::avi1 load $::av4l_tools::avi_filename
      set ::av4l_tools::cur_idframe 0
      ::av4l_tools_avi::next_image
      ::av4l_tools_avi::exist
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
 
      set text [$panneau(av4l,$visuNo,av4l_verif).frmverif.results.txt cget -text]


      # Lancement des etapes de verification      
      set nbimage [::av4l_tools_avi::get_nbimage]
      append text "Nb d'images : $nbimage\n"
       
      append text "Test:"
      append text [::av4l_tools_avi::avi1 test]
      append text "\n"
      ::av4l_tools_avi::next_image
      append text "Test:"
      append text [::av4l_tools_avi::avi1 test]
      append text "\n"
             
      # Fin
      $panneau(av4l,$visuNo,av4l_verif).frmverif.results.txt configure -text $text

   }











   proc ::av4l_tools_avi::get_nbimage { } {
    return [::av4l_tools_avi::avi1 get_nb_frames]
   }












   proc ::av4l_tools_avi::next_image { } {

      ::av4l_tools_avi::avi1 next
      set ::av4l_tools::cur_idframe [expr int($::av4l_tools::cur_idframe + 1)]
      if { $::av4l_tools::cur_idframe > $::av4l_tools::frame_end } {
         set ::av4l_tools::cur_idframe $::av4l_tools::frame_end
      }

   }


   proc ::av4l_tools_avi::prev_image { } {

      set idframe [expr int($::av4l_tools::cur_idframe - 1)]
      if { $idframe < $::av4l_tools::frame_begin } {
         set idframe $::av4l_tools::frame_begin
      }
      ::av4l_tools_avi::set_frame $idframe
   }



   proc ::av4l_tools_avi::quick_next_image { } {

      set idframe [expr int($::av4l_tools::cur_idframe + 100)]
      if { $idframe > $::av4l_tools::frame_end } {
         set idframe $::av4l_tools::frame_end
      }
      ::av4l_tools_avi::set_frame $idframe
   }



   proc ::av4l_tools_avi::quick_prev_image { } {

      set idframe [expr int($::av4l_tools::cur_idframe - 100)]
      if { $idframe < $::av4l_tools::frame_begin } {
         set idframe $::av4l_tools::frame_begin
      }
      ::av4l_tools_avi::set_frame $idframe
   }














   proc ::av4l_tools_avi::set_frame { idframe } {

      set nbf [expr  $::av4l_tools::nb_open_frames * 1.0]

      if {$idframe > $::av4l_tools::frame_end} {
         set idframe $::av4l_tools::frame_end
      }
      
      if {$idframe < $::av4l_tools::frame_begin} {
         set idframe $::av4l_tools::frame_begin
      }
      
      
      set pc [expr ($idframe-1) / ($nbf+1.0) ]

      ::av4l_tools_avi::avi1 seekpercent $pc
      ::av4l_tools_avi::next_image

      set ::av4l_tools::cur_idframe [expr int($idframe)]
   }
















#   proc ::av4l_tools_avi::avi_seek { visuNo arg } {
#      ::console::affiche_resultat "% : [expr $arg / 100.0 ]"
#      ::av4l_tools::avi1 seekpercent [expr $arg / 100.0 ]
#      ::av4l_tools::avi1 next
#      visu$visuNo disp
#   }













#   proc ::av4l_tools_avi::avi_seekbyte { arg } {
#      set visuNo 1
#      ::console::affiche_resultat "arg = $arg"
#      ::av4l_tools::avi1 seekbyte $arg
#      ::av4l_tools::avi1 next
#      visu$visuNo disp
#   }













   proc ::av4l_tools_avi::setmin { This } {

      if { ! [info exists ::av4l_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmin delete 0 end
      $This.posmin insert 0 $::av4l_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc ::av4l_tools_avi::setmax { This } {

      if { ! [info exists ::av4l_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmax delete 0 end
      $This.posmax insert 0 $::av4l_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc ::av4l_tools_avi::imagecount { frm } {
      global audace
      
      $frm.imagecount delete 0 end
      set fmin [ $frm.posmin get ]
      set fmax [ $frm.posmax get ]
      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::av4l_tools::nb_open_frames
      }
      $frm.imagecount insert 0 [ expr $fmax - $fmin + 1 ]

   }
































   proc ::av4l_tools_avi::acq_fetch { this } {
        global audace
        ::avi::convert_shared_image /dev/shm/pict.yuv422
        visu1 disp
        file delete -force /dev/shm/pict.yuv422
   }














   proc ::av4l_tools_avi::acq_start { this } {
        global audace
        ::console::affiche_resultat "path : [$this.form.v.destdir get]"
        exec $audace(rep_plugin)/../../../bin/av4l-grab -d 120m -c 2m -o [$this.form.v.destdir get] &
   }














   proc ::av4l_tools_avi::acq_stop { this } {
        global audace
        exec pkill -x av4l-grab
   }









}
