#
# Fichier : tlscp.tcl
# Description : Outil pour le controle des montures
# Compatibilite : Montures LX200, AudeCom, etc.
# Auteurs : Alain KLOTZ, Robert DELMAS et Philippe KAUFFMANN
# Mise a jour $Id: tlscp.tcl,v 1.21 2009-02-07 11:03:38 robertdelmas Exp $
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
      menu         { return "tool" }
      function     { return "aiming" }
      subfunction1 { return "acquisition" }
      display      { return "panel" }
      multivisu    { return 1 }
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
proc ::tlscp::createPluginInstance { { tkBase "" } { visuNo 1 } } {
   variable private
   global audace caption conf

   #--- parametres de la camera
   if { ! [ info exists conf(tlscp,binning)] }                { set conf(tlscp,binning)                "1x1" }
   if { ! [ info exists conf(tlscp,expTime)] }                { set conf(tlscp,expTime)                "1" }
   if { ! [ info exists conf(tlscp,mountEnabled)] }           { set conf(tlscp,mountEnabled)           "1" }

   #--- parametres pour le centrage
   if { ! [ info exists conf(tlscp,alphaSpeed)] }             { set conf(tlscp,alphaSpeed)             "1" }
   if { ! [ info exists conf(tlscp,deltaSpeed)] }             { set conf(tlscp,deltaSpeed)             "1" }
   if { ! [ info exists conf(tlscp,alphaReverse)] }           { set conf(tlscp,alphaReverse)           "0" }
   if { ! [ info exists conf(tlscp,deltaReverse)] }           { set conf(tlscp,deltaReverse)           "0" }
   if { ! [ info exists conf(tlscp,seuilx)] }                 { set conf(tlscp,seuilx)                 "1" }
   if { ! [ info exists conf(tlscp,seuily)] }                 { set conf(tlscp,seuily)                 "1" }
   if { ! [ info exists conf(tlscp,angle)] }                  { set conf(tlscp,angle)                  "0" }
   if { ! [ info exists conf(tlscp,showAxis)] }               { set conf(tlscp,showAxis)               "1" }
   if { ! [ info exists conf(tlscp,showTarget)] }             { set conf(tlscp,showTarget)             "1" }
   if { ! [ info exists conf(tlscp,originCoord)] }            { set conf(tlscp,originCoord)            "" }
   if { ! [ info exists conf(tlscp,targetBoxSize)] }          { set conf(tlscp,targetBoxSize)          "16" }
   if { ! [ info exists conf(tlscp,searchBoxSize)] }          { set conf(tlscp,searchBoxSize)          "64" }
   if { ! [ info exists conf(tlscp,configWindowPosition)] }   { set conf(tlscp,configWindowPosition)   "+0+0" }
   if { ! [ info exists conf(tlscp,cumulEnabled)] }           { set conf(tlscp,cumulEnabled)           "0" }
   if { ! [ info exists conf(tlscp,cumulNb)] }                { set conf(tlscp,cumulNb)                "5" }
   if { ! [ info exists conf(tlscp,darkEnabled)] }            { set conf(tlscp,darkEnabled)            "0" }
   if { ! [ info exists conf(tlscp,darkFileName)] }           { set conf(tlscp,darkFileName)           "dark.fit" }
   if { ! [ info exists conf(tlscp,centerSpeed)] }            { set conf(tlscp,centerSpeed)            "2" }
   if { ! [ info exists conf(tlscp,searchThreshin)] }         { set conf(tlscp,searchThreshin)         "10" }
   if { ! [ info exists conf(tlscp,searchFwhm)] }             { set conf(tlscp,searchFwhm)             "3" }
   if { ! [ info exists conf(tlscp,searchRadius)] }           { set conf(tlscp,searchRadius)           "4" }
   if { ! [ info exists conf(tlscp,searchThreshold)] }        { set conf(tlscp,searchThreshold)        "40" }

   if { ! [ info exists conf(tlscp,foclen)] }                 { set conf(tlscp,foclen)                 "1" }
   if { ! [ info exists conf(tlscp,methode)] }                { set conf(tlscp,methode)                "BRIGHTEST" }
   if { ! [ info exists conf(tlscp,detection)] }              { set conf(tlscp,detection)              "STAT" }
   if { ! [ info exists conf(tlscp,catalogue)] }              { set conf(tlscp,catalogue)              "MICROCAT" }
   if { ! [ info exists conf(tlscp,kappa)] }                  { set conf(tlscp,kappa)                  "3" }
   if { ! [ info exists conf(tlscp,threshin)] }               { set conf(tlscp,threshin)               "6" }
   if { ! [ info exists conf(tlscp,fwhm)] }                   { set conf(tlscp,fwhm)                   "6" }
   if { ! [ info exists conf(tlscp,radius)] }                 { set conf(tlscp,radius)                 "10" }
   if { ! [ info exists conf(tlscp,threshold)] }              { set conf(tlscp,threshold)              "6" }
   if { ! [ info exists conf(tlscp,maxMagnitude)] }           { set conf(tlscp,maxMagnitude)           "10" }
   if { ! [ info exists conf(tlscp,delta)] }                  { set conf(tlscp,delta)                  "4" }
   if { ! [ info exists conf(tlscp,epsilon)] }                { set conf(tlscp,epsilon)                "0.002" }
   if { ! [ info exists conf(tlscp,notebook)] }               { set conf(tlscp,notebook)               "mount" }

   if { ! [ info exists conf(tlscp,catalogueName)] }          { set conf(tlscp,catalogueName)          "MicroCat" }
   if { ! [ info exists conf(tlscp,cataloguePath,MicroCat)] } { set conf(tlscp,cataloguePath,MicroCat) ""  }
   if { ! [ info exists conf(tlscp,cataloguePath,USNO)] }     { set conf(tlscp,cataloguePath,USNO)     ""  }

   #--- Initialisation des variables
   set private($visuNo,This)              "$tkBase.tlscp"
   set private($visuNo,choix_bin)         "1x1 2x2 4x4"
   set private($visuNo,menu)              "$caption(tlscp,coord)"
   set private($visuNo,camItem)           ""
   set private($visuNo,updateAxis)        ""
   set private($visuNo,targetCoord)       ""
   set private($visuNo,hCanvas)           [::confVisu::getCanvas $visuNo]
   set private($visuNo,dx)                [format "%##0.1f" "0"]
   set private($visuNo,dy)                [format "%##0.1f" "0"]
   set private($visuNo,acquisitionState)  ""
   set private($visuNo,mode)              "acq"
   set private($visuNo,acquisitionResult) ""
   set private($visuNo,acquisitionResult) ""
   set private($visuNo,pose_en_cours)     "0"

   #--- Coordonnees J2000.0 de M104
   setRaDec $visuNo [list "12h40m0s" "-11d37m22"]  "M104" "J2000.0" ""

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
         ::cataGoto::createFrameCatalogue $private($visuNo,This).fra2.catalogue [list $private($visuNo,raObjet) $private($visuNo,decObjet)] $visuNo "::tlscp"
         pack $private($visuNo,This).fra2.catalogue -in $private($visuNo,This).fra2 -anchor nw -side top -padx 4 -pady 1

         #--- Entry de l'objet choisi
         entry $private($visuNo,This).fra2.lab1 -textvariable ::tlscp::private($visuNo,nomObjet) -relief groove
         pack $private($visuNo,This).fra2.lab1 -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 1

         #--- Entry pour les coordonnes de l'objet
         entry $private($visuNo,This).fra2.ra -textvariable ::tlscp::private($visuNo,raObjet) \
            -relief groove -width 16
         pack $private($visuNo,This).fra2.ra -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 2
         DynamicHelp::add $private($visuNo,This).fra2.ra -text "$caption(tlscp,formataddec1)"
         entry $private($visuNo,This).fra2.dec -textvariable ::tlscp::private($visuNo,decObjet) \
            -relief groove -width 16
         pack $private($visuNo,This).fra2.dec -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 2
         DynamicHelp::add $private($visuNo,This).fra2.dec -text "$caption(tlscp,formataddec2)"

         #--- LabelEntry pour l'equinoxe des coordonnees
         LabelEntry $private($visuNo,This).fra2.equinox -label "$caption(tlscp,equinoxe)" \
            -labeljustify left -labelwidth 10 -width 5 -justify center -editable 0 \
            -textvariable ::tlscp::private($visuNo,equinoxObjet)
         pack $private($visuNo,This).fra2.equinox -anchor w -side top -fill x -expand 0

         frame $private($visuNo,This).fra2.fra1a

            #--- Checkbutton chemin le plus long
            checkbutton $private($visuNo,This).fra2.fra1a.check1 -highlightthickness 0 \
               -variable conf(audecom,gotopluslong) -command "::tlscp::PlusLong $visuNo"
            pack $private($visuNo,This).fra2.fra1a.check1 -in $private($visuNo,This).fra2.fra1a -side left \
               -fill both -anchor center -pady 1

            #--- Bouton MATCH
            button $private($visuNo,This).fra2.fra1a.match -borderwidth 1 -text $caption(tlscp,match) \
               -command "::tlscp::cmdMatch $visuNo"
            pack $private($visuNo,This).fra2.fra1a.match -in $private($visuNo,This).fra2.fra1a -side right -expand 1 \
               -fill both -anchor center -pady 1
            #--- Bouton CARTE
            button $private($visuNo,This).fra2.fra1a.chart -borderwidth 1 -text $caption(tlscp,chart) \
               -command "::tlscp::cmdSkyMap $visuNo"
            pack $private($visuNo,This).fra2.fra1a.chart -in $private($visuNo,This).fra2.fra1a -side right -expand 1 \
               -fill both -anchor center -pady 1

         pack $private($visuNo,This).fra2.fra1a -in $private($visuNo,This).fra2 -expand 1 -fill both

         frame $private($visuNo,This).fra2.fra2a

            #--- Bouton Coord. / Stop GOTO
            button $private($visuNo,This).fra2.fra2a.but2 -borderwidth 2 -text $caption(tlscp,coord) \
               -command { ::telescope::afficheCoord }
            pack $private($visuNo,This).fra2.fra2a.but2 -in $private($visuNo,This).fra2.fra2a -side left \
               -fill both -anchor center -pady 1

            #--- Bouton GOTO
            button $private($visuNo,This).fra2.fra2a.but1 -borderwidth 2 -text $caption(tlscp,goto) \
               -command "::tlscp::cmdGoto $visuNo"
            pack $private($visuNo,This).fra2.fra2a.but1 -in $private($visuNo,This).fra2.fra2a -side right -expand 1 \
               -fill both -anchor center -pady 1

            #--- Bouton Stop GOTO
            button $private($visuNo,This).fra2.fra2a.but3 -borderwidth 2 -text $caption(tlscp,stop_goto) \
               -command { ::telescope::stopGoto }
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
         label $private($visuNo,This).fra3.ent1 -textvariable audace(telescope,getra) -relief flat
         pack $private($visuNo,This).fra3.ent1 -in $private($visuNo,This).fra3 -anchor center -fill none -pady 1

         #--- Label pour DEC
         label $private($visuNo,This).fra3.ent2 -textvariable audace(telescope,getdec) -relief flat
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
         button $private($visuNo,This).fra4.n.canv1PoliceInvariant -borderwidth 2 \
            -text "$caption(tlscp,nord)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.n.canv1PoliceInvariant -in $private($visuNo,This).fra4.n -expand 0 \
            -side top -padx 2 -pady 0

         #--- Create the buttons 'E W'
         frame $private($visuNo,This).fra4.we -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.we -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design 'E'
         button $private($visuNo,This).fra4.we.canv1PoliceInvariant -borderwidth 2 \
            -text "$caption(tlscp,est)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.we.canv1PoliceInvariant \
            -in $private($visuNo,This).fra4.we -expand 1 -side left -padx 0 -pady 0

         #--- Write the label of speed
         label $private($visuNo,This).fra4.we.labPoliceInvariant \
            -textvariable audace(telescope,labelspeed) \
            -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.we.labPoliceInvariant \
            -in $private($visuNo,This).fra4.we -expand 1 -side left

         #--- Button-design 'W'
         button $private($visuNo,This).fra4.we.canv2PoliceInvariant -borderwidth 2 \
            -text "$caption(tlscp,ouest)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.we.canv2PoliceInvariant \
            -in $private($visuNo,This).fra4.we -expand 1 -side right -padx 0 -pady 0

         #--- Create the button 'S'
         frame $private($visuNo,This).fra4.s -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.s -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design
         button $private($visuNo,This).fra4.s.canv1PoliceInvariant -borderwidth 2 \
            -text "$caption(tlscp,sud)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.s.canv1PoliceInvariant \
            -in $private($visuNo,This).fra4.s -expand 0 -side top -padx 2 -pady 0

         set zone(n) $private($visuNo,This).fra4.n.canv1PoliceInvariant
         set zone(e) $private($visuNo,This).fra4.we.canv1PoliceInvariant
         set zone(w) $private($visuNo,This).fra4.we.canv2PoliceInvariant
         set zone(s) $private($visuNo,This).fra4.s.canv1PoliceInvariant

         #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
         label $private($visuNo,This).fra4.s.lab1 -textvariable audace(telescope,controle) \
            -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.s.lab1 -in $private($visuNo,This).fra4.s -expand 1 -side left

      pack $private($visuNo,This).fra4 -side top -fill x

      bind $private($visuNo,This).fra4.we.labPoliceInvariant <ButtonPress-1> { ::tlscp::cmdSpeed }
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
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
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

         #--- Label pour binning
         frame $private($visuNo,This).camera.binning -borderwidth 0 -relief groove

            label $private($visuNo,This).camera.binning.label -text "$caption(tlscp,binning)"
            pack $private($visuNo,This).camera.binning.label -anchor center -side left -fill x -expand 1
            set list_combobox [list "" ]
            ComboBox $private($visuNo,This).camera.binning.combo \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken -borderwidth 1 -editable 0 \
               -textvariable ::conf(tlscp,binning)) \
               -values $list_combobox \
               -modifycmd "::tlscp::setBinning $visuNo"

            pack $private($visuNo,This).camera.binning.combo -anchor center -side left -fill x -expand 1

         #--- Bouton GO
         button $private($visuNo,This).camera.goccd -borderwidth 2 -text $caption(tlscp,goccd) \
            -command "::tlscp::startAcquisition $visuNo"

         #--- Bouton center
         button $private($visuNo,This).camera.center -borderwidth 2 -text "$caption(tlscp,centrer)" \
            -command " ::tlscp::startCenter $visuNo"

         #--- Bouton search
         button $private($visuNo,This).camera.search -borderwidth 2 -text "$caption(tlscp,rechercher)" \
            -command " ::tlscp::startSearchStar $visuNo"

         #--- Bouton clear
         button $private($visuNo,This).camera.clear -borderwidth 2 -text "$caption(tlscp,nettoyer)" \
            -command " ::tlscp::clearSearchStar $visuNo"

         #--- checkbutton monture active
        ### checkbutton $private($visuNo,This).camera.mountEnabled -text "$caption(tlscp,mountEnabled)" \
        ###    -variable ::conf(tlscp,mountEnabled)

         grid $private($visuNo,This).camera.pose  -row 0  -sticky nsew -pady 1
         grid $private($visuNo,This).camera.binning -row 1 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.goccd  -row 2 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.center -row 3 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.search -row 4 -sticky nsew -pady 1
         grid $private($visuNo,This).camera.clear  -row 5 -sticky nsew -pady 1
        ### grid $private($visuNo,This).camera.mountEnabled -row 7 -sticky nsew -pady 1
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

   #--- Configuration de la camera
   set This $private($visuNo,This)
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set private($visuNo,camItem) [ ::confVisu::getCamItem $visuNo ]

   if { $camItem == "" } {
      $private($visuNo,This).camera.goccd  configure -state disabled
      $private($visuNo,This).camera.center configure -state disabled
      $private($visuNo,This).camera.search configure -state disabled
      $private($visuNo,This).camera.clear  configure -state disabled
   } else {
      $private($visuNo,This).camera.goccd  configure -state normal
      $private($visuNo,This).camera.center configure -state normal
      $private($visuNo,This).camera.search configure -state normal
      $private($visuNo,This).camera.clear  configure -state normal
   }

   if { [::confCam::getPluginProperty $camItem hasBinning] == "0" } {
     $This.camera.binning.label configure -state disabled
     set list_binning ""
     $This.camera.binning.combo configure -values $list_binning -height [ llength $list_binning]
     $This.camera.binning.combo configure -state disabled
   } else {
     $This.camera.binning.label configure -state normal
     #--- j'initialise avec la liste des binnings propre a la camera
     set list_binning [::confCam::getPluginProperty $camItem binningList]
     $This.camera.binning.combo configure -values $list_binning -height [ llength $list_binning]
     $This.camera.binning.combo configure -state normal
   }

   #--- j'adapte les boutons de selection de pose
   if { $camItem != "" } {
      $private($visuNo,This).camera.pose.label configure -state normal
      $private($visuNo,This).camera.pose.combo configure -state normal
      $private($visuNo,This).camera.pose.webcam configure -state normal

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
   } else {
      $private($visuNo,This).camera.pose.label configure -state disabled
      $private($visuNo,This).camera.pose.combo configure -state disabled
      $private($visuNo,This).camera.pose.webcam configure -state disabled
   }

   #--- j'intialise les coordonnees de axes
   if { $camItem != "" } {
      set bufNo [::confVisu::getBufNo $visuNo]
      if { [buf$bufNo imageready] == 0 } {
         #--- je cree une image de la taille de l'image de la camera
         set windowCam [cam[::confCam::getCamNo $private($visuNo,camItem)] window]
         buf$bufNo setpixels "CLASS_GRAY" [expr [lindex $windowCam 2] - [lindex $windowCam 0] +1] [expr [lindex $windowCam 3] - [lindex $windowCam 1] +1] "FORMAT_FLOAT" "COMPRESS_NONE" 0
         ::confVisu::autovisu $visuNo
      }

      if { $::conf(tlscp,originCoord) == "" } {
         set ::conf(tlscp,originCoord) [list [expr [buf$bufNo getpixelswidth]/2] [expr [buf$bufNo getpixelsheight]/2] ]
      }
      if { $private($visuNo,targetCoord) == "" } {
         set private($visuNo,targetCoord) $::conf(tlscp,originCoord)
      }
      ::tlscp::changeShowAxis $visuNo
      ::tlscp::moveTarget $visuNo $private($visuNo,targetCoord)
   }
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::tlscp::startTool { visuNo } {
   variable private

   #--- j'active les traces et affiche l'outil
   trace add variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   if { [ ::confTel::getPluginProperty hasModel ] == "1" } {
      trace add variable ::conf($::conf(telescope),modele) write "::tlscp::adaptPanel $visuNo"
   }
   pack $private($visuNo,This) -side left -fill y

   #--- j'active la mise a jour automatique de l'affichage quand on change de camera
   ::confVisu::addCameraListener $visuNo "::tlscp::adaptPanel $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
   ::confVisu::addZoomListener $visuNo "::tlscp::onChangeDisplay $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de fenetrage
   ::confVisu::addSubWindowListener $visuNo "::tlscp::onChangeDisplay $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de miroir
   ::confVisu::addMirrorListener $visuNo "::tlscp::onChangeDisplay $visuNo"

   #--- je refraichis l'affichage des coordonnees
   ::telescope::afficheCoord

   #--- je change le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::tlscp::setOrigin $visuNo %x %y"
   #--- je change le bind du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "::tlscp::setTargetCoord $visuNo %x %y"

   #--- j'affiche les axes
   if { $::conf(tlscp,showAxis) == "1" } {
      ::tlscp::changeShowAxis $visuNo
   }
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::tlscp::stopTool { visuNo } {
   variable private

   #--- Je verifie si une operation est en cours
   if { $private($visuNo,pose_en_cours) == 1 } {
      return -1
   }

   #--- je masque les axes
   ::tlscp::deleteAlphaDeltaAxis $visuNo
   #--- j'efface les cercles autour des etoiles
   ::tlscp::clearSearchStar $visuNo
   #--- j'efface la cible
   ::tlscp::deleteTarget $visuNo

   #--- je restaure le bind par defaut du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "default"
   #--- je restaure le bind par defaut du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "default"

   #--- j'active la mise a jour automatique de l'affichage quand on change de camera
   ::confVisu::removeCameraListener $visuNo "::tlscp::adaptPanel $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
   ::confVisu::removeZoomListener $visuNo "::tlscp::onChangeDisplay $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de fenetrage
   ::confVisu::removeSubWindowListener $visuNo "::tlscp::onChangeDisplay $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de miroir
   ::confVisu::removeMirrorListener $visuNo "::tlscp::onChangeDisplay $visuNo"

   #--- je desactive les traces et enleve l'outil de l'affichage
   trace remove variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   if { [ ::confTel::getPluginProperty hasModel ] == "1" } {
      trace remove variable ::conf($::conf(telescope),modele) write "::tlscp::adaptPanel $visuNo"
   }
   pack forget $private($visuNo,This)
}

#------------------------------------------------------------
# cmdMatch
#    aligne la monture avec les coordonnes de l'objet selectionne
#------------------------------------------------------------
proc ::tlscp::cmdMatch { visuNo } {
   variable private

   $private($visuNo,This).fra2.fra1a.match configure -relief groove -state disabled
   update
   ::telescope::match [list $private($visuNo,raObjet) $private($visuNo,decObjet)]
   $private($visuNo,This).fra2.fra1a.match configure -relief raised -state normal
   update
}

#------------------------------------------------------------
# cmdGoto
#    pointe la monture vers les coordonnes de l'objet selectionne
#------------------------------------------------------------
proc ::tlscp::cmdGoto { visuNo } {
   variable private
   global audace caption cataGoto catalogue

   #--- Gestion graphique des boutons GOTO et Stop
   $private($visuNo,This).fra2.fra2a.but1 configure -relief groove -state disabled
   $private($visuNo,This).fra2.fra2a.but2 configure -text $caption(tlscp,stop_goto) \
      -command "::tlscp::cmdStopGoto $visuNo"
   update

   #--- Affichage de champ dans une carte. Parametres : nom_objet, ad, dec, zoom_objet, avant_plan
   if { $cataGoto(carte,validation) == "1" } {
      ::carte::gotoObject $cataGoto(carte,nom_objet) $cataGoto(carte,ad) $cataGoto(carte,dec) $cataGoto(carte,zoom_objet) $cataGoto(carte,avant_plan)
   }

   #--- Cas particulier si le premier pointage est en mode coordonnees
   if { $private($visuNo,menu) == "$caption(tlscp,coord)" } {
      set private($visuNo,list_radec) [list $private($visuNo,raObjet) $private($visuNo,decObjet)]
   }

   #--- Prise en compte des corrections de precession, de nutation et d'aberrations (annuelle et diurne)
   if { $private($visuNo,equinoxObjet) != "now" } {
      #--- Calcul des corrections et affichage dans la Console
      set ad_objet_cata  [ lindex $private($visuNo,list_radec) 0 ]
      set dec_objet_cata [ lindex $private($visuNo,list_radec) 1 ]
      ::console::disp "$caption(tlscp,coord_catalogue) \n"
      ::console::disp "$caption(tlscp,ad) $ad_objet_cata \n"
      ::console::disp "$caption(tlscp,dec) $dec_objet_cata \n"
      set now            [ ::audace::date_sys2ut "now" ]
      set ad_dec_vrai    [ ::telescope::coord_eph_vrai $ad_objet_cata $dec_objet_cata J2000.0 $now ]
      set ad_objet_vrai  [ lindex $ad_dec_vrai 0 ]
      set dec_objet_vrai [ lindex $ad_dec_vrai 1 ]
      ::console::disp "$caption(tlscp,coord_corrigees) \n"
      ::console::disp "$caption(tlscp,ad) $ad_objet_vrai \n"
      ::console::disp "$caption(tlscp,dec) $dec_objet_vrai \n"
      set private($visuNo,list_radec) "$ad_objet_vrai $dec_objet_vrai"
   }

   #--- Goto
   ::telescope::goto $private($visuNo,list_radec) "0" \
      $private($visuNo,This).fra2.fra2a.but1 \
      $private($visuNo,This).fra2.fra1a.match \
      $private($visuNo,nomObjet) \
      $private($visuNo,equinoxObjet)

   #--- Affichage des coordonnees pointees par le telescope dans la Console
   if { $private($visuNo,equinoxObjet) != "now" } {
      ::telescope::afficheCoord
      ::console::disp "$caption(tlscp,coord_pointees) \n"
      ::console::disp "$caption(tlscp,ad) $audace(telescope,getra) \n"
      ::console::disp "$caption(tlscp,dec) $audace(telescope,getdec) \n"
      ::console::disp "\n"
   }

   #--- Gestion graphique du bouton Stop
   $private($visuNo,This).fra2.fra2a.but2 configure -relief raised -state normal -text $caption(tlscp,coord) \
      -command { ::telescope::afficheCoord }
   update
}

#------------------------------------------------------------
#  cmdSkyMap
#     Recupere les coordonnees et le nom de l'objet selectionne dans une carte
#
#  parametres :
#    visuNo : numero de la visu courante
#  retour
#    rien
#------------------------------------------------------------
proc ::tlscp::cmdSkyMap { visuNo } {
   variable private

   set result [::carte::getSelectedObject]
   if { [llength $result] == 5 } {
     ### set now now
     ### set now [::audace::date_sys2ut now]
     ### set result [modpoi_catalogmean2apparent [lindex $result 0] [lindex $result 1] J2000.0 $now]
      set ra        [mc_angle2hms [lindex $result 0] 360 nozero 0 auto string]
      set dec       [mc_angle2dms [lindex $result 1] 90 nozero 0 + string]
      set equinox   [lindex $result 2]
      set name      [lindex $result 3]
      set magnitude ""
      ::tlscp::setRaDec $visuNo [list $ra $dec] $name $equinox $magnitude
   }
}

#------------------------------------------------------------
#  setRaDec
#     memorise les coordonnes et le nom de l'objet cible
#
#  parametres :
#    visuNo    : numero de la visu courante
#    listRaDec : RA et DEC de l'objet
#    nomObjet  : nom de l'objet
#    equinox   : equinoxe de RA et DEC ( exemple : J2000.0 , "now" )
#  retour
#    rien
#------------------------------------------------------------
proc ::tlscp::setRaDec { visuNo listRaDec nomObjet equinox magnitude } {
   variable private

   set private($visuNo,raObjet)      [lindex $listRaDec 0]
   set private($visuNo,decObjet)     [lindex $listRaDec 1]
   set private($visuNo,nomObjet)     $nomObjet
   set private($visuNo,equinoxObjet) $equinox
}

#------------------------------------------------------------
#  PlusLong
#    Goto par le chemin le plus long
#
#  parametres :
#    visuNo : numero de la visu courante
#  retour
#    rien
#------------------------------------------------------------
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
      wm geometry $This +[ expr $posx_pluslong + 150 ]+[ expr $posy_pluslong + 150 ]

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
# setBinning
#    change le binning de la camera
#------------------------------------------------------------
proc ::tlscp::setBinning { visuNo } {
   variable private

   set binning [list [string range $::conf(tlscp,binning) 0 0] [string range $::conf(tlscp,binning) 2 2]]
   set camItem [::confVisu::getCamItem $visuNo]
   set camNo   [::confCam::getCamNo $camItem ]
   cam$camNo bin $binning
}

#------------------------------------------------------------
# startAcquisition
#    fait une acquisition
# parametres
#    visuNo : numero de la visu
# return
#    rien
#------------------------------------------------------------
proc ::tlscp::startAcquisition { visuNo  } {
   variable private
   global caption conf

   if { $private($visuNo,acquisitionState) != "" } {
      return
   }

   #--- j'identifie le debut d'une acquisition
   set private($visuNo,pose_en_cours)     "1"

   #--- je configure le type d'acquisition
   set private($visuNo,acquisitionState) "acquisition"

   #--- j'affiche le bouton STOP CCD
   $private($visuNo,This).camera.goccd configure -text "$::caption(tlscp,stopccd) (ESC)" -command "::tlscp::stopAcquisition $visuNo $private($visuNo,This).camera.goccd "
   #--- J'associe la touche ESCAPE a la commande d'arret
   bind all <Key-Escape> "::tlscp::stopAcquisition $visuNo $private($visuNo,This).camera.goccd "

   #--- je lance l'acquisition
   ::camera::acquisition $private($visuNo,camItem) "::tlscp::callbackAcquisition $visuNo" $::conf(tlscp,expTime)

   #--- j'attend la fin de l'acquisition
   vwait ::tlscp::private($visuNo,acquisitionState)

   #--- Rajoute des mots clefs dans l'en-tete FITS
   set bufNo [ ::confVisu::getBufNo $visuNo ]
   foreach keyword [ ::keyword::getKeywords $visuNo ] {
      buf$bufNo setkwd $keyword
   }

   #--- j'identifie la fin d'une acquisition
   set private($visuNo,pose_en_cours)     "0"

   #--- j'affiche le bouton GO CCD
   $private($visuNo,This).camera.goccd configure -text $::caption(tlscp,goccd) -command "::tlscp::startAcquisition $visuNo" -state normal
   bind all <Key-Escape>
}

#------------------------------------------------------------
# startCenter
#    lance le centrage de l'etoile
#
# parametres
#    visuNo : numero de la visu
#    methode : "BRIGHTEST" ou "ASTROMETRY" ou ""
# return :
#    - les coordonnes (rad,dec) de l'etoile trouvee
#    - ou une chaine vide si une etoile n'est pas trouvee
#------------------------------------------------------------
proc ::tlscp::startCenter { visuNo { methode "" } } {
   variable private

   #--- je verifie qu'il n'y a pas deja une sequence en cours
   if { $private($visuNo,acquisitionState) != "" } {
      return ""
   }

   #--- je verifie que la camera existe
   if { $private($visuNo,camItem) == "" } {
      return ""
   }

   #--- je prends la methode par defaut si la methode n'est pas precisee dans les parametres
   if { $methode == "" } {
      set methode $::conf(tlscp,methode)
   }

   if { $methode == "BRIGHTEST" } {
      #--- je cherche l'etoile la plus brillante
      set brigthestStarCoord [::tlscp::startSearchStar $visuNo]
      if { $brigthestStarCoord == "" } {
         return
      }
   }

   #--- je configure le type d'acquisition
   set private($visuNo,acquisitionState) "center"

   #--- je configure le telescope
   if { $::audace(telNo) != 0 } {
      ::telescope::setSpeed $::conf(tlscp,centerSpeed)
      ::camera::setParam $private($visuNo,camItem) "telRate" $::audace(telescope,rate)
     ### set ::conf(tlscp,mountEnabled) 1
   } else {
     ### set ::conf(tlscp,mountEnabled) 0
   }

   #--- j'affiche le bouton STOP CENTER
   $private($visuNo,This).camera.center configure -text "Stop center (ESC)" -command "::tlscp::stopAcquisition $visuNo $private($visuNo,This).camera.center"
   #--- J'associe la touche ESCAPE a la commande d'arret
   bind all <Key-Escape> "::tlscp::stopAcquisition $visuNo $private($visuNo,This).camera.center"

   #--- j'efface les marques dans la visu
   ::tlscp::clearSearchStar $visuNo

   #--- RAZ du resultat
   set private($visuNo,acquisitionResult) ""

   #--- je recupere les coordonnees J2000 pour le centrage aux coordonnees
   if { $private($visuNo,equinoxObjet) == "J2000.0" || $private($visuNo,equinoxObjet) == "J2000" } {
      set ra  $private($visuNo,raObjet)
      set dec $private($visuNo,decObjet)
      set ra  [string trim [mc_angle2deg $ra ]]
      set dec [string trim [mc_angle2deg $dec ]]
   } else {
      #--- je calcule les coordonnees J2000
      set dateNow   [::audace::date_sys2ut now]
      set listRaDec [::telescope::apparent2catalogmean $private($visuNo,raObjet) $private($visuNo,decObjet) $dateNow J2000.0 ]
      set ra        [lindex $listRaDec 0]
      set dec       [lindex $listRaDec 1]
   }

   if { $methode == "BRIGHTEST" } {
      ::camera::centerBrightestStar $private($visuNo,camItem) "::tlscp::callbackAcquisition $visuNo" $::conf(tlscp,expTime) $::conf(tlscp,originCoord) $private($visuNo,targetCoord) $::conf(tlscp,angle) $::conf(tlscp,targetBoxSize) $::conf(tlscp,mountEnabled) $::conf(tlscp,alphaSpeed) $::conf(tlscp,deltaSpeed) $::conf(tlscp,alphaReverse) $::conf(tlscp,deltaReverse) $::conf(tlscp,seuilx) $::conf(tlscp,seuily)
   } else {
      ::camera::centerRadec $private($visuNo,camItem) "::tlscp::callbackAcquisition $visuNo" \
         $::conf(tlscp,expTime) $::conf(tlscp,originCoord) [list $ra $dec] $::conf(tlscp,angle) \
         $::conf(tlscp,targetBoxSize) $::conf(tlscp,mountEnabled) \
         $::conf(tlscp,alphaSpeed) $::conf(tlscp,deltaSpeed) \
         $::conf(tlscp,alphaReverse) $::conf(tlscp,deltaReverse) \
         $::conf(tlscp,seuilx) $::conf(tlscp,seuily) \
         $::conf(tlscp,foclen) $::conf(tlscp,detection) $::conf(tlscp,catalogue) \
         $::conf(tlscp,kappa)  \
         $::conf(tlscp,searchThreshin) $::conf(tlscp,searchFwhm) $::conf(tlscp,searchRadius) $::conf(tlscp,searchThreshold) \
         $::conf(tlscp,maxMagnitude) $::conf(tlscp,delta) $::conf(tlscp,epsilon) \
         $::conf(tlscp,catalogueName) $::conf(tlscp,cataloguePath,$::conf(tlscp,catalogueName))
   }
   #--- j'attends la fin du centrage
   vwait ::tlscp::private($visuNo,acquisitionState)

   #--- j'ajoute les mots clefs dans l'en-tete FITS
   set bufNo [::confVisu::getBufNo $visuNo]
   foreach keyword [ ::keyword::getKeywords $visuNo ] {
      buf$bufNo setkwd $keyword
   }

   #--- j'affiche marques autour des etoiles
   if { $private($visuNo,acquisitionResult) != "" } {
      #--- j'ajoute les mots cles dans l'image
      set bufNo [::confVisu::getBufNo $visuNo]
      buf$bufNo setkwd [list "RA"  $ra  double "reference coordinate for naxis1" "degree" ]
      buf$bufNo setkwd [list "DEC" $dec double "reference coordinate for naxis2" "degree" ]
      buf$bufNo setkwd [list "OBJNAME" $private($visuNo,nomObjet) string "object name" "" ]
      buf$bufNo setkwd [list "EQUINOX" "J2000.0" string "Coordinates equinox" "" ]

      #--- je cree un cercle rouge autour de l'etoile centree
      set coord [::confVisu::picture2Canvas $visuNo $private($visuNo,acquisitionResult) ]
      set x [lindex $coord 0]
      set y [lindex $coord 1]
      [::confVisu::getCanvas $visuNo] create oval [expr $x-8] [expr $y-8] [expr $x+8] [expr $y+8] -fill {} -outline red -width 2 -activewidth 3 -tag tlscpstar

      ::confVisu::setAvailableScale $visuNo "xy_radec"
   }

   #--- j'affiche le bouton CENTER
   $private($visuNo,This).camera.center configure -text "$::caption(tlscp,centrer)" \
      -command "::tlscp::startCenter $visuNo" -state normal
   #--- je descative la touche ESC
   bind all <Key-Escape>

   return $private($visuNo,acquisitionResult)
}

#------------------------------------------------------------
# startSearchStar
#    cherche une l'etoile la plus brillante dans la zone
# parametres
#    visuNo : numero de visu
# return :
#    - les coordonnes de l'etoile trouvee
#    - une chaine vide si une etoile n'est pas trouvee
#------------------------------------------------------------
proc ::tlscp::startSearchStar { visuNo } {
   variable private

   if { $private($visuNo,acquisitionState) != "" } {
      return
   }

   #--- j'efface les traces precedentes
   clearSearchStar  $visuNo

   #--- je configure le type d'acquisition
   set private($visuNo,acquisitionState)  "search"
   set private($visuNo,acquisitionResult) ""

   #--- j'affiche le bouton STOP SEARCH
   $private($visuNo,This).camera.search configure -text "$::caption(tlscp,stop_rechercher) (ESC)" -command "::tlscp::stopAcquisition $visuNo $private($visuNo,This).camera.search"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::tlscp::stopAcquisition $visuNo $private($visuNo,This).camera.search"

   #--- je lance la recherche
   ::camera::searchBrightestStar $private($visuNo,camItem) "::tlscp::callbackAcquisition $visuNo" $::conf(tlscp,expTime) $::conf(tlscp,originCoord) $::conf(tlscp,searchBoxSize) $::conf(tlscp,searchThreshin) $::conf(tlscp,searchFwhm) $::conf(tlscp,searchRadius) $::conf(tlscp,searchThreshold)

   #--- j'attends la fin de le recherche
   vwait ::tlscp::private($visuNo,acquisitionState)

   #--- j'affiche les etoiles
   if { $private($visuNo,acquisitionResult) != "" } {
      set hCanvas [::confVisu::getCanvas $visuNo]
      #--- je dessine des cercles vert autour des etoiles
      foreach star $private($visuNo,acquisitionResult) {
         set coord [::confVisu::picture2Canvas $visuNo [lrange $star 1 2]]
         set x  [lindex $coord 0]
         set y  [lindex $coord 1]
         $hCanvas create oval [expr $x-5] [expr $y-5] [expr $x+5] [expr $y+5] -fill {} -outline blue -width 2 -activewidth 3 -tag tlscpstar
        ### $hCanvas create text [expr $x+12] [expr $y+6] -text "$xintensity $yintensity" -tag tlscpstar -state normal -fill green
      }

      #--- je cree un cercle rouge autour de l'etoile la plus brillante
      set brigthestStarCoord [lrange [lindex $private($visuNo,acquisitionResult) 0 ] 1 2]
      set private($visuNo,targetCoord) $brigthestStarCoord
      moveTarget $visuNo $brigthestStarCoord
     ### set coord [::confVisu::picture2Canvas $visuNo $brigthestStarCoord ]
     ### set x [lindex $coord 0]
     ### set y [lindex $coord 1]
     ### $hCanvas create oval [expr $x-8] [expr $y-8] [expr $x+8] [expr $y+8] -fill {} -outline red -width 2 -activewidth 3 -tag tlscpstar
   } else {
       set brigthestStarCoord ""
   }

   #--- j'affiche le bouton SEARCH
   $private($visuNo,This).camera.search configure -text "$::caption(tlscp,rechercher)" \
      -command "::tlscp::startSearchStar $visuNo" -state normal
   #--- je descative la touche ESC
   bind all <Key-Escape>

   return $brigthestStarCoord
}

#------------------------------------------------------------
# clearSearchStar
#    efface les cercles autour des etoiles
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
# stopAcquisition
#    arrete les acquisitions
#
# return :
#    rien
#------------------------------------------------------------
proc ::tlscp::stopAcquisition { visuNo { tkButton "" } } {
   variable private

   if { $private($visuNo,acquisitionState) != "" } {
      if { $private($visuNo,camItem)!= "" } {
         #--- je desactive le bouton en attendant que l'aquisition
         #--- soit completmeent terminee ( voir ::tlscp::callbackAcquisition)
         if { $tkButton != ""  } {
            $tkButton configure -state disabled
         }
         #--- je transmet la demande d'arret a la camera
         ::camera::stopAcquisition $private($visuNo,camItem)
      }
   }
}

#------------------------------------------------------------
# callbackAcquisition
#    traite les infomations retounees par l'acquisition
#
# return :
#    rien
#------------------------------------------------------------
proc ::tlscp::callbackAcquisition { visuNo command args } {
   variable private

   switch $command {
      "autovisu" {
         ::confVisu::autovisu $visuNo
      }
      "acquisitionResult" {
         #--- je recupere les coordonnees de l'etoile
         set private($visuNo,acquisitionResult) [lindex $args 0]
         set private($visuNo,acquisitionState) ""
      }
      "targetCoord" {
         set private($visuNo,targetCoord) [lindex $args 0]

         #--- je deplace la cible
         ::tlscp::moveTarget $visuNo $private($visuNo,targetCoord)

         #--- j'affiche la distance entre l'etoile cible et l'otrgine
         set private($visuNo,dx) [format "%##0.1f" [lindex $args 1]]
         set private($visuNo,dy) [format "%##0.1f" [lindex $args 2]]

         #--- j'efface les marques precedentes
         set hCanvas [::confVisu::getCanvas $visuNo]
         $hCanvas delete tlscpstar

         #--- j'affiche les marques des etoiles detectees dans l'image (cercle bleu)
         foreach coords [lindex $args 3] {
            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $visuNo $coords ]
            set xcan  [lindex $coord 0]
            set ycan  [lindex $coord 1]
            #--- je dessine des cercles autour des etoiles
            set radius 7
            $hCanvas create oval [expr $xcan-$radius] [expr $ycan-$radius] [expr $xcan+$radius] [expr $ycan+$radius] -fill {} -outline blue -width 1 -activewidth 3 -tag "tlscpstar $coord"
         }

         #--- j'affiche les marques des etoiles trouvees dans le catalogue (cercle vert)
         foreach coords [lindex $args 4] {
            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $visuNo $coords ]
            set xcan  [lindex $coord 0]
            set ycan  [lindex $coord 1]
            #--- je dessine des cercles autour des etoiles
            set radius 5
            $hCanvas create oval [expr $xcan-$radius] [expr $ycan-$radius] [expr $xcan+$radius] [expr $ycan+$radius] -fill {} -outline green -width 1 -activewidth 3 -tag "tlscpstar $coord"
         }

         #--- j'affiche les marques des etoiles appereillees
         foreach coords [lindex $args 5] {
            set ximapic   [lindex $coords 0]
            set yimapic   [lindex $coords 1]
            set xobspic   [lindex $coords 2]
            set yobspic   [lindex $coords 3]

            set coord [::confVisu::picture2Canvas $visuNo [list $ximapic $yimapic ]]
            set ximacan  [lindex $coord 0]
            set yimacan  [lindex $coord 1]
            set coord [::confVisu::picture2Canvas $visuNo [list $xobspic $yobspic ]]
            set xobscan  [lindex $coord 0]
            set yobscan  [lindex $coord 1]
            #--- je dessine un trait entre les etoiles appareillees
            $hCanvas create line $ximacan $yimacan $xobscan $yobscan -fill red -width 2 -activewidth 3 -tag "tlscpstar $ximapic $yimapic $xobspic $yobspic"
         }

      }
      "error" {
         console::affiche_erreur "callbackAcquisition visu=$visuNo command=$command args=$args\n"
         set private($visuNo,acquisitionState) ""
      }
   }
}

