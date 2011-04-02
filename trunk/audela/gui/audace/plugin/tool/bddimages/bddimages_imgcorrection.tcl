#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_imgcorrection.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_imgcorrection.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_imgcorrection.tcl 6858 2011-03-06 14:19:15Z fredvachier $
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

namespace eval bddimages_imgcorrection {

   global audace
   global bddconf

   variable type 
   variable imgtmplist 
   variable inforesult
   variable erreur_selection

   variable offset_img_list 
   variable soffset_img_list
   variable dark_img_list 
   variable sdark_img_list
   variable flat_img_list 
   variable sflat_img_list
   variable deflat_img_list

}


proc ::bddimages_imgcorrection::get_info_img {  } {

   #recupere la liste des idbddimg
   set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
   set lid [lsort -decreasing -integer $lid]
   set imgtmplist [::bddimages_liste::new_normallist $lid]
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
   
   set telescopsav ""
   set bin1sav ""
   set bin2sav ""
   set cpt 0

   foreach img $img_list {
      # A FAIRE
      #set bufno [::buf::create]
      #set bufno 1
      #buf$bufno load $fileimg
      #::bddimagesAdmin::bdi_compatible buf$bufno
      set tabkey   [::bddimages_liste::lget $img "tabkey"]
      set telescop [lindex [::bddimages_liste::lget $tabkey telescop] 1]
      set bin1     [lindex [::bddimages_liste::lget $tabkey bin1    ] 1]
      set bin2     [lindex [::bddimages_liste::lget $tabkey bin2    ] 1]
      if {$cpt==0} {
         set telescopsav $telescop
         set bin1sav     $bin1
         set bin2sav     $bin2
      } else {
         if {$telescopsav!=$telescop} {return -code error "Erreur TELESCOP different"} 
         if {$bin1sav    !=$bin1}     {return -code error "Erreur BIN1 different"} 
         if {$bin2sav    !=$bin2}     {return -code error "Erreur BIN2 different"} 
      }
      incr cpt
   }

   return -code ok ""
}



proc ::bddimages_imgcorrection::verif_filter_img {  } {

   set img_list ""
   foreach img $::bddimages_imgcorrection::flat_img_list    {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::sflat_img_list   {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::deflat_img_list  {lappend img_list $img}
   
   set filtersav ""
   set cpt 0

   foreach img $img_list {
      # A FAIRE
      #set bufno [::buf::create]
      #set bufno 1
      #buf$bufno load $fileimg
      #::bddimagesAdmin::bdi_compatible buf$bufno
      set tabkey [::bddimages_liste::lget $img "tabkey"]
      set filter [lindex [::bddimages_liste::lget $tabkey filter] 1]
      if {$cpt==0} {
         set filtersav $filter
      } else {
         if {$filtersav!=$filter} {return -code error "Erreur Filtre different"} 
      }
      incr cpt
   }

   return -code ok ""
}



proc ::bddimages_imgcorrection::name_to_stdname { name } {

   set result [string trim $name]
   #set result [string tolower $result]
   set result [string map {" " "_"} $result]
   return $result

}



proc ::bddimages_imgcorrection::create_filename_deflat { file } {

   set img_list $::bddimages_imgcorrection::deflat_img_list

   set filename ""
   foreach img $img_list {
      set filenametmp [::bddimages_liste::lget $img "filenametmp"]
      if {$file == $filenametmp} {
         set tabkey       [::bddimages_liste::lget $img "tabkey"]
         set telescop     [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey telescop] 1] ]
         set bin1         [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey bin1]     1] ]
         set bin2         [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey bin2]     1] ]
         set filter       [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey filter]   1] ]
         set dateobs      [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set object       [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey "object"] 1] ]
         set ms    [ string range $dateobs end-2 end ]
         set date  [ string range $dateobs 0 end-4 ]
         set date  [ clock format [clock scan $date] -format %Y%m%d_%H%M%S ]
         set filename "${telescop}_${date}_${ms}_bin${bin1}x${bin2}_F${filter}_${object}"
         break
      }
   }

   return $filename
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

   set commundatejjmoy 0
   set cpt 0
   foreach img $img_list {
      set tabkey       [::bddimages_liste::lget $img "tabkey"]
      set telescop     [lindex [::bddimages_liste::lget $tabkey telescop] 1]
      set bin1         [lindex [::bddimages_liste::lget $tabkey bin1]     1]
      set bin2         [lindex [::bddimages_liste::lget $tabkey bin2]     1]
      set filter       [string trim [lindex [::bddimages_liste::lget $tabkey filter]   1] ]
      set commundatejj [::bddimages_liste::lget $img commundatejj]
      set commundatejjmoy [expr $commundatejjmoy + $commundatejj]
      incr cpt
   }

   if { $cpt == 0 } {
      return ""
   }

   set commundatejjmoy  [ expr $commundatejjmoy / $cpt ]
   set dateobs          [ mc_date2iso8601 $commundatejjmoy ]
   set ms               [ string range $dateobs end-2 end ]
   set commundatejjmoy  [ string range $dateobs 0 end-4 ]
   set commundatejjmoy  [ clock format [clock scan $commundatejjmoy] -format %Y%m%d_%H%M%S ]
 

   if {$type=="offset"||$type=="dark"} { 
      set filename "${telescop}_${commundatejjmoy}_${ms}_bin${bin1}x${bin2}_${type}"
   }
   if {$type=="flat"} { 
      set filename "${telescop}_${commundatejjmoy}_${ms}_bin${bin1}x${bin2}_F${filter}_${type}"
   }

   return [list $filename $dateobs $bin1 $bin2]
}



