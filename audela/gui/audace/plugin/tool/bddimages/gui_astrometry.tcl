namespace eval gui_astrometry {



   proc ::gui_astrometry::inittoconf {  } {

      global bddconf, conf
      set ::tools_astrometry::science   "SKYBOT"
      set ::tools_astrometry::reference "UCAC3"
      set ::tools_astrometry::delta 15
      set ::tools_astrometry::treshold 5
      set ::gui_astrometry::factor 1000

      if {! [info exists ::tools_astrometry::ifortlib] } {
         if {[info exists conf(bddimages,astrometry,priam,ifortlib)]} {
            set ::tools_astrometry::ifortlib $conf(bddimages,astrometry,priam,ifortlib)
         } else {
            set ::tools_astrometry::ifortlib "/opt/intel/lib/ia32"
         }
      }

      if {! [info exists ::tools_astrometry::rapport_uai_code] } {
         if {[info exists conf(bddimages,astrometry,rapport,uai_code)]} {
            set ::tools_astrometry::rapport_uai_code $conf(bddimages,astrometry,rapport,uai_code)
         } else {
            set ::tools_astrometry::rapport_uai_code ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_uai_location] } {
         if {[info exists conf(bddimages,astrometry,rapport,uai_location)]} {
            set ::tools_astrometry::rapport_uai_location $conf(bddimages,astrometry,rapport,uai_location)
         } else {
            set ::tools_astrometry::rapport_uai_location ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_rapporteur] } {
         if {[info exists conf(bddimages,astrometry,rapport,rapporteur)]} {
            set ::tools_astrometry::rapport_rapporteur $conf(bddimages,astrometry,rapport,rapporteur)
         } else {
            set ::tools_astrometry::rapport_rapporteur ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_mail] } {
         if {[info exists conf(bddimages,astrometry,rapport,mail)]} {
            set ::tools_astrometry::rapport_mail $conf(bddimages,astrometry,rapport,mail)
         } else {
            set ::tools_astrometry::rapport_mail ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_observ] } {
         if {[info exists conf(bddimages,astrometry,rapport,observ)]} {
            set ::tools_astrometry::rapport_observ $conf(bddimages,astrometry,rapport,observ)
         } else {
            set ::tools_astrometry::rapport_observ ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_reduc] } {
         if {[info exists conf(bddimages,astrometry,rapport,reduc)]} {
            set ::tools_astrometry::rapport_reduc $conf(bddimages,astrometry,rapport,reduc)
         } else {
            set ::tools_astrometry::rapport_reduc ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_instru] } {
         if {[info exists conf(bddimages,astrometry,rapport,instru)]} {
            set ::tools_astrometry::rapport_instru $conf(bddimages,astrometry,rapport,instru)
         } else {
            set ::tools_astrometry::rapport_instru ""
         }
      }
      if {! [info exists ::tools_astrometry::rapport_cata] } {
         if {[info exists conf(bddimages,astrometry,rapport,cata)]} {
            set ::tools_astrometry::rapport_cata $conf(bddimages,astrometry,rapport,cata)
         } else {
            set ::tools_astrometry::rapport_cata ""
         }
      }

     set ::tools_astrometry::rapport_desti "mpc@cfa.harvard.edu"



   }




   proc ::gui_astrometry::charge_list { img_list } {

     catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }

      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
      
      ::gui_astrometry::charge_solution_astrometrique
      ::gui_astrometry::charge_element_rapport
      

   }











#      set astrom(kwds)     {RA       DEC       CRPIX1      CRPIX2      CRVAL1       CRVAL2       CDELT1      CDELT2      CROTA2      CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN       PIXSIZE1       PIXSIZE2        CATA_PVALUE        EQUINOX       CTYPE1        CTYPE2      LONPOLE                                        CUNIT1                       CUNIT2                       }
#      set astrom(units)    {deg      deg       pixel       pixel       deg          deg          deg/pixel   deg/pixel   deg         deg/pixel     deg/pixel     deg/pixel     deg/pixel     m            um             um              percent            no            no            no          deg                                            no                           no                           }
#      set astrom(types)    {double   double    double      double      double       double       double      double      double      double        double        double        double        double       double         double          double             string        string        string      double                                         string                       string                       }
#      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included" "Pvalue of astrometric reduction" "System of equatorial coordinates" "Gnomonic projection" "Gnomonic projection" "Long. of the celest.NP in native coor.syst."  "Angles are degrees always"  "Angles are degrees always"  }

   proc ::gui_astrometry::charge_solution_astrometrique {  } {

      set id_current_image 0
      ::tools_astrometry::set_fields_astrom astrom
      set n [llength $astrom(kwds)]

      foreach current_image $::tools_cata::img_list {
         
         incr id_current_image

         set ::tools_cata::new_astrometry($id_current_image) ""
         
         # Tabkey
         set tabkey [::bddimages_liste::lget $current_image "tabkey"]
         
         for {set k 0 } { $k<$n } {incr k} {

            set kwd [lindex $astrom(kwds) $k]
            foreach key $tabkey {
            
               if {[string equal -nocase [lindex $key 0] $kwd] } {
                  set type [lindex $astrom(types) $k]
                  set unit [lindex $astrom(units) $k]
                  set comment [lindex $astrom(comments) $k]
                  set val [lindex [lindex $key 1] 1]
                  lappend ::tools_cata::new_astrometry($id_current_image) [list $kwd $val $type $unit $comment]
               }
            }
         }
      }

   }












   proc ::gui_astrometry::fermer {  } {

      global conf
      set conf(bddimages,astrometry,priam,ifortlib)        $::tools_astrometry::ifortlib
      set conf(bddimages,astrometry,rapport,uai_code)      $::tools_astrometry::rapport_uai_code
      set conf(bddimages,astrometry,rapport,uai_location)  $::tools_astrometry::rapport_uai_location
      set conf(bddimages,astrometry,rapport,rapporteur)    $::tools_astrometry::rapport_rapporteur
      set conf(bddimages,astrometry,rapport,mail)          $::tools_astrometry::rapport_mail
      set conf(bddimages,astrometry,rapport,observ)        $::tools_astrometry::rapport_observ
      set conf(bddimages,astrometry,rapport,reduc)         $::tools_astrometry::rapport_reduc
      set conf(bddimages,astrometry,rapport,instru)        $::tools_astrometry::rapport_instru
      set conf(bddimages,astrometry,rapport,cata)          $::tools_astrometry::rapport_cata

      destroy $::gui_astrometry::fen
      #::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      #::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark

   }






#tabval($name,$dateiso) [list $ar $ra $dec $res_ra $res_dec $ecart $mag]
#tabfield(sources,$name) $dateiso
#tabfield(science,$name) $dateiso
#tabfield(ref,$name) $dateiso
#tabfield(date,$dateiso) $name





# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" "name"
   proc ::gui_astrometry::see_residus {  } {

      set id_current_image 1
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

         set ::tools_cata::current_listsources [::bddimages_liste::lget $::tools_cata::current_image "listsources"]
         set ::tools_cata::current_listsources [::manage_source::extract_sources_by_catalog $::tools_cata::current_listsources "ASTROID"]
         #gren_info "Rolextr=[ ::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

         #::manage_source::imprim_sources  $::tools_cata::current_listsources "ASTROID"

         foreach s [lindex $::tools_cata::current_listsources 1] {
            foreach cata $s {
            
               if {[lindex $cata 0] == $::tools_astrometry::science} {
                  set comm [lindex $cata 1]
                  set ra      [lindex $comm 0]  
                  set dec     [lindex $comm 1]
                  affich_un_rond $ra $dec "green" 1
               }
               if {[lindex $cata 0] == $::tools_astrometry::reference} {
                  set comm [lindex $cata 1]
                  set ra      [lindex $comm 0]  
                  set dec     [lindex $comm 1]
                  affich_un_rond $ra $dec "yellow" 1
               }
            
               if {[lindex $cata 0] == "ASTROID"} {
                  set astroid [lindex $cata 2]
                  
                  set flagastrom  [lindex $astroid 20]  
                  set ra      [lindex $astroid 14]  
                  set dec     [lindex $astroid 15]   
                  set res_ra  [lindex $astroid 16]  
                  set res_dec [lindex $astroid 17]  
                  set omc_ra  [lindex $astroid 18]   
                  set omc_dec [lindex $astroid 19]  
                  set color "red"
                  if {$flagastrom=="S"} { set color "green"}
                  if {$flagastrom=="R"} { set color "yellow"}
                  affich_vecteur $ra $dec $res_ra $res_dec $::gui_astrometry::factor $color
                  #gren_info "vect! $ra $dec $res_ra $res_dec $::gui_astrometry::factor $color\n"
               }
            }
         }
         
         incr id_current_image
      }

   
   }











   proc ::gui_astrometry::cmdButton1Click_srpt { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 0]
         gren_info "srpt name = $name \n"

         # Construit la table enfant
         $::gui_astrometry::sret delete 0 end
         foreach date $::tools_astrometry::listref($name) {
            $::gui_astrometry::sret insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 2 $date]
         }
         
         # Affiche un rond sur la source
         ::gui_cata::voir_sxpt $::gui_astrometry::srpt

         break
      }
   }



   proc ::gui_astrometry::cmdButton1Click_sspt { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 0]
         gren_info "sspt name = $name \n"

         # Construit la table enfant
         $::gui_astrometry::sset delete 0 end
         foreach date $::tools_astrometry::listscience($name) {
            $::gui_astrometry::sset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 2 $date]
         }

         # Affiche un rond sur la source
         ::gui_cata::voir_sxpt $::gui_astrometry::sspt

         break
      }
   }

   proc ::gui_astrometry::cmdButton1Click_dspt { w args } {

      foreach select [$w curselection] {
         set date [lindex [$w get $select] 0]
         gren_info "dspt date = $date \n"

         # Construit la table enfant
         $::gui_astrometry::dset delete 0 end
         foreach name $::tools_astrometry::listdate($date) {
            $::gui_astrometry::dset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 1 $name]
         }

         break
      }
   }


   proc ::gui_astrometry::cmdButton1Click_dset { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 1]
         gren_info "dset name = $name \n"

         # Affiche un rond sur la source
         ::gui_cata::voir_dset $::gui_astrometry::dset

         break
      }
   }

   
   
   proc ::gui_astrometry::cmdButton1Click_dwpt { w args } {

      foreach select [$w curselection] {
         set date [lindex [$w get $select] 0]
         
         gren_info "date = $date \n"
         gren_info "Id img = $::tools_astrometry::date_to_id($date) \n"
         set id $::tools_astrometry::date_to_id($date)
         set tabkey [::bddimages_liste::lget [lindex $::tools_cata::img_list [expr $id -1] ] "tabkey"]
         set datei   [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         gren_info "date = $datei \n"
         #gren_info "tabkey = $::tools_cata::new_astrometry($id) \n"

         ::gui_astrometry::voir_dwet %w
         
         $::gui_astrometry::dwet delete 0 end
         foreach val $::tools_cata::new_astrometry($id) {
            $::gui_astrometry::dwet insert end $val
         }
         
         break
      }
   }









      #MPCCON1 F.Vachier, IMCCE, Obs de Paris,77 Av Denfert Rochereau 75014 Paris France
      #MPCCON2 [vachier@imcce.fr]
      #MPCOBS F.Vachier, A.Kryszczynska
      #MPCMEA F.Vachier
      #MPCTEL 1.05-m f/12 reflector + CCD
      #MPCNET USNO-A2
      #MPCACK Batch 003
      #MPCAC2 vachier@imcce.fr
      #MPCNUM 9


      #COD 586
      #CON F.Vachier, IMCCE, Obs de Paris,77 Av Denfert Rochereau 75014 Paris France
      #CON [vachier@imcce.fr]
      #OBS F.Vachier, A.Kryszczynska
      #MEA F.Vachier
      #TEL 1.05-m f/12 reflector + CCD
      #NET USNO-A2
      #ACK Batch 003
      #AC2 vachier@imcce.fr
      #NUM 9

    #  ::tools_astrometry::rapport_uai_code
    #  ::tools_astrometry::rapport_uai_location
    #  ::tools_astrometry::rapport_rapporteur
    #  ::tools_astrometry::rapport_mail
    #  ::tools_astrometry::rapport_observ
    #  ::tools_astrometry::rapport_reduc
    #  ::tools_astrometry::rapport_instru
    #  ::tools_astrometry::rapport_cata
    #  ::tools_astrometry::rapport_batch
    #  ::tools_astrometry::rapport_nb



   proc ::gui_astrometry::charge_element_rapport { } {

      set current_image [lindex $::tools_cata::img_list 0]
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set datei  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]

      set ::tools_astrometry::rapport_uai_code  [string trim [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1] ]
      set ::tools_astrometry::rapport_observ    [string trim [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1] ]

      set ex [::bddimages_liste::lexist $tabkey "INSTRUME"]
      if {$ex != 0} {
         set ::tools_astrometry::rapport_instru [string trim [lindex [::bddimages_liste::lget $tabkey "INSTRUME"] 1] ]
      }

      # Nombre de positions rapportées
      set cpt 0
      set l [array get ::tools_astrometry::listscience]
      foreach {name y} $l {
         foreach date $::tools_astrometry::listscience($name) {
            incr cpt
         }
      }
      set ::tools_astrometry::rapport_nb $cpt       


   }








