#
# Fichier : etel.tcl
# Description : Configuration de la monture Etel
# Auteur : Alain KLOTZ
# Mise a jour $Id: etel.tcl,v 1.10 2008-12-06 17:08:41 robertdelmas Exp $
#

namespace eval ::etel {
   package provide etel 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] etel.cap ]
}

#
# ::etel::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::etel::getPluginTitle { } {
   global caption

   return "$caption(etel,monture)"
}

#
#  ::etel::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::etel::getPluginHelp { } {
   return "etel.htm"
}

#
# ::etel::getPluginType
#    Retourne le type du plugin
#
proc ::etel::getPluginType { } {
   return "mount"
}

#
# ::etel::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::etel::getPluginOS { } {
   return [ list Windows ]
}

#
# ::etel::getTelNo
#    Retourne le numero de la monture
#
proc ::etel::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# ::etel::isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::etel::isReady { } {
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
# ::etel::initPlugin
#    Initialise les variables conf(etel,...)
#
proc ::etel::initPlugin { } {
   variable private

   #--- Initialisation
   set private(telNo) "0"
}

#
# ::etel::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::etel::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Etel dans le tableau private(...)
   set private(raquette) $conf(raquette)
}

#
# ::etel::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::etel::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Etel dans le tableau conf(etel,...)
   set conf(raquette) $private(raquette)
}

#
# ::etel::fillConfigPage
#    Interface de configuration de la monture Etel
#
proc ::etel::fillConfigPage { frm } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::etel::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(etel,raquette_tel)" \
      -highlightthickness 0 -variable ::etel::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du Etel
   label $frm.lab103 -text "$caption(etel,titre_site_web)"
   pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame4 "$caption(etel,site_etel)" \
      "$caption(etel,site_etel)" ]
   pack $labelName -side top -fill x -pady 2
}

#
# ::etel::configureMonture
#    Configure la monture Etel en fonction des donnees contenues dans les variables conf(etel,...)
#
proc ::etel::configureMonture { } {
   variable private
   global caption

   #--- Je cree la monture
   set telNo [ tel::create etel PCI ]
   #--- J'affiche un message d'information dans la Console
   console::affiche_erreur "$caption(etel,port_etel)\
      $caption(etel,2points) PCI\n"
   console::affiche_saut "\n"
   #--- Je change de variable
   set private(telNo) $telNo
}

#
# ::etel::stop
#    Arrete la monture Etel
#
proc ::etel::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# ::etel::getPluginProperty
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
# hasModel                Retourne la possibilite d'avoir plusieurs modeles pour le meme product
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::etel::getPluginProperty { propertyName } {
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
      hasModel                { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

