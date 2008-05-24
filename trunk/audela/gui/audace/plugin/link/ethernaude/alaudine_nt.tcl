#
# Fichier : alaudine_nt.tcl
# Description : Permet de controler l'alimentation AlAudine NT avec port I2C
# Auteur : Robert DELMAS
# Mise a jour $Id: alaudine_nt.tcl,v 1.17 2008-05-24 10:48:43 robertdelmas Exp $
#

namespace eval AlAudine_NT {

   #
   # AlAudine_NT::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # AlAudine_NT::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK'
   #
   proc ok { } {
      variable This

      ::AlAudine_NT::appliquer
      ::AlAudine_NT::recup_position
      destroy $This
   }

   #
   # AlAudine_NT::appliquer
   # Fonction appellee lors de l'appui sur le bouton 'Appliquer'
   #
   proc appliquer { } {
      ::AlAudine_NT::widgetToConf
      ::AlAudine_NT::configureAlAudine_NT
   }

   #
   # AlAudine_NT::afficherAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficherAide { } {
      ::audace::showHelpPlugin link ethernaude "alaudine.htm"
   }

   #
   # AlAudine_NT::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      ::AlAudine_NT::recup_position
      destroy $This
   }

   #
   # AlAudine_NT::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre de configuration de l'alimentation
   #
   proc recup_position { } {
      variable This
      variable private
      global conf

      set private(geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $private(geometry) ] ]
      set fin [ string length $private(geometry) ]
      set private(position) "+[ string range $private(geometry) $deb $fin ]"
      #---
      set conf(alaudine_nt,position) $private(position)
   }

   proc createDialog { } {
      variable This
      variable private
      global audace caption color conf

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) link ethernaude alaudine_nt.cap ]

      #--- initConf
      if { ! [ info exists conf(alaudine_nt,position) ] }          { set conf(alaudine_nt,position)          "+600+490" }
      if { ! [ info exists conf(alaudine_nt,evaluation) ] }        { set conf(alaudine_nt,evaluation)        "25.0" }
      if { ! [ info exists conf(alaudine_nt,delta_t_max) ] }       { set conf(alaudine_nt,delta_t_max)       "30.0" }
      set t_ccd [ expr $conf(alaudine_nt,evaluation) - $conf(alaudine_nt,delta_t_max) / 2. ]
      if { ! [ info exists conf(alaudine_nt,temp_ccd_souhaite) ] } { set conf(alaudine_nt,temp_ccd_souhaite) "$t_ccd" }

      #--- confToWidget
      set private(evaluation)        $conf(alaudine_nt,evaluation)
      set private(delta_t_max)       $conf(alaudine_nt,delta_t_max)
      set private(temp_ccd_souhaite) $conf(alaudine_nt,temp_ccd_souhaite)

      #--- Initialisation
      set private(temp_ccd_mesure)   $caption(alaudine_nt,temp_ccd_mesure)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #---
      set private(position) $conf(alaudine_nt,position)
      #---
      if { [ info exists private(geometry) ] } {
         set deb [ expr 1 + [ string first + $private(geometry) ] ]
         set fin [ string length $private(geometry) ]
         set private(position) "+[ string range $private(geometry) $deb $fin ]"
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm title $This $caption(alaudine_nt,titre)
      wm geometry $This $private(position)
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW ::AlAudine_NT::fermer

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame1 -side top -fill both -expand 1

      #--- Evaluation de la temperature ambiante de la camera CCD
      label $This.lab1 -text "$caption(alaudine_nt,evaluation)"
      pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

      entry $This.temp_amb -textvariable ::AlAudine_NT::private(evaluation) -width 5 -justify center
      pack $This.temp_amb -in $This.frame3 -anchor center -side left -padx 0 -pady 5

      label $This.lab2 -text "$caption(alaudine_nt,degres)"
      pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

      #--- Delta t maximum possible
      label $This.lab3 -text "$caption(alaudine_nt,delta_t)"
      pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

      entry $This.delta_t_max -textvariable ::AlAudine_NT::private(delta_t_max) -width 5 -justify center
      pack $This.delta_t_max -in $This.frame4 -anchor center -side left -padx 0 -pady 5

      label $This.lab4 -text "$caption(alaudine_nt,degres)"
      pack $This.lab4 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

      #--- Temperatures minimale et maximale possibles
      set tmp_ccd_max $private(evaluation)
      set tmp_ccd_min [ expr $private(evaluation) - $private(delta_t_max) ]

      #--- Temperature du CCD souhaitée avec la glissière de reglage
      label $This.lab5 -text "$caption(alaudine_nt,temp_ccd_souhaite)"
      pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

      scale $This.temp_ccd_souhaite_variant -from $tmp_ccd_min -to $tmp_ccd_max -length 300 \
         -orient horizontal -showvalue true -tickinterval 5 -resolution 0.1 \
         -borderwidth 2 -relief groove -variable ::AlAudine_NT::private(temp_ccd_souhaite) -width 10 \
         -command { ::AlAudine_NT::reglageTemp }
      pack $This.temp_ccd_souhaite_variant -in $This.frame6 -anchor center -side left -padx 5 -pady 0

      entry $This.temp_ccd_souhaite -textvariable ::AlAudine_NT::private(temp_ccd_souhaite) -width 5 -justify center
      pack $This.temp_ccd_souhaite -in $This.frame6 -anchor center -side left -padx 0 -pady 0

      label $This.lab6 -text "$caption(alaudine_nt,degres)"
      pack $This.lab6 -in $This.frame6 -anchor center -side left -padx 5 -pady 0

      #--- Temperature du CCD mesurée
      label $This.lab7 -textvariable ::AlAudine_NT::private(temp_ccd_mesure)
      pack $This.lab7 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

      #--- Site web officiel de l'AlAudine
      label $This.lab103 -text "$caption(alaudine_nt,site_web_ref)"
      pack $This.lab103 -in $This.frame8 -side top -fill x -pady 2

      label $This.labURL -text "$caption(alaudine_nt,site_alaudine_nt)" -font $audace(font,url) -fg $color(blue)
      pack $This.labURL -in $This.frame8 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $This.labURL <ButtonPress-1> {
         set filename "$caption(alaudine_nt,site_alaudine_nt)"
         ::audace::Lance_Site_htm $filename
      }
      bind $This.labURL <Enter> {
         $::AlAudine_NT::This.labURL configure -fg $color(purple)
      }
      bind $This.labURL <Leave> {
         $::AlAudine_NT::This.labURL configure -fg $color(blue)
      }

      #--- Cree le bouton 'OK'
      button $This.frame2.ok -text "$caption(alaudine_nt,ok)" -width 7 -command { ::AlAudine_NT::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.frame2.ok -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      #--- Cree le bouton 'Appliquer'
      button $This.frame2.appliquer -text "$caption(alaudine_nt,appliquer)" -width 8 -command { ::AlAudine_NT::appliquer }
      pack $This.frame2.appliquer -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x

      #--- Cree le bouton 'Fermer'
      button $This.frame2.fermer -text "$caption(alaudine_nt,fermer)" -width 7 -command { ::AlAudine_NT::fermer }
      pack $This.frame2.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      #--- Cree le bouton 'Aide'
      button $This.frame2.aide -text "$caption(alaudine_nt,aide)" -width 7 -command { ::AlAudine_NT::afficherAide }
      pack $This.frame2.aide -in $This.frame2 -side right -padx 3 -pady 3 -ipady 5 -fill x

      #--- La fenetre est active
      focus $This

      #---
      if { [ info exists private(aftertemp) ] == "0" } {
         ::AlAudine_NT::dispTempAlAudine_NT
      }

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # AlAudine_NT::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable private
      global conf

      #--- Memorise la configuration de l'AlAudine NT dans le tableau conf(alaudine_nt,...)
      set conf(alaudine_nt,evaluation)        $private(evaluation)
      set conf(alaudine_nt,delta_t_max)       $private(delta_t_max)
      set conf(alaudine_nt,temp_ccd_souhaite) $private(temp_ccd_souhaite)
   }

   #
   # AlAudine_NT::configureAlAudine_NT
   # Configure l'alimentation en fonction des donnees contenues dans le tableau conf :
   # conf(alaudine_nt,...) -> proprietes de ce type de l'alimentation
   #
   proc configureAlAudine_NT { } {
      variable This
      global conf

      #--- Temperatures minimale et maximale possibles
      set tmp_ccd_max $conf(alaudine_nt,evaluation)
      set tmp_ccd_min [ expr $conf(alaudine_nt,evaluation) - $conf(alaudine_nt,delta_t_max) ]
      #--- Configuration de la glissiere de reglage de la temperature
      $This.temp_ccd_souhaite_variant configure -from $tmp_ccd_min -to $tmp_ccd_max
   }

   #
   # AlAudine_NT::reglageTemp
   # Fonction pour regler la temperature du CCD via l'AlAudine NT
   #
   proc reglageTemp { temp_ccd_souhaite } {
      set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]
      if { $camNo != "0" } {
         cam$camNo cooler check $temp_ccd_souhaite
      } else {
         return
      }
   }

   #
   # AlAudine_NT::dispTempAlAudine_NT
   # Fonction de mesure de la temperature reelle du CCD via l'AlAudine NT
   #
   proc dispTempAlAudine_NT { } {
      variable private
      global caption

      #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
      set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]
      if { $camNo != "0" } {
         set statusVariableName "::status_cam$camNo"
      } else {
         if { [ info exists private(aftertemp) ] == "1" } {
            unset private(aftertemp)
         }
         return
      }
      if { [set $statusVariableName] == "exp" } {
         #--- Si on lit une image de la camera, il ne faut pas lire la temperature
         set private(aftertemp) [ after 5000 ::AlAudine_NT::dispTempAlAudine_NT ]
      } else {
         if { [ catch { set temp_ccd_mesure [ cam$camNo temperature ] } ] == "0" } {
            set temp_ccd_mesure [ format "%+5.1f" $temp_ccd_mesure ]
            set private(temp_ccd_mesure) "$caption(alaudine_nt,temp_ccd_mesure) $temp_ccd_mesure $caption(alaudine_nt,degres)"
            set private(aftertemp) [ after 5000 ::AlAudine_NT::dispTempAlAudine_NT ]
         } else {
            set private(temp_ccd_mesure) "$caption(alaudine_nt,temp_ccd_mesure)"
            if { [ info exists private(aftertemp) ] == "1" } {
               unset private(aftertemp)
            }
         }
      }
   }

   #------------------------------------------------------------
   #  addAlAudineNTListener
   #     ajoute une procedure a appeler si on change un parametre
   #
   #  parametres :
   #     cmd : commande TCL a lancer quand la temperature de consigne change
   #------------------------------------------------------------
   proc addAlAudineNTListener { cmd } {
      trace add variable "::conf(alaudine_nt,temp_ccd_souhaite)" write $cmd
   }

   #------------------------------------------------------------
   #  removeAlAudineNTListener
   #     supprime une procedure a appeler si on change un parametre
   #
   #  parametres :
   #     cmd : commande TCL a lancer quand la temperature de consigne change
   #------------------------------------------------------------
   proc removeAlAudineNTListener { cmd } {
      trace remove variable "::conf(alaudine_nt,temp_ccd_souhaite)" write $cmd
   }

}

