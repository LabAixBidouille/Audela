#
# Fichier : telshift_go.tcl
# Description : Outil pour l'acquisition avec deplacement du telescope entre les poses
# Auteur : Christian JASINSKI
# Mise a jour $Id: telshift_go.tcl,v 1.4 2007-04-07 00:38:36 robertdelmas Exp $
#

#============================================================
# Declaration du namespace ImagerDeplacer
#    initialise le namespace
#============================================================
namespace eval ::ImagerDeplacer {
   package provide telshift 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] telshift_go.cap ]
}

#------------------------------------------------------------
# ::ImagerDeplacer::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::ImagerDeplacer::getPluginTitle { } {
   global caption

   return "$caption(telshift_go,telshift)"
}

#------------------------------------------------------------
# ::ImagerDeplacer::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::ImagerDeplacer::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::ImagerDeplacer::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::ImagerDeplacer::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
   }
}

#------------------------------------------------------------
# ::ImagerDeplacer::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::ImagerDeplacer::initPlugin{ } {

}

#------------------------------------------------------------
# ::ImagerDeplacer::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::createPluginInstance { { in "" } { visuNo 1 } } {
   ::ImagerDeplacer::createPanel $in.imagerdeplacer
}

#------------------------------------------------------------
# ::ImagerDeplacer::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::ImagerDeplacer::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::ImagerDeplacer::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(ImagerDeplacer,titre)  "$caption(telshift_go,telshift)"
   set panneau(ImagerDeplacer,aide)   "$caption(telshift_go,help_titre)"
   set panneau(ImagerDeplacer,titre1) "$caption(telshift_go,acquisition)"
   set panneau(ImagerDeplacer,acq)    "$caption(telshift_go,acq)"
   #--- Construction de l'interface
   ::ImagerDeplacer::ImagerDeplacerBuildIF $This
}

#------------------------------------------------------------
# ::ImagerDeplacer::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::ImagerDeplacer::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::ImagerDeplacer::ImagerDeplacerBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::ImagerDeplacerBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(ImagerDeplacer,titre) \
            -command "::audace::showHelpPlugin tool telshift telshift.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(ImagerDeplacer,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du bouton
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du bouton
         label $This.fra2.lab1 -borderwidth 0 -text $panneau(ImagerDeplacer,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton AcqVisu
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ImagerDeplacer,acq) \
            -command { source [ file join $audace(rep_plugin) tool telshift telshift.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 10 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

