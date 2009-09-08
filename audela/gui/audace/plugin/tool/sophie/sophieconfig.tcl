##------------------------------------------------------------
# @file     sophieconfig.tcl
# @brief    Fichier du namespace ::sophie::config
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophieconfig.tcl,v 1.17 2009-09-08 16:59:35 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @brief   configuration de l'outil sophie
#
#------------------------------------------------------------
namespace eval ::sophie::config {

}

#------------------------------------------------------------
# run
#    affiche la fenetre du configuration
#------------------------------------------------------------
proc ::sophie::config::run { visuNo tkbase  } {
   variable private

   #--- Initialisation de variables
   set private(frm) "$::audace(base).sophieconfig"

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,configWindowPosition) ] } { set ::conf(sophie,configWindowPosition) "450x540+565+160" }

   #--- j'affiche la fenetre
   ::confGenerique::run $visuNo $private(frm) "::sophie::config" -modal 0 -geometry $::conf(sophie,configWindowPosition) -resizable 1

   #--- je deplace la consigne a la position du mode courant de la fibre
   ###onFiberMode $visuNo
}

#------------------------------------------------------------
# closeWindow
#   ferme la fenetre
#------------------------------------------------------------
proc ::sophie::config::closeWindow { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(sophie,configWindowPosition) [ winfo geometry [ winfo toplevel $private(frm) ] ]
}

#------------------------------------------------------------
# showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::sophie::config::showHelp { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory \
      [ ::sophie::getPluginType ] ] [ ::sophie::getPluginDirectory ] [ ::sophie::getPluginHelp ]
}

#------------------------------------------------------------
# getLabel
#   retourne le nom de la fenetre de traitement
#------------------------------------------------------------
proc ::sophie::config::getLabel { } {
   return "$::caption(sophie,titre) - $::caption(sophie,config)"
}

#------------------------------------------------------------
# fillConfigPage
#   cree les widgets de la fenetre de configuration du traitement
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillConfigPage { frm visuNo } {
   variable private

   set private(frm) $frm

   #--- Je positionne la fenetre
   wm geometry [ winfo toplevel $frm ] $::conf(sophie,configWindowPosition)

   #--- Creation des onglets
   set notebook [ NoteBook $frm.notebook ]
      $notebook insert end "configuration" -text $::caption(sophie,parametreConfig)
      $notebook insert end "algorithme"    -text $::caption(sophie,parametreAlgo)
     ### $notebook insert end "callibration"  -text $::caption(sophie,callibrationRappels)
   pack $frm.notebook -side top -fill both -expand 1

   #--- j'affiche les wigdets dans les onglets
   fillConfigurationPage [ $notebook getframe "configuration" ] 1
   fillAlgorithmePage    [ $notebook getframe "algorithme" ] 1
  ### fillCallibrationPage  [ $notebook getframe "callibration" ] 1

   pack $frm -side top -fill x -expand 1

   #--- je selectionne le premier onglet
   $notebook raise "configuration"
}

