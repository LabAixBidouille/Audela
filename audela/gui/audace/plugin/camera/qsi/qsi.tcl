#
# Fichier : qsi.tcl
# Description : Configuration de la camera QSI
# Auteur : Michel Pujol
# Mise a jour $Id: qsi.tcl,v 1.2 2009-07-11 17:11:38 robertdelmas Exp $
#

namespace eval ::qsi {
   package provide qsi 1.0
   package require audela 1.5.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] qsi.cap ]
}

#
# ::qsi::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::qsi::getPluginTitle { } {
   global caption

   return "$caption(qsi,camera)"
}

#
# ::qsi::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::qsi::getPluginHelp { } {
   return "qsi.htm"
}

#
# ::qsi::getPluginType
#    Retourne le type du plugin
#
proc ::qsi::getPluginType { } {
   return "camera"
}

#
# ::qsi::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::qsi::getPluginOS { } {
   return [ list Windows ]
}

#
# ::qsi::getCamNo
#    Retourne le numero de la camera
#
proc ::qsi::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::qsi::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::qsi::isReady { camItem } {
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
# ::qsi::initPlugin
#    Initialise les variables conf(qsi,...)
#
proc ::qsi::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera
   if { ! [ info exists conf(qsi,mirh) ] }           { set conf(qsi,mirh)           0 }
   if { ! [ info exists conf(qsi,mirv) ] }           { set conf(qsi,mirv)           0 }
   if { ! [ info exists conf(qsi,cool) ] }           { set conf(qsi,cool)           0 }
   if { ! [ info exists conf(qsi,setTemperature) ] } { set conf(qsi,setTemperature) 0 }
   if { ! [ info exists conf(qsi,foncobtu) ] }       { set conf(qsi,foncobtu)       2 }
   if { ! [ info exists conf(qsi,filterNo) ] }       { set conf(qsi,filterNo)       0 }

   #--- Initialisation
   set private(A,camNo)     "0"
   set private(B,camNo)     "0"
   set private(C,camNo)     "0"
   set private(power)       "$caption(qsi,puissance_peltier_--)"
   set private(frm)         ""
   set private(filterNames) ""
   ###set private(temperature) $caption(qsi,ccdTemp)
}

#
# ::qsi::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::qsi::confToWidget { } {
   variable widget
   global conf caption

   #--- Recupere la configuration de la camera dans le tableau private(...)
   set widget(mirh)     $conf(qsi,mirh)
   set widget(mirv)     $conf(qsi,mirv)
   set widget(foncobtu) [ lindex "opened $caption(qsi,obtu_ferme) $caption(qsi,obtu_synchro)" $conf(qsi,foncobtu) ]
   ###set widget(cool)           $conf(qsi,cool)
   ###set widget(setTemperature) $conf(qsi,setTemperature)
}

#
# ::qsi::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::qsi::widgetToConf { camItem } {
   variable widget
   global conf

   #--- Memorise la configuration de la camera dans le tableau conf()
   set conf(qsi,mirh) $widget(mirh)
   set conf(qsi,mirv) $widget(mirv)
   ###set conf(qsi,cool)           $widget(cool)
   ###set conf(qsi,setTemperature) $widget(setTemperature)
}

