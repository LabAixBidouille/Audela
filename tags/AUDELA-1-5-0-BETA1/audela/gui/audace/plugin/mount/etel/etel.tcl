#
# Fichier : etel.tcl
# Description : Configuration de la monture Etel
# Auteur : Alain KLOTZ
# Mise a jour $Id: etel.tcl,v 1.7 2008-02-10 17:32:22 robertdelmas Exp $
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
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Etel
   if { ! [ info exists conf(etel,port) ] }   { set conf(etel,port)   [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(etel,format) ] } { set conf(etel,format) "1" }
}

#
# ::etel::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::etel::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture Etel dans le tableau private(...)
   set private(port)     $conf(etel,port)
   set private(format)   [ lindex "$caption(etel,format_court_long)" $conf(etel,format) ]
   set private(raquette) $conf(raquette)
}

#
# ::etel::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::etel::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture Etel dans le tableau conf(etel,...)
   set conf(etel,port)   $private(port)
   set conf(etel,format) [ lsearch "$caption(etel,format_court_long)" "$private(format)" ]
   set conf(raquette)    $private(raquette)
}

#
# ::etel::fillConfigPage
#    Interface de configuration de la monture Etel
#
proc ::etel::fillConfigPage { frm } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::etel::confToWidget

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
   label $frm.lab1 -text "$caption(etel,port)"
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
   button $frm.configure -text "$caption(etel,configurer)" -relief raised \
      -command {
         ::confLink::run ::etel::private(port) { serialport } \
            "- $caption(etel,controle) - $caption(etel,monture)"
      }
   pack $frm.configure -in $frm.frame6 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 7          \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::etel::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Definition du format des donnees transmises au Etel
   label $frm.lab2 -text "$caption(etel,format)"
   pack $frm.lab2 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(etel,format_court_long)"
   ComboBox $frm.formatradec \
      -width 7          \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::etel::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame8 -anchor center -side left -padx 30 -pady 10

   #--- Le bouton de commande maj heure et position du Etel
   button $frm.majpara -text "$caption(etel,maj_etel)" -relief raised -command {
      tel$::etel::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$::etel::private(telNo) home $audace(posobs,observateur,gps)
   }
   pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(etel,raquette_tel)" \
      -highlightthickness 0 -variable ::etel::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du Etel
   label $frm.lab103 -text "$caption(etel,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(etel,site_etel)" \
      "$caption(etel,site_etel)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::etel::confEtel
}

#
# ::etel::configureMonture
#    Configure la monture Etel en fonction des donnees contenues dans les variables conf(etel,...)
#
proc ::etel::configureMonture { } {
   variable private
   global caption conf

   #--- Je cree la monture
   set telNo [ tel::create etel $conf(etel,port) ]
   #--- J'affiche un message d'information dans la Console
   console::affiche_erreur "$caption(etel,port_etel)\
      $caption(etel,2points) $conf(etel,port)\n"
   console::affiche_saut "\n"
   if { $conf(etel,format) == "0" } {
      tel$telNo longformat off
   } else {
      tel$telNo longformat on
   }
   #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
   set linkNo [ ::confLink::create $conf(etel,port) "tel$telNo" "control" [ tel$telNo product ] ]
   #--- Je change de variable
   set private(telNo) $telNo
   #--- Gestion du bouton actif/inactif
   ::etel::confEtel
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

   #--- Gestion du bouton actif/inactif
   ::etel::confEtelInactif

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
# ::etel::confEtel
# Permet d'activer ou de désactiver le bouton
#
proc ::etel::confEtel { } {
   variable private
   global audace

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::etel::isReady ] == 1 } {
            #--- Bouton Mise a jour de la monture actif
            $frm.majpara configure -state normal -command {
               tel$::etel::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
               tel$::etel::private(telNo) home $audace(posobs,observateur,gps)
            }
         } else {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
         }
      }
   }
}

#
# ::etel::confEtelInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::etel::confEtelInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::etel::isReady ] == 1 } {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
         }
      }
   }
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
      backlash                { return 0 }
   }
}

