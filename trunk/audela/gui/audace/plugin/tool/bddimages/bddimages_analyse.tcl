#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_analyse.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_analyse.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : FrÃ©dÃ©ric Vachier
# Mise Ã  jour $Id: bddimages_analyse.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bddimages_analyse
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_analyse.cap
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

namespace eval bddimages_analyse {

   global audace
   global bddconf

   variable current_image
   variable current_cata
   variable fen
   variable stateback
   variable statenext
   variable current_appli


   variable color_button_good "green"
   variable color_button_bad  "red"
   variable color_button      
   variable bddimages_wcs 


   proc ::bddimages_analyse::charge_cata { img_list } {

      global bddconf

      ::console::affiche_resultat "charge_cata\n"
      ::console::affiche_resultat "img_list $img_list\n"
      
      set id 1
      set catafile ""

      set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
      set bufno 1
      set ext [buf$bufno extension]
      set gz [buf$bufno compress]
      if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

      foreach img $img_list {

         set idbddimg [::bddimages_liste::lget $img "idbddimg"]
         ::console::affiche_resultat "idbddimg $idbddimg\n"

         ::bddimages_analyse::get_one_image $idbddimg 
         
         ::console::affiche_resultat "idbddcata  = $::bddimages_analyse::current_image(idbddcata)\n"
         ::console::affiche_resultat "idbddimage = $::bddimages_analyse::current_image(idbddimg)\n"
         ::console::affiche_resultat "cata       = $::bddimages_analyse::current_image(dir_cata_file)/$::bddimages_analyse::current_image(cata_filename)\n"
         ::console::affiche_resultat "image      = $::bddimages_analyse::current_image(fits_filename)\n"
         ::console::affiche_resultat "idheader   = $::bddimages_analyse::current_image(idheader)\n"
         ::console::affiche_resultat "dateobs    = $::bddimages_analyse::current_image(dateobs)\n"
         ::console::affiche_resultat "ra         = $::bddimages_analyse::current_image(ra)\n"
         ::console::affiche_resultat "dec        = $::bddimages_analyse::current_image(dec)\n"
         ::console::affiche_resultat "telescop   = $::bddimages_analyse::current_image(telescop)\n"
         ::console::affiche_resultat "exposure   = $::bddimages_analyse::current_image(exposure)\n"
         ::console::affiche_resultat "filter     = $::bddimages_analyse::current_image(filter)\n"

         set catafile [file join $bddconf(dirbase) $::bddimages_analyse::current_image(dir_cata_file) $::bddimages_analyse::current_image(cata_filename)]
         set ::bddimages_analyse::current_cata [get_cata $catafile] 
         ::console::affiche_resultat "head       = [lindex $::bddimages_analyse::current_cata 0] \n"

      }

   }

