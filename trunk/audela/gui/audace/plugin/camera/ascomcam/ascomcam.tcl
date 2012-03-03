#
# Fichier : ascomcam.tcl
# Description : Configuration de la camera ASCOM
# Auteur : Michel PUJOL
# Mise à jour $Id$
#

namespace eval ::ascomcam {
   package provide ascomcam 1.2

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ascomcam.cap ]
}

#
# install
#    installe le plugin
#
proc ::ascomcam::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libascomcam.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] "ascomcam" "libascomcam.dll"]
      ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      ::audace::appendUpdateMessage [ format $::caption(ascomcam,installNewVersion) $sourceFileName [package version ascomcam] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::ascomcam::getPluginTitle { } {
   global caption

   return "$caption(ascomcam,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::ascomcam::getPluginHelp { } {
   return "ascomcam.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::ascomcam::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::ascomcam::getPluginOS { } {
   return [ list Windows ]
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::ascomcam::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::ascomcam::isReady { camItem } {
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
# initPlugin
#    Initialise les variables conf(ascomcam,...)
#
proc ::ascomcam::initPlugin { } {
   variable private

   #--- Initialise les variables de la camera ASCOM
   if { ! [ info exists ::conf(ascomcam,modele) ] }   { set ::conf(ascomcam,modele)   "" }
   if { ! [ info exists ::conf(ascomcam,mirh) ] }     { set ::conf(ascomcam,mirh)     "0" }
   if { ! [ info exists ::conf(ascomcam,mirv) ] }     { set ::conf(ascomcam,mirv)     "0" }
   if { ! [ info exists ::conf(ascomcam,foncobtu) ] } { set ::conf(ascomcam,foncobtu) "2" }

   #--- Initialisation
   set private(A,camNo)      "0"
   set private(B,camNo)      "0"
   set private(C,camNo)      "0"

   set private(ascomDrivers) ""
   set private(modele)       ""
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ascomcam::confToWidget { } {
   variable private

   #--- Recupere la configuration de la camera ASCOM dans le tableau private(...)
   set private(modele)  $::conf(ascomcam,modele)
   set private(mirh)    $::conf(ascomcam,mirh)
   set private(mirv)    $::conf(ascomcam,mirv)
   set widget(foncobtu) [ lindex "$::caption(ascomcam,obtu_ouvert) $::caption(ascomcam,obtu_ferme) $::caption(ascomcam,obtu_synchro)" $::conf(ascomcam,foncobtu) ]
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ascomcam::widgetToConf { camItem } {
   variable private

   #--- Memorise la configuration de la camera ASCOM dans le tableau conf(ascomcam,...)
   set ::conf(ascomcam,modele) $private(modele)
   set ::conf(ascomcam,mirh)   $private(mirh)
   set ::conf(ascomcam,mirv)   $private(mirv)
}

#
# fillConfigPage
#    Interface de configuration de la camera ASCOM
#
proc ::ascomcam::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- confToWidget
   ::ascomcam::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   package require registry
   set private(ascomDrivers) ""

   #--- Plugins ASCOM 5.5 installes sur le PC
   set allUsersDataDir [ ::registry get "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" "Common AppData" ]
   set cameraDriverDir [ file normalize [ file join $allUsersDataDir ASCOM Profile "Camera Drivers" ] ]
   if { [file exists $cameraDriverDir] == 1 } {
      foreach key [ glob -nocomplain  -tails -type d -dir  $cameraDriverDir * ] {
         lappend private(ascomDrivers) $key
      }
   }

   if { $private(ascomDrivers) == "" } {
      #--- je chercher les plugins ASCOM 5.0 si je n'ai pas trouvé de Plugin ASCOM 5.5
      set catchError [ catch {
         set keyList [ ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Camera Drivers" ]
      }]
      if { $catchError == 0 } {
         foreach key $keyList {
            if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Camera Drivers\\$key" "" } r ] == 0 } {
               ###lappend private(ascomDrivers) [list $r $key]
               lappend private(ascomDrivers) [list $key]
            }
         }
      }
   }

   #--- Je verifie le contenu de la liste
   if { [llength $private(ascomDrivers) ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $private(ascomDrivers) $private(modele) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(modele) [lindex $private(ascomDrivers) 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
      set private(modele) ""
   }

   #--- Frame de la configuration du plugin et des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame de la configuration du plugin
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Definition du plugin
         label $frm.frame1.frame3.lab1 -text "$caption(ascomcam,modele)"
         pack $frm.frame1.frame3.lab1 -anchor center -side left -padx 10 -pady 30

         #--- Choix du plugin
         ComboBox $frm.frame1.frame3.driver \
            -width [ ::tkutil::lgEntryComboBox $private(ascomDrivers) ] \
            -height [ llength $private(ascomDrivers) ] \
            -relief sunken                \
            -borderwidth 1                \
            -editable 0                   \
            -textvariable ::ascomcam::private(modele) \
            -values $private(ascomDrivers)
         pack $frm.frame1.frame3.driver -fill x -expand 1 -anchor center -side left -padx 10 -pady 10

         #--- Bouton de configuration du plugin
         button $frm.frame1.frame3.configure -text "$caption(ascomcam,configurer)" -relief raised \
            -command "::ascomcam::configureDriver "
         pack $frm.frame1.frame3.configure -anchor center -side left -pady 28 -ipadx 10 -ipady 1 -expand 0

      pack $frm.frame1.frame3 -anchor nw -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame1.frame4.mirx -text "$caption(ascomcam,miroir_x)" -highlightthickness 0 \
            -variable ::ascomcam::private(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(ascomcam,miroir_y)" -highlightthickness 0 \
            -variable ::ascomcam::private(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor nw -side left -fill x -padx 20

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la ASCOM
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(ascomcam,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(ascomcam,site_web_ref)" \
         "$caption(ascomcam,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera en fonction des donnees contenues dans les variables conf(ascomcam,...)
#
proc ::ascomcam::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0 } {
         error "" "CameraUnique"
      }
      #--- Je cree la camera
      set camNo [ cam::create ascomcam $conf(ascomcam,modele) -debug_directory $::audace(rep_log) ]
      console::affiche_entete "$caption(ascomcam,port_camera) $caption(ascomcam,2points) $conf(ascomcam,modele)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(ascomcam,mirh)
      cam$camNo mirrorv $conf(ascomcam,mirv)
      #--- Je configure l'obturateur
      switch -exact -- $conf(ascomcam,foncobtu) {
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

   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::ascomcam::stop $camItem
      #--- Je transmets l'erreur a la procedure appellante
      error $::errorInfo
   }
}

#
# stop
#    Arrete la camera
#
proc ::ascomcam::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# getPluginProperty
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
proc ::ascomcam::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      {
         if { [::ascomcam::isReady $camItem ] == 1 } {
            set maxBin [cam$private($camItem,camNo) property maxbin]
            set binningList ""
            for { set i 1 } { $i <= $maxBin } { incr i } {
               lappend binningList "${i}x${i}"
            }
            return $binningList
         } else {
            return [ list 1x1 ]
         }
      }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 4096 -4096 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       {
         if { [::ascomcam::isReady $camItem ] == 1 } {
            return [cam$private($camItem,camNo) property hasShutter]
         } else {
            return 0
         }
      }
      hasTempSensor    { return 0 }
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
      shutterList      { return [ list $::caption(sbig,obtu_ferme) $::caption(sbig,obtu_synchro)] }
   }
}

proc ::ascomcam::configureDriver { } {
   variable private

   set camItem [::confCam::getCurrentCamItem]
   if { [ ::ascomcam::isReady $camItem] == 1 } {
      #--- le telescope est deja connecte
      cam$private($camItem,camNo) setup
   } else {
      #--- le telescope n'est pas connecte
      load [file join $::audela_start_dir libascomcam.dll]
      ascomcam setup $private(modele)
   }

}

#
# selectCamera
#    affiche la fenetre pour selectionner une camera
#
proc ::ascomcam::selectCamera { camItem } {
   variable private

   load [file join $::audela_start_dir libascomcam.dll]
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::ascomcam::setShutter { camItem shutterState ShutterOptionList } {
   variable private

   set ::conf(ascomcam,foncobtu) $shutterState

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      1  {
         #--- j'envoie la commande a la camera
         cam$private($camItem,camNo) shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set widget(foncobtu) $::caption(ascomcam,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$private($camItem,camNo) shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set widget(foncobtu) $::caption(ascomcam,obtu_synchro)
      }
   }
}

