#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_define.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_define.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace bddimages_define
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_define.cap
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
#  cmdFormatColumn { column_name }
#--------------------------------------------------
#
#    fonction  :
#       Definit la largeur, la traduction du titre
#       et la justification des colonnes
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
#       Trie les lignes par ordre alphabetique de
#       la colonne (est appele quand on clique sur
#       le titre de la colonne)
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
#       Affiche la liste des objets de l'image
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------

namespace eval bddimages_define {

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste_creation.tcl ]\""


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

   proc run { this {listname ?} } {
      variable This
      global entetelog


      ::console::affiche_resultat "Liste courante :   ($::bddimages_recherche::current_list_id) $::bddimages_recherche::current_list_name \n"
      set entetelog "liste"
      set This $this
      createDialog $listname
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

      ::bddimages_define::recup_position
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

      set bddconf(list_geom_stat) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $bddconf(list_geom_stat) ] ]
      set fin [ string length $bddconf(list_geom_stat) ]
      set bddconf(list_pos_stat) "+[ string range $bddconf(list_geom_stat) $deb $fin ]"
      #---
      set conf(bddimages,list_pos_stat) $bddconf(list_pos_stat)
      return
   }


proc remove_requete { } {

  variable This
   global indicereq
   global list_req


  for {set x 1} {$x<=$indicereq} {incr x} {
    set err [catch {set a [$This.framereq.$x.sup cget -state]} msg ]
    if {!$err} {
      if {$a == "active" } {set i $x}
      }
    }


  set list_req($i,valide) "no"
  destroy $This.framereq.$i

}

#--------------------------------------------------
#  get_list_box_champs { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des champs
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste
#
#--------------------------------------------------
proc get_list_box_champs { } {

   global list_key_to_var

   set list_box_champs [list ]
   set nbl1 0
   set sqlcmd "select distinct keyname,variable from header order by keyname;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
      return -code error "Erreur de lecture de la liste des header par SQL"
   }
   foreach line $resultsql {
      set key [lindex $line 0]
      set var [lindex $line 1]
      set list_key_to_var($key) $var
      if {$nbl1<[string length $key]} {
         set nbl1 [string length $key]
      }
      lappend list_box_champs $key
   }
   set nbl1 [expr $nbl1 + 3]
   return [list $nbl1 $list_box_champs]
}



proc get_var_type { var } {

  set i [regexp -all {^[-+]?[0-9]+$} $var]
  if {$i == 1 } {return "int"}

  set i [regexp -all {^[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?$} $var]
  if {$i == 1 } {return "double"}

  set i [regexp -nocase {^.*[a-z].*$} $var]
  if {$i == 1 } {return "string"}

 return

}






proc accept { } {

   global form_req
   global caption

   global indicereq
   global list_req
   global bddconf

   #::console::affiche_resultat "Modification de l image \n"

   #::console::affiche_resultat "id list = $bddconf(define) \n"
   #::console::affiche_resultat "set compatible = $form_req(type_req_check) \n"

   foreach idbddimg $bddconf(define) {

      set change "no"

      ::console::affiche_resultat "idbddimg = $idbddimg  \n"
      # charge l image
      set ident [bddimages_image_identification $idbddimg]
      ::console::affiche_resultat "Chargement de $ident \n"
      set fileimg  [lindex $ident 1]
      
      if {$fileimg==-1} {
         ::console::affiche_resultat "Fichier image inexistant ($idbddimg) \n"
         ::bddimages_define::fermer
         return
         }
      
      set filecata [lindex $ident 3]
      ::console::affiche_resultat "Chargement de $fileimg \n"
      set bufno [::buf::create]
      buf$bufno load $fileimg
      
      if {$form_req(type_req_check)==1} {
         # verifie la compatibilite
         #::console::affiche_resultat "verifie la compatibilite \n"
         if {[::bddimagesAdmin::bdi_compatible $bufno] == 0 } {
            #::console::affiche_resultat "rend l image compatible \n"
            ::bddimagesAdmin::bdi_setcompat $bufno
            set change "yes"
            }
         }

      for { set x 1 } { $x <= $indicereq } { incr x } {
         #::console::affiche_resultat "Modification utilisateur \n"
         # modifie le header fits de l image
         if {$list_req($x,valide)=="ok"} {
            set key [buf$bufno getkwd $list_req($x,champ)]
            #::console::affiche_resultat "AV Modif: $key \n"
            set key [lreplace $key 0 0 $list_req($x,champ)]
            set key [lreplace $key 1 1 $list_req($x,valeur)]

            set vartype [lindex $key 2]
            set evalvartype [get_var_type [lindex $key 1]]
            #::console::affiche_erreur "[lindex $key 1] est de type $evalvartype \n"
            if {$vartype == "none"} {
               set key [lreplace $key 2 2 $evalvartype]
               } elseif {$vartype != $evalvartype} {
                 ::console::affiche_erreur "WARNING ! le type de variable a change $vartype -> $evalvartype \n"
                 set key [lreplace $key 2 2 $evalvartype]
                 }
            #::console::affiche_resultat "Modif: $key \n"
            buf$bufno setkwd $key
            set key [buf$bufno getkwd $list_req($x,champ)]
            #::console::affiche_resultat "AP Modif: $key \n"
            set change "yes"
            }
         }

      if {$change=="yes"} {
         # enregistre les modif dans l image
         set fichtmpunzip [unzipedfilename $fileimg]

         set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
         set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]
         #::console::affiche_resultat "Sauvegarde fichier temporaire : $filetmp \n"
         createdir_ifnot_exist $bddconf(dirtmp)
         buf$bufno save $filetmp
         #::console::affiche_resultat "Compression vers $filefinal \n"
         set errnum [catch {exec gzip -c $filetmp > $filefinal} msg ]
      
         # copie l image dans incoming, ainsi que le fichier cata si il existe
         if {$filecata!=-1} {
            set errnum [catch {file rename -force -- $filecata $bddconf(dirinco)/.} msg ]
            }
            
         # efface l image dans la base et le disque
         bddimages_image_delete_fromsql $ident
         bddimages_image_delete_fromdisk $ident
         
         # insere l image et le cata dans la base
         insertion_solo $filefinal
         if {$filecata!=-1} {
            set filecata [file join $bddconf(dirinco) [file tail $filecata]]
            insertion_solo $filecata
            }

         set errnum [catch {file delete -force $filetmp} msg ]

         }


      buf$bufno clear
   
      
      }

   # Rechargement de la liste courante
   ::bddimages_recherche::cmd_list_select $::bddimages_recherche::tbl_cmd_list_select

   ::bddimages_define::fermer
   }

