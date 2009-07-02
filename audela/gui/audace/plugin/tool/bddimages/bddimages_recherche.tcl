#--------------------------------------------------  
# source audace/plugin/tool/bddimages/bddimages_recherche.tcl
#--------------------------------------------------  
#
# Fichier     : bddimages_recherche.tcl
# Description : Environnement de recherche des images
#               dans la base de donnees
# Auteur      : Frédéric Vachier
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
#   -- Procedures du namespace
#
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
#        this = chemin de la fenetre
#
#    variables en sortie : 
#
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
#  init_info { }
#--------------------------------------------------  
#
#    fonction  : 
#       Initialisation de la liste des fichiers 
#       du repertoire "incoming" dans conf(dirinco)
#       pour l affichage dans la table.
#	
#    procedure externe :
#     
#    variables en entree : 
#
#    variables en sortie : 
#   
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
#  affiche_entete { }
#--------------------------------------------------  
#
#    fonction  : 
#       Permet d afficher l entete d un fichier 
#       selectionné
#	
#    procedure externe :
#     
#    variables en entree : 
#
#    variables en sortie : 
#  
#--------------------------------------------------  
#  affiche_image { }
#--------------------------------------------------  
#
#    fonction  : 
#       Permet d afficher l image d un fichier 
#       selectionné
#	
#    procedure externe :
#     
#    variables en entree : 
#
#    variables en sortie : 
#  
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
#  createTbl { frame }
#--------------------------------------------------  
#
#    fonction  : 
#       Affiche la table avec ses scrollbars dans une
#	frame et cree le menu pop-up associe
#	
#    procedure externe :
#     
#    variables en entree : 
#        frame = Fenetre ou s affiche la table
#
#    variables en sortie : 
#
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

namespace eval bddimages_recherche {

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""


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
#        this = chemin de la fenetre
#
#    variables en sortie : 
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
#  affiche_image { }
#--------------------------------------------------  
#
#    fonction  : 
#       Permet d afficher l image d un fichier 
#       selectionné
#	
#    procedure externe :
#     
#    variables en entree : 
#
#    variables en sortie : 
#  
#--------------------------------------------------  
   proc affiche_image_by_idbddimg { id } {
    set sqlcmd "SELECT dirfilename,filename FROM images WHERE idbddimg = $id"
    set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
    if {$err} {
      # TODO
      return
    }
    set nbresult [llength $resultcount]

    set colvar [lindex $resultcount 0]
    set rowvar [lindex $resultcount 1]
    set nbcol  [llength $colvar]
    set line [lindex $rowvar 0]
    set fp [file join $::bddconf(dirbase) [lindex $line 0] [lindex $line 1] ]
    set bufno $::bddconf(bufno)
#    set errnum [catch {buf$bufno load $fp} msg ]
    charge $fp

   }


   proc affiche_image { } {
      variable This
      global audace
      global conf
      global bddconf

     set i [lindex [$::bddimages_recherche::This.frame6.result.tbl curselection ]  0]
     set idbddimg  [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]

     affiche_image_by_idbddimg $idbddimg
     return
     for { set i 0 } { $i <= [ expr [llength $bddconf(listetotale)] - 1 ] } { incr i } {
       set selectfich [$::bddimages_recherche::This.frame6.result.tbl selection includes $i]
       if {$selectfich==1} {
         set nomfich [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 1]
	 set errnum [ catch { loadima $nomfich } msg ]
         if { $errnum == "1" } {
           tk_messageBox -message "$msg" -icon error
           }
	   return # affiche seulement le premier fichier selectionné et sort de la procedure
	 }
       } 
	 
      return
   }


# Lorsque le nom d'une liste a ete selectionne dans la table des listes
  proc cmd_list_select { tbl } {
   set i [$tbl curselection]
   set row [$tbl get $i $i]
   set name [lindex $row 0]
   set num [::bddimages_liste::get_intellilist_by_name $name]
#   set num [expr $i + 1]
#   ::bddimages_recherche::Affiche_listes
#   unset ::table_result($num)
   ::bddimages_recherche::get_list $num
   ::bddimages_recherche::Affiche_Results $num
  }

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
#   unset ::table_result($num)
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


# |-------------------------------------------|
# |                                           |
# | |-frame0-------------------------------|  |
# | |                                      |  | 
# | |--------------------------------------|  |
# |                                           |
# | |-frame1-------------------------------|  |
# | |                                      |  | 
# | | |---------| |----------------------| |  |
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
# | |--------------------------------------|  |
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
      if { ! [ info exists conf(bddimages,position_status) ] } { set conf(bddimages,position_status) "+80+40" }

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

      
      set nbintellilist 0
      ::bddimages_liste::conf_load_intellilists
      set bddconf(inserinfo) "Total($nbintellilist)"

      #--- Lecture des champs de la table
       
