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

           #--- Cree un frame pour afficher les resultats
           frame $This.frame1.status \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.status \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status
           label $This.frame1.statusbdd -font $acqvideolinuxconf(font,arial_12_b) \
                -text "$caption(acqvideolinux_extraction,label_bdd)"
           pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.status.l -borderwidth 0]
             pack $intitle -in $This.frame1.status -side left

               #--- Cree un label pour le status
               label $intitle.ok -font $acqvideolinuxconf(font,courier_10) -padx 3 \
                     -text "$caption(acqvideolinux_extraction,label_connect)"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb d image
               label $intitle.requetes -font $acqvideolinuxconf(font,courier_10) \
                     -text "$caption(acqvideolinux_extraction,label_nbrequetes)"
               pack $intitle.requetes -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $intitle.scenes -font $acqvideolinuxconf(font,courier_10) \
                     -text "$caption(acqvideolinux_extraction,label_nbscenes)"
               pack $intitle.scenes -in $intitle -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.status.v -borderwidth 0]
             pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.ok \
                     -text $status -fg $color(green)
               if {$errconn != 0} { $inparam.ok configure -fg $color(red) }
               pack $inparam.ok -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb image
               label $inparam.requetes   \
                     -text $nbrequetes -fg $color(blue)
               pack $inparam.requetes -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $inparam.scenes   \
                     -text $nbscenes -fg $color(blue)
               pack $inparam.scenes -in $inparam -side top -pady 1 -anchor w


           #--- Cree un frame pour le status des repertoires
           frame $This.frame1.rep \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.rep \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status des repertoires
           label $This.frame1.statusrep -font $acqvideolinuxconf(font,arial_12_b) \
                -text "$caption(acqvideolinux_extraction,label_rep)"
           pack $This.frame1.statusrep -in $This.frame1.rep -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.rep.l -borderwidth 0]
             pack $intitle -in $This.frame1.rep -side left

               #--- Cree un label pour le status
               label $intitle.tconnect -font $acqvideolinuxconf(font,courier_10) \
                     -text "$caption(acqvideolinux_extraction,label_tconnect)" -anchor center
               pack $intitle.tconnect -in $intitle -side top -padx 3 -pady 1 -anchor center


             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.rep.v -borderwidth 0]
             pack $inparam -in $This.frame1.rep -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.tconnect  \
                     -text $tconnect -fg $color(green)
               #if {$nbfichbdd != $nbimg} { $inparam.nbimgrep configure -fg $color(red) }
               pack $inparam.tconnect -in $inparam -side top -pady 1 -anchor w



         #--- Cree un frame pour y mettre les boutons
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

           #--- Creation du bouton Connect
           button $This.frame11.but_connect \
              -text "$caption(acqvideolinux_extraction,verif)" -borderwidth 2 \
              -command { ::acqvideolinux_extraction::verif }
           pack $This.frame11.but_connect \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton RAZ
           button $This.frame11.but_raz \
              -text "$caption(acqvideolinux_extraction,raz)" -borderwidth 2 \
              -command { }
           pack $This.frame11.but_raz \
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

}
