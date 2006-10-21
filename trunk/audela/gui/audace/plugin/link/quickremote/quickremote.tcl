#
# Fichier : quickremote.tcl
# Description : Interface de liaison QuickRemote
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: quickremote.tcl,v 1.4 2006-10-21 16:34:01 robertdelmas Exp $
#

package provide quickremote 1.1

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

namespace eval quickremote {
}

#==============================================================
# Procedures generiques de configuration des drivers
#==============================================================

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#  
#  return nothing
#------------------------------------------------------------
proc ::quickremote::configureDriver { } {
   global audace

   #--- Affiche la liaison
   ####quickremote::run "$audace(base).quickremote"
   console::disp "::quickremote::configureDriver \n"

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
   global caption

}

#------------------------------------------------------------
# create
#    cree une liaison
#   
#    retourne le numero du link
#      le numero du link est attribue automatiquement
#      si ce link est deja cree , on retourne le numero du link existant
#
#   exemple :
#   ::parallelport::create "Quickremote1" "cam1" "acquisition" "bit 1"
#     1
#   ::parallelport::create "Quickremote2" "cam1" "longuepose" "bit 1"
#     2
#   ::parallelport::create "Quickremote2" "cam2" "longuepose" "bit 2"
#     2
#------------------------------------------------------------
proc ::quickremote::create { linkLabel deviceId usage comment } {
   set linkIndex [getLinkIndex $linkLabel]

   #---  je cree le lien
   set linkno [::link::create quickremote $linkIndex]
   #---  j'ajoute l'utilisation
   link$linkno use add $deviceId $usage $comment
   return $linkno
}

#------------------------------------------------------------
# delete
#    Supprime une utilisation d'une liaison
#    et supprime la liaison si elle n'est plus utilises par aucun autre peripherique
#    Ne fait rien si la liaison n'est pas ouverte
#
#    retourne rien
#------------------------------------------------------------
proc ::quickremote::delete { linkLabel deviceId usage } {
   set linkno [::confLink::getLinkNo $linkLabel]
   if { $linkno != "" } {
      link$linkno use remove $deviceId $usage
      if  { [link$linkno use get] == "" } {
         #--- je supprime la liaison si elle n'est plus utilisee par aucun peripherique
         ::link::delete $linkno
      }
   }
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#  
#  return nothing
#------------------------------------------------------------
proc ::quickremote::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #---  j'afffiche la liste des link
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(quickremote,available)
      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true
      Button  $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(quickremote,refresh)" -command { ::quickremote::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left

   pack $frm.available -side left -fill both -expand true

   #--- je mets  a jour la liste
   refreshAvailableList

   ::confColor::applyColor $private(frm)

}

#------------------------------------------------------------
#  getDriverType
#     retourne le type de driver
#  
#  return "link"
#------------------------------------------------------------
proc ::quickremote::getDriverType { } {
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
# getLinkIndex
#    retourne l'index du link
#   
#    retourne une chaine vide si le link n'existe pas
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
#  getLabel
#     retourne le label du driver
#  
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::quickremote::getLabel { } {
   global caption

   return "$caption(quickremote,titre)"
}

#------------------------------------------------------------
# ::quickremote::getLinkLabels
#    retourne les libelles des quickremote disponibles
#
#   exemple :
#   getLinkLabels "quickremote"
#     { "QuickRemote0" "QuickRemote1" }
#------------------------------------------------------------
proc ::quickremote::getLinkLabels { } {
   variable private

   set labels [list]
   foreach instance [link::available quickremote ] {
      lappend labels "$private(genericName)[lindex $instance 0]"
   }
   return $labels
}

#------------------------------------------------------------
# ::quickremote::getSelectedLinkLabel
#    retourne le link choisi
#
#   exemple :
#   getLinkLabels
#     "QuickRemote0"
#------------------------------------------------------------
proc ::quickremote::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if  { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne )
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  init (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#  
#  return namespace name
#------------------------------------------------------------
proc ::quickremote::init { } {
   global caption
   variable private

   #--- Charge le fichier caption
   uplevel #0  "source \"[ file join $::audace(rep_plugin) link quickremote quickremote.cap ]\""

   #--- je recupere le nom generique de la liaison
   set private(genericName) "quickremote"

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
proc ::quickremote::initConf { } {
   global conf

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#  
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::quickremote::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#      rafraichit la liste des link disponibles
#  
#  return nothing
#------------------------------------------------------------
proc ::quickremote::refreshAvailableList { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if  { $i == "" } {
      set i 0
   }
   set selectedLinkLabel [getSelectedLinkLabel]

   #--- j'efface le contenu de la liste
   $private(frm).available.list delete 0 [ $private(frm).available.list size]

   #--- je recupere les linkNo ouverts
   set linkNoList [link::list]

   #--- je remplis la liste
   foreach linkLabel [::quickremote::getLinkLabels] {
      set linkText ""
      #--- je recherche si ce link est ouvert
      foreach linkNo $linkNoList {
         if { "[link$linkNo index]" == [getLinkIndex $linkLabel] } {
            #--- si le link est ouvert, j'affiche son label, linkNo et les utilisations
            set linkText "$linkLabel link$linkNo [link$linkNo use get]"
         }
      }
      #--- si le link est ferme , j'affiche son label seulement
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
#  return nothing
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

::quickremote::init

