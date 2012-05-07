#
# Fichier : aud_menu_1.tcl
# Description : Script regroupant les fonctionnalites du menu Fichier
# Mise à jour $Id$
#

namespace eval ::audace {

   #
   # ::audace::charger visuNo
   # Charge un fichier dans la visu
   #
   proc charger { visuNo } {
      menustate disabled
      set errnum [ catch { loadima ? $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      menustate normal
   }

   #
   # ::audace::enregistrer visuNo
   # Enregistre un fichier sous son nom d'ouverture
   #
   proc enregistrer { visuNo } {
      menustate disabled
      set errnum [ catch { saveima [::confVisu::getFileName $visuNo] $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      menustate normal
   }

   #
   # ::audace::enregistrer_sous visuNo
   # Enregistre un fichier sous un nom
   #
   proc enregistrer_sous { visuNo } {
      menustate disabled
      set errnum [ catch { saveima ? $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      menustate normal
   }

   #
   # ::audace::newScript
   # Creation d'un nouveau script : Demande en premier le fichier et ouvre l'editeur choisi dans les reglages
   # Il faut avoir choisi un editeur (sous Windows : notepad, etc., sous Linux : kwrite, xemacs, nedit, dtpad, etc.)
   #
   proc newScript { } {
      global caption conf

      menustate disabled
      set result [::newScript::run ""]
      if { [lindex $result 0] == 1 } {
         set filename [lindex $result 1]
         if { [string compare $filename ""] } {
            #--- Creation du fichier
            set fid [open $filename w]
            close $fid
            #--- Ouverture de ce fichier
            set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
            if {[catch $a_effectuer msg]} {
               ::console::affiche_erreur "$caption(audace,pas_ouvrir_fichier) $msg\n"
            }
         }
      }
      menustate normal
   }

   #
   # ::audace::editScript
   # Edition d'un script : Demande en premier le fichier et ouvre l'editeur choisi dans les reglages
   # Il faut avoir choisi un editeur (sous Windows : notepad, etc., sous Linux : kwrite, xemacs, nedit, dtpad, etc.)
   #
   proc editScript { } {
      global audace caption conf confgene

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la fenetre de choix des scripts
      set filename [ ::tkutil::box_load $fenetre $audace(rep_scripts) $audace(bufNo) "2" ]
      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # ::console::affiche_erreur "$caption(audace,console_rate)\n"
            set confgene(EditScript,error_script) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
            ::console::affiche_saut "\n"
            ::console::disp $filename
            ::console::affiche_saut "\n"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            ::console::affiche_saut "\n"
            ::console::disp $filename
            ::console::affiche_saut "\n"
            set audace(current_edit) $input
           # ::console::affiche_erreur "$caption(audace,console_gagne)\n"
         }
      } else {
        # ::console::affiche_erreur "$caption(audace,console_annule)\n"
      }
   }

   #
   # ::audace::runScript
   # Execute un script en demandant le nom du fichier par un explorateur
   #
   proc runScript { } {
      global audace caption errorInfo

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la fenetre de choix des scripts
      set filename [ ::tkutil::box_load $fenetre $audace(rep_scripts) $audace(bufNo) "3" ]
      #---
      if [string compare $filename ""] {
         ::console::affiche_erreur "\n"
         ::console::affiche_erreur "$caption(audace,script) $filename\n"
         ::console::affiche_erreur "\n"
         if {[catch {uplevel source \"$filename\"} m]} {
            ::console::affiche_erreur "$caption(audace,boite_erreur) $caption(audace,2points) $m\n";
            set m2 $errorInfo
            ::console::affiche_erreur "$m2\n";
         } else {
            ::console::affiche_erreur "\n"
         }
         ::console::affiche_erreur "$caption(audace,script_termine)\n"
         ::console::affiche_erreur "\n"
         ::console::affiche_saut "\n"
      }
   }

   #
   # ::audace::quitter
   # Demande la confirmation pour quitter
   #
   proc quitter { } {
      global audace caption conf tmp

      #--- je sors de la procedure si une fermeture est deja en cours
      if { $audace(quitterEnCours) == "1" } {
         return
      }
      #--- j'initialise la variable de fermeture
      set audace(quitterEnCours) "1"
      #---
      menustate disabled
      set catchError [ catch {
         #--- Positions et tailles des fenetres
         set conf(console,wmgeometry) [ wm geometry $audace(Console) ]

         #--- tous les outils de la visu 1
         if { [ ::confVisu::stopTool 1 ] == "-1" } {
            tk_messageBox -title "$caption(audace,attention)" -icon error \
               -message [ format $caption(audace,fermeture_impossible) [ [ ::confVisu::getTool 1 ]::getPluginTitle ] ]
            set audace(quitterEnCours) "0"
            menustate normal
            return
         }
         #--- tous les outils des autres visu
         foreach visuName [winfo children .] {
            set visuNo ""
            scan $visuName ".visu%d" visuNo
            if { $visuNo != "" } {
               if { [ ::confVisu::stopTool $visuNo ] == "-1" } {
                  tk_messageBox -title "$caption(audace,attention)" -icon error \
                     -message [ format $caption(audace,fermeture_impossible) [ [ ::confVisu::getTool $visuNo ]::getPluginTitle ] ]
                  set audace(quitterEnCours) "0"
                  menustate normal
                  return
               }
            }
         }
         #--- Arrete les plugins camera
         ::confCam::stopPlugin
         #--- Arrete les plugins monture
         ::confTel::stopPlugin
         #--- Arrete les plugins equipement
         ::confEqt::stopPlugin
         #--- Arrete les plugins raquette
         ::confPad::stopPlugin
         #--- Arrete les plugins carte
         ::confCat::stopPlugin
         #--- Arrete les plugins link
         ::confLink::stopPlugin
         #--- Arrete les visu sauf la visu1
         foreach visuName [winfo children .] {
            set visuNo ""
            scan $visuName ".visu%d" visuNo
            if { $visuNo != "" } {
               ::confVisu::close $visuNo
            }
         }

         set filename  [ file join $::audace(rep_home) audace.ini ]
         set filebak   [ file join $::audace(rep_home) audace.bak ]
         set filename2 $filename
         catch {
            file copy -force $filename $filebak
         }
         array set file_conf [ini_getArrayFromFile $filename]

         ::confVisu::close $audace(visuNo)

         if {[ini_fileNeedWritten file_conf conf]} {
            set old_focus [focus]
            set choice [tk_messageBox -message "$caption(audace,enregistrer_config_1)\n$caption(audace,enregistrer_config_2)" \
                  -title "$caption(audace,enregistrer_config_3)" -icon question -type yesnocancel]
            if {$choice=="yes"} {
               #--- Enregistrer la configuration
               ini_writeIniFile $filename2 conf
               ::audace::shutdown_devices
               exit
            } elseif {$choice=="no"} {
               #--- Pas d'enregistrement
               ::audace::shutdown_devices
               exit
            } else {
               set visuNo [ ::audace::createDialog ]
               ::confVisu::createMenu $visuNo
               ::audace::initLastEnv $visuNo
               ::audace::afficheOutilF2
            }
            focus $old_focus
         } else {
            set choice [tk_messageBox -type yesno -icon warning -title "$caption(audace,attention)" \
                  -message "$caption(audace,quitter)"]
            if {$choice=="yes"} {
               ::audace::shutdown_devices
               exit
            }
            ::console::affiche_resultat "$caption(audace,enregistrer_config_4)\n\n"
            set visuNo [ ::audace::createDialog ]
            ::confVisu::createMenu $visuNo
            ::audace::initLastEnv $visuNo
            ::audace::afficheOutilF2
         }
      #---
      } catchMessage ]
      if { $catchError == 1 } {
         ::console::affiche_erreur "$::errorInfo\n"
         tk_messageBox -message "$catchMessage" -title "$caption(audace,enregistrer_config_3)" -icon error
      }
      set audace(quitterEnCours) "0"
      menustate normal
   }

}
############################# Fin du namespace audace #############################

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

namespace eval ::newScript {

   #
   # ::newScript::run this
   # Lance la boite de dialogue de creation d'un nouveau script
   # this : Chemin de la fenetre
   #
   proc run { this } {
      variable This
      variable Filename
      global audace caption newScript

      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         createDialog $this
         set Filename [ file join $audace(rep_scripts) $caption(newscript,pas_de_nom) ]
         $This.frame1.ent1 configure -width [ expr [ string length $Filename ]+3 ]
         if { [ info exists newScript(geometry) ] } {
            wm geometry $This $newScript(geometry)
         }
      }
      tkwait variable newScript(flag)
      if { $newScript(flag) == "0" } {
         return [ list 0 "" ]
      } else {
         return [ list 1 $Filename ]
      }
   }

   #
   # ::newScript::createDialog this
   # Creation de l'interface graphique
   # this : Chemin de la fenetre
   #
   proc createDialog { this } {
      variable This
      global audace caption newScript

      if { $this == "" } {
         set This "$audace(base).newScript"
      } else {
         set This $this
      }
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(newscript,nouveau_script)"
      wm geometry $This +180+50
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::newScript::cmdClose

      #--- Cree un frame pour y mettre le bouton et la zone a renseigner
      frame $This.frame1 -borderwidth 1 -relief raised
         #--- Positionne le bouton et la zone a renseigner
         label $This.frame1.lab1 -text "$caption(newscript,nom_script)"
         pack $This.frame1.lab1 -side left -padx 5 -pady 5
         entry $This.frame1.ent1 -textvariable newScript::Filename
         pack $This.frame1.ent1 -side left -padx 5 -pady 5
         button $This.frame1.explore -text "$caption(newscript,parcourir)" -width 1 -command {
            set dirname [ tk_chooseDirectory -title "$caption(newscript,nouveau_script)" \
               -initialdir $audace(rep_scripts) -parent $::newScript::This ]
            set newScript::Filename [ file join $dirname $caption(newscript,pas_de_nom) ]
         }
         pack $This.frame1.explore -side left -padx 5 -pady 5 -ipady 5
      pack $This.frame1 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre les boutons
      frame $This.frame2 -borderwidth 1 -relief raised
         #--- Cree le bouton 'OK'
         button $This.frame2.ok -text "$caption(newscript,ok)" -width 8 -command { ::newScript::cmdOk }
         pack $This.frame2.ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
         #--- Cree le bouton 'Annuler'
         button $This.frame2.annuler -text "$caption(newscript,annuler)" -width 8 -command { ::newScript::cmdClose }
         pack $This.frame2.annuler -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5
         #--- Cree le bouton 'Aide'
         button $This.frame2.aide -text "$caption(newscript,aide)" -width 8 -command { ::newScript::afficheAide }
         pack $This.frame2.aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5
         #--- Commandes associees
         bind $This <Key-Return> newScript::cmdOk
         bind $This <Key-Escape> newScript::cmdClose
      pack $This.frame2 -side top -fill x

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::newScript::destroyDialog
   # Procedure correspondant a la fermeture de la fenetre
   #
   proc destroyDialog { } {
      variable This
      global newScript

      set newScript(geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

   #
   # ::newScript::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      global newScript

      set newScript(flag) 1
      ::newScript::destroyDialog
   }

   #
   # ::newScript::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      ::audace::showHelpItem "$help(dir,fichier)" "1050nouveau_script.htm"
   }

   #
   # ::newScript::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      global newScript

      set newScript(flag) 0
      ::newScript::destroyDialog
   }

}

############################ Fin du namespace newScript ############################

