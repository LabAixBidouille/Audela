#
# Fichier : ouranos.tcl
# Description : Configuration de la monture Ouranos
# Auteur : Robert DELMAS
# Mise a jour $Id: ouranos.tcl,v 1.9 2008-02-06 22:15:55 robertdelmas Exp $
#

namespace eval ::ouranos {
   package provide ouranos 2.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ouranos.cap ]
}

#
# ::ouranos::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::ouranos::getPluginTitle { } {
   global caption

   return "$caption(ouranos,monture)"
}

#
#  ::ouranos::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::ouranos::getPluginHelp { } {
   return "ouranos.htm"
}

#
# ::ouranos::getPluginType
#    Retourne le type du plugin
#
proc ::ouranos::getPluginType { } {
   return "mount"
}

#
# ::ouranos::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::ouranos::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::ouranos::getTelNo
#    Retourne le numero de la monture
#
proc ::ouranos::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# ::ouranos::isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::ouranos::isReady { } {
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
# ::ouranos::initPlugin
#    Initialise les variables conf(ouranos,...)
#
proc ::ouranos::initPlugin { } {
   variable private
   global audace conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Charge le fichier auxiliaire
   uplevel #0 "source \"[ file join $audace(rep_plugin) mount ouranos ouranoscom.tcl ]\""

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialisation des variables de la monture Ouranos
   if { ! [ info exists conf(ouranos,port) ] }        { set conf(ouranos,port)        [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(ouranos,cod_ra) ] }      { set conf(ouranos,cod_ra)      "32768" }
   if { ! [ info exists conf(ouranos,cod_dec) ] }     { set conf(ouranos,cod_dec)     "32768" }
   if { ! [ info exists conf(ouranos,freq) ] }        { set conf(ouranos,freq)        "1" }
   if { ! [ info exists conf(ouranos,init) ] }        { set conf(ouranos,init)        "0" }
   if { ! [ info exists conf(ouranos,inv_ra) ] }      { set conf(ouranos,inv_ra)      "1" }
   if { ! [ info exists conf(ouranos,inv_dec) ] }     { set conf(ouranos,inv_dec)     "1" }
   if { ! [ info exists conf(ouranos,show_coord) ] }  { set conf(ouranos,show_coord)  "1" }
   if { ! [ info exists conf(ouranos,tjrsvisible) ] } { set conf(ouranos,tjrsvisible) "0" }

   #--- Initialisation des fenetres d'affichage des coordonnees AD et Dec.
   if { ! [ info exists conf(ouranos,wmgeometry) ] }     { set conf(ouranos,wmgeometry)     "200x70+640+268" }
   if { ! [ info exists conf(ouranos,x10,wmgeometry) ] } { set conf(ouranos,x10,wmgeometry) "850x500+0+0" }
}

#
# ::ouranos::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ouranos::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Ouranos dans le tableau private(...)
   if { $::OuranosCom::private(lecture) == "0" } {
      ::OuranosCom::init_ouranos
   }
   set private(port) $conf(ouranos,port)

}

#
# ::ouranos::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ouranos::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Ouranos dans le tableau conf(ouranos,...)
   set conf(ouranos,cod_ra)     $private(cod_ra)
   set conf(ouranos,cod_dec)    $private(cod_dec)
   set conf(ouranos,freq)       $private(freq)
   set conf(ouranos,init)       $private(init)
   set conf(ouranos,inv_ra)     $private(inv_ra)
   set conf(ouranos,inv_dec)    $private(inv_dec)
   set conf(ouranos,port)       $private(port)
   set conf(ouranos,show_coord) $private(show_coord)
}

