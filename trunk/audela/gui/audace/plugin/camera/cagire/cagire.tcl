#
# Fichier : cagire.tcl
# Description : Configuration de la camera Cagire
# Auteur : Robert DELMAS
# Mise a jour $Id: cagire.tcl,v 1.2 2010-05-19 22:20:58 alainklotz Exp $
#

namespace eval ::cagire {
   package provide cagire 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] cagire.cap ]
}

#
# ::cagire::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::cagire::getPluginTitle { } {
   global caption

   return "$caption(cagire,camera)"
}

#
# ::cagire::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::cagire::getPluginHelp { } {
   return "cagire.htm"
}

#
# ::cagire::getPluginType
#    Retourne le type du plugin
#
proc ::cagire::getPluginType { } {
   return "camera"
}

#
# ::cagire::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::cagire::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::cagire::getCamNo
#    Retourne le numero de la camera
#
proc ::cagire::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::cagire::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::cagire::isReady { camItem } {
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
# ::cagire::initPlugin
#    Initialise les variables conf(cagire,...)
#
proc ::cagire::initPlugin { } {
   variable private
   global audace conf caption

   #--- Initialise les variables de la camera Cagire
   if { ! [ info exists conf(cagire,cool) ] }        { set conf(cagire,cool)        "0" }
   if { ! [ info exists conf(cagire,foncobtu) ] }    { set conf(cagire,foncobtu)    "2" }
   if { ! [ info exists conf(cagire,config) ] }      { set conf(cagire,config)      [ file join $audace(rep_install) bin ] }
   if { ! [ info exists conf(cagire,mirh) ] }        { set conf(cagire,mirh)        "0" }
   if { ! [ info exists conf(cagire,mirv) ] }        { set conf(cagire,mirv)        "0" }
   if { ! [ info exists conf(cagire,temp) ] }        { set conf(cagire,temp)        "-160" }
   if { ! [ info exists conf(cagire,ipserver) ] } { set conf(cagire,ipserver) "127.0.0.1" }
   if { ! [ info exists conf(cagire,portserver) ] }   { set conf(cagire,portserver)   "5000" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(ccdTemp) "$caption(cagire,temperature_CCD)"
}

#
# ::cagire::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::cagire::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Cagire dans le tableau private(...)
   set private(cool)        $conf(cagire,cool)
   set private(foncobtu)    [ lindex "$caption(cagire,obtu_ouvert) $caption(cagire,obtu_ferme) $caption(cagire,obtu_synchro)" $conf(cagire,foncobtu) ]
   set private(config)      $conf(cagire,config)
   set private(mirh)        $conf(cagire,mirh)
   set private(mirv)        $conf(cagire,mirv)
   set private(temp)        $conf(cagire,temp)
   set private(ouvert_obtu) $conf(cagire,ipserver)
   set private(ferm_obtu)   $conf(cagire,portserver)
}

#
# ::cagire::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::cagire::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Cagire dans le tableau conf(cagire,...)
   set conf(cagire,cool)        $private(cool)
   set conf(cagire,foncobtu)    [ lsearch "$caption(cagire,obtu_ouvert) $caption(cagire,obtu_ferme) $caption(cagire,obtu_synchro)" "$private(foncobtu)" ]
   set conf(cagire,config)      $private(config)
   set conf(cagire,mirh)        $private(mirh)
   set conf(cagire,mirv)        $private(mirv)
   set conf(cagire,temp)        $private(temp)
   set conf(cagire,ipserver) $private(ouvert_obtu)
   set conf(cagire,portserver)   $private(ferm_obtu)
}

