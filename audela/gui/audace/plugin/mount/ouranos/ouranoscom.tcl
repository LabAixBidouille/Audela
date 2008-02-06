#
# Fichier : ouranoscom.tcl
# Description : Script dedie a l'interface Ouranos de Patrick DUFOUR
# Auteurs : Raymond ZACHANTKE et Robert DELMAS
# Mise a jour $Id: ouranoscom.tcl,v 1.12 2008-02-06 22:53:36 robertdelmas Exp $
#

namespace eval OuranosCom {
}

#
# ::OuranosCom::init (est lance automatiquement au chargement de ce fichier tcl)
# Initialise les variables private(...) et caption(...)
#
proc ::OuranosCom::init { } {
   variable private
   global audace

   #--- Initialisation de variables
   set private(lecture) "0"
   set private(find)    "0"

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) mount ouranos ouranoscom.cap ]
}

#
# ::OuranosCom::init_ouranos
# Initialisation de variables
#
proc ::OuranosCom::init_ouranos { } {
   variable private
   global caption conf

   #--- Initialisation de l'affichage du statut
   set ::ouranos::private(status)      $caption(ouranoscom,off)

   #--- Initialisation de variables
   set ::ouranos::private(cod_ra)      $conf(ouranos,cod_ra)
   set ::ouranos::private(cod_dec)     $conf(ouranos,cod_dec)
   set ::ouranos::private(freq)        $conf(ouranos,freq)
   set ::ouranos::private(init)        $conf(ouranos,init)
   set ::ouranos::private(inv_ra)      $conf(ouranos,inv_ra)
   set ::ouranos::private(inv_dec)     $conf(ouranos,inv_dec)
   set ::ouranos::private(show_coord)  $conf(ouranos,show_coord)
   set ::ouranos::private(tjrsvisible) $conf(ouranos,tjrsvisible)
}

#
# ::OuranosCom::find_res
# Recherche la resolution des 2 codeurs
#
proc ::OuranosCom::find_res { } {
   variable private
   global audace

   #--- Effacement des fenetres auxiliaires
   set ::ouranos::private(tjrsvisible) "0"
   if { [ winfo exists $audace(base).tjrsvisible ] } {
      destroy $audace(base).tjrsvisible
   }
   if { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
      destroy $audace(base).tjrsvisible_x10
   }

   #--- Initialisation de variables
   set frm $::ouranos::private(frm)
   set private(lecture)               "1"
   set private(find)                  "1"
   set ::ouranos::private(init)       "0"
   set ::ouranos::private(inv_ra)     "1"
   set ::ouranos::private(inv_dec)    "1"
   set ::ouranos::private(show_coord) "0"

   #--- Traitement graphique des boutons 'Lire' et 'Regler' et du checkbutton 'Coordonnees'
   $frm.but_read configure -state disabled
   $frm.but_init configure -relief groove -state disabled
   $frm.unites configure -state disabled
   $frm.visible configure -state disabled
   $frm.invra configure -state disabled
   $frm.invdec configure -state disabled

   #--- Configuration des informations associees au bouton MATCH
   ::ouranos::matchOuranos

   #--- Initialisation des sens de rotation des codeurs
   tel$::ouranos::private(telNo) invert $::ouranos::private(inv_ra) $::ouranos::private(inv_dec)

   #--- Initialisation du microcontroleur de l'interface
   #--- Commande equivalente aux 2 commandes suivantes :
   #--- R 65536 65536
   #--- I 0 0
   tel$::ouranos::private(telNo) adjust

   #--- Lecture et affichage des coordonnées
   ::OuranosCom::read_coord
}