#
# ::ouranos::fillConfigPage
#    Interface de configuration de la monture Ouranos
#
proc ::ouranos::fillConfigPage { frm } {
   variable private
   global audace caption color conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::ouranos::confToWidget

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 1

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x -expand 0

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill both -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side top -fill both -expand 1

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -side bottom -fill x -pady 2

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame2 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame2 -side left -fill both -expand 1

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame2 -side left -fill both -expand 1

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame3 -side left -fill both -expand 1

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame3 -side left -fill both -expand 1

   frame $frm.frame12 -borderwidth 0 -relief raised
   pack $frm.frame12 -in $frm.frame7 -side top -fill both -expand 1

   frame $frm.frame13 -borderwidth 0 -relief raised
   pack $frm.frame13 -in $frm.frame7 -side top -fill both -expand 1

   frame $frm.frame14 -borderwidth 0 -relief raised
   pack $frm.frame14 -in $frm.frame8 -side top -fill both -expand 1

   frame $frm.frame15 -borderwidth 0 -relief raised
   pack $frm.frame15 -in $frm.frame8 -side top -fill both -expand 1

   #--- Definition du port
   label $frm.lab1 -text "$caption(ouranos,port)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

   entry $frm.status -font $audace(font,arial_8_b) -textvariable ::ouranos::private(status) -width 4 \
      -justify center -bg $color(red)
   pack $frm.status -in $frm.frame1 -anchor center -side left -padx 0 -pady 5

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
   button $frm.configure -text "$caption(ouranos,configurer)" -relief raised \
      -command {
         ::confLink::run ::ouranos::private(port) { serialport } \
            "- $caption(ouranos,controle) - $caption(ouranos,monture)"
      }
   pack $frm.configure -in $frm.frame1 -anchor n -side left -padx 10 -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 7        \
      -height [ llength $list_connexion ] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable ::ouranos::private(port) \
      -editable 0     \
      -values $list_connexion
   pack $frm.port -in $frm.frame1 -anchor center -side left -padx 0 -pady 5

   #--- Selection affichage toujours visibles ou non
   checkbutton $frm.visible -text "$caption(ouranos,visible)" -highlightthickness 0 \
      -variable ::ouranos::private(tjrsvisible) -onvalue 1 -offvalue 0 \
      -command { set ::ouranos::private(dim) "0" ; ::OuranosCom::tjrsVisible }
   pack $frm.visible -in $frm.frame1 -anchor center -side right -padx 13 -pady 5

   #--- Definition des unit�s de l'affichage (pas encodeurs ou coordonn�es)
   checkbutton $frm.unites -text "$caption(ouranos,unites)" -highlightthickness 0 \
      -variable ::ouranos::private(show_coord) -onvalue 1 -offvalue 0 \
      -command { ::ouranos::confRadioBouton ; ::ouranos::matchOuranos ; ::OuranosCom::show1 }
   pack $frm.unites -in $frm.frame1 -anchor center -side right -padx 0 -pady 5

   #--- Informations concernant le codeur RA
   label $frm.ra -text "$caption(ouranos,res_codeur)"
   pack $frm.ra -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

   #--- Valeur des pas encodeurs RA pour 1 tour
   entry $frm.codRA -textvariable ::ouranos::private(cod_ra) -justify center -width 7
   pack $frm.codRA -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

   #--- Definition de l'inversion de RA
   checkbutton $frm.invra -text "$caption(ouranos,inv)" -highlightthickness 0 \
      -variable ::ouranos::private(inv_ra) -onvalue -1 -offvalue 1
   pack $frm.invra -in $frm.frame14 -anchor center -side left -padx 10 -pady 5

   #--- Label pour les coordonn�es RA
   label  $frm.encRA -text "$caption(ouranos,ra)"
   pack $frm.encRA -in $frm.frame14 -anchor center -side right -padx 10 -pady 5

   #--- Fen�tre de lecture de RA
   label $frm.coordRA -font $audace(font,arial_8_b) -textvariable ::ouranos::private(coord_ra) \
      -justify left -width 12
   pack $frm.coordRA -in $frm.frame9 -anchor center -side top -padx 10 -pady 5

   #--- Informations concernant le codeur DEC
   label $frm.dec -text "$caption(ouranos,res_codeur)"
   pack $frm.dec -in $frm.frame13 -anchor center -side left -padx 10 -pady 5

   #--- Valeur des pas encodeurs DEC pour 1 tour
   entry $frm.codDEC -textvariable ::ouranos::private(cod_dec) -justify center -width 7
   pack $frm.codDEC -in $frm.frame13 -anchor center -side left -padx 10 -pady 5

   #--- Definition de l'inversion de DEC
   checkbutton $frm.invdec -text "$caption(ouranos,inv)" -highlightthickness 0 \
      -variable ::ouranos::private(inv_dec) -onvalue -1 -offvalue 1
   pack $frm.invdec -in $frm.frame15 -anchor center -side left -padx 10 -pady 5

   #--- Label pour les coordonn�es DEC
   label $frm.encDEC -text "$caption(ouranos,dec)"
   pack $frm.encDEC -in $frm.frame15 -anchor center -side right -padx 10 -pady 5

   #--- Fen�tre de lecture de DEC
   label $frm.coordDEC -font $audace(font,arial_8_b) -textvariable ::ouranos::private(coord_dec) \
      -justify left -width 12
   pack $frm.coordDEC -in $frm.frame9 -anchor center -side bottom -padx 10 -pady 5

   #--- Definition de l'initialisation DEC
   radiobutton $frm.dec90 -text "$caption(ouranos,init1)" -highlightthickness 0 \
      -indicatoron 1 -variable ::ouranos::private(init) -value 90 -command { }
   pack $frm.dec90 -in $frm.frame10 -anchor w -side top -padx 5 -pady 5

   radiobutton $frm.dec0 -text "$caption(ouranos,init2)" -highlightthickness 0 \
      -indicatoron 1 -variable ::ouranos::private(init) -value 0 -command { }
   pack $frm.dec0 -in $frm.frame10 -anchor w -side top -padx 5 -pady 5

   radiobutton $frm.dec-90 -text "$caption(ouranos,init3)" -highlightthickness 0 \
      -indicatoron 1 -variable ::ouranos::private(init) -value -90 -command { }
   pack $frm.dec-90 -in $frm.frame10 -anchor w -side top -padx 5 -pady 5

   #--- Les boutons de commande
   if { [ ::ouranos::isReady ] == 1 } {
      button $frm.but_init -text "$caption(ouranos,reglage)"  -width 7 -relief raised -state normal \
         -command { ::OuranosCom::find_res }
      pack $frm.but_init -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
      button $frm.but_close -text "$caption(ouranos,stop)" -width 6 -relief raised -state normal \
         -command { ::OuranosCom::close_com }
      pack $frm.but_close -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
      button $frm.but_read -text "$caption(ouranos,lire)" -width 6 -relief raised -state normal \
         -command { ::OuranosCom::go_ouranos }
      pack $frm.but_read -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
   } else {
      button $frm.but_init -text "$caption(ouranos,reglage)"  -width 7 -relief raised -state disabled
      pack $frm.but_init -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
      button $frm.but_close -text "$caption(ouranos,stop)" -width 6 -relief raised -state disabled
      pack $frm.but_close -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
      button $frm.but_read -text "$caption(ouranos,lire)" -width 6 -relief raised -state disabled
      pack $frm.but_read -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
   }

   #--- Definition de la fr�quence de lecture
   label  $frm.title1 -text "$caption(ouranos,seconde)"
   pack $frm.title1 -in $frm.frame11 -anchor center -side right -padx 5 -pady 5

   entry $frm.freq -textvariable ::ouranos::private(freq) -justify center -width 5
   pack $frm.freq -in $frm.frame11 -anchor center -side right -padx 5 -pady 5

   label  $frm.title -text "$caption(ouranos,frequence)"
   pack $frm.title -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

   #--- Gestion du bouton MATCH et des coordonnees pour MATCH
   set private(show_coord) $conf(ouranos,show_coord)
   if { $private(show_coord) == "1" } {
      #--- Bouton MATCH avec entry inactif
      button $frm.but_match -text "$caption(ouranos,match)" -width 8 -state disabled
      pack $frm.but_match -in $frm.frame4 -anchor center -side left -padx 20 -ipady 5
      #--- Valeur Dec. en � ' "
      entry $frm.match_dec_entry -textvariable ::ouranos::private(match_dec) -justify center -width 12
      pack $frm.match_dec_entry -in $frm.frame4 -anchor center -side right -padx 10
      #--- Commentaires Dec.
      label $frm.match_dec -text "$caption(ouranos,dec) $caption(ouranos,dms_angle)"
      pack $frm.match_dec -in $frm.frame4 -anchor center -side right -padx 10
      #--- Gestion des evenements Dec.
      bind $frm.match_dec_entry <Enter> { ::ouranos::formatMatchDec }
      bind $frm.match_dec_entry <Leave> { destroy $audace(base).format_match_dec }
      #--- Valeur AD en h mn s
      entry $frm.match_ra_entry -textvariable ::ouranos::private(match_ra) -justify center -width 12
      pack $frm.match_ra_entry -in $frm.frame4 -anchor center -side right -padx 10
      #--- Commentaires AD
      label $frm.match_ra -text "$caption(ouranos,ra) $caption(ouranos,hms_angle)"
      pack $frm.match_ra -in $frm.frame4 -anchor center -side right -padx 10
      #--- Gestion des evenements AD
      bind $frm.match_ra_entry <Enter> { ::ouranos::formatMatchAD }
      bind $frm.match_ra_entry <Leave> { destroy $audace(base).format_match_ad }
   } else {
      #--- Bouton MATCH sans entry inactif
      button $frm.but_match -text "$caption(ouranos,match)" -width 8 -state disabled
      pack $frm.but_match -in $frm.frame4 -anchor center -side left -padx 10 -ipady 5
   }

   #--- Gestion des catalogues
   if { ( [ ::ouranos::isReady ] == 1 ) && ( $private(show_coord) == "1" ) } {
      #--- Bouton radio Etoile
      radiobutton $frm.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text "$caption(ouranos,etoile)" -value 0 -variable ::ouranos::private(objet) -command {
            set ::ouranos::private(obj_choisi) $caption(ouranos,etoile)
            ::cataGoto::CataEtoiles
         }
      pack $frm.rad0 -in $frm.frame5 -anchor center -side left -padx 30
      #--- Bouton radio Messier
      radiobutton $frm.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text "$caption(ouranos,messier)" -value 1 -variable ::ouranos::private(objet) -command {
            set ::ouranos::private(obj_choisi) $caption(ouranos,messier)
            ::cataGoto::CataObjet $caption(ouranos,messier)
         }
      pack $frm.rad1 -in $frm.frame5 -anchor center -side left -padx 30
      #--- Bouton radio NGC
      radiobutton $frm.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text "$caption(ouranos,ngc)" -value 2 -variable ::ouranos::private(objet) -command {
            set ::ouranos::private(obj_choisi) $caption(ouranos,ngc)
            ::cataGoto::CataObjet $caption(ouranos,ngc)
         }
      pack $frm.rad2 -in $frm.frame5 -anchor center -side left -padx 30
      #--- Bouton radio IC
      radiobutton $frm.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text "$caption(ouranos,ic)" -value 3 -variable ::ouranos::private(objet) -command {
            set ::ouranos::private(obj_choisi) $caption(ouranos,ic)
            ::cataGoto::CataObjet $caption(ouranos,ic)
      }
      pack $frm.rad3 -in $frm.frame5 -anchor center -side left -padx 30
   } else {
      #--- Bouton radio Etoile
      radiobutton $frm.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
         -text "$caption(ouranos,etoile)" -value 0 -variable ::ouranos::private(objet)
      pack $frm.rad0 -in $frm.frame5 -anchor center -side left -padx 30
      #--- Bouton radio Messier
      radiobutton $frm.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
         -text "$caption(ouranos,messier)" -value 1 -variable ::ouranos::private(objet)
      pack $frm.rad1 -in $frm.frame5 -anchor center -side left -padx 30
      #--- Bouton radio NGC
      radiobutton $frm.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
         -text "$caption(ouranos,ngc)" -value 2 -variable ::ouranos::private(objet)
      pack $frm.rad2 -in $frm.frame5 -anchor center -side left -padx 30
      #--- Bouton radio IC
      radiobutton $frm.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
         -text "$caption(ouranos,ic)" -value 3 -variable ::ouranos::private(objet)
      pack $frm.rad3 -in $frm.frame5 -anchor center -side left -padx 30
   }

   #--- Site web officiel d'Ouranos
   label $frm.lab103 -text "$caption(ouranos,titre_site_web)"
   pack $frm.lab103 -in $frm.frame6 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame6 "$caption(ouranos,site_ouranos)" \
      "$caption(ouranos,site_ouranos)" ]
   pack $labelName -side top -fill x -pady 2

   #---
   if [ winfo exists $audace(base).tjrsvisible ] {
      set ::ouranos::private(tjrsvisible) "1"
   }
   if { $::OuranosCom::private(lecture) == "1" } {
      #--- Traitement graphique du bouton 'Lire'
      $frm.but_read configure -text "$caption(ouranos,lire)" -relief groove -state disabled
      #--- Traitement graphique du bouton 'Regler'
      $frm.but_init configure -text "$caption(ouranos,reglage)" -state disabled
      if { $private(show_coord) == "1" } {
         #--- Bouton MATCH avec entry actif
         $frm.but_match configure -text "$caption(ouranos,match)" -state normal
      } else {
         #--- Bouton MATCH avec entry inactif
         $frm.but_match configure -text "$caption(ouranos,match)" -state disabled
      }
   }
}

