#
# Fichier : kitty.tcl
# Description : Configuration de la camera Kitty
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::kitty {
   package provide kitty 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] kitty.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::kitty::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libk2.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::kitty::getPluginType]] "kitty" "libk2.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(kitty,installNewVersion) $sourceFileName [package version kitty] ]
   }
}

#
# ::kitty::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::kitty::getPluginTitle { } {
   global caption

   return "$caption(kitty,camera)"
}

#
# ::kitty::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::kitty::getPluginHelp { } {
   return "kitty.htm"
}

#
# ::kitty::getPluginType
#    Retourne le type du plugin
#
proc ::kitty::getPluginType { } {
   return "camera"
}

#
# ::kitty::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::kitty::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::kitty::getCamNo
#    Retourne le numero de la camera
#
proc ::kitty::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::kitty::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::kitty::isReady { camItem } {
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
# ::kitty::initPlugin
#    Initialise les variables conf(kitty,...)
#
proc ::kitty::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera Kitty
   if { ! [ info exists conf(kitty,mirh) ] }    { set conf(kitty,mirh)    "0" }
   if { ! [ info exists conf(kitty,mirv) ] }    { set conf(kitty,mirv)    "0" }
   if { ! [ info exists conf(kitty,port) ] }    { set conf(kitty,port)    "LPT1:" }
   if { ! [ info exists conf(kitty,on_off) ] }  { set conf(kitty,on_off)  "1" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(ccdTemp) "$caption(kitty,temperature_CCD)"
}

#
# ::kitty::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::kitty::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Kitty dans le tableau private(...)
   set private(mirh)    $conf(kitty,mirh)
   set private(mirv)    $conf(kitty,mirv)
   set private(port)    $conf(kitty,port)
   set private(on_off)  $conf(kitty,on_off)
}

#
# ::kitty::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::kitty::widgetToConf { camItem } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Kitty dans le tableau conf(kitty,...)
   set conf(kitty,mirh)    $private(mirh)
   set conf(kitty,mirv)    $private(mirv)
   set conf(kitty,port)    $private(port)
   set conf(kitty,on_off)  $private(on_off)
}

