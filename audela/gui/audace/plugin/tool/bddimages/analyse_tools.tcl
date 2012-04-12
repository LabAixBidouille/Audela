#--------------------------------------------------
# source audace/plugin/tool/bddimages/analyse_tools.tcl
#--------------------------------------------------
#
# Fichier        : analyse_tools.tcl
# Description    : Procedures d analyses de l image
#                  sans GUI.
# Auteur         : Frédéric Vachier
# Mise à jour $Id: analyse_tools.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace analyse_tools
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  
#
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
# { {TELESCOP { {TELESCOP} {TAROT CHILI} string {Observatory name} } }
#   {NAXIS2   { {NAXIS2}   {1024}        int    {}                 } }
#    etc ...
# }
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

namespace eval analyse_tools {

   global audace
   global bddconf

   variable id_current_image
   variable current_image
   variable current_cata
   variable current_image_name
   variable current_image_date
   variable img_list
   variable nb_img_list
   variable current_listsources

   variable use_skybot
   variable use_usnoa2
   variable use_ucac2
   variable use_ucac3
   variable use_nomad1
   variable use_tycho2

   variable catalog_usnoa2
   variable catalog_ucac2
   variable catalog_ucac3
   variable catalog_nomad1
   variable catalog_tycho2

   variable use_skybot
   variable keep_radec
   variable create_cata
   variable boucle

   variable ra_save
   variable dec_save

   variable nb_img
   variable nb_usnoa2
   variable nb_ucac2
   variable nb_ucac3
   variable nb_nomad1
   variable nb_tycho2
   variable nb_skybot
   variable nb_ovni

   variable size_img
   variable size_usnoa2
   variable size_ucac2
   variable size_ucac3
   variable size_nomad1
   variable size_tycho2
   variable size_skybot
   variable size_ovni

   variable color_img     "blue"
   variable color_usnoa2  "green"
   variable color_ucac2   "cyan"
   variable color_ucac3   "red"
   variable color_nomad1  "brown"
   variable color_tycho2  "white"
   variable color_skybot  "magenta"
   variable color_ovni    "yellow"

   variable ra       
   variable dec      
   variable pixsize1 
   variable pixsize2 
   variable foclen   
   variable exposure 

   variable delpv
   variable deuxpasses