#
# ::ouranos::configureMonture
#    Configure la monture Ouranos en fonction des donnees contenues dans les variables conf(ouranos,...)
#
proc ::ouranos::configureMonture { } {
   variable private
   global audace caption conf

   #--- Initialisation
   set conf(raquette) "0"
   #--- Je cree la monture
   set telNo [ tel::create ouranos $conf(ouranos,port) -resol_ra $conf(ouranos,cod_ra) \
      -resol_dec $conf(ouranos,cod_dec) -initial_dec $conf(ouranos,init) ]
   #--- J'initialise la position de l'observateur
   tel$telNo home $::audace(posobs,observateur,gps)
   #--- J'initialise le sens de rotation des codeurs
   tel$telNo invert $conf(ouranos,inv_ra) $conf(ouranos,inv_dec)
   #--- J'affiche un message d'information dans la Console
   console::affiche_erreur "$caption(ouranos,port_ouranos) $caption(ouranos,2points)\
      $conf(ouranos,port)\n"
   console::affiche_erreur "$caption(ouranos,res_codeurs)\n"
   console::affiche_erreur "$caption(ouranos,ra) $caption(ouranos,2points)\
      $conf(ouranos,cod_ra) $caption(ouranos,pas) $caption(ouranos,et) $caption(ouranos,dec)\
      $caption(ouranos,2points) $conf(ouranos,cod_dec) $caption(ouranos,pas)\n"
   console::affiche_saut "\n"
   #--- Je nettoye l'affichage les codeurs
   set private(coord_ra)  ""
   set private(coord_dec) ""
   #--- J'affiche le statut du port
   set private(status) $caption(ouranos,on)
   #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
   set linkNo [ ::confLink::create $conf(ouranos,port) "tel$telNo" "control" [ tel$telNo product ] ]
   #--- Je change de variable
   set private(telNo) $telNo
   #--- Gestion des boutons actifs/inactifs
   ::ouranos::confOuranos
   ::ouranos::matchOuranos

   #--- Si Ouranos est une monture secondaire, c'est AudeCom qui specifie l'utilisation de la raquette
   if { [ ::confTel::hasSecondaryMount ] == "1" } {
      set conf(raquette) $::audecom::private(raquette)
   }
}

