#
# Fichier : temma.tcl
# Description : Fenetre de configuration pour le parametrage du suivi d'objets mobiles pour le telescope Temma
# Auteur : Robert DELMAS
# Mise a jour $Id: temma.tcl,v 1.14 2007-12-19 22:29:44 robertdelmas Exp $
#

namespace eval ::temma {
   package provide temma 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] temma.cap ]
}

#
# ::temma::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::temma::getPluginTitle { } {
   global caption

   return "$caption(temma,monture)"
}

#
#  ::temma::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::temma::getPluginHelp { } {
   return "temma.htm"
}

#
# ::temma::getPluginType
#    Retourne le type du plugin
#
proc ::temma::getPluginType { } {
   return "mount"
}

#
# ::temma::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::temma::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::temma::initPlugin
#    Initialise les variables conf(temma,...)
#
proc ::temma::initPlugin { } {
   global audace conf

   #--- Charge le fichier auxiliaire
   uplevel #0 "source \"[ file join $audace(rep_plugin) mount temma temmaconfig.tcl ]\""

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Temma
   if { ! [ info exists conf(temma,port) ] }       { set conf(temma,port)       [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(temma,correc_AD) ] }  { set conf(temma,correc_AD)  "50" }
   if { ! [ info exists conf(temma,correc_Dec) ] } { set conf(temma,correc_Dec) "50" }
   if { ! [ info exists conf(temma,liaison) ] }    { set conf(temma,liaison)    "1" }
   if { ! [ info exists conf(temma,modele) ] }     { set conf(temma,modele)     "0" }
   if { ! [ info exists conf(temma,suivi_ad) ] }   { set conf(temma,suivi_ad)   "0" }
   if { ! [ info exists conf(temma,suivi_dec) ] }  { set conf(temma,suivi_dec)  "0" }
   if { ! [ info exists conf(temma,type) ] }       { set conf(temma,type)       "0" }
}

#
# ::temma::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::temma::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture Temma dans le tableau private(...)
   set private(port)       $conf(temma,port)
   set private(correc_AD)  $conf(temma,correc_AD)
   set private(correc_Dec) $conf(temma,correc_Dec)
   set private(liaison)    $conf(temma,liaison)
   set private(modele)     [ lindex "$caption(temma,modele_1) $caption(temma,modele_2) $caption(temma,modele_3)" $conf(temma,modele) ]
   set private(suivi_ad)   $conf(temma,suivi_ad)
   set private(suivi_dec)  $conf(temma,suivi_dec)
   set private(type)       $conf(temma,type)
   set private(raquette)   $conf(raquette)
}

#
# ::temma::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::temma::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture Temma dans le tableau conf(temma,...)
   set conf(temma,correc_AD)  $private(correc_AD)
   set conf(temma,correc_Dec) $private(correc_Dec)
   set conf(temma,liaison)    $private(liaison)
   set conf(temma,modele)     [ lsearch "$caption(temma,modele_1) $caption(temma,modele_2) $caption(temma,modele_3)" "$private(modele)" ]
   set conf(temma,port)       $private(port)
   set conf(temma,suivi_ad)   $private(suivi_ad)
   set conf(temma,suivi_dec)  $private(suivi_dec)
   set conf(temma,type)       $private(type)
   set conf(raquette)         $private(raquette)
}

