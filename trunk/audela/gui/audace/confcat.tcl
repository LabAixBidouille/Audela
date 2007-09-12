#
# Fichier : confcat.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'chart'
# Auteur : Michel PUJOL
# Mise a jour $Id: confcat.tcl,v 1.13 2007-09-12 17:18:54 robertdelmas Exp $
#

namespace eval ::confCat {

   #------------------------------------------------------------
   # init (est lance automatiquement au chargement de ce fichier tcl)
   # initialise les variable conf(..) et caption(..)
   # demarrer le driver selectionne par defaut
   #------------------------------------------------------------
   proc init { } {
      variable private
      global audace conf

      #--- charge le fichier caption
      source [ file join "$audace(rep_caption)" confcat.cap ]

      #--- cree les variables dans conf(..) si elles n'existent pas
      if { ! [ info exists conf(confCat) ] }          { set conf(confCat)          "" }
      if { ! [ info exists conf(confCat,start) ] }    { set conf(confCat,start)    "0" }
      if { ! [ info exists conf(confCat,geometry) ] } { set conf(confCat,geometry) "490x330+130+60" }

      #--- Initialise les variables locales
      set private(pluginList)      ""
      set private(pluginTitleList) ""
      set private(frm)             "$audace(base).confcat"

      #--- j'ajoute le repertoire pouvant contenir des plugins
      lappend ::auto_path [file join "$::audace(rep_plugin)" chart]
      findPlugin

      #--- configure le driver selectionne par defaut
      #if { $conf(confCat,start) == "1" } {
      #   configureDriver
      #}
   }

