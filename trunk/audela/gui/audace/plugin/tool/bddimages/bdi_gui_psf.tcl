## \file bdi_gui_psf.tcl
#  \brief     Traitement des psf des images
#  \details   Ce namepsace concerne seulement l'affichage et 
#             l'appel des methodes de mesures de psf
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_psf.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_gui_psf.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_gui_psf.tcl
# Description    : Traitement des psf des images
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_gui_psf.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bdi_gui_psf
#
#--------------------------------------------------


## Declaration du namespace \c bdi_gui_psf .
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Appel par GUI uniquement
namespace eval bdi_gui_psf {



   #------------------------------------------------------------
   ## Charge les parametres depuis la configuration d'AUDACE
   # Cette initialisation est a effectuer avant l'appel
   # a une fonction de mesure de photocentre
   # @return void
   #
   proc ::bdi_gui_psf::inittoconf { } {

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
   proc ::bdi_gui_psf::closetoconf { } {

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
   ## Fonction qui initialise la variable current_psf
   # et formate le resultat
   # @param otherfield ASTROID
   # @return void
   #
   proc ::bdi_gui_psf::init_current_psf { othf } {
   
      set l [::bdi_tools_psf::get_fields_current_psf]

      foreach key $l {
      
         set value [::bdi_tools_psf::get_val othf $key]
         
         if {[string is ascii $value]} {set fmt "%s"}
         if {[string is double $value]} {set fmt "%.4f"}
         if {$value==""} {
            set ::gui_cata::current_psf($key) ""
            continue
         }
         if { ! [info exists fmt] } {gren_erreur "$value n a pas de format\n"}
         set ::gui_cata::current_psf($key) [format $fmt $value ]
      }
      
   }



   proc ::bdi_gui_psf::gui_configuration { frm } {

      
      set spinlist ""
      for {set i 1} {$i<$::bdi_tools_psf::psf_limitradius} {incr i} {lappend spinlist $i}
      
      # configuration par onglets
      set block [frame $frm.conf -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $frm -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

              set meth_onglets [frame $block.meth_onglets -borderwidth 0 -cursor arrow -relief groove]
              pack $meth_onglets -in $block -side top -expand yes -fill both -padx 10 -pady 5

              pack [ttk::notebook $meth_onglets.nb] -expand yes -fill both 
              set i 0
              foreach m [::bdi_tools_psf::get_methodes] {
                 incr i
                 set ongl($i) [frame $meth_onglets.nb.g$i]
                 $meth_onglets.nb add $ongl($i) -text $m
              }

              ttk::notebook::enableTraversal $meth_onglets.nb


              # configuration photombasic
              set block [frame $ongl(2).conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $ongl(2) -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Rayon : " 
                     spinbox $block.radiusc -values $spinlist -from 1 -to $::bdi_tools_psf::psf_limitradius -textvariable ::gui_cata::psf_radius -width 3 \
                         -command ""
                     pack  $block.radiusc -side left 
                     $block.radiusc set 15

                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radiusc  -sticky nsw -pady 3

              # configuration globale
              set block [frame $ongl(3).conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $ongl(3) -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Limite du Rayon : " 
                     entry $block.radv -textvariable ::bdi_tools_psf::psf_limitradius -relief sunken -width 5

                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radv  -sticky nsw -pady 3



    set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
    pack $actions -in $frm -anchor c -side top

           label $actions.lab1 -text "Methode pour PSF : " 
           menubutton $actions.b -menu $actions.b.m -textvar ::bdi_tools_psf::psf_methode -width 10 -relief groove
           menu $actions.b.m -tearoff 0
           foreach value [::bdi_tools_psf::get_methodes] { 
              $actions.b.m add command -label $value -command [list ::bdi_gui_psf::focus_conf_methode $frm $value ] 
           }
           grid $actions.lab1 $actions.b
           #$actions.b.m select 

     ::bdi_gui_psf::focus_conf_methode $frm
   }
     
     
# focus sur l'onglet de la methode de ::bdi_tools_psf::psf_methode
proc ::bdi_gui_psf::focus_conf_methode { frm { value "" } } {
      
      if { $value != "" } {
         set ::bdi_tools_psf::psf_methode $value
      }

      set i 0
      foreach m [::bdi_tools_psf::get_methodes] {
         incr i
         if {$m == $::bdi_tools_psf::psf_methode } {
            $frm.conf.meth_onglets.nb select $frm.conf.meth_onglets.nb.g$i
            break
         }
      }
   }




}
