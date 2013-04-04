## \file bdi_gui_gestion_source.tcl
#  \brief     Gestion des sources dans les images
#  \details   Ce namespace reunit tous les outils concernant la gui 
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2008
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_gestion_source.tcl]
#  \endcode
#  \todo      finir les entetes doxyfile

#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_gui_gestion_source.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_gui_gestion_source.tcl
# Description    : Gestion des sources dans les images
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_gui_gestion_source.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bdi_gui_gestion_source
#
#--------------------------------------------------


## Declaration du namespace \c bdi_gui_gestion_source .
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Pour developpeur seulement
#  @todo      faire en sorte que la psf s appelle depuis la recherche 
namespace eval bdi_gui_gestion_source {


   variable gui_catalogues_data
   variable fen
   variable butcata
   variable gui_catalogues
   variable id_img
   variable dateimg
   variable visucrop
   variable bufcrop










   proc ::bdi_gui_gestion_source::psf { } {

   
      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         set getbox "no"
         if {$::bdi_tools_psf::psf_methode=="fitgauss"} {
            tk_messageBox -message "Veuillez selectionner un carr� dans l'image" -type ok
            return
         }
      } else {
         set getbox "yes"
         set ::bdi_tools_psf::psf_rect $rect
      }

      gren_info "Methode pour psf : $::bdi_tools_psf::psf_methode \n"
      gren_info "Source : $::gui_cata::psf_name_source  \n"
      gren_info "getbox : $getbox  \n"
       
      switch $::gui_cata::psf_name_source {
         "-" -
         "Unknown" {
            # source inconnue du cata ou nouvelle source
         }
         "Ambigue" {
            # Il y a plusieurs sources a mesurer on decide de ne rien faire
            tk_messageBox -message "Veuillez selectionner une seule source" -type ok
            return
         }
         default  {
            gren_info "id source : $::gui_cata::psf_id_source  \n"
            set s [lindex [lindex $::tools_cata::current_listsources 1] [expr $::gui_cata::psf_id_source - 1] ]
            ::bdi_tools_psf::get_psf_source s
         }
      }
      
      #::bdi_gui_gestion_source::affich_cata
       
      set lf [lindex $::tools_cata::current_listsources 0]
      set ls [lindex $::tools_cata::current_listsources 1]
      set i  [expr $::gui_cata::psf_id_source - 1]
      set ls [lreplace $ls $i $i $s]
      set ::tools_cata::current_listsources [list $lf $ls]
      
      ::bdi_gui_psf::init_current_psf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      
      ::bdi_gui_gestion_source::maj_catalogues

      set onglets $::bdi_gui_gestion_source::fen.appli.onglets
      $onglets.nb select $onglets.nb.f1
      
      
   }








   proc ::bdi_gui_gestion_source::maj_catalogues {  } {

      # recupere la liste des sources de l image courante
      set sources [lindex $::tools_cata::current_listsources 1]
      
      # Recupere la liste des id des sources du catalogue selectionne
      set idlist ""
      foreach line $::bdi_gui_gestion_source::gui_catalogues_data {
         lappend idlist [lindex $line 2]
      }
      set idlist [lsort -unique $idlist]
     
      
      # reconstruit pour chaque source la variable catalogue
      set ::bdi_gui_gestion_source::gui_catalogues_data ""
      foreach id $idlist {
         incr id -1
         set s [lindex $sources $id]
         set pos 0
         foreach cata $s {
            set ra0  [lindex [lindex $cata 1] 0]
            set dec0 [lindex [lindex $cata 1] 1]
            set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] [expr $id + 1] $x $y ]
            incr pos
         }
      }

      $::bdi_gui_gestion_source::gui_catalogues.tbl delete 0 end
      foreach line $::bdi_gui_gestion_source::gui_catalogues_data {
         $::bdi_gui_gestion_source::gui_catalogues.tbl insert end $line
      }
      
      
      # Effacement des boutons des catalogues
      if {[info exists ::gui_cata::nb_butcata]} {
         for { set i 0 } { $i <= 10} {incr i} {
            set ex [winfo exists $::bdi_gui_gestion_source::fen.appli.info_cata.c$i]
            if {$ex == 0} {break}
            destroy $::bdi_gui_gestion_source::fen.appli.info_cata.c$i
         } 
      } 

      # Affichage des boutons des catalogues si il n y a qu une seule source concernee
      if {[llength $idlist]==1} {
         array unset ::bdi_gui_gestion_source::butcata
         set i 0
         foreach mycata $s {
            set a [lindex $mycata 0]
            button $::bdi_gui_gestion_source::fen.appli.info_cata.c$i  -state normal \
               -text $a -relief "sunken" -command "::bdi_gui_gestion_source::butcata_action $i"
            pack   $::bdi_gui_gestion_source::fen.appli.info_cata.c$i -in $::bdi_gui_gestion_source::fen.appli.info_cata -side left -padx 0
            set ::bdi_gui_gestion_source::butcata($i,cata) $a
            set ::bdi_gui_gestion_source::butcata($i,state) "Ok"
            incr i
         }
         set ::gui_cata::nb_butcata $i
      }

   }







   proc ::bdi_gui_gestion_source::grab_sources_getsource { ids s } {

      set color red
      set width 2
      cleanmark

      set ::bdi_gui_gestion_source::gui_catalogues_data ""

      # Nom de la source
      set namable [::manage_source::namable $s]
      if {$namable==""} {
         set name ""
      } else {
         set name [::manage_source::naming $s $namable]
      } 

      # source trouv�e
      gren_info "SOURCE FOUND : ID = $ids NAME = $name CATAS = "
      set pos 0
      foreach cata $s {
         gren_info "[lindex $cata 0] "
         set ra0  [lindex [lindex $cata 1] 0]
         set dec0 [lindex [lindex $cata 1] 1]
         set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
         set x [lindex $xy 0]
         set y [lindex $xy 1]
         lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] $ids $x $y ]
         incr pos
      }
      gren_info "\n"

      return [list 0 "" $ids $x $y $s]

   }














   proc ::bdi_gui_gestion_source::grab_sources_getbox {  } {
 
      set color red
      set width 2
      cleanmark

      set ambigue "no"

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }
      set ::bdi_gui_gestion_source::gui_catalogues_data ""

      set sources [lindex $::tools_cata::current_listsources 1]

      set id 1
      set cpt_grab 0
      foreach s $sources {

         foreach cata $s {
            
            set namable [::manage_source::namable $s]
            if {$namable==""} {
               set name ""
            } else {
               set name [::manage_source::naming $s $namable]
            } 

            set pass "no"
            
            set ra  [lindex [lindex $cata 1] 0]
            set dec [lindex [lindex $cata 1] 1]
            
            if {$ra!="" && $dec!="" && $ra!="-" && $dec!="-"  } {
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  set pass "yes"
                  set xpass $x
                  set ypass $y
               }
            }

            if {$pass=="yes"} {

               #gren_info "**NAME = $name \n"
               incr cpt_grab
               if {$cpt_grab>1} { set ambigue "yes"}

               #gren_info "NAME = $name \n"
               #gren_info "xpass ypass  = $xpass $ypass\n"
               #gren_info "rect = $rect\n"
               affich_un_rond_xy $xpass $ypass green 60 1

               # gren_info "cpt_grab = $cpt_grab\n"

               gren_info "SOURCE FOUND : ID = $id NAME = $name CATAS = "
               set pos 0
               foreach cata $s {
                  gren_info "[lindex $cata 0] "
                  set ra0  [lindex [lindex $cata 1] 0]
                  set dec0 [lindex [lindex $cata 1] 1]
                  if {$ra0!="" && $dec0!="" && $ra0!="-" && $dec0!="-"  } {
                     set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
                     set x [lindex $xy 0]
                     set y [lindex $xy 1]
                     lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] $id $x $y ]
                  }
                  incr pos
               }
               gren_info "\n"

               if {$ambigue == "yes" } {
                  set result [list 1 "Ambigue" $id $xpass $ypass $s]
               } else {
                  set result [list 0 "" $id $xpass $ypass $s]
               }
               break
            }
         }
         incr id
      }
      if {$cpt_grab==0} { return [list 1 "Unknown"] }
      return $result
   }
 
 
 
 

