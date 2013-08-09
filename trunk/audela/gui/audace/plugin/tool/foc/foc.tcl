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
   source [ file join [file dirname [info script]] foc_sim.tcl ]

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
      set panneau(foc,hasWindow)         "0"
      set panneau(foc,start)             "0"
      set panneau(foc,end)               "65535"
      set panneau(foc,step)              "3000"
      set panneau(foc,repeat)            "1"
      set panneau(foc,seeing)            "24"
      set panneau(foc,simulation)        "0"

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

      ::confEqt::activeFocuser $This.fra3.focuser.configure ::panneau(foc,focuser)
      if {$panneau(foc,focuser) eq ""} {
         set panneau(foc,focuser) "$caption(foc,pas_focuser)"
      }

      if { $panneau(foc,focuser) == "$caption(foc,pas_focuser)" } {

         #--   absence de focuser
         set panneau(foc,typefocuser) 0
         #--   masque tout sauf la liste des focuser
         pack forget $This.fra4                              ; #-- masque le frame de la raquette du focuser
         pack forget $This.fra5                              ; #-- masque frame position focus
         pack forget $This.fra6                              ; #-- masque frame programation

      } else {

         #--   tous les focuser reels

         #-- demasque le frame de la raquette du focuser commun a tous les focuser
         pack $This.fra4 -after $This.fra3 -side top -fill x

         if { [ ::focus::possedeControleEtendu $panneau(foc,focuser) ] == "1"} {

            #--   focuseraudecom et usb_focus
            set panneau(foc,typefocuser) 1

            pack $This.fra5 -after $This.fra4 -side top -fill x ; #-- demasque frame position focus
            pack $This.fra6 -after $This.fra5 -side top -fill x ; #-- demasque frame programmation

            if {$::panneau(foc,focuser) eq "usb_focus"} {
               #--   usb_focus
               pack forget $This.fra5.but0
               pack forget $This.fra5.but1
               ::focus::displayCurrentPosition $::panneau(foc,focuser)
               #--   adapte les commandes
               $This.fra5.but2 configure -command { ::foc::cmdUSB_FocusGoto }
               $This.fra5.target configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 65535 }
               $This.fra6.start configure -helptext [format $caption(foc,hlpstart) 0]
               $This.fra6.end configure -helptext [format $caption(foc,hlpend) 65535]
               #--   modifie les valeurs debut et fin
               set panneau(foc,start) "0"
               set panneau(foc,end)   "65535"
            } else {
               #--   focuseraudecom
               $This.fra4.we.labPoliceInvariant configure -text $::audace(focus,labelspeed)
               #--   adapte les commandes
               $This.fra5.but2 configure -command { ::foc::cmdSeDeplaceA }
               $This.fra5.target configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -32767 32767 }
               $This.fra6.start configure -helptext [format $caption(foc,hlpstart) -32767]
               $This.fra6.end configure -helptext [format $caption(foc,hlpend) 32767]
               #--   modifie les valeurs debut et fin
               set panneau(foc,start) "-32767"
               set panneau(foc,end)   "32767"
            }

            #--   switch les graphes
            if {[winfo exists $::audace(base).visufoc]} {
              #--   ferme le graphique normal
              ::foc::fermeGraphe
              #--   ouvre l'autre graphique
              ::foc::HFDGraphe
            }

         } else {

            #--   tous les focuser sans controle etendu
            set panneau(foc,typefocuser) 0

            pack forget $This.fra5 ; #-- masque frame position focus
            pack forget $This.fra6 ; #-- masque frame proogrammation

            #--   switch les graphes
            if {[winfo exists $::audace(base).hfd]} {
               #--   ferme le graphique hfd
               ::foc::closeHFDGraphe
               #--   ouvre la graphique normal
               ::foc::focGraphe
            }
         }
      }
      update
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
         pack $This.fra1.but -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(foc,help_titre)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $caption(foc,acquisition) -relief flat
         pack $This.fra2.lab1 -anchor center -fill none -padx 4 -pady 1

         #--- Menu
         menubutton $This.fra2.optionmenu1 -textvariable panneau(foc,menu) \
            -menu $This.fra2.optionmenu1.menu -borderwidth 2 -relief raised
         pack $This.fra2.optionmenu1 -anchor center -fill x -padx 5 -pady 2 -ipady 1
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

            pack $This.fra2.fra1.ent1 -side left -fill none -padx 4 -pady 2
            #--- Label secondes
            label $This.fra2.fra1.lab1 -text $caption(foc,seconde) -relief flat
            pack $This.fra2.fra1.lab1 -side left -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -anchor center -fill none

         #--- Bouton GO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(foc,go) -command { ::foc::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

         #--- Bouton STOP/RAZ
         button $This.fra2.but2 -borderwidth 2 -text $panneau(foc,raz) -command { ::foc::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

      pack $This.fra2 -side top -fill x

      #--- Frame de la configuration
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Frame focuser
         ::confEqt::createFrameFocuserTool $This.fra3.focuser ::panneau(foc,focuser)
         pack $This.fra3.focuser -in $This.fra3 -anchor nw -side top -padx 4 -pady 1

         #--   je lis la configuration de la commande de la combobox
         set oldCmd [$This.fra3.focuser.list configure -modifycmd]
         #--   je lis la commande ecrite par la proc ::confEqt::createFrameFocuserTool
         set cmd [lindex $oldCmd 4]
         #--   j'ajoute l'instruction ::foc::adaptOutilFoc
         append cmd "; ::foc::adaptOutilFoc"
         #--   je modifie la commande de la combobox
         $This.fra3.focuser.list configure -modifycmd $cmd

      pack $This.fra3 -side top -fill x

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

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

         #--- Bouton "Initialisation"
         button $This.fra5.but0 -borderwidth 2 -text $panneau(foc,initialise) -command { ::foc::cmdInitFoc }
         pack $This.fra5.but0 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Bouton "Se trouve à"
         button $This.fra5.but1 -borderwidth 2 -text $panneau(foc,trouve) -command { ::foc::cmdSeTrouveA }
         pack $This.fra5.but1 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des labels
         LabelEntry $This.fra5.current \
            -label $caption(foc,pos_focus) -labeljustify left -labelwidth 12 \
            -textvariable audace(focus,currentFocus) -width 6 -justify center \
            -state disabled
         pack $This.fra5.current -side top -fill x -padx 4 -pady 2

         #--- Bouton "Aller à"
         button $This.fra5.but2 -borderwidth 2 -text $panneau(foc,deplace) -command { ::foc::cmdSeDeplaceA }
         pack $This.fra5.but2 -anchor center -fill x -padx 5 -pady 5 -ipadx 15

         #--- Frame des entry & label
         LabelEntry $This.fra5.target \
            -label $caption(foc,target) -labeljustify left -labelwidth 12 \
            -textvariable audace(focus,targetFocus) -width 6 -justify center
         pack $This.fra5.target -side top -fill x -padx 4 -pady 2
         bind $This.fra5.target <Enter> { ::foc::formatFoc }
         bind $This.fra5.target <Leave> { destroy $audace(base).formatfoc }

      pack $This.fra5 -side top -fill x

      frame $This.fra6 -borderwidth 2 -relief ridge

         LabelEntry $This.fra6.start \
            -label $caption(foc,start) -labeljustify left -labelwidth 12 \
            -textvariable panneau(foc,start) -width 6 -justify center \
            -helptext [format $caption(foc,hlpstart) 0]
         pack $This.fra6.start -side top -fill x -padx 4 -pady 2
         bind $This.fra6.start <Leave> { ::foc::analyseAuto start }

         LabelEntry $This.fra6.end \
            -label $caption(foc,end) -labeljustify left -labelwidth 12 \
            -textvariable panneau(foc,end) -width 6 -justify center \
            -helptext [format $caption(foc,hlpend) 0 65535]
         pack $This.fra6.end -side top -fill x -padx 4 -pady 2
         bind $This.fra6.end <Leave> { ::foc::analyseAuto end }

         LabelEntry $This.fra6.step \
            -label $caption(foc,step) -labeljustify left -labelwidth 12 \
            -textvariable panneau(foc,step) -width 6 -justify center \
            -helptext $caption(foc,hlpstep)
         pack $This.fra6.step -side top -fill x -padx 4 -pady 2
         bind $This.fra6.step <Leave> { ::foc::analyseAuto step }

         LabelEntry $This.fra6.repeat \
            -label $caption(foc,repeat) -labeljustify left -labelwidth 12\
            -textvariable panneau(foc,repeat) -width 6 -justify center \
            -helptext $caption(foc,hlprepeat)
         pack $This.fra6.repeat -side top -fill x -padx 4 -pady 2
         bind $This.fra6.repeat <Leave> { ::foc::analyseAuto repeat }

      pack $This.fra6 -in $This -after $This.fra5 -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $This.fra7 -borderwidth 2 -relief ridge

        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.fra7.avancement_acq -highlightthickness 0 \
           -text $caption(foc,avancement_acq) -variable panneau(foc,avancement_acq)
        pack $This.fra7.avancement_acq -side left -fill x

     pack $This.fra7 -fill x

     #--- Frame pour la simulation
     frame $This.fra8 -borderwidth 2 -relief ridge

        #--- Checkbutton pour la simulation
        checkbutton $This.fra8.simul -highlightthickness 0 \
           -text $caption(foc,simulation) -variable panneau(foc,simulation) \
           -onvalue 1 -offvalue 0
        pack $This.fra8.simul -side left -fill x

     pack $This.fra8 -fill x

     #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $This
}

