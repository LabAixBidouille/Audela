#
# Fichier : telpad.tcl
# Description : Raquette simplifiee a l'usage des telescopes
# Auteur : Robert DELMAS
# Date de mise a jour : 26 juillet 2005
#

package provide telpad 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init 			: initialise le namespace (appelee pendant le chargement de ce source)   
#     getDriverName  	: retourne le nom du driver
#     getLabel     	: retourne le nom affichable du driver 
#     getHelp           : retourne la documentation htm associee
#     getDriverType 	: retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf     	: initialise les parametres de configuration s'il n'existe pas dans le tableau conf()  
#     fillConfigPage 	: affiche la fenetre de configuration de ce driver 
#     confToWidget   	: copie le tableau conf() dans les variables des widgets
#     widgetToConf 	: copie les variables des widgets dans le tableau conf()
#     configureDriver	: configure le driver 
#     stopDriver        : arrete le driver et libere les ressources occupees
#     isReady 		: informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :  
#     run         	: affiche la raquette 
#     fermer            : ferme la raquette
#     createDialog      : creation de l'interface graphique
#    

namespace eval telpad {
   variable This
   global telpad

   #==============================================================
   # Procedures generiques de configuration des drivers
   #==============================================================

   #------------------------------------------------------------
   #  init (est lance automatiquement au chargement de ce fichier tcl)
   #     initialise le driver 
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {   
      global audace    

      #--- Charge le fichier caption
      uplevel #0  "source \"[ file join $audace(rep_plugin) pad telpad telpad.cap ]\"" 

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

      return "$caption(telpad,titre)"
   }	

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #  
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {

      return "telpad.htm"
   }	

   #------------------------------------------------------------
   #  initConf 
   #     initialise les parametres dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(telpad,padsize) ] }    { set conf(telpad,padsize)    "0.6" }
      if { ! [ info exists conf(telpad,visible) ] }    { set conf(telpad,visible)    "1" }
      if { ! [ info exists conf(telpad,wmgeometry) ] } { set conf(telpad,wmgeometry) "157x254+657+252" }
      
