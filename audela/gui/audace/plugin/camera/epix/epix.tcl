#
# Fichier : epix.tcl
# Description : Configuration de la camera Raptor
# Auteur : Frederic VACHIER
# Mise à jour $Id$
#

#TODO: rewrite all the file for the epix camera

namespace eval ::epix {
   package provide epix 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] epix.cap ]
}

#
# ::epix::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::epix::getPluginTitle { } {
   global caption

   return "$caption(epix,camera)"
}

#
# ::epix::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::epix::getPluginHelp { } {
   return "epix.htm"
}

#
# ::epix::getPluginType
#    Retourne le type du plugin
#
proc ::epix::getPluginType { } {
   return "camera"
}

#
# ::epix::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::epix::getPluginOS { } {
   return [ list Linux ]
}

#
# ::epix::getCamNo
#    Retourne le numero de la camera
#
proc ::epix::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::epix::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::epix::isReady { camItem } {
   variable private

   if { $private($camItem,camNo) == "0" } {
      #--- Camera KO
      return 0
   } else {
      #--- Camera OK
      return 1
   }
}

#
# ::epix::initPlugin
#    Initialise les variables conf(epix,...)
#
proc ::epix::initPlugin { } {
   variable private
   global audace conf caption

   #--- Initialise les variables de la camera Raptor OSPREY
   if { ! [ info exists conf(epix,tec) ] }         { set conf(epix,tec)       "1" }
   if { ! [ info exists conf(epix,framerate) ] }   { set conf(epix,framerate) "37.5" }
   if { ! [ info exists conf(epix,config) ] }      { set conf(epix,config)    "" }
   if { ! [ info exists conf(epix,mirh) ] }        { set conf(epix,mirh)      "0" }
   if { ! [ info exists conf(epix,mirv) ] }        { set conf(epix,mirv)      "0" }
   if { ! [ info exists conf(epix,CMOStemp) ] }    { set conf(epix,CMOStemp)  "" }
   if { ! [ info exists conf(epix,exposure) ] }    { set conf(epix,exposure)  "0.001" }
   if { ! [ info exists conf(epix,roi_x1) ] }      { set conf(epix,roi_x1)    "0" }
   if { ! [ info exists conf(epix,roi_y1) ] }      { set conf(epix,roi_y1)    "0" }
   if { ! [ info exists conf(epix,roi_x2 ] }       { set conf(epix,roi_x2)    "2047" }
   if { ! [ info exists conf(epix,roi_y2) ] }      { set conf(epix,roi_y2)    "2047" }
   if { ! [ info exists conf(epix,binning) ] }     { set conf(epix,binning)   "1" }
   if { ! [ info exists conf(epix,extconfig) ] }   { set conf(epix,extconfig) "0" }
   if { ! [ info exists conf(epix,hdr) ] }         { set conf(epix,hdr)       "0" }
   if { ! [ info exists conf(epix,videomode) ] }   { set conf(epix,videomode) "ffr" }

   #--- Initialisation
   set private(A,camNo)  "0"
   set private(B,camNo)  "0"
   set private(C,camNo)  "0"
   set private(CMOStemp) "$caption(epix,temperature_CCD)"
}

#
# ::epix::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::epix::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Andor dans le tableau private(...)
   set private(tec)         $conf(epix,tec)
   set private(framerate)   $conf(epix,framerate)
   set private(config)      $conf(epix,config)
   set private(extconfig)   $conf(epix,extconfig)
   set private(mirh)        $conf(epix,mirh)
   set private(mirv)        $conf(epix,mirv)
   set private(CMOStemp)    $conf(epix,CMOStemp)
   set private(exposure)    $conf(epix,exposure)
   set private(roi_x1)      $conf(epix,roi_x1)
   set private(roi_y1)      $conf(epix,roi_y1)
   set private(roi_x2)      $conf(epix,roi_x2)
   set private(roi_y2)      $conf(epix,roi_y2)
   set private(hdr)         $conf(epix,hdr)
   set private(videomode)   $conf(epix,videomode)
   set private(binning)     "$conf(epix,binning)x$conf(epix,binning)"
}

