##------------------------------------------------------------
# @file     sophiecontrol.tcl
# @brief    Fichier du namespace ::sophie::config
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiecontrol.tcl,v 1.35 2009-10-11 18:12:55 robertdelmas Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @brief   fenêtre de controle du centrage, de la focalisation et du guidage
#
#------------------------------------------------------------
namespace eval ::sophie::control {

}

#------------------------------------------------------------
# run
#    affiche la fenetre du configuration
#------------------------------------------------------------
proc ::sophie::control::run { visuNo tkbase } {
   variable private

   package require BLT
   namespace import ::blt::vector

   #--- Creation des variables globales si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,controlWindowPosition) ] } { set ::conf(sophie,controlWindowPosition) "430x540+580+160" }

   #--- Initialisation de variables locales
   set private(positionEtoileX)                 ""
   set private(positionEtoileY)                 ""
   set private(indicateursFwhmX)                ""
   set private(indicateursFwhmY)                ""
   set private(indicateursFondDeCiel)           ""
   set private(indicateursFluxMax)              ""
   set private(positionConsigneX)               ""
   set private(positionConsigneY)               ""
   set private(indicateursFluxMax)              ""
   set private(positionObjetX)                  ""
   set private(positionObjetY)                  ""
   set private(focalisationCourbesIntensiteMax) ""
   set private(centrageIncrement)               1
   set private(guidageIncrement)                1
   set private(guidagePhotocentrePositionX)     ""
   set private(guidagePhotocentrePositionY)     ""
   set private(ecartEtoileX)                    ""
   set private(ecartEtoileY)                    ""
   set private(ecartConsigneX)                  ""
   set private(ecartConsigneY)                  ""
   set private(alphaCorrection)                 ""
   set private(deltaCorrection)                 ""
   set private(realDelay)                       ""
   set private(biasUse)                         ""

   ###set private(activeColor)                     "#77ff77" ; #--- vert tendre
   set private(activeColor)                     "#48ebff" ; #--- bleu tendre 9 221 232
   set private(inactiveColor)                   "#ff9582" ; #--- rouge tendre
   set private(vectorLength)                    50        ; #--- nombre de valeurs conservées dans les vecteurs
   set private(listMaxIntensity)                ""

   #--- vecteur des abcisses
   if { [::blt::vector names ::sophieAbcisse ] == "" } {
      ::blt::vector create ::sophieAbcisse
      ::sophieAbcisse seq 1 $private(vectorLength)
   }

   #--- vecteur FwhmX
   if { [::blt::vector names ::sophieFwhmX] == "" } {
      ::blt::vector create ::sophieFwhmX
   }
   #--- vecteur FwhmY
   if { [::blt::vector names ::sophieFwhmY] == "" } {
      ::blt::vector create ::sophieFwhmY
   }

   #--- vecteur MaxIntensity
   if { [::blt::vector names ::sophieMaxIntensity] == "" } {
      ::blt::vector create ::sophieMaxIntensity
   }

   #--- vecteur alphaDiff
   if { [::blt::vector names ::sophieEcartEtoileX] == "" } {
      ::blt::vector create ::sophieEcartEtoileX
   }

   #--- vecteur DeltaDiff
   if { [::blt::vector names ::sophieEcartEtoileY] == "" } {
      ::blt::vector create ::sophieEcartEtoileY
   }

   #--- vecteur AlphaCorrection
   if { [::blt::vector names ::sophieCorrectionAlpha] == "" } {
      ::blt::vector create ::sophieCorrectionAlpha
   }

   #--- vecteur DeltaCorrection
   if { [::blt::vector names ::sophieCorrectionDelta] == "" } {
      ::blt::vector create ::sophieCorrectionDelta
   }

   #--- vecteur consigneXDiff
   if { [::blt::vector names ::sophieEcartConsigneX] == "" } {
      ::blt::vector create ::sophieEcartConsigneX
   }

   #--- vecteur consigneYDiff
   if { [::blt::vector names ::sophieEcartConsigneY] == "" } {
      ::blt::vector create ::sophieEcartConsigneY
   }

   #--- vecteur sophieEcartMax
   if { [::blt::vector names ::sophieEcartMax] == "" } {
      ::blt::vector create ::sophieEcartMax
      ###::sophieEcartMax append { 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 }
      ###::sophieEcartMax expr 0.5
   }

   if { [::blt::vector names ::sophieEcartMin] == "" } {
      ::blt::vector create ::sophieEcartMin
   }

   if { [::blt::vector names ::sophieEcartNul] == "" } {
      ::blt::vector create ::sophieEcartNul
      for { set i 0 } { $i < $private(vectorLength) } {incr i } {
         ::sophieEcartNul append { 0 }
      }
   }

   #--- j'intialise les courbes Min et Max des ecarts
   ::sophie::control::setMinMaxDiff $::conf(sophie,minMaxDiff)

   #--- Initialisation des vecteurs des fenetres Focalisation et Guidage
   resetFocusVector
   resetGuideVector

   #--- j'affiche la fenetre
   set this "$::audace(base).sophiecontrol"
   ::confGenerique::run $visuNo $this "::sophie::control" \
      -modal 0 \
      -geometry $::conf(sophie,controlWindowPosition) \
      -resizable 1 \
      -close 0
   #--- je supprime le bouton fermer
   pack forget $this.but_fermer

   #--- je masque les graduations des abcisses (un bug de BLT empeche de le faire avant)
   set frm $private(frm)
   $frm.focalisation.courbes.graphFwhmX_simple axis configure x -hide true
   $frm.focalisation.courbes.graphFwhmY_simple axis configure x -hide true
   $frm.focalisation.courbes.graphintensiteMax_simple axis configure x -hide true

   $frm.guidage.positionconsigne.correction.ecartConsigne_simple axis configure x -hide true
   $frm.guidage.ecarts.alpha_simple axis configure x -hide true
   $frm.guidage.corrections.delta_simple axis configure x -hide true

}

#------------------------------------------------------------
# closeWindow
#   ferme la fenetre
#------------------------------------------------------------
proc ::sophie::control::closeWindow { visuNo } {
   variable private

   if { [winfo exists $private(frm)] } {
      #--- je memorise la position courante de la fenetre
      set ::conf(sophie,controlWindowPosition) [ winfo geometry [winfo toplevel $private(frm)]]
      destroy [ winfo toplevel $private(frm) ]
   }

}

#------------------------------------------------------------
# getLabel
#   retourne le nom de la fenetre de traitement
#------------------------------------------------------------
proc ::sophie::control::getLabel { } {
   return $::caption(sophie,controleInterface)
}

#------------------------------------------------------------
# ::sophie::control::showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::sophie::control::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::sophie::getPluginType]] \
      [::sophie::getPluginDirectory] [::sophie::getPluginHelp]
}

