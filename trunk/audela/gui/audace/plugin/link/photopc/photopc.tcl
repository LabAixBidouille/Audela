#
# Fichier : photopc.tcl
# Description : Interface de liaison PhotoPC
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: photopc.tcl,v 1.4 2007-01-27 15:16:32 robertdelmas Exp $
#

package provide photopc 1.0

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

namespace eval photopc {
}

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::configureDriver { } {
   global audace

   #--- Affiche la liaison
   ###photopc::run "$audace(base).photopc"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::photopc::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  create
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::create { linkLabel deviceId usage comment } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  delete
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::delete { linkLabel deviceId usage } {
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::fillConfigPage { frm } {
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set widget(frm) $frm
}

#------------------------------------------------------------
#  getDriverType
#     retourne le type de driver
#
#  return "link"
#------------------------------------------------------------
proc ::photopc::getDriverType { } {
   return "link"
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::photopc::getHelp { } {
   return "photopc.htm"
}

#------------------------------------------------------------
#  getLabel
#     retourne le label du driver
#
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::photopc::getLabel { } {
   global caption

   return "$caption(photopc,titre)"
}

#------------------------------------------------------------
# getLinkIndex
#    retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#
#------------------------------------------------------------
proc ::photopc::getLinkIndex { linkLabel } {
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
proc ::photopc::getLinkLabels { } {
   variable private

   return "$private(genericName)1"
}

#------------------------------------------------------------
# getSelectedLinkLabel
#    retourne le link choisi
#
#------------------------------------------------------------
proc ::photopc::getSelectedLinkLabel { } {
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
proc ::photopc::init { } {
   variable private

   #--- Charge le fichier caption
   source [ file join $::audace(rep_plugin) link photopc photopc.cap ]

   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "photopc"

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
proc ::photopc::initConf { } {
   global conf

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::photopc::isReady { } {
   return 0
}

#------------------------------------------------------------
#  selectConfigItem
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::selectConfigLink { linkLabel } {
   variable private

   #--- rien a faire car il n'y qu'un seul link de ce type
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::photopc::widgetToConf { } {
   variable widget
   global conf

}

::photopc::init

