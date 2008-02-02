#
# Fichier : tlscp.tcl
# Description : Outil pour le controle des montures
# Compatibilite : Montures LX200, AudeCom, etc.
# Auteurs : Alain KLOTZ, Robert DELMAS et Philippe KAUFFMANN
# Mise a jour $Id: tlscp.tcl,v 1.5 2008-02-02 18:29:44 robertdelmas Exp $
#

#============================================================
# Declaration du namespace tlscp
#    initialise le namespace
#============================================================
namespace eval ::tlscp {
   package provide tlscp 1.1
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] tlscp.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::tlscp::getPluginTitle { } {
   global caption

   return "$caption(tlscp,telescope)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::tlscp::getPluginHelp { } {
   return "tlscp.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::tlscp::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::tlscp::getPluginDirectory { } {
   return "tlscp"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::tlscp::getPluginOS { } {
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
proc ::tlscp::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "acquisition" }
      multivisu    { return 1 }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::tlscp::initPlugin { tkbase } {

}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::tlscp::createPluginInstance { { in "" } { visuNo 1 } } {
   variable private
   global audace caption conf

   #--- parametres de la camera
   if { ! [ info exists conf(tlscp,binning)] }               { set conf(tlscp,binning)               "1x1" }
   if { ! [ info exists conf(tlscp,expTime)] }               { set conf(tlscp,expTime)               "1" }
   if { ! [ info exists conf(tlscp,continuousAcquisition)] } { set conf(tlscp,continuousAcquisition) "0" }
   if { ! [ info exists conf(tlscp,mountEnabled)] }          { set conf(tlscp,mountEnabled)          "0" }

   #--- parametres pour le centrage
   if { ! [ info exists conf(tlscp,alphaSpeed)] }           { set conf(tlscp,alphaSpeed)           "1" }
   if { ! [ info exists conf(tlscp,deltaSpeed)] }           { set conf(tlscp,deltaSpeed)           "1" }
   if { ! [ info exists conf(tlscp,alphaReverse)] }         { set conf(tlscp,alphaReverse)         "0" }
   if { ! [ info exists conf(tlscp,deltaReverse)] }         { set conf(tlscp,deltaReverse)         "0" }
   if { ! [ info exists conf(tlscp,seuilx)] }               { set conf(tlscp,seuilx)               "1" }
   if { ! [ info exists conf(tlscp,seuily)] }               { set conf(tlscp,seuily)               "1" }
   if { ! [ info exists conf(tlscp,angle)] }                { set conf(tlscp,angle)                "0" }
   if { ! [ info exists conf(tlscp,showAxis)] }             { set conf(tlscp,showAxis)             "1" }
   if { ! [ info exists conf(tlscp,showTarget)] }           { set conf(tlscp,showTarget)           "1" }
   if { ! [ info exists conf(tlscp,originCoord)] }          { set conf(tlscp,originCoord)          "" }
   if { ! [ info exists conf(tlscp,targetBoxSize)] }        { set conf(tlscp,targetBoxSize)        "16" }
   if { ! [ info exists conf(tlscp,searchBoxSize)] }        { set conf(tlscp,searchBoxSize)        "64" }
   if { ! [ info exists conf(tlscp,configWindowPosition)] } { set conf(tlscp,configWindowPosition) "+0+0" }
   if { ! [ info exists conf(tlscp,cumulEnabled)] }         { set conf(tlscp,cumulEnabled)         "0" }
   if { ! [ info exists conf(tlscp,cumulNb)] }              { set conf(tlscp,cumulNb)              "5" }
   if { ! [ info exists conf(tlscp,darkEnabled)] }          { set conf(tlscp,darkEnabled)          "0" }
   if { ! [ info exists conf(tlscp,darkFileName)] }         { set conf(tlscp,darkFileName)         "dark.fit" }
   if { ! [ info exists conf(tlscp,centerSpeed)] }          { set conf(tlscp,centerSpeed)          "2" }
   if { ! [ info exists conf(tlscp,searchThreshin)] }       { set conf(tlscp,searchThreshin)       "10" }
   if { ! [ info exists conf(tlscp,searchFwmh)] }           { set conf(tlscp,searchFwmh)           "3" }
   if { ! [ info exists conf(tlscp,searchRadius)] }         { set conf(tlscp,searchRadius)         "4" }
   if { ! [ info exists conf(tlscp,searchThreshold)] }      { set conf(tlscp,searchThreshold)      "40" }

   #--- Initialisation des variables
   set private($visuNo,This)      "[::confVisu::getBase $visuNo].tlscp"
   set private($visuNo,choix_bin) "1x1 2x2 4x4"
   set private($visuNo,menu)      "$caption(tlscp,coord)"
   set private($visuNo,nomObjet)  ""

   #--- Coordonnees J2000.0 de M104
   set private($visuNo,getobj) "12h40m0 -11d37m22"

   #--- Frame principal
   frame $private($visuNo,This) -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $private($visuNo,This).fra1 -borderwidth 2 -relief groove
         #--- Label du titre
         Button $private($visuNo,This).fra1.but -borderwidth 1 -text $caption(tlscp,telescope) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::tlscp::getPluginType ] ] \
               [ ::tlscp::getPluginDirectory ] [ ::tlscp::getPluginHelp ]"
         pack $private($visuNo,This).fra1.but -anchor center -expand 1 \
            -fill both -side top -ipadx 5
         DynamicHelp::add $private($visuNo,This).fra1.but -text $caption(tlscp,help_titre)

      pack $private($visuNo,This).fra1 -side top -fill x

      #--- Frame de la configuration
      frame $private($visuNo,This).config -borderwidth 2 -relief groove
         #--- bouton de configuration
         Button $private($visuNo,This).config.but -borderwidth 1 -text "$caption(tlscp,configuration)..." \
            -command "::tlscp::config::run $visuNo"
         pack $private($visuNo,This).config.but -anchor center -expand 1 \
            -fill both -side top -ipadx 5

      pack $private($visuNo,This).config -side top -fill x

      #--- Frame du pointage
      frame $private($visuNo,This).fra2 -borderwidth 1 -relief groove

         #--- Frame pour choisir un catalogue
         ::cataGoto::createFrameCatalogue $private($visuNo,This).fra2.catalogue $::tlscp::private($visuNo,getobj) $visuNo "::tlscp"
         pack $private($visuNo,This).fra2.catalogue -in $private($visuNo,This).fra2 -anchor nw -side top -padx 4 -pady 1

         #--- Label de l'objet choisi
         label $private($visuNo,This).fra2.lab1 -textvariable ::tlscp::private($visuNo,nomObjet) -relief flat
         pack $private($visuNo,This).fra2.lab1 -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 1

         #--- Entry pour les coordonnes de l'objet
         entry $private($visuNo,This).fra2.ent1 -font $audace(font,arial_8_b) \
            -textvariable ::tlscp::private($visuNo,getobj) -relief groove -width 16
         pack $private($visuNo,This).fra2.ent1 -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 2

         bind $private($visuNo,This).fra2.ent1 <Enter> "::tlscp::FormatADDec $visuNo"
         bind $private($visuNo,This).fra2.ent1 <Leave> "destroy [::confVisu::getBase $visuNo].formataddec"

         frame $private($visuNo,This).fra2.fra1a

            #--- Checkbutton chemin le plus long
            checkbutton $private($visuNo,This).fra2.fra1a.check1 -highlightthickness 0 \
               -variable conf(audecom,gotopluslong) -command "::tlscp::PlusLong $visuNo"
            pack $private($visuNo,This).fra2.fra1a.check1 -in $private($visuNo,This).fra2.fra1a -side left \
               -fill both -anchor center -pady 1

            #--- Bouton MATCH
            button $private($visuNo,This).fra2.fra1a.match -borderwidth 2 -text $caption(tlscp,match) \
               -command "::tlscp::cmdMatch $visuNo"
            pack $private($visuNo,This).fra2.fra1a.match -in $private($visuNo,This).fra2.fra1a -side right -expand 1 \
               -fill both -anchor center -pady 1

         pack $private($visuNo,This).fra2.fra1a -in $private($visuNo,This).fra2 -expand 1 -fill both

         frame $private($visuNo,This).fra2.fra2a

            #--- Bouton Coord. / Stop GOTO
            button $private($visuNo,This).fra2.fra2a.but2 -borderwidth 2 -text $caption(tlscp,coord) \
               -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
            pack $private($visuNo,This).fra2.fra2a.but2 -in $private($visuNo,This).fra2.fra2a -side left \
               -fill both -anchor center -pady 1

            #--- Bouton GOTO
            button $private($visuNo,This).fra2.fra2a.but1 -borderwidth 2 -text $caption(tlscp,goto) \
               -command "::tlscp::cmdGoto $visuNo"
            pack $private($visuNo,This).fra2.fra2a.but1 -in $private($visuNo,This).fra2.fra2a -side right -expand 1 \
               -fill both -anchor center -pady 1

            #--- Bouton Stop GOTO
            button $private($visuNo,This).fra2.fra2a.but3 -borderwidth 2 -text $caption(tlscp,stop_goto) \
               -font $audace(font,arial_10_b) -command { ::telescope::stopGoto }
            pack $private($visuNo,This).fra2.fra2a.but3 -in $private($visuNo,This).fra2.fra2a -side left \
               -fill y -anchor center -pady 1

         pack $private($visuNo,This).fra2.fra2a -in $private($visuNo,This).fra2 -expand 1 -fill both

         #--- Bouton Initialisation Telescope
         button $private($visuNo,This).fra2.but3 -borderwidth 2 -textvariable audace(telescope,inittel) \
            -command "::tlscp::cmdInitTel $visuNo"
         pack $private($visuNo,This).fra2.but3 -in $private($visuNo,This).fra2 -side bottom -anchor center \
            -fill x -pady 1

      pack $private($visuNo,This).fra2 -side top -fill x

      #--- Frame des coordonnees
      frame $private($visuNo,This).fra3 -borderwidth 1 -relief groove

         #--- Label pour RA
         label $private($visuNo,This).fra3.ent1 -font $audace(font,arial_10_b) \
            -textvariable audace(telescope,getra) -relief flat
         pack $private($visuNo,This).fra3.ent1 -in $private($visuNo,This).fra3 -anchor center -fill none -pady 1

         #--- Label pour DEC
         label $private($visuNo,This).fra3.ent2 -font $audace(font,arial_10_b) \
            -textvariable audace(telescope,getdec) -relief flat
         pack $private($visuNo,This).fra3.ent2 -in $private($visuNo,This).fra3 -anchor center -fill none -pady 1

      pack $private($visuNo,This).fra3 -side top -fill x
      set zone(radec) $private($visuNo,This).fra3

      bind $zone(radec) <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      frame $private($visuNo,This).fra4 -borderwidth 1 -relief groove

         #--- Create the button 'N'
         frame $private($visuNo,This).fra4.n -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.n -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design
         button $private($visuNo,This).fra4.n.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tlscp,nord)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.n.canv1 -in $private($visuNo,This).fra4.n -expand 0 \
            -side top -padx 2 -pady 0

         #--- Create the buttons 'E W'
         frame $private($visuNo,This).fra4.we -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.we -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design 'E'
         button $private($visuNo,This).fra4.we.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tlscp,est)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.we.canv1 \
            -in $private($visuNo,This).fra4.we -expand 1 -side left -padx 0 -pady 0

         #--- Write the label of speed
         label $private($visuNo,This).fra4.we.lab \
            -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
            -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.we.lab \
            -in $private($visuNo,This).fra4.we -expand 1 -side left

         #--- Button-design 'W'
         button $private($visuNo,This).fra4.we.canv2 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tlscp,ouest)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.we.canv2 \
            -in $private($visuNo,This).fra4.we -expand 1 -side right -padx 0 -pady 0

         #--- Create the button 'S'
         frame $private($visuNo,This).fra4.s -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.s -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design
         button $private($visuNo,This).fra4.s.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tlscp,sud)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.s.canv1 \
            -in $private($visuNo,This).fra4.s -expand 0 -side top -padx 2 -pady 0

         set zone(n) $private($visuNo,This).fra4.n.canv1
         set zone(e) $private($visuNo,This).fra4.we.canv1
         set zone(w) $private($visuNo,This).fra4.we.canv2
         set zone(s) $private($visuNo,This).fra4.s.canv1

         #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
         label $private($visuNo,This).fra4.s.lab1 -font $audace(font,arial_10_b) \
            -textvariable audace(telescope,controle) -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.s.lab1 -in $private($visuNo,This).fra4.s -expand 1 -side left

      pack $private($visuNo,This).fra4 -side top -fill x

      bind $private($visuNo,This).fra4.we.lab <ButtonPress-1> { ::tlscp::cmdSpeed }
      bind $private($visuNo,This).fra4.s.lab1 <ButtonPress-1> { ::tlscp::cmdCtlSuivi }

      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1> { ::tlscp::cmdMove e }
      bind $zone(e) <ButtonRelease-1> { ::tlscp::cmdStop e }
      bind $zone(w) <ButtonPress-1> { ::tlscp::cmdMove w }
      bind $zone(w) <ButtonRelease-1> { ::tlscp::cmdStop w }
      bind $zone(s) <ButtonPress-1> { ::tlscp::cmdMove s  }
      bind $zone(s) <ButtonRelease-1> { ::tlscp::cmdStop s }
      bind $zone(n) <ButtonPress-1> { ::tlscp::cmdMove n }
      bind $zone(n) <ButtonRelease-1> { ::tlscp::cmdStop n }

      #--- Frame de la camera
      frame $private($visuNo,This).camera -borderwidth 1 -relief groove
         frame $private($visuNo,This).camera.pose
            label $private($visuNo,This).camera.pose.label -text "$caption(tlscp,pose)"
            set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
            ComboBox $private($visuNo,This).camera.pose.combo \
               -width 4 -height [ llength $list_combobox ] \
               -relief sunken -borderwidth 1 -editable 1 \
               -textvariable ::conf(tlscp,expTime) \
               -values $list_combobox
            button $private($visuNo,This).camera.pose.webcam -text "$caption(tlscp,pose)" \
               -command "::tlscp::webcamConfigure $visuNo"

            grid $private($visuNo,This).camera.pose.label -row 0 -column 0  -sticky nsew
            grid $private($visuNo,This).camera.pose.combo -row 0 -column 1  -sticky nsew
            grid $private($visuNo,This).camera.pose.webcam -row 0 -column 0 -sticky nsew
            grid columnconfigure  $private($visuNo,This).camera.pose 0 -weight  1
            grid columnconfigure  $private($visuNo,This).camera.pose 1 -weight  1

