#
# Fichier : aud4.tcl
# Description : Interfaces graphiques pour les fonctions carte de champ
# Auteur : Denis MARCHAIS
# $Id: aud4.tcl,v 1.4 2006-06-19 16:44:32 robertdelmas Exp $
#

namespace eval ::mapWindow {
   variable This

   proc initConf { } {
      global caption conf

      if { ! [ info exists conf(mapWindow,position) ] }     { set conf(mapWindow,position)  "+350+75" }
      if { ! [ info exists conf(mapWindow,catalogue) ] }    { set conf(mapWindow,catalogue) "$caption(catalogue,microcat)" }
      if { ! [ info exists conf(mapWindow,magmax) ] }       { set conf(mapWindow,magmax)    "14" }
      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(mapWindow,path_cata) ] } { set conf(mapWindow,path_cata) "/cdrom/" }
      } else {
         if { ! [ info exists conf(mapWindow,path_cata) ] } { set conf(mapWindow,path_cata) "d:/" }
      }

      return
   }

   proc confToWidget { } {
      variable widget
      global conf

      set widget(mapWindow,position)  "$conf(mapWindow,position)"
      set widget(mapWindow,catalogue) "$conf(mapWindow,catalogue)"
      set widget(mapWindow,magmax)    "$conf(mapWindow,magmax)"
      set widget(mapWindow,path_cata) "$conf(mapWindow,path_cata)"
   }

   proc widgetToConf { } {
      variable widget
      global conf

      set conf(mapWindow,position)  "$widget(mapWindow,position)"
      set conf(mapWindow,catalogue) "$widget(mapWindow,catalogue)"
      set conf(mapWindow,magmax)    "$widget(mapWindow,magmax)"
      set conf(mapWindow,path_cata) "$widget(mapWindow,path_cata)"
   }

   proc recup_position { } {
      variable This
      variable widget
      global mapWindow

      set mapWindow(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $mapWindow(geometry) ] ]
      set fin [ string length $mapWindow(geometry) ]
      set widget(mapWindow,position) "+[string range $mapWindow(geometry) $deb $fin]"
      #---
      ::mapWindow::widgetToConf
   }

   proc run { this } {
      variable This
      variable widget
      global mapWindow

      #---
      ::mapWindow::initConf
      ::mapWindow::confToWidget
      #---
      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         if { [ info exists mapWindow(geometry) ] } {
            set deb [ expr 1 + [ string first + $mapWindow(geometry) ] ]
            set fin [ string length $mapWindow(geometry) ]
            set widget(mapWindow,position) "+[string range $mapWindow(geometry) $deb $fin]"
         }
         createDialog
      }
   }

   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf mapWindow

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(superposer,carte,champ)"
      wm geometry $This $widget(mapWindow,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::mapWindow::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief flat

         frame $This.usr.1 -borderwidth 1 -relief raised

            checkbutton $This.usr.1.che1 -text "$caption(param,champ,image)" \
               -variable mapWindow(FieldFromImage) -command { ::mapWindow::toggleSource }
            grid $This.usr.1.che1 -row 0 -column 1 -columnspan 2 -padx 5 -pady 2  -sticky w

            label $This.usr.1.lab1 -text "$caption(audace,dialog,catalogue)"
            grid $This.usr.1.lab1 -row 1 -column 1 -padx 5 -pady 2 -sticky w

            set list_combobox [ list $caption(catalogue,microcat) $caption(catalogue,tycho) $caption(catalogue,loneos) ]
            ComboBox $This.usr.1.cata \
               -width 17         \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::mapWindow::widget(mapWindow,catalogue) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.cata -row 1 -column 2 -padx 5 -pady 2 -sticky e

            button $This.usr.1.explore -text "$caption(script,parcourir)" -width 1 \
               -command { set ::mapWindow::widget(mapWindow,path_cata) [ ::mapWindow::parcourir ] }
            grid $This.usr.1.explore -row 2 -column 0 -padx 5 -pady 2 -sticky w

            label $This.usr.1.lab3 -text "$caption(audace,repertoire,microcat)"
            grid $This.usr.1.lab3 -row 2 -column 1 -padx 5 -pady 2 -sticky w

            entry $This.usr.1.ent1 -textvariable ::mapWindow::widget(mapWindow,path_cata)
            grid $This.usr.1.ent1 -row 2 -column 2 -padx 5 -pady 2 -sticky e

            label $This.usr.1.lab2 -text "$caption(audace,magnitude,limite)"
            grid $This.usr.1.lab2 -row 3 -column 1 -padx 5 -pady 2 -sticky w

            set list_combobox [ list "10" "12" "14" "16" ]
            ComboBox $This.usr.1.magmax \
               -width 6          \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::mapWindow::widget(mapWindow,magmax) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.magmax -row 3 -column 2 -padx 5 -pady 2 -sticky e

         pack $This.usr.1 -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised

            label $This.usr.2.lab1 -text "$caption(audace,largeur,image)"
            grid $This.usr.2.lab1 -row 0 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent1 -textvariable mapWindow(PictureWidth) -width 5
            grid $This.usr.2.ent1 -row 0 -column 1 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab2 -text "$caption(audace,hauteur,image)"
            grid $This.usr.2.lab2 -row 1 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent2 -textvariable mapWindow(PictureHeight) -width 5
            grid $This.usr.2.ent2 -row 1 -column 1 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but1 -text "$caption(prendre,de,image)" -command { ::mapWindow::cmdTakeWHFromPicture }
            grid $This.usr.2.but1 -column 2 -row 0 -rowspan 2 -padx 5 -pady 5 -ipady 5 -sticky news

            label $This.usr.2.lab3 -text "$caption(ascencion,droite,centre)"
            grid $This.usr.2.lab3 -column 0 -row 2 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent3 -textvariable mapWindow(CentreRA) -width 10
            grid $This.usr.2.ent3 -column 1 -row 2 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab4 -text "$caption(declinaison,du,centre)"
            grid $This.usr.2.lab4 -column 0 -row 3 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent4 -textvariable mapWindow(CentreDec) -width 10
            grid $This.usr.2.ent4 -column 1 -row 3 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but2 -text "$caption(prendre,de,image)" -command { ::mapWindow::cmdTakeRaDecFromPicture }
            grid $This.usr.2.but2  -column 2 -row 2 -rowspan 2 -padx 5 -pady 5 -ipady 5 -sticky news

            label $This.usr.2.lab5 -text "$caption(inclinaison,de,camera)"
            grid $This.usr.2.lab5 -column 0 -row 4 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent5 -textvariable mapWindow(Inclin) -width 10
            grid $This.usr.2.ent5 -column 1 -row 4 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab6 -text "$caption(focale,de,instrument)"
            grid $This.usr.2.lab6 -column 0 -row 5 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent6 -textvariable mapWindow(FocLen) -width 10
            grid $This.usr.2.ent6 -column 1 -row 5 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab7 -text "$caption(taille,des,pixels)"
            grid $This.usr.2.lab7 -column 0 -row 6 -padx 5 -pady 2 -sticky w

            frame $This.usr.2.1 -borderwidth 0 -relief flat

               entry $This.usr.2.1.ent1 -textvariable mapWindow(PixSize1) -width 3
               pack $This.usr.2.1.ent1 -side left

               label $This.usr.2.1.lab1 -text "$caption(champ,dimension,x)"
               pack $This.usr.2.1.lab1 -side left

               entry $This.usr.2.1.ent2 -textvariable mapWindow(PixSize2) -width 3
               pack $This.usr.2.1.ent2 -side left

            grid $This.usr.2.1 -column 1 -row 6 -columnspan 3  -padx 5 -pady 2 -sticky w

         pack $This.usr.2 -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised

         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
             -command { \
                if { [ buf$audace(bufNo) imageready ] == "1" } { ::mapWindow::cmdOk } else { ::mapWindow::cmdClose } \
             }
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { if { [ buf$audace(bufNo) imageready ] == "1" } { ::mapWindow::cmdApply } }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.effacer -text "$caption(audace,image,effacer)" -width 10 \
            -command { ::mapWindow::cmdDelete }
         pack $This.cmd.effacer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 8 \
            -command { ::mapWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.aide -text "$caption(conf,aide)" -width 8 \
            -command { ::mapWindow::afficheAide }
         pack $This.cmd.aide -side left -padx 3 -pady 3 -ipady 5 -fill x

      pack $This.cmd -side top -fill x

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

   }

   proc destroyDialog { } {
      variable This

      destroy $This
      unset This
   }

   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   proc cmdApply { } {
      variable This
      variable widget
      global audace caption color etoiles mapWindow

      set unit "e-6"

      #--- Efface la carte de champ precedante
      ::mapWindow::cmdDelete
      #--- Definition des parametres optiques
      if { $mapWindow(FieldFromImage) == "0" } {
         if { $mapWindow(PictureWidth) != "" && $mapWindow(PictureHeight) != "" && $mapWindow(CentreRA) != "" && \
              $mapWindow(CentreDec) != "" && $mapWindow(Inclin) != "" && $mapWindow(FocLen) != "" && \
              $mapWindow(PixSize1) != "" && $mapWindow(PixSize2) != "" } {
            set field [ list OPTIC NAXIS1 $mapWindow(PictureWidth) NAXIS2 $mapWindow(PictureHeight) ]
            lappend field FOCLEN $mapWindow(FocLen) PIXSIZE1 $mapWindow(PixSize1)$unit PIXSIZE2 $mapWindow(PixSize2)$unit
            lappend field CROTA2 $mapWindow(Inclin) RA $mapWindow(CentreRA) DEC $mapWindow(CentreDec)
         } else {
            return
         }
      } else {
         set field [ list BUFFER $audace(bufNo) ]
      }
      #--- Liste des objets
      set choix [ $This.usr.1.cata get ]
      if { ! [ string compare $choix $caption(catalogue,microcat) ] } {
            set objects [ list * ASTROMMICROCAT [ lindex $::mapWindow::widget(mapWindow,path_cata) 0 ] ]
      } elseif { ! [ string compare $choix $caption(catalogue,tycho) ] } {
            set objects [ list * TYCHOMICROCAT [ lindex $::mapWindow::widget(mapWindow,path_cata) 0 ] ]
      } elseif { ! [ string compare $choix $caption(catalogue,loneos) ] } {
            set objects [ list * LONEOSMICROCAT [ lindex $::mapWindow::widget(mapWindow,path_cata) 0 ] ]
      }
      set result [ list LIST ]
      set magmax [ $This.usr.1.magmax get ]

      ::console::affiche_resultat "$field\n"
      ::console::affiche_resultat "$objects\n"
      ::console::affiche_resultat "$result\n\n"

      set a_executer { mc_readcat $field $objects $result -magb< $magmax -magr< $magmax }

      set msg [ eval $a_executer ]

      if { [ llength $msg ] == "1" } {
         set etoiles $msg
         set msg [ lindex $msg 0 ]
         if { [ lindex $msg 0 ] == "Pb" } {
            tk_messageBox -message "[ lindex $msg 1 ]" -icon error -title "$caption(audace,boite,erreur)"
         } else {
            tk_messageBox -message "$caption(pas,etoile,champ)" -icon warning -title "$caption(audace,boite,attention)"
         }
      } else {
         set etoiles $msg
         foreach star $etoiles {
            if { [ llength $star ] == "7" } {
               set coord [ lrange $star 4 5 ]
               set coord [ ::audace::picture2Canvas $coord ]
               set x [ lindex $coord 0 ]
               set y [ lindex $coord 1 ]
               set x1 [ expr $x-2 ]
               set y1 [ expr $y-2 ]
               set x2 [ expr $x+2 ]
               set y2 [ expr $y+2 ]
               $audace(hCanvas) create oval $x1 $y1 $x2 $y2 -fill $color(red) -width 0 -tag chart
            }
         }
      }
      ::mapWindow::recup_position
   }

   proc cmdClose { } {
      ::mapWindow::recup_position
      destroyDialog
   }

   proc afficheAide { } {
      global help

      ::audace::showHelpItem "$help(dir,analyse)" "1100carte_champ.htm"
   }

   proc cmdDelete { } {
      global audace

      $audace(hCanvas) delete chart
   }

   proc cmdTakeWHFromPicture { } {
      global audace mapWindow

      set mapWindow(PictureWidth)  [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      set mapWindow(PictureHeight) [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]
   }

   proc cmdTakeRaDecFromPicture { } {
      global audace mapWindow

      set mapWindow(CentreRA)  [ lindex [ buf$audace(bufNo) getkwd RA ] 1 ]
      set mapWindow(CentreDec) [ lindex [ buf$audace(bufNo) getkwd DEC ] 1 ]
   }

   proc toggleSource { } {
      variable This
      global mapWindow

      if { $mapWindow(FieldFromImage) == "1" } {
         pack forget $This.usr.2 
      } else {
         pack $This.usr.2 -side top -fill both
      }
   }

   proc parcourir { } {
      variable This
      global audace caption mapWindow

      set dirname [ tk_chooseDirectory -title "$caption(catalogue,recherche)" \
         -initialdir $audace(rep_catalogues) -parent $This ]
      set len [ string length $dirname ]
      set folder "$dirname"
      if { $len > "0" } {
         set car [ string index "$dirname" [ expr $len-1 ] ]
         if { $car != "/" } {
            append folder "/"
         }
         set dirname $folder
      }
      return $dirname
   }

}