#
# ::epix::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::epix::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Raptor dans le tableau conf(epix,...)
   set conf(epix,tec)         $private(tec)
   set conf(epix,framerate)   $private(framerate)
   set conf(epix,config)      $private(config)
   set conf(epix,extconfig)   $private(extconfig)
   set conf(epix,mirh)        $private(mirh)
   set conf(epix,mirv)        $private(mirv)
   set conf(epix,CMOStemp)    $private(CMOStemp)
   set conf(epix,exposure)    $private(exposure)
   set conf(epix,roi_x1)      $private(roi_x1)
   set conf(epix,roi_y1)      $private(roi_y1)
   set conf(epix,roi_x2)      $private(roi_x2)
   set conf(epix,roi_y2)      $private(roi_y2)
   set conf(epix,hdr)         $private(hdr)
   set conf(epix,videomode)   $private(videomode)
   set conf(epix,binning)     [ string index $private(binning) 0 ]
}

#
# ::epix::fillConfigPage
#    Interface de configuration de la camera Andor
#
proc ::epix::fillConfigPage { frm camItem } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::epix::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- External file configuration frame
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Video format file definition
      frame $frm.frame1.frame1 -borderwidth 0 -relief raised

         checkbutton $frm.frame1.frame1.check -text "$caption(epix,extconfig)" -highlightthickness 0 -variable ::epix::private(extconfig) -command "::epix::extconfig $camItem"
         pack $frm.frame1.frame1.check -anchor w -side top -padx 10 -pady 1

         label $frm.frame1.frame1.lab2 -text "$caption(epix,config)"
         pack $frm.frame1.frame1.lab2 -anchor center -side left -padx 1

         entry $frm.frame1.frame1.host -width 30 -textvariable ::epix::private(config) -state disabled
         pack $frm.frame1.frame1.host -anchor center -side left -padx 1

         button $frm.frame1.frame1.explore -text "$caption(epix,browse)" -width 1 -command ::epix::explore -state disabled
         pack $frm.frame1.frame1.explore -side left -padx 10 -pady 5 -ipady 5

      pack $frm.frame1.frame1 -side top -fill none -anchor n

      #--- ROI and binning
      frame $frm.frame1.frame2 -borderwidth 0 -relief raised

         #--- ROI
         #frame $frm.frame1.frame2.frametitle -borderwidth 0 -relief raised

         label $frm.frame1.frame2.lab1 -text "ROI"
         pack $frm.frame1.frame2.lab1 -anchor center -side top -pady 2

         #pack $frm.frame1.frame2.frametitle -side top -fill both -expand 1 -anchor n -pady 2

         #--- Frame roi_x1
         frame $frm.frame1.frame2.frame1 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame1.lab1 -text "x1"
         pack $frm.frame1.frame2.frame1.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame1.roi_x1 -width 4 -textvariable ::epix::private(roi_x1) -state disabled
         pack $frm.frame1.frame2.frame1.roi_x1 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame1 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_y1
         frame $frm.frame1.frame2.frame2 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame2.lab1 -text "y1"
         pack $frm.frame1.frame2.frame2.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame2.roi_y1 -width 4 -textvariable ::epix::private(roi_y1) -state disabled
         pack $frm.frame1.frame2.frame2.roi_y1 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame2 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_x2
         frame $frm.frame1.frame2.frame3 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame3.lab1 -text "x2"
         pack $frm.frame1.frame2.frame3.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame3.roi_x2 -width 4 -textvariable ::epix::private(roi_x2) -state disabled
         pack $frm.frame1.frame2.frame3.roi_x2 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame3 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_y2
         frame $frm.frame1.frame2.frame4 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame4.lab1 -text "y2"
         pack $frm.frame1.frame2.frame4.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame4.roi_y2 -width 4 -textvariable ::epix::private(roi_y2) -state disabled
         pack $frm.frame1.frame2.frame4.roi_y2 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame4 -side top -fill both -expand 1 -anchor center -pady 2

      pack $frm.frame1.frame2 -side left -fill none -expand 1 -anchor center

      #--- Frame binning
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

      label $frm.frame1.frame3.lab1 -text "Binning"
      pack $frm.frame1.frame3.lab1 -anchor center -side top -pady 2

      set list_binning [ list "1x1" "2x2" "4x4" ]
      ComboBox $frm.frame1.frame3.bin -width 10 -height [ llength $list_binning ] -relief sunken -borderwidth 1 -editable 0 -textvariable ::epix::private(binning) -values $list_binning -state disabled
      pack $frm.frame1.frame3.bin -anchor center -side top -padx 10 -pady 5

      pack $frm.frame1.frame3 -side left -fill none -expand 1 -anchor center

   pack $frm.frame1 -side left -fill both -expand 1

   #--- Configuration frame
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Top frame
      frame $frm.frame2.frame1 -borderwidth 0  -relief raised

         #--- Mirror configuration frame
         frame $frm.frame2.frame1.frame1 -borderwidth 0 -relief raised

         #--- Mirror in x and in y
         checkbutton $frm.frame2.frame1.frame1.mirx -text "$caption(epix,mirror_x)" -highlightthickness 0 \
            -variable ::epix::private(mirh)
         pack $frm.frame2.frame1.frame1.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame2.frame1.frame1.miry -text "$caption(epix,mirror_y)" -highlightthickness 0 \
            -variable ::epix::private(mirv)
         pack $frm.frame2.frame1.frame1.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame2.frame1.frame1 -side top -fill none -expand 1 -anchor center

         #--- Temperature and TEC frame
         #frame $frm.frame2.frame1.frame2 -borderwidth 0 -relief raised

         #-- CMOS sensor temperature
         #label $frm.frame2.frame1.frame2.cmostemp -textvariable ::epix::private(CMOStemp)
         #pack $frm.frame2.frame1.frame2.cmostemp -side top -fill x -padx 20 -pady 5

         #pack $frm.frame2.frame1.frame2 -side top -fill none -expand 1 -anchor center

      pack $frm.frame2.frame1 -side top -fill both -expand 1 -anchor center

      #--- Bottom frame
      frame $frm.frame2.frame2 -borderwidth 0 -relief raised

         #--- Exposure frame
         frame $frm.frame2.frame2.frame1 -borderwidth 0 -relief raised

            #--- Exposure time
            frame $frm.frame2.frame2.frame1.frame1 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame1.frame1.lab1 -text "$caption(epix,exposure)"
            pack $frm.frame2.frame2.frame1.frame1.lab1 -anchor center -side left -padx 5 -pady 5

            entry $frm.frame2.frame2.frame1.frame1.exp -width 8 -textvariable ::epix::private(exposure)
            pack $frm.frame2.frame2.frame1.frame1.exp -anchor center -side left -padx 5 -pady 5

            pack $frm.frame2.frame2.frame1.frame1 -side top -fill none -expand 1 -anchor center

            #--- High dynamic range
            frame $frm.frame2.frame2.frame1.frame2 -borderwidth 0 -relief raised

            checkbutton $frm.frame2.frame2.frame1.frame2.hdr -text "$caption(epix,hdr)" -highlightthickness 0 \
               -variable ::epix::private(hdr)
            pack $frm.frame2.frame2.frame1.frame2.hdr -side top -fill none -expand 1 -anchor center

            pack $frm.frame2.frame2.frame1.frame2 -side top -fill none -expand 1 -anchor center

         pack $frm.frame2.frame2.frame1 -side top -fill none -expand 1 -anchor center

         #--- Frame rate frame
         frame $frm.frame2.frame2.frame2 -borderwidth 0 -relief raised

            #--- Frame rate
            frame $frm.frame2.frame2.frame2.frame1 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame2.frame1.lab1 -text "$caption(epix,framerate)"
            pack $frm.frame2.frame2.frame2.frame1.lab1 -anchor w -side left -padx 5 -pady 5

            entry $frm.frame2.frame2.frame2.frame1.fr -width 5 -textvariable ::epix::private(framerate)
            pack $frm.frame2.frame2.frame2.frame1.fr -anchor center -side left -padx 5 -pady 5

            pack $frm.frame2.frame2.frame2.frame1 -side top -fill none -expand 1 -anchor center

            #--- Video mode (FFR or ITR)
            frame $frm.frame2.frame2.frame2.frame2 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame2.frame2.lab1 -text "$caption(epix,videomode)"
            pack $frm.frame2.frame2.frame2.frame2.lab1 -anchor center -side left -padx 5 -pady 5

            set list_binning [ list "ffr" "itr" ]
            ComboBox $frm.frame2.frame2.frame2.frame2.bin -width 10 -height [ llength $list_binning ] -relief sunken -borderwidth 1 -editable 0 -textvariable ::epix::private(videomode) -values $list_binning
            pack $frm.frame2.frame2.frame2.frame2.bin -anchor center -side top -padx 10 -pady 5

            pack $frm.frame2.frame2.frame2.frame2 -side top -fill both -expand 1 -anchor center

         pack $frm.frame2.frame2.frame2 -side top -fill none -expand 1 -anchor center

      pack $frm.frame2.frame2 -side top -fill both -expand 1 -anchor center

   pack $frm.frame2 -side left -fill both -expand 1

   #::epix::dispTempCMOS
}

