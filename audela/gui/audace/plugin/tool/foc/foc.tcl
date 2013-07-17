#
# Fichier : foc.tcl
# Description : Outil pour le controle de la focalisation
# Compatibilité : Protocoles LX200 et AudeCom
# Auteurs : Alain KLOTZ, Robert DELMAS et Raymond ZACHANTKE
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace foc
#    initialise le namespace
#============================================================
namespace eval ::foc {
   package provide foc 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] foc.cap ]
   source [ file join [file dirname [info script]] focHFD.tcl ]
   source [ file join [file dirname [info script]] foc_focuser.tcl ]
   source [ file join [file dirname [info script]] foc_cam.tcl ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(foc,focalisation)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "foc.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "foc"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "focusing" }
         display      { return "panel" }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {

   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      createPanel $in.foc
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {

   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      variable This
      global conf caption panneau

      set This $this

      #--- Initialisation de la position du graphique
      if { ! [ info exists conf(visufoc,position) ] } {
         set conf(visufoc,position) "+200+0"
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(parafoc,position) ] } {
         set conf(parafoc,position) "+500+75"
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(foc,avancement,position) ] } {
         set conf(foc,avancement,position) "+120+315"
      }

      #--- Initialisation de variables
      set panneau(foc,menu)              "$caption(foc,centrage)"
      set panneau(foc,centrage_fenetre)  "1"
      set panneau(foc,compteur)          "0"
      set panneau(foc,bin)               "1"
      set panneau(foc,exptime)           "2"
      set panneau(foc,go)                "$caption(foc,go)"
      set panneau(foc,stop)              "$caption(foc,stop)"
      set panneau(foc,raz)               "$caption(foc,raz)"
      set panneau(foc,trouve)            "$caption(foc,se_trouve)"
      set panneau(foc,pas)               "$caption(foc,pas)"
      set panneau(foc,deplace)           "$caption(foc,aller_a)"
      set panneau(foc,initialise)        "$caption(foc,init)"
      set panneau(foc,dispTimeAfterId)   ""
      set panneau(foc,pose_en_cours)     "0"
      set panneau(foc,demande_arret)     "0"
      set panneau(foc,avancement_acq)    "1"
      set panneau(foc,fichier)           ""
      #--   on copie le nom du focuser selectionne dans le pad
      if { $conf($conf(confPad),focuserLabel) != "" } {
         set panneau(foc,focuser)        "$conf($conf(confPad),focuserLabel)"
         if { [ ::focus::possedeControleEtendu $panneau(foc,focuser) ] == "1"} {
            set panneau(foc,typefocuser) "1"
         } else {
            set panneau(foc,typefocuser) "0"
         }
      } else {
         set panneau(foc,focuser)        "$caption(foc,pas_focuser)"
         set panneau(foc,typefocuser)    "0"
      }

      focBuildIF $This
   }

   #------------------------------------------------------------
   # adaptOutilFoc
   #    adapte automatiquement l'interface graphique de l'outil
   #------------------------------------------------------------
   proc adaptOutilFoc { { a "" } { b "" } { c "" } } {
      variable This
      global caption panneau

      ::confEqt::activeFocuser $This.fra4.focuser.configure ::panneau(foc,focuser)
      if {$panneau(foc,focuser) eq ""} {
         set panneau(foc,focuser) "$caption(foc,pas_focuser)"
      }

      if { $panneau(foc,focuser) != "$caption(foc,pas_focuser)" } {
         if { [ ::focus::possedeControleEtendu $panneau(foc,focuser) ] == "1"} {
            set panneau(foc,typefocuser) 1
         } else {
            set panneau(foc,typefocuser) 0
         }

         #--   demasque tout ce qui etait masque
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1 ; #-- demasque label moteur focus
         pack $This.fra4.we -in $This.fra4 -side top -fill x  ; #-- demasque frame des buttons '- +'
         pack $This.fra5 -side top -fill x               ; #-- demasque frame position focus
      } else {
         set panneau(foc,typefocuser) 0

         #--   masque tout sauf la liste des focuser
         pack forget $This.fra4.lab1                     ; #-- masque label moteur focus
         pack forget $This.fra4.we                       ; #-- masque frame des buttons '- +'
         pack forget $This.fra5                          ; #-- masque frame position focus
      }

      if { $panneau(foc,typefocuser) == "1"} {

         #--- Avec controle etendu
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -ipady 1 -padx 5
         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -padx 5
         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but4 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         if {$::panneau(foc,focuser) eq "usb_focus"} {
            pack forget $This.fra5.but1
            ::focus::displayCurrentPosition $::panneau(foc,focuser) ; #usb_focus
            #--   modifie la commande du bouton en appelant la cmd focus en mode non bloquant
            $This.fra5.but2 configure -command { ::focus::goto usb_focus 0 }
            #--   modifie la commande validation de la saisie
            $This.fra5.fra2.ent3 configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 65535 }
            pack forget $This.fra5.but3
         } else {
            #--   sans effet si la commande est deja configuree comme cela
            $This.fra5.but2 configure -command { ::foc::cmdSeDeplaceA }
            $This.fra5.fra2.ent3 configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -32767 32767 }
         }

         #--   switch les graphes
         if {[winfo exists $::audace(base).visufoc]} {
            #--   ferme le graphique normal
            fermeGraphe
            #--   ouvre l'autre graphique
            initFocHFD
         }

      } else {

         #--- Sans controle etendu
         pack forget $This.fra5.lab1
         pack forget $This.fra5.but1
         pack forget $This.fra5.fra1.lab1
         pack forget $This.fra5.fra1.lab2
         pack forget $This.fra5.but2
         pack forget $This.fra5.fra2.ent3
         pack forget $This.fra5.fra2.lab4
         pack forget $This.fra5.but3
         pack forget $This.fra5.but4
         #--   switch les graphes
         if {[winfo exists $::audace(base).hfd]} {
            #--   ferme le graphique hfd
            closeHFDGraphe
            #--   ouvre la graphique normal
            focGraphe
         }

      }
      $This.fra4.we.labPoliceInvariant configure -text $::audace(focus,labelspeed)
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      trace add variable ::conf(telescope) write ::foc::adaptOutilFoc
      trace add variable ::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
      pack $This -side left -fill y
      ::foc::adaptOutilFoc
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace panneau

      #--- Je verifie si une operation est en cours
      if { $panneau(foc,pose_en_cours) == "1" } {
         return -1
      }

      #--- Initialisation du fenetrage
      set camItem [ ::confVisu::getCamItem $audace(visuNo) ]
      if { [ ::confCam::isReady $camItem ] == "1" } {
         set n1n2 [ cam$audace(camNo) nbcells ]
         cam$audace(camNo) window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- Initialisation des variables et fermeture des fenetres auxiliaires
      set panneau(foc,compteur) "0"
      closeAllWindows $audace(base)

      #--- Arret de la surveillance de la variable conf(telescope)
      trace remove variable :::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
      trace remove variable ::conf(telescope) write ::foc::adaptOutilFoc

      #---
      pack forget $This
   }

   #------------------------------------------------------------
   # closeAllWindows
   #    ferme toutes les fenetres annexes
   # Parametre : chemin du parent
   #------------------------------------------------------------
   proc closeAllWindows { base } {

      if {[winfo exists $base.parafoc]} {
         fermeQualiteFoc
      }
      if {[winfo exists $base.visufoc]} {
         fermeGraphe
      }
      if {[winfo exists $base.hfd]} {
         closeHFDGraphe
      }
   }

}