       #--- Gestion des erreurs
 #      if { [llength $bddconf(liste)] != 0} {
#      if { $erreur == "0" && $status != "failed"} {}

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
#             $This.frame0.file.menu add separator
#             $This.frame0.file.menu add command -label "$caption(search,ouvre)" -command {  }
#             $This.frame0.file.menu add command -label "$caption(search,sauve)" -command {  }
#             $This.frame0.file.menu add command -label "$caption(search,sauvess)" -command {  }
#             $This.frame0.file.menu add command -label "$caption(search,fermer_B)" -command {  }
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
             $This.frame0.aide.menu add command -label "$caption(search,aide_skybot)" -command {  }
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
           label $This.frame1.titre -font $audace(font,arial_10_b) \
                 -text "$caption(bddimages_recherche,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

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
           label $This.frame11.nbimg -font $audace(font,en_tete_2) \
               -textvariable bddconf(inserinfo)
           pack $This.frame11.nbimg -in $This.frame11 -side left -padx 3 -pady 1 -anchor w

 #      } else {
 #
 #         tk_messageBox -title $caption(bddimages_recherche,msg_erreur) -type ok -message $caption(bddimages_recherche,msg_internet)
 # #         $audace(base).bddimages.fra5.but1 configure -relief raised -state normal
 #         return
 #
 #      }


