#
# Fichier : atik.tcl
# Description : Configuration de la camera Atik
# Auteur : Robert DELMAS
# Mise à jour $Id: atik.tcl 8159 2012-03-03 08:48:07Z robertdelmas  $
#

namespace eval ::atik {
   package provide atik 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] atik.cap ]
}

#
# ::atik::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::atik::getPluginTitle { } {
   global caption

   return "$caption(atik,camera)"
}

#
# ::atik::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::atik::getPluginHelp { } {
   return "atik.htm"
}

#
# ::atik::getPluginType
#    Retourne le type du plugin
#
proc ::atik::getPluginType { } {
   return "camera"
}

#
# ::atik::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::atik::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::atik::getCamNo
#    Retourne le numero de la camera
#
proc ::atik::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::atik::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::atik::isReady { camItem } {
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
# ::atik::initPlugin
#    Initialise les variables conf(atik,...)
#
proc ::atik::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera Atik
   if { ! [ info exists conf(atik,cool) ] }     { set conf(atik,cool)     "0" }
   if { ! [ info exists conf(atik,foncobtu) ] } { set conf(atik,foncobtu) "2" }
   if { ! [ info exists conf(atik,mirh) ] }     { set conf(atik,mirh)     "0" }
   if { ! [ info exists conf(atik,mirv) ] }     { set conf(atik,mirv)     "0" }
   if { ! [ info exists conf(atik,temp) ] }     { set conf(atik,temp)     "-50" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(ccdTemp) "$caption(atik,temperature_CCD)"
}

#
# ::atik::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::atik::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Atik dans le tableau private(...)
   set private(cool)     $conf(atik,cool)
   set private(foncobtu) [ lindex "$caption(atik,obtu_ouvert) $caption(atik,obtu_ferme) $caption(atik,obtu_synchro)" $conf(atik,foncobtu) ]
   set private(mirh)     $conf(atik,mirh)
   set private(mirv)     $conf(atik,mirv)
   set private(temp)     $conf(atik,temp)
}

#
# ::atik::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::atik::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Atik dans le tableau conf(atik,...)
   set conf(atik,cool)     $private(cool)
   set conf(atik,foncobtu) [ lsearch "$caption(atik,obtu_ouvert) $caption(atik,obtu_ferme) $caption(atik,obtu_synchro)" "$private(foncobtu)" ]
   set conf(atik,mirh)     $private(mirh)
   set conf(atik,mirv)     $private(mirv)
   set conf(atik,temp)     $private(temp)
}