#
# ::kitty::fillConfigPage
#    Interface de configuration de la camera Kitty
#
proc ::kitty::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::kitty::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Je constitue la liste des liaisons pour l'acquisition des images
   set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

   #--- Je verifie le contenu de la liste
   if { [ llength $list_combobox ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox $::kitty::private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set ::kitty::private(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame du modele
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Label Kitty-2
      label $frm.frame1.modele -text "$caption(kitty,kitty_2)"
      pack $frm.frame1.modele -anchor center -side left -padx 10

   pack $frm.frame1 -side top -fill x -pady 10

   #--- Frame du port, de la resolution, du refroidissement et des miroirs en x et en y
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Frame du port, de la resolution et du refroidissement
      frame $frm.frame2.frame5 -borderwidth 0 -relief raised

         #--- Frame de la configuration du port
         frame $frm.frame2.frame5.frame7 -borderwidth 0 -relief raised

            #--- Definition du port
            label $frm.frame2.frame5.frame7.lab1 -text "$caption(kitty,port)"
            pack $frm.frame2.frame5.frame7.lab1 -anchor center -side left -padx 10

            #--- Bouton de configuration des ports et liaisons
            button $frm.frame2.frame5.frame7.configure -text "$caption(kitty,configurer)" -relief raised \
               -command {
                  ::confLink::run ::kitty::private(port) { parallelport } \
                     "- $caption(kitty,acquisition) - $caption(kitty,camera)"
               }
            pack $frm.frame2.frame5.frame7.configure -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

            #--- Choix du port ou de la liaison
            ComboBox $frm.frame2.frame5.frame7.port \
              -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::kitty::private(port) \
               -values $list_combobox
            pack $frm.frame2.frame5.frame7.port -anchor center -side right -padx 10

         pack $frm.frame2.frame5.frame7 -side top -fill x

         #--- Frame du refroidissement
         frame $frm.frame2.frame5.frame8 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            label $frm.frame2.frame5.frame8.lab4 -text "$caption(kitty,refroidissement_2)"
            pack $frm.frame2.frame5.frame8.lab4 -anchor center -side left -padx 10

            #--- Refroidissement On
            radiobutton $frm.frame2.frame5.frame8.radio_on -anchor w -highlightthickness 0 \
               -text "$caption(kitty,refroidissement_on)" -value 1 \
               -variable ::kitty::private(on_off) -command { cam$private($camItem,camNo) cooler on }
            pack $frm.frame2.frame5.frame8.radio_on -side left -padx 5 -pady 5 -ipady 0

            #--- Refroidissement Off
            radiobutton $frm.frame2.frame5.frame8.radio_off -anchor w -highlightthickness 0 \
               -text "$caption(kitty,refroidissement_off)" -value 0 \
               -variable ::kitty::private(on_off) -command { cam$private($camItem,camNo) cooler off }
            pack $frm.frame2.frame5.frame8.radio_off -side left -padx 5 -pady 5 -ipady 0

         pack $frm.frame2.frame5.frame8 -side top -fill both -expand 1

      pack $frm.frame2.frame5 -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame2.frame6 -borderwidth 0 -relief raised

            #--- Miroir en x et en y
            checkbutton $frm.frame2.frame6.mirx -text "$caption(kitty,miroir_x)" -highlightthickness 0 \
               -variable ::kitty::private(mirh)
            pack $frm.frame2.frame6.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame2.frame6.miry -text "$caption(kitty,miroir_y)" -highlightthickness 0 \
               -variable ::kitty::private(mirv)
            pack $frm.frame2.frame6.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame2.frame6 -side right -fill x -padx 50

   pack $frm.frame2 -side top -fill x

   #--- Frame de la temperature du capteur CCD et du bouton de test
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Frame de la temperature du capteur CCD
      frame $frm.frame3.frame9 -borderwidth 0 -relief raised

         #--- Definition de la temperature du capteur CCD
         label $frm.frame3.frame9.ccdtemp -textvariable ::kitty::private(ccdTemp)
         pack $frm.frame3.frame9.ccdtemp -side left -fill x -padx 10 -pady 0

      pack $frm.frame3.frame9 -side top -fill both -expand 1

      #--- Frame du bouton de test
      frame $frm.frame3.frame10 -borderwidth 0 -relief raised

         #--- Bouton de test du microcontrolleur de la carte d'interface
         button $frm.frame3.frame10.test -text "$caption(kitty,test)" -relief raised \
            -command "::kitty::testK2 $camItem"
         pack $frm.frame3.frame10.test -side left -padx 10 -pady 0 -ipadx 10 -ipady 5

      pack $frm.frame3.frame10 -side top -fill both -expand 1

   pack $frm.frame3 -side top -fill both -expand 1

   #--- Frame du site web officiel de la Kitty
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(kitty,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(kitty,site_web_ref)" \
         "$caption(kitty,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::kitty::confKitty $camItem

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::kitty::configureCamera
#    Configure la camera Kitty en fonction des donnees contenues dans les variables conf(kitty,...)
#
proc ::kitty::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0 } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
      set linkNo [ ::confLink::create $conf(kitty,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
      #--- Je cree la camera
      if { [ catch { set camNo [ cam::create k2 $conf(kitty,port) -debug_directory $::audace(rep_log) -name KITTYK2 ] } catchError ] == 1 } {
         if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
            error "" "" "NotRoot"
         } else {
            error $catchError
         }
      }
      console::affiche_entete "$caption(kitty,port_camera) $caption(kitty,2points) $conf(kitty,port)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(kitty,mirh)
      cam$camNo mirrorv $conf(kitty,mirv)
      #--- Je configure le refroidissement
      if { $conf(kitty,on_off) == "1" } {
         cam$camNo cooler on
      } else {
         cam$camNo cooler off
      }
      #--- Gestion des widgets actifs/inactifs
      ::kitty::confKitty $camItem
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::kitty::dispTempKitty $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::kitty::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::kitty::stop
#    Arrete la camera Kitty
#
proc ::kitty::stop { camItem } {
   variable private
   global conf

   #--- Gestion des widgets actifs/inactifs
   ::kitty::confKittyK2Inactif $camItem

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(kitty,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::kitty::dispTempKitty
#    Affiche la temperature du CCD
#
proc ::kitty::dispTempKitty { camItem } {
   variable private
   global caption

   if { [ catch { set temp_ccd [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_ccd [ format "%+5.2f" $temp_ccd ]
      set private(ccdTemp)   "$caption(kitty,temperature_CCD) $temp_ccd $caption(kitty,deg_c)"
      set private(aftertemp) [ after 5000 ::kitty::dispTempKitty $camItem ]
   } else {
      set temp_ccd ""
      set private(ccdTemp) "$caption(kitty,temperature_CCD) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   }
}

#
# ::kitty::confKitty
#    Permet d'activer ou de desactiver les widgets de configuration de la Kitty K2
#
proc ::kitty::confKitty { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         pack $frm.frame2.frame5.frame8 -side top -fill both -expand 1
         pack $frm.frame2.frame5.frame8.lab4 -anchor center -side left -padx 10
         pack $frm.frame2.frame5.frame8.radio_on -side left -padx 5 -pady 5 -ipady 0
         pack $frm.frame2.frame5.frame8.radio_off -side left -padx 5 -pady 5 -ipady 0
         pack $frm.frame3.frame9 -side top -fill both -expand 1
         pack $frm.frame3.frame9.ccdtemp -side left -fill x -padx 10 -pady 0
         pack $frm.frame3.frame10 -side top -fill both -expand 1
         pack $frm.frame3.frame10.test -side left -padx 10 -pady 0 -ipadx 10 -ipady 5
         #--- Widgets de configuration de la Kitty K2 actif
         if { [ ::confCam::getPluginProperty $camItem "name" ] == "K2" } {
            #--- Widgets de configuration de la Kitty K2 actif
            $frm.frame2.frame5.frame8.radio_on configure -state normal
            $frm.frame2.frame5.frame8.radio_off configure -state normal
            $frm.frame3.frame9.ccdtemp configure -state normal
            $frm.frame3.frame10.test configure -state normal
            $frm.frame3.frame10.test configure -command "::kitty::testK2 $camItem"
         } else {
            #--- Widgets de configuration de la Kitty K2 inactif
            $frm.frame2.frame5.frame8.radio_on configure -state disabled
            $frm.frame2.frame5.frame8.radio_off configure -state disabled
            $frm.frame3.frame9.ccdtemp configure -state disabled
            $frm.frame3.frame10.test configure -state disabled
         }
      }
      #--- Je mets a jour camItem dans la commande des widgets
      $frm.frame2.frame5.frame8.radio_on configure -command "::kitty::confKitty $camItem"
      $frm.frame2.frame5.frame8.radio_off configure -command "::kitty::confKitty $camItem"
   }
}

#
# ::kitty::confKittyK2Inactif
#    Permet de desactiver les widgets a l'arret de la Kitty K2
#
proc ::kitty::confKittyK2Inactif { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Widgets de configuration de la Kitty K2 inactif
         $frm.frame2.frame5.frame8.radio_on configure -state disabled
         $frm.frame2.frame5.frame8.radio_off configure -state disabled
         $frm.frame3.frame9.ccdtemp configure -state disabled
         $frm.frame3.frame10.test configure -state disabled
      }
   }
}

#
# ::kitty::testK2
#    Permet de tester le microcontroleur de la Kitty K2
#
proc ::kitty::testK2 { camItem } {
   variable private

   cam$private($camItem,camNo) sx28test
}

#
# ::kitty::getPluginProperty
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
proc ::kitty::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 4096 -4096 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
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
      shutterList      { return [ list "" ] }
   }
}