#------------------------------------------------------------
# fillConfigurationPage
#   cree les widgets dans l'onglet configuration generale
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillConfigurationPage { frm visuNo } {
   variable private
   variable widget

   #--- j'initalise les variables des widgets
  ### set widget(poseDefaut)            $::conf(sophie,exposure)
   set widget(binCentrageDefaut)     $::conf(sophie,centerBinning)
   set widget(binFocalisationDefaut) $::conf(sophie,focuseBinning)
   set widget(binGuidageDefaut)      $::conf(sophie,guideBinning)
   set widget(echelle)               $::conf(sophie,pixelScale)
   set widget(nbPosesAvantCorrect)   $::conf(sophie,correctionCumulNb)
   set widget(nbPosesAvantMaj)       $::conf(sophie,originSumNb)
   set widget(tailleFenetreGuidage)  $::conf(sophie,guidingWindowSize)
   set widget(tailleFenetreCentrage) $::conf(sophie,centerWindowSize)
   set widget(alphaProportionalGain) [expr $::conf(sophie,alphaProportionalGain) * 100.0]
   set widget(deltaProportionalGain) [expr $::conf(sophie,deltaProportionalGain) * 100.0]
   set widget(alphaIntegralGain)     [expr $::conf(sophie,alphaIntegralGain) * 100.0]
   set widget(deltaIntegralGain)     [expr $::conf(sophie,deltaIntegralGain) * 100.0]
   set widget(minMaxDiff)            $::conf(sophie,minMaxDiff)

   set widget(prefixeImageCentrage)  $::conf(sophie,centerFileNameprefix)
   set widget(prefixeImageGuidage)   $::conf(sophie,guidingFileNameprefix)

  ### set widget(fiberGuigindMode)      $::conf(sophie,fiberGuigindMode)
   set widget(fiberHRX)              $::conf(sophie,fiberHRX)
   set widget(fiberHRY)              $::conf(sophie,fiberHRY)
   set widget(fiberHEX)              $::conf(sophie,fiberHEX)
   set widget(fiberHEY)              $::conf(sophie,fiberHEY)

   set widget(biasFileName,1,slow)   $::conf(sophie,biasFileName,1,slow)
   set widget(biasFileName,1,fast)   $::conf(sophie,biasFileName,1,fast)
   set widget(biasFileName,2,slow)   $::conf(sophie,biasFileName,2,slow)
   set widget(biasFileName,2,fast)   $::conf(sophie,biasFileName,2,fast)
   set widget(biasFileName,3,slow)   $::conf(sophie,biasFileName,3,slow)
   set widget(biasFileName,3,fast)   $::conf(sophie,biasFileName,3,fast)

   #--- Frame pour la configuration des acquisitions
   TitleFrame $frm.acq -borderwidth 2 -relief ridge -text $::caption(sophie,parametreAcquisition)

     ### #--- Temps de pose par defaut
     ### label $frm.acq.labelpose -text $::caption(sophie,poseDefaut)
     ### grid $frm.acq.labelpose -in [ $frm.acq getframe ] -row 0 -column 0 -sticky w

     ### ComboBox $frm.acq.valeurpose \
     ###    -width [ ::tkutil::lgEntryComboBox $::sophie::private(listePose) ] \
     ###    -height [ llength $::sophie::private(listePose) ] \
     ###    -justify center            \
     ###    -relief sunken             \
     ###    -borderwidth 1             \
     ###    -textvariable ::sophie::config::widget(poseDefaut) \
     ###    -editable 1                \
     ###    -values $::sophie::private(listePose)
     ### grid $frm.acq.valeurpose -in [ $frm.acq getframe ] -row 0 -column 1 -sticky ens

      #--- Binning par defaut du mode centrage
      label $frm.acq.labelbincentrage -text $::caption(sophie,binningCentrage) -justify left
      grid $frm.acq.labelbincentrage -in [ $frm.acq getframe ] -row 1 -column 0 -sticky w

      ComboBox $frm.acq.valeurbincentrage \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binCentrageDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.acq.valeurbincentrage -in [ $frm.acq getframe ] -row 1 -column 1 -sticky ens

      #--- Binning par defaut du mode focalisation
      label $frm.acq.labelbinfocalisation -text $::caption(sophie,binningFocalisation) -justify left
      grid $frm.acq.labelbinfocalisation -in [ $frm.acq getframe ] -row 2 -column 0 -sticky w

      ComboBox $frm.acq.valeurbinfocalisation \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binFocalisationDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.acq.valeurbinfocalisation -in [ $frm.acq getframe ] -row 2 -column 1 -sticky ens

      #--- Binning par defaut du mode guidage
      label $frm.acq.labelbinguidage -text $::caption(sophie,binningGuidage) -justify left
      grid $frm.acq.labelbinguidage -in [ $frm.acq getframe ] -row 3 -column 0 -sticky w

      ComboBox $frm.acq.valeurbinguidage \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binGuidageDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.acq.valeurbinguidage -in [ $frm.acq getframe ] -row 3 -column 1 -sticky ens

   pack $frm.acq -side top -anchor w -fill x -expand 0

   #--- Frame pour la configuration du guidage
   TitleFrame $frm.guidage -borderwidth 2 -relief ridge -text $::caption(sophie,parametreGuidage)

      #--- Echelle
      label $frm.guidage.labelechelle -text $::caption(sophie,echelle)
      grid $frm.guidage.labelechelle -in [ $frm.guidage getframe ] -row 0 -column 0 -sticky w

      Entry $frm.guidage.entryechelle \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(echelle)
      grid $frm.guidage.entryechelle -in [ $frm.guidage getframe ] -row 0 -column 1 -sticky ens

      #--- Nombre de poses avant la correction de guidage
      label $frm.guidage.labelnbPosesAvantCorrect -text $::caption(sophie,nbPosesAvantCorrect)
      grid $frm.guidage.labelnbPosesAvantCorrect -in [ $frm.guidage getframe ] -row 1 -column 0 -sticky w

      Entry $frm.guidage.entrynbPosesAvantCorrect \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(nbPosesAvantCorrect)
      grid $frm.guidage.entrynbPosesAvantCorrect -in [ $frm.guidage getframe ] -row 1 -column 1 -sticky ens

      #--- Nombre de poses avant la mise � jour de la consigne
      label $frm.guidage.labelnbPosesAvantMaj -text $::caption(sophie,nbPosesAvantMaj)
      grid $frm.guidage.labelnbPosesAvantMaj -in [ $frm.guidage getframe ] -row 2 -column 0 -sticky w

      Entry $frm.guidage.entrynbPosesAvantMaj \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(nbPosesAvantMaj)
      grid $frm.guidage.entrynbPosesAvantMaj -in [ $frm.guidage getframe ] -row 2 -column 1 -sticky ens

      #--- Taille de la fenetre de centrage
      label $frm.guidage.labeltailleFenetreCentrage -text $::caption(sophie,tailleFenetreCentrage)
      grid $frm.guidage.labeltailleFenetreCentrage -in [ $frm.guidage getframe ] -row 3 -column 0 -sticky w

      Entry $frm.guidage.entrytailleFenetreCentrage \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(tailleFenetreCentrage)
      grid $frm.guidage.entrytailleFenetreCentrage -in [ $frm.guidage getframe ] -row 3 -column 1 -sticky ens

      #--- Taille de la fenetre de guidage
      label $frm.guidage.labeltailleFenetreGuidage -text $::caption(sophie,tailleFenetreGuidage)
      grid $frm.guidage.labeltailleFenetreGuidage -in [ $frm.guidage getframe ] -row 4 -column 0 -sticky w

      Entry $frm.guidage.entrytailleFenetreGuidage \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(tailleFenetreGuidage)
      grid $frm.guidage.entrytailleFenetreGuidage -in [ $frm.guidage getframe ] -row 4 -column 1 -sticky ens

      #--- Gain proportionnel
      label $frm.guidage.labelGainAlpha -text $::caption(sophie,alpha)
      grid $frm.guidage.labelGainAlpha -in [ $frm.guidage getframe ] -row 5 -column 1 -sticky we

      label $frm.guidage.labelGainDelta -text $::caption(sophie,delta)
      grid $frm.guidage.labelGainDelta -in [ $frm.guidage getframe ] -row 5 -column 2 -sticky we

      label $frm.guidage.labelgainProportionnel -text $::caption(sophie,gainProportionnel)
      grid $frm.guidage.labelgainProportionnel -in [ $frm.guidage getframe ] -row 6 -column 0 -sticky w

      Entry $frm.guidage.entryAlphaProportionalGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(alphaProportionalGain)
      grid $frm.guidage.entryAlphaProportionalGain -in [ $frm.guidage getframe ] -row 6 -column 1 -sticky ens

      Entry $frm.guidage.entryDeltaProportionalGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(deltaProportionalGain)
      grid $frm.guidage.entryDeltaProportionalGain -in [ $frm.guidage getframe ] -row 6 -column 2 -sticky ens

      #--- Gain integrateur
      label $frm.guidage.labelgainIntegrateur -text $::caption(sophie,gainIntegrateur)
      grid $frm.guidage.labelgainIntegrateur -in [ $frm.guidage getframe ] -row 7 -column 0 -sticky w

      Entry $frm.guidage.entryAlphaIntegralGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(alphaIntegralGain)
      grid $frm.guidage.entryAlphaIntegralGain -in [ $frm.guidage getframe ] -row 7 -column 1 -sticky ens

      Entry $frm.guidage.entryDeltaIntegralGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(deltaIntegralGain)
      grid $frm.guidage.entryDeltaIntegralGain -in [ $frm.guidage getframe ] -row 7 -column 2 -sticky ens

      #--- Ecart min max
      label $frm.guidage.labelEcartMinMax -text $::caption(sophie,ecartMinMax)
      grid $frm.guidage.labelEcartMinMax -in [ $frm.guidage getframe ] -row 8 -column 0 -sticky w

      Entry $frm.guidage.entryEcartMinMax \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(minMaxDiff)
      grid $frm.guidage.entryEcartMinMax -in [ $frm.guidage getframe ] -row 8 -column 1 -sticky ens

   pack $frm.guidage -side top -anchor w -fill x -expand 0

   #--- Frame pour la position des fibres
   TitleFrame $frm.fibre -borderwidth 2 -relief ridge -text $::caption(sophie,positionFibres)

      label $frm.fibre.xLabel -text "X"
      grid $frm.fibre.xLabel -in [ $frm.fibre getframe ] -row 0 -column 1 -sticky we
      label $frm.fibre.yLabel -text "Y"
      grid $frm.fibre.yLabel -in [ $frm.fibre getframe ] -row 0 -column 2 -sticky we

      #--- Fibre A HR
      label $frm.fibre.labelfibreAHR -text $::caption(sophie,fibreAHR)
      grid $frm.fibre.labelfibreAHR -in [ $frm.fibre getframe ] -row 1 -column 0 -sticky w

      Entry $frm.fibre.spinboxfiberHRX \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHRX)
      grid $frm.fibre.spinboxfiberHRX -in [ $frm.fibre getframe ] -row 1 -column 1 -sticky ens

      Entry $frm.fibre.spinboxfiberHRY \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHRY)
      grid $frm.fibre.spinboxfiberHRY -in [ $frm.fibre getframe ] -row 1 -column 2 -sticky ens

      Button $frm.fibre.replaceOriginHR -text $::caption(sophie,replaceOriginValue) \
         -command "::sophie::config::replaceOriginCoordinates $visuNo HR"
      grid $frm.fibre.replaceOriginHR -in [ $frm.fibre getframe ] -row 1 -column 3 -sticky ens  -padx 2

      #--- Fibre A HE
      label $frm.fibre.labelfibreAHE -text $::caption(sophie,fibreAHE)
      grid $frm.fibre.labelfibreAHE -in [ $frm.fibre getframe ] -row 2 -column 0 -sticky w

      Entry $frm.fibre.spinboxfiberHEX \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHEX)
      grid $frm.fibre.spinboxfiberHEX -in [ $frm.fibre getframe ] -row 2 -column 1 -sticky ens

      Entry $frm.fibre.spinboxfiberHEY \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHEY)
      grid $frm.fibre.spinboxfiberHEY -in [ $frm.fibre getframe ] -row 2 -column 2 -sticky ens

      Button $frm.fibre.replaceOriginHE -text $::caption(sophie,replaceOriginValue) \
         -command "::sophie::config::replaceOriginCoordinates $visuNo HE"
      grid $frm.fibre.replaceOriginHE -in [ $frm.fibre getframe ] -row 2 -column 3 -sticky ens  -padx 2


      #--- Fibre B
      label $frm.fibre.labelfibreB -text $::caption(sophie,fibreB)
      grid $frm.fibre.labelfibreB -in [ $frm.fibre getframe ] -row 3 -column 0 -sticky w

      Entry $frm.fibre.spinboxxfibreB\
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(xfibreB)
      grid $frm.fibre.spinboxxfibreB -in [ $frm.fibre getframe ] -row 3 -column 1 -sticky ens

      Entry $frm.fibre.spinboxyfibreB\
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(yfibreB)
      grid $frm.fibre.spinboxyfibreB -in [ $frm.fibre getframe ] -row 3 -column 2 -sticky ens


      #--- Mode d'entree de la fibre A
      ###label $frm.fibre.labelfiberGuigindMode -text $::caption(sophie,fiberGuigindMode)
      ###grid $frm.fibre.labelfiberGuigindMode -in [ $frm.fibre getframe ] -row 3 -column 1 -sticky w
      ###
      ###radiobutton $frm.fibre.fiberGuigindModeHR -highlightthickness 0 -padx 0 -pady 0 -state normal \
      ###   -text $::caption(sophie,HR) \
      ###   -value "HR" \
      ###   -variable ::sophie::config::widget(fiberGuigindMode)
      ###
      ###   ###-command "::sophie::config::onFiberMode $visuNo"
      ###
      ###grid $frm.fibre.fiberGuigindModeHR -in [ $frm.fibre getframe ] -row 3 -column 2 -sticky ens
      ###
      ###radiobutton $frm.fibre.fiberGuigindModeHE -highlightthickness 0 -padx 0 -pady 0 -state normal \
      ###   -text $::caption(sophie,HE) \
      ###   -value "HE" \
      ###   -variable ::sophie::config::widget(fiberGuigindMode)
      ###
      ###   ###-command "::sophie::config::onFiberMode $visuNo"
      ###grid $frm.fibre.fiberGuigindModeHE -in [ $frm.fibre getframe ] -row 3 -column 3 -sticky ens

   pack $frm.fibre -side top -anchor w -fill x -expand 0

   #--- Frame pour les images
   TitleFrame $frm.image -borderwidth 2 -relief ridge -text $::caption(sophie,images)

      #--- Repertoire des images
      label $frm.image.labelImageDirectory -text $::caption(sophie,imageDirectory)
      grid $frm.image.labelImageDirectory -in [ $frm.image getframe ] -row 0 -column 1 -sticky w

      Entry $frm.image.entryrepImages \
         -width 30 -justify left -editable 1 \
         -textvariable ::conf(sophie,imageDirectory)
      grid $frm.image.entryrepImages -in [ $frm.image getframe ] -row 0 -column 2 -sticky ew

      button $frm.image.configurerepImages -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::changeRepImages"
      grid $frm.image.configurerepImages -in [ $frm.image getframe ] -row 0 -column 3 -sticky e -padx 2

      #--- Prefixe des images de centrage
      label $frm.image.labelprefixeImageCentrage -text $::caption(sophie,prefixeImageCentrage)
      grid $frm.image.labelprefixeImageCentrage -in [ $frm.image getframe ] -row 1 -column 1 -sticky w

      Entry $frm.image.entryprefixeImageCentrage \
         -width 13 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageCentrage)
      grid $frm.image.entryprefixeImageCentrage -in [ $frm.image getframe ] -row 1 -column 2 -sticky ew

      #--- Prefixe des images de guidage
      label $frm.image.labelprefixeImageGuidage -text $::caption(sophie,prefixeImageGuidage)
      grid $frm.image.labelprefixeImageGuidage -in [ $frm.image getframe ] -row 2 -column 1 -sticky w

      Entry $frm.image.entryprefixeImageGuidage \
         -width 13 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageGuidage)
      grid $frm.image.entryprefixeImageGuidage -in [ $frm.image getframe ] -row 2 -column 2 -sticky ew

      #--- Valeur de Bias 1 Slow
      ### label $frm.image.labelImageBias1Slow -text "$::caption(sophie,imageBias,bin1Slow)"
      label $frm.image.labelImageBias1Slow -text "$::caption(sophie,valeurBias,bin1Slow)"
      grid $frm.image.labelImageBias1Slow -in [ $frm.image getframe ] -row 3 -column 1 -sticky w

      Entry $frm.image.entryImageBias1Slow \
         -width 30 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,1,slow)
      grid $frm.image.entryImageBias1Slow -in [ $frm.image getframe ] -row 3 -column 2 -sticky ew

      button $frm.image.configureimageBias1Slow -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::chooseBiasFile 1 slow"
      grid $frm.image.configureimageBias1Slow -in [ $frm.image getframe ] -row 3 -column 3 -sticky e -padx 2

      #--- Valeur de Bias 1 Fast
      ### label $frm.image.labelImageBias1Fast -text "$::caption(sophie,imageBias,bin1Fast)"
      label $frm.image.labelImageBias1Fast -text "$::caption(sophie,valeurBias,bin1Fast)"
      grid $frm.image.labelImageBias1Fast -in [ $frm.image getframe ] -row 4 -column 1 -sticky w

      Entry $frm.image.entryImageBias1Fast \
         -width 30 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,1,fast)
      grid $frm.image.entryImageBias1Fast -in [ $frm.image getframe ] -row 4 -column 2 -sticky ew

      button $frm.image.configureimageBias1Fast -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::chooseBiasFile 1 fast"
      grid $frm.image.configureimageBias1Fast -in [ $frm.image getframe ] -row 4 -column 3 -sticky e -padx 2

      #--- Valeur de Bias 2 Slow
      ### label $frm.image.labelImageBias2Slow -text "$::caption(sophie,imageBias,bin2Slow)"
      label $frm.image.labelImageBias2Slow -text "$::caption(sophie,valeurBias,bin2Slow)"
      grid $frm.image.labelImageBias2Slow -in [ $frm.image getframe ] -row 5 -column 1 -sticky w

      Entry $frm.image.entryImageBias2Slow \
         -width 30 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,2,slow)
      grid $frm.image.entryImageBias2Slow -in [ $frm.image getframe ] -row 5 -column 2 -sticky ew

      button $frm.image.configureimageBias2Slow -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::chooseBiasFile 2 slow"
      grid $frm.image.configureimageBias2Slow -in [ $frm.image getframe ] -row 5 -column 3 -sticky e -padx 2

      #--- Valeur de Bias 2 Fast
      ### label $frm.image.labelImageBias2Fast -text "$::caption(sophie,imageBias,bin2Fast)"
      label $frm.image.labelImageBias2Fast -text "$::caption(sophie,valeurBias,bin2Fast)"
      grid $frm.image.labelImageBias2Fast -in [ $frm.image getframe ] -row 6 -column 1 -sticky w

      Entry $frm.image.entryImageBias2Fast \
         -width 30 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,2,fast)
      grid $frm.image.entryImageBias2Fast -in [ $frm.image getframe ] -row 6 -column 2 -sticky ew

      button $frm.image.configureimageBias2Fast -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::chooseBiasFile 2 fast"
      grid $frm.image.configureimageBias2Fast -in [ $frm.image getframe ] -row 6 -column 3 -sticky e -padx 2

      grid columnconfigure [ $frm.image getframe ] 2 -weight 1

      #--- Valeur de Bias 3 Slow
      ### label $frm.image.labelImageBias3Slow -text "$::caption(sophie,imageBias,bin3Slow)"
      label $frm.image.labelImageBias3Slow -text "$::caption(sophie,valeurBias,bin3Slow)"
      grid $frm.image.labelImageBias3Slow -in [ $frm.image getframe ] -row 7 -column 1 -sticky w

      Entry $frm.image.entryImageBias3Slow \
         -width 30 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,3,slow)
      grid $frm.image.entryImageBias3Slow -in [ $frm.image getframe ] -row 7 -column 2 -sticky ew

      button $frm.image.configureimageBias3Slow -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::chooseBiasFile 3 slow"
      grid $frm.image.configureimageBias3Slow -in [ $frm.image getframe ] -row 7 -column 3 -sticky e -padx 2

      #--- Valeur de Bias 3 Fast
      ### label $frm.image.labelImageBias3Fast -text "$::caption(sophie,imageBias,bin3Fast)"
      label $frm.image.labelImageBias3Fast -text "$::caption(sophie,valeurBias,bin3Fast)"
      grid $frm.image.labelImageBias3Fast -in [ $frm.image getframe ] -row 8 -column 1 -sticky w

      Entry $frm.image.entryImageBias3Fast \
         -width 30 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,3,fast)
      grid $frm.image.entryImageBias3Fast -in [ $frm.image getframe ] -row 8 -column 2 -sticky ew

      button $frm.image.configureimageBias3Fast -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::chooseBiasFile 3 fast"
      grid $frm.image.configureimageBias3Fast -in [ $frm.image getframe ] -row 8 -column 3 -sticky e -padx 2

      grid columnconfigure [ $frm.image getframe ] 2 -weight 1

   pack $frm.image -side top -anchor w -fill x -expand 0
}

