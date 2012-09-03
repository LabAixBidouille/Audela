namespace eval tools_astrometry {


variable science
variable reference
variable imglist
variable nbimg
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
      set ::tools_astrometry::nbimg [llength $::tools_astrometry::img_list]
      gren_info "nb img = $::tools_astrometry::nbimg\n"
      
      set imgtmp {}

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

            lappend imgtmp [::bddimages_liste::ladd $::tools_astrometry::current_image listsources $tools_astrometry::current_listsources ]
            #tabkey inkey inval
            #set ::tools_astrometry::listsources(idbddimg) $tools_astrometry::current_listsources
            #gren_info "current_listsources $tools_astrometry::current_listsources\n"
            
            # ne fait qu une seule image: la premiere de a liste
            #break
         }
         
      }

      set ::tools_astrometry::img_list $imgtmp
      set ::tools_astrometry::nbimg [llength $::tools_astrometry::img_list]
      gren_info "nb img = $::tools_astrometry::nbimg\n"

      ::tools_astrometry::extract_priam_result [::tools_astrometry::launch_priam]
      

   }

   proc ::tools_astrometry::launch_priam {  } {
       
      global bddconf

      set cpt 0
      foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {
 
         if {$cpt==0} {
            set tag "new"
         } else {
            set tag "add"
         }

         set dirfilename [::bddimages_liste::lget $::tools_astrometry::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::tools_astrometry::current_image filename]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]
         buf$::audace(bufNo) load $file
         ::confVisu::setFileName $::audace(visuNo) $file
         ::audace::autovisu $::audace(visuNo)
         

         set tabkey      [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]
         set ::tools_astrometry::current_listsources [::bddimages_liste::lget $::tools_astrometry::current_image "listsources"]
         set ::tools_astrometry::current_listsources [::analyse_source::psf $tools_astrometry::current_listsources $::tools_astrometry::treshold $::tools_astrometry::delta]
         ::priam::create_file_oldformat $tag $::tools_astrometry::nbimg $::tools_astrometry::current_listsources $::tools_astrometry::science $::tools_astrometry::reference 
         gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $::tools_astrometry::current_listsources ]\n"
         incr cpt
      }

      gren_info "nb img = [llength $::tools_astrometry::img_list] $cpt\n"

      #set cmdpriam "priam -lang en -format priam -m 1 -fc cnd.obs -fm science.mes -r ./ -fcat local.cat -rcat ./ -s fichier:priam -te 1"
      #set err [catch {exec export LD_LIBRARY_PATH=/usr/local/lib:/opt/intel/lib/intel64 |& $cmdpriam} msg ]
      
      #set err [catch {exec pwd} msg]
      #gren_info "launch_priam:  PWD : <$msg>\n"
      set err [catch {exec sh ./cmd.priam} msg]
      
      if {$err} {
         gren_info "launch_priam ERREUR d\n"
         gren_info "launch_priam:  NUM : <$err>\n" 
      }   
      gren_info "launch_priam:  MSG : <$msg>\n"
      
    set tab [split $msg "\0"]
    set pass "no"
    foreach l $tab {
       #gren_info "ligne=$l n"
       set exs [string first "writing results in the file:" $l]
       if {$exs>=0} {
          set r [string last "writing results in the file:" $l ]
          #gren_info "r=$r ***\n"
          set file [string trim [string range $l [expr 29+$r] end] ]
          #gren_info "file=$file\n"
          set pass "yes"
       }
       
    }
    
    if {$pass=="yes"} {
      gren_info "PRIAMRESULT: =$file\n"
      return -code 0 $file
    } else {
      return -code -1 $msg
    }
   }
   


   proc ::tools_astrometry::test {  } {

      set r [buf1 fitgauss [list 222 193 269 234 ]]
      set radec [ buf1 xy2radec [ list [lindex $r 1] [lindex $r 5] ] ]
      gren_info "\nRADEC=$radec\n\n"
      
  }
  
  
   proc ::tools_astrometry::extract_priam_result { file } {
   
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
      
      set id_img -1

      # faire une boule sur un mot clés ! CDELT1

      while {[gets $chan line] >= 0} {

         set a [split $line "="]
         set key [lindex $a 0]
         set val [lindex $a 1]
         #gren_info "$key=$val\n"
          
         if {$key=="RA"} {
            # Debut image
            incr id_img
            set catascience($id_img) {}
            set cataref($id_img) {}
         }
         
         for {set k 0 } { $k<$n } {incr k} {
            set kwd [lindex $astrom(kwds) $k]
            if {$kwd==$key} {
               set type [lindex $astrom(types) $k]
               set unit [lindex $astrom(units) $k]
               
               set comment [lindex $astrom(comments) $k]
               #gren_info "KWD: [lindex [buf$::audace(bufNo) getkwd  $kwd] 1] == $val \n"
               #buf$::audace(bufNo) setkwd [list $kwd $val $type $unit $comment]
            }
         }
         
         if {$key=="CATA_VALUES"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            lappend catascience($id_img) [list $name $sour]
         }
         if {$key=="CATA_REF"} {
            set name  [lindex $val 0]
            set sour  [lindex $val 1]
            lappend cataref($id_img) [list $name $sour]
         }
         
      }
      close $chan


   # sur une seule image -> current_listsources

      gren_info "[::manage_source::get_fields_from_sources $tools_astrometry::current_listsources] \n"

   # A FAIRE  : nettoyage des astrometrie de current_listsources
      ::tools_astrometry::clean_astrom 
      
   # Insertion des resultats dans current_listsources

      set fieldsastroid [list "ASTROID" {} [list "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" \
                                           "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" \
                                           "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" \
                                           "mag" "err_mag" ] ]
                                           
      set id_img 0
      foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {
         
         set ::tools_astrometry::current_listsources [::bddimages_liste::lget $::tools_astrometry::current_image "listsources"]


         set fields [lindex $::tools_astrometry::current_listsources 0]
         lappend fields $fieldsastroid

         foreach {n val} $catascience($id_img) {

            gren_info "catascience : $n $val\n"
            set cpt 0
            set sources [lindex $::tools_astrometry::current_listsources 1]
            foreach s $sources {

               foreach cata $s {
                  if {[lindex $cata 0] == $::tools_astrometry::science} {
                     set name [::manage_source::naming $s $::tools_astrometry::science]
                     if {$n==$name} {
                        #gren_info "NAME=$name\n"
                        set ra      [expr [lindex $val 0] ]
                        set dec     [lindex $val 1]
                        set res_ra  [lindex $val 2]
                        set res_dec [lindex $val 3]
                        set omc_ra  [expr $ra - [lindex [lindex $cata 1] 0]]
                        set omc_dec [expr $dec - [lindex [lindex $cata 1] 1]]
                        set flag    "S"

                        #gren_info "NAME=$name $ra $dec $res_ra $res_dec $omc_ra $omc_dec $flag\n"
                        set s [::tools_astrometry::set_astrom_to_source $s $ra $dec $res_ra $res_dec $omc_ra $omc_dec $flag]
                        set sources [lreplace $sources $cpt $cpt $s]
                        set ::tools_astrometry::current_listsources [list $fields $sources]

                     }

                  }

               }

               incr cpt
            }


         }

         foreach {n val} $cataref($id_img) {

            set cpt 0
            set sources [lindex $::tools_astrometry::current_listsources 1]
            foreach s $sources {
               foreach cata $s {
                  #gren_info "CATA = [lindex $cata 0]\n"
                  if {[lindex $cata 0] == $::tools_astrometry::reference} {
                     set name [::manage_source::naming $s $::tools_astrometry::reference]
                     if {$n==$name} {
                        #gren_info "NAME=$name\n"                     
                        set ra      [lindex [lindex $cata 1] 0]
                        set dec     [lindex [lindex $cata 1] 1]
                        set res_ra  [lindex $val 0]
                        set res_dec [lindex $val 1]
                        set omc_ra  [expr $ra - [lindex [lindex $cata 1] 0]]
                        set omc_dec [expr $dec - [lindex [lindex $cata 1] 1]]
                        set flag    "R"

                        #gren_info "NAME=$name $ra $dec $res_ra $res_dec $omc_ra $omc_dec $flag\n"                     
                        set s [::tools_astrometry::set_astrom_to_source $s $ra $dec $res_ra $res_dec $omc_ra $omc_dec $flag]
                        set sources [lreplace $sources $cpt $cpt $s]
                        set ::tools_astrometry::current_listsources [list $fields $sources]
                     }
                  }
               }
               incr cpt
            }
         }


         gren_info "SRol=[ ::manage_source::get_nb_sources_rollup $::tools_astrometry::current_listsources]\n"
         if {[::bddimages_liste::lexist $::tools_astrometry::current_image "listsources" ]==0} {
            gren_info "Listesource n existe pas\n"
            set ::tools_astrometry::current_image [::bddimages_liste::ladd $::tools_astrometry::current_image "listsources" $::tools_astrometry::current_listsources ]
         } else {
            gren_info "Listesource existe\n"
            set ::tools_astrometry::current_image [::bddimages_liste::lupdate $::tools_astrometry::current_image "listsources" $::tools_astrometry::current_listsources ]
         }
         
         set ::tools_astrometry::img_list [lreplace $::tools_astrometry::img_list $id_img $id_img $::tools_astrometry::current_image]
         incr id_img



      }


   gren_info "SRol=[ ::manage_source::get_nb_sources_rollup $::tools_astrometry::current_listsources]\n"
   #gren_info "ASTROIDS=[::manage_source::extract_sources_by_catalog $::tools_astrometry::current_listsources ASTROID]\n"
   #gren_info "LISTSOURCES=$::tools_astrometry::current_listsources\n"

   # Ecriture des resultats dans un fichier 
      

       
        
   }
   
   
# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" 
   proc ::tools_astrometry::set_astrom_to_source { s ra dec res_ra res_dec omc_ra omc_dec flag } {
   
      set pass "no"
      
      set stmp {}
      foreach cata $s {
         if {[lindex $cata 0] == "ASTROID"} {
            set pass "yes"
            set astroid [lindex $cata 2]
            set astroid [lreplace $astroid 14 20 $ra $dec $res_ra $res_dec $omc_ra $omc_dec $flag]
            lappend stmp [list "ASTROID" {} $astroid]
         } else {
            lappend stmp $cata
         }
      }
      return $stmp
   }
   
   proc ::tools_astrometry::clean_astrom {  } {
   
   }
   
   proc ::tools_astrometry::save { form } {

      global bddconf audace
  
      gren_info "FORMAT:$form\n"
      
      # Fichier au format TXT 
      if {$form=="TXT"} {
         set fileres [ file join $audace(rep_travail) priam.txt ]
         set chan0 [open $fileres w]
         foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {

            gren_info "IMG: $::tools_astrometry::current_image\n"

            set tabkey      [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]
            set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
            set exposure    [lindex [::bddimages_liste::lget $tabkey EXPOSURE ] 1]
            set ::tools_astrometry::current_listsources [::bddimages_liste::lget $::tools_astrometry::current_image "listsources"]
            set datem $date

            foreach s [lindex $::tools_astrometry::current_listsources 1] {
               foreach cata $s {
                  if {[lindex $cata 0] == "ASTROID"} {
                     set name [::manage_source::naming $s $::tools_astrometry::science]
                     set flagastrom [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "flagastrom"]   1] ]
                     if {$flagastrom=="S"} {
                        set ra      [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "ra"]   1] ]
                        set dec     [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "dec"]   1] ]
                        set res_ra  [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "res_ra"]   1] ]
                        set res_dec [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "res_dec"]   1] ]
                        set omc_ra  [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "omc_ra"]   1] ]
                        set omc_dec [string trim [lindex [::bddimages_liste::lget [lindex $cata 0] "omc_dec"]   1] ]
                        puts $chan0 "$name $datem $ra $dec $res_ra $res_dec $omc_ra $omc_dec"
                     }
                  }
               }
            }
         }
         close $chan0
      }

      # Fichier au format MPC 
      if {$form=="MPC"} {
      }

      # Fichier au format CATA 
      if {$form=="CATA"} {

##############
         set fileres [ file join $audace(rep_travail) priam.txt ]
         set chan0 [open $fileres w]
         foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {
            set tabkey      [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]
            set ::tools_astrometry::current_listsources [::bddimages_liste::lget $::tools_astrometry::current_image "listsources"]

            set cataxml [::tools_cata::get_catafilename $::tools_astrometry::current_image "TMP" ]
            
            gren_info "cataxml = $cataxml\n"

            gren_info "Rol=[ ::manage_source::get_nb_sources_rollup $::tools_astrometry::current_listsources]\n"
            set votable [::votableUtil::list2votable $::tools_astrometry::current_listsources $tabkey]

#            gren_info "votable = $votable\n"

            # Sauvegarde du cata XML
            #gren_info "Enregistrement du cata XML: $cataxml\n"
            
            set fxml [open $cataxml "w"]
            puts $fxml $votable
            close $fxml

            return

            set err [ catch { insertion_solo $cataxml } msg ]
            gren_info "** INSERTION_SOLO = $err $msg\n"

            set cataexist [::bddimages_liste::lexist $::tools_astrometry::current_image "cataexist"]
            if {$cataexist==0} {
               set ::tools_astrometry::current_image [::bddimages_liste::ladd $::tools_astrometry::current_image "cataexist" 1]
            } else {
               set ::tools_astrometry::current_image [::bddimages_liste::lupdate $::tools_astrometry::current_image "cataexist" 1]
            }
         }
##############


      }
   
   }

# Fin de Classe
}

