#
# Fichier : zadkopad.tcl
# Description : Raquette virtuelle du LX200
# Auteur : Alain KLOTZ
# Mise a jour $Id: zadkopad.tcl,v 1.1 2009-09-02 04:14:58 myrtillelaas Exp $
#

namespace eval ::zadkopad {
   package provide zadkopad 1.0
   package require audela 1.4.0
   source [ file join [file dirname [info script]] zadkopad.cap ]

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

      return "$caption(zadkopad,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "zadkopad.htm"
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

      if { ! [ info exists conf(zadkopad,padsize) ] }  { set conf(zadkopad,padsize)  "0.6" }
      if { ! [ info exists conf(zadkopad,position) ] } { set conf(zadkopad,position) "657+252" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(padsize) $conf(zadkopad,padsize)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(zadkopad,padsize) $widget(padsize)
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

      #--- Frame de la taille de la raquette
      frame $frm.frame1 -borderwidth 0 -relief raised

         #--- Label de la taille de la raquette
         label $frm.frame1.labSize -text "$caption(zadkopad,pad_size)"
         pack $frm.frame1.labSize -anchor nw -side left -padx 10 -pady 10

         #--- Definition de la taille de la raquette
         set list_combobox [ list 0.5 0.6 0.7 0.8 0.9 1.0 ]
         ComboBox $frm.frame1.taille \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [llength $list_combobox ] \
            -relief sunken           \
            -borderwidth 1           \
            -editable 0              \
            -textvariable ::zadkopad::widget(padsize) \
            -values $list_combobox
         pack $frm.frame1.taille -anchor nw -side left -padx 10 -pady 10

      pack $frm.frame1 -side top -fill both -expand 0

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
      global conf

      #--- Affiche la raquette
      zadkopad::run $conf(zadkopad,padsize) $conf(zadkopad,position)

      #--- Je demarre la surveillance de audace(telescope,speed)
      ::telescope::addSpeedListener ::zadkopad::surveilleSpeed

      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      global audace conf

      if { [ winfo exists .zadkopad ] } {
         #--- Enregistre la position de la raquette
         set geom [wm geometry .zadkopad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(zadkopad,position) [string range $geom $deb $fin]
      }

      #--- J'arrete la surveillance de audace(telescope,speed)
      ::telescope::removeSpeedListener ::zadkopad::surveilleSpeed

      #--- Supprime la raquette
      destroy .zadkopad

      return
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
   proc run { {zoom .5} {positionxy 0+0} } {
      variable widget
      global audace caption color geomlx200 statustel zonelx200

      if { [ string length [ info commands .zadkopad.display* ] ] != "0" } {
         destroy .zadkopad
      }

      if { $zoom <= "0" } {
         destroy .zadkopad
         return
      }

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      set statustel(speed) "0"

      #--- Definition of colorlx200s
      #--- Definition des couleurs
      set colorlx200(backkey)  $color(gray_pad)
      set colorlx200(backpad)  $color(blue_pad)
      set colorlx200(backdisp) $color(red_pad)
      set colorlx200(textkey)  $color(white)
      set colorlx200(textdisp) $color(black)

      #--- Definition des geomlx200etries
      #--- Definition of geometry
      set geomlx200(larg)       [ expr int(900*$zoom) ]
      set geomlx200(long)       [ expr int(810*$zoom+40) ]
      set geomlx200(fontsize25) [ expr int(25*$zoom) ]
      set geomlx200(fontsize20) [ expr int(20*$zoom) ]
      set geomlx200(fontsize16) [ expr int(16*$zoom) ]
      set geomlx200(fontsize14) [ expr int(14*$zoom) ]
      set geomlx200(fontsize10) [ expr int(10*$zoom) ]
      set geomlx200(10pixels)   [ expr int(10*$zoom) ]
      set geomlx200(20pixels)   [ expr int(20*$zoom) ]
      set geomlx200(larg2)      [ expr int(85*$zoom) ]
      set geomlx200(haut2)      [ expr int(65*$zoom) ]
      set geomlx200(haut)       [ expr int(70*$zoom) ]
      set geomlx200(linewidth0) [ expr int(3*$zoom) ]
      set geomlx200(linewidth)  [ expr int($geomlx200(linewidth0)+1) ]
      set geomlx200(lightx1)    [ expr int(10*$zoom) ]
      set geomlx200(lighty1)    [ expr int(30*$zoom) ]
      set geomlx200(lightx2)    [ expr int(20*$zoom) ]
      set geomlx200(lighty2)    [ expr int(40*$zoom) ]
      if { $geomlx200(linewidth0) <= "1" } { set geomlx200(textthick) "" } else { set geomlx200(textthick) "bold" }

      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .zadkopad de niveau le plus haut
      toplevel .zadkopad -class Toplevel -bg $colorlx200(backpad)
      wm geometry .zadkopad $geomlx200(larg)x$geomlx200(long)+$positionxy
      wm resizable .zadkopad 0 0
      wm title .zadkopad $caption(zadkopad,titre)
      wm protocol .zadkopad WM_DELETE_WINDOW "::zadkopad::deletePluginInstance"

      #--- Create the title
      #--- Cree le titre
      label .zadkopad.meade \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text Meade \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .zadkopad.meade \
         -in .zadkopad -fill x -side top

      frame .zadkopad.display \
         -borderwidth 4  -relief sunken \
         -bg $colorlx200(backdisp)
      pack .zadkopad.display -in .zadkopad \
         -fill x -side top \
         -pady $geomlx200(10pixels) -padx 12

      #--- Label pour RA
      label .zadkopad.display.ra \
         -font [ list {Courier} $geomlx200(fontsize20) $geomlx200(textthick) ] \
         -textvariable audace(telescope,getra) -bg $colorlx200(backdisp) \
         -fg $colorlx200(textdisp) -relief flat -height 1 -width 12
      pack .zadkopad.display.ra -in .zadkopad.display -anchor center -pady 0

      #--- Label pour DEC
      label .zadkopad.display.dec \
         -font [ list {Courier} $geomlx200(fontsize20) $geomlx200(textthick) ] \
         -textvariable audace(telescope,getdec) -bg $colorlx200(backdisp) \
         -fg $colorlx200(textdisp) -relief flat -height 1 -width 12
      pack .zadkopad.display.dec -in .zadkopad.display -anchor center -pady 0

      #--- Refreach the coordinates on the display
      bind .zadkopad.display.ra  <ButtonPress-1> { ::telescope::afficheCoord }
      bind .zadkopad.display.dec <ButtonPress-1> { ::telescope::afficheCoord }
      bind .zadkopad.display     <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Create a dummy space
      #--- Cree un espace inutile
      frame .zadkopad.dum1 \
         -height $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.dum1 \
         -in .zadkopad -side top -fill x

      #--- Create a frame for the function buttons
      #--- Cree un espace pour les boutons de fonction
      frame .zadkopad.func \
         -height 70 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.func \
         -in .zadkopad -side top -fill x

      #--- Create the button 'enter'
      frame .zadkopad.func.enter \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.func.enter \
         -in .zadkopad.func -side left

      #--- Button-design
      canvas .zadkopad.func.enter.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.func.enter.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.func.enter.canv1 \
         -in .zadkopad.func.enter -expand 1
      #--- Write the label
      label .zadkopad.func.enter.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text ENTER \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.func.enter.canv1.lab \
         -in .zadkopad.func.enter.canv1 -x [ expr int(11*$zoom) ] -y [ expr int(22*$zoom) ]

      #--- Create the button 'go to'
      frame .zadkopad.func.goto \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.func.goto \
         -in .zadkopad.func -side right
      #--- Button-design
      canvas .zadkopad.func.goto.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.func.goto.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.func.goto.canv1 \
         -in .zadkopad.func.goto -expand 1
      #--- Write the label
      label .zadkopad.func.goto.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text "GO TO" \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.func.goto.canv1.lab \
         -in .zadkopad.func.goto.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(22*$zoom) ]

      #--- Create the button 'mode'
      frame .zadkopad.func.mode \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.func.mode \
         -in .zadkopad.func -side top
      #--- Button-design
      canvas .zadkopad.func.mode.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.func.mode.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.func.mode.canv1 \
         -in .zadkopad.func.mode -expand 1
      #--- Write the label
      label .zadkopad.func.mode.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text MODE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.func.mode.canv1.lab \
         -in .zadkopad.func.mode.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(22*$zoom) ]

      #--- Create a frame for the cardinal buttons
      #--- Cree un espace pour les boutons cardinaux
      frame .zadkopad.card \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card \
         -in .zadkopad -side top -fill x

      #--- Create a dummy space
      #--- Cree un espace inutile
      frame .zadkopad.card.dumw \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card.dumw \
         -in .zadkopad.card -side left -fill y

      #--- Create the button 'W'
      set geomlx200(larg2) $geomlx200(haut2)
      frame .zadkopad.card.w \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card.w \
         -in .zadkopad.card -side left
      #--- Button-design
      canvas .zadkopad.card.w.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.card.w.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.card.w.canv1 \
         -in .zadkopad.card.w -expand 1
      #--- Write the label
      label .zadkopad.card.w.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text W \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.card.w.canv1.lab \
         -in .zadkopad.card.w.canv1 -x [ expr int(17*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(w) .zadkopad.card.w.canv1

      #--- Create a dummy space
      #--- Cree un espace inutile
      frame .zadkopad.card.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card.dume \
         -in .zadkopad.card -side right -fill y

      #--- Create the button 'E'
      frame .zadkopad.card.e \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card.e \
         -in .zadkopad.card -side right
      #--- Button-design
      canvas .zadkopad.card.e.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.card.e.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.card.e.canv1 \
         -in .zadkopad.card.e -expand 1
      #--- Write the label
      label .zadkopad.card.e.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text E \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.card.e.canv1.lab \
         -in .zadkopad.card.e.canv1 -x [ expr int(22*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(e) .zadkopad.card.e.canv1

      #--- Create the button 'N'
      frame .zadkopad.card.n \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card.n \
         -in .zadkopad.card -side top
      #--- Button-design
      canvas .zadkopad.card.n.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.card.n.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.card.n.canv1 \
         -in .zadkopad.card.n -expand 1
      #--- Write the label
      label .zadkopad.card.n.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text N \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.card.n.canv1.lab \
         -in .zadkopad.card.n.canv1 -x [ expr int(22*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(n) .zadkopad.card.n.canv1

      #--- Create the button 'S'
      frame .zadkopad.card.s \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.card.s \
         -in .zadkopad.card -side top
      #--- Button-design
      canvas .zadkopad.card.s.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.card.s.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.card.s.canv1 \
         -in .zadkopad.card.s -expand 1
      #--- Write the label
      label .zadkopad.card.s.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text S \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.card.s.canv1.lab \
         -in .zadkopad.card.s.canv1 -x [ expr int(22*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(s) .zadkopad.card.s.canv1

      #--- Create a frame for the 789 buttons
      #--- Cree un espace pour les boutons 789
      frame .zadkopad.789 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.789 \
         -in .zadkopad -side top -fill x

      #--- Create the light 'slew'
      frame .zadkopad.789.slew \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $color(green)
      pack .zadkopad.789.slew \
         -in .zadkopad.789 -side left -fill y
      canvas .zadkopad.789.slew.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.789.slew.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
      $geomlx200(lighty2) -fill $color(black)
      pack .zadkopad.789.slew.canv1 \
         -in .zadkopad.789.slew -expand 1
      set zonelx200(slew) .zadkopad.789.slew.canv1

      #--- Create the button '7'
      frame .zadkopad.789.7 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.789.7 \
         -in .zadkopad.789 -side left
      #--- Button-design
      canvas .zadkopad.789.7.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.789.7.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.789.7.canv1 \
         -in .zadkopad.789.7 -expand 1
      #--- Write the label
      label .zadkopad.789.7.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 7 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.789.7.canv1.lab1 \
         -in .zadkopad.789.7.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.789.7.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text SLEW \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.789.7.canv1.lab2 \
         -in .zadkopad.789.7.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(7) .zadkopad.789.7.canv1

      #--- Create a dummy frame
      frame .zadkopad.789.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.789.dume \
         -in .zadkopad.789 -side right -fill y

      #--- Create the button '9'
      frame .zadkopad.789.9 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.789.9 \
         -in .zadkopad.789 -side right
      #--- Button-design
      canvas .zadkopad.789.9.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.789.9.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.789.9.canv1 \
         -in .zadkopad.789.9 -expand 1
      #--- Write the label
      label .zadkopad.789.9.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 9 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.789.9.canv1.lab1 \
         -in .zadkopad.789.9.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.789.9.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text M \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.789.9.canv1.lab2 \
         -in .zadkopad.789.9.canv1 -x [ expr int(28*$zoom) ] -y [ expr int(10*$zoom) ]

      #--- Create the button '8'
      frame .zadkopad.789.8 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.789.8 \
         -in .zadkopad.789 -side top
      #--- Button-design
      canvas .zadkopad.789.8.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.789.8.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.789.8.canv1 \
         -in .zadkopad.789.8 -expand 1
      #--- Write the label
      label .zadkopad.789.8.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 8 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.789.8.canv1.lab1 \
         -in .zadkopad.789.8.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.789.8.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text RET \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.789.8.canv1.lab2 \
         -in .zadkopad.789.8.canv1 -x [ expr int(20*$zoom) ] -y [ expr int(10*$zoom) ]

      #--- Create a frame for the 456 buttons
      #--- Cree un espace pour les boutons 456
      frame .zadkopad.456 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.456 \
         -in .zadkopad -side top -fill x

      #--- Create the light 'find'
      frame .zadkopad.456.find \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $color(red)
      pack .zadkopad.456.find \
         -in .zadkopad.456 -side left -fill y
      canvas .zadkopad.456.find.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.456.find.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
         $geomlx200(lighty2) -fill $color(black)
      pack .zadkopad.456.find.canv1 \
         -in .zadkopad.456.find -expand 1
      set zonelx200(find) .zadkopad.456.find.canv1

      #--- Create the button '4'
      frame .zadkopad.456.4 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.456.4 \
         -in .zadkopad.456 -side left
      #--- Button-design
      canvas .zadkopad.456.4.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.456.4.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.456.4.canv1 \
         -in .zadkopad.456.4 -expand 1

      #--- Write the label
      label .zadkopad.456.4.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 4 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.456.4.canv1.lab1 \
         -in .zadkopad.456.4.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.456.4.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text FIND \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.456.4.canv1.lab2 \
         -in .zadkopad.456.4.canv1 -x [ expr int(18*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(4) .zadkopad.456.4.canv1

      #--- Create a dummy frame
      frame .zadkopad.456.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.456.dume \
         -in .zadkopad.456 -side right -fill y

      #--- Create the button '6'
      frame .zadkopad.456.6 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.456.6 \
         -in .zadkopad.456 -side right
      #--- Button-design
      canvas .zadkopad.456.6.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.456.6.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.456.6.canv1 \
         -in .zadkopad.456.6 -expand 1
      #--- Write the label
      label .zadkopad.456.6.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 6 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.456.6.canv1.lab1 \
         -in .zadkopad.456.6.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.456.6.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text STAR \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.456.6.canv1.lab2 \
         -in .zadkopad.456.6.canv1 -x [ expr int(16*$zoom) ] -y [ expr int(10*$zoom) ]

      #--- Create the button '5'
      frame .zadkopad.456.5 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.456.5 \
         -in .zadkopad.456 -side top
      #--- Button-design
      canvas .zadkopad.456.5.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.456.5.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.456.5.canv1 \
         -in .zadkopad.456.5 -expand 1
      #--- Write the label
      label .zadkopad.456.5.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 5 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.456.5.canv1.lab1 \
         -in .zadkopad.456.5.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.456.5.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text FOCUS \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.456.5.canv1.lab2 \
         -in .zadkopad.456.5.canv1 -x [ expr int(10*$zoom) ] -y [ expr int(10*$zoom) ]

      #--- Create a frame for the 123 buttons
      #--- Cree un espace pour les boutons 123
      frame .zadkopad.123 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.123 \
         -in .zadkopad -side top -fill x

      #--- Create the light 'cntr'
      frame .zadkopad.123.cntr \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.123.cntr \
         -in .zadkopad.123 -side left -fill y
      canvas .zadkopad.123.cntr.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.123.cntr.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
         $geomlx200(lighty2) -fill $color(black)
      pack .zadkopad.123.cntr.canv1 \
         -in .zadkopad.123.cntr -expand 1
      set zonelx200(cntr) .zadkopad.123.cntr.canv1

      #--- Create the button '1'
      set larg2 65
      set haut2 65
      frame .zadkopad.123.1 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.123.1 \
         -in .zadkopad.123 -side left
      #--- Button-design
      canvas .zadkopad.123.1.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.123.1.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.123.1.canv1 \
         -in .zadkopad.123.1 -expand 1
      #--- Write the label
      label .zadkopad.123.1.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 1 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.123.1.canv1.lab1 \
         -in .zadkopad.123.1.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.123.1.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text CNTR \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.123.1.canv1.lab2 \
         -in .zadkopad.123.1.canv1 -x [ expr int(16*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(1) .zadkopad.123.1.canv1

      #--- Create a dummy frame
      frame .zadkopad.123.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.123.dume \
         -in .zadkopad.123 -side right -fill y

      #--- Create the button '3'
      frame .zadkopad.123.3 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.123.3 \
         -in .zadkopad.123 -side right
      #--- Button-design
      canvas .zadkopad.123.3.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.123.3.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.123.3.canv1 \
         -in .zadkopad.123.3 -expand 1
      #--- Write the label
      label .zadkopad.123.3.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 3 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.123.3.canv1.lab1 \
         -in .zadkopad.123.3.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.123.3.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text CNGC \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.123.3.canv1.lab2 \
         -in .zadkopad.123.3.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(10*$zoom) ]

      #--- Create the button '2'
      frame .zadkopad.123.2 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.123.2 \
         -in .zadkopad.123 -side top
      #--- Button-design
      canvas .zadkopad.123.2.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.123.2.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.123.2.canv1 \
         -in .zadkopad.123.2 -expand 1
      #--- Write the label
      label .zadkopad.123.2.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 2 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.123.2.canv1.lab1 \
         -in .zadkopad.123.2.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.123.2.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text MAP \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.123.2.canv1.lab2 \
         -in .zadkopad.123.2.canv1 -x [ expr int(19*$zoom) ] -y [ expr int(10*$zoom) ]

      #--- Create a frame for the 000 buttons
      #--- Cree un espace pour les boutons 000
      frame .zadkopad.000 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.000 \
         -in .zadkopad -side top -fill x

      #--- Create the light 'guide'
      frame .zadkopad.000.guide \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.000.guide \
         -in .zadkopad.000 -side left -fill y
      canvas .zadkopad.000.guide.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.000.guide.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
         $geomlx200(lighty2) -fill $color(red)
      pack .zadkopad.000.guide.canv1 \
         -in .zadkopad.000.guide -expand 1
      set zonelx200(guide) .zadkopad.000.guide.canv1

      #--- Create the button '0'
      set larg2 65
      set haut2 65
      frame .zadkopad.000.0 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.000.0 \
         -in .zadkopad.000 -side left
      #--- Button-design
      canvas .zadkopad.000.0.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.000.0.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.000.0.canv1 \
         -in .zadkopad.000.0 -expand 1
      #--- Write the label
      label .zadkopad.000.0.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 0 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.000.0.canv1.lab1 \
         -in .zadkopad.000.0.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.000.0.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text GUIDE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.000.0.canv1.lab2 \
         -in .zadkopad.000.0.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(0) .zadkopad.000.0.canv1

      #--- Create a dummy frame
      frame .zadkopad.000.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.000.dume \
         -in .zadkopad.000 -side right -fill y

      #--- Create the button 'next'
      frame .zadkopad.000.next \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.000.next \
         -in .zadkopad.000 -side right
      #--- Button-design
      canvas .zadkopad.000.next.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.000.next.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth)
      pack .zadkopad.000.next.canv1 \
         -in .zadkopad.000.next -expand 1
      #--- Write the label
      label .zadkopad.000.next.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text " " \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.000.next.canv1.lab1 \
         -in .zadkopad.000.next.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.000.next.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text NEXT \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.000.next.canv1.lab2 \
         -in .zadkopad.000.next.canv1 -x [ expr int(16*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(next) .zadkopad.000.next.canv1

      #--- Create the button 'prev'
      frame .zadkopad.000.prev \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.000.prev \
         -in .zadkopad.000 -side top
      #--- Button-design
      canvas .zadkopad.000.prev.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .zadkopad.000.prev.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .zadkopad.000.prev.canv1 \
         -in .zadkopad.000.prev -expand 1
      #--- Write the label
      label .zadkopad.000.prev.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text " " \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.000.prev.canv1.lab1 \
         -in .zadkopad.000.prev.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .zadkopad.000.prev.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text PREV \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .zadkopad.000.prev.canv1.lab2 \
         -in .zadkopad.000.prev.canv1 -x [ expr int(15*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(prev) .zadkopad.000.prev.canv1

      #--- La fenetre est active
      focus .zadkopad

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .zadkopad <Key-F1> { ::console::GiveFocus }

      # =========================================
      # === Setting the binding
      # === Met en place les liaisons
      # =========================================

      # ========================================
      # === Setting the astronomical devices ===
      # ========================================

      if { [ string compare $audace(telNo) 0 ] != "0" } {
         #--- Cardinal moves
         bind $zonelx200(e) <ButtonPress-1>       { ::telescope::move e }
         bind $zonelx200(e).lab <ButtonPress-1>   { ::telescope::move e }
         bind $zonelx200(e) <ButtonRelease-1>     { ::telescope::stop e }
         bind $zonelx200(e).lab <ButtonRelease-1> { ::telescope::stop e }

         bind $zonelx200(w) <ButtonPress-1>       { ::telescope::move w }
         bind $zonelx200(w).lab <ButtonPress-1>   { ::telescope::move w }
         bind $zonelx200(w) <ButtonRelease-1>     { ::telescope::stop w }
         bind $zonelx200(w).lab <ButtonRelease-1> { ::telescope::stop w }

         bind $zonelx200(s) <ButtonPress-1>       { ::telescope::move s }
         bind $zonelx200(s).lab <ButtonPress-1>   { ::telescope::move s }
         bind $zonelx200(s) <ButtonRelease-1>     { ::telescope::stop s }
         bind $zonelx200(s).lab <ButtonRelease-1> { ::telescope::stop s }

         bind $zonelx200(n) <ButtonPress-1>       { ::telescope::move n }
         bind $zonelx200(n).lab <ButtonPress-1>   { ::telescope::move n }
         bind $zonelx200(n) <ButtonRelease-1>     { ::telescope::stop n }
         bind $zonelx200(n).lab <ButtonRelease-1> { ::telescope::stop n }

         #--- Focus moves
         bind $zonelx200(next) <ButtonPress-1> { tel$audace(telNo) focus move + $statustel(speed) }
         bind $zonelx200(next).lab1 <ButtonPress-1> { tel$audace(telNo) focus move + $statustel(speed) }
         bind $zonelx200(next) <ButtonRelease-1> { tel$audace(telNo) focus stop }
         bind $zonelx200(next).lab1 <ButtonRelease-1> { tel$audace(telNo) focus stop }
         bind $zonelx200(prev) <ButtonPress-1> { tel$audace(telNo) focus move - $statustel(speed) }
         bind $zonelx200(prev).lab1 <ButtonPress-1> { tel$audace(telNo) focus move - $statustel(speed) }
         bind $zonelx200(prev) <ButtonRelease-1> { tel$audace(telNo) focus stop }
         bind $zonelx200(prev).lab1 <ButtonRelease-1> { tel$audace(telNo) focus stop }

         #--- Set speeds
         bind $zonelx200(7) <ButtonPress-1>      {::telescope::setSpeed "4"}
         bind $zonelx200(7).lab1 <ButtonPress-1> {::telescope::setSpeed "4"}
         bind $zonelx200(7).lab2 <ButtonPress-1> {::telescope::setSpeed "4"}

         bind $zonelx200(4) <ButtonPress-1>      {::telescope::setSpeed "3"}
         bind $zonelx200(4).lab1 <ButtonPress-1> {::telescope::setSpeed "3"}
         bind $zonelx200(4).lab2 <ButtonPress-1> {::telescope::setSpeed "3"}

         bind $zonelx200(1) <ButtonPress-1>      {::telescope::setSpeed "2"}
         bind $zonelx200(1).lab1 <ButtonPress-1> {::telescope::setSpeed "2"}
         bind $zonelx200(1).lab2 <ButtonPress-1> {::telescope::setSpeed "2"}

         bind $zonelx200(0) <ButtonPress-1>      {::telescope::setSpeed "1"}
         bind $zonelx200(0).lab1 <ButtonPress-1> {::telescope::setSpeed "1"}
         bind $zonelx200(0).lab2 <ButtonPress-1> {::telescope::setSpeed "1"}
      }

      #--- Je refraichi l'affichage des coordonnees
      ::telescope::afficheCoord

      # =======================================
      # === It is the end of the script run ===
      # =======================================
   }

   #------------------------------------------------------------
   #  surveilleSpeed
   #   surveille les modifications de audace(telescope,speed) en tache de fond
   #   car les canvas qui sont mis a jour en fonction audace(telescope,speed)
   #   ne possedent pas le parametre -textvariable pour se mettre a jour automatiquement
   #
   #  return rien
   #------------------------------------------------------------
   proc surveilleSpeed { args } {
      global audace

      #--- Si la raquette existe, je mets a jour l'affichage de la vitesse
      if { [ winfo exists .zadkopad ] } {
         switch -exact -- $audace(telescope,speed) {
            1 { ::zadkopad::lx200_set_guide }
            2 { ::zadkopad::lx200_set_cntr }
            3 { ::zadkopad::lx200_set_find }
            4 { ::zadkopad::lx200_set_slew }
         }
      }
   }

   #------------------------------------------------------------
   #  lx200_set_slew
   #     affiche la vitesse slew sur la raquette
   #------------------------------------------------------------
   proc lx200_set_slew { } {
      global color zonelx200

      $zonelx200(slew)  itemconfigure 1 -fill $color(red)
      $zonelx200(find)  itemconfigure 1 -fill $color(black)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(black)
      $zonelx200(guide) itemconfigure 1 -fill $color(black)
   }

   #------------------------------------------------------------
   #  lx200_set_find
   #     affiche la vitesse find sur la raquette
   #------------------------------------------------------------
   proc lx200_set_find { } {
      global color zonelx200

      $zonelx200(slew)  itemconfigure 1 -fill $color(black)
      $zonelx200(find)  itemconfigure 1 -fill $color(red)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(black)
      $zonelx200(guide) itemconfigure 1 -fill $color(black)
   }

   #------------------------------------------------------------
   #  lx200_set_cntr
   #     affiche la vitesse cntr sur la raquette
   #------------------------------------------------------------
   proc lx200_set_cntr { } {
      global color zonelx200

      $zonelx200(slew)  itemconfigure 1 -fill $color(black)
      $zonelx200(find)  itemconfigure 1 -fill $color(black)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(red)
      $zonelx200(guide) itemconfigure 1 -fill $color(black)
   }

   #------------------------------------------------------------
   #  lx200_set_guide
   #     affiche la vitesse guide sur la raquette
   #------------------------------------------------------------
   proc lx200_set_guide { } {
      global color zonelx200

      $zonelx200(slew)  itemconfigure 1 -fill $color(black)
      $zonelx200(find)  itemconfigure 1 -fill $color(black)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(black)
      $zonelx200(guide) itemconfigure 1 -fill $color(red)
   }

}

