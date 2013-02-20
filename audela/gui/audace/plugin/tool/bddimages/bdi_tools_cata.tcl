#--------------------------------------------------
# source audace/plugin/tool/bddimages/bdi_tools_cata.tcl
#--------------------------------------------------
#
# Fichier        : bdi_tools_cata.tcl
# Description    : Procedures d analyses de l image
#                  sans GUI.
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: tools_cata.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace tools_cata
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  
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

namespace eval tools_cata {

   global audace
   global bddconf

   variable id_current_image
   variable current_image
   variable current_cata
   variable current_image_name
   variable current_cata_name
   variable current_image_date
   variable img_list
   variable img_list_sav
   variable nb_img_list
   variable current_listsources

   variable use_skybot
   variable use_usnoa2
   variable use_ucac2
   variable use_ucac3
   variable use_nomad1
   variable use_tycho2

   variable catalog_usnoa2
   variable catalog_ucac2
   variable catalog_ucac3
   variable catalog_nomad1
   variable catalog_tycho2

   variable keep_radec
   variable create_cata
   variable boucle

   variable ra_save
   variable dec_save

   variable nb_img
   variable nb_usnoa2
   variable nb_ucac2
   variable nb_ucac3
   variable nb_nomad1
   variable nb_tycho2
   variable nb_skybot
   variable nb_ovni

   variable ra       
   variable dec      
   variable pixsize1 
   variable pixsize2 
   variable foclen   
   variable exposure 

   variable delpv
   variable deuxpasses
   variable limit_nbstars_accepted
   variable log

   variable treshold_ident_pos_star
   variable treshold_ident_mag_star
   variable treshold_ident_pos_ast
   variable treshold_ident_mag_ast




   proc ::tools_cata::charge_list { img_list } {

      global audace
      global bddconf

      catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::nb_img_list ] }        {unset ::tools_cata::nb_img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }
      
      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

      #foreach ::tools_cata::current_image $::tools_cata::img_list {
      #   set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      #   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      #   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      #}

      # Chargement premiere image sans GUI
      set ::tools_cata::id_current_image 1
      set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]

      set ::tools_cata::file [file join $bddconf(dirbase) $dirfilename $filename]
      set ::tools_cata::ra       [lindex [::bddimages_liste::lget $tabkey ra] 1]
      set ::tools_cata::dec      [lindex [::bddimages_liste::lget $tabkey dec] 1]
