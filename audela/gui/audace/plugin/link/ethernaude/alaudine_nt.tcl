#
# Fichier : alaudine_nt.tcl
# Description : Permet de controler l'alimentation AlAudine NT avec port I2C
# Auteur : Robert DELMAS
# Mise a jour $Id: alaudine_nt.tcl,v 1.8 2006-10-07 10:27:17 robertdelmas Exp $
#

namespace eval AlAudine_NT {
   variable This
   global AlAudine_NT

   #
   # AlAudine_NT::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      ::AlAudine_NT::AlAudine_NTDispTemp
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
      global conf
      global confCam

      set confCam(alaudine_nt,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $confCam(alaudine_nt,geometry) ] ]
      set fin [ string length $confCam(alaudine_nt,geometry) ]
      set confCam(alaudine_nt,position) "+[ string range $confCam(alaudine_nt,geometry) $deb $fin ]"
      #---
      set conf(alaudine_nt,position) $confCam(alaudine_nt,position)
   }

   proc createDialog { } {
      variable This
      global audace
      global color
      global conf
      global confCam
      global caption

      #--- initConf
      if { ! [ info exists conf(alaudine_nt,position) ] }          { set conf(alaudine_nt,position)          "+600+490" }
      if { ! [ info exists conf(alaudine_nt,evaluation) ] }        { set conf(alaudine_nt,evaluation)        "25.0" }
      if { ! [ info exists conf(alaudine_nt,delta_t_max) ] }       { set conf(alaudine_nt,delta_t_max)       "30.0" }
      set t_ccd [ expr $conf(alaudine_nt,evaluation) - $conf(alaudine_nt,delta_t_max) / 2. ]
      if { ! [ info exists conf(alaudine_nt,temp_ccd_souhaite) ] } { set conf(alaudine_nt,temp_ccd_souhaite) "$t_ccd" }

      #--- confToWidget
      set confCam(alaudine_nt,evaluation)        $conf(alaudine_nt,evaluation)
      set confCam(alaudine_nt,delta_t_max)       $conf(alaudine_nt,delta_t_max)
      set confCam(alaudine_nt,temp_ccd_souhaite) $conf(alaudine_nt,temp_ccd_souhaite)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #---
      set confCam(alaudine_nt,position) $conf(alaudine_nt,position)
      #---
      if { [ info exists confCam(alaudine_nt,geometry) ] } {
         set deb [ expr 1 + [ string first + $confCam(alaudine_nt,geometry) ] ]
         set fin [ string length $confCam(alaudine_nt,geometry) ]
         set confCam(alaudine_nt,position) "+[ string range $confCam(alaudine_nt,geometry) $deb $fin ]"
      }

      #--- Chargement des captions
      uplevel #0 "source \"[ file join $audace(rep_plugin) link ethernaude alaudine_nt.cap ]\""

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(alaudine_nt,titre)
      wm geometry $This $confCam(alaudine_nt,position)
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

      entry $This.temp_amb -textvariable confCam(alaudine_nt,evaluation) -width 5 -justify center
      pack $This.temp_amb -in $This.frame3 -anchor center -side left -padx 0 -pady 5

      label $This.lab2 -text "$caption(alaudine_nt,degres)"
      pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

      #--- Delta t maximum possible
      label $This.lab3 -text "$caption(alaudine_nt,delta_t)"
      pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

      entry $This.delta_t_max -textvariable confCam(alaudine_nt,delta_t_max) -width 5 -justify center
      pack $This.delta_t_max -in $This.frame4 -anchor center -side left -padx 0 -pady 5

      label $This.lab4 -text "$caption(alaudine_nt,degres)"
      pack $This.lab4 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

      #--- Temperatures minimale et maximale possibles
      set tmp_ccd_max $confCam(alaudine_nt,evaluation)
      set tmp_ccd_min [ expr $confCam(alaudine_nt,evaluation) - $confCam(alaudine_nt,delta_t_max) ]

      #--- Temperature du CCD souhaitée avec la glissière de reglage
      label $This.lab5 -text "$caption(alaudine_nt,temp_ccd_souhaite)"
      pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

      scale $This.temp_ccd_souhaite_variant -from $tmp_ccd_min -to $tmp_ccd_max -length 300 \
         -orient horizontal -showvalue true -tickinterval 5 -resolution 0.1 \
         -borderwidth 2 -relief groove -variable confCam(alaudine_nt,temp_ccd_souhaite) -width 10 \
         -command { ::AlAudine_NT::ReglageTemp }
      pack $This.temp_ccd_souhaite_variant -in $This.frame6 -anchor center -side left -padx 5 -pady 0

      entry $This.temp_ccd_souhaite -textvariable confCam(alaudine_nt,temp_ccd_souhaite) -width 5 -justify center
      pack $This.temp_ccd_souhaite -in $This.frame6 -anchor center -side left -padx 0 -pady 0

      label $This.lab6 -text "$caption(alaudine_nt,degres)"
      pack $This.lab6 -in $This.frame6 -anchor center -side left -padx 5 -pady 0

      #--- Temperature du CCD mesurée
      label $This.lab7 -text "$caption(alaudine_nt,temp_ccd_mesure)"
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
      if { [ info exists confCam(alaudine_nt,aftertemp) ] == "0" } {
         ::AlAudine_NT::AlAudine_NTDispTemp
      }

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # AlAudine_NT::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confCam

      #--- Memorise la configuration de l'AlAudine NT dans le tableau conf(alaudine_nt,...)
      set conf(alaudine_nt,evaluation)        $confCam(alaudine_nt,evaluation)
      set conf(alaudine_nt,delta_t_max)       $confCam(alaudine_nt,delta_t_max)
      set conf(alaudine_nt,temp_ccd_souhaite) $confCam(alaudine_nt,temp_ccd_souhaite)
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
   # AlAudine_NT::ReglageTemp
   # Fonction pour regler la temperature du CCD via l'AlAudine NT
   #
   proc ReglageTemp { temp_ccd_souhaite } {
      global confCam

      set camNo $confCam($confCam(cam_item),camNo)
      cam$camNo cooler check $temp_ccd_souhaite
   }

   #
   # AlAudine_NT::AlAudine_NTDispTemp
   # Fonction de mesure de la temperature reelle du CCD via l'AlAudine NT
   #
   proc AlAudine_NTDispTemp { } {
      variable This
      global audace
      global caption
      global confCam

      catch {
         #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
         set camNo $confCam($confCam(cam_item),camNo)
         set statusVariableName "::status_cam$camNo"
         if { [set $statusVariableName] == "exp" } {
            #--- Si on lit une image de la camera, il ne faut pas lire la temperature
            set confCam(alaudine_nt,aftertemp) [ after 5000 ::AlAudine_NT::AlAudine_NTDispTemp ]
         } else {
            if { [ info exists This ] == "1" && [ catch { set temp_ccd_mesure [ cam$confCam($confCam(cam_item),camNo) temperature ] } ] == "0" } {
               set temp_ccd_mesure [ format "%+5.1f" $temp_ccd_mesure ]
               $This.lab7 configure \
                  -text "$caption(alaudine_nt,temp_ccd_mesure) $temp_ccd_mesure $caption(alaudine_nt,degres)"
               set confCam(alaudine_nt,aftertemp) [ after 5000 ::AlAudine_NT::AlAudine_NTDispTemp ]
            } else {
               catch { unset confCam(alaudine_nt,aftertemp) }
            }
         }
      }
   }
}

