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
#
#  Structure de la liste image
#
# {               -- debut de liste
#
#   {             -- debut d une image
#
#     {ibddimg 1}
#     {ibddcata 2}
#     {filename toto.fits.gz}
#     {dirfilename /.../}
#     {filenametmp toto.fit}
#     {cataexist 1}
#     {cataloaded 1}
#     ...
#     {tabkey {{NAXIS1 1024} {NAXIS2 1024}} }
#     {cata {{{IMG {ra dec ...}{USNO {...]}}}} { { {IMG {4.3 -21.5 ...}} {USNOA2 {...}} } {source2} ... } } }
#
#   }             -- fin d une image
#
# }               -- fin de liste
#
#--------------------------------------------------
#
#  Structure du tabkey
#
# { {NAXIS1 1024} {NAXIS2 1024} etc ... }
#
#--------------------------------------------------
#
#  Structure du cata
#
# {               -- debut structure generale
#
#  {              -- debut des noms de colonne des catalogues
#
#   { IMG   {list field crossmatch} {list fields}} 
#   { TYC2  {list field crossmatch} {list fields}}
#   { USNO2 {list field crossmatch} {list fields}}
#
#  }              -- fin des noms de colonne des catalogues
#
#  {              -- debut des sources
#
#   {             -- debut premiere source
#
#    { IMG   {crossmatch} {fields}}  -> vue dans l image
#    { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#    { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#
#   }             -- fin premiere source
#
#  }              -- fin des sources
#
# }               -- fin structure generale
#
#--------------------------------------------------
#
#  Structure intellilist_i (dite inteligente)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist           { 
#                        { valide     ... }
#                        { condition  ... }
#                        { champ      ... }
#                        { valeur     ... }
#                      }
#
#   }
#
# }
#
#--------------------------------------------------
#
#  Structure intellilist_n (dite normale)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist            { 
#                         {image_34 {134 345 677}}
#                         {image_38 {135 344 679}}
#                       }
#
#   }
#
# }
#
#--------------------------------------------------

namespace eval bddimages_recherche {

   package require bddimagesXML 1.0
   
   global audace
   global bddconf

   variable ::bddimages_recherche::current_list_id

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

      set bddconf(geometry_recherche) [ wm geometry $This ]
      set conf(bddimages,geometry_recherche) $bddconf(geometry_recherche)
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
   #  cmd_list_select { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Affiche les elements d une liste, selectionnee dans le frame list
   #       par clic dans la liste du tk 
   #
   #    procedure externe :
   #        get_intellilist_by_name
   #        get_intellist
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

      global action_frame_type
      global action_frame_state
      global bddconf

      set ::bddimages_recherche::tbl_cmd_list_select $tbl
      set i [$tbl curselection]
      set row [$tbl get $i $i]
      set ::bddimages_recherche::current_list_name [lindex $row 0]
      set ::bddimages_recherche::current_list_id [::bddimages_liste::get_intellilist_by_name $::bddimages_recherche::current_list_name]

      ::console::affiche_resultat "Chargement ... "

      set t0 [clock clicks -milliseconds]
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id

      set t1 [clock clicks -milliseconds]
      ::bddimages_recherche::reset_icon_yes_recherche $action_frame_state [list "unkstate" "corr" "raw"]
      ::bddimages_recherche::reset_icon_yes_recherche $action_frame_type [list "unktype" "offset" "dark" "flat" "img"]
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id      

      set t2 [clock clicks -milliseconds]
      set sec [expr ($t1-$t0)/1000.]
      set bddconf(chrgtlist) "Charge $sec sec"
      set sec [expr ($t2-$t1)/1000.]
      set bddconf(affichlist) "Affiche $sec sec"
      ::console::affiche_resultat "Fin...\n"

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
   #  ::bddimages_recherche::command_icon_recherche { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Configure le bouton de tri sur les images, et 
   #       affiche les images en fonction de l'etat du bouton 
   #
   #    procedure externe :
   #        ::bddimages_recherche::Affiche_Results
   #
   #    variables en entree :
   #        @param frame frame dans lequel se trouve le bouton
   #        @param button le nom du bouton
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::command_icon_recherche { frame button } {
   
      global action_frame_type
      global action_frame_state
      global action_label

      if {$action_label($button) == 1} {
         set action_label($button) 0
         $frame.$button configure -relief "raised" -image [join [list "icon_no_" $button] ""]
      } else {
         set action_label($button) 1 
         $frame.$button configure -relief "sunken" -image [join [list "icon_yes_" $button] ""]
      }
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
   }