#         #--- Frame invisible pour le temps de pose
#         frame $private($visuNo,This).camera.fra1

#            #--- Entry pour l'objet a centrer
#            entry $private($visuNo,This).camera.fra1.ent1 -font $audace(font,arial_8_b) \
#               -textvariable ::conf(tlscp,expTime) -relief groove -width 5 -justify center
#            pack $private($visuNo,This).camera.fra1.ent1 -in $private($visuNo,This).camera.fra1 -side left \
#               -fill none -padx 4 -pady 2

#            label $private($visuNo,This).camera.fra1.lab1 -text $caption(tlscp,seconde) -relief flat
#            pack $private($visuNo,This).camera.fra1.lab1 -in $private($visuNo,This).camera.fra1 -side left \
#               -fill none -padx 1 -pady 1

#         pack $private($visuNo,This).camera.fra1 -in $private($visuNo,This).camera -side top -fill x

         #--- Menu pour binning
         frame $private($visuNo,This).camera.optionmenu1 -borderwidth 0 -relief groove
            menubutton $private($visuNo,This).camera.optionmenu1.but_bin -text $caption(tlscp,binning) \
               -menu $private($visuNo,This).camera.optionmenu1.but_bin.menu -relief raised
            pack $private($visuNo,This).camera.optionmenu1.but_bin -in $private($visuNo,This).camera.optionmenu1 \
               -side left -fill none
            set m [ menu $private($visuNo,This).camera.optionmenu1.but_bin.menu -tearoff 0 ]
            foreach valbin $private($visuNo,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable ::conf(tlscp,binning) \
                  -command { }
            }
            entry $private($visuNo,This).camera.optionmenu1.lab_bin -width 3 -font {arial 10 bold} -relief groove \
              -textvariable ::conf(tlscp,binning) -justify center -state disabled
            pack $private($visuNo,This).camera.optionmenu1.lab_bin -in $private($visuNo,This).camera.optionmenu1 \
               -side left -fill both -expand true

         #--- Bouton GO
         button $private($visuNo,This).camera.goccd -borderwidth 2 -text $caption(tlscp,goccd) \
            -command "::tlscp::center::startAcquisition $visuNo acq"
         #--- Bouton center
         #button $private($visuNo,This).camera.center -borderwidth 2 -text "center" \
         #   -command " ::tlscp::cmdCenter $visuNo"

         #--- checkbutton continu
        checkbutton $private($visuNo,This).camera.continu -text "$caption(tlscp,continu)" \
         -variable ::conf(tlscp,continuousAcquisition)
         #--- checkbutton monture active
        checkbutton $private($visuNo,This).camera.mountEnabled -text "$caption(tlscp,mountEnabled)" \
         -variable ::conf(tlscp,mountEnabled)

         grid $private($visuNo,This).camera.pose  -row 0  -sticky nsew -pady 1
         grid $private($visuNo,This).camera.optionmenu1 -row 1 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.goccd  -row 2 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.continu -row 3 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.mountEnabled -row 4 -sticky nsew -pady 1
         grid columnconfigure  $private($visuNo,This).camera 0 -weight  1

      pack $private($visuNo,This).camera -side top -fill x

      ::tlscp::adaptPanel $visuNo

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private($visuNo,This)
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::tlscp::deletePluginInstance { visuNo } {
   variable private

   #--- je detruis le panel
   destroy $private($visuNo,This)
}