   proc ::analyse_tools::get_wcs {  } {

      global audace
      global bddconf


         set limit_nbstars_accepted 10

         set img $::analyse_tools::current_image
 
         set wcs_ok false

         # Infos sur l'image a traiter
         set tabkey [::bddimages_liste::lget $img "tabkey"]

         set ra         $::analyse_tools::ra       
         set dec        $::analyse_tools::dec      
         set pixsize1   $::analyse_tools::pixsize1 
         set pixsize2   $::analyse_tools::pixsize2 
         set foclen     $::analyse_tools::foclen   
         set exposure   $::analyse_tools::exposure 

#         set ra          [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
#         set dec         [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
#         set pixsize1    [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
#         set pixsize2    [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
#         set foclen      [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
#         set exposure    [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]

         set dateobs     [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
         set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
         set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
         set filename    [::bddimages_liste::lget $img filename   ]
         set dirfilename [::bddimages_liste::lget $img dirfilename]
         set idbddimg    [::bddimages_liste::lget $img idbddimg]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]

         #gren_info "idbddimg    $idbddimg\n"
        #gren_info "ra          $ra\n"
        #gren_info "dec         $dec\n"
        #gren_info "pixsize1    $pixsize1\n"
        #gren_info "pixsize2    $pixsize2\n"
        #gren_info "foclen      $foclen\n"
        #gren_info "dateobs     $dateobs \n"
        #gren_info "exposure    $exposure\n"
         #gren_info "naxis1      $naxis1  \n"
         #gren_info "naxis2      $naxis2  \n"
         #gren_info "filename    $filename\n"
         #gren_info "dirfilename $dirfilename\n"
         #gren_info "file        $file\n"

         set xcent    [expr $naxis1/2.0]
         set ycent    [expr $naxis2/2.0]
         #gren_info "xcent ycent $xcent $ycent\n"

         #gren_info "** Calibration de l image\n"

         #gren_info "param : $ra $dec $pixsize1 $pixsize2 $foclen\n"
         #gren_info "catalog_usnoa2 : $::analyse_tools::catalog_usnoa2\n"
 
         gren_info "calibwcs $ra $dec * * * USNO  $::analyse_tools::catalog_usnoa2 del_tmp_files 0\n"
         set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 del_tmp_files 0]} msg]
         if {$erreur} { return false }

         #gren_info "calibwcs $ra $dec * * * USNO  $::analyse_tools::catalog_usnoa2\n"
         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]
         #gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"

         if {$::analyse_tools::deuxpasses} {
            set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 del_tmp_files 0]} msg]
            if {$erreur} { return false }
            set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
            set ra  [lindex $a 0]
            set dec [lindex $a 1]
            gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
         }

         if { $::analyse_tools::keep_radec==1 && $nbstars<$limit_nbstars_accepted } {
             set ra  $::analyse_tools::ra_save
             set dec $::analyse_tools::dec_save
             set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 del_tmp_files 0]} msg]
             if {$erreur} { return false }
             #gren_info "calibwcs $ra $dec * * * USNO  $::analyse_tools::catalog_usnoa2\n"
             set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
             set ra  [lindex $a 0]
             set dec [lindex $a 1]
             #gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"

             if {$::analyse_tools::deuxpasses} {
                set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 del_tmp_files 0]} msg]
                if {$erreur} { return false }
                set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
                set ra  [lindex $a 0]
                set dec [lindex $a 1]
                gren_info "RETRY nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
             }
         }         


         set ::analyse_tools::nb_usnoa2 $nbstars

         set ::analyse_tools::current_listsources [get_ascii_txt]
         set ::analyse_tools::nb_img    [::manage_source::get_nb_sources_by_cata $::analyse_tools::current_listsources IMG   ]
         set ::analyse_tools::nb_ovni   [::manage_source::get_nb_sources_by_cata $::analyse_tools::current_listsources OVNI  ]
         set ::analyse_tools::nb_usnoa2 [::manage_source::get_nb_sources_by_cata $::analyse_tools::current_listsources USNOA2]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::analyse_tools::current_listsources]\n"




         if {$::analyse_tools::create_cata} {



            set catafile        [file join $bddconf(dirbase) $dirfilename $filename .xml]
            write_cata_votable $listsources $catafile
         }








        if {$nbstars > $limit_nbstars_accepted} {
             set wcs_ok true
         }         
          
#   gren_info "Chargement de la liste des sources\n"
#   set listsources [get_ascii_txt]
#   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
 
         if {$wcs_ok} {

             set ::analyse_tools::ra_save $ra 
             set ::analyse_tools::dec_save $dec

             set ident [bddimages_image_identification $idbddimg]
             #gren_info "\n\n** ident = $ident $idbddimg\n"
             set fileimg  [lindex $ident 1]
             set filecata [lindex $ident 3]
             if {$fileimg == -1} {
                ::console::affiche_erreur "Fichier image inexistant ($idbddimg) \n"
                return false
             }

             # Efface les cles PV1_0 et PV2_0 car pas bon
             if {$::analyse_tools::delpv} {
                buf$::audace(bufNo) delkwd PV1_0
                buf$::audace(bufNo) delkwd PV2_0
             }

             # Modifie le champs BDI
             set key [buf$::audace(bufNo) getkwd "BDDIMAGES WCS"]
             set key [lreplace $key 1 1 "Y"]
             buf$::audace(bufNo) setkwd $key

             set fichtmpunzip [unzipedfilename $fileimg]
             set filetmp      [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
             set filefinal    [file join $::bddconf(dirinco) [file tail $fileimg]]

             createdir_ifnot_exist $bddconf(dirtmp)
             buf$::audace(bufNo) save $filetmp
             set errnum [catch {exec gzip -c $filetmp > $filefinal} msg ]

             # copie l image dans incoming, ainsi que le fichier cata si il existe
             if {$filecata != -1} {
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
             return true
         } 
         
         return false
   }



# Fin Classe
}