#------------   gestion du graphique classique -----------------

#---------------------------------------------------------------
# focGraphe
#    cree le fenetre graphique de suivi des parametres de focalisation
#---------------------------------------------------------------
proc focGraphe { } {
   global audace caption conf panneau

   set this $audace(base).visufoc

   #--- Fenetre d'affichage des parametres de la foc
   if [ winfo exists $this ] {
      fermeGraphe
   }

   #--- Creation et affichage des graphes
   if { [ winfo exists $this ] == "0" } {
      package require BLT
      #--- Creation de la fenetre
      toplevel $this
      wm title $this "$caption(foc,titre_graphe)"
      if { $panneau(foc,exptime) > "2" } {
         wm transient $this $audace(base)
      }
      wm resizable $this 1 1
      wm geometry $this $conf(visufoc,position)
      wm protocol $this WM_DELETE_WINDOW "fermeGraphe"
      #---
      visuf $this g_inten "$caption(foc,intensite_adu)"
      visuf $this g_fwhmx "$caption(foc,fwhm_x)"
      visuf $this g_fwhmy "$caption(foc,fwhm_y)"
      visuf $this g_contr "$caption(foc,contrast_adu)"
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }
}

#------------------------------------------------------------
# visuf
#    cree un graphique de suivi d'un parametre
#------------------------------------------------------------
proc visuf { base win_name title } {

   set frm $base.$win_name

   #--   ::vx (compteur) est commun a tous les graphes
   if {"::vx" ni [blt::vector names]} {
      ::blt::vector create ::vx -watchunset 1
   }
   ::blt::vector create ::vy$win_name -watchunset 1

   ::blt::graph $frm
   $frm element create line1 -xdata ::vx -ydata ::vy$win_name \
      -linewidth 1 -color black -symbol "" -hide no
   $frm axis configure x -hide no -min 1 -max 20 -subdivision 0 -stepsize 1
   $frm axis configure x2 -hide no -min 1 -max 20 -subdivision 0 -stepsize 1
   #--   laisse flotter le minimum et le maximum
   $frm axis configure y -title "$title" -hide no -min {} -max {}
   $frm axis configure y2 -hide no -min {} -max {}
   $frm legend configure -hide yes
   $frm configure -height 140
   pack $frm
}