#------------------------------------------------------------
# adaptPanel
#    adapte l'affichage des boutons en fonction de la camera
#
# parametres
#    visuNo    : numero de la visu
#    varName   : nom de la variable surveillee
#    varIndex  : index de la variable surveillee si c'est un array
#    operation : operation declencheuse (array read write unset)
#------------------------------------------------------------
proc ::tlscp::adaptPanel { visuNo args } {
   variable private
   global conf

   #--- Configuration des specificites AudeCom
   if { $conf(telescope) == "audecom" } {
      pack $private($visuNo,This).fra2.fra1a.check1 -in $private($visuNo,This).fra2.fra1a -side left \
         -fill both -anchor center -pady 1
      pack $private($visuNo,This).fra2.fra2a.but2 -in $private($visuNo,This).fra2.fra2a -side right \
         -fill both -anchor center -pady 1
      pack forget $private($visuNo,This).fra2.fra2a.but3
      pack $private($visuNo,This).fra2.but3 -in $private($visuNo,This).fra2 -side bottom -anchor center -fill x -pady 1
   } else {
      pack forget $private($visuNo,This).fra2.fra1a.check1
      pack forget $private($visuNo,This).fra2.fra2a.but2
      pack $private($visuNo,This).fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
      pack forget $private($visuNo,This).fra2.but3
   }

   #--- Configuration du controle du suivi sideral
   if { [ ::confTel::getPluginProperty hasControlSuivi ] == "0" } {
      pack forget $private($visuNo,This).fra4.s.lab1
   } else {
      pack $private($visuNo,This).fra4.s.lab1 -in $private($visuNo,This).fra4.s -expand 1 -side left
   }

   #--- Configuration du Goto
   if { [ ::confTel::getPluginProperty hasGoto ] == "0" } {
      $private($visuNo,This).fra2.fra2a.but1 configure -relief groove -state disabled
      $private($visuNo,This).fra2.fra2a.but2 configure -relief groove -state disabled
      $private($visuNo,This).fra2.fra2a.but3 configure -relief groove -state disabled
   } else {
      $private($visuNo,This).fra2.fra2a.but1 configure -relief raised -state normal
      $private($visuNo,This).fra2.fra2a.but2 configure -relief raised -state normal
      $private($visuNo,This).fra2.fra2a.but3 configure -relief raised -state normal
   }

   #--- Configuration du Match
   if { [ ::confTel::getPluginProperty hasMatch ] == "0" } {
      $private($visuNo,This).fra2.fra1a.match configure -relief groove -state disabled
   } else {
      $private($visuNo,This).fra2.fra1a.match configure -relief raised -state normal
   }

   set This $private($visuNo,This)
   set camItem [ ::confVisu::getCamItem $visuNo ]

   #--- j'adapte les boutons de selection de pose et de binning
   if { [::confCam::getPluginProperty $camItem longExposure] == "1" } {
      #--- avec longue pose
      grid $private($visuNo,This).camera.pose.label
      grid $private($visuNo,This).camera.pose.combo
      grid remove $private($visuNo,This).camera.pose.webcam
   } else {
      #--- sans longue pose
      grid remove $private($visuNo,This).camera.pose.label
      grid remove $private($visuNo,This).camera.pose.combo
      grid $private($visuNo,This).camera.pose.webcam
      #--- je mets la pose a zero car cette variable n'est pas utilisee et doit etre nulle
      set ::conf(tlscp,expTime) "0"
   }

   if { [::confCam::getPluginProperty $camItem hasBinning] == "0" } {
     #grid remove $This.binning
   } else {
     #set list_binning [::confCam::getPluginProperty $camItem binningList]
     #$This.binning.combo configure -values $list_binning -height [ llength $list_binning]
     #grid $This.binning
   }
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::tlscp::startTool { visuNo } {
   variable private

   trace add variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   trace add variable ::temma::private(modele) write "::tlscp::adaptPanel $visuNo"
   pack $private($visuNo,This) -side left -fill y

   #--- j'active la mise a jour automatique de l'affichage quand on change de camera
   ::confVisu::addCameraListener $visuNo "::tlscp::adaptPanel $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
   ::confVisu::addZoomListener $visuNo "::tlscp::onChangeZoom $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de fenetrage
   ::confVisu::addSubWindowListener $visuNo "::tlscp::onChangeSubWindow $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de miroir
   ::confVisu::addMirrorListener $visuNo "::tlscp::onChangeSubWindow $visuNo"

   #--- Je refraichis l'affichage des coordonnees
   ::telescope::afficheCoord

   #--- je change le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::tlscp::center::setOrigin $visuNo %x %y"
   #--- je change le bind du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "::tlscp::center::setTargetCoord $visuNo %x %y"

   #--- J'affiche les axes
   ::tlscp::center::init $visuNo
   if { $::conf(tlscp,showAxis) == "1" } {
      ::tlscp::center::changeShowAxis $visuNo
   }
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::tlscp::stopTool { visuNo } {
   variable private

   #--- je masque les axes
   ::tlscp::center::deleteAlphaDeltaAxis $visuNo
   #--- je masque les marques des etoiles
   [::confVisu::getCanvas $visuNo] delete tlscpstar

   #--- je restaure le bind par defaut du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "default"
   #--- je restaure le bind par defaut du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "default"

   trace remove variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   trace remove variable ::temma::private(modele) write "::tlscp::adaptPanel $visuNo"
   pack forget $private($visuNo,This)
}

#------------------------------------------------------------
# cmdMatch
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::tlscp::cmdMatch { visuNo } {
   variable private

   $private($visuNo,This).fra2.fra1a.match configure -relief groove -state disabled
   update
   ::telescope::match $private($visuNo,getobj)
   $private($visuNo,This).fra2.fra1a.match configure -relief raised -state normal
   update
}

proc ::tlscp::cmdGoto { visuNo } {
   variable private
   global audace caption cataGoto catalogue

   #--- Gestion graphique des boutons GOTO et Stop
   $private($visuNo,This).fra2.fra2a.but1 configure -relief groove -state disabled
   $private($visuNo,This).fra2.fra2a.but2 configure -text $caption(tlscp,stop_goto) -font $audace(font,arial_8_b) \
      -command "::tlscp::cmdStopGoto $visuNo"
   update

   #--- Affichage de champ dans une carte. Parametres : nom_objet, ad, dec, zoom_objet, avant_plan
   if { $cataGoto(carte,validation) == "1" } {
      ::carte::gotoObject $cataGoto(carte,nom_objet) $cataGoto(carte,ad) $cataGoto(carte,dec) $cataGoto(carte,zoom_objet) $cataGoto(carte,avant_plan)
   }

   #--- Cas particulier si le premier pointage est en mode coordonnees
   if { $private($visuNo,menu) == "$caption(tlscp,coord)" } {
      set private($visuNo,list_radec) $private($visuNo,getobj)
   }

   #--- Prise en compte des corrections de precession, de nutation et d'aberrations (annuelle et diurne)
   if { $private($visuNo,menu) != "$caption(tlscp,coord)" && $private($visuNo,menu) != "$caption(tlscp,planete)" \
      && $private($visuNo,menu) != "$caption(tlscp,asteroide)" && $private($visuNo,menu) != "$caption(tlscp,zenith)" } {
      #--- Initialisation du temps
      set now now
      catch {
         set now [::audace::date_sys2ut now]
      }
      #--- Calcul des corrections et affichage dans la Console
      set ad_objet_cata  [ lindex $private($visuNo,list_radec) 0 ]
      set dec_objet_cata [ lindex $private($visuNo,list_radec) 1 ]
      ::console::disp "\n"
      ::console::disp "$caption(tlscp,coord_catalogue) \n"
      ::console::disp "$caption(tlscp,ad) $ad_objet_cata \n"
      ::console::disp "$caption(tlscp,dec) $dec_objet_cata \n"
      set ad_dec_vrai    [ ::tkutil::coord_eph_vrai $ad_objet_cata $dec_objet_cata J2000.0 $now ]
      set ad_objet_vrai  [ lindex $ad_dec_vrai 0 ]
      set dec_objet_vrai [ lindex $ad_dec_vrai 1 ]
      ::console::disp "$caption(tlscp,coord_corrigees) \n"
      ::console::disp "$caption(tlscp,ad) $ad_objet_vrai \n"
      ::console::disp "$caption(tlscp,dec) $dec_objet_vrai \n"
      set private($visuNo,list_radec) "$ad_objet_vrai $dec_objet_vrai"
   }

   #--- Goto
   ::telescope::goto $private($visuNo,list_radec) "0" $private($visuNo,This).fra2.fra2a.but1 $private($visuNo,This).fra2.fra1a.match

   #--- Affichage des coordonnees pointees par le telescope dans la Console
   if { $private($visuNo,menu) != "$caption(tlscp,coord)" && $private($visuNo,menu) != "$caption(tlscp,planete)" \
      && $private($visuNo,menu) != "$caption(tlscp,asteroide)" && $private($visuNo,menu) != "$caption(tlscp,zenith)" } {
      ::telescope::afficheCoord
      ::console::disp "$caption(tlscp,coord_pointees) \n"
      ::console::disp "$caption(tlscp,ad) $audace(telescope,getra) \n"
      ::console::disp "$caption(tlscp,dec) $audace(telescope,getdec) \n"
      ::console::disp "\n"
   }

   #--- Gestion graphique du bouton Stop
   $private($visuNo,This).fra2.fra2a.but2 configure -relief raised -state normal -text $caption(tlscp,coord) \
      -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
   update
}

proc ::tlscp::setRaDec { visuNo listRaDec nomObjet } {
   variable private

   set private($visuNo,getobj)   $listRaDec
   set private($visuNo,nomObjet) $nomObjet
}

proc ::tlscp::PlusLong { visuNo } {
   global audace caption conf

   set This "[::confVisu::getBase $visuNo].pluslong"
   if { $conf(audecom,gotopluslong) == "0" } {
      catch { tel$audace(telNo) slewpath short }
      destroy $This
   } else {
      catch { tel$audace(telNo) slewpath long }
      if [ winfo exists $This ] {
         destroy $This
      }

      #---
      toplevel $This
      wm transient $This [::confVisu::getBase $visuNo]
      wm resizable $This 0 0
      wm title $This "$caption(tlscp,attention)"
      set posx_pluslong [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 1 ]
      set posy_pluslong [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_pluslong + 120 ]+[ expr $posy_pluslong + 105 ]

      #--- Cree l'affichage du message
      label $This.lab1 -text "$caption(tlscp,pluslong1)"
      pack $This.lab1 -padx 10 -pady 2
      label $This.lab2 -text "$caption(tlscp,pluslong2)"
      pack $This.lab2 -padx 10 -pady 2
      label $This.lab3 -text "$caption(tlscp,pluslong3)"
      pack $This.lab3 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

proc ::tlscp::cmdStopGoto { visuNo } {
   variable private

   $private($visuNo,This).fra2.fra2a.but2 configure -relief groove -state disabled
   update
   ::telescope::stopGoto $private($visuNo,This).fra2.fra2a.but2
}

proc ::tlscp::cmdInitTel { visuNo } {
   variable private

   $private($visuNo,This).fra2.but3 configure -relief groove -state disabled
   update
   ::telescope::initTel $private($visuNo,This).fra2.but3 $visuNo
}

proc ::tlscp::FormatADDec { visuNo } {
   global caption

   set This "[::confVisu::getBase $visuNo].formataddec"

   if [ winfo exists $This ] {
      destroy $This
   }

   #---
   toplevel $This
   wm transient $This [::confVisu::getBase $visuNo]
   wm title $This "$caption(tlscp,attention)"
   set posx_formataddec [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 1 ]
   set posy_formataddec [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_formataddec + 120 ]+[ expr $posy_formataddec + 90 ]
   wm resizable $This 0 0

   #--- Cree l'affichage du message
   label $This.lab1 -text "$caption(tlscp,formataddec1)"
   pack $This.lab1 -padx 10 -pady 2
   label $This.lab2 -text "$caption(tlscp,formataddec2)"
   pack $This.lab2 -padx 10 -pady 2
   label $This.lab3 -text "$caption(tlscp,formataddec3)"
   pack $This.lab3 -padx 10 -pady 2
   label $This.lab4 -text "$caption(tlscp,formataddec4)"
   pack $This.lab4 -padx 10 -pady 2
   label $This.lab5 -text "$caption(tlscp,formataddec5)"
   pack $This.lab5 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $This

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc ::tlscp::cmdCtlSuivi { { value " " } } {
   ::telescope::controleSuivi $value
}

proc ::tlscp::cmdMove { direction } {
   ::telescope::move $direction
}

proc ::tlscp::cmdStop { direction } {
   ::telescope::stop $direction
}

proc ::tlscp::cmdSpeed { } {
   ::telescope::incrementSpeed
}

#------------------------------------------------------------
# startSearchStar
#    cherche une l'étoile la plus brillante dans la zone
# parametres
#    visuNo : numero de visu
# return :
#    - les coordonnes de l'etoile trouvee
#    - une chaine vide si une etoile n'est pas trouvee
#------------------------------------------------------------
proc ::tlscp::startSearchStar { visuNo } {
   variable private

   #--- j'active le mode continu
   set ::conf(tlscp,continuousAcquisition) 0
   set private($visuNo,acquisitionState)  1

   #--- j'efface les traces précédentes
   clearSearchStar  $visuNo

   #--- je lance les acquisitions
   set result [::tlscp::center::startAcquisition $visuNo "search" ]

   if { $result == 0 } {
      #--- j'attends la fin de l'acquisition
      vwait ::tlscp::center::private($visuNo,acquisitionState)
      set result $::tlscp::center::private($visuNo,searchResult)
   } else {
      set result ""
   }

   return $result
}

#------------------------------------------------------------
# clearSearchStar
#    efface les marques de étoiles
# parametres
#    visuNo : numero de visu
# return :
#    rien
#------------------------------------------------------------
proc ::tlscp::clearSearchStar { visuNo } {
   variable private

   [::confVisu::getCanvas $visuNo] delete tlscpstar
}

#------------------------------------------------------------
# startCenterStar
#    lance le centrage de l'étoile
#
# return :
#    - les coordonnes de l'etoile trouvee
#    - une chaine vide si une etoile n'est pas trouvee
#------------------------------------------------------------
proc ::tlscp::startCenterStar { visuNo  } {
   variable private

   if { $::audace(telNo) != 0 } {
      ::telescope::setSpeed $::conf(tlscp,centerSpeed)
      set ::conf(tlscp,mountEnabled) 1
   } else {
      set ::conf(tlscp,mountEnabled) 0
   }

   set ::conf(tlscp,continuousAcquisition) "1"
   set result [ ::tlscp::center::startAcquisition $visuNo "center" ]
   if { $result == 0 } {
      vwait ::tlscp::center::private($visuNo,centerResult)
      set result $::tlscp::center::private($visuNo,centerResult)
   } else {
      set result ""
   }
   return $result
}

#------------------------------------------------------------
# stopAcquisition
#    arrete les acqusitions
#
# return :
#    rien
#------------------------------------------------------------
proc ::tlscp::stopAcquisition { visuNo  } {
   variable private

   ::tlscp::center::stopAcquisition $visuNo
}

#------------------------------------------------------------
# onChangeZoom
#    appl
# parametres
#    visuNo  : numero de visu
#     args   : valeur fournies par le gestionnaire de listener
# return : null
#------------------------------------------------------------
proc ::tlscp::onChangeZoom { visuNo args } {
   variable private

   #--- je redessine l'origine
   ::tlscp::center::changeShowAxis $visuNo
   #--- je redessine la cible
   ::tlscp::center::moveTarget $visuNo $::tlscp::center::private($visuNo,targetCoord)
}

#------------------------------------------------------------
# onChangeSubWindow
#    appl
# parametres
#    visuNo  : numero de visu
#     args   : valeur fournies par le gestionnaire de listener
# return : null
#------------------------------------------------------------
proc ::tlscp::onChangeSubWindow { visuNo args } {
   variable private

   #--- je redessine l'origine
   ::tlscp::center::changeShowAxis $visuNo
   #--- je redessine la cible
   ::tlscp::center::moveTarget $visuNo $::tlscp::center::private($visuNo,targetCoord)
}

#------------------------------------------------------------
# configureWebcam
#    affiche la fenetre de configuration d'une webcam
#------------------------------------------------------------
proc ::tlscp::webcamConfigure { visuNo } {
   global caption

   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title [::tlscp::getPluginTitle] -type ok \
                -message "You must select a camera first\n(Setup/Camera)." ]
         if { $choix == "ok" } {
             #--- Ouverture de la fenetre de selection des cameras
             ::confCam::run
             tkwait window $audace(base).confCam
         }
         ::audace::menustate normal
      }
   }
}

proc ::tlscp::TestReel { valeur } {
   #--- Vérifie que la chaine passée en argument décrit bien un réel
   #--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un reel
   set test 1
   for { set i 0 } { $i < [ string length $valeur ] } { incr i } {
      set a [ string index $valeur $i ]
      if { ! [ string match {[0-9.]} $a ] } {
         set test 0
      }
   }
   return $test
}

proc ::tlscp::validateNumber { win event X oldX  min max} {
   global audace

   # Make sure min<=max
   if {$min > $max} {
      set tmp $min; set min $max; set max $tmp
   }
   # Allow valid integers, empty strings, sign without number
   # Reject Octal numbers, but allow a single "0"
   # Which signes are allowed ?
   if {($min <= 0) && ($max >= 0)} {   ;# positive & negative sign
      set pattern {^[+-]?(()|0|([1-9\.][0-9\.]*))$}
   } elseif {$max < 0} {               ;# negative sign
      set pattern {^[-]?(()|0|([1-9\.][0-9\.]*))$}
   } else {                            ;# positive sign
      set pattern {^[+]?(()|0|([1-9\.][0-9\.]*))$}
   }
   # Weak integer checking: allow empty string, empty sign, reject octals
   set weakCheck [regexp $pattern $X]
   # if weak check fails, continue with old value
   if {! $weakCheck} {set X $oldX}
   # Strong integer checking with range
   set strongCheck [expr {[string is double  $X] && ($X >= $min) && ($X <= $max)}]

   switch $event {
      key {
         if { $strongCheck == 0 } {
            $win configure -bg $audace(color,entryTextColor) -fg $audace(color,entryBackColor)
         } else {
            $win configure -bg $audace(color,entryBackColor) -fg $audace(color,entryTextColor)
         }
         return $weakCheck
      }
      focusout {
         if { $strongCheck == 0} {
            $win configure -bg $audace(color,entryTextColor) -fg $audace(color,entryBackColor)
         } else {
            $win configure -bg $audace(color,entryBackColor) -fg $audace(color,entryTextColor)
         }
         return $strongCheck
      }
      default {
          return 1
      }
   }
}

################################################################################
namespace eval ::tlscp::center {

}
################################################################################

proc ::tlscp::center::init { visuNo } {
   variable private

   set private($visuNo,updateAxis)       ""
   set private($visuNo,targetCoord)      ""
   set private($visuNo,centerButton)     ""
   set private($visuNo,hCanvas)          [::confVisu::getCanvas $visuNo]
   set private($visuNo,dx)               [format "%##0.1f" "0"]
   set private($visuNo,dy)               [format "%##0.1f" "0"]
   set private(previousAlphaDirection)   "e"
   set private(previousDeltaDirection)   "n"
   set private($visuNo,acquisitionState) "0"
   set private($visuNo,mode)             "acq"
   set private($visuNo,centerResult)     ""
   set private($visuNo,searchResult)     ""
   set private($visuNo,deltaList)        ""
}

#------------------------------------------------------------
# startAcquisition
#    execute les acquisitions en boucle
# parametres
#    visuNo : numero de la visu
#    mode   :  "acq" , "center", "search"
# return
#    0 si le lance est OK
#    1 si erreur de lancement
#------------------------------------------------------------
proc ::tlscp::center::startAcquisition { visuNo mode } {
   variable private
   global caption conf

   if { $private($visuNo,acquisitionState) != 0 } {
      #--- je ne fais rien si une demande d'arret est en cours
      return 1
   }

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]
   set camNo   [::confCam::getCamNo $camItem ]

   #--- je verifie la presence de la camera
   if { [::confCam::isReady $camItem] == 0 } {
      ::confCam::run
      return 1
   }

   set private($visuNo,acquisitionState) 1
   set private($visuNo,mode)  $mode

   #--- j'affiche le bouton STOP CCD
   $::tlscp::private($visuNo,This).camera.goccd configure -text "$::caption(tlscp,stopccd) (ESC)" -command "::tlscp::center::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::tlscp::center::stopAcquisition $visuNo"

   if { $private($visuNo,mode) == "center" } {
      #--- J'intialise la liste des deltas
      set private($visuNo,deltaList) ""
      lappend  private($visuNo,deltaList) [list $::conf(tlscp,searchBoxSize) $::conf(tlscp,searchBoxSize)]
      lappend  private($visuNo,deltaList) [list $::conf(tlscp,searchBoxSize) $::conf(tlscp,searchBoxSize)]
      lappend  private($visuNo,deltaList) [list $::conf(tlscp,searchBoxSize) $::conf(tlscp,searchBoxSize)]
      lappend  private($visuNo,deltaList) [list $::conf(tlscp,searchBoxSize) $::conf(tlscp,searchBoxSize)]
      set private($visuNo,centerResult) ""
   }

   if { $private($visuNo,mode) == "search" } {
      set private($visuNo,searchResult) ""
   }

   #--- je parametre le binning
   cam$camNo bin [list [string range $::conf(tlscp,binning) 0 0] [string range $::conf(tlscp,binning) 2 2]]

   #--- j'arrete la mise a jour des coordonnees dans les images, pour gagner du temps
   cam$camNo radecfromtel 0
   cam$camNo exptime $::conf(tlscp,expTime)

   set private($visuNo,camThreadNo) [::confCam::getThreadNo $camItem ]
   if { $private($visuNo,camThreadNo) == 0 } {
      after 0 [list ::tlscp::center::processAcquisition $visuNo $camNo ""]
   } else {
      set script [info body ::tlscp::center::processAcquisition]
      thread::send $private($visuNo,camThreadNo) "proc processAcquisition { visuNo camNo mainThreadNo } { $script } "
      #--- je fais une acquisition avec la thread de la camera
      thread::send -async $private($visuNo,camThreadNo) "processAcquisition $visuNo $camNo [thread::id]"
   }

   return 0
}

#------------------------------------------------------------
# stopAcquisition
#    arrete les acquisitions en boucle
#------------------------------------------------------------
proc ::tlscp::center::stopAcquisition { visuNo } {
   variable private

   if { $private($visuNo,acquisitionState) == 1 } {
      #--- j'affiche le bouton GO CCD
      $::tlscp::private($visuNo,This).camera.goccd configure -text $::caption(tlscp,goccd) -command "::tlscp::center::startAcquisition $visuNo acq"
      #--- je supprime l'association du bouton escape
      bind all <Key-Escape>
      set private($visuNo,acquisitionState) 0
   }
}

#------------------------------------------------------------
# processAcquisition
#    traite une acquisition
#------------------------------------------------------------
proc ::tlscp::center::processAcquisition { visuNo camNo mainThreadNo} {
   set result 0

   #--- je fais une acquisition
   cam$camNo acq
   set statusVariableName "::status_cam$camNo"
   if { [set $statusVariableName] == "exp" } {
      vwait ::status_cam$camNo
   }

   #--- je traite l'acquisition
   if { $mainThreadNo == "" } {
      set result [::tlscp::center::processAcquisition2 $visuNo $camNo ]
   } else {
      set result [thread::send $mainThreadNo  "::tlscp::center::processAcquisition2 $visuNo"]
   }

   if { $result == 0 } {
      #--- c'est reparti pour tour ...
      after 10 [list processAcquisition $visuNo $camNo $mainThreadNo]
   }
}

#------------------------------------------------------------
# processAcquisition2
#
# traite une acquisition (suite) :
#    determine l'ecart entre la cible et le point de reference
#    envoi les commandes deplacement au telescope
#------------------------------------------------------------
proc ::tlscp::center::processAcquisition2 { visuNo } {
   variable private
   global caption conf

   set catchError [ catch {
      set bufNo [::confVisu::getBufNo $visuNo ]
      #--- si l'origine n'est pas deja fixee, je prends le centre de l'image pour origine
      if { $::conf(tlscp,originCoord) == "" } {
         set ::conf(tlscp,originCoord) [list [expr [buf$bufNo getpixelswidth]/2] [expr [buf$bufNo getpixelsheight]/2] ]
         set private($visuNo,updateAxis) 1
      }
      #--- si la cible n'est pas deja fixee, je prends les coordonnees de l'origine
      if { $private($visuNo,targetCoord) == "" } {
         set private($visuNo,targetCoord) $::conf(tlscp,originCoord)
      }

      #--- je calcule la position de l'etoile guide dans la zone cible
      #--- je calcule les coordonnees de la cible autour de l'etoile
      if { $private($visuNo,mode) == "center" } {
         set x  [lindex $private($visuNo,targetCoord) 0]
         set y  [lindex $private($visuNo,targetCoord) 1]
         set x1 [expr int($x) - $::conf(tlscp,targetBoxSize)]
         set x2 [expr int($x) + $::conf(tlscp,targetBoxSize)]
         set y1 [expr int($y) - $::conf(tlscp,targetBoxSize)]
         set y2 [expr int($y) + $::conf(tlscp,targetBoxSize)]
         set private($visuNo,targetCoord) [buf$bufNo centro "[list $x1 $y1 $x2 $y2]"]
         ##console::disp "::tlscp::center::processAcquisition2 targetCoord=$private($visuNo,targetCoord) \n"

         #--- je calcule l'ecart de position par rapport a la position d'origine
         set dx [expr [lindex $private($visuNo,targetCoord) 0] - [lindex $::conf(tlscp,originCoord) 0] ]
         set dy [expr [lindex $private($visuNo,targetCoord) 1] - [lindex $::conf(tlscp,originCoord) 1] ]

         #--- je diminue les valeurs de dx et dy si elles depassent la taille de la zone de detection de l'etoile
         if { $dx > $conf(tlscp,targetBoxSize) } {
            set dx $conf(tlscp,targetBoxSize)
         } elseif { $dx <  -$conf(tlscp,targetBoxSize) } {
            set dx [expr -$conf(tlscp,targetBoxSize) ]
         }

         if { $dy > $conf(tlscp,targetBoxSize) } {
            set dy $conf(tlscp,targetBoxSize)
         } elseif { $private($visuNo,dy) <  -$conf(tlscp,targetBoxSize) } {
            set dy [expr -$conf(tlscp,targetBoxSize) ]
         }

         set private($visuNo,dx) [format "%##0.1f" $dx]
         set private($visuNo,dy) [format "%##0.1f" $dy]
      } elseif { $private($visuNo,mode) == "search" } {
         #--- mode=search
         ::confVisu::autovisu $visuNo
         set x  [lindex $::conf(tlscp,originCoord) 0]
         set y  [lindex $::conf(tlscp,originCoord) 1]
         set x1 [expr int($x) - $conf(tlscp,searchBoxSize)]
         set x2 [expr int($x) + $conf(tlscp,searchBoxSize)]
         set y1 [expr int($y) - $conf(tlscp,searchBoxSize)]
         set y2 [expr int($y) + $conf(tlscp,searchBoxSize)]

         set private($visuNo,searchResult) [searchStar $visuNo [list $x1 $y1 $x2 $y2] ]
         if { $private($visuNo,searchResult) != "" } {
             set private($visuNo,targetCoord) $private($visuNo,searchResult)
             moveTarget $visuNo $private($visuNo,targetCoord)
         }
         return
      }

      #--- j'affiche l'image
      ::confVisu::autovisu $visuNo

      #--- je mets a jour l'affichage des axes si c'est necessaire
      if { $private($visuNo,updateAxis) == 1 } {
         createAlphaDeltaAxis $visuNo $::conf(tlscp,originCoord) $conf(tlscp,angle)
         set private($visuNo,updateAxis) 0
      }

      #--- j'affiche le symbole de la cible si c'est autorise
      if { $conf(tlscp,showTarget) == "1" } {
         moveTarget $visuNo $private($visuNo,targetCoord)
      }

      #--- je deplace le telescope
      if { $::conf(tlscp,mountEnabled) == 1 && $private($visuNo,acquisitionState) == "1" } {
         #--- je convertis l'angle en radian
         set angle [expr $conf(tlscp,angle)* 3.14159265359/180 ]

         #--- je calcule les delais de deplacement alpha et delta (en millisecondes)
         set alphaDelay [expr int((cos($angle) * $private($visuNo,dx) - sin($angle) *$private($visuNo,dy)) * $conf(tlscp,alphaSpeed))]
         set deltaDelay [expr int((sin($angle) * $private($visuNo,dx) + cos($angle) *$private($visuNo,dy)) * $conf(tlscp,deltaSpeed))]
         #--- calcul des seuils minimaux de deplacement alpha et delta (en millisecondes)
         set seuilAlpha [expr $::conf(tlscp,seuilx) * $conf(tlscp,alphaSpeed)]
         set seuilDelta [expr $::conf(tlscp,seuily) * $conf(tlscp,deltaSpeed)]

         #--- j'inverse le sens des deplacements si necessaire
         if { $conf(tlscp,alphaReverse) == "1" } {
            set alphaDelay [expr -$alphaDelay]
         }
         if { $conf(tlscp,deltaReverse) == "1" } {
            set deltaDelay [expr -$deltaDelay]
         }

         #--- je calcule la direction alpha
         if { $alphaDelay >= 0 } {
            set alphaDirection "w"
         } else {
            set alphaDirection "e"
            set alphaDelay [expr -$alphaDelay]
         }

         #--- test anti-turbulence
         if { $alphaDirection != $private(previousAlphaDirection) } {
            set alphaDelay 0
         }
         if { $alphaDelay < $seuilAlpha } {
            set alphaDelay 0
         }
         set private(previousAlphaDirection) $alphaDirection

         #--- je calcule la direction delta
         if { $deltaDelay >= 0 } {
            set deltaDirection "n"
         } else {
            set deltaDirection "s"
            set deltaDelay [expr -$deltaDelay]
         }
         #--- test anti-turbulence
         if { $deltaDirection != $private(previousDeltaDirection) } {
           set deltaDelay 0
         }
         if { $deltaDelay < $seuilDelta } {
           set deltaDelay 0
         }
         set private(previousDeltaDirection) $deltaDirection
         set private($visuNo,delay,alpha) "$alphaDelay $alphaDirection"
         set private($visuNo,delay,delta) "$deltaDelay $deltaDirection"

         #--- je refraichis l'affichage des nouvelles valeurs
         #--- avant le deplacement du telescope
         update
         #--- je deplace le telescope
         if { $alphaDelay != 0 } {
            ::tlscp::center::moveTelescope $visuNo $alphaDirection $alphaDelay
         }
         if { $deltaDelay != 0 } {
            ::tlscp::center::moveTelescope $visuNo $deltaDirection $deltaDelay
         }
      } else {
         set private($visuNo,delay,alpha) "0"
         set private($visuNo,delay,delta) "0"
         update
      }

      if { $private($visuNo,mode)  == "center" } {
         #--- j'ajoute les nouvelles valeurs dans la liste
         lappend private($visuNo,deltaList) [list $private($visuNo,dx) $private($visuNo,dy)]
         #--- je supprime le premier element
         set private($visuNo,deltaList) [lrange $private($visuNo,deltaList) 1 end ]
         #--- je vérifie si la moyenne est inferieur au seuil
         set xmean "0"
         set ymean "0"
         foreach delta  $private($visuNo,deltaList) {
            set xmean [expr $xmean + abs( [lindex $delta 0 ] ) ]
            set ymean [expr $ymean + abs( [lindex $delta 1 ] ) ]
         }
         set xmean [expr $xmean / [llength $private($visuNo,deltaList)]]
         set ymean [expr $ymean / [llength $private($visuNo,deltaList)]]
         if { $xmean < $::conf(tlscp,seuilx)  && $ymean < $::conf(tlscp,seuily) } {
            set private($visuNo,centerResult) $private($visuNo,targetCoord)
         }
#console::disp "xmean=$xmean ymean=$ymean  sx=$::conf(tlscp,seuilx) sy=$::conf(tlscp,seuily)\n"
      }
   } catchMessage ]

   if { $catchError == 1 } {
      #--- j'arrete les acqusitions
      stopAcquisition $visuNo
      #--- j'affiche un message d'erreur
      console::affiche_erreur "::tlscp::center::processAcquisition $::errorInfo \n"
      tk_messageBox -message "$catchMessage. See console." -title [::tlscp::getPluginTitle] -icon error
      return 1
   }

#console::disp "acquisitionState=$private($visuNo,acquisitionState) mode=$private($visuNo,mode) center=$private($visuNo,centerResult) continuous=$::conf(tlscp,continuousAcquisition)\n "

   if { $private($visuNo,acquisitionState) == "1"
      && ! ($private($visuNo,mode) == "center" && $private($visuNo,centerResult) != "" )
      && $::conf(tlscp,continuousAcquisition) == "1"  } {
      #--- c'est reparti pour un tour ...
      return 0
   } else {
      #--- la fin des acquistions a ete demandee
      stopAcquisition $visuNo
      return 1
   }
}

#------------------------------------------------------------
# createTarget
#    cree et affiche la cible au coocrdonnees (1,1)(2,2) du canvas
#
# parametres :
#    visuNo      : numero de la visu courante
#------------------------------------------------------------
proc ::tlscp::center::createTarget { visuNo } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteTarget $visuNo

   #--- j'affiche la cible
   $private($visuNo,hCanvas) create rect 1 1 2 2 -outline red -offset center -tag target
}