#------------------------------------------------------------
# fillConfigPage
#   cree les widgets de la fenetre de configuration du traitement
#   return rien
#------------------------------------------------------------
proc ::sophie::control::fillConfigPage { frm visuNo } {
   variable private

   set private(frm) $frm

   #--- Frame des voyants de controle de l'interface
   TitleFrame $frm.voyant -borderwidth 2 -relief ridge \
      -text $::caption(sophie,indicateurInterface)

      label $frm.voyant.acquisition_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief groove \
         -text $::caption(sophie,acquisitionArretee)

      grid $frm.voyant.acquisition_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 0 -column 0 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

      #--- Indicateur etoile selectionnee ou non
      label $frm.voyant.etoile_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief groove \
         -text $::caption(sophie,etoileNonDetecte)
      grid $frm.voyant.etoile_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 1 -column 0 -sticky ns -padx 4 -pady 4 -ipadx 10 -ipady 4

      #--- Indicateur trou detecte ou non
      label $frm.voyant.trou_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief groove \
         -text $::caption(sophie,trouNonDetecte)
      grid $frm.voyant.trou_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 1 -column 1 -sticky ns -padx 4 -pady 4 -ipadx 10 -ipady 4

      #--- Indicateur guidage en cours ou arrete
      label $frm.voyant.guidage_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief groove \
         -text $::caption(sophie,guidageSuspendu)
      grid $frm.voyant.guidage_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 2 -column 0 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

      #--- Indicateur pose Sophie en cours ou arretee
      label $frm.voyant.sophie_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief groove \
         -text $::caption(sophie,sophieArretee)
      grid $frm.voyant.sophie_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 3 -column 0 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

      #--- Durée entre 2 poses
      LabelEntry $frm.voyant.entryRealDelay \
         -borderwidth 0 -relief flat\
         -label $::caption(sophie,realDelay) \
         -labelanchor w -width 8 -padx 2 \
         -justify center -state normal\
         -textvariable ::sophie::control::private(realDelay)
      grid $frm.voyant.entryRealDelay \
         -in [ $frm.voyant getframe ] \
         -row 4 -column 0 -columnspan 2 -sticky w -padx 2 -pady 2

      #--- Nom de l'image Bias utilisée
      LabelEntry $frm.voyant.entryBiasUse \
         -borderwidth 0 -relief flat\
         -label $::caption(sophie,biasUse) \
         -labelanchor w -width 30 -padx 2 \
         -justify center -state normal\
         -textvariable ::sophie::control::private(biasUse)
      grid $frm.voyant.entryBiasUse \
         -in [ $frm.voyant getframe ] \
         -row 5 -column 0 -columnspan 2 -sticky w -padx 2 -pady 2

      grid columnconfigure [ $frm.voyant getframe ] 0 -weight 1
      grid columnconfigure [ $frm.voyant getframe ] 1 -weight 1

   #--- Frame du seeing du centrage et de la focalisation
   TitleFrame $frm.seeing -borderwidth 2 -relief ridge \
      -text $::caption(sophie,seeing)

      #--- FWHM X
      label $frm.seeing.labelFWHMX -text $::caption(sophie,FWHMX)
      grid $frm.seeing.labelFWHMX \
         -in [ $frm.seeing getframe ] \
         -row 0 -column 0 -sticky ew

      Entry $frm.seeing.entryFWHMX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFwhmX)
      grid $frm.seeing.entryFWHMX \
         -in [ $frm.seeing getframe ] \
         -row 0 -column 1 -sticky ens -padx 10

      #--- FWHM Y
      label $frm.seeing.labelFWHMY -text $::caption(sophie,FWHMY)
      grid $frm.seeing.labelFWHMY \
         -in [ $frm.seeing getframe ] \
         -row 1 -column 0 -sticky ew

      Entry $frm.seeing.entryFWHMY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFwhmY)
      grid $frm.seeing.entryFWHMY \
         -in [ $frm.seeing getframe ] \
         -row 1 -column 1 -sticky ens -padx 10

      #--- Fond de ciel
      label $frm.seeing.labelfondDeCiel -text $::caption(sophie,fondDeCiel)
      grid $frm.seeing.labelfondDeCiel \
         -in [ $frm.seeing getframe ] \
         -row 0 -column 2 -sticky ew -padx 10

      Entry $frm.seeing.entryfondDeCiel \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFondDeCiel)
      grid $frm.seeing.entryfondDeCiel \
         -in [ $frm.seeing getframe ] \
         -row 0 -column 3 -sticky ens

      #--- Flux maxi
      label $frm.seeing.labelfluxMax -text $::caption(sophie,fluxMax)
      grid $frm.seeing.labelfluxMax \
         -in [ $frm.seeing getframe ] \
         -row 1 -column 2 -sticky ew -padx 10

      Entry $frm.seeing.entryfluxMax \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFluxMax)
      grid $frm.seeing.entryfluxMax \
         -in [ $frm.seeing getframe ] \
         -row 1 -column 3 -sticky ens

   #--- Frame pour la position du guidage
   TitleFrame $frm.position -borderwidth 2 -relief ridge \
      -text $::caption(sophie,position)

      #--- Position etoile
      label $frm.position.labelPosition -text $::caption(sophie,positionEtoile)
      grid $frm.position.labelPosition \
         -in [ $frm.position getframe ] \
         -row 0 -column 0 -columnspan 2 -sticky ew

      #--- Position etoile x
      label $frm.position.labelPositionEtoileX -text $::caption(sophie,x)
      grid $frm.position.labelPositionEtoileX \
         -in [ $frm.position getframe ] \
         -row 1 -column 0 -sticky ew

      Entry $frm.position.entryPositionEtoileX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionEtoileX)
      grid $frm.position.entryPositionEtoileX \
         -in [ $frm.position getframe ] \
         -row 1 -column 1 -sticky ew

      #--- Position etoile y
      label $frm.position.labelPositionEtoileY -text $::caption(sophie,y)
      grid $frm.position.labelPositionEtoileY \
         -in [ $frm.position getframe ] \
         -row 2 -column 0 -sticky ew

      Entry $frm.position.entryPositionEtoileY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionEtoileY)
      grid $frm.position.entryPositionEtoileY \
         -in [ $frm.position getframe ] \
         -row 2 -column 1 -sticky ew

      #--- Position consigne
      label $frm.position.labelConsigne -text $::caption(sophie,positionConsigne)
      grid $frm.position.labelConsigne \
         -in [ $frm.position getframe ] \
         -row 0 -column 2 -columnspan 2 -sticky ew

      #--- Position consigne X
      label $frm.position.labelPositionConsigneX -text $::caption(sophie,x)
      grid $frm.position.labelPositionConsigneX \
         -in [ $frm.position getframe ] \
         -row 1 -column 2 -sticky ew

      Entry $frm.position.entryPositionConsigneX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionConsigneX)
      grid $frm.position.entryPositionConsigneX \
         -in [ $frm.position getframe ] \
         -row 1 -column 3 -sticky ew

      #--- Positionconsigne Y
      label $frm.position.labelPositionConsigneY -text $::caption(sophie,y)
      grid $frm.position.labelPositionConsigneY \
         -in [ $frm.position getframe ] \
         -row 2 -column 2 -sticky ew

      Entry $frm.position.entryPositionConsigneY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionConsigneY)
      grid $frm.position.entryPositionConsigneY \
         -in [ $frm.position getframe ] \
         -row 2 -column 3 -sticky ew

      #--- Ecart etoile
      label $frm.position.labelEcartEtoile -text $::caption(sophie,ecartEtoile)
      grid $frm.position.labelEcartEtoile \
         -in [ $frm.position getframe ] \
         -row 0 -column 4 -columnspan 2 -sticky ew

      #--- Ecart etoile X
      label $frm.position.labelEcartEtoileX -text $::caption(sophie,alpha)
      grid $frm.position.labelEcartEtoileX \
         -in [ $frm.position getframe ] \
         -row 1 -column 4 -sticky ew

      Entry $frm.position.entryEcartEtoileX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(ecartEtoileX)
      grid $frm.position.entryEcartEtoileX \
         -in [ $frm.position getframe ] \
         -row 1 -column 5 -sticky ew

      #--- Ecart etoile Y
      label $frm.position.labelEcartEtoileY -text $::caption(sophie,delta)
      grid $frm.position.labelEcartEtoileY \
         -in [ $frm.position getframe ] \
         -row 2 -column 4 -sticky ew

      Entry $frm.position.entryEcartEtoileY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(ecartEtoileY)
      grid $frm.position.entryEcartEtoileY \
         -in [ $frm.position getframe ] \
         -row 2 -column 5 -sticky ew

      #--- Correction
      label $frm.position.labelCorrection -text $::caption(sophie,correction)
      grid $frm.position.labelCorrection \
         -in [ $frm.position getframe ] \
         -row 0 -column 6 -columnspan 2 -sticky ew

      #--- Correction alpha
      label $frm.position.labelCorrectionAlpha -text $::caption(sophie,alpha)
      grid $frm.position.labelCorrectionAlpha \
         -in [ $frm.position getframe ] \
         -row 1 -column 6 -sticky ew

      Entry $frm.position.entryCorrectionAlpha \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(alphaCorrection)
      grid $frm.position.entryCorrectionAlpha \
         -in [ $frm.position getframe ] \
         -row 1 -column 7 -sticky ew

      #--- Correction delta
      label $frm.position.labelCorrectionDelta -text $::caption(sophie,delta)
      grid $frm.position.labelCorrectionDelta \
         -in [ $frm.position getframe ] \
         -row 2 -column 6 -sticky ew

      Entry $frm.position.entryCorrectionDelta \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(deltaCorrection)
      grid $frm.position.entryCorrectionDelta \
         -in [ $frm.position getframe ] \
         -row 2 -column 7 -sticky ew

      grid columnconfigure [ $frm.position getframe ] 0 -weight 1
      grid columnconfigure [ $frm.position getframe ] 1 -weight 1
      grid columnconfigure [ $frm.position getframe ] 2 -weight 1
      grid columnconfigure [ $frm.position getframe ] 3 -weight 1
      grid columnconfigure [ $frm.position getframe ] 4 -weight 1
      grid columnconfigure [ $frm.position getframe ] 5 -weight 1
      grid columnconfigure [ $frm.position getframe ] 6 -weight 1
      grid columnconfigure [ $frm.position getframe ] 7 -weight 1

   #--- Frame du centrage
   frame $frm.centrage -borderwidth 1 -relief groove

      #--- Frame pour l'indicateur de centrage
      TitleFrame $frm.centrage.centrageConsigne -borderwidth 2 -relief ridge \
         -text $::caption(sophie,indicateurCentrage)

         #--- Indicateur Centrage en cours ou non
         label $frm.centrage.centrageConsigne.indicateur -text $::caption(sophie,centrageArrete) \
            -borderwidth 1 -relief groove -bg $private(inactiveColor)
         #grid $frm.centrage.centrageConsigne.indicateur \
         #   -in [ $frm.centrage.centrageConsigne getframe ] \
         #   -row 0 -column 0 -columnspan 1 -sticky n -pady 4 -ipadx 10 -ipady 4
         pack $frm.centrage.centrageConsigne.indicateur -in [ $frm.centrage.centrageConsigne getframe] \
            -side top -anchor center -fill none -expand 1  -pady 4 -ipadx 10 -ipady 4

         #--- Commande de centrage (doublon avec la commande de la fenetre principale)
         checkbutton $frm.centrage.centrageConsigne.start \
            -indicatoron 0 -state disabled \
            -text $::caption(sophie,lancerCentrage) \
            -variable ::sophie::private(centerEnabled) \
            -command "::sophie::onCenter"
         #grid $frm.centrage.centrageConsigne.start \
         #   -in [ $frm.centrage.centrageConsigne getframe ] \
         #   -row 1 -column 0 -columnspan 1 -sticky n -pady 4 -ipadx 10 -ipady 4
         pack $frm.centrage.centrageConsigne.start -in [ $frm.centrage.centrageConsigne getframe ] \
            -side top -anchor center -fill none -expand 1 -pady 4 -ipadx 10 -ipady 4

      pack $frm.centrage.centrageConsigne -side top -anchor center -fill x -expand 1

      #--- Frame pour le mode de guidage (Fibre ou objet)
      TitleFrame $frm.centrage.pointage -borderwidth 2 -relief ridge \
         -text $::caption(sophie,consigne)

         #--- Frame des indicateurs
         frame $frm.centrage.pointage.indicateur -borderwidth 0 -relief ridge

            #--- Indicateur de pointage de l'entree de la fibre A HR
            radiobutton $frm.centrage.pointage.indicateur.fibreAHR \
               -indicatoron 0 -text $::caption(sophie,consigneFibreHR) -value FIBER_HR \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namespace ::sophie
            pack $frm.centrage.pointage.indicateur.fibreAHR -anchor center \
               -expand 1 -fill none -side left -ipadx 4 -ipady 4

            #--- Indicateur de pointage de l'entree de la fibre A HE
            radiobutton $frm.centrage.pointage.indicateur.fibreAHE \
               -indicatoron 0 -text $::caption(sophie,consigneFibreHE) -value FIBER_HE \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namespace ::sophie
            pack $frm.centrage.pointage.indicateur.fibreAHE -anchor center \
               -expand 1 -fill none -side left -ipadx 4 -ipady 4

            #--- Indicateur de pointage de l'objet
            radiobutton $frm.centrage.pointage.indicateur.objet \
               -indicatoron 0 -text $::caption(sophie,consigneObjet) -value OBJECT \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namespace ::sophie
            pack $frm.centrage.pointage.indicateur.objet -anchor center \
               -expand 1 -fill none -side left -ipadx 4 -ipady 4

         pack $frm.centrage.pointage.indicateur \
            -in [ $frm.centrage.pointage getframe ] \
            -side top -anchor w -fill x -expand 1

         #--- Frame pour modifier la position de la consigne
         frame $frm.centrage.pointage.positionXY -borderwidth 0 -relief ridge

            #--- Position X
            label $frm.centrage.pointage.positionXY.labelX -text $::caption(sophie,x)
            grid $frm.centrage.pointage.positionXY.labelX -row 0 -column 1 -sticky w -padx 5 -pady 3

            spinbox $frm.centrage.pointage.positionXY.spinboxX -from 1 -to 1536 -incr $private(centrageIncrement) \
               -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetX)
            bind $frm.centrage.pointage.positionXY.spinboxX <Key-Return> "::sophie::control::onScrollOrigin $visuNo"
            grid $frm.centrage.pointage.positionXY.spinboxX -row 0 -column 2 -sticky ens

            #--- Position Y
            label $frm.centrage.pointage.positionXY.labelY -text $::caption(sophie,y)
            grid $frm.centrage.pointage.positionXY.labelY -row 0 -column 3 -sticky w -padx 5 -pady 3

            spinbox $frm.centrage.pointage.positionXY.spinboxY -from 1 -to 1024 -incr $private(centrageIncrement)  \
               -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetY)
            bind $frm.centrage.pointage.positionXY.spinboxY <Key-Return> "::sophie::control::onScrollOrigin $visuNo"
            grid $frm.centrage.pointage.positionXY.spinboxY -row 0 -column 4 -sticky ens

            #--- increment
            label $frm.centrage.pointage.positionXY.labelIncrement -text $::caption(sophie,increment)
            grid $frm.centrage.pointage.positionXY.labelIncrement -row 0 -column 5 -sticky w -padx 5 -pady 3

            spinbox $frm.centrage.pointage.positionXY.spinboxIncrement \
               -values { 0.1 1 10 } -width 5 -justify center \
               -command "::sophie::control::setCenterIncrement" \
               -textvariable ::sophie::control::private(centrageIncrement)
            $frm.centrage.pointage.positionXY.spinboxIncrement set 1
            grid $frm.centrage.pointage.positionXY.spinboxIncrement \
               -row 0 -column 6 -sticky ens

            Button $frm.centrage.pointage.positionXY.replaceManualOrigin -text $::caption(sophie,replaceSquarePosition) \
               -command "::sophie::control::replaceOriginCoordinates $visuNo"
            grid $frm.centrage.pointage.positionXY.replaceManualOrigin -row 0 -column 7 -sticky ew -padx 2

      pack $frm.centrage.pointage -side top -anchor w -fill x -expand 1

   #--- Frame de la focalisation
   frame $frm.focalisation -borderwidth 1 -relief groove

      #--- Frame des courbes
      TitleFrame $frm.focalisation.courbes -borderwidth 2 -relief ridge \
         -text $::caption(sophie,courbes)

         #--- FWHM X
         createGraph $visuNo $frm.focalisation.courbes.graphFwhmX_simple 120
         ###$frm.focalisation.courbes.graphFwhmX_simple axis configure y -min 0
         $frm.focalisation.courbes.graphFwhmX_simple element create xfwhm \
            -xdata ::sophieAbcisse -ydata ::sophieFwhmX \
            -symbol none -label $::caption(sophie,FWHMX)
         $frm.focalisation.courbes.graphFwhmX_simple axis configure x -hide true
         $frm.focalisation.courbes.graphFwhmX_simple legend configure -hide no \
            -position plotarea -anchor nw -font $::conf(conffont,Label) \
            -borderwidth 0 -relief flat

         grid $frm.focalisation.courbes.graphFwhmX_simple \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 0 -column 1 -sticky nsew

         #--- FWHM Y
         createGraph $visuNo $frm.focalisation.courbes.graphFwhmY_simple 120
         ###$frm.focalisation.courbes.graphFwhmY_simple axis configure y -min 0
         $frm.focalisation.courbes.graphFwhmY_simple element create yfwhm \
            -xdata ::sophieAbcisse -ydata ::sophieFwhmY \
            -symbol none -label $::caption(sophie,FWHMY)
         $frm.focalisation.courbes.graphFwhmY_simple legend configure \
            -hide no -position plotarea -anchor nw -font $::conf(conffont,Label) \
            -borderwidth 0 -relief flat
         grid $frm.focalisation.courbes.graphFwhmY_simple \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 1 -column 1 -sticky nsew

         #--- Intensite maxi
         createGraph $visuNo $frm.focalisation.courbes.graphintensiteMax_simple 120
         ###$frm.focalisation.courbes.graphintensiteMax_simple axis configure y -min 0
         $frm.focalisation.courbes.graphintensiteMax_simple element create maxIntensity \
            -xdata ::sophieAbcisse -ydata ::sophieMaxIntensity \
            -symbol none -label $::caption(sophie,intensiteMax)
         $frm.focalisation.courbes.graphintensiteMax_simple legend configure \
            -hide no -position plotarea -anchor nw -font $::conf(conffont,Label) \
            -borderwidth 0 -relief flat
         grid $frm.focalisation.courbes.graphintensiteMax_simple \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 2 -column 1 -sticky nsew

         grid columnconfig [ $frm.focalisation.courbes getframe ] 0 -weight 0
         grid columnconfig [ $frm.focalisation.courbes getframe ] 1 -weight 1
      pack $frm.focalisation.courbes -side top -anchor w -fill x -expand 1

   #--- Frame du guidage
   frame $frm.guidage -borderwidth 1 -relief groove

      #--- Frame seeing du guidage
      TitleFrame $frm.guidage.seeing -borderwidth 2 -relief ridge \
         -text $::caption(sophie,seeing)

         #--- FWHM X
         label $frm.guidage.seeing.labelFWHMX -text $::caption(sophie,FWHMXMemorise)
         grid $frm.guidage.seeing.labelFWHMX \
            -in [ $frm.guidage.seeing getframe ] \
            -row 0 -column 0 -sticky ew

         Entry $frm.guidage.seeing.entryFWHMX \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursFwhmX)
         grid $frm.guidage.seeing.entryFWHMX \
            -in [ $frm.guidage.seeing getframe ] \
            -row 0 -column 1 -sticky ens -padx 10

         #--- FWHM Y
         label $frm.guidage.seeing.labelFWHMY -text $::caption(sophie,FWHMYMemorise)
         grid $frm.guidage.seeing.labelFWHMY \
            -in [ $frm.guidage.seeing getframe ] \
            -row 1 -column 0 -sticky ew

         Entry $frm.guidage.seeing.entryFWHMY \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursFwhmY)
         grid $frm.guidage.seeing.entryFWHMY \
            -in [ $frm.guidage.seeing getframe ] \
            -row 1 -column 1 -sticky ens -padx 10

         #--- Fond de ciel
         label $frm.guidage.seeing.labelfondDeCiel -text $::caption(sophie,fondDeCielMemorise)
         grid $frm.guidage.seeing.labelfondDeCiel \
            -in [ $frm.guidage.seeing getframe ] \
           -row 0 -column 2 -sticky ew -padx 10

         Entry $frm.guidage.seeing.entryfondDeCiel \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursFluxMax)
         grid $frm.guidage.seeing.entryfondDeCiel \
            -in [ $frm.guidage.seeing getframe ] \
            -row 0 -column 3 -sticky ens

         #--- Flux maxi
         label $frm.guidage.seeing.labelfluxMax -text $::caption(sophie,fluxMax)
         grid $frm.guidage.seeing.labelfluxMax \
            -in [ $frm.guidage.seeing getframe ] \
            -row 1 -column 2 -sticky ew -padx 10

         Entry $frm.guidage.seeing.entryfluxMax \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursFluxMax)
         grid $frm.guidage.seeing.entryfluxMax \
            -in [ $frm.guidage.seeing getframe ] \
            -row 1 -column 3 -sticky ens

      pack $frm.guidage.seeing -side top -anchor w -fill x -expand 1

      #--- Frame des graphes des ecarts et des corrections
      TitleFrame $frm.guidage.positionconsigne -borderwidth 2 -relief ridge \
         -text $::caption(sophie,positionConsigneImage)

         #--- Frame pour afficher la position de la consigne
         frame $frm.guidage.positionconsigne.correction -borderwidth 0 -relief ridge

            #--- Graphe de la erreur en alpha et delta
            createGraph $visuNo $frm.guidage.positionconsigne.correction.ecartConsigne_simple 105
            $frm.guidage.positionconsigne.correction.ecartConsigne_simple element create ecartConsigneX \
               -xdata ::sophieAbcisse -ydata ::sophieEcartConsigneX -mapy y \
               -color blue -dash "2" -linewidth 3 \
               -symbol none -label $::caption(sophie,alpha)
            $frm.guidage.positionconsigne.correction.ecartConsigne_simple element create ecartConsigneY \
               -xdata ::sophieAbcisse -ydata ::sophieEcartConsigneY -mapy y \
               -color orange -dash "" -linewidth 3 \
               -symbol none -label $::caption(sophie,delta)
            $frm.guidage.positionconsigne.correction.ecartConsigne_simple legend configure -hide no -position right
            ###$frm.guidage.positionconsigne.correction.ecartConsigne_simple legend configure -hide no -position plotarea -anchor nw

            grid $frm.guidage.positionconsigne.correction.ecartConsigne_simple \
               -row 0 -column 0 -sticky ew
            grid columnconfig $frm.guidage.positionconsigne.correction 0 -weight 1

         pack $frm.guidage.positionconsigne.correction \
           -in [ $frm.guidage.positionconsigne getframe ] \
           -side top -anchor w -fill x -expand 1

         #--- Frame pour modifier la position de la consigne
         frame $frm.guidage.positionconsigne.positionXY -borderwidth 0 -relief ridge

            ####--- Label
            ###label $frm.guidage.positionconsigne.positionXY.label \
            ###   -text $::caption(sophie,positionConsigneImage)
            ###grid $frm.guidage.positionconsigne.positionXY.label \
            ###   -row 0 -column 1 -columnspan 4 -sticky w -padx 5 -pady 3

            #--- Position X
            label $frm.guidage.positionconsigne.positionXY.labelX -text $::caption(sophie,x)
            grid $frm.guidage.positionconsigne.positionXY.labelX \
               -row 0 -column 1 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxX -from 1 -to 1536 \
               -incr $private(guidageIncrement) -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetX)
            grid $frm.guidage.positionconsigne.positionXY.spinboxX \
               -row 0 -column 2 -sticky ens

            #--- Position Y
            label $frm.guidage.positionconsigne.positionXY.labelY -text $::caption(sophie,y)
            grid $frm.guidage.positionconsigne.positionXY.labelY \
               -row 0 -column 3 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxY -from 1 -to 1024 \
               -incr $private(guidageIncrement) -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetY)
            grid $frm.guidage.positionconsigne.positionXY.spinboxY \
               -row 0 -column 4 -sticky ens

            #--- Increment
            label $frm.guidage.positionconsigne.positionXY.labelIncrement \
               -text $::caption(sophie,increment)
            grid $frm.guidage.positionconsigne.positionXY.labelIncrement \
               -row 0 -column 5 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxIncrement \
               -values { 0.1 1 10 } -width 5 -justify center \
               -command "::sophie::control::setGuidingIncrement" \
               -textvariable ::sophie::control::private(guidageIncrement)

            grid $frm.guidage.positionconsigne.positionXY.spinboxIncrement \
               -row 0 -column 6 -sticky ens

            set private(guidageIncrement) 1

      pack $frm.guidage.positionconsigne -side top -anchor w -fill x -expand 1

      #--- Frame des ecarts en alpha et delta
      TitleFrame $frm.guidage.ecarts -borderwidth 2 -relief ridge \
         -text $::caption(sophie,ecartEtoile)

         #--- Graphe de la erreur en alpha et delta
         createGraph $visuNo $frm.guidage.ecarts.alpha_simple 105
         $frm.guidage.ecarts.alpha_simple element create alphaDiff \
            -xdata ::sophieAbcisse -ydata ::sophieEcartEtoileX -mapy y \
            -color blue -dash "2" -linewidth 3 \
            -symbol none -label $::caption(sophie,alpha)
         $frm.guidage.ecarts.alpha_simple element create deltaDiff \
            -xdata ::sophieAbcisse -ydata ::sophieEcartEtoileY -mapy y \
            -color orange -dash "" -linewidth 3 \
            -symbol none -label $::caption(sophie,delta)
         $frm.guidage.ecarts.alpha_simple legend configure -hide no -position right
         ###$frm.guidage.ecarts.alpha_simple legend configure -hide no -position plotarea -anchor nw

         $frm.guidage.ecarts.alpha_simple  element create ecartMax  \
            -xdata ::sophieAbcisse -ydata ::sophieEcartMax -mapy y \
            -color red -symbol none -label ""

         $frm.guidage.ecarts.alpha_simple  element create ecartMin  \
            -xdata ::sophieAbcisse -ydata ::sophieEcartMin -mapy y \
            -color red -symbol none  -label ""

         $frm.guidage.ecarts.alpha_simple  element create ecartNul  \
            -xdata ::sophieAbcisse -ydata ::sophieEcartNul -mapy y \
            -color black -symbol none  -label ""

         grid $frm.guidage.ecarts.alpha_simple \
            -in [ $frm.guidage.ecarts getframe ] \
            -row 0 -column 0 -sticky nsew
        grid columnconfig [ $frm.guidage.ecarts getframe ] 0 -weight 1

      pack $frm.guidage.ecarts -side top -anchor w -fill x -expand 1

      #--- Frame pour visualiser les corrections du telescope en alpha et delta
      TitleFrame $frm.guidage.corrections -borderwidth 2 -relief ridge \
         -text $::caption(sophie,correction)

         #--- Graphe de la correction en delta
         createGraph $visuNo $frm.guidage.corrections.delta_simple 105
         $frm.guidage.corrections.delta_simple element create alphaCorrection \
            -xdata ::sophieAbcisse -ydata ::sophieCorrectionAlpha -mapy y \
            -color blue -dash "2" -linewidth 3 \
            -symbol none -label $::caption(sophie,alpha)
         $frm.guidage.corrections.delta_simple element create deltaCorrection \
            -xdata ::sophieAbcisse -ydata ::sophieCorrectionDelta -mapy y \
            -color orange -dash "" -linewidth 3 \
            -symbol none -label $::caption(sophie,delta)
         $frm.guidage.corrections.delta_simple legend configure -hide no -position right
         ###$frm.guidage.corrections.delta_simple legend configure -hide no -position plotarea -anchor nw

         grid $frm.guidage.corrections.delta_simple \
            -in [ $frm.guidage.corrections getframe ] \
            -row 1 -column 0 -sticky nsew

        grid columnconfig [ $frm.guidage.corrections getframe ] 0 -weight 1
      pack $frm.guidage.corrections -side top -anchor w -fill x -expand 1

    # pack $frm.guidage -side top -fill both

}

