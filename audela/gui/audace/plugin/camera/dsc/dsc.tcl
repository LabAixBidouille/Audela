#
# Fichier : dsc.tcl
# Description : Gestion du telechargement des images d'un APN
# Auteur : Robert DELMAS
# Date de mise a jour : 11 mars 2006
#

namespace eval cameraDSC {

   proc init { } {
      global audace
      global conf

      #--- Chargement des captions
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera dsc dsc.cap ]\""

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(dsc,telecharge_mode) ] } { set conf(dsc,telecharge_mode)     "2" }

   }

   proc Telecharge_image { } {
      global conf
      global audace
      global caption

      #---
      if { [ winfo exists $audace(base).telecharge_image ] } {
         wm withdraw $audace(base).telecharge_image
         if { [ winfo exists $audace(base).confCam ] } {
            wm deiconify $audace(base).confCam
         }
         wm deiconify $audace(base).telecharge_image
         focus $audace(base).telecharge_image
         return
      }

      #--- Creation de la fenetre
      toplevel $audace(base).telecharge_image
      wm resizable $audace(base).telecharge_image 0 0
      wm title $audace(base).telecharge_image "$caption(dsc,telecharger)"
      if { [ winfo exists $audace(base).confCam ] } {
         wm deiconify $audace(base).confCam
         wm transient $audace(base).telecharge_image $audace(base).confCam
         set posx_telecharge_image [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 1 ]
         set posy_telecharge_image [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 2 ]
         wm geometry $audace(base).telecharge_image +[ expr $posx_telecharge_image + 350 ]+[ expr $posy_telecharge_image + 90 ]
      } else {
         wm transient $audace(base).telecharge_image $audace(base)
         set posx_telecharge_image [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_telecharge_image [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $audace(base).telecharge_image +[ expr $posx_telecharge_image + 150 ]+[ expr $posy_telecharge_image + 90 ]
      }
      foreach visuNo [ ::visu::list ] {
         radiobutton $audace(base).telecharge_image.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
           -text "$caption(dsc,pas_telecharger)" -value 1 -variable conf(dsc,telecharge_mode) -state normal \
           -command "::cameraDSC::ChangerSelectionTelechargementAPN $visuNo" 
         pack $audace(base).telecharge_image.rad1 -anchor w -expand 1 -fill none \
           -side top -padx 30 -pady 5
         radiobutton $audace(base).telecharge_image.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
           -text "$caption(dsc,immediat)" -value 2 -variable conf(dsc,telecharge_mode) -state normal \
           -command "::cameraDSC::ChangerSelectionTelechargementAPN $visuNo"
         pack $audace(base).telecharge_image.rad2 -anchor w -expand 1 -fill none \
           -side top -padx 30 -pady 5
         radiobutton $audace(base).telecharge_image.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
           -text "$caption(dsc,acq_suivante)" -value 3 -variable conf(dsc,telecharge_mode) -state normal \
           -command "::cameraDSC::ChangerSelectionTelechargementAPN $visuNo"
         pack $audace(base).telecharge_image.rad3 -anchor w -expand 1 -fill none \
            -side top -padx 30 -pady 5
      }

      #--- New message window is on
      focus $audace(base).telecharge_image

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).telecharge_image
   }

   proc ChangerSelectionTelechargementAPN { visuNo} {
      global conf

      switch -exact -- $conf(dsc,telecharge_mode) {
         1  {
            #--- Ne pas telecharger
            cam[ ::confVisu::getCamNo $visuNo ] autoload 0
         }
         2  {
            #--- Telechargement immediat
            cam[ ::confVisu::getCamNo $visuNo ] autoload 1
         }
         3  {
            #--- Telechargement pendant la pose suivante
            cam[ ::confVisu::getCamNo $visuNo ] autoload 0
         }
      }
      ::console::affiche_saut "\n"
      ::console::disp "conf(dsc,telecharge_mode) = $conf(dsc,telecharge_mode) cam[ ::confVisu::getCamNo $visuNo ] autoload=[ cam[ ::confVisu::getCamNo $visuNo ] autoload ] \n"
   }

}

#--- Initialisation au demarrage
::cameraDSC::init

