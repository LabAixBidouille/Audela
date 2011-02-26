#
# Fichier : satellite.tcl
# Description : Interfaces graphiques pour les satellites artificiels
# Auteur : Myrtille LAAS-BOUREZ
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace satellite
#    initialise le namespace
#============================================================
namespace eval ::satellite {
   package provide satellite 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] satellite.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::satellite::getPluginTitle { } {
   global caption

   return "$caption(satellite,tle_titre)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::satellite::getPluginHelp { } {
   return "satellite.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::satellite::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::satellite::getPluginDirectory { } {
   return "satellite"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::satellite::getPluginOS { } {
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
proc ::satellite::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "setup" }
      subfunction1 { return "satellite" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::satellite::initPlugin { tkbase } {
}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::satellite::createPluginInstance { { in "" } { visuNo 1 } } {
   variable This
   variable widget
   global audace conf

   #--- Inititalisation du nom de la fenetre
   set This "$audace(base).satellite"

   #--- Initialisation de variables
   set widget(name_sat)       ""
   set widget(name_satcoord)  ""
   set widget(satel_date)     ""
   set widget(coord_gps)      "$audace(posobs,observateur,gps)"
   set widget(satel_ravalue)  "22h07m34s25"
   set widget(satel_decvalue) "+60d17m33s0 "
   set widget(satel_ra)       ""
   set widget(satel_dec)      ""

   #--- Inititalisation de variables de configuration
   if { ! [ info exists conf(satellite,position) ] } { set conf(satellite,position) "+350+50" }
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::satellite::deletePluginInstance { visuNo } {
   variable This

   if { [ winfo exists $This ] } {
      #--- Je ferme la fenetre si l'utilsateur ne l'a pas deja fait
      ::satellite::cmdClose
   }
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::satellite::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::satellite::run
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::satellite::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

#------------------------------------------------------------
# confToWidget
#    Charge les variables de configuration dans des variables locales
#------------------------------------------------------------
proc ::satellite::confToWidget { } {
   variable widget
   global conf

   set widget(satellite,position) "$conf(satellite,position)"
}

#------------------------------------------------------------
# widgetToConf
#    Charge les variables locales dans des variables de configuration
#------------------------------------------------------------
proc ::satellite::widgetToConf { } {
   variable widget
   global conf

   set conf(satellite,position) "$widget(satellite,position)"
}

#------------------------------------------------------------
# recupPosition
#    Recupere la position de la fenetre
#------------------------------------------------------------
proc ::satellite::recupPosition { } {
   variable This
   variable widget

   set widget(geometry) [ wm geometry $This ]
   set deb [ expr 1 + [ string first + $widget(geometry) ] ]
   set fin [ string length $widget(geometry) ]
   set widget(satellite,position) "+[string range $widget(geometry) $deb $fin]"
   #---
   ::satellite::widgetToConf
}

#------------------------------------------------------------
# run
#    Lance la boite de dialogue
#------------------------------------------------------------
proc ::satellite::run { } {
   variable This
   variable widget

   #---
   ::satellite::confToWidget
   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   } else {
      if { [ info exists widget(geometry) ] } {
         set deb [ expr 1 + [ string first + $widget(geometry) ] ]
         set fin [ string length $widget(geometry) ]
         set widget(satellite,position) "+[string range $widget(geometry) $deb $fin]"
      }
      ::satellite::createDialog
   }
}

#------------------------------------------------------------
# createDialog
#    Creation de l'interface graphique
#------------------------------------------------------------
proc ::satellite::createDialog { } {
   variable This
   variable widget
   global caption

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm resizable $This 0 0
   wm deiconify $This
   wm title $This "$caption(satellite,tle_titre)"
   wm geometry $This $widget(satellite,position)
   wm protocol $This WM_DELETE_WINDOW ::satellite::cmdClose

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side top -fill x

   #--- Cree le label pour mettre a jour les TLE
   frame $This.frame3 -borderwidth 0
      button $This.but_updateTLE -text "$caption(satellite,tle_update)" -borderwidth 2 \
         -command "::satellite::updateTLE"
      pack $This.but_updateTLE -in $This.frame3 -anchor center -padx 5 -pady 5 -ipadx 15 -ipady 5
   pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

   #--- Affiche dans la Console tous les noms des satellites
   frame $This.frame4 -borderwidth 0
      button $This.but_satelname1 -text "$caption(satellite,tle_satelname)" -borderwidth 2 \
         -command { ::satellite::satelname "" }
      pack $This.but_satelname1 -in $This.frame4 -side left -anchor w -padx 5 -pady 5 -ipady 5
   pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

   #--- Cree le label pour rechercher un nom ou une liste de noms
   frame $This.frame7 -borderwidth 0
      button $This.but_satelname -text "$caption(satellite,tle_satelnamesearch) " -borderwidth 2 \
         -command { ::satellite::satelname $::satellite::widget(name_sat) }
      pack $This.but_satelname -in $This.frame7 -side left -anchor w -padx 5 -pady 5 -ipady 5
      entry $This.ent_satelname -width 6 -relief groove \
            -textvariable ::satellite::widget(name_sat) -justify center
      pack $This.ent_satelname -in $This.frame7 -side left -fill both -expand 1 -padx 5 -pady 5 -ipadx 5
   pack $This.frame7 -in $This.frame1 -side top -fill both -expand 1

   #--- Coordonnes GPS
   frame $This.frame8 -borderwidth 0
      label $This.labgps -text "$caption(satellite,gps_lieu)"
      pack $This.labgps -in $This.frame8 -side left -anchor w -padx 5 -pady 5
      entry $This.ent_gps -width 6 -relief groove -textvariable ::satellite::widget(coord_gps) \
          -justify center
      pack $This.ent_gps -in $This.frame8 -side left -fill both -expand 1 -padx 5 -pady 5 -ipady 5
   pack $This.frame8 -in $This.frame1 -side top -fill both -expand 1

   #--- Date obs
   set widget(tu,format,dmyhmsint) [ clock format [ clock seconds ] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC ]
   frame $This.frame9 -borderwidth 0
      label $This.labdate -text "$caption(satellite,dateob) : $widget(tu,format,dmyhmsint)"
      pack $This.labdate -in $This.frame9 -anchor w -side left -padx 5 -pady 5
      entry $This.ladatetu -borderwidth 1 -textvariable ::satellite::widget(satel_date)
      pack $This.ladatetu -in $This.frame9 -side left -fill both -expand 1 -padx 5 -pady 5 -ipady 5
   pack $This.frame9 -in $This.frame1 -side top -fill both -expand 1

   #--- Cree le label pour rechercher une coordonnes
   frame $This.frame5 -borderwidth 0
      button $This.but_searchcoord -text "$caption(satellite,tle_satelcoord)" -borderwidth 2 \
         -command { ::satellite::satelcoord $::satellite::widget(name_satcoord) $::satellite::widget(satel_date) $::satellite::widget(coord_gps) }
      pack $This.but_searchcoord -in $This.frame5 -side left -anchor w -padx 5 -pady 5 -ipadx 5
      entry $This.ent_satelsatcoord -width 6 -relief groove \
         -textvariable ::satellite::widget(name_satcoord) -justify center
      pack $This.ent_satelsatcoord -in $This.frame5 -side left -fill both -expand 1 -padx 5 -pady 5 -ipadx 5
   pack  $This.frame5 -in $This.frame1 -side top -fill both -expand 1

   #--- Cree le label pour rechercher le plus proche satellite
   #frame $This.frame10 -borderwidth 0
   #   button $This.but_searchcoordnearest -text "$caption(satellite,tle_satelcoordnearest)" -borderwidth 2 \
   #      -command { ::satellite::satelnearest $::satellite::widget(satel_ravalue) $::satellite::widget(satel_decvalue) $::satellite::widget(satel_date) $::satellite::widget(coord_gps) }
   #   pack $This.but_searchcoordnearest -in $This.frame10 -side left -anchor w -padx 5 -pady 5 -ipadx 5
   #   label $This.labra -text "$caption(satellite,tle_satelra)"
   #   pack $This.labra -in $This.frame10 -side left -anchor w -padx 5 -pady 5
   #   entry $This.ent_ra -width 6 -relief groove \
   #      -textvariable ::satellite::widget(satel_ra) -justify center
   #   pack $This.ent_ra -in $This.frame10 -side left -fill both -expand 1 -padx 5 -pady 5 -ipadx 5
   #   label $This.labdec -text "$caption(satellite,tle_sateldec)"
   #   pack $This.labdec -in $This.frame10 -side left -anchor w -padx 5 -pady 5
   #   entry $This.ent_dec -width 6 -relief groove \
   #      -textvariable ::satellite::widget(satel_dec) -justify center
   #   pack $This.ent_dec -in $This.frame10 -side left -fill both -expand 1 -padx 5 -pady 5 -ipadx 5
   #pack  $This.frame10 -in $This.frame1 -side top -fill both -expand 1

   #--- Creation du frame des boutons
   frame $This.frame6 -borderwidth 0

      #--- Creation du bouton 'Fermer'
      button $This.but_fermer -text "$caption(satellite,fermer)" -width 7 -borderwidth 2 \
         -command "::satellite::cmdClose"
      pack $This.but_fermer -in $This.frame6 -side right -anchor w -padx 5 -pady 5 -ipady 5

      #--- Creation du bouton 'Aide'
      button $This.but_aide -text "$caption(satellite,aide)" -width 7 -borderwidth 2 \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::satellite::getPluginType ] ] \
            [ ::satellite::getPluginDirectory ] [ ::satellite::getPluginHelp ]"
      pack $This.but_aide -in $This.frame6 -side right -anchor w -padx 5 -pady 5 -ipady 5

   pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#------------------------------------------------------------
# cmdClose
#    Procedure correspondant a l'appui sur le bouton Fermer
#------------------------------------------------------------
proc ::satellite::cmdClose { } {
   variable This

   ::satellite::recupPosition
   destroy $This
}

#------------------------------------------------------------
# updateTLE
#    Mettre a jour le fichier TLE des satellites artificiels
#------------------------------------------------------------
proc ::satellite::updateTLE { } {
   satel_update
}

#------------------------------------------------------------
# satelname
#    Lister les noms des satellites artificiels
#------------------------------------------------------------
proc ::satellite::satelname { name } {
   set result [ catch { satel_names $name} msg ]
   if {$result=="1"} {
      ::console::affiche_erreur "Error satel_names : $msg\n"
   }  else {
      ::console::disp  "\n$msg\n"
   }
}

#------------------------------------------------------------
# satelcoord
#    Calculer les coordonnees des satellites artificiels
#------------------------------------------------------------
proc ::satellite::satelcoord { name_satcoord satel_date satel_lieu } {
   set result [ catch { satel_coords $name_satcoord $satel_date $satel_lieu} msg ]
   if {$result=="1"} {
      ::console::affiche_erreur "Error satel_coords : $msg\n"
   }  else {
      ::console::disp  "\n$msg\n"
   }
}

#------------------------------------------------------------
# satelnearest
#    Rechercher les satellites artificiels proches
#------------------------------------------------------------
#proc ::satellite::satelnearest { ra dec satel_date satel_lieu } {
#   if {($ra=="")||($dec=="")||($ra=="RA")||($dec=="DEC")} {
#         ::console::affiche_erreur "RA and/or DEC not valid\n"
#   } else {
#      set result [ catch { satel_nearest_radec $ra $dec $satel_lieu} msg ]
#      if {$result=="1"} {
#         ::console::affiche_erreur "Error satelnearest : $msg\n"
#     }  else {
#         ::console::disp  "\n$msg\n"
#     }
#   }
#}

