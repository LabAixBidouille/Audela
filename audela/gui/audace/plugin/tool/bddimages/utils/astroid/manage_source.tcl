#--------------------------------------------------
# source audace/plugin/tool/av4l/manage_source.tcl
#--------------------------------------------------
#
# Fichier        : manage_source.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: manage_source.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::manage_source {



   #----------------------------------------------------------------------------
   ## Renvoi le nombre de source dans une listsource
   #  @param listsources    variable de type listsource
   proc ::manage_source::get_nb_sources { listsources } {

      set sources [lindex $listsources 1]
      set cpt 0
      foreach s $sources { 
         incr cpt
      }
      return $cpt
   }


   #----------------------------------------------------------------------------
   ## Renvoi le nombre de source dans une listsource et pour
   #  un catalogue donne.
   #  @param listsources    variable de type listsource
   #  @param catalog        Chaine du nom du catalogue
   proc ::manage_source::get_nb_sources_by_cata { listsources catalog } {

      set sources [lindex $listsources 1]
      set cpt 0
      foreach s $sources { 
         foreach cata $s {
            if { [string toupper [lindex $cata 0]] == $catalog } {
               incr cpt
            }
         }
      }
      return $cpt
   }

   #----------------------------------------------------------------------------
   ## Renvoi le nombre de source dans une listsource et donne 
   #  le nombre de source pour tous les catalogues present.
   #  @param listsources    variable de type listsource
   proc ::manage_source::get_nb_sources_rollup { listsources } {

       set sources [lindex $listsources 1]
       set cpt 0
       foreach s $sources { 
          incr cpt
          foreach cata $s {
             set namecata [string toupper [lindex $cata 0]]
             if { [info exists nbcata($namecata)] } {
                incr nbcata($namecata)
             } else {
                set nbcata($namecata) 1
             }
          }
       }
       set result [array get nbcata]
       lappend  result "TOTAL" $cpt
       return $result
   }



   #----------------------------------------------------------------------------
   ## Renvoi la liste des catalogues d une listsource.
   #  @param listsources    variable de type listsource
   proc ::manage_source::get_cata_from_sources { listsources } {

       set catalist {}
       set fields  [lindex $listsources 0]
       foreach s $fields { 
          lappend catalist [lindex $s 0]
       }
   return $catalist
   }

   #----------------------------------------------------------------------------
   ## Renvoi la liste des champs des entetes des catalogues d une listsource.
   #  @param listsources    variable de type listsource
   proc ::manage_source::get_fields_from_sources { listsources } {

   return [lindex $listsources 0]
   }


   #----------------------------------------------------------------------------
   ## Renvoi une listsource qui est .
   #  @param listsources    variable de type listsource
   proc ::manage_source::extract_sources_by_catalog { listsources catadem } {

       set fields  [lindex $listsources 0]
       #foreach s $fields { 
       #      ::console::affiche_resultat "$s\n"
       #}
       set newsources {}
       set sources [lindex $listsources 1]
       foreach s $sources {
          foreach cata $s {
             if {[string toupper [lindex $cata 0]] == $catadem} {
               lappend newsources $s
             }
          }
       }
   return [list $fields $newsources]
   }


   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::extract_catalog { listsources catadem } {

       set fields  [lindex $listsources 0]
       set newfields {}
       foreach f $fields { 
             if { [lindex $f 0] == $catadem } {
               lappend newfields $f 
             }
       }
       set newsources {}
       set sources [lindex $listsources 1]
       foreach s $sources {
          foreach cata $s {
             if {[string toupper [lindex $cata 0]] == $catadem} {
               lappend newsources [list $cata ]
             }
          }
       }
   return [list $newfields $newsources]
   }



   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::delete_catalog { listsources catadem } {

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set cpt 0
      set newsources {}
      foreach s $sources {
          set news {}
          foreach cata $s {
             if {[string toupper [lindex $cata 0]] != $catadem} {
               lappend news $cata
               incr cpt
             }
          }
          lappend newsources $news
      }

      if {$cpt!=0} {
          set newfields {}
          foreach f $fields { 
             if { [lindex $f 0] != $catadem } {
               lappend newfields $f 
             }
          }
      } else {
          set newfields $fields
      }

      return [list $newfields $newsources]
   }




   #------------------------------------------------------------
   ## Fonction qui supprime le catalogue ASTROID d'une source
   # @param p_s pointeur d'une source qui sera modifiee
   # @return void
   #
   proc ::manage_source::delete_catalog_in_source { p_s catadem } {
      
      upvar $p_s s

      set pos [lsearch -index 0 $s $catadem]
      if {$pos != -1} {
         set s [lreplace $s $pos $pos]
      }
   }



   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_all_sources { listsources } {

      ::console::affiche_resultat "** SOURCES = \n"
      ::console::affiche_resultat "FIELDS = \n"
      set fields  [lindex $listsources 0]
      foreach s $fields { 
         ::console::affiche_resultat "$s\n"
      }
      ::console::affiche_resultat "VALUES = \n"
      set sources [lindex $listsources 1]
      foreach s $sources { 
         ::console::affiche_resultat "$s\n"
      }
      }

   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_3_sources { listsources } {

      set nb 0
      ::console::affiche_resultat "FIELDS = \n"
      set fields  [lindex $listsources 0]
      foreach s $fields { 
         ::console::affiche_resultat "$s\n"
      }
      ::console::affiche_resultat "VALUES = \n"
      set sources [lindex $listsources 1]
      foreach s $sources { 
         ::console::affiche_resultat "$s\n"
         incr nb
         if {$nb>2} {
            return
         }
      }
   }

   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_sources { listsources catalog } {

       set nb 0
       ::console::affiche_resultat "** SOURCES $catalog = \n"
       ::console::affiche_resultat "FIELDS = \n"
       set fields  [lindex $listsources 0]
       foreach s $fields { 
          ::console::affiche_resultat "$s\n"
          }
       ::console::affiche_resultat "VALUES = \n"
       set sources [lindex $listsources 1]
       foreach s $sources { 
          foreach cata $s {
             if { [string toupper [lindex $cata 0]] == $catalog } {
                ::console::affiche_resultat "$s\n"
             }
          }
       }
   }
   
   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_sources_vrac { listsources } {

      ::console::affiche_resultat "$listsources\n"
   }
   

   proc ::manage_source::namincata { mysource } {

      set list_of_cata [list SKYBOT TYCHO2 UCAC4 UCAC3 UCAC2 2MASS PPMX PPMXL USNOA2 WFIBC]
      foreach cata $list_of_cata {
          foreach mycata $mysource {
             if {[lindex $mycata 0] == $cata} {
                return [::manage_source::naming $mysource $cata]
             }
          }
      }
      return ""
   }



   proc ::manage_source::namable { mysource } {

      set list_of_cata [list USER SKYBOT TYCHO2 UCAC4 UCAC3 UCAC2 2MASS PPMX PPMXL USNOA2 WFIBC ASTROID IMG]
      foreach cata $list_of_cata {
          foreach mycata $mysource {
             if {[lindex $mycata 0] == $cata} {
                return $cata
             }
          }
      }
      return ""
   }

   proc ::manage_source::list_of_cata { mysource } {

      set list_of_cata ""
      foreach mycata $mysource {
         set mycata [lindex $mycata 0]
         if {[lsearch $list_of_cata $mycata]==-1} {
            set list_of_cata [linsert $list_of_cata end $mycata]
         }
      }
      return $list_of_cata
   }

   proc ::manage_source::list_of_name { mysource } {

      set list_of_name ""
      foreach mycata $mysource {
         set mycata [lindex $mycata 0]
         set name [::manage_source::naming $mysource $mycata]
         set list_of_name [linsert $list_of_name end $name]
      }
      return $list_of_name
   }

   #
   # manage_source::name_cata
   # retourne le nom du catalogue pour un nom de source 
   #
   proc ::manage_source::name_cata { name } {
       set a [split $name "_"]
       return [lindex $a 0]
   }

   #
   # manage_source::naming
   # Fournit une denomination selon le type de catalogue
   #
   proc ::manage_source::naming { mysource mycata} {

      foreach cata $mysource {
      
         if {[string toupper [lindex $cata 0]] == $mycata} {

            if {$mycata == "USER"} {
               return "USER_[string trim [lindex [lindex $cata 2] 1] ]"
            }
            
            if {$mycata == "IMG"} {
               set ra  [format "%.6f" [lindex [lindex $cata 2] 8] ]
               set dec [format "%.6f" [lindex [lindex $cata 2] 9] ]
               if {$dec > 0} {
                  set dec [regsub {\+} $dec ""]
                  set dec "+$dec"
                }
               return "IMG_${ra}${dec}"
            }

            if {$mycata == "ASTROID"} {
               set othf [lindex $cata 2]
               set ra  [format "%.6f" [::bdi_tools_psf::get_val othf "ra" ] ]
               set dec [format "%.6f" [::bdi_tools_psf::get_val othf "dec"] ]
               if {$dec > 0} {
                  set dec [regsub {\+} $dec ""]
                  set dec "+$dec"
                }
               return "ASTROID_${ra}${dec}"
            }

            if {$mycata == "SKYBOT"} {
               set name [lindex [lindex $cata 2] 1] 
               set i [regsub -all {\W} $name "_" name] 
               set name "SKYBOT_[lindex [lindex $cata 2] 0]_$name"
               return $name
            }

            if {$mycata == "UCAC4"} {
               set id [lindex [lindex $cata 2] 0]
               return "UCAC4_$id"
            }

            if {$mycata == "UCAC3"} {
               set id [lindex [lindex $cata 2] 0]
               return "UCAC3_$id"
            }

            if {$mycata == "UCAC2"} {
               set id [lindex [lindex $cata 2] 0]
               return "UCAC2_$id"
            }

            if {$mycata == "USNOA2"} {
               set id [lindex [lindex $cata 2] 0]
               return "USNOA2_${id}"
            }

            if {$mycata == "PPMX"} {
               set id [lindex [lindex $cata 2] 0]
               return "PPMX_${id}"
            }

            if {$mycata == "PPMXL"} {
               set id [lindex [lindex $cata 2] 0]
               return "PPMXL_${id}"
            }

            if {$mycata == "NOMAD1"} {
               set id [lindex [lindex $cata 2] 0]
               return "NOMAD1_${id}"
            }

            if {$mycata == "TYCHO2"} {
               set id1 [lindex [lindex $cata 2] 1]
               set id2 [lindex [lindex $cata 2] 2]
               set id3 [lindex [lindex $cata 2] 3]
               return "TYCHO2_${id1}_${id2}_${id3}"
            }

            if {$mycata == "2MASS"} {
               set id [lindex [lindex $cata 2] 0]
               return "2MASS_$id"
            }

            if {$mycata == "WFIBC"} {
               set ra  [format "%.6f" [lindex [lindex $cata 2] 0] ]
               set dec [format "%.6f" [lindex [lindex $cata 2] 1] ]
               if {$dec > 0} {
                  set dec [regsub {\+} $dec ""]
                  set dec "+$dec"
                }
               return "WFIBC_${ra}${dec}"
            }

         }
      }
      return ""
   }

   #
   # manage_source::name2ids
   # Fournit l'id de la source nomm� par dans astroid
   #
   proc ::manage_source::name2ids { myname p_listsources} {
      
      upvar $p_listsources listsources 

      set mycata [::manage_source::name_cata $myname]
      set fields [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set ids 0
      foreach s $sources {
         set name [::manage_source::naming $s $mycata ]
         if {$myname == $name} { return $ids }
         incr ids
      }
      return -1
   }



   #
   # manage_source::set_common_fields
   # initialise les champ common de la liste
   # 
   #
   # listsources : liste en entree
   # catalog : ou il faut puiser l info
   # fieldlist : les champs a utiliser
   #
   proc ::manage_source::set_common_fields { listsources catalog fieldlist } {


      set cst 0
      foreach f $fieldlist {
         if {[string is double -strict $f]} {
            incr cst
         }
      }
      #gren_info "cst = $cst \n"

      set idlist ""
      set fields [lindex $listsources 0]
      #gren_info "FIELDS = $fields\n"
      foreach cata $fields {
         #gren_info "CATA: [string toupper [lindex $cata 0]] -> catalog? $catalog\n"
         if { [string toupper [lindex $cata 0]] == $catalog } {
            set cols [lindex $cata 2]
            foreach f $fieldlist {
               #gren_info "     f = $f \n"
               if {[string is double -strict $f]} {
                  #gren_info "double \n"
                  lappend idlist -1
               } else {
                  #gren_info "char \n"
                  set cpt 0
                  foreach col $cols {
                     if {$f==$col} {
                         lappend idlist $cpt
                     }
                     incr cpt
                  }
               }
            }
         }
      }

      set cmfields [list ra dec poserr mag magerr]
      set newfields {}
      foreach cata $fields {
         set cata [lreplace $cata 1 1 $cmfields]
         lappend newfields $cata
      }
      
      #gren_info "idlist = $idlist \n"
      if {[llength $idlist]!=5} {
          gren_info "erreur nom des champs\n"
          return $listsources
      }

      set sources [lindex $listsources 1]
      set ids 0
      foreach s $sources {
         set sa($ids,catalog) ""
         foreach cata $s {
            lappend sa($ids,catalog) [string toupper [lindex $cata 0]]
            set sa($ids,[string toupper [lindex $cata 0]]) $cata
               if {$ids == -1 } {
                  gren_info "catalog = $sa($ids,[string toupper [lindex $cata 0]])\n"
               }
         }
      incr ids
      }
      set nbs $ids
      #gren_info "idlist = $idlist\n"
      #gren_info "nbs = $nbs\n"
      
      for {set ids 0} {$ids<$nbs} {incr ids} {
         if {[info exists sa($ids,$catalog)] } {
               set data [lindex $sa($ids,$catalog) 2]
               
               if {[string is double -strict [lindex $fieldlist 0]]} {
                  set ra [lindex $fieldlist 0]
               } else {
                  set ra [lindex $data [lindex $idlist 0]]
               }

               if {[string is double -strict [lindex $fieldlist 1]]} {
                  set dec [lindex $fieldlist 1]
               } else {
                  set dec [lindex $data [lindex $idlist 1]]
               }

               if {[string is double -strict [lindex $fieldlist 2]]} {
                  set poserr [lindex $fieldlist 2]
               } else {
                  set poserr [lindex $data [lindex $idlist 2]]
               }

               if {[string is double -strict [lindex $fieldlist 3]]} {
                  set mag [lindex $fieldlist 3]
               } else {
                  set mag [lindex $data [lindex $idlist 3]]
               }

               if {[string is double -strict [lindex $fieldlist 4]]} {
                  set magerr [lindex $fieldlist 4]
               } else {
                  set magerr [lindex $data [lindex $idlist 4]]
               }

               set com [list $ra \
                             $dec \
                             $poserr \
                             $mag \
                             $magerr \
                       ]
               set sa($ids,$catalog) [lreplace $sa($ids,$catalog) 1 1 $com]
               if {$ids == -1 } {
                  gren_info "sa $catalog = $sa($ids,$catalog)\n"
                  gren_info "catalog = $catalog\n"
                  gren_info "data = $data\n"
               
                  gren_info "com = $com\n"
               }
         }
      }

      set sources ""       
      for {set ids 0} {$ids<$nbs} {incr ids} {
         set s ""
         foreach cata $sa($ids,catalog) {
            lappend s $sa($ids,$cata)
         }
         lappend sources $s
      }

      #gren_info "fin\n"
      
      return [list $newfields $sources]

   }




   #
   # manage_source::extract_sources_by_array
   # Fournit le nombre de source
   #
   proc ::manage_source::extract_sources_by_array { rect listsources } {

      gren_info "ARRAY=$rect\n"

      set fields  [lindex $listsources 0]
      foreach s $fields { 
            ::console::affiche_resultat "$s\n"
            }
      set newsources {}
      set sources [lindex $listsources 1]
      foreach s $sources {
         set kelcata ""
         set pass "no"
         foreach cata $s {
            append kelcata "[string toupper [lindex $cata 0]] "
            if {[string toupper [lindex $cata 0]] == "IMG"} {
              set x [lindex [lindex [lindex $s 0] 2] 2]
              set y [lindex [lindex [lindex $s 0] 2] 3]
              if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                 set pass "yes"
                 lappend newsources $s
                 set ra [lindex [lindex [lindex $s 0] 2] 8]
                 set dec [lindex [lindex [lindex $s 0] 2] 9]
              }
            }
         }
         
         if {$pass == "yes" } {
            #gren_info "X Y = $x $y | $kelcata | RA DEC = $ra $dec\n"
            #gren_info "affich_un_rond_xy $x $y \"blue\" 1 1"
            #gren_info "affich_un_rond $ra $dec \"red\" 2"
         }
      }
      return [list $fields $newsources]
   }


   #
   # 
   # Fournit un tableau de sources uniques extraites des catalogues stellaires
   # utilise cata_list
   #
   proc ::manage_source::extract_tabsources_by_flagastrom { flagastrom p_tabsources } {

      upvar $p_tabsources tabsources

      array unset tabsources

      foreach {id_source current_listsources} [array get ::gui_cata::cata_list] {
 
         foreach s [lindex $current_listsources 1] {
            set p [lsearch -index 0 $s "ASTROID"]
            if {$p != -1} {
               set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
               set ar [::bdi_tools_psf::get_val othf "flagastrom"]
               if {$ar == $flagastrom} {
                  set ac [::bdi_tools_psf::get_val othf "cataastrom"]
                  set p [lsearch -index 0 $s $ac]
                  if {$p!=-1} {
                     set obj [lindex $s $p]
                     set name [::manage_source::naming $s $ac]
                     set tabsources($name) $obj
                  } else {
                     gren_erreur "trouver l'erreur...\n"
                  } 
               }
            }
         }
 
      }
      return

   }


   #
   # 
   # Fournit un tableau de sources de reference et de science extraites des catalogues stellaires pour une image donnee par son id
   # utilise cata_list
   #
   proc ::manage_source::extract_tabsources_by_idimg { id p_tabsources } {
      
      upvar $p_tabsources tabsources
      
      array unset tabsources

      set current_listsources $::gui_cata::cata_list($id)

      foreach s [lindex $current_listsources 1] {
         set p [lsearch -index 0 $s "ASTROID"]
         if {$p != -1} {
            set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
            set ar [::bdi_tools_psf::get_val othf "flagastrom"]
            if {$ar == "R" || $ar == "S"} {
               set ac [::bdi_tools_psf::get_val othf "cataastrom"]
               set p [lsearch -index 0 $s $ac]
               if {$p != -1} {
                  set obj [lindex $s $p]
                  set name [::manage_source::naming $s $ac]
                  set tabsources($name) [list $ar $ac $othf]
               } else {
                  gren_erreur "trouver l'erreur...\n"
               } 
            }
         }
      }

      return

   }

# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/manage_source.tcl
# ::manage_source::set_common_fields $listsources IMG { id flag xpos ypos instr_mag }
# ::manage_source::imprim_3_sources $listsources
# set l [::manage_source::set_common_fields $listsources IMG { id flag xpos ypos instr_mag }]
# ::manage_source::imprim_3_sources $l


}