   #--------------------------------------------------
   #  ::bddimages_recherche::reset_icon_yes_recherche { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Remet a 'yes' tous les boutons selectionnes dans un frame donne 
   #
   #    procedure externe :
   #        ::bddimages_recherche::Affiche_Results
   #
   #    variables en entree :
   #        @param frame frame dans lequel se trouve le bouton
   #        @param buttons liste des boutons
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::reset_icon_yes_recherche { frame buttons } {
   
      global action_frame_type
      global action_frame_state
      global action_label

      foreach b $buttons {
         set action_label($b) 1
         $frame.$b configure -relief "sunken" -image [join [list "icon_yes_" $b] ""]
      }
   }

   #--------------------------------------------------
   #  ::bddimages_recherche::reset_icon_no_recherche { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Remet a 'no' tous les boutons selectionnes dans un frame donne 
   #
   #    procedure externe :
   #        ::bddimages_recherche::Affiche_Results
   #
   #    variables en entree :
   #        @param frame frame dans lequel se trouve le bouton
   #        @param buttons liste des boutons
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::reset_icon_no_recherche { frame buttons } {
   
      global action_frame_type
      global action_frame_state
      global action_label

      foreach b $buttons {
         set action_label($b) 0
         $frame.$b configure -relief "raised" -image [join [list "icon_no_" $b] ""]
      }
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
      if { ! [ info exists conf(bddimages,geometry_recherche) ] } { set conf(bddimages,geometry_recherche) "+100+100" }
      set bddconf(geometry_recherche) $conf(bddimages,geometry_recherche)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
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
         #::console::affiche_resultat "list_config = $bddconf(list_config) \n"
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
      set bddconf(chrgtlist) "Charge -"
      set bddconf(affichlist) "Affiche -"
      set bddconf(namelist) "Liste -"


      # Definitions des boutons d'action: par defaut tout a 1
      array set action_label {
         img      1
         flat     1
         dark     1
         offset   1
         unktype  1
         raw      1
         corr     1
         cata     1
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
      #--- UNKNOWN TYPE
      image create photo icon_yes_unktype
      icon_yes_unktype configure -file [file join $audace(rep_plugin) tool bddimages icons yes_unk.gif]
      image create photo icon_no_unktype
      icon_no_unktype configure -file [file join $audace(rep_plugin) tool bddimages icons no_unk.gif]
      #--- UNKNOWN STATE
      image create photo icon_yes_unkstate
      icon_yes_unkstate configure -file [file join $audace(rep_plugin) tool bddimages icons yes_unk.gif]
      image create photo icon_no_unkstate
      icon_no_unkstate configure -file [file join $audace(rep_plugin) tool bddimages icons no_unk.gif]
      #--- CATA
      image create photo icon_yes_cata
      icon_yes_cata configure -file [file join $audace(rep_plugin) tool bddimages icons yes_corr.gif]
      image create photo icon_no_cata
      icon_no_cata configure -file [file join $audace(rep_plugin) tool bddimages icons no_corr.gif]
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
         wm geometry $This $bddconf(geometry_recherche)
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
           pack $This.frame0.file -side left
           #--- menu aide
           menubutton $This.frame0.aide -text "$caption(search,aide)" -underline 0 -menu $This.frame0.aide.menu
           menu $This.frame0.aide.menu
             $This.frame0.aide.menu add command -label "$caption(search,aide)" -command { }
             $This.frame0.aide.menu add separator
             $This.frame0.aide.menu add command -label "$caption(search,code_uai)" -command {  }
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
               button $This.frame1.action.type.unktype -state active -relief "sunken" -image icon_yes_unktype \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_type "unktype" }
               pack $This.frame1.action.type.unktype -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.unktype -text $caption(bddimages_recherche,button_unktype)
               #----- OFFSET
               button $This.frame1.action.type.offset -state active -relief "sunken" -image icon_yes_offset \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_type "offset" }
               pack $This.frame1.action.type.offset -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.offset -text $caption(bddimages_recherche,button_offset)
               #----- DARK
               button $This.frame1.action.type.dark -state active -relief "sunken" -image icon_yes_dark \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_type "dark" }
               pack $This.frame1.action.type.dark -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.dark -text $caption(bddimages_recherche,button_dark)
               #----- FLAT
               button $This.frame1.action.type.flat -state active -relief "sunken" -image icon_yes_flat \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_type "flat" }
               pack $This.frame1.action.type.flat -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.flat -text $caption(bddimages_recherche,button_flat)
               #----- IMG
               button $This.frame1.action.type.img -state active -relief "sunken" -image icon_yes_img \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_type "img" }
               pack $This.frame1.action.type.img -in $This.frame1.action.type -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.type.img -text $caption(bddimages_recherche,button_img)
               
               #--- Label ACTIONS TYPE
               label $This.frame1.action.type.label -text "TYPE: "
               pack $This.frame1.action.type.label -in $This.frame1.action.type -side right -anchor w -padx 5

               #--- Boutons ACTIONS STATE
               set action_frame_state [frame $This.frame1.action.state -borderwidth 1 -cursor arrow]
               pack $This.frame1.action.state -in $This.frame1.action -side right -expand 0 -fill x
               #----- UNKNOWN
               button $This.frame1.action.state.unkstate -state active -relief "sunken" -image icon_yes_unkstate \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_state "unkstate" }
               pack $This.frame1.action.state.unkstate -in $This.frame1.action.state -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.state.unkstate -text $caption(bddimages_recherche,button_unkstate)
               #----- CATA
