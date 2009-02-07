#
# Fichier : modpoi_go.tcl
# Description : Outil pour la determination du modele de pointage
# Auteur : Alain KLOTZ
# Mise a jour $Id: modpoi_go.tcl,v 1.13 2009-02-07 11:01:41 robertdelmas Exp $
#

#============================================================
# Declaration du namespace modpoi
#    initialise le namespace
#============================================================
namespace eval ::modpoi {
   package provide modpoi 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] modpoi_go.cap ]
}

#------------------------------------------------------------
# ::modpoi::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::modpoi::getPluginTitle { } {
   global caption

   return "$caption(modpoi_go,modpoi)"
}

#------------------------------------------------------------
# ::modpoi::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::modpoi::getPluginHelp { } {
   return "modpoi.htm"
}

#------------------------------------------------------------
# ::modpoi::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::modpoi::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::modpoi::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::modpoi::getPluginDirectory { } {
   return "modpoi"
}

#------------------------------------------------------------
# ::modpoi::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::modpoi::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::modpoi::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::modpoi::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "tool" }
      function     { return "utility" }
      subfunction1 { return "aiming" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::modpoi::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::modpoi::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::modpoi::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::modpoi::createPluginInstance { { in "" } { visuNo 1 } } {
   ::modpoi::createPanel $in.modpoi
}

#------------------------------------------------------------
# ::modpoi::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::modpoi::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::modpoi::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::modpoi::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(modpoi,titre)   "$caption(modpoi_go,modpoi)"
   set panneau(modpoi,aide)    "$caption(modpoi_go,help_titre)"
   set panneau(modpoi,titre1)  "$caption(modpoi_go,titre)"
   set panneau(modpoi,nouveau) "$caption(modpoi_go,nouveau)"
   set panneau(modpoi,charger) "$caption(modpoi_go,ouvrir)"
   set panneau(modpoi,editer)  "$caption(modpoi_go,editer)"
   #--- Construction de l'interface
   ::modpoi::modpoiBuildIF $This
}

#------------------------------------------------------------
# ::modpoi::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::modpoi::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::modpoi::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::modpoi::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::modpoi::modpoiBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::modpoi::modpoiBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(modpoi,titre) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::modpoi::getPluginType ] ] \
               [ ::modpoi::getPluginDirectory ] [ ::modpoi::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(modpoi,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame TPOINT
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(modpoi,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top -pady 5

         #--- Bouton Nouveau
         button $This.fra2.but1 -borderwidth 2 -text $panneau(modpoi,nouveau) \
            -command {
               #--- Je connecte la monture si ce n'est pas fait
               if { [ ::tel::list ] == "" } {
                  ::confTel::run
                  tkwait window $audace(base).confTel
               }
               #--- Chargement du script
               source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ]
               #--- Chargement des parametres
               Chargement_Var
               #--- Ouvre l'assistant pour realiser un modele de pointage
               modpoi_wiz new
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

         #--- Bouton Ouvrir
         button $This.fra2.but2 -borderwidth 2 -text $panneau(modpoi,charger) \
            -command {
               #--- Je connecte la monture si ce n'est pas fait
               if { [ ::tel::list ] == "" } {
                  ::confTel::run
                  tkwait window $audace(base).confTel
               }
               #--- Chargement du script
               source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ]
               #--- Chargement des parametres
               Chargement_Var
               #--- Fenetre parent
               set fenetre "$audace(base)"
               #--- Repertoire contenant les modeles de pointage
               set initialdir [ file join $audace(rep_plugin) tool modpoi model_modpoi ]
               #--- Ouvre la fenetre de configuration du choix du modele de pointage
               set panneau(modpoi_choisi) [ ::tkutil::box_load $fenetre $initialdir $audace(bufNo) "10" ]
               #--- Ouvre le modele de pointage choisi
               modpoi_load "$panneau(modpoi_choisi)"
            }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

         #--- Bouton Editer
         button $This.fra2.but3 -borderwidth 2 -text $panneau(modpoi,editer) \
            -command {
               #--- Chargement du script
               source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ]
               #--- Chargement des parametres
               Chargement_Var
               #--- Edite le modele de pointage choisi
               modpoi_wiz edit
            }
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

