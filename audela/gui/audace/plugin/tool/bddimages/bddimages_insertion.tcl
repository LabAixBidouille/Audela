#--------------------------------------------------  
# source audace/plugin/tool/bddimages/bddimages_insertion.tcl
#--------------------------------------------------  
#
# Fichier     : bddimages_insertion.tcl
# Description : Environnement d'inssertion des images
#               dans la base de donnees
# Auteur      : Frédéric Vachier
#
#--------------------------------------------------  
#
# - namespace bddimages_insertion
#
#--------------------------------------------------  
#
#   -- Fichiers source externe :
#
#  bddimages_insertion.cap
#  bddimages_insertion_applet.cap
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

namespace eval bddimages_insertion {

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""


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

      ::bddimages_insertion::recup_position
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
proc affiche_entete { } {

  variable This
  global audace
  global conf
  global bddconf

  for { set i 0 } { $i <= [ expr [llength $bddconf(listetotale)] - 1 ] } { incr i } {
    set selectfich [$::bddimages_insertion::This.frame7.tbl selection includes $i]
    if {$selectfich==1} {
      set nomfich [lindex [$::bddimages_insertion::This.frame7.tbl get $i] 1]
      ::audace::header $nomfich
      return # affiche seulement le premier fichier selectionné et sort de la procedure
      }
    }
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
proc affiche_image { } {

  variable This
  global audace
  global conf
  global bddconf

  for { set i 0 } { $i <= [ expr [llength $bddconf(listetotale)] - 1 ] } { incr i } {
    set selectfich [$::bddimages_insertion::This.frame7.tbl selection includes $i]
    if {$selectfich==1} {
      set nomfich [lindex [$::bddimages_insertion::This.frame7.tbl get $i] 1]
      set errnum [ catch { loadima $nomfich } msg ]
      if { $errnum == "1" } {
        tk_messageBox -message "$msg" -icon error
        }
        return 
        # affiche seulement le premier fichier selectionné et sort de la procedure
      }
    } 
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
   proc createDialog { } {

      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf

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

      
      set bddconf(inserinfo) "Total(-) Inser(-) Err(-)"

      #--- Lecture des champs de la table
      init_info

      #--- Gestion des erreurs
      if { [llength $bddconf(liste)] != 0} {

         #---
         toplevel $This -class Toplevel
         wm geometry $This $bddconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(bddimages_insertion,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_insertion::fermer }


         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x

           #--- Cree un label pour le titre
           label $This.frame1.titre \
                 -text "$caption(bddimages_insertion,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3


         #--- Cree un frame pour l'affichage du resultat de la recherche
         frame $This.frame7 -borderwidth 0
         pack $This.frame7 -expand yes -fill both -padx 3 -pady 6

            #--- Cree un acsenseur vertical
            scrollbar $This.frame7.vsb -orient vertical \
               -command { $::bddimages_insertion::This.frame7.lst1 yview } -takefocus 1 -borderwidth 1
            pack $This.frame7.vsb \
               -in $This.frame7 -side right -fill y

            #--- Cree un acsenseur horizontal
            scrollbar $This.frame7.hsb -orient horizontal \
               -command { $::bddimages_insertion::This.frame7.lst1 xview } -takefocus 1 -borderwidth 1
            pack $This.frame7.hsb \
               -in $This.frame7 -side bottom -fill x

            #--- Creation de la table
            ::bddimages_insertion::createTbl $This.frame7
            pack $This.frame7.tbl -in $This.frame7 -expand yes -fill both



         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(bddimages_insertion,fermer)" -borderwidth 2 \
              -command { ::bddimages_insertion::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bddimages_insertion,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton lecture entete
           button $This.frame11.but_lectentete \
              -text "$caption(bddimages_insertion,lectentete)" -borderwidth 2 \
              -command {lecture_info This}
           pack $This.frame11.but_lectentete \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton insertion
           button $This.frame11.but_insertion \
              -text "$caption(bddimages_insertion,inser)" -borderwidth 2 \
              -command { insertion This }
           pack $This.frame11.but_insertion \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton insertion
           button $This.frame11.but_refresh \
              -text "$caption(bddimages_insertion,refresh)" -borderwidth 2 \
              -command { 
                        ::bddimages_insertion::getFormatColumn
		       $::bddimages_insertion::This.frame7.tbl delete 0 end
		       $::bddimages_insertion::This.frame7.tbl deletecolumns 0 end
			init_info
			::bddimages_insertion::Affiche_Results
                       }
           pack $This.frame11.but_refresh \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Cree un label pour le nb image
           label $This.frame11.nbimg -font $audace(font,en_tete_2) \
               -textvariable bddconf(inserinfo)
           pack $This.frame11.nbimg -in $This.frame11 -side left -padx 3 -pady 1 -anchor w

      } else {

         tk_messageBox -title $caption(bddimages_insertion,msg_erreur) -type ok -message $caption(bddimages_insertion,msg_internet)
         #$audace(base).bddimages.fra5.but1 configure -relief raised -state normal
         return

      }

      ::bddimages_insertion::Affiche_Results

      #--- Gestion du bouton
      #-$audace(base).bddimages.fra5.but1 configure -relief raised -state normal

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

   proc createTbl { frame } {
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
         -labelcommand ::bddimages_insertion::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale 
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table 
      menu $popupTbl -title $caption(bddimages_insertion,titre)
      #$caption(status,popup_tbl)
        # Pour marquer les reperes sur les objets
        $popupTbl add command -label $caption(bddimages_insertion,inser) \
           -command { insertion This }
        # Separateur
        $popupTbl add separator
        # Pour marquer les reperes sur les objets
        $popupTbl add checkbutton -label $caption(bddimages_insertion,inserauto)  \
           -variable bddconf(inserauto) \
           -command { } 
        # Pour marquer les reperes sur les objets
        $popupTbl add checkbutton -label $caption(bddimages_insertion,inserall)  \
           -variable bddconf(inserall) \
           -command { } 
        # Separateur
        $popupTbl add separator
        # Labels des objets dans l'image
        $popupTbl add command -label $caption(bddimages_insertion,selectall) \
           -command { $::bddimages_insertion::This.frame7.tbl selection set 0 end }
        # Separateur
        $popupTbl add separator
        # Labels charger image
        $popupTbl add command -label $caption(bddimages_insertion,voirimg) \
           -command { ::bddimages_insertion::affiche_image }
        # Labels Lire le Header
        $popupTbl add command -label $caption(bddimages_insertion,voirheader) \
           -command { ::bddimages_insertion::affiche_entete}
        # Separateur
        $popupTbl add separator
        # Acces a l'aide
        $popupTbl add command -label "$caption(bddimages_insertion,aide)" \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm field_2 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ] 
      bind $tbl <<ListboxSelect>>          [ list ::bddimages_insertion::cmdButton1Click $This.frame7 ]

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

   proc getFormatColumn { } {
      global column_format
      global caption
          
      set column_format($caption(bddimages_insertion,etat))      [ list [ $::bddimages_insertion::This.frame7.tbl columncget 0 -width] "$caption(bddimages_insertion,etat)"      left ]
      set column_format($caption(bddimages_insertion,nom))       [ list [ $::bddimages_insertion::This.frame7.tbl columncget 1 -width] "$caption(bddimages_insertion,nom)"       left ]
      set column_format($caption(bddimages_insertion,dateobs))   [ list [ $::bddimages_insertion::This.frame7.tbl columncget 2 -width] "$caption(bddimages_insertion,dateobs)"   left ]
      set column_format($caption(bddimages_insertion,telescope)) [ list [ $::bddimages_insertion::This.frame7.tbl columncget 3 -width] "$caption(bddimages_insertion,telescope)" left ]
      set column_format($caption(bddimages_insertion,taille))    [ list [ $::bddimages_insertion::This.frame7.tbl columncget 4 -width] "$caption(bddimages_insertion,taille)"	 left ]
      set column_format($caption(bddimages_insertion,erreur))    [ list [ $::bddimages_insertion::This.frame7.tbl columncget 5 -width] "$caption(bddimages_insertion,erreur)"	 left ]
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
      global column_format

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

   proc Affiche_Results { } {
      variable This
      global audace caption color
      global bddconf popupTbl
      global valMinFiltre valMaxFiltre

      set liste_titres [ lindex $bddconf(liste) 0 ]
      for { set i 0 } { $i <= [ expr [ llength $liste_titres ] - 1 ] } { incr i } {
         set format [ ::bddimages_insertion::cmdFormatColumn [ lindex $liste_titres $i ] ]
         $::bddimages_insertion::This.frame7.tbl insertcolumns end [ lindex $format 0 ] [ lindex $format 1 ] [ lindex $format 2 ]
	 }

      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::bddimages_insertion::This.frame7.tbl columncount ] != "0" } {
         $::bddimages_insertion::This.frame7.tbl columnconfigure 1 -sortmode dictionary
      }

      #--- Extraction du resultat
      set bddconf(j) 0
      for { set i 1 } { $i <= [ expr [ llength $bddconf(liste) ] - 1 ] } { incr i } {
         set objet($i) [ lindex $bddconf(liste) $i ]
         for { set j 0 } { $j <= [ expr [ llength $objet($i) ] - 1 ] } { incr j } {
            $::bddimages_insertion::This.frame7.tbl insert end [ lindex $objet($i) $j ]
         }
      }
      #---
      if { [ $::bddimages_insertion::This.frame7.tbl columncount ] != "0" } {
         #--- Les noms des objets sont en bleu
         for { set i 0 } { $i <= [ expr $bddconf(j) - 1 ] } { incr i } {
            $::bddimages_insertion::This.frame7.tbl cellconfigure $i,1 -fg $color(blue)
         }
         #--- Trie par ordre alphabetique de la premiere colonne 
         ::bddimages_insertion::cmdSortColumn $::bddimages_insertion::This.frame7.tbl 1
      }
   }



}

