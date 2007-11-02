#
# Fichier : sbig.tcl
# Description : Configuration de la camera SBIG
# Auteur : Robert DELMAS
# Mise a jour $Id: sbig.tcl,v 1.8 2007-11-02 23:20:36 michelpujol Exp $
#

namespace eval ::sbig {
   package provide sbig 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] sbig.cap ]
}

#
# ::sbig::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::sbig::getPluginTitle { } {
   global caption

   return "$caption(sbig,camera)"
}

#
# ::sbig::getPluginHelp
#    Retourne la documentation du driver
#
proc ::sbig::getPluginHelp { } {
   return "sbig.htm"
}

#
# ::sbig::getPluginType
#    Retourne le type de driver
#
proc ::sbig::getPluginType { } {
   return "camera"
}

#
# ::sbig::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::sbig::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::sbig::getCamNo
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::sbig::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::sbig::initPlugin
#    Initialise les variables conf(sbig,...)
#
proc ::sbig::initPlugin { } {
   variable private
   global conf

   #--- Initialise les variables de la camera SBIG
   if { ! [ info exists conf(sbig,cool) ] }     { set conf(sbig,cool)     "0" }
   if { ! [ info exists conf(sbig,foncobtu) ] } { set conf(sbig,foncobtu) "2" }
   if { ! [ info exists conf(sbig,host) ] }     { set conf(sbig,host)     "192.168.0.2" }
   if { ! [ info exists conf(sbig,mirh) ] }     { set conf(sbig,mirh)     "0" }
   if { ! [ info exists conf(sbig,mirv) ] }     { set conf(sbig,mirv)     "0" }
   if { ! [ info exists conf(sbig,port) ] }     { set conf(sbig,port)     "LPT1:" }
   if { ! [ info exists conf(sbig,temp) ] }     { set conf(sbig,temp)     "0" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# ::sbig::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::sbig::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera SBIG dans le tableau private(...)
   set private(cool)     $conf(sbig,cool)
   set private(foncobtu) [ lindex "$caption(sbig,obtu_ouvert) $caption(sbig,obtu_ferme) $caption(sbig,obtu_synchro)" $conf(sbig,foncobtu) ]
   set private(host)     $conf(sbig,host)
   set private(mirh)     $conf(sbig,mirh)
   set private(mirv)     $conf(sbig,mirv)
   set private(port)     $conf(sbig,port)
   set private(temp)     $conf(sbig,temp)
}

#
# ::sbig::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::sbig::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera SBIG dans le tableau conf(sbig,...)
   set conf(sbig,cool)     $private(cool)
   set conf(sbig,foncobtu) [ lsearch "$caption(sbig,obtu_ouvert) $caption(sbig,obtu_ferme) $caption(sbig,obtu_synchro)" "$private(foncobtu)" ]
   set conf(sbig,host)     $private(host)
   set conf(sbig,mirh)     $private(mirh)
   set conf(sbig,mirv)     $private(mirv)
   set conf(sbig,port)     $private(port)
   set conf(sbig,temp)     $private(temp)
}