#      set ::tools_cata::radius   [lindex [::bddimages_liste::lget $tabkey dec] 1]
      set ::tools_cata::crota    [lindex [::bddimages_liste::lget $tabkey CROTA] 1]
      set ::tools_cata::pixsize1 [lindex [::bddimages_liste::lget $tabkey pixsize1] 1]
      set ::tools_cata::pixsize2 [lindex [::bddimages_liste::lget $tabkey pixsize2] 1]
      set ::tools_cata::foclen   [lindex [::bddimages_liste::lget $tabkey foclen] 1]
      set ::tools_cata::exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set ::tools_cata::naxis1   [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set ::tools_cata::naxis2   [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set ::tools_cata::xcent    [expr $::tools_cata::naxis1/2.0]
      set ::tools_cata::ycent    [expr $::tools_cata::naxis2/2.0]

      set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]

      set ::tools_cata::current_image_name $filename
      set ::tools_cata::current_image_date $date

      gren_info "::tools_cata::file = $::tools_cata::file \n"
      gren_info "date = $date \n"
      gren_info "::tools_cata::bddimages_wcs = $::tools_cata::bddimages_wcs \n"
      gren_info " = [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"] \n"
      set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
      if {$cataexist==0} {
          gren_info "cata n existe pas\n"
      }
      if {[::bddimages_liste::lget $::tools_cata::current_image "cataexist"]=="1"} {
         gren_info "cata existe\n"
      } else {
         gren_info "cata n existe t pas\n"
      }
      
  }












   proc ::tools_cata::get_catafilename { img type } {

      global bddconf

      if {$type == "FILE"} {
         set catafilenameexist [::bddimages_liste::lexist $img "catafilename"]
         if {$catafilenameexist==0} {return -code 1 "catafilename n existe pas dans l image"}
         set catafilename [::bddimages_liste::lget $img "catafilename"]
         return -code 0 [::bddimages_liste::lget $img "catafilename"]
      }

      if {$type == "BASE"} {
         
      }

      if {$type == "DRIVE"} {
         set catafilenameexist [::bddimages_liste::lexist $img "catafilename"]
         if {$catafilenameexist==0} {return -code 1 "catafilename n existe pas dans l image"}
         set catafilename [::bddimages_liste::lget $img "catafilename"]

         set catadirfilename [::bddimages_liste::lexist $img "catadirfilename"]
         if {$catafilenameexist==0} {return -code 2 "catadirfilename n existe pas dans l image"}
         set catadirfilename [::bddimages_liste::lget $img "catadirfilename"]
      
         return -code 0 [file join $bddconf(dirbase) $catadirfilename $catafilename]
      }

      if {$type == "TMP"} {
         set catafilenameexist [::bddimages_liste::lexist $img "catafilename"]
         if {$catafilenameexist==0} {return -code 1 "catafilename n existe pas dans l image"}
         set catafilename [::bddimages_liste::lget $img "catafilename"]

         set catafilename [string range $catafilename 0 [expr [string last .gz $catafilename] -1]]

         return -code 0 [file join $bddconf(dirtmp) $catafilename]
      }

   }






   proc ::tools_cata::extract_cata_xml { catafile } {

      global bddconf

      set xml [string range $catafile 0 [expr [string last .gz $catafile] -1]]
      set tmpfile [file join $bddconf(dirtmp) [file tail $xml] ]

      lassign [::bddimages::gunzip $xml $tmpfile] errnum msgzip
      #file delete -force -- $tmpfile
      #if { $::tcl_platform(os) == "Linux" } {
      #   set errnum [catch {exec gunzip -c $xml > $tmpfile} msgzip ]
      #} else {
      #   set errnum [catch {file copy "$xml" "${tmpfile}.gz" ; gunzip "$tmpfile"} msgzip ]
      #}
      if {$errnum} {
         file delete -force -- $tmpfile
         return -code 1 "Err extraction $xml $tmpfile"
      }
      return $tmpfile
   }






