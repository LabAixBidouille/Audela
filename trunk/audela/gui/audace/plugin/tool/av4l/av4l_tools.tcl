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

   proc avi_open { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set bufNo [ visu$visuNo buf ]
      set filename [$panneau(av4l,$visuNo,av4l_extraction).frmextraction.open.avipath get]
      ::avi::create ::av4l_tools::avi1
      ::av4l_tools::avi1 load $filename
      ::av4l_tools::avi1 next
      ::av4l_tools::avi_exist
      
      #::confVisu::autovisu $visuNo

      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
      
      
      
      $panneau(av4l,$visuNo,av4l_extraction).frmextraction.percent configure -command "::av4l_tools::avi_seek $visuNo"
      $panneau(av4l,$visuNo,av4l_extraction).frmextraction.percent configure -state normal
   }


   proc avi_next_image { } {
      set visuNo 1
      ::av4l_tools::avi1 next
      visu$visuNo disp
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
      global audace
      $This.posmin delete 0 end
      $This.posmin insert 0 [ ::av4l_tools::avi1 getpreviousoffset ]
   }

   proc avi_setmax { This } {
      global audace
      $This.posmax delete 0 end
      $This.posmax insert 0 [ ::av4l_tools::avi1 getpreviousoffset ]
   }

   proc avi_imagecount { This } {
      global audace
      $This.imagecount delete 0 end
      $This.imagecount insert 0 [ ::av4l_tools::avi1 count [ $This.posmin get ] [ $This.posmax get]]

   }

   proc avi_extract { } {
      global audace
      variable This
      set visuNo 1
      set bufNo [ visu$visuNo buf ]

      set bytemin [ $This.frame1.posmin get ]
      set bytemax [ $This.frame1.posmax get ]
      set rep [  $This.frame1.status.v.requetes get ]
      set prefix [ $This.frame1.status.v.scenes get ]
      set i 0

      avi_seekbyte $bytemin
      avi_next_image
      while { 1 } {
         incr i
         ::console::affiche_resultat "i = $i"
         set fn "$rep/$prefix$i"
         ::console::affiche_resultat "fn : $fn"
         buf$bufNo save $fn fits
              if { [::av4l_tools::avi1 getoffset] >= $bytemax } { break }
         ::av4l_tools::avi1 next
      }
      visu$visuNo disp
   }


}
