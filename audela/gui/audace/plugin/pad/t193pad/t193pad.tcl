#
# Fichier : t193pad.tcl
# Description : Raquette specifique au T193 de l'OHP
# Auteur : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: t193pad.tcl,v 1.1 2009-10-25 13:27:08 robertdelmas Exp $
#

namespace eval ::t193pad {
   package provide t193pad 1.0
   package require audela 1.4.0
   source [ file join [file dirname [info script]] t193pad.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
      #--- Cree les variables dans conf(...) si elles n'existent pas
      initConf
      #--- J'initialise les variables widget(..)
      confToWidget
   }

   #------------------------------------------------------------
   #  getPluginProperty
   #     retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete, ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
      }
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le label du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(t193pad,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "t193pad.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "pad"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      variable private
      global caption conf

      set private(targetRa)      "0h0m0s"
      set private(targetDec)     "0d0m0s"
      set private(controleSuivi) "$caption(t193pad,suivi_marche)"
      set private(positionFoc)   "0"
      set private(positionDome)  "0"
      set private(synchro)       "1"

      if { ! [ info exists conf(t193pad,wmgeometry) ] }   { set conf(t193pad,wmgeometry)   "205x486+643+214" }
      if { ! [ info exists conf(t193pad,focuserLabel) ] } { set conf(t193pad,focuserLabel) "" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #
   #  return rien
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(focuserLabel) $conf(t193pad,focuserLabel)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(t193pad,focuserLabel) $widget(focuserLabel)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Frame pour le choix du focuser
      frame $frm.frame1 -borderwidth 0 -relief raised

         ::confEqt::createFrameFocuser $frm.frame1.focuser ::t193pad::widget(focuserLabel)
         pack $frm.frame1.focuser -anchor nw -side left -padx 10 -pady 10

      pack $frm.frame1 -side top -fill both -expand 0

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }

   #------------------------------------------------------------
   #  createPluginInstance
   #     cree une instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc createPluginInstance { } {
      global conf

      #--- Creation du focuser
      if { $conf(superpad,focuserLabel) != "" } {
         ::$conf(superpad,focuserLabel)::createPlugin
      }

      #--- Affiche la raquette
      t193pad::run

      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      variable This
      global conf

      #--- Ferme la raquette
      if { [ info exists This ] == 1 } {
         if { [ winfo exists $This ] == 1 } {
            set conf(t193pad,wmgeometry) [ wm geometry $This ]
           destroy $This
         }
      }
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du plugin
   #
   #  return 0 (ready), 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du plugin
   #==============================================================

   #------------------------------------------------------------
   #  run
   #     cree la fenetre de la raquette
   #------------------------------------------------------------
   proc run { } {
      variable This

      #--- Je cree la fenetre de la raquette
      set This ".t193pad"
      createDialog

      #--- Je refraichis l'affichage des coordonnees
      ::telescope::afficheCoord

   }

   #------------------------------------------------------------
   #  createDialog
   #     creation de l'interface graphique
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable private
      global audace caption color conf

      if { [ winfo exists $This ] } {
         destroy $This
      }

      #--- Cree la fenetre This de niveau le plus haut
      toplevel $This -class toplevel -bg $color(blue_pad)
      wm title $This $caption(t193pad,titre)
      if { [ info exists conf(t193pad,wmgeometry) ] == "1" } {
         wm geometry $This $conf(t193pad,wmgeometry)
      } else {
         wm geometry $This 205x486+643+214
      }
      wm resizable $This 1 1
      wm protocol $This WM_DELETE_WINDOW ::t193pad::deletePluginInstance

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame2 -side top -fill both -expand 1

      frame $This.frame3 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame3 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame4 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame5 -side top -fill both -expand 1

      #--- Label pour AD
      label $This.frame1.ent1 -textvariable audace(telescope,getra) \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame1.ent1 -anchor center -fill none -pady 1

      #--- Label pour DEC
      label $This.frame1.ent2 -textvariable audace(telescope,getdec) \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame1.ent2 -anchor center -fill none -pady 1

      #--- Bind de l'affichage des coordonnees
      set zone(radec) $This.frame1
      bind $zone(radec) <ButtonPress-1>      { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame du bouton 'N'
      frame $This.frame2.n -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame2.n -side top -fill x

      #--- Bouton 'N'
      button $This.frame2.n.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(t193pad,nord)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.n.canv1 -expand 0 -side top -padx 10 -pady 4

      #--- Frame des boutons 'E', 'O' et de la vitesse de la monture
      frame $This.frame2.we -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame2.we -side top -fill x

      #--- Bouton 'E'
      button $This.frame2.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(t193pad,est)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.we.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Label de la vitesse de la monture
      label $This.frame2.we.vitesseMonture -font [ list {Arial} 12 bold ] \
         -textvariable audace(telescope,labelspeed) -bg $color(blue_pad) -fg $color(white) \
         -borderwidth 0 -relief flat
      pack $This.frame2.we.vitesseMonture -expand 1 -side left

      #--- Bouton 'O'
      button $This.frame2.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(t193pad,ouest)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.we.canv2 -expand 0 -side right -padx 10 -pady 4

      #--- Frame du bouton 'S'
      frame $This.frame2.s -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame2.s -side top -fill x

      #--- Bouton 'S'
      button $This.frame2.s.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(t193pad,sud)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.s.canv1 -expand 0 -side top -padx 10 -pady 4

      #--- Label du controle du suivi : Suivi on ou off
      if { [ ::confTel::getPluginProperty hasControlSuivi ] == "1" } {
         radiobutton $This.frame2.s.controleSuiviOn -indicatoron 0 -font [ list {Arial} 10 bold ] \
            -bg $color(gray_pad) -fg $color(white) -selectcolor $color(gray_pad) \
            -text "$caption(t193pad,suivi_marche)" -value "$caption(t193pad,suivi_marche)" \
            -variable ::t193pad::private(controleSuivi) -command "::telescope::controleSuivi"
         pack $This.frame2.s.controleSuiviOn -expand 1 -fill x -side left -pady 2
         radiobutton $This.frame2.s.controleSuiviOff -indicatoron 0 -font [ list {Arial} 10 bold ] \
            -bg $color(gray_pad) -fg $color(white) -selectcolor $color(gray_pad) \
            -text "$caption(t193pad,suivi_arret)" -value "$caption(t193pad,suivi_arret)" \
            -variable ::t193pad::private(controleSuivi) -command "::telescope::controleSuivi"
         pack $This.frame2.s.controleSuiviOff -expand 1 -fill x -side left -pady 2
      }

      #--- LabelEntry pour AD
      LabelEntry $This.frame3.ad -label $caption(t193pad,RA) \
         -textvariable ::t193pad::private(targetRa) -width 13 -fg $color(white) \
         -bg $color(blue_pad) -entrybg $color(gray_pad) -justify center \
         -labelfont [ list {Arial} 10 bold ] -font [ list {Arial} 10 bold ]
      pack $This.frame3.ad -anchor center -fill none -pady 2

      #--- LabelEntry pour DEC
      LabelEntry $This.frame3.dec -label $caption(t193pad,DEC) \
         -textvariable ::t193pad::private(targetDec) -width 13 -fg $color(white) \
         -bg $color(blue_pad) -entrybg $color(gray_pad) -justify center \
         -labelfont [ list {Arial} 10 bold ] -font [ list {Arial} 10 bold ]
      pack $This.frame3.dec -anchor center -fill none -pady 2

      #--- Bouton GOTO
      button $This.frame3.buttonGoto -borderwidth 1 -width 16\
         -font [ list {Arial} 10 bold ] -text $caption(t193pad,goto) -relief ridge \
         -fg $color(white) -bg $color(gray_pad) -command "::t193pad::cmdStartGoto"
      pack $This.frame3.buttonGoto -anchor center -fill x -side left -pady 2

      #--- Bouton Stop GOTO
      button $This.frame3.buttonStopGoto -borderwidth 1 -width 10 \
         -font [ list {Arial} 10 bold ] -text $caption(t193pad,stopGoto) -relief ridge \
         -fg $color(white) -bg $color(gray_pad) -command "::telescope::stopGoto"
      pack $This.frame3.buttonStopGoto -anchor center -fill x -pady 2

      #--- Bind des boutons 'N', 'E', 'O' et 'S'
      set zone(n) $This.frame2.n.canv1
      set zone(e) $This.frame2.we.canv1
      set zone(w) $This.frame2.we.canv2
      set zone(s) $This.frame2.s.canv1
      bind $zone(e) <ButtonPress-1>   { catch { ::telescope::move e } }
      bind $zone(e) <ButtonRelease-1> { ::telescope::stop e }
      bind $zone(w) <ButtonPress-1>   { catch { ::telescope::move w } }
      bind $zone(w) <ButtonRelease-1> { ::telescope::stop w }
      bind $zone(s) <ButtonPress-1>   { catch { ::telescope::move s } }
      bind $zone(s) <ButtonRelease-1> { ::telescope::stop s }
      bind $zone(n) <ButtonPress-1>   { catch { ::telescope::move n } }
      bind $zone(n) <ButtonRelease-1> { ::telescope::stop n }

      #--- Bind de la vitesse de la monture
      bind $This.frame2.we.vitesseMonture <ButtonPress-1> { ::telescope::incrementSpeed }

      #--- Label pour le moteur de focalisation
      label $This.frame4.focus -text $caption(t193pad,moteur_foc) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame4.focus -anchor center -fill none -padx 4 -pady 1

      #--- Frame pour les boutons '-' et '+'
      frame $This.frame4.pm -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame4.pm -side top -fill x

      #--- Bouton '-'
      button $This.frame4.pm.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "-" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame4.pm.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Label pour la position de la focalisation courante
      label $This.frame4.pm.positionFoc -textvariable ::t193pad::private(positionFoc) \
         -bg $color(blue_pad) -fg $color(white) -font [ list {Arial} 12 bold ] -width 10 \
         -borderwidth 0 -relief flat
      pack $This.frame4.pm.positionFoc -expand 1 -side left

      #--- Bouton '+'
      button $This.frame4.pm.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "+" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame4.pm.canv2 -expand 0 -side right -padx 10 -pady 4

      #--- Label de la vitesse du moteur de focalisation
      label $This.frame4.vitesseFocus -font [ list {Arial} 12 bold ] \
         -textvariable audace(focus,labelspeed) -bg $color(blue_pad) -fg $color(white) \
         -width 2 -borderwidth 0 -relief flat
      pack $This.frame4.vitesseFocus -anchor center -fill none -pady 2

      #--- Bouton GOTOFoc
      button $This.frame4.buttonGotoFoc -borderwidth 1 -width 10\
         -font [ list {Arial} 10 bold ] -text $caption(t193pad,gotoFoc) -relief ridge \
         -fg $color(white) -bg $color(gray_pad) -command "  "
      pack $This.frame4.buttonGotoFoc -anchor center -fill x -side left -pady 2

      #--- LabelEntry pour la position du GOTO de la focalisation
      LabelEntry $This.frame4.positionGotoFoc -textvariable ::t193pad::private(gotoFoc) \
         -width 10 -entrybg $color(gray_pad) -justify center -font [ list {Arial} 10 bold ]
      pack $This.frame4.positionGotoFoc -anchor center -fill none -pady 2

      #--- Bind des boutons '+' et '-'
      set zone(moins) $This.frame4.pm.canv1
      set zone(plus)  $This.frame4.pm.canv2
      bind $zone(moins) <ButtonPress-1>   { catch { ::focus::move $::conf(t193pad,focuserLabel) - } }
      bind $zone(moins) <ButtonRelease-1> { ::focus::move $::conf(t193pad,focuserLabel) stop }
      bind $zone(plus)  <ButtonPress-1>   { catch { ::focus::move $::conf(t193pad,focuserLabel) + } }
      bind $zone(plus)  <ButtonRelease-1> { ::focus::move $::conf(t193pad,focuserLabel) stop }

      #--- Bind de la vitesse du moteur de focalisation
      bind $This.frame4.vitesseFocus <ButtonPress-1> { ::focus::incrementSpeed $::conf(t193pad,focuserLabel) pad }

      #--- Label pour le dome
      label $This.frame5.dome -text $caption(t193pad,dome) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame5.dome -anchor center -fill none -padx 4 -pady 1

      #--- Frame pour les boutons '-' et '+'
      frame $This.frame5.pm -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame5.pm -side top -fill x

      #--- Bouton '-'
      button $This.frame5.pm.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "-" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame5.pm.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Label pour la position du dome
      label $This.frame5.pm.positionDome -textvariable ::t193pad::private(positionDome) \
         -bg $color(blue_pad) -fg $color(white) -font [ list {Arial} 12 bold ] -width 10 \
         -borderwidth 0 -relief flat
      pack $This.frame5.pm.positionDome -expand 1 -side left

      #--- Bouton '+'
      button $This.frame5.pm.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "+" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame5.pm.canv2 -expand 0 -side right -padx 10 -pady 4

      #--- Checkbutton pour la synchronisation du dome sur la monture
      checkbutton $This.frame5.check -text "$caption(t193pad,synchroMonture)" \
         -variable ::t193pad::private(synchro) -bg $color(blue_pad) -fg $color(white) \
         -activebackground $color(blue_pad) -activeforeground $color(white) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -font [ list {Arial} 10 bold ] -command "  "
      pack $This.frame5.check -anchor center -fill none -pady 2

      #--- Bind des boutons '+' et '-'
      set zone(moins) $This.frame5.pm.canv1
      set zone(plus)  $This.frame5.pm.canv2
      bind $zone(moins) <ButtonPress-1>   {  }
      bind $zone(moins) <ButtonRelease-1> {  }
      bind $zone(plus)  <ButtonPress-1>   {  }
      bind $zone(plus)  <ButtonRelease-1> {  }

      #--- Initialise et affiche la vitesse du focuser
      ::focus::setSpeed "$conf(superpad,focuserLabel)" "0"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
   }

   #------------------------------------------------------------
   #  cmdStartGoto
   #     pointe l'objet cible
   #------------------------------------------------------------
   proc cmdStartGoto { } {
      variable This
      variable private

      ::telescope::goto [ list $private(targetRa) $private(targetDec) ] "0" $This.frame3.buttonGoto
   }

}

