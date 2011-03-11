#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_imgcorrection.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_imgcorrection.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Fr√©d√©ric Vachier
# Mise √† jour $Id: bddimages_liste.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bddimages_imgcorrection
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_imgcorrection.cap
#
#--------------------------------------------------

namespace eval bddimages_imgcorrection {

   global audace
   global bddconf

    variable type imgtmplist inforesult  erreur_selection

    variable offset_img_list 
    variable soffset_img_list
    variable dark_img_list 
    variable sdark_img_list
    variable flat_img_list 
    variable sflat_img_list
    variable deflat_img_list




   proc ::bddimages_imgcorrection::get_info_img {  } {

      #recupere la liste des idbddimg
      set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set lid [lsort -decreasing -integer $lid]
      

      set imgtmplist     ""
      lappend imgtmplist [list "type"               "normal"]              
      lappend imgtmplist [list "name"               "imgtmplist"]              
      lappend imgtmplist [list "idlist"             ""]              
      set imgtmplist [::bddimages_liste::add_to_normallist $lid $imgtmplist]


      #::console::affiche_resultat "imgtmplist=$imgtmplist\n"

      set imgtmplist [::bddimages_liste::get_imglist $imgtmplist]

      #::console::affiche_resultat "imgtmplist=$imgtmplist\n"

      return $imgtmplist
   }









