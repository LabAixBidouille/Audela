#
# Fichier : fieldchart.tcl
# Description : Interfaces graphiques pour les fonctions carte de champ
# Auteur : Denis MARCHAIS
# Mise a jour $Id: fieldchart.tcl,v 1.8 2008-12-10 18:47:01 robertdelmas Exp $
#

namespace eval ::mapWindow {

   #
   # ::mapWindow::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global caption conf

      if { ! [ info exists conf(mapWindow,position) ] }     { set conf(mapWindow,position)  "+350+75" }
      if { ! [ info exists conf(mapWindow,catalogue) ] }    { set conf(mapWindow,catalogue) "$caption(fieldchart,microcat)" }
      if { ! [ info exists conf(mapWindow,magmax) ] }       { set conf(mapWindow,magmax)    "14" }
      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(mapWindow,path_cata) ] } { set conf(mapWindow,path_cata) "/cdrom/" }
      } else {
         if { ! [ info exists conf(mapWindow,path_cata) ] } { set conf(mapWindow,path_cata) "d:/" }
      }
   }

   #
   # ::mapWindow::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(mapWindow,position)  "$conf(mapWindow,position)"
      set widget(mapWindow,catalogue) "$conf(mapWindow,catalogue)"
      set widget(mapWindow,magmax)    "$conf(mapWindow,magmax)"
      set widget(mapWindow,path_cata) "$conf(mapWindow,path_cata)"
   }

   #
   # ::mapWindow::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(mapWindow,position)  "$widget(mapWindow,position)"
      set conf(mapWindow,catalogue) "$widget(mapWindow,catalogue)"
      set conf(mapWindow,magmax)    "$widget(mapWindow,magmax)"
      set conf(mapWindow,path_cata) "$widget(mapWindow,path_cata)"
   }

   #
   # ::mapWindow::recup_position
   # Recupere la position de la fenetre
   #
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

   #
   # ::mapWindow::run
   # Lance la boite de dialogue pour les cartes de champ
   #
   proc run { this } {
      variable This
      variable widget
      global mapWindow

      #---
      ::mapWindow::initConf
      ::mapWindow::confToWidget
      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         if { [ info exists mapWindow(geometry) ] } {
            set deb [ expr 1 + [ string first + $mapWindow(geometry) ] ]
            set fin [ string length $mapWindow(geometry) ]
            set widget(mapWindow,position) "+[string range $mapWindow(geometry) $deb $fin]"
         }
         createDialog
      }
   }

   #
   # ::mapWindow::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf mapWindow

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(fieldchart,carte_champ)"
      wm geometry $This $widget(mapWindow,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::mapWindow::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief flat

         frame $This.usr.1 -borderwidth 1 -relief raised

            checkbutton $This.usr.1.che1 -text "$caption(fieldchart,champ_image)" \
               -variable mapWindow(FieldFromImage) -command { ::mapWindow::toggleSource }
            grid $This.usr.1.che1 -row 0 -column 0 -columnspan 2 -padx 5 -pady 2  -sticky w

            label $This.usr.1.lab1 -text "$caption(fieldchart,catalogue)"
            grid $This.usr.1.lab1 -row 1 -column 0 -padx 5 -pady 2 -sticky w

            set list_combobox [ list $caption(fieldchart,microcat) $caption(fieldchart,tycho) $caption(fieldchart,loneos) ]
            ComboBox $This.usr.1.cata \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::mapWindow::widget(mapWindow,catalogue) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.cata -row 1 -column 1 -padx 5 -pady 2 -sticky e

            label $This.usr.1.lab3 -text "$caption(fieldchart,cat_microcat)"
            grid $This.usr.1.lab3 -row 2 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.1.ent1 -textvariable ::mapWindow::widget(mapWindow,path_cata)
            grid $This.usr.1.ent1 -row 2 -column 1 -padx 5 -pady 2 -sticky e

            button $This.usr.1.explore -text "$caption(fieldchart,parcourir)" -width 1 \
               -command { set ::mapWindow::widget(mapWindow,path_cata) [ ::mapWindow::parcourir ] }
            grid $This.usr.1.explore -row 2 -column 2 -padx 5 -pady 2 -sticky w

            label $This.usr.1.lab2 -text "$caption(fieldchart,magnitude_limite)"
            grid $This.usr.1.lab2 -row 3 -column 0 -padx 5 -pady 2 -sticky w

            set list_combobox [ list "10" "12" "14" "16" ]
            ComboBox $This.usr.1.magmax \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::mapWindow::widget(mapWindow,magmax) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.magmax -row 3 -column 1 -padx 5 -pady 2 -sticky e

         pack $This.usr.1 -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised

            label $This.usr.2.lab1 -text "$caption(fieldchart,largeur_image)"
            grid $This.usr.2.lab1 -row 0 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent1 -textvariable mapWindow(PictureWidth) -width 5
            grid $This.usr.2.ent1 -row 0 -column 1 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab2 -text "$caption(fieldchart,hauteur_image)"
            grid $This.usr.2.lab2 -row 1 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent2 -textvariable mapWindow(PictureHeight) -width 5
            grid $This.usr.2.ent2 -row 1 -column 1 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but1 -text "$caption(fieldchart,prendre_image)" -command { ::mapWindow::cmdTakeWHFromPicture }
            grid $This.usr.2.but1 -column 2 -row 0 -rowspan 2 -padx 5 -pady 5 -ipady 5 -sticky news

            label $This.usr.2.lab3 -text "$caption(fieldchart,ad_centre)"
            grid $This.usr.2.lab3 -column 0 -row 2 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent3 -textvariable mapWindow(CentreRA) -width 10
            grid $This.usr.2.ent3 -column 1 -row 2 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab4 -text "$caption(fieldchart,dec_centre)"
            grid $This.usr.2.lab4 -column 0 -row 3 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent4 -textvariable mapWindow(CentreDec) -width 10
            grid $This.usr.2.ent4 -column 1 -row 3 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but2 -text "$caption(fieldchart,prendre_image)" -command { ::mapWindow::cmdTakeRaDecFromPicture }
            grid $This.usr.2.but2  -column 2 -row 2 -rowspan 2 -padx 5 -pady 5 -ipady 5 -sticky news

            label $This.usr.2.lab5 -text "$caption(fieldchart,inclinaison_camera)"
            grid $This.usr.2.lab5 -column 0 -row 4 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent5 -textvariable mapWindow(Inclin) -width 10
            grid $This.usr.2.ent5 -column 1 -row 4 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab6 -text "$caption(fieldchart,focale_instrument)"
            grid $This.usr.2.lab6 -column 0 -row 5 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent6 -textvariable mapWindow(FocLen) -width 10
            grid $This.usr.2.ent6 -column 1 -row 5 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab7 -text "$caption(fieldchart,taille_pixels)"
            grid $This.usr.2.lab7 -column 0 -row 6 -padx 5 -pady 2 -sticky w

            frame $This.usr.2.1 -borderwidth 0 -relief flat

               entry $This.usr.2.1.ent1 -textvariable mapWindow(PixSize1) -width 3
               pack $This.usr.2.1.ent1 -side left

               label $This.usr.2.1.lab1 -text "$caption(fieldchart,x)"
               pack $This.usr.2.1.lab1 -side left

               entry $This.usr.2.1.ent2 -textvariable mapWindow(PixSize2) -width 3
               pack $This.usr.2.1.ent2 -side left

            grid $This.usr.2.1 -column 1 -row 6 -columnspan 3  -padx 5 -pady 2 -sticky w

         pack $This.usr.2 -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised

         button $This.cmd.ok -text "$caption(fieldchart,ok)" -width 7 \
            -command { ::mapWindow::cmdOk }
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $This.cmd.appliquer -text "$caption(fieldchart,appliquer)" -width 8 \
            -command { ::mapWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.effacer -text "$caption(fieldchart,effacer)" -width 10 \
            -command { ::mapWindow::cmdDelete }
         pack $This.cmd.effacer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.fermer -text "$caption(fieldchart,fermer)" -width 8 \
            -command { ::mapWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.aide -text "$caption(fieldchart,aide)" -width 8 \
            -command { ::mapWindow::afficheAide }
         pack $This.cmd.aide -side left -padx 3 -pady 3 -ipady 5 -fill x

      pack $This.cmd -side top -fill x

      #--- La fenetre est active
      focus $This

      #--- Mise a jour de la fenetre
      ::mapWindow::toggleSource

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

   }

   #
   # ::mapWindow::destroyDialog
   # Procedure correspondant a la fermeture de la fenetre
   #
   proc destroyDialog { } {
      variable This

      destroy $This
      unset This
   }

   #
   # ::mapWindow::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   #
   # ::mapWindow::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      variable This
      variable widget
      global audace caption color etoiles mapWindow

      set unit "e-6"

      if { [ buf$audace(bufNo) imageready ] == "1" } {
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
         if { ! [ string compare $choix $caption(fieldchart,microcat) ] } {
            set objects [ list * ASTROMMICROCAT $::mapWindow::widget(mapWindow,path_cata) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,tycho) ] } {
            set objects [ list * TYCHOMICROCAT $::mapWindow::widget(mapWindow,path_cata) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,loneos) ] } {
            set objects [ list * LONEOSMICROCAT $::mapWindow::widget(mapWindow,path_cata) ]
         }
         set result [ list LIST ]
         set magmax [ $This.usr.1.magmax get ]

         set a_executer { mc_readcat $field $objects $result -magb< $magmax -magr< $magmax }

         set msg [ eval $a_executer ]

         if { [ llength $msg ] == "1" } {
            set etoiles $msg
            set msg [ lindex $msg 0 ]
            if { [ lindex $msg 0 ] == "Pb" } {
               tk_messageBox -message "[ lindex $msg 1 ]" -icon error -title "$caption(fieldchart,erreur)"
            } else {
               tk_messageBox -message "$caption(fieldchart,pas_etoile)" -icon warning -title "$caption(fieldchart,attention)"
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
                  #--- Dessin des etoiles rouges visualisant la carte de champ
                  $audace(hCanvas) create oval $x1 $y1 $x2 $y2 -fill $color(red) -width 0 -tag chart
               }
            }
         }
      }
      ::mapWindow::recup_position
   }

   #
   # ::mapWindow::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      ::mapWindow::recup_position
      destroyDialog
   }

   #
   # ::mapWindow::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      ::audace::showHelpItem "$help(dir,analyse)" "1100carte_champ.htm"
   }

   #
   # ::mapWindow::cmdDelete
   # Effacement des etoiles rouges visualisant la carte de champ
   #
   proc cmdDelete { } {
      global audace

      #--- Effacement des etoiles rouges visualisant la carte de champ
      $audace(hCanvas) delete chart
   }

   #
   # ::mapWindow::cmdTakeWHFromPicture
   # Recupere la largeur et la hauteur de l'image
   #
   proc cmdTakeWHFromPicture { } {
      global audace mapWindow

      set mapWindow(PictureWidth)  [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      set mapWindow(PictureHeight) [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]
   }

   #
   # ::mapWindow::cmdTakeRaDecFromPicture
   # Recupere l'ascension droite et la declinaison de l'image
   #
   proc cmdTakeRaDecFromPicture { } {
      global audace mapWindow

      set mapWindow(CentreRA)  [ lindex [ buf$audace(bufNo) getkwd RA ] 1 ]
      set mapWindow(CentreDec) [ lindex [ buf$audace(bufNo) getkwd DEC ] 1 ]
   }

   #
   # ::mapWindow::toggleSource
   # Adapte l'interface graphique de la boite de dialogue
   proc toggleSource { } {
      variable This
      global mapWindow

      if { $mapWindow(FieldFromImage) == "1" } {
         pack forget $This.usr.2
      } else {
         pack $This.usr.2 -side top -fill both
      }
   }

   #
   # ::mapWindow::parcourir
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { } {
      variable This
      global audace caption

      set dirname [ tk_chooseDirectory -title "$caption(fieldchart,recherche)" \
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