##------------------------------------------------------------
# adaptIncrement
#    adapte la valeur de l'increment
#------------------------------------------------------------
proc ::sophie::control::setCenterIncrement { } {
   variable private

   set frm $::sophie::control::private(frm)
   $frm.centrage.pointage.positionXY.spinboxX configure -increment $private(centrageIncrement)
   $frm.centrage.pointage.positionXY.spinboxY configure -increment $private(centrageIncrement)
}

##------------------------------------------------------------
# adaptIncrement
#    adapte la valeur de l'increment
#------------------------------------------------------------
proc ::sophie::control::setGuidingIncrement { } {
   variable private

   set frm $::sophie::control::private(frm)
   $frm.guidage.positionconsigne.positionXY.spinboxX configure -increment $private(guidageIncrement)
   $frm.guidage.positionconsigne.positionXY.spinboxY configure -increment $private(guidageIncrement)
}

#------------------------------------------------------------
# setGuidingMode
#    si guidingMode=OBJECT ouvre les spinbox pour le pointage d'un objet
#    si guidingMode=FIBER_HR ou FIBER_HE omasque les spinbox et affiche  le graphe d'ecart consigne/fibre
# @param guidingMode mode de guidage
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setGuidingMode { guidingMode } {
   variable private

   #--- petit raccourci bien pratique
   set frm $private(frm)

   switch $guidingMode {
      "OBJECT" {
         #--- je masque le graphe des ecarts de la consigne
         pack forget $frm.guidage.positionconsigne.correction
         #--- j'affiche les spinbox de modification manuelle de la consigne
         pack $frm.centrage.pointage.positionXY \
            -in [ $frm.centrage.pointage getframe ] \
            -side top -anchor w -fill x -expand 1 -pady 2
         pack $frm.guidage.positionconsigne.positionXY \
            -in [ $frm.guidage.positionconsigne getframe ] \
            -side top -anchor w -fill x -expand 1
      }
      "FIBER_HR" -
      "FIBER_HE" {
         #--- je masque les spinbox de modification manuelle de la consigne
         pack forget $frm.centrage.pointage.positionXY
         pack forget $frm.guidage.positionconsigne.positionXY
         #--- j'affiche le graphe des ecarts de la consigne
         pack $frm.guidage.positionconsigne.correction \
            -in [ $frm.guidage.positionconsigne getframe ] \
            -side top -anchor w -fill x -expand 1
      }
   }
}

