namespace eval tools_astrometry {

   variable science
   variable reference
   variable treshold
   variable delta
   variable ifortlib
   variable imagelimit


   proc ::tools_astrometry::init_priam { } {

      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

      set id_current_image 0
      foreach current_image $::tools_cata::img_list {
         incr id_current_image
         if {$id_current_image==1} {set tag "new"} else {set tag "add"}
         
         # LOG
         gren_info "init_priam : $id_current_image / $::tools_cata::nb_img_list \n"

         foreach s [lindex $::gui_cata::cata_list($id_current_image) 1] {
            set pos [lsearch -index 0 $s "ASTROID"]
            if {$pos != -1} {
               set a [lindex [lindex $s $pos] 2]
               set ar [lindex $a 25]
               set ac [lindex $a 27]
            }
         }

         ::priam::create_file_oldformat $tag $::tools_cata::nb_img_list current_image ::gui_cata::cata_list($id_current_image)
      }

   }





   proc ::tools_astrometry::go_priam {  } {


      set ::tools_astrometry::last_results_file [::priam::launch_priam]
      gren_info "new file : <$::tools_astrometry::last_results_file>\n"
      ::tools_astrometry::extract_priam_result $::tools_astrometry::last_results_file

   }







   proc ::tools_astrometry::create_vartab { } {
         
      if {[info exists ::tools_astrometry::tabval]}        {unset ::tools_astrometry::tabval}
      if {[info exists ::tools_astrometry::listref]}       {unset ::tools_astrometry::listref}
      if {[info exists ::tools_astrometry::listscience]}   {unset ::tools_astrometry::listscience}
      if {[info exists ::tools_astrometry::listdate]}      {unset ::tools_astrometry::listdate}

      set id_current_image 0

      foreach current_image $::tools_cata::img_list {

         incr id_current_image
         set current_listsources $::gui_cata::cata_list($id_current_image)
         set commundatejj [::bddimages_liste::lget $current_image "commundatejj"]
         set dateiso [ mc_date2iso8601 $commundatejj ]

         gren_info "-- IMG : $id_current_image / [llength $::tools_cata::img_list] :: "

         # REFERENCES

         set list_id_ref [::tools_cata::get_id_astrometric "R" current_listsources]

         foreach l $list_id_ref {

            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [string trim [lindex $l 4]]

            if {$name == ""} {
               gren_info "Lect Ref = $id $idcata $ar $ac $name\n"
            }
            #gren_info "Lect Ref = $id $idcata $ar $ac $name\n"

            #set a [lindex [lindex $current_listsources 1] $id]
            #gren_info "ASTROM UNSET $a\n"
            
            set s       [lindex [lindex $current_listsources 1] $id]
            set astroid [lindex $s $idcata]
            set b       [lindex $astroid 2]
            #gren_info "b = $b\n"

            set ra      [lindex $b 16]
            set dec     [lindex $b 17]
            set res_ra  [format  "%.4f" [lindex $b 18]]
            set res_dec [format  "%.4f" [lindex $b 19]]
            set rho     [format  "%.4f" [expr sqrt((pow($res_ra,2)+pow($res_dec,2))/2.)]]
            set omc_ra  [lindex $b 20]
            set omc_dec [lindex $b 21]
            set mag     [lindex $b 22]
            set err_mag [lindex $b 23]
            #gren_info "rho = $rho :: $res_ra $res_dec \n"
            gren_info "->vartab($name,$dateiso) ($ar $ra $dec $res_ra $res_dec $mag)\n"
            set ::tools_astrometry::tabval($name,$dateiso) [list [expr $id + 1] field $ar $rho $res_ra $res_dec $ra $dec $mag $err_mag]

            lappend ::tools_astrometry::listref($name)     $dateiso
            lappend ::tools_astrometry::listdate($dateiso) $name
            set ::tools_astrometry::date_to_id($dateiso) $id_current_image
            
         }

         # SCIENCES

         set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]
         foreach l $list_id_science {

            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]

            if {$name == ""} {
               gren_info "Lect Science = $id $idcata $ar $ac $name\n"
            }
            #gren_info "Lect Science = $id $idcata $ar $ac $name\n"
            
            set s       [lindex [lindex $current_listsources 1] $id]
            set astroid [lindex $s $idcata]
            set b       [lindex $astroid 2]
            #gren_info "b = $b\n"

            set ra      [lindex $b 16]
            set dec     [lindex $b 17]
            set res_ra  [format  "%.4f" [lindex $b 18] ]
            set res_dec [format  "%.4f" [lindex $b 19] ]
            set rho     [format  "%.4f" [expr sqrt((pow($res_ra,2)+pow($res_dec,2))/2.)]]
            set omc_ra  [lindex $b 20]
            set omc_dec [lindex $b 21]
            set mag     [lindex $b 22]
            set err_mag [lindex $b 23]
            #gren_info "Rho = $rho :: $res_ra $res_dec \n"
            #gren_info "->vartab($name,$dateiso) ($ar $ra $dec $res_ra $res_dec $ecart $mag)\n"

            set ::tools_astrometry::tabval($name,$dateiso) [list [expr $id + 1] field $ar $rho $res_ra $res_dec $ra $dec $mag $err_mag]

            lappend ::tools_astrometry::listscience($name) $dateiso
            lappend ::tools_astrometry::listdate($dateiso) $name
         }
         
