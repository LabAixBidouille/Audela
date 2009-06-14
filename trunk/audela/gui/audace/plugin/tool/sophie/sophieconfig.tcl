#
# Fichier : sophieconfig.tcl
# Description : Fenetre de configuration de l'instrument Sophie
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophieconfig.tcl,v 1.9 2009-06-14 08:53:39 robertdelmas Exp $
#

#============================================================
# Declaration du namespace sophie::config
#    initialise le namespace
#============================================================
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
   onFiberMode $visuNo
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
      $notebook insert end "callibration"  -text $::caption(sophie,callibrationRappels)
   pack $frm.notebook -side top -fill both -expand 1

   #--- j'affiche les wigdets dans les onglets
   fillConfigurationPage [ $notebook getframe "configuration" ] 1
   fillAlgorithmePage    [ $notebook getframe "algorithme" ] 1
   fillCallibrationPage  [ $notebook getframe "callibration" ] 1

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
   set widget(poseDefaut)            $::conf(sophie,exposure)
   set widget(binCentrageDefaut)     $::conf(sophie,centerBinning)
   set widget(binGuidageDefaut)      $::conf(sophie,guideBinning)
   set widget(echelle)               $::conf(sophie,pixelScale)
   set widget(nbPosesAvantCorrect)   $::conf(sophie,correctionCumulNb)
   set widget(nbPosesAvantMaj)       $::conf(sophie,originSumNb)
   set widget(tailleFenetreGuidage)  $::conf(sophie,guidingWindowSize)
   set widget(tailleFenetreCentrage) $::conf(sophie,centerWindowSize)
   set widget(gainProportionnel)     [expr $::conf(sophie,proportionalGain) * 100.0]
   set widget(gainIntegrateur)       [expr $::conf(sophie,integralGain) * 100.0]
   set widget(prefixeImageCentrage)  $::conf(sophie,centerFileNameprefix)
   set widget(prefixeImageGuidage)   $::conf(sophie,guidingFileNameprefix)

   set widget(fiberGuigindMode)      $::conf(sophie,fiberGuigindMode)
   set widget(fiberHRX)              $::conf(sophie,fiberHRX)
   set widget(fiberHRY)              $::conf(sophie,fiberHRY)
   set widget(fiberHEX)              $::conf(sophie,fiberHEX)
   set widget(fiberHEY)              $::conf(sophie,fiberHEY)

   #--- Frame pour la configuration des acquisitions
   TitleFrame $frm.acq -borderwidth 2 -relief ridge -text $::caption(sophie,parametreAcquisition)

      #--- Poses par defaut
      label $frm.acq.labelpose -text $::caption(sophie,poseDefaut)
      grid $frm.acq.labelpose -in [ $frm.acq getframe ] -row 0 -column 0 -sticky w

      ComboBox $frm.acq.valeurpose \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listePose) ] \
         -height [ llength $::sophie::private(listePose) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(poseDefaut) \
         -editable 1                \
         -values $::sophie::private(listePose)
      grid $frm.acq.valeurpose -in [ $frm.acq getframe ] -row 0 -column 1 -sticky ens

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

      #--- Binning par defaut du mode centrage
      label $frm.acq.labelbinguidage -text $::caption(sophie,binningGuidage) -justify left
      grid $frm.acq.labelbinguidage -in [ $frm.acq getframe ] -row 2 -column 0 -sticky w

      ComboBox $frm.acq.valeurbinguidage \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binGuidageDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.acq.valeurbinguidage -in [ $frm.acq getframe ] -row 2 -column 1 -sticky ens

   pack $frm.acq -side top -anchor w -fill x -expand 0

   #--- Frame pour la configuration du guidage
   TitleFrame $frm.guidage -borderwidth 2 -relief ridge -text $::caption(sophie,parametreGuidage)

      #--- Echelle
      label $frm.guidage.labelechelle -text $::caption(sophie,echelle)
      grid $frm.guidage.labelechelle -in [ $frm.guidage getframe ] -row 0 -column 1 -sticky w

      Entry $frm.guidage.entryechelle \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(echelle)
      grid $frm.guidage.entryechelle -in [ $frm.guidage getframe ] -row 0 -column 2 -sticky ens

      #--- Nombre de poses avant la correction de guidage
      label $frm.guidage.labelnbPosesAvantCorrect -text $::caption(sophie,nbPosesAvantCorrect)
      grid $frm.guidage.labelnbPosesAvantCorrect -in [ $frm.guidage getframe ] -row 1 -column 1 -sticky w

      Entry $frm.guidage.entrynbPosesAvantCorrect \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(nbPosesAvantCorrect)
      grid $frm.guidage.entrynbPosesAvantCorrect -in [ $frm.guidage getframe ] -row 1 -column 2 -sticky ens

      #--- Nombre de poses avant la mise à jour de la consigne
      label $frm.guidage.labelnbPosesAvantMaj -text $::caption(sophie,nbPosesAvantMaj)
      grid $frm.guidage.labelnbPosesAvantMaj -in [ $frm.guidage getframe ] -row 2 -column 1 -sticky w

      Entry $frm.guidage.entrynbPosesAvantMaj \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(nbPosesAvantMaj)
      grid $frm.guidage.entrynbPosesAvantMaj -in [ $frm.guidage getframe ] -row 2 -column 2 -sticky ens

      #--- Taille de la fenetre de centrage
      label $frm.guidage.labeltailleFenetreCentrage -text $::caption(sophie,tailleFenetreCentrage)
      grid $frm.guidage.labeltailleFenetreCentrage -in [ $frm.guidage getframe ] -row 3 -column 1 -sticky w

      Entry $frm.guidage.entrytailleFenetreCentrage \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(tailleFenetreCentrage)
      grid $frm.guidage.entrytailleFenetreCentrage -in [ $frm.guidage getframe ] -row 3 -column 2 -sticky ens

      #--- Taille de la fenetre de guidage
      label $frm.guidage.labeltailleFenetreGuidage -text $::caption(sophie,tailleFenetreGuidage)
      grid $frm.guidage.labeltailleFenetreGuidage -in [ $frm.guidage getframe ] -row 4 -column 1 -sticky w

      Entry $frm.guidage.entrytailleFenetreGuidage \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(tailleFenetreGuidage)
      grid $frm.guidage.entrytailleFenetreGuidage -in [ $frm.guidage getframe ] -row 4 -column 2 -sticky ens

      #--- Gain proportionnel
      label $frm.guidage.labelgainProportionnel -text $::caption(sophie,gainProportionnel)
      grid $frm.guidage.labelgainProportionnel -in [ $frm.guidage getframe ] -row 5 -column 1 -sticky w

      Entry $frm.guidage.entrygainProportionnel \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(gainProportionnel)
      grid $frm.guidage.entrygainProportionnel -in [ $frm.guidage getframe ] -row 5 -column 2 -sticky ens

      #--- Gain integrateur
      label $frm.guidage.labelgainIntegrateur -text $::caption(sophie,gainIntegrateur)
      grid $frm.guidage.labelgainIntegrateur -in [ $frm.guidage getframe ] -row 6 -column 1 -sticky w

      Entry $frm.guidage.entrygainIntegrateur \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(gainIntegrateur)
      grid $frm.guidage.entrygainIntegrateur -in [ $frm.guidage getframe ] -row 6 -column 2 -sticky ens

   pack $frm.guidage -side top -anchor w -fill x -expand 0

   #--- Frame pour la position des fibres
   TitleFrame $frm.fibre -borderwidth 2 -relief ridge -text $::caption(sophie,positionFibres)

      #--- Fibre A HR
      label $frm.fibre.labelfibreAHR -text $::caption(sophie,fibreAHR)
      grid $frm.fibre.labelfibreAHR -in [ $frm.fibre getframe ] -row 0 -column 1 -sticky w

      spinbox $frm.fibre.spinboxfiberHRX -from 1 -to 1536 -incr 1 \
         -width 8 -justify center \
         -command "::sophie::config::onScroll $visuNo fiberHRX" \
         -textvariable ::sophie::config::widget(fiberHRX)
      grid $frm.fibre.spinboxfiberHRX -in [ $frm.fibre getframe ] -row 0 -column 2 -sticky ens

      spinbox $frm.fibre.spinboxfiberHRY -from 1 -to 1024 -incr 1 \
         -width 8 -justify center \
         -command "::sophie::config::onScroll $visuNo fiberHRY" \
         -textvariable ::sophie::config::widget(fiberHRY)
      grid $frm.fibre.spinboxfiberHRY -in [ $frm.fibre getframe ] -row 0 -column 3 -sticky ens

      #--- Fibre A HE
      label $frm.fibre.labelfibreAHE -text $::caption(sophie,fibreAHE)
      grid $frm.fibre.labelfibreAHE -in [ $frm.fibre getframe ] -row 1 -column 1 -sticky w

      spinbox $frm.fibre.spinboxfiberHEX -from 1 -to 1536 -incr 1 \
         -width 8 -justify center \
         -command "::sophie::config::onScroll $visuNo fiberHEX" \
         -textvariable ::sophie::config::widget(fiberHEX)
      grid $frm.fibre.spinboxfiberHEX -in [ $frm.fibre getframe ] -row 1 -column 2 -sticky ens

      spinbox $frm.fibre.spinboxfiberHEY -from 1 -to 1024 -incr 1 \
         -width 8 -justify center \
         -command "::sophie::config::onScroll $visuNo fiberHEY" \
         -textvariable ::sophie::config::widget(fiberHEY)
      grid $frm.fibre.spinboxfiberHEY -in [ $frm.fibre getframe ] -row 1 -column 3 -sticky ens

      #--- Fibre B
      label $frm.fibre.labelfibreB -text $::caption(sophie,fibreB)
      grid $frm.fibre.labelfibreB -in [ $frm.fibre getframe ] -row 2 -column 1 -sticky w

      spinbox $frm.fibre.spinboxxfibreB -from 1 -to 1536 -incr 1 \
         -width 8 -justify center \
         -command "::sophie::config::onScroll $visuNo fiberBX" \
         -textvariable ::sophie::config::widget(xfibreB)
      grid $frm.fibre.spinboxxfibreB -in [ $frm.fibre getframe ] -row 2 -column 2 -sticky ens

      spinbox $frm.fibre.spinboxyfibreB -from 1 -to 1024 -incr 1 \
         -width 8 -justify center \
         -command "::sophie::config::onScroll $visuNo fiberBY" \
         -textvariable ::sophie::config::widget(yfibreB)
      grid $frm.fibre.spinboxyfibreB -in [ $frm.fibre getframe ] -row 2 -column 3 -sticky ens

      #--- Mode d'entree de la fibre A
      label $frm.fibre.labelfiberGuigindMode -text $::caption(sophie,fiberGuigindMode)
      grid $frm.fibre.labelfiberGuigindMode -in [ $frm.fibre getframe ] -row 3 -column 1 -sticky w

      radiobutton $frm.fibre.fiberGuigindModeHR -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $::caption(sophie,HR) \
         -value "HR" \
         -variable ::sophie::config::widget(fiberGuigindMode) \
         -command "::sophie::config::onFiberMode $visuNo"
      grid $frm.fibre.fiberGuigindModeHR -in [ $frm.fibre getframe ] -row 3 -column 2 -sticky ens

      radiobutton $frm.fibre.fiberGuigindModeHE -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $::caption(sophie,HE) \
         -value "HE" \
         -variable ::sophie::config::widget(fiberGuigindMode) \
         -command "::sophie::config::onFiberMode $visuNo"
      grid $frm.fibre.fiberGuigindModeHE -in [ $frm.fibre getframe ] -row 3 -column 3 -sticky ens

   pack $frm.fibre -side top -anchor w -fill x -expand 0

   #--- Frame pour les images
   TitleFrame $frm.image -borderwidth 2 -relief ridge -text $::caption(sophie,images)

      #--- Repertoire des images
      label $frm.image.labelImageDirectory -text $::caption(sophie,imageDirectory)
      grid $frm.image.labelImageDirectory -in [ $frm.image getframe ] -row 0 -column 1 -sticky w

      Entry $frm.image.entryrepImages \
         -width 30 -justify left -editable 1 \
         -textvariable ::conf(sophie,imageDirectory)
      grid $frm.image.entryrepImages -in [ $frm.image getframe ] -row 0 -column 2 -sticky ens

      button $frm.image.configurerepImages -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::config::changeRepImages"
      grid $frm.image.configurerepImages -in [ $frm.image getframe ] -row 0 -column 3 -sticky ens -padx 2

      #--- Prefixe des images de centrage
      label $frm.image.labelprefixeImageCentrage -text $::caption(sophie,prefixeImageCentrage)
      grid $frm.image.labelprefixeImageCentrage -in [ $frm.image getframe ] -row 1 -column 1 -sticky w

      Entry $frm.image.entryprefixeImageCentrage \
         -width 13 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageCentrage)
      grid $frm.image.entryprefixeImageCentrage -in [ $frm.image getframe ] -row 1 -column 2 -sticky ens

      #--- Prefixe des images de guidage
      label $frm.image.labelprefixeImageGuidage -text $::caption(sophie,prefixeImageGuidage)
      grid $frm.image.labelprefixeImageGuidage -in [ $frm.image getframe ] -row 2 -column 1 -sticky w

      Entry $frm.image.entryprefixeImageGuidage \
         -width 13 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageGuidage)
      grid $frm.image.entryprefixeImageGuidage -in [ $frm.image getframe ] -row 2 -column 2 -sticky ens

      #--- Image de Bias
      label $frm.image.labelimageBias -text $::caption(sophie,imageBias)
      grid $frm.image.labelimageBias -in [ $frm.image getframe ] -row 3 -column 1 -sticky w

      Entry $frm.image.entryimageBias \
         -width 30 -justify left -editable 1 \
         -textvariable ::conf(sophie,biasImage)
      grid $frm.image.entryimageBias -in [ $frm.image getframe ] -row 3 -column 2 -sticky ens

      button $frm.image.configureimageBias -text $::caption(sophie,parcourir) -relief raised \
         -command "::sophie::chooseBiasFile"
      grid $frm.image.configureimageBias -in [ $frm.image getframe ] -row 3 -column 3 -sticky ens -padx 2

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

   #--- Frame pour les parametres de la précision du guidage
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
#    met à jour les variables et les widgets quand on applique les modifications d'une configuration
#----------------------------------------------------------------------------
proc ::sophie::config::apply { visuNo } {
   variable widget


   #--- je controle les valeurs saisies
   ### à compléter ...

   #--- j'initalise les variables des widgets
   set ::conf(sophie,exposure)              $widget(poseDefaut)
   set ::conf(sophie,centerBinning)         $widget(binCentrageDefaut)
   set ::conf(sophie,guideBinning)          $widget(binGuidageDefaut)
   set ::conf(sophie,pixelScale)            $widget(echelle)
   set ::conf(sophie,correctionCumulNb)     $widget(nbPosesAvantCorrect)
   set ::conf(sophie,originSumNb)           $widget(nbPosesAvantMaj)
   set ::conf(sophie,guidingWindowSize)     $widget(tailleFenetreGuidage)
   set ::conf(sophie,centerWindowSize)      $widget(tailleFenetreCentrage)
   set ::conf(sophie,proportionalGain)      [expr double($widget(gainProportionnel)) / 100.0]
   set ::conf(sophie,integralGain)          [expr double($widget(gainIntegrateur)) / 100.0]
   set ::conf(sophie,centerFileNameprefix)  $widget(prefixeImageCentrage)
   set ::conf(sophie,guidingFileNameprefix) $widget(prefixeImageGuidage)

   set ::conf(sophie,fiberGuigindMode)      $widget(fiberGuigindMode)
   set ::conf(sophie,fiberHRX)              $widget(fiberHRX)
   set ::conf(sophie,fiberHRY)              $widget(fiberHRY)
   set ::conf(sophie,fiberHEX)              $widget(fiberHEX)
   set ::conf(sophie,fiberHEY)              $widget(fiberHEY)

   #
   #---  je re-positionne la consigne demandé si le mode de guidage est FIBER
   ::sophie::setGuidingMode $visuNo
   #--- j'applique le mode courant pour prendre en compte les nouvelles valeurs des parametres
   ::sophie::setMode
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
proc ::sophie::config::chooseDir { { inidir . } { title } { parent } } {
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
#------------------------------------------------------------
proc ::sophie::chooseBiasFile { } {
   variable private

   #--- Ouvre la fenetre de choix des images
   set ::conf(sophie,biasImage) [ ::tkutil::box_load $::audace(base) $::audace(rep_images) $::audace(bufNo) "1" ]
   #--- Il faut un fichier
   if { $::conf(sophie,biasImage)  == "" } {
      return
   }
}

#------------------------------------------------------------
# choseBiasFile
#    choisi le nom de l'image de bias
#------------------------------------------------------------
proc ::sophie::config::onScroll { visuNo name  args } {
   variable widget

   switch $name {
      "fiberHRX" -
      "fiberHRY" {
         set ::sophie::private(originCoord) [list $widget(fiberHRX) $widget(fiberHRY)]
         ::sophie::createOrigin $visuNo
      }
      "fiberHEX" -
      "fiberHEY" {
         set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
         ::sophie::createOrigin $visuNo
      }
      "fiberBX" -
      "fiberBY" {
         ###set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
         ###::sophie::createFiberB $visuNo
      }
   }
}

#------------------------------------------------------------
# onFiberMode
#   change le mode
#------------------------------------------------------------
proc ::sophie::config::onFiberMode { visuNo args } {
   variable widget

   switch $widget(fiberGuigindMode) {
      "HR" {
         set ::sophie::private(originCoord) [list $widget(fiberHRX) $widget(fiberHRY)]
         ::sophie::createOrigin $visuNo
      }
      "HE" {
         set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
         ::sophie::createOrigin $visuNo
      }
   }

}


