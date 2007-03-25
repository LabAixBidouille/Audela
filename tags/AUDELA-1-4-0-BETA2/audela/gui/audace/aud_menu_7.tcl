#
# Fichier : aud_menu_7.tcl
# Description : Script regroupant les fonctionnalites du menu Configuration
# Mise a jour $Id: aud_menu_7.tcl,v 1.6 2007-03-03 22:09:28 robertdelmas Exp $
#

namespace eval ::cwdWindow {

   #
   # ::cwdWindow::run this
   # Lance la boite de dialogue de reglage des repertoires
   # this : Chemin de la fenetre
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
      wm title $This "$caption(cwdWindow,repertoire)"
      wm protocol $This WM_DELETE_WINDOW ::cwdWindow::cmdClose
      #--- Initialisation des variables de changement
      set cwdWindow(rep_images)     "0"
      set cwdWindow(rep_scripts)    "0"
      set cwdWindow(rep_catalogues) "0"
      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.a -borderwidth 0 -relief raised
               button $This.usr.1.a.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command { ::cwdWindow::change_rep_images }
               pack $This.usr.1.a.explore -side left -padx 5 -pady 5 -ipady 5
               label $This.usr.1.a.lab1 -text "$caption(cwdWindow,repertoire_images)"
               pack $This.usr.1.a.lab1 -side left -padx 5 -pady 5
               entry $This.usr.1.a.ent1 -textvariable cwdWindow(dir_images) -width $cwdWindow(long)
               pack $This.usr.1.a.ent1 -side right -padx 5 -pady 5
            pack $This.usr.1.a -side top -fill both -expand 1
            frame $This.usr.1.b -borderwidth 0 -relief raised
               #--- Label nouveau sous-repertoire
               label $This.usr.1.b.label_sous_rep -text "$caption(cwdWindow,label_sous_rep)"
               pack $This.usr.1.b.label_sous_rep -side left -padx 5 -pady 5
               #--- Entry nouveau sous-repertoire
               entry $This.usr.1.b.ent_sous_rep -textvariable cwdWindow(sous_repertoire) -width 30
               pack $This.usr.1.b.ent_sous_rep -side left -padx 5 -pady 5
               #--- Button creation du sous-repertoire
               button $This.usr.1.b.button_sous_rep -text "$caption(cwdWindow,creation_sous_rep)" -width 7 \
                  -command { ::cwdWindow::cmdCreateSubDir }
               pack $This.usr.1.b.button_sous_rep -side left -padx 5 -pady 5 -ipady 5
            pack $This.usr.1.b -side top -fill both -expand 1
         pack $This.usr.1 -side top -fill both -expand 1
         frame $This.usr.2 -borderwidth 1 -relief raised
            button $This.usr.2.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command { ::cwdWindow::change_rep_scripts }
            pack $This.usr.2.explore -side left -padx 5 -pady 5 -ipady 5
            label $This.usr.2.lab2 -text "$caption(cwdWindow,repertoire_scripts)"
            pack $This.usr.2.lab2 -side left -padx 5 -pady 5
            entry $This.usr.2.ent2 -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long)
            pack $This.usr.2.ent2 -side right -padx 5 -pady 5
         pack $This.usr.2 -side top -fill both -expand 1
         frame $This.usr.3 -borderwidth 1 -relief raised
            button $This.usr.3.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command { ::cwdWindow::change_rep_catalogues }
            pack $This.usr.3.explore -side left -padx 5 -pady 5 -ipady 5
            label $This.usr.3.lab3 -text "$caption(cwdWindow,repertoire_catalogues)"
            pack $This.usr.3.lab3 -side left -padx 5 -pady 5
            entry $This.usr.3.ent3 -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long)
            pack $This.usr.3.ent3 -side right -padx 5 -pady 5
         pack $This.usr.3 -side top -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) [ $This.usr.1.a.ent1 cget -font ]
      #---
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_7,ok)" -width 7 \
            -command { ::cwdWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
           pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_7,appliquer)" -width 8 \
            -command { ::cwdWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_7,fermer)" -width 7 \
            -command { ::cwdWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_7,aide)" -width 7 \
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
      set title $caption(cwdWindow,repertoire_images)
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
      set title $caption(cwdWindow,repertoire_scripts)
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
      set title $caption(cwdWindow,repertoire_catalogues)
      set cwdWindow(dir_catalogues) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.3.ent3 configure -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.3
   }

   #
   # ::cwdWindow::tkplus_chooseDir [inidir] [title] [parent]
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

      #--- Substituer les \ par des /
      regsub -all {[\\]} $cwdWindow(dir_images) "/" cwdWindow(dir_images)
      regsub -all {[\\]} $cwdWindow(dir_scripts) "/" cwdWindow(dir_scripts)
      regsub -all {[\\]} $cwdWindow(dir_catalogues) "/" cwdWindow(dir_catalogues)

      if {[file exists "$cwdWindow(dir_images)"] && [file isdirectory "$cwdWindow(dir_images)"]} {
         set conf(rep_images) "$cwdWindow(dir_images)"
         set audace(rep_images) "$cwdWindow(dir_images)"
      } else {
         set m "$cwdWindow(dir_images)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists "$cwdWindow(dir_scripts)"] && [file isdirectory "$cwdWindow(dir_scripts)"]} {
         set conf(rep_scripts) "$cwdWindow(dir_scripts)"
         set audace(rep_scripts) "$cwdWindow(dir_scripts)"
      } else {
         set m "$cwdWindow(dir_scripts)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists "$cwdWindow(dir_catalogues)"] && [file isdirectory "$cwdWindow(dir_catalogues)"]} {
         set conf(rep_catalogues) "$cwdWindow(dir_catalogues)"
         set audace(rep_catalogues) "$cwdWindow(dir_catalogues)"
      } else {
         set m "$cwdWindow(dir_catalogues)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

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

namespace eval ::confEditScript {

   #
   # confEditScript::run this
   # Cree la fenetre de configuration de l'editeur de scripts, de fichiers pdf, de pages html et d'images
   # this : Chemin de la fenetre
   #
   proc run { this } {
      variable This
      global confgene

      set This $this

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      updateData
      createDialog
      focus $This

      if { [ info exists confgene(EditScript,geometry) ] } {
         wm geometry $This $confgene(EditScript,geometry)
      }

      tkwait visibility $This
      tkwait variable confgene(EditScript,ok)
      catch { destroy $This }

      return $confgene(EditScript,ok)
   }

   #
   # ::confEditScript::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption conf confgene

      if { [ info exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(confeditscript,editeurs)"
      wm geometry $This +180+50
      wm protocol $This WM_DELETE_WINDOW ::confEditScript::cmdClose

      #--- Ecriture du chemin d'un repertoire et du nom d'un lecteur
      if { $::tcl_platform(os) == "Linux" } {
         set confgene(EditScript,path) [ file join / usr bin ]
      } else {
      set defaultpath [ file join C: "Program Files" ]
      catch {
         set testpath "$::env(ProgramFiles)"
         set kend [expr [string length $testpath]-1]
         for {set k 0} {$k<=$kend} {incr k} {
            set car [string index "$testpath" $k]
            if {$car=="\\"} {
               set testpath [string replace "$testpath" $k $k /]
            }
         }
         set defaultpath "$testpath"
         }
      set confgene(EditScript,path)  "$defaultpath"
      set confgene(EditScript,drive) [ lindex [ file split "$confgene(EditScript,path)" ] 0 ]
      }

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Editeur de scripts
      frame $This.usr1 -borderwidth 1 -relief raised

         #--- Creation d'une entry non affichee pour en recuperer le parametre -font
         entry $This.usr1.ent0 -width 1
         set confgene(EditScript,edit_font)        [ $This.usr1.ent0 cget -font ]
         set confgene(EditScript,edit_font)        "$confgene(EditScript,edit_font) normal"
         set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]

         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_script) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         button $This.usr1.explore1 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               $::confEditScript::This.usr1.ent1 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_script) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "6" ]
               if { $confgene(EditScript,edit_script) == "" } {
                  set confgene(EditScript,edit_script) $conf(editscript)
               }
               focus $::confEditScript::This.usr1
               $::confEditScript::This.usr1.ent1 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr1.explore1 -side left -padx 5 -pady 5 -ipady 5
         label $This.usr1.lab1 -text "$caption(confeditscript,edit_script)"
         pack $This.usr1.lab1 -side left -padx 5 -pady 5
         entry $This.usr1.ent1 -textvariable confgene(EditScript,edit_script) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr1.ent1 -side right -padx 5 -pady 5
      pack $This.usr1 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Editeur de documents pdf
      frame $This.usr2 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_pdf) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         button $This.usr2.explore2 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               $::confEditScript::This.usr2.ent2 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_pdf) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "7" ]
               if { $confgene(EditScript,edit_pdf) == "" } {
                  set confgene(EditScript,edit_pdf) $conf(editnotice_pdf)
               }
               focus $::confEditScript::This.usr2
               $::confEditScript::This.usr2.ent2 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr2.explore2 -side left -padx 5 -pady 5 -ipady 5
         label $This.usr2.lab2 -text "$caption(confeditscript,notice_pdf)"
         pack $This.usr2.lab2 -side left -padx 5 -pady 5
         entry $This.usr2.ent2 -textvariable confgene(EditScript,edit_pdf) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr2.ent2 -side right -padx 5 -pady 5
      pack $This.usr2 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Navigateur de pages htm
      frame $This.usr3 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_htm) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         button $This.usr3.explore3 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               $::confEditScript::This.usr3.ent3 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_htm) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "8" ]
               if { $confgene(EditScript,edit_htm) == "" } {
                  set confgene(EditScript,edit_htm) $conf(editsite_htm)
               }
               focus $::confEditScript::This.usr3
               $::confEditScript::This.usr3.ent3 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr3.explore3 -side left -padx 5 -pady 5 -ipady 5
         label $This.usr3.lab3 -text "$caption(confeditscript,navigateur_htm)"
         pack $This.usr3.lab3 -side left -padx 5 -pady 5
         entry $This.usr3.ent3 -textvariable confgene(EditScript,edit_htm) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr3.ent3 -side right -padx 5 -pady 5
      pack $This.usr3 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Visualiseur d'images
      frame $This.usr4 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_viewer) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         button $This.usr4.explore4 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               $::confEditScript::This.usr4.ent4 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_viewer) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "9" ]
               if { $confgene(EditScript,edit_viewer) == "" } {
                  set confgene(EditScript,edit_viewer) $conf(edit_viewer)
               }
               focus $::confEditScript::This.usr4
               $::confEditScript::This.usr4.ent4 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr4.explore4 -side left -padx 5 -pady 5 -ipady 5
         label $This.usr4.lab4 -text "$caption(confeditscript,viewer)"
         pack $This.usr4.lab4 -side left -padx 5 -pady 5
         entry $This.usr4.ent4 -textvariable confgene(EditScript,edit_viewer) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr4.ent4 -side right -padx 5 -pady 5
      pack $This.usr4 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         #--- Cree le bouton 'OK'
         button $This.cmd.ok -text "$caption(aud_menu_7,ok)" -width 7 -command ::confEditScript::cmdOk
         pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Fermer'
         button $This.cmd.fermer -text "$caption(aud_menu_7,fermer)" -width 7 -command ::confEditScript::cmdClose
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Aide'
         button $This.cmd.aide -text "$caption(aud_menu_7,aide)" -width 7 -command ::confEditScript::afficheAide
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::confEditScript::updateData
   # Mise a jour automatique de la longueur des entry
   #
   proc updateData { } {
      global conf confgene

      catch {
         set confgene(EditScript,edit_script) $conf(editscript)
         set confgene(EditScript,long)        [ string length $confgene(EditScript,edit_script) ]
      }
      if { ! [ info exists confgene(EditScript,edit_script) ] } { set confgene(EditScript,long) "30" }
      catch {
         set confgene(EditScript,edit_pdf) $conf(editnotice_pdf)
         set confgene(EditScript,long_pdf) [ string length $confgene(EditScript,edit_pdf) ]
      }
      if { ! [ info exists confgene(EditScript,edit_pdf) ] } { set confgene(EditScript,long_pdf) "30" }
      catch {
         set confgene(EditScript,edit_htm) $conf(editsite_htm)
         set confgene(EditScript,long_htm) [ string length $confgene(EditScript,edit_htm) ]
      }
      if { ! [ info exists confgene(EditScript,edit_htm) ] } { set confgene(EditScript,long_htm) "30" }
      catch {
         set confgene(EditScript,edit_viewer) $conf(edit_viewer)
         set confgene(EditScript,long_viewer) [ string length $confgene(EditScript,edit_viewer) ]
      }
      if { ! [ info exists confgene(EditScript,edit_viewer) ] } { set confgene(EditScript,long_viewer) "30" }

      if { $confgene(EditScript,long_pdf) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_pdf)
      }
      if { $confgene(EditScript,long_htm) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_htm)
      }
      if { $confgene(EditScript,long_viewer) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_viewer)
      }
      set confgene(EditScript,long) [expr $confgene(EditScript,long) + 3]
   }

   #
   # ::confEditScript::destroyDialog
   # Procedure correspondant a la fermeture de la fenetre
   #
   proc destroyDialog { } {
      variable This
      global confgene

      set confgene(EditScript,geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

   #
   # ::confEditScript::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      global conf confgene

      #---
      set conf(editscript)                  "$confgene(EditScript,edit_script)"
      set conf(editnotice_pdf)              "$confgene(EditScript,edit_pdf)"
      set conf(editsite_htm)                "$confgene(EditScript,edit_htm)"
      set conf(edit_viewer)                 "$confgene(EditScript,edit_viewer)"
      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      #---
      set confgene(EditScript,ok)           "1"
      ::confEditScript::destroyDialog
   }

   #
   # ::confEditScript::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1030editeur.htm"
   }

   #
   # ::confEditScript::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      global confgene

      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      #---
      set confgene(EditScript,ok)           "0"
      ::confEditScript::destroyDialog
   }

}

######################### Fin du namespace confEditScript #########################

namespace eval ::audace {

   #
   # ::audace::enregistrerConfiguration visuNo
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
         set choice [ tk_messageBox -message "$caption(audace,enregistrer_config3)" \
            -title "$caption(audace,enregistrer_config1)" -icon question -type yesno ]
         if { $choice == "yes" } {
            #--- Enregistrer la configuration
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            ::console::affiche_resultat "$caption(audace,enregistrer_config2)\n\n"
         }
      } else {
         #--- Pas d'enregistrement
         ::console::affiche_resultat "$caption(audace,enregistrer_config2)\n\n"
      }
      #---
      menustate normal
      #---
      focus $audace(base)
   }

}
############################# Fin du namespace audace #############################

