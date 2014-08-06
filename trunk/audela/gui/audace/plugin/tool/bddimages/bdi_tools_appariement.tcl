## \file bdi_tools_appariement.tcl
#  \brief     Choix de la methode d'appariement pour l'astrometrie
#  \details   Ce namepsace permet de choisir la methode d'appariement et de definir leurs parametres. Usage:
#
# set ::bdi_tools_appariement::calibwcs_args "$ra $dec * * *"
# set erreur [catch {set calibwcs_cmd [::bdi_tools_appariement::get_calibwcs_cmde]} msg]
# if {$erreur} { ... }
# set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
# if {$erreur} { ... }
#
#  \author    Jerome Berthier
#  \version   1.0
#  \date      2014
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [ file join $audace(rep_plugin) tool bddimages bdi_tools_appariement.tcl ]
#  \endcode
#  \todo      ...
# Mise à jour $Id: bdi_gui_psf.tcl 6858 2011-03-06 14:19:15Z fredvachier $

## Declaration du namespace \c bdi_tools_appariement
#  @pre       Chargement a partir d'Audace
#  @warning   Appel par GUI
namespace eval bdi_tools_appariement {

   # Choix de la methode d'appariement: 0: calibwcs ; 1: calibwcs_new
   variable calibwcs_method

   # Parametres de la methode d'appariement:
   #   calibwcs_param(maglimit)       : magnitude limite de la methode calibwcs
   #   calibwcs_param(refcata)        : cata de reference pour l'appariement
   #   calibwcs_param(delta)          : ? 
   #   calibwcs_param(nmax)           : ?
   #   calibwcs_param(flux_criterion) : ?
   #   calibwcs_param(catalist)       : Liste des cata de ref. possibles
   variable calibwcs_param

   # Parametres externes de la methode d'appariement (i.e. independant de la methode)
   variable calibwcs_args

   # Liste des catalogues disponibles affichee dans la GUI
   variable combo_catalist

}

#------------------------------------------------------------
## Initialisation des parametres d'appariement au niveau GUI
# @return void
#
proc ::bdi_tools_appariement::inittoconf { } {

   global conf

   # Methode d'appariement
   if {! [info exists ::bdi_tools_appariement::calibwcs_method] } {
      if {[info exists conf(bddimages,appariement,method)]} {
         set ::bdi_tools_appariement::calibwcs_method $conf(bddimages,appariement,method)
      } else {
         set ::bdi_tools_appariement::calibwcs_method 0
      }
   }
   # Parametres des methodes d'appariement
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(maglimit)] } {
      if {[info exists conf(bddimages,appariement,maglimit)]} {
         set ::bdi_tools_appariement::calibwcs_param(maglimit) $conf(bddimages,appariement,maglimit)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(maglimit) ""
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(refcata)] } {
      if {[info exists conf(bddimages,appariement,refcata)]} {
         set ::bdi_tools_appariement::calibwcs_param(refcata) $conf(bddimages,appariement,refcata)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(refcata) "?"
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(delta)] } {
      if {[info exists conf(bddimages,appariement,delta)]} {
         set ::bdi_tools_appariement::calibwcs_param(delta) $conf(bddimages,appariement,delta)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(delta) 3.5
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(nmax)] } {
      if {[info exists conf(bddimages,appariement,nmax)]} {
         set ::bdi_tools_appariement::calibwcs_param(nmax) $conf(bddimages,appariement,nmax)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(nmax) 35
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(flux_criterion)] } {
      if {[info exists conf(bddimages,appariement,flux_criterion)]} {
         set ::bdi_tools_appariement::calibwcs_param(flux_criterion) $conf(bddimages,appariement,flux_criterion)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(flux_criterion) 0
      }
   }

   # List des cata de reference possibles, a partir de la liste par defaut
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(catalist)] } {
      if {[info exists conf(bddimages,appariement,catalist)]} {
         set ::bdi_tools_appariement::calibwcs_param(catalist) $conf(bddimages,appariement,catalist)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(catalist) [::bdi_tools_appariement::get_default_refcatalist]
      }
   }

   # Parametres externes
   if {[info exists ::bdi_tools_appariement::calibwcs_args]} {
      unset ::bdi_tools_appariement::calibwcs_args
   }

}

