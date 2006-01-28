#
# Fichier : conflink.tcl
# Description : Gere des objets 'liaison' pour la communication
# Auteurs : Robert DELMAS et Michel PUJOL
# Date de mise a jour : 28 janvier 2006
#

namespace eval ::confLink {

   #--- variables locales de ce namespace
   array set private {
      namespace      "confLink"
      frm            ""
      driverType     "link"
      driverPattern  ""
      namespacelist  ""
      driverlist     ""
   }

   #------------------------------------------------------------
   # init ( est lance automatiquement au chargement de ce fichier tcl)
   # initialise les variable conf(..) et caption(..)
   # demarrer le driver selectionne par defaut
   #------------------------------------------------------------
   proc init { } {
      variable private
      global audace
      global conf

      #---
      set private(driverPattern) [ file join audace plugin link * pkgIndex.tcl ]
      set private(frm)           "$audace(base).conflink"
      #--- cree les variables dans conf(..) si elles n'existent pas
      if { ! [ info exists conf(confLink) ] }          { set conf(confLink)          "" }
      if { ! [ info exists conf(confLink,start) ] }    { set conf(confLink,start)    "0" }
      if { ! [ info exists conf(confLink,position) ] } { set conf(confLink,position) "+155+100" }

      #--- charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_caption) conflink.cap ]\""

      findDriver

      #--- configure le driver selectionne par defaut
      #if { $conf(confLink,start) == "1" } {
      #   configureDriver
      #}
   }

