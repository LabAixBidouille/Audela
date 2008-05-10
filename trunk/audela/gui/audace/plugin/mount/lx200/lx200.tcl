#
# Fichier : lx200.tcl
# Description : Configuration de la monture LX200
# Auteur : Robert DELMAS
# Mise a jour $Id: lx200.tcl,v 1.12 2008-05-10 12:01:10 michelpujol Exp $
#

namespace eval ::lx200 {
   package provide lx200 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] lx200.cap ]
}

#
# ::lx200::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::lx200::getPluginTitle { } {
   global caption

   return "$caption(lx200,monture)"
}

#
#  ::lx200::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::lx200::getPluginHelp { } {
   return "lx200.htm"
}

#
# ::lx200::getPluginType
#    Retourne le type du plugin
#
proc ::lx200::getPluginType { } {
   return "mount"
}

#
# ::lx200::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::lx200::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::lx200::getTelNo
#    Retourne le numero de la monture
#
proc ::lx200::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# ::lx200::isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::lx200::isReady { } {
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
# ::lx200::getSecondaryTelNo
#    Retourne le numero de la monture secondaire, sinon retourne "0"
#
proc ::lx200::getSecondaryTelNo { } {
   set result [ ::ouranos::getTelNo ]
   return $result
}

#
# ::lx200::initPlugin
#    Initialise les variables conf(lx200,...)
#
proc ::lx200::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Prise en compte des liaisons
   set list_connexion [::confLink::getLinkLabels { "serialport" "audinet" } ]

   #--- Initialise les variables de la monture LX200
   if { ! [ info exists conf(lx200,port) ] }            { set conf(lx200,port)            [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(lx200,ouranos) ] }         { set conf(lx200,ouranos)         "0" }
   if { ! [ info exists conf(lx200,modele) ] }          { set conf(lx200,modele)          "LX200" }
   if { ! [ info exists conf(lx200,format) ] }          { set conf(lx200,format)          "1" }
   if { ! [ info exists conf(lx200,ite-lente_tempo) ] } { set conf(lx200,ite-lente_tempo) "300" }
}

#
# ::lx200::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::lx200::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture LX200 dans le tableau private(...)
   set private(port)            $conf(lx200,port)
   set private(ouranos)         $conf(lx200,ouranos)
   set private(modele)          $conf(lx200,modele)
   set private(format)          [ lindex "$caption(lx200,format_court_long)" $conf(lx200,format) ]
   set private(ite-lente_tempo) $conf(lx200,ite-lente_tempo)
   set private(raquette)        $conf(raquette)
}

#
# ::lx200::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::lx200::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture LX200 dans le tableau conf(lx200,...)
   set conf(lx200,port)            $private(port)
   set conf(lx200,ouranos)         $private(ouranos)
   set conf(lx200,format)          [ lsearch "$caption(lx200,format_court_long)" "$private(format)" ]
   set conf(lx200,modele)          $private(modele)
   set conf(lx200,ite-lente_tempo) $private(ite-lente_tempo)
   set conf(raquette)              $private(raquette)
}

