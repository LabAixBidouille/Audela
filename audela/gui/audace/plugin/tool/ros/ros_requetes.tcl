#--------------------------------------------------
# source audace/plugin/tool/ros/ros_requetes.tcl
#--------------------------------------------------
#
# Fichier        : ros_requetes.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace ros_requetes
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  ros_requetes.cap
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
#  affiche_scenes
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

namespace eval ros_requetes {

   global audace
   global rosconf


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

      set entetelog "requetes"
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

      ::ros_requetes::recup_position
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
      global rosconf

      set rosconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $rosconf(geometry_status) ] ]
      set fin [ string length $rosconf(geometry_status) ]
      set rosconf(position_status) "+[ string range $rosconf(geometry_status) $deb $fin ]"
      #---
      set conf(ros,position_status) $rosconf(position_status)
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
   proc affiche_scene_by_idscene { id } {
     
      set sqlcmd "SELECT dirfilename,filename FROM images WHERE idbddimg = $id"
      set err [catch {set resultcount [::ros_sql::sql select $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$msg" -type ok
         return
      }

      set nbresult [llength $resultcount]
      set colvar [lindex $resultcount 0]
      set rowvar [lindex $resultcount 1]
      set nbcol  [llength $colvar]
      set line [lindex $rowvar 0]
      set fp [file join $::rosconf(dirbase) [lindex $line 0] [lindex $line 1] ]
      set bufno $::rosconf(bufno)
#      set errnum [catch {buf$bufno load $fp} msg ]
      charge $fp

   }


   proc affiche_scene { } {
      variable This
      global audace
      global conf
      global rosconf

      set i [lindex [$::ros_requetes::This.frame6.requests.tbl curselection ]  0]
      set idbddimg  [lindex [$::ros_requetes::This.frame6.requests.tbl get $i] 0]

      affiche_scene_by_idscene $idbddimg
      return
   }


  
  
  
  # Lorsque le nom d'une liste a ete selectionne dans la table des listes
  proc cmd_scenes_select { tbl } {

     set i [$tbl curselection]
     set row [$tbl get $i $i]
     set name [lindex $row 0]
     set num 0
     }






  proc cmd_requests_delete { tbl } {
     set i [$tbl curselection]
     set row [$tbl get $i $i]
     set name [lindex $row 0]
     set num 0
     for { set i 0 } { $i < $::nbreq } { incr i } {
      set ::reqlisttotal($i) $::reqlisttotal([expr $i+1])
     }
     set ::nbreq [expr $::nbreq - 1]
     ::ros_requetes::Affiche_req
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

   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global rosconf

      variable nbreq
      variable reqlisttotal

      #--- initConf
      if { ! [ info exists conf(ros,position_status) ] } { set conf(ros,position_status) "+80+40" }

      #--- confToWidget
      set rosconf(position_status) $conf(ros,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists rosconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $rosconf(geometry_status) ] ]
         set fin [ string length $rosconf(geometry_status) ]
         set rosconf(position_status) "+[ string range $rosconf(geometry_status) $deb $fin ]"
      }

      set nbreq 0
      set rosconf(inserinfo) "Nb req ($nbreq)"

      #--- Lecture des champs de la table

       #--- Gestion des erreurs

         #---
         toplevel $This -class Toplevel
         wm geometry $This $rosconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(ros_requetes,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::ros_requetes::fermer }


         #--- Cree un menu pour le panneau
         frame $This.frame0 -borderwidth 1 -relief raised
         pack $This.frame0 -side top -fill x
           #--- menu Requetes
           menubutton $This.frame0.file -text "$caption(search,requetes)" -underline 0 -menu $This.frame0.file.menu
           menu $This.frame0.file.menu
             $This.frame0.file.menu add command -label "$caption(ros_requetes,get_requests)" -command { ::ros_requetes::charge_requetes }
             $This.frame0.file.menu add command -label "Efface (Ctrl+s)"   -command { }
             $This.frame0.file.menu add command -label "Nouvelle (Ctrl+n)" -command { }
           pack $This.frame0.file -side left
           #--- menu Scenes
           menubutton $This.frame0.image -text "Scenes" -underline 0 -menu $This.frame0.image.menu
           menu $This.frame0.image.menu
             $This.frame0.image.menu add command -label "Efface (Ctrl+s)"   -command { }
             $This.frame0.image.menu add command -label "Nouvelle (Ctrl+n)" -command { }
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
           label $This.frame1.titre -font $rosconf(font,arial_10_b) \
                 -text "$caption(ros_requetes,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

	 #--- Cree un frame pour l'affichage des deux listes
	 frame $This.frame6 -borderwidth 0
	 pack $This.frame6 -expand yes -fill both -padx 3 -pady 6


	 #--- Cree un frame pour l'affichage de la liste des results
	 frame $This.frame6.scenes -borderwidth 0
	 pack $This.frame6.scenes -expand yes -fill both -padx 3 -pady 6 -in $This.frame6 -side right -anchor e

            #--- Cree un acsenseur vertical
            scrollbar $This.frame6.scenes.vsb -orient vertical \
               -command { $::ros_requetes::This.frame6.scenes.lst1 yview } -takefocus 1 -borderwidth 1
            pack $This.frame6.scenes.vsb \
               -in $This.frame6.scenes -side right -fill y

            #--- Cree un acsenseur horizontal
            scrollbar $This.frame6.scenes.hsb -orient horizontal \
               -command { $::ros_requetes::This.frame6.scenes.lst1 xview } -takefocus 1 -borderwidth 1
            pack $This.frame6.scenes.hsb \
               -in $This.frame6.scenes -side bottom -fill x

            #--- Creation de la table
            ::ros_requetes::createTbl1 $This.frame6.scenes
            pack $This.frame6.scenes.tbl -in $This.frame6.scenes -expand yes -fill both


	 #--- Cree un frame pour l'affichage de la liste des images
	 frame $This.frame6.requests -borderwidth 0
	 pack $This.frame6.requests -expand yes -fill both -padx 3 -pady 6 -in $This.frame6


            #--- Cree un acsenseur vertical
            scrollbar $This.frame6.requests.vsb -orient vertical \
               -command { $::ros_requetes::This.frame6.requests.lst1 yview } -takefocus 1 -borderwidth 1
            pack $This.frame6.requests.vsb \
               -in $This.frame6.requests -side right -fill y

            #--- Cree un acsenseur horizontal
            scrollbar $This.frame6.requests.hsb -orient horizontal \
               -command { $::ros_requetes::This.frame6.requests.lst1 xview } -takefocus 1 -borderwidth 1
            pack $This.frame6.requests.hsb \
               -in $This.frame6.requests -side bottom -fill x

            #--- Creation de la table
            ::ros_requetes::createTbl2 $This.frame6.requests
            pack $This.frame6.requests.tbl -in $This.frame6.requests -expand yes -fill both

         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(ros_requetes,fermer)" -borderwidth 2 \
              -command { ::ros_requetes::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(ros_requetes,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool ros ros.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Cree un label pour le nb image
           label $This.frame11.nbimg -font $rosconf(font,arial_12_b) \
               -textvariable rosconf(inserinfo)
           pack $This.frame11.nbimg -in $This.frame11 -side left -padx 3 -pady 1 -anchor w

      

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
   }




   proc createTbl2 { frame } {
      variable This
      global audace
      global caption
      global rosconf
      global popupTbl
      global paramwindow

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl
      set popupTbl $frame.popupTbl
      set filtres $frame.popupTbl.filtres
      set paramwindow $This.param

      #--- Table des objets
      tablelist::tablelist $tbl \
         -labelcommand ::ros_requetes::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table
      menu $popupTbl -title $caption(ros_requetes,titre)

        # Label
        $popupTbl add command -label "$caption(ros_requetes,get_scenes)" \
           -command {  }
        $popupTbl add command -label "$caption(ros_requetes,edit)" \
           -command [list ::ros_requetes::Tbl2Edit $tbl ]
        # Separateur
        $popupTbl add separator
        # Acces a l'aide
        $popupTbl add command -label $caption(ros_requetes,aide) \
           -command { ::audace::showHelpPlugin tool ros ros.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind $tbl <<ListboxSelect>>          [ list ::ros_requetes::cmdButton1Click $This.frame6.scenes ]
      bind [$tbl bodypath] <Double-ButtonPress-1> { ::ros_requetes::charge_scenes }

   }









   proc createTbl1 { frame } {
      variable This
      global audace
      global caption
      global rosconf
      global popupTbl
      global paramwindow

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl
      set popupTbl $frame.popupTbl
      set filtres $frame.popupTbl.filtres
      set paramwindow $This.param

      #--- Table des objets
      tablelist::tablelist $tbl \
         -labelcommand ::ros_requetes::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table
      menu $popupTbl -title $caption(ros_requetes,titre)
        # Labels des objets dans l'image
        $popupTbl add command -label $caption(ros_requetes,selectall) \
           -command { $::ros_requetes::This.frame6.scenes.tbl selection set 0 end }
        # Separateur
        $popupTbl add separator
        # Labels charger image
        $popupTbl add command -label $caption(ros_requetes,voirimg) \
           -command { }
        # Labels Lire le Header
        $popupTbl add command -label $caption(ros_requetes,voirheader) \
           -command { }
        # Separateur
        $popupTbl add separator
        # Acces a l'aide
        $popupTbl add command -label $caption(ros_requetes,aide) \
           -command { ::audace::showHelpPlugin tool ros ros.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind $tbl <<ListboxSelect>>          [ list ::ros_requetes::cmdButton1Click $This.frame6.scenes ]

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





   proc affiche_scenes { i } {
      variable This
      global audace caption color
      global rosconf popupTbl
      global valMinFiltre valMaxFiltre
      global table_result
      global rosconf
      global color
      global list_of_columns

      ::console::affiche_resultat "clock seconds [clock seconds] \n"

      set list_of_columns [list "id" "sname" ]

      set table $table_result($i)
      set nbobj [llength $table]
      set rosconf(inserinfo) "Total($nbobj)"
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

      catch {  $::ros_requetes::This.frame6.scenes.tbl delete 0 end
	  $::ros_requetes::This.frame6.scenes.tbl deletecolumns 0 end
	  }

      for { set i 0 } { $i < $nbcol} { incr i } {
         $::ros_requetes::This.frame6.scenes.tbl insertcolumns end "30" [lindex $list_of_columns $i] left
	 }

      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::ros_requetes::This.frame6.scenes.tbl columncount ] != "0" } {
         $::ros_requetes::This.frame6.scenes.tbl columnconfigure 0 -sortmode dictionary
      }

      #--- Extraction du resultat
      foreach line $affich_table {
         $::ros_requetes::This.frame6.scenes.tbl insert end $line
        }

      #---
      if { [ $::ros_requetes::This.frame6.scenes.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set i 0 } { $i < [ expr $nbobj - 1] } { incr i } {
           # $::ros_requetes::This.frame6.scenes.tbl cellconfigure $i,1 -fg $color(blue)
         }
         #--- Trie par ordre alphabetique de la premiere colonne
         ::ros_requetes::cmdSortColumn $::ros_requetes::This.frame6.scenes.tbl 0
      }
   }




#--------------------------------------------------
#  charge_scenes
#--------------------------------------------------
#
#    fonction  :
#	forme la liste des requetes pour l affichage
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
   proc charge_scenes {  } {
      variable nbscenes
      variable sceneslisttotal
      global rosconf
 
     set sceneslisttotal [::ros_webservice::scenes_list]
     set nbscenes [llength $sceneslisttotal]
     set rosconf(inserinfo) "Nb req ($nbreq) Nb scenes ($nbscenes)"
     #::ros_requetes::Affiche_scenes
   }


#--------------------------------------------------
#  charge_requetes
#--------------------------------------------------
#
#    fonction  :
#	forme la liste des requetes pour l affichage
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
   proc charge_requetes {  } {
      variable nbreq
      variable reqlisttotal
      global rosconf
 
     set reqlisttotal [::ros_webservice::request_list]
     set nbreq [llength $reqlisttotal]
     set rosconf(inserinfo) "Nb req ($nbreq)"
     ::ros_requetes::Affiche_req
   }

#--------------------------------------------------
#  Affiche_req
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

   proc ::ros_requetes::Affiche_req { } {

      variable This
      global audace caption color
      global rosconf popupTbl
      global valMinFiltre valMaxFiltre
      variable nbreq
      variable reqlisttotal

      catch {  $::ros_requetes::This.frame6.requests.tbl delete 0 end
         $::ros_requetes::This.frame6.requests.tbl deletecolumns 0 end
         }

      $::ros_requetes::This.frame6.requests.tbl insertcolumns end "20" "Requetes" left


      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::ros_requetes::This.frame6.requests.tbl columncount ] != "0" } {
         $::ros_requetes::This.frame6.requests.tbl columnconfigure 0 -sortmode dictionary
      }

      #::console::affiche_resultat "--nbreq : $nbreq \n"

      #--- Extraction du resultat
      foreach rname $reqlisttotal {
        $::ros_requetes::This.frame6.requests.tbl insert end $rname
        }
        
      #---
      if { [ $::ros_requetes::This.frame6.requests.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set i 0 } { $i <= [ expr $nbreq - 1 ] } { incr i } {
            $::ros_requetes::This.frame6.requests.tbl cellconfigure $i,0 -fg $color(blue)
         }
         #--- Trie par ordre alphabetique de la premiere colonne
         ::ros_requetes::cmdSortColumn $::ros_requetes::This.frame6.requests.tbl 0
      }
   }


}




 proc ::ldelete {liste index} {

 }