#
# ::qsi::fillConfigPage
#    Fenetre de configuration de la camera
#
proc ::qsi::fillConfigPage { frm camItem } {
   variable private
   variable widget
   global caption

   set private(frm) $frm
   #--- confToWidget
   ::qsi::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame1.frame4.mirx -text "$caption(qsi,miroir_x)" -highlightthickness 0 \
            -variable ::qsi::widget(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(qsi,miroir_y)" -highlightthickness 0 \
            -variable ::qsi::widget(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor nw -side left -fill x -padx 20

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la camera
   frame $frm.frame2 -borderwidth 0 -relief raised

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(qsi,site_web_ref)" \
         "$caption(qsi,site_web_ref)" ]
      pack $labelName -side bottom -fill x -pady 2

      label $frm.frame2.lab103 -text "$caption(qsi,titre_site_web)"
      pack $frm.frame2.lab103 -side bottom -fill x -pady 2

      #--- Frame du refroidissement et de la temperature du capteur CCD
      frame $frm.frame2.frame6 -borderwidth 0 -relief raised

         #--- Frame du refroidissement
         frame $frm.frame2.frame6.frame7 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            checkbutton $frm.frame2.frame6.frame7.cool -text "$caption(qsi,refroidissement)" -highlightthickness 0 \
               -variable ::conf(qsi,cool) -command "::qsi::setConfigTemperature $camItem"
            pack $frm.frame2.frame6.frame7.cool -anchor w -side left -padx 0 -pady 5 -expand 0

            entry $frm.frame2.frame6.frame7.setTemp -textvariable ::conf(qsi,setTemperature) -width 4 -justify center
            pack $frm.frame2.frame6.frame7.setTemp -anchor w -side left -padx 5 -pady 5 -expand 0

            label $frm.frame2.frame6.frame7.tempdeg -text "$caption(qsi,deg_c) $caption(qsi,refroidissement_1)"
            pack $frm.frame2.frame6.frame7.tempdeg -anchor w -side left -padx 0 -pady 5 -expand 0

         pack $frm.frame2.frame6.frame7 -side top -fill none -padx 30 -expand 0

         #--- Frame de la puissance de refroidissement
         frame $frm.frame2.frame6.frame8 -borderwidth 0 -relief raised

            label $frm.frame2.frame6.frame8.power -textvariable ::qsi::private(power)
            pack $frm.frame2.frame6.frame8.power -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame8 -side top -fill x -padx 30

         #--- Frame de la temperature
         frame $frm.frame2.frame6.frame9 -borderwidth 0 -relief raised

            label $frm.frame2.frame6.frame9.ccdtemp -textvariable ::qsi::private(temperature)
            pack $frm.frame2.frame6.frame9.ccdtemp -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame9 -side top -fill x -padx 30

         #--- Frame de la roue a filtre
         frame $frm.frame2.frame6.wheel -borderwidth 0 -relief raised

            label $frm.frame2.frame6.wheel.filterLabel -text $caption(qsi,filters) -state disabled
            pack $frm.frame2.frame6.wheel.filterLabel -side left -fill x -padx 20 -pady 5

            #--- Choix du filtre
            ComboBox $frm.frame2.frame6.wheel.filterList \
               -width 20        \
               -height [ llength $private(filterNames) ] \
               -relief sunken  \
               -borderwidth 1  \
               -modifycmd "::qsi::onSelectFilter $camItem $frm.frame2.frame6.wheel.filterList" \
               -editable 1     \
               -state disabled \
               -values $private(filterNames)
            pack $frm.frame2.frame6.wheel.filterList -in $frm.frame2.frame6.wheel -anchor center -side left -padx 0

         pack $frm.frame2.frame6.wheel -side top -fill x -padx 30

      pack $frm.frame2.frame6 -side left -expand 0 -padx 60

   ###pack $frm.frame2 -side top -fill both -expand 1

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- j'adapte l'etat des widgets
   ::qsi::setWigetState $camItem
}

#
# ::qsi::onSelectFilter
#    recupere le numero du filtre quand on change la selection dans la combbox
#
proc ::qsi::onSelectFilter { camItem tkCombo } {
   variable private

   set ::conf(qsi,filterNo) [$tkCombo  getvalue]
   #--- j'envoie la commande a la camera
   cam$private($camItem,camNo) wheel position $::conf(qsi,filterNo)
}

#
# ::qsi::configureCamera
#    Configure la camera en fonction des donnees contenues dans les variables conf(qsi,...)
#
proc ::qsi::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "CameraUnique"
      }
      #--- Je cree la camera
      set camNo [ cam::create qsi USB ]
      console::affiche_erreur "$caption(qsi,port_camera) $caption(qsi,2points) USB\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'orientation des miroirs par defaut
      cam$camNo mirrorh $conf(qsi,mirh)
      cam$camNo mirrorv $conf(qsi,mirv)

      #--- Je configure l'obturateur
      switch -exact -- $conf(qsi,foncobtu) {
         0 {
            cam$camNo shutter "opened"
         }
         1 {
            cam$camNo shutter "closed"
         }
         2 {
            cam$camNo shutter "synchro"
         }
      }
      #--- Je configure la roue a filtre
      set private(filterNames) [cam$camNo wheel names]
      if { [llength $private(filterNames)] > 0 } {
         if { $::conf(qsi,filterNo) >= [llength $private(filterNames)] } {
            #--- si le numero de filter ne correspond pas a un filtre existant
            #--- je remplace par le numero du premier filtre
            set ::conf(qsi,filterNo) 0
         }
         $private(frm).frame2.frame6.wheel.filterList configure -values  $private(filterNames)
         $private(frm).frame2.frame6.wheel.filterList setvalue "@$::conf(qsi,filterNo)"
         cam$camNo wheel position $::conf(qsi,filterNo)
         console::disp "Camera QSI: connexion avec roue a filtre\n"
      } else {
         console::disp "Camera QSI: connexion sans roue a filtre\n"
      }
      #--- j'adapte l'etat des widgets
      ::qsi::setWigetState $camItem
      #--- Je configure le refroidissement
      ::qsi::setConfigTemperature $camItem

   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::qsi::stop $camItem
      #--- Je transmets l'erreur a la procedure appellante
      error $::errorInfo
   }
}

#
# ::qsi::stop
#    Arrete la camera
#
proc ::qsi::stop { camItem } {
   variable private
   global conf

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }

   #--- j'adapte l'etat des widgets
   ::qsi::setWigetState $camItem
}

# ::qsi::getPluginProperty
#    Retourne la valeur de la propriete
#    (voir la liste des proprietes dans confCam::getPluginProperty)
# Parametre :
#    propertyName : Nom de la propriete
#
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
proc ::qsi::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 65535 0 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasTempSensor    { return 1 }
      hasSetTemp       { return 1 }
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
      shutterList      {
         #--- F + S
         return [ list $::caption(qsi,obtu_ferme) $::caption(qsi,obtu_synchro) ]
      }
   }
}