#
# ::ouranos::stop
#    Arrete la monture Ouranos
#
proc ::ouranos::stop { } {
   variable private

   #--- Gestion du bouton actif/inactif
   ::ouranos::confOuranosInactif

   #--- Fermeture de la communication
   ::OuranosCom::close_com

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
# ::ouranos::confOuranos
# Permet d'activer ou de d�sactiver les radio-boutons 'Etoiles', 'Messier', 'NGC' et 'IC'
# ainsi que les boutons 'Regler', 'Stopper' et 'Lire'
#
proc ::ouranos::confOuranos { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::ouranos::isReady ] == 1 } {
            #--- Boutons de la monture actifs
            $frm.but_init configure -relief raised -state normal -command { ::OuranosCom::find_res }
            $frm.but_close configure -relief raised -state normal -command { ::OuranosCom::close_com }
            $frm.but_read configure -relief raised -state normal -command { ::OuranosCom::go_ouranos }
            if { $private(show_coord) == "1" } {
               #--- Radio-boutons de la monture actifs
               $frm.rad0 configure -state normal -command {
                     set ::ouranos::private(obj_choisi) $caption(ouranos,etoile)
                     ::cataGoto::CataEtoiles
                  }
               $frm.rad1 configure -state normal -command {
                     set ::ouranos::private(obj_choisi) $caption(ouranos,messier)
                     ::cataGoto::CataObjet $caption(ouranos,messier)
                  }
               $frm.rad2 configure -state normal -command {
                     set ::ouranos::private(obj_choisi) $caption(ouranos,ngc)
                     ::cataGoto::CataObjet $caption(ouranos,ngc)
                  }
               $frm.rad3 configure -state normal -command {
                     set ::ouranos::private(obj_choisi) $caption(ouranos,ic)
                     ::cataGoto::CataObjet $caption(ouranos,ic)
                  }
            } else {
               #--- Radio-boutons de la monture inactifs
               $frm.rad0 configure -state disabled
               $frm.rad1 configure -state disabled
               $frm.rad2 configure -state disabled
               $frm.rad3 configure -state disabled
            }
         } else {
            #--- Boutons de la monture inactifs
            $frm.but_init configure -state disabled
            $frm.but_close configure -state disabled
            $frm.but_read configure -state disabled
            #--- Radio-boutons de la monture inactifs
            $frm.rad0 configure -state disabled
            $frm.rad1 configure -state disabled
            $frm.rad2 configure -state disabled
            $frm.rad3 configure -state disabled
         }
      }
   }
}

