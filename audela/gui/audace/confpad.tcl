#
# Fichier : confpad.tcl
# Description : Affiche la fenetre de configuration des drivers du type 'pad'
# Auteur : Michel PUJOL
# Mise a jour $Id: confpad.tcl,v 1.3 2006-06-20 17:26:47 robertdelmas Exp $
#

namespace eval ::confPad {
   
   #--- variables locales de ce namespace
   array set private {
      namespace      "confPad"
      frm            ""              
      driverType     "pad"               
      driverPattern  ""   
      namespacelist  ""     
      driverlist     ""
   }

   #------------------------------------------------------------
   # init  ( est lance automatiquement au chargement de ce fichier tcl)
   # initialise les variable conf(..) et caption(..) 
   # demarrer le driver selectionne par defaut
   #------------------------------------------------------------
   proc init { } {
      variable private
      global audace   
      global conf

      #---
      set private(driverPattern) [ file join audace plugin pad * pkgIndex.tcl ]
      set private(frm)           "$audace(base).confPad"
      #--- cree les variables dans conf(..) si elles n'existent pas
      if { ! [ info exists conf(confPad) ] }          { set conf(confPad)       "" }
      if { ! [ info exists conf(confPad,start) ] }    { set conf(confPad,start) "0" }
      if { ! [ info exists conf(confPad,position) ] } { set conf(confPad,position) "+155+100" }

      #--- charge le fichier caption
      uplevel #0  "source \"[ file join $audace(rep_caption) confpad.cap ]\"" 

      findDriver

      #--- configure le driver selectionne par defaut
      #if { $conf(confPad,start) == "1" } {  
      #   configureDriver
      #}

   }
    
   #------------------------------------------------------------
   #  getLabel
   #     retourne le titre de la fenetre
   #  
   #  return "Titre de la fenetre de choix (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(confpad,config)"
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
         select $conf(confPad)
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
      global conf

      $private(frm).cmd.ok configure -state disabled
      $private(frm).cmd.appliquer configure -relief groove -state disabled
      $private(frm).cmd.fermer configure -state disabled

      #--- j'arrete la raquette precedente
      stopDriver

      #--- je recupere le namespace correspondant au label  
      set label "[Rnotebook:currentName $private(frm).usr.book ]"
      set index [lsearch -exact $private(driverlist) $label ] 
      if { $index != -1 } {
         set conf(confPad) [lindex $private(namespacelist) $index]
      } else {
         set conf(confPad) ""
      }

      #--- je demande a chaque driver de sauver sa config dans le tableau conf(..)
      foreach name $private(namespacelist) {
         set drivername [ $name\:\:widgetToConf ]    
      }

      #--- je mets a jour le nom de la raquette
      getLabelPad

      #--- je demarre le driver selectionne
      configureDriver    

      $private(frm).cmd.ok configure -state normal
      $private(frm).cmd.appliquer configure -relief raised -state normal
      $private(frm).cmd.fermer configure -state normal
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
      set private(conf_confPad) [Rnotebook:currentName $private(frm).usr.book ] 
      #--- je recupere le namespace correspondant au label  
      set label "[Rnotebook:currentName $private(frm).usr.book ]"
      set index [lsearch -exact $private(driverlist) $label ] 
      if { $index != -1 } {
         set private(conf_confPad) [ lindex $private(namespacelist) $index ]
      } else {
         set private(conf_confPad) ""
      }
      #--- j'affiche la documentation
      set driver_doc [ $private(conf_confPad)\:\:getHelp ]
      ::audace::showHelpPlugin pad $private(conf_confPad) "$driver_doc"

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

