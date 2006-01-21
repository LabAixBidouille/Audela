#
# Fichier : audecom.tcl
# Description : Parametrage et pilotage de la carte AudeCom (Ex-Kauffmann)
# Auteurs : Robert DELMAS et Philippe KAUFFMANN
# Date de mise a jour : 16 novembre 2005
#

#
# paramot / AudecomMot
# Description : Fenetre de configuration pour le parametrage des moteurs pour AudeCom
#

# Initialisation de la variable confTel(audecom,connect)
# Initialisation de la variable confgene(espion) pour supprimer la ligne TU=HL-Xh si l'heure de l'ordinateur est en TU
global confTel
global confgene

#--- Initialisation de variables
set confTel(audecom,connect) "0"
set confgene(espion)         "1" 

namespace eval confAudecomMot {
   variable This
   global confAudecomMot

   #
   # confAudecomMot::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables caption(...) 
   #
   proc init { } {
      global audace   
 
      #--- Charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_plugin) mount audecom audecom.cap ]\""
   }

   #
   # confAudecomMot::run this
   # Cree la fenetre de configuration des parametres moteurs
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog 
      tkwait visibility $This
   }

   #
   # confAudecomMot::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre des parametres moteurs
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confAudecomMot::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confAudecomMot::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confTel
      global confAudecomMot
      global confAudecom

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(audecom,para_mot)
      set posx_audecom_para_mot [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
      set posy_audecom_para_mot [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_audecom_para_mot + 0 ]+[ expr $posy_audecom_para_mot + 70 ]
      wm resizable $This 0 0

      #--- On utilise les valeurs contenues dans le tableau confTel pour l'initialisation
      set confAudecomMot(conf_audecom,rat_ad)  $confTel(conf_audecom,rat_ad)
      set confAudecomMot(conf_audecom,rat_dec) $confTel(conf_audecom,rat_dec)
      set confAudecomMot(conf_audecom,maxad)   $confTel(conf_audecom,maxad)
      set confAudecomMot(conf_audecom,maxdec)  $confTel(conf_audecom,maxdec)
      set confAudecomMot(conf_audecom,limp)    $confTel(conf_audecom,limp)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill x

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame3 -side left -fill y

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in $This.frame3 -side left -fill x

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame10 -borderwidth 0 -relief raised
      pack $This.frame10 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame11 -borderwidth 0 -relief raised
      pack $This.frame11 -in $This.frame6 -side top -fill none

      frame $This.frame12 -borderwidth 0 -relief raised
      pack $This.frame12 -in $This.frame6 -side top -fill none

      frame $This.frame13 -borderwidth 0 -relief raised
      pack $This.frame13 -in $This.frame7 -side top -fill both -expand 1

      frame $This.frame14 -borderwidth 0 -relief raised
      pack $This.frame14 -in $This.frame7 -side top -fill both -expand 1

      frame $This.frame15 -borderwidth 0 -relief raised
      pack $This.frame15 -in $This.frame8 -side bottom -fill both -expand 1

      frame $This.frame16 -borderwidth 0 -relief raised
      pack $This.frame16 -in $This.frame8 -side bottom -fill both -expand 1

      frame $This.frame17 -borderwidth 0 -relief raised
      pack $This.frame17 -in $This.frame8 -side bottom -fill both -expand 1

      frame $This.frame18 -borderwidth 0 -relief raised
      pack $This.frame18 -in $This.frame8 -side bottom -fill both -expand 1

      #--- Cree le bouton 'Aide' du rattrapage des jeux en AD et Dec. 
      button $This.but_aide0 -text "$caption(audecom,aide)" -height 3 -width 2 -borderwidth 2 \
         -command { ::confAudecomMot::aide0 } 
	pack $This.but_aide0 -in $This.frame5 -anchor center -side left -padx 10 -pady 0

      #--- De l'amplitude du rattrapage des jeux en A.D.
      label $This.lab1 -text "$caption(audecom,rat_jeu_ad)"
	pack $This.lab1 -in $This.frame11 -anchor w -side left -padx 5 -pady 5

      catch {
         entry $This.rat_ad -textvariable confAudecomMot(conf_audecom,rat_ad) -width 5 -justify center
	   pack $This.rat_ad -in $This.frame13 -anchor w -side left -padx 5 -pady 5
      }

      #--- De l'amplitude du rattrapage des jeux en Dec.
      label $This.lab2 -text "$caption(audecom,rat_jeu_dec)"
	pack $This.lab2 -in $This.frame12 -anchor w -side left -padx 5 -pady 5

      catch {
         entry $This.rat_dec -textvariable confAudecomMot(conf_audecom,rat_dec) -width 5 -justify center
	   pack $This.rat_dec -in $This.frame14 -anchor w -side left -padx 5 -pady 5
      }

      #--- Rappelle les valeurs par defaut programmees dans le microcontroleur
      label $This.lab3 -text "$caption(audecom,val_defaut)"
	pack $This.lab3 -in $This.frame9 -anchor center -side top -padx 0 -pady 5

      #--- De la largeur des impulsions
      catch {
         label $This.lab4 -text "$conf(audecom,dlimp)"
	   pack $This.lab4 -in $This.frame9 -anchor center -side bottom -padx 0 -pady 11
      }

      #--- De la vitesse maxi en Dec.
      catch {
         label $This.lab5 -text "$conf(audecom,dmaxdec)"
	   pack $This.lab5 -in $This.frame9 -anchor center -side bottom -padx 0 -pady 11
      }

      #--- De la vitesse maxi en A.D.
      catch {
         label $This.lab6 -text "$conf(audecom,dmaxad)"
	   pack $This.lab6 -in $This.frame9 -anchor center -side bottom -padx 0 -pady 11
      }

      #--- Rapelle les limites de ces valeurs
      label $This.lab7 -text "$caption(audecom,limites)"
	pack $This.lab7 -in $This.frame10 -anchor center -side top -padx 0 -pady 5

      #--- De la largeur des impulsions
      catch {
         label $This.lab8 -text "$conf(audecom,dlimpmin) $caption(audecom,a)\
            $conf(audecom,dlimpmax)"
	   pack $This.lab8 -in $This.frame10 -anchor center -side bottom -padx 0 -pady 11
      }

      #--- De la vitesse maxi en Dec.
      catch {
         label $This.lab9 -text "$conf(audecom,dmaxdecmin) $caption(audecom,a)\
            $conf(audecom,dmaxdecmax)"
	   pack $This.lab9 -in $This.frame10 -anchor center -side bottom -padx 0 -pady 11
      }

      #--- De la vitesse maxi en A.D.
      catch {
         label $This.lab10 -text "$conf(audecom,dmaxadmin) $caption(audecom,a)\
            $conf(audecom,dmaxadmax)"
	   pack $This.lab10 -in $This.frame10 -anchor center -side bottom -padx 0 -pady 11
      }

      #--- Cree le bouton 'Aide' de la vitesse maxi en A.D. 
      button $This.but_aide1 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomMot::aide1 }
	pack $This.but_aide1 -in $This.frame17 -anchor center -side left -padx 10 -pady 5

      #--- De la vitesse maxi en A.D.
      label $This.lab11 -text "$caption(audecom,max_AD)"
	pack $This.lab11 -in $This.frame17 -anchor center -side left -padx 0 -pady 5

      catch {
         entry $This.limp -textvariable confAudecomMot(conf_audecom,maxad) -width 5 -justify center
	   pack $This.limp -in $This.frame17 -anchor center -side right -padx 5 -pady 5
      }

      #--- Cree le bouton 'Aide' de la vitesse maxi en Dec. 
      button $This.but_aide2 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomMot::aide2 }
	pack $This.but_aide2 -in $This.frame16 -anchor center -side left -padx 10 -pady 5

      #--- De la vitesse maxi en Dec.
      label $This.lab12 -text "$caption(audecom,max_Dec)"
	pack $This.lab12 -in $This.frame16 -anchor center -side left -padx 0 -pady 5

      catch {
         entry $This.maxad -textvariable confAudecomMot(conf_audecom,maxdec) -width 5 -justify center
	   pack $This.maxad -in $This.frame16 -anchor center -side right -padx 5 -pady 5
      }

      #--- Cree le bouton 'Aide' de la largeur des impulsions 
      button $This.but_aide3 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomMot::aide3 } 
	pack $This.but_aide3 -in $This.frame15 -anchor center -side left -padx 10 -pady 5

      #--- De la largeur des impulsions
      label $This.lab13 -text "$caption(audecom,larg_imp)"
	pack $This.lab13 -in $This.frame15 -anchor center -side left -padx 0 -pady 5

      catch {
         entry $This.maxdec -textvariable confAudecomMot(conf_audecom,limp) -width 5 -justify center
	   pack $This.maxdec -in $This.frame15 -anchor center -side right -padx 5 -pady 5
      }

      #--- Cree le bouton 'OK' 
      button $This.but_ok -text "$caption(audecom,ok)" -width 7 -borderwidth 2 \
         -command { ::confAudecomMot::ok } 
      pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Annuler' 
      button $This.but_cancel -text "$caption(audecom,annuler)" -width 10 -borderwidth 2 \
         -command { ::confAudecomMot::fermer  } 
      pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree la console texte d'aide
      text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
      pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
      $This.lst1 insert end " \n"
      $This.lst1 insert end "$caption(audecom,para_mot,aide01)\n"
      $This.lst1 insert end "$caption(audecom,para_mot,aide02)\n"
      $This.lst1 insert end "$caption(audecom,para_mot,aide03)\n"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAudecomMot::aide0
   # Affiche l'aide pour le choix de l'amplitude du rattrapage des jeux en A.D. et Dec.
   #
   proc aide0 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecom,para_mot,aide05)\n"
   $This.lst1 insert end "$caption(audecom,para_mot,aide06)\n"
   $This.lst1 insert end " \n"
   $This.lst1 see insert
   }

   #
   # confAudecomMot::aide1
   # Affiche l'aide pour le choix de la vitesse maxi en A.D.
   #
   proc aide1 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "$caption(audecom,para_mot,aide11)\n"
   $This.lst1 insert end "$caption(audecom,para_mot,aide12)\n"
   $This.lst1 insert end "$caption(audecom,para_mot,aide13)\n"
   $This.lst1 see insert
   }

   #
   # confAudecomMot::aide2
   # Affiche l'aide pour le choix de la vitesse maxi en Dec.
   #
   proc aide2 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "$caption(audecom,para_mot,aide11)\n"
   $This.lst1 insert end "$caption(audecom,para_mot,aide12)\n"
   $This.lst1 insert end "$caption(audecom,para_mot,aide21)\n"
   $This.lst1 see insert
   }

   #
   # confAudecomMot::aide3
   # Affiche l'aide pour le choix de la largeur de l'impulsion
   #
   proc aide3 { } {
   variable This
   global conf
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "[eval [concat {format} {$caption(audecom,para_mot,aide31) $conf(audecom,dlimprecouv) \
      $conf(audecom,dlimpmin) $conf(audecom,dlimpmin) $conf(audecom,dlimpmax) $conf(audecom,dlimpmin)}]]"
   $This.lst1 see insert
   }

   #
   # confAudecomMot::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global confAudecomMot
      global confTel

      set confTel(conf_audecom,rat_ad)  $confAudecomMot(conf_audecom,rat_ad)
      set confTel(conf_audecom,rat_dec) $confAudecomMot(conf_audecom,rat_dec)
      set confTel(conf_audecom,maxad)   $confAudecomMot(conf_audecom,maxad)
      set confTel(conf_audecom,maxdec)  $confAudecomMot(conf_audecom,maxdec)
      set confTel(conf_audecom,limp)    $confAudecomMot(conf_audecom,limp)
   }
}

