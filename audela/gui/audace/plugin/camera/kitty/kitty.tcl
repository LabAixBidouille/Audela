#
# Fichier : kitty.tcl
# Description : Configuration de la camera Kitty
# Auteur : Robert DELMAS
# Mise a jour $Id: kitty.tcl,v 1.7 2007-10-20 15:46:23 robertdelmas Exp $
#

namespace eval ::kitty {
   package provide kitty 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] kitty.cap ]
}

#
# ::kitty::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::kitty::getPluginTitle { } {
   global caption

   return "$caption(kitty,camera)"
}

#
# ::kitty::getPluginHelp
#    Retourne la documentation du driver
#
proc ::kitty::getPluginHelp { } {
   return "kitty.htm"
}

#
# ::kitty::getPluginType
#    Retourne le type de driver
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
# ::kitty::initPlugin
#    Initialise les variables conf(kitty,...)
#
proc ::kitty::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera Kitty
   if { ! [ info exists conf(kitty,captemp) ] } { set conf(kitty,captemp) "0" }
   if { ! [ info exists conf(kitty,mirh) ] }    { set conf(kitty,mirh)    "0" }
   if { ! [ info exists conf(kitty,mirv) ] }    { set conf(kitty,mirv)    "0" }
   if { ! [ info exists conf(kitty,modele) ] }  { set conf(kitty,modele)  "237" }
   if { ! [ info exists conf(kitty,port) ] }    { set conf(kitty,port)    "LPT1:" }
   if { ! [ info exists conf(kitty,res) ] }     { set conf(kitty,res)     "12 bits" }
   if { ! [ info exists conf(kitty,on_off) ] }  { set conf(kitty,on_off)  "1" }
}

#
# ::kitty::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::kitty::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Kitty dans le tableau private(...)
   set private(captemp) [ lindex "$caption(kitty,capteur_temp_ad7893an2) $caption(kitty,capteur_temp_ad7893an5)" $conf(kitty,captemp) ]
   set private(mirh)    $conf(kitty,mirh)
   set private(mirv)    $conf(kitty,mirv)
   set private(modele)  $conf(kitty,modele)
   set private(port)    $conf(kitty,port)
   set private(res)     $conf(kitty,res)
   set private(on_off)  $conf(kitty,on_off)
}

#
# ::kitty::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::kitty::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Kitty dans le tableau conf(kitty,...)
   set conf(kitty,captemp) [ lsearch "$caption(kitty,capteur_temp_ad7893an2) $caption(kitty,capteur_temp_ad7893an5)" "$private(captemp)" ]
   set conf(kitty,mirh)    $private(mirh)
   set conf(kitty,mirv)    $private(mirv)
   set conf(kitty,modele)  $private(modele)
   set conf(kitty,port)    $private(port)
   set conf(kitty,res)     $private(res)
   set conf(kitty,on_off)  $private(on_off)
}

