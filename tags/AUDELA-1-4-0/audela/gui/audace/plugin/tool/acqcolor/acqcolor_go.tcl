#
# Fichier : acqcolor_go.tcl
# Description : Outil pour l'acquisition d'images en couleur
# Compatibilite : Cameras Audine Couleur et SCR1300XTC
# Auteur : Alain KLOTZ
# Mise a jour $Id: acqcolor_go.tcl,v 1.9 2007-05-06 14:28:46 robertdelmas Exp $
#

#============================================================
# Declaration du namespace ccdcolor
#    initialise le namespace
#============================================================
namespace eval ::ccdcolor {
   package provide acqcolor 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] acqcolor_go.cap ]
}

#------------------------------------------------------------
# ::ccdcolor::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::ccdcolor::getPluginTitle { } {
   global caption

   return "$caption(acqcolor_go,acqcolor)"
}

#------------------------------------------------------------
# ::ccdcolor::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::ccdcolor::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::ccdcolor::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::ccdcolor::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "color" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::ccdcolor::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::ccdcolor::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::ccdcolor::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::ccdcolor::createPluginInstance { { in "" } { visuNo 1 } } {
   ::ccdcolor::createPanel $in.ccdcolor
}

#------------------------------------------------------------
# ::ccdcolor::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::ccdcolor::deletePluginInstance { visuNo } {
   global audace

   if { [ winfo exists $audace(base).test ] } {
      testexit
   }
}

#------------------------------------------------------------
# ::ccdcolor::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::ccdcolor::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(ccdcolor,titre)  "$caption(acqcolor_go,acqcolor)"
   set panneau(ccdcolor,aide)   "$caption(acqcolor_go,help_titre)"
   set panneau(ccdcolor,titre1) "$caption(acqcolor_go,kaf0400)"
   set panneau(ccdcolor,titre2) "$caption(acqcolor_go,kaf1600)"
   set panneau(ccdcolor,titre3) "$caption(acqcolor_go,kac1310)"
   set panneau(ccdcolor,acq)    "$caption(acqcolor_go,acqvisu)"
   #--- Construction de l'interface
   ::ccdcolor::ccdcolorBuildIF $This
}

#------------------------------------------------------------
# ::ccdcolor::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::ccdcolor::startTool { visuNo } {
   variable This

   #--- Chargement de la librairie de definition de la commande combit
   if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
      load libcombit.dll
   }
   #---
   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::ccdcolor::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::ccdcolor::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::ccdcolor::ccdcolorBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::ccdcolor::ccdcolorBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(ccdcolor,titre) \
            -command "::audace::showHelpPlugin tool acqcolor acqcolor.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(ccdcolor,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame Kaf-400 Couleur
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(ccdcolor,titre1)
         pack $This.fra2.lab1 -in $This.fra2  -anchor center -fill none -padx 4 -pady 1

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ccdcolor,acq) \
            -command {
               set audace(acqvisu,ccd) "kaf400"
               set audace(acqvisu,ccd_model) $panneau(ccdcolor,titre1)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ]
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame Kaf-1600 Couleur
      frame $This.fra3 -borderwidth 1 -relief groove

         label $This.fra3.lab1 -borderwidth 0 -text "$panneau(ccdcolor,titre2)"
         pack $This.fra3.lab1 -in $This.fra3  -anchor center -fill none -padx 4 -pady 1

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra3.but1 -borderwidth 2 -text $panneau(ccdcolor,acq) \
            -command {
               set audace(acqvisu,ccd) "kaf1600"
               set audace(acqvisu,ccd_model) $panneau(ccdcolor,titre2)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ]
            }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Frame Kac-1310 Couleur
      frame $This.fra4 -borderwidth 1 -relief groove

         label $This.fra4.lab1 -borderwidth 0 -text "$panneau(ccdcolor,titre3)"
         pack $This.fra4.lab1 -in $This.fra4  -anchor center -fill none -padx 4 -pady 1

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra4.but1 -borderwidth 2 -text $panneau(ccdcolor,acq) \
            -command {
               set audace(acqvisu,ccd) "kac1310"
               set audace(acqvisu,ccd_model) $panneau(ccdcolor,titre3)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ]
            }
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