#
# ::ouranos::confOuranosInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::ouranos::confOuranosInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::ouranos::isReady ] == 1 } {
            #--- Boutons de la monture inactifs
            $frm.but_init configure -state disabled
            $frm.but_close configure -state disabled
            $frm.but_read configure -state disabled
            #--- Radio-boutons de la monture inactifs
            $frm.rad0 configure -state disabled
            $frm.rad1 configure -state disabled
            $frm.rad2 configure -state disabled
            $frm.rad3 configure -state disabled
         }
      }
   }
}

#
# ::ouranos::matchOuranos
# Permet de gerer l'affichage du bouton MATCH d'Ouranos et des informations associes
# ainsi que le transfert des coordonnees pour MATCH
#
proc ::ouranos::matchOuranos { } {
   variable private
   global audace caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         destroy $frm.match_ra
         destroy $frm.match_ra_entry
         destroy $frm.match_dec
         destroy $frm.match_dec_entry
         #---
         if { $private(show_coord) == "1" } {
            if { $::OuranosCom::private(lecture) == "0" } {
               #--- Bouton MATCH avec entry inactif
               $frm.but_match configure -state disabled
            } else {
               #--- Bouton MATCH avec entry actif
               $frm.but_match configure -text "$caption(ouranos,match)" -width 8 -state normal \
                  -command { ::OuranosCom::match_ouranos }
            }
            #--- Valeur Dec. en � ' "
            entry $frm.match_dec_entry -textvariable ::ouranos::private(match_dec) -justify center -width 12
            pack $frm.match_dec_entry -in $frm.frame4 -anchor center -side right -padx 10
            #--- Commentaires Dec.
            label $frm.match_dec -text "$caption(ouranos,dec) $caption(ouranos,dms_angle)"
            pack $frm.match_dec -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements Dec.
            bind $frm.match_dec_entry <Enter> { ::ouranos::formatMatchDec }
            bind $frm.match_dec_entry <Leave> { destroy $audace(base).format_match_dec }
            #--- Valeur AD en h mn s
            entry $frm.match_ra_entry -textvariable ::ouranos::private(match_ra) -justify center -width 12
            pack $frm.match_ra_entry -in $frm.frame4 -anchor center -side right -padx 10
            #--- Commentaires AD
            label $frm.match_ra -text "$caption(ouranos,ra) $caption(ouranos,hms_angle)"
            pack $frm.match_ra -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements AD
            bind $frm.match_ra_entry <Enter> { ::ouranos::formatMatchAD }
            bind $frm.match_ra_entry <Leave> { destroy $audace(base).format_match_ad }
         } else {
            #--- Bouton MATCH sans entry inactif
            $frm.but_match configure -state disabled
         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   }
}

