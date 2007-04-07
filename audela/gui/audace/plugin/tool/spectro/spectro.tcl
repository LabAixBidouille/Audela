#
# Fichier : spectro.tcl
# Description : Outil de traitement d'images de spectro
# Auteur : Alain Klotz
# Mise a jour $Id: spectro.tcl,v 1.16 2007-04-07 00:38:35 robertdelmas Exp $
#

#============================================================
# Declaration du namespace spectro
#    initialise le namespace
#============================================================
namespace eval ::spectro {
   package provide spectro 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] spectro.cap ]
}

#------------------------------------------------------------
# ::spectro::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::spectro::getPluginTitle { } {
   global caption

   return "$caption(spectro,titre,outil)"
}

#------------------------------------------------------------
# ::spectro::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::spectro::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::spectro::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::spectro::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "spectro" }
   }
}

#------------------------------------------------------------
# ::spectro::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::spectro::initPlugin{ } {

}

#------------------------------------------------------------
# ::spectro::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::spectro::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement des fonctions de spectrographie
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool spectro spcaudace.tcl ]\""
   #--- Mise en place de l'interface graphique
   ::spectro::createPanel $in.spectro
}

#------------------------------------------------------------
# ::spectro::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::spectro::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::spectro::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::spectro::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(spectro,titre)      "$caption(spectro,titre,outil)"
   set panneau(spectro,aide)       "$caption(spectro,help,titre)"
   set panneau(spectro,configure)  "$caption(spectro,configure)"
   set panneau(spectro,spc_audace) "$caption(spectro,spc_audace)"
   #--- Construction de l'interface
   ::spectro::spectroBuildIF $This
}

#------------------------------------------------------------
# ::spectro::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::spectro::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::spectro::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::spectro::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::spectro::spectroBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::spectro::spectroBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(spectro,titre) \
            -command "::audace::showHelpPlugin tool spectro spectro.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(spectro,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame des boutons
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton configurer
         button $This.fra2.but1 -borderwidth 2 -text $panneau(spectro,configure) \
            -command { source [ file join $audace(rep_plugin) tool spectro spectro_configure.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton editer un profil
         button $This.fra2.but2 -borderwidth 2 -text $panneau(spectro,spc_audace) \
            -command { source [ file join $audace(rep_plugin) tool spectro spcaudace spc_gui.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