proc ::bddimages_imgcorrection::create_image_offset { type inforesult } {

   global bddconf

   set bufno 1
   set fileout  [lindex $inforesult 0]
   set dateobs  [lindex $inforesult 1]

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nboffset   [llength $::bddimages_imgcorrection::offset_img_list]
   set k [expr $nboffset - 1]

   set methode 1
   set fileout ${fileout}${methode}

   if {$methode == 1} {
      buf$bufno load "$bddconf(dirtmp)/${type}0$ext"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) offset 0  $k $ext $bddconf(dirtmp) $fileout . $ext MED"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout . . $ext $bddconf(dirtmp) $fileout . $ext STAT"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd \"MEAN\"]\n"
   }
   if {$methode == 2} {

   }

   buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
   buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
   buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno clear

   insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

}



proc ::bddimages_imgcorrection::create_image_dark { type inforesult } {

  global bddconf

   set bufno 1
   set fileout  [lindex $inforesult 0]
   set dateobs  [lindex $inforesult 1]

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nbdark [llength $::bddimages_imgcorrection::dark_img_list]
   set k [expr $nbdark - 1]

   set methode 1
   set fileout ${fileout}${methode}
   
   if {$methode == 1} {
      buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k $ext $bddconf(dirtmp) $fileout . $ext MED"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd MEAN]\n"
   }
   
   if {$methode == 2} {
      buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k $ext $bddconf(dirtmp) $fileout . $ext MED"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd MEAN]\n"
   }
   
   if {$methode == 3} {

      set f [file join $bddconf(dirtmp) ${fileout}]

      smedian dark ${fileout} $k
   }
   
   if {$methode == 4} {

      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark 0 $k $ext $bddconf(dirtmp) $fileout . $ext MED"
   }
   



   buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
   ::console::affiche_resultat "MEAN DARK: [buf$bufno getkwd MEAN]\n"
   buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
   buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
   buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
   
   buf$bufno clear

   insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

}



proc ::bddimages_imgcorrection::get_stat { bufno } {

   set stat [buf$bufno stat]
   return "moy=[lindex $stat 4] sig=[lindex $stat 5]"

}