#
# ::ouranos::confRadioBouton
# Permet d'activer ou de d�sactiver les radio-boutons 'Etoiles', 'Messier', 'NGC' et 'IC'
#
proc ::ouranos::confRadioBouton { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { ( [ ::ouranos::isReady ] == 1 ) && ( $private(show_coord) == "1" ) } {
            #--- Radio-boutons de la monture actifs
            $frm.rad0 configure -state normal -command {
                  set ::ouranos::private(obj_choisi) $caption(ouranos,etoile)
                  ::cataGoto::CataEtoiles
               }
            $frm.rad1 configure -state normal -command {
                  set ::ouranos::private(obj_choisi) $caption(ouranos,messier)
                  ::cataGoto::CataObjet $caption(ouranos,messier)
               }
            $frm.rad2 configure -state normal -command {
                  set ::ouranos::private(obj_choisi) $caption(ouranos,ngc)
                  ::cataGoto::CataObjet $caption(ouranos,ngc)
               }
            $frm.rad3 configure -state normal -command {
                  set ::ouranos::private(obj_choisi) $caption(ouranos,ic)
                  ::cataGoto::CataObjet $caption(ouranos,ic)
               }
         } else {
            #--- Radio-boutons de la monture inactifs
            $frm.rad0 configure -state disabled
            $frm.rad1 configure -state disabled
            $frm.rad2 configure -state disabled
            $frm.rad3 configure -state disabled
         }
      }
   }
}

