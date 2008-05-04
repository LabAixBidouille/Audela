#
# Fichier : confoptic.tcl
# Description : Affiche la fenetre de configuration des systemes optiques associes aux cameras A, B et C
# Auteur : Robert DELMAS
# Mise a jour $Id: confoptic.tcl,v 1.28 2008-05-04 06:25:03 robertdelmas Exp $
#

namespace eval ::confOptic {

   #------------------------------------------------------------
   #  init
   #     Initialise les captions et les variables de
   #     configuration de chaque systeme optique
   #
   #------------------------------------------------------------
   proc init { } {
      global audace

      source [ file join $audace(rep_caption) confoptic.cap ]
      initConf
   }

   #------------------------------------------------------------
   #  run
   #     Cree la fenetre de choix et de configuration des
   #     systemes optiques associes aux cameras A, B et C
   #
   #------------------------------------------------------------
   proc run { visuNo } {
      variable This
      global audace

      set This "$audace(base).confOptic"
      createDialog $visuNo
   }

   #------------------------------------------------------------
   #  initConf
   #     Initialise les parametres de chaque systeme optique
   #     dans le tableau conf()
   #
   #------------------------------------------------------------
   proc initConf { } {
      variable widget
      global caption conf

      #--- Position de la fenetre
      if { ! [ info exists conf(confoptic,position) ] } { set conf(confoptic,position) "+15+0" }

      #--- Instrumentation associee a la camera A
      if { ! [ info exists conf(confoptic,combinaison_optique_A,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique_A(diametre)         "0.203"
         set combinaison_optique_A(focale)           "2.0"
         set combinaison_optique_A(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique_A,0) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique_A(diametre)         "0.203"
         set combinaison_optique_A(focale)           "2.0"
         set combinaison_optique_A(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique_A,1) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique_A(diametre)         "0.203"
         set combinaison_optique_A(focale)           "2.0"
         set combinaison_optique_A(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique_A,2) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique_A(diametre)         "0.203"
         set combinaison_optique_A(focale)           "2.0"
         set combinaison_optique_A(barlow_reduc)     "2.5"

         set conf(confoptic,combinaison_optique_A,3) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,4) ] } { set conf(confoptic,combinaison_optique_A,4) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_A,5) ] } { set conf(confoptic,combinaison_optique_A,5) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_A,6) ] } { set conf(confoptic,combinaison_optique_A,6) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_A,7) ] } { set conf(confoptic,combinaison_optique_A,7) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_A,8) ] } { set conf(confoptic,combinaison_optique_A,8) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_A,9) ] } { set conf(confoptic,combinaison_optique_A,9) "" }

      #--- Instrumentation associee a la camera B
      if { ! [ info exists conf(confoptic,combinaison_optique_B,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique_B(diametre)         "0.203"
         set combinaison_optique_B(focale)           "2.0"
         set combinaison_optique_B(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique_B,0) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique_B(diametre)         "0.203"
         set combinaison_optique_B(focale)           "2.0"
         set combinaison_optique_B(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique_B,1) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique_B(diametre)         "0.203"
         set combinaison_optique_B(focale)           "2.0"
         set combinaison_optique_B(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique_B,2) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique_B(diametre)         "0.203"
         set combinaison_optique_B(focale)           "2.0"
         set combinaison_optique_B(barlow_reduc)     "2.5"

         set conf(confoptic,combinaison_optique_B,3) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,4) ] } { set conf(confoptic,combinaison_optique_B,4) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_B,5) ] } { set conf(confoptic,combinaison_optique_B,5) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_B,6) ] } { set conf(confoptic,combinaison_optique_B,6) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_B,7) ] } { set conf(confoptic,combinaison_optique_B,7) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_B,8) ] } { set conf(confoptic,combinaison_optique_B,8) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_B,9) ] } { set conf(confoptic,combinaison_optique_B,9) "" }

      #--- Instrumentation associee a la camera C
      if { ! [ info exists conf(confoptic,combinaison_optique_C,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_C { }
         set combinaison_optique_C(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique_C(diametre)         "0.203"
         set combinaison_optique_C(focale)           "2.0"
         set combinaison_optique_C(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique_C,0) [ array get combinaison_optique_C ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_C,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_C { }
         set combinaison_optique_C(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique_C(diametre)         "0.203"
         set combinaison_optique_C(focale)           "2.0"
         set combinaison_optique_C(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique_C,1) [ array get combinaison_optique_C ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_C,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_C { }
         set combinaison_optique_C(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique_C(diametre)         "0.203"
         set combinaison_optique_C(focale)           "2.0"
         set combinaison_optique_C(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique_C,2) [ array get combinaison_optique_C ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_C,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_C { }
         set combinaison_optique_C(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique_C(diametre)         "0.203"
         set combinaison_optique_C(focale)           "2.0"
         set combinaison_optique_C(barlow_reduc)     "2.5"

         set conf(confoptic,combinaison_optique_C,3) [ array get combinaison_optique_C ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_C,4) ] } { set conf(confoptic,combinaison_optique_C,4) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_C,5) ] } { set conf(confoptic,combinaison_optique_C,5) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_C,6) ] } { set conf(confoptic,combinaison_optique_C,6) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_C,7) ] } { set conf(confoptic,combinaison_optique_C,7) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_C,8) ] } { set conf(confoptic,combinaison_optique_C,8) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_C,9) ] } { set conf(confoptic,combinaison_optique_C,9) "" }

      #--- J'initialise les combobox du binning
      foreach camItem { A B C } {
         set widget($camItem,binning) "1x1"
      }
   }

   #------------------------------------------------------------
   #  ok
   #     Fonction appellee lors de l'appui sur le bouton 'OK'
   #     pour appliquer la configuration et fermer la fenetre
   #     de reglage des systemes optiques
   #
   #------------------------------------------------------------
   proc ok { visuNo } {
      variable This

      $This.cmd.ok configure -relief groove -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.fermer configure -state disabled
      appliquer
      fermer $visuNo
   }

   #------------------------------------------------------------
   #  appliquer
   #     Fonction appellee lors de l'appui sur le bouton
   #     'Appliquer' pour memoriser et appliquer la
   #     configuration
   #
   #------------------------------------------------------------
   proc appliquer { } {
      variable This

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -relief groove -state disabled
      $This.cmd.fermer configure -state disabled
      widgetToConf
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -relief raised -state normal
      $This.cmd.fermer configure -state normal
   }

   #------------------------------------------------------------
   #  afficherAide
   #     Aide
   #
   #------------------------------------------------------------
   proc afficherAide { } {
      global help

      ::audace::showHelpItem "$help(dir,optic)" "1010config_optique.htm"
   }

   #------------------------------------------------------------
   #  fermer
   #     Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   #------------------------------------------------------------
   proc fermer { visuNo } {
      variable This

      #--- Supprime la procedure de surveillance de la connexion d'une camera
      ::confCam::removeCameraListener "A" "::confOptic::MAJ_Binning A [ $This.usr.onglet getframe fillConfigCameraA ]"
      ::confCam::removeCameraListener "B" "::confOptic::MAJ_Binning B [ $This.usr.onglet getframe fillConfigCameraB ]"
      ::confCam::removeCameraListener "C" "::confOptic::MAJ_Binning C [ $This.usr.onglet getframe fillConfigCameraC ]"
      #---
      recup_position
      destroy $This
   }

   #------------------------------------------------------------
   #  recup_position
   #     Permet de recuperer et de sauvegarder la position
   #     de la fenetre de configuration des systemes optiques
   #
   #------------------------------------------------------------
   proc recup_position { } {
      variable This
      variable widget
      global conf

      set widget(telescope,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $widget(telescope,geometry) ] ]
      set fin [ string length $widget(telescope,geometry) ]
      set widget(confoptic,position) "+[ string range $widget(telescope,geometry) $deb $fin ]"
      #---
      set conf(confoptic,position) $widget(confoptic,position)
   }

   #------------------------------------------------------------
   #  createDialog
   #     Creation de la boite qui va accueillir les onglets
   #
   #------------------------------------------------------------
   proc createDialog { visuNo } {
      variable This
      variable widget
      global caption conf

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }
      #--- J'initialise les valeurs des parametres
      confToWidget
      #---
      toplevel $This
      wm geometry $This 540x535$widget(confoptic,position)
      wm minsize $This 540 535
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(confoptic,config_optique)"
      wm protocol $This WM_DELETE_WINDOW "::confOptic::fermer $visuNo"

      #--- Frame des onglets
      frame $This.usr -borderwidth 0 -relief raised

         #--- Creation de la fenetre a onglets
         set notebook [ NoteBook $This.usr.onglet ]

         fillConfigCameraA [ $notebook insert end fillConfigCameraA -text "$caption(confoptic,camera_A)  " \
                               -raisecmd "::confOptic::cmdOngletCameraA" ]
         fillConfigCameraB [ $notebook insert end fillConfigCameraB -text "$caption(confoptic,camera_B)  " \
                               -raisecmd "::confOptic::cmdOngletCameraB" ]
         fillConfigCameraC [ $notebook insert end fillConfigCameraC -text "$caption(confoptic,camera_C)  " \
                               -raisecmd "::confOptic::cmdOngletCameraC" ]

         pack $notebook -fill both -expand 1 -padx 4 -pady 4

         $notebook raise [ $notebook page 0 ]

      pack $This.usr -side top -fill both -expand 1

      #--- Definition des frames recevant les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(confoptic,ok)" -relief raised -state normal -width 7 \
            -command "::confOptic::ok $visuNo"
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(confoptic,appliquer)" -relief raised -state normal -width 8 \
            -command "::confOptic::appliquer"
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(confoptic,fermer)" -relief raised -state normal -width 7 \
            -command "::confOptic::fermer $visuNo"
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(confoptic,aide)" -relief raised -state normal -width 7 \
            -command "::confOptic::afficherAide"
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Charge la procedure de surveillance de la connexion d'une camera
      ::confCam::addCameraListener "A" "::confOptic::MAJ_Binning A [ $This.usr.onglet getframe fillConfigCameraA ]"
      ::confCam::addCameraListener "B" "::confOptic::MAJ_Binning B [ $This.usr.onglet getframe fillConfigCameraB ]"
      ::confCam::addCameraListener "C" "::confOptic::MAJ_Binning C [ $This.usr.onglet getframe fillConfigCameraC ]"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  cmdOngletCameraA
   #     Procedure executee lorsqu'on selectionne l'onglet numero 1
   #------------------------------------------------------------
   proc cmdOngletCameraA { } {
      variable This
      variable widget

      #--- Affiche en gras le titre de l'onglet
      ::confOptic::onRaiseNotebook [ $This.usr.onglet raise "fillConfigCameraA" ]
      #--- Mise a jour des parametres de la camera CCD A
      ::confOptic::MAJ_Conf_Camera A $widget(frm)
   }

   #------------------------------------------------------------
   #  cmdOngletCameraB
   #     Procedure executee lorsqu'on selectionne l'onglet numero 2
   #------------------------------------------------------------
   proc cmdOngletCameraB { } {
      variable This
      variable widget

      #--- Affiche en gras le titre de l'onglet
      ::confOptic::onRaiseNotebook [ $This.usr.onglet raise "fillConfigCameraB" ]
      #--- Mise a jour des parametres de la camera CCD B
      ::confOptic::MAJ_Conf_Camera B $widget(frm)
   }

   #------------------------------------------------------------
   #  cmdOngletCameraC
   #     Procedure executee lorsqu'on selectionne l'onglet numero 3
   #------------------------------------------------------------
   proc cmdOngletCameraC { } {
      variable This
      variable widget

      #--- Affiche en gras le titre de l'onglet
      ::confOptic::onRaiseNotebook [ $This.usr.onglet raise "fillConfigCameraC" ]
      #--- Mise a jour des parametres de la camera CCD C
      ::confOptic::MAJ_Conf_Camera C $widget(frm)
   }

   #------------------------------------------------------------
   #  onRaiseNotebook
   #     Affiche en gras le nom de l'onglet
   #------------------------------------------------------------
   proc onRaiseNotebook { ongletName } {
      variable This

      set font [ $This.usr.onglet.c itemcget "$ongletName:text" -font ]
      lappend font "bold"
      #--- Remarque : Il faut attendre que l'onglet soit redessine avant de changer la police
      after 200 $This.usr.onglet.c itemconfigure "$ongletName:text" -font [ list $font ]
   }

   #------------------------------------------------------------
   #  confToWidget
   #     Copie les parametres du tableau conf() dans les
   #     variables des widgets
   #
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique A
      set widget(A,config_liste) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_A,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_A $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_A(instrument) - $combinaison_optique_A(diametre) - $combinaison_optique_A(focale) -\
            $combinaison_optique_A(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(A,config_liste) "$line"
      }

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique B
      set widget(B,config_liste) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_B,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_B $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_B(instrument) - $combinaison_optique_B(diametre) - $combinaison_optique_B(focale) -\
            $combinaison_optique_B(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(B,config_liste) "$line"
      }

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique C
      set widget(C,config_liste) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_C,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_C $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_C(instrument) - $combinaison_optique_C(diametre) - $combinaison_optique_C(focale) -\
            $combinaison_optique_C(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(C,config_liste) "$line"
      }

      #--- Autre valeur sauvegardee dans conf()
      set widget(confoptic,position) "$conf(confoptic,position)"
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     Copie les valeurs des widgets dans le tableau conf()
   #
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable private
      variable widget
      variable This
      global conf

      #--- Cas de la camera A
      #--- Je formate les entry pour permettre le calcul decimal
      set widget(A,diametre) [ format "%.1f" $widget(A,diametre) ]
      $widget(frm).entDiametre configure -textvariable ::confOptic::widget(A,diametre)

      set widget(A,focale) [ format "%.1f" $widget(A,focale) ]
      $widget(frm).entFocale configure -textvariable ::confOptic::widget(A,focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set widget(A,config_instrument) "$widget(A,instrument) - $widget(A,diametre) -\
         $widget(A,focale) - $widget(A,barlow_reduc)"

      #--- Mise a jour des parametres calcules
      ::confOptic::afficheResultatCalculette A $widget(frm)

      #--- Je copie les valeurs des widgets pour la camera A
      set private(A,instrument)   $widget(A,instrument)
      set private(A,diametre)     $widget(A,diametre)
      set private(A,focale)       $widget(A,focale)
      set private(A,barlow_reduc) $widget(A,barlow_reduc)

      #--- J'ajoute le systeme optique en tete dans le tableau des systemes optiques precedents s'il n'y est pas deja
      array set combinaison_optique_A { }
      set combinaison_optique_A(instrument)   "$private(A,instrument)"
      set combinaison_optique_A(diametre)     "$private(A,diametre)"
      set combinaison_optique_A(focale)       "$private(A,focale)"
      set combinaison_optique_A(barlow_reduc) "$private(A,barlow_reduc)"

      #--- Je copie conf dans templist en mettant le systeme optique courant en premier
      array set templist_A { }
      set templist_A(0) [ array get combinaison_optique_A ]
      set j "1"
      foreach {key value} [ array get conf confoptic,combinaison_optique_A,* ] {
         if { "$value" == "" } {
            set templist_A($j) ""
            incr j
         } else {
            array set temp1_A $value
            if { "$temp1_A(instrument)" != "$combinaison_optique_A(instrument)" } {
               set templist_A($j) [ array get temp1_A ]
               incr j
            }
         }
      }

      #--- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique_A,$i) $templist_A($i)
      }

      #--- je mets a jour les valeurs dans la combobox
      set config_liste ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_A,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_A $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_A(instrument) - $combinaison_optique_A(diametre) - $combinaison_optique_A(focale) -\
            $combinaison_optique_A(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend config_liste "$line"
      }
      set frm [$This.usr.onglet getframe fillConfigCameraA ]
      $frm.comboboxModele configure -values $config_liste

      #--- Cas de la camera B
      #--- Je formate les entry pour permettre le calcul decimal
      set widget(B,diametre) [ format "%.1f" $widget(B,diametre) ]
      $widget(frm).entDiametre configure -textvariable widget(B,diametre)

      set widget(B,focale) [ format "%.1f" $widget(B,focale) ]
      $widget(frm).entFocale configure -textvariable ::confOptic::widget(B,focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set widget(B,config_instrument) "$widget(B,instrument) - $widget(B,diametre) -\
         $widget(B,focale) - $widget(B,barlow_reduc)"

      #--- Mise a jour des parametres calcules
      ::confOptic::afficheResultatCalculette B $widget(frm)

      #--- Je copie les valeurs des widgets pour la camera B
      set private(B,instrument)   $widget(B,instrument)
      set private(B,diametre)     $widget(B,diametre)
      set private(B,focale)       $widget(B,focale)
      set private(B,barlow_reduc) $widget(B,barlow_reduc)

      #--- J'ajoute le systeme optique en tete dans le tableau des systemes optiques precedents s'il n'y est pas deja
      array set combinaison_optique_B { }
      set combinaison_optique_B(instrument)   "$private(B,instrument)"
      set combinaison_optique_B(diametre)     "$private(B,diametre)"
      set combinaison_optique_B(focale)       "$private(B,focale)"
      set combinaison_optique_B(barlow_reduc) "$private(B,barlow_reduc)"

      #--- Je copie conf dans templist en mettant le systeme optique courant en premier
      array set templist_B { }
      set templist_B(0) [ array get combinaison_optique_B ]
      set j "1"
      foreach {key value} [ array get conf confoptic,combinaison_optique_B,* ] {
         if { "$value" == "" } {
            set templist_B($j) ""
            incr j
         } else {
            array set temp1_B $value
            if { "$temp1_B(instrument)" != "$combinaison_optique_B(instrument)" } {
               set templist_B($j) [ array get temp1_B ]
               incr j
            }
         }
      }

      #--- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique_B,$i) $templist_B($i)
      }

      #--- je mets a jour les valeurs dans la combobox
      set config_liste ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_B,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_B $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_B(instrument) - $combinaison_optique_B(diametre) - $combinaison_optique_B(focale) -\
            $combinaison_optique_B(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend config_liste "$line"
      }
      set frm [$This.usr.onglet getframe fillConfigCameraB ]
      $frm.comboboxModele configure -values $config_liste

      #--- Cas de la camera C
      #--- Je formate les entry pour permettre le calcul decimal
      set widget(C,diametre) [ format "%.1f" $widget(C,diametre) ]
      $widget(frm).entDiametre configure -textvariable ::confOptic::widget(C,diametre)

      set widget(C,focale) [ format "%.1f" $widget(C,focale) ]
      $widget(frm).entFocale configure -textvariable ::confOptic::widget(C,focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set widget(C,config_instrument) "$widget(C,instrument) - $widget(C,diametre) -\
         $widget(C,focale) - $widget(C,barlow_reduc)"

      #--- Mise a jour des parametres calcules
      ::confOptic::afficheResultatCalculette C $widget(frm)

      #--- Je copie les valeurs des widgets pour la camera C
      set private(C,instrument)   $widget(C,instrument)
      set private(C,diametre)     $widget(C,diametre)
      set private(C,focale)       $widget(C,focale)
      set private(C,barlow_reduc) $widget(C,barlow_reduc)

      #--- J'ajoute le systeme optique en tete dans le tableau des systemes optiques precedents s'il n'y est pas deja
      array set combinaison_optique_C { }
      set combinaison_optique_C(instrument)   "$private(C,instrument)"
      set combinaison_optique_C(diametre)     "$private(C,diametre)"
      set combinaison_optique_C(focale)       "$private(C,focale)"
      set combinaison_optique_C(barlow_reduc) "$private(C,barlow_reduc)"

      #--- Je copie conf dans templist en mettant le systeme optique courant en premier
      array set templist_C { }
      set templist_C(0) [ array get combinaison_optique_C ]
      set j "1"
      foreach {key value} [ array get conf confoptic,combinaison_optique_C,* ] {
         if { "$value" == "" } {
            set templist_C($j) ""
            incr j
         } else {
            array set temp1_C $value
            if { "$temp1_C(instrument)" != "$combinaison_optique_C(instrument)" } {
               set templist_C($j) [ array get temp1_C ]
               incr j
            }
         }
      }

      #--- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique_C,$i) $templist_C($i)
      }

      #--- je mets a jour les valeurs dans la combobox
      set config_liste ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_C,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_C $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_C(instrument) - $combinaison_optique_C(diametre) - $combinaison_optique_C(focale) -\
            $combinaison_optique_C(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend config_liste "$line"
      }
      set frm [$This.usr.onglet getframe fillConfigCameraC ]
      $frm.comboboxModele configure -values $config_liste

      #--- Je mets la position actuelle de la fenetre dans conf()
      set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(confoptic,position) "+[ string range $geom $deb $fin ]"
   }

   #------------------------------------------------------------
   #  cbCommand_A
   #     (appelee par la combobox a chaque changement de selection)
   #     Affiche les valeurs dans les widgets pour la camera A
   #
   #  return rien
   #------------------------------------------------------------
   proc cbCommand_A { cb } {
      variable widget
      global conf

      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration optique de la camera A de conf()
      array set combinaison_optique_A $conf(confoptic,combinaison_optique_A,$index)

      #--- Je copie les valeurs dans les widgets pour la camera A
      set widget(A,instrument)   $combinaison_optique_A(instrument)
      set widget(A,diametre)     $combinaison_optique_A(diametre)
      set widget(A,focale)       $combinaison_optique_A(focale)
      set widget(A,barlow_reduc) $combinaison_optique_A(barlow_reduc)
   }

   #------------------------------------------------------------
   #  cbCommand_B
   #     (appelee par la combobox a chaque changement de selection)
   #     Affiche les valeurs dans les widgets pour la camera B
   #
   #  return rien
   #------------------------------------------------------------
   proc cbCommand_B { cb } {
      variable widget
      global conf

      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration optique de la camera B de conf()
      array set combinaison_optique_B $conf(confoptic,combinaison_optique_B,$index)

      #--- Je copie les valeurs dans les widgets pour la camera B
      set widget(B,instrument)   $combinaison_optique_B(instrument)
      set widget(B,diametre)     $combinaison_optique_B(diametre)
      set widget(B,focale)       $combinaison_optique_B(focale)
      set widget(B,barlow_reduc) $combinaison_optique_B(barlow_reduc)
   }

   #------------------------------------------------------------
   #  cbCommand_C
   #     (appelee par la combobox a chaque changement de selection)
   #     Affiche les valeurs dans les widgets pour la camera C
   #
   #  return rien
   #------------------------------------------------------------
   proc cbCommand_C { cb } {
      variable widget
      global conf

      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration optique de la camera C de conf()
      array set combinaison_optique_C $conf(confoptic,combinaison_optique_C,$index)

      #--- Je copie les valeurs dans les widgets pour la camera C
      set widget(C,instrument)   $combinaison_optique_C(instrument)
      set widget(C,diametre)     $combinaison_optique_C(diametre)
      set widget(C,focale)       $combinaison_optique_C(focale)
      set widget(C,barlow_reduc) $combinaison_optique_C(barlow_reduc)
   }

   #------------------------------------------------------------
   #  fillConfigCameraA
   #     Fenetre de configuration de la camera CCD A
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigCameraA { frm } {
      variable widget
      global audace caption color

      #--- Recherche du numero de la camera A connectee
      if { [::confCam::isReady "A"] != "0" } {
         set camItem "A"
         set camNo   [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo   ""
         set camItem ""
      }

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Creation des differents frames
      frame $widget(frm).frame1 -borderwidth 1 -relief raised
      pack $widget(frm).frame1 -side top -fill both -expand 1

      frame $widget(frm).frame2 -borderwidth 0 -relief raised
      pack $widget(frm).frame2 -side top -fill both -expand 1

      frame $widget(frm).frame3 -borderwidth 0 -relief raised
      pack $widget(frm).frame3 -in $widget(frm).frame2 -side left -fill both -expand 1

      frame $widget(frm).frame4 -borderwidth 1 -relief raised
      pack $widget(frm).frame4 -in $widget(frm).frame2 -side left -fill both -expand 1

      frame $widget(frm).frame5 -borderwidth 1 -relief raised
      pack $widget(frm).frame5 -in $widget(frm).frame3 -side top -fill both -expand 1

      frame $widget(frm).frame6 -borderwidth 1 -relief raised
      pack $widget(frm).frame6 -in $widget(frm).frame3 -side top -fill both -expand 1

      frame $widget(frm).frame7 -borderwidth 0 -relief raised
      pack $widget(frm).frame7 -in $widget(frm).frame1 -side left -fill both -expand 1

      frame $widget(frm).frame8 -borderwidth 0 -relief raised
      pack $widget(frm).frame8 -in $widget(frm).frame1 -side left -fill both -expand 1

      frame $widget(frm).frame9 -borderwidth 0 -relief raised
      pack $widget(frm).frame9 -in $widget(frm).frame5 -side left -fill both -expand 1

      frame $widget(frm).frame10 -borderwidth 0 -relief raised
      pack $widget(frm).frame10 -in $widget(frm).frame5 -side left -fill both -expand 1

      frame $widget(frm).frame11 -borderwidth 0 -relief raised
      pack $widget(frm).frame11 -in $widget(frm).frame6 -side left -fill both -expand 1

      frame $widget(frm).frame12 -borderwidth 0 -relief raised
      pack $widget(frm).frame12 -in $widget(frm).frame6 -side left -fill both -expand 1

      #--- Donnees caracteristiques de l'optique
      label $widget(frm).labModele -text "$caption(confoptic,modele_instrument)" -relief flat
      pack $widget(frm).labModele -in $widget(frm).frame7 -anchor w -side top -padx 10 -pady 5

      ComboBox $widget(frm).comboboxModele \
         -width 45         \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -modifycmd "::confOptic::cbCommand_A $widget(frm).comboboxModele" \
         -values $widget(A,config_liste)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable ::confOptic::widget(A,instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable ::confOptic::widget(A,diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable ::confOptic::widget(A,focale) -width 8
      pack $widget(frm).entFocale -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labBarlow_Reduc -text "$caption(confoptic,barlow_reduc)" -relief flat
      pack $widget(frm).labBarlow_Reduc -in $widget(frm).frame7 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list 0.33 0.5 0.66 1.0 1.5 2.0 2.5 3.0 3.5 4.0 5.0 ]
      ComboBox $widget(frm).comboboxBarlow_Reduc \
         -width 5          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 1       \
         -textvariable ::confOptic::widget(A,barlow_reduc) \
         -values $list_combobox
      pack $widget(frm).comboboxBarlow_Reduc -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations calculees du systeme optique
      label $widget(frm).labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $widget(frm).labFoc_Result -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Foc_Result -text "" -relief flat
      pack $widget(frm).labVal_Foc_Result -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labouverture -text "$caption(confoptic,rapport_ouverture)" -relief flat
      pack $widget(frm).labouverture -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_ouverture -text "" -relief flat
      pack $widget(frm).labVal_ouverture -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $widget(frm).labP_Separateur -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_PS -text "" -relief flat
      pack $widget(frm).labVal_PS -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $widget(A,binning) 0 0] [string range $widget(A,binning) 2 2]]
      }

      #--- Informations liees a la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         set camera(A)   "[ lindex [ cam$camNo info ] 1 ]"
         set capteur(A)  "[ lindex [ cam$camNo info ] 2 ]"
         set cell_dim(A) "[ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]"
         set pix_dim(A)  "[ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]"
         set fg          "$color(blue)"
      } else {
         set camera(A)   "$caption(confoptic,nocam)"
         set capteur(A)  ""
         set cell_dim(A) ""
         set pix_dim(A)  ""
         set fg          "$color(red)"
      }

      label $widget(frm).labCamera -text "$caption(confoptic,camera)" -relief flat
      pack $widget(frm).labCamera -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_nomCamera -font $audace(font,url) -text $camera(A) -fg $fg
      pack $widget(frm).labURL_nomCamera -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCapteurCCD -text "$caption(confoptic,capteur_ccd)" -relief flat
      pack $widget(frm).labCapteurCCD -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_typeCapteur -text $capteur(A)
      pack $widget(frm).labURL_typeCapteur -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCellDim -text "$caption(confoptic,cell_dim)" -relief flat
      pack $widget(frm).labCellDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_CellDim -text $cell_dim(A)
      pack $widget(frm).labURL_CellDim -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labBinning -text "$caption(confoptic,binning)" -relief flat
      pack $widget(frm).labBinning -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      set widget(list_combobox) [ ::confCam::getPluginProperty $camItem binningList ]
      if { $widget(list_combobox) == "{}" } {
         set widget(list_combobox) $widget(A,binning)
      }
      ComboBox $widget(frm).labURL_Binning \
         -width 5          \
         -height [ llength $widget(list_combobox) ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable ::confOptic::widget(A,binning) \
         -modifycmd "::confOptic::Impact_Binning A $widget(frm)" \
         -values $widget(list_combobox)
      pack $widget(frm).labURL_Binning -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labPixDim -text "$caption(confoptic,pix_dim)" -relief flat
      pack $widget(frm).labPixDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_PixDim -text $pix_dim(A)
      pack $widget(frm).labURL_PixDim -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labChamp -text "$caption(confoptic,champ)" -relief flat
      pack $widget(frm).labChamp -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Champ -text "" -relief flat
      pack $widget(frm).labVal_Champ -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labEchant -text "$caption(confoptic,echantillonnage)" -relief flat
      pack $widget(frm).labEchant -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Echantillonnage -text "" -relief flat
      pack $widget(frm).labVal_Echantillonnage -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      #--- Je selectionne le premier element de la combobox de configuration du systeme optique
      $widget(frm).comboboxModele setvalue first
      ::confOptic::cbCommand_A $widget(frm).comboboxModele

      #--- Definition du bouton Calcul
      button $widget(frm).but_Calcul -text "$caption(confoptic,calcul)" -relief raised -width 15 \
         -command "::confOptic::afficheResultatCalculette A $widget(frm)"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::afficheResultatCalculette A $widget(frm)

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> "set ::confCam::private(currentCamItem) A ; ::confCam::run ; ::confCam::selectNotebook A"
   }

   #------------------------------------------------------------
   #  fillConfigCameraB
   #     Fenetre de configuration de la camera CCD B
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigCameraB { frm } {
      variable widget
      global audace caption color

      #--- Recherche du numero de la camera B connectee
      if { [::confCam::isReady "B"] != "0" } {
         set camItem "B"
         set camNo   [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo   ""
         set camItem ""
      }

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Creation des differents frames
      frame $widget(frm).frame1 -borderwidth 1 -relief raised
      pack $widget(frm).frame1 -side top -fill both -expand 1

      frame $widget(frm).frame2 -borderwidth 0 -relief raised
      pack $widget(frm).frame2 -side top -fill both -expand 1

      frame $widget(frm).frame3 -borderwidth 0 -relief raised
      pack $widget(frm).frame3 -in $widget(frm).frame2 -side left -fill both -expand 1

      frame $widget(frm).frame4 -borderwidth 1 -relief raised
      pack $widget(frm).frame4 -in $widget(frm).frame2 -side left -fill both -expand 1

      frame $widget(frm).frame5 -borderwidth 1 -relief raised
      pack $widget(frm).frame5 -in $widget(frm).frame3 -side top -fill both -expand 1

      frame $widget(frm).frame6 -borderwidth 1 -relief raised
      pack $widget(frm).frame6 -in $widget(frm).frame3 -side top -fill both -expand 1

      frame $widget(frm).frame7 -borderwidth 0 -relief raised
      pack $widget(frm).frame7 -in $widget(frm).frame1 -side left -fill both -expand 1

      frame $widget(frm).frame8 -borderwidth 0 -relief raised
      pack $widget(frm).frame8 -in $widget(frm).frame1 -side left -fill both -expand 1

      frame $widget(frm).frame9 -borderwidth 0 -relief raised
      pack $widget(frm).frame9 -in $widget(frm).frame5 -side left -fill both -expand 1

      frame $widget(frm).frame10 -borderwidth 0 -relief raised
      pack $widget(frm).frame10 -in $widget(frm).frame5 -side left -fill both -expand 1

      frame $widget(frm).frame11 -borderwidth 0 -relief raised
      pack $widget(frm).frame11 -in $widget(frm).frame6 -side left -fill both -expand 1

      frame $widget(frm).frame12 -borderwidth 0 -relief raised
      pack $widget(frm).frame12 -in $widget(frm).frame6 -side left -fill both -expand 1

      #--- Donnees caracteristiques de l'optique
      label $widget(frm).labModele -text "$caption(confoptic,modele_instrument)" -relief flat
      pack $widget(frm).labModele -in $widget(frm).frame7 -anchor w -side top -padx 10 -pady 5

      ComboBox $widget(frm).comboboxModele \
         -width 45         \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -modifycmd "::confOptic::cbCommand_B $widget(frm).comboboxModele" \
         -values $widget(B,config_liste)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable ::confOptic::widget(B,instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable ::confOptic::widget(B,diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable ::confOptic::widget(B,focale) -width 8
      pack $widget(frm).entFocale -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labBarlow_Reduc -text "$caption(confoptic,barlow_reduc)" -relief flat
      pack $widget(frm).labBarlow_Reduc -in $widget(frm).frame7 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list 0.33 0.5 0.66 1.0 1.5 2.0 2.5 3.0 3.5 4.0 5.0 ]
      ComboBox $widget(frm).comboboxBarlow_Reduc \
         -width 5          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 1       \
         -textvariable ::confOptic::widget(B,barlow_reduc) \
         -values $list_combobox
      pack $widget(frm).comboboxBarlow_Reduc -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations calculees du systeme optique
      label $widget(frm).labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $widget(frm).labFoc_Result -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Foc_Result -text "" -relief flat
      pack $widget(frm).labVal_Foc_Result -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labouverture -text "$caption(confoptic,rapport_ouverture)" -relief flat
      pack $widget(frm).labouverture -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_ouverture -text "" -relief flat
      pack $widget(frm).labVal_ouverture -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $widget(frm).labP_Separateur -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_PS -text "" -relief flat
      pack $widget(frm).labVal_PS -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $widget(B,binning) 0 0] [string range $widget(B,binning) 2 2]]
      }

      #--- Informations liees a la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         set camera(B)   "[ lindex [ cam$camNo info ] 1 ]"
         set capteur(B)  "[ lindex [ cam$camNo info ] 2 ]"
         set cell_dim(B) "[ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]"
         set pix_dim(B)  "[ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]"
         set fg          "$color(blue)"
      } else {
         set camera(B)   "$caption(confoptic,nocam)"
         set capteur(B)  ""
         set cell_dim(B) ""
         set pix_dim(B)  ""
         set fg          "$color(red)"
      }

      label $widget(frm).labCamera -text "$caption(confoptic,camera)" -relief flat
      pack $widget(frm).labCamera -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_nomCamera -font $audace(font,url) -text $camera(B) -fg $fg
      pack $widget(frm).labURL_nomCamera -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCapteurCCD -text "$caption(confoptic,capteur_ccd)" -relief flat
      pack $widget(frm).labCapteurCCD -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_typeCapteur -text $capteur(B)
      pack $widget(frm).labURL_typeCapteur -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCellDim -text "$caption(confoptic,cell_dim)" -relief flat
      pack $widget(frm).labCellDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_CellDim -text $cell_dim(B)
      pack $widget(frm).labURL_CellDim -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labBinning -text "$caption(confoptic,binning)" -relief flat
      pack $widget(frm).labBinning -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      set widget(list_combobox) [ ::confCam::getPluginProperty $camItem binningList ]
      if { $widget(list_combobox) == "{}" } {
         set widget(list_combobox) $widget(B,binning)
      }
      ComboBox $widget(frm).labURL_Binning \
         -width 5          \
         -height [ llength $widget(list_combobox) ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable ::confOptic::widget(B,binning) \
         -modifycmd "::confOptic::Impact_Binning B $widget(frm)" \
         -values $widget(list_combobox)
      pack $widget(frm).labURL_Binning -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labPixDim -text "$caption(confoptic,pix_dim)" -relief flat
      pack $widget(frm).labPixDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_PixDim -text $pix_dim(B)
      pack $widget(frm).labURL_PixDim -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labChamp -text "$caption(confoptic,champ)" -relief flat
      pack $widget(frm).labChamp -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Champ -text "" -relief flat
      pack $widget(frm).labVal_Champ -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labEchant -text "$caption(confoptic,echantillonnage)" -relief flat
      pack $widget(frm).labEchant -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Echantillonnage -text "" -relief flat
      pack $widget(frm).labVal_Echantillonnage -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      #--- Je selectionne le premier element de la combobox de configuration du systeme optique
      $widget(frm).comboboxModele setvalue first
      ::confOptic::cbCommand_B $widget(frm).comboboxModele

      #--- Definition du bouton Calcul
      button $widget(frm).but_Calcul -text "$caption(confoptic,calcul)" -relief raised -width 15 \
         -command "::confOptic::afficheResultatCalculette B $widget(frm)"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::afficheResultatCalculette B $widget(frm)

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> "set ::confCam::private(currentCamItem) B ; ::confCam::run ; ::confCam::selectNotebook B"
   }

   #------------------------------------------------------------
   #  fillConfigCameraC
   #     Fenetre de configuration de la camera CCD C
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigCameraC { frm } {
      variable widget
      global audace caption color

      #--- Recherche du numero de la camera C connectee
      if { [::confCam::isReady "C"] != "0" } {
         set camItem "C"
         set camNo   [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo   ""
         set camItem ""
      }

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Creation des differents frames
      frame $widget(frm).frame1 -borderwidth 1 -relief raised
      pack $widget(frm).frame1 -side top -fill both -expand 1

      frame $widget(frm).frame2 -borderwidth 0 -relief raised
      pack $widget(frm).frame2 -side top -fill both -expand 1

      frame $widget(frm).frame3 -borderwidth 0 -relief raised
      pack $widget(frm).frame3 -in $widget(frm).frame2 -side left -fill both -expand 1

      frame $widget(frm).frame4 -borderwidth 1 -relief raised
      pack $widget(frm).frame4 -in $widget(frm).frame2 -side left -fill both -expand 1

      frame $widget(frm).frame5 -borderwidth 1 -relief raised
      pack $widget(frm).frame5 -in $widget(frm).frame3 -side top -fill both -expand 1

      frame $widget(frm).frame6 -borderwidth 1 -relief raised
      pack $widget(frm).frame6 -in $widget(frm).frame3 -side top -fill both -expand 1

      frame $widget(frm).frame7 -borderwidth 0 -relief raised
      pack $widget(frm).frame7 -in $widget(frm).frame1 -side left -fill both -expand 1

      frame $widget(frm).frame8 -borderwidth 0 -relief raised
      pack $widget(frm).frame8 -in $widget(frm).frame1 -side left -fill both -expand 1

      frame $widget(frm).frame9 -borderwidth 0 -relief raised
      pack $widget(frm).frame9 -in $widget(frm).frame5 -side left -fill both -expand 1

      frame $widget(frm).frame10 -borderwidth 0 -relief raised
      pack $widget(frm).frame10 -in $widget(frm).frame5 -side left -fill both -expand 1

      frame $widget(frm).frame11 -borderwidth 0 -relief raised
      pack $widget(frm).frame11 -in $widget(frm).frame6 -side left -fill both -expand 1

      frame $widget(frm).frame12 -borderwidth 0 -relief raised
      pack $widget(frm).frame12 -in $widget(frm).frame6 -side left -fill both -expand 1

      #--- Donnees caracteristiques de l'optique
      label $widget(frm).labModele -text "$caption(confoptic,modele_instrument)" -relief flat
      pack $widget(frm).labModele -in $widget(frm).frame7 -anchor w -side top -padx 10 -pady 5

      ComboBox $widget(frm).comboboxModele \
         -width 45         \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -modifycmd "::confOptic::cbCommand_C $widget(frm).comboboxModele" \
         -values $widget(C,config_liste)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable ::confOptic::widget(C,instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable ::confOptic::widget(C,diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable ::confOptic::widget(C,focale) -width 8
      pack $widget(frm).entFocale -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labBarlow_Reduc -text "$caption(confoptic,barlow_reduc)" -relief flat
      pack $widget(frm).labBarlow_Reduc -in $widget(frm).frame7 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list 0.33 0.5 0.66 1.0 1.5 2.0 2.5 3.0 3.5 4.0 5.0 ]
      ComboBox $widget(frm).comboboxBarlow_Reduc \
         -width 5          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 1       \
         -textvariable ::confOptic::widget(C,barlow_reduc) \
         -values $list_combobox
      pack $widget(frm).comboboxBarlow_Reduc -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations calculees du systeme optique
      label $widget(frm).labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $widget(frm).labFoc_Result -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Foc_Result -text "" -relief flat
      pack $widget(frm).labVal_Foc_Result -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labouverture -text "$caption(confoptic,rapport_ouverture)" -relief flat
      pack $widget(frm).labouverture -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_ouverture -text "" -relief flat
      pack $widget(frm).labVal_ouverture -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $widget(frm).labP_Separateur -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_PS -text "" -relief flat
      pack $widget(frm).labVal_PS -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $widget(C,binning) 0 0] [string range $widget(C,binning) 2 2]]
      }

      #--- Informations liees a la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         set camera(C)   "[ lindex [ cam$camNo info ] 1 ]"
         set capteur(C)  "[ lindex [ cam$camNo info ] 2 ]"
         set cell_dim(C) "[ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]"
         set pix_dim(C)  "[ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]"
         set fg          "$color(blue)"
      } else {
         set camera(C)   "$caption(confoptic,nocam)"
         set capteur(C)  ""
         set cell_dim(C) ""
         set pix_dim(C)  ""
         set fg          "$color(red)"
      }

      label $widget(frm).labCamera -text "$caption(confoptic,camera)" -relief flat
      pack $widget(frm).labCamera -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_nomCamera -font $audace(font,url) -text $camera(C) -fg $fg
      pack $widget(frm).labURL_nomCamera -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCapteurCCD -text "$caption(confoptic,capteur_ccd)" -relief flat
      pack $widget(frm).labCapteurCCD -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_typeCapteur -text $capteur(C)
      pack $widget(frm).labURL_typeCapteur -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCellDim -text "$caption(confoptic,cell_dim)" -relief flat
      pack $widget(frm).labCellDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_CellDim -text $cell_dim(C)
      pack $widget(frm).labURL_CellDim -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labBinning -text "$caption(confoptic,binning)" -relief flat
      pack $widget(frm).labBinning -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      set widget(list_combobox) [ ::confCam::getPluginProperty $camItem binningList ]
      if { $widget(list_combobox) == "{}" } {
         set widget(list_combobox) $widget(C,binning)
      }
      ComboBox $widget(frm).labURL_Binning \
         -width 5          \
         -height [ llength $widget(list_combobox) ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable ::confOptic::widget(C,binning) \
         -modifycmd "::confOptic::Impact_Binning C $widget(frm)" \
         -values $widget(list_combobox)
      pack $widget(frm).labURL_Binning -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labPixDim -text "$caption(confoptic,pix_dim)" -relief flat
      pack $widget(frm).labPixDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_PixDim -text $pix_dim(C)
      pack $widget(frm).labURL_PixDim -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labChamp -text "$caption(confoptic,champ)" -relief flat
      pack $widget(frm).labChamp -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Champ -text "" -relief flat
      pack $widget(frm).labVal_Champ -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labEchant -text "$caption(confoptic,echantillonnage)" -relief flat
      pack $widget(frm).labEchant -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Echantillonnage -text "" -relief flat
      pack $widget(frm).labVal_Echantillonnage -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      #--- Je selectionne le premier element de la combobox de configuration du systeme optique
      $widget(frm).comboboxModele setvalue first
      ::confOptic::cbCommand_C $widget(frm).comboboxModele

      #--- Definition du bouton Calcul
      button $widget(frm).but_Calcul -text "$caption(confoptic,calcul)" -relief raised -width 15 \
         -command "::confOptic::afficheResultatCalculette C $widget(frm)"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::afficheResultatCalculette C $widget(frm)

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> "set ::confCam::private(currentCamItem) C ; ::confCam::run ; ::confCam::selectNotebook C"
   }

   #==============================================================
   # Fonctions specifiques
   #==============================================================

   #------------------------------------------------------------
   #  MAJ_Binning
   #     Affichage des binnings disponibles selon les cameras
   #     args : Valeurs fournies par le gestionnaire de listener
   #
   #------------------------------------------------------------
   proc MAJ_Binning { camItem frm args } {
      variable widget

      #--- Teste l'existence de la fenetre
      if { [ winfo exists $frm ] == 0 } {
         return
      }
      #--- Recherche du binning associe a la camera selectionnee
      if { $camItem != "0" } {
         set camNo [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo ""
      }
      #--- Mise a jour des parametres dependant du binning
      if { $camNo != "" && $camNo != "0" } {
         #--- Mise a jour de la combobox du binning
         set widget(list_combobox) [ ::confCam::getPluginProperty $camItem binningList ]
         $frm.labURL_Binning configure -height [ llength $widget(list_combobox) ]
         $frm.labURL_Binning configure -values $widget(list_combobox)
      } else {
         #--- Mise a jour de la combobox du binning
         set widget($camItem,binning) "1x1"
         set widget(list_combobox) "$widget($camItem,binning)"
         $frm.labURL_Binning configure -height [ llength $widget(list_combobox) ]
         $frm.labURL_Binning configure -values $widget(list_combobox)
         $frm.labURL_Binning configure -textvariable ::confOptic::widget($camItem,binning)
         #--- Mise a jour du champ et de l'echantilonnage
         $frm.labVal_Champ configure -text ""
         $frm.labVal_Echantillonnage configure -text ""
      }
      #--- Mise a jour des parametres de la camera CCD
      ::confOptic::MAJ_Conf_Camera $camItem $frm
   }

   #------------------------------------------------------------
   #  Impact_Binning
   #     Prise en compte du binning choisi
   #
   #------------------------------------------------------------
   proc Impact_Binning { camItem frm } {
      variable widget
      global audace

      #--- Recherche du numero de la camera CCD
      if { $camItem != "0" } {
         set camNo [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo ""
      }
      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $widget($camItem,binning) 0 0] [string range $widget($camItem,binning) 2 2]]
      }
      #--- Mise a jour des informations concernant la camera
      if { $camNo != "" && $camNo != "0" } {
         set pix_dim($camItem) "[ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]"
      } else {
         set pix_dim($camItem) ""
      }
      if { [ winfo exists $audace(base).confOptic ] } {
         $frm.labURL_PixDim configure -text $pix_dim($camItem)
      }
      #--- Calcul et affichage des parametres du systeme optique
      ::confOptic::afficheResultatCalculette $camItem $frm
   }

   #------------------------------------------------------------
   #  Calculette
   #     Calcule les differents parametres du systeme optique
   #
   #------------------------------------------------------------
   proc Calculette { camItem focale barlow_reduc diametre } {
      variable private
      global conf

      set combinaison(focale)       $focale
      set combinaison(barlow_reduc) $barlow_reduc
      set combinaison(diametre)     $diametre

      #--- Calcul de la focale resultante du systeme optique
      set private($camItem,focale_resultante) [ expr $combinaison(focale) * $combinaison(barlow_reduc) ]

      #--- Calcul du rapport ouverture du systeme optique
      set private($camItem,ouverture) [ format "%.1f" \
         [ expr $private($camItem,focale_resultante) / $combinaison(diametre) ] ]

      #--- Calcul du pouvoir separateur du systeme optique
      set private($camItem,PS) [ format "%.2f" [ expr 0.120 / $combinaison(diametre) ] ]

      #--- Recherche du numero de la camera CCD
      if { $camItem != "0" } {
         set camNo [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo ""
      }

      #--- Calculs du champ et de l'echantillonnage de la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         #--- Nombres de pixels en x et en y
         set nb_xy($camItem) [ cam$camNo nbpix ]
         #--- Dimensions des pixels en x et en y
         set pix_dim_xy($camItem) [ cam$camNo pixdim ]
         #--- Dimensions du CCD en x et en y
         set dim_x($camItem) [ expr [ lindex $nb_xy($camItem) 0 ] * [ lindex $pix_dim_xy($camItem) 0 ] * 1000. ]
         set dim_y($camItem) [ expr [ lindex $nb_xy($camItem) 1 ] * [ lindex $pix_dim_xy($camItem) 1 ] * 1000. ]
         #--- Champ en x et en y en minutes d'arc
         set private($camItem,champ_x) [ format "%.1f" [ expr 206265 * $dim_x($camItem) / ( $private($camItem,focale_resultante) * 1000. * 60. ) ] ]
         set private($camItem,champ_y) [ format "%.1f" [ expr 206265 * $dim_y($camItem) / ( $private($camItem,focale_resultante) * 1000. * 60. ) ] ]
         #--- Echantillonnage du CCD en x et en y en secondes d'arc par pixels
         set private($camItem,echantillonnage_x) [ format "%.1f"  [ expr $private($camItem,champ_x) * 60. / [ lindex $nb_xy($camItem) 0 ] ] ]
         set private($camItem,echantillonnage_y) [ format "%.1f"  [ expr $private($camItem,champ_y) * 60. / [ lindex $nb_xy($camItem) 1 ] ] ]
      } else {
         set private($camItem,champ_x) ""
         set private($camItem,champ_y) ""
         set private($camItem,echantillonnage_x) ""
         set private($camItem,echantillonnage_y) ""
      }
   }

   #------------------------------------------------------------
   #  afficheResultatCalculette
   #     Calcule les differents parametres du systeme optique
   #
   #------------------------------------------------------------
   proc afficheResultatCalculette { camItem frm } {
      variable private
      variable widget

      #--- Je formate les entry pour permettre le calcul decimal
      set widget($camItem,diametre) [ format "%.3f" $widget($camItem,diametre) ]
      $frm.entDiametre configure -textvariable ::confOptic::widget($camItem,diametre)

      set widget($camItem,focale) [ format "%.3f" $widget($camItem,focale) ]
      $frm.entFocale configure -textvariable ::confOptic::widget($camItem,focale)

      #--- Je mets a jour la combobox du systeme optique
      set widget($camItem,config_instrument) "$widget($camItem,instrument) -\
         $widget($camItem,diametre) - $widget($camItem,focale) -\
         $widget($camItem,barlow_reduc)"
      $frm.comboboxModele configure -textvariable ::confOptic::widget($camItem,config_instrument)

      #--- Je calcule les valeurs
      ::confOptic::Calculette $camItem $widget($camItem,focale) $widget($camItem,barlow_reduc) $widget($camItem,diametre)

      #--- Affichage du calcul de la focale resultante du systeme optique
      $frm.labVal_Foc_Result configure -text $private($camItem,focale_resultante)

      #--- Affichage du calcul du rapport ouverture du systeme optique
      $frm.labVal_ouverture configure -text $private($camItem,ouverture)

      #--- Affichage du calcul du pouvoir separateur du systeme optique
      $frm.labVal_PS configure -text $private($camItem,PS)

      #--- Affichage du calcul du champ du CCD en x et en y en minutes d'arc
      $frm.labVal_Champ configure -text "$private($camItem,champ_x) x $private($camItem,champ_y)"

      #--- Affichage du calcul de l'echantillonnage du CCD en x et en y en secondes d'arc par pixels
      $frm.labVal_Echantillonnage configure -text "$private($camItem,echantillonnage_x) x $private($camItem,echantillonnage_y)"
   }

   #------------------------------------------------------------
   #  MAJ_Conf_Camera
   #     Mise a jour des parametres de la camera CCD
   #
   #------------------------------------------------------------
   proc MAJ_Conf_Camera { camItem frm } {
      variable widget
      global audace caption color

      #--- Recherche du numero de la camera CCD
      if { $camItem != "" } {
         set camNo [ ::confCam::getCamNo $camItem ]
      } else {
         set camNo ""
      }
      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $widget($camItem,binning) 0 0] [string range $widget($camItem,binning) 2 2]]
      }
      #--- Je mets a jour les parametres de la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         set camera($camItem)   "[ lindex [ cam$camNo info ] 1 ]"
         set capteur($camItem)  "[ lindex [ cam$camNo info ] 2 ]"
         set cell_dim($camItem) "[ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]"
         set pix_dim($camItem)  "[ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]"
         set fg                 "$color(blue)"
      } else {
         set camera($camItem)   "$caption(confoptic,nocam)"
         set capteur($camItem)  ""
         set cell_dim($camItem) ""
         set pix_dim($camItem)  ""
         set fg                 "$color(red)"
         $frm.labVal_Champ configure -text ""
         $frm.labVal_Echantillonnage configure -text ""
      }
      #--- Affichage des parametres de la camera CCD
      if { [ winfo exists $audace(base).confOptic ] } {
         $frm.labURL_nomCamera configure -text $camera($camItem) -fg $fg
         $frm.labURL_typeCapteur configure -text $capteur($camItem)
         $frm.labURL_CellDim configure -text $cell_dim($camItem)
         $frm.labURL_PixDim configure -text $pix_dim($camItem)
         ::confOptic::afficheResultatCalculette $camItem $frm
      }
   }

   #------------------------------------------------------------
   #  addOpticListener
   #     ajoute une procedure a appeler si on change un parametre
   #
   #  parametres :
   #     cmd : commande TCL a lancer quand la configuration optique change
   #------------------------------------------------------------
   proc addOpticListener { cmd } {
      trace add variable "::conf(confoptic,combinaison_optique_C,0)" write $cmd
   }

   #------------------------------------------------------------
   #  removeOpticListener
   #     supprime une procedure a appeler si on change un parametre
   #
   #  parametres :
   #     cmd : commande TCL a lancer quand la configuration optique change
   #------------------------------------------------------------
   proc removeOpticListener { cmd } {
      trace remove variable "::conf(confoptic,combinaison_optique_C,0)" write $cmd
   }

   #------------------------------------------------------------
   #  getConfOptic
   #     retourne la configuration optique
   #
   #  parametres :
   #     camItem : item de la camera
   #  return :
   #     retourne la liste {instrument diametre focale}
   #------------------------------------------------------------
   proc getConfOptic { camItem } {
      variable private

      #--- Je recupere la premiere combinaison selectionnee
      array set combinaison $::conf(confoptic,combinaison_optique_$camItem,0)

      #--- Je calcule la focale resultante
      ::confOptic::Calculette $camItem $combinaison(focale) $combinaison(barlow_reduc) $combinaison(diametre)

      return [list $combinaison(instrument) $combinaison(diametre) $private($camItem,focale_resultante)]
   }

}

::confOptic::init