   proc ::bddimages_imgcorrection::verif_all_img {  } {


      set img_list ""
      foreach img $::bddimages_imgcorrection::offset_img_list  {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::soffset_img_list {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::dark_img_list    {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::sdark_img_list   {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::flat_img_list    {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::sflat_img_list   {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::deflat_img_list  {lappend img_list $img}
      
      set telsav ""
      set bin1sav ""
      set bin2sav ""
      set cpt 0

      foreach img $img_list {
         # A FAIRE
         #set bufno [::buf::create]
         #set bufno 1
         #buf$bufno load $fileimg
         #::bddimagesAdmin::bdi_compatible buf$bufno
         foreach l $img {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="telescop"} {
               if {$cpt==0} {set telsav $val}
               if {$val!=$telsav} {return "Erreur telescope different"} 
            }
            if {$key=="bin1"} {
               if {$cpt==0} {set bin1sav $val}
               if {$val!=$bin1sav} {return "Erreur binning 1 different"} 
            }
            if {$key=="bin2"} {
               if {$cpt==0} {set bin2sav $val}
               if {$val!=$bin2sav} {return "Erreur binning 2 different"} 
            }
            if {$key=="bin2"} {
               if {$cpt==0} {set bin2sav $val}
               if {$val!=$bin2sav} {return "Erreur binning 2 different"} 
            }
         }
      incr cpt
      }
   
      return ""
   }














   proc ::bddimages_imgcorrection::verif_filter_img {  } {

      set img_list ""
      foreach img $::bddimages_imgcorrection::flat_img_list    {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::sflat_img_list   {lappend img_list $img}
      foreach img $::bddimages_imgcorrection::deflat_img_list   {lappend img_list $img}
      
      set telsav ""
      set bin1sav ""
      set bin2sav ""
      set cpt 0

      foreach img $img_list {
         # A FAIRE
         #set bufno [::buf::create]
         #set bufno 1
         #buf$bufno load $fileimg
         #::bddimagesAdmin::bdi_compatible buf$bufno
         foreach l $img {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="filter"} {
               if {$cpt==0} {set telsav $val}
               if {$val!=$telsav} {return "Erreur filtre different"} 
            }
         }
      incr cpt
      }
   
      return ""
   }












   proc ::bddimages_imgcorrection::create_filename { type } {


      if {$type=="offset"} {
         set img_list $::bddimages_imgcorrection::offset_img_list
      }
      if {$type=="dark"} {
         set img_list $::bddimages_imgcorrection::dark_img_list
      }
      if {$type=="flat"} {
         set img_list $::bddimages_imgcorrection::flat_img_list
      }
      if {$type=="deflat"} {
         return ""
      }
      
      set tel ""
      set bin1 ""
      set bin2 ""
      set filtre ""
      set commundatejjmoy 0
      set cpt 0
      foreach img $img_list {
         foreach l $img {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="telescop"} {set tel $val}
            if {$key=="bin1"} {set bin1 $val}
            if {$key=="bin2"} {set bin2 $val}
            if {$key=="filter"} {set filtre [string trim $val]}
            if {$key=="commundatejj"} {set commundatejjmoy [expr $commundatejjmoy + $val]}
         }
      incr cpt
      }
      if { $cpt == 0 } {
         return ""
      }
      set commundatejjmoy  [ expr $commundatejjmoy / $cpt ]
      set dateobs          [ mc_date2iso8601 $commundatejjmoy ]
      set ms               [ string range $dateobs end-2 end ]
      set commundatejjmoy  [ string range $dateobs 0 end-4 ]

      set commundatejjmoy [clock format [clock scan $commundatejjmoy] -format %Y%m%d.%H%M%S]
 
      if {$type=="flat"} {
         set filename "$tel.$commundatejjmoy.$ms.bin${bin1}x${bin2}.$type.$filtre"
      } else {
         set filename "$tel.$commundatejjmoy.$ms.bin${bin1}x${bin2}.$type"
      }

      return [list $filename $dateobs $bin1 $bin2]
   }





proc create_image_offset { k type inforesult } {

  global bddconf

      set fileout  [lindex $inforesult 0]
      set dateobs  [lindex $inforesult 1]
      incr k -1

      set bufno 1

      buf$bufno load "$bddconf(dirtmp)/${type}0.fit"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) offset       0  $k .fit $bddconf(dirtmp) $fileout . .fit KS kappa=3"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  .fit $bddconf(dirtmp) $fileout . .fit STAT"

      buf$bufno load "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
      buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
      buf$bufno save "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno clear

      insertion_solo $bddconf(dirtmp)/$fileout.fit

  }





proc create_image_dark { k type inforesult } {

  global bddconf

      set fileout  [lindex $inforesult 0]
      set dateobs  [lindex $inforesult 1]
      incr k -1

      set bufno 1

      buf$bufno load "$bddconf(dirtmp)/${type}0.fit"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k .fit $bddconf(dirtmp) $fileout . .fit KS kappa=3"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  .fit $bddconf(dirtmp) $fileout . .fit STAT"

      buf$bufno load "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
      buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
      buf$bufno save "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno clear

      insertion_solo $bddconf(dirtmp)/$fileout.fit
  }




proc create_image_flat { k type inforesult } {

  global bddconf

      set fileout  [lindex $inforesult 0]
      set dateobs  [lindex $inforesult 1]
      incr k -1

      set bufno 1

      buf$bufno load "$bddconf(dirtmp)/${type}0.fit"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) flat       0  $k .fit $bddconf(dirtmp) $fileout . .fit KS kappa=3"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  .fit $bddconf(dirtmp) $fileout . .fit STAT"

   set nbsoffset [llength $::bddimages_imgcorrection::soffset_img_list]
   set nbsdark   [llength $::bddimages_imgcorrection::sdark_img_list]

   if {$nbsoffset == 1 && $nbsdark == 1 } {
      ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k .fit $bddconf(dirtmp) flat     0 .fit SUBDARK dark=sdark0.fit bias=soffset0.fit exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000"
   }
   if {$nbsoffset == 0 && $nbsdark == 1 } {
      ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k .fit $bddconf(dirtmp) flat     0 .fit SUB file=$bddconf(dirtmp)/sdark0.fit offset=0"
   }
   if {$nbsoffset == 1 && $nbsdark == 0 } {
      ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k .fit $bddconf(dirtmp) flat     0 .fit SUB file=$bddconf(dirtmp)/soffset0.fit offset=0"
   }

   #!!! --
   # --- normalisation au meme niveau
   ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k .fit $bddconf(dirtmp) flat     0 .fit NORMGAIN normgain_value=10000 nullpixel=-10000"
   # --- pile mediane
   ttscript2 "IMA/STACK  $bddconf(dirtmp) flat     0 $k .fit $bddconf(dirtmp) $fileout . .fit MED"
   # --- pile KappaSigma
   # ttscript2 "IMA/STACK  $bddconf(dirtmp) flat     0 $k .fit $bddconf(dirtmp) $fileout . .fit KS kappa=3"

   # --- Met a jour le Header Fits en fonction des statistiques de l image
   ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout . . .fit $bddconf(dirtmp) $fileout . .fit STAT"

      buf$bufno load "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
      buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
      buf$bufno save "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno clear

      insertion_solo $bddconf(dirtmp)/$fileout.fit
  }




proc create_image_deflat {  } {

   global bddconf
      
      set type "deflat"
      set nbsoffset [llength $::bddimages_imgcorrection::soffset_img_list]
      set nbsdark   [llength $::bddimages_imgcorrection::sdark_img_list]
      set nbsflat   [llength $::bddimages_imgcorrection::sflat_img_list]
      set nbdeflat  [llength $::bddimages_imgcorrection::deflat_img_list]

      buf$bufno load "$bddconf(dirtmp)/${type}0.fit"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  .fit $bddconf(dirtmp) $fileout . .fit STAT"

  }



proc create_image { type inforesult} {

  global bddconf

      if {$type=="offset"} {
         ::bddimages_imgcorrection::create_image_offset [llength $::bddimages_imgcorrection::offset_img_list] $type $inforesult
      }
      if {$type=="dark"} {
         ::bddimages_imgcorrection::create_image_dark [llength $::bddimages_imgcorrection::dark_img_list] $type $inforesult
      }
      if {$type=="flat"} {
         ::bddimages_imgcorrection::create_image_flat [llength $::bddimages_imgcorrection::flat_img_list] $type $inforesult
      }
      if {$type=="deflat"} {
         ::bddimages_imgcorrection::create_image_deflat
      }
      

  }
 







proc delete_to_tmp { type img_list } {

   global bddconf

      set nb  [llength $img_list]
      for {set i 0} {$i<$nb} {incr i} {
         #file delete -force -- [file join $bddconf(dirtmp) ${type}${i}.fit]
      }

      }






proc copy_to_tmp { type img_list } {

   global bddconf

      set k 0
      set result_list ""

      set fichiers [::bddimages_imgcorrection::img_to_filename_list $img_list]

      foreach fichier $fichiers {
         set errnum [catch {file copy -force -- $fichier $bddconf(dirtmp)/${type}${k}.fit} msg]
         if {$errnum==0} {
            #::console::affiche_resultat "cp image : $fichier\n"
            incr k
         } else {
            ::console::affiche_erreur "Erreur copy_to_tmp : $fichier\n"
            ::console::affiche_erreur "errnum : $errnum\n"
            ::console::affiche_erreur "msg    : $msg\n"
         }
      }
      ::console::affiche_resultat "Copie de $k $type\n"
      incr k -1



  }











proc correction { type inforesult} {

      global action_label audace bddconf

      set audace(rep_images) $bddconf(dirtmp)
      cd $bddconf(dirtmp)

      ::bddimages_imgcorrection::copy_to_tmp "offset"  $::bddimages_imgcorrection::offset_img_list
      ::bddimages_imgcorrection::copy_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list 
      ::bddimages_imgcorrection::copy_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list    
      ::bddimages_imgcorrection::copy_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list   
      ::bddimages_imgcorrection::copy_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::copy_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list   
      ::bddimages_imgcorrection::copy_to_tmp "img"     $::bddimages_imgcorrection::deflat_img_list   

      set errnum [catch {create_image $type $inforesult} msg]
      if {$errnum!=0} {
         ::console::affiche_erreur "Erreur sur la creation de $type\n"
         ::console::affiche_erreur "errnum : $errnum\n"
         ::console::affiche_erreur "msg    : $msg\n"
      } else {
      
      ::bddimages_imgcorrection::delete_to_tmp "offset"  $::bddimages_imgcorrection::offset_img_list
      ::bddimages_imgcorrection::delete_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list 
      ::bddimages_imgcorrection::delete_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list   
      ::bddimages_imgcorrection::delete_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list   
      ::bddimages_imgcorrection::delete_to_tmp "img"     $::bddimages_imgcorrection::deflat_img_list   
      file delete -force -- [file join $bddconf(dirtmp) tt.log]

}
      

      ::bddimages_recherche::get_list $::bddimages_recherche::current_list_id
      ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]


      return 0
}












#--------------------------------------------------
# img_to_filename_list { img_list }
#--------------------------------------------------
#
#    fonction  :
#        Fournit un extrait de la liste imgtmplist
#        correspodant au mot clÈ : bddimages type
#
#    procedure externe :
#
#    variables en entree :
#        type = mot clÈ bddimages type
#        imgtmplist = liste complete d image
#
#    variables en sortie :
#        imgtmplist = liste complete d image de meme mot clÈ bddimages type
#
#--------------------------------------------------
   proc ::bddimages_imgcorrection::img_to_filename_list { img_list } {

   global bddconf

      set result_list ""
      foreach img $img_list {
         foreach l $img {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="filename"} {
               set filename $val
            }
            if {$key=="dirfilename"} {
               set dirfilename $val
            }
         }
         lappend result_list [file join $bddconf(dirbase) $dirfilename $filename]
      }

      return $result_list
   }





#--------------------------------------------------
# type_to_img_list { type img_list }
#--------------------------------------------------
#
#    fonction  :
#        Fournit un extrait de la liste imgtmplist
#        correspodant au mot clÈ : bddimages_type
#
#    procedure externe :
#
#    variables en entree :
#        type = mot clÈ bddimages_type
#        img_list = liste complete d image
#
#    variables en sortie :
#        result_list = liste complete d image de meme mot clÈ bddimages_type
#
#--------------------------------------------------
   proc ::bddimages_imgcorrection::type_to_img_list { type img_list } {


      if {$type=="OFFSET"} {
         set type "OFFSET"
         set state "RAW"
         }
      if {$type=="SOFFSET"} {
         set type "OFFSET"
         set state "CORR"
         }
      if {$type=="DARK"} {
         set type "DARK"
         set state "RAW"
         }
      if {$type=="SDARK"} {
         set type "DARK"
         set state "CORR"
         }
      if {$type=="FLAT"} {
         set type "FLAT"
         set state "RAW"
         }
      if {$type=="SFLAT"} {
         set type "FLAT"
         set state "CORR"
         }
      if {$type=="IMG"} {
         set state "RAW"
         }

      set result_list ""
      foreach img $img_list {
         set keep "ok"
         foreach l $img {
            #::console::affiche_resultat "l= -${l}- \n"
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="bddimages_type"} {
               if {[string trim $val]!=$type} {
                  #::console::affiche_resultat "hno $key -> -${val}-\n"
                  set keep "no"
               }
            }
            if {$key=="bddimages_state"} {
               if {[string trim $val]!=$state} {
                  #::console::affiche_resultat "hno $key -> -${val}-\n"
                  set keep "no"
               }
            }
            if {$key=="filename"} {
               set filename $val
               #::console::affiche_resultat "hno -${filename}-\n"
            }
         }
         if {$keep=="ok"} {
            #::console::affiche_resultat "ACCEPTED -${filename}- $state $type\n"
            lappend result_list $img
         } else {
            #::console::affiche_resultat "REJECTED -${filename}- $state $type\n"
         }
      }
      return $result_list
   }