#               button $This.frame1.action.state.cata -state active -relief "sunken" -image icon_yes_cata \
#                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_state "cata" }
#               pack $This.frame1.action.state.cata -in $This.frame1.action.state -side right -anchor w -padx 0
#               DynamicHelp::add $This.frame1.action.state.cata -text $caption(bddimages_recherche,button_cata)
               #----- CORR
               button $This.frame1.action.state.corr -state active -relief "sunken" -image icon_yes_corr \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_state "corr" }
               pack $This.frame1.action.state.corr -in $This.frame1.action.state -side right -anchor w -padx 0
               DynamicHelp::add $This.frame1.action.state.corr -text $caption(bddimages_recherche,button_corr)
               #----- RAW
               button $This.frame1.action.state.raw -state active -relief "sunken" -image icon_yes_raw \
                  -command { ::bddimages_recherche::command_icon_recherche $action_frame_state "raw" }
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

           #--- Cree un label pour le nb image
           label $This.frame11.nbimg -font $bddconf(font,arial_12_b) \
               -textvariable bddconf(inserinfo)
           pack $This.frame11.nbimg -in $This.frame11 -side left -padx 3 -pady 1 -anchor w
           #--- Cree un label pour le nb image
           label $This.frame11.chrgtlist -font $bddconf(font,arial_12_b) \
               -textvariable bddconf(chrgtlist)
           pack $This.frame11.chrgtlist -in $This.frame11 -side left -padx 3 -pady 1 -anchor w
           #--- Cree un label pour le nb image
           label $This.frame11.affichlist -font $bddconf(font,arial_12_b) \
               -textvariable bddconf(affichlist)
           pack $This.frame11.affichlist -in $This.frame11 -side left -padx 3 -pady 1 -anchor w
           #--- Cree un label pour le nom de la liste
           label $This.frame11.namelist -font $bddconf(font,arial_12_b) \
               -textvariable bddconf(namelist)
           pack $This.frame11.namelist -in $This.frame11 -side left -padx 3 -pady 1 -anchor w

      
      ::bddimages_recherche::Affiche_listes

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

   #--------------------------------------------------
   #  createTbl2 { frame }
   #--------------------------------------------------
   #
   #    fonction  : Affiche de la tablelist contenant les listes
   #      definies par l'utilisateur. La selection d'une liste
   #      charge directement les images de la liste
   #
   #    variables en entree :
   #        frame = reference de l'objet graphique d'affichage
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc createTbl2 { frame } {
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
        # Edite la liste selectionnee
        $popupTbl add command -label "$caption(bddimages_recherche,edit)" \
           -command [list ::bddimages_recherche::Tbl2Edit $tbl ]

        # Supprime la liste selectionnee
        $popupTbl add command -label "$caption(bddimages_recherche,delete_list)" \
           -command [list ::bddimages_recherche::Tbl2Delete $tbl ]

        # Separateur
        $popupTbl add separator
        
        # Nouvelle liste intelligente
        $popupTbl add command -label "$caption(bddimages_recherche,new_list_i)" \
           -command { ::bddimages_liste::run $audace(base).bddimages_liste }

        # Nouvelle liste normale
        $popupTbl add command -label "$caption(bddimages_recherche,new_list_n)" \
           -command { ::bddimages_liste::runnormal $audace(base).bddimages_liste }

        # Separateur
        $popupTbl add separator
        
        # Acces a l'aide
        $popupTbl add command -label $caption(bddimages_recherche,aide) \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

   }

   #--------------------------------------------------
   #  createTbl1 { frame }
   #--------------------------------------------------
   #
   #    fonction  : Affiche les images correspondant a une liste
   #      definie par l'utilisateur. La selection d'une image
   #      l'affiche dans la visu d'Audela
   #
   #    variables en entree :
   #        frame = reference de l'objet graphique d'affichage
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc createTbl1 { frame } {
      variable This
      global audace
      global caption
      global bddconf
      global popupTbl
      global paramwindow
      global intellilisttotal

      set normal_liste ""
      set total [array get intellilisttotal]
      foreach intellilist $total {
         set type [::bddimages_liste::lget $intellilist "type"]
         if { $type == "normal"} {
            set name [::bddimages_liste::lget $intellilist "name"]
            lappend normal_liste $name
         }
      }
      ::console::affiche_resultat "normal_liste  = $normal_liste \n"

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
 
      menu $popupTbl.gestion -tearoff 0
      $popupTbl add cascade -label "Gestion" -menu $popupTbl.gestion

           # Labels Define
           $popupTbl.gestion add command -label $caption(bddimages_recherche,define) \
              -command { ::bddimages_recherche::bddimages_define }

           # Labels Effacement de l image
           $popupTbl.gestion add command -label $caption(bddimages_recherche,delete) \
              -command { ::bddimages_recherche::bddimages_images_delete }

           # Labels Exporter
           $popupTbl.gestion add command -label "Exporter" \
              -command { ::bddimages_recherche::export }

           # Labels Copier une image
           $popupTbl.gestion add command -label "Copier une image de calibration"  \
              -command { ::bddimages_recherche::bddimages_images_copy_calib }

      menu $popupTbl.liste -tearoff 0
      $popupTbl add cascade -label "Listes" -menu $popupTbl.liste

           menu $popupTbl.liste.associer -tearoff 0
           $popupTbl.liste add cascade -label $caption(bddimages_recherche,associate) -menu $popupTbl.liste.associer

               foreach name_liste $normal_liste {

                  $popupTbl.liste.associer add command -label $name_liste \
                     -command " ::bddimages_recherche::bddimages_associate $name_liste "
               }

           # Labels DisAssociate
           $popupTbl.liste add command -label $caption(bddimages_recherche,disassociate) \
              -command { ::bddimages_recherche::bddimages_disassociate "tmp" }

      menu $popupTbl.correction -tearoff 0
      $popupTbl add cascade -label "Correction" -menu $popupTbl.correction

           $popupTbl.correction add command -label $caption(bddimages_recherche,sbias) \
              -command { ::bddimages_imgcorrection::run_create $audace(base).bddimages_imgcorrection "offset"}

           $popupTbl.correction add command -label $caption(bddimages_recherche,sdark) \
              -command [list ::bddimages_imgcorrection::run_create $audace(base).bddimages_imgcorrection "dark"]

           $popupTbl.correction add command -label $caption(bddimages_recherche,sflat) \
              -command { ::bddimages_imgcorrection::run_create $audace(base).bddimages_imgcorrection "flat"}

           $popupTbl.correction add command -label $caption(bddimages_recherche,deflat) \
              -command { ::bddimages_imgcorrection::run_create $audace(base).bddimages_imgcorrection "deflat"}

           $popupTbl.correction add separator
 
           $popupTbl.correction add command -label "Automatique" -state disabled\
              -command { }

      menu $popupTbl.geometrie -tearoff 0
      $popupTbl add cascade -label "Geometrie" -menu $popupTbl.geometrie

           $popupTbl.geometrie add command -label "Mirroir X" \
              -command { ::bddimages_recherche::bddimages_geometrie "mirroirx" }

           $popupTbl.geometrie add command -label "Mirroir Y" -state disabled \
              -command {  }

           $popupTbl.geometrie add command -label "Somme" \
              -command { ::bddimages_imgcorrection::somme }

      menu $popupTbl.analyse -tearoff 0
      $popupTbl add cascade -label "Analyse" -menu $popupTbl.analyse

           $popupTbl.analyse add command -label "Creer le Cata" \
              -command { ::bddimages_recherche::bddimages_creation_wcs }

           $popupTbl.analyse add command -label "CdL" \
              -command { ::bddimages_cdl::run}

           $popupTbl.analyse add command -label $caption(bddimages_recherche,astroid) -state disabled \
              -command { ::bddimages_astroid::run_astroid}

           $popupTbl.analyse add command -label $caption(bddimages_recherche,photom) -state disabled \
              -command { ::bddimages_analyse::run_photom}

           $popupTbl.analyse add command -label $caption(bddimages_recherche,astrom) -state disabled \
              -command { ::bddimages_analyse::run_astrom}

           $popupTbl.analyse add command -label $caption(bddimages_recherche,cata) -state disabled \
              -command { ::bddimages_analyse::run_cata}

      menu $popupTbl.developpement -tearoff 0
      $popupTbl add cascade -label "Developpement" -menu $popupTbl.developpement

           $popupTbl.developpement add command -label "charge_cata" \
              -command { ::bddimages_recherche::bddimages_charge_cata }

      # Separateur
      $popupTbl add separator

      # Acces a l'aide
      $popupTbl add command -label $caption(bddimages_recherche,aide) \
         -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind [$tbl bodypath] <Control-Key-a> [ list $tbl selection set 0 end ]
      bind $tbl <<ListboxSelect>> [ list ::bddimages_recherche::cmdButton1Click %W ]

   }











   #--------------------------------------------------
   #  bddimages_associate {  }
   #--------------------------------------------------
   #
   #    fonction  : Associe l image a une liste normale
   #
   #    variables en entree : namelist : le nom de la liste normale
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::bddimages_associate { namelist } {
   
      set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set lid [lsort -decreasing -integer $lid]
      
      #ajoute l ancienne idlist
      set num [::bddimages_liste::get_intellilist_by_name $namelist]   
      set normallist $::intellilisttotal($num)

      set ::intellilisttotal($num) [::bddimages_liste::add_to_normallist $lid $normallist]
      return
   }



   #--------------------------------------------------
   #  export {  }
   #--------------------------------------------------
   #
   #    fonction  : exporte des images de la base
   #
   #    variables en entree :
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::export {  } {

      variable This
      global bddconf

      set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set lid [lsort -decreasing -integer $lid]
      set img_list [::bddimages_liste::new_normallist $lid]
      foreach img $img_list {

         set filename    [string trim [::bddimages_liste::lget $img "filename"] ]
         set dirfilename [string trim [::bddimages_liste::lget $img "dirfilename"] ]
         set fichier [ file join $bddconf(dirbase) $dirfilename $filename]
         set fc [file tail $fichier]
         set fd [file join $bddconf(dirtmp) $fc]
         if {[file exists $fichier] != 1} {
            ::console::affiche_erreur "image inconue : $fichier\n"
            continue
         }
         set errnum [catch {file copy -force -- $fichier $fd} msg]
         if {$errnum != 0} {
            ::console::affiche_erreur "cp image impossible : $fichier\n"
            ::console::affiche_erreur "err : $errnum\n"
            ::console::affiche_erreur "msg : $msg\n"
            continue
         }
         ::console::affiche_resultat "cp image : $fc\n"
         
      
      }


      return
   }



   #--------------------------------------------------
   #  bddimages_images_copy_calib {  }
   #--------------------------------------------------
   #
   #    fonction  : Copie une image de calibration en changeant la date
   #
   #    variables en entree :
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::bddimages_images_copy_calib {  } {

      variable This
      global bddconf

      set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]

      if {[llength $lid]!=1} {
         tk_dialog $This.confirmDialog "BddImages - Copie Image de Calibration" "Veuillez selectionner UNE seule image de calibration" questhead 0 "Annuler"
         return
      }
      
      # recupere l info de l image
      set img [lindex [::bddimages_liste::new_normallist $lid] 0]

      # Verification des champs
      set tabkey [::bddimages_liste::lget $img "tabkey"]
      set bddimages_type [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_type] 1]]
      if {$bddimages_type == "IMG" } {
          tk_dialog $This.confirmDialog "BddImages - Copie Image de Calibration" "Veuillez selectionner une image de CALIBRATION" questhead 0 "Annuler"
          return
      }
      
      if { $bddimages_type != "FLAT" && $bddimages_type != "DARK" && $bddimages_type != "OFFSET" } {
         tk_dialog $This.confirmDialog "BddImages - Copie Image de Calibration" "Votre image n est pas compatible BDI" questhead 0 "Annuler"
         return
      }
       
      # Fenetre de changement de date
      set dateobs [::bddimagesAdmin::GetDateIso]

      # charge l image 
      set filename    [string trim [::bddimages_liste::lget $img "filename"] ]
      set dirfilename [string trim [::bddimages_liste::lget $img "dirfilename"] ]
      set fichier [ file join $bddconf(dirbase) $dirfilename $filename]
      buf[::confVisu::getBufNo $::audace(visuNo)] load $fichier
      
      # modification du header
      buf[::confVisu::getBufNo $::audace(visuNo)] setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
      
      # copie de l image dans tmp
      set fichier [ file tail $fichier ]
      set fichier [ file rootname $fichier ]
      set fichier [ file rootname $fichier ]

      set ext [buf[::confVisu::getBufNo $::audace(visuNo)] extension]
      set gz [buf[::confVisu::getBufNo $::audace(visuNo)] compress]
      if {[buf[::confVisu::getBufNo $::audace(visuNo)] compress] == "gzip"} {set gz ".gz"} else {set gz ""}

      set fichier "${fichier}_COPY"
      buf[::confVisu::getBufNo $::audace(visuNo)] save [ file join $bddconf(dirtmp) ${fichier}${ext} ]

      # insertion dans la base
      insertion_solo [ file join $bddconf(dirtmp) ${fichier}${ext}${gz} ]

      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      return
   }




   #--------------------------------------------------
   #  bddimages_define {  }
   #--------------------------------------------------
   #
   #    fonction  : Ouvre l'interface de modification de l'entete des images selectionnees
   #
   #    variables en entree :
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc bddimages_define {  } {
   
      global audace
      global bddconf
      global action_label

      set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set l [lsort -decreasing -integer $l]
      set bddconf(define) ""
      foreach i $l {
         lappend bddconf(define) [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
      }

      # GUI de modif des entetes des images
      ::bddimages_define::run $audace(base).bddimages_define
      # Attend une action de la part de la GUI 
      tkwait variable ::bddimages_define::bdi_define_close
      # ... pour Re-afficher la liste courante
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      
   }

   #--------------------------------------------------
   #  bddimages_images_delete {  }
   #--------------------------------------------------
   #
   #    fonction  : Efface definitivement le lot d'images selectionnees
   #
   #    variables en entree :
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc bddimages_images_delete {  } {
   
      variable This
      global caption
      set reply [tk_dialog $This.confirmDialog "BddImages" "$caption(bddimages_recherche,confirmQuest)" \
                    questhead 1 "$caption(bddimages_recherche,confirmNo)" "$caption(bddimages_recherche,confirmYes)"]
      if {$reply} {
         set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
         set l [lsort -decreasing -integer $l]
         foreach i $l {
            set idbddimg  [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
            bddimages_image_delete $idbddimg
            $::bddimages_recherche::This.frame6.result.tbl delete $i
         }
      }
      
   }

   proc ::bddimages_recherche::bddimages_geometrie { type } {
   
      variable This
      global caption
      set reply [tk_dialog $This.confirmDialog "BddImages" "$caption(bddimages_recherche,confirmQuest)" \
                    questhead 1 "$caption(bddimages_recherche,confirmNo)" "$caption(bddimages_recherche,confirmYes)"]
      if {$reply} {

         set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
         set lid [lsort -decreasing -integer $lid]
         set imglist [::bddimages_liste::new_normallist $lid]

            if {$type=="mirroirx"} {
               ::bddimages_imgcorrection::bddimages_mirroirx $imglist
            }
            if {$type=="mirroiry"} {
               #::bddimages_imgcorrection::mirroiry $idbddimg
            }
            if {$type=="rot_plus90"} {
               #::bddimages_imgcorrection::rot_plus90 $idbddimg
            }
            if {$type=="rot_moins90"} {
               #::bddimages_imgcorrection::rot_moins90 $idbddimg
            }

      }
      
   }




   proc ::bddimages_recherche::bddimages_charge_cata { } {

      variable This
      global caption
      set reply [tk_dialog $This.confirmDialog "BddImages" "$caption(bddimages_recherche,confirmQuest)" \
                    questhead 1 "$caption(bddimages_recherche,confirmNo)" "$caption(bddimages_recherche,confirmYes)"]
      if {$reply} {

         set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
         set lid [lsort -decreasing -integer $lid]
         set imglist [::bddimages_liste::new_normallist $lid]

         ::bddimages_analyse::charge_cata $imglist

      }

   }



   proc ::bddimages_recherche::bddimages_creation_wcs { } {

      variable This
      global caption
      set reply [tk_dialog $This.confirmDialog "BddImages" "$caption(bddimages_recherche,confirmWCS)" \
                    questhead 1 "$caption(bddimages_recherche,confirmNo)" "$caption(bddimages_recherche,confirmYes)"]
      if {$reply} {

         set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
         set lid [lsort -decreasing -integer $lid]
         set imglist [::bddimages_liste::new_normallist $lid]

         ::bddimages_analyse::creation_wcs $imglist

         ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
         ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
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
   #  ::bddimages_recherche::cmdButton1Click { frame }
   #--------------------------------------------------
   #
   #    fonction  : Affiche l'image selectionnee lorsqu'on clique 
   #      sur une ligne ou se deplace avec les fleches H/B
   #
   #    variables en entree :
   #        frame = reference de l'objet graphique de la selection
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc ::bddimages_recherche::cmdButton1Click { w args } {

      if { [$w curselection] != "" } {
         set i [lindex [$w curselection ]  0]
         set idbddimg  [lindex [$w get $i] 0]
         affiche_image_by_idbddimg $idbddimg
      }
      return

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
      set list_of_columns [list  [list "idbddimg"             "ID"] \
                                 [list "filename"             "Filename"] \
                                 [list "telescop"             "Telescope"] \
                                 [list "date-obs"             "Date-Obs"] \
                                 [list "exposure"             "Exposure"] \
                                 [list "object"               "Object"] \
                                 [list "filter"               "Filter"] \
                                 [list "bin1"                 "BIN 1"] \
                                 [list "bin2"                 "BIN 2"] \
                                 [list "bddimages_version"    "V"] \
                                 [list "bddimages_state"      "S"] \
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
            set current_columns [lindex [lindex $list_of_columns $i] 0]
            set val [::bddimages_liste::lget $line $current_columns]
            set lign_affich [lreplace $lign_affich $i $i $val]
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
      #--- de choix de l'utilisateur via les boutons STATE et TYPE
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
            if {[string equal -nocase $bdi_state "CATA"]      && $zaction(cata) == 0}     { set voir 0 }
            if {[string equal -nocase $bdi_state "?"]         && $zaction(unkstate) == 0} { set voir 0 }
            
            # Si oui, doit on afficher la ligne d'apres bdi_type ? 
            if {$voir} {
               if {[string equal -nocase $bdi_type "IMG"]     && $zaction(img) == 0}      { set voir 0 }
               if {[string equal -nocase $bdi_type "FLAT"]    && $zaction(flat) == 0}     { set voir 0 }
               if {[string equal -nocase $bdi_type "DARK"]    && $zaction(dark) == 0}     { set voir 0 }
               if {[string equal -nocase $bdi_type "OFFSET"]  && $zaction(offset) == 0}   { set voir 0 }
               if {[string equal -nocase $bdi_type "?"]       && $zaction(unktype) == 0}  { set voir 0 }
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
            for { set j 9 } { $j < 10 } { incr j } {
               # Centrage colonne
               #$::bddimages_recherche::This.frame6.result.tbl columnconfigure $j -align center
               # Recupere la valeur de la cellule i,j
               set val [$::bddimages_recherche::This.frame6.result.tbl getcells $i,$j]
               # Si valeur cellule = pattern alors premiere lettre seulement
               if {[regexp -nocase -- {(RAW|CORR|CATA|IMG|DARK|FLAT|OFFSET)} [ string trim $val ]]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text [ string range $val 0 0 ]
               }
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
               if {[string equal -nocase [ string trim $val ] "?"]} {
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
#  get_intellist { $i }
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
proc ::bddimages_recherche::get_intellist { i } {

   global form_req
   global caption
   global intellilisttotal
   global list_key_to_var
   global table_result
   global bddconf

   #::console::affiche_resultat "get_intellist  $i\n"
   set intellilist  $intellilisttotal($i)
   set nl [::bddimages_liste::get_val_intellilist $intellilist "name"]
   set bddconf(namelist) "Liste : $nl"

   #::console::affiche_resultat "[::bddimages_liste::get_val_intellilist $intellilist "name"] ... "
   #::console::affiche_resultat "intellilist = $intellilist\n"

#  Table_tmp
#   {idheader 22} 
#   {tabname images_22} 
#   {filename IM_20091017_063807246_200279_49065202.fits.gz} 
#   {dirfilename fits/tarot_chili/2009/10/17} 
#   {sizefich 4556161} 
#   {datemodif {2011-03-15 15:10:52}} 
#   {commundatejj 2455121.77616018}
#   {tabkey {..}}

   set table_tmp [::bddimages_liste::intellilist_to_imglist $intellilist]

   #::console::affiche_resultat "table_tmp = $table_tmp\n"
   set table_result($i) ""

   foreach img $table_tmp {

      set tabkey               [::bddimages_liste::lget $img "tabkey"]

      set idbddimg             [list "idbddimg" [::bddimages_liste::lget $img "idbddimg"] ]
      set filename             [list "filename" [::bddimages_liste::lget $img "filename"] ]
      set telescop             [list "telescop"             [lindex [::bddimages_liste::lget $tabkey "telescop"            ] 1] ]
      set dateobs              [list "date-obs"             [lindex [::bddimages_liste::lget $tabkey "date-obs"            ] 1] ]
      set exposure             [list "exposure"             [lindex [::bddimages_liste::lget $tabkey "exposure"            ] 1] ]
      set object               [list "object"               [lindex [::bddimages_liste::lget $tabkey "object"              ] 1] ]
      set filter               [list "filter"               [lindex [::bddimages_liste::lget $tabkey "filter"              ] 1] ]
      set bin1                 [list "bin1"                 [lindex [::bddimages_liste::lget $tabkey "bin1"                ] 1] ]
      set bin2                 [list "bin2"                 [lindex [::bddimages_liste::lget $tabkey "bin2"                ] 1] ]
      set bddimages_version    [list "bddimages_version"    [lindex [::bddimages_liste::lget $tabkey "bddimages_version"   ] 1] ]
      set bddimages_state      [list "bddimages_state"      [lindex [::bddimages_liste::lget $tabkey "bddimages_state"     ] 1] ]
      set bddimages_type       [list "bddimages_type"       [lindex [::bddimages_liste::lget $tabkey "bddimages_type"      ] 1] ]
      set bddimages_wcs        [list "bddimages_wcs"        [lindex [::bddimages_liste::lget $tabkey "bddimages_wcs"       ] 1] ]
      set bddimages_namecata   [list "bddimages_namecata"   [lindex [::bddimages_liste::lget $tabkey "bddimages_namecata"  ] 1] ]
      set bddimages_datecata   [list "bddimages_datecata"   [lindex [::bddimages_liste::lget $tabkey "bddimages_datecata"  ] 1] ]
      set bddimages_astroid    [list "bddimages_astroid"    [lindex [::bddimages_liste::lget $tabkey "bddimages_astroid"   ] 1] ]
      set bddimages_astrometry [list "bddimages_astrometry" [lindex [::bddimages_liste::lget $tabkey "bddimages_astrometry"] 1] ]
      set bddimages_cataastrom [list "bddimages_cataastrom" [lindex [::bddimages_liste::lget $tabkey "bddimages_cataastrom"] 1] ]
      set bddimages_photometry [list "bddimages_photometry" [lindex [::bddimages_liste::lget $tabkey "bddimages_photometry"] 1] ]
      set bddimages_cataphotom [list "bddimages_cataphotom" [lindex [::bddimages_liste::lget $tabkey "bddimages_cataphotom"] 1] ]
      lappend table_result($i) [list $idbddimg             \
                                     $filename             \
                                     $telescop             \
                                     $dateobs              \
                                     $exposure             \
                                     $object               \
                                     $filter               \
                                     $bin1                 \
                                     $bin2                 \
                                     $bddimages_version    \
                                     $bddimages_state      \
                                     $bddimages_type       \
                                     $bddimages_wcs        \
                                     $bddimages_namecata   \
                                     $bddimages_datecata   \
                                     $bddimages_astroid    \
                                     $bddimages_astrometry \
                                     $bddimages_cataastrom \
                                     $bddimages_photometry \
                                     $bddimages_cataphotom
                                ]
   }

#  table_result($i)
#  "idbddimg"            
#  "filename"            
#  "telescop"            
#  "date-obs"            
#  "exposure"            
#  "object"              
#  "filter"              
#  "bin1"                
#  "bin2"                
#  "bddimages_version"   
#  "bddimages_state"     
#  "bddimages_type"      
#  "bddimages_wcs"       
#  "bddimages_namecata"  
#  "bddimages_datecata"  
#  "bddimages_astroid"   
#  "bddimages_astrometry"
#  "bddimages_cataastrom"
#  "bddimages_photometry"
#  "bddimages_cataphotom"
#

   return 0
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

