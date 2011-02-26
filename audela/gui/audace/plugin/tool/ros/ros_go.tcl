#--------------------------------------------------
# source audace/plugin/tool/ros/ros_go.tcl
#--------------------------------------------------
#
# Fichier        : ros_go.tcl
# Description    : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace ros
#    initialise le namespace
#============================================================
namespace eval ::ros {
   package provide ros 1.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] ros_go.cap ]
}

#------------------------------------------------------------
# ::ros::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::ros::getPluginTitle { } {
   global caption

   return "$caption(ros_go,titre)"
}

#------------------------------------------------------------
# ::ros::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::ros::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::ros::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::ros::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::ros::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::ros::initPlugin { tkbase } {
   global audace
   global conf
   global rosconf

   set rosconf(font,courier_10) "Courier 10 normal"
   set rosconf(font,arial_10_b) "{Arial} 10 bold"
   set rosconf(font,arial_12)   "{Arial} 12 normal"
   set rosconf(font,arial_12_b) "{Arial} 12 bold"
   set rosconf(font,arial_14_b) "{Arial} 14 bold"

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_admin.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_config.tcl ]\""

   foreach param $::ros_config::allparams {
     if {[info exists conf(ros,$param)]} then { set rosconf($param) $conf(ros,$param) }
   }

   set rosconf(bufno)    $audace(bufNo)
   set rosconf(rep_plug) [file join $audace(rep_plugin) tool ros ]

}

#------------------------------------------------------------
# ::ros::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::ros::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require tablelist
   ::ros::ressource
   ::ros::createPanel $in.ros
}

#------------------------------------------------------------
# ::ros::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::ros::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool ros ros_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_go.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_sql.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_requetes.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_sub_header.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_liste.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_admin.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_webservice.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_config.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_status.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_requetes.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_liste.cap ]\""
}

#------------------------------------------------------------
# ::ros::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::ros::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::ros::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::ros::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(ros,titre)  "$caption(ros_go,ros)"
   set panneau(ros,aide)   "$caption(ros_go,help_titre)"
   set panneau(ros,aide1)  "$caption(ros_go,help_titre1)"
   set panneau(ros,titre1) "$caption(ros_go,configuration)"
   set panneau(ros,titre2) "$caption(ros_go,status)"
   set panneau(ros,titre3) "$caption(ros_go,gestion)"
   set panneau(ros,titre4) "$caption(ros_go,synchronisation)"
   set panneau(ros,titre5) "$caption(ros_go,test)"
   set panneau(ros,titre6) "$caption(ros_go,ressource)"
   #--- Construction de l'interface
   ::ros::rosBuildIF $This

}

#------------------------------------------------------------
# ::ros::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::ros::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::ros::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::ros::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::ros::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::ros::rosBuildIF { This } {
   global audace panneau caption

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(ros,aide1)\n$panneau(ros,titre)" \
            -command "::audace::showHelpPlugin tool ros ros.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(ros,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame des services
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de configuration
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ros,titre1) \
            -command "::ros_config::run $audace(base).ros_config"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame des services
      frame $This.status -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.status.but1 -borderwidth 2 -text $caption(ros_go,status) \
            -command "::ros_status::run $audace(base).ros_status"
         pack $This.status.but1 -in $This.status -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.status -side top -fill x

      #--- Frame des services
      frame $This.maintenance -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.maintenance.but1 -borderwidth 2 -text $caption(ros_go,maintenance) \
            -command "::ros_maintenance::run $audace(base).ros_maintenance"
         pack $This.maintenance.but1 -in $This.maintenance -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.maintenance -side top -fill x

      #--- Frame des services
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de gestion de requetes
         button $This.fra4.but1 -borderwidth 2 -text $panneau(ros,titre3) \
            -command "::ros_requetes::run $audace(base).ros_synchronisation"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

     #--- Frame des services
     frame $This.fra5 -borderwidth 1 -relief groove

        #--- Bouton d'ouverture de l'outil de synchronisation
        button $This.fra5.but1 -borderwidth 2 -text $panneau(ros,titre4) \
           -command "ros_synchronisation::run"
        pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     pack $This.fra5 -side top -fill x

     #--- Frame des services
     frame $This.fra6 -borderwidth 1 -relief groove

        #--- Bouton de test
        button $This.fra6.but1 -borderwidth 2 -text $panneau(ros,titre5) \
           -command "::testprocedure::run"
        pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     pack $This.fra6 -side top -fill x

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove

         #--- Bouton de rechargement des sources du plugin
         button $This.ressource.but1 -borderwidth 2 -text $panneau(ros,titre6) \
            -command {::ros::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.ressource -side top -fill x


      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

proc gren_info { msg } { ::console::affiche_resultat "$msg" }