# Anciennement ::gui_cata::psf_grab
# Grab des sources dans l image
# appele depuis l analyse des psf en mode manuel


   proc ::bdi_gui_gestion_source::gestion_mode_manuel_grab { {ids ""} } {

      $::bdi_gui_gestion_source::fen.appli.actions1.save configure -state normal
      $::bdi_gui_gestion_source::fen.appli.actions1.new  configure -state disabled
      set ::gui_cata::nb_butcata 0

      set ::gui_cata::psf_id_source ""
      set ::gui_cata::list_of_cata ""
      
      if { $ids == "" } {
         set r [::bdi_gui_gestion_source::grab_sources_getbox]
      } else {
         set r [::bdi_gui_gestion_source::grab_sources_getsource $ids [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ] ]
      }

      #gren_info "r=$r\n"

      set err   [lindex $r 0]
      set aff   [lindex $r 1]
      set id    [lindex $r 2]
      set xpass [lindex $r 3]
      set ypass [lindex $r 4]
      set s     [lindex $r 5]

      set ::gui_cata::psf_best_sol [list $xpass $ypass]

      if {$err!=0} {
         set ::gui_cata::psf_name_source "Erreur"
         if { $aff=="Unknown" || $aff=="Ambigue" } {
            set ::gui_cata::psf_name_source $aff
            if {[info exists ::gui_cata::psf_best_sol]} { unset ::gui_cata::psf_best_sol }
         }
         if { $aff=="Ambigue" } {
            set ::gui_cata::psf_name_source $aff
            if {[info exists ::gui_cata::psf_best_sol]} { unset ::gui_cata::psf_best_sol }
         }
      } else {
       
       
         ::psf_tools::result_photom_methode "err" 
         ::psf_tools::result_fitgauss "err" 

         set d [::manage_source::namable $s]
         if {$d==""} {
            gren_info "s=$s\n"
            set ::gui_cata::psf_name_source "Unnamable"
            return
         }
         set ::gui_cata::psf_source $s
         set ::gui_cata::psf_name_source [::manage_source::naming $s $d]
         set ::gui_cata::psf_name_cata $d
         set ::gui_cata::psf_id_source $id
      }


      # Effacement des boutons des catalogues
      if {[info exists ::gui_cata::nb_butcata]} {
         for { set i 0 } { $i <= 10} {incr i} {
            set ex [winfo exists $::bdi_gui_gestion_source::fen.appli.info_cata.c$i]
            if {$ex == 0} {break}
            destroy $::bdi_gui_gestion_source::fen.appli.info_cata.c$i
         } 
      } 


      # Affichage des boutons des catalogues
      if { $aff!="Ambigue" } {
         # bouton et list des cata des sources grab�es
         array unset ::bdi_gui_gestion_source::butcata
         set i 0
         foreach mycata $s {
            set a [lindex $mycata 0]
            button $::bdi_gui_gestion_source::fen.appli.info_cata.c$i  -state normal \
               -text $a -relief "sunken" -command "::bdi_gui_gestion_source::butcata_action $i"
            pack   $::bdi_gui_gestion_source::fen.appli.info_cata.c$i -in $::bdi_gui_gestion_source::fen.appli.info_cata -side left -padx 0
            set ::bdi_gui_gestion_source::butcata($i,cata) $a
            set ::bdi_gui_gestion_source::butcata($i,state) "Ok"
            incr i
         }
         set ::gui_cata::nb_butcata $i

      } 


      # affichage des infos dans la GUI
      ::bdi_gui_gestion_source::affich_cata

       
      # Selection dans la liste des sources
      ::bdi_gui_gestion_source::selectall $::bdi_gui_gestion_source::gui_catalogues.tbl


      # onglets direct en cas d ambiguit�
      if { $aff=="Ambigue" } {
         set onglets $::bdi_gui_gestion_source::fen.appli.onglets
         $onglets.nb select $onglets.nb.f6
      }

   }


















   proc ::bdi_gui_gestion_source::affich_cata { } {

      global bddconf

      set bufno $::bddconf(bufno)
      cleanmark
      
      
      for { set i 0 } { $i < $::gui_cata::nb_butcata} {incr i} {

         
         if { $::bdi_gui_gestion_source::butcata($i,state) == "Ok" } {
            set pos [lsearch -index 0 $::gui_cata::psf_source $::bdi_gui_gestion_source::butcata($i,cata)]
            if {$pos != -1} {
               set ra  [lindex $::gui_cata::psf_source [list $pos 1 0] ]
               set dec [lindex $::gui_cata::psf_source [list $pos 1 1] ]
            }
            set width [expr 20 + $i * 10]

            if {$ra!="" && $dec!="" && $ra!="-" && $dec!="-"  } {
               # Affiche un rond vert
               set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
               set x [lindex $img_xy 0]
               set y [lindex $img_xy 1]
               affich_un_rond_xy $x $y green  $width 1
            }
         }
      }
      
      $::bdi_gui_gestion_source::gui_catalogues.tbl delete 0 end
      foreach line $::bdi_gui_gestion_source::gui_catalogues_data {
         $::bdi_gui_gestion_source::gui_catalogues.tbl insert end $line
      }


   }





   proc ::bdi_gui_gestion_source::butcata_action { i } {

      if { $::bdi_gui_gestion_source::butcata($i,state) == "Ok" } {
         set ::bdi_gui_gestion_source::butcata($i,state) ""
         $::bdi_gui_gestion_source::fen.appli.info_cata.c$i configure -relief "raised"
      } else {
         set ::bdi_gui_gestion_source::butcata($i,state) "Ok"
         $::bdi_gui_gestion_source::fen.appli.info_cata.c$i configure -relief "sunken"
      }
      
      ::bdi_gui_gestion_source::affich_cata

   }








   proc ::bdi_gui_gestion_source::init { } {

      ::bdi_gui_psf::inittoconf

      if {[info exists ::gui_cata::current_psf]} {unset ::gui_cata::current_psf}
      foreach key [list xsm ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta] {
         set ::gui_cata::current_psf($key) "-"
      }

   }





