#
# Fichier : sophieview.tcl
# Description : vue detail du suivi
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophieview.tcl,v 1.2 2009-05-30 07:14:18 michelpujol Exp $
#

#============================================================
# Declaration du namespace sophie::config
#    initialise le namespace
#============================================================
namespace eval ::sophie::view {
}

#------------------------------------------------------------
# run
#    affiche la fenetre du configuration
#------------------------------------------------------------
proc ::sophie::view::run { sophieVisu } {
   variable private

   set private(sophieVisu) $sophieVisu
   #--- j'ouvre une fenetre pour afficher des profils
   set visuNo [::confVisu::create]
   confVisu::selectTool $visuNo ""
   Menu_Delete $visuNo $::caption(audace,menu,tool) all
   createPluginInstance [::confVisu::getBase $visuNo].tool $visuNo
   lappend ::confVisu::private($visuNo,pluginInstanceList) "sophie::view"
   set ::confVisu::private($visuNo,currentTool) "sophie::view"
   startTool $visuNo
   grid [::confVisu::getBase $visuNo].tool -row 0 -column 0 -rowspan 2 -sticky ns
}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::sophie::view::createPluginInstance { { in "" } { visuNo 1 } } {
   variable private

   set private(frm)              "$in.sophieview"
   #--- je memorise le buffer initial
   set private(initialBuffer) [::confVisu::getBufNo $visuNo]
console::disp "::sophie::view::createPluginInstance $private(initialBuffer)\n"

   set private(bufferName)    "maskBufNo"

   #--- Petit raccourci
   set frm $private(frm)

   #--- Interface graphique de l'outil
   frame $frm -borderwidth 2 -relief groove

      #--- Frame du titre et de la configuration
      frame $frm.select -borderwidth 2 -relief groove

         #--- Bouton du titre
         ##button $frm.titre.but2 -borderwidth 2 -text "test"
         #--- Bouton de selection de l'image a afficher
         radiobutton $frm.select.mask -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "Masque" \
            -value "maskBufNo" \
            -variable ::sophie::view::private(bufferName) \
            -command "::sophie::view::setBuffer $visuNo "
         pack $frm.select.mask -anchor center -expand 0 -fill x -ipady 2 -padx 2 -pady 2

         radiobutton $frm.select.sum -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "Image intégrée" \
            -value "sumBufNo" \
            -variable ::sophie::view::private(bufferName) \
            -command "::sophie::view::setBuffer $visuNo "
         pack $frm.select.sum -anchor center -expand 0 -fill x -ipady 2 -padx 2 -pady 2

         radiobutton $frm.select.fiber -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "Entrée fibre" \
            -value "fiberBufNo" \
            -variable ::sophie::view::private(bufferName) \
            -command "::sophie::view::setBuffer $visuNo "
         pack $frm.select.fiber -anchor center -expand 0 -fill x -ipady 2 -padx 2 -pady 2

      pack $frm.select -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::sophie::view::deletePluginInstance { visuNo } {

   #--- je restaure le numero du buffer initial
   ##::sophie::setBuffer $visuNo ""

}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::view::startTool { visuNo } {
   variable private

   #--- j'affiche le panneau
   pack $private(frm) -side left -fill y
   #--- je passe en zoomx4
   ::confVisu::setZoom  $visuNo 4
   #--- j'affiche l'image du buffer
   setBuffer $visuNo
   #--- je demarre le listener
   ::sophie::addAcquisitionListener $private(sophieVisu) "::sophie::view::refresh $visuNo"
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::view::stopTool { visuNo } {
   variable private

   #--- j'arrete le listener
   ::sophie::removeAcquisitionListener $private(sophieVisu) "::sophie::view::refresh $visuNo"
   after 1000
   #--- je restaure le numero du buffer initial
   ::sophie::view::setBuffer $visuNo "initialBuffer"
   #--- je masque le panneau
   pack forget $private(frm)

}

#------------------------------------------------------------
# setBuffer
#    change le buffer etaffiche le contenu
#------------------------------------------------------------
proc ::sophie::view::setBuffer { visuNo { bufferName "" } } {
   variable private

   if { $bufferName == "" } {
      set bufferName $private(bufferName)
   } else {
      set private(bufferName) $bufferName
   }

   switch $bufferName {
      "maskBufNo" -
      "sumBufNo"  -
      "fiberBufNo" {
         visu$visuNo buf [::sophie::getBufNo $bufferName]
      }
      "initialBuffer" {
         visu$visuNo buf $private(initialBuffer)
      }
   }
console::disp "::sophie::view::setBuffer [visu$visuNo buf]\n"
   ::confVisu::autovisu $visuNo
}

#------------------------------------------------------------
# refresh
#    change le buffer etaffiche le contenu
#------------------------------------------------------------
proc ::sophie::view::refresh { visuNo args } {
   variable private
   ::confVisu::autovisu $visuNo
}

