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
   variable color_nomad1  "#b4b308"
   variable color_tycho2  "orange"
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
   variable limit_nbstars_accepted
   variable log
















   proc ::analyse_tools::get_cata {  } {

      global bddconf

      # Noms du fichier et du repertoire du cata TXT
      set imgfilename [::bddimages_liste::lget $::analyse_tools::current_image filename]
      set imgdirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
      # Definition du nom du cata XML
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      # Liste des champs du header de l'image
      set tabkey [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]

      # Liste des sources de l'image
      set listsources $::analyse_tools::current_listsources

      set ra $::analyse_tools::ra
      set dec $::analyse_tools::dec
      set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
      set radius [::analyse_tools::get_radius $naxis1 $naxis2 $scale_x $scale_y]

      if {$::analyse_tools::use_tycho2} {
         set tycho2 [cstycho2 $::analyse_tools::catalog_tycho2 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $tycho2]\n"
         set tycho2 [::manage_source::set_common_fields $tycho2 TYCHO2 { RAdeg DEdeg 5 VT e_VT }]
         #::manage_source::imprim_3_sources $tycho2
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $tycho2 TYCHO2 30.0 -30.0 {} $log]
         set $::analyse_tools::nb_tycho2 [::manage_source::get_nb_sources_by_cata $listsources TYCHO2]
      }
      
      if {$::analyse_tools::use_ucac2} {
         set ucac2 [csucac2 $::analyse_tools::catalog_ucac2 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac2]\n"
         set ucac2 [::manage_source::set_common_fields $ucac2 UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
         #::manage_source::imprim_3_sources $ucac2
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ucac2 UCAC2 30.0 -30.0 {} $log]
         set $::analyse_tools::nb_ucac2 [::manage_source::get_nb_sources_by_cata $listsources UCAC2]
      }
      
      if {$::analyse_tools::use_ucac3} {
         set ucac3 [csucac3 $::analyse_tools::catalog_ucac3 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac3]\n"
         set ucac3 [::manage_source::set_common_fields $ucac3 UCAC3 { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
         #::manage_source::imprim_3_sources $ucac3
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ucac3 UCAC3 30.0 -30.0 {} $log]
         set $::analyse_tools::nb_ucac3 [::manage_source::get_nb_sources_by_cata $listsources UCAC3]
      }
      
      if {$::analyse_tools::use_skybot} {
         set dateobs     [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
         set exposure    [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set datejd  [ mc_date2jd $dateobs ]
         set datejd  [ expr $datejd + $exposure/86400.0/2.0 ]
         set dateiso [ mc_date2iso8601 $datejd ]
         set radius  [format "%0.0f" [expr $radius*60.0] ]
         set iau_code [lindex [::bddimages_liste::lget $tabkey IAU_CODE ] 1]

         gren_info "get_skybot $dateiso $ra $dec $radius $iau_code\n"
         set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} skybot ]
         gren_info "skybot = $skybot\n"

         gren_info "nb_skybot = [::manage_source::get_nb_sources_by_cata $skybot SKYBOT]\n"
         set listsources [ identification $listsources "OVNI" $skybot "SKYBOT" 30.0 -30.0 {} 1] 
         set ::analyse_tools::nb_skybot [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
         gren_info "nb_skybot ident = $::analyse_tools::nb_skybot\n"
         affich_rond $listsources SKYBOT $::analyse_tools::color_skybot  1
      }
      
      gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"

      # Creation de la VOTable en memoire
      set votable [::votableUtil::list2votable $listsources $tabkey]
      
      # Sauvegarde du cata XML
      #gren_info "Enregistrement du cata XML: $cataxml\n"
      set fxml [open $cataxml "w"]
      puts $fxml $votable
      close $fxml

      if {$::analyse_tools::create_cata} {
         set err [ catch { insertion_solo $cataxml } msg ]
         #gren_info "** INSERTION_SOLO = $err $msg\n"
      }



      return true
   }



















   proc ::analyse_tools::get_wcs {  } {

      global audace
      global bddconf


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

         set xcent [expr $naxis1/2.0]
         set ycent [expr $naxis2/2.0]
         #gren_info "xcent ycent = $xcent $ycent\n"

         #gren_info "****************************************************\n"
         #gren_info "** Calibration de l image\n"
         #gren_info "****************************************************\n"
         #gren_info "param : $ra $dec $pixsize1 $pixsize2 $foclen\n"
         #gren_info "catalog_usnoa2 : $::analyse_tools::catalog_usnoa2\n"
         #gren_info "DEBUT WCS ra dec : $ra  $dec \n"

         if {$::analyse_tools::log} {gren_info "PASS1: calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO  $::analyse_tools::catalog_usnoa2 -del_tmp_files 0\n"}
         set erreur [catch {set nbstars [calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $::analyse_tools::catalog_usnoa2 -del_tmp_files 0]} msg]
         if {$erreur} {
            #gren_info "1 ERR NBSTARS=$nbstars ($msg)"
            return -code 1 "ERR NBSTARS=$nbstars ($msg)"
            }

         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]
         if {$::analyse_tools::log} {gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"}

         if {$::analyse_tools::deuxpasses} {
         if {$::analyse_tools::log} {gren_info "PASS2: calibwcs $ra $dec * * * USNO  $::analyse_tools::catalog_usnoa2 -del_tmp_files 0\n"}
            set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 -del_tmp_files 0]} msg]
            if {$erreur} {
                  #gren_info "2 ERR NBSTARS=$nbstars ($msg)"
               return -code 2 "ERR NBSTARS=$nbstars ($msg)"
               }

            set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
            set ra  [lindex $a 0]
            set dec [lindex $a 1]
            if {$::analyse_tools::log} {gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"}
         }

         gren_info "nbstars/limit_nbstars_accepted  = $nbstars/$::analyse_tools::limit_nbstars_accepted \n"
         if { $::analyse_tools::keep_radec==1 && $nbstars<$::analyse_tools::limit_nbstars_accepted && [info exists ::analyse_tools::ra_save] && [info exists ::analyse_tools::dec_save] } {
            set ra  $::analyse_tools::ra_save
            set dec $::analyse_tools::dec_save
            if {$::analyse_tools::log} {gren_info "PASS3: calibwcs $ra $dec * * * USNO  $::analyse_tools::catalog_usnoa2 -del_tmp_files 0\n"}
            set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 -del_tmp_files 0]} msg]
            if {$erreur} {
#                  gren_info "3 ERR NBSTARS=$nbstars ($msg)"
               return -code 3 "ERR NBSTARS=$nbstars ($msg)"
               }
            set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
            set ra  [lindex $a 0]
            set dec [lindex $a 1]
