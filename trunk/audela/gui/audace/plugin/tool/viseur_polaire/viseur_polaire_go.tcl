#
# Fichier : viseur_polaire_go.tcl
# Description : Outil proposant 2 types de viseur polaire
# Type Takahashi : Viseur polaire à niveau
# Type EQ6 : Viseur polaire à constellations
# Auteur : Robert DELMAS
# Mise a jour $Id: viseur_polaire_go.tcl,v 1.5 2007-04-14 08:35:45 robertdelmas Exp $
#

#============================================================
# Declaration du namespace ViseurPolaire
#    initialise le namespace
#============================================================
namespace eval ::ViseurPolaire {
   package provide viseur_polaire 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] viseur_polaire_go.cap ]
}

#------------------------------------------------------------
# ::ViseurPolaire::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::ViseurPolaire::getPluginTitle { } {
   global caption

   return "$caption(viseur_polaire_go,titre)"
}

#------------------------------------------------------------
# ::ViseurPolaire::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::ViseurPolaire::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::ViseurPolaire::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::ViseurPolaire::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "utility" }
      subfunction1 { return "aiming" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::ViseurPolaire::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::ViseurPolaire::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::ViseurPolaire::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::ViseurPolaire::createPluginInstance { { in "" } { visuNo 1 } } {
   ::ViseurPolaire::createPanel $in.viseurpolaire
}

#------------------------------------------------------------
# ::ViseurPolaire::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::ViseurPolaire::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::ViseurPolaire::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::ViseurPolaire::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(ViseurPolaire,titre) "$caption(viseur_polaire_go,titre)"
   set panneau(ViseurPolaire,aide)  "$caption(viseur_polaire_go,help_titre)"
   set panneau(ViseurPolaire,taka)  "$caption(viseur_polaire_go,taka)"
   set panneau(ViseurPolaire,eq6)   "$caption(viseur_polaire_go,eq6)"
   #--- Construction de l'interface
   ViseurPolaireBuildIF $This
}

#------------------------------------------------------------
# ::ViseurPolaire::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::ViseurPolaire::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::ViseurPolaire::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::ViseurPolaire::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::ViseurPolaire::ViseurPolaireBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::ViseurPolaire::ViseurPolaireBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(ViseurPolaire,titre) \
            -command "::audace::showHelpPlugin tool viseur_polaire viseur_polaire.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(ViseurPolaire,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du viseur polaire de type Takahashi
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type Takahashi
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ViseurPolaire,taka) \
            -command {
               source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_taka.tcl ]
               ::viseurPolaireTaka::run "$audace(base).viseurPolaireTaka"
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame du viseur polaire de type EQ6
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type EQ6
         button $This.fra3.but1 -borderwidth 2 -text $panneau(ViseurPolaire,eq6) \
            -command {
               source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_eq6.tcl ]
               ::viseurPolaireEQ6::run "$audace(base).viseurPolaireEQ6"
            }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

