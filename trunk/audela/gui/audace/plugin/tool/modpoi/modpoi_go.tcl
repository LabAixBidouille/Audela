#
# Fichier : modpoi_go.tcl
# Description : Outil pour le modele de pointage
# Auteur : Alain KLOTZ
# Date de mise a jour : 18 juin 2005
#

package provide modpoi 1.0

namespace eval ::Modelpoi {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool modpoi modpoi_go.cap ]

   proc init { { in "" } } {
      createPanel $in.modelpoi
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(Modelpoi,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(Modelpoi,largeur_outil) "130"
      } else {
         set panneau(Modelpoi,largeur_outil) "101"
      }
      #---
      set panneau(menu_name,Modelpoi)   "$caption(modpoi_go,modpoi_titre)"
      set panneau(Modelpoi,titre)       "$caption(modpoi_go,modpoi)"
      set panneau(Modelpoi,aide)        "$caption(modpoi_go,help_titre)"
      set panneau(Modelpoi,titre1)      "$caption(modpoi_go,titre)"
      set panneau(Modelpoi,nouveau)     "$caption(modpoi_go,nouveau)"
      set panneau(Modelpoi,charger)     "$caption(modpoi_go,ouvrir)"
      set panneau(Modelpoi,editer)      "$caption(modpoi_go,editer)"
      set panneau(Modelpoi,enregistrer) "$caption(modpoi_go,enregistrer)"
      ModelpoiBuildIF $This
   }

   proc pack { } {
      variable This
      global unpackFunction

      set unpackFunction ::Modelpoi::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
   }

   proc unpack { } {
      variable This

      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }

}

proc ModelpoiBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(Modelpoi,largeur_outil)

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(Modelpoi,titre) \
            -command {
               ::audace::showHelpPlugin tool modpoi modpoi.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $This.fra1.but -text $panneau(Modelpoi,aide)

      place $This.fra1 -x 4 -y 4 -height 22 -width [ expr $panneau(Modelpoi,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame TPOINT
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(Modelpoi,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton Nouveau
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Modelpoi,nouveau) \
            -command {
               if { [ ::tel::list ] == "" } {
                  ::confTel::run 
                  tkwait window $audace(base).confTel
               } else {
                  source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ] 
                  Chargement_Var
                  modpoi_wiz new
               }
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

         #--- Bouton Ouvrir
         button $This.fra2.but2 -borderwidth 2 -text $panneau(Modelpoi,charger) \
            -command {
               if { [ ::tel::list ] == "" } {
                  ::confTel::run 
                  tkwait window $audace(base).confTel
               } else {
                  source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ] 
                  Chargement_Var
                  modpoi_load modpoires.txt
               }
            }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

         #--- Bouton Editer
         button $This.fra2.but3 -borderwidth 2 -text $panneau(Modelpoi,editer) \
            -command { 
               source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ] 
               Chargement_Var
               modpoi_wiz edit
            }
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

         #--- Bouton Enregistrer
         button $This.fra2.but4 -borderwidth 2 -text $panneau(Modelpoi,enregistrer) -state disabled \
            -command { 
               source [ file join $audace(rep_plugin) tool modpoi modpoi.tcl ] 
               Chargement_Var
            }
         pack $This.fra2.but4 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra2 -x 4 -y 32 -height 190 -width [ expr $panneau(Modelpoi,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Modelpoi::init $audace(base)