   #--------------------------------------------------
   # ::bddimages_analyse::creation_wcs { }
   #--------------------------------------------------
   # Calibration astrometrique d'une image et creation des mots cles WCS.
   # Apres calibrarion, les images sont automatiquement re-inserees dans la bdd.
   # @param img_list liste des images a calibrer
   # @return void
   #--------------------------------------------------
   proc ::bddimages_analyse::creation_wcs_1_obsolete { img_list } {

      global audace
      global bddconf
      global caption

      # Repertoire du catalogue USNO-A2 utilise pour la calibration astrometrique
      set catalog $bddconf(usnocat)
      set catalog "/data/astrodata/Catalog/USNOA2/"
      #set catalog "/home/t1m/astrodata/Catalog/USNOA2/"
      set catalog "/astrodata/USNOA2/"
      set catalog "/astrodata/Catalog/USNOA2/"

      # Copie de l'image courante dans rep. temp en .fit -> bddimages_imgcorrection.tcl 
      set erreur [catch {::bddimages_imgcorrection::copy_to_tmp "IMG" $img_list} tmp_file_list]
      if {$erreur != 0} {
         tk_messageBox -title $caption(bddimages_analyse,error) -type ok -message $caption(bddimages_analyse,copytotmp)
         return
      }

      foreach img $img_list {

         # Infos sur l'image a traiter
         set tabkey [::bddimages_liste::lget $img "tabkey"]

         set dateobs     [lindex [::bddimages_liste::lget $tabkey date-obs   ] 1]
         set ra          [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set dec         [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
         set pixsize1    [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set pixsize2    [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set foclen      [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set filename    [::bddimages_liste::lget $img filename   ]
         set dirfilename [::bddimages_liste::lget $img dirfilename]
         set idbddimg    [::bddimages_liste::lget $img idbddimg]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]

#         ::console::affiche_resultat "date-obs $dateobs\n"
#         ::console::affiche_resultat "ra $ra\n"
#         ::console::affiche_resultat "dec $dec\n"
#         ::console::affiche_resultat "pixsize1 $pixsize1\n"
#         ::console::affiche_resultat "pixsize2 $pixsize2\n"
#         ::console::affiche_resultat "foclen $foclen\n"
#         ::console::affiche_resultat "filename $filename\n"
#         ::console::affiche_resultat "dirfilename $dirfilename\n"
#         ::console::affiche_resultat "file $file\n"
#         ::console::affiche_resultat "USNO-A2 $catalog\n"

         # Charge l'image
         buf$::audace(bufNo) load $file
         
         # Execute la calibration astrometrique
         set result [calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $catalog]
         if {$result < 3} {
            ::console::affiche_erreur "Echec d'identification: la calibration astrometrique a echouee\n"
            ::console::affiche_erreur "CMD: calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $catalog\n"
            continue
         }
         if {$result == ""} {
            ::console::affiche_resultat "Echec d'identification (verifier chemin catalogue)\n"
            continue
         }
         ::console::affiche_resultat "Nb sources USNOA2 identifiees : $result\n"

         set ident [bddimages_image_identification $idbddimg]
         set fileimg  [lindex $ident 1]
         set filecata [lindex $ident 3]
         if {$fileimg == -1} {
            ::console::affiche_erreur "Fichier image inexistant ($idbddimg) \n"
            continue
         }

         # Modifie le champs BDI
         set key [buf$::audace(bufNo) getkwd "BDDIMAGES WCS"]
         set key [lreplace $key 1 1 "Y"]
         buf$::audace(bufNo) setkwd $key

         set fichtmpunzip [unzipedfilename $fileimg]
         set filetmp      [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
         set filefinal    [file join $::bddconf(dirinco) [file tail $fileimg]]

         createdir_ifnot_exist $bddconf(dirtmp)

         # Sauve l'image
         buf$::audace(bufNo) save $filetmp
         set errnum [catch {exec gzip -c $filetmp > $filefinal} msg ]

         # Copie l image dans incoming, ainsi que le fichier cata si il existe
         if {$filecata != -1} {
            set errnum [catch {file rename -force -- $filecata $bddconf(dirinco)/.} msg ]
         }
  
         # Efface l image dans la base et le disque
         bddimages_image_delete_fromsql $ident
         bddimages_image_delete_fromdisk $ident

         # Insere l image et le cata dans la base
         insertion_solo $filefinal
         if {$filecata != -1} {
            set filecata [file join $bddconf(dirinco) [file tail $filecata]]
            insertion_solo $filecata
         }

         set errnum [catch {file delete -force $filetmp} msg ]

      }

   }
   
















proc get_cata_obsolete { catafile } {

   global bddconf


   set filenametmpzip $bddconf(dirtmp)/ssp_tmp_cata.txt.gz
   set filenametmp $bddconf(dirtmp)/ssp_tmp_cata.txt

       # -- liste des sources tag = 1
       set err [catch {file delete -force $filenametmpzip} msg]
       if {$err} {
          ::console::affiche_erreur "astroid: ERREUR 4a\n"
          ::console::affiche_erreur "astroid:        NUM : <$err>\n" 
          ::console::affiche_erreur "astroid:        MSG : <$msg>\n"
          }
       set err [catch {file delete -force $filenametmp} msg]
       if {$err} {
          ::console::affiche_erreur "astroid: ERREUR 4b\n"
          ::console::affiche_erreur "astroid:        NUM : <$err>\n" 
          ::console::affiche_erreur "astroid:        MSG : <$msg>\n"
          }
   ::console::affiche_resultat  "file copy -force $catafile $filenametmpzip\n"
       set err [catch {file copy -force $catafile $filenametmpzip} msg]
       if {$err} {
          ::console::affiche_erreur "astroid: ERREUR 4c\n"
          ::console::affiche_erreur "astroid:        NUM : <$err>\n" 
          ::console::affiche_erreur "astroid:        MSG : <$msg>\n"
          }
       set err [catch {exec chmod g-s $filenametmpzip} msg ]
       if {$err} {
          ::console::affiche_erreur "astroid: ERREUR 4d\n"
          ::console::affiche_erreur "astroid:        NUM : <$err>\n" 
          ::console::affiche_erreur "astroid:        MSG : <$msg>\n"
          }   
       set err [catch {exec gunzip $filenametmpzip} msg ]
       if {$err} {
          ::console::affiche_erreur "astroid: ERREUR 4e\n"
          ::console::affiche_erreur "astroid:        NUM : <$err>\n" 
          ::console::affiche_erreur "astroid:        MSG : <$msg>\n"
          }   

   ::console::affiche_resultat  "fichier dezippe\n"

   set linerech "123456789 123456789 123456789 123456789" 

#{ 
# { 
#  { IMG   {list field crossmatch} {list fields}} 
#  { TYC2  {list field crossmatch} {list fields}}
#  { USNO2 {list field crossmatch} {list fields}}
# }
# {                                -> liste des sources
#  {                               -> 1 source
#   { IMG   {crossmatch} {fields}}  -> vue dans l image
#   { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#   { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#  }
# }
#}

   set cmfields  [list ra dec poserr mag magerr]
   set allfields [list id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex]

   set list_fields [list [list "IMG" $cmfields $allfields] [list "USNO2" $cmfields {}]]


   set list_sources {}
   set chan [open $filenametmp r]
   set lineCount 0
   set littab "no"
   while {[gets $chan line] >= 0} {
       if {$littab=="ok"} {
         incr lineCount
         set zlist [split $line " "]
         set xlist {}
         foreach value $zlist {
            if {$value!={}} {
               set xlist [linsert $xlist end $value]
               }
            }
         set row {}
         set cmval [list [lindex $xlist 8] [lindex $xlist 9] 5.0 [lindex $xlist 10] [lindex $xlist 12] ] 
         if {[lindex $xlist 1]==1} {
            lappend row [list "IMG" $cmval $xlist ]
            lappend row [list "OVNI" $cmval {} ]
            }
         if {[lindex $xlist 1]==3} {
            lappend row [list "IMG" $cmval $xlist ]
            lappend row [list "USNOA2" $cmval {} ]
            }
         if {[llength $row] > 0} {
            lappend list_sources $row
            }
        
         #if {$lineCount > 215} {  return [list $list_fields $list_sources] }

         } else {
         set a [string first $linerech $line 0]
         if {$a>=0} { set littab "ok" }
         }
      }

   if {[catch {close $chan} err]} {
       ::console::affiche_resultat "astroid: ERREUR 6  <$err>"
   }


 return [list $list_fields $list_sources]
 }













proc get_one_image_obsolete { idbddimg } {

   # pour ne traiter qu'une seule image
   # par exemple : SSP_ID=176 ./solarsystemprocess --console --file ros.tcl
   #gren_info "::::::::::DEBUG::::::: Looping with SSP_ID=$idbddimg"
   set sqlcmd    "SELECT catas.idbddcata,catas.filename,catas.dirfilename,"
   append sqlcmd " cataimage.idbddimg,images.idheader, "
   append sqlcmd " images.filename,images.dirfilename "
   append sqlcmd " FROM catas,cataimage,images "
   append sqlcmd " WHERE cataimage.idbddcata=catas.idbddcata "
   append sqlcmd " AND cataimage.idbddimg=images.idbddimg "
   append sqlcmd " AND cataimage.idbddimg='$idbddimg' "
   append sqlcmd " LIMIT 1 "

   ::console::affiche_resultat "\n$sqlcmd = $sqlcmd\n"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_erreur "ASTROID: ERREUR 2\n"
      ::console::affiche_erreur "ASTROID: NUM : <$err>\n" 
      ::console::affiche_erreur "ASTROID: MSG : <$msg>\n"
      }

   if {[llength $resultsql] <= 0} then { break }

   set idbddcata -1

   foreach line $resultsql {
      ::console::affiche_resultat "\n\nline = $line\n"
      set idbddcata      [lindex $line 0]
      set cata_filename  [lindex $line 1]
      set dir_cata_file  [lindex $line 2]
      set idbddimg       [lindex $line 3]
      set idheader       [lindex $line 4]
      set fits_filename  [lindex $line 5]
      set fits_dir       [lindex $line 6]
      set header_tabname  "images_$idheader"
      }

   set sqlcmd    "select `date-obs`,`ra`,`dec`,`telescop`,`exposure`,`filter` from $header_tabname where idbddimg='$idbddimg'"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "ASTROID: ERREUR 3"
      gren_info "ASTROID: NUM : <$err>" 
      gren_info "ASTROID: MSG : <$msg>"
      }

   set line     [lindex $resultsql 0] 
   set dateobs  [lindex $line 0]
   set ra       [lindex $line 1]
   set dec      [lindex $line 2]
   set telescop [lindex $line 3]
   set exposure [lindex $line 4]
   set filter   [lindex $line 5]
   set radius   3

   foreach n { idbddcata cata_filename dir_cata_file idbddimg idheader 
                fits_filename fits_dir header_tabname dateobs ra dec telescop 
                exposure filter radius } { set ::bddimages_analyse::current_image($n) [set $n] }

 }














   #
   # av4l_acq::initToConf
   # Initialisation des variables de configuration
   #
   proc ::bddimages_analyse::inittoconf {  } {

      global bddconf, conf

      set ::analyse_tools::use_usnoa2  1
      set ::analyse_tools::use_ucac2   1
      set ::analyse_tools::use_ucac3   1
      set ::analyse_tools::use_nomad1  0
      set ::analyse_tools::use_tycho2  1

      if {! [info exists ::analyse_tools::catalog_usnoa2] } {
         set ::analyse_tools::catalog_usnoa2 $conf(astrometry,catfolder)
         if {[info exists conf(astrometry,catfolder,usnoa2)]} {
            set ::analyse_tools::catalog_usnoa2 $conf(astrometry,catfolder,usnoa2)
         } else {
            set ::analyse_tools::catalog_usnoa2 "/astrodata/Catalog/USNOA2/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_ucac2] } {
         if {[info exists conf(astrometry,catfolder,ucac2)]} {
            set ::analyse_tools::catalog_ucac2 $conf(astrometry,catfolder,ucac2)
         } else {
            set ::analyse_tools::catalog_ucac2 "/astrodata/Catalog/UCAC2/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_ucac3] } {
         if {[info exists conf(astrometry,catfolder,ucac3)]} {
            set ::analyse_tools::catalog_ucac3 $conf(astrometry,catfolder,ucac3)
         } else {
            set ::analyse_tools::catalog_ucac3 "/astrodata/Catalog/UCAC3/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_tycho2] } {
         if {[info exists conf(astrometry,catfolder,tycho2)]} {
            set ::analyse_tools::catalog_tycho2 $conf(astrometry,catfolder,tycho2)
         } else {
            set ::analyse_tools::catalog_tycho2 "/astrodata/Catalog/TYCHO-2/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_nomad1] } {
         if {[info exists conf(astrometry,catfolder,nomad1)]} {
            set ::analyse_tools::catalog_nomad1 $conf(astrometry,catfolder,nomad1)
         } else {
            set ::analyse_tools::catalog_nomad1 "/astrodata/Catalog/NOMAD1/"
         }
      }

      set ::analyse_tools::use_skybot      0
      set ::analyse_tools::keep_radec      1
      set ::analyse_tools::create_cata     1
      set ::analyse_tools::delpv           1
      set ::analyse_tools::boucle          0
      set ::analyse_tools::deuxpasses      1
      set ::analyse_tools::limit_nbstars_accepted      5
      set ::analyse_tools::log             0

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      #if { ! [ info exists $bddconf(catalog_ucac2) ] } { set ::analyse_tools::catalog_ucac2 "" }
   }


   proc ::bddimages_analyse::fermer { } {

      global conf
      global action_label

      set conf(astrometry,catfolder,usnoa2) $::analyse_tools::catalog_usnoa2 
      set conf(astrometry,catfolder,ucac2)  $::analyse_tools::catalog_ucac2  
      set conf(astrometry,catfolder,ucac3)  $::analyse_tools::catalog_ucac3  
      set conf(astrometry,catfolder,tycho2) $::analyse_tools::catalog_tycho2 
      set conf(astrometry,catfolder,nomad1) $::analyse_tools::catalog_nomad1 

      destroy $::bddimages_analyse::fen
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]

   }

   proc ::bddimages_analyse::setval { } {

      set ::analyse_tools::ra_save  $::analyse_tools::ra
      set ::analyse_tools::dec_save $::analyse_tools::dec

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect ==""} {
         gren_info "SET CENTER : $::analyse_tools::ra_save $::analyse_tools::dec_save\n"
         return
      }
      set xcent [format "%0.0f" [expr ([lindex $rect 0] + [lindex $rect 2])/2.]  ]   
      set ycent [format "%0.0f" [expr ([lindex $rect 1] + [lindex $rect 1])/2.]  ]   
      set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
      if {$err} {
         ::console::affiche_erreur "$err $msg\n"
         return
      }
      set ::analyse_tools::ra_save  [lindex $a 0]
      set ::analyse_tools::dec_save [lindex $a 1]
      gren_info "SET BOX : $::analyse_tools::ra_save $::analyse_tools::dec_save\n"
      
      

   }





   proc ::bddimages_analyse::next { } {

         if {$::analyse_tools::id_current_image < $::analyse_tools::nb_img_list} {
            incr ::analyse_tools::id_current_image
            ::bddimages_analyse::charge_current_image
         }
   }


   proc ::bddimages_analyse::back { } {

         if {$::analyse_tools::id_current_image > 1 } {
            incr ::analyse_tools::id_current_image -1
            ::bddimages_analyse::charge_current_image
         }
   }



   proc ::bddimages_analyse::charge_current_image { } {

      global audace
      global bddconf

         

         #ï¿½Charge l image en memoire
         #gren_info "cur id $::analyse_tools::id_current_image: \n"
         set ::analyse_tools::current_image [lindex $::analyse_tools::img_list [expr $::analyse_tools::id_current_image - 1] ]
         set tabkey      [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]

         set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]
         set ::analyse_tools::current_image_name $filename
         set ::analyse_tools::current_image_date $date
         set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
         set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set ::analyse_tools::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
         set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
         set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
         set xcent    [expr $naxis1/2.0]
         set ycent    [expr $naxis2/2.0]

         #gren_info "wcs : $date $::analyse_tools::bddimages_wcs\n"
         #gren_info "\n\nTABKEY = $tabkey\n\n\n"
         #gren_info "$::analyse_tools::id_current_image = date : $date  idbddimg : $idbddimg  file : $filename $::analyse_tools::bddimages_wcs\n"

         #ï¿½Charge l image a l ecran
         #gren_info "\n ** LOAD ** charge_current_image\n"
         buf$::audace(bufNo) load $file

         if { $::analyse_tools::boucle == 0 } {
            cleanmark
            #set cuts [buf$::audace(bufNo) autocuts]
            #gren_info "\n ** VISU ** charge_current_image\n"
            ::audace::autovisu $::audace(visuNo)
            #visu$::audace(visuNo) disp [list [lindex $cuts 0] [lindex $cuts 1] ]
         }
         
         #ï¿½Mise a jour GUI
         $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.back configure -state disabled
         $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.back configure -state disabled
         $::bddimages_analyse::current_appli.onglets.nb.f3.infoimage.nomimage    configure -text $::analyse_tools::current_image_name
         $::bddimages_analyse::current_appli.onglets.nb.f3.infoimage.stimage     configure -text "$::analyse_tools::id_current_image / $::analyse_tools::nb_img_list"

         if {$::analyse_tools::id_current_image == 1 && $::analyse_tools::nb_img_list > 1 } {
            $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.back configure -state disabled
         }
         if {$::analyse_tools::id_current_image == $::analyse_tools::nb_img_list && $::analyse_tools::nb_img_list > 1 } {
            $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.next configure -state disabled
         }
         if {$::analyse_tools::id_current_image > 1 } {
            $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.back configure -state normal
         }
         if {$::analyse_tools::id_current_image < $::analyse_tools::nb_img_list } {
            $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.next configure -state normal
         }
         if {$::analyse_tools::bddimages_wcs == "Y"} {
            set ::bddimages_analyse::color_button $::bddimages_analyse::color_button_good
            set ::bddimages_analyse::state_button normal
         } else {
            set ::bddimages_analyse::color_button $::bddimages_analyse::color_button_bad
            set ::bddimages_analyse::state_button normal
         }
         $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.go configure -bg $::bddimages_analyse::color_button -state $::bddimages_analyse::state_button
         affich_un_rond_xy $xcent $ycent red 2 2
 
   }










   proc ::bddimages_analyse::aladin { } {



         set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]

         set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]

         set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set ::analyse_tools::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
         set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
         set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
         set xcent    [expr $naxis1/2.0]
         set ycent    [expr $naxis2/2.0]
         set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
         set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
         set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
         set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
         set radius [::analyse_tools::get_radius $naxis1 $naxis2 $scale_x $scale_y]

         #envoie dans Aladin l image
         
         #envoi du CATA


   }













   proc ::bddimages_analyse::get_cata { } {

         if { $::analyse_tools::boucle ==1 } {
            ::bddimages_analyse::get_all_cata
         }  else {
            if {[::bddimages_analyse::get_one_wcs] == true} {
               if {[::analyse_tools::get_cata] == false} {
                  # TODO gerer l'erreur le  cata a echoué
                  return false
               }
            } else {
               # TODO gerer l'erreur le wcs a echoué
            }
         }

   }


   proc ::bddimages_analyse::get_wcs { } {

         if { $::analyse_tools::boucle ==1 } {
            ::bddimages_analyse::get_all_wcs
         }  else {
            ::bddimages_analyse::get_one_wcs
         }

   }


   proc ::bddimages_analyse::get_all_cata { } {

         
         while {1==1} {
            if { $::analyse_tools::boucle == 0 } {
               break
            }

            if {[::bddimages_analyse::get_one_wcs] == true} {
               if {[::analyse_tools::get_cata] == false} {
                  # TODO gerer l'erreur le  cata a echoué
                  break
               }
            } else {
               # TODO gerer l'erreur le wcs a echoué
               break
            }
            if {$::analyse_tools::id_current_image == $::analyse_tools::nb_img_list} { break }
            ::bddimages_analyse::next
         }

   }









   proc ::bddimages_analyse::get_all_wcs { } {
         
         while {1==1} {
            if { $::analyse_tools::boucle == 0 } {
               break
            }
            ::bddimages_analyse::get_one_wcs
            if {$::analyse_tools::id_current_image == $::analyse_tools::nb_img_list} { break }
            ::bddimages_analyse::next
         }

   }







   proc ::bddimages_analyse::get_one_wcs { } {

         set tabkey         [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
         set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs" ] 1] ]
         set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
         set idbddimg       [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         set filename       [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
         set dirfilename    [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
         #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs \n"

         set err [catch {::analyse_tools::get_wcs} msg]
         #gren_info "::analyse_tools::get_wcs $err $msg \n"
         
         if {$err == 0 } {
            set newimg [::bddimages_liste_gui::file_to_img $filename $dirfilename]
            
            set ::analyse_tools::img_list [lreplace $::analyse_tools::img_list [expr $::analyse_tools::id_current_image -1] [expr $::analyse_tools::id_current_image-1] $newimg]
            
            set idbddimg    [::bddimages_liste::lget $newimg idbddimg]
            set tabkey      [::bddimages_liste::lget $newimg "tabkey"]
            set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
            #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs  \n"

            set ::bddimages_analyse::color_button $::bddimages_analyse::color_button_good
            set ::bddimages_analyse::state_button normal
            $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.go configure -bg $::bddimages_analyse::color_button -state $::bddimages_analyse::state_button

            set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
            set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
            set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
            set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
            set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
            set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]

            #affich_rond $::analyse_tools::current_listsources IMG    $::analyse_tools::color_img     4

            if { $::analyse_tools::boucle == 1 } {
               cleanmark
               #gren_info "\n ** VISU ** get_one_wcs\n"
               ::audace::autovisu $::audace(visuNo)
               #visu$::audace(visuNo) disp
            }
            affich_rond $::analyse_tools::current_listsources USNOA2 $::analyse_tools::color_usnoa2  1
            
            #affich_rond $::analyse_tools::current_listsources OVNI   $::analyse_tools::color_ovni    2

            #::analyse_tools::nb_img   
            #::analyse_tools::nb_ovni  
            #::analyse_tools::nb_usnoa2

            return true

         } else {
            # "idbddimg : $idbddimg   filename : $filename wcs : erreur \n"
            ::console::affiche_erreur "GET_WCS ERROR: $msg  idbddimg : $idbddimg   filename : $filename\n"
            if { $::analyse_tools::boucle == 1 } {
               cleanmark
               #gren_info "\n ** VISU ** get_one_wcs\n"
               ::audace::autovisu $::audace(visuNo)
            set ::bddimages_analyse::color_button $::bddimages_analyse::color_button_bad
            set ::bddimages_analyse::state_button normal
            $::bddimages_analyse::current_appli.onglets.nb.f3.bouton.go configure -bg $::bddimages_analyse::color_button -state $::bddimages_analyse::state_button

            }
            return false
         }
   }


#   proc ::bddimages_analyse::get_one_cata { } {
#
#         set tabkey         [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
#         set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs" ] 1] ]
#         set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
#         set idbddimg       [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
#         set filename       [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
#         set dirfilename    [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
#         #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs \n"
#
#         set result [::analyse_tools::get_wcs]
#      
#         set err [::analyse_tools::get_cata $result]
#
#   }




   proc ::bddimages_analyse::charge_list { img_list } {

      global audace
      global bddconf

     catch {
         if { [ info exists $::analyse_tools::img_list ] }           {unset ::analyse_tools::img_list}
         if { [ info exists $::analyse_tools::nb_img_list ] }        {unset ::analyse_tools::nb_img_list}
         if { [ info exists $::analyse_tools::current_image ] }      {unset ::analyse_tools::current_image}
         if { [ info exists $::analyse_tools::current_image_name ] } {unset ::analyse_tools::current_image_name}
      }
      
      set ::analyse_tools::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::analyse_tools::nb_img_list [llength $::analyse_tools::img_list]
      #gren_info "nb images : $::analyse_tools::nb_img_list\n"

      foreach ::analyse_tools::current_image $::analyse_tools::img_list {
         set tabkey      [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         #gren_info "date : $date  idbddimg : $idbddimg\n"
      }

      # Chargement premiere image sans GUI
      #gren_info "* Premiere image :\n"
      set ::analyse_tools::id_current_image 1
      set ::analyse_tools::current_image [lindex $::analyse_tools::img_list 0]

      set tabkey      [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]

      set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
      set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
      set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
      set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
      set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
      set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
      set ::analyse_tools::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]
      set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
      set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
      set xcent    [expr $naxis1/2.0]
      set ycent    [expr $naxis2/2.0]

      set ::analyse_tools::current_image_name $filename
      set ::analyse_tools::current_image_date $date
      #gren_info "$::analyse_tools::id_current_image = date : $date  idbddimg : $idbddimg  file : $filename $::analyse_tools::bddimages_wcs\n"

      #ï¿½Charge l image a l ecran
      #gren_info "\n ** LOAD ** \n"
      buf$::audace(bufNo) load $file
      #gren_info "\n ** VISU ** premiere image\n"
      ::audace::autovisu $::audace(visuNo)
      #visu$::audace(visuNo) disp

      # Etat des boutons et GUI
      cleanmark
      set ::bddimages_analyse::stateback disabled
      if {$::analyse_tools::nb_img_list == 1} {
         set ::bddimages_analyse::statenext disabled
      } else {
         set ::bddimages_analyse::statenext normal
      }
      if {$::analyse_tools::bddimages_wcs == "Y"} {
         set ::bddimages_analyse::color_button $::bddimages_analyse::color_button_good
         set ::bddimages_analyse::state_button normal
      } else {
         set ::bddimages_analyse::color_button $::bddimages_analyse::color_button_bad
         set ::bddimages_analyse::state_button normal
      }
      set ::analyse_tools::nb_img     0
      set ::analyse_tools::nb_ovni    0
      set ::analyse_tools::nb_usnoa2  0
      set ::analyse_tools::nb_tycho2  0
      set ::analyse_tools::nb_ucac2   0
      set ::analyse_tools::nb_ucac3   0
      set ::analyse_tools::nb_nomad1  0
      affich_un_rond_xy $xcent $ycent red 2 2

   }









   proc ::bddimages_analyse::creation_wcs { img_list } {

      global audace
      global bddconf

      ::bddimages_analyse::charge_list $img_list
      ::bddimages_analyse::inittoconf
      
      #--- Creation de la fenetre
      set ::bddimages_analyse::fen .new
      if { [winfo exists $::bddimages_analyse::fen] } {
         wm withdraw $::bddimages_analyse::fen
         wm deiconify $::bddimages_analyse::fen
         focus $::bddimages_analyse::fen
         return
      }
      toplevel $::bddimages_analyse::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bddimages_analyse::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bddimages_analyse::fen ] "+" ] 2 ]
      wm geometry $::bddimages_analyse::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bddimages_analyse::fen 1 1
      wm title $::bddimages_analyse::fen "Creation du WCS"
      wm protocol $::bddimages_analyse::fen WM_DELETE_WINDOW "destroy $::bddimages_analyse::fen"

      set frm $::bddimages_analyse::fen.frm_creation_wcs
      set ::bddimages_analyse::current_appli $frm






      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::bddimages_analyse::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -text "Repertoire des catalogues"
        pack $frm.titre -in $frm -side top -padx 3 -pady 3

        #--- Cree un frame pour afficher ucac2
        set usnoa2 [frame $frm.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
        pack $usnoa2 -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $usnoa2.check -highlightthickness 0 -text "USNO-A2" \
                              -variable ::analyse_tools::use_usnoa2 -state disabled
             pack $usnoa2.check -in $usnoa2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $usnoa2.dir -relief sunken -textvariable ::analyse_tools::catalog_usnoa2
             pack $usnoa2.dir -in $usnoa2 -side right -pady 1 -anchor w
    
        #--- Cree un frame pour afficher delkwd PV
        set deuxpasses [frame $frm.deuxpasses -borderwidth 0 -cursor arrow -relief groove]
        pack $deuxpasses -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $deuxpasses.check -highlightthickness 0 -text "Faire 2 passes pour calibrer" -variable ::analyse_tools::deuxpasses
             pack $deuxpasses.check -in $deuxpasses -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher "utiliser les RA/DEC precedent
        set keepradec [frame $frm.keepradec -borderwidth 0 -cursor arrow -relief groove]
        pack $keepradec -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $keepradec.check -highlightthickness 0 -text "Utiliser RADEC precedent en cas d'echec" -variable ::analyse_tools::keep_radec
             pack $keepradec.check -in $keepradec -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher delkwd PV
        set delpv [frame $frm.delpv -borderwidth 0 -cursor arrow -relief groove]
        pack $delpv -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $delpv.check -highlightthickness 0 -text "Suppression des PV(1,2)_0" -variable ::analyse_tools::delpv
             pack $delpv.check -in $delpv -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher boucle
        set boucle [frame $frm.boucle -borderwidth 0 -cursor arrow -relief groove]
        pack $boucle -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $boucle.check -highlightthickness 0 -text "Analyse continue" -variable ::analyse_tools::boucle
             pack $boucle.check -in $boucle -side left -padx 5 -pady 0

        #--- Cree un frame pour afficher boucle
        set limit_nbstars [frame $frm.limit_nbstars -borderwidth 0 -cursor arrow -relief groove]
        pack $limit_nbstars -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $limit_nbstars.lab -text "limite acceptable du nb d'etoiles identifiees : " 
             pack $limit_nbstars.lab -in $limit_nbstars -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $limit_nbstars.val -relief sunken -textvariable ::analyse_tools::limit_nbstars_accepted
             pack $limit_nbstars.val -in $limit_nbstars -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set bouton [frame $frm.bouton -borderwidth 0 -cursor arrow -relief groove]
        pack $bouton -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $bouton.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::back" -state $::bddimages_analyse::stateback
             pack $bouton.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.next -text "Next" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::next" -state $::bddimages_analyse::statenext
             pack $bouton.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.go -text "Create WCS" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::get_wcs" \
                -bg $::bddimages_analyse::color_button -state $::bddimages_analyse::state_button
             pack $bouton.go -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un frame pour afficher info image
        set infoimage [frame $frm.infoimage -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimage -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- Cree un label pour le Nom de l image
            label $infoimage.nomimage -text $::analyse_tools::current_image_name
            pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

            #--- Cree un label pour la date de l image
            label $infoimage.dateimage -text $::analyse_tools::current_image_date
            pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3

            #--- Cree un label pour la date de l image
            label $infoimage.stimage -text "$::analyse_tools::id_current_image / $::analyse_tools::nb_img_list"
            pack $infoimage.stimage -in $infoimage -side top -padx 3 -pady 3

        #--- Cree un frame pour afficher les champs du header
        set keys [frame $frm.keys -borderwidth 0 -cursor arrow -relief groove]
        pack $keys -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- RA
            set ra [frame $keys.ra -borderwidth 0 -cursor arrow -relief groove]
            pack $ra -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $ra.name -text "RA : "
                pack $ra.name -in $ra -side left -padx 3 -pady 3
                entry $ra.val -relief sunken -textvariable ::analyse_tools::ra
                pack $ra.val -in $ra -side right -pady 1 -anchor w

            #--- DEC
            set dec [frame $keys.dec -borderwidth 0 -cursor arrow -relief groove]
            pack $dec -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $dec.name -text "DEC : "
                pack $dec.name -in $dec -side left -padx 3 -pady 3
                entry $dec.val -relief sunken -textvariable ::analyse_tools::dec
                pack $dec.val -in $dec -side right -pady 1 -anchor w

            #--- pixsize1
            set pixsize1 [frame $keys.pixsize1 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize1 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize1.name -text "PIXSIZE1 : "
                pack $pixsize1.name -in $pixsize1 -side left -padx 3 -pady 3
                entry $pixsize1.val -relief sunken -textvariable ::analyse_tools::pixsize1
                pack $pixsize1.val -in $pixsize1 -side right -pady 1 -anchor w

            #--- pixsize2
            set pixsize2 [frame $keys.pixsize2 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize2 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize2.name -text "PIXSIZE2 : "
                pack $pixsize2.name -in $pixsize2 -side left -padx 3 -pady 3
                entry $pixsize2.val -relief sunken -textvariable ::analyse_tools::pixsize2
                pack $pixsize2.val -in $pixsize2 -side right -pady 1 -anchor w

            #--- foclen
            set foclen [frame $keys.foclen -borderwidth 0 -cursor arrow -relief groove]
            pack $foclen -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $foclen.name -text "FOCLEN : "
                pack $foclen.name -in $foclen -side left -padx 3 -pady 3
                entry $foclen.val -relief sunken -textvariable ::analyse_tools::foclen
                pack $foclen.val -in $foclen -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set count [frame $frm.count -borderwidth 0 -cursor arrow -relief groove]
        pack $count -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un frame pour afficher boucle
           set img [frame $count.img -borderwidth 0 -cursor arrow -relief groove]
           pack $img -in $count -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $img.name -text "IMG : " -width 7
                pack $img.name -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.val -textvariable ::analyse_tools::nb_img
                pack $img.val -in $img -side left -padx 3 -pady 3
                button $img.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_img -command ""
                pack $img.color -side left -anchor e -expand 0 
                spinbox $img.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $img.radius -in $img -side left -anchor w

           #--- Cree un frame pour afficher boucle
           set usnoa2 [frame $count.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
           pack $usnoa2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $usnoa2.name -text "USNOA2 : " -width 7
                pack $usnoa2.name -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.val -textvariable ::analyse_tools::nb_usnoa2
                pack $usnoa2.val -in $usnoa2 -side left -padx 3 -pady 3
                button $usnoa2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_usnoa2 -command ""
                pack $usnoa2.color -side left -anchor e -expand 0 
                spinbox $usnoa2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $usnoa2.radius -in $usnoa2 -side left -anchor w

           #--- Cree un frame pour afficher boucle
           set ovni [frame $count.ovni -borderwidth 0 -cursor arrow -relief groove]
           pack $ovni -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label   $ovni.name   -text "OVNI : " -width 7
                pack    $ovni.name   -in $ovni -side left -padx 3 -pady 3 -anchor w  -fill x
                label   $ovni.val    -textvariable ::analyse_tools::nb_ovni
                pack    $ovni.val    -in $ovni -side left -padx 3 -pady 3
                button  $ovni.color  -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_ovni -command ""
                pack    $ovni.color  -side left -anchor e -expand 0 
                spinbox $ovni.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack    $ovni.radius -in $ovni -side left -anchor w


        #--- Cree un frame pour afficher boucle
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::fermer"
             pack $boutonpied.fermer -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.setval -text "Set Val" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::setval"
             pack $boutonpied.setval -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }
   
   




















   proc ::bddimages_analyse::creation_cata { img_list } {

      global audace
      global bddconf

      ::bddimages_analyse::charge_list $img_list
      ::bddimages_analyse::inittoconf
      

      #--- Creation de la fenetre
      set ::bddimages_analyse::fen .new
      if { [winfo exists $::bddimages_analyse::fen] } {
         wm withdraw $::bddimages_analyse::fen
         wm deiconify $::bddimages_analyse::fen
         focus $::bddimages_analyse::fen
         return
      }
      toplevel $::bddimages_analyse::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bddimages_analyse::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bddimages_analyse::fen ] "+" ] 2 ]
      wm geometry $::bddimages_analyse::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bddimages_analyse::fen 1 1
      wm title $::bddimages_analyse::fen "Creation du CATA"
      wm protocol $::bddimages_analyse::fen WM_DELETE_WINDOW "destroy $::bddimages_analyse::fen"

      set frm $::bddimages_analyse::fen.frm_creation_cata
      set ::bddimages_analyse::current_appli $frm




      

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::bddimages_analyse::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un label pour le titre
      label $frm.titre -text "Repertoire des catalogues"
      pack $frm.titre -in $frm -side top -padx 3 -pady 3


         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand 0 -fill x -padx 10 -pady 5
 

            pack [ttk::notebook $onglets.nb]
            set f1 [frame $onglets.nb.f1]
            set f2 [frame $onglets.nb.f2]
            set f3 [frame $onglets.nb.f3]
            set f4 [frame $onglets.nb.f4]
            
            $onglets.nb add $f1 -text "Catalogues"
            $onglets.nb add $f2 -text "Variables"
            $onglets.nb add $f3 -text "Actions"
            $onglets.nb add $f4 -text "Couleurs"
            $onglets.nb select $f3
            ttk::notebook::enableTraversal $onglets.nb







        #--- Cree un frame pour afficher ucac2
        set usnoa2 [frame $f1.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
        pack $usnoa2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $usnoa2.check -highlightthickness 0 -text "USNO-A2" \
                              -variable ::analyse_tools::use_usnoa2 -state disabled
             pack $usnoa2.check -in $usnoa2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $usnoa2.dir -relief sunken -textvariable ::analyse_tools::catalog_usnoa2 -width 30
             pack $usnoa2.dir -in $usnoa2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set tycho2 [frame $f1.tycho2 -borderwidth 0 -cursor arrow -relief groove]
        pack $tycho2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $tycho2.check -highlightthickness 0 -text "tycho2" -variable ::analyse_tools::use_tycho2
             pack $tycho2.check -in $tycho2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $tycho2.dir -relief sunken -textvariable ::analyse_tools::catalog_tycho2 -width 30
             pack $tycho2.dir -in $tycho2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set ucac2 [frame $f1.ucac2 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac2.check -highlightthickness 0 -text "ucac2" -variable ::analyse_tools::use_ucac2
             pack $ucac2.check -in $ucac2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac2.dir -relief sunken -textvariable ::analyse_tools::catalog_ucac2 -width 30
             pack $ucac2.dir -in $ucac2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac3
        set ucac3 [frame $f1.ucac3 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac3 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac3.check -highlightthickness 0 -text "ucac3" -variable ::analyse_tools::use_ucac3
             pack $ucac3.check -in $ucac3 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac3.dir -relief sunken -textvariable ::analyse_tools::catalog_ucac3 -width 30
             pack $ucac3.dir -in $ucac3 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher nomad1
        set nomad1 [frame $f1.nomad1 -borderwidth 0 -cursor arrow -relief groove]
        pack $nomad1 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $nomad1.check -highlightthickness 0 -text "nomad1" -variable ::analyse_tools::use_nomad1
             pack $nomad1.check -in $nomad1 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $nomad1.dir -relief sunken -textvariable ::analyse_tools::catalog_nomad1 -width 30
             pack $nomad1.dir -in $nomad1 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher delkwd PV
        set deuxpasses [frame $f2.deuxpasses -borderwidth 0 -cursor arrow -relief groove]
        pack $deuxpasses -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $deuxpasses.check -highlightthickness 0 -text "Faire 2 passes pour calibrer" -variable ::analyse_tools::deuxpasses
             pack $deuxpasses.check -in $deuxpasses -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher "utiliser les RA/DEC precedent
        set keepradec [frame $f2.keepradec -borderwidth 0 -cursor arrow -relief groove]
        pack $keepradec -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $keepradec.check -highlightthickness 0 -text "Utiliser RADEC precedent" -variable ::analyse_tools::keep_radec
             pack $keepradec.check -in $keepradec -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher delkwd PV
        set delpv [frame $f2.delpv -borderwidth 0 -cursor arrow -relief groove]
        pack $delpv -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $delpv.check -highlightthickness 0 -text "Suppression des PV(1,2)_0" -variable ::analyse_tools::delpv
             pack $delpv.check -in $delpv -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher creation du cata
        set create_cata [frame $f2.create_cata -borderwidth 0 -cursor arrow -relief groove]
        pack $create_cata -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $create_cata.check -highlightthickness 0 -text "Inserer le fichier CATA" -variable ::analyse_tools::create_cata
             pack $create_cata.check -in $create_cata -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher boucle
        set boucle [frame $f2.boucle -borderwidth 0 -cursor arrow -relief groove]
        pack $boucle -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $boucle.check -highlightthickness 0 -text "Analyse continue" -variable ::analyse_tools::boucle
             pack $boucle.check -in $boucle -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher boucle
        set skybot [frame $f2.skybot -borderwidth 0 -cursor arrow -relief groove]
        pack $skybot -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $skybot.check -highlightthickness 0 -text "Utiliser SkyBot" -variable ::analyse_tools::use_skybot
             pack $skybot.check -in $skybot -side left -padx 5 -pady 0
  

        #--- Cree un frame pour afficher boucle
        set limit_nbstars [frame $f2.limit_nbstars -borderwidth 0 -cursor arrow -relief groove]
        pack $limit_nbstars -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $limit_nbstars.lab -text "limite acceptable du nb d'etoiles identifiees : " 
             pack $limit_nbstars.lab -in $limit_nbstars -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $limit_nbstars.val -relief sunken -textvariable ::analyse_tools::limit_nbstars_accepted
             pack $limit_nbstars.val -in $limit_nbstars -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set log [frame $f2.log -borderwidth 0 -cursor arrow -relief groove]
        pack $log -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $log.check -highlightthickness 0 -text "Activation du log" -variable ::analyse_tools::log
             pack $log.check -in $log -side left -padx 5 -pady 0





        #--- Cree un frame pour afficher boutons
        set bouton [frame $f3.bouton -borderwidth 0 -cursor arrow -relief groove]
        pack $bouton -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $bouton.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::back" -state $::bddimages_analyse::stateback
             pack $bouton.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.next -text "Next" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::next" -state $::bddimages_analyse::statenext
             pack $bouton.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.go -text "Create CATA" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::get_cata" \
                -bg $::bddimages_analyse::color_button -state $::bddimages_analyse::state_button
             pack $bouton.go -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.aladin -text "Aladin" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::aladin" 
             pack $bouton.aladin -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un frame pour afficher info image
        set infoimage [frame $f3.infoimage -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimage -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- Cree un label pour le Nom de l image
            label $infoimage.nomimage -text $::analyse_tools::current_image_name
            pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

                entry $infoimage.dateimage -relief sunken -textvariable ::analyse_tools::current_image_date
                pack $infoimage.dateimage -in $infoimage -side right -pady 1 -anchor w

            #--- Cree un label pour la date de l image
            label $infoimage.stimage -text "$::analyse_tools::id_current_image / $::analyse_tools::nb_img_list"
            pack $infoimage.stimage -in $infoimage -side top -padx 3 -pady 3


        #--- Cree un frame pour afficher les champs du header
        set keys [frame $f3.keys -borderwidth 0 -cursor arrow -relief groove]
        pack $keys -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- RA
            set ra [frame $keys.ra -borderwidth 0 -cursor arrow -relief groove]
            pack $ra -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $ra.name -text "RA : "
                pack $ra.name -in $ra -side left -padx 3 -pady 3
                entry $ra.val -relief sunken -textvariable ::analyse_tools::ra
                pack $ra.val -in $ra -side right -pady 1 -anchor w

            #--- DEC
            set dec [frame $keys.dec -borderwidth 0 -cursor arrow -relief groove]
            pack $dec -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $dec.name -text "DEC : "
                pack $dec.name -in $dec -side left -padx 3 -pady 3
                entry $dec.val -relief sunken -textvariable ::analyse_tools::dec
                pack $dec.val -in $dec -side right -pady 1 -anchor w

            #--- pixsize1
            set pixsize1 [frame $keys.pixsize1 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize1 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize1.name -text "PIXSIZE1 : "
                pack $pixsize1.name -in $pixsize1 -side left -padx 3 -pady 3
                entry $pixsize1.val -relief sunken -textvariable ::analyse_tools::pixsize1
                pack $pixsize1.val -in $pixsize1 -side right -pady 1 -anchor w

            #--- pixsize2
            set pixsize2 [frame $keys.pixsize2 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize2 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize2.name -text "PIXSIZE2 : "
                pack $pixsize2.name -in $pixsize2 -side left -padx 3 -pady 3
                entry $pixsize2.val -relief sunken -textvariable ::analyse_tools::pixsize2
                pack $pixsize2.val -in $pixsize2 -side right -pady 1 -anchor w

            #--- foclen
            set foclen [frame $keys.foclen -borderwidth 0 -cursor arrow -relief groove]
            pack $foclen -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $foclen.name -text "FOCLEN : "
                pack $foclen.name -in $foclen -side left -padx 3 -pady 3
                entry $foclen.val -relief sunken -textvariable ::analyse_tools::foclen
                pack $foclen.val -in $foclen -side right -pady 1 -anchor w


        #--- Cree un frame pour afficher 
        set count [frame $f4.count -borderwidth 0 -cursor arrow -relief groove]
        pack $count -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un frame pour afficher 
           set img [frame $count.img -borderwidth 0 -cursor arrow -relief groove]
           pack $img -in $count -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $img.name -text "IMG : " -width 7
                pack $img.name -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.val -textvariable ::analyse_tools::nb_img
                pack $img.val -in $img -side left -padx 3 -pady 3
                button $img.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_img -command ""
                pack $img.color -side left -anchor e -expand 0 
                spinbox $img.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $img.radius -in $img -side left -anchor w

           #--- Cree un frame pour afficher USNOA2
           set usnoa2 [frame $count.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
           pack $usnoa2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $usnoa2.name -text "USNOA2 : " -width 7
                pack $usnoa2.name -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.val -textvariable ::analyse_tools::nb_usnoa2
                pack $usnoa2.val -in $usnoa2 -side left -padx 3 -pady 3
                button $usnoa2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_usnoa2 -command ""
                pack $usnoa2.color -side left -anchor e -expand 0 
                spinbox $usnoa2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $usnoa2.radius -in $usnoa2 -side left -anchor w

           #--- Cree un frame pour afficher OVNI
           set ovni [frame $count.ovni -borderwidth 0 -cursor arrow -relief groove]
           pack $ovni -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label   $ovni.name   -text "OVNI : " -width 7
                pack    $ovni.name   -in $ovni -side left -padx 3 -pady 3 -anchor w  -fill x
                label   $ovni.val    -textvariable ::analyse_tools::nb_ovni
                pack    $ovni.val    -in $ovni -side left -padx 3 -pady 3
                button  $ovni.color  -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_ovni -command ""
                pack    $ovni.color  -side left -anchor e -expand 0 
                spinbox $ovni.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack    $ovni.radius -in $ovni -side left -anchor w

           #--- Cree un frame pour afficher UCAC2
           set ucac2 [frame $count.ucac2 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $ucac2.name -text "UCAC2 : " -width 7
                pack $ucac2.name -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.val -textvariable ::analyse_tools::nb_ucac2
                pack $ucac2.val -in $ucac2 -side left -padx 3 -pady 3
                button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_ucac2 -command ""
                pack $ucac2.color -side left -anchor e -expand 0 
                spinbox $ucac2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $ucac2.radius -in $ucac2 -side left -anchor w

           #--- Cree un frame pour afficher UCAC3
           set ucac3 [frame $count.ucac3 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac3 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $ucac3.name -text "UCAC3 : " -width 7
                pack $ucac3.name -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.val -textvariable ::analyse_tools::nb_ucac3
                pack $ucac3.val -in $ucac3 -side left -padx 3 -pady 3
                button $ucac3.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_ucac3 -command ""
                pack $ucac3.color -side left -anchor e -expand 0 
                spinbox $ucac3.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $ucac3.radius -in $ucac3 -side left -anchor w

           #--- Cree un frame pour afficher TYCHO2
           set tycho2 [frame $count.tycho2 -borderwidth 0 -cursor arrow -relief groove]
           pack $tycho2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $tycho2.name -text "TYCHO2 : " -width 7
                pack $tycho2.name -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.val -textvariable ::analyse_tools::nb_tycho2
                pack $tycho2.val -in $tycho2 -side left -padx 3 -pady 3
                button $tycho2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_tycho2 -command ""
                pack $tycho2.color -side left -anchor e -expand 0 
                spinbox $tycho2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $tycho2.radius -in $tycho2 -side left -anchor w

           #--- Cree un frame pour afficher NOMAD1
           set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
           pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                label $nomad1.name -text "NOMAD1 : " -width 7
                pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.val -textvariable ::analyse_tools::nb_nomad1
                pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
                button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_nomad1 -command ""
                pack $nomad1.color -side left -anchor e -expand 0 
                spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 5
                pack  $nomad1.radius -in $nomad1 -side left -anchor w





        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::fermer"
             pack $boutonpied.fermer -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.setval -text "Set Val" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::setval"
             pack $boutonpied.setval -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


   }
   


# Fin Classe
}

