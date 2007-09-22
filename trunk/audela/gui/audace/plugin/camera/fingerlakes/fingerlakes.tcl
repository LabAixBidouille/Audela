#
# Fichier : fingerlakes.tcl
# Description : Configuration de la camera FLI (Finger Lakes Instrumentation)
# Auteur : Robert DELMAS
# Mise a jour $Id: fingerlakes.tcl,v 1.13 2007-09-22 06:40:06 robertdelmas Exp $
#

namespace eval ::fingerlakes {
   package provide fingerlakes 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] fingerlakes.cap ]
}

#
# ::fingerlakes::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::fingerlakes::getPluginTitle { } {
   global caption

   return "$caption(fingerlakes,camera)"
}

#
#  ::fingerlakes::getPluginHelp
#     Retourne la documentation du driver
#
proc ::fingerlakes::getPluginHelp { } {
   return "fingerlakes.htm"
}

#
# ::fingerlakes::getPluginType
#    Retourne le type de driver
#
proc ::fingerlakes::getPluginType { } {
   return "camera"
}

#
# ::fingerlakes::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::fingerlakes::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::fingerlakes::initPlugin
#    Initialise les variables conf(fingerlakes,...)
#
proc ::fingerlakes::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera FLI
   if { ! [ info exists conf(fingerlakes,cool) ] }     { set conf(fingerlakes,cool)     "0" }
   if { ! [ info exists conf(fingerlakes,foncobtu) ] } { set conf(fingerlakes,foncobtu) "2" }
   if { ! [ info exists conf(fingerlakes,mirh) ] }     { set conf(fingerlakes,mirh)     "0" }
   if { ! [ info exists conf(fingerlakes,mirv) ] }     { set conf(fingerlakes,mirv)     "0" }
   if { ! [ info exists conf(fingerlakes,temp) ] }     { set conf(fingerlakes,temp)     "-50" }
}

#
# ::fingerlakes::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::fingerlakes::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera fingerlakes dans le tableau private(...)
   set private(cool)     $conf(fingerlakes,cool)
   set private(foncobtu) [ lindex "$caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro)" $conf(fingerlakes,foncobtu) ]
   set private(mirh)     $conf(fingerlakes,mirh)
   set private(mirv)     $conf(fingerlakes,mirv)
   set private(temp)     $conf(fingerlakes,temp)
}

#
# ::fingerlakes::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::fingerlakes::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera FLI dans le tableau conf(fingerlakes,...)
   set conf(fingerlakes,cool)     $private(cool)
   set conf(fingerlakes,foncobtu) [ lsearch "$caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro)" "$private(foncobtu)" ]
   set conf(fingerlakes,mirh)     $private(mirh)
   set conf(fingerlakes,mirv)     $private(mirv)
   set conf(fingerlakes,temp)     $private(temp)
}