#------------------------------------------------------------
## Sauvegarde dans la conf des parametres lies a l'appariement
# @return void
#
proc ::bdi_tools_appariement::closetoconf { } {

   global conf

   set conf(bddimages,appariement,method)         $::bdi_tools_appariement::calibwcs_method 
   set conf(bddimages,appariement,maglimit)       $::bdi_tools_appariement::calibwcs_param(maglimit)
   set conf(bddimages,appariement,refcata)        $::bdi_tools_appariement::calibwcs_param(refcata)
   set conf(bddimages,appariement,delta)          $::bdi_tools_appariement::calibwcs_param(delta)
   set conf(bddimages,appariement,nmax)           $::bdi_tools_appariement::calibwcs_param(nmax)
   set conf(bddimages,appariement,flux_criterion) $::bdi_tools_appariement::calibwcs_param(flux_criterion)
   set conf(bddimages,appariement,catalist)       $::bdi_tools_appariement::calibwcs_param(catalist)

}


#------------------------------------------------------------
## Retourne la liste des cata de reference possibles pour l'appariement
# @return list liste des cata de reference
#
proc ::bdi_tools_appariement::get_default_refcatalist { } {

   global conf

   set refcatalist {}

   if {$conf(bddimages,cata,use_usnoa2) == 1} { lappend refcatalist [list USNOA2 $conf(bddimages,catfolder,usnoa2)] }
   if {$conf(bddimages,cata,use_ucac2)  == 1} { lappend refcatalist [list UCAC2  $conf(bddimages,catfolder,ucac2)]  }
   if {$conf(bddimages,cata,use_ucac3)  == 1} { lappend refcatalist [list UCAC3  $conf(bddimages,catfolder,ucac3)]  }
   if {$conf(bddimages,cata,use_ucac4)  == 1} { lappend refcatalist [list UCAC4  $conf(bddimages,catfolder,ucac4)]  }
   if {$conf(bddimages,cata,use_ppmx)   == 1} { lappend refcatalist [list PPMX   $conf(bddimages,catfolder,ppmx)]   }
   if {$conf(bddimages,cata,use_ppmxl)  == 1} { lappend refcatalist [list PPMXL  $conf(bddimages,catfolder,ppmxl)]  }
   if {$conf(bddimages,cata,use_tycho2) == 1} { lappend refcatalist [list TYCHO2 $conf(bddimages,catfolder,tycho2)] }
   if {$conf(bddimages,cata,use_nomad1) == 1} { lappend refcatalist [list NOMAD1 $conf(bddimages,catfolder,nomad1)] }
   if {$conf(bddimages,cata,use_2mass)  == 1} { lappend refcatalist [list 2MASS  $conf(bddimages,catfolder,2mass)]  }
   if {$conf(bddimages,cata,use_wfibc)  == 1} { lappend refcatalist [list WFIBC  $conf(bddimages,catfolder,wfibc)]  }

   # Raffraichissement de la liste combo
   if {[info exists ::bdi_tools_appariement::combo_catalist]} {
      $::bdi_tools_appariement::combo_catalist configure -values [::bdi_tools_appariement::get_combo_catalist]
   }

   return $refcatalist

}


