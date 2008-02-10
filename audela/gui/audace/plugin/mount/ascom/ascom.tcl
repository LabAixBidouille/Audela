#
# Fichier : ascom.tcl
# Description : Configuration de la monture ASCOM
# Auteur : Robert DELMAS
# Mise a jour $Id: ascom.tcl,v 1.11 2008-02-10 17:31:15 robertdelmas Exp $
#

namespace eval ::ascom {
   package provide ascom 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ascom.cap ]
}

#
# ::ascom::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::ascom::getPluginTitle { } {
   global caption

   return "$caption(ascom,monture)"
}

#
#  ::ascom::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::ascom::getPluginHelp { } {
   return "ascom.htm"
}

#
# ::ascom::getPluginType
#    Retourne le type du plugin
#
proc ::ascom::getPluginType { } {
   return "mount"
}

#
# ::ascom::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::ascom::getPluginOS { } {
   return [ list Windows ]
}

#
# ::ascom::getTelNo
#    Retourne le numero de la monture
#
proc ::ascom::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# ::ascom::isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::ascom::isReady { } {
   variable private

   if { $private(telNo) == "0" } {
      #--- Monture KO
      return 0
   } else {
      #--- Monture OK
      return 1
   }
}

#
# ::ascom::initPlugin
#    Initialise les variables conf(ascom,...)
#
proc ::ascom::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Plugins ASCOM installes sur le PC
   set private(ascom_drivers) ""
   if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
      set erreur [ catch { ::registry keys "HKEY_LOCAL_MACHINE\\SOFTWARE\\ASCOM\\Telescope Drivers" } msg ]
      if { $erreur == "0" } {
         foreach key [ ::registry keys "HKEY_LOCAL_MACHINE\\SOFTWARE\\ASCOM\\Telescope Drivers" ] {
            if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\SOFTWARE\\ASCOM\\Telescope Drivers\\$key" "" } r ] == 0 } {
               lappend private(ascom_drivers) [list $r $key]
            }
         }
      } else {
         set erreur [ catch { ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers" } msg ]
         if { $erreur == "0" } {
            foreach key [ ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers" ] {
               if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers\\$key" "" } r ] == 0 } {
                  lappend private(ascom_drivers) [list $r $key]
               }
            }
         }
      }
   }

   #--- Initialise les variables de la monture ASCOM
   if { ! [ info exists conf(ascom,driver) ] } { set conf(ascom,driver) [ lindex $private(ascom_drivers) 0 ] }
}

#
# ::ascom::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ascom::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture ASCOM dans le tableau private(...)
   set private(driver)   $conf(ascom,driver)
   set private(raquette) $conf(raquette)
}

#
# ::ascom::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ascom::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture ASCOM dans le tableau conf(ascom,...)
   set conf(ascom,driver) $private(driver)
   set conf(raquette)     $private(raquette)
}

#
# ::ascom::fillConfigPage
#    Interface de configuration de la monture ASCOM
#
proc ::ascom::fillConfigPage { frm } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::ascom::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 0

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side bottom -fill x -pady 2

   #--- Definition du plugin
   label $frm.lab1 -text "$caption(ascom,driver)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

   ComboBox $frm.driver \
      -width 50         \
      -height [ llength $private(ascom_drivers) ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::ascom::private(driver) \
      -editable 0       \
      -values $private(ascom_drivers)
   pack $frm.driver -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(ascom,raquette_tel)" \
      -highlightthickness 0 -variable ::ascom::private(raquette)
   pack $frm.raquette -in $frm.frame2 -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame2 -side left -padx 0 -pady 10

   #--- Site web officiel des plugins ASCOM
   label $frm.lab103 -text "$caption(ascom,titre_site_web)"
   pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame3 "$caption(ascom,site_web_ref)" \
      "$caption(ascom,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2
}

#
# ::ascom::configureMonture
#    Configure la monture ASCOM en fonction des donnees contenues dans les variables conf(ascom,...)
#
proc ::ascom::configureMonture { } {
   variable private
   global caption conf

   #--- Je cree la monture
   set telNo [ tel::create ascom "unknown" [ lindex $conf(ascom,driver) 1 ] ]
   #--- J'affiche un message d'information dans la Console
   console::affiche_erreur "$caption(ascom,driver) \
      $caption(ascom,2points) [ lindex $conf(ascom,driver) 1 ] \n"
   console::affiche_saut "\n"
   #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
  ### set linkNo [ ::confLink::create $conf(ascom,port) "tel$telNo" "control" [ tel$telNo product ] ]
   #--- Je change de variable
   set private(telNo) $telNo
}

#
# ::ascom::stop
#    Arrete la monture ASCOM
#
proc ::ascom::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Je memorise le port
  ### set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
  ### ::confLink::delete $telPort "tel$private(telNo)" "control"
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# ::ascom::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# multiMount              Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
# name                    Retourne le modele de la monture
# product                 Retourne le nom du produit
# hasCoordinates          Retourne la possibilite d'afficher les coordonnees
# hasGoto                 Retourne la possibilite de faire un Goto
# hasMatch                Retourne la possibilite de faire un Match
# hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
# hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
# hasCorrectionRefraction Retourne la possibilite de calculer les corrections de refraction
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::ascom::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              { return 0 }
      name                    {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) name ]
         } else {
            return ""
         }
      }
      product                 {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) product ]
         } else {
            return ""
         }
      }
      hasCoordinates          { return 1 }
      hasGoto                 { return 1 }
      hasMatch                { return 1 }
      hasManualMotion         { return 1 }
      hasControlSuivi         { return 0 }
      hasCorrectionRefraction { return 0 }
      backlash                { return 0 }
   }
}

