#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_go.tcl
#--------------------------------------------------
#
# Fichier        : av4l_go.tcl
# Description    : Acquisition Video For Linux
# Auteur         : Stephane Vaillant & Frederic Vachier
# Mise à jour $Id: av4l_go.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#============================================================
# Declaration du namespace av4l
#    initialise le namespace
#============================================================
namespace eval ::av4l {
   package provide av4l 1.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] av4l_go.cap ]
   source [ file join [file dirname [info script]] av4l_extraction.cap ]
}

#------------------------------------------------------------
# ::av4l::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::av4l::getPluginTitle { } {
   global caption

   return "$caption(av4l_go,titre)"
}

#------------------------------------------------------------
# ::av4l::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::av4l::getPluginType { } {
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
# ::av4l::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::av4l::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::av4l::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::av4l::initPlugin { tkbase } {
   global audace
   global conf
   global av4lconf

   set av4lconf(font,courier_10) "Courier 10 normal"
   set av4lconf(font,arial_10_b) "{Arial} 10 bold"
   set av4lconf(font,arial_12)   "{Arial} 12 normal"
   set av4lconf(font,arial_12_b) "{Arial} 12 bold"
   set av4lconf(font,arial_14_b) "{Arial} 14 bold"

   ::av4l::ressource

   # foreach param $::av4l_config::allparams {
   #   if {[info exists conf(av4l,$param)]} then { set av4lconf($param) $conf(av4l,$param) }
   # }

   set av4lconf(bufno)    $audace(bufNo)
   set av4lconf(rep_plug) [file join $audace(rep_plugin) tool av4l ]

   load libavi[info sharedlibextension]
   # ::console::affiche_resultat [::hello]
}

#------------------------------------------------------------
# ::av4l::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::av4l::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require tablelist
   ::av4l::ressource
   ::av4l::createPanel $in.av4l
}

#------------------------------------------------------------
# ::av4l::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::av4l::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool av4l av4l_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_go.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_acquisition.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_extraction.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l test.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_setup.tcl ]\""
}

#------------------------------------------------------------
# ::av4l::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::av4l::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::av4l::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::createPanel { this } {
   variable This
   global caption 

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Construction de l'interface
   ::av4l::av4lBuildIF $This

}

#------------------------------------------------------------
# ::av4l::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::av4l::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::av4l::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::av4lBuildIF { This } {
   global audace caption

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$caption(av4l_go,help_titre1)\n$caption(av4l_go,help_titre)" \
            -command "::audace::showHelpPlugin tool av4l av4l.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(av4l_go,help_titre)

      pack $This.fra1 -side top -fill x

      #--- Frame configuration
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de configuration
         button $This.fra2.but1 -borderwidth 2 -text $caption(av4l_go,setup) \
            -command "::av4l_setup::run  $visuNo $base.av4l_setup"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame acquisition
      frame $This.status -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.status.but1 -borderwidth 2 -text $caption(av4l_go,acquisition) \
            -command "::av4l_acquisition::run $audace(base).av4l_acquisition"
         pack $This.status.but1 -in $This.status -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.status -side top -fill x

      #--- Frame extraction
      frame $This.maintenance -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.maintenance.but1 -borderwidth 2 -text $caption(av4l_go,extraction) \
            -command "::av4l_extraction::run $audace(base).av4l_extraction"
         pack $This.maintenance.but1 -in $This.maintenance -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.maintenance -side top -fill x


     #--- Frame des tests
     frame $This.fra6 -borderwidth 1 -relief groove

        #--- Bouton de test
        button $This.fra6.but1 -borderwidth 2 -text $caption(av4l_go,test) \
           -command "::testprocedure::run"
        pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     pack $This.fra6 -side top -fill x

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove

         #--- Bouton de rechargement des sources du plugin
         button $This.ressource.but1 -borderwidth 2 -text $caption(av4l_go,ressource) \
            -command {::av4l::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.ressource -side top -fill x


      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

proc gren_info { msg } { ::console::affiche_resultat "$msg" }

