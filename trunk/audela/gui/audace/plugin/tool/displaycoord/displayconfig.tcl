#
# Fichier : session.tcl
# Description : configuration des parametres de session
# Auteur : Michel PUJOL
# Mise a jour $Id: displayconfig.tcl,v 1.1 2009-12-14 18:56:14 michelpujol Exp $
#

################################################################
# namespace ::displaycoord::config
#
################################################################

namespace eval ::displaycoord::config {
   
}

##------------------------------------------------------------
# affiche la fenetre du traitement
#
# Utilise les fonctions de la classe parent ::confGenerique
# @param tkbase nom tk de la fenêtre parent
# @param visuNo  numero de la visu parent
# @return rien
# @public
#------------------------------------------------------------
proc ::displaycoord::config::run { tkbase visuNo } {
   variable private
   
   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(displaycoord,configWindowPosition) ] } { set ::conf(displaycoord,configWindowPosition) "300x200+20+10" }
   
   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.config"
   ::confGenerique::run  $visuNo $private($visuNo,This) "::displaycoord::config" -modal 0 -geometry $::conf(displaycoord,configWindowPosition) -resizable 1
   
}

##------------------------------------------------------------
# ferme la fenetre
#
# @param visuNo  numero de la visu
# @return
#   - 0  s'il ne faut pas fermer la fenêtre
#   - 1  s'il faut fermer la fenêtre
# @public
#------------------------------------------------------------
proc ::displaycoord::config::closeWindow { visuNo } {
   variable private
   
   #--- je memorise la position courante de la fenetre
   set ::conf(displaycoord,configWindowPosition) [ wm geometry $private($visuNo,This) ]
}

##------------------------------------------------------------
# affiche l'aide de cet outil
#
# Cette procedure est appelée par ::confGenerique::showHelp
# @return rien
# @private
#------------------------------------------------------------
proc ::displaycoord::config::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::displaycoord::getPluginType]] \
   [::eshel::getPluginDirectory] [::eshel::getPluginHelp]
}


##------------------------------------------------------------
# enregistre les modifications
#
# Cette procedure est appelée par ::confGenerique::apply
# @param visuNo  numero de la visu parent
# @return rien
# @private
#------------------------------------------------------------
proc ::displaycoord::config::apply { visuNo } {
   variable widget
      
   #--- je copie les autres valeurs dans les variables
   set ::conf(displaycoord,serverHost)  $widget(serverHost)
   set ::conf(displaycoord,serverPort)  $widget(serverPort)
   
   #--- je relance la connexion au serveur de coordonnees
   ::displaycoord::startConnectionLoop    
   
}

##------------------------------------------------------------
# Crée les widgets de la fenetre de configuration de la session
#
# Cette procedure est appelée par ::confGenerique::fillConfigPage a la creation de la fenetre
# @param frm nom tk de la frame cree par ::confgene::fillConfigPage
# @param visuNo numero de la visu
# @return  rien
# @private
#------------------------------------------------------------
proc ::displaycoord::config::fillConfigPage { frm visuNo } {
   variable widget
   variable private
   global caption
   
   set private($visuNo,frm) $frm
   
   #--- j'initalise les variables temporaires
   set widget(serverHost) $::conf(displaycoord,serverHost)
   set widget(serverPort) $::conf(displaycoord,serverPort)
   
   
   label  $frm.serverHostLabel  -text $caption(displaycoord,serverHost) -justify left
   entry  $frm.serverHostEntry  -textvariable ::displaycoord::config::widget(serverHost) -justify left
   label  $frm.serverPortLabel  -text $caption(displaycoord,serverPort) -justify left
   entry  $frm.serverPortEntry  -textvariable ::displaycoord::config::widget(serverPort) -justify left -width 8
   
   #--- placement dans la grille
   grid $frm.serverHostLabel    -in $frm -row 0 -column 0 -sticky wn  -padx 2
   grid $frm.serverHostEntry    -in $frm -row 0 -column 1 -sticky wen -padx 2
   grid $frm.serverPortLabel    -in $frm -row 1 -column 0 -sticky wn  -padx 2
   grid $frm.serverPortEntry    -in $frm -row 1 -column 1 -sticky wn  -padx 2
   
   grid columnconfig $frm 1 -weight 1
   
   
   pack $frm  -side top -fill x -expand 1
}


##------------------------------------------------------------
# retourne le titre de la fenetre
#
# Cette procedure est appelée par ::confGenerique::getLabel
# @return  titre de la fenêtre
# @private
#------------------------------------------------------------
proc ::displaycoord::config::getLabel { } {
   global caption
   
   return "$caption(displaycoord,title)"
}