proc ::bddimages_imgcorrection::create_image_flat { type inforesult } {

   global bddconf

   set bufno 1
   set fileout  [lindex $inforesult 0]
   set dateobs  [lindex $inforesult 1]

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nbsoffset [llength $::bddimages_imgcorrection::soffset_img_list]
   set nbsdark   [llength $::bddimages_imgcorrection::sdark_img_list]
   set nbflat    [llength $::bddimages_imgcorrection::flat_img_list]
   set k [expr $nbflat - 1]

   set methode 1
   set fileout ${fileout}${methode}
      
   if {$methode == 1} {

      # Ni Dark Ni Offset -> on normalise les flat
      if {$nbsoffset == 0 && $nbsdark == 0 } {
         for {set x 0} {$x<$nbflat} {incr x} {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flat $x $x $ext $bddconf(dirtmp) flatn $x $ext NORMGAIN normgain_value=44000"
         }
      }

      # Dark + Offset -> soustraction des Dark et Offset
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat 0 $k $ext $bddconf(dirtmp) flats 0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000"
         for {set x 0} {$x<$nbflat} {incr x} {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flats $x $x $ext $bddconf(dirtmp) flatn $x $ext NORMGAIN normgain_value=44000"
         }
      }
      
      # Offset uniquement -> soustraction des Offset
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat 0 $k $ext $bddconf(dirtmp) flatn 0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0"
      }
      
      # Dark uniquement -> Soustraction des Dark
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         #loadima [file join $bddconf(dirtmp) "sdark0$ext"]
         set f [file join $bddconf(dirtmp) "sdark0$ext"]
         buf$bufno load $f

         #::console::affiche_resultat "SDARK sdark0$ext\n"
         #::console::affiche_resultat "STAT sdark0$ext [get_stat $bufno]\n"
         #::console::affiche_resultat "ALL [buf$bufno getkwds]\n"
         #::console::affiche_resultat "MEAN [lindex [buf$bufno getkwd MEAN] 1]\n"
         #::console::affiche_resultat "EXPOSURE [buf$bufno getkwd EXPOSURE]\n"

         set meandark [lindex [buf$bufno getkwd MEAN] 1]
         set expodark [expr [lindex [buf$bufno getkwd EXPOSURE] 1] * 1.0]

         #::console::affiche_resultat "SDARK - MEAN : $meandark - EXPOSURE : $expodark\n"

         for {set x 0} {$x<$nbflat} {incr x} {

            #::console::affiche_resultat "FLAT flat${x}${ext}\n"
            buf$bufno load "$bddconf(dirtmp)/flat${x}${ext}"
            #::console::affiche_resultat "STAT flat av [get_stat $bufno]\n"

            set meanflat [lindex [buf$bufno getkwd MEAN] 1]
            set expoflat [expr [lindex [buf$bufno getkwd EXPOSURE] 1]  * 1.0]        

            set fact [expr $expoflat / $expodark]
            ::console::affiche_resultat "FLAT - MEAN : $meanflat - EXPOSURE : $expoflat - FACT : $fact\n"
            
            buf$bufno load "$bddconf(dirtmp)/sdark0${ext}"
            #::console::affiche_resultat "STAT sdark1 av [get_stat $bufno]\n"

            # divise le DARK par un facteur des temps d exposition
            ttscript2 "IMA/SERIES $bddconf(dirtmp) sdark0 . . $ext $bddconf(dirtmp) sdark1 . $ext MULT constant=$fact"
            #buf$bufno load "$bddconf(dirtmp)/sdark1${ext}"
            #::console::affiche_resultat "STAT sdark1 ap [get_stat $bufno]\n"
            
            # Soustraction du DARK
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flat $x $x $ext $bddconf(dirtmp) flats $x $ext SUB file=$bddconf(dirtmp)/sdark1$ext offset=0"
            #buf$bufno load "$bddconf(dirtmp)/flats${x}${ext}"
            #::console::affiche_resultat "STAT flats [get_stat $bufno]\n"

            # Normalisation du FLAT
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flats $x $x $ext $bddconf(dirtmp) flatn $x $ext NORMGAIN normgain_value=44000"
            buf$bufno load "$bddconf(dirtmp)/flatn${x}${ext}"
            ::console::affiche_resultat "STAT flatn [get_stat $bufno]\n"
         }

      }

      # Pile KAPPA SIGMA
      #ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn 0  $k $ext $bddconf(dirtmp) $fileout . $ext KS kappa=3"

      # Pile MEDIANE
      ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn 0  $k $ext $bddconf(dirtmp) $fileout . $ext MED"

      # Inscrit les stat dans le header de l image
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      set mean [buf$bufno getkwd "MEAN"]
      ::console::affiche_resultat "MEAN : $mean\n"
      ::console::affiche_resultat "STAT flat [get_stat $bufno]\n"
      #::console::affiche_resultat "ttscript2 \"IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT\""
   }

   if {$methode == 2} {

      # Soustraction des Dark et Offset
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000"
      }
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0"
      }
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0"
      }

      # Pile Mediane
      buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) flat       0  $k $ext $bddconf(dirtmp) $fileout . $ext MED"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd \"MEAN\"]\n"
   }


   if { $methode == 3 } {

      if {$nbsoffset == 0 && $nbsdark == 1 } {
         sub2 flat sdark0 flats 0 $k
         ngain2 flats flatn 20000 $k
         smedian flatn ${fileout} $k
      }


   }

   if { $methode == 4 } {

      if {$nbsoffset == 0 && $nbsdark == 1 } {
      
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat  0  $k $ext $bddconf(dirtmp) flats    0  $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0" 
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flats 0  $k $ext $bddconf(dirtmp) flatn    0  $ext NORMGAIN normgain_value=20000"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn 0  $k $ext $bddconf(dirtmp) $fileout .  $ext MED"
      }


   }

   buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
   buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
  # buf$bufno mirrorx
   buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno clear

   insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

}



