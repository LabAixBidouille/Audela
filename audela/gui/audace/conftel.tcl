#
# Fichier : conftel.tcl
# Description : Gere des objets 'monture' (ex-objets 'telescope')
# Mise a jour $Id: conftel.tcl,v 1.53 2008-12-22 09:28:01 robertdelmas Exp $
#

namespace eval ::confTel {
}

#------------------------------------------------------------
# init (est lance automatiquement au chargement de ce fichier tcl)
#    Initialise les variables conf(...) et caption(...)
#    Demarre le plugin selectionne par defaut
#------------------------------------------------------------
proc ::confTel::init { } {
   variable private
   global audace conf

   #--- initConf
   if { ! [ info exists conf(raquette) ] }           { set conf(raquette)           "1" }
   if { ! [ info exists conf(telescope) ] }          { set conf(telescope)          "lx200" }
   if { ! [ info exists conf(telescope,start) ] }    { set conf(telescope,start)    "0" }
   if { ! [ info exists conf(telescope,geometry) ] } { set conf(telescope,geometry) "540x500+15+0" }

   #--- Charge le fichier caption
   source [ file join $audace(rep_caption) conftel.cap ]

   #--- Initalise le numero de la monture a nul
   set audace(telNo) "0"

   #--- Initialisation de variables
   set private(geometry)  $conf(telescope,geometry)
   set private(telNo)     "0"
   set private(mountName) ""

   #--- Initalise les listes de montures
   set private(nomRaquette) $conf(confPad)

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" mount]

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confTel"

   #--- je recherche les plugins presents
   findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(telescope)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(telescope) ""
   }
}

#------------------------------------------------------------
# run
#    Cree la fenetre de choix et de configuration des montures
#------------------------------------------------------------
proc ::confTel::run { } {
   variable private
   global conf

   set private(nomRaquette) [::confPad::getCurrentPad]
   createDialog
   selectNotebook $conf(telescope)
}

