
# source $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex/main.tcl

   source [file join $bddconf(astroid) libastroid.tcl]
   source /srv/develop/audela/gui/audace/plugin/tool/av4l/av4l_photom.tcl
   source "$audace(rep_install)/gui/audace/surchaud.tcl"


   set audace(rep_travail) "$audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex"

cleanmark

   gren_info "Chargement de l image\n"
   set path0 "$audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex"
   loadima ${path0}/t1m_20110413_034512_858.fits

   set ra       [lindex [buf$audace(bufNo) getkwd RA      ] 1]
   set dec      [lindex [buf$audace(bufNo) getkwd DEC     ] 1]
   set pixsize1 [lindex [buf$audace(bufNo) getkwd PIXSIZE1] 1]
   set pixsize2 [lindex [buf$audace(bufNo) getkwd PIXSIZE2] 1]
   set foclen   [lindex [buf$audace(bufNo) getkwd FOCLEN  ] 1]
   set dateobs  [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
   set exposure [lindex [buf$audace(bufNo) getkwd EXPOSURE] 1]

   gren_info "Calibration de l image\n"
   #calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO c:/d/usno
   calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO /astrodata/Catalog/USNOA2/

   set a [buf$bddconf(bufno) xy2radec {512 512}]
   calibwcs [lindex $a 0] [lindex $a 1] $pixsize1 $pixsize2 $foclen USNO /astrodata/Catalog/USNOA2/
 

   gren_info "Chargement de la liste des sources\n"
   set listsources [get_ascii_txt]
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

   gren_info "Affichage du centre\n"
   set centre [list {"CENTRE" {} {} } [list [list [list "CENTRE" [list $ra $dec] {}]]]]
   affich_rond $centre "CENTRE" "red" 1
   affich_rond $listsources IMG "blue" 2

   set  listsources [::analyse_source::test2 $listsources 1]
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

   cleanmark
   affich_rond $listsources IMG "green" 1

   # mesure du photocentre
   set listsources [::manage_source::set_common_fields $listsources IMG { ra dec 5 calib_mag err_mag }]
   affich_rond $listsources TYCHO2 "green"    3

      set tycho2 [cstycho2 /astrodata/Catalog/TYCHO-2 $ra $dec 10 ]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $tycho2]\n"
      set tycho2 [::manage_source::set_common_fields $tycho2 TYCHO2 { RAdeg DEdeg 5 VT e_VT }]
      ::manage_source::imprim_3_sources $tycho2
      set listsources [ identification $listsources IMG $tycho2 TYCHO2 30.0 -30.0 {} 0] 
      affich_rond $listsources TYCHO2 "blue"   2

      set ucac2 [csucac2 /astrodata/Catalog/UCAC2 $ra $dec 10]
      set ucac2 [::manage_source::set_common_fields $ucac2 UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
      set listsources [ identification $listsources IMG $ucac2 UCAC2  -30.0 -30.0 {} 0] 
      affich_rond $listsources       UCAC2 "yellow"   2
 
      set ucac3 [csucac3 /astrodata/Catalog/UCAC3 $ra $dec 10]
      set ucac3 [::manage_source::set_common_fields $ucac3 UCAC3 { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
      set listsources [ identification $listsources IMG $ucac3 UCAC3  30.0 -30.0 {} 0] 
      affich_rond $listsources       UCAC3 "blue"   1
 
      cleanmark
      set listsources [::manage_source::extract_sources_by_catalog $listsources PHOTOM]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
      affich_rond $listsources OVNI "blue"   1
      affich_rond $listsources UCAC3 "green"  1

      set datejd  [ mc_date2jd $dateobs ]
      set datejd  [ expr $datejd + $exposure/86400.0/2.0 ]
      set dateiso [ mc_date2iso8601 $datejd ]
      gren_info "dateiso = $dateiso \n"
      set listskybot [ get_skybot $dateiso $ra $dec 600 586 ]
      gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listskybot]\n"
      set listsources [ identification $listsources "OVNI" $listskybot "SKYBOT" 30.0 10.0 {} 0] 
      affich_rond $listsources "SKYBOT" "red" 3


      ::priam::create_file_oldformat $listsources SKYBOT

      deleteFileConfigSextractor
      gren_info "Fin script\n"