#------------------------------------------------------------
# moveTarget
#    deplace l'affichage de la cible
#
# parametres :
#    visuNo      : numero de la visu courante
#    targetCoord : coordonnees de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::tlscp::center::moveTarget { visuNo targetCoord } {
   variable private

   if { $private($visuNo,targetCoord) == "" } {
     return
   }

   #--- je cree la cible si elle n'existe pas
   if { [$private($visuNo,hCanvas) gettags target] == "" } {
      createTarget $visuNo
   }

   #--- je calcule les coordonnees dans le buffer
   set x  [lindex $targetCoord 0]
   set y  [lindex $targetCoord 1]
   set x1 [expr int($x) - $::conf(tlscp,targetBoxSize)]
   set x2 [expr int($x) + $::conf(tlscp,targetBoxSize)]
   set y1 [expr int($y) - $::conf(tlscp,targetBoxSize)]
   set y2 [expr int($y) + $::conf(tlscp,targetBoxSize)]

   #--- je calcule les coordonnees dans le canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set x1 [lindex $coord 0]
   set y1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set x2 [lindex $coord 0]
   set y2 [lindex $coord 1]

   #--- je place la cible
   $private($visuNo,hCanvas) coords "target" [list $x1 $y1 $x2 $y2]
}

#------------------------------------------------------------
# deleteTarget
#    supprime l'affichage de la cible
#
# parametres :
#    visuNo : numero de la visu courante
#------------------------------------------------------------
proc ::tlscp::center::deleteTarget { visuNo } {
   variable private

   #--- je supprime l'ffichage de la cible
   $private($visuNo,hCanvas) delete "target"
   $private($visuNo,hCanvas) dtag "target"
}

