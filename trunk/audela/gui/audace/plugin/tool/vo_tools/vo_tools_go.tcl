#
# Fichier : vo_tools_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Robert DELMAS
# Date de mise a jour : 25 octobre 2005
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
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(VO_Tools,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(VO_Tools,largeur_outil) "130"
      } else {
         set panneau(VO_Tools,largeur_outil) "101"
      }
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

   proc pack { } {
      variable This
      global unpackFunction

      set unpackFunction ::VO_Tools::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
   }

   proc unpack { } {
      variable This

      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }

}

proc VO_ToolsBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(VO_Tools,largeur_outil)

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(VO_Tools,titre) \
            -command {
               ::audace::showHelpPlugin tool vo_tools vo_tools.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $This.fra1.but -text $panneau(VO_Tools,aide)

      place $This.fra1 -x 4 -y 4 -height 42 -width [ expr $panneau(VO_Tools,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame CDS Aladin Multiview
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil CDS Aladin Multiview
         button $This.fra2.but1 -borderwidth 2 -text $panneau(VO_Tools,titre1) \
            -command {  }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra2 -x 4 -y 52 -height 50 -width [ expr $panneau(VO_Tools,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame du mode de recherche d'objets du Systeme Solaire dans le champ
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d'objets du Systeme Solaire dans le champ
         button $This.fra3.but1 -borderwidth 2 -text $panneau(VO_Tools,titre2) \
            -command { ::skybot_Search::run "$audace(base).skybot_Search" }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra3 -x 4 -y 108 -height 75 -width [ expr $panneau(VO_Tools,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame du mode de calcul des ephemerides d'objets du Systeme Solaire
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de calcul des ephemerides d'objets du Systeme Solaire
         button $This.fra4.but1 -borderwidth 2 -text $panneau(VO_Tools,titre3) \
            -command { ::skybot_Resolver::run "$audace(base).skybot_Resolver" }
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra4 -x 4 -y 190 -height 85 -width [ expr $panneau(VO_Tools,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

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

      place $This.fra5 -x 4 -y 282 -height 60 -width [ expr $panneau(VO_Tools,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::VO_Tools::init $audace(base)