proc ::tools_cata::extract_cata_xml_old { catafile } {

  global bddconf

      # copy catafile vers tmp
      set destination [file join $bddconf(dirtmp) [file tail $catafile]]
      #gren_info "destination = $destination\n"
      set errnum [catch {file copy "$catafile" "$destination" ; gunzip "$destination"} msgzip ]
      #gren_info "errnum = $errnum\n"
      #gren_info "msgzip = $msgzip\n"
      
      # gunzip catafile de tmp
      # return le nom de fichier
      return [file rootname $destination]
 }
 
 













   proc ::tools_cata::get_cata_xml { catafile } {

      global bddconf

      gren_info "Chargement du cata xml: $catafile \n"

      set fields ""
      set fxml [open $catafile "r"]
      set data [read $fxml]
      close $fxml

      set motif  "<vot:TABLE\\s+?name=\"(.+?)\"\\s+?nrows=(.+?)>(?:.*?)</vot:TABLE>"
      set res [regexp -all -inline -- $motif $data]
      set cpt 1
      foreach { table name nrows } $res {
         #gren_info "$cpt  :  \n"
         #gren_info "Name => $name  \n"
         #gren_info "nrows  => $nrows  \n"
         #gren_info "TABLE => $table  \n"
         set res [ get_table $name $table ]
         #gren_info "TABLE res => $res  \n"
         #set ftmp  [lindex [lindex $res 0] 2]
         #set ftmp [lrange $ftmp 1 end]
         #set ftmp [list  [lindex [lindex $res 0] 0]   [lindex [lindex $res 0] 1]  $ftmp]  
         #gren_info "TABLE => $ftmp  \n"
         
         lappend fields [lindex $res 0]
         set asource [lindex $res 1]
         foreach x $asource {
            set idcataspec [lindex $x 0]
            set val [lindex $x 1]
            #gren_info "$idcataspec = $val\n"
            if {![info exists tsource($idcataspec)]} {
               #gren_info "set $idcataspec => $val  \n"
               set tsource($idcataspec) [list [list $name {} $val]]
            } else {
               #gren_info "app $idcataspec => $val  \n"
               lappend tsource($idcataspec) [list $name {} $val]
            }
         }

         incr cpt
      }
      
      #gren_info "tsource => [array get tsource]  \n"
      set tab [array get tsource]
      set lso {}
      set cpt 0
      foreach val $tab {
         #gren_info "vals [expr $cpt%2] => $val \n"
         if {[expr $cpt%2] == 0 } {
            # indice
         } else {
            lappend lso $val
         }
         incr cpt
      }
      
      return [list $fields $lso]

   }








   proc ::tools_cata::get_table { name table } {


      set motif  "<vot:FIELD(?:.*?)name=\"(.+?)\"(?:.*?)</vot:FIELD>"

      set res [regexp -all -inline -- $motif $table ]
      #gren_info "== res $res \n"
      set cpt 1
      set listfield ""
      foreach { x y } $res {
         #gren_info "== $cpt  : $y \n"
         
         if {$y != "idcataspec.$name"} { lappend listfield $y }
         incr cpt
      }
      
      set listfield [list $name [list ra dec poserr mag magerr] $listfield]
      #gren_info "== listfield $listfield \n"

      set motiftr  "<vot:TR>(.*?)</vot:TR>"
      set motiftd  "<vot:TD>(.*?)</vot:TD>"
      
      set tr [regexp -all -inline -- $motiftr $table ]
      set cpt 1
      set lls ""
      foreach { a x } $tr {
         #gren_info "TR-> $cpt  : a: $a x: $x \n"
         #gren_info "TR-> $cpt \n"
         set td [regexp -all -inline -- $motiftd $x ]
         set u 0
         set ls ""
         foreach { y z } $td {
            if { $u == 0 } {
               set idcataspec $z
            } else {
               lappend ls $z
            }
            incr u
         }
         #gren_info "$idcataspec : $ls\n"
         lappend lls [list $idcataspec $ls]
         incr cpt
      }
      
      #gren_info "lls = $lls \n"
      return [list $listfield $lls]
   }








 

   proc ::tools_cata::get_cata {  } {

      global bddconf


      set tt0 [clock clicks -milliseconds]


      # Noms du fichier et du repertoire du cata TXT
      set imgfilename [::bddimages_liste::lget $::tools_cata::current_image filename]
      set imgdirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      # Definition du nom du cata XML
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      # Liste des champs du header de l'image
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

      # Liste des sources de l'image
      set listsources $::tools_cata::current_listsources

      set ra  $::tools_cata::ra
      set dec $::tools_cata::dec
      set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]

      set lcd ""
      lappend lcd [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
      lappend lcd [lindex [::bddimages_liste::lget $tabkey CD1_2] 1]
      lappend lcd [lindex [::bddimages_liste::lget $tabkey CD2_1] 1]
      lappend lcd [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
      set mscale [::math::statistics::max $lcd]
      set radius [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]

      if {1==0} {
         gren_info "naxis1  = $naxis1\n"
         gren_info "naxis2  = $naxis2\n"
         gren_info "mscale  = $mscale\n"
         gren_info "scale_x = $scale_x\n"
         gren_info "scale_y = $scale_y\n"
         gren_info "ra      = $ra\n"
         gren_info "dec     = $dec\n"
         gren_info "radius  = $radius\n"
      }

      if {$::tools_cata::use_usnoa2} {
         #gren_info "*** CMD: csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius\n"
         set usnoa2 [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $usnoa2]\n"
         set usnoa2 [::manage_source::set_common_fields $usnoa2 USNOA2 { ra_deg dec_deg 5.0 magR 0.5 }]
         #::manage_source::imprim_3_sources $usnoa2
         #gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources USNOA2CALIB $usnoa2 USNOA2 $::tools_cata::treshold_ident_pos_star $::tools_cata::treshold_ident_mag_star {} $log]
         set listsources [ ::manage_source::delete_catalog $listsources USNOA2CALIB ]
         set ::tools_cata::nb_usnoa2 [::manage_source::get_nb_sources_by_cata $listsources USNOA2]
      }

      if {$::tools_cata::use_tycho2} {
         #gren_info "CMD: cstycho2 $::tools_cata::catalog_tycho2 $ra $dec $radius\n"
         set tycho2 [cstycho2 $::tools_cata::catalog_tycho2 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $tycho2]\n"
         set tycho2 [::manage_source::set_common_fields $tycho2 TYCHO2 { RAdeg DEdeg 5.0 VT e_VT }]
         #::manage_source::imprim_3_sources $tycho2
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $tycho2 TYCHO2 $::tools_cata::treshold_ident_pos_star $::tools_cata::treshold_ident_mag_star {} $log]
         set ::tools_cata::nb_tycho2 [::manage_source::get_nb_sources_by_cata $listsources TYCHO2]
      }

      if {$::tools_cata::use_ucac2} {
         #gren_info "CMD: csucac2 $::tools_cata::catalog_ucac2 $ra $dec $radius\n"
         set ucac2 [csucac2 $::tools_cata::catalog_ucac2 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac2]\n"
         set ucac2 [::manage_source::set_common_fields $ucac2 UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
         #::manage_source::imprim_3_sources $ucac2
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ucac2 UCAC2 $::tools_cata::treshold_ident_pos_star $::tools_cata::treshold_ident_mag_star {} $log]
         set ::tools_cata::nb_ucac2 [::manage_source::get_nb_sources_by_cata $listsources UCAC2]
      }

      if {$::tools_cata::use_ucac3} {
         #gren_info "CMD: csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius\n"
         set ucac3 [csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac3]\n"
         set ucac3 [::manage_source::set_common_fields $ucac3 UCAC3 { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
         #::manage_source::imprim_3_sources $ucac3
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ucac3 UCAC3 $::tools_cata::treshold_ident_pos_star $::tools_cata::treshold_ident_mag_star {} $log]
         set ::tools_cata::nb_ucac3 [::manage_source::get_nb_sources_by_cata $listsources UCAC3]
      }

      if {$::tools_cata::use_ucac4} {
         #gren_info "CMD: csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius\n"
         set ucac4 [csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac4]\n"
         set ucac4 [::manage_source::set_common_fields $ucac4 UCAC4 { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
         #::manage_source::imprim_3_sources $ucac4
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ucac4 UCAC4 $::tools_cata::treshold_ident_pos_star $::tools_cata::treshold_ident_mag_star {} $log]
         set ::tools_cata::nb_ucac4 [::manage_source::get_nb_sources_by_cata $listsources UCAC4]
      }
   
      if {$::tools_cata::use_skybot} {
         set dateobs [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
         set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set datejd [ mc_date2jd $dateobs ]
         set datejd [ expr $datejd + $exposure/86400.0/2.0 ]
         set dateiso [ mc_date2iso8601 $datejd ]
         set radius [format "%0.0f" [expr $radius*60.0] ]
         set iau_code [lindex [::bddimages_liste::lget $tabkey IAU_CODE ] 1]
         #gren_info "get_skybot $dateiso $ra $dec $radius $iau_code\n"
         set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} skybot ]
         #set listsources [::tools_sources::set_common_fields_skybot $listsources]
         set listsources [::manage_source::delete_catalog $listsources "SKYBOT"]
         set listsources [ identification $listsources "IMG" $skybot "SKYBOT" $::tools_cata::treshold_ident_pos_ast $::tools_cata::treshold_ident_mag_ast {} 0 ] 
         set ::tools_cata::nb_skybot [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
      }

      if {$::psf_tools::use_psf} {
         
         if {$::psf_tools::use_global} {
            ::psf_gui::psf_listsources_auto listsources $::psf_tools::psf_threshold $::psf_tools::psf_limitradius $::psf_tools::psf_saturation
         } else {
            ::psf_gui::psf_listsources_no_auto listsources $::psf_tools::psf_threshold $::psf_tools::psf_delta $::psf_tools::psf_saturation
         }
         set ::tools_cata::nb_astroid [::manage_source::get_nb_sources_by_cata $listsources ASTROID]
         ::psf_tools::set_mag listsources
         
      }

      gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"

      # Sauvegarde du cata XML
      gren_info "Enregistrement du cata XML: $cataxml\n"
      if {$::tools_cata::create_cata == 1} {
         ::tools_cata::save_cata $listsources $tabkey $cataxml
      }
      
      set ::tools_cata::current_listsources $listsources

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Creation du cata in $tt sec \n"

      return true

#::manage_source::imprim_3_sources $::tools_cata::current_listsources
#gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
#set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
#set votable [::votableUtil::list2votable $::tools_cata::current_listsources $tabkey]
#set fxml [open $cataxml "w"]
#puts $fxml $votable
#close $fxml

   }




   #
   # Sauvegarde du cata XML et insertion dans la bdd si demande (insertcata=1)
   #   listsources liste des sources des cata
   #   tabkey      liste des tabkey
   #   cataxml     nom du fichier du cata xml
   #   insertcata  1|0 pour inserer ou non le cata xml dans la bdd
   #
   proc ::tools_cata::save_cata { listsources tabkey cataxml } {

      global bddconf

      set dateobs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
      gren_info "date = $dateobs\n"
      gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"

      # Creation de la VOTable en memoire
      set votable [::votableUtil::list2votable $listsources $tabkey]
      
      # Sauvegarde du cata XML
      set fxml [open $cataxml "w"]
      puts $fxml $votable
      close $fxml

      # Insertion du cata dans bdi
      set err [ catch { insertion_solo $cataxml } msg ]
      #gren_info "** INSERTION_SOLO = $err $msg\n"
      set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
      if {$cataexist==0} {
         set ::tools_cata::current_image [::bddimages_liste::ladd $::tools_cata::current_image "cataexist" 1]
      } else {
         set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "cataexist" 1]
      }

   }
   
   
   



#::tools_cata::test_ident_skybot 50 50 2

   proc ::tools_cata::test_ident_skybot { x y l } {

      cleanmark

      set ra  $::tools_cata::ra
      set dec $::tools_cata::dec
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set listsources $::tools_cata::current_listsources

     gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"
     set listsources [ ::manage_source::delete_catalog $listsources "SKYBOT" ]
     gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"



      
      set dateobs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
      set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
      set datejd   [ mc_date2jd $dateobs ]
      set datejd   [ expr $datejd + $exposure/86400.0/2.0 ]
      set dateiso  [ mc_date2iso8601 $datejd ]
      set radius   [format "%0.0f" [expr 10.*60.0] ]
      set iau_code [lindex [::bddimages_liste::lget $tabkey IAU_CODE ] 1]

      gren_info "get_skybot $dateiso $ra $dec $radius $iau_code\n"
      if {![info exists ::tools_cata::skybot]} {
         set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} ::tools_cata::skybot ]
         if {$err} {
            gren_info "err = $err\n"
            gren_info "msg = $::tools_cata::skybot\n"
            return
         }
      }
      gren_info "skybot = $::tools_cata::skybot\n"

      #set listsources [::tools_sources::set_common_fields_skybot $listsources]
      set listsources [ identification $listsources "IMG" $::tools_cata::skybot "SKYBOT" $x $y {} $l] 
      set ::tools_cata::nb_skybot [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
      gren_info "nb_skybot = $::tools_cata::nb_skybot\n"
      #gren_info "[::manage_source::extract_sources_by_catalog $listsources SKYBOT]\n"
      #cleanmark
      affich_rond $listsources "SKYBOT" "magenta" 4

# {1647 0} {1689 0} {1700 0} {1712 0} {3058 0} {3069 0} {3073 0}

# {1678 0} {1738 0} {1752 0} {3420 0} {3463 0} {3465 0} {3488 0} 
# {1678 0} {1738 0} {1752 0} {3420 0} {3463 0} {3465 0} {3488 0} 

#{1299 0} {1334 0} {1342 0} {2737 0} {2779 0} {2781 0} {2802 0} 
#{1299 0} {1334 0} {1342 0} {2737 0} {2779 0} {2781 0} {2802 0} 
   }









   proc ::tools_cata::get_wcs {  } {

      global audace
      global bddconf

      set img $::tools_cata::current_image

      set wcs_ok false

      # Infos sur l'image a traiter
      set tabkey [::bddimages_liste::lget $img "tabkey"]

      set ra        $::tools_cata::ra       
      set dec       $::tools_cata::dec      
      set pixsize1  $::tools_cata::pixsize1 
      set pixsize2  $::tools_cata::pixsize2 
      set foclen    $::tools_cata::foclen   
      set exposure  $::tools_cata::exposure 

      set dateobs     [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
      set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
      set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
      set filename    [::bddimages_liste::lget $img filename   ]
      set dirfilename [::bddimages_liste::lget $img dirfilename]
      set idbddimg    [::bddimages_liste::lget $img idbddimg]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      set xcent [expr $naxis1/2.0]
      set ycent [expr $naxis2/2.0]

      if {$::tools_cata::log} {
         gren_info "PASS1: calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO  $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0\n"
      }

      set erreur [catch {set nbstars [calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0]} msg]

      if {$erreur} {
         if {[info exists nbstars]} {
            gren_info "existe"
            if {[string is integer -strict $nbstars]} {
               return -code 1 "ERR NBSTARS=$nbstars ($msg)"
            } else {
               return -code 1 "ERR = $erreur ($msg)"
            }
         } else {
            gren_info "Erreur interne de calibwcs, voir l erreur de la libtt"
            return -code 1 "ERR = $erreur ($msg)"
         }
      }

      set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
      set ra  [lindex $a 0]
      set dec [lindex $a 1]
      if {$::tools_cata::log} {gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"}

      if {$::tools_cata::deuxpasses} {
         if {$::tools_cata::log} {gren_info "PASS2: calibwcs $ra $dec * * * USNO  $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0\n"}
         set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0]} msg]
         if {$erreur} {
            return -code 2 "ERR NBSTARS=$nbstars ($msg)"
         }

         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]
         if {$::tools_cata::log} {
            gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
         }
      }

      gren_info "nbstars/limit  = $nbstars / $::tools_cata::limit_nbstars_accepted \n"

      if { $::tools_cata::keep_radec==1 && $nbstars<$::tools_cata::limit_nbstars_accepted && [info exists ::tools_cata::ra_save] && [info exists ::tools_cata::dec_save] } {
         set ra  $::tools_cata::ra_save
         set dec $::tools_cata::dec_save
         if {$::tools_cata::log} {gren_info "PASS3: calibwcs $ra $dec * * * USNO  $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0\n"}
         set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0]} msg]
         if {$erreur} {
            return -code 3 "ERR NBSTARS=$nbstars ($msg)"
         }
         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]
         if {$::tools_cata::log} {
            gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
         }
         if {$::tools_cata::deuxpasses} {
            if {$::tools_cata::log} {gren_info "PASS4: calibwcs $ra $dec * * * USNO  $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0\n"
         }
         set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0]} msg]
         if {$erreur} {
            return -code 4 "ERR NBSTARS=$nbstars ($msg)"
         }
         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]
         if {$::tools_cata::log} {gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"}
            gren_info "RETRY nbstars : $nbstars | ra : [mc_angle2hms $ra 360 zero 1 auto string] | dec : [mc_angle2dms $dec 90 zero 1 + string]\n"
         }
      }

      set ::tools_cata::nb_usnoa2 $nbstars
      set ::tools_cata::current_listsources [get_ascii_txt]
      set ::tools_cata::nb_img  [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources IMG   ]
      set ::tools_cata::nb_ovni [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources OVNI  ]

      if {$nbstars > $::tools_cata::limit_nbstars_accepted} {
         set wcs_ok true
      }

