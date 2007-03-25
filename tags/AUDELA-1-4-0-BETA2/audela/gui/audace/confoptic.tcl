#
# Fichier : confoptic.tcl
# Description : Affiche la fenetre de configuration des systemes optiques associes aux cameras A, B et C
# Auteur : Robert DELMAS
# Mise a jour $Id: confoptic.tcl,v 1.15 2007-03-17 09:24:37 robertdelmas Exp $
#

namespace eval ::confOptic {

   #------------------------------------------------------------
   #  init { }
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
   #  run { }
   #     Cree la fenetre de choix et de configuration des
   #     systemes optiques associes aux cameras A, B et C
   #
   #------------------------------------------------------------
   proc run { visuNo } {
      variable This
      global audace conf confCam

      set This "$audace(base).confOptic"
      createDialog $visuNo
      if { $conf(camera,$confCam(currentCamItem),camName) != "" } {
         select $conf(camera,$confCam(currentCamItem),camName)
      } else {
         select A
      }
      catch { tkwait visibility $This }
   }

   #------------------------------------------------------------
   #  initConf { }
   #     Initialise les parametres de chaque systeme optique
   #     dans le tableau conf()
   #
   #------------------------------------------------------------
   proc initConf { } {
      variable widget
      global caption conf

      #--- Position de la fenetre
      if { ! [ info exists conf(confoptic,position) ] } { set conf(confoptic,position) "+150+75" }

      #--- Instrumentation associee a la camera A
      if { ! [ info exists conf(confoptic,combinaison_optique_A,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique_A(diametre)         "203.0"
         set combinaison_optique_A(focale)           "2000.0"
         set combinaison_optique_A(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique_A,0) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique_A(diametre)         "203.0"
         set combinaison_optique_A(focale)           "2000.0"
         set combinaison_optique_A(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique_A,1) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique_A(diametre)         "203.0"
         set combinaison_optique_A(focale)           "2000.0"
         set combinaison_optique_A(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique_A,2) [ array get combinaison_optique_A ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_A,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_A { }
         set combinaison_optique_A(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique_A(diametre)         "203.0"
         set combinaison_optique_A(focale)           "2000.0"
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
         set combinaison_optique_B(diametre)         "203.0"
         set combinaison_optique_B(focale)           "2000.0"
         set combinaison_optique_B(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique_B,0) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique_B(diametre)         "203.0"
         set combinaison_optique_B(focale)           "2000.0"
         set combinaison_optique_B(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique_B,1) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique_B(diametre)         "203.0"
         set combinaison_optique_B(focale)           "2000.0"
         set combinaison_optique_B(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique_B,2) [ array get combinaison_optique_B ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_B,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_B { }
         set combinaison_optique_B(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique_B(diametre)         "203.0"
         set combinaison_optique_B(focale)           "2000.0"
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
      if { ! [ info exists conf(confoptic,combinaison_optique_D,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_D { }
         set combinaison_optique_D(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique_D(diametre)         "203.0"
         set combinaison_optique_D(focale)           "2000.0"
         set combinaison_optique_D(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique_D,0) [ array get combinaison_optique_D ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_D,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_D { }
         set combinaison_optique_D(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique_D(diametre)         "203.0"
         set combinaison_optique_D(focale)           "2000.0"
         set combinaison_optique_D(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique_D,1) [ array get combinaison_optique_D ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_D,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_D { }
         set combinaison_optique_D(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique_D(diametre)         "203.0"
         set combinaison_optique_D(focale)           "2000.0"
         set combinaison_optique_D(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique_D,2) [ array get combinaison_optique_D ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_D,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique_D { }
         set combinaison_optique_D(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique_D(diametre)         "203.0"
         set combinaison_optique_D(focale)           "2000.0"
         set combinaison_optique_D(barlow_reduc)     "2.5"

         set conf(confoptic,combinaison_optique_D,3) [ array get combinaison_optique_D ]
      }
      #---
      if { ! [ info exists conf(confoptic,combinaison_optique_D,4) ] } { set conf(confoptic,combinaison_optique_D,4) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_D,5) ] } { set conf(confoptic,combinaison_optique_D,5) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_D,6) ] } { set conf(confoptic,combinaison_optique_D,6) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_D,7) ] } { set conf(confoptic,combinaison_optique_D,7) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_D,8) ] } { set conf(confoptic,combinaison_optique_D,8) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique_D,9) ] } { set conf(confoptic,combinaison_optique_D,9) "" }

      #--- J'initialise les combobox du binning
      set widget(A,binning) "1x1"
      set widget(B,binning) "1x1"
      set widget(C,binning) "1x1"
   }

   #------------------------------------------------------------
   #  ok { }
   #     Fonction appellee lors de l'appui sur le bouton 'OK'
   #     pour appliquer la configuration et fermer la fenetre
   #     de reglage des systemes optiques
   #
   #------------------------------------------------------------
   proc ok { visuNo } {
      variable This

      $This.cmd.ok configure -relief groove -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      appliquer
      fermer $visuNo
   }

   #------------------------------------------------------------
   #  appliquer { }
   #     Fonction appellee lors de l'appui sur le bouton
   #     'Appliquer' pour memoriser et appliquer la
   #     configuration
   #
   #------------------------------------------------------------
   proc appliquer { } {
      variable This

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -relief groove -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      widgetToConf
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -relief raised -state normal
      $This.cmd.aide configure -state normal
      $This.cmd.fermer configure -state normal
   }

   #------------------------------------------------------------
   #  showHelp { }
   #     Aide
   #
   #------------------------------------------------------------
   proc afficherAide { } {
      variable This
      global help

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -relief groove -state disabled
      $This.cmd.fermer configure -state disabled
      ::audace::showHelpItem "$help(dir,optic)" "1010config_optique.htm"
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -state normal
      $This.cmd.aide configure -relief raised -state normal
      $This.cmd.fermer configure -state normal
   }

   #------------------------------------------------------------
   #  fermer { }
   #     Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   #------------------------------------------------------------
   proc fermer { visuNo } {
      variable This

      #--- Supprime la procedure de surveillance de la connexion d'une camera
      trace remove variable ::confCam(A,super_camNo) write "::confOptic::MAJ_Binning A [ Rnotebook:frame $This.usr.book 1 ]"
      trace remove variable ::confCam(B,super_camNo) write "::confOptic::MAJ_Binning B [ Rnotebook:frame $This.usr.book 2 ]"
      trace remove variable ::confCam(C,super_camNo) write "::confOptic::MAJ_Binning C [ Rnotebook:frame $This.usr.book 3 ]"
      #---
      recup_position
      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -relief groove -state disabled
      destroy $This
   }

   #------------------------------------------------------------
   #  recup_position { }
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
   #  createDialog { }
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
      wm geometry $This 540x530$widget(confoptic,position)
      wm minsize $This 540 530
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(confoptic,config_optique)"
      wm protocol $This WM_DELETE_WINDOW "::confOptic::fermer $visuNo"

      #--- Definition des frames recevant les onglets
      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set nn $This.usr.book
         Rnotebook:create $nn -tabs [ list $caption(confoptic,camera_A) $caption(confoptic,camera_B) \
            $caption(confoptic,camera_C) ] -borderwidth 1
         fillConfigPage1 $nn
         fillConfigPage2 $nn
         fillConfigPage3 $nn
         pack $nn -fill both -expand 1
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
      trace add variable ::confCam(A,super_camNo) write "::confOptic::MAJ_Binning A [ Rnotebook:frame $This.usr.book 1 ]"
      trace add variable ::confCam(B,super_camNo) write "::confOptic::MAJ_Binning B [ Rnotebook:frame $This.usr.book 2 ]"
      trace add variable ::confCam(C,super_camNo) write "::confOptic::MAJ_Binning C [ Rnotebook:frame $This.usr.book 3 ]"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  select [ camItem ]
   #     Selectionne un onglet en passant le nom de la
   #     camera (A, B ou C)
   #
   #------------------------------------------------------------
   proc select { { camItem A } } {
      variable This

      set nn $This.usr.book
      switch -exact -- $camItem {
         A { Rnotebook:raise $nn 1 }
         B { Rnotebook:raise $nn 2 }
         C { Rnotebook:raise $nn 3 }
      }
   }

   #------------------------------------------------------------
   #  confToWidget { }
   #     Copie les parametres du tableau conf() dans les
   #     variables des widgets
   #
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique A
      set widget(A,config_instrument) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_A,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_A $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_A(instrument) - $combinaison_optique_A(diametre) - $combinaison_optique_A(focale) -\
            $combinaison_optique_A(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(A,config_instrument) "$line"
      }

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique B
      set widget(B,config_instrument) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_B,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_B $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_B(instrument) - $combinaison_optique_B(diametre) - $combinaison_optique_B(focale) -\
            $combinaison_optique_B(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(B,config_instrument) "$line"
      }

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique C
      set widget(C,config_instrument) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique_D,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique_D $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique_D(instrument) - $combinaison_optique_D(diametre) - $combinaison_optique_D(focale) -\
            $combinaison_optique_D(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(C,config_instrument) "$line"
      }

      #--- Autre valeur sauvegardee dans conf()
      set widget(confoptic,position) "$conf(confoptic,position)"
   }

   #------------------------------------------------------------
   #  widgetToConf { }
   #     Copie les valeurs des widgets dans le tableau conf()
   #
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable private
      variable widget
      global conf

      #--- Cas de la camera A
      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(A,diametre) [ format "%.1f" $confOptic::widget(A,diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(A,diametre)

      set confOptic::widget(A,focale) [ format "%.1f" $confOptic::widget(A,focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(A,focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set confOptic::widget(A,config_instrument) "$confOptic::widget(A,instrument) - $confOptic::widget(A,diametre) -\
         $confOptic::widget(A,focale) - $confOptic::widget(A,barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(A,config_instrument)

      #--- Mise a jour des parametres calcules
      ::confOptic::Calculette A $widget(frm)

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

      #-- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique_A,$i) $templist_A($i)
      }

      #--- Cas de la camera B
      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(B,diametre) [ format "%.1f" $confOptic::widget(B,diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(B,diametre)

      set confOptic::widget(B,focale) [ format "%.1f" $confOptic::widget(B,focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(B,focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set confOptic::widget(B,config_instrument) "$confOptic::widget(B,instrument) - $confOptic::widget(B,diametre) -\
         $confOptic::widget(B,focale) - $confOptic::widget(B,barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(B,config_instrument)

      #--- Mise a jour des parametres calcules
      ::confOptic::Calculette B $widget(frm)

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

      #-- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique_B,$i) $templist_B($i)
      }

      #--- Cas de la camera C
      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(C,diametre) [ format "%.1f" $confOptic::widget(C,diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(C,diametre)

      set confOptic::widget(C,focale) [ format "%.1f" $confOptic::widget(C,focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(C,focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set confOptic::widget(C,config_instrument) "$confOptic::widget(C,instrument) - $confOptic::widget(C,diametre) -\
         $confOptic::widget(C,focale) - $confOptic::widget(C,barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(C,config_instrument)

      #--- Mise a jour des parametres calcules
      ::confOptic::Calculette C $widget(frm)

      #--- Je copie les valeurs des widgets pour la camera C
      set private(C,instrument)   $widget(C,instrument)
      set private(C,diametre)     $widget(C,diametre)
      set private(C,focale)       $widget(C,focale)
      set private(C,barlow_reduc) $widget(C,barlow_reduc)

      #--- J'ajoute le systeme optique en tete dans le tableau des systemes optiques precedents s'il n'y est pas deja
      array set combinaison_optique_D { }
      set combinaison_optique_D(instrument)   "$private(C,instrument)"
      set combinaison_optique_D(diametre)     "$private(C,diametre)"
      set combinaison_optique_D(focale)       "$private(C,focale)"
      set combinaison_optique_D(barlow_reduc) "$private(C,barlow_reduc)"

      #--- Je copie conf dans templist en mettant le systeme optique courant en premier
      array set templist_C { }
      set templist_C(0) [ array get combinaison_optique_D ]
      set j "1"
      foreach {key value} [ array get conf confoptic,combinaison_optique_D,* ] {
         if { "$value" == "" } {
            set templist_C($j) ""
            incr j
         } else {
            array set temp1_C $value
            if { "$temp1_C(instrument)" != "$combinaison_optique_D(instrument)" } {
               set templist_C($j) [ array get temp1_C ]
               incr j
            }
         }
      }

      #-- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique_D,$i) $templist_C($i)
      }

      #--- Je mets la position actuelle de la fenetre dans conf()
      set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(confoptic,position) "+[ string range $geom $deb $fin ]"
   }

   #------------------------------------------------------------
   #  cbCommand_A { }
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
   #  cbCommand_B { }
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
   #  cbCommand_C { }
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
      array set combinaison_optique_D $conf(confoptic,combinaison_optique_D,$index)

      #--- Je copie les valeurs dans les widgets pour la camera C
      set widget(C,instrument)   $combinaison_optique_D(instrument)
      set widget(C,diametre)     $combinaison_optique_D(diametre)
      set widget(C,focale)       $combinaison_optique_D(focale)
      set widget(C,barlow_reduc) $combinaison_optique_D(barlow_reduc)
   }

   #------------------------------------------------------------
   #  fillConfigPage1 { }
   #     Fenetre de configuration de la camera CCD A
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage1 { nn } {
      variable widget
      global audace caption confCam color

      #--- Recherche du numero de la camera A connectee
      if { $confCam(A,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam(A,visuNo) ]
      } else {
         set camNo ""
      }

      #--- Je memorise la reference de la frame
      set widget(frm) [ Rnotebook:frame $nn 1 ]

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
         -editable 1       \
         -textvariable ::confOptic::widget(A,config_instrument) \
         -modifycmd "::confOptic::cbCommand_A $widget(frm).comboboxModele" \
         -values $widget(A,config_instrument)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable confOptic::widget(A,instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable confOptic::widget(A,diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable confOptic::widget(A,focale) -width 8
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
         -textvariable confOptic::widget(A,barlow_reduc) \
         -values $list_combobox
      pack $widget(frm).comboboxBarlow_Reduc -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations calculees du systeme optique
      label $widget(frm).labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $widget(frm).labFoc_Result -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Foc_Result -text "" -relief flat
      pack $widget(frm).labVal_Foc_Result -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labF/D -text "$caption(confoptic,rapport_F/D)" -relief flat
      pack $widget(frm).labF/D -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_F/D -text "" -relief flat
      pack $widget(frm).labVal_F/D -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $widget(frm).labP_Separateur -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_PS -text "" -relief flat
      pack $widget(frm).labVal_PS -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $::confOptic::widget(A,binning) 0 0] [string range $::confOptic::widget(A,binning) 2 2]]
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

      set confOptic::widget(list_combobox) [ ::confCam::getBinningList $camNo ]
      ComboBox $widget(frm).labURL_Binning \
         -width 5          \
         -height [ llength $confOptic::widget(list_combobox) ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable confOptic::widget(A,binning) \
         -modifycmd "::confOptic::Impact_Binning A $widget(frm)" \
         -values $confOptic::widget(list_combobox)
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
         -command "::confOptic::Calculette A $widget(frm)"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette A $widget(frm)

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> "::confCam::run ; set ::confCam(currentCamItem) A ; tkwait window $audace(base).confCam"
      bind [ Rnotebook:button $nn 1 ] <Button-1> "::confOptic::MAJ_Conf_Camera A $::confOptic::widget(frm)"
   }

   #------------------------------------------------------------
   #  fillConfigPage2 { }
   #     Fenetre de configuration de la camera CCD B
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage2 { nn } {
      variable widget
      global audace caption confCam color

      #--- Recherche du numero de la camera B connectee
      if { $confCam(B,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam(B,visuNo) ]
      } else {
         set camNo ""
      }

      #--- Je memorise la reference de la frame
      set widget(frm) [ Rnotebook:frame $nn 2 ]

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
         -editable 1       \
         -textvariable ::confOptic::widget(B,config_instrument) \
         -modifycmd "::confOptic::cbCommand_B $widget(frm).comboboxModele" \
         -values $widget(B,config_instrument)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable confOptic::widget(B,instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable confOptic::widget(B,diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable confOptic::widget(B,focale) -width 8
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
         -textvariable confOptic::widget(B,barlow_reduc) \
         -values $list_combobox
      pack $widget(frm).comboboxBarlow_Reduc -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations calculees du systeme optique
      label $widget(frm).labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $widget(frm).labFoc_Result -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Foc_Result -text "" -relief flat
      pack $widget(frm).labVal_Foc_Result -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labF/D -text "$caption(confoptic,rapport_F/D)" -relief flat
      pack $widget(frm).labF/D -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_F/D -text "" -relief flat
      pack $widget(frm).labVal_F/D -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $widget(frm).labP_Separateur -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_PS -text "" -relief flat
      pack $widget(frm).labVal_PS -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $::confOptic::widget(B,binning) 0 0] [string range $::confOptic::widget(B,binning) 2 2]]
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

      set confOptic::widget(list_combobox) [ ::confCam::getBinningList $camNo ]
      ComboBox $widget(frm).labURL_Binning \
         -width 5          \
         -height [ llength $confOptic::widget(list_combobox) ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable confOptic::widget(B,binning) \
         -modifycmd "::confOptic::Impact_Binning B $widget(frm)" \
         -values $confOptic::widget(list_combobox)
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
         -command "::confOptic::Calculette B $widget(frm)"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette B $widget(frm)

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> "::confCam::run ; set ::confCam(currentCamItem) B ; tkwait window $audace(base).confCam"
      bind [ Rnotebook:button $nn 2 ] <Button-1> "::confOptic::MAJ_Conf_Camera B $::confOptic::widget(frm)"
   }

   #------------------------------------------------------------
   #  fillConfigPage3 { }
   #     Fenetre de configuration de la camera CCD C
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage3 { nn } {
      variable widget
      global audace caption confCam color

      #--- Recherche du numero de la camera C connectee
      if { $confCam(C,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam(C,visuNo) ]
      } else {
         set camNo ""
      }

      #--- Je memorise la reference de la frame
      set widget(frm) [ Rnotebook:frame $nn 3 ]

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
         -editable 1       \
         -textvariable ::confOptic::widget(C,config_instrument) \
         -modifycmd "::confOptic::cbCommand_C $widget(frm).comboboxModele" \
         -values $widget(C,config_instrument)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable confOptic::widget(C,instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable confOptic::widget(C,diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable confOptic::widget(C,focale) -width 8
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
         -textvariable confOptic::widget(C,barlow_reduc) \
         -values $list_combobox
      pack $widget(frm).comboboxBarlow_Reduc -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations calculees du systeme optique
      label $widget(frm).labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $widget(frm).labFoc_Result -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_Foc_Result -text "" -relief flat
      pack $widget(frm).labVal_Foc_Result -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labF/D -text "$caption(confoptic,rapport_F/D)" -relief flat
      pack $widget(frm).labF/D -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_F/D -text "" -relief flat
      pack $widget(frm).labVal_F/D -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $widget(frm).labP_Separateur -in $widget(frm).frame9 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labVal_PS -text "" -relief flat
      pack $widget(frm).labVal_PS -in $widget(frm).frame10 -anchor w -side top -padx 0 -pady 5

      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $::confOptic::widget(C,binning) 0 0] [string range $::confOptic::widget(C,binning) 2 2]]
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

      set confOptic::widget(list_combobox) [ ::confCam::getBinningList $camNo ]
      ComboBox $widget(frm).labURL_Binning \
         -width 5          \
         -height [ llength $confOptic::widget(list_combobox) ] \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable confOptic::widget(C,binning) \
         -modifycmd "::confOptic::Impact_Binning C $widget(frm)" \
         -values $confOptic::widget(list_combobox)
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
         -command "::confOptic::Calculette C $widget(frm)"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette C $widget(frm)

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> "::confCam::run ; set ::confCam(currentCamItem) C ; tkwait window $audace(base).confCam"
      bind [ Rnotebook:button $nn 3 ] <Button-1> "::confOptic::MAJ_Conf_Camera C $::confOptic::widget(frm)"
   }

   #==============================================================
   # Fonctions specifiques
   #==============================================================

   #------------------------------------------------------------
   #  MAJ_Binning { }
   #     Affichage des binnings disponibles selon les cameras
   #
   #------------------------------------------------------------

   proc MAJ_Binning { camItem frm { varname "" } { arrayindex "" } { operation "" } } {
      variable widget
      global confCam

      #--- Recherche du binning associe a la camera selectionnee
      if { $confCam($camItem,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam($camItem,visuNo) ]
      } else {
         set camNo ""
      }
      set confOptic::widget(list_combobox) [ ::confCam::getBinningList $camNo ]
      #--- Mise a jour des parametres dependant du binning
      if { $camNo != "" && $camNo != "0" } {
         #--- Mise a jour de la combobox du binning
         $frm.labURL_Binning configure -height [ llength $::confOptic::widget(list_combobox) ]
         $frm.labURL_Binning configure -values $::confOptic::widget(list_combobox)
      } else {
         #--- Mise a jour de la combobox du binning
         set confOptic::widget($camItem,binning) "1x1"
         $frm.labURL_Binning configure -height [ llength $confOptic::widget(list_combobox) ]
         $frm.labURL_Binning configure -values $confOptic::widget(list_combobox)
         $frm.labURL_Binning configure -textvariable confOptic::widget($camItem,binning)
         #--- Mise a jour du champ et de l'echantilonnage
         $frm.labVal_Champ configure -text ""
         $frm.labVal_Echantillonnage configure -text ""
      }
      #--- Mise a jour des parametres de la camera CCD
      ::confOptic::MAJ_Conf_Camera $camItem $frm
   }

   #------------------------------------------------------------
   #  Impact_Binning { }
   #     Prise en compte du binning choisi
   #
   #------------------------------------------------------------
   proc Impact_Binning { camItem frm } {
      variable widget
      global audace confCam

      #--- Recherche du numero de la camera CCD
      if { $confCam($camItem,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam($camItem,visuNo) ]
      } else {
         set camNo ""
      }
      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $::confOptic::widget($camItem,binning) 0 0] [string range $::confOptic::widget($camItem,binning) 2 2]]
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
      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette $camItem $frm
   }

   #------------------------------------------------------------
   #  Calculette { }
   #     Calcule les differents parametres du systeme optique
   #
   #------------------------------------------------------------
   proc Calculette { camItem frm } {
      variable widget
      global confCam

      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget($camItem,diametre) [ format "%.1f" $confOptic::widget($camItem,diametre) ]
      $frm.entDiametre configure -textvariable confOptic::widget($camItem,diametre)

      set confOptic::widget($camItem,focale) [ format "%.1f" $confOptic::widget($camItem,focale) ]
      $frm.entFocale configure -textvariable confOptic::widget($camItem,focale)

      #--- Je mets a jour la combobox du systeme optique
      set confOptic::widget($camItem,config_instrument) "$confOptic::widget($camItem,instrument) -\
         $confOptic::widget($camItem,diametre) - $confOptic::widget($camItem,focale) -\
         $confOptic::widget($camItem,barlow_reduc)"
      $frm.comboboxModele configure -textvariable confOptic::widget($camItem,config_instrument)

      #--- Calcul de la focale resultante du systeme optique
      set confOptic::widget($camItem,focale_resultante) [ expr $confOptic::widget($camItem,focale) * $confOptic::widget($camItem,barlow_reduc) ]
      $frm.labVal_Foc_Result configure -text $confOptic::widget($camItem,focale_resultante)

      #--- Calcul du rapport F/D du systeme optique
      set confOptic::widget($camItem,F/D) [ format "%.1f" \
         [ expr $confOptic::widget($camItem,focale_resultante) / $confOptic::widget($camItem,diametre) ] ]
      $frm.labVal_F/D configure -text $confOptic::widget($camItem,F/D)

      #--- Calcul du pouvoir separateur du systeme optique
      set confOptic::widget($camItem,PS) [ format "%.2f" [ expr 120.0 / $confOptic::widget($camItem,diametre) ] ]
      $frm.labVal_PS configure -text $confOptic::widget($camItem,PS)

      #--- Recherche du numero de la camera CCD
      if { $confCam($camItem,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam($camItem,visuNo) ]
      } else {
         set camNo ""
      }

      #--- Calcul du champ et de l'echantillonnage de la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         #--- Nombres de pixels en x et en y
         set nb_xy($camItem) [ cam$camNo nbpix ]
         #--- Dimensions des pixels en x et en y
         set pix_dim_xy($camItem) [ cam$camNo pixdim ]
         #--- Dimensions du CCD en x et en y
         set dim_x($camItem) [ expr [ lindex $nb_xy($camItem) 0 ] * [ lindex $pix_dim_xy($camItem) 0 ] * 1000. ]
         set dim_y($camItem) [ expr [ lindex $nb_xy($camItem) 1 ] * [ lindex $pix_dim_xy($camItem) 1 ] * 1000. ]
         #--- Champ en x et en y en minutes d'arc
         set champ_x($camItem) [ format "%.1f" [ expr 206265 * $dim_x($camItem) / ( $confOptic::widget($camItem,focale_resultante) * 60. ) ] ]
         set champ_y($camItem) [ format "%.1f" [ expr 206265 * $dim_y($camItem) / ( $confOptic::widget($camItem,focale_resultante) * 60. ) ] ]
         $frm.labVal_Champ configure -text "$champ_x($camItem) x $champ_y($camItem)"
         #--- Echantillonnage du CCD en x et en y en secondes d'arc par pixels
         set echantillonnage_x($camItem) [ format "%.1f"  [ expr $champ_x($camItem) * 60. / [ lindex $nb_xy($camItem) 0 ] ] ]
         set echantillonnage_y($camItem) [ format "%.1f"  [ expr $champ_y($camItem) * 60. / [ lindex $nb_xy($camItem) 1 ] ] ]
         $frm.labVal_Echantillonnage configure -text "$echantillonnage_x($camItem) x $echantillonnage_y($camItem)"
      }
   }

   #------------------------------------------------------------
   #  MAJ_Conf_Camera { }
   #     Mise a jour des parametres de la camera CCD
   #
   #------------------------------------------------------------
   proc MAJ_Conf_Camera { camItem frm } {
      variable widget
      global audace caption confCam color

      #--- Recherche du numero de la camera CCD
      if { $confCam($camItem,visuNo) != "0" } {
         set camNo [ ::confVisu::getCamNo $confCam($camItem,visuNo) ]
      } else {
         set camNo ""
      }
      #--- Prise en compte du binning choisi
      if { $camNo != "" && $camNo != "0" } {
         cam$camNo bin [list [string range $::confOptic::widget($camItem,binning) 0 0] [string range $::confOptic::widget($camItem,binning) 2 2]]
      }
      #--- Je mets a jour les parametres de la camera CCD
      if { $camNo != "" && $camNo != "0" } {
         set camera($camItem)   "[ lindex [ cam$camNo info ] 1 ]"
         set capteur($camItem)  "[ lindex [ cam$camNo info ] 2 ]"
         set cell_dim($camItem) "[ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]"
         set pix_dim($camItem)  "[ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]"
         set fg                  "$color(blue)"
      } else {
         set camera($camItem)   "$caption(confoptic,nocam)"
         set capteur($camItem)  ""
         set cell_dim($camItem) ""
         set pix_dim($camItem)  ""
         set fg                  "$color(red)"
      }
      #--- Affichage des parametres de la camera CCD
      if { [ winfo exists $audace(base).confOptic ] } {
         $frm.labURL_nomCamera configure -text $camera($camItem) -fg $fg
         $frm.labURL_typeCapteur configure -text $capteur($camItem)
         $frm.labURL_CellDim configure -text $cell_dim($camItem)
         $frm.labURL_PixDim configure -text $pix_dim($camItem)
         ::confOptic::Calculette $camItem $frm
      }
   }

}

::confOptic::init