#
# ::cagire::fillConfigPage
#    Interface de configuration de la camera Cagire
#
proc ::cagire::fillConfigPage { frm camItem } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::cagire::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du repertoire des fichiers de configuration
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Definition du repertoire des fichiers de configuration
      label $frm.frame1.lab2 -text "$caption(cagire,config)"
      pack $frm.frame1.lab2 -anchor center -side left -padx 10

      entry $frm.frame1.host -width 40 -textvariable ::cagire::private(config)
      pack $frm.frame1.host -anchor center -side left -padx 10

      button $frm.frame1.explore -text "$caption(cagire,parcourir)" -width 1 \
         -command {
            set ::cagire::private(config) [ tk_chooseDirectory -title "$caption(cagire,dossier)" \
            -initialdir [ file join $audace(rep_install) bin ] -parent [ winfo toplevel $frm ] ]
         }
      pack $frm.frame1.explore -side left -padx 10 -pady 5 -ipady 5

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame des miroirs en x et en y, du refroidissement, de la temperature du capteur CCD et de l'obturateur
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Frame du mode de fonctionnement, du delai d'ouverture et de fermeture de l'obturateur
      frame $frm.frame2.frame4 -borderwidth 0 -relief raised

         #--- Frame du mode de fonctionnement de l'obturateur
         frame $frm.frame2.frame4.frame7 -borderwidth 0 -relief raised

            #--- Mode de fonctionnement de l'obturateur
            label $frm.frame2.frame4.frame7.lab3 -text "$caption(cagire,fonc_obtu)"
            pack $frm.frame2.frame4.frame7.lab3 -anchor center -side left -padx 10 -pady 5

            set list_combobox [ list $caption(cagire,obtu_ouvert) $caption(cagire,obtu_ferme) $caption(cagire,obtu_synchro) ]
            ComboBox $frm.frame2.frame4.frame7.foncobtu \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
              -relief sunken       \
               -borderwidth 1      \
               -editable 0         \
               -textvariable ::cagire::private(foncobtu) \
               -values $list_combobox
            pack $frm.frame2.frame4.frame7.foncobtu -anchor center -side left -padx 10 -pady 5

         pack $frm.frame2.frame4.frame7 -side top -fill x -expand 1

         #--- Frame du delai d'ouverture de l'obturateur
         frame $frm.frame2.frame4.frame8 -borderwidth 0 -relief raised

            #--- Delai d'ouverture de l'obturateur
            label $frm.frame2.frame4.frame8.lab4 -text "$caption(cagire,ipserver)"
            pack $frm.frame2.frame4.frame8.lab4 -anchor center -side left -padx 10 -pady 5

            entry $frm.frame2.frame4.frame8.ouvert_obtu -textvariable ::cagire::private(ouvert_obtu) -width 20 -justify center
            pack $frm.frame2.frame4.frame8.ouvert_obtu -anchor center -side left -padx 5 -pady 5

            label $frm.frame2.frame4.frame8.lab5 -text "$caption(cagire,ms)"
            pack $frm.frame2.frame4.frame8.lab5 -side left -fill x -padx 0 -pady 5

         pack $frm.frame2.frame4.frame8 -side top -fill x -expand 1

         #--- Frame du delai de fermeture de l'obturateur
         frame $frm.frame2.frame4.frame9 -borderwidth 0 -relief raised

            #--- Delai de fermeture de l'obturateur
            label $frm.frame2.frame4.frame9.lab6 -text "$caption(cagire,portserver)"
            pack $frm.frame2.frame4.frame9.lab6 -anchor center -side left -padx 10 -pady 5

            entry $frm.frame2.frame4.frame9.ferm_obtu -textvariable ::cagire::private(ferm_obtu) -width 6 -justify center
            pack $frm.frame2.frame4.frame9.ferm_obtu -anchor center -side left -padx 5 -pady 5

            label $frm.frame2.frame4.frame9.lab7 -text "$caption(cagire,ms)"
            pack $frm.frame2.frame4.frame9.lab7 -side left -fill x -padx 0 -pady 5

         pack $frm.frame2.frame4.frame9 -side top -fill x -expand 1

      pack $frm.frame2.frame4 -side bottom -fill both -expand 1

      #--- Frame des miroirs en x et en y
      frame $frm.frame2.frame5 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame2.frame5.mirx -text "$caption(cagire,miroir_x)" -highlightthickness 0 \
            -variable ::cagire::private(mirh)
         pack $frm.frame2.frame5.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame2.frame5.miry -text "$caption(cagire,miroir_y)" -highlightthickness 0 \
            -variable ::cagire::private(mirv)
         pack $frm.frame2.frame5.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame2.frame5 -anchor n -side left -fill x -padx 20

      #--- Frame du refroidissement et de la temperature du capteur CCD
      frame $frm.frame2.frame6 -borderwidth 0 -relief raised

         #--- Frame du refroidissement
         frame $frm.frame2.frame6.frame10 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            checkbutton $frm.frame2.frame6.frame10.cool -text "$caption(cagire,refroidissement)" \
               -highlightthickness 0 -variable ::cagire::private(cool) \
               -command "::cagire::checkConfigRefroidissement"
            pack $frm.frame2.frame6.frame10.cool -anchor center -side left -padx 0 -pady 5

            entry $frm.frame2.frame6.frame10.temp -textvariable ::cagire::private(temp) -width 4 \
               -justify center
            pack $frm.frame2.frame6.frame10.temp -anchor center -side left -padx 5 -pady 5

            label $frm.frame2.frame6.frame10.tempdeg \
               -text "$caption(cagire,refroidissement_1)"
            pack $frm.frame2.frame6.frame10.tempdeg -side left -fill x -padx 0 -pady 5

         pack $frm.frame2.frame6.frame10 -side top -fill x -padx 10

         #--- Frame de la temperature du capteur CCD
         frame $frm.frame2.frame6.frame11 -borderwidth 0 -relief raised

            #--- Definition de la temperature du capteur CCD
            label $frm.frame2.frame6.frame11.ccdtemp -textvariable ::cagire::private(ccdTemp)
            pack $frm.frame2.frame6.frame11.ccdtemp -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame11 -side top -fill x -padx 30

      pack $frm.frame2.frame6 -side left -fill x -expand 0

   pack $frm.frame2 -side top -fill x -expand 0

   #--- Frame du site web officiel de la Cagire
   frame $frm.frame3 -borderwidth 0 -relief raised

      label $frm.frame3.lab103 -text "$caption(cagire,titre_site_web)"
      pack $frm.frame3.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame3 "$caption(cagire,site_web_ref)" \
         "$caption(cagire,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame3 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::cagire::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::cagire::configureCamera
