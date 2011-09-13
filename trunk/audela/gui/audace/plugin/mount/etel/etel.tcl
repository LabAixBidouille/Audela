#
# Fichier : etel.tcl
# Description : Configuration de la monture Etel
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#

namespace eval ::etel {
   package provide etel 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] etel.cap ]
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::etel::getPluginTitle { } {
   global caption

   return "$caption(etel,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::etel::getPluginHelp { } {
   return "etel.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::etel::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::etel::getPluginOS { } {
   return [ list Windows ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::etel::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
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
# initPlugin
#    Initialise les variables conf(etel,...)
#
proc ::etel::initPlugin { } {
   variable private

   #--- Initialisation
   set private(telNo) "0"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::etel::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Etel dans le tableau private(...)
   set private(raquette) $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::etel::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Etel dans le tableau conf(etel,...)
   set conf(raquette) $private(raquette)
}

#
# fillConfigPage
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
# configureMonture
#    Configure la monture Etel en fonction des donnees contenues dans les variables conf(etel,...)
#
proc ::etel::configureMonture { } {
   variable private
   global caption

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create etel PCI ]
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(etel,port_etel) $caption(etel,2points) PCI\n"
      ::console::affiche_saut "\n"
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::etel::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
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
# getPluginProperty
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
      hasModel                { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

