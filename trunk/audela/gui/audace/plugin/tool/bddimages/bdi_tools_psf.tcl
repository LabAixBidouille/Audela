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


   proc ::bdi_tools_psf::get_xy { send_s } {

      upvar $send_s s

      return xy  { 973.33 1201.05 }
   }












   proc ::bdi_tools_psf::psf_source { send_s } {

      upvar $send_s s
      
      gren_info "psf_methode = $::bdi_tools_psf::psf_methode\n"
      gren_info "s = $s\n"
      set xy [::bdi_tools_psf::get_xy s]
      
      switch $::bdi_tools_psf::psf_methode {
         "fitgauss" {
            set r [::bdi_tools_methodes_psf::fitgauss $::bdi_tools_psf::psf_rect $::audace(bufNo)]
         }
         "basic" {
            set r [::bdi_tools_methodes_psf::basic [lindex $xy 0] [lindex $xy 1] $::bdi_tools_psf::psf_radius $::audace(bufNo)]
         }
         "globale" {
         }
         "aphot" {
         }
         "bphot" {
         }
      
      }
      gren_info "Resultats = $r\n"
      
      
      
   }




}
