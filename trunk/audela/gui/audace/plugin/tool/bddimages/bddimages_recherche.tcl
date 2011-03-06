#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_recherche.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_recherche.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace bddimages_recherche
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_recherche.cap
#
#--------------------------------------------------

namespace eval bddimages_recherche {

   global audace
   global bddconf

#--------------------------------------------------
# run { this }
#--------------------------------------------------
#
#    fonction  :
#        Creation de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#        @param this = chemin de la fenetre
#
#    variables en sortie :
#        @return
#
#--------------------------------------------------

   proc run { this } {
      variable This

      set entetelog "recherche"
      set This $this
      createDialog
      return
   }

#--------------------------------------------------
# fermer { }
#--------------------------------------------------
#
#    fonction  :
#        Fonction appellee lors de l'appui
#        sur le bouton 'Fermer'
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
   proc fermer { } {
      variable This

      ::bddimages_recherche::recup_position
      destroy $This
      return
   }



#--------------------------------------------------
#  recup_position { }
#--------------------------------------------------
#
#    fonction  :
#       Permet de recuperer et de sauvegarder
#       la position de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
   proc recup_position { } {
      variable This
      global audace
      global conf
      global bddconf

      set bddconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
      set fin [ string length $bddconf(geometry_status) ]
      set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
      #---
      set conf(bddimages,position_status) $bddconf(position_status)
      return
   }


#--------------------------------------------------
#  affiche_image_by_idbddimg { id }
#--------------------------------------------------
#
#    fonction  :
#       Permet d afficher l image d un fichier
#       selectionné
#
#    procedure externe :
#        charge $fp : $fp est le chemin de l image sur le disque
#
#    variables en entree :
#        @param id = identification de l image dans la base de donnees
#
#    variables en sortie :
#
#--------------------------------------------------
   proc affiche_image_by_idbddimg { id } {
     
      set sqlcmd "SELECT dirfilename,filename FROM images WHERE idbddimg = $id"
      set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$msg" -type ok
         return
      }

      set nbresult [llength $resultcount]
      set colvar [lindex $resultcount 0]
      set rowvar [lindex $resultcount 1]
      set nbcol  [llength $colvar]
      set line [lindex $rowvar 0]
      set fp [file join $::bddconf(dirbase) [lindex $line 0] [lindex $line 1] ]
      set bufno $::bddconf(bufno)
      charge $fp
      return
   }


#--------------------------------------------------
#  affiche_image { }
#--------------------------------------------------
#
#    fonction  :
#       Permet d afficher l image d un fichier
#       selectionne par clic dans la liste du tk 
#
#    procedure externe :
#        affiche_image_by_idbddimg $id : $id = identification de l image dans la base de donnees
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
   proc affiche_image { } {
      variable This
      global audace
      global conf
      global bddconf

      set i [lindex [$::bddimages_recherche::This.frame6.result.tbl curselection ]  0]
      set idbddimg  [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]

      affiche_image_by_idbddimg $idbddimg
      ###for { set i 0 } { $i <= [ expr [llength $bddconf(listetotale)] - 1 ] } { incr i } {
      ### set selectfich [$::bddimages_recherche::This.frame6.result.tbl selection includes $i]
      ###  if {$selectfich==1} {
      ###     set nomfich [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 1]
      ###     set errnum [ catch { loadima $nomfich } msg ]
      ###     if { $errnum == "1" } {
      ###        tk_messageBox -message "$msg" -icon error
      ###     }
      ###     return # affiche seulement le premier fichier selectionné et sort de la procedure
      ###  }
      ###}
      return
   }


#--------------------------------------------------
#  cmd_list_select { }
#--------------------------------------------------
#
#    fonction  :
#       Affiche les elements d une liste, selectionnee dans le frame list
#       par clic dans la liste du tk 
#
#    procedure externe :
#        get_intellilist_by_name
#        get_list
#        Affiche_Results
#
#    variables en entree :
#        @param tbl = entree tk
#
#    variables en sortie :
#
#--------------------------------------------------

   proc ::bddimages_recherche::cmd_list_select { tbl } {

      variable ::bddimages_recherche::current_list_name
      variable ::bddimages_recherche::current_list_id
      variable ::bddimages_recherche::tbl_cmd_list_select

      set ::bddimages_recherche::tbl_cmd_list_select $tbl
      set i [$tbl curselection]
      set row [$tbl get $i $i]
      set ::bddimages_recherche::current_list_name [lindex $row 0]
      set ::bddimages_recherche::current_list_id [::bddimages_liste::get_intellilist_by_name $::bddimages_recherche::current_list_name]

      ::console::affiche_resultat "Chargement ... "

      set t0 [clock clicks -milliseconds]
      ::bddimages_recherche::get_list $::bddimages_recherche::current_list_id

      set t1 [clock clicks -milliseconds]
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id      

      set t2 [clock clicks -milliseconds]
      set sec [expr ($t1-$t0)/1000.]
      ::console::affiche_resultat "SQL: $sec sec ..."
      set sec [expr ($t2-$t1)/1000.]
      ::console::affiche_resultat "AFF: $sec sec .\n"

      return
   }

