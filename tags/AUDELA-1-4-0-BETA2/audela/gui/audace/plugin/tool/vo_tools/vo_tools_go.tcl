#
# Fichier : vo_tools_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Robert DELMAS
# Mise a jour $Id: vo_tools_go.tcl,v 1.5 2007-01-27 15:17:49 robertdelmas Exp $
#

package provide vo_tools 1.0

namespace eval ::VO_Tools {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool vo_tools vo_tools_go.cap ]

   #--- Charge un fichier auxiliaire
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_resolver.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_search.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_statut.tcl ]\""

   proc init { { in "" } } {
      createPanel $in.vo_tools
   }

   proc createPanel { this } {
      variable This
      global caption panneau

      set This $this
      #---
      set panneau(menu_name,VO_Tools) "$caption(vo_tools_go,titre)"
      set panneau(VO_Tools,titre)     "$caption(vo_tools_go,vo_tools)"
      set panneau(VO_Tools,aide)      "$caption(vo_tools_go,help_titre)"
      set panneau(VO_Tools,titre1)    "$caption(vo_tools_go,aladin)"
      set panneau(VO_Tools,titre2)    "$caption(vo_tools_go,cone-search)"
      set panneau(VO_Tools,titre3)    "$caption(vo_tools_go,resolver)"
      set panneau(VO_Tools,titre4)    "$caption(vo_tools_go,statut)"
      VO_ToolsBuildIF $This
   }

   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
   }

   proc stopTool { visuNo } {
      variable This

      pack forget $This
   }

}

proc VO_ToolsBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(VO_Tools,titre) \
            -command "::audace::showHelpPlugin tool vo_tools vo_tools.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(VO_Tools,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame CDS Aladin Multiview
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil CDS Aladin Multiview
         button $This.fra2.but1 -borderwidth 2 -text $panneau(VO_Tools,titre1) -state disabled \
            -command ""
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame des services SkyBoT
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d'objets du Systeme Solaire dans le champ
         button $This.fra3.but1 -borderwidth 2 -text $panneau(VO_Tools,titre2) \
            -command "::skybot_Search::run $audace(base).skybot_Search"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Frame du mode de calcul des ephemerides d'objets du Systeme Solaire
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de calcul des ephemerides d'objets du Systeme Solaire
         button $This.fra4.but1 -borderwidth 2 -text $panneau(VO_Tools,titre3) \
            -command "::skybot_Resolver::run $audace(base).skybot_Resolver"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame du mode de verification du statut de la base SkyBoT
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de verification du statut de la base SkyBoT
         button $This.fra5.but1 -borderwidth 2 -text $panneau(VO_Tools,titre4) \
            -command {
               #--- Gestion du bouton
               $::VO_Tools::This.fra5.but1 configure -relief groove -state disabled
               #--- Lancement de la commande
               ::skybot_Statut::run "$audace(base).skybot_Statut"
            }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra5 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::VO_Tools::init $audace(base)

