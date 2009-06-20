#
# Fichier : sophiecontrol.tcl
# Description : Fenetre de controle pour le centrage, la focalisation et le guidage
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophiecontrol.tcl,v 1.19 2009-06-20 17:32:26 michelpujol Exp $
#

##------------------------------------------------------------
# @brief   fenetre de controle pour le centrage, la focalisation et le guidage
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
   set private(positionObjetX)                  [lindex $::conf(sophie,originCoord) 0]
   set private(positionObjetY)                  [lindex $::conf(sophie,originCoord) 1]
   set private(focalisationCourbesIntensiteMax) ""
   set private(guidageIncrement)                "0.1"
   set private(guidagePhotocentrePositionX)     ""
   set private(guidagePhotocentrePositionY)     ""
   set private(ecartEtoileX)                    ""
   set private(ecartEtoileY)                    ""
   set private(ecartConsigneX)                  ""
   set private(ecartConsigneY)                  ""
   set private(correctionAlpha)                 ""
   set private(correctionDelta)                 ""
   set private(realDelay)                        ""

   set private(activeColor)                     "#77ff77" ; #--- vert tendre
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
   $private(frm).focalisation.courbes.graphFwhmX_simple axis configure x -hide true
   $private(frm).focalisation.courbes.graphFwhmY_simple axis configure x -hide true
   $private(frm).focalisation.courbes.graphintensiteMax_simple axis configure x -hide true

   $private(frm).guidage.positionconsigne.correction.ecartConsigne_simple axis configure x -hide true
   $private(frm).guidage.erreurs.alpha_simple axis configure x -hide true
   $private(frm).guidage.corrections.delta_simple axis configure x -hide true

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
         -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
         -text $::caption(sophie,acquisitionArretee)

      grid $frm.voyant.acquisition_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 0 -column 0 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

      #--- Indicateur etoile selectionnee ou non
      label $frm.voyant.etoile_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
         -text $::caption(sophie,etoileNonDetecte)
      grid $frm.voyant.etoile_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 1 -column 0 -sticky ns -padx 4 -pady 4 -ipadx 10 -ipady 4

      #--- Indicateur trou detecte ou non
      label $frm.voyant.trou_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
         -text $::caption(sophie,trouNonDetecte)
      grid $frm.voyant.trou_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 1 -column 1 -sticky ns -padx 4 -pady 4 -ipadx 10 -ipady 4

      #--- Indicateur guidage en cours ou arrete
      label $frm.voyant.guidage_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
         -text $::caption(sophie,guidageSuspendu)
      grid $frm.voyant.guidage_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 2 -column 0 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

      #--- Indicateur pose Sophie en cours ou arretee
      label $frm.voyant.sophie_color_invariant \
         -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
         -text $::caption(sophie,sophieArretee)
      grid $frm.voyant.sophie_color_invariant \
         -in [ $frm.voyant getframe ] \
         -row 3 -column 0 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

      #--- Indicateur durée entre 2 poses
      LabelEntry $frm.voyant.entryRealDelay \
         -borderwidth 0 -relief flat\
         -label $::caption(sophie,realDelay) \
         -labelanchor w  -width 8 -padx 2 \
         -justify center -state normal\
         -textvariable ::sophie::control::private(realDelay)
      grid $frm.voyant.entryRealDelay \
         -in [ $frm.voyant getframe ] \
         -row 4 -column 0 -columnspan 2 -sticky w

      grid columnconfigure [ $frm.voyant getframe ] 0 -weight 1
      grid columnconfigure [ $frm.voyant getframe ] 1 -weight 1

   #--- Frame pour la position et le seeing du centrage et de la focalisation
   TitleFrame $frm.positionSeeing -borderwidth 2 -relief ridge \
      -text $::caption(sophie,positionSeeing)

      #--- Position x
      label $frm.positionSeeing.labelPositionX -text $::caption(sophie,x)
      grid $frm.positionSeeing.labelPositionX \
         -in [ $frm.positionSeeing getframe ] \
         -row 0 -column 1 -sticky ew

      Entry $frm.positionSeeing.entryPositionX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionEtoileX)
      grid $frm.positionSeeing.entryPositionX \
         -in [ $frm.positionSeeing getframe ] \
         -row 0 -column 2 -sticky ens

      #--- Position y
      label $frm.positionSeeing.labelPositionY -text $::caption(sophie,y)
      grid $frm.positionSeeing.labelPositionY \
         -in [ $frm.positionSeeing getframe ] \
         -row 1 -column 1 -sticky ew

      Entry $frm.positionSeeing.entryPositionY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionEtoileY)
      grid $frm.positionSeeing.entryPositionY \
         -in [ $frm.positionSeeing getframe ] \
         -row 1 -column 2 -sticky ens

      #--- FWHM X
      label $frm.positionSeeing.labelFWHMX -text $::caption(sophie,FWHMX)
      grid $frm.positionSeeing.labelFWHMX \
         -in [ $frm.positionSeeing getframe ] \
         -row 0 -column 3 -sticky ew

      Entry $frm.positionSeeing.entryFWHMX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFwhmX)
      grid $frm.positionSeeing.entryFWHMX \
         -in [ $frm.positionSeeing getframe ] \
         -row 0 -column 4 -sticky ens

      #--- FWHM Y
      label $frm.positionSeeing.labelFWHMY -text $::caption(sophie,FWHMY)
      grid $frm.positionSeeing.labelFWHMY \
         -in [ $frm.positionSeeing getframe ] \
         -row 1 -column 3 -sticky ew

      Entry $frm.positionSeeing.entryFWHMY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFwhmY)
      grid $frm.positionSeeing.entryFWHMY \
         -in [ $frm.positionSeeing getframe ] \
         -row 1 -column 4 -sticky ens

      #--- Fond de ciel
      label $frm.positionSeeing.labelfondDeCiel -text $::caption(sophie,fondDeCiel)
      grid $frm.positionSeeing.labelfondDeCiel \
         -in [ $frm.positionSeeing getframe ] \
         -row 0 -column 5 -sticky ew

      Entry $frm.positionSeeing.entryfondDeCiel \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFondDeCiel)
      grid $frm.positionSeeing.entryfondDeCiel \
         -in [ $frm.positionSeeing getframe ] \
         -row 0 -column 6 -sticky ens

      #--- Flux maxi
      label $frm.positionSeeing.labelfluxMax -text $::caption(sophie,fluxMax)
      grid $frm.positionSeeing.labelfluxMax \
         -in [ $frm.positionSeeing getframe ] \
         -row 1 -column 5 -sticky ew

      Entry $frm.positionSeeing.entryfluxMax \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(indicateursFluxMax)
      grid $frm.positionSeeing.entryfluxMax \
         -in [ $frm.positionSeeing getframe ] \
         -row 1 -column 6 -sticky ens

      grid columnconfigure [ $frm.positionSeeing getframe ] 0 -weight 0
      grid columnconfigure [ $frm.positionSeeing getframe ] 1 -weight 1
      grid columnconfigure [ $frm.positionSeeing getframe ] 2 -weight 0
      grid columnconfigure [ $frm.positionSeeing getframe ] 3 -weight 1
      grid columnconfigure [ $frm.positionSeeing getframe ] 4 -weight 0
      grid columnconfigure [ $frm.positionSeeing getframe ] 5 -weight 1


   #--- Frame pour la position du guidage
   TitleFrame $frm.positionGuidage -borderwidth 2 -relief ridge \
      -text $::caption(sophie,positionGuidage)

      #--- Position etoile
      label $frm.positionGuidage.labelPosition -text $::caption(sophie,positionEtoile)
      grid $frm.positionGuidage.labelPosition \
         -in [ $frm.positionGuidage getframe ] \
         -row 0 -column 0 -columnspan 2 -sticky ew

      #--- Position etoile x
      label $frm.positionGuidage.labelPositionEtoileX -text $::caption(sophie,x)
      grid $frm.positionGuidage.labelPositionEtoileX \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 0 -sticky ew

      Entry $frm.positionGuidage.entryPositionEtoileX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionEtoileX)
      grid $frm.positionGuidage.entryPositionEtoileX \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 1 -sticky ew

      #--- Position etoile y
      label $frm.positionGuidage.labelPositionEtoileY -text $::caption(sophie,y)
      grid $frm.positionGuidage.labelPositionEtoileY \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 0 -sticky ew

      Entry $frm.positionGuidage.entryPositionEtoileY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionEtoileY)
      grid $frm.positionGuidage.entryPositionEtoileY \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 1 -sticky ew

      #--- Position consigne
      label $frm.positionGuidage.labelConsigne -text $::caption(sophie,positionConsigne)
      grid $frm.positionGuidage.labelConsigne \
         -in [ $frm.positionGuidage getframe ] \
         -row 0 -column 2 -columnspan 2 -sticky ew

      #--- Position consigne X
      label $frm.positionGuidage.labelPositionConsigneX -text $::caption(sophie,x)
      grid $frm.positionGuidage.labelPositionConsigneX \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 2 -sticky ew

      Entry $frm.positionGuidage.entryPositionConsigneX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionConsigneX)
      grid $frm.positionGuidage.entryPositionConsigneX \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 3 -sticky ew

      #--- Positionconsigne Y
      label $frm.positionGuidage.labelPositionConsigneY -text $::caption(sophie,y)
      grid $frm.positionGuidage.labelPositionConsigneY \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 2 -sticky ew

      Entry $frm.positionGuidage.entryPositionConsigneY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(positionConsigneY)
      grid $frm.positionGuidage.entryPositionConsigneY \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 3 -sticky ew

      #--- Ecart etoile
      label $frm.positionGuidage.labelEcartEtoile -text $::caption(sophie,ecartEtoile)
      grid $frm.positionGuidage.labelEcartEtoile \
         -in [ $frm.positionGuidage getframe ] \
         -row 0 -column 4 -columnspan 2 -sticky ew

      #--- Ecart etoile X
      label $frm.positionGuidage.labelEcartEtoileX -text $::caption(sophie,dx)
      grid $frm.positionGuidage.labelEcartEtoileX \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 4 -sticky ew

      Entry $frm.positionGuidage.entryEcartEtoileX \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(ecartEtoileX)
      grid $frm.positionGuidage.entryEcartEtoileX \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 5 -sticky ew

      #--- Ecart etoile Y
      label $frm.positionGuidage.labelEcartEtoileY -text $::caption(sophie,dy)
      grid $frm.positionGuidage.labelEcartEtoileY \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 4 -sticky ew

      Entry $frm.positionGuidage.entryEcartEtoileY \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(ecartEtoileY)
      grid $frm.positionGuidage.entryEcartEtoileY \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 5 -sticky ew

      #--- Correction
      label $frm.positionGuidage.labelCorrection -text $::caption(sophie,correction1)
      grid $frm.positionGuidage.labelCorrection \
         -in [ $frm.positionGuidage getframe ] \
         -row 0 -column 6 -columnspan 2 -sticky ew

      #--- Correction alpha
      label $frm.positionGuidage.labelCorrectionAlpha -text $::caption(sophie,alpha)
      grid $frm.positionGuidage.labelCorrectionAlpha \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 6 -sticky ew

      Entry $frm.positionGuidage.entryCorrectionAlpha \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(correctionAlpha)
      grid $frm.positionGuidage.entryCorrectionAlpha \
         -in [ $frm.positionGuidage getframe ] \
         -row 1 -column 7 -sticky ew

      #--- Correction delta
      label $frm.positionGuidage.labelCorrectionDelta -text $::caption(sophie,delta)
      grid $frm.positionGuidage.labelCorrectionDelta \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 6 -sticky ew

      Entry $frm.positionGuidage.entryCorrectionDelta \
         -width 8 -justify center -editable 0 \
         -textvariable ::sophie::control::private(correctionDelta)
      grid $frm.positionGuidage.entryCorrectionDelta \
         -in [ $frm.positionGuidage getframe ] \
         -row 2 -column 7 -sticky ew

      grid columnconfigure [ $frm.positionGuidage getframe ] 0 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 1 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 2 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 3 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 4 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 5 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 6 -weight 1
      grid columnconfigure [ $frm.positionGuidage getframe ] 7 -weight 1

   #--- Frame du centrage
   frame $frm.centrage -borderwidth 1 -relief groove

      #--- Frame pour l'indicateur de centrage
      TitleFrame $frm.centrage.centrageConsigne -borderwidth 2 -relief ridge \
         -text $::caption(sophie,indicateurCentrage)

         #--- Commande de centrage ( doublon avec la commande de la fenetre principale)
         checkbutton $frm.centrage.centrageConsigne.start \
            -indicatoron 0  -state disabled \
            -text $::caption(sophie,lancerCentrage) \
            -variable ::sophie::private(centerEnabled) \
            -command "::sophie::onCenter"

         pack $frm.centrage.centrageConsigne.start \
            -in [ $frm.centrage.centrageConsigne getframe ] \
            -side left -expand 1 -pady 4 -ipadx 10 -ipady 4

         #--- Indicateur Centrage en cours ou non
         label $frm.centrage.centrageConsigne.indicateur -text $::caption(sophie,centrageArrete) \
            -borderwidth 1 -relief  groove -bg $private(inactiveColor)

         pack $frm.centrage.centrageConsigne.indicateur \
            -in [ $frm.centrage.centrageConsigne getframe ] \
            -side left -expand 1 -pady 4 -ipadx 10 -ipady 4

      pack $frm.centrage.centrageConsigne -side top -anchor w -fill x -expand 1

      #--- Frame pour le mode de pointage (Fibre ou objet)
      TitleFrame $frm.centrage.pointage -borderwidth 2 -relief ridge \
         -text $::caption(sophie,consigne)

         #--- Frame pour les indicateurs
         frame $frm.centrage.pointage.indicateur -borderwidth 0 -relief ridge

            #--- Indicateur de pointage de l'objet
            radiobutton $frm.centrage.pointage.indicateur.objet \
               -indicatoron 0 -text $::caption(sophie,pointageObjet) -value OBJECT \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namespace ::sophie
            pack $frm.centrage.pointage.indicateur.objet -anchor center \
               -expand 1 -fill x -side left -ipadx 4 -ipady 4

            #--- Indicateur de pointage de l'entree de la fibre
            radiobutton $frm.centrage.pointage.indicateur.fibreA \
               -indicatoron 0 -text $::caption(sophie,pointageEntreeFibreA) -value FIBER \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namespace ::sophie
            pack $frm.centrage.pointage.indicateur.fibreA -anchor center \
               -expand 1 -fill x -side left -ipadx 4 -ipady 4

         pack $frm.centrage.pointage.indicateur \
            -in [ $frm.centrage.pointage getframe ] \
            -side top -anchor w -fill x -expand 1

         #--- Frame pour la position en X et Y de l'objet
         frame $frm.centrage.pointage.positionXY -borderwidth 0 -relief ridge

            #--- Position X
            label $frm.centrage.pointage.positionXY.labelX -text $::caption(sophie,x)
            grid $frm.centrage.pointage.positionXY.labelX -row 0 -column 1 -sticky w -padx 5 -pady 3

            spinbox $frm.centrage.pointage.positionXY.spinboxX -from 1 -to 1536 -incr 0.1 \
               -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetX)
            grid $frm.centrage.pointage.positionXY.spinboxX -row 0 -column 2 -sticky ens

            #--- Position Y
            label $frm.centrage.pointage.positionXY.labelY -text $::caption(sophie,y)
            grid $frm.centrage.pointage.positionXY.labelY -row 0 -column 3 -sticky w -padx 5 -pady 3

            spinbox $frm.centrage.pointage.positionXY.spinboxY -from 1 -to 1024 -incr 0.1 \
               -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetY)
            grid $frm.centrage.pointage.positionXY.spinboxY -row 0 -column 4 -sticky ens

      pack $frm.centrage.pointage -side top -anchor w -fill x -expand 1

   #--- Frame de la focalisation
   frame $frm.focalisation -borderwidth 1 -relief groove

      #--- Frame des courbes
      TitleFrame $frm.focalisation.courbes -borderwidth 2 -relief ridge \
         -text $::caption(sophie,courbes)

         #--- FWHM X
         createGraph $frm.focalisation.courbes.graphFwhmX_simple 120
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
         createGraph $frm.focalisation.courbes.graphFwhmY_simple 120
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
         createGraph $frm.focalisation.courbes.graphintensiteMax_simple 120
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

      #--- Frame de la position de la consigne sur la fibre
      TitleFrame $frm.guidage.positionconsigne -borderwidth 2 -relief ridge \
         -text $::caption(sophie,positionConsigneImage)

         #--- Frame pour la position en X et Y de la consigne dans l'image
         frame $frm.guidage.positionconsigne.correction -borderwidth 0 -relief ridge

            #--- Graphe de la erreur en alpha et delta
            createGraph $frm.guidage.positionconsigne.correction.ecartConsigne_simple 105
            $frm.guidage.positionconsigne.correction.ecartConsigne_simple element create ecartConsigneX \
               -xdata ::sophieAbcisse -ydata ::sophieEcartConsigneX -mapy y \
               -color blue -dash "2" -linewidth 3 \
               -symbol none -label $::caption(sophie,dx)
            $frm.guidage.positionconsigne.correction.ecartConsigne_simple element create ecartConsigneY \
               -xdata ::sophieAbcisse -ydata ::sophieEcartConsigneY -mapy y \
               -color orange -dash "" -linewidth 3 \
               -symbol none -label $::caption(sophie,dy)
            $frm.guidage.positionconsigne.correction.ecartConsigne_simple legend configure -hide no -position right

            grid $frm.guidage.positionconsigne.correction.ecartConsigne_simple \
               -row 0 -column 1 -sticky ew

         pack $frm.guidage.positionconsigne.correction \
           -in [ $frm.guidage.positionconsigne getframe ] \
           -side top -anchor w -fill x

         #--- Frame pour la position en X et Y de la consigne dans l'image
         frame $frm.guidage.positionconsigne.positionXY -borderwidth 0 -relief ridge

            #--- Label
            label $frm.guidage.positionconsigne.positionXY.label \
               -text $::caption(sophie,positionConsigneImage)
            grid $frm.guidage.positionconsigne.positionXY.label \
               -row 0 -column 1 -columnspan 4 -sticky w -padx 5 -pady 3

            #--- Position X
            label $frm.guidage.positionconsigne.positionXY.labelX -text $::caption(sophie,x)
            grid $frm.guidage.positionconsigne.positionXY.labelX \
               -row 1 -column 1 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxX -from 1 -to 1536 \
               -incr $::sophie::control::private(guidageIncrement) -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetX)
            grid $frm.guidage.positionconsigne.positionXY.spinboxX \
               -row 1 -column 2 -sticky ens

            #--- Position Y
            label $frm.guidage.positionconsigne.positionXY.labelY -text $::caption(sophie,y)
            grid $frm.guidage.positionconsigne.positionXY.labelY \
               -row 1 -column 3 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxY -from 1 -to 1024 \
               -incr $::sophie::control::private(guidageIncrement) -width 8 -justify center \
               -command "::sophie::control::onScrollOrigin $visuNo" \
               -textvariable ::sophie::control::private(positionObjetY)
            grid $frm.guidage.positionconsigne.positionXY.spinboxY \
               -row 1 -column 4 -sticky ens

            #--- Increment
            label $frm.guidage.positionconsigne.positionXY.labelIncrement \
               -text $::caption(sophie,increment)
            grid $frm.guidage.positionconsigne.positionXY.labelIncrement \
               -row 1 -column 5 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxIncrement \
               -values { 0.01 0.1 1 10 } -width 5 -justify center \
               -command "::sophie::adaptIncrement" \
               -textvariable ::sophie::control::private(guidageIncrement)
            grid $frm.guidage.positionconsigne.positionXY.spinboxIncrement \
               -row 1 -column 6 -sticky ens

        # pack $frm.guidage.positionconsigne.positionXY \
        #    -in [ $frm.guidage.positionconsigne getframe ] \
        #    -side top -anchor w -fill x -expand 1

      pack $frm.guidage.positionconsigne -side top -anchor w -fill x -expand 1

      #--- Frame pour visualiser les erreurs en alpha et delta
      TitleFrame $frm.guidage.erreurs -borderwidth 2 -relief ridge \
         -text $::caption(sophie,erreursAlphaDelta)

         #--- Graphe de la erreur en alpha et delta
         createGraph $frm.guidage.erreurs.alpha_simple 105
         $frm.guidage.erreurs.alpha_simple element create alphaDiff \
            -xdata ::sophieAbcisse -ydata ::sophieEcartEtoileX -mapy y \
            -color blue -dash "2" -linewidth 3 \
           -symbol none -label $::caption(sophie,alpha)
         $frm.guidage.erreurs.alpha_simple element create deltaDiff \
            -xdata ::sophieAbcisse -ydata ::sophieEcartEtoileY -mapy y \
            -color orange -dash "" -linewidth 3 \
            -symbol none -label $::caption(sophie,delta)
         $frm.guidage.erreurs.alpha_simple legend configure -hide no -position right

         grid $frm.guidage.erreurs.alpha_simple \
            -in [ $frm.guidage.erreurs getframe ] \
            -row 0 -column 1 -sticky nsew

      pack $frm.guidage.erreurs -side top -anchor w -fill x -expand 1

      #--- Frame pour visualiser les corrections au telescope en alpha et delta
      TitleFrame $frm.guidage.corrections -borderwidth 2 -relief ridge \
         -text $::caption(sophie,correction)

         #--- Graphe de la correction en delta
         createGraph $frm.guidage.corrections.delta_simple 105
         $frm.guidage.corrections.delta_simple element create alphaCorrection \
            -xdata ::sophieAbcisse -ydata ::sophieCorrectionAlpha -mapy y \
            -color blue -dash "2" -linewidth 3 \
            -symbol none -label $::caption(sophie,alpha)
         $frm.guidage.corrections.delta_simple element create deltaCorrection \
            -xdata ::sophieAbcisse -ydata ::sophieCorrectionDelta -mapy y \
            -color orange -dash "" -linewidth 3 \
            -symbol none -label $::caption(sophie,delta)
         $frm.guidage.corrections.delta_simple legend configure -hide no -position right

         grid $frm.guidage.corrections.delta_simple \
            -in [ $frm.guidage.corrections getframe ] \
            -row 1 -column 1 -sticky nsew

        ### grid columnconfig [ $frm.guidage.erreurs getframe ] 0 -weight 0
        ### grid columnconfig [ $frm.guidage.erreurs getframe ] 1 -weight 1
      pack $frm.guidage.corrections -side top -anchor w -fill x -expand 1

    # pack $frm.guidage -side top -fill both

}

