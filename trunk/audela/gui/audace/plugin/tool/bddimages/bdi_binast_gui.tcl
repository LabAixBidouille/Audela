namespace eval bdi_binast_gui {



   proc ::bdi_binast_gui::inittoconf {  } {

      catch { unset ::bdi_binast_gui::fen                  }
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
      catch { unset ::bdi_binast_tools::nb_obj_sav        }

      set ::bdi_binast_gui::enregistrer disabled
      set ::bdi_binast_gui::analyser disabled
      set ::bdi_binast_gui::check_system "-"

      set ::bdi_binast_tools::nb_obj 1
      set ::bdi_binast_tools::nb_obj_sav $::bdi_binast_tools::nb_obj
      set ::tools_cdl::saturation 50000

      set ::bdi_binast_tools::tabsource(obj1,delta) 15

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
      set exposure       [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"]   1] ]
      set idbddimg       [::bddimages_liste::lget $::bdi_binast_tools::current_image idbddimg]
      set dirfilename    [::bddimages_liste::lget $::bdi_binast_tools::current_image dirfilename]
      set filename       [::bddimages_liste::lget $::bdi_binast_tools::current_image filename   ]
      set file           [file join $bddconf(dirbase) $dirfilename $filename]
      set ::bdi_binast_tools::current_image_name $filename
      set ::bdi_binast_tools::current_image_date $date
      set ::bdi_binast_tools::current_image_jjdate [expr [mc_date2jd $date] + $exposure / 86400.0 / 2.0]
      set ::bdi_binast_tools::current_image_date [mc_date2iso8601 $::bdi_binast_tools::current_image_jjdate]
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




   proc ::bdi_binast_gui::set_nb_system {  } {

      set ::bdi_binast_tools::nb_obj 2
      
   }



   proc ::bdi_binast_gui::change_nbobject { sources } {

      gren_info "nb object = $::bdi_binast_tools::nb_obj \n"
      gren_info "nb save = $::bdi_binast_tools::nb_obj_sav \n"

      if {$::bdi_binast_tools::nb_obj == 1 && $::bdi_binast_tools::nb_obj_sav == 1} {
         set ::bdi_binast_tools::nb_obj $::bdi_binast_tools::nb_obj_sav
         return
      }


      if {$::bdi_binast_tools::nb_obj<$::bdi_binast_tools::nb_obj_sav} {

         set x $::bdi_binast_tools::nb_obj_sav

         destroy $sources.name.obj$x   
         destroy $sources.id.obj$x     
         destroy $sources.ra.obj$x     
         destroy $sources.dec.obj$x    
         destroy $sources.xobs.obj$x    
         destroy $sources.yobs.obj$x    
         destroy $sources.xcalc.obj$x    
         destroy $sources.ycalc.obj$x    
         destroy $sources.xomc.obj$x    
         destroy $sources.yomc.obj$x    
         destroy $sources.mag.obj$x    
         destroy $sources.stdev.obj$x 
         destroy $sources.delta.obj$x  
         destroy $sources.select.obj$x 
         destroy $sources.miriade.obj$x 

      } else {

         set x $::bdi_binast_tools::nb_obj

         label   $sources.name.obj$x -text "Obj$x :"
         entry   $sources.id.obj$x   -relief sunken -width 11
         entry   $sources.ra.obj$x   -relief sunken -width 11
         entry   $sources.dec.obj$x  -relief sunken -width 11
         entry   $sources.xobs.obj$x  -relief sunken -width 11
         entry   $sources.yobs.obj$x  -relief sunken -width 11
         entry   $sources.xcalc.obj$x  -relief sunken -width 11
         entry   $sources.ycalc.obj$x  -relief sunken -width 11
         entry   $sources.xomc.obj$x  -relief sunken -width 11
         entry   $sources.yomc.obj$x  -relief sunken -width 11
         label   $sources.mag.obj$x  -width 9
         label   $sources.stdev.obj$x -width 9 
         spinbox $sources.delta.obj$x -from 1 -to 100 -increment 1 -command "" -width 3 \
                   -command "::bdi_binast_gui::mesure_tout $sources" \
                   -textvariable ::bdi_binast_tools::tabsource(obj$x,delta)
         button  $sources.select.obj$x -text "Select" -command "::bdi_binast_gui::select_source $sources obj$x"
         button $sources.miriade.obj$x -text "Miriade" -command "::bdi_binast_gui::miriade_obj $sources obj$x"

         pack $sources.name.obj$x    -in $sources.name   -side top -pady 2 -ipady 2
         pack $sources.id.obj$x      -in $sources.id     -side top -pady 2 -ipady 2
         pack $sources.ra.obj$x      -in $sources.ra     -side top -pady 2 -ipady 2
         pack $sources.dec.obj$x     -in $sources.dec    -side top -pady 2 -ipady 2
         pack $sources.xobs.obj$x     -in $sources.xobs    -side top -pady 2 -ipady 2
         pack $sources.yobs.obj$x     -in $sources.yobs    -side top -pady 2 -ipady 2
         pack $sources.xcalc.obj$x     -in $sources.xcalc    -side top -pady 2 -ipady 2
         pack $sources.ycalc.obj$x     -in $sources.ycalc    -side top -pady 2 -ipady 2
         pack $sources.xomc.obj$x     -in $sources.xomc    -side top -pady 2 -ipady 2
         pack $sources.yomc.obj$x     -in $sources.yomc    -side top -pady 2 -ipady 2
         pack $sources.mag.obj$x     -in $sources.mag    -side top -pady 2 -ipady 2
         pack $sources.stdev.obj$x   -in $sources.stdev  -side top -pady 2 -ipady 2
         pack $sources.delta.obj$x   -in $sources.delta  -side top -pady 2 -ipady 2
         pack $sources.select.obj$x  -in $sources.select -side top 
         pack $sources.miriade.obj$x -in $sources.miriade -side top    

         set ::bdi_binast_tools::tabsource(obj$x,delta) 15

         set system [string trim [$sources.id.obj1 get ] ]
         set idobj [expr $::bdi_binast_tools::nb_obj-1]
         $sources.id.obj$x configure 
         $sources.id.obj$x delete 0 end 
         $sources.id.obj$x insert end "${system}/${idobj}"
      }

      set ::bdi_binast_tools::nb_obj_sav $::bdi_binast_tools::nb_obj
      return

   }








   proc ::bdi_binast_gui::good_sexa { d m s prec } {

      set d [expr int($d)]
      set m [expr int($m)]
      set sa [expr int($s)]
      if {$prec==0} {
         return [format "%02d:%02d:%02d" $d $m $sa]
      }
      set ms [expr int(($s - $sa) * pow(10,$prec))]
      return [format "%02d:%02d:%02d.%0${prec}d" $d $m $sa $ms]
   }   







   proc ::bdi_binast_gui::miriade_obj { sources obj  } {


           


            set jd $::bdi_binast_tools::current_image_jjdate
            set ::bdi_binast_tools::observer_pos "@-48"
            set ::bdi_binast_tools::observer_pos "500"
            gren_info "observer_pos=$::bdi_binast_tools::observer_pos\n"

            set miriade_obj [$sources.id.$obj get ]
            gren_info "miriade_obj=$miriade_obj\n"

 
      set cmd1 "vo_miriade_ephemcc \"$miriade_obj\" \"\" $jd 1 \"1d\" \"UTC\" \"$::bdi_binast_tools::observer_pos\" \"INPOP\" 2 1 1 \"text\" \"--jd\" 0"
      #::console::affiche_resultat "CMD MIRIADE=$cmd1\n"
      set textraw1 [vo_miriade_ephemcc "$miriade_obj" "" $jd 1 "1d" "UTC" "$::bdi_binast_tools::observer_pos" "INPOP" 2 1 1 "text" "--jd" 0]
      set text1 [split $textraw1 ";"]
      set nbl [llength $text1]
      if {$nbl == 1} {
         set res [tk_messageBox -message "L'appel aux ephemerides a echouer.\nVerifier le nom de l'objet.\nLa commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         return      
      }

      # Sauvegarde des fichiers intermediaires
      set file "miriade.1"
      set chan [open $file w]
      foreach line $text1 {
         ::console::affiche_resultat "MIRIADE=$line\n"
         puts $chan $line
      }

      # Recupere la position de l'observateur
      foreach t $text1 {
         if { [regexp {.*(\d+) h +(\d+) m +(\d+)\.(\d+) s (.+?).* (\d+) d +(\d+) ' +(\d+)\.(\d+) " +(.+?).* ([-+]?\d*\.?\d*) m.*} $t str loh lom los loms lowe lad lam las lams lans alt] } {
            # "
            set ::bdi_binast_tools::longitude [format "%s %02d %02d %02d.%03d" $lowe $loh $lom $los $loms ]
            set ::bdi_binast_tools::latitude  [format "%s %02d %02d %02d.%03d" $lans $lad $lam $las $lams ]
            set ::bdi_binast_tools::altitude  $alt
            gren_info "Position=$::bdi_binast_tools::longitude $::bdi_binast_tools::latitude $::bdi_binast_tools::altitude m\n"
         }      
      }

      # Maj du nom de l asteroide      
      set ast [lindex $text1 2]
      if {$ast != ""} {
         gren_info "AST=$ast\n"
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

      # Interpretation appel format num 1
      set cpt 0
      foreach line $text1 {
         set char [string index [string trim $line] 0]
         #::console::affiche_resultat "ephemcc 1 ($cpt) ($char)=$line\n"
         if {$char!="#"} { break }
         incr cpt
      }
      #::console::affiche_resultat "cptdata = $cpt\n"
      # on split la la ligne pour retrouver les valeurs
      set line [lindex $text1 $cpt]
      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      foreach s_el $line {
         ::console::affiche_resultat  "($cpt) $s_el\n"
         incr cpt
      }

      # on affecte les varaibles
      set ::atos_analysis_gui::rajapp   [::bdi_binast_gui::good_sexa [lindex $line  2] [lindex $line  3] [lindex $line  4] 2]
      set ::atos_analysis_gui::decapp   [::bdi_binast_gui::good_sexa [lindex $line  5] [lindex $line  6] [lindex $line  7] 2]
      set ::atos_analysis_gui::dist     [format "%.5f" [lindex $line 8]]
      set ::atos_analysis_gui::magv     [lindex $line 9]
      set ::atos_analysis_gui::phase    [lindex $line 10]
      set ::atos_analysis_gui::elong    [lindex $line 11]
      set ::atos_analysis_gui::dracosd  [format "%.5f" [expr [lindex $line 12] * 60. ] ]
      set ::atos_analysis_gui::ddec     [format "%.5f" [expr [lindex $line 13] * 60. ] ]
      set ::atos_analysis_gui::vn       [lindex $line 14]
      set ::atos_analysis_gui::dx       0
      set ::atos_analysis_gui::dy       0
catch {
      set ::atos_analysis_gui::dx       [lindex $line 15]
      set ::atos_analysis_gui::dy       [lindex $line 16]
}


#      $sources.ra.obj1 configure 
#      $sources.ra.obj1   delete 0 end 
#      $sources.ra.obj1   insert end $::atos_analysis_gui::rajapp
#      $sources.dec.obj1 configure 
#      $sources.dec.obj1   delete 0 end 
#      $sources.dec.obj1   insert end $::atos_analysis_gui::decapp
      $sources.xcalc.$obj configure 
      $sources.xcalc.$obj delete 0 end 
      $sources.xcalc.$obj insert end [format "%.4f" [expr $::atos_analysis_gui::dx] ]
      $sources.ycalc.$obj configure 
      $sources.ycalc.$obj delete 0 end 
      $sources.ycalc.$obj insert end [format "%.4f" [expr $::atos_analysis_gui::dy] ]
#      $sources.ra.$obj configure 
#      $sources.ra.$obj   delete 0 end 
#      $sources.ra.$obj   insert end [mc_angle2hms [ expr  [mc_angle2deg $::atos_analysis_gui::rajapp ] * 15.0 + $::atos_analysis_gui::dx / 3600.0 ] ]
#      $sources.dec.$obj configure 
#      $sources.dec.$obj   delete 0 end 
#      $sources.dec.$obj   insert end [mc_angle2dms [ expr  [mc_angle2deg $::atos_analysis_gui::decapp ] + $::atos_analysis_gui::dy / 3600.0 ] ]

       set xcalc  [$sources.xcalc.$obj get]
       set ycalc  [$sources.ycalc.$obj get]
       set xobs   [$sources.xobs.$obj get]
       set yobs   [$sources.yobs.$obj get]
       gren_info "set  xcalc  $xcalc\n"
       gren_info "set  ycalc  $ycalc\n"
       gren_info "set  xobs   $xobs \n"
       gren_info "set  yobs   $yobs \n"

      if {$xcalc!="" && $ycalc!="" && $xobs!="" && $yobs!="" } {
      
         gren_info "OK\n"

             set xomc [expr $xobs - $xcalc ]
             $sources.xomc.$obj configure 
             $sources.xomc.$obj delete 0 end 
             $sources.xomc.$obj insert end [format "%.4f" $xomc ]
             set yomc [expr $yobs - $ycalc ]
             $sources.yomc.$obj configure 
             $sources.yomc.$obj delete 0 end 
             $sources.yomc.$obj insert end [format "%.4f" $yomc ]
  
      }

      # si tout c est bien passé
      set ::bdi_binast_gui::check_system "Checked"

      # si erreur
      set ::bdi_binast_gui::check_system "Erreur"


      # EN DUR
      set ::bdi_binast_gui::check_system "Checked"

      return ::bdi_binast_tools::nb_obj
   
   }
 
 
 
 
 
    proc ::bdi_binast_gui::select_source { sources obj } {
      
      gren_info "obj = $obj \n"
      gren_info "delta = $::bdi_binast_tools::tabsource($obj,delta) \n"


      if {[ $sources.select.$obj cget -relief] == "raised"} {

         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         #buf$::audace(bufNo)
         if {$err>0 || $rect ==""} {
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
           
            return
         }
         set err [ catch {set valeurs [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
         if {$err>0} {
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Mesure Photometrique impossible\n"
            ::console::affiche_erreur "      * * * *\n"
            return
         }

         
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,x) [lindex $valeurs 0]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,y) [lindex $valeurs 1]
         set ::bdi_binast_tools::tabsource($obj,select) true
         $sources.select.$obj  configure -relief sunken

      } else {
         $sources.select.$obj  configure -relief raised
         set ::bdi_binast_tools::tabsource($obj,select) false
      }

      ::bdi_binast_gui::mesure_tout $sources
     

       set rap [$sources.ra.obj1 get]
       set decp [$sources.dec.obj1 get]
       set ras [$sources.ra.$obj get]
       set decs [$sources.dec.$obj get]
       gren_info "set rap   $rap\n"
       gren_info "set decp   $decp\n"
       gren_info "set ras   $ras\n"
       gren_info "set decs   $decs\n"
      

      if {$rap!="" && $decp!="" && $ras!="" && $decs!="" } {
      
         gren_info "OK\n"
             set dra [expr ([mc_angle2deg $ras ] * 15.0 - [mc_angle2deg $rap ] * 15.0 ) * 3600.0 * cos ( [mc_angle2rad $decp ] )]
             $sources.xobs.$obj configure 
             $sources.xobs.$obj delete 0 end 
             $sources.xobs.$obj insert end [format "%.4f" $dra ]
             set ddec [expr ([mc_angle2deg $decs ] - [mc_angle2deg $decp ]) * 3600.0]
             $sources.yobs.$obj configure 
             $sources.yobs.$obj delete 0 end 
             $sources.yobs.$obj insert end [format "%.4f" $ddec ]
         
      
      }




   }

 
   proc ::bdi_binast_gui::mesure_tout { sources } {


      gren_info "ZOOM: [::confVisu::getZoom $::audace(visuNo)] \n "

      for {set x 1} {$x<=$::bdi_binast_tools::nb_obj} {incr x} {
         if { [ $sources.select.obj$x cget -relief] == "sunken" } {
            ::bdi_binast_gui::mesure_une $sources obj$x
         }
      }




      return 0

   }
   
   
   
   
   
   
   
      proc ::bdi_binast_gui::mesure_une { sources obj } {

      set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,err) false
      set err [ catch {set valeurs [::tools_cdl::mesure_obj \
               $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,x) \
               $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,y) \
               $::bdi_binast_tools::tabsource($obj,delta) $::audace(bufNo)]} msg ]

      gren_info "PHOTOM $obj : $valeurs \n "
      
      if { $valeurs == -1 } {
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,err) true
         $sources.ra.$obj configure -bg red
         $sources.dec.$obj configure -bg red
         return
      } else {

         $sources.ra.$obj configure -bg "#ffffff"
         $sources.dec.$obj configure -bg "#ffffff"

         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]

         set a [buf$::audace(bufNo) xy2radec [list $xsm $ysm]]
         set ra_deg  [lindex $a 0]
         set dec_deg [lindex $a 1]
         set ra_hms  [mc_angle2hms $ra_deg 360 zero 3 auto string]
         set dec_dms [mc_angle2dms $dec_deg 90 zero 3 + string]
         set ra_hms  [string map {h : m : s .} $ra_hms]
         set dec_dms [string map {d : m : s .} $dec_dms]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,x)           $xsm
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,y)           $ysm
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,ra_deg)      $ra_deg
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,dec_deg)     $dec_deg
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,ra_hms)      $ra_hms
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,dec_dms)     $dec_dms

         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,fwhmx)       [lindex $valeurs 2]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,fwhmy)       [lindex $valeurs 3]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,fwhm)        [lindex $valeurs 4]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,fluxintegre) [lindex $valeurs 5]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,errflux)     [lindex $valeurs 6]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,pixmax)      [lindex $valeurs 7]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,intensite)   [lindex $valeurs 8]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,sigmafond)   [lindex $valeurs 9]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,snint)       [lindex $valeurs 10]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,snpx)        [lindex $valeurs 11]
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,delta)       [lindex $valeurs 12]
         
         set err [ catch {set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,maginstru)   [expr -log10([lindex $valeurs 5]/20000.)*2.5] } msg ]
         if {$err} {::console::affiche_erreur "Calcul mag_instru $err $msg $obj : $valeurs\n"}
         
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,jjdate)      $::bdi_binast_tools::current_image_jjdate
         set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,isodate)     $::bdi_binast_tools::current_image_date


         if { [lindex $valeurs 7] > $::tools_cdl::saturation} {

            set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,err) true
            set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,saturation) true
            set mesure "bad"

         } else {

            set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,saturation) false


            $sources.ra.$obj   delete 0 end 
            $sources.ra.$obj   insert end $ra_hms
            $sources.dec.$obj  delete 0 end 
            $sources.dec.$obj  insert end $dec_dms
            $sources.mag.$obj  configure -bg "#ece9d8"

         }

      }
 
   }
 
   
}
