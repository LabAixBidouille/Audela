#
# Fichier : sophie.tcl
# Description : Outil d'autoguidage pour le spectro Sophie du telescope T193 de l'OHP
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophie.tcl,v 1.2 2009-05-08 12:54:01 robertdelmas Exp $
#

#============================================================
# Declaration du namespace sophie
#    initialise le namespace
#============================================================
namespace eval ::sophie {
   package provide sophie 1.0
   package require audela 1.5.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] sophie.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::sophie::getPluginTitle { } {
   global caption

   return "$caption(sophie,titre)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::sophie::getPluginHelp { } {
   return "sophie.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::sophie::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::sophie::getPluginDirectory { } {
   return "sophie"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::sophie::getPluginOS { } {
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
proc ::sophie::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "tool" }
      function     { return "autoguider" }
      subfunction1 { return "focusing" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::sophie::initPlugin { tkbase } {

}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::sophie::createPluginInstance { { in "" } { visuNo 1 } } {
   variable private
   global audace caption color conf

   source [ file join $audace(rep_plugin) tool sophie sophiecommand.tcl ]
   source [ file join $audace(rep_plugin) tool sophie sophieconfig.tcl ]
   source [ file join $audace(rep_plugin) tool sophie sophiecontrol.tcl ]
   source [ file join $audace(rep_plugin) tool sophie sophietest.tcl ] ; # a supprimer quand on aura fait les premiers tests

   if { ! [ info exists conf(sophie,exposure) ] }               { set conf(sophie,exposure                 "0.5" }
   if { ! [ info exists conf(sophie,binning) ] }                { set conf(sophie,binning)                 [lindex $audace(list_binning) 1] }
   if { ! [ info exists conf(sophie,intervalle)] }              { set conf(sophie,intervalle)              "0" }
   if { ! [ info exists conf(sophie,alphaSpeed)] }              { set conf(sophie,alphaSpeed)              "10" }
   if { ! [ info exists conf(sophie,deltaSpeed)] }              { set conf(sophie,deltaSpeed)              "10" }
   if { ! [ info exists conf(sophie,seuilx)] }                  { set conf(sophie,seuilx)                  "1" }
   if { ! [ info exists conf(sophie,seuily)] }                  { set conf(sophie,seuily)                  "1" }
   if { ! [ info exists conf(sophie,detection)] }               { set conf(sophie,detection)               "FIBER" }
   if { ! [ info exists conf(sophie,angle)] }                   { set conf(sophie,angle)                   "0" }
   if { ! [ info exists conf(sophie,showOrigin)] }              { set conf(sophie,showOrigin)              "1" }
   if { ! [ info exists conf(sophie,showImage)] }               { set conf(sophie,showImage)               "1" }
   if { ! [ info exists conf(sophie,showTarget)] }              { set conf(sophie,showTarget)              "1" }
   if { ! [ info exists conf(sophie,targetBoxSize)] }           { set conf(sophie,targetBoxSize)           "16" }
   if { ! [ info exists conf(sophie,originCoord)] }             { set conf(sophie,originCoord)             [list 320 240 ] }
   if { ! [ info exists conf(sophie,originBoxSize)] }           { set conf(sophie,originBoxSize)           "32" }
   if { ! [ info exists conf(sophie,declinaisonEnabled)] }      { set conf(sophie,declinaisonEnabled)      "1" }
   if { ! [ info exists conf(sophie,cumulEnabled)] }            { set conf(sophie,cumulEnabled)            "0" }
   if { ! [ info exists conf(sophie,cumulNb)] }                 { set conf(sophie,cumulNb)                 "5" }
   if { ! [ info exists conf(sophie,darkEnabled)] }             { set conf(sophie,darkEnabled)             "0" }
   if { ! [ info exists conf(sophie,darkFileName)] }            { set conf(sophie,darkFileName)            "dark.fit" }
   if { ! [ info exists conf(sophie,alphaReverse)] }            { set conf(sophie,alphaReverse)            "0" }
   if { ! [ info exists conf(sophie,deltaReverse)] }            { set conf(sophie,deltaReverse)            "0" }

   if { ! [ info exists conf(sophie,biasImage)] }               { set conf(sophie,biasImage)               "" }
   if { ! [ info exists conf(sophie,imageDirectory)] }          { set conf(sophie,imageDirectory)          $::audace(rep_images) }
   if { ! [ info exists conf(sophie,guidingMode)] }             { set conf(sophie,guidingMode)             "FIBER" }  ; # FIBER ou OBJECT
   if { ! [ info exists conf(sophie,fiberGuigindMode)] }        { set conf(sophie,fiberGuigindMode)        "HR" }
   if { ! [ info exists conf(sophie,xfibreAHR)] }               { set conf(sophie,xfibreAHR)               "314" }
   if { ! [ info exists conf(sophie,yfibreAHR)] }               { set conf(sophie,yfibreAHR)               "150" }
   if { ! [ info exists conf(sophie,xfibreAHE)] }               { set conf(sophie,xfibreAHE)               "315" }
   if { ! [ info exists conf(sophie,yfibreAHE)] }               { set conf(sophie,yfibreAHE)               "151" }
   if { ! [ info exists conf(sophie,xfibreB)] }                 { set conf(sophie,xfibreB)                 "925" }
   if { ! [ info exists conf(sophie,yfibreB)] }                 { set conf(sophie,yfibreB)                 "566" }
   if { ! [ info exists conf(sophie,targetDetectionThresold)] } { set conf(sophie,targetDetectionThresold) "10" }

   if { $conf(sophie,originCoord) == "" }                       { set conf(sophie,originCoord)          [list 320 240 ] }

   #--- Initialisation de variables
   set private(frm)              "$in.sophie"
   set private(listePose)        "0.1 0.2 0.5 0.8 1"
   set private(pose)             "0.5"
   set private(listeBinning)     "1x1 2x2 3x3 4x4 5x5 6x6"
   set private(binning)          "2x2"
   set private(mode)             "centrage"
   set private(zoom)             "1"
   set private(attenuateur)      "50"

   set private(hCanvas)          [::confVisu::getCanvas $visuNo]
   set private(targetCoord)      $conf(sophie,originCoord)
   set private(centerEnabled)    0
   set private(mountEnabled)     0
   set private(delay,alpha)      "0.00"   ; # duree de rappel en alpha
   set private(delay,delta)      "0.00"   ; # duree de rappel en delta
   set private(acquisitionState) 0        ; # etat de l'acquisition  continue 0=arrete  1= en cours
   set private(detectedTarget)   0        ; # 0=etoile non detectee  1=etoile detectee

   #--- Petit raccourci
   set frm $private(frm)

   #--- Interface graphique de l'outil
   frame $frm -borderwidth 2 -relief groove

      #--- Frame du titre et de la configuration
      frame $frm.titre -borderwidth 2 -relief groove

         #--- Bouton du titre
         image create photo sophieLogo -file [ file join $audace(rep_plugin) [ ::audace::getPluginTypeDirectory [ getPluginType ] ] [ getPluginDirectory ] "logosophie.gif" ]
         Button $frm.titre.but1 -borderwidth 1 -image "sophieLogo" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory \
            [ ::sophie::getPluginType ] ] [ ::sophie::getPluginDirectory ] [ ::sophie::getPluginHelp ]"
         pack $frm.titre.but1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $frm.titre.but1 -text "$caption(sophie,aide)"

         #--- Bouton d'ouverture de la fenetre de configuration
         button $frm.titre.but2 -borderwidth 2 -text "$caption(sophie,config)" \
            -command "::sophie::config::run [winfo toplevel $private(frm)]"
         pack $frm.titre.but2 -anchor center -expand 0 -fill x -ipady 2 -padx 2 -pady 2

      pack $frm.titre -side top -fill x

      #--- Frame pour l'acquisition
      frame $frm.acq -borderwidth 1 -relief groove

         #--- Label pour la pose
         label $frm.acq.lab1 -borderwidth 0 -text "$caption(sophie,pose)"
         grid $frm.acq.lab1 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky w -padx 3

         #--- ComboBox pour le choix du temps de pose
         ComboBox $frm.acq.exposure \
            -entrybg white -justify center -takefocus 1 \
            -width [ ::tkutil::lgEntryComboBox $private(listePose) ] \
            -textvariable ::conf(sophie,exposure) \
            -values $private(listePose)
         grid $frm.acq.exposure -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky e

         #--- Label pour le binning
         label $frm.acq.lab2 -borderwidth 0 -text "$caption(sophie,binning)"
         grid $frm.acq.lab2 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky w -padx 3

         #--- ComboBox pour le choix du binning
         ComboBox $frm.acq.binning \
            -entrybg white -justify center -takefocus 1 \
            -width [ ::tkutil::lgEntryComboBox $private(listeBinning) ] \
            -textvariable ::sophie::private(binning) \
            -values $private(listeBinning)
         grid $frm.acq.binning -column 1 -row 1 -columnspan 1 -rowspan 1 -sticky e

         #--- Bouton de lancement de l'outil
         button $frm.acq.goAcq -borderwidth 2 -text $::caption(sophie,goAcq) \
            -command "::sophie::startAcquisition $visuNo"
         grid $frm.acq.goAcq -column 0 -row 2 -columnspan 2 -rowspan 1 -ipadx 20 -ipady 4 -pady 2

         grid columnconfigure $frm.acq 0 -weight 1

      pack $frm.acq -side top -fill x

      #--- Frame pour le mode de fonctionnement
      TitleFrame $frm.mode -borderwidth 2 -relief groove -text "$caption(sophie,mode)"

         #--- Radiobutton pour le mode Centrage
         radiobutton $frm.mode.centrage \
            -command " " -indicatoron 0 -text "$caption(sophie,centrage)" -value centrage \
            -variable ::sophie::private(mode) -command "::sophie::onChangeMode"
         pack $frm.mode.centrage -in [ $frm.mode getframe ] -anchor center \
            -expand 0 -fill x -side top

         #--- Radiobutton pour le mode Mise au point
         radiobutton $frm.mode.focalisation \
            -command " " -indicatoron 0 -text "$caption(sophie,focalisation)" -value focalisation \
            -variable ::sophie::private(mode) -command "::sophie::onChangeMode"
         pack $frm.mode.focalisation -in [ $frm.mode getframe ] -anchor center \
            -expand 0 -fill x -side top

         #--- Radiobutton pour le mode Guidage
         radiobutton $frm.mode.guidage \
            -command " " -indicatoron 0 -text "$caption(sophie,guidage)" -value guidage \
            -variable ::sophie::private(mode) -command "::sophie::onChangeMode"
         pack $frm.mode.guidage -in [ $frm.mode getframe ] -anchor center \
            -expand 0 -fill x -side top

      pack $frm.mode -side top -fill x

      #--- Frame pour le zoom
      TitleFrame $frm.zoom -borderwidth 2 -relief groove \
         -text "$caption(sophie,zoom)"

         #--- Diminution du zoom
         ArrowButton $frm.zoom.butMin -borderwidth 1 -dir left -relief raised \
            -command "::sophie::incrementZoom"
         pack $frm.zoom.butMin -in [ $frm.zoom getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

         #--- Entry pour la consigne du zoom
         entry $frm.zoom.entry \
            -background $color(white) -state readonly -takefocus 0 \
            -textvariable ::sophie::private(zoom) -width 6 -justify center
         pack $frm.zoom.entry -in [ $frm.zoom getframe ] \
            -anchor center -expand 0 -fill none -side left

         #--- Augmentation du zoom
         ArrowButton $frm.zoom.butMax -borderwidth 1 -dir right -relief raised \
            -command "::sophie::decrementZoom"
         pack $frm.zoom.butMax -in [ $frm.zoom getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

      pack $frm.zoom -side top -fill x

      #--- Frame pour l'attenuateur
      TitleFrame $frm.attenuateur -borderwidth 2 -relief groove \
         -text "$caption(sophie,attenuateur)"

         #--- Label blanc
         label $frm.attenuateur.labBlanc_color_invariant -text "  " -background $color(white)
         pack $frm.attenuateur.labBlanc_color_invariant -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 0 -fill none -side left

         ArrowButton $frm.attenuateur.butMin -borderwidth 1 -dir left -relief raised \
            -command "::sophie::incrementAttenuateur"
         pack $frm.attenuateur.butMin -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

         ArrowButton $frm.attenuateur.butMax -borderwidth 1 -dir right -relief raised \
            -command "::sophie::decrementAttenuateur"
         pack $frm.attenuateur.butMax -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

         #--- Label noir
         label $frm.attenuateur.labNoir_color_invariant -text "  " -background $color(black)
         pack $frm.attenuateur.labNoir_color_invariant -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 0 -fill none -side left

         #--- Entry pour la consigne de l'attenuateur
         entry $frm.attenuateur.entry \
            -background $color(white) -state readonly -takefocus 0 \
            -textvariable ::sophie::private(attenuateur) -width 4 -justify center
         pack $frm.attenuateur.entry -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 0 -fill none -side top

      pack $frm.attenuateur -side top -fill x

      #--- Frame pour l'image
      TitleFrame $frm.image -borderwidth 2 -relief groove -text "$caption(sophie,image)"

         #--- Bouton pour enregistrer l'image courante
         button $frm.image.but4 -borderwidth 2 -text "$caption(sophie,enregistrer)" \
            -command " "
         pack $frm.image.but4 -in [ $frm.image getframe ] -anchor center \
            -expand 0 -fill x -ipady 2 -padx 2 -pady 2

         #--- Bouton pour visualiser une image
         button $frm.image.but5 -borderwidth 2 -text "$caption(sophie,voirImage)" \
            -command "::sophie::showImage"
         pack $frm.image.but5 -in [ $frm.image getframe ] -anchor center \
            -expand 0 -fill x -ipady 2 -padx 2 -pady 2

      pack $frm.image -side top -fill x

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $frm <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::sophie::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::startTool { visuNo } {
   variable private

   pack $private(frm) -side left -fill y

   #--- je change le bind du bouton droit de la souris sur le canvas
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::sophie::setOriginCoord $visuNo %x %y"
   #--- je change le bind du double-clic du bouton gauche de la souris sur le canvas
   ::confVisu::createBindCanvas $visuNo <Double-1> "::sophie::setTargetCoord $visuNo %x %y"

   #--- j'active la mise a jour automatique de l'affichage quand on change de camera
   ::confVisu::addCameraListener $visuNo "::sophie::adaptPanel $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
   ::confVisu::addZoomListener $visuNo "::sophie::onChangeZoom $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de fenetrage
   ::confVisu::addSubWindowListener $visuNo "::sophie::onChangeSubWindow $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de miroir
   ::confVisu::addMirrorListener $visuNo "::sophie::onChangeSubWindow $visuNo"

   #--- j'adapte l'affichage du panneau
   adaptPanel $visuNo

   #--- Ouverture de la fenetre de controle de l'interface
   ::sophie::control::run [winfo toplevel $private(frm)] $visuNo
   #--- je mets à jour le mode
   ::sophie::setMode $private(mode)

   #--- j'affiche la cible sur l'image
   createTarget $visuNo

}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::stopTool { visuNo } {
   variable private

   #--- Je verifie si une operation est en cours
   if { $private(acquisitionState) == 1 } {
      return -1
   }

   #--- j'arrete le suivi
   stopAcquisition $visuNo

   #--- je desactive l'adaptation de l'affichage quand on change de camera
   ::confVisu::removeCameraListener $visuNo "::sophie::adaptPanel $visuNo"
   #--- je desactive l'adaptation de l'affichage quand on change de zoom
   ::confVisu::removeZoomListener $visuNo "::sophie::onChangeZoom $visuNo"
   #--- je desactive l'adaptation de l'affichage quand on change de fenetrage
   ::confVisu::removeSubWindowListener $visuNo "::sophie::onChangeSubWindow $visuNo"
   #--- je desactive l'adaptation de l'affichage quand on change de miroir
   ::confVisu::removeMirrorListener $visuNo "::sophie::onChangeSubWindow $visuNo"

   #--- je supprime la cible
   ::sophie::deleteTarget $visuNo
   #--- je supprime la consigne
   ::sophie::deleteOrigin $visuNo

   #--- je restaure le bind par defaut du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "default"
   #--- je restaure le bind par defaut du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "default"

   #--- je ferme la fenetre de controle
   ::sophie::control::closeWindow $visuNo

   #--- je masque le panneau
   pack forget $private(frm)

}

