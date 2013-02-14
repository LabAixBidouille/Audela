#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_cata_creation_gui.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_cata_creation_gui.tcl
# Description    : GUI de Creation des fichiers catalogues 
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: bdi_cata_creation_gui.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace cata_creation_gui
#
#--------------------------------------------------


namespace eval cata_creation_gui {



# Anciennement ::gui_cata::inittoconf

   #
   # initToConf
   # Initialisation des variables de configuration
   #
   proc ::cata_creation_gui::inittoconf {  } {

      global bddconf, conf

#/srv/astrodata/Catalog/USNOA2/
#/srv/astrodata/Catalog/TYCHO-2/
#/srv/astrodata/Catalog/UCAC2/
#/srv/astrodata/Catalog/UCAC3/
#/srv/astrodata/Catalog/NOMAD1/

      # Affichage des ronds dans l image
      ::gui_cata::inittoconf

      # Mesure des PSF
      ::psf_tools::inittoconf
      


      # Check button Use
      if {! [info exists ::tools_cata::use_usnoa2] } {
         if {[info exists conf(bddimages,cata,use_usnoa2)]} {
            set ::tools_cata::use_usnoa2 $conf(bddimages,cata,use_usnoa2)
         } else {
            set ::tools_cata::use_usnoa2 1
         }
      }
      if {! [info exists ::tools_cata::use_ucac2] } {
         if {[info exists conf(bddimages,cata,use_ucac2)]} {
            set ::tools_cata::use_ucac2 $conf(bddimages,cata,use_ucac2)
         } else {
            set ::tools_cata::use_ucac2 0
         }
      }
      if {! [info exists ::tools_cata::use_ucac3] } {
         if {[info exists conf(bddimages,cata,use_ucac3)]} {
            set ::tools_cata::use_ucac3 $conf(bddimages,cata,use_ucac3)
         } else {
            set ::tools_cata::use_ucac3 0
         }
      }
      if {! [info exists ::tools_cata::use_ucac4] } {
         if {[info exists conf(bddimages,cata,use_ucac4)]} {
            set ::tools_cata::use_ucac4 $conf(bddimages,cata,use_ucac4)
         } else {
            set ::tools_cata::use_ucac4 0
         }
      }
      if {! [info exists ::tools_cata::use_ppmx] } {
         if {[info exists conf(bddimages,cata,use_ppmx)]} {
            set ::tools_cata::use_ppmx $conf(bddimages,cata,use_ppmx)
         } else {
            set ::tools_cata::use_ppmx 0
         }
      }
      if {! [info exists ::tools_cata::use_ppmxl] } {
         if {[info exists conf(bddimages,cata,use_ppmxl)]} {
            set ::tools_cata::use_ppmxl $conf(bddimages,cata,use_ppmxl)
         } else {
            set ::tools_cata::use_ppmxl 0
         }
      }
      if {! [info exists ::tools_cata::use_tycho2] } {
         if {[info exists conf(bddimages,cata,use_tycho2)]} {
            set ::tools_cata::use_tycho2 $conf(bddimages,cata,use_tycho2)
         } else {
            set ::tools_cata::use_tycho2 0
         }
      }
      if {! [info exists ::tools_cata::use_nomad1] } {
         if {[info exists conf(bddimages,cata,use_nomad1)]} {
            set ::tools_cata::use_nomad1 $conf(bddimages,cata,use_nomad1)
         } else {
            set ::tools_cata::use_nomad1 0
         }
      }
      if {! [info exists ::tools_cata::use_skybot] } {
         if {[info exists conf(bddimages,cata,use_skybot)]} {
            set ::tools_cata::use_skybot $conf(bddimages,cata,use_skybot)
         } else {
            set ::tools_cata::use_skybot 0
         }
      }

      # Uncosmic or not
      if {! [info exists ::gui_cata::use_uncosmic] } {
         if {[info exists conf(bddimages,cata,use_uncosmic)]} {
            set ::gui_cata::use_uncosmic $conf(bddimages,cata,use_uncosmic)
         } else {
            set ::gui_cata::use_uncosmic 1
         }
      }
      if {! [info exists ::tools_cdl::uncosm_param1] } {
         if {[info exists conf(bddimages,cata,uncosm_param1)]} {
            set ::tools_cdl::uncosm_param1 $conf(bddimages,cata,uncosm_param1)
         } else {
            set ::tools_cdl::uncosm_param1 0.8
         }
      }
      if {! [info exists ::tools_cdl::uncosm_param2] } {
         if {[info exists conf(bddimages,cata,uncosm_param2)]} {
            set ::tools_cdl::uncosm_param2 $conf(bddimages,cata,uncosm_param2)
         } else {
            set ::tools_cdl::uncosm_param2 100
         }
      }

      # Repertoires 
      if {! [info exists ::tools_cata::catalog_usnoa2] } {
         if {[info exists conf(bddimages,catfolder,usnoa2)]} {
            set ::tools_cata::catalog_usnoa2 $conf(bddimages,catfolder,usnoa2)
         } else {
            set ::tools_cata::catalog_usnoa2 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ucac2] } {
         if {[info exists conf(bddimages,catfolder,ucac2)]} {
            set ::tools_cata::catalog_ucac2 $conf(bddimages,catfolder,ucac2)
         } else {
            set ::tools_cata::catalog_ucac2 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ucac3] } {
         if {[info exists conf(bddimages,catfolder,ucac3)]} {
            set ::tools_cata::catalog_ucac3 $conf(bddimages,catfolder,ucac3)
         } else {
            set ::tools_cata::catalog_ucac3 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ucac4] } {
         if {[info exists conf(bddimages,catfolder,ucac4)]} {
            set ::tools_cata::catalog_ucac4 $conf(bddimages,catfolder,ucac4)
         } else {
            set ::tools_cata::catalog_ucac4 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ppmx] } {
         if {[info exists conf(bddimages,catfolder,ppmx)]} {
            set ::tools_cata::catalog_ppmx $conf(bddimages,catfolder,ppmx)
         } else {
            set ::tools_cata::catalog_ppmx ""
         }
      }
      if {! [info exists ::tools_cata::catalog_ppmxl] } {
         if {[info exists conf(bddimages,catfolder,ppmxl)]} {
            set ::tools_cata::catalog_ppmxl $conf(bddimages,catfolder,ppmxl)
         } else {
            set ::tools_cata::catalog_ppmxl ""
         }
      }
      if {! [info exists ::tools_cata::catalog_tycho2] } {
         if {[info exists conf(bddimages,catfolder,tycho2)]} {
            set ::tools_cata::catalog_tycho2 $conf(bddimages,catfolder,tycho2)
         } else {
            set ::tools_cata::catalog_tycho2 ""
         }
      }
      if {! [info exists ::tools_cata::catalog_nomad1] } {
         if {[info exists conf(bddimages,catfolder,nomad1)]} {
            set ::tools_cata::catalog_nomad1 $conf(bddimages,catfolder,nomad1)
         } else {
            set ::tools_cata::catalog_nomad1 ""
         }
      }


      # Autres utilitaires
      if {! [info exists ::tools_cata::keep_radec] } {
         if {[info exists conf(bddimages,cata,keep_radec)]} {
            set ::tools_cata::keep_radec $conf(bddimages,cata,keep_radec)
         } else {
            set ::tools_cata::keep_radec 1
         }
      }
      if {! [info exists ::tools_cata::create_cata] } {
         if {[info exists conf(bddimages,cata,create_cata)]} {
            set ::tools_cata::create_cata $conf(bddimages,cata,create_cata)
         } else {
            set ::tools_cata::create_cata 1
         }
      }
      if {! [info exists ::tools_cata::delpv] } {
         if {[info exists conf(bddimages,cata,delpv)]} {
            set ::tools_cata::delpv $conf(bddimages,cata,delpv)
         } else {
            set ::tools_cata::delpv 1
         }
      }
      if {! [info exists ::tools_cata::boucle] } {
         if {[info exists conf(bddimages,cata,boucle)]} {
            set ::tools_cata::boucle $conf(bddimages,cata,boucle)
         } else {
            set ::tools_cata::boucle 0
         }
      }
      if {! [info exists ::tools_cata::deuxpasses] } {
         if {[info exists conf(bddimages,cata,deuxpasses)]} {
            set ::tools_cata::deuxpasses $conf(bddimages,cata,deuxpasses)
         } else {
            set ::tools_cata::deuxpasses 1
         }
      }
      if {! [info exists ::tools_cata::limit_nbstars_accepted] } {
         if {[info exists conf(bddimages,cata,limit_nbstars_accepted)]} {
            set ::tools_cata::limit_nbstars_accepted $conf(bddimages,cata,limit_nbstars_accepted)
         } else {
            set ::tools_cata::limit_nbstars_accepted 5
         }
      }
      if {! [info exists ::tools_cata::log] } {
         if {[info exists conf(bddimages,cata,log)]} {
            set ::tools_cata::log $conf(bddimages,cata,log)
         } else {
            set ::tools_cata::log 0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_pos_star] } {
         if {[info exists conf(bddimages,cata,treshold_ident_pos_star)]} {
            set ::tools_cata::treshold_ident_pos_star $conf(bddimages,cata,treshold_ident_pos_star)
         } else {
            set ::tools_cata::treshold_ident_pos_star 30.0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_mag_star] } {
         if {[info exists conf(bddimages,cata,treshold_ident_mag_star)]} {
            set ::tools_cata::treshold_ident_mag_star $conf(bddimages,cata,treshold_ident_mag_star)
         } else {
            set ::tools_cata::treshold_ident_mag_star -30.0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_pos_ast] } {
         if {[info exists conf(bddimages,cata,treshold_ident_pos_ast)]} {
            set ::tools_cata::treshold_ident_pos_ast $conf(bddimages,cata,treshold_ident_pos_ast)
         } else {
            set ::tools_cata::treshold_ident_pos_ast 10.0
         }
      }
      if {! [info exists ::tools_cata::treshold_ident_mag_ast] } {
         if {[info exists conf(bddimages,cata,treshold_ident_mag_ast)]} {
            set ::tools_cata::treshold_ident_mag_ast $conf(bddimages,cata,treshold_ident_mag_ast)
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



   }

















# Anciennement ::gui_cata::setval
   proc ::cata_creation_gui::setval { } {

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















# Anciennement ::gui_cata::resetcenter
   proc ::cata_creation_gui::resetcenter { } {

      set ::tools_cata::ra  $::tools_cata::ra_save
      set ::tools_cata::dec $::tools_cata::dec_save
      gren_info "RESET CENTER : $::tools_cata::ra $::tools_cata::dec\n"
   
   }



















# Anciennement ::gui_cata::fermer

   proc ::cata_creation_gui::fermer { } {

      global conf
      global action_label


      # Affichage des ronds dans l image
      ::gui_cata::closetoconf
      # Mesure des PSF
      ::psf_tools::closetoconf

      # Repertoires 
      set conf(bddimages,catfolder,usnoa2) $::tools_cata::catalog_usnoa2 
      set conf(bddimages,catfolder,ucac2)  $::tools_cata::catalog_ucac2  
      set conf(bddimages,catfolder,ucac3)  $::tools_cata::catalog_ucac3  
      set conf(bddimages,catfolder,ucac4)  $::tools_cata::catalog_ucac4  
      set conf(bddimages,catfolder,ppmx)   $::tools_cata::catalog_ppmx  
      set conf(bddimages,catfolder,ppmxl)  $::tools_cata::catalog_ppmxl
      set conf(bddimages,catfolder,tycho2) $::tools_cata::catalog_tycho2 
      set conf(bddimages,catfolder,nomad1) $::tools_cata::catalog_nomad1 

      # Check button Use
      set conf(bddimages,cata,use_usnoa2) $::tools_cata::use_usnoa2
      set conf(bddimages,cata,use_ucac2)  $::tools_cata::use_ucac2
      set conf(bddimages,cata,use_ucac3)  $::tools_cata::use_ucac3
      set conf(bddimages,cata,use_ucac4)  $::tools_cata::use_ucac4
      set conf(bddimages,cata,use_ppmx)   $::tools_cata::use_ppmx
      set conf(bddimages,cata,use_ppmxl)  $::tools_cata::use_ppmxl
      set conf(bddimages,cata,use_tycho2) $::tools_cata::use_tycho2
      set conf(bddimages,cata,use_nomad1) $::tools_cata::use_nomad1
      set conf(bddimages,cata,use_skybot) $::tools_cata::use_skybot
            
      # Uncosmic or not!
      set conf(bddimages,cata,use_uncosmic) $::gui_cata::use_uncosmic
      set conf(bddimages,cata,uncosm_param1) $::tools_cdl::uncosm_param1
      set conf(bddimages,cata,uncosm_param2) $::tools_cdl::uncosm_param2

      # Autres utilitaires
      set conf(bddimages,cata,keep_radec)              $::tools_cata::keep_radec
      set conf(bddimages,cata,create_cata)             $::tools_cata::create_cata
      set conf(bddimages,cata,delpv)                   $::tools_cata::delpv
      set conf(bddimages,cata,boucle)                  $::tools_cata::boucle
      set conf(bddimages,cata,deuxpasses)              $::tools_cata::deuxpasses
      set conf(bddimages,cata,limit_nbstars_accepted)  $::tools_cata::limit_nbstars_accepted
      set conf(bddimages,cata,log)                     $::tools_cata::log
      set conf(bddimages,cata,treshold_ident_pos_star) $::tools_cata::treshold_ident_pos_star
      set conf(bddimages,cata,treshold_ident_mag_star) $::tools_cata::treshold_ident_mag_star
      set conf(bddimages,cata,treshold_ident_pos_ast)  $::tools_cata::treshold_ident_pos_ast
      set conf(bddimages,cata,treshold_ident_mag_ast)  $::tools_cata::treshold_ident_mag_ast


      destroy $::cata_creation_gui::fen
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark
   }
















# Anciennement ::gui_cata::get_cata

   proc ::cata_creation_gui::get_cata { } {

         $::gui_cata::gui_create configure -state disabled
         $::gui_cata::gui_fermer configure -state disabled

         if { $::tools_cata::boucle == 1 } {

            ::cata_creation_gui::get_all_cata

         }  else {
            cleanmark
            if {[::cata_creation_gui::get_one_wcs] == true} {
            
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













# Anciennement ::gui_cata::get_all_cata

   proc ::cata_creation_gui::get_all_cata { } {

      cleanmark
      while {1==1} {
         if { $::tools_cata::boucle == 0 } {
            break
         }
         if {[::cata_creation_gui::get_one_wcs] == true} {
             
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
         ::cata_creation_gui::next
      }

   }










# Anciennement ::gui_cata::get_one_wcs

   proc ::cata_creation_gui::get_one_wcs { } {

         set tabkey        [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set date          [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs" ] 1] ]
         set bddimages_wcs [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
         set idbddimg      [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
         set filename      [::bddimages_liste::lget $::tools_cata::current_image filename   ]
         set dirfilename   [::bddimages_liste::lget $::tools_cata::current_image dirfilename]

         set err [catch {::tools_cata::get_wcs} msg]
         
         if {$err == 0 } {
            set newimg [::bddimages_liste_gui::file_to_img $filename $dirfilename]
            
            set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] [expr $::tools_cata::id_current_image-1] $newimg]
            
            set idbddimg      [::bddimages_liste::lget $newimg idbddimg]
            set tabkey        [::bddimages_liste::lget $newimg "tabkey"]
            set bddimages_wcs [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]

            set ::gui_cata::color_wcs $::gui_cata::color_button_good

            set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
            set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
            set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
            set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
            set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
            set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
            set ::tools_cata::crota     [lindex [::bddimages_liste::lget $tabkey crota1     ] 1]

            set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
            set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
            set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
            set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
            set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
            
            return true

         } else {
            ::console::affiche_erreur "GET_WCS ERROR: $msg  idbddimg : $idbddimg   filename : $filename\n"
            set ::gui_cata::color_wcs $::gui_cata::color_button_bad
            set ::tools_cata::boucle 0
            return false
         }
   }


















# Anciennement ::gui_cata::sendImageAndTable

   proc ::cata_creation_gui::sendImageAndTable { } {

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
















# Anciennement ::gui_cata::set_aladin_script_params

   proc ::cata_creation_gui::set_aladin_script_params { } {
   
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
      set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

   }


















# Anciennement ::gui_cata::sendAladinScript

   proc ::cata_creation_gui::sendAladinScript { } {

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




















# Anciennement ::gui_cata::skybotResolver

   proc ::cata_creation_gui::skybotResolver { } {

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
















# Anciennement ::gui_cata::setCenterFromRADEC
   
   proc ::cata_creation_gui::setCenterFromRADEC { } {

      set rd [regexp -inline -all -- {\S+} $::tools_cata::coord]
      set ra [lindex $rd 0]
      set dec [lindex $rd 1]
      set ::tools_cata::ra  $ra
      set ::tools_cata::dec $dec
      gren_info "SET CENTER FROM RA,DEC: $::tools_cata::ra $::tools_cata::dec\n"

   }

   














# Anciennement ::gui_cata::watch_info

   proc ::cata_creation_gui::watch_info { }  {

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

















# Anciennement ::gui_cata::watch_tabkey

   proc ::cata_creation_gui::watch_tabkey { } {

      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

      set cpt 0
      foreach v $tabkey {
         gren_info "v = $v\n"
         incr cpt
         #if {$cpt > 12 } {break}
      }

   }
















# Anciennement ::gui_cata::watch_buffer_header

   proc ::cata_creation_gui::watch_buffer_header { } {

      set cpt 0
      set list_keys [buf$::audace(bufNo) getkwds]
      foreach key $list_keys {
         if {$key==""} {continue}
         gren_info "$key = [buf$::audace(bufNo) getkwd $key]\n" 
         incr cpt
         #if {$cpt > 12 } {break}
      }
    }














# Anciennement ::gui_cata::charge_current_image

   proc ::cata_creation_gui::charge_current_image { } {

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
         set ::tools_cata::crota     [lindex [::bddimages_liste::lget $tabkey crota1     ] 1]
         set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]

         set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
         set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
         set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
         set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
         set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

         set xcent [expr $naxis1/2.0]
         set ycent [expr $naxis2/2.0]

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



      

















# Anciennement ::gui_cata::charge_list

   proc ::cata_creation_gui::charge_list { img_list } {

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

      set ::tools_cata::ra       [lindex [::bddimages_liste::lget $tabkey ra      ] 1]
      set ::tools_cata::dec      [lindex [::bddimages_liste::lget $tabkey dec     ] 1]
      set ::tools_cata::crota    [lindex [::bddimages_liste::lget $tabkey crota1  ] 1]
      set ::tools_cata::pixsize1 [lindex [::bddimages_liste::lget $tabkey pixsize1] 1]
      set ::tools_cata::pixsize2 [lindex [::bddimages_liste::lget $tabkey pixsize2] 1]
      set ::tools_cata::foclen   [lindex [::bddimages_liste::lget $tabkey foclen  ] 1]
      set ::tools_cata::exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]

      set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
      set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

      set xcent [expr $naxis1/2.0]
      set ycent [expr $naxis2/2.0]

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
      set ::tools_cata::nb_ucac4   0
      set ::tools_cata::nb_ppmx    0
      set ::tools_cata::nb_ppmxl   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0
      affich_un_rond_xy $xcent $ycent red 2 2
      ::gui_cata::affiche_current_image
      ::gui_cata::affiche_cata
   }


















# Anciennement ::gui_cata::get_confsex

   proc ::cata_creation_gui::get_confsex { } {

      global audace

         
         set fileconf [ file join $audace(rep_plugin) tool bddimages config config.sex ]
         
         set chan [open $fileconf r]
         while {[gets $chan line] >= 0} {
            $::cata_creation_gui::fen.frm_creation_cata.onglets.nb.f5.confsex.file insert end "$line\n"
         }
         close $chan

   }














# Anciennement ::gui_cata::set_confsex

   proc ::cata_creation_gui::set_confsex { } {

      global audace

      set r  [$::cata_creation_gui::fen.frm_creation_cata.onglets.nb.f5.confsex.file get 1.0 end]
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
















# Anciennement ::gui_cata::test_confsex

   proc ::cata_creation_gui::test_confsex { } {

      cleanmark
      ::cata_creation_gui::set_confsex 

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














# Anciennement ::gui_cata::affich_catapcat

   proc ::cata_creation_gui::affich_catapcat {  } {
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
   
   
   
   
   




   








# Anciennement ::gui_cata::grab

   proc ::cata_creation_gui::grab { i } {

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
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
# Anciennement ::gui_cata::manual_clean 
   
   proc ::cata_creation_gui::manual_clean {  } {

      for {set i 1} {$i<=7} {incr i} {
         set ::gui_cata::man_xy_star($i) ""
         set ::gui_cata::man_ad_star($i) ""      
      }

   }



















# Anciennement ::gui_cata::test_manual_create

   proc ::cata_creation_gui::test_manual_create {  } {

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



















# Anciennement ::gui_cata::manual_view

   proc ::cata_creation_gui::manual_view {  } {

      for {set i 1} {$i<=7} {incr i} {
         if {$::gui_cata::man_xy_star($i) != "" && $::gui_cata::man_ad_star($i) != ""} {
            set x [split $::gui_cata::man_xy_star($i) " "]
            set xsm [lindex $x 0]
            set ysm [lindex $x 1]
            affich_un_rond_xy  $xsm $ysm "blue" 5 2
         }
      }
       

   }


















# Anciennement ::gui_cata::manual_fit

   proc ::cata_creation_gui::manual_fit {  } {


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
      ::cata_creation_gui::manual_view
   }
































# Anciennement ::gui_cata::manual_create_wcs

   proc ::cata_creation_gui::manual_create_wcs {  } {

      global bddconf

      #::gui_cata::test_manual_create

      ::tools_cata::push_img_list
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
      set fieldimg [list "IMG" [list "ra" "dec" "err_pos" "mag" "err_mag"] [::tools_cata::get_img_fields] ]

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
            set b [::tools_cata::get_img_null]
            set b [lreplace $b 2 3 $xsm $ysm]
            set b [lreplace $b 8 9 $ra $dec]
            lappend sources [list [list "IMG" [list $ra $dec 0 0 0] $b ] ]
         }
      }
      set fields  [list $fieldimg]
      set listsources [list $fields $sources ]
      #gren_info "listsources : $listsources\n"
      
      #gren_info "fields : $fields\n"
      #gren_info "sources : $sources\n"
      
      gren_info "     Mesure des PSF\n"
      ::psf_gui::psf_listsources_no_auto listsources $::tools_astrometry::treshold $::tools_astrometry::delta
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

      # Nouvel appel
      # ::priam::create_file_oldformat  tag nb sent_img sent_list_source
      # ::priam::create_file_oldformat $tag $::tools_cata::nb_img_list current_image ::gui_cata::cata_list($id_current_image)
      # ::priam::create_file_oldformat "new" 1 ::tools_cata::current_image listsources

      #set err [catch {::priam::create_file_oldformat "new" 1 $::tools_cata::current_image "" "IMG" } msg ]
      gren_info "**listsources : $listsources\n"
      set id 0
      set ls [lindex $listsources 1]
      foreach s $ls {
         set x  [lsearch -index 0 $s "ASTROID"]
         if {$x>=0} {
            set a [lindex $s $x]
            set b [lindex $a 2]
            set b [lreplace $b 25 25 "R"]
            set b [lreplace $b 27 27 "IMG"]
            set a [lreplace $a 2 2 $b] 
            set s [lreplace $s $x $x $a]
            set ls [lreplace $ls $id $id $s]
         }
         incr id
      }
      set listsources [lreplace $listsources 1 1 $ls]
      gren_info "**listsources : $listsources\n"

      set err [catch {::priam::create_file_oldformat "new" 1 ::tools_cata::current_image listsources } msg ]

      if {$err} {
         ::console::affiche_erreur "WCS Impossible :($err) $msg \n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::tools_cata::pop_img_list
         return
      }

      #gren_info "current_image : $::tools_cata::current_image\n"

      set ::tools_cata::img_list [list $::tools_cata::current_image]


      # Nouvel appel
      # set ::tools_astrometry::last_results_file [::priam::launch_priam]
      # gren_info "new file : <$::tools_astrometry::last_results_file>\n"
      # ::tools_astrometry::extract_priam_result $::tools_astrometry::last_results_file


      set err [catch {

          set ::tools_astrometry::last_results_file [::priam::launch_priam]
          gren_info "new file : <$::tools_astrometry::last_results_file>\n"
          ::tools_astrometry::extract_priam_result $::tools_astrometry::last_results_file
      
      } msg ]
      
      if {$err} {
         ::console::affiche_erreur "WCS Impossible :($err)  $msg \n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::tools_cata::pop_img_list
         return
      }

      set ::tools_cata::current_listsources $::gui_cata::cata_list(1)
      ::manage_source::imprim_3_sources $::tools_cata::current_listsources

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
         ::tools_cata::pop_img_list
         return
      }

      ::tools_cata::pop_img_list

      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]

      #gren_info "current_image : $::tools_cata::current_image\n"

      set ::gui_cata::color_wcs $::gui_cata::color_button_good
      $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
      $::gui_cata::gui_enrimg configure -state normal
      $::gui_cata::gui_creercata configure -state normal
      
   }





















# Anciennement ::gui_cata::manual_create_cata

   proc ::cata_creation_gui::manual_create_cata {  } {

      ::tools_cata::push_img_list
      set ::tools_cata::create_cata 0
      $::gui_cata::gui_enrimg configure -state disabled

      # Lancement Sextractor
      set ext $::conf(extension,defaut)
      set mypath "."
      set sky0 dummy0
      set sky dummy
      catch {buf$::audace(bufNo) delkwd CATASTAR}
      buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
      createFileConfigSextractor
      buf$::audace(bufNo) save [ file join ${mypath} ${sky}$ext ]
      ::cata_creation_gui::set_confsex
      sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"

      # Extraction Resultat Sextractor et Creation de la liste
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
      set ::tools_cata::current_listsources [::tools_sources::set_common_fields $::tools_cata::current_listsources IMG { ra dec 5.0 calib_mag calib_mag_ss1}]
      #::manage_source::imprim_3_sources $::tools_cata::current_listsources

      # Modification de la liste
      set tabkey  [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1 ] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2 ] 1]
      set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
      set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
      set xcent   [expr $naxis1/2.0]
      set ycent   [expr $naxis2/2.0]

      set a       [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
      set ra      [lindex $a 0]
      set dec     [lindex $a 1]
      set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

      #set listsources [::tools_sources::set_common_fields $listsources USNOA2 { ra_deg dec_deg 5.0 magR 0.5 }]
      #set ::tools_cata::current_listsources [::tools_sources::set_common_fields $::tools_cata::current_listsources USNOA2 { ra_deg dec_deg 5.0 magR 0.5 }]

      # 1ere identification sur l USNOA2

      #   gren_info "csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius\n"
      #   return
      #   set usnoa2 [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius]
      #   set usnoa2 [::tools_sources::set_common_fields $usnoa2 USNOA2 { ra_deg dec_deg 5.0 magR 0.5 }]
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
         ::tools_cata::pop_img_list
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
      ::tools_cata::pop_img_list
   }





















# Anciennement ::gui_cata::manual_insert_img

   proc ::cata_creation_gui::manual_insert_img {  } {
   
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














# Anciennement ::gui_cata::getsource

   proc ::cata_creation_gui::getsource {  } {

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect ==""} {
         tk_messageBox -message "Veuillez selectionner un carre dans l'image" -type ok
         return
      }
      set l [::manage_source::extract_sources_by_array $rect $::tools_cata::current_listsources]
      ::manage_source::imprim_all_sources $l
   }


   proc ::cata_creation_gui::develop { tag } {

      if {$tag == 1 } {

         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         if {$err>0 || $rect ==""} {
            tk_messageBox -message "Veuillez selectionner un carre dans l'image" -type ok
            return
         }
         set l [::manage_source::extract_sources_by_array $rect $::tools_cata::current_listsources]
         ::manage_source::imprim_all_sources $l
         return
      }

      if {$tag == 2 } {
         ::manage_source::imprim_all_sources $::tools_cata::current_listsources
         return
      }

      if {$tag == 3 } {
         ::manage_source::imprim_3_sources $::tools_cata::current_listsources
         return
      }

   }







# Anciennement ::gui_cata::next

   proc ::cata_creation_gui::next { } {

         if {$::tools_cata::id_current_image < $::tools_cata::nb_img_list} {
            incr ::tools_cata::id_current_image
            catch {unset ::tools_cata::current_listsources}
            ::cata_creation_gui::charge_current_image
         }
   }













# Anciennement ::gui_cata::back

   proc ::cata_creation_gui::back { } {

         if {$::tools_cata::id_current_image > 1 } {
            incr ::tools_cata::id_current_image -1
            catch {unset ::tools_cata::current_listsources}
            ::cata_creation_gui::charge_current_image
         }
   }












   proc ::cata_creation_gui::cata_psf { } {
   
      set psf $::cata_creation_gui::fen.frm_creation_cata.onglets.nb.f6.psf
      gren_info "use_psf = $::psf_tools::use_psf \n"
      if {$::psf_tools::use_psf} {
         gren_info "pass\n"
         $psf.opts.saturation.val configure -state normal
         $psf.opts.delta.val      configure -state normal
         $psf.methglobale.check   configure -state normal
      } else {
         $psf.opts.saturation.val configure -state disabled
         $psf.opts.delta.val      configure -state disabled
         $psf.methglobale.check   configure -state disabled
      }
   
   }


   proc ::cata_creation_gui::psf_auto { } {

      set psf $::cata_creation_gui::fen.frm_creation_cata.onglets.nb.f6.psf
      gren_info "use_global = $::psf_tools::use_global \n"
      if {$::psf_tools::use_global} {
         gren_info "pass\n"
         $psf.opts2.threshold.val   configure -state normal
         $psf.opts2.limitradius.val configure -state normal
         $psf.opts.delta.val        configure -state disabled
      } else {
         $psf.opts2.threshold.val   configure -state disabled
         $psf.opts2.limitradius.val configure -state disabled
         $psf.opts.delta.val        configure -state normal
      }
   
   }










# Anciennement ::gui_cata::creation_cata
# Gui de creation des fichiers catalogues
# interface de gestion, creation de WCS
# gestion et test de sextractor/calibwcs
# astrometrie manuelle pour premier wcs
# interoperabilité avec skybot, aladin, dss
# mesure des photocentre
# traitement automatique d'un lot d images.

   proc ::cata_creation_gui::go { img_list } {

      global audace
      global bddconf

      ::cata_creation_gui::inittoconf
      ::cata_creation_gui::charge_list $img_list
      catch { 
         ::gui_cata::set_aladin_script_params
      }

      #--- Creation de la fenetre
      set ::cata_creation_gui::fen .new
      if { [winfo exists $::cata_creation_gui::fen] } {
         wm withdraw $::cata_creation_gui::fen
         wm deiconify $::cata_creation_gui::fen
         focus $::cata_creation_gui::fen
         return
      }
      toplevel $::cata_creation_gui::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::cata_creation_gui::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::cata_creation_gui::fen ] "+" ] 2 ]
      wm geometry $::cata_creation_gui::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::cata_creation_gui::fen 1 1
      wm title $::cata_creation_gui::fen "Creation du CATA"
      wm protocol $::cata_creation_gui::fen WM_DELETE_WINDOW "destroy $::cata_creation_gui::fen"

      set frm $::cata_creation_gui::fen.frm_creation_cata

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::cata_creation_gui::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame general
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


             set ::gui_cata::gui_back [button $actions.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::cata_creation_gui::back" -state $::gui_cata::stateback]
             pack $actions.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_next [button $actions.next -text "Next" -borderwidth 2 -takefocus 1 \
                -command "::cata_creation_gui::next" -state $::gui_cata::statenext]
             pack $actions.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_create [button $actions.go -text "Create" -borderwidth 2 -takefocus 1 \
                -command "::cata_creation_gui::get_cata" -state normal]
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
            $onglets.nb add $f6 -text "PSF"
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
  
        #--- Cree un frame pour afficher ucac4
        set ucac4 [frame $f1.ucac4 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac4 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac4.check -highlightthickness 0 -text "UCAC4" -variable ::tools_cata::use_ucac4
             pack $ucac4.check -in $ucac4 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac4.dir -relief sunken -textvariable ::tools_cata::catalog_ucac4 -width 30
             pack $ucac4.dir -in $ucac4 -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher ppmx
        set ppmx [frame $f1.ppmx -borderwidth 0 -cursor arrow -relief groove]
        pack $ppmx -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ppmx.check -highlightthickness 0 -text "PPMX" -variable ::tools_cata::use_ppmx -state disabled
             pack $ppmx.check -in $ppmx -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ppmx.dir -relief sunken -textvariable ::tools_cata::catalog_ppmx -width 30
             pack $ppmx.dir -in $ppmx -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher ppmxl
        set ppmxl [frame $f1.ppmxl -borderwidth 0 -cursor arrow -relief groove]
        pack $ppmxl -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ppmxl.check -highlightthickness 0 -text "PPMXL" -variable ::tools_cata::use_ppmxl -state disabled
             pack $ppmxl.check -in $ppmxl -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ppmxl.dir -relief sunken -textvariable ::tools_cata::catalog_ppmxl -width 30
             pack $ppmxl.dir -in $ppmxl -side right -pady 1 -anchor w

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
               button $setbut.setval -text "Set Center" -borderwidth 2 -takefocus 1 -command "::cata_creation_gui::setval"
               pack $setbut.setval -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
               #--- reset center
               button $setbut.resetval -text "Reset Center" -borderwidth 2 -takefocus 1 -command "::cata_creation_gui::resetcenter"
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
                button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac2 -command ""
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
                $ucac4.radius set $::gui_cata::size_ucac4_sav

           #--- Cree un frame pour afficher PPMX
           set ppmx [frame $count.ppmx -borderwidth 0 -cursor arrow -relief groove]
           pack $ppmx -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ppmx.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_ppmx -state normal  \
                      -command "::gui_cata::affiche_cata" \
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
                $ppmx.radius set $::gui_cata::size_ppmx_sav

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
                $ppmxl.radius set $::gui_cata::size_ppmxl_sav

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
                      -command "::gui_cata::affiche_cata" \
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
                $skybot.radius set $::gui_cata::size_skybot_sav

        #--- Cree un frame pour la conf Sextractor
        set confsex [frame $f5.confsex -borderwidth 0 -cursor arrow -relief groove]
        pack $confsex -in $f5 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                frame $confsex.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $confsex.buttons  -in $confsex  -side top -anchor e -expand 0 

                     button  $confsex.buttons.clean  -borderwidth 1  \
                         -command "cleanmark" -text "Clean"
                     pack    $confsex.buttons.clean  -side left -anchor e -expand 0 
                     button  $confsex.buttons.test  -borderwidth 1  \
                         -command "::cata_creation_gui::test_confsex" -text "Test"
                     pack    $confsex.buttons.test  -side left -anchor e -expand 0 
                     button  $confsex.buttons.save  -borderwidth 1  \
                         -command "::cata_creation_gui::set_confsex" -text "Save"
                     pack    $confsex.buttons.save  -side left -anchor e -expand 0 

                #--- Cree un label pour le titre
                text $confsex.file 
                pack $confsex.file -in $confsex -side top -padx 3 -pady 3 -anchor w 

                ::cata_creation_gui::get_confsex

        #--- Cree un frame pour la conf PSF
        set psf [frame $f6.psf -borderwidth 0 -cursor arrow -relief groove]
        pack $psf -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               #--- Creation du cata psf
               set creer [frame $psf.creer -borderwidth 1 -cursor arrow -relief groove]
               pack $creer -in $psf -side top -anchor w -expand 0 -fill x -pady 5
                  checkbutton $creer.check -highlightthickness 0 -text " Creer le cata psf" \
                        -variable ::psf_tools::use_psf -state normal -command "::cata_creation_gui::cata_psf"
                  pack $creer.check -in $creer -side left -padx 3 -pady 3 -anchor w 

               #--- Options de creation du cata Asttroid
               set opts [frame $psf.opts -borderwidth 1 -cursor arrow -relief sunken]
               pack $opts -in $psf  -side top -anchor e -expand 0 -fill x 
        
                  #--- Niveau de saturation (ADU)
                  set saturation [frame $opts.saturation]
                  pack $saturation -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $saturation.lab -text "Niveau de saturation (ADU)" -width 24 -anchor e
                       pack $saturation.lab -in $saturation -side left -padx 5 -pady 0 -anchor e
                       entry $saturation.val -relief sunken -textvariable ::psf_tools::psf_saturation -width 6
                       pack $saturation.val -in $saturation -side left -pady 1 -anchor w

                  #--- Delta
                  set delta [frame $opts.delta]
                  pack $delta -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $delta.lab -text "Delta (pixel)" -width 24 -anchor e
                       pack $delta.lab -in $delta -side left -padx 5 -pady 0 -anchor e
                       entry $delta.val -relief sunken -textvariable ::psf_tools::psf_delta -width 3
                       pack $delta.val -in $delta -side left -pady 1 -anchor w

               #--- Creation du cata psf
               set methglobale [frame $psf.methglobale -borderwidth 1 -cursor arrow -relief groove]
               pack $methglobale -in $psf -side top -anchor w -expand 0 -fill x -pady 5
                  checkbutton $methglobale.check -highlightthickness 0 -text "Mesure Automatique" \
                        -variable ::psf_tools::use_global -state normal \
                        -command "::cata_creation_gui::psf_auto"
                  pack $methglobale.check -in $methglobale -side left -padx 3 -pady 3 -anchor w 

               #--- Options de creation du cata Asttroid
               set opts [frame $psf.opts2 -borderwidth 1 -cursor arrow -relief sunken]
               pack $opts -in $psf  -side top -anchor e -expand 0 -fill x 
        
                  #--- Threshold
                  set threshold [frame $opts.threshold]
                  pack $threshold -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $threshold.lab -text "Threshold (pixel)" -width 24 -anchor e
                       pack  $threshold.lab -side left -padx 5 -pady 0 -anchor e
                       entry $threshold.val -relief sunken -textvariable ::psf_tools::psf_threshold -width 3
                       pack  $threshold.val -side left -pady 1 -anchor w

                  #--- Threshold
                  set limitradius [frame $opts.limitradius]
                  pack $limitradius -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                       label $limitradius.lab -text "Rayon max (pixel)" -width 24 -anchor e
                       pack  $limitradius.lab -side left -padx 5 -pady 0 -anchor e
                       entry $limitradius.val -relief sunken -textvariable ::psf_tools::psf_limitradius -width 3
                       pack  $limitradius.val -side left -pady 1 -anchor w

               if { $::psf_tools::use_psf == 0 } {
                  $saturation.val      configure -state disabled
                  $delta.val           configure -state disabled
                  $methglobale.check   configure -state disabled
                  $threshold.val       configure -state disabled
                  $limitradius.val     configure -state disabled
               } else {
                  if { $::psf_tools::use_global == 0 } {
                     $delta.val           configure -state normal
                     $threshold.val    configure -state disabled
                     $limitradius.val  configure -state disabled
                  } else {
                     $delta.val           configure -state disabled
                  }
               }
 
        #--- Cree un frame pour afficher les actions Interop
        set interop [frame $f7.interop -borderwidth 0 -cursor arrow -relief groove]
        pack $interop -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
  
           # Bouton pour envoyer les plans courants (image,table) vers Aladin
           set plan [frame $interop.plan -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
           pack $plan -in $interop -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
              label $plan.lab -text "Envoyer le plan vers "
              pack $plan.lab -in $plan -side left -padx 3 -pady 3
              button $plan.aladin -text "Aladin" -borderwidth 2 -takefocus 1 -command "::cata_creation_gui::sendImageAndTable" 
              pack $plan.aladin -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           # 
           set resolver [frame $interop.resolver -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
           pack $resolver -in $interop -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set l [frame $resolver.l -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $l -in $resolver -anchor s -side left -expand 0 -fill x -padx 10 -pady 5
                 label $l.date -justify right -text "Epoque (UTC) : "
                 pack $l.date -in $l -side top -padx 3 -pady 3
                 label $l.coord -justify right -text "Coordonnees (RA DEC) : "
                 pack $l.coord -in $l -side top -padx 3 -pady 3
                 label $l.radius -justify right -text "Rayon (arcmin) : "
                 pack $l.radius -in $l -side top -padx 3 -pady 3
                 label $l.uaicode -justify right -text "UAI Code : "
                 pack $l.uaicode -in $l -side top -padx 3 -pady 3
 
              set m [frame $resolver.m -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $m -in $resolver -anchor s -side left -expand 0 -fill x -padx 10 -pady 5
                 entry $m.date -relief sunken -width 26 -textvariable ::tools_cata::current_image_date
                 pack $m.date -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.coord -relief sunken -width 26 -textvariable ::tools_cata::coord
                 pack $m.coord -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.radius -relief sunken -width 26 -textvariable ::tools_cata::radius
                 pack $m.radius -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.uaicode -relief sunken -width 26 -textvariable ::tools_cata::uaicode
                 pack $m.uaicode -in $m -side top -padx 3 -pady 3 -anchor w

              set r [frame $resolver.r -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $r -in $resolver -anchor s -side left -expand 0 -fill x -padx 3 -pady 3
                 button $r.resolve -text "Resolve Sso" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 \
                        -command "::cata_creation_gui::skybotResolver"
                 pack $r.resolve -side top -anchor e -padx 3 -pady 1 -ipadx 2 -ipady 2 -expand 0
                 button $r.setcenter -text "Set Center" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 \
                        -command "::cata_creation_gui::setCenterFromRADEC"
                 pack $r.setcenter -side top -anchor e -padx 3 -pady 1 -ipadx 2 -ipady 2 -expand 0
                 button $r.aladin -text "Show in Aladin" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 \
                        -command "::cata_creation_gui::sendAladinScript" 
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
                                   button  $img.v1.grab  -borderwidth 1 -command "::cata_creation_gui::grab 1" -text "Grab"
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
                                   button  $img.v2.grab  -borderwidth 1 -command "::cata_creation_gui::grab 2" -text "Grab"
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
                                   button $img.v3.grab  -borderwidth 1 -command "::cata_creation_gui::grab 3" -text "Grab"
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
                                   button  $img.v4.grab  -borderwidth 1 -command "::cata_creation_gui::grab 4" -text "Grab"
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
                                   button  $img.v5.grab  -borderwidth 1 -command "::cata_creation_gui::grab 5" -text "Grab"
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
                                   button  $img.v6.grab  -borderwidth 1 -command "::cata_creation_gui::grab 6" -text "Grab"
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
                                   button  $img.v7.grab  -borderwidth 1 -command "::cata_creation_gui::grab 7" -text "Grab"
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
                         -command "::cata_creation_gui::manual_view" -text "Voir XY"
                     pack    $manuel.entr.buttonsvisu.voir -in $manuel.entr.buttonsvisu -side left -anchor e -expand 0 
                     button  $manuel.entr.buttonsvisu.fit  -borderwidth 1  \
                         -command "::cata_creation_gui::manual_fit" -text "Fit XY"
                     pack    $manuel.entr.buttonsvisu.fit -in $manuel.entr.buttonsvisu -side left -anchor e -expand 0 

                frame $manuel.entr.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr.buttons  -in $manuel.entr  -side top 
                
                     button  $manuel.entr.buttons.efface  -borderwidth 1  \
                         -command "::cata_creation_gui::manual_clean" -text "Effacer tout"
                     pack    $manuel.entr.buttons.efface -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     button  $manuel.entr.buttons.creerwcs  -borderwidth 1  \
                         -command "::cata_creation_gui::manual_create_wcs" -text "Creer WCS"
                     pack    $manuel.entr.buttons.creerwcs -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     set ::gui_cata::gui_creercata [button  $manuel.entr.buttons.creercata -borderwidth 1  \
                         -command "::cata_creation_gui::manual_create_cata" -text "Creer Cata" -state disabled]
                     pack    $manuel.entr.buttons.creercata -in $manuel.entr.buttons -side left -anchor e -expand 0 


                frame $manuel.entr.buttonsins -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr.buttonsins  -in $manuel.entr  -side top 
                
                     set ::gui_cata::gui_enrimg [button  $manuel.entr.buttonsins.enrimg  -borderwidth 1  \
                         -command "::cata_creation_gui::manual_insert_img" -text "Insertion Image" -state disabled]
                     pack    $manuel.entr.buttonsins.enrimg -in $manuel.entr.buttonsins -side left -anchor e -expand 0 

        #--- Cree un frame pour afficher l onglet develop
        set develop [frame $f9.develop -borderwidth 0 -cursor arrow -relief groove]
        pack $develop -in $f9 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                frame $develop.entr -borderwidth 0 -cursor arrow -relief groove
                pack $develop.entr  -in $develop  -side top 
                

                     set inf [frame $develop.entr.affsourcegrab -borderwidth 0 -cursor arrow  -borderwidth 0]
                     pack $inf -side top 

                          button $inf.lab -borderwidth 1 -command "::cata_creation_gui::getsource" -text "Voir dans la console : les sources d'une fenetre"
                          pack   $inf.lab -side top -padx 3 -pady 3 -anchor c

                     set inf [frame $develop.entr.affsourceall -borderwidth 0 -cursor arrow  -borderwidth 0]
                     pack $inf -side top 

                          button $inf.lab -borderwidth 1 -command "::cata_creation_gui::develop 2" -text "Voir dans la console : toutes les sources"
                          pack   $inf.lab -side top -padx 3 -pady 3 -anchor c

                     set inf [frame $develop.entr.affsource3 -borderwidth 0 -cursor arrow  -borderwidth 0]
                     pack $inf -side top 

                          button $inf.lab -borderwidth 1 -command "::cata_creation_gui::develop 3" -text "Voir dans la console : 3 sources"
                          pack   $inf.lab -side top -padx 3 -pady 3 -anchor c







        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set ::gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::cata_creation_gui::fermer"]
             pack $boutonpied.fermer -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

            set ::gui_cata::gui_info [label $boutonpied.info -text ""]
            pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
            set ::gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
            pack $::gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


   }








#- Fin du namespace -------------------------------------------------
}
