#
# Fichier : modpoi_go.tcl
# Description : Outil pour la determination du modele de pointage
# Auteur : Alain KLOTZ
# Mise a jour $Id: modpoi_go.tcl,v 1.7 2007-04-07 00:38:34 robertdelmas Exp $
#

#============================================================
# Declaration du namespace Modelpoi
#    initialise le namespace
#============================================================
namespace eval ::Modelpoi {
   package provide modpoi 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] modpoi_go.cap ]
}

#------------------------------------------------------------
# ::Modelpoi::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::Modelpoi::getPluginTitle { } {
   global caption

   return "$caption(modpoi_go,modpoi)"
}

#------------------------------------------------------------
# ::Modelpoi::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::Modelpoi::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::Modelpoi::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::Modelpoi::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "utility" }
      subfunction1 { return "aiming" }
   }
}

#------------------------------------------------------------
# ::Modelpoi::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::Modelpoi::initPlugin{ } {

}

#------------------------------------------------------------
# ::Modelpoi::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::Modelpoi::createPluginInstance { { in "" } { visuNo 1 } } {
   ::Modelpoi::createPanel $in.modelpoi
}

#------------------------------------------------------------
# ::Modelpoi::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::Modelpoi::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::Modelpoi::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::Modelpoi::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(Modelpoi,titre)   "$caption(modpoi_go,modpoi)"
   set panneau(Modelpoi,aide)    "$caption(modpoi_go,help_titre)"
   set panneau(Modelpoi,titre1)  "$caption(modpoi_go,titre)"
   set panneau(Modelpoi,nouveau) "$caption(modpoi_go,nouveau)"
   set panneau(Modelpoi,charger) "$caption(modpoi_go,ouvrir)"
   set panneau(Modelpoi,editer)  "$caption(modpoi_go,editer)"
   #--- Construction de l'interface
   ::Modelpoi::ModelpoiBuildIF $This
}

#------------------------------------------------------------
# ::Modelpoi::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::Modelpoi::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::Modelpoi::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::Modelpoi::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::Modelpoi::ModelpoiBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::Modelpoi::ModelpoiBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(Modelpoi,titre) \
            -command "::audace::showHelpPlugin tool modpoi modpoi.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Modelpoi,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame TPOINT
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(Modelpoi,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top -pady 5

         #--- Bouton Nouveau
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Modelpoi,nouveau) \
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
         button $This.fra2.but2 -borderwidth 2 -text $panneau(Modelpoi,charger) \
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
         button $This.fra2.but3 -borderwidth 2 -text $panneau(Modelpoi,editer) \
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