#------------------------------------------------------------
# setGuidingMode
#    ouvre les spinbox pour le pointage d'un objet
#    place la consigne au bon endroit
#------------------------------------------------------------
proc ::sophie::control::setGuidingMode { guidingMode } {
   variable private

   set frm $private(frm)
   if { $guidingMode == "OBJECT" } {
      pack $frm.centrage.pointage.positionXY \
         -in [ $frm.centrage.pointage getframe ] \
         -side top -anchor w -fill x -expand 1
      pack $frm.guidage.positionconsigne.positionXY \
         -in [ $frm.guidage.positionconsigne getframe ] \
         -side top -anchor w -fill x -expand 1
      pack forget $frm.guidage.positionconsigne.correction
   } elseif { $guidingMode == "FIBER" } {
      pack forget $frm.centrage.pointage.positionXY
      pack forget $frm.guidage.positionconsigne.positionXY
      pack $frm.guidage.positionconsigne.correction \
         -in [ $frm.guidage.positionconsigne getframe ] \
         -side top -anchor w -fill x -expand 1
   }
}

#------------------------------------------------------------
# onScrollOrigin
#    modifie la position de la consigne
#------------------------------------------------------------
proc ::sophie::control::onScrollOrigin { visuNo args } {
   variable private

   #--- je copie les coordonnees dans la vairable globale
   set ::conf(sophie,originCoord) [list $private(positionObjetX) $private(positionObjetY) ]

   #--- je met a jour l'affichage de la fenetre principale
   ::sophie::setGuidingMode $visuNo

}

