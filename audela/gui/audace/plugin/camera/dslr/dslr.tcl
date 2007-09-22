#
# Fichier : dslr.tcl
# Description : Gestion du telechargement des images d'un APN (DSLR)
# Auteur : Robert DELMAS
# Mise a jour $Id: dslr.tcl,v 1.14 2007-09-22 06:39:48 robertdelmas Exp $
#

namespace eval ::dslr {
   package provide dslr 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] dslr.cap ]
}

#
# ::dslr::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::dslr::getPluginTitle { } {
   global caption

   return "$caption(dslr,camera)"
}

#
#  ::dslr::getPluginHelp
#     Retourne la documentation du driver
#
proc ::dslr::getPluginHelp { } {
   return "dslr.htm"
}

#
# ::dslr::getPluginType
#    Retourne le type de driver
#
proc ::dslr::getPluginType { } {
   return "camera"
}

#
# ::dslr::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::dslr::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::dslr::initPlugin
#    Initialise les variables conf(dslr,...)
#
proc ::dslr::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera APN (DSLR)
   if { ! [ info exists conf(dslr,longuepose) ] }           { set conf(dslr,longuepose)           "0" }
   if { ! [ info exists conf(dslr,longueposeport) ] }       { set conf(dslr,longueposeport)       "LPT1:" }
   if { ! [ info exists conf(dslr,longueposelinkbit) ] }    { set conf(dslr,longueposelinkbit)    "0" }
   if { ! [ info exists conf(dslr,longueposestartvalue) ] } { set conf(dslr,longueposestartvalue) "1" }
   if { ! [ info exists conf(dslr,longueposestopvalue) ] }  { set conf(dslr,longueposestopvalue)  "0" }
   if { ! [ info exists conf(dslr,statut_service) ] }       { set conf(dslr,statut_service)       "1" }
   if { ! [ info exists conf(dslr,mirh) ] }                 { set conf(dslr,mirh)                 "0" }
   if { ! [ info exists conf(dslr,mirv) ] }                 { set conf(dslr,mirv)                 "0" }
   if { ! [ info exists conf(dslr,telecharge_mode) ] }      { set conf(dslr,telecharge_mode)      "2" }
   if { ! [ info exists conf(dslr,utiliser_cf) ] }          { set conf(dslr,utiliser_cf)          "1" }
   if { ! [ info exists conf(dslr,supprimer_image) ] }      { set conf(dslr,supprimer_image)      "0" }
}

#
# ::dslr::setLoadParameters
#    Cree la boite de telechargement des images
#
proc ::dslr::setLoadParameters { visuNo} {
   global audace caption conf

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

#
# ::dslr::utiliserCF
#    Utilise la carte memoire CF
#
proc ::dslr::utiliserCF { visuNo } {
   global audace conf

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

#
# ::dslr::supprimerImage
#    Supprime une image
#
proc ::dslr::supprimerImage { visuNo } {
   global conf

   cam[ ::confVisu::getCamNo $visuNo ] delete $conf(dslr,supprimer_image)
}

#
# ::dslr::changerSelectionTelechargementAPN
#    Change le mode de telechargement
#
proc ::dslr::changerSelectionTelechargementAPN { visuNo} {
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
# ::dslr::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::dslr::getBinningList { camNo } {
   set binningList [ cam$camNo quality list ]
   return $binningList
}

#
# ::dslr::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::dslr::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ ::dslr::getBinningList $camNo ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 0 }
      hasFormat        { return 1 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasVideo         { return 0 }
      hasWindow        { return 0 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList      { return [ list "" ] }
   }
}

