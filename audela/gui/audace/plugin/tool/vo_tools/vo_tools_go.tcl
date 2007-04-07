#
# Fichier : vo_tools_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Robert DELMAS
# Mise a jour $Id: vo_tools_go.tcl,v 1.6 2007-04-07 00:38:36 robertdelmas Exp $
#

#============================================================
# Declaration du namespace VO_Tools
#    initialise le namespace
#============================================================
namespace eval ::VO_Tools {
   package provide vo_tools 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] vo_tools_go.cap ]
}

#------------------------------------------------------------
# ::VO_Tools::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::VO_Tools::getPluginTitle { } {
   global caption

   return "$caption(vo_tools_go,titre)"
}

#------------------------------------------------------------
# ::VO_Tools::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::VO_Tools::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::VO_Tools::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::VO_Tools::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analisys" }
      subfunction1 { return "solar system" }
   }
}

#------------------------------------------------------------
# ::VO_Tools::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::VO_Tools::initPlugin{ } {

}

#------------------------------------------------------------
# ::VO_Tools::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::VO_Tools::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require Tablelist
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_resolver.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_search.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_statut.tcl ]\""
   #--- Mise en place de l'interface graphique
   ::VO_Tools::createPanel $in.vo_tools
}

#------------------------------------------------------------
# ::VO_Tools::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::VO_Tools::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::VO_Tools::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::VO_Tools::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(VO_Tools,titre)  "$caption(vo_tools_go,vo_tools)"
   set panneau(VO_Tools,aide)   "$caption(vo_tools_go,help_titre)"
   set panneau(VO_Tools,titre1) "$caption(vo_tools_go,aladin)"
   set panneau(VO_Tools,titre2) "$caption(vo_tools_go,cone-search)"
   set panneau(VO_Tools,titre3) "$caption(vo_tools_go,resolver)"
   set panneau(VO_Tools,titre4) "$caption(vo_tools_go,statut)"
   #--- Construction de l'interface
   ::VO_Tools::VO_ToolsBuildIF $This
}

#------------------------------------------------------------
# ::VO_Tools::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::VO_Tools::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::VO_Tools::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::VO_Tools::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::VO_Tools::VO_ToolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::VO_Tools::VO_ToolsBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(VO_Tools,titre) \
            -command "::audace::showHelpPlugin tool vo_tools vo_tools.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(VO_Tools,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame CDS Aladin Multiview
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil CDS Aladin Multiview
         button $This.fra2.but1 -borderwidth 2 -text $panneau(VO_Tools,titre1) -state disabled \
            -command ""
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame des services SkyBoT
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d'objets du Systeme Solaire dans le champ
         button $This.fra3.but1 -borderwidth 2 -text $panneau(VO_Tools,titre2) \
            -command "::skybot_Search::run $audace(base).skybot_Search"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Frame du mode de calcul des ephemerides d'objets du Systeme Solaire
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de calcul des ephemerides d'objets du Systeme Solaire
         button $This.fra4.but1 -borderwidth 2 -text $panneau(VO_Tools,titre3) \
            -command "::skybot_Resolver::run $audace(base).skybot_Resolver"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame du mode de verification du statut de la base SkyBoT
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de verification du statut de la base SkyBoT
         button $This.fra5.but1 -borderwidth 2 -text $panneau(VO_Tools,titre4) \
            -command {
               #--- Gestion du bouton
               $::VO_Tools::This.fra5.but1 configure -relief groove -state disabled
               #--- Lancement de la commande
               ::skybot_Statut::run "$audace(base).skybot_Statut"
            }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra5 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

