#--------------------------------------------------
# source bdi_gui_synchro.tcl
#--------------------------------------------------
#
# Fichier        : bdi_gui_synchro.tcl
# Description    : Environnement de synchronisation des bases
#                  pour des images qui ont un cata
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: bdi_gui_synchro.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval bdi_gui_synchro {

}


   proc ::bdi_gui_synchro::stop {  } {
      set ::bdi_tools_synchro::stop 1
   }


   proc ::bdi_gui_synchro::go {  } {

      gren_info "Lancement de la synchronisation des bases\n"
      ::bdi_tools_synchro::go

   }



   proc ::bdi_gui_synchro::run {  } {
      

      set fen .synchro
      set ::bdi_gui_astroid::fen $fen
      if { [winfo exists $fen] } {
         wm withdraw $fen
         wm deiconify $fen
         focus $fen
         return
      }
      toplevel $fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
      wm geometry $fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $fen 1 1
      wm title $fen "Synchronisation"
      wm protocol $fen WM_DELETE_WINDOW "destroy .synchro"

      set frm $fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

             label $frm.txt -text "Synchronisation des Bases de Donnees\nChoisir de quel coté du socket voulez vous etre :" 

             button $frm.serveur -state active -text "Serveur" -relief "raised" \
                -command "::bdi_gui_synchro::serveur"
             button $frm.client -state active -text "Client" -relief "raised" \
                -command "::bdi_gui_synchro::client"

             grid $frm.txt -row 0 -column 0 -sticky news -padx 10 -pady 5 -columnspan 2

             grid $frm.serveur -row 1 -column 0 -sticky news -padx 10 -pady 5
             grid $frm.client  -row 1 -column 1 -sticky news -padx 10 -pady 5


   }

   proc ::bdi_gui_synchro::serveur {  } {
      
      destroy .synchro

      set fen .synchroserv
      set ::bdi_gui_astroid::fen $fen
      if { [winfo exists $fen] } {
         wm withdraw $fen
         wm deiconify $fen
         focus $fen
         return
      }
      toplevel $fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
      wm geometry $fen 800x500+165+55
      wm resizable $fen 1 1
      wm title $fen "Synchronisation Serveur Log"
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"

      set frm $fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5


      frame $frm.buttons -borderwidth 0 -cursor arrow -relief groove
      pack $frm.buttons -in $frm -anchor w -side top 

             button $frm.buttons.close -state active -text "Close" -relief "raised" \
                -command "::bdi_tools_synchro::close_socket"
             button $frm.buttons.reopen -state active -text "Re-Open" -relief "raised" \
                -command "::bdi_tools_synchro::reopen_socket"

             pack $frm.buttons.close  -expand no -side left
             pack $frm.buttons.reopen -expand no -side left



      set ::bdi_tools_synchro::rapport $frm.text
      text $::bdi_tools_synchro::rapport -height 30 -width 80 \
           -xscrollcommand "$::bdi_tools_synchro::rapport.xscroll set" \
           -yscrollcommand "$::bdi_tools_synchro::rapport.yscroll set" \
           -wrap none
      pack $::bdi_tools_synchro::rapport -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_tools_synchro::rapport.xscroll -orient horizontal -cursor arrow -command "$::bdi_tools_synchro::rapport xview"
      pack $::bdi_tools_synchro::rapport.xscroll -side bottom -fill x

      scrollbar $::bdi_tools_synchro::rapport.yscroll -orient vertical -cursor arrow -command "$::bdi_tools_synchro::rapport yview"
      pack $::bdi_tools_synchro::rapport.yscroll -side right -fill y

      $::bdi_tools_synchro::rapport delete 0.0 end
      
      ::bdi_tools_synchro::launch_socket
   }

