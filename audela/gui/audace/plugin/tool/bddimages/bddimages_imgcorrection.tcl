#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_imgcorrection.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_imgcorrection.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6858 2011-03-06 14:19:15Z fredvachier $
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
         set tabkey   [::bddimages_liste::get_key_img $img "tabkey"]
         set telescop [::bddimages_liste::get_key_img $tabkey telescop]
         set bin1     [::bddimages_liste::get_key_img $tabkey bin1]
         set bin2     [::bddimages_liste::get_key_img $tabkey bin2]
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
      
      set filtresav ""
      set cpt 0

      foreach img $img_list {
         # A FAIRE
         #set bufno [::buf::create]
         #set bufno 1
         #buf$bufno load $fileimg
         #::bddimagesAdmin::bdi_compatible buf$bufno
         set tabkey   [::bddimages_liste::get_key_img $img "tabkey"]
         set filtre [::bddimages_liste::get_key_img $tabkey filtre]
         if {$cpt==0} {
            set filtresav $filtre
            } else {
            if {$filtresav!=$filtre} {return -code error "Erreur Filtre different"} 
            }
      incr cpt
      }
   
      return -code ok ""
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
         set tabkey   [::bddimages_liste::get_key_img $img "tabkey"]
         set telescop [::bddimages_liste::get_key_img $tabkey telescop]
         set bin1     [::bddimages_liste::get_key_img $tabkey bin1]
         set bin2     [::bddimages_liste::get_key_img $tabkey bin2]
         set filtre   [::bddimages_liste::get_key_img $tabkey filtre]
         set commundatejj   [::bddimages_liste::get_key_img $img commundatejj]
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
      set commundatejjmoy  [clock format [clock scan $commundatejjmoy] -format %Y%m%d_%H%M%S]
 

      if {$type=="offset"||$type=="dark"} { 
         set filename "${telescop}_${commundatejjmoy}_${ms}_bin${bin1}x${bin2}_${type}"
      }
      if {$type=="flat"} { 
         set filename "${telescop}_${commundatejjmoy}_${ms}_bin${bin1}x${bin2}_F${filtre}_${type}"
      }

      return [list $filename $dateobs $bin1 $bin2]
   }