#--------------------------------------------------
#  cmd_list_delete { }
#--------------------------------------------------
#
#    fonction  :
#       Supprime un element d une liste, selectionnee dans le frame list
#       par clic dans la liste du tk 
#
#    procedure externe :
#        get_intellilist_by_name
#        Affiche_listes
#        conf_save_intellilists
#
#    variables en entree :
#        @param tbl = entree tk
#
#    variables en sortie :
#
#--------------------------------------------------
   proc cmd_list_delete { tbl } {
      set i [$tbl curselection]
      set row [$tbl get $i $i]
      set name [lindex $row 0]
      set num [::bddimages_liste::get_intellilist_by_name $name]
      for { set i 0 } { $i < $::nbintellilist } { incr i } {
         set ::intellilisttotal($i) $::intellilisttotal([expr $i+1])
         }
      set ::nbintellilist [expr $::nbintellilist - 1]
      ::bddimages_recherche::Affiche_listes
      ::bddimages_liste::conf_save_intellilists
      return
   }

#--------------------------------------------------
#  createDialog { }
#--------------------------------------------------
#
#    fonction  :
#       Creation de l'interface graphique
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------


# |-fenetre-----------------------------------|
# |                                           |
# | |-menu---------------------------------|  |
# | |                                      |  |
# | |--------------------------------------|  |
# |                                           |
# | |-boutons------------------------------|  |
# | |                                      |  |
# | |--------------------------------------|  |
# |                                           |
# | |-table--------------------------------|  |
# | |                                      |  |
# | | |-liste---| |-images---------------| |  |
# | | |	       | |			              | |  |
# | | |	       | |			              | |  |
# | | |	       | |	             	     | |  |
# | | |	       | |		                 | |  |
# | | |	       | |             			  | |  |
# | | |         | |	                    | |  |
# | | |	       | |	                    | |  |
# | | |---------| |----------------------| |  |
# | |                                      |  |
# | |--------------------------------------|  |
# |                                           |
# | |-frame2-------------------------------|  |
# | |                                      |  |
# | |--------------------------------------|  |
# |                                           |
# |-------------------------------------------|

   proc createDialog { } {

      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf

      global nbintellilist
      global intellilisttotal
      global action_frame_type
      global action_frame_state
      global action_label

      #--- initConf
      if { ! [ info exists conf(bddimages,position_status) ] } { set conf(bddimages,position_status) "+100+100" }

      #--- confToWidget
      set bddconf(position_status) $conf(bddimages,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists bddconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
         set fin [ string length $bddconf(geometry_status) ]
         set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
      }

      if {! [ info exists bddconf(current_config)]} {
         # Charge les config bddimages depuis le fichier XML
         set err [::bddimagesXML::load_xml_config]
         # Recupere la liste des bddimages disponibles
         set bddconf(list_config) $::bddimagesXML::list_bddimages
         # Recupere la config par defaut [liste id name]
         set bddconf(default_config) $::bddimagesXML::default_config
         # Recupere la config par courante [liste id name]
         set bddconf(current_config) $::bddimagesXML::current_config
         ::console::affiche_resultat "list_config = $bddconf(list_config) \n"
         ::console::affiche_resultat "default_config = $bddconf(default_config) \n"
         ::console::affiche_resultat "current_config = $bddconf(current_config) \n"
      }

      set nbintellilist 0
      if { [catch {::bddimages_liste::conf_load_intellilists } msg] } {
         tk_messageBox -message "$msg" -type ok
         return
      }

      # Message d'info pour demander la creation d'au moins une liste
      if {$nbintellilist == 0} {
         tk_messageBox -message "$caption(bddimages_recherche,nointelist)" -type ok
      }
      
      set bddconf(inserinfo) "Total($nbintellilist)"

      # Definitions des boutons d'action: par defaut tout a 1
      array set action_label {
         img      1
         flat     1
         dark     1
         offset   1
         unktype  1
         raw      1
         corr     1
         unkstate 1
      }
      # Definition des icones des boutons d'action
      #--- IMG
      image create photo icon_yes_img
      icon_yes_img configure -file [file join $audace(rep_plugin) tool bddimages icons yes_img.gif]
      image create photo icon_no_img
      icon_no_img configure -file [file join $audace(rep_plugin) tool bddimages icons no_img.gif]
      #--- FLAT
      image create photo icon_yes_flat
      icon_yes_flat configure -file [file join $audace(rep_plugin) tool bddimages icons yes_flat.gif]
      image create photo icon_no_flat
      icon_no_flat configure -file [file join $audace(rep_plugin) tool bddimages icons no_flat.gif]
      #--- DARK
      image create photo icon_yes_dark
      icon_yes_dark configure -file [file join $audace(rep_plugin) tool bddimages icons yes_dark.gif]
      image create photo icon_no_dark
      icon_no_dark configure -file [file join $audace(rep_plugin) tool bddimages icons no_dark.gif]
      #--- OFFSET
      image create photo icon_yes_offset
      icon_yes_offset configure -file [file join $audace(rep_plugin) tool bddimages icons yes_offset.gif]
      image create photo icon_no_offset
      icon_no_offset configure -file [file join $audace(rep_plugin) tool bddimages icons no_offset.gif]
      #--- UNKNOWN
      image create photo icon_yes_unk
      icon_yes_unk configure -file [file join $audace(rep_plugin) tool bddimages icons yes_unk.gif]
      image create photo icon_no_unk
      icon_no_unk configure -file [file join $audace(rep_plugin) tool bddimages icons no_unk.gif]
      #--- CORR
      image create photo icon_yes_corr
      icon_yes_corr configure -file [file join $audace(rep_plugin) tool bddimages icons yes_corr.gif]
      image create photo icon_no_corr
      icon_no_corr configure -file [file join $audace(rep_plugin) tool bddimages icons no_corr.gif]
      #--- RAW
      image create photo icon_yes_raw
      icon_yes_raw configure -file [file join $audace(rep_plugin) tool bddimages icons yes_raw.gif]
      image create photo icon_no_raw
      icon_no_raw configure -file [file join $audace(rep_plugin) tool bddimages icons no_raw.gif]

      #--- Lecture des champs de la table

         #---
         toplevel $This -class Toplevel
         wm geometry $This $bddconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(bddimages_recherche,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_recherche::fermer }

         #--- Cree un menu pour le panneau
         frame $This.frame0 -borderwidth 1 -relief raised
         pack $This.frame0 -side top -fill x
         
           #--- menu Fichier
           menubutton $This.frame0.file -text "$caption(search,fichier)" -underline 0 -menu $This.frame0.file.menu
  
             menu $This.frame0.file.menu

             $This.frame0.file.menu add command -label "$caption(bddimages_recherche,new_list_i)" -command { ::bddimages_liste::run $audace(base).bddimages_liste }
             $This.frame0.file.menu add command -label "$caption(bddimages_recherche,new_list_n)" -command { ::bddimages_liste::runnormal $audace(base).bddimages_liste }
             #$This.frame0.file.menu add command -label "$caption(bddimages_recherche,delete_list)" -command " ::bddimages_recherche::cmd_list_delete $This.frame6.liste.tbl "
             # $This.frame0.file.menu add separator
             # $This.frame0.file.menu add command -label "$caption(search,ouvre)" -command {  }
             # $This.frame0.file.menu add command -label "$caption(search,sauve)" -command {  }
             # $This.frame0.file.menu add command -label "$caption(search,sauvess)" -command {  }
             # $This.frame0.file.menu add command -label "$caption(search,fermer_B)" -command {  }

           pack $This.frame0.file -side left

           #--- menu Image
           menubutton $This.frame0.image -text "$caption(search,image)" -underline 0 -menu $This.frame0.image.menu
           menu $This.frame0.image.menu
             $This.frame0.image.menu add command -label "$caption(search,charge)" -command { ::bddimages_recherche::affiche_image }
             $This.frame0.image.menu add command -label [concat "$caption(search,entete_FITS) (Ctrl+f)"] \
                                               -command { }
           pack $This.frame0.image -side left
           #--- menu aide
           menubutton $This.frame0.aide -text "$caption(search,aide)" -underline 0 -menu $This.frame0.aide.menu
           menu $This.frame0.aide.menu
             $This.frame0.aide.menu add command -label "$caption(search,aide)" -command { }
             $This.frame0.aide.menu add separator
             $This.frame0.aide.menu add command -label "$caption(search,code_uai)" -command {  }
             # $This.frame0.aide.menu add separator
             # $This.frame0.aide.menu add command -label "$caption(search,apropos)" -command { ::skybot_Search::apropos }
           pack $This.frame0.aide -side right
         
         #--- barre de menu
             tk_menuBar $This.frame0 $This.frame0.file $This.frame0.image $This.frame0.aide


         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x

           #--- Cree un label pour le titre
           label $This.frame1.titre -font $bddconf(font,arial_10_b) \
                 -text "$caption(bddimages_recherche,titre)"
           pack $This.frame1.titre -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour afficher les boutons d'actions
           set action_frame [frame $This.frame1.action -borderwidth 1 -cursor arrow -padx 5]
           pack $This.frame1.action -in $This.frame1 -side top -expand 1 -fill x
              
               #--- Boutons ACTIONS TYPE
               set action_frame_type [frame $This.frame1.action.type -borderwidth 1 -cursor arrow]
               pack $This.frame1.action.type -in $This.frame1.action -side right -expand 0 -fill x
               #----- UNKNOWN
               button $This.frame1.action.type.unknown -state active -relief sunken -image icon_yes_unk \
                  -command { if {$action_label(unktype) == 1} {
                                set action_label(unktype) 0
                                $action_frame_type.unknown configure -relief "raised" -image icon_no_unk
                             } else {
                                set action_label(unktype) 1 
                                $action_frame_type.unknown configure -relief "sunken" -image icon_yes_unk
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.type.unknown -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.unknown -text $caption(bddimages_recherche,button_unktype)
               #----- OFFSET
               button $This.frame1.action.type.offset -state active -relief sunken -image icon_yes_offset \
                  -command { if {$action_label(offset) == 1} {
                                set action_label(offset) 0
                                $action_frame_type.offset configure -relief "raised" -image icon_no_offset
                             } else {
                                set action_label(offset) 1 
                                $action_frame_type.offset configure -relief "sunken" -image icon_yes_offset
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.type.offset -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.offset -text $caption(bddimages_recherche,button_offset)
               #----- DARK
               button $This.frame1.action.type.dark -state active -relief sunken -image icon_yes_dark \
                  -command { if {$action_label(dark) == 1} {
                                set action_label(dark) 0
                                $action_frame_type.dark configure -relief "raised" -image icon_no_dark
                             } else {
                                set action_label(dark) 1 
                                $action_frame_type.dark configure -relief "sunken" -image icon_yes_dark
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.type.dark -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.dark -text $caption(bddimages_recherche,button_dark)
               #----- FLAT
               button $This.frame1.action.type.flat -state active -relief sunken -image icon_yes_flat \
                  -command { if {$action_label(flat) == 1} {
                                set action_label(flat) 0
                                $action_frame_type.flat configure -relief "raised" -image icon_no_flat
                             } else {
                                set action_label(flat) 1 
                                $action_frame_type.flat configure -relief "sunken" -image icon_yes_flat
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.type.flat -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.flat -text $caption(bddimages_recherche,button_flat)
               #----- IMG
               button $This.frame1.action.type.img -state active -relief sunken -image icon_yes_img \
                  -command { if {$action_label(img) == 1} {
                                set action_label(img) 0
                                $action_frame_type.img configure -relief "raised" -image icon_no_img
                             } else {
                                set action_label(img) 1 
                                $action_frame_type.img configure -relief "sunken" -image icon_yes_img
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.type.img -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.img -text $caption(bddimages_recherche,button_img)
               
               #--- Label ACTIONS TYPE
               label $This.frame1.action.type.label -text "TYPE: "
               pack $This.frame1.action.type.label -in $This.frame1.action.type -side right -anchor w -padx 5

               #--- Boutons ACTIONS STATES
               set action_frame_state [frame $This.frame1.action.state -borderwidth 1 -cursor arrow]
               pack $This.frame1.action.state -in $This.frame1.action -side right -expand 0 -fill x
               #----- UNKNOWN
               button $This.frame1.action.state.unknown -state active -relief sunken -image icon_yes_unk \
                  -command { if {$action_label(unkstate) == 1} {
                                set action_label(unkstate) 0
                                $action_frame_state.unknown configure -relief "raised" -image icon_no_unk
                             } else {
                                set action_label(unkstate) 1 
                                $action_frame_state.unknown configure -relief "sunken" -image icon_yes_unk
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.state.unknown -in $This.frame1.action.state -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.state.unknown -text $caption(bddimages_recherche,button_unkstate)
               #----- CORR
               button $This.frame1.action.state.corr -state active -relief sunken -image icon_yes_corr \
                  -command { if {$action_label(corr) == 1} {
                                set action_label(corr) 0
                                $action_frame_state.corr configure -relief "raised" -image icon_no_corr
                             } else {
                                set action_label(corr) 1 
                                $action_frame_state.corr configure -relief "sunken" -image icon_yes_corr
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.state.corr -in $This.frame1.action.state -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.state.corr -text $caption(bddimages_recherche,button_corr)
               #----- RAW
               button $This.frame1.action.state.raw -state active -relief sunken -image icon_yes_raw \
                  -command { if {$action_label(raw) == 1} {
                                set action_label(raw) 0
                                $action_frame_state.raw configure -relief "raised" -image icon_no_raw
                             } else {
                                set action_label(raw) 1 
                                $action_frame_state.raw configure -relief "sunken" -image icon_yes_raw
                             }
                             ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
                           }
               pack $This.frame1.action.state.raw -in $This.frame1.action.state -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.state.raw -text $caption(bddimages_recherche,button_raw)
               
               #--- Label ACTIONS TYPE
               label $This.frame1.action.state.label -text "STATE: "
               pack $This.frame1.action.state.label -in $This.frame1.action.state -side right -anchor w -padx 5

        #--- Cree un frame pour l'affichage des deux listes
        frame $This.frame6 -borderwidth 0
        pack $This.frame6 -expand yes -fill both -padx 3 -pady 6


	 #--- Cree un frame pour l'affichage de la liste des results
	 frame $This.frame6.result -borderwidth 0 -background white
	 pack $This.frame6.result -expand yes -fill both -padx 3 -pady 6 -in $This.frame6 -side right -anchor e

            #--- Cree un acsenseur vertical
            scrollbar $This.frame6.result.vsb -orient vertical \
               -command { $::bddimages_recherche::This.frame6.result.lst1 yview } -takefocus 1 -borderwidth 1
            pack $This.frame6.result.vsb \
               -in $This.frame6.result -side right -fill y

            #--- Cree un acsenseur horizontal
            scrollbar $This.frame6.result.hsb -orient horizontal \
               -command { $::bddimages_recherche::This.frame6.result.lst1 xview } -takefocus 1 -borderwidth 1
            pack $This.frame6.result.hsb \
               -in $This.frame6.result -side bottom -fill x

            #--- Creation de la table
            ::bddimages_recherche::createTbl1 $This.frame6.result
            pack $This.frame6.result.tbl -in $This.frame6.result -expand yes -fill both


        #--- Cree un frame pour l'affichage de la liste des images
        frame $This.frame6.liste -borderwidth 0
        pack $This.frame6.liste -expand yes -fill both -padx 3 -pady 6 -in $This.frame6


            #--- Cree un acsenseur vertical
            scrollbar $This.frame6.liste.vsb -orient vertical \
               -command { $::bddimages_recherche::This.frame6.liste.lst1 yview } -takefocus 1 -borderwidth 1
            pack $This.frame6.liste.vsb \
               -in $This.frame6.liste -side right -fill y

            #--- Cree un acsenseur horizontal
            scrollbar $This.frame6.liste.hsb -orient horizontal \
               -command { $::bddimages_recherche::This.frame6.liste.lst1 xview } -takefocus 1 -borderwidth 1
            pack $This.frame6.liste.hsb \
               -in $This.frame6.liste -side bottom -fill x

            #--- Creation de la table
            ::bddimages_recherche::createTbl2 $This.frame6.liste
            pack $This.frame6.liste.tbl -in $This.frame6.liste -expand yes -fill both
            bind $This.frame6.liste.tbl <<ListboxSelect>> " ::bddimages_recherche::cmd_list_select $This.frame6.liste.tbl "

      
         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(bddimages_recherche,fermer)" -borderwidth 2 \
              -command { ::bddimages_recherche::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bddimages_recherche,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton lecture entete
#           button $This.frame11.but_lectentete \
#              -text "$caption(bddimages_recherche,lectentete)" -borderwidth 2 \
#              -command {lecture_info This}
#           pack $This.frame11.but_lectentete \
#              -in $This.frame11 -side right -anchor e \
#              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton insertion
#           button $This.frame11.but_insertion \
#              -text "$caption(bddimages_recherche,inser)" -borderwidth 2 \
#              -command { insertion This }
#           pack $This.frame11.but_insertion \
#              -in $This.frame11 -side right -anchor e \
#              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

#           #--- Creation du bouton insertion
#           button $This.frame11.but_refresh \
#              -text "$caption(bddimages_recherche,refresh)" -borderwidth 2 \
#              -command {
#	                 ::bddimages_recherche::init_info
#		       }
#           pack $This.frame11.but_refresh \
#              -in $This.frame11 -side right -anchor e \
#              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Cree un label pour le nb image
           label $This.frame11.nbimg -font $bddconf(font,arial_12_b) \
               -textvariable bddconf(inserinfo)
           pack $This.frame11.nbimg -in $This.frame11 -side left -padx 3 -pady 1 -anchor w

      
      Affiche_listes

      #--- Lecture des info des images

      #--- Gestion du bouton
#      $audace(base).bddimages.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
      #--- Surcharge la couleur de fond des resultats
      $This.frame6.result.tbl configure -background white
   }

#--------------------------------------------------
#  Tbl2Edit { tbl }
#--------------------------------------------------
#
#    fonction  :
#       
#	
#
#    procedure externe :
#
#    variables en entree :
#        tbl = frame tk
#
#    variables en sortie :
#
#--------------------------------------------------

   proc Tbl2Edit { tbl } {
     global audace
     set i [$tbl curselection]
     set row [$tbl get $i $i]
     set name [lindex $row 0]
     puts "Tbl2GetListName : $name"
     ::bddimages_liste::run $audace(base).bddimages_liste $name
   }
   
   
#--------------------------------------------------
#  Tbl2Delete { tbl }
#--------------------------------------------------
#
#    fonction  :
#       
#	
#
#    procedure externe :
#
#    variables en entree :
#        tbl = frame tk
#
#    variables en sortie :
#
#--------------------------------------------------

   proc Tbl2Delete { tbl } {

     global audace
     global intellilisttotal

     set i [$tbl curselection]
     set row [$tbl get $i $i]
     set name [lindex $row 0]
     #::console::affiche_resultat "i    = $i    \n"
     #::console::affiche_resultat "row  = $row  \n"
     #::console::affiche_resultat "name = $name \n"
     #::console::affiche_resultat "tbl  = $tbl \n"

      set num [::bddimages_liste::get_intellilist_by_name $name]
     #::console::affiche_resultat "num  = $num \n"
     #::console::affiche_resultat "count  =  [array get intellilisttotal] \n"
     set total [array get intellilisttotal]
     foreach intellilist $total {
        #::console::affiche_resultat "intelliliste  = $intellilist \n"
     }

     set cpt 0
     #::console::affiche_resultat "prevision effacement :\n"
     for {set x 1} {$x<=$::nbintellilist} {incr x} {

        if { [::bddimages_liste::get_val_intellilist $::intellilisttotal($x) "name"] == $name} {
           #::console::affiche_resultat "on efface $name \n"
        } else {
           incr cpt
           set ::intellilisttotal($cpt) $::intellilisttotal($x)
           #::console::affiche_resultat "[::bddimages_liste::get_val_intellilist $::intellilisttotal($x) "name"] $cpt\n"
        }
        #lappend l [list $::intellilisttotal($x)]
     }
     #::console::affiche_resultat "--\n"
     # for { set i 0 } { $i < $::nbintellilist } { incr i } {
         #set ::intellilisttotal($i) $::intellilisttotal([expr $i+1])
     #    }

      set ::nbintellilist $cpt
      ::bddimages_recherche::Affiche_listes
      ::bddimages_liste::conf_save_intellilists
      return

   }


   proc createTbl2 { frame } {
      variable This
      global audace
      global caption
      global bddconf
      global popupTbl
      global paramwindow


      set name "-?-"

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl
      set popupTbl $frame.popupTbl
      set filtres $frame.popupTbl.filtres
      set paramwindow $This.param


      #--- Table des objets
      tablelist::tablelist $tbl \
         -labelcommand ::bddimages_recherche::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none 

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table
      menu $popupTbl -title $caption(bddimages_recherche,titre)
        # Label


        $popupTbl add command -label "$caption(bddimages_recherche,new_list_i)" \
           -command { ::bddimages_liste::run $audace(base).bddimages_liste }
        # Separateur
#        proc getcurname { tbl } {
#         set i [$tbl curselection]
#         set row [$tbl get $i $i]
#         set name [lindex $row 0]
#         return $name
#        }

        # Edite la liste selectionnee
        $popupTbl add command -label "$caption(bddimages_recherche,edit)" \
           -command [list ::bddimages_recherche::Tbl2Edit $tbl ]

        # Supprime la liste selectionnee
        $popupTbl add command -label "$caption(bddimages_recherche,delete_list) : $name" \
           -command [list ::bddimages_recherche::Tbl2Delete $tbl ]

        # Separateur
        $popupTbl add separator
        
        # Acces a l'aide
        $popupTbl add command -label $caption(bddimages_recherche,aide) \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind $tbl <<ListboxSelect>>          [ list ::bddimages_recherche::cmdButton1Click $This.frame6.result ]
      bind [$tbl bodypath] <Double-ButtonPress-1> { ::bddimages_recherche::affiche_image }

   }



   proc createTbl1 { frame } {
      variable This
      global audace
      global caption
      global bddconf
      global popupTbl
      global paramwindow

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl
      set popupTbl $frame.popupTbl
      set filtres $frame.popupTbl.filtres
      set paramwindow $This.param

      #--- Table des objets
      tablelist::tablelist $tbl \
         -labelcommand ::bddimages_recherche::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table
      menu $popupTbl -title $caption(bddimages_recherche,titre)
        # Labels des objets dans l'image
        $popupTbl add command -label $caption(bddimages_recherche,selectall) \
           -command { $::bddimages_recherche::This.frame6.result.tbl selection set 0 end }
        # Separateur
        $popupTbl add separator
        # Labels charger image
        $popupTbl add command -label $caption(bddimages_recherche,voirimg) \
           -command { ::bddimages_recherche::affiche_image
                     #set numbuf [::buf::create]
                     #buf$numbuf load "$conf(bddimages,dirinco)/p41957f1.fits.gz"
                     #::visu::create $numbuf 0
                     #::audace::header
                     }
        # Labels Lire le Header
        $popupTbl add command -label $caption(bddimages_recherche,voirheader) \
           -command { ::bddimages_recherche::affiche_entete}

        # Separateur
        $popupTbl add separator

        # Labels Define
        $popupTbl add command -label $caption(bddimages_recherche,define) \
           -command { ::bddimages_recherche::bddimages_define }

        # Separateur
        $popupTbl add separator

        # Labels Effacement de l image
        $popupTbl add command -label $caption(bddimages_recherche,delete) \
           -command { ::bddimages_recherche::bddimages_images_delete }

        # Separateur
        $popupTbl add separator
 
        # Labels Associate
        $popupTbl add command -label $caption(bddimages_recherche,associate) \
           -command { ::bddimages_recherche::bddimages_associate "tmp" }

        # Separateur
        $popupTbl add separator

        # Acces a l'aide
        $popupTbl add command -label $caption(bddimages_recherche,aide) \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind $tbl <<ListboxSelect>>          [ list ::bddimages_recherche::cmdButton1Click $This.frame6.result ]
      bind [$tbl bodypath] <Double-ButtonPress-1> { ::bddimages_recherche::affiche_image }

   }



   proc ::bddimages_recherche::bddimages_associate { namelist } {
   
      global audace
      global bddconf
   
      set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set l [lsort -decreasing -integer $l]
      set associate ""
      set cpt 0
      foreach i $l {
         incr cpt
         set id [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
         lappend associate $id
         if {$cpt == 1} {
            set l "$id"
         } else {
            set l "$l,$id"
         }
      }
      if {$cpt == 0}  { return }
      
      ::console::affiche_resultat "associate = $associate\n"
   
      set sqlcmd "SELECT images.tabname,images.idbddimg FROM images
                  WHERE images.idbddimg IN ($l)
                  ORDER BY images.tabname ASC;"
      set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
         ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
         ::console::affiche_erreur "        err = $err\n"
         ::console::affiche_erreur "        msg = $msg\n"
         return
      }
      set nbresult [llength $resultcount]
      set result [lindex $resultcount 1]
      ::console::affiche_resultat "nbresult = $nbresult\n"
      ::console::affiche_resultat "result = $result\n"
   
      set ltable ""
      foreach l $result {
          set table [lindex $l 0]
          set id [lindex $l 1]
          lappend ltable $table
          lappend comp($table) $id
      }
      set ltable [lsort -unique $ltable]
     
      set idlist ""
      foreach t $ltable {
         ::console::affiche_resultat "table = $t\n"
         set il ""
         foreach i $comp($t) {
            lappend il $i
            ::console::affiche_resultat "$i "
         }
         lappend idlist [list $t $il]
         ::console::affiche_resultat "\n"
      }
      ::console::affiche_resultat "idlist=$idlist\n"
   
   }


   proc bddimages_define {  } {
   
      global audace
      global bddconf
   
      set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set l [lsort -decreasing -integer $l]
      set bddconf(define) ""
      foreach i $l {
         lappend bddconf(define) [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
      }
   
      ::console::affiche_resultat "\n**\n run define sur $audace(base).bddimages_define \n**\n"
      ::bddimages_define::run $audace(base).bddimages_define
      
   }


   proc bddimages_images_delete {  } {
   
      set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set l [lsort -decreasing -integer $l]
      foreach i $l {
         set idbddimg  [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
         bddimages_image_delete $idbddimg
         $::bddimages_recherche::This.frame6.result.tbl delete $i
      }
   }


#--------------------------------------------------
#  cmdFormatColumn { column_name }
#--------------------------------------------------
#
#    fonction  :
#       Definit la largeur, la traduction du titre
#	et la justification des colonnes
#
#    procedure externe :
#
#    variables en entree :
#        column_name =
#
#    variables en sortie :
#
#--------------------------------------------------

   proc cmdFormatColumn { column_name } {
      variable column_format

      #--- Suppression des caracteres "(" et ")"
      regsub -all {[\(]} $column_name "" column_name
      regsub -all {[\)]} $column_name "" column_name
      #---
      set a [ array get column_format $column_name ]
      if { [ llength $a ] == "0" } {
         set format [ list 10 $column_name left ]
      } else {
         set format [ lindex $a 1 ]
      }
      return $format
   }

#--------------------------------------------------
#  cmdButton1Click { frame }
#--------------------------------------------------
#
#    fonction  :
#
#    procedure externe :
#
#    variables en entree :
#        frame = Fenetre ou s affiche la table
#
#    variables en sortie :
#
#--------------------------------------------------

   proc cmdButton1Click { frame } {
   }

#--------------------------------------------------
#  cmdSortColumn { tbl col }
#--------------------------------------------------
#
#    fonction  :
#	Trie les lignes par ordre alphabetique de
#	la colonne (est appele quand on clique sur
#	le titre de la colonne)
#
#    procedure externe :
#
#    variables en entree :
#        tbl =
#        col =
#
#    variables en sortie :
#
#--------------------------------------------------

   proc cmdSortColumn { tbl col } {
      tablelist::sortByColumn $tbl $col
   }

#--------------------------------------------------
#  Affiche_Results
#--------------------------------------------------
#
#    fonction  :
#	Affiche la liste des objets de l'image
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------

   proc ::bddimages_recherche::Affiche_Results { i {action {"" ""}} } {
      variable This
      global audace caption color
      global bddconf popupTbl
      global valMinFiltre valMaxFiltre
      global table_result
      global bddconf
      global color
      global list_of_columns

      # Recupere le tableau des action
      array set zaction $action

      # Definition
      set empty [list "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-"]
      set list_of_columns [list [list "idbddimg"             "ID"] \
                                 [list "filename"             "Filename"] \
                                 [list "telescop"             "Telescope"] \
                                 [list "date-obs"             "Date-Obs"] \
                                 [list "exposure"             "Exposure"] \
                                 [list "object"               "Object"] \
                                 [list "filter"               "Filter"] \
                                 [list "bin1"                 "BIN 1"] \
                                 [list "bin2"                 "BIN 2"] \
                                 [list "bddimages_version"    "V"] \
                                 [list "bddimages_states"     "S"] \
                                 [list "bddimages_type"       "T"] \
                                 [list "bddimages_wcs"        "W"] \
                                 [list "bddimages_namecata"   "NC"] \
                                 [list "bddimages_datecata"   "DC"] \
                                 [list "bddimages_astroid"    "A"] \
                                 [list "bddimages_astrometry" "AS"] \
                                 [list "bddimages_cataastrom" "CA"] \
                                 [list "bddimages_photometry" "P"] \
                                 [list "bddimages_cataphotom" "CP"]  ]

      # Initialisations
      set table $table_result($i)
      # -- nb de ligne de la table
      set nbobj [llength $table]
      set bddconf(inserinfo) "Total($nbobj)"
      # -- nb colonne de la table
      set nbcol [llength $list_of_columns]
      #-- lignes a afficher
      set affich_table ""

      foreach line $table {
       set lign_affich $empty
       for { set i 0 } { $i < $nbcol} { incr i } {
         set current_columns [lindex $list_of_columns $i]
         foreach var $line {
           if {[lindex $var 0] eq [lindex $current_columns 0]} {
              set lign_affich [lreplace $lign_affich $i $i [lindex $var 1]]
              break
           }
         }
       }
       lappend affich_table $lign_affich

     }
      
     catch { $::bddimages_recherche::This.frame6.result.tbl delete 0 end
              $::bddimages_recherche::This.frame6.result.tbl deletecolumns 0 end  }

     # Entete des colonnes
     for { set i 0 } { $i < $nbcol} { incr i } {
       set current_columns [lindex $list_of_columns $i]
       $::bddimages_recherche::This.frame6.result.tbl insertcolumns end 0 [lindex $current_columns 1] left
     }

      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::bddimages_recherche::This.frame6.result.tbl columncount ] != "0" } {
         $::bddimages_recherche::This.frame6.result.tbl columnconfigure 0 -sortmode dictionary
      }

      #--- Extraction du resultat: on affiche les lignes qui repondent aux criteres
      #--- de choix de l'utilisateur
      foreach line $affich_table {

         # Dans le cas d'une action non nulle (i.e. on a clique sur un des boutons TYPE ou STATE
         if {[array size zaction] > 1} {

            # Valeur de bdi_state pour la ligne courante 
            set bdi_state [ string trim [lindex $line 10] ]
            # Valeur de bdi_type pour la ligne courante 
            set bdi_type [ string trim [lindex $line 11] ]

            # Doit on afficher la ligne d'apres bdi_state ?
            set voir 1
            if {[string equal -nocase $bdi_state "RAW"]       && $zaction(raw) == 0}      { set voir 0 }
            if {[string equal -nocase $bdi_state "CORR"]      && $zaction(corr) == 0}     { set voir 0 }
            if {[string equal -nocase $bdi_state "unknown"]   && $zaction(unkstate) == 0} { set voir 0 }
            
            # Si oui, doit on afficher la ligne d'apres bdi_type ? 
            if {$voir} {
               if {[string equal -nocase $bdi_type "IMG"]     && $zaction(img) == 0}      { set voir 0 }
               if {[string equal -nocase $bdi_type "FLAT"]    && $zaction(flat) == 0}     { set voir 0 }
               if {[string equal -nocase $bdi_type "DARK"]    && $zaction(dark) == 0}     { set voir 0 }
               if {[string equal -nocase $bdi_type "OFFSET"]  && $zaction(offset) == 0}   { set voir 0 }
               if {[string equal -nocase $bdi_type "unknown"] && $zaction(unktype) == 0}  { set voir 0 }
            }

            # Si oui
            if {$voir} {
               # On affiche l'image
               $::bddimages_recherche::This.frame6.result.tbl insert end $line
            } else {
               # Sinon on la decompte du total des objets
               set nbobj [ expr $nbobj - 1 ]
            }

         } else {
           
            # Pas d'action, donc affichage
            $::bddimages_recherche::This.frame6.result.tbl insert end $line

         }
         
      }
      # Rafraichi le nombre d'elements dans la liste
      set bddconf(inserinfo) "Total($nbobj)"

      #--- Configuration de la liste: affichage des icones en fonction du cas de figure
      if { [ $::bddimages_recherche::This.frame6.result.tbl columncount ] != "0" } {
         #--- Creation des icones 
         image create photo icon_yes
         icon_yes configure -file [file join $audace(rep_plugin) tool bddimages icons ok.gif]
         image create photo icon_no
         icon_no configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
         #--- Analyse des objets...
         for { set i 0 } { $i < $nbobj } { incr i } {
            #--- Coloration bleu du nom des images
            $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,1 -fg $color(blue)
            #--- Affichage d'une icone pour les colonnes bddimages_*
            for { set j 9 } { $j < 20 } { incr j } {
               # Centrage colonne
               $::bddimages_recherche::This.frame6.result.tbl columnconfigure $j -align center
               # Recupere la valeur de la cellule i,j
               set val [$::bddimages_recherche::This.frame6.result.tbl getcells $i,$j]
               # Si valeur cellule = '-' alors icone NO
               if {[string equal -nocase [ string trim $val ] "-"]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text ""
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -image icon_no
               }
               # Si valeur cellule = 1 alors icone YES
               if {[string equal -nocase [ string trim $val ] "1"]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text ""
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -image icon_yes
               }
               # Si valeur cellule = unknown alors icone NO
               if {[string equal -nocase [ string trim $val ] "unknown"]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text ""
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -image icon_no
               }
            }
         }
         #--- Trie par ordre alphabetique de la premiere colonne
         ::bddimages_recherche::cmdSortColumn $::bddimages_recherche::This.frame6.result.tbl 0
      }
   }

#--------------------------------------------------
#  Affiche_listes
#--------------------------------------------------
#
#    fonction  :
#	Affiche la liste des objets de l'image
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------

   proc ::bddimages_recherche::Affiche_listes { } {

      variable This
      global audace caption color
      global bddconf popupTbl
      global valMinFiltre valMaxFiltre
      global nbintellilist
      global intellilisttotal

      catch {  $::bddimages_recherche::This.frame6.liste.tbl delete 0 end
         $::bddimages_recherche::This.frame6.liste.tbl deletecolumns 0 end
         }

      $::bddimages_recherche::This.frame6.liste.tbl insertcolumns end "20" "Listes" left


      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::bddimages_recherche::This.frame6.liste.tbl columncount ] != "0" } {
         $::bddimages_recherche::This.frame6.liste.tbl columnconfigure 0 -sortmode dictionary
      }

      #::console::affiche_resultat "--nbintellilist : $nbintellilist \n"

      #--- Extraction du resultat
      for { set i 1 } { $i <= $nbintellilist } { incr i } {
        
        set intellilist  $intellilisttotal($i)
        set name [::bddimages_liste::get_val_intellilist $intellilist "name"]
        #::console::affiche_resultat " $name\n"
        $::bddimages_recherche::This.frame6.liste.tbl insert end $name

      }
      
      
      #---
      if { [ $::bddimages_recherche::This.frame6.liste.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set j 1 } { $j <= $nbintellilist } { incr j } {
            set intellilist  $intellilisttotal($j)
            set type [::bddimages_liste::get_val_intellilist $intellilist "type"]
            
            #::console::affiche_resultat "[::bddimages_liste::get_val_intellilist $intellilist "name"] = [::bddimages_liste::get_val_intellilist $intellilist "type"] \n"
            set ccolor $color(red)
            if { $type == "intellilist" } { set ccolor $color(blue) } 
            if { $type == "normal" } { set ccolor $color(black) }
            set i [expr $j-1]
            $::bddimages_recherche::This.frame6.liste.tbl cellconfigure $i,0 -fg $ccolor
         }
         #--- Trie par ordre alphabetique de la premiere colonne
         ::bddimages_recherche::cmdSortColumn $::bddimages_recherche::This.frame6.liste.tbl 0
      }
   }


}

#--------------------------------------------------
#  get_list { $i }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste
#
#--------------------------------------------------
proc ::bddimages_recherche::get_list { i } {

   global form_req
   global caption
   global intellilisttotal
   global list_key_to_var
   global table_result

   #::console::affiche_resultat "get_list  $i\n"
   set intellilist  $intellilisttotal($i)
   ::console::affiche_resultat "[::bddimages_liste::get_val_intellilist $intellilist "name"] ... "
   #::console::affiche_resultat "intellilist = $intellilist\n"

   set table_result($i) [::bddimages_liste::get_imglist $intellilist]
}




 proc ::ldelete {liste index} {
 
    if {[llength $liste] <= 1} {return $liste}
    if {$index +1 > [llength $liste]} {return $liste}
    if {$index +1 == [llength $liste]} {set index end}
    if {$index == 0} {
        set range [list 0 1]
        set index 1
    } elseif {$index eq "end"} {
        set index [expr {[llength $liste]-2}]
        set range [list $index [expr {[llength $liste]-1}]]
    } elseif {![string is integer -strict $index]} {
        return $liste
    } else {
        set range [list $index [incr index]]
    }
    return [eval lreplace [list $liste] $range [list [lindex $liste $index]]]
 }

