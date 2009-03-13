#
# Fichier : confLink.tcl
# Description : Gere des objets 'liaison' pour la communication
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: conflink.tcl,v 1.34 2009-03-13 23:43:57 michelpujol Exp $
#

namespace eval ::confLink {
}

#------------------------------------------------------------
# ::confLink::init ( est lance automatiquement au chargement de ce fichier tcl)
#    Initialise les variable conf(..) et caption(..)
#    Demarre le plugin selectionne par defaut
#------------------------------------------------------------
proc ::confLink::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" conflink.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   if { ! [ info exists conf(confLink,start) ] }    { set conf(confLink,start)    "0" }
   if { ! [ info exists conf(confLink,position) ] } { set conf(confLink,position) "+15+15" }

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confLink"

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" link]
   #--- je recherche les plugin presents
   findPlugin

   #--- configure le plugin selectionne par defaut
   #if { $conf(confLink,start) == "1" } {
   #   configurePlugin
   #}
}

#------------------------------------------------------------
# ::confLink::afficheAide
#    Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confLink::afficheAide { } {
   variable private

   #--- j'affiche la documentation
   set selectedPluginName  [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp          [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#------------------------------------------------------------
# ::confLink::appliquer
#    Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
#    memoriser et appliquer la configuration
#------------------------------------------------------------
proc ::confLink::appliquer { } {
   variable private
   global audace

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le nom du plugin selectionne
   set linkNamespace [ $private(frm).usr.onglet raise ]


   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach name $private(authorizedPresentNamespaces) {
      $name\:\:widgetToConf
   }

   #--- je recupere le link choisi (pour la procedure ::confLink::run)
   set private(linkLabel) [$linkNamespace\:\:getSelectedLinkLabel]
   set $private(variableLinkLabel) $private(linkLabel)

   #--- je demarre le plugin selectionne
   configurePlugin


   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
# ::confLink::getLabel
#    Retourne le titre de la fenetre
#
# return "Titre de la fenetre de choix (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::confLink::getLabel { } {
   global caption

   return "$caption(conflink,config)"
}

#------------------------------------------------------------
# ::confLink::ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
#    la configuration, et fermer la fenetre de reglage
#------------------------------------------------------------
proc ::confLink::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# ::confLink::fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confLink::fermer { } {
   variable private

   ::confLink::recup_position
   destroy $private(frm)
}

#------------------------------------------------------------
# ::confLink::recup_position
#    Permet de recuperer et de sauvegarder la position de la
#    fenetre de configuration de la liaison
#------------------------------------------------------------
proc ::confLink::recup_position { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set deb [ expr 1 + [ string first + $private(geometry) ] ]
   set fin [ string length $private(geometry) ]
   set private(position) "+[ string range $private(geometry) $deb $fin ]"
   #---
   set conf(confLink,position) $private(position)
}

#------------------------------------------------------------
# ::confLink::createDialog
#    Affiche la fenetre a onglet
#
# Parametres :
#    authorizedNamespaces : Liste des onglets a afficher
#      Si la chaine est vide tous les onglets sont affiches
#    configurationTitle : Titre complementaire de la fenetres de dialogue
# return 0 = OK , 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confLink::createDialog { authorizedNamespaces configurationTitle } {
   variable private
   global caption conf

   if { [winfo exists $private(frm)] } {
      destroy $private(frm)
   }

   #--- Je verifie qu'il y a des liaisons
   if { [llength $authorizedNamespaces] <1 } {
      tk_messageBox -title "$caption(conflink,config) $configurationTitle" \
         -message "$caption(conflink,pas_liaison)" -icon error
      return 1
   }

   #---
   set private(position) $conf(confLink,position)

   #---
   if { [ info exists private(geometry) ] } {
      set deb [ expr 1 + [ string first + $private(geometry) ] ]
      set fin [ string length $private(geometry) ]
      set private(position) "+[ string range $private(geometry) $deb $fin ]"
   }

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) 580x420$private(position)
   wm minsize $private(frm) 580 420
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(conflink,config) $configurationTitle"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confLink::fermer"

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(conflink,ok)" -relief raised -state normal -width 7 \
         -command " ::confLink::ok "
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(conflink,appliquer)" -relief raised -state normal -width 8 \
         -command " ::confLink::appliquer "
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(conflink,fermer)" -relief raised -state normal -width 7 \
         -command " ::confLink::fermer "
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(conflink,aide)" -relief raised -state normal -width 8 \
         -command " ::confLink::afficheAide "
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      checkbutton $private(frm).start.chk -text "$caption(conflink,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(confLink,start)
      pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x

   pack $private(frm).start -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $authorizedNamespaces {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title    "  ]
         ### -raisecmd "::confLink::onRaiseNotebook $namespace"
         ::$namespace\::fillConfigPage $frm
      }
      pack $notebook -fill both -expand 1 -padx 4 -pady 4

   pack $private(frm).usr -side top -fill both -expand 1

   #--- La fenetre est active
   focus $private(frm)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private(frm) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)

   return 0
}