#
# parafoc / AudecomFoc
# Description :Fenetre de configuration pour le parametrage de la focalisation pour AudeCom
#

namespace eval confAudecomFoc {
   variable This
   global confAudecomFoc

   #
   # confAudecomFoc::run this args
   # Cree la fenetre de configuration des parametres de la focalisation
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog 
      tkwait visibility $This
   }

   #
   # confAudecomFoc::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre des parametres de la focalisation
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confAudecomFoc::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confAudecomFoc::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confTel
      global confAudecomFoc

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(audecom,para_foc)
      set posx_audecom_para_foc [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
      set posy_audecom_para_foc [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_audecom_para_foc + 0 ]+[ expr $posy_audecom_para_foc + 70 ]
      wm resizable $This 0 0

      #--- On utilise les valeurs contenues dans le tableau confTel pour l'initialisation
      set confAudecomFoc(conf_audecom,vitesse)     $confTel(conf_audecom,vitesse)
      set confAudecomFoc(conf_audecom,intra_extra) $confTel(conf_audecom,intra_extra)
      set confAudecomFoc(conf_audecom,inv_rot)     $confTel(conf_audecom,inv_rot)
      set confAudecomFoc(conf_audecom,dep_val)     $confTel(conf_audecom,dep_val)

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

      #--- Cree le bouton 'Aide' de la vitesse du moteur 
      button $This.but_aide1 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomFoc::aide1 }
	pack $This.but_aide1 -in $This.frame3 -anchor center -side left -padx 10 -pady 5

      #--- Etiquette vitesse du moteur
      label $This.lab1 -text "$caption(audecom,vit_foc)"
	pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

      #--- Cree la zone a renseigner de la vitesse du moteur
      catch {
         entry $This.vitmotfoc -textvariable confAudecomFoc(conf_audecom,vitesse) -width 5 -justify center
	   pack $This.vitmotfoc -in $This.frame3 -anchor center -side left -padx 5 -pady 5
      }

      #--- Etiquette des limites de la vitesse moteur
      label $This.lab2 -text "$caption(audecom,limite_vit)"
	pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

      #--- Cree le bouton 'Aide' de la direction du mouvement 
      button $This.but_aide2 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomFoc::aide2 }
	pack $This.but_aide2 -in $This.frame4 -anchor center -side left -padx 10 -pady 5

      #--- Etiquette direction du mouvement
      label $This.lab3 -text "$caption(audecom,direction)"
	pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_1 -width 10
      pack $This.lab_invisible_1 -in $This.frame5 -side left -anchor w -padx 10 -pady 5

      #--- Radio-bouton intrafocal
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(audecom,intra_focal)" -value 0 -variable confAudecomFoc(conf_audecom,intra_extra)
	pack $This.rad1 -in $This.frame5 -anchor center -side left -padx 3 -pady 5

      #--- Radio-bouton extrafocal
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(audecom,extra_focal)" -value 1 -variable confAudecomFoc(conf_audecom,intra_extra)
	pack $This.rad2 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_2 -width 10 -borderwidth 0
      pack $This.lab_invisible_2 -in $This.frame6 -side left -anchor w -padx 10 -pady 5

      #--- Inversion du sens de rotation du moteur
      checkbutton $This.invrot -text "$caption(audecom,inversion_rot)" -highlightthickness 0 \
         -variable confAudecomFoc(conf_audecom,inv_rot)
	pack $This.invrot -in $This.frame6 -anchor center -side left -padx 5 -pady 5

      #--- Cree le bouton 'Aide' de la consigne pour le rattrapage des jeux
      button $This.but_aide3 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomFoc::aide3 }
	pack $This.but_aide3 -in $This.frame7 -anchor center -side left -padx 10 -pady 5

      #--- Etiquette consigne pour le rattrapage des jeux
      label $This.lab4 -text "$caption(audecom,valeur_dep)"
	pack $This.lab4 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_3 -width 11 -borderwidth 0
      pack $This.lab_invisible_3 -in $This.frame8 -side left -anchor w -padx 10 -pady 5

      #--- Cree la zone a renseigner de la consigne du rattrapage des jeux
      catch {
         entry $This.depval -textvariable confAudecomFoc(conf_audecom,dep_val) -width 5 -justify center
	   pack $This.depval -in $This.frame8 -anchor center -side left -padx 5 -pady 5
      }

      #--- Etiquette de l'unite (pas) pour la consigne
      label $This.lab5 -text "$caption(audecom,pas)"
	pack $This.lab5 -in $This.frame8 -anchor center -side left -padx 5 -pady 5

      #--- Cree le bouton 'OK' 
      button $This.but_ok -text "$caption(audecom,ok)" -width 7 -borderwidth 2 \
         -command { ::confAudecomFoc::ok } 
      pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Annuler' 
      button $This.but_cancel -text "$caption(audecom,annuler)" -width 10 -borderwidth 2 \
         -command { ::confAudecomFoc::fermer  } 
      pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree la console texte d'aide
      text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
      pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
      $This.lst1 insert end " \n"
      $This.lst1 insert end "$caption(audecom,para_foc,aide01)\n"
      $This.lst1 insert end "$caption(audecom,para_foc,aide02)\n"
      $This.lst1 insert end "$caption(audecom,para_foc,aide03)\n"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAudecomFoc::aide1
   # Affiche l'aide pour le choix de la vitesse du moteur
   #
   proc aide1 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecom,para_foc,aide1)\n"
   $This.lst1 see insert
   }

   #
   # confAudecomFoc::aide2
   # Affiche l'aide pour le choix de la direction du mouvement
   #
   proc aide2 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecom,para_foc,aide2)\n"
   $This.lst1 see insert
   }

   #
   # confAudecomFoc::aide3
   # Affiche l'aide pour le choix de la consigne du rattrapage des jeux
   #
   proc aide3 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecom,para_foc,aide3)\n"
   $This.lst1 see insert
   }

   #
   # confAudecomFoc::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global confAudecomFoc
      global confTel

      set confTel(conf_audecom,vitesse)     $confAudecomFoc(conf_audecom,vitesse)
      set confTel(conf_audecom,intra_extra) $confAudecomFoc(conf_audecom,intra_extra)
      set confTel(conf_audecom,inv_rot)     $confAudecomFoc(conf_audecom,inv_rot)
      set confTel(conf_audecom,dep_val)     $confAudecomFoc(conf_audecom,dep_val)
   }
}

