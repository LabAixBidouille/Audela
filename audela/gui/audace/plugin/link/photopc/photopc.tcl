#
# Fichier : photopc.tcl
# Description : Interface de liaison PhotoPC
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: photopc.tcl,v 1.5 2007-04-07 00:35:18 michelpujol Exp $
#


namespace eval photopc {
   package provide photopc 1.0
   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] photopc.cap ]
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
#  createPluginInstance
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::createPluginInstance { linkLabel deviceId usage comment } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::photopc::deletePluginInstance { linkLabel deviceId usage } {
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
proc ::photopc::getPluginProperty { propertyName } {
   switch $propertyName {
      
   }
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
#  getPluginType 
#     retourne le type de driver
#------------------------------------------------------------
proc ::photopc::getPluginType  { } {
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
#  getPluginTitle
#     retourne le label du driver dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::photopc::getPluginTitle { } {
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
#------------------------------------------------------------
proc ::photopc::initPlugin  { } {
   variable private


   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "photopc"

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

