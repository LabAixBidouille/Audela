namespace eval tools_astrometry {


variable science
variable reference
variable imglist
variable current_image
variable current_image_name
variable current_image_date
variable current_listsources



   proc ::tools_astrometry::load_cata {  } {

      global bddconf

      set catafilenameexist [::bddimages_liste::lexist $::tools_astrometry::current_image "catafilename"]
      if {$catafilenameexist==0} {return}

      set catafilename [::bddimages_liste::lget $::tools_astrometry::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::tools_astrometry::current_image "catadirfilename"]
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
      set ::tools_astrometry::current_listsources $listsources

   }

   proc ::tools_astrometry::go {  } {

      global bddconf

      gren_info "Science = $::tools_astrometry::science\n"
      gren_info "Reference = $::tools_astrometry::reference\n"

      foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {

         set tabkey      [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_astrometry::current_image idbddimg]
         gren_info "date : $date  idbddimg : $idbddimg\n"
         # gren_info "CURRENT_IMAGE :  $::tools_astrometry::current_image\n"

         if {[::bddimages_liste::lget $::tools_astrometry::current_image "cataexist"]=="1"} {

            set dirfilename [::bddimages_liste::lget $::tools_astrometry::current_image dirfilename]
            set filename    [::bddimages_liste::lget $::tools_astrometry::current_image filename]
            set file        [file join $bddconf(dirbase) $dirfilename $filename]
            set ::tools_astrometry::current_image_name $filename
            set ::tools_astrometry::current_image_date $date

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

            gren_info "current_listsources $tools_astrometry::current_listsources\n"
            
           # break
         }
         
      }

      ::tools_astrometry::extract_priam_result [::tools_astrometry::launch_priam]
      

   }

   proc ::tools_astrometry::launch_priam {  } {
       
       set ::tools_astrometry::current_listsources [::analyse_source::psf $tools_astrometry::current_listsources 10]
       ::priam::create_file_oldformat $::tools_astrometry::current_listsources $::tools_astrometry::science $::tools_astrometry::reference 
       gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $::tools_astrometry::current_listsources ]\n"

      #set cmdpriam "priam -lang en -format priam -m 1 -fc cnd.obs -fm science.mes -r ./ -fcat local.cat -rcat ./ -s fichier:priam -te 1"
      #set err [catch {exec export LD_LIBRARY_PATH=/usr/local/lib:/opt/intel/lib/intel64 |& $cmdpriam} msg ]
      
      #set err [catch {exec pwd} msg]
      #gren_info "launch_priam:  PWD : <$msg>\n"
      set err [catch {exec sh ./cmd.priam} msg]
      
      if {$err} {
         gren_info "launch_priam ERREUR d\n"
         gren_info "launch_priam:  NUM : <$err>\n" 
      }   
      #gren_info "launch_priam:  MSG : <$msg>\n"
      
    set tab [split $msg "\0"]
    foreach l $tab {
       #gren_info "ligne=$l n"
       set r [string last "writing results in the file:" $l ]
       #gren_info "r=$r ***\n"
       set file [string trim [string range $l [expr 29+$r] end] ]
       #gren_info "file=$file\n"
       
    }
      return $file
   }
   
   proc ::tools_astrometry::extract_priam_result { file } {
   
      set file "science.mes.bdi1"
      gren_info "extract_priam_result:  file : <$file>\n"
   
      set chan [open $file r]
      gets $chan success
      #gren_info "$success\n"
      if {$success!="SUCCESS"} {
         return
      }
      set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2}
      set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              um                              um}
      set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        double         double                          double}
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included"}
      set n [llength $astrom(kwds)]
      
      set cpt 0
      while {[gets $chan line] >= 0} {
         set a [split $line "="]
         set key [lindex $a 0]
         set val [lindex $a 1]
         gren_info "$key=$val\n"

         for {set k 0 } { $k<$n } {incr k} {
            set kwd [lindex $astrom(kwds) $k]
            if {$kwd==$key} {
               set type [lindex $astrom(types) $k]
               set unit [lindex $astrom(units) $k]
               set comment [lindex $astrom(comments) $k]
               buf$::audace(bufNo) setkwd [list $kwd $val $type $unit $comment]
            }
         }
         
         if {$key=="CATA_FIELDS"} {
            set catafields $val
         }
         if {$key=="CATA_VALUES"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            set catasource($name) $sour
         }
         if {$key=="CATA_REF"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            set catasource($name) $sour
         }
         
      }
      close $chan
   
      gren_info "[::manage_source::get_fields_from_sources $tools_astrometry::current_listsources] \n"
   
   
   }
   

}

# Sortie de Priam:

#SUCCESS
#CRVAL1=...
#CATA_FIELDS=ASTROM { ra dec dra ddec}
#CATA_VALUES=SKYBOT_1 { 12.59423872 +01.75000 0.0769  0.0382 }
#CATA_VALUES=SKYBOT_2 { 12.59423872 +01.19500 0.0769  0.0382 }
#...
#CATA_REF=UCAC3_1 { 12.59423872 +01.75000 0.11748 0.05313 }
#...
