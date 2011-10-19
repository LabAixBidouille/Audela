#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_analyse.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_analyse.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6858 2011-03-06 14:19:15Z fredvachier $
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
         ::console::affiche_resultat "head     = [lindex $::bddimages_analyse::current_cata 0] \n"

      }

   }











   proc ::bddimages_analyse::creation_wcs { img_list } {

      global audace
      global bddconf

      #  source /data/install/develop/audela/gui/audace/surchaud.tcl
      set catalog "/data/astrodata/Catalog/USNOA2/"
      #set catalog "/home/t1m/astrodata/Catalog/USNOA2/"
      set catalog "/astrodata/USNOA2/"
      set catalog "/data/astrodata/Catalog/USNOA2/"

      # copie image courante dans rep temp en .fit -> bddimages_imgcorrection.tcl 
      set erreur [catch {::bddimages_imgcorrection::copy_to_tmp "IMG" $img_list} tmp_file_list]
      if {$erreur} {
         # popup
         return
      }

      foreach img $img_list {

         # Infos sur l'image a traiter
         set tabkey [::bddimages_liste::lget $img "tabkey"]

         set ra          [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set dec         [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
         set pixsize1    [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set pixsize2    [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set foclen      [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set filename    [::bddimages_liste::lget $img filename   ]
         set dirfilename [::bddimages_liste::lget $img dirfilename]
         set idbddimg    [::bddimages_liste::lget $img idbddimg]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]

         ::console::affiche_resultat "ra $ra\n"
         ::console::affiche_resultat "dec $dec\n"
         ::console::affiche_resultat "pixsize1 $pixsize1\n"
         ::console::affiche_resultat "pixsize2 $pixsize2\n"
         ::console::affiche_resultat "foclen $foclen\n"
         ::console::affiche_resultat "filename $filename\n"
         ::console::affiche_resultat "dirfilename $dirfilename\n"
         ::console::affiche_resultat "file $file\n"

         # Charge l'image
         buf$::audace(bufNo) load $file
         
         ::console::affiche_resultat "calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $catalog \n"
         
         set result [calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $catalog]
         if {$result < 3} {
            ::console::affiche_erreur "Echec d identification\n"
            ::console::affiche_erreur "CMD: calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $catalog\n"
            continue
         }
         if {$result == ""} {
            ::console::affiche_resultat "Echec d identification (verifier chemin catalogue)\n"
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

      }

   }
   
















proc get_cata { catafile } {

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













proc get_one_image { idbddimg } {

   # pour ne traiter qu'une seule image
   # par exemple : SSP_ID=176 ./solarsystemprocess --console --file ros.tcl
   gren_info "::::::::::DEBUG::::::: Looping with SSP_ID=$idbddimg"
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









# Fin Classe
}

