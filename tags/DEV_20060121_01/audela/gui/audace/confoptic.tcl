#
# Fichier : confoptic.tcl
# Description : Affiche la fenetre de configuration de l'optique
# Auteur : Robert DELMAS
# Date de mise a jour : 26 juillet 2005
#

namespace eval ::confOptic {  

   #------------------------------------------------------------
   #  init 
   #     initialise le driver 
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      global audace  

      uplevel #0  "source \"[ file join $audace(rep_caption) confoptic.cap ]\""
      initConf
      return [namespace current]
   }

   #------------------------------------------------------------
   #  initConf{ }
   #     initialise les parametres dans le tableau conf()
   #------------------------------------------------------------
   proc initConf { } {
      global conf
      global caption

      if { ! [ info exists conf(confoptic,position) ] } { set conf(confoptic,position) "+150+75" }

      if { ! [ info exists conf(confoptic,combinaison_optique,0) ] } { 
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 $caption(confoptic,sans_accessoire)"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "1.0"
        
         set conf(confoptic,combinaison_optique,0) [ array get combinaison_optique ] 
      }
      
      if { ! [ info exists conf(confoptic,combinaison_optique,1) ] } { 
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 + $caption(confoptic,reducteur) 0.66"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "0.66"
         
         set conf(confoptic,combinaison_optique,1) [ array get combinaison_optique ] 
      }

      if { ! [ info exists conf(confoptic,combinaison_optique,2) ] } { 
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 + $caption(confoptic,reducteur) 0.33"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "0.33"
         
         set conf(confoptic,combinaison_optique,2) [ array get combinaison_optique ] 
      }

      if { ! [ info exists conf(confoptic,combinaison_optique,3) ] } { 
         #--- Je prepare un exemple de configuration optique
         array set combinaison_optique { }
         set combinaison_optique(instrument)       "C8 + $caption(confoptic,barlow) 2.5"
         set combinaison_optique(diametre)         "203.0"
         set combinaison_optique(focale)           "2000.0"
         set combinaison_optique(barlow_reduc)     "2.5"
         
         set conf(confoptic,combinaison_optique,3) [ array get combinaison_optique ] 
      }
      
      if { ! [ info exists conf(confoptic,combinaison_optique,4) ] } { set conf(confoptic,combinaison_optique,4) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,5) ] } { set conf(confoptic,combinaison_optique,5) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,6) ] } { set conf(confoptic,combinaison_optique,6) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,7) ] } { set conf(confoptic,combinaison_optique,7) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,8) ] } { set conf(confoptic,combinaison_optique,8) "" }
      if { ! [ info exists conf(confoptic,combinaison_optique,9) ] } { set conf(confoptic,combinaison_optique,9) "" }
   }     

   #==============================================================
   # Fonctions de configuration generiques
   #
   # getLabel       : retourne le titre de la fenetre de config
   # confToWidget   : copie les parametres du tableau conf() dans les variables des widgets
   # widgetToConf   : copie les variables des widgets dans le tableau conf()
   # fillConfigPage : affiche la fenetre de config
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

      return "$caption(confoptic,config_optique)"
   }

   #------------------------------------------------------------
   #  confToWidget { }
   #     copie les parametres du tableau conf() dans les variables des widgets
   #------------------------------------------------------------
   proc confToWidget {  } {   
      variable widget 
      global conf

      #--- Je prepare les valeurs de la combobox
      set widget(config_instrument) ""
      foreach {key value} [ array get conf confoptic,combinaison_optique,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set combinaison_optique $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$combinaison_optique(instrument) - $combinaison_optique(diametre) - $combinaison_optique(focale) -\
            $combinaison_optique(barlow_reduc)"         
         #--- J'ajoute la ligne
         lappend widget(config_instrument) "$line"
      }      
                  
      #--- Autre widget sauvegarde dans conf()
      set widget(position) "$conf(confoptic,position)"
   }

   #------------------------------------------------------------
   #  widgetToConf { }
   #     copie les variables des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc widgetToConf {  } {   
      variable widget
      variable private
      global conf

      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(diametre) [ format "%.1f" $confOptic::widget(diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(diametre)

      set confOptic::widget(focale) [ format "%.1f" $confOptic::widget(focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(focale)

      #--- Je mets a jour la combobox
      set confOptic::widget(config_instrument) "$confOptic::widget(instrument) - $confOptic::widget(diametre) -\
         $confOptic::widget(focale) - $confOptic::widget(barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(config_instrument)

      #--- Mise a jour des parametres calcules
      ::confOptic::Calculette

      #--- Je copie les valeurs des widgets
      set private(instrument)   $widget(instrument)       
      set private(diametre)     $widget(diametre)          
      set private(focale)       $widget(focale)           
      set private(barlow_reduc) $widget(barlow_reduc)        

      #--- J'ajoute linstrument en tete dans le tableau des instruments precedents si elle n'y est pas deja 
      array set combinaison_optique { }
      set combinaison_optique(instrument)   "$private(instrument)"
      set combinaison_optique(diametre)     "$private(diametre)"
      set combinaison_optique(focale)       "$private(focale)"
      set combinaison_optique(barlow_reduc) "$private(barlow_reduc)"

      #--- Je copie conf dans templist en mettant l'instrument courant en premier
      array set templist { }
      set templist(0) [ array get combinaison_optique ]
      set j "1"
      foreach {key value} [ array get conf confoptic,combinaison_optique,* ] {
         if { "$value" == "" } {
            set templist($j) ""
            incr j
         } else {
            array set temp1 $value
            if { "$temp1(instrument)" != "$combinaison_optique(instrument)" } {
               set templist($j) [ array get temp1 ]
               incr j
            }
         }          
      }      
      
      #-- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(confoptic,combinaison_optique,$i) $templist($i)
      }

      #--- Je mets la position actuelle de la fenetre dans conf()      
      set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(confoptic,position) "+[ string range $geom $deb $fin ]"
   }

   #------------------------------------------------------------
   #  ftpclient::cbCommand { }  
   #  (appelee par la combobox a chaque changement de selection)
   #  affiche les valeurs dans les widgets
   #  
   #  return rien
   #------------------------------------------------------------
   proc cbCommand { cb } {
      variable widget
      global conf
      
      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration optique de conf()     
      array set combinaison_optique $conf(confoptic,combinaison_optique,$index)

      #--- Je copie les valeurs dans les widgets
      set widget(instrument)   $combinaison_optique(instrument)
      set widget(diametre)     $combinaison_optique(diametre)
      set widget(focale)       $combinaison_optique(focale)
      set widget(barlow_reduc) $combinaison_optique(barlow_reduc)
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
      global color
      global conf

	#--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Je position la fenetre 
      wm geometry [ winfo toplevel $widget(frm) ] $conf(confoptic,position)

	#--- J'initialise les valeurs
      confToWidget

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 1 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame4 -borderwidth 1 -relief raised
      pack $frm.frame4 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame5 -borderwidth 1 -relief raised
      pack $frm.frame5 -in $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame6 -borderwidth 1 -relief raised
      pack $frm.frame6 -in $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame5 -side left -fill both -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame5 -side left -fill both -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame6 -side left -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame6 -side left -fill both -expand 1

      #--- Donnees caracteristiques de l'optique
      label $frm.labModele -text "$caption(confoptic,modele_instrument)" -relief flat
      pack $frm.labModele -in $frm.frame7 -anchor w -side top -padx 10 -pady 5

      ComboBox $frm.comboboxModele \
         -width 45         \
         -relief sunken    \
         -borderwidth 2    \
         -editable 1       \
         -textvariable ::confOptic::widget(config_instrument) \
         -modifycmd  { ::confOptic::cbCommand  $frm.comboboxModele } \
         -values $widget(config_instrument)
	pack $frm.comboboxModele -in $frm.frame8 -anchor w -side top -padx 10 -pady 5

      label $frm.labInstrument -text "$caption(confoptic,instrument)" -relief flat
      pack $frm.labInstrument -in $frm.frame7 -anchor w -side top -padx 30 -pady 5

      entry $frm.entInstrument -textvariable confOptic::widget(instrument) -width 30
      pack $frm.entInstrument -in $frm.frame8 -anchor w -side top -padx 10 -pady 5

      label $frm.labDiametre -text "$caption(confoptic,diametre)" -relief flat
      pack $frm.labDiametre -in $frm.frame7 -anchor w -side top -padx 30 -pady 5

      entry $frm.entDiametre -textvariable confOptic::widget(diametre) -width 8
      pack $frm.entDiametre -in $frm.frame8 -anchor w -side top -padx 10 -pady 5

      label $frm.labFocale -text "$caption(confoptic,focale)" -relief flat
      pack $frm.labFocale -in $frm.frame7 -anchor w -side top -padx 30 -pady 5

      entry $frm.entFocale -textvariable confOptic::widget(focale) -width 8
      pack $frm.entFocale -in $frm.frame8 -anchor w -side top -padx 10 -pady 5

      label $frm.labBarlow_Reduc -text "$caption(confoptic,barlow_reduc)" -relief flat
      pack $frm.labBarlow_Reduc -in $frm.frame7 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list 0.33 0.5 0.66 1.0 1.5 2.0 2.5 3.0 3.5 4.0 5.0 ]
      ComboBox $frm.comboboxBarlow_Reduc \
         -width 5          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 2    \
         -editable 1       \
         -textvariable confOptic::widget(barlow_reduc) \
         -values $list_combobox
      pack $frm.comboboxBarlow_Reduc -in $frm.frame8 -anchor w -side top -padx 10 -pady 5

      #--- Informations de l'instrument calculees
      label $frm.labFoc_Result -text "$caption(confoptic,focale_result)" -relief flat
      pack $frm.labFoc_Result -in $frm.frame9 -anchor w -side top -padx 10 -pady 5

      label $frm.labVal_Foc_Result -text "" -relief flat
      pack $frm.labVal_Foc_Result -in $frm.frame10 -anchor w -side top -padx 0 -pady 5

      label $frm.labF/D -text "$caption(confoptic,rapport_F/D)" -relief flat
      pack $frm.labF/D -in $frm.frame9 -anchor w -side top -padx 10 -pady 5

      label $frm.labVal_F/D -text "" -relief flat
      pack $frm.labVal_F/D -in $frm.frame10 -anchor w -side top -padx 0 -pady 5

      label $frm.labP_Separateur -text "$caption(confoptic,pouvoir_separateur)" -relief flat
      pack $frm.labP_Separateur -in $frm.frame9 -anchor w -side top -padx 10 -pady 5

      label $frm.labVal_PS -text "" -relief flat
      pack $frm.labVal_PS -in $frm.frame10 -anchor w -side top -padx 0 -pady 5

      #--- Informations liees a la camera CCD
      if { [ ::cam::list ] != "" } {
         set camera "[ lindex [ cam$audace(camNo) info ] 1 ]"
         set capteur "[ lindex [ cam$audace(camNo) info ] 2 ]"
         set fg $color(blue)
      } else {
         set camera $caption(confoptic,nocam)
         set capteur ""
         set fg $color(red)
      }

      label $frm.labCamera -text "$caption(confoptic,camera)" -relief flat
      pack $frm.labCamera -in $frm.frame11 -anchor w -side top -padx 10 -pady 5

      label $frm.labURL_nomCamera -font $audace(font,url) -text $camera -fg $fg
      pack $frm.labURL_nomCamera -in $frm.frame12 -anchor w -side top -padx 0 -pady 5

      label $frm.labCapteurCCD -text "$caption(confoptic,capteur_ccd)" -relief flat
      pack $frm.labCapteurCCD -in $frm.frame11 -anchor w -side top -padx 10 -pady 5

      label $frm.labURL_typeCapteur -text $capteur
      pack $frm.labURL_typeCapteur -in $frm.frame12 -anchor w -side top -padx 0 -pady 5

      label $frm.labChamp -text "$caption(confoptic,champ)" -relief flat
      pack $frm.labChamp -in $frm.frame11 -anchor w -side top -padx 10 -pady 5

      label $frm.labVal_Champ -text "" -relief flat
      pack $frm.labVal_Champ -in $frm.frame12 -anchor w -side top -padx 0 -pady 5

      label $frm.labEchant -text "$caption(confoptic,echantillonnage)" -relief flat
      pack $frm.labEchant -in $frm.frame11 -anchor w -side top -padx 10 -pady 5

      label $frm.labVal_Echantillonnage -text "" -relief flat
      pack $frm.labVal_Echantillonnage -in $frm.frame12 -anchor w -side top -padx 0 -pady 5

      #--- Je selectionne le premier element de la combobox
      $frm.comboboxModele setvalue first
      cbCommand $frm.comboboxModele 

      #--- Calcul
      button $frm.but_Calcul -text "$caption(confoptic,calcul)" -relief raised -width 15 \
         -command { ::confOptic::Calculette }
      pack $frm.but_Calcul -in $frm.frame4 -anchor center -side left -expand true -padx 10 -pady 5 -ipady 5

      #--- Calcul des parametres du systeme optique
      ::confOptic::Calculette

      #--- Bind pour la camera CCD
      bind $frm.labURL_nomCamera <ButtonPress-1> {
         ::confCam::run
         tkwait window $audace(base).confCam
         if { [ ::cam::list ] != "" } {
            set camera "[ lindex [ cam$audace(camNo) info ] 1 ]"
            set capteur "[ lindex [ cam$audace(camNo) info ] 2 ]"
            set fg $color(blue)
         } else {
            set camera $caption(confoptic,nocam)
            set capteur ""
            set fg $color(red)
         }
         $::confOptic::widget(frm).labURL_nomCamera configure -text $camera -fg $fg
         $::confOptic::widget(frm).labURL_typeCapteur configure -text $capteur
         ::confOptic::Calculette
         update
      }
   }

   #==============================================================
   # Fonctions specifiques 
   #==============================================================

   #------------------------------------------------------------
   #  Calculette
   #  calcule les differents parametres de l'instrument 
   #   
   #------------------------------------------------------------
   proc Calculette { } {
      variable widget
      global audace

      #--- Je formate les entry pour permettre le calcul decimal
      set confOptic::widget(diametre) [ format "%.1f" $confOptic::widget(diametre) ]
      $confOptic::widget(frm).entDiametre configure -textvariable confOptic::widget(diametre)

      set confOptic::widget(focale) [ format "%.1f" $confOptic::widget(focale) ]
      $confOptic::widget(frm).entFocale configure -textvariable confOptic::widget(focale)

      #--- Je mets a jour la combobox
      set confOptic::widget(config_instrument) "$confOptic::widget(instrument) - $confOptic::widget(diametre) -\
         $confOptic::widget(focale) - $confOptic::widget(barlow_reduc)"
      $confOptic::widget(frm).comboboxModele configure -textvariable confOptic::widget(config_instrument)

      #--- Calcul de la focale resultante du systeme optique
      set confOptic::widget(focale_resultante) [ expr $confOptic::widget(focale) * $confOptic::widget(barlow_reduc) ]
      $confOptic::widget(frm).labVal_Foc_Result configure -text $confOptic::widget(focale_resultante)

      #--- Calcul du rapport F/D du systeme optique
      set confOptic::widget(F/D) [ format "%.1f" \
         [ expr $confOptic::widget(focale_resultante) / $confOptic::widget(diametre) ] ]
      $confOptic::widget(frm).labVal_F/D configure -text $confOptic::widget(F/D)

      #--- Calcul du pouvoir separateur du systeme optique
      set confOptic::widget(PS) [ format "%.2f" [ expr 120.0 / $confOptic::widget(diametre) ] ]
      $confOptic::widget(frm).labVal_PS configure -text $confOptic::widget(PS)

      #--- Calcul du champ et de l'echantillonnage du CCD
      if { [ ::cam::list ] != "" } {
         #--- Nombres de pixels en x et en y
         set nb_xy [ cam$audace(camNo) nbpix ]
         #--- Dimensions des pixels en x et en y
         set dim_pix_xy [ cam$audace(camNo) pixdim ]
         #--- Dimensions du CCD en x et en y
         set dim_x [ expr [ lindex $nb_xy 0 ] * [ lindex $dim_pix_xy 0 ] * 1000. ]
         set dim_y [ expr [ lindex $nb_xy 1 ] * [ lindex $dim_pix_xy 1 ] * 1000. ]
         #--- Champ en x et en y en minutes d'arc
         set champ_x [ format "%.1f" [ expr 206265 * $dim_x / ( $confOptic::widget(focale_resultante) * 60. ) ] ]
         set champ_y [ format "%.1f" [ expr 206265 * $dim_y / ( $confOptic::widget(focale_resultante) * 60. ) ] ]
         $confOptic::widget(frm).labVal_Champ configure -text "$champ_x x $champ_y"
         #--- Echantillonnage du CCD en x et en y en secondes d'arc par pixels
         set echantillonnage_x [ format "%.1f"  [ expr $champ_x * 60. / [ lindex $nb_xy 0 ] ] ]
         set echantillonnage_y [ format "%.1f"  [ expr $champ_y * 60. / [ lindex $nb_xy 1 ] ] ]
         $confOptic::widget(frm).labVal_Echantillonnage configure -text "$echantillonnage_x x $echantillonnage_y"
      }
   }

   #------------------------------------------------------------
   #  showHelp
   #  aide 
   #   
   #------------------------------------------------------------
   proc showHelp { } {
      global help
 
      ::audace::showHelpItem "$help(dir,optic)" "1010config_optique.htm"
   }

}

::confOptic::init