#------------------------------------------------------------
# createGraph
#    affichage de graphiques
#
#------------------------------------------------------------
proc ::sophie::control::createGraph { graph height } {
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

   bind $graph <Motion> "::sophie::control::onGraphMotion %W %x %y"
}

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
      if { [ winfo exists $frm ] } {
         switch $mode {
            "CENTER" {
               pack forget $frm.positionGuidage
               pack forget $frm.guidage
               pack forget $frm.focalisation
               pack $frm.voyant         -side top -fill x
               pack $frm.positionSeeing -side top -fill x
               pack $frm.centrage       -side top -fill x
            }
            "FOCUS" {
               pack forget $frm.positionGuidage
               pack forget $frm.centrage
               pack forget $frm.guidage
               pack $frm.voyant         -side top -fill x
               pack $frm.positionSeeing -side top -fill x
               pack $frm.focalisation   -side top -fill x
               #--- raz des vecteurs
               resetFocusVector
            }
            "GUIDE" {
               pack forget $frm.positionSeeing
               pack forget $frm.centrage
               pack forget $frm.focalisation
               pack $frm.voyant          -side top -fill x
               pack $frm.positionGuidage -side top -fill x
               pack $frm.guidage         -side top -fill x
               #--- raz des vecteurs
               resetGuideVector
            }
         }
         set This "$::audace(base).sophiecontrol"
         wm title $This "$::caption(sophie,$mode)"
         focus $frm
      }
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
# setRealDelay
#    met a jour le delai entre 2 poses
#
# @param delay   delai entre 2 poses en seconde
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setRealDelay { delay } {
   variable private

   #--- je formate le délai avant de l'afficher
   set  private(realDelay) [format "%6.3f" $delay ]

}

