#
# Fichier : scr1300xtc.tcl
# Description : Configuration de la camera SCR1300XTC
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::scr1300xtc {
   package provide scr1300xtc 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] scr1300xtc.cap ]
}

#
# ::scr1300xtc::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::scr1300xtc::getPluginTitle { } {
   global caption

   return "$caption(scr1300xtc,camera)"
}

#
# ::scr1300xtc::getPluginHelp
#    Retourne la documentation du plugin
#
proc ::scr1300xtc::getPluginHelp { } {
   return "scr1300xtc.htm"
}

#
# ::scr1300xtc::getPluginType
#    Retourne le type du plugin
#
proc ::scr1300xtc::getPluginType { } {
   return "camera"
}

#
# ::scr1300xtc::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::scr1300xtc::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::scr1300xtc::getCamNo
#    Retourne le numero de la camera
#
proc ::scr1300xtc::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# ::scr1300xtc::isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::scr1300xtc::isReady { camItem } {
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
# ::scr1300xtc::initPlugin
#    Initialise les variables conf(scr1300xtc,...)
#
proc ::scr1300xtc::initPlugin { } {
   variable private
   global conf

   #--- Initialise les variables de la camera SCR1300XTC
   if { ! [ info exists conf(scr1300xtc,port) ] } { set conf(scr1300xtc,port) "LPT1:" }
   if { ! [ info exists conf(scr1300xtc,mirh) ] } { set conf(scr1300xtc,mirh) "0" }
   if { ! [ info exists conf(scr1300xtc,mirv) ] } { set conf(scr1300xtc,mirv) "0" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# ::scr1300xtc::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::scr1300xtc::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera SCR1300XTC dans le tableau private(...)
   set private(port) $conf(scr1300xtc,port)
   set private(mirh) $conf(scr1300xtc,mirh)
   set private(mirv) $conf(scr1300xtc,mirv)
}

#
# ::scr1300xtc::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::scr1300xtc::widgetToConf { camItem } {
   variable private
   global conf

   #--- Memorise la configuration de la camera SCR1300XTC dans le tableau conf(scr1300xtc,...)
   set conf(scr1300xtc,port) $private(port)
   set conf(scr1300xtc,mirh) $private(mirh)
   set conf(scr1300xtc,mirv) $private(mirv)
}

#
# ::scr1300xtc::fillConfigPage
#    Interface de configuration de la camera SCR1300XTC
#
proc ::scr1300xtc::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- confToWidget
   ::scr1300xtc::confToWidget

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
      if { [ lsearch -exact $list_combobox $private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame de la configuration du port et des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame de la configuration du port
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Definition du port
         label $frm.frame1.frame3.lab1 -text "$caption(scr1300xtc,port)"
         pack $frm.frame1.frame3.lab1 -anchor center -side left -padx 10 -pady 30

         #--- Bouton de configuration des ports et liaisons
         button $frm.frame1.frame3.configure -text "$caption(scr1300xtc,configurer)" -relief raised \
            -command {
               ::confLink::run ::scr1300xtc::private(port) { parallelport } \
                  "- $caption(scr1300xtc,acquisition) - $caption(scr1300xtc,camera)"
            }
         pack $frm.frame1.frame3.configure -anchor center -side left -pady 28 -ipadx 10 -ipady 1 -expand 0

         #--- Choix du port ou de la liaison
         ComboBox $frm.frame1.frame3.port \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken                \
            -borderwidth 1                \
            -editable 0                   \
            -textvariable ::scr1300xtc::private(port) \
            -values $list_combobox
         pack $frm.frame1.frame3.port -anchor center -side left -padx 10 -pady 30

      pack $frm.frame1.frame3 -anchor nw -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame1.frame4.mirx -text "$caption(scr1300xtc,miroir_x)" -highlightthickness 0 \
            -variable ::scr1300xtc::private(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(scr1300xtc,miroir_y)" -highlightthickness 0 \
            -variable ::scr1300xtc::private(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor nw -side left -fill x -padx 20

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la SCR1300XTC
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(scr1300xtc,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(scr1300xtc,site_web_ref)" \
         "$caption(scr1300xtc,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::scr1300xtc::configureCamera
#    Configure la camera SCR1300XTC en fonction des donnees contenues dans les variables conf(scr1300xtc,...)
#
proc ::scr1300xtc::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
      set linkNo [ ::confLink::create $conf(scr1300xtc,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
      #--- Je cree la camera
      if { [ catch { set camNo [ cam::create synonyme $conf(scr1300xtc,port) -debug_directory $::audace(rep_log) -name SCR1300XTC ] } catchError ] == 1 } {
         if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
            error "" "" "NotRoot"
         } else {
            error $catchError
         }
      }
      console::affiche_entete "$caption(scr1300xtc,port_camera) $caption(scr1300xtc,2points) $conf(scr1300xtc,port)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(scr1300xtc,mirh)
      cam$camNo mirrorv $conf(scr1300xtc,mirv)
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::scr1300xtc::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# ::scr1300xtc::stop
#    Arrete la camera SCR1300XTC
#
proc ::scr1300xtc::stop { camItem } {
   variable private
   global conf

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(scr1300xtc,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# ::scr1300xtc::getPluginProperty
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
proc ::scr1300xtc::getPluginProperty { camItem propertyName } {
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

