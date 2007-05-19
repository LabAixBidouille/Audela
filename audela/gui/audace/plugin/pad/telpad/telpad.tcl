#
# Fichier : telpad.tcl
# Description : Raquette simplifiee a l'usage des telescopes
# Auteur : Robert DELMAS
# Mise a jour $Id: telpad.tcl,v 1.11 2007-05-19 09:19:27 robertdelmas Exp $
#

namespace eval telpad {
   package provide telpad 1.0
   source [ file join [file dirname [info script]]  telpad.cap ]

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
   # return : valeur de la propriete , ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {

      }
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "pad"
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le label du driver dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(telpad,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {
      return "telpad.htm"
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(telpad,visible) ] }      { set conf(telpad,visible)      "1" }
      if { ! [ info exists conf(telpad,wmgeometry) ] }   { set conf(telpad,wmgeometry)   "157x254+657+252" }
      if { ! [ info exists conf(telpad,focuserLabel) ] } { set conf(telpad,focuserLabel) "focuserlx200" }

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

      set widget(visible)      $conf(telpad,visible)
      set widget(focuserLabel) $conf(telpad,focuserLabel)
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

      set conf(telpad,visible)      $widget(visible)
      set conf(telpad,focuserLabel) $widget(focuserLabel)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du driver
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 0

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 0

      #--- Frame focuser
      ::confEqt::createFrameFocuser $frm.frame1.focuser ::telpad::widget(focuserLabel)
      pack $frm.frame1.focuser -in $frm.frame1 -anchor nw -side left -padx 10 -pady 10

      #--- Raquette toujours visible
      checkbutton $frm.visible -text "$caption(telpad,pad_visible)" -highlightthickness 0 \
         -variable ::telpad::widget(visible) -onvalue 1 -offvalue 0
      pack $frm.visible -in $frm.frame2 -anchor nw -side left -padx 10 -pady 10

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }

   #------------------------------------------------------------
   #  createPluginInstance
   #     cree une intance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc createPluginInstance { } {
      global audace

      #--- Affiche la raquette
      telpad::run "$audace(base).telpad"
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
      if { [info exists This] == 1 } {
         if { [ winfo exists $This ] == 1 } {
            set conf(telpad,wmgeometry) "[ wm geometry $This ]"
           destroy $This
         }
      }
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du driver
   #
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du driver
   #==============================================================

   #------------------------------------------------------------
   #  run this
   #     cree la fenetre de la raquette
   #     this = chemin de la fenetre
   #------------------------------------------------------------
   proc run { { this } } {
      variable This

      set This $this
      createDialog
      #tkwait visibility $This

      #--- Je refraichis l'affichage des coordonnees
      ::telescope::afficheCoord

   }

   #------------------------------------------------------------
   #  createDialog
   #     creation de l'interface graphique
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf

      if { [ winfo exists $This ] } {
         destroy $This
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm title $This $caption(telpad,titre)
      if { [ info exists conf(telpad,wmgeometry) ] == "1" } {
         wm geometry $This $conf(telpad,wmgeometry)
      } else {
         wm geometry $This 157x256+657+252
      }
      wm resizable $This 1 1
      wm protocol $This WM_DELETE_WINDOW ::telpad::deletePluginInstance

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief groove
      pack $This.frame2 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame3 -borderwidth 1 -relief groove
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 1 -relief groove
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      #--- Label pour RA
      label $This.frame2.ent1 -font $audace(font,arial_10_b) -textvariable audace(telescope,getra)
      pack $This.frame2.ent1 -in $This.frame2 -anchor center -fill none -pady 1

      #--- Label pour DEC
      label $This.frame2.ent2 -font $audace(font,arial_10_b) -textvariable audace(telescope,getdec)
      pack $This.frame2.ent2 -in $This.frame2 -anchor center -fill none -pady 1

      set zone(radec) $This.frame2
      bind $zone(radec) <ButtonPress-1>      { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      #--- Create the button 'N'
      frame $This.frame3.n -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.n -in $This.frame3 -side top -fill x

      #--- Button-design 'N'
      button $This.frame3.n.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,nord)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.n.canv1 -in $This.frame3.n -expand 0 -side top -padx 10 -pady 4

      #--- Create the buttons 'E W'
      frame $This.frame3.we -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.we -in $This.frame3 -side top -fill x

      #--- Button-design 'E'
      button $This.frame3.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,est)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv1 -in $This.frame3.we -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed
      label $This.frame3.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
         -borderwidth 0 -relief flat
      pack $This.frame3.we.lab -in $This.frame3.we -expand 1 -side left

      #--- Button-design 'W'
      button $This.frame3.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,ouest)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv2 -in $This.frame3.we -expand 0 -side right -padx 10 -pady 4

      #--- Create the button 'S'
      frame $This.frame3.s -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.s -in $This.frame3 -side top -fill x

      #--- Button-design 'S'
      button $This.frame3.s.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,sud)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.s.canv1 -in $This.frame3.s -expand 0 -side top -padx 10 -pady 4

      set zone(n) $This.frame3.n.canv1
      set zone(e) $This.frame3.we.canv1
      set zone(w) $This.frame3.we.canv2
      set zone(s) $This.frame3.s.canv1

      #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
      if { [::telescope::possedeControleSuivi] == "1" } {
         label $This.frame3.s.lab1 \
            -font $audace(font,arial_10_b) -textvariable audace(telescope,controle) \
            -borderwidth 0 -relief flat
         pack $This.frame3.s.lab1 -in $This.frame3.s -expand 1 -side left
         bind $This.frame3.s.lab1 <ButtonPress-1> { ::telescope::controleSuivi }
      }

      #--- Binding de la vitesse du telescope
      bind $This.frame3.we.lab <ButtonPress-1> { ::telescope::incrementSpeed }

      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1>   { catch { ::telescope::move e } }
      bind $zone(e) <ButtonRelease-1> { ::telescope::stop e }
      bind $zone(w) <ButtonPress-1>   { catch { ::telescope::move w } }
      bind $zone(w) <ButtonRelease-1> { ::telescope::stop w }
      bind $zone(s) <ButtonPress-1>   { catch { ::telescope::move s } }
      bind $zone(s) <ButtonRelease-1> { ::telescope::stop s }
      bind $zone(n) <ButtonPress-1>   { catch { ::telescope::move n } }
      bind $zone(n) <ButtonRelease-1> { ::telescope::stop n }

      #--- Label pour moteur focus
      label $This.frame4.lab1 -text $caption(telpad,moteur_foc) -relief flat
      pack $This.frame4.lab1 -in $This.frame4 -anchor center -fill none -padx 4 -pady 1

      #--- Create the buttons '- +'
      frame $This.frame4.we -width 27 -borderwidth 0 -relief flat
      pack $This.frame4.we -in $This.frame4 -side top -fill x

      #--- Button '-'
      button $This.frame4.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "-" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame4.we.canv1 -in $This.frame4.we -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed for LX200 and compatibles
      label $This.frame4.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(focus,labelspeed) -width 2 \
         -borderwidth 0 -relief flat
      pack $This.frame4.we.lab -in $This.frame4.we -expand 1 -side left

      #--- Button '+'
      button $This.frame4.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "+" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame4.we.canv2 -in $This.frame4.we -expand 0 -side right -padx 10 -pady 4

      set zone(moins) $This.frame4.we.canv1
      set zone(plus)  $This.frame4.we.canv2

      #--- Binding de la vitesse du moteur de focalisation
      bind $This.frame4.we.lab <ButtonPress-1> { ::focus::incrementSpeed $::conf(telpad,focuserLabel) pad }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { catch { ::focus::move $::conf(telpad,focuserLabel) - } }
      bind $zone(moins) <ButtonRelease-1> { ::focus::move $::conf(telpad,focuserLabel) stop }
      bind $zone(plus)  <ButtonPress-1>   { catch { ::focus::move $::conf(telpad,focuserLabel) + } }
      bind $zone(plus)  <ButtonRelease-1> { ::focus::move $::conf(telpad,focuserLabel) stop }

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
  }

}