#            gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"

            if {$::analyse_tools::deuxpasses} {
               if {$::analyse_tools::log} {gren_info "PASS4: calibwcs $ra $dec * * * USNO  $::analyse_tools::catalog_usnoa2 -del_tmp_files 0\n"}
               set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::analyse_tools::catalog_usnoa2 -del_tmp_files 0]} msg]
               if {$erreur} {
#                  gren_info "4 ERR NBSTARS=$nbstars ($msg)"
                  return -code 4 "ERR NBSTARS=$nbstars ($msg)"
                  }
               set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
               set ra  [lindex $a 0]
               set dec [lindex $a 1]
               gren_info "RETRY nbstars : $nbstars | ra : [mc_angle2hms $ra 360 zero 1 auto string] | dec : [mc_angle2dms $dec 90 zero 1 + string]\n"
            }
         }         

         set ::analyse_tools::nb_usnoa2 $nbstars
         set ::analyse_tools::current_listsources [get_ascii_txt]
         set ::analyse_tools::nb_img    [::manage_source::get_nb_sources_by_cata $::analyse_tools::current_listsources IMG   ]
         set ::analyse_tools::nb_ovni   [::manage_source::get_nb_sources_by_cata $::analyse_tools::current_listsources OVNI  ]
         set ::analyse_tools::nb_usnoa2 [::manage_source::get_nb_sources_by_cata $::analyse_tools::current_listsources USNOA2]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::analyse_tools::current_listsources]\n"

         if {$nbstars > $::analyse_tools::limit_nbstars_accepted} {
             set wcs_ok true
         }         
          
