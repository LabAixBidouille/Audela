#
# Fichier : telpad.tcl
# Description : Raquette simplifiee a l'usage des telescopes
# Auteur : Robert DELMAS
# Mise a jour $Id: telpad.tcl,v 1.19 2008-12-20 22:21:16 robertdelmas Exp $
#

namespace eval telpad {
   package provide telpad 1.0
   package require audela 1.4.0
   source [ file join [file dirname [info script]] telpad.cap ]

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

      return "$caption(telpad,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "telpad.htm"
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
      global conf

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

      set conf(telpad,focuserLabel) $widget(focuserLabel)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Frame pour le choix du focuser
      frame $frm.frame1 -borderwidth 0 -relief raised

         ::confEqt::createFrameFocuser $frm.frame1.focuser ::telpad::widget(focuserLabel)
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
      global audace conf

      #--- Creation du focuser
      if { $conf(superpad,focuserLabel) != "" } {
         ::$conf(superpad,focuserLabel)::createPlugin
      }

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
      if { [ info exists This ] == 1 } {
         if { [ winfo exists $This ] == 1 } {
            set conf(telpad,wmgeometry) [ wm geometry $This ]
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
   #  run this
   #     cree la fenetre de la raquette
   #     this = chemin de la fenetre
   #------------------------------------------------------------
   proc run { { this } } {
      variable This

      set This $this
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
      frame $This.frame1 -borderwidth 1 -relief groove
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief groove
      pack $This.frame2 -side top -fill both -expand 1

      frame $This.frame3 -borderwidth 1 -relief groove
      pack $This.frame3 -side top -fill both -expand 1

      #--- Label pour RA
      label $This.frame1.ent1 -textvariable audace(telescope,getra)
      pack $This.frame1.ent1 -anchor center -fill none -pady 1

      #--- Label pour DEC
      label $This.frame1.ent2 -textvariable audace(telescope,getdec)
      pack $This.frame1.ent2 -anchor center -fill none -pady 1

      set zone(radec) $This.frame1
      bind $zone(radec) <ButtonPress-1>      { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      #--- Create the button 'N'
      frame $This.frame2.n -width 27 -borderwidth 0 -relief flat
      pack $This.frame2.n -side top -fill x

      #--- Button-design 'N'
      button $This.frame2.n.canv1 -borderwidth 2 \
         -font $audace(font,arial_12_b) \
         -text "$caption(telpad,nord)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.n.canv1 -expand 0 -side top -padx 10 -pady 4

      #--- Create the buttons 'E W'
      frame $This.frame2.we -width 27 -borderwidth 0 -relief flat
      pack $This.frame2.we -side top -fill x

      #--- Button-design 'E'
      button $This.frame2.we.canv1 -borderwidth 2 \
         -font $audace(font,arial_12_b) \
         -text "$caption(telpad,est)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.we.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed
      label $This.frame2.we.lab -font $audace(font,arial_12_b) -textvariable audace(telescope,labelspeed) \
         -borderwidth 0 -relief flat
      pack $This.frame2.we.lab -expand 1 -side left

      #--- Button-design 'W'
      button $This.frame2.we.canv2 -borderwidth 2 \
         -font $audace(font,arial_12_b) \
         -text "$caption(telpad,ouest)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.we.canv2 -expand 0 -side right -padx 10 -pady 4

      #--- Create the button 'S'
      frame $This.frame2.s -width 27 -borderwidth 0 -relief flat
      pack $This.frame2.s -side top -fill x

      #--- Button-design 'S'
      button $This.frame2.s.canv1 -borderwidth 2 \
         -font $audace(font,arial_12_b) \
         -text "$caption(telpad,sud)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame2.s.canv1 -expand 0 -side top -padx 10 -pady 4

      set zone(n) $This.frame2.n.canv1
      set zone(e) $This.frame2.we.canv1
      set zone(w) $This.frame2.we.canv2
      set zone(s) $This.frame2.s.canv1

      #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
      if { [ ::confTel::getPluginProperty hasControlSuivi ] == "1" } {
         label $This.frame2.s.lab1 -textvariable audace(telescope,controle) -borderwidth 0 -relief flat
         pack $This.frame2.s.lab1 -expand 1 -side left
         bind $This.frame2.s.lab1 <ButtonPress-1> { ::telescope::controleSuivi }
      }

      #--- Binding de la vitesse du telescope
      bind $This.frame2.we.lab <ButtonPress-1> { ::telescope::incrementSpeed }

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
      label $This.frame3.lab1 -text $caption(telpad,moteur_foc) -relief flat
      pack $This.frame3.lab1 -anchor center -fill none -padx 4 -pady 1

      #--- Create the buttons '- +'
      frame $This.frame3.we -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.we -side top -fill x

      #--- Button '-'
      button $This.frame3.we.canv1 -borderwidth 2 \
         -font $audace(font,arial_12_b) \
         -text "-" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed for LX200 and compatibles
      label $This.frame3.we.lab -font $audace(font,arial_12_b) -textvariable audace(focus,labelspeed) \
         -width 2 -borderwidth 0 -relief flat
      pack $This.frame3.we.lab -expand 1 -side left

      #--- Button '+'
      button $This.frame3.we.canv2 -borderwidth 2 \
         -font $audace(font,arial_12_b) \
         -text "+" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv2 -expand 0 -side right -padx 10 -pady 4

      set zone(moins) $This.frame3.we.canv1
      set zone(plus)  $This.frame3.we.canv2

      #--- Binding de la vitesse du moteur de focalisation
      bind $This.frame3.we.lab <ButtonPress-1> { ::focus::incrementSpeed $::conf(telpad,focuserLabel) pad }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { catch { ::focus::move $::conf(telpad,focuserLabel) - } }
      bind $zone(moins) <ButtonRelease-1> { ::focus::move $::conf(telpad,focuserLabel) stop }
      bind $zone(plus)  <ButtonPress-1>   { catch { ::focus::move $::conf(telpad,focuserLabel) + } }
      bind $zone(plus)  <ButtonRelease-1> { ::focus::move $::conf(telpad,focuserLabel) stop }

      #--- Initialise et affiche la vitesse du focuser
      ::focus::setSpeed "$conf(superpad,focuserLabel)" "0"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

