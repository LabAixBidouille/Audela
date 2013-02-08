#--------------------------------------------------
# source audace/plugin/tool/bddimages/bdi_gui_cata.tcl
#--------------------------------------------------
#
# Fichier        : bdi_gui_cata.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bdi_gui_cata.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace gui_cata
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  gui_cata.cap
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
# IMG CATALOG
# 0   id 
# 1   flag 
# 2   xpos 
# 3   ypos 
# 4   instr_mag 
# 5   err_mag 
# 6   flux_sex 
# 7   err_flux_sex 
# 8   ra 
# 9   dec 
# 10  calib_mag 
# 11  calib_mag_ss1 
# 12  err_calib_mag_ss1 
# 13  calib_mag_ss2 
# 14  err_calib_mag_ss2 
# 15  nb_neighbours 
# 16  radius 
# 17  background_sex 
# 18  x2_momentum_sex 
# 19  y2_momentum_sex 
# 20  xy_momentum_sex 
# 21  major_axis_sex 
# 22  minor_axis_sex 
# 23  position_angle_sex 
# 24  fwhm_sex 
# 25  flag_sex


namespace eval gui_cata {

   global audace
   global bddconf

   variable current_image
   variable current_cata
   variable fen
   variable stateback
   variable statenext
   variable current_appli


   variable color_button_good "green"
   variable color_button_bad  "red"
   variable color_wcs      
   variable color_cata      
   variable bddimages_wcs 

   variable gui_next 
   variable gui_back
   variable gui_create
   variable gui_fermer
   variable gui_nomimage
   variable gui_dateimage
   variable gui_stimage
   variable gui_wcs
   variable gui_cata
   variable gui_info
   variable gui_info2

   variable gui_img
   variable gui_usnoa2
   variable gui_ucac2
   variable gui_ucac3
   variable gui_ucac4
   variable gui_ppmx
   variable gui_ppmxl
   variable gui_tycho2
   variable gui_nomad1
   variable gui_skybot

   variable size_img
   variable size_usnoa2
   variable size_ucac2
   variable size_ucac3
   variable size_ucac4
   variable size_ppmx
   variable size_ppmxl
   variable size_nomad1
   variable size_tycho2
   variable size_skybot
   variable size_ovni

   variable color_img     "red"
   variable color_usnoa2  "green"
   variable color_ucac2   "cyan"
   variable color_ucac3   "#006cc0"
   variable color_ucac4   "#0000ff"
   variable color_ppmx    "orange"
   variable color_ppmxl   "orange"
   variable color_nomad1  "#b4b308"
   variable color_tycho2  "orange"
   variable color_skybot  "magenta"
   variable color_ovni    "yellow"

   variable dssvisu
   variable dssbuf 

   variable man_xy_star
   variable man_ad_star

   variable use_uncosmic

   variable gui_astroid_bestdelta








