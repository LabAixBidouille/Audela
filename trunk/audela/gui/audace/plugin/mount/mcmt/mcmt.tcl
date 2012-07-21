#
# Fichier : mcmt.tcl
# Description : Configuration de la monture mcmt
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#

namespace eval ::mcmt {
   package provide mcmt 1.1

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] mcmt.cap ]
}

#
# install
#    installe le plugin
#
proc ::mcmt::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libmcmt.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] "mcmt" "libmcmt.dll"]
      ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      ::audace::appendUpdateMessage "$::caption(mcmt,install_1) v[package version mcmt]. $::caption(mcmt,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::mcmt::getPluginTitle { } {
   global caption

   return "$caption(mcmt,monture)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::mcmt::getPluginHelp { } {
   return "mcmt.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::mcmt::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::mcmt::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::mcmt::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::mcmt::isReady { } {
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
# getSecondaryTelNo
#    Retourne le numero de la monture secondaire, sinon retourne "0"
#
proc ::mcmt::getSecondaryTelNo { } {
   set result [ ::ouranos::getTelNo ]
   return $result
}

#
# initPlugin
#    Initialise les variables conf(mcmt,...)
#
proc ::mcmt::initPlugin { } {
   variable private
   global conf

   #--- Initialisation de variables
   set private(telNo)         "0"
   set private(tracesConsole) "0"

   #--- Initialise les variables de la monture mcmt
   if { ! [ info exists conf(mcmt,port) ] }              { set conf(mcmt,port)              "" }
   if { ! [ info exists conf(mcmt,ouranos) ] }           { set conf(mcmt,ouranos)           "0" }
   if { ! [ info exists conf(mcmt,modele) ] }            { set conf(mcmt,modele)            "mcmt" }
   if { ! [ info exists conf(mcmt,format) ] }            { set conf(mcmt,format)            "1" }
   if { ! [ info exists conf(mcmt,ite-lente_tempo) ] }   { set conf(mcmt,ite-lente_tempo)   "10" }
   if { ! [ info exists conf(mcmt,alphaGuidingSpeed) ] } { set conf(mcmt,alphaGuidingSpeed) "3.0" }
   if { ! [ info exists conf(mcmt,deltaGuidingSpeed) ] } { set conf(mcmt,deltaGuidingSpeed) "3.0" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::mcmt::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture mcmt dans le tableau private(...)
   set private(port)              $conf(mcmt,port)
   set private(ouranos)           $conf(mcmt,ouranos)
   set private(modele)            $conf(mcmt,modele)
   set private(format)            [ lindex "$caption(mcmt,format_court_long)" $conf(mcmt,format) ]
   set private(ite-lente_tempo)   $conf(mcmt,ite-lente_tempo)
   set private(raquette)          $conf(raquette)
   set private(alphaGuidingSpeed) $conf(mcmt,alphaGuidingSpeed)
   set private(deltaGuidingSpeed) $conf(mcmt,deltaGuidingSpeed)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::mcmt::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture mcmt dans le tableau conf(mcmt,...)
   set conf(mcmt,port)              $private(port)
   set conf(mcmt,ouranos)           $private(ouranos)
   set conf(mcmt,format)            [ lsearch "$caption(mcmt,format_court_long)" "$private(format)" ]
   set conf(mcmt,modele)            $private(modele)
   set conf(mcmt,ite-lente_tempo)   $private(ite-lente_tempo)
   set conf(raquette)                $private(raquette)
   set conf(mcmt,alphaGuidingSpeed) $private(alphaGuidingSpeed)
   set conf(mcmt,deltaGuidingSpeed) $private(deltaGuidingSpeed)
}

#
# fillConfigPage
#    Interface de configuration de la monture mcmt
#
proc ::mcmt::fillConfigPage { frm } {
   variable private
   global audace caption conf

   #--- Initialise les variables locales
   set private(frm)          $frm
   set private(ite-lente_A0) "0"
   set private(ite-lente_A1) "0"

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" "audinet" } ]
   if { $conf(mcmt,port) == "" } {
      set conf(mcmt,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(mcmt,port) ] == -1 } {
      lappend list_connexion $conf(mcmt,port)
   }

   #--- confToWidget
   ::mcmt::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame2a -borderwidth 0 -relief raised
   pack $frm.frame2a -side top -fill x

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
   label $frm.lab1 -text "$caption(mcmt,port_liaison)"
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
   button $frm.configure -text "$caption(mcmt,configurer)" -relief raised \
      -command {
         ::confLink::run ::mcmt::private(port) { serialport audinet } \
            "- $caption(mcmt,controle) - $caption(mcmt,monture)"
      }
   pack $frm.configure -in $frm.frame8 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::mcmt::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton du fonctionnement coordonne mcmt (modele AudeCom) + Ouranos
   if { [glob -nocomplain -type f -join "$audace(rep_plugin)" mount ouranos pkgIndex.tcl ] == "" } {
      set private(ouranos) "0"
      checkbutton $frm.ouranos -text "$caption(mcmt,ouranos)" -highlightthickness 0 \
         -variable ::mcmt::private(ouranos) -state disabled
      pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
   } else {
      checkbutton $frm.ouranos -text "$caption(mcmt,ouranos)" -highlightthickness 0 \
         -variable ::mcmt::private(ouranos) -state normal
      pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
   }

   #--- Definition du mcmt ou du clone
   label $frm.lab3 -text "$caption(mcmt,modele)"
   pack $frm.lab3 -in $frm.frame10 -anchor center -side left -padx 10 -pady 10

   set list_combobox [ list $caption(mcmt,modele_mcmt) $caption(mcmt,modele_astro_physics) \
      $caption(mcmt,modele_audecom) $caption(mcmt,modele_skysensor) \
      $caption(mcmt,modele_gemini) $caption(mcmt,modele_ite-lente) \
      $caption(mcmt,modele_mel_bartels) $caption(mcmt,modele_fs2) ]
   ComboBox $frm.modele \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::mcmt::private(modele) \
      -modifycmd { ::mcmt::confModele } \
      -editable 0       \
      -values $list_combobox
   pack $frm.modele -in $frm.frame10 -anchor center -side right -padx 10 -pady 10

   #--- Definition du format des donnees transmises au mcmt
   label $frm.lab2 -text "$caption(mcmt,format)"
   pack $frm.lab2 -in $frm.frame11 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(mcmt,format_court_long)"
   ComboBox $frm.formatradec \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::mcmt::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame11 -anchor center -side right -padx 10 -pady 10

   #--- Le bouton de commande maj heure et position du mcmt
   button $frm.majpara -text "$caption(mcmt,maj_mcmt)" -relief raised -command {
      tel$::mcmt::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$::mcmt::private(telNo) home $audace(posobs,observateur,gps)
   }
   pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 \
      -expand true

   #--- Frame des vitesses de guidage
   frame $frm.frame2.frameSpeed -borderwidth 0

      #--- Vitesse de rappel alpha
      label $frm.frame2.frameSpeed.labelAlpha -text "$caption(mcmt,rappelAD)"
      entry $frm.frame2.frameSpeed.entryAlpha -textvariable ::mcmt::private(alphaGuidingSpeed) -width 5 -justify right
      grid $frm.frame2.frameSpeed.labelAlpha  -row 0 -column 0 -sticky nw -ipadx 3
      grid $frm.frame2.frameSpeed.entryAlpha  -row 0 -column 1 -sticky nw -ipadx 3

      #--- Vitesse de rappel delta
      label $frm.frame2.frameSpeed.labelDelta -text "$caption(mcmt,rappelDec)"
      entry $frm.frame2.frameSpeed.entryDelta -textvariable ::mcmt::private(deltaGuidingSpeed) -width 5 -justify right
      grid $frm.frame2.frameSpeed.labelDelta  -row 1 -column 0 -sticky nw -ipadx 3
      grid $frm.frame2.frameSpeed.entryDelta  -row 1 -column 1 -sticky nw -ipadx 3

      #--- Information
      label $frm.frame2.frameSpeed.labelInformation -text "$caption(mcmt,vitesseSiderale)"
      grid $frm.frame2.frameSpeed.labelInformation  -row 0 -column 2 -rowspan 2 -sticky ns -ipadx 3

      grid rowconfigure $frm.frame2.frameSpeed 0 -weight 0
      grid rowconfigure $frm.frame2.frameSpeed 1 -weight 0

      grid columnconfigure $frm.frame2.frameSpeed 0 -weight 0
      grid columnconfigure $frm.frame2.frameSpeed 1 -weight 0
      grid columnconfigure $frm.frame2.frameSpeed 2 -weight 1

   pack $frm.frame2.frameSpeed -in $frm.frame2 -anchor n -side left -padx 10 -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Le checkbutton pour obtenir des traces dans la Console
   checkbutton $frm.tracesConsole -text "$caption(mcmt,tracesConsole)" \
      -highlightthickness 0 -variable ::mcmt::private(tracesConsole) \
      -command "::mcmt::tracesConsole"
   pack $frm.tracesConsole -in $frm.frame2a -anchor w -side left -padx 10 -pady 10

   #--- Entree de la tempo Ite-lente
   label $frm.lab4 -text "$caption(mcmt,ite-lente_tempo)"
   pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   entry $frm.tempo -textvariable ::mcmt::private(ite-lente_tempo) -justify center -width 5
   pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Bouton GO/Stop A0
   checkbutton $frm.ite-lente_A0 -text "$caption(mcmt,ite-lente_A0,go)" -relief raised -indicatoron 0 \
      -variable ::mcmt::private(ite-lente_A0) -state disabled \
      -command "::mcmt::testIteLente ite-lente_A0"
   pack $frm.ite-lente_A0 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10

   #--- Bouton GO/Stop A1
   checkbutton $frm.ite-lente_A1 -text "$caption(mcmt,ite-lente_A1,go)" -relief raised -indicatoron 0 \
      -variable ::mcmt::private(ite-lente_A1) -state disabled \
      -command "::mcmt::testIteLente ite-lente_A1"
   pack $frm.ite-lente_A1 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10

   #--- Bouton ACK
   button $frm.ite-lente_ack -text "$caption(mcmt,ite-lente_ack)" -relief raised \
      -state disabled -command "::mcmt::testIteLente ite-lente_ack"
   pack $frm.ite-lente_ack -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(mcmt,raquette_tel)" \
      -highlightthickness 0 -variable ::mcmt::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Bouton park
   button $frm.park -text "$caption(mcmt,park)" -relief raised -command "::telescope::park 1" \
      -state disabled
   pack $frm.park -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Bouton unpark
   button $frm.unpark -text "$caption(mcmt,unpark)" -relief raised -command "::telescope::park 0" \
      -state disabled
   pack $frm.unpark -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Site web officiel du mcmt
   label $frm.lab103 -text "$caption(mcmt,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(mcmt,site_web_ref)" \
      "$caption(mcmt,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::mcmt::confmcmt

   #--- Gestion de la tempo pour Ite-lente
   ::mcmt::confModele
}

#
# configureMonture
#    Configure la monture mcmt en fonction des donnees contenues dans les variables conf(mcmt,...)
#
proc ::mcmt::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      switch [::confLink::getLinkNamespace $conf(mcmt,port)] {
         audinet {
            #--- Je cree la monture
            set telNo [ tel::create lxnet $conf(mcmt,port) -name lxnet \
               -host $conf(audinet,host) \
               -ipsetting $conf(audinet,ipsetting) \
               -macaddress $conf(audinet,mac_address) \
               -autoflush $conf(audinet,autoflush) \
               -focusertype $conf(audinet,focuser_type) \
               -focuseraddr $conf(audinet,focuser_addr) \
               -focuserbit $conf(audinet,focuser_bit) \
            ]
            #--- J'affiche un message d'information dans la Console
            ::console::affiche_entete "$caption(mcmt,host_audinet) $caption(mcmt,2points)\
               $conf(audinet,host)\n"
            ::console::affiche_saut "\n"
            if { $conf(mcmt,format) == "0" } {
               tel$telNo longformat off
            } else {
               tel$telNo longformat on
            }
            #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
            set linkNo [ ::confLink::create $conf(mcmt,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
            #--- Je change de variable
            set private(telNo) $telNo
         }
         serialport {
            #--- Je cree la monture
            set telNo [ tel::create mcmt $conf(mcmt,port) -name $conf(mcmt,modele) ]
            #--- J'affiche un message d'information dans la Console
            ::console::affiche_entete "$caption(mcmt,port_mcmt) ($conf(mcmt,modele))\
               $caption(mcmt,2points) $conf(mcmt,port)\n"
            ::console::affiche_saut "\n"
            if { $conf(mcmt,modele) == "Ite-lente" } {
               tel$telNo tempo $conf(mcmt,ite-lente_tempo)
            }
            #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
            set linkNo [ ::confLink::create $conf(mcmt,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
            #--- Je change de variable
            set private(telNo) $telNo
         }
      }
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- Gestion du bouton actif/inactif
      ::mcmt::confmcmt
      #--- Traces dans la Console
      ::mcmt::tracesConsole

      #--- Si connexion des codeurs Ouranos demandee en tant que monture secondaire
      if { $conf(mcmt,ouranos) == "1" } {
         #--- Je copie les parametres Ouranos dans conf()
         ::ouranos::widgetToConf
         #--- Je configure la monture secondaire Ouranos
         ::ouranos::configureMonture
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::mcmt::stop
      if { $conf(mcmt,ouranos) == "1" } {
         ::ouranos::stop
      }
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture mcmt
#
proc ::mcmt::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::mcmt::confmcmtInactif

   #--- Je desactive le rafraichissement automatique des coordonnees AD et Dec.
   tel$private(telNo) radec survey 0
   #--- Je memorise le port
   set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
    ::confLink::delete $telPort "tel$private(telNo)" "control"
   set private(telNo) "0"

   #--- Deconnexion des codeurs Ouranos si la monture secondaire existe
   if { $conf(mcmt,ouranos) == "1" } {
      ::ouranos::stop
   }
}

#
# confmcmt
# Permet d'activer ou de desactiver le bouton
#
proc ::mcmt::confmcmt { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::mcmt::isReady ] == 1 } {
            if { [ ::confTel::getPluginProperty hasUpdateDate ] == "1" } {
               #--- Bouton Mise a jour de la date et du lieu actif
               $frm.majpara configure -state normal
            }
            #--- Cas des modeles qui ont la fonction "park"
            if { [ ::confTel::getPluginProperty hasPark ] == "1" } {
               #--- Bouton park actif
               $frm.park configure -state normal
            }
            #--- Cas des modeles qui ont la fonction "unpark"
            if { [ ::confTel::getPluginProperty hasUnpark ] == "1" } {
               #--- Bouton unpark actif
               $frm.unpark configure -state normal
            }
            #--- Cas du modele Ite-Lente
            if { $private(modele) == "$caption(mcmt,modele_ite-lente)" } {
               $frm.ite-lente_A0 configure -state normal
               $frm.ite-lente_A1 configure -state normal
               $frm.ite-lente_ack configure -state normal
            }
         } else {
            #--- Bouton Mise a jour de la date et du lieu inactif
            $frm.majpara configure -state disabled
            #--- Bouton park inactif
            $frm.park configure -state disabled
            #--- Bouton unpark inactif
            $frm.unpark configure -state disabled
            #--- Boutons du modele Ite-Lente
            $frm.ite-lente_A0 configure -state disabled
            $frm.ite-lente_A1 configure -state disabled
            $frm.ite-lente_ack configure -state disabled
         }
      }
   }
}

#
# confmcmtInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::mcmt::confmcmtInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Bouton Mise a jour de la date et du lieu inactif
         $frm.majpara configure -state disabled
         #--- Bouton park inactif
         $frm.park configure -state disabled
         #--- Bouton unpark inactif
         $frm.unpark configure -state disabled
         #--- Boutons du modele Ite-Lente
         if { [ winfo exists $frm.ite-lente_A0 ] } {
            $frm.ite-lente_A0 configure -state disabled
            $frm.ite-lente_A1 configure -state disabled
            $frm.ite-lente_ack configure -state disabled
         }
      }
   }
}

