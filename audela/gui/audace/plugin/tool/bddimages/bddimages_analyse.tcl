#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_analyse.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_analyse.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_analyse.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bddimages_analyse
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_analyse.cap
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

namespace eval bddimages_analyse {

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





























   #
   # initToConf
   # Initialisation des variables de configuration
   #
   proc ::bddimages_analyse::inittoconf {  } {

      global bddconf, conf

      set ::analyse_tools::use_usnoa2  1
      set ::analyse_tools::use_ucac2   1
      set ::analyse_tools::use_ucac3   1
      set ::analyse_tools::use_nomad1  0
      set ::analyse_tools::use_tycho2  1

      if {! [info exists ::analyse_tools::catalog_usnoa2] } {
         if {[info exists conf(astrometry,catfolder,usnoa2)]} {
            set ::analyse_tools::catalog_usnoa2 $conf(astrometry,catfolder,usnoa2)
         } else {
            set ::analyse_tools::catalog_usnoa2 "/astrodata/Catalog/USNOA2/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_ucac2] } {
         if {[info exists conf(astrometry,catfolder,ucac2)]} {
            set ::analyse_tools::catalog_ucac2 $conf(astrometry,catfolder,ucac2)
         } else {
            set ::analyse_tools::catalog_ucac2 "/astrodata/Catalog/UCAC2/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_ucac3] } {
         if {[info exists conf(astrometry,catfolder,ucac3)]} {
            set ::analyse_tools::catalog_ucac3 $conf(astrometry,catfolder,ucac3)
         } else {
            set ::analyse_tools::catalog_ucac3 "/astrodata/Catalog/UCAC3/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_tycho2] } {
         if {[info exists conf(astrometry,catfolder,tycho2)]} {
            set ::analyse_tools::catalog_tycho2 $conf(astrometry,catfolder,tycho2)
         } else {
            set ::analyse_tools::catalog_tycho2 "/astrodata/Catalog/TYCHO-2/"
         }
      }
      if {! [info exists ::analyse_tools::catalog_nomad1] } {
         if {[info exists conf(astrometry,catfolder,nomad1)]} {
            set ::analyse_tools::catalog_nomad1 $conf(astrometry,catfolder,nomad1)
         } else {
            set ::analyse_tools::catalog_nomad1 "/astrodata/Catalog/NOMAD1/"
         }
      }

      set ::analyse_tools::use_skybot      1
      set ::analyse_tools::keep_radec      1
      set ::analyse_tools::create_cata     1
      set ::analyse_tools::delpv           1
      set ::analyse_tools::boucle          0
      set ::analyse_tools::deuxpasses      1
      set ::analyse_tools::limit_nbstars_accepted      5
      set ::analyse_tools::log             0

      set ::analyse_tools::size_img    1
      set ::analyse_tools::size_usnoa2 1
      set ::analyse_tools::size_ucac2  1
      set ::analyse_tools::size_ucac3  1
      set ::analyse_tools::size_nomad1 1
      set ::analyse_tools::size_tycho2 1
      set ::analyse_tools::size_skybot 1
      set ::analyse_tools::size_ovni   1

      set ::bddimages_analyse::gui_usnoa2 1
      set ::bddimages_analyse::gui_ucac2  1
      set ::bddimages_analyse::gui_ucac3  1
      set ::bddimages_analyse::gui_tycho2 1
      set ::bddimages_analyse::gui_skybot 1
      #--- Creation des variables de la boite de configuration si elles n'existent pas
      #if { ! [ info exists $bddconf(catalog_ucac2) ] } { set ::analyse_tools::catalog_ucac2 "" }
   }







   proc ::bddimages_analyse::setval { } {

      set ::analyse_tools::ra_save  $::analyse_tools::ra
      set ::analyse_tools::dec_save $::analyse_tools::dec

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect ==""} {
         gren_info "SET CENTER : $::analyse_tools::ra_save $::analyse_tools::dec_save\n"
         return
      }
      set xcent [format "%0.0f" [expr ([lindex $rect 0] + [lindex $rect 2])/2.]  ]   
      set ycent [format "%0.0f" [expr ([lindex $rect 1] + [lindex $rect 1])/2.]  ]   
      set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
      if {$err} {
         ::console::affiche_erreur "$err $msg\n"
         return
      }
      set ::analyse_tools::ra_save  [lindex $a 0]
      set ::analyse_tools::dec_save [lindex $a 1]
      gren_info "SET BOX : $::analyse_tools::ra_save $::analyse_tools::dec_save\n"
      
      

   }











   proc ::bddimages_analyse::fermer { } {

      global conf
      global action_label

      set conf(astrometry,catfolder,usnoa2) $::analyse_tools::catalog_usnoa2 
      set conf(astrometry,catfolder,ucac2)  $::analyse_tools::catalog_ucac2  
      set conf(astrometry,catfolder,ucac3)  $::analyse_tools::catalog_ucac3  
      set conf(astrometry,catfolder,tycho2) $::analyse_tools::catalog_tycho2 
      set conf(astrometry,catfolder,nomad1) $::analyse_tools::catalog_nomad1 

      destroy $::bddimages_analyse::fen
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark
   }















   proc ::bddimages_analyse::next { } {

         if {$::analyse_tools::id_current_image < $::analyse_tools::nb_img_list} {
            incr ::analyse_tools::id_current_image
            catch {unset ::analyse_tools::current_listsources}
            ::bddimages_analyse::charge_current_image
         }
   }










   proc ::bddimages_analyse::back { } {

         if {$::analyse_tools::id_current_image > 1 } {
            incr ::analyse_tools::id_current_image -1
            catch {unset ::analyse_tools::current_listsources}
            ::bddimages_analyse::charge_current_image
         }
   }








   proc ::bddimages_analyse::get_cata { } {


         $::bddimages_analyse::gui_create configure -state disabled
         $::bddimages_analyse::gui_fermer configure -state disabled

         if { $::analyse_tools::boucle == 1 } {
            ::bddimages_analyse::get_all_cata
         }  else {
            cleanmark
            if {[::bddimages_analyse::get_one_wcs] == true} {
            
               set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_good
               $::bddimages_analyse::gui_wcs configure -bg $::bddimages_analyse::color_wcs
            
               if {[::analyse_tools::get_cata] == false} {
                  # TODO gerer l'erreur le  cata a echou�
                  set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_bad
                  $::bddimages_analyse::gui_cata configure -bg $::bddimages_analyse::color_cata
                  
                  #return false
               } else {
                  set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_good
                  $::bddimages_analyse::gui_cata configure -bg $::bddimages_analyse::color_cata
                  ::bddimages_analyse::affiche_cata
               }
            } else {
               # TODO gerer l'erreur le wcs a echou�
               set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_bad
               $::bddimages_analyse::gui_wcs configure -bg $::bddimages_analyse::color_wcs
               cleanmark
               
            }
            
         }
         $::bddimages_analyse::gui_create configure -state normal
         $::bddimages_analyse::gui_fermer configure -state normal

   }


















   proc ::bddimages_analyse::affiche_current_image { } {

      global bddconf

      set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]
      
      buf$::audace(bufNo) load $file
      ::audace::autovisu $::audace(visuNo)

   }






   proc ::bddimages_analyse::get_all_cata { } {

         cleanmark
         while {1==1} {
            if { $::analyse_tools::boucle == 0 } {
               break
            }
            if {[::bddimages_analyse::get_one_wcs] == true} {
                
               set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_good
               $::bddimages_analyse::gui_wcs configure -bg $::bddimages_analyse::color_wcs
               if {[::analyse_tools::get_cata] == false} {
                  # TODO gerer l'erreur le  cata a echou�
                  set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_bad
                  $::bddimages_analyse::gui_cata configure -bg $::bddimages_analyse::color_cata
                  break
               } else {
                  # Ok ca se passe bien
                  set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_good
                  $::bddimages_analyse::gui_cata configure -bg $::bddimages_analyse::color_cata
                  cleanmark
                  ::bddimages_analyse::affiche_current_image
                  ::bddimages_analyse::affiche_cata
               }
            } else {
               # TODO gerer l'erreur le wcs a echou�
               set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_bad
               $::bddimages_analyse::gui_wcs configure -bg $::bddimages_analyse::color_wcs
               cleanmark
               break
            }
            if {$::analyse_tools::id_current_image == $::analyse_tools::nb_img_list} { break }
            ::bddimages_analyse::next
         }

   }












   proc ::bddimages_analyse::load_cata {  } {

      global bddconf

      set catafilename [::bddimages_liste::lget $::analyse_tools::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::analyse_tools::current_image "catadirfilename"]
      #set catadirfilename [::bddimages_liste::lget $::analyse_tools::current_image "catadirfilename"]
         
      set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
      #gren_info "catafile = $catafile\n"
      set catafile [::tools_cata::extract_cata_xml $catafile]
      #gren_info "READ catafile = $catafile\n"
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
      set ::analyse_tools::current_listsources $listsources
   }











   proc ::bddimages_analyse::affiche_cata { } {


       set err [catch {

       #gren_info "AFFICHE_CATA\n"
       
       if {[::bddimages_liste::lget $::analyse_tools::current_image "cataexist"]=="1"} {
          gren_info "LOAD CATA\n"
          ::bddimages_analyse::load_cata
          #gren_info "current_listsources = $::analyse_tools::current_listsources \n"
       } else {
          ::console::affiche_erreur "NO CATA\n"
          return
       }

       cleanmark
       #gren_info "current_listsources = $::analyse_tools::current_listsources \n"
       #::tools_sources::imprim_3_sources $::analyse_tools::current_listsources USNOA2

       if { $::bddimages_analyse::gui_img    } {
          #gren_info "OK\n"
          #gren_info "size_img = $::analyse_tools::size_img\n"
          #gren_info "gui_img = $::bddimages_analyse::gui_img\n"
          #gren_info "color_img = $::analyse_tools::color_img\n"
          #gren_info "nb = [::tools_sources::get_nb_sources_by_cata $::analyse_tools::current_listsources IMG ]\n"
          #::tools_sources::imprim_3_sources $::analyse_tools::current_listsources USNOA2
          affich_rond $::analyse_tools::current_listsources IMG $::analyse_tools::color_img $::analyse_tools::size_img }
       if { $::bddimages_analyse::gui_usnoa2 } { affich_rond $::analyse_tools::current_listsources USNOA2 $::analyse_tools::color_usnoa2 $::analyse_tools::size_usnoa2 }
       if { $::bddimages_analyse::gui_ucac2  } { affich_rond $::analyse_tools::current_listsources UCAC2  $::analyse_tools::color_ucac2  $::analyse_tools::size_ucac2  }
       if { $::bddimages_analyse::gui_ucac3  } { affich_rond $::analyse_tools::current_listsources UCAC3  $::analyse_tools::color_ucac3  $::analyse_tools::size_ucac3  }
       if { $::bddimages_analyse::gui_tycho2 } { affich_rond $::analyse_tools::current_listsources TYCHO2 $::analyse_tools::color_tycho2 $::analyse_tools::size_tycho2 }
       if { $::bddimages_analyse::gui_nomad1 } { affich_rond $::analyse_tools::current_listsources NOMAD1 $::analyse_tools::color_nomad1 $::analyse_tools::size_nomad1 }
       if { $::bddimages_analyse::gui_skybot } { affich_rond $::analyse_tools::current_listsources SKYBOT $::analyse_tools::color_skybot $::analyse_tools::size_skybot }

       } msg ]
       if {$err} {
          ::console::affiche_erreur "ERREUR affiche_cata : $msg\n" 
           set ::analyse_tools::current_listsources [::tools_sources::set_common_fields_skybot $::analyse_tools::current_listsources]
          ::tools_sources::imprim_3_sources $::analyse_tools::current_listsources SKYBOT
       }
   }














































   proc ::bddimages_analyse::get_one_wcs { } {

         set tabkey         [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
         set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs" ] 1] ]
         set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
         set idbddimg       [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         set filename       [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
         set dirfilename    [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
         #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs \n"

         set err [catch {::analyse_tools::get_wcs} msg]
         #gren_info "::analyse_tools::get_wcs $err $msg \n"
         
         if {$err == 0 } {
            set newimg [::bddimages_liste_gui::file_to_img $filename $dirfilename]
            
            set ::analyse_tools::img_list [lreplace $::analyse_tools::img_list [expr $::analyse_tools::id_current_image -1] [expr $::analyse_tools::id_current_image-1] $newimg]
            
            set idbddimg    [::bddimages_liste::lget $newimg idbddimg]
            set tabkey      [::bddimages_liste::lget $newimg "tabkey"]
            set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
            #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs  \n"

            set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_good

            set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
            set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
            set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
            set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
            set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
            set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
            
            return true

         } else {
            # "idbddimg : $idbddimg   filename : $filename wcs : erreur \n"
            ::console::affiche_erreur "GET_WCS ERROR: $msg  idbddimg : $idbddimg   filename : $filename\n"
            set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_bad
            return false
         }
   }













   proc ::bddimages_analyse::aladin { } {

     global bddconf

         set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]

         set tabkey [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
         set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]

         set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set ::analyse_tools::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
         set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
         set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
         set xcent    [expr $naxis1/2.0]
         set ycent    [expr $naxis2/2.0]
         set naxis1   [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
         set naxis2   [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
         set scale_x  [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
         set scale_y  [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
         set radius   [::analyse_tools::get_radius $naxis1 $naxis2 $scale_x $scale_y]

         #envoie dans Aladin l image
         ::vo_tools::SampBroadcastImage        

         #envoi du CATA
         #gren_info "current_image = $::analyse_tools::current_image\n"
         set cataexist [::bddimages_liste::lget $::analyse_tools::current_image "cataexist"]
         set catafilename [::bddimages_liste::lget $::analyse_tools::current_image "catafilename"]
         set catadirfilename [::bddimages_liste::lget $::analyse_tools::current_image "catadirfilename"]
         set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename] 

         gren_info "cataexist = $cataexist\n"
         set ::analyse_tools::current_image [::bddimages_liste_gui::add_info_cata $::analyse_tools::current_image]
         gren_info "cataexist = $cataexist\n"
         if {$cataexist} {


             set ::votableUtil::votBuf(file) $catafile
            ::vo_tools::SampBroadcastTable
         }

   }













   proc ::bddimages_analyse::charge_current_image { } {

      global audace
      global bddconf

         

         #�Charge l image en memoire
         #gren_info "cur id $::analyse_tools::id_current_image: \n"
         set ::analyse_tools::current_image [lindex $::analyse_tools::img_list [expr $::analyse_tools::id_current_image - 1] ]
         set ::analyse_tools::current_image [::bddimages_liste_gui::add_info_cata $::analyse_tools::current_image]
         
         set cataexist   [::bddimages_liste::lget $::analyse_tools::current_image "cataexist"]
         set tabkey      [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]

         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]
         set ::analyse_tools::current_image_name $filename
         set ::analyse_tools::current_image_date $date
         set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
         set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
         set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
         set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
         set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
         set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
         set ::analyse_tools::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]
         set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
         set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
         set xcent    [expr $naxis1/2.0]
         set ycent    [expr $naxis2/2.0]

         $::bddimages_analyse::gui_dateimage configure -text $::analyse_tools::current_image_date
         #gren_info "wcs : $date $::analyse_tools::bddimages_wcs\n"
         #gren_info "\n\nTABKEY = $tabkey"
         #gren_info "$::analyse_tools::id_current_image = date : $date  idbddimg : $idbddimg  file : $filename $::analyse_tools::bddimages_wcs\n"

         #�Charge l image a l ecran
         #gren_info "\n ** LOAD ** charge_current_image\n"
         buf$::audace(bufNo) load $file


         if { $::analyse_tools::boucle == 0 } {
            #set cuts [buf$::audace(bufNo) autocuts]
            #gren_info "\n ** VISU ** charge_current_image\n"
            #::audace::autovisu $::audace(visuNo)
            ::bddimages_analyse::affiche_current_image
            ::bddimages_analyse::affiche_cata
            #visu$::audace(visuNo) disp [list [lindex $cuts 0] [lindex $cuts 1] ]
         }
         
         #�Mise a jour GUI
         
         $::bddimages_analyse::gui_back configure -state disabled
         
         $::bddimages_analyse::gui_nomimage configure -text $::analyse_tools::current_image_name
         $::bddimages_analyse::gui_stimage  configure -text "$::analyse_tools::id_current_image / $::analyse_tools::nb_img_list"

         if {$::analyse_tools::id_current_image == 1 && $::analyse_tools::nb_img_list > 1 } {
            $::bddimages_analyse::gui_back configure -state disabled
         }
         if {$::analyse_tools::id_current_image == $::analyse_tools::nb_img_list && $::analyse_tools::nb_img_list > 1 } {
            $::bddimages_analyse::gui_next configure -state disabled
         }
         if {$::analyse_tools::id_current_image > 1 } {
            $::bddimages_analyse::gui_back configure -state normal
         }
         if {$::analyse_tools::id_current_image < $::analyse_tools::nb_img_list } {
            $::bddimages_analyse::gui_next configure -state normal
         }
         if {$::analyse_tools::bddimages_wcs == "Y"} {
            set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_good
            $::bddimages_analyse::gui_wcs configure -bg $::bddimages_analyse::color_wcs
         } else {
            set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_bad
            $::bddimages_analyse::gui_wcs configure -bg $::bddimages_analyse::color_wcs
         }
         if {$cataexist == "1"} {
            set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_good
            $::bddimages_analyse::gui_cata configure -bg $::bddimages_analyse::color_cata
         } else {
            set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_bad
            $::bddimages_analyse::gui_cata configure -bg $::bddimages_analyse::color_cata
         }
         affich_un_rond_xy $xcent $ycent red 2 2
   }



      



   proc ::bddimages_analyse::charge_list { img_list } {

      global audace
      global bddconf

     catch {
         if { [ info exists $::analyse_tools::img_list ] }           {unset ::analyse_tools::img_list}
         if { [ info exists $::analyse_tools::nb_img_list ] }        {unset ::analyse_tools::nb_img_list}
         if { [ info exists $::analyse_tools::current_image ] }      {unset ::analyse_tools::current_image}
         if { [ info exists $::analyse_tools::current_image_name ] } {unset ::analyse_tools::current_image_name}
      }
      
      set ::analyse_tools::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::analyse_tools::img_list    [::bddimages_liste_gui::add_info_cata_list $::analyse_tools::img_list]
      set ::analyse_tools::nb_img_list [llength $::analyse_tools::img_list]
      #gren_info "nb images : $::analyse_tools::nb_img_list\n"

      foreach ::analyse_tools::current_image $::analyse_tools::img_list {
         set tabkey      [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
         #gren_info "date : $date  idbddimg : $idbddimg\n"
      }

      # Chargement premiere image sans GUI
      #gren_info "* Premiere image :\n"
      set ::analyse_tools::id_current_image 1
      set ::analyse_tools::current_image [lindex $::analyse_tools::img_list 0]

      set tabkey      [::bddimages_liste::lget $::analyse_tools::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::analyse_tools::current_image "cataexist"]

      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::analyse_tools::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::analyse_tools::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::analyse_tools::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      set ::analyse_tools::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
      set ::analyse_tools::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
      set ::analyse_tools::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
      set ::analyse_tools::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
      set ::analyse_tools::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
      set ::analyse_tools::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
      set ::analyse_tools::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]
      set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1     ] 1]
      set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2     ] 1]
      set xcent    [expr $naxis1/2.0]
      set ycent    [expr $naxis2/2.0]

      set ::analyse_tools::current_image_name $filename
      set ::analyse_tools::current_image_date $date
      #gren_info "$::analyse_tools::id_current_image = date : $date  idbddimg : $idbddimg  file : $filename $::analyse_tools::bddimages_wcs\n"

      #�Charge l image a l ecran
      #gren_info "\n ** LOAD ** \n"
      buf$::audace(bufNo) load $file
      #gren_info "\n ** VISU ** premiere image\n"
      #::audace::autovisu $::audace(visuNo)
      #visu$::audace(visuNo) disp

      # Etat des boutons et GUI
      cleanmark
      set ::bddimages_analyse::stateback disabled
      if {$::analyse_tools::nb_img_list == 1} {
         set ::bddimages_analyse::statenext disabled
      } else {
         set ::bddimages_analyse::statenext normal
      }
      if {$::analyse_tools::bddimages_wcs == "Y"} {
         set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_good
      } else {
         set ::bddimages_analyse::color_wcs $::bddimages_analyse::color_button_bad
      }
      if {$cataexist == "1"} {
         set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_good
      } else {
         set ::bddimages_analyse::color_cata $::bddimages_analyse::color_button_bad
      }
      
      set ::analyse_tools::nb_img     0
      set ::analyse_tools::nb_usnoa2  0
      set ::analyse_tools::nb_tycho2  0
      set ::analyse_tools::nb_ucac2   0
      set ::analyse_tools::nb_ucac3   0
      set ::analyse_tools::nb_nomad1  0
      set ::analyse_tools::nb_skybot  0
      affich_un_rond_xy $xcent $ycent red 2 2
      ::bddimages_analyse::affiche_current_image
      ::bddimages_analyse::affiche_cata
   }






















   proc ::bddimages_analyse::get_confsex { } {

      global audace

         
         set fileconf [ file join $audace(rep_plugin) tool bddimages config config.sex ]
         
         # $::bddimages_analyse::current_appli.onglets.nb.f5.confsex.file insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
         # $confsex.file  insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
         
         set chan [open $fileconf r]
         while {[gets $chan line] >= 0} {
            $::bddimages_analyse::current_appli.onglets.nb.f5.confsex.file insert end "$line\n"
         }
         close $chan

   }



   proc ::bddimages_analyse::set_confsex { } {

      global audace

      set r  [$::bddimages_analyse::current_appli.onglets.nb.f5.confsex.file get 1.0 end]
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




   proc ::bddimages_analyse::test_confsex { } {

      cleanmark
      ::bddimages_analyse::set_confsex 

      catch {
        calibwcs * * * * * USNO $::analyse_tools::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0
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




   proc ::bddimages_analyse::affich_catapcat {  } {
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








































   proc ::bddimages_analyse::creation_cata { img_list } {

      global audace
      global bddconf

      ::bddimages_analyse::charge_list $img_list
      ::bddimages_analyse::inittoconf
      

      #--- Creation de la fenetre
      set ::bddimages_analyse::fen .new
      if { [winfo exists $::bddimages_analyse::fen] } {
         wm withdraw $::bddimages_analyse::fen
         wm deiconify $::bddimages_analyse::fen
         focus $::bddimages_analyse::fen
         return
      }
      toplevel $::bddimages_analyse::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bddimages_analyse::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bddimages_analyse::fen ] "+" ] 2 ]
      wm geometry $::bddimages_analyse::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bddimages_analyse::fen 1 1
      wm title $::bddimages_analyse::fen "Creation du CATA"
      wm protocol $::bddimages_analyse::fen WM_DELETE_WINDOW "destroy $::bddimages_analyse::fen"

      set frm $::bddimages_analyse::fen.frm_creation_cata
      set ::bddimages_analyse::current_appli $frm



      

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::bddimages_analyse::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame general
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


             set ::bddimages_analyse::gui_back [button $actions.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::back" -state $::bddimages_analyse::stateback]
             pack $actions.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::bddimages_analyse::gui_next [button $actions.next -text "Next" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::next" -state $::bddimages_analyse::statenext]
             pack $actions.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::bddimages_analyse::gui_create [button $actions.go -text "Create" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::get_cata" -state normal]
             pack $actions.go -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un label 
             set ::bddimages_analyse::gui_stimage [label $actions.stimage -text "$::analyse_tools::id_current_image / $::analyse_tools::nb_img_list"]
             pack $::bddimages_analyse::gui_stimage -side left -padx 3 -pady 3

             #--- Cree un frame pour afficher boucle
             set bouc [frame $actions.bouc -borderwidth 0 -cursor arrow -relief groove]
             pack $bouc -in $actions -side left -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un checkbutton
                  checkbutton $bouc.check -highlightthickness 0 -text "Analyse continue" -variable ::analyse_tools::boucle
                  pack $bouc.check -in $bouc -side left -padx 5 -pady 0


             #--- Cree un frame general
             set lampions [frame $actions.actions -borderwidth 0 -cursor arrow -relief groove]
             pack $lampions -in $actions -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

                  set ::bddimages_analyse::gui_wcs [button $lampions.wcs -text "WCS" \
                     -borderwidth 1 -takefocus 0 -command "" \
                     -bg $::bddimages_analyse::color_wcs -relief sunken -state disabled]
                  pack $lampions.wcs -side top -anchor e -expand 0 -padx 0 -pady 0 -ipadx 0 -ipady 0

                  set ::bddimages_analyse::gui_cata [button $lampions.cata -text "CATA" -borderwidth 1 -takefocus 0 -command "" \
                     -bg $::bddimages_analyse::color_cata -relief sunken -state disabled]
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
            
            $onglets.nb add $f1 -text "Catalogues"
            $onglets.nb add $f2 -text "Variables"
            $onglets.nb add $f3 -text "Entete"
            $onglets.nb add $f4 -text "Couleurs"
            $onglets.nb add $f5 -text "Sextractor"
            $onglets.nb add $f6 -text "Interop"
            $onglets.nb add $f7 -text "Manuel"
            $onglets.nb select $f3
            ttk::notebook::enableTraversal $onglets.nb







        #--- Cree un frame pour afficher ucac2
        set usnoa2 [frame $f1.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
        pack $usnoa2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $usnoa2.check -highlightthickness 0 -text "USNO-A2" \
                              -variable ::analyse_tools::use_usnoa2 -state disabled
             pack $usnoa2.check -in $usnoa2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $usnoa2.dir -relief sunken -textvariable ::analyse_tools::catalog_usnoa2 -width 30
             pack $usnoa2.dir -in $usnoa2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set tycho2 [frame $f1.tycho2 -borderwidth 0 -cursor arrow -relief groove]
        pack $tycho2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $tycho2.check -highlightthickness 0 -text "tycho2" -variable ::analyse_tools::use_tycho2
             pack $tycho2.check -in $tycho2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $tycho2.dir -relief sunken -textvariable ::analyse_tools::catalog_tycho2 -width 30
             pack $tycho2.dir -in $tycho2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set ucac2 [frame $f1.ucac2 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac2.check -highlightthickness 0 -text "ucac2" -variable ::analyse_tools::use_ucac2
             pack $ucac2.check -in $ucac2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac2.dir -relief sunken -textvariable ::analyse_tools::catalog_ucac2 -width 30
             pack $ucac2.dir -in $ucac2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac3
        set ucac3 [frame $f1.ucac3 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac3 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac3.check -highlightthickness 0 -text "ucac3" -variable ::analyse_tools::use_ucac3
             pack $ucac3.check -in $ucac3 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac3.dir -relief sunken -textvariable ::analyse_tools::catalog_ucac3 -width 30
             pack $ucac3.dir -in $ucac3 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher nomad1
        set nomad1 [frame $f1.nomad1 -borderwidth 0 -cursor arrow -relief groove]
        pack $nomad1 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $nomad1.check -highlightthickness 0 -text "nomad1" -variable ::analyse_tools::use_nomad1
             pack $nomad1.check -in $nomad1 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $nomad1.dir -relief sunken -textvariable ::analyse_tools::catalog_nomad1 -width 30
             pack $nomad1.dir -in $nomad1 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher boucle
        set skybot [frame $f1.skybot -borderwidth 0 -cursor arrow -relief groove]
        pack $skybot -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $skybot.check -highlightthickness 0 -text "Utiliser SkyBot" -variable ::analyse_tools::use_skybot
             pack $skybot.check -in $skybot -side left -padx 5 -pady 0
  





        #--- Cree un frame pour afficher delkwd PV
        set deuxpasses [frame $f2.deuxpasses -borderwidth 0 -cursor arrow -relief groove]
        pack $deuxpasses -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $deuxpasses.check -highlightthickness 0 -text "Faire 2 passes pour calibrer" -variable ::analyse_tools::deuxpasses
             pack $deuxpasses.check -in $deuxpasses -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher "utiliser les RA/DEC precedent
        set keepradec [frame $f2.keepradec -borderwidth 0 -cursor arrow -relief groove]
        pack $keepradec -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $keepradec.check -highlightthickness 0 -text "Utiliser RADEC precedent" -variable ::analyse_tools::keep_radec
             pack $keepradec.check -in $keepradec -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher delkwd PV
        set delpv [frame $f2.delpv -borderwidth 0 -cursor arrow -relief groove]
        pack $delpv -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $delpv.check -highlightthickness 0 -text "Suppression des PV(1,2)_0" -variable ::analyse_tools::delpv
             pack $delpv.check -in $delpv -side left -padx 5 -pady 0
  
        #--- Cree un frame pour afficher creation du cata
        set create_cata [frame $f2.create_cata -borderwidth 0 -cursor arrow -relief groove]
        pack $create_cata -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $create_cata.check -highlightthickness 0 -text "Inserer le fichier CATA" -variable ::analyse_tools::create_cata
             pack $create_cata.check -in $create_cata -side left -padx 5 -pady 0
  
  

        #--- Cree un frame pour afficher boucle
        set limit_nbstars [frame $f2.limit_nbstars -borderwidth 0 -cursor arrow -relief groove]
        pack $limit_nbstars -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $limit_nbstars.lab -text "limite acceptable du nb d'etoiles identifiees : " 
             pack $limit_nbstars.lab -in $limit_nbstars -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $limit_nbstars.val -relief sunken -textvariable ::analyse_tools::limit_nbstars_accepted
             pack $limit_nbstars.val -in $limit_nbstars -side right -pady 1 -anchor w

        #--- Cree un frame pour afficher boucle
        set log [frame $f2.log -borderwidth 0 -cursor arrow -relief groove]
        pack $log -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $log.check -highlightthickness 0 -text "Activation du log" -variable ::analyse_tools::log
             pack $log.check -in $log -side left -padx 5 -pady 0













        #--- Cree un frame pour afficher info image
        set infoimage [frame $f3.infoimage -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimage -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 

            #--- Cree un label pour le Nom de l image
            set ::bddimages_analyse::gui_nomimage [label $infoimage.nomimage -text $::analyse_tools::current_image_name]
            pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

            set ::bddimages_analyse::gui_dateimage [label $infoimage.dateimage -text $::analyse_tools::current_image_date]
            pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3








        #--- Cree un frame pour afficher les champs du header
        set keys [frame $f3.keys -borderwidth 0 -cursor arrow -relief groove]
        pack $keys -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- RA
            set ra [frame $keys.ra -borderwidth 0 -cursor arrow -relief groove]
            pack $ra -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $ra.name -text "RA : "
                pack $ra.name -in $ra -side left -padx 3 -pady 3
                entry $ra.val -relief sunken -textvariable ::analyse_tools::ra
                pack $ra.val -in $ra -side right -pady 1 -anchor w

            #--- DEC
            set dec [frame $keys.dec -borderwidth 0 -cursor arrow -relief groove]
            pack $dec -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $dec.name -text "DEC : "
                pack $dec.name -in $dec -side left -padx 3 -pady 3
                entry $dec.val -relief sunken -textvariable ::analyse_tools::dec
                pack $dec.val -in $dec -side right -pady 1 -anchor w

            #--- pixsize1
            set pixsize1 [frame $keys.pixsize1 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize1 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize1.name -text "PIXSIZE1 : "
                pack $pixsize1.name -in $pixsize1 -side left -padx 3 -pady 3
                entry $pixsize1.val -relief sunken -textvariable ::analyse_tools::pixsize1
                pack $pixsize1.val -in $pixsize1 -side right -pady 1 -anchor w

            #--- pixsize2
            set pixsize2 [frame $keys.pixsize2 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize2 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize2.name -text "PIXSIZE2 : "
                pack $pixsize2.name -in $pixsize2 -side left -padx 3 -pady 3
                entry $pixsize2.val -relief sunken -textvariable ::analyse_tools::pixsize2
                pack $pixsize2.val -in $pixsize2 -side right -pady 1 -anchor w

            #--- foclen
            set foclen [frame $keys.foclen -borderwidth 0 -cursor arrow -relief groove]
            pack $foclen -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $foclen.name -text "FOCLEN : "
                pack $foclen.name -in $foclen -side left -padx 3 -pady 3
                entry $foclen.val -relief sunken -textvariable ::analyse_tools::foclen
                pack $foclen.val -in $foclen -side right -pady 1 -anchor w

            button $f3.setval -text "Set Val" -borderwidth 2 -takefocus 1 \
              -command "::bddimages_analyse::setval"
            pack $f3.setval -side top \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


        #--- Cree un frame pour afficher 
        set count [frame $f4.count -borderwidth 0 -cursor arrow -relief groove]
        pack $count -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un frame pour afficher 
           set img [frame $count.img -borderwidth 0 -cursor arrow -relief groove]
           pack $img -in $count -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

                #--- Cree un label pour le titre
                checkbutton $img.check -highlightthickness 0 \
                      -variable ::bddimages_analyse::gui_img -state normal \
                      -command "::bddimages_analyse::affiche_cata"
                pack $img.check -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.name -text "IMG : " -width 7
                pack $img.name -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.val -textvariable ::analyse_tools::nb_img
                pack $img.val -in $img -side left -padx 3 -pady 3
                button $img.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_img -command ""
                pack $img.color -side left -anchor e -expand 0 
                spinbox $img.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "::bddimages_analyse::affiche_cata" -width 3 \
                      -textvariable ::analyse_tools::size_img
                pack  $img.radius -in $img -side left -anchor w

           #--- Cree un frame pour afficher USNOA2
           set usnoa2 [frame $count.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
           pack $usnoa2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $usnoa2.check -highlightthickness 0 \
                      -variable ::bddimages_analyse::gui_usnoa2 -state normal \
                      -command "::bddimages_analyse::affiche_cata"
                pack $usnoa2.check -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.name -text "USNOA2 : " -width 7
                pack $usnoa2.name -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.val -textvariable ::analyse_tools::nb_usnoa2
                pack $usnoa2.val -in $usnoa2 -side left -padx 3 -pady 3
                button $usnoa2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_usnoa2 -command ""
                pack $usnoa2.color -side left -anchor e -expand 0 
                spinbox $usnoa2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $usnoa2.radius -in $usnoa2 -side left -anchor w

           #--- Cree un frame pour afficher UCAC2
           set ucac2 [frame $count.ucac2 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac2.check -highlightthickness 0  \
                      -variable ::bddimages_analyse::gui_ucac2 -state normal  \
                      -command "::bddimages_analyse::affiche_cata"
                pack $ucac2.check -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.name -text "UCAC2 : " -width 7
                pack $ucac2.name -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.val -textvariable ::analyse_tools::nb_ucac2
                pack $ucac2.val -in $ucac2 -side left -padx 3 -pady 3
                button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_ucac2 -command ""
                pack $ucac2.color -side left -anchor e -expand 0 
                spinbox $ucac2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $ucac2.radius -in $ucac2 -side left -anchor w

           #--- Cree un frame pour afficher UCAC3
           set ucac3 [frame $count.ucac3 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac3 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac3.check -highlightthickness 0 \
                      -variable ::bddimages_analyse::gui_ucac3 -state normal  \
                      -command "::bddimages_analyse::affiche_cata"
                pack $ucac3.check -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.name -text "UCAC3 : " -width 7
                pack $ucac3.name -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.val -textvariable ::analyse_tools::nb_ucac3
                pack $ucac3.val -in $ucac3 -side left -padx 3 -pady 3
                button $ucac3.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_ucac3 -command ""
                pack $ucac3.color -side left -anchor e -expand 0 
                spinbox $ucac3.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $ucac3.radius -in $ucac3 -side left -anchor w

           #--- Cree un frame pour afficher TYCHO2
           set tycho2 [frame $count.tycho2 -borderwidth 0 -cursor arrow -relief groove]
           pack $tycho2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $tycho2.check -highlightthickness 0 \
                      -variable ::bddimages_analyse::gui_tycho2 -state normal \
                      -command "::bddimages_analyse::affiche_cata"
                pack $tycho2.check -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.name -text "TYCHO2 : " -width 7
                pack $tycho2.name -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.val -textvariable ::analyse_tools::nb_tycho2
                pack $tycho2.val -in $tycho2 -side left -padx 3 -pady 3
                button $tycho2.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_tycho2 -command ""
                pack $tycho2.color -side left -anchor e -expand 0 
                spinbox $tycho2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $tycho2.radius -in $tycho2 -side left -anchor w

           #--- Cree un frame pour afficher NOMAD1
           set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
           pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $nomad1.check -highlightthickness 0 \
                      -variable ::bddimages_analyse::gui_nomad1 -state normal  \
                      -command "::bddimages_analyse::affiche_cata"
                pack $nomad1.check -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.name -text "NOMAD1 : " -width 7
                pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.val -textvariable ::analyse_tools::nb_nomad1
                pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
                button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_nomad1 -command ""
                pack $nomad1.color -side left -anchor e -expand 0 
                spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $nomad1.radius -in $nomad1 -side left -anchor w


           #--- Cree un frame pour afficher NOMAD1
           set skybot [frame $count.skybot -borderwidth 0 -cursor arrow -relief groove]
           pack $skybot -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $skybot.check -highlightthickness 0 \
                      -variable ::bddimages_analyse::gui_skybot -state normal  \
                      -command "::bddimages_analyse::affiche_cata"
                pack $skybot.check -in $skybot -side left -padx 3 -pady 3 -anchor w 
                label $skybot.name -text "SKYBOT : " -width 7
                pack $skybot.name -in $skybot -side left -padx 3 -pady 3 -anchor w 
                label $skybot.val -textvariable ::analyse_tools::nb_skybot
                pack $skybot.val -in $skybot -side left -padx 3 -pady 3
                button $skybot.color -borderwidth 0 -takefocus 1 -bg $::analyse_tools::color_skybot -command ""
                pack $skybot.color -side left -anchor e -expand 0 
                spinbox $skybot.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $skybot.radius -in $skybot -side left -anchor w


        #--- Cree un frame pour afficher 
        set confsex [frame $f5.confsex -borderwidth 0 -cursor arrow -relief groove]
        pack $confsex -in $f5 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                frame $confsex.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $confsex.buttons  -in $confsex  -side top -anchor e -expand 0 
                
                     button  $confsex.buttons.clean  -borderwidth 1  \
                         -command "cleanmark" -text "Clean"
                     pack    $confsex.buttons.clean  -side left -anchor e -expand 0 
                     button  $confsex.buttons.test  -borderwidth 1  \
                         -command "::bddimages_analyse::test_confsex" -text "Test"
                     pack    $confsex.buttons.test  -side left -anchor e -expand 0 
                     button  $confsex.buttons.save  -borderwidth 1  \
                         -command "::bddimages_analyse::set_confsex" -text "Save"
                     pack    $confsex.buttons.save  -side left -anchor e -expand 0 

                #--- Cree un label pour le titre
                text $confsex.file 
                pack $confsex.file -in $confsex -side top -padx 3 -pady 3 -anchor w 

                ::bddimages_analyse::get_confsex


        #--- Cree un frame pour afficher 
        set interop [frame $f6.interop -borderwidth 0 -cursor arrow -relief groove]
        pack $interop -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
  
           # Bouton Aladin       
           set plan [frame $interop.plan -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
           pack $plan -in $interop -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
              label $plan.lab -text "Envoyer le plan vers "
              pack $plan.lab -in $plan -side left -padx 3 -pady 3
              button $plan.aladin -text "Aladin" -borderwidth 2 -takefocus 1 -command "::bddimages_analyse::aladin" 
              pack $plan.aladin -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           # 
           set dss [frame $interop.dss -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
           pack $dss -in $interop -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set l [frame $dss.l -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $l -in $dss -anchor s -side left -expand 0 -fill x -padx 10 -pady 5
                 label $l.coord -text "Coordonnees : "
                 pack $l.coord -in $l -side top -padx 3 -pady 3
                 label $l.date -text "Date : "
                 pack $l.date -in $l -side top -padx 3 -pady 3
                 label $l.uaicode -text "UAI Code : "
                 pack $l.uaicode -in $l -side top -padx 3 -pady 3
 
              set m [frame $dss.m -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $m -in $dss -anchor s -side left -expand 0 -fill x -padx 10 -pady 5
                 entry $m.coord -relief sunken -textvariable ::analyse_tools::coord
                 pack $m.coord -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.date -relief sunken -textvariable ::analyse_tools::date
                 pack $m.date -in $m -side top -padx 3 -pady 3 -anchor w
                 entry $m.uaicode -relief sunken -textvariable ::analyse_tools::uaicode
                 pack $m.uaicode -in $m -side top -padx 3 -pady 3 -anchor w

              set r [frame $dss.r -borderwidth 0 -cursor arrow  -borderwidth 0]
              pack $r -in $dss -anchor s -side left -expand 0 -fill x -padx 3 -pady 3
                 button $r.resolve -text "resolve" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 -command ""
                 pack $r.resolve -side top -anchor e -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0
                 button $r.aladin -text "Aladin" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 -command "" 
                 pack $r.aladin -side top -anchor e -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

        #--- Cree un frame pour afficher 
        set manuel [frame $f7.manuel -borderwidth 0 -cursor arrow -relief groove]
        pack $manuel -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                frame $manuel.entr -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr  -in $manuel  -side top 
                
                     set coord [frame $manuel.entr.coord -borderwidth 0 -cursor arrow  -borderwidth 0]
                     pack $coord -in $manuel.entr 

                          set img [frame $coord.l -borderwidth 0 -cursor arrow  -borderwidth 0]
                          pack $img -in $coord -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                                entry $img.v1 -relief sunken 
                                pack  $img.v1 -in $img -side top -padx 3 -pady 3 -anchor w
                                entry $img.v2 -relief sunken 
                                pack  $img.v2 -in $img -side top -padx 3 -pady 3 -anchor w
                                entry $img.v3 -relief sunken 
                                pack  $img.v3 -in $img -side top -padx 3 -pady 3 -anchor w
                                entry $img.v4 -relief sunken 
                                pack  $img.v4 -in $img -side top -padx 3 -pady 3 -anchor w
                                entry $img.v5 -relief sunken 
                                pack  $img.v5 -in $img -side top -padx 3 -pady 3 -anchor w
                                entry $img.v6 -relief sunken 
                                pack  $img.v6 -in $img -side top -padx 3 -pady 3 -anchor w
                                entry $img.v7 -relief sunken 
                                pack  $img.v7 -in $img -side top -padx 3 -pady 3 -anchor w

                          set other [frame $coord.r -borderwidth 0 -cursor arrow  -borderwidth 0]
                          pack $other -in $coord -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                                entry $other.v1 -relief sunken 
                                pack  $other.v1 -in $other -side top -padx 3 -pady 3 -anchor w
                                entry $other.v2 -relief sunken 
                                pack  $other.v2 -in $other -side top -padx 3 -pady 3 -anchor w
                                entry $other.v3 -relief sunken 
                                pack  $other.v3 -in $other -side top -padx 3 -pady 3 -anchor w
                                entry $other.v4 -relief sunken 
                                pack  $other.v4 -in $other -side top -padx 3 -pady 3 -anchor w
                                entry $other.v5 -relief sunken 
                                pack  $other.v5 -in $other -side top -padx 3 -pady 3 -anchor w
                                entry $other.v6 -relief sunken 
                                pack  $other.v6 -in $other -side top -padx 3 -pady 3 -anchor w
                                entry $other.v7 -relief sunken 
                                pack  $other.v7 -in $other -side top -padx 3 -pady 3 -anchor w

                frame $manuel.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.buttons  -in $manuel  -side top 
                
                     button  $manuel.buttons.grab  -borderwidth 1  \
                         -command "" -text "Grab"
                     pack    $manuel.buttons.grab -in $manuel.buttons -side left -anchor e -expand 0 
                     button  $manuel.buttons.creer  -borderwidth 1  \
                         -command "" -text "Creer"
                     pack    $manuel.buttons.creer -in $manuel.buttons -side left -anchor e -expand 0 






        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set ::bddimages_analyse::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::bddimages_analyse::fermer"]
             pack $boutonpied.fermer -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

            set ::bddimages_analyse::gui_info [label $boutonpied.info -text ""]
            pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
            set ::bddimages_analyse::gui_info2 [label $boutonpied.info2 -text ""]
            pack $::bddimages_analyse::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


   }
   


# Fin Classe
}