#
# ::temma::fillConfigPage
#    Interface de configuration de la monture Temma
#
proc ::temma::fillConfigPage { frm } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::temma::confToWidget

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
   pack $frm.frame4 -in $frm.frame2 -side left -fill x -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -in $frm.frame2 -side left -fill x

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -side top -fill x

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -side top -fill x

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -side bottom -fill x -pady 2

   #--- Definition du port
   label $frm.lab1 -text "$caption(temma,port)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

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
   button $frm.configure -text "$caption(temma,configurer)" -relief raised \
      -command {
         ::confLink::run ::private(port) { serialport } \
            "- $caption(temma,controle) - $caption(temma,monture)"
      }
   pack $frm.configure -in $frm.frame1 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 7          \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::temma::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

   #--- Definition du modele Temma
   set list_combobox [ list $caption(temma,modele_1) $caption(temma,modele_2) \
      $caption(temma,modele_3) ]
   ComboBox $frm.modele \
      -width 25         \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::temma::private(modele) \
      -editable 0       \
      -values $list_combobox
   pack $frm.modele -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

   label $frm.lab2 -text "$caption(temma,modele)"
   pack $frm.lab2 -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

   #--- Liaison des curseurs d'AD et de Dec.
   if { $private(liaison) != "1" } {

      #--- Label de la correction en AD
      label $frm.lab3 -text "$caption(temma,correc_AD)"
      pack $frm.lab3 -in $frm.frame4 -anchor e -side top -pady 7

      #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
      checkbutton $frm.liaison -text "$caption(temma,liaison_AD_Dec)" -highlightthickness 0 \
         -variable ::temma::private(liaison) -onvalue 1 -offvalue 0 -command { ::temma::config_correc_Temma }
      pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

      #--- Label de la correction en Dec
      label $frm.lab4 -text "$caption(temma,correc_Dec)"
      pack $frm.lab4 -in $frm.frame4 -anchor e -side top -pady 7

      #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
      scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
         -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_AD) -width 10
      pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

      #--- Reglage de la vitesse de correction en Dec. pour la vitesse normale (NS)
      scale $frm.correc_variantDec -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
         -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_Dec) -width 10
      pack $frm.correc_variantDec -in $frm.frame5 -side top -padx 10

   } else {

      #--- Label de la correction en AD
      label $frm.lab3 -text "$caption(temma,correc_AD)"
      pack $frm.lab3 -in $frm.frame4 -anchor e -side top

      #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
      checkbutton $frm.liaison -text "$caption(temma,liaison_AD_Dec)" -highlightthickness 0 \
         -variable ::temma::private(liaison) -command { ::temma::config_correc_Temma }
      pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

      #--- Label de la correction en Dec
      label $frm.lab4 -text "$caption(temma,correc_Dec)"
      pack $frm.lab4 -in $frm.frame4 -anchor e -side top

      #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
      scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
         -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_AD) -width 10
      pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

      #--- Liaison des corrections en AD et en Dec.
      set private(correc_Dec) $private(correc_AD)

   }

   #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
   label $frm.pos_tel -text "$caption(temma,position_telescope)"
   pack $frm.pos_tel -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
   pack $frm.pos_tel_ew -in $frm.frame3 -anchor center -side left -pady 10

   #--- Initialisation de l'instrument au zenith
   if { [ ::confTel::isReady ] == 1 } {
      button $frm.init_zenith -text "$caption(temma,init_zenith)" -relief raised -state normal -command {
         tel$audace(telNo) initzenith
         ::telescope::afficheCoord
      }
      pack $frm.init_zenith -in $frm.frame3 -anchor nw -side right -padx 10 -pady 10 -ipadx 10 -ipady 5
   } else {
      button $frm.init_zenith -text "$caption(temma,init_zenith)" -relief raised -state disabled
      pack $frm.init_zenith -in $frm.frame3 -anchor nw -side right -padx 10 -pady 10 -ipadx 10 -ipady 5
   }

   #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
   label $frm.pos_tel_est -text "$caption(temma,change_position_telescope)"
   pack $frm.pos_tel_est -in $frm.frame6 -anchor center -side left -padx 10 -pady 5

   if { [ ::confTel::isReady ] == 1 } {
      button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel) -command {
         set pos_tel [ tel$audace(telNo) german ]
         if { $pos_tel == "E" } {
            tel$audace(telNo) german W
         } elseif { $pos_tel == "W" } {
            tel$audace(telNo) german E
         }
         ::telescope::monture_allemande
      }
      pack $frm.chg_pos_tel -in $frm.frame6 -anchor nw -side left -padx 10 -pady 10 -ipadx 10 -ipady 5
   } else {
      button $frm.chg_pos_tel -text "  ?  " -relief raised -state disabled
      pack $frm.chg_pos_tel -in $frm.frame6 -anchor nw -side left -padx 10 -pady 10 -ipadx 10 -ipady 5
   }

   #--- Bouton de controle de la vitesse de suivi
   button $frm.tracking -text "$caption(temma,ctl_mobile)" -state normal \
      -command { ::confTemmaMobile::run "$audace(base).confTemmaMobile" }
   pack $frm.tracking -in $frm.frame6 -anchor center -side right -padx 10 -pady 10 -ipadx 10 -ipady 5

   #--- Rafraichissement de la position du telescope par rapport a la monture
   if { [ ::confTel::isReady ] == 1 } {
      #--- Affichage de la position du telescope
     ### ::telescope::monture_allemande
   }

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(temma,raquette_tel)" \
      -highlightthickness 0 -variable ::temma::private(raquette)
   pack $frm.raquette -in $frm.frame7 -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame7 -side left -padx 0 -pady 10

   #--- Site web officiel Temma et Takahashi
   label $frm.lab103 -text "$caption(temma,titre_site_web)"
   pack $frm.lab103 -in $frm.frame8 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame8 "$caption(temma,site_temma)" \
      "$caption(temma,site_temma)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion des boutons actifs/inactifs
   ::temma::confTemma
}