#------------------------------------------------------------
## Met a jour la liste courante des cata de reference (calibwcs_param(catalist)) pour la methode d'appariement,
#  et met a jour la liste combo des cata
# @return void
#
proc ::bdi_tools_appariement::update_current_refcatalist { {cata ""} {use 0} {dir ""} } {

   if {[info exists ::bdi_tools_appariement::calibwcs_param(catalist)]} {
      set refcatalist $::bdi_tools_appariement::calibwcs_param(catalist)
   } else {
      set refcatalist {}
   }

   set k 0
   set catakey -1
   foreach c $refcatalist {
      if {[string toupper [lindex $c 0]] == [string toupper $cata]} {
         set catakey $k
      }
      incr k
   }

   if {$catakey > -1} {
      if {$use == 0} {
         set refcatalist [lreplace $refcatalist $catakey $catakey]
         if {$::bdi_tools_appariement::calibwcs_param(refcata) == [string toupper $cata]} {
            set ::bdi_tools_appariement::calibwcs_param(refcata) "?"
         }
      }
   } else {
      if {$use == 1} {
         lappend refcatalist [list [string toupper $cata] $dir]
      }
   }

   set ::bdi_tools_appariement::calibwcs_param(catalist) $refcatalist

   # Raffraichissement de la liste combo
   if {[info exists ::bdi_tools_appariement::combo_catalist]} {
      $::bdi_tools_appariement::combo_catalist configure -values [::bdi_tools_appariement::get_combo_catalist]
   }

}


#------------------------------------------------------------
## Retourne la liste combo des cata de reference pour l'appriement (affichee par la GUI)
# @return list vide ou liste de cata de reference possibles
#
proc ::bdi_tools_appariement::get_combo_catalist { } {

   if {[info exists ::bdi_tools_appariement::combo_catalist]} {
      set combolist {}
      foreach c $::bdi_tools_appariement::calibwcs_param(catalist) {
         lappend combolist [lindex $c 0]
      }
      return $combolist
   }
   return {}

}


#------------------------------------------------------------
## Retourne le nom du repertoire d'un cata de reference de l'appariement a partir de son nom
# @param cata string Nom du cata
# @return string repertoire du cata
#
proc ::bdi_tools_appariement::get_refcatadir { cata } {

   set catadir "?"
   if {[info exists ::bdi_tools_appariement::calibwcs_param(catalist)]} {
      foreach c $::bdi_tools_appariement::calibwcs_param(catalist) {
         if {[string toupper [lindex $c 0]] == [string toupper $cata]} {
            set catadir [lindex $c 1]
         }
      }
   }

   return $catadir

}


#------------------------------------------------------------
## Retourne la commande calibwcs a executer pour effectuer l'appariement
# @return string commande calibwcs a executer
#
proc ::bdi_tools_appariement::get_calibwcs_cmde { } {

   set cmde ""

   if {! [info exists ::bdi_tools_appariement::calibwcs_args] || [string length $::bdi_tools_appariement::calibwcs_args] < 1} {
      set msg "bdi_tools_appariement: no user argument defined for calibwcs method. Set them through ::bdi_tools_appariement::calibwcs_args variable"
      return -code 1 $msg
   }

   switch $::bdi_tools_appariement::calibwcs_method {
      1 {
         set calibwcs_method "calibwcs_new"
         set calibwcs_args $::bdi_tools_appariement::calibwcs_args
         set calibwcs_cata $::bdi_tools_appariement::calibwcs_param(refcata)
         set calibwcs_catadir [::bdi_tools_appariement::get_refcatadir $::bdi_tools_appariement::calibwcs_param(refcata)]
         set calibwcs_options "$::bdi_tools_appariement::calibwcs_param(delta) $::bdi_tools_appariement::calibwcs_param(nmax) $::bdi_tools_appariement::calibwcs_param(flux_criterion) -del_tmp_files 0 -yes_visu 0"
      }
      default {
         set calibwcs_method "calibwcs"
         set calibwcs_args $::bdi_tools_appariement::calibwcs_args
         set calibwcs_cata "USNO"
         set calibwcs_catadir $::tools_cata::catalog_usnoa2
         set calibwcs_options "-del_tmp_files 0 -yes_visu 0"
         if {[string length $::bdi_tools_appariement::calibwcs_param(maglimit)] > 0} {
            append calibwcs_options " -maglimit $::bdi_tools_appariement::calibwcs_param(maglimit)"
         }
      }
   }

   return -code 0 "$calibwcs_method $calibwcs_args $calibwcs_cata $calibwcs_catadir $calibwcs_options"

}