   proc ::gui_cata::inittoconf { } {


      global conf


      # Check button GUI

      if {! [info exists ::gui_cata::gui_img] } {
         if {[info exists conf(astrometry,cata,gui_img)]} {
            set ::gui_cata::gui_img $conf(astrometry,cata,gui_img)
         } else {
            set ::gui_cata::gui_img 1
         }
      }
      if {! [info exists ::gui_cata::gui_usnoa2] } {
         if {[info exists conf(astrometry,cata,gui_usnoa2)]} {
            set ::gui_cata::gui_usnoa2 $conf(astrometry,cata,gui_usnoa2)
         } else {
            set ::gui_cata::gui_usnoa2 1
         }
      }
      if {! [info exists ::gui_cata::gui_ucac2] } {
         if {[info exists conf(astrometry,cata,gui_ucac2)]} {
            set ::gui_cata::gui_ucac2 $conf(astrometry,cata,gui_ucac2)
         } else {
            set ::gui_cata::gui_ucac2 0
         }
      }
      if {! [info exists ::gui_cata::gui_ucac3] } {
         if {[info exists conf(astrometry,cata,gui_ucac3)]} {
            set ::gui_cata::gui_ucac3 $conf(astrometry,cata,gui_ucac3)
         } else {
            set ::gui_cata::gui_ucac3 0
         }
      }
      if {! [info exists ::gui_cata::gui_ucac4] } {
         if {[info exists conf(astrometry,cata,gui_ucac4)]} {
            set ::gui_cata::gui_ucac4 $conf(astrometry,cata,gui_ucac4)
         } else {
            set ::gui_cata::gui_ucac4 0
         }
      }
      if {! [info exists ::gui_cata::gui_ppmx] } {
         if {[info exists conf(astrometry,cata,gui_ppmx)]} {
            set ::gui_cata::gui_ppmx $conf(astrometry,cata,gui_ppmx)
         } else {
            set ::gui_cata::gui_ppmx 0
         }
      }
      if {! [info exists ::gui_cata::gui_ppmxl] } {
         if {[info exists conf(astrometry,cata,gui_ppmxl)]} {
            set ::gui_cata::gui_ppmxl $conf(astrometry,cata,gui_ppmxl)
         } else {
            set ::gui_cata::gui_ppmxl 0
         }
      }
      if {! [info exists ::gui_cata::gui_tycho2] } {
         if {[info exists conf(astrometry,cata,gui_tycho2)]} {
            set ::gui_cata::gui_tycho2 $conf(astrometry,cata,gui_tycho2)
         } else {
            set ::gui_cata::gui_tycho2 0
         }
      }
      if {! [info exists ::gui_cata::gui_nomad1] } {
         if {[info exists conf(astrometry,cata,gui_nomad1)]} {
            set ::gui_cata::gui_nomad1 $conf(astrometry,cata,gui_nomad1)
         } else {
            set ::gui_cata::gui_nomad1 0
         }
      }
      if {! [info exists ::gui_cata::gui_skybot] } {
         if {[info exists conf(astrometry,cata,gui_skybot)]} {
            set ::gui_cata::gui_skybot $conf(astrometry,cata,gui_skybot)
         } else {
            set ::gui_cata::gui_skybot 0
         }
      }

      # Taille des ronds
      if {! [info exists ::gui_cata::size_img] } {
         if {[info exists conf(astrometry,cata,size_img)]} {
            set ::gui_cata::size_img $conf(astrometry,cata,size_img)
         } else {
            set ::gui_cata::size_img 1
         }
      }
      set ::gui_cata::size_img_sav $::gui_cata::size_img
      
      if {! [info exists ::gui_cata::size_usnoa2] } {
         if {[info exists conf(astrometry,cata,size_usnoa2)]} {
            set ::gui_cata::size_usnoa2 $conf(astrometry,cata,size_usnoa2)
         } else {
            set ::gui_cata::size_usnoa2 1
         }
      }
      set ::gui_cata::size_usnoa2_sav $::gui_cata::size_usnoa2
      
      if {! [info exists ::gui_cata::size_ucac2] } {
         if {[info exists conf(astrometry,cata,size_ucac2)]} {
            set ::gui_cata::size_ucac2 $conf(astrometry,cata,size_ucac2)
         } else {
            set ::gui_cata::size_ucac2 1
         }
      }
      set ::gui_cata::size_ucac2_sav $::gui_cata::size_ucac2
      
      if {! [info exists ::gui_cata::size_ucac3] } {
         if {[info exists conf(astrometry,cata,size_ucac3)]} {
            set ::gui_cata::size_ucac3 $conf(astrometry,cata,size_ucac3)
         } else {
            set ::gui_cata::size_ucac3 1
         }
      }
      set ::gui_cata::size_ucac3_sav $::gui_cata::size_ucac3
      
      if {! [info exists ::gui_cata::size_ucac4] } {
         if {[info exists conf(astrometry,cata,size_ucac4)]} {
            set ::gui_cata::size_ucac4 $conf(astrometry,cata,size_ucac4)
         } else {
            set ::gui_cata::size_ucac4 1
         }
      }
      set ::gui_cata::size_ucac4_sav $::gui_cata::size_ucac4

      if {! [info exists ::gui_cata::size_ppmx] } {
         if {[info exists conf(astrometry,cata,size_ppmx)]} {
            set ::gui_cata::size_ppmx $conf(astrometry,cata,size_ppmx)
         } else {
            set ::gui_cata::size_ppmx 1
         }
      }
      set ::gui_cata::size_ppmx_sav $::gui_cata::size_ppmx

      if {! [info exists ::gui_cata::size_ppmxl] } {
         if {[info exists conf(astrometry,cata,size_ppmxl)]} {
            set ::gui_cata::size_ppmxl $conf(astrometry,cata,size_ppmxl)
         } else {
            set ::gui_cata::size_ppmxl 1
         }
      }
      set ::gui_cata::size_ppmxl_sav $::gui_cata::size_ppmxl

      if {! [info exists ::gui_cata::size_nomad1] } {
         if {[info exists conf(astrometry,cata,size_nomad1)]} {
            set ::gui_cata::size_nomad1 $conf(astrometry,cata,size_nomad1)
         } else {
            set ::gui_cata::size_nomad1 1
         }
      }
      set ::gui_cata::size_nomad1_sav $::gui_cata::size_nomad1
      
      if {! [info exists ::gui_cata::size_tycho2] } {
         if {[info exists conf(astrometry,cata,size_tycho2)]} {
            set ::gui_cata::size_tycho2 $conf(astrometry,cata,size_tycho2)
         } else {
            set ::gui_cata::size_tycho2 1
         }
      }
      set ::gui_cata::size_tycho2_sav $::gui_cata::size_tycho2
      
      if {! [info exists ::gui_cata::size_skybot] } {
         if {[info exists conf(astrometry,cata,size_skybot)]} {
            set ::gui_cata::size_skybot $conf(astrometry,cata,size_skybot)
         } else {
            set ::gui_cata::size_skybot 1
         }
      }
      set ::gui_cata::size_skybot_sav $::gui_cata::size_skybot
      
      if {! [info exists ::gui_cata::size_ovni] } {
         if {[info exists conf(astrometry,cata,size_ovni)]} {
            set ::gui_cata::size_ovni $conf(astrometry,cata,size_ovni)
         } else {
            set ::gui_cata::size_ovni 1
         }
      }

      # Uncosmic or not
      if {! [info exists ::gui_cata::use_uncosmic] } {
         if {[info exists conf(astrometry,cata,use_uncosmic)]} {
            set ::gui_cata::use_uncosmic $conf(astrometry,cata,use_uncosmic)
         } else {
            set ::gui_cata::use_uncosmic 1
         }
      }
      if {! [info exists ::tools_cdl::uncosm_param1] } {
         if {[info exists conf(astrometry,cata,uncosm_param1)]} {
            set ::tools_cdl::uncosm_param1 $conf(astrometry,cata,uncosm_param1)
         } else {
            set ::tools_cdl::uncosm_param1 0.8
         }
      }
      if {! [info exists ::tools_cdl::uncosm_param2] } {
         if {[info exists conf(astrometry,cata,uncosm_param2)]} {
            set ::tools_cdl::uncosm_param2 $conf(astrometry,cata,uncosm_param2)
         } else {
            set ::tools_cdl::uncosm_param2 100
         }
      }


      set ::tools_cata::nb_img     0
      set ::tools_cata::nb_usnoa2  0
      set ::tools_cata::nb_tycho2  0
      set ::tools_cata::nb_ppmx    0
      set ::tools_cata::nb_ppmxl   0
      set ::tools_cata::nb_ucac2   0
      set ::tools_cata::nb_ucac3   0
      set ::tools_cata::nb_ucac4   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0

   }


