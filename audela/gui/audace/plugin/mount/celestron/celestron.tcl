#
# Fichier : celestron.tcl
# Description : Configuration de la monture Celestron
# Auteur : Robert DELMAS
# Mise à jour $Id: celestron.tcl,v 1.18 2010-10-30 13:20:23 robertdelmas Exp $
#

namespace eval ::celestron {
   package provide celestron 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] celestron.cap ]
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::celestron::getPluginTitle { } {
   global caption

   return "$caption(celestron,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::celestron::getPluginHelp { } {
   return "celestron.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::celestron::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::celestron::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::celestron::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::celestron::isReady { } {
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
#    Initialise les variables conf(celestron,...)
#
proc ::celestron::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture Celestron
   if { ! [ info exists conf(celestron,port) ] }   { set conf(celestron,port)   "" }
   if { ! [ info exists conf(celestron,format) ] } { set conf(celestron,format) "1" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::celestron::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture Celestron dans le tableau private(...)
   set private(port)     $conf(celestron,port)
   set private(format)   [ lindex "$caption(celestron,format_court_long)" $conf(celestron,format) ]
   set private(raquette) $conf(raquette)

}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::celestron::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture Celestron dans le tableau conf(celestron,...)
   set conf(celestron,port)   $private(port)
   set conf(celestron,format) [ lsearch "$caption(celestron,format_court_long)" "$private(format)" ]
   set conf(raquette)         $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture Celestron
#
proc ::celestron::fillConfigPage { frm } {
   variable private
   global audace caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   if { $conf(celestron,port) == "" } {
      set list_connexion       [ ::confLink::getLinkLabels { "serialport" } ]
      set conf(celestron,port) [ lindex $list_connexion 0 ]
   }

   #--- confToWidget
   ::celestron::confToWidget

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side bottom -fill x -pady 2

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame7 -side top -fill x

   #--- Definition du port
   label $frm.lab1 -text "$caption(celestron,port)"
   pack $frm.lab1 -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $private(port) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports et liaisons
   button $frm.configure -text "$caption(celestron,configurer)" -relief raised \
      -command {
         ::confLink::run ::celestron::private(port) { serialport } \
            "- $caption(celestron,controle) - $caption(celestron,monture)"
      }
   pack $frm.configure -in $frm.frame6 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::celestron::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Definition du format des donnees transmises au Celestron
   label $frm.lab2 -text "$caption(celestron,format)"
   pack $frm.lab2 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(celestron,format_court_long)"
   ComboBox $frm.formatradec \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::celestron::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame8 -anchor center -side left -padx 30 -pady 10

   #--- Le bouton de commande maj heure et position du Celestron
   button $frm.majpara -text "$caption(celestron,maj_celestron)" -relief raised -command {
      tel$::celestron::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$::celestron::private(telNo) home $audace(posobs,observateur,gps)
   }
   pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(celestron,raquette_tel)" \
      -highlightthickness 0 -variable ::celestron::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du Celestron
   label $frm.lab103 -text "$caption(celestron,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(celestron,site_celestron)" \
      "$caption(celestron,site_celestron)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::celestron::confCelestron
}

#
# configureMonture
#    Configure la monture Celestron en fonction des donnees contenues dans les variables conf(celestron,...)
#
proc ::celestron::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create celestron $conf(celestron,port) ]
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(celestron,port_celestron)\
         $caption(celestron,2points) $conf(celestron,port)\n"
      ::console::affiche_saut "\n"
      if { $conf(celestron,format) == "0" } {
         tel$telNo longformat off
      } else {
         tel$telNo longformat on
      }
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(celestron,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Gestion du bouton actif/inactif
      ::celestron::confCelestron
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::celestron::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture Celestron
#
proc ::celestron::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::celestron::confCelestronInactif

   #--- Je memorise le port
   set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$private(telNo)" "control"
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# confCelestron
# Permet d'activer ou de desactiver le bouton
#
proc ::celestron::confCelestron { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::celestron::isReady ] == 1 } {
            if { [ ::confTel::getPluginProperty hasUpdateDate ] == "1" } {
               #--- Bouton Mise a jour de la date et du lieu actif
               $frm.majpara configure -state normal
            }
         } else {
            #--- Bouton Mise a jour de la date et du lieu inactif
            $frm.majpara configure -state disabled
         }
      }
   }
}

#
# confCelestronInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::celestron::confCelestronInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::celestron::isReady ] == 1 } {
            #--- Bouton Mise a jour de la date et du lieu inactif
            $frm.majpara configure -state disabled
         }
      }
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
proc ::celestron::getPluginProperty { propertyName } {
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
      hasUpdateDate           { return 1 }
      backlash                { return 0 }
   }
}

