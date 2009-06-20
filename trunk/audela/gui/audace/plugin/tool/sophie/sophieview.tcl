#
# Fichier : sophieview.tcl
# Description : Vue detail du suivi
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophieview.tcl,v 1.9 2009-06-20 17:32:26 michelpujol Exp $
#

##------------------------------------------------------------
# @brief   visualisation des images
#
#------------------------------------------------------------
namespace eval ::sophie::view {

}

##------------------------------------------------------------
# run
#    affiche la fenetre du configuration
# @param sophieVisu  numero de la visu de la fenetre principale de l'outil sophie
# @return null
#------------------------------------------------------------
proc ::sophie::view::run { sophieVisu } {
   variable private

   set private(sophieVisu) $sophieVisu
   #--- j'ouvre une visu pour afficher des profils
   set visuNo [::confVisu::create]
   confVisu::selectTool $visuNo ""
   Menu_Delete $visuNo $::caption(audace,menu,tool) all
   createPluginInstance [::confVisu::getBase $visuNo].tool $visuNo
   lappend ::confVisu::private($visuNo,pluginInstanceList) "sophie::view"
   set ::confVisu::private($visuNo,currentTool) "sophie::view"
   startTool $visuNo
   grid [::confVisu::getBase $visuNo].tool -row 0 -column 0 -rowspan 2 -sticky ns
}

##------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::sophie::view::createPluginInstance { { in "" } { visuNo 1 } } {
   variable private

   #--- je memorise le buffer initial
   set private(initialBuffer,$visuNo) [::confVisu::getBufNo $visuNo]

   set private(bufferName,$visuNo)    "maskBufNo"

   #--- Petit raccourci
   set private(frm) "$in.sophieview"
   set frm $private(frm)

   #--- Interface graphique de l'outil
   frame $frm -borderwidth 2 -relief groove

      #--- Frame du titre et de la configuration
      frame $frm.select -borderwidth 2 -relief groove

         #--- Bouton de selection de l'image a afficher
         radiobutton $frm.select.mask -highlightthickness 0 -state normal \
            -text "$::caption(sophie,masque)" \
            -value "maskBufNo" \
            -variable ::sophie::view::private(bufferName,$visuNo) \
            -command "::sophie::view::setBuffer $visuNo"
         pack $frm.select.mask -side top -anchor w -ipady 2 -padx 2 -pady 2

         radiobutton $frm.select.sum -highlightthickness 0 -state normal \
            -text "$::caption(sophie,imageIntegree)" \
            -value "sumBufNo" \
            -variable ::sophie::view::private(bufferName,$visuNo) \
            -command "::sophie::view::setBuffer $visuNo"
         pack $frm.select.sum -side top -anchor w -ipady 2 -padx 2 -pady 2

         radiobutton $frm.select.fiber -highlightthickness 0 -state normal \
            -text "$::caption(sophie,imageInversee)" \
            -value "fiberBufNo" \
            -variable ::sophie::view::private(bufferName,$visuNo) \
            -command "::sophie::view::setBuffer $visuNo"
         pack $frm.select.fiber -side top -anchor w -ipady 2 -padx 2 -pady 2

      pack $frm.select -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
}

##------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::sophie::view::deletePluginInstance { visuNo } {

   #--- je restaure le numero du buffer initial
   ##::sophie::setBuffer $visuNo ""
}

##------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::view::startTool { visuNo } {
   variable private

   #--- j'affiche l'outil
   pack $private(frm) -side left -fill y
   #--- je choisi les seuils initiaux par defaut
   set ::conf(seuils,visu$visuNo,mode) "initiaux"

   #--- je passe en zoom x1
   ::confVisu::setZoom  $visuNo 1
   #--- j'affiche l'image du buffer
   setBuffer $visuNo
   #--- je demarre le listener
   ::sophie::addAcquisitionListener $private(sophieVisu) "::sophie::view::refresh $visuNo"
}

##------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::sophie::view::stopTool { visuNo } {
   variable private

   #--- j'arrete le listener
   ::sophie::removeAcquisitionListener $private(sophieVisu) "::sophie::view::refresh $visuNo"
   ##after 1000
   #--- je restaure le numero du buffer initial
   visu$visuNo buf $private(initialBuffer,$visuNo)
   #--- je masque l'outil
   pack forget $private(frm)
}

##------------------------------------------------------------
# setBuffer
#    change le buffer et affiche le contenu
# @param visuNo  numero de la visu
# @param bufferName  nom du buffer
# @return null
#------------------------------------------------------------
proc ::sophie::view::setBuffer { visuNo { bufferName "" } } {
   variable private

   if { $bufferName == "" } {
      set bufferName $private(bufferName,$visuNo)
   } else {
      set private(bufferName,$visuNo) $bufferName
   }

   switch $bufferName {
      "maskBufNo" -
      "sumBufNo"  -
      "fiberBufNo" {
         visu$visuNo buf [::sophie::getBufNo $bufferName]
      }
      "initialBuffer" {
         visu$visuNo buf $private(initialBuffer,$visuNo)
      }
   }
   ::confVisu::autovisu $visuNo
}

##------------------------------------------------------------
# refresh
#    rafraichit l'affichage
#
# @param visuNo  numero de la visu
# @param args    liste de parametres fournis par le listener
# @return null
#------------------------------------------------------------
proc ::sophie::view::refresh { visuNo args } {
   variable private
   if { [winfo exists $private(frm) ] } {
      ::confVisu::autovisu $visuNo
   }
}