#
# ::temma::configureTelescope
#    Configure la monture Temma en fonction des donnees contenues dans les variables conf(temma,...)
#
proc ::temma::configureTelescope { } {
   variable private
   global audace caption conf

   set audace(telNo) [ tel::create temma $conf(temma,port) ]
   if { $conf(temma,modele) == "0" } {
      set private(modele) $caption(temma,modele_1)
   } elseif { $conf(temma,modele) == "1" } {
      set private(modele) $caption(temma,modele_2)
   } else {
      set private(modele) $caption(temma,modele_3)
   }
   console::affiche_erreur "$caption(temma,port_temma) ($private(modele)) \
      $caption(temma,2points) $conf(temma,port)\n"
   #--- Lit et affiche la version du Temma
   set version [ tel$audace(telNo) firmware ]
   console::affiche_erreur "$caption(temma,version) $version\n"
   console::affiche_saut "\n"
   #--- Demande et recoit la latitude
   set latitude_temma [ tel$audace(telNo) getlatitude ]
   #--- Mise en forme de la latitude du lieu du format Temma au format d'affichage
   set signe_lat [ string range $latitude_temma 0 0 ]
   if { $signe_lat == "-" } {
      set signe_lat "S"
      set lat_deg [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 0 ]
      set lat_deg [ string range $lat_deg 1 2 ]
   } else {
      set signe_lat "N"
      set lat_deg [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 0 ]
   }
   set lat_min [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 1 ]
   set lat_min_deci [ format "%.1f" [ expr [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 2 ] / 60.0 ] ]
   set lat_min_deci [ string range $lat_min_deci 2 2 ]
   set latitude_temma "$signe_lat $lat_deg° $lat_min.$lat_min_deci'"
   #--- Affichage de la latitude
   ::console::affiche_erreur "$caption(temma,init_module)\n"
   ::console::affiche_erreur "$caption(temma,latitude) $latitude_temma\n\n"
   #--- Prise en compte des encodeurs
   tel$audace(telNo) encoder "1"
   #--- Force la mise en marche des moteurs
   tel$audace(telNo) radec motor on
   #--- Prise en compte des corrections de la vitesse normale en AD et en Dec.
   if { $conf(temma,liaison) == "1" } {
      tel$audace(telNo) correctionspeed $conf(temma,correc_AD) $conf(temma,correc_AD)
   } else {
      tel$audace(telNo) correctionspeed $conf(temma,correc_AD) $conf(temma,correc_Dec)
   }
   #--- Correction de la vitesse de suivi en ad et en dec
   if { $conf(temma,type) == "0" } {
      tel$audace(telNo) driftspeed 0 0
      ::console::affiche_resultat "$caption(temma,mobile_etoile)\n\n"
   } elseif { $conf(temma,type) == "1" } {
      tel$audace(telNo) driftspeed $conf(temma,suivi_ad) $conf(temma,suivi_dec)
      set correction_suivi [ tel$audace(telNo) driftspeed ]
      ::console::affiche_resultat "$caption(temma,ctl_mobile:)\n"
      ::console::affiche_resultat "$caption(temma,mobile_ad) $caption(temma,2points)\
         [ lindex $correction_suivi 0 ]\n"
      ::console::affiche_resultat "$caption(temma,mobile_dec) $caption(temma,2points)\
         [ lindex $correction_suivi 1 ]\n\n"
   }
   #--- Affichage de la position du telescope
   if { [ ::confTel::isReady ] == 1 } {
      ::telescope::monture_allemande
   }
   #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par le telescope)
   set linkNo [ ::confLink::create $conf(temma,port) "tel$audace(telNo)" "control" [ tel$audace(telNo) product ] ]
   #--- Gestion des boutons actifs/inactifs
   ::temma::confTemma
   ::temma::config_correc_Temma
}

