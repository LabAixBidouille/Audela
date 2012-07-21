#
# Fichier : acqcolor_go.tcl
# Description : Outil pour l'acquisition d'images en couleur
# Cet outil est utilisable par l'Audine couleur, par les WebCams couleur et par la SCR1300XTC
# Auteur : Alain KLOTZ
# Date de mise a jour : 18 juin 2005
#

package provide acqcolor 1.0

namespace eval ::Ccdcolor {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool acqcolor acqcolor_go.cap ]

   proc init { { in "" } } {
      createPanel $in.ccdcolor
   }

   proc createPanel { this } {
      variable This
      global caption panneau

      set This $this
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(Ccdcolor,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(Ccdcolor,largeur_outil) "130"
      } else {
         set panneau(Ccdcolor,largeur_outil) "101"
      }
      #---
      set panneau(menu_name,Ccdcolor) "$caption(acqcolor_go,acqcolor)"
      set panneau(Ccdcolor,aide)      "$caption(acqcolor_go,help_titre)"
      set panneau(Ccdcolor,titre1)    "$caption(acqcolor_go,kaf0400)"
      set panneau(Ccdcolor,titre2)    "$caption(acqcolor_go,kaf1600)"
      set panneau(Ccdcolor,titre3)    "$caption(acqcolor_go,webcam)"
      set panneau(Ccdcolor,titre4)    "$caption(acqcolor_go,kac1310)"
      set panneau(Ccdcolor,acq)       "$caption(acqcolor_go,acqvisu)"
      CcdcolorBuildIF $This
   }

   proc pack { } {
      variable This
      global unpackFunction

      set unpackFunction ::Ccdcolor::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
   }

   proc unpack { } {
      variable This

      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }

}

proc CcdcolorBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(Ccdcolor,largeur_outil)

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Ccdcolor) \
            -command {
               ::audace::showHelpPlugin tool acqcolor acqcolor.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $This.fra1.but -text $panneau(Ccdcolor,aide)

      place $This.fra1 -x 4 -y 4 -height 22 -width [ expr $panneau(Ccdcolor,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame Kaf-400 Couleur
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(Ccdcolor,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command { 
               set audace(acqvisu,ccd) "kaf400"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre1)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ] 
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra2 -x 4 -y 32 -height 60 -width [ expr $panneau(Ccdcolor,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame Kaf-1600 Couleur
      frame $This.fra3 -borderwidth 1 -relief groove

         label $This.fra3.lab1 -borderwidth 0 -text "$panneau(Ccdcolor,titre2)"
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand 1 -fill both -side top

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra3.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command { 
               set audace(acqvisu,ccd) "kaf1600"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre2)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ] 
            }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra3 -x 4 -y 100 -height 60 -width [ expr $panneau(Ccdcolor,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame webcam
      frame $This.fra4 -borderwidth 1 -relief groove

         label $This.fra4.lab1 -borderwidth 0 -text $panneau(Ccdcolor,titre3)
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -expand 1 -fill both -side top

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra4.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command { 
               set audace(acqvisu,ccd) "webcam"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre3)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ] 
            }
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra4 -x 4 -y 168 -height 60 -width [ expr $panneau(Ccdcolor,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame Kac-1310 Couleur
      frame $This.fra5 -borderwidth 1 -relief groove

         label $This.fra5.lab1 -borderwidth 0 -text "$panneau(Ccdcolor,titre4)"
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -expand 1 -fill both -side top

         #--- Bouton d'ouverture de l'outil d'acquisition
         button $This.fra5.but1 -borderwidth 2 -text $panneau(Ccdcolor,acq) \
            -command { 
               set audace(acqvisu,ccd) "kac1310"
               set audace(acqvisu,ccd_model) $panneau(Ccdcolor,titre4)
               source [ file join $audace(rep_plugin) tool acqcolor acqcolor.tcl ] 
            }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      place $This.fra5 -x 4 -y 236 -height 60 -width [ expr $panneau(Ccdcolor,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Ccdcolor::init $audace(base)
