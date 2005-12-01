#
# Fichier : lx200pad.tcl
# Description : Raquette virtuelle du LX200
# Auteur : Alain KLOTZ
# Date de mise a jour : 01 janvier 2005
#

package provide lx200pad 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init 			  : initialise le namespace (appelee pendant le chargement de ce source)   
#     getDriverName  	  : retourne le nom du driver
#     getLabel     	  : retourne le nom affichable du driver 
#     getHelp             : retourne la documentation htm associee
#     getDriverType 	  : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf     	  : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()  
#     fillConfigPage 	  : affiche la fenetre de configuration de ce driver 
#     confToWidget   	  : copie le tableau conf() dans les variables des widgets
#     widgetToConf 	  : copie les variables des widgets dans le tableau conf()
#     configureDriver	  : configure le driver et reserve les ressources
#     stopDriver          : arrete le driver et libere les ressources occupees
#     isReady 		  : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :  
#     run         	  : affiche la raquette 
#     startSurveilleSpeed : lance la surveillance de la vitesse
#     surveilleSpeed      : surveillance de la vitesse
#     lx200_set_slew      : vitesse slew
#     lx200_set_find      : vitesse find
#     lx200_set_cntr      : vitesse cntr
#     lx200_set_guide     : vitesse guide
#    

namespace eval ::lx200pad {

   #==============================================================
   # Procedures generiques de configuration des drivers
   #==============================================================
   
   #------------------------------------------------------------
   #  init 
   #     initialise le driver 
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {   
      global audace    

      #--- Charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_plugin) pad lx200pad lx200pad.cap ]\"" 

      #--- Cree les variables dans conf(...) si elles n'existent pas
      initConf

      #--- J'initialise les variables widget(..) 
      confToWidget

      return [namespace current]
   }

   #------------------------------------------------------------
   #  getDriverType 
   #     retourne le type de driver
   #  
   #  return "pad"
   #------------------------------------------------------------
   proc getDriverType { } {
      return "pad"
   }	

