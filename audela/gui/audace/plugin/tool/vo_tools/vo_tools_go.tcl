#
# Fichier : vo_tools_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Robert DELMAS
# Mise a jour $Id: vo_tools_go.tcl,v 1.8 2007-05-06 14:29:27 robertdelmas Exp $
#

#============================================================
# Declaration du namespace vo_tools
#    initialise le namespace
#============================================================
namespace eval ::vo_tools {
   package provide vo_tools 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] vo_tools_go.cap ]
}

#------------------------------------------------------------
# ::vo_tools::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::vo_tools::getPluginTitle { } {
   global caption

   return "$caption(vo_tools_go,titre)"
}

#------------------------------------------------------------
# ::vo_tools::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::vo_tools::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::vo_tools::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::vo_tools::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analisys" }
      subfunction1 { return "solar system" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::vo_tools::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::vo_tools::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::vo_tools::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::vo_tools::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require Tablelist
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_resolver.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_search.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_statut.tcl ]\""
   #--- Mise en place de l'interface graphique
   ::vo_tools::createPanel $in.vo_tools
}

#------------------------------------------------------------
# ::vo_tools::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::vo_tools::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::vo_tools::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(vo_tools,titre)  "$caption(vo_tools_go,vo_tools)"
   set panneau(vo_tools,aide)   "$caption(vo_tools_go,help_titre)"
   set panneau(vo_tools,titre1) "$caption(vo_tools_go,aladin)"
   set panneau(vo_tools,titre2) "$caption(vo_tools_go,cone-search)"
   set panneau(vo_tools,titre3) "$caption(vo_tools_go,resolver)"
   set panneau(vo_tools,titre4) "$caption(vo_tools_go,statut)"
   #--- Construction de l'interface
   ::vo_tools::vo_toolsBuildIF $This
}

#------------------------------------------------------------
# ::vo_tools::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::vo_tools::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::vo_tools::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::vo_toolsBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(vo_tools,titre) \
            -command "::audace::showHelpPlugin tool vo_tools vo_tools.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(vo_tools,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame CDS Aladin Multiview
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil CDS Aladin Multiview
         button $This.fra2.but1 -borderwidth 2 -text $panneau(vo_tools,titre1) -state disabled \
            -command ""
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame des services SkyBoT
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d'objets du Systeme Solaire dans le champ
         button $This.fra3.but1 -borderwidth 2 -text $panneau(vo_tools,titre2) \
            -command "::skybot_Search::run $audace(base).skybot_Search"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Frame du mode de calcul des ephemerides d'objets du Systeme Solaire
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de calcul des ephemerides d'objets du Systeme Solaire
         button $This.fra4.but1 -borderwidth 2 -text $panneau(vo_tools,titre3) \
            -command "::skybot_Resolver::run $audace(base).skybot_Resolver"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame du mode de verification du statut de la base SkyBoT
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de verification du statut de la base SkyBoT
         button $This.fra5.but1 -borderwidth 2 -text $panneau(vo_tools,titre4) \
            -command {
               #--- Gestion du bouton
               $::vo_tools::This.fra5.but1 configure -relief groove -state disabled
               #--- Lancement de la commande
               ::skybot_Statut::run "$audace(base).skybot_Statut"
            }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra5 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