#
# ::OuranosCom::close_com
# Ferme le port serie s'il n'est pas deja ferme
#
proc ::OuranosCom::close_com { } {
   variable private
   global audace caption conf

   #--- Initialisation de variables
   set private(lecture) "0"
   set private(find)    "0"
   #--- Effacement des fenetres auxiliaires
   set ::ouranos::private(tjrsvisible) "0"
   if { [ winfo exists $audace(base).tjrsvisible ] } {
      destroy $audace(base).tjrsvisible
   }
   if { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
      destroy $audace(base).tjrsvisible_x10
   }
   #--- Traitement des autres widgets
   if { [ info exists ::ouranos::private(frm) ] } {
      set frm $::ouranos::private(frm)
      if { [ winfo exists $frm ] } {
         #--- Traitement graphique des boutons 'Lire' et 'Regler' et du checkbutton 'Coordonnees'
         $frm.but_read configure -relief raised -state normal
         $frm.but_init configure -relief raised -state normal
         $frm.unites configure -state normal
         $frm.visible configure -state normal
         $frm.invra configure -state normal
         $frm.invdec configure -state normal
         #--- Traitement graphique du bouton 'MATCH'
         if { $::ouranos::private(show_coord) == "1" } {
            #--- Bouton MATCH avec entry inactif
            $frm.but_match configure -text "$caption(ouranoscom,match)" -width 8 -state disabled \
               -command { ::OuranosCom::match_ouranos }
         }
         #--- Effacement du contenu des labels et des entry
         set ::ouranos::private(match_ra)  ""
         set ::ouranos::private(match_dec) ""
         destroy $frm.match_ra
         destroy $frm.match_dec
         destroy $frm.match_ra_entry
         destroy $frm.match_dec_entry
         if { ( $::ouranos::private(show_coord) == "1" ) && ( $conf(ouranos,show_coord) == "1" ) } {
            #--- Valeur Dec. en ° ' "
            entry $frm.match_dec_entry -textvariable ::ouranos::private(match_dec) -justify center -width 12
            pack $frm.match_dec_entry -in $frm.frame4 -anchor center -side right -padx 10
            #--- Commentaires Dec.
            label $frm.match_dec -text "$caption(ouranoscom,dec1) $caption(ouranoscom,dms_angle)"
            pack $frm.match_dec -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements Dec.
            bind $frm.match_dec_entry <Enter> { ::ouranos::formatMatchDec }
            bind $frm.match_dec_entry <Leave> { destroy $audace(base).format_match_dec }
            #--- Valeur AD en h mn s
            entry $frm.match_ra_entry -textvariable ::ouranos::private(match_ra) -justify center -width 12
            pack $frm.match_ra_entry -in $frm.frame4 -anchor center -side right -padx 10
            #--- Commentaires AD
            label $frm.match_ra -text "$caption(ouranoscom,ad1) $caption(ouranoscom,hms_angle)"
            pack $frm.match_ra -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements AD
            bind $frm.match_ra_entry <Enter> { ::ouranos::formatMatchAD }
            bind $frm.match_ra_entry <Leave> { destroy $audace(base).format_match_ad }
         }
         #--- Boutons et radio-boutons inactifs
         $frm.but_init configure -state disabled
         $frm.but_close configure -state disabled
         $frm.but_read configure -state disabled
         $frm.rad0 configure -state disabled
         $frm.rad1 configure -state disabled
         $frm.rad2 configure -state disabled
         $frm.rad3 configure -state disabled
      }
   }
   #--- Effacement des coordonnees AD et Dec.
   set ::ouranos::private(coord_ra)  ""
   set ::ouranos::private(coord_dec) ""
   #--- Fermeture du port et affichage du status
   tel$::ouranos::private(telNo) close
   set ::ouranos::private(status) $caption(ouranoscom,off)
   console::affiche_erreur "$caption(ouranoscom,port) ($conf(ouranos,port))\
      $caption(ouranoscom,2points) $caption(ouranoscom,ferme)\n\n"
}

#
# ::OuranosCom::go_ouranos
# Lance la lecture des 2 codeurs
#
proc ::OuranosCom::go_ouranos { } {
   variable private
   global caption

   #--- Initialisation de variables
   set frm $::ouranos::private(frm)
   set private(lecture) "1"
   #--- Traitement graphique des boutons 'Lire' et 'Regler'
   $frm.but_read configure -relief groove -state disabled
   $frm.but_init configure -state disabled
   #--- Traitement graphique du bouton 'MATCH'
   if { $::ouranos::private(show_coord) == "1" } {
      #--- Bouton MATCH avec entry actif
      $frm.but_match configure -text "$caption(ouranoscom,match)" -width 8 -state normal \
         -command { ::OuranosCom::match_ouranos }
   }
   #--- Lecture et affichage des coordonnées
   ::OuranosCom::read_coord
}

