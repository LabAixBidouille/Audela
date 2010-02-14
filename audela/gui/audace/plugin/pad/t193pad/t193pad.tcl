#
# Fichier : t193pad.tcl
# Description : Raquette specifique au T193 de l'OHP
# Auteur : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: t193pad.tcl,v 1.9 2010-02-14 16:40:33 michelpujol Exp $
#

namespace eval ::t193pad {
   package provide t193pad 1.0
   package require audela 1.4.0
   source [ file join [file dirname [info script]] t193pad.cap ]
}

#------------------------------------------------------------
#  initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::t193pad::initPlugin { } {
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
proc ::t193pad::getPluginProperty { propertyName } {

}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::t193pad::getPluginTitle { } {
   global caption

   return "$caption(t193pad,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::t193pad::getPluginHelp { } {
   return "t193pad.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::t193pad::getPluginType { } {
   return "pad"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::t193pad::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::initConf { } {
   variable private
   global caption conf

   if { ! [ info exists conf(t193pad,wmgeometry) ] }   { set conf(t193pad,wmgeometry)   "240x520+643+180" }
   if { ! [ info exists conf(t193pad,focuserLabel) ] } { set conf(t193pad,focuserLabel) "" }

   set private(targetRa)      "00h00m00.00s"
   set private(targetDec)     "+00d00m00.00s"
   set private(positionDome)  "0"
   set private(synchro)       "1"
   set private(gotoFocus)     0

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::confToWidget { } {
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
proc ::t193pad::widgetToConf { } {
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
proc ::t193pad::fillConfigPage { frm } {
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
proc ::t193pad::createPluginInstance { } {
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
proc ::t193pad::deletePluginInstance { } {
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
proc ::t193pad::isReady { } {
   return 0
}

#==============================================================
# Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  run
#     cree la fenetre de la raquette
#------------------------------------------------------------
proc ::t193pad::run { } {
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
proc ::t193pad::createDialog { } {
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
      wm geometry $This 240x520+643+180
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

   #--- Label pour AD
   label $This.frame1.ent1 -textvariable audace(telescope,getra) \
      -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
   pack $This.frame1.ent1 -anchor center -fill none -pady 1

   #--- Label pour DEC
   label $This.frame1.ent2 -textvariable audace(telescope,getdec) \
      -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
   pack $This.frame1.ent2 -anchor center -fill none -pady 1

   #--- Bind de l'affichage des coordonnees
   bind $This.frame1      <ButtonPress-1> { ::telescope::afficheCoord }
   bind $This.frame1.ent1 <ButtonPress-1> { ::telescope::afficheCoord }
   bind $This.frame1.ent2 <ButtonPress-1> { ::telescope::afficheCoord }

   #--- Frame du bouton 'N'
   frame $This.frame2.n -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
   pack $This.frame2.n -side top -fill x

   #--- Bouton 'N'
   button $This.frame2.n.canv1 -borderwidth 2 \
      -font [ list {Arial} 12 bold ] \
      -fg $color(white) \
      -bg $color(gray_pad) \
      -text "$caption(t193pad,nord)" \
      -width 2 \
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
      -width 2 \
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
      -text $caption(t193pad,ouest) \
      -width 2 \
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
      -text $caption(t193pad,sud) \
      -width 2 \
      -anchor center \
      -relief ridge
   pack $This.frame2.s.canv1 -expand 0 -side top -padx 10 -pady 4

   #--- LabelEntry pour AD
   LabelEntry $This.frame3.ad -label $caption(t193pad,RA) \
      -textvariable ::t193pad::private(targetRa) -width 14 -fg $color(white) \
      -bg $color(blue_pad) -entrybg $color(gray_pad) -justify center \
      -labelwidth 5 \
      -labelfont [ list {Arial} 10 bold ] -font [ list {Arial} 12 bold ]
   pack $This.frame3.ad -anchor center -fill none -pady 2

   #--- LabelEntry pour DEC
   LabelEntry $This.frame3.dec -label $caption(t193pad,DEC) \
      -textvariable ::t193pad::private(targetDec) -width 14 -fg $color(white) \
      -bg $color(blue_pad) -entrybg $color(gray_pad) -justify center \
      -labelwidth 5 \
      -labelfont [ list {Arial} 10 bold ] -font [ list {Arial} 12 bold ]
   pack $This.frame3.dec -anchor center -fill none -pady 2

   #--- Bouton GOTO start
   button $This.frame3.buttonGoto -borderwidth 1 -width 8 \
      -font [ list {Arial} 12 bold ] -text $caption(t193pad,goto) -relief ridge \
      -fg $color(white) -bg $color(gray_pad) -command "::t193pad::cmdStartGoto"
   pack $This.frame3.buttonGoto -anchor center -fill x -expand 1 -side left -padx 4 -pady 2

   #--- Bouton GOTO stop
   button $This.frame3.buttonStopGoto -borderwidth 1 -width 8 \
      -font [ list {Arial} 12 bold ] -text $caption(t193pad,stopGoto) -relief ridge \
      -fg $color(white) -bg $color(gray_pad) -command "::telescope::stopGoto"
   pack $This.frame3.buttonStopGoto -anchor center -fill x -expand 1  -side left -padx 4 -pady 2

   #--- Bind des boutons 'N', 'E', 'O' et 'S'
   set zone(n) $This.frame2.n.canv1
   set zone(e) $This.frame2.we.canv1
   set zone(w) $This.frame2.we.canv2
   set zone(s) $This.frame2.s.canv1
   bind $zone(e) <ButtonPress-1>   { ::telescope::move e }
   bind $zone(e) <ButtonRelease-1> { ::telescope::stop e }
   bind $zone(w) <ButtonPress-1>   { ::telescope::move w }
   bind $zone(w) <ButtonRelease-1> { ::telescope::stop w }
   bind $zone(s) <ButtonPress-1>   { ::telescope::move s }
   bind $zone(s) <ButtonRelease-1> { ::telescope::stop s }
   bind $zone(n) <ButtonPress-1>   { ::telescope::move n }
   bind $zone(n) <ButtonRelease-1> { ::telescope::stop n }

   #--- Bind de la vitesse de la monture
   bind $This.frame2.we.vitesseMonture <ButtonPress-1> { ::telescope::incrementSpeed }

   #--- Frame du FOCUS
   frame $This.focus -borderwidth 1 -relief groove -bg $color(blue_pad)
      #--- Titre pour le moteur de focalisation
      label $This.focus.titre -text $caption(t193pad,moteur_foc) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
      pack $This.focus.titre -anchor center -fill none -padx 4 -pady 1

      #--- Frame pour les boutons '-' et '+' du FOCUS
      frame $This.focus.pm -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
         #--- Bouton '-'
         button $This.focus.pm.buttonMoins -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -fg $color(white) \
            -bg $color(gray_pad) \
            -text "-" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.focus.pm.buttonMoins -expand 0 -side left -padx 10 -pady 4

         #--- Label pour la position de la focalisation courante
         label $This.focus.pm.positionFoc -textvariable ::audace(telescope,currentFocus) \
            -bg $color(blue_pad) -fg $color(white) -font [ list {Arial} 12 bold ] -width 10 \
            -borderwidth 0 -relief flat
         pack $This.focus.pm.positionFoc -expand 1 -side left

         #--- Bouton '+'
         button $This.focus.pm.buttonPlus -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -fg $color(white) \
            -bg $color(gray_pad) \
            -text "+" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.focus.pm.buttonPlus -expand 0 -side right -padx 10 -pady 4

         #--- Bind des boutons '+' et '-'
         bind $This.focus.pm.buttonMoins <ButtonPress-1>   { ::t193pad::startFocus "-" }
         bind $This.focus.pm.buttonMoins <ButtonRelease-1> { ::t193pad::stopFocus }
         bind $This.focus.pm.buttonPlus  <ButtonPress-1>   { ::t193pad::startFocus "+" }
         bind $This.focus.pm.buttonPlus  <ButtonRelease-1> { ::t193pad::stopFocus }


         #--- Label de la vitesse du moteur de focalisation
         ###label $This.focus.vitesseFocus -font [ list {Arial} 12 bold ] \
         ###   -textvariable audace(focus,labelspeed) -bg $color(blue_pad) -fg $color(white) \
         ###   -width 2 -borderwidth 0 -relief flat
         ###pack $This.focus.vitesseFocus -anchor center -fill none -pady 2

      #--- Bind de la vitesse du moteur de focalisation
         ###bind $This.focus.vitesseFocus <ButtonPress-1> { ::focus::incrementSpeed $::conf(t193pad,focuserLabel) pad }

      pack $This.focus.pm -side top -fill x

      #--- Frame pour FOCUS GOTO
      frame $This.focus.goto -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
         #--- Bouton FOCUS GOTO
         button $This.focus.goto.buttonGotoFoc -borderwidth 1 -width 8 \
            -font [ list {Arial} 12 bold ] -text $caption(t193pad,gotoFoc) -relief ridge \
            -fg $color(white) -bg $color(gray_pad) -command "::t193pad::gotoFocus"
         pack $This.focus.goto.buttonGotoFoc -anchor center -fill x -side left -padx 4 -pady 2 -expand 1

         #--- Entry pour la position du GOTO de la focalisation
         Entry $This.focus.goto.positionGotoFoc -textvariable ::t193pad::private(gotoFocus) \
            -width 4 -bg $color(gray_pad) -justify center -font [ list {Arial} 12 bold ]
         pack $This.focus.goto.positionGotoFoc -anchor center -fill x -side left -padx 4 -pady 2 -expand 1

         #--- Bouton FOCUS STOP
         button $This.focus.goto.buttonStopFoc -borderwidth 1 -width 8 \
         -font [ list {Arial} 12 bold ] -text $caption(t193pad,stopFoc) -relief ridge \
         -fg $color(white) -bg $color(gray_pad) -command ::t193pad::stopFocus
         pack $This.focus.goto.buttonStopFoc -anchor center -fill x -side left -padx 4 -pady 2 -expand 1

      pack $This.focus.goto -side top -fill x -expand 1

   pack $This.focus -side top -fill both -expand 1 -pady 4

   #--- Frame du DOME
   frame $This.dome -borderwidth 1 -relief groove -bg $color(blue_pad)
      #--- titre pour le dome
      label $This.dome.titre -text $caption(t193pad,dome) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
      pack $This.dome.titre -anchor center -fill none -padx 4 -pady 1

      #--- Frame pour les boutons '-' et '+'
      frame $This.dome.pm -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.dome.pm -side top -fill x

      #--- Bouton '-'
      button $This.dome.pm.buttonMoins -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "-" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.dome.pm.buttonMoins -expand 0 -side left -padx 10 -pady 4

      #--- Label pour la position du dome
      label $This.dome.pm.positionDome -textvariable ::t193pad::private(positionDome) \
         -bg $color(blue_pad) -fg $color(white) -font [ list {Arial} 12 bold ] -width 10 \
         -borderwidth 0 -relief flat
      pack $This.dome.pm.positionDome -expand 1 -side left

      #--- Bouton '+'
      button $This.dome.pm.buttonPlus -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "+" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.dome.pm.buttonPlus -expand 0 -side right -padx 10 -pady 4

      #--- Checkbutton pour la synchronisation du dome sur la monture
      checkbutton $This.dome.check -text "$caption(t193pad,synchroMonture)" \
         -variable ::t193pad::private(synchro) -bg $color(blue_pad) -fg $color(white) \
         -activebackground $color(blue_pad) -activeforeground $color(white) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -font [ list {Arial} 12 bold ] -command "  "
      pack $This.dome.check -anchor center -fill none -pady 2

   pack $This.dome -side top -fill both -expand 1

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
proc ::t193pad::cmdStartGoto { } {
   variable This
   variable private
   set catchError [catch {
      ::telescope::goto [ list $private(targetRa) $private(targetDec) ] 0 $This.frame3.buttonGoto
   }]
   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

#------------------------------------------------------------
#  startFocus
#     demarre le mouvement du focus du T193
#------------------------------------------------------------
proc ::t193pad::startFocus { direction } {
   variable private

   set catchError [catch {
      tel$::audace(telNo) focus move $direction
   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

#------------------------------------------------------------
#  stopFocus
#     arrete le mouvement du focus du T193
#------------------------------------------------------------
proc ::t193pad::stopFocus {  } {
   variable private

   set catchError [catch {
      tel$::audace(telNo) focus stop
   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

#------------------------------------------------------------
#  gotoFocus
#     lance un goto du focus
#------------------------------------------------------------
proc ::t193pad::gotoFocus {  } {
   variable private

   set catchError [catch {
      #--- format de la commande : tel1 focus goto number ?-rate value? ?-blocking boolean?
      tel$::audace(telNo) focus goto $private(gotoFocus) -blocking 0
   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

