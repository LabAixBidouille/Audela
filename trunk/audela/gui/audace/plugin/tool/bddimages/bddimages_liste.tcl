#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_liste.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_liste.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace bddimages_liste
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_liste.cap
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

namespace eval bddimages_liste {

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste_creation.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_calendrier.tcl ]\""


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

      ::bddimages_liste::recup_position
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

#--------------------------------------------------
#  get_list_combobox { }
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
proc get_list_combobox { } {

   global caption

return [list "=" ">" "<" ">=" "<=" "!=" $caption(bddimages_liste,contient) $caption(bddimages_liste,notcontient)]
}

#--------------------------------------------------
#  affich_form_req { }
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
proc affich_form_req { } {

  set jjdatemin [ mc_date2jd $form_req(datemin) ]
  set jjdatemax [ mc_date2jd $form_req(datemax) ]

  ::console::affiche_resultat "-- affich_form_req"
  ::console::affiche_resultat "datemin                  = $form_req(datemin)"
  ::console::affiche_resultat "datemax                  = $form_req(datemax)"
  ::console::affiche_resultat "jjdatemin                = $jjdatemin"
  ::console::affiche_resultat "jjdatemax                = $jjdatemax"
  ::console::affiche_resultat "type_req_check 		= $form_req(type_req_check)"
  ::console::affiche_resultat "type_requ 		= $form_req(type_requ)"
  ::console::affiche_resultat "choix_limit_result	= $form_req(choix_limit_result)"
  ::console::affiche_resultat "limit_result		= $form_req(limit_result)"
  ::console::affiche_resultat "type_result		= $form_req(type_result)"
  ::console::affiche_resultat "type_select		= $form_req(type_select)"
  ::console::affiche_resultat "nbimg			= $form_req(nbimg)"

}






proc ::bddimages_liste::get_val_intellilist { intellilist val } {

   foreach  l $intellilist  {
       set x [lsearch $l $val]
       if {$x!=-1} {
          set y [lindex $l 1]
          return $y
       }
   }
}











proc ::bddimages_liste::affiche_intellilist { intellilist } {

  ::console::affiche_resultat "-- affiche_intellilist\n"
  ::console::affiche_resultat "intellilist = $intellilist \n"
  ::console::affiche_resultat "name = [get_val_intellilist $intellilist "name"] \n"
  ::console::affiche_resultat "datemin = [get_val_intellilist $intellilist "datemin"]\n"
  ::console::affiche_resultat "datemax = [get_val_intellilist $intellilist "datemax"]\n"
  ::console::affiche_resultat "type_req_check = [get_val_intellilist $intellilist "type_req_check"]\n"
  ::console::affiche_resultat "type_requ = [get_val_intellilist $intellilist "type_requ"]\n"
  ::console::affiche_resultat "choix_limit_result = [get_val_intellilist $intellilist "choix_limit_result"]\n"
  ::console::affiche_resultat "limit_result = [get_val_intellilist $intellilist "limit_result"]\n"
  ::console::affiche_resultat "type_result = [get_val_intellilist $intellilist "type_result"]\n"
  ::console::affiche_resultat "type_select = [get_val_intellilist $intellilist "type_select"]\n"
  ::console::affiche_resultat "reqlist = [get_val_intellilist $intellilist "reqlist"]\n"
  ::console::affiche_resultat "--\n"

}








#--------------------------------------------------
#  get_intellilist_by_name { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : name
#
#    variables en sortie : none
#
#--------------------------------------------------
proc get_intellilist_by_name { name } {

  global nbintellilist
  global intellilisttotal

  set found 0
  for {set i 1} {$i<=$nbintellilist} {incr i} {
     set l $intellilisttotal($i)
     if { [lindex [lindex $l 0] 1] eq "$name" } then { set found 1 ; break }
  }
  if { $found } { return $i } else { return -1 }
}











proc exec_intellilist { num } {

 ::bddimages_recherche::Affiche_listes
 ::bddimages_recherche::get_list $num
 ::bddimages_recherche::Affiche_Results $num
}
















