#--------------------------------------------------
# source audace/plugin/tool/acqvideolinux/acqvideolinux_extraction.tcl
#--------------------------------------------------
#
# Fichier        : acqvideolinux_extraction.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: acqvideolinux_extraction.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval acqvideolinux_extraction {

   global audace
   global acqvideolinuxconf

   #--- Chargement des captions

   #
   # acqvideolinux_extraction::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      return
   }

   #
   # acqvideolinux_extraction::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      avi1 close

      ::acqvideolinux_extraction::recup_position
      destroy $This
      return
   }

   #
   # acqvideolinux_extraction::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
   #
   proc recup_position { } {
      variable This
      global audace
      global conf
      global acqvideolinuxconf

      set acqvideolinuxconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $acqvideolinuxconf(geometry_status) ] ]
      set fin [ string length $acqvideolinuxconf(geometry_status) ]
      set acqvideolinuxconf(position_status) "+[ string range $acqvideolinuxconf(geometry_status) $deb $fin ]"
      #---
      set conf(acqvideolinux,position_status) $acqvideolinuxconf(position_status)
   }


   #
   # acqvideolinux_extraction::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global acqvideolinuxconf

      #--- initConf
      if { ! [ info exists conf(acqvideolinux,position_status) ] } { set conf(acqvideolinux,position_status) "+80+40" }

      #--- confToWidget
      set acqvideolinuxconf(position_status) $conf(acqvideolinux,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         #--- Gestion du bouton
         #$audace(base).acqvideolinux.fra5.but1 configure -relief raised -state normal
         return
      }

      #---
      if { [ info exists acqvideolinuxconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $acqvideolinuxconf(geometry_status) ] ]
         set fin [ string length $acqvideolinuxconf(geometry_status) ]
         set acqvideolinuxconf(position_status) "+[ string range $acqvideolinuxconf(geometry_status) $deb $fin ]"
      }

      #--- Lancement
      ::console::affiche_resultat "---------------------------\n"
      ::console::affiche_resultat " Extraction\n"
      ::console::affiche_resultat "---------------------------\n"

      set erreur 0

      #--- Gestion des erreurs
      if { $erreur == "0"} {

         #---
         toplevel $This -class Toplevel
         wm geometry $This $acqvideolinuxconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(acqvideolinux_extraction,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::acqvideolinux_extraction::fermer }

         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un label pour le titre
           label $This.frame1.titre -font $acqvideolinuxconf(font,arial_14_b) \
                 -text "$caption(acqvideolinux_extraction,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour 
           frame $This.frame1.open \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.open \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1
           #--- Creation du bouton open
           button $This.frame1.open.but_open \
              -text "open" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::avi_open }
           pack $This.frame1.open.but_open \
              -side left -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton select
           button $This.frame1.open.but_select \
              -text "..." -borderwidth 2 \
              -command { ::acqvideolinux_extraction::avi_select }
           pack $This.frame1.open.but_select \
              -side left -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Cree un label pour le chemin de l'AVI
           entry $This.frame1.open.avipath 
           pack $This.frame1.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

           #--- Creation de la barre de defilement
           scale $This.frame1.percent -from 0 -to 100 -length 600 -variable pc \
              -label Percentage -tickinterval 10 -orient horizontal \
              -state disabled
           pack $This.frame1.percent -in $This.frame1 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

           #--- Cree un frame pour afficher
           set btnav [frame $This.frame1.btnav -borderwidth 0]
           pack $btnav -in $This.frame1 -side top

           #--- Creation du bouton next image
           button $This.frame1.nextimage \
              -text "nextimage" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::avi_next_image  }
           pack $This.frame1.nextimage \
              -in $This.frame1.btnav \
              -side left -anchor w \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton setmin
           button $This.frame1.setmin \
              -text "setmin" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::avi_setmin  }
           pack $This.frame1.setmin \
              -in $This.frame1.btnav \
              -side left -anchor w \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton setmax
           button $This.frame1.setmax \
              -text "setmax" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::avi_setmax  }
           pack $This.frame1.setmax \
              -in $This.frame1.btnav \
              -side left -anchor w \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


           #--- Cree un frame pour 
           frame $This.frame1.pos \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.pos \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

             #--- Cree un frame pour afficher
             frame $This.frame1.pos.min -borderwidth 0
             pack $This.frame1.pos.min -in $This.frame1.pos -side left
               #--- Cree un label pour
               entry $This.frame1.datemin -fg $color(blue) -relief sunken
               pack $This.frame1.datemin -in $This.frame1.pos.min -side top -pady 1 -anchor w
               #--- Cree un label pour
               entry $This.frame1.posmin -fg $color(blue) -relief sunken
               pack $This.frame1.posmin -in $This.frame1.pos.min -side top -pady 1 -anchor w


             #--- Cree un frame pour afficher
             frame $This.frame1.pos.max -borderwidth 0
             pack $This.frame1.pos.max -in $This.frame1.pos -side left
               #--- Cree un label pour
               entry $This.frame1.datemax -fg $color(blue) -relief sunken
               pack $This.frame1.datemax -in $This.frame1.pos.max -side top -pady 1 -anchor w
               #--- Cree un label pour
               entry $This.frame1.posmax -fg $color(blue) -relief sunken
               pack $This.frame1.posmax -in $This.frame1.pos.max -side top -pady 1 -anchor w

             #--- Cree un frame pour afficher
             frame $This.frame1.count -borderwidth 0
             pack $This.frame1.count -in $This.frame1 -side top
               #--- Cree un label pour
               button $This.frame1.doimagecount \
                -text "count" -borderwidth 2 \
                -command { ::acqvideolinux_extraction::avi_imagecount  }
               pack $This.frame1.doimagecount -in $This.frame1.count -side left -pady 1 -anchor w
               #--- Cree un label pour
               entry $This.frame1.imagecount -fg $color(blue) -relief sunken
               pack $This.frame1.imagecount -in $This.frame1.count -side left -pady 1 -anchor w

           #--- Cree un frame pour 
           frame $This.frame1.status \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.status \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour
           #label $This.frame1.statusbdd -font $acqvideolinuxconf(font,arial_12_b) \
           #     -text "LBL $caption(acqvideolinux_extraction,label_bdd)"
           #pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w


             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.status.l -borderwidth 0]
             pack $intitle -in $This.frame1.status -side left

               #--- Cree un label pour le status
               label $intitle.ok -font $acqvideolinuxconf(font,courier_10) -padx 3 \
                     -text "repertoire destination"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb d image
               label $intitle.requetes -font $acqvideolinuxconf(font,courier_10) \
                     -text "prefixe des fichiers"
               pack $intitle.requetes -in $intitle -side top -padx 3 -pady 1 -anchor w


             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.status.v -borderwidth 0]
             pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

               #--- Cree un label pour le nb image
               entry $inparam.requetes -fg $color(blue)
               pack $inparam.requetes -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               entry $inparam.scenes  -fg $color(blue)
               pack $inparam.scenes -in $inparam -side top -pady 1 -anchor w


	   #---
           button $This.frame1.extract \
              -text "extract" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::avi_extract }
           pack $This.frame1.extract \
              -side left -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Cree un frame pour le status des repertoires
           frame $This.frame1.rep \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.rep \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1


         #--- Cree un frame pour y mettre la barre de defilement et les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(acqvideolinux_extraction,fermer)" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(acqvideolinux_extraction,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool acqvideolinux acqvideolinux.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      } else {

         tk_messageBox -title $caption(acqvideolinux_extraction,msg_erreur) -type ok -message $caption(acqvideolinux_extraction,msg_prevent2)
         #$audace(base).acqvideolinux.fra5.but1 configure -relief raised -state normal
         return

      }

      #--- Gestion du bouton
      #$audace(base).acqvideolinux.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

   }

   # acqvideolinux_extraction::list_diff_shift
   # Retourne la liste test epurée de l intersection des deux listes
   proc list_diff_shift { ref test }  {
      foreach elemref $ref {
         set new_test ""
         foreach elemtest $test {
            if {$elemref!=$elemtest} {lappend new_test $elemtest}
         }
         set test $new_test
      }
      return $test
   }

   # acqvideolinux_extraction::verif
   # Verification des donnees
   proc verif { } {
   
   
   }

   proc avi_select { } {
	   global audace
	   variable This
	   set visuNo 1
	   set bufNo [ visu$visuNo buf ]
	   #--- Fenetre parent
	   set fenetre [::confVisu::getBase $visuNo]
	   #--- Ouvre la fenetre de choix des images
	   set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $bufNo "1" $visuNo ]
	   $This.frame1.open.avipath delete 0 end
	   $This.frame1.open.avipath insert 0 $filename
   }

   proc avi_open { } {
	   global audace
	   variable This
	   set visuNo 1
	   set bufNo [ visu$visuNo buf ]
	   #--- Fenetre parent
	   set fenetre [::confVisu::getBase $visuNo]
	   set filename [$This.frame1.open.avipath get]
	   ::avi::create avi1
	   avi1 load $filename
	   avi1 next
           visu$visuNo disp
	   $This.frame1.percent configure -command "::acqvideolinux_extraction::avi_seek"
	   $This.frame1.percent configure -state normal
   }


   proc avi_next_image { } {
	   set visuNo 1
	   avi1 next
	   visu$visuNo disp
   }

   proc avi_seek { arg } {
           set visuNo 1
           puts [expr $arg / 100.0 ]
           avi1 seekpercent [expr $arg / 100.0 ]
           avi1 next
           visu$visuNo disp

   }

   proc avi_seekbyte { arg } {
           set visuNo 1
           puts $arg
           avi1 seekbyte $arg
           avi1 next
           visu$visuNo disp
   }

   proc avi_setmin { } {
	   global audace
	   variable This
	   $This.frame1.posmin delete 0 end
	   $This.frame1.posmin insert 0 [ avi1 getpreviousoffset ]
   }

   proc avi_setmax { } {
	   global audace
	   variable This
	   $This.frame1.posmax delete 0 end
	   $This.frame1.posmax insert 0 [ avi1 getpreviousoffset ]
   }

   proc avi_imagecount { } {
	   global audace
	   variable This
	   $This.frame1.imagecount delete 0 end
	   $This.frame1.imagecount insert 0 [ avi1 count [ $This.frame1.posmin get ] [ $This.frame1.posmax get]]

   }

   proc avi_extract { } {
	   global audace
	   variable This
	   set visuNo 1
	   set bufNo [ visu$visuNo buf ]

	   set bytemin [ $This.frame1.posmin get ]
	   set bytemax [ $This.frame1.posmax get ]
	   set rep [  $This.frame1.status.v.requetes get ]
	   set prefix [ $This.frame1.status.v.scenes get ]
	   set i 0

	   avi_seekbyte $bytemin
	   avi_next_image
	   while { 1 } {
		   incr i
		   puts $i
		   set fn "$rep/$prefix$i"
		   puts $fn
		   buf$bufNo save $fn fits
	           if { [avi1 getoffset] >= $bytemax } { break }
		   avi1 next
	   }
	   visu$visuNo disp
   }


}