#----------------------------------a--------------------------
# setTargetCoord
#    initialise les coordonnees de la cible dans private(visuNo,targetCoord)
#
# parametres :
#    visuNo : numero de la visu courante
#    x,y    : coordonnees de l'origine des axes (referentiel ecran)
#------------------------------------------------------------
proc ::tlscp::center::setTargetCoord { visuNo x y } {
   variable private

   #--- petits raccourcis pour se simplier le codage
   set zoom [visu$visuNo zoom]
   set bufNo [visu$visuNo buf]

   #---
   if { [buf$bufNo imageready] == 0 } {
      return
   }

   #--- je calcule les coordonnees de la zone de recherche de l'etoile
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]

   #--- je recherche la nouvelle position de l'etoile dans la zone cible
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set x1 [expr $x - $::conf(tlscp,targetBoxSize)]
   set x2 [expr $x + $::conf(tlscp,targetBoxSize)]
   set y1 [expr $y - $::conf(tlscp,targetBoxSize)]
   set y2 [expr $y + $::conf(tlscp,targetBoxSize)]
   set centro [buf$bufNo centro [list $x1 $y1 $x2 $y2] ]
   set private($visuNo,targetCoord) $centro

   #--- je dessine la cible aux nouvelle coordonnee sur la nouvelle origine
   if { $::conf(tlscp,showTarget) == "1" } {
      moveTarget $visuNo $private($visuNo,targetCoord)
   }
}

