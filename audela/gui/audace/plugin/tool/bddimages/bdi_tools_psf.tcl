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
# Mise Ã  jour $Id: bdi_tools_psf.tcl 6858 2011-03-06 14:19:15Z fredvachier $
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
   ## Cette fonction renvoit la liste des methodes
   # de mesure de psf
   # @return liste des methodes
   #
   proc ::bdi_tools_psf::get_methodes { } {
   
      return { fitgauss basic globale aphot bphot }
   
   }



   #------------------------------------------------------------
   ## Cette fonction renvoit une source
   # ASTROID nulle.
   # elle sert generalement comme premiere etape 
   # de creation d'une nouvelle source 
   # @return une source ASTROID vide
   #
   proc ::bdi_tools_psf::get_astroid_null { } {

      return [list "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "-" \
                   "-" \
                   "-" \
                   "-" \
                   "-" \
                   ]
   }



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
   proc ::bdi_tools_psf::get_basic_fields { } {

      return [list "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf" "ra" "dec"]
   }

   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme des other field
   # seulement la liste des champs modifie par la methode BASIC
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_fitgauss_fields { } {
      return [list "xsm" "ysm" "fwhmx" "fwhmy" "fwhm"  "pixmax" \
                   "intensity" "sky" "radius" "err_psf" "ra" "dec" \
             ]
   }

   #------------------------------------------------------------
   ## Cette fonction renvoit les noms des champs 
   # d'une source ASTROID sous la forme d'une variable current_psf
   # qui sert pour l affichage 
   # @return liste des champs d'une source ASTROID
   #
   proc ::bdi_tools_psf::get_fields_current_psf { } {
      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf"]
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
   ## Pour une clé donné, cette fonction fournit sa position 
   # dans la liste ASTROID 
   # @param key nom de la clé  (\sa get_fields_sources_astroid).
   # @return id sous forme d'un entier 
   #
   proc ::bdi_tools_psf::get_id_astroid { key } {
      return [lsearch [::bdi_tools_psf::get_otherfields_astroid] $key]     
   }











   #------------------------------------------------------------
   ## modifier la clé d'une liste astroid (other fields) 
   # @param othf pointeur de la liste qui va etre modifiée.
   # @param key clé qui fait reference de la valeur a modifiée
   # @param val nouvelle valeur a modifier
   # @return void
   #
   proc ::bdi_tools_psf::set_by_key { send_othf key val } {
      
      upvar $send_othf othf
   
      set p [::bdi_tools_psf::get_otherfields_astroid]
      set pos [lsearch $p $key]
      set othf [lreplace $othf $pos $pos $val]
   }



   #------------------------------------------------------------
   ## cree un tableau taboid des element de la liste otherfield
   # @param taboid pointeur du tableau qui va etre cree
   # @param othf pointeur de la liste qui va etre lue
   # @return void
   #
   proc ::bdi_tools_psf::get_tab {  send_othf send_taboid } {

      upvar $send_taboid taboid
      upvar $send_othf othf

         set p [::bdi_tools_psf::get_otherfields_astroid]
         foreach key $p {
            set pos [lsearch $p $key]
            set taboid($key) [lindex $othf $pos]
         }
   }



   #------------------------------------------------------------
   ## Affiche la liste otherfield dans la console
   # @param taboid pointeur du tableau qui va etre cree
   # @param othf pointeur de la liste qui va etre lue
   # @return void
   #
   proc ::bdi_tools_psf::gren_astroid {  send_othf } {

      upvar $send_othf othf

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
   proc ::bdi_tools_psf::get_val { send_othf key } {

      upvar $send_othf othf

         set p [::bdi_tools_psf::get_otherfields_astroid]
         set pos [lsearch $p $key]
         return [lindex $othf $pos]
   }










   #------------------------------------------------------------
   ## A la fermeture de l'application, cette fonction
   # sauvegarde les parametres dans la conf
   # @return void
   #
   proc ::bdi_tools_psf::get_xy { send_s { cata ""} } {

      upvar $send_s s

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
   ## Fonction qui retourne les champs otherfield d ASTROID
   # pour une source donnee. Si la source ne comporte pas de 
   # cata ASTROID alors une entree vide 
   # @param s pointeur d'une source qui se verra modifiée
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
   ## Fonction qui supprime le catalogue ASTROID d'une source
   # @param s pointeur d'une source qui sera modifiée
   # @return void
   #
   proc ::bdi_tools_psf::delete_cata_from_source { send_s cata} {

      upvar $send_s s

      set news ""
      foreach c $s {
         if {[lindex $c 0]==$cata} {continue}
         lappend news $c
      }
      set s $news

   }

   #------------------------------------------------------------
   ## Fonction qui modifie les champs commonfields d'une source ASTROID
   # a partir de ses champs otherfields
   # @param s pointeur d'une source qui sera modifiée
   # @return void
   #
   proc ::bdi_tools_psf::set_astroid_common_fields { send_s } {

      upvar $send_s s
     
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]

      set ra      [::bdi_tools_psf::get_val othf "ra"]
      set dec     [::bdi_tools_psf::get_val othf "dec"]
      set res_ra  [::bdi_tools_psf::get_val othf "res_ra"]
      set res_ra  [expr $res_ra * cos([deg2rad $dec]) ]
      set res_dec [::bdi_tools_psf::get_val othf "res_dec"]
      set err_pos [expr sqrt( ( pow($res_ra,2) + pow($res_dec,2) ) / 2.0 ) ]
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
   # @param s pointeur d'une source qui se verra modifiée
   # @param othf pointeur d'une liste otherfield
   # @return void
   #
   proc ::bdi_tools_psf::set_astroid_in_source { send_s send_othf} {

      upvar $send_s s
      upvar $send_othf othf
      
      ::bdi_tools_psf::delete_cata_from_source s "ASTROID"
      lappend s [list "ASTROID" {} $othf]
      ::bdi_tools_psf::set_astroid_common_fields s
   }


   #------------------------------------------------------------
   ## Fonction qui mesure le photocentre d'une source
   # @param s pointeur d'une source qui se verra modifiée
   # @return void
   #
   proc ::bdi_tools_psf::get_psf_source { send_s } {

      upvar $send_s s
      
      gren_info "psf_methode = $::bdi_tools_psf::psf_methode\n"
      set xy       [::bdi_tools_psf::get_xy s]
      set othf_old [::bdi_tools_psf::get_astroid_othf_from_source $s]
      set p        [::bdi_tools_psf::get_otherfields_astroid]

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
            set othf [::bdi_tools_methodes_psf::globale [lindex $xy 0] [lindex $xy 1] $::audace(bufNo)]
            set fields [::bdi_tools_methodes_psf::get_globale_fields]
         }

         "aphot" {
         }

         "bphot" {
         }
      
      }
      ::bdi_tools_psf::gren_astroid othf

      # on ne modifie que les champs modifiés par la methode
      foreach key $fields {
         set pos [lsearch $p $key]
         set othf_old [lreplace $othf_old $pos $pos [lindex $othf $pos] ]
      }
      ::bdi_tools_psf::set_astroid_in_source s othf_old
      
   }














}
