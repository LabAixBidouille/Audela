#
# Fichier : crosshair.tcl
# Description : Affiche un reticule sur l'image
# Auteur : Michel PUJOL
# Date de mise a jour : 26 novembre 2004
#

namespace eval ::Crosshair {  
   global audace
   
   #--- private variable
   array set private { 
      currentstate   "0"
      hCrosshairH    ""
      hCrosshairV    ""
      imageSize      ""
   }  

   array set widget { }

   #------------------------------------------------------------
   #  init 
   #     initialise le driver 
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init {} {
      variable private  
      global audace  
      global conf

      uplevel #0  "source \"[file join $audace(rep_caption) crosshair.cap]\"" 
      
      initConf
      set private(currentstate)  "$conf(crosshair,defaultstate)"
      set private(imageSize) " "   
 
      return [namespace current]
   }

   #------------------------------------------------------------
   #  initConf{ }
   #     initialise les parametres dans le tableau conf()
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if {![info exists conf(crosshair,color)]}        { set conf(crosshair,color) "#FF0000" }
      if {![info exists conf(crosshair,defaultstate)]} { set conf(crosshair,defaultstate) "0" }
   }     

   #==============================================================
   # Fonctions de configuration generiques
   #
   # getLabel        retourne le titre de la fenetre de config
   # confToWidget    copie les parametres du tableau conf() dans les variables des widgets
   # widgetToConf    copie les variable des widgets dans le tableau conf()
   # fillConfigPage  affiche la fenetre de config
   #==============================================================

   #------------------------------------------------------------
   #  getLabel
   #     retourne le nom et le label du driver
   #  
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"]
   #
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(crosshair,titre)"
   }	
    
   #------------------------------------------------------------
   #  confToWidget { }
   #     copie les parametres du tableau conf() dans les variables des widgets
   #------------------------------------------------------------
   proc confToWidget {  } {   
      variable private  
      variable widget  
      global conf

      set widget(color)         $conf(crosshair,color) 
      set widget(defaultstate)  $conf(crosshair,defaultstate)   
      set widget(currentstate)  $private(currentstate)
   }

   #------------------------------------------------------------
   #  widgetToConf { }
   #     copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc widgetToConf {  } {   
      variable private
      variable widget  
      global conf

      set conf(crosshair,color)         $widget(color)
      set conf(crosshair,defaultstate)  $widget(defaultstate) 
      set private(currentstate)         $widget(currentstate)    
      
      redrawCrosshair
   }	

   #------------------------------------------------------------
   #  fillConfigPage { }
   #     fenetre de configuration du driver
   #  
   #  return rien
   #
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global audace
      global caption

	#--- je memorise la reference de la frame 
      set widget(frm) $frm
      
	#--- j'initialise les valeurs 
      confToWidget

      #--- Creation des differents frames
      frame $frm.frameState -borderwidth 1 -relief raised
      pack $frm.frameState -side top -fill both -expand 1

      frame $frm.frameColor -borderwidth 1 -relief raised
      pack $frm.frameColor -side top -fill both -expand 1 
      
      #--- current state
      checkbutton $frm.frameState.currentstate -text "$caption(crosshair,current_state_label)" \
         -highlightthickness 0 -variable Crosshair::widget(currentstate)
    	pack $frm.frameState.currentstate -in $frm.frameState -anchor center -side left -padx 10 -pady 5

      #--- default state
      checkbutton $frm.frameState.defaultstate -text "$caption(crosshair,default_state_label)" \
         -highlightthickness 0 -variable Crosshair::widget(defaultstate)
    	pack $frm.frameState.defaultstate -in $frm.frameState -anchor center -side left -padx 10 -pady 5

      #--- color
      label $frm.frameColor.labColor -text "$caption(crosshair,color_label)" -relief flat
	pack $frm.frameColor.labColor -in $frm.frameColor -anchor center -side left -padx 10 -pady 10

      button $frm.frameColor.butColor_color_invariant -relief raised -width 6 -bg $widget(color) \
         -activebackground $widget(color) \
         -command { 
            set temp [tk_chooseColor -initialcolor ${Crosshair::widget(color)} -parent ${Crosshair::widget(frm)} \
               -title ${caption(crosshair,color_crosshair)} ] 
            if  { "$temp" != "" } {  
               set Crosshair::widget(color) "$temp" 
               ${Crosshair::widget(frm)}.frameColor.butColor_color_invariant configure -bg ${Crosshair::widget(color)} \
                  -bg ${Crosshair::widget(color)} 
            }
         }
	pack $frm.frameColor.butColor_color_invariant -in $frm.frameColor -anchor center -side left -padx 10 -pady 5 -ipady 5

   }

   #==============================================================
   # Fonctions specifiques 
   #==============================================================

   #------------------------------------------------------------
   #  toggleCrosshair
   #  toggle drawing/hiding Crosshair 
   #  as check button state indicate 
   #------------------------------------------------------------
   proc toggleCrosshair { } {
      variable private

      if { "$private(currentstate)"=="0"} {
         set private(currentstate) "1"
      } else {
         set private(currentstate) "0"
      }
      redrawCrosshair      
   }

   #------------------------------------------------------------
   #  redrawCrosshair
   #  redraw Crosshair if image size is changed
   #------------------------------------------------------------
   proc redrawCrosshair { } {
      variable private
      global audace
 
      #--- je verifie que l'image existe
      if {[info exists audace(picture,w)] !=1 } {
         update
         return
      }
      
      #--- je masque le reticule
      hideCrosshair
      
      if { "$private(currentstate)" == "1"  } {
         #--- j'affiche le reticule
         displayCrosshair 
      }
      update
   }

   #------------------------------------------------------------
   #  displayCrosshair
   #  draw Crosshair lines ( 1 horizontal line , 1 vertical line)
   #   
   #------------------------------------------------------------
   proc displayCrosshair { } {
      variable private
      global audace   
      global conf

      #--- verify if image exists
      if {[info exists audace(picture,w)]!=1} {
         update
         return
      }
      
      set hCanvas $audace(hCanvas) 
      set private(hCrosshairH) $audace(hCanvas).crosshairH
      set private(hCrosshairV) $audace(hCanvas).crosshairV

      
      #--- je cree le label representant la ligne horizontale
      if { ![winfo exists $private(hCrosshairH)] } {
         label $private(hCrosshairH) -bg $conf(crosshair,color)
      }
      #--- je cree le label representant la ligne verticale
      if { ![winfo exists $private(hCrosshairV)] } {
         label $private(hCrosshairV) -bg $conf(crosshair,color)
      } 

      #--- j'applique la couleur
      $private(hCrosshairH) configure -bg $conf(crosshair,color)
      $private(hCrosshairV) configure -bg $conf(crosshair,color)

      #--- calcul des dimensions en fonction du zoom
      set zoom [visu$audace(visuNo) zoom]
      set w [expr int($zoom*$audace(picture,w))]
      set h [expr int($zoom*$audace(picture,h))]
      
      #--- coordonnees du centre
      set xc [expr $w / 2]
      set yc [expr $h / 2]

      #--- draw horizontal line
      $audace(hCanvas) create window 1 1 -tag lineh -anchor nw -window $private(hCrosshairH) -height 1
      $audace(hCanvas) coords lineh 0 $yc
      $audace(hCanvas) itemconfigure lineh -width $w  
      $audace(hCanvas) itemconfigure lineh -state normal 
      raise $private(hCrosshairH)
      
      #--- draw vertical line
      $audace(hCanvas) create window 1 1 -tag linev -anchor nw -window $private(hCrosshairV) -width 1
      $audace(hCanvas) coords linev $xc 0
      $audace(hCanvas) itemconfigure linev -height $h 
      $audace(hCanvas) itemconfigure linev -state normal
      raise $private(hCrosshairV)
      
      #--- store current image size   
      set private(imageSize) [list $audace(picture,w) $audace(picture,w)]
   }

   #------------------------------------------------------------
   #  hideCrosshair
   #  hiding Crosshair lines 
   #   
   #------------------------------------------------------------
   proc hideCrosshair {} {
      global audace
 
      $audace(hCanvas) delete lineh
      $audace(hCanvas) delete linev
   }

   #------------------------------------------------------------
   #  showHelp
   #  aide 
   #   
   #------------------------------------------------------------
   proc showHelp {} {
      global help
 
      ::audace::showHelpItem "$help(dir,affichage)" "1100crosshair.htm"
   }

}

::Crosshair::init