#------------------------------------------------------------
# createAlphaDeltaAxis
#    dessine les axes alpha et delta centres sur l'origine
#
# parametres :
#    visuNo : numero de la visu courante
#------------------------------------------------------------
proc ::tlscp::center::createAlphaDeltaAxis { visuNo originCoord angle } {
   variable private
   #--- je supprime les axes s'ils existent deja
   deleteAlphaDeltaAxis $visuNo
   #--- je dessine l'axe alpha
   drawAxis $visuNo $originCoord $angle "Est" "West"
   #--- je dessine l'axe delta
   drawAxis $visuNo $originCoord [expr $angle+90] "South" "North"

      #--- je calcule les coordonnees dans le buffer
   set x  [lindex $originCoord 0]
   set y  [lindex $originCoord 1]
   set x1 [expr int($x) - $::conf(tlscp,searchBoxSize)]
   set x2 [expr int($x) + $::conf(tlscp,searchBoxSize)]
   set y1 [expr int($y) - $::conf(tlscp,searchBoxSize)]
   set y2 [expr int($y) + $::conf(tlscp,searchBoxSize)]

   #--- je calcule les coordonnees dans le canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set x1 [lindex $coord 0]
   set y1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set x2 [lindex $coord 0]
   set y2 [lindex $coord 1]

   #--- je dessine la zone de recherche
   $private($visuNo,hCanvas) create rect [list $x1 $y1 $x2 $y2] -outline blue -offset center -tag axis
}

#------------------------------------------------------------
# deleteAlphaDeltaAxis
#    arrete l'affichage des axes alpha et delta
#
# parametres :
#    visuNo : numero de la visu courante
#------------------------------------------------------------
proc ::tlscp::center::deleteAlphaDeltaAxis { visuNo } {
   variable private

   #--- je supprime les axes qui existent deja
   $private($visuNo,hCanvas) delete axis
}

#------------------------------------------------------------
# drawAxis
#    trace un axe avec un libelle a chaque extremite
#
# parametres :
#    visuNo : numero de la visu courante
#    coord  : coordonnees de l'origine des axes (referentiel buffer)
#    angle  : angle d'inclinaison des axes (en degres)
#    label1 : libelle de l'extremite negative de l'axe
#    label2 : libelle de l'extremite positive de l'axe
#------------------------------------------------------------
proc ::tlscp::center::drawAxis { visuNo coord angle label1 label2} {
   variable private
   global audace

   set bufNo [::confVisu::getBufNo $visuNo ]

   if { [buf$bufNo imageready] == 0 } {
      return
   }

   set margin 8
   set windowCoords [::confVisu::getWindow $visuNo]
   set xmin [expr [lindex $windowCoords 0] + $margin]
   set ymin [expr [lindex $windowCoords 1] + $margin]
   set xmax [expr [lindex $windowCoords 2] - $margin]
   set ymax [expr [lindex $windowCoords 3] - $margin]

   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set a  [expr tan($angle*3.14159265359/180)]
   set b  [expr $y - $a * $x]

   #--- je calcule les coordonnees des extremites de l'axe
   if { $a > 1000000 || $a < -1000000 } {
      #--- l'axe est vertical
      if { [expr sin($angle*3.14159265359/180)] >= 0 } {
         set y1 $ymin
         set y2 $ymax
      } else {
         set y1 $ymax
         set y2 $ymin
      }
      set x1 $x
      set x2 $x
   } elseif { $a > 0.00000001 || $a < -0.00000001 } {
      #--- l'axe n'est ni vertical ni horizontal
      if { [expr sin($angle*3.14159265359/180)] >= 0 } {
         set y1 $ymin
         set y2 $ymax
      } else {
         set y1 $ymax
         set y2 $ymin
      }
      set x1 [expr ($y1 - $b) / $a ]
      if { $x1 < $xmin } {
         set x1 $xmin
         set y1 [expr $a * $x1 + $b]
      } elseif { $x1 > $xmax } {
         set x1 $xmax
         set y1 [expr $a * $x1 + $b]
      }
      set x2 [expr ($y2 - $b) / $a ]
      if { $x2 < $xmin } {
         set x2 $xmin
         set y2 [expr $a * $x2 + $b]
      } elseif { $x2 > $xmax } {
         set x2 $xmax
         set y2 [expr $a * $x2 + $b]
      }
   } else {
      #--- l'axe est horizontal
      if { [expr cos($angle*3.14159265359/180)] >= 0 } {
         set x1 $xmin
         set x2 $xmax
      } else {
         set x1 $xmax
         set x2 $xmin
      }
      set y1 $y
      set y2 $y
   }

   #--- je transforme les coordonnees dans le repere canvas
   set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1]]
   set coord2 [::confVisu::picture2Canvas $visuNo [list $x2 $y2]]
   #--- je trace l'axe et les libelles des extremites
   $private($visuNo,hCanvas) create line [lindex $coord1 0] [lindex $coord1 1] [lindex $coord2 0] [lindex $coord2 1] -fill $::audace(color,drag_rectangle) -tag axis -state normal
   $private($visuNo,hCanvas) create text [lindex $coord1 0] [lindex $coord1 1] -text $label1 -tag axis  -state normal -fill $::audace(color,drag_rectangle)
   $private($visuNo,hCanvas) create text [lindex $coord2 0] [lindex $coord2 1] -text $label2 -tag axis  -state normal -fill $::audace(color,drag_rectangle)
}

