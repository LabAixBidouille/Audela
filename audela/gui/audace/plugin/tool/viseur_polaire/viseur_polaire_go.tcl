#
# Fichier : viseur_polaire_go.tcl
# Description : Outil proposant 2 types de viseur polaire
# Type Takahashi : Viseur polaire à niveau
# Type EQ6 : Viseur polaire à constellations
# Auteur : Robert DELMAS
# Mise a jour $Id: viseur_polaire_go.tcl,v 1.11 2009-07-14 08:09:51 robertdelmas Exp $
#

#============================================================
# Declaration du namespace viseur_polaire
#    initialise le namespace
#============================================================
namespace eval ::viseur_polaire {
   package provide viseur_polaire 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] viseur_polaire_go.cap ]
}

#------------------------------------------------------------
# ::viseur_polaire::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::viseur_polaire::getPluginTitle { } {
   global caption

   return "$caption(viseur_polaire_go,titre)"
}

#------------------------------------------------------------
# ::viseur_polaire::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::viseur_polaire::getPluginHelp { } {
   return "viseur_polaire.htm"
}

#------------------------------------------------------------
# ::viseur_polaire::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::viseur_polaire::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::viseur_polaire::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::viseur_polaire::getPluginDirectory { } {
   return "viseur_polaire"
}

#------------------------------------------------------------
# ::viseur_polaire::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::viseur_polaire::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::viseur_polaire::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::viseur_polaire::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "tool" }
      function     { return "utility" }
      subfunction1 { return "aiming" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::viseur_polaire::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::viseur_polaire::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::viseur_polaire::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::viseur_polaire::createPluginInstance { { in "" } { visuNo 1 } } {
   ::viseur_polaire::createPanel $in.viseur_polaire
}

#------------------------------------------------------------
# ::viseur_polaire::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::viseur_polaire::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::viseur_polaire::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::viseur_polaire::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(viseur_polaire,titre) "$caption(viseur_polaire_go,titre)"
   set panneau(viseur_polaire,aide)  "$caption(viseur_polaire_go,help_titre)"
   set panneau(viseur_polaire,aide1) "$caption(viseur_polaire_go,help_titre1)"
   set panneau(viseur_polaire,taka)  "$caption(viseur_polaire_go,taka)"
   set panneau(viseur_polaire,eq6)   "$caption(viseur_polaire_go,eq6)"
   #--- Construction de l'interface
   viseur_polaireBuildIF $This
}

#------------------------------------------------------------
# ::viseur_polaire::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::viseur_polaire::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::viseur_polaire::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::viseur_polaire::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::viseur_polaire::viseur_polaireBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::viseur_polaire::viseur_polaireBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(viseur_polaire,aide1)\n$panneau(viseur_polaire,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::viseur_polaire::getPluginType ] ] \
               [ ::viseur_polaire::getPluginDirectory ] [ ::viseur_polaire::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(viseur_polaire,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du viseur polaire de type Takahashi
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type Takahashi
         button $This.fra2.but1 -borderwidth 2 -text $panneau(viseur_polaire,taka) \
            -command {
               source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_taka.tcl ]
               ::viseurPolaireTaka::run "$audace(base).viseurPolaireTaka"
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame du viseur polaire de type EQ6
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type EQ6
         button $This.fra3.but1 -borderwidth 2 -text $panneau(viseur_polaire,eq6) \
            -command {
               source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_eq6.tcl ]
               ::viseurPolaireEQ6::run "$audace(base).viseurPolaireEQ6"
            }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

