#
# Fichier : sophiecontrol.tcl
# Description : Fenetre de controle pour le centrage, la focalisation et le guidage
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophiecontrol.tcl,v 1.7 2009-05-11 18:01:00 robertdelmas Exp $
#

#============================================================
# Declaration du namespace sophie::config
#    initialise le namespace
#============================================================
namespace eval ::sophie::control {
}

#------------------------------------------------------------
# run
#    affiche la fenetre du configuration
#------------------------------------------------------------
proc ::sophie::control::run { tkbase visuNo} {
   variable private

   #--- Initialisation de variables
   set private(indicateursPositionX)            ""
   set private(indicateursPositionY)            ""
   set private(indicateursFWHMX)                ""
   set private(indicateursFWHMY)                ""
   set private(indicateursFondDeCiel)           ""
   set private(indicateursFluxMax)              ""
   set private(centragexObjet)                  "353.2"
   set private(centrageyObjet)                  "470.5"
   set private(focalisationCourbesIntensiteMax) ""
   set private(guidagexObjet)                   "353.2"
   set private(guidageyObjet)                   "470.5"
   set private(guidageIncrement)                "0.1"
   set private(guidagePhotocentrePositionX)     ""
   set private(guidagePhotocentrePositionY)     ""
   set private(guidageDX)                       ""
   set private(guidageDY)                       ""
   set private(guidageErreurAlpha)              ""
   set private(guidageErreurDelta)              ""

   set private(activeColor)                     "green"
   set private(inactiveColor)                   "red"

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,controlWindowPosition) ] } { set ::conf(sophie,controlWindowPosition) "430x540+580+160" }

   #--- j'affiche la fenetre
   set this "$::audace(base).sophiecontrol"
   ::confGenerique::run $visuNo $this "::sophie::control" \
      -modal 0 \
      -geometry $::conf(sophie,controlWindowPosition) \
      -resizable 1 \
      -close 0
   #--- je supprime le bouton fermer
   pack forget $this.but_fermer

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

   #--- Frame des indicateurs
   frame $frm.indicateurs -borderwidth 1 -relief groove

      #--- Frame pour les indicateurs de controle de l'interface
      TitleFrame $frm.indicateurs.controleInterface -borderwidth 2 -relief ridge \
         -text $::caption(sophie,indicateurInterface)

         label $frm.indicateurs.controleInterface.acquisition_color_invariant \
            -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
            -text $::caption(sophie,acquisitionArretee)

         grid $frm.indicateurs.controleInterface.acquisition_color_invariant \
            -in [ $frm.indicateurs.controleInterface getframe ] \
            -row 0 -column 1 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

         #--- Indicateur etoile selectionnee ou non
         label $frm.indicateurs.controleInterface.etoile_color_invariant \
            -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
            -text $::caption(sophie,etoileNonDetecte)
         grid $frm.indicateurs.controleInterface.etoile_color_invariant \
            -in [ $frm.indicateurs.controleInterface getframe ] \
            -row 1 -column 1 -sticky we -padx 4 -pady 4 -ipadx 10 -ipady 4

         #--- Indicateur trou detecte ou non
         label $frm.indicateurs.controleInterface.trou_color_invariant \
            -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
            -text $::caption(sophie,trouNonDetecte)
         grid $frm.indicateurs.controleInterface.trou_color_invariant \
            -in [ $frm.indicateurs.controleInterface getframe ] \
            -row 1 -column 2 -sticky we -padx 4 -pady 4 -ipadx 10 -ipady 4

         #--- Indicateur guidage en cours ou arrete
         label $frm.indicateurs.controleInterface.guidage_color_invariant \
            -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
            -text $::caption(sophie,guidageSuspendu)
         grid $frm.indicateurs.controleInterface.guidage_color_invariant \
            -in [ $frm.indicateurs.controleInterface getframe ] \
            -row 2 -column 1 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

         #--- Indicateur pose Sophie en cours ou arretee
         label $frm.indicateurs.controleInterface.sophie_color_invariant \
            -bg $private(inactiveColor) -borderwidth 1 -relief  groove \
            -text $::caption(sophie,sophieArretee)
         grid $frm.indicateurs.controleInterface.sophie_color_invariant \
            -in [ $frm.indicateurs.controleInterface getframe ] \
            -row 3 -column 1 -columnspan 2 -sticky ns -pady 4 -ipadx 20 -ipady 4

         grid columnconfigure [ $frm.indicateurs.controleInterface getframe ] 0 -weight 1
         grid columnconfigure [ $frm.indicateurs.controleInterface getframe ] 1 -weight 1
         grid columnconfigure [ $frm.indicateurs.controleInterface getframe ] 2 -weight 1
         grid columnconfigure [ $frm.indicateurs.controleInterface getframe ] 3 -weight 1
         grid columnconfigure [ $frm.indicateurs.controleInterface getframe ] 4 -weight 1

      pack $frm.indicateurs.controleInterface -side top -anchor w -fill x -expand 1

      #--- Frame pour la position et le seeing
      TitleFrame $frm.indicateurs.positionSeeing -borderwidth 2 -relief ridge \
         -text $::caption(sophie,positionSeeing)

         #--- Position x
         label $frm.indicateurs.positionSeeing.labelPositionX -text $::caption(sophie,x)
         grid $frm.indicateurs.positionSeeing.labelPositionX \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 0 -column 1 -sticky ew

         Entry $frm.indicateurs.positionSeeing.entryPositionX \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(indicateursPositionX)
         grid $frm.indicateurs.positionSeeing.entryPositionX \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 0 -column 2 -sticky ens

         #--- Position y
         label $frm.indicateurs.positionSeeing.labelPositionY -text $::caption(sophie,y)
         grid $frm.indicateurs.positionSeeing.labelPositionY \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 1 -column 1 -sticky ew

         Entry $frm.indicateurs.positionSeeing.entryPositionY \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursPositionY)
         grid $frm.indicateurs.positionSeeing.entryPositionY \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 1 -column 2 -sticky ens

         #--- FWHM X
         label $frm.indicateurs.positionSeeing.labelFWHMX -text $::caption(sophie,FWHMX)
         grid $frm.indicateurs.positionSeeing.labelFWHMX \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 0 -column 3 -sticky ew

         Entry $frm.indicateurs.positionSeeing.entryFWHMX \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursFWHMX)
         grid $frm.indicateurs.positionSeeing.entryFWHMX \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 0 -column 4 -sticky ens

         #--- FWHM Y
         label $frm.indicateurs.positionSeeing.labelFWHMY -text $::caption(sophie,FWHMY)
         grid $frm.indicateurs.positionSeeing.labelFWHMY \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 1 -column 3 -sticky ew

         Entry $frm.indicateurs.positionSeeing.entryFWHMY \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(indicateursFWHMY)
         grid $frm.indicateurs.positionSeeing.entryFWHMY \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 1 -column 4 -sticky ens

         #--- Fond de ciel
         label $frm.indicateurs.positionSeeing.labelfondDeCiel -text $::caption(sophie,fondDeCiel)
         grid $frm.indicateurs.positionSeeing.labelfondDeCiel \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 0 -column 5 -sticky ew

         Entry $frm.indicateurs.positionSeeing.entryfondDeCiel \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(indicateursFondDeCiel)
         grid $frm.indicateurs.positionSeeing.entryfondDeCiel \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 0 -column 6 -sticky ens

         #--- Flux maxi
         label $frm.indicateurs.positionSeeing.labelfluxMax -text $::caption(sophie,fluxMax)
         grid $frm.indicateurs.positionSeeing.labelfluxMax \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 1 -column 5 -sticky ew

         Entry $frm.indicateurs.positionSeeing.entryfluxMax \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(indicateursFluxMax)
         grid $frm.indicateurs.positionSeeing.entryfluxMax \
            -in [ $frm.indicateurs.positionSeeing getframe ] \
            -row 1 -column 6 -sticky ens

         grid columnconfigure [ $frm.indicateurs.positionSeeing getframe ] 0 -weight 0
         grid columnconfigure [ $frm.indicateurs.positionSeeing getframe ] 1 -weight 1
         grid columnconfigure [ $frm.indicateurs.positionSeeing getframe ] 2 -weight 0
         grid columnconfigure [ $frm.indicateurs.positionSeeing getframe ] 3 -weight 1
         grid columnconfigure [ $frm.indicateurs.positionSeeing getframe ] 4 -weight 0
         grid columnconfigure [ $frm.indicateurs.positionSeeing getframe ] 5 -weight 1

      pack $frm.indicateurs.positionSeeing -side top -anchor w -fill x -expand 1

  # pack $frm.indicateurs -side top -fill both

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

      #--- Frame pour l'indicateur de pointage
      TitleFrame $frm.centrage.pointage -borderwidth 2 -relief ridge \
         -text $::caption(sophie,consigne)

         #--- Frame pour les indicateurs
         frame $frm.centrage.pointage.indicateur -borderwidth 0 -relief ridge

            #--- Indicateur de pointage de l'objet
            radiobutton $frm.centrage.pointage.indicateur.objet \
               -indicatoron 0 -text $::caption(sophie,pointageObjet) -value OBJECT \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namspace ::sophie
            pack $frm.centrage.pointage.indicateur.objet -anchor center \
               -expand 1 -fill x -side left -ipadx 4 -ipady 4

            #--- Indicateur de pointage de l'entree de la fibre A
            radiobutton $frm.centrage.pointage.indicateur.fibreA \
               -indicatoron 0 -text $::caption(sophie,pointageEntreeFibreA) -value FIBER \
               -variable ::conf(sophie,guidingMode) \
               -command "::sophie::setGuidingMode $visuNo"   ; # Attention: la commande appelle la procedure du namspace ::sophie
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
               -width 8 -justify center
            $frm.centrage.pointage.positionXY.spinboxX set $private(centragexObjet)
            $frm.centrage.pointage.positionXY.spinboxX configure \
               -textvariable ::sophie::control::private(centragexObjet)
            grid $frm.centrage.pointage.positionXY.spinboxX -row 0 -column 2 -sticky ens

            #--- Position Y
            label $frm.centrage.pointage.positionXY.labelY -text $::caption(sophie,y)
            grid $frm.centrage.pointage.positionXY.labelY -row 0 -column 3 -sticky w -padx 5 -pady 3

            spinbox $frm.centrage.pointage.positionXY.spinboxY -from 1 -to 1024 -incr 0.1 \
               -width 8 -justify center
            $frm.centrage.pointage.positionXY.spinboxY set $private(centrageyObjet)
            $frm.centrage.pointage.positionXY.spinboxY configure \
               -textvariable ::sophie::control::private(centrageyObjet)
            grid $frm.centrage.pointage.positionXY.spinboxY -row 0 -column 4 -sticky ens

        # pack $frm.centrage.pointage.positionXY \
        #    -in [ $frm.centrage.pointage getframe ] \
        #    -side top -anchor w -fill x -expand 1

      pack $frm.centrage.pointage -side top -anchor w -fill x -expand 1

  # pack $frm.centrage -side top -fill both

   #--- Frame de la focalisation
   frame $frm.focalisation -borderwidth 1 -relief groove

      #--- Frame des courbes
      TitleFrame $frm.focalisation.courbes -borderwidth 2 -relief ridge \
         -text $::caption(sophie,courbes)

         #--- FWHM X
         label $frm.focalisation.courbes.labelFWHMX -text $::caption(sophie,FWHMX)
         grid $frm.focalisation.courbes.labelFWHMX \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 0 -column 1 -sticky w

         createGraph $frm.focalisation.courbes.graphFWHMX_simple 120
         grid $frm.focalisation.courbes.graphFWHMX_simple \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 0 -column 3 -sticky nsew

         #--- FWHM Y
         label $frm.focalisation.courbes.labelFWHMY -text $::caption(sophie,FWHMY)
         grid $frm.focalisation.courbes.labelFWHMY \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 1 -column 1 -sticky w

         createGraph $frm.focalisation.courbes.graphFWHMY_simple 120
         grid $frm.focalisation.courbes.graphFWHMY_simple \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 1 -column 3 -sticky nsew

         #--- Intensite maxi
         label $frm.focalisation.courbes.labelintensiteMax -text $::caption(sophie,intensiteMax)
         grid $frm.focalisation.courbes.labelintensiteMax \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 2 -column 1 -sticky w

         Entry $frm.focalisation.courbes.entryintensiteMax \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(focalisationCourbesIntensiteMax)
         grid $frm.focalisation.courbes.entryintensiteMax \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 2 -column 2 -sticky ew

         createGraph $frm.focalisation.courbes.graphintensiteMax_simple 120
         grid $frm.focalisation.courbes.graphintensiteMax_simple \
            -in [ $frm.focalisation.courbes getframe ] \
            -row 2 -column 3 -sticky nsew

      pack $frm.focalisation.courbes -side top -anchor w -fill x -expand 1

  # pack $frm.focalisation -side top -fill both

   #--- Frame du guidage
   frame $frm.guidage -borderwidth 1 -relief groove

      #--- Frame pour l'activation du guidage
      TitleFrame $frm.guidage.activationGuidage -borderwidth 2 -relief ridge \
         -text $::caption(sophie,activationGuidage)

         #--- Indicateur Etoile selectionnee ou non
         button $frm.guidage.activationGuidage.etoile -text $::caption(sophie,activationGuidage) \
            -relief raised -command " "
         pack $frm.guidage.activationGuidage.etoile \
            -in [ $frm.guidage.activationGuidage getframe ] \
            -side top -ipadx 4 -ipady 4

      pack $frm.guidage.activationGuidage -side top -anchor w -fill x -expand 1

      #--- Frame de la position de la consigne sur la fibre
      TitleFrame $frm.guidage.positionconsigne -borderwidth 2 -relief ridge \
         -text $::caption(sophie,positionConsigne)

         #--- Frame pour la position en X et Y de la consigne dans l'image
         frame $frm.guidage.positionconsigne.correction -borderwidth 0 -relief ridge

            #--- Label de la correction en X
            label $frm.guidage.positionconsigne.correction.labelX -text $::caption(sophie,correctionX)
            grid $frm.guidage.positionconsigne.correction.labelX \
               -row 0 -column 1 -sticky w -padx 5 -pady 3

            #--- Graphe de la correction en X
            createGraph $frm.guidage.positionconsigne.correction.dX_simple 120
            grid $frm.guidage.positionconsigne.correction.dX_simple -row 0 -column 2 -sticky nsew

            #--- Label de la correction en Y
            label $frm.guidage.positionconsigne.correction.labelY -text $::caption(sophie,correctionY)
            grid $frm.guidage.positionconsigne.correction.labelY \
               -row 1 -column 1 -sticky w -padx 5 -pady 3

            #--- Graphe de la correction en Y
            createGraph $frm.guidage.positionconsigne.correction.dY_simple 120
            grid $frm.guidage.positionconsigne.correction.dY_simple -row 1 -column 2 -sticky nsew

        # pack $frm.guidage.positionconsigne.correction \
        #    -in [ $frm.guidage.positionconsigne getframe ] \
        #    -side top -anchor w -fill x -expand 1

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
               -incr $::sophie::control::private(guidageIncrement) -width 8 -justify center
            $frm.guidage.positionconsigne.positionXY.spinboxX set $private(guidagexObjet)
            $frm.guidage.positionconsigne.positionXY.spinboxX configure \
               -textvariable ::sophie::control::private(guidagexObjet)
            grid $frm.guidage.positionconsigne.positionXY.spinboxX \
               -row 1 -column 2 -sticky ens

            #--- Position Y
            label $frm.guidage.positionconsigne.positionXY.labelY -text $::caption(sophie,y)
            grid $frm.guidage.positionconsigne.positionXY.labelY \
               -row 1 -column 3 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxY -from 1 -to 1024 \
               -incr $::sophie::control::private(guidageIncrement) -width 8 -justify center
            $frm.guidage.positionconsigne.positionXY.spinboxY set $private(guidageyObjet)
            $frm.guidage.positionconsigne.positionXY.spinboxY configure \
               -textvariable ::sophie::control::private(guidageyObjet)
            grid $frm.guidage.positionconsigne.positionXY.spinboxY \
               -row 1 -column 4 -sticky ens

            #--- Increment
            label $frm.guidage.positionconsigne.positionXY.labelIncrement \
               -text $::caption(sophie,increment)
            grid $frm.guidage.positionconsigne.positionXY.labelIncrement \
               -row 1 -column 5 -sticky w -padx 5 -pady 3

            spinbox $frm.guidage.positionconsigne.positionXY.spinboxIncrement \
               -from 0.1 -to 10.0 -incr 0.1 -values { 0.1 1 10 } -width 5 -justify center \
               -command "::sophie::adaptIncrement"
            $frm.guidage.positionconsigne.positionXY.spinboxIncrement set $private(guidageIncrement)
            $frm.guidage.positionconsigne.positionXY.spinboxIncrement configure \
               -textvariable ::sophie::control::private(guidageIncrement)
            grid $frm.guidage.positionconsigne.positionXY.spinboxIncrement \
               -row 1 -column 6 -sticky ens

        # pack $frm.guidage.positionconsigne.positionXY \
        #    -in [ $frm.guidage.positionconsigne getframe ] \
        #    -side top -anchor w -fill x -expand 1

      pack $frm.guidage.positionconsigne -side top -anchor w -fill x -expand 1

      #--- Frame de la position de l'objet par rapport a la consigne
      TitleFrame $frm.guidage.objetconsigne -borderwidth 2 -relief ridge \
         -text $::caption(sophie,objetconsigne)

         #--- Photocentre de l'objet
         label $frm.guidage.objetconsigne.labelPhotocentreObjet -text $::caption(sophie,photocentreObjet)
         grid $frm.guidage.objetconsigne.labelPhotocentreObjet \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 0 -column 1 -sticky w

         label $frm.guidage.objetconsigne.labelPositionX -text $::caption(sophie,x) -relief groove
         grid $frm.guidage.objetconsigne.labelPositionX \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 0 -column 2 -columnspan 1 -rowspan 1 -sticky ew

         Entry $frm.guidage.objetconsigne.entryPositionX \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(guidagePhotocentrePositionX)
         grid $frm.guidage.objetconsigne.entryPositionX \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 0 -column 3 -sticky ens

         label $frm.guidage.objetconsigne.labelPositionY -text $::caption(sophie,y) -relief groove
         grid $frm.guidage.objetconsigne.labelPositionY \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 0 -column 4 -columnspan 1 -rowspan 1 -sticky ew

         Entry $frm.guidage.objetconsigne.entryPositionY \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(guidagePhotocentrePositionY)
         grid $frm.guidage.objetconsigne.entryPositionY \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 0 -column 5 -sticky ens

         #--- Ecart par rapport a la consigne
         label $frm.guidage.objetconsigne.labelEcartconsigne -text $::caption(sophie,ecartconsigne)
         grid $frm.guidage.objetconsigne.labelEcartconsigne \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 1 -column 1 -sticky w

         label $frm.guidage.objetconsigne.labelDX -text $::caption(sophie,dx) -relief groove
         grid $frm.guidage.objetconsigne.labelDX \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 1 -column 2 -columnspan 1 -rowspan 1 -sticky ew

         Entry $frm.guidage.objetconsigne.entryDX \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(guidageDX)
         grid $frm.guidage.objetconsigne.entryDX \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 1 -column 3 -sticky ens

         label $frm.guidage.objetconsigne.labelDY -text $::caption(sophie,dy) -relief groove
         grid $frm.guidage.objetconsigne.labelDY \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 1 -column 4 -columnspan 1 -rowspan 1 -sticky ew

         Entry $frm.guidage.objetconsigne.entryDY \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(guidageDY)
         grid $frm.guidage.objetconsigne.entryDY \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 1 -column 5 -sticky ens

         #--- Erreur alpha et delta
         label $frm.guidage.objetconsigne.labelErreur -text $::caption(sophie,erreur)
         grid $frm.guidage.objetconsigne.labelErreur \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 2 -column 1 -sticky w

         label $frm.guidage.objetconsigne.labelErreurAlpha -text $::caption(sophie,erreurAlpha) \
            -relief groove
         grid $frm.guidage.objetconsigne.labelErreurAlpha \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 2 -column 2 -columnspan 1 -rowspan 1 -sticky ew

         Entry $frm.guidage.objetconsigne.entryErreurAlpha \
            -width 8 -justify left -editable 0 \
            -textvariable ::sophie::control::private(guidageErreurAlpha)
         grid $frm.guidage.objetconsigne.entryErreurAlpha \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 2 -column 3 -sticky ens

         label $frm.guidage.objetconsigne.labelErreurDelta -text $::caption(sophie,erreurDelta) \
            -relief groove
         grid $frm.guidage.objetconsigne.labelErreurDelta \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 2 -column 4 -columnspan 1 -rowspan 1 -sticky ew

         Entry $frm.guidage.objetconsigne.entryErreurDelta \
            -width 8 -justify center -editable 0 \
            -textvariable ::sophie::control::private(guidageErreurDelta)
         grid $frm.guidage.objetconsigne.entryErreurDelta \
            -in [ $frm.guidage.objetconsigne getframe ] \
            -row 2 -column 5 -sticky ens

      pack $frm.guidage.objetconsigne -side top -anchor w -fill x -expand 1

      #--- Frame pour visualiser les erreurs en alpha et delta
      TitleFrame $frm.guidage.erreurs -borderwidth 2 -relief ridge \
         -text $::caption(sophie,erreursAlphaDelta)

            #--- Label de la correction en alpha
            label $frm.guidage.erreurs.labelAlpha -text $::caption(sophie,erreurAlpha)
            grid $frm.guidage.erreurs.labelAlpha \
               -in [ $frm.guidage.erreurs getframe ] \
               -row 0 -column 1 -sticky w -padx 5 -pady 3

            #--- Graphe de la correction en alpha
            createGraph $frm.guidage.erreurs.alpha_simple 120
            grid $frm.guidage.erreurs.alpha_simple \
               -in [ $frm.guidage.erreurs getframe ] \
               -row 0 -column 2 -sticky nsew

            #--- Label de la correction en delta
            label $frm.guidage.erreurs.labelDelta -text $::caption(sophie,erreurDelta)
            grid $frm.guidage.erreurs.labelDelta \
               -in [ $frm.guidage.erreurs getframe ] \
               -row 1 -column 1 -sticky w -padx 5 -pady 3

            #--- Graphe de la correction en delta
            createGraph $frm.guidage.erreurs.delta_simple 120
            grid $frm.guidage.erreurs.delta_simple \
               -in [ $frm.guidage.erreurs getframe ] \
               -row 1 -column 2 -sticky nsew

      pack $frm.guidage.erreurs -side top -anchor w -fill x -expand 1

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
# createGraph
#    affichage de graphiques
#
#------------------------------------------------------------
proc ::sophie::control::createGraph { frm height } {

   package require BLT

   if { [winfo exists $frm ] } {
      return
   }

   #--- je cree le graphique
   blt::graph $frm -plotbackground "$::color(white)"
   $frm crosshairs on
   $frm crosshairs configure -color "$::color(red)" -dashes 2
   $frm axis configure x2 -hide true
   $frm axis configure y2 -hide true
   $frm legend configure -hide yes
   $frm configure -height $height
   $frm configure -plotbackground "$::color(white)"

   bind $frm <Motion> "::sophie::control::onGraphMotion %W %x %y"
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
         if { $mode == "centrage" } {
            pack $frm.indicateurs -side top -fill both
            pack $frm.centrage -side top -fill both
            pack forget $frm.focalisation
            pack forget $frm.guidage
         } elseif { $mode == "focalisation" } {
            pack $frm.indicateurs -side top -fill both
            pack forget $frm.centrage
            pack $frm.focalisation -side top -fill both
            pack forget $frm.guidage
         } elseif { $mode == "guidage" } {
            pack $frm.indicateurs -side top -fill both
            pack forget $frm.centrage
            pack forget $frm.focalisation
            pack $frm.guidage -side top -fill both
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
      $frm.indicateurs.controleInterface.acquisition_color_invariant configure \
         -text $::caption(sophie,acquisitionArretee) \
         -bg   $private(inactiveColor)

      #--- je desactive le bouton de centrage
      $frm.centrage.centrageConsigne.start configure -state disabled
   } else {
      #--- j'affiche l'indicateur d'acquisition en vert
      $frm.indicateurs.controleInterface.acquisition_color_invariant configure \
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
# @param max     flux max
#
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setCenterInformation { starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxFlow } {
   variable private

   set frm $private(frm)

   #--- je mets a jour le voyant "etoileDetecte"
   if { $starDetection == 0 } {
      $frm.indicateurs.controleInterface.etoile_color_invariant configure \
         -text $::caption(sophie,etoileNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.indicateurs.controleInterface.etoile_color_invariant configure \
         -text $::caption(sophie,etoileDetecte) \
         -bg   $private(activeColor)
   }

   #--- je mets a jour le voyant "trouDetecte"
   if { $fiberDetection == 0 } {
      $frm.indicateurs.controleInterface.trou_color_invariant configure \
         -text $::caption(sophie,trouNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.indicateurs.controleInterface.trou_color_invariant configure \
         -text $::caption(sophie,trouDetecte) \
         -bg   $private(activeColor)
   }

   set private(indicateursPositionX)  [format "%6.1f" $starX]
   set private(indicateursPositionY)  [format "%6.1f" $starY]
   set private(indicateursFWHMX)      [format "%6.1f" $fwhmX]
   set private(indicateursFWHMY)      [format "%6.1f" $fwhmY]
   set private(indicateursFondDeCiel) [format "%6.1f" $background]
   set private(indicateursFluxMax)    [format "%6.1f" $maxFlow]
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
# @param maxFlow      flux max
# @param maxIntensity intensité max
#
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setFocusInformation { starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxFlow maxIntensity } {
   variable private

   set frm $private(frm)

   #--- je mets a jour le voyant "etoileDetecte"
   if { $starDetection == 0 } {
      $frm.indicateurs.controleInterface.etoile_color_invariant configure \
         -text $::caption(sophie,etoileNonDetecte)
      $frm.indicateurs.controleInterface.etoile_color_invariant deselect
   } else {
      $frm.indicateurs.controleInterface.etoile_color_invariant configure \
         -text $::caption(sophie,etoileDetecte)
      $frm.indicateurs.controleInterface.etoile_color_invariant select
   }

   #--- je mets a jour le voyant "trouDetecte"
   if { $fiberDetection == 0 } {
      $frm.indicateurs.controleInterface.trou_color_invariant configure \
         -text $::caption(sophie,trouNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.indicateurs.controleInterface.trou_color_invariant configure \
         -text $::caption(sophie,trouDetecte) \
         -bg   $private(activeColor)
   }

   set private(indicateursPositionX)            [format "%6.1f" $starX]
   set private(indicateursPositionY)            [format "%6.1f" $starY]
   set private(indicateursFWHMX)                [format "%6.1f" $fwhmX]
   set private(indicateursFWHMY)                [format "%6.1f" $fwhmY]
   set private(indicateursFondDeCiel)           [format "%6.1f" $background]
   set private(indicateursFluxMax)              [format "%6.1f" $maxFlow]
   set private(focalisationCourbesIntensiteMax) [format "%6.1f" $maxIntensity]

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
# @return rien
#------------------------------------------------------------
proc ::sophie::control::setGuideInformation { starDetection fiberDetection originX originY starX starY starDx starDy alphaCorrection deltaCorrection } {
   variable private

   set frm $private(frm)

   #--- je mets a jour le voyant "etoileDetecte"
   if { $starDetection == 0 } {
      $frm.indicateurs.controleInterface.etoile_color_invariant configure \
         -text $::caption(sophie,etoileNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.indicateurs.controleInterface.etoile_color_invariant configure \
         -text $::caption(sophie,etoileDetecte) \
         -bg   $private(activeColor)
   }

   #--- je mets a jour le voyant "trouDetecte"
   if { $fiberDetection == 0 } {
      $frm.indicateurs.controleInterface.trou_color_invariant configure \
         -text $::caption(sophie,trouNonDetecte) \
         -bg   $private(inactiveColor)
   } else {
      $frm.indicateurs.controleInterface.trou_color_invariant configure \
         -text $::caption(sophie,trouDetecte) \
         -bg   $private(activeColor)
   }

   set private(indicateursPositionX) [format "%6.1f" $starX]
   set private(indicateursPositionY) [format "%6.1f" $starY]
   set private(guidageDX)            [format "%6.1f" $starDx]
   set private(guidageDY)            [format "%6.1f" $starDy]
   set private(guidageErreurAlpha)   [format "%6.1f" $alphaCorrection]
   set private(guidageErreurDelta)   [format "%6.1f" $deltaCorrection]

}