#
# progpec / AudecomPec
# Description :Fenetre de configuration pour la programmation du PEC pour AudeCom
#

namespace eval confAudecomPec {
   variable This
   global confAudecomPec

   #
   # confAudecomPec::run this args
   # Cree la fenetre de configuration des parametres du Pec
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog 
      tkwait visibility $This
   }

   #
   # confAudecomPec::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de programmation du PEC
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confAudecomPec::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confAudecomPec::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global color
      global confTel
      global confAudecomPec

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(audecom,prog_pec)
      set posx_audecom_prog_pec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
      set posy_audecom_prog_pec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_audecom_prog_pec + 0 ]+[ expr $posy_audecom_prog_pec + 70 ]
      wm resizable $This 0 0
 
      #--- On utilise les valeurs contenues dans le tableau confTel pour l'initialisation
      set confAudecomPec(conf_audecom,t0)   $confTel(conf_audecom,t0)
      set confAudecomPec(conf_audecom,t1)   $confTel(conf_audecom,t1)
      set confAudecomPec(conf_audecom,t2)   $confTel(conf_audecom,t2)
      set confAudecomPec(conf_audecom,t3)   $confTel(conf_audecom,t3)
      set confAudecomPec(conf_audecom,t4)   $confTel(conf_audecom,t4)
      set confAudecomPec(conf_audecom,t5)   $confTel(conf_audecom,t5)
      set confAudecomPec(conf_audecom,t6)   $confTel(conf_audecom,t6)
      set confAudecomPec(conf_audecom,t7)   $confTel(conf_audecom,t7)
      set confAudecomPec(conf_audecom,t8)   $confTel(conf_audecom,t8)
      set confAudecomPec(conf_audecom,t9)   $confTel(conf_audecom,t9)
      set confAudecomPec(conf_audecom,t10)  $confTel(conf_audecom,t10)
      set confAudecomPec(conf_audecom,t11)  $confTel(conf_audecom,t11)
      set confAudecomPec(conf_audecom,t12)  $confTel(conf_audecom,t12)
      set confAudecomPec(conf_audecom,t13)  $confTel(conf_audecom,t13)
      set confAudecomPec(conf_audecom,t14)  $confTel(conf_audecom,t14)
      set confAudecomPec(conf_audecom,t15)  $confTel(conf_audecom,t15)
      set confAudecomPec(conf_audecom,t16)  $confTel(conf_audecom,t16)
      set confAudecomPec(conf_audecom,t17)  $confTel(conf_audecom,t17)
      set confAudecomPec(conf_audecom,t18)  $confTel(conf_audecom,t18)
      set confAudecomPec(conf_audecom,t19)  $confTel(conf_audecom,t19)
      set confAudecomPec(conf_audecom,rpec) $confTel(conf_audecom,rpec)

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
      pack $This.frame5 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame10 -borderwidth 0 -relief raised
      pack $This.frame10 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame11 -borderwidth 0 -relief raised
      pack $This.frame11 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame12 -borderwidth 0 -relief raised
      pack $This.frame12 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame13 -borderwidth 0 -relief raised
      pack $This.frame13 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame14 -borderwidth 0 -relief raised
      pack $This.frame14 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame15 -borderwidth 0 -relief raised
      pack $This.frame15 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame16 -borderwidth 0 -relief raised
      pack $This.frame16 -in $This.frame5 -side top -fill both -expand 1

      frame $This.frame17 -borderwidth 0 -relief raised
      pack $This.frame17 -in $This.frame5 -side top -fill both -expand 1

      frame $This.frame18 -borderwidth 0 -relief raised
      pack $This.frame18 -in $This.frame15 -side top -fill both -expand 1

      frame $This.frame19 -borderwidth 0 -relief raised
      pack $This.frame19 -in $This.frame15 -side top -fill both -expand 1

      #--- Cree le bouton 'Aide' de la vitesse de suivi nominale 
      button $This.but_aide1 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomPec::aide1 }
	pack $This.but_aide1 -in $This.frame16 -anchor center -side left -padx 10 -pady 5

      #--- Rappelle la vitesse de suivi nominale
      label $This.lab1 -text "$caption(audecom,vit_suiv_nom)"
	pack $This.lab1 -in $This.frame16 -anchor center -side left -padx 5 -pady 5

      catch {
         label $This.labURL2 -text "$conf(audecom,dsuivinom)" -fg $color(blue)
	   pack $This.labURL2 -in $This.frame16 -anchor center -side left -padx 0 -pady 5
      }

      #--- Cree le bouton 'Aide' de l'intervalle de choix de la vitesse de suivi
      button $This.but_aide2 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomPec::aide2 } 
	pack $This.but_aide2 -in $This.frame17 -anchor center -side left -padx 10 -pady 5

      #--- Rappelle les limites des corrections et la reduction
      catch {
         label $This.lab3 -text "$caption(audecom,compris_entre) $conf(audecom,dsuivinommin)\
            $caption(audecom,et) $conf(audecom,dsuivinommax)"
	   pack $This.lab3 -in $This.frame17 -anchor center -side left -padx 5 -pady 5
      }

      #--- Affiche la moyenne des correction
      label $This.lab4 -text "$caption(audecom,somme_ti)"
	pack $This.lab4 -in $This.frame6 -anchor center -side top -padx 10 -pady 9

      label $This.labURL5 -text "$caption(audecom,non_calcul)" -relief groove -fg $color(blue) -width 13 
	pack $This.labURL5 -in $This.frame6 -anchor center -side top -padx 10 -pady 9

      #--- Cree la zone a renseigner t0
      label $This.lab6 -text "$caption(audecom,t0)"
	pack $This.lab6 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t0 -textvariable confAudecomPec(conf_audecom,t0) -width 5 -justify center
	   pack $This.t0 -in $This.frame8 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t1
      label $This.lab7 -text "$caption(audecom,t1)"
	pack $This.lab7 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t1 -textvariable confAudecomPec(conf_audecom,t1) -width 5 -justify center
	   pack $This.t1 -in $This.frame8 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t2
      label $This.lab8 -text "$caption(audecom,t2)"
	pack $This.lab8 -in $This.frame7 -anchor center -side top -padx 5 -pady 5 

      catch {
         entry $This.t2 -textvariable confAudecomPec(conf_audecom,t2) -width 5 -justify center
	   pack $This.t2 -in $This.frame8 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t3
      label $This.lab9 -text "$caption(audecom,t3)"
	pack $This.lab9 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t3 -textvariable confAudecomPec(conf_audecom,t3) -width 5 -justify center
	   pack $This.t3 -in $This.frame8 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t4
      label $This.lab10 -text "$caption(audecom,t4)"
	pack $This.lab10 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t4 -textvariable confAudecomPec(conf_audecom,t4) -width 5 -justify center
	   pack $This.t4 -in $This.frame8 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t5
      label $This.lab11 -text "$caption(audecom,t5)"
	pack $This.lab11 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t5 -textvariable confAudecomPec(conf_audecom,t5) -width 5 -justify center
	   pack $This.t5 -in $This.frame10 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t6
      label $This.lab12 -text "$caption(audecom,t6)"
	pack $This.lab12 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t6 -textvariable confAudecomPec(conf_audecom,t6) -width 5 -justify center
	   pack $This.t6 -in $This.frame10 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t7
      label $This.lab13 -text "$caption(audecom,t7)"
	pack $This.lab13 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t7 -textvariable confAudecomPec(conf_audecom,t7) -width 5 -justify center
	   pack $This.t7 -in $This.frame10 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t8
      label $This.lab14 -text "$caption(audecom,t8)"
	pack $This.lab14 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t8 -textvariable confAudecomPec(conf_audecom,t8) -width 5 -justify center
	   pack $This.t8 -in $This.frame10 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t9
      label $This.lab15 -text "$caption(audecom,t9)"
	pack $This.lab15 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t9 -textvariable confAudecomPec(conf_audecom,t9) -width 5 -justify center
	   pack $This.t9 -in $This.frame10 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t10
      label $This.lab16 -text "$caption(audecom,t10)"
	pack $This.lab16 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t10 -textvariable confAudecomPec(conf_audecom,t10) -width 5 -justify center
	   pack $This.t10 -in $This.frame12 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t11
      label $This.lab17 -text "$caption(audecom,t11)"
	pack $This.lab17 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t11 -textvariable confAudecomPec(conf_audecom,t11) -width 5 -justify center
	   pack $This.t11 -in $This.frame12 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t12
      label $This.lab18 -text "$caption(audecom,t12)"
	pack $This.lab18 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t12 -textvariable confAudecomPec(conf_audecom,t12) -width 5 -justify center
	   pack $This.t12 -in $This.frame12 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t13
      label $This.lab19 -text "$caption(audecom,t13)"
	pack $This.lab19 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t13 -textvariable confAudecomPec(conf_audecom,t13) -width 5 -justify center
	   pack $This.t13 -in $This.frame12 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t14
      label $This.lab20 -text "$caption(audecom,t14)"
	pack $This.lab20 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t14 -textvariable confAudecomPec(conf_audecom,t14) -width 5 -justify center
	   pack $This.t14 -in $This.frame12 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t15
      label $This.lab21 -text "$caption(audecom,t15)"
	pack $This.lab21 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t15 -textvariable confAudecomPec(conf_audecom,t15) -width 5 -justify center
	   pack $This.t15 -in $This.frame14 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t16
      label $This.lab22 -text "$caption(audecom,t16)"
	pack $This.lab22 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t16 -textvariable confAudecomPec(conf_audecom,t16) -width 5 -justify center
	   pack $This.t16 -in $This.frame14 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t17
      label $This.lab23 -text "$caption(audecom,t17)"
	pack $This.lab23 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t17 -textvariable confAudecomPec(conf_audecom,t17) -width 5 -justify center
	   pack $This.t17 -in $This.frame14 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t18
      label $This.lab24 -text "$caption(audecom,t18)"
	pack $This.lab24 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t18 -textvariable confAudecomPec(conf_audecom,t18) -width 5 -justify center
	   pack $This.t18 -in $This.frame14 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree la zone a renseigner t19
      label $This.lab25 -text "$caption(audecom,t19)"
	pack $This.lab25 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

      catch {
         entry $This.t19 -textvariable confAudecomPec(conf_audecom,t19) -width 5 -justify center
	   pack $This.t19 -in $This.frame14 -anchor center -side top -padx 5 -pady 5
      }

      #--- Cree le bouton 'Calculer' la moyenne de la somme de t1 a t19
      button $This.but_calculer -text "$caption(audecom,calculer)" -borderwidth 2 \
         -command { ::confAudecomPec::moyti } 
	pack $This.but_calculer -in $This.frame18 -anchor center -side top -pady 9 -ipadx 10 -ipady 5 -expand true

      #--- Cree le bouton 'Aide' pour la periodicite du PEC
      button $This.but_aide3 -text "$caption(audecom,aide)" -width 2 -borderwidth 2 \
         -command { ::confAudecomPec::aide3 } 
	pack $This.but_aide3 -in $This.frame19 -anchor center -side left -padx 10 -pady 9

      #--- Cree la zone a renseigner (r)
      label $This.lab26 -text "$caption(audecom,r)"
	pack $This.lab26 -in $This.frame19 -anchor center -side left -padx 10 -pady 9

      catch {
         entry $This.rpec -textvariable confAudecomPec(conf_audecom,rpec) -width 5 -justify center
	   pack $This.rpec -in $This.frame19 -anchor center -side left -padx 10 -pady 9
      }

      #--- Cree le bouton 'OK' 
      button $This.but_ok -text "$caption(audecom,ok)" -width 7 -borderwidth 2 \
         -command { ::confAudecomPec::ok } 
      pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Annuler' 
      button $This.but_cancel -text "$caption(audecom,annuler)" -width 10 -borderwidth 2 \
         -command { ::confAudecomPec::fermer  } 
      pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree la console texte d'aide
      text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
      pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
      $This.lst1 insert end " \n"
      $This.lst1 insert end "$caption(audecom,prog_pec,aide01)\n"
      $This.lst1 insert end "$caption(audecom,prog_pec,aide02)\n"
      $This.lst1 insert end "$caption(audecom,prog_pec,aide03)\n"

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAudecomPec::aide1
   # Affiche l'aide de la vitesse de suivi nominale
   #
   proc aide1 { } {
   variable This
   global conf
   global caption

   $This.lst1 delete 1.0 end
   set conf(audecom,dsuivinomxt0) [ expr $conf(audecom,dsuivinom) * $conf(audecom,internom) / 1000 ]
   $This.lst1 insert end "[eval [concat {format} {$caption(audecom,prog_pec,aide11) $conf(audecom,dsuivinom) \
      $conf(audecom,dsuivinom) $conf(audecom,dsuivinomxt0) $conf(audecom,internom)}]]"
   $This.lst1 see insert
   }

   #
   # confAudecomPec::aide2
   # Affiche l'aide de l'intervalle de choix de la vitesse de suivi
   #
   proc aide2 { } {
   variable This
   global conf
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "[eval [concat {format} {$caption(audecom,prog_pec,aide21) $conf(audecom,dsuivinommin) \
      $conf(audecom,dsuivinommax) $conf(audecom,dsuivinom) $conf(audecom,dsuivinom)}]]"
   $This.lst1 see insert
   }

   #
   # confAudecomPec::aide3
   # Affiche l'aide pour le choix de la periodicite du PEC
   #
   proc aide3 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "\n"   
   $This.lst1 insert end "$caption(audecom,prog_pec,aide31)\n"
   $This.lst1 insert end "\n"   
   $This.lst1 see insert
   }

   #
   # confAudecomPec::analyse1
   # Affiche un commentaire sur l'analyse des corrections (correct)
   #
   proc analyse1 { } {
   variable This
   global conf
   global caption
   global color

   $This.lst1 delete 1.0 end
   $This.lst1 tag configure style_correct -foreground $color(blue)
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse11)\n" style_correct
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse12)\n" style_correct
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse13)\
      $conf(audecom,dsuivinom)$caption(audecom,point)\n" style_correct
   $This.lst1 insert end "\n"
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse14)\n" style_correct
   $This.lst1 insert end ""
   $This.lst1 see insert
   }

   #
   # confAudecomPec::analyse2
   # Affiche un commentaire sur l'analyse des corrections (diverge)
   #
   proc analyse2 { } {
   variable This
   global conf
   global caption
   global color

   $This.lst1 delete 1.0 end
   $This.lst1 tag configure style_diverge -foreground $color(red)
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse21)\n" style_diverge
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse22)\n" style_diverge
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse23)\
      $conf(audecom,dsuivinom)$caption(audecom,point)\n" style_diverge
   $This.lst1 insert end "\n"
   $This.lst1 insert end "$caption(audecom,prog_pec,analyse24)\n" style_diverge
   $This.lst1 insert end ""
   $This.lst1 see insert
   }

   #
   # confAudecomPec::moyti
   # Calcule la moyenne de t1 a t19
   #
   proc moyti { } {
      variable This
      global conf
      global color
      global confTel
      global confAudecomPec

      set confTel(audecom,t) 0
      for {set i 0} {$i <= 19} {incr i} {
         set confTel(audecom,t) [ expr $confTel(audecom,t) + $confAudecomPec(conf_audecom,t$i) ]
      }
      set confTel(audecom,moyti) [ expr $confTel(audecom,t) / 20.0 ]
      if { $confTel(audecom,moyti) == "$conf(audecom,dsuivinom)" } {
         set fg $color(blue)
         analyse1
      } else {
         set fg $color(red)
         analyse2
      }
      $This.labURL5 configure -textvariable confTel(audecom,moyti) -fg $fg -width 11
   }

   #
   # confAudecomPec::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global confTel
      global confAudecomPec
   
      set confTel(conf_audecom,t0)   $confAudecomPec(conf_audecom,t0)
      set confTel(conf_audecom,t1)   $confAudecomPec(conf_audecom,t1)
      set confTel(conf_audecom,t2)   $confAudecomPec(conf_audecom,t2)
      set confTel(conf_audecom,t3)   $confAudecomPec(conf_audecom,t3)
      set confTel(conf_audecom,t4)   $confAudecomPec(conf_audecom,t4)
      set confTel(conf_audecom,t5)   $confAudecomPec(conf_audecom,t5)
      set confTel(conf_audecom,t6)   $confAudecomPec(conf_audecom,t6)
      set confTel(conf_audecom,t7)   $confAudecomPec(conf_audecom,t7)
      set confTel(conf_audecom,t8)   $confAudecomPec(conf_audecom,t8)
      set confTel(conf_audecom,t9)   $confAudecomPec(conf_audecom,t9)
      set confTel(conf_audecom,t10)  $confAudecomPec(conf_audecom,t10)
      set confTel(conf_audecom,t11)  $confAudecomPec(conf_audecom,t11)
      set confTel(conf_audecom,t12)  $confAudecomPec(conf_audecom,t12)
      set confTel(conf_audecom,t13)  $confAudecomPec(conf_audecom,t13)
      set confTel(conf_audecom,t14)  $confAudecomPec(conf_audecom,t14)
      set confTel(conf_audecom,t15)  $confAudecomPec(conf_audecom,t15)
      set confTel(conf_audecom,t16)  $confAudecomPec(conf_audecom,t16)
      set confTel(conf_audecom,t17)  $confAudecomPec(conf_audecom,t17)
      set confTel(conf_audecom,t18)  $confAudecomPec(conf_audecom,t18)
      set confTel(conf_audecom,t19)  $confAudecomPec(conf_audecom,t19)
      set confTel(conf_audecom,rpec) $confAudecomPec(conf_audecom,rpec)
   }
}

