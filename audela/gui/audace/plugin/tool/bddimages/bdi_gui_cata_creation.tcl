## @file bdi_gui_cata_creation.tcl
# @brief     Methodes dediees a la GUI de creation des fichiers catalogues
# @author    Frederic Vachier and Jerome Berthier 
# @version   1.0
# @date      2013
# @copyright GNU Public License.
# @par Ressource 
# @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cata_creation.tcl]
# @endcode

# Mise à jour $Id: bdi_gui_cata_creation.tcl 9215 2013-03-15 15:36:44Z jberthier $

#============================================================
## Declaration du namespace \c gui_cata_creation .
# @brief     Affichage du statut et reinitialisation des bases de donnees bddimages
# @pre       Requiert bdi_tools_xml 1.0 et bddimagesAdmin 1.0
# @warning   Pour developpeur seulement
#
namespace eval gui_cata_creation {

   package require vo_tools 2.0

   variable default_conf_sex [file join $audace(rep_plugin) tool bddimages config config.sex]
   variable user_conf_sex [file join $audace(rep_home) bddimages_config.sex]

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_creation.cap ]\""

   #--- Init la variable de listenner pour le bouton Interop
   set ::vo_tools::interop($::audace(visuNo),interopListenner) ""


   #------------------------------------------------------------
   ## Initialisation des parametres de la GUI creation du cata
   # @return void
   #
   proc ::gui_cata_creation::inittoconf {  } {

      global conf

      # Initialisation au niveau GUI cata
      ::gui_cata::inittoconf

      # Lib du compilateur Fortran pour executer Priam
      if {! [info exists ::tools_astrometry::ifortlib] } {
         if {[info exists conf(bddimages,cata,ifortlib)]} {
            set ::tools_astrometry::ifortlib $conf(bddimages,cata,ifortlib)
         } else {
            set ::tools_astrometry::ifortlib "/opt/intel/lib/intel64"
         }
      }

   }



   #------------------------------------------------------------
   ## Affectation des variables de conf en sortie de la GUI craetion cata
   # @return void
   #
   proc ::gui_cata_creation::closetoconf { } {

      ::gui_cata::closetoconf

   }



   #------------------------------------------------------------
   ## Actions a la sortie de la GUI creation cata
   # @return void
   #
   proc ::gui_cata_creation::fermer { } {

      global conf action_label

      # Fermeture de cette GUI
      ::gui_cata_creation::closetoconf
      # Destruction de la fenetre
      ::gui_cata_creation::recup_position
      destroy $::gui_cata_creation::fen
      # Rechargement des listes
      ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark

   }



   #------------------------------------------------------------
   ## Recuperation de la position d'affichage de la GUI
   #  @return void
   #
   proc ::gui_cata_creation::recup_position { } {
   
      global conf bddconf
   
      set bddconf(geometry_creation_cata) [wm geometry $::gui_cata_creation::fen]
      set conf(bddimages,geometry_creation_cata) $bddconf(geometry_creation_cata)
   
   }



   #------------------------------------------------------------
   ## Defini les coordonnees RA,DEC du centre de l'image
   # @return void
   #
   proc ::gui_cata_creation::setval { } {

      set ::tools_cata::ra_save  $::tools_cata::ra
      set ::tools_cata::dec_save $::tools_cata::dec

      set err [ catch {set rect [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect ==""} {
         gren_info "Coordinates of image center: $::tools_cata::ra_save, $::tools_cata::dec_save\n"
         return
      }
      set xcent [format "%0.0f" [expr ([lindex $rect 0] + [lindex $rect 2])/2.]  ]   
      set ycent [format "%0.0f" [expr ([lindex $rect 1] + [lindex $rect 1])/2.]  ]   
      set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
      if {$err} {
         gren_erreur "Error gui_cata_creation::setval: $err -> $msg\n"
         return
      }
      set ::tools_cata::ra_save  [lindex $a 0]
      set ::tools_cata::dec_save [lindex $a 1]
      gren_info "Set new coordinates of image center to $::tools_cata::ra_save, $::tools_cata::dec_save\n"

   }



   #------------------------------------------------------------
   ## Reset les coordonnees du centre de l'image (a partir des valeurs initiales)
   # @return void
   #
   proc ::gui_cata_creation::resetcenter { } {

      set ::tools_cata::ra  $::tools_cata::ra_save
      set ::tools_cata::dec $::tools_cata::dec_save
      gren_info "Reset coordinates of image center to $::tools_cata::ra $::tools_cata::dec\n"
   
   }



   #------------------------------------------------------------
   ## Identification des sources et affichage des catas
   # @return void
   #
   proc ::gui_cata_creation::get_cata { } {

         $::gui_cata::gui_create configure -state disabled
         $::gui_cata::gui_fermer configure -state disabled

         if { $::tools_cata::boucle == 1 } {

            ::gui_cata_creation::get_all_cata

         }  else {

            cleanmark
            if {[::gui_cata_creation::get_one_wcs] == true} {
            
               set ::gui_cata::color_wcs $::gui_cata::color_button_good
               $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
            
               if {[::tools_cata::get_cata] == false} {
                  # TODO ::gui_cata_creation::get_cata : gerer l'erreur le  cata a echou?
                  set ::gui_cata::color_cata $::gui_cata::color_button_bad
                  $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata
                  #return false
               } else {
                  set ::gui_cata::color_cata $::gui_cata::color_button_good
                  $::gui_cata::gui_cata configure -bg $::gui_cata::color_cata

                  # Affiche le cata
                  ::gui_cata::affiche_cata

                  # Trace du repere E/N dans l'image
                  set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
                  set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
                  set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
                  ::gui_cata::trace_repere [list $cdelt1 $cdelt2]
               }
            } else {
               # TODO ::gui_cata_creation::get_cata : gerer l'erreur le wcs a echou?
               set ::gui_cata::color_wcs $::gui_cata::color_button_bad
               $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
               cleanmark
            }

         }
         $::gui_cata::gui_create configure -state normal
         $::gui_cata::gui_fermer configure -state normal

   }



   #------------------------------------------------------------
   ## Identification des sources et affichage des catas en boucle continue
   # @return void
   #
   proc ::gui_cata_creation::get_all_cata { } {

      cleanmark
      while {1==1} {
         if { $::tools_cata::boucle == 0 } {
            break
         }
         if {[::gui_cata_creation::get_one_wcs] == true} {
             
            set ::gui_cata::color_wcs $::gui_cata::color_button_good
            $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
            if {[::tools_cata::get_cata] == false} {
               # TODO ::gui_cata_creation::get_all_cata : gerer l'erreur le  cata a echou?
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
               # Trace du repere E/N dans l'image
               set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
               set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
               set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
               ::gui_cata::trace_repere [list $cdelt1 $cdelt2]
            }
         } else {
            # TODO ::gui_cata_creation::get_all_cata : gerer l'erreur le wcs a echou?
            set ::gui_cata::color_wcs $::gui_cata::color_button_bad
            $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
            cleanmark
            ::gui_cata::affiche_current_image
            break
         }
         if {$::tools_cata::id_current_image == $::tools_cata::nb_img_list} { break }
         ::gui_cata_creation::next
      }

   }



   #------------------------------------------------------------
   ## Determination d'une solution astrometrique preliminaire de l'image sur la base des WCS
   # @return void
   #
   proc ::gui_cata_creation::get_one_wcs { } {

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
            gren_erreur "Error: ::gui_cata_creation::get_one_wcs: $msg  [ idbddimg : $idbddimg ] [ filename : $filename ]\n"
            set ::gui_cata::color_wcs $::gui_cata::color_button_bad
            set ::tools_cata::boucle 0
            return false
         }
   }



   #------------------------------------------------------------
   ## Chargement de l'image courante et de son cata
   # @return void
   #
   proc ::gui_cata_creation::charge_current_image { } {

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
         if {$scale_x=="" || $scale_y == ""} {
            set ::tools_cata::radius 20
         } else {
            set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
         }
         
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
            set err [catch {::gui_cata::affiche_cata} msg ]
            if {$err} {
               gren_erreur "Erreur d'affichage du CATA\n"
               gren_erreur "err = $err\n"
               gren_erreur "msg = $msg\n"
               set cataexist 0
            }
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



   #------------------------------------------------------------
   ## Chargement de la liste des images, et affichage de la premiere image + cata
   # @return void
   #
   proc ::gui_cata_creation::charge_list { img_list } {

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
      if {$scale_x=="" || $scale_y == ""} {
         set ::tools_cata::radius 20
      } else {
         set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
      }
      set xcent [expr $naxis1/2.0]
      set ycent [expr $naxis2/2.0]

      set ::tools_cata::current_image_name $filename
      set ::tools_cata::current_image_date $date

      #?Charge l image a l ecran
      buf$::audace(bufNo) load $file

      set ::tools_cata::nb_img     0
      set ::tools_cata::nb_usnoa2  0
      set ::tools_cata::nb_tycho2  0
      set ::tools_cata::nb_ucac2   0
      set ::tools_cata::nb_ucac3   0
      set ::tools_cata::nb_ucac4   0
      set ::tools_cata::nb_ppmx    0
      set ::tools_cata::nb_ppmxl   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_2mass   0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0
      affich_un_rond_xy $xcent $ycent red 2 2
      ::gui_cata::affiche_current_image
      set err [catch {::gui_cata::affiche_cata} msg ]
      if {$err} {
         gren_erreur "Erreur d'affichage du CATA\n"
         gren_erreur "err = $err\n"
         gren_erreur "msg = $msg\n"
         set cataexist 0
      }

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

   }



   #------------------------------------------------------------
   ## Charge la config Sextractor par defaut 
   # @return void
   #
   proc ::gui_cata_creation::get_default_confsex { } {

      global audace

      # Verifie que le fichier utilisateur de la config sextractor existe
      # s'il n'existe pas, copie depuis le fichier par defaut config/config.sex
      if { ! [file exists $::gui_cata_creation::user_conf_sex]} {
         set err [catch {file copy $::gui_cata_creation::default_conf_sex $::gui_cata_creation::user_conf_sex} msg ]
         if {$err != 0} {
            gren_erreur "Error: gui_cata_creation::get_default_confsex: cannot copy config.sex file to Audace user home dir\n"
            return $err
         }
      }

      # Lecture et affichage du fichier de config Sextractor
      set chan [open $::gui_cata_creation::user_conf_sex r]
      while {[gets $chan line] >= 0} {
         $::gui_cata_creation::fen.frm_creation_cata.onglets.nb.f5.confsex.file insert end "$line\n"
      }
      close $chan

   }



   #------------------------------------------------------------
   ## Charge la config Sextractor a partir de la zone de texte editable (onglet Sextractor)
   # @return void
   #
   proc ::gui_cata_creation::set_user_confsex { } {

      global audace

      set r [$::gui_cata_creation::fen.frm_creation_cata.onglets.nb.f5.confsex.file get 1.0 end]
      # Sauve la config Sextractor dans le fichier utilisateur
      set chan [open "$::gui_cata_creation::user_conf_sex" "w"]
      puts $chan $r
      close $chan
      # Copie la config dans le rep de travail
      set err [catch {file copy -force $::gui_cata_creation::user_conf_sex "./config.sex"} msg ]
      if {$err != 0} {
         gren_erreur "Error: gui_cata_creation::set_user_confsex: cannot copy $::gui_cata_creation::user_conf_sex to work dir (./config.sex)\n"
         gren_erreur "$err ; $msg\n" 
         return $err
      }

   }



   #------------------------------------------------------------
   ## Test la config Sextractor a partir de la zone de texte editable (onglet Sextractor)
   # @return void
   #
   proc ::gui_cata_creation::test_user_confsex { } {

      gren_info "Test Sextractor ...\n"
      cleanmark
      ::gui_cata_creation::set_user_confsex 

      # Calib WCS
      set err [catch {calibwcs * * * * * USNO $::tools_cata::catalog_usnoa2 -del_tmp_files 0 -yes_visu 0} msg]
      if {$err} {
         gren_erreur "  Error #$err -> $msg\n"
      } else {
         gren_info "  Nb stars detected = $msg\n"

         ## Lecture des sources depuis le fichier obs.lst
         #set chan [open "./obs.lst" "r"]
         #while {[gets $chan line] >= 0} {
         #   set cpt 0
         #   foreach x [split $line " "] {
         #      if {$x != ""} {
         #         if {$cpt == 0} {set xi $x}
         #         if {$cpt == 1} {set yi $x}
         #         incr cpt
         #      }
         #   }
         #   affich_un_rond_xy $xi $yi "green" 3 1
         #}
         #close $chan
   
         array set color { 1 green 2 blue 3 red}
         gren_info "  Display ascii.txt:\n"
         gren_info "   * green = Sextractor extracted sources (code 1)\n"
         gren_info "   * blue = Sources identified as USNOA2 stars (code 2)\n"
         gren_info "   * red = Rejected sources (code 3)\n"
         # Lecture des sources depuis le fichier obs.lst
         set chan [open "./ascii.txt" "r"]
         while {[gets $chan line] >= 0} {
            set cpt 0
            foreach x [split $line " "] {
               if {$x != ""} {
                  if {$cpt == 1} {set ci $color($x)}
                  if {$cpt == 2} {set xi $x}
                  if {$cpt == 3} {set yi $x}
                  incr cpt
               }
            }
            affich_un_rond_xy $xi $yi $ci 3 2
         }
         close $chan

      }

   }



   #------------------------------------------------------------
   ## Grab une portion de la visu et une portion de la visu DSS pour
   # selectionner une source et sa reference
   # @return void
   #
   proc ::gui_cata_creation::grab { i } {

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez selectionner une etoile en dessinant un carre dans l'image a reduire" -type ok
         return
      }
      set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
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
         gren_erreur "Error: gui_cata_creation::grab: $err -> $msg\n"
         return
      }
      set ::gui_cata::man_ad_star($i) "[lindex $a 0] [lindex $a 1]"

   }



   #------------------------------------------------------------
   ## Nettoie la table des sources et de leurs references dans
   # le mode manuel de creation du cata
   # @return void
   #
   proc ::gui_cata_creation::manual_clean {  } {

      for {set i 1} {$i<=7} {incr i} {
         set ::gui_cata::man_xy_star($i) ""
         set ::gui_cata::man_ad_star($i) ""      
      }

   }



   #------------------------------------------------------------
   ## Affiche dans la visu les sources selectionnees pour 
   # le mode manuel de creation du cata
   # @return void
   #
   proc ::gui_cata_creation::manual_view {  } {

      for {set i 1} {$i<=7} {incr i} {
         if {$::gui_cata::man_xy_star($i) != "" && $::gui_cata::man_ad_star($i) != ""} {
            set x [split $::gui_cata::man_xy_star($i) " "]
            set xsm [lindex $x 0]
            set ysm [lindex $x 1]
            affich_un_rond_xy  $xsm $ysm "blue" 5 2
         }
      }

   }



   #------------------------------------------------------------
   ## ???
   # 
   # @return void
   #
   proc ::gui_cata_creation::manual_fit {  } {


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

      cleanmark
      ::gui_cata_creation::manual_view

   }



   #------------------------------------------------------------
   ## Creation de la calibration WCS d'une image en mode manuel,
   # a partir des etoiles (et de leurs references) definies dans
   # la GUI (onglet Manuel). L'astrometrie est calculee par Priam.
   # @return void
   #
   proc ::gui_cata_creation::manual_create_wcs {  } {

      global bddconf

      ::tools_cata::push_img_list
      $::gui_cata::gui_enrimg configure -state disabled
      $::gui_cata::gui_creercata configure -state disabled
      
      gren_info "Creation Manuelle du WCS\n"

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
      
      gren_info "     Mesure des PSF\n"
      
      ::psf_gui::psf_listsources_no_auto listsources $::psf_tools::psf_threshold $::psf_tools::psf_radius $::psf_tools::psf_saturation
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

      if {[::bddimages_liste::lexist $::tools_cata::current_image "listsources" ]==0} {
         set ::tools_cata::current_image [::bddimages_liste::ladd $::tools_cata::current_image "listsources" $listsources]
      } else {
         set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "listsources" $listsources]
      }
      
      set ::tools_astrometry::reference ""

      # Creation des fichiers et lancement de Priam
      gren_info "     Creation des fichiers et lancement de Priam\n"
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

      set err [catch {::priam::create_file_oldformat "new" 1 ::tools_cata::current_image listsources } msg ]

      if {$err} {
         gren_erreur "Error: gui_cata_creation::manual_create_wcs: impossible de creer le fichier Priam: $err -> $msg\n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::tools_cata::pop_img_list
         return
      }

      set ::tools_cata::img_list [list $::tools_cata::current_image]

      set err [catch {
          set ::tools_astrometry::last_results_file [::priam::launch_priam]
          gren_info "new Priam file: $::tools_astrometry::last_results_file\n"
          ::tools_astrometry::extract_priam_results $::tools_astrometry::last_results_file
      } msg ]
      
      if {$err} {
         gren_erreur "Error: gui_cata_creation::manual_create_wcs: calcul WCS en erreur: $err ->  $msg\n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::tools_cata::pop_img_list
         return
      }

      set ::tools_cata::current_listsources $::gui_cata::cata_list(1)
      ::manage_source::imprim_3_sources $::tools_cata::current_listsources

      # WCS dans l image

      set filename [::bddimages_liste::lget $::tools_cata::current_image filename]
      set filename [string range $filename 0 [expr [string last .gz $filename] -1]]
      set file [file join $bddconf(dirtmp) $filename]
      set key [list "BDDIMAGES WCS" "Y" "string" "Y | N | ? (WCS performed)" ""]
      buf$::audace(bufNo) setkwd $key
      saveima $file
      loadima $file

      gren_info "     Enregistrement du WCS dans l'image $file\n"

      # Obtention du nouvel header
      set err [catch {set tabkey [::bdi_tools_image::get_tabkey_from_buffer] } msg ]
      if {$err} {
         gren_erreur "Error: gui_cata_creation::manual_create_wcs: tabkey non charge: $err -> $msg\n"
         set ::gui_cata::color_wcs $::gui_cata::color_button_bad
         $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
         ::tools_cata::pop_img_list
         return
      }

      ::tools_cata::pop_img_list

      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]
      set ::gui_cata::color_wcs $::gui_cata::color_button_good

      $::gui_cata::gui_wcs configure -bg $::gui_cata::color_wcs
      $::gui_cata::gui_enrimg configure -state normal
      $::gui_cata::gui_creercata configure -state normal

   }



   #------------------------------------------------------------
   ## Creation des cata d'une image en mode manuel.
   # @return void
   #
   proc ::gui_cata_creation::manual_create_cata {  } {

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
      ::gui_cata_creation::set_user_confsex
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



   #------------------------------------------------------------
   ## Insertion d'une image dans la bdd en mode manuel.
   # @return void
   #
   proc ::gui_cata_creation::manual_insert_img {  } {
   
      global bddconf
   
      set log 1

      set idbddimg [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]
      set imgfilename [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set dirimgfilename [::bddimages_liste::lget $::tools_cata::current_image "dirfilename"]
      set imgfilebase [file join $bddconf(dirbase) $dirimgfilename $imgfilename]

      set imgfilename [unzipedfilename $imgfilename]
      set imgfiletmp [file join $bddconf(dirtmp) $imgfilename]
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



   #------------------------------------------------------------
   ## Fonction d'acces a plusieurs actions, dediee au developpement.
   # @param tag string Mot cle designant l'action: box | all | 3sources
   # @return void
   #
   proc ::gui_cata_creation::develop { tag } {

      switch $box {

         "box" {
            set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
            if {$err>0 || $rect ==""} {
               tk_messageBox -message "Veuillez selectionner un carre dans l'image" -type ok
               return
            }
            set l [::manage_source::extract_sources_by_array $rect $::tools_cata::current_listsources]
            ::manage_source::imprim_all_sources $l
         }

         "all" {
            ::manage_source::imprim_all_sources $::tools_cata::current_listsources
         }

         "3sources" {
            ::manage_source::imprim_3_sources $::tools_cata::current_listsources
         }

      }

   }



   #------------------------------------------------------------
   ## Affiche l'image suivante
   # @return void
   #
   proc ::gui_cata_creation::next { } {

         if {$::tools_cata::id_current_image < $::tools_cata::nb_img_list} {
            incr ::tools_cata::id_current_image
            catch {unset ::tools_cata::current_listsources}
            ::gui_cata_creation::charge_current_image
         }

   }



   #------------------------------------------------------------
   ## Affiche l'image precedente
   # @return void
   #
   proc ::gui_cata_creation::back { } {

         if {$::tools_cata::id_current_image > 1 } {
            incr ::tools_cata::id_current_image -1
            catch {unset ::tools_cata::current_listsources}
            ::gui_cata_creation::charge_current_image
         }
   }



   #------------------------------------------------------------
   ## Change le statut des elements des options de creation du cata Astroid (mesures de PSF)
   # @param this string pathName des elements de GUI concernes par un changement de statut
   # @return void
   #
   proc ::gui_cata_creation::handlePSFParams { this } {

      if {$::psf_tools::use_psf} {
         $this.opts.saturation.val   configure -state normal
         $this.opts.delta.val        configure -state normal
         $this.methglobale.check     configure -state normal
         $this.opts2.threshold.val   configure -state normal
         $this.opts2.limitradius.val configure -state normal
         if {$::psf_tools::use_global} {
            $this.opts2.threshold.val   configure -state normal
            $this.opts2.limitradius.val configure -state normal
            $this.opts.delta.val        configure -state disabled
         } else {
            $this.opts2.threshold.val   configure -state disabled
            $this.opts2.limitradius.val configure -state disabled
            $this.opts.delta.val        configure -state normal
         }
      } else {
         $this.opts.saturation.val   configure -state disabled
         $this.opts.delta.val        configure -state disabled
         $this.methglobale.check     configure -state disabled
         $this.opts2.threshold.val   configure -state disabled
         $this.opts2.limitradius.val configure -state disabled
      }

   }



   #------------------------------------------------------------
   ## Creation du menu Audace->Interop, et gestion de l'etat des boutons de broadcast
   # @param w string pathName contenant le bouton interop (w.menu) et les boutons a gerer (w.action.imgtab, w.action.script)
   # @return void
   #
   proc ::gui_cata_creation::startInterop { } {

      set w $::gui_cata_creation::votoolsmenu

      set err [ catch {::vo_tools::InstallMenuInterop $w} msg ]
      if {$err == 1} {
         gren_erreur "Warning: gui_cata_creation::startInterop: $msg\n"
      }

      ::gui_cata_creation::handleVOButtons

   }



   #------------------------------------------------------------
   ## Gestion de l'etat des boutons de broadcast vers les outils VO
   # @param w string pathName des boutons a gerer (w.action.imgtab, w.action.script)
   # @return void
   #
   proc ::gui_cata_creation::handleVOButtons { args } {

      global audace

      if {$args ne "disabled"} {

         # Bouton Interop
         set w $::gui_cata_creation::votoolsmenu
         set err [catch {MenuGet $::audace(visuNo) "Interop"} msg]
         if {! $err} {
            pack forget $w
         } else {
            pack $w
         }

         # Boutons action
         set w $::gui_cata_creation::votoolsaction
         set but [list $w.broadcast $w.script]
         foreach b $but {
            if {[::Samp::isConnected]} {
               $b configure -state active
            } else {
               $b configure -state disable
            }
         }

      }

   }



   #------------------------------------------------------------
   ## GUI principale de creation des fichiers catalogues d'un lot d'images
   # @param img_list list Liste des images (\sa charge_list).
   # @return void
   #
   proc ::gui_cata_creation::go { img_list } {

      global audace caption 
      global conf bddconf

      ::gui_cata_creation::charge_list $img_list
      catch { ::tools_cata::set_aladin_script_params }

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_creation_cata) ] } {
         set conf(bddimages,geometry_creation_cata) "+100+100"
      }
      set bddconf(geometry_creation_cata) $conf(bddimages,geometry_creation_cata)

      #--- Creation de la fenetre
      set ::gui_cata_creation::fen .new
      if { [winfo exists $::gui_cata_creation::fen] } {
         wm withdraw $::gui_cata_creation::fen
         wm deiconify $::gui_cata_creation::fen
         focus $::gui_cata_creation::fen
         return
      }

      #--- GUI
      toplevel $::gui_cata_creation::fen -class Toplevel
      wm geometry $::gui_cata_creation::fen $bddconf(geometry_creation_cata)
      wm resizable $::gui_cata_creation::fen 1 1
      wm title $::gui_cata_creation::fen "$caption(gui_cata_creation,title)"
      wm protocol $::gui_cata_creation::fen WM_DELETE_WINDOW "::gui_cata_creation::fermer"

      set frm $::gui_cata_creation::fen.frm_creation_cata

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata_creation::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame pour les ACTIONS
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
             set ::gui_cata::gui_back [button $actions.back -text "$caption(gui_cata_creation,prec)" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata_creation::back" -state $::gui_cata::stateback]
             pack $actions.back -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
             set ::gui_cata::gui_next [button $actions.next -text "$caption(gui_cata_creation,next)" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata_creation::next" -state $::gui_cata::statenext]
             pack $actions.next -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
             set ::gui_cata::gui_create [button $actions.go -text "$caption(gui_cata_creation,create)" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata_creation::get_cata" -state normal]
             pack $actions.go -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
             set ::gui_cata::gui_stimage [label $actions.stimage -text "$::tools_cata::id_current_image / $::tools_cata::nb_img_list"]
             pack $::gui_cata::gui_stimage -side left -padx 3 -pady 3
             set bouc [frame $actions.bouc -borderwidth 0 -cursor arrow -relief groove]
             pack $bouc -in $actions -side left -expand 0 -fill x -padx 10 -pady 5
                  checkbutton $bouc.check -highlightthickness 0 -text "$caption(gui_cata_creation,analyse)" -variable ::tools_cata::boucle
                  pack $bouc.check -in $bouc -side left -padx 5 -pady 0
             set lampions [frame $actions.actions -borderwidth 0 -cursor arrow -relief groove]
             pack $lampions -in $actions -anchor s -side right -expand 0 -fill x -padx 10 -pady 5
                  set ::gui_cata::gui_wcs [button $lampions.wcs -text "WCS" -borderwidth 1 -takefocus 0 -command "" \
                     -bg $::gui_cata::color_wcs -relief sunken -state disabled]
                  pack $lampions.wcs -side top -anchor e -expand 0 -fill x -padx 0 -pady 0 -ipadx 0 -ipady 0
                  set ::gui_cata::gui_cata [button $lampions.cata -text "CATA" -borderwidth 1 -takefocus 0 -command "" \
                     -bg $::gui_cata::color_cata -relief sunken -state disabled]
                  pack $lampions.cata -side top -anchor e -expand 0 -fill x -padx 0 -pady 0 -ipadx 0 -ipady 0

         #--- Cree un frame pour les onglets
         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand 0 -fill x -padx 10 -pady 5
 
            pack [ttk::notebook $onglets.nb]
            set f1 [frame $onglets.nb.f1]
            set f2 [frame $onglets.nb.f2]
            set f3 [frame $onglets.nb.f3]
            set f5 [frame $onglets.nb.f5]
            set f6 [frame $onglets.nb.f6]
            set f7 [frame $onglets.nb.f7]
            set f8 [frame $onglets.nb.f8]
            set f9 [frame $onglets.nb.f9]
            
            $onglets.nb add $f1 -text $caption(gui_cata_creation,catalogue) 
            $onglets.nb add $f2 -text $caption(gui_cata_creation,variables) 
            $onglets.nb add $f3 -text $caption(gui_cata_creation,image)
            $onglets.nb add $f5 -text $caption(gui_cata_creation,sextractor)
            $onglets.nb add $f6 -text $caption(gui_cata_creation,psf) 
            $onglets.nb add $f7 -text $caption(gui_cata_creation,interop)
            $onglets.nb add $f8 -text $caption(gui_cata_creation,manuel) 
            $onglets.nb add $f9 -text $caption(gui_cata_creation,develop)

            $onglets.nb select $f3
            ttk::notebook::enableTraversal $onglets.nb

         #-----------------------------------------------------------------------
         #--- Onglet CATALOGUES
         #-----------------------------------------------------------------------

         #--- Cree un frame pour afficher les onglets
         set subonglets [frame $f1.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $subonglets -in $f1 -side top -expand 1 -fill both -padx 5 -pady 5
      
            pack [ttk::notebook $subonglets.list] -expand yes -fill both -padx 5 -pady 5
      
            set conesearch [frame $subonglets.list.xml]
            pack $conesearch -in $subonglets.list -expand yes -fill both 
            $subonglets.list add $conesearch -text "$caption(gui_cata_creation,conesearch)"
            
            set affichage [frame $subonglets.list.cata]
            pack $affichage -in $subonglets.list -expand yes -fill both 
            $subonglets.list add $affichage -text "$caption(gui_cata_creation,dispcata)"
      
            #--- Cree un frame pour la liste des cata
            label $conesearch.titre -text "$caption(gui_cata_creation,conesearchmsg)" -font $bddconf(font,arial_10_b)
            pack $conesearch.titre -in $conesearch -side top -fill x -anchor c -pady 10
         
            #--- Cree un frame pour la liste des cata
            set cataconf [frame $conesearch.conf -borderwidth 0 -relief groove]
            pack $cataconf -in $conesearch -anchor c -side top -expand 0 -padx 10 -pady 5
         
               checkbutton $cataconf.skybot_check -highlightthickness 0 -text "  SKYBOT" -variable ::tools_cata::use_skybot
                  entry $cataconf.skybot_dir -relief flat -borderwidth 1 -textvariable ::tools_cata::catalog_skybot -width 30 -state disabled
               checkbutton $cataconf.usnoa2_check -highlightthickness 0 -text "  USNO-A2" -variable ::tools_cata::use_usnoa2 -state disabled
                  entry $cataconf.usnoa2_dir -relief flat -textvariable ::tools_cata::catalog_usnoa2 -width 30 -state disabled
               checkbutton $cataconf.tycho2_check -highlightthickness 0 -text "  TYCHO-2" -variable ::tools_cata::use_tycho2
                  entry $cataconf.tycho2_dir -relief flat -textvariable ::tools_cata::catalog_tycho2 -width 30 -state disabled
               checkbutton $cataconf.ucac2_check -highlightthickness 0 -text "  UCAC2" -variable ::tools_cata::use_ucac2
                  entry $cataconf.ucac2_dir -relief flat -textvariable ::tools_cata::catalog_ucac2 -width 30 -state disabled
               checkbutton $cataconf.ucac3_check -highlightthickness 0 -text "  UCAC3" -variable ::tools_cata::use_ucac3
                  entry $cataconf.ucac3_dir -relief flat -textvariable ::tools_cata::catalog_ucac3 -width 30 -state disabled
               checkbutton $cataconf.ucac4_check -highlightthickness 0 -text "  UCAC4" -variable ::tools_cata::use_ucac4
                  entry $cataconf.ucac4_dir -relief flat -textvariable ::tools_cata::catalog_ucac4 -width 30 -state disabled
               checkbutton $cataconf.ppmx_check -highlightthickness 0 -text "  PPMX" -variable ::tools_cata::use_ppmx -state disabled
                  entry $cataconf.ppmx_dir -relief flat -textvariable ::tools_cata::catalog_ppmx -width 30 -state disabled
               checkbutton $cataconf.ppmxl_check -highlightthickness 0 -text "  PPMX" -variable ::tools_cata::use_ppmxl -state disabled
                  entry $cataconf.ppmxl_dir -relief flat -textvariable ::tools_cata::catalog_ppmxl -width 30 -state disabled
               checkbutton $cataconf.nomad1_check -highlightthickness 0 -text "  NOMAD1" -variable ::tools_cata::use_nomad1 -state disabled
                  entry $cataconf.nomad1_dir -relief flat -textvariable ::tools_cata::catalog_nomad1 -width 30 -state disabled
               checkbutton $cataconf.twomass_check -highlightthickness 0 -text "  2MASS" -variable ::tools_cata::use_2mass
                  entry $cataconf.twomass_dir -relief flat -textvariable ::tools_cata::catalog_2mass -width 30 -state disabled
               frame $cataconf.blank -height 15

            grid $cataconf.skybot_check  $cataconf.skybot_dir  -sticky nsw -pady 3
            grid $cataconf.blank
            grid $cataconf.usnoa2_check  $cataconf.usnoa2_dir  -sticky nsw -pady 3
            grid $cataconf.tycho2_check  $cataconf.tycho2_dir  -sticky nsw -pady 3
            grid $cataconf.ucac2_check   $cataconf.ucac2_dir   -sticky nsw -pady 3
            grid $cataconf.ucac3_check   $cataconf.ucac3_dir   -sticky nsw -pady 3
            grid $cataconf.ucac4_check   $cataconf.ucac4_dir   -sticky nsw -pady 3
            grid $cataconf.ppmx_check    $cataconf.ppmx_dir    -sticky nsw -pady 3
            grid $cataconf.ppmxl_check   $cataconf.ppmxl_dir   -sticky nsw -pady 3
            grid $cataconf.nomad1_check  $cataconf.nomad1_dir  -sticky nsw -pady 3
            grid $cataconf.twomass_check $cataconf.twomass_dir -sticky nsw -pady 3
            grid columnconfigure $cataconf 0 -pad 30
      
            #--- Cree un frame pour la liste des cata
            set catafftitre [frame $affichage.titre -borderwidth 0 -relief groove]
            pack $catafftitre -in $affichage -anchor w -side top -expand 0 -fill x -padx 10 -pady 10
               label $catafftitre.lab -text "$caption(gui_cata_creation,dispcatamsg)" -font $bddconf(font,arial_10_b)
               pack $catafftitre.lab -in $catafftitre -side top -fill x -anchor c -pady 10
      
            #--- Cree un frame pour la liste des cata
            set cataff [frame $affichage.conf -borderwidth 0 -relief groove]
            pack $cataff -in $affichage -anchor c -side top -expand 0 -padx 10 -pady 5

               checkbutton $cataff.skybot_check -highlightthickness 0 -text "  SKYBOT" \
                  -variable ::gui_cata::gui_skybot -command "::gui_cata::affiche_cata"
                  label $cataff.skybot_val -textvariable ::tools_cata::nb_skybot -width 4
                  button $cataff.skybot_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_skybot \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_skybot $cataff.skybot_color"
                  spinbox $cataff.skybot_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_skybot -command "::gui_cata::affiche_cata"
                  $cataff.skybot_radius set $::gui_cata::size_skybot_sav
               checkbutton $cataff.astroid_check -highlightthickness 0 -text "  ASTROID" \
                  -variable ::gui_cata::gui_astroid -command "::gui_cata::affiche_cata"
                  label $cataff.astroid_val -textvariable ::tools_cata::nb_astroid -width 4
                  button $cataff.astroid_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_astroid \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_astroid $cataff.astroid_color"
                  spinbox $cataff.astroid_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_astroid -command "::gui_cata::affiche_cata"
                  $cataff.astroid_radius set $::gui_cata::size_astroid_sav
               checkbutton $cataff.img_check -highlightthickness 0 -text "  IMG" \
                  -variable ::gui_cata::gui_img -command "::gui_cata::affiche_cata"
                  label $cataff.img_val -textvariable ::tools_cata::nb_img -width 4
                  button $cataff.img_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_img \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_img $cataff.img_color"
                  spinbox $cataff.img_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_img -command "::gui_cata::affiche_cata"
                  $cataff.img_radius set $::gui_cata::size_img_sav
               checkbutton $cataff.usnoa2_check -highlightthickness 0 -text "  USNOA2" \
                  -variable ::gui_cata::gui_usnoa2 -command "::gui_cata::affiche_cata"
                  label $cataff.usnoa2_val -textvariable ::tools_cata::nb_usnoa2 -width 4
                  button $cataff.usnoa2_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_usnoa2 \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_usnoa2 $cataff.usnoa2_color"
                  spinbox $cataff.usnoa2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_usnoa2 -command "::gui_cata::affiche_cata"
                  $cataff.usnoa2_radius set $::gui_cata::size_usnoa2_sav
               checkbutton $cataff.tycho2_check -highlightthickness 0 -text "  TYCHO2" \
                  -variable ::gui_cata::gui_tycho2 -command "::gui_cata::affiche_cata"
                  label $cataff.tycho2_val -textvariable ::tools_cata::nb_tycho2 -width 4
                  button $cataff.tycho2_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_tycho2 \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_tycho2 $cataff.tycho2_color"
                  spinbox $cataff.tycho2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_tycho2 -command "::gui_cata::affiche_cata"
                  $cataff.tycho2_radius set $::gui_cata::size_tycho2_sav
               checkbutton $cataff.ucac2_check -highlightthickness 0 -text "  UCAC2" \
                  -variable ::gui_cata::gui_ucac2 -command "::gui_cata::affiche_cata"
                  label $cataff.ucac2_val -textvariable ::tools_cata::nb_ucac2 -width 4
                  button $cataff.ucac2_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_ucac2 \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_ucac2 $cataff.ucac2_color"
                  spinbox $cataff.ucac2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_ucac2 -command "::gui_cata::affiche_cata"
                  $cataff.ucac2_radius set $::gui_cata::size_ucac2_sav
               checkbutton $cataff.ucac3_check -highlightthickness 0 -text "  UCAC3" \
                  -variable ::gui_cata::gui_ucac3 -command "::gui_cata::affiche_cata"
                  label $cataff.ucac3_val -textvariable ::tools_cata::nb_ucac3 -width 4
                  button $cataff.ucac3_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_ucac3 \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_ucac3 $cataff.ucac3_color"
                  spinbox $cataff.ucac3_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_ucac3 -command "::gui_cata::affiche_cata"
                  $cataff.ucac3_radius set $::gui_cata::size_ucac3_sav
               checkbutton $cataff.ucac4_check -highlightthickness 0 -text "  UCAC4" \
                  -variable ::gui_cata::gui_ucac4 -command "::gui_cata::affiche_cata"
                  label $cataff.ucac4_val -textvariable ::tools_cata::nb_ucac4 -width 4
                  button $cataff.ucac4_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_ucac4 \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_ucac4 $cataff.ucac4_color"
                  spinbox $cataff.ucac4_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_ucac4 -command "::gui_cata::affiche_cata"
                  $cataff.ucac4_radius set $::gui_cata::size_ucac4_sav
               checkbutton $cataff.ppmx_check -highlightthickness 0 -text "  PPMX" \
                  -variable ::gui_cata::gui_ppmx -command "::gui_cata::affiche_cata"
                  label $cataff.ppmx_val -textvariable ::tools_cata::nb_ppmx -width 4
                  button $cataff.ppmx_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_ppmx \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_ppmx $cataff.ppmx_color"
                  spinbox $cataff.ppmx_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_ppmx -command "::gui_cata::affiche_cata"
                  $cataff.ppmx_radius set $::gui_cata::size_ppmx_sav
               checkbutton $cataff.ppmxl_check -highlightthickness 0 -text "  PPMXL" \
                  -variable ::gui_cata::gui_ppmxl -command "::gui_cata::affiche_cata"
                  label $cataff.ppmxl_val -textvariable ::tools_cata::nb_ppmxl -width 4
                  button $cataff.ppmxl_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_ppmxl \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_ppmxl $cataff.ppmxl_color"
                  spinbox $cataff.ppmxl_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_ppmxl -command "::gui_cata::affiche_cata"
                  $cataff.ppmxl_radius set $::gui_cata::size_ppmxl_sav
               checkbutton $cataff.nomad1_check -highlightthickness 0 -text "  NOMAD1" \
                  -variable ::gui_cata::gui_nomad1 -command "::gui_cata::affiche_cata"
                  label $cataff.nomad1_val -textvariable ::tools_cata::nb_nomad1 -width 4
                  button $cataff.nomad1_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_nomad1 \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_nomad1 $cataff.nomad1_color"
                  spinbox $cataff.nomad1_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_nomad1 -command "::gui_cata::affiche_cata"
                  $cataff.nomad1_radius set $::gui_cata::size_nomad1_sav
               checkbutton $cataff.2mass_check -highlightthickness 0 -text "  2MASS" \
                  -variable ::gui_cata::gui_2mass -command "::gui_cata::affiche_cata"
                  label $cataff.2mass_val -textvariable ::tools_cata::nb_2mass -width 4
                  button $cataff.2mass_color -borderwidth 1 -relief groove -width 5 -bg $::gui_cata::color_2mass \
                     -command "::bdi_gui_config::choose_color ::gui_cata::color_2mass $cataff.2mass_color"
                  spinbox $cataff.2mass_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                     -textvariable ::gui_cata::size_2mass -command "::gui_cata::affiche_cata"
                  $cataff.2mass_radius set $::gui_cata::size_2mass_sav

               frame $cataff.blank -height 15

            grid $cataff.img_check     $cataff.img_val     $cataff.img_color     $cataff.img_radius     -sticky nsw -pady 1
            grid $cataff.skybot_check  $cataff.skybot_val  $cataff.skybot_color  $cataff.skybot_radius  $cataff.astroid_check $cataff.astroid_val  $cataff.astroid_color $cataff.astroid_radius -sticky nsw -pady 1
            grid $cataff.blank                             
            grid $cataff.usnoa2_check  $cataff.usnoa2_val  $cataff.usnoa2_color  $cataff.usnoa2_radius  -sticky nsw -pady 1
            grid $cataff.tycho2_check  $cataff.tycho2_val  $cataff.tycho2_color  $cataff.tycho2_radius  $cataff.ucac3_check   $cataff.ucac3_val    $cataff.ucac3_color   $cataff.ucac3_radius   -sticky nsw -pady 1
            grid $cataff.ucac2_check   $cataff.ucac2_val   $cataff.ucac2_color   $cataff.ucac2_radius   $cataff.ucac4_check   $cataff.ucac4_val    $cataff.ucac4_color   $cataff.ucac4_radius   -sticky nsw -pady 1
            grid $cataff.ppmx_check    $cataff.ppmx_val    $cataff.ppmx_color    $cataff.ppmx_radius    $cataff.ppmxl_check   $cataff.ppmxl_val    $cataff.ppmxl_color   $cataff.ppmxl_radius   -sticky nsw -pady 1
            grid $cataff.nomad1_check  $cataff.nomad1_val  $cataff.nomad1_color  $cataff.nomad1_radius  $cataff.2mass_check   $cataff.2mass_val    $cataff.2mass_color   $cataff.2mass_radius   -sticky nsw -pady 1
            grid columnconfigure $cataff 0 -pad 10
            grid columnconfigure $cataff 2 -pad 10
            grid columnconfigure $cataff 3 -pad 10
            grid columnconfigure $cataff 4 -pad 10
            grid columnconfigure $cataff 6 -pad 10
            grid columnconfigure $cataff 7 -pad 10


         #-----------------------------------------------------------------------
         #--- Onglet VARIABLES
         #-----------------------------------------------------------------------

         set param [frame $f2.title -borderwidth 0 -cursor arrow -relief groove]
         pack $param -in $f2 -anchor c -side top -expand 0 -padx 10 -pady 10

            set title [frame $param.title -borderwidth 0 -cursor arrow -relief groove]
            pack $title -in $param -anchor s -side top -expand 0 -padx 10 -pady 10
               label $title.lab -highlightthickness 0 -text "$caption(gui_cata_creation,paramcata)" -font $bddconf(font,arial_10_b)
               pack $title.lab -in $title -side left -anchor c -expand 0 -padx 2 -pady 2
   
            set log [frame $param.log -borderwidth 0 -cursor arrow -relief groove]
            pack $log -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
               checkbutton $log.check -highlightthickness 0 -text "  $caption(gui_cata_creation,activelog)" -variable ::tools_cata::log
               pack $log.check -in $log -side left -expand 0 -fill x -padx 5 -pady 5
   
            set deuxpasses [frame $param.deuxpasses -borderwidth 0 -cursor arrow -relief groove]
            pack $deuxpasses -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
               checkbutton $deuxpasses.check -highlightthickness 0 -text "  $caption(gui_cata_creation,2passes)" -variable ::tools_cata::deuxpasses
               pack $deuxpasses.check -in $deuxpasses -side left -padx 5 -pady 0
     
            set keepradec [frame $param.keepradec -borderwidth 0 -cursor arrow -relief groove]
            pack $keepradec -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
               checkbutton $keepradec.check -highlightthickness 0 -text " $caption(gui_cata_creation,radecprec)" -variable ::tools_cata::keep_radec
               pack $keepradec.check -in $keepradec -side left -padx 5 -pady 0
     
            set delpv [frame $param.delpv -borderwidth 0 -cursor arrow -relief groove]
            pack $delpv -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
               checkbutton $delpv.check -highlightthickness 0 -text "  $caption(gui_cata_creation,supprpv)" -variable ::tools_cata::delpv
               pack $delpv.check -in $delpv -side left -padx 5 -pady 0
     
            set create_cata [frame $param.create_cata -borderwidth 0 -cursor arrow -relief groove]
            pack $create_cata -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
               checkbutton $create_cata.check -highlightthickness 0 -text "  $caption(gui_cata_creation,insertcata)" -variable ::tools_cata::create_cata
               pack $create_cata.check -in $create_cata -side left -padx 5 -pady 0
   
            set myuncosm [frame $param.myuncosm -borderwidth 0 -cursor arrow -relief groove]
            pack $myuncosm -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
               checkbutton $myuncosm.check -highlightthickness 0 -text "  $caption(gui_cata_creation,uncosmic)" -variable ::gui_cata::use_uncosmic
               pack $myuncosm.check -in $myuncosm -side left -padx 5 -pady 0
               label $myuncosm.lab1 -text "coef.:" 
               pack $myuncosm.lab1 -in $myuncosm -side left -padx 5 -pady 0
               entry $myuncosm.val1 -relief sunken -textvariable ::tools_cdl::uncosm_param1 -width 5
               pack $myuncosm.val1 -in $myuncosm -side left -pady 1 -anchor w
               label $myuncosm.lab2 -text "clipmax:" 
               pack $myuncosm.lab2 -in $myuncosm -side left -padx 5 -pady 0
               entry $myuncosm.val2 -relief sunken -textvariable ::tools_cdl::uncosm_param2 -width 5
               pack $myuncosm.val2 -in $myuncosm -side left -pady 1 -anchor w
   
            set limit_nbstars [frame $param.limit_nbstars -borderwidth 0 -cursor arrow -relief groove]
            pack $limit_nbstars -in $param -anchor s -side top -expand 0 -fill x -padx 20 -pady 5
   
               label $limit_nbstars.lab -text "$caption(gui_cata_creation,limitestars)" 
               entry $limit_nbstars.val -relief sunken -textvariable ::tools_cata::limit_nbstars_accepted -width 5
   
               grid $limit_nbstars.lab $limit_nbstars.val -sticky nsw -pady 1
               grid columnconfigure $limit_nbstars 0 -pad 10
   
            set threshold_ident [frame $param.threshold_ident -borderwidth 0 -cursor arrow -relief groove]
            pack $threshold_ident -in $param -anchor s -side top -expand 0 -fill x -padx 20 -pady 5
   
               label $threshold_ident.star_lab0 -text "$caption(gui_cata_creation,seuilidentstar)"  -justify left -borderwidth 1
               label $threshold_ident.star_lab1 -text "$caption(gui_cata_creation,enpos)"
               entry $threshold_ident.star_val1 -relief sunken -textvariable ::tools_cata::threshold_ident_pos_star -width 6
               label $threshold_ident.star_lab2 -text "$caption(gui_cata_creation,enmag)"
               entry $threshold_ident.star_val2 -relief sunken -textvariable ::tools_cata::threshold_ident_mag_star -width 6
   
               label $threshold_ident.plan_lab0 -text "$caption(gui_cata_creation,seuilidentplan)" -justify left
               label $threshold_ident.plan_lab1 -text "$caption(gui_cata_creation,enpos)"
               entry $threshold_ident.plan_val1 -relief sunken -textvariable ::tools_cata::threshold_ident_pos_ast -width 6
               label $threshold_ident.plan_lab2 -text "$caption(gui_cata_creation,enmag)" 
               entry $threshold_ident.plan_val2 -relief sunken -textvariable ::tools_cata::threshold_ident_mag_ast -width 6
   
               grid $threshold_ident.star_lab0 $threshold_ident.star_lab1 $threshold_ident.star_val1 $threshold_ident.star_lab2 $threshold_ident.star_val2 -sticky nsw -pady 1
               grid $threshold_ident.plan_lab0 $threshold_ident.plan_lab1 $threshold_ident.plan_val1 $threshold_ident.plan_lab2 $threshold_ident.plan_val2 -sticky nsw -pady 1
               grid columnconfigure $threshold_ident 0 -pad 10


         #-----------------------------------------------------------------------
         #--- Onglet IMAGE
         #-----------------------------------------------------------------------

         set infoimage [frame $f3.infoimage -borderwidth 0 -cursor arrow -relief groove]
         pack $infoimage -in $f3 -anchor c -side top -expand 0 -padx 10 -pady 10

            #--- Nom et date de l'image
            set img [frame $infoimage.img -borderwidth 1 -cursor arrow -relief solid -borderwidth 1]
            pack $img -in $infoimage -anchor c -side top -expand 0 -padx 10 -pady 10

               set ::gui_cata::gui_nomimage [label $img.nom -text $::tools_cata::current_image_name -font $bddconf(font,arial_10_b)]
               pack $img.nom -in $img -side top -padx 3 -pady 3 -ipadx 5 -ipady 2
   
               set ::gui_cata::gui_dateimage [label $img.date -text $::tools_cata::current_image_date]
               pack $img.date -in $img -side top -padx 3 -pady 3

            #--- Champs du header de l'image
            set keys [frame $infoimage.keys -borderwidth 0 -cursor arrow -relief groove]
            pack $keys -in $infoimage -anchor s -side top -expand 0 -padx 10 -pady 5
   
               #--- RA
               set ra [frame $keys.ra -borderwidth 0 -cursor arrow -relief groove]
               pack $ra -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                   label $ra.name -text "RA (deg):"
                   pack $ra.name -in $ra -side left -padx 15 -pady 3
                   entry $ra.val -relief sunken -textvariable ::tools_cata::ra
                   pack $ra.val -in $ra -side right -pady 1 -anchor w
   
               #--- DEC
               set dec [frame $keys.dec -borderwidth 0 -cursor arrow -relief groove]
               pack $dec -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                   label $dec.name -text "DEC (deg):"
                   pack $dec.name -in $dec -side left -padx 15 -pady 3
                   entry $dec.val -relief sunken -textvariable ::tools_cata::dec
                   pack $dec.val -in $dec -side right -pady 1 -anchor w
   
               #--- pixsize1
               set pixsize1 [frame $keys.pixsize1 -borderwidth 0 -cursor arrow -relief groove]
               pack $pixsize1 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                   label $pixsize1.name -text "PIXSIZE1 (micron):"
                   pack $pixsize1.name -in $pixsize1 -side left -padx 15 -pady 3
                   entry $pixsize1.val -relief sunken -textvariable ::tools_cata::pixsize1
                   pack $pixsize1.val -in $pixsize1 -side right -pady 1 -anchor w
   
               #--- pixsize2
               set pixsize2 [frame $keys.pixsize2 -borderwidth 0 -cursor arrow -relief groove]
               pack $pixsize2 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                   label $pixsize2.name -text "PIXSIZE2 (micron):"
                   pack $pixsize2.name -in $pixsize2 -side left -padx 15 -pady 3
                   entry $pixsize2.val -relief sunken -textvariable ::tools_cata::pixsize2
                   pack $pixsize2.val -in $pixsize2 -side right -pady 1 -anchor w
   
               #--- foclen
               set foclen [frame $keys.foclen -borderwidth 0 -cursor arrow -relief groove]
               pack $foclen -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                   label $foclen.name -text "FOCLEN (m):"
                   pack $foclen.name -in $foclen -side left -padx 15 -pady 3
                   entry $foclen.val -relief sunken -textvariable ::tools_cata::foclen
                   pack $foclen.val -in $foclen -side right -pady 1 -anchor w
   
            #--- set and reset center
            set setbut [frame $infoimage.setbut -borderwidth 0 -cursor arrow -relief groove]
            pack $setbut -in $infoimage -anchor s -side top -expand 0 -padx 5 -pady 1
               #--- set val
               button $setbut.setval -text "Set Center" -borderwidth 2 -takefocus 1 -command "::gui_cata_creation::setval"
               pack $setbut.setval -side left -padx 5 -pady 5 -expand 0
               #--- reset center
               button $setbut.resetval -text "Reset Center" -borderwidth 2 -takefocus 1 -command "::gui_cata_creation::resetcenter"
               pack $setbut.resetval -side left -padx 5 -pady 5 -expand 0


         #-----------------------------------------------------------------------
         #--- Onglet SEXTRACTOR
         #-----------------------------------------------------------------------

         set confsex [frame $f5.confsex -borderwidth 0 -cursor arrow -relief groove]
         pack $confsex -in $f5 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            frame $confsex.buttons -borderwidth 0 -cursor arrow -relief groove
            pack $confsex.buttons -in $confsex  -side top -anchor e -expand 0 

               button $confsex.buttons.clean -borderwidth 1 -command "cleanmark" -text "Clean"
               pack $confsex.buttons.clean -side left -anchor e -expand 0 
               button $confsex.buttons.test -borderwidth 1 -command "::gui_cata_creation::test_user_confsex" -text "Test"
               pack $confsex.buttons.test -side left -anchor e -expand 0 
               button $confsex.buttons.save -borderwidth 1 -command "::gui_cata_creation::set_user_confsex" -text "Save"
               pack $confsex.buttons.save -side left -anchor e -expand 0 

            text $confsex.file 
            pack $confsex.file -in $confsex -side top -padx 3 -pady 3 -anchor w 


         #-----------------------------------------------------------------------
         #--- Onglet PSF
         #-----------------------------------------------------------------------

         set psf [frame $f6.psf -borderwidth 0 -cursor arrow -relief groove]
         pack $psf -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               #--- Title
               label $psf.lab -text "$caption(gui_cata_creation,psftitle)" -font $bddconf(font,arial_10_b)
               pack $psf.lab -in $psf -side top -anchor c -expand 0 -padx 5 -pady 10

               #--- Creation du cata psf
               set creer [frame $psf.creer -borderwidth 0 -cursor arrow -relief groove]
               pack $creer -in $psf -side top -anchor w -expand 0 -fill x -pady 5
                  checkbutton $creer.check -highlightthickness 0 -text "  $caption(gui_cata_creation,psfcreer)" \
                        -variable ::psf_tools::use_psf -command "::gui_cata_creation::handlePSFParams $psf"
                  pack $creer.check -in $creer -side left -padx 3 -pady 3 -anchor w 

               #--- Option de creation du cata Astroid
               set opts [frame $psf.opts -borderwidth 1 -cursor arrow -relief sunken]
               pack $opts -in $psf  -side top -anchor e -expand 0 -fill x 
        
                  #--- Niveau de saturation (ADU)
                  set saturation [frame $opts.saturation]
                  pack $saturation -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                     label $saturation.lab -text "$caption(gui_cata_creation,psfsatu)" -width 24 -anchor e
                     pack $saturation.lab -in $saturation -side left -padx 5 -pady 0 -anchor e
                     entry $saturation.val -relief sunken -textvariable ::psf_tools::psf_saturation -width 6
                     pack $saturation.val -in $saturation -side left -pady 1 -anchor w

                  #--- Delta
                  set delta [frame $opts.delta]
                  pack $delta -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                     label $delta.lab -text "$caption(gui_cata_creation,psfdelta)" -width 24 -anchor e
                     pack $delta.lab -in $delta -side left -padx 5 -pady 0 -anchor e
                     entry $delta.val -relief sunken -textvariable ::psf_tools::psf_radius -width 3
                     pack $delta.val -in $delta -side left -pady 1 -anchor w

               #--- Creation du cata psf
               set methglobale [frame $psf.methglobale -borderwidth 0 -cursor arrow -relief groove]
               pack $methglobale -in $psf -side top -anchor w -expand 0 -fill x -pady 5
                  checkbutton $methglobale.check -highlightthickness 0 -text "  $caption(gui_cata_creation,psfauto)" \
                     -variable ::psf_tools::use_global -command "::gui_cata_creation::handlePSFParams $psf"
                  pack $methglobale.check -in $methglobale -side left -padx 3 -pady 3 -anchor w 

               #--- Option de creation du cata Astroid
               set opts [frame $psf.opts2 -borderwidth 1 -cursor arrow -relief sunken]
               pack $opts -in $psf  -side top -anchor e -expand 0 -fill x 
        
                  #--- Threshold
                  set threshold [frame $opts.threshold]
                  pack $threshold -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                     label $threshold.lab -text "$caption(gui_cata_creation,psfseuil)" -width 24 -anchor e
                     pack  $threshold.lab -side left -padx 5 -pady 0 -anchor e
                     entry $threshold.val -relief sunken -textvariable ::psf_tools::psf_threshold -width 3
                     pack  $threshold.val -side left -pady 1 -anchor w

                  #--- Threshold
                  set limitradius [frame $opts.limitradius]
                  pack $limitradius -in $opts -side top -anchor e -expand 0 -fill x -pady 5
                     label $limitradius.lab -text "$caption(gui_cata_creation,psfrayon)" -width 24 -anchor e
                     pack  $limitradius.lab -side left -padx 5 -pady 0 -anchor e
                     entry $limitradius.val -relief sunken -textvariable ::psf_tools::psf_limitradius -width 3
                     pack  $limitradius.val -side left -pady 1 -anchor w

               ::gui_cata_creation::handlePSFParams $psf
 

         #-----------------------------------------------------------------------
         #--- Onglet INTEROP
         #-----------------------------------------------------------------------

         #--- Cree un frame pour afficher les actions Interop
         set interop [frame $f7.interop -borderwidth 0 -cursor arrow -relief groove]
         pack $interop -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
  
            #--- Calcul des coordonnees du centre du fov
            set resolver [frame $interop.resolver -borderwidth 0 -cursor arrow -relief solid]
            pack $resolver -in $interop -anchor s -side top -expand 0 -fill x -padx 1 -pady 10

               label $resolver.title -text "$caption(gui_cata_creation,resolver)" -font $bddconf(font,arial_10_b)
               pack $resolver.title -in $resolver -anchor c -side top -padx 5 -pady 10

               set gril [frame $resolver.grid -borderwidth 0 -cursor arrow -relief solid]
               pack $gril -in $resolver -anchor c -side top -pady 10

                  label $gril.ldate    -text "$caption(gui_cata_creation,lepoch)"
                  label $gril.lcoord   -text "$caption(gui_cata_creation,lcoord)"
                  label $gril.lradius  -text "$caption(gui_cata_creation,lradius)"
                  label $gril.luaicode -text "$caption(gui_cata_creation,luaicode)"
 
                  entry $gril.edate -relief sunken -width 22 -textvariable ::tools_cata::current_image_date
                  entry $gril.ecoord -relief sunken -width 22 -textvariable ::tools_cata::coord
                  entry $gril.eradius -relief sunken -width 22 -textvariable ::tools_cata::radius
                  entry $gril.euaicode -relief sunken -width 22 -textvariable ::tools_cata::uaicode

                  button $gril.resolve -text "$caption(gui_cata_creation,butresolve)" -width 10 -borderwidth 1 -relief groove \
                     -command "::tools_cata::skybotResolver"
                  button $gril.setcenter -text "$caption(gui_cata_creation,butcenter)" -width 10 -borderwidth 1 -relief groove \
                     -command "::tools_cata::setCenterFromRADEC"
                  button $gril.blank1 -borderwidth 0 -width 12 -relief solid -borderwidth 0 -state disabled
                  button $gril.blank2 -borderwidth 0 -width 12 -relief solid -borderwidth 0 -state disabled

               grid $gril.ldate    $gril.edate    $gril.blank1    -sticky nsw -pady 1
               grid $gril.lcoord   $gril.ecoord   $gril.resolve   -sticky nsw -pady 1
               grid $gril.lradius  $gril.eradius  $gril.setcenter -sticky nsw -pady 1
               grid $gril.luaicode $gril.euaicode $gril.blank2    -sticky nsw -pady 1
               grid configure $gril.ldate $gril.lcoord $gril.lradius $gril.luaicode -sticky nse
               grid columnconfigure $gril 0 -pad 10
               grid columnconfigure $gril 2 -pad 5

            # Bouton pour envoyer les plans courants (image,table) vers Aladin
            set votools [frame $interop.votools -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
            pack $votools -in $interop -anchor s -side top -expand 0 -padx 10 -pady 5 -ipadx 20 -ipady 10

               label $votools.title -text "$caption(gui_cata_creation,votitle)" -font $bddconf(font,arial_10_b)
               pack $votools.title -in $votools -anchor c -side top -padx 5 -pady 10

               set ::gui_cata_creation::votoolsmenu [frame $votools.menu -borderwidth 0 -relief groove]
               pack $::gui_cata_creation::votoolsmenu -in $votools -anchor c -side top -padx 5 -pady 2
                  button $::gui_cata_creation::votoolsmenu.connect -borderwidth 1 -text "$caption(gui_cata_creation,voconnect)" \
                     -command "::gui_cata_creation::startInterop"
                  pack $::gui_cata_creation::votoolsmenu.connect -in $::gui_cata_creation::votoolsmenu -side top 

               set ::gui_cata_creation::votoolsaction [frame $votools.action -borderwidth 0 -relief groove]
               pack $::gui_cata_creation::votoolsaction -in $votools -anchor c -side top -padx 5 -pady 10
                  button $::gui_cata_creation::votoolsaction.broadcast -text "$caption(gui_cata_creation,voimgtab)" -borderwidth 1 -relief groove \
                     -command "::tools_cata::broadcastImageAndTable"
                  pack $::gui_cata_creation::votoolsaction.broadcast -in $::gui_cata_creation::votoolsaction -side top -fill x 
                  button $::gui_cata_creation::votoolsaction.script -text "$caption(gui_cata_creation,voscript)" -borderwidth 1 -relief groove \
                     -command "::tools_cata::broadcastAladinScript"
                  pack $::gui_cata_creation::votoolsaction.script -in $::gui_cata_creation::votoolsaction -side top -fill x


         #-----------------------------------------------------------------------
         #--- Onglet MANUEL
         #-----------------------------------------------------------------------

         #--- Cree un frame pour afficher la GUI du Mode Manuel
         set manuel [frame $f8.manuel -borderwidth 0 -cursor arrow -relief groove]
         pack $manuel -in $f8 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label $manuel.title -text "$caption(gui_cata_creation,manueltitle)" -font $bddconf(font,arial_10_b)
               pack $manuel.title -in $manuel -anchor c -side top -padx 5 -pady 5

               frame $manuel.entr -borderwidth 0 -cursor arrow -relief groove
               pack $manuel.entr -in $manuel -side top 

                  set fov [frame $manuel.fov -borderwidth 0 -cursor arrow  -borderwidth 0]
                  pack $fov -in $manuel.entr -side top 

                     frame $fov.alpha -borderwidth 0 -cursor arrow -relief groove
                     pack $fov.alpha -in $fov -side left 
                        label $fov.alpha.lab -text "RA (deg)"
                        pack $fov.alpha.lab -in $fov.alpha -side top -padx 1 -pady 1 -anchor c
                        entry $fov.alpha.val -relief sunken -textvariable ::tools_cata::ra -width 12
                        pack $fov.alpha.val -in $fov.alpha -side top -padx 1 -pady 1 -anchor w

                     frame $fov.delta -borderwidth 0 -cursor arrow -relief groove
                     pack $fov.delta -in $fov -side left 
                        label $fov.delta.lab -text "DEC (deg)"
                        pack $fov.delta.lab -in $fov.delta -side top -padx 1 -pady 1 -anchor c
                        entry $fov.delta.val -relief sunken -textvariable ::tools_cata::dec -width 12
                        pack $fov.delta.val -in $fov.delta -side top -padx 1 -pady 1 -anchor w

                     frame $fov.fov -borderwidth 0 -cursor arrow -relief groove
                     pack $fov.fov -in $fov -side left 
                        label $fov.fov.lab -text "Fov (arcmin)"
                        pack $fov.fov.lab -in $fov.fov -side top -padx 1 -pady 1 -anchor c
                        entry $fov.fov.val -relief sunken -textvariable ::tools_cata::radius -width 12
                        pack $fov.fov.val -in $fov.fov -side top -padx 1 -pady 1 -anchor w

                     frame $fov.crota -borderwidth 0 -cursor arrow -relief groove
                     pack $fov.crota -in $fov -side left 
                        label $fov.crota.lab -text "Orient. (deg)"
                        pack $fov.crota.lab -in $fov.crota -side top -padx 1 -pady 1 -anchor c
                        entry $fov.crota.val -relief sunken -textvariable ::tools_cata::crota -width 12
                        pack $fov.crota.val -in $fov.crota -side top -padx 1 -pady 1 -anchor w

                     frame $fov.dss -borderwidth 0 -cursor arrow -relief groove
                     pack $fov.dss -in $fov -side left -padx 5 -fill y
                        button $fov.dss.lab -borderwidth 2 -text "Get DSS" -command "::gui_cata::getDSS"
                        pack $fov.dss.lab -in $fov.dss -anchor s -side bottom

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
                           label $img.title.ad  -text "RA DEC (deg)" -borderwidth 0  -relief groove  -width 25
                           pack  $img.title.ad -in $img.title -side right -padx 3 -pady 3 -anchor e

                        for {set i 1} {$i<8} {incr i} {
                           frame $img.v$i -borderwidth 1 -cursor arrow -relief groove
                           pack $img.v$i -in $img  -side top 
                              entry $img.v$i.xy -relief sunken -textvariable ::gui_cata::man_xy_star($i)
                              pack  $img.v$i.xy -in $img.v$i -side left -padx 1 -pady 1 -anchor w
                              button  $img.v$i.grab -borderwidth 1 -command "::gui_cata_creation::grab $i" -text "Grab"
                              pack    $img.v$i.grab -in $img.v$i -side left -anchor e -expand 0 
                              entry $img.v$i.ad -relief sunken  -textvariable ::gui_cata::man_ad_star($i)
                              pack  $img.v$i.ad -in $img.v$i -side left -padx 1 -pady 1 -anchor w
                              button $img.v$i.clean -borderwidth 1 -image icon_clean -command {
                                 set ::gui_cata::man_xy_star($i) ""
                                 set ::gui_cata::man_ad_star($i) ""
                              }
                              pack $img.v$i.clean -in $img.v$i -side left -anchor e -expand 0 
                        }

                     set visu [frame $coord.r -borderwidth 0 -cursor arrow  -borderwidth 0]
                     pack $visu -in $coord -anchor c -side right -expand 0 -fill x -padx 10 -pady 5

                        button $visu.efface -borderwidth 1 -command "::gui_cata_creation::manual_clean" -text "Effacer"
                        pack $visu.efface -in $visu -side top -anchor c -fill x
                        button $visu.blank -borderwidth 0 -state disabled
                        pack $visu.blank -in $visu -side top -anchor c -fill x
                        button $visu.voir -borderwidth 1 -text "Voir XY" -command "::gui_cata_creation::manual_view"
                        pack $visu.voir -in $visu -side top -anchor c -fill x
                        button $visu.fit -borderwidth 1 -text "Fit XY" -command "::gui_cata_creation::manual_fit"
                        pack $visu.fit -in $visu -side top -anchor c -fill x
                        button $visu.clean  -borderwidth 1 -text "Clean XY" -command "cleanmark"
                        pack $visu.clean -in $visu -side top -anchor c -fill x

                  frame $manuel.entr.buttons -borderwidth 0 -cursor arrow -relief groove
                  pack $manuel.entr.buttons -in $manuel.entr -side top -pady 10
                
                     button $manuel.entr.buttons.creerwcs -borderwidth 1  \
                        -command "::gui_cata_creation::manual_create_wcs" -text "Creer WCS"
                     pack $manuel.entr.buttons.creerwcs -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     set ::gui_cata::gui_creercata [button $manuel.entr.buttons.creercata -borderwidth 1  \
                        -command "::gui_cata_creation::manual_create_cata" -text "Creer Cata" -state disabled]
                     pack $manuel.entr.buttons.creercata -in $manuel.entr.buttons -side left -anchor e -expand 0 
                     set ::gui_cata::gui_enrimg [button $manuel.entr.buttons.enrimg -borderwidth 1 \
                        -command "::gui_cata_creation::manual_insert_img" -text "Insertion Image" -state disabled]
                     pack $manuel.entr.buttons.enrimg -in $manuel.entr.buttons -side left -anchor e -expand 0 


         #-----------------------------------------------------------------------
         #--- Onglet DEVELOP
         #-----------------------------------------------------------------------

         set develop [frame $f9.develop -borderwidth 0 -cursor arrow -relief groove]
         pack $develop -in $f9 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            frame $develop.entr -borderwidth 0 -cursor arrow -relief groove
            pack $develop.entr  -in $develop  -side top 

               set inf [frame $develop.entr.affsourcegrab -borderwidth 0 -cursor arrow  -borderwidth 0]
               pack $inf -side top 
                  button $inf.lab -borderwidth 1 -command "::gui_cata_creation::develop box" -text "Voir dans la console : les sources d'une fenetre"
                  pack   $inf.lab -side top -padx 3 -pady 3 -anchor c

               set inf [frame $develop.entr.affsourceall -borderwidth 0 -cursor arrow  -borderwidth 0]
               pack $inf -side top 
                  button $inf.lab -borderwidth 1 -command "::gui_cata_creation::develop all" -text "Voir dans la console : toutes les sources"
                  pack   $inf.lab -side top -padx 3 -pady 3 -anchor c

               set inf [frame $develop.entr.affsource3 -borderwidth 0 -cursor arrow  -borderwidth 0]
               pack $inf -side top 
                  button $inf.lab -borderwidth 1 -command "::gui_cata_creation::develop 3sources" -text "Voir dans la console : 3 sources"
                  pack   $inf.lab -side top -padx 3 -pady 3 -anchor c


         #-----------------------------------------------------------------------
         #--- BOUTONS PIED
         #-----------------------------------------------------------------------
         set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
         pack $boutonpied -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            set ::gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
               -command "::gui_cata_creation::fermer"]
            pack $boutonpied.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

            #set ::gui_cata::gui_info [label $boutonpied.info -text ""]
            #pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
            #set ::gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
            #pack $::gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


      # Post-actions
      ::gui_cata_creation::get_default_confsex
      ::gui_cata_creation::handleVOButtons
      ::vo_tools::addInteropListener "::gui_cata_creation::handleVOButtons"

   }


}
