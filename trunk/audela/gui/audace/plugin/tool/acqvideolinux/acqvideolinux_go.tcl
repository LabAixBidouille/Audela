#--------------------------------------------------
# source audace/plugin/tool/acqvideolinux/acqvideolinux_go.tcl
#--------------------------------------------------
#
# Fichier        : acqvideolinux_go.tcl
# Description    : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur         : Frédéric Vachier
# Mise à jour $Id: acqvideolinux_go.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#============================================================
# Declaration du namespace acqvideolinux
#    initialise le namespace
#============================================================
namespace eval ::acqvideolinux {
   package provide acqvideolinux 1.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] acqvideolinux_go.cap ]
   source [ file join [file dirname [info script]] acqvideolinux_extraction.cap ]
}

#------------------------------------------------------------
# ::acqvideolinux::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::acqvideolinux::getPluginTitle { } {
   global caption

   return "$caption(acqvideolinux_go,titre)"
}

#------------------------------------------------------------
# ::acqvideolinux::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::acqvideolinux::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc getPluginOS { } {
   return [ list Linux ]
}

#------------------------------------------------------------
# ::acqvideolinux::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::acqvideolinux::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::acqvideolinux::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::acqvideolinux::initPlugin { tkbase } {
   global audace
   global conf
   global acqvideolinuxconf

   set acqvideolinuxconf(font,courier_10) "Courier 10 normal"
   set acqvideolinuxconf(font,arial_10_b) "{Arial} 10 bold"
   set acqvideolinuxconf(font,arial_12)   "{Arial} 12 normal"
   set acqvideolinuxconf(font,arial_12_b) "{Arial} 12 bold"
   set acqvideolinuxconf(font,arial_14_b) "{Arial} 14 bold"

   ::acqvideolinux::ressource

   foreach param $::acqvideolinux_config::allparams {
     if {[info exists conf(acqvideolinux,$param)]} then { set acqvideolinuxconf($param) $conf(acqvideolinux,$param) }
   }

   set acqvideolinuxconf(bufno)    $audace(bufNo)
   set acqvideolinuxconf(rep_plug) [file join $audace(rep_plugin) tool acqvideolinux ]

   load libavi[info sharedlibextension]
   # ::console::affiche_resultat [::hello]
}

#------------------------------------------------------------
# ::acqvideolinux::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::acqvideolinux::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require tablelist
   ::acqvideolinux::ressource
   ::acqvideolinux::createPanel $in.acqvideolinux
}

#------------------------------------------------------------
# ::acqvideolinux::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::acqvideolinux::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool acqvideolinux acqvideolinux_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideolinux acqvideolinux_go.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideolinux acqvideolinux_acquisition.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideolinux acqvideolinux_extraction.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideolinux test.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideolinux acqvideolinux_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideolinux acqvideolinux_config.tcl ]\""
}

#------------------------------------------------------------
# ::acqvideolinux::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::acqvideolinux::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::acqvideolinux::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::acqvideolinux::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(acqvideolinux,titre)  "$caption(acqvideolinux_go,acqvideolinux)"
   set panneau(acqvideolinux,aide)   "$caption(acqvideolinux_go,help_titre)"
   set panneau(acqvideolinux,aide1)  "$caption(acqvideolinux_go,help_titre1)"
   set panneau(acqvideolinux,titre1) "$caption(acqvideolinux_go,configuration)"
   set panneau(acqvideolinux,titre2) "$caption(acqvideolinux_go,acquisition)"
   set panneau(acqvideolinux,titre2) "$caption(acqvideolinux_go,extraction)"
   set panneau(acqvideolinux,titre5) "$caption(acqvideolinux_go,test)"
   set panneau(acqvideolinux,titre6) "$caption(acqvideolinux_go,ressource)"
   #--- Construction de l'interface
   ::acqvideolinux::acqvideolinuxBuildIF $This

}

#------------------------------------------------------------
# ::acqvideolinux::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::acqvideolinux::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::acqvideolinux::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::acqvideolinux::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::acqvideolinux::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::acqvideolinux::acqvideolinuxBuildIF { This } {
   global audace panneau caption

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(acqvideolinux,aide1)\n$panneau(acqvideolinux,titre)" \
            -command "::audace::showHelpPlugin tool acqvideolinux acqvideolinux.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(acqvideolinux,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame configuration
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de configuration
         button $This.fra2.but1 -borderwidth 2 -text $panneau(acqvideolinux,titre1) \
            -command "::acqvideolinux_config::run $audace(base).acqvideolinux_config"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame acquisition
      frame $This.status -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.status.but1 -borderwidth 2 -text $caption(acqvideolinux_go,acquisition) \
            -command "::acqvideolinux_acquisition::run $audace(base).acqvideolinux_acquisition"
         pack $This.status.but1 -in $This.status -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.status -side top -fill x

      #--- Frame extraction
      frame $This.maintenance -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.maintenance.but1 -borderwidth 2 -text $caption(acqvideolinux_go,extraction) \
            -command "::acqvideolinux_extraction::run $audace(base).acqvideolinux_extraction"
         pack $This.maintenance.but1 -in $This.maintenance -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.maintenance -side top -fill x


     #--- Frame des tests
     frame $This.fra6 -borderwidth 1 -relief groove

        #--- Bouton de test
        button $This.fra6.but1 -borderwidth 2 -text $panneau(acqvideolinux,titre5) \
           -command "::testprocedure::run"
        pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     pack $This.fra6 -side top -fill x

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove

         #--- Bouton de rechargement des sources du plugin
         button $This.ressource.but1 -borderwidth 2 -text $panneau(acqvideolinux,titre6) \
            -command {::acqvideolinux::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.ressource -side top -fill x


      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

proc gren_info { msg } { ::console::affiche_resultat "$msg" }

