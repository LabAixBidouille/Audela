## \file bdi_tools_psf.tcl
#  \brief     Traitement des psf des images
#  \details   Ce namepsace concerne l'appel des methodes de mesures de psf sans GUI
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_psf.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
#
# source [ file join $audace(rep_plugin) tool bddimages bdi_tools_psf.tcl ]
#
#--------------------------------------------------
#
# Mise à jour $Id: bdi_tools_psf.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------

## Declaration du namespace \c bdi_tools_psf .
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Appel SANS GUI
namespace eval bdi_tools_psf {


   variable psf_saturation
   variable psf_threshold
   variable psf_limitradius
   variable psf_radius
   variable psf_rect
   variable psf_methode


   #------------------------------------------------------------
   ## Charge les parametres depuis la configuration d'AUDACE
   # Cette initialisation est a effectuer avant l'appel
   # a une fonction de mesure de photocentre
   # @return void
   #
   proc ::bdi_tools_psf::inittoconf { } {

      global conf

      if {! [info exists ::bdi_tools_psf::use_psf] } {
         if {[info exists conf(bddimages,cata,psf,create)]} {
            set ::bdi_tools_psf::use_psf $conf(bddimages,cata,psf,create)
         } else {
            set ::bdi_tools_psf::use_psf 0
         }
      }
      if {! [info exists ::bdi_tools_psf::use_global] } {
         if {[info exists conf(bddimages,cata,psf,globale)]} {
            set ::bdi_tools_psf::use_global $conf(bddimages,cata,psf,globale)
         } else {
            set ::bdi_tools_psf::use_global 0
         }
      }
      if {! [info exists ::bdi_tools_psf::psf_saturation] } {
         if {[info exists conf(bddimages,cata,psf,saturation)]} {
            set ::bdi_tools_psf::psf_saturation $conf(bddimages,cata,psf,saturation)
         } else {
            set ::bdi_tools_psf::psf_saturation 50000
         }
      }
      if {! [info exists ::bdi_tools_psf::psf_radius] } {
         if {[info exists conf(bddimages,cata,psf,radius)]} {
            set ::bdi_tools_psf::psf_radius $conf(bddimages,cata,psf,radius)
         } else {
            set ::bdi_tools_psf::psf_radius 15
         }
      }
      if {! [info exists ::bdi_tools_psf::psf_threshold] } {
         if {[info exists conf(bddimages,cata,psf,threshold)]} {
            set ::bdi_tools_psf::psf_threshold $conf(bddimages,cata,psf,threshold)
         } else {
            set ::bdi_tools_psf::psf_threshold 2
         }
      }
      if {! [info exists ::bdi_tools_psf::psf_limitradius] } {
         if {[info exists conf(bddimages,cata,psf,limitradius)]} {
            set ::bdi_tools_psf::psf_limitradius $conf(bddimages,cata,psf,limitradius)
         } else {
            set ::bdi_tools_psf::psf_limitradius 50
         }
      }
      if {! [info exists ::bdi_tools_psf::psf_methode] } {
         if {[info exists conf(bddimages,cata,psf,methode)]} {
            set ::bdi_tools_psf::psf_methode $conf(bddimages,cata,psf,methode)
         } else {
            set ::bdi_tools_psf::psf_methode "basic"
         }
      }

   }


   #------------------------------------------------------------
   ## A la fermeture de l'application, cette fonction
   # sauvegarde les parametres dans la conf
   # @return void
   #
   proc ::bdi_tools_psf::closetoconf { } {

      global conf
   
      # Conf cata psf
      set conf(bddimages,cata,psf,create)       $::bdi_tools_psf::use_psf
      set conf(bddimages,cata,psf,globale)      $::bdi_tools_psf::use_global
      set conf(bddimages,cata,psf,saturation)   $::bdi_tools_psf::psf_saturation
      set conf(bddimages,cata,psf,radius)       $::bdi_tools_psf::psf_radius
      set conf(bddimages,cata,psf,threshold)    $::bdi_tools_psf::psf_threshold
      set conf(bddimages,cata,psf,limitradius)  $::bdi_tools_psf::psf_limitradius
      set conf(bddimages,cata,psf,methode)      $::bdi_tools_psf::psf_methode
   }



