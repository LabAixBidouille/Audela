#
# Fichier : wizardacq.tcl
# Description : assistant pour le reglage des parametres de traitement
# Auteur : Michel PUJOL
# Mise à jour $Id: wizardacq.tcl,v 1.1 2011-01-16 19:05:10 michelpujol Exp $
#

################################################################
# namespace ::eshel::wizardacq
#
################################################################

namespace eval ::eshel::wizardacq {

}



#------------------------------------------------------------
# goAcquisitionLed
#   supprime les ressources specifiques
#   et sauvegarde les parametres avant de fermer la fenetre
#
#------------------------------------------------------------
proc ::eshel::wizardacq::goAcquisitionLed { visuNo } {
   variable private

   set catchResult [catch {
     #--- acquisition
     ::eshel::acquisition::startSequence $visuNo [list flatSerie [list expNb 1 expTime 10]]

     #--- traitement
     ::eshel::checkDirectory
     ::eshel::process::generateNightlog
     ::eshel::process::generateProcessBias
     ::eshel::process::generateScript

     #--- j'initialise le roadmap a vide
     set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]

     set roadmapNode [lindex [set [::dom::element getElementsByTagName $nightNode PROCESS ]] 0]
     if { $roadmapNode != "" } {
        ::dom::tcl::destroy $roadmapNode
     }
     set roadmapNode [::dom::document createElement $nightNode PROCESS ]

     #--- je recupere la liste des series identifiées
     set filesNode [::eshel::process::getFilesNode]




   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
      tk_messageBox -icon error -title $title -message $errorMessage
      setResult $visuNo selectLed "error" $::errorInfo
   }

}