proc form_req_to_intellilist { name } {
  global form_req

  set intellilist     [list "name"               $name]  
  lappend intellilist [list "datemin"            $form_req(datemin)]              
  lappend intellilist [list "datemax"            $form_req(datemax)]              
  lappend intellilist [list "type_req_check"     $form_req(type_req_check)]       
  lappend intellilist [list "type_requ"          $form_req(type_requ)]            
  lappend intellilist [list "choix_limit_result" $form_req(choix_limit_result)]
  lappend intellilist [list "limit_result"       $form_req(limit_result)]         
  lappend intellilist [list "type_result"        $form_req(type_result)]          
  lappend intellilist [list "type_select"        $form_req(type_select)]          
  return $intellilist
}













# Construit une intelliliste a partir du formulaire
proc ::bddimages_liste::build_intellilist { name } {

   global indicereq
   global list_req
   global form_req
   global caption
   global nbintellilist

   set intellilist     ""
   lappend intellilist [list "name"               $name]              
   lappend intellilist [list "datemin"            $form_req(datemin)]              
   lappend intellilist [list "datemax"            $form_req(datemax)]              
   lappend intellilist [list "type_req_check"     $form_req(type_req_check)]       
   lappend intellilist [list "type_requ"          $form_req(type_requ)]            
   lappend intellilist [list "choix_limit_result" $form_req(choix_limit_result)]
   lappend intellilist [list "limit_result"       $form_req(limit_result)]         
   lappend intellilist [list "type_result"        $form_req(type_result)]          
   lappend intellilist [list "type_select"        $form_req(type_select)]          

   set reqlist ""
   set y 0
   for {set x 1} {$x<=$indicereq} {incr x} {
     if {$list_req($x,valide)=="ok"&&$list_req($x,valeur)!=""} {
       incr y
       if {$list_req($x,condition)== $caption(bddimages_liste,contient)} {
          lappend reqlist [list $y $list_req($x,champ) "LIKE" "%$list_req($x,valeur)%"]
          continue
          }
       if {$list_req($x,condition)== $caption(bddimages_liste,notcontient)} {
          lappend reqlist [list $y $list_req($x,champ) "NOT LIKE" "%$list_req($x,valeur)%"]
          continue
          }
       lappend reqlist [list $y $list_req($x,champ) $list_req($x,condition) $list_req($x,valeur)]
       }
     }
   lappend intellilist [list "reqlist" $reqlist]

   return $intellilist
}














proc conf_save_intellilists { } {

   global bddconf

   set l ""
   for {set x 1} {$x<=$::nbintellilist} {incr x} {
      lappend l [list $::intellilisttotal($x)]
   }
   set ::conf(bddimages,$bddconf(current_config),intellilists) $l
}












proc conf_load_intellilists { } {

   global nbintellilist
   global intellilisttotal
   global bddconf

   set nbintellilist 0
   
   # hack pour initialisation
   if { [catch {get_list_box_champs} msg] } {
      return -code error $msg
   }
   if { ! [info exists ::conf(bddimages,$bddconf(current_config),intellilists) ] } then { return }
   foreach l $::conf(bddimages,$bddconf(current_config),intellilists) {
      incr nbintellilist
      set intellilisttotal($nbintellilist) [lindex $l 0]
   }
}










proc accept { } {

   global indicereq
   global list_req
   global form_req
   global caption
   global nbintellilist
   global intellilisttotal

   set idx [get_intellilist_by_name $form_req(name)]
   if { $idx == -1 } {
      incr nbintellilist
      set idx $nbintellilist
   }
   set intellilist [build_intellilist "$form_req(name)"]
   set intellilisttotal($idx) $intellilist
   # ::bddimages_recherche::Affiche_listes
   # ::bddimages_recherche::get_list $nbintellilist
   # ::bddimages_recherche::Affiche_Results $nbintellilist
   exec_intellilist $idx
   conf_save_intellilists
   ::bddimages_liste::fermer
}