#   gren_info "Chargement de la liste des sources\n"
#   set listsources [get_ascii_txt]
#   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
 
         if {$wcs_ok} {
              #gren_info "WCS_OK $wcs_ok\n"

             set ::analyse_tools::ra_save $ra 
             set ::analyse_tools::dec_save $dec

             set ident [bddimages_image_identification $idbddimg]
             #gren_info "** ident = $ident $idbddimg\n"
             set fileimg  [lindex $ident 1]
             set filecata [lindex $ident 3]
             if {$fileimg == -1} {
                ::console::affiche_erreur "Fichier image inexistant ($idbddimg) \n"
                if {$erreur} {
                   #gren_info "5 Fichier image inexistant ($idbddimg) \n"
                   return -code 5 "Fichier image inexistant ($idbddimg) \n"
                   }
             }

             # Efface les cles PV1_0 et PV2_0 car pas bon
             if {$::analyse_tools::delpv} {
                set err [catch {buf$::audace(bufNo) delkwd PV1_0} msg]
                set err [catch {buf$::audace(bufNo) delkwd PV2_0} msg]
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


             # efface l image dans la base et le disque
             bddimages_image_delete_fromsql $ident
             bddimages_image_delete_fromdisk $ident

             gren_info "av idbddimg : $idbddimg \n"
             # insere l image et le cata dans la base filecata
             set errnum [catch {set r [insertion_solo $filefinal]} msg ]
             catch {gren_info "$errnum : $msg : $r"}
             if {$errnum==0} {
                set ::analyse_tools::current_image [::bddimages_liste::lupdate $::analyse_tools::current_image idbddimg $r]
             }
             
             set errnum [catch {file delete -force $filetmp} msg ]

             set errnum [catch {set list_keys [buf$::audace(bufNo) getkwds]} msg ]
             set tabkey {}
             foreach key $list_keys {
                set garde "ok"
                if {$key==""} {set garde "no"}
                foreach rekey $tabkey {
                   if {$key==$rekey} {set garde "no"}
                }
                if {$garde=="ok"} {
                   lappend tabkey [list $key [buf$::audace(bufNo) getkwd $key] ]
                }
             }

             set result  [bddimages_entete_preminforecon $tabkey]
             set err     [lindex $result 0]
             set $tabkey [lindex $result 1]
             set ::analyse_tools::current_image [::bddimages_liste::lupdate $::analyse_tools::current_image tabkey $tabkey]
             set idbddimg   [::bddimages_liste::lget $::analyse_tools::current_image "idbddimg"]
             gren_info "fin idbddimg : $idbddimg \n"

             return -code 0 "WCS OK"
         }
         
         return -code 10 "Sources non identifiees"
   }














   #
   # Calcul le rayon (arcmin) du FOV de l'image
   #
   proc ::analyse_tools::get_radius { naxis1 naxis2 scale_x scale_y } {

      #--- Coordonnees en pixels du centre de l'image
      set xc [ expr $naxis1/2.0 ]
      set yc [ expr $naxis2/2.0 ]

      #--- Calcul de la dimension du FOV: naxis*scale
      set taille_champ_x [expr abs($scale_x)*$naxis1*60.0]
      set taille_champ_y [expr abs($scale_y)*$naxis2*60.0]

      set radius [expr sqrt(pow($taille_champ_x,2) + pow($taille_champ_y,2)) ]
      return $radius

   }

# Fin Classe
}
