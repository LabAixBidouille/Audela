#
# Fichier : supernovae_go.tcl
# Description : Outil pour l'observation des SnAudes
# Auteur : Alain KLOTZ
# Mise a jour $Id: supernovae_go.tcl,v 1.17 2009-07-14 08:08:33 robertdelmas Exp $
#

#============================================================
# Declaration du namespace supernovae
#    initialise le namespace
#============================================================
namespace eval ::supernovae {
   package provide supernovae 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] supernovae_go.cap ]
}

#------------------------------------------------------------
# ::supernovae::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::supernovae::getPluginTitle { } {
   global caption

   return "$caption(supernovae_go,supernovae)"
}

#------------------------------------------------------------
# ::supernovae::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::supernovae::getPluginHelp { } {
   return "supernovae.htm"
}

#------------------------------------------------------------
# ::supernovae::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::supernovae::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::supernovae::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::supernovae::getPluginDirectory { } {
   return "supernovae"
}

#------------------------------------------------------------
# ::supernovae::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::supernovae::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::supernovae::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::supernovae::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "tool" }
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::supernovae::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::supernovae::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::supernovae::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::supernovae::createPluginInstance { { in "" } { visuNo 1 } } {
   ::supernovae::createPanel $in.supernovae
}

#------------------------------------------------------------
# ::supernovae::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::supernovae::deletePluginInstance { visuNo } {
   global audace

   if { [ winfo exists $audace(base).snvisu ] } {
      snDelete
   }
}

#------------------------------------------------------------
# ::supernovae::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(supernovae,titre)     "$caption(supernovae_go,supernovae)"
   set panneau(supernovae,aide)      "$caption(supernovae_go,help,titre)"
   set panneau(supernovae,aide1)     "$caption(supernovae_go,help,titre1)"
   set panneau(supernovae,recherche) "$caption(supernovae_go,recherche_sn)"
   set panneau(supernovae,snacq)     "$caption(supernovae_go,sn_acq)"
   set panneau(supernovae,snvisu)    "$caption(supernovae_go,sn_visu)"
   #--- Construction de l'interface
   supernovaeBuildIF $This
}

#------------------------------------------------------------
# ::supernovae::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::supernovae::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::supernovae::supernovaeBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::supernovaeBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(supernovae,aide1)\n$panneau(supernovae,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::supernovae::getPluginType ] ] \
               [ ::supernovae::getPluginDirectory ] [ ::supernovae::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(supernovae,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du frame
         label $This.fra2.lab1 -borderwidth 0 -text $panneau(supernovae,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton Sn Acq
         button $This.fra2.but1 -borderwidth 2 -text $panneau(supernovae,snacq) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snacq.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton Sn Visu
         button $This.fra2.but2 -borderwidth 2 -text $panneau(supernovae,snvisu) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snvisu.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