#
# ::OuranosCom::match_ouranos
# Synchronise l'interface avec l'objet pointe (commande Match)
#
proc ::OuranosCom::match_ouranos { } {
   variable private

   if { [ ::confTel::hasSecondaryMount ] == "0" } {
      #--- Envoie le Match a l'interface Ouranos
      tel$::ouranos::private(telNo) radec init { $::ouranos::private(match_ra) $::ouranos::private(match_dec) }
   } else {
      #--- Si Ouranos est une monture secondaire, envoie egalement le Match a la monture principale
      ::telescope::match { $::ouranos::private(match_ra) $::ouranos::private(match_dec) }

   }
}

#
# ::OuranosCom::match_transfert_ouranos
# Transfert des coordonnees pour le bouton MATCH
#
proc ::OuranosCom::match_transfert_ouranos { } {
   variable private
   global caption catalogue

   set frm $::ouranos::private(frm)
   if { $::ouranos::private(obj_choisi) == "$caption(ouranoscom,messier)" } {
      set ::ouranos::private(match_ra) $catalogue(objet_ad)
      $frm.match_ra_entry configure -textvariable ::ouranos::private(match_ra)
      set ::ouranos::private(match_dec) $catalogue(objet_dec)
      $frm.match_dec_entry configure -textvariable ::ouranos::private(match_dec)
   } elseif { $::ouranos::private(obj_choisi) == "$caption(ouranoscom,ngc)" } {
      set ::ouranos::private(match_ra) $catalogue(objet_ad)
      $frm.match_ra_entry configure -textvariable ::ouranos::private(match_ra)
      set ::ouranos::private(match_dec) $catalogue(objet_dec)
      $frm.match_dec_entry configure -textvariable ::ouranos::private(match_dec)
   } elseif { $::ouranos::private(obj_choisi) == "$caption(ouranoscom,ic)" } {
      set ::ouranos::private(match_ra) $catalogue(objet_ad)
      $frm.match_ra_entry configure -textvariable ::ouranos::private(match_ra)
      set ::ouranos::private(match_dec) $catalogue(objet_dec)
      $frm.match_dec_entry configure -textvariable ::ouranos::private(match_dec)
   } elseif { $::ouranos::private(obj_choisi) == "$caption(ouranoscom,etoile)" } {
      set ::ouranos::private(match_ra) $catalogue(etoile_ad)
      $frm.match_ra_entry configure -textvariable ::ouranos::private(match_ra)
      set ::ouranos::private(match_dec) $catalogue(etoile_dec)
      $frm.match_dec_entry configure -textvariable ::ouranos::private(match_dec)
   }
   set ::ouranos::private(objet) "4"
}

#
# ::OuranosCom::read_coord
# Lecture des 2 codeurs et affichage des positions
#
proc ::OuranosCom::read_coord { } {
   variable private
   global audace caption

   #--- Affichage dans l'onglet Ouranos
   if { $private(find) == "0" } {
      ::OuranosCom::show1
   } else {
      ::OuranosCom::show2
   }
   #--- Affichage dans la boite auxiliaire
   if { $::ouranos::private(tjrsvisible) == "1" } {
      if { [ winfo exists $audace(base).tjrsvisible ] } {
         $audace(base).tjrsvisible.lab1 configure -text "$caption(ouranoscom,ad) $::ouranos::private(coord_ra)"
         $audace(base).tjrsvisible.lab2 configure -text "$caption(ouranoscom,dec) $::ouranos::private(coord_dec)"
      }
      if { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
         $audace(base).tjrsvisible_x10.lab1 configure -text "$caption(ouranoscom,ad)\n$::ouranos::private(coord_ra)"
         $audace(base).tjrsvisible_x10.lab2 configure -text "$caption(ouranoscom,dec)\n$::ouranos::private(coord_dec)"
      }
   } else {
      destroy $audace(base).tjrsvisible
      destroy $audace(base).tjrsvisible_x10
   }
   #--- Et on recommence...
   if { $private(lecture) == "1" } {
      after [ expr $::ouranos::private(freq)*1000 ] ::OuranosCom::read_coord
   } else {
      #--- Effacement des coordonnees AD et Dec.
      set ::ouranos::private(coord_ra)  ""
      set ::ouranos::private(coord_dec) ""
   }
}