#
# ::fingerlakes::fillConfigPage
#    Interface de configuration de la camera FLI
#
proc ::fingerlakes::fillConfigPage { frm } {
   variable private
   global audace caption color

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::fingerlakes::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du refroidissement, de la temperature du capteur CCD, des miroirs en x et en y et de l'obturateur
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame du refroidissement, de la temperature du capteur CCD et des miroirs en x et en y
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Frame du refroidissement et de la temperature du capteur CCD
         frame $frm.frame1.frame3.frame4 -borderwidth 0 -relief raised

            #--- Frame du refroidissement
            frame $frm.frame1.frame3.frame4.frame6 -borderwidth 0 -relief raised

               #--- Definition du refroidissement
               checkbutton $frm.frame1.frame3.frame4.frame6.cool -text "$caption(fingerlakes,refroidissement)" \
                  -highlightthickness 0 -variable ::fingerlakes::private(cool)
               pack $frm.frame1.frame3.frame4.frame6.cool -anchor center -side left -padx 0 -pady 5

               entry $frm.frame1.frame3.frame4.frame6.temp -textvariable ::fingerlakes::private(temp) -width 4 \
                  -justify center
               pack $frm.frame1.frame3.frame4.frame6.temp -anchor center -side left -padx 5 -pady 5

               label $frm.frame1.frame3.frame4.frame6.tempdeg \
                  -text "$caption(fingerlakes,deg_c) $caption(fingerlakes,refroidissement_1)"
               pack $frm.frame1.frame3.frame4.frame6.tempdeg -side left -fill x -padx 0 -pady 5

            pack $frm.frame1.frame3.frame4.frame6 -side top -fill x -padx 10

            #--- Frame de la temperature du capteur CCD
            frame $frm.frame1.frame3.frame4.frame7 -borderwidth 0 -relief raised

               #--- Definition de la temperature du capteur CCD
               label $frm.frame1.frame3.frame4.frame7.temp_ccd -text "$caption(fingerlakes,temperature_CCD)"
               pack $frm.frame1.frame3.frame4.frame7.temp_ccd -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame4.frame7 -side top -fill x -padx 30

         pack $frm.frame1.frame3.frame4 -side left -fill x -expand 0

         #--- Frame des miroirs en x et en y
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Miroir en x et en y
            checkbutton $frm.frame1.frame3.frame5.mirx -text "$caption(fingerlakes,miroir_x)" -highlightthickness 0 \
               -variable ::fingerlakes::private(mirh)
            pack $frm.frame1.frame3.frame5.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame1.frame3.frame5.miry -text "$caption(fingerlakes,miroir_y)" -highlightthickness 0 \
               -variable ::fingerlakes::private(mirv)
            pack $frm.frame1.frame3.frame5.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame1.frame3.frame5 -anchor n -side left -fill x -padx 20

      pack $frm.frame1.frame3 -side top -fill x -expand 0

      #--- Frame du mode de fonctionnement de l'obturateur
      frame $frm.frame1.frame8 -borderwidth 0 -relief raised

         #--- Mode de fonctionnement de l'obturateur
         label $frm.frame1.frame8.lab3 -text "$caption(fingerlakes,fonc_obtu)"
         pack $frm.frame1.frame8.lab3 -anchor nw -side left -padx 10 -pady 5

         set list_combobox [ list $caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) \
            $caption(fingerlakes,obtu_synchro) ]
         ComboBox $frm.frame1.frame8.foncobtu \
            -width 11           \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -textvariable ::fingerlakes::private(foncobtu) \
            -values $list_combobox
         pack $frm.frame1.frame8.foncobtu -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.frame8 -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la FLI
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(fingerlakes,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(fingerlakes,site_web_ref)" \
         "$caption(fingerlakes,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::fingerlakes::configureCamera
#    Configure la camera FLI en fonction des donnees contenues dans les variables conf(fingerlakes,...)
#
proc ::fingerlakes::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create fingerlakes USB ]
   console::affiche_erreur "$caption(fingerlakes,port) ([ cam$camNo name ]) $caption(fingerlakes,2points) USB\n"
   console::affiche_saut "\n"
   set confCam($camItem,camNo) $camNo
   set foncobtu $conf(fingerlakes,foncobtu)
   switch -exact -- $foncobtu {
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
   if { $conf(fingerlakes,cool) == "1" } {
      cam$camNo cooler on
      cam$camNo cooler check $conf(fingerlakes,temp)
   } else {
      cam$camNo cooler off
   }
   #--- J'associe le buffer de la visu
   set bufNo [visu$confCam($camItem,visuNo) buf]
   cam$camNo buf $bufNo
   #--- Je configure l'oriention des miroirs par defaut
   cam$camNo mirrorh $conf(fingerlakes,mirh)
   cam$camNo mirrorv $conf(fingerlakes,mirv)
   #---
   ::confVisu::visuDynamix $confCam($camItem,visuNo) 65535 0
   #---
   if { [ info exists confCam(fingerlakes,aftertemp) ] == "0" } {
      ::fingerlakes::FLIDispTemp
   }
}

#
# ::fingerlakes::stop
#    Arrete la camera FLI
#
proc ::fingerlakes::stop { camItem } {
   global confCam

   #--- J'arrete la camera
   if { $confCam($camItem,camNo) != 0 } {
      cam::delete $confCam($camItem,camNo)
      set confCam($camItem,camNo) 0
   }
}

#
# ::fingerlakes::FLIDispTemp
#    Affiche la temperature du CCD
#
proc ::fingerlakes::FLIDispTemp { } {
   variable private
   global audace caption confCam

   catch {
      set frm $private(frm)
      set camItem $confCam(currentCamItem)
      if { [ info exists audace(base).confCam ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
         set temp_ccd [ format "%+5.2f" $temp_ccd ]
         $frm.frame1.frame3.frame4.frame7.temp_ccd configure \
            -text "$caption(fingerlakes,temperature_CCD) $temp_ccd $caption(fingerlakes,deg_c)"
         set confCam(fingerlakes,aftertemp) [ after 5000 ::fingerlakes::FLIDispTemp ]
      } else {
         catch { unset confCam(fingerlakes,aftertemp) }
      }
   }
}

#
# ::fingerlakes::getPluginProperty
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
proc ::fingerlakes::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 7x7 8x8 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList     {
         #--- O + F + S - A confirmer avec le materiel
         return [ list $::caption(fingerlakes,obtu_ouvert) $::caption(fingerlakes,obtu_ferme) $::caption(fingerlakes,obtu_synchro) ]
      }
   }
}