#------------------------------------------------------------
# fillAlgorithmePage
#   cree les widgets dans l'onglet configuration de l'algorithme
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillAlgorithmePage { frm visuNo } {
   variable private

   #--- Frame pour les parametres du masque
   TitleFrame $frm.paraMasque -borderwidth 2 -relief ridge -text $::caption(sophie,paraMasque)

      #--- Diametre du masque
      label $frm.paraMasque.labeldiametreMasque -text $::caption(sophie,diametreMasque)
      grid $frm.paraMasque.labeldiametreMasque -in [ $frm.paraMasque getframe ]\
         -row 0 -column 1 -sticky w

      Entry $frm.paraMasque.entrydiametreMasque \
         -width 8 -justify center -editable 1 \
         -textvariable ::conf(sophie,maskRadius)
      grid $frm.paraMasque.entrydiametreMasque -in [ $frm.paraMasque getframe ] \
         -row 0 -column 2 -sticky ens

      #--- Largeur de la gaussienne du masque
      label $frm.paraMasque.labellargeurGaussMasque -text $::caption(sophie,largeurGaussMasque)
      grid $frm.paraMasque.labellargeurGaussMasque -in [ $frm.paraMasque getframe ] \
         -row 1 -column 1 -sticky w

      Entry $frm.paraMasque.entrylargeurGaussMasque \
         -width 8 -justify center -editable 1 \
         -textvariable ::conf(sophie,maskFwhm)
      grid $frm.paraMasque.entrylargeurGaussMasque -in [ $frm.paraMasque getframe ] \
         -row 1 -column 2 -sticky ens

      #--- Nombre minimal de pixels
      label $frm.paraMasque.labelseuilMini -text $::caption(sophie,seuilMini)
      grid $frm.paraMasque.labelseuilMini -in [ $frm.paraMasque getframe ] \
         -row 2 -column 1 -sticky w

      Entry $frm.paraMasque.entryseuilMini \
         -width 8 -justify center -editable 1 \
         -textvariable ::conf(sophie,pixelMinCount)
      grid $frm.paraMasque.entryseuilMini -in [ $frm.paraMasque getframe ] \
         -row 2 -column 2 -sticky ens

   pack $frm.paraMasque -side top -anchor w -fill x -expand 0

   #--- Frame pour les parametres de la pr�cision du guidage
   TitleFrame $frm.paraPrecisionCentrage -borderwidth 2 -relief ridge \
      -text $::caption(sophie,paraPrecisionCentrage)

      #--- Precision du centrage
      label $frm.paraPrecisionCentrage.labelprecisionCentrage -text $::caption(sophie,precisionCentrage)
      grid $frm.paraPrecisionCentrage.labelprecisionCentrage -in [ $frm.paraPrecisionCentrage getframe ] \
         -row 0 -column 1 -sticky w

      Entry $frm.paraPrecisionCentrage.entryprecisionCentrage \
         -width 8 -justify center -editable 1 \
         -textvariable ::conf(sophie,centerMaxLimit)
      grid $frm.paraPrecisionCentrage.entryprecisionCentrage -in [ $frm.paraPrecisionCentrage getframe ] \
         -row 0 -column 2 -sticky ens

   pack $frm.paraPrecisionCentrage -side top -anchor w -fill x -expand 0
}