#
# ::OuranosCom::show1
# Affichage en mode lecture (pas codeurs ou coordonnees)
#
proc ::OuranosCom::show1 { } {
   variable private
   global audace caption

   if { $::ouranos::private(telNo) == "0" } {
      return
   }
   if { $private(lecture) == "0" } {
      #--- Coordonnees AD et Dec. invisibles
      set ::ouranos::private(coord_ra)  ""
      set ::ouranos::private(coord_dec) ""
      return
   }
   if { $::ouranos::private(show_coord) == "0" } {
      #--- Affichage en mode pas codeurs
      set pas_encod [ tel$::ouranos::private(telNo) nbticks ]
      set ::ouranos::private(coord_ra)  "[ lindex $pas_encod 0 ] $caption(ouranoscom,pas)"
      set ::ouranos::private(coord_dec) "[ lindex $pas_encod 1 ] $caption(ouranoscom,pas)"
   } else {
      if { [ ::confTel::hasSecondaryMount ] == "0" } {
         #--- Affichage en mode coordonnees pour la monture principale
         ::telescope::afficheCoord
         set ::ouranos::private(coord_ra)  $audace(telescope,getra)
         set ::ouranos::private(coord_dec) $audace(telescope,getdec)
      } else {
         #--- Affichage en mode coordonnees pour la monture secondaire
         set radec [ tel$::ouranos::private(telNo) radec coord ]
         set ::ouranos::private(coord_ra)  [ lindex $radec 0 ]
         set ::ouranos::private(coord_dec) [ lindex $radec 1 ]
      }
   }
}

#
# ::OuranosCom::show2
# Affichage des pas codeurs en mode reglage
#
proc ::OuranosCom::show2 { } {
   variable private

   if { $::ouranos::private(telNo) == "0" } {
      return
   }
   set coords [ tel$::ouranos::private(telNo) nbticks ]

   set dec_enc [ format "%g" [ lindex $coords 1 ] ]
   set ra_enc  [ format "%g" [ lindex $coords 0 ] ]
   set dec_enc [ expr $::ouranos::private(inv_dec)*$dec_enc ]
   set ra_enc  [ expr $::ouranos::private(inv_ra)*$ra_enc ]
   if { [ expr abs($dec_enc)-32768 ] > "0" } {
      set dec_enc [ expr 65536-[ expr abs($dec_enc) ] ]
      set ::ouranos::private(inv_dec) "-1"
   }
   if { [ expr abs($ra_enc)-32768 ] > "0" } {
      set ra_enc [ expr 65536-[ expr abs($ra_enc) ] ]
      set ::ouranos::private(inv_ra) "-1"
   }
   set ::ouranos::private(cod_dec) $dec_enc
   set ::ouranos::private(cod_ra)  $ra_enc
}