   #------------------------------------------------------------
   # getLabel
   #    retourne le titre de la fenetre
   #
   # return "Titre de la fenetre de choix (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(conflink,config)"
   }

   #------------------------------------------------------------
   # run
   # Affiche la fenetre de choix et de configuration 
   # 
   #------------------------------------------------------------
   proc run { } {
      variable private
      global conf

      if { [createDialog ]==0 } {
         select $conf(confLink)
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
      global audace
      global conf

      $private(frm).cmd.ok configure -state disabled
      $private(frm).cmd.appliquer configure -relief groove -state disabled
      $private(frm).cmd.fermer configure -state disabled

      #--- j'arrete la liaison precedente
      stopDriver

      #--- je recupere le namespace correspondant au label
      set label "[Rnotebook:currentName $private(frm).usr.book ]"
      set index [lsearch -exact $private(driverlist) $label ] 
      if { $index != -1 } {
         set conf(confLink) [lindex $private(namespacelist) $index]
      } else {
         set conf(confLink) ""
      }

      #--- je demande a chaque driver de sauver sa config dans le tableau conf(..)
      foreach name $private(namespacelist) {
         set drivername [ $name\:\:widgetToConf ]
      }

      #--- Affichage d'un message d'alerte si necessaire
      ::confLink::Connect_Liaison

      #--- je demarre le driver selectionne
      configureDriver

      $private(frm).cmd.ok configure -state normal
      $private(frm).cmd.appliquer configure -relief raised -state normal
      $private(frm).cmd.fermer configure -state normal

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectLiaison ] {
         destroy $audace(base).connectLiaison
      }
   }

   #------------------------------------------------------------
   # afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #------------------------------------------------------------
   proc afficheAide { } {
      variable private
      global conf
      global help

      $private(frm).cmd.ok configure -state disabled
      $private(frm).cmd.appliquer configure -state disabled
      $private(frm).cmd.fermer configure -state disabled
      $private(frm).cmd.aide configure -relief groove -state disabled

      #--- je recupere le label de l'onglet selectionne
      set private(conf_confLink) [Rnotebook:currentName $private(frm).usr.book ]
      #--- je recupere le namespace correspondant au label  
      set label "[Rnotebook:currentName $private(frm).usr.book ]"
      set index [lsearch -exact $private(driverlist) $label ]
      if { $index != -1 } {
         set private(conf_confLink) [lindex $private(namespacelist) $index]
      } else {
         set private(conf_confLink) ""
      }
      #--- j'affiche la documentation
      set driver_doc [ $private(conf_confLink)\:\:getHelp ]
      ::audace::showHelpPlugin link $private(conf_confLink) "$driver_doc"

      $private(frm).cmd.ok configure -state normal
      $private(frm).cmd.appliquer configure -state normal
      $private(frm).cmd.fermer configure -state normal
      $private(frm).cmd.aide configure -relief raised -state normal
   }

   #------------------------------------------------------------
   # fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #------------------------------------------------------------
   proc fermer { } {
      variable private

      ::confLink::recup_position
      $private(frm).cmd.ok configure -state disabled
      $private(frm).cmd.appliquer configure -state disabled
      $private(frm).cmd.fermer configure -relief groove -state disabled
      destroy $private(frm)
   }

   #------------------------------------------------------------
   # confLink::recup_position
   # Permet de recuperer et de sauvegarder la position de la
   # fenetre de configuration de la liaison
   #------------------------------------------------------------
   proc recup_position { } {
      variable private
      global conf

      set private(confLink,geometry) [ wm geometry $private(frm) ]
      set deb [ expr 1 + [ string first + $private(confLink,geometry) ] ]
      set fin [ string length $private(confLink,geometry) ]
      set private(confLink,position) "+[ string range $private(confLink,geometry) $deb $fin ]"
      #---
      set conf(confLink,position) $private(confLink,position)
   }

   #------------------------------------------------------------
   # createDialog
   # Affiche la fenetre a onglet
   # retrun 0 = OK , 1 = error (no driver found)
   #------------------------------------------------------------
   proc createDialog { } {
      variable private
      global audace
      global conf
      global caption

      if { [winfo exists $private(frm)] } {
         wm withdraw $private(frm)
         wm deiconify $private(frm)
         focus $private(frm)
         return 0
      }

      #--- je mets a jour la liste des drivers
      if { [findDriver] == 1 } {
         return 1
      }

      #---
      set private(confLink,position) $conf(confLink,position)

      #---
      if { [ info exists private(confLink,geometry) ] } {
         set deb [ expr 1 + [ string first + $private(confLink,geometry) ] ]
         set fin [ string length $private(confLink,geometry) ]
         set private(confLink,position) "+[ string range $private(confLink,geometry) $deb $fin ]"
      }

      toplevel $private(frm)
      if { $::tcl_platform(os) == "Linux" } {
         wm geometry $private(frm) 620x370$private(confLink,position)
         wm minsize $private(frm) 620 370
      } else {
         wm geometry $private(frm) 580x370$private(confLink,position)
         wm minsize $private(frm) 580 370
      }
      wm resizable $private(frm) 1 0
      wm deiconify $private(frm)
      wm title $private(frm) "$caption(conflink,config)"
      wm protocol $private(frm) WM_DELETE_WINDOW "::confLink::fermer"

      frame $private(frm).usr -borderwidth 0 -relief raised

      #--- creation de la fenetre a onglets
      set mainFrame $private(frm).usr.book

      #--- j'affiche les onglets dans la fenetre
      Rnotebook:create $mainFrame -tabs "$private(driverlist)" -borderwidth 1

      #--- je demande a chaque driver d'afficher sa page de config
      set indexOnglet 1
      foreach name $private(namespacelist) {
         set drivername [ $name\:\:fillConfigPage [ Rnotebook:frame $mainFrame $indexOnglet ] ]
         incr indexOnglet
      }

      pack $mainFrame -fill both -expand 1
      pack $private(frm).usr -side top -fill both -expand 1

      #--- frame checkbutton creer au demarrage
      frame $private(frm).start -borderwidth 1 -relief raised
         checkbutton $private(frm).start.chk -text "$caption(conflink,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(confLink,start)
         pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x
      pack $private(frm).start -side top -fill x

      #--- frame bouton ok, appliquer, fermer
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
      pack $private(frm).cmd -side top -fill x    

      #---
      focus $private(frm)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $private(frm) <Key-F1> { $audace(console)::GiveFocus }

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
      set index [ lsearch -exact $private(namespacelist) "$name" ]
      if { $index != -1 } {
         Rnotebook:select $private(frm).usr.book [ lindex $private(driverlist) $index ]
      }
   }

   #------------------------------------------------------------
   # configureDriver
   # configure le driver dont le label est dans $conf(confLink)
   #------------------------------------------------------------
   proc configureDriver { } {
      variable private
      global conf

      if { $conf(confLink) == "" } {
         #--- pas de driver selectionne par defaut
         return
      }

      #--- je charge les drivers 
      if { [llength $private(namespacelist)] <1 } {
         findDriver   
      }

      #--- j'arrete le driver 
      catch { $conf(confLink)\:\:stopDriver }
      #--- je configure le driver 
      catch { $conf(confLink)\:\:configureDriver }
   }

   #------------------------------------------------------------
   # stopDriver
   #    arrete le driver selectionne 
   #
   # return rien
   #------------------------------------------------------------
   proc stopDriver { } {
      global conf

      if { "$conf(confLink)" != "" } {
         catch { $conf(confLink)\:\:stopDriver }
      }
   }

   #------------------------------------------------------------
   # findDriver
   # recherche les fichiers .tcl presents dans driverPattern 
   #
   # conditions : 
   #  - le driver doit retourner un namespace non nul quand on charge son source .tcl
   #  - le driver doit avoir une procedure getDriverType qui retourne une valeur egale à $driverType
   #  - le driver doit avoir une procedure getlabel
   # 
   # si le driver remplit les conditions 
   #    son label est ajouté dans la liste driverlist, et son namespace est ajoute dans namespacelist
   #    sinon le fichier tcl est ignore car ce n'est pas un driver
   #
   # retrun 0 = OK , 1 = error (no driver found)
   #------------------------------------------------------------
   proc findDriver { } {
      variable private 
      global audace
      global caption

      #--- j'initialise les listes vides
      set private(namespacelist)  ""
      set private(driverlist)     ""

      #--- chargement des differentes fenetres de configuration des drivers
      set error [catch { glob -nocomplain $private(driverPattern) } filelist ]
      
      if { "$filelist" == "" } {
         #--- aucun fichier correct
         return 1
      }
      
      #--- je recherche les drivers repondant au filtre driverPattern
      foreach fichier [glob $private(driverPattern)] {
         uplevel #0 "source $fichier"
         catch {
            set linkname [ file tail [ file dirname "$fichier" ] ]
            package require $linkname
            if { [$linkname\:\:getDriverType] == $private(driverType) } {
               set driverlabel "[$linkname\:\:getLabel]" 
               #--- si c'est un driver valide, je l'ajoute dans la liste
               lappend private(namespacelist) $linkname
               lappend private(driverlist) $driverlabel
               $audace(console)::affiche_prompt "#$caption(conflink,liaison) $driverlabel v[package present $linkname]\n"                 
            }
         }
      }
      $audace(console)::affiche_prompt "\n"

      if { [llength $private(namespacelist)] <1 } {
         #--- pas driver correct
         return 1
      } else {
         #--- tout est ok
         return 0
      }
   }

   #------------------------------------------------------------
   # Connect_Liaison
   # Affichage d'un message d'alerte pendant la connexion d'une liaison au demarrage
   #------------------------------------------------------------
   proc Connect_Liaison { } {
      variable private
      global audace
      global caption
      global color

      if [ winfo exists $audace(base).connectLiaison ] {
         destroy $audace(base).connectLiaison
      }

      toplevel $audace(base).connectLiaison
      wm resizable $audace(base).connectLiaison 0 0
      wm title $audace(base).connectLiaison "$caption(conflink,attention)"
      if { [ info exists private(frm) ] } {
         set posx_connectLiaison [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
         set posy_connectLiaison [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
         wm geometry $audace(base).connectLiaison +[ expr $posx_connectLiaison + 50 ]+[ expr $posy_connectLiaison + 100 ]
         wm transient $audace(base).connectLiaison $private(frm)
      } else {
         wm geometry $audace(base).connectLiaison +200+100
         wm transient $audace(base).connectLiaison $audace(base)
      }

      #--- Cree l'affichage du message
      label $audace(base).connectLiaison.labURL_1 -text "$caption(conflink,connexion_texte1)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      uplevel #0 { pack $audace(base).connectLiaison.labURL_1 -padx 10 -pady 2 }
      label $audace(base).connectLiaison.labURL_2 -text "$caption(conflink,connexion_texte2)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      uplevel #0 { pack $audace(base).connectLiaison.labURL_2 -padx 10 -pady 2 }
      update

      #--- La nouvelle fenetre est active
      focus $audace(base).connectLiaison

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).connectLiaison
   }

}

#--- connexion au demarrage du driver selectionne par defaut
::confLink::init

