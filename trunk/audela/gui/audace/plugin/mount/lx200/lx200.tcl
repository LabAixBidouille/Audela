#
# Fichier : lx200.tcl
# Description : Configuration de la monture LX200
# Auteur : Robert DELMAS
# Mise a jour $Id: lx200.tcl,v 1.6 2007-12-18 22:17:22 robertdelmas Exp $
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
# ::lx200::initPlugin
#    Initialise les variables conf(lx200,...)
#
proc ::lx200::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [::confLink::getLinkLabels { "serialport" "audinet" } ]

   #--- Initialise les variables de la monture LX200
   if { ! [ info exists conf(lx200,port) ] }            { set conf(lx200,port)            [ lindex $list_connexion 0 ] }
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
   pack $frm.frame8 -in $frm.frame7 -side top -fill x

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame7 -side top -fill x

   #--- Definition du port
   label $frm.lab1 -text "$caption(lx200,port_liaison)"
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
   button $frm.configure -text "$caption(lx200,configurer)" -relief raised \
      -command {
         ::confLink::run ::lx200::private(port) { serialport audinet } \
            "- $caption(lx200,controle) - $caption(lx200,monture)"
      }
   pack $frm.configure -in $frm.frame6 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 9          \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Definition du LX200 ou du clone
   label $frm.lab3 -text "$caption(lx200,modele)"
   pack $frm.lab3 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

   set list_combobox [ list $caption(lx200,modele_lx200) $caption(lx200,modele_audecom) \
      $caption(lx200,modele_skysensor) $caption(lx200,modele_gemini) $caption(lx200,modele_ite-lente) \
      $caption(lx200,modele_mel_bartels) ]
   ComboBox $frm.modele \
      -width 17         \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(modele) \
      -modifycmd { ::lx200::confIteLente } \
      -editable 0       \
      -values $list_combobox
   pack $frm.modele -in $frm.frame8 -anchor center -side right -padx 10 -pady 10

   #--- Definition du format des donnees transmises au LX200
   label $frm.lab2 -text "$caption(lx200,format)"
   pack $frm.lab2 -in $frm.frame9 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(lx200,format_court_long)"
   ComboBox $frm.formatradec \
      -width 7          \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame9 -anchor center -side right -padx 10 -pady 10

   #--- Le bouton de commande maj heure et position du LX200
   button $frm.majpara -text "$caption(lx200,maj_lx200)" -relief raised -command {
      tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$audace(telNo) home $audace(posobs,observateur,gps)
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

   #--- Site web officiel du LX200
   label $frm.lab103 -text "$caption(lx200,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(lx200,site_web_ref)" \
      "$caption(lx200,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::lx200::confLX200

   #--- Gestion de la tempo pour Ite-lente
   ::lx200::confIteLente
}

#
# ::lx200::configureTelescope
#    Configure la monture LX200 en fonction des donnees contenues dans les variables conf(lx200,...)
#
proc ::lx200::configureTelescope { } {
   global audace caption conf

   switch [::confLink::getLinkNamespace $conf(lx200,port)] {
      audinet {
         set audace(telNo) [ tel::create lxnet $conf(lx200,port) -name lxnet \
               -host $conf(audinet,host) \
               -ipsetting $conf(audinet,ipsetting) \
               -macaddress $conf(audinet,mac_address) \
               -autoflush $conf(audinet,autoflush) \
               -focusertype $conf(audinet,focuser_type) \
               -focuseraddr $conf(audinet,focuser_addr) \
               -focuserbit $conf(audinet,focuser_bit) \
            ]
         console::affiche_erreur "$caption(lx200,host_audinet) $caption(lx200,2points)\
            $conf(audinet,host)\n"
         console::affiche_saut "\n"
         set audace(telNo) $msg
         if { $conf(lx200,format) == "0" } {
            tel$audace(telNo) longformat off
         } else {
            tel$audace(telNo) longformat on
         }
         #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par le telescope)
         set linkNo [ ::confLink::create $conf(lx200,port) "tel$audace(telNo)" "control" [ tel$audace(telNo) product ] ]
      }
      serialport {
         set audace(telNo) [ tel::create lx200 $conf(lx200,port) ]
         console::affiche_erreur "$caption(lx200,port_lx200) ($conf(lx200,modele))\
            $caption(lx200,2points) $conf(lx200,port)\n"
         console::affiche_saut "\n"
         if { $conf(lx200,format) == "0" } {
            tel$audace(telNo) longformat off
         } else {
            tel$audace(telNo) longformat on
         }
         if { $conf(lx200,modele) == "Ite-lente" } {
            tel$audace(telNo) tempo $conf(lx200,ite-lente_tempo)
         }
         #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par le telescope)
         set linkNo [ ::confLink::create $conf(lx200,port) "tel$audace(telNo)" "control" [ tel$audace(telNo) product ] ]
      }
   }
   #--- Gestion du bouton actif/inactif
   ::lx200::confLX200
}

#
# ::lx200::stop
#    Arrete la monture LX200
#
proc ::lx200::stop { } {
   global audace

   #--- Gestion du bouton actif/inactif
   ::lx200::confLX200Inactif

   #--- Je memorise le port
   set telPort [ tel$audace(telNo) port ]
   #--- J'arrete la monture
   tel::delete $audace(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$audace(telNo)" "control"
   set audace(telNo) "0"
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
         if { [ ::confTel::isReady ] == 1 } {
            if { $conf(lx200,modele) == "$caption(lx200,modele_lx200)" } {
               #--- Bouton Mise a jour de la monture actif
               $frm.majpara configure -state normal -command {
                  tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                  tel$audace(telNo) home $audace(posobs,observateur,gps)
               }
            } elseif { $conf(lx200,modele) == "$caption(lx200,modele_skysensor)" } {
               #--- Bouton Mise a jour de la monture actif
               $frm.majpara configure -state normal -command {
                  tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                  tel$audace(telNo) home $audace(posobs,observateur,gps)
               }
            } elseif { $conf(lx200,modele) == "$caption(lx200,modele_gemini)" } {
               #--- Bouton Mise a jour de la monture actif
               $frm.majpara configure -state normal -command {
                  tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                  tel$audace(telNo) home $audace(posobs,observateur,gps)
               }
            } else {
               #--- Bouton Mise a jour de la monture inactif
               $frm.majpara configure -state disabled
            }
         } else {
            #--- Bouton Mise a jour de la monture inactif
            $frm.majpara configure -state disabled
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
# ::lx200::confIteLente
# Permet d'activer ou de désactiver la tempo de l'interface Ite-lente
#
proc ::lx200::confIteLente { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
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
# multiMount :       Retourne la possibilite de connecter plusieurs montures differentes (1 : Oui, 0 : Non)
# name :             Retourne le modele de la monture
# product :          Retourne le nom du produit
#
proc ::lx200::getPluginProperty { propertyName } {
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