         gren_info "date = $dateiso "
         gren_info "nb science = [llength $list_id_science] "
         gren_info "nb ref = [llength $list_id_ref] \n"


      }
   
   }







#0  nb            : nb d element 
#1  mrho          : moyenne sur rho =  rayon des residu
#2  stdev_rho     : stdev sur rho
#3  mra           : moyenne sur residu alpha
#4  mrd           : moyenne sur residu delta
#5  sra           : stdev sur residu alpha
#6  srd           : stdev sur residu delta
#7  ma            : moyenne sur alpha
#8  md            : moyenne sur delta
#9  sa            : stdev sur alpha
#10 sd            : stdev sur delta
#11 mm            : moyenne sur la magnitude
#12 sm            : stdev sur la magnitude

   proc ::tools_astrometry::calcul_statistique { } {
   
 
      package require math::statistics
   
      if {[info exists ::tools_astrometry::tabdate]}       {unset ::tools_astrometry::tabdate}
      if {[info exists ::tools_astrometry::tabref]}        {unset ::tools_astrometry::tabref}
      if {[info exists ::tools_astrometry::tabscience]}    {unset ::tools_astrometry::tabscience}

      #
      # STAT sur la liste des references
      #
      set cpt 0
      foreach name [array names ::tools_astrometry::listref] {
         
         incr cpt 
         
         set rho ""
         set a   ""
         set d   ""
         set ra  ""
         set rd  ""
         set m   ""

         foreach date $::tools_astrometry::listref($name) {
            lappend rho [lindex $::tools_astrometry::tabval($name,$date) 3]
            lappend ra  [lindex $::tools_astrometry::tabval($name,$date) 4]
            lappend rd  [lindex $::tools_astrometry::tabval($name,$date) 5]
            lappend a   [lindex $::tools_astrometry::tabval($name,$date) 6]
            lappend d   [lindex $::tools_astrometry::tabval($name,$date) 7]
            lappend m   [lindex $::tools_astrometry::tabval($name,$date) 8]
         }

         set nb   [llength $::tools_astrometry::listref($name)]
         set mrho [format "%.3f" [::math::statistics::mean  $rho]]
         set mra  [format "%.3f" [::math::statistics::mean  $ra ]]
         set mrd  [format "%.3f" [::math::statistics::mean  $rd ]]
         set ma   [format "%.6f" [::math::statistics::mean  $a  ]]
         set md   [format "%.5f" [::math::statistics::mean  $d  ]]
         set mm   [format "%.3f" [::math::statistics::mean  $m  ]]
         if {$nb>1} {
            set srho [format "%.3f" [::math::statistics::stdev $rho]]
            set sra  [format "%.3f" [::math::statistics::stdev $ra ]]
            set srd  [format "%.3f" [::math::statistics::stdev $rd ]]
            set sa   [format "%.3f" [::math::statistics::stdev $a  ]]
            set sd   [format "%.3f" [::math::statistics::stdev $d  ]]
            set sm   [format "%.3f" [::math::statistics::stdev $m  ]]
         } else {
            set srho 0
            set sra  0
            set srd  0
            set sa   0
            set sd   0
            set sm   0
         }

         set ::tools_astrometry::tabref($name) [list $name $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm]
      }
   
      #
      # STAT sur la liste des sciences
#

      foreach name [array names ::tools_astrometry::listscience] {

         set rho ""
         set a ""
         set d ""
         set ra ""
         set rd ""
         set m ""

         foreach date $::tools_astrometry::listscience($name) {
            lappend rho [lindex $::tools_astrometry::tabval($name,$date) 3]
            lappend ra  [lindex $::tools_astrometry::tabval($name,$date) 4]
            lappend rd  [lindex $::tools_astrometry::tabval($name,$date) 5]
            lappend a   [lindex $::tools_astrometry::tabval($name,$date) 6]
            lappend d   [lindex $::tools_astrometry::tabval($name,$date) 7]
            lappend m   [lindex $::tools_astrometry::tabval($name,$date) 8]
         }
         
         set nb   [llength $::tools_astrometry::listscience($name)]
         set mrho [format "%.3f" [::math::statistics::mean  $rho]]
         set mra  [format "%.3f" [::math::statistics::mean  $ra ]]
         set mrd  [format "%.3f" [::math::statistics::mean  $rd ]]
         set ma   [format "%.6f" [::math::statistics::mean  $a  ]]
         set md   [format "%.5f" [::math::statistics::mean  $d  ]]
         set mm   [format "%.3f" [::math::statistics::mean  $m  ]]
         if {$nb>1} {
            set srho [format "%.3f" [::math::statistics::stdev $rho]]
            set sra  [format "%.3f" [::math::statistics::stdev $ra ]]
            set srd  [format "%.3f" [::math::statistics::stdev $rd ]]
            set sa   [format "%.3f" [::math::statistics::stdev $a  ]]
            set sd   [format "%.3f" [::math::statistics::stdev $d  ]]
            set sm   [format "%.3f" [::math::statistics::stdev $m  ]]
         } else {
            set srho 0
            set sra  0
            set srd  0
            set sa   0
            set sd   0
            set sm   0
         }

         set ::tools_astrometry::tabscience($name) [list $name $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm]
      }
      
# STAT sur la liste des dates


      foreach date [array names ::tools_astrometry::listdate] {

         set rho ""
         set a ""
         set d ""
         set ra ""
         set rd ""
         set m ""

         set nb 0
         foreach name $::tools_astrometry::listdate($date) {
            if {[lindex $::tools_astrometry::tabval($name,$date) 0]=="S"} { continue }
            incr nb
            lappend rho [lindex $::tools_astrometry::tabval($name,$date) 3]
            lappend ra  [lindex $::tools_astrometry::tabval($name,$date) 4]
            lappend rd  [lindex $::tools_astrometry::tabval($name,$date) 5]
            lappend a   [lindex $::tools_astrometry::tabval($name,$date) 6]
            lappend d   [lindex $::tools_astrometry::tabval($name,$date) 7]
            lappend m   [lindex $::tools_astrometry::tabval($name,$date) 8]
         }

         set mrho [format "%.3f" [::math::statistics::mean  $rho]]
         set mra  [format "%.3f" [::math::statistics::mean  $ra ]]
         set mrd  [format "%.3f" [::math::statistics::mean  $rd ]]
         set ma   [format "%.6f" [::math::statistics::mean  $a  ]]
         set md   [format "%.5f" [::math::statistics::mean  $d  ]]
         set mm   [format "%.3f" [::math::statistics::mean  $m  ]]
         if {$nb>1} {
            set srho [format "%.3f" [::math::statistics::stdev $rho]]
            set sra  [format "%.3f" [::math::statistics::stdev $ra ]]
            set srd  [format "%.3f" [::math::statistics::stdev $rd ]]
            set sa   [format "%.3f" [::math::statistics::stdev $a  ]]
            set sd   [format "%.3f" [::math::statistics::stdev $d  ]]
            set sm   [format "%.3f" [::math::statistics::stdev $m  ]]
         } else {
            set srho 0
            set sra  0
            set srd  0
            set sa   0
            set sd   0
            set sm   0
         }

         set ::tools_astrometry::tabdate($date) [list $date $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm]
      }
      
   }








   proc ::tools_astrometry::affich_catalist {  } {

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::create_vartab  
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Creation de la structure de variable in $tt sec \n"
      
      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::calcul_statistique  
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Calculs statistiques in $tt sec \n"

      return

   }





   proc ::tools_astrometry::set_fields_astrom { send_astrom } {
   
      upvar $send_astrom astrom
      
      set astrom(kwds)     {RA       DEC       CRPIX1      CRPIX2      CRVAL1       CRVAL2       CDELT1      CDELT2      CROTA2      CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN       PIXSIZE1       PIXSIZE2        CATA_PVALUE        EQUINOX       CTYPE1        CTYPE2      LONPOLE                                        CUNIT1                       CUNIT2                       }
      set astrom(units)    {deg      deg       pixel       pixel       deg          deg          deg/pixel   deg/pixel   deg         deg/pixel     deg/pixel     deg/pixel     deg/pixel     m            um             um              percent            no            no            no          deg                                            no                           no                           }
      set astrom(types)    {double   double    double      double      double       double       double      double      double      double        double        double        double        double       double         double          double             string        string        string      double                                         string                       string                       }
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included" "Pvalue of astrometric reduction" "System of equatorial coordinates" "Gnomonic projection" "Gnomonic projection" "Long. of the celest.NP in native coor.syst."  "Angles are degrees always"  "Angles are degrees always"  }
      return
   }








 # Extraction des resultats de Priam

  
   proc ::tools_astrometry::extract_priam_result { file } {
   
      #gren_info "extract_priam_result:  file : <$file>\n"
   
      set chan [open $file r]
      
      ::tools_astrometry::set_fields_astrom astrom
      set n [llength $astrom(kwds)]

      set id_current_image 0
      set nberr 0

      # Lecture du fichier en continue

      while {[gets $chan line] >= 0} {

         set a [split $line "="]
         set key [lindex $a 0]
         set val [lindex $a 1]
         #gren_info "$key=$val\n"

         if {$key=="BEGIN"} {
            # Debut image
            set filename $val
            incr id_current_image
            set catascience($id_current_image) ""
            set cataref($id_current_image) ""
            set ::tools_cata::new_astrometry($id_current_image) ""
            
            gets $chan success

            if {$success!="SUCCESS"} {
               incr nberr
               gren_info "ASTROMETRY FAILED : $file\n"
               continue
            }

         }

         if {$key=="END"} {
         }

         for {set k 0 } { $k<$n } {incr k} {
            set kwd [lindex $astrom(kwds) $k]
            if {$kwd==$key} {
               set type [lindex $astrom(types) $k]
               set unit [lindex $astrom(units) $k]
               set comment [lindex $astrom(comments) $k]
               # gren_info "KWD: $key \n"
               # buf$::audace(bufNo) setkwd [list $kwd $val $type $unit $comment]
               
               # TODO Modif du tabkey de chaque image de img_list
               foreach kk [list FOCLEN RA DEC CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA2 CD1_1 CD1_2 CD2_1 CD2_2 ] {
                  if {$kk == $key } {
                     set val [format "%.10f" $val]
                  }
               }
               foreach kk [list CRPIX1 CRPIX2] {
                  if {$kk == $key } {
                     set val [format "%.3f" $val]
                  }
               }
               lappend ::tools_cata::new_astrometry($id_current_image) [list $kwd $val $type $unit $comment]
               
            }
         }

         if {$key=="CATA_VALUES"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            lappend catascience($id_current_image) [list $name $sour]
         }
         if {$key=="CATA_REF"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            lappend cataref($id_current_image) [list $name $sour]
         }

      }
      close $chan
      
      if {$id_current_image == $nberr } {
         return -code 1 "ASTROMETRY FAILURE"
      }


      #gren_info "NB IMG EXTRACTED FROM PRIAM RESULTS: [expr $id_current_image +1 ] \n"
      #gren_info "NB IMG LIST: [llength $::tools_cata::img_list] \n"

   # sur une seule image -> current_listsources

      #gren_info "[::manage_source::get_fields_from_sources $current_listsources] \n"

   # A FAIRE  : nettoyage des astrometrie de current_listsources

   #   ::tools_astrometry::clean_astrom 

   # Insertion des resultats dans current_listsources

      set fieldsastroid [::analyse_source::get_fieldastroid]

#      set fieldsastroid [list "ASTROID" {} [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" \
#                                           "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" \
#                                           "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" \
#                                           "name" "flagastrom" "flagphotom" "cataastrom" "cataphotom"] ]

      set id_current_image 0

      foreach current_image $::tools_cata::img_list {

         incr id_current_image
         
         set ex [::bddimages_liste::lexist $current_image "listsources"]
         if {$ex != 0} {
            ::console::affiche_erreur "Attention listsources existe dans img_list et ce n est plus necessaire\n"
         } 
         
         set current_listsources $::gui_cata::cata_list($id_current_image)
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $current_listsources]\n"

         #gren_info "LISTSOURCES: ($current_listsources) \n"
         set n [llength $catascience($id_current_image)]
         #gren_info "NB SCIENCE: ($n) \n"

         set fields [lindex $current_listsources 0]
         set sources [lindex $current_listsources 1]
         
         set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]
         
         #gren_info "list_id_science = $list_id_science\n"

         foreach l $list_id_science {
            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]
            #gren_info "Lect = $id $idcata $ar $ac $name\n"
            #gren_info "catascience = $catascience($id_current_image)\n"


            set x  [lsearch -index 0 $catascience($id_current_image) $name]
            if {$x>=0} {
               set data [lindex [lindex $catascience($id_current_image) $x] 1]
               set ra      [lindex $data 0]
               set dec     [lindex $data 1]
               set res_ra  [lindex $data 2]
               set res_dec [lindex $data 3]
               #gren_info "$id $name Residus $res_ra $res_dec \n"
               set s [lindex $sources $id]
               
               set omc_ra  "-"
               set omc_dec "-"
               set x [lsearch -index 0 $s $ac]
               if {$x>=0} {
                  set cata [lindex $s $x]
                  set omc_ra  [expr ($ra  - [lindex [lindex $cata 1] 0])*3600.0]
                  set omc_dec [expr ($dec - [lindex [lindex $cata 1] 1])*3600.0]
               }
               
               set astroid [lindex $s $idcata]
               #gren_info "astroid = $astroid\n"
               set b [lindex $astroid 2]
               set b [lreplace $b 16 21 $ra $dec $res_ra $res_dec $omc_ra $omc_dec]
               set astroid [lreplace $astroid 2 2 $b]
               #gren_info "astroid = $astroid\n"
               set s [lreplace $s $idcata $idcata $astroid]
               set sources [lreplace $sources $id $id $s]
            }
         }

         set list_id_ref [::tools_cata::get_id_astrometric "R" current_listsources]
         
         #gren_info "list_id_ref = $list_id_ref\n"

         foreach l $list_id_ref {
            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]
            #gren_info "Lect = $id $idcata $ar $ac $name\n"
            #gren_info "cataref = $cataref($id_current_image)\n"

            set x  [lsearch -index 0 $cataref($id_current_image) $name]
            if {$x>=0} {
               set data [lindex [lindex $cataref($id_current_image) $x] 1]
               set res_ra  [lindex $data 0]
               set res_dec [lindex $data 1]

               #gren_info "$id $name Residus $res_ra $res_dec \n"

               set s [lindex $sources $id]

               set ra  "-"
               set dec "-"
               set x [lsearch -index 0 $s $ac]
               if {$x>=0} {
                  set cata [lindex $s $x]
                  set ra  [lindex [lindex $cata 1] 0]
                  set dec [lindex [lindex $cata 1] 1]
               }
               
               set astroid [lindex $s $idcata]
               #gren_info "astroid = $astroid\n"
               set b [lindex $astroid 2]
               set b [lreplace $b 16 19 $ra $dec $res_ra $res_dec]
               set astroid [lreplace $astroid 2 2 $b]
               #gren_info "astroid = $astroid\n"
               set s [lreplace $s $idcata $idcata $astroid]
               set sources [lreplace $sources $id $id $s]
            }
         }
 
         set ::gui_cata::cata_list($id_current_image) [list $fields $sources]

      }


   #gren_info "SRol=[ ::manage_source::get_nb_sources_rollup $current_listsources]\n"
   #gren_info "ASTROIDS=[::manage_source::extract_sources_by_catalog $current_listsources ASTROID]\n"
   #gren_info "LISTSOURCES=$current_listsources\n"

   # Ecriture des resultats dans un fichier 


   }













   