#   gren_info "Chargement de la liste des sources\n"
#   set listsources [get_ascii_txt]
#   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
 
      if {$wcs_ok} {
         set ::tools_cata::ra_save $ra 
         set ::tools_cata::dec_save $dec

         set ident [bddimages_image_identification $idbddimg]
         set fileimg  [lindex $ident 1]
         set filecata [lindex $ident 3]
         if {$fileimg == -1} {
            if {$erreur} {
               return -code 5 "Fichier image inexistant ($idbddimg) \n"
            }
         }

         # Efface les cles PV1_0 et PV2_0 car pas bon
         if {$::tools_cata::delpv} {
            set err [catch {buf$::audace(bufNo) delkwd PV1_0} msg]
            set err [catch {buf$::audace(bufNo) delkwd PV2_0} msg]
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
         lassign [::bddimages::gzip $filetmp $filefinal] errnum msg

         # efface l image dans la base et le disque
         bddimages_image_delete_fromsql $ident
         bddimages_image_delete_fromdisk $ident

         # insere l image et le cata dans la base filecata
         set errnum [catch {set r [insertion_solo $filefinal]} msg ]
         if {$errnum==0} {
            set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image idbddimg $r]
         }

         set errnum [catch {file delete -force $filetmp} msg ]

         set errnum [catch {set list_keys [buf$::audace(bufNo) getkwds]} msg ]
         set tabkey {}
         foreach key $list_keys {
            set garde "ok"
            if {$key==""} {set garde "no"}
            foreach rekey $tabkey {
               if {$key==$rekey} {set garde "no"}
            }
            if {$garde=="ok"} {
               lappend tabkey [list $key [buf$::audace(bufNo) getkwd $key] ]
            }
         }

         set result  [bddimages_entete_preminforecon $tabkey]
         set err     [lindex $result 0]
         set $tabkey [lindex $result 1]
         set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image tabkey $tabkey]
         set idbddimg   [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]

         return -code 0 "WCS OK"
      }

      return -code 10 "Sources non identifiees"
   }














   #
   # Calcul le rayon (arcmin) du FOV de l'image
   #
   proc ::tools_cata::get_radius { naxis1 naxis2 scale_x scale_y } {

      #--- Coordonnees en pixels du centre de l'image
      set xc [ expr $naxis1/2.0 ]
      set yc [ expr $naxis2/2.0 ]

      #--- Calcul de la dimension du FOV: naxis*scale
      set taille_champ_x [expr abs($scale_x)*$naxis1*60.0]
      set taille_champ_y [expr abs($scale_y)*$naxis2*60.0]

      set radius [expr sqrt(pow($taille_champ_x,2) + pow($taille_champ_y,2)) ]
      return $radius

   }





   proc ::tools_cata::get_id_astrometric { tag sent_current_listsources} {
      
      upvar $sent_current_listsources listsources
      
      set result ""
      set sources [lindex $listsources 1]
      set cpt 0
      foreach s $sources {
         set x  [lsearch -index 0 $s "ASTROID"]
         if {$x>=0} {
            set b  [lindex [lindex $s $x] 2]           
            set ar [lindex $b 25]
            set ac [lindex $b 27]
            if {$ar==$tag} {
               set name [::manage_source::naming $s $ac]
               lappend result [list $cpt $x $ar $ac $name]
            }
         }
         incr cpt
      }
      
      return $result
   }