   #------------------------------------------------------------
   # getLabel
   # retourne le titre de la fenetre
   #
   # return "Titre de la fenetre (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(confcat,config)"
   }

   #------------------------------------------------------------
   # run
   # Affiche la fenetre de choix et de configuration
   #------------------------------------------------------------
   proc run { } {
      variable private
      global conf

      if { [createDialog ] == 0 } {
         select $conf(confCat)
         catch { tkwait visibility $private(frm) }
      }
   }

   #------------------------------------------------------------
   # ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
   # la configuration, et fermer la fenetre de reglage
   #------------------------------------------------------------
   proc ok { } {
      variable private

      $private(frm).cmd.ok configure -relief groove -state disabled
      $private(frm).cmd.appliquer configure -state disabled
      $private(frm).cmd.fermer configure -state disabled
      $private(frm).cmd.aide configure -state disabled
      appliquer
      fermer
   }

   #------------------------------------------------------------
   # appliquer
   # Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
   # memoriser et appliquer la configuration
   #------------------------------------------------------------
   proc appliquer { } {
      variable private
      global conf

      $private(frm).cmd.ok configure -state disabled
      $private(frm).cmd.appliquer configure -relief groove -state disabled
      $private(frm).cmd.fermer configure -state disabled
      $private(frm).cmd.aide configure -state disabled

      #--- j'arrete le driver precedent
      if { "$conf(confCat)" != "" } {
         #--- je detruis le plugin danc catch, au cas ou il aurait ete supprime
         #--- depuis sa derniere selections
         catch {
            $conf(confCat)::deletePluginInstance
         }
      }

      #--- je recupere le label de l'onglet selectionne
      set conf(confCat) [Rnotebook:currentName $private(frm).usr.book ]
      #--- je recupere le namespace correspondant au label
      set label "[Rnotebook:currentName $private(frm).usr.book ]"
      set index [lsearch -exact $private(pluginTitleList) $label ]
      if { $index != -1 } {
         set conf(confCat) [lindex $private(pluginList) $index]
      } else {
         set conf(confCat) ""
      }

      #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
      foreach name $private(pluginList) {
         $name\::widgetToConf
      }

      #--- je demarre le plugin selectionne
      if { $conf(confCat) != "" } {
         $conf(confCat)::createPluginInstance
      }

      $private(frm).cmd.ok configure -state normal
      $private(frm).cmd.appliquer configure -relief raised -state normal
      $private(frm).cmd.fermer configure -state normal
      $private(frm).cmd.aide configure -state normal
   }

   #------------------------------------------------------------
   # afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #------------------------------------------------------------
   proc afficheAide { } {
      variable private

      #--- je recupere l'index de l'onglet selectionne
      set index [Rnotebook:currentIndex $private(frm).usr.book ]
      if { $index != -1 } {
         set selectedPluginName [lindex $private(pluginList) [expr $index -1]]
         #--- j'affiche la documentation
         set pluginHelp [ $selectedPluginName\::getPluginHelp ]
         set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
         ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
      }
   }

   #------------------------------------------------------------
   # fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #------------------------------------------------------------
   proc fermer { } {
      variable private

      ::confCat::recupPosDim
      destroy $private(frm)
   }

   #------------------------------------------------------------
   # recupPosDim
   # Permet de recuperer et de sauvegarder la position et la
   # dimension de la fenetre de configuration de la carte
   #------------------------------------------------------------
   proc recupPosDim { } {
      variable private
      global conf

      set private(confCat,geometry) [ wm geometry $private(frm) ]
      set conf(confCat,geometry) $private(confCat,geometry)
   }

   #------------------------------------------------------------
   # createDialog
   # Affiche la fenetre a onglet
   #
   # retrun 0 = OK, 1 = error (no driver found)
   #------------------------------------------------------------
   proc createDialog { } {
      variable private
      global caption conf

      #--- Je verifie qu'il y a des cartes
      if { [ llength $private(pluginList) ] < 1 } {
         tk_messageBox -title "$caption(confcat,config)" -message "$caption(confcat,pas_carte)" -icon error
         return 1
      }

      #---
      if { [ winfo exists $private(frm) ] } {
         wm withdraw $private(frm)
         wm deiconify $private(frm)
         focus $private(frm)
         return 0
      }

      #---
      set private(confCat,geometry) $conf(confCat,geometry)

      toplevel $private(frm)
      wm geometry $private(frm) $private(confCat,geometry)
      wm minsize $private(frm) 490 330
      wm resizable $private(frm) 1 1
      wm deiconify $private(frm)
      wm title $private(frm) "$caption(confcat,config)"
      wm protocol $private(frm) WM_DELETE_WINDOW "::confCat::fermer"

      #--- Frame de la fenetre de configuration
      frame $private(frm).usr -borderwidth 0 -relief raised

         #--- Creation de la fenetre a onglets
         set mainFrame $private(frm).usr.book

            #--- J'affiche les onglets dans la fenetre
            Rnotebook:create $mainFrame -tabs "$private(pluginTitleList)" -borderwidth 1

            #--- Je demande a chaque plugin d'afficher sa page de config
            set indexOnglet 1
            foreach name $private(pluginList) {
               set drivername [ $name\:\:fillConfigPage [ Rnotebook:frame $mainFrame $indexOnglet ] ]
               incr indexOnglet
            }

         pack $mainFrame -fill both -expand 1

      pack $private(frm).usr -side top -fill both -expand 1

      #--- Frame du checkbutton creer au demarrage
      frame $private(frm).start -borderwidth 1 -relief raised

         checkbutton $private(frm).start.chk -text "$caption(confcat,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(confCat,start)
         pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x

      pack $private(frm).start -side top -fill x

      #--- Frame des boutons OK, Appliquer, Aide et Fermer
      frame $private(frm).cmd -borderwidth 1 -relief raised

         button $private(frm).cmd.ok -text "$caption(confcat,ok)" -relief raised -state normal -width 7 \
            -command "::confCat::ok"
         if { $conf(ok+appliquer)=="1" } {
            pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $private(frm).cmd.appliquer -text "$caption(confcat,appliquer)" -relief raised -state normal -width 8 \
            -command "::confCat::appliquer"
         pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $private(frm).cmd.fermer -text "$caption(confcat,fermer)" -relief raised -state normal -width 7 \
            -command "::confCat::fermer"
         pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $private(frm).cmd.aide -text "$caption(confcat,aide)" -relief raised -state normal -width 8 \
            -command "::confCat::afficheAide"
         pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $private(frm).cmd -side top -fill x

      #---
      focus $private(frm)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $private(frm) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(frm)

      return 0
   }

   #------------------------------------------------------------
   # select [label]
   # Selectionne un onglet en passant le label de l'onglet decrit dans la fenetre de configuration
   # Si le label est omis ou inconnu, le premier onglet est selectionne
   #------------------------------------------------------------
   proc select { { name "" } } {
      variable private

      #--- je recupere le label correspondant au namespace
      set index [lsearch -exact $private(pluginList) "$name" ]
      if { $index != -1 } {
         Rnotebook:select $private(frm).usr.book [lindex  $private(pluginTitleList)  $index]
      }
   }

   #------------------------------------------------------------
   # configureDriver
   # configure le driver selectionne
   #------------------------------------------------------------
   proc configureDriver { } {

   }

   #------------------------------------------------------------
   # createUrlLabel
   # cree un widget "label" avec une URL du site WEB
   #------------------------------------------------------------
   proc createUrlLabel { tkparent title url } {
      global audace color

      label  $tkparent.labURL -text "$title" -font $audace(font,url) -fg $color(blue)
      bind   $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
      bind   $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
      bind   $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
      return $tkparent.labURL
   }

   #------------------------------------------------------------
   # stopDriver
   # arrete le driver selectionne
   #
   #  return rien
   #------------------------------------------------------------
   proc stopDriver { } {
      global conf

      if { "$conf(confCat)" != "" } {
         catch {
            $conf(confCat)::deletePluginInstance
         }
      }
   }

   #------------------------------------------------------------
   # findPlugin
   # recherche les fichiers .tcl presents dans plugin/chart
   #
   # si le driver remplit les conditions
   #    son label est ajoute dans la liste namespaceList, et son namespace est ajoute dans namespacelist
   # sinon le fichier tcl est ignore car ce n'est pas un driver
   #
   # retrun 0 = OK, 1 = error (no driver found)
   #------------------------------------------------------------
   proc findPlugin { } {
      variable private
      global audace caption

      #--- j'initialise les listes vides
      set private(pluginList)      ""
      set private(pluginTitleList) ""

      #--- je recherche les fichiers link/*/pkgIndex.tcl
      set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" chart * pkgIndex.tcl ]
      #--- je recherche les drivers repondant au filtre driverPattern
      foreach pkgIndexFileName $filelist {
         set catchResult [catch {
            #--- je recupere le nom du package
            if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
               if { $pluginInfo(type)== "chart"} {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginTitleList) $pluginlabel
                  ::console::affiche_prompt "#$caption(confcat,carte) $pluginlabel v$pluginInfo(version)\n"
               }
            } else {
               ::console::affiche_erreur "Error loading $pkgIndexFileName \n$::errorInfo\n\n"
            }
         } catchMessage]
         #--- j'affiche le message d'erreur et je continu la recherche des plugins
         if { $catchResult !=0 } {
           console::affiche_erreur "::confCat::findPlugin $::errorInfo\n"
        }
      }
      ::console::affiche_prompt "\n"

      if { [llength $private(pluginList)] <1 } {
         #--- aucun driver correct
         return 1
      } else {
         #--- tout est ok
         return 0
      }
   }

}

#--- connexion au demarrage du driver selectionne par defaut
::confCat::init