#
# ::lx200::fillConfigPage
#    Interface de configuration de la monture LX200
#
proc ::lx200::fillConfigPage { frm } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::lx200::confToWidget

   #--- Prise en compte des liaisons
   set list_connexion [::confLink::getLinkLabels { "serialport" "audinet" } ]

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill x

   frame $frm.frame4a -borderwidth 0 -relief raised
   pack $frm.frame4a -side top -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side bottom -fill x -pady 2

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame6 -side top -fill x

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame6 -side top -fill x

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame7 -side top -fill x

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame7 -side top -fill x

   #--- Definition du port
   label $frm.lab1 -text "$caption(lx200,port_liaison)"
   pack $frm.lab1 -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

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
   button $frm.configure -text "$caption(lx200,configurer)" -relief raised \
      -command {
         ::confLink::run ::lx200::private(port) { serialport audinet } \
            "- $caption(lx200,controle) - $caption(lx200,monture)"
      }
   pack $frm.configure -in $frm.frame8 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 9          \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton du fonctionnement coordonne LX200 (modele AudeCom) + Ouranos
   if { [glob -nocomplain -type f -join "$audace(rep_plugin)" mount ouranos pkgIndex.tcl ] == "" } {
      set private(ouranos) "0"
      checkbutton $frm.ouranos -text "$caption(lx200,ouranos)" -highlightthickness 0 \
         -variable ::lx200::private(ouranos) -state disabled
      pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
   } else {
      checkbutton $frm.ouranos -text "$caption(lx200,ouranos)" -highlightthickness 0 \
         -variable ::lx200::private(ouranos) -state normal
      pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
   }

   #--- Definition du LX200 ou du clone
   label $frm.lab3 -text "$caption(lx200,modele)"
   pack $frm.lab3 -in $frm.frame10 -anchor center -side left -padx 10 -pady 10

   set list_combobox [ list $caption(lx200,modele_lx200) $caption(lx200,modele_astro_physics) \
      $caption(lx200,modele_audecom) $caption(lx200,modele_skysensor) \
      $caption(lx200,modele_gemini) $caption(lx200,modele_ite-lente) \
      $caption(lx200,modele_mel_bartels) ]
   ComboBox $frm.modele \
      -width 17         \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(modele) \
      -modifycmd { ::lx200::confModele } \
      -editable 0       \
      -values $list_combobox
   pack $frm.modele -in $frm.frame10 -anchor center -side right -padx 10 -pady 10

   #--- Definition du format des donnees transmises au LX200
   label $frm.lab2 -text "$caption(lx200,format)"
   pack $frm.lab2 -in $frm.frame11 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(lx200,format_court_long)"
   ComboBox $frm.formatradec \
      -width 7          \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame11 -anchor center -side right -padx 10 -pady 10

   #--- Le bouton de commande maj heure et position du LX200
   button $frm.majpara -text "$caption(lx200,maj_lx200)" -relief raised -command {
      tel$::lx200::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$::lx200::private(telNo) home $audace(posobs,observateur,gps)
   }
   pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

   #--- Entree de la tempo Ite-lente
   label $frm.lab4 -text "$caption(lx200,ite-lente_tempo)"
   pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   entry $frm.tempo -textvariable ::lx200::private(ite-lente_tempo) -justify center -width 5
   pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
  checkbutton $frm.raquette -text "$caption(lx200,raquette_tel)" \
      -highlightthickness 0 -variable ::lx200::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Bouton park
   button $frm.park -text "$caption(lx200,park)" -relief raised -command "::telescope::park 1" -state disabled
   pack $frm.park -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Bouton unpark
   button $frm.unpark -text "$caption(lx200,unpark)" -relief raised -command "::telescope::park 0" -state disabled
   pack $frm.unpark -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Site web officiel du LX200
   label $frm.lab103 -text "$caption(lx200,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(lx200,site_web_ref)" \
      "$caption(lx200,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::lx200::confLX200

   #--- Gestion de la tempo pour Ite-lente
   ::lx200::confModele
}

#
# ::lx200::configureMonture
#    Configure la monture LX200 en fonction des donnees contenues dans les variables conf(lx200,...)
#
proc ::lx200::configureMonture { } {
   variable private
   global caption conf

   switch [::confLink::getLinkNamespace $conf(lx200,port)] {
      audinet {
         #--- Je cree la monture
         set telNo [ tel::create lxnet $conf(lx200,port) -name lxnet \
               -host $conf(audinet,host) \
               -ipsetting $conf(audinet,ipsetting) \
               -macaddress $conf(audinet,mac_address) \
               -autoflush $conf(audinet,autoflush) \
               -focusertype $conf(audinet,focuser_type) \
               -focuseraddr $conf(audinet,focuser_addr) \
               -focuserbit $conf(audinet,focuser_bit) \
            ]
         #--- J'affiche un message d'information dans la Console
         console::affiche_erreur "$caption(lx200,host_audinet) $caption(lx200,2points)\
            $conf(audinet,host)\n"
         console::affiche_saut "\n"
         if { $conf(lx200,format) == "0" } {
            tel$telNo longformat off
         } else {
            tel$telNo longformat on
         }
         #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
         set linkNo [ ::confLink::create $conf(lx200,port) "tel$telNo" "control" [ tel$telNo product ] ]
         #--- Je change de variable
         set private(telNo) $telNo
      }
      serialport {
         #--- Je cree la monture
         set telNo [ tel::create lx200 $conf(lx200,port) ]
         #--- J'affiche un message d'information dans la Console
         console::affiche_erreur "$caption(lx200,port_lx200) ($conf(lx200,modele))\
            $caption(lx200,2points) $conf(lx200,port)\n"
         console::affiche_saut "\n"
         if { $conf(lx200,format) == "0" } {
            tel$telNo longformat off
         } else {
            tel$telNo longformat on
         }
         if { $conf(lx200,modele) == "Ite-lente" } {
            tel$telNo tempo $conf(lx200,ite-lente_tempo)
         }
         #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
         set linkNo [ ::confLink::create $conf(lx200,port) "tel$telNo" "control" [ tel$telNo product ] ]
         #--- Je change de variable
         set private(telNo) $telNo
      }
   }
   #--- Gestion du bouton actif/inactif
   ::lx200::confLX200

   #--- Si connexion des codeurs Ouranos demandee en tant que monture secondaire
   if { $conf(lx200,ouranos) == "1" } {
      #--- Je copie les parametres Ouranos dans conf()
      ::ouranos::widgetToConf
      #--- Je configure la monture secondaire Ouranos
      set catchResult [ catch {
         ::ouranos::configureMonture
      } errorMessage ]
      if { $catchResult != "0" } {
         ::lx200::stop
         error $errorMessage
      }
   }
}

