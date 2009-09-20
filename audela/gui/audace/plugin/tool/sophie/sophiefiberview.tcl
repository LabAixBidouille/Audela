##------------------------------------------------------------
# @file     fiberview.tcl
# @brief    Fichier du namespace ::sophie::fiberview
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiefiberview.tcl,v 1.1 2009-09-20 13:29:14 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @brief   visualisation de la fibre
#
#------------------------------------------------------------
namespace eval ::sophie::fiberview {
   variable private
   set private(visuNo) 0

}

##------------------------------------------------------------
# run
#    cree une visu pour voir la fibre
# @param sophieVisuNo  numero de la visu de la fenetre principale de l'outil sophie
# @return numero de la visu de visualisation de la fibre A
#------------------------------------------------------------
proc ::sophie::fiberview::run { sophieVisuNo  } {
   variable private

   if { $private(visuNo) == 0 } {
      if { ! [ info exists ::conf(sophie,fiberVisu,position) ] } {
         set ::conf(sophie,fiberVisu,position)     "+400+300"
      }

      #--- je memorise le numero de la visu de la fenetre principale de sophie
      set private(sophieVisuNo) $sophieVisuNo

      #--- j'ouvre une visu pour afficher la fibre A
      set visuNo [::confVisu::create]

      #--- j'affiche l'outil
      confVisu::selectTool $visuNo ""
      createPluginInstance [::confVisu::getBase $visuNo].tool $visuNo
      lappend ::confVisu::private($visuNo,pluginInstanceList) "sophie::fiberview"
      set ::confVisu::private($visuNo,currentTool) "sophie::fiberview"
      startTool $visuNo
   }
}

##------------------------------------------------------------
# ::sophie::fiberview::closeWindow
#    ferme la visu
#------------------------------------------------------------
proc ::sophie::fiberview::closeWindow { } {
   variable private
   if { $private(visuNo) != 0 } {
      ::confVisu::close $private(visuNo)
   }
}

##------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::sophie::fiberview::createPluginInstance { in visuNo  } {
   variable private

   set tkBase [::confVisu::getBase $visuNo]
   console::disp "createPluginInstance in=$in tkBase=$tkBase"
   #--- je vide le menu des outils
   Menu_Delete $visuNo $::caption(audace,menu,tool) all
   #--- j'affiche la fentre au dessus de la fenetre principale de sophie
   wm transient $tkBase [::confVisu::getBase $private(sophieVisuNo)]
   #--- je change le titre
   wm title $tkBase $::caption(sophie,visuFibreA)
   #--- je change la position
   wm geometry $tkBase $::conf(sophie,fiberVisu,position)
   #--- je passe en zoom x4
   ::confVisu::setZoom $visuNo 4
   #--- je memorise le buffer initial
   set private(initialBufferNo) [::confVisu::getBufNo $visuNo]
   #--- je change le buffer
   visu$visuNo buf [::confVisu::getBufNo $private(sophieVisuNo)]
   #--- je masque le nom de la camera et du telescope
   grid forget $tkBase.fra1.labCam_labURL
   grid forget $tkBase.fra1.labCam_name_labURL
   grid forget $tkBase.fra1.labTel_labURL
   grid forget $tkBase.fra1.labTel_name_labURL

   #--- je memorise le numero de la visu
   set private(visuNo) $visuNo

}

##------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::sophie::fiberview::deletePluginInstance { visuNo } {
   variable private
   set private(visuNo) 0

}

##------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::fiberview::startTool { visuNo } {
   variable private

   #--- je demarre le listener
   ::sophie::addAcquisitionListener $private(sophieVisuNo) "::sophie::fiberview::refresh $visuNo"
}

##------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::fiberview::stopTool { visuNo } {
   variable private

   #--- j'arrete le listener
   ::sophie::removeAcquisitionListener $private(sophieVisuNo) "::sophie::fiberview::refresh $visuNo"
   #--- je restaure le numero du buffer initial
   visu$visuNo buf $private(initialBufferNo)
   #--- j'enregistre la position
   set ::conf(sophie,fiberVisu,position) [winfo geometry [::confVisu::getBase $visuNo]]
}

##------------------------------------------------------------
# refresh
#    met a jour le fenertage si necessaire
#    affiche le contenu du buffer
#------------------------------------------------------------
proc ::sophie::fiberview::refresh { visuNo args } {
   variable private

   #--- j'applique un fenetrage centre sur la fibreAHR
   set dispWindowCoord [visu$visuNo window]
   set x  $::conf(sophie,fiberHRX)
   set y  $::conf(sophie,fiberHRY)
   set size $::sophie::private(targetBoxSize)

   set x1 [expr int(($x - $size) / $::sophie::private(xBinning))]
   set x2 [expr int(($x + $size) / $::sophie::private(xBinning))]
   set y1 [expr int(($y - $size) / $::sophie::private(yBinning))]
   set y2 [expr int(($y + $size) / $::sophie::private(yBinning))]
   if { $dispWindowCoord != [list $x1 $y1 $x2 $y2] } {
      #--- j'annule le fenetrage precedent
      if { $dispWindowCoord != "full" } {
         visu$visuNo window "full"
      }
      #--- j'applique le nouveau fenetrage
      catch {
         visu$visuNo window [list $x1 $y1 $x2 $y2]
         set ::confVisu::private($visuNo,window) 1
      }
   }
   #--- j'affiche l'image
   ::confVisu::autovisu $visuNo
   #--- je change le titre
   wm title [::confVisu::getBase $visuNo] $::caption(sophie,visuFibreA)
}