#------------------------------------------------------------
## Analyse de photocentre d'une source
# Permet la recombinaison des catalogue pour une source.
# fonction appelee par l'outil recherche
#  \sa bdi_gui_gestion_source::run
   proc ::bdi_gui_gestion_source::charge_list { img_list } {
      
      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
      
      set ::tools_cata::id_current_image 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         incr ::tools_cata::id_current_image
         ::gui_cata::load_cata
         set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      }

      set ::tools_cata::id_current_image 0
      set ::bdi_gui_gestion_source::id_img 1
      set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]
      ::gui_cata::affiche_current_image
      
      set ::gui_cata::psf_name_source "-"
      set ::gui_cata::list_of_cata "-"

      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set ::bdi_gui_gestion_source::dateimg [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]

   }










#------------------------------------------------------------
## Analyse de photocentre d'une source
# Permet la recombinaison des catalogue pour une source.
# fonction appelee par l'outil recherche
#  \sa bdi_gui_gestion_source::run
   proc ::bdi_gui_gestion_source::run_recherche { img_list } {
      set ::gui_cata::use_uncosmic 0
      ::bdi_gui_gestion_source::charge_list $img_list
      ::bdi_gui_gestion_source::run
   }















   proc ::bdi_gui_gestion_source::getpos { s cata x y } {

      set p -1
      
      set p [lsearch -index 0 $s $cata]
      if {$p!=-1} {
         set mycata [lindex $s $p]
         set ra  [lindex $mycata {1 0}]
         set dec [lindex $mycata {1 1}]
         set img_xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
         set xc [lindex $img_xy 0]
         set yc [lindex $img_xy 1]
         #gren_info " $xc $x\n"
         #gren_info " $yc $y\n"
         #gren_info "a [expr abs($xc - $x)]\n"
         #gren_info "b [expr abs($yc - $y)]\n"
         if { [expr abs($xc - $x)] < 0.001 && [expr abs($yc - $y)] < 0.001} { 
            return $p
         }
      }
      return $p
   }

   proc ::bdi_gui_gestion_source::console { tbl } {

      set l ""
      foreach select [$tbl curselection] {
         set pos  [lindex [$tbl get $select] 0]      
         set cata [lindex [$tbl get $select] 1]      
         set ids  [lindex [$tbl get $select] 2]   
         set x    [lindex [$tbl get $select] 3]   
         set y    [lindex [$tbl get $select] 4]   
         lappend l [list $pos $cata $ids $x $y]
      }
      set l [lsort -decreasing -integer -index 2 $l]
      foreach c $l {
         set pos  [lindex $c 0]      
         set cata [lindex $c 1]      
         set ids  [lindex $c 2]   
         set x    [lindex $c 3]   
         set y    [lindex $c 4]   
         #gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
         gren_info [format "%-7s %5s %5s %.3f %.3f\n" $cata $ids $pos $x $y] 
      }
  }











   proc ::bdi_gui_gestion_source::select { tbl } {

      set l ""
      set idsel ""
      foreach select [$tbl curselection] {
         set pos  [lindex [$tbl get $select] 0]      
         set cata [lindex [$tbl get $select] 1]      
         set ids  [lindex [$tbl get $select] 2]   
         set x    [lindex [$tbl get $select] 3]   
         set y    [lindex [$tbl get $select] 4]   
         lappend l [list $pos $cata $ids $x $y]
         if {$idsel == ""} { set idsel $ids}
         if {$idsel != $ids} {
            tk_messageBox -message "Veuillez selectionner une seule source" -type ok
            return
         }
      }
      gren_info "Source selectionnee : $idsel\n"
      
      set l [lsort -decreasing -integer -index 2 $l]
      foreach c $l {
         set pos  [lindex $c 0]      
         set cata [lindex $c 1]      
         set ids  [lindex $c 2]   
         set x    [lindex $c 3]   
         set y    [lindex $c 4]   
         #gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
         gren_info [format "%-7s %5s %5s %.3f %.3f\n" $cata $ids $pos $x $y] 
      }

      ::bdi_gui_gestion_source::gestion_mode_manuel_grab $idsel
  }
  
  
  
  
  

   proc ::bdi_gui_gestion_source::aff_catas { s } {

      set line "AFF_CATAS ="
      foreach c $s {
         append line " [lindex $c 0]"
      }
      return $line
  }



   proc ::bdi_gui_gestion_source::mode_manuel_save { } {

       global bddconf
       
       gren_info "Maj id = $::tools_cata::id_current_image \n"

       set current_image [ lindex  $::tools_cata::img_list $::tools_cata::id_current_image  ]
       # @todo sauver ::tools_cata::current_listsources
       gren_info "img_list = [llength $::tools_cata::img_list] \n"
       gren_info "current_image = $current_image \n"

       # Tabkey
       set tabkey [::bddimages_liste::lget $current_image "tabkey"]
       # Liste des sources
       incr id_current_image
       # Noms du fichier cata
       set imgfilename    [::bddimages_liste::lget $current_image filename]
       set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
       set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
       set cataxml "${f}_cata.xml"

       ::tools_cata::save_cata $::tools_cata::current_listsources $tabkey $cataxml

   }









   proc ::bdi_gui_gestion_source::newsource { tbl } {

# ouvrir bouton save
      $::bdi_gui_gestion_source::fen.appli.actions1.save configure -state normal

      set l ""
      foreach select [$tbl curselection] {
         set pos  [lindex [$tbl get $select] 0]      
         set cata [lindex [$tbl get $select] 1]      
         set ids  [lindex [$tbl get $select] 2]   
         set x    [lindex [$tbl get $select] 3]   
         set y    [lindex [$tbl get $select] 4]   
         gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
         lappend l [list $pos $cata $ids $x $y]
      }
      set l [lsort -decreasing -integer -index 2 $l]


      set fields  [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]

      set newsource ""
      foreach c $l {
         set pos  [lindex $c 0]      
         set cata [lindex $c 1]      
         set ids  [lindex $c 2]   
         set x    [lindex $c 3]   
         set y    [lindex $c 4]   

         gren_info "catat = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
         incr ids -1
         set s [lindex $sources $ids]
         set pos [::bdi_gui_gestion_source::getpos $s $cata $x $y]
         if {$pos==-1} {
            gren_erreur "pos = $pos\n"
         }


         gren_info "s $ids : [::bdi_gui_gestion_source::aff_catas $s]\n"
         gren_info "pos $ids : $pos\n"
         gren_info "ns $ids : [lindex $s [list $pos 0]]\n"

         
         lappend newsource [lindex $s $pos]
         set s [lreplace $s $pos $pos]
         if {[llength $s ]==0} {
            set sources [lreplace $sources $ids $ids]
            gren_info "old s $ids : SUPPRIMEE\n"
         } else {
            set sources [lreplace $sources $ids $ids $s]
            gren_info "old s $ids : [::bdi_gui_gestion_source::aff_catas $s]\n"
            set s [lindex $sources $ids]
            
         }
      }

      gren_info "New source : [::bdi_gui_gestion_source::aff_catas $newsource]\n"
      
      lappend sources $newsource

      set s [lindex $sources $ids]

      set ::tools_cata::current_listsources [list $fields $sources]
      
      ::bdi_gui_gestion_source::gestion_mode_manuel_grab

   }










   proc ::bdi_gui_gestion_source::get_id_from_gui_catalogues_data { c } {

      set cpt -1
      foreach x $::bdi_gui_gestion_source::gui_catalogues_data {
         incr cpt
         if {[lindex $x 0] != [lindex $c 0] } {continue}
         if {[lindex $x 1] != [lindex $c 1] } {continue}
         if {[lindex $x 2] != [lindex $c 2] } {continue}
         if {[lindex $x 3] != [lindex $c 3] } {continue}
         if {[lindex $x 4] != [lindex $c 4] } {continue}
         return $cpt
      }
      return -1
   }
   
   
   
   
   
   
   proc ::bdi_gui_gestion_source::deletesource { tbl } {

      set l ""
      foreach select [$tbl curselection] {
         set pos  [lindex [$tbl get $select] 0]      
         set cata [lindex [$tbl get $select] 1]      
         set ids  [lindex [$tbl get $select] 2]   
         set x    [lindex [$tbl get $select] 3]   
         set y    [lindex [$tbl get $select] 4]   
         lappend l [list $pos $cata $ids $x $y]
      }

      set l [lsort -decreasing -integer -index 2 $l]
      foreach c $l {
         set pos  [lindex $c 0]      
         set cata [lindex $c 1]      
         set ids  [lindex $c 2]   
         set x    [lindex $c 3]   
         set y    [lindex $c 4]   
         gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"

         set id [expr $ids - 1]
         set ls [lindex $::tools_cata::current_listsources 1]
         set s  [lindex $ls $id]

         ::bdi_tools_psf::delete_cata_from_source s $cata
         set ls [lreplace $ls $id $id $s]
         set ::tools_cata::current_listsources [lreplace $::tools_cata::current_listsources 1 1 $ls]
         
         set posc [::bdi_gui_gestion_source::get_id_from_gui_catalogues_data $c]
         if {$posc == -1} {
            gren_erreur "$c n est pas dans la liste des catalogues"
            return
         } else {
            set ::bdi_gui_gestion_source::gui_catalogues_data [lreplace $::bdi_gui_gestion_source::gui_catalogues_data $posc $posc]
         }

      }

      ::bdi_gui_gestion_source::affich_cata

      

   }









   proc ::bdi_gui_gestion_source::selectall { tbl  } {
      $tbl selection set 0 end
      set nb [llength [$tbl curselection] ]
      gren_info "Nb selected : $nb\n"
      set i 0
      foreach select [$tbl curselection] {
         set pos  [lindex [$tbl get $select] 0]      
         set cata [lindex [$tbl get $select] 1]      
         set ids  [lindex [$tbl get $select] 2]   
         set x    [lindex [$tbl get $select] 3]   
         set y    [lindex [$tbl get $select] 4]   
         
         set width [expr 20 + $i * 10]
         affich_un_rond_xy $x $y green  $width 1
         #gren_info "cata = $cata ; ids = $ids \n"   
         incr i
      }
   }

   proc ::bdi_gui_gestion_source::cmdButton1Click { tbl  args } {

      cleanmark
      set nb [llength [$tbl curselection] ]
      gren_info "Nb selected : $nb\n"
      set i 0
      foreach select [$tbl curselection] {
         set pos  [lindex [$tbl get $select] 0]      
         set cata [lindex [$tbl get $select] 1]      
         set ids  [lindex [$tbl get $select] 2]   
         set x    [lindex [$tbl get $select] 3]   
         set y    [lindex [$tbl get $select] 4]   
         
         set width [expr 20 + $i * 10]
         affich_un_rond_xy $x $y green  $width 1
         #gren_info "cata = $cata ; ids = $ids \n"   
         incr i
      }

 
   }

   proc ::bdi_gui_gestion_source::create_Tbl_sources { frmtable name_of_columns} {

      variable This
      global audace
      global caption
      global bddconf

      #--- Quelques raccourcis utiles
      set tbl $frmtable.tbl
      set popupTbl $frmtable.popupTbl

      #--- Table des objets
      tablelist::tablelist $tbl \
         -columns $name_of_columns \
         -labelcommand tablelist::sortByColumn \
         -selectmode extended \
         -activestyle none \
         -stripebackground #e0e8f0 \
         -showseparators 1


      #--- Gestion des popup

      #--- Menu pop-up associe a la table
      menu $popupTbl -title "Selection"

        # Edite la liste selectionnee
        $popupTbl add command -label "Console" -command "::bdi_gui_gestion_source::console $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Select" -command "::bdi_gui_gestion_source::select $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Nouvelle source" -command "::bdi_gui_gestion_source::newsource $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Supprimer" -command "::bdi_gui_gestion_source::deletesource $tbl"


      #--- Gestion des evenements
      bind [$tbl bodypath] <Control-Key-a> [ list ::bdi_gui_gestion_source::selectall $tbl ]
      bind $tbl <<ListboxSelect>>          [ list ::bdi_gui_gestion_source::cmdButton1Click %W ]
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

      pack  $tbl -in  $frmtable -expand yes -fill both
      
   }




