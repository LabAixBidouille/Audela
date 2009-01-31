#
# Fichier : fieldchart.tcl
# Description : Interfaces graphiques pour les fonctions carte de champ
# Auteur : Denis MARCHAIS
# Mise a jour $Id: fieldchart.tcl,v 1.1 2009-01-31 08:23:29 robertdelmas Exp $
#

#============================================================
# Declaration du namespace fieldchart
#    initialise le namespace
#============================================================
namespace eval ::fieldchart {
   package provide fieldchart 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] fieldchart.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(fieldchart,carte_champ)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "fieldchart.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "fieldchart"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "analysis" }
         subfunction1 { return "fieldchart" }
         display      { return "window" }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {
      variable This
      variable widget
      global caption conf

      #--- Inititalisation du nom de la fenetre
      set This "$tkbase"

      #--- Inititalisation de variables de configuration
      if { ! [ info exists conf(fieldchart,position) ] }     { set conf(fieldchart,position)  "+350+75" }
      if { ! [ info exists conf(fieldchart,catalogue) ] }    { set conf(fieldchart,catalogue) "$caption(fieldchart,microcat)" }
      if { ! [ info exists conf(fieldchart,magmax) ] }       { set conf(fieldchart,magmax)    "14" }
      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(fieldchart,path_cata) ] } { set conf(fieldchart,path_cata) "/cdrom/" }
      } else {
         if { ! [ info exists conf(fieldchart,path_cata) ] } { set conf(fieldchart,path_cata) "d:/" }
      }
   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {

   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {

   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      #--- J'ouvre la fenetre
      ::fieldchart::run
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      #--- Rien a faire, car la fenetre est fermee par l'utilisateur
   }

   #------------------------------------------------------------
   # confToWidget
   #    Charge les variables de configuration dans des variables locales
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(fieldchart,position)  "$conf(fieldchart,position)"
      set widget(fieldchart,catalogue) "$conf(fieldchart,catalogue)"
      set widget(fieldchart,magmax)    "$conf(fieldchart,magmax)"
      set widget(fieldchart,path_cata) "$conf(fieldchart,path_cata)"
   }

   #------------------------------------------------------------
   # widgetToConf
   #    Charge les variables locales dans des variables de configuration
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(fieldchart,position)  "$widget(fieldchart,position)"
      set conf(fieldchart,catalogue) "$widget(fieldchart,catalogue)"
      set conf(fieldchart,magmax)    "$widget(fieldchart,magmax)"
      set conf(fieldchart,path_cata) "$widget(fieldchart,path_cata)"
   }

   #------------------------------------------------------------
   # recup_position
   #    Recupere la position de la fenetre
   #------------------------------------------------------------
   proc recup_position { } {
      variable This
      variable widget
      global fieldchart

      set fieldchart(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $fieldchart(geometry) ] ]
      set fin [ string length $fieldchart(geometry) ]
      set widget(fieldchart,position) "+[string range $fieldchart(geometry) $deb $fin]"
      #---
      ::fieldchart::widgetToConf
   }

   #------------------------------------------------------------
   # run
   #    Lance la boite de dialogue pour les cartes de champ
   #------------------------------------------------------------
   proc run { } {
      variable This
      variable widget
      global audace fieldchart

      #---
      ::fieldchart::initPlugin "$audace(base).fieldchart"
      ::fieldchart::confToWidget
      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         if { [ info exists fieldchart(geometry) ] } {
            set deb [ expr 1 + [ string first + $fieldchart(geometry) ] ]
            set fin [ string length $fieldchart(geometry) ]
            set widget(fieldchart,position) "+[string range $fieldchart(geometry) $deb $fin]"
         }
         createDialog
      }
   }

   #------------------------------------------------------------
   # createDialog
   #    Creation de l'interface graphique
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf fieldchart

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(fieldchart,titre)"
      wm geometry $This $widget(fieldchart,position)
      wm protocol $This WM_DELETE_WINDOW ::fieldchart::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief flat

         frame $This.usr.1 -borderwidth 1 -relief raised

            checkbutton $This.usr.1.che1 -text "$caption(fieldchart,champ_image)" \
               -variable fieldchart(FieldFromImage) -command { ::fieldchart::toggleSource }
            grid $This.usr.1.che1 -row 0 -column 0 -columnspan 2 -padx 5 -pady 2  -sticky w

            label $This.usr.1.lab1 -text "$caption(fieldchart,catalogue)"
            grid $This.usr.1.lab1 -row 1 -column 0 -padx 5 -pady 2 -sticky w

            set list_combobox [ list $caption(fieldchart,microcat) $caption(fieldchart,tycho) $caption(fieldchart,loneos) ]
            ComboBox $This.usr.1.cata \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::fieldchart::widget(fieldchart,catalogue) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.cata -row 1 -column 1 -padx 5 -pady 2 -sticky e

            label $This.usr.1.lab3 -text "$caption(fieldchart,cat_microcat)"
            grid $This.usr.1.lab3 -row 2 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.1.ent1 -textvariable ::fieldchart::widget(fieldchart,path_cata)
            grid $This.usr.1.ent1 -row 2 -column 1 -padx 5 -pady 2 -sticky e

            button $This.usr.1.explore -text "$caption(fieldchart,parcourir)" -width 1 \
               -command { set ::fieldchart::widget(fieldchart,path_cata) [ ::fieldchart::parcourir ] }
            grid $This.usr.1.explore -row 2 -column 2 -padx 5 -pady 2 -sticky w

            label $This.usr.1.lab2 -text "$caption(fieldchart,magnitude_limite)"
            grid $This.usr.1.lab2 -row 3 -column 0 -padx 5 -pady 2 -sticky w

            set list_combobox [ list "10" "12" "14" "16" ]
            ComboBox $This.usr.1.magmax \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::fieldchart::widget(fieldchart,magmax) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.magmax -row 3 -column 1 -padx 5 -pady 2 -sticky e

         pack $This.usr.1 -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised

            label $This.usr.2.lab1 -text "$caption(fieldchart,largeur_image)"
            grid $This.usr.2.lab1 -row 0 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent1 -textvariable fieldchart(PictureWidth) -width 5
            grid $This.usr.2.ent1 -row 0 -column 1 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab2 -text "$caption(fieldchart,hauteur_image)"
            grid $This.usr.2.lab2 -row 1 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent2 -textvariable fieldchart(PictureHeight) -width 5
            grid $This.usr.2.ent2 -row 1 -column 1 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but1 -text "$caption(fieldchart,prendre_image)" -command { ::fieldchart::cmdTakeWHFromPicture }
            grid $This.usr.2.but1 -column 2 -row 0 -rowspan 2 -padx 5 -pady 5 -ipady 5 -sticky news

            label $This.usr.2.lab3 -text "$caption(fieldchart,ad_centre)"
            grid $This.usr.2.lab3 -column 0 -row 2 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent3 -textvariable fieldchart(CentreRA) -width 10
            grid $This.usr.2.ent3 -column 1 -row 2 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab4 -text "$caption(fieldchart,dec_centre)"
            grid $This.usr.2.lab4 -column 0 -row 3 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent4 -textvariable fieldchart(CentreDec) -width 10
            grid $This.usr.2.ent4 -column 1 -row 3 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but2 -text "$caption(fieldchart,prendre_image)" -command { ::fieldchart::cmdTakeRaDecFromPicture }
            grid $This.usr.2.but2  -column 2 -row 2 -rowspan 2 -padx 5 -pady 5 -ipady 5 -sticky news

            label $This.usr.2.lab5 -text "$caption(fieldchart,inclinaison_camera)"
            grid $This.usr.2.lab5 -column 0 -row 4 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent5 -textvariable fieldchart(Inclin) -width 10
            grid $This.usr.2.ent5 -column 1 -row 4 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab6 -text "$caption(fieldchart,focale_instrument)"
            grid $This.usr.2.lab6 -column 0 -row 5 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent6 -textvariable fieldchart(FocLen) -width 10
            grid $This.usr.2.ent6 -column 1 -row 5 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab7 -text "$caption(fieldchart,taille_pixels)"
            grid $This.usr.2.lab7 -column 0 -row 6 -padx 5 -pady 2 -sticky w

            frame $This.usr.2.1 -borderwidth 0 -relief flat

               entry $This.usr.2.1.ent1 -textvariable fieldchart(PixSize1) -width 3
               pack $This.usr.2.1.ent1 -side left

               label $This.usr.2.1.lab1 -text "$caption(fieldchart,x)"
               pack $This.usr.2.1.lab1 -side left

               entry $This.usr.2.1.ent2 -textvariable fieldchart(PixSize2) -width 3
               pack $This.usr.2.1.ent2 -side left

            grid $This.usr.2.1 -column 1 -row 6 -columnspan 3  -padx 5 -pady 2 -sticky w

         pack $This.usr.2 -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised

         button $This.cmd.ok -text "$caption(fieldchart,ok)" -width 7 \
            -command "::fieldchart::cmdOk"
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $This.cmd.appliquer -text "$caption(fieldchart,appliquer)" -width 8 \
            -command "::fieldchart::cmdApply"
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.effacer -text "$caption(fieldchart,effacer)" -width 10 \
            -command "::fieldchart::cmdDelete"
         pack $This.cmd.effacer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.fermer -text "$caption(fieldchart,fermer)" -width 8 \
            -command "::fieldchart::cmdClose"
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.aide -text "$caption(fieldchart,aide)" -width 8 \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::fieldchart::getPluginType ] ] \
               [ ::fieldchart::getPluginDirectory ] [ ::fieldchart::getPluginHelp ]"
         pack $This.cmd.aide -side left -padx 3 -pady 3 -ipady 5 -fill x

      pack $This.cmd -side top -fill x

      #--- La fenetre est active
      focus $This

      #--- Mise a jour de la fenetre
      ::fieldchart::toggleSource

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

   }

   #------------------------------------------------------------
   # destroyDialog
   #    Procedure correspondant a la fermeture de la fenetre
   #------------------------------------------------------------
   proc destroyDialog { } {
      variable This

      destroy $This
      unset This
   }

   #------------------------------------------------------------
   # cmdOk
   #    Procedure correspondant a l'appui sur le bouton OK
   #------------------------------------------------------------
   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   #------------------------------------------------------------
   # cmdApply
   #    Procedure correspondant a l'appui sur le bouton Appliquer
   #------------------------------------------------------------
   proc cmdApply { } {
      variable This
      variable widget
      global audace caption color etoiles fieldchart

      set unit "e-6"

      if { [ buf$audace(bufNo) imageready ] == "1" } {
         #--- Efface la carte de champ precedante
         ::fieldchart::cmdDelete
         #--- Definition des parametres optiques
         if { $fieldchart(FieldFromImage) == "0" } {
            if { $fieldchart(PictureWidth) != "" && $fieldchart(PictureHeight) != "" && $fieldchart(CentreRA) != "" && \
                 $fieldchart(CentreDec) != "" && $fieldchart(Inclin) != "" && $fieldchart(FocLen) != "" && \
                 $fieldchart(PixSize1) != "" && $fieldchart(PixSize2) != "" } {
               set field [ list OPTIC NAXIS1 $fieldchart(PictureWidth) NAXIS2 $fieldchart(PictureHeight) ]
               lappend field FOCLEN $fieldchart(FocLen) PIXSIZE1 $fieldchart(PixSize1)$unit PIXSIZE2 $fieldchart(PixSize2)$unit
               lappend field CROTA2 $fieldchart(Inclin) RA $fieldchart(CentreRA) DEC $fieldchart(CentreDec)
            } else {
               return
            }
         } else {
            set field [ list BUFFER $audace(bufNo) ]
         }

         #--- Liste des objets
         set choix [ $This.usr.1.cata get ]
         if { ! [ string compare $choix $caption(fieldchart,microcat) ] } {
            set objects [ list * ASTROMMICROCAT $::fieldchart::widget(fieldchart,path_cata) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,tycho) ] } {
            set objects [ list * TYCHOMICROCAT $::fieldchart::widget(fieldchart,path_cata) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,loneos) ] } {
            set objects [ list * LONEOSMICROCAT $::fieldchart::widget(fieldchart,path_cata) ]
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
      ::fieldchart::recup_position
   }

   #------------------------------------------------------------
   # cmdClose
   #    Procedure correspondant a l'appui sur le bouton Fermer
   #------------------------------------------------------------
   proc cmdClose { } {
      ::fieldchart::recup_position
      destroyDialog
   }

   #------------------------------------------------------------
   # cmdDelete
   #    Effacement des etoiles rouges visualisant la carte de champ
   #------------------------------------------------------------
   proc cmdDelete { } {
      global audace

      #--- Effacement des etoiles rouges visualisant la carte de champ
      $audace(hCanvas) delete chart
   }

   #------------------------------------------------------------
   # cmdTakeWHFromPicture
   #    Recupere la largeur et la hauteur de l'image
   #------------------------------------------------------------
   proc cmdTakeWHFromPicture { } {
      global audace fieldchart

      set fieldchart(PictureWidth)  [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      set fieldchart(PictureHeight) [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]
   }

   #------------------------------------------------------------
   # cmdTakeRaDecFromPicture
   #    Recupere l'ascension droite et la declinaison de l'image
   #------------------------------------------------------------
   proc cmdTakeRaDecFromPicture { } {
      global audace fieldchart

      set fieldchart(CentreRA)  [ lindex [ buf$audace(bufNo) getkwd RA ] 1 ]
      set fieldchart(CentreDec) [ lindex [ buf$audace(bufNo) getkwd DEC ] 1 ]
   }

   #------------------------------------------------------------
   # toggleSource
   #    Adapte l'interface graphique de la boite de dialogue
   #------------------------------------------------------------
   proc toggleSource { } {
      variable This
      global fieldchart

      if { $fieldchart(FieldFromImage) == "1" } {
         pack forget $This.usr.2
      } else {
         pack $This.usr.2 -side top -fill both
      }
   }

   #------------------------------------------------------------
   # parcourir
   #    Ouvre un explorateur pour choisir un fichier
   #------------------------------------------------------------
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

