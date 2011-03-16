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

namespace eval bddimages_analyse {

   global audace
   global bddconf

   variable ssp_image





   proc ::bddimages_analyse::charge_cata { img_list } {

      global bddconf

      ::console::affiche_resultat "charge_cata\n"
      ::console::affiche_resultat "img_list $img_list\n"
      
      set id 1
      set catafile ""

         get_one_image $id 

         get_cata $catafile 
   }






   proc ::bddimages_analyse::creation_wcs { img_list } {

      global bddconf

      ::console::affiche_resultat "creation_wcs\n"
      ::console::affiche_resultat "img_list $img_list\n"

      set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
      set bufno 1
      set ext [buf$bufno extension]
      set gz [buf$bufno compress]
      if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

      foreach img $img_list {
        set ra          [::bddimages_imgcorrection::get_val_imglist ra $img]
        set dec         [::bddimages_imgcorrection::get_val_imglist dec $img]
        set pixsize1    [::bddimages_imgcorrection::get_val_imglist pixsize1 $img]
        set pixsize2    [::bddimages_imgcorrection::get_val_imglist pixsize2 $img]
        set foclen      [::bddimages_imgcorrection::get_val_imglist foclen $img]
        set filename    [::bddimages_imgcorrection::get_val_imglist filename $img]
        set dirfilename [::bddimages_imgcorrection::get_val_imglist dirfilename $img]

        ::console::affiche_resultat "ra $ra\n"
        ::console::affiche_resultat "dec $ra\n"
        ::console::affiche_resultat "pixsize1 $pixsize1\n"
        ::console::affiche_resultat "pixsize2 $pixsize2\n"
        ::console::affiche_resultat "foclen $foclen\n"
        ::console::affiche_resultat "filename $filename\n"
        ::console::affiche_resultat "dirfilename $dirfilename\n"

        set fc [file join $dirfilename $filename]
        ::console::affiche_resultat "filename $fc\n"
        # buf1 load $fc
        # buf1
        # set fileout [file tail $fc ]
        # buf1 save "$bddconf(dirtmp)/${fileout}${ext}"

        # calibwcs
        # RA DEC CRPIX1 CRPIX2 
        # calibwcs Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder

      }

   }
   




  
















proc get_cata { catafile } {


   global bddconf

   set test "ok"

   set filenametmpzip $bddconf(dirlog)/ssp_tmp_cata.txt.gz
   set filenametmp $bddconf(dirlog)/ssp_tmp_cata.txt

   if  {$test == "no"} { 
       # -- liste des sources tag = 1
       set err [catch {file delete -force $filenametmpzip} msg]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4a\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }
       set err [catch {file delete -force $filenametmp} msg]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4b\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }
       set err [catch {file copy -force $catafile $filenametmpzip} msg]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4c\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }
       set err [catch {exec chmod g-s $filenametmpzip} msg ]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4d\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }   
       set err [catch {exec gunzip $filenametmpzip} msg ]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4e\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }   
      }   

gren_info "fichier dezipp�\n"

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
       gren_info "solarsystemprocess: ERREUR 6  <$err>"
   }


# gren_info " ovni_list2 = $ovni_list2"
# return usno_list2 ?
 return [list $list_fields $list_sources]
 }













proc get_one_image { id } {

   # pour ne traiter qu'une seule image
   # par exemple : SSP_ID=176 ./solarsystemprocess --console --file ros.tcl
   gren_info "::::::::::DEBUG::::::: Looping with SSP_ID=$id"
   set sqlcmd    "SELECT catas.idbddcata,catas.filename,catas.dirfilename,"
   append sqlcmd " cataimage.idbddimg,images.idheader, "
   append sqlcmd " images.filename,images.dirfilename "
   append sqlcmd " FROM catas,cataimage,images "
   append sqlcmd " WHERE cataimage.idbddcata=catas.idbddcata "
   append sqlcmd " AND cataimage.idbddimg=images.idbddimg "
   append sqlcmd " AND cataimage.idbddimg='$id' "
   append sqlcmd " LIMIT 1 "

   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "ASTROID: ERREUR 2"
      gren_info "ASTROID: NUM : <$err>" 
      gren_info "ASTROID: MSG : <$msg>"
      }

   if {[llength $resultsql] <= 0} then { break }

   set idbddcata -1

   foreach line $resultsql {
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

   foreach n { idbddcata cata_filename dir_cata_file idbddimg idheader 
                fits_filename fits_dir header_tabname dateobs ra dec telescop 
                exposure filter } { set ::bddimages_analyse::ssp_image($n) [set $n] }

 }









# Fin Classe
}

