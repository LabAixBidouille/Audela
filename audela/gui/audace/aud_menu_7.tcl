#
# Fichier : aud_menu_7.tcl
# Description : Script regroupant les fonctionnalites du menu Configuration
# Mise a jour $Id: aud_menu_7.tcl,v 1.1 2006-11-05 07:42:48 robertdelmas Exp $
#

namespace eval ::cwdWindow {

   #
   # ::cwdWindow::run
   # Lance la boite de dialogue de reglage des repertoires
   #
   proc run { this } {
      variable This
      global audace cwdWindow

      #---
      if { [info exists This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         set cwdWindow(dir_images) $audace(rep_images)
         set cwdWindow(dir_scripts) $audace(rep_scripts)
         set cwdWindow(dir_catalogues) $audace(rep_catalogues)
         set cwdWindow(long) [string length $cwdWindow(dir_images)]
         if {[string length $cwdWindow(dir_scripts)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_scripts)]
         }
         if {[string length $cwdWindow(dir_catalogues)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_catalogues)]
         }
         set cwdWindow(long) [expr $cwdWindow(long) + 10]
         createDialog
      }
   }

   #
   # ::cwdWindow::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global caption conf cwdWindow

      #--- Nom du sous-repertoire
      set date [clock format [clock seconds] -format "%y%m%d"]
      set cwdWindow(sous_repertoire) $date
      #---
      toplevel $This
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This "$caption(audace,menu,cwd)"
      wm protocol $This WM_DELETE_WINDOW ::cwdWindow::cmdClose
      #--- Initialisation des variables de changement
      set cwdWindow(rep_images)     "0"
      set cwdWindow(rep_scripts)    "0"
      set cwdWindow(rep_catalogues) "0"
      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.a -borderwidth 0 -relief raised
               button $This.usr.1.a.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::cwdWindow::change_rep_images }
               pack $This.usr.1.a.explore -side left -padx 5 -pady 5 -ipady 5
               label $This.usr.1.a.lab1 -text "$caption(audace,dialog,repertoire_images)"
               pack $This.usr.1.a.lab1 -side left -padx 5 -pady 5
               entry $This.usr.1.a.ent1 -textvariable cwdWindow(dir_images) -width $cwdWindow(long)
               pack $This.usr.1.a.ent1 -side right -padx 5 -pady 5
            pack $This.usr.1.a -side top -fill both -expand 1
            frame $This.usr.1.b -borderwidth 0 -relief raised
               #--- Label nouveau sous-repertoire
               label $This.usr.1.b.label_sous_rep -text "$caption(audace,label_sous_rep)"
               pack $This.usr.1.b.label_sous_rep -side left -padx 5 -pady 5
               #--- Entry nouveau sous-repertoire
               entry $This.usr.1.b.ent_sous_rep -textvariable cwdWindow(sous_repertoire) -width 30
               pack $This.usr.1.b.ent_sous_rep -side left -padx 5 -pady 5
               #--- Button creation du sous-repertoire
               button $This.usr.1.b.button_sous_rep -text "$caption(audace,creation_sous_rep)" -width 7 \
                  -command { ::cwdWindow::cmdCreateSubDir }
               pack $This.usr.1.b.button_sous_rep -side left -padx 5 -pady 5 -ipady 5
            pack $This.usr.1.b -side top -fill both -expand 1
         pack $This.usr.1 -side top -fill both -expand 1
         frame $This.usr.2 -borderwidth 1 -relief raised
            button $This.usr.2.explore -text "$caption(script,parcourir)" -width 1 \
               -command { ::cwdWindow::change_rep_scripts }
            pack $This.usr.2.explore -side left -padx 5 -pady 5 -ipady 5
            label $This.usr.2.lab2 -text "$caption(audace,dialog,repertoire_scripts)"
            pack $This.usr.2.lab2 -side left -padx 5 -pady 5
            entry $This.usr.2.ent2 -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long)
            pack $This.usr.2.ent2 -side right -padx 5 -pady 5
         pack $This.usr.2 -side top -fill both -expand 1
         frame $This.usr.3 -borderwidth 1 -relief raised
            button $This.usr.3.explore -text "$caption(script,parcourir)" -width 1 \
               -command { ::cwdWindow::change_rep_catalogues }
            pack $This.usr.3.explore -side left -padx 5 -pady 5 -ipady 5
            label $This.usr.3.lab3 -text "$caption(audace,dialog,repertoire_catalogues)"
            pack $This.usr.3.lab3 -side left -padx 5 -pady 5
            entry $This.usr.3.ent3 -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long)
            pack $This.usr.3.ent3 -side right -padx 5 -pady 5
         pack $This.usr.3 -side top -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) [ $This.usr.1.a.ent1 cget -font ]
      #---
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::cwdWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
           pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::cwdWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::cwdWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::cwdWindow::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x
      #---
      bind $This <Key-Return> {::cwdWindow::cmdOk}
      bind $This <Key-Escape> {::cwdWindow::cmdClose}
      #--- La fenetre est active
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::cwdWindow::cmdCreateSubDir
   # Creation d'un sous-repertoire
   #
   proc cmdCreateSubDir { } {
      variable This
      global cwdWindow

      set subDirectory [ file join $cwdWindow(dir_images) $cwdWindow(sous_repertoire) ]
      set command "file mkdir $subDirectory"
      file mkdir $subDirectory
      set cwdWindow(dir_images) $subDirectory
      update
      focus $This.usr.1.a.ent1
      event generate $This.usr.1.a.ent1 <Control-e> 
   }

   #
   # ::cwdWindow::change_rep_images
   # Ouvre le navigateur pour choisir le repertoire des images
   #
   proc change_rep_images { } {
      variable This
      global caption cwdWindow

      #---
      set cwdWindow(rep_font) "$cwdWindow(rep_font) normal"
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_images) "1"
      $This.usr.1.a.ent1 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir $cwdWindow(dir_images)
      set title $caption(audace,dialog,repertoire_images)
      set cwdWindow(dir_images) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.1.a.ent1 configure -textvariable cwdWindow(dir_images) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.1
   }

   #
   # ::cwdWindow::change_rep_scripts
   # Ouvre le navigateur pour choisir le repertoire des scripts
   #
   proc change_rep_scripts { } {
      variable This
      global caption cwdWindow

      #---
      set cwdWindow(rep_font) "$cwdWindow(rep_font) normal"
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_scripts) "1"
      $This.usr.2.ent2 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir $cwdWindow(dir_scripts)
      set title $caption(audace,dialog,repertoire_scripts)
      set cwdWindow(dir_scripts) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.2.ent2 configure -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.2
   }

   #
   # ::cwdWindow::change_rep_catalogues
   # Ouvre le navigateur pour choisir le repertoire des catalogues
   #
   proc change_rep_catalogues { } {
      variable This
      global caption cwdWindow

      #---
      set cwdWindow(rep_font) "$cwdWindow(rep_font) normal"
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_catalogues) "1"
      $This.usr.3.ent3 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir $cwdWindow(dir_catalogues)
      set title $caption(audace,dialog,repertoire_catalogues)
      set cwdWindow(dir_catalogues) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.3.ent3 configure -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.3
   }

   #
   # ::cwdWindow::tkplus_chooseDir
   # Navigateur pour le choix des repertoires
   #
   proc tkplus_chooseDir { { inidir . } { title } { parent } } {
      global cwdWindow

      if {$inidir=="."} {
         set inidir [pwd]
      }
      if { $cwdWindow(rep_images) == "1" } {
         set cwdWindow(rep_images) "0"
      } elseif { $cwdWindow(rep_scripts) == "1" } {
         set cwdWindow(rep_scripts) "0"
      } elseif { $cwdWindow(rep_catalogues) == "1" } {
         set cwdWindow(rep_catalogues) "0"
      }
      set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]
      if {$res==""} {
         return "$inidir"
      } else {
         return "$res"
      }
   }

   #
   # ::cwdWindow::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      if {[cmdApply] == 0} {
         cmdClose
      }
   }

   #
   # ::cwdWindow::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      global audace caption conf cwdWindow

      #---
      save_cursor
      all_cursor watch
      #--- Substituer les \ par des /
      regsub -all {[\\]} $cwdWindow(dir_images) "/" cwdWindow(dir_images)
      regsub -all {[\\]} $cwdWindow(dir_scripts) "/" cwdWindow(dir_scripts)
      regsub -all {[\\]} $cwdWindow(dir_catalogues) "/" cwdWindow(dir_catalogues)

      if {[file exists "$cwdWindow(dir_images)"] && [file isdirectory "$cwdWindow(dir_images)"]} {
         set conf(rep_images) "$cwdWindow(dir_images)"
         set audace(rep_images) "$cwdWindow(dir_images)"
      } else {
         set m "$cwdWindow(dir_images)"
         append m "$caption(audace,boite,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(audace,boite,erreur)"
         restore_cursor
         return -1
      }

      if {[file exists "$cwdWindow(dir_scripts)"] && [file isdirectory "$cwdWindow(dir_scripts)"]} {
         set conf(rep_scripts) "$cwdWindow(dir_scripts)"
         set audace(rep_scripts) "$cwdWindow(dir_scripts)"
      } else {
         set m "$cwdWindow(dir_scripts)"
         append m "$caption(audace,boite,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(audace,boite,erreur)"
         restore_cursor
         return -1
      }

      if {[file exists "$cwdWindow(dir_catalogues)"] && [file isdirectory "$cwdWindow(dir_catalogues)"]} {
         set conf(rep_catalogues) "$cwdWindow(dir_catalogues)"
         set audace(rep_catalogues) "$cwdWindow(dir_catalogues)"
      } else {
         set m "$cwdWindow(dir_catalogues)"
         append m "$caption(audace,boite,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(audace,boite,erreur)"
         restore_cursor
         return -1
      }

      restore_cursor
      return 0
   }

   #
   # ::cwdWindow::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1020repertoire.htm"
   }

   #
   # ::cwdWindow::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This
      global cwdWindow

      set cwdWindow(geometry) [wm geometry $This]
      destroy $This
      unset This
   }

}
########################### Fin du namespace cwdWindow ###########################