#::bddimages::ressource ; ::gui_astrometry::rapport

   proc ::gui_astrometry::create_rapport {  } {


      # Batch
      set ::tools_astrometry::rapport_batch [clock format [clock scan now] -format "Audela BDI %Y-%m-%dT%H:%M:%S %Z"]

      # Liste des catalogue de reference
      set l [array get ::tools_astrometry::listref]
      set clist ""
      foreach {name y} $l {
         set cata [lindex [split $name "_"] 0]
         set pos [lsearch $clist $cata]
         if {$pos==-1} {
            lappend clist $cata
         }
      }
      set ::tools_astrometry::rapport_cata ""
      set separ ""
      foreach cata $clist {
         append ::tools_astrometry::rapport_cata "${separ}${cata}"
         if {$separ==""} {set separ " "}
      }

      # Generation des rapports
      ::gui_astrometry::create_rapport_txt
      ::gui_astrometry::create_rapport_mpc

   }

#::bddimages::ressource ; ::gui_astrometry::create_rapport_mpc
   proc ::gui_astrometry::create_rapport_mpc {  } {

      $::gui_astrometry::rapport_mpc delete 0.0 end 

      $::gui_astrometry::rapport_mpc insert end  "#COD $::tools_astrometry::rapport_uai_code \n"
      $::gui_astrometry::rapport_mpc insert end  "#CON $::tools_astrometry::rapport_rapporteur \n"
      $::gui_astrometry::rapport_mpc insert end  "#CON $::tools_astrometry::rapport_mail \n"
      $::gui_astrometry::rapport_mpc insert end  "#CON Software Reduction : Audela Bddimages Priam \n"
      $::gui_astrometry::rapport_mpc insert end  "#OBS $::tools_astrometry::rapport_observ \n"
      $::gui_astrometry::rapport_mpc insert end  "#MEA $::tools_astrometry::rapport_reduc \n"
      $::gui_astrometry::rapport_mpc insert end  "#TEL $::tools_astrometry::rapport_instru \n"
      $::gui_astrometry::rapport_mpc insert end  "#NET $::tools_astrometry::rapport_cata \n"
      $::gui_astrometry::rapport_mpc insert end  "#ACK Batch $::tools_astrometry::rapport_batch \n"
      $::gui_astrometry::rapport_mpc insert end  "#AC2 $::tools_astrometry::rapport_mail \n"
      $::gui_astrometry::rapport_mpc insert end  "#NUM $::tools_astrometry::rapport_nb \n"

#      $::gui_astrometry::rapport_mpc insert end  "         1         2         3         4         5         6         7         8\n"
#      $::gui_astrometry::rapport_mpc insert end  "12345678901234567890123456789012345678901234567890123456789012345678901234567890\n"

      set form "%14s%s%17s%12s%12s         %5s       %3s\n"

      set l [array get ::tools_astrometry::listscience]
      foreach {name y} $l {
         gren_info "$name = $y\n"
         foreach date $::tools_astrometry::listscience($name) {

            set object_name "274138 "
            set flag "C"
            set obsuai "586"

            set alpha   [lindex $::tools_astrometry::tabval($name,$date) 6]
            set delta   [lindex $::tools_astrometry::tabval($name,$date) 7]
            set mag     [lindex $::tools_astrometry::tabval($name,$date) 8]
            if {$mag <10.0} {set mag "0$mag"}
            set mag     [format "%+.2f" $mag ]
            set ra_hms  [::tools_astrometry::convert_mpc_hms $alpha]
            set dec_dms [::tools_astrometry::convert_mpc_dms $delta]
            set datempc [::tools_astrometry::convert_mpc_date $date]
            
            
            set txt [format $form $object_name $flag $datempc $ra_hms $dec_dms $mag $obsuai]
            $::gui_astrometry::rapport_mpc insert end  $txt
         }
      }
      
      $::gui_astrometry::rapport_mpc insert end  "\n\n\n"


   }






   proc ::gui_astrometry::create_rapport_txt {  } {

      # ::bddimages::ressource
      $::gui_astrometry::rapport_txt delete 0.0 end 

      $::gui_astrometry::rapport_txt insert end  "------------------------------------------------------------------------------------------------------------------------------------\n"

      $::gui_astrometry::rapport_txt insert end  "#IAU CODE    : $::tools_astrometry::rapport_uai_code \n"
      $::gui_astrometry::rapport_txt insert end  "#Subscriber  : $::tools_astrometry::rapport_rapporteur \n"
      $::gui_astrometry::rapport_txt insert end  "#MAIL        : $::tools_astrometry::rapport_mail \n"
      $::gui_astrometry::rapport_txt insert end  "#Software    : Audela Bddimages Priam \n"
      $::gui_astrometry::rapport_txt insert end  "#Observers   : $::tools_astrometry::rapport_observ \n"
      $::gui_astrometry::rapport_txt insert end  "#Reduction   : $::tools_astrometry::rapport_reduc \n"
      $::gui_astrometry::rapport_txt insert end  "#Instrument  : $::tools_astrometry::rapport_instru \n"
      $::gui_astrometry::rapport_txt insert end  "#Ref.Catalog : $::tools_astrometry::rapport_cata \n"
      $::gui_astrometry::rapport_txt insert end  "#Batch       : $::tools_astrometry::rapport_batch \n"
      $::gui_astrometry::rapport_txt insert end  "#Numb.Pos.   : $::tools_astrometry::rapport_nb \n"

      $::gui_astrometry::rapport_txt insert end  "------------------------------------------------------------------------------------------------------------------------------------\n"








      set l [array get ::tools_astrometry::listscience]
      set nummax 0
      foreach {name y} $l {
         set num [string length $name]
         if {$num>$nummax} {set nummax $num}
      }

      set form "%-${nummax}s  %-23s  %-10s  %-11s  %-6s  %-6s  %-11s  %-12s  %-6s  %-6s\n"

      set name    "Object"
      set date    "Mid-Date"
      set ra_hms  "Right Asc."
      set dec_dms "Declination"
      set res_a   "Err RA"
      set res_d   "Err De"
      set alpha   "Right Asc."
      set delta   " Declination"
      set mag     " Mag"
      set err_mag " ErrMag"
      set txt [format $form $name $date $ra_hms $dec_dms $res_a $res_d $alpha $delta $mag $err_mag ]
      $::gui_astrometry::rapport_txt insert end  $txt
      set name    ""
      set date    "iso"
      set ra_hms  "hms"
      set dec_dms "dms"
      set rho     "arcsec"
      set res_a   "arcsec"
      set res_d   "arcsec"
      set alpha   "deg"
      set delta   " deg"
      set mag     ""
      set err_mag ""
      set txt [format $form $name $date $ra_hms $dec_dms $res_a $res_d $alpha $delta $mag $err_mag]
      $::gui_astrometry::rapport_txt insert end  $txt

      $::gui_astrometry::rapport_txt insert end  "------------------------------------------------------------------------------------------------------------------------------------\n"

      foreach {name y} $l {
         gren_info "$name = $y\n"
         foreach date $::tools_astrometry::listscience($name) {
            gren_info "tabval $nummax = $::tools_astrometry::tabval($name,$date)\n"

            set rho     [format "%.4f" [lindex $::tools_astrometry::tabval($name,$date) 3] ]
            set res_a   [format "%.4f" [lindex $::tools_astrometry::tabval($name,$date) 4] ]
            set res_d   [format "%.4f" [lindex $::tools_astrometry::tabval($name,$date) 5] ]
            set alpha   [format "%.8f" [lindex $::tools_astrometry::tabval($name,$date) 6] ]
            set delta   [format "%+.8f" [lindex $::tools_astrometry::tabval($name,$date) 7] ]
            set mag     [format "%.3f" [lindex $::tools_astrometry::tabval($name,$date) 8] ]
            set err_mag [format "%.3f" [lindex $::tools_astrometry::tabval($name,$date) 9] ]
            set ra_hms  [mc_angle2hms [lindex $::tools_astrometry::tabval($name,$date) 6] 360 zero 1 auto string]
            set dec_dms [mc_angle2dms [lindex $::tools_astrometry::tabval($name,$date) 7] 90 zero 1 + string]

            set txt [format $form $name $date $ra_hms $dec_dms $res_a $res_d $alpha $delta $mag $err_mag]
            $::gui_astrometry::rapport_txt insert end  $txt
         }
      }

      return

   }



   proc ::gui_astrometry::send_email { } {
      
      set someone "fv@imcce.fr"
      set recipient_list "fv@imcce.fr"
      set cc_list ""
      set subject "BATCH"
      set body    "body"
      
      set msg {From: someone}
      append msg \n "To: " [join $recipient_list ,]
      append msg \n "Cc: " [join $cc_list ,]
      append msg \n "Subject: $subject"
      append msg \n\n $body
gren_info "$msg\n"
      exec /usr/lib/sendmail -oi -t << $msg


   }