   proc ::gui_cata::closetoconf { } {

      global conf

      set conf(astrometry,cata,gui_img)    $::gui_cata::gui_img
      set conf(astrometry,cata,gui_usnoa2) $::gui_cata::gui_usnoa2
      set conf(astrometry,cata,gui_ucac2)  $::gui_cata::gui_ucac2
      set conf(astrometry,cata,gui_ucac3)  $::gui_cata::gui_ucac3
      set conf(astrometry,cata,gui_ucac4)  $::gui_cata::gui_ucac4
      set conf(astrometry,cata,gui_ppmx)   $::gui_cata::gui_ppmx
      set conf(astrometry,cata,gui_ppmxl)  $::gui_cata::gui_ppmxl
      set conf(astrometry,cata,gui_tycho2) $::gui_cata::gui_tycho2
      set conf(astrometry,cata,gui_nomad1) $::gui_cata::gui_nomad1
      set conf(astrometry,cata,gui_skybot) $::gui_cata::gui_skybot
      
      # Uncosmic or not!
      set conf(astrometry,cata,use_uncosmic)  $::gui_cata::use_uncosmic
      set conf(astrometry,cata,uncosm_param1) $::tools_cdl::uncosm_param1
      set conf(astrometry,cata,uncosm_param2) $::tools_cdl::uncosm_param2

      # Taille des ronds
      set conf(astrometry,cata,size_img)    $::gui_cata::size_img
      set conf(astrometry,cata,size_usnoa2) $::gui_cata::size_usnoa2
      set conf(astrometry,cata,size_ucac2)  $::gui_cata::size_ucac2
      set conf(astrometry,cata,size_ucac3)  $::gui_cata::size_ucac3
      set conf(astrometry,cata,size_ucac4)  $::gui_cata::size_ucac4
      set conf(astrometry,cata,size_ppmx)   $::gui_cata::size_ppmx
      set conf(astrometry,cata,size_ppmxl)   $::gui_cata::size_ppmxl
      set conf(astrometry,cata,size_nomad1) $::gui_cata::size_nomad1
      set conf(astrometry,cata,size_tycho2) $::gui_cata::size_tycho2
      set conf(astrometry,cata,size_skybot) $::gui_cata::size_skybot
      set conf(astrometry,cata,size_ovni)   $::gui_cata::size_ovni

   }




