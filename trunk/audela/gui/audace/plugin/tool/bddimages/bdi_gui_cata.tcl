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

      # Check button GUI

      if {! [info exists ::gui_cata::gui_img] } {
         if {[info exists conf(bddimages,cata,gui_img)]} {
            set ::gui_cata::gui_img $conf(bddimages,cata,gui_img)
         } else {
            set ::gui_cata::gui_img 1
         }
      }
      if {! [info exists ::gui_cata::gui_usnoa2] } {
         if {[info exists conf(bddimages,cata,gui_usnoa2)]} {
            set ::gui_cata::gui_usnoa2 $conf(bddimages,cata,gui_usnoa2)
         } else {
            set ::gui_cata::gui_usnoa2 1
         }
      }
      if {! [info exists ::gui_cata::gui_ucac2] } {
         if {[info exists conf(bddimages,cata,gui_ucac2)]} {
            set ::gui_cata::gui_ucac2 $conf(bddimages,cata,gui_ucac2)
         } else {
            set ::gui_cata::gui_ucac2 0
         }
      }
      if {! [info exists ::gui_cata::gui_ucac3] } {
         if {[info exists conf(bddimages,cata,gui_ucac3)]} {
            set ::gui_cata::gui_ucac3 $conf(bddimages,cata,gui_ucac3)
         } else {
            set ::gui_cata::gui_ucac3 0
         }
      }
      if {! [info exists ::gui_cata::gui_tycho2] } {
         if {[info exists conf(bddimages,cata,gui_tycho2)]} {
            set ::gui_cata::gui_tycho2 $conf(bddimages,cata,gui_tycho2)
         } else {
            set ::gui_cata::gui_tycho2 0
         }
      }
      if {! [info exists ::gui_cata::gui_nomad1] } {
         if {[info exists conf(bddimages,cata,gui_nomad1)]} {
            set ::gui_cata::gui_nomad1 $conf(bddimages,cata,gui_nomad1)
         } else {
            set ::gui_cata::gui_nomad1 0
         }
      }
      if {! [info exists ::gui_cata::gui_skybot] } {
         if {[info exists conf(bddimages,cata,gui_skybot)]} {
            set ::gui_cata::gui_skybot $conf(bddimages,cata,gui_skybot)
         } else {
            set ::gui_cata::gui_skybot 0
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
         if {[info exists conf(bddimages,cata,size_img)]} {
            set ::gui_cata::size_img $conf(bddimages,cata,size_img)
         } else {
            set ::gui_cata::size_img 1
         }
      }
      if {! [info exists ::gui_cata::size_usnoa2] } {
         if {[info exists conf(bddimages,cata,size_usnoa2)]} {
            set ::gui_cata::size_usnoa2 $conf(bddimages,cata,size_usnoa2)
         } else {
            set ::gui_cata::size_usnoa2 1
         }
      }
      if {! [info exists ::gui_cata::size_ucac2] } {
         if {[info exists conf(bddimages,cata,size_ucac2)]} {
            set ::gui_cata::size_ucac2 $conf(bddimages,cata,size_ucac2)
         } else {
            set ::gui_cata::size_ucac2 1
         }
      }
      if {! [info exists ::gui_cata::size_ucac3] } {
         if {[info exists conf(bddimages,cata,size_ucac3)]} {
            set ::gui_cata::size_ucac3 $conf(bddimages,cata,size_ucac3)
         } else {
            set ::gui_cata::size_ucac3 1
         }
      }
      if {! [info exists ::gui_cata::size_nomad1] } {
         if {[info exists conf(bddimages,cata,size_nomad1)]} {
            set ::gui_cata::size_nomad1 $conf(bddimages,cata,size_nomad1)
         } else {
            set ::gui_cata::size_nomad1 1
         }
      }
      if {! [info exists ::gui_cata::size_tycho2] } {
         if {[info exists conf(bddimages,cata,size_tycho2)]} {
            set ::gui_cata::size_tycho2 $conf(bddimages,cata,size_tycho2)
         } else {
            set ::gui_cata::size_tycho2 1
         }
      }
      if {! [info exists ::gui_cata::size_skybot] } {
         if {[info exists conf(bddimages,cata,size_skybot)]} {
            set ::gui_cata::size_skybot $conf(bddimages,cata,size_skybot)
         } else {
            set ::gui_cata::size_skybot 1
         }
      }
      if {! [info exists ::gui_cata::size_ovni] } {
         if {[info exists conf(bddimages,cata,size_ovni)]} {
            set ::gui_cata::size_ovni $conf(bddimages,cata,size_ovni)
         } else {
            set ::gui_cata::size_ovni 1
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











   proc ::gui_cata::fermer { } {

      global conf
      global action_label

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
       
      # Repertoires 
      set conf(astrometry,catfolder,usnoa2) $::tools_cata::catalog_usnoa2 
      set conf(astrometry,catfolder,ucac2)  $::tools_cata::catalog_ucac2  
      set conf(astrometry,catfolder,ucac3)  $::tools_cata::catalog_ucac3  
      set conf(astrometry,catfolder,tycho2) $::tools_cata::catalog_tycho2 
      set conf(astrometry,catfolder,nomad1) $::tools_cata::catalog_nomad1 

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
      set conf(astrometry,cata,keep_radec)             $::tools_cata::keep_radec
      set conf(astrometry,cata,create_cata)            $::tools_cata::create_cata
      set conf(astrometry,cata,delpv)                  $::tools_cata::delpv
      set conf(astrometry,cata,boucle)                 $::tools_cata::boucle
      set conf(astrometry,cata,deuxpasses)             $::tools_cata::deuxpasses
      set conf(astrometry,cata,limit_nbstars_accepted) $::tools_cata::limit_nbstars_accepted
      set conf(astrometry,cata,log)                    $::tools_cata::log


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
               break
            }
            if {$::tools_cata::id_current_image == $::tools_cata::nb_img_list} { break }
            ::gui_cata::next
         }

   }




   proc ::gui_cata::load_cata {  } {

      global bddconf


      set catafilenameexist [::bddimages_liste::lexist $::tools_cata::current_image "catafilename"]
      #gren_info "catafilenameexist = $catafilenameexist\n"
      if {$catafilenameexist==0} {return}

      set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
      #set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
      #gren_info "catafilename = $catafilename\n"
      #gren_info "catadirfilename = $catadirfilename\n"
         
      set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
      #gren_info "catafile = $catafile\n"
      set errnum [catch {set catafile [::tools_cata::extract_cata_xml $catafile]} msg ]
      if {$errnum} {
         return -code $errnum $msg
      }
      
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
      set ::tools_cata::current_listsources $listsources
   }



   proc ::gui_cata::affiche_cata { } {


      cleanmark
      set err [catch {

      #gren_info "\nAFFICHE_CATA\n"

      set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
      #gren_info "cataexist = $cataexist\n"
      if {$cataexist==0} {return}
      #gren_info "current_image = $::tools_cata::current_image\n"

      set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      #gren_info "cataexist = $cataexist\n"
      if {$cataexist!=1} {
         #gren_info "RETURN\n"
         return -code 0 "NOCATA"
      }
       
      if {[::bddimages_liste::lget $::tools_cata::current_image "cataexist"]=="1"} {
         
         #gren_info "LOAD CATA\n"
         ::gui_cata::load_cata
         
         #gren_info "current_listsources = $::tools_cata::current_listsources \n"
      } else {
         #::console::affiche_erreur "NO CATA\n"
         return -code 0 "NOCATA"
      }

      #gren_info "current_listsources = $::tools_cata::current_listsources \n"
      #::tools_sources::imprim_3_sources $::tools_cata::current_listsources USNOA2

      if { $::gui_cata::gui_img    } {
         #gren_info "OK\n"
         #gren_info "size_img = $::tools_cata::size_img\n"
         #gren_info "gui_img = $::gui_cata::gui_img\n"
         #gren_info "color_img = $::gui_cata::color_img\n"
         #gren_info "nb = [::tools_sources::get_nb_sources_by_cata $::tools_cata::current_listsources IMG ]\n"
         #::tools_sources::imprim_3_sources $::tools_cata::current_listsources USNOA2
         affich_rond $::tools_cata::current_listsources IMG $::gui_cata::color_img $::gui_cata::size_img }
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
         #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs \n"

         set err [catch {::tools_cata::get_wcs} msg]
         #gren_info "::tools_cata::get_wcs $err $msg \n"
         
         if {$err == 0 } {
            set newimg [::bddimages_liste_gui::file_to_img $filename $dirfilename]
            
            set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] [expr $::tools_cata::id_current_image-1] $newimg]
            
            set idbddimg    [::bddimages_liste::lget $newimg idbddimg]
            set tabkey      [::bddimages_liste::lget $newimg "tabkey"]
            set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
            #gren_info "idbddimg : $idbddimg   wcs : $bddimages_wcs  \n"

            set ::gui_cata::color_wcs $::gui_cata::color_button_good

            set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra         ] 1]
            set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec        ] 1]
            set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1   ] 1]
            set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2   ] 1]
            set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen     ] 1]
            set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE   ] 1]
            
            return true

         } else {
            # "idbddimg : $idbddimg   filename : $filename wcs : erreur \n"
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


   proc ::gui_cata::charge_current_image { } {

      global audace
      global bddconf

         #?Charge l image en memoire
         #gren_info "cur id $::tools_cata::id_current_image: \n"
         set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image - 1] ]
         set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]
         
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

         $::gui_cata::gui_dateimage configure -text $::tools_cata::current_image_date
         #gren_info "wcs : $date $::tools_cata::bddimages_wcs\n"
         #gren_info "\n\nTABKEY = $tabkey"
         #gren_info "$::tools_cata::id_current_image = date : $date  idbddimg : $idbddimg  file : $filename $::tools_cata::bddimages_wcs\n"

         #?Charge l image a l ecran
         #gren_info "\n ** LOAD ** charge_current_image\n"
         buf$::audace(bufNo) load $file
         ::confVisu::setFileName $::audace(visuNo) $file

         if { $::tools_cata::boucle == 0 } {
            #set cuts [buf$::audace(bufNo) autocuts]
            #gren_info "\n ** VISU ** charge_current_image\n"
            #::audace::autovisu $::audace(visuNo)
            ::gui_cata::affiche_current_image
            ::gui_cata::affiche_cata
            #visu$::audace(visuNo) disp [list [lindex $cuts 0] [lindex $cuts 1] ]
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
      #gren_info "nb images : $::tools_cata::nb_img_list\n"

      foreach ::tools_cata::current_image $::tools_cata::img_list {
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
         #gren_info "date : $date  idbddimg : $idbddimg\n"
      }

      # Chargement premiere image sans GUI
      #gren_info "* Premiere image :\n"
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
      #gren_info "$::tools_cata::id_current_image = date : $date  idbddimg : $idbddimg  file : $filename $::tools_cata::bddimages_wcs\n"

      #?Charge l image a l ecran
      #gren_info "\n ** LOAD ** \n"
      buf$::audace(bufNo) load $file
      #gren_info "\n ** VISU ** premiere image\n"
      #::audace::autovisu $::audace(visuNo)
      #visu$::audace(visuNo) disp

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
        gren_info "Resulta Test -> nb stars : $r\n"
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
      set url "http://skyview.gsfc.nasa.gov/cgi-bin/images?"
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
      #gren_info "DSS XY: $err : $rect : $msg\n"
      set err [ catch {set a [buf$::audace(bufNo) xy2radec $cent]} msg ]
      if {$err} {
         ::console::affiche_erreur "$err $msg\n"
         return
      }
      #gren_info "AD: $err : $a : $msg\n"
      set ::gui_cata::man_ad_star($i) "[lindex $a 0] [lindex $a 1]"

      return
      
   }
   proc ::gui_cata::manual_clean {  } {

      for {set i 1} {$i<=7} {incr i} {
         set ::gui_cata::man_xy_star($i) ""
         set ::gui_cata::man_ad_star($i) ""      
      }

   }

   proc ::gui_cata::manual_create {  } {

      set sources {}
      set fieldsastroid [list "IMG" [list "ra" "dec" "err_pos" "mag" "err_mag"] [list "x1" "y2" "xsm" "ysm"] ]

      # Coordonnees x,y du centre du champ comme objet Science
      set tabkey [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]
      set ra  [lindex [::bddimages_liste::lget $tabkey ra] 1]
      set dec [lindex [::bddimages_liste::lget $tabkey dec] 1]
      set xsc [expr [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1] / 2.0]
      set ysc [expr [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1] / 2.0]
      lappend sources [list [list "IMG" [list $ra $dec 0 0 0] [list $ra $dec $xsc $ysc]] [list "SCIENCE" {} {}]] 

      # Liste des etoiles pointees a la mano
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
      set listsources [list [list $fieldsastroid] $sources ]
      set listsources [::analyse_source::psf $listsources $::tools_astrometry::treshold $::tools_astrometry::delta]
      set ::tools_astrometry::current_image [::bddimages_liste::ladd $::tools_astrometry::current_image "listsources" $listsources]
      
      # Creation des fichiers Priam
      ::priam::create_file_oldformat "new" 1 $::tools_astrometry::current_image "SCIENCE" "IMG"
      
      set ::tools_astrometry::img_list [list $::tools_astrometry::current_image]
      ::tools_astrometry::extract_priam_result [::tools_astrometry::launch_priam]
      

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



   proc ::gui_cata::creation_cata { img_list } {

      global audace
      global bddconf

      ::gui_cata::charge_list $img_list
      ::gui_cata::inittoconf
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
            
            $onglets.nb add $f1 -text "Catalogues"
            $onglets.nb add $f2 -text "Variables"
            $onglets.nb add $f3 -text "Entete"
            $onglets.nb add $f4 -text "Couleurs"
            $onglets.nb add $f5 -text "Sextractor"
            $onglets.nb add $f6 -text "Interop"
            $onglets.nb add $f7 -text "Manuel"
            $onglets.nb add $f8 -text "Develop"
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
             checkbutton $tycho2.check -highlightthickness 0 -text "tycho2" -variable ::tools_cata::use_tycho2
             pack $tycho2.check -in $tycho2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $tycho2.dir -relief sunken -textvariable ::tools_cata::catalog_tycho2 -width 30
             pack $tycho2.dir -in $tycho2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac2
        set ucac2 [frame $f1.ucac2 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac2 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac2.check -highlightthickness 0 -text "ucac2" -variable ::tools_cata::use_ucac2
             pack $ucac2.check -in $ucac2 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac2.dir -relief sunken -textvariable ::tools_cata::catalog_ucac2 -width 30
             pack $ucac2.dir -in $ucac2 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher ucac3
        set ucac3 [frame $f1.ucac3 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac3 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $ucac3.check -highlightthickness 0 -text "ucac3" -variable ::tools_cata::use_ucac3
             pack $ucac3.check -in $ucac3 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $ucac3.dir -relief sunken -textvariable ::tools_cata::catalog_ucac3 -width 30
             pack $ucac3.dir -in $ucac3 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher nomad1
        set nomad1 [frame $f1.nomad1 -borderwidth 0 -cursor arrow -relief groove]
        pack $nomad1 -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $nomad1.check -highlightthickness 0 -text "nomad1" -variable ::tools_cata::use_nomad1 -state disabled
             pack $nomad1.check -in $nomad1 -side left -padx 5 -pady 0
             #--- Cree un entry
             entry $nomad1.dir -relief sunken -textvariable ::tools_cata::catalog_nomad1 -width 30
             pack $nomad1.dir -in $nomad1 -side right -pady 1 -anchor w
  
        #--- Cree un frame pour afficher boucle
        set skybot [frame $f1.skybot -borderwidth 0 -cursor arrow -relief groove]
        pack $skybot -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $skybot.check -highlightthickness 0 -text "Utiliser SkyBot" -variable ::tools_cata::use_skybot
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
             label $limit_nbstars.lab -text "limite acceptable du nb d'etoiles identifiees : " 
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

            button $f3.setval -text "Set Val" -borderwidth 2 -takefocus 1 \
              -command "::gui_cata::setval"
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
                      -variable ::gui_cata::gui_img -state normal \
                      -command "::gui_cata::affiche_cata"
                pack $img.check -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.name -text "IMG : " -width 7
                pack $img.name -in $img -side left -padx 3 -pady 3 -anchor w 
                label $img.val -textvariable ::tools_cata::nb_img
                pack $img.val -in $img -side left -padx 3 -pady 3
                button $img.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_img -command ""
                pack $img.color -side left -anchor e -expand 0 
                spinbox $img.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "::gui_cata::affiche_cata" -width 3 \
                      -textvariable ::tools_cata::size_img
                pack  $img.radius -in $img -side left -anchor w

           #--- Cree un frame pour afficher USNOA2
           set usnoa2 [frame $count.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
           pack $usnoa2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $usnoa2.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_usnoa2 -state normal \
                      -command "::gui_cata::affiche_cata"
                pack $usnoa2.check -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.name -text "USNOA2 : " -width 7
                pack $usnoa2.name -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
                label $usnoa2.val -textvariable ::tools_cata::nb_usnoa2
                pack $usnoa2.val -in $usnoa2 -side left -padx 3 -pady 3
                button $usnoa2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_usnoa2 -command ""
                pack $usnoa2.color -side left -anchor e -expand 0 
                spinbox $usnoa2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $usnoa2.radius -in $usnoa2 -side left -anchor w

           #--- Cree un frame pour afficher UCAC2
           set ucac2 [frame $count.ucac2 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac2.check -highlightthickness 0  \
                      -variable ::gui_cata::gui_ucac2 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $ucac2.check -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.name -text "UCAC2 : " -width 7
                pack $ucac2.name -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
                label $ucac2.val -textvariable ::tools_cata::nb_ucac2
                pack $ucac2.val -in $ucac2 -side left -padx 3 -pady 3
                button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac2 -command ""
                pack $ucac2.color -side left -anchor e -expand 0 
                spinbox $ucac2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $ucac2.radius -in $ucac2 -side left -anchor w

           #--- Cree un frame pour afficher UCAC3
           set ucac3 [frame $count.ucac3 -borderwidth 0 -cursor arrow -relief groove]
           pack $ucac3 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $ucac3.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_ucac3 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $ucac3.check -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.name -text "UCAC3 : " -width 7
                pack $ucac3.name -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
                label $ucac3.val -textvariable ::tools_cata::nb_ucac3
                pack $ucac3.val -in $ucac3 -side left -padx 3 -pady 3
                button $ucac3.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_ucac3 -command ""
                pack $ucac3.color -side left -anchor e -expand 0 
                spinbox $ucac3.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $ucac3.radius -in $ucac3 -side left -anchor w

           #--- Cree un frame pour afficher TYCHO2
           set tycho2 [frame $count.tycho2 -borderwidth 0 -cursor arrow -relief groove]
           pack $tycho2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $tycho2.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_tycho2 -state normal \
                      -command "::gui_cata::affiche_cata"
                pack $tycho2.check -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.name -text "TYCHO2 : " -width 7
                pack $tycho2.name -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
                label $tycho2.val -textvariable ::tools_cata::nb_tycho2
                pack $tycho2.val -in $tycho2 -side left -padx 3 -pady 3
                button $tycho2.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_tycho2 -command ""
                pack $tycho2.color -side left -anchor e -expand 0 
                spinbox $tycho2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $tycho2.radius -in $tycho2 -side left -anchor w

           #--- Cree un frame pour afficher NOMAD1
           set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
           pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $nomad1.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_nomad1 -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $nomad1.check -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.name -text "NOMAD1 : " -width 7
                pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
                label $nomad1.val -textvariable ::tools_cata::nb_nomad1
                pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
                button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_nomad1 -command ""
                pack $nomad1.color -side left -anchor e -expand 0 
                spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -command "" -width 3
                pack  $nomad1.radius -in $nomad1 -side left -anchor w


           #--- Cree un frame pour afficher NOMAD1
           set skybot [frame $count.skybot -borderwidth 0 -cursor arrow -relief groove]
           pack $skybot -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                checkbutton $skybot.check -highlightthickness 0 \
                      -variable ::gui_cata::gui_skybot -state normal  \
                      -command "::gui_cata::affiche_cata"
                pack $skybot.check -in $skybot -side left -padx 3 -pady 3 -anchor w 
                label $skybot.name -text "SKYBOT : " -width 7
                pack $skybot.name -in $skybot -side left -padx 3 -pady 3 -anchor w 
                label $skybot.val -textvariable ::tools_cata::nb_skybot
                pack $skybot.val -in $skybot -side left -padx 3 -pady 3
                button $skybot.color -borderwidth 0 -takefocus 1 -bg $::gui_cata::color_skybot -command ""
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
                         -command "::gui_cata::test_confsex" -text "Test"
                     pack    $confsex.buttons.test  -side left -anchor e -expand 0 
                     button  $confsex.buttons.save  -borderwidth 1  \
                         -command "::gui_cata::set_confsex" -text "Save"
                     pack    $confsex.buttons.save  -side left -anchor e -expand 0 

                #--- Cree un label pour le titre
                text $confsex.file 
                pack $confsex.file -in $confsex -side top -padx 3 -pady 3 -anchor w 

                ::gui_cata::get_confsex


        #--- Cree un frame pour afficher 
        set interop [frame $f6.interop -borderwidth 0 -cursor arrow -relief groove]
        pack $interop -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
  
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
                 button $r.resolve -text "Resolve Sso" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 -command "::gui_cata::skybotResolver"
                 pack $r.resolve -side top -anchor e -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0
                 button $r.aladin -text "Show in Aladin" -borderwidth 0 -takefocus 1 -relief groove -borderwidth 1 -command "::gui_cata::sendAladinScript" 
                 pack $r.aladin -side top -anchor e -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

        #--- Cree un frame pour afficher 
        set manuel [frame $f7.manuel -borderwidth 0 -cursor arrow -relief groove]
        pack $manuel -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

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

                     set minfo [frame $manuel.entr.info -borderwidth 1 -cursor arrow]
                     pack $minfo -in $manuel.entr -side top -pady 5
                     
                          set mode_manuel "Selectionner une source en dessinant un carre dans l'image a reduire, et selectionner de meme l'etoile correspondante dans l'image DSS, puis cliquer sur le bouton GRAB.\n"
                          text $minfo.txt -wrap word -width 50 -height 4 -relief groove
                          $minfo.txt insert 1.0 $mode_manuel
                          pack  $minfo.txt -in $minfo -side left -expand 0 -fill both -padx 10

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


                frame $manuel.entr.buttons -borderwidth 0 -cursor arrow -relief groove
                pack $manuel.entr.buttons  -in $manuel.entr  -side top 
                
                     button  $manuel.entr.buttons.efface  -borderwidth 1  \
                         -command "::gui_cata::manual_clean" -text "Effacer tout"
                     pack    $manuel.entr.buttons.efface -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     button  $manuel.entr.buttons.creer  -borderwidth 1  \
                         -command "::gui_cata::manual_create" -text "Creer"
                     pack    $manuel.entr.buttons.creer -in $manuel.entr.buttons -side left -anchor e -expand 0 


        #--- Cree un frame pour afficher l onglet develop
        set develop [frame $f8.develop -borderwidth 0 -cursor arrow -relief groove]
        pack $develop -in $f8 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

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