#
# ::kitty::fillConfigPage
#    Interface de configuration de la camera Kitty
#
proc ::kitty::fillConfigPage { frm } {
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
   if { [llength $list_combobox ] > 0 } {
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

   #--- Frame de la selection du modele
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Bouton radio Kitty-237
      radiobutton $frm.frame1.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(kitty,kitty_237)" -value 237 -variable ::kitty::private(modele) \
         -command { ::kitty::confKitty }
      pack $frm.frame1.radio0 -anchor center -side left -padx 10

      #--- Bouton radio Kitty-255
      radiobutton $frm.frame1.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(kitty,kitty_255)" -value 255 -variable ::kitty::private(modele) \
         -command { ::kitty::confKitty }
      pack $frm.frame1.radio1 -anchor center -side left -padx 10

      #--- Bouton radio Kitty-2
      radiobutton $frm.frame1.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(kitty,kitty_2)" -value K2 -variable ::kitty::private(modele) \
         -command { ::kitty::confKitty }
      pack $frm.frame1.radio2 -anchor center -side left -padx 10

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
              -width 7         \
               -height [ llength $list_combobox ] \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable ::kitty::private(port) \
               -values $list_combobox
            pack $frm.frame2.frame5.frame7.port -anchor center -side right -padx 10

         pack $frm.frame2.frame5.frame7 -side top -fill x

         #--- Frame de la resolution
         frame $frm.frame2.frame5.frame8 -borderwidth 0 -relief raised

            #--- Definition de la resolution
            label $frm.frame2.frame5.frame8.lab2 -text "$caption(kitty,resolution)"
            pack $frm.frame2.frame5.frame8.lab2 -anchor center -side left -padx 10

            set list_combobox [ list $caption(kitty,can_12bits) $caption(kitty,can_8bits) ]
            ComboBox $frm.frame2.frame5.frame8.res \
               -width 7       \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::kitty::private(res) \
               -values $list_combobox
            pack $frm.frame2.frame5.frame8.res -anchor center -side right -padx 10

         pack $frm.frame2.frame5.frame8 -side top -fill x

         #--- Frame du refroidissement
         frame $frm.frame2.frame5.frame9 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            label $frm.frame2.frame5.frame9.lab4 -text "$caption(kitty,refroidissement_2)"
            pack $frm.frame2.frame5.frame9.lab4 -anchor center -side left -padx 10

            #--- Refroidissement On
            radiobutton $frm.frame2.frame5.frame9.radio_on -anchor w -highlightthickness 0 \
               -text "$caption(kitty,refroidissement_on)" -value 1 \
               -variable ::kitty::private(on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler on }
            pack $frm.frame2.frame5.frame9.radio_on -side left -padx 5 -pady 5 -ipady 0

            #--- Refroidissement Off
            radiobutton $frm.frame2.frame5.frame9.radio_off -anchor w -highlightthickness 0 \
               -text "$caption(kitty,refroidissement_off)" -value 0 \
               -variable ::kitty::private(on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler off }
            pack $frm.frame2.frame5.frame9.radio_off -side left -padx 5 -pady 5 -ipady 0

         pack $frm.frame2.frame5.frame9 -side top -fill both -expand 1

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

   #--- Frame du capteur de temperature, de la temperature du capteur CCD et du bouton de test
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Definition du capteur de temperature
      label $frm.frame3.lab3 -text "$caption(kitty,capteur_temp)"
      pack $frm.frame3.lab3 -anchor n -side left -padx 10 -pady 10

      set list_combobox [ list $caption(kitty,capteur_temp_ad7893an2) $caption(kitty,capteur_temp_ad7893an5) ]
      ComboBox $frm.frame3.captemp \
         -width 12          \
         -height [ llength $list_combobox ] \
         -relief sunken     \
         -borderwidth 1     \
         -editable 0        \
         -textvariable ::kitty::private(captemp) \
         -values $list_combobox
      pack $frm.frame3.captemp -anchor n -side left -padx 10 -pady 10

      #--- Frame de la temperature du capteur CCD
      frame $frm.frame3.frame10 -borderwidth 0 -relief raised

         #--- Definition de la temperature du capteur CCD
         label $frm.frame3.frame10.temp_ccd -text "$caption(kitty,temperature_CCD)"
         pack $frm.frame3.frame10.temp_ccd -side left -fill x -padx 10 -pady 0

      pack $frm.frame3.frame10 -side top -fill both -expand 1

      #--- Frame du bouton de test
      frame $frm.frame3.frame11 -borderwidth 0 -relief raised

         #--- Bouton de test du microcontrolleur de la carte d'interface
         button $frm.frame3.frame11.test -text "$caption(kitty,test)" -relief raised \
            -command { cam$confCam($confCam(currentCamItem),camNo) sx28test }
         pack $frm.frame3.frame11.test -side left -padx 10 -pady 0 -ipadx 10 -ipady 5

      pack $frm.frame3.frame11 -side top -fill both -expand 1

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
   ::kitty::confKitty

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::kitty::configureCamera
#    Configure la camera Kitty en fonction des donnees contenues dans les variables conf(kitty,...)
#
proc ::kitty::configureCamera { camItem } {
   global caption conf confCam

   set catchResult [ catch {
      if { $conf(kitty,modele) == "237" } {
         set camNo [ cam::create kitty $conf(kitty,port) -name KITTY237 -canbits [ lindex $conf(kitty,res) 0 ] ]
         console::affiche_erreur "$caption(kitty,port_camera) $conf(kitty,modele) ($conf(kitty,res))\
            $caption(kitty,2points) $conf(kitty,port)\n"
         console::affiche_saut "\n"
         set confCam($camItem,camNo) $camNo
         #--- Je cree la liaison utilisee par la camera pour l'acquisition
         set linkNo [ ::confLink::create $conf(kitty,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
         #--- Je configure la resolution du CAN
         cam$camNo canbits [ lindex $conf(kitty,res) 0 ]
         #--- Je selectionne le capteur de temperature
         if { $conf(kitty,captemp) == "0" } {
            cam$camNo AD7893 AN2
         } else {
            cam$camNo AD7893 AN5
         }
         #--- J'associe le buffer de la visu
         set bufNo [visu$confCam($camItem,visuNo) buf]
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(kitty,mirh)
         cam$camNo mirrorv $conf(kitty,mirv)
         #--- Je renseigne la dynamique de la camera
         ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
         #--- Gestion des widgets actifs/inactifs
         ::kitty::confKitty
      } elseif { $conf(kitty,modele) == "255" } {
         set camNo [ cam::create kitty $conf(kitty,port) -name KITTY255 -canbits [ lindex $conf(kitty,res) 0 ] ]
         console::affiche_erreur "$caption(kitty,port_camera) $conf(kitty,modele) ($conf(kitty,res))\
            $caption(kitty,2points) $conf(kitty,port)\n"
         console::affiche_saut "\n"
         set confCam($camItem,camNo) $camNo
         #--- Je cree la liaison utilisee par la camera pour l'acquisition
         set linkNo [ ::confLink::create $conf(kitty,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
         #--- Je configure la resolution du CAN
         cam$camNo canbits [ lindex $conf(kitty,res) 0 ]
         #--- Je selectionne le capteur de temperature
         if { $conf(kitty,captemp) == "0" } {
            cam$camNo AD7893 AN2
         } else {
            cam$camNo AD7893 AN5
         }
         #--- J'associe le buffer de la visu
         set bufNo [visu$confCam($camItem,visuNo) buf]
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(kitty,mirh)
         cam$camNo mirrorv $conf(kitty,mirv)
         #--- Je renseigne la dynamique de la camera
         ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
         #--- Gestion des widgets actifs/inactifs
         ::kitty::confKitty
      } elseif { $conf(kitty,modele) == "K2" } {
         set camNo [ cam::create k2 $conf(kitty,port) -name KITTYK2 ]
         console::affiche_erreur "$caption(kitty,port_camera) $conf(kitty,modele)\
            $caption(kitty,2points) $conf(kitty,port)\n"
         console::affiche_saut "\n"
         set confCam($camItem,camNo) $camNo
         #--- Je cree la liaison utilisee par la camera pour l'acquisition
         set linkNo [ ::confLink::create $conf(kitty,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
         #--- J'associe le buffer de la visu
         set bufNo [visu$confCam($camItem,visuNo) buf]
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
         #--- Je renseigne la dynamique de la camera
         ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
         #--- Gestion des widgets actifs/inactifs
         ::kitty::confKitty
         #--- Je mesure la temperature du capteur CCD
         if { [ info exists confCam(kitty,aftertemp) ] == "0" } {
            ::kitty::KittyDispTemp
         }
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::kitty::stop $camItem
      #--- Je transmets l'erreur a la procedure appellante
      error $::errorInfo
   }
}

#
# ::kitty::stop
#    Arrete la camera Kitty
#
proc ::kitty::stop { camItem } {
   global conf confCam

   #--- Gestion des widgets actifs/inactifs
   ::kitty::confKittyK2Inactif

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(kitty,port) "cam$confCam($camItem,camNo)" "acquisition"

   #--- J'arrete la camera
   if { $confCam($camItem,camNo) != 0 } {
      cam::delete $confCam($camItem,camNo)
      set confCam($camItem,camNo) 0
   }
}

#
# ::kitty::KittyDispTemp
#    Affiche la temperature du CCD
#
proc ::kitty::KittyDispTemp { } {
   variable private
   global audace caption confCam

   catch {
      set frm $private(frm)
      set camItem $confCam(currentCamItem)
      if { [ info exists audace(base).confCam ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
         set temp_ccd [ format "%+5.2f" $temp_ccd ]
         $frm.frame3.frame10.temp_ccd configure \
            -text "$caption(kitty,temperature_CCD) $temp_ccd $caption(kitty,deg_c)"
         set confCam(kitty,aftertemp) [ after 5000 ::kitty::KittyDispTemp ]
      } else {
         catch { unset confCam(kitty,aftertemp) }
      }
   }
}

#
# ::kitty::confKitty
#    Permet d'activer ou de desactiver les widgets de configuration de la Kitty K2
#
proc ::kitty::confKitty { } {
   variable private
   global confCam

   set camItem $confCam(currentCamItem)

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::kitty::private(modele) == "K2" } {
            pack forget $frm.frame2.frame5.frame8
            pack forget $frm.frame2.frame5.frame8.lab2
            pack forget $frm.frame2.frame5.frame8.res
            pack forget $frm.frame3.lab3
            pack forget $frm.frame3.captemp
            pack $frm.frame2.frame5.frame9 -side top -fill both -expand 1
            pack $frm.frame2.frame5.frame9.lab4 -anchor center -side left -padx 10
            pack $frm.frame2.frame5.frame9.radio_on -side left -padx 5 -pady 5 -ipady 0
            pack $frm.frame2.frame5.frame9.radio_off -side left -padx 5 -pady 5 -ipady 0
            pack $frm.frame3.frame10 -side top -fill both -expand 1
            pack $frm.frame3.frame10.temp_ccd -side left -fill x -padx 10 -pady 0
            pack $frm.frame3.frame11 -side top -fill both -expand 1
            pack $frm.frame3.frame11.test -side left -padx 10 -pady 0 -ipadx 10 -ipady 5
            if { [ ::confCam::getName $confCam($camItem,camNo) ] == "KITTYK2" } {
               #--- Widgets de configuration de la Kitty K2 actif
               $frm.frame2.frame5.frame9.radio_on configure -state normal
               $frm.frame2.frame5.frame9.radio_off configure -state normal
               $frm.frame3.frame10.temp_ccd configure -state normal
               $frm.frame3.frame11.test configure -state normal
            } else {
               #--- Widgets de configuration de la Kitty K2 inactif
               $frm.frame2.frame5.frame9.radio_on configure -state disabled
               $frm.frame2.frame5.frame9.radio_off configure -state disabled
               $frm.frame3.frame10.temp_ccd configure -state disabled
               $frm.frame3.frame11.test configure -state disabled
            }
         } else {
            pack forget $frm.frame2.frame5.frame9
            pack forget $frm.frame2.frame5.frame9.lab4
            pack forget $frm.frame2.frame5.frame9.radio_on
            pack forget $frm.frame2.frame5.frame9.radio_off
            pack forget $frm.frame3.frame10
            pack forget $frm.frame3.frame10.temp_ccd
            pack forget $frm.frame3.frame11
            pack forget $frm.frame3.frame11.test
            pack $frm.frame2.frame5.frame8 -side top -fill both -expand 1
            pack $frm.frame2.frame5.frame8.lab2 -anchor center -side left -padx 10
            pack $frm.frame2.frame5.frame8.res -anchor center -side right -padx 10
            pack $frm.frame3.lab3 -anchor n -side left -padx 10 -pady 10
            pack $frm.frame3.captemp -anchor n -side left -padx 10 -pady 10
         }
      }
   }
}

#
# ::kitty::confKittyK2Inactif
#    Permet de desactiver les widgets a l'arret de la Kitty K2
#
proc ::kitty::confKittyK2Inactif { } {
   variable private
   global confCam

   set camItem $confCam(currentCamItem)

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::confCam::getName $confCam($camItem,camNo) ] == "KITTYK2" } {
            #--- Widgets de configuration de la Kitty K2 inactif
            $frm.frame2.frame5.frame9.radio_on configure -state disabled
            $frm.frame2.frame5.frame9.radio_off configure -state disabled
            $frm.frame3.frame10.temp_ccd configure -state disabled
            $frm.frame3.frame11.test configure -state disabled
         }
      }
   }
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
proc ::kitty::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList      { return [ list "" ] }
   }
}

