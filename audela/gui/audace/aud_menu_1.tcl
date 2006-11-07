#
# Fichier : aud_menu_1.tcl
# Description : Script regroupant les fonctionnalites du menu Fichier
# Mise a jour $Id: aud_menu_1.tcl,v 1.2 2006-11-07 21:00:02 robertdelmas Exp $
#

namespace eval ::audace {

   #
   # ::audace::charger
   # Charge un fichier dans la visu
   #
   proc charger { visuNo } {
      menustate disabled
      save_cursor
      all_cursor watch
      set errnum [ catch { loadima ? $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   #
   # ::audace::enregistrer
   # Enregistre un fichier sous son nom d'ouverture
   #
   proc enregistrer { visuNo } {
      menustate disabled
      save_cursor
      all_cursor watch
      set errnum [ catch { saveima $::confVisu::private($visuNo,lastFileName) $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   #
   # ::audace::enregistrer_sous
   # Enregistre un fichier sous un nom
   #
   proc enregistrer_sous { visuNo } {
      menustate disabled
      save_cursor
      all_cursor watch
      set errnum [ catch { saveima ? $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   #
   # ::audace::copyjpeg
   # Enregistre un fichier au format Jpeg
   #
   proc copyjpeg { visuNo } {
      menustate disabled
      save_cursor
      all_cursor watch
      #---
      set bufNo [ visu$visuNo buf ]
      #--- On sort immediatement s'il n'y a pas d'image dans le buffer
      if { [ buf$bufNo imageready ] == "0" } {
         restore_cursor
         menustate normal
         return
      }
      #---
      set errnum [ catch { sauve_jpeg ? } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   #
   # ::audace::header
   # Affiche l'en-tete FITS d'un fichier
   #
   proc header { visuNo } {
      global audace caption color

      #---
      set base [ ::confVisu::getBase $visuNo ]
      #---
      set i 0
      if [winfo exists $base.header] {
         destroy $base.header
      }
      toplevel $base.header
      wm transient $base.header $base
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
         wm minsize $base.header 632 303
      }
      wm resizable $base.header 0 1
      wm title $base.header "$caption(audace,menu,entete) (visu$visuNo)"
      set posx_header [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_header [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $base.header +[ expr $posx_header + 3 ]+[ expr $posy_header + 75 ]

      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
         Scrolled_Text $base.header.slb -width 87 -font $audace(font,en_tete_1) -height 20
         pack $base.header.slb -fill y -expand true
         $base.header.slb.list tag configure keyw -foreground $color(blue)   -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure egal -foreground $color(black)  -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure valu -foreground $color(red)    -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure comm -foreground $color(green1) -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure unit -foreground $color(orange) -font $audace(font,en_tete_2)
         foreach kwd [ lsort -dictionary [ buf[ ::confVisu::getBufNo $visuNo ] getkwds ] ] {
            set liste [ buf[ ::confVisu::getBufNo $visuNo ] getkwd $kwd ]
            set koff 0
            if {[llength $liste]>5} {
               #--- Detourne un bug eventuel des mots longs (ne devrait jamais arriver !)
               set koff [expr [llength $liste]-5]
            }
            set keyword "$kwd"
            if {[string length $keyword]<=8} {
               set keyword "[format "%8s" $keyword]"
            }
            $base.header.slb.list insert end "$keyword " keyw
            $base.header.slb.list insert end "= " egal
            $base.header.slb.list insert end "[lindex $liste [expr $koff+1]] " valu
            $base.header.slb.list insert end "[lindex $liste [expr $koff+3]] " comm
            $base.header.slb.list insert end "[lindex $liste [expr $koff+4]]\n" unit
         }
      } else {
         label $base.header.l -text "$caption(audace,header,noimage)"
         pack $base.header.l -padx 20 -pady 10
      }
      update

      #--- Focus
      focus $base.header

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $base.header <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base.header
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
               ::console::affiche_erreur "$caption(impossible,ouvrir,fichier) $msg\n"
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
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # ::console::affiche_erreur "$caption(audace,console,rate)\n"
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
           # ::console::affiche_erreur "$caption(audace,console,gagne)\n"
         }
      } else {
        # ::console::affiche_erreur "$caption(audace,console,annule)\n"
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
         ::console::affiche_saut "\n"
         ::console::affiche_erreur "\n"
         ::console::affiche_erreur "$caption(prog,erreur,script) $filename\n"
         ::console::affiche_erreur "\n"
         if {[catch {uplevel source \"$filename\"} m]} {
            ::console::affiche_erreur "$caption(audace,boite,erreur) $caption(caractere,2points) $m\n";
            set m2 $errorInfo
            ::console::affiche_erreur "$m2\n";
         } else {
            ::console::affiche_erreur "\n"
         }
         ::console::affiche_erreur "$caption(termine,erreur,script)\n"
         ::console::affiche_erreur "\n"
      }
   }

   #
   # ::audace::quitter
   # Demande la confirmation pour quitter
   #
   proc quitter { } {
      global audace caption tmp

      #--- Si le tutorial EthernAude est affiche, je le ferme en premier avant de quitter
      if { [ winfo exist .main ] } {
         if { [ winfo exist .second ] } {
            destroy .second
         }
         destroy .main
      }
      #--- Si l'outil SnVisu est affiche, je le ferme avant de quitter
      if { [ winfo exists $audace(base).snvisu ] } {
         sn_delete
      }
      #--- Si l'outil CCD Couleur est affiche, je le ferme avant de quitter
      if { [ winfo exists $audace(base).test ] } {
         testexit
      }
      #---
      menustate disabled
      wm protocol $audace(base) WM_DELETE_WINDOW ::audace::rien
      wm protocol $audace(Console) WM_DELETE_WINDOW ::audace::rien
      #--- Positions et tailles des fenetres
      set conf(audace,visu1,wmgeometry) "[wm geometry $audace(base)]"
      set conf(console,wmgeometry) "[wm geometry $audace(Console)]"
      if {[winfo exists $audace(base).tjrsvisible]==1} {
         set conf(ouranos,wmgeometry) "[wm geometry $audace(base).tjrsvisible]"
      }
      #--- Arrete les plugins camera
      ::confCam::stopDriver
      #--- Arrete le plugin monture
      ### ::confTel::stopDriver
      #--- Arrete le plugin equipement
      ::confEqt::stopDriver
      #--- Arrete le plugin raquette
      ::confPad::stopDriver
      #--- Arrete le plugin carte
      ::confCat::stopDriver
      #--- Arrete les visu sauf la visu1
      foreach visuNo [visu::list] {
         if { $visuNo != "1"  } {
            ::confVisu::close $visuNo
         }
      }

      if { $::tcl_platform(os) == "Linux" } {
         set filename [ file join ~ .audela config.ini ]
         set filebak [ file join ~ .audela config.bak ]
      } else {
         set filename [ file join $audace(rep_audela) audace config.ini ]
         set filebak [ file join $audace(rep_audela) audace config.bak ]
      }
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ini_getArrayFromFile $filename]

      #--- Suppression des fichiers temporaires 'fonction_transfert.pal' et 'fonction_transfert_x.pal'
      if { [ lindex [ decomp $tmp(fichier_palette).pal ] 2 ] != "" } {
         #--- Cas des fichiers temporaires 'fonction_transfert_x.pal'
         set index_final [ lindex [ decomp $tmp(fichier_palette).pal ] 2 ]
         for { set index "1" } { $index <= $index_final } { incr index } {
            file delete [ file join [ lindex [ decomp $tmp(fichier_palette).pal ] 0 ] [ lindex [ decomp $tmp(fichier_palette).pal ] 1 ]$index[ lindex [ decomp $tmp(fichier_palette).pal ] 3 ] ]
            file delete [ file join [ lindex [ decomp $tmp(fichier_palette).pal ] 0 ] [ string trimright [ lindex [ decomp $tmp(fichier_palette).pal ] 1 ] "_" ][ lindex [ decomp $tmp(fichier_palette).pal ] 3 ] ]
         }
      } else {
         #--- Cas du fichier temporaire 'fonction_transfert.pal'
         file delete [ file join [ lindex [ decomp $tmp(fichier_palette).pal ] 0 ] [ lindex [ decomp $tmp(fichier_palette).pal ] 1 ][ lindex [ decomp $tmp(fichier_palette).pal ] 2 ][ lindex [ decomp $tmp(fichier_palette).pal ] 3 ] ]
      }

      if {[ini_fileNeedWritten file_conf conf]} {
         set old_focus [focus]
         set choice [tk_messageBox -message "$caption(sur,enregistrer,config1)\n$caption(sur,enregistrer,config2)" \
            -title "$caption(sur,enregistrer,config3)" -icon question -type yesnocancel]
         if {$choice=="yes"} {
            #--- Enregistrer la configuration
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
            ::confVisu::stopTool $audace(visuNo)
            ::audace::shutdown_devices
            exit
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            wm protocol $audace(base) WM_DELETE_WINDOW " ::audace::quitter "
            wm protocol $audace(Console) WM_DELETE_WINDOW " ::audace::quitter "
            ::confVisu::stopTool $audace(visuNo)
            ::audace::shutdown_devices
            exit
         } else {
            wm protocol $audace(base) WM_DELETE_WINDOW " ::audace::quitter "
            wm protocol $audace(Console) WM_DELETE_WINDOW " ::audace::quitter "
         }
         focus $old_focus
      } else {
         set choice [tk_messageBox -type yesno -icon warning -title "$caption(attention,enregistrer,config)" \
            -message "$caption(audace,prog,quitter)"]
         if {$choice=="yes"} {
            ::confVisu::stopTool $audace(visuNo)
            ::audace::shutdown_devices
            exit
         }
         ::console::affiche_resultat "$caption(sur,enregistrer,config5)\n\n"
         wm protocol $audace(base) WM_DELETE_WINDOW " ::audace::quitter "
         wm protocol $audace(Console) WM_DELETE_WINDOW " ::audace::quitter "
      }
      #---
      menustate normal
      focus $audace(base)
   }

}
############################# Fin du namespace audace #############################

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

namespace eval ::newScript {

   #
   # ::newScript::run
   # Lance la boite de dialogue de creation d'un nouveau script
   #
   proc run { this } {
      variable This
      variable Filename
      global audace caption newScript

      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
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
   # ::newScript::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { this } {
      variable This
      global audace caption newScript

      if { $this == "" } {
         set This "$audace(base).newScript"
      } else {
         set This $this
      }
      if { [ info exists $This ] } {
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
         button $This.frame1.explore -text "$caption(newscript,parcourir)" -width 1 -command {
            set dirname [ tk_chooseDirectory -title "$caption(newscript,nouveau_script)" \
               -initialdir $audace(rep_scripts) -parent $::newScript::This ]
            set newScript::Filename [ file join $dirname $caption(newscript,pas_de_nom) ]
         }
         pack $This.frame1.explore -side left -padx 5 -pady 5 -ipady 5
         label $This.frame1.lab1 -text "$caption(newscript,nom_script)"
         pack $This.frame1.lab1 -side left -padx 5 -pady 5
         entry $This.frame1.ent1 -textvariable newScript::Filename
         pack $This.frame1.ent1 -side right -padx 5 -pady 5
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

