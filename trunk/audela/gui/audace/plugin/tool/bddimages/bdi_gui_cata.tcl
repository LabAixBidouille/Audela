#--------------------------------------------------
# source audace/plugin/tool/bddimages/bdi_gui_cata.tcl
#--------------------------------------------------
#
# Fichier        : bdi_gui_cata.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : FrÃ©dÃ©ric Vachier
# Mise Ã  jour $Id: bdi_gui_cata.tcl 6858 2011-03-06 14:19:15Z fredvachier $
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
   variable gui_tycho2
   variable gui_nomad1
   variable gui_skybot

   variable size_img
   variable size_usnoa2
   variable size_ucac2
   variable size_ucac3
   variable size_nomad1
   variable size_tycho2
   variable size_skybot
   variable size_ovni

   variable color_img     "blue"
   variable color_usnoa2  "green"
   variable color_ucac2   "cyan"
   variable color_ucac3   "red"
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





   #
   # initToConf
   # Initialisation des variables de configuration
   #
   proc ::gui_cata::inittoconf {  } {

      global bddconf, conf

#/srv/astrodata/Catalog/USNOA2/
#/srv/astrodata/Catalog/TYCHO-2/
#/srv/astrodata/Catalog/UCAC2/
#/srv/astrodata/Catalog/UCAC3/
#/srv/astrodata/Catalog/NOMAD1/

      # Check button Use
      if {! [info exists ::tools_cata::use_usnoa2] } {
         if {[info exists conf(astrometry,cata,use_usnoa2)]} {
            set ::tools_cata::use_usnoa2 $conf(astrometry,cata,use_usnoa2)
         } else {
            set ::tools_cata::use_usnoa2 1
         }
      }
      if {! [info exists ::tools_cata::use_ucac2] } {
         if {[info exists conf(astrometry,cata,use_ucac2)]} {
            set ::tools_cata::use_ucac2 $conf(astrometry,cata,use_ucac2)
         } else {
            set ::tools_cata::use_ucac2 0
         }
      }
      if {! [info exists ::tools_cata::use_ucac3] } {
         if {[info exists conf(astrometry,cata,use_ucac3)]} {
            set ::tools_cata::use_ucac3 $conf(astrometry,cata,use_ucac3)
         } else {
            set ::tools_cata::use_ucac3 0
         }
      }
      if {! [info exists ::tools_cata::use_tycho2] } {
         if {[info exists conf(astrometry,cata,use_tycho2)]} {
            set ::tools_cata::use_tycho2 $conf(astrometry,cata,use_tycho2)
         } else {
            set ::tools_cata::use_tycho2 0
         }
      }
      if {! [info exists ::tools_cata::use_nomad1] } {
         if {[info exists conf(astrometry,cata,use_nomad1)]} {
            set ::tools_cata::use_nomad1 $conf(astrometry,cata,use_nomad1)
         } else {
            set ::tools_cata::use_nomad1 0
         }
      }
      if {! [info exists ::tools_cata::use_skybot] } {
         if {[info exists conf(astrometry,cata,use_skybot)]} {
            set ::tools_cata::use_skybot $conf(astrometry,cata,use_skybot)
         } else {
            set ::tools_cata::use_skybot 0
         }
      }

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

      # Repertoires 
      if {! [info exists ::tools_cata::catalog_usnoa2] } {
         if {[info exists conf(astrometry,catfolder,usnoa2)]} {
            set ::tools_cata::catalog_usnoa2 $conf(astrometry,catfolder,usnoa2)
         } else {
            set ::tools_cata::catalog_usnoa2 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ucac2] } {
         if {[info exists conf(astrometry,catfolder,ucac2)]} {
            set ::tools_cata::catalog_ucac2 $conf(astrometry,catfolder,ucac2)
         } else {
            set ::tools_cata::catalog_ucac2 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ucac3] } {
         if {[info exists conf(astrometry,catfolder,ucac3)]} {
            set ::tools_cata::catalog_ucac3 $conf(astrometry,catfolder,ucac3)
         } else {
            set ::tools_cata::catalog_ucac3 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_tycho2] } {
         if {[info exists conf(astrometry,catfolder,tycho2)]} {
            set ::tools_cata::catalog_tycho2 $conf(astrometry,catfolder,tycho2)
         } else {
            set ::tools_cata::catalog_tycho2 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_nomad1] } {
         if {[info exists conf(astrometry,catfolder,nomad1)]} {
            set ::tools_cata::catalog_nomad1 $conf(astrometry,catfolder,nomad1)
         } else {
            set ::tools_cata::catalog_nomad1 ""
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
      if {! [info exists ::gui_cata::size_usnoa2] } {
         if {[info exists conf(astrometry,cata,size_usnoa2)]} {
            set ::gui_cata::size_usnoa2 $conf(astrometry,cata,size_usnoa2)
         } else {
            set ::gui_cata::size_usnoa2 1
         }
      }
      if {! [info exists ::gui_cata::size_ucac2] } {
         if {[info exists conf(astrometry,cata,size_ucac2)]} {
            set ::gui_cata::size_ucac2 $conf(astrometry,cata,size_ucac2)
         } else {
            set ::gui_cata::size_ucac2 1
         }
      }
      if {! [info exists ::gui_cata::size_ucac3] } {
         if {[info exists conf(astrometry,cata,size_ucac3)]} {
            set ::gui_cata::size_ucac3 $conf(astrometry,cata,size_ucac3)
         } else {
            set ::gui_cata::size_ucac3 1
         }
      }
      if {! [info exists ::gui_cata::size_nomad1] } {
         if {[info exists conf(astrometry,cata,size_nomad1)]} {
            set ::gui_cata::size_nomad1 $conf(astrometry,cata,size_nomad1)
         } else {
            set ::gui_cata::size_nomad1 1
         }
      }
      if {! [info exists ::gui_cata::size_tycho2] } {
         if {[info exists conf(astrometry,cata,size_tycho2)]} {
            set ::gui_cata::size_tycho2 $conf(astrometry,cata,size_tycho2)
         } else {
            set ::gui_cata::size_tycho2 1
         }
      }
      if {! [info exists ::gui_cata::size_skybot] } {
         if {[info exists conf(astrometry,cata,size_skybot)]} {
            set ::gui_cata::size_skybot $conf(astrometry,cata,size_skybot)
         } else {
            set ::gui_cata::size_skybot 1
         }
      }
      if {! [info exists ::gui_cata::size_ovni] } {
         if {[info exists conf(astrometry,cata,size_ovni)]} {
            set ::gui_cata::size_ovni $conf(astrometry,cata,size_ovni)
         } else {
            set ::gui_cata::size_ovni 1
         }
      }

      # Autres utilitaires
      if {! [info exists ::tools_cata::keep_radec] } {
         if {[info exists conf(astrometry,cata,keep_radec)]} {
            set ::tools_cata::keep_radec $conf(astrometry,cata,keep_radec)
         } else {
            set ::tools_cata::keep_radec 1
         }
      }
      if {! [info exists ::tools_cata::create_cata] } {
         if {[info exists conf(astrometry,cata,create_cata)]} {
            set ::tools_cata::create_cata $conf(astrometry,cata,create_cata)
         } else {
            set ::tools_cata::create_cata 1
         }
      }
      if {! [info exists ::tools_cata::delpv] } {
         if {[info exists conf(astrometry,cata,delpv)]} {
            set ::tools_cata::delpv $conf(astrometry,cata,delpv)
         } else {
            set ::tools_cata::delpv 1
         }
      }
      if {! [info exists ::tools_cata::boucle] } {
         if {[info exists conf(astrometry,cata,boucle)]} {
            set ::tools_cata::boucle $conf(astrometry,cata,boucle)
         } else {
            set ::tools_cata::boucle 0
         }
      }
      if {! [info exists ::tools_cata::deuxpasses] } {
         if {[info exists conf(astrometry,cata,deuxpasses)]} {
            set ::tools_cata::deuxpasses $conf(astrometry,cata,deuxpasses)
         } else {
            set ::tools_cata::deuxpasses 1
         }
      }
      if {! [info exists ::tools_cata::limit_nbstars_accepted] } {
         if {[info exists conf(astrometry,cata,limit_nbstars_accepted)]} {
            set ::tools_cata::limit_nbstars_accepted $conf(astrometry,cata,limit_nbstars_accepted)
         } else {
            set ::tools_cata::limit_nbstars_accepted 5
         }
      }
      if {! [info exists ::tools_cata::log] } {
         if {[info exists conf(astrometry,cata,log)]} {
            set ::tools_cata::log $conf(astrometry,cata,log)
         } else {
            set ::tools_cata::log 0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_pos_star] } {
         if {[info exists conf(astrometry,cata,treshold_ident_pos_star)]} {
            set ::tools_cata::treshold_ident_pos_star $conf(astrometry,cata,treshold_ident_pos_star)
         } else {
            set ::tools_cata::treshold_ident_pos_star 30.0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_mag_star] } {
         if {[info exists conf(astrometry,cata,treshold_ident_mag_star)]} {
            set ::tools_cata::treshold_ident_mag_star $conf(astrometry,cata,treshold_ident_mag_star)
         } else {
            set ::tools_cata::treshold_ident_mag_star -30.0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_pos_ast] } {
         if {[info exists conf(astrometry,cata,treshold_ident_pos_ast)]} {
            set ::tools_cata::treshold_ident_pos_ast $conf(astrometry,cata,treshold_ident_pos_ast)
         } else {
            set ::tools_cata::treshold_ident_pos_ast 10.0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_mag_ast] } {
         if {[info exists conf(astrometry,cata,treshold_ident_mag_ast)]} {
            set ::tools_cata::treshold_ident_mag_ast $conf(astrometry,cata,treshold_ident_mag_ast)
         } else {
            set ::tools_cata::treshold_ident_mag_ast -100.0
         }
      }

      # Lib du compilateur Fortran pour executer Priam
      if {! [info exists ::tools_astrometry::ifortlib] } {
         if {[info exists conf(bddimages,cata,ifortlib)]} {
            set ::tools_astrometry::ifortlib $conf(bddimages,cata,ifortlib)
         } else {
            set ::tools_astrometry::ifortlib "/opt/intel/lib/ia32"
         }
      }
      # 
      if {! [info exists ::tools_astrometry::treshold] } {
         if {[info exists conf(bddimages,cata,treshold)]} {
            set ::tools_astrometry::treshold $conf(bddimages,cata,treshold)
         } else {
            set ::tools_astrometry::treshold 10
         }
      }
      # 
      if {! [info exists ::tools_astrometry::delta] } {
         if {[info exists conf(bddimages,cata,delta)]} {
            set ::tools_astrometry::delta $conf(bddimages,cata,delta)
         } else {
            set ::tools_astrometry::delta 15
         }
      }

      # Astroid
      if {! [info exists ::tools_cata::use_astroid] } {
         if {[info exists conf(astrometry,cata,astroid,create)]} {
            set ::tools_cata::use_astroid $conf(astrometry,cata,astroid,create)
         } else {
            set ::tools_cata::use_astroid 0
         }
      }
      if {! [info exists ::tools_cata::astroid_saturation] } {
         if {[info exists conf(astrometry,cata,astroid,saturation)]} {
            set ::tools_cata::astroid_saturation $conf(astrometry,cata,astroid,saturation)
         } else {
            set ::tools_cata::astroid_saturation 50000
         }
      }
      if {! [info exists ::tools_cata::astroid_delta] } {
         if {[info exists conf(astrometry,cata,astroid,delta)]} {
            set ::tools_cata::astroid_delta $conf(astrometry,cata,astroid,delta)
         } else {
            set ::tools_cata::astroid_delta 15
         }
      }
      if {! [info exists ::tools_cata::astroid_threshold] } {
         if {[info exists conf(astrometry,cata,astroid,threshold)]} {
            set ::tools_cata::astroid_threshold $conf(astrometry,cata,astroid,threshold)
         } else {
            set ::tools_cata::astroid_threshold 5
         }
      }
      

   }




   proc ::gui_cata::setval { } {

      set ::tools_cata::ra_save  $::tools_cata::ra
      set ::tools_cata::dec_save $::tools_cata::dec

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect ==""} {
         gren_info "SET CENTER : $::tools_cata::ra_save $::tools_cata::dec_save\n"
         return
      }
      set xcent [format "%0.0f" [expr ([lindex $rect 0] + [lindex $rect 2])/2.]  ]   
      set ycent [format "%0.0f" [expr ([lindex $rect 1] + [lindex $rect 1])/2.]  ]   
      set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
      if {$err} {
         ::console::affiche_erreur "$err $msg\n"
         return
      }
      set ::tools_cata::ra_save  [lindex $a 0]
      set ::tools_cata::dec_save [lindex $a 1]
      gren_info "SET BOX : $::tools_cata::ra_save $::tools_cata::dec_save\n"

   }

   proc ::gui_cata::resetcenter { } {

      set ::tools_cata::ra  $::tools_cata::ra_save
      set ::tools_cata::dec $::tools_cata::dec_save
      gren_info "RESET CENTER : $::tools_cata::ra $::tools_cata::dec\n"
   
   }




   proc ::gui_cata::fermer { } {

      global conf
      global action_label




      # Repertoires 
      set conf(astrometry,catfolder,usnoa2) $::tools_cata::catalog_usnoa2 
      set conf(astrometry,catfolder,ucac2)  $::tools_cata::catalog_ucac2  
      set conf(astrometry,catfolder,ucac3)  $::tools_cata::catalog_ucac3  
      set conf(astrometry,catfolder,tycho2) $::tools_cata::catalog_tycho2 
      set conf(astrometry,catfolder,nomad1) $::tools_cata::catalog_nomad1 

      # Check button Use
      set conf(astrometry,cata,use_usnoa2) $::tools_cata::use_usnoa2
      set conf(astrometry,cata,use_ucac2)  $::tools_cata::use_ucac2
      set conf(astrometry,cata,use_ucac3)  $::tools_cata::use_ucac3
      set conf(astrometry,cata,use_tycho2) $::tools_cata::use_tycho2
      set conf(astrometry,cata,use_nomad1) $::tools_cata::use_nomad1
      set conf(astrometry,cata,use_skybot) $::tools_cata::use_skybot
            
      # Check button GUI
      set conf(astrometry,cata,gui_img)    $::gui_cata::gui_img
      set conf(astrometry,cata,gui_usnoa2) $::gui_cata::gui_usnoa2
      set conf(astrometry,cata,gui_ucac2)  $::gui_cata::gui_ucac2
      set conf(astrometry,cata,gui_ucac3)  $::gui_cata::gui_ucac3
      set conf(astrometry,cata,gui_tycho2) $::gui_cata::gui_tycho2
      set conf(astrometry,cata,gui_nomad1) $::gui_cata::gui_nomad1
      set conf(astrometry,cata,gui_skybot) $::gui_cata::gui_skybot
      
      # Uncosmic or not!
      set conf(astrometry,cata,use_uncosmic) $::gui_cata::use_uncosmic
      set conf(astrometry,cata,uncosm_param1) $::tools_cdl::uncosm_param1
      set conf(astrometry,cata,uncosm_param2) $::tools_cdl::uncosm_param2

      # Taille des ronds
      set conf(astrometry,cata,size_img)    $::gui_cata::size_img
      set conf(astrometry,cata,size_usnoa2) $::gui_cata::size_usnoa2
      set conf(astrometry,cata,size_ucac2)  $::gui_cata::size_ucac2
      set conf(astrometry,cata,size_ucac3)  $::gui_cata::size_ucac3
      set conf(astrometry,cata,size_nomad1) $::gui_cata::size_nomad1
      set conf(astrometry,cata,size_tycho2) $::gui_cata::size_tycho2
      set conf(astrometry,cata,size_skybot) $::gui_cata::size_skybot
      set conf(astrometry,cata,size_ovni)   $::gui_cata::size_ovni

      # Autres utilitaires
      set conf(astrometry,cata,keep_radec)              $::tools_cata::keep_radec
      set conf(astrometry,cata,create_cata)             $::tools_cata::create_cata
      set conf(astrometry,cata,delpv)                   $::tools_cata::delpv
      set conf(astrometry,cata,boucle)                  $::tools_cata::boucle
      set conf(astrometry,cata,deuxpasses)              $::tools_cata::deuxpasses
      set conf(astrometry,cata,limit_nbstars_accepted)  $::tools_cata::limit_nbstars_accepted
      set conf(astrometry,cata,log)                     $::tools_cata::log
      set conf(astrometry,cata,treshold_ident_pos_star) $::tools_cata::treshold_ident_pos_star
      set conf(astrometry,cata,treshold_ident_mag_star) $::tools_cata::treshold_ident_mag_star
      set conf(astrometry,cata,treshold_ident_pos_ast)  $::tools_cata::treshold_ident_pos_ast
      set conf(astrometry,cata,treshold_ident_mag_ast)  $::tools_cata::treshold_ident_mag_ast

      # Conf cata Astroid
      set conf(astrometry,cata,astroid,create)     $::tools_cata::use_astroid
      set conf(astrometry,cata,astroid,saturation) $::tools_cata::astroid_saturation
      set conf(astrometry,cata,astroid,delta)      $::tools_cata::astroid_delta
      set conf(astrometry,cata,astroid,threshold)  $::tools_cata::astroid_threshold

      destroy $::gui_cata::fen
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark
   }



   proc ::gui_cata::next { } {

         if {$::tools_cata::id_current_image < $::tools_cata::nb_img_list} {
            incr ::tools_cata::id_current_image
            catch {unset ::tools_cata::current_listsources}
            ::gui_cata::charge_current_image
         }
   }



   proc ::gui_cata::back { } {

         if {$::tools_cata::id_current_image > 1 } {
            incr ::tools_cata::id_current_image -1
            catch {unset ::tools_cata::current_listsources}
            ::gui_cata::charge_current_image
         }
   }








   proc ::gui_cata::get_cata { } {

         $::gui_cata::gui_create configure -state disabled
         $::gui_cata::gui_fermer configure -state disabled

         if { $::tools_cata::boucle == 1 } {

            ::gui_cata::get_all_cata

         }  else {
            cleanmark
            if {[::gui_cata::get_one_wcs] == true} {
            
               set ::gui_cata::color_wcs $::gui_cata::color_button_good
               $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
            
               if {[::tools_cata::get_cata] == false} {
                  # TODO gerer l'erreur le  cata a echou?
                  set ::gui_cata::color_cata $::gui_cata::color_button_bad
                  $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
                  #return false
               } else {
                  set ::gui_cata::color_cata $::gui_cata::color_button_good
                  $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata

                  # Affiche le cata
                  ::gui_cata::affiche_cata

               }
            } else {
               # TODO gerer l'erreur le wcs a echou?
               set ::gui_cata::color_wcs $::gui_cata::color_button_bad
               $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
               cleanmark
               
            }
            
         }
         $::gui_cata::gui_create configure -state normal
         $::gui_cata::gui_fermer configure -state normal

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















   proc ::gui_cata::get_all_cata { } {

      cleanmark
      while {1==1} {
         if { $::tools_cata::boucle == 0 } {
            break
         }
         if {[::gui_cata::get_one_wcs] == true} {
             
            set ::gui_cata::color_wcs $::gui_cata::color_button_good
            $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
            if {[::tools_cata::get_cata] == false} {
               # TODO gerer l'erreur le  cata a echou?
               set ::gui_cata::color_cata $::gui_cata::color_button_bad
               $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
               set ::tools_cata::boucle 0
               ::gui_cata::affiche_current_image
               break
            } else {
               # Ok ca se passe bien
               set ::gui_cata::color_cata $::gui_cata::color_button_good
               $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
               update

               cleanmark
               ::gui_cata::affiche_current_image
               ::gui_cata::affiche_cata
            }
         } else {
            # TODO gerer l'erreur le wcs a echou?
            set ::gui_cata::color_wcs $::gui_cata::color_button_bad
            $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
            cleanmark
            ::gui_cata::affiche_current_image
            break
         }
         if {$::tools_cata::id_current_image == $::tools_cata::nb_img_list} { break }
         ::gui_cata::next
      }

   }



















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
      set listsources [::tools_sources::set_common_fields $listsources IMG     { ra dec 5.0 calib_mag calib_mag_ss1}]
      set listsources [::tools_sources::set_common_fields $listsources USNOA2  { ra dec poserr mag magerr }]
      set listsources [::tools_sources::set_common_fields $listsources UCAC2   { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
      set listsources [::tools_sources::set_common_fields $listsources UCAC3   { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
      set listsources [::tools_sources::set_common_fields $listsources TYCHO2  { RAdeg DEdeg 5 VT e_VT }]
      set listsources [::tools_sources::set_common_fields_skybot $listsources]
      set listsources [::tools_sources::set_common_fields $listsources ASTROID { ra dec 0.0 0.0 0.0 }]
      set ::tools_cata::current_listsources $listsources

   }

   
   
   
   
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







   proc ::gui_cata::get_one_wcs { } {

         set tabkey         [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs" ] 1] ]
         set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
         set idbddimg       [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
         set filename       [::bddimages_liste::lget $::tools_cata::current_image filename   ]
         set dirfilename    [::bddimages_liste::lget $::tools_cata::current_image dirfilename]

         set err [catch {::tools_cata::get_wcs} msg]
         
         if {$err == 0 } {
            set newimg [::bddimages_liste_gui::file_to_img $filename $dirfilename]
            
            set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] [expr $::tools_cata::id_current_image-1] $newimg]
            
            set idbddimg    [::bddimages_liste::lget $newimg idbddimg]
            set tabkey      [::bddimages_liste::lget $newimg "tabkey"]
            set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]

            set ::gui_cata::color_wcs $::gui_cata::color_button_good

            set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
            set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
            set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
            set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
            set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
            set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
            
            return true

         } else {
            ::console::affiche_erreur "GET_WCS ERROR: $msg  idbddimg : $idbddimg   filename : $filename\n"
            set ::gui_cata::color_wcs $::gui_cata::color_button_bad
            set ::tools_cata::boucle 0
            return false
         }
   }




   proc ::gui_cata::sendImageAndTable { } {

      global bddconf

      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]
      
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra      ] 1]
      set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec     ] 1]
      set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1] 1]
      set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2] 1]
      set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen  ] 1]
      set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]

      set ::tools_cata::bddimages_wcs [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]

      set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
      set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

      # Envoie de l'image dans Aladin via Samp
      ::SampTools::broadcastImage
      
      set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
      set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename] 
      set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]

      # Envoie du CATA dans Aladin via Samp
      if {$cataexist} {
         set ::votableUtil::votBuf(file) $catafile
         ::SampTools::broadcastTable
      }

   }


   proc ::gui_cata::set_aladin_script_params { } {
   
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

      set ::tools_cata::uaicode [string trim [lindex [::bddimages_liste::lget $tabkey IAU_CODE] 1]]

      set ra  [lindex [::bddimages_liste::lget $tabkey ra] 1]
      set dec [lindex [::bddimages_liste::lget $tabkey dec] 1]
      if {$dec > 0} { set dec "+$dec" }
      set ::tools_cata::coord "$ra $dec"

      set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
      set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
      set ::tools_cata::radius "$radius"

   }

   proc ::gui_cata::sendAladinScript { } {

      # Get parameters
      set coord $::tools_cata::coord
      set radius_arcmin "${::tools_cata::radius}arcmin"
      set radius_arcsec [concat [expr $::tools_cata::radius * 60.0] "arcsec"]
      set date $::tools_cata::current_image_date
      set uaicode [string trim $::tools_cata::uaicode]

      # Request Skybot cone-search
      set skybotQuery "get SkyBoT.IMCCE($date,$uaicode,'Asteroids and Planets','$radius_arcsec')"

      # Draw a circle to mark the fov center
      set lcoord [split $coord " "]
      set drawFovCenter "draw phot([lindex $lcoord 0],[lindex $lcoord 1],20.00arcsec)"
      # Draw USNO stars as triangles
      set shapeUSNO "set USNO2 shape=triangle"

      # Aladin Script
      set script "get Aladin(DSS2) ${coord} $radius_arcmin; get VizieR(USNO2); sync; $shapeUSNO; $drawFovCenter; $skybotQuery;"
      # Broadcast script
      ::SampTools::broadcastAladinScript $script
   
   }

   proc ::gui_cata::skybotResolver { } {

      set name $::tools_cata::coord
      set date $::tools_cata::current_image_date
      set uaicode [string trim $::tools_cata::uaicode]

      set erreur [ catch { vo_skybotresolver $date $name text basic $uaicode } skybot ]
      if { $erreur == "0" } {
         if { [ lindex $skybot 0 ] == "no" } {
            ::console::affiche_erreur "The solar system object '$name' was not resolved by SkyBoT"
         } else {
            set resp [split $skybot ";"]
            set respdata [split [lindex $resp 1] "|"]
            set ra [expr [lindex $respdata 2] * 15.0]
            set dec [lindex $respdata 3]
            if {$dec > 0} { set dec "+$dec" }
            set ::tools_cata::coord "$ra $dec"
         }
      } else {
         ::console::affiche_erreur "SkyBoT error: $erreur : $skybot"
      }

   }

   
   proc ::gui_cata::setCenterFromRADEC { } {

      set rd [regexp -inline -all -- {\S+} $::tools_cata::coord]
      set ra [lindex $rd 0]
      set dec [lindex $rd 1]
      set ::tools_cata::ra  $ra
      set ::tools_cata::dec $dec
      gren_info "SET CENTER FROM RA,DEC: $::tools_cata::ra $::tools_cata::dec\n"

   }

   
   proc ::gui_cata::watch_info { }  {

      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]

      gren_info "---------------------------\n"
      gren_info "IDBDDIMG = $idbddimg\n"
      gren_info "FILENAME = $filename\n"
      gren_info "DATE = $date\n"
      gren_info "WCS = $bddimages_wcs\n"
      gren_info "CATAEXIST = $cataexist\n"
      gren_info "ID_CURRENT_IMAGE = $::tools_cata::id_current_image\n"
      gren_info "---------------------------\n"
   
   }

   proc ::gui_cata::watch_tabkey { } {

      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

      set cpt 0
      foreach v $tabkey {
         gren_info "v = $v\n"
         incr cpt
         #if {$cpt > 12 } {break}
      }

   }

   proc ::gui_cata::watch_buffer_header { } {

      set cpt 0
      set list_keys [buf$::audace(bufNo) getkwds]
      foreach key $list_keys {
         if {$key==""} {continue}
         gren_info "$key = [buf$::audace(bufNo) getkwd $key]\n" 
         incr cpt
         #if {$cpt > 12 } {break}
      }
    }






   proc ::gui_cata::charge_current_image { } {

      global audace
      global bddconf

         set log 0

         gren_info "--------\n"

         set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image - 1] ]
         
         set err [catch {set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]} msg]
         if {$err} {
            ::console::affiche_erreur "Erreur de lecture des infos du cata de l image \n"
            ::console::affiche_erreur "        err = $err\n"
            ::console::affiche_erreur "        msg = $msg\n"
            ::console::affiche_erreur "        idbddimg = $idbddimg\n"
            return
         }
         
         set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]
         set ::tools_cata::current_image_name $filename
         set ::tools_cata::current_image_date $date
         set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
         set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
         set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
         set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
         set xcent    [expr $naxis1/2.0]
         set ycent    [expr $naxis2/2.0]


         if {$log} {
            gren_info "---------------------------\n"
            gren_info "IDBDDIMG = $idbddimg\n"
            gren_info "FILENAME = $filename\n"
            gren_info "DATE = $date\n"
            gren_info "WCS = $::tools_cata::bddimages_wcs\n"
            gren_info "CATAEXIST = $cataexist\n"
            gren_info "ID_CURRENT_IMAGE = $::tools_cata::id_current_image\n"
            gren_info "---------------------------\n"
         }

         $::gui_cata::gui_dateimage configure -text $::tools_cata::current_image_date

         buf$::audace(bufNo) load $file

         ::confVisu::setFileName $::audace(visuNo) $file

         if { $::tools_cata::boucle == 0 } {
            ::gui_cata::affiche_current_image
            ::gui_cata::affiche_cata
         }
         
         #?Mise a jour GUI
         
         $::gui_cata::gui_back configure -state disabled
         
         $::gui_cata::gui_nomimage configure -text $::tools_cata::current_image_name
         $::gui_cata::gui_stimage  configure -text "$::tools_cata::id_current_image / $::tools_cata::nb_img_list"

         if {$::tools_cata::id_current_image == 1 && $::tools_cata::nb_img_list > 1 } {
            $::gui_cata::gui_back configure -state disabled
         }
         if {$::tools_cata::id_current_image == $::tools_cata::nb_img_list && $::tools_cata::nb_img_list > 1 } {
            $::gui_cata::gui_next configure -state disabled
         }
         if {$::tools_cata::id_current_image > 1 } {
            $::gui_cata::gui_back configure -state normal
         }
         if {$::tools_cata::id_current_image < $::tools_cata::nb_img_list } {
            $::gui_cata::gui_next configure -state normal
         }
         if {$::tools_cata::bddimages_wcs == "Y"} {
            set ::gui_cata::color_wcs $::gui_cata::color_button_good
            $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         } else {
            set ::gui_cata::color_wcs $::gui_cata::color_button_bad
            $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         }
         if {$cataexist == "1"} {
            set ::gui_cata::color_cata $::gui_cata::color_button_good
            $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
         } else {
            set ::gui_cata::color_cata $::gui_cata::color_button_bad
            $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
         }
         affich_un_rond_xy $xcent $ycent red 2 2
         $::gui_cata::gui_enrimg configure -state disabled
   }



      



   proc ::gui_cata::charge_list { img_list } {

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

      foreach ::tools_cata::current_image $::tools_cata::img_list {
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      }

      # Chargement premiere image sans GUI
      set ::tools_cata::id_current_image 1
      set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
      set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
      set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
      set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
      set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
      set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
      set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]
      set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
      set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
      set xcent    [expr $naxis1/2.0]
      set ycent    [expr $naxis2/2.0]

      set ::tools_cata::current_image_name $filename
      set ::tools_cata::current_image_date $date

      #?Charge l image a l ecran
      buf$::audace(bufNo) load $file

      # Etat des boutons et GUI
      cleanmark
      set ::gui_cata::stateback disabled
      if {$::tools_cata::nb_img_list == 1} {
         set ::gui_cata::statenext disabled
      } else {
         set ::gui_cata::statenext normal
      }
      if {$::tools_cata::bddimages_wcs == "Y"} {
         set ::gui_cata::color_wcs $::gui_cata::color_button_good
      } else {
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
      }
      if {$cataexist == "1"} {
         set ::gui_cata::color_cata $::gui_cata::color_button_good
      } else {
         set ::gui_cata::color_cata $::gui_cata::color_button_bad
      }

      set ::tools_cata::nb_img     0
      set ::tools_cata::nb_usnoa2  0
      set ::tools_cata::nb_tycho2  0
      set ::tools_cata::nb_ucac2   0
      set ::tools_cata::nb_ucac3   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0
      affich_un_rond_xy $xcent $ycent red 2 2
      ::gui_cata::affiche_current_image
      ::gui_cata::affiche_cata
   }




   proc ::gui_cata::get_confsex { } {

      global audace

         
         set fileconf [ file join $audace(rep_plugin) tool bddimages config config.sex ]
         
         # $::gui_cata::current_appli.onglets.nb.f5.confsex.file insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
         # $confsex.file  insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
         
         set chan [open $fileconf r]
         while {[gets $chan line] >= 0} {
            $::gui_cata::current_appli.onglets.nb.f5.confsex.file insert end "$line\n"
         }
         close $chan

   }



   proc ::gui_cata::set_confsex { } {

      global audace

      set r  [$::gui_cata::current_appli.onglets.nb.f5.confsex.file get 1.0 end]
      #set r [split $r "\n"]
      #set r [lreverse $r]
      #::console::affiche_erreur "$r\n***\n"
      #::console::affiche_erreur "[pwd]\n"
      set chan [open "./config.sex" "w"]
      #foreach l $r {
      #   puts $chan "$l"
      #}
      puts $chan $r
      close $chan
      
   }




   proc ::gui_cata::test_confsex { } {

      cleanmark
      ::gui_cata::set_confsex 

      catch {
        set r [calibwcs * * * * * USNO $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0]
        gren_info "Resultat test -> nb stars = $r\n"
      }



      set chan [open "./obs.lst" "r"]
      while {[gets $chan line] >= 0} {
         set r [split $line " "]
         set cpt 0
         foreach x $r {
            if {$x!=""} {
               if {$cpt == 0} {set xi $x}
               if {$cpt == 1} {set yi $x}
               incr cpt
            }
         }
         #gren_info "pos image : $xi $yi\n"
         affich_un_rond_xy $xi $yi "green" 3 1
         #break
      }
      close $chan

      
   }




   proc ::gui_cata::affich_catapcat {  } {
      set fxml [open catalog.cat "r"]
      while {[gets $fxml line] >= 0} {
         set r [split $line " "]
         gren_info "$r\n"
         set cpt 0
         foreach x $r {
            if {$x!=""} {
               if {$cpt == 6} {set xi $x}
               if {$cpt == 7} {set yi $x}
               incr cpt
            }
         }
         gren_info "pos image : $xi $yi\n"
         break
      }
      close $fxml
   }
   
   
   
   
   
   
   proc ::gui_cata::getDSS { } {

      #gren_info "RA (deg): $::tools_cata::ra\n"
      #gren_info "DEC (deg): $::tools_cata::dec\n"
      #gren_info "RADIUS (arcmin): $::tools_cata::radius\n"
      set fov_x_deg [expr $::tools_cata::radius/60.]
      set fov_y_deg [expr $::tools_cata::radius/60.]
      set naxis1 600
      set naxis2 600
      set crota2 $::tools_cata::crota
      ::gui_cata::loadDSS dss.fit $::tools_cata::ra $::tools_cata::dec $fov_x_deg $fov_y_deg $naxis1 $naxis2 $crota2 

      set ::gui_cata::dssvisu [ ::confVisu::create ]
      set ::gui_cata::dssbuf  [ visu$::gui_cata::dssvisu buf   ]
      buf$::gui_cata::dssbuf load dss.fit
      buf$::gui_cata::dssbuf setkwd {CROTA2 $crota2 double "" ""}
      ::audace::autovisu $::gui_cata::dssvisu

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
   
   
   
   
   
   
   proc ::gui_cata::loadDSS { fichier_fits_dss ra dec fov_x_deg fov_y_deg naxis1 naxis2 crota2} {
      set url "http://skyview.gsfc.nasa.gov/cgi-bin/runquery.pl"
      set sentence "Position=%s,%s&Size=%s,%s&Pixels=%s,%s&Rotation=%s&Survey=DSS&Scaling=Linear&Projection=Tan&Coordinates=J2000&Return=FITS"
      set query [ format $sentence [mc_angle2deg $ra] [mc_angle2deg $dec 90] $fov_x_deg $fov_y_deg $naxis1 $naxis2 $crota2 ]
      ::gui_cata::downloadURL "$url" "$query" $fichier_fits_dss
   }






   proc ::gui_cata::grab { i } {

      #gren_info "Etoile num $i\n"

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez selectionner une etoile en dessinant un carre dans l'image a reduire" -type ok
         return
      }
      set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
      #gren_info "IMG XY: $err : $cent : $msg \n"
      set ::gui_cata::man_xy_star($i) "[format "%2.2f" [lindex $cent 0]] [format "%2.2f" [lindex $cent 1]]"
      
      set err [ catch {set rect  [ ::confVisu::getBox $::gui_cata::dssvisu ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez selectionner une etoile en dessinant un carre dans l'image DSS" -type ok
         return
      }
      set err [ catch {set cent [::tools_cdl::select_obj $rect $::gui_cata::dssbuf]} msg ]
      gren_info "DSS XY: $err : $rect : $msg\n"
      set err [ catch {set a [buf$::gui_cata::dssbuf xy2radec $cent]} msg ]
      if {$err} {
         ::console::affiche_erreur "$err $msg\n"
         return
      }
      gren_info "AD: $err : $a : $msg\n"
      set ::gui_cata::man_ad_star($i) "[lindex $a 0] [lindex $a 1]"

      return
      
   }
   
   
   
   
   
   
   proc ::gui_cata::manual_clean {  } {

      for {set i 1} {$i<=7} {incr i} {
         set ::gui_cata::man_xy_star($i) ""
         set ::gui_cata::man_ad_star($i) ""      
      }

   }





   proc ::gui_cata::test_manual_create {  } {

# pour l image = 2011-04-12T20:44:40.700

      set ::gui_cata::man_xy_star(1) [list 516.91 722.89]
      set ::gui_cata::man_ad_star(1) [list 194.10746 +02.27564]
      set ::gui_cata::man_xy_star(2) [list 505.11 448.60]
      set ::gui_cata::man_ad_star(2) [list 194.10942 +02.24207]
      set ::gui_cata::man_xy_star(3) [list 894.25 508.29]
      set ::gui_cata::man_ad_star(3) [list 194.06204 +02.24825]
      set ::gui_cata::man_xy_star(4) [list 372.61 116.50]
      set ::gui_cata::man_ad_star(4) [list 194.12675 +02.20196]

      for {set i 5} {$i<=7} {incr i} {
         set ::gui_cata::man_xy_star($i) ""
         set ::gui_cata::man_ad_star($i) ""
      }

   }


   proc ::gui_cata::manual_view {  } {

      for {set i 1} {$i<=7} {incr i} {
         if {$::gui_cata::man_xy_star($i) != "" && $::gui_cata::man_ad_star($i) != ""} {
            set x [split $::gui_cata::man_xy_star($i) " "]
            set xsm [lindex $x 0]
            set ysm [lindex $x 1]
            affich_un_rond_xy  $xsm $ysm "blue" 5 2
         }
      }
       

   }




   proc ::gui_cata::manual_fit {  } {


      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez selectionner une etoile et une reference XY en dessinant un carre dans l'image a reduire" -type ok
         return
      }
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]
      set xradius [expr $x2 - $x1]
      set yradius [expr $y2 - $y1]
      
      
      set id 0
      for {set i 1} {$i<=7} {incr i} {
         if {$::gui_cata::man_xy_star($i) != "" && $::gui_cata::man_ad_star($i) != ""} {
            set x [split $::gui_cata::man_xy_star($i) " "]
            set xsm [lindex $x 0]
            set ysm [lindex $x 1]
            if {$xsm>$x1 && $xsm<$x2 && $ysm > $y1 && $ysm < $y2 } {
               set id $i
               break
            }
         }
      }
      if {$id == 0} {
         tk_messageBox -message "Veuillez selectionner une etoile + une reference XY en dessinant un carre dans l'image a reduire" -type ok
         return
      }

      set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
      #gren_info "IMG XY: $err : $cent : $msg \n"
      set xdiff [expr [lindex $cent 0] - $xsm]
      set ydiff [expr [lindex $cent 1] - $ysm]
      set rdiff [expr sqrt((pow($xdiff,2)+pow($ydiff,2))/2.0)]
      #gren_info "RDIFF: $rdiff \n"
      
      set err [catch {set ::gui_cata::man_xy_star($id) "[format "%2.2f" [lindex $cent 0]] [format "%2.2f" [lindex $cent 1]]"} msg ]
      if {$err} {
         gren_info "err: $err \n"
         gren_info "msg: $msg \n"
         gren_info "cnt 0: [lindex $cent 0] \n"
         gren_info "cnt 1: [lindex $cent 1] \n"      
      }

      set rdiff ""
      for {set i 1} {$i<=7} {incr i} {
         if {$::gui_cata::man_xy_star($i) != "" && $::gui_cata::man_ad_star($i) != ""} {
            set x [split $::gui_cata::man_xy_star($i) " "]
            set xsm [expr [lindex $x 0] + $xdiff]
            set ysm [expr [lindex $x 1] + $ydiff]
            set x1 [expr $xsm - $xradius ]
            set y1 [expr $ysm - $yradius ]
            set x2 [expr $xsm + $xradius ]
            set y2 [expr $ysm + $yradius ]
            set rect [list $x1 $y1 $x2 $y2]
            set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
            #gren_info "IMG XY: $err : $cent : $msg \n"
            set xdiff [expr [lindex $cent 0] - $xsm]
            set ydiff [expr [lindex $cent 1] - $ysm]
            lappend rdiff [expr sqrt((pow($xdiff,2)+pow($ydiff,2))/2.0)]
            set err [catch {set ::gui_cata::man_xy_star($i) "[format "%2.2f" [lindex $cent 0]] [format "%2.2f" [lindex $cent 1]]"    } msg ]       
            if {$err} {
               gren_info "err: $err \n"
               gren_info "msg: $msg \n"
               gren_info "cnt 0: [lindex $cent 0] \n"
               gren_info "cnt 1: [lindex $cent 1] \n"      
            }

         }
      }
      set rdiff [::math::statistics::max $rdiff]
      #gren_info "RDIFFMAX: $rdiff \n"
      cleanmark
      ::gui_cata::manual_view
   }

   proc ::gui_cata::push_img_list {  } {
      set ::tools_cata::img_list_sav $::tools_cata::img_list
      set ::tools_cata::current_image_sav $::tools_cata::current_image
      set ::tools_cata::id_current_image_sav $::tools_cata::id_current_image
      set ::tools_cata::create_cata_sav $::tools_cata::create_cata
   }

   proc ::gui_cata::pop_img_list {  } {
      set ::tools_cata::img_list $::tools_cata::img_list_sav
      set ::tools_cata::current_image $::tools_cata::current_image_sav
      set ::tools_cata::id_current_image $::tools_cata::id_current_image_sav
      set ::tools_cata::create_cata $::tools_cata::create_cata_sav
   }









   proc ::gui_cata::manual_create_wcs {  } {

      global bddconf

      #::gui_cata::test_manual_create

      ::gui_cata::push_img_list
      $::gui_cata::gui_enrimg configure -state disabled
      $::gui_cata::gui_creercata configure -state disabled
      
      gren_info "Creation Manuelle du WCS\n"

      #gren_info " tools_astrometry::treshold: $::tools_astrometry::treshold \n"
      #gren_info " tools_astrometry::delta:    $::tools_astrometry::delta \n"
      #gren_info " Compilo: $::tools_astrometry::ifortlib \n"

      set ::tools_astrometry::treshold 10
      set ::tools_astrometry::delta   15
      set ::tools_astrometry::science ""
      set ::tools_astrometry::reference ""

      set sources {}
      set fieldimgshort [list "IMG" [list "ra" "dec" "err_pos" "mag" "err_mag"] [list "x1" "y2" "xsm" "ysm"] ]

      # Liste des etoiles pointees a la mano
      gren_info "     Preparation des sources\n"
      for {set i 1} {$i<=7} {incr i} {
         if {$::gui_cata::man_xy_star($i) != "" && $::gui_cata::man_ad_star($i) != ""} {
            set x [split $::gui_cata::man_xy_star($i) " "]
            set xsm [lindex $x 0]
            set ysm [lindex $x 1]
            set x [split $::gui_cata::man_ad_star($i) " "]
            set ra [lindex $x 0]
            set dec [lindex $x 1]
            lappend sources [list [list "IMG" [list $ra $dec 0 0 0] [list $ra $dec $xsm $ysm]] ]
         }
      }
      set listsources [list [list $fieldimgshort] $sources ]
      #gren_info "listsources : $listsources\n"
      
      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      #gren_info "fields : $fields\n"
      #gren_info "sources : $sources\n"
      
      gren_info "     Mesure des PSF\n"
      set listsources [::analyse_source::psf $listsources $::tools_astrometry::treshold $::tools_astrometry::delta]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

      if {[::bddimages_liste::lexist $::tools_cata::current_image "listsources" ]==0} {
         set ::tools_cata::current_image [::bddimages_liste::ladd $::tools_cata::current_image "listsources" $listsources]
      } else {
         set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "listsources" $listsources]
      }
      
      #set listsources [::bddimages_liste::lget $::tools_cata::current_image "listsources"]
      #gren_info "listsources : $listsources\n"
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
      #gren_info "current_image : $::tools_cata::current_image\n"
  
  
      # Creation des fichiers et lancement de Priam
      gren_info "     Creation des fichiers et lancement de Priam\n"
      set ::tools_astrometry::reference ""

      set err [catch {::priam::create_file_oldformat "new" 1 \
                 $::tools_cata::current_image "" "IMG" } msg ]
      if {$err} {
         ::console::affiche_erreur "WCS Impossible :($err) $msg \n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::gui_cata::pop_img_list
         return
      }
      
      #gren_info "current_image : $::tools_cata::current_image\n"

      set ::tools_cata::img_list [list $::tools_cata::current_image]

      set err [catch {::tools_astrometry::extract_priam_result [::tools_astrometry::launch_priam] } msg ]
      if {$err} {
         ::console::affiche_erreur "WCS Impossible :($err)  $msg \n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::gui_cata::pop_img_list
         return
      }

      foreach ::tools_cata::current_image $::tools_cata::img_list {
         #gren_info "current_image : $::tools_cata::current_image\n"

         if {[::bddimages_liste::lexist $::tools_cata::current_image "listsources" ]==0} {
            ::console::affiche_erreur "WCS Impossible :(4) listesources n existe pas dans l image courante \n"
            ::gui_cata::pop_img_list
            return
         } 

         set ::tools_cata::current_listsources [::bddimages_liste::lget $::tools_cata::current_image "listsources"]
         #::manage_source::imprim_3_sources $::tools_cata::current_listsources
      }

      #gren_info "current_image : $::tools_cata::current_image\n"
      #::manage_source::imprim_3_sources $::tools_cata::current_listsources
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