#--------------------------------------------------
# run_create { this }
#--------------------------------------------------
#
#    fonction  :
#        Creation de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------

   proc ::bddimages_imgcorrection::run_create { this type } {


      set ::bddimages_imgcorrection::type $type

      # Recuperation des informations des images selectionnees
      set selection_list [::bddimages_imgcorrection::get_info_img]

      set ::bddimages_imgcorrection::offset_img_list  ""
      set ::bddimages_imgcorrection::soffset_img_list ""
      set ::bddimages_imgcorrection::dark_img_list    ""
      set ::bddimages_imgcorrection::sdark_img_list   ""
      set ::bddimages_imgcorrection::flat_img_list    ""
      set ::bddimages_imgcorrection::sflat_img_list   ""
      set ::bddimages_imgcorrection::deflat_img_list   ""

      set ::bddimages_imgcorrection::erreur_selection 0
      set texte "Creation d un $type : \n\n"

      # Traitement des OFFSET
      if {$type == "offset"}  {

         # Chargement de la liste OFFSET
         set typekey "OFFSET"
         set typename $typekey
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::offset_img_list $img_list
         }

      }

      if {$type == "dark"}  {

         # Chargement de la liste SOFFSET
         set typekey "SOFFSET"
         set typename "SUPER OFFSET"

         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::soffset_img_list $img_list
         }
         
         # Chargement de la liste DARK
         set typekey "DARK"
         set typename $typekey
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::dark_img_list $img_list
         }

      }

      if {$type == "flat"}  {

         # Chargement de la liste SOFFSET
         set typekey "SOFFSET"
         set typename "SUPER OFFSET"

         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::soffset_img_list $img_list
         }
         
         # Chargement de la liste SDARK
         set typekey "SDARK"
         set typename "SUPER DARK"
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::sdark_img_list $img_list
         }
         
         # Chargement de la liste FLAT
         set typekey "FLAT"
         set typename $typekey
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::flat_img_list $img_list
         }

      }

      if {$type == "deflat"}  {

         # Chargement de la liste SOFFSET
         set typekey "SOFFSET"
         set typename "SUPER OFFSET"

         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::soffset_img_list $img_list
         }
         
         # Chargement de la liste SDARK
         set typekey "SDARK"
         set typename "SUPER DARK"
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::sdark_img_list $img_list
         }
         
         # Chargement de la liste SDARK
         set typekey "SFLAT"
         set typename "SUPER FLAT"
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::sflat_img_list $img_list
         }
         
         # Chargement de la liste IMG
         set typekey "IMG"
         set typename $typekey
         
         set img_list [::bddimages_imgcorrection::type_to_img_list $typekey $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images $typename d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des $typename\n"
         }  else {
            set filename_list [::bddimages_imgcorrection::img_to_filename_list $img_list]
            foreach img $filename_list {
               set texte "${texte}$img\n"
            }
            set ::bddimages_imgcorrection::deflat_img_list $img_list
         }

      }



      
      if {$::bddimages_imgcorrection::erreur_selection==0} {

         # concatenation des listes
         
         
         set errmsg [::bddimages_imgcorrection::verif_all_img]
         if {$errmsg != ""}  {
            ::console::affiche_erreur "ERROR: $errmsg\n"
            return
            }
         set errmsg [::bddimages_imgcorrection::verif_filter_img]
         if {$errmsg != ""}  {
            ::console::affiche_erreur "ERROR: $errmsg\n"
            return
            }
            
         if { [llength $::bddimages_imgcorrection::deflat_img_list] == 0 } {
            set ::bddimages_imgcorrection::inforesult [::bddimages_imgcorrection::create_filename $type]
            set texte "${texte}- Image en sortie\n"
            set texte "${texte}filename = [lindex $::bddimages_imgcorrection::inforesult 0]\n"
            set texte "${texte}dateobs  = [lindex $::bddimages_imgcorrection::inforesult 1]\n"
            set texte "${texte}bin1     = [lindex $::bddimages_imgcorrection::inforesult 2]\n"
            set texte "${texte}bin2     = [lindex $::bddimages_imgcorrection::inforesult 3]\n"
         }
         
      }
      
      # Affichage de la fenetre
      global This
      global entetelog
      set entetelog "Creation d un $type"
      set This $this

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      toplevel $This -class Toplevel
      wm title $This $entetelog
      wm positionfrom $This user
      wm sizefrom $This user

      set framecurrent $This.framename

      frame $framecurrent -relief groove
      pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

      # Frame qui va contenir le label "Type your password:" et une entr√©e pour le rentrer
      frame $framecurrent.title
      pack configure $framecurrent.title -side top -fill x
        label $framecurrent.title.e -text ${texte}
        pack configure $framecurrent.title.e -side left -anchor c

      # Frame qui va contenir les boutons Cancel et Ok
      frame $framecurrent.buttons
      pack configure $framecurrent.buttons -side top -fill x
        button $framecurrent.buttons.cancel -text Cancel -command "destroy $This"
        pack configure $framecurrent.buttons.cancel -side left

      if {$::bddimages_imgcorrection::erreur_selection==0} {
        button $framecurrent.buttons.ok -text Ok -command {::bddimages_imgcorrection::correction $::bddimages_imgcorrection::type $::bddimages_imgcorrection::inforesult; destroy $This}
        pack configure $framecurrent.buttons.ok -side right
      }
      
      grab set $This
      tkwait window $This
}








}