proc create_image_offset { type inforesult } {

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
         ttscript2 "IMA/STACK  $bddconf(dirtmp) offset       0  $k $ext $bddconf(dirtmp) $fileout . $ext KS kappa=3"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
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





proc create_image_dark { type inforesult } {

  global bddconf

      set bufno 1
      set fileout  [lindex $inforesult 0]
      set dateobs  [lindex $inforesult 1]

      set ext [buf$bufno extension]
      set gz [buf$bufno compress]
      if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

      set nbdark   [llength $::bddimages_imgcorrection::dark_img_list]
      set k [expr $nbdark - 1]

      set methode 1
      set fileout ${fileout}${methode}
      
      if {$methode == 1} {
         buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k $ext $bddconf(dirtmp) $fileout . $ext KS kappa=3"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
         buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
         ::console::affiche_resultat "MEAN : [buf$bufno getkwd "MEAN"]\n"
      }
      
      if {$methode == 2} {
         buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k $ext $bddconf(dirtmp) $fileout . $ext KS kappa=3"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT"
         buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
         ::console::affiche_resultat "MEAN : [buf$bufno getkwd \"MEAN\"]\n"
      }
      



      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
      buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
      buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
      
      buf$bufno clear

      insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

  }

proc get_stat { bufno } {

set stat [buf$bufno stat]
return "moy=[lindex $stat 4] sig=[lindex $stat 5]"
}
















proc create_image_flat { type inforesult } {

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

       # Recuperation de la boite de selection d image
       # ::confVisu::getBox 1





      set methode 1
      set fileout ${fileout}${methode}
      
      if {$methode == 1} {

         # Soustraction des Dark et Offset
         if {$nbsoffset == 1 && $nbsdark == 1 } {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000"
         }
         if {$nbsoffset == 1 && $nbsdark == 0 } {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0"
         }
         if {$nbsoffset == 0 && $nbsdark == 1 } {


            #ttscript2 "IMA/SERIES $bddconf(dirtmp) sdark0 .  .  $ext $bddconf(dirtmp) sdark0 . $ext STAT"

            #loadima [file join $bddconf(dirtmp) "sdark0$ext"]
            set f [file join $bddconf(dirtmp) "sdark0$ext"]

            #loadima $f
            buf$bufno load $f
            ::console::affiche_resultat "buf1 load $f\n"


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
               #::console::affiche_resultat "FLAT - MEAN : $meanflat - EXPOSURE : $expoflat - FACT : $fact\n"
               
               buf$bufno load "$bddconf(dirtmp)/sdark0${ext}"
               #::console::affiche_resultat "STAT sdark1 av [get_stat $bufno]\n"

               # divise le DARK par un facteur des temps d exposition
               ttscript2 "IMA/SERIES $bddconf(dirtmp) sdark0 . . $ext $bddconf(dirtmp) sdark1 . $ext MULT constant=$fact"
               #buf$bufno load "$bddconf(dirtmp)/sdark1${ext}"
               #::console::affiche_resultat "STAT sdark1 ap [get_stat $bufno]\n"
               
               # Soustraction du DARK
               ttscript2 "IMA/SERIES $bddconf(dirtmp) flat   $x $x $ext $bddconf(dirtmp) flats     $x $ext SUB file=$bddconf(dirtmp)/sdark1$ext offset=0"
               #buf$bufno load "$bddconf(dirtmp)/flats${x}${ext}"
               #::console::affiche_resultat "STAT flats [get_stat $bufno]\n"

               # Normalisation du FLAT
               ttscript2 "IMA/SERIES $bddconf(dirtmp) flats   $x $x $ext $bddconf(dirtmp) flatn     $x $ext NORMGAIN normgain_value=44000"
               buf$bufno load "$bddconf(dirtmp)/flatn${x}${ext}"
               ::console::affiche_resultat "STAT flatn [get_stat $bufno]\n"
            }

         }

         # Pile KAPPA SIGMA
         #buf$bufno load "$bddconf(dirtmp)/flatn0${ext}"
         #::console::affiche_resultat "flatn$k$ext\n"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn    0  $k $ext $bddconf(dirtmp) $fileout . $ext KS kappa=3"
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

      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
      buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
     # buf$bufno mirrorx
      buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
      buf$bufno clear

      insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
  }




















proc create_image_deflat {  } {

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


      set fichiers [::bddimages_imgcorrection::img_list_to_filename_list $::bddimages_imgcorrection::deflat_img_list long]

      # Soustraction des Dark et Offset
      ::console::affiche_resultat "Soustraction des Dark et Offset\n"
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000"
      }
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0"
      }
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         # Soustraction du DARK
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0"
      }



      if { $nbsflat == 1 } {

         set f [file join $bddconf(dirtmp) "sflat0$ext"]
         buf$bufno load $f
         set meanflat [lindex [buf$bufno getkwd MEAN] 1]
         ::console::affiche_resultat "K . E / F -- K = $meanflat\n"

         # Division par le flat
         ::console::affiche_resultat "Division par le flat\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext DIV file=$bddconf(dirtmp)/sflat0$ext constant=$meanflat nullpixel=-10000 bitpix=16"

         # Change les mots cles
         ::console::affiche_resultat "Modif Header\n"
         for {set x 0} {$x<$nbdeflat} {incr x} {

            buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
            buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
            buf$bufno save "$bddconf(dirtmp)/fini${x}${ext}"
            buf$bufno clear

            #insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
         }

      }


  }