   #------------------------------------------------------------
   #  getLabel
   #     retourne le label du driver
   #  
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(lx200pad,titre)"
   }	

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #  
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {

      return "lx200pad.htm"
   }	

   #------------------------------------------------------------
   #  initConf 
   #     initialise les parametres dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(lx200pad,padsize) ] }  { set conf(lx200pad,padsize)  "0.6" }
      if { ! [ info exists conf(lx200pad,visible) ] }  { set conf(lx200pad,visible)  "1" }
      if { ! [ info exists conf(lx200pad,position) ] } { set conf(lx200pad,position) "657+252" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget 
   #     copie les parametres du tableau conf() dans les variables des widgets
   #  
   #  return rien
   #
   #------------------------------------------------------------
   proc confToWidget {  } {   
      variable widget  
      global conf

      set widget(padsize) $conf(lx200pad,padsize)
      set widget(visible) $conf(lx200pad,visible)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #  
   #  return rien
   #
   #------------------------------------------------------------
   proc widgetToConf {  } {   
      variable widget  
      global conf
      
      set conf(lx200pad,padsize) $widget(padsize)
      set conf(lx200pad,visible) $widget(visible)
  }	

   #------------------------------------------------------------
   #  fillConfigPage 
   #     fenetre de configuration du driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      variable private
      global caption

      #--- Je memorise la reference de la frame 
      set widget(frm) $frm
      
      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 0

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 0

      #--- Label pad size
      label $frm.labSize -text "$caption(lx200pad,pad_size)"
   	pack $frm.labSize -in $frm.frame1 -anchor nw -side left -padx 10 -pady 10

      #--- Definition de la taille de la raquette 
      set list_combobox [ list 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
      ComboBox $frm.taille \
         -width 7          \
         -height [llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::lx200pad::widget(padsize) \
         -values $list_combobox
      pack $frm.taille -in $frm.frame1 -anchor nw -side left -padx 10 -pady 10

	#--- Raquette toujours visible
	checkbutton $frm.visible -text "$caption(lx200pad,pad_visible)" -highlightthickness 0 \
         -variable ::lx200pad::widget(visible) -onvalue 1 -offvalue 0
	pack $frm.visible -in $frm.frame2 -anchor nw -side left -padx 10 -pady 10
   }

   #------------------------------------------------------------
   #  configureDriver
   #     configure le driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc configureDriver {  } { 
      global conf

      #--- Affiche la raquette  
      lx200pad::run $conf(lx200pad,padsize) $conf(lx200pad,position)
      return 
   }

   #------------------------------------------------------------
   #  stopDriver
   #     arrete le driver et libere les ressources occupees
   #  
   #  return nothing
   #------------------------------------------------------------
   proc stopDriver {  } { 
      global conf
      global audace

      if { [ winfo exists .lx200pad ] } {
         #--- Enregistre la position de la raquette 
         set geom [wm geometry .lx200pad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(lx200pad,position) "[string range  $geom $deb $fin]"     
      }

      #--- Supprime la raquette 
      destroy .lx200pad 
            
   
      #--- J'arrete la surveillance de audace(telescope,speed) et je modifie pour d�bloquer la boucle d'attente
      set temp $audace(telescope,speed) 
      set audace(telescope,speed) $temp
      
      return 
   }

   #------------------------------------------------------------
   #  isReady 
   #     informe de l'etat de fonctionnement du driver
   #  
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady {  } {   
      return  0
   }
               
   #==============================================================
   # Procedures specifiques du driver 
   #==============================================================

   #------------------------------------------------------------
   #  run 
   #     cree la fenetre de la raquette
   #------------------------------------------------------------
   proc run { {zoom .5} {positionxy 0+0} } {
      variable widget
      global audace
      global caption
      global zonelx200
      global geomlx200
      global statustel
      global color

      if { [ string length [ info commands .lx200pad.display* ] ] != "0" } {
         destroy .lx200pad 
      }
      
      if { $zoom <= "0" } {
         destroy .lx200pad
         return
      }
      
      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================
      
      set statustel(speed) "0"
      
      #--- Definition of colorlx200s
      #--- Definition des couleurs
      set colorlx200(backkey)  $color(gray_pad)
      set colorlx200(backpad)  $color(blue_pad)
      set colorlx200(backdisp) $color(red_pad)
      set colorlx200(textkey)  $color(white)
      set colorlx200(textdisp) $color(black)
      
      #--- Definition des geomlx200etries
      #--- Definition of geometry
      set geomlx200(larg)       [ expr int(300*$zoom) ]
      set geomlx200(long)       [ expr int(610*$zoom+40) ]
      set geomlx200(fontsize25) [ expr int(25*$zoom) ]
      set geomlx200(fontsize20) [ expr int(20*$zoom) ]
      set geomlx200(fontsize16) [ expr int(16*$zoom) ]
      set geomlx200(fontsize14) [ expr int(14*$zoom) ]
      set geomlx200(fontsize10) [ expr int(10*$zoom) ]
      set geomlx200(10pixels)   [ expr int(10*$zoom) ]
      set geomlx200(20pixels)   [ expr int(20*$zoom) ]
      set geomlx200(larg2)      [ expr int(85*$zoom) ]
      set geomlx200(haut2)      [ expr int(65*$zoom) ]
      set geomlx200(haut)       [ expr int(70*$zoom) ]
      set geomlx200(linewidth0) [ expr int(3*$zoom) ]
      set geomlx200(linewidth)  [ expr int($geomlx200(linewidth0)+1) ]
      set geomlx200(lightx1)    [ expr int(10*$zoom) ]
      set geomlx200(lighty1)    [ expr int(30*$zoom) ]
      set geomlx200(lightx2)    [ expr int(20*$zoom) ]
      set geomlx200(lighty2)    [ expr int(40*$zoom) ]
      if { $geomlx200(linewidth0) <= "1" } { set geomlx200(textthick) "" } else { set geomlx200(textthick) "bold" } 
      
      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .lx200pad de niveau le plus haut
      toplevel .lx200pad -class Toplevel -bg $colorlx200(backpad)
      wm geometry .lx200pad $geomlx200(larg)x$geomlx200(long)+$positionxy
      wm resizable .lx200pad 0 0
      wm title .lx200pad $caption(lx200pad,titre)
      wm protocol .lx200pad WM_DELETE_WINDOW "::lx200pad::stopDriver"
      if { $widget(visible) == "1" } {
         wm transient .lx200pad $audace(base)
      }

      #--- Create the title
      #--- Cree le titre
      label .lx200pad.meade \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text Meade \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .lx200pad.meade \
         -in .lx200pad -fill x -side top
      
      frame .lx200pad.display -borderwidth 4  -relief sunken -bg $colorlx200(backdisp) 
   
      #--- Label pour RA
      label  .lx200pad.display.ra  \
         -font [ list {Courier} $geomlx200(fontsize20) $geomlx200(textthick) ] \
         -textvariable audace(telescope,getra) -bg $colorlx200(backdisp) \
         -fg $colorlx200(textdisp) -relief flat -height 1 -width 12  
      pack   .lx200pad.display.ra -in .lx200pad.display  -anchor center  -pady 0 
      
      #--- Label pour DEC
      label  .lx200pad.display.dec \
         -font [ list {Courier} $geomlx200(fontsize20) $geomlx200(textthick) ] \
         -textvariable audace(telescope,getdec) -bg $colorlx200(backdisp) \
         -fg $colorlx200(textdisp) -relief flat -height 1 -width 12
      pack   .lx200pad.display.dec -in .lx200pad.display  -anchor center -pady 0  

      pack .lx200pad.display -in .lx200pad  -fill x -side top -pady $geomlx200(10pixels) -padx 12

      #--- Refreach the coordinates on the display
      bind .lx200pad.display.ra  <ButtonPress-1> { ::telescope::afficheCoord  }
      bind .lx200pad.display.dec <ButtonPress-1> { ::telescope::afficheCoord  }
      bind .lx200pad.display     <ButtonPress-1> { ::telescope::afficheCoord  }
      
      #--- Create a dummy space
      #--- Cree un espace inutile
      frame .lx200pad.dum1 \
         -height $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.dum1 \
         -in .lx200pad -side top -fill x
      
      #--- Create a frame for the function buttons
      #--- Cree un espace pour les boutons de fonction
      frame .lx200pad.func \
         -height 70 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.func \
         -in .lx200pad -side top -fill x
      
      #--- Create the button 'enter'
      frame .lx200pad.func.enter \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.func.enter \
         -in .lx200pad.func -side left
      #--- Button-design
      canvas .lx200pad.func.enter.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.func.enter.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.func.enter.canv1 \
         -in .lx200pad.func.enter -expand 1
      #--- Write the label
      label .lx200pad.func.enter.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text ENTER \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.func.enter.canv1.lab \
         -in .lx200pad.func.enter.canv1 -x [ expr int(11*$zoom) ] -y [ expr int(22*$zoom) ]
      
      #--- Create the button 'go to'
      frame .lx200pad.func.goto \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.func.goto \
         -in .lx200pad.func -side right
      #--- Button-design
      canvas .lx200pad.func.goto.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.func.goto.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.func.goto.canv1 \
         -in .lx200pad.func.goto -expand 1
      #--- Write the label
      label .lx200pad.func.goto.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text "GO TO" \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.func.goto.canv1.lab \
         -in .lx200pad.func.goto.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(22*$zoom) ]
      
      #--- Create the button 'mode'
      frame .lx200pad.func.mode \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.func.mode \
         -in .lx200pad.func -side top
      #--- Button-design
      canvas .lx200pad.func.mode.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.func.mode.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.func.mode.canv1 \
         -in .lx200pad.func.mode -expand 1
      #--- Write the label
      label .lx200pad.func.mode.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text MODE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.func.mode.canv1.lab \
         -in .lx200pad.func.mode.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(22*$zoom) ]
      
      #--- Create a frame for the cardinal buttons
      #--- Cree un espace pour les boutons cardinaux
      frame .lx200pad.card \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.card \
         -in .lx200pad -side top -fill x
      
      #--- Create a dummy space
      #--- Cree un espace inutile
      frame .lx200pad.card.dumw \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.card.dumw \
         -in .lx200pad.card -side left -fill y
      
      #--- Create the button 'W'
      set geomlx200(larg2) $geomlx200(haut2)
      frame .lx200pad.card.w \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.card.w \
         -in .lx200pad.card -side left
      #--- Button-design
      canvas .lx200pad.card.w.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.card.w.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.card.w.canv1 \
         -in .lx200pad.card.w -expand 1
      #--- Write the label
      label .lx200pad.card.w.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text W \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.card.w.canv1.lab \
         -in .lx200pad.card.w.canv1 -x [ expr int(17*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(w) .lx200pad.card.w.canv1
      
      #--- Create a dummy space
      #--- Cree un espace inutile
      frame .lx200pad.card.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.card.dume \
         -in .lx200pad.card -side right -fill y
      
      #--- Create the button 'E'
      frame .lx200pad.card.e \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) 
      pack .lx200pad.card.e \
         -in .lx200pad.card -side right
      #--- Button-design
      canvas .lx200pad.card.e.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.card.e.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.card.e.canv1 \
         -in .lx200pad.card.e -expand 1
      #--- Write the label
      label .lx200pad.card.e.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text E \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.card.e.canv1.lab \
         -in .lx200pad.card.e.canv1 -x [ expr int(22*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(e) .lx200pad.card.e.canv1
      
      #--- Create the button 'N'
      frame .lx200pad.card.n \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.card.n \
         -in .lx200pad.card -side top
      #--- Button-design
      canvas .lx200pad.card.n.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.card.n.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.card.n.canv1 \
         -in .lx200pad.card.n -expand 1
      #--- Write the label
      label .lx200pad.card.n.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text N \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.card.n.canv1.lab \
         -in .lx200pad.card.n.canv1 -x [ expr int(22*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(n) .lx200pad.card.n.canv1
      
      #--- Create the button 'S'
      frame .lx200pad.card.s \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.card.s \
         -in .lx200pad.card -side top
      #--- Button-design
      canvas .lx200pad.card.s.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.card.s.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.card.s.canv1 \
         -in .lx200pad.card.s -expand 1
      #--- Write the label
      label .lx200pad.card.s.canv1.lab \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text S \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.card.s.canv1.lab \
         -in .lx200pad.card.s.canv1 -x [ expr int(22*$zoom) ] -y [ expr int(15*$zoom) ]
      set zonelx200(s) .lx200pad.card.s.canv1
      
      #--- Create a frame for the 789 buttons
      #--- Cree un espace pour les boutons 789
      frame .lx200pad.789 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.789 \
         -in .lx200pad -side top -fill x
      
      #--- Create the light 'slew'
      frame .lx200pad.789.slew \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $color(green) 
      pack .lx200pad.789.slew \
         -in .lx200pad.789 -side left -fill y
      canvas .lx200pad.789.slew.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.789.slew.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
      $geomlx200(lighty2) -fill $color(black)
      pack .lx200pad.789.slew.canv1 \
         -in .lx200pad.789.slew -expand 1
      set zonelx200(slew) .lx200pad.789.slew.canv1
      
      #--- Create the button '7'
      frame .lx200pad.789.7 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.789.7 \
         -in .lx200pad.789 -side left
      #--- Button-design
      canvas .lx200pad.789.7.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.789.7.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.789.7.canv1 \
         -in .lx200pad.789.7 -expand 1
      #--- Write the label
      label .lx200pad.789.7.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 7 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.789.7.canv1.lab1 \
         -in .lx200pad.789.7.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.789.7.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text SLEW \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.789.7.canv1.lab2 \
         -in .lx200pad.789.7.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(7) .lx200pad.789.7.canv1
      
      #--- Create a dummy frame
      frame .lx200pad.789.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.789.dume \
         -in .lx200pad.789 -side right -fill y
      
      #--- Create the button '9'
      frame .lx200pad.789.9 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.789.9 \
         -in .lx200pad.789 -side right
      #--- Button-design
      canvas .lx200pad.789.9.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.789.9.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.789.9.canv1 \
         -in .lx200pad.789.9 -expand 1
      #--- Write the label
      label .lx200pad.789.9.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 9 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.789.9.canv1.lab1 \
         -in .lx200pad.789.9.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.789.9.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text M \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.789.9.canv1.lab2 \
         -in .lx200pad.789.9.canv1 -x [ expr int(28*$zoom) ] -y [ expr int(10*$zoom) ]
      
      #--- Create the button '8'
      frame .lx200pad.789.8 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.789.8 \
         -in .lx200pad.789 -side top
      #--- Button-design
      canvas .lx200pad.789.8.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.789.8.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.789.8.canv1 \
         -in .lx200pad.789.8 -expand 1
      #--- Write the label
      label .lx200pad.789.8.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 8 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.789.8.canv1.lab1 \
         -in .lx200pad.789.8.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.789.8.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text RET \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.789.8.canv1.lab2 \
         -in .lx200pad.789.8.canv1 -x [ expr int(20*$zoom) ] -y [ expr int(10*$zoom) ]
      
      #--- Create a frame for the 456 buttons
      #--- Cree un espace pour les boutons 456
      frame .lx200pad.456 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.456 \
         -in .lx200pad -side top -fill x
      
      #--- Create the light 'find'
      frame .lx200pad.456.find \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $color(red) 
      pack .lx200pad.456.find \
         -in .lx200pad.456 -side left -fill y
      canvas .lx200pad.456.find.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.456.find.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
         $geomlx200(lighty2) -fill $color(black)
      pack .lx200pad.456.find.canv1 \
         -in .lx200pad.456.find -expand 1
      set zonelx200(find) .lx200pad.456.find.canv1
      
      #--- Create the button '4'
      frame .lx200pad.456.4 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.456.4 \
         -in .lx200pad.456 -side left
      #--- Button-design
      canvas .lx200pad.456.4.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.456.4.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.456.4.canv1 \
         -in .lx200pad.456.4 -expand 1
      
      #--- Write the label
      label .lx200pad.456.4.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 4 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.456.4.canv1.lab1 \
         -in .lx200pad.456.4.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.456.4.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text FIND \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.456.4.canv1.lab2 \
         -in .lx200pad.456.4.canv1 -x [ expr int(18*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(4) .lx200pad.456.4.canv1
      
      #--- Create a dummy frame
      frame .lx200pad.456.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.456.dume \
         -in .lx200pad.456 -side right -fill y
      
      #--- Create the button '6'
      frame .lx200pad.456.6 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.456.6 \
         -in .lx200pad.456 -side right
      #--- Button-design
      canvas .lx200pad.456.6.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.456.6.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.456.6.canv1 \
         -in .lx200pad.456.6 -expand 1
      #--- Write the label
      label .lx200pad.456.6.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 6 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.456.6.canv1.lab1 \
         -in .lx200pad.456.6.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.456.6.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text STAR \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.456.6.canv1.lab2 \
         -in .lx200pad.456.6.canv1 -x [ expr int(16*$zoom) ] -y [ expr int(10*$zoom) ]
      
      #--- Create the button '5'
      frame .lx200pad.456.5 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.456.5 \
         -in .lx200pad.456 -side top
      #--- Button-design
      canvas .lx200pad.456.5.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.456.5.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.456.5.canv1 \
         -in .lx200pad.456.5 -expand 1
      #--- Write the label
      label .lx200pad.456.5.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 5 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.456.5.canv1.lab1 \
         -in .lx200pad.456.5.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.456.5.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text FOCUS \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.456.5.canv1.lab2 \
         -in .lx200pad.456.5.canv1 -x [ expr int(10*$zoom) ] -y [ expr int(10*$zoom) ]
      
      #--- Create a frame for the 123 buttons
      #--- Cree un espace pour les boutons 123
      frame .lx200pad.123 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.123 \
         -in .lx200pad -side top -fill x
      
      #--- Create the light 'cntr'
      frame .lx200pad.123.cntr \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.123.cntr \
         -in .lx200pad.123 -side left -fill y
      canvas .lx200pad.123.cntr.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.123.cntr.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
         $geomlx200(lighty2) -fill $color(black)
      pack .lx200pad.123.cntr.canv1 \
         -in .lx200pad.123.cntr -expand 1
      set zonelx200(cntr) .lx200pad.123.cntr.canv1
      
      #--- Create the button '1'
      set larg2 65
      set haut2 65
      frame .lx200pad.123.1 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.123.1 \
         -in .lx200pad.123 -side left
      #--- Button-design
      canvas .lx200pad.123.1.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.123.1.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.123.1.canv1 \
         -in .lx200pad.123.1 -expand 1
      #--- Write the label
      label .lx200pad.123.1.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 1 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.123.1.canv1.lab1 \
         -in .lx200pad.123.1.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.123.1.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text CNTR \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.123.1.canv1.lab2 \
         -in .lx200pad.123.1.canv1 -x [ expr int(16*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(1) .lx200pad.123.1.canv1
      
      #--- Create a dummy frame
      frame .lx200pad.123.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.123.dume \
         -in .lx200pad.123 -side right -fill y
      
      #--- Create the button '3'
      frame .lx200pad.123.3 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.123.3 \
         -in .lx200pad.123 -side right
      #--- Button-design
      canvas .lx200pad.123.3.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.123.3.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.123.3.canv1 \
         -in .lx200pad.123.3 -expand 1
      #--- Write the label
      label .lx200pad.123.3.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 3 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.123.3.canv1.lab1 \
         -in .lx200pad.123.3.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.123.3.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text CNGC \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.123.3.canv1.lab2 \
         -in .lx200pad.123.3.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(10*$zoom) ]
      
      #--- Create the button '2'
      frame .lx200pad.123.2 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.123.2 \
         -in .lx200pad.123 -side top
      #--- Button-design
      canvas .lx200pad.123.2.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.123.2.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.123.2.canv1 \
         -in .lx200pad.123.2 -expand 1
      #--- Write the label
      label .lx200pad.123.2.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 2 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.123.2.canv1.lab1 \
         -in .lx200pad.123.2.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.123.2.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text MAP \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.123.2.canv1.lab2 \
         -in .lx200pad.123.2.canv1 -x [ expr int(19*$zoom) ] -y [ expr int(10*$zoom) ]
      
      #--- Create a frame for the 000 buttons
      #--- Cree un espace pour les boutons 000
      frame .lx200pad.000 \
         -height 150 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.000 \
         -in .lx200pad -side top -fill x
      
      #--- Create the light 'guide'
      frame .lx200pad.000.guide \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.000.guide \
         -in .lx200pad.000 -side left -fill y
      canvas .lx200pad.000.guide.canv1 \
         -width $geomlx200(20pixels) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.000.guide.canv1 create oval $geomlx200(lightx1) $geomlx200(lighty1) $geomlx200(lightx2) \
         $geomlx200(lighty2) -fill $color(red)
      pack .lx200pad.000.guide.canv1 \
         -in .lx200pad.000.guide -expand 1
      set zonelx200(guide) .lx200pad.000.guide.canv1
      
      #--- Create the button '0'
      set larg2 65
      set haut2 65
      frame .lx200pad.000.0 \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.000.0 \
         -in .lx200pad.000 -side left
      #--- Button-design
      canvas .lx200pad.000.0.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.000.0.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.000.0.canv1 \
         -in .lx200pad.000.0 -expand 1
      #--- Write the label
      label .lx200pad.000.0.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text 0 \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.000.0.canv1.lab1 \
         -in .lx200pad.000.0.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.000.0.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text GUIDE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.000.0.canv1.lab2 \
         -in .lx200pad.000.0.canv1 -x [ expr int(13*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(0) .lx200pad.000.0.canv1
      
      #--- Create a dummy frame
      frame .lx200pad.000.dume \
         -width $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.000.dume \
         -in .lx200pad.000 -side right -fill y
      
      #--- Create the button 'next'
      frame .lx200pad.000.next \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.000.next \
         -in .lx200pad.000 -side right
      #--- Button-design
      canvas .lx200pad.000.next.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.000.next.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth)
      pack .lx200pad.000.next.canv1 \
         -in .lx200pad.000.next -expand 1
      #--- Write the label
      label .lx200pad.000.next.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text " " \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.000.next.canv1.lab1 \
         -in .lx200pad.000.next.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.000.next.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text NEXT \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.000.next.canv1.lab2 \
         -in .lx200pad.000.next.canv1 -x [ expr int(16*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(next) .lx200pad.000.next.canv1
      
      #--- Create the button 'prev'
      frame .lx200pad.000.prev \
         -width $geomlx200(larg2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .lx200pad.000.prev \
         -in .lx200pad.000 -side top
      #--- Button-design
      canvas .lx200pad.000.prev.canv1 \
         -width $geomlx200(larg2) -height $geomlx200(haut2) \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -highlightbackground $colorlx200(backpad)
      .lx200pad.000.prev.canv1 create line $geomlx200(linewidth) $geomlx200(linewidth) $geomlx200(linewidth) \
         $geomlx200(haut2) $geomlx200(larg2) $geomlx200(haut2) $geomlx200(larg2) $geomlx200(linewidth) \
         $geomlx200(linewidth) $geomlx200(linewidth) \
         -fill $colorlx200(textkey) -width $geomlx200(linewidth0)
      pack .lx200pad.000.prev.canv1 \
         -in .lx200pad.000.prev -expand 1
      #--- Write the label
      label .lx200pad.000.prev.canv1.lab1 \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text " " \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.000.prev.canv1.lab1 \
         -in .lx200pad.000.prev.canv1 -x [ expr int(25*$zoom) ] -y [ expr int(28*$zoom) ]
      #--- Write the label
      label .lx200pad.000.prev.canv1.lab2 \
         -font [ list {Arial} $geomlx200(fontsize10) $geomlx200(textthick) ] -text PREV \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)
      place .lx200pad.000.prev.canv1.lab2 \
         -in .lx200pad.000.prev.canv1 -x [ expr int(15*$zoom) ] -y [ expr int(10*$zoom) ]
      set zonelx200(prev) .lx200pad.000.prev.canv1
      
      #--- La fenetre est active
      focus .lx200pad

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .lx200pad <Key-F1> { $audace(console)::GiveFocus }

      # =========================================
      # === Setting the binding
      # === Met en place les liaisons
      # =========================================
      
      # ========================================
      # === Setting the astronomical devices ===
      # ========================================
      
      if { [ string compare $audace(telNo) 0 ] != "0" } {
         #--- Cardinal moves
         bind $zonelx200(e) <ButtonPress-1>     { ::telescope::move e }
         bind $zonelx200(e).lab <ButtonPress-1> { ::telescope::move e }
         bind $zonelx200(e) <ButtonRelease-1>   { ::telescope::stop e }
         bind $zonelx200(e).lab <ButtonRelease-1> {::telescope::stop e  }
         
         bind $zonelx200(w) <ButtonPress-1>     { ::telescope::move w }
         bind $zonelx200(w).lab <ButtonPress-1> { ::telescope::move w }
         bind $zonelx200(w) <ButtonRelease-1>   { ::telescope::stop w }
         bind $zonelx200(w).lab <ButtonRelease-1> {::telescope::stop w }
         
         bind $zonelx200(s) <ButtonPress-1>     { ::telescope::move s }
         bind $zonelx200(s).lab <ButtonPress-1> { ::telescope::move s }
         bind $zonelx200(s) <ButtonRelease-1>   { ::telescope::stop s  }
         bind $zonelx200(s).lab <ButtonRelease-1> {::telescope::stop s }
         
         bind $zonelx200(n) <ButtonPress-1>     { ::telescope::move n }
         bind $zonelx200(n).lab <ButtonPress-1> { ::telescope::move n }
         bind $zonelx200(n) <ButtonRelease-1>   { ::telescope::stop n }
         bind $zonelx200(n).lab <ButtonRelease-1> {::telescope::stop n }
         
         #--- Focus moves
         bind $zonelx200(next) <ButtonPress-1> { tel$audace(telNo) focus move + $statustel(speed) }
         bind $zonelx200(next).lab1 <ButtonPress-1> { tel$audace(telNo) focus move + $statustel(speed) }
         bind $zonelx200(next) <ButtonRelease-1> { tel$audace(telNo) focus stop }
         bind $zonelx200(next).lab1 <ButtonRelease-1> { tel$audace(telNo) focus stop }
         bind $zonelx200(prev) <ButtonPress-1> { tel$audace(telNo) focus move - $statustel(speed) }
         bind $zonelx200(prev).lab1 <ButtonPress-1> { tel$audace(telNo) focus move - $statustel(speed) }
         bind $zonelx200(prev) <ButtonRelease-1> { tel$audace(telNo) focus stop }
         bind $zonelx200(prev).lab1 <ButtonRelease-1> { tel$audace(telNo) focus stop }
         
         #--- Set speeds
         bind $zonelx200(7) <ButtonPress-1>      {::telescope::setSpeed "4"}
         bind $zonelx200(7).lab1 <ButtonPress-1> {::telescope::setSpeed "4"}
         bind $zonelx200(7).lab2 <ButtonPress-1> {::telescope::setSpeed "4"}
         
         bind $zonelx200(4) <ButtonPress-1>      {::telescope::setSpeed "3"}
         bind $zonelx200(4).lab1 <ButtonPress-1> {::telescope::setSpeed "3"}
         bind $zonelx200(4).lab2 <ButtonPress-1> {::telescope::setSpeed "3"}
         
         bind $zonelx200(1) <ButtonPress-1>      {::telescope::setSpeed "2"}
         bind $zonelx200(1).lab1 <ButtonPress-1> {::telescope::setSpeed "2"}
         bind $zonelx200(1).lab2 <ButtonPress-1> {::telescope::setSpeed "2"}
         
         bind $zonelx200(0) <ButtonPress-1>      {::telescope::setSpeed "1"}
         bind $zonelx200(0).lab1 <ButtonPress-1> {::telescope::setSpeed "1"}
         bind $zonelx200(0).lab2 <ButtonPress-1> {::telescope::setSpeed "1"}
      }

      #--- Je demarre la surveillance de audace(telescope,speed)
      ::lx200pad::startSurveilleSpeed

      #--- Je refraichi l'affichage des coordonnees
      ::telescope::afficheCoord

      # =======================================
      # === It is the end of the script run ===
      # =======================================
   }

   #------------------------------------------------------------
   #  startSurveilleSpeed 
   #   lance ::lx200pad::surveilleSpeed si ce n'est pas deja fait
   #    
   #  return rien
   #------------------------------------------------------------
   proc startSurveilleSpeed {} {
      global suveilleSpeedActif

      #--- Je cree la variable globale si elle n'existe pas     
      if { [info exists suveilleSpeedActif] == "0"  } {
         set suveilleSpeedActif "0"
      } 
          
      if { $suveilleSpeedActif == "0" } {
         after 100 ::lx200pad::surveilleSpeed
         set suveilleSpeedActif "1"
      }

   }

   #------------------------------------------------------------
   #  surveilleSpeed 
   #   surveille les modifications de audace(telescope,speed) en tache de fond 
   #   car les canvas qui sont mis a jour en fonction audace(telescope,speed) 
   #   ne possedent pas le parametre -textvariable pour se mettre a jour automatiquement
   #    
   #  return rien
   #------------------------------------------------------------
   proc surveilleSpeed {} {
      global audace
      global suveilleSpeedActif
      
      #--- J'attends un changement de la valeur de audace(telescope,speed)
      vwait audace(telescope,speed)

      #--- Si la raquette existe , je met a jour l'affichage de la vitesse
      if { [ winfo exists .lx200pad ] } {
         switch -exact -- $audace(telescope,speed) {
   	      1 { ::lx200pad::lx200_set_guide }
   	      2 { ::lx200pad::lx200_set_cntr  }
   	      3 { ::lx200pad::lx200_set_find  }
   	      4 { ::lx200pad::lx200_set_slew }
         }
      }

      #--- Je relance la surveillance
      if { $suveilleSpeedActif == "1" && [ winfo exists .lx200pad ] } {
          after 100 ::lx200pad::surveilleSpeed
      } else {
         set suveilleSpeedActif "0"
      }
	   
   }

   #------------------------------------------------------------
   #  lx200_set_slew 
   #     affiche la vitesse slew sur la raquette
   #------------------------------------------------------------
   proc lx200_set_slew { } {
      global color zonelx200
      $zonelx200(slew)  itemconfigure 1 -fill $color(red)
      $zonelx200(find)  itemconfigure 1 -fill $color(black)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(black)
      $zonelx200(guide) itemconfigure 1 -fill $color(black)
   }

   #------------------------------------------------------------
   #  lx200_set_find 
   #     affiche la vitesse find sur la raquette
   #------------------------------------------------------------
   proc lx200_set_find { } {
      global color zonelx200
      $zonelx200(slew)  itemconfigure 1 -fill $color(black)
      $zonelx200(find)  itemconfigure 1 -fill $color(red)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(black)
      $zonelx200(guide) itemconfigure 1 -fill $color(black)
   }

   #------------------------------------------------------------
   #  lx200_set_cntr 
   #     affiche la vitesse cntr sur la raquette
   #------------------------------------------------------------
   proc lx200_set_cntr { } {
      global color zonelx200
      $zonelx200(slew)  itemconfigure 1 -fill $color(black)
      $zonelx200(find)  itemconfigure 1 -fill $color(black)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(red)
      $zonelx200(guide) itemconfigure 1 -fill $color(black)
   }

   #------------------------------------------------------------
   #  lx200_set_guide 
   #     affiche la vitesse guide sur la raquette
   #------------------------------------------------------------
   proc lx200_set_guide { } {
      global color zonelx200
      $zonelx200(slew)  itemconfigure 1 -fill $color(black)
      $zonelx200(find)  itemconfigure 1 -fill $color(black)
      $zonelx200(cntr)  itemconfigure 1 -fill $color(black)
      $zonelx200(guide) itemconfigure 1 -fill $color(red)
   }

}

::lx200pad::init

