#
# Fichier : select.tcl
# Description : Interface permettant la selection d'images
# Mise a jour $Id: select.tcl,v 1.8 2008-12-07 22:01:55 michelpujol Exp $
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
      set selectWindow(This) $This

      if [ winfo exists $This ] {
         destroy $This
      }

      toplevel $This
      wm title $This "$caption(select,titre)"
      wm geometry $This +0+70
      wm resizable $This 1 1
      wm protocol $This WM_DELETE_WINDOW ::selectWindow::end

      #--- Je cree la visu de la fenetre de selection
      set selectWindow(visuNo) [::confVisu::create $This]

      #--- j'ajoute l'ouil de selection
      frame $This.tool.fra2 -bd 2 -relief groove

      frame $This.tool.fra2.f -bd 2 -relief groove
         label $This.tool.fra2.f.titre -text "$caption(select,entree)"
         label $This.tool.fra2.f.lne -text "$caption(select,nom)"
         entry $This.tool.fra2.f.ene -width 15 -textvariable selectWindow(nomEntree)
         button $This.tool.fra2.f.explore -text "$caption(select,parcourir)" -width 1 -command { ::selectWindow::parcourir 1 }
         label $This.tool.fra2.f.lie -text "$caption(select,index)"
         entry $This.tool.fra2.f.eie -width 3 -textvariable selectWindow(indexEntree)
         grid $This.tool.fra2.f.titre -row 0 -column 0 -columnspan 2 -sticky {}
         grid $This.tool.fra2.f.lne -row 1 -column 0 -sticky w
         grid $This.tool.fra2.f.ene -row 1 -column 1 -sticky e
         grid $This.tool.fra2.f.explore -row 1 -column 2 -sticky e -padx 10 -ipady 5
         grid $This.tool.fra2.f.lie -row 2 -column 0 -sticky w
         grid $This.tool.fra2.f.eie -row 2 -column 1 -sticky e

      frame $This.tool.fra2.g -bd 2 -relief groove
         label $This.tool.fra2.g.titre -text "$caption(select,sortie)"
         label $This.tool.fra2.g.lne -text "$caption(select,nom)"
         entry $This.tool.fra2.g.ene -width 15 -textvariable selectWindow(nomSortie)
         button $This.tool.fra2.g.explore -text "$caption(select,parcourir)" -width 1 -command { ::selectWindow::parcourir 2 }
         label $This.tool.fra2.g.lie -text "$caption(select,index)"
         entry $This.tool.fra2.g.eie -width 3 -textvariable selectWindow(indexSortie)
         grid $This.tool.fra2.g.titre -row 0 -column 0 -columnspan 2 -sticky {}
         grid $This.tool.fra2.g.lne -row 1 -column 0 -sticky w
         grid $This.tool.fra2.g.ene -row 1 -column 1 -sticky e
         grid $This.tool.fra2.g.explore -row 1 -column 2 -sticky e -padx 10 -ipady 5
         grid $This.tool.fra2.g.lie -row 2 -column 0 -sticky w
         grid $This.tool.fra2.g.eie -row 2 -column 1 -sticky e

      frame $This.tool.fra2.h -bd 2 -relief groove
         button $This.tool.fra2.h.b0 -text "$caption(select,demarrer)" -command { ::selectWindow::start }
         button $This.tool.fra2.h.b1 -text "$caption(select,inf)" -command { ::selectWindow::prev } -state disabled
         entry  $This.tool.fra2.h.e0 -textvariable selectWindow(indexEntree) -width 3
         button $This.tool.fra2.h.b2 -text "$caption(select,sup)" -command { ::selectWindow::next } -state disabled
         button $This.tool.fra2.h.b4 -text "$caption(select,auto)" -command { ::selectWindow::auto } -state disabled
         button $This.tool.fra2.h.b5 -text "$caption(select,aide)" -command { ::selectWindow::afficheAide } -state normal
         button $This.tool.fra2.h.b3 -text "$caption(select,record)" -command { ::selectWindow::record } -state disabled
         pack $This.tool.fra2.h.b0 $This.tool.fra2.h.b1 $This.tool.fra2.h.e0 $This.tool.fra2.h.b2 $This.tool.fra2.h.b4 -side left -padx 4 -pady 4 -ipady 5
         pack $This.tool.fra2.h.b3 $This.tool.fra2.h.b5 -side right -padx 4 -pady 4 -ipady 5

      frame $This.tool.fra2.i
         scrollbar $This.tool.fra2.i.vsb -orient vertical -command "$This.tool.fra2.i.t yview"
         scrollbar $This.tool.fra2.i.hsb -orient horizontal -command "$This.tool.fra2.i.t xview"
         text $This.tool.fra2.i.t -yscrollcommand "$This.tool.fra2.i.vsb set" -xscrollcommand "$This.tool.fra2.i.hsb set" -width 0 -height 0
         grid $This.tool.fra2.i.t $This.tool.fra2.i.vsb -sticky news
         grid $This.tool.fra2.i.hsb -sticky ew
         grid rowconfigure $This.tool.fra2.i 0 -weight 1
         grid columnconfigure $This.tool.fra2.i 0 -weight 1

      grid $This.tool.fra2.f -row 0 -column 0 -padx 2 -pady 4 -ipadx 4 -ipady 4 -sticky ew
      grid $This.tool.fra2.g -row 0 -column 1 -padx 2 -pady 4 -ipadx 4 -ipady 4 -sticky ew
      grid $This.tool.fra2.h -row 1 -column 0 -columnspan 2 -padx 2 -pady 0 -sticky ew
      grid $This.tool.fra2.i -row 2 -column 0 -columnspan 2 -padx 2 -pady 4 -sticky news; #-sticky ew
      grid columnconfigure $This.tool.fra2 0 -weight 1
      grid rowconfigure $This.tool.fra2 2 -weight 1

      pack $This.tool.fra2 -anchor center -expand 0 -fill y -side left

      #--- Creation des variables audace dependant de la visu
      set selectWindow(buffer) [visu$selectWindow(visuNo) buf]
      set selectWindow(canvas) $::confVisu::private($selectWindow(visuNo),hCanvas)

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc parcourir { Entree_Sortie } {
      global audace
      global selectWindow

      #--- Fenetre parent
      set fenetre "$selectWindow(This)"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $selectWindow(buffer) "1" ]
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
         $This.tool.fra2.i.t insert insert "# $liste\n\n"
         set cmp [ buf$selectWindow(buffer) compress ]
         if { $cmp == "none" } {
            set cmp ""
         } else {
            set cmp ".gz"
         }
         foreach elem $liste {
            $This.tool.fra2.i.t insert insert "# $elem\n"
            set org "[ lindex $elem 1 ]"
            set dest [ file join $audace(rep_images) $selectWindow(nomSortie)$selectWindow(indexSortie)[ buf$selectWindow(buffer) extension ]$cmp ]
            file copy -force "$org" "$dest"
            $This.tool.fra2.i.t insert insert "file copy -force $org $dest\n\n"
            incr selectWindow(indexSortie)
         }
         $This.tool.fra2.i.t insert insert "---------------------------------------------------------------------------------------------------------\n\n"
         $This.tool.fra2.i.t see insert
      }
   }

   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,fichier)" "1046selection_images.htm"
   }

   proc record { } {
      variable This
      global audace
      global caption
      global selectWindow

      if { ( $selectWindow(nomSortie) != "" ) && ( $selectWindow(indexSortie) != "" ) } {
         $This.tool.fra2.h.b3 configure -state disabled
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
         $This.tool.fra2.i.t insert insert "file copy -force $org $dest\n"
         #--- Incrementation de l'index de sortie
         incr selectWindow(indexSortie)
         #--- L'image recopiee est supprimee de la liste de depart
         set selectWindow(liste_entree) [ lreplace $selectWindow(liste_entree) $selectWindow(index) $selectWindow(index) ]
         if { $selectWindow(index) == [ llength $selectWindow(liste_entree) ] } {
            incr selectWindow(index) -1
         }
         if { $selectWindow(index) < "0" } {
            set selectWindow(indexEntree) "$caption(select,tiret)"
            $This.tool.fra2.h.b1 configure -state disabled
            $This.tool.fra2.h.b2 configure -state disabled
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
         ::audace::autovisu $selectWindow(visuNo)
         set a [ scan $nom [ file join $audace(rep_images) $selectWindow(nomEntree)%d[ buf$selectWindow(buffer) extension ] ] val ]
         set num [ catch { set selectWindow(indexEntree) $val } msg ]
         if { $num == "1" } {
            ::selectWindow::start
         }
         wm title $This [ lindex $selectWindow(liste_entree) $selectWindow(index) ]
         #--- Validation des boutons de navigation et enregistrement
         $This.tool.fra2.h.b3 configure -state normal
         if { $selectWindow(index) == [ expr [ llength $selectWindow(liste_entree) ] -1 ] } {
            $This.tool.fra2.h.b2 configure -state disabled
         } else {
            $This.tool.fra2.h.b2 configure -state normal
         }
         if { $selectWindow(index) == "0" } {
            $This.tool.fra2.h.b1 configure -state disabled
         } else {
            $This.tool.fra2.h.b1 configure -state normal
         }
      }
   }

   proc start { } {
      variable This
      global audace
      global caption
      global selectWindow

      #--- Nettoyage de l'affichage des images
      visu$selectWindow(visuNo) clear

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
         set w [ buf$selectWindow(buffer) getpixelswidth ]
         $selectWindow(canvas) configure -width $w
         if { [buf$selectWindow(buffer) getnaxis] == 1 } {
            set h [ visu$selectWindow(visuNo) thickness ]
         } else {
            set h [ buf$selectWindow(buffer) getpixelsheight ]
         }
         $selectWindow(canvas) configure -height $h
         if { [ llength $selectWindow(liste_entree) ] != "1" } {
            $This.tool.fra2.h.b2 configure -state normal
         } else {
            $This.tool.fra2.h.b2 configure -state disabled
         }
         $This.tool.fra2.h.b3 configure -state normal
         $This.tool.fra2.h.b4 configure -state normal
         foreach elem $selectWindow(liste_entree) {
            $This.tool.fra2.i.t insert insert "# $elem\n"
         }
         $This.tool.fra2.i.t insert insert "\n"
         $This.tool.fra2.i.t see insert
      }
   }

   proc end { } {
      global selectWindow

      ::confVisu::close $selectWindow(visuNo)
   }

}