#------------------------------------------------------------
# fillCallibrationPage
#   cree les widgets dans l'onglet callibration
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillCallibrationPage { frm visuNo } {
   variable private

}

#----------------------------------------------------------------------------
# apply
#    met � jour les variables et les widgets quand on applique les modifications d'une configuration
#----------------------------------------------------------------------------
proc ::sophie::config::apply { visuNo } {
   variable widget


   #--- je controle les valeurs saisies
   ### � compl�ter ...

   #--- j'initalise les variables des widgets
  ### set ::conf(sophie,exposure)              $widget(poseDefaut)
   set ::conf(sophie,centerBinning)         $widget(binCentrageDefaut)
   set ::conf(sophie,focuseBinning)         $widget(binFocalisationDefaut)
   set ::conf(sophie,guideBinning)          $widget(binGuidageDefaut)
   set ::conf(sophie,pixelScale)            $widget(echelle)
   set ::conf(sophie,correctionCumulNb)     $widget(nbPosesAvantCorrect)
   set ::conf(sophie,originSumNb)           $widget(nbPosesAvantMaj)
   set ::conf(sophie,guidingWindowSize)     $widget(tailleFenetreGuidage)
   set ::conf(sophie,centerWindowSize)      $widget(tailleFenetreCentrage)
   set ::conf(sophie,alphaProportionalGain) [expr double($widget(alphaProportionalGain)) / 100.0]
   set ::conf(sophie,deltaProportionalGain) [expr double($widget(deltaProportionalGain)) / 100.0]
   set ::conf(sophie,alphaIntegralGain)     [expr double($widget(alphaIntegralGain)) / 100.0]
   set ::conf(sophie,deltaIntegralGain)     [expr double($widget(deltaIntegralGain)) / 100.0]
   set ::conf(sophie,minMaxDiff)            $widget(minMaxDiff)
   set ::conf(sophie,centerFileNameprefix)  $widget(prefixeImageCentrage)
   set ::conf(sophie,guidingFileNameprefix) $widget(prefixeImageGuidage)

  ### set ::conf(sophie,fiberGuigindMode)      $widget(fiberGuigindMode)
   set ::conf(sophie,fiberHRX)               $widget(fiberHRX)
   set ::conf(sophie,fiberHRY)               $widget(fiberHRY)
   set ::conf(sophie,fiberHEX)               $widget(fiberHEX)
   set ::conf(sophie,fiberHEY)               $widget(fiberHEY)

   set ::conf(sophie,biasFileName,1,slow)    $widget(biasFileName,1,slow)
   set ::conf(sophie,biasFileName,1,fast)    $widget(biasFileName,1,fast)
   set ::conf(sophie,biasFileName,2,slow)    $widget(biasFileName,2,slow)
   set ::conf(sophie,biasFileName,2,fast)    $widget(biasFileName,2,fast)
   set ::conf(sophie,biasFileName,3,slow)    $widget(biasFileName,3,slow)
   set ::conf(sophie,biasFileName,3,fast)    $widget(biasFileName,3,fast)

   #--- je communique les nouveaux parametres au thread de la camera
   ::camera::setAsynchroneParameter $::sophie::private(camItem)\
         "alphaProportionalGain"    $::conf(sophie,alphaProportionalGain) \
         "deltaProportionalGain"    $::conf(sophie,deltaProportionalGain) \
         "alphaIntegralGain"        $::conf(sophie,alphaIntegralGain) \
         "deltaIntegralGain"        $::conf(sophie,deltaIntegralGain) \
         "originSumNb"              $::conf(sophie,originSumNb)

   #---  je re-positionne la consigne
   ::sophie::setGuidingMode $visuNo
   #--- j'applique le mode courant pour prendre en compte les nouvelles valeurs des parametres
   ::sophie::setMode
   #--- je met a jour la fenetre de controle
   ::sophie::control::setMinMaxDiff $::conf(sophie,minMaxDiff)

}