#
# ::OuranosCom::tjrsVisible
# Affichage visible des coordonnees ou des pas en petit
#
proc ::OuranosCom::tjrsVisible { } {
   variable private
   global audace caption conf

   if { $::ouranos::private(tjrsvisible) == "0" } {
      destroy $audace(base).tjrsvisible
   } else {
      if { [ winfo exists $audace(base).tjrsvisible ] } {
         destroy $audace(base).tjrsvisible
      }
      toplevel $audace(base).tjrsvisible
      wm transient $audace(base).tjrsvisible $audace(base)
      wm resizable $audace(base).tjrsvisible 0 0
      wm title $audace(base).tjrsvisible "$caption(ouranoscom,pos_tel)"
      wm protocol $audace(base).tjrsvisible WM_DELETE_WINDOW {
         set ::ouranos::private(tjrsvisible) "0"
         destroy $audace(base).tjrsvisible
      }
      if { [ info exists conf(ouranos,wmgeometry) ] == "1" } {
         wm geometry $audace(base).tjrsvisible $conf(ouranos,wmgeometry)
      } else {
         wm geometry $audace(base).tjrsvisible 200x70+370+375
      }

      #--- Cree l'affichage d'AD et Dec
      label $audace(base).tjrsvisible.lab1 -borderwidth 1 -anchor w
      pack $audace(base).tjrsvisible.lab1 -padx 10 -pady 2
      label $audace(base).tjrsvisible.lab2 -borderwidth 1 -anchor w
      pack $audace(base).tjrsvisible.lab2 -padx 10 -pady 2

      #--- Bouton radio x1
      radiobutton $audace(base).tjrsvisible.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(ouranoscom,x1)" -value 0 -variable ::ouranos::private(dim) -command {
            destroy $audace(base).tjrsvisible_x10 ; ::OuranosCom::tjrsVisible
         }
      pack $audace(base).tjrsvisible.rad0 -padx 20 -pady 2 -side left
      #--- Bouton radio x10
      radiobutton $audace(base).tjrsvisible.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(ouranoscom,x5)" -value 1 -variable ::ouranos::private(dim) -command {
            destroy $audace(base).tjrsvisible ; ::OuranosCom::tjrsVisibleX10
         }
      pack $audace(base).tjrsvisible.rad1 -padx 20 -pady 2 -side right
      #--- La fenetre est active
      focus $audace(base).tjrsvisible
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).tjrsvisible <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).tjrsvisible
   }
}

#
# ::OuranosCom::tjrsVisibleX10
# Affichage visible des coordonnees ou des pas en gros
#
proc ::OuranosCom::tjrsVisibleX10 { } {
   variable private
   global audace caption conf

   if { $::ouranos::private(tjrsvisible) == "0" } {
      destroy $audace(base).tjrsvisible_x10
   } else {
      if { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
         destroy $audace(base).tjrsvisible_x10
      }
      toplevel $audace(base).tjrsvisible_x10
      wm transient $audace(base).tjrsvisible_x10 $audace(base)
      wm resizable $audace(base).tjrsvisible_x10 0 0
      wm title $audace(base).tjrsvisible_x10 "$caption(ouranoscom,pos_tel)"
      wm protocol $audace(base).tjrsvisible_x10 WM_DELETE_WINDOW {
         set ::ouranos::private(tjrsvisible) "0"
         destroy $audace(base).tjrsvisible_x10
      }
      if { [ info exists conf(ouranos,x10,wmgeometry) ] == "1" } {
         wm geometry $audace(base).tjrsvisible_x10 $conf(ouranos,x10,wmgeometry)
      } else {
         wm geometry $audace(base).tjrsvisible_x10 850x500+0+0
      }

      #--- Cree l'affichage d'AD et Dec
      label $audace(base).tjrsvisible_x10.lab1 -borderwidth 1 -anchor w -font {verdana 60 bold}
      pack $audace(base).tjrsvisible_x10.lab1 -padx 10 -pady 2
      label $audace(base).tjrsvisible_x10.lab2 -borderwidth 1 -anchor w -font {verdana 60 bold}
      pack $audace(base).tjrsvisible_x10.lab2 -padx 10 -pady 2

      #--- Bouton radio x1
      radiobutton $audace(base).tjrsvisible_x10.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -font {verdana 20 bold} -text "$caption(ouranoscom,:5)" -value 0 -variable ::ouranos::private(dim) \
         -command {
            destroy $audace(base).tjrsvisible_x10 ; ::OuranosCom::tjrsVisible
         }
      pack $audace(base).tjrsvisible_x10.rad0 -padx 100 -pady 10 -side left
      #--- Bouton radio x10
      radiobutton $audace(base).tjrsvisible_x10.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -font {verdana 20 bold} -text "$caption(ouranoscom,x1)" -value 1 -variable ::ouranos::private(dim) \
         -command {
            destroy $audace(base).tjrsvisible ; ::OuranosCom::tjrsVisibleX10
         }
      pack $audace(base).tjrsvisible_x10.rad1 -padx 100 -pady 10 -side right
      #--- La fenetre est active
      focus $audace(base).tjrsvisible_x10
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).tjrsvisible_x10 <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).tjrsvisible_x10
   }
}

#--- Chargement au demarrage
::OuranosCom::init

