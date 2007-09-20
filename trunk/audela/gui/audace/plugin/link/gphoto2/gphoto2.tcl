#
# Fichier : gphoto2.tcl
# Description : Interface de liaison GPhoto2
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: gphoto2.tcl,v 1.9 2007-09-20 20:15:50 robertdelmas Exp $
#

namespace eval gphoto2 {
   package provide gphoto2 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] gphoto2.cap ]
}

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::configureDriver { } {
   global audace

   #--- Affiche la liaison
  ### gphoto2::run "$audace(base).gphoto2"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::gphoto2::confToWidget { } {
   variable widget
   global conf

   set widget(debug) $conf(dslr,debug)
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::createPluginInstance { linkLabel deviceId usage comment } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::deletePluginInstance { linkLabel deviceId usage } {
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::gphoto2::getPluginProperty { propertyName } {
   switch $propertyName {

   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du driver dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::gphoto2::getPluginTitle { } {
   global caption

   return "$caption(gphoto2,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::gphoto2::getPluginHelp { } {
   return "gphoto2.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de driver
#------------------------------------------------------------
proc ::gphoto2::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::gphoto2::getPluginOS { } {
   return [ list Windows Linux Darwin ]
   }

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::fillConfigPage { frm } {
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- mode debug
   checkbutton $frm.debug -text "$caption(dslr,debug)" -highlightthickness 0 \
      -variable ::gphoto2::widget(debug)
   pack $frm.debug -in $frm -anchor center -side left -padx 10 -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
# getLinkIndex
#    retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#
#------------------------------------------------------------
proc ::gphoto2::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   if { [string first $private(genericName) $linkLabel]  == 0 } {
      scan $linkLabel "$private(genericName)%s" linkIndex
   }
   return $linkIndex
}

#------------------------------------------------------------
# getLinkLabels
#    retourne le label du seul link
#
#------------------------------------------------------------
proc ::gphoto2::getLinkLabels { } {
   variable private

   return "$private(genericName)1"
}

#------------------------------------------------------------
# getSelectedLinkLabel
#    retourne le link choisi
#
#------------------------------------------------------------
proc ::gphoto2::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#------------------------------------------------------------
proc ::gphoto2::initPlugin { } {
   variable private

   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "gphoto2"

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::gphoto2::initConf { } {
   global conf

   if { ! [ info exists conf(dslr,debug) ] } { set conf(dslr,debug) "0" }
   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::gphoto2::isReady { } {
   return 0
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::selectConfigLink { linkLabel } {
   variable private

   #--- rien a faire car il n'y qu'un seul link de ce type
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::gphoto2::widgetToConf { } {
   variable widget
   global conf

   set conf(dslr,debug) $widget(debug)
}