#------------------------------------------------------------
# onChangeDisplay
#    prend en compte les changements de parametres d'affichage
#    (zoom, fentrage, miroir)
# parametres
#    visuNo  : numero de visu
#     args   : valeur fournies par le gestionnaire de listener
# return : null
#------------------------------------------------------------
proc ::tlscp::onChangeDisplay { visuNo args } {
   variable private

   #--- je redessine l'origine
   ::tlscp::changeShowAxis $visuNo
   #--- je redessine la cible
   ::tlscp::moveTarget $visuNo $private($visuNo,targetCoord)

   set hCanvas [::confVisu::getCanvas $visuNo]
   foreach itemId [$hCanvas find withtag "mpastrometrystar"] {
      switch [$hCanvas type $itemId] {
         "oval" {
            set tagValue [$hCanvas itemcget $itemId -tag]
            set xpic [lindex $tagValue 1]
            set ypic [lindex $tagValue 2]
            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $visuNo [list $xpic $ypic ]]
            set xcan  [lindex $coord 0]
            set ycan  [lindex $coord 1]
            #--- je dessine des cercles autour des etoiles
            set oldCoord [$hCanvas coords $itemId]
            set radius [expr ([lindex $oldCoord 2] - [lindex $oldCoord 0])/2]
            $hCanvas coords $itemId [expr $xcan-$radius] [expr $ycan-$radius] [expr $xcan+$radius] [expr $ycan+$radius]
         }
         "line" {
            set tagValue [$hCanvas itemcget $itemId -tag]
            set ximapic [lindex $tagValue 1]
            set yimapic [lindex $tagValue 2]
            set xobspic [lindex $tagValue 3]
            set yobspic [lindex $tagValue 4]
            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $visuNo [list $ximapic $yimapic ]]
            set ximacan  [lindex $coord 0]
            set yimacan  [lindex $coord 1]
            set coord [::confVisu::picture2Canvas $visuNo [list $xobspic $yobspic ]]
            set xobscan  [lindex $coord 0]
            set yobscan  [lindex $coord 1]
            #--- je change les coordonnees de la ligne
            $hCanvas coords $itemId $ximacan $yimacan $xobscan $yobscan
         }
         "text" {
            set tagValue [$hCanvas itemcget $itemId -tag]
            set xpic [lindex $tagValue 1]
            set ypic [lindex $tagValue 2]
            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $visuNo [list $xpic $ypic ]]
            set xcan  [lindex $coord 0]
            set ycan  [lindex $coord 1]
            #--- je dessine des cercles autour des etoiles
            $hCanvas coords $itemId [expr $xcan+12] [expr $ycan+24]
         }
      }
   }

}