proc ::bddimages_imgcorrection::create_image_deflat {  } {

   global bddconf
      
   set bufno 1

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nbsoffset [llength $::bddimages_imgcorrection::soffset_img_list]
   set nbsdark   [llength $::bddimages_imgcorrection::sdark_img_list]
   set nbsflat   [llength $::bddimages_imgcorrection::sflat_img_list]
   set nbdeflat  [llength $::bddimages_imgcorrection::deflat_img_list]
   set k [expr $nbdeflat - 1]

   set methode 1
   
   if {$methode == 1} {

      # Soustraction des Dark et Offset
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ::console::affiche_resultat "Soustraction des Dark et Offset\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000"
      }
      # Soustraction des Offset (pas de Dark)
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         ::console::affiche_resultat "Soustraction de l OFFSET\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0"
      }
      # Soustraction des Dark (pas d'Offset)
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         ::console::affiche_resultat "Soustraction du DARK\n"
         if {1==1} {
            set f [file join $bddconf(dirtmp) "sdark0$ext"]
            buf$bufno load $f
            set meandark [lindex [buf$bufno getkwd MEAN] 1]
            set expodark [expr [lindex [buf$bufno getkwd EXPOSURE] 1] * 1.0]

            for {set x 0} {$x<$nbdeflat} {incr x} {
               buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
               set meandeflat [lindex [buf$bufno getkwd MEAN] 1]
               set expodeflat [expr [lindex [buf$bufno getkwd EXPOSURE] 1]  * 1.0]        
               set fact [expr $expodeflat / $expodark]
               ::console::affiche_resultat "FLAT - MEAN : $meandeflat - EXPOSURE : $expodeflat - FACT : $fact\n"
               ttscript2 "IMA/SERIES $bddconf(dirtmp) sdark0 .  .  $ext $bddconf(dirtmp) sdark1 .  $ext MULT constant=$fact"
               ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat $x $x $ext $bddconf(dirtmp) deflat $x $ext SUB file=$bddconf(dirtmp)/sdark1$ext offset=0"
            }
         } else {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0"
         }
      }
      # Division par le Flat
      if { $nbsflat == 1 } {
         set f [file join $bddconf(dirtmp) "sflat0$ext"]
         buf$bufno load $f
         set meanflat [lindex [buf$bufno getkwd MEAN] 1]
         ::console::affiche_resultat "K . E / F -- K = $meanflat\n"

         # Division par le flat
         ::console::affiche_resultat "Division par le flat\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext DIV file=$bddconf(dirtmp)/sflat0$ext constant=$meanflat nullpixel=-10000"

         # Change les mots cles
         ::console::affiche_resultat "Modif Header\n"
         for {set x 0} {$x<$nbdeflat} {incr x} {

            buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
            buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
            set fileout [::bddimages_imgcorrection::create_filename_deflat "deflat${x}${ext}"]
            buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
            buf$bufno clear
            ::console::affiche_resultat " $x / $k : "
            insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
         }
      }

   }

   if { $methode == 3 } {
      sub2 deflat sdark0 deflat 0 $k
      div2 deflat sflat0 deflat 20000 $k
      for {set x 1} {$x<$nbdeflat} {incr x} {
         buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
         buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
         set fileout [::bddimages_imgcorrection::create_filename_deflat "deflat${x}${ext}"]
         buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
         buf$bufno clear
         ::console::affiche_resultat " $x / $k : "
         insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
      }
   }

   if { $methode == 4 } {

      ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0" 
      ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext DIV file=$bddconf(dirtmp)/sflat0$ext constant=20000 nullpixel=-10000"
      for {set x 1} {$x<$nbdeflat} {incr x} {
         buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
         buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
         set fileout [::bddimages_imgcorrection::create_filename_deflat "deflat${x}${ext}"]
         buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
         buf$bufno clear
         ::console::affiche_resultat " $x / $k : "
         insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
      }
   }

}



proc ::bddimages_imgcorrection::create_image { type inforesult} {

  global bddconf

   if {$type=="offset"} {
      ::bddimages_imgcorrection::create_image_offset $type $inforesult
   }
   if {$type=="dark"} {
      ::bddimages_imgcorrection::create_image_dark  $type $inforesult
   }
   if {$type=="flat"} {
      ::bddimages_imgcorrection::create_image_flat $type $inforesult
   }
   if {$type=="deflat"} {
      ::bddimages_imgcorrection::create_image_deflat
   }

}



proc ::bddimages_imgcorrection::delete_to_tmp { type img_list } {

   global bddconf

   set bufno 1
   set ext [buf$bufno extension]
   set nb  [llength $img_list]
   for {set i 0} {$i<$nb} {incr i} {
      file delete -force -- [file join $bddconf(dirtmp) ${type}${i}${ext}]
   }

}