#
# ctlking / AudecomKing
# Description :Fenetre de configuration pour le controle de la vitesse de King pour AudeCom
#

namespace eval confAudecomKing {
   variable This
   global confAudecomKing

   #
   # confAudecomKing::run this args
   # Cree la fenetre de controle de la vitesse de King
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This
      global frmm

      set This $this
      set frm $frmm(Telscp3)
      $frm.ctlking configure -relief groove -state disabled
      createDialog 
      tkwait visibility $This
      Clock_et_King
   }

   #
   # confAudecomKing::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This
      global audace
      global confgene
      global frmm

      set frm $frmm(Telscp3)
      set confgene(espion2) "1"
      if { [ winfo exists $audace(base).confTel ] } {
         $frm.ctlking configure -relief raised -state normal
      }
      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confAudecomKing
      global confgene

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Initialisation de variables
      set confgene(posobs,altitude) $conf(posobs,altitude)
      set confgene(posobs,nordsud)  $conf(posobs,nordsud)
      set confgene(posobs,lat)      $conf(posobs,lat)
      set confgene(posobs,estouest) $conf(posobs,estouest)
      set confgene(posobs,long)     $conf(posobs,long)

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(audecom,ctrl_king)
      set posx_audecom_ctrl_king [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
      set posy_audecom_ctrl_king [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_audecom_ctrl_king + 150 ]+[ expr $posy_audecom_ctrl_king + 0 ]
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW ::confAudecomKing::fermer

      #--- Initialisation de variables
      set confgene(espion1) "0"
      set confgene(espion2) "0"

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
      pack $This.frame7 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame3 -side left -fill none

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame10 -borderwidth 0 -relief raised
      pack $This.frame10 -in $This.frame4 -side left -fill none

      frame $This.frame11 -borderwidth 0 -relief raised
      pack $This.frame11 -in $This.frame5 -side left -fill both -expand 1

      frame $This.frame12 -borderwidth 0 -relief raised
      pack $This.frame12 -in $This.frame5 -side left -fill none

      frame $This.frame13 -borderwidth 0 -relief raised
      pack $This.frame13 -in $This.frame6 -side left -fill both -expand 1

      frame $This.frame14 -borderwidth 0 -relief raised
      pack $This.frame14 -in $This.frame6 -side left -fill none

      #--- Position de l'observateur
      label $This.lab1 -text "$caption(audecom,pos_obs)"
	pack $This.lab1 -in $This.frame7 -anchor w -side top -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_1 -text " "
      pack $This.lab_invisible_1 -in $This.frame8 -anchor w -side top -padx 5 -pady 5

      #--- Longitude observateur
      label $This.lab2 -text "$caption(audecom,longitude)"
	pack $This.lab2 -in $This.frame7 -anchor w -side top -padx 25 -pady 0

      #--- Cree le label de la longitude
      label $This.lab3 -borderwidth 1 -width 14 -anchor w
	pack $This.lab3 -in $This.frame8 -anchor w -side top -padx 5 -pady 1

      #--- Latitude observateur
      label $This.lab4 -text "$caption(audecom,latitude)"
	pack $This.lab4 -in $This.frame7 -anchor w -side top -padx 25 -pady 0

      #--- Cree le label de la latitude
      label $This.lab5 -borderwidth 1 -width 14 -anchor w
	pack $This.lab5 -in $This.frame8 -anchor w -side top -padx 5 -pady 1

      #--- Altitude observateur
      label $This.lab6 -text "$caption(audecom,altitude)"
	pack $This.lab6 -in $This.frame7 -anchor w -side top -padx 25 -pady 0

      #--- Cree le label de l'altitude
      label $This.lab7 -borderwidth 1 -width 14 -anchor w
	pack $This.lab7 -in $This.frame8 -anchor w -side top -padx 5 -pady 1

      #--- Position du telescope
      label $This.lab8 -text "$caption(audecom,pos_tel)"
	pack $This.lab8 -in $This.frame9 -anchor w -side top -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_2 -text " "
      pack $This.lab_invisible_2 -in $This.frame10 -anchor w -side top -padx 5 -pady 5

      #--- Azimut
      label $This.lab9 -text "$caption(audecom,azimut)"
	pack $This.lab9 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

      label $This.lab10 -borderwidth 1 -textvariable "confAudecomKing(azimut)" -width 14 -anchor w
	pack $This.lab10 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

      #--- Hauteur
      label $This.lab11 -text "$caption(audecom,hauteur)"
	pack $This.lab11 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

      label $This.lab12 -borderwidth 1 -textvariable "confAudecomKing(hauteur)" -width 14 -anchor w
	pack $This.lab12 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

      #--- Ascension droite
      label $This.lab13 -text "$caption(audecom,ad)"
	pack $This.lab13 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

      label $This.lab14 -borderwidth 1 -textvariable "confAudecomKing(ascension1)" -width 14 -anchor w
	pack $This.lab14 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

      #--- Declinaison
      label $This.lab15 -text "$caption(audecom,dec)"
	pack $This.lab15 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

      label $This.lab16 -borderwidth 1 -textvariable "confAudecomKing(declinaison1)" -width 14 -anchor w
	pack $This.lab16 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

      #--- Parametres lies au temps
      label $This.lab17 -text "$caption(audecom,temps)"
	pack $This.lab17 -in $This.frame11 -anchor w -side top -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_3 -text " "
      pack $This.lab_invisible_3 -in $This.frame12 -anchor w -side top -padx 5 -pady 5

      #--- Heure systeme = tu ou heure legale
      label $This.lab18 -text "$caption(audecom,hsysteme)"
	pack $This.lab18 -in $This.frame11 -anchor w -side top -padx 25 -pady 0

      label $This.lab19 -borderwidth 1 -width 14 -anchor w -textvariable confgene(temps,hsysteme)
	pack $This.lab19 -in $This.frame12 -anchor w -side top -padx 5 -pady 1

      #--- Cree le label fushoraire
      label $This.lab20 -text "$caption(audecom,fushoraire2)"
	pack $This.lab20 -in $This.frame11 -anchor w -side top -padx 25 -pady 0

      label $This.lab21 -borderwidth 1 -width 14 -anchor w -textvariable confgene(temps,fushoraire)
	pack $This.lab21 -in $This.frame12 -anchor w -side top -padx 5 -pady 1

      #--- Cree le label hhiverete
      label $This.lab22 -text "$caption(audecom,hhiverete)"
	pack $This.lab22 -in $This.frame11 -anchor w -side top -padx 25 -pady 0

      label $This.lab23 -borderwidth 1 -width 14 -anchor w
	pack $This.lab23 -in $This.frame12 -anchor w -side top -padx 5 -pady 1

      #--- Angle horaire
      label $This.lab24 -text "$caption(audecom,angle_horaire)"
	pack $This.lab24 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

      label $This.lab25 -borderwidth 1 -textvariable "confAudecomKing(anglehoraire)" -width 14 -anchor w
	pack $This.lab25 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

      #--- Temps sideral local
      label $This.lab26 -text "$caption(audecom,tsl)"
	pack $This.lab26 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

      label $This.lab27 -borderwidth 1 -textvariable "audace(tsl,format,hmsint)" -width 14 -anchor w
	pack $This.lab27 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

      #--- Temps universel
      label $This.lab28 -text "$caption(audecom,tu)"
	pack $This.lab28 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

      label $This.lab29 -borderwidth 1 -textvariable "audace(tu,format,hmsint)" -width 14 -anchor w
	pack $This.lab29 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

      #--- Coefficient de King
      label $This.lab30 -text "$caption(audecom,coef_king)"
	pack $This.lab30 -in $This.frame13 -anchor w -side top -padx 5 -pady 5

      #--- Cree un widget 'Invisible' pour simuler un espacement
      label $This.lab_invisible_4 -text " "
      pack $This.lab_invisible_4 -in $This.frame14 -anchor w -side top -padx 5 -pady 5

      #--- Coefficient k
      label $This.lab31 -text "$caption(audecom,coef_k)"
	pack $This.lab31 -in $This.frame13 -anchor w -side top -padx 25 -pady 0

      label $This.lab32 -borderwidth 1 -textvariable "confAudecomKing(coefking)" -width 14 -anchor w
	pack $This.lab32 -in $This.frame14 -anchor w -side top -padx 5 -pady 1

      #--- Cree le bouton 'Fermer' 
      button $This.but_close -text "$caption(audecom,fermer)" -width 7 -borderwidth 2 \
         -command { ::confAudecomKing::fermer  } 
      pack $This.but_close -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAudecomKing::Clock_et_King
   # Fonction qui met a jour TU, TSL, .... Cette fonction se re-appelle au bout d'une seconde
   #
   proc Clock_et_King { } {
      variable This
      global audace
      global conf
      global caption
      global confAudecomKing
      global confgene

      if { $confgene(espion2) != "1" } {
         #--- Cree le label de la longitude
         set confgene(posobs,long1) [ lindex [ mc_angle2dms $confgene(posobs,long) 180 ] 0 ]
         catch {
            $This.lab3 configure -text "$confgene(posobs,estouest)  [ expr int($confgene(posobs,long1)) ]° [ lindex [ mc_angle2dms $confgene(posobs,long) 180 ] 1 ]' [ format "%03.1f" [ lindex [ mc_angle2dms $confgene(posobs,long) 180 ] 2 ] ]''"
         }
         #--- Cree le label de la latitude
         set confgene(posobs,lat1) [lindex [ mc_angle2dms $confgene(posobs,lat) 90 ] 0]
         catch {
            $This.lab5 configure -text "$confgene(posobs,nordsud)  [ expr int($confgene(posobs,lat1)) ]° [ lindex [ mc_angle2dms $confgene(posobs,lat) 90 ] 1 ]' [ format "%03.1f" [ lindex [ mc_angle2dms $confgene(posobs,lat) 90 ] 2 ] ]''"
         }
         #--- Cree le label de l'altitude
         catch {
            $This.lab7 configure -text "$confgene(posobs,altitude) $caption(audecom,metre)"
         }
         if { $confgene(temps,hsysteme) == "$caption(audecom,heure_legale)" } {
            if { $confgene(espion1) == "1" } {
               set confgene(espion1) "0"
               #--- Cree le label fushoraire
               label $This.lab20 -text "$caption(audecom,fushoraire2)"
	         pack $This.lab20 -in $This.frame11 -anchor w -side top -padx 25 -pady 0
               label $This.lab21 -borderwidth 1 -width 6 -anchor w -textvariable confgene(temps,fushoraire)
	         pack $This.lab21 -in $This.frame12 -anchor w -side top -padx 5 -pady 0
               #--- Cree le label hhiverete
               label $This.lab22 -text "$caption(audecom,hhiverete)"
	         pack $This.lab22 -in $This.frame11 -anchor w -side top -padx 25 -pady 0
               label $This.lab23 -borderwidth 1 -width 8 -anchor w
	         pack $This.lab23 -in $This.frame12 -anchor w -side top -padx 5 -pady 0
               #--- Mise a jour dynamique des couleurs
               ::confColor::applyColor $This
            }
            $This.lab19 configure -text "$caption(audecom,heure_legale)"
            catch {
               if { $confgene(temps,hhiverete) == "$caption(audecom,aucune)" } {
                  $This.lab23 configure -text "$caption(audecom,aucune)"
               } elseif { $confgene(temps,hhiverete) == "$caption(audecom,heure_hiver)" } {
                  $This.lab23 configure -text "$caption(audecom,heure_hiver)"
               } else {
                  $This.lab23 configure -text "$caption(audecom,heure_ete)"
               }
            }
         } else {
            $This.lab19 configure -text "$caption(audecom,temps_universel)"
            destroy $This.lab20
            destroy $This.lab21
            destroy $This.lab22
            destroy $This.lab23
            set confgene(espion1) "1"
         }
         #--- Affichage heure tu et heure tsl
         #--- Preparation et affichage ascension droite et declinaison
         #--- Lecture de la position du telescope
         set addec [ tel$audace(telNo) radec coord ]
         #--- Ascension droite
         set ascension [ lindex $addec 0 ]
         if { $ascension == "+" } {
            set confAudecomKing(ascension1) "00h 00m 00s"
            set ascension2 "00h00m00s"
         } else {
            set confAudecomKing(ascension1) "[ string range $ascension  0 1 ]h [ string range $ascension 3 4 ]m [ string range $ascension 6 7 ]s"
            set ascension2 $ascension
         }
         #--- Declinaison
         set declinaison [ lindex $addec 1 ]
         if { $declinaison == "" } {
            set confAudecomKing(declinaison1) "00° 00' 00''"
            set declinaison2 "00d00m00s"
         } else {
            set confAudecomKing(declinaison1) "[ string range $declinaison 0 2 ]° [ string range $declinaison 4 5 ]' [ string range $declinaison 7 8 ]''"
            set declinaison2 $declinaison
         }
         #--- Preparation affichage azimut, hauteur et angle horaire
         set pos [ mc_radec2altaz $ascension2 $declinaison2 $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
         #--- Azimut
         set confAudecomKing(azimut) [ format "%05.2f" [ lindex $pos 0 ] ]$caption(audecom,degre)
         #--- Hauteur
         set confAudecomKing(hauteur) [ format "%05.2f" [ lindex $pos 1 ] ]$caption(audecom,degre)
         #--- Angle horaire
         set anglehoraire [ lindex $pos 2 ]
         set anglehoraire [ mc_angle2hms $anglehoraire 360 ]
         set anglehorairesec [ lindex $anglehoraire 2 ]
         set confAudecomKing(anglehoraire) [ format "%02dh %02dm %02ds" [ lindex $anglehoraire 0 ] [ lindex $anglehoraire 1 ] [ expr int($anglehorairesec) ] ]
         #--- Preparation affichage du coefficient de King
         #--- Latitude en radians
         set latitude [ lindex $audace(posobs,observateur,gps) 3 ]
         set latrad [ mc_angle2rad $latitude ]
         #--- Declinaison en radians
         set decrad [ mc_angle2rad $declinaison2 ]
         #--- Angle horaire en radians
         set anghorad [ mc_angle2rad [ lindex $pos 2 ] ]
         #--- Vitesse de king
         set num1 [ expr cos($latrad)*cos($decrad)+sin($latrad)*sin($decrad)*cos($anghorad) ]
         set denom1 [ expr pow(sin($latrad)*sin($decrad)+cos($latrad)*cos($decrad)*cos($anghorad),2) ]
         set exp1 [ expr $num1/$denom1 ]
         set exp2 [ expr ($exp1*cos($latrad)/cos($decrad))-(tan($decrad)*cos($anghorad)/tan($latrad)) ]
         set vitking [ expr 1436.07+0.40*$exp2 ]
         #--- Coefficient de king
         set confAudecomKing(coefking) [ format "%01.8f" [ expr $vitking/1436.07 ] ]
         #--- Active ou non le suivi a la vitesse de King
         if { $conf(audecom,king) == "1" } {
            set corking [ expr $conf(audecom,dsuivinom) / ( 1 - $confAudecomKing(coefking) ) ]
		set corking [ expr round($corking) ]
            if { $corking > "99999999" } { set corking "99999999" }
		if { $corking < "-99999999" } { set corking "-99999999" }
            tel$audace(telNo) king $corking
         } else {
            tel$audace(telNo) king "99999999"
         }
         after 1000 ::confAudecomKing::Clock_et_King
      } else {
         #--- Rien
      }
   } 
}

#
# paramobile / AudecomMobile
# Description :Fenetre de configuration pour le parametrage du suivi d'objets mobiles
#

namespace eval confAudecomMobile {
   variable This
   global confAudecomMobile

   #
   # confAudecomMobile::run this args
   # Cree la fenetre de configuration des parametres de suivi
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog 
      tkwait visibility $This
   }

   #
   # confAudecomMobile::ok
   # Fonction appelee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre des parametres
   #
   proc ok { } {
      global confTel

      set confTel(fenetre,mobile,valider) "1"
      appliquer
      fermer
   }

   #
   # confAudecomMobile::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confAudecomMobile::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # confAudecomMobile::griser
   # Fonction destinee a inhiber l'affichage de derive
   #
   proc griser { this } {
      variable This

      set This $this
	$This.vitmotad configure -state disabled
	$This.vitmotdec configure -state disabled
   }

   #
   # confAudecomMobile::activer
   # Fonction destinee a activer l'affichage de derive
   #
   proc activer { this } {
      variable This

      set This $this
	$This.vitmotad configure -state normal
	$This.vitmotdec configure -state normal
   }

  proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confTel
      global confAudecomMobile

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(audecom,para_mobile)
      set posx_audecom_para_mobile [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
      set posy_audecom_para_mobile [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_audecom_para_mobile + 0 ]+[ expr $posy_audecom_para_mobile + 70 ]
      wm resizable $This 0 0

      #--- On utilise les valeurs contenues dans le tableau confTel pour l'initialisation
      set confAudecomMobile(conf_audecom,ad)   $confTel(conf_audecom,ad)
      set confAudecomMobile(conf_audecom,dec)  $confTel(conf_audecom,dec)
      set confAudecomMobile(conf_audecom,type) $confTel(conf_audecom,type)

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
      pack $This.frame6 -in $This.frame5 -side left -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame5 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame7 -side top -fill both -expand 1

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in $This.frame7 -side top -fill both -expand 1

     	#--- Radio-bouton Lune
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(audecom,para_mobile_lune)" \
         -value 0 -variable confAudecomMobile(conf_audecom,type) \
         -command { ::confAudecomMobile::griser "$audace(base).confAudecomMobile" }
	pack $This.rad1 -in $This.frame3 -anchor center -side left -padx 10 -pady 5

      #--- Radio-bouton Soleil
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(audecom,para_mobile_soleil)" \
         -value 1 -variable confAudecomMobile(conf_audecom,type) \
         -command { ::confAudecomMobile::griser "$audace(base).confAudecomMobile" }
	pack $This.rad2 -in $This.frame4 -anchor center -side left -padx 10 -pady 5

      #--- Radio-bouton comete, etc.
      radiobutton $This.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(audecom,para_mobile_comete)" \
         -value 2 -variable confAudecomMobile(conf_audecom,type) \
         -command { ::confAudecomMobile::activer "$audace(base).confAudecomMobile" }
	pack $This.rad3 -in $This.frame6 -anchor n -side left -padx 10 -pady 5

      #--- Radio-bouton etoile
     # radiobutton $This.rad4 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
     #    -text "$caption(audecom,para_mobile_etoile)" \
     #    -value 3 -variable confAudecomMobile(conf_audecom,type) \
     #    -command { ::confAudecomMobile::griser "$audace(base).confAudecomMobile" }
     # pack $This.rad4 -in $This.frame6 -anchor s -side left -padx 10 -pady 5

      #--- Cree la zone a renseigner de la vitesse en asension droite
      catch {
         entry $This.vitmotad -textvariable confAudecomMobile(conf_audecom,ad) -width 10 -justify center
	   pack $This.vitmotad -in $This.frame8 -anchor n -side left -padx 5 -pady 5
      }

      #--- Etiquette vitesse d'ascension droite
      label $This.lab1 -text "$caption(audecom,para_mobile_ad)"
	pack $This.lab1 -in $This.frame8 -anchor n -side left -padx 10 -pady 5

      #--- Cree la zone a renseigner de la vitesse en declinaison
      catch {
         entry $This.vitmotdec -textvariable confAudecomMobile(conf_audecom,dec) -width 10 -justify center
	   pack $This.vitmotdec -in $This.frame9 -anchor n -side left -padx 5 -pady 5
      }

      #--- Etiquette vitesse de declinaison
      label $This.lab2 -text "$caption(audecom,para_mobile_dec)"
	pack $This.lab2 -in $This.frame9 -anchor n -side left -padx 10 -pady 5

      #--- Cree le bouton 'OK' 
      button $This.but_ok -text "$caption(audecom,ok)" -width 7 -borderwidth 2 \
         -command { ::confAudecomMobile::ok } 
      pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Annuler' 
      button $This.but_cancel -text "$caption(audecom,annuler)" -width 10 -borderwidth 2 \
         -command { ::confAudecomMobile::fermer  } 
      pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree la console texte d'aide
      text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
      pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
      $This.lst1 insert end " \n"
      $This.lst1 insert end "$caption(audecom,para_mobile,aide0)\n"

      #--- Entry actives ou non
      if { $confAudecomMobile(conf_audecom,type) != "2" } {
         ::confAudecomMobile::griser "$audace(base).confAudecomMobile"
      } else {
         ::confAudecomMobile::activer "$audace(base).confAudecomMobile"
      }

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAudecomMobile::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global confAudecomMobile
      global confTel

      set confTel(conf_audecom,ad)   $confAudecomMobile(conf_audecom,ad)
      set confTel(conf_audecom,dec)  $confAudecomMobile(conf_audecom,dec)
      set confTel(conf_audecom,type) $confAudecomMobile(conf_audecom,type)
   }
}

#--- Chargement au demarrage
::confAudecomMot::init