#------------------------------------------------------------
# showAxis
#    affiche/cache les axes alpha et delta centres sur l'origine
#    si showAxis==0 , efface l'image
#    si showAxis==1 , ne fait rien , l'image sera affiche apres la prochaine acquisition
#------------------------------------------------------------
proc ::tlscp::center::changeShowAxis { visuNo } {
   variable private

   if { $::conf(tlscp,showAxis) == "0" } {
      #--- delete axis
      deleteAlphaDeltaAxis $visuNo
   } else {
      #--- create axis
      if { $::conf(tlscp,originCoord) != "" } {
         createAlphaDeltaAxis $visuNo $::conf(tlscp,originCoord) $::conf(tlscp,angle)
      }
   }
}

#------------------------------------------------------------
# setOrigin
#    initialise le point origine dans conf(tlscp,originCoord)
#
# parametres :
#    visuNo : numero de la visu courante
#    x,y    : coordonnees de l'origine des axes (referentiel ecran)
#------------------------------------------------------------
proc ::tlscp::center::setOrigin { visuNo x y } {
   variable private

   #--- je convertis en coordonnes du referentiel buffer
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]

   set ::conf(tlscp,originCoord) $coord

   #--- je dessine les axes sur la nouvelle origine
   changeShowAxis $visuNo
}

#------------------------------------------------------------
# moveTelescope
#    Deplace le telescope pendant un duree determinee
#    Le deplacement est interrompu si private($visuNo,acquisitionState)!=0
#
# parametres :
#    visuNo    : numero de la visu courante
#    direction : e w n s
#    delay     : duree du deplacement en milliseconde (nombre entier)
# return
#    rien
#------------------------------------------------------------
proc ::tlscp::center::moveTelescope { visuNo direction delay} {
   variable private

   #--- laisse la main pour traiter une eventuelle demande d'arret
   ##update

   #--- je demarre le deplacement
   ##::telescope::move $direction
   tel$::audace(telNo) radec move $direction $::audace(telescope,rate)

   #--- j'attend l'expiration du delai par tranche de 1 seconde
   while { $delay > 0 } {
      if { $private($visuNo,acquisitionState) == 1 } {
         if { $delay > 1000 } {
            after 999
            set delay [expr $delay - 1000 ]
         } else {
            after $delay
            set delay 0
         }
      } else {
         #--- j'interromp l'attente s'il y a une demande d'arret
         set delay 0
      }
   }

   #--- j'arrete le deplacement
   ##::telescope::stop $direction
   tel$::audace(telNo) radec stop $direction
}

#------------------------------------------------------------
# searchStar
#    recherche les coordonnees des etoiles
#
# parametres :
#    visuNo : numero de la visu courante
# return
#    rien
#------------------------------------------------------------
proc ::tlscp::center::searchStar { visuNo searchBox } {
   variable private

   set bufNo [::confVisu::getBufNo $visuNo ]

   #--- A_starlist - returns number of stars on image and save stars-list to file
   #
   #Parameters:
   #
   #threshin - pixels above threshin are taken by gauss filter,
   #   suggested  threshin = (total average on the image) + 3*(total standard deviation of the image)
   #filename - where save the star list - ?optional?
   #after_gauss - ?optional?, copy to buffer image after gauss filter, y or n - default n
   #fwhm - ?optional?, default 3.0, best betwen 2.0 and 4.0
   #radius - ?optional?, default 4, "radius" of gauss matrix  - size is (2*radius+1) x (2*radius+1)
   #border - ?optional?, default 20, should be set to more or equal to radius
   #threshold - ?optional?, default 40.0, best betwen 30.0 and 50.0, is used after gauss filter
   #           when procerure is looking for stars, pixels below threshold are not taken

   ##console::disp "::tlscp::center::searchStar searchBox=$searchBox\n"

   #--- je cherche les étoiles
   set resultFile "$::audace(rep_audela)/telsearch.txt"
   set searchBorder [expr $::conf(tlscp,searchRadius) + 2]
   if { $searchBox == "" } {
      buf$bufNo A_starlist $::conf(tlscp,searchThreshin) $resultFile n $::conf(tlscp,searchFwmh) $::conf(tlscp,searchRadius) $searchBorder $::conf(tlscp,searchThreshold)
   } else {
      buf$bufNo A_starlist $::conf(tlscp,searchThreshin) $resultFile n $::conf(tlscp,searchFwmh) $::conf(tlscp,searchRadius) $searchBorder $::conf(tlscp,searchThreshold) $searchBox
   }
   # j'ouvre le fichier resultat
   set fresult [open "$resultFile" r]

   set hCanvas [::confVisu::getCanvas $visuNo]

   $hCanvas delete tlscpstar
   set points [list ]
   set selectedCoord ""
   set maxLight  0

   # je traite le fichier de coordonnes
   while {-1 != [gets $fresult line1]} {
      # je decoupe la ligne en une liste de champs
      set line2 [split [regsub -all {[ \t\n]+} $line1 { }]]

      # je copie chaque champ dans une variable distincte
      set numero [lindex $line2 0]

      # je passe outre les lignes qui ne commencent pas par un numero
      if { [ string is integer $numero ] == 0 } {
         continue
      }
      # je passe outre les lignes vides
      if { $numero == ""} {
         continue
      }

      #--- je convertis en coordonnes picture
      if { $searchBox == "" } {
         set x      [expr [lindex $line2 1]]
         set y      [expr [lindex $line2 2]]
      } else {
         set x      [expr [lindex $line2 1] + [lindex $searchBox 0]]
         set y      [expr [lindex $line2 2] + [lindex $searchBox 1]]
      }
      set light    [lindex $line2 4]

      # je calcule le centre de l'etoile
      set x1  [expr $x -10]
      set y1  [expr $y -10]
      set x2  [expr $x +10]
      set y2  [expr $y +10]
      set box [list $x1 $y1 $x2 $y2]
      set resultat [buf$bufNo fitgauss $box ]
      set xintensity [lindex $resultat 0]
      set xposition  [lindex $resultat 1]
      set xfwmh      [lindex $resultat 2]
      set xfond      [lindex $resultat 3]
      set yintensity [lindex $resultat 4]
      set yposition  [lindex $resultat 5]
      set yfwmh      [lindex $resultat 6]
      set yfond      [lindex $resultat 7]
      set resultat [buf$bufNo flux $box ]
      set flux    [lindex $resultat 0]

      # je passe outre les points chaud
      ##if { $xfwmh < 1.1 && $yfwmh <1.1} {
      ##   continue
      ##}

      #-- j'enregistre le resultat dans la liste
      lappend points "$x $y"
      if { $flux > $maxLight } {
         set maxLight $flux
         set selectedCoord [list $xposition $yposition ]
      }

      #--- je dessine des cercles autour des etoiles
      set coord [::confVisu::picture2Canvas $visuNo [list $xposition $yposition ]]
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      $hCanvas create oval [expr $x-5] [expr $y-5] [expr $x+5] [expr $y+5] -fill {} -outline green -width 2 -activewidth 3 -tag tlscpstar
      ##$hCanvas create text [expr $x+12] [expr $y+6] -text "$xintensity $yintensity" -tag tlscpstar  -state normal -fill green

   }

   #--- je cree un deuxième cercle autour de l'étoile la plusluminuese
   if { $selectedCoord != "" } {
      set coord [::confVisu::picture2Canvas $visuNo $selectedCoord]
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]

      $hCanvas create oval [expr $x-8] [expr $y-8] [expr $x+8] [expr $y+8] -fill {} -outline red -width 2 -activewidth 3 -tag tlscpstar
   }
   # je ferme et supprime le fichier de coordonnees
   close $fresult
   file delete -force $resultFile

   return $selectedCoord
}

################################################################################
namespace eval ::tlscp::config {

}
################################################################################

#------------------------------------------------------------
# run
#    affiche la fenetre de configuration de l'outil Telescope
#------------------------------------------------------------
proc ::tlscp::config::run { visuNo } {
   variable private

   #--- j'affiche la fenetre de configuration
   set private($visuNo,This) ".telconfig$visuNo"
   ::confGenerique::run  $visuNo $private($visuNo,This) "::tlscp::config" -modal 0
   wm geometry $private($visuNo,This) $::conf(tlscp,configWindowPosition)
}