#--------------------------------------------------
#  add_requete { }
#--------------------------------------------------
#
#    fonction  :
#       ajout d'une requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : none
#
#--------------------------------------------------

proc add_requete { } {

   variable This
   global audace
   global caption
   global bddconf
   global indicereq
   global list_req


  #--- Initialisation des combox
  set result [get_list_box_champs]
  set list_box_champs [lindex $result 1]
  set nbrows1 [ llength $list_box_champs ]
  set nbcols1 [lindex $result 0]
  set list_combobox "="
  set nbrows2 1
  set nbcols2 13


  #--- Initialisation de la liste des requetes
  set indicereq [expr $indicereq + 1]

  if { [ info exists list_req($indicereq,champ) ] } {
  set list_req($indicereq,valide) "ok"
  } else {
  set list_req($indicereq,champ)     [lindex $list_box_champs 0]
  set list_req($indicereq,condition) "="
  set list_req($indicereq,valeur) ""
  set list_req($indicereq,valide) "ok"
  }


  #--- frame pour afficher les requetes
  set frch $This.framereq

  #--- Cree un frame pour la requete
  set frchch $frch.$indicereq
  frame $frchch -borderwidth 1 -relief solid
  pack $frchch -in $frch -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

    #--- Cree la liste des champs
    ComboBox $frchch.combo1 \
       -width $nbcols1 -height 15 \
       -relief sunken -borderwidth 1 -editable 0 \
       -textvariable list_req($indicereq,champ) \
       -values $list_box_champs
    pack $frchch.combo1 -anchor center -side left -fill x -expand 1
    grid $frchch -sticky new
    #--- Cree la liste des conditions
    label $frchch.combo -font $bddconf(font,arial_10_b) -text "="
    pack $frchch.combo -in $frchch -side left -anchor w -padx 1
    #--- Cree une ligne d'entree pour la variable
    entry $frchch.dat -textvariable list_req($indicereq,valeur) -borderwidth 1 -relief groove -width 25 -justify left
    pack $frchch.dat -in $frchch -side left -anchor w -padx 1
    #--- Cree un bouton supprime requete
    button $frchch.sup -state normal -borderwidth 1 -relief groove -anchor c -height 1 \
       -text "-" -command { ::bddimages_define::remove_requete }

    pack $frchch.sup -in $frchch -side left -anchor w -padx 1
    #--- Cree un bouton ajout requete
    button $frchch.add -state active -borderwidth 1 -relief groove -anchor c -height 1 \
       -text "+" -command { ::bddimages_define::add_requete }
    pack $frchch.add -in $frchch -side left -anchor w -padx 1

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


# |-------------------------------------------|
# |                                           |
# | |-frame0-------------------------------|  |
# | |                                      |  |
# | |--------------------------------------|  |
# |                                           |
# | |-framereq-----------------------------|  |
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


   proc createDialog { listname } {
      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf
      global intellilisttotal

      global indicereq
      global form_req

      set indicereq 0

      global list_req

      ::console::affiche_resultat "createDialog : $listname \n"

      set list_comb1 [list $caption(bddimages_define,toutes) $caption(bddimages_define,nimporte)]
      set list_comb2 [list $caption(bddimages_define,elem)]
      set list_comb3 [list $caption(bddimages_define,alea) \
                           $caption(bddimages_define,dateobs) \
                           $caption(bddimages_define,telescope) \
                           $caption(bddimages_define,plrecmod) \
                           $caption(bddimages_define,morecmod) \
                           $caption(bddimages_define,plrecajo) \
                           $caption(bddimages_define,morecajo) ]

      set form_req(name) "Newlist[ expr $::nbintellilist + 1 ]"
      set form_req(type_req_check) 1
      set form_req(type_requ) [lindex $list_comb1 0]
      set form_req(choix_limit_result) ""
      set form_req(limit_result) "25"
      set form_req(type_result) [lindex $list_comb2 0]
      set form_req(type_select) [lindex $list_comb3 0]
      set form_req(nbimg) "?"

      set edit 0
      if { ! ($listname eq "?") } {
        set edit 1
        set editname $listname
        set editid [get_intellilist_by_name $listname]
        ::console::affiche_resultat "createDialog : $listname id=$editid \n"

      }

      set indicereqinit 0

      if { $edit } {
        set  l $intellilisttotal($editid)
        foreach e $l {
         set key [lindex $e 0]
         if { [string is integer $key] } {
           set list_req($key,champ) [lindex $e 1]
           set list_req($key,condition) [lindex $e 2]
           set list_req($key,valeur) [lindex $e 3]
           if { $indicereqinit < $key } { set indicereqinit $key }
         } else {
           set a($key) [lindex $e 1]
         }
        }
        set form_req(name) $a(name)
        set form_req(type_req_check) $a(type_req_check)
        set form_req(type_requ) $a(type_requ)
        set form_req(choix_limit_result) $a(choix_limit_result)
        set form_req(limit_result) $a(limit_result)
        set form_req(type_select) $a(type_select)
        parray form_req
        parray list_req
        array unset a
      } else {
       array unset list_req
      }


      #--- initConf
      if { ! [ info exists conf(bddimages,list_pos_stat) ] } { set conf(bddimages,list_pos_stat) "+80+40" }

      #--- confToWidget
      set bddconf(list_pos_stat) $conf(bddimages,list_pos_stat)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists bddconf(list_geom_stat) ] } {
         set deb [ expr 1 + [ string first + $bddconf(list_geom_stat) ] ]
         set fin [ string length $bddconf(list_geom_stat) ]
         set bddconf(list_geom_stat) "+[ string range $bddconf(list_geom_stat) $deb $fin ]"
      }

         #---
         toplevel $This -class Toplevel
         wm geometry $This $bddconf(list_pos_stat)
         wm resizable $This 1 1
         wm title $This $caption(bddimages_define,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_define::fermer }





         #--- Cree un frame pour afficher le type de logique AND / OR
         set framecurrent $This.frame1
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x

             #--- Bouton check