#------------------------------------------------------------
# ::confLink::create
#    Cree une liaison
#
# @param linkLabel  identifiant de la liaison
# @param deviceId   identifiant du peripherique qui utilise la liaison
# @param usage      type d'utilisation
# @param comment    commentaire facultatif
# @param args       arguments optionnels (depend du type de liaison)s
# @return linkno    Retourne le numero du link
#      Le numero du link est attribue automatiquement
#      Si ce link est deja cree, on retourne le numero du link existant
#
#    Retourne une chaine vide si le type du lien n'existe pas
#    Exemple :
#    ::confLink::create "quickaudine0" "cam1" "acquisition" "bit 1"
#    1
#    ::confLink::create "quickremote1" "cam1" "longuepose" "bit 1"
#    2
#    ::confLink::create "quickremote1" "cam2" "longuepose" "bit 2"
#    2
#------------------------------------------------------------
proc ::confLink::create { linkLabel deviceId usage comment args } {
   set linkNamespace [getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      set linkno [$linkNamespace\::createPluginInstance $linkLabel $deviceId $usage $comment $args ]
   } else {
      set linkno ""
   }
   return $linkno
}

#------------------------------------------------------------
# ::confLink::delete
#    Supprime une utilisation d'une liaison et supprime la
#    liaison si elle n'est plus utilisee par aucun autre peripherique
#
#    Retourne rien
#
#    Exemple :
#    ::confLink::delete "quickremote0" "cam1" "longuepose"
#------------------------------------------------------------
proc ::confLink::delete { linkLabel deviceId usage } {
   set linkNamespace [getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      $linkNamespace\:\:deletePluginInstance $linkLabel $deviceId $usage
   }
}