#--------------------------------------------------
#  get_sqlcritere { }
#--------------------------------------------------
#
#    fonction  :
#       construit la requete sql pour une table images_xxx
#
#    variables en entree : id header de la table
#
#    variables en sortie : requete sql
#
#--------------------------------------------------
proc ::bddimages_liste::get_sqlcritere { intellilist table } {

   global indicereq
   global list_req
   global form_req
   global caption
   global list_key_to_var


   set ilist(name)               [get_val_intellilist $intellilist "name"]
   set ilist(datemin)            [get_val_intellilist $intellilist "datemin"]
   set ilist(datemax)            [get_val_intellilist $intellilist "datemax"]
   set ilist(type_req_check)     [get_val_intellilist $intellilist "type_req_check"]
   set ilist(type_requ)          [get_val_intellilist $intellilist "type_requ"]
   set ilist(choix_limit_result) [get_val_intellilist $intellilist "choix_limit_result"]
   set ilist(limit_result)       [get_val_intellilist $intellilist "limit_result"]
   set ilist(type_result)        [get_val_intellilist $intellilist "type_result"]
   set ilist(type_select)        [get_val_intellilist $intellilist "type_select"]
   set reqlist                   [get_val_intellilist $intellilist "reqlist"]

   
   if { $ilist(type_requ)==$caption(bddimages_liste,toutes)} {
     set reqcond "AND"
     }
   if { $ilist(type_requ)==$caption(bddimages_liste,nimporte)} {
     set reqcond "OR"
     }


   set sqlcritere ""
   set cpt 0
   foreach req $reqlist {
      set key  [lindex $req 1]
      set cond [lindex $req 2]
      set val  [lindex $req 3]
      if {$cpt==0} {
         set sqlcritere "AND ( $sqlcritere (`$list_key_to_var($key)` $cond '$val') "
      } else {
         set sqlcritere "$sqlcritere $reqcond (`$list_key_to_var($key)` $cond '$val') "
      }
      incr cpt
   }
   if {$cpt!=0} {
      set sqlcritere "$sqlcritere ) "
   }

   set cond "AND"

   set jjdatemin [ mc_date2jd "$ilist(datemin)T00:00:00" ]
   set jjdatemax [ mc_date2jd "$ilist(datemax)T00:00:00" ]

   if { $ilist(datemin)!=""} {
      if { $ilist(datemax)!=""} {
      set sqlcritere "$sqlcritere AND (commun.datejj>$jjdatemin AND commun.datejj<$jjdatemax) "
      } else {
      set sqlcritere "$sqlcritere AND (commun.datejj>$jjdatemin) "
      }
   } else {
      if { $ilist(datemax)!=""} {
      set sqlcritere "$sqlcritere AND (commun.datejj<$jjdatemax) "
      }
   }

   return $sqlcritere
}






#--------------------------------------------------
#  get_imglist { }
#--------------------------------------------------
#
#    fonction  :
#       construit la requete sql generale
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste des images
#
#--------------------------------------------------
proc ::bddimages_liste::get_imglist { intellilist } {


   #::bddimages_liste::affiche_intellilist $intellilist


   set sqlcmd "SELECT DISTINCT idheader FROM header;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "Erreur de lecture de la table header par SQL"
      bddimages_sauve_fich "	sqlcmd = $sqlcmd"
      bddimages_sauve_fich "	err = $err"
      bddimages_sauve_fich "	msg = $msg"
      return
   }

   set table ""

   foreach line $resultsql {

      set idhd [lindex $line 0]
      set sqlcritere [::bddimages_liste::get_sqlcritere $intellilist "images_$idhd"]
      set sqlcmd "SELECT images.idheader,images.tabname,images.filename,
                  images.dirfilename,images.sizefich,images.datemodif,
                  images_$idhd.* FROM images,images_$idhd,commun
		  WHERE images.idbddimg = images_$idhd.idbddimg 
                  AND   commun.idbddimg = images_$idhd.idbddimg
                  $sqlcritere  ;"
      set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
      if {[string first "Unknown column" $msg]==-1} {
         if {$err} {
            bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
            bddimages_sauve_fich "        sqlcmd = $sqlcmd"
            bddimages_sauve_fich "        err = $err"
            bddimages_sauve_fich "        msg = $msg"
            ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
            ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
            ::console::affiche_erreur "        err = $err\n"
            ::console::affiche_erreur "        msg = $msg\n"
            return
         }

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
      }
   }

   #::console::affiche_erreur " table = $table\n"
   return $table
}