#------------------------------------------------------------
# setFiberDetection
#    si OBJECT ouvre les spinbox pour le pointage d'un objet
#
#    si findFiber=0 affiche les spinbox pour le pointage d'un objet
#    si findFiber=1 affiche les graphes de correction automatique
#------------------------------------------------------------
###proc ::sophie::control::setFiberDetection { findFiber } {
###   variable private
###
###   set frm $private(frm)
###
###   switch $::conf(sophie,guidingMode)  {
###      "FIBER_HR" {
###         #--- je masque les spinbox de modification manuelle de la consigne
###         pack forget $frm.centrage.pointage.positionXY
###         pack forget $frm.guidage.positionconsigne.positionXY
###
###         if { $findFiber == 0 } {
###            #--- je masque la position corrigee de la consigne
###         } else {
###            #--- j'affiche la position corrigee de la consigne
###         }
###
###         #--- j'affiche le graphe de position de la consigne
###         pack $frm.guidage.positionconsigne.correction \
###            -in [ $frm.guidage.positionconsigne getframe ] \
###            -side top -anchor w -fill x -expand 1
###      }
###      "FIBER_HE" {
###         #--- je masque les spinbox de modification manuelle de la consigne
###         pack forget $frm.centrage.pointage.positionXY
###         pack forget $frm.guidage.positionconsigne.positionXY
###
###         if { $findFiber == 0 } {
###            #--- je masque la position corrigee de la consigne
###         } else {
###            #--- j'affiche la position corrigee de la consigne
###         }
###
###         #--- j'affiche le graphe de position de la consigne
###         pack $frm.guidage.positionconsigne.correction \
###            -in [ $frm.guidage.positionconsigne getframe ] \
###            -side top -anchor w -fill x -expand 1
###      }
###      "OBJECT" {
###         #--- je masque le graphe des ecarts de la consigne
###         pack forget $frm.guidage.positionconsigne.correction
###         #--- j'affiche les spinbox de modification manuelle de la consigne
###         pack $frm.centrage.pointage.positionXY \
###            -in [ $frm.centrage.pointage getframe ] \
###            -side top -anchor w -fill x -expand 1
###         pack $frm.guidage.positionconsigne.positionXY \
###            -in [ $frm.guidage.positionconsigne getframe ] \
###            -side top -anchor w -fill x -expand 1
###      }
###   }
###
###}

