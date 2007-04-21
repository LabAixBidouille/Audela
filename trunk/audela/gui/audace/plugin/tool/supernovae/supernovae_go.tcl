#
# Fichier : supernovae_go.tcl
# Description : Outil pour l'observation des SnAudes
# Auteur : Alain KLOTZ
# Mise a jour $Id: supernovae_go.tcl,v 1.7 2007-04-21 21:48:18 michelpujol Exp $
#

#============================================================
# Declaration du namespace Snaude
#    initialise le namespace
#============================================================
namespace eval ::Snaude {
   package provide supernovae 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] supernovae_go.cap ]
}

#------------------------------------------------------------
# ::Snaude::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::Snaude::getPluginTitle { } {
   global caption

   return "$caption(supernovae_go,supernovae)"
}

#------------------------------------------------------------
# ::Snaude::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::Snaude::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::Snaude::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::Snaude::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::Snaude::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::Snaude::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::Snaude::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::Snaude::createPluginInstance { { in "" } { visuNo 1 } } {
   ::Snaude::createPanel $in.snaude
}

#------------------------------------------------------------
# ::Snaude::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::Snaude::deletePluginInstance { visuNo } {
   sn_delete 
}

#------------------------------------------------------------
# ::Snaude::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::Snaude::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(Snaude,titre)     "$caption(supernovae_go,supernovae)"
   set panneau(Snaude,aide)      "$caption(supernovae_go,help,titre)"
   set panneau(Snaude,recherche) "$caption(supernovae_go,recherche_sn)"
   set panneau(Snaude,snacq)     "$caption(supernovae_go,sn_acq)"
   set panneau(Snaude,snvisu)    "$caption(supernovae_go,sn_visu)"
   #--- Construction de l'interface
   SnaudeBuildIF $This
}

#------------------------------------------------------------
# ::Snaude::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::Snaude::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::Snaude::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::Snaude::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::Snaude::SnaudeBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::Snaude::SnaudeBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(Snaude,titre) \
            -command "::audace::showHelpPlugin tool supernovae supernovae_go.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Snaude,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du frame
         label $This.fra2.lab1 -borderwidth 0 -text $panneau(Snaude,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton Sn Acq
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Snaude,snacq) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snacq.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton Sn Visu
         button $This.fra2.but2 -borderwidth 2 -text $panneau(Snaude,snvisu) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snvisu.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

