#
# Fichier : th7852a.tcl
# Description : Configuration de la camera TH7852A
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::th7852a {
   package provide th7852a 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] th7852a.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::th7852a::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libcamth.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::th7852a::getPluginType]] "th7852a" "libcamth.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(th7852a,installNewVersion) $sourceFileName [package version th7852a] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::th7852a::getPluginTitle { } {
   global caption

   return "$caption(th7852a,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::th7852a::getPluginHelp { } {
   return "th7852a.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::th7852a::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::th7852a::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::th7852a::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::th7852a::isReady { camItem } {
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
#    Initialise les variables conf(th7852a,...)
#
proc ::th7852a::initPlugin { } {
   variable private
   global conf

   #--- Initialise la variable de la camera TH7852A
   if { ! [ info exists conf(th7852a,mirh) ] } { set conf(th7852a,mirh) "0" }
   if { ! [ info exists conf(th7852a,mirv) ] } { set conf(th7852a,mirv) "0" }
   if { ! [ info exists conf(th7852a,coef) ] } { set conf(th7852a,coef) "1.0" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# confToWidget
#    Copie la variable de configuration dans une variable locale
#
proc ::th7852a::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera TH7852A dans le tableau private(...)
   set private(mirh) $conf(th7852a,mirh)
   set private(mirv) $conf(th7852a,mirv)
   set private(coef) $conf(th7852a,coef)
}

#
# widgetToConf
#    Copie la variable locale dans une variable de configuration
#
proc ::th7852a::widgetToConf { camItem } {
   variable private
   global conf

   #--- Memorise la configuration de la camera TH7852A dans le tableau conf(th7852a,...)
   set conf(th7852a,mirh) $private(mirh)
   set conf(th7852a,mirv) $private(mirv)
   set conf(th7852a,coef) $private(coef)
}

#
# fillConfigPage
#    Interface de configuration de la camera TH7852A
#
proc ::th7852a::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- confToWidget
   ::th7852a::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du coefficent et des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame du coefficient
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         label $frm.frame1.frame3.lab2 -text "$caption(th7852a,coef)"
         pack $frm.frame1.frame3.lab2 -anchor n -side left -padx 10 -pady 30

         entry $frm.frame1.frame3.coef -textvariable ::th7852a::private(coef) -width 5 -justify center
         pack $frm.frame1.frame3.coef -anchor n -side left -padx 0 -pady 30

      pack $frm.frame1.frame3 -anchor n -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         checkbutton $frm.frame1.frame4.mirx -text "$caption(th7852a,miroir_x)" -highlightthickness 0 \
            -variable ::th7852a::private(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(th7852a,miroir_y)" -highlightthickness 0 \
            -variable ::th7852a::private(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor n -side left -fill x -padx 20

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la TH7852A d'Yves LATIL (a creer)
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(th7852a,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(th7852a,site_web_ref)" "" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera TH7852A en fonction des donnees contenues dans les variables conf(th7852a,...)
#
proc ::th7852a::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la camera
      if { [ catch { set camNo [ cam::create camth "unknown" -debug_directory $::audace(rep_log) -name TH7852A ] } catchError ] == 1 } {
         if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
            error "" "" "NotRoot"
         } else {
            error $catchError
         }
      }
      console::affiche_entete "$caption(th7852a,port_camera) $caption(th7852a,2points) $caption(th7852a,bus_ISA)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(th7852a,mirh)
      cam$camNo mirrorv $conf(th7852a,mirv)
      #--- Je configure le coefficient
      cam$camNo timescale $conf(th7852a,coef)
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::th7852a::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera TH7852A
#
proc ::th7852a::stop { camItem } {
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
proc ::th7852a::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 ] }
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

