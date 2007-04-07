#
# Fichier : parallelport.tcl
# Description : Interface de liaison Port Parallele
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: parallelport.tcl,v 1.10 2007-04-07 00:35:17 michelpujol Exp $
#

namespace eval parallelport {
   package provide parallelport 1.0
   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] parallelport.cap ]
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::parallelport::getPluginProperty { propertyName } {
   switch $propertyName {
   }
}


#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::parallelport::getPluginTitle { } {
   global caption

   return "$caption(parallelport,titre)"
}

#------------------------------------------------------------
#  :getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::parallelport::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  init
#     initialise le driver
#     init est lance automatiquement au chargement de ce fichier tcl
#  return namespace
#------------------------------------------------------------
proc ::parallelport::initPlugin { } {
   variable private
   #--- je recupere le nom generique de la liaison
   ##set private(genericName) [link::genericname parallelport]
   if { $::tcl_platform(os) == "Linux" } {
      set private(genericName) "/dev/parport"
   } else {
      set private(genericName) "LPT";
   }
}


#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return rien
#------------------------------------------------------------
proc ::parallelport::configureDriver { } {
   global audace

   #--- Affiche la liaison
   ###parallelport::run "$audace(base).parallelport"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::parallelport::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  createPluginInstance
#     cree une liaison
#
#     retourne le numero du link
#       le numero du link est attribue automatiquement
#       si ce link est deja cree, on retourne le numero du link existant
#
#   exemple :
#   ::parallelport::create "LPT1:" "cam1" "acquisition" "bit 1"
#     1
#   ::parallelport::create "LPT2:" "cam1" "longuepose" "bit 1"
#     2
#   ::parallelport::create "LPT2:" "cam2" "longuepose" "bit 2"
#     2
#------------------------------------------------------------
proc ::parallelport::createPluginInstance { linkLabel deviceId usage comment } {
   global audace

   set linkIndex [getLinkIndex $linkLabel]
   #--- je cree le lien
   set linkno [::link::create parallelport $linkIndex]
   #--- j'ajoute l'utilisation
   link$linkno use add $deviceId $usage $comment
   #--- je rafraichis la liste
   if { [ winfo exists $audace(base).confLink ] } {
      ::parallelport::refreshAvailableList
   }
   #--- je selectionne le link
   if { [ winfo exists $audace(base).confLink ] } {
      ::parallelport::selectConfigLink $linkLabel
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
proc ::parallelport::deletePluginInstance { linkLabel deviceId usage } {
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
         ::parallelport::refreshAvailableList
      }
   }
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return rien
#------------------------------------------------------------
proc ::parallelport::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #---  j'afffiche la liste des link
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(parallelport,available)
      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true
      Button $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(parallelport,refresh)" -command { ::parallelport::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left

   pack $frm.available -side left -fill both -expand true

   #--- je mets a jour la liste
   refreshAvailableList

   ::confColor::applyColor $private(frm)
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::parallelport::getHelp { } {
   return "parallelport.htm"
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#     retourne une chaine vide si le type du link n'existe pas
#
#   exemple :
#   getLinkIndex "LPT1:"
#     1
#------------------------------------------------------------
proc ::parallelport::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   scan $linkLabel "$private(genericName)%d" linkIndex
   return $linkIndex
}


#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des ports paralleles disponibles
#
#   exemple :
#   getLinkLabel
#   { "LPT1:" "LPT2:" "LPT3:" }
#------------------------------------------------------------
proc ::parallelport::getLinkLabels { } {
   set linkLabels [list]
   set instances [link::available parallelport ]
   foreach instance $instances {
      ####lappend linkLabels "[getLabel][lindex $instance 0]"
      lappend linkLabels "[lindex $instance 1]"
   }
   return $linkLabels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "LPT1:"
#------------------------------------------------------------
proc ::parallelport::getSelectedLinkLabel { } {
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
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::parallelport::isReady { } {

   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::parallelport::refreshAvailableList { } {
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
   foreach linkLabel [::parallelport::getLinkLabels] {
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

   return
}

#------------------------------------------------------------
#  selectConfigItem
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::parallelport::selectConfigLink { linkLabel } {
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
proc ::parallelport::widgetToConf { } {
   variable widget
   global conf

}