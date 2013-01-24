namespace eval tools_astrometry {


variable science
variable reference
variable treshold
variable delta
variable ifortlib
variable imagelimit


   proc ::tools_astrometry::load_cata {  } {

      global bddconf

      set catafilenameexist [::bddimages_liste::lexist $::tools_cata::current_image "catafilename"]
      if {$catafilenameexist==0} {return}

      set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
      set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
      #gren_info "catafile = $catafile\n"
      set errnum [catch {set catafile [::tools_cata::extract_cata_xml $catafile]} msg ]
      if {$errnum} {
         return -code $errnum $msg
      }
      
      gren_info "READ catafile = $catafile\n"
      set listsources [::tools_cata::get_cata_xml $catafile]
      
      set listsources [::tools_sources::set_common_fields $listsources IMG    { ra dec 5.0 calib_mag calib_mag_ss1}]
      #set listsources [::tools_sources::set_common_fields $listsources USNOA2 { ra dec poserr mag magerr }]
      set listsources [::tools_sources::set_common_fields $listsources USNOA2 { ra dec poserr mag magerr }]
      set listsources [::tools_sources::set_common_fields $listsources UCAC2  { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
      #set listsources [::tools_sources::set_common_fields $listsources UCAC2  { ra_deg dec_deg 0 0 0}]
      set listsources [::tools_sources::set_common_fields $listsources UCAC3  { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
      #set listsources [::tools_sources::set_common_fields $listsources TYCHO2 { RAdeg DEdeg 5 VT e_VT }]
      set listsources [::tools_sources::set_common_fields_skybot $listsources]
      #set listsources [::tools_sources::set_common_fields $listsources TYCHO2 { RAdeg DEdeg 5 VT e_VT }]
      set ::tools_cata::current_listsources $listsources

      set errnum [catch {file delete -force $catafile} msg ]

   }



   proc ::tools_astrometry::load_all_cata {  } {

      global bddconf

      set ::tools_astrometry::imagelimit 250

      gren_info "Science = $::tools_astrometry::science\n"
      gren_info "Reference = $::tools_astrometry::reference\n"
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
      gren_info "nb img = $::tools_cata::nb_img_list\n"
      
      set imgtmp {}
      set ::tools_cata::id_current_image 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {

         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
         gren_info "date : $date  idbddimg : $idbddimg\n"
         # gren_info "CURRENT_IMAGE :  $::tools_cata::current_image\n"

         if {[::bddimages_liste::lget $::tools_cata::current_image "cataexist"]=="1"} {

            set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
            set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]
            set file        [file join $bddconf(dirbase) $dirfilename $filename]
            set ::tools_cata::current_image_name $filename
            set ::tools_cata::current_image_date $date

            set ra             [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
            set dec            [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
            set pixsize1       [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
            set pixsize2       [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
            set foclen         [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
            set exposure       [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
            set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
            set naxis1         [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
            set naxis2         [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]

            ::tools_astrometry::load_cata

            lappend imgtmp [::bddimages_liste::ladd $::tools_cata::current_image listsources $::tools_cata::current_listsources ]
            
            incr ::tools_cata::id_current_image
            if {$::tools_cata::id_current_image>=$::tools_astrometry::imagelimit} {break}
         }
         
      }

      set ::tools_cata::img_list $imgtmp
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
      gren_info "nb img = $::tools_cata::nb_img_list\n"

   }


 
   proc ::tools_astrometry::modif_array { sent_array } {
         upvar $sent_array a
         
         set a [list 4 3 2 ]
         
   }
   proc ::tools_astrometry::modif_array2 { u } {
      array set b $u 
      set b(1,1) 1
      return [array get b]
   }

   proc ::tools_astrometry::create_array { sent_array } {

      upvar $sent_array a

      set tt0 [clock clicks -milliseconds]
      for {set i 0} {$i<2000} {incr i} {
         for {set j 0} {$j<2000} {incr j} {
            set a($i,$j) 0
         }
      }
      set tt1 [clock clicks -milliseconds]
      set tt [expr ($tt1 - $tt0)/1000.]
      gren_info "Creation array duration $tt sec \n"
         

   }

   proc ::tools_astrometry::mytest { } {

      gren_info "TEST\n"
      set a [list 1 2 4]
      
      ::tools_astrometry::modif_array a
         gren_info "$a\n"
return

      set tt0 [clock clicks -milliseconds]
      for {set i 0} {$i<2000} {incr i} {
         for {set j 0} {$j<2000} {incr j} {
            set a($i,$j) 0
         }
      }
      set tt1 [clock clicks -milliseconds]
      set tt [expr ($tt1 - $tt0)/1000.]
      gren_info "Creation array duration $tt sec \n"
      gren_info "size(a)= [array size a]\n"

      ::tools_astrometry::create_array ::tools_astrometry::myarray
      gren_info "size(b)= [array size ::tools_astrometry::myarray]\n"

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::modif_array a
      gren_info "a(1,1) = $a(1,1) \n"
      set tt1 [clock clicks -milliseconds]
      set tt [expr ($tt1 - $tt0)/1000.]
      gren_info "Modif array duration $tt sec \n"

      set tt0 [clock clicks -milliseconds]
      set ::tools_astrometry::myarray [::tools_astrometry::modif_array2 [array get ::tools_astrometry::myarray]]
      gren_info "::tools_astrometry::myarray(1,1) = $::tools_astrometry::myarray(1,1) \n"
      set tt1 [clock clicks -milliseconds]
      set tt [expr ($tt1 - $tt0)/1000.]
      gren_info "Modif array duration $tt sec \n"

   }





   proc ::tools_astrometry::init_priam { } {

      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

      ::gui_cata::charge_memory 0

      set ::tools_cata::id_current_image 1
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         if {$::tools_cata::id_current_image==1} {set tag "new"} else {set tag "add"}
         gren_info "$::tools_cata::current_image\n"
         ::priam::create_file_oldformat $tag $::tools_cata::nb_img_list ::tools_cata::current_image ::gui_cata::cata_list($::tools_cata::id_current_image)
         incr ::tools_cata::id_current_image
      }
      set ::tools_cata::id_current_image 1

   }















   proc ::tools_astrometry::go_priam {  } {


      set ::tools_astrometry::last_results_file [::priam::launch_priam]
      gren_info "new file : <$::tools_astrometry::last_results_file>\n"
      ::tools_astrometry::extract_priam_result $::tools_astrometry::last_results_file

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
   proc ::tools_astrometry::get_cols {} {
      return [list nb mrho stdev_rho mra mrd sra srd ma md sa sd mm sm]
   }




   proc ::tools_astrometry::create_vartab { } {
         
      if {[info exists ::tools_astrometry::tabval]}        {unset ::tools_astrometry::tabval}
      if {[info exists ::tools_astrometry::listref]}       {unset ::tools_astrometry::listref}
      if {[info exists ::tools_astrometry::listscience]}   {unset ::tools_astrometry::listscience}
      if {[info exists ::tools_astrometry::listdate]}      {unset ::tools_astrometry::listdate}

            
      set ::tools_cata::id_current_image 0

      foreach ::tools_cata::current_image $::tools_cata::img_list {

         incr ::tools_cata::id_current_image
         set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
         set commundatejj [::bddimages_liste::lget $::tools_cata::current_image "commundatejj"]
         set dateiso [ mc_date2iso8601 $commundatejj ]










         set list_id_science [::tools_cata::get_id_astrometric "S" ::tools_cata::current_listsources]
         foreach l $list_id_science {

            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]
            #gren_info "Lect = $id $idcata $ar $ac $name\n"
            
            set s       [lindex [lindex $::tools_cata::current_listsources 1] $id]
            set astroid [lindex $s $idcata]
            set b       [lindex $astroid 2]
            #gren_info "b = $b\n"

            set ra      [lindex $b 14]
            set dec     [lindex $b 15]
            set res_ra  [format  "%.4f" [lindex $b 16] ]
            set res_dec [format  "%.4f" [lindex $b 17] ]
            set rho     [format  "%.4f" [expr sqrt((pow($res_ra,2)+pow($res_dec,2))/2.)]]
            set omc_ra  [lindex $b 18]
            set omc_dec [lindex $b 19]
            set mag     "-"
            #gren_info "->vartab($name,$dateiso) ($ar $ra $dec $res_ra $res_dec $ecart $mag)\n"

            set ::tools_astrometry::tabval($name,$dateiso) [list $ar $rho $res_ra $res_dec $ra $dec $mag]

            lappend ::tools_astrometry::listscience($name) $dateiso
            lappend ::tools_astrometry::listdate($dateiso) $name
         }
         
         
 









         set list_id_ref [::tools_cata::get_id_astrometric "R" ::tools_cata::current_listsources]
         foreach l $list_id_ref {

            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]
            #gren_info "Lect = $id $idcata $ar $ac $name\n"
            
            set s       [lindex [lindex $::tools_cata::current_listsources 1] $id]
            set astroid [lindex $s $idcata]
            set b       [lindex $astroid 2]
            #gren_info "b = $b\n"

            set ra      [lindex $b 14]
            set dec     [lindex $b 15]
            set res_ra  [format  "%.4f" [lindex $b 16] ]
            set res_dec [format  "%.4f" [lindex $b 17] ]
            set rho     [format  "%.4f" [expr sqrt((pow($res_ra,2)+pow($res_dec,2))/2.)]]
            set omc_ra  [lindex $b 18]
            set omc_dec [lindex $b 19]
            set mag     "-"
            #gren_info "->vartab($name,$dateiso) ($ar $ra $dec $res_ra $res_dec $ecart $mag)\n"
            set ::tools_astrometry::tabval($name,$dateiso) [list $ar $rho $res_ra $res_dec $ra $dec $mag]

            lappend ::tools_astrometry::listref($name)     $dateiso
            lappend ::tools_astrometry::listdate($dateiso) $name
            
         }
         
      }
# loc_sources_par Name Nb mrho stdev_rho mra mrd sra srd ma md sa sd mm sm   
   
   
   }








   proc ::tools_astrometry::calcul_statistique { } {
   
 
      package require math::statistics
   
      if {[info exists ::tools_astrometry::tabdate]}       {unset ::tools_astrometry::tabdate}
      if {[info exists ::tools_astrometry::tabref]}        {unset ::tools_astrometry::tabref}
      if {[info exists ::tools_astrometry::tabscience]}    {unset ::tools_astrometry::tabscience}
#
# STAT sur la liste des references
#

      foreach name [array names ::tools_astrometry::listref] {

         set rho ""
         set a   ""
         set d   ""
         set ra  ""
         set rd  ""

         foreach date $::tools_astrometry::listref($name) {
            lappend rho [lindex $::tools_astrometry::tabval($name,$date) 1]
            lappend ra  [lindex $::tools_astrometry::tabval($name,$date) 2]
            lappend rd  [lindex $::tools_astrometry::tabval($name,$date) 3]
            lappend a   [lindex $::tools_astrometry::tabval($name,$date) 4]
            lappend d   [lindex $::tools_astrometry::tabval($name,$date) 5]
         }


         set nb   [llength $::tools_astrometry::listref($name)]
         set mrho [format "%.3f" [::math::statistics::mean  $rho]]
         set srho [format "%.3f" [::math::statistics::stdev $rho]]
         set mra  [format "%.3f" [::math::statistics::mean  $ra ]]
         set mrd  [format "%.3f" [::math::statistics::mean  $rd ]]
         set sra  [format "%.3f" [::math::statistics::stdev $ra ]]
         set srd  [format "%.3f" [::math::statistics::stdev $rd ]]
         set ma   [format "%.6f" [::math::statistics::mean  $a  ]]
         set md   [format "%.5f" [::math::statistics::mean  $d  ]]
         set sa   [format "%.3f" [::math::statistics::stdev $a  ]]
         set sd   [format "%.3f" [::math::statistics::stdev $d  ]]
         set mm   "-"
         set sm   "-"

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

         foreach date $::tools_astrometry::listscience($name) {
            lappend rho [lindex $::tools_astrometry::tabval($name,$date) 1]
            lappend ra  [lindex $::tools_astrometry::tabval($name,$date) 2]
            lappend rd  [lindex $::tools_astrometry::tabval($name,$date) 3]
            lappend a   [lindex $::tools_astrometry::tabval($name,$date) 4]
            lappend d   [lindex $::tools_astrometry::tabval($name,$date) 5]
         }
         
         set nb   [llength $::tools_astrometry::listscience($name)]
         set mrho [format "%.3f" [::math::statistics::mean  $rho]]
         set srho [format "%.3f" [::math::statistics::stdev $rho]]
         set mra  [format "%.3f" [::math::statistics::mean  $ra ]]
         set mrd  [format "%.3f" [::math::statistics::mean  $rd ]]
         set sra  [format "%.3f" [::math::statistics::stdev $ra ]]
         set srd  [format "%.3f" [::math::statistics::stdev $rd ]]
         set ma   [format "%.6f" [::math::statistics::mean  $a  ]]
         set md   [format "%.5f" [::math::statistics::mean  $d  ]]
         set sa   [format "%.3f" [::math::statistics::stdev $a  ]]
         set sd   [format "%.3f" [::math::statistics::stdev $d  ]]
         set mm   "-"
         set sm   "-"

         set ::tools_astrometry::tabscience($name) [list $name $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm]
      }
      
# STAT sur la liste des dates


      foreach date [array names ::tools_astrometry::listdate] {

         set rho ""
         set a ""
         set d ""
         set ra ""
         set rd ""

         set nb 0
         foreach name $::tools_astrometry::listdate($date) {
            if {[lindex $::tools_astrometry::tabval($name,$date) 0]=="S"} { continue }
            incr nb
            lappend rho [lindex $::tools_astrometry::tabval($name,$date) 1]
            lappend ra  [lindex $::tools_astrometry::tabval($name,$date) 2]
            lappend rd  [lindex $::tools_astrometry::tabval($name,$date) 3]
            lappend a   [lindex $::tools_astrometry::tabval($name,$date) 4]
            lappend d   [lindex $::tools_astrometry::tabval($name,$date) 5]
         }

         set mrho [format "%.3f" [::math::statistics::mean  $rho]]
         set srho [format "%.3f" [::math::statistics::stdev $rho]]
         set mra  [format "%.3f" [::math::statistics::mean  $ra ]]
         set mrd  [format "%.3f" [::math::statistics::mean  $rd ]]
         set sra  [format "%.3f" [::math::statistics::stdev $ra ]]
         set srd  [format "%.3f" [::math::statistics::stdev $rd ]]
         set ma   [format "%.6f" [::math::statistics::mean  $a  ]]
         set md   [format "%.5f" [::math::statistics::mean  $d  ]]
         set sa   [format "%.3f" [::math::statistics::stdev $a  ]]
         set sd   [format "%.3f" [::math::statistics::stdev $d  ]]
         set mm   "-"
         set sm   "-"

         set ::tools_astrometry::tabdate($date)  [list $date $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm]
      }
      
   }














   proc ::tools_astrometry::results_priam {  } {

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::extract_priam_result $::tools_astrometry::last_results_file
      set tt [expr ([clock clicks -milliseconds] - $tt0)/1000.]
      gren_info "Extraction des resultats Priam in $tt sec \n"

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::create_vartab  
      set tt [expr ([clock clicks -milliseconds] - $tt0)/1000.]
      gren_info "Creation de la structure de variable in $tt sec \n"
      
      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::calcul_statistique  
      set tt [expr ([clock clicks -milliseconds] - $tt0)/1000.]
      gren_info "Calculs statistiques in $tt sec \n"

      return

   }









 # Obsolete ?

   proc ::tools_astrometry::test {  } {

      set r [buf1 fitgauss [list 222 193 269 234 ]]
      set radec [ buf1 xy2radec [ list [lindex $r 1] [lindex $r 5] ] ]
      gren_info "\nRADEC=$radec\n\n"
      
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



      
      set ::tools_cata::id_current_image 0

      # Lecture du fichier en continue

      while {[gets $chan line] >= 0} {

         set a [split $line "="]
         set key [lindex $a 0]
         set val [lindex $a 1]
         #gren_info "$key=$val\n"
          
         if {$key=="BEGIN"} {
            # Debut image
            set filename $val
            incr ::tools_cata::id_current_image
            set catascience($::tools_cata::id_current_image) ""
            set cataref($::tools_cata::id_current_image) ""

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
            lappend catascience($::tools_cata::id_current_image) [list $name $sour]
         }
         if {$key=="CATA_REF"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            lappend cataref($::tools_cata::id_current_image) [list $name $sour]
         }
                  
      }
      close $chan

      #gren_info "NB IMG EXTRACTED FROM PRIAM RESULTS: [expr $::tools_cata::id_current_image +1 ] \n"
      #gren_info "NB IMG LIST: [llength $::tools_cata::img_list] \n"

   # sur une seule image -> current_listsources

      #gren_info "[::manage_source::get_fields_from_sources $::tools_cata::current_listsources] \n"

   # A FAIRE  : nettoyage des astrometrie de current_listsources

   #   ::tools_astrometry::clean_astrom 

   # Insertion des resultats dans current_listsources

      set fieldsastroid [::analyse_source::get_fieldastroid]
  
#      set fieldsastroid [list "ASTROID" {} [list "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" \
 #                                          "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" \
#                                           "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" \
#                                           "mag" "err_mag" "name"] ]
                                           
      set ::tools_cata::id_current_image 0

      foreach ::tools_cata::current_image $::tools_cata::img_list {

         incr ::tools_cata::id_current_image
         
         set ex [::bddimages_liste::lexist $::tools_cata::current_image "listsources"]
         if {$ex != 0} {
            ::console::affiche_erreur "Attention listsources existe dans img_list et ce n est plus necessaire\n"
         } 
         
         set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
         gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

         #gren_info "LISTSOURCES: ($::tools_cata::current_listsources) \n"
         set n [llength $catascience($::tools_cata::id_current_image)]
         #gren_info "NB SCIENCE: ($n) \n"

         set fields [lindex $::tools_cata::current_listsources 0]
         set sources [lindex $::tools_cata::current_listsources 1]
         
         set list_id_science [::tools_cata::get_id_astrometric "S" ::tools_cata::current_listsources]
         
         #gren_info "list_id_science = $list_id_science\n"

         foreach l $list_id_science {
            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]
            #gren_info "Lect = $id $idcata $ar $ac $name\n"
            #gren_info "catascience = $catascience($::tools_cata::id_current_image)\n"


            set x  [lsearch -index 0 $catascience($::tools_cata::id_current_image) $name]
            if {$x>=0} {
               set data [lindex [lindex $catascience($::tools_cata::id_current_image) $x] 1]
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
               set b [lreplace $b 14 19 $ra $dec $res_ra $res_dec $omc_ra $omc_dec]
               set astroid [lreplace $astroid 2 2 $b]
               #gren_info "astroid = $astroid\n"
               set s [lreplace $s $idcata $idcata $astroid]
               set sources [lreplace $sources $id $id $s]
            }
         }

         set list_id_ref [::tools_cata::get_id_astrometric "R" ::tools_cata::current_listsources]
         
         #gren_info "list_id_ref = $list_id_ref\n"

         foreach l $list_id_ref {
            set id     [lindex $l 0]
            set idcata [lindex $l 1]
            set ar     [lindex $l 2]
            set ac     [lindex $l 3]
            set name   [lindex $l 4]
            #gren_info "Lect = $id $idcata $ar $ac $name\n"
            #gren_info "cataref = $cataref($::tools_cata::id_current_image)\n"

            set x  [lsearch -index 0 $cataref($::tools_cata::id_current_image) $name]
            if {$x>=0} {
               set data [lindex [lindex $cataref($::tools_cata::id_current_image) $x] 1]
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
               set b [lreplace $b 14 17 $ra $dec $res_ra $res_dec]
               set astroid [lreplace $astroid 2 2 $b]
               #gren_info "astroid = $astroid\n"
               set s [lreplace $s $idcata $idcata $astroid]
               set sources [lreplace $sources $id $id $s]
            }
         }
 
      set ::gui_cata::cata_list($::tools_cata::id_current_image) [list $fields $sources]

      }


   #gren_info "SRol=[ ::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   #gren_info "ASTROIDS=[::manage_source::extract_sources_by_catalog $::tools_cata::current_listsources ASTROID]\n"
   #gren_info "LISTSOURCES=$::tools_cata::current_listsources\n"

   # Ecriture des resultats dans un fichier 
      

   }













   
# ASTROID --   
# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" "name"
   proc ::tools_astrometry::set_astrom_to_source { s ra dec res_ra res_dec omc_ra omc_dec flag name} {
   
      set pass "no"
      
      set stmp {}
      foreach cata $s {
         if {[lindex $cata 0] == "ASTROID"} {
            set pass "yes"
            set astroid [lindex $cata 2]
            set astroid [lreplace $astroid 14 20 $ra $dec $res_ra $res_dec $omc_ra $omc_dec $flag]
            set astroid [lreplace $astroid 23 23 $name]
            
            lappend stmp [list "ASTROID" {} $astroid]
         } else {
            lappend stmp $cata
         }
      }
      return $stmp
   }
   
   
   
   
   
   
   
   
   
   
   
   





# ASTROID --   
# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" "name" 

   proc ::tools_astrometry::save { form } {

      global bddconf audace
  
      gren_info "FORMAT:$form\n"
      
      # Fichier au format TXT 
      
      if {$form=="TXT"} {

         if {[info exists tag]} {unset tag}
         set ::tools_cata::id_current_image 0
         foreach ::tools_cata::current_image $::tools_cata::img_list {

            set idbddimg [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]
            set commundatejj [::bddimages_liste::lget $::tools_cata::current_image "commundatejj"]
            set ::tools_cata::current_listsources [::bddimages_liste::lget $::tools_cata::current_image "listsources"]
            set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
            set pvalue [string trim [lindex [::bddimages_liste::lget $tabkey "CATA_PVALUE"] 1] ]
            set pvalue 0

            foreach s [lindex $::tools_cata::current_listsources 1] {
               foreach cata $s {

                  if {[lindex $cata 0] == "ASTROID"} {
                     set astroid [lindex $cata 2]

# ASTROID --   
# ASTROID --   
# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" "name" 

                     set xsm         [lindex $astroid  0]  
                     set ysm         [lindex $astroid  1]  
                     set fwhmx       [lindex $astroid  2]  
                     set fwhmy       [lindex $astroid  3]  
                     set fwhm        [lindex $astroid  4]  
                     set fluxintegre [lindex $astroid  5]  
                     set errflux     [lindex $astroid  6]  
                     set pixmax      [lindex $astroid  7]  
                     set intensite   [lindex $astroid  8]  
                     set sigmafond   [lindex $astroid  9]  
                     set snint       [lindex $astroid 10]  
                     set snpx        [lindex $astroid 11]  
                     set delta       [lindex $astroid 12]  
                     set rdiff       [lindex $astroid 13]  
                     set ra          [lindex $astroid 14]  
                     set dec         [lindex $astroid 15]   
                     set res_ra      [lindex $astroid 16]  
                     set res_dec     [lindex $astroid 17]  
                     set omc_ra      [lindex $astroid 18]   
                     set omc_dec     [lindex $astroid 19]  
                     set flagastrom  [lindex $astroid 20]  
                     set mag         [lindex $astroid 21]  
                     set err_mag     [lindex $astroid 22]  
                     set name        [lindex $astroid 23]  

                     if {$flagastrom!="S"&&$flagastrom!="R"} {break}
                     gren_info "$idbddimg name:$name $ra $dec\n"
                     set fileres "PRIAM_$name.csv"
                     set fileres [ file join $audace(rep_travail) $fileres ]
                     if {[info exists tag($name)]} {
                        set chan0 [open $fileres a+]
                     } else {
                        set tag($name) "ok"
                        set chan0 [open $fileres w]
                        puts $chan0 "idbddimg,commundatejj,ra,dec,res_ra,res_dec,omc_ra,omc_dec,name,pvalue,xsm,ysm,fwhmx,fwhmy,fwhm,fluxintegre,errflux,pixmax,intensite,sigmafond,snint,snpx,delta,rdiff"
                     }
                     puts $chan0 "$idbddimg,$commundatejj,$ra,$dec,$res_ra,$res_dec,$omc_ra,$omc_dec,$name,$pvalue,$xsm,$ysm,$fwhmx,$fwhmy,$fwhm,$fluxintegre,$errflux,$pixmax,$intensite,$sigmafond,$snint,$snpx,$delta,$rdiff"
                     close $chan0
                     break
                  }
                  
               }
               
            }

            incr ::tools_cata::id_current_image
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
         foreach ::tools_cata::current_image $::tools_cata::img_list {
            set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
            set ::tools_cata::current_listsources [::bddimages_liste::lget $::tools_cata::current_image "listsources"]

            set cataxml [::tools_cata::get_catafilename $::tools_cata::current_image "TMP" ]
            
            gren_info "cataxml = $cataxml\n"

            gren_info "Rol=[ ::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
            set votable [::votableUtil::list2votable $::tools_cata::current_listsources $tabkey]

#            gren_info "votable = $votable\n"

            # Sauvegarde du cata XML
            #gren_info "Enregistrement du cata XML: $cataxml\n"
            
            set fxml [open $cataxml "w"]
            puts $fxml $votable
            close $fxml

            return

            set err [ catch { insertion_solo $cataxml } msg ]
            gren_info "** INSERTION_SOLO = $err $msg\n"

            set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
            if {$cataexist==0} {
               set ::tools_cata::current_image [::bddimages_liste::ladd $::tools_cata::current_image "cataexist" 1]
            } else {
               set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "cataexist" 1]
            }
         }

      }
   
   }

# Fin de Classe
}

