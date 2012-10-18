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
      catch { unset ::bdi_binast_tools::tabphotom          }

      catch { unset ::bdi_binast_tools::nb_obj        }
      catch { unset ::bdi_binast_tools::nb_obj_sav        }

      set ::bdi_binast_gui::enregistrer disabled
      set ::bdi_binast_gui::analyser disabled
      set ::bdi_binast_gui::check_system "-"

      set ::bdi_binast_tools::nb_obj 1
      set ::bdi_binast_tools::nb_obj_sav $::bdi_binast_tools::nb_obj
      set ::bdi_binast_tools::saturation 50000
      set ::bdi_binast_tools::uncosm 50000
      set ::bdi_binast_gui::block 1

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

      # Initialisation des boutons
      set ::bdi_binast_gui::stateback disabled
      if {$::bdi_binast_tools::nb_img_list == 1} {
         set ::bdi_binast_gui::statenext disabled
      } else {
         set ::bdi_binast_gui::statenext normal
      }


      # Chargement des variables
      set ::bdi_binast_tools::id_current_image 1
      ::bdi_binast_gui::charge_current_image
      

      return




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

      # teph 1 = astromJ2000
      # teph 2 = apparent
      # teph 3 = moyen date
      # teph 3 = moyen J2000
      set teph  1

      # tcoor 
      # 1: spheriques, 2: rectangulaires,                   !
      # 3: locales,    4: horaires,                         !
      # 5: dediees a l'observation,                         !
      # 6: dediees a l'observation AO,                      !
      # 7: dediees au calcul (rep. helio. moyen J2000)      !
      set tcoor  1
      
      # rplane
      # 1: equateur, 2:ecliptique  
      set rplane 1

 
      set cmd1 "vo_miriade_ephemcc \"$miriade_obj\" \"\" $jd 1 \"1d\" \"UTC\" \"$::bdi_binast_tools::observer_pos\" \"INPOP\" $teph $tcoor $rplane \"text\" \"--jd\" 0"
      #::console::affiche_resultat "CMD MIRIADE=$cmd1\n"
      set textraw1 [vo_miriade_ephemcc "$miriade_obj" "" $jd 1 "1d" "UTC" "$::bdi_binast_tools::observer_pos" "INPOP" $teph $tcoor $rplane "text" "--jd" 0]
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
      set ::bdi_binast_tools::rajapp   [::bdi_binast_gui::good_sexa [lindex $line  2] [lindex $line  3] [lindex $line  4] 2]
      set ::bdi_binast_tools::decapp   [::bdi_binast_gui::good_sexa [lindex $line  5] [lindex $line  6] [lindex $line  7] 2]
      set ::bdi_binast_tools::dist     [format "%.5f" [lindex $line 8]]
      set ::bdi_binast_tools::magv     [lindex $line 9]
      set ::bdi_binast_tools::phase    [lindex $line 10]
      set ::bdi_binast_tools::elong    [lindex $line 11]
      set ::bdi_binast_tools::dracosd  [format "%.5f" [expr [lindex $line 12] * 60. ] ]
      set ::bdi_binast_tools::ddec     [format "%.5f" [expr [lindex $line 13] * 60. ] ]
      set ::bdi_binast_tools::vn       [lindex $line 14]
      set ::bdi_binast_tools::dx       0
      set ::bdi_binast_tools::dy       0

      set ra  [ expr  [mc_angle2deg $::bdi_binast_tools::rajapp ] * 15.0 ]
      set dec [ expr  [mc_angle2deg $::bdi_binast_tools::decapp ] ]
      affich_un_rond  $ra $dec green 3
      gren_info "affich_un_rond  $ra $dec green 3"


catch {
      set ::bdi_binast_tools::dx       [lindex $line 15]
      set ::bdi_binast_tools::dy       [lindex $line 16]
      
      set ra  [ expr $ra  + $::bdi_binast_tools::dx / 3600.0 ]
      set dec [ expr $dec + $::bdi_binast_tools::dy / 3600.0 ]
      affich_un_rond  $ra $dec yellow 3
      gren_info "affich_un_rond  $ra $dec yellow 2"

}

#affich_un_rond  204.953273 19.237446 green 3 
#affich_un_rond  205.08516  19.184583 green 3 