#------------------------------------------------------------
# changeRepImages
#    ouvre le navigateur pour choisir le repertoire des images
#------------------------------------------------------------
proc ::sophie::config::changeRepImages { } {
   variable private

   set initialdir $::conf(sophie,imageDirectory)
   set title $::caption(sophie,imageDirectory)
   set ::conf(sophie,imageDirectory) [ ::sophie::config::chooseDir $initialdir $title $private(frm) ]
}

#------------------------------------------------------------
# chooseDir
#    navigateur pour le choix des repertoires
#------------------------------------------------------------
proc ::sophie::config::chooseDir { inidir title parent } {
   if {$inidir=="."} {
      set inidir [pwd]
   }
   set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]
   if {$res==""} {
      return "$inidir"
   } else {
      return "$res"
   }
}

#------------------------------------------------------------
# choseBiasFile
#    choisi le nom de l'image de bias
# @param  cameraBinning  binning de la camera
# @param  cameraMode     mode de la camera
# @return rien
#------------------------------------------------------------
proc ::sophie::config::chooseBiasFile { cameraBinning cameraMode } {
   variable widget

   #--- Ouvre la fenetre de choix des images
   set widget(biasFileName,$cameraBinning,$cameraMode) [ ::tkutil::box_load $::private(frm) $::audace(rep_images) $::audace(bufNo) "1" ]
}

