#
# Fichier : coolpix.tcl
# Description : Configuration de l'appareil photo numerique Nikon CoolPix
# Auteur : Robert DELMAS
# Mise a jour $Id: coolpix.tcl,v 1.3 2007-05-19 08:39:45 robertdelmas Exp $
#

namespace eval ::coolpix {
}

#
# ::coolpix::init
#    Initialise les variables conf(coolpix,...) et les captions
#
proc ::coolpix::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera coolpix coolpix.cap ]

   #--- Initialise la variable de la camera Nikon CoolPix
   if { ! [ info exists conf(coolpix,baud) ] } { set conf(coolpix,baud) "115200" }
}

#
# ::coolpix::confToWidget
#    Copie la variable de configuration dans une variable locale
#
proc ::coolpix::confToWidget { } {
   global conf confCam

   #--- Recupere la configuration de la camera Nikon CoolPix dans le tableau confCam(coolpix,...)
   set confCam(coolpix,baud) $conf(coolpix,baud)
}

#
# ::coolpix::widgetToConf
#    Copie la variable locale dans une variable de configuration
#
proc ::coolpix::widgetToConf { } {
   global conf confCam

   #--- Memorise la configuration de la camera Nikon CoolPix dans le tableau conf(coolpix,...)
   set conf(coolpix,baud) $confCam(coolpix,baud)
   #---
   if { [ info exists confCam(coolpix,model) ] } {
      set conf(coolpix,model) $confCam(coolpix,model)
   } else {
      catch { unset conf(coolpix,model) }
   }
}

#
# ::coolpix::fillConfigPage
#    Interface de configuration de la camera Nikon CoolPix
#
proc ::coolpix::fillConfigPage { frm } {
   global audace caption color

   #--- confToWidget
   ::coolpix::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side bottom -fill x -pady 2

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -in $frm.frame1 -side top -fill x -expand 0

   #--- Definition de la vitesse du port serie
   label $frm.lab1 -text $caption(coolpix,baud)
   pack $frm.lab1 -in $frm.frame3 -anchor e -side left -padx 10 -pady 10

   set list_combobox [ list 115200 57600 38400 19200 9600 ]
   ComboBox $frm.listeBaud \
      -width 8             \
      -height [ llength $list_combobox ] \
      -relief sunken       \
      -borderwidth 1       \
      -textvariable confCam(coolpix,baud) \
      -editable 0          \
      -values $list_combobox
   pack $frm.listeBaud -in $frm.frame3 -anchor e -side left -padx 0 -pady 10

   #--- Site web officiel de la Nikon CoolPix
   label $frm.lab103 -text "$caption(coolpix,titre_site_web)"
   pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(coolpix,site_web_ref)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(coolpix,site_web_ref)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      global frmm
      set frm $frmm(Camera14)
      $frm.labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      global frmm
      set frm $frmm(Camera14)
      $frm.labURL configure -fg $color(blue)
   }
}

#
# ::coolpix::configureCamera
#    Configure la camera Nikon CoolPix en fonction des donnees contenues dans les variables conf(coolpix,...)
#
proc ::coolpix::configureCamera { camItem } {
   global caption conf confCam

   set camNo "0"
   ::acqapn::Off
   ::acqapn::Query
   set confCam($camItem,camNo) $camNo
}

#
# ::coolpix::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::coolpix::getBinningList { } {
   set binningList { }
   return $binningList
}

#
# ::coolpix::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::coolpix::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

# ::coolpix::hasCapability
#    Retourne "la valeur de la propriete"
#
#  Parametres :
#     camNo      : Numero de la camera
#     capability : Fonctionnalite de la camera
#
proc ::coolpix::hasCapability { camNo capability } {
   switch $capability {
      window { return 0 }
   }
}

#
# ::coolpix::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::coolpix::hasLongExposure { } {
   return 0
}

#
# ::coolpix::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::coolpix::getLongExposure { } {
   return 0
}

#
# ::coolpix::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::coolpix::hasVideo { } {
   return 1
}

#
# ::coolpix::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::coolpix::hasScan { } {
   return 0
}

#
# ::coolpix::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::coolpix::hasShutter { } {
   return 0
}

#
# ::coolpix::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::coolpix::getShutterOption { } {
   global caption

   set ShutterOptionList { }
   return $ShutterOptionList
}

