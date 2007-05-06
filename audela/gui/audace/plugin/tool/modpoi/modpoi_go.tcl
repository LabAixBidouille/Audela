#
# Fichier : modpoi_go.tcl
# Description : Outil pour la determination du modele de pointage
# Auteur : Alain KLOTZ
# Mise a jour $Id: modpoi_go.tcl,v 1.9 2007-05-06 14:56:06 robertdelmas Exp $
#

#============================================================
# Declaration du namespace modelpoi
#    initialise le namespace
#============================================================
namespace eval ::modelpoi {
   package provide modpoi 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] modpoi_go.cap ]
}

#------------------------------------------------------------
# ::modelpoi::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::modelpoi::getPluginTitle { } {
   global caption

   return "$caption(modpoi_go,modpoi)"
}

#------------------------------------------------------------
# ::modelpoi::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::modelpoi::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::modelpoi::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::modelpoi::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "utility" }
      subfunction1 { return "aiming" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::modelpoi::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::modelpoi::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::modelpoi::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::modelpoi::createPluginInstance { { in "" } { visuNo 1 } } {
   ::modelpoi::createPanel $in.modelpoi
}

#------------------------------------------------------------
# ::modelpoi::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::modelpoi::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::modelpoi::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::modelpoi::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(modelpoi,titre)   "$caption(modpoi_go,modpoi)"
   set panneau(modelpoi,aide)    "$caption(modpoi_go,help_titre)"
   set panneau(modelpoi,titre1)  "$caption(modpoi_go,titre)"
   set panneau(modelpoi,nouveau) "$caption(modpoi_go,nouveau)"
   set panneau(modelpoi,charger) "$caption(modpoi_go,ouvrir)"
   set panneau(modelpoi,editer)  "$caption(modpoi_go,editer)"
   #--- Construction de l'interface
   ::modelpoi::modelpoiBuildIF $This
}

#------------------------------------------------------------
# ::modelpoi::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::modelpoi::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::modelpoi::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::modelpoi::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::modelpoi::modelpoiBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::modelpoi::modelpoiBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(modelpoi,titre) \
            -command "::audace::showHelpPlugin tool modpoi modpoi.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(modelpoi,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame TPOINT
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(modelpoi,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top -pady 5

         #--- Bouton Nouveau
         button $This.fra2.but1 -borderwidth 2 -text $panneau(modelpoi,nouveau) \
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
         button $This.fra2.but2 -borderwidth 2 -text $panneau(modelpoi,charger) \
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
         button $This.fra2.but3 -borderwidth 2 -text $panneau(modelpoi,editer) \
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