#
# ::sbig::fillConfigPage
#    Interface de configuration de la camera SBIG
#
proc ::sbig::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::sbig::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Je constitue la liste des liaisons pour l'acquisition des images
   if { $::tcl_platform(os) == "Linux" } {
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]
   } else {
      set list_combobox "[ ::confLink::getLinkLabels { "parallelport" } ] \
         $caption(sbig,usb) $caption(sbig,ethernet)"
   }

   #--- Je verifie le contenu de la liste
   if { [llength $list_combobox ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox $private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame de la configuration du port
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Definition du port
      label $frm.frame1.lab1 -text "$caption(sbig,port)"
      pack $frm.frame1.lab1 -anchor center -side left -padx 10

      #--- Bouton de configuration des ports et liaisons
      button $frm.frame1.configure -text "$caption(sbig,configurer)" -relief raised \
         -command {
            ::confLink::run ::sbig::private(port) { parallelport } \
               "- $caption(sbig,acquisition) - $caption(sbig,camera)"
         }
      pack $frm.frame1.configure -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.frame1.port \
         -width 7               \
         -height [ llength $list_combobox ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::sbig::private(port) \
         -values $list_combobox \
         -modifycmd "::sbig::configurePort"
      pack $frm.frame1.port -anchor center -side left -padx 10

      #--- Definition du host pour une connexion Ethernet
      entry $frm.frame1.host -width 18 -textvariable ::sbig::private(host)
      pack $frm.frame1.host -anchor center -side right -padx 10

      label $frm.frame1.lab2 -text "$caption(sbig,host)"
      pack $frm.frame1.lab2 -anchor center -side right -padx 10

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame des miroirs en x et en y, du refroidissement et de la temperature (du capteur CCD et exterieure)
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Frame des miroirs en x et en y
      frame $frm.frame2.frame5 -borderwidth 0 -relief raised

         #--- Miroirs en x et en y
         checkbutton $frm.frame2.frame5.mirx -text "$caption(sbig,miroir_x)" -highlightthickness 0 \
            -variable ::sbig::private(mirh)
         pack $frm.frame2.frame5.mirx -anchor w -side top -padx 10 -pady 10

         checkbutton $frm.frame2.frame5.miry -text "$caption(sbig,miroir_y)" -highlightthickness 0 \
            -variable ::sbig::private(mirv)
         pack $frm.frame2.frame5.miry -anchor w -side top -padx 10 -pady 10

      pack $frm.frame2.frame5 -side left -fill x -expand 0

      #--- Frame du refroidissement et de la temperature du capteur CCD
      frame $frm.frame2.frame6 -borderwidth 0 -relief raised

         #--- Frame du refroidissement
         frame $frm.frame2.frame6.frame7 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            checkbutton $frm.frame2.frame6.frame7.cool -text "$caption(sbig,refroidissement)" -highlightthickness 0 \
               -variable ::sbig::private(cool) -command "::sbig::checkConfigRefroidissement"
            pack $frm.frame2.frame6.frame7.cool -anchor center -side left -padx 0 -pady 5

            entry $frm.frame2.frame6.frame7.temp -textvariable ::sbig::private(temp) -width 4 -justify center
            pack $frm.frame2.frame6.frame7.temp -anchor center -side left -padx 5 -pady 5

            label $frm.frame2.frame6.frame7.tempdeg -text "$caption(sbig,deg_c) $caption(sbig,refroidissement_1)"
            pack $frm.frame2.frame6.frame7.tempdeg -anchor center -side left -padx 0 -pady 5

         pack $frm.frame2.frame6.frame7 -side top -fill none -padx 30

         #--- Frame de la puissance de refroidissement
         frame $frm.frame2.frame6.frame8 -borderwidth 0 -relief raised

            label $frm.frame2.frame6.frame8.power -text "$caption(sbig,puissance_peltier_--)"
            pack $frm.frame2.frame6.frame8.power -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame8 -side top -fill x -padx 30

         #--- Frame de la temperature exterieure
         frame $frm.frame2.frame6.frame9 -borderwidth 0 -relief raised

            label $frm.frame2.frame6.frame9.ccdtemp -text "$caption(sbig,temp_ext)"
            pack $frm.frame2.frame6.frame9.ccdtemp -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame9 -side top -fill x -padx 30

      pack $frm.frame2.frame6 -side left -expand 0 -padx 60

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame du mode de fonctionnement de l'obturateur
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Mode de fonctionnement de l'obturateur
      label $frm.frame3.lab3 -text "$caption(sbig,fonc_obtu)"
      pack $frm.frame3.lab3 -anchor center -side left -padx 10

      set list_combobox [ list $caption(sbig,obtu_ouvert) $caption(sbig,obtu_ferme) $caption(sbig,obtu_synchro) ]
      ComboBox $frm.frame3.foncobtu \
         -width 11                  \
         -height [ llength $list_combobox ] \
         -relief sunken             \
         -borderwidth 1             \
         -editable 0                \
         -textvariable ::sbig::private(foncobtu) \
         -values $list_combobox
      pack $frm.frame3.foncobtu -anchor center -side left -padx 10

   pack $frm.frame3 -side top -fill both -expand 1

   #--- Frame du site web officiel de la SBIG
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(sbig,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(sbig,site_web_ref)" \
         "$caption(sbig,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::sbig::configurePort
   ::sbig::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::sbig::configureCamera
#    Configure la camera SBIG en fonction des donnees contenues dans les variables conf(sbig,...)
#
proc ::sbig::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
     ### set conf(sbig,host) [ ::audace::verifip $conf(sbig,host) ]
      #--- Je cree la camera
      set camNo [ cam::create sbig $conf(sbig,port) -ip $conf(sbig,host) ]
      console::affiche_erreur "$caption(sbig,port_camera) ([ cam$camNo name ]) $caption(sbig,2points) $conf(sbig,port)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je cree la liaison utilisee par la camera pour l'acquisition
      set linkNo [ ::confLink::create $conf(sbig,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
      #--- Je configure l'obturateur
      switch -exact -- $conf(sbig,foncobtu) {
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
      if { $conf(sbig,cool) == "1" } {
         cam$camNo cooler check $conf(sbig,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(sbig,mirh)
      cam$camNo mirrorv $conf(sbig,mirv)
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::sbig::SbigDispTemp $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::sbig::stop $camItem
      #--- Je transmets l'erreur a la procedure appellante
      error $::errorInfo
   }
}

#
# ::sbig::stop
#    Arrete la camera SBIG
#
proc ::sbig::stop { camItem } {
   variable private
   global conf

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(sbig,port) "cam$private($camItem,camNo)" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::sbig::SbigDispTemp
#    Affiche la temperature du CCD
#
proc ::sbig::SbigDispTemp { camItem } {
   variable private
   global audace caption

   catch {
      set frm $private(frm)
      if { [ winfo exists $frm ] == "1" && [ catch { set tempstatus [ cam$private($camItem,camNo) infotemp ] } ] == "0" } {
         set temp_check [ format "%+5.2f" [ lindex $tempstatus 0 ] ]
         set temp_ccd [ format "%+5.2f" [ lindex $tempstatus 1 ] ]
         set temp_ambiant [ format "%+5.2f" [ lindex $tempstatus 2 ] ]
         set regulation [ lindex $tempstatus 3 ]
         set power [ format "%3.0f" [ expr 100.*[ lindex $tempstatus 4 ]/255. ] ]
         $frm.power configure \
            -text "$caption(sbig,puissance_peltier) $power %"
         $frm.ccdtemp configure \
            -text "$caption(sbig,temp_ext) $temp_ccd $caption(sbig,deg_c) / $temp_ambiant $caption(sbig,deg_c)"
         set private(aftertemp) [ after 5000 ::sbig::SbigDispTemp $camItem ]
      } else {
         catch { unset private(aftertemp) }
      }
   }
}

#
# ::sbig::configurePort
#    Configure le bouton "Configurer" et le host
#
proc ::sbig::configurePort { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::tcl_platform(os) != "Linux" } {
            if { $::sbig::private(port) == "$caption(sbig,usb)" || $::sbig::private(port) == "$caption(sbig,ethernet)" } {
               $frm.frame1.configure configure -state disabled
            } else {
               $frm.frame1.configure configure -state normal
            }
            if { $::sbig::private(port) == "$caption(sbig,ethernet)" } {
               $frm.frame1.host configure -state normal
            } else {
               $frm.frame1.host configure -state disabled
            }
         }
      }
   }
}

#
# ::sbig::checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::sbig::checkConfigRefroidissement { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::sbig::private(cool) == "1" } {
            pack $frm.frame2.frame6.frame7.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame2.frame6.frame7.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame2.frame6.frame8.power configure -state normal
            $frm.frame2.frame6.frame9.ccdtemp configure -state normal
         } else {
            pack forget $frm.frame2.frame6.frame7.temp
            pack forget $frm.frame2.frame6.frame7.tempdeg
            $frm.frame2.frame6.frame8.power configure -state disabled
            $frm.frame2.frame6.frame9.ccdtemp configure -state disabled
         }
      }
   }
}

#
# ::sbig::setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::sbig::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(sbig,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Gestion du mode de fonctionnement
         switch -exact -- $shutterState {
            0  {
               set private(foncobtu) $caption(sbig,obtu_ouvert)
               $frm.frame3.foncobtu configure -height [ llength $ShutterOptionList ]
               $frm.frame3.foncobtu configure -values $ShutterOptionList
               cam$camNo shutter "opened"
            }
            1  {
               set private(foncobtu) $caption(sbig,obtu_ferme)
               $frm.frame3.foncobtu configure -height [ llength $ShutterOptionList ]
               $frm.frame3.foncobtu configure -values $ShutterOptionList
               cam$camNo shutter "closed"
            }
            2  {
               set private(foncobtu) $caption(sbig,obtu_synchro)
               $frm.frame3.foncobtu configure -height [ llength $ShutterOptionList ]
               $frm.frame3.foncobtu configure -values $ShutterOptionList
               cam$camNo shutter "synchro"
            }
         }
      }
   }
}

#
# ::sbig::getPluginProperty
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
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::sbig::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 65535 0 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
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
         #--- O + F + S - A confirmer avec le materiel
         return [ list $::caption(sbig,obtu_ouvert) $::caption(sbig,obtu_ferme) $::caption(sbig,obtu_synchro) ]
      }
   }
}

