#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_extraction.tcl
#--------------------------------------------------
#
# Fichier        : av4l_extraction.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: av4l_extraction.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::av4l_tools {

   variable avi1
   variable nb_frames
   variable cur_idframe
   variable scrollbar

   # av4l_tools::list_diff_shift
   # Retourne la liste test epurée de l intersection des deux listes
   proc list_diff_shift { ref test }  {
      foreach elemref $ref {
         set new_test ""
         foreach elemtest $test {
            if {$elemref!=$elemtest} {lappend new_test $elemtest}
         }
         set test $new_test
      }
      return $test
   }

   # av4l_tools::verif
   # Verification des donnees
   proc verif { } {
   
   
   }

   proc avi_exist {  } {

      catch {
         set exist [info exists ::av4l_tools::avi1]
         ::console::affiche_resultat "exists  : $exist\n"
         ::console::affiche_resultat "exists  : [info exists avi1]\n"
         ::console::affiche_resultat "globals : [info globals]\n"
         ::console::affiche_resultat "locals  : [info locals]\n"
         ::console::affiche_resultat "vars    : [info vars avi1]\n"
      }

   }

   proc avi_close {  } {


      catch {
         ::av4l_tools::avi1 close
         unset ::av4l_tools::avi1
      }
   }

   proc avi_select { visuNo this } {

      global audace panneau

      set bufNo [ visu$visuNo buf ]
      #--- Fenetre parent
      set fenetre [::confVisu::getBase $visuNo]
      
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load_avi $fenetre $audace(rep_images) $bufNo "1" ]
      $this.open.avipath delete 0 end
      $this.open.avipath insert 0 $filename
      focus $this
   }







   proc avi_open { visuNo frm } {

      global audace panneau

      set bufNo [ visu$visuNo buf ]
      set filename [$frm.open.avipath get]
      ::avi::create ::av4l_tools::avi1
      catch { ::av4l_tools::avi1 load $filename }
      if {[::av4l_tools::avi1 status] != 0} {
         ::console::affiche_erreur "Echec du chargement de la video\n"
         catch {
            $frm.status.v.status configure -text Error
            $frm.status.v.nbtotal configure -text ?
         }
         return
      }
      set ::av4l_tools::cur_idframe 0
      set ::av4l_tools::nb_frames [::av4l_tools::avi1 get_nb_frames]
      ::av4l_tools::avi_next
      ::av4l_tools::avi_exist


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
      $frm.scrollbar configure -command "::av4l_tools::avi_slide $visuNo"
      $frm.scrollbar configure -state normal
      $frm.scrollbar configure -variable ::av4l_tools::scrollbar
   }







