#
# Fichier : fieldchart.tcl
# Description : Interfaces graphiques pour les fonctions carte de champ
# Auteur : Denis MARCHAIS
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace fieldchart
#    initialise le namespace
#============================================================
namespace eval ::fieldchart {
   package provide fieldchart 1.0

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
   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      variable This
      global audace caption conf

      #--- Inititalisation du nom de la fenetre
      set This "$audace(base).fieldchart"

      #--- Inititalisation de variables de configuration
      if { ! [ info exists conf(fieldchart,position) ] }    { set conf(fieldchart,position)    "+350+75" }
      if { ! [ info exists conf(fieldchart,catalogue) ] }   { set conf(fieldchart,catalogue)   "$caption(fieldchart,microcat)" }
      if { ! [ info exists conf(fieldchart,magmax) ] }      { set conf(fieldchart,magmax)      "14" }
      if { ! [ info exists conf(fieldchart,pathCatalog) ] } { set conf(fieldchart,pathCatalog) "$audace(rep_userCatalog)" }
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      variable This

      if { [ winfo exists $This ] } {
         #--- Je ferme la fenetre si l'utilsateur ne l'a pas deja fait
         ::fieldchart::cmdClose
      }
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

      set widget(fieldchart,position)    "$conf(fieldchart,position)"
      set widget(fieldchart,catalogue)   "$conf(fieldchart,catalogue)"
      set widget(fieldchart,magmax)      "$conf(fieldchart,magmax)"
      set widget(fieldchart,pathCatalog) "$conf(fieldchart,pathCatalog)"
   }

   #------------------------------------------------------------
   # widgetToConf
   #    Charge les variables locales dans des variables de configuration
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(fieldchart,position)    "$widget(fieldchart,position)"
      set conf(fieldchart,catalogue)   "$widget(fieldchart,catalogue)"
      set conf(fieldchart,magmax)      "$widget(fieldchart,magmax)"
      set conf(fieldchart,pathCatalog) "$widget(fieldchart,pathCatalog)"
   }

   #------------------------------------------------------------
   # recupPosition
   #    Recupere la position de la fenetre
   #------------------------------------------------------------
   proc recupPosition { } {
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

      #--- J'active la mise a jour automatique de l'affichage quand on change de zoom
      ::confVisu::addZoomListener $audace(visuNo) "::fieldchart::refreshChart"

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
               -variable fieldchart(FieldFromImage) -command "::fieldchart::toggleSource"
            grid $This.usr.1.che1 -row 0 -column 0 -columnspan 2 -padx 5 -pady 2 -sticky w

            label $This.usr.1.lab1 -text "$caption(fieldchart,catalogue)"
            grid $This.usr.1.lab1 -row 1 -column 0 -padx 5 -pady 2 -sticky w

            set list_combobox [ list $caption(fieldchart,microcat) $caption(fieldchart,tycho) \
               $caption(fieldchart,loneos) $caption(fieldchart,usno) ]
            ComboBox $This.usr.1.cata \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -textvariable ::fieldchart::widget(fieldchart,catalogue) \
               -editable 0       \
               -values $list_combobox
            grid $This.usr.1.cata -row 1 -column 1 -padx 5 -pady 2 -sticky e

            label $This.usr.1.lab3 -text "$caption(fieldchart,recherche)"
            grid $This.usr.1.lab3 -row 2 -column 0 -padx 5 -pady 2 -sticky w

            entry $This.usr.1.ent1 -textvariable ::fieldchart::widget(fieldchart,pathCatalog) -width 30
            grid $This.usr.1.ent1 -row 2 -column 1 -padx 5 -pady 2 -sticky e
            $This.usr.1.ent1 xview end

            button $This.usr.1.explore -text "$caption(fieldchart,parcourir)" -width 1 \
               -command "::fieldchart::cataFolder"
            grid $This.usr.1.explore -row 2 -column 2 -padx 5 -pady 2 -sticky w

            label $This.usr.1.lab2 -text "$caption(fieldchart,magnitude_limite)"
            grid $This.usr.1.lab2 -row 3 -column 0 -padx 5 -pady 2 -sticky w

            set list_combobox [ list 6 8 10 12 14 16 18 20 22 24 ]
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

            label $This.usr.2.lab3 -text "$caption(fieldchart,ad_centre)"
            grid $This.usr.2.lab3 -column 0 -row 2 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent3 -textvariable fieldchart(CentreRA) -width 14
            grid $This.usr.2.ent3 -column 1 -row 2 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab4 -text "$caption(fieldchart,dec_centre)"
            grid $This.usr.2.lab4 -column 0 -row 3 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent4 -textvariable fieldchart(CentreDec) -width 14
            grid $This.usr.2.ent4 -column 1 -row 3 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab5 -text "$caption(fieldchart,inclinaison_camera)"
            grid $This.usr.2.lab5 -column 0 -row 4 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent5 -textvariable fieldchart(Inclin) -width 14
            grid $This.usr.2.ent5 -column 1 -row 4 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab6 -text "$caption(fieldchart,focale_instrument)"
            grid $This.usr.2.lab6 -column 0 -row 5 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent6 -textvariable fieldchart(FocLen) -width 14
            grid $This.usr.2.ent6 -column 1 -row 5 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab7 -text "$caption(fieldchart,taille_pixels)"
            grid $This.usr.2.lab7 -column 0 -row 6 -padx 5 -pady 2 -sticky w

            frame $This.usr.2.1 -borderwidth 0 -relief flat

               entry $This.usr.2.1.ent1 -textvariable fieldchart(PixSize1) -width 5
               pack $This.usr.2.1.ent1 -side left

               label $This.usr.2.1.lab1 -text "$caption(fieldchart,x)"
               pack $This.usr.2.1.lab1 -side left

               entry $This.usr.2.1.ent2 -textvariable fieldchart(PixSize2) -width 5
               pack $This.usr.2.1.ent2 -side left

            grid $This.usr.2.1 -column 1 -row 6 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab8 -text "$caption(fieldchart,crpix1)"
            grid $This.usr.2.lab8 -column 0 -row 7 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent8 -textvariable fieldchart(Crpix1) -width 10
            grid $This.usr.2.ent8 -column 1 -row 7 -padx 5 -pady 2 -sticky w

            label $This.usr.2.lab9 -text "$caption(fieldchart,crpix2)"
            grid $This.usr.2.lab9 -column 0 -row 8 -padx 5 -pady 2 -sticky w

            entry $This.usr.2.ent9 -textvariable fieldchart(Crpix2) -width 10
            grid $This.usr.2.ent9 -column 1 -row 8 -padx 5 -pady 2 -sticky w

            button $This.usr.2.but3 -text "$caption(fieldchart,prendre_image)" \
               -command "::fieldchart::cmdTakeFITSKeywords"
            grid $This.usr.2.but3 -column 2 -row 0 -rowspan 9 -padx 5 -pady 5 -ipady 5 -sticky news

         pack $This.usr.2 -side top -fill both -expand 1

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised

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

      #--- Telechargement du catalogue MicroCat
      if  { $widget(fieldchart,pathCatalog) == "" } {
         ::fieldchart::loadMicroCat
      }
   }

   #------------------------------------------------------------
   # destroyDialog
   #    Procedure correspondant a la fermeture de la fenetre
   #------------------------------------------------------------
   proc destroyDialog { } {
      variable This

      destroy $This
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
                 $fieldchart(PixSize1) != "" && $fieldchart(PixSize2) != "" && $fieldchart(Crpix1) != "" &&
                 $fieldchart(Crpix2) != "" } {
               set field [ list OPTIC NAXIS1 $fieldchart(PictureWidth) NAXIS2 $fieldchart(PictureHeight) \
                  FOCLEN $fieldchart(FocLen) PIXSIZE1 $fieldchart(PixSize1)$unit PIXSIZE2 $fieldchart(PixSize2)$unit \
                  CROTA2 $fieldchart(Inclin) RA $fieldchart(CentreRA) DEC $fieldchart(CentreDec) \
                  CRPIX1 $fieldchart(Crpix1) CRPIX2 $fieldchart(Crpix2) ]
               } else {
               return
            }
         } else {
            set field [ list BUFFER $audace(bufNo) ]
         }

         #--- Liste des objets
         set choix [ $This.usr.1.cata get ]
         if { ! [ string compare $choix $caption(fieldchart,microcat) ] } {
            set objects [ list * ASTROMMICROCAT $::fieldchart::widget(fieldchart,pathCatalog) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,tycho) ] } {
            set objects [ list * TYCHOMICROCAT $::fieldchart::widget(fieldchart,pathCatalog) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,loneos) ] } {
            set objects [ list * LONEOSMICROCAT $::fieldchart::widget(fieldchart,pathCatalog) ]
         } elseif { ! [ string compare $choix $caption(fieldchart,usno) ] } {
            set objects [ list * USNO $::fieldchart::widget(fieldchart,pathCatalog) ]
         }
         set result [ list LIST ]
         set magmax [ $This.usr.1.magmax get ]

         set a_executer { mc_readcat $field $objects $result -magb< $magmax -magr< $magmax }

         set msg [ eval $a_executer ]

         if { [ llength $msg ] == "1" } {
            set msg [ lindex $msg 0 ]
            if { [ lindex $msg 0 ] == "Pb" } {
               tk_messageBox -message "[ lindex $msg 1 ]" -icon error -title "$caption(fieldchart,erreur)"
            } else {
               tk_messageBox -message "$caption(fieldchart,pas_etoile)" -icon warning \
                  -title "$caption(fieldchart,attention)"
            }
         } else {
             set etoiles [ lreplace $msg end end ]
             ::fieldchart::refreshChart
         }
      }
      ::fieldchart::recupPosition
   }

   #------------------------------------------------------------
   # cmdClose
   #    Procedure correspondant a l'appui sur le bouton Fermer
   #------------------------------------------------------------
   proc cmdClose { } {
      global audace

      #--- Je desactive l'adaptation de l'affichage quand on change de zoom
      ::confVisu::removeZoomListener $audace(visuNo) "::fieldchart::refreshChart"

      #---
      ::fieldchart::recupPosition
      ::fieldchart::cmdDelete
      ::fieldchart::destroyDialog
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
   # refreshChart
   #    Reconstruction des points rouges materialisant les etoiles
   #------------------------------------------------------------
   proc refreshChart { args } {
      global audace color etoiles

      #--- Efface les points rouges meme s'ils n'existent pas
      ::fieldchart::cmdDelete

      #--- Dessine les points rouges
      foreach star $etoiles {
         if { [ llength $star ] == "7" } {
            set coord [ lrange $star 4 5 ]
            lassign [ ::audace::picture2Canvas $coord ] x y
            lassign [ list [ expr $x-2 ] [ expr $y-2 ] [ expr $x+2 ] [ expr $y+2 ] ] x1 y1 x2 y2
            $audace(hCanvas) create oval $x1 $y1 $x2 $y2 -fill $color(red) -width 0 -tag chart
         }
      }
   }

   #------------------------------------------------------------
   # cmdTakeFITSKeywords
   #    Recupere naxis1, naxis2, AD, Dec.,l'inclinaison de la
   #    camera, la focale de l'instrument et la taille des pixels
   #------------------------------------------------------------
   proc cmdTakeFITSKeywords { } {
      global audace fieldchart

      set fieldchart(PictureWidth)  [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      set fieldchart(PictureHeight) [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]
      set fieldchart(CentreRA)      [ lindex [ buf$audace(bufNo) getkwd RA ] 1 ]
      set fieldchart(CentreDec)     [ lindex [ buf$audace(bufNo) getkwd DEC ] 1 ]
      set fieldchart(Inclin)        [ lindex [ buf$audace(bufNo) getkwd CROTA2 ] 1 ]
      set fieldchart(FocLen)        [ lindex [ buf$audace(bufNo) getkwd FOCLEN ] 1 ]
      set fieldchart(PixSize1)      [ lindex [ buf$audace(bufNo) getkwd PIXSIZE1 ] 1 ]
      set fieldchart(PixSize2)      [ lindex [ buf$audace(bufNo) getkwd PIXSIZE2 ] 1 ]
      set fieldchart(Crpix1)        [ lindex [ buf$audace(bufNo) getkwd CRPIX1 ] 1 ]
      set fieldchart(Crpix2)        [ lindex [ buf$audace(bufNo) getkwd CRPIX2 ] 1 ]
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
   # cataFolder
   #    Affiche le chemin du catalogue
   #------------------------------------------------------------
   proc cataFolder { } {
      variable This
      variable widget

      set widget(fieldchart,pathCatalog) [ ::fieldchart::parcourir ]
      $This.usr.1.ent1 xview end
   }

   #------------------------------------------------------------
   # parcourir
   #    Ouvre un explorateur pour choisir un fichier
   #------------------------------------------------------------
   proc parcourir { } {
      variable This
      global audace caption conf

      set dirname [ tk_chooseDirectory -title "$caption(fieldchart,recherche)" \
         -initialdir "$audace(rep_userCatalog)" -parent $This ]
      set len [ string length $dirname ]
      set folder "$dirname"
      if { $len > "0" } {
         set car [ string index "$dirname" [ expr $len-1 ] ]
         if { $car != "/" } {
            append folder "/"
         }
         set dirname $folder
      }
      if { $dirname == "" } {
         set dirname $conf(fieldchart,pathCatalog)
      }
      return $dirname
   }

   #------------------------------------------------------------
   # loadMicroCat
   #    Invite au telechargement de Microcat
   #------------------------------------------------------------
   proc loadMicroCat { } {
      variable This
      global audace caption color

      if [ winfo exists $audace(base).loadMicrocat ] {
         destroy $audace(base).loadMicrocat
      }
      toplevel $audace(base).loadMicrocat
      wm transient $audace(base).loadMicrocat $This
      wm title $audace(base).loadMicrocat "$caption(fieldchart,microcat)"
      set posx_maj [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
      set posy_maj [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
      wm geometry $audace(base).loadMicrocat +[ expr $posx_maj + 10 ]+[ expr $posy_maj + 105 ]
      wm resizable $audace(base).loadMicrocat 0 0
      set fg $color(blue)

      #--- Cree l'affichage du message
      label $audace(base).loadMicrocat.lab1 -text "$caption(fieldchart,loadMicrocat_1)"
      pack $audace(base).loadMicrocat.lab1 -padx 10 -pady 2
      label $audace(base).loadMicrocat.labURL2 -text "$caption(fieldchart,loadMicrocat_2)" -fg $fg
      pack $audace(base).loadMicrocat.labURL2 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).loadMicrocat

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $audace(base).loadMicrocat.labURL2 <ButtonPress-1> {
        set filename "$caption(fieldchart,loadMicrocat_2)"
         ::audace::Lance_Site_htm $filename
      }
      bind $audace(base).loadMicrocat.labURL2 <Enter> {
         set fg2 $color(purple)
         $audace(base).loadMicrocat.labURL2 configure -fg $fg2
      }
      bind $audace(base).loadMicrocat.labURL2 <Leave> {
         set fg3 $color(blue)
         $audace(base).loadMicrocat.labURL2 configure -fg $fg3
      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).loadMicrocat
   }

}

