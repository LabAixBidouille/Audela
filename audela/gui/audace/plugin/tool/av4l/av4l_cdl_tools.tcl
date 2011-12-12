#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_cdl_tools.tcl
#--------------------------------------------------
#
# Fichier        : av4l_cdl_tools.tcl
# Description    : Utilitaires pour le calcul des courbes de lumiere
# Auteur         : Frederic Vachier
# Mise à jour $Id: av4l_ocr_gui.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::av4l_cdl_tools {


   variable obj
   variable ref
   variable delta
   variable mesure
   variable file_mesure
   variable sortie

 
   #
   # Existance et chargement d un fichier time
   #
   proc ::av4l_cdl_tools::file_time_exist {  } {

      for  {set x 1} {$x<=$::av4l_tools::nb_open_frames} {incr x} {
         set ::av4l_ocr_tools::timing($x,jd)  ""
         set ::av4l_ocr_tools::timing($x,dateiso) ""
      }


      set filename [::av4l_ocr_tools::get_filename_time]
      if { [file exists $filename] } {
         set reponse [tk_messageBox -message "Un fichier 'time' a �t� trouv�\nVoulez vous l'associer ?" -type yesno]
         if { $reponse == "yes"} {
            set f [open $filename "r"]
            set cpt 0
            while {1} {
                set line [gets $f]
                if {[eof $f]} {
                    close $f
                    break
                }
                if {$cpt > 2} {
                   set tab [ split $line "," ]
                   set id [string trim [lindex $tab 0] " "]
                   set jd [string trim [lindex $tab 1] " "]
                   set dateiso [string trim [lindex $tab 2] " "]
                   set ::av4l_ocr_tools::timing($id,dateiso) $dateiso
                   set ::av4l_ocr_tools::timing($id,jd) $jd
                }
                incr cpt
            }
            tk_messageBox -message "Fichier 'time' charg�." -type ok
         }

      }

   }



   #
   # Ouverture d un flux
   #
   proc ::av4l_cdl_tools::open_flux { visuNo frm } {

      ::av4l_tools::open_flux $visuNo $frm
      ::av4l_cdl_tools::file_time_exist

   }

   #
   # Selection d un flux
   #
   proc ::av4l_cdl_tools::select { visuNo frm } {

      ::av4l_tools::select $visuNo $frm
      ::av4l_cdl_tools::file_time_exist

   }


   #
   # Sauvegarde la courbe lumiere  en memoire
   #
   proc ::av4l_cdl_tools::save { visuNo frm } {
 

      if { $::av4l_tools::traitement=="fits" } {
         set filename [file join ${::av4l_tools::destdir} "${::av4l_tools::prefix}"]
      }

      if { $::av4l_tools::traitement=="avi" }  {
         set filename $::av4l_tools::avi_filename
         if { ! [file exists $filename] } {
         ::console::affiche_erreur "Charger une video ...\n"
         } 
      }

      set racinefilename "${filename}."

      set sortie 0
      set idfile 0
      while {$sortie == 0} {
         set idd [format "%05d" $idfile]
         set filename "${racinefilename}${idd}.csv"
         if { [file exists $filename] } {
         #::console::affiche_resultat "existe ${filename} ...\n"
         } else {
         set sortie 1
         }
         incr idfile
      }

      ::console::affiche_resultat "Sauvegarde dans ${filename} ..."
      set f1 [open $filename "w"]
      puts $f1 "# ** AV4L - Audela - Linux  * "
      puts $f1 "#FPS = 25"
      set line "idframe,"
      append line "jd,"
      append line "dateiso,"
      append line "obj_fint     ,"
      append line "obj_pixmax   ,"
      append line "obj_intensite,"
      append line "obj_sigmafond,"
      append line "obj_snint    ,"
      append line "obj_snpx     ,"
      append line "obj_delta    ,"
      append line "obj_xpos,"
      append line "obj_ypos,"
      append line "obj_xfwhm,"
      append line "obj_yfwhm,"
      append line "ref_fint     ,"
      append line "ref_pixmax   ,"
      append line "ref_intensite,"
      append line "ref_sigmafond,"
      append line "ref_snint    ,"
      append line "ref_snpx     ,"
      append line "ref_delta    ,"
      append line "ref_xpos,"
      append line "ref_ypos,"
      append line "ref_xfwhm,"
      append line "ref_yfwhm,"
      append line "img_intmin ,"
      append line "img_intmax,"
      append line "img_intmoy,"
      append line "img_sigma ,"
      append line "img_xsize,"
      append line "img_ysize"
      puts $f1 $line


      set sortie 0
      set idframe 1
      set cpt 0
      while {$sortie == 0} {

         if {$idframe == $::av4l_tools::nb_frames} {
            set sortie 1
         }
         
         if { [info exists ::av4l_cdl_tools::mesure($idframe,mesure_obj)] && $::av4l_cdl_tools::mesure($idframe,mesure_obj) == 1 } {
            set reste [expr $::av4l_tools::nb_frames-$idframe]

            set line "$idframe,"
            append line "$::av4l_ocr_tools::timing($idframe,jd)           ,"
            append line "$::av4l_ocr_tools::timing($idframe,dateiso)      ,"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_fint)     ,"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_pixmax)   ,"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_intensite),"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_sigmafond),"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_snint)    ,"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_snpx)     ,"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_delta)    ,"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_xpos),"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_ypos),"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_xfwhm),"
            append line "$::av4l_cdl_tools::mesure($idframe,obj_yfwhm),"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_fint)     ,"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_pixmax)   ,"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_intensite),"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_sigmafond),"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_snint)    ,"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_snpx)     ,"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_delta)    ,"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_xpos),"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_ypos),"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_xfwhm),"
            append line "$::av4l_cdl_tools::mesure($idframe,ref_yfwhm),"
            append line "$::av4l_cdl_tools::mesure($idframe,img_intmin) ,"
            append line "$::av4l_cdl_tools::mesure($idframe,img_intmax),"
            append line "$::av4l_cdl_tools::mesure($idframe,img_intmoy),"
            append line "$::av4l_cdl_tools::mesure($idframe,img_sigma) ,"
            append line "$::av4l_cdl_tools::mesure($idframe,img_xsize),"
            append line "$::av4l_cdl_tools::mesure($idframe,img_ysize)"
            
            
            puts $f1 $line
            incr cpt
         }
         
         incr idframe
      }

      close $f1
      ::console::affiche_resultat "nb frame save = $cpt   .. Fin  ..\n"
      

   }
   



   




   #
   # Stop les mesures photometriques
   #
   proc ::av4l_cdl_tools::stop { } {
         
      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_cdl_tools_fits::stop
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_cdl_tools::stop
      }

   }
   










   #
   # 
   #
   proc ::av4l_cdl_tools::mesure_obj_avance { visuNo frm } {

      cleanmark

      set delta [ $frm.photom.values.object.v.r.delta get]
      set statebutton [ $frm.photom.values.object.t.select cget -relief]
      if { $statebutton=="sunken" } {
         ::av4l_cdl_tools::mesure_obj $::av4l_cdl_tools::obj(x) $::av4l_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
      }

   }
 
 
 





   #
   # 
   #
   proc ::av4l_cdl_tools::mesure_ref_avance { visuNo frm } {

      cleanmark

      set delta [ $frm.photom.values.reference.v.r.delta get]
      set statebutton [ $frm.photom.values.reference.t.select cget -relief]
      if { $statebutton=="sunken" } {
         ::av4l_cdl_tools::mesure_ref $::av4l_cdl_tools::ref(x) $::::av4l_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
      }

   }
 




   #
   # Effectue la photometrie de la reference et l affiche
   #
   proc ::av4l_cdl_tools::mesure_ref { xsm ysm visuNo frm delta} {
         
      global color
         
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set err 0
      
      set err [ catch { set valeurs  [::av4l_photom::mesure_obj $xsm $ysm $delta $bufNo] } msg ]

      if {$err>0} { 
         ::console::affiche_erreur $msg
         $frm.v.r.position  configure -text "?" -fg $color(blue)
         $frm.v.r.delta     configure -text "?" -fg $color(blue)
         $frm.v.r.fint      configure -text "?" -fg $color(blue)
         $frm.v.r.fwhm      configure -text "?" -fg $color(blue)
         $frm.v.r.pixmax    configure -text "?" -fg $color(blue)
         $frm.v.r.intensite configure -text "?" -fg $color(blue)
         $frm.v.r.sigmafond configure -text "?" -fg $color(blue)
         $frm.v.r.snint     configure -text "?" -fg $color(blue)
         $frm.v.r.snpx      configure -text "?" -fg $color(blue)
         return
      }
      
      set xsm         [lindex $valeurs 0]
      set ysm         [lindex $valeurs 1]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 3]
      set fwhm        [lindex $valeurs 4]
      set fluxintegre [lindex $valeurs 5]
      set errflux     [lindex $valeurs 6]
      set pixmax      [lindex $valeurs 7]
      set intensite   [lindex $valeurs 8]
      set sigmafond   [lindex $valeurs 9]
      set snint       [lindex $valeurs 10]
      set snpx        [lindex $valeurs 11]
      set delta       [lindex $valeurs 12]

      set visupos       "[format "%4.2f" $xsm] / [format "%4.2f" $ysm]"
      set visudelta     [format "%5.2f" $delta]
      set visufint      [format "%5.2f" $fluxintegre]
      set visufwhm      "[format "%4.2f" $fwhmx] / [format "%4.2f" $fwhmy]"
      set visupixmax    [format "%5.2f" $pixmax]
      set visuintensite [format "%5.2f" $intensite]
      set visusigmafond [format "%5.2f" $sigmafond]
      set visusnint     [format "%5.2f" $snint]
      set visusnpx      [format "%5.2f" $snpx]

      $frm.v.r.position     configure -text "$visupos"       -fg $color(blue)
      $frm.v.r.fint         configure -text "$visufint"      -fg $color(blue)
      $frm.v.r.fwhm         configure -text "$visufwhm"      -fg $color(blue)
      $frm.v.r.pixmax       configure -text "$visupixmax"    -fg $color(blue)
      $frm.v.r.intensite    configure -text "$visuintensite" -fg $color(blue)
      $frm.v.r.sigmafond    configure -text "$visusigmafond" -fg $color(blue)
      $frm.v.r.snint        configure -text "$visusnint"     -fg $color(blue)
      $frm.v.r.snpx         configure -text "$visusnpx"      -fg $color(blue)
      
      set ::av4l_cdl_tools::ref(x) [format "%4.2f" $xsm]
      set ::av4l_cdl_tools::ref(y) [format "%4.2f" $ysm]
      ::bddimages_cdl::affich_un_rond [expr $xsm + 1] [expr $ysm - 1] blue $delta
   }


   #
   # Effectue la photometrie de l objet et l affiche
   #
   proc ::av4l_cdl_tools::mesure_obj { xsm ysm visuNo frm delta} {
         
      global color
         
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set err 0
      
      set err [ catch { set valeurs  [::av4l_photom::mesure_obj $xsm $ysm $delta $bufNo] } msg ]

      if {$err>0} { 
         ::console::affiche_erreur $msg
         $frm.v.r.position  configure -text "?" -fg $color(blue)
         $frm.v.r.delta     configure -text "?" -fg $color(blue)
         $frm.v.r.fint      configure -text "?" -fg $color(blue)
         $frm.v.r.fwhm      configure -text "?" -fg $color(blue)
         $frm.v.r.pixmax    configure -text "?" -fg $color(blue)
         $frm.v.r.intensite configure -text "?" -fg $color(blue)
         $frm.v.r.sigmafond configure -text "?" -fg $color(blue)
         $frm.v.r.snint     configure -text "?" -fg $color(blue)
         $frm.v.r.snpx      configure -text "?" -fg $color(blue)
         return
      }
      
      set xsm         [lindex $valeurs 0]
      set ysm         [lindex $valeurs 1]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 3]
      set fwhm        [lindex $valeurs 4]
      set fluxintegre [lindex $valeurs 5]
      set errflux     [lindex $valeurs 6]
      set pixmax      [lindex $valeurs 7]
      set intensite   [lindex $valeurs 8]
      set sigmafond   [lindex $valeurs 9]
      set snint       [lindex $valeurs 10]
      set snpx        [lindex $valeurs 11]
      set delta       [lindex $valeurs 12]

      set visupos       "[format "%4.2f" $xsm] / [format "%4.2f" $ysm]"
      set visudelta     [format "%5.2f" $delta]
      set visufint      [format "%5.2f" $fluxintegre]
      set visufwhm      "[format "%4.2f" $fwhmx] / [format "%4.2f" $fwhmy]"
      set visupixmax    [format "%5.2f" $pixmax]
      set visuintensite [format "%5.2f" $intensite]
      set visusigmafond [format "%5.2f" $sigmafond]
      set visusnint     [format "%5.2f" $snint]
      set visusnpx      [format "%5.2f" $snpx]

      $frm.v.r.position     configure -text "$visupos"       -fg $color(blue)
      $frm.v.r.fint         configure -text "$visufint"      -fg $color(blue)
      $frm.v.r.fwhm         configure -text "$visufwhm"      -fg $color(blue)
      $frm.v.r.pixmax       configure -text "$visupixmax"    -fg $color(blue)
      $frm.v.r.intensite    configure -text "$visuintensite" -fg $color(blue)
      $frm.v.r.sigmafond    configure -text "$visusigmafond" -fg $color(blue)
      $frm.v.r.snint        configure -text "$visusnint"     -fg $color(blue)
      $frm.v.r.snpx         configure -text "$visusnpx"      -fg $color(blue)
      
      set ::av4l_cdl_tools::obj(x) [format "%4.2f" $xsm]
      set ::av4l_cdl_tools::obj(y) [format "%4.2f" $ysm]
      ::bddimages_cdl::affich_un_rond [expr $xsm + 1] [expr $ysm - 1] green $delta
   }









   #
   # 
   #
   proc ::av4l_cdl_tools::select_fullimg { visuNo this } {

      global color

      set statebutton [ $this.t.select cget -relief]

      # desactivation
      if {$statebutton=="sunken"} {
         $this.v.r.fenetre configure -text   "?"
         $this.v.r.intmin  configure -text   "?"
         $this.v.r.intmax  configure -text   "?"
         $this.v.r.intmoy  configure -text   "?"
         $this.v.r.sigma   configure -text   "?"
         $this.t.select    configure -relief raised
         return
      } 


      # activation
      if {$statebutton=="raised"} {

         # Recuperation du Rectangle de l image
         set rect [ ::confVisu::getBox $visuNo ]

         # Affichage de la taille de la fenetre
         if {$rect==""} {
            $this.v.r.fenetre configure -text "Error" -fg $color(red)
            set ::av4l_photom::rect_img ""
         } else {
            set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
            set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
            $this.v.r.fenetre configure -text "${taillex}x${tailley}" -fg $color(blue)
            set ::av4l_photom::rect_img $rect
         }
         ::av4l_cdl_tools::get_fullimg $visuNo $this
         $this.t.select  configure -relief sunken
         return

      }

   }




   #
   # Selection de la zone dans l image correspond a l image effective. 
   # Sans l inscrustation de la date par exemple
   #
   proc ::av4l_cdl_tools::get_fullimg { visuNo frm } {

      #::console::affiche_resultat "Arect_img = $::av4l_photom::rect_img \n"

      if { ! [info exists ::av4l_photom::rect_img] } {
         return
      }


      if {$::av4l_photom::rect_img==""} {
         $frm.v.r.fenetre configure -text "?"
         $frm.v.r.intmin  configure -text "?"
         $frm.v.r.intmax  configure -text "?"
         $frm.v.r.intmoy  configure -text "?"
         $frm.v.r.sigma   configure -text "?"

      } else {

         set bufNo [ ::confVisu::getBufNo $visuNo ]

         set stat [buf$bufNo stat $::av4l_photom::rect_img]

         $frm.v.r.intmin configure -text [lindex $stat 3]
         $frm.v.r.intmax configure -text [lindex $stat 2]
         $frm.v.r.intmoy configure -text [lindex $stat 4]
         $frm.v.r.sigma  configure -text [lindex $stat 5]
      }


   }










   
   #
   # Selection d un objet a partir d une getBox sur l image
   #
   proc ::av4l_cdl_tools::select_obj { visuNo frm } {
   
      global color
   
      set statebutton [ $frm.t.select cget -relief]

      # activation
      if {$statebutton=="raised"} {

         set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]

         if {$err>0 || $rect ==""} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm.v.r.position configure -text "Selectionnez un cadre" -fg $color(red)
            return
         }

         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set err [ catch {set valeurs  [::av4l_photom::select_obj $rect $bufNo]} msg ]
         
         if {$err>0} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Mesure Photometrique impossible\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm.v.r.position configure -text "Error" -fg $color(red)
            return
         }
         
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set delta 5
         $frm.v.r.delta delete 0 end
         $frm.v.r.delta insert 0 $delta
         ::av4l_cdl_tools::mesure_obj $xsm $ysm $visuNo $frm $delta
         $frm.t.select  configure -relief sunken
         return
      } 
      
      # desactivation
      if {$statebutton=="sunken"} {

         $frm.v.r.position  configure -text "?" 
         $frm.v.r.delta     configure -text "?" 
         $frm.v.r.fint      configure -text "?" 
         $frm.v.r.fwhm      configure -text "?" 
         $frm.v.r.pixmax    configure -text "?" 
         $frm.v.r.intensite configure -text "?" 
         $frm.v.r.sigmafond configure -text "?" 
         $frm.v.r.snint     configure -text "?" 
         $frm.v.r.snpx      configure -text "?" 

         $frm.t.select  configure -relief raised
         return
      } 
      
      $frm.t.select  configure -relief raised
      return

   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   #
   # Selection d une reference a partir d une getBox sur l image
   #
   proc ::av4l_cdl_tools::select_ref { visuNo frm } {
   
      global color
   
      set statebutton [ $frm.t.select cget -relief]

      # activation
      if {$statebutton=="raised"} {

         set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]

         if {$err>0 || $rect ==""} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm.v.r.position configure -text "Selectionnez un cadre" -fg $color(red)
            return
         }

         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set err [ catch {set valeurs  [::av4l_photom::select_obj $rect $bufNo]} msg ]
         
         if {$err>0} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Mesure Photometrique impossible\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm.v.r.position configure -text "Error" -fg $color(red)
            return
         }
         
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set delta 5
         $frm.v.r.delta delete 0 end
         $frm.v.r.delta insert 0 $delta
         ::av4l_cdl_tools::mesure_ref $xsm $ysm $visuNo $frm $delta
         $frm.t.select  configure -relief sunken
         return
      } 
      
      # desactivation
      if {$statebutton=="sunken"} {

         $frm.v.r.position  configure -text "?" 
         $frm.v.r.delta     configure -text "?" 
         $frm.v.r.fint      configure -text "?" 
         $frm.v.r.fwhm      configure -text "?" 
         $frm.v.r.pixmax    configure -text "?" 
         $frm.v.r.intensite configure -text "?" 
         $frm.v.r.sigmafond configure -text "?" 
         $frm.v.r.snint     configure -text "?" 
         $frm.v.r.snpx      configure -text "?" 

         $frm.t.select  configure -relief raised
         return
      } 
      
      $frm.t.select  configure -relief raised
      return

   }
   
   
   
   #
   # Retour Rapide
   #
   proc ::av4l_cdl_tools::quick_prev_image { visuNo frm } {
         
       cleanmark
       ::av4l_tools::quick_prev_image $visuNo

       set statebutton [ $frm.photom.values.object.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.object.v.r.delta get]
          ::av4l_cdl_tools::mesure_obj $::av4l_cdl_tools::obj(x) $::av4l_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
       }
       set statebutton [ $frm.photom.values.reference.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.reference.v.r.delta get]
          ::av4l_cdl_tools::mesure_ref $::av4l_cdl_tools::ref(x) $::av4l_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
       }
       set statebutton [ $frm.photom.values.image.t.select cget -relief]
       if { $statebutton=="sunken" } {
       ::av4l_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
       }
      
   }
 

   #
   # avance rapide
   #
   proc ::av4l_cdl_tools::quick_next_image { visuNo frm } {
         
       cleanmark
       ::av4l_tools::quick_next_image $visuNo

       set statebutton [ $frm.photom.values.object.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.object.v.r.delta get]
          ::av4l_cdl_tools::mesure_obj $::av4l_cdl_tools::obj(x) $::av4l_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
       }
       set statebutton [ $frm.photom.values.reference.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.reference.v.r.delta get]
          ::av4l_cdl_tools::mesure_ref $::av4l_cdl_tools::ref(x) $::av4l_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
       }
       set statebutton [ $frm.photom.values.image.t.select cget -relief]
       if { $statebutton=="sunken" } {
       ::av4l_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
       }
   
   }
   

   #
   # Passe a l image suivante
   #
   proc ::av4l_cdl_tools::next_image { visuNo frm } {
         
       cleanmark
       ::av4l_tools::next_image $visuNo

       set statebutton [ $frm.photom.values.object.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.object.v.r.delta get]
          ::av4l_cdl_tools::mesure_obj $::av4l_cdl_tools::obj(x) $::av4l_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
       }
       set statebutton [ $frm.photom.values.reference.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.reference.v.r.delta get]
          ::av4l_cdl_tools::mesure_ref $::av4l_cdl_tools::ref(x) $::av4l_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
       }
       set statebutton [ $frm.photom.values.image.t.select cget -relief]
       if { $statebutton=="sunken" } {
       ::av4l_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
       }

   }


   #
   # Passe a l image precedente
   #
   proc ::av4l_cdl_tools::prev_image { visuNo frm } {
         
       cleanmark
       ::av4l_tools::prev_image $visuNo

       set statebutton [ $frm.photom.values.object.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.object.v.r.delta get]
          ::av4l_cdl_tools::mesure_obj $::av4l_cdl_tools::obj(x) $::av4l_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
       }
       set statebutton [ $frm.photom.values.reference.t.select cget -relief]
       if { $statebutton=="sunken" } {
          set delta [ $frm.photom.values.reference.v.r.delta get]
          ::av4l_cdl_tools::mesure_ref $::av4l_cdl_tools::ref(x) $::av4l_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
       }
       set statebutton [ $frm.photom.values.image.t.select cget -relief]
       if { $statebutton=="sunken" } {
       ::av4l_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
       }

   }
   
   
















   #
   # Lance les mesures photometriques
   #
   proc ::av4l_cdl_tools::start { visuNo frm } {
 
      set ::av4l_cdl_tools::sortie 0
      set cpt 0
      $frm.action.start configure -image .stop
      $frm.action.start configure -relief sunken     
      $frm.action.start configure -command " ::av4l_cdl_tools::stop" 
      
      while {$::av4l_cdl_tools::sortie == 0} {

         set idframe $::av4l_tools::cur_idframe
         ::console::affiche_resultat "\[$idframe / $::av4l_tools::nb_frames / [expr $::av4l_tools::nb_frames-$idframe] \]\n"
         if {$idframe == $::av4l_tools::nb_frames} {
            set ::av4l_cdl_tools::sortie 1
         }
          
         cleanmark
         
         set statebutton [ $frm.photom.values.object.t.select cget -relief]
         if { $statebutton=="sunken" } {
            set delta [ $frm.photom.values.object.v.r.delta get]
            ::av4l_cdl_tools::mesure_obj $::av4l_cdl_tools::obj(x) $::av4l_cdl_tools::obj(y) $visuNo $frm.photom.values.object $delta
         }
         set statebutton [ $frm.photom.values.reference.t.select cget -relief]
         if { $statebutton=="sunken" } {
            set delta [ $frm.photom.values.reference.v.r.delta get]
            ::av4l_cdl_tools::mesure_ref $::av4l_cdl_tools::ref(x) $::av4l_cdl_tools::ref(y) $visuNo $frm.photom.values.reference $delta
         }
         set statebutton [ $frm.photom.values.image.t.select cget -relief]
         if { $statebutton=="sunken" } {
         ::av4l_cdl_tools::get_fullimg $visuNo $frm.photom.values.image
         }

         set ::av4l_cdl_tools::mesure($idframe,mesure_obj) 1


         # mesure objet
         set ::av4l_cdl_tools::mesure($idframe,obj_delta)     [$frm.photom.values.object.v.r.delta     get]
         set ::av4l_cdl_tools::mesure($idframe,obj_fint)      [$frm.photom.values.object.v.r.fint      cget -text]
         set ::av4l_cdl_tools::mesure($idframe,obj_pixmax)    [$frm.photom.values.object.v.r.pixmax    cget -text]
         set ::av4l_cdl_tools::mesure($idframe,obj_intensite) [$frm.photom.values.object.v.r.intensite cget -text]
         set ::av4l_cdl_tools::mesure($idframe,obj_sigmafond) [$frm.photom.values.object.v.r.sigmafond cget -text]
         set ::av4l_cdl_tools::mesure($idframe,obj_snint)     [$frm.photom.values.object.v.r.snint     cget -text]
         set ::av4l_cdl_tools::mesure($idframe,obj_snpx)      [$frm.photom.values.object.v.r.snpx      cget -text]

         set position  [$frm.photom.values.object.v.r.position  cget -text]
         set poslist [split $position "/"]
         set ::av4l_cdl_tools::mesure($idframe,obj_xpos) [lindex $poslist 0]
         set ::av4l_cdl_tools::mesure($idframe,obj_ypos) [lindex $poslist 1]
         if {$::av4l_cdl_tools::mesure($idframe,obj_ypos)==""} { set ::av4l_cdl_tools::mesure($idframe,obj_ypos) "?" }

         set fwhm      [$frm.photom.values.object.v.r.fwhm cget -text]
         set fwhmlist [split $fwhm "/"]
         set ::av4l_cdl_tools::mesure($idframe,obj_xfwhm) [lindex $fwhmlist 0]
         set ::av4l_cdl_tools::mesure($idframe,obj_yfwhm) [lindex $fwhmlist 1]
         if {$::av4l_cdl_tools::mesure($idframe,obj_yfwhm)==""} {set ::av4l_cdl_tools::mesure($idframe,obj_yfwhm) "?" }

         # mesure reference
         set ::av4l_cdl_tools::mesure($idframe,ref_delta)     [$frm.photom.values.reference.v.r.delta     get]
         set ::av4l_cdl_tools::mesure($idframe,ref_fint)      [$frm.photom.values.reference.v.r.fint      cget -text]
         set ::av4l_cdl_tools::mesure($idframe,ref_pixmax)    [$frm.photom.values.reference.v.r.pixmax    cget -text]
         set ::av4l_cdl_tools::mesure($idframe,ref_intensite) [$frm.photom.values.reference.v.r.intensite cget -text]
         set ::av4l_cdl_tools::mesure($idframe,ref_sigmafond) [$frm.photom.values.reference.v.r.sigmafond cget -text]
         set ::av4l_cdl_tools::mesure($idframe,ref_snint)     [$frm.photom.values.reference.v.r.snint     cget -text]
         set ::av4l_cdl_tools::mesure($idframe,ref_snpx)      [$frm.photom.values.reference.v.r.snpx      cget -text]

         set position  [$frm.photom.values.reference.v.r.position  cget -text]
         set poslist [split $position "/"]
         set ::av4l_cdl_tools::mesure($idframe,ref_xpos) [lindex $poslist 0]
         set ::av4l_cdl_tools::mesure($idframe,ref_ypos) [lindex $poslist 1]
         if {$::av4l_cdl_tools::mesure($idframe,ref_ypos)==""} { set ::av4l_cdl_tools::mesure($idframe,ref_ypos) "?" }

         set fwhm      [$frm.photom.values.reference.v.r.fwhm cget -text]
         set fwhmlist [split $fwhm "/"]
         set ::av4l_cdl_tools::mesure($idframe,ref_xfwhm) [lindex $fwhmlist 0]
         set ::av4l_cdl_tools::mesure($idframe,ref_yfwhm) [lindex $fwhmlist 1]
         if {$::av4l_cdl_tools::mesure($idframe,ref_yfwhm)==""} {set ::av4l_cdl_tools::mesure($idframe,ref_yfwhm) "?" }

         # mesure image
         set ::av4l_cdl_tools::mesure($idframe,img_intmin)  [$frm.photom.values.image.v.r.intmin  cget -text]
         set ::av4l_cdl_tools::mesure($idframe,img_intmax)  [$frm.photom.values.image.v.r.intmax  cget -text]
         set ::av4l_cdl_tools::mesure($idframe,img_intmoy)  [$frm.photom.values.image.v.r.intmoy  cget -text]
         set ::av4l_cdl_tools::mesure($idframe,img_sigma)   [$frm.photom.values.image.v.r.sigma   cget -text]

         set fenetre  [$frm.photom.values.image.v.r.fenetre  cget -text]
         set fenetrelist [split $fenetre "x"]
         set ::av4l_cdl_tools::mesure($idframe,img_xsize) [lindex $fenetrelist 0]
         set ::av4l_cdl_tools::mesure($idframe,img_ysize) [lindex $fenetrelist 1]
         if {$::av4l_cdl_tools::mesure($idframe,img_ysize)==""} { set ::av4l_cdl_tools::mesure($idframe,img_ysize) "?" }


         ::av4l_tools::next_image $visuNo
      }

      $frm.action.start configure -image .start
      $frm.action.start configure -relief raised     
      $frm.action.start configure -command "::av4l_cdl_tools::start $visuNo $frm" 

   }







   #
   # Stop les mesures photometriques
   #
   proc ::av4l_cdl_tools::stop {  } {

      ::console::affiche_resultat "-- stop \n"
      set ::av4l_cdl_tools::sortie 1

   }   
 
   
 

}