#
# ::atik::fillConfigPage
#    Interface de configuration de la camera Atik
#
proc ::atik::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::atik::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du refroidissement, de la temperature du capteur CCD, des miroirs en x et en y et de l'obturateur
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame des miroirs en x et en y, du refroidissement et de la temperature du capteur CCD
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Frame des miroirs en x et en y
         frame $frm.frame1.frame3.frame4 -borderwidth 0 -relief raised

            #--- Miroirs en x et en y
            checkbutton $frm.frame1.frame3.frame4.mirx -text "$caption(atik,miroir_x)" -highlightthickness 0 \
               -variable ::atik::private(mirh)
            pack $frm.frame1.frame3.frame4.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame1.frame3.frame4.miry -text "$caption(atik,miroir_y)" -highlightthickness 0 \
               -variable ::atik::private(mirv)
            pack $frm.frame1.frame3.frame4.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame1.frame3.frame4 -anchor n -side left -fill x -padx 20

         #--- Frame du refroidissement et de la temperature du capteur CCD
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Frame du refroidissement
            frame $frm.frame1.frame3.frame5.frame6 -borderwidth 0 -relief raised

               #--- Definition du refroidissement
               checkbutton $frm.frame1.frame3.frame5.frame6.cool -text "$caption(atik,refroidissement)" \
                  -highlightthickness 0 -variable ::atik::private(cool) -command "::atik::checkConfigRefroidissement"
               pack $frm.frame1.frame3.frame5.frame6.cool -anchor center -side left -padx 0 -pady 5

               entry $frm.frame1.frame3.frame5.frame6.temp -textvariable ::atik::private(temp) -width 4 \
                  -justify center \
                  -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -274 50 }
               pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5

               label $frm.frame1.frame3.frame5.frame6.tempdeg \
                  -text "$caption(atik,refroidissement_1)"
               pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5

            pack $frm.frame1.frame3.frame5.frame6 -side top -fill x -padx 10

            #--- Frame de la temperature du capteur CCD
            frame $frm.frame1.frame3.frame5.frame7 -borderwidth 0 -relief raised

               #--- Definition de la temperature du capteur CCD
               label $frm.frame1.frame3.frame5.frame7.ccdtemp -textvariable ::atik::private(ccdTemp)
               pack $frm.frame1.frame3.frame5.frame7.ccdtemp -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame5.frame7 -side top -fill x -padx 30

         pack $frm.frame1.frame3.frame5 -side left -fill x -expand 0

      pack $frm.frame1.frame3 -side top -fill x -expand 0

      #--- Frame du mode de fonctionnement de l'obturateur
      frame $frm.frame1.frame8 -borderwidth 0 -relief raised

         #--- Mode de fonctionnement de l'obturateur
         label $frm.frame1.frame8.lab3 -text "$caption(atik,fonc_obtu)"
         pack $frm.frame1.frame8.lab3 -anchor nw -side left -padx 10 -pady 5

         set list_combobox [ list $caption(atik,obtu_ouvert) $caption(atik,obtu_ferme) $caption(atik,obtu_synchro) ]
         ComboBox $frm.frame1.frame8.foncobtu \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -textvariable ::atik::private(foncobtu) \
            -values $list_combobox
         pack $frm.frame1.frame8.foncobtu -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.frame8 -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la Atik
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(atik,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(atik,site_web_ref)" \
         "$caption(atik,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::atik::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::atik::configureCamera
#    Configure la camera Atik en fonction des donnees contenues dans les variables conf(atik,...)
#
proc ::atik::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la camera
      set camNo [ cam::create atik PCI -debug_directory $::audace(rep_log) ]
      console::affiche_entete "$caption(atik,port_camera) $caption(atik,2points) [ cam$camNo port ]\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'obturateur
      switch -exact -- $conf(atik,foncobtu) {
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
      if { $conf(atik,cool) == "1" } {
         cam$camNo cooler on
         cam$camNo cooler check $conf(atik,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(atik,mirh)
      cam$camNo mirrorv $conf(atik,mirv)
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::atik::dispTempAtik $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::atik::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::atik::stop
#    Arrete la camera Atik
#
proc ::atik::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::atik::dispTempAtik
#    Affiche la temperature du CCD
#
proc ::atik::dispTempAtik { camItem } {
   variable private
   global caption

   if { [ catch { set temp_ccd [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_ccd [ format "%+5.2f" $temp_ccd ]
      set private(ccdTemp)   "$caption(atik,temperature_CCD) $temp_ccd $caption(atik,deg_c)"
      set private(aftertemp) [ after 5000 ::atik::dispTempAtik $camItem ]
   } else {
      set temp_ccd ""
      set private(ccdTemp) "$caption(atik,temperature_CCD) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   }
}

#
# ::atik::checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::atik::checkConfigRefroidissement { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::atik::private(cool) == "1" } {
            pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame1.frame3.frame5.frame7.ccdtemp configure -state normal
         } else {
            pack forget $frm.frame1.frame3.frame5.frame6.temp
            pack forget $frm.frame1.frame3.frame5.frame6.tempdeg
            $frm.frame1.frame3.frame5.frame7.ccdtemp configure -state disabled
         }
      }
   }
}

#
# ::atik::setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::atik::setTempCCD { } {
   global conf

   return "$conf(atik,temp)"
}

#
# ::atik::setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::atik::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(atik,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      0  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "opened"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(atik,obtu_ouvert)
      }
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(atik,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(atik,obtu_synchro)
      }
   }
}

#
# ::atik::getPluginProperty
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
proc ::atik::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 4x4 8x8 ] }
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
      shutterList      { return [ list $::caption(atik,obtu_ouvert) $::caption(atik,obtu_ferme) $::caption(atik,obtu_synchro) ] }
   }
}