#------------------------------------------------------------
# getCenterMethod
#   retourne le methode de centrage (ASTROMETRY ou BRIGHTEST)
#
#------------------------------------------------------------
proc ::tlscp::getCenterMethod { visuNo } {
   return $::conf(tlscp,methode)
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

#------------------------------------------------------------
# createTarget
#    cree et affiche la cible au coocrdonnees (1,1)(2,2) du canvas
#
# parametres :
#    visuNo : numero de la visu courante
#------------------------------------------------------------
proc ::tlscp::createTarget { visuNo } {
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
proc ::tlscp::moveTarget { visuNo targetCoord } {
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
proc ::tlscp::deleteTarget { visuNo } {
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
proc ::tlscp::setTargetCoord { visuNo x y } {
   variable private

   #---
   if { [buf[visu$visuNo buf] imageready] == 0 } {
      return
   }

   #--- je calcule les coordonnees de l'etoile dans l'image
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]
   set private($visuNo,targetCoord) $coord

   #--- je dessine la cible aux nouvelle coordonnee sur la nouvelle origine
   if { $::conf(tlscp,showTarget) == "1" } {
      moveTarget $visuNo $private($visuNo,targetCoord)
   }

   #--- je transmet les coordonnees a l'interperteur de la camera
   ::camera::setParam $private($visuNo,camItem) "targetCoord" $private($visuNo,targetCoord)
}

#------------------------------------------------------------
# createAlphaDeltaAxis
#    dessine les axes alpha et delta centres sur l'origine
#
# parametres :
#    visuNo : numero de la visu courante
#------------------------------------------------------------
proc ::tlscp::createAlphaDeltaAxis { visuNo originCoord angle } {
   variable private

   #--- je supprime les axes s'ils existent deja
   deleteAlphaDeltaAxis $visuNo

   #--- je dessine l'axe alpha
   drawAxis $visuNo $originCoord $angle "$::caption(tlscp,ret_est)" "$::caption(tlscp,ret_ouest)"

   #--- je dessine l'axe delta
   drawAxis $visuNo $originCoord [expr $angle+90] "$::caption(tlscp,ret_sud)" "$::caption(tlscp,ret_nord)"

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
proc ::tlscp::deleteAlphaDeltaAxis { visuNo } {
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
proc ::tlscp::drawAxis { visuNo coord angle label1 label2} {
   variable private
   global audace

   set bufNo [::confVisu::getBufNo $visuNo ]

   if { [buf$bufNo imageready] == 1 } {
      set windowCoords [::confVisu::getWindow $visuNo]
   } else {
      return
   }

   set margin 8
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
   $private($visuNo,hCanvas) create text [lindex $coord1 0] [lindex $coord1 1] -text $label1 -tag axis -state normal -fill $::audace(color,drag_rectangle)
   $private($visuNo,hCanvas) create text [lindex $coord2 0] [lindex $coord2 1] -text $label2 -tag axis -state normal -fill $::audace(color,drag_rectangle)
}

#------------------------------------------------------------
# showAxis
#    affiche/cache les axes alpha et delta centres sur l'origine
#    si showAxis==0 , efface les axes
#    si showAxis==1 , ne fait rien , les axes seront affiches apres la prochaine acquisition
#------------------------------------------------------------
proc ::tlscp::changeShowAxis { visuNo } {
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
proc ::tlscp::setOrigin { visuNo x y } {
   variable private

   #--- je convertis en coordonnes du referentiel buffer
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]
   set ::conf(tlscp,originCoord) $coord
   #--- je dessine les axes sur la nouvelle origine
   changeShowAxis $visuNo
   #---
   ::camera::setParam $private($visuNo,camItem) "originCoord" $::conf(tlscp,originCoord)
}

################################################################################

namespace eval ::tlscp::config {
}

#------------------------------------------------------------
# run
#    affiche la fenetre de configuration de l'outil Telescope
#------------------------------------------------------------
proc ::tlscp::config::run { visuNo } {
   variable private

   #--- j'affiche la fenetre de configuration
   set private($visuNo,This) "[::confVisu::getBase $visuNo].tlscpconfig"
   ::confGenerique::run  $visuNo $private($visuNo,This) "::tlscp::config" -modal 0 -geometry $::conf(tlscp,configWindowPosition) -resizable 1
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

   set conf(tlscp,seuilx)           $widget($visuNo,seuilx)
   set conf(tlscp,seuily)           $widget($visuNo,seuily)
   set conf(tlscp,alphaSpeed)       $widget($visuNo,alphaSpeed)
   set conf(tlscp,alphaReverse)     $widget($visuNo,alphaReverse)
   set conf(tlscp,deltaSpeed)       $widget($visuNo,deltaSpeed)
   set conf(tlscp,deltaReverse)     $widget($visuNo,deltaReverse)
   set conf(tlscp,angle)            $widget($visuNo,angle)
   set conf(tlscp,showAxis)         $widget($visuNo,showAxis)
   set conf(tlscp,targetBoxSize)    $widget($visuNo,targetBoxSize)
   set conf(tlscp,searchBoxSize)    $widget($visuNo,searchBoxSize)
   set conf(tlscp,cumulEnabled)     $widget($visuNo,cumulEnabled)
   set conf(tlscp,cumulNb)          $widget($visuNo,cumulNb)
   set conf(tlscp,darkEnabled)      $widget($visuNo,darkEnabled)
   set conf(tlscp,darkFileName)     $widget($visuNo,darkFileName)
   set conf(tlscp,centerSpeed)      $widget($visuNo,centerSpeed)

   set conf(tlscp,methode)          $widget($visuNo,methode)
   set conf(tlscp,detection)        $widget($visuNo,detection)
   set conf(tlscp,kappa)            $widget($visuNo,kappa)
   set conf(tlscp,maxMagnitude)     $widget($visuNo,maxMagnitude)
   set conf(tlscp,delta)            $widget($visuNo,delta)
   set conf(tlscp,epsilon)          $widget($visuNo,epsilon)
   set conf(tlscp,foclen)           $widget($visuNo,foclen)

   set conf(tlscp,searchThreshin)   $widget($visuNo,searchThreshin)
   set conf(tlscp,searchFwhm)       $widget($visuNo,searchFwhm)
   set conf(tlscp,searchRadius)     $widget($visuNo,searchRadius)
   set conf(tlscp,searchThreshold)  $widget($visuNo,searchThreshold)

   set conf(tlscp,catalogueName)    $widget($visuNo,catalogueName)
   if { [string index $widget($visuNo,cataloguePath) end] != "/" } {
      #--- j'ajoute un slash a la fin du repertoire (exige par le traitement d'astrometrie)
      append widget($visuNo,cataloguePath) "/"
   }
   set conf(tlscp,cataloguePath,$conf(tlscp,catalogueName)) $widget($visuNo,cataloguePath)

   #--- je tranmets les changement a l'interperteur de la camera
   ::camera::setParam $::tlscp::private($visuNo,camItem) "telRate" $::audace(telescope,rate)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "detection" $conf(tlscp,detection)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "targetBoxSize" $conf(tlscp,targetBoxSize)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "angle" $conf(tlscp,angle)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "alphaSpeed" $conf(tlscp,alphaSpeed)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "deltaSpeed" $conf(tlscp,deltaSpeed)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "alphaReverse" $conf(tlscp,alphaReverse)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "deltaReverse" $conf(tlscp,deltaReverse)
   ::camera::setParam $::tlscp::private($visuNo,camItem) "seuilx" $conf(tlscp,seuilx)

   #--- je redessine la cible
   ::tlscp::createTarget $visuNo

   #--- je redessine les axes
   ::tlscp::changeShowAxis $visuNo
   update
}

#------------------------------------------------------------
# closeWindow
#    ferme la fenetre de configuration
#------------------------------------------------------------
proc ::tlscp::config::closeWindow { visuNo } {
   variable private
   global caption

   set geometry [ wm geometry $private($visuNo,This) ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set ::conf(tlscp,configWindowPosition) "+[ string range $geometry $deb $fin ]"
   set private($visuNo,selectedNotebook) [$private($visuNo,frm).notebook raise]
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

   set widget($visuNo,methode)         $conf(tlscp,methode)
   set widget($visuNo,detection)       $conf(tlscp,detection)
   set widget($visuNo,kappa)           $conf(tlscp,kappa)
   set widget($visuNo,maxMagnitude)    $conf(tlscp,maxMagnitude)
   set widget($visuNo,delta)           $conf(tlscp,delta)
   set widget($visuNo,epsilon)         $conf(tlscp,epsilon)
   set widget($visuNo,foclen)          $conf(tlscp,foclen)

   set widget($visuNo,searchThreshin)  $conf(tlscp,searchThreshin)
   set widget($visuNo,searchFwhm)      $conf(tlscp,searchFwhm)
   set widget($visuNo,searchRadius)    $conf(tlscp,searchRadius)
   set widget($visuNo,searchThreshold) $conf(tlscp,searchThreshold)

   set widget($visuNo,catalogueName)   $conf(tlscp,catalogueName)
   set widget($visuNo,cataloguePath)   $conf(tlscp,cataloguePath,$conf(tlscp,catalogueName))

   #--- Creation des onglets
   set notebook [ NoteBook $frm.notebook ]
   set notebookMount  [$notebook insert end "mount" -text $caption(tlscp,mount) ]
   set notebookCamera [$notebook insert end "camera" -text $caption(tlscp,camera) ]
   set notebookCenter [$notebook insert end "center" -text $caption(tlscp,center) ]

   #--- notebookMount
   set frm $notebookMount

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
        ### -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s -9999 9999}
      pack $frm.delta.gainprop -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.delta.seuil -label "$caption(tlscp,seuil)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s 0 99} \
         -textvariable ::tlscp::config::widget($visuNo,seuily)
      pack $frm.delta.seuil -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.delta.reverse -text "$caption(tlscp,deltaReverse)" \
         -variable ::tlscp::config::widget($visuNo,deltaReverse)
      pack $frm.delta.reverse -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0

   #--- Frame telescope
   TitleFrame $frm.telescope -borderwidth 2 -text "$caption(tlscp,telescope)"
      label $frm.telescope.speedLabel -text "$caption(tlscp,defaultSpeed)"
      pack $frm.telescope.speedLabel -in [$frm.telescope getframe] -anchor w -side left -fill x -expand 0
      set speedList [::telescope::getSpeedValueList]
      ComboBox $frm.telescope.speedList -relief sunken -borderwidth 1 -editable 0 \
         -height [llength $speedList] \
         -width [ ::tkutil::lgEntryComboBox $speedList ] \
         -textvariable ::tlscp::config::widget($visuNo,centerSpeed) \
         -values $speedList
      pack $frm.telescope.speedList -in [$frm.telescope getframe] -anchor w -side left -fill x -expand 0

   pack $frm.alpha -in $frm -anchor w -side top -fill x -expand 0
   pack $frm.delta -in $frm -anchor w -side top -fill x -expand 0
   pack $frm.telescope -in $frm -anchor w -side top -fill x -expand 0

   #--- notebookCamera
   set frm $notebookCamera

   #--- Frame camera
   frame $frm.fits
      button $frm.fits.buttonFits -text "$caption(tlscp,en-tete_fits)" \
         -command "::keyword::run $visuNo"
      pack $frm.fits.buttonFits -anchor n -side top -fill x

   TitleFrame $frm.camera -borderwidth 2 -text "$caption(tlscp,camera)"
      LabelEntry $frm.camera.angle -label "$caption(tlscp,angle)" \
         -labeljustify left -labelwidth 14 -width 5 -justify right \
         -validate all -validatecommand { ::tlscp::validateNumber %W %V %P %s -360 360} \
         -textvariable ::tlscp::config::widget($visuNo,angle)
      pack $frm.camera.angle -in [$frm.camera getframe] -anchor w -side top -fill x -expand 0

   pack $frm.fits   -in $frm -anchor w -side top -fill x -expand 0
   pack $frm.camera -in $frm -anchor w -side top -fill x -expand 0 -pady 5

   #--- onglet centrer
   set frm $notebookCenter

   #--- Frame search
   frame $frm.method
      radiobutton $frm.method.radioBrightest -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $caption(tlscp,brightest) -value "BRIGHTEST" \
         -variable ::tlscp::config::widget($visuNo,methode) \
         -command  "::tlscp::config::onSelectMethod $visuNo $notebookCenter"
      radiobutton $frm.method.radioAstrom -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $caption(tlscp,astrometry) -value "ASTROMETRY" \
         -variable ::tlscp::config::widget($visuNo,methode) \
         -command  "::tlscp::config::onSelectMethod $visuNo $notebookCenter"
      pack $frm.method.radioBrightest  -anchor w -side left -fill x -expand 0
      pack $frm.method.radioAstrom     -anchor w -side left -fill x -expand 0

   TitleFrame $frm.brightest -borderwidth 2 -text "$caption(tlscp,searchTitle)"
      LabelEntry $frm.brightest.searchBoxSize -label $caption(tlscp,searchBoxSize) \
         -labeljustify left -labelwidth 16 -width 4 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,searchBoxSize)
      checkbutton $frm.brightest.showSearchBox -text "$caption(tlscp,showSearchBox)" \
         -variable ::tlscp::config::widget($visuNo,showAxis)
      pack $frm.brightest.searchBoxSize -in [$frm.brightest getframe] -anchor w -side top -fill x -expand 0
      pack $frm.brightest.showSearchBox -in [$frm.brightest getframe] -anchor w -side top -fill x -expand 0

   TitleFrame $frm.astrom -borderwidth 2 -text "$caption(tlscp,detection)"
      frame $frm.astrom.detection
         radiobutton $frm.astrom.detection.radioStat -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text $caption(tlscp,stat) -value "STAT" \
            -variable ::tlscp::config::widget($visuNo,detection) \
            -command  "::tlscp::config::onSelectDetection $visuNo $notebookCenter"
         radiobutton $frm.astrom.detection.radioBogumil -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text $caption(tlscp,bogumil) -value "BOGUMIL" \
            -variable ::tlscp::config::widget($visuNo,detection) \
            -command  "::tlscp::config::onSelectDetection $visuNo $notebookCenter"
         pack $frm.astrom.detection.radioStat      -anchor w -side left -fill x -expand 0
         pack $frm.astrom.detection.radioBogumil   -anchor w -side left -fill x -expand 0

      frame $frm.astrom.stat -borderwidth 2
         LabelEntry $frm.astrom.stat.kappa -label "$caption(tlscp,kappa)" \
            -labeljustify left -labelwidth 22 -width 3 -justify right \
            -textvariable ::tlscp::config::widget($visuNo,kappa)
         pack $frm.astrom.stat.kappa  -anchor w -side left -fill x -expand 0

      frame  $frm.astrom.bogumil -borderwidth 2
         LabelEntry $frm.astrom.bogumil.threshin -label "$caption(tlscp,searchThreshin)" \
            -labeljustify left -labelwidth 22 -width 3 -justify right \
            -textvariable ::tlscp::config::widget($visuNo,searchThreshin)
         LabelEntry $frm.astrom.bogumil.fwhm -label "$caption(tlscp,searchFwhm)" \
            -labeljustify left -labelwidth 22 -width 3 -justify right \
            -textvariable ::tlscp::config::widget($visuNo,searchFwhm)
         LabelEntry $frm.astrom.bogumil.radius -label "$caption(tlscp,searchRadius)" \
            -labeljustify left -labelwidth 22 -width 3 -justify right \
            -textvariable ::tlscp::config::widget($visuNo,searchRadius)
         LabelEntry $frm.astrom.bogumil.threshold -label "$caption(tlscp,searchThreshold)" \
            -labeljustify left -labelwidth 22 -width 3 -justify right \
            -textvariable ::tlscp::config::widget($visuNo,searchThreshold)
         pack $frm.astrom.bogumil.threshin  -anchor w -side top -fill x -expand 0
         pack $frm.astrom.bogumil.fwhm      -anchor w -side top -fill x -expand 0
         pack $frm.astrom.bogumil.radius    -anchor w -side top -fill x -expand 0
         pack $frm.astrom.bogumil.threshold -anchor w -side top -fill x -expand 0

      pack $frm.astrom.detection -in [$frm.astrom getframe] -anchor w -side top -fill x -expand 0
      pack $frm.astrom.stat      -in [$frm.astrom getframe] -anchor w -side top -fill x -expand 0
      pack $frm.astrom.bogumil   -in [$frm.astrom getframe] -anchor w -side top -fill x -expand 0

   TitleFrame $frm.catalogue -borderwidth 2 -text "$caption(tlscp,catalogue)"
      set catalogueList [list "MicroCat" "USNO"]
      ComboBox $frm.catalogue.name -relief sunken -borderwidth 1 -editable 0 \
         -height [llength $catalogueList] \
         -width [ ::tkutil::lgEntryComboBox $catalogueList ] \
         -textvariable ::tlscp::config::widget($visuNo,catalogueName) \
         -modifycmd "::tlscp::config::onSelectCatalogue $visuNo" \
         -values $catalogueList
      pack $frm.catalogue.name -in [$frm.catalogue getframe] -anchor w -side top -fill x -expand 0

      frame $frm.catalogue.path
         LabelEntry $frm.catalogue.path.value -label "$caption(tlscp,cataloguePath)" \
            -labeljustify left -labelwidth 22 -justify left -padx 2 \
            -textvariable ::tlscp::config::widget($visuNo,cataloguePath)
         pack $frm.catalogue.path.value -anchor w -side left -fill x -expand 1
         button $frm.catalogue.path.button -text "..." -command "::tlscp::config::onChooseDirectory $visuNo"
         pack $frm.catalogue.path.button -anchor w -side right -fill none -expand 0
      pack $frm.catalogue.path  -in [$frm.catalogue getframe] -anchor w -side top -fill x -expand 1

      LabelEntry $frm.catalogue.maxMagnitude -label "$caption(tlscp,maxMagnitude)" \
         -labeljustify left -labelwidth 22 -justify right -padx 2 \
         -textvariable ::tlscp::config::widget($visuNo,maxMagnitude)
      pack $frm.catalogue.maxMagnitude -in [$frm.catalogue getframe] -anchor w -side top -fill x -expand 0

   TitleFrame $frm.matching -borderwidth 2 -text "$caption(tlscp,matching)"
      LabelEntry $frm.matching.delta -label "$caption(tlscp,delta)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,delta)
      LabelEntry $frm.matching.epsilon -label "$caption(tlscp,epsilon)" \
         -labeljustify left -labelwidth 22 -width 8 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,epsilon)
      pack $frm.matching.delta   -in [$frm.matching getframe] -anchor w -side top -fill x -expand 0
      pack $frm.matching.epsilon  -in [$frm.matching getframe] -anchor w -side top -fill x -expand 0

   LabelEntry $frm.foclen -label "$caption(tlscp,foclen)" \
         -labeljustify left -labelwidth 22 -width 8 -justify right \
         -textvariable ::tlscp::config::widget($visuNo,foclen)

   pack $frm.method     -in $frm -anchor w -side top -fill x -expand 0
   pack $frm.catalogue  -in $frm -anchor w -side top -fill x -expand 0
   pack $frm.matching   -in $frm -anchor w -side top -fill x -expand 0
   pack $frm.foclen     -in $frm -anchor w -side top -fill x -expand 0
   ::tlscp::config::onSelectMethod $visuNo $notebookCenter

   pack $notebook -in $private($visuNo,frm) -fill both -expand 1 -padx 2 -pady 2

   if { [info exists private($visuNo,selectedNotebook)] == 0 } {
      set private($visuNo,selectedNotebook) "mount"
   }

   $notebook raise $private($visuNo,selectedNotebook)
}

#------------------------------------------------------------
# onSelectCatalogue
#    affiche le repertoire du catalogue quand on choisit un autre catalogue
# parametres
#    visuNo : numero de la visu
# return
#    rien
#------------------------------------------------------------
proc ::tlscp::config::onSelectCatalogue { visuNo } {
   variable widget

   #--- je copie le repertoire du catalogue selectionne dans la variable du widget
   set widget($visuNo,cataloguePath) $::conf(tlscp,cataloguePath,$widget($visuNo,catalogueName))
}

#------------------------------------------------------------
# onChooseDirectory
#    affiche la fenetre pour choisir le repertoire du catalogue.
# parametres
#    visuNo : numero de la visu
# return
#    rien
#------------------------------------------------------------
proc ::tlscp::config::onChooseDirectory  { visuNo } {
   variable private
   variable widget
   set res [ tk_chooseDirectory -title $::caption(tlscp,selectPath) -initialdir $widget($visuNo,cataloguePath) -parent $private($visuNo,frm)  ]
   if {$res!=""} {
      set widget($visuNo,cataloguePath) $res
   }
}

#------------------------------------------------------------
# onChooseDirectory
#    affiche les parametre de la methode quand on change de methode BRIGHTEST ou ASTROMETRY
# parametres
#    visuNo : numero de la visu
# return
#    rien
#------------------------------------------------------------
proc ::tlscp::config::onSelectMethod { visuNo frm } {
   variable widget

   switch $widget($visuNo,methode) {
      "BRIGHTEST" {
         pack $frm.brightest  -in $frm -anchor w -side top -fill x -expand 0
         pack forget  $frm.astrom
      }
      "ASTROMETRY" {
         pack forget  $frm.brightest
         pack $frm.astrom     -in $frm -anchor w -side top -fill x -expand 0
         ::tlscp::config::onSelectDetection $visuNo $frm
      }
   }
}

proc ::tlscp::config::onSelectDetection { visuNo frm } {
   variable widget

   switch $widget($visuNo,detection) {
      "STAT" {
         pack $frm.astrom.stat -in [$frm.astrom getframe] -anchor w -side top -fill x -expand 0
         pack forget  $frm.astrom.bogumil
      }
      "BOGUMIL" {
         pack forget  $frm.astrom.stat
         pack $frm.astrom.bogumil -in [$frm.astrom getframe] -anchor w -side top -fill x -expand 0
      }
   }
}