#      $sources.ra.obj1 configure 
#      $sources.ra.obj1   delete 0 end 
#      $sources.ra.obj1   insert end $::bdi_binast_tools::rajapp
#      $sources.dec.obj1 configure 
#      $sources.dec.obj1   delete 0 end 
#      $sources.dec.obj1   insert end $::bdi_binast_tools::decapp
      $sources.xcalc.$obj configure 
      $sources.xcalc.$obj delete 0 end 
      $sources.xcalc.$obj insert end [format "%.4f" $::bdi_binast_tools::dx ]
      set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,xcalc) [format "%.4f" $::bdi_binast_tools::dx ]
      $sources.ycalc.$obj configure 
      $sources.ycalc.$obj delete 0 end 
      $sources.ycalc.$obj insert end [format "%.4f" $::bdi_binast_tools::dy ]
      set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,ycalc) [format "%.4f" $::bdi_binast_tools::dy ]
#      $sources.ra.$obj configure 
#      $sources.ra.$obj   delete 0 end 
#      $sources.ra.$obj   insert end [mc_angle2hms [ expr  [mc_angle2deg $::bdi_binast_tools::rajapp ] * 15.0 + $::bdi_binast_tools::dx / 3600.0 ] ]
#      $sources.dec.$obj configure 
#      $sources.dec.$obj   delete 0 end 
#      $sources.dec.$obj   insert end [mc_angle2dms [ expr  [mc_angle2deg $::bdi_binast_tools::decapp ] + $::bdi_binast_tools::dy / 3600.0 ] ]

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
             set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,xomc) [format "%.4f" $xomc ]
             set yomc [expr $yobs - $ycalc ]
             $sources.yomc.$obj configure 
             $sources.yomc.$obj delete 0 end 
             $sources.yomc.$obj insert end [format "%.4f" $yomc ]
             set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,yomc) [format "%.4f" $yomc ]
  
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
         #$sources.select.$obj  configure -relief sunken

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
             set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,xobs) [format "%.4f" $dra ]
             set ddec [expr ([mc_angle2deg $decs ] - [mc_angle2deg $decp ]) * 3600.0]
             $sources.yobs.$obj configure 
             $sources.yobs.$obj delete 0 end 
             $sources.yobs.$obj insert end [format "%.4f" $ddec ]
             set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,yobs) [format "%.4f" $ddec ]
         
      
      }




   }
   
   
   
   
   
   
   proc ::bdi_binast_gui::enregistre { sources } {
      
      set id_obj 2

      set fileres "obs-$id_obj.xml"
      set chan0 [open $fileres w]


      for {set i 1} {$i <= $::bdi_binast_tools::nb_img_list} {incr i} {

         if {![info exists ::bdi_binast_tools::tabphotom($i,obj$id_obj,jjdate)]} {
            continue
         }

         set jjdate  $::bdi_binast_tools::tabphotom($i,obj$id_obj,jjdate)
         set isodate $::bdi_binast_tools::tabphotom($i,obj$id_obj,isodate)
         set system      [ $sources.id.obj1 get ]
         set xobs    $::bdi_binast_tools::tabphotom($i,obj$id_obj,xobs)
         set yobs    $::bdi_binast_tools::tabphotom($i,obj$id_obj,yobs)
         set xcalc   $::bdi_binast_tools::tabphotom($i,obj$id_obj,xcalc)
         set ycalc   $::bdi_binast_tools::tabphotom($i,obj$id_obj,ycalc)
         set xomc    $::bdi_binast_tools::tabphotom($i,obj$id_obj,xomc)
         set yomc    $::bdi_binast_tools::tabphotom($i,obj$id_obj,yomc)
         set timescale   "UTC"

         # centerframe = icent dans genoide/eproc
         # centerframe 1 = helio
         # centerframe 2 = geo
         # centerframe 3 = topo
         # centerframe 4 = sonde
         set centerframe 4


         # typeframe = iteph dans genoide/eproc
         # typeframe 1 = astromj2000
         # typeframe 2 = apparent
         # typeframe 3 = moyen date
         # typeframe 4 = moyen J2000
         set typeframe   1

         # coordtype = itrep dans genoide/eproc
         # 1: spheriques, 2: rectangulaires,                   !
         # 3: locales,    4: horaires,                         !
         # 5: dediees a l'observation,                         !
         # 6: dediees a l'observation AO,                      !
         # 7: dediees au calcul (rep. helio. moyen J2000)      !
         set coordtype   1

         # refframe =  ipref dans genoide/eproc
         # 1: equateur, 2:ecliptique  
         set refframe    1

         set obsuai      "@HST"


         puts $chan0 "<vot:TR>"
         puts $chan0 "<vot:TD>$jjdate</vot:TD>"
         puts $chan0 "<vot:TD>$isodate</vot:TD>"
         puts $chan0 "<vot:TD>$system</vot:TD>"
         puts $chan0 "<vot:TD>$xobs</vot:TD>"
         puts $chan0 "<vot:TD>$yobs</vot:TD>"
         puts $chan0 "<vot:TD>$xcalc</vot:TD>"
         puts $chan0 "<vot:TD>$ycalc</vot:TD>"
         puts $chan0 "<vot:TD>$xomc</vot:TD>"
         puts $chan0 "<vot:TD>$yomc</vot:TD>"
         puts $chan0 "<vot:TD>$timescale</vot:TD>"
         puts $chan0 "<vot:TD>$centerframe</vot:TD>"
         puts $chan0 "<vot:TD>$typeframe</vot:TD>"
         puts $chan0 "<vot:TD>$coordtype</vot:TD>"
         puts $chan0 "<vot:TD>$refframe</vot:TD>"
         puts $chan0 "<vot:TD>$obsuai</vot:TD>"
         puts $chan0 "</vot:TR>"
         puts $chan0 ""



      }
      
      close $chan0


   }











 
   proc ::bdi_binast_gui::mesure_tout { sources } {

cleanmark
      gren_info "ZOOM: [::confVisu::getZoom $::audace(visuNo)] \n "

      for {set x 1} {$x<=$::bdi_binast_tools::nb_obj} {incr x} {
            ::bdi_binast_gui::mesure_une $sources obj$x
      }




      return 0

   }
   
   
   
   
   
   






   
      proc ::bdi_binast_gui::mesure_une { sources obj } {

      set ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,err) false
      set err [ catch {set valeurs [::tools_cdl::mesure_obj \
               $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,x) \
               $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,$obj,y) \
               $::bdi_binast_tools::tabsource($obj,delta) $::audace(bufNo)]} msg ]
      if {$err} {
         gren_info "PHOTOM ERR $err : $msg \n "
         return
      } else {
         gren_info "PHOTOM $obj : $valeurs \n "
      }
      
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
         
         affich_un_rond_xy  $xsm $ysm blue [expr int($::bdi_binast_tools::tabsource($obj,delta) / 2.0)] 1
         
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


         if { [lindex $valeurs 7] > $::bdi_binast_tools::saturation} {

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
 




   proc ::bdi_binast_gui::next { sources } {

         set cpt 0
         
         while {$cpt<$::bdi_binast_gui::block} {
         
            if {$::bdi_binast_tools::id_current_image < $::bdi_binast_tools::nb_img_list} {
               incr ::bdi_binast_tools::id_current_image
               ::bdi_binast_gui::charge_current_image
               set err [::bdi_binast_gui::mesure_tout $sources]
               if {$err==1 && $::bdi_binast_tools::stoperreur==1} {
                  break
               }
            }
            incr cpt
         }
   }
   

   proc ::bdi_binast_gui::back { sources } {

         if {$::bdi_binast_tools::id_current_image > 1 } {
            incr ::bdi_binast_tools::id_current_image -1
            ::bdi_binast_gui::charge_current_image
            ::bdi_binast_gui::mesure_tout $sources
         }
   }










   proc ::bdi_binast_gui::charge_current_image { } {

      global audace
      global bddconf

         gren_info "Charge Image id: $::bdi_binast_tools::id_current_image  \n"

         #ï¿½Charge l image en memoire
         set ::bdi_binast_tools::current_image [lindex $::bdi_binast_tools::img_list [expr $::bdi_binast_tools::id_current_image - 1] ]
         set tabkey      [::bddimages_liste::lget $::bdi_binast_tools::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set exposure    [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"]   1] ]

         set idbddimg    [::bddimages_liste::lget $::bdi_binast_tools::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::bdi_binast_tools::current_image dirfilename]
         set filename    [::bddimages_liste::lget $::bdi_binast_tools::current_image filename   ]
         set file        [file join $bddconf(dirbase) $dirfilename $filename]
         set ::bdi_binast_tools::current_image_name $filename
         set ::bdi_binast_tools::current_image_jjdate [expr [mc_date2jd $date] + $exposure / 86400.0 / 2.0]
         set ::bdi_binast_tools::current_image_date [mc_date2iso8601 $::bdi_binast_tools::current_image_jjdate]

         gren_info "\nCharge Image cur: $date  ($exposure)\n"
         #gren_info "Charge Image cur: $::tools_cdl::current_image_date ($::tools_cdl::current_image_jjdate) \n"
         
         #ï¿½Charge l image
         buf$::audace(bufNo) load $file
         cleanmark
       
         # EFFECTUE UNCOSMIC
         if {$::bdi_binast_tools::uncosm == 1} {
            ::tools_cdl::myuncosmic $::audace(bufNo)
         }
         
         # VIsualisation par Sseuil automatique
         ::audace::autovisu $::audace(visuNo)
          
         catch {
          
            #ï¿½Mise a jour GUI
            $::bdi_binast_gui::fen.frm_cdlwcs.bouton.back configure -state disabled
            $::bdi_binast_gui::fen.frm_cdlwcs.bouton.back configure -state disabled
            $::bdi_binast_gui::fen.frm_cdlwcs.infoimage.nomimage    configure -text $::bdi_binast_tools::current_image_name
            $::bdi_binast_gui::fen.frm_cdlwcs.infoimage.dateimage   configure -text $::bdi_binast_tools::current_image_date
            $::bdi_binast_gui::fen.frm_cdlwcs.infoimage.stimage     configure -text "$::bdi_binast_tools::id_current_image / $::bdi_binast_tools::nb_img_list"

            gren_info " $::bdi_binast_tools::current_image_name \n"

            if {$::bdi_binast_tools::id_current_image == 1 && $::bdi_binast_tools::nb_img_list > 1 } {
               $::bdi_binast_gui::fen.frm_cdlwcs.bouton.back configure -state disabled
            }
            if {$::bdi_binast_tools::id_current_image == $::bdi_binast_tools::nb_img_list && $::bdi_binast_tools::nb_img_list > 1 } {
               $::bdi_binast_gui::fen.frm_cdlwcs.bouton.next configure -state disabled
            }
            if {$::bdi_binast_tools::id_current_image > 1 } {
               $::bdi_binast_gui::fen.frm_cdlwcs.bouton.back configure -state normal
            }
            if {$::bdi_binast_tools::id_current_image < $::bdi_binast_tools::nb_img_list } {
               $::bdi_binast_gui::fen.frm_cdlwcs.bouton.next configure -state normal
            }
         
            set sources $::bdi_binast_gui::fen.frm_cdlwcs.sources
            for {set x 1} {$x<=$::bdi_binast_tools::nb_obj} {incr x} {

               $sources.ra.obj$x delete 0 end 
               $sources.dec.obj$x delete 0 end 
               $sources.xobs.obj$x delete 0 end 
               $sources.yobs.obj$x delete 0 end 
               $sources.xcalc.obj$x delete 0 end 
               $sources.ycalc.obj$x delete 0 end 
               $sources.xomc.obj$x delete 0 end 
               $sources.yomc.obj$x delete 0 end 

               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,ra_hms)]} {
                  $sources.ra.obj$x configure 
                  $sources.ra.obj$x   delete 0 end 
                  $sources.ra.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,ra_hms)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,dec_hms)]} {
                  $sources.dec.obj$x configure 
                  $sources.dec.obj$x   delete 0 end 
                  $sources.dec.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,dec_hms)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,xobs)]} {
                  $sources.xobs.obj$x configure 
                  $sources.xobs.obj$x   delete 0 end 
                  $sources.xobs.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,xobs)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,yobs)]} {
                  $sources.yobs.obj$x configure 
                  $sources.yobs.obj$x   delete 0 end 
                  $sources.yobs.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,yobs)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,xomc)]} {
                  $sources.xomc.obj$x configure 
                  $sources.xomc.obj$x   delete 0 end 
                  $sources.xomc.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,xomc)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,yomc)]} {
                  $sources.yomc.obj$x configure 
                  $sources.yomc.obj$x   delete 0 end 
                  $sources.yomc.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,yomc)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,xcalc)]} {
                  $sources.xcalc.obj$x configure 
                  $sources.xcalc.obj$x   delete 0 end 
                  $sources.xcalc.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,xcalc)
               }
               if {[info exists ::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,ycalc)]} {
                  $sources.ycalc.obj$x configure 
                  $sources.ycalc.obj$x   delete 0 end 
                  $sources.ycalc.obj$x   insert end $::bdi_binast_tools::tabphotom($::bdi_binast_tools::id_current_image,obj$x,ycalc)
               }

            }
         }
         
         
      
   }










   
}