      return
   }

   #------------------------------------------------------------
   #  confToWidget 
   #     copie les parametres du tableau conf() dans les variables des widgets
   #  
   #  return rien
   #------------------------------------------------------------
   proc confToWidget {  } {   
      variable widget  
      global conf

      set widget(padsize) $conf(telpad,padsize) 
      set widget(visible) $conf(telpad,visible)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf {  } {   
      variable widget  
      global conf
      
      set conf(telpad,padsize) $widget(padsize)
      set conf(telpad,visible) $widget(visible)
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
      label $frm.labSize -text "$caption(telpad,taille)"
   	pack $frm.labSize -in $frm.frame1 -anchor nw -side left -padx 10 -pady 10
      
      #--- Definition de la taille de la raquette 
      set list_combobox [ list 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
      ComboBox $frm.taille \
         -width 7          \
         -height [llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::telpad::widget(padsize) \
         -values $list_combobox
      pack $frm.taille -in $frm.frame1 -anchor nw -side left -padx 10 -pady 10

	#--- Raquette toujours visible
	checkbutton $frm.visible -text "$caption(telpad,pad_visible)" -highlightthickness 0 \
         -variable ::telpad::widget(visible) -onvalue 1 -offvalue 0
	pack $frm.visible -in $frm.frame2 -anchor nw -side left -padx 10 -pady 10
   }

   #------------------------------------------------------------
   #  configureDriver
   #     configure le driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc configureDriver { } { 
      global audace

      #--- Affiche la raquette  
      telpad::run "$audace(base).telpad"
      return 
   }

   #------------------------------------------------------------
   #  stopDriver
   #     arrete le driver et libere les ressources occupees
   #  
   #  return nothing
   #------------------------------------------------------------
   proc stopDriver { } { 

      #--- Ferme la raquette 
      fermer
      return 
   }

   #------------------------------------------------------------
   #  isReady 
   #     informe de l'etat de fonctionnement du driver
   #  
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {   

      return  0
   }

   #==============================================================
   # Procedures specifiques du driver 
   #==============================================================

   #------------------------------------------------------------
   #  run this 
   #     cree la fenetre de la raquette
   #     this = chemin de la fenetre
   #------------------------------------------------------------
   proc run { { this } } {
      variable This

      set This $this
      createDialog 
      #tkwait visibility $This

      #--- Je refraichis l'affichage des coordonnees      
      ::telescope::afficheCoord

   }

   #------------------------------------------------------------
   #  fermer
   #     fonction appellee lors de l'appui sur la croix
   #------------------------------------------------------------
   proc fermer { } {
      variable This
      global conf

      if { [ winfo exists $This ] == 1 } {
         set conf(telpad,wmgeometry) "[ wm geometry $This ]"
      }

      destroy $This
   }

   #------------------------------------------------------------
   #  createDialog
   #     creation de l'interface graphique
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable widget
      global audace
      global conf
      global caption

      if { [ winfo exists $This ] } {
         destroy $This
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(telpad,titre)
      if { [ info exists conf(telpad,wmgeometry) ] == "1" } {
         wm geometry $This $conf(telpad,wmgeometry)
      } else {
         wm geometry $This 157x256+657+252
      }
      wm resizable $This 1 1
      wm protocol $This WM_DELETE_WINDOW ::telpad::fermer
      if { $widget(visible) == "1" } {
         wm transient $This $audace(base)
      }

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief groove
      pack $This.frame2 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame3 -borderwidth 1 -relief groove
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 1 -relief groove
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      #--- Label pour RA
      label $This.frame2.ent1 -font $audace(font,arial_10_b) -textvariable audace(telescope,getra)
      pack $This.frame2.ent1 -in $This.frame2 -anchor center -fill none -pady 1

      #--- Label pour DEC
      label $This.frame2.ent2 -font $audace(font,arial_10_b) -textvariable audace(telescope,getdec)
      pack $This.frame2.ent2 -in $This.frame2 -anchor center -fill none -pady 1

      set zone(radec) $This.frame2
      bind $zone(radec) <ButtonPress-1>      { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      #--- Create the button 'N'
      frame $This.frame3.n -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.n -in $This.frame3 -side top -fill x

      #--- Button-design 'N'
      button $This.frame3.n.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,nord)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.n.canv1 -in $This.frame3.n -expand 0 -side top -padx 10 -pady 4

      #--- Create the buttons 'E W'
      frame $This.frame3.we -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.we -in $This.frame3 -side top -fill x

      #--- Button-design 'E'
      button $This.frame3.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,est)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv1 -in $This.frame3.we -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed
      label $This.frame3.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
         -borderwidth 0 -relief flat
      pack $This.frame3.we.lab -in $This.frame3.we -expand 1 -side left

      #--- Button-design 'W'
      button $This.frame3.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,ouest)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv2 -in $This.frame3.we -expand 0 -side right -padx 10 -pady 4

      #--- Create the button 'S'
      frame $This.frame3.s -width 27 -borderwidth 0 -relief flat
      pack $This.frame3.s -in $This.frame3 -side top -fill x

      #--- Button-design 'S'
      button $This.frame3.s.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "$caption(telpad,sud)" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame3.s.canv1 -in $This.frame3.s -expand 0 -side top -padx 10 -pady 4

      set zone(n) $This.frame3.n.canv1
      set zone(e) $This.frame3.we.canv1
      set zone(w) $This.frame3.we.canv2
      set zone(s) $This.frame3.s.canv1

      #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
      if { [::telescope::possedeControleSuivi] == "1" } {
         label $This.frame3.s.lab1 \
            -font $audace(font,arial_10_b) -textvariable audace(telescope,controle) \
            -borderwidth 0 -relief flat
         pack $This.frame3.s.lab1 -in $This.frame3.s -expand 1 -side left
         bind $This.frame3.s.lab1 <ButtonPress-1> { ::telescope::controleSuivi }
      }

      #--- Binding de la vitesse du telescope
      bind $This.frame3.we.lab <ButtonPress-1> { ::telescope::incrementSpeed }

      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1> { catch { ::telescope::move e } }
      bind $zone(e) <ButtonRelease-1> { ::telescope::stop e }
      bind $zone(w) <ButtonPress-1> { catch { ::telescope::move w  } }
      bind $zone(w) <ButtonRelease-1> { ::telescope::stop w }
      bind $zone(s) <ButtonPress-1> { catch { ::telescope::move s  } }
      bind $zone(s) <ButtonRelease-1> { ::telescope::stop s }
      bind $zone(n) <ButtonPress-1> { catch { ::telescope::move n } }
      bind $zone(n) <ButtonRelease-1> { ::telescope::stop n }

      #--- Label pour moteur focus
      label $This.frame4.lab1 -text $caption(telpad,moteur_foc) -relief flat
      pack $This.frame4.lab1 -in $This.frame4 -anchor center -fill none -padx 4 -pady 1

      #--- Create the buttons '- +'
      frame $This.frame4.we -width 27 -borderwidth 0 -relief flat
      pack $This.frame4.we -in $This.frame4 -side top -fill x

      #--- Button '-'
      button $This.frame4.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "-" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame4.we.canv1 -in $This.frame4.we -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed for LX200 and compatibles
      label $This.frame4.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(focus,labelspeed) -width 2 \
         -borderwidth 0 -relief flat
      pack $This.frame4.we.lab -in $This.frame4.we -expand 1 -side left

      #--- Button '+'
      button $This.frame4.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -text "+" \
         -width 2  \
         -anchor center \
         -relief ridge
      pack $This.frame4.we.canv2 -in $This.frame4.we -expand 0 -side right -padx 10 -pady 4

      set zone(moins) $This.frame4.we.canv1
      set zone(plus)  $This.frame4.we.canv2
      
      #--- Binding de la vitesse du moteur de focalisation
      bind $This.frame4.we.lab <ButtonPress-1> { ::focus::incrementSpeed }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1> { catch { ::focus::move - } }
      bind $zone(moins) <ButtonRelease-1> { ::focus::move stop }
      bind $zone(plus) <ButtonPress-1> { catch { ::focus::move + } }
      bind $zone(plus) <ButtonRelease-1> { ::focus::move stop }

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
  }

}

::telpad::init

