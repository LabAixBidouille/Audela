#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_admin_cata.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_admin_cata.tcl
# Description    : Environnement de gestion des listes d images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6969 2011-03-16 17:12:35Z fredvachier $
#
#--------------------------------------------------
# - Namespace bddimages_admin_image
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

namespace eval bddimages_admin_cata {

   global audace
   global bddconf
























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

   proc ::bddimages_admin_cata::add_info_cata { img_list } {

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
         set idbddimg [lindex $img [lsearch $img idbddimg]]
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
         set idbddimg [lindex $img [lsearch $img idbddimg]]
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


















#--- Fin Classe

}
