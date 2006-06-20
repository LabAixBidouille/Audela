#
# Fichier : newscript.tcl
# Description : Creation d'un script nouveau
# Mise a jour $Id: newscript.tcl,v 1.2 2006-06-20 17:33:07 robertdelmas Exp $
#

namespace eval ::newScript {
   variable This
   variable Filename
   global newScript

   proc run { this } {
      variable This
      variable Filename
      global audace
      global caption
      global newScript

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
      tkwait variable newScript
      if { $newScript == "0" } {
         return [ list 0 "" ]
      } else {
         return [ list 1 $Filename ]
      }
   }

   proc createDialog { this } {
      variable This
      global audace
      global conf
      global caption
      global newScript

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
      wm protocol $This WM_DELETE_WINDOW ::newScript::annuler

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
         button $This.frame2.ok -text "$caption(newscript,ok)" -width 8 -command { ::newScript::ok }
         pack $This.frame2.ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
         #--- Cree le bouton 'Annuler'
         button $This.frame2.annuler -text "$caption(newscript,annuler)" -width 8 -command { ::newScript::annuler }
         pack $This.frame2.annuler -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5
         #--- Cree le bouton 'Aide' 
         button $This.frame2.aide -text "$caption(newscript,aide)" -width 8 -command { ::newScript::afficheAide }
         pack $This.frame2.aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5
         #--- Commandes associees
         bind $This <Key-Return> newScript::ok
         bind $This <Key-Escape> newScript::annuler
      pack $This.frame2 -side top -fill x

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc destroyDialog { } {
      variable This

      set newScript(geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

   proc ok { } {
      global newScript

      set newScript 1
      ::newScript::destroyDialog
   }

   proc afficheAide {} {
      global help
 
      ::audace::showHelpItem "$help(dir,fichier)" "1050nouveau_script.htm"
   }

   proc annuler { } {
      global newScript

      set newScript 0
      ::newScript::destroyDialog
   }

}