proc create_image { type inforesult} {

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
 







proc delete_to_tmp { type img_list } {

   global bddconf

      set bufno 1
      set ext [buf$bufno extension]
      set nb  [llength $img_list]
      for {set i 0} {$i<$nb} {incr i} {
      #   file delete -force -- [file join $bddconf(dirtmp) ${type}${i}${ext}]
      }

      }






proc copy_to_tmp { type img_list } {

   global bddconf
   global audace

      set k 0
      set new_list ""

      foreach img $img_list {
         foreach l $img {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {[string equal -nocase [string trim $key] "filename"]} {
               set filename $val
            }
            if {[string equal -nocase [string trim $key] "dirfilename"]} {
               set dirfilename $val
            }
         }
         
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
               lappend img [list tmpfile $f ]
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











proc correction { type inforesult} {

      global action_label audace bddconf

      set audace(rep_images) $bddconf(dirtmp)
      cd $bddconf(dirtmp)

      set ::bddimages_imgcorrection::offset_img_list  [::bddimages_imgcorrection::copy_to_tmp "offset" $::bddimages_imgcorrection::offset_img_list  ]
      set ::bddimages_imgcorrection::soffset_img_list [::bddimages_imgcorrection::copy_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list] 
      set ::bddimages_imgcorrection::dark_img_list    [::bddimages_imgcorrection::copy_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list   ]  
      set ::bddimages_imgcorrection::sdark_img_list   [::bddimages_imgcorrection::copy_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list  ]  
      set ::bddimages_imgcorrection::flat_img_list    [::bddimages_imgcorrection::copy_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list   ]  
      set ::bddimages_imgcorrection::sflat_img_list   [::bddimages_imgcorrection::copy_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list  ]  
      set ::bddimages_imgcorrection::deflat_img_list  [::bddimages_imgcorrection::copy_to_tmp "deflat"  $::bddimages_imgcorrection::deflat_img_list ]  

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
      #::bddimages_imgcorrection::delete_to_tmp "img"     $::bddimages_imgcorrection::deflat_img_list   
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

      set filename    [::bddimages_liste::get_key_img $img filename]
      set dirfilename [::bddimages_liste::get_key_img $img dirfilename]
      set filenametmp [::bddimages_liste::get_key_img $img filenametmp]
      
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
         set tabkey [::bddimages_liste::get_key_img $img "tabkey"]
         foreach l $tabkey {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="bddimages_type"}  { if {[string trim $val]!=$bddimages_type } { set keep "no" } }
            if {$key=="bddimages_state"} { if {[string trim $val]!=$bddimages_state} { set keep "no" } }
         }
         if {$keep=="ok"} {
            lappend result_list $img
         }
      }
      #::console::affiche_resultat "result_list $result_list \n"
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
         set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET RAW $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images OFFSET d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des OFFSET\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::offset_img_list $img_list
         }

      }

      if {$type == "dark"}  {

        # Chargement de la liste SOFFSET
         set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]

         set nbi [llength $img_list]
         set texte "${texte}- Images OFFSET d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul OFFSET\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::soffset_img_list $img_list
         }
         
         # Chargement de la liste DARK
         set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK RAW $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images DARK d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des DARK\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::dark_img_list $img_list
         }

      }

      if {$type == "flat"}  {

         # Chargement de la liste SOFFSET
         set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images OFFSET d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul OFFSET\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::soffset_img_list $img_list
         }
         
         # Chargement de la liste SDARK
         set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images DARK d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul DARK\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::sdark_img_list $img_list
         }
         
         # Chargement de la liste FLAT
         set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT RAW $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images FLAT d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des FLAT\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::flat_img_list $img_list
         }

      }

      if {$type == "deflat"}  {

         # Chargement de la liste SOFFSET
         set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images OFFSET d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul OFFSET\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::soffset_img_list $img_list
         }
         
         # Chargement de la liste SDARK
         set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images DARK d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul DARK\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::sdark_img_list $img_list
         }
         
         # Chargement de la liste SDARK
         set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT CORR $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images FLAT d entree : nb = $nbi\n"
         if {$nbi>1} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner un seul FLAT\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::sflat_img_list $img_list
         }
         
         # Chargement de la liste IMG
         set img_list [::bddimages_imgcorrection::select_img_list_by_type IMG RAW $selection_list]
         set nbi [llength $img_list]
         set texte "${texte}- Images d entree : nb = $nbi\n"
         if {$nbi==0} {
            set ::bddimages_imgcorrection::erreur_selection 1
            set texte "${texte}\n\nVeuillez selectionner des Images\n"
         }  else {
            foreach img $img_list {
               set texte "${texte}[::bddimages_imgcorrection::img_to_filename $img short]\n"
            }
            set ::bddimages_imgcorrection::deflat_img_list $img_list
         }

      }



      
      if {$::bddimages_imgcorrection::erreur_selection==0} {

         # concatenation des listes
         
         
         if {[catch {::bddimages_imgcorrection::verif_all_img} msg]}  {
            ::console::affiche_erreur "ERROR $errmsg: $msg\n"
            return
            }
         if {[catch {::bddimages_imgcorrection::verif_filter_img} msg]}  {
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

      # Frame qui va contenir le label "Type your password:" et une entrée pour le rentrer
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
   
   
   



}