#------------------------------------------------------------
# onScrollOrigin
#    modifie la position de la consigne
#------------------------------------------------------------
proc ::sophie::control::onScrollOrigin { visuNo args } {
   variable private

   #--- je copie les coordonnees dans la variable globale
   set ::conf(sophie,objectCoord) [list $private(positionObjetX) $private(positionObjetY) ]

   #--- je met a jour l'affichage de la fenetre principale
   ::sophie::setGuidingMode $visuNo

}

#------------------------------------------------------------
# createGraph
#    affichage de graphiques
#
#------------------------------------------------------------
proc ::sophie::control::createGraph { visuNo graph height } {
   #--- je cree le graphique
   blt::graph $graph -plotbackground "$::color(white)"
   $graph crosshairs on
   $graph crosshairs configure -color "$::color(red)" -dashes 2
   $graph axis configure x  -hide 1
   $graph axis configure y  -hide 0
   $graph axis configure x2 -hide 1
   $graph axis configure y2 -hide 1
   $graph grid on
   $graph configure -height $height
   $graph configure -plotbackground "$::color(white)"
   $graph configure -leftmargin 50

   bind $graph <Motion>          "::sophie::control::onGraphMotion %W %x %y"
   bind $graph <ButtonPress-1>   "::sophie::control::onGraphRegionStart $visuNo %W %x %y "
   bind $graph <B1-Motion>       "::sophie::control::onGraphRegionMotion $visuNo %W %x %y"
   bind $graph <ButtonRelease-1> "::sophie::control::onGraphRegionEnd $visuNo %W %x %y"
   bind $graph <ButtonRelease-3> "::sophie::control::onGraphUnzoom $graph"

}