# Anciennement ::gui_cata::get_img_null
# return une ligne de champ nul pour la creation d'une entree IMG dans le catalogue
   proc ::tools_cata::get_img_fields { } {
      return [list id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex]

   }

   proc ::tools_cata::get_img_null { } {
    
      return [list "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" ]
   }


# Anciennement ::gui_cata::is_astrometric_catalog
# renvoit le nom d'un catalogue consideré comme astrometrique
   proc ::tools_cata::is_astrometric_catalog { c } {

      return [expr [lsearch -exact [list USNOA2 UCAC2 UCAC3 UCAC4 TYCHO2] $c] + 1]
   }


# Anciennement ::gui_cata::is_photometric_catalog 
# renvoit le nom d'un catalogue consideré comme photometrique
   proc ::tools_cata::is_photometric_catalog { c } {

      return [expr [lsearch -exact [list USNOA2 UCAC2 UCAC3 UCAC4 TYCHO2] $c] + 1]
   }











# Anciennement ::gui_cata::push_img_list

   proc ::tools_cata::push_img_list {  } {
      set ::tools_cata::img_list_sav         $::tools_cata::img_list
      set ::tools_cata::current_image_sav    $::tools_cata::current_image
      set ::tools_cata::id_current_image_sav $::tools_cata::id_current_image
      set ::tools_cata::create_cata_sav      $::tools_cata::create_cata
   }