# ASTROID --   
# "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name"
# "flagastrom" "flagphotom" "cataastrom" "cataphotom" 

   proc ::tools_astrometry::set_astrom_to_source { s ra dec res_ra res_dec omc_ra omc_dec name} {
   
      set pass "no"
      
      set stmp {}
      foreach cata $s {
         if {[lindex $cata 0] == "ASTROID"} {
            set pass "yes"
            set astroid [lindex $cata 2]
            set astroid [lreplace $astroid 16 21 $ra $dec $res_ra $res_dec $omc_ra $omc_dec]
            set astroid [lreplace $astroid 24 24 $name]
            
            lappend stmp [list "ASTROID" {} $astroid]
         } else {
            lappend stmp $cata
         }
      }
      return $stmp
   }
   
   
   
   
   
   
   
   
   
   
   
   





# ASTROID --   
# "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name"
# "flagastrom" "flagphotom" "cataastrom" "cataphotom" 

   proc ::tools_astrometry::save { form } {

      global bddconf audace
  
      gren_info "FORMAT:$form\n"
      
      # Fichier au format TXT 
      
      if {$form=="TXT"} {

         if {[info exists tag]} {unset tag}
         set id_current_image 0
         foreach current_image $::tools_cata::img_list {

            set idbddimg [::bddimages_liste::lget $current_image "idbddimg"]
            set commundatejj [::bddimages_liste::lget $current_image "commundatejj"]
            set current_listsources [::bddimages_liste::lget $current_image "listsources"]
            set tabkey [::bddimages_liste::lget $current_image "tabkey"]
            set pvalue [string trim [lindex [::bddimages_liste::lget $tabkey "CATA_PVALUE"] 1] ]
            set pvalue 0

            foreach s [lindex $current_listsources 1] {
               foreach cata $s {

                  if {[lindex $cata 0] == "ASTROID"} {
                     set astroid [lindex $cata 2]

# ASTROID --   
# "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name"
# "flagastrom" "flagphotom" "cataastrom" "cataphotom" 

                     set xsm         [lindex $astroid  0]
                     set ysm         [lindex $astroid  1]
                     set err_xsm     [lindex $astroid  2]
                     set err_ysm     [lindex $astroid  3]
                     set fwhmx       [lindex $astroid  4]
                     set fwhmy       [lindex $astroid  5]
                     set fwhm        [lindex $astroid  6]
                     set fluxintegre [lindex $astroid  7]
                     set errflux     [lindex $astroid  8]
                     set pixmax      [lindex $astroid  9]
                     set intensite   [lindex $astroid 10]
                     set sigmafond   [lindex $astroid 11]
                     set snint       [lindex $astroid 12]
                     set snpx        [lindex $astroid 13]
                     set delta       [lindex $astroid 14]
                     set rdiff       [lindex $astroid 15]
                     set ra          [lindex $astroid 16]
                     set dec         [lindex $astroid 17]
                     set res_ra      [lindex $astroid 18]
                     set res_dec     [lindex $astroid 19]
                     set omc_ra      [lindex $astroid 20]
                     set omc_dec     [lindex $astroid 21]
                     set mag         [lindex $astroid 22]
                     set err_mag     [lindex $astroid 23]
                     set name        [lindex $astroid 24]
                     set flagastrom  [lindex $astroid 25]
                     set flagphotom  [lindex $astroid 26]
                     set cataastrom  [lindex $astroid 27]
                     set cataphotom  [lindex $astroid 28]

                     if {$flagastrom!="S"&&$flagastrom!="R"} {break}
                     gren_info "$idbddimg name:$name $ra $dec\n"
                     set fileres "PRIAM_$name.csv"
                     set fileres [ file join $audace(rep_travail) $fileres ]
                     if {[info exists tag($name)]} {
                        set chan0 [open $fileres a+]
                     } else {
                        set tag($name) "ok"
                        set chan0 [open $fileres w]
                        puts $chan0 "idbddimg,commundatejj,ra,dec,res_ra,res_dec,omc_ra,omc_dec,name,pvalue,xsm,ysm,err_xsm,err_ysm,fwhmx,fwhmy,fwhm,fluxintegre,errflux,pixmax,intensite,sigmafond,snint,snpx,delta,rdiff"
                     }
                     puts $chan0 "$idbddimg,$commundatejj,$ra,$dec,$res_ra,$res_dec,$omc_ra,$omc_dec,$name,$pvalue,$xsm,$ysm,$err_xsm,$err_ysm,$fwhmx,$fwhmy,$fwhm,$fluxintegre,$errflux,$pixmax,$intensite,$sigmafond,$snint,$snpx,$delta,$rdiff"
                     close $chan0
                     break
                  }
                  
               }
               
            }

            incr id_current_image
         }
         
         gren_info "s $s\n"

      }


      # Fichier au format MPC 
      if {$form=="MPC"} {
      }

   }



   proc ::tools_astrometry::set_savprogress { cur max } {
      set ::tools_astrometry::savprogress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }
   proc ::tools_astrometry::annul_save_images { } {
      set ::tools_astrometry::savannul 1
   }




   proc ::tools_astrometry::save_images { } {


      global audace
      global bddconf

      set id_current_image 0
      ::tools_astrometry::set_fields_astrom astrom
      set n [llength $astrom(kwds)]

      foreach current_image $::tools_cata::img_list {

         incr id_current_image

         # Progression
         ::tools_astrometry::set_savprogress $id_current_image $::tools_cata::nb_img_list
         if { $::tools_astrometry::savannul } { break }
         
         # Tabkey
         set idbddimg [::bddimages_liste::lget $current_image "idbddimg"]
         set tabkey   [::bddimages_liste::lget $current_image "tabkey"]

         # Noms des fichiers
         set imgfilename    [::bddimages_liste::lget $current_image filename]
         set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
         set cataxml "${f}_cata.xml"

         # buf$::audace(bufNo) setkwd [list $kwd $val $type $unit $comment]
         
         set ident [bddimages_image_identification $idbddimg]
         set fileimg  [lindex $ident 1]
         set filecata [lindex $ident 3]


         # Maj du buffer
         buf$::audace(bufNo) load $fileimg

         foreach vals $::tools_cata::new_astrometry($id_current_image) {
            buf$::audace(bufNo) setkwd $vals
         }


         set tabkey [::bdi_tools_image::get_tabkey_from_buffer]
         
         # Creation de l image temporaire
         set fichtmpunzip [unzipedfilename $fileimg]
         set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
         set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]
         createdir_ifnot_exist $bddconf(dirtmp)
         buf$::audace(bufNo) save $filetmp
         lassign [::bddimages::gzip $filetmp $filefinal] errnum msg

         # efface l image dans la base et le disque
         bddimages_image_delete_fromsql $ident
         bddimages_image_delete_fromdisk $ident
         
         # insere l image dans la base
         set err [catch {set idbddimg [insertion_solo $filefinal]} msg]
         if {$err} {
            gren_info "Erreur Insertion (ERR=$err) (MSG=$msg) (RESULT=$idbddimg) \n"
         }

         # Effacement de l image du repertoire tmp
         set errnum [catch {file delete $filetmp} msg]

         # insere le cata dans la base
         ::tools_cata::save_cata $::gui_cata::cata_list($id_current_image) $tabkey $cataxml

         # Maj  ::tools_cata::img_list
         set current_image [::bddimages_liste::lupdate $current_image idbddimg $idbddimg]
         set current_image [::bddimages_liste::lupdate $current_image tabkey $tabkey]
         set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $id_current_image - 1] [expr $id_current_image - 1] $current_image]
      }

      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]

   }




   proc ::tools_astrometry::convert_mpc_hms { val } {

      set h [expr $val/15.]
      set hint [expr int($h)]
      set r [expr $h - $hint]
      set m [expr $r * 60.]
      set mint [expr int($m)]
      set r [expr $m - $mint]
      set sec [format "%.3f" [expr $r * 60.]]
      if {$hint < 10.0} {set hint "0$hint"}
      if {$mint < 10.0} {set m "0$mint"}
      if {$sec  < 10.0} {set sec "0$sec"}
      return "$hint $mint $sec"

   }



   proc ::tools_astrometry::convert_mpc_dms { val } {

      set s "+"
      if {$val < 0} {
         set s "-"
      }
      set aval [expr abs($val)]
      set d [expr int($aval)]
      set r [expr $aval - $d]
      set m [expr $r * 60.]
      set mint [expr int($m)]
      set r [expr $m - $mint]
      set sec [format "%.2f" [expr $r * 60.]]
      if {$d    < 10.0} {set d "0$d"}
      if {$mint < 10.0} {set m "0$mint"}
      if {$sec  < 10.0} {set sec "0$sec"}
      return "$s$d $mint $sec"
      
   }



   proc ::tools_astrometry::convert_mpc_date { date } {

      set a [string range $date 0 3]
      set m [string range $date 5 6]
      set d [string range $date 8 9]
      set h [string range $date 11 12]
      set mn [string range $date 14 15]
      set s  [string range $date 17 22]
      set day [format "%.6f" [expr $d + $h / 24. + $mn / 24. / 60. + $s / 24. /3600.]]
      if {$day <10.0} {set day "0$day"}
      return "$a $m $day"

   }



   proc ::tools_astrometry::convert_mpc_mag { mag } {

      # Band in which the measurement was made:
      #  B (default if band is not indicated), V, R, I, J, W, U, g, r, i, w, y and z
      set bandmag "R"
      # Observed magnitude and band: F5.2,A1
      set mpc_mag [format "%5.2f%1s" $mag $bandmag]

      return "$mpc_mag"
   }



   # MPC naming convention for asteroids
   #   Columns     Format   Use
   #    1 -  5       A5     Minor planet number
   #    6 - 12       A7     Provisional or temporary designation
   #   13            A1     Discovery asterisk
   proc ::tools_astrometry::convert_mpc_name { name } {

      set mpc_name [format "%13s" " "]

      set sname [split $name "_"]
      switch [lindex $sname 0] {
         SKYBOT {
            if {[string length [lindex $sname 1]] > 0} {
               # Sso official number 
               set onum [lindex $sname 1]
               if {$onum < 100000} {
                  # Official number
                  set mpc_name [format "%05u%7s%1s" $onum " " " "]
               } else {
                  # Official number in packed form
                  set x [expr {int($onum/10000.0)}]
                  set p [string map {10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K 21 L 22 M 23 N 24 O 25 P 26 Q 27 R 28 S 29 T 30 U 31 V 32 W 33 X 34 Y 35 Z} $x]
                  set mpc_name [format "%1s%04u%7s%1s" $p [string range $onum 2 end] " " " "]
               }
            } else {
               # No number, then get packed form of the provisional designation
               set packedname [::tools_astrometry::get_packed_designation [lrange $sname 2 end]]
               set mpc_name [format "%5s%7s%1s" " " $packedname " "]
            }
         }
         IMG {
            # Unknown or not identified Sso -> user name (must start by one or more letters).
            set form "%5s%7s%1s"
            set uname [string range [lindex $sname 1] 0 5]
            set mpc_name [format $form " " "U$uname" "*"]
         }
      }
   
      return $mpc_name
   
   }



   # Source: http://www.minorplanetcenter.net/iau/info/PackedDes.html
   # The first two digits of the year are packed into a single character in column 1 (I = 18, J = 19, K = 20).
   # Columns 2-3 contain the last two digits of the year.
   # Column 4 contains the half-month letter and column 7 contains the second letter.
   # The cycle count (the number of times that the second letter has cycled through the alphabet) is coded in columns 5-6,
   # using a letter in column 5 when the cycle count is larger than 99. The uppercase letters are used, followed by the lowercase
   # letters.
   #
   # Where possible, the cycle count should be displayed as a subscript when the designation is written out in unpacked format.
   #   Examples:
   #   J95X00A = 1995 XA
   #   J95X01L = 1995 XL1
   #   J95F13B = 1995 FB13
   #   J98SA8Q = 1998 SQ108
   #   J98SC7V = 1998 SV127
   #   J98SG2S = 1998 SS162
   #   K99AJ3Z = 2099 AZ193
   #   K08Aa0A = 2008 AA360
   #   K07Tf8A = 2007 TA418
   #
   # Survey designations of the form 2040 P-L, 3138 T-1, 1010 T-2 and 4101 T-3 are packed differently. Columns 1-3 contain the code
   # indicating the survey and columns 4-7 contain the number within the survey.
   #
   #   Examples:
   #   2040 P-L  = PLS2040
   #   3138 T-1  = T1S3138
   #   1010 T-2  = T2S1010
   #   4101 T-3  = T3S4101
   #
   proc ::tools_astrometry::get_packed_designation { prov } {

      # Split la designation provisoire en ses 2 parties
      set lprov [split $prov]

      # Cas des surveys
      if {[string match {[\P\T\-]*} [lindex $lprov 1]]} {
         set c1 [string range [lindex $lprov 1] 0 0]
         set c2 [string range [lindex $lprov 1] 2 2]
         set c3 [lindex $lprov 0]
         set packed [format "%1s%1s%1s%4s" $c1 $c2 "S" $c3]
         return $packed
      }

      # Autres cas:

      # Pack les 2 premiers chiffres de l'annee
      set first2digits [string range [lindex $lprov 0] 0 1]
      set c1 [string map {10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K 21 L 22 M 23 N 24 O 25 P 26 Q 27 R 28 S 29 T 30 U 31 V 32 W 33 X 34 Y 35 Z} $first2digits]
      set c2 [string range [lindex $lprov 0] 2 end]
      set c4 [string range [lindex $lprov 1] 0 0]
      set c7 [string range [lindex $lprov 1] 1 1]
      set cyclecount [string range [lindex $lprov 1] 2 end]
      if {$cyclecount < 10} {
         set c5 [format "0%1s" $cyclecount]
      } elseif {$cyclecount < 100} {
         set c5 [format "%2s" $cyclecount]
      } else {
         set first2digits [string range $cyclecount 0 1]
         set lastdigit [string range $cyclecount 2 end]
         set p [string map {10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K 21 L 22 M 23 N 24 O 25 P 26 Q 27 R 28 S 29 T 30 U 31 V 32 W 33 X 34 Y 35 Z\
                            36 a 37 b 38 c 39 d 40 e 41 f 42 g 43 h 44 i 45 j 46 k 47 l 48 m 49 n 50 o 51 p 52 q 53 r 54 s 55 t 56 u 57 v 58 w 59 x 60 y 61 z} $first2digits]
         set c5 [format "%1s%1s" $p $lastdigit]
      }
      set packed [format "%1s%2s%1s%2s%1s" $c1 $c2 $c4 $c5 $c7]
      return $packed

   }




# Fin de Classe
}

