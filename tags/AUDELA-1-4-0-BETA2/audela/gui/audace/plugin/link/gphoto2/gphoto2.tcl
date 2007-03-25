#
# Fichier : gphoto2.tcl
# Description : Interface de liaison GPhoto2
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: gphoto2.tcl,v 1.5 2007-01-27 15:16:14 robertdelmas Exp $
#

package provide gphoto2 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init              : initialise le namespace (appelee pendant le chargement de ce source)
#     getDriverName     : retourne le nom du driver
#     getLabel          : retourne le nom affichable du driver
#     getHelp           : retourne la documentation htm associee
#     getDriverType     : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf          : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()
#     fillConfigPage    : affiche la fenetre de configuration de ce driver
#     confToWidget      : copie le tableau conf() dans les variables des widgets
#     widgetToConf      : copie les variables des widgets dans le tableau conf()
#     configureDriver   : configure le driver
#     stopDriver        : arrete le driver et libere les ressources occupees
#     isReady           : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :
#

namespace eval gphoto2 {
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
   ###gphoto2::run "$audace(base).gphoto2"

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

   set widget(debug)     $conf(dslr,debug)
}

#------------------------------------------------------------
#  create
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::create { linkLabel deviceId usage comment } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  delete
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::delete { linkLabel deviceId usage } {
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
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

}

#------------------------------------------------------------
#  getDriverType
#     retourne le type de driver
#
#  return "link"
#------------------------------------------------------------
proc ::gphoto2::getDriverType { } {
   return "link"
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::gphoto2::getHelp { } {
   return "gphoto2.htm"
}

#------------------------------------------------------------
#  getLabel
#     retourne le label du driver
#
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::gphoto2::getLabel { } {
   global caption

   return "$caption(gphoto2,titre)"
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
#  init (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#
#  return namespace name
#------------------------------------------------------------
proc ::gphoto2::init { } {
   variable private

   #--- Charge le fichier caption
   source [ file join $::audace(rep_plugin) link gphoto2 gphoto2.cap ]

   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "gphoto2"

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   #--- J'initialise les variables widget(..)
   confToWidget

   return [namespace current]
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::gphoto2::initConf { } {
   global conf

   if { ! [ info exists conf(dslr,debug) ] }     { set conf(dslr,debug)      "0" }

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
#  selectConfigItem
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
   set conf(dslr,debug)     $widget(debug)
}

::gphoto2::init

