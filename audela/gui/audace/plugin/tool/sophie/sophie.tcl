##------------------------------------------------------------
# @file     sophie.tcl
# @brief    Fichier du namespace ::sophie
# @author   Michel PUJOL et Robert DELMAS
# @version   $Id: sophie.tcl,v 1.24 2009-09-08 09:33:56 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @mainpage   Outil de guidage pour le spectro Sophie.
#
# @image html logosophie.gif
#
# Dans un premier temps, les éléments remplacés sont :
# - le PC de guidage et logiciel de guidage sont remplacés ( => Windows Vista et Audela),
# - la caméra de guidage est remplacée par la caméra FLI,
# - la carte wrappée est remplacée par la carte N.I. USB-6501.
#
# Puis, dans un deuxième temps :
# - le HP1000 est remplacé par un « PC T193 » avec les nouveaux moteurs associés (moteurs ETEL et BRADFOR commandés par une carte DELTATAU).
#
# Le cahier des charges « cahier des charges_guidage_193_v0.pdf » décrit les besoins suivants :
# - Le logiciel doit permettre de s'interfacer avec les équipements de la configuration intermédiaire puis de la configuration cible.
# - Il doit fournir les fonctions de centrage d'une étoile sur une consigne, d'aide à la mise au point (focalisation) et de guidage automatique du télescope pendant les poses du spectrographe Sophie.
#
# Interlocuteurs opérationnels :
# - Luc Arnold : Nouveau PC guidage et caméra FLI
# - François Moreau : jouvance T193
# - Jean Pierre Menier : spectrographe Sophie
# - Xavier Regal : commandes atténuateurs, carte National Instrument
# - Fabien Fillion : PC de supervision du T193
#
#------------------------------------------------------------



