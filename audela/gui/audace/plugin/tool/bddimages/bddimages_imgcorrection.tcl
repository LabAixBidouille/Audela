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

namespace eval bddimages_imgcorrection {

   global audace
   global bddconf

    variable type imgtmplist inforesult 







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







   proc ::bddimages_imgcorrection::verif_info_img { imgtmplist } {

      set telsav ""
      set bin1sav ""
      set bin2sav ""
      set cpt 0

      foreach img $imgtmplist {
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







   proc ::bddimages_imgcorrection::create_filename { incname imgtmplist } {

      set tel ""
      set bin1 ""
      set bin2 ""
      set commundatejjmoy 0
      set cpt 0
      foreach img $imgtmplist {
         foreach l $img {
            set key [lindex $l 0]
            set val [lindex $l 1]
            if {$key=="telescop"} {set tel $val}
            if {$key=="bin1"} {set bin1 $val}
            if {$key=="bin2"} {set bin2 $val}
            if {$key=="commundatejj"} {set commundatejjmoy [expr $commundatejjmoy + $val]}
         }
      incr cpt
      }
      set commundatejjmoy  [expr $commundatejjmoy / $cpt]
      set dateobs          [ mc_date2iso8601 $commundatejjmoy ]
      set ms               [string range $dateobs end-2 end]
      set commundatejjmoy  [string range $dateobs 0 end-4]

      set commundatejjmoy [clock format [clock scan $commundatejjmoy] -format %Y%m%d.%H%M%S]
 
      set filename "$tel.$commundatejjmoy.$ms.bin${bin1}x${bin2}.$incname"

      return [list $filename $dateobs $bin1 $bin2]
   }





proc create_image { k type fileout dateobs} {

  global bddconf


      set bufno 1
      if {$type=="dark"} {
         buf$bufno load "$bddconf(dirtmp)/${type}0.fit"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k .fit $bddconf(dirtmp) $fileout . .fit KS kappa=3"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  .fit $bddconf(dirtmp) $fileout . .fit STAT"
      }
      if {$type=="flat"} {
         buf$bufno load "$bddconf(dirtmp)/${type}0.fit"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) flat       0  $k .fit $bddconf(dirtmp) $fileout . .fit KS kappa=3"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  .fit $bddconf(dirtmp) $fileout . .fit STAT"
      }
      
      buf$bufno load "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno setkwd [list "HIERARCH BDDIMAGES STATES" "CORR" "string" "RAW | CORR | CATA | Unknown" ""]
      buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
      buf$bufno save "$bddconf(dirtmp)/$fileout.fit"
      buf$bufno clear

      insertion_solo $bddconf(dirtmp)/$fileout.fit

      for {set i 0} {$i<=$k} {incr i} {
  #       file delete $bddconf(dirtmp)/${type}${i}.fit
      }

  }
 










proc correction { type imgtmplist inforesult} {

  global bddconf

      set fileout [lindex $inforesult 0]
      set dateobs  [lindex $inforesult 1]
      set bin1  [lindex $inforesult 2]
      set bin2  [lindex $inforesult 3]

      set fichiers ""
      foreach img $imgtmplist {
         foreach lk $img {
            set key [lindex $lk 0]
            set val  [lindex $lk 1]
            if {$key=="filename"} {set filename $val}
            if {$key=="dirfilename"} {set dirfilename $val}
         }
         #::console::affiche_resultat "img: $bddconf(dirfits)/${dirfilename}/${filename}\n"
         lappend fichiers $bddconf(dirbase)/${dirfilename}/${filename}
      }

      set k 0

      foreach fichier $fichiers {
         set errnum [catch {file copy -force $fichier $bddconf(dirtmp)/${type}${k}.fit} msg]
         if {$errnum==0} {
            ::console::affiche_resultat "cp image : $fichier\n"
            incr k
         } else {
            ::console::affiche_erreur "Erreur sur : $fichier\n"
            ::console::affiche_erreur "errnum : $errnum\n"
            ::console::affiche_erreur "msg    : $msg\n"
         }
      }
      incr k -1


      set errnum [catch {create_image $k $type $fileout $dateobs} msg]
      if {$errnum!=0} {
         ::console::affiche_erreur "Erreur sur la creation de $fileout\n"
         ::console::affiche_erreur "errnum : $errnum\n"
         ::console::affiche_erreur "msg    : $msg\n"
      }




      return 0
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
      set ::bddimages_imgcorrection::imgtmplist [::bddimages_imgcorrection::get_info_img]
      set errmsg [::bddimages_imgcorrection::verif_info_img $::bddimages_imgcorrection::imgtmplist]
      if {$errmsg != ""}  {
         ::console::affiche_erreur "ERROR: $errmsg\n"
         return
         }
      set ::bddimages_imgcorrection::inforesult [::bddimages_imgcorrection::create_filename $::bddimages_imgcorrection::type $::bddimages_imgcorrection::imgtmplist]


      set texte "Creation d un $type : \n\n"
      set texte "${texte}- Images d entree\n"
     # set texte "${texte}imgtmplist = $::bddimages_imgcorrection::imgtmplist \n\n"
      set texte "${texte}- Image en sortie\n"
      set texte "${texte}inforesult=$::bddimages_imgcorrection::inforesult\n"
      
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
        button $framecurrent.buttons.ok -text Ok -command {::bddimages_imgcorrection::correction $::bddimages_imgcorrection::type $::bddimages_imgcorrection::imgtmplist $::bddimages_imgcorrection::inforesult; destroy $This}
        pack configure $framecurrent.buttons.ok -side right

      grab set $This
      tkwait window $This
}








}

