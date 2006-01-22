#
# Description : Fenetre generique pour les fonctions de SpcAud'ACE
# Date de mise a jour : 21 janvier 2006
#

#--- Definition des captions de la fenetre generique
global caption

set caption(fenetre_generique,fonction_1,titre)  "Titre de la fenêtre pour la fonction 1"
set caption(fenetre_generique,fonction_2,titre)  "Titre de la fenêtre pour la fonction 2"
set caption(fenetre_generique,fonction_3,titre)  "Titre de la fenêtre pour la fonction 3"
set caption(fenetre_generique,parcourir)         "..."
set caption(fenetre_generique,fichier)           "Fichier"
set caption(fenetre_generique,coefficient)       "Coefficient"
set caption(fenetre_generique,ok)                "OK"
set caption(fenetre_generique,appliquer)         "Appliquer"
set caption(fenetre_generique,aide)              "Aide"
set caption(fenetre_generique,fermer)            "Fermer"

#--- Definition d'un namespace pour la fenetre generique
namespace eval ::genericWindow {

   proc run { this nom } {
      variable This

      #---
      set This $this
      if { [ info exists This ] } {
         destroy $This
      }
      ::genericWindow::createDialog $nom
      focus $This
   }

   proc createDialog { nom } {
      variable This
      global audace
      global caption
      global conf
      global genericWindow
      global help

      #--- Repertoire contenant la doc de SpcAud'ACE (a creer)
      set help(dir,doc_spc_audace) "doc_spc_audace"
      #---
      toplevel $This
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This "$caption(fenetre_generique,$nom,titre)"
      wm protocol $This WM_DELETE_WINDOW ::genericWindow::cmdClose
      #--- Initialisation des variables de changement
      set genericWindow(fichier_$nom)     ""
      set genericWindow(coefficient_$nom) ""
      #---
      #--- Frame pour la fenetre
      frame $This.usr -borderwidth 1 -relief raised
         #--- Frame pour le fichier
         frame $This.usr.a -borderwidth 0 -relief raised
            #--- Bouton Parcourir pour le fichier
            button $This.usr.a.explore -text "$caption(fenetre_generique,parcourir)" -width 1 \
               -command "::genericWindow::change_fichier $nom"
            pack $This.usr.a.explore -side left -padx 5 -pady 5 -ipady 5
            #--- Label pour le fichier
            label $This.usr.a.lab1 -text "$caption(fenetre_generique,fichier)"
            pack $This.usr.a.lab1 -side left -padx 5 -pady 5
            #--- Entry pour le fichier
            entry $This.usr.a.ent1 -textvariable genericWindow(fichier_$nom) -width 50
            pack $This.usr.a.ent1 -side right -padx 5 -pady 5
         pack $This.usr.a -side top -fill both -expand 1
         #--- Frame pour le coefficient
         frame $This.usr.b -borderwidth 0 -relief raised
            #--- Label pour le coefficient
            label $This.usr.b.label_sous_rep -text "$caption(fenetre_generique,coefficient)"
            pack $This.usr.b.label_sous_rep -side left -padx 5 -pady 5
            #--- Entry pour le coefficient
            entry $This.usr.b.ent_sous_rep -textvariable genericWindow(coefficient_$nom) -width 15
            pack $This.usr.b.ent_sous_rep -side left -padx 5 -pady 5
         pack $This.usr.b -side top -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      #--- Recuperation de la police par defaut de l'entry
      set genericWindow(rep_font) [ $This.usr.a.ent1 cget -font ]
      #--- Frame pour les boutons de controle de la fenetre
      frame $This.cmd -borderwidth 1 -relief raised
         #--- Bouton OK
         button $This.cmd.ok -text "$caption(fenetre_generique,ok)" -width 7 \
            -command "::genericWindow::cmdOk $nom"
         if { $conf(ok+appliquer)=="1" } {
           pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         #--- Bouton Appliquer
         button $This.cmd.appliquer -text "$caption(fenetre_generique,appliquer)" -width 8 \
            -command "::genericWindow::cmdApply $nom"
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         #--- Bouton Fermer
         button $This.cmd.fermer -text "$caption(fenetre_generique,fermer)" -width 7 \
            -command "::genericWindow::cmdClose"
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         #--- Bouton Aide
         button $This.cmd.aide -text "$caption(fenetre_generique,aide)" -width 7 \
            -command "::genericWindow::afficheAide $nom"
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x
      #--- La fenetre est active
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc change_fichier { nom } {
      variable This
      global caption
      global genericWindow

      #---
      set genericWindow(rep_font)        "$genericWindow(rep_font) normal"
      set genericWindow(rep_font_italic) [ lreplace $genericWindow(rep_font) 2 2 italic ]
      #---
      $This.usr.a.ent1 configure -font $genericWindow(rep_font_italic) -relief solid
      set initialdir $genericWindow(fichier_$nom)
      set title $caption(fenetre_generique,$nom,titre)
      set genericWindow(fichier_$nom) [ ::genericWindow::tkplus_chooseFile $nom $initialdir $title $This ]
      $This.usr.a.ent1 configure -textvariable genericWindow(fichier_$nom) -width 50 \
         -font $genericWindow(rep_font) -relief sunken
      focus $This.usr
   }

   proc tkplus_chooseFile { nom { inidir . } { title } { parent } } {
      variable This
      global audace
      global genericWindow

      if {$inidir=="."} {
         set inidir [pwd]
      }
      set genericWindow(fichier_$nom) [ ::tkutil::box_load $This $audace(rep_images) "1" "1" "1" ]
      if { $genericWindow(fichier_$nom) == "" } {
         return ""
      } else {
         return "$genericWindow(fichier_$nom)"
      }
   }

   proc cmdOk { nom } {
      cmdApply $nom
      cmdClose
   }

   proc cmdApply { nom } {
      global audace
      global conf
      global caption
      global genericWindow

      #--- Fonction a realiser dependant de la variable nom
      if { $nom == "fonction_1" } {
         #--- Execution de la fonction 1
         ::console::disp "SpcAud'ACE - Fonction 1 \n"
         ::console::disp "$caption(fenetre_generique,fichier) = $genericWindow(fichier_$nom) \n"
         ::console::disp "$caption(fenetre_generique,coefficient) = $genericWindow(coefficient_$nom) \n\n"
      } elseif { $nom == "fonction_2" } {
         #--- Execution de la fonction 2
         ::console::disp "SpcAud'ACE - Fonction 2 \n\n"
         ::console::disp "$caption(fenetre_generique,fichier) = $genericWindow(fichier_$nom) \n"
         ::console::disp "$caption(fenetre_generique,coefficient) = $genericWindow(coefficient_$nom) \n\n"
      } elseif { $nom == "fonction_3" } {
         #--- Execution de la fonction 3
         ::console::disp "SpcAud'ACE - Fonction 3 \n\n"
         ::console::disp "$caption(fenetre_generique,fichier) = $genericWindow(fichier_$nom) \n"
         ::console::disp "$caption(fenetre_generique,coefficient) = $genericWindow(coefficient_$nom) \n\n"
      }
   }

   proc afficheAide { nom } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,doc_spc_audace)" "doc_$nom.htm"
   }

   proc cmdClose { } {
      variable This
      global genericWindow

      set genericWindow(geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

}

