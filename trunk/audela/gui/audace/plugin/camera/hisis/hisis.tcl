#
# Fichier : hisis.tcl
# Description : Configuration de la camera Hi-SIS
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::hisis {
   package provide hisis 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] hisis.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::hisis::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libhisis.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::hisis::getPluginType]] "hisis" "libhisis.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(hisis,installNewVersion) $sourceFileName [package version hisis] ]
   }
}

#
# ::hisis::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::hisis::getPluginTitle { } {
   global caption

   return "$caption(hisis,camera)"
}

#
# ::hisis::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::hisis::getPluginHelp { } {
   return "hisis.htm"
}

#
# ::hisis::getPluginType
#    Retourne le type du plugin
#
proc ::hisis::getPluginType { } {
   return "camera"
}

#
# ::hisis::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::hisis::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::hisis::getCamNo
#    Retourne le numero de la camera
#
proc ::hisis::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::hisis::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::hisis::isReady { camItem } {
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
# ::hisis::initPlugin
#    Initialise les variables conf(hisis,...)
#
proc ::hisis::initPlugin { } {
   variable private
   global conf

   #--- Initialise les variables de la camera Hi-SIS
   if { ! [ info exists conf(hisis,delai_a) ] }  { set conf(hisis,delai_a)  "5" }
   if { ! [ info exists conf(hisis,delai_b) ] }  { set conf(hisis,delai_b)  "2" }
   if { ! [ info exists conf(hisis,delai_c) ] }  { set conf(hisis,delai_c)  "7" }
   if { ! [ info exists conf(hisis,foncobtu) ] } { set conf(hisis,foncobtu) "2" }
   if { ! [ info exists conf(hisis,mirh) ] }     { set conf(hisis,mirh)     "0" }
   if { ! [ info exists conf(hisis,mirv) ] }     { set conf(hisis,mirv)     "0" }
   if { ! [ info exists conf(hisis,modele) ] }   { set conf(hisis,modele)   "22" }
   if { ! [ info exists conf(hisis,port) ] }     { set conf(hisis,port)     "LPT1:" }
   if { ! [ info exists conf(hisis,res) ] }      { set conf(hisis,res)      "12 bits" }
   if { ! [ info exists conf(hisis,debug) ] }    { set conf(hisis,debug)    "0" }
   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# ::hisis::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::hisis::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Hi-SIS dans le tableau private(...)
   set private(delai_a)  $conf(hisis,delai_a)
   set private(delai_b)  $conf(hisis,delai_b)
   set private(delai_c)  $conf(hisis,delai_c)
   set private(foncobtu) [ lindex "$caption(hisis,obtu_ouvert) $caption(hisis,obtu_ferme) $caption(hisis,obtu_synchro)" $conf(hisis,foncobtu) ]
   set private(mirh)     $conf(hisis,mirh)
   set private(mirv)     $conf(hisis,mirv)
   set private(modele)   [ lsearch "11 22 23 24 33 36 39 43 44 48" "$conf(hisis,modele)" ]
   set private(port)     $conf(hisis,port)
   set private(res)      $conf(hisis,res)
   set private(debug)    $conf(hisis,debug)
}

#
# ::hisis::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::hisis::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Hi-SIS dans le tableau conf(hisis,...)
   set conf(hisis,delai_a)  $private(delai_a)
   set conf(hisis,delai_b)  $private(delai_b)
   set conf(hisis,delai_c)  $private(delai_c)
   set conf(hisis,foncobtu) [ lsearch "$caption(hisis,obtu_ouvert) $caption(hisis,obtu_ferme) $caption(hisis,obtu_synchro)" "$private(foncobtu)" ]
   set conf(hisis,mirh)     $private(mirh)
   set conf(hisis,mirv)     $private(mirv)
   set conf(hisis,modele)   [ lindex "11 22 23 24 33 36 39 43 44 48" $private(modele) ]
   set conf(hisis,port)     $private(port)
   set conf(hisis,res)      $private(res)
   set conf(hisis,debug)    $private(debug)
}

