# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/identification.tcl



package require math::constants




proc get_identified { sra sdec serrpos srmag srmagerr ira idec ierrpos irmag irmagerr scoreposlimit scoremvlimit scorelimit log} {

    if {$log} {gren_info "identification\n"}
    if {$log} {gren_info "$sra $sdec $serrpos $srmag $srmagerr\n"}
    if {$log} {gren_info "$ira $idec $ierrpos $irmag $irmagerr\n"}
    set dtr $::math::constants::degtorad
    set score NULL
    set deltapos [expr sqrt(pow(($sra-$ira)*cos($sdec*$dtr),2) + pow($sdec-$idec,2))]
    if {$log} {gren_info "deltapos=$deltapos\n"}
    if {$log} {gren_info "deltapos arcsec=[expr $deltapos*3600.0]\n"}
    set deltaposdiv [expr ($serrpos + $ierrpos) / 3600.0]
    if {$log} {gren_info "deltaposdiv=$deltaposdiv\n"}
    set scorepos [expr (1.0 - $deltapos / $deltaposdiv) * 100.0]
    if {$log} {gren_info "scorepos=$scorepos\n"}
    if {$deltapos > $deltaposdiv } { set scorepos 0.0 }
    set deltamag [expr abs($irmag - $srmag)]
    if {$log} {gren_info "deltamag=$deltamag\n"}
    set deltamagdiv [expr $srmagerr+$irmagerr]
    if {$log} {gren_info "deltamagdiv=$deltamagdiv\n"}
    set scoremv [expr (1.0 - $deltamag / $deltamagdiv) * 100.0]
    if {$log} {gren_info "scoremv=$scoremv\n"}
    if { $deltamag > $deltamagdiv } { set scoremv 0.0 }
    set score $scorepos
    if {$log} {gren_info "score=$score\n"}
    if { $scoremv < $score } { set score $scoremv }
    if {$log} {gren_info "score=$score\n"}
    if {$log} {gren_info "($scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit )\n"}
    if { $scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit } {
       if {$log} {gren_info "($scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit )\n"}
       return true
       }
    return false
    }





