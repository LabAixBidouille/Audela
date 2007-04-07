#
# Fichier : acqcolor_go.tcl
# Description : Outil pour l'acquisition d'images en couleur
# Compatibilite : Cameras Audine Couleur et SCR1300XTC
# Auteur : Alain KLOTZ
# Mise a jour $Id: acqcolor_go.tcl,v 1.5 2007-04-07 00:38:29 robertdelmas Exp $
#

#============================================================
# Declaration du namespace Ccdcolor
#    initialise le namespace
#============================================================
namespace eval ::Ccdcolor {
   package provide acqcolor 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] acqcolor_go.cap ]
}

#------------------------------------------------------------
# ::Ccdcolor::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::Ccdcolor::getPluginTitle { } {
   global caption

   return "$caption(acqcolor_go,acqcolor)"
}

#------------------------------------------------------------
# ::Ccdcolor::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::Ccdcolor::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::Ccdcolor::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::Ccdcolor::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "color" }
   }
}

#------------------------------------------------------------
# ::Ccdcolor::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::Ccdcolor::initPlugin{ } {

}

#------------------------------------------------------------
# ::Ccdcolor::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::Ccdcolor::createPluginInstance { { in "" } { visuNo 1 } } {
   ::Ccdcolor::createPanel $in.ccdcolor
}

#------------------------------------------------------------
# ::Ccdcolor::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::Ccdcolor::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::Ccdcolor::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::Ccdcolor::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(Ccdcolor,titre)  "$caption(acqcolor_go,acqcolor)"
   set panneau(Ccdcolor,aide)   "$caption(acqcolor_go,help_titre)"
   set panneau(Ccdcolor,titre1) "$caption(acqcolor_go,kaf0400)"
   set panneau(Ccdcolor,titre2) "$caption(acqcolor_go,kaf1600)"
   set panneau(Ccdcolor,titre3) "$caption(acqcolor_go,kac1310)"
   set panneau(Ccdcolor,acq)    "$caption(acqcolor_go,acqvisu)"
   #--- Construction de l'interface
   ::Ccdcolor::CcdcolorBuildIF $This
}

#------------------------------------------------------------
# ::Ccdcolor::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::Ccdcolor::startTool { visuNo } {
   variable This

   #--- Chargement de la librairie de definition de la commande combit
   if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
      load libcombit.dll
   }
   #---
   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::Ccdcolor::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::Ccdcolor::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::Ccdcolor::CcdcolorBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::Ccdcolor::CcdcolorBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(Ccdcolor,titre) \
            -command "::audace::showHelpPlugin tool acqcolor acqcolor.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Ccdcolor,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame Kaf-400 Couleur
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(Ccdcolor,titre1)
         pack $This.fra2.lab1 -in $This.fra2  -anchor center -fill none -padx 4 -pady 1

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command {
               set audace(acqvisu,ccd) "kaf400"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre1)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ]
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame Kaf-1600 Couleur
      frame $This.fra3 -borderwidth 1 -relief groove

         label $This.fra3.lab1 -borderwidth 0 -text "$panneau(Ccdcolor,titre2)"
         pack $This.fra3.lab1 -in $This.fra3  -anchor center -fill none -padx 4 -pady 1

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra3.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command {
               set audace(acqvisu,ccd) "kaf1600"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre2)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ]
            }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Frame Kac-1310 Couleur
      frame $This.fra4 -borderwidth 1 -relief groove

         label $This.fra4.lab1 -borderwidth 0 -text "$panneau(Ccdcolor,titre3)"
         pack $This.fra4.lab1 -in $This.fra4  -anchor center -fill none -padx 4 -pady 1

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra4.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command {
               set audace(acqvisu,ccd) "kac1310"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre3)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ]
            }
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

