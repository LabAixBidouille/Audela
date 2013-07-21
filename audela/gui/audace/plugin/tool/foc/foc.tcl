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
   source [ file join [file dirname [info script]] foc_HFD.tcl ]
   source [ file join [file dirname [info script]] foc_focuser.tcl ]
   source [ file join [file dirname [info script]] foc_cam.tcl ]
   source [ file join [file dirname [info script]] foc_graph.tcl ]

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
      set panneau(foc,window)            ""
      set panneau(foc,box)               ""
      set panneau(foc,pose_en_cours)     "0"
      set panneau(foc,demande_arret)     "0"
      set panneau(foc,avancement_acq)    "1"
      set panneau(foc,fichier)           "${caption(foc,intensite)}\t${caption(foc,fwhm__x)}\t${caption(foc,fwhm__y)}\t${caption(foc,contraste)}\t"

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
         pack $This.fra4.we -in $This.fra4 -side top -fill x   ; #-- demasque frame des buttons '- +'
         pack $This.fra5 -before $This.fra6 -side top -fill x  ; #-- demasque frame position focus
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
         pack $This.fra5.but0 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -ipady 1 -padx 5
         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -padx 5
         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         if {$::panneau(foc,focuser) eq "usb_focus"} {
            pack forget $This.fra5.but0
            pack forget $This.fra5.but1
            ::focus::displayCurrentPosition $::panneau(foc,focuser) ; #usb_focus
            #--   modifie la commande du bouton
            $This.fra5.but2 configure -command { ::foc::cmdUSB_FocusGoto }
            #--   modifie la commande validation de la saisie
            $This.fra5.fra2.ent3 configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 65535 }
         } else {
            #--   sans effet si la commande est deja configuree comme cela
            $This.fra5.but2 configure -command { ::foc::cmdSeDeplaceA }
            $This.fra5.fra2.ent3 configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -32767 32767 }
         }

         #--   switch les graphes
         if {[winfo exists $::audace(base).visufoc]} {
            #--   ferme le graphique normal
            ::foc::fermeGraphe
            #--   ouvre l'autre graphique
            ::foc::HFDGraphe
         }

      } else {

         #--- Sans controle etendu
         pack forget $This.fra5.lab1
         pack forget $This.fra5.but0
         pack forget $This.fra5.but1
         pack forget $This.fra5.fra1.lab1
         pack forget $This.fra5.fra1.lab2
         pack forget $This.fra5.but2
         pack forget $This.fra5.fra2.ent3
         pack forget $This.fra5.fra2.lab4
         #--   switch les graphes
         if {[winfo exists $::audace(base).hfd]} {
            #--   ferme le graphique hfd
            ::foc::closeHFDGraphe
            #--   ouvre la graphique normal
            ::foc::focGraphe
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
      ::foc::closeAllWindows $audace(base)

      #--- Arret de la surveillance de la variable conf(telescope)
      trace remove variable :::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
      trace remove variable ::conf(telescope) write ::foc::adaptOutilFoc

      #---
      pack forget $This
   }

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
         $m add radiobutton -label "$caption(foc,fenetre_man)" \
            -indicatoron "1" \
            -value "2" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,fenetre_man)" ; set panneau(foc,centrage_fenetre) "2" }
         $m add radiobutton -label "$caption(foc,fenetre_auto)" \
            -indicatoron "1" \
            -value "3" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,fenetre_auto)" ; set panneau(foc,centrage_fenetre) "3" }

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

         #--- Bouton "Initialisation"
         button $This.fra5.but0 -borderwidth 2 -text $panneau(foc,initialise) -command { ::foc::cmdInitFoc }
         pack $This.fra5.but0 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

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
      pack $This.fra5 -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $This.fra6 -borderwidth 2 -relief ridge

        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.fra6.avancement_acq -highlightthickness 0 \
           -text $caption(foc,avancement_acq) -variable panneau(foc,avancement_acq)
        pack $This.fra6.avancement_acq -side left -fill x

     pack $This.fra6 -fill x

     #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $This
}