# Anciennement ::gui_cata::pop_img_list

   proc ::tools_cata::pop_img_list {  } {
      set ::tools_cata::img_list         $::tools_cata::img_list_sav
      set ::tools_cata::current_image    $::tools_cata::current_image_sav
      set ::tools_cata::id_current_image $::tools_cata::id_current_image_sav
      set ::tools_cata::create_cata      $::tools_cata::create_cata_sav
   }















# Anciennement ::gui_cata::current_listsources_to_tklist



   proc ::tools_cata::current_listsources_to_tklist { } {

      set listsources $::tools_cata::current_listsources
      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set nbcata  [llength $fields]

      catch {
         unset ::gui_cata::cataname
         unset ::gui_cata::cataid
      }

      set commonfields ""
      set idcata 0
      set list_id ""
      foreach f $fields {
         incr idcata
         set c [lindex $f 0]
         set ::gui_cata::cataname($idcata) $c
         set ::gui_cata::cataid($c) $idcata
         if {$c=="ASTROID"} {
            set idcata_astroid $idcata
            set list_id [linsert $list_id 0 $idcata]
         } else {
            set list_id [linsert $list_id end $idcata]
         }
         if {$c=="IMG"} {
            foreach cc [lindex $f 1] {
               lappend commonfields $cc
            }
         }
      }
      
      foreach idcata $list_id {

         set ::gui_cata::tklist($idcata) ""
         set ::gui_cata::tklist_list_of_columns($idcata) [list  \
                                    [list "bdi_idc_lock"      "Id"] \
                                    [list "astrom_reference"  "AR"] \
                                    [list "astrom_catalog"    "AC"] \
                                    [list "photom_reference"  "PR"] \
                                    [list "photom_catalog"    "PC"] \
                                    ]
         foreach cc $commonfields {
            lappend ::gui_cata::tklist_list_of_columns($idcata) [list $cc $cc]
         }

         set otherfields ""
         foreach f $fields {
            if {[lindex $f 0]==$::gui_cata::cataname($idcata)} {
               foreach cc [lindex $f 2] {
                  lappend ::gui_cata::tklist_list_of_columns($idcata) [list $cc $cc]
                  lappend otherfields $cc
                }
            }
         }
      }
         
      #gren_info "m list_of_columns = $list_of_columns \n"
      #gren_info "$::gui_cata::cataname($idcata) => fields : $otherfields\n"
  
      set cpts 0

      foreach s $sources {

         incr cpts

         set ar "-"
         set ac "-"
         set pr "-"
         set pc "-"

         set x  [lsearch -index 0 $s "ASTROID"]
         if {$x>=0} {
            set b  [lindex [lindex $s $x] 2]           
            set ar [lindex $b 25]
            set ac [lindex $b 27]
            set pr [lindex $b 26]
            set pc [lindex $b 28]   
            #gren_info "AR = $ar $ac $pr $pc\n"
         }

         foreach cata $s {
            if {![info exists ::gui_cata::cataid([lindex $cata 0])]} { continue }
            set idcata $::gui_cata::cataid([lindex $cata 0])
            set line ""
            # ID
            lappend line $cpts
            # valeur des Flag ASTROID
            lappend line $ar
            lappend line $ac
            lappend line $pr
            lappend line $pc
            # valeur des common
            foreach field [lindex $cata 1] {
               lappend line $field
            }
            # valeur des other field
            foreach field [lindex $cata 2] {
               lappend line $field
            }
            lappend ::gui_cata::tklist($idcata) $line
         }


      }


   }









# Fin du namespace
}
