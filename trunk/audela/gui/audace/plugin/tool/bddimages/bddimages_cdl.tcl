#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_cdl.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_admin_image.tcl
# Description    : Environnement de gestion des listes d images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6969 2011-03-16 17:12:35Z fredvachier $
#
#--------------------------------------------------
# - Namespace bddimages_cdl
# - Fichiers source externe :
#       bddimages_cdl.cap
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
# { {NAXIS1 1024} {NAXIS2 1024} etc ... }
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

namespace eval bddimages_cdl {

   global audace
   global bddconf
   global caption

   variable interpol_aster interpol_star1
   variable img_list
   variable file_result_m1
   variable file_result_m2
   variable file_result_m3
   variable stop
   variable delta_star
   variable delta_aster
   variable magstar

























   proc ::bddimages_cdl::run {  } {

    ::bddimages_cdl::init
    if { $::bddimages_cdl::stop == 0} {
       ::bddimages_cdl::mesure_images
    }
    ::console::affiche_resultat "Fin script CdL... \n"   
    return
    }













   proc ::bddimages_cdl::init {  } {

    global bddconf

        set ::bddimages_cdl::magstar 13.69
    set ::bddimages_cdl::stop 0
    # Recuperation des informations des images selectionnees
    set selection_list [::bddimages_imgcorrection::get_info_img]
    # Chargement de la liste IMG
    set ::bddimages_cdl::img_list [::bddimages_imgcorrection::select_img_list_by_type IMG CORR $selection_list]
    set nbimg  [llength $::bddimages_cdl::img_list]
    ::console::affiche_resultat "nbimg : $nbimg\n"
    set ::bddimages_cdl::img_list [::bddimages_imgcorrection::chrono_sort_img $::bddimages_cdl::img_list]

    # Chargement de la premiere image de la liste
    set img [::bddimages_imgcorrection::chrono_first_img $::bddimages_cdl::img_list]
    set filename [::bddimages_liste::lget $img "filename"]
    set dirfilename [::bddimages_liste::lget $img "dirfilename"]
    set tabkey  [::bddimages_liste::lget $img "tabkey"]
    set dateobs [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
    set commundatejj [::bddimages_liste::lget $img "commundatejj"]
    ::console::affiche_resultat "file : $dirfilename/$filename\n"
    ::console::affiche_resultat "first dateobs $dateobs \n"
    set file [file join $bddconf(dirbase) $dirfilename $filename]
    loadima $file
    set td $commundatejj

    # Selection de l etoile
    set star_deb [::bddimages_cdl::select_source "Selection de l etoile" 1]
    ::bddimages_cdl::affich_un_rond  [lindex $star_deb 0] [lindex $star_deb 1] "yellow"
    if {$::bddimages_cdl::stop} {return}
    lappend star_deb $commundatejj
    ::console::affiche_resultat "star : $star_deb\n"

    # Selection de l asteroide
    set aster_deb [::bddimages_cdl::select_source "Selection de l asteroide" 0]
    ::bddimages_cdl::affich_un_rond  [lindex $aster_deb 0] [lindex $aster_deb 1] "green"
    if {$::bddimages_cdl::stop} {return}
    lappend aster_deb $commundatejj
    ::console::affiche_resultat "aster : $aster_deb\n"

    # Chargement de la derniere image
    set img [::bddimages_imgcorrection::chrono_last_img $::bddimages_cdl::img_list]
    set filename [::bddimages_liste::lget $img "filename"]
    set dirfilename [::bddimages_liste::lget $img "dirfilename"]
    set tabkey  [::bddimages_liste::lget $img "tabkey"]
    set dateobs [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
    set commundatejj [::bddimages_liste::lget $img "commundatejj"]
    ::console::affiche_resultat "file : $dirfilename/$filename\n"
    ::console::affiche_resultat "last dateobs $dateobs \n"
    set file [file join $bddconf(dirbase) $dirfilename $filename]
    loadima $file
    set tf $commundatejj

    #Selection de l etoile
    set star_fin [::bddimages_cdl::select_source "Selection de l etoile" 0]
    ::bddimages_cdl::affich_un_rond  [lindex $star_fin 0] [lindex $star_fin 1] "yellow"
    if {$::bddimages_cdl::stop} {return}
    lappend star_fin $commundatejj

    ::console::affiche_resultat "star : $star_fin\n"
    #Selection de l asteroide
    set aster_fin [::bddimages_cdl::select_source "Selection de l asteroide" 0]
    ::bddimages_cdl::affich_un_rond  [lindex $aster_fin 0] [lindex $aster_fin 1] "green"
    if {$::bddimages_cdl::stop} {return}
    lappend aster_fin $commundatejj
    ::console::affiche_resultat "aster : $aster_fin\n"


      set xd [lindex $aster_deb 0]
      set yd [lindex $aster_deb 1]
      set xf [lindex $aster_fin 0]
      set yf [lindex $aster_fin 1]

      set ::bddimages_cdl::interpol_aster [list $xd $yd $td $xf $yf $tf]

      set xd [lindex $star_deb 0]
      set yd [lindex $star_deb 1]
      set xf [lindex $star_fin 0]
      set yf [lindex $star_fin 1]

      set ::bddimages_cdl::interpol_star1 [list $xd $yd $td $xf $yf $tf]

      ::console::affiche_resultat "\n** ESTIMATION ETOILE ** \n\n"
      set ::bddimages_cdl::delta_star  [::bddimages_cdl::estimation_fenetre [list $star_deb  $star_fin  ] ]
      ::console::affiche_resultat "\n** ESTIMATION ASTEROIDE ** \n\n"
      set ::bddimages_cdl::delta_aster [::bddimages_cdl::estimation_fenetre [list $aster_deb $aster_fin ] ]

      ::bddimages_cdl::box_fenetre

      set tabkey       [::bddimages_liste::lget $img "tabkey"]

      set telescop     [lindex [::bddimages_liste::lget $tabkey telescop] 1]
      set object       [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey "object"] 1] ]
      set dateobs      [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set ::bddimages_cdl::file_result_m1  [file join $bddconf(dirtmp) "${telescop}_${object}_m1.csv"]
      ::console::affiche_resultat "RESULTAT DANS FICHIER : $::bddimages_cdl::file_result_m1\n"
      set ::bddimages_cdl::file_result_m2  [file join $bddconf(dirtmp) "${telescop}_${object}_m2.csv"]
      ::console::affiche_resultat "RESULTAT DANS FICHIER : $::bddimages_cdl::file_result_m2\n"
      set ::bddimages_cdl::file_result_m3  [file join $bddconf(dirtmp) "${telescop}_${object}_m3.csv"]
      ::console::affiche_resultat "RESULTAT DANS FICHIER : $::bddimages_cdl::file_result_m3\n"


    }















   proc ::bddimages_cdl::mesure_images {  } {

    global bddconf audace


      set f1 [open $::bddimages_cdl::file_result_m1 "w"]
      set f2 [open $::bddimages_cdl::file_result_m2 "w"]
      set f3 [open $::bddimages_cdl::file_result_m3 "w"]
      puts $f1 "dateiso,datejj,mag"
      puts $f2 "dateiso,datejj,mag"
      puts $f3 "dateiso,datejj,mag"

      foreach img $::bddimages_cdl::img_list {

         $audace(hCanvas) delete cadres

         set commundatejj [::bddimages_liste::lget $img "commundatejj"]
         set filename     [::bddimages_liste::lget $img "filename"]
         set dirfilename  [::bddimages_liste::lget $img "dirfilename"]
         set tabkey       [::bddimages_liste::lget $img "tabkey"]
         set exposure     [lindex [::bddimages_liste::lget $tabkey exposure] 1]
         set dateobs      [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         set datejd       [ mc_date2jd $dateobs ]
         set datejd       [expr ($datejd + $exposure / 2. / 24. / 3600.)]
         set dateiso      [ mc_date2iso8601 $datejd ]
       
         set file [file join $bddconf(dirbase) $dirfilename $filename]
         loadima $file
         
         ::bddimages_cdl::mesure_methode1 $f1 $commundatejj $dateiso $datejd
         #::bddimages_cdl::mesure_methode2 $f2 $commundatejj $dateiso $datejd
         ::bddimages_cdl::mesure_methode3 $f3 $commundatejj $dateiso $datejd


         #after 100

      }

      $audace(hCanvas) delete cadres
      close $f1
      close $f2
      close $f3

    }


proc ::bddimages_cdl::mesure_methode1 { f commundatejj dateiso datejd } {

         set ls       [::bddimages_cdl::interpol $::bddimages_cdl::interpol_star1 $commundatejj]
         set valeurs  [photom_methode1 [lindex $ls 0] [lindex $ls 1] $::bddimages_cdl::delta_star]
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set fluxs    [lindex $valeurs 2]
         set errfluxs [lindex $valeurs 3]
         ::bddimages_cdl::affich_un_rond  $xsm $ysm "yellow"

         set la       [::bddimages_cdl::interpol $::bddimages_cdl::interpol_aster $commundatejj]
         set valeurs  [photom_methode1 [lindex $la 0] [lindex $la 1] $::bddimages_cdl::delta_star]
         set xam      [lindex $valeurs 0]
         set yam      [lindex $valeurs 1]
         set fluxa    [lindex $valeurs 2]
         set errfluxa [lindex $valeurs 3]
         ::bddimages_cdl::affich_un_rond  $xam $yam "green"

         set err [catch {
            set mag [expr $::bddimages_cdl::magstar - log10($fluxa/$fluxs)*2.5]
            set errmag [expr abs( log10($fluxa/$fluxs)*2.5 - log10(($fluxa+$errfluxa)/($fluxs-$errfluxs))*2.5)]
            set errmag2 [expr abs( log10($fluxa/$fluxs)*2.5 - log10(($fluxa-$errfluxa)/($fluxs+$errfluxs))*2.5)]
            if {$errmag<$errmag2} {
               set errmag $errmag2
            }
         } msg ]
         if {$err!=0} {
            ::console::affiche_erreur "METHODE 1\n"
            ::console::affiche_erreur "err = $err\n"
            ::console::affiche_erreur "msg = $msg\n"
            ::console::affiche_erreur "fluxa = $fluxa\n"
            ::console::affiche_erreur "fluxs = $fluxs\n"
         }

         puts $f "$dateiso,$datejd,$mag"
         ::console::affiche_resultat "M1 $dateiso,$datejd,$mag\n"
    }


proc ::bddimages_cdl::mesure_methode2 { f commundatejj dateiso datejd } {

         set ls       [::bddimages_cdl::interpol $::bddimages_cdl::interpol_star1 $commundatejj]
         set valeurs  [photom_methode2 [lindex $ls 0] [lindex $ls 1] $::bddimages_cdl::delta_star]
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set fluxs    [lindex $valeurs 2]
         set errfluxs [lindex $valeurs 3]
         ::bddimages_cdl::affich_un_rond  $xsm $ysm "yellow"

         set la       [::bddimages_cdl::interpol $::bddimages_cdl::interpol_aster $commundatejj]
         set valeurs  [photom_methode2 [lindex $la 0] [lindex $la 1] $::bddimages_cdl::delta_star]
         set xam      [lindex $valeurs 0]
         set yam      [lindex $valeurs 1]
         set fluxa    [lindex $valeurs 2]
         set errfluxa [lindex $valeurs 3]
         ::bddimages_cdl::affich_un_rond  $xam $yam "green"

         set err [catch {
            set mag [expr $::bddimages_cdl::magstar - log10($fluxa/$fluxs)*2.5]
            set errmag [expr abs( log10($fluxa/$fluxs)*2.5 - log10(($fluxa+$errfluxa)/($fluxs-$errfluxs))*2.5)]
            set errmag2 [expr abs( log10($fluxa/$fluxs)*2.5 - log10(($fluxa-$errfluxa)/($fluxs+$errfluxs))*2.5)]
            if {$errmag<$errmag2} {
               set errmag $errmag2
            }
         } msg ]
         if {$err!=0} {
            ::console::affiche_erreur "METHODE 2\n"
            ::console::affiche_erreur "err = $err\n"
            ::console::affiche_erreur "msg = $msg\n"
            ::console::affiche_erreur "fluxa = $fluxa\n"
            ::console::affiche_erreur "fluxs = $fluxs\n"
         }

         puts $f "$dateiso,$datejd,$mag"

    }



proc ::bddimages_cdl::mesure_methode3 { f commundatejj dateiso datejd } {

         set ls       [::bddimages_cdl::interpol $::bddimages_cdl::interpol_star1 $commundatejj]
         set valeurs  [photom_methode3 [lindex $ls 0] [lindex $ls 1] $::bddimages_cdl::delta_star]
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set fluxs    [lindex $valeurs 2]
         set errfluxs [lindex $valeurs 3]
         ::bddimages_cdl::affich_un_rond  $xsm $ysm "yellow"

         set la       [::bddimages_cdl::interpol $::bddimages_cdl::interpol_aster $commundatejj]
         set valeurs  [photom_methode3 [lindex $la 0] [lindex $la 1] $::bddimages_cdl::delta_star]
         set xam      [lindex $valeurs 0]
         set yam      [lindex $valeurs 1]
         set fluxa    [lindex $valeurs 2]
         set errfluxa [lindex $valeurs 3]
         ::bddimages_cdl::affich_un_rond  $xam $yam "green"

         set err [catch {
            set mag [expr $::bddimages_cdl::magstar - log10($fluxa/$fluxs)*2.5]
            set errmag [expr abs( log10($fluxa/$fluxs)*2.5 - log10(($fluxa+$errfluxa)/($fluxs-$errfluxs))*2.5)]
            set errmag2 [expr abs( log10($fluxa/$fluxs)*2.5 - log10(($fluxa-$errfluxa)/($fluxs+$errfluxs))*2.5)]
            if {$errmag<$errmag2} {
               set errmag $errmag2
            }
         } msg ]
         if {$err!=0} {
            ::console::affiche_erreur "METHODE 3\n"
            ::console::affiche_erreur "err = $err\n"
            ::console::affiche_erreur "msg = $msg\n"
            ::console::affiche_erreur "fluxa = $fluxa\n"
            ::console::affiche_erreur "fluxs = $fluxs\n"
         }

         puts $f "$dateiso,$datejd,$mag"
         ::console::affiche_resultat "M1 $dateiso,$datejd,$mag\n"

    }





proc ::bddimages_cdl::affich_un_rond { x y color } {

   global audace

       #--- Transformation des coordonnees image en coordonnees canvas
       set can_xy [ ::audace::picture2Canvas [list $x $y] ]
       set x [lindex $can_xy 0]
       set y [lindex $can_xy 1]
       # gren_info "XY =  $x $y \n"
       set radius 5           
       set width 1           
       #--- Dessine l'objet selectionne en vert dans l'image
       $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
           -outline $color -tags cadres -width $width

   }






   proc ::bddimages_cdl::interpol { interpol t} {
    
      set xd [lindex $interpol 0]
      set yd [lindex $interpol 1]
      set td [lindex $interpol 2]
      set xf [lindex $interpol 3]
      set yf [lindex $interpol 4]
      set tf [lindex $interpol 5]

      set x [expr ($xd-$xf)/($td-$tf)*$t + ($td * $xf - $tf * $xd) / ($td-$tf)]
      set y [expr ($yd-$yf)/($td-$tf)*$t + ($td * $yf - $tf * $yd) / ($td-$tf)]

      return [list $x $y]
   }

















   proc ::bddimages_cdl::select_source { txt flag } {

      ::bddimages_cdl::box_source $txt $flag
      if { $::bddimages_cdl::stop == 1} {return}

      set rect [ ::confVisu::getBox $::audace(visuNo) ]
      set xsm [expr ([lindex $rect 0] + [lindex $rect 2]) / 2. ]
      set ysm [expr ([lindex $rect 1] + [lindex $rect 3]) / 2. ]
      set deltax [expr abs([lindex $rect 0] - [lindex $rect 2]) ]
      set deltay [expr abs([lindex $rect 1] - [lindex $rect 3]) ]
      if {$deltax < $deltay} {
         set delta $deltay
      } else {
         set delta $deltax
      }
      return [list $xsm $ysm $delta]
   }












   

   proc ::bddimages_cdl::box_source { txt flag } {

        set magstar $::bddimages_cdl::magstar
        
        set tl [ toplevel $::audace(base).bddimages_cdl \
            -class Toplevel -borderwidth 2 -relief groove ]
        wm title $tl titre
        wm resizable $tl 0 0
        wm protocol $tl WM_DELETE_WINDOW
        wm transient $tl .audace

        set tlfaide [ frame $tl.aide ]
        label $tlfaide.l -text  $txt
        pack $tlfaide.l

        if {$flag == 1} {
           set tlf1 [ frame $tl.f1 -borderwidth 2 -relief groove ]
           set tlf1l [ label $tlf1.l -text magnitude ]
           set tlf1e [ entry $tlf1.e -textvariable ::bddimages_cdl::magstar \
               -width -1 -relief sunken ]
           $tlf1.e delete 0 end
           $tlf1.e insert 0 $magstar
           grid $tlf1l $tlf1e
        }

        set tlf2 [ frame $tl.f2 -borderwidth 2 -relief groove ]
        set tlf2b1 [ button $tlf2.b1 -text ok -command { 
                update idletasks
                destroy $::audace(base).bddimages_cdl
                ::console::affiche_resultat "** MAGSTAR = $::bddimages_cdl::magstar\n"
            } ]
        set tlf2b2 [ button $tlf2.b2 -text arret -command {
                update idletasks
                destroy $::audace(base).bddimages_cdl
                set ::bddimages_cdl::stop 1
            } ]

        pack $tlf2b1 $tlf2b2 -side left -padx 10 -pady 10
        if {$flag == 1} {
           pack $tlfaide $tlf1 $tlf2
        } else {
           pack $tlfaide $tlf2
        }
        ::confColor::applyColor $tl
        tkwait window $tl
        return ""

   }





   proc ::bddimages_cdl::box_fenetre { } {

        set deltas $::bddimages_cdl::delta_star
        set deltaa $::bddimages_cdl::delta_aster

        set tl [ toplevel $::audace(base).bddimages_cdl \
            -class Toplevel -borderwidth 2 -relief groove ]
        wm title $tl titre
        wm resizable $tl 0 0
        wm protocol $tl WM_DELETE_WINDOW
        wm transient $tl .audace

        set tlfaide [ frame $tl.aide ]
        label $tlfaide.l -text  "Taille fenetre"
        pack $tlfaide.l

        set tlf1 [ frame $tl.f1 -borderwidth 2 -relief groove ]
        set tlf1l [ label $tlf1.l -text "box etoile" ]
        set tlf1e [ entry $tlf1.e -textvariable ::bddimages_cdl::delta_star \
            -width -1 -relief sunken ]
        $tlf1.e delete 0 end
        $tlf1.e insert 0 $deltas
        grid $tlf1l $tlf1e

        set tlf3 [ frame $tl.f3 -borderwidth 2 -relief groove ]
        set tlf3l [ label $tlf3.l -text "box aster" ]
        set tlf3e [ entry $tlf3.e -textvariable ::bddimages_cdl::delta_aster \
            -width -1 -relief sunken ]
        $tlf3.e delete 0 end
        $tlf3.e insert 0 $deltaa
        grid $tlf3l $tlf3e

        set tlf2 [ frame $tl.f2 -borderwidth 2 -relief groove ]
        set tlf2b1 [ button $tlf2.b1 -text ok -command { 
                update idletasks
                destroy $::audace(base).bddimages_cdl
                ::console::affiche_resultat "** DELTA STAR = $::bddimages_cdl::delta_star\n"
                ::console::affiche_resultat "** DELTA ASTER = $::bddimages_cdl::delta_aster\n"
            } ]
        set tlf2b2 [ button $tlf2.b2 -text arret -command {
                update idletasks
                destroy $::audace(base).bddimages_cdl
                set ::bddimages_cdl::stop 1
            } ]

        pack $tlf2b1 $tlf2b2 -side left -padx 10 -pady 10
        pack $tlfaide $tlf1 $tlf3 $tlf2
        ::confColor::applyColor $tl
        tkwait window $tl
        return ""

   }



















   proc ::bddimages_cdl::photom_methode1 { xsm ysm delta } {

      set xs0 [expr int($xsm - $delta)]
      set ys0 [expr int($ysm - $delta)]
      set xs1 [expr int($xsm + $delta)]
      set ys1 [expr int($ysm + $delta)]
      set valeurs [  buf1 fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]

      set flux [expr ([lindex $valeurs 0] + [lindex $valeurs 4])/2.]

      set xsm [lindex $valeurs 1]
      set ysm [lindex $valeurs 5]

      #::console::affiche_resultat "fitgauss = $xsm $ysm $flux\n"

      set xs0 [expr int($xsm - $delta)]
      set ys0 [expr int($ysm - $delta)]
      set xs1 [expr int($xsm + $delta)]
      set ys1 [expr int($ysm + $delta)]

      set valeurs [  buf1 photom [list $xs0 $ys0 $xs1 $ys1] square 20 25 35 ]
      #::console::affiche_resultat "photom = $valeurs\n"
      set flux [lindex $valeurs 0]
      set errflux 0

      #::console::affiche_resultat "flux int photom = $flux \n"

      return [ list $xsm $ysm $flux $errflux]
   }







  
proc photom_methode2 { xm ym delta } {

   set x0 [expr int($xm - $delta)]
   set y0 [expr int($ym - $delta)]
   set x1 [expr int($xm + $delta)]
   set y1 [expr int($ym + $delta)]
   set valeurs [ calaphot_fitgauss2d 1 [ list $x0 $y0 $x1 $y1 ] ]
   set xm [lindex $valeurs 2]
   set ym [lindex $valeurs 3]
   set flux [lindex $valeurs 12]
   set errflux [lindex $valeurs 23]
   return [ list $xm $ym $flux $errflux]
   }







proc photom_methode3 { xm ym delta } {

   set x0 [expr int($xm - $delta)]
   set y0 [expr int($ym - $delta)]
   set x1 [expr int($xm + $delta)]
   set y1 [expr int($ym + $delta)]
   set valeurs [  buf1 fitgauss [ list $x0 $y0 $x1 $y1 ] ]

   set xm [lindex $valeurs 1]
   set ym [lindex $valeurs 5]
   set flux [expr ([lindex $valeurs 0] + [lindex $valeurs 4])/2.]
   set errflux 0

   return [ list $xm $ym $flux $errflux]
   }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
   proc ::bddimages_cdl::estimation_fenetre { target_list } {

      set result_delta 20

      foreach target $target_list {

         set x [lindex $target 0]
         set y [lindex $target 1]
         set d [lindex $target 2]

         # fenetre croissante
         ::console::affiche_resultat "ASC...\n"
         set fluxsave 1
         set cpt 0
         for {set deltato 1} {$deltato<$d} {incr deltato} {
            set valeurs [photom_methode1 $x $y $deltato]
            set fluxs [lindex $valeurs 2]
            if { $fluxs > 0 } {
               set pourcent [expr abs(($fluxs - $fluxsave )/$fluxs*100)]
               ::console::affiche_resultat "TAILLE=$deltato # FLUX : $fluxs # $pourcent %\n"
               set fluxsave $fluxs
            } else {
               ::console::affiche_resultat "TAILLE=$deltato # FLUX : $fluxs \n"
            }

         }

      }

   return $result_delta
   }





























#--- Fin Classe

}