#
# ::epix::configureCamera
#    Configure la camera Andor en fonction des donnees contenues dans les variables conf(epix,...)
#
proc ::epix::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je mets conf(epix,config) entre guillemets pour le cas ou le nom du repertoire contient des espaces
      #--- Je cree la camera
      if {$private(config) eq ""} {
         set camNo [ cam::create epix -debug_directory $::audace(rep_log) ]
      } else {
         set camNo [ cam::create epix -debug_directory $::audace(rep_log) -config $conf(epix,config) $conf(epix,roi_x1) $conf(epix,roi_y1) $conf(epix,roi_x2) $conf(epix,roi_y2) $conf(epix,binning) $conf(epix,binning) ]
      }
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'exposition
      cam$camNo exposure $conf(epix,exposure)
      #--- Je configure le refroidissement

      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(epix,mirh)
      cam$camNo mirrorv $conf(epix,mirv)
      #--- Je configure le frame rate
      cam$camNo framerate $conf(epix,framerate)
      #--- Je configure la ROI
      #cam$camNo roi $conf(epix,roi)
      #--- Je configure le binning
      #cam$camNo bin $conf(epix,binning)
      #--- Je mesure la temperature du capteur CMOS
      ::epix::dispTempCMOS $camItem
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::epix::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::epix::stop
#    Arrete la camera Andor
#
proc ::epix::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::epix::dispTempCMOS
#    Affiche la temperature du capteur CMOS
#
proc ::epix::dispTempCMOS { camItem } {
   variable private
   global caption

   if { [ catch { set temp_cmos [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_cmos [ format "%+5.2f" $temp_cmos ]
      set private(CMOStemp)   "$caption(epix,temperature_CCD) $temp_cmos $caption(epix,deg_c)"
   } else {
      set temp_cmos ""
      set private(CMOStemp) "$caption(epix,temperature_CCD) $temp_cmos"
   }
   console::affiche_entete $private(CMOStemp)
   console::affiche_saut "\n"
}

#
# ::epix::checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::epix::checkConfigRefroidissement { } {
}

#
# ::epix::setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::epix::setTempCCD { camItem } {
   global conf

   return "$conf(epix,temp)"
}

#
# ::epix::explore
#    Procedure pour designer les fichiers de configuration
#
proc ::epix::explore { } {
   variable private
   global audace caption

   set types {
      {"Video Format Files" {.fmt} TEXT}
      {"All files" * TEXT}
   }

   set inDir [ file join /usr local xcap data ]

   set private(config) [ tk_getOpenFile -title "$caption(epix,folder)" \
      -initialdir $inDir -parent [ winfo toplevel $private(frm) ] -defaultextension {.fmt} -filetypes $types ]
}

#
# ::epix::enable_config
#    Enables or disables ROI and binning
#
proc ::epix::extconfig { camNo } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if {$private(extconfig) == "1"} {
         $frm.frame1.frame3.bin configure -state normal
         $frm.frame1.frame2.frame1.roi_x1 configure -state normal
         $frm.frame1.frame2.frame2.roi_y1 configure -state normal
         $frm.frame1.frame2.frame3.roi_x2 configure -state normal
         $frm.frame1.frame2.frame4.roi_y2 configure -state normal
         $frm.frame1.frame1.host configure -state normal
         $frm.frame1.frame1.explore configure -state normal
      } else {
         set ::epix::private(roi_x1) "0"
         set ::epix::private(roi_y1) "0"
         set ::epix::private(roi_x2) "2047"
         set ::epix::private(roi_y2) "2047"
         set ::epix::private(config) ""
         set ::epix::private(binning) "1x1"
         $frm.frame1.frame3.bin configure -state disabled
         $frm.frame1.frame2.frame1.roi_x1 configure -state disabled
         $frm.frame1.frame2.frame2.roi_y1 configure -state disabled
         $frm.frame1.frame2.frame3.roi_x2 configure -state disabled
         $frm.frame1.frame2.frame4.roi_y2 configure -state disabled
         $frm.frame1.frame1.host configure -state disabled
         $frm.frame1.frame1.explore configure -state disabled
      }
   }

   ::epix::widgetToConf $camNo

}

#
# ::epix::extract_config
#    Procedure that extract the ROI and the binning from the current file
#
#
# ::epix::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# dynamic :          Retourne la liste de la dynamique haute et basse
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasTempSensor      Retourne l'existence du capteur de temperature (1 : Oui, 0 : Non)
# hasSetTemp         Retourne l'existence d'une consigne de temperature (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::epix::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 4x4 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 4095 0 ] }
      hasBinning       { return 0 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasTempSensor    { return 1 }
      hasSetTemp       { return 0 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      name             {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) name ]
         } else {
            return ""
         }
      }
      product          {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) product ]
         } else {
            return ""
         }
      }
   }
}

