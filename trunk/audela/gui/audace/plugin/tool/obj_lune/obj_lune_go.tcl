#
# Fichier : obj_lune_go.tcl
# Description : Outil pour le lancement d'Objectif Lune
# Auteur : Robert DELMAS
# Mise a jour $Id: obj_lune_go.tcl,v 1.6 2007-04-07 00:38:34 robertdelmas Exp $
#

#============================================================
# Declaration du namespace Obj_Lune_Go
#    initialise le namespace
#============================================================
namespace eval ::Obj_Lune_Go {
   package provide obj_lune 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] obj_lune_go.cap ]
}

#------------------------------------------------------------
# ::Obj_Lune_Go::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::Obj_Lune_Go::getPluginTitle { } {
   global caption

   return "$caption(obj_lune_go,obj_lune)"
}

#------------------------------------------------------------
# ::Obj_Lune_Go::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::Obj_Lune_Go::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::Obj_Lune_Go::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::Obj_Lune_Go::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "moon" }
   }
}

#------------------------------------------------------------
# ::Obj_Lune_Go::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::Obj_Lune_Go::initPlugin{ } {

}

#------------------------------------------------------------
# ::Obj_Lune_Go::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::createPluginInstance { { in "" } { visuNo 1 } } {
   ::Obj_Lune_Go::createPanel $in.obj_lune_go
}

#------------------------------------------------------------
# ::Obj_Lune_Go::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::Obj_Lune_Go::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::Obj_Lune_Go::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(Obj_Lune_Go,titre)   "$caption(obj_lune_go,obj_lune)"
   set panneau(Obj_Lune_Go,aide)    "$caption(obj_lune_go,help_titre)"
   set panneau(Obj_Lune_Go,execute) "$caption(obj_lune_go,executer)"
   #--- Construction de l'interface
   ::Obj_Lune_Go::Obj_Lune_GoBuildIF $This
}

#------------------------------------------------------------
# ::Obj_Lune_Go::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
   #--- Chargement du package Img pour visualiser les cartes de la Lune au format jpg
   package require Img 1.3
}

#------------------------------------------------------------
# ::Obj_Lune_Go::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::Obj_Lune_Go::Obj_Lune_GoBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::Obj_Lune_GoBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(Obj_Lune_Go,titre) \
            -command "::audace::showHelpPlugin tool obj_lune obj_lune.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Obj_Lune_Go,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du bouton de lancement
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton Execute
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Obj_Lune_Go,execute) \
            -command {
               source [ file join $audace(rep_plugin) tool obj_lune obj_lune.tcl ]
               ::obj_Lune::run
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -padx 5 -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