#    Configure la camera Cagire en fonction des donnees contenues dans les variables conf(cagire,...)
#
proc ::cagire::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je mets conf(cagire,config) entre guillemets pour le cas ou le nom du repertoire contient des espaces
      #--- Je cree la camera
      set camNo [ cam::create cagire TCP -ip \"$conf(cagire,ipserver)\" -port \"$conf(cagire,portserver)\" -impath \"$conf(cagire,config)\" -simu 1]
      console::affiche_entete "$caption(cagire,port_camera) ([ cam$camNo name ]) \
         $caption(cagire,2points) $conf(cagire,config)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'obturateur
      switch -exact -- $conf(cagire,foncobtu) {
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
      #--- Je configure le refroidissement
      if { $conf(cagire,cool) == "1" } {
         cam$camNo cooler on
         cam$camNo cooler check $conf(cagire,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(cagire,mirh)
      cam$camNo mirrorv $conf(cagire,mirv)
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::cagire::dispTempCagire $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::cagire::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::cagire::stop
#    Arrete la camera Cagire
#
proc ::cagire::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::cagire::dispTempCagire
#    Affiche la temperature du CCD
#
proc ::cagire::dispTempCagire { camItem } {
   variable private
   global caption

   if { [ catch { set temp_ccd [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_ccd [ format "%+5.2f" $temp_ccd ]
      set private(ccdTemp)   "$caption(cagire,temperature_CCD) $temp_ccd $caption(cagire,deg_c)"
      set private(aftertemp) [ after 5000 ::cagire::dispTempCagire $camItem ]
   } else {
      set temp_ccd ""
      set private(ccdTemp) "$caption(cagire,temperature_CCD) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   }
}

#
# ::cagire::checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::cagire::checkConfigRefroidissement { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::cagire::private(cool) == "1" } {
            pack $frm.frame2.frame6.frame10.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame2.frame6.frame10.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame2.frame6.frame11.ccdtemp configure -state normal
         } else {
            pack forget $frm.frame2.frame6.frame10.temp
            pack forget $frm.frame2.frame6.frame10.tempdeg
            $frm.frame2.frame6.frame11.ccdtemp configure -state disabled
         }
      }
   }
}

#
# ::cagire::setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::cagire::setTempCCD { } {
   global conf

   return "$conf(cagire,temp)"
}

#
# ::cagire::setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::cagire::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(cagire,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   if { [ info exists private(frm) ] } {
      #--- Gestion du mode de fonctionnement
      switch -exact -- $shutterState {
         0  {
            set private(foncobtu) $caption(cagire,obtu_ouvert)
            cam$camNo shutter "opened"
         }
         1  {
            set private(foncobtu) $caption(cagire,obtu_ferme)
            cam$camNo shutter "closed"
         }
         2  {
            set private(foncobtu) $caption(cagire,obtu_synchro)
            cam$camNo shutter "synchro"
         }
      }
   }
}

#
# ::cagire::getPluginProperty
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
proc ::cagire::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 65535 0 ] }
      hasBinning       { return 0 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasTempSensor    { return 1 }
      hasSetTemp       { return 1 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 0 }
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
      shutterList      { return [ list $::caption(cagire,obtu_ouvert) $::caption(cagire,obtu_ferme) $::caption(cagire,obtu_synchro) ] }
   }
}