 #      ::bddimages_recherche::Affiche_Results

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
#  createTbl { frame }
#--------------------------------------------------  
#
#    fonction  : 
#       Affiche la table avec ses scrollbars dans une
#	frame et cree le menu pop-up associe
#	
#    procedure externe :
#     
#    variables en entree : 
#        frame = Fenetre ou s affiche la table
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
        # Pour marquer les reperes sur les objets
        $popupTbl add command -label $caption(bddimages_recherche,inser) \
           -command { insertion This }
        # Separateur
        $popupTbl add separator
        # Pour marquer les reperes sur les objets
        $popupTbl add checkbutton -label $caption(bddimages_recherche,inserauto)  \
           -variable bddconf(inserauto) \
           -command { } 
        # Pour marquer les reperes sur les objets
        $popupTbl add checkbutton -label $caption(bddimages_recherche,inserall)  \
           -variable bddconf(inserall) \
           -command { } 
        # Separateur
        $popupTbl add separator
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
        # Acces a l'aide
        $popupTbl add command -label $caption(bddimages_recherche,aide) \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ] 
      bind $tbl <<ListboxSelect>>          [ list ::bddimages_recherche::cmdButton1Click $This.frame6.result ]
      bind [$tbl bodypath] <Double-ButtonPress-1> { ::bddimages_recherche::affiche_image }

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

   proc Affiche_Results { i } {
      variable This
      global audace caption color
      global bddconf popupTbl
      global valMinFiltre valMaxFiltre
      global table_result
      global bddconf
      global color
      global list_of_columns
      
::console::affiche_resultat "clock seconds [clock seconds] \n"

      set list_of_columns [list "idbddimg" "filename" "telescop" "date-obs" "object" ]

      set table $table_result($i) 
      set nbobj [llength $table]
      set bddconf(inserinfo) "Total($nbobj)"
      set nbcol [llength $list_of_columns] 
       ::console::affiche_resultat "nbcol = $nbcol \n"
       ::console::affiche_resultat "nbobj = $nbobj \n"

      set affich_table ""
      foreach line $table {
       set lign_affich ""
       for { set i 0 } { $i < $nbcol} { incr i } {
           foreach var $line {
	      if {[lindex $var 0] eq [lindex $list_of_columns $i]} {
		lappend lign_affich [lindex $var 1]
                break
		}
              }
	  }
	  lappend affich_table $lign_affich
	}
      
      catch {  $::bddimages_recherche::This.frame6.result.tbl delete 0 end
	  $::bddimages_recherche::This.frame6.result.tbl deletecolumns 0 end
	  }

      for { set i 0 } { $i < $nbcol} { incr i } {
         $::bddimages_recherche::This.frame6.result.tbl insertcolumns end "30" [lindex $list_of_columns $i] left
	 }

      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::bddimages_recherche::This.frame6.result.tbl columncount ] != "0" } {
         $::bddimages_recherche::This.frame6.result.tbl columnconfigure 0 -sortmode dictionary
      }

      #--- Extraction du resultat
      foreach line $affich_table {
         $::bddimages_recherche::This.frame6.result.tbl insert end $line
        }

      #---
      if { [ $::bddimages_recherche::This.frame6.result.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set i 0 } { $i < [ expr $nbobj - 1] } { incr i } {
           # $::bddimages_recherche::This.frame6.result.tbl cellconfigure $i,1 -fg $color(blue)
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

       ::console::affiche_resultat "--nbintellilist : $nbintellilist \n"
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

   global indicereq
   global list_req
   global form_req
   global caption
   global intellilisttotal
   global list_key_to_var
   global table_result


   set laliste  $intellilisttotal($i)
   set val [lindex $laliste 0] 
   set intellilist(name) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set val [lindex $laliste 0] 
   set intellilist(type_req_check) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set val [lindex $laliste 0] 
   set intellilist(type_requ) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set val [lindex $laliste 0] 
   set intellilist(choix_limit_result) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set val [lindex $laliste 0] 
   set intellilist(limit_result) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set val [lindex $laliste 0] 
   set intellilist(type_result) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set val [lindex $laliste 0] 
   set intellilist(type_select) [lindex $val 1]
   set laliste [::ldelete $laliste 0]

   set nbcond [llength $laliste]
   foreach val $laliste {
     set x [lindex $val 0]
     set intellilist($x,champ)     [lindex $val 1]
     set intellilist($x,condition) [lindex $val 2]
     set intellilist($x,valeur)    [lindex $val 3]
     }


  ::console::affiche_resultat "-- affich_form_req\n "
  ::console::affiche_resultat "name           		= $intellilist(name)\n"
  ::console::affiche_resultat "type_req_check 		= $intellilist(type_req_check)\n"
  ::console::affiche_resultat "type_requ 		= $intellilist(type_requ)\n"
  ::console::affiche_resultat "choix_limit_result	= $intellilist(choix_limit_result)\n"
  ::console::affiche_resultat "limit_result		= $intellilist(limit_result)\n"
  ::console::affiche_resultat "type_result		= $intellilist(type_result)\n"
  ::console::affiche_resultat "type_select		= $intellilist(type_select)\n"
  ::console::affiche_resultat "nbcond			= $nbcond\n"


  if { $intellilist(type_req_check)==0} {
    set intellilist(nbimg) "?"
    return
    }
 
  set cond "UNKNOWNOP" 
  if { $intellilist(type_requ)==$caption(bddimages_liste,toutes)} {
    set cond "AND"
    }
  if { $intellilist(type_requ)==$caption(bddimages_liste,nimporte)} {
    set cond "OR"
    }

  set cpt 0
  set sqlcriteres {}
  for {set x 1} {$x<=$nbcond} {incr x} {
    if {$cpt==0} {
      set sqlcritere "`$list_key_to_var($intellilist($x,champ))` $intellilist($x,condition) '$intellilist($x,valeur)' "
      } else {
      set sqlcritere "$sqlcritere $cond `$list_key_to_var($intellilist($x,champ))` $intellilist($x,condition) '$intellilist($x,valeur)' "
      }
      lappend sqlcriteres $sqlcritere
    }

  set sqlcritere [join $sqlcriteres " $cond " ]

  ::console::affiche_resultat "lecture des idheader : "
  set sqlcmd "SELECT DISTINCT idheader FROM header;"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
     bddimages_sauve_fich "Erreur de lecture de la table header par SQL"
     bddimages_sauve_fich "	sqlcmd = $sqlcmd"
     bddimages_sauve_fich "	err = $err"
     bddimages_sauve_fich "	msg = $msg"
     set intellilist(nbimg) "Error"
     return
     }
  ::console::affiche_resultat "[llength $resultsql ]\n"

  set intellilist(nbimg) 0
  set table ""
  

  foreach line $resultsql {
    set idhd [lindex $line 0]
    ::console::affiche_resultat "**+++ $idhd \n"
    set sqlcmd "SELECT images.idheader,images.tabname,images.filename,
                images.dirfilename,images.sizefich,images.datemodif, 
                images_$idhd.* FROM images,images_$idhd 
		WHERE images.idbddimg=images_$idhd.idbddimg AND ($sqlcritere);"
    set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
    if {[string first "Unknown column" $msg]==-1} {
       if {$err} {
	  bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
	  bddimages_sauve_fich "	sqlcmd = $sqlcmd"
	  bddimages_sauve_fich "	err = $err"
	  bddimages_sauve_fich "	msg = $msg"
	  set intellilist(nbimg) "Error"     
	  return
	  }
      ::console::affiche_resultat "nb images [llength $resultcount ]\n"

       set nbresult [llength $resultcount]
       set nbcol    [llength $resultcount]

       if {$nbresult>0} {

         set colvar [lindex $resultcount 0]
         set rowvar [lindex $resultcount 1]
         set nbcol  [llength $colvar]

	 foreach line $rowvar {
	   set resultline ""
           set cpt 0
	   foreach col $colvar {
             lappend resultline [list $col [lindex $line $cpt]]
	     incr cpt
             }
	       
	     lappend table $resultline
	   }

	 }
      
       } else {
       }
    }

  ::console::affiche_resultat "** nb data in table [llength $table] \n"
  set table_result($i) $table
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