##------------------------------------------------------------
# @brief   namespace principal de l'outil sophie
#
#------------------------------------------------------------
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
   return $::caption(sophie,titre)
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
   source [ file join $::audace(rep_plugin) tool sophie sophiecommand.tcl ]
   source [ file join $::audace(rep_plugin) tool sophie sophieconfig.tcl ]
   source [ file join $::audace(rep_plugin) tool sophie sophiecontrol.tcl ]
   source [ file join $::audace(rep_plugin) tool sophie sophiespectro.tcl ]
   source [ file join $::audace(rep_plugin) tool sophie sophieview.tcl ]
   source [ file join $::audace(rep_plugin) tool sophie sophietest.tcl ] ; #--- a supprimer quand on aura fait les premiers tests

   if { ! [ info exists ::conf(sophie,exposure) ] }                 { set ::conf(sophie,exposure)                  "0.5" }
   if { ! [ info exists ::conf(sophie,centerBinning) ] }            { set ::conf(sophie,centerBinning)             "2x2" }
   if { ! [ info exists ::conf(sophie,guideBinning) ] }             { set ::conf(sophie,guideBinning)              "1x1" }
   if { ! [ info exists ::conf(sophie,pixelScale)] }                { set ::conf(sophie,pixelScale)                "0.186" }
   if { ! [ info exists ::conf(sophie,alphaProportionalGain)] }     { set ::conf(sophie,alphaProportionalGain)     "0.9" }
   if { ! [ info exists ::conf(sophie,alphaIntegralGain)] }         { set ::conf(sophie,alphaIntegralGain)         "0.1" }
   if { ! [ info exists ::conf(sophie,deltaProportionalGain)] }     { set ::conf(sophie,deltaProportionalGain)     "0.9" }
   if { ! [ info exists ::conf(sophie,deltaIntegralGain)] }         { set ::conf(sophie,deltaIntegralGain)         "0.1" }
   if { ! [ info exists ::conf(sophie,minMaxDiff)] }                { set ::conf(sophie,minMaxDiff)                "0.5" }
   if { ! [ info exists ::conf(sophie,detection)] }                 { set ::conf(sophie,detection)                 "FIBER" }
   if { ! [ info exists ::conf(sophie,centerMaxLimit)] }            { set ::conf(sophie,centerMaxLimit)            "3" }
   if { ! [ info exists ::conf(sophie,objectCoord)] }               { set ::conf(sophie,objectCoord)               [list 320 240 ] }
   if { ! [ info exists ::conf(sophie,originBoxSize)] }             { set ::conf(sophie,originBoxSize)             "32" }
   if { ! [ info exists ::conf(sophie,alphaReverse)] }              { set ::conf(sophie,alphaReverse)              "0" }
   if { ! [ info exists ::conf(sophie,deltaReverse)] }              { set ::conf(sophie,deltaReverse)              "0" }

   if { ! [ info exists ::conf(sophie,biasFileName,1,slow)] }       { set ::conf(sophie,biasFileName,1,slow)       "" }
   if { ! [ info exists ::conf(sophie,biasFileName,1,fast)] }       { set ::conf(sophie,biasFileName,1,fast)       "" }
   if { ! [ info exists ::conf(sophie,biasFileName,2,slow)] }       { set ::conf(sophie,biasFileName,2,slow)       "" }
   if { ! [ info exists ::conf(sophie,biasFileName,2,fast)] }       { set ::conf(sophie,biasFileName,2,fast)       "" }
   if { ! [ info exists ::conf(sophie,correctionCumulNb)] }         { set ::conf(sophie,correctionCumulNb)         1 }
   if { ! [ info exists ::conf(sophie,originSumNb)] }               { set ::conf(sophie,originSumNb)               1 }
   if { ! [ info exists ::conf(sophie,guidingWindowSize)] }         { set ::conf(sophie,guidingWindowSize)         200 }
   if { ! [ info exists ::conf(sophie,centerWindowSize)] }          { set ::conf(sophie,centerWindowSize)          100 }
   if { ! [ info exists ::conf(sophie,imageDirectory)] }            { set ::conf(sophie,imageDirectory)            "$::audace(rep_images)" }
   if { ! [ info exists ::conf(sophie,guidingMode)] }               { set ::conf(sophie,guidingMode)               "FIBER_HR" } ; #--- FIBER_HR , FIBER_HE ou OBJECT
   ###if { ! [ info exists ::conf(sophie,fiberGuigindMode)] }          { set ::conf(sophie,fiberGuigindMode)          "HR" }
   if { ! [ info exists ::conf(sophie,fiberHRX)] }                  { set ::conf(sophie,fiberHRX)                  "314" }
   if { ! [ info exists ::conf(sophie,fiberHRY)] }                  { set ::conf(sophie,fiberHRY)                  "150" }
   if { ! [ info exists ::conf(sophie,fiberHEX)] }                  { set ::conf(sophie,fiberHEX)                  "315" }
   if { ! [ info exists ::conf(sophie,fiberHEY)] }                  { set ::conf(sophie,fiberHEY)                  "151" }
   if { ! [ info exists ::conf(sophie,xfibreB)] }                   { set ::conf(sophie,xfibreB)                   "925" }
   if { ! [ info exists ::conf(sophie,yfibreB)] }                   { set ::conf(sophie,yfibreB)                   "566" }
   if { ! [ info exists ::conf(sophie,targetDetectionThresold)] }   { set ::conf(sophie,targetDetectionThresold)   "10" }
   if { ! [ info exists ::conf(sophie,simulation)] }                { set ::conf(sophie,simulation)                "0" }
   if { ! [ info exists ::conf(sophie,simulationGenericFileName)] } { set ::conf(sophie,simulationGenericFileName) "$::audace(rep_images)/simulation" }
   if { ! [ info exists ::conf(sophie,centerFileNameprefix)] }      { set ::conf(sophie,centerFileNameprefix)      "centrage" }
   if { ! [ info exists ::conf(sophie,guidingFileNameprefix)] }     { set ::conf(sophie,guidingFileNameprefix)     "guidage" }
   if { ! [ info exists ::conf(sophie,maskRadius)] }                { set ::conf(sophie,maskRadius)                20 }
   if { ! [ info exists ::conf(sophie,maskFwhm)] }                  { set ::conf(sophie,maskFwhm)                  5 }
   if { ! [ info exists ::conf(sophie,maskPercent)] }               { set ::conf(sophie,maskPercent)               0.15 }
   if { ! [ info exists ::conf(sophie,pixelMinCount)] }             { set ::conf(sophie,pixelMinCount)             50 }

   if { ! [ info exists ::conf(sophie,socketPort)] }                { set ::conf(sophie,socketPort)                5020 }

   #--- Initialisation de variables
   set private(frm)              "$in.sophie"
   set private(visuNo)           $visuNo
   set private(listePose)        "0 0.1 0.2 0.5 0.8 1 2 3 5 10 new"
   set private(pose)             "0.5"
   set private(listeBinning)     "1x1 2x2 3x3 4x4"
   set private(widgetBinning)    "2x2"
   set private(xBinning)         2
   set private(yBinning)         2
   set private(mode)             "CENTER"
   set private(zoom)             "1"
   set private(attenuateur)      "5"
   set private(windowing)        "full"            ; #--- fenetrage, contient "full" ou la longueur du coté du carré de fenetrage
   set private(targetDetection)  0                 ; #--- 0=etoile non detectee , 1= etoile detectee
   set private(findFiber)        0                 ; #---  1= detection de la fibre activee 0=detection fibre desactivee
   set private(updateFilterId)   ""                ; #--- identifiant de la commande after pour la mise a jour de l'affichage du taux d'attenuation
   set private(updateFilterSate) 0                 ; #--- 0=pas de modificationde l'atténuation en cour, 1= modification de l'attennuation en cours
   set private(targetBoxSize)    100
   set private(cameraCells)      [list 1536 1024 ] ; #--- dimensions du capteur de la camera

   set private(bufNo)            [::confVisu::getBufNo $visuNo]
   set private(hCanvas)          [::confVisu::getCanvas $visuNo]
   switch $::conf(sophie,guidingMode) {
      "FIBER_HR" {
         set private(originCoord)      [list $::conf(sophie,fiberHRX) $::conf(sophie,fiberHRX) ]
      }
      "FIBER_HE" {
         set private(originCoord)      [list $::conf(sophie,fiberHEX) $::conf(sophie,fiberHEX) ]
      }
      "OBJECT" {
         set private(originCoord)      $::conf(sophie,objectCoord)
      }
      default {
         set private(originCoord)      $::conf(sophie,objectCoord)
      }
   }
      
   set private(originMove)       "AUTO"      ; #--- "MANUAL"=positionnement manuel en cours "AUTO"=positionnement automatique
   if { $::conf(sophie,detection) == "FIBER" } {
      #--- je place le symbole de la cible sur la consigne FIBRE HR
      set private(targetCoord)      [list $::conf(sophie,fiberHRX) $::conf(sophie,fiberHRY)]
   } else {
      #--- je place le symbole de la cible sur la consigne OBJET
      set private(targetCoord)      $::conf(sophie,objectCoord)
   }
   set private(targetMove)       "AUTO"   ; #--- "MANUAL"=positionnement manuel en cours "AUTO"=positionnement automatique  
   set private(centerEnabled)    0
   set private(guideEnabled)     0
   set private(mountEnabled)     0
   set private(acquisitionState) 0        ; #--- etat de l'acquisition continue 0=arrete  1=en cours
   set private(targetRa)         "0h0m0s" ; #--- ascension droite de la cible en HMS
   set private(targetDec)        "0d0m0s" ; #--- declinaison de la cible en DMS
   set private(xWindow)          1        ; #--- abscisse du coin bas gauche du fenetrage
   set private(yWindow)          1        ; #--- ordonnee du coin bas gauche du fenetrage
   set private(biasFileName)        "" 
   set private(biasBufNo)  [::buf::create ]
   set private(maskBufNo)  [::buf::create ]
   set private(sumBufNo)   [::buf::create ]
   set private(fiberBufNo) [::buf::create ]

   set private(AsynchroneParameter) 0
   set private(newAcquisition)      1     ; #--- variable utilisee par le listener addAcquisitionListener
   set private(currentMouseItem)    ""    ; #--- item en cous de deplacement avec la souris
   set private(pendingZoom)         ""
   set private(biasWindow)          ""
   set private(windowSize)          "full"
   set private(centerCoords)        [list 0 0 ]
   
   #--- Petit raccourci
   set frm $private(frm)

   #--- Interface graphique de l'outil
   frame $frm -borderwidth 2 -relief groove

      #--- Frame du titre et de la configuration
      frame $frm.titre -borderwidth 2 -relief groove

         #--- Bouton du titre
         image create photo sophieLogo -file [ file join $::audace(rep_plugin) [ ::audace::getPluginTypeDirectory [ getPluginType ] ] [ getPluginDirectory ] "logosophie.gif" ]
         Button $frm.titre.but1 -borderwidth 1 -text $::caption(sophie,aide1) -image "sophieLogo" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory \
            [ ::sophie::getPluginType ] ] [ ::sophie::getPluginDirectory ] [ ::sophie::getPluginHelp ]"
         pack $frm.titre.but1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $frm.titre.but1 -text $::caption(sophie,aide)

         #--- Bouton d'ouverture de la fenetre de configuration
         button $frm.titre.but2 -borderwidth 2 -text $::caption(sophie,config) \
            -command "::sophie::showConfigWindow $visuNo"
         pack $frm.titre.but2 -anchor center -expand 0 -fill x -ipady 2 -padx 2 -pady 2

      pack $frm.titre -side top -fill x

      #--- Frame pour l'acquisition
      TitleFrame $frm.acq -borderwidth 2 -relief groove -text $::caption(sophie,acquisition)

         #--- Label pour la pose
         label $frm.acq.labelPose -borderwidth 0 -text $::caption(sophie,pose)
         grid $frm.acq.labelPose -in [$frm.acq getframe] -column 0 -row 0 \
            -columnspan 1 -rowspan 1 -sticky w -padx 3

         #--- ComboBox pour le choix du temps de pose
         ComboBox $frm.acq.exposure \
            -entrybg white -justify center -takefocus 1 -editable 0 \
            -width [ ::tkutil::lgEntryComboBox $private(listePose) ] \
            -textvariable ::conf(sophie,exposure) \
            -modifycmd "::sophie::onChangeExposure $visuNo" \
            -values $private(listePose)
         grid $frm.acq.exposure -in [$frm.acq getframe] -column 1 -row 0 \
            -columnspan 1 -rowspan 1 -sticky e

         #--- Label pour le binning
         label $frm.acq.labBinning -borderwidth 0 -text $::caption(sophie,binning)
         grid $frm.acq.labBinning -in [$frm.acq getframe] -column 0 -row 1 \
            -columnspan 1 -rowspan 1 -sticky w -padx 3

         #--- ComboBox pour le choix du binning
         ComboBox $frm.acq.binning \
            -entrybg white -justify center -takefocus 1 -editable 0 \
            -width [ ::tkutil::lgEntryComboBox $private(listeBinning) ] \
            -textvariable ::sophie::private(widgetBinning) \
            -modifycmd "::sophie::onChangeBinning $visuNo" \
            -values $private(listeBinning)
         grid $frm.acq.binning -in [$frm.acq getframe] -column 1 -row 1 \
            -columnspan 1 -rowspan 1 -sticky e

         #--- Bouton de lancement des acqusitions
         button $frm.acq.goAcq -borderwidth 2 -height 2 -text $::caption(sophie,goAcq) \
            -command "::sophie::startAcquisition $visuNo"
         grid $frm.acq.goAcq -in [$frm.acq getframe] -column 0 -row 2 \
            -columnspan 2 -rowspan 1 -ipadx 20 -ipady 4 -pady 2 -sticky ew

         grid columnconfigure [$frm.acq getframe] 0 -weight 1

      pack $frm.acq -side top -fill x

      #--- Frame pour le mode de fonctionnement
      TitleFrame $frm.mode -borderwidth 2 -relief groove -text $::caption(sophie,mode)

         #--- Radiobutton pour le mode Centrage
         radiobutton $frm.mode.centrage -height 2 \
            -indicatoron 0 -text $::caption(sophie,CENTER) -value "CENTER" \
            -variable ::sophie::private(mode) -command "::sophie::onChangeMode"
         pack $frm.mode.centrage -in [ $frm.mode getframe ] -anchor center \
            -expand 0 -fill x -side top

         #--- Radiobutton pour le mode Mise au point
         radiobutton $frm.mode.focalisation -height 2 \
            -indicatoron 0 -text $::caption(sophie,FOCUS) -value "FOCUS" \
            -variable ::sophie::private(mode) -command "::sophie::onChangeMode"
         pack $frm.mode.focalisation -in [ $frm.mode getframe ] -anchor center \
           -expand 0 -fill x -side top

         #--- Radiobutton pour le mode Guidage
         radiobutton $frm.mode.guidage -height 2 \
            -indicatoron 0 -text $::caption(sophie,GUIDE) -value "GUIDE" \
            -variable ::sophie::private(mode) -command "::sophie::onChangeMode"
         pack $frm.mode.guidage -in [ $frm.mode getframe ] -anchor center \
            -expand 0 -fill x -side top

         #--- Commande de centrage
         checkbutton $frm.mode.centrageStart \
            -indicatoron 1 -offrelief flat -state disabled \
            -text $::caption(sophie,lancerCentrage) \
            -variable ::sophie::private(centerEnabled) \
            -command "::sophie::onCenter"
         pack $frm.mode.centrageStart -in [ $frm.mode getframe ] -anchor w \
            -expand 0 -fill x -side top

         #--- Commande de guidage
         checkbutton $frm.mode.guidageStart \
            -indicatoron 1 -offrelief flat -state disabled \
            -text $::caption(sophie,activationGuidage) \
            -variable ::sophie::private(guideEnabled) \
            -command "::sophie::onGuide"
         pack $frm.mode.guidageStart -in [ $frm.mode getframe ] -anchor w \
            -expand 0 -fill x -side top

         #--- DetectionFibre
         checkbutton $frm.mode.findFiber \
            -indicatoron 1 -offrelief flat  \
            -text $::caption(sophie,findFiber) \
            -variable ::sophie::private(findFiber) \
            -command "::sophie::onFiberDetection"
         pack $frm.mode.findFiber -in [ $frm.mode getframe ] -anchor w \
            -expand 0 -fill x -side top


      pack $frm.mode -side top -fill x

      #--- Frame pour le zoom
      TitleFrame $frm.zoom -borderwidth 2 -relief groove \
         -text $::caption(sophie,zoom)

         #--- Diminution du zoom
         ArrowButton $frm.zoom.butMin -borderwidth 1 -dir left -relief raised \
            -command "::sophie::incrementZoom"
         pack $frm.zoom.butMin -in [ $frm.zoom getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

         #--- Entry pour la consigne du zoom
         entry $frm.zoom.entry \
            -background $::color(white) -state readonly -takefocus 0 \
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
         -text $::caption(sophie,attenuateur)

         #--- Label blanc
         label $frm.attenuateur.labMin_color_invariant -text "  " -background $::color(white)
         pack $frm.attenuateur.labMin_color_invariant -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 0 -fill none -side left

         Button $frm.attenuateur.butMin -borderwidth 1 -relief raised -text "-"
         pack $frm.attenuateur.butMin -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

         #--- Entry pour la consigne de l'attenuateur
         entry $frm.attenuateur.entry \
            -background $::color(white) -state readonly -takefocus 0 \
            -textvariable ::sophie::private(attenuateur) -width 4 -justify center
         pack $frm.attenuateur.entry -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 0 -fill none -side left

         Button $frm.attenuateur.butMax -borderwidth 1 -relief raised -text "+"
         pack $frm.attenuateur.butMax -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 1 -fill x -ipady 2 -side left

         bind $frm.attenuateur.butMin <ButtonPress-1>   "::sophie::startMoveFilter -"
         bind $frm.attenuateur.butMin <ButtonRelease-1> "::sophie::stopMoveFilter"
         bind $frm.attenuateur.butMax <ButtonPress-1>   "::sophie::startMoveFilter +"
         bind $frm.attenuateur.butMax <ButtonRelease-1> "::sophie::stopMoveFilter"

         #--- Label noir
         label $frm.attenuateur.labMax_color_invariant -text "  " -background $::color(black)
         pack $frm.attenuateur.labMax_color_invariant -in [ $frm.attenuateur getframe ] \
            -anchor center -expand 0 -fill none -side left

      pack $frm.attenuateur -side top -fill x

      #--- Frame pour l'image
      TitleFrame $frm.image -borderwidth 2 -relief groove -text $::caption(sophie,image)

         #--- Bouton pour enregistrer l'image courante
         button $frm.image.but4 -borderwidth 2 -text $::caption(sophie,enregistrer) \
            -command "::sophie::saveImage"
         pack $frm.image.but4 -in [ $frm.image getframe ] -anchor center \
            -expand 0 -fill x -ipady 2 -padx 2 -pady 2

         #--- Bouton pour visualiser une image
         button $frm.image.but5 -borderwidth 2 -text $::caption(sophie,voirImage) \
            -command "::sophie::showImage"
         pack $frm.image.but5 -in [ $frm.image getframe ] -anchor center \
            -expand 0 -fill x -ipady 2 -padx 2 -pady 2

      pack $frm.image -side top -fill x

      #--- Frame pour enregistrer et voir les images capturees
      TitleFrame $frm.processus -borderwidth 2 -relief groove -text $::caption(sophie,controle)

         #--- Bouton pour enregistrer l'image courante
         button $frm.processus.but5 -borderwidth 2 -text $::caption(sophie,imagesEtapes) \
            -command "::sophie::view::run $visuNo"
         pack $frm.processus.but5 -in [ $frm.processus getframe ] -anchor center \
            -expand 0 -fill x -ipady 2 -padx 2 -pady 2

      pack $frm.processus -side top -fill x

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

   #--- je cree les bind pour les items "::sophie"
   $private(hCanvas) bind "::sophie"  <ButtonPress-1>  "::sophie::onMousePressButton1 $visuNo %W %x %y"
   $private(hCanvas) bind "::sophie"  <B1-Motion>      "::sophie::onMouseMoveButton1  $visuNo %W %x %y"
   $private(hCanvas) bind "::sophie" <ButtonRelease-1> "::sophie::onMouseReleaseButton1 $visuNo %W %x %y"
   #--- je surcharge le double clic sur l'image du canvas pour deplacer la cible a la position de la souris 
   ::confVisu::createBindCanvas $visuNo <Double-Button-1> "::sophie::onTargetCoord $visuNo %x %y; break"
   
   #--- j'active la mise a jour automatique de l'affichage quand on change de camera
   ::confVisu::addCameraListener $visuNo "::sophie::adaptPanel $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
   ::confVisu::addZoomListener $visuNo "::sophie::onChangeZoom $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de fenetrage
   ::confVisu::addSubWindowListener $visuNo "::sophie::onChangeSubWindow $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de miroir
   ::confVisu::addMirrorListener $visuNo "::sophie::onChangeSubWindow $visuNo"

   #--- j'adapte l'affichage de l'outil
   adaptPanel $visuNo

   #--- Ouverture de la fenetre de controle de l'interface
   ::sophie::showControlWindow $visuNo
   #--- je mets à jour le mode
   ::sophie::setMode $private(mode)
   #--- je mets a jour le mode de guidage
   ::sophie::setGuidingMode $visuNo
   #--- j'affiche la cible sur l'image
   ::sophie::createTarget $visuNo
   #--- j'affiche la consigne sur l'image
   createOrigin $visuNo


   set catchError [ catch {
      #--- j'ouvre la liaison pour recevoir les commandes du PC Sophie
      ::sophie::spectro::openSocket
   }]
   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }
   
   #--- j'intialise la paosition de l'attenuateur 
   ::sophie::initFilter

   #--- je selectionne les mots clefs optionnel a ajouter dans les images
   ::keyword::selectKeywords $visuNo [list RA_MEAN RA_RMS DEC_MEAN DEC_RMS DETNAM INSTRUME TELESCOP SITENAME SITELONG SITELAT SWCREATE]
   #--- je selectionne la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo [list RA_MEAN RA_RMS DEC_MEAN DEC_RMS DETNAM INSTRUME TELESCOP ]
   
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

   set catchError [ catch {
      #--- je ferme la liaison du PC Sophie
      ::sophie::spectro::closeSocket
   }]
   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }


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

   #--- je supprime les binds des items "::sophie"
   $private(hCanvas) bind "::sophie"  <ButtonPress-1>     "default"
   $private(hCanvas) bind "::sophie"  <B1-Motion>         "default"
   $private(hCanvas) bind "::sophie"  <ButtonRelease-1>   "default"
   $private(hCanvas) bind "::sophie"  <ButtonPress-3>     "default"
   #--- je restaure le bind du canvas 
   ::confVisu::createBindCanvas $visuNo <Double-Button-1> "default"
   
   #--- je ferme la fenetre de controle
   ::sophie::control::closeWindow $visuNo

   #--- je masque le panneau
   pack forget $private(frm)
}

