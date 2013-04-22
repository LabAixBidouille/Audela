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
   variable use_tycho2
   variable use_ucac2
   variable use_ucac3
   variable use_ucac4
   variable use_ppmx
   variable use_ppmxl
   variable use_nomad1
   variable use_2mass

   variable catalog_usnoa2
   variable catalog_tycho2
   variable catalog_ucac2
   variable catalog_ucac3
   variable catalog_ucac4
   variable catalog_ppmx
   variable catalog_ppmxl
   variable catalog_nomad1
   variable catalog_2mass

   variable keep_radec
   variable create_cata
   variable boucle

   variable ra_save
   variable dec_save

   variable nb_img
   variable nb_ovni
   variable nb_skybot

   variable nb_usnoa2
   variable nb_tycho2
   variable nb_ucac2
   variable nb_ucac3
   variable nb_ucac4
   variable nb_ppmx
   variable nb_ppmxl
   variable nb_nomad1
   variable nb_2mass

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

   variable threshold_ident_pos_star
   variable threshold_ident_mag_star
   variable threshold_ident_pos_ast
   variable threshold_ident_mag_ast

   
   proc ::tools_cata::inittoconf { } {

      global conf

      set ::tools_cata::nb_img     0
      set ::tools_cata::nb_usnoa2  0
      set ::tools_cata::nb_tycho2  0
      set ::tools_cata::nb_ppmx    0
      set ::tools_cata::nb_ppmxl   0
      set ::tools_cata::nb_ucac2   0
      set ::tools_cata::nb_ucac3   0
      set ::tools_cata::nb_ucac4   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_2mass   0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0

      # Utilisation des catalogues
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
      if {! [info exists ::tools_cata::use_2mass] } {
         if {[info exists conf(bddimages,cata,use_2mass)]} {
            set ::tools_cata::use_2mass $conf(bddimages,cata,use_2mass)
         } else {
            set ::tools_cata::use_2mass 0
         }
      }
      if {! [info exists ::tools_cata::use_skybot] } {
         if {[info exists conf(bddimages,cata,use_skybot)]} {
            set ::tools_cata::use_skybot $conf(bddimages,cata,use_skybot)
         } else {
            set ::tools_cata::use_skybot 0
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
      if {! [info exists ::tools_cata::catalog_2mass] } {
         if {[info exists conf(bddimages,catfolder,2mass)]} {
            set ::tools_cata::catalog_2mass $conf(bddimages,catfolder,2mass)
         } else {
            set ::tools_cata::catalog_2mass ""
         }
      }

      # Services
      if {! [info exists ::tools_cata::catalog_skybot] } {
         if {[info exists conf(bddimages,catfolder,skybot)]} {
            set ::tools_cata::catalog_2mass $conf(bddimages,catfolder,skybot)
         } else {
            set ::tools_cata::catalog_skybot "http://vo.imcce.fr/webservices/skybot/"
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
      if {! [info exists ::tools_cata::threshold_ident_pos_star] } {
         if {[info exists conf(bddimages,cata,threshold_ident_pos_star)]} {
            set ::tools_cata::threshold_ident_pos_star $conf(bddimages,cata,threshold_ident_pos_star)
         } else {
            set ::tools_cata::threshold_ident_pos_star 30.0
         }
      }
      if {! [info exists ::tools_cata::threshold_ident_mag_star] } {
         if {[info exists conf(bddimages,cata,threshold_ident_mag_star)]} {
            set ::tools_cata::threshold_ident_mag_star $conf(bddimages,cata,threshold_ident_mag_star)
         } else {
            set ::tools_cata::threshold_ident_mag_star -30.0
         }
      }
      if {! [info exists ::tools_cata::threshold_ident_pos_ast] } {
         if {[info exists conf(bddimages,cata,threshold_ident_pos_ast)]} {
            set ::tools_cata::threshold_ident_pos_ast $conf(bddimages,cata,threshold_ident_pos_ast)
         } else {
            set ::tools_cata::threshold_ident_pos_ast 10.0
         }
      }
      if {! [info exists ::tools_cata::threshold_ident_mag_ast] } {
         if {[info exists conf(bddimages,cata,threshold_ident_mag_ast)]} {
            set ::tools_cata::threshold_ident_mag_ast $conf(bddimages,cata,threshold_ident_mag_ast)
         } else {
            set ::tools_cata::threshold_ident_mag_ast -100.0
         }
      }

   }




   proc ::tools_cata::closetoconf { } {

      global conf

       # Repertoires 
      set conf(bddimages,catfolder,usnoa2)              $::tools_cata::catalog_usnoa2 
      set conf(bddimages,catfolder,ucac2)               $::tools_cata::catalog_ucac2  
      set conf(bddimages,catfolder,ucac3)               $::tools_cata::catalog_ucac3  
      set conf(bddimages,catfolder,ucac4)               $::tools_cata::catalog_ucac4  
      set conf(bddimages,catfolder,ppmx)                $::tools_cata::catalog_ppmx  
      set conf(bddimages,catfolder,ppmxl)               $::tools_cata::catalog_ppmxl
      set conf(bddimages,catfolder,tycho2)              $::tools_cata::catalog_tycho2 
      set conf(bddimages,catfolder,nomad1)              $::tools_cata::catalog_nomad1 
      set conf(bddimages,catfolder,2mass)               $::tools_cata::catalog_2mass 
      # Utilisation des catalogues
      set conf(bddimages,cata,use_usnoa2)               $::tools_cata::use_usnoa2
      set conf(bddimages,cata,use_ucac2)                $::tools_cata::use_ucac2
      set conf(bddimages,cata,use_ucac3)                $::tools_cata::use_ucac3
      set conf(bddimages,cata,use_ucac4)                $::tools_cata::use_ucac4
      set conf(bddimages,cata,use_ppmx)                 $::tools_cata::use_ppmx
      set conf(bddimages,cata,use_ppmxl)                $::tools_cata::use_ppmxl
      set conf(bddimages,cata,use_tycho2)               $::tools_cata::use_tycho2
      set conf(bddimages,cata,use_nomad1)               $::tools_cata::use_nomad1
      set conf(bddimages,cata,use_2mass)                $::tools_cata::use_2mass
      set conf(bddimages,cata,use_skybot)               $::tools_cata::use_skybot
     # Autres utilitaires
      set conf(bddimages,cata,keep_radec)               $::tools_cata::keep_radec
      set conf(bddimages,cata,create_cata)              $::tools_cata::create_cata
      set conf(bddimages,cata,delpv)                    $::tools_cata::delpv
      set conf(bddimages,cata,boucle)                   $::tools_cata::boucle
      set conf(bddimages,cata,deuxpasses)               $::tools_cata::deuxpasses
      set conf(bddimages,cata,limit_nbstars_accepted)   $::tools_cata::limit_nbstars_accepted
      set conf(bddimages,cata,log)                      $::tools_cata::log
      set conf(bddimages,cata,threshold_ident_pos_star) $::tools_cata::threshold_ident_pos_star
      set conf(bddimages,cata,threshold_ident_mag_star) $::tools_cata::threshold_ident_mag_star
      set conf(bddimages,cata,threshold_ident_pos_ast)  $::tools_cata::threshold_ident_pos_ast
      set conf(bddimages,cata,threshold_ident_mag_ast)  $::tools_cata::threshold_ident_mag_ast

   }






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
      
      lassign [::bdi_tools::gunzip $catafile $tmpfile] errnum msgzip

      if {$errnum} {
         file delete -force -- $tmpfile
         return -code 1 "Err extraction $catafile -> $tmpfile with msg: $msgzip"
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
#gren_erreur "----------------------------------------------------------------\n"
#gren_info "$cpt  :  \n"
#gren_info "Name => $name  \n"
#gren_info "nrows  => $nrows  \n"
#gren_info "TABLE => $table  \n"
         set res [ ::tools_cata::get_table $name $table ]
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
         set x [string map { "<vot:TD/>" "<vot:TD></vot:TD>" } $x]
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

      gren_info "image qui va etre traitee : $imgfilename \n"

      set imgdirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      # Definition du nom du cata XML
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      gren_info "  -> cata dans tmp : $cataxml \n"

      set a $::tools_cata::current_image

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
         set listsources [ identification $listsources IMG $usnoa2 USNOA2 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
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
         set listsources [ identification $listsources IMG $tycho2 TYCHO2 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
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
         set listsources [ identification $listsources IMG $ucac2 UCAC2 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
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
         set listsources [ identification $listsources IMG $ucac3 UCAC3 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
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
         set listsources [ identification $listsources IMG $ucac4 UCAC4 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
         set ::tools_cata::nb_ucac4 [::manage_source::get_nb_sources_by_cata $listsources UCAC4]
      }

      if {$::tools_cata::use_ppmx} {
         #gren_info "CMD: csppmx $::tools_cata::catalog_ppmx $ra $dec $radius\n"
         set ppmx [csppmx $::tools_cata::catalog_ppmx $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ppmx]\n"
         set ppmx [::manage_source::set_common_fields $ppmx PPMX { RAJ2000 DECJ2000 errDec Vmag ErrVmag }]
         #::manage_source::imprim_3_sources $ppmx
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ppmx PPMX $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
         set ::tools_cata::nb_ppmx [::manage_source::get_nb_sources_by_cata $listsources PPMX]
      }

      if {$::tools_cata::use_ppmxl} {
         #gren_info "CMD: csppmxl $::tools_cata::catalog_ppmxl $ra $dec $radius\n"
         set ppmxl [csppmxl $::tools_cata::catalog_ppmxl $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ppmxl]\n"
         set ppmxl [::manage_source::set_common_fields $ppmxl PPMXL { RAJ2000 DECJ2000 errDec magR1 0.5 }]
         #::manage_source::imprim_3_sources $ppmxl
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $ppmxl PPMXL $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
         set ::tools_cata::nb_ppmxl [::manage_source::get_nb_sources_by_cata $listsources PPMXL]
      }

      if {$::tools_cata::use_nomad1} {
         #gren_info "CMD: csnomad1 $::tools_cata::catalog_nomad1 $ra $dec $radius\n"
         set nomad1 [csnomad1 $::tools_cata::catalog_nomad1 $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $nomad1]\n"
         set nomad1 [::manage_source::set_common_fields $nomad1 NOMAD1 { RAJ2000 DECJ2000 errDec magV 0.5 }]
         #::manage_source::imprim_3_sources $nomad1
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $nomad1 NOMAD1 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
         set ::tools_cata::nb_nomad1 [::manage_source::get_nb_sources_by_cata $listsources NOMAD1]
      }

      if {$::tools_cata::use_2mass} {
         #gren_info "CMD: cs2mass $::tools_cata::catalog_2mass $ra $dec $radius\n"
         set twomass [cs2mass $::tools_cata::catalog_2mass $ra $dec $radius]
         #gren_info "rollup = [::manage_source::get_nb_sources_rollup $twomass]\n"
         set twomass [::manage_source::set_common_fields $twomass 2MASS { ra_deg dec_deg err_dec jMag jMagError }]
         #::manage_source::imprim_3_sources $twomass
         #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Identification\n"
         set log 0
         set listsources [ identification $listsources IMG $twomass 2MASS $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $log]
         set ::tools_cata::nb_2mass [::manage_source::get_nb_sources_by_cata $listsources 2MASS]
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
         set log 0; # log=2 pour activer ulog dans identification
         set listsources [::manage_source::delete_catalog $listsources "SKYBOT"]
         set listsources [ identification $listsources "IMG" $skybot "SKYBOT" $::tools_cata::threshold_ident_pos_ast $::tools_cata::threshold_ident_mag_ast {} $log ] 
         set ::tools_cata::nb_skybot [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
      }

      if {$::bdi_tools_psf::use_psf} {
      
         gren_info "Building ASTROID catalogue ... \n"
         set tt0 [clock clicks -milliseconds]

         ::bdi_tools_psf::get_psf_listsources listsources
         set ::tools_cata::current_listsources_sav $listsources
         set ::tools_cata::nb_astroid [::manage_source::get_nb_sources_by_cata $listsources ASTROID]
   
         set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
         gren_info "** ASTROID in $tt secondes with SUCCESS for $::tools_cata::nb_astroid sources\n"

      }

      # Sauvegarde du cata XML
      if {$::tools_cata::create_cata == 1} {
         gren_info "Enregistrement du cata XML: $cataxml\n"
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
      #gren_info "date = $dateobs\n"
      gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"

      # Creation de la VOTable en memoire
      set votable [::votableUtil::list2votable $listsources $tabkey]
      
      # Sauvegarde du cata XML
      set fxml [open $cataxml "w"]
      puts $fxml $votable
      close $fxml
      #set fxml [open "/astrodata/Observations/Images/bddimages/bddimages_local/tmp/test.xml" "w"]
      #puts $fxml $votable
      #close $fxml
      
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
      if {$::tools_cata::log} {
         gren_info "nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
      }

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

         lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg

         if {$errnum != 0} {
            gren_info "Appel gzip: $filetmp -> $filefinal\n"
            gren_info "  size filetmp = [file size $filetmp]\n" 
            gren_info "   => err=$errnum avec msg: $msg\n"
         }

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
            set othf  [lindex [lindex $s $x] 2]           
            set ar [::bdi_tools_psf::get_val othf "flagastrom"]
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
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

      array unset ::tools_cata::cata_list_sav
      if {[info exists ::gui_cata::cata_list]} {
         array set ::tools_cata::cata_list_sav  [array get ::gui_cata::cata_list]
      }

   }













# Anciennement ::gui_cata::pop_img_list

   proc ::tools_cata::pop_img_list {  } {

      set ::tools_cata::img_list         $::tools_cata::img_list_sav
      set ::tools_cata::current_image    $::tools_cata::current_image_sav
      set ::tools_cata::id_current_image $::tools_cata::id_current_image_sav
      set ::tools_cata::create_cata      $::tools_cata::create_cata_sav

      array unset ::gui_cata::cata_list
      if {[info exists ::tools_cata::cata_list_sav]} {
         array set ::gui_cata::cata_list  [array get ::tools_cata::cata_list_sav]
      } 

   }















# Anciennement ::gui_cata::current_listsources_to_tklist



   proc ::tools_cata::current_listsources_to_tklist { } {

      set listsources $::tools_cata::current_listsources
      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      #gren_erreur "sources current_listsources_to_tklist=[lindex $sources {1 9 2 0}]\n"

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

         set ar ""
         set ac ""
         set pr ""
         set pc ""

         set x  [lsearch -index 0 $s "ASTROID"]
         if {$x>=0} {
            set othf [lindex [lindex $s $x] 2]           
            set ar [::bdi_tools_psf::get_val othf "flagastrom"]
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
            set pr [::bdi_tools_psf::get_val othf "flagphotom"]
            set pc [::bdi_tools_psf::get_val othf "cataphotom"]
            #gren_info "AR = $ar $ac $pr $pc\n"
         }

         foreach cata $s {
            #set a [lindex $cata 0]
            #if {$a == "ASTROID"} { gren_info "cata = $a\n" }
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
            #if {$a == "ASTROID"} { gren_info "line = $line\n" }
            #if {$a == "ASTROID"} { return }
            
         }

      }


   }





# Anciennement ::gui_cata::setCenterFromRADEC
   
   proc ::tools_cata::setCenterFromRADEC { } {

      set rd [regexp -inline -all -- {\S+} $::tools_cata::coord]
      set ra [lindex $rd 0]
      set dec [lindex $rd 1]
      set ::tools_cata::ra  $ra
      set ::tools_cata::dec $dec
      gren_info "SET CENTER FROM RA,DEC: $::tools_cata::ra $::tools_cata::dec\n"

   }

   

# Anciennement ::gui_cata::sendImageAndTable

   proc ::tools_cata::broadcastImageAndTable { } {

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
      set catafile [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
      set catafilename [string range $catafile 0 [expr [string last .gz $catafile] -1]]
      set catadir [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
      set cata [file join $bddconf(dirbase) $bddconf(dirtmp) $catafilename]

      set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]

      # Envoie du CATA dans Aladin via Samp
      if {$cataexist} {
         set ::votableUtil::votBuf(file) $cata
         ::SampTools::broadcastTable
      } else {
         gren_erreur "Cata does not exist. Broadcast to VO tools aborted."
      }

   }


# Anciennement ::gui_cata::set_aladin_script_params

   proc ::tools_cata::set_aladin_script_params { } {
   
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

   proc ::tools_cata::broadcastAladinScript { } {

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

   proc ::tools_cata::skybotResolver { } {

      set name $::tools_cata::coord
      set date $::tools_cata::current_image_date
      set uaicode [string trim $::tools_cata::uaicode]

      set erreur [ catch { vo_skybotresolver $date $name text basic $uaicode } skybot ]
      if { $erreur == "0" } {
         if { [ lindex $skybot 0 ] == "no" } {
            tk_messageBox -message "skybotResolver error: the solar system object '$name' was not resolved by SkyBoT" -type ok
         } else {
            set resp [split $skybot ";"]
            set respdata [split [lindex $resp 1] "|"]
            set ra [expr [lindex $respdata 2] * 15.0]
            set dec [lindex $respdata 3]
            if {$dec > 0} { set dec "+[string trim $dec]" }
            set ::tools_cata::coord "$ra $dec"
         }
      } else {
         tk_messageBox -message "skybotResolver error: $erreur : $skybot" -type ok
      }

   }


}
