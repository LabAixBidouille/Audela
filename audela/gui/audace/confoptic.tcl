#
# Fichier : confoptic.tcl
# Description : Affiche la fenetre de configuration des systemes optiques associes aux cameras A, B et C
# Auteur : Robert DELMAS
# Mise a jour $Id: confoptic.tcl,v 1.10 2006-12-18 21:32:49 robertdelmas Exp $
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

      uplevel #0 "source \"[ file join $audace(rep_caption) confoptic.cap ]\""
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
      if { $conf(camera,$confCam(cam_item),camName) != "" } {
         select $conf(camera,$confCam(cam_item),camName)
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

      if { ! [ info exists conf(confoptic,position) ] } { set conf(confoptic,position) "+150+75" }

      if { ! [ info exists conf(confoptic,combinaison_optique,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "1.0"

         set conf(confoptic,combinaison_optique,0) [ array get combinaison_optique ]
      }

      if { ! [ info exists conf(confoptic,combinaison_optique,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "0.66"

         set conf(confoptic,combinaison_optique,1) [ array get combinaison_optique ]
      }

      if { ! [ info exists conf(confoptic,combinaison_optique,2) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "0.33"

         set conf(confoptic,combinaison_optique,2) [ array get combinaison_optique ]
      }

      if { ! [ info exists conf(confoptic,combinaison_optique,3) ] } {
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "2.5"

         set conf(confoptic,combinaison_optique,3) [ array get combinaison_optique ]
      }

      if { ! [ info exists conf(confoptic,combinaison_optique,4) ] } { set conf(confoptic,combinaison_optique,4) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,5) ] } { set conf(confoptic,combinaison_optique,5) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,6) ] } { set conf(confoptic,combinaison_optique,6) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,7) ] } { set conf(confoptic,combinaison_optique,7) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,8) ] } { set conf(confoptic,combinaison_optique,8) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,9) ] } { set conf(confoptic,combinaison_optique,9) "" }

      #--- J'initialise la combobox du binning
      set widget(binning) "1x1"
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
      appliquer $visuNo
      fermer $visuNo
   }

   #------------------------------------------------------------
   #  appliquer { }
   #     Fonction appellee lors de l'appui sur le bouton
   #     'Appliquer' pour memoriser et appliquer la
   #     configuration
   #  
   #------------------------------------------------------------
   proc appliquer { visuNo } {
      variable This

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -relief groove -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      widgetToConf $visuNo
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
      ::confVisu::removeCameraListener $visuNo "::confOptic::MAJ_Binning $visuNo"
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
         fillConfigPage1 $nn $visuNo
         fillConfigPage2 $nn $visuNo
         fillConfigPage3 $nn $visuNo
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
            -command "::confOptic::appliquer $visuNo"
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(confoptic,fermer)" -relief raised -state normal -width 7 \
            -command "::confOptic::fermer $visuNo"
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(confoptic,aide)" -relief raised -state normal -width 7 \
            -command "::confOptic::afficherAide"
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Charge la procedure de surveillance de la connexion d'une camera
      ::confVisu::addCameraListener $visuNo "::confOptic::MAJ_Binning $visuNo"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  select [ cam_item ]
   #     Selectionne un onglet en passant le nom de la
   #     camera (A, B ou C)
   #  
   #------------------------------------------------------------
   proc select { { cam_item A } } {
      variable This

      set nn $This.usr.book
      switch -exact -- $cam_item {
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

      #--- Je prepare les valeurs de la combobox de configuration du systeme optique
      set widget(config_instrument) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique(instrument) - $combinaison_optique(diametre) - $combinaison_optique(focale) -\
            $combinaison_optique(barlow_reduc)"
         #--- J'ajoute la ligne
         lappend widget(config_instrument) "$line"
      }

      #--- Autre valeur sauvegardee dans conf()
      set widget(confoptic,position) "$conf(confoptic,position)"
   }

   #------------------------------------------------------------
   #  widgetToConf { }
   #     Copie les valeurs des widgets dans le tableau conf()
   #  
   #------------------------------------------------------------
   proc widgetToConf { visuNo } {
      variable private
      variable widget
      global conf

      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(diametre) [ format "%.1f" $confOptic::widget(diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(diametre)

      set confOptic::widget(focale) [ format "%.1f" $confOptic::widget(focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(focale)

      #--- Je mets a jour la combobox de configuration du systeme optique
      set confOptic::widget(config_instrument) "$confOptic::widget(instrument) - $confOptic::widget(diametre) -\
         $confOptic::widget(focale) - $confOptic::widget(barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(config_instrument)

      #--- Mise a jour des parametres calcules
      ::confOptic::Calculette $visuNo

      #--- Je copie les valeurs des widgets
      set private(instrument)   $widget(instrument)
      set private(diametre)     $widget(diametre)
      set private(focale)       $widget(focale)
      set private(barlow_reduc) $widget(barlow_reduc)

      #--- J'ajoute le systeme optique en tete dans le tableau des systemes optiques precedents si il n'y est pas deja
      array set combinaison_optique { }
      set combinaison_optique(instrument)   "$private(instrument)"
      set combinaison_optique(diametre)     "$private(diametre)"
      set combinaison_optique(focale)       "$private(focale)"
      set combinaison_optique(barlow_reduc) "$private(barlow_reduc)"

      #--- Je copie conf dans templist en mettant le systeme optique courant en premier
      array set templist { }
      set templist(0) [ array get combinaison_optique ]
      set j "1"
      foreach {key value} [ array get conf confoptic,combinaison_optique,* ] {
         if { "$value" == "" } {
            set templist($j) ""
            incr j
         } else {
            array set temp1 $value
            if { "$temp1(instrument)" != "$combinaison_optique(instrument)" } {
               set templist($j) [ array get temp1 ]
               incr j
            }
         }
      }

      #-- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique,$i) $templist($i)
      }

      #--- Je mets la position actuelle de la fenetre dans conf()
      set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(confoptic,position) "+[ string range $geom $deb $fin ]"
   }

   #------------------------------------------------------------
   #  cbCommand { }
   #     (appelee par la combobox a chaque changement de selection)
   #     Affiche les valeurs dans les widgets
   #  
   #  return rien
   #------------------------------------------------------------
   proc cbCommand { cb } {
      variable widget
      global conf

      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration optique de conf()
      array set combinaison_optique $conf(confoptic,combinaison_optique,$index)

      #--- Je copie les valeurs dans les widgets
      set widget(instrument)   $combinaison_optique(instrument)
      set widget(diametre)     $combinaison_optique(diametre)
      set widget(focale)       $combinaison_optique(focale)
      set widget(barlow_reduc) $combinaison_optique(barlow_reduc)
   }

   #------------------------------------------------------------
   #  fillConfigPage1 { visuNo }
   #     Fenetre de configuration de la camera CCD A
   #  
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage1 { nn visuNo } {
      variable widget
      global audace caption color

      #--- Recherche du numero de la camera CCD connectee
      set camNo [ ::confVisu::getCamNo $visuNo ]

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
         -textvariable ::confOptic::widget(config_instrument) \
         -modifycmd "::confOptic::cbCommand $widget(frm).comboboxModele" \
         -values $widget(config_instrument)
      pack $widget(frm).comboboxModele -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $widget(frm).labInstrument -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entInstrument -textvariable confOptic::widget(instrument) -width 30
      pack $widget(frm).entInstrument -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $widget(frm).labDiametre -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entDiametre -textvariable confOptic::widget(diametre) -width 8
      pack $widget(frm).entDiametre -in $widget(frm).frame8 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $widget(frm).labFocale -in $widget(frm).frame7 -anchor w -side top -padx 30 -pady 5

      entry $widget(frm).entFocale -textvariable confOptic::widget(focale) -width 8
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
         -textvariable confOptic::widget(barlow_reduc) \
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
      if { $camNo != "0" } {
         cam[ ::confVisu::getCamNo $visuNo ] bin [list [string range $::confOptic::widget(binning) 0 0] [string range $::confOptic::widget(binning) 2 2]]
      }

      #--- Informations liees a la camera CCD
      if { $camNo != "0" } {
         set camera   "[ lindex [ cam[ ::confVisu::getCamNo $visuNo ] info ] 1 ]"
         set capteur  "[ lindex [ cam[ ::confVisu::getCamNo $visuNo ] info ] 2 ]"
         set cell_dim "[ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] celldim ] 1 ] * 1e6 ]"
         set pix_dim  "[ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ] 1 ] * 1e6 ]"
         set fg       "$color(blue)"
      } else {
         set camera   "$caption(confoptic,nocam)"
         set capteur  ""
         set cell_dim ""
         set pix_dim  ""
         set fg       "$color(red)"
      }

      label $widget(frm).labCamera -text "$caption(confoptic,camera)" -relief flat
      pack $widget(frm).labCamera -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_nomCamera -font $audace(font,url) -text $camera -fg $fg
      pack $widget(frm).labURL_nomCamera -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCapteurCCD -text "$caption(confoptic,capteur_ccd)" -relief flat
      pack $widget(frm).labCapteurCCD -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_typeCapteur -text $capteur
      pack $widget(frm).labURL_typeCapteur -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labCellDim -text "$caption(confoptic,cell_dim)" -relief flat
      pack $widget(frm).labCellDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_CellDim -text $cell_dim
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
         -textvariable confOptic::widget(binning) \
         -modifycmd "::confOptic::Impact_Binning $visuNo" \
         -values $confOptic::widget(list_combobox)
      pack $widget(frm).labURL_Binning -in $widget(frm).frame12 -anchor w -side top -padx 0 -pady 5

      label $widget(frm).labPixDim -text "$caption(confoptic,pix_dim)" -relief flat
      pack $widget(frm).labPixDim -in $widget(frm).frame11 -anchor w -side top -padx 10 -pady 5

      label $widget(frm).labURL_PixDim -text $pix_dim
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
      ::confOptic::cbCommand $widget(frm).comboboxModele

      #--- Definition du bouton Calcul
      button $widget(frm).but_Calcul -text "$caption(confoptic,calcul)" -relief raised -width 15 \
         -command "::confOptic::Calculette $visuNo"
      pack $widget(frm).but_Calcul -in $widget(frm).frame4 -anchor center -side left -expand true \
         -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette $visuNo

      #--- Bind pour la selection d'une camera CCD
      bind $widget(frm).labURL_nomCamera <ButtonPress-1> " \
         ::confCam::run ; \
         tkwait window $audace(base).confCam ; \
         #--- Mise a jour des parametres de la camera CCD ; \
         ::confOptic::MAJ_Conf_Camera $visuNo"
   }

################################
   #------------------------------------------------------------
   #  fillConfigPage2 { visuNo }
   #     Fenetre de configuration de la camera CCD B
   #  
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage2 { nn visuNo } {
      variable widget
      global audace caption color

      #--- Je memorise la reference de la frame
     # set widget(frm) [ Rnotebook:frame $nn 2 ]


   }

   #------------------------------------------------------------
   #  fillConfigPage3 { visuNo }
   #     Fenetre de configuration de la camera CCD C
   #  
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage3 { nn visuNo } {
      variable widget
      global audace caption color

      #--- Je memorise la reference de la frame
     # set widget(frm) [ Rnotebook:frame $nn 3 ]


   }
################################

   #==============================================================
   # Fonctions specifiques
   #==============================================================

   #------------------------------------------------------------
   #  MAJ_Binning { }
   #     Affichage des binnings disponibles selon les cameras
   #  
   #------------------------------------------------------------

   proc MAJ_Binning { visuNo { varname "" } { arrayindex "" } { operation "" } } {
      variable widget

      #--- Recherche du binning associe a la camera selectionnee
      set camNo [ ::confVisu::getCamNo $visuNo ]
      set confOptic::widget(list_combobox) [ ::confCam::getBinningList $camNo ]
      #--- Mise a jour des parametres dependant du binning
      if { $camNo == "0" } {
         #--- Mise a jour de la combobox du binning
         set confOptic::widget(binning) "1x1"
         $widget(frm).labURL_Binning configure -height [ llength $confOptic::widget(list_combobox) ]
         $widget(frm).labURL_Binning configure -values $confOptic::widget(list_combobox)
         $widget(frm).labURL_Binning configure -textvariable confOptic::widget(binning)
         #--- Mise a jour du champ et de l'echantilonnage
         $confOptic::widget(frm).labVal_Champ configure -text ""
         $confOptic::widget(frm).labVal_Echantillonnage configure -text ""
      } else {
         #--- Mise a jour de la combobox du binning
         $widget(frm).labURL_Binning configure -height [ llength $::confOptic::widget(list_combobox) ]
         $widget(frm).labURL_Binning configure -values $::confOptic::widget(list_combobox)
      }
      #--- Mise a jour des parametres de la camera CCD
      ::confOptic::MAJ_Conf_Camera $visuNo
   }

   #------------------------------------------------------------
   #  Impact_Binning { }
   #     Prise en compte du binning choisi
   #  
   #------------------------------------------------------------
   proc Impact_Binning { visuNo } {
      variable widget
      global audace

      #--- Recherche du numero de la camera CCD
      set camNo [ ::confVisu::getCamNo $visuNo ]
      #--- Prise en compte du binning choisi
      if { $camNo != "0" } {
         cam[ ::confVisu::getCamNo $visuNo ] bin [list [string range $::confOptic::widget(binning) 0 0] [string range $::confOptic::widget(binning) 2 2]]
      }
      #--- Mise a jour des informations concernant la camera
      if { $camNo != "0" } {
         set pix_dim "[ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ] 1 ] * 1e6 ]"
      } else {
         set pix_dim ""
      }
      if { [ winfo exists $audace(base).confOptic ] } {
         $::confOptic::widget(frm).labURL_PixDim configure -text $pix_dim
      }
      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette $visuNo
   }

   #------------------------------------------------------------
   #  Calculette { }
   #     Calcule les differents parametres du systeme optique
   #  
   #------------------------------------------------------------
   proc Calculette { visuNo } {
      variable widget
      global audace

      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(diametre) [ format "%.1f" $confOptic::widget(diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(diametre)

      set confOptic::widget(focale) [ format "%.1f" $confOptic::widget(focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(focale)

      #--- Je mets a jour la combobox du systeme optique
      set confOptic::widget(config_instrument) "$confOptic::widget(instrument) - $confOptic::widget(diametre) -\
         $confOptic::widget(focale) - $confOptic::widget(barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(config_instrument)

      #--- Calcul de la focale resultante du systeme optique
      set confOptic::widget(focale_resultante) [ expr $confOptic::widget(focale) * $confOptic::widget(barlow_reduc) ]
      $confOptic::widget(frm).labVal_Foc_Result configure -text $confOptic::widget(focale_resultante)

      #--- Calcul du rapport F/D du systeme optique
      set confOptic::widget(F/D) [ format "%.1f" \
         [ expr $confOptic::widget(focale_resultante) / $confOptic::widget(diametre) ] ]
      $confOptic::widget(frm).labVal_F/D configure -text $confOptic::widget(F/D)

      #--- Calcul du pouvoir separateur du systeme optique
      set confOptic::widget(PS) [ format "%.2f" [ expr 120.0 / $confOptic::widget(diametre) ] ]
      $confOptic::widget(frm).labVal_PS configure -text $confOptic::widget(PS)

      #--- Recherche du numero de la camera CCD
      set camNo [ ::confVisu::getCamNo $visuNo ]

      #--- Calcul du champ et de l'echantillonnage de la camera CCD
      if { $camNo != "0" } {
         #--- Nombres de pixels en x et en y
         set nb_xy [ cam[ ::confVisu::getCamNo $visuNo ] nbpix ]
         #--- Dimensions des pixels en x et en y
         set pix_dim_xy [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ]
         #--- Dimensions du CCD en x et en y
         set dim_x [ expr [ lindex $nb_xy 0 ] * [ lindex $pix_dim_xy 0 ] * 1000. ]
         set dim_y [ expr [ lindex $nb_xy 1 ] * [ lindex $pix_dim_xy 1 ] * 1000. ]
         #--- Champ en x et en y en minutes d'arc
         set champ_x [ format "%.1f" [ expr 206265 * $dim_x / ( $confOptic::widget(focale_resultante) * 60. ) ] ]
         set champ_y [ format "%.1f" [ expr 206265 * $dim_y / ( $confOptic::widget(focale_resultante) * 60. ) ] ]
         $confOptic::widget(frm).labVal_Champ configure -text "$champ_x x $champ_y"
         #--- Echantillonnage du CCD en x et en y en secondes d'arc par pixels
         set echantillonnage_x [ format "%.1f"  [ expr $champ_x * 60. / [ lindex $nb_xy 0 ] ] ]
         set echantillonnage_y [ format "%.1f"  [ expr $champ_y * 60. / [ lindex $nb_xy 1 ] ] ]
         $confOptic::widget(frm).labVal_Echantillonnage configure -text "$echantillonnage_x x $echantillonnage_y"
      }
   }

   #------------------------------------------------------------
   #  MAJ_Conf_Camera { }
   #     Mise a jour des parametres de la camera CCD
   #  
   #------------------------------------------------------------
   proc MAJ_Conf_Camera { visuNo } {
      variable widget
      global audace caption color

      #--- Recherche du numero de la camera CCD
      set camNo [ ::confVisu::getCamNo $visuNo ]
      #--- Prise en compte du binning choisi
      if { $camNo != "0" } {
         cam[ ::confVisu::getCamNo $visuNo ] bin [list [string range $::confOptic::widget(binning) 0 0] [string range $::confOptic::widget(binning) 2 2]]
      }
      #--- Je mets a jour les parametres de la camera CCD
      if { $camNo != "0" } {
         set camera   "[ lindex [ cam[ ::confVisu::getCamNo $visuNo ] info ] 1 ]"
         set capteur  "[ lindex [ cam[ ::confVisu::getCamNo $visuNo ] info ] 2 ]"
         set cell_dim "[ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] celldim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] celldim ] 1 ] * 1e6 ]"
         set pix_dim  "[ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ] 0 ] * 1e6 ] x \
            [ expr [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] pixdim ] 1 ] * 1e6 ]"
         set fg       "$color(blue)"
      } else {
         set camera   "$caption(confoptic,nocam)"
         set capteur  ""
         set cell_dim ""
         set pix_dim  ""
         set fg       "$color(red)"
      }
      #--- Affichage des parametres de la camera CCD
      if { [ winfo exists $audace(base).confOptic ] } {
         $::confOptic::widget(frm).labURL_nomCamera configure -text $camera -fg $fg
         $::confOptic::widget(frm).labURL_typeCapteur configure -text $capteur
         $::confOptic::widget(frm).labURL_CellDim configure -text $cell_dim
         $::confOptic::widget(frm).labURL_PixDim configure -text $pix_dim
         ::confOptic::Calculette $visuNo
      }
   }

}

::confOptic::init

