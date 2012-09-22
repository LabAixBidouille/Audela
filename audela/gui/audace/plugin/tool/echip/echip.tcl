#
# Fichier : echip.tcl
# Description : GUI de la proc electronic_chip (surchaud.tcl)
# Auteur : Raymond Zachantke
# Mise � jour $Id$
#

#============================================================
# Declaration du namespace echip
#    initialise le namespace
#============================================================
namespace eval ::echip {

   package provide echip 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] echip.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(echip,title)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "echip.htm"
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
      return "echip"
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
         subfunction1 { return "echip" }
         display      { return "window" }
         multivisu    { return 0 }
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

   }

   #------------------------------------------------------------
   # startTool : affiche la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable private

      if { ![ winfo exists private(This) ] } {
          createWindow $visuNo
      }
    }

   #------------------------------------------------------------
   # stopTool : masque la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc stopTool { visuNo } {

   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      variable private

      if { [ winfo exists $private(This) ] } {
         #--- Je ferme la fenetre si l'utilsateur ne l'a pas deja fait
          cmdClose $visuNo $private(This)
      }
   }

   #-----------------------------------------------------------------
   #  createWindow
   #  Cree la fenetre
   #-----------------------------------------------------------------
   proc createWindow { visuNo } {
      variable private
      global audace conf caption

      set this $audace(base).echip
      set private(This) $this

      if {[winfo exists $this]} {
         cmdClose $visuNo $this
      }

      toplevel $this -class Toplevel
      wm title $this "$caption(echip,title)"
      wm geometry $this "+300+300"
      wm resizable $this 0 0
      wm protocol $this WM_DELETE_WINDOW "::echip::cmdClose $visuNo $this"

      #--    cree trois frame (offset, dark, flat)
      pack [frame $this.fr] -side top
      set row 0
      foreach child [list offset dark flat] {
         label $this.fr.lab_$child -text "$caption(echip,$child)" -justify left
         grid $this.fr.lab_$child -row $row -column 0 -sticky w -padx 3 -pady 3
         ttk::entry $this.fr.$child -textvariable ::echip::private(${child}name) -justify left -width 15
         grid $this.fr.$child -row $row -column 1 -sticky w -padx 3 -pady 3
         ttk::button $this.fr.search$child -text "$caption(echip,search)" -width 4 \
            -command "::::echip::getFileName $this.fr.search$child $child"
         grid $this.fr.search$child -row $row -column 2 -padx 3 -pady 3
         label $this.fr.lab_nb$child -text "$caption(echip,nombre)" -justify left
         grid $this.fr.lab_nb$child -row $row -column 3 -sticky w -padx 3 -pady 3
         label $this.fr.nb$child -textvariable ::echip::private(${child}nb) -justify center -width 4
         grid $this.fr.nb$child -row $row -column 4 -sticky w -padx 3 -pady 3
         incr row
      }

      label $this.fr.lab_saturation -text "$caption(echip,saturation)" -justify left
      grid $this.fr.lab_saturation -row $row -column 0 -sticky w -padx 3 -pady 3
      ttk::entry $this.fr.saturation -textvariable ::echip::private(saturation) -justify center -width 8
      grid $this.fr.saturation -row $row -column 1 -sticky w -padx 3 -pady 3
      incr row
      checkbutton $this.fr.obt -text "$caption(echip,obt)" -variable ::echip::private(obt) \
         -offvalue 0 -onvalue 1
      grid $this.fr.obt -row $row -column 0 -padx 3 -pady 3 -sticky w
      incr row

      grid [ttk::separator $this.fr.sep1 -orient horizontal] \
         -row $row -column 0 -columnspan 5 -padx 3 -pady 5 -sticky ew
      incr row

      #--    cree les frame de resultats
      foreach child [list gain noise bias thermic_signal] {
         label $this.fr.lab_mean_$child -text "$caption(echip,$child)" -justify left
         grid $this.fr.lab_mean_$child -row $row -column 0 -sticky w -padx 3 -pady 3
         label $this.fr.mean_$child -textvariable ::echip::private(mean_$child) -justify center -width 8
         grid $this.fr.mean_$child -row $row -column 1 -sticky w -padx 3 -pady 3
         label $this.fr.lab_std_$child -text "$caption(echip,sigma)" -justify left
         grid $this.fr.lab_std_$child -row $row -column 2 -sticky w -padx 3 -pady 3
         label $this.fr.std_$child -textvariable ::echip::private(std_$child) -justify center -width 8
         grid $this.fr.std_$child -row $row -column 3 -sticky w -padx 3 -pady 3
         incr row
      }
      foreach child [list exp_critique exp_max dynamic] {
         label $this.fr.lab_$child -text "$caption(echip,$child)" -justify left
         grid $this.fr.lab_$child -row $row -column 0 -sticky w -padx 3 -pady 3
         label $this.fr.$child -textvariable ::echip::private($child) -justify center -width 8
         grid $this.fr.$child -row $row -column 1 -padx 3 -pady 3 -sticky w
         incr row
      }

      grid [ttk::separator $this.fr.sep2 -orient horizontal] \
         -row $row -column 0 -columnspan 5 -padx 3 -pady 5 -sticky ew

      #--   frame des boutons de commande
      pack [frame $this.cmd] -side bottom -fill x

      set listOfCmd [list \
         "::echip::cmdOk $visuNo $this" \
         "::echip::cmdApply $visuNo $this" \
         "::echip::cmdClose $visuNo $this" \
         "::audace::showTutorials 1050tutoriel_electronic1.htm" \
         "::audace::showHelpPlugin tool echip echip.htm" \
      ]

      foreach {but side} [list ok left apply left close right hlpFunction right  hlpTool right] cmd $listOfCmd {
         ttk::button $this.cmd.$but -text "$caption(echip,$but)" -command $cmd \
            -width 10 -state !disabled
         pack $this.cmd.$but -side $side -padx 5 -pady 5 -ipady 5
         if {$but eq "ok" && $conf(ok+appliquer) eq 0} {
             pack forget $this.cmd.ok
         }
      }

      #--   initialise les variables
      lassign [list offset dark flat 0 ""] private(offsetname) private(darkname) \
         private(flatname) private(obt) private(saturation)

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #--------------------------------------------------------------------------
   #  getFileName w nom_de_variable
   #  Ouvre un explorateur pour choisir une image operande
   #  Commande des boutons '...'
   #--------------------------------------------------------------------------
   proc getFileName { this var } {
      variable private
      global audace conf

      #--   ouvre la fenetre de choix des images
      set file [::tkutil::box_load $this $::audace(rep_images) $::audace(bufNo) "1"]

      #--   arrete si pas de selection
      if {$file eq ""} {return}

      #--   verifie le repertoire et l'extension
      set dir [file dirname $file]
      set ext [file extension $file]
      if {$dir ne "$audace(rep_images)" || $ext ne "$conf(extension,defaut)"} {
         return
      }

      #--   actualise les donnees
      lassign [::tkutil::afficherNomGenerique $file] private(${var}name) private(${var}nb) -> private(${var}indexes)

      #--   filtre les resultats
      if {$private(${var}nb) < 2} {
         lassign [list 0 ""] private(${var}nb) private(${var}name)
      }
   }

   #-----------------------------------------------------------------
   #  cmdApply
   #  Commande du bouton Appliquer
   #-----------------------------------------------------------------
   proc cmdApply { visuNo this } {
      variable private
      global audace

      configButtons $this disabled

      #--   determine le gain et le bruit
      set cmd [list electronic_chip gainnoise]
      foreach k $private(offsetindexes) {
         lappend cmd $private(offsetname)$k
      }
      foreach k $private(flatindexes) {
         lappend cmd $private(flatname)$k
      }
      lassign [eval $cmd] mean_gain mean_noise std_gain std_noise

      #--   formate les resultats
      foreach var [list mean_gain std_gain mean_noise std_noise] {
         set private($var) [format %.2f [set $var]]
      }
      update

      #--   determine le bias et le bruit thermique
      set cmd [list electronic_chip lintherm]
      lappend cmd $private(darkname) $private(darknb) $mean_gain $mean_noise
      if {$private(saturation) ne ""} {
         lappend cmd $private(saturation)
      }
      lassign [eval $cmd] mean_thermic_signal mean_bias \
         std_thermic_signal std_bias exp_critique exp_max

      #--   formate les resultats
      foreach var [list mean_thermic_signal std_thermic_signal mean_bias std_bias ] {
         set private($var) [format %.2f [set $var]]
      }
      set private(exp_critique) [format %.1f $exp_critique]
      set private(exp_max) [format %.1f $exp_max]
      if {$private(saturation) ne ""} {
         set private(dynamic) [expr { int(($private(saturation)-$mean_bias)*$mean_gain/$mean_noise) }]
      }
      update

      #--   cree une image de l'oburateur mecanique
      if {$private(obt) == 1} {
         electronic_chip shutter $private(flatname) $private(flatnb)
      }

      configButtons $this !disabled
   }

   #---------------------------------------------------------------------------
   #  configButtons
   #  Inhibe/Desinhibe tous les boutons
   #---------------------------------------------------------------------------
   proc configButtons { this state } {

      foreach but  [list ok apply close hlpFunction hlpTool] {
         $this.cmd.$but state $state
      }
      update
   }

   #-----------------------------------------------------------------
   #  cmdOk
   #  Commande du bouton OK
   #-----------------------------------------------------------------
   proc cmdOk { visuNo this } {

      cmdApply $visuNo $this
      cmdClose $visuNo $this
   }

   #-----------------------------------------------------------------
   #  cmdClose
   #  Commande du bouton Fermer
   #-----------------------------------------------------------------
   proc cmdClose { visuNo this } {

      destroy $this
   }

}

