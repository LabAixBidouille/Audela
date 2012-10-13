#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_tools.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_tools.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_tools.tcl 8110 2012-02-16 21:20:04Z fredvachier $
#


namespace eval ::atos_tools {

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
   # atos_tools::open_flux
   # ouvre un flux
   #
   proc ::atos_tools::open_flux { visuNo frm } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::open_flux $visuNo $frm
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::open_flux $visuNo $frm
      }

      catch {
         $frm.status.v.status  configure -text "Loaded"
         $frm.status.v.nbtotal configure -text $::atos_tools::nb_frames
      }

      set bufNo [ visu$visuNo buf ]
      if { [buf$bufNo imageready] == 1 } {
            set autocuts [buf$bufNo autocuts]
            visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
      }

      set ::atos_tools::scrollbar 1
      $frm.scrollbar configure -from 1
      $frm.scrollbar configure -to $::atos_tools::nb_frames
      $frm.scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]
      $frm.scrollbar configure -command "::atos_tools::slide $visuNo"
      $frm.scrollbar configure -state normal
      $frm.scrollbar configure -variable ::atos_tools::scrollbar

   }





   #
   # atos_tools::select
   # Selectionne le ou les fichiers a ouvrir
   #
   proc ::atos_tools::select { visuNo frm } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::select $visuNo $frm
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::select $visuNo $frm
         ::atos_tools::open_flux $visuNo $frm
      }

   }





   #
   # atos_tools::quick_prev_image
   # Retour Rapide
   #
   proc ::atos_tools::quick_prev_image { visuNo } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::quick_prev_image $visuNo
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::quick_prev_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }





   #
   # atos_tools::quick_next_image
   # avance rapide
   #
   proc ::atos_tools::quick_next_image { visuNo } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::quick_next_image $visuNo
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::quick_next_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }





   #
   # atos_tools::next_image
   # Passe a l image suivante
   #
   proc ::atos_tools::next_image { visuNo } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::next_image $visuNo
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::next_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }





   #
   # atos_tools::prev_image
   # Passe a l image precedente
   #
   proc ::atos_tools::prev_image { visuNo } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::prev_image $visuNo
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::prev_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }



   #
   # se positionne a la l image $idframe
   #
   proc ::atos_tools::set_frame { visuNo idframe } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::set_frame $visuNo $idframe
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::set_frame $idframe
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar [expr int($::atos_tools::cur_idframe)]

   }



   #
   # selection du frame de debut
   #
   proc ::atos_tools::setmin { frm } {

      $frm.posmin delete 0 end
      $frm.posmin insert 0 [expr int($::atos_tools::cur_idframe)]

   }

   #
   # selection du frame de fin
   #
   proc ::atos_tools::setmax { frm } {

      $frm.posmax delete 0 end
      $frm.posmax insert 0 [expr int($::atos_tools::cur_idframe)]

   }

   #
   # redimensionne le flux entre la valeur min et max
   #
   proc ::atos_tools::crop { visuNo frm } {

      set fmin  [$frm.posmin get]
      set fmax  [$frm.posmax get]

      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::atos_tools::nb_open_frames
      }
      set ::atos_tools::nb_frames   [expr int($fmax-$fmin+1)]
      set ::atos_tools::frame_begin $fmin
      set ::atos_tools::frame_end   $fmax
      set ::atos_tools::cur_idframe $fmin
      ::console::affiche_resultat "CROP! \n"
      ::console::affiche_resultat "cur_idframe  $::atos_tools::cur_idframe \n"
      ::console::affiche_resultat "frame_begin  $::atos_tools::frame_begin \n"
      ::console::affiche_resultat "frame_end    $::atos_tools::frame_end   \n"
      ::console::affiche_resultat "nb_frames    $::atos_tools::nb_frames   \n"

      $frm.scrollbar configure -from $fmin
      $frm.scrollbar configure -to $fmax
      $frm.scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]

      ::atos_tools::set_frame $visuNo $fmin

   }







   #
   # redimensionne le flux entre la valeur min et max
   #
   proc ::atos_tools::uncrop { visuNo frm } {

      set fmin  1
      set fmax  $::atos_tools::nb_open_frames

      set ::atos_tools::nb_frames   [expr int($fmax-$fmin+1)]
      set ::atos_tools::frame_begin $fmin
      set ::atos_tools::frame_end   $fmax
      set ::atos_tools::cur_idframe $fmin

      $frm.scrollbar configure -from $fmin
      $frm.scrollbar configure -to $fmax
      $frm.scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]
      $frm.posmin delete 0 end
      $frm.posmin insert 0 ""
      $frm.posmax delete 0 end
      $frm.posmax insert 0 ""

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe
   }














   #
   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::atos_tools::slide { visuNo idframe } {
      #::console::affiche_resultat "idframe  : $idframe"
      ::atos_tools::set_frame $visuNo [expr int($idframe)]
   }












   #
   # atos_acq::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc ::atos_tools::chgdir { This } {
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