#------------------------------------------------------------
## Analyse de photocentre d'une source
# Permet de recombiner des catalogues pour une source,
# de mesurer la psf d'une source, de rappeler les 
# conesearch dans une zone de l'image
#  \sa bdi_gui_gestion_source::gestion_mode_manuel_init
   proc ::bdi_gui_gestion_source::run {  } {

      ::psf_tools::inittoconf
      ::bdi_gui_gestion_source::init

      set spinlist ""
      for {set i 1} {$i<$::bdi_tools_psf::psf_limitradius} {incr i} {lappend spinlist $i}
      set ::bdi_gui_gestion_source::visucrop ""
      set ::bdi_gui_gestion_source::bufcrop  ""
      
      
      set spinlist ""
      for {set i 1} {$i<$::bdi_tools_psf::psf_limitradius} {incr i} {lappend spinlist $i}

      set ::bdi_gui_gestion_source::fen .psf
      if { [winfo exists $::bdi_gui_gestion_source::fen] } {
         wm withdraw $::bdi_gui_gestion_source::fen
         wm deiconify $::bdi_gui_gestion_source::fen
         focus $::bdi_gui_gestion_source::fen
         return
      }
      toplevel $::bdi_gui_gestion_source::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bdi_gui_gestion_source::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bdi_gui_gestion_source::fen ] "+" ] 2 ]
      wm geometry $::bdi_gui_gestion_source::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bdi_gui_gestion_source::fen 1 1
      wm title $::bdi_gui_gestion_source::fen "PSF"
      wm protocol $::bdi_gui_gestion_source::fen WM_DELETE_WINDOW "destroy $::bdi_gui_gestion_source::fen"

      set frm $::bdi_gui_gestion_source::fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_gestion_source::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5


         set info_source  [frame $frm.info_source -borderwidth 0 -cursor arrow -relief groove]
         pack $info_source -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $info_source.lab1 -text "Source : " 
             pack  $info_source.lab1 -side left -padx 2 -pady 0
             
             label $info_source.labv -textvariable ::gui_cata::psf_name_source 
             pack  $info_source.labv -side left -padx 2 -pady 0

         set info_cata  [frame $frm.info_cata -borderwidth 0 -cursor arrow -relief groove]
         pack $info_cata -in $frm -anchor s -side top -expand 1 -fill x -padx 10 -pady 5


         set info_img  [frame $frm.info_img -borderwidth 0 -cursor arrow -relief groove]
         pack $info_img -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

             label $info_img.title -text "Image : "
             pack  $info_img.title -side left -padx 2 -pady 0
             label $info_img.id -textvariable ::bdi_gui_gestion_source::id_img
             pack  $info_img.id -side left -padx 2 -pady 0
             label $info_img.lab -text "/"
             pack  $info_img.lab -side left -padx 2 -pady 0
             label $info_img.lab2 -text $::tools_cata::nb_img_list
             pack  $info_img.lab2 -side left -padx 2 -pady 0

         set info_date [frame $frm.info_date -borderwidth 0 -cursor arrow ]
         pack $info_date -in $frm -anchor c -side top -expand 1 

             label $info_date.id -textvariable ::bdi_gui_gestion_source::dateimg
             pack  $info_date.id -side left -padx 2 -pady 0

         set actions [frame $frm.actions1 -borderwidth 1 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor c -side top -expand 1 

                 button $actions.grab -state active -text "Grab" -relief "raised" \
                  -command "::bdi_gui_gestion_source::gestion_mode_manuel_grab"
                 pack   $actions.grab -side left -padx 0

                 button $actions.crop -state active -text "Crop" -relief "raised" \
                  -command ""
                 pack   $actions.crop -side left -padx 0

                 button $actions.new -state disabled -text "New" -relief "raised" \
                  -command "::bdi_gui_gestion_source::gestion_mode_manuel_new"
                 pack   $actions.new -side left -padx 0

                 button $actions.save -state normal -text "Save" -relief "raised" \
                  -command "::bdi_gui_gestion_source::mode_manuel_save"
                 pack   $actions.save -side left -padx 0
 
         set actions [frame $frm.actions2 -borderwidth 1 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor c -side top -expand 1 

                 button $actions.prev -state disabled -text "Prev" -relief "raised" \
                  -command "::bdi_gui_gestion_source::prev_img"
                 pack   $actions.prev -side left -padx 0

                 button $actions.next -state active -text "Next" -relief "raised" \
                  -command "::bdi_gui_gestion_source::next_img"
                 pack   $actions.next -side left -padx 0

                 button $actions.nextauto -state active -text "Next & Auto" -relief "raised" \
                  -command "::bdi_gui_gestion_source::nextauto_img"
                 pack   $actions.nextauto -side left -padx 0

                 button $actions.savenextauto -state active -text "Save & Next & Auto" -relief "raised" \
                  -command "::bdi_gui_gestion_source::savenextauto_img"
                 pack   $actions.savenextauto -side left -padx 0
 
         set actions [frame $frm.actions3 -borderwidth 1 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor c -side top

             label $actions.lab1 -text "Methode pour PSF : " 
             ComboBox $actions.combo \
                -width 50 -height [llength [::bdi_tools_psf::get_methodes]] \
                -relief sunken -borderwidth 1 -editable 0 -width 10\
                -textvariable ::bdi_tools_psf::psf_methode \
                -values [::bdi_tools_psf::get_methodes]

             button $actions.psfc -state active -text "PSF" -relief "raised" \
                  -command "::bdi_gui_gestion_source::psf"
 
             grid $actions.lab1 $actions.combo $actions.psfc -sticky nsw -pady 3

         set actions [frame $frm.actions4 -borderwidth 1 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor c -side top

             button $actions.clean -state active -text "Clean" -relief "raised" \
                  -command "cleanmark"
                   
             grid $actions.clean -sticky nsw -pady 3


         # onglets : mesures, methode, rafale, conesearch, identification, cata

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
         pack [ttk::notebook $onglets.nb] -expand yes -fill both 
         set f1 [frame $onglets.nb.f1]
         set f2 [frame $onglets.nb.f2]
         set f3 [frame $onglets.nb.f3]
         set f4 [frame $onglets.nb.f4]
         set f5 [frame $onglets.nb.f5]
         set f6 [frame $onglets.nb.f6]

         $onglets.nb add $f1 -text "Mesures"
         $onglets.nb add $f2 -text "Methode"
         $onglets.nb add $f3 -text "Rafale"
         $onglets.nb add $f4 -text "Conesearch"
         $onglets.nb add $f5 -text "Identification"
         $onglets.nb add $f6 -text "Catalogues"

        $onglets.nb select $f1
        ttk::notebook::enableTraversal $onglets.nb


         # onglets : mesures
         set nbp [llength [::bdi_tools_psf::get_fields_current_psf] ]
         set cptmed [expr int($nbp/2)]


         set results [frame $f1.results -borderwidth 0 -cursor arrow -relief groove]
         pack $results -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set block [frame $results.params -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $results -anchor n -side top -expand 0 -fill x -padx 10 -pady 5

                  set values [ frame $block.valuesleft -borderwidth 0 -cursor arrow -relief groove ]
                  pack $values -in $block -anchor n -side left -expand 1 -fill both -padx 10 -pady 2
                          
                         set cpt 0
                         foreach key [::bdi_tools_psf::get_fields_current_psf]  {
                              incr cpt
                              if {$cpt > $cptmed } {break}
                              set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                              pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 2 -pady 0

                                   if {$key=="err_xsm"||$key=="err_ysm"} {
                                      set active disabled
                                   } else {
                                      set active active
                                   }
                                   button $value.graph -state $active -text "$key" -relief "raised" -width 8 -height 1\
                                      -command "::bdi_gui_gestion_source::graph $key" 
                                   label $value.lab1 -text " = " 
                                   label $value.lab2 -textvariable ::gui_cata::current_psf($key)
                                   grid $value.graph $value.lab1 $value.lab2 -sticky nsw -pady 3
                         }

                  set values [ frame $block.valuesright -borderwidth 0 -cursor arrow -relief groove ]
                  pack $values -in $block -anchor n -side right -expand 1 -fill both -padx 10 -pady 2

                         set cpt 0
                         foreach key [::bdi_tools_psf::get_fields_current_psf] {
                              incr cpt
                              if {$cpt <= $cptmed } {continue}

                              set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                              pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 2 -pady 0

                                   if {$key=="errflux"||$key=="delta"} {
                                      set active disabled
                                   } else {
                                      set active active
                                   }
                                   button $value.graph -state $active -text "$key" -relief "raised" -width 8 -height 1\
                                      -command "::bdi_gui_gestion_source::graph $key" 
                                   label $value.lab1 -text " = " 
                                   label $value.lab2 -textvariable ::gui_cata::current_psf($key)
                                   grid $value.graph $value.lab1 $value.lab2 -sticky nsw -pady 3
                         }

              set actions [frame $results.actions -borderwidth 0 -cursor arrow -relief groove]
              pack $actions -in $results -anchor c -side top 

                   button $actions.takall -state active -text "Select All Radius" -relief "raised" \
                        -command "::bdi_gui_gestion_source::takall"
                   button $actions.crop -state active -text "Crop" -relief "raised" \
                        -command "::bdi_gui_gestion_source::setval"
                   grid $actions.takall $actions.crop -sticky nsw -pady 3
                   
         # onglets : methodes

         set methodes [frame $f2.methodes -borderwidth 0 -cursor arrow -relief groove]
         pack $methodes -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
              
              # configuration par onglets
              set block [frame $methodes.conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $methodes -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

                   set meth_onglets [frame $block.meth_onglets -borderwidth 0 -cursor arrow -relief groove]
                   pack $meth_onglets -in $block -side top -expand yes -fill both -padx 10 -pady 5

                   pack [ttk::notebook $meth_onglets.nb] -expand yes -fill both 
                   set i 0
                   foreach m [::bdi_tools_psf::get_methodes] {
                      incr i
                      set a [frame $meth_onglets.nb.g$i]
                      set g$i $a
                      $meth_onglets.nb add $a -text $m
                   }

              $meth_onglets.nb select $g1
              ttk::notebook::enableTraversal $meth_onglets.nb


              # configuration fitgauss
              set block [frame $g1.conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $g1 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
              
                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3

              # configuration photombasic
              set block [frame $g2.conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $g2 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
              
                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Rayon : " 
                     spinbox $block.radiusc -values $spinlist -from 1 -to $::bdi_tools_psf::psf_limitradius -textvariable ::gui_cata::psf_radius -width 3 \
                         -command "::bdi_gui_gestion_source::one_psf_crop"
                     pack  $block.radiusc -side left 
                     $block.radiusc set 15
                   
                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radiusc  -sticky nsw -pady 3

              # configuration globale
              set block [frame $g3.conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $g3 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
              
                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Limite du Rayon : " 
                     entry $block.radv -textvariable ::bdi_tools_psf::psf_limitradius -relief sunken -width 5
                   
                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radv  -sticky nsw -pady 3

              # configuration aphot
              set block [frame $g4.conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $g4 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
              
                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Limite du Rayon : " 
                     entry $block.radv -textvariable ::bdi_tools_psf::psf_limitradius -relief sunken -width 5
                   
                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radv  -sticky nsw -pady 3

              # configuration bphot
              set block [frame $g5.conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $g5 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
              
                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Limite du Rayon : " 
                     entry $block.radv -textvariable ::bdi_tools_psf::psf_limitradius -relief sunken -width 5
                   
                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radv  -sticky nsw -pady 3


         # onglets : conesearch

         set cataconf [frame $f4.conesearch -borderwidth 0 -cursor arrow -relief groove]
         pack $cataconf -in $f4 -anchor c -side top -expand 0 -padx 10 -pady 5
 
               checkbutton $cataconf.skybot_check -highlightthickness 0 -text "  SKYBOT" -variable ::tools_cata::use_skybot
                  entry $cataconf.skybot_dir -relief flat -borderwidth 1 -textvariable ::tools_cata::catalog_skybot -width 30 -state disabled
               checkbutton $cataconf.usnoa2_check -highlightthickness 0 -text "  USNO-A2" -variable ::tools_cata::use_usnoa2 -state disabled
                  entry $cataconf.usnoa2_dir -relief flat -textvariable ::tools_cata::catalog_usnoa2 -width 30 -state disabled
               checkbutton $cataconf.tycho2_check -highlightthickness 0 -text "  TYCHO-2" -variable ::tools_cata::use_tycho2
                  entry $cataconf.tycho2_dir -relief flat -textvariable ::tools_cata::catalog_tycho2 -width 30 -state disabled
               checkbutton $cataconf.ucac2_check -highlightthickness 0 -text "  UCAC2" -variable ::tools_cata::use_ucac2
                  entry $cataconf.ucac2_dir -relief flat -textvariable ::tools_cata::catalog_ucac2 -width 30 -state disabled
               checkbutton $cataconf.ucac3_check -highlightthickness 0 -text "  UCAC3" -variable ::tools_cata::use_ucac3
                  entry $cataconf.ucac3_dir -relief flat -textvariable ::tools_cata::catalog_ucac3 -width 30 -state disabled
               checkbutton $cataconf.ucac4_check -highlightthickness 0 -text "  UCAC4" -variable ::tools_cata::use_ucac4
                  entry $cataconf.ucac4_dir -relief flat -textvariable ::tools_cata::catalog_ucac4 -width 30 -state disabled
               checkbutton $cataconf.ppmx_check -highlightthickness 0 -text "  PPMX" -variable ::tools_cata::use_ppmx
                  entry $cataconf.ppmx_dir -relief flat -textvariable ::tools_cata::catalog_ppmx -width 30 -state disabled
               checkbutton $cataconf.ppmxl_check -highlightthickness 0 -text "  PPMXL" -variable ::tools_cata::use_ppmxl
                  entry $cataconf.ppmxl_dir -relief flat -textvariable ::tools_cata::catalog_ppmxl -width 30 -state disabled
               checkbutton $cataconf.nomad1_check -highlightthickness 0 -text "  NOMAD1" -variable ::tools_cata::use_nomad1
                  entry $cataconf.nomad1_dir -relief flat -textvariable ::tools_cata::catalog_nomad1 -width 30 -state disabled
               checkbutton $cataconf.twomass_check -highlightthickness 0 -text "  2MASS" -variable ::tools_cata::use_2mass
                  entry $cataconf.twomass_dir -relief flat -textvariable ::tools_cata::catalog_2mass -width 30 -state disabled
               frame $cataconf.blank -height 15

            grid $cataconf.skybot_check  $cataconf.skybot_dir  -sticky nsw -pady 3
            grid $cataconf.blank
            grid $cataconf.usnoa2_check  $cataconf.usnoa2_dir  -sticky nsw -pady 3
            grid $cataconf.tycho2_check  $cataconf.tycho2_dir  -sticky nsw -pady 3
            grid $cataconf.ucac2_check   $cataconf.ucac2_dir   -sticky nsw -pady 3
            grid $cataconf.ucac3_check   $cataconf.ucac3_dir   -sticky nsw -pady 3
            grid $cataconf.ucac4_check   $cataconf.ucac4_dir   -sticky nsw -pady 3
            grid $cataconf.ppmx_check    $cataconf.ppmx_dir    -sticky nsw -pady 3
            grid $cataconf.ppmxl_check   $cataconf.ppmxl_dir   -sticky nsw -pady 3
            grid $cataconf.nomad1_check  $cataconf.nomad1_dir  -sticky nsw -pady 3
            grid $cataconf.twomass_check $cataconf.twomass_dir -sticky nsw -pady 3
 
            button $f4.go -state active -text "Conesearch" -relief "raised" \
               -command ""
            pack $f4.go -in $f4 -anchor c 
 
              
         # onglets : Catalogues

         set col_catalogues { 0 pos 0 Cata 0 IdS 0 x 0 y }

         set ::bdi_gui_gestion_source::gui_catalogues [frame $f6.catalogues -borderwidth 0 -cursor arrow -relief groove]
         pack $::bdi_gui_gestion_source::gui_catalogues -in $f6 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
         ::bdi_gui_gestion_source::create_Tbl_sources $::bdi_gui_gestion_source::gui_catalogues $col_catalogues


         # Pied de page

         set actionspied [frame $frm.actionspied -borderwidth 0 -cursor arrow -relief groove]
         pack $actionspied -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $actionspied.fermer -state active -text "Fermer" -relief "raised" -command "destroy $::bdi_gui_gestion_source::fen"
             pack   $actionspied.fermer -in $actionspied -side right -anchor w -padx 0

   }














}

