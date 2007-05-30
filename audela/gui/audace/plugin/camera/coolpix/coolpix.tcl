#
# Fichier : coolpix.tcl
# Description : Configuration de l'appareil photo numerique Nikon CoolPix
# Auteur : Robert DELMAS
# Mise a jour $Id: coolpix.tcl,v 1.4 2007-05-30 17:14:49 robertdelmas Exp $
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
   variable private
   global caption

   #--- Initialisation
   set private(frm) $frm

   #--- confToWidget
   ::coolpix::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du commentaire et de la vitesse du port serie
   frame $frm.frame1 -borderwidth 0 -relief raised

      label $frm.frame1.lab1 -text $caption(coolpix,commentaire)
      pack $frm.frame1.lab1 -anchor nw -side top -padx 10 -pady 10

      #--- Frame de la vitesse du port serie
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         label $frm.frame1.frame3.lab1 -text $caption(coolpix,baud)
         pack $frm.frame1.frame3.lab1 -anchor nw -side left -padx 10 -pady 10

         set list_combobox [ list 115200 57600 38400 19200 9600 ]
         ComboBox $frm.frame1.frame3.listeBaud \
            -width 8                           \
            -height [ llength $list_combobox ] \
            -relief sunken                     \
            -borderwidth 1                     \
            -editable 0                        \
            -textvariable confCam(coolpix,baud) \
            -values $list_combobox
         pack $frm.frame1.frame3.listeBaud -anchor nw -side left -padx 0 -pady 10

      pack $frm.frame1.frame3 -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de PhotoPC (Nikon CoolPix)
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(coolpix,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(coolpix,site_web_ref)" \
         "$caption(coolpix,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::coolpix::configureCamera
#    Configure la camera Nikon CoolPix en fonction des donnees contenues dans les variables conf(coolpix,...)
#
proc ::coolpix::configureCamera { camItem } {
   global confCam

   if { [ ::confVisu::getTool 1 ] == "acqapn" } {
      set camNo "0"
      ::acqapn::Off
      ::acqapn::Query
      set confCam($camItem,camNo) $camNo
   } else {
      set camItem $confCam(currentCamItem)
      set confCam($camItem,camName) ""
   }
}

#
# ::coolpix::stop
#    Arrete la camera Nikon CoolPix
#
proc ::coolpix::stop { camItem } {
   if { [ ::confVisu::getTool 1 ] == "acqapn" } {
      ::acqapn::Off
   }
}

#
# ::coolpix::connect
#    Procedure appelee pour connecter la camera Nikon CoolPix
#
proc ::coolpix::connect { } {
   variable private
   global confCam

   if { [ info exists private(frm)] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         ::confCam::appliquer
      } else {
         #--- J'arrete la camera
         ::coolpix::deconnect
         #--- Je copie les parametres de la nouvelle camera dans conf()
         ::coolpix::widgetToConf
         set camItem $confCam(currentCamItem)
         set confCam($camItem,camName) "coolpix"
         ::confCam::configureCamera $camItem
      }
   } else {
      #--- J'arrete la camera
      ::coolpix::deconnect
      #--- Je copie les parametres de la nouvelle camera dans conf()
      ::coolpix::widgetToConf
      set camItem $confCam(currentCamItem)
      set confCam($camItem,camName) "coolpix"
      ::confCam::configureCamera $camItem
   }
}

#
# ::coolpix::deconnect
#    Procedure appelee pour deconnecter la camera Nikon CoolPix
#
proc ::coolpix::deconnect { } {
   global confCam

   set camItem $confCam(currentCamItem)
   set confCam($camItem,camName) "coolpix"
   ::confCam::stopItem $camItem
}

#
# ::coolpix::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::coolpix::getBinningList { } {
   if { [ ::confVisu::getTool 1 ] == "acqapn" } {
      set binningList [ ::acqapn::Formats ]
      return $binningList
   }
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
#    Retourne 1 si le mode longue pose est active
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
   set ShutterOptionList { }
   return $ShutterOptionList
}