#------------------------------------------------------------
# onScroll
#    scroll de la consigne
#------------------------------------------------------------
###proc ::sophie::config::onScroll { visuNo name  args } {
###   variable widget
###
###   switch $name {
###      "fiberHRX" -
###      "fiberHRY" {
###         set ::sophie::private(originCoord) [list $widget(fiberHRX) $widget(fiberHRY)]
###         ::sophie::createOrigin $visuNo
###      }
###      "fiberHEX" -
###      "fiberHEY" {
###         set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
###         ::sophie::createOrigin $visuNo
###      }
###      "fiberBX" -
###      "fiberBY" {
###         ###set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
###         ###::sophie::createFiberB $visuNo
###      }
###   }
###}

#------------------------------------------------------------
# onFiberMode
#   change le mode
#------------------------------------------------------------
###proc ::sophie::config::onFiberMode { visuNo args } {
###   variable widget
###
###   switch $widget(fiberGuigindMode) {
###      "HR" {
###         set ::sophie::private(originCoord) [list $widget(fiberHRX) $widget(fiberHRY)]
###         ::sophie::createOrigin $visuNo
###      }
###      "HE" {
###         set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
###         ::sophie::createOrigin $visuNo
###      }
###   }
###
###}

#------------------------------------------------------------
# replaceOriginValue
#   remplace la position de la consigne par la position courante de la consigne
# @param numero de la visu
# @param type de position (HR ou HE)
# @return rien
#------------------------------------------------------------
proc ::sophie::config::replaceOriginCoordinates { visuNo positionType } {
   variable widget

   switch $positionType {
      "HR" {
         set widget(fiberHRX) [lindex $::sophie::private(originCoord) 0]
         set widget(fiberHRY) [lindex $::sophie::private(originCoord) 1]
      }
      "HE" {
         set widget(fiberHEX) [lindex $::sophie::private(originCoord) 0]
         set widget(fiberHEY) [lindex $::sophie::private(originCoord) 1]
      }
   }
}



