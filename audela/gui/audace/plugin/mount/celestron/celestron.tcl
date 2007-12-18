#
# Fichier : celestron.tcl
# Description : Configuration de la monture Celestron
# Auteur : Robert DELMAS
# Mise a jour $Id: celestron.tcl,v 1.6 2007-12-18 22:16:12 robertdelmas Exp $
#

namespace eval ::celestron {
   package provide celestron 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] celestron.cap ]
}

#
# ::celestron::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::celestron::getPluginTitle { } {
   global caption

   return "$caption(celestron,monture)"
}

#
#  ::celestron::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::celestron::getPluginHelp { } {
   return "celestron.htm"
}

#
# ::celestron::getPluginType
#    Retourne le type du plugin
#
proc ::celestron::getPluginType { } {
   return "mount"
}

#
# ::celestron::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::celestron::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::celestron::initPlugin
#    Initialise les variables conf(celestron,...)
#
proc ::celestron::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Celestron
   if { ! [ info exists conf(celestron,port) ] }   { set conf(celestron,port)   [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(celestron,format) ] } { set conf(celestron,format) "1" }
}

#
# ::celestron::confToWidget
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
# ::celestron::widgetToConf
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
# ::celestron::fillConfigPage
#    Interface de configuration de la monture Celestron
#
proc ::celestron::fillConfigPage { frm } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

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
      -width 7          \
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
      -width 7          \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::celestron::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame8 -anchor center -side left -padx 30 -pady 10

   #--- Le bouton de commande maj heure et position du Celestron
   button $frm.majpara -text "$caption(celestron,maj_celestron)" -relief raised -command {
      tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$audace(telNo) home $audace(posobs,observateur,gps)
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
# ::celestron::configureTelescope
#    Configure la monture Celestron en fonction des donnees contenues dans les variables conf(celestron,...)
#
proc ::celestron::configureTelescope { } {
   global audace caption conf

   set audace(telNo) [ tel::create celestron $conf(celestron,port) ]
   console::affiche_erreur "$caption(celestron,port_celestron)\
      $caption(celestron,2points) $conf(celestron,port)\n"
   console::affiche_saut "\n"
   if { $conf(celestron,format) == "0" } {
      tel$audace(telNo) longformat off
   } else {
      tel$audace(telNo) longformat on
   }
   #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par le telescope)
   set linkNo [ ::confLink::create $conf(celestron,port) "tel$audace(telNo)" "control" [ tel$audace(telNo) product ] ]
   #--- Gestion du bouton actif/inactif
   ::celestron::confCelestron
}

#
# ::celestron::stop
#    Arrete la monture Celestron
#
proc ::celestron::stop { } {
   global audace

   #--- Gestion du bouton actif/inactif
   ::celestron::confCelestronInactif

   #--- Je memorise le port
   set telPort [ tel$audace(telNo) port ]
   #--- J'arrete la monture
   tel::delete $audace(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$audace(telNo)" "control"
   set audace(telNo) "0"
}

#
# ::celestron::confCelestron
# Permet d'activer ou de désactiver le bouton
#
proc ::celestron::confCelestron { } {
   variable private
   global audace

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::confTel::isReady ] == 1 } {
            #--- Bouton Mise a jour de la monture actif
            $frm.majpara configure -state normal -command {
               tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
               tel$audace(telNo) home $audace(posobs,observateur,gps)
            }
         } else {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
         }
      }
   }
}

#
# ::celestron::confCelestronInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::celestron::confCelestronInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::confTel::isReady ] == 1 } {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
         }
      }
   }
}

#
# ::celestron::getPluginProperty
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
proc ::celestron::getPluginProperty { propertyName } {
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