#------------------------------------------------------------
# ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
#    la configuration, et fermer la fenetre de configuration
#------------------------------------------------------------
proc ::confTel::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# appliquer
#    Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
#    memoriser et appliquer la configuration
#------------------------------------------------------------
proc ::confTel::appliquer { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- J'arrete la monture
   stopPlugin
   #--- Je copie les parametres de la nouvelle monture dans conf()
   widgetToConf
   #--- Je configure la monture
   configureMonture

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
# afficherAide
#    Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confTel::afficherAide { } {
   variable private

   #--- J'affiche la documentation
   set selectedPluginName [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#------------------------------------------------------------
# fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confTel::fermer { } {
   variable private

   ::confTel::recupPosDim
   destroy $private(frm)
}

#------------------------------------------------------------
# recupPosDim
#    Permet de recuperer et de sauvegarder la position de la fenetre de configuration
#------------------------------------------------------------
proc ::confTel::recupPosDim { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set conf(telescope,geometry) $private(geometry)
}

#------------------------------------------------------------
# createDialog
#    Creation de la boite avec les onglets
#------------------------------------------------------------
proc ::confTel::createDialog { } {
   variable private
   global caption conf

   if { [ winfo exists $private(frm) ] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      selectNotebook $conf(telescope)
      focus $private(frm)
      return
   }

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(geometry)
   wm minsize $private(frm) 540 500
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(conftel,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW ::confTel::fermer

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(conftel,ok)" -relief raised -state normal -width 7 \
         -command { ::confTel::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(conftel,appliquer)" -relief raised -state normal -width 8 \
         -command { ::confTel::appliquer }
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(conftel,fermer)" -relief raised -state normal -width 7 \
         -command { ::confTel::fermer }
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(conftel,aide)" -relief raised -state normal -width 7 \
         -command { ::confTel::afficherAide }
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame du bouton Arreter et du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      button $private(frm).start.stop -text "$caption(conftel,arreter)" -width 7 \
         -command { ::confTel::stopPlugin }
      pack $private(frm).start.stop -side left -padx 3 -pady 3 -expand true

      checkbutton $private(frm).start.chk -text "$caption(conftel,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(telescope,start)
      pack $private(frm).start.chk -side left -padx 3 -pady 3 -expand true

   pack $private(frm).start -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $private(pluginNamespaceList) {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title " -raisecmd "::confTel::onRaiseNotebook $namespace" ]
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
}

#------------------------------------------------------------
# createUrlLabel
#    Cree un widget "label" avec une URL du site WEB
#------------------------------------------------------------
proc ::confTel::createUrlLabel { tkparent title url } {
   global color

   label $tkparent.labURL -text "$title" -fg $color(blue)
   if { $url != "" } {
      bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   }
   bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

#------------------------------------------------------------
# createPdfLabel
#    Cree un widget "label" pour un document pdf
#------------------------------------------------------------
proc ::confTel::createPdfLabel { tkparent title pdf } {
   global audace color

   set filename [ file join $audace(rep_plugin) mount audecom french $pdf ]
   label $tkparent.labURL -text "$title" -fg $color(blue)
   if { $pdf != "" } {
      bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Notice_pdf \"$filename\""
   }
   bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return  $tkparent.labURL
}

#------------------------------------------------------------
# connectMonture
#    Affichage d'un message d'alerte pendant la connexion de la monture au demarrage
#------------------------------------------------------------
proc ::confTel::connectMonture { } {
   variable private
   global audace caption color

   if [ winfo exists $audace(base).connectMonture ] {
      destroy $audace(base).connectMonture
   }

   toplevel $audace(base).connectMonture
   wm resizable $audace(base).connectMonture 0 0
   wm title $audace(base).connectMonture "$caption(conftel,attention)"
   if { [ info exists private(frm) ] } {
      if { [ winfo exists $private(frm) ] } {
         set posx_connectMonture [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
         set posy_connectMonture [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
         wm geometry $audace(base).connectMonture +[ expr $posx_connectMonture + 50 ]+[ expr $posy_connectMonture + 100 ]
         wm transient $audace(base).connectMonture $private(frm)
      }
   } else {
      wm geometry $audace(base).connectMonture +200+100
      wm transient $audace(base).connectMonture $audace(base)
   }

   #--- Cree l'affichage du message
   label $audace(base).connectMonture.labURL_1 -text "$caption(conftel,connexion_texte1)" -fg $color(red)
   pack $audace(base).connectMonture.labURL_1 -padx 10 -pady 2
   label $audace(base).connectMonture.labURL_2 -text "$caption(conftel,connexion_texte2)" -fg $color(red)
   pack $audace(base).connectMonture.labURL_2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).connectMonture

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectMonture
}

#------------------------------------------------------------
# selectNotebook
#    Selectionne un onglet
#------------------------------------------------------------
proc ::confTel::selectNotebook { mountName } {
   variable private
   global conf

   #--- je recupere l'item courant
   if { $mountName == "" } {
      set mountName $conf(telescope)
   }

   if { $mountName != "" } {
      set frm [ $private(frm).usr.onglet getframe $mountName ]
      $private(frm).usr.onglet raise $mountName
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#------------------------------------------------------------
# onRaiseNotebook
#    Affiche en gras le nom de l'onglet
#------------------------------------------------------------
proc ::confTel::onRaiseNotebook { mountName } {
   variable private

   set font [$private(frm).usr.onglet.c itemcget "$mountName:text" -font]
   lappend font "bold"
   #--- remarque : il faut attendre que l'onglet soit redessine avant de changer la police
   after 200 $private(frm).usr.onglet.c itemconfigure "$mountName:text" -font [list $font]
}

#------------------------------------------------------------
# startPlugin
#    Ouvre les montures
#------------------------------------------------------------
proc ::confTel::startPlugin { } {
   variable private
   global conf

   if { $conf(telescope,start) == "1" } {
      set private(mountName) $conf(telescope)
      if { $private(mountName) != "" } {
         ::confTel::configureMonture
      }
   }
}

#------------------------------------------------------------
# stopPlugin
#    Ferme la monture ouverte
#------------------------------------------------------------
proc ::confTel::stopPlugin { } {
   variable private
   global audace

   #--- Je ferme la liaison
   if { $private(telNo) != "0" } {
      #--- Je ferme les ressources specifiques de la monture
      ::$private(mountName)::stop
      #--- Raz du numero de monture
      set private(telNo) "0"
      set audace(telNo) $private(telNo)
      #--- Je supprime le label des visus
      foreach visuNo [ ::visu::list ] {
         ::confVisu::setMount $visuNo
      }
      #--- Je supprime l'association avec les cameras
      foreach camItem { A B C } {
         ::confCam::setMount $camItem $audace(telNo)
      }
   }
   set private(mountName) ""
}

#------------------------------------------------------------
# configureMonture
#    Configure la monture en fonction des donnees contenues dans le tableau conf(..)
#------------------------------------------------------------
proc ::confTel::configureMonture { } {
   variable private
   global audace caption conf

   #--- Affichage d'un message d'alerte si necessaire
   ::confTel::connectMonture

   set catchResult [ catch {

      #--- Je configure la monture
      ::$private(mountName)::configureMonture

      #--- Je recupere telNo
      set private(telNo) [ ::$private(mountName)::getTelNo ]

      #--- Mise a jour de la variable audace
      set audace(telNo) $private(telNo)

      #--- J'associe la monture avec les visus
      foreach visuNo [ ::visu::list ] {
         ::confVisu::setMount $visuNo
      }

      #--- J'associe la monture avec les cameras
      foreach camItem { A B C } {
         ::confCam::setMount $camItem $audace(telNo)
      }

      #--- Raffraichissement de la vitesse dans les raquettes et les outils, et de l'affichage des coordonnees
      if { $conf(raquette) == "1" } {
         #--- je cree la nouvelle raquette
         ::confPad::configurePlugin $private(nomRaquette)
      } else {
         ::confPad::stopPlugin
      }

   } errorMessage ]

   #--- Il n'y a pas d'erreur detectee par le catch
   if { $catchResult == "0" } {

      ::telescope::setSpeed "$audace(telescope,speed)"
      ::telescope::afficheCoord

   }

   #--- Il y a des erreurs detectees par le catch
   if { $catchResult != "0" } {

      #--- J'affiche le message d'erreur
      ::console::affiche_erreur "$::errorInfo\n\n"
      tk_messageBox -title "$caption(conftel,attention)" -icon error \
         -message "$errorMessage\n$caption(conftel,cannotcreatecam)\n$caption(conftel,seeconsole)"

      #--- Je desactive le demarrage automatique
      set conf(telescope,start) "0"

      #--- En cas de probleme, monture par defaut
      set private(mountName) ""
      set private(telNo)     "0"

   }

   #--- Effacement du message d'alerte s'il existe
   if [ winfo exists $audace(base).connectMonture ] {
      destroy $audace(base).connectMonture
   }
}

#------------------------------------------------------------
# widgetToConf
#    Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
#------------------------------------------------------------
proc ::confTel::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture
   set mountName          [ $private(frm).usr.onglet raise ]
   set private(mountName) $mountName
   set conf(telescope)    $mountName

   ::$private(mountName)::widgetToConf
}

#------------------------------------------------------------
# getPluginProperty
#    Retourne la valeur d'une propriete de la monture
#
# Parametres :
#    propertyName : Propriete
#------------------------------------------------------------
proc ::confTel::getPluginProperty { propertyName } {
   variable private

   # multiMount              Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
   # name                    Retourne le modele de la monture
   # product                 Retourne le nom du produit
   # hasCoordinates          Retourne la possibilite d'afficher les coordonnees
   # hasGoto                 Retourne la possibilite de faire un Goto
   # hasMatch                Retourne la possibilite de faire un Match
   # hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
   # hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
   # hasCorrectionRefraction Retourne la possibilite de calculer les corrections de refraction
   # hasModel                Retourne la possibilite d'avoir plusieurs modeles pour le meme product
   # hasPark                 Retourne la possibilite de parquer la monture
   # hasUnpark               Retourne la possibilite de de-parquer la monture
   # hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
   # backlash                Retourne la possibilite de faire un rattrapage des jeux

   #--- je recherche la valeur par defaut de la propriete
   #--- si la valeur par defaut de la propriete n'existe pas, je retourne une chaine vide
   switch $propertyName {
      multiMount              { set result 0 }
      name                    { set result "" }
      product                 { set result "" }
      hasCoordinates          { set result 1 }
      hasGoto                 { set result 1 }
      hasMatch                { set result 1 }
      hasManualMotion         { set result 1 }
      hasControlSuivi         { set result 0 }
      hasCorrectionRefraction { set result 0 }
      hasModel                { set result 0 }
      hasPark                 { set result 0 }
      hasUnpark               { set result 0 }
      hasUpdateDate           { set result 0 }
      backlash                { set result 0 }
      default                 { set result 0 }
   }

   #--- si aucune monture n'est selectionnee, je retourne la valeur par defaut
   if { $private(mountName) == "" } {
      return $result
   }

   #--- si une monture est selectionnee, je recherche la valeur propre a la monture
   set result [ ::$private(mountName)::getPluginProperty $propertyName ]
   return $result
}

#------------------------------------------------------------
# isReady
#    Retourne "1" si la monture est demarree, sinon retourne "0"
#------------------------------------------------------------
proc ::confTel::isReady { } {
   variable private

   #--- Je verifie que la monture est prete
   if { $private(mountName) == "" } {
      set result "0"
   } else {
      set result [ ::$private(mountName)::isReady ]
   }
   return $result
}

#------------------------------------------------------------
# findPlugin
#    recherche les plugins de type "mount"
#
# conditions :
#    - le plugin doit avoir une procedure getPluginType qui retourne "mount"
#    - le plugin doit avoir une procedure getPluginTitle
#    - etc.
#
#    si le plugin remplit les conditions :
#    son label est ajoute dans la liste pluginTitleList et son namespace est ajoute dans pluginNamespaceList
#    sinon le fichier tcl est ignore car ce n'est pas un plugin
#
# return 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confTel::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers mount/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" mount * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {

      set catchResult [ catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "mount" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(conftel,mount) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading mount $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage ]

      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         ::console::affiche_erreur "::confTel::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphabetique des libelles
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

#--- Connexion au demarrage de la monture selectionnee par defaut
::confTel::init

