#
# Fichier : quickaudine.tcl
# Description : Interface de liaison QuickAudine
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: quickaudine.tcl,v 1.11 2007-03-11 19:16:23 robertdelmas Exp $
#

package provide quickaudine 1.0

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

namespace eval quickaudine {
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
proc ::quickaudine::configureDriver { } {
   global audace

   #--- Affiche la liaison
   ###quickaudine::run "$audace(base).quickaudine"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  create
#     demarre la liaison
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::create { linkLabel deviceId usage comment } {
   global audace

   #--- je rafraichis la liste
   if { [ winfo exists $audace(base).confLink ] } {
      ::quickaudine::refreshAvailableList
   }
   #--- je selectionne le link
   if { [ winfo exists $audace(base).confLink ] } {
      ::quickaudine::selectConfigLink $linkLabel
   }
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  delete
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::delete { linkLabel deviceId usage } {
   global audace

   #--- je rafraichis la liste
   if { [ winfo exists $audace(base).confLink ] } {
      ::quickaudine::refreshAvailableList
   }
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- j'afffiche la liste des link
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(quickaudine,available)
      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true
      Button $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(quickaudine,refresh)" -command { ::quickaudine::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left
   pack $frm.available -side top -fill both -expand true

   frame $frm.statusMessage -borderwidth 0 -relief ridge
      label $frm.statusMessage.statusMessage_lab -text "$caption(quickaudine,error)"
      pack $frm.statusMessage.statusMessage_lab -in $frm.statusMessage -side top -anchor nw -padx 5 -pady 5
      Label $frm.statusMessage.status -textvariable ::quickaudine::private(statusMessage) -width 60 -height 4 \
         -wraplength 400 -justify left
      pack $frm.statusMessage.status -in $frm.statusMessage -side top -anchor nw -padx 20
   pack $frm.statusMessage -side top -fill x

   #--- je mets a jour la liste
   refreshAvailableList

   ::confColor::applyColor $private(frm)
}

#------------------------------------------------------------
#  getDriverType
#     retourne le type de driver
#
#  return "link"
#------------------------------------------------------------
proc ::quickaudine::getDriverType { } {
   return "link"
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::quickaudine::getHelp { } {
   return "quickaudine.htm"
}

#------------------------------------------------------------
#  getLabel
#     retourne le label du driver
#
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::quickaudine::getLabel { } {
   global caption

   return "$caption(quickaudine,titre)"
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#
#   exemple :
#   getLinkIndex "quickaudine1"
#     1
#------------------------------------------------------------
proc ::quickaudine::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   scan $linkLabel "$private(genericName)%s" linkIndex
   return $linkIndex
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des quickaudine disponibles
#
#   exemple :
#   getLinkLabels
#     { "quickaudine0" "quickaudine1" }
#------------------------------------------------------------
proc ::quickaudine::getLinkLabels { } {
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
#     "quickaudine0"
#------------------------------------------------------------
proc ::quickaudine::getSelectedLinkLabel { } {
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
#  init (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#
#  return namespace
#------------------------------------------------------------
proc ::quickaudine::init { } {
   variable private

   #--- Charge le fichier caption
   source [ file join $::audace(rep_plugin) link quickaudine quickaudine.cap ]

   #--- je fixe le nom generique de la liaison
   set private(genericName)   "quickaudine"
   set private(statusMessage) ""

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
proc ::quickaudine::initConf { } {
   global conf

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::quickaudine::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::refreshAvailableList { } {
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
#  selectConfigItem
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::selectConfigLink { linkLabel } {
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
proc ::quickaudine::widgetToConf { } {
   variable widget
   global conf

}

::quickaudine::init

