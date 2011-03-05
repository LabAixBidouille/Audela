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
      ::bddimages_recherche::get_list $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id
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
# | | |	        | |			 | |  |
# | | |	        | |			 | |  |
# | | |	        | |			 | |  |
# | | |	        | |			 | |  |
# | | |	        | |			 | |  |
# | | |         | |			 | |  |
# | | |	        | |			 | |  |
# | | |---------| |----------------------| |  |
# | |                                      |  |
# | |--------------------------------------|  |
# |					      |
# | |-frame2-------------------------------|  |
# | |					   |  |
# | |--------------------------------------|  |
# |					      |
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

      #--- initConf
      if { ! [ info exists conf(bddimages,position_status) ] } { set conf(bddimages,position_status) "+80+1200" }

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
      set bddconf(inserinfo) "Total($nbintellilist)"

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

             $This.frame0.file.menu add command -label "$caption(bddimages_recherche,new_list)" -command { ::bddimages_liste::run $audace(base).bddimages_liste }
             $This.frame0.file.menu add command -label "$caption(bddimages_recherche,delete_list)" -command " ::bddimages_recherche::cmd_list_delete $This.frame6.liste.tbl "
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
             #$This.frame0.aide.menu add command -label "$caption(search,aide_skybot)" -command {  }
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

           #--- Cree un frame pour afficher le status de la base
           frame $This.frame1.action -borderwidth 1 -cursor arrow
           pack $This.frame1.action -in $This.frame1 -side top -expand 1 -fill x
              
               #--- Boutons ACTIONS
               button $This.frame1.action.unknown -state active -text "?" \
                  -command { }
               pack $This.frame1.action.unknown -in $This.frame1.action -side right -anchor w -padx 0
               button $This.frame1.action.offset -state active -text "O" \
                  -command { }
               pack $This.frame1.action.offset -in $This.frame1.action -side right -anchor w -padx 0
               button $This.frame1.action.dark -state active -text "D" \
                  -command { ::bddimages_recherche::Affiche_Results  $::bddimages_recherche::current_list_id "NODARK" }
               pack $This.frame1.action.dark -in $This.frame1.action -side right -anchor w -padx 0
               button $This.frame1.action.flat -state active -text "F" \
                  -command { }
               pack $This.frame1.action.flat -in $This.frame1.action -side right -anchor w -padx 0
               button $This.frame1.action.img -state active -text "I" \
                  -command { }
               pack $This.frame1.action.img -in $This.frame1.action -side right -anchor w -padx 0
      
	 #--- Cree un frame pour l'affichage des deux listes
	 frame $This.frame6 -borderwidth 0
	 pack $This.frame6 -expand yes -fill both -padx 3 -pady 6


	 #--- Cree un frame pour l'affichage de la liste des results
	 frame $This.frame6.result -borderwidth 0
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
        # Label
        $popupTbl add command -label "$caption(bddimages_recherche,new_list)" \
           -command { ::bddimages_liste::run $audace(base).bddimages_liste }
        # Separateur
#        proc getcurname { tbl } {
#         set i [$tbl curselection]
#         set row [$tbl get $i $i]
#         set name [lindex $row 0]
#         return $name
#        }
        $popupTbl add command -label "$caption(bddimages_recherche,edit)" \
           -command [list ::bddimages_recherche::Tbl2Edit $tbl ]
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
        # Acces a l'aide
        $popupTbl add command -label $caption(bddimages_recherche,aide) \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind $tbl <<ListboxSelect>>          [ list ::bddimages_recherche::cmdButton1Click $This.frame6.result ]
      bind [$tbl bodypath] <Double-ButtonPress-1> { ::bddimages_recherche::affiche_image }

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

   proc ::bddimages_recherche::Affiche_Results { i {dark ""} } {
      variable This
      global audace caption color
      global bddconf popupTbl
      global valMinFiltre valMaxFiltre
      global table_result
      global bddconf
      global color
      global list_of_columns

      #::console::affiche_resultat "clock seconds [clock seconds] \n"

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
                                 [list "bddimages_cataphotom" "CP"]
                                                                
      ]

      set table $table_result($i)
      #::console::affiche_resultat "table: $i \n"
      
      set nbobj [llength $table]
      set bddconf(inserinfo) "Total($nbobj)"
      set nbcol [llength $list_of_columns]

#::console::affiche_resultat "nbcol = $nbcol \n"
#::console::affiche_resultat "nbobj = $nbobj \n"

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

      #--- Extraction du resultat
      foreach line $affich_table {
         
         if {[string equal -nocase [ string trim [lindex $line 11] ] "DARK"]} {
            if {$dark != "NODARK"} {
               $::bddimages_recherche::This.frame6.result.tbl insert end $line
            }
         } else {
            $::bddimages_recherche::This.frame6.result.tbl insert end $line
         }
         
      }
      # Rafraichi le nombre d'elements dans la liste
      set nbobj [expr $nbobj - 3]
      

      #--- Configuration de la liste: couleur
      if { [ $::bddimages_recherche::This.frame6.result.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set i 0 } { $i < $nbobj } { incr i } {
           $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,1 -fg $color(blue)
         }
         #--- Les valeurs Unknown sont coloriees en rouge
         image create photo icon_yes
         icon_yes configure -file [file join $audace(rep_plugin) tool bddimages icons ok.gif]
         image create photo icon_no
         icon_no configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
         for { set i 0 } { $i < $nbobj } { incr i } {
            
            for { set j 9 } { $j < 20 } { incr j } {            
               set val [$::bddimages_recherche::This.frame6.result.tbl getcells $i,$j]
               # Si valeur cellule = 1 alors colorie en vert
               if {[string equal -nocase [ string trim $val ] "-"]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text ""
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -image icon_no
               }
               if {[string equal -nocase [ string trim $val ] "1"]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text ""
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -image icon_yes
               }
               # Si valeur cellule = unknown alors colorie en rouge et marque ?
               if {[string equal -nocase [ string trim $val ] "unknown"]} {
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -text ""
                  $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,$j -image icon_no
               }
            }

#           for { set j 0 } { $j < [ expr $nbcol - 1] } { incr j } {
#             $::bddimages_recherche::This.frame6.result.tbl getcells  
#            if { } {
#              $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,1 -fg $color(red)
#            }
#           }
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

        foreach val $intellilist {
          if {[lindex $val 0]=="name"} {set name [lindex $val 1]}
        }
        $::bddimages_recherche::This.frame6.liste.tbl insert end $name
      }
      #---
      if { [ $::bddimages_recherche::This.frame6.liste.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set i 0 } { $i <= [ expr $nbintellilist - 1 ] } { incr i } {
            $::bddimages_recherche::This.frame6.liste.tbl cellconfigure $i,0 -fg $color(blue)
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

   set intellilist  $intellilisttotal($i)
   ::console::affiche_resultat "intellilist = [::bddimages_liste::get_val_intellilist $intellilist "name"]\n"

      ::console::affiche_resultat "Chargement : "
      set t0 [clock clicks -milliseconds]
      set table_result($i) [::bddimages_liste::get_imglist $intellilist]
      set t1 [clock clicks -milliseconds]
      set sec [expr ($t1-$t0)/1000.]
      ::console::affiche_resultat "$sec sec\n"
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