#------------------------------------------------------------
# ::confLink::selectNotebook
#    Selectionne un onglet
#------------------------------------------------------------
proc ::confLink::selectNotebook { { linkNamespace "" } } {
   variable private

   if { $linkNamespace != "" } {
      set frm [ $private(frm).usr.onglet getframe $linkNamespace ]
      $private(frm).usr.onglet raise $linkNamespace
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#----------------------------------------------------------------------------
# ::confLink::onRaiseNotebook
#    Affiche en gras le nom de l'onglet
#----------------------------------------------------------------------------
proc ::confLink::onRaiseNotebook { linkName } {
   variable private

   set font [$private(frm).usr.onglet.c itemcget "$linkName:text" -font]
   lappend font "bold"
   #--- remarque : il faut attendre que l'onglet soit redessine avant de changer la police
   after 200 $private(frm).usr.onglet.c itemconfigure "$linkName:text" -font [list $font]
}

#------------------------------------------------------------
# ::confLink::configurePlugin
#    Configure le plugin dont le label est dans private(linkLabel)
#------------------------------------------------------------
proc ::confLink::configurePlugin { } {
   variable private

   if { $private(linkLabel) == "" } {
      #--- pas de plugin selectionne par defaut
      return
   }

   #--- je configure le plugin
   [getLinkNamespace $private(linkLabel)]\::configurePlugin
}

#------------------------------------------------------------
# ::confLink::stopPlugin
#    Arrete un link, si le nom d'un link est donne en parametre
#    Arrete tous les links, si aucun link est donne en parametre
# return rien
#------------------------------------------------------------
proc ::confLink::stopPlugin { { linkLabel "" } } {
   if { $linkLabel != "" } {
      [getLinkNamespace $linkLabel]\:\:stopPlugin
   } else {
      #--- j'arrete tous les links
      ##### A FAIRE
   }
}

#------------------------------------------------------------
# ::confLink::findPlugin
#    Recherche les plugins de type "link"
#
#    Conditions :
#      - le plugin doit avoir une procedure getPluginType qui retourne "link"
#      - le plugin doit avoir une procedure getPluginTitle
#      - etc.
#
#    Si le plugin remplit les conditions :
#      Son label est ajoute dans la liste pluginTitleList, et son namespace est ajoute dans namespaceList
#      Sinon le fichier tcl est ignore car ce n'est pas un plugin du type souhaite
#
# return 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confLink::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers link/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" link * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "link" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(conflink,liaison) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading link $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confLink::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphabétique des libelles
   set pluginList ""
   for { set i 0} {$i< [llength $private(pluginLabelList)] } {incr i } {
      lappend pluginList [list [lindex $private(pluginLabelList) $i] [lindex $private(pluginNamespaceList) $i] ]
   }
   set pluginList [lsort -dictionary -index 0 $pluginList]
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   foreach plugin $pluginList {
      lappend private(pluginLabelList)     [lindex $plugin 0]
      lappend private(pluginNamespaceList) [lindex $plugin 1]
   }

   ::console::affiche_prompt "\n"

   if { [llength $private(pluginNamespaceList)] < 1 } {
      #--- aucun plugin correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#------------------------------------------------------------
# ::confLink::getLinkLabels
#    Retourne les libelles des link disponibles correspondant aux
#    namespaces fourni en parametre
#
#    Retourne une liste vide si namespace n'existe pas
#
#    Exemple :
#    getLinkLabels { quickremote parallelport }
#      { "quickremote0" "quickremote1" "LPT1:" "LPT2:" }
#------------------------------------------------------------
proc ::confLink::getLinkLabels { namespaces } {
   variable private

   set labels [list]

   foreach namespace $namespaces {
      #--- je verifie que le namespace existe
      if { [lsearch -exact $private(pluginNamespaceList) $namespace] != -1 } {
         foreach linkLabel [$namespace\:\:getLinkLabels] {
            lappend labels $linkLabel
         }
      }
   }
   return $labels
}

#------------------------------------------------------------
# ::confLink::getNamespaceLabel
#    Retourne le libelle du namespace
#
#    Retourne une chaine vide si namespace n'existe pas
#
#    Exemple :
#    getNamespaceLabel "parallelport"
#      { "Port parallèle" }
#------------------------------------------------------------
proc ::confLink::getNamespaceLabel { namespace } {
   variable private

   #--- je verifie que le namespace existe
   if { [lsearch -exact $private(pluginNamespaceList) $namespace] != -1 } {
      return [$namespace\:\:getPluginTitle]
   } else {
      #--- je retourne une chaine vide
      return ""
   }
}

#------------------------------------------------------------
# ::confLink::getLinkNamespace
#    Retourne le namespace du link
#
#    Retourne une chaine vide si le link n'existe pas
#
#    Exemple :
#    getLinkNamespace "LPT1:"
#      parallelport
#------------------------------------------------------------
proc ::confLink::getLinkNamespace { linkLabel } {
   variable private

   foreach namespace $private(pluginNamespaceList) {
      #--- je verifie si on peut recuperer l'index
      if { [$namespace\::getLinkIndex $linkLabel] != "" } {
         return $namespace
      }
   }
   #--- je retourne une chaine vide
   return ""
}

#------------------------------------------------------------
# ::confLink::getLinkNo
#    Retourne le numero de la liaison
#
#    Retourne une chaine vide si la liaison est fermee
#
#    Exemple :
#    getLinkNo "quickremote0"
#      1
#------------------------------------------------------------
proc ::confLink::getLinkNo { linkLabel } {
   variable private

   #--- je recupere les linkNo ouverts avec une librairie dynamique
   ##set linkNoList [link::list]
   #--- je recherche les commandes de la forme link£linkno
   set linkList [info command {link*[0-9]} ]

   set linkNamespace [::confLink::getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      set linkIndex [$linkNamespace\::getLinkIndex $linkLabel]
      #--- je recherche la liaison deja ouverte qui a le meme namespace et le meme index
      foreach link $linkList {
         if {    "[$link drivername]" == $linkNamespace
              && "[$link index]" == $linkIndex } {
            return [scan $link "link%d" ]
         }
      }
   }
   #--- je retourne une chaine vide si la liaison n'a pas de numero
   return ""
}

#------------------------------------------------------------
# getPluginProperty
# Retourne la valeur d'une propriete d'une liaison
#
# Parametres :
#    linkLabel    : nom du link (exemple: LPT1 ou QUICKREMOTE1 )
#    propertyName : Propriete
#
#------------------------------------------------------------
proc ::confLink::getPluginProperty { linkLabel propertyName } {
   variable private

   #--- je recherche la valeur par defaut de la propriete
   #--- si la valeur par defaut de la propriete n'existe pas , je retourne une chaine vide
   switch $propertyName {
      bitList          { set result [ list "" ] }
      default          { set result "" }
   }

   set linkNamespace [::confLink::getLinkNamespace $linkLabel]

   #--- si une camera est selectionnee, je recherche la valeur propre a la camera
   if { $linkNamespace != "" } {
      set result [ ::$linkNamespace\::getPluginProperty $propertyName ]
   }
   return $result
}

#------------------------------------------------------------
# ::confLink::run
#    Affiche la fenetre de choix et de configuration
#
#    Parametres :
#      variableLinkLabel : nom de la variable qui contient le link pre-selectionne
#      authorizedNamespaces : namespaces autorises (optionel)
#      configurationTitle : titre de la fenetre de configuration (optionel)
#------------------------------------------------------------
proc ::confLink::run { { variableLinkLabel "" } { authorizedNamespaces "" } { configurationTitle "" } } {
   variable private
   global conf

   if { $variableLinkLabel == "" } {
      set private(linkLabel)         ""
      set private(variableLinkLabel) ""
   } else {
      set private(linkLabel)         [set $variableLinkLabel]
      set private(variableLinkLabel) $variableLinkLabel
   }

   if { $authorizedNamespaces == "" } {
      set authorizedPresentNamespaces $private(pluginNamespaceList)
   } else {
      #--- je liste les packages qui sont presents parmi ceux qui sont autorises
      set authorizedPresentNamespaces [list ]
      foreach name $authorizedNamespaces {
          if { [lsearch $private(pluginNamespaceList) $name ] != -1 } {
            lappend authorizedPresentNamespaces $name
          }
      }
   }

   #--- je memorise la liste des onglets qui vont etre affiches
   set private(authorizedPresentNamespaces) $authorizedPresentNamespaces

   if { [createDialog $authorizedPresentNamespaces $configurationTitle ]==0 } {
      set linkNamespace [getLinkNamespace $private(linkLabel) ]
      if { $linkNamespace != "" } {
         #--- je selectionne l'onglet correspondant au linkNamespace
         selectNotebook $linkNamespace
         #--- je selectionne le link dans l'onglet
         $linkNamespace\::selectConfigLink $private(linkLabel)
      } else {
         #--- si  linkNamespace demande n'existe pas je selectionne le premier onglet
         selectNotebook [ lindex $authorizedPresentNamespaces 0 ]
      }
      #--- j'attends la fermeture de la fenetre
      tkwait window $private(frm)
      #--- je retourne le link choisi
      return $private(linkLabel)
   }
}


#--- Connexion au demarrage du plugin selectionne par defaut
::confLink::init

