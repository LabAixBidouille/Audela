#
# Fichier : dslr.tcl
# Description : Gestion du telechargement des images d'un APN (DSLR)
# Auteur : Robert DELMAS
# Mise a jour $Id: dslr.tcl,v 1.11 2007-05-26 22:26:40 robertdelmas Exp $
#

namespace eval dslr {

   proc init { } {
      global audace
      global conf

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) camera dslr dslr.cap ]

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(dslr,telecharge_mode) ] } { set conf(dslr,telecharge_mode) "2" }
      if { ! [ info exists conf(dslr,utiliser_cf) ] }     { set conf(dslr,utiliser_cf)     "1" }
      if { ! [ info exists conf(dslr,supprimer_image) ] } { set conf(dslr,supprimer_image) "0" }
   }

   proc setLoadParameters { visuNo} {
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
      wm title $audace(base).telecharge_image "$caption(dslr,telecharger)"
      if { [ winfo exists $audace(base).confCam ] } {
         wm deiconify $audace(base).confCam
         wm transient $audace(base).telecharge_image $audace(base).confCam
         set posx_telecharge_image [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 1 ]
         set posy_telecharge_image [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 2 ]
         wm geometry $audace(base).telecharge_image +[ expr $posx_telecharge_image + 300 ]+[ expr $posy_telecharge_image + 20 ]
      } else {
         wm transient $audace(base).telecharge_image $audace(base)
         set posx_telecharge_image [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_telecharge_image [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $audace(base).telecharge_image +[ expr $posx_telecharge_image + 150 ]+[ expr $posy_telecharge_image + 90 ]
      }

      #--- utilise carte memoire CF
      checkbutton $audace(base).telecharge_image.utiliserCF -text "$caption(dslr,utiliser_cf)" \
         -highlightthickness 0 -variable conf(dslr,utiliser_cf) \
         -command "::dslr::utiliserCF $visuNo"
      pack $audace(base).telecharge_image.utiliserCF -anchor w -side top -padx 20 -pady 10

      radiobutton $audace(base).telecharge_image.rad1 -anchor nw -highlightthickness 1 \
        -padx 0 -pady 0 -state normal \
        -text "$caption(dslr,pas_telecharger)" -value 1 -variable conf(dslr,telecharge_mode) \
        -command "::dslr::changerSelectionTelechargementAPN $visuNo"
      pack $audace(base).telecharge_image.rad1 -anchor w -expand 1 -fill none \
        -side top -padx 30 -pady 5
      radiobutton $audace(base).telecharge_image.rad2 -anchor nw -highlightthickness 0 \
        -padx 0 -pady 0 -state normal \
        -text "$caption(dslr,immediat)" -value 2 -variable conf(dslr,telecharge_mode)\
        -command "::dslr::changerSelectionTelechargementAPN $visuNo"
      pack $audace(base).telecharge_image.rad2 -anchor w -expand 1 -fill none \
        -side top -padx 30 -pady 5
      radiobutton $audace(base).telecharge_image.rad3 -anchor nw -highlightthickness 0 \
        -padx 0 -pady 0 -state normal -disabledforeground #999999 \
        -text "$caption(dslr,acq_suivante)" -value 3 -variable conf(dslr,telecharge_mode) \
        -command "::dslr::changerSelectionTelechargementAPN $visuNo"
      pack $audace(base).telecharge_image.rad3 -anchor w -expand 1 -fill none \
         -side top -padx 30 -pady 5

      #--- supprime l'image sur la carte memoire apres le chargement
      checkbutton $audace(base).telecharge_image.supprime_image -text "$caption(dslr,supprimer_image)" \
         -highlightthickness 0 -variable conf(dslr,supprimer_image) \
         -command "::dslr::supprimerImage $visuNo"
      pack $audace(base).telecharge_image.supprime_image -anchor w -side top -padx 20 -pady 10

      #--- New message window is on
      focus $audace(base).telecharge_image

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).telecharge_image

      #---
      if { $conf(dslr,utiliser_cf) == "0" } {
         $audace(base).telecharge_image.rad3 configure -state disabled
         $audace(base).telecharge_image.supprime_image configure -state disabled
      } else {
         $audace(base).telecharge_image.rad3 configure -state normal
         $audace(base).telecharge_image.supprime_image configure -state normal
      }

   }

   proc utiliserCF { visuNo } {
      global conf
      global audace

      #--- je configure la camera
      set camNo [::confVisu::getCamNo $visuNo]
      set resultUsecf [ catch { cam$camNo usecf $conf(dslr,utiliser_cf) } messageUseCf ]
      if { $resultUsecf == 1 } {
         tk_messageBox -message "$messageUseCf" -icon error
         #--- si l'appareil n'a pas de carte memoire
         #--- je change l'option carte memoire pour l'appareil
         set conf(dslr,utiliser_cf) 0
         cam$camNo usecf $conf(dslr,utiliser_cf)
      }

      #--- je mets a jour les widgets
      if { $conf(dslr,utiliser_cf) == "0" } {
         $audace(base).telecharge_image.rad3 configure -state disabled
         $audace(base).telecharge_image.supprime_image configure -state disabled
         if { $conf(dslr,telecharge_mode) == "3" } {
            #--- j'annule le mode 3 car il n'est pas possible sans CF
            set conf(dslr,telecharge_mode) "2"
         }
      } else {
         $audace(base).telecharge_image.rad3 configure -state normal
         $audace(base).telecharge_image.supprime_image configure -state normal
      }

   }

   proc supprimerImage { visuNo } {
      global conf

      cam[ ::confVisu::getCamNo $visuNo ] delete $conf(dslr,supprimer_image)
   }

   proc changerSelectionTelechargementAPN { visuNo} {
      global conf

      switch -exact -- $conf(dslr,telecharge_mode) {
         1 {
            #--- Ne pas telecharger
            cam[ ::confVisu::getCamNo $visuNo ] autoload 0
         }
         2 {
            #--- Telechargement immediat
            cam[ ::confVisu::getCamNo $visuNo ] autoload 1
         }
         3 {
            #--- Telechargement pendant la pose suivante
            cam[ ::confVisu::getCamNo $visuNo ] autoload 0
         }
      }
      ::console::affiche_saut "\n"
      ::console::disp "conf(dslr,telecharge_mode) = $conf(dslr,telecharge_mode) cam[ ::confVisu::getCamNo $visuNo ] autoload=[ cam[ ::confVisu::getCamNo $visuNo ] autoload ] \n"
   }

   #
   # getBinningList
   #    Retourne la liste des binnings disponibles de la camera
   #
   proc getBinningList { camNo } {
      set binningList [ cam$camNo quality list ]
      return $binningList
   }

   #
   # hasCapability
   #    Retourne "la valeur de la propriete"
   #
   #  Parametres :
   #     camNo      : Numero de la camera
   #     capability : Fonctionnalite de la camera
   #
   proc hasCapability { camNo capability } {
      switch $capability {
         window { return 0 }
      }
   }

}

#--- Initialisation au demarrage
::dslr::init

