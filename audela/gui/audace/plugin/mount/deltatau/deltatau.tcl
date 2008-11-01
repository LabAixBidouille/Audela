#
# Fichier : deltatau.tcl
# Description : Configuration de la monture Delta Tau
# Auteur : Alain KLOTZ
# Mise a jour $Id: deltatau.tcl,v 1.7 2008-11-01 17:44:06 robertdelmas Exp $
#

namespace eval ::deltatau {
   package provide deltatau 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] deltatau.cap ]
}

#
# ::deltatau::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::deltatau::getPluginTitle { } {
   global caption

   return "$caption(deltatau,monture)"
}

#
#  ::deltatau::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::deltatau::getPluginHelp { } {
   return "deltatau.htm"
}

#
# ::deltatau::getPluginType
#    Retourne le type du plugin
#
proc ::deltatau::getPluginType { } {
   return "mount"
}

#
# ::deltatau::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::deltatau::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::deltatau::getTelNo
#    Retourne le numero de la monture
#
proc ::deltatau::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# ::deltatau::isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::deltatau::isReady { } {
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
# ::deltatau::initPlugin
#    Initialise les variables conf(deltatau,...)
#
proc ::deltatau::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Delta Tau
   if { ! [ info exists conf(deltatau,port) ] }   { set conf(deltatau,port)   [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(deltatau,format) ] } { set conf(deltatau,format) "1" }
}

#
# ::deltatau::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::deltatau::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture Delta Tau dans le tableau private(...)
   set private(port)     $conf(deltatau,port)
   set private(format)   [ lindex "$caption(deltatau,format_court_long)" $conf(deltatau,format) ]
   set private(raquette) $conf(raquette)
}

#
# ::deltatau::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::deltatau::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture Delta Tau dans le tableau conf(deltatau,...)
   set conf(deltatau,port)   $private(port)
   set conf(deltatau,format) [ lsearch "$caption(deltatau,format_court_long)" "$private(format)" ]
   set conf(raquette)        $private(raquette)
}

#
# ::deltatau::fillConfigPage
#    Interface de configuration de la monture Delta Tau
#
proc ::deltatau::fillConfigPage { frm } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::deltatau::confToWidget

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
   label $frm.lab1 -text "$caption(deltatau,port)"
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
   button $frm.configure -text "$caption(deltatau,configurer)" -relief raised \
      -command {
         ::confLink::run ::deltatau::private(port) { serialport } \
            "- $caption(deltatau,controle) - $caption(deltatau,monture)"
      }
   pack $frm.configure -in $frm.frame6 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::deltatau::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Definition du format des donnees transmises au Delta Tau
   label $frm.lab2 -text "$caption(deltatau,format)"
   pack $frm.lab2 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(deltatau,format_court_long)"
   ComboBox $frm.formatradec \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::deltatau::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame8 -anchor center -side left -padx 30 -pady 10

   #--- Le bouton de commande maj heure et position du Delta Tau
   button $frm.majpara -text "$caption(deltatau,maj_deltatau)" -relief raised -command {
      tel$::deltatau::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$::deltatau::private(telNo) home $audace(posobs,observateur,gps)
   }
   pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(deltatau,raquette_tel)" \
      -highlightthickness 0 -variable ::deltatau::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du Delta Tau
   label $frm.lab103 -text "$caption(deltatau,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(deltatau,site_deltatau)" \
      "$caption(deltatau,site_deltatau)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::deltatau::confDeltaTau
}

#
# ::deltatau::configureMonture
#    Configure la monture Delta Tau en fonction des donnees contenues dans les variables conf(deltatau,...)
#
proc ::deltatau::configureMonture { } {
   variable private
   global caption conf

   #--- Je cree la monture
   set telNo [ tel::create deltatau $conf(deltatau,port) ]
   #--- J'affiche un message d'information dans la Console
   console::affiche_erreur "$caption(deltatau,port_deltatau)\
      $caption(deltatau,2points) $conf(deltatau,port)\n"
   console::affiche_saut "\n"
   if { $conf(deltatau,format) == "0" } {
      tel$telNo longformat off
   } else {
      tel$telNo longformat on
   }
   #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
   set linkNo [ ::confLink::create $conf(deltatau,port) "tel$telNo" "control" [ tel$telNo product ] ]
   #--- Je change de variable
   set private(telNo) $telNo
   #--- Gestion du bouton actif/inactif
   ::deltatau::confDeltaTau
}

#
# ::deltatau::stop
#    Arrete la monture Delta Tau
#
proc ::deltatau::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::deltatau::confDeltaTauInactif

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
# ::deltatau::confDeltaTau
# Permet d'activer ou de désactiver le bouton
#
proc ::deltatau::confDeltaTau { } {
   variable private
   global audace

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::deltatau::isReady ] == 1 } {
            #--- Bouton Mise a jour de la monture actif
            $frm.majpara configure -state normal -command {
               tel$::deltatau::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
               tel$::deltatau::private(telNo) home $audace(posobs,observateur,gps)
            }
         } else {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
         }
      }
   }
}

#
# ::deltatau::confDeltaTauInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::deltatau::confDeltaTauInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::deltatau::isReady ] == 1 } {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
         }
      }
   }
}

#
# ::deltatau::getPluginProperty
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
proc ::deltatau::getPluginProperty { propertyName } {
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

