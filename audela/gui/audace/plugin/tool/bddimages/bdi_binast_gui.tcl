namespace eval bdi_binast_gui {



   proc ::bdi_binast_gui::inittoconf {  } {

      catch { unset ::bdi_binast_gui::fen                  }
      catch { unset ::bdi_binast_gui::nbstars              }
      catch { unset ::bdi_binast_gui::directaccess         }
      catch { unset ::bdi_binast_gui::stateback            }
      catch { unset ::bdi_binast_gui::statenext            }
      catch { unset ::bdi_binast_gui::block                }

      catch { unset ::bdi_binast_gui::check_system         }

      catch { unset ::bdi_binast_tools::nomobj             }
      catch { unset ::bdi_binast_tools::savedir            }
      catch { unset ::bdi_binast_tools::uncosm             }
      catch { unset ::bdi_binast_tools::uncosm_param1      }
      catch { unset ::bdi_binast_tools::uncosm_param2      }
      catch { unset ::bdi_binast_tools::firstmagref        }
      catch { unset ::bdi_binast_tools::current_image_name }
      catch { unset ::bdi_binast_tools::current_image_date }
      catch { unset ::bdi_binast_tools::id_current_image   }
      catch { unset ::bdi_binast_tools::nb_img_list        }
      catch { unset ::bdi_binast_tools::tabsource          }
      catch { unset ::bdi_binast_tools::firstmagref        }

      catch { unset ::bdi_binast_tools::nb_obj        }

      set ::bdi_binast_gui::enregistrer disabled
      set ::bdi_binast_gui::analyser disabled
      set ::bdi_binast_gui::check_system "-"
   }




   proc ::bdi_binast_gui::fermer {  } {

      cleanmark
      destroy $::bdi_binast_gui::fen
   }

   



   proc ::bdi_binast_gui::charge_list { img_list } {

      global audace
      global bddconf

      catch {
         if { [ info exists $::bdi_binast_tools::img_list ] }           {unset ::bdi_binast_tools::img_list}
         if { [ info exists $::bdi_binast_tools::current_image ] }      {unset ::bdi_binast_tools::current_image}
         if { [ info exists $::bdi_binast_tools::current_image_name ] } {unset ::bdi_binast_tools::current_image_name}
      }
      
      set ::bdi_binast_tools::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::bdi_binast_tools::img_list    [::bddimages_liste_gui::add_info_cata_list $::bdi_binast_tools::img_list]
      set ::bdi_binast_tools::nb_img_list [llength $::bdi_binast_tools::img_list]


      # Verification du WCS
      foreach ::bdi_binast_tools::current_image $::bdi_binast_tools::img_list {
         set tabkey      [::bddimages_liste::lget $::bdi_binast_tools::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::bdi_binast_tools::current_image idbddimg]
         set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]
         gren_info " idbddimg : $idbddimg  - date : $date - WCS : bddimages_wcs\n"
      }

      # Chargement des variables
      set ::bdi_binast_tools::id_current_image 1

      set ::bdi_binast_tools::current_image [lindex $::bdi_binast_tools::img_list 0]
      set tabkey         [::bddimages_liste::lget $::bdi_binast_tools::current_image "tabkey"]
      set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
#      set exposure       [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"]   1] ]
      set idbddimg       [::bddimages_liste::lget $::bdi_binast_tools::current_image idbddimg]
      set dirfilename    [::bddimages_liste::lget $::bdi_binast_tools::current_image dirfilename]
      set filename       [::bddimages_liste::lget $::bdi_binast_tools::current_image filename   ]
      set file           [file join $bddconf(dirbase) $dirfilename $filename]
      set ::bdi_binast_tools::current_image_name $filename
      set ::bdi_binast_tools::current_image_date $date
#      set ::bdi_binast_tools::current_image_jjdate [expr [mc_date2jd $date] + $exposure / 86400.0 / 2.0]
#      set ::bdi_binast_tools::current_image_date [mc_date2iso8601 $::bdi_binast_tools::current_image_jjdate]
#
      # Visualisation de l image
      cleanmark
      buf$::audace(bufNo) load $file
      ::audace::autovisu $::audace(visuNo)

      # Initialisation des boutons
      set ::bdi_binast_gui::stateback disabled
      if {$::bdi_binast_tools::nb_img_list == 1} {
         set ::bdi_binast_gui::statenext disabled
      } else {
         set ::bdi_binast_gui::statenext normal
      }


   }


   proc ::bdi_binast_gui::miriade_system {  } {

      set ::bdi_binast_tools::nb_obj 0

      set cmd1 "vo_miriade_ephemcc \"$::bdi_binast_tools::system\" \"\" $jd 1 \"1d\" \"UTC\" \"$::bdi_binast_tools::observer_pos\" \"INPOP\" 2 1 1 \"text\" \"--jd\" 0"
      #::console::affiche_resultat "CMD MIRIADE=$cmd1\n"
      set textraw1 [vo_miriade_ephemcc "$::atos_analysis_gui::system" "" $jd 1 "1d" "UTC" "$::bdi_binast_tools::observer_pos" "INPOP" 2 1 1 "text" "--jd" 0]
      set text1 [split $textraw1 ";"]
      set nbl [llength $text1]
      if {$nbl == 1} {
         set res [tk_messageBox -message "L'appel aux ephemerides a echouer.\nVerifier le nom de l'objet.\nLa commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         return      
      }

      # Sauvegarde des fichiers intermediaires
      set file [file join $::atos_analysis_gui::prj_dir "miriade.1"]
      set chan [open $file w]
      foreach line $text1 {
         puts $chan $line
      }

      # Recupere la position de l'observateur
      foreach t $text1 {
         if { [regexp {.*(\d+) h +(\d+) m +(\d+)\.(\d+) s (.+?).* (\d+) d +(\d+) ' +(\d+)\.(\d+) " +(.+?).* ([-+]?\d*\.?\d*) m.*} $t str loh lom los loms lowe lad lam las lams lans alt] } {
            # "
            set ::bdi_binast_tools::longitude [format "%s %02d %02d %02d.%03d" $lowe $loh $lom $los $loms ]
            set ::bdi_binast_tools::latitude  [format "%s %02d %02d %02d.%03d" $lans $lad $lam $las $lams ]
            set ::bdi_binast_tools::altitude  $alt
         }      
      }

      # Maj du nom de l asteroide      
      set ast [lindex $text1 2]
      if {$ast != ""} {
         ::bdi_binast_tools::set_object_name $ast
      } else {
         set res [tk_messageBox -message "Le nom de l'objet n'est pas reconnu par Miriade.\nLe resultat de la commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         set cpt 0
         foreach line $text1 {
            ::console::affiche_erreur "($cpt)=$line\n"
            incr cpt
         }
         return               
      }


      # si tout c est bien passé
      set ::bdi_binast_gui::check_system "Checked"

      # si erreur
      set ::bdi_binast_gui::check_system "Erreur"

      return ::bdi_binast_tools::nb_obj
   
   }
   
}