#
# ::temma::stop
#    Arrete la monture Temma
#
proc ::temma::stop { } {
   global audace

   #--- Gestion du bouton actif/inactif
   ::temma::confTemmaInactif

   #--- Je memorise le port
   set telPort [ tel$audace(telNo) port ]
   #--- J'arrete la monture
   tel::delete $audace(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$audace(telNo)" "control"
   set audace(telNo) "0"
}

#
# ::temma::confTemma
# Permet d'activer ou de désactiver les boutons
#
proc ::temma::confTemma { } {
   variable private
   global audace

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::confTel::isReady ] == 1 } {
            #--- Boutons de la monture actifs
            $frm.init_zenith configure -state normal -command {
               tel$audace(telNo) initzenith
               ::telescope::afficheCoord
            }
            $frm.chg_pos_tel configure -state normal -textvariable audace(chg_pos_tel) -command {
               set pos_tel [ tel$audace(telNo) german ]
               if { $pos_tel == "E" } {
                  tel$audace(telNo) german W
               } elseif { $pos_tel == "W" } {
                  tel$audace(telNo) german E
               }
               ::telescope::monture_allemande
            }
         } else {
            #--- Boutons de la monture inactifs
            $frm.init_zenith configure -state disabled
            $frm.chg_pos_tel configure -text "  ?  " -state disabled
         }
      }
   }
}

#
# ::temma::confTemmaInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::temma::confTemmaInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::confTel::isReady ] == 1 } {
            #--- Boutons de la monture inactifs
            $frm.init_zenith configure -state disabled
            $frm.chg_pos_tel configure -text "  ?  " -state disabled
         }
      }
   }
}

#
# ::temma::config_correc_Temma
# Permet d'afficher une ou deux echelles de reglage de la vitesse normale de correction
#
proc ::temma::config_correc_Temma { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { $private(liaison) != "1" } {

         destroy $frm.lab3
         destroy $frm.liaison
         destroy $frm.lab4
         destroy $frm.correc_variantAD
         destroy $frm.correc_variantDec

         #--- Label de la correction en AD
         label $frm.lab3 -text "$caption(temma,correc_AD)"
         pack $frm.lab3 -in $frm.frame4 -anchor e -side top -pady 7

         #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
         checkbutton $frm.liaison -text "$caption(temma,liaison_AD_Dec)" -highlightthickness 0 \
            -variable ::temma::private(liaison) -command { ::temma::config_correc_Temma }
         pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

         #--- Label de la correction en Dec
         label $frm.lab4 -text "$caption(temma,correc_Dec)"
         pack $frm.lab4 -in $frm.frame4 -anchor e -side top -pady 7

         #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
         scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
            -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_AD) -width 10
         pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

         #--- Reglage de la vitesse de correction en Dec. pour la vitesse normale (NS)
         scale $frm.correc_variantDec -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
            -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_Dec) -width 10
         pack $frm.correc_variantDec -in $frm.frame5 -side top -padx 10

      } else {

         destroy $frm.lab3
         destroy $frm.liaison
         destroy $frm.lab4
         destroy $frm.correc_variantAD
         destroy $frm.correc_variantDec

         #--- Label de la correction en AD
         label $frm.lab3 -text "$caption(temma,correc_AD)"
         pack $frm.lab3 -in $frm.frame4 -anchor e -side top

         #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
         checkbutton $frm.liaison -text "$caption(temma,liaison_AD_Dec)" -highlightthickness 0 \
            -variable ::temma::private(liaison) -command { ::temma::config_correc_Temma }
         pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

         #--- Label de la correction en Dec
         label $frm.lab4 -text "$caption(temma,correc_Dec)"
         pack $frm.lab4 -in $frm.frame4 -anchor e -side top

         #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
         scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
            -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_AD) -width 10
         pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

         #--- Liaison des corrections en AD et en Dec.
         set private(correc_Dec) $private(correc_AD)

      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }
}

#
# ::temma::getPluginProperty
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
proc ::temma::getPluginProperty { propertyName } {
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