##------------------------------------------------------------
# setMode
#    met a jour l'affichage en fonction du mode
#
# @param mode  mode de fonctionnement (centrage, focalisation, guidage)
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setMode { mode } {
   variable private

   set frm $private(frm)

   if { [ winfo exists $frm ] } {
      switch $mode {
         "CENTER" {
            pack forget $frm.guidage
            pack forget $frm.focalisation
            pack $frm.voyant     -side top -fill x
            pack $frm.position   -side top -fill x -after $frm.voyant
            pack $frm.seeing     -side top -fill x -after $frm.position
            pack $frm.centrage   -side top -fill x
         }
         "FOCUS" {
            pack forget $frm.centrage
            pack forget $frm.guidage
            pack forget $frm.focalisation
            pack $frm.voyant     -side top -fill x
            pack $frm.position   -side top -fill x -after $frm.voyant
            pack $frm.seeing     -side top -fill x -after $frm.position
            pack $frm.focalisation   -side top -fill x
            #--- raz des vecteurs
            resetFocusVector
         }
         "GUIDE" {
            pack forget $frm.seeing
            pack forget $frm.centrage
            pack forget $frm.focalisation
            pack $frm.voyant     -side top -fill x
            pack $frm.position   -side top -fill x
            pack $frm.guidage    -side top -fill x
            #--- raz des vecteurs
            resetGuideVector
         }
      }
      set This "$::audace(base).sophiecontrol"
      wm title $This "$::caption(sophie,controlTitle) $::caption(sophie,$mode)"
      ###focus $frm
   }
}

##------------------------------------------------------------
# setMode
#    met a jour l'affichage en fonction du mode
#
# @param mode  mode de fonctionnement (centrage, focalisation, guidage)
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setMinMaxDiff { minMaxValue } {
   variable private

   if { [::sophieEcartMax length] > 0 } {
      ::sophieEcartMax delete 0:end
   }
   for { set i 0 } { $i < $private(vectorLength) } {incr i } {
      ::sophieEcartMax append $minMaxValue
   }

   if { [::sophieEcartMin length] > 0 } {
      ::sophieEcartMin delete 0:end
   }
   for { set i 0 } { $i < $private(vectorLength) } {incr i } {
      ::sophieEcartMin append [expr $minMaxValue * -1]
   }
}

##------------------------------------------------------------
# setAcquisitionState
#    met a jour l'etat des acquisitions continues
#
# @param state    etat des acquisitions continues 0=arrete 1=en cours
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setAcquisitionState { state } {
   variable private

   set frm $private(frm)
   if { $state == 0 } {
      #--- j'affiche l'indicateur d'acquisition en rouge
      $frm.voyant.acquisition_color_invariant configure \
         -text $::caption(sophie,acquisitionArretee) \
         -bg   $private(inactiveColor)

      #--- je desactive le bouton de centrage
      $frm.centrage.centrageConsigne.start configure -state disabled
   } else {
      #--- j'affiche l'indicateur d'acquisition en vert
      $frm.voyant.acquisition_color_invariant configure \
         -text $::caption(sophie,acquisitionEncours) \
         -bg   $private(activeColor)
      #--- j'active le bouton de centrage
      $frm.centrage.centrageConsigne.start configure -state normal
   }
}

##------------------------------------------------------------
# setCenterState
#    met a jour le voyant du centrage
#
# @param state    etat du centrage 0=arrete 1=en cours
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setCenterState { state } {
   variable private

   set frm $private(frm)
   if { $state == 0 } {
      #--- j'affiche le voyant en rouge
      $frm.centrage.centrageConsigne.indicateur configure \
         -text $::caption(sophie,centrageArrete) \
         -bg   $private(inactiveColor)
      #--- je change le libelle du bouton de commande
      $frm.centrage.centrageConsigne.start configure -text $::caption(sophie,lancerCentrage)
   } else {
      #--- j'affiche le voyant en vert
      $frm.centrage.centrageConsigne.indicateur configure \
         -text $::caption(sophie,centrageReussi) \
         -bg   $private(activeColor)
      #--- je change le libelle du bouton de commande
      $frm.centrage.centrageConsigne.start configure -text $::caption(sophie,arreterCentrage)
   }
}

##------------------------------------------------------------
# setGuideState
#    met a jour le voyant du guidage
#
# @param state    etat du centrage 0=arrete 1=en cours
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setGuideState { state } {
   variable private

   set frm $private(frm)
   if { $state == 0 } {
      #--- j'affiche le voyant en rouge
      $frm.voyant.guidage_color_invariant configure \
         -text $::caption(sophie,guidageSuspendu) \
         -bg   $private(inactiveColor)
      #--- je purge les vecteurs

   } else {
      #--- j'affiche le voyant en vert
      $frm.voyant.guidage_color_invariant configure \
         -text $::caption(sophie,guidageEncours) \
         -bg   $private(activeColor)
   }
}

##------------------------------------------------------------
# setCenterState
#    met a jour le voyant d'acquisition des spectres Sophie
#
# @param state    etat du centrage 0=arrete 1=en cours
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setAcquisitionSophie { state } {
   variable private

   set frm $private(frm)
   if { $state == 0 } {
      #--- j'affiche le voyant en rouge
      $frm.voyant.sophie_color_invariant configure \
         -text $::caption(sophie,sophieArretee) \
         -bg   $private(inactiveColor)
      #--- je purge les vecteurs

   } else {
      #--- j'affiche le voyant en vert
      $frm.voyant.sophie_color_invariant configure \
         -text $::caption(sophie,sophieEncours) \
         -bg   $private(activeColor)
   }
}

##------------------------------------------------------------
# setBias
#    met a jour le nom du fichier bias
#
# @param biasState  etat du bias
#     - OK   le bias est charge  (biasMessage contient le nom du fichier)
#     - NONE pas de bias demande (biasMessage est vide)
#     - ERROR erreur pendant le chargement de bias (biasMessage contient le libelle du message d'erreur)
# @param biasMessage  nom du fichier bias ou message d'erreur
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setBias { biasState biasMessage } {
   variable private

   set private(biasUse) $biasMessage
  ### console::disp "setBias biasState=$biasState biasMessage=$biasMessage\n"
}

##------------------------------------------------------------
# setRealDelay
#    met a jour le delai entre 2 poses
#
# @param delay   delai entre 2 poses en seconde
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setRealDelay { delay } {
   variable private

   #--- je formate le delai avant de l'afficher
   set private(realDelay) [format "%6.3f" $delay ]

}

##------------------------------------------------------------
# setCenterInformation
#    affiche les informations de centrage
#
# @param starDetection  0=etoile non detecte 1=etoile detecte
# @param fiberStatus  resultat detection de la fibre = DETECTED NO_SIGNAL TOO_FAR OUTSIDE LOW_SIGNAL INTEGRATING DISABLED
# @param originX  abcisse de la consigne en pixel
# @param originY  ordonnee de la consigne en pixel
# @param starX  abcisse de l'etoile en pixel
# @param starY  ordonnee de l'etoile en pixel
# @param fwhmX  largeur a mi hauter sur l'axe X
# @param fwhmY  largeur a mi hauter sur l'axe Y
# @param background  fond du ciel
# @param maxIntensity  intensité max
# @param starDx  ecart de l'abcisse de l'etoile en pixel
# @param starDy  ecart de l'ordonne de l'etoile en pixel
# @param alphaDiff  ecart de l'ascension droite de l'etoile en arcseconde
# @param deltaDiff  ecart de la declinaison de l'etoile en arcseconde
# @param alphaCorrection  correction du telescope en alpha (en arcseconde)
# @param deltaCorrection  correction du telescope en delta (en arcseconde)
#
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setCenterInformation { starDetection fiberStatus originX originY starX starY fwhmX fwhmY background maxIntensity starDx starDy alphaDiff deltaDiff alphaCorrection deltaCorrection } {
   variable private

   set frm $private(frm)

   #--- je mets a jour le voyant "etoileDetecte"
   if { $starDetection == 0 } {
      $frm.voyant.etoile_color_invariant configure \
         -text $::caption(sophie,etoileNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.voyant.etoile_color_invariant configure \
         -text $::caption(sophie,etoileDetecte) \
         -bg   $private(activeColor)
   }

   #--- je mets a jour le voyant "trouDetecte"
   switch $fiberStatus {
      "DETECTED" {
         #--- le trou est détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouDetecte) \
            -bg   $private(activeColor)
      }
      "DISABLED" {
         #--- la detection du trou est desactivee
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,tourNonRecherche) \
            -bg   "SystemButtonFace"
      }
      "INTEGRATING" {
         #--- l'integration des premieres images est en cours
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,integrationEncours) \
            -bg   "SystemButtonFace"
      }
      "LOW_SIGNAL" -
      "TOO_FAR" -
      "OUTSIDE" -
      "NO_SIGNAL" -
      default {
         #--- le trou n'est pas détecte
         $frm.voyant.trou_color_invariant configure \
            -text "$::caption(sophie,trouNonDetecte) ($fiberStatus)" \
            -bg   $private(inactiveColor)
      }
   }

   set private(positionEtoileX)       [format "%6.1f" $starX]
   set private(positionEtoileY)       [format "%6.1f" $starY]
   set private(positionConsigneX)     [format "%6.1f" $originX]
   set private(positionConsigneY)     [format "%6.1f" $originY]
   set private(ecartEtoileX)          [format "%6.2f" $alphaDiff]
   set private(ecartEtoileY)          [format "%6.2f" $deltaDiff]
   set private(alphaCorrection)       [format "%6.2f" $alphaCorrection]
   set private(deltaCorrection)       [format "%6.2f" $deltaCorrection]

   set private(indicateursFwhmX)      [format "%6.1f" $fwhmX]
   set private(indicateursFwhmY)      [format "%6.1f" $fwhmY]
   set private(indicateursFondDeCiel) [format "%6.1f" $background]
   set private(indicateursFluxMax)    [format "%6.1f" $maxIntensity]

}