# Verification d un fichier avi
   proc avi_verif { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set bufNo [ visu$visuNo buf ]
      set filename [$panneau(av4l,$visuNo,av4l_verif).frmverif.open.avipath get]
      ::avi::create ::av4l_tools::avi1
      ::av4l_tools::avi1 load $filename
      set ::av4l_tools::cur_idframe 0
      ::av4l_tools::avi_next
      ::av4l_tools::avi_exist
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
 
      set text [$panneau(av4l,$visuNo,av4l_verif).frmverif.results.txt cget -text]


      # Lancement des etapes de verification      
      set nbimage [::av4l_tools::get_nbimage]
      append text "Nb d'images : $nbimage\n"
       
      append text "Test:"
      append text [::av4l_tools::avi1 test]
      append text "\n"
      ::av4l_tools::avi_next
      append text "Test:"
      append text [::av4l_tools::avi1 test]
      append text "\n"
             
      # Fin
      $panneau(av4l,$visuNo,av4l_verif).frmverif.results.txt configure -text $text

   }











   proc get_nbimage { } {
    return [::av4l_tools::avi1 get_nb_frames]
   }












   proc avi_next { } {
      ::av4l_tools::avi1 next
      incr ::av4l_tools::cur_idframe
      if { $::av4l_tools::cur_idframe > $::av4l_tools::nb_frames } {
         set ::av4l_tools::cur_idframe $::av4l_tools::nb_frames
      }
      if { $::av4l_tools::cur_idframe < 1 } {
         set ::av4l_tools::cur_idframe 1
      }
      
   }



















































   proc avi_quick_prev_image { } {
      set visuNo 1
      set ::av4l_tools::cur_idframe [ expr $::av4l_tools::cur_idframe - 100 ]
      if { $::av4l_tools::cur_idframe > $::av4l_tools::nb_frames } {
         set ::av4l_tools::cur_idframe $::av4l_tools::nb_frames
      }
      if { $::av4l_tools::cur_idframe < 1 } {
         set ::av4l_tools::cur_idframe 1
      }
      ::av4l_tools::avi_get_frame $visuNo $::av4l_tools::cur_idframe
      visu$visuNo disp
   }














   proc avi_get_frame { visuNo idframe } {

      set nbf [expr  $::av4l_tools::nb_frames * 1.0]
      #::console::affiche_resultat "idframe  : $idframe\n"
      #::console::affiche_resultat "nb_frames  : $nbf\n"

      if {$idframe > $::av4l_tools::nb_frames} {
         set idframe $nbf
      }     
      set pc [expr ($idframe-1) / ($nbf+1.0) ]
      #::console::affiche_resultat "pc  : $pc\n"
      ::av4l_tools::avi1 seekpercent $pc
      ::av4l_tools::avi_next
      set ::av4l_tools::cur_idframe $idframe
      visu$visuNo disp
      set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe
   }













   proc avi_get_idframe {  } {

      #::console::affiche_resultat "idframe  : $::av4l_tools::cur_idframe"
      return $::av4l_tools::cur_idframe
   }













   proc avi_slide { visuNo idframe } {
      #::console::affiche_resultat "idframe  : $idframe"
      ::av4l_tools::avi_get_frame $visuNo $idframe
   }













   proc avi_seek { visuNo arg } {
      ::console::affiche_resultat "% : [expr $arg / 100.0 ]"
      ::av4l_tools::avi1 seekpercent [expr $arg / 100.0 ]
      ::av4l_tools::avi1 next
      visu$visuNo disp
   }













   proc avi_seekbyte { arg } {
      set visuNo 1
      ::console::affiche_resultat "arg = $arg"
      ::av4l_tools::avi1 seekbyte $arg
      ::av4l_tools::avi1 next
      visu$visuNo disp
   }













   proc avi_setmin { This } {

      if { ! [info exists ::av4l_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmin delete 0 end
      $This.posmin insert 0 $::av4l_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc avi_setmax { This } {

      if { ! [info exists ::av4l_tools::cur_idframe] } {
          tk_messageBox -message "Veuillez charger une video" -type ok
          return
      }

      $This.posmax delete 0 end
      $This.posmax insert 0 $::av4l_tools::cur_idframe
      catch { $This.imagecount delete 0 end }
   }













   proc avi_imagecount { This } {
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
















   proc avi_extract { frm } {
      global audace
      set visuNo 1
      set bufNo [ visu$visuNo buf ]

      set fmin    [ $frm.posmin get ]
      set fmax    [ $frm.posmax get ]
      set destdir [ $frm.form.v.destdir get ]
      set prefix  [ $frm.form.v.prefix get ]
      set i 0
      set cpt 1
      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::av4l_tools::nb_frames
      }
      ::console::affiche_resultat "fmin=$fmin\n"
      ::console::affiche_resultat "fmax=$fmax\n"


      avi_get_frame $visuNo $fmin
      for {set i $fmin} {$i <= $fmax} {incr i} {
         set ::av4l_tools::scrollbar $i
         #::console::affiche_resultat "$i / [expr $fmax-$fmin+1]\n"
         ::console::affiche_resultat ""
         
         
         set path "$destdir/$prefix$cpt"
         #::console::affiche_resultat "path : $path\n"
         buf$bufNo save $path fits
         ::av4l_tools::avi1 next
         incr cpt
      }
      visu$visuNo disp
      ::console::affiche_resultat "Extraction Terminee\n"
   }
















   proc acq_fetch { this } {
        global audace
        ::avi::convert_shared_image /dev/shm/pict.yuv422
        visu1 disp
        file delete -force /dev/shm/pict.yuv422
   }














   proc acq_start { this } {
        global audace
        ::console::affiche_resultat "path : [$this.form.v.destdir get]"
        exec $audace(rep_plugin)/../../../bin/av4l-grab -d 120m -c 2m -o [$this.form.v.destdir get] &
   }














   proc acq_stop { this } {
        global audace
        exec pkill -x av4l-grab
   }

}