   #------------------------------------------------------------
   ## Cette fonction renvoit la liste des methodes
   # de mesure de psf
   # @return liste des methodes
   #
   proc ::bdi_tools_psf::get_methodes { } {
   
      return { fitgauss basic globale }
   
   }



   #------------------------------------------------------------
   ## Cette fonction renvoit une source
   # ASTROID nulle.
   # elle sert generalement comme premiere etape 
   # de creation d'une nouvelle source 
   # @return une source ASTROID vide
   #
   proc ::bdi_tools_psf::get_astroid_null { } {
      
      set r ""
      for {set i 1} {$i<=30} {incr i} {
         lappend r ""
      }
      return $r
   }


#  0    "xsm" 
#  1    "ysm" 
#  2    "err_xsm" 
#  3    "err_ysm" 
#  4    "fwhmx" 
#  5    "fwhmy" 
#  6    "fwhm" 
#  7    "flux" 
#  8    "err_flux" 
#  9    "pixmax"
#  10   "intensity" 
#  11   "sky" 
#  12   "err_sky" 
#  13   "snint" 
#  14   "radius" 
#  15   "rdiff" 
#  16   "err_psf" 
#  17   "ra" 
#  18   "dec"
#  19   "res_ra" 
#  20   "res_dec" 
#  21   "omc_ra" 
#  22   "omc_dec" 
#  23   "mag" 
#  24   "err_mag" 
#  25   "name" 
#  26   "flagastrom" 
#  27   "flagphotom" 
#  28   "cataastrom"
#  29   "cataphotom"
#  
   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs d'une source
   # ASTROID sous la forme des other field
   # c est la liste de tous les parametres que l'on peut 
   # en tirer par la mesure photocentrique. mais aussi de l'astrometrie
   # ainsi que les parametres de gestion 
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_otherfields_astroid { } {

      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "flux" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf" "ra" "dec" \
                   "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name" "flagastrom" "flagphotom" "cataastrom" \
                   "cataphotom"]
   }

   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme des other field
   # seulement la liste des champs modifie par la methode BASIC
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_globale_fields { } {

      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "flux" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf" "ra" "dec"]
   }

   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme des other field
   # seulement la liste des champs modifie par la methode BASIC
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_basic_fields { } {

      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "flux" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf" "ra" "dec"]
   }

   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme des other field
   # seulement la liste des champs modifie par la methode BASIC
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_fitgauss_fields { } {
      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "flux" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf" "ra" "dec" \
             ]
   }

   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme d'une variable current_psf
   # qui sert pour l affichage 
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_fields_current_psf { } {
      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "err_psf" "flux" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff"]
   }
   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme d'une variable current_psf
   # qui sert pour l affichage de la colonne de gauche
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_fields_current_psf_left { } {
      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "err_psf" ]
   }
   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme d'une variable current_psf
   # qui sert pour l affichage de la colonne de droite
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_fields_current_psf_right { } {
      return [list "flux" "err_flux" "pixmax" "intensity" "sky" "err_sky" "snint" "radius" "rdiff"]
   }








   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs d'une source
   # ASTROID compatible avec la forme listesource.
   # c est l'entete d'un cata ASTROID
   # @return cata fields d'astroid
   #
   proc ::bdi_tools_psf::get_fields_sources_astroid { } {

      return [list "ASTROID" [list "ra" "dec" "poserr" "mag" "magerr"] \
                             [::bdi_tools_psf::get_otherfields_astroid] ]

   }






   #------------------------------------------------------------
   ## Pour une cle donne, cette fonction fournit sa position 
   # dans la liste ASTROID 
   # @param key nom de la cle  (\sa get_fields_sources_astroid
   # @return id sous forme d'un entier 
   #
   proc ::bdi_tools_psf::get_id_astroid { key } {
      return [lsearch [::bdi_tools_psf::get_otherfields_astroid] $key]     
   }





   #------------------------------------------------------------
   ## Pour une cle donne, cette fonction fournit sa position 
   # dans la liste ASTROID 
   # @param key nom de la cle  (\sa get_fields_sources_astroid
   # @return id sous forme d'un entier 
   #
   proc ::bdi_tools_psf::set_photom_error { p_othf err } {

      upvar $p_othf othf

      set othf [::bdi_tools_psf::get_astroid_null]
      ::bdi_tools_psf::set_by_key othf "err_psf" $err
   }








   #------------------------------------------------------------
   ## modifier la cle d'une liste astroid (other fields) 
   # @param othf pointeur de la liste qui va etre modifiee.
   # @param key cle qui fait reference de la valeur a modifiee
   # @param val nouvelle valeur a modifier
   # @return void
   #
   proc ::bdi_tools_psf::set_by_key { p_othf key val } {
      
      upvar $p_othf othf
   
      set p [::bdi_tools_psf::get_otherfields_astroid]
      set pos [lsearch $p $key]
      if {$pos != -1} {
         set othf [lreplace $othf $pos $pos $val]
      }
      return
   }



   #------------------------------------------------------------
   ## cree un tableau taboid des element de la liste otherfield
   # @param taboid pointeur du tableau qui va etre cree
   # @param othf pointeur de la liste qui va etre lue
   # @return void
   #
   proc ::bdi_tools_psf::get_tab {  p_othf p_taboid } {

      upvar $p_taboid taboid
      upvar $p_othf othf

         set p [::bdi_tools_psf::get_otherfields_astroid]
         foreach key $p {
            set pos [lsearch $p $key]
            set taboid($key) [lindex $othf $pos]
         }
   }



   #------------------------------------------------------------
   ## Affiche la liste otherfield dans la console
   # @param othf pointeur de la liste qui va etre affichee
   # @return void
   #
   proc ::bdi_tools_psf::gren_astroid {  p_othf } {

      upvar $p_othf othf

         gren_info "-- ASTROID ---\n"
         set p [::bdi_tools_psf::get_otherfields_astroid]
         foreach key $p {
            set pos [lsearch $p $key]
            gren_info "$key = [lindex $othf $pos]\n"
         }
   }

   #------------------------------------------------------------
   ## cree un tableau taboid des element de la liste otherfield
   # @param taboid pointeur du tableau qui va etre cree
   # @param othf pointeur de la liste qui va etre lue
   # @return void
   #
   proc ::bdi_tools_psf::get_val { p_othf key } {

      upvar $p_othf othf

         set p [::bdi_tools_psf::get_otherfields_astroid]
         set pos [lsearch $p $key]
         return [lindex $othf $pos]
   }










   #------------------------------------------------------------
   ## Fonction qui renvoit les coordonnees de la source
   # calculee a partir du WCS inscrit dans l image et 
   # se basant sur les coordonnees RA et DEC des champs 
   # common de la source.
   # Si "cata" n est pas renseigne, le premier catalogue 
   # de la liste sera considere
   # @param s pointeur de la source envoyee en argument
   # @param cata (optionnel) fixe le nom du catalogue pour 
   # en calculer la position x y 
   # @return {x y} la liste des coordonnees pixels de la source
   #
   proc ::bdi_tools_psf::get_xy { p_s { cata ""} } {

      upvar $p_s s

      if { $cata == "" } {
         set cata [lindex $s 0]
      } else {
         set cata [lindex $s [lsearch -index 0 $s $cata]]
      }
      set ra   [lindex $cata {1 0}] 
      set dec  [lindex $cata {1 1}]
      return [ buf$::audace(bufNo) radec2xy [list $ra $dec ] ]
   }

   #------------------------------------------------------------
   ## Fonction qui renvoit les coordonnees X Y de la source
   # dont le catalogue ASTROID est present 
   # les coordonnees X et Y sont celles mesurees dans l'image
   # lors de l'ajustement de la PSF
   # @param s pointeur de la source envoyee en argument
   # @return {x y} la liste des coordonnees pixels de la source
   #
   proc ::bdi_tools_psf::get_xy_astroid { p_s  } {

      upvar $p_s s

      set pos [lsearch -index 0 $s "ASTROID"]
      if { $pos != -1 } {
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set xsm [::bdi_tools_psf::get_val othf "xsm"]
         set ysm [::bdi_tools_psf::get_val othf "ysm"]
         return [list $xsm $ysm]
      } else {
         return -1
      }
   }






   #------------------------------------------------------------
   ## Fonction qui retourne les champs otherfield d ASTROID
   # pour une source donnee. Si la source ne comporte pas de 
   # cata ASTROID alors une entree vide 
   # @param s source qui se verra modifiee
   # @return void
   #
   proc ::bdi_tools_psf::get_astroid_othf_from_source { s } {
      
      set posastr [lsearch -index 0 $s "ASTROID"]
      if {$posastr == -1} {
         set othf [::bdi_tools_psf::get_astroid_null]
      } else {
         set othf [lindex [lindex $s $posastr] 2]
      }
      return $othf
   }



   #------------------------------------------------------------
   ## Cette fonction ajoute les champs ASTROID a la liste Fields
   # qui nomme chaque champs d'un catalogue ASTROID dans une 
   # listsources
   # @param p_listsources pointeur de variable de type listsources
   # @return void
   #
   proc ::bdi_tools_psf::set_fields_astroid { p_listsources } {
   
      upvar $p_listsources listsources
      
      set fields [lindex $listsources 0]
      set pos [lsearch -index 0 $fields "ASTROID"]
      if {$pos == -1 } {
         lappend fields [::bdi_tools_psf::get_fields_sources_astroid]
      }
      set listsources [lreplace $listsources 0 0 $fields]
      return
   }

   #------------------------------------------------------------
   ## Fonction qui modifie les champs commonfields d'une source ASTROID
   # a partir de ses champs otherfields
   # @param p_s pointeur d'une source qui sera modifiee
   # @return void
   #
   proc ::bdi_tools_psf::set_astroid_common_fields { p_s } {

      upvar $p_s s
     
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]

      set ra      [::bdi_tools_psf::get_val othf "ra"]
      set dec     [::bdi_tools_psf::get_val othf "dec"]
      set res_ra  [::bdi_tools_psf::get_val othf "res_ra"]
      set res_dec [::bdi_tools_psf::get_val othf "res_dec"]
      if { $res_ra == "" || $res_dec == "" } {
         set err_pos "3"
      } else {
         set res_ra  [expr $res_ra * cos([deg2rad $dec]) ]
         set err_pos [expr sqrt( ( pow($res_ra,2) + pow($res_dec,2) ) / 2.0 ) ]
      }
      set mag     [::bdi_tools_psf::get_val othf "mag"]
      set err_mag [::bdi_tools_psf::get_val othf "err_mag"]

      set commonf [list $ra $dec $err_pos $mag $err_mag ]
      set posastr [lsearch -index 0 $s "ASTROID"]
      if {$posastr == -1} {
         return
      } else {
        set astroid [lindex $s $posastr]
        set astroid [lreplace $astroid 1 1 $commonf]
        set s [lreplace $s $posastr $posastr $astroid]
      }
      
   }

   #------------------------------------------------------------
   ## Fonction qui modifie les champs otherfield une source ASTROID
   # @param s pointeur d'une source qui se verra modifiee
   # @param othf pointeur d'une liste otherfield
   # @return void
   #
   proc ::bdi_tools_psf::set_astroid_in_source { p_s p_othf} {

      upvar $p_s s
      upvar $p_othf othf
      
      ::manage_source::delete_catalog_in_source s "ASTROID"
      lappend s [list "ASTROID" {} $othf]
      ::bdi_tools_psf::set_astroid_common_fields s
   }













   #------------------------------------------------------------
   ## Fonction qui mesure le photocentre d'une source
   # @param s pointeur d'une source qui se verra modifiee
   # @return void
   #
   proc ::bdi_tools_psf::get_psf_source { p_s } {

      upvar $p_s s
      
      set xy       [::bdi_tools_psf::get_xy s]
      set othf_old [::bdi_tools_psf::get_astroid_othf_from_source $s]
      set p        [::bdi_tools_psf::get_otherfields_astroid]
      if {[llength $othf_old ] !=  [llength $p ]} {
         set othf_old [::bdi_tools_psf::get_astroid_null]
      }

      switch $::bdi_tools_psf::psf_methode {

         "fitgauss" {
            set othf [::bdi_tools_methodes_psf::fitgauss $::bdi_tools_psf::psf_rect $::audace(bufNo)]
            set fields [::bdi_tools_psf::get_fitgauss_fields]
         }

         "basic" {
            set othf [::bdi_tools_methodes_psf::basic [lindex $xy 0] [lindex $xy 1] $::bdi_tools_psf::psf_radius $::audace(bufNo)]
            set fields [::bdi_tools_psf::get_basic_fields]
         }

         "globale" {
            set err [ catch { set othf [::bdi_tools_methodes_psf::globale [lindex $xy 0] [lindex $xy 1] $::audace(bufNo)] } msg ]
            if {$err} {
               gren_erreur "err = $err\n"
               gren_erreur "msg = $msg\n"
               return -code 10 "Globale PSF impossible"
               
            }
            set fields [::bdi_tools_psf::get_globale_fields]
         }

         "aphot" {
         }

         "bphot" {
         }
      
      }
      
      # Affichage des resultats dans la console
      #::bdi_tools_psf::gren_astroid othf

      # on ne modifie que les champs modifies par la methode


      foreach key $fields {
         set pos [lsearch $p $key]
         set othf_old [lreplace $othf_old $pos $pos [lindex $othf $pos] ]
      }
      
      # on nomme la source
      set name_cata [::manage_source::namable $s]
      if {$name_cata!=""} {
         set name_source [::manage_source::naming $s $name_cata]
         ::bdi_tools_psf::set_by_key othf_old "name" $name_source
      }


      set err_psf [::bdi_tools_psf::get_val othf_old "err_psf"]
      if {$err_psf == "" } {
         ::bdi_tools_psf::set_astroid_in_source s othf_old
      } else {
         gren_erreur "Erreur PSF\n"
      }
      return $err_psf
   }
















   #
   # ::analyse_source::psf
   # Mesure de PSF d'une source
   #
   proc ::bdi_tools_psf::get_psf_listsources { p_listsources } {
   
      upvar $p_listsources listsources
    
      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      set pass "no"
      set id 0     
      foreach s $sources {
         set err [ catch {set err_psf [::bdi_tools_psf::get_psf_source s] } msg ]
         
         if {$id == -1} {
            gren_info "err=$err\n"
            gren_info "err_psf=$err_psf\n"
            gren_info "s=$s\n"
         }
         
         if {$err} {
            ::manage_source::delete_catalog_in_source s "ASTROID"
         } else {
            if { $err_psf != ""} {
               gren_erreur "*ERREUR PSF err_psf: $err_psf\n"
            } else {
               set pass "yes"
            }
         }
         set sources [lreplace $sources $id $id $s]
         incr id
      }

      if {$pass=="no"} { return }
      
      ::bdi_tools_psf::set_fields_astroid listsources
      ::bdi_tools_psf::set_mag listsources
      
      return
   }







   proc ::bdi_tools_psf::set_mag { send_listsources } {

      upvar $send_listsources listsources
      ::bdi_tools_psf::set_mag_usno_r listsources

   }



   proc ::bdi_tools_psf::set_mag_usno_r { send_listsources } {
      
      upvar $send_listsources listsources

      #set ::psf_tools::debug $listsources


      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      
      set nd_sources [llength $sources]

      set tabmaginst ""
      set tabmagcata ""
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "USNOA2"} {
               set pos [lsearch -index 0 $s "ASTROID"]
               if {$pos!=-1} {
                  set usnoa2 $cata
                  set usnoa2_oth [lindex $usnoa2 2]
                  set astroid [lindex $s $pos]
                  set astroid_com [lindex $astroid 1]
                  set astroid_oth [lindex $astroid 2]
                  set flux [lindex $astroid_oth 7 ]
                  set magcata  [lindex $usnoa2_oth  7]
                  if {$flux!="" && $magcata != "" && $flux>0} {        
                     set maginst  [expr -log10($flux)*2.5]
                     lappend tabmaginst  $maginst 
                     lappend tabmagcata  $magcata  
                  }
                  
               }
            }
         }
      }
      gren_info "nb data = [llength $tabmaginst] == [llength $tabmagcata] \n"
      if {[llength $tabmaginst]==0||[llength $tabmagcata]==0} {return}
      set median_maginst [::math::statistics::median $tabmaginst ]
      set median_magcata [::math::statistics::median $tabmagcata ]
      set const_mag      [expr $median_magcata - $median_maginst]
      #gren_info "median_maginst = $median_maginst\n"
      #gren_info "median_magcata = $median_magcata\n"
      #gren_info "const_mag = $const_mag\n"

      set tabmaginst ""
      set tabmagcata ""
      set tabflux ""
      set tabmag  ""
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "USNOA2"} {
               set pos [lsearch -index 0 $s "ASTROID"]
               if {$pos!=-1} {
                  set usnoa2      $cata
                  set usnoa2_oth  [lindex $usnoa2 2]
                  set astroid     [lindex $s $pos]
                  set astroid_com [lindex $astroid 1]
                  set astroid_oth [lindex $astroid 2]
                  set flux        [::bdi_tools_psf::get_val astroid_oth "flux" ]
                  set magcata     [lindex $usnoa2_oth  7 ]

                  if {$flux!="" && $magcata != ""  && $flux>0} {
                     set maginst  [expr -log10($flux)*2.5]
                     set magcalc  [expr -log10($flux)*2.5 + $const_mag]
                     if {[expr abs($magcata - $magcalc) ] < 1.} {
                        lappend tabmaginst  $maginst 
                        lappend tabmagcata  $magcata  
                        #gren_info "mag cata = $magcata ; maginstru = $maginst ; diff = [expr abs($magcata - $maginst) ] ; macalc = $magcalc ; diff = [expr abs($magcalc - $magcata) ]\n"
                        #gren_info "flux = $flux ; mag cata = $magcata ; magcalc = $magcalc ; diff = [expr abs($magcata - $magcalc) ] \n"
                        lappend tabmag  [expr abs($magcalc - $magcata) ]
                     }
                  }
               }
            }
         }
      }

      set median_maginst [::math::statistics::median $tabmaginst ]
      set median_magcata [::math::statistics::median $tabmagcata ]
      set const_mag      [expr $median_magcata - $median_maginst]
      set mag_err [format "%.3f" [::math::statistics::mean $tabmag] ]

  # calcul toutes les sources

      set spos 0
      foreach s $sources {
         set cpos [lsearch -index 0 $s "ASTROID"]
         if {$cpos != -1} {

               set astroid [lindex $s $cpos]
               set astroid_com [lindex $astroid 1]
               set astroid_oth [lindex $astroid 2]
               set flux [::bdi_tools_psf::get_val astroid_oth "flux" ]

               set err [catch {set mag [format "%.3f" [expr -log10($flux)*2.5 + $const_mag] ]} msg ]
               if {$err} {
                  #gren_info "ERREUR MAG : s = $s \n"
                  #gren_info "ERREUR MAG : flux = $flux ; const_mag = $const_mag\n"
                  incr spos
                  continue
               }
               if {$flux < 0 } {
                  incr spos
                  continue
               }
               set astroid_com [lreplace  $astroid_com 3 4 $mag $mag_err ]
               ::bdi_tools_psf::set_by_key astroid_oth "mag" $mag
               ::bdi_tools_psf::set_by_key astroid_oth "err_mag" $mag_err
               set s [lreplace $s $cpos $cpos [list "ASTROID" $astroid_com $astroid_oth]]
               set sources [lreplace $sources $spos $spos $s]
         }
         incr spos
         
      }
      
      set listsources [list $fields $sources]
      return
   }




}