namespace eval ::audace {

   #
   # ::audace::enregistrerConfiguration
   # Demande la confirmation pour enregistrer la configuration
   #
   proc enregistrerConfiguration { visuNo } {
      global audace caption conf

      #---
      menustate disabled
      #--- Positions des fenetres
      set conf(audace,visu$visuNo,wmgeometry) "[wm geometry $audace(base)]"
      set conf(console,wmgeometry) "[wm geometry $audace(Console)]"
      if {[winfo exists $audace(base).tjrsvisible]==1} {
         set conf(ouranos,wmgeometry) "[wm geometry $audace(base).tjrsvisible]"
      }

      #---
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

      if {[ini_fileNeedWritten file_conf conf]} {
         set choice [ tk_messageBox -message "$caption(sur,enregistrer,config7)" \
            -title "$caption(sur,enregistrer,config3)" -icon question -type yesno ]
         if { $choice == "yes" } {
            #--- Enregistrer la configuration
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            ::console::affiche_resultat "$caption(sur,enregistrer,config5)\n\n"
         }
      } else {
         #--- Pas d'enregistrement
         ::console::affiche_resultat "$caption(sur,enregistrer,config5)\n\n"
      }
      #---
      menustate normal
      #---
      focus $audace(base)
   }

}
############################# Fin du namespace audace #############################

