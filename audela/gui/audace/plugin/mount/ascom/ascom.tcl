#
# Fichier : ascom.tcl
# Description : Configuration de la monture ASCOM
# Auteur : Robert DELMAS
# Mise a jour $Id: ascom.tcl,v 1.6 2007-12-18 22:15:07 robertdelmas Exp $
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
   return [ list Windows Linux Darwin ]
}

#
# ::ascom::initPlugin
#    Initialise les variables conf(ascom,...)
#
proc ::ascom::initPlugin { } {
   variable private
   global conf

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
# ::ascom::configureTelescope
#    Configure la monture ASCOM en fonction des donnees contenues dans les variables conf(ascom,...)
#
proc ::ascom::configureTelescope { } {
   global audace caption conf

   set audace(telNo) [ tel::create ascom "unknown" [ lindex $conf(ascom,driver) 1 ] ]
   console::affiche_erreur "$caption(ascom,driver) \
      $caption(ascom,2points) [ lindex $conf(ascom,driver) 1 ] \n"
   console::affiche_saut "\n"
}

#
# ::ascom::stop
#    Arrete la monture ASCOM
#
proc ::ascom::stop { } {
   global audace

   #--- Je memorise le port
   set telPort [ tel$audace(telNo) port ]
   #--- J'arrete la monture
   tel::delete $audace(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$audace(telNo)" "control"
   set audace(telNo) "0"
}

#
# ::ascom::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# multiMount :       Retourne la possibilite de connecter plusieurs montures differentes (1 : Oui, 0 : Non)
# name :             Retourne le modele de la monture
# product :          Retourne le nom du produit
#
proc ::ascom::getPluginProperty { propertyName } {
   global audace

   switch $propertyName {
      multiMount       { return 0 }
      name             {
         if { $audace(telNo) != "0" } {
            return [ tel$audace(telNo) name ]
         } else {
            return ""
         }
      }
      product          {
         if { $audace(telNo) != "0" } {
            return [ tel$audace(telNo) product ]
         } else {
            return ""
         }
      }
   }
}

