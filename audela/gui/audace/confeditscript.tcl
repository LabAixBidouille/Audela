#
# Fichier : confeditscript.tcl
# Description : Fenetre de configuration pour parametrer les differents editeurs
# Mise a jour $Id: confeditscript.tcl,v 1.2 2006-06-20 17:25:11 robertdelmas Exp $
#

namespace eval ::confEditScript {
   variable This
   global confgene

   #
   # confEditScript::run this
   # Cree la fenetre de configuration de l'editeur de scripts, de fichiers pdf, de pages html et d'images
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This
      global conf
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

   proc createDialog { } {
      variable This
      global conf
      global audace
      global caption
      global confgene
      global color

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
      wm protocol $This WM_DELETE_WINDOW ::confEditScript::fermer

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
         button $This.usr1.explore1 -text "$caption(confeditscript,parcourir)" -width 1 \
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
         button $This.usr2.explore2 -text "$caption(confeditscript,parcourir)" -width 1 \
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
         button $This.usr3.explore3 -text "$caption(confeditscript,parcourir)" -width 1 \
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
         button $This.usr4.explore4 -text "$caption(confeditscript,parcourir)" -width 1 \
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
         button $This.cmd.ok -text "$caption(confeditscript,ok)" -width 7 -command ::confEditScript::ok
         pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Fermer'
         button $This.cmd.fermer -text "$caption(confeditscript,fermer)" -width 7 -command ::confEditScript::fermer
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Aide' 
         button $This.cmd.aide -text "$caption(confeditscript,aide)" -width 7 -command ::confEditScript::afficheAide
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc updateData { } {
      global conf
      global confgene

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

   proc destroyDialog { } {
      variable This
      global confgene

      set confgene(EditScript,geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

   proc ok { } {
      global conf
      global confgene

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

   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1030editeur.htm"
   }

   proc fermer { } {
      variable This
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

