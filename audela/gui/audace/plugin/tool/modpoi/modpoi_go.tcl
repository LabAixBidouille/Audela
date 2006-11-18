#
# Fichier : modpoi_go.tcl
# Description : Outil pour la determination du modele de pointage
# Auteur : Alain KLOTZ
# Mise a jour $Id: modpoi_go.tcl,v 1.5 2006-11-18 23:49:10 robertdelmas Exp $
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
      #---
      set panneau(menu_name,Modelpoi)   "$caption(modpoi_go,modpoi)"
      set panneau(Modelpoi,aide)        "$caption(modpoi_go,help_titre)"
      set panneau(Modelpoi,titre1)      "$caption(modpoi_go,titre)"
      set panneau(Modelpoi,nouveau)     "$caption(modpoi_go,nouveau)"
      set panneau(Modelpoi,charger)     "$caption(modpoi_go,ouvrir)"
      set panneau(Modelpoi,editer)      "$caption(modpoi_go,editer)"
      ModelpoiBuildIF $This
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

proc ModelpoiBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Modelpoi) \
            -command {
               ::audace::showHelpPlugin tool modpoi modpoi.htm
            }
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

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Modelpoi::init $audace(base)