#
# ::ouranos::formatMatchAD
# Definit le format en entree de l'AD pour MATCH d'Ouranos
#
proc ::ouranos::formatMatchAD { } {
   global audace caption

   if [ winfo exists $audace(base).format_match_ad ] {
      destroy $audace(base).format_match_ad
   }
   toplevel $audace(base).format_match_ad
   wm transient $audace(base).format_match_ad $audace(base).confTel
   wm title $audace(base).format_match_ad "$caption(ouranos,attention)"
   set posx_format_match_ad [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_format_match_ad [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $audace(base).format_match_ad +[ expr $posx_format_match_ad + 60 ]+[ expr $posy_format_match_ad + 220 ]
   wm resizable $audace(base).format_match_ad 0 0

   #--- Cree l'affichage du message
   label $audace(base).format_match_ad.lab1 -text "$caption(ouranos,formataddec1)"
   pack $audace(base).format_match_ad.lab1 -padx 10 -pady 2
   label $audace(base).format_match_ad.lab2 -text "$caption(ouranos,formataddec2)"
   pack $audace(base).format_match_ad.lab2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).format_match_ad

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).format_match_ad
}

#
# ::ouranos::formatMatchDec
# Definit le format en entree de la Dec pour MATCH d'Ouranos
#
proc ::ouranos::formatMatchDec { } {
   global audace caption

   if [ winfo exists $audace(base).format_match_dec ] {
      destroy $audace(base).format_match_dec
   }
   toplevel $audace(base).format_match_dec
   wm transient $audace(base).format_match_dec $audace(base).confTel
   wm title $audace(base).format_match_dec "$caption(ouranos,attention)"
   set posx_format_match_dec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_format_match_dec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $audace(base).format_match_dec +[ expr $posx_format_match_dec + 254 ]+[ expr $posy_format_match_dec + 197 ]
   wm resizable $audace(base).format_match_dec 0 0

   #--- Cree l'affichage du message
   label $audace(base).format_match_dec.lab3 -text "$caption(ouranos,formataddec3)"
   pack $audace(base).format_match_dec.lab3 -padx 10 -pady 2
   label $audace(base).format_match_dec.lab4 -text "$caption(ouranos,formataddec4)"
   pack $audace(base).format_match_dec.lab4 -padx 10 -pady 2
   label $audace(base).format_match_dec.lab5 -text "$caption(ouranos,formataddec5)"
   pack $audace(base).format_match_dec.lab5 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).format_match_dec

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).format_match_dec
}

#
# ::ouranos::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# multiMountOuranos       Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
# name                    Retourne le modele de la monture
# product                 Retourne le nom du produit
# hasCoordinates          Retourne la possibilite d'afficher les coordonnees
# hasGoto                 Retourne la possibilite de faire un Goto
# hasMatch                Retourne la possibilite de faire un Match
# hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
# hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
# hasCorrectionRefraction Retourne la possibilite de calculer les corrections de refraction
# mechanicalPlay          Retourne la possibilite de faire un rattrapage des jeux
#
proc ::ouranos::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMountOuranos       { return 0 }
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
      hasGoto                 { return 0 }
      hasMatch                { return 1 }
      hasManualMotion         { return 0 }
      hasControlSuivi         { return 0 }
      hasCorrectionRefraction { return 0 }
      mechanicalPlay          { return 0 }
   }
}

