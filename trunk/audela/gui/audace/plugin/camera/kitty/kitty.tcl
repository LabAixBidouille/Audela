#
# Fichier : kitty.tcl
# Description : Configuration de la camera Kitty
# Auteur : Robert DELMAS
# Mise a jour $Id: kitty.tcl,v 1.4 2007-10-18 21:07:03 robertdelmas Exp $
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
#  ::kitty::getPluginHelp
#     Retourne la documentation du driver
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
   global audace caption color

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

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 1

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill both -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -in $frm.frame2 -side left -fill both -expand 1

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame2 -side left -fill both -expand 1 -padx 80

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame5 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame5 -side left -fill both -expand 1

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame7 -side top -fill both -expand 1

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame7 -side top -fill both -expand 1

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame8 -side top -fill both -expand 1

   frame $frm.frame12 -borderwidth 0 -relief raised
   pack $frm.frame12 -in $frm.frame8 -side top -fill both -expand 1

   frame $frm.frame13 -borderwidth 0 -relief raised
   pack $frm.frame13 -in $frm.frame3 -side top -fill both -expand 1

   frame $frm.frame14 -borderwidth 0 -relief raised
   pack $frm.frame14 -in $frm.frame3 -side top -fill both -expand 1

   #--- Bouton radio Kitty-237
   radiobutton $frm.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(kitty,kitty_237)" -value 237 -variable ::kitty::private(modele) -command {
         set frm [ $::confCam::This.usr.onglet getframe kitty ]
         if { [ winfo exists $frm.lab4 ] } {
            destroy $frm.lab4 ; destroy $frm.radio_on ; destroy $frm.radio_off
            destroy $frm.temp_ccd ; destroy $frm.test
         }
         #--- Definition de la resolution
         if { ! [ winfo exists $frm.lab2 ] } {
            label $frm.lab2 -text "$caption(kitty,resolution)"
            pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10
            #---
            set list_combobox [ list $caption(kitty,can_12bits) $caption(kitty,can_8bits) ]
            ComboBox $frm.res \
               -width 7       \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::kitty::private(res) \
               -values $list_combobox
            pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
            #--- Definition du capteur de temperature
            label $frm.lab3 -text "$caption(kitty,capteur_temp)"
            pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            #---
            set list_combobox [ list $caption(kitty,capteur_temp_ad7893an2) $caption(kitty,capteur_temp_ad7893an5) ]
            ComboBox $frm.captemp \
               -width 12          \
               -height [ llength $list_combobox ] \
               -relief sunken     \
               -borderwidth 1     \
               -editable 0        \
               -textvariable ::kitty::private(captemp) \
               -values $list_combobox
            pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
         }
         #--- Gestion des boutons actif/inactif
         ::kitty::ConfKitty
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   pack $frm.radio0 -in $frm.frame1 -anchor center -side left -padx 10

   #--- Bouton radio Kitty-255
   radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(kitty,kitty_255)" -value 255 -variable ::kitty::private(modele) -state normal -command {
         set frm [ $::confCam::This.usr.onglet getframe kitty ]
         if { [ winfo exists $frm.lab4 ] } {
            destroy $frm.lab4 ; destroy $frm.radio_on ; destroy $frm.radio_off
            destroy $frm.temp_ccd ; destroy $frm.test
         }
         #--- Definition de la resolution
         if { ! [ winfo exists $frm.lab2 ] } {
            label $frm.lab2 -text "$caption(kitty,resolution)"
            pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10
            #---
            set list_combobox [ list $caption(kitty,can_12bits) $caption(kitty,can_8bits) ]
            ComboBox $frm.res \
               -width 7       \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::kitty::private(res) \
               -values $list_combobox
            pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
            #--- Definition du capteur de temperature
            label $frm.lab3 -text "$caption(kitty,capteur_temp)"
            pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            #---
            set list_combobox [ list $caption(kitty,capteur_temp_ad7893an2) $caption(kitty,capteur_temp_ad7893an5) ]
            ComboBox $frm.captemp \
               -width 12          \
               -height [ llength $list_combobox ] \
               -relief sunken     \
               -borderwidth 1     \
               -editable 0        \
               -textvariable ::kitty::private(captemp) \
               -values $list_combobox
            pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
         }
         #--- Gestion des boutons actif/inactif
         ::kitty::ConfKitty
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   pack $frm.radio1 -in $frm.frame1 -anchor center -side left -padx 10

   #--- Bouton radio Kitty-2
   radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(kitty,kitty_2)" -value K2 -variable ::kitty::private(modele) -command {
         set frm [ $::confCam::This.usr.onglet getframe kitty ]
         if { [ winfo exists $frm.lab2 ] } {
            destroy $frm.lab2 ; destroy $frm.res
            destroy $frm.lab3 ; destroy $frm.captemp
         }
         #--- Definition du refroidissement
         label $frm.lab4 -text "$caption(kitty,refroidissement_2)"
         pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10
         #--- Refroidissement On
         radiobutton $frm.radio_on -anchor w -highlightthickness 0 \
            -text "$caption(kitty,refroidissement_on)" -value 1 \
            -variable ::kitty::private(on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler on }
         pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Refroidissement Off
         radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
            -text "$caption(kitty,refroidissement_off)" -value 0 \
            -variable ::kitty::private(on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler off }
         pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Definition de la temperature du capteur CCD
         label $frm.temp_ccd -text "$caption(kitty,temperature_CCD)"
         pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
         #--- Bouton de test du microcontrolleur de la carte d'interface
         button $frm.test -text "$caption(kitty,test)" -relief raised \
            -command { cam$confCam($confCam(currentCamItem),camNo) sx28test }
         pack $frm.test -in $frm.frame14 -side left -padx 10 -pady 0 -ipadx 10 -ipady 5
         #--- Gestion des boutons actif/inactif
         ::kitty::ConfKitty
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   pack $frm.radio2 -in $frm.frame1 -anchor center -side left -padx 10

   #--- Definition du port
   label $frm.lab1 -text "$caption(kitty,port)"
   pack $frm.lab1 -in $frm.frame9 -anchor center -side left -padx 10

   #--- Bouton de configuration des ports et liaisons
   button $frm.configure -text "$caption(kitty,configurer)" -relief raised \
      -command {
         ::confLink::run ::kitty::private(port) { parallelport } \
            "- $caption(kitty,acquisition) - $caption(kitty,camera)"
      }
   pack $frm.configure -in $frm.frame9 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 7        \
      -height [ llength $list_combobox ] \
      -relief sunken  \
      -borderwidth 1  \
      -editable 0     \
      -textvariable ::kitty::private(port) \
      -values $list_combobox
   pack $frm.port -in $frm.frame9 -anchor center -side right -padx 10

   #--- Definition de la resolution
   if { $::kitty::private(modele) != "K2" } {
      label $frm.lab2 -text "$caption(kitty,resolution)"
      pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10

      set list_combobox [ list $caption(kitty,can_12bits) $caption(kitty,can_8bits) ]
      ComboBox $frm.res \
         -width 7       \
         -height [ llength $list_combobox ] \
         -relief sunken \
         -borderwidth 1 \
         -editable 0    \
         -textvariable ::kitty::private(res) \
         -values $list_combobox
      pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
   }

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(kitty,miroir_x)" -highlightthickness 0 \
      -variable ::kitty::private(mirh)
   pack $frm.mirx -in $frm.frame11 -anchor w -side left -padx 10

   checkbutton $frm.miry -text "$caption(kitty,miroir_y)" -highlightthickness 0 \
      -variable ::kitty::private(mirv)
   pack $frm.miry -in $frm.frame12 -anchor w -side left -padx 10

   #--- Definition du capteur de temperature
   if { $::kitty::private(modele) != "K2" } {
      label $frm.lab3 -text "$caption(kitty,capteur_temp)"
      pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

      set list_combobox [ list $caption(kitty,capteur_temp_ad7893an2) $caption(kitty,capteur_temp_ad7893an5) ]
      ComboBox $frm.captemp \
         -width 12          \
         -height [ llength $list_combobox ] \
         -relief sunken     \
         -borderwidth 1     \
         -editable 0        \
         -textvariable ::kitty::private(captemp) \
         -values $list_combobox
      pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
   #--- Definition du refroidissement, de la temperature du CCD et du test
   } else {
      #--- Definition du refroidissement
      label $frm.lab4 -text "$caption(kitty,refroidissement_2)"
      pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10
      #--- Refroidissement On
      radiobutton $frm.radio_on -anchor w -highlightthickness 0 \
         -text "$caption(kitty,refroidissement_on)" -value 1 \
         -variable ::kitty::private(on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler on }
      pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
      #--- Refroidissement Off
      radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
         -text "$caption(kitty,refroidissement_off)" -value 0 \
         -variable ::kitty::private(on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler off }
      pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
      #--- Definition de la temperature du capteur CCD
      label $frm.temp_ccd -text "$caption(kitty,temperature_CCD)"
      pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
      #--- Bouton de test du microcontrolleur de la carte d'interface
      button $frm.test -text "$caption(kitty,test)" -relief raised \
         -command { cam$confCam($confCam(currentCamItem),camNo) sx28test }
      pack $frm.test -in $frm.frame14 -side left -padx 10 -pady 0 -ipadx 10 -ipady 5
   }

   #--- Frame du site web officiel de la Kitty
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(kitty,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(kitty,site_web_ref)" \
         "$caption(kitty,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion des boutons actif/inactif
   ::kitty::ConfKitty

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::kitty::configureCamera
#    Configure la camera Kitty en fonction des donnees contenues dans les variables conf(kitty,...)
#
proc ::kitty::configureCamera { camItem } {
   global caption conf confCam

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
      #---
      ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
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
      #---
      ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
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
      #---
      ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
      #---
      if { [ info exists confCam(kitty,aftertemp) ] == "0" } {
         ::kitty::KittyDispTemp
      }
   }
}

#
# ::kitty::stop
#    Arrete la camera Kitty
#
proc ::kitty::stop { camItem } {
   global conf confCam

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(kitty,port) "cam$confCam($camItem,camNo)" "acquisition"

   #--- Gestion des boutons
   ::kitty::ConfKitty

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
         $frm.temp_ccd configure \
            -text "$caption(kitty,temperature_CCD) $temp_ccd $caption(kitty,deg_c)"
         set confCam(kitty,aftertemp) [ after 5000 ::kitty::KittyDispTemp ]
      } else {
         catch { unset confCam(kitty,aftertemp) }
      }
   }
}

#
# ::kitty::ConfKitty
# Permet d'activer ou de desactiver les widgets de configuration de la Kitty K2
#
proc ::kitty::ConfKitty { } {
   variable private
   global audace confCam

   set camItem $confCam(currentCamItem)

   if { [ winfo exists $audace(base).confCam ] } {
      set frm $private(frm)
      if { [ winfo exists $frm.radio_on ] } {
         if { [ ::confCam::getName $confCam($camItem,camNo) ] == "KITTYK2" } {
            #--- Widgets de configuration de la Kitty K2 actif
            $frm.radio_on configure -state normal
            $frm.radio_off configure -state normal
            $frm.temp_ccd configure -state normal
            $frm.test configure -state normal
         } else {
            #--- Widgets de configuration de la Kitty K2 inactif
            $frm.radio_on configure -state disabled
            $frm.radio_off configure -state disabled
            $frm.temp_ccd configure -state disabled
            $frm.test configure -state disabled
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