#------------------------------------------------------------
## Affichage de la GUI de choix de la methode d'appariement et de ses parametres
# @param frm id du frame dans lequel la GUI est packee
# @return void
#
proc ::bdi_tools_appariement::gui { frm } {

   set calib1 [frame $frm.m1 -borderwidth 0 -cursor arrow]
   pack $calib1 -in $frm -anchor w -side top -expand 0 -fill x -padx 5 -pady 5

      radiobutton $calib1.r -text "calibwcs" -width 12 -value 0 -variable ::bdi_tools_appariement::calibwcs_method -command "" -highlightthickness 0 -anchor w
      pack $calib1.r -in $calib1 -anchor s -side left -expand 0 -fill x -padx 5 -pady 5

      frame $calib1.f -borderwidth 1 -cursor arrow -relief groove
      pack $calib1.f -in $calib1 -anchor s -side left -expand 0 -fill x -padx 5 -pady 5 

         label $calib1.f.lab -text "Mag. limit : " -width 12 -anchor e
         pack $calib1.f.lab -in $calib1.f -side left -padx 5 -pady 5
         entry $calib1.f.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(maglimit) -width 5
         pack $calib1.f.val -in $calib1.f -side left -padx 5 -pady 5

   set calib2 [frame $frm.m2 -borderwidth 1 -cursor arrow]
   pack $calib2 -in $frm -anchor n -side top -expand 0 -fill x -padx 5 -pady 5

      radiobutton $calib2.r -text "calibwcs new" -width 12 -value 1 -variable ::bdi_tools_appariement::calibwcs_method -command "" -highlightthickness 0 -anchor w
      pack $calib2.r -in $calib2 -anchor w -side left -expand 0 -fill x -padx 5 -pady 5

      frame $calib2.f -borderwidth 1 -cursor arrow -relief groove 
      pack $calib2.f -in $calib2 -anchor s -side left -expand 0 -fill x -padx 5 -pady 5

         frame $calib2.f.1
         pack $calib2.f.1 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.1.lab -text "Ref. cata: " -width 12 -anchor e
            pack $calib2.f.1.lab -in $calib2.f.1 -side left -padx 5 -pady 5
            set ::bdi_tools_appariement::combo_catalist [ComboBox $calib2.f.1.combo -height 3 -relief sunken -borderwidth 1 -editable 0 \
               -textvariable ::bdi_tools_appariement::calibwcs_param(refcata) -values [::bdi_tools_appariement::get_combo_catalist]]
            pack $::bdi_tools_appariement::combo_catalist -in $calib2.f.1 -side left -padx 5 -pady 5 -expand 0

         frame $calib2.f.2
         pack $calib2.f.2 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.2.lab -text "Delta: " -width 12 -anchor e
            pack $calib2.f.2.lab -in $calib2.f.2 -side left -padx 5 -pady 5
            entry $calib2.f.2.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(delta) -width 5
            pack $calib2.f.2.val -in $calib2.f.2 -side left -padx 5 -pady 5

         frame $calib2.f.3
         pack $calib2.f.3 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.3.lab -text "nmax: " -width 12 -anchor e
            pack $calib2.f.3.lab -in $calib2.f.3 -side left -padx 5 -pady 5
            entry $calib2.f.3.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(nmax) -width 5
            pack $calib2.f.3.val -in $calib2.f.3 -side left -padx 5 -pady 5

         frame $calib2.f.4
         pack $calib2.f.4 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.4.lab -text "flux_criterion: " -width 12 -anchor e
            pack $calib2.f.4.lab -in $calib2.f.4 -side left -padx 5 -pady 5
            entry $calib2.f.4.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(flux_criterion) -width 5
            pack $calib2.f.4.val -in $calib2.f.4 -side left -padx 5 -pady 5

   # Initialisation de la combolist des cata
   ::bdi_tools_appariement::update_current_refcatalist

}