#             radiobutton $framecurrent.check -highlightthickness 0 -state normal -value 0 -variable form_req(type_req_check) -command {  }
             checkbutton $framecurrent.check -highlightthickness 0 -state normal -variable form_req(type_req_check) -command {  }
             pack $framecurrent.check \
                -in $framecurrent -side left -anchor center -padx 3
             #--- Cree un label
             label $framecurrent.txt1 -font $bddconf(font,arial_10_b) \
                -text "Maj Compatibilite�"
             pack $framecurrent.txt1 \
                -in $framecurrent -side left -anchor w -padx 1



         #--- Cree un frame pour faire un saut
         set framecurrent $This.frameblank1
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x -padx 3 -pady 3

           #--- Cree un label pour faire un saut
           label $framecurrent.titre -font $bddconf(font,arial_10_b) \
                 -text " "
           pack $framecurrent.titre \
                -in $framecurrent -side top -padx 3 -pady 3


         button $framecurrent.add -state active -borderwidth 1 -height 1 -text "+" -command { ::bddimages_define::add_requete }
         pack $framecurrent.add -in $framecurrent -side top -fill x


         #--- Cree un frame pour afficher les requetes
         set frch $This.framereq
         frame $frch -borderwidth 0 -cursor arrow
         pack $frch -in $This -anchor s -side top -expand 0 -fill x

#--
         for { set x 0 } { $x < $indicereqinit } { incr x } {
          ::bddimages_define::add_requete
         }

#         if { $indicereqinit == 0 } {
#          ::bddimages_define::add_requete
#         }

#--




         #--- Cree un frame pour faire un saut
         set framecurrent $This.frameblank2
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x -padx 3 -pady 3

           #--- Cree un label pour faire un saut
           label $framecurrent.titre -font $bddconf(font,arial_10_b) \
                 -text " "
           pack $framecurrent.titre \
                -in $framecurrent -side top -padx 3 -pady 3



         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton annuler
           button $This.frame11.but_annuler \
              -text "$caption(bddimages_define,annuler)" -borderwidth 2 \
              -command { ::bddimages_define::fermer }
           pack $This.frame11.but_annuler \
              -in $This.frame11 -side right -anchor e \
              -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

           #--- Creation du bouton ok
           button $This.frame11.but_ok \
              -text "$caption(bddimages_define,ok)" -borderwidth 2 \
              -command { ::bddimages_define::accept }
           pack $This.frame11.but_ok \
              -in $This.frame11 -side right -anchor e \
              -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bddimages_define,aide)" -borderwidth 2 \
              -command {lecture_info This}
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0




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



}