      ::confPad::recup_position
      $private(frm).cmd.ok configure -state disabled
      $private(frm).cmd.appliquer configure -state disabled
      $private(frm).cmd.fermer configure -relief groove -state disabled
      destroy $private(frm)
   }

   #------------------------------------------------------------
   # confPad::recup_position
   # Permet de recuperer et de sauvegarder la position de la 
   # fenetre de configuration de la raquette
   #------------------------------------------------------------
   proc recup_position { } {
      variable private
      global conf

      set private(confPad,geometry) [ wm geometry $private(frm) ]
      set deb [ expr 1 + [ string first + $private(confPad,geometry) ] ]
      set fin [ string length $private(confPad,geometry) ]
      set private(confPad,position) "+[ string range $private(confPad,geometry) $deb $fin ]"
      #---
      set conf(confPad,position) $private(confPad,position)
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
      set private(confPad,position) $conf(confPad,position)

      #---
      if { [ info exists private(confPad,geometry) ] } {
         set deb [ expr 1 + [ string first + $private(confPad,geometry) ] ]
         set fin [ string length $private(confPad,geometry) ]
         set private(confPad,position) "+[ string range $private(confPad,geometry) $deb $fin ]"
      }

      toplevel $private(frm)
      if { $::tcl_platform(os) == "Linux" } {
         wm geometry $private(frm) 550x200$private(confPad,position)
         wm minsize $private(frm) 550 200
      } else {
         wm geometry $private(frm) 440x200$private(confPad,position)
         wm minsize $private(frm) 440 200
      }
      wm resizable $private(frm) 0 0
      wm deiconify $private(frm)
      wm title $private(frm) "$caption(confpad,config)"
      wm protocol $private(frm) WM_DELETE_WINDOW "::confPad::fermer"

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

      #--- frame bouton ok, appliquer, fermer
      frame $private(frm).cmd -borderwidth 1 -relief raised
      button $private(frm).cmd.ok -text "$caption(confpad,ok)" -relief raised -state normal -width 7 \
         -command " ::confPad::ok "
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }
      button $private(frm).cmd.appliquer -text "$caption(confpad,appliquer)" -relief raised -state normal -width 8 \
         -command " ::confPad::appliquer "
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
      button $private(frm).cmd.fermer -text "$caption(confpad,fermer)" -relief raised -state normal -width 7 \
         -command " ::confPad::fermer "
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
      button $private(frm).cmd.aide -text "$caption(confpad,aide)" -relief raised -state normal -width 8 \
         -command " ::confPad::afficheAide "
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
   # configure le driver dont le label est dans $conf(confPad)
   #------------------------------------------------------------
   proc configureDriver {  } {
      variable private
      global conf

      if { $conf(confPad) == "" } {
         #--- pas de driver selectionne par defaut
         return
      }
            
      #--- je charge les drivers 
      if { [llength $private(namespacelist)] <1 } {
         findDriver   
      }

      #--- je configure le driver 
      catch { $conf(confPad)\:\:stopDriver }
      #--- je configure le driver 
      catch { $conf(confPad)\:\:configureDriver }

   }

   #------------------------------------------------------------
   #  stopDriver
   #     arrete le driver selectionne 
   #  
   #  return rien
   #------------------------------------------------------------
   proc stopDriver {  } {
      global conf

      if { "$conf(confPad)" != "" } {
         catch { $conf(confPad)\:\:stopDriver }
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
   # sinon le fichier tcl est ignore car ce n'est pas un driver 
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
            set padname [ file tail [ file dirname "$fichier" ] ]
            package require $padname
            if { [$padname\:\:getDriverType] == $private(driverType) } {
               set driverlabel "[$padname\:\:getLabel]" 
               #--- si c'est un driver valide, je l'ajoute dans la liste
               lappend private(namespacelist) $padname
               lappend private(driverlist) $driverlabel
               $audace(console)::affiche_prompt "#$caption(confpad,raquette) $driverlabel v[package present $padname]\n"                 
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

   proc getLabelPad { } {
      global audace conf

      set erreur [catch { set nom_raquette [$conf(confPad)::getLabel] } msg ]
      
      if { $erreur == "1" } {
         set audace(nom_raquette) ""
      } else {
         set audace(nom_raquette) "$nom_raquette"
      }         
  }

}

#--- connexion au demarrage du driver selectionne par defaut
::confPad::init