# WCS dans l image

      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]
      set filename    [string range $filename 0 [expr [string last .gz $filename] -1]]
      set file        [file join $bddconf(dirtmp) $filename]

      set key [list "BDDIMAGES WCS" "Y" "string" "Y | N | ? (WCS performed)" ""]
      buf$::audace(bufNo) setkwd $key

      saveima $file
      loadima $file

      gren_info "     WCS dans l image $file\n"

# Obtention du nouvel header

      set err [catch {set tabkey [::bdi_tools_image::get_tabkey_from_buffer] } msg ]
      if {$err} {
         ::console::affiche_erreur "WCS Impossible :($err) $msg \n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::gui_cata::pop_img_list
         return
      }

      ::gui_cata::pop_img_list

      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]

      #gren_info "current_image : $::tools_cata::current_image\n"

      set ::gui_cata::color_wcs $::gui_cata::color_button_good
      $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
      $::gui_cata::gui_enrimg configure -state normal
      $::gui_cata::gui_creercata configure -state normal
      
   }







   proc ::gui_cata::manual_create_cata {  } {

      ::gui_cata::push_img_list
      set ::tools_cata::create_cata 0

      $::gui_cata::gui_enrimg configure -state disabled

# Lancement Sextractor
         gren_info "     Lancement Sextractor\n"

         set ext $::conf(extension,defaut)
         set mypath "."
         set sky0 dummy0
         set sky dummy
         catch {buf$::audace(bufNo) delkwd CATASTAR}
         buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         createFileConfigSextractor
         buf$::audace(bufNo) save [ file join ${mypath} ${sky}$ext ]
         ::gui_cata::set_confsex
         sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"
         

# Extraction Resultat Sextractor
# et Creation de la liste
         gren_info "     Extraction Resultat\n"

      set fields [list [list IMG [list ra dec poserr mag magerr] \
                 [list id flag xpos ypos instr_mag err_mag flux_sex \
                 err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 \
                 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius \
                 background_sex x2_momentum_sex y2_momentum_sex \
                 xy_momentum_sex major_axis_sex minor_axis_sex \
                 position_angle_sex fwhm_sex flag_sex]]]
      set sources {}
      set chan [open "catalog.cat" r]
      while {[gets $chan line] >= 0} {
         set a [split $line "="]
         set a [lindex $a 0]
         set a [split $a " "]
         set c {}
         foreach b $a {
            if {$b==""} {continue}
            lappend c $b
         }
         #gren_info "C=$c\n"
         set id                 [lindex $c 0]
         set flux_sex           [lindex $c 1]
         set err_flux_sex       [lindex $c 2]
         set instr_mag          [lindex $c 3]
         set err_mag            [lindex $c 4]
         set background_sex     [lindex $c 5]
         set xpos               [lindex $c 6]
         set ypos               [lindex $c 7]
         set major_axis_sex     [lindex $c 11]
         set minor_axis_sex     [lindex $c 12]
         set position_angle_sex [lindex $c 13]
         set fwhm_sex           [lindex $c 14]
         set flag_sex           [lindex $c 15]
         set radec  [buf$::audace(bufNo) xy2radec [list $xpos $ypos]]
         set ra  [lindex $radec 0]
         set dec [lindex $radec 1]
         
         set l [list $id 1 $xpos $ypos $instr_mag $err_mag $flux_sex $err_flux_sex $ra $dec \
                     0.0 0.0 0.0 0.0 0.0 0 0 \
                     $background_sex 0.0 0.0 0.0 $major_axis_sex $minor_axis_sex $position_angle_sex \
                     $fwhm_sex $flag_sex]
         lappend sources [list [list "IMG" {} $l]]
         
      }
      set ::tools_cata::current_listsources [list $fields $sources]
      set ::tools_cata::current_listsources [::tools_sources::set_common_fields $::tools_cata::current_listsources IMG    { ra dec 5.0 calib_mag calib_mag_ss1}]
      #::manage_source::imprim_3_sources $::tools_cata::current_listsources

# Modification de la liste

      set tabkey  [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
      set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
      set xcent   [expr $naxis1/2.0]
      set ycent   [expr $naxis2/2.0]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1 ] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2 ] 1]

      set a       [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
      set ra      [lindex $a 0]
      set dec     [lindex $a 1]
      set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

      #set listsources [::tools_sources::set_common_fields $listsources USNOA2 { ra dec poserr mag magerr }]
      #set ::tools_cata::current_listsources [::tools_sources::set_common_fields $::tools_cata::current_listsources USNOA2 { ra dec poserr mag magerr }]

      # 1ere identification sur l USNOA2

      #   gren_info "csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius\n"
      #   return
      #   set usnoa2 [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius]
      #   set usnoa2 [::tools_sources::set_common_fields $usnoa2 USNOA2 { ra dec poserr mag magerr }]
      #   set log 0
      #   set ::tools_cata::current_listsources [ identification $::tools_cata::current_listsources IMG $usnoa2 USNOA2 30.0 -30.0 {} $log]
      #   gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

      # 1ere identification sur l UCAC3

      gren_info "csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius\n"
      set ucac3 [csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius]
      set ucac3 [::tools_sources::set_common_fields $ucac3 UCAC3 { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]

      affich_rond $ucac3 UCAC3  $::gui_cata::color_ucac3  $::gui_cata::size_ucac3
      #::manage_source::imprim_3_sources $ucac3
      set log 0
      set ::tools_cata::current_listsources [ identification $::tools_cata::current_listsources IMG $ucac3 UCAC3 30.0 -30.0 {} $log]
      set nbs [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources "UCAC3"]
      gren_info "     $nbs Sources identifiees -> ROLLUP = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

      if {[::manage_source::get_nb_sources_by_cata  $::tools_cata::current_listsources UCAC3]<=2 } {
         ::console::affiche_erreur "WCS Impossible\n"
         ::gui_cata::pop_img_list
         return
      }

      set ::tools_cata::ra  $ra
      set ::tools_cata::dec $dec
      
      # Calcul des magnitudes 

      set fields [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      set newsources "" 
      foreach s $sources {
         set news ""
         foreach cata $s {
            if {[lindex $cata 0] == "IMG"} {
               set c [lindex $cata 1]
               #gren_info "c=$c\n"
               set l [lindex $cata 2]
               set flux [lindex $l 6]

               set tabmagref ""
               set tabfluxref ""
               set tabmag ""
               foreach s2 $sources {
                  foreach cata2 $s2 {
                     if {[lindex $cata2 0] == "UCAC3"} {
                        set magref [lindex [lindex $cata2 1] 3]
                        lappend tabmagref $magref

                        foreach cata3 $s2 {
                           if {[lindex $cata3 0] == "IMG"} {
                              set fluxref  [lindex [lindex $cata3 2] 6]
                              lappend tabfluxref $fluxref
                              set magobjcalc [expr $magref - log10(($flux*1.0)/($fluxref*1.0))*2.5]
                              #gren_info "calc = $magref  $flux $fluxref $magobjcalc\n"
                              lappend tabmag $magobjcalc
                           }
                        }
                     }
                  }
               }
               #gren_info "tabmag=$tabmag \n"
               
               set mag [::math::statistics::median $tabmag]

               #set errmag [::math::statistics::mean $errmag]
               #set errmag [::math::statistics::stdev $mag]
               set c [ lreplace $c 3 3 $mag]
               #gren_info "cfinal=$c \n"

               lappend news [list "IMG" $c $l]
            } else {
              lappend news $cata
            }
         }
         lappend newsources $news
      }
      set ::tools_cata::current_listsources [list $fields $newsources]


      # calcule l erreur en mag
      set tabdmag ""
      set sources [lindex $::tools_cata::current_listsources 1]
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "IMG"} {
               set mag [lindex [lindex $cata 1] 3]
               foreach cata2 $s {
                  if {[lindex $cata2 0] == "UCAC3"} {
                     set magcata [lindex [lindex $cata2 1] 3]
                     lappend tabdmag [expr abs($magcata - $mag)]
                  }
               }
            } 
         }
      }
      set dmag [::math::statistics::median $tabdmag]
      set stdmag [::math::statistics::stdev $tabdmag]
      set dmag [expr $dmag + $stdmag]

      # mise a jour de l erreur en mag
      set fields [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      set newsources "" 
      foreach s $sources {
         set news ""
         foreach cata $s {
            if {[lindex $cata 0] == "IMG"} {
               set c [lindex $cata 1]
               set l [lindex $cata 2]
               #gren_info "c1=$c\n"
               set c [lreplace $c 4 4 $dmag]
               #gren_info "c2=$c $dmag \n"
               lappend news [list "IMG" $c $l]
            } else {
              lappend news $cata
            }
         }
         lappend newsources $news
      }
      set ::tools_cata::current_listsources [list $fields $newsources]

      # Resultats des magnitudes 
      ::manage_source::get_fields_from_sources $::tools_cata::current_listsources

      set log 0

      if {$log} {
         set sources [lindex $::tools_cata::current_listsources 1]
         foreach s $sources {
            foreach cata $s {
               if {[lindex $cata 0] == "IMG"} {
                 set l [lindex $cata 2]
                 set flux [lindex $l 6]
                 set mag [lindex [lindex $cata 1] 3]
                 set errmag [lindex [lindex $cata 1] 4]
                 gren_info "IMG $flux $mag $errmag "
                 foreach cata2 $s {
                    if {[lindex $cata2 0] == "UCAC3"} {
                       gren_info "(UCAC3) "
                       set dmag [expr [lindex [lindex $cata2 1] 3] - $mag ]
                       set emag [lindex [lindex $cata2 1] 4]
                       gren_info " $dmag $emag "
                    }
                 }
                 gren_info "\n"
               } 
            }
         }
      }

      #set ::tools_cata::current_listsources [::tools_sources::set_common_fields $::tools_cata::current_listsources IMG { ra dec 5.0 calib_mag calib_mag_ss1}]
      #::manage_source::imprim_3_sources $::tools_cata::current_listsources
      set ::tools_cata::current_listsources [::manage_source::extract_catalog $::tools_cata::current_listsources "IMG"]
      #gren_info "rollupE = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

# Obtention du CATA
      if {[::tools_cata::get_cata] == false} {
         set ::gui_cata::color_cata $::gui_cata::color_button_bad
         $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
      } else {
         set ::gui_cata::color_cata $::gui_cata::color_button_good
         $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
      }

      #gren_info "rollupE = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

      $::gui_cata::gui_enrimg configure -state normal
      ::gui_cata::pop_img_list
   }




   proc ::gui_cata::manual_insert_img {  } {
   
      global bddconf
   
      set log 1

      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]
      set imgfilename    [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set dirimgfilename [::bddimages_liste::lget $::tools_cata::current_image "dirfilename"]
      set imgfilebase    [file join $bddconf(dirbase) $dirimgfilename $imgfilename]

      set imgfilename    [unzipedfilename $imgfilename]
      set imgfiletmp     [file join $bddconf(dirtmp) $imgfilename]
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set catafiletmp "${f}_cata.xml"
   
      gren_info "Verification image $idbddimg\n"

      set ident [bddimages_image_identification $idbddimg]
      #gren_info "** ident = $ident\n"
      set fileimg      [lindex $ident 1]
      set idbddcata    [lindex $ident 2]
      set catafilebase [lindex $ident 3]

      if {$fileimg == -1} {
         ::console::affiche_erreur "Fichier image inexistant ($idbddimg) \n"
         ::console::affiche_erreur "Fichier image inexistant ($idbddimg) \n"
         return
      }
      
      if {$imgfilebase!=$fileimg} {
         ::console::affiche_erreur "Insertion de l image impossible\n"
         ::console::affiche_erreur "Le fichiers sont different.\n"
         ::console::affiche_erreur "Fichier MEMORY $filebase\n"
         ::console::affiche_erreur "Fichier SQL $fileimg\n"
         return
      }

      if {![file exists $imgfiletmp]} {
         ::console::affiche_erreur "Le fichier n existe pas\n"
         ::console::affiche_erreur "Creez le WCS\n"
         return
      }

      if {$catafilebase == -1 } {
         if {$log} {gren_info "cata n existe pas dans la base\n"}      
      } else {
         if {$log} {gren_info "cata existe dans la base\n"}
         if {$log} {gren_info "cata dans la base = $catafilebase\n"}
         if {$log} {gren_info "idbddcata = $idbddcata\n"}
      }



      gren_info "Effacement de l image dans la base\n"

      # efface l image dans la base et le disque
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      gren_info "Insertion de l image dans la base\n"
      #gren_info "idlist : $::tools_cata::id_current_image\n"
      set i [::bddimages_liste::lget [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image -1]] "idbddimg"]
      #gren_info "idlist2 : $i\n"
      #set filename2    [::bddimages_liste::lget [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image -1]] "filename"]
      #gren_info "file : $filename2\n"

      # Insertion de l image
      set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
      catch {gren_info "$errnum : $msg : $r"}
      if {$errnum==0} {
      
         # Modification de l idbddimg
         gren_info "\nInsertion reussie\n"
         gren_info "Old Idbddimg = $i\n"
         gren_info "New Idbddimg = $r\n"
         set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "idbddimg" $r]
         
         set idbddimg $r 
         
         # Modification du tabkey
         gren_info "Chargement du TABKEY depuis le buffer\n"
         set err [catch {set tabkey [::bdi_tools_image::get_tabkey_from_buffer] } msg ]
         if {$err} {
            ::console::affiche_erreur "Insertion Impossible :($err) $msg \n"
            return
         }

         # Modification du tabkey
         gren_info "Modification du TABKEY\n"
         set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]

         # Insertion du cata
         gren_info "Verification cata pour idbddimg=$idbddimg\n"
         if {![file exists $catafiletmp]} {
            ::console::affiche_erreur "Le fichier cata n existe pas\n"
         } else {
            if {$log} {gren_info "Le fichier cata existe dans tmp\n"}
            set ident [bddimages_image_identification $idbddimg]
            set catafilebase [lindex $ident 3]
            set idbddcata [lindex $ident 2]
            if {$catafilebase == -1 } {
               if {$log} {gren_info "cata n existe pas dans la base\n"}     
               # insertion du CATA
               set errnum [catch {set r [insertion_solo $catafiletmp]} msg ]
               catch {gren_info "$errnum : $msg : $r"}
               if {$errnum==0} {
                  gren_info "\nInsertion reussie\n"
                  gren_info "New Idbddcata = $r\n"
                  ::gui_cata::affiche_cata
               }
                
            } else {
               if {$log} {gren_info "cata existe dans la base\n"}
               if {$log} {gren_info "cata dans la base = $catafilebase\n"}
               if {$log} {gren_info "idbddcata = $idbddcata\n"}
            }
         }

         # Modification img_list
         gren_info "Modification de img_list\n"
         set i [expr $::tools_cata::id_current_image -1]
         set ::tools_cata::img_list [lreplace $::tools_cata::img_list $i $i $::tools_cata::current_image]

       }

   }





   proc ::gui_cata::getsource {  } {

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect ==""} {
         tk_messageBox -message "Veuillez selectionner un carre dans l'image" -type ok
         return
      }
      set l [::manage_source::extract_sources_by_array $rect $::tools_cata::current_listsources]
      ::manage_source::imprim_3_sources $l
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

           #--- Cree un frame pour afficher NOMAD1
           set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
           pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $nomad1.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_nomad1 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $nomad1.check -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.name -text "NOMAD1 :" -width 14 -anchor e
                pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.val -textvariable ::tools_cata::nb_nomad1 -width 4
                pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
                button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_nomad1 -command ""
                pack $nomad1.color -side left -anchor e -expand 0 
                spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_nomad1 -command "::gui_cata::affiche_cata" -width 3
                pack  $nomad1.radius -in $nomad1 -side left -anchor w

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






   proc ::gui_cata::unset_srpt {  } {
      
      set color red
      set width 2
      cleanmark

      foreach select [$::gui_astrometry::srpt curselection] {
         
         set data [$::gui_astrometry::srpt get $select]
         set name [lindex $data 0]
         set date $::tools_cata::current_image_date
         gren_info "gestion name = $name\n"
         gren_info "gestion date = $date\n"
         
         set id [lindex $::tools_astrometry::tabval($name,$date) 0]
         gren_info "gestion Id = $id\n"
         
         
         if {![winfo exists .gestion_cata.appli.onglets.nb]} {
            return
         }
         set onglets [.gestion_cata.appli.onglets.nb tabs]
         set f [.gestion_cata.appli.onglets.nb select]
         set idcata [string index [lindex [split $f .] 5] 1]
         array set cataname $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
         gren_info "cataname = $cataname($idcata)\n"

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
      
      ::gui_cata::unset_flag $f.frmtable.tbl

      ::gui_cata::propagation $f.frmtable.tbl
   
   }


   proc ::gui_cata::voir_srpt {  } {
      
      set color red
      set width 2
      cleanmark

      foreach select [$::gui_astrometry::srpt curselection] {
         
         set data [$::gui_astrometry::srpt get $select]
         set name [lindex $data 0]
         set date $::tools_cata::current_image_date
         gren_info "gestion name = $name\n"
         gren_info "gestion date = $date\n"
         
         set id [lindex $::tools_astrometry::tabval($name,$date) 0]
         gren_info "gestion Id = $id\n"
         
         
         if {![winfo exists .gestion_cata.appli.onglets.nb]} {
            return
         }
         set onglets [.gestion_cata.appli.onglets.nb tabs]
         set f [.gestion_cata.appli.onglets.nb select]
         set idcata [string index [lindex [split $f .] 5] 1]
         array set cataname $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
         gren_info "cataname = $cataname($idcata)\n"

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
   
   }


   proc ::gui_cata::voir_sret {  } {
      
      set color red
      set width 2
      cleanmark

      foreach select [$::gui_astrometry::sret curselection] {
         
         set data [$::gui_astrometry::sret get $select]
         set id [lindex $data 0]
         set date [lindex $data 1]
         #gren_info "Id = $id $date\n"
         #gren_info "gestion date = $::tools_cata::current_image_date\n"
         if {![winfo exists .gestion_cata.appli.onglets.nb]} {
            return
         }
         set onglets [.gestion_cata.appli.onglets.nb tabs]
         #gren_info "gestion onglets = $onglets\n"
         foreach f $onglets {
             #gren_info "f = $f.frmtable.tbl\n"
             set idcata [string index [lindex [split $f .] 5] 1]
             #gren_info "idcata = $idcata\n"
             array set cataname $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
             #gren_info "cataname = $cataname($idcata)\n"
             if { $cataname($idcata) == "ASTROID"} {
                .gestion_cata.appli.onglets.nb select $f
                set u 0
                foreach x [$f.frmtable.tbl get 0 end] {
                   set idx [lindex $x 0]
                   if {$idx == $id} {
                      #gren_info "ok= $u\n"
                      $f.frmtable.tbl selection set $u
                      set ra  [lindex $x [::gui_cata::get_pos_col ra]]
                      set dec [lindex $x [::gui_cata::get_pos_col dec]]
                      affich_un_rond $ra $dec $color $width
                   }
                   incr u
                }
                
             }

         }
         
      }
   
   }



   #--------------------------------------------------
   #  ::gui_cata::cmdButton1Click { frame }
   #--------------------------------------------------
   #
   #    fonction  : 
   #    
   #
   #    variables en entree :
   #        frame = reference de l'objet graphique de la selection
   #
   #    variables en sortie : void
   #
   #--------------------------------------------------
   proc ::gui_cata::cmdButton1Click { w args } {

      set color red
      set width 2
      cleanmark
      foreach select [$w curselection] {
         set id [lindex [$w get $select] 0]
         set ra [lindex [$w get $select] [::gui_cata::get_pos_col ra]]
         set dec [lindex [$w get $select] [::gui_cata::get_pos_col dec]]
         affich_un_rond $ra $dec $color $width
      }
      return

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


   proc ::gui_cata::selectall { tbl } {
      
      # Selectionne toutes les sources
      $tbl selection set 0 end

      # Affiche les sources selectionnees
      cleanmark
      set selected [$tbl get 0 end]
      foreach s $selected {
         set id [lindex $s 0]
         set ra [lindex $s [::gui_cata::get_pos_col ra]]
         set dec [lindex $s [::gui_cata::get_pos_col dec]]
         affich_un_rond $ra $dec red 2
      }
      return

   }


   proc ::gui_cata::is_astrometric_catalog { c } {

      return [expr [lsearch -exact [list USNOA2 UCAC2 UCAC3 UCAC4 TYCHO2] $c] + 1]
   }


   proc ::gui_cata::is_photometric_catalog { c } {

      return [expr [lsearch -exact [list USNOA2 UCAC2 UCAC3 UCAC4 TYCHO2] $c] + 1]
   }





   proc ::gui_cata::set_astrom_ref { tbl } {

      set flag "R"
      set onglets $::gui_cata::current_appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      if {![::gui_cata::is_astrometric_catalog $cataselect]} {
         tk_messageBox -message "Le catalogue selectionné $cataselect n'est pas astrometrique" -type ok
         return
      }

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)
         
            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }


            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col astrom_reference] [::gui_cata::get_pos_col astrom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col astrom_catalog] [::gui_cata::get_pos_col astrom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagastrom $idcata] [::gui_cata::get_pos_col flagastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataastrom $idcata] [::gui_cata::get_pos_col cataastrom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               #gren_info "on est ici $t\n"
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
               }
               continue
            }

            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  #gren_info "$id -> $u sur $t\n"
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }

         }

      }
      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "AV REF $a\n"

      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]

      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "SET REF $a\n"

      return
   }








   proc ::gui_cata::set_astrom_mes { tbl } {

      set flag "S"
      set onglets $::gui_cata::current_appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)

            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }
            
            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col astrom_reference] [::gui_cata::get_pos_col astrom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col astrom_catalog]   [::gui_cata::get_pos_col astrom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagastrom $idcata] [::gui_cata::get_pos_col flagastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataastrom $idcata] [::gui_cata::get_pos_col cataastrom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
               }
               continue
            }
            
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }
            
            
         }
         
      }
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }
 
 
 
 
 
 
 
 
 
   proc ::gui_cata::unset_flag { tbl } {

      set flag "-"
      gren_info "tbl=$tbl\n"
      set onglets $::gui_cata::current_appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)


            # Modification du cata_list_source

            if {[string compare -nocase $cata "ASTROID"] == 0} {

               gren_info "modif  current_listsources\n"
               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set x [lsearch -index 0 $a "ASTROID"]
               set astroid [lindex $a $x]

               set b [lindex $astroid 2]
               set pos [expr [::gui_cata::get_pos_col flagphotom $idcata] - 10]
               gren_info "pos flagphotom= $pos\n"
               set b [lreplace $b $pos $pos $flag]
               set pos [expr [::gui_cata::get_pos_col cataphotom $idcata] - 10]
               gren_info "pos cataphotom= $pos\n"
               set b [lreplace $b $pos $pos $flag]
               set pos [expr [::gui_cata::get_pos_col flagastrom $idcata] - 10]
               gren_info "pos flagastrom= $pos\n"
               set b [lreplace $b $pos $pos $flag]
               set pos [expr [::gui_cata::get_pos_col cataastrom $idcata] - 10]
               gren_info "pos cataastrom= $pos\n"
               set b [lreplace $b $pos $pos $flag]

               set astroid [lreplace $astroid 2 2 $b]
               set a [lreplace $a $x $x $astroid]

               set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
               set ::tools_cata::current_listsources [list $fields $sources]
               
            }









            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col astrom_reference] [::gui_cata::get_pos_col astrom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col astrom_catalog]   [::gui_cata::get_pos_col astrom_catalog]   $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_reference] [::gui_cata::get_pos_col photom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_catalog]   [::gui_cata::get_pos_col photom_catalog]   $flag]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagphotom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataphotom $idcata] $flag]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }







            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_catalog]   -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_catalog]   -text $flag
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataphotom $idcata] -text $flag
               }
               continue
            }
            
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_catalog]   -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_catalog]   -text $flag
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataphotom $idcata] -text $flag
                  }
                  break
               }
               incr u
            }               

         }
         
      }
      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "AV UNSET $a\n"

      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      
      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "UNSET $a\n"
      
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }














   proc ::gui_cata::set_photom_ref { tbl } {

      set flag "R"
      set onglets $::gui_cata::current_appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      if {![::gui_cata::is_photometric_catalog $cataselect]} {
         tk_messageBox -message "Le catalogue selectionné $cataselect n'est pas photometrique" -type ok
         return
      }

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)

            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }
            
            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col photom_reference] [::gui_cata::get_pos_col photom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_catalog] [::gui_cata::get_pos_col photom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagphotom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataphotom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
               }
               continue
            }
            
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }
            
         }
         
      }
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }
 
 
 
 
   proc ::gui_cata::set_photom_mes { tbl } {

      set flag "S"
      set onglets $::gui_cata::current_appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      #gren_info "Cata select = $cataselect\n"
      #gren_info "idCata select = $idcata\n"
      #gren_info "flag = $flag\n"

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         #gren_info "select = $id ($select)\n"
         #gren_info "tbl = $tbl\n"
         
         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)
            #gren_info "Cata   = $cata\n"
            #gren_info "idCata = $idcata\n"

            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }


            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            #gren_info "indice tklist($idcata)  =  $x\n"
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               #gren_info "a =  $a\n"
               set b [lreplace $a [::gui_cata::get_pos_col photom_reference] [::gui_cata::get_pos_col photom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_catalog] [::gui_cata::get_pos_col photom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagphotom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataphotom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               #gren_info "on est ici $t\n"
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
               }
               continue
            }
            
            set u 0
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  #gren_info "$id -> $u sur $t\n"
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }

         }

      }
      #set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] 0] 
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }
 
 
 
   proc ::gui_cata::grab_sources { tbl } {

      set color red
      set width 2
      cleanmark
      $tbl selection clear 0 end

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }

      set sources [lindex $::tools_cata::current_listsources 1]
      set id 1
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "IMG"} {
               set x [lindex [lindex $cata 2] 2]
               set y [lindex [lindex $cata 2] 3]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  # selection de la source
                  set u 0
                  # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
                  # l indice de la table.
                  foreach l [$tbl get 0 end] {
                     set idx [lindex $l 0]
                     if {$idx == $id} {
                        $tbl selection set $u
                        set ra  [lindex [lindex $cata 1] 0]
                        set dec [lindex [lindex $cata 1] 1]
                        affich_un_rond $ra $dec $color $width
                        break
                     }
                     incr u
                  }
               }
            }
         }
         incr id
      }
   }





   proc ::gui_cata::propagation { tbl } {

      set onglets $::gui_cata::current_appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]
      if {[string compare -nocase $cataselect "ASTROID"] == 0} {
         
         set propalist ""
         foreach select [$tbl curselection] {

            set id   [lindex [$tbl get $select] [::gui_cata::get_pos_col bdi_idc_lock $idcata]]
            set ar   [lindex [$tbl get $select] [::gui_cata::get_pos_col astrom_reference $idcata]]
            set ac   [lindex [$tbl get $select] [::gui_cata::get_pos_col astrom_catalog $idcata]]
            set pr   [lindex [$tbl get $select] [::gui_cata::get_pos_col photom_reference $idcata]]
            set pc   [lindex [$tbl get $select] [::gui_cata::get_pos_col photom_catalog $idcata]]
            set name [lindex [$tbl get $select] [::gui_cata::get_pos_col name $idcata]]
            set cata ""
            if {$ac != "-"} {
               set cata $ac
            } elseif {$pc != "-"} {
               set cata $pc
            }

            set s [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
            set namable [::manage_source::namable $s]

            #gren_info "namable = $namable\n"
            if {$namable==""} {
               set res [tk_messageBox -message "La source dont l'ID est $id ne peut pas etre propagee vers d'autres images car elle n est referencee dans aucun catalogue. Continuer quand meme ?" -type yesno]
               #gren_info "res = $res\n"
               if {$res=="no"} {
                  return
               } else {
                  continue
               }
            }
            
            if {$cata!=""} {
               set name [::manage_source::naming $s $cata]
            } else {
               #gren_info "\n*** s = $s \n\n"
               set cata $namable
               set name [::manage_source::naming $s $cata]
            }
            #gren_info "$id :: $ar $ac :: $pr $pc :: $name :: $cata\n"
            lappend propalist [list $cata $name $ar $ac $pr $pc]
         }
         
         if {[llength $propalist] > 0} {
            #gren_info "propalist =$propalist\n"
         } else {
            gren_info "Rien a faire ...\n"
            return
         }

         # on sauve les variables courantes
         set tklist_list_of_columns_sav [array get ::gui_cata::tklist_list_of_columns]
         
         # on boucle sur les images (sauf celle qui est courrante car rien a propager)
         for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

            if {$i == $::tools_cata::id_current_image} { continue }
               
            gren_info "Image =$i / $::tools_cata::nb_img_list\n"

            array set tklist                             $::gui_cata::tk_list($i,tklist)
            array set ::gui_cata::tklist_list_of_columns $::gui_cata::tk_list($i,list_of_columns)
            array set cataname                           $::gui_cata::tk_list($i,cataname)
            set current_listsources                      $::gui_cata::cata_list($i)
            set sources [lindex $current_listsources 1]

            #array set ::gui_cata::tklist                 $::gui_cata::tk_list($::tools_cata::id_current_image,tklist)
            #array set ::gui_cata::tklist_list_of_columns $::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns)
            #array set ::gui_cata::cataname               $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
            #set ::tools_cata::current_listsources        $::gui_cata::cata_list($::tools_cata::id_current_image)
            
#             gren_info "::gui_cata::cataname =[array get ::::gui_cata::cataname]\n"
            foreach {x y} [array get cataname] {
               #gren_info "getid=$x $y\n"
               set getid($y) $x
            }

            set nbcol [array size ::gui_cata::tklist_list_of_columns]
#            gren_info "nbcol =$nbcol\n"

            # Ob boucle sur les sources a propager
            foreach c $propalist {
            
               set cata [lindex $c 0]
               set name [lindex $c 1]
               set ar   [lindex $c 2]
               set ac   [lindex $c 3]
               set pr   [lindex $c 4]
               set pc   [lindex $c 5]

               set idcata $getid($cata)
               
#               gren_info "$cata ($idcata) :: $name :: $ar $ac :: $pr $pc\n"

               # on boucle sur les sources du cata
               set cpt 1
               set pass "no"
               foreach s $sources {
               
                  foreach c $s {
                     if {[lindex $c 0]==$cata} {
                        set namesou [::manage_source::naming $s $cata]
                        if {$namesou==$name} {
                           set pass "ok"
                           break
                        }
                     }
                  }
                  
                  if {$pass=="ok"} {break}
                  incr cpt
               }

               if {$pass=="ok"} {

                  #gren_info "source retrouvee $cpt $name\n"

                  # Modif TKLIST
                  foreach {idcata cata} [array get cataname] {

                     set pos [lsearch -index 0 $tklist($idcata) $cpt]
                     if {$pos != -1} {
                        set b [lindex $tklist($idcata) $pos]
                        #gren_info "*** $idcata $cata\n"
                        #gren_info "b = $b\n"
                        set col [::gui_cata::get_pos_col astrom_reference $idcata]
                        #gren_info "     ar = $ar , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $ar]
                        set col [::gui_cata::get_pos_col astrom_catalog $idcata]
                        #gren_info "     ac = $ac , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $ac]
                        set col [::gui_cata::get_pos_col photom_reference $idcata]
                        #gren_info "     pr = $pr , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $pr]
                        set col [::gui_cata::get_pos_col photom_catalog $idcata]
                        #gren_info "     pc = $pc , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $pc]
                        if {[string compare -nocase $cata "ASTROID"] == 0} {

                           #gren_info "tklist_list_of_columns =  $::gui_cata::tklist_list_of_columns($idcata)\n"

                           set col [::gui_cata::get_pos_col flagastrom $idcata]
                           #gren_info "     aar = $ar , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $ar]

                           set col [::gui_cata::get_pos_col cataastrom $idcata]
                           #gren_info "     aac = $ac , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $ac]

                           set col [::gui_cata::get_pos_col flagphotom $idcata]
                           #gren_info "     apr = $pr , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $pr]

                           set col [::gui_cata::get_pos_col cataphotom $idcata]
                           #gren_info "     apc = $pc , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $pc]
                        }
                        set tklist($idcata) [lreplace $tklist($idcata) $pos $pos $b]
                        #gren_info "a modif = [lindex $tklist($idcata) $pos]\n"



                     }
                     
                  }
                  
                  # Modif CATALIST
                  set s [lindex $sources [expr $cpt -1]]
                  #gren_info "S = $s\n"
                  set x  [lsearch -index 0 $s "ASTROID"]
                  if {$x>=0} {
                     set a [lindex $s $x]
                     set b [lindex $a 2]
                     set b [lreplace $b 23 23 $ar]
                     set b [lreplace $b 25 25 $ac]
                     set b [lreplace $b 24 24 $pr]
                     set b [lreplace $b 26 26 $pc]
                     set a [lreplace $a 2 2 $b]
                     #gren_info "a modif = $a\n"
                     set s [lreplace $s $x $x $a]
                     #gren_info "S modif = $s\n"
                     set sources [lreplace $sources [expr $cpt -1] [expr $cpt -1] $s]
                  }
               }
               
            }

            # Modification du tk_list
            set ::gui_cata::tk_list($i,tklist) [array get tklist]

            # Modification du cata_list
            set ::gui_cata::cata_list($i) [list [lindex $current_listsources 0] $sources]
             
            # break

         }

         # on recupere les variables courantes
         array set ::gui_cata::tklist_list_of_columns $tklist_list_of_columns_sav

      } else {
         tk_messageBox -message "Le catalogue selectionné doit etre ASTROID" -type ok
      }

   }
 
 
   proc ::gui_cata::edit_source { tbl } {
# 
#      foreach select [$tbl curselection] {
#         $tbl cellconfigure $select, -text $flag
#      }
#      $tbl rowconfigure -editable yes
#
#   
   }




 
   proc ::gui_cata::delete_sources { tbl } {

      set onglets $::gui_cata::current_appli.onglets
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      set cpt 0
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]
         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {
            set idcata [string index [lindex [split $t .] 5] 1]
            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x]
            }
         }

         # Modification du current_listsources
         set fields [lindex $::tools_cata::current_listsources 0]
         set sources [lindex $::tools_cata::current_listsources 1]
         set sources [lreplace $sources [expr $select-$cpt] [expr $select-$cpt]]
         set ::tools_cata::current_listsources [list $fields $sources]

         # Compteur de sources effacees
         incr cpt
      }
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      ::gui_cata::gestion_go
      return
 
   }


 
   proc ::gui_cata::delete_sources_allimg { tbl } {

      set onglets $::gui_cata::current_appli.onglets
      set idcata [string index [lindex [split $tbl .] 5] 1]
         
      set dellist ""
      foreach select [$tbl curselection] {
         set id [lindex [$tbl get $select] [::gui_cata::get_pos_col bdi_idc_lock $idcata]]
         set s [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
         set sname [::manage_source::naming $s "IMG"]
         lappend dellist $sname
      }
gren_info "ListToDel: $dellist\n"

      # Si la liste est vide, rien a faire
      if {[llength $dellist] < 1} {
         return
      }

      # On boucle sur les images (sauf celle qui est courrante car rien a propager)
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

::console::affiche_erreur "Image #$i / $::tools_cata::nb_img_list\n"

         array set tklist $::gui_cata::tk_list($i,tklist)
         array set cataname $::gui_cata::tk_list($i,cataname)
gren_info "cataname = [array get ::gui_cata::cataname]\n"
         set current_listsources $::gui_cata::cata_list($i)
         set sources [lindex $current_listsources 1]
#gren_info "sources = $sources \n"

            foreach {x y} [array get cataname] {
               set getid($y) $x
            }

         # On boucle sur les sources a effacer
         foreach dl $dellist {

gren_info "DL = $dl\n"

            # on boucle sur les sources du cata
            set cpt 1
            set pass "no"
            foreach s $sources {
               foreach c $s {
                  if {[lindex $c 0] == "IMG"} {
                     set namesou [::manage_source::naming $s "IMG"]
                     if {$namesou == $dl} {
                        set pass "ok"
                        break
                     }
                  }
               }
               if {$pass == "ok"} { break }
               incr cpt
            }

gren_info "PASS? $pass \n"

            if {$pass == "ok"} {

gren_info " => source retrouvee $cpt $dl\n"

               # Modif TKLIST
               foreach {idcata cata} [array get cataname] {
                  set x [lsearch -index 0 $tklist($idcata) $cpt]
                  if {$x != -1} {
                     set tklist($idcata) [lreplace $tklist($idcata) $x $x]
                  }
               }
 
               # Modif current_listsources
               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]
               set sources [lreplace $sources $cpt $cpt]
               set ::tools_cata::current_listsources [list $fields $sources]

            }
               
         }

         # Modification du tk_list
         set ::gui_cata::tk_list($i,tklist) [array get tklist]
         # Modification du cata_list
         set ::gui_cata::cata_list($i) [list [lindex $current_listsources 0] $sources]

      }

      ::gui_cata::gestion_go
      return

   } 
 
 
 
 
 
 
 
   proc ::gui_cata::create_Tbl_sources { idcata } {

      variable This
      global audace
      global caption
      global bddconf

      #--- Quelques raccourcis utiles
      set tbl $::gui_cata::frmtable($idcata).tbl
      set popupTbl $::gui_cata::frmtable($idcata).popupTbl

      #--- Table des objets
      tablelist::tablelist $tbl \
         -labelcommand tablelist::sortByColumn \
         -xscrollcommand [ list $::gui_cata::frmtable($idcata).hsb set ] \
         -yscrollcommand [ list $::gui_cata::frmtable($idcata).vsb set ] \
         -selectmode extended \
         -activestyle none \
         -stripebackground #e0e8f0 \
         -showseparators 1

      #--- Scrollbars verticale et horizontale
      $::gui_cata::frmtable($idcata).vsb configure -command [ list $tbl yview ]
      $::gui_cata::frmtable($idcata).hsb configure -command [ list $tbl xview ]

      #--- Gestion des popup

      #--- Menu pop-up associe a la table
      menu $popupTbl -title "Selection"

        # Edite la liste selectionnee
        $popupTbl add command -label "Grab les sources" \
           -command "::gui_cata::grab_sources $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Propager les sources" \
           -command "::gui_cata::propagation $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Editer la source" \
           -command "::gui_cata::edit_source $tbl" -state disable

        # Edite la liste selectionnee
        $popupTbl add command -label "Sauver la source" \
           -command "" -state disable

        # Supprime les sources selectionnees dans l'image courante
        $popupTbl add command -label "Supprimer dans l'image courante" \
           -command "::gui_cata::delete_sources $tbl"

        # Supprime les sources selectionnees dans toutes les images
        $popupTbl add command -label "Supprimer dans toutes les images" \
           -command "::gui_cata::delete_sources_allimg $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Unset" \
           -command "::gui_cata::unset_flag $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Set astrometric reference" \
           -command "::gui_cata::set_astrom_ref $tbl"

        # Supprime la liste selectionnee
        $popupTbl add command -label "Set astrometric mesure" \
           -command "::gui_cata::set_astrom_mes $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Set photometric reference" \
           -command "::gui_cata::set_photom_ref $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Set photometric mesure" \
           -command "::gui_cata::set_photom_mes $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Cataloguer la source" \
           -command "" -state disable


      #--- Gestion des evenements
      bind [$tbl bodypath] <Control-Key-a> [ list ::gui_cata::selectall $tbl ]
      bind $tbl <<ListboxSelect>> [ list ::gui_cata::cmdButton1Click %W ]
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      
   }









   proc ::gui_cata::charge_gestion_cata { img_list } {

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

      # Chargement premiere image sans GUI
      set ::tools_cata::id_current_image 1
      set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      set ::tools_cata::current_image_name $filename
      set ::tools_cata::current_image_date $date

      #?Charge l image a l ecran
      buf$::audace(bufNo) load $file
      cleanmark

      set ::gui_cata::stateback disabled
      set ::tools_cata::nb_img     0
      set ::tools_cata::nb_usnoa2  0
      set ::tools_cata::nb_tycho2  0
      set ::tools_cata::nb_ucac2   0
      set ::tools_cata::nb_ucac3   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0

      ::gui_cata::affiche_current_image
      ::gui_cata::affiche_cata

   }











   proc ::gui_cata::charge_current_cata { } {

      global bddconf
 
      #gren_info "charge_current_cata ::tools_cata::id_current_image = $::tools_cata::id_current_image\n"

      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

      set ::tools_cata::current_image_date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set file        [file join $bddconf(dirbase) $dirfilename $::tools_cata::current_image_name]
      
      ::gui_cata::load_cata

      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
      #gren_info "charge_current_catas ::tools_cata::id_current_image=$::tools_cata::id_current_image\n"

      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources

      # chargement de la tklist sous forme de liste tcl. (pour affichage)
      ::gui_cata::current_listsources_to_tklist

      set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

   }











   proc ::gui_cata::charge_memory { { gui 1 } } {

      if {$gui} {
      
         set state [$::gui_cata::current_appli.actions.charge cget -text]

         if  {$state == "Annuler"} {
             set ::gui_cata::annul 1
             return
         }

         set ::gui_cata::annul 0
         $::gui_cata::current_appli.actions.charge configure -text "Annuler"
      }

      for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image<=$::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {
         
         if {$gui} {
            if {$::gui_cata::annul == 1} {
               gren_info "Chargement annulé...\n"
               break
            }
         ::gui_cata::set_progress $::tools_cata::id_current_image $::tools_cata::nb_img_list
         }

         ::gui_cata::charge_current_cata

      }

      if {$gui} { ::gui_cata::set_progress 0 $::tools_cata::nb_img_list 

         $::gui_cata::current_appli.actions.charge configure -text "Charge"

         set ::gui_cata::directaccess 1
         ::gui_cata::gestion_go
      }

   }













   proc ::gui_cata::set_progress { cur max } {
      set ::gui_cata::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }













   proc ::gui_cata::current_listsources_to_tklist { } {

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
            set ar [lindex $b 23]
            set ac [lindex $b 25]
            set pr [lindex $b 24]
            set pc [lindex $b 26]   
            #gren_info "AR = $ar $ac $pr $pc\n"
         }

         foreach cata $s {
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











   proc ::gui_cata::affich_current_tklist { } {


      set onglets $::gui_cata::current_appli.onglets
   
      # TODO afficher l image ici
   
      set listsources $::tools_cata::current_listsources
      set fields [lindex $listsources 0]
   
      set nbcatadel [expr [llength [array get ::gui_cata::cataname]]/2]
      #gren_info "cataname = [array get ::gui_cata::cataname] \n"
      #gren_info "nbcatadel = $nbcatadel \n"
   
      foreach t [$onglets.nb tabs] {
         destroy $t
      }

      set idcata 0
      set select 0
      foreach field $fields {
         incr idcata
         
         set fc($idcata) [frame $onglets.nb.f$idcata]
         
         set c [lindex $field 0]
         
         $onglets.nb add $fc($idcata) -text $c
         if {$c=="IMG"} {
            set select $idcata
         }
      }
      set nbcata $idcata
      #gren_info "nbcata : $nbcata\n"
   
      if {$select >0} {$onglets.nb select $fc($select)}
      ttk::notebook::enableTraversal $onglets.nb

      for { set idcata 1 } { $idcata <= $nbcata} { incr idcata } {

         set ::gui_cata::frmtable($idcata) [frame $fc($idcata).frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
         pack $::gui_cata::frmtable($idcata) -expand yes -fill both -padx 3 -pady 6 -in $fc($idcata) -side right -anchor e

         #--- Cree un acsenseur vertical
         scrollbar $::gui_cata::frmtable($idcata).vsb -orient vertical \
            -command { $::gui_cata::frmtable($idcata).lst1 yview } -takefocus 1 -borderwidth 1
         pack $::gui_cata::frmtable($idcata).vsb -in $::gui_cata::frmtable($idcata) -side right -fill y

         #--- Cree un acsenseur horizontal
         scrollbar $::gui_cata::frmtable($idcata).hsb -orient horizontal \
            -command { $::gui_cata::frmtable($idcata).lst1 xview } -takefocus 1 -borderwidth 1
         pack $::gui_cata::frmtable($idcata).hsb -in $::gui_cata::frmtable($idcata) -side bottom -fill x

         #--- Creation de la table
         ::gui_cata::create_Tbl_sources $idcata
         pack  $::gui_cata::frmtable($idcata).tbl -in  $::gui_cata::frmtable($idcata) -expand yes -fill both


         catch { $::gui_cata::frmtable($idcata).tbl delete 0 end
                 $::gui_cata::frmtable($idcata).tbl deletecolumns 0 end  
         }
        
         set nbcol [llength $::gui_cata::tklist_list_of_columns($idcata)]
         for { set j 0 } { $j < $nbcol} { incr j } {
            set current_columns [lindex $::gui_cata::tklist_list_of_columns($idcata) $j]
            $::gui_cata::frmtable($idcata).tbl insertcolumns end 0 [lindex $current_columns 1] left
            $::gui_cata::frmtable($idcata).tbl columnconfigure $j -sortmode dictionary
         }

         #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
         if { [ $::gui_cata::frmtable($idcata).tbl columncount ] != "0" } {
            $::gui_cata::frmtable($idcata).tbl columnconfigure 0 -sortmode dictionary
         }
         foreach col {5 6 7 8 9} {
             $::gui_cata::frmtable($idcata).tbl columnconfigure $col -background ivory -sortmode dictionary
         }

         foreach line $::gui_cata::tklist($idcata) {
            $::gui_cata::frmtable($idcata).tbl insert end $line
         }
         
         #gren_info "$::gui_cata::cataname($idcata) : [llength $::gui_cata::tklist($idcata)]\n"
         #gren_info "onglets : [$::gui_cata::current_appli.onglets.nb tabs]\n"
         
         $::gui_cata::current_appli.onglets.nb tab [expr $idcata - 1] -text "([llength $::gui_cata::tklist($idcata)])$::gui_cata::cataname($idcata)"
         
      }
   }












   proc ::gui_cata::gestion_go { } {

      set ::tools_cata::id_current_image $::gui_cata::directaccess

      gren_info "image = $::tools_cata::id_current_image / $::tools_cata::nb_img_list\n"
      ::gui_cata::set_progress 0 100      

      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set ::tools_cata::current_image_date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      ::gui_cata::set_progress 33 100
      array set ::gui_cata::tklist_list_of_columns $::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns)
      array set ::gui_cata::tklist                 $::gui_cata::tk_list($::tools_cata::id_current_image,tklist)
      array set ::gui_cata::cataname               $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)

      ::gui_cata::set_progress 66 100
      ::gui_cata::affich_current_tklist
      ::gui_cata::set_progress 100 100
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   }











   proc ::gui_cata::gestion_next { } {

      if {$::gui_cata::directaccess==$::tools_cata::nb_img_list } {return}
      incr ::gui_cata::directaccess 
      ::gui_cata::gestion_go

   }
   
   
   
   
   
   
   
   
   
   
   proc ::gui_cata::gestion_back { } {

      if {$::gui_cata::directaccess==1 } {return}
      incr ::gui_cata::directaccess -1
      ::gui_cata::gestion_go

   }



   proc ::gui_cata::fermer_feng { } {

      set ::gui_cata::state_gestion 0
      cleanmark
      destroy $::gui_cata::feng

   }



   proc ::gui_cata::gestion_cata { img_list } {

      global audace
      global bddconf

      set ::gui_cata::directaccess 1
      set ::gui_cata::progress 0
      set ::tools_cata::mem_use 0
      set ::tools_cata::mem_total 0

      set ::gui_cata::state_gestion 1
      
      ::gui_cata::inittoconf
      
      ::gui_cata::charge_gestion_cata $img_list 




      #--- Creation de la fenetre
      set ::gui_cata::feng .gestion_cata
      if { [winfo exists $::gui_cata::feng] } {
         wm withdraw $::gui_cata::feng
         wm deiconify $::gui_cata::feng
         focus $::gui_cata::feng
         return
      }
      toplevel $::gui_cata::feng -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cata::feng ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cata::feng ] "+" ] 2 ]
      wm geometry $::gui_cata::feng +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cata::feng 1 1
      wm title $::gui_cata::feng "Gestion du CATA"
      wm protocol $::gui_cata::feng WM_DELETE_WINDOW "::gui_cata::fermer_feng"

      set frm $::gui_cata::feng.appli
      set ::gui_cata::current_appli $frm

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata::feng -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         #--- Cree un frame general
         set menubar [frame $frm.menubar -cursor arrow -borderwidth 1 -relief raised]
         pack $menubar -in $frm -side top -fill x

           #--- menu Fichier
           menubutton $menubar.catalog -text "Catalogue" -underline 0 -menu $menubar.catalog.menu
           menu $menubar.catalog.menu
             $menubar.catalog.menu add command -label "Personnel" \
                -command ""
             $menubar.catalog.menu add command -label "Astroid" \
                -command ""
             $menubar.catalog.menu add command -label "Astrometrie" \
                -command ""
             $menubar.catalog.menu add command -label "Photometrie" \
                -command ""
             $menubar.catalog.menu add separator
             $menubar.catalog.menu add command -label "Supprimer" \
                -command ""
             #$This.frame0.file.menu add command -label "$caption(bddimages_recherche,delete_list)" -command " ::bddimages_recherche::cmd_list_delete $This.frame6.liste.tbl "
           pack $menubar.catalog -side left

         #--- Cree un frame general
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #----- 
             button $actions.charge -state active -text "Charge" -relief "raised" -command "::gui_cata::charge_memory"
             pack $actions.charge -in $actions -side left -anchor w -padx 0

             set pf [ ttk::progressbar $actions.p -variable ::gui_cata::progress -orient horizontal -length 200 -mode determinate]
             pack $pf -in $actions -side left

             label $actions.lab1 -text "Img ("
             pack  $actions.lab1 -in $actions -side left -padx 5 -pady 0
             label $actions.lab2 -textvariable ::tools_cata::id_current_image
             pack  $actions.lab2 -in $actions -side left -padx 5 -pady 0
             label $actions.lab3 -text "/"
             pack  $actions.lab3 -in $actions -side left -padx 5 -pady 0
             label $actions.lab4 -textvariable ::tools_cata::nb_img_list
             pack  $actions.lab4 -in $actions -side left -padx 5 -pady 0
             label $actions.lab5 -text ")"
             pack  $actions.lab5 -in $actions -side left -padx 5 -pady 0

 
         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
            pack [ttk::notebook $onglets.nb] -expand yes -fill both 
 
 