   proc ::gui_cata::affiche_current_image { } {

      global bddconf

      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      buf$::audace(bufNo) load $file
      if {$::gui_cata::use_uncosmic} {
         ::tools_cdl::myuncosmic $::audace(bufNo)
      }
      ::audace::autovisu $::audace(visuNo)

   }







   
   proc ::gui_cata::loadDSS { fichier_fits_dss ra dec fov_x_deg fov_y_deg naxis1 naxis2 crota2} {
      set url "http://skyview.gsfc.nasa.gov/cgi-bin/runquery.pl"
      set sentence "Position=%s,%s&Size=%s,%s&Pixels=%s,%s&Rotation=%s&Survey=DSS&Scaling=Linear&Projection=Tan&Coordinates=J2000&Return=FITS"
      set query [ format $sentence [mc_angle2deg $ra] [mc_angle2deg $dec 90] $fov_x_deg $fov_y_deg $naxis1 $naxis2 $crota2 ]
      ::gui_cata::downloadURL "$url" "$query" $fichier_fits_dss
   }










   proc ::gui_cata::downloadURL { url query fichier } {
      package require http
      set tok [ ::http::geturl "$url" -query "$query" ]
      upvar #0 $tok state   
      set f [ open $fichier w ]
      fconfigure $f -translation binary
      puts -nonewline $f [ ::http::data $tok ]
      close $f
      ::http::cleanup $tok
   }
   


   proc ::gui_cata::getDSS { } {

      if {$::tools_cata::radius == ""} { set ::tools_cata::radius 15.0 }
      if {$::tools_cata::crota == ""} { set ::tools_cata::crota 0.0 }

      set naxis1 600
      set naxis2 600
      set fov_x_deg [expr $::tools_cata::radius/60.]
      set fov_y_deg [expr $::tools_cata::radius/60.]
      ::gui_cata::loadDSS dss.fit $::tools_cata::ra $::tools_cata::dec $fov_x_deg $fov_y_deg $naxis1 $naxis2 $::tools_cata::crota

      set ::gui_cata::dssvisu [ ::confVisu::create ]
      set ::gui_cata::dssbuf  [ visu$::gui_cata::dssvisu buf   ]
      buf$::gui_cata::dssbuf load dss.fit
      buf$::gui_cata::dssbuf setkwd {CROTA2 $crota2 double "" ""}
      ::audace::autovisu $::gui_cata::dssvisu

   }








   proc ::gui_cata::charge_list { img_list } {

      ::tools_cata::charge_list $img_list

      #?Charge l image a l ecran
      buf$::audace(bufNo) load $::tools_cata::file
      cleanmark
      affich_un_rond_xy $::tools_cata::xcent $::tools_cata::ycent red 2 2

      ::gui_cata::affiche_current_image
      ::gui_cata::affiche_cata
   }















# Anciennement ::gui_cata::load_cata

