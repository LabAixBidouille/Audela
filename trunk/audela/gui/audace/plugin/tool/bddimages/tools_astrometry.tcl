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
               if  { $ar == "R" } {
                  gren_info "-> $ar $ac\n"
               }
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

         gren_info "-- IMG : $id_current_image / [llength $::tools_cata::img_list]\n"

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
            gren_info "Lect Ref = $id $idcata $ar $ac $name\n"

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
            #gren_info "->vartab($name,$dateiso) ($ar $ra $dec $res_ra $res_dec $ecart $mag)\n"
            set ::tools_astrometry::tabval($name,$dateiso) [list [expr $id + 1] field $ar $rho $res_ra $res_dec $ra $dec $mag $err_mag]

            lappend ::tools_astrometry::listref($name)     $dateiso
            lappend ::tools_astrometry::listdate($dateiso) $name
            
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
            gren_info "Lect Science = $id $idcata $ar $ac $name\n"
            
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
         gren_info "nb ref = [llength $list_id_ref] \n "


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














 # Extraction des resultats de Priam

  
   proc ::tools_astrometry::extract_priam_result { file } {
   
      gren_info "extract_priam_result:  file : <$file>\n"
   
      set chan [open $file r]

      set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2                        CATA_PVALUE                       EQUINOX                            CTYPE1                CTYPE2                LONPOLE                                        CUNIT1                       CUNIT2                       }
      set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              um                              um                              percent                           no                                 no                    no                    deg                                            no                           no                           }
      set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        double         double                          double                          double                            string                             string                string                double                                         string                       string                       }
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included" "Pvalue of astrometric reduction" "System of equatorial coordinates" "Gnomonic projection" "Gnomonic projection" "Long. of the celest.NP in native coor.syst."  "Angles are degrees always"  "Angles are degrees always"  }
      set n [llength $astrom(kwds)]

      set id_current_image 0

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

            gets $chan success
            #gren_info "$success\n"
            if {$success!="SUCCESS"} {
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
         gren_info "rollup = [::manage_source::get_nb_sources_rollup $current_listsources]\n"

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

      # Fichier au format CATA 
      if {$form=="CATA"} {

         set fileres [ file join $audace(rep_travail) priam.txt ]
         set chan0 [open $fileres w]
         foreach current_image $::tools_cata::img_list {
            set tabkey      [::bddimages_liste::lget $current_image "tabkey"]
            set current_listsources [::bddimages_liste::lget $current_image "listsources"]

            set cataxml [::tools_cata::get_catafilename $current_image "TMP" ]
            
            gren_info "cataxml = $cataxml\n"

            gren_info "Rol=[ ::manage_source::get_nb_sources_rollup $current_listsources]\n"
            set votable [::votableUtil::list2votable $current_listsources $tabkey]

#            gren_info "votable = $votable\n"

            # Sauvegarde du cata XML
            #gren_info "Enregistrement du cata XML: $cataxml\n"
            
            set fxml [open $cataxml "w"]
            puts $fxml $votable
            close $fxml

            return

            set err [ catch { insertion_solo $cataxml } msg ]
            gren_info "** INSERTION_SOLO = $err $msg\n"

            set cataexist [::bddimages_liste::lexist $current_image "cataexist"]
            if {$cataexist==0} {
               set current_image [::bddimages_liste::ladd $current_image "cataexist" 1]
            } else {
               set current_image [::bddimages_liste::lupdate $current_image "cataexist" 1]
            }
         }

      }
   
   }

# Fin de Classe
}

