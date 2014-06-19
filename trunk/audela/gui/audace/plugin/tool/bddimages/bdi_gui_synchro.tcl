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
           -yscrollcommand "$::bdi_tools_synchro::rapport.yscroll set" \
           -wrap none
      pack $::bdi_tools_synchro::rapport -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_tools_synchro::rapport.yscroll -orient vertical -cursor arrow -command "$::bdi_tools_synchro::rapport yview"
      pack $::bdi_tools_synchro::rapport.yscroll -side right -fill y

      $::bdi_tools_synchro::rapport delete 0.0 end
      
      ::bdi_tools_synchro::launch_socket
   }







   proc ::bdi_gui_synchro::client {  } {
      
      destroy .synchro

      set ::bdi_tools_synchro::param_check_nothing 1
      set ::bdi_tools_synchro::param_check_maj_client 1
      set ::bdi_tools_synchro::param_check_maj_server 1
      set ::bdi_tools_synchro::param_check_exist 0
      set ::bdi_tools_synchro::param_check_error 1

      # maison
      set ::bdi_tools_synchro::address 192.168.0.60

      # local
      set ::bdi_tools_synchro::address localhost

      # 
      set ::bdi_tools_synchro::address 193.48.190.
      
      # metis
      set ::bdi_tools_synchro::address 193.48.190.89

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

      frame $frm.setup -borderwidth 0 -cursor arrow -relief groove
      pack $frm.setup -in $frm -anchor w -side top 

             entry $frm.setup.address -textvariable ::bdi_tools_synchro::address
             pack $frm.setup.address -in $frm.setup -anchor w -side top 
             
      frame $frm.buttons -borderwidth 0 -cursor arrow -relief groove
      pack $frm.buttons -in $frm -anchor w -side top 

             button $frm.buttons.connect -state active -text "Connect" -relief "raised" \
                -command "::bdi_tools_synchro::connect_to_socket"

             button $frm.buttons.ping -state active -text "Ping" -relief "raised" \
                -command "::bdi_tools_synchro::ping_socket"

             button $frm.buttons.check -state active -text "Check" -relief "raised" \
                -command "::bdi_gui_synchro::check_synchro"

             button $frm.buttons.synchro -state active -text "Synchro" -relief "raised" \
                -command "::bdi_tools_synchro::launch_synchro"

             button $frm.buttons.stop -state active -text "STOP" -relief "raised" \
                -command "::bdi_tools_synchro::stop_synchro"

             pack $frm.buttons.connect -expand no -side left
             pack $frm.buttons.ping    -expand no -side left
             pack $frm.buttons.check   -expand no -side left
             pack $frm.buttons.synchro -expand no -side left
             pack $frm.buttons.stop    -expand no -side left

      set ::bdi_tools_synchro::buttons_synchro $frm.buttons.synchro


      set onglets [frame $frm.onglets]
      pack $onglets -in $frm  -expand yes -fill both


            pack [ttk::notebook $onglets.nb] -expand yes -fill both 
            set f_param [frame $onglets.nb.f_param]
            set f_log   [frame $onglets.nb.f_log]
            set f_liste [frame $onglets.nb.f_liste]

            $onglets.nb add $f_param -text "Parametres"
            $onglets.nb add $f_log   -text "Logs"
            $onglets.nb add $f_liste -text "Liste"

            ttk::notebook::enableTraversal $onglets.nb

         set param [frame $f_param.frm  -borderwidth 1 -relief groove]
         pack $param -in $f_param -expand yes -fill both
         set ::bdi_tools_synchro::param_frame $param

            checkbutton $param.nothing -highlightthickness 0 -text "Ne rien faire" \
                        -variable ::bdi_tools_synchro::param_check_nothing \
                        -command "::bdi_gui_synchro::param_check nothing"
                        
            checkbutton $param.maj_client -highlightthickness 0 -text "Mise a jour du client" \
                        -variable ::bdi_tools_synchro::param_check_maj_client \
                        -state disabled \
                        -command "::bdi_gui_synchro::param_check maj_client"

            checkbutton $param.maj_server -highlightthickness 0 -text "Mise a jour du serveur" \
                        -variable ::bdi_tools_synchro::param_check_maj_server \
                        -state disabled \
                        -command "::bdi_gui_synchro::param_check maj_server"

            checkbutton $param.exist -highlightthickness 0 -text "Si le fichier existe ne rien faire" \
                        -variable ::bdi_tools_synchro::param_check_exist \
                        -state disabled \
                        -command "::bdi_gui_synchro::param_check exist"

            checkbutton $param.erreur -highlightthickness 0 -text "Continu la synchro si erreur" \
                        -variable ::bdi_tools_synchro::param_check_error\
                        -state normal 

 
            grid $param.nothing      -sticky nsw 
            grid $param.maj_client   -sticky nsw 
            grid $param.maj_server   -sticky nsw  
            grid $param.exist        -sticky nsw 
            grid $param.erreur       -sticky nsw 

         set logs [frame $f_log.frm  -borderwidth 1 -relief groove]
         pack $logs -in $f_log -expand yes -fill both

            set ::bdi_tools_synchro::rapport $logs.text
            text $::bdi_tools_synchro::rapport -height 30 -width 80 \
                 -yscrollcommand "$::bdi_tools_synchro::rapport.yscroll set" \
                 -wrap none
            pack $::bdi_tools_synchro::rapport -expand yes -fill both -padx 5 -pady 5

            scrollbar $::bdi_tools_synchro::rapport.yscroll -orient vertical -cursor arrow -command "$::bdi_tools_synchro::rapport yview"
            pack $::bdi_tools_synchro::rapport.yscroll -side right -fill y

            $::bdi_tools_synchro::rapport delete 0.0 end

         set liste [frame $f_liste.frm  -borderwidth 1 -relief groove]
         pack $liste -in $f_liste -expand yes -fill both

# $cpt "TODO" "S->C" "FITS" $f_e $tab_server_f_m($f) $tab_server_f_s($f) $f "" ""
            set cols [list 0  "Id"        right \
                           15 "Status"    left \
                           0  "Synchro"   left \
                           0  "Type"      right \
                           0  "Exist"     left \
                           0  "Date"      left \
                           0  "Size (o)"  right \
                           0  "Filename"  left \
                           8  "Duration"  right \
                           30 "ErrLog"    left \
                     ]
            
            set ::bdi_gui_synchro::liste $liste.tab
            tablelist::tablelist $::bdi_gui_synchro::liste \
               -columns $cols \
               -labelcommand tablelist::sortByColumn \
               -yscrollcommand [ list $liste.vsb set ] \
               -selectmode extended \
               -activestyle none \
               -stripebackground "#e0e8f0" \
               -showseparators 1

            #--- Scrollbars verticale et horizontale
            scrollbar $liste.vsb -orient vertical -command [list $::bdi_gui_synchro::liste yview]
            pack $liste.vsb -in $liste -side left -fill y

            menu $liste.popupTbl -title "Actions"
            $liste.popupTbl add command -label "Voir le chemin dans la console" \
                -command { ::bdi_gui_synchro::file_in_console }

            bind [$::bdi_gui_synchro::liste bodypath] <ButtonPress-3> [ list tk_popup $liste.popupTbl %X %Y ]

            pack $::bdi_gui_synchro::liste -in $liste -expand yes -fill both
            #--- Gestion des evenements
            #bind [$tbl bodypath] <Control-Key-a> [ list ::cata_gestion_gui::selectall $tbl ]
            #bind $tbl <<ListboxSelect>>          [ list ::cata_gestion_gui::cmdButton1Click %W ]
            #bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
            #bind [$tbl bodypath] <Key-u>         [ list ::cata_gestion_gui::unset_flag $tbl ]
            $::bdi_gui_synchro::liste columnconfigure 0 -sortmode dictionary
            $::bdi_gui_synchro::liste columnconfigure 6 -sortmode dictionary
            
      #::bdi_tools_synchro::connect_to_socket
   }


   proc ::bdi_gui_synchro::file_in_console {  } {

      global bddconf

      foreach select [$::bdi_gui_synchro::liste curselection] {
         set data [$::bdi_gui_synchro::liste get $select]
         set id [lindex $data 0]
         set file [lindex $data 7]
         set file [file join $bddconf(dirbase) $file]
         gren_info "set file $file\n"
      }
      gren_info "file exists \$file\n"
      return
   }


   proc ::bdi_gui_synchro::check_synchro {  } {

      ::bdi_tools_synchro::check_synchro

      set tt0 [clock clicks -milliseconds]
      ::bdi_gui_synchro::affich_synchro
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage de la tablelist en $tt sec\n"
   }

   proc ::bdi_gui_synchro::affich_synchro { } {

      $::bdi_gui_synchro::liste delete 0 end

      if {[llength $::bdi_tools_synchro::todolist]>0} {
         set cpt 0
         foreach l $::bdi_tools_synchro::todolist {
            $::bdi_gui_synchro::liste insert end $l
            incr cpt
         }
      }
   }




   proc ::bdi_gui_synchro::param_check { but } {

      set param $::bdi_tools_synchro::param_frame
      set state_but [$param.$but cget -state]

      gren_info "--\n"
      gren_info "but = $but\n"
      gren_info "param_check_nothing = $::bdi_tools_synchro::param_check_nothing\n"
      gren_info "state_but = $state_but\n"
   
      if {$but=="nothing"&&$::bdi_tools_synchro::param_check_nothing==0} {
         $param.maj_client configure -state normal
         $param.maj_server configure -state normal
         $param.exist configure -state normal
      }
      if {$but=="nothing"&&$::bdi_tools_synchro::param_check_nothing==1} {
         $param.maj_client configure -state disabled
         $param.maj_server configure -state disabled
         $param.exist configure -state disabled
      }
   }