#      ::gui_cata::affiche_Tbl_sources $nbcata   
        


        #--- Cree un frame pour afficher les boutons
        set infoimg [frame $frm.infoimg -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimg -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $infoimg.lab1 -textvariable ::tools_cata::id_current_image
             pack  $infoimg.lab1 -in $infoimg -side left -padx 5 -pady 0
             #--- Cree un checkbutton
             label $infoimg.lab2 -textvariable ::tools_cata::current_image_name
             pack  $infoimg.lab2 -in $infoimg -side left -padx 5 -pady 0
             #--- Cree un checkbutton
             label $infoimg.lab3 -textvariable ::tools_cata::current_image_date
             pack  $infoimg.lab3 -in $infoimg -side left -padx 5 -pady 0


        #--- Cree un frame pour afficher les boutons
        set navigation [frame $frm.navigation -borderwidth 0 -cursor arrow -relief groove]
        pack $navigation -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $navigation.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                   -command "::gui_cata::gestion_back" 
             pack $navigation.back -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $navigation.next -text "Suivant" -borderwidth 2 -takefocus 1 \
                   -command "::gui_cata::gestion_next" 
             pack $navigation.next -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un checkbutton
             label $navigation.lab -text "Access direct a l'image : "
             pack $navigation.lab -in $navigation -side left -padx 5 -pady 0
             entry $navigation.val -relief sunken \
                -textvariable ::gui_cata::directaccess -width 6 \
                -justify center
             pack $navigation.val -in $navigation -side left -pady 1 -anchor w
             button $navigation.go -text "Go" -borderwidth 1 -takefocus 1 \
                   -command "::gui_cata::gestion_go" 
             pack $navigation.go -side left -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0


        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonpied.annuler -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::fermer_feng"
             pack $boutonpied.annuler -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::save_cata"
             pack $boutonpied.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.aide -text "Aide" -borderwidth 2 -takefocus 1 \
                -command ""
             pack $boutonpied.aide -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_info [label $boutonpied.info -text ""]
             pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
             set ::gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
             pack $::gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


      ::gui_cata::charge_memory
   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   proc ::gui_cata::creation_cata { img_list } {

      global audace
      global bddconf

      ::gui_cata::inittoconf
      ::gui_cata::charge_list $img_list
      catch { 
         ::gui_cata::set_aladin_script_params
      }

      #--- Creation de la fenetre
      set ::gui_cata::fen .new
      if { [winfo exists $::gui_cata::fen] } {
         wm withdraw $::gui_cata::fen
         wm deiconify $::gui_cata::fen
         focus $::gui_cata::fen
         return
      }
      toplevel $::gui_cata::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cata::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cata::fen ] "+" ] 2 ]
      wm geometry $::gui_cata::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cata::fen 1 1
      wm title $::gui_cata::fen "Creation du CATA"
      wm protocol $::gui_cata::fen WM_DELETE_WINDOW "destroy $::gui_cata::fen"

      set frm $::gui_cata::fen.frm_creation_cata
      set ::gui_cata::current_appli $frm

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame general
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


             set ::gui_cata::gui_back [button $actions.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::back" -state $::gui_cata::stateback]
             pack $actions.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_next [button $actions.next -text "Next" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::next" -state $::gui_cata::statenext]
             pack $actions.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_create [button $actions.go -text "Create" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::get_cata" -state normal]
             pack $actions.go -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un label 
             set ::gui_cata::gui_stimage [label $actions.stimage -text "$::tools_cata::id_current_image / $::tools_cata::nb_img_list"]
             pack $::gui_cata::gui_stimage -side left -padx 3 -pady 3

             #--- Cree un frame pour afficher boucle
             set bouc [frame $actions.bouc -borderwidth 0 -cursor arrow -relief groove]
             pack $bouc -in $actions -side left -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un checkbutton
                  checkbutton $bouc.check -highlightthickness 0 -text "Analyse continue" -variable ::tools_cata::boucle
                  pack $bouc.check -in $bouc -side left -padx 5 -pady 0


             #--- Cree un frame general
             set lampions [frame $actions.actions -borderwidth 0 -cursor arrow -relief groove]
             pack $lampions -in $actions -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

                  set ::gui_cata::gui_wcs [button $lampions.wcs -text "WCS" \
                     -borderwidth 1 -takefocus 0 -command "" \
                     -bg $::gui_cata::color_wcs -relief sunken -state disabled]
                  pack $lampions.wcs -side top -anchor e -expand 0 -padx 0 -pady 0 -ipadx 0 -ipady 0

                  set ::gui_cata::gui_cata [button $lampions.cata -text "CATA" -borderwidth 1 -takefocus 0 -command "" \
                     -bg $::gui_cata::color_cata -relief sunken -state disabled]
                  pack $lampions.cata -side top -anchor e -expand 0 -padx 0 -pady 0 -ipadx 0 -ipady 0


         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand 0 -fill x -padx 10 -pady 5
 
            pack [ttk::notebook $onglets.nb]
            set f1 [frame $onglets.nb.f1]
            set f2 [frame $onglets.nb.f2]
            set f3 [frame $onglets.nb.f3]
            set f4 [frame $onglets.nb.f4]
            set f5 [frame $onglets.nb.f5]
            set f6 [frame $onglets.nb.f6]
            set f7 [frame $onglets.nb.f7]
            set f8 [frame $onglets.nb.f8]
            set f9 [frame $onglets.nb.f9]
            
            $onglets.nb add $f1 -text "Catalogues"
            $onglets.nb add $f2 -text "Variables"
            $onglets.nb add $f3 -text "Entete"
            $onglets.nb add $f4 -text "Couleurs"
            $onglets.nb add $f5 -text "Sextractor"
            $onglets.nb add $f6 -text "Astroid"
            $onglets.nb add $f7 -text "Interop"
            $onglets.nb add $f8 -text "Manuel"
            $onglets.nb add $f9 -text "Develop"

            $onglets.nb select $f3
            ttk::notebook::enableTraversal $onglets.nb

        #--- Cree un frame pour afficher ucac2
        set usnoa2 [frame $f1.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
        pack $usnoa2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $usnoa2.check -highlightthickness 0 -text "USNO-A2" \
                              -variable ::tools_cata::use_usnoa2 -state disabled
             pack $usnoa2.check -in $usnoa2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $usnoa2.dir -relief sunken -textvariable ::tools_cata::catalog_usnoa2 -width 30
             pack $usnoa2.dir -in $usnoa2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set tycho2 [frame $f1.tycho2 -borderwidth 0 -cursor arrow -relief groove]
        pack $tycho2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $tycho2.check -highlightthickness 0 -text "TYCHO-2" -variable ::tools_cata::use_tycho2
             pack $tycho2.check -in $tycho2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $tycho2.dir -relief sunken -textvariable ::tools_cata::catalog_tycho2 -width 30
             pack $tycho2.dir -in $tycho2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set ucac2 [frame $f1.ucac2 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac2.check -highlightthickness 0 -text "UCAC2" -variable ::tools_cata::use_ucac2
             pack $ucac2.check -in $ucac2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac2.dir -relief sunken -textvariable ::tools_cata::catalog_ucac2 -width 30
             pack $ucac2.dir -in $ucac2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac3
        set ucac3 [frame $f1.ucac3 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac3 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac3.check -highlightthickness 0 -text "UCAC3" -variable ::tools_cata::use_ucac3
             pack $ucac3.check -in $ucac3 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac3.dir -relief sunken -textvariable ::tools_cata::catalog_ucac3 -width 30
             pack $ucac3.dir -in $ucac3 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher nomad1
        set nomad1 [frame $f1.nomad1 -borderwidth 0 -cursor arrow -relief groove]
        pack $nomad1 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $nomad1.check -highlightthickness 0 -text "NOMAD1" -variable ::tools_cata::use_nomad1 -state disabled
             pack $nomad1.check -in $nomad1 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $nomad1.dir -relief sunken -textvariable ::tools_cata::catalog_nomad1 -width 30
             pack $nomad1.dir -in $nomad1 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher boucle
        set skybot [frame $f1.skybot -borderwidth 0 -cursor arrow -relief groove]
        pack $skybot -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $skybot.check -highlightthickness 0 -text "Utiliser SkyBoT" -variable ::tools_cata::use_skybot
             pack $skybot.check -in $skybot -side left -padx 5 -pady 0
  


        #--- Cree un frame pour afficher delkwd PV
        set deuxpasses [frame $f2.deuxpasses -borderwidth 0 -cursor arrow -relief groove]
        pack $deuxpasses -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $deuxpasses.check -highlightthickness 0 -text "Faire 2 passes pour calibrer" -variable ::tools_cata::deuxpasses
             pack $deuxpasses.check -in $deuxpasses -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher "utiliser les RA/DEC precedent
        set keepradec [frame $f2.keepradec -borderwidth 0 -cursor arrow -relief groove]
        pack $keepradec -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $keepradec.check -highlightthickness 0 -text "Utiliser RADEC precedent" -variable ::tools_cata::keep_radec
             pack $keepradec.check -in $keepradec -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher delkwd PV
        set delpv [frame $f2.delpv -borderwidth 0 -cursor arrow -relief groove]
        pack $delpv -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $delpv.check -highlightthickness 0 -text "Suppression des PV(1,2)_0" -variable ::tools_cata::delpv
             pack $delpv.check -in $delpv -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher creation du cata
        set create_cata [frame $f2.create_cata -borderwidth 0 -cursor arrow -relief groove]
        pack $create_cata -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $create_cata.check -highlightthickness 0 -text "Inserer le fichier CATA" -variable ::tools_cata::create_cata
             pack $create_cata.check -in $create_cata -side left -padx 5 -pady 0
  
  

        #--- Cree un frame pour afficher boucle
        set limit_nbstars [frame $f2.limit_nbstars -borderwidth 0 -cursor arrow -relief groove]
        pack $limit_nbstars -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $limit_nbstars.lab -text "Limite acceptable du nb d'etoiles identifiees : " 
             pack $limit_nbstars.lab -in $limit_nbstars -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $limit_nbstars.val -relief sunken -textvariable ::tools_cata::limit_nbstars_accepted
             pack $limit_nbstars.val -in $limit_nbstars -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set log [frame $f2.log -borderwidth 0 -cursor arrow -relief groove]
        pack $log -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $log.check -highlightthickness 0 -text "Activation du log" -variable ::tools_cata::log
             pack $log.check -in $log -side left -padx 5 -pady 0

        #--- Cree un frame pour afficher boucle
        set treshold_ident [frame $f2.treshold_ident_star -borderwidth 0 -cursor arrow -relief groove]
        pack $treshold_ident -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $treshold_ident.lab1 -text "Seuil d'indentification stellaire : En position :" 
             pack $treshold_ident.lab1 -in $treshold_ident -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $treshold_ident.val1 -relief sunken -textvariable ::tools_cata::treshold_ident_pos_star -width 5
             pack $treshold_ident.val1 -in $treshold_ident -side left -pady 1 -anchor w
             #--- Cree un checkbutton
             label $treshold_ident.lab2 -text "En magnitude :"
             pack $treshold_ident.lab2 -in $treshold_ident -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $treshold_ident.val2 -relief sunken -textvariable ::tools_cata::treshold_ident_mag_star -width 5
             pack $treshold_ident.val2 -in $treshold_ident -side left -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set treshold_ident [frame $f2.treshold_ident_ast -borderwidth 0 -cursor arrow -relief groove]
        pack $treshold_ident -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $treshold_ident.lab1 -text "Seuil d'indentification planetaire : En position :" 
             pack $treshold_ident.lab1 -in $treshold_ident -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $treshold_ident.val1 -relief sunken -textvariable ::tools_cata::treshold_ident_pos_ast -width 5
             pack $treshold_ident.val1 -in $treshold_ident -side left -pady 1 -anchor w
             #--- Cree un checkbutton
             label $treshold_ident.lab2 -text "En magnitude :" 
             pack $treshold_ident.lab2 -in $treshold_ident -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $treshold_ident.val2 -relief sunken -textvariable ::tools_cata::treshold_ident_mag_ast -width 5
             pack $treshold_ident.val2 -in $treshold_ident -side left -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set myuncosm [frame $f2.myuncosm -borderwidth 0 -cursor arrow -relief groove]
        pack $myuncosm -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $myuncosm.check -highlightthickness 0 -text "Supprimer les cosmiques :" -variable ::gui_cata::use_uncosmic
             pack $myuncosm.check -in $myuncosm -side left -padx 5 -pady 0
  
             #--- Cree un checkbutton
             label $myuncosm.lab1 -text "coef :" 
             pack $myuncosm.lab1 -in $myuncosm -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $myuncosm.val1 -relief sunken -textvariable ::tools_cdl::uncosm_param1 -width 5
             pack $myuncosm.val1 -in $myuncosm -side left -pady 1 -anchor w
             #--- Cree un checkbutton
             label $myuncosm.lab2 -text "clipmax :" 
             pack $myuncosm.lab2 -in $myuncosm -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $myuncosm.val2 -relief sunken -textvariable ::tools_cdl::uncosm_param2 -width 5
             pack $myuncosm.val2 -in $myuncosm -side left -pady 1 -anchor w


        #--- Cree un frame pour afficher info image
        set infoimage [frame $f3.infoimage -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimage -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 

            #--- Cree un label pour le Nom de l image
            set ::gui_cata::gui_nomimage [label $infoimage.nomimage -text $::tools_cata::current_image_name]
            pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

            set ::gui_cata::gui_dateimage [label $infoimage.dateimage -text $::tools_cata::current_image_date]
            pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3


        #--- Cree un frame pour afficher les champs du header
        set keys [frame $f3.keys -borderwidth 0 -cursor arrow -relief groove]
        pack $keys -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- RA
            set ra [frame $keys.ra -borderwidth 0 -cursor arrow -relief groove]
            pack $ra -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $ra.name -text "RA : "
                pack $ra.name -in $ra -side left -padx 3 -pady 3
                entry $ra.val -relief sunken -textvariable ::tools_cata::ra
                pack $ra.val -in $ra -side right -pady 1 -anchor w

            #--- DEC
            set dec [frame $keys.dec -borderwidth 0 -cursor arrow -relief groove]
            pack $dec -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $dec.name -text "DEC : "
                pack $dec.name -in $dec -side left -padx 3 -pady 3
                entry $dec.val -relief sunken -textvariable ::tools_cata::dec
                pack $dec.val -in $dec -side right -pady 1 -anchor w

            #--- pixsize1
            set pixsize1 [frame $keys.pixsize1 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize1 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize1.name -text "PIXSIZE1 : "
                pack $pixsize1.name -in $pixsize1 -side left -padx 3 -pady 3
                entry $pixsize1.val -relief sunken -textvariable ::tools_cata::pixsize1
                pack $pixsize1.val -in $pixsize1 -side right -pady 1 -anchor w

            #--- pixsize2
            set pixsize2 [frame $keys.pixsize2 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize2 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize2.name -text "PIXSIZE2 : "
                pack $pixsize2.name -in $pixsize2 -side left -padx 3 -pady 3
                entry $pixsize2.val -relief sunken -textvariable ::tools_cata::pixsize2
                pack $pixsize2.val -in $pixsize2 -side right -pady 1 -anchor w

            #--- foclen
            set foclen [frame $keys.foclen -borderwidth 0 -cursor arrow -relief groove]
            pack $foclen -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $foclen.name -text "FOCLEN : "
                pack $foclen.name -in $foclen -side left -padx 3 -pady 3
                entry $foclen.val -relief sunken -textvariable ::tools_cata::foclen
                pack $foclen.val -in $foclen -side right -pady 1 -anchor w

            #--- set and reset center
            set setbut [frame $f3.setbut -borderwidth 0 -cursor arrow -relief groove]
            pack $setbut -in $f3 -anchor s -side top -expand 0 -padx 5 -pady 5
               #--- set val
               button $setbut.setval -text "Set Center" -borderwidth 2 -takefocus 1 -command "::gui_cata::setval"
               pack $setbut.setval -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
               #--- reset center
               button $setbut.resetval -text "Reset Center" -borderwidth 2 -takefocus 1 -command "::gui_cata::resetcenter"
               pack $setbut.resetval -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

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
                button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac2 -command ""
                pack $ucac2.color -side left -anchor e -expand 0 
                spinbox $ucac2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_ucac2 -command "::gui_cata::affiche_cata" -width 3
                pack  $ucac2.radius -in $ucac2 -side left -anchor w

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

           #--- Cree un frame pour afficher NOMAD1
           set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
           pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $nomad1.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_nomad1 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $nomad1.check -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.name -text "NOMAD1 :" -width 14 -anchor e
                pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.val -textvariable ::tools_cata::nb_nomad1 -width 4
                pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
                button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_nomad1 -command ""
                pack $nomad1.color -side left -anchor e -expand 0 
                spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::gui_cata::size_nomad1 -command "::gui_cata::affiche_cata" -width 3
                pack  $nomad1.radius -in $nomad1 -side left -anchor w

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

        #--- Cree un frame pour la conf Sextractor
        set confsex [frame $f5.confsex -borderwidth 0 -cursor arrow -relief groove]
        pack $confsex -in $f5 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                frame $confsex.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $confsex.buttons  -in $confsex  -side top -anchor e -expand 0 

                     button  $confsex.buttons.clean  -borderwidth 1  \
                         -command "cleanmark" -text "Clean"
                     pack    $confsex.buttons.clean  -side left -anchor e -expand 0 
                     button  $confsex.buttons.test  -borderwidth 1  \
                         -command "::gui_cata::test_confsex" -text "Test"
                     pack    $confsex.buttons.test  -side left -anchor e -expand 0 
                     button  $confsex.buttons.save  -borderwidth 1  \
                         -command "::gui_cata::set_confsex" -text "Save"
                     pack    $confsex.buttons.save  -side left -anchor e -expand 0 

                #--- Cree un label pour le titre
                text $confsex.file 
                pack $confsex.file -in $confsex -side top -padx 3 -pady 3 -anchor w 

                ::gui_cata::get_confsex

        #--- Cree un frame pour la conf Astroid
        set astroid [frame $f6.confsex -borderwidth 0 -cursor arrow -relief groove]
        pack $astroid -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               #--- Creation du cata Astroid
               set creer [frame $astroid.creer -borderwidth 1 -cursor arrow -relief groove]
               pack $creer -in $astroid -side top -anchor w -expand 0 -fill x -pady 5
                  checkbutton $creer.check -highlightthickness 0 -text " Creer le cata Astroid" \
                        -variable ::tools_cata::use_astroid -state normal
                  pack $creer.check -in $creer -side left -padx 3 -pady 3 -anchor w 

               #--- Options de creation du cata Asttroid
               set opts [frame $astroid.opts -borderwidth 1 -cursor arrow -relief sunken]
               pack $opts -in $astroid  -side top -anchor e -expand 0 -fill x 
        
                  #--- Niveau de saturation (ADU)
                  set saturation [frame $opts.saturation]
                  pack $saturation -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $saturation.lab -text "Niveau de saturation (ADU)" -width 24 -anchor e
                       pack $saturation.lab -in $saturation -side left -padx 5 -pady 0 -anchor e
                       entry $saturation.val -relief sunken -textvariable ::tools_cata::astroid_saturation -width 6
                       pack $saturation.val -in $saturation -side left -pady 1 -anchor w

                  #--- Delta
                  set delta [frame $opts.delta]
                  pack $delta -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $delta.lab -text "Delta (pixel)" -width 24 -anchor e
                       pack $delta.lab -in $delta -side left -padx 5 -pady 0 -anchor e
                       entry $delta.val -relief sunken -textvariable ::tools_cata::astroid_delta -width 3
                       pack $delta.val -in $delta -side left -pady 1 -anchor w

                     #--- Recherche du best delta
                     set best [frame $delta.best]
                     pack $best -in $delta -side top -anchor e -expand 0 -fill x -pady 5
                        button $best.cherche  -borderwidth 1 -command "" -text "Rechercher le meilleur delta" -state disabled
                        pack $best.cherche -in $best -side left -anchor e -expand 0 -padx 10
                        label $best.sol -textvariable ::gui_cata::gui_astroid_bestdelta -anchor e
                        pack $best.sol -in $best -side left -padx 5 -pady 0 -anchor e

                  #--- Threshold
                  set threshold [frame $opts.threshold]
                  pack $threshold -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $threshold.lab -text "Threshold (pixel)" -width 24 -anchor e
                       pack $threshold.lab -in $threshold -side left -padx 5 -pady 0 -anchor e
                       entry $threshold.val -relief sunken -textvariable ::tools_cata::astroid_threshold -width 3
                       pack $threshold.val -in $threshold -side left -pady 1 -anchor w


        #--- Cree un frame pour afficher les actions Interop
        set interop [frame $f7.interop -borderwidth 0 -cursor arrow -relief groove]
        pack $interop -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
  
           # Bouton pour envoyer les plans courants (image,table) vers Aladin
           set plan [frame $interop.plan -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
           pack $plan -in $interop -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
              label $plan.lab -text "Envoyer le plan vers "
              pack $plan.lab -in $plan -side left -padx 3 -pady 3
              button $plan.aladin -text "Aladin" -borderwidth 2 -takefocus 1 -command "::gui_cata::sendImageAndTable" 
              pack $plan.aladin -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           # 
           set dss [frame $interop.dss -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
           pack $dss -in $interop -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set l [frame $dss.l -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $l -in $dss -anchor s -side left -expand 0 -fill x -padx 10 -pady 5
                 label $l.date -justify right -text "Epoque (UTC) : "
                 pack $l.date -in $l -side top -padx 3 -pady 3
                 label $l.coord -justify right -text "Coordonnees (RA DEC) : "
                 pack $l.coord -in $l -side top -padx 3 -pady 3
                 label $l.radius -justify right -text "Rayon (arcmin) : "
                 pack $l.radius -in $l -side top -padx 3 -pady 3
                 label $l.uaicode -justify right -text "UAI Code : "
                 pack $l.uaicode -in $l -side top -padx 3 -pady 3
 
              set m [frame $dss.m -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $m -in $dss -anchor s -side left -expand 0 -fill x -padx 10 -pady 5
                 entry $m.date -relief sunken -width 26 -textvariable ::tools_cata::current_image_date
                 pack $m.date -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.coord -relief sunken -width 26 -textvariable ::tools_cata::coord
                 pack $m.coord -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.radius -relief sunken -width 26 -textvariable ::tools_cata::radius
                 pack $m.radius -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.uaicode -relief sunken -width 26 -textvariable ::tools_cata::uaicode
                 pack $m.uaicode -in $m -side top -padx 3 -pady 3 -anchor w

              set r [frame $dss.r -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $r -in $dss -anchor s -side left -expand 0 -fill x -padx 3 -pady 3
                 button $r.resolve -text "Resolve Sso" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 \
                        -command "::gui_cata::skybotResolver"
                 pack $r.resolve -side top -anchor e -padx 3 -pady 1 -ipadx 2 -ipady 2 -expand 0
                 button $r.setcenter -text "Set Center" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 \
                        -command "::gui_cata::setCenterFromRADEC"
                 pack $r.setcenter -side top -anchor e -padx 3 -pady 1 -ipadx 2 -ipady 2 -expand 0
                 button $r.aladin -text "Show in Aladin" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 \
                        -command "::gui_cata::sendAladinScript" 
                 pack $r.aladin -side top -anchor e -padx 3 -pady 1 -ipadx 2 -ipady 2 -expand 0

              #--- Cree un frame pour afficher la GUI du Mode Manuel
              set manuel [frame $f8.manuel -borderwidth 0 -cursor arrow -relief groove]
              pack $manuel -in $f8 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                 frame $manuel.entr -borderwidth 0 -cursor arrow -relief groove
                 pack $manuel.entr  -in $manuel  -side top 

                     set dss [frame $manuel.entr.dss -borderwidth 0 -cursor arrow]
                     pack $dss -in $manuel.entr -side top 

                          button  $dss.lab  -borderwidth 1 -command "::gui_cata::getDSS" -text "Obtenir une image DSS"
                          pack   $dss.lab   -in $dss -side top -padx 3 -pady 3 -anchor c

                          set basic [frame $dss.basic -borderwidth 0 -cursor arrow  -borderwidth 0]
                          pack $basic -in $dss -side top 

                               frame  $basic.alpha -borderwidth 0 -cursor arrow -relief groove
                               pack   $basic.alpha  -in $basic  -side left 
                                      label  $basic.alpha.lab   -text "Alpha (deg)" -borderwidth 1
                                      pack   $basic.alpha.lab   -in $basic.alpha -side top -padx 3 -pady 3 -anchor c
                                      entry  $basic.alpha.val -relief sunken -textvariable ::tools_cata::ra -width 10
                                      pack   $basic.alpha.val -in $basic.alpha -side top -padx 3 -pady 3 -anchor w

                               frame  $basic.delta -borderwidth 0 -cursor arrow -relief groove
                               pack   $basic.delta  -in $basic  -side left 
                                      label  $basic.delta.lab   -text "Delta (deg)" -borderwidth 1
                                      pack   $basic.delta.lab   -in $basic.delta -side top -padx 3 -pady 3 -anchor c
                                      entry  $basic.delta.val -relief sunken -textvariable ::tools_cata::dec -width 10
                                      pack   $basic.delta.val -in $basic.delta -side top -padx 3 -pady 3 -anchor w

                               frame  $basic.fov -borderwidth 0 -cursor arrow -relief groove
                               pack   $basic.fov  -in $basic  -side left 
                                      label  $basic.fov.lab   -text "Fov (arcmin)" -borderwidth 1
                                      pack   $basic.fov.lab   -in $basic.fov -side top -padx 3 -pady 3 -anchor c
                                      entry  $basic.fov.val -relief sunken -textvariable ::tools_cata::radius -width 10
                                      pack   $basic.fov.val -in $basic.fov -side top -padx 3 -pady 3 -anchor w

                               frame  $basic.crota -borderwidth 0 -cursor arrow -relief groove
                               pack   $basic.crota  -in $basic  -side left 
                                      label  $basic.crota.lab   -text "Orientation (deg)" -borderwidth 1
                                      pack   $basic.crota.lab   -in $basic.crota -side top -padx 3 -pady 3 -anchor c
                                      entry  $basic.crota.val -relief sunken -textvariable ::tools_cata::crota -width 10
                                      pack   $basic.crota.val -in $basic.crota -side top -padx 3 -pady 3 -anchor w

                     #set minfo [frame $manuel.entr.info -borderwidth 1 -cursor arrow]
                     #pack $minfo -in $manuel.entr -side top -pady 5
                     
                          #set mode_manuel "Selectionner une source en dessinant un carre dans l'image a reduire, et selectionner de meme l'etoile correspondante dans l'image DSS, puis cliquer sur le bouton GRAB.\n"
                          #text $minfo.txt -wrap word -width 70 -height 4 -relief groove
                          #$minfo.txt insert 1.0 $mode_manuel
                          #pack  $minfo.txt -in $minfo -side left -expand 0 -fill both -padx 10

                     set coord [frame $manuel.entr.coord -borderwidth 0 -cursor arrow]
                     pack $coord -in $manuel.entr 

                          image create photo icon_clean
                          icon_clean configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
            
                          set img [frame $coord.l -borderwidth 0 -cursor arrow  -borderwidth 0]
                          pack $img -in $coord -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                                frame $img.title -borderwidth 0 -cursor arrow -relief groove
                                pack $img.title  -in $img  -side top  -anchor c
                                   label $img.title.xy  -text "X Y (pixel)" -borderwidth 0 -relief groove  -width 25
                                   pack  $img.title.xy -in $img.title -side left -padx 3 -pady 3 -anchor w
                                   label $img.title.ad  -text "Alpha Delta (deg)" -borderwidth 0  -relief groove  -width 25
                                   pack  $img.title.ad -in $img.title -side right -padx 3 -pady 3 -anchor e

                                frame $img.v1 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v1  -in $img  -side top 
                                   entry $img.v1.xy -relief sunken -textvariable ::gui_cata::man_xy_star(1)
                                   pack  $img.v1.xy -in $img.v1 -side left -padx 3 -pady 3 -anchor w
                                   button  $img.v1.grab  -borderwidth 1 -command "::gui_cata::grab 1" -text "Grab"
                                   pack    $img.v1.grab -in $img.v1 -side left -anchor e -expand 0 
                                   entry $img.v1.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(1)
                                   pack  $img.v1.ad -in $img.v1 -side left -padx 3 -pady 3 -anchor w
                                   button $img.v1.clean  -borderwidth 1 -image icon_clean -command {
                                      set ::gui_cata::man_xy_star(1) ""
                                      set ::gui_cata::man_ad_star(1) ""
                                   }
                                   pack   $img.v1.clean -in $img.v1 -side left -anchor e -expand 0 

                                frame $img.v2 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v2  -in $img  -side top 
                                   entry $img.v2.xy -relief sunken -textvariable ::gui_cata::man_xy_star(2)
                                   pack  $img.v2.xy -in $img.v2 -side left -padx 3 -pady 3 -anchor w
                                   button  $img.v2.grab  -borderwidth 1 -command "::gui_cata::grab 2" -text "Grab"
                                   pack    $img.v2.grab -in $img.v2 -side left -anchor e -expand 0 
                                   entry $img.v2.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(2)
                                   pack  $img.v2.ad -in $img.v2 -side left -padx 3 -pady 3 -anchor w
                                   button $img.v2.clean  -borderwidth 1 -image icon_clean -command {
                                     set ::gui_cata::man_xy_star(2) ""
                                     set ::gui_cata::man_ad_star(2) ""
                                   }
                                   pack   $img.v2.clean -in $img.v2 -side left -anchor e -expand 0 

                                frame $img.v3 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v3  -in $img  -side top 
                                   entry $img.v3.xy -relief sunken -textvariable ::gui_cata::man_xy_star(3)
                                   pack  $img.v3.xy -in $img.v3 -side left -padx 3 -pady 3 -anchor w
                                   button $img.v3.grab  -borderwidth 1 -command "::gui_cata::grab 3" -text "Grab"
                                   pack   $img.v3.grab -in $img.v3 -side left -anchor e -expand 0 
                                   entry $img.v3.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(3)
                                   pack  $img.v3.ad -in $img.v3 -side left -padx 3 -pady 3 -anchor w
                                   button $img.v3.clean  -borderwidth 1 -image icon_clean -command {
                                      set ::gui_cata::man_xy_star(3) ""
                                      set ::gui_cata::man_ad_star(3) ""
                                   }
                                   pack   $img.v3.clean -in $img.v3 -side left -anchor e -expand 0 

                                frame $img.v4 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v4  -in $img  -side top 
                                   entry $img.v4.xy -relief sunken -textvariable ::gui_cata::man_xy_star(4)
                                   pack  $img.v4.xy -in $img.v4 -side left -padx 3 -pady 3 -anchor w
                                   button  $img.v4.grab  -borderwidth 1 -command "::gui_cata::grab 4" -text "Grab"
                                   pack    $img.v4.grab -in $img.v4 -side left -anchor e -expand 0 
                                   entry $img.v4.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(4)
                                   pack  $img.v4.ad -in $img.v4 -side left -padx 3 -pady 3 -anchor w
                                    button $img.v4.clean  -borderwidth 1 -image icon_clean -command {
                                       set ::gui_cata::man_xy_star(4) ""
                                       set ::gui_cata::man_ad_star(4) ""
                                    }
                                    pack   $img.v4.clean -in $img.v4 -side left -anchor e -expand 0 

                                frame $img.v5 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v5  -in $img  -side top 
                                   entry $img.v5.xy -relief sunken -textvariable ::gui_cata::man_xy_star(5)
                                   pack  $img.v5.xy -in $img.v5 -side left -padx 3 -pady 3 -anchor w
                                   button  $img.v5.grab  -borderwidth 1 -command "::gui_cata::grab 5" -text "Grab"
                                   pack    $img.v5.grab -in $img.v5 -side left -anchor e -expand 0 
                                   entry $img.v5.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(5)
                                   pack  $img.v5.ad -in $img.v5 -side left -padx 3 -pady 3 -anchor w
                                    button $img.v5.clean  -borderwidth 1 -image icon_clean -command {
                                       set ::gui_cata::man_xy_star(5) ""
                                       set ::gui_cata::man_ad_star(5) ""
                                    }
                                    pack   $img.v5.clean -in $img.v5 -side left -anchor e -expand 0 

                                frame $img.v6 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v6  -in $img  -side top 
                                   entry $img.v6.xy -relief sunken -textvariable ::gui_cata::man_xy_star(6)
                                   pack  $img.v6.xy -in $img.v6 -side left -padx 3 -pady 3 -anchor w
                                   button  $img.v6.grab  -borderwidth 1 -command "::gui_cata::grab 6" -text "Grab"
                                   pack    $img.v6.grab -in $img.v6 -side left -anchor e -expand 0 
                                   entry $img.v6.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(6)
                                   pack  $img.v6.ad -in $img.v6 -side left -padx 3 -pady 3 -anchor w
                                    button $img.v6.clean  -borderwidth 1 -image icon_clean -command {
                                       set ::gui_cata::man_xy_star(6) ""
                                       set ::gui_cata::man_ad_star(6) ""
                                    }
                                    pack   $img.v6.clean -in $img.v6 -side left -anchor e -expand 0 

                                frame $img.v7 -borderwidth 1 -cursor arrow -relief groove
                                pack $img.v7  -in $img  -side top 
                                   entry $img.v7.xy -relief sunken -textvariable ::gui_cata::man_xy_star(7)
                                   pack  $img.v7.xy -in $img.v7 -side left -padx 3 -pady 3 -anchor w
                                   button  $img.v7.grab  -borderwidth 1 -command "::gui_cata::grab 7" -text "Grab"
                                   pack    $img.v7.grab -in $img.v7 -side left -anchor e -expand 0 
                                   entry $img.v7.ad -relief sunken  -textvariable ::gui_cata::man_ad_star(7)
                                   pack  $img.v7.ad -in $img.v7 -side left -padx 3 -pady 3 -anchor w
                                    button $img.v7.clean  -borderwidth 1 -image icon_clean -command {
                                       set ::gui_cata::man_xy_star(7) ""
                                       set ::gui_cata::man_ad_star(7) ""
                                    }
                                    pack   $img.v7.clean -in $img.v7 -side left -anchor e -expand 0 


                frame $manuel.entr.buttonsvisu -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr.buttonsvisu  -in $manuel.entr  -side top 
                
                     button  $manuel.entr.buttonsvisu.clean  -borderwidth 1  \
                         -command "cleanmark" -text "Clean"
                     pack    $manuel.entr.buttonsvisu.clean -in $manuel.entr.buttonsvisu -side left -anchor e -expand 0 
                     button  $manuel.entr.buttonsvisu.voir  -borderwidth 1  \
                         -command "::gui_cata::manual_view" -text "Voir XY"
                     pack    $manuel.entr.buttonsvisu.voir -in $manuel.entr.buttonsvisu -side left -anchor e -expand 0 
                     button  $manuel.entr.buttonsvisu.fit  -borderwidth 1  \
                         -command "::gui_cata::manual_fit" -text "Fit XY"
                     pack    $manuel.entr.buttonsvisu.fit -in $manuel.entr.buttonsvisu -side left -anchor e -expand 0 

                frame $manuel.entr.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr.buttons  -in $manuel.entr  -side top 
                
                     button  $manuel.entr.buttons.efface  -borderwidth 1  \
                         -command "::gui_cata::manual_clean" -text "Effacer tout"
                     pack    $manuel.entr.buttons.efface -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     button  $manuel.entr.buttons.creerwcs  -borderwidth 1  \
                         -command "::gui_cata::manual_create_wcs" -text "Creer WCS"
                     pack    $manuel.entr.buttons.creerwcs -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     set ::gui_cata::gui_creercata [button  $manuel.entr.buttons.creercata -borderwidth 1  \
                         -command "::gui_cata::manual_create_cata" -text "Creer Cata" -state disabled]
                     pack    $manuel.entr.buttons.creercata -in $manuel.entr.buttons -side left -anchor e -expand 0 


                frame $manuel.entr.buttonsins -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr.buttonsins  -in $manuel.entr  -side top 
                
                     set ::gui_cata::gui_enrimg [button  $manuel.entr.buttonsins.enrimg  -borderwidth 1  \
                         -command "::gui_cata::manual_insert_img" -text "Insertion Image" -state disabled]
                     pack    $manuel.entr.buttonsins.enrimg -in $manuel.entr.buttonsins -side left -anchor e -expand 0 

        #--- Cree un frame pour afficher l onglet develop
        set develop [frame $f9.develop -borderwidth 0 -cursor arrow -relief groove]
        pack $develop -in $f9 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                frame $develop.entr -borderwidth 0 -cursor arrow -relief groove
                pack $develop.entr  -in $develop  -side top 
                

                     set affsource [frame $develop.entr.affsource -borderwidth 0 -cursor arrow  -borderwidth 0]
                     pack $affsource -in $develop.entr -side top 

                          button  $affsource.lab  -borderwidth 1 -command "::gui_cata::getsource" -text "Obtenir les sources d'une fenetre"
                          pack   $affsource.lab   -in $affsource -side top -padx 3 -pady 3 -anchor c






        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set ::gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::fermer"]
             pack $boutonpied.fermer -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

            set ::gui_cata::gui_info [label $boutonpied.info -text ""]
            pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
            set ::gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
            pack $::gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


   }
   


# Fin Classe
}