#--------------------------------------------------
#  calcul_nbimg { }
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
proc ::bddimages_liste::calcul_nbimg { } {

   global form_req

   set intellilist [::bddimages_liste::build_intellilist "calcul_nbimg"]
   set form_req(nbimg) [llength [::bddimages_liste::get_imglist $intellilist]]
   ::console::affiche_resultat "Nb img = $form_req(nbimg) \n"
   return
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
   global indicereq
   global list_req


  #--- Initialisation des combox
  set result [get_list_box_champs]
  set list_box_champs [lindex $result 1]
  set nbrows1 [ llength $list_box_champs ]
  set nbcols1 [lindex $result 0]
  set list_combobox [get_list_combobox]
  set nbrows2 [ llength $list_combobox ]
  set nbcols2 13


  #--- Initialisation de la liste des requetes
  set indicereq [expr $indicereq + 1]

  if { [ info exists list_req($indicereq,champ) ] } {
#  set list_req($indicereq,champ)
#  set list_req($indicereq,condition)
#  set list_req($indicereq,valeur) ""
  set list_req($indicereq,valide) "ok"
   if { $list_req($indicereq,condition) eq "LIKE" } {
    set list_req($indicereq,condition) $caption(bddimages_liste,contient)
    set list_req($indicereq,valeur) [string trim $list_req($indicereq,valeur) %]
   } elseif { $list_req($indicereq,condition) eq "NOT LIKE" } {
    set list_req($indicereq,condition) $caption(bddimages_liste,notcontient)
    set list_req($indicereq,valeur) [string trim $list_req($indicereq,valeur) %]
   }
  } else {
  set list_req($indicereq,champ)     [lindex $list_box_champs 0]
  set list_req($indicereq,condition) [lindex $list_combobox 0]
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
    ComboBox $frchch.combo \
       -width $nbcols2 -height $nbrows2 \
       -relief sunken -borderwidth 1 -editable 0 \
       -textvariable list_req($indicereq,condition) \
       -values $list_combobox
    pack $frchch.combo -anchor center -side left -fill x -expand 1
    grid $frchch -sticky new
    #--- Cree une ligne d'entree pour la variable
    entry $frchch.dat -textvariable list_req($indicereq,valeur) -borderwidth 1 -relief groove -width 25 -justify left
    pack $frchch.dat -in $frchch -side left -anchor w -padx 1
    #--- Cree un bouton supprime requete
    button $frchch.sup -state normal -borderwidth 1 -relief groove -anchor c -height 1 \
       -text "-" -command { ::bddimages_liste::remove_requete }

    pack $frchch.sup -in $frchch -side left -anchor w -padx 1
    #--- Cree un bouton ajout requete
    button $frchch.add -state active -borderwidth 1 -relief groove -anchor c -height 1 \
       -text "+" -command { ::bddimages_liste::add_requete }
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

      set list_comb1 [list $caption(bddimages_liste,toutes) $caption(bddimages_liste,nimporte)]
      set list_comb2 [list $caption(bddimages_liste,elem)]
      set list_comb3 [list $caption(bddimages_liste,alea) \
                           $caption(bddimages_liste,dateobs) \
                           $caption(bddimages_liste,telescope) \
                           $caption(bddimages_liste,plrecmod) \
                           $caption(bddimages_liste,morecmod) \
                           $caption(bddimages_liste,plrecajo) \
                           $caption(bddimages_liste,morecajo) ]

      set form_req(name) "Newlist[ expr $::nbintellilist + 1 ]"
      set form_req(type_req_check) ""
      set form_req(datemin) ""
      set form_req(datemax) ""
      set form_req(type_req_check) 1
      set form_req(type_requ) [lindex $list_comb1 0]
      set form_req(choix_limit_result) 0
      set form_req(limit_result) "25"
      set form_req(type_result) [lindex $list_comb2 0]
      set form_req(type_select) [lindex $list_comb3 0]
      set form_req(nbimg) "?"

      set edit 0
      if { ! ($listname eq "?") } {
        set edit 1
        set editname $listname
        set editid [get_intellilist_by_name $listname]
        puts "createDialog : $listname id=$editid"
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
        set form_req(datemin) $a(datemin)
        set form_req(datemax) $a(datemax)
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
         wm title $This $caption(bddimages_liste,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_liste::fermer }


         #--- Cree un frame pour le nom de la liste
         set framecurrent $This.framename
          frame $framecurrent -borderwidth 0 -cursor arrow
          pack $framecurrent -in $This -anchor s -side top -expand 0 -fill both -padx 3 -pady 3

            #--- Cree un label
            label $framecurrent.lab -text "$caption(bddimages_liste,nom)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $framecurrent.lab -in $framecurrent -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $framecurrent.dat -textvariable form_req(name) -borderwidth 1 -relief groove -width 25 -justify left
            pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1
            #--- Cree un bouton info
           # button $This.bdd.login.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
           #         -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
           # pack $This.bdd.login.help -in $This.bdd.login -side left -anchor w -padx 1



         #--- Cree un frame pour faire un saut
         set framecurrent $This.frameblank00
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x -padx 3 -pady 3

           #--- Cree un label pour faire un saut
           label $framecurrent.titre -font $bddconf(font,arial_10_b) \
                 -text " "
           pack $framecurrent.titre \
                -in $framecurrent -side top -padx 3 -pady 3


         #--- Cree un frame pour le nom de la liste
         set framecurrent $This.datemindatemax
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill both -padx 3 -pady 3

            #--- Cree un label
            label $framecurrent.labmin -text "DATE-OBS min"  -anchor w -borderwidth 0 -relief flat
            pack $framecurrent.labmin -in $framecurrent -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable form_req(datemin)
            entry $framecurrent.datmin -textvariable form_req(datemin) -borderwidth 1 -relief groove  -justify left
            pack $framecurrent.datmin -in $framecurrent -side left -anchor w -padx 1

            #--- Creation du bouton ok
            button $framecurrent.but_datmin \
               -text "Cal" -borderwidth 2 \
               -command { ::bddimages_calendar::run $audace(base).bddimages_liste }
            pack $framecurrent.but_datmin \
               -in $framecurrent -side right -anchor e \
               -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

           #--- Cree un label
           label $framecurrent.labmax -text "DATE-OBS max"  -anchor w -borderwidth 0 -relief flat
           pack $framecurrent.labmax -in $framecurrent -side left -anchor w -padx 1
           #--- Cree une ligne d'entree pour la variable
           entry $framecurrent.datmax -textvariable form_req(datemax) -borderwidth 1 -relief groove -justify left
           pack $framecurrent.datmax -in $framecurrent -side left -anchor w -padx 1



         #--- Cree un frame pour faire un saut
         set framecurrent $This.frameblank0
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x -padx 3 -pady 3

           #--- Cree un label pour faire un saut
           label $framecurrent.titre -font $bddconf(font,arial_10_b) \
                 -text " "
           pack $framecurrent.titre \
                -in $framecurrent -side top -padx 3 -pady 3




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
                -text "Répondre à"
             pack $framecurrent.txt1 \
                -in $framecurrent -side left -anchor w -padx 1
             #--- Cree un combox pour le choix
             ComboBox $framecurrent.combo1 \
                -width 20 -height 2 -font $bddconf(font,arial_10_b)\
                -relief raised -borderwidth 1 -editable 0 \
                -textvariable form_req(type_requ) \
                -values $list_comb1
             pack $framecurrent.combo1 -anchor center -side left -fill x -expand 0
             #--- Cree un label
             label $framecurrent.txt2 -font $bddconf(font,arial_10_b) \
                -text "règles suivantes :"
             pack $framecurrent.txt2 \
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


         button $framecurrent.add -state active -borderwidth 1 -height 1 -text "+" -command { ::bddimages_liste::add_requete }
         pack $framecurrent.add -in $framecurrent -side top -fill x


         #--- Cree un frame pour afficher les requetes
         set frch $This.framereq
         frame $frch -borderwidth 0 -cursor arrow
         pack $frch -in $This -anchor s -side top -expand 0 -fill x

         #--- Cree un bouton ajout requete
#         button $frch.add -state active -borderwidth 1 -relief groove -anchor c -height 1 \
#            -text "+" -command { ::bddimages_liste::add_requete }
#         pack $frch.add -in $frch -side top -anchor s -padx 1 -expand 0 -fill x

#--
         for { set x 0 } { $x < $indicereqinit } { incr x } {
          ::bddimages_liste::add_requete
         }

#         if { $indicereqinit == 0 } {
#          ::bddimages_liste::add_requete
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





         #--- Cree un frame pour l'affichage des resultats
         set framecurrent $This.frame2
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x


             #--- Bouton check
             checkbutton $framecurrent.check -highlightthickness 0 -state normal \
               -variable form_req(choix_limit_result) \
               -command {  }
             pack $framecurrent.check \
               -in $framecurrent -side left -anchor center -padx 3
             #--- Cree un label
             label $framecurrent.txt1 -font $bddconf(font,arial_10_b) \
                -text "Limiter à"
             pack $framecurrent.txt1 \
                -in $framecurrent -side left -anchor w -padx 1
             #--- Cree une ligne d'entree pour la variable
             entry $framecurrent.dat -textvariable form_req(limit_result) -borderwidth 1 -relief groove -width 8 -justify center
             pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1
             #--- Cree un combox pour le choix
             ComboBox $framecurrent.combo \
                -width 10 -height 1 \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable form_req(type_result) \
                -values $list_comb2
             pack $framecurrent.combo -anchor center -side left -fill x -expand 0
             #--- Cree un label
             label $framecurrent.txt2 -font $bddconf(font,arial_10_b) \
                -text "sélectionnés par"
             pack $framecurrent.txt2 \
                -in $framecurrent -side left -anchor w -padx 1
             #--- Cree un combox pour le choix
             ComboBox $framecurrent.combo2 \
                -width 27 -height 7 \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable form_req(type_select) \
                -values $list_comb3
             pack $framecurrent.combo2 -anchor center -side left -fill x -expand 0





         #--- Cree un frame pour le calcul du nombre d images
         set framecurrent $This.frame3
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor s -side top -expand 0 -fill x -padx 3 -pady 3


         #--- Cree un label
         label $framecurrent.txt1 -font $bddconf(font,arial_10_b) \
            -text "Nombre d'images résultant de cette requête : "
         pack $framecurrent.txt1 \
            -in $framecurrent -side left -anchor w -padx 1
         #--- Cree une ligne d'entree pour la variable
         entry $framecurrent.dat -textvariable form_req(nbimg) -state readonly -borderwidth 1 -relief groove -width 8 -justify center
         pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1
         #--- Cree un bouton ajout requete
         button $framecurrent.calc -state active -borderwidth 1 -relief groove -anchor c -height 1 \
            -text "Calcul" -command { ::bddimages_liste::calcul_nbimg }
         pack $framecurrent.calc -in $framecurrent -side left -anchor w -padx 1





         #--- Cree un frame pour faire un saut
         set framecurrent $This.frameblank3
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
              -text "$caption(bddimages_liste,annuler)" -borderwidth 2 \
              -command { ::bddimages_liste::fermer }
           pack $This.frame11.but_annuler \
              -in $This.frame11 -side right -anchor e \
              -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

           #--- Creation du bouton ok
           button $This.frame11.but_ok \
              -text "$caption(bddimages_liste,ok)" -borderwidth 2 \
              -command { ::bddimages_liste::accept }
           pack $This.frame11.but_ok \
              -in $This.frame11 -side right -anchor e \
              -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bddimages_liste,aide)" -borderwidth 2 \
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

