#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_tools.tcl
#--------------------------------------------------
#
# Fichier        : av4l_tools.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#

namespace eval ::av4l_tools {

   variable nb_frames
   variable nb_open_frames
   variable cur_idframe
   variable frame_begin
   variable frame_end


   variable scrollbar

   variable traitement

   variable avi_filename
   variable fits_dir
   variable fits_genericname

   set nb_frames 0

   #
   # av4l_tools::open_flux
   # ouvre un flux
   #
   proc ::av4l_tools::open_flux { visuNo frm } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::open_flux $visuNo $frm
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::open_flux $visuNo $frm
      }

      catch {
         $frm.status.v.status  configure -text "Loaded"
         $frm.status.v.nbtotal configure -text $::av4l_tools::nb_frames
      }

      set bufNo [ visu$visuNo buf ]
      if { [buf$bufNo imageready] == 1 } {
            set autocuts [buf$bufNo autocuts]
            visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
      }

      set ::av4l_tools::scrollbar 1
      $frm.scrollbar configure -from 1
      $frm.scrollbar configure -to $::av4l_tools::nb_frames
      $frm.scrollbar configure -tickinterval [expr $::av4l_tools::nb_frames / 5]
      $frm.scrollbar configure -command "::av4l_tools::slide $visuNo"
      $frm.scrollbar configure -state normal
      $frm.scrollbar configure -variable ::av4l_tools::scrollbar

   }





   #
   # av4l_tools::select
   # Selectionne le ou les fichiers a ouvrir
   #
   proc ::av4l_tools::select { visuNo frm } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::select $visuNo $frm
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::select $visuNo $frm
         ::av4l_tools::open_flux $visuNo $frm
      }

   }





   #
   # av4l_tools::quick_prev_image
   # Retour Rapide
   #
   proc ::av4l_tools::quick_prev_image { visuNo } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::quick_prev_image $visuNo
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::quick_prev_image
      }

      visu$visuNo disp
      set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe

   }





   #
   # av4l_tools::quick_next_image
   # avance rapide
   #
   proc ::av4l_tools::quick_next_image { visuNo } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::quick_next_image $visuNo
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::quick_next_image
      }

      visu$visuNo disp
      set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe

   }





   #
   # av4l_tools::next_image
   # Passe a l image suivante
   #
   proc ::av4l_tools::next_image { visuNo } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::next_image $visuNo
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::next_image
      }

      visu$visuNo disp
      set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe

   }





   #
   # av4l_tools::prev_image
   # Passe a l image precedente
   #
   proc ::av4l_tools::prev_image { visuNo } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::prev_image $visuNo
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::prev_image
      }

      visu$visuNo disp
      set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe

   }



   #
   # se positionne a la l image $idframe
   #
   proc ::av4l_tools::set_frame { visuNo idframe } {

      if { $::av4l_tools::traitement=="fits" } {
         ::av4l_tools_fits::set_frame $visuNo $idframe
      }

      if { $::av4l_tools::traitement=="avi" }  {
         ::av4l_tools_avi::set_frame $idframe
      }

      visu$visuNo disp
      set ::av4l_tools::scrollbar [expr int($::av4l_tools::cur_idframe)]

   }



   #
   # selection du frame de debut
   #
   proc ::av4l_tools::setmin { frm } {

      $frm.posmin delete 0 end
      $frm.posmin insert 0 [expr int($::av4l_tools::cur_idframe)]

   }

   #
   # selection du frame de fin
   #
   proc ::av4l_tools::setmax { frm } {

      $frm.posmax delete 0 end
      $frm.posmax insert 0 [expr int($::av4l_tools::cur_idframe)]

   }

   #
   # redimensionne le flux entre la valeur min et max
   #
   proc ::av4l_tools::crop { visuNo frm } {

      set fmin  [$frm.posmin get]
      set fmax  [$frm.posmax get]

      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::av4l_tools::nb_open_frames
      }
      set ::av4l_tools::nb_frames   [expr int($fmax-$fmin+1)]
      set ::av4l_tools::frame_begin $fmin
      set ::av4l_tools::frame_end   $fmax
      set ::av4l_tools::cur_idframe $fmin
      ::console::affiche_resultat "CROP! \n"
      ::console::affiche_resultat "cur_idframe  $::av4l_tools::cur_idframe \n"
      ::console::affiche_resultat "frame_begin  $::av4l_tools::frame_begin \n"
      ::console::affiche_resultat "frame_end    $::av4l_tools::frame_end   \n"
      ::console::affiche_resultat "nb_frames    $::av4l_tools::nb_frames   \n"

      $frm.scrollbar configure -from $fmin
      $frm.scrollbar configure -to $fmax
      $frm.scrollbar configure -tickinterval [expr $::av4l_tools::nb_frames / 5]

      ::av4l_tools::set_frame $visuNo $fmin

   }







   #
   # redimensionne le flux entre la valeur min et max
   #
   proc ::av4l_tools::uncrop { visuNo frm } {

      set fmin  1
      set fmax  $::av4l_tools::nb_open_frames

      set ::av4l_tools::nb_frames   [expr int($fmax-$fmin+1)]
      set ::av4l_tools::frame_begin $fmin
      set ::av4l_tools::frame_end   $fmax
      set ::av4l_tools::cur_idframe $fmin

      $frm.scrollbar configure -from $fmin
      $frm.scrollbar configure -to $fmax
      $frm.scrollbar configure -tickinterval [expr $::av4l_tools::nb_frames / 5]
      $frm.posmin delete 0 end
      $frm.posmin insert 0 ""
      $frm.posmax delete 0 end
      $frm.posmax insert 0 ""

      visu$visuNo disp
      set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe
   }














   #
   # av4l_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::av4l_tools::slide { visuNo idframe } {
      #::console::affiche_resultat "idframe  : $idframe"
      ::av4l_tools::set_frame $visuNo [expr int($idframe)]
   }












   #
   # av4l_acq::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc ::av4l_tools::chgdir { This } {
      global caption
      global cwdWindow
      global audace

      #--- Initialisation des variables a 2 (0 et 1 reservees a Configuration --> Repertoires)
      set cwdWindow(rep_images)      "2"
      set cwdWindow(rep_travail)     "2"
      set cwdWindow(rep_scripts)     "2"
      set cwdWindow(rep_catalogues)  "2"
      set cwdWindow(rep_userCatalog) "2"
      set cwdWindow(rep_archives)    "2"

      set parent "$audace(base)"
      set title "Choisir un repertoire de destination"
      set rep "$audace(rep_images)"

      set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep" $title $This ]" } msg ]
      if { $numerror == "1" } {
         set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $This ]"
      }

      ::console::affiche_resultat $audace(rep_images)

      $This delete 0 end
      $This insert 0 $filename

   }

}