# -- Procedure 
proc identification { catalist1 catalog1 catalist2 catalog2 scoreposlimit scoremvlimit scorelimit } {

   set log 0
   set ilog 0
   
   set resultlist {}
   
   #gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $catalist1]\n"
   
   set fields1  [lindex $catalist1 0]
   set sources1 [lindex $catalist1 1]
   set fields2  [lindex $catalist2 0]
   set sources2 [lindex $catalist2 1]

   #gren_info "Chargement liste 1 : "
   set cpt 0
   set id 0
   foreach s $sources1 {
      foreach cata $s {
         if { [lindex $cata 0]==$catalog1 } {
           set data [lindex $cata 1]
           set tabs1($cpt,id)     $id
           set tabs1($cpt,ra)     [lindex $data 0]
           set tabs1($cpt,dec)    [lindex $data 1]
           set tabs1($cpt,poserr) [lindex $data 2]
           set tabs1($cpt,mag)    [lindex $data 3]
           set tabs1($cpt,magerr) [lindex $data 4]
           incr cpt
         }
      }
      incr id
   }
   #gren_info "$cpt rows\n"
   set nbtabs1 $cpt

   #gren_info "Chargement liste 2 : "
   set cpt 0
   set id 0
   foreach s $sources2 {
      foreach cata $s {
         if { [lindex $cata 0]==$catalog2 } {
           set data [lindex $cata 1]
           set tabs2($cpt,id)     $id
           set tabs2($cpt,ra)     [lindex $data 0]
           set tabs2($cpt,dec)    [lindex $data 1]
           set tabs2($cpt,poserr) [lindex $data 2]
           set tabs2($cpt,mag)    [lindex $data 3]
           set tabs2($cpt,magerr) [lindex $data 4]
           #gren_info "$accepted $id1 $id2\n"
           incr cpt
         }
      }
      incr id
   }
   #gren_info "$cpt rows\n"
   set nbtabs2 $cpt
   set ident ""

   for {set id1 0} {$id1<$nbtabs1} {incr id1} {

      for {set id2 0} {$id2<$nbtabs2} {incr id2} {
         #if { $id1 == 87 } {
         #   set ilog 0
         #} else {
         #   set ilog 0
         #}
         set accepted [get_identified \
                          $tabs1($id1,ra)           \
                          $tabs1($id1,dec)          \
                          $tabs1($id1,poserr)       \
                          $tabs1($id1,mag)          \
                          $tabs1($id1,magerr)       \
                          $tabs2($id2,ra)           \
                          $tabs2($id2,dec)          \
                          $tabs2($id2,poserr)       \
                          $tabs2($id2,mag)          \
                          $tabs2($id2,magerr)       \
                          $scoreposlimit $scoremvlimit $scorelimit $ilog]
         #gren_info "$accepted $id1 $id2 $tabs1($id1,ra)\n"
         if { $accepted } {
            if {$log} {gren_info "+"}
            lappend ident [list $tabs1($id1,id) $tabs2($id2,id)]
            #gren_info "[list $tabs1($id1,id) $tabs2($id2,id)]\n"
         }
         
         #set a 106.253805
         #set d 4.088599
         #set eps 0.01
         #if { $tabs1($id1,ra)>[expr $a - $eps] && $tabs1($id1,ra)<[expr $a + $eps] } {
         #if { $tabs1($id1,dec)>[expr $d - $eps] && $tabs1($id1,dec)<[expr $d + $eps] } {
         #   gren_info "$accepted $id1 $id2 $tabs1($id1,ra)\n"
         #   gren_info "+++++++++++\n"
         #}
         #}
         
         
      }

   }


   set cpt 0
   foreach i $ident {
      #gren_info "i = $i\n"
      set id1 [lindex $i 0]
      set id2 [lindex $i 1]
      set s1 [lindex $sources1 $id1]
      set news1 ""
      foreach cata $s1 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend news1 $cata
         }
      }
      set s2 [lindex $sources2 $id2]
      foreach cata $s2 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend news1 $cata
         }
      }
      set sources1 [lreplace $sources1 $id1 $id1 $news1]
      incr cpt
   }
   
   #gren_info "cpt = $cpt\n"
   if {$cpt > 0} {
      
      set nbovni [::manage_source::get_nb_sources_by_cata [list $fields1 $sources1] OVNI]
      #gren_info "nbovni = $nbovni\n"
     
      if {$nbovni == 0} {
         set newfields ""
         foreach cata $fields1 {
            if { [lindex $cata 0]!="OVNI" } {
               lappend newfields $cata
            }
         }
      } else {
         set newfields $fields1
      }
      foreach cata $fields2 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend newfields $cata
         }
      }
      #gren_info "fini\n"
      return [list $newfields $sources1]
   } else {
      return $catalist1
   }
 
 

}


