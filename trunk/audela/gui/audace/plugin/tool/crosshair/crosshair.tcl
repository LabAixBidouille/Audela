#
# Fichier : crosshair.tcl
# Description : Affiche un reticule sur l'image
# Auteur : Michel PUJOL
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace Crosshair
#    initialise le namespace
#============================================================
namespace eval ::Crosshair {
   package provide Crosshair 1.0

   array set widget { }

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] crosshair.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(crosshair,titre)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "crosshair.htm"
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
      return "crosshair"
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
         function     { return "display" }
         subfunction1 { return "crosshair" }
         display      { return "window" }
         multivisu    { return 1 }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin au demarrage d'AudeLA
   #    Il ne faut utiliser cette procedure que si on a besoin d'initialiser des
   #    des variables ou de creer des procedure des le demarrage d'AudeLA.
   #    Sinon il vaut mieux utiliser createPluginInstance qui est appelee lors de
   #    la premiere utilisation de l'outil.
   #    Cela evite ainsi d'alourdir le demarrage d'AudeLA et d'occuper de la
   #    memoire pour rien si l'outil n'est pas utilise.
   #------------------------------------------------------------
   proc initPlugin { tkbase } {
   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      variable private

      #--- j'initialise les parametres dans le tableau conf()
      set private(imageSize) " "

      return [namespace current]
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      if { [ winfo exists [ confVisu::getBase $visuNo ].confCrossHair ] } {
         #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
         ::Crosshair::closeWindow $visuNo
      }
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      #--- J'ouvre la fenetre
      ::confGenerique::run $visuNo [confVisu::getBase $visuNo].confCrossHair ::Crosshair -modal 0
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      #--- Rien a faire, car la fenetre est fermee par l'utilisateur
   }

   #------------------------------------------------------------
   # getLabel
   #    retourne le nom et le label du reticule
   #
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"]
   #------------------------------------------------------------
   proc getLabel { } {
      return [ ::Crosshair::getPluginTitle ]
   }

   #------------------------------------------------------------
   # apply { }
   #    copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc apply { visuNo } {
      variable widget
      global conf

      set conf(visu,crosshair,color)        $widget(color)
      set conf(visu,crosshair,defaultstate) $widget(defaultstate)

      ::confVisu::setCrosshair $visuNo $widget($visuNo,currentstate)
   }

   #------------------------------------------------------------
   # closeWindow
   #    Procedure correspondant a l'appui sur le bouton Fermer
   #------------------------------------------------------------
   proc closeWindow { visuNo } {
      variable wbase

      #--- Detruit la fenetre
      destroy [confVisu::getBase $visuNo].confCrossHair
   }

   #------------------------------------------------------------
   # fillConfigPage { }
   #    fenetre de configuration du reticule
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc fillConfigPage { frm visuNo } {
      variable widget
      global caption conf

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      #--- j'initialise les valeurs
      set widget(color)                $conf(visu,crosshair,color)
      set widget(defaultstate)         $conf(visu,crosshair,defaultstate)
      set widget($visuNo,currentstate) [::confVisu::getCrosshair $visuNo]

      #--- creation des differents frames
      frame $frm.frameState -borderwidth 1 -relief raised
      pack $frm.frameState -side top -fill both -expand 1

      frame $frm.frameColor -borderwidth 1 -relief raised
      pack $frm.frameColor -side top -fill both -expand 1

      #--- current state
      checkbutton $frm.frameState.currentstate -text "$caption(crosshair,current_state_label)" \
         -highlightthickness 0 -variable ::Crosshair::widget($visuNo,currentstate)
      pack $frm.frameState.currentstate -in $frm.frameState -anchor center -side left -padx 10 -pady 5

      #--- default state
      checkbutton $frm.frameState.defaultstate -text "$caption(crosshair,default_state_label)" \
         -highlightthickness 0 -variable Crosshair::widget(defaultstate)
      pack $frm.frameState.defaultstate -in $frm.frameState -anchor center -side left -padx 10 -pady 5

      #--- color
      label $frm.frameColor.labColor -text "$caption(crosshair,color_label)" -relief flat
      pack $frm.frameColor.labColor -in $frm.frameColor -anchor center -side left -padx 10 -pady 10

      button $frm.frameColor.butColor_color_invariant -relief raised -width 6 -bg $widget(color) \
         -activebackground $widget(color) -command "::Crosshair::changeColor $frm"
      pack $frm.frameColor.butColor_color_invariant -in $frm.frameColor -anchor center -side left -padx 10 -pady 5 -ipady 5
   }

   #==============================================================
   # Fonctions specifiques
   #==============================================================

   #------------------------------------------------------------
   # showHelp
   #    aide
   #
   #------------------------------------------------------------
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::Crosshair::getPluginType ] ] \
         [ ::Crosshair::getPluginDirectory ] [ ::Crosshair::getPluginHelp ]
   }

   #------------------------------------------------------------
   # changeColor
   #    change la couleur du reticule
   #
   #------------------------------------------------------------
   proc changeColor { frm } {
      variable widget
      global caption

      set temp [tk_chooseColor -initialcolor $::Crosshair::widget(color) -parent ${Crosshair::widget(frm)} \
         -title ${caption(crosshair,color_crosshair)} ]
      if  { "$temp" != "" } {
         set Crosshair::widget(color) "$temp"
         ${Crosshair::widget(frm)}.frameColor.butColor_color_invariant configure \
            -bg $::Crosshair::widget(color) -activebackground $::Crosshair::widget(color)
      }
   }

}