proc ::bddimages_imgcorrection::copy_to_tmp { type img_list } {

   global bddconf
   global audace

   set k 0
   set new_list ""

   foreach img $img_list {   
   
      set filename    [string trim [::bddimages_liste::lget $img "filename"] ]
      set dirfilename [string trim [::bddimages_liste::lget $img "dirfilename"] ]
   
      # test filename et dirfilename non null
      set fichier [file join $bddconf(dirbase) $dirfilename $filename]
      
      set f "${type}${k}${bddconf(extension_tmp)}"
      set fc "$bddconf(dirtmp)/$f.gz"
      set fm "$bddconf(dirtmp)/$f"
      set errnum [catch {file copy -force -- $fichier $fc} msg]
      if {$errnum == 0} {
         #::console::affiche_resultat "cp image : $fichier\n"
         #::console::affiche_resultat "gunzip $fc \n"
         if { [file exists $fm] == 1 } {
            set errnum [catch {file delete -force -- $fm} msg]
         }

         set errnum [catch {exec gunzip $fc } msg ]
         if {$errnum == 0} {
            #::console::affiche_resultat "dezip image : $f\n"
            lappend img [list filenametmp $f ]
            lappend new_list $img
            incr k
         } else {
            ::console::affiche_erreur "Erreur gunzip : $fm \n"
            ::console::affiche_erreur "errnum : $errnum\n"
            ::console::affiche_erreur "msg    : $msg\n"
         }

      } else {
         ::console::affiche_erreur "Erreur copy_to_tmp : $fichier\n"
         ::console::affiche_erreur "errnum : $errnum\n"
         ::console::affiche_erreur "msg    : $msg\n"
      }
      
   }

   ::console::affiche_resultat "Copie de $k $type\n"

   return $new_list    
}



proc ::bddimages_imgcorrection::correction { type inforesult} {

   global action_label audace bddconf

   set audace(rep_images) $bddconf(dirtmp)
   cd $bddconf(dirtmp)

   set ::bddimages_imgcorrection::offset_img_list  [::bddimages_imgcorrection::copy_to_tmp "offset"  $::bddimages_imgcorrection::offset_img_list  ]
   set ::bddimages_imgcorrection::soffset_img_list [::bddimages_imgcorrection::copy_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list] 
   set ::bddimages_imgcorrection::dark_img_list    [::bddimages_imgcorrection::copy_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list   ]  
   set ::bddimages_imgcorrection::sdark_img_list   [::bddimages_imgcorrection::copy_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list  ]  
   set ::bddimages_imgcorrection::flat_img_list    [::bddimages_imgcorrection::copy_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list   ]  
   set ::bddimages_imgcorrection::sflat_img_list   [::bddimages_imgcorrection::copy_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list  ]  
   set ::bddimages_imgcorrection::deflat_img_list  [::bddimages_imgcorrection::copy_to_tmp "deflat"  $::bddimages_imgcorrection::deflat_img_list ]  

   set errnum [catch {create_image $type $inforesult} msg]
   if {$errnum != 0} {
      ::console::affiche_erreur "Erreur sur la creation de $type\n"
      ::console::affiche_erreur "errnum : $errnum\n"
      ::console::affiche_erreur "msg    : $msg\n"
   } else {
      ::bddimages_imgcorrection::delete_to_tmp "offset"  $::bddimages_imgcorrection::offset_img_list
      ::bddimages_imgcorrection::delete_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list 
      ::bddimages_imgcorrection::delete_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list   
      ::bddimages_imgcorrection::delete_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "flatn"   $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "flats"   $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list   
      ::bddimages_imgcorrection::delete_to_tmp "deflat"  $::bddimages_imgcorrection::deflat_img_list   
      file delete -force -- [file join $bddconf(dirtmp) tt.log]
   }

   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
   return 0

}




#--------------------------------------------------
# img_list_to_filename_list { img_list }
#--------------------------------------------------
#
#    fonction  :
#        Fournit un extrait de la liste imgtmplist
#        correspodant au mot cl� : bddimages type
#
#    procedure externe :
#
#    variables en entree :
#        type = mot cl� bddimages type
#        imgtmplist = liste complete d image
#
#    variables en sortie :
#        imgtmplist = liste complete d image de meme mot cl� bddimages type
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::img_list_to_filename_list { img_list typ } {

   global bddconf

   set result_list ""
   foreach img $img_list {
      lappend result_list [::bddimages_imgcorrection::img_to_filename $img $typ]
   }
   return $result_list

}


