#
# Fichier : starlight.tcl
# Description : Configuration de la camera Starlight
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::starlight {
   package provide starlight 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] starlight.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::starlight::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libstarlight.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::starlight::getPluginType]] "starlight" "libstarlight.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(starlight,installNewVersion) $sourceFileName [package version starlight] ]
   }
}

#
# ::starlight::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::starlight::getPluginTitle { } {
   global caption

   return "$caption(starlight,camera)"
}

#
# ::starlight::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::starlight::getPluginHelp { } {
   return "starlight.htm"
}

#
# ::starlight::getPluginType
#    Retourne le type du plugin
#
proc ::starlight::getPluginType { } {
   return "camera"
}

#
# ::starlight::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::starlight::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::starlight::getCamNo
#    Retourne le numero de la camera
#
proc ::starlight::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::starlight::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::starlight::isReady { camItem } {
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
# ::starlight::initPlugin
#    Initialise les variables conf(starlight,...)
#
proc ::starlight::initPlugin { } {
   variable private
   global conf

   #--- Initialise les variables de la camera Starlight
   if { ! [ info exists conf(starlight,acc) ] }    { set conf(starlight,acc)    "0" }
   if { ! [ info exists conf(starlight,mirh) ] }   { set conf(starlight,mirh)   "0" }
   if { ! [ info exists conf(starlight,mirv) ] }   { set conf(starlight,mirv)   "0" }
   if { ! [ info exists conf(starlight,modele) ] } { set conf(starlight,modele) "MX516" }
   if { ! [ info exists conf(starlight,port) ] }   { set conf(starlight,port)   "LPT1:" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# ::starlight::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::starlight::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Starlight dans le tableau private(...)
   set private(acc)    [ lindex "$caption(starlight,sans_accelerateur) $caption(starlight,avec_accelerateur)" $conf(starlight,acc) ]
   set private(mirh)   $conf(starlight,mirh)
   set private(mirv)   $conf(starlight,mirv)
   set private(modele) [ lsearch "MX516 MX916 HX516" "$conf(starlight,modele)" ]
   set private(port)   $conf(starlight,port)
}

#
# ::starlight::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::starlight::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Starlight dans le tableau conf(starlight,...)
   set conf(starlight,acc)    [ lsearch "$caption(starlight,sans_accelerateur) $caption(starlight,avec_accelerateur)" "$private(acc)" ]
   set conf(starlight,mirh)   $private(mirh)
   set conf(starlight,mirv)   $private(mirv)
   set conf(starlight,modele) [ lindex "MX516 MX916 HX516" $private(modele) ]
   set conf(starlight,port)   $private(port)
}

#
# ::starlight::fillConfigPage
#    Interface de configuration de la camera Starlight
#
proc ::starlight::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- confToWidget
   ::starlight::confToWidget

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
      if { [ lsearch -exact $list_combobox $::starlight::private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set ::starlight::private(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame du choix du modele de Starlight
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Modele MX516
      radiobutton $frm.frame1.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(starlight,mx5)" -value 0 -variable ::starlight::private(modele)
      pack $frm.frame1.radio0 -anchor center -side left -padx 10

      #--- Modele MX916
      radiobutton $frm.frame1.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(starlight,mx9)" -value 1 -variable ::starlight::private(modele)
      pack $frm.frame1.radio1 -anchor center -side left -padx 10

      #--- Modele HX516
      radiobutton $frm.frame1.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(starlight,hx5)" -value 2 -variable ::starlight::private(modele)
      pack $frm.frame1.radio2 -anchor center -side left -padx 10

   pack $frm.frame1 -side top -fill x -expand 0 -pady 15

   #--- Frame du port, du choix de la liaison et des miroirs en x et en y
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Frame du port et du choix de la liaison
      frame $frm.frame2.frame5 -borderwidth 0 -relief raised

         #--- Definition du port
         label $frm.frame2.frame5.lab1 -text "$caption(starlight,port)"
         pack $frm.frame2.frame5.lab1 -anchor center -side left -padx 10 -pady 30

         #--- Bouton de configuration des ports et liaisons
         button $frm.frame2.frame5.configure -text "$caption(starlight,configurer)" -relief raised \
            -command {
               ::confLink::run ::starlight::private(port) { parallelport } \
                  "- $caption(starlight,acquisition) - $caption(starlight,camera)"
            }
         pack $frm.frame2.frame5.configure -anchor center -side left -pady 28 -ipadx 10 -ipady 1 -expand 0

         #--- Choix du port ou de la liaison
         ComboBox $frm.frame2.frame5.port \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken  \
            -borderwidth 1  \
            -editable 0     \
            -textvariable ::starlight::private(port) \
            -values $list_combobox
         pack $frm.frame2.frame5.port -anchor center -side left -padx 10 -pady 30

      pack $frm.frame2.frame5 -anchor nw -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame2.frame6 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame2.frame6.mirx -text "$caption(starlight,miroir_x)" -highlightthickness 0 \
            -variable ::starlight::private(mirh)
         pack $frm.frame2.frame6.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame2.frame6.miry -text "$caption(starlight,miroir_y)" -highlightthickness 0 \
            -variable ::starlight::private(mirv)
         pack $frm.frame2.frame6.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame2.frame6 -anchor nw -side left -fill x -padx 20

   pack $frm.frame2 -side top -fill x -expand 0

   #--- Frame d'accelerateur de port parallele
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Accelerateur de port parallele
      label $frm.frame3.lab2 -text "$caption(starlight,accelerateur)"
      pack $frm.frame3.lab2 -anchor n -side left -padx 10 -pady 10

      set list_combobox [ list $caption(starlight,sans_accelerateur) $caption(starlight,avec_accelerateur) ]
      ComboBox $frm.frame3.acc \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken \
         -borderwidth 1 \
         -editable 0    \
         -textvariable ::starlight::private(acc) \
         -values $list_combobox
      pack $frm.frame3.acc -anchor n -side left -padx 10 -pady 10

   pack $frm.frame3 -side top -fill both -expand 1

   #--- Frame du site web officiel de la CB245
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(starlight,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(starlight,site_web_ref)" \
         "$caption(starlight,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2
}

#
# ::starlight::configureCamera
#    Configure la camera Starlight en fonction des donnees contenues dans les variables conf(starlight,...)
#
proc ::starlight::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      if { $conf(starlight,modele) == "MX516" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(starlight,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create starlight $conf(starlight,port) -debug_directory $::audace(rep_log) -name MX516 ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(starlight,port_camera) $conf(starlight,modele)\
            $caption(starlight,2points) $conf(starlight,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'accelerateur de port parallele
         cam$camNo accelerator $conf(starlight,acc)
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(starlight,mirh)
         cam$camNo mirrorv $conf(starlight,mirv)
      } elseif { $conf(starlight,modele) == "MX916" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(starlight,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create starlight $conf(starlight,port) -debug_directory $::audace(rep_log) -name MX916 ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(starlight,port_camera) $conf(starlight,modele)\
            $caption(starlight,2points) $conf(starlight,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'accelerateur de port parallele
         cam$camNo accelerator $conf(starlight,acc)
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(starlight,mirh)
         cam$camNo mirrorv $conf(starlight,mirv)
      } elseif { $conf(starlight,modele) == "HX516" } {
         #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
         set linkNo [ ::confLink::create $conf(starlight,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
         #--- Je cree la camera
         if { [ catch { set camNo [ cam::create starlight $conf(starlight,port) -debug_directory $::audace(rep_log) -name HX516 ] } catchError ] == 1 } {
            if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
               error "" "" "NotRoot"
            } else {
               error $catchError
            }
         }
         console::affiche_entete "$caption(starlight,port_camera) $conf(starlight,modele)\
            $caption(starlight,2points) $conf(starlight,port)\n"
         console::affiche_saut "\n"
         #--- Je change de variable
         set private($camItem,camNo) $camNo
         #--- Je configure l'accelerateur de port parallele
         cam$camNo accelerator $conf(starlight,acc)
         #--- J'associe le buffer de la visu
         cam$camNo buf $bufNo
         #--- Je configure l'oriention des miroirs par defaut
         cam$camNo mirrorh $conf(starlight,mirh)
         cam$camNo mirrorv $conf(starlight,mirv)
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::starlight::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::starlight::stop
#    Arrete la camera Starlight
#
proc ::starlight::stop { camItem } {
   variable private
   global conf

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(starlight,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::starlight::getPluginProperty
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
proc ::starlight::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 32767 -32768 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
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
      shutterList      { return [ list "" ] }
   }
}