# -- Procedure 
proc identification2 { catalist1 catalog1 catalist2 catalog2 scoreposlimit scoremvlimit scorelimit } {

   set log 0
   set ilog 0
   
   set resultlist {}
   
   #gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $catalist1]\n"
   
   set fields1  [lindex $catalist1 0]
   set sources1 [lindex $catalist1 1]
   set fields2  [lindex $catalist2 0]
   set sources2 [lindex $catalist2 1]

   #gren_info "Chargement liste 1 : "
   
   set ralist1 ""
   set cpt 0
   set id 0
   foreach s $sources1 {
      foreach cata $s {
         if { [lindex $cata 0]==$catalog1 } {
           set data [lindex $cata 1]
           set tabs1($cpt,accepted)     0
           set tabs1($cpt,id)           $id
           set tabs1($cpt,ra)           [lindex $data 0]
           set tabs1($cpt,dec)          [lindex $data 1]
           set tabs1($cpt,poserr)       [lindex $data 2]
           set tabs1($cpt,mag)          [lindex $data 3]
           set tabs1($cpt,magerr)       [lindex $data 4]
           lappend ralist1  [list $tabs1($cpt,ra) $tabs1($cpt,id)]
           incr cpt
         }
      }
      incr id
   }
   #gren_info "$cpt rows\n"
   set nbtabs1 $cpt

   #gren_info "Chargement liste 2 : "
   set ralist2 ""
   set cpt 0
   set id 0
   foreach s $sources2 {
      foreach cata $s {
         if { [lindex $cata 0]==$catalog2 } {
           set data [lindex $cata 1]
           set tabs2($cpt,accepted)     0
           set tabs2($cpt,id)           $id
           set tabs2($cpt,ra)           [lindex $data 0]
           set tabs2($cpt,dec)          [lindex $data 1]
           set tabs2($cpt,poserr)       [lindex $data 2]
           set tabs2($cpt,mag)          [lindex $data 3]
           set tabs2($cpt,magerr)       [lindex $data 4]
           lappend ralist2  [list $tabs2($cpt,ra) $tabs2($cpt,id)]
           #gren_info "$accepted $id1 $id2\n"
           incr cpt
         }
      }
      incr id
   }
   #gren_info "$cpt rows\n"
   set nbtabs2 $cpt
   set ident ""


   # tri des listes ralist1 et ralist2
   set ralist1 [lsort -index 0 $ralist1] 
   set ralist2 [lsort -index 0 $ralist2] 

   gren_info "ralist 1 : $ralist1 \n"









return

   for {set id1 0} {$id1<$nbtabs1} {incr id1} {

      for {set id2 0} {$id2<$nbtabs2} {incr id2} {
         #if { $id1 == 87 } {
         #   set ilog 0
         #} else {
         #   set ilog 0
         #}
         if {$tabs2($cpt,accepted)==0 } {
            set accepted [get_identified \
                             $tabs1($id1,ra)           \
                             $tabs1($id1,dec)          \
                             $tabs1($id1,poserr)       \
                             $tabs1($id1,mag)          \
                             $tabs1($id1,magerr)       \
                             $tabs2($id2,ra)           \
                             $tabs2($id2,dec)          \
                             $tabs2($id2,poserr)       \
                             $tabs2($id2,mag)          \
                             $tabs2($id2,magerr)       \
                             $scoreposlimit $scoremvlimit $scorelimit $ilog]
            #gren_info "$accepted $id1 $id2 $tabs1($id1,ra)\n"
            if { $accepted } {
               if {$log} {gren_info "+"}
               lappend ident [list $tabs1($id1,id) $tabs2($id2,id)]
               set tabs2($cpt,accepted) 1
               #gren_info "[list $tabs1($id1,id) $tabs2($id2,id)]\n"
            }

            #set a 106.253805
            #set d 4.088599
            #set eps 0.01
            #if { $tabs1($id1,ra)>[expr $a - $eps] && $tabs1($id1,ra)<[expr $a + $eps] } {
            #if { $tabs1($id1,dec)>[expr $d - $eps] && $tabs1($id1,dec)<[expr $d + $eps] } {
            #   gren_info "$accepted $id1 $id2 $tabs1($id1,ra)\n"
            #   gren_info "+++++++++++\n"
            #}
            #}
         } 
         
      }

   }


   set cpt 0
   foreach i $ident {
      #gren_info "i = $i\n"
      set id1 [lindex $i 0]
      set id2 [lindex $i 1]
      set s1 [lindex $sources1 $id1]
      set news1 ""
      foreach cata $s1 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend news1 $cata
         }
      }
      set s2 [lindex $sources2 $id2]
      foreach cata $s2 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend news1 $cata
         }
      }
      set sources1 [lreplace $sources1 $id1 $id1 $news1]
      incr cpt
   }
   
   #gren_info "cpt = $cpt\n"
   if {$cpt > 0} {
      
      set nbovni [::manage_source::get_nb_sources_by_cata [list $fields1 $sources1] OVNI]
      #gren_info "nbovni = $nbovni\n"
     
      if {$nbovni == 0} {
         set newfields ""
         foreach cata $fields1 {
            if { [lindex $cata 0]!="OVNI" } {
               lappend newfields $cata
            }
         }
      } else {
         set newfields $fields1
      }
      foreach cata $fields2 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend newfields $cata
         }
      }
      #gren_info "fini\n"
      return [list $newfields $sources1]
   } else {
      return $catalist1
   }
 
 

}