proc ::bddimages_imgcorrection::img_to_filename { img typ } {

   global bddconf

   set result ""

   set filename    [::bddimages_liste::lget $img filename]
   set dirfilename [::bddimages_liste::lget $img dirfilename]
   set filenametmp [::bddimages_liste::lget $img filenametmp]
   
   if { $typ == "long" } {
      return [file join $bddconf(dirbase) $dirfilename $filename]
   }
   if { $typ == "short" } {
      return $filename
   }
   if { $typ == "tmp" } {
      return $filenametmp
   }
   if { $typ == "longtmp" } {
      return [file join $bddconf(dirtmp) $filenametmp] 
   }
  
   return "-1"
}



#--------------------------------------------------
# select_img_list_by_type { type img_list }
#--------------------------------------------------
#
#    fonction  :
#        Fournit un extrait de la liste imgtmplist
#        correspodant au mot cl� : bddimages_type
#
#    procedure externe :
#
#    variables en entree :
#        bddimages_type = mot cl� bddimages_type
#        bddimages_state = mot cl� bddimages_state
#        img_list = liste complete d image
#
#    variables en sortie :
#        result_list = liste complete d image de meme mot cl� bddimages_type
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::select_img_list_by_type { bddimages_type bddimages_state img_list } {


   #::console::affiche_resultat "img_list $img_list \n"
   set result_list ""


   foreach img $img_list {
      set keep "ok"
      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set bdditype  [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_type"] 1]]
      set bddistate [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_state"] 1]]
      #::console::affiche_resultat "result $bdditype $bddistate\n"

      if {($bddimages_type  == $bdditype)&&($bddimages_state == $bddistate)}  {
         lappend result_list $img
      }
   }

   #::console::affiche_resultat "result_list $bddimages_type $bddimages_state $result_list \n"
   return $result_list
}



proc ::bddimages_imgcorrection::chrono_first_img { img_list } {

   set cpt 0
   foreach img $img_list {
      incr cpt
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      if {$cpt == 1} {
         set datemin $commundatejj
         set result_img $img
         continue
      }
      if { $commundatejj < $datemin} {
         set datemin $commundatejj
         set result_img $img
      }
   }
   return $result_img
}



proc ::bddimages_imgcorrection::chrono_last_img { img_list } {

   set cpt 0
   foreach img $img_list {
      incr cpt
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      if {$cpt == 1} {
         set datemin $commundatejj
         set result_img $img
         continue
      }
      if { $commundatejj > $datemin} {
         set datemin $commundatejj
         set result_img $img
      }
   }
   return $result_img
}



proc ::bddimages_imgcorrection::chrono_sort_img { img_list } {

   set sort_img_list ""
   foreach img $::bddimages_cdl::img_list {
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      lappend sort_img_list [list $commundatejj $img]
   }

   set sort_img_list [lsort -real -index 0 $sort_img_list]

   set result_img_list ""
   foreach line $sort_img_list {
      lappend result_img_list [lindex $line 1]
   }

   return $result_img_list
}



proc ::bddimages_imgcorrection::bddimages_mirroirx { img_list } {

   global bddconf

   #? set ::bddimages_imgcorrection::imgtmplist $imglist
   set filename_list [::bddimages_imgcorrection::img_list_to_filename_list $img_list long]
   set bufno 1
   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   foreach fc $filename_list {

     ::console::affiche_resultat "file $fc\n"
     buf$bufno load $fc
     buf$bufno mirrorx
     set fileout [file tail $fc ]
     buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"

   }

}



proc ::bddimages_imgcorrection::showReport { {title "Console"} {ltexte "Empty"} {format ""} } {

   variable This
   global audace
   global caption
   global color
   global imgConsole

   set imgConsole $This.report
   if { [ winfo exists $imgConsole ] } {
      destroy $imgConsole
   }

   toplevel $imgConsole -class Toplevel
   wm title $imgConsole "BddImages - Console"
   wm positionfrom $imgConsole user
   wm sizefrom $imgConsole user
   wm resizable $imgConsole 1 1
   wm geometry $imgConsole "400x200"
   wm protocol $imgConsole WM_DELETE_WINDOW { 
      destroy $imgConsole 
   }

   set zonetext $imgConsole.text
   text $zonetext -height 30 -width 80 -yscrollcommand "$zonetext.scroll set"
   pack $zonetext -expand yes -fill both -padx 5 -pady 5
   scrollbar $zonetext.scroll -command "$zonetext.text yview"
   pack $zonetext.scroll -side right -fill y

   $zonetext tag configure BODY -foreground black -background white
   $zonetext tag configure TITLE -foreground "#808080" -justify center -font [ list {Arial} 12 bold ] 
   $zonetext tag configure H1 -justify left -font [ list {Arial} 10 normal ] -wrap word
   $zonetext tag configure H2 -justify left -font [ list {Arial} 10 normal ] -foreground $color(blue) -wrap word 
   $zonetext tag configure LISTE0 -foreground $color(black) -lmargin1 20 -lmargin2 20 -rmargin 10 -wrap word
   $zonetext tag configure LISTE1 -foreground $color(red) -lmargin1 20 -lmargin2 20 -rmargin 10 -wrap word
   $zonetext tag configure GREEN -foreground $color(green) -wrap word
   $zonetext tag configure RED -foreground $color(red) -wrap word

   $zonetext insert end "$title \n\n" TITLE
   foreach t $ltexte { 
      $zonetext insert end "* [lindex $t 0] : [lindex $t 1] \n" $format
   }

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
   
   global This
   global audace bddconf caption
   global entetelog

   # Type de correction (e.g. flat)
   set ::bddimages_imgcorrection::type $type

   # Recuperation des informations des images selectionnees
   set selection_list [::bddimages_imgcorrection::get_info_img]

   # Initialisations
   set ::bddimages_imgcorrection::offset_img_list  ""
   set ::bddimages_imgcorrection::soffset_img_list ""
   set ::bddimages_imgcorrection::dark_img_list    ""
   set ::bddimages_imgcorrection::sdark_img_list   ""
   set ::bddimages_imgcorrection::flat_img_list    ""
   set ::bddimages_imgcorrection::sflat_img_list   ""
   set ::bddimages_imgcorrection::deflat_img_list  ""
   set ::bddimages_imgcorrection::erreur_selection 0

   set reportMessage ""
   set reportFilename ""

   # Definition des vignettes
   image create photo icon_ok
   icon_ok configure -file [file join $audace(rep_plugin) tool bddimages icons ok.gif]
   image create photo icon_no
   icon_no configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
   image create photo icon_warn
   icon_warn configure -file [file join $audace(rep_plugin) tool bddimages icons warn.gif]
   image create photo icon_report
   icon_report configure -file [file join $audace(rep_plugin) tool bddimages icons report.gif]

   # Affichage de la fenetre
   set entetelog "$caption(bddimages_imgcorrection,main_title)"
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
   wm resizable $This 0 0

   set framecurrent $This.framename
   frame $framecurrent
   pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

   # Frame de titre
   frame $framecurrent.title
   pack configure $framecurrent.title -side top -fill x
   switch $::bddimages_imgcorrection::type {
      offset { set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,insoffset)] }
      dark   { set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,insdark)] }
      flat   { set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,insflat)] }
      deflat { set title $caption(bddimages_imgcorrection,correction) }
   }
   label $framecurrent.title.e -font $bddconf(font,arial_10_b) -text $title
   pack configure $framecurrent.title.e -side top -anchor c -padx 3 -pady 3 -fill x 

   # Images d'entree
   frame $framecurrent.input -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.input -side top -padx 5 -pady 5 -fill x
      frame $framecurrent.input.title
      pack configure $framecurrent.input.title -side top -fill x
         label $framecurrent.input.title.t -relief groove -text "$caption(bddimages_imgcorrection,input)" 
         pack $framecurrent.input.title.t -in $framecurrent.input.title -side top -padx 3 -pady 3 -anchor w -fill x -expand 1
      set inputFrame $framecurrent.input.tab
      frame $inputFrame
      pack configure $inputFrame -side top -expand 0
         frame $inputFrame.filetype
         pack configure $inputFrame.filetype -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filenb
         pack configure $inputFrame.filenb -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filestatus
         pack configure $inputFrame.filestatus -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filereport
         pack configure $inputFrame.filereport -side left -fill x -padx 2 -pady 1

   # ------------------------------------------------------------------
   #                     Creation d'un OFFSET MAITRE 
   # ------------------------------------------------------------------
   if {$type == "offset"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,inoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "offset" $caption(bddimages_imgcorrection,nooffset)]
         lappend reportFilename [list "offset" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::offset_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.offset -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.offset -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     Creation d'un DARK MAITRE 
   # ------------------------------------------------------------------
   if {$type == "dark"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,insoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master offset" $caption(bddimages_imgcorrection,oneoffset)]
         lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::soffset_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste DARK
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_imgcorrection,indark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "dark" $caption(bddimages_imgcorrection,nodark)]
         lappend reportFilename [list "dark" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::dark_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.dark -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.dark -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     Creation d'un FLAT MAITRE
   # ------------------------------------------------------------------
   if {$type == "flat"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,insoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master offset" $caption(bddimages_imgcorrection,oneoffset)]
         lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::soffset_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste SDARK
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_imgcorrection,insdark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master dark" $caption(bddimages_imgcorrection,onedark)]
         lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::sdark_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste FLAT
      set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.flat -text "$caption(bddimages_imgcorrection,inflat)"
      pack $inputFrame.filetype.flat -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.flat -text $nbi
      pack $inputFrame.filenb.flat -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "flat" $caption(bddimages_imgcorrection,noflat)]
         lappend reportFilename [list "flat" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::flat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "flat" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.flat -image $icon
      pack $inputFrame.filestatus.flat -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.flat -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.flat -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     DEFLAT images 
   # ------------------------------------------------------------------
   if {$type == "deflat"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,insoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master offset" $caption(bddimages_imgcorrection,oneoffset)]
         lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::soffset_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w
      
      # Chargement de la liste SDARK
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_imgcorrection,insdark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master dark" $caption(bddimages_imgcorrection,onedark)]
         lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::sdark_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste SFLAT
      set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.flat -text "$caption(bddimages_imgcorrection,insflat)"
      pack $inputFrame.filetype.flat -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.flat -text $nbi
      pack $inputFrame.filenb.flat -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0 || $nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master flat" $caption(bddimages_imgcorrection,oneflat)]
         lappend reportFilename [list "master flat" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::sflat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "master flat" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.flat -image $icon
      pack $inputFrame.filestatus.flat -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w
      
      # Chargement de la liste IMG
      set img_list [::bddimages_imgcorrection::select_img_list_by_type IMG RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.img -text "$caption(bddimages_imgcorrection,inimg)"
      pack $inputFrame.filetype.img -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.img -text $nbi
      pack $inputFrame.filenb.img -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "image" $caption(bddimages_imgcorrection,noimg)]
         lappend reportFilename [list "image" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::deflat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "image" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.img -image $icon
      pack $inputFrame.filestatus.img -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.img -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.img -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # Image RESULTAT
   frame $framecurrent.output -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.output -side top -padx 5 -pady 5 -fill x
      frame $framecurrent.output.title
      pack configure $framecurrent.output.title -side top -fill x
         label $framecurrent.output.title.t -relief groove -text "$caption(bddimages_imgcorrection,output)" 
         pack $framecurrent.output.title.t -in $framecurrent.output.title -side top -padx 3 -pady 3 -anchor w -fill x -expand 1
      set outputFrame $framecurrent.output.tab
      frame $outputFrame
      pack configure $outputFrame -side top -expand 0 -padx 2 -pady 1

   # Si les elements selectionnes permettent l'action...
   if {$::bddimages_imgcorrection::erreur_selection == 0} {
      # concatenation des listes
      if {[catch {::bddimages_imgcorrection::verif_all_img} msg]}  {
         ::console::affiche_erreur "ERROR: $msg\n"
         return
      }
      if {[catch {::bddimages_imgcorrection::verif_filter_img} msg]}  {
         ::console::affiche_erreur "ERROR: $msg\n"
         return
      }

      set filename "<generic>"
      if { [llength $::bddimages_imgcorrection::deflat_img_list] == 0 } {
         set ::bddimages_imgcorrection::inforesult [::bddimages_imgcorrection::create_filename $type]
         set filename [lindex $::bddimages_imgcorrection::inforesult 0]
      }
      label $outputFrame.name -text "$filename"
      pack $outputFrame.name -in $outputFrame -side top -padx 3 -pady 1 -anchor w
      
   } else {
      label $outputFrame.name -text "$caption(bddimages_imgcorrection,noresult)"
      pack $outputFrame.name -in $outputFrame -side left -padx 3 -pady 1 -anchor w
      button $outputFrame.helpme -text ? \
         -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleE) $reportMessage LISTE1]
      pack configure $outputFrame.helpme -side left
   }
   
   # Frame boutons Cancel et Ok
   frame $framecurrent.buttons
   pack configure $framecurrent.buttons -side top -fill x -padx 3 -pady 3
      # --- ok
      if {$::bddimages_imgcorrection::erreur_selection == 0} {
        button $framecurrent.buttons.ok -text Ok \
           -command {
              ::bddimages_imgcorrection::correction $::bddimages_imgcorrection::type $::bddimages_imgcorrection::inforesult
              destroy $This
           }
        pack configure $framecurrent.buttons.ok -side right
      }
      # --- cancel
      button $framecurrent.buttons.cancel -text Cancel -command {destroy $This}
      pack configure $framecurrent.buttons.cancel -side right

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
   #--- Surcharge la couleur de fond des resultats
   $framecurrent.title.e configure -font $bddconf(font,arial_10_b)

   grab set $This
   tkwait window $This
}