#------------------------------------------------------------
# fermeGraphe
#    ferme la fenetre des graphes et sauve la position
# Parametre : chemin de la fenetre
#------------------------------------------------------------
proc fermeGraphe { } {
   global audace conf

   set w $audace(base).visufoc

   #--- Determination de la position de la fenetre
   regsub {([0-9]+x[0-9]+)} [wm geometry $w] "" conf(visufoc,position)

   #--- Detruit les vecteurs persistants
   blt::vector destroy ::vx ::vyg_fwhmx ::vyg_fwhmy ::vyg_inten ::vyg_contr

   #--- Fermeture de la fenetre
   destroy $w
}

#------------------------------------------------------------
# focBuildIF
#    cree le panneau de l'outil
#------------------------------------------------------------
proc focBuildIF { This } {
   global audace caption panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$caption(foc,help_titre1)\n$caption(foc,focalisation)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::foc::getPluginType ] ] \
               [ ::foc::getPluginDirectory ] [ ::foc::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(foc,help_titre)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $caption(foc,acquisition) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Menu
         menubutton $This.fra2.optionmenu1 -textvariable panneau(foc,menu) \
            -menu $This.fra2.optionmenu1.menu -relief raised
         pack $This.fra2.optionmenu1 -in $This.fra2 -anchor center -padx 4 -pady 2 -ipadx 3
         set m [ menu $This.fra2.optionmenu1.menu -tearoff 0 ]
         $m add radiobutton -label "$caption(foc,centrage)" \
            -indicatoron "1" \
            -value "1" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,centrage)" ; set panneau(foc,centrage_fenetre) "1" }
         $m add radiobutton -label "$caption(foc,fenetre)" \
            -indicatoron "1" \
            -value "2" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,fenetre)" ; set panneau(foc,centrage_fenetre) "2" }

         #--- Frame des entry & label
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour exptime
            entry $This.fra2.fra1.ent1 -textvariable panneau(foc,exptime) \
               -relief groove -width 6 -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label secondes
            label $This.fra2.fra1.lab1 -text $caption(foc,seconde) -relief flat
            pack $This.fra2.fra1.lab1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Bouton GO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(foc,go) -command { ::foc::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

         #--- Bouton STOP/RAZ
         button $This.fra2.but2 -borderwidth 2 -text $panneau(foc,raz) -command { ::foc::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

      pack $This.fra2 -side top -fill x

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame focuser
         ::confEqt::createFrameFocuserTool $This.fra4.focuser ::panneau(foc,focuser)
         pack $This.fra4.focuser -in $This.fra4 -anchor nw -side top -padx 4 -pady 1

         #--   je lis la configuration de la commande de la combobox
         set oldCmd [$This.fra4.focuser.list configure -modifycmd]
         #--   je lis la commande ecrite par la proc ::confEqt::createFrameFocuserTool
         set cmd [lindex $oldCmd 4]
         #--   j'ajoute l'instruction ::foc::adaptOutilFoc
         append cmd "; ::foc::adaptOutilFoc"
         #--   je modifie la commande de la combobox
         $This.fra4.focuser.list configure -modifycmd $cmd

         #--- Label pour moteur focus
         label $This.fra4.lab1 -text $caption(foc,moteur_focus) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Create the buttons '- +'
         frame $This.fra4.we -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.we -in $This.fra4 -side top -fill x

         #--- Button '-'
         button $This.fra4.we.canv1PoliceInvariant -borderwidth 2 \
            -text "-" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv1PoliceInvariant -in $This.fra4.we -expand 0 -side left -padx 2 -pady 2

         #--- Write the label of speed for LX200 and compatibles
         label $This.fra4.we.labPoliceInvariant \
            -textvariable audace(focus,labelspeed) -width 2 -borderwidth 0 -relief flat
         pack $This.fra4.we.labPoliceInvariant -in $This.fra4.we -expand 1 -side left

         #--- Button '+'
         button $This.fra4.we.canv2PoliceInvariant -borderwidth 2 \
            -text "+" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv2PoliceInvariant -in $This.fra4.we -expand 0 -side right -padx 2 -pady 2

         set zone(moins) $This.fra4.we.canv1PoliceInvariant
         set zone(plus)  $This.fra4.we.canv2PoliceInvariant

      pack $This.fra4 -side top -fill x

      #--- Speed
      bind $This.fra4.we.labPoliceInvariant <ButtonPress-1> { ::foc::cmdSpeed }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { ::foc::cmdFocus - }
      bind $zone(moins) <ButtonRelease-1> { ::foc::cmdFocus stop }
      bind $zone(plus)  <ButtonPress-1>   { ::foc::cmdFocus + }
      bind $zone(plus)  <ButtonRelease-1> { ::foc::cmdFocus stop }

      #--- Frame de la position focus
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour la position focus
         label $This.fra5.lab1 -text $caption(foc,pos_focus) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton "Se trouve à"
         button $This.fra5.but1 -borderwidth 2 -text $panneau(foc,trouve) -command { ::foc::cmdSeTrouveA }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des labels
         frame $This.fra5.fra1 -borderwidth 1 -relief flat

            #--- Label pour la position courante du focuser
            entry $This.fra5.fra1.lab1 -textvariable audace(focus,currentFocus) \
               -relief groove -width 6 -state disabled
            pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pas
            label $This.fra5.fra1.lab2 -text $panneau(foc,pas) -relief flat
            pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Aller à"
         button $This.fra5.but2 -borderwidth 2 -text $panneau(foc,deplace) -command { ::foc::cmdSeDeplaceA }
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des entry & label
         frame $This.fra5.fra2 -borderwidth 1 -relief flat

            #--- Entry pour la position cible du focuser
            entry $This.fra5.fra2.ent3 -textvariable audace(focus,targetFocus) \
               -relief groove -width 6 -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -32767 32767 }
            pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2
            bind $This.fra5.fra2.ent3 <Enter> { ::foc::formatFoc }
            bind $This.fra5.fra2.ent3 <Leave> { destroy $audace(base).formatfoc }

            #--- Label pas
            label $This.fra5.fra2.lab4 -text $panneau(foc,pas) -relief flat
            pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Initialisation"
         button $This.fra5.but3 -borderwidth 2 -text $panneau(foc,initialise) -command { ::foc::cmdInitFoc }
         pack $This.fra5.but3 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Bouton "Courbe en V"
         button $This.fra5.but4 -borderwidth 2 -text "$caption(foc,vcurve)" -command { ::foc::traceCurve }
         pack $This.fra5.but4 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

      pack $This.fra5 -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $This.fra6 -borderwidth 2 -relief ridge

        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.fra6.avancement_acq -highlightthickness 0 \
           -text $caption(foc,avancement_acq) -variable panneau(foc,avancement_acq)
        pack $This.fra6.avancement_acq -side left -fill x

     pack $This.fra6 -side top -fill x

     #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $This
}