#------------------------------------------------------------
# getLabel
#    retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::tlscp::config::getLabel { } {
   global caption

   return "[::tlscp::getPluginTitle] $caption(tlscp,configuration)"
}

#------------------------------------------------------------
# appliquer
#    copie les variables widget() dans le tableau conf()
#------------------------------------------------------------
proc ::tlscp::config::apply { visuNo } {
   variable widget
   global conf

   set pendingUpdateTarget 0
   set pendingUpdateAxis 0

   #--- je verifie s'il faut redessiner la cible si le mode de detection a change
   if { $widget($visuNo,targetBoxSize) != $conf(tlscp,targetBoxSize) } {
      if { $::conf(tlscp,showTarget) } {
         set pendingUpdateTarget 1
      }
   }

   #--- je verifie s'il faut redessiner les axes si l'angle a change
   if {  $widget($visuNo,angle) != $conf(tlscp,angle)
      || $widget($visuNo,showAxis) != $conf(tlscp,showAxis) } {
      set pendingUpdateAxis 1
   }

   set conf(tlscp,seuilx)          $widget($visuNo,seuilx)
   set conf(tlscp,seuily)          $widget($visuNo,seuily)
   set conf(tlscp,alphaSpeed)      $widget($visuNo,alphaSpeed)
   set conf(tlscp,alphaReverse)    $widget($visuNo,alphaReverse)
   set conf(tlscp,deltaSpeed)      $widget($visuNo,deltaSpeed)
   set conf(tlscp,deltaReverse)    $widget($visuNo,deltaReverse)
   set conf(tlscp,angle)           $widget($visuNo,angle)
   set conf(tlscp,showAxis)        $widget($visuNo,showAxis)
   set conf(tlscp,targetBoxSize)   $widget($visuNo,targetBoxSize)
   set conf(tlscp,searchBoxSize)   $widget($visuNo,searchBoxSize)
   set conf(tlscp,showAxis)        $widget($visuNo,showAxis)
   set conf(tlscp,cumulEnabled)    $widget($visuNo,cumulEnabled)
   set conf(tlscp,cumulNb)         $widget($visuNo,cumulNb)
   set conf(tlscp,darkEnabled)     $widget($visuNo,darkEnabled)
   set conf(tlscp,darkFileName)    $widget($visuNo,darkFileName)
   set conf(tlscp,centerSpeed)     $widget($visuNo,centerSpeed)

   set conf(tlscp,searchThreshin)  $widget($visuNo,searchThreshin)
   set conf(tlscp,searchFwmh)      $widget($visuNo,searchFwmh)
   set conf(tlscp,searchRadius)    $widget($visuNo,searchRadius)
   set conf(tlscp,searchThreshold) $widget($visuNo,searchThreshold)

   #--- je redessine la cible si le mode de detection a change
   if { $pendingUpdateTarget } {
      ::tlscp::center::createTarget $visuNo
   }

   #--- je redessine les axes si l'angle a change
   ##if {  $pendingUpdateAxis } {
      ::tlscp::center::changeShowAxis $visuNo
   ##}
   update
}

#------------------------------------------------------------
# closeWindow
#    ferme le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::tlscp::config::closeWindow { visuNo } {
   variable private
   global caption

   set geometry [ wm geometry $private($visuNo,This) ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set ::conf(tlscp,configWindowPosition) "+[ string range $geometry $deb $fin ]"
}

#------------------------------------------------------------
# showHelp
#    affiche l'aide de cet outil
#------------------------------------------------------------
proc ::tlscp::config::showHelp { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::tlscp::getPluginType ] ] \
      [::tlscp::getPluginDirectory] [::tlscp::getPluginHelp]
}

#------------------------------------------------------------
# fillConfigPage
#    fenetre de configuration du panneau
#    return rien
#------------------------------------------------------------
proc ::tlscp::config::fillConfigPage { frm visuNo } {
   variable widget
   variable private
   global caption conf

   set private($visuNo,frm) $frm
   #--- j'initialise les variables des widgets
   set widget($visuNo,seuilx)          $conf(tlscp,seuilx)
   set widget($visuNo,seuily)          $conf(tlscp,seuily)
   set widget($visuNo,alphaSpeed)      $conf(tlscp,alphaSpeed)
   set widget($visuNo,alphaReverse)    $conf(tlscp,alphaReverse)
   set widget($visuNo,deltaSpeed)      $conf(tlscp,deltaSpeed)
   set widget($visuNo,deltaReverse)    $conf(tlscp,deltaReverse)
   set widget($visuNo,angle)           $conf(tlscp,angle)
   set widget($visuNo,targetBoxSize)   $conf(tlscp,targetBoxSize)
   set widget($visuNo,searchBoxSize)   $conf(tlscp,searchBoxSize)
   set widget($visuNo,showAxis)        $conf(tlscp,showAxis)
   set widget($visuNo,cumulEnabled)    $conf(tlscp,cumulEnabled)
   set widget($visuNo,cumulNb)         $conf(tlscp,cumulNb)
   set widget($visuNo,darkEnabled)     $conf(tlscp,darkEnabled)
   set widget($visuNo,darkFileName)    $conf(tlscp,darkFileName)
   set widget($visuNo,centerSpeed)     $conf(tlscp,centerSpeed)

   set widget($visuNo,searchThreshin)  $conf(tlscp,searchThreshin)
   set widget($visuNo,searchFwmh)      $conf(tlscp,searchFwmh)
   set widget($visuNo,searchRadius)    $conf(tlscp,searchRadius)
   set widget($visuNo,searchThreshold) $conf(tlscp,searchThreshold)

   #--- Frame ascension droite
   TitleFrame $frm.alpha -borderwidth 2 -relief ridge -text "$caption(tlscp,AD)"
      LabelEntry $frm.alpha.gainprop -label "$caption(tlscp,vitesse)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,alphaSpeed)
      pack $frm.alpha.gainprop -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.alpha.seuil -label "$caption(tlscp,seuil)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s 0 99} \
         -textvariable ::tlscp::config::widget($visuNo,seuilx)
      pack $frm.alpha.seuil -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.alpha.reverse -text "$caption(tlscp,alphaReverse)" \
         -variable ::tlscp::config::widget($visuNo,alphaReverse)
      pack $frm.alpha.reverse -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0

   #--- Frame declinaison
   TitleFrame $frm.delta -borderwidth 2 -text "$caption(tlscp,declinaison)"
      LabelEntry $frm.delta.gainprop -label "$caption(tlscp,vitesse)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,deltaSpeed)
##         -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s -9999 9999}
      pack $frm.delta.gainprop -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.delta.seuil -label "$caption(tlscp,seuil)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s 0 99} \
         -textvariable ::tlscp::config::widget($visuNo,seuily)
      pack $frm.delta.seuil -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.delta.reverse -text "$caption(tlscp,deltaReverse)" \
         -variable ::tlscp::config::widget($visuNo,deltaReverse)
      pack $frm.delta.reverse -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0

   #--- Frame camera
   TitleFrame $frm.camera -borderwidth 2 -text "$caption(tlscp,camera)"
      LabelEntry $frm.camera.angle -label "$caption(tlscp,angle)" \
         -labeljustify left -labelwidth 14 -width 5 -justify right \
         -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s -360 360} \
         -textvariable ::tlscp::config::widget($visuNo,angle)
      pack $frm.camera.angle -in [$frm.camera getframe] -anchor w -side top -fill x -expand 0

   #--- Frame telescope
   TitleFrame $frm.telescope -borderwidth 2 -text "$caption(tlscp,telescope)"
      label $frm.telescope.speedLabel -text "$caption(tlscp,defaultSpeed)"
      pack $frm.telescope.speedLabel -in [$frm.telescope getframe] -anchor w -side left -fill x -expand 0
      set speedList [::telescope::getSpeedValueList]
      ComboBox $frm.telescope.speedList -relief sunken -borderwidth 1 -editable 0 \
         -height [llength $speedList] \
         -width 3 \
         -textvariable ::tlscp::config::widget($visuNo,centerSpeed) \
         -values $speedList
      pack $frm.telescope.speedList -in [$frm.telescope getframe] -anchor w -side left -fill x -expand 0

   #--- Frame search
   TitleFrame $frm.search -borderwidth 2 -text "$caption(tlscp,searchTitle)"
      LabelEntry $frm.search.searchBoxSize -label $caption(tlscp,searchBoxSize) \
         -labeljustify left -labelwidth 16 -width 4 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,searchBoxSize)
      pack $frm.search.searchBoxSize -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.search.showSearchBox -text "$caption(tlscp,showSearchBox)" \
         -variable ::tlscp::config::widget($visuNo,showAxis)
      pack $frm.search.showSearchBox -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.threshin -label "$caption(tlscp,searchThreshin)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,searchThreshin)
      pack $frm.search.threshin -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.fwhm -label "$caption(tlscp,searchFwmh)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,searchFwmh)
      pack $frm.search.fwhm -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.radius -label "$caption(tlscp,searchRadius)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,searchRadius)
      pack $frm.search.radius -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.threshold -label "$caption(tlscp,searchThreshold)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,searchThreshold)
      pack $frm.search.threshold -in [$frm.search getframe] -anchor w -side top -fill x -expand 0

   grid $frm.alpha -in $frm -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns
   grid $frm.delta -in $frm -row 0 -column 1 -columnspan 1 -rowspan 1 -sticky ewns
   grid $frm.search -in $frm -row 1 -column 0 -columnspan 1 -rowspan 2 -sticky ewns
   grid $frm.camera  -in $frm -row 1 -column 1 -columnspan 1 -sticky ewns
   grid $frm.telescope  -in $frm -row 2 -column 1 -columnspan 1 -sticky ewns
}

