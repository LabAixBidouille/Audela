#
# Fichier : select.tcl
# Description : Interface permettant la selection d'images
# Date de mise a jour : 07 decembre 2004
#

namespace eval ::selectWindow {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) select.cap ]

   proc run { } {
      variable This
      global audace
      global caption
      global selectWindow

      #--- Initialisation des variables
      set selectWindow(nomEntree)   ""
      set selectWindow(nomSortie)   ""
      set selectWindow(indexEntree) ""
      set selectWindow(indexSortie) ""

      set This "$audace(base).select"

      if [ winfo exists $This ] {
         destroy $This
      }

      toplevel $This
      wm title $This "$caption(select,titre)"
      wm geometry $This +0+70
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW ::selectWindow::end

      frame $This.f -bd 2 -relief groove
         label $This.f.titre -text "$caption(select,entree)"
         label $This.f.lne -text "$caption(select,nom)"
         entry $This.f.ene -width 15 -textvariable selectWindow(nomEntree)
         button $This.f.explore -text "$caption(select,parcourir)" -width 1 -command { ::selectWindow::parcourir 1 }
         label $This.f.lie -text "$caption(select,index)"
         entry $This.f.eie -width 3 -textvariable selectWindow(indexEntree)
         grid $This.f.titre -row 0 -column 0 -columnspan 2 -sticky {}
         grid $This.f.lne -row 1 -column 0 -sticky w
         grid $This.f.ene -row 1 -column 1 -sticky e
         grid $This.f.explore -row 1 -column 2 -sticky e -padx 10 -ipady 5
         grid $This.f.lie -row 2 -column 0 -sticky w
         grid $This.f.eie -row 2 -column 1 -sticky e

      frame $This.g -bd 2 -relief groove
         label $This.g.titre -text "$caption(select,sortie)"
         label $This.g.lne -text "$caption(select,nom)"
         entry $This.g.ene -width 15 -textvariable selectWindow(nomSortie)
         button $This.g.explore -text "$caption(select,parcourir)" -width 1 -command { ::selectWindow::parcourir 2 }
         label $This.g.lie -text "$caption(select,index)"
         entry $This.g.eie -width 3 -textvariable selectWindow(indexSortie)
         grid $This.g.titre -row 0 -column 0 -columnspan 2 -sticky {}
         grid $This.g.lne -row 1 -column 0 -sticky w
         grid $This.g.ene -row 1 -column 1 -sticky e
         grid $This.g.explore -row 1 -column 2 -sticky e -padx 10 -ipady 5
         grid $This.g.lie -row 2 -column 0 -sticky w
         grid $This.g.eie -row 2 -column 1 -sticky e

      frame $This.h -bd 2 -relief groove
         button $This.h.b0 -text "$caption(select,demarrer)" -command { ::selectWindow::start }
         button $This.h.b1 -text "$caption(select,inf)" -command { ::selectWindow::prev } -state disabled
         entry  $This.h.e0 -textvariable selectWindow(indexEntree) -width 3
         button $This.h.b2 -text "$caption(select,sup)" -command { ::selectWindow::next } -state disabled
         button $This.h.b4 -text "$caption(select,auto)" -command { ::selectWindow::auto } -state disabled
         button $This.h.b5 -text "$caption(select,aide)" -command { ::selectWindow::afficheAide } -state normal
         button $This.h.b3 -text "$caption(select,record)" -command { ::selectWindow::record } -state disabled
         pack $This.h.b0 $This.h.b1 $This.h.e0 $This.h.b2 $This.h.b4 -side left -padx 4 -pady 4 -ipady 5
         pack $This.h.b3 $This.h.b5 -side right -padx 4 -pady 4 -ipady 5

      frame $This.i
         text $This.i.t -yscrollcommand "$This.i.vsb set" -xscrollcommand "$This.i.hsb set" -width 0 -height 0
         scrollbar $This.i.vsb -orient vertical -command "$This.i.t yview"
         scrollbar $This.i.hsb -orient horizontal -command "$This.i.t xview"
         grid $This.i.t $This.i.vsb -sticky news
         grid $This.i.hsb -sticky ew
         grid rowconfigure $This.i 0 -weight 1
         grid columnconfigure $This.i 0 -weight 1

      canvas $This.j

      grid $This.f -row 0 -column 1 -padx 2 -pady 4 -ipadx 4 -ipady 4 -sticky ew
      grid $This.g -row 0 -column 2 -padx 2 -pady 4 -ipadx 4 -ipady 4 -sticky ew
      grid $This.h -row 1 -column 1 -columnspan 2 -padx 2 -pady 0 -sticky ew 
      grid $This.i -row 2 -column 1 -rowspan 2 -columnspan 2 -padx 2 -pady 4 -sticky news; #-sticky ew 
      grid $This.j -row 0 -column 0 -rowspan 3 -padx 4 -pady 4 -sticky nsew
      grid columnconfigure $This 0 -weight 1
      grid rowconfigure $This 2 -weight 1

      set selectWindow(buffer) [ ::buf::create ]
      buf$selectWindow(buffer) extension "[ buf$audace(bufNo) extension ]"
      buf$selectWindow(buffer) compress "[ buf$audace(bufNo) compress ]"
      set selectWindow(visu)   [ ::visu::create $selectWindow(buffer) 100 ]
      image delete image100
      image create photo image100
      set selectWindow(canvas) $This.j
      $selectWindow(canvas) create image 0 0 -image image100 -anchor nw

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc parcourir { Entree_Sortie } {
      global audace
      global selectWindow

      #--- Fenetre parent
      set fenetre "$audace(base).select"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom generique
      if { $Entree_Sortie == "1" } {
         set selectWindow(nomEntree) [ lindex [ decomp $filename ] 1 ]
      } else {
         set selectWindow(nomSortie) [ lindex [ decomp $filename ] 1 ]
      }
   }

   proc next { } {
      global selectWindow

      dispima [ incr selectWindow(index) ]
   }

   proc prev { } {
      global selectWindow

      dispima [ incr selectWindow(index) -1 ]
   }

   proc auto { } {
      variable This
      global audace
      global selectWindow

      if { ( $selectWindow(nomSortie) != "" ) && ( $selectWindow(indexSortie) != "" ) } {
         set in $selectWindow(nomEntree)
         set nb [ llength $selectWindow(liste_entree) ]
         catch { unset liste }
         #--- Cette boucle cree une liste dont les elements sont des listes a 2 elems : [ list fwhm nom_image ]
         foreach img $selectWindow(liste_entree) {
            buf$selectWindow(buffer) load "$img"
            buf$selectWindow(buffer) imaseries "STAT fwhm"
            set fwhm [ lindex [ buf$selectWindow(buffer) getkwd FWHM ] 1 ]
            set dfwhm [ lindex [ buf$selectWindow(buffer) getkwd D_FWHM ] 1 ]
            lappend liste [ list $fwhm $img $dfwhm ]
         }
         set liste [ lsort $liste ]
         $This.i.t insert insert "# $liste\n\n"
         set cmp [ buf$selectWindow(buffer) compress ]
         if { $cmp == "none" } {
            set cmp ""
         } else {
            set cmp ".gz"
         }
         foreach elem $liste {
            $This.i.t insert insert "# $elem\n"
            set org "[ lindex $elem 1 ]"
            set dest [ file join $audace(rep_images) $selectWindow(nomSortie)$selectWindow(indexSortie)[ buf$selectWindow(buffer) extension ]$cmp ]
            file copy -force "$org" "$dest"
            $This.i.t insert insert "file copy -force $org $dest\n\n"
            incr selectWindow(indexSortie)
         }
         $This.i.t insert insert "---------------------------------------------------------------------------------------------------------\n\n"
         $This.i.t see insert
      }
   }

   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1090selection_images.htm"
   }

   proc record { } {
      variable This
      global audace
      global caption
      global selectWindow

      if { ( $selectWindow(nomSortie) != "" ) && ( $selectWindow(indexSortie) != "" ) } {
         $This.h.b3 configure -state disabled
         set cmp [ buf$selectWindow(buffer) compress ]
         if { $cmp == "none" } {
            set cmp ""
         } else {
            set cmp ".gz"
         }
         #--- Copie du fichier
         set org "[ lindex $selectWindow(liste_entree) $selectWindow(index) ]"
         set dest [ file join $audace(rep_images) $selectWindow(nomSortie)$selectWindow(indexSortie)[ buf$selectWindow(buffer) extension ]$cmp ]
         file copy -force $org $dest
         $This.i.t insert insert "file copy -force $org $dest\n"
         #--- Incrementation de l'index de sortie
         incr selectWindow(indexSortie)
         #--- L'image recopiee est supprimee de la liste de depart
         set selectWindow(liste_entree) [ lreplace $selectWindow(liste_entree) $selectWindow(index) $selectWindow(index) ]
         if { $selectWindow(index) == [ llength $selectWindow(liste_entree) ] } {
            incr selectWindow(index) -1
         }
         if { $selectWindow(index) < "0" } {
            set selectWindow(indexEntree) "$caption(select,tiret)"            
            $This.h.b1 configure -state disabled
            $This.h.b2 configure -state disabled
         } 
         dispima $selectWindow(index)
      }
   }

   proc dispima { index } {
      variable This
      global audace
      global selectWindow

      if { $index >= "0" } {
         set nom [ lindex $selectWindow(liste_entree) $index ]
         catch {
            buf$selectWindow(buffer) load $nom
         }
         ::audace::autovisu visu$selectWindow(visu)
         set a [ scan $nom [ file join $audace(rep_images) $selectWindow(nomEntree)%d[ buf$selectWindow(buffer) extension ] ] val ]
         set num [ catch { set selectWindow(indexEntree) $val } msg ]
         if { $num == "1" } {
            ::selectWindow::start
         }
         wm title $This [ lindex $selectWindow(liste_entree) $selectWindow(index) ]
         #--- Validation des boutons de navigation et enregistrement
         $This.h.b3 configure -state normal
         if { $selectWindow(index) == [ expr [ llength $selectWindow(liste_entree) ] -1 ] } {
            $This.h.b2 configure -state disabled
         } else {
            $This.h.b2 configure -state normal
         }
         if { $selectWindow(index) == "0" } {
            $This.h.b1 configure -state disabled
         } else {
            $This.h.b1 configure -state normal
         }
      }
   }

   proc start { } {
      variable This
      global audace
      global caption
      global selectWindow

      #--- Nettoyage de l'affichage des images
      image delete image100
      image create photo image100

      set cmp [ buf$selectWindow(buffer) compress ]
      if { $cmp == "none" } {
         set comp ""
      } else {
         set comp ".gz"
      }
      if { [ catch { lsort -dictionary [ glob [ file join $audace(rep_images) $selectWindow(nomEntree)\[0-9\]*[ buf$selectWindow(buffer) extension]$comp ] ] } m ] == "1" } {
         tk_messageBox -message "$caption(select,pas_image)" -title "$caption(select,titre_menu)"
      } else {
         set selectWindow(liste_entree) $m
         set selectWindow(index) 0
         unset selectWindow(indexEntree)
         dispima $selectWindow(index)
         $This.j configure -width [ lindex [ buf$selectWindow(buffer) getkwd NAXIS1 ] 1 ]
         $This.j configure -height [ lindex [ buf$selectWindow(buffer) getkwd NAXIS2 ] 1 ]
         if { [ llength $selectWindow(liste_entree) ] != "1" } {
            $This.h.b2 configure -state normal
         } else {
            $This.h.b2 configure -state disabled
         }
         $This.h.b3 configure -state normal      
         $This.h.b4 configure -state normal      
         foreach elem $selectWindow(liste_entree) {
            $This.i.t insert insert "# $elem\n"
         }
         $This.i.t insert insert "\n"
         $This.i.t see insert 
      }
   }

   proc end { } {
      variable This
      global selectWindow

      buf::delete $selectWindow(buffer)
      destroy $This
   }

}