   proc ::gui_cata::load_cata {  } {

      global bddconf

      set catafilenameexist [::bddimages_liste::lexist $::tools_cata::current_image "catafilename"]
      if {$catafilenameexist==0} {return}

      set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
         
      set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
      set errnum [catch {set catafile [::tools_cata::extract_cata_xml $catafile]} msg ]
      if {$errnum} {
         return -code $errnum $msg
      }
      
      set listsources [::tools_cata::get_cata_xml $catafile]
      set listsources [::tools_sources::set_common_fields $listsources IMG     { ra dec 5.0 calib_mag_ss2 err_calib_mag_ss2}]
      set listsources [::tools_sources::set_common_fields $listsources USNOA2  { ra_deg dec_deg 5.0 magR 0.5 }]
      set listsources [::tools_sources::set_common_fields $listsources UCAC2   { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
      set listsources [::tools_sources::set_common_fields $listsources UCAC3   { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
      set listsources [::tools_sources::set_common_fields $listsources UCAC4   { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
#### TODO
#      set listsources [::tools_sources::set_common_fields $listsources PPMX   {  }]
#      set listsources [::tools_sources::set_common_fields $listsources PPMXL  {  }]
      set listsources [::tools_sources::set_common_fields $listsources TYCHO2  { RAdeg DEdeg 5.0 VT e_VT }]
      set listsources [::tools_sources::set_common_fields_skybot $listsources]
      set listsources [::tools_sources::set_common_fields $listsources ASTROID { ra dec 5.0 mag err_mag }]
      set ::tools_cata::current_listsources $listsources

   }








# Anciennement ::gui_cata::save_cata
   
   proc ::gui_cata::save_cata {  } {

      global bddconf

      set id_current_image 0
      foreach current_image $::tools_cata::img_list {

         # Tabkey
         set tabkey [::bddimages_liste::lget $current_image "tabkey"]
         # Liste des sources
         incr id_current_image
         set listsources $::gui_cata::cata_list($id_current_image)
         # Noms du fichier cata
         set imgfilename [::bddimages_liste::lget $current_image filename]
         set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
         set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
         set cataxml "${f}_cata.xml"

         ::tools_cata::save_cata $listsources $tabkey $cataxml

      }

   }







# Anciennement ::gui_cata::affiche_cata

   proc ::gui_cata::affiche_cata { } {


      cleanmark
      set err [catch {

         set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
         if {$cataexist==0} {return}
   
         set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
         if {$cataexist!=1} {
            return -code 0 "NOCATA"
         }
          
         if {[::bddimages_liste::lget $::tools_cata::current_image "cataexist"]=="1"} {
            ::gui_cata::load_cata
         } else {
            return -code 0 "NOCATA"
         }
   
         if {$::gui_cata::gui_img} {
            affich_rond $::tools_cata::current_listsources IMG $::gui_cata::color_img $::gui_cata::size_img 
         }

         if { $::gui_cata::gui_usnoa2 } { affich_rond $::tools_cata::current_listsources USNOA2 $::gui_cata::color_usnoa2 $::gui_cata::size_usnoa2 }
         if { $::gui_cata::gui_ucac2  } { affich_rond $::tools_cata::current_listsources UCAC2  $::gui_cata::color_ucac2  $::gui_cata::size_ucac2  }
         if { $::gui_cata::gui_ucac3  } { affich_rond $::tools_cata::current_listsources UCAC3  $::gui_cata::color_ucac3  $::gui_cata::size_ucac3  }
         if { $::gui_cata::gui_ucac4  } { affich_rond $::tools_cata::current_listsources UCAC4  $::gui_cata::color_ucac4  $::gui_cata::size_ucac4  }
         if { $::gui_cata::gui_ppmx   } { affich_rond $::tools_cata::current_listsources PPMX   $::gui_cata::color_ppmx   $::gui_cata::size_ppmx   }
         if { $::gui_cata::gui_ppmxl  } { affich_rond $::tools_cata::current_listsources PPMXL  $::gui_cata::color_ppmxl  $::gui_cata::size_ppmxl  }
         if { $::gui_cata::gui_tycho2 } { affich_rond $::tools_cata::current_listsources TYCHO2 $::gui_cata::color_tycho2 $::gui_cata::size_tycho2 }
         if { $::gui_cata::gui_nomad1 } { affich_rond $::tools_cata::current_listsources NOMAD1 $::gui_cata::color_nomad1 $::gui_cata::size_nomad1 }
         if { $::gui_cata::gui_skybot } { affich_rond $::tools_cata::current_listsources SKYBOT $::gui_cata::color_skybot $::gui_cata::size_skybot }

      } msg ]

      if {$err} {
         if {$msg=="NOCATA"} {return}
         ::console::affiche_erreur "ERREUR affiche_cata : $msg\n" 
         #set ::tools_cata::current_listsources [::tools_sources::set_common_fields_skybot $::tools_cata::current_listsources]
         #::tools_sources::imprim_3_sources $::tools_cata::current_listsources SKYBOT
      }

   }















   proc ::gui_cata::voir_cata { img_list } {

      global audace
      global bddconf

      ::gui_cata::inittoconf
      set uncosmic_status $::gui_cata::use_uncosmic
      set ::gui_cata::use_uncosmic 0
      ::gui_cata::charge_list $img_list
      set ::gui_cata::use_uncosmic $uncosmic_status

      # Update nb sources du cata
      set ::tools_cata::nb_img [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources IMG]
      set ::tools_cata::nb_usnoa2 [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources USNOA2]
      set ::tools_cata::nb_tycho2 [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources TYCHO2]
      set ::tools_cata::nb_ucac2 [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources UCAC2]
      set ::tools_cata::nb_ucac3 [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources UCAC3]
      set ::tools_cata::nb_ucac4 [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources UCAC4]
      set ::tools_cata::nb_ppmx [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources PPMX]
      set ::tools_cata::nb_ppmxl [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources PPMXL]
      set ::tools_cata::nb_nomad1 [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources NOMAD1]
      set ::tools_cata::nb_skybot [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources SKYBOT]
      set ::tools_cata::nb_astroid [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources ASTROID]

      #--- Creation de la fenetre
      set ::gui_cata::fenv .new
      if { [winfo exists $::gui_cata::fenv] } {
         wm withdraw $::gui_cata::fenv
         wm deiconify $::gui_cata::fenv
         focus $::gui_cata::fenv
         return
      }
      toplevel $::gui_cata::fenv -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cata::fenv ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cata::fenv ] "+" ] 2 ]
      wm geometry $::gui_cata::fenv +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cata::fenv 1 1
      wm title $::gui_cata::fenv "Voir le CATA"
      wm protocol $::gui_cata::fenv WM_DELETE_WINDOW "destroy $::gui_cata::fenv"

      set frm $::gui_cata::fenv.frm_voir_cata
      set ::gui_cata::current_appli $frm

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata::fenv -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      set f4 [frame $frm.f4]
      pack $f4 -in $frm

              #--- Cree un frame pour afficher 
        set count [frame $f4.count -borderwidth 0 -cursor arrow -relief groove]
        pack $count -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un frame pour afficher 
           set img [frame $count.img -borderwidth 0 -cursor arrow -relief groove]
           pack $img -in $count -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                checkbutton $img.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_img -state normal \
                      -command "::gui_cata::affiche_cata"
                pack $img.check -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.name -text "SOURCES (IMG) :" -width 14 -anchor e
                pack $img.name -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.val -textvariable ::tools_cata::nb_img -width 4
                pack $img.val -in $img -side left -padx 3 -pady 3
                button $img.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_img -command ""
                pack $img.color -side left -anchor e -expand 0 
                spinbox $img.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_img -command "::gui_cata::affiche_cata" -width 3
                pack  $img.radius -in $img -side left -anchor w
                $img.radius set $::gui_cata::size_img_sav
                
                
           #--- Cree un frame pour afficher USNOA2
           set usnoa2 [frame $count.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
           pack $usnoa2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $usnoa2.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_usnoa2 -state normal \
                      -command "::gui_cata::affiche_cata"
                pack $usnoa2.check -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.name -text "USNOA2 :" -width 14 -anchor e
                pack $usnoa2.name -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.val -textvariable ::tools_cata::nb_usnoa2 -width 4
                pack $usnoa2.val -in $usnoa2 -side left -padx 3 -pady 3
                button $usnoa2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_usnoa2 -command ""
                pack $usnoa2.color -side left -anchor e -expand 0 
                spinbox $usnoa2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_usnoa2 -command "::gui_cata::affiche_cata" -width 3
                pack  $usnoa2.radius -in $usnoa2 -side left -anchor w
                $usnoa2.radius set $::gui_cata::size_usnoa2_sav

           #--- Cree un frame pour afficher UCAC2
           set ucac2 [frame $count.ucac2 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac2.check -highlightthickness 0  \
                      -variable ::gui_cata::gui_ucac2 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $ucac2.check -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.name -text "UCAC2 :" -width 14 -anchor e
                pack $ucac2.name -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.val -textvariable ::tools_cata::nb_ucac2 -width 4
                pack $ucac2.val -in $ucac2 -side left -padx 3 -pady 3
                button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac2 \
                        -command {set ::gui_cata::color_ucac2 [tk_chooseColor -initialcolor $::gui_cata::color_ucac2 -title "Choose color"]; wm withdraw}
                pack $ucac2.color -side left -anchor e -expand 0 
                spinbox $ucac2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_ucac2 -command "::gui_cata::affiche_cata" -width 3
                pack  $ucac2.radius -in $ucac2 -side left -anchor w
                $ucac2.radius set $::gui_cata::size_ucac2_sav

           #--- Cree un frame pour afficher UCAC3
           set ucac3 [frame $count.ucac3 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac3 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac3.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_ucac3 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $ucac3.check -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.name -text "UCAC3 :" -width 14 -anchor e
                pack $ucac3.name -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.val -textvariable ::tools_cata::nb_ucac3 -width 4
                pack $ucac3.val -in $ucac3 -side left -padx 3 -pady 3
                button $ucac3.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac3 -command ""
                pack $ucac3.color -side left -anchor e -expand 0 
                spinbox $ucac3.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_ucac3 -command "::gui_cata::affiche_cata" -width 3
                pack  $ucac3.radius -in $ucac3 -side left -anchor w
                $ucac3.radius set $::gui_cata::size_ucac3_sav

           #--- Cree un frame pour afficher UCAC4
           set ucac4 [frame $count.ucac4 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac4 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac4.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_ucac4 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $ucac4.check -in $ucac4 -side left -padx 3 -pady 3 -anchor w 
                label $ucac4.name -text "UCAC4 :" -width 14 -anchor e
                pack $ucac4.name -in $ucac4 -side left -padx 3 -pady 3 -anchor w 
                label $ucac4.val -textvariable ::tools_cata::nb_ucac4 -width 4
                pack $ucac4.val -in $ucac4 -side left -padx 3 -pady 3
                button $ucac4.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac4 -command ""
                pack $ucac4.color -side left -anchor e -expand 0 
                spinbox $ucac4.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_ucac4 -command "::gui_cata::affiche_cata" -width 3
                pack  $ucac4.radius -in $ucac4 -side left -anchor w

           #--- Cree un frame pour afficher PPMX
           set ppmx [frame $count.ppmx -borderwidth 0 -cursor arrow -relief groove]
           pack $ppmx -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ppmx.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_ppmx -state normal  \
                      -command "::gui_cata::affiche_cata"\
                      -state disable
                pack $ppmx.check -in $ppmx -side left -padx 3 -pady 3 -anchor w 
                label $ppmx.name -text "PPMX :" -width 14 -anchor e
                pack $ppmx.name -in $ppmx -side left -padx 3 -pady 3 -anchor w 
                label $ppmx.val -textvariable ::tools_cata::nb_ppmx -width 4
                pack $ppmx.val -in $ppmx -side left -padx 3 -pady 3
                button $ppmx.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ppmx -command ""
                pack $ppmx.color -side left -anchor e -expand 0 
                spinbox $ppmx.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_ppmx -command "::gui_cata::affiche_cata" -width 3
                pack  $ppmx.radius -in $ppmx -side left -anchor w

           #--- Cree un frame pour afficher PPMXL
           set ppmxl [frame $count.ppmxl -borderwidth 0 -cursor arrow -relief groove]
           pack $ppmxl -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ppmxl.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_ppmxl -state normal  \
                      -command "::gui_cata::affiche_cata" \
                      -state disable
                pack $ppmxl.check -in $ppmxl -side left -padx 3 -pady 3 -anchor w 
                label $ppmxl.name -text "PPMXL :" -width 14 -anchor e
                pack $ppmxl.name -in $ppmxl -side left -padx 3 -pady 3 -anchor w 
                label $ppmxl.val -textvariable ::tools_cata::nb_ppmxl -width 4
                pack $ppmxl.val -in $ppmxl -side left -padx 3 -pady 3
                button $ppmxl.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ppmxl -command ""
                pack $ppmxl.color -side left -anchor e -expand 0 
                spinbox $ppmxl.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_ppmxl -command "::gui_cata::affiche_cata" -width 3
                pack  $ppmxl.radius -in $ppmxl -side left -anchor w

           #--- Cree un frame pour afficher TYCHO2
           set tycho2 [frame $count.tycho2 -borderwidth 0 -cursor arrow -relief groove]
           pack $tycho2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $tycho2.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_tycho2 -state normal \
                      -command "::gui_cata::affiche_cata"
                pack $tycho2.check -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.name -text "TYCHO2 :" -width 14 -anchor e
                pack $tycho2.name -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.val -textvariable ::tools_cata::nb_tycho2 -width 4
                pack $tycho2.val -in $tycho2 -side left -padx 3 -pady 3
                button $tycho2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_tycho2 -command ""
                pack $tycho2.color -side left -anchor e -expand 0 
                spinbox $tycho2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_tycho2 -command "::gui_cata::affiche_cata" -width 3
                pack  $tycho2.radius -in $tycho2 -side left -anchor w
                $tycho2.radius set $::gui_cata::size_tycho2_sav

           #--- Cree un frame pour afficher NOMAD1
           set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
           pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $nomad1.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_nomad1 -state normal  \
                      -command "::gui_cata::affiche_cata"\
                      -state disable
                pack $nomad1.check -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.name -text "NOMAD1 :" -width 14 -anchor e
                pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.val -textvariable ::tools_cata::nb_nomad1 -width 4
                pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
                button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_nomad1 -command ""
                pack $nomad1.color -side left -anchor e -expand 0 
                spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_nomad1 -command "::gui_cata::affiche_cata" -width 3
                pack  $nomad1.radius -in $nomad1 -side left -anchor w
                $nomad1.radius set $::gui_cata::size_nomad1_sav

           #--- Cree un frame pour afficher SKYBOT
           set skybot [frame $count.skybot -borderwidth 0 -cursor arrow -relief groove]
           pack $skybot -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $skybot.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_skybot -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $skybot.check -in $skybot -side left -padx 3 -pady 3 -anchor w 
                label $skybot.name -text "SKYBOT :" -width 14 -anchor e
                pack $skybot.name -in $skybot -side left -padx 3 -pady 3 -anchor w 
                label $skybot.val -textvariable ::tools_cata::nb_skybot -width 4
                pack $skybot.val -in $skybot -side left -padx 3 -pady 3
                button $skybot.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_skybot -command ""
                pack $skybot.color -side left -anchor e -expand 0 
                spinbox $skybot.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_skybot -command "::gui_cata::affiche_cata" -width 3
                pack  $skybot.radius -in $skybot -side left -anchor w
                $skybot.radius set $::gui_cata::size_skybot
                
        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied -in $frm -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

             set ::gui_cata::gui_refresh [button $boutonpied.refresh -text "Refresh" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::affiche_cata"]
             pack $boutonpied.refresh -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command {cleanmark; destroy $::gui_cata::fenv}]
             pack $boutonpied.fermer -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }
















   #
   # Astrometrie: supprime une source de reference (de la table srpt) dans toutes les images
   #
   proc ::gui_cata::unset_srpt {  } {
      
      set color red
      set width 2

      if {![winfo exists .gestion_cata.appli.onglets.nb]} {
         tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
         return
      }

      cleanmark

      # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
      set onglets .gestion_cata.appli.onglets.nb
      array set cataname $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
      foreach {x y} [array get cataname] {
         set tabid($y) $x
      }
      set idcata_astroid $tabid(ASTROID)
      $onglets select $onglets.f$idcata_astroid
      set f [$onglets select]

      # Selectionne chaque source
      foreach select [$::gui_astrometry::srpt curselection] {
         
         set data [$::gui_astrometry::srpt get $select]
         set name [lindex $data 0]
         set date $::tools_cata::current_image_date
         set id [lindex $::tools_astrometry::tabval($name,$date) 0]

         set u 0
         foreach x [$f.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               $f.frmtable.tbl selection set $u
               set ra  [lindex $x [::gui_cata::get_pos_col ra]]
               set dec [lindex $x [::gui_cata::get_pos_col dec]]
               affich_un_rond $ra $dec $color $width
            }
            incr u
         }
         
      }

      # Unset les sources
      ::cata_gestion_gui::unset_flag $f.frmtable.tbl
      # Propage les sources
      ::cata_gestion_gui::propagation $f.frmtable.tbl
   }














   #
   # Astrometrie: supprime une source de reference (de la table srpt) dans l'image selectionnee
   #
   proc ::gui_cata::unset_sret {  } {
      
      set color red

      set width 2
      if {![winfo exists .gestion_cata.appli.onglets.nb]} {
         tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
         return
      }

      cleanmark

      # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
      set onglets .gestion_cata.appli.onglets.nb
      array set cataname $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
      foreach {x y} [array get cataname] {
         set tabid($y) $x
      }
      set idcata_astroid $tabid(ASTROID)
      $onglets select $onglets.f$idcata_astroid
      set f [$onglets select]

      # Selectionne chaque source
      foreach select [$::gui_astrometry::sret curselection] {
         
         set data [$::gui_astrometry::sret get $select]
         set id [lindex $data 0]
         set date [lindex $data 1]

         set u 0
         foreach x [$f.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               $f.frmtable.tbl selection set $u
               set ra  [lindex $x [::gui_cata::get_pos_col ra]]
               set dec [lindex $x [::gui_cata::get_pos_col dec]]
               affich_un_rond $ra $dec $color $width
            }
            incr u
         }
         
      }
      
      # Unset les sources
      ::cata_gestion_gui::unset_flag $f.frmtable.tbl

   }








   proc ::gui_cata::get_pos_col { name { idcata 1 } } {

      if {![info exists idcata]} {set idcata 1}
      
      set list_of_columns $::gui_cata::tklist_list_of_columns($idcata)

      set cpt 0
      foreach { c } $list_of_columns {
         set a [split $c " "]
         set b [lindex $a 1]
         set a [lindex $a 0]
         if {$a==$name} {
            return $cpt
         }
         incr cpt
      }
      
      return -1

   }












   proc ::gui_cata::voir_sxpt { w } {
      
      set color red
      set width 2

      if {![winfo exists .gestion_cata.appli.onglets.nb]} {
         tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
         return
      }

      cleanmark

      set onglets [.gestion_cata.appli.onglets.nb tabs]
      set f [.gestion_cata.appli.onglets.nb select]

      foreach select [$w curselection] {
         set data [$w get $select]
         set name [lindex $data 0]
         set date $::tools_cata::current_image_date
         set id [lindex $::tools_astrometry::tabval($name,$date) 0]

         gren_info "voir_sxpt name = $name\n"
         gren_info "voir_sxpt date = $date\n"
         gren_info "voir_sxpt id   = $id\n"


         set u 0
         foreach x [$f.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               #$f.frmtable.tbl selection set $u
               set ra  [lindex $x [::gui_cata::get_pos_col ra]]
               set dec [lindex $x [::gui_cata::get_pos_col dec]]
               affich_un_rond $ra $dec $color $width
            }
            incr u
         }
         
      }
   
   }


















   
   proc ::gui_cata::voir_dset { w } {
      
      set color red
      set width 2

      if {![winfo exists .gestion_cata.appli.onglets.nb]} {
         tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
         return
      }

      cleanmark
      set onglets [.gestion_cata.appli.onglets.nb tabs]
      set f [.gestion_cata.appli.onglets.nb select]

      foreach select [$w curselection] {
         set data [$w get $select]
         set name [lindex $data 1]
         set date $::tools_cata::current_image_date
         set id [lindex $::tools_astrometry::tabval($name,$date) 0]

         if {![winfo exists .gestion_cata.appli.onglets.nb]} {
            return
         }

         set u 0
         foreach x [$f.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               #$f.frmtable.tbl selection set $u
               set ra  [lindex $x [::gui_cata::get_pos_col ra]]
               set dec [lindex $x [::gui_cata::get_pos_col dec]]
               affich_un_rond $ra $dec $color $width
            }
            incr u
         }
         
      }
   
   }

   

   
   
   
   
   










# Fin Classe
}