##------------------------------------------------------------
# setCenterInformation
#    affiche les informations de centrage
#
# @param starDetection 0=etoile non detecte 1=etoile detecte
# @param fiberDetection 0=fibre non detecte 1=fibre detecte
# @param originX  abcisse de la consigne en pixel
# @param originY  ordonnee de la consigne en pixel
# @param starX   abcisse de l'etoile en pixel
# @param starY   ordonnee de l'etoile en pixel
# @param fwhmX   largeur a mi hauter sur l'axe X
# @param fwhmY   largeur a mi hauter sur l'axe Y
# @param background   fond du ciel
# @param maxIntensity  intensité max
#
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setCenterInformation { starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxIntensity } {
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
   switch $fiberDetection {
      "0" {
         #--- le trou n'est pas détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouNonDetecte) \
            -bg   $private(inactiveColor)
      }
      "1" {
         #--- le trou est détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouDetecte) \
            -bg   $private(activeColor)
      }
      "2" {
         #--- la detection du trou est desactivee
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,tourNonRecherche) \
            -bg   "SystemButtonFace"
      }
   }

   set private(positionEtoileX)       [format "%6.1f" $starX]
   set private(positionEtoileY)       [format "%6.1f" $starY]
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
# @param fiberDetection 0=fibre non detecte 1=fibre detecte
# @param originX  abcisse de la consigne en pixel
# @param originY  ordonnee de la consigne en pixel
# @param starX   abcisse de l'etoile en pixel
# @param starY   ordonnee de l'etoile en pixel
# @param fwhmX   largeur a mi hauter sur l'axe X
# @param fwhmY   largeur a mi hauter sur l'axe Y
# @param background   fond du ciel
# @param maxIntensity intensité max
#
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setFocusInformation { starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxIntensity } {
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
   switch $fiberDetection {
      "0" {
         #--- le trou n'est pas détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouNonDetecte) \
            -bg   $private(inactiveColor)
      }
      "1" {
         #--- le trou est détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouDetecte) \
            -bg   $private(activeColor)
      }
      "2" {
         #--- la detection du trou est desactivee
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,tourNonRecherche) \
            -bg   "SystemButtonFace"
      }
   }

   set private(positionEtoileX)       [format "%6.1f" $starX]
   set private(positionEtoileY)       [format "%6.1f" $starY]
   set private(indicateursFwhmX)      [format "%6.1f" $fwhmX]
   set private(indicateursFwhmY)      [format "%6.1f" $fwhmY]
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
# @param fiberDetection 0=fibre non detecte 1=fibre detecte
# @param originX  abcisse de la consigne en pixel
# @param originY  ordonnee de la consigne en pixel
# @param starX   abcisse de l'etoile en pixel
# @param starY   ordonnee de l'etoile en pixel
# @param starDx  ecart de l'abcisse de l'etoile en pixel
# @param starDy  ecart de l'ordonne de l'etoile en pixel
# @param alphaCorrection  correction en alpha (en arcseconde)
# @param deltaCorrection  correction en delta (en arcseconde)
# @param originDx correction de la consigne en X  (en pixel)
# @param originDy correction de la consigne en Y  (en pixel)
# @return null
#------------------------------------------------------------
proc ::sophie::control::setGuideInformation { starDetection fiberDetection originX originY starX starY starDx starDy alphaCorrection deltaCorrection originDx originDy} {
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
   switch $fiberDetection {
      "0" {
         #--- le trou n'est pas détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouNonDetecte) \
            -bg   $private(inactiveColor)
      }
      "1" {
         #--- le trou est détecte
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,trouDetecte) \
            -bg   $private(activeColor)
      }
      "2" {
         #--- la detection du trou est desactivee
         $frm.voyant.trou_color_invariant configure \
            -text $::caption(sophie,tourNonRecherche) \
            -bg   "SystemButtonFace"
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
   set private(ecartEtoileX)      [format "%6.1f" $starDx]
   set private(ecartEtoileY)      [format "%6.1f" $starDy]
   set private(ecartConsigneX)    [format "%6.1f" $originDx]
   set private(ecartConsigneY)    [format "%6.1f" $originDy]
   set private(correctionAlpha)   [format "%6.2f" $alphaCorrection]
   set private(correctionDelta)   [format "%6.2f" $deltaCorrection]

   #--- j'ajoute la valeur le graphe starDx
   ::sophieEcartEtoileX append $starDx
   if { [::sophieEcartEtoileX length] >= $private(vectorLength) } {
      #--- je supprime le point le plus ancien
      ::sophieEcartEtoileX delete 0
   }

   #--- j'ajoute la valeur le graphe starDy
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

