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
# - Namespace bddimages_liste
# - Fichiers source externe :
#       bddimages_liste.cap
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

namespace eval bddimages_liste {

   package require bdicalendar 1.0

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""

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

      set entetelog "liste"
      set This $this
      createDialog $listname
      return
   }

   proc ::bddimages_liste::runnormal { this } {

      global This
      global entetelog

      set entetelog "liste"
      set This $this

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      global getnamenewlist
   
      set getnamenewlist(result) 0
      set getnamenewlist(name) ""
   
      toplevel $This -class Toplevel
      wm title $This "Nouvelle liste"
      wm positionfrom $This user
      wm sizefrom $This user
   
      set framecurrent $This.framename

      frame $framecurrent -relief groove
      pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10
   
      # Frame qui va contenir le label "Type your password:" et une entrée pour le rentrer
      frame $framecurrent.title
      pack configure $framecurrent.title -side top -fill x
        label $framecurrent.title.e -text "Nom de la liste"
        pack configure $framecurrent.title.e -side left -anchor c
   
      # L'option -show permet de masquer la véritable entrée, 
      # et de mettre une étoile à la place des caractères saisis
      frame $framecurrent.gpass
      pack configure $framecurrent.gpass -side top -fill x
        entry $framecurrent.gpass.v -textvariable getnamenewlist(name)
        pack configure $framecurrent.gpass.v -side bottom -anchor c
   
      # Frame qui va contenir les boutons Cancel et Ok
      frame $framecurrent.buttons
      pack configure $framecurrent.buttons -side top -fill x
        button $framecurrent.buttons.cancel -text Cancel -command "destroy $This"
        pack configure $framecurrent.buttons.cancel -side left
        button $framecurrent.buttons.ok -text Ok -command { set getnamenewlist(result) 1; ::bddimages_liste::build_normallist; destroy $This }
        pack configure $framecurrent.buttons.ok -side right
   
      grab set $This
      tkwait window $This
      if {$getnamenewlist(result)} {
         return -code 0 $getnamenewlist(name)
      } else {
         return -code error ""
      }
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
   
      set y ""
      foreach  l $intellilist  {
          set x [lsearch $l $val]
          if {$x!=-1} {
             set y [lindex $l 1]
             return $y
          }
      }
      return $y
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
             
        if { [get_val_intellilist $l "name"] eq "$name" } then { set found 1 ; break }
     }
     if { $found } { return $i } else { return -1 }
   }



   proc exec_intellilist { num } {
   
    ::bddimages_recherche::Affiche_listes
    ::bddimages_recherche::get_intellist $num
    ::bddimages_recherche::Affiche_Results $num
   }
















   proc ::bddimages_liste::new_normallist { lid } {

      set imgtmplist     ""
      lappend imgtmplist [list "type"               "normal"]              
      lappend imgtmplist [list "name"               "tmp"]              
      lappend imgtmplist [list "idlist"             ""]              
      set imgtmplist [::bddimages_liste::add_to_normallist $lid $imgtmplist]
      #::console::affiche_resultat "imgtmplist=$imgtmplist\n"
      set imgtmplist [::bddimages_liste::intellilist_to_imglist $imgtmplist]
      #::console::affiche_resultat "imgtmplist=$imgtmplist\n"
      return $imgtmplist
   }






















   proc ::bddimages_liste::add_to_normallist { lid normallist } {


      #recupere la liste des idbddimg
      set cpt 0
      foreach i $lid {
         incr cpt
         set id [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
         if {$cpt == 1} {
            set l "$id"
         } else {
            set l "$l,$id"
         }
      }
      if {$cpt == 0}  { return }
      
      #recupere les tables images_xxx des idbddimg
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
      #::console::affiche_resultat "nbresult = $nbresult\n"
      #::console::affiche_resultat "result = $result\n"
   
      #met en forme la nouvelle liste d id
      set ltable ""
      foreach l $result {
         set table [lindex $l 0]
         set id [lindex $l 1]
         lappend ltable $table
         lappend comp($table) $id
      }
     
      #::console::affiche_resultat "comp = [array get comp]\n"


      set oldidlist [::bddimages_liste::get_val_intellilist $normallist "idlist"]

      foreach l $oldidlist {
         set table [lindex $l 0]
         set li    [lindex $l 1]
         lappend ltable $table
         foreach id $li {
            lappend comp($table) $id
         }
      }

      #construit la nouvelle idlist
      set ltable [lsort -unique $ltable]
      foreach t $ltable {
         set comp($t) [lsort -unique $comp($t)]
      }


      set idlist ""
      foreach t $ltable {
         #::console::affiche_resultat "table = $t\n"
         set il ""
         foreach i $comp($t) {
            lappend il $i
            #::console::affiche_resultat "$i "
         }
         lappend idlist [list $t $il]
         #::console::affiche_resultat "\n"
      }
      #::console::affiche_resultat "idlist=$idlist\n"
   

      if { [::bddimages_liste::get_val_intellilist $normallist "type"] != "normal"} {
         ::console::affiche_erreur "Ne peut etre associe a la liste $namelist\n"
         return
      }

      #::console::affiche_resultat "normallist=$normallist\n"
   
      set newl ""
      foreach val $normallist {
         if {[lindex $val 0]=="idlist"} {
            lappend newl [list "idlist" $idlist]
         } else {
            lappend newl $val
         }
      }

   return $newl
   }




























   proc ::bddimages_liste::build_normallist { } {
   
      global getnamenewlist
      global nbintellilist intellilisttotal
   
      if {$getnamenewlist(name) != ""} {
         ::console::affiche_resultat "new list = $getnamenewlist(name)"
         set intellilist     ""
         lappend intellilist [list "type"               "normal"]              
         lappend intellilist [list "name"               $getnamenewlist(name)]              
         lappend intellilist [list "idlist"             ""]              
         incr nbintellilist
         set intellilisttotal($nbintellilist) $intellilist
         exec_intellilist $nbintellilist
         conf_save_intellilists
         }
   
   }





















   # Construit une intelliliste a partir du formulaire
   proc ::bddimages_liste::build_intellilist { name } {
   
      global indicereq
      global list_req
      global form_req
      global caption
      global nbintellilist

      set intellilist ""
      lappend intellilist [list "type"               "intellilist"]              
      lappend intellilist [list "name"               $name]              
      lappend intellilist [list "datemin"            $::bddimages_liste::form_req(datemin)]              
      lappend intellilist [list "datemax"            $::bddimages_liste::form_req(datemax)]              
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

   



















   # Construit une intelliliste a partir du formulaire
   proc ::bddimages_liste::load_intellilist { intellilist } {
   
      global indicereq
      global list_req
      global form_req
   
      set ::bddimages_liste::form_req(name)                       [get_val_intellilist $intellilist "name"]
      set ::bddimages_liste::form_req(datemin)                    [get_val_intellilist $intellilist "datemin"]
      set ::bddimages_liste::form_req(datemax)                    [get_val_intellilist $intellilist "datemax"]
      set ::bddimages_liste::form_req(type_req_check)             [get_val_intellilist $intellilist "type_req_check"]
      set ::bddimages_liste::form_req(type_requ)                  [get_val_intellilist $intellilist "type_requ"]
      set ::bddimages_liste::form_req(choix_limit_result)         [get_val_intellilist $intellilist "choix_limit_result"]
      set ::bddimages_liste::form_req(limit_result)               [get_val_intellilist $intellilist "limit_result"]
      set ::bddimages_liste::form_req(type_result)                [get_val_intellilist $intellilist "type_result"]
      set ::bddimages_liste::form_req(type_select)                [get_val_intellilist $intellilist "type_select"]
      set ::bddimages_liste::reqlist                              [get_val_intellilist $intellilist "reqlist"]
   
      set indicereq 0
      foreach req $reqlist {
         incr indicereq
         set list_req($indicereq,valide)    "ok"
         set list_req($indicereq,condition) [lindex $req 2]
         set list_req($indicereq,champ)     [lindex $req 1]
         set list_req($indicereq,valeur)    [lindex $req 3]
      }
   
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

      set intellilist [::bddimages_liste::build_intellilist "$form_req(name)"]
      set intellilisttotal($idx) $intellilist
      
      # ::bddimages_recherche::Affiche_listes
      # ::bddimages_recherche::get_intellist $nbintellilist
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
















   proc ::bddimages_liste::transform_tabkey { table } {


      set tableresult ""

      foreach img $table {

         set tabkey ""
         foreach lkey $img {
            set key  [lindex $lkey 0]
            set val  [lindex $lkey 1]
            lappend tabkey [list [string toupper $key] [list [string toupper $key] $val] ]
         }

         set r [bddimages_entete_preminforecon $tabkey]

         set imgresult ""
         foreach lkey $img {
            set key  [lindex $lkey 0]
            set val  [lindex $lkey 1]
            if {$key=="telescop"} {
               set site [string trim [lindex $r 2]]
               set site [string tolower $site]
               set val [string map {" " "_"} $site]
               }
            if {$key=="date-obs"} {set val [lindex $r 1]}
            lappend imgresult [list $key $val ]
         }
         lappend tableresult $imgresult
      }

      return $tableresult

   }



















   #--------------------------------------------------
   #  intellilist_to_imglist { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       renvoit la liste des images et de leur contenu
   #
   #    procedure externe :
   #
   #    variables en entree : none
   #
   #    variables en sortie : liste des images
   #
   #--------------------------------------------------
   proc ::bddimages_liste::intellilist_to_imglist { intellilist } {
   
      set type [::bddimages_liste::get_val_intellilist $intellilist "type"]
      
      set table ""
      if {$type == "intellilist"} {
         set table [::bddimages_liste::intellilist_to_imglist_i $intellilist]
         set table [::bddimages_liste::transform_tabkey $table]

         foreach img $table {
            set tabkey   [::bddimages_liste::get_key_img $img "tabkey"]
            set telescop [::bddimages_liste::get_key_img $tabkey telescop]
            ::console::affiche_resultat "telescop = $telescop\n"
         }

      }
      if {$type == "normal"} {
         #::console::affiche_resultat "intellilist = $intellilist\n"
         set table [::bddimages_liste::intellilist_to_imglist_n $intellilist]
         set table [::bddimages_liste::transform_tabkey $table]
      }
      return $table
   }









   #--------------------------------------------------
   #  get_key_img_list { }
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

   proc ::bddimages_liste::get_key_img_list { key img_list } {
   
      set y ""
      foreach  img $img_list  {
         lappend y [::bddimages_liste::get_key_img $img $key]
      }
      return $y
   }

   proc ::bddimages_liste::update_val_img_list { key val img_list } {
   
      set y ""
      set result_list ""
      foreach  l $img_list  {
          set br ""
          foreach  b $l  {
             if {[lindex $l 0]==$key} {
                lappend br [list $key $val]
             } else {
                lappend br $b
             }
          }
         lappend result_list $br
      }
      return $result_list
   }












   #--------------------------------------------------
   #  intellilist_to_imglist_n { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       construit la requete sql generale pour une liste normale
   #
   #    procedure externe :
   #
   #    variables en entree : none
   #
   #    variables en sortie : liste des images
   #
   #--------------------------------------------------
   proc ::bddimages_liste::intellilist_to_imglist_n { intellilist } {
   
      #::console::affiche_resultat "intellilist = $intellilist\n"
   
      set idlist [::bddimages_liste::get_val_intellilist $intellilist "idlist"]
      #::console::affiche_resultat "idlist = $idlist\n"
      if {[llength $idlist] == 0} {return}
      set img_list ""
   
      foreach val $idlist {
         set imageidhd [lindex $val 0]
         set lid [lindex $val 1]
         set cpt 0
         foreach id $lid {
            if {$cpt==0} {
               set lsqlid "$id"
            } else {
               set lsqlid "$lsqlid,$id"
            }
            incr cpt
         }
         #::console::affiche_resultat "imageidhd = $imageidhd : $lsqlid\n"
   
         set sqlcmd "SELECT images.idbddimg,
                            images.idheader,
                            images.tabname,
                            images.filename,
                            images.dirfilename,
                            images.sizefich,
                            images.datemodif,
                            commun.datejj as commundatejj,
                            $imageidhd.* 
                     FROM images,$imageidhd,commun
   		     WHERE images.idbddimg = $imageidhd.idbddimg 
                     AND   commun.idbddimg = $imageidhd.idbddimg
                     AND   images.idbddimg IN ($lsqlid);"
   
         #::console::affiche_resultat "sqlcmd = $sqlcmd\n"
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
   
            if {$nbresult>0} {
   
               set colvar [lindex $resultcount 0]
               set rowvar [lindex $resultcount 1]
               set nbcol  [llength $colvar]
   
               foreach line $rowvar {
                  set result_img ""
                  set result_tabkey ""
                  set cpt 0
                  foreach col $colvar {
                     if {$cpt>=0&&$cpt<=7} {lappend result_img    [list $col [lindex $line $cpt]]}
                     if {$cpt>7}           {lappend result_tabkey [list $col [lindex $line $cpt]]}
                     incr cpt
                  }
                  lappend result_img [list "tabkey" $result_tabkey]
                  lappend img_list $result_img
               }
            }
         }
      }

      set img_list [::bddimages_liste::add_info_cata $img_list]

      #::console::affiche_erreur " idbddimg_list = [::bddimages_liste::get_key_img_list idbddimg $img_list]\n"
      #::console::affiche_erreur " cataexist_list = [::bddimages_liste::get_key_img_list cataexist $img_list]\n"
      #::console::affiche_erreur " img_list = $img_list\n"
      return $img_list
   }




















   #--------------------------------------------------
   #  intellilist_to_imglist_i { }
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

   proc ::bddimages_liste::intellilist_to_imglist_i { intellilist } {

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

      set img_list ""

      foreach line $resultsql {

         set idhd [lindex $line 0]
         set sqlcritere [::bddimages_liste::get_sqlcritere $intellilist "images_$idhd"]
         set sqlcmd "SELECT images.idbddimg,
                            images.idheader,
                            images.tabname,
                            images.filename,
                            images.dirfilename,
                            images.sizefich,
                            images.datemodif,
                            commun.datejj as commundatejj,
                            images_$idhd.* 
                     FROM images,images_$idhd,commun
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

            if {$nbresult>0} {

               set colvar [lindex $resultcount 0]
               set rowvar [lindex $resultcount 1]
               set nbcol  [llength $colvar]

               foreach line $rowvar {
                  set result_img ""
                  set result_tabkey ""
                  set cpt 0
                  foreach col $colvar {
                     if {$cpt>=0&&$cpt<=7} {lappend result_img    [list $col [lindex $line $cpt]]}
                     if {$cpt>7}           {lappend result_tabkey [list $col [lindex $line $cpt]]}
                     incr cpt
                  }
                  lappend result_img [list "tabkey" $result_tabkey]
                  lappend img_list $result_img
               }
            }
         }
      }

      set img_list [::bddimages_liste::add_info_cata $img_list]

      #::console::affiche_erreur " idbddimg_list = [::bddimages_liste::get_key_img_list idbddimg $img_list]\n"
      #::console::affiche_erreur " cataexist_list = [::bddimages_liste::get_key_img_list cataexist $img_list]\n"
      #::console::affiche_erreur " img_list = $img_list\n"
      #foreach img $img_list {
      #   set commundatejj   [::bddimages_liste::get_key_img $img commundatejj]
      #   ::console::affiche_erreur "commundatejj = $commundatejj\n"
      #}


      return $img_list
   }





#  proc ::bddimages_admin_image::get_key_img_list { key img_list } {
#  
#     set y ""
#     foreach  img $img_list  {
#        lappend y [::bddimages_admin_image::get_key_img $key $img]
#     }
#     return $y
#  }
#
#

# img = { {key val} {..} }
 
   proc ::bddimages_liste::get_key_img { img key } {
   
      set val ""
      foreach row $img {
          set x [lsearch $row $key]
          if {$x!=-1} {
             set val [lindex $row 1]
             return $val
          }
      }
      return $val
   }

   proc ::bddimages_liste::get_key_img_tabkey { img key } {
   
      set val ""
      set tabkey ""
      foreach row $img {
          if {[lindex $row 0]=="tabkey"} {
             set tabkey [lindex $row 1]
             break
          }
      }
      if { $tabkey != "" } {
         foreach row $tabkey {
             if {[lindex $row 0]==$key} {
                set val [lindex $row 1]
                break
             }
         }
      }

      return $val
   }



   #--------------------------------------------------
   #  add_info_cata { img_list }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Ajoute les info de la base concernant les catas
   #
   #    procedure externe :
   #
   #    variables en entree : 
   #        img_list : liste image
   #
   #    variables en sortie :
   #        img_list : liste image avec les champs cata en plus
   #
   #--------------------------------------------------

   proc ::bddimages_liste::add_info_cata { img_list } {

      set sqlcmd "SELECT cataimage.idbddimg,
                         catas.idbddcata,
                         catas.filename as catafilename,
                         catas.dirfilename as catadirfilename,
                         catas.sizefich as catasizefich,
                         catas.datemodif as catadatemodif
                  FROM cataimage, catas 
                  WHERE cataimage.idbddcata = catas.idbddcata 
                  AND cataimage.idbddimg IN ("
      set cpt 0
      foreach img $img_list {
         #set idbddimg [lindex $img [lsearch $img idbddimg]]
         set idbddimg [::bddimages_liste::get_key_img $img idbddimg]
         if {$cpt == 0} {
            set sqlcmd "$sqlcmd $idbddimg"
         } else {
            set sqlcmd "$sqlcmd, $idbddimg"
         }
         incr cpt
      }
      set sqlcmd "$sqlcmd )"

      set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]


      if {$err} {
          # si l erreur est qu il n y a pas de table cata alors traiter ce cas special
          set resultcount 0
          set err 0
      }

      if {$err} {
         ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
         ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
         ::console::affiche_erreur "        err = $err\n"
         ::console::affiche_erreur "        msg = $msg\n"
         return
      }
      set nbresult [llength $resultcount]
      if {$nbresult>0} {
         set colvar [lindex $resultcount 0]
         set rowvar [lindex $resultcount 1]
         set nbcol  [llength $colvar]
         set keys [list idbddcata catafilename catadirfilename catasizefich catadatemodif]
         foreach line $rowvar {
            set idbddimg [lindex $line 0]
            foreach key $keys  {
               set cata($idbddimg,$key) [lindex $line [lsearch $colvar $key]]
            }
         }
      }

      set result_img_list ""
      foreach img $img_list {
         #set idbddimg [lindex $img [lsearch $img idbddimg]]
         set idbddimg [::bddimages_liste::get_key_img $img idbddimg]
         if {[info exists cata($idbddimg,idbddcata)]} {

            foreach key $keys  {
               lappend img [list $key $cata($idbddimg,$key)]
            }
            lappend img [list cataexist 1] 
            lappend img [list cataloaded 0] 

         } else {

            lappend img [list cataexist 0] 
            lappend img [list cataloaded 0] 
            
         }
         lappend result_img_list $img
         incr cpt
      }


      return $result_img_list
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
        ::console::affiche_resultat "intelliliste  = $intellilist \n"

      set form_req(nbimg) [llength [::bddimages_liste::intellilist_to_imglist $intellilist]]
      #::console::affiche_resultat "Nb img = $form_req(nbimg) \n"
      return
   }




















   #--------------------------------------------------
   #  remove_requete { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       efface une requete
   #
   #    procedure externe :
   #
   #    variables en entree : none
   #
   #    variables en sortie : none
   #
   #--------------------------------------------------
   proc remove_requete { } {
   
      variable This
      global indicereq
      global list_req
      global framereqcurrent

      set i $indicereq
      for {set x 1} {$x<=$indicereq} {incr x} {
         set err [catch {set a [$This.framereq.$x.sup cget -state]} msg ]
         if {!$err} {
            if {$a == "active" } {set i $x}
         }
      }

      set list_req($i,valide) "no"
      destroy $framereqcurrent.framereq.$i

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
      global framereqcurrent
      
      #--- Initialisation des combox
      set result [get_list_box_champs]
      set list_box_champs [lindex $result 1]
      set nbrows1 [ llength $list_box_champs ]
      set nbcols1 [lindex $result 0]
      set list_combobox [get_list_combobox]
      set nbrows2 [ llength $list_combobox ]
      set nbcols2 13

      #--- frame pour afficher les requetes
      set frch $framereqcurrent.framereq

      #--- Initialisation de la liste des requetes
      set indicereq [expr $indicereq + 1]

      if { [ info exists list_req($indicereq,champ) ] } {
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

      #--- Cree un frame pour la requete
      set frchch $frch.$indicereq
      frame $frchch -borderwidth 1 -relief solid
      pack $frchch -in $frch -anchor w -side top -expand 0 -padx 5 -pady 0
   
         #--- Cree la liste des champs
         ComboBox $frchch.combo1 \
            -width $nbcols1 -height 20 \
            -relief sunken -borderwidth 0 -editable 0 \
            -textvariable list_req($indicereq,champ) \
            -values $list_box_champs
         pack $frchch.combo1 -anchor center -side left -fill x -expand 1
         grid $frchch -sticky new
         #--- Cree la liste des conditions
         ComboBox $frchch.combo \
            -width $nbcols2 -height $nbrows2 \
            -relief sunken -borderwidth 0 -editable 0 \
            -textvariable list_req($indicereq,condition) \
            -values $list_combobox
         pack $frchch.combo -anchor center -side left -fill x -expand 1
         grid $frchch -sticky new
         #--- Cree une ligne d'entree pour la variable
         entry $frchch.dat -textvariable list_req($indicereq,valeur) -borderwidth 1 -relief groove -width 20 -justify left
         pack $frchch.dat -in $frchch -side left -anchor w -padx 1
         #--- Cree un bouton supprime requete
         button $frchch.sup -state normal -borderwidth 1 -relief groove -anchor c -text "-" \
            -command { ::bddimages_liste::remove_requete }
         pack $frchch.sup -in $frchch -side left -anchor w -padx 1
         #--- Cree un bouton ajout requete
         button $frchch.add -state active -borderwidth 1 -relief groove -anchor c -text "+" \
            -command { ::bddimages_liste::add_requete }
         pack $frchch.add -in $frchch -side left -anchor w -padx 1
   
      return
   }




















   #--------------------------------------------------
   #  ouvreCalendrier { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Ouverture d'un popup de selection d'une date
   #
   #    variables en entree :
   #        x y         position de la fenetre du calendrier
   #        clockformat format d'affichage de la date (e.g. "%Y.%m.%d")
   #        wdate       nom de la variable contenant la date choisie dans le calendrier  
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ouvreCalendrier { x y clockformat wdate } {
   
      variable This
      global langage

      # Langage de l'utilisateur (defaut: en)
      set userLang "en"
      set calendarLang [list de en fr it nl ru sv pt]
      set ulang [string range $langage 0 1]
      foreach lang $calendarLang {
         if {[string compare $lang $ulang] == "0"} {
            set userLang $ulang
         }
      }

      # Fenetre du calendrier
      set w [toplevel $This.calendar]
      wm overrideredirect $w 1
      frame $w.f -borderwidth 2 -relief solid -takefocus 0
      ::bdicalendar::chooser $w.f.d -language $userLang -mon 0 \
             -command [list set ::SEMA close] \
             -textvariable $wdate -clockformat $clockformat
      pack $w.f.d $w.f
      lassign [winfo pointerxy .] x y
      wm geometry $w "+${x}+${y}"
   
      set _w [grab current]
      if {$_w ne {} } {
         grab release $_w
         grab set $w
      }

      set ::SEMA ""
      tkwait variable ::SEMA

      if {$_w ne {} } {
         grab release $w
         grab set $_w
      }
      destroy $w
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
      global list_req
      global framereqcurrent

      set indicereq 0

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
      }

      set indicereqinit 0

      if { $edit } {
         set l $intellilisttotal($editid)
         #::console::affiche_resultat "edit : $edit\n"
         #::console::affiche_resultat "l : $l\n"
         ::bddimages_liste::load_intellilist $l
         parray form_req
         if { [info exists list_req ] } then { parray list_req }
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

      #--- Cree un frame pour le titre
      set framecurrent $This.title
      frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
      pack $framecurrent -in $This -anchor s -side top -expand 1 -fill x -padx 5 -pady 5
        #--- Cree un label
        label $framecurrent.titre -font $bddconf(font,arial_12_b) -text "$caption(bddimages_liste,title)"
        pack $framecurrent.titre -in $framecurrent -side top -padx 5 -pady 5

      #--- Cree un frame pour le nom de la liste
      set framecurrent $This.framename
      frame $framecurrent -borderwidth 1 -cursor arrow -relief flat
      pack $framecurrent -in $This -anchor c -side top -expand 0 -padx 5 -pady 5
        #--- Cree un label
        label $framecurrent.lab -text "$caption(bddimages_liste,nom)" -width 20
        pack $framecurrent.lab -in $framecurrent -side left -anchor w -padx 1
        #--- Cree une ligne d'entree pour la variable
        entry $framecurrent.dat -textvariable form_req(name) -borderwidth 1 -relief groove -width 25 -justify left
        pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1

      #--- Cree un frame pour le choix de date min et max
      image create photo icon_calendar
      icon_calendar configure -file [file join $audace(rep_plugin) tool bddimages icons calendar.gif]
      image create photo icon_clean
      icon_clean configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
      set clockformat "%Y-%m-%d"
      set framecurrent $This.datemindatemax
      frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
      pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

         # Date START
         frame $framecurrent.datemin -borderwidth 0 -cursor arrow
         pack $framecurrent.datemin -in $framecurrent -anchor w -side top -expand 0 -fill both -padx 3 -pady 3
            #--- Cree un label
            label $framecurrent.datemin.lab -text "DATE-OBS start" -width 20
            pack $framecurrent.datemin.lab -in $framecurrent.datemin -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable form_req(datemin)
            entry $framecurrent.datemin.date -textvariable ::bddimages_liste::form_req(datemin) -borderwidth 1 -relief groove  -justify left
            pack $framecurrent.datemin.date -in $framecurrent.datemin -side left -anchor w -padx 1
            #--- Creation du bouton d'acces au calendrier graphique
            button $framecurrent.datemin.calstart -image icon_calendar -borderwidth 1 \
               -command [list ::bddimages_liste::ouvreCalendrier %X %Y $clockformat ::bddimages_liste::form_req(datemin)]
            pack $framecurrent.datemin.calstart -in $framecurrent.datemin -side left -anchor e -padx 2 -pady 2 -expand 0
            #--- Creation du bouton de remise a zero de form_req(datemin)
            button $framecurrent.datemin.cleanstart -image icon_clean -borderwidth 1 \
               -command { set ::bddimages_liste::form_req(datemin) "" }
            pack $framecurrent.datemin.cleanstart -in $framecurrent.datemin -side left -anchor e -padx 2 -pady 2 -expand 0

         # Date START
         frame $framecurrent.datemax -borderwidth 0 -cursor arrow
         pack $framecurrent.datemax -in $framecurrent -anchor w -side top -expand 0 -fill both -padx 3 -pady 3
            #--- Cree un label
            label $framecurrent.datemax.lab -text "DATE-OBS stop" -width 20
            pack $framecurrent.datemax.lab -in $framecurrent.datemax -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable form_req(datemax)
            entry $framecurrent.datemax.date -textvariable ::bddimages_liste::form_req(datemax) -borderwidth 1 -relief groove -justify left
            pack $framecurrent.datemax.date -in $framecurrent.datemax -side left -anchor w -padx 1
            #--- Creation du bouton d'acces au calendrier graphique
            button $framecurrent.datemax.calstop -image icon_calendar -borderwidth 1 \
               -command [list ::bddimages_liste::ouvreCalendrier %X %Y $clockformat ::bddimages_liste::form_req(datemax)]
            pack $framecurrent.datemax.calstop -in $framecurrent.datemax -side left -anchor e -padx 2 -pady 2 -expand 0
            #--- Creation du bouton de remise a zero de form_req(datemax)
            button $framecurrent.datemax.cleanstart -image icon_clean -borderwidth 1 \
               -command { set ::bddimages_liste::form_req(datemax) "" }
            pack $framecurrent.datemax.cleanstart -in $framecurrent.datemax -side left -anchor e -padx 2 -pady 2 -expand 0

      #--- Cree un frame pour afficher le type de logique AND / OR
      set framecurrent $This.frame1
      frame $framecurrent -borderwidth 0 -cursor arrow
      pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

         #--- Bouton a cocher
         checkbutton $framecurrent.check -highlightthickness 0 -state normal -variable form_req(type_req_check) -command { }
         pack $framecurrent.check -in $framecurrent -side left -anchor center -padx 5
         #--- Cree un label
         label $framecurrent.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,repondrea)"
         pack $framecurrent.txt1 -in $framecurrent -side left -anchor w -padx 1
         #--- Cree un combox pour le choix
         ComboBox $framecurrent.combo1 \
             -width 20 -height 2 -font $bddconf(font,arial_10_b)\
             -relief raised -borderwidth 1 -editable 0 \
             -textvariable form_req(type_requ) \
             -values $list_comb1
         pack $framecurrent.combo1 -anchor center -side left -fill x -expand 0
         #--- Cree un label
         label $framecurrent.txt2 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,regles)"
         pack $framecurrent.txt2 -in $framecurrent -side left -anchor w -padx 1

      #--- Cree un frame pour ajouter des requetes
      set framereqcurrent $This.addreq
      frame $framereqcurrent -borderwidth 0 -cursor arrow
      pack $framereqcurrent -in $This -anchor s -side top -fill x -padx 5 -pady 5

         #--- Cree un bouton d'ajout de requete
         button $framereqcurrent.add -state active -borderwidth 1 -width 45 -text "$caption(bddimages_liste,addrule)" \
            -command { ::bddimages_liste::add_requete }
         pack $framereqcurrent.add -in $framereqcurrent -side top -padx 5 -pady 5 

         #--- Cree un frame pour afficher les requetes
         frame $framereqcurrent.framereq -borderwidth 0 -cursor arrow
         pack $framereqcurrent.framereq -in $framereqcurrent -anchor s -side top -expand 1 -fill both
         #--- Ajout des requetes
         for { set x 0 } { $x < $indicereqinit } { incr x } {
            ::bddimages_liste::add_requete
         }

      #--- Cree un frame pour les options
      set framecurrent $This.frame2
      frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
      pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

         #--- Check button
         frame $framecurrent.1 -borderwidth 0 -cursor arrow
         pack $framecurrent.1 -in $framecurrent -anchor n -side left -expand 1 -fill x -padx 1 -pady 5
            #--- Bouton check
            checkbutton $framecurrent.1.check -highlightthickness 0 -state normal -variable form_req(choix_limit_result) -command { }
            pack $framecurrent.1.check -in $framecurrent.1 -side left -anchor c -padx 5

         #--- Options:
         frame $framecurrent.2 -borderwidth 0 -cursor arrow
         pack $framecurrent.2 -in $framecurrent -anchor s -side left -expand 1 -fill x -padx 1 -pady 3

            #--- limite a
            frame $framecurrent.2.l -borderwidth 0 -cursor arrow
            pack $framecurrent.2.l -in $framecurrent.2 -anchor c -side top -expand 1 -fill x -padx 1 -pady 3
               #--- Cree un label
               label $framecurrent.2.l.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,limitera)"
               pack $framecurrent.2.l.txt1 -in $framecurrent.2.l -side left -anchor w -padx 2
               #--- Cree une ligne d'entree pour la variable
               entry $framecurrent.2.l.dat -textvariable form_req(limit_result) -borderwidth 1 -relief groove -width 8 -justify center
               pack $framecurrent.2.l.dat -in $framecurrent.2.l -side left -anchor w -padx 2
               #--- Cree un combox pour le choix
               ComboBox $framecurrent.2.l.combo \
                   -width 10 -height 1 \
                   -relief sunken -borderwidth 1 -editable 0 \
                   -textvariable form_req(type_result) \
                   -values $list_comb2
               pack $framecurrent.2.l.combo -in $framecurrent.2.l -anchor center -side left -fill x -expand 0
            #--- selection
            frame $framecurrent.2.s -borderwidth 0 -cursor arrow
            pack $framecurrent.2.s -in $framecurrent.2 -anchor c -side top -expand 1 -fill x -padx 1 -pady 3
               #--- Cree un label
               label $framecurrent.2.s.txt2 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,selectpar)"
               pack $framecurrent.2.s.txt2 -in $framecurrent.2.s -side left -anchor w -padx 2
               #--- Cree un combox pour le choix
               ComboBox $framecurrent.2.s.combo2 \
                   -width 27 -height 7 \
                   -relief sunken -borderwidth 1 -editable 0 \
                   -textvariable form_req(type_select) \
                   -values $list_comb3
               pack $framecurrent.2.s.combo2 -in $framecurrent.2.s -anchor center -side left -fill x -expand 0

      #--- Cree un frame pour le calcul du nombre d images
      set framecurrent $This.frame3
      frame $framecurrent -borderwidth 0 -cursor arrow
      pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

         #--- Cree un label
         label $framecurrent.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,nbresreq)"
         pack $framecurrent.txt1 -in $framecurrent -side left -anchor w -padx 1
         #--- Cree une ligne d'entree pour la variable
         entry $framecurrent.dat -textvariable form_req(nbimg) -state readonly -borderwidth 1 -relief groove -width 8 -justify center
         pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1
         #--- Cree un bouton ajout requete
         button $framecurrent.calc -state active -borderwidth 1 -relief groove -anchor c -text "$caption(bddimages_liste,calcul)" \
            -command { ::bddimages_liste::calcul_nbimg }
         pack $framecurrent.calc -in $framecurrent -side left -anchor w -padx 1

      #--- Cree un frame pour y mettre les boutons
      frame $This.frame11 -borderwidth 0 -cursor arrow
      pack $This.frame11 -in $This -anchor s -side bottom -expand 0 -fill x -pady 5

         #--- Creation du bouton annuler
         button $This.frame11.but_annuler -text "$caption(bddimages_liste,annuler)" -borderwidth 2 \
              -command { ::bddimages_liste::fermer }
         pack $This.frame11.but_annuler -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0
         #--- Creation du bouton ok
         button $This.frame11.but_ok -text "$caption(bddimages_liste,ok)" -borderwidth 2 \
              -command { ::bddimages_liste::accept }
         pack $This.frame11.but_ok -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0
         #--- Creation du bouton aide
         button $This.frame11.but_aide -text "$caption(bddimages_liste,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
         pack $This.frame11.but_aide -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

      #--- La fenetre est active
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }



















#--- Fin Classe

}