proc send_simple_message {originator recipient email_server subject body} {

    package require smtp
    package require mime
gren_info "ici\n"
    set token [mime::initialize -canonical text/plain -string $body]
gren_info "la\n"
    #smtp::sendmessage $token -servers $email_server -header [list From "$originator"] -header [list To "$recipient"] -header [list Subject "$subject"] -header [list cc ""]  -header [list Bcc ""]
    smtp::sendmessage $token -header [list From "$originator"] -header [list To "$recipient"] -header [list Subject "$subject"] -header [list cc ""]  -header [list Bcc ""]
gren_info "ici\n"
    mime::finalize $token
gren_info "la\n"
}


#    set gren(email,originator) "Test"
#    set adresse  fv@imcce.fr 
#    set gren(email,email_server) smtp.free.fr
#    set email_subject "sujet test"
#    set texte00 "Bonjour. Fais-moi un reply que c'est OK."

# send_simple_message $gren(email,originator) $adresse $gren(email,email_server) "$email_subject" "$texte00"





   proc ::gui_astrometry::create_list_denom {  } {

      gren_info "toto\n"

      set l [array get ::tools_astrometry::listscience]
      
      set namelist ""
      foreach {name y} $l {
         lappend namelist $name
      }
      
      foreach nameall $namelist {
         gren_info "$nameall\n"
         set sp [split $nameall "_"]
         set cata [lindex $sp 0]
         if {$cata=="SKYBOT"} {
            gren_info "$cata\n"

            set id [lindex $sp 1]
            set sp [lreplace $sp 0 1 ""]
            set name [string trim [join $sp " "] ]
            gren_info "$id\n"
            gren_info "$name\n"
            
            frame  $::gui_astrometry::zlist.$nameall -borderwidth 0 -cursor arrow -relief groove
            pack $::gui_astrometry::zlist.$nameall  -in $::gui_astrometry::zlist -side top -expand 0 -fill x -padx 2 -pady 5

            label  $::gui_astrometry::zlist.$nameall.cata -text $cata -borderwidth 1 -width 10
            pack   $::gui_astrometry::zlist.$nameall.cata -in $::gui_astrometry::zlist.$nameall -side left -padx 3 -pady 1 -anchor w
            
         }
      }

   }





   proc ::gui_astrometry::affich_gestion {  } {
       
      gren_info "\n\n\n-----------\n"
      set tt0 [clock clicks -milliseconds]

      if {$::gui_astrometry::state_gestion == 0} {
         catch {destroy $::cata_gestion_gui::fen}
         gren_info "Chargement des fichiers XML\n"
         ::cata_gestion_gui::go $::tools_cata::img_list
         set ::gui_astrometry::state_gestion 1
      }

      if {[info exists ::cata_gestion_gui::state_gestion] && $::cata_gestion_gui::state_gestion == 1} {
         gren_info "Chargement depuis la fenetre de gestion des sources\n"
         ::gui_astrometry::affich_catalist
      } else {
         catch {destroy $::cata_gestion_gui::fen}
         gren_info "Chargement des fichiers XML\n"
         ::cata_gestion_gui::go $::tools_cata::img_list
      }

      focus $::gui_astrometry::fen

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement complet en $tt sec \n"

      return

   }


   proc ::gui_astrometry::affich_catalist {  } {

      ::tools_astrometry::affich_catalist

      set tt0 [clock clicks -milliseconds]

      $::gui_astrometry::srpt delete 0 end
      $::gui_astrometry::sret delete 0 end
      $::gui_astrometry::sspt delete 0 end
      $::gui_astrometry::sset delete 0 end
      $::gui_astrometry::dspt delete 0 end
      $::gui_astrometry::dset delete 0 end
      $::gui_astrometry::dwpt delete 0 end
 
      foreach name [array names ::tools_astrometry::listref] {
         $::gui_astrometry::srpt insert end $::tools_astrometry::tabref($name)
      }

      foreach name [array names ::tools_astrometry::listscience] {
         $::gui_astrometry::sspt insert end $::tools_astrometry::tabscience($name)
      }

      foreach date [array names ::tools_astrometry::listdate] {
         $::gui_astrometry::dspt insert end $::tools_astrometry::tabdate($date)
         $::gui_astrometry::dwpt insert end $::tools_astrometry::tabdate($date)
      }

      # Tri les resultats en fonction de la colonne Rho
      $::gui_astrometry::srpt sortbycolumn 2 -decreasing
      $::gui_astrometry::sspt sortbycolumn 2 -decreasing

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage des resultats in $tt sec \n"


   }


   proc ::gui_astrometry::go_priam {  } {

      ::tools_astrometry::init_priam
      ::tools_astrometry::go_priam
      ::gui_astrometry::affich_catalist

   }



   proc ::gui_astrometry::priam_to_catalist {  } {

      ::tools_astrometry::affich_priam

      set tt0 [clock clicks -milliseconds]

      $::gui_astrometry::srpt delete 0 end
      $::gui_astrometry::sret delete 0 end
      $::gui_astrometry::sspt delete 0 end
      $::gui_astrometry::sset delete 0 end
      $::gui_astrometry::dspt delete 0 end
      $::gui_astrometry::dset delete 0 end
      $::gui_astrometry::dwpt delete 0 end
 
      foreach name [array names ::tools_astrometry::listref] {
         $::gui_astrometry::srpt insert end $::tools_astrometry::tabref($name)
      }

      foreach name [array names ::tools_astrometry::listscience] {
         $::gui_astrometry::sspt insert end $::tools_astrometry::tabscience($name)
      }

      foreach date [array names ::tools_astrometry::listdate] {
         $::gui_astrometry::dspt insert end $::tools_astrometry::tabdate($date)
         $::gui_astrometry::dwpt insert end $::tools_astrometry::tabdate($date)
      }

      
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage des resultats in $tt sec \n"

   }






   proc ::gui_astrometry::annul_save_images { } {
      $::gui_astrometry::fensav.appli.boutons.annul configure -state disabled
      set ::tools_astrometry::savannul 1
   }



   proc ::gui_astrometry::save_images { } {

      $::gui_astrometry::fen.appli.info.fermer configure -state disabled
      $::gui_astrometry::fen.appli.info.enregistrer configure -state disabled


      set ::tools_astrometry::savprogress 0
      set ::tools_astrometry::savannul 0

      set ::gui_astrometry::fensav .savprogress
      if { [winfo exists $::gui_astrometry::fensav] } {
         wm withdraw $::gui_astrometry::fensav
         wm deiconify $::gui_astrometry::fensav
         focus $::gui_astrometry::fensav
         return
      }
      
      toplevel $::gui_astrometry::fensav -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_astrometry::fensav ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_astrometry::fensav ] "+" ] 2 ]
      wm geometry $::gui_astrometry::fensav +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_astrometry::fensav 1 1
      wm title $::gui_astrometry::fensav "Enregistrement"
      wm protocol $::gui_astrometry::fensav WM_DELETE_WINDOW ""

      set frm $::gui_astrometry::fensav.appli
      
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_astrometry::fensav -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
      
         set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set    pf [ ttk::progressbar $data.p -variable ::tools_astrometry::savprogress -orient horizontal -length 200 -mode determinate]
             pack   $pf -in $data -side top

         set data  [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $data.annul -state active -text "Annuler" -relief "raised" \
                -command "::gui_astrometry::annul_save_images"
             pack   $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5


      update
      ::tools_astrometry::save_images   

      destroy $::gui_astrometry::fensav

      $::gui_astrometry::fen.appli.info.fermer configure -state normal
      $::gui_astrometry::fen.appli.info.enregistrer configure -state normal
   
   } 
   



   proc ::gui_astrometry::create_rapport_default {  } {

      ::tools_astrometry::rapport_uai_code
      ::tools_astrometry::rapport_uai_location
      ::tools_astrometry::rapport_rapporteur
      ::tools_astrometry::rapport_mail
      ::tools_astrometry::rapport_observ
      ::tools_astrometry::rapport_reduc
      ::tools_astrometry::rapport_instru
      ::tools_astrometry::rapport_cata

      #IAU_CODE
      #OBSERVER

      #COD 586
      #CON F.Vachier, IMCCE, Obs de Paris,77 Av Denfert Rochereau 75014 Paris France
      #CON [vachier@imcce.fr]
      #OBS F.Vachier, A.Kryszczynska
      #MEA F.Vachier
      #TEL 1.05-m f/12 reflector + CCD
      #NET USNO-A2
      #ACK Batch 003
      #AC2 vachier@imcce.fr
      #NUM 9

   } 






   proc ::gui_astrometry::setup { img_list } {

      global audace
      global bddconf


      ::gui_astrometry::inittoconf

      ::gui_astrometry::charge_list $img_list

      set ::gui_astrometry::state_gestion 0
      
      set loc_sources_par [list 0 "Name"              left  \
                                0 "Nb img"            right \
                                0 "\u03C1"            right \
                                0 "stdev \u03C1"      right \
                                0 "moy res \u03B1"    right \
                                0 "moy res \u03B4"    right \
                                0 "stdev res \u03B1"  right \
                                0 "stdev res \u03B4"  right \
                                0 "moy \u03B1"        right \
                                0 "moy \u03B4"        right \
                                0 "stdev \u03B1"      right \
                                0 "stdev \u03B4"      right \
                                0 "moy Mag"           right \
                                0 "stdev Mag"         right ]
      set loc_dates_enf   [list 0 "Id"                right \
                                0 "Date-obs"          left  \
                                0 "\u03C1"            right \
                                0 "res \u03B1"        right \
                                0 "res \u03B4"        right \
                                0 "\u03B1"            right \
                                0 "\u03B4"            right \
                                0 Mag                 right \
                                0 err_Mag             right ]
      set loc_dates_par   [list 0 "Date-obs"          left  \
                                0 "Nb ref"            right \
                                0 "\u03C1"            right \
                                0 "stdev \u03C1"      right \
                                0 "moy res \u03B1"    right \
                                0 "moy res \u03B4"    right \
                                0 "stdev res \u03B1"  right \
                                0 "stdev res \u03B4"  right \
                                0 "moy \u03B1"        right \
                                0 "moy \u03B4"        right \
                                0 "stdev \u03B1"      right \
                                0 "stdev \u03B4"      right \
                                0 "moy Mag"           right \
                                0 "stdev Mag"         right ]
      set loc_sources_enf [list 0 "Id"                right \
                                0 "Name"              left  \
                                0 "type"              center \
                                0 "\u03C1"            right \
                                0 "res \u03B1"        right \
                                0 "res \u03B4"        right \
                                0 "\u03B1"            right \
                                0 "\u03B4"            right \
                                0 Mag                 right \
                                0 err_Mag             right ]
      set loc_wcs_enf     [list 0 "Clés"              left \
                                0 "Valeur"            center  \
                                0 "type"              center \
                                0 "unité"             center \
                                0 "commentaire"       left ]
      
      set ::gui_astrometry::fen .astrometry
      if { [winfo exists $::gui_astrometry::fen] } {
         wm withdraw $::gui_astrometry::fen
         wm deiconify $::gui_astrometry::fen
         focus $::gui_astrometry::fen
         return
      }
      toplevel $::gui_astrometry::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_astrometry::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_astrometry::fen ] "+" ] 2 ]
      wm geometry $::gui_astrometry::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_astrometry::fen 1 1
      wm title $::gui_astrometry::fen "Astrometrie"
      wm protocol $::gui_astrometry::fen WM_DELETE_WINDOW "destroy $::gui_astrometry::fen"

      set frm $::gui_astrometry::fen.appli

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_astrometry::fen -anchor s -side top -expand yes -fill both  -padx 10 -pady 5

         #--- Cree un frame ifort
         set ifortlib [frame $frm.ifortlib -borderwidth 0 -cursor arrow -relief groove]
         pack $ifortlib -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
 
              label  $ifortlib.lab -text "ifort" -borderwidth 1
              pack   $ifortlib.lab -in $ifortlib -side left -padx 3 -pady 3 -anchor c
              entry  $ifortlib.val -relief sunken -textvariable ::tools_astrometry::ifortlib -width 30
              pack   $ifortlib.val -in $ifortlib -side left -padx 3 -pady 3 -anchor w


         #--- Cree un frame pour afficher bouton fermeture
         set actions [frame $frm.actions  -borderwidth 0 -cursor arrow -relief groove]
         pack $actions  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set ::gui_astrometry::gui_affich_gestion [button $actions.affich_gestion -text "Charge" -borderwidth 2 -takefocus 1 \
                 -relief "raised" \
                 -command "::gui_astrometry::affich_gestion"]
              pack $actions.affich_gestion -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_astrometry::gui_go_priam [button $actions.go_priam -text "Priam" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::go_priam"]
              pack $actions.go_priam -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              label  $actions.labv -text "Voir : " -borderwidth 1
              pack   $actions.labv -in $actions -side left -padx 3 -pady 3 -anchor c

              button $actions.clean -text "Clean" -borderwidth 2 -takefocus 1 \
                      -command "cleanmark"
              pack   $actions.clean -side left -anchor e -expand 0

              button $actions.residus -text "Residus" -borderwidth 2 -takefocus 1 \
                      -command "::gui_astrometry::see_residus"
              pack   $actions.residus -side left -anchor e -expand 0

              label  $actions.labf -text "facteur : " -borderwidth 1
              pack   $actions.labf -in $actions -side left -padx 3 -pady 3 -anchor c

              entry  $actions.factor -relief sunken -textvariable ::gui_astrometry::factor -width 5
              pack   $actions.factor -in $actions -side left -padx 3 -pady 3 -anchor w

              label  $actions.labe -text "Enregistrer : " -borderwidth 1
              pack   $actions.labe -in $actions -side left -padx 3 -pady 3 -anchor c

              button $actions.txt -text "TXT" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save TXT"
              pack   $actions.txt -side left -anchor e -expand 0

              button $actions.mpc -text "MPC" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save MPC"
              pack   $actions.mpc -side left -anchor e -expand 0

              button $actions.cata -text "CATA" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save CATA"
              pack   $actions.cata -side left -anchor e -expand 0


         #--- Cree un frame pour afficher les tables
         set tables [frame $frm.tables  -borderwidth 0 -cursor arrow -relief groove]
         pack $tables  -in $frm -anchor s -side top -expand 0  -padx 10 -pady 5

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
            
            pack [ttk::notebook $onglets.list] -expand yes -fill both 
 
            set sources [frame $onglets.list.sources]
            pack $sources -in $onglets.list -expand yes -fill both 
            $onglets.list add $sources -text "Sources"
            
            set dates [frame $onglets.list.dates]
            pack $dates -in $onglets.list -expand yes -fill both 
            $onglets.list add $dates -text "Dates"

            set graphes [frame $onglets.list.graphes]
            pack $graphes -in $onglets.list -expand yes -fill both 
            $onglets.list add $graphes -text "Graphes"

            set rapports [frame $onglets.list.rapports]
            pack $rapports -in $onglets.list -expand yes -fill both 
            $onglets.list add $rapports -text "Rapports"

            set onglets_sources [frame $sources.onglets -borderwidth 1 -cursor arrow -relief groove]
            pack $onglets_sources -in $sources -side top -expand yes -fill both -padx 10 -pady 5
 
                 pack [ttk::notebook $onglets_sources.list] -expand yes -fill both 
 
                 set references [frame $onglets_sources.list.references -borderwidth 1]
                 pack $references -in $onglets_sources.list -expand yes -fill both 
                 $onglets_sources.list add $references -text "References"

                 set sciences [frame $onglets_sources.list.sciences -borderwidth 1]
                 pack $sciences -in $onglets_sources.list -expand yes -fill both 
                 $onglets_sources.list add $sciences -text "Sciences"

            set onglets_dates [frame $dates.onglets -borderwidth 1 -cursor arrow -relief groove]
            pack $onglets_dates -in $dates -side top -expand yes -fill both -padx 10 -pady 5
 
                 pack [ttk::notebook $onglets_dates.list] -expand yes -fill both 
 
                 set sour [frame $onglets_dates.list.sources -borderwidth 1]
                 pack $sour -in $onglets_dates.list -expand yes -fill both 
                 $onglets_dates.list add $sour -text "Sources"

                 set wcs [frame $onglets_dates.list.wcs -borderwidth 1]
                 pack $wcs -in $onglets_dates.list -expand yes -fill both 
                 $onglets_dates.list add $wcs -text "WCS"

            set onglets_rapports [frame $rapports.onglets -borderwidth 1 -cursor arrow -relief groove]
            pack $onglets_rapports -in $rapports -side top -expand yes -fill both -padx 10 -pady 5
 
                 button $onglets_rapports.gen -text "Generer" -borderwidth 2 -takefocus 1 \
                         -command "::gui_astrometry::create_rapport"
                 pack   $onglets_rapports.gen -side top -anchor c -expand 0


                 pack [ttk::notebook $onglets_rapports.list] -expand yes -fill both 
 
                 set entetes [frame $onglets_rapports.list.entetes -borderwidth 1]
                 pack $entetes -in $onglets_rapports.list -expand yes -fill both 
                 $onglets_rapports.list add $entetes -text "Entetes"

                 set denom [frame $onglets_rapports.list.denom -borderwidth 1]
                 pack $denom -in $onglets_rapports.list -expand yes -fill both 
                 $onglets_rapports.list add $denom -text "Dénomination"

                 set mpc [frame $onglets_rapports.list.mpc -borderwidth 1]
                 pack $mpc -in $onglets_rapports.list -expand yes -fill both 
                 $onglets_rapports.list add $mpc -text "MPC"

                 set txt [frame $onglets_rapports.list.txt -borderwidth 1]
                 pack $txt -in $onglets_rapports.list -expand yes -fill both 
                 $onglets_rapports.list add $txt -text "TXT"


            # Sources - References Parent (par liste de source et moyenne)
            set srp [frame $onglets_sources.list.references.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $srp -in $onglets_sources.list.references -expand yes -fill both -side left

                 set ::gui_astrometry::srpt $srp.table
                 
                 tablelist::tablelist $::gui_astrometry::srpt \
                   -columns $loc_sources_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $srp.hsb set ] \
                   -yscrollcommand [ list $srp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $srp.hsb -orient horizontal -command [list $::gui_astrometry::srpt xview]
                 pack $srp.hsb -in $srp -side bottom -fill x
                 scrollbar $srp.vsb -orient vertical -command [list $::gui_astrometry::srpt yview]
                 pack $srp.vsb -in $srp -side left -fill y

                 menu $srp.popupTbl -title "Actions"
                     $srp.popupTbl add command -label "Supprimer de toutes les images" \
                         -command {::gui_cata::unset_srpt; ::gui_astrometry::affich_gestion}

                 #--- bindings
                 bind $::gui_astrometry::srpt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_srpt %W ]
                 bind [$::gui_astrometry::srpt bodypath] <ButtonPress-3> [ list tk_popup $srp.popupTbl %X %Y ]

                 pack $::gui_astrometry::srpt -in $srp -expand yes -fill both 


            # Sources - References Enfant (par liste de date chaque mesure)
            set sre [frame $onglets_sources.list.references.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
            pack $sre -in $onglets_sources.list.references -expand yes -fill both -side left

                 set ::gui_astrometry::sret $sre.table

                 tablelist::tablelist $::gui_astrometry::sret \
                   -columns $loc_dates_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $sre.hsb set ] \
                   -yscrollcommand [ list $sre.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1


                 scrollbar $sre.hsb -orient horizontal -command [list $::gui_astrometry::sret xview]
                 pack $sre.hsb -in $sre -side bottom -fill x
                 scrollbar $sre.vsb -orient vertical -command [list $::gui_astrometry::sret yview]
                 pack $sre.vsb -in $sre -side right -fill y

                 menu $sre.popupTbl -title "Actions"
                     $sre.popupTbl add command -label "Supprimer de cette image uniquement" \
                        -command {::gui_cata::unset_sret; ::gui_astrometry::affich_gestion}

                 bind [$::gui_astrometry::sret bodypath] <ButtonPress-3> [ list tk_popup $sre.popupTbl %X %Y ]

                 pack $::gui_astrometry::sret -in $sre -expand yes -fill both


            # Sources - Science Parent (par liste de source et moyenne)
            set ssp [frame $onglets_sources.list.sciences.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $ssp -in $onglets_sources.list.sciences -expand yes -fill both -side left

                 set ::gui_astrometry::sspt $onglets_sources.list.sciences.parent.table

                 tablelist::tablelist $::gui_astrometry::sspt \
                   -columns $loc_sources_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $ssp.hsb set ] \
                   -yscrollcommand [ list $ssp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $ssp.hsb -orient horizontal -command [list $::gui_astrometry::sspt xview]
                 pack $ssp.hsb -in $ssp -side bottom -fill x
                 scrollbar $ssp.vsb -orient vertical -command [list $::gui_astrometry::sspt yview]
                 pack $ssp.vsb -in $ssp -side left -fill y

                 menu $ssp.popupTbl -title "Actions"
                     $ssp.popupTbl add command -label "Supprimer de toutes les images" \
                         -command ""

                 bind $::gui_astrometry::sspt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_sspt %W ]
                 bind [$::gui_astrometry::sspt bodypath] <ButtonPress-3> [ list tk_popup $ssp.popupTbl %X %Y ]

                 pack $::gui_astrometry::sspt -in $ssp -expand yes -fill both 



            # Sources - Science Enfant (par liste de date chaque mesure)
            set sse [frame $onglets_sources.list.sciences.enfant -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $sse -in $onglets_sources.list.sciences -expand yes -fill both -side left

                 set ::gui_astrometry::sset $onglets_sources.list.sciences.enfant.table

                 tablelist::tablelist $::gui_astrometry::sset \
                   -columns $loc_dates_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $sse.hsb set ] \
                   -yscrollcommand [ list $sse.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $sse.hsb -orient horizontal -command [list $::gui_astrometry::sset xview]
                 pack $sse.hsb -in $sse -side bottom -fill x
                 scrollbar $sse.vsb -orient vertical -command [list $::gui_astrometry::sset yview]
                 pack $sse.vsb -in $sse -side right -fill y

                 menu $sse.popupTbl -title "Actions"
                     $sse.popupTbl add command -label "Supprimer de cette image uniquement" \
                        -command ""

                 bind [$::gui_astrometry::sset bodypath] <ButtonPress-3> [ list tk_popup $sre.popupTbl %X %Y ]

                 pack $::gui_astrometry::sset -in $sse -expand yes -fill both



            # Dates - Sources Parent (par liste de dates et moyenne)
            set dsp [frame $onglets_dates.list.sources.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $dsp -in $onglets_dates.list.sources -expand yes -fill both -side left

                 set ::gui_astrometry::dspt $onglets_dates.list.sources.parent.table

                 tablelist::tablelist $::gui_astrometry::dspt \
                   -columns $loc_dates_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dsp.hsb set ] \
                   -yscrollcommand [ list $dsp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1


                 scrollbar $dsp.hsb -orient horizontal -command [list $::gui_astrometry::dspt xview]
                 pack $dsp.hsb -in $dsp -side bottom -fill x
                 scrollbar $dsp.vsb -orient vertical -command [list $::gui_astrometry::dspt yview]
                 pack $dsp.vsb -in $dsp -side left -fill y

                 menu $dsp.popupTbl -title "Actions"
                     $dsp.popupTbl add command -label "Supprimer l'image" \
                         -command ""

                 bind $::gui_astrometry::dspt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dspt %W ]
                 bind [$::gui_astrometry::dspt bodypath] <ButtonPress-3> [ list tk_popup $dsp.popupTbl %X %Y ]

                 pack $::gui_astrometry::dspt -in $dsp -expand yes -fill both 


            # Dates - Sources Enfant (par liste de sources chaque mesure)
            set dse [frame $onglets_dates.list.sources.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
            pack $dse -in $onglets_dates.list.sources -expand yes -fill both -side left

                 set ::gui_astrometry::dset $dse.table

                 tablelist::tablelist $::gui_astrometry::dset \
                   -columns $loc_sources_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dse.hsb set ] \
                   -yscrollcommand [ list $dse.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1


                 scrollbar $dse.hsb -orient horizontal -command [list $::gui_astrometry::dset xview]
                 pack $dse.hsb -in $dse -side bottom -fill x
                 scrollbar $dse.vsb -orient vertical -command [list $::gui_astrometry::dset yview]
                 pack $dse.vsb -in $dse -side right -fill y

                 menu $dse.popupTbl -title "Actions"

                     $dse.popupTbl add command -label "Supprimer de cette image uniquement" \
                        -command ""

                 bind $::gui_astrometry::dset <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dset %W ]
                 bind [$::gui_astrometry::dset bodypath] <ButtonPress-3> [ list tk_popup $dse.popupTbl %X %Y ]

                 pack $::gui_astrometry::dset -in $dse -expand yes -fill both


            # Dates - WCS Parent (par liste de dates et moyenne)
            set dwp [frame $onglets_dates.list.wcs.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $dwp -in $onglets_dates.list.wcs -expand yes -fill both -side left

                 set ::gui_astrometry::dwpt $onglets_dates.list.wcs.parent.table

                 tablelist::tablelist $::gui_astrometry::dwpt \
                   -columns $loc_dates_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dwp.hsb set ] \
                   -yscrollcommand [ list $dwp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $dwp.hsb -orient horizontal -command [list $::gui_astrometry::dwpt xview]
                 pack $dwp.hsb -in $dwp -side bottom -fill x
                 scrollbar $dwp.vsb -orient vertical -command [list $::gui_astrometry::dwpt yview]
                 pack $dwp.vsb -in $dwp -side left -fill y

                 bind $::gui_astrometry::dwpt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dwpt %W ]

                 pack $::gui_astrometry::dwpt -in $dwp -expand yes -fill both 

            # Dates - WCS Enfant (Solution astrometrique)
            set dwe [frame $onglets_dates.list.wcs.enfant -borderwidth 1 -cursor arrow -relief groove -background ivory]
            pack $dwe -in $onglets_dates.list.wcs -expand yes -fill both -side left

               label  $dwe.titre -text "Solution astrometrique" -borderwidth 1
               pack   $dwe.titre -in $dwe -side top -padx 3 -pady 3 -anchor c

                 set ::gui_astrometry::dwet $onglets_dates.list.wcs.enfant.table

                 tablelist::tablelist $::gui_astrometry::dwet \
                   -columns $loc_wcs_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dwe.hsb set ] \
                   -yscrollcommand [ list $dwe.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $dwe.hsb -orient horizontal -command [list $::gui_astrometry::dwet xview]
                 pack $dwe.hsb -in $dwe -side bottom -fill x
                 scrollbar $dwe.vsb -orient vertical -command [list $::gui_astrometry::dwet yview]
                 pack $dwe.vsb -in $dwe -side left -fill y

                 pack $::gui_astrometry::dwet -in $dwe -expand yes -fill both 


         #  set ps [frame $onglets_sources.list.sciences.table_par -borderwidth 0 -cursor arrow -relief groove -background white]
         #  pack $ps -in $onglets_sources.list.sciences


#            frame $onglets0.list.sources.table_enf -borderwidth 0 -cursor arrow -relief groove -background white

         #--- Entetes Rapports
         
         
         set wdth 13
         
         
         set block [frame $entetes.uai_code  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "UAI Code : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 5 -textvariable ::tools_astrometry::rapport_uai_code
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

               label  $block.loc -textvariable ::tools_astrometry::rapport_uai_location -borderwidth 1 -width $wdth
               pack   $block.loc -side left -padx 3 -pady 3 -anchor w


         set block [frame $entetes.rapporteur  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Rapporteur : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_rapporteur
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.mail  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Mail : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80  -textvariable ::tools_astrometry::rapport_mail
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.observ  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Observateurs : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_observ
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.reduc  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Reduction : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_reduc
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.instru  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Instrument : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_instru
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.cata  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Catalogue Ref : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_cata
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         
# $denom
         
  
         set block [frame $denom.but  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $denom -side top -expand 0 -fill x -padx 2 -pady 5

               button $block.liste -text "Liste" -borderwidth 2 -takefocus 1 \
                       -command "::gui_astrometry::create_list_denom"
               pack   $block.liste -side top -anchor c -expand 0
         
         set ::gui_astrometry::zlist [frame $denom.zlist  -borderwidth 0 -cursor arrow -relief groove]
         pack $::gui_astrometry::zlist  -in $denom -side top -expand 0 -fill x -padx 2 -pady 5




         #--- Rapports MPC

         set block [frame $mpc.exped  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Destinataire : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_desti
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set block [frame $mpc.subj  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Sujet : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_batch
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set ::gui_astrometry::rapport_mpc $mpc.text
         text $::gui_astrometry::rapport_mpc -height 30 -width 80 \
              -xscrollcommand "$::gui_astrometry::rapport_mpc.xscroll set" \
              -yscrollcommand "$::gui_astrometry::rapport_mpc.yscroll set" \
              -wrap none
         pack $::gui_astrometry::rapport_mpc -expand yes -fill both -padx 5 -pady 5

         scrollbar $::gui_astrometry::rapport_mpc.xscroll  -orient horizontal -command "$::gui_astrometry::rapport_mpc xview"
         pack $::gui_astrometry::rapport_mpc.xscroll -side bottom -fill x

         scrollbar $::gui_astrometry::rapport_mpc.yscroll -orient vertical -command "$::gui_astrometry::rapport_mpc yview"
         pack $::gui_astrometry::rapport_mpc.yscroll -side right -fill y







         #--- Rapports txt

         set ::gui_astrometry::rapport_txt $txt.text
         text $::gui_astrometry::rapport_txt -height 30 -width 120 \
              -xscrollcommand "$::gui_astrometry::rapport_txt.xscroll set" \
              -yscrollcommand "$::gui_astrometry::rapport_txt.yscroll set" \
              -wrap none
         pack $::gui_astrometry::rapport_txt -expand yes -fill both -padx 5 -pady 5

         scrollbar $::gui_astrometry::rapport_txt.xscroll  -orient horizontal -command "$::gui_astrometry::rapport_txt xview"
         pack $::gui_astrometry::rapport_txt.xscroll -side bottom -fill x

         scrollbar $::gui_astrometry::rapport_txt.yscroll -orient vertical -command "$::gui_astrometry::rapport_txt yview"
         pack $::gui_astrometry::rapport_txt.yscroll -side right -fill y

#   $::gui_astrometry::rapport_txt insert end "$title \n\n" TITLE















         #--- Cree un frame pour afficher bouton fermeture
         set info [frame $frm.info  -borderwidth 0 -cursor arrow -relief groove]
         pack $info  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

              label  $info.labf -text "Fichier resultats : " -borderwidth 1
              pack   $info.labf -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.lastres -textvariable ::tools_astrometry::last_results_file -borderwidth 1
              pack   $info.lastres -in $info -side left -padx 3 -pady 3 -anchor c

              set ::gui_astrometry::gui_fermer [button $info.fermer -text "Fermer" -borderwidth 2 -takefocus 1 -command "::gui_astrometry::fermer"]
              pack $info.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              button $info.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 -command "::gui_astrometry::save_images"
              pack $info.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


      # Au lancement, charge les donnees
      ::gui_astrometry::affich_gestion


   }
   

   
   
   
   
   
   
   
   


   
}
