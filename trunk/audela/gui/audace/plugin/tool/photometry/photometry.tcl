#
# Fichier : photometry.tcl
# Description : Outil de traitement d'images de photometrie
# Auteur : Alain Klotz
# Mise a jour $Id: photometry.tcl,v 1.6 2007-09-09 19:29:51 robertdelmas Exp $
#

namespace eval ::photometry {
   package provide photometry 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] photometry.cap ]
}

#------------------------------------------------------------
# ::photometry::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::photometry::getPluginTitle { } {
   global caption

   return "$caption(photometry,titre,panneau)"
}

#------------------------------------------------------------
#  ::photometry::getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::photometry::getPluginHelp { } {
   return "photometry.htm"
}

#------------------------------------------------------------
# ::photometry::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::photometry::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::photometry::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::photometry::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "photometry" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::photometry::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::photometry::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::photometry::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::photometry::createPluginInstance { { in "" } { visuNo 1 } } {
   ::photometry::createPanel $in.photometry
}

#------------------------------------------------------------
# ::photometry::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::photometry::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::photometry::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::photometry::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(photometry,titre)     "$caption(photometry,titre,panneau)"
   set panneau(photometry,aide)      "$caption(photometry,help,titre)"
   set panneau(photometry,recherche) "$caption(photometry,2_3_couleur)"
   set panneau(photometry,configure) "$caption(photometry,configure)"
   set panneau(photometry,prepare)   "$caption(photometry,prepare)"
   set panneau(photometry,calibre)   "$caption(photometry,calibre)"
   set panneau(photometry,mesure)    "$caption(photometry,mesure)"
   #--- Construction de l'interface
   ::photometry::photometryBuildIF $This
}

#------------------------------------------------------------
# ::photometry::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::photometry::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::photometry::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::photometry::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::photometry::photometryBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::photometry::photometryBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(photometry,titre) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::photometry::getPluginType ] ] \
               photometry [ ::photometry::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(photometry,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(photometry,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top -padx 5

         #--- Bouton configurer
         button $This.fra2.but1 -borderwidth 2 -text $panneau(photometry,configure) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_configure.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton preparer
         button $This.fra2.but2 -borderwidth 2 -text $panneau(photometry,prepare) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_prepare.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton calibrer
         button $This.fra2.but3 -borderwidth 2 -text $panneau(photometry,calibre) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_calibre.tcl ] }
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton mesurer
         button $This.fra2.but4 -borderwidth 2 -text $panneau(photometry,mesure) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_mesure.tcl ] }
         pack $This.fra2.but4 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