#
# confModele
# Permet d'activer ou de desactiver les champs lies au modele
#
proc ::mcmt::confModele { } {
   variable private
   global audace caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Cas du modele IteLente
         if { $private(modele) == "$caption(mcmt,modele_ite-lente)" } {
            if { ! [ winfo exists $frm.lab4 ] } {
               #--- Label de la tempo Ite-lente
               label $frm.lab4 -text "$caption(mcmt,ite-lente_tempo)"
               pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
            }
            if { ! [ winfo exists $frm.tempo ] } {
               #--- Entree de la tempo Ite-lente
               entry $frm.tempo -textvariable ::mcmt::private(ite-lente_tempo) -justify center -width 5
               pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
               #--- Bouton GO/Stop A0
               checkbutton $frm.ite-lente_A0 -text "$caption(mcmt,ite-lente_A0,go)" -relief raised -indicatoron 0 \
                  -variable ::mcmt::private(ite-lente_A0) -state disabled \
                  -command "::mcmt::testIteLente ite-lente_A0"
               pack $frm.ite-lente_A0 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
               #--- Bouton GO/Stop A1
               checkbutton $frm.ite-lente_A1 -text "$caption(mcmt,ite-lente_A1,go)" -relief raised -indicatoron 0 \
                  -variable ::mcmt::private(ite-lente_A1) -state disabled \
                  -command "::mcmt::testIteLente ite-lente_A1"
               pack $frm.ite-lente_A1 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
               #--- Bouton ACK
               button $frm.ite-lente_ack -text "$caption(mcmt,ite-lente_ack)" -relief raised \
                  -state disabled -command "::mcmt::testIteLente ite-lente_ack"
               pack $frm.ite-lente_ack -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
            }
         } else {
            destroy $frm.lab4 ; destroy $frm.tempo
            destroy $frm.ite-lente_A0 ; destroy $frm.ite-lente_A1 ; destroy $frm.ite-lente_ack
         }
         #--- Cas du modele AudeCom
         if { $private(modele) == "$caption(mcmt,modele_audecom)" } {
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
# testIteLente
#    Envoie les commandes A0, A1 et ACK
#
proc ::mcmt::testIteLente { buttonName } {
   variable private
   global caption

   switch $buttonName {
      ite-lente_A0 {
         if { $private($buttonName) == "1" } {
            tel$private(telNo) command "#:Xa+#" none
            $private(frm).$buttonName configure -text $caption(mcmt,$buttonName,stop)
         } else {
            tel$private(telNo) command "#:Xa-#" none
            $private(frm).$buttonName configure -text $caption(mcmt,$buttonName,go)
         }
      }
      ite-lente_A1 {
         if { $private($buttonName) == "1" } {
            tel$private(telNo) command "#:Xb+#" none
            $private(frm).$buttonName configure -text $caption(mcmt,$buttonName,stop)
         } else {
            tel$private(telNo) command "#:Xb-#" none
            $private(frm).$buttonName configure -text $caption(mcmt,$buttonName,go)
         }
      }
      ite-lente_ack {
         tel$private(telNo) command "\x06" ok
      }
   }
}

#
# tracesConsole
#    Affiche des traces dans la Console
#
proc ::mcmt::tracesConsole { } {
   variable private

   if { $private(telNo) == "0" } {
      return
   }

   tel$private(telNo) consolelog $private(tracesConsole)
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
# hasMotionWhile          Retourne la possibilite d'avoir des deplacements cardinaux pendant une duree
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::mcmt::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              {
         if { $::conf(mcmt,modele) == "$::caption(mcmt,modele_audecom)" } {
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
      hasControlSuivi         { return 1 }
      hasModel                { return 1 }
      hasMotionWhile          {
         if { $::conf(mcmt,modele) == "$::caption(mcmt,modele_ite-lente)" } {
            return 1
         } else {
            return 0
         }
      }
      hasPark                 {
         if {  $::conf(mcmt,modele) == $::caption(mcmt,modele_mcmt)
            || $::conf(mcmt,modele) == $::caption(mcmt,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUnpark               {
         if { $::conf(mcmt,modele) == $::caption(mcmt,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUpdateDate           {
         if {  $::conf(mcmt,modele) == $::caption(mcmt,modele_mcmt)
            || $::conf(mcmt,modele) == $::caption(mcmt,modele_skysensor)
            || $::conf(mcmt,modele) == $::caption(mcmt,modele_gemini)
            || $::conf(mcmt,modele) == $::caption(mcmt,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      backlash                { return 0 }
      guidingSpeed            { return [list $::conf(mcmt,alphaGuidingSpeed) $::conf(mcmt,deltaGuidingSpeed) ] }
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
proc ::mcmt::park { state } {
   variable private

   if {  $::conf(mcmt,modele) == $::caption(mcmt,modele_mcmt) } {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":hP#" none
      } elseif { $state == 0 } {
         #--- je ne fais rien car Meade n'a pas la fonction un-park
      }
   } elseif { $::conf(mcmt,modele) == $::caption(mcmt,modele_astro_physics)} {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":KA#" none
      } elseif { $state == 0 } {
         #--- j'envoie l'heure courante
         tel$::mcmt::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
         #--- je de-parque la monture
         tel$private(telNo) command ":PO#" none
      }
   }
}

proc ::mcmt::move { direction rate } {
   global conf caption
   variable private

   if {$conf(mcmt,modele) != $caption(mcmt,modele_astro_physics)} {
      # Cas normal, le driver va faire le necessaire */
      tel$private(telNo) radec move $direction $rate
   } else {
      # Cas Astrophysics (a base de GTOCP3)
      # Commande de vitesse
      if {$rate < 0.33} {
         # x1
         tel$private(telNo) command ":RG2#" none
      } elseif {$rate < 0.66} {
         # x12
         tel$private(telNo) command ":RC0#" none
      } elseif {$rate < 1} {
         # x64
         tel$private(telNo) command ":RC1#" none
      } else {
         # x600
         tel$private(telNo) command ":RC2#" none
      }

      # Commande de mouvement NEWS
      set d [lindex [string toupper $direction] 0]
      if { $d == "N" } {
         tel$private(telNo) command ":Mn#" none
      } elseif { $d == "S" } {
         tel$private(telNo) command ":Ms#" none
      } elseif { $d == "E" } {
         tel$private(telNo) command ":Me#" none
      } elseif { $d == "W" } {
         tel$private(telNo) command ":Mw#" none
      } else {
         ::console::affiche_entete "AP command set : unknow direction"
      }
   }

}