##------------------------------------------------------------
# setFocusInformation
#    affiche les informations de focalisation
#
# @param starDetection 0=etoile non detecte 1=etoile detecte
# @param fiberStatus  resultat detection de la fibre = DETECTED NO_SIGNAL TOO_FAR OUTSIDE LOW_SIGNAL INTEGRATING DISABLED
# @param originY  ordonnee de la consigne en pixel
# @param starX   abcisse de l'etoile en pixel
# @param starY   ordonnee de l'etoile en pixel
# @param fwhmX   largeur a mi hauteur sur l'axe X (arcsec)
# @param fwhmY   largeur a mi hauteur sur l'axe Y (arcsec)
# @param alphaDiff  ecart de l'ascension droite de l'etoile en arcseconde
# @param deltaDiff  ecart de la declinaison de l'etoile en arcseconde
# @param background   fond du ciel
# @param maxIntensity intensité max
#
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setFocusInformation { starDetection fiberStatus originX originY starX starY fwhmX fwhmY alphaDiff deltaDiff background maxIntensity } {
   variable private

   set frm $private(frm)

   #--- je mets a jour le voyant "etoileDetecte"
   if { $starDetection == 0 } {
      $frm.voyant.etoile_color_invariant configure \
         -text $::caption(sophie,etoileNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.voyant.etoile_color_invariant configure \
         -text $::caption(sophie,etoileDetecte) \
         -bg   $private(activeColor)
   }

   #--- je mets a jour le voyant "trouDetecte"
   switch $fiberStatus {
      "DETECTED" {
         #--- le trou est détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouDetecte) \
            -bg   $private(activeColor)
      }
      "DISABLED" {
         #--- la detection du trou est desactivee
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,tourNonRecherche) \
            -bg   "SystemButtonFace"
      }
      "INTEGRATING" {
         #--- l'integration des premieres images est en cours
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,integrationEncours) \
            -bg   "SystemButtonFace"
      }
      "LOW_SIGNAL" -
      "TOO_FAR" -
      "OUTSIDE" -
      "NO_SIGNAL" -
      default {
         #--- le trou n'est pas détecte
         $frm.voyant.trou_color_invariant configure \
            -text "$::caption(sophie,trouNonDetecte) ($fiberStatus)" \
            -bg   $private(inactiveColor)
      }
   }

   set private(positionEtoileX)       [format "%6.1f" $starX]
   set private(positionEtoileY)       [format "%6.1f" $starY]
   set private(indicateursFwhmX)      [format "%6.2f" $fwhmX]
   set private(indicateursFwhmY)      [format "%6.2f" $fwhmY]
   set private(ecartEtoileX)          [format "%6.2f" $alphaDiff]
   set private(ecartEtoileY)          [format "%6.2f" $deltaDiff]
   set private(indicateursFondDeCiel) [format "%6.1f" $background]
   set private(indicateursFluxMax)    [format "%6.1f" $maxIntensity]

   #--- j'ajoute la valeur dans le graphe FwhmX
   ::sophieFwhmX append $fwhmX
   if { [::sophieFwhmX length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieFwhmX delete 0
   }

   #--- j'ajoute la valeur dans le graphe FwhmY
   ::sophieFwhmY append $fwhmY
   if { [::sophieFwhmY length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieFwhmY delete 0
   }

   #--- j'ajoute la valeur dans le graphe maxIntensity
   ::sophieMaxIntensity append $maxIntensity
   if { [::sophieMaxIntensity length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieMaxIntensity delete 0
   }
}

##------------------------------------------------------------
# setGuideInformation
#    affiche les informations de guidage
#
# @param starDetection 0=etoile non detecte 1=etoile detecte
# @param fiberStatus  resultat detection de la fibre = DETECTED NO_SIGNAL TOO_FAR OUTSIDE LOW_SIGNAL INTEGRATING DISABLED
# @param originX  abcisse de la consigne (en pixel)
# @param originY  ordonnee de la consigne (en pixel)
# @param starX   abcisse de l'etoile (en pixel)
# @param starY   ordonnee de l'etoile (en pixel)
# @param starDx  ecart alpha de l'etoile (en arcsec)
# @param starDy  ecart delta de l'etoile (en arcsec)
# @param alphaCorrection  correction en alpha (en arcsec)
# @param deltaCorrection  correction en delta (en arcsec)
# @param originDx correction de la consigne en X  (en pixel)
# @param originDy correction de la consigne en Y  (en pixel)
# @param background  fond du ciel
# @param maxIntensity  intensité max
# @return null
#------------------------------------------------------------
proc ::sophie::control::setGuideInformation { starDetection fiberStatus originX originY starX starY starDx starDy alphaCorrection deltaCorrection originDx originDy background maxIntensity} {
   variable private

   set frm $private(frm)

   #--- je mets a jour le voyant "etoileDetecte"
   if { $starDetection == 0 } {
      $frm.voyant.etoile_color_invariant configure \
         -text $::caption(sophie,etoileNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.voyant.etoile_color_invariant configure \
         -text $::caption(sophie,etoileDetecte) \
         -bg   $private(activeColor)
   }

   #--- je mets a jour le voyant "trouDetecte"
   switch $fiberStatus {
      "DETECTED" {
         #--- le trou est détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouDetecte) \
            -bg   $private(activeColor)
      }
      "DISABLED" {
         #--- la detection du trou est desactivee
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,tourNonRecherche) \
            -bg   "SystemButtonFace"
      }
      "INTEGRATING" {
         #--- l'integration des premieres images est en cours
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,integrationEncours) \
            -bg   "SystemButtonFace"
      }
      "LOW_SIGNAL" -
      "TOO_FAR" -
      "OUTSIDE" -
      "NO_SIGNAL" -
      "OUTSIDE" -
      default {
         #--- le trou n'est pas détecte
         $frm.voyant.trou_color_invariant configure \
            -text "$::caption(sophie,trouNonDetecte) ($fiberStatus)" \
            -bg   $private(inactiveColor)
      }
   }

   set private(indicateursFwhmX)      ""
   set private(indicateursFwhmY)      ""
   set private(indicateursFondDeCiel) ""
   set private(indicateursFluxMax)    ""

   set private(positionEtoileX)   [format "%6.1f" $starX]
   set private(positionEtoileY)   [format "%6.1f" $starY]
   set private(positionConsigneX) [format "%6.1f" $originX]
   set private(positionConsigneY) [format "%6.1f" $originY]
   set private(ecartConsigneX)    [format "%6.2f" $originDx]
   set private(ecartConsigneY)    [format "%6.2f" $originDy]
   set private(ecartEtoileX)      [format "%6.2f" $starDx]
   set private(ecartEtoileY)      [format "%6.2f" $starDy]
   set private(alphaCorrection)   [format "%6.2f" $alphaCorrection]
   set private(deltaCorrection)   [format "%6.2f" $deltaCorrection]
   set private(indicateursFondDeCiel) [format "%6.1f" $background]
   set private(indicateursFluxMax)    [format "%6.1f" $maxIntensity]

   #--- j'ajoute la valeur le graphe sophieEcartConsigneX
   ::sophieEcartConsigneX append $originDx
   if { [::sophieEcartConsigneX length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieEcartConsigneX delete 0
   }

   #--- j'ajoute la valeur le graphe sophieEcartConsigneY
   ::sophieEcartConsigneY append $originDy
   if { [::sophieEcartConsigneY length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieEcartConsigneY delete 0
   }

   #--- j'ajoute la valeur le graphe sophieEcartEtoileX
   ::sophieEcartEtoileX append $starDx
   if { [::sophieEcartEtoileX length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieEcartEtoileX delete 0
   }

   #--- j'ajoute la valeur le graphe sophieEcartEtoileY
   ::sophieEcartEtoileY append $starDy
   if { [::sophieEcartEtoileY length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieEcartEtoileY delete 0
   }

   #--- j'ajoute la valeur le graphe alphaCorrection
   ::sophieCorrectionAlpha append $alphaCorrection
   if { [::sophieCorrectionAlpha length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieCorrectionAlpha delete 0
   }

   #--- j'ajoute la valeur le graphe deltaCorrection
   ::sophieCorrectionDelta append $deltaCorrection
   if { [::sophieCorrectionDelta length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieCorrectionDelta delete 0
   }
}

##------------------------------------------------------------
# setOriginCoords
#    met a jour les coordonnes de la consigne
#
# @param originX  abcisse de la consigne en pixel
# @param originY  ordonnee de la consigne en pixel
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setOriginCoords { originX originY } {
   variable private

   set private(positionObjetX)   [format "%6.1f" $originX]
   set private(positionObjetY)   [format "%6.1f" $originY]
}

##------------------------------------------------------------
# setTargetCoords
#    met a jour les coordonnes de l'etoile
#
# @param starX  abcisse de l'etoile en pixel (referentiel image binning 1x1 sans fentrage)
# @param starY  ordonnee de l'etoile en pixel (referentiel image binning 1x1 sans fentrage)
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setTargetCoords { starX starY } {
   variable private

   set private(positionEtoileX)   [format "%6.1f" $starX]
   set private(positionEtoileY)   [format "%6.1f" $starY]
}

#
# ::fingerlakes::dispTempFLI
#    Affiche la temperature du CCD
#

proc ::sophie::control::dispTempFLI { camItem } {
   variable private
   global caption

   if { [ catch { set temppower [ cam$private($camItem,camNo) temppower ] } ] == "0" } {
      set internTemp [ format "%+5.2f" [lindex $temppower 0] ]
      set externTemp [ format "%+5.2f" [lindex $temppower 1] ]
      set power      [ format "%+5.2f" [lindex $temppower 2] ]
      set private(ccdTemp)   "$caption(fingerlakes,temperature_CCD): $internTemp $caption(fingerlakes,deg_c) / $externTemp $caption(fingerlakes,deg_c) $caption(fingerlakes,power): $power %"
      set private(aftertemp) [ after 5000 ::fingerlakes::dispTempFLI $camItem ]
   } else {
      set temp_ccd ""
      set private(ccdTemp) "$caption(fingerlakes,temperature_CCD): -- $caption(fingerlakes,deg_c) / -- $caption(fingerlakes,deg_c) $caption(fingerlakes,power): -- %"
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   }
}

#------------------------------------------------------------
# replaceOriginCoordinates
#   remplace la position de la consigne par la position de l'etoile
# @param numero de la visu
# @param type de position (HR ou HE)
# @return rien
#------------------------------------------------------------
proc ::sophie::control::replaceOriginCoordinates { visuNo } {
   variable widget

   #--- je copie les coordonnees courante de la fenetre principale dans la variable globale
   set ::conf(sophie,objectCoord) $::sophie::private(targetCoord)
   #--- je copie les coordonnees courante de la fenetre principale dans les variables
   set private(positionObjetX) [lindex $::sophie::private(targetCoord) 0]
   set private(positionObjetY) [lindex $::sophie::private(targetCoord) 1]

   #--- je met a jour l'affichage de la fenetre principale
   ::sophie::setGuidingMode $visuNo
}

proc ::sophie::control::resetFocusVector {  } {
   #--- raz des vecteurs
   if { [::sophieFwhmX length] > 0 } {
      ::sophieFwhmX delete 0:end
   }
   if { [::sophieFwhmY length] > 0 } {
      ::sophieFwhmY delete 0:end
   }
   if { [::sophieMaxIntensity length] > 0 } {
      ::sophieMaxIntensity delete 0:end
   }
}

proc ::sophie::control::resetGuideVector {  } {
   #--- raz des vecteurs

   if { [::sophieEcartConsigneX length] > 0 } {
      ::sophieEcartConsigneX delete 0:end
   }
   if { [::sophieEcartConsigneY length] > 0 } {
      ::sophieEcartConsigneY delete 0:end
   }
   if { [::sophieEcartEtoileX length] > 0 } {
      ::sophieEcartEtoileX delete 0:end
   }
   if { [::sophieEcartEtoileY length] > 0 } {
      ::sophieEcartEtoileY delete 0:end
   }
   if { [::sophieCorrectionAlpha length] > 0 } {
      ::sophieCorrectionAlpha delete 0:end
   }
   if { [::sophieCorrectionDelta length] > 0 } {
      sophieCorrectionDelta delete 0:end
   }
}

#############################################################
#  gestion du zoom des graphes
#############################################################

#------------------------------------------------------------
# onGraphMotion
#    affiche les coordonnees du curseur de la souris
#    apres chaque deplacement de la souris dans le graphe
#------------------------------------------------------------
proc ::sophie::control::onGraphMotion { graph xScreen yScreen } {
   set x [ $graph axis invtransform x $xScreen ]
   set y [ $graph axis invtransform y $yScreen ]
   set lx [ string length $x ]
   if {$lx>8} { set x [ string range $x 0 7 ] }
   set ly [ string length $y ]
   if {$ly>8} { set y [ string range $y 0 7 ] }
   $graph crosshairs configure -position @$xScreen,$yScreen
}


#------------------------------------------------------------
# onGraphRegionStart
#  demarre la selection d'une region du graphe avec la souris
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#    xScreen yScreen  coordoonnees ecran de la souris
#  @return
#    rien
#------------------------------------------------------------
proc ::sophie::control::onGraphRegionStart { visuNo graph x y } {
   variable private

   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   $graph marker create line -coords {} -name myLine \
      -dashes dash -xor yes
   set private($visuNo,regionStartX) $x
   set private($visuNo,regionStartY) $y
}

#------------------------------------------------------------
# onGraphRegionMotion
#  modifie la selection d'une region du graphe avec la souris
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#    xScreen yScreen  coordoonnees ecran de la souris
#  @return
#     rien
#------------------------------------------------------------
proc ::sophie::control::onGraphRegionMotion { visuNo graph x y } {
   variable private

   if { [info exists private($visuNo,regionStartX)] } {
      set x0 $private($visuNo,regionStartX)
      set y0 $private($visuNo,regionStartY)
      set x [$graph axis invtransform x $x]
      set y [$graph axis invtransform y $y]
      $graph marker configure myLine -coords \
         "$x0 $y0 $x0 $y $x $y $x $y0 $x0 $y0"
   }
}

#------------------------------------------------------------
# onGraphRegionEnd
#  termine la selection d'une region du graphe avec la souris
#  et applique un zoom sur cette region

# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#    xScreen yScreen  coordoonnees ecran de la souris
#  @return
#     rien
#------------------------------------------------------------
proc ::sophie::control::onGraphRegionEnd { visuNo graph x y } {
   variable private

   if { [info exists private($visuNo,regionStartX)] } {
      set x0 $private($visuNo,regionStartX)
      set y0 $private($visuNo,regionStartY)
      $graph marker delete myLine
      set x [$graph axis invtransform x $x]
      set y [$graph axis invtransform y $y]
      onGraphZoom $visuNo $graph $x0 $y0 $x $y

      unset private($visuNo,regionStartX)
      unset private($visuNo,regionStartY)
   }
}

#------------------------------------------------------------
# onGraphZoom
#  applique le zoom sur une region du graphe
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#  @return
#     rien
#------------------------------------------------------------
proc ::sophie::control::onGraphZoom { visuNo graph x1 y1 x2 y2 } {
   variable private

   if { $x1 > $x2 } {
      $graph axis configure x -min $x2 -max $x1
   } elseif { $x1 < $x2 } {
      $graph axis configure x -min $x1 -max $x2
   }
   if { $y1 > $y2 } {
      $graph axis configure y -min $y2 -max $y1
   } elseif { $y1 < $y2 } {
      $graph axis configure y -min $y1 -max $y2
   }
}

#------------------------------------------------------------
# onGraphUnzoom
#  supprime le zoom sur le graphe
#
# Parameters
#    graph   nom tk du graphe
#  @return
#     rien
#------------------------------------------------------------
proc ::sophie::control::onGraphUnzoom { graph  } {
   variable private

   $graph axis configure x y -min {} -max {}
}