#
# ::hisis::fillConfigPage
#    Interface de configuration de la camera Hi-SIS
#
proc ::hisis::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::hisis::confToWidget

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
      if { [ lsearch -exact $list_combobox $private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [ lindex $list_combobox 0 ]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame du choix du modele (Hi-SIS11, Hi-SIS22, Hi-SIS23, Hi-SIS24 et Hi-SIS33)
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Bouton radio Hi-SIS11
      radiobutton $frm.frame1.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_11)" -value 0 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame1.radio0 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS22
      radiobutton $frm.frame1.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_22)" -value 1 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame1.radio1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS23
      radiobutton $frm.frame1.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_23)" -value 2 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame1.radio2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS24
      radiobutton $frm.frame1.radio3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_24)" -value 3 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame1.radio3 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS33
      radiobutton $frm.frame1.radio4 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_33)" -value 4 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame1.radio4 -anchor center -side left -padx 10

   pack $frm.frame1 -side top -fill x -pady 10

   #--- Frame du choix du modele (Hi-SIS36, Hi-SIS39, Hi-SIS43, Hi-SIS44 et Hi-SIS48)
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Bouton radio Hi-SIS36
      radiobutton $frm.frame2.radio5 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_36)" -value 5 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame2.radio5 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS39
      radiobutton $frm.frame2.radio6 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_39)" -value 6 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame2.radio6 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS43
      radiobutton $frm.frame2.radio7 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_43)" -value 7 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame2.radio7 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS44
      radiobutton $frm.frame2.radio8 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_44)" -value 8 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame2.radio8 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS48
      radiobutton $frm.frame2.radio9 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(hisis,hisis_48)" -value 9 -variable ::hisis::private(modele) \
         -command { ::hisis::confHiSIS }
      pack $frm.frame2.radio9 -anchor center -side left -padx 10

   pack $frm.frame2 -side top -fill x -pady 10

   #--- Frame de la configuration du port et de la resolution, des miroirs en x et en y,  de l'obturateur et des delais
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Frame de la configuration du port et de la resolution, des miroirs en x et en y et de l'obturateur
      frame $frm.frame3.frame5 -borderwidth 0 -relief raised

         #--- Frame de la configuration du port et de la resolution, et des miroirs en x et en y
         frame $frm.frame3.frame5.frame7 -borderwidth 0 -relief raised

            #--- Frame de la configuration du port et de la resolution
            frame $frm.frame3.frame5.frame7.frame9 -borderwidth 0 -relief raised

               #--- Frame de la configuration du port
               frame $frm.frame3.frame5.frame7.frame9.frame11 -borderwidth 0 -relief raised

                  #--- Definition du port
                  label $frm.frame3.frame5.frame7.frame9.frame11.lab1 -text "$caption(hisis,port)"
                  pack $frm.frame3.frame5.frame7.frame9.frame11.lab1 -anchor center -side left -padx 10

                  #--- Bouton de configuration des ports et liaisons
                  button $frm.frame3.frame5.frame7.frame9.frame11.configure -text "$caption(hisis,configurer)" \
                     -relief raised \
                     -command {
                        ::confLink::run ::hisis::private(port) { parallelport } \
                           "- $caption(hisis,acquisition) - $caption(hisis,camera)"
                     }
                  pack $frm.frame3.frame5.frame7.frame9.frame11.configure -anchor center -side left -pady 10 \
                     -ipadx 10 -ipady 1 -expand 0

                  #--- Choix du port ou de la liaison
                  ComboBox $frm.frame3.frame5.frame7.frame9.frame11.port \
                     -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
                     -height [ llength $list_combobox ] \
                     -relief sunken \
                     -borderwidth 1 \
                     -editable 0    \
                     -textvariable ::hisis::private(port) \
                     -values $list_combobox
                  pack $frm.frame3.frame5.frame7.frame9.frame11.port -anchor center -side left -padx 20

               pack $frm.frame3.frame5.frame7.frame9.frame11 -side top -fill x

               #--- Frame de la configuration de la resolution
               frame $frm.frame3.frame5.frame7.frame9.frame12 -borderwidth 0 -relief raised

                  #--- Configuration de la resolution
                  label $frm.frame3.frame5.frame7.frame9.frame12.lab2 -text "$caption(hisis,can_resolution)"
                  pack $frm.frame3.frame5.frame7.frame9.frame12.lab2 -anchor center -side left -padx 10

                  set list_combobox [ list $caption(hisis,can_12bits) $caption(hisis,can_14bits) ]
                  ComboBox $frm.frame3.frame5.frame7.frame9.frame12.res \
                     -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
                     -height [ llength $list_combobox ] \
                     -relief sunken \
                     -borderwidth 1 \
                     -editable 0    \
                     -textvariable ::hisis::private(res) \
                     -values $list_combobox
                  pack $frm.frame3.frame5.frame7.frame9.frame12.res -anchor center -side left -padx 30

               pack $frm.frame3.frame5.frame7.frame9.frame12 -side top -fill both -expand 1

            pack $frm.frame3.frame5.frame7.frame9 -side left -fill both -expand 1

            #--- Frame des miroirs en x, en y et debug
            frame $frm.frame3.frame5.frame7.frame10 -borderwidth 0 -relief raised

               #--- Miroir en x
               checkbutton $frm.frame3.frame5.frame7.frame10.mirx -text "$caption(hisis,miroir_x)" \
                  -highlightthickness 0 -variable ::hisis::private(mirh)
               pack $frm.frame3.frame5.frame7.frame10.mirx -anchor w -side top -padx 10 -pady 10

               #--- Mode debug
               checkbutton $frm.frame3.frame5.frame7.frame10.debug -text "$caption(hisis,debug) (hisis.log)" \
                  -highlightthickness 0 -variable ::hisis::private(debug)
               pack $frm.frame3.frame5.frame7.frame10.debug -anchor w -side bottom -padx 10 -pady 10

               #--- Miroir en y
               checkbutton $frm.frame3.frame5.frame7.frame10.miry -text "$caption(hisis,miroir_y)" \
                  -highlightthickness 0 -variable ::hisis::private(mirv)
               pack $frm.frame3.frame5.frame7.frame10.miry -anchor w -side bottom -padx 10 -pady 10

            pack $frm.frame3.frame5.frame7.frame10 -anchor n -side left -fill x

         pack $frm.frame3.frame5.frame7 -side top -fill both -expand 1

         #--- Frame du mode de fonctionnement de l'obturateur
         frame $frm.frame3.frame5.frame8 -borderwidth 0 -relief raised

            #--- Mode de fonctionnement de l'obturateur
            label $frm.frame3.frame5.frame8.lab0 -text "$caption(hisis,fonc_obtu)"
            pack $frm.frame3.frame5.frame8.lab0 -anchor center -side left -padx 8

            set list_combobox [ list $caption(hisis,obtu_ouvert) $caption(hisis,obtu_ferme) $caption(hisis,obtu_synchro) ]
            ComboBox $frm.frame3.frame5.frame8.foncobtu \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -textvariable ::hisis::private(foncobtu) \
               -editable 0    \
               -values $list_combobox
            pack $frm.frame3.frame5.frame8.foncobtu -anchor center -side left -padx 10

         pack $frm.frame3.frame5.frame8 -side top -fill both -expand 1

      pack $frm.frame3.frame5 -side left -fill both -expand 1

      #--- Frame de configuration des delais a, b et c
      frame $frm.frame3.frame6 -borderwidth 0 -relief raised

         #--- Frame de configuration du delai a
         frame $frm.frame3.frame6.frame13 -borderwidth 0 -relief raised

            label $frm.frame3.frame6.frame13.lab3 -text "$caption(hisis,delai_a)"
            pack $frm.frame3.frame6.frame13.lab3 -anchor center -side left -padx 10

            entry $frm.frame3.frame6.frame13.delai_a -textvariable ::hisis::private(delai_a) -width 3 -justify center
            pack $frm.frame3.frame6.frame13.delai_a -anchor center -side left -padx 10

         pack $frm.frame3.frame6.frame13 -side top -fill both -expand 1

         #--- Frame de configuration du delai b
         frame $frm.frame3.frame6.frame14 -borderwidth 0 -relief raised

            label $frm.frame3.frame6.frame14.lab4 -text "$caption(hisis,delai_b)"
            pack $frm.frame3.frame6.frame14.lab4 -anchor center -side left -padx 10

            entry $frm.frame3.frame6.frame14.delai_b -textvariable ::hisis::private(delai_b) -width 3 -justify center
           pack $frm.frame3.frame6.frame14.delai_b -anchor center -side left -padx 10

         pack $frm.frame3.frame6.frame14 -side top -fill both -expand 1

         #--- Frame de configuration du delai c
         frame $frm.frame3.frame6.frame15 -borderwidth 0 -relief raised

            label $frm.frame3.frame6.frame15.lab5 -text "$caption(hisis,delai_c)"
            pack $frm.frame3.frame6.frame15.lab5 -anchor center -side left -padx 10

            entry $frm.frame3.frame6.frame15.delai_c -textvariable ::hisis::private(delai_c) -width 3 -justify center
            pack $frm.frame3.frame6.frame15.delai_c -anchor center -side left -padx 10

         pack $frm.frame3.frame6.frame15 -side top -fill both -expand 1

      pack $frm.frame3.frame6 -side left -fill both -expand 1

   pack $frm.frame3 -side top -fill both -expand 1

   #--- Frame du site web officiel de la Hi-SIS
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(hisis,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(hisis,site_web_ref)" \
         "$caption(hisis,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::hisis::confHiSIS

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::hisis::configureCamera
#    Configure la camera Hi-SIS en fonction des donnees contenues dans les variables conf(hisis,...)
#
proc ::hisis::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0 } {
         error "" "" "CameraUnique"
      }
      #--- mode debug
      if { $::conf(hisis,debug) == 1 } {
         # LOG_NONE    0
         # LOG_ERROR   1
         # LOG_WARNING 2
         # LOG_INFO    3
         # LOG_DEBUG   4
         set logLevel 4
      } else {
         set logLevel 0
      }
      if { $conf(hisis,modele) == "11" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS11 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "22" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS22-[ lindex $conf(hisis,res) 0 ] -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele) ($conf(hisis,res))\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
         #--- Je configure les delais
         cam$camNo delayloops $conf(hisis,delai_a) $conf(hisis,delai_b) $conf(hisis,delai_c)
      } elseif { $conf(hisis,modele) == "23" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS23 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
          }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "24" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS24 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "33" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS33 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "36" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS36 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "39" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS39 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "43" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS43 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "44" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS44 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      } elseif { $conf(hisis,modele) == "48" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(hisis,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create hisis $conf(hisis,port) -debug_directory $::audace(rep_log) -name Hi-SIS48 -loglevel $logLevel ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(hisis,port_camera) $conf(hisis,modele)\
            $caption(hisis,2points) $conf(hisis,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'obturateur
         switch -exact -- $conf(hisis,foncobtu) {
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
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(hisis,mirh)
         cam$camNo mirrorv $conf(hisis,mirv)
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::hisis::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::hisis::stop
#    Arrete la camera Hi-SIS
#
proc ::hisis::stop { camItem } {
   variable private
   global conf

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(hisis,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::hisis::confHiSIS
#    Permet d'activer ou de desactiver les widgets de configuration des Hi-SIS
#
proc ::hisis::confHiSIS { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::hisis::private(modele) == "0" } {
            #--- Widgets de configuration de la Hi-SIS11 actifs
            pack forget $frm.frame3.frame5.frame8
            pack forget $frm.frame3.frame5.frame7.frame9.frame12
            pack forget $frm.frame3.frame6.frame13
            pack forget $frm.frame3.frame6.frame14
            pack forget $frm.frame3.frame6.frame15
         } elseif { $::hisis::private(modele) == "1" } {
            #--- Widgets de configuration de la Hi-SIS22 actifs
            pack $frm.frame3.frame5.frame8 -side top -fill both -expand 1
            pack $frm.frame3.frame5.frame7.frame9.frame12 -side top -fill both -expand 1
            pack $frm.frame3.frame6.frame13 -side top -fill both -expand 1
            pack $frm.frame3.frame6.frame14 -side top -fill both -expand 1
            pack $frm.frame3.frame6.frame15 -side top -fill both -expand 1
         } else {
            #--- Widgets de configuration des autres Hi-SIS actifs
            pack $frm.frame3.frame5.frame8  -side top -fill both -expand 1
            pack forget $frm.frame3.frame5.frame7.frame9.frame12
            pack forget $frm.frame3.frame6.frame13
            pack forget $frm.frame3.frame6.frame14
            pack forget $frm.frame3.frame6.frame15
         }
      }
   }
}

#
# ::hisis::setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::hisis::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(hisis,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      0  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "opened"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(hisis,obtu_ouvert)
      }
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(hisis,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(hisis,obtu_synchro)
      }
   }
}

#
# ::hisis::getPluginProperty
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
proc ::hisis::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic       {
         if { $::conf(hisis,modele) == "11" } {
            return [ list 4096 0 ]
         } else {
            return [ list 32767 -32768 ]
         }
      }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       {
         if { $::conf(hisis,modele) == "11" } {
            return 0
         } else {
            return 1
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
      shutterList      {
         if { $::conf(hisis,modele) == "11" } {
            return 0
         } else {
            #--- O + F + S - A confirmer avec le materiel
            return [ list $::caption(hisis,obtu_ouvert) $::caption(hisis,obtu_ferme) $::caption(hisis,obtu_synchro) ]
         }
      }
   }
}

