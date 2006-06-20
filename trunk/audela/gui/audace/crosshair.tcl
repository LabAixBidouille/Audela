#
# Fichier : crosshair.tcl
# Description : Affiche un reticule sur l'image
# Auteur : Michel PUJOL
# Mise a jour $Id: crosshair.tcl,v 1.5 2006-06-20 17:27:58 robertdelmas Exp $
#

namespace eval ::Crosshair {

   array set widget { }

   #------------------------------------------------------------
   #  init
   #     initialise le driver
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      variable private
      global audace

      uplevel #0 "source \"[file join $audace(rep_caption) crosshair.cap]\""

      initConf
      set private(imageSize) " "

      return [namespace current]
   }

   #------------------------------------------------------------
   #  initConf{ }
   #     initialise les parametres dans le tableau conf()
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(crosshair,color) ] }        { set conf(crosshair,color)        "#FF0000" }
      if { ! [ info exists conf(crosshair,defaultstate) ] } { set conf(crosshair,defaultstate) "0" }
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
   proc confToWidget { visuNo } {
      variable widget
      global conf

      set widget(color)        $conf(crosshair,color)
      set widget(defaultstate) $conf(crosshair,defaultstate)
      set widget(currentstate) [::confVisu::getCrosshair $visuNo]
   }

   #------------------------------------------------------------
   #  widgetToConf { }
   #     copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc widgetToConf { visuNo } {
      variable widget
      global conf

      set conf(crosshair,color)        $widget(color)
      set conf(crosshair,defaultstate) $widget(defaultstate)

      ::confVisu::setCrosshair $visuNo $widget(currentstate)
   }

   #------------------------------------------------------------
   #  fillConfigPage { }
   #     fenetre de configuration du driver
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc fillConfigPage { frm visuNo } {
      variable widget
      global caption

      #--- je memorise la reference de la frame
      set widget(frm) $frm
      
      #--- j'initialise les valeurs
      confToWidget $visuNo

      #--- creation des differents frames
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
         -activebackground $widget(color) -command "::Crosshair::changeColor $frm"
      pack $frm.frameColor.butColor_color_invariant -in $frm.frameColor -anchor center -side left -padx 10 -pady 5 -ipady 5

   }

   #==============================================================
   # Fonctions specifiques 
   #==============================================================

   #------------------------------------------------------------
   #  showHelp
   #  aide 
   #   
   #------------------------------------------------------------
   proc showHelp { } {
      global help

      ::audace::showHelpItem "$help(dir,affichage)" "1100crosshair.htm"
   }

   #------------------------------------------------------------
   #  changeColor
   #  change la couleur du reticule 
   #   
   #------------------------------------------------------------
   proc changeColor { frm } {
      variable widget
      global caption

      set temp [tk_chooseColor -initialcolor $::Crosshair::widget(color) -parent ${Crosshair::widget(frm)} \
         -title ${caption(crosshair,color_crosshair)} ] 
      if  { "$temp" != "" } {  
         set Crosshair::widget(color) "$temp" 
         ${Crosshair::widget(frm)}.frameColor.butColor_color_invariant configure \
            -bg $::Crosshair::widget(color) -bg $::Crosshair::widget(color) 
      }
   }

}

::Crosshair::init

