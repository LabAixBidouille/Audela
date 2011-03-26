#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_cdl.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_admin_image.tcl
# Description    : Environnement de gestion des listes d images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6969 2011-03-16 17:12:35Z fredvachier $
#
#--------------------------------------------------
# - Namespace bddimages_cdl
# - Fichiers source externe :
#       bddimages_cdl.cap
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

namespace eval bddimages_cdl {

   global audace
   global bddconf
   global caption



   proc ::bddimages_cdl::run { this } {

      global This
      global entetelog
      set entetelog "Courbe de Lumiere"
      set This $this


      set reply [tk_dialog $This.confirmDialog "choisir une zone autour de l asteroide" \
                    questhead 1 "Annuler" "Ok"]
      if {$reply} {
         ::console::affiche_resultat "oh�\n"
         #set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
         #set l [lsort -decreasing -integer $l]
         #foreach i $l {
         #   set idbddimg  [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
         #   bddimages_image_delete $idbddimg
         #   $::bddimages_recherche::This.frame6.result.tbl delete $i
         #}
      }

   }



































#--- Fin Classe

}