#
# ::lx200::stop
#    Arrete la monture LX200
#
proc ::lx200::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::lx200::confLX200Inactif

   #--- Je memorise le port
   set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$private(telNo)" "control"
   set private(telNo) "0"

   #--- Deconnexion des codeurs Ouranos si la monture secondaire existe
   if { $conf(lx200,ouranos) == "1" } {
      ::ouranos::stop
   }
}

#
# ::lx200::confLX200
# Permet d'activer ou de désactiver le bouton
#
proc ::lx200::confLX200 { } {
   variable private
   global audace caption conf

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::lx200::isReady ] == 1 } {
            if { [ ::confTel::getPluginProperty hasUpdateDate ] == "1" } {
               #--- Bouton Mise a jour de la date et du lieu
               $frm.majpara configure -state normal
            }
            #--- Cas des modeles qui ont la fonction "park"
            if { [ ::confTel::getPluginProperty hasPark ] == "1" } {
               #--- Bouton park
               $frm.park configure -state normal
            }

            #--- Cas des modeles qui ont la fonction "unpark"
            if { [ ::confTel::getPluginProperty hasUnpark ] == "1" } {
               #--- Bouton unpark
               $frm.unpark configure -state normal
            }
         } else {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
            #--- Bouton unpark
            $frm.unpark configure -state disabled
            #--- Bouton unpark
            $frm.unpark configure -state disabled
         }
      }
   }
}

#
# ::lx200::confLX200Inactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::lx200::confLX200Inactif { } {
   variable private

   set frm $private(frm)
   if { [winfo exists $frm ] } {
      #--- Bouton Mise a jour de la monture inactif
      $frm.majpara configure -state disabled
      #--- Bouton unpark
      $frm.park configure -state disabled
      #--- Bouton unpark
      $frm.unpark configure -state disabled
   }
}

#
# ::lx200::confModele
# Permet d'activer ou de désactiver les champs lies au modele
#
proc ::lx200::confModele { } {
   variable private
   global audace caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Cas du modele IteLente
         if { $private(modele) == "$caption(lx200,modele_ite-lente)" } {
            if { ! [ winfo exists $frm.lab4 ] } {
               #--- Label de la tempo Ite-lente
               label $frm.lab4 -text "$caption(lx200,ite-lente_tempo)"
               pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
            }
            if { ! [ winfo exists $frm.tempo ] } {
               #--- Entree de la tempo Ite-lente
               entry $frm.tempo -textvariable ::lx200::private(ite-lente_tempo) -justify center -width 5
               pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
            }
         } else {
            destroy $frm.lab4 ; destroy $frm.tempo
         }
         #--- Cas du modele AudeCom
         if { $private(modele) == "$caption(lx200,modele_audecom)" } {
            if { [glob -nocomplain -type f -join "$audace(rep_plugin)" mount ouranos pkgIndex.tcl ] == "" } {
               set private(ouranos) "0"
               $frm.ouranos configure -state disabled
               pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
            } else {
               $frm.ouranos configure -state normal
            }
         } else {
            set private(ouranos) "0"
            $frm.ouranos configure -state disabled
         }
      }
   }
}

#
# ::lx200::getPluginProperty
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
# hasPark                 Retourne la possibilite de parquer la monture
# hasUpdatedate           Retourne la possibilite de mettre a jour la date et le lieu
#
proc ::lx200::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              {
         if { $::conf(lx200,modele) == "$::caption(lx200,modele_audecom)" } {
            return 1
         } else {
            return 0
         }
      }
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
      hasCorrectionRefraction {
         if { $::conf(lx200,modele) == "$::caption(lx200,modele_audecom)" } {
            return 0
         } elseif { $::conf(lx200,modele) == "$::caption(lx200,modele_ite-lente)" } {
            return 0
         } else {
            return 1
         }
      }
      hasPark {
         if {  $::conf(lx200,modele) == $::caption(lx200,modele_lx200)
            || $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUnpark {
         if { $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUpdateDate {
         if {  $::conf(lx200,modele) == $::caption(lx200,modele_lx200)
            || $::conf(lx200,modele) == $::caption(lx200,modele_skysensor)
            || $::conf(lx200,modele) == $::caption(lx200,modele_gemini)
            || $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      backlash                { return 0 }
   }
}

#------------------------------------------------------------
# park
#    parque la monture
#
# Parametres :
#    state : 1= park , 0=un-park
# Return :
#    rien
#------------------------------------------------------------
proc ::lx200::park { state } {
   variable private

   if {  $::conf(lx200,modele) == $::caption(lx200,modele_lx200) } {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":hP#" none
      } elseif { $state == 0 } {
         #--- je ne fais rien car Meade n'a pas la fonction un-park
      }
   } elseif { $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":KA#" none
      } elseif { $state == 0 } {
         #--- j'envoie l'heure courante
         tel$::lx200::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
         #--- je de-parque la monture
         tel$private(telNo) command ":PO#" none
      }
   }
}
