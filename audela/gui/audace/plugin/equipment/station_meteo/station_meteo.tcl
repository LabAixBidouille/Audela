#
# Fichier : station_meteo.tcl
# Description : Gere les donnees meteorologique issues de stations meteo
# Auteur : Robert DELMAS & Raymond ZACHANTKE
# Mise à jour $Id$
#

#
# Procedures generiques obligatoires (pour configurer tous les plugins camera, telescope, equipement) :
#     initPlugin      : Initialise le plugin
#     getStartFlag    : Retourne l'indicateur de lancement au demarrage
#     getPluginHelp   : Retourne la documentation htm associee
#     getPluginTitle  : Retourne le titre du plugin dans la langue de l'utilisateur
#     getPluginType   : Retourne le type de plugin
#     getPluginOS     : Retourne les OS sous lesquels le plugin fonctionne
#     fillConfigPage  : Affiche la fenetre de configuration de ce plugin
#     createPlugin    : Cree une instance du plugin
#     deletePlugin    : Arrete une instance du plugin et libere les ressources occupees
#     configurePlugin : Configure le plugin
#     isReady         : Informe de l'etat de fonctionnement du plugin
#

# Procedures specifiques a ce plugin :
#

namespace eval station_meteo {
   package provide station_meteo 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] station_meteo.cap ]
}

#------------------------------------------------------------
#  initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::station_meteo::initPlugin { } {
   global audace conf

   #--- Cree les variables dans conf(...) si elles n'existent pas
   if { ! [ info exists conf(station_meteo,pressure) ] }    { set conf(station_meteo,pressure)    "101325" }
   if { ! [ info exists conf(station_meteo,temperature) ] } { set conf(station_meteo,temperature) "290" }
   if { ! [ info exists conf(station_meteo,start) ] }       { set conf(station_meteo,start)       "0" }

   #--- Initialisation des variables audace
   set audace(meteo,obs,pressure)    $conf(station_meteo,pressure)
   set audace(meteo,obs,temperature) $conf(station_meteo,temperature)

}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::station_meteo::getPluginTitle { } {
   global caption

   return "$caption(station_meteo,label)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::station_meteo::getPluginHelp { } {
   return "station_meteo.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#
#  return "equipment"
#------------------------------------------------------------
proc ::station_meteo::getPluginType { } {
   return "equipment"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::station_meteo::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::station_meteo::getStartFlag { } {
   return $::conf(station_meteo,start)
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::fillConfigPage { frm } {
   variable widget
   global caption conf

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Copie de conf(...) dans la variable widget
   set widget(pressure)    $conf(station_meteo,pressure)
   set widget(temperature) $conf(station_meteo,temperature)

   #--- Frame pour le choix de la liaison et de la combinaison
   frame $frm.frame1 -borderwidth 0 -relief raised

   pack $frm.frame1 -side top -fill x

   #--- Frame des boutons de commande et de la representation de la roue a filtres
   frame $frm.frame2 -borderwidth 0 -relief raised

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame pour le site web et le checkbutton creer au demarrage
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Site web officiel des stations meteo supportees
      label $frm.frame3.lab103 -text "$caption(station_meteo,site_web)"
      pack $frm.frame3.lab103 -side top -fill x -pady 2

      set labelName [ ::confEqt::createUrlLabel $frm.frame3 "$caption(station_meteo,site_web_ref)" \
         "$caption(station_meteo,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Frame du bouton Arreter et du checkbutton creer au demarrage
      frame $frm.frame3.start -borderwidth 0 -relief flat

         #--- Bouton Arreter
         button $frm.frame3.start.stop -text "$caption(station_meteo,arreter)" -relief raised \
            -command { ::station_meteo::deletePlugin }
         pack $frm.frame3.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

         #--- Checkbutton demarrage automatique
         checkbutton $frm.frame3.start.chk -text "$caption(station_meteo,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(station_meteo,start)
         pack $frm.frame3.start.chk -side top -padx 10 -pady 3 -expand 1

      pack $frm.frame3.start -side left -expand 1

   pack $frm.frame3 -side bottom -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::configurePlugin { } {
   variable widget
   global audace conf

   #--- Memorise la configuration dans le tableau conf(station_meteo,...)
   set conf(station_meteo,pressure)    $widget(pressure)
   set conf(station_meteo,temperature) $widget(temperature)

   #--- Mise a jour des variables audace
   set audace(meteo,obs,pressure)    $conf(station_meteo,pressure)
   set audace(meteo,obs,temperature) $conf(station_meteo,temperature)
}

#------------------------------------------------------------
#  createPlugin
#     configure la roue a filtre
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::createPlugin { } {

}

#------------------------------------------------------------
#  deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::deletePlugin { } {

}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::station_meteo::isReady { } {

}

#==============================================================
# Procedures specifiques du plugin
#==============================================================

