#
# Fichier : acquisition.tcl
# Description : acquisitionde guidage de  l'outil Sophie
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: acquisition.tcl,v 1.1 2009-05-08 10:44:49 michelpujol Exp $
#

#============================================================
# Declaration du namespace sophie
#    initialise le namespace
#============================================================
namespace eval ::sophie::acquisition {
}

##------------------------------------------------------------
# setMode
#    change le mode d'acquisition
#
# @param mode  mode de fonctionnement (centrage, focalisation, guidage)
# @return rien
#------------------------------------------------------------
proc ::sophie::acquisition::setMode { mode } {
   variable private

}



#------------------------------------------------------------
#  startGuiding
#     lance l'autoguidage
#  parametres
#     visuNo : numero de visu
#  return :
#     none
#------------------------------------------------------------
proc ::sophie::acquisition::startAcquisition { visuNo } {
   variable private
   global conf

   #--- je verifie que l'acquisition n'est pas déjà démarré
   if { $private(acquisitionState) == 1 } {
      return ""
   }

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]

   #--- je verifie la presence la camera
   if { [::confCam::isReady $camItem] == 0 } {
      error "
   }

   #--- J'affiche le bouton "STOP" et l'associe a la commande d'arret
   $private($visuNo,This).go_stop.but configure \
      -text "$::caption(autoguider,STOP)" \
      -command "::autoguider::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::autoguider::stopAcquisition $visuNo"

   #--- j'initialise les valeurs affichees
   set private($visuNo,acquisitionState)  1
   set private($visuNo,acquisitionResult) ""

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private($visuNo,mountEnabled) == 1 } {
      ::telescope::setSpeed 1
   }

   #--- je fais l'acquisition
   ###set binning [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]
   ::camera::guide $camItem "::autoguider::callbackAcquisition $visuNo" \
      $::conf(autoguider,pose)         \
      $::conf(autoguider,detection)    \
      $::conf(autoguider,originCoord)   \
      $private($visuNo,targetCoord)    \
      $::conf(autoguider,angle)        \
      $::conf(autoguider,targetBoxSize) \
      $private($visuNo,mountEnabled)   \
      $::conf(autoguider,alphaSpeed)   \
      $::conf(autoguider,deltaSpeed)   \
      $::conf(autoguider,alphaReverse) \
      $::conf(autoguider,deltaReverse) \
      $::conf(autoguider,seuilx)       \
      $::conf(autoguider,seuily)       \
      $::conf(autoguider,slitWidth)    \
      $::conf(autoguider,slitRatio)    \
      $::conf(autoguider,intervalle)   \
      $::conf(autoguider,declinaisonEnabled)

   return 0
}

proc ::sophie::acquisition::callbackAcquisition { visuNo command args } {
   variable private

   ###console::disp "callbackAcquisition visu=$visuNo command=$command args=$args\n"
   switch $command  {
      "autovisu" {
         if { $::conf(autoguider,showImage) == "1" } {
            ::confVisu::autovisu $visuNo
            ###visu1 disp
         }
         #--- j'affiche les axes si ce n'est pas deja fait
         if {  [$private($visuNo,hCanvas) gettags axis ] == "" } {
            createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)
         }
         set private($visuNo,interval) [format "%###0d ms" [lindex $args 0]]
      }
      "error" {
         ###console::disp "callbackGuide visu=$visuNo command=$command $args\n"
         ::autoguider::stopAcquisition $visuNo
      }
      "targetCoord" {
         set private($visuNo,targetCoord) [lindex $args 0]
         ::autoguider::moveTarget $visuNo [lindex $args 0]
         set private($visuNo,dx) [format "%##0.1f" [lindex $args 1]]
         set private($visuNo,dy) [format "%##0.1f" [lindex $args 2]]
      }
      "mountInfo" {
         set private($visuNo,delay,alpha) "[lindex $args 1] [lindex $args 0]"
         set private($visuNo,delay,delta) "[lindex $args 3] [lindex $args 2]"
      }
      "acquisitionResult" {
         #--- je recupere la liste des etoiles
         set private($visuNo,acquisitionResult) [lindex $args 0]
         ::autoguider::stopAcquisition $visuNo
      }
   }

}

#------------------------------------------------------------
# stopAcquisition
#    Demande l'arret des acquisitions . L'arret sera effectif apres la fin
#    de l'acquisition en cours
#------------------------------------------------------------
proc ::sophie::acquisition::stopAcquisition { visuNo } {
   variable private
   global caption

   if { $private($visuNo,acquisitionState) == 1 } {
      #--- je demande l'arret des acquisitions
      set camItem [ ::confVisu::getCamItem $visuNo ]
      if { $camItem != "" } {
         ::camera::stopAcquisition $camItem
      }
      $private($visuNo,This).go_stop.but configure \
         -text "$::caption(autoguider,GO)" \
         -command "::autoguider::startGuiding $visuNo"
      $private($visuNo,This).suivi.center configure \
         -text "$caption(autoguider,centrer)" \
         -command "::autoguider::startCenter $visuNo"
      $private($visuNo,This).suivi.search configure \
         -text "$caption(autoguider,rechercher)" \
         -command "::autoguider::startSearch $visuNo"

      #--- je supprime l'association du bouton escape
      bind all <Key-Escape> ""
      #--- j'efface le fichier de cumul
      ###file delete -force [file join $::audace(rep_images) $private($visuNo,cumulFileName)]]
      #--- j'initialise la variable
      set private($visuNo,acquisitionState) 0

   }
}