#
# ::qsi::setWigetState
#    change l'etat widgets "normal" si la camera est connectee
#    change l'etat widgets "disabled" si la camera est deconnectee
#
proc ::qsi::setWigetState { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::qsi::isReady $camItem ] == 1 } {
            $private(frm).frame2.frame6.frame7.cool configure -state normal
            if { $private(filterNames) != "" } {
               $frm.frame2.frame6.wheel.filterLabel configure -state normal
               $frm.frame2.frame6.wheel.filterList  configure -state normal
            }
         } else {
            $private(frm).frame2.frame6.frame7.cool configure -state disabled
            $frm.frame2.frame6.wheel.filterLabel configure -state disabled
            $frm.frame2.frame6.wheel.filterList  configure -state disabled
         }
      }
   }
}

#
# ::qsi::setConfigTemperature
#    Configure le widget de la consigne en temperature
#
proc ::qsi::setConfigTemperature { camItem } {
   variable private

   #--- petit raccourci bien prayique
   set camNo $private($camItem,camNo)

   #--- je configure la camera
   if { $::conf(qsi,cool) == "1" } {
      #-- j'envoi la consigne de temperature
      cam$camNo cooler check $::conf(qsi,setTemperature)
      #-- je demarre le refroidissement
      cam$camNo cooler on
      #--- Je lance la recuperation periodique de la temerature
      if { [ info exists private(aftertemp) ] == "0" } {
         ::qsi::displayTemperature $camItem
      }
   } else {
      #--- J'arrete la recuperation periodique de la temerature
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
      #-- j'arrete le refroidissement
      cam$camNo cooler off
   }

   #--- je rafraichis l'affichage
   if { [ info exists private(frm) ] } {
      set frm $private(frm)
     if { [ winfo exists $frm ] } {
         if { $::conf(qsi,cool) == "1" } {
            ###pack $frm.frame2.frame6.frame7.setTemp -anchor center -side left -padx 5 -pady 5
            ###pack $frm.frame2.frame6.frame7.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame2.frame6.frame7.setTemp configure -state normal
            $frm.frame2.frame6.frame7.tempdeg configure -state normal
            $frm.frame2.frame6.frame8.power configure   -state normal
            $frm.frame2.frame6.frame9.ccdtemp configure -state normal
         } else {
            ###pack forget $frm.frame2.frame6.frame7.setTemp
            ###pack forget $frm.frame2.frame6.frame7.tempdeg
            $frm.frame2.frame6.frame7.setTemp configure -state disabled
            $frm.frame2.frame6.frame7.tempdeg configure -state disabled
            $frm.frame2.frame6.frame8.power configure   -state disabled
            $frm.frame2.frame6.frame9.ccdtemp configure -state disabled
         }
      }
   }
}

#
# ::qsi::displayTemperature
#    Affiche la temperature du CCD
#
proc ::qsi::displayTemperature { camItem } {
   variable private
   global caption

   if { [ catch { set tempstatus [ cam$private($camItem,camNo) infotemp ] } ] == "0" } {
      set setTemp              [ format "%+5.2f" [ lindex $tempstatus 0 ] ]
      set temp_ccd             [ format "%+5.2f" [ lindex $tempstatus 1 ] ]
      set temp_ambiant         [ format "%+5.2f" [ lindex $tempstatus 2 ] ]
      set regulation           [ lindex $tempstatus 3 ]
      set private(power)       "$caption(qsi,puissance_peltier) [ format "%3.0f" [ lindex $tempstatus 4 ] ] %"
      set private(temperature) "$caption(qsi,ccdTemp) $temp_ccd $caption(qsi,deg_c) ($caption(qsi,setTemp): $setTemp)"
      set private(aftertemp)   [ after 5000 ::qsi::displayTemperature $camItem ]
   } else {
      set setTemp              "--"
      set temp_ccd             ""
      set temp_ambiant         ""
      set regulation           ""
      set power                "--"
      set private(power)       "$caption(qsi,puissance_peltier) $power"
      set private(temperature) "$caption(qsi,ccdTemp) $temp_ccd $caption(qsi,deg_c) ($caption(qsi,setTemp): $setTemp)"
      ###if { [ info exists private(aftertemp) ] == "1" } {
      ###   unset private(aftertemp)
      ###}
   }
}

#
# ::qsi::setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::qsi::setShutter { camItem shutterState ShutterOptionList } {
   variable private

   set ::conf(qsi,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   if { [ info exists private(frm) ] } {
      #--- Gestion du mode de fonctionnement
      switch -exact -- $shutterState {
         1  {
            set widget(foncobtu) $::caption(qsi,obtu_ferme)
            cam$camNo shutter "closed"
         }
         2  {
            set widget(foncobtu) $::caption(qsi,obtu_synchro)
            cam$camNo shutter "synchro"
         }
      }
   }
}

