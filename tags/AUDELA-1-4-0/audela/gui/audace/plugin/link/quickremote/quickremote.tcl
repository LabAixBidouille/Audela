#
# Fichier : quickremote.tcl
# Description : Interface de liaison QuickRemote
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: quickremote.tcl,v 1.13 2007-05-19 10:40:40 robertdelmas Exp $
#

namespace eval quickremote {
   package provide quickremote 1.1

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] quickremote.cap ]
}

#==============================================================
# Procedures generiques de configuration des drivers
#==============================================================

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::configureDriver { } {
   global audace

   #--- rien a faire ,
   #--- car la liaison est configuree par le peripherique qui l'utilise

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#     retourne le numero du link
#       le numero du link est attribue automatiquement
#       si ce link est deja cree, on retourne le numero du link existant
#
#   exemple :
#   ::quickremote::create "quickremote1" "cam1" "acquisition" "bit 1"
#     1
#   ::quickremote::create "quickremote2" "cam1" "longuepose" "bit 1"
#     2
#   ::quickremote::create "quickremote2" "cam2" "longuepose" "bit 2"
#     2
#------------------------------------------------------------
proc ::quickremote::createPluginInstance { linkLabel deviceId usage comment } {
   global audace

   set linkIndex [getLinkIndex $linkLabel]
   #--- je cree le lien
   set linkno [::link::create quickremote $linkIndex]
   #--- j'ajoute l'utilisation
   link$linkno use add $deviceId $usage $comment
   #--- je rafraichis la liste
   if { [ winfo exists $audace(base).confLink ] } {
      ::quickremote::refreshAvailableList
   }
   #--- je selectionne le link
   if { [ winfo exists $audace(base).confLink ] } {
      ::quickremote::selectConfigLink $linkLabel
   }
   #---
   return $linkno
}

#------------------------------------------------------------
#  deletePluginInstance
#     Supprime une utilisation d'une liaison
#     et supprime la liaison si elle n'est plus utilises par aucun autre peripherique
#     Ne fait rien si la liaison n'est pas ouverte
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::deletePluginInstance { linkLabel deviceId usage } {
   global audace

   set linkno [::confLink::getLinkNo $linkLabel]
   if { $linkno != "" } {
      link$linkno use remove $deviceId $usage
      if { [link$linkno use get] == "" } {
         #--- je supprime la liaison si elle n'est plus utilisee par aucun peripherique
         ::link::delete $linkno
      }
      #--- je rafraichis la liste
      if { [ winfo exists $audace(base).confLink ] } {
         ::quickremote::refreshAvailableList
      }
   }
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::quickremote::getPluginProperty { propertyName } {
   switch $propertyName {

   }
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- j'afffiche la liste des link
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(quickremote,available)
      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true
      Button $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(quickremote,refresh)" -command { ::quickremote::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left
   pack $frm.available -side top -fill both -expand true

   frame $frm.statusMessage -borderwidth 0 -relief ridge
      label $frm.statusMessage.statusMessage_lab -text "$caption(quickremote,error)"
      pack $frm.statusMessage.statusMessage_lab -in $frm.statusMessage -side top -anchor nw -padx 5 -pady 5
      Label $frm.statusMessage.status -textvariable ::quickremote::private(statusMessage) -width 60 -height 4 \
         -wraplength 400 -justify left
      pack $frm.statusMessage.status -in $frm.statusMessage -side top -anchor nw -padx 20
   pack $frm.statusMessage -side top -fill x

   #--- je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de driver
#------------------------------------------------------------
proc ::quickremote::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::quickremote::getHelp { } {
   return "quickremote.htm"
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du driver dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::quickremote::getPluginTitle { } {
   global caption

   return "$caption(quickremote,titre)"
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#     retourne une chaine vide si le link n'existe pas
#
#   exemple :
#   getLinkIndex "quickremote1"
#     1
#------------------------------------------------------------
proc ::quickremote::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   scan $linkLabel "$private(genericName)%d" linkIndex
   return $linkIndex
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des quickremote disponibles
#
#   exemple :
#   getLinkLabels
#     { "quickremote0" "quickremote1" }
#------------------------------------------------------------
proc ::quickremote::getLinkLabels { } {
   variable private

   #--- j'initialise une liste vide
   set labels [list]
   catch {
      foreach instance [link::available quickremote ] {
         lappend labels "$private(genericName)[lindex $instance 0]"
      }
   } catchError
   set private(statusMessage) $catchError

   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "quickremote0"
#------------------------------------------------------------
proc ::quickremote::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne )
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#------------------------------------------------------------
proc ::quickremote::initPlugin { } {
   variable private

   #--- je fixe le nom generique de la liaison
   set private(genericName)   "quickremote"
   set private(statusMessage) ""

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
proc ::quickremote::initConf { } {
   global conf

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::quickremote::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::refreshAvailableList { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   set selectedLinkLabel [getSelectedLinkLabel]

   #--- j'efface le contenu de la liste
   $private(frm).available.list delete 0 [ $private(frm).available.list size]

   #--- je recupere les linkNo ouverts
   set linkNoList [link::list]

   #--- je remplis la liste
   foreach linkLabel [getLinkLabels] {
      set linkText ""
      #--- je recherche si ce link est ouvert
      foreach linkNo $linkNoList {
         if { "[link$linkNo index]" == [getLinkIndex $linkLabel] } {
            #--- si le link est ouvert, j'affiche son label, linkNo et les utilisations
            set linkText "$linkLabel link$linkNo [link$linkNo use get]"
         }
      }
      #--- si le link est ferme, j'affiche son label seulement
      if { $linkText == "" } {
         set linkText "$linkLabel"
      }
      $private(frm).available.list insert end $linkText
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::selectConfigLink { linkLabel } {
   variable private

   $private(frm).available.list selection clear 0 end

   #--- je recherche linkLabel dans la listbox  (linkLabel est le premier element de chaque ligne)
   for {set i 0} {$i<[$private(frm).available.list size]} {incr i} {
      if { [lindex [$private(frm).available.list get $i] 0] == $linkLabel } {
         $private(frm).available.list selection set $i
         return
      }
   }
   if { [$private(frm).available.list size] > 0 } {
      #--- sinon je selectionne le premier linkLabel
      $private(frm).available.list selection set 0
   }
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::widgetToConf { } {
   variable widget
   global conf

}

