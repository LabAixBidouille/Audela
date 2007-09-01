#
# Fichier : obj_lune.tcl
# Description : Outil dedie a la Lune, avec Goto vers un site choisi, ephemerides et cartographie
# Auteur : Robert DELMAS
# Mise a jour $Id: obj_lune.tcl,v 1.9 2007-09-01 12:24:09 robertdelmas Exp $
#

global audace

#--- Chargement du programme de calcul (ephemerides, etc.)
source [ file join $audace(rep_plugin) tool obj_lune obj_lune_1.tcl ]

#--- Chargement du programme pour la partie graphique de l'outil Objectif Lune
source [ file join $audace(rep_plugin) tool obj_lune obj_lune_2.tcl ]

namespace eval obj_lune {
   global audace

   #--- Chargement des legendes et des textes pour differentes langues
   source [ file join $audace(rep_plugin) tool obj_lune obj_lune.cap ]
   source [ file join $audace(rep_plugin) tool obj_lune obj_lune_1.cap ]
   source [ file join $audace(rep_plugin) tool obj_lune obj_lune_2.cap ]

   #
   # obj_lune::run
   # Cree la fenetre de choix des onglets
   # This = chemin de la fenetre
   #
   proc run { } {
      variable This
      global audace
      global obj_lune

      set This "$audace(base).obj_lune"
      createDialog
      catch { tkwait visibility $This }
   }

   #
   # obj_lune::goto_lune
   # Fonction appellee lors de l'appui sur le bouton 'GOTO' pour realiser le GOTO du telescope
   # sur le site lunaire choisi
   #
   proc goto_lune { } {
      variable This
      global audace
      global obj_lune
      global conf

      #--- Gestion des boutons actifs/inactifs
      $This.cmd.goto configure -relief groove -state disabled
      $This.cmd.match configure -relief raised -state disabled
      $This.cmd.aide configure -relief raised -state disabled
      $This.cmd.fermer configure -relief raised -state disabled
      update
      #--- Gestion des differents telescopes goto
      ::telescope::goto [list $obj_lune(ad_site) $obj_lune(dec_site)] "0" $This.cmd.goto $This.cmd.match
      #--- Gestion des boutons actifs/inactifs
      $This.cmd.goto configure -relief raised -state normal
      $This.cmd.match configure -relief raised -state normal
      $This.cmd.aide configure -relief raised -state normal
      $This.cmd.fermer configure -relief raised -state normal
      update
      catch {
         ::telescope::afficheCoord
      }
   }

   #
   # obj_lune::match_lune
   # Fonction appellee lors de l'appui sur le bouton 'Match' pour realiser le Match du telescope sur
   # le site lunaire choisi
   #
   proc match_lune { } {
      variable This
      global audace
      global obj_lune
      global caption

      #--- Gestion des boutons actifs/inactifs
      $This.cmd.goto configure -relief raised -state disabled
      $This.cmd.match configure -relief groove -state disabled
      $This.cmd.aide configure -relief raised -state disabled
      $This.cmd.fermer configure -relief raised -state disabled
      update
      #--- Gestion des differents telescopes goto
      if {[::tel::list]!=""} {
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(obj_lune,match)" \
            -message "$caption(obj_lune,match_confirm)" ]
         if { $choix == "yes" } {
            tel$audace(telNo) radec init [list $obj_lune(ad_site) $obj_lune(dec_site)]
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
      #--- Gestion des boutons actifs/inactifs
      $This.cmd.goto configure -relief raised -state normal
      $This.cmd.match configure -relief raised -state normal
      $This.cmd.aide configure -relief raised -state normal
      $This.cmd.fermer configure -relief raised -state normal
      update
      catch {
         ::telescope::afficheCoord
      }
   }

   #
   # obj_lune::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This
      global conf
      global obj_lune

      #--- Recuperation de la position et de la dimension de la fenetre
      set conf(obj_lune,wmgeometry) [ wm geometry $This ]
      #--- Destruction des images specifiques a cet outil
      catch {
         image delete imageflag2a
         image delete imageflag4a
         image delete imageflag4b
         image delete imageflag5a
      }
      #---
      set obj_lune(espion) "1"
      destroy $This
   }

   proc createDialog { } {
      variable This
      global caption
      global conf
      global obj_lune

      #--- Initialisation
      set obj_lune(indice_mois)      "0"
      set obj_lune(rep_cartes)       "atlas_obj_lune"
      set obj_lune(extension_cartes) ".jpg"

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.cmd.goto
         return
      }

      toplevel $This
      if { [ info exists conf(obj_lune,wmgeometry) ] == "1" } {
         wm geometry $This $conf(obj_lune,wmgeometry)
      } else {
         wm geometry $This 620x455+10+10
      }
      wm minsize $This 620 455
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(obj_lune,titre)"
      wm protocol $This WM_DELETE_WINDOW ::obj_lune::fermer
      set obj_lune(espion) "0"

      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set nn $This.usr.book
         Rnotebook:create $nn -tabs "{$caption(obj_lune,goto)} {$caption(obj_lune,ephemerides)} \
            {$caption(obj_lune,cartographie)} {$caption(obj_lune,carte_libration)} \
            {$caption(obj_lune,meilleur_moment)}" -borderwidth 1
         fillPage1 $nn
         fillPage2 $nn
         fillPage3 $nn
         fillPage4 $nn
         fillPage5 $nn
         pack $nn -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.goto -text "$caption(obj_lune,goto)" -relief raised -state normal \
            -command { ::obj_lune::goto_lune }
         pack $This.cmd.goto -side left -padx 5 -pady 5 -ipadx 5 -ipady 5
         button $This.cmd.match -text "$caption(obj_lune,match)" -relief raised -state normal \
            -command { ::obj_lune::match_lune }
         pack $This.cmd.match -side left -padx 5 -pady 5 -ipadx 5 -ipady 5
         button $This.cmd.fermer -text "$caption(obj_lune,fermer)" -relief raised -state normal \
            -command { ::obj_lune::fermer }
         pack $This.cmd.fermer -side right -padx 5 -pady 5 -ipadx 5 -ipady 5
         button $This.cmd.aide -text "$caption(obj_lune,aide)" -relief raised -state normal \
            -command { ::audace::showHelpPlugin tool obj_lune obj_lune.htm }
         pack $This.cmd.aide -side right -padx 5 -pady 5 -ipadx 5 -ipady 5
      pack $This.cmd -side top -fill x

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc fillPage1 {nn} {
      variable This
      global audace
      global obj_lune
      global caption
      global zone
      global frmm

      #--- Initialisation
      set frmm(Obj_Lune1) [Rnotebook:frame $nn 1]
      set frm $frmm(Obj_Lune1)

      #--- Creation des differents frames
      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill both -expand 1

      frame $frm.frame0 -borderwidth 0 -relief raised
      pack $frm.frame0 -side left -fill both -expand 1

      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -in $frm.frame0 -side left -fill y -padx 10

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -in $frm.frame0 -side left -fill y

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame0 -side top -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame4 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 1 -relief raised
      pack $frm.frame6 -in $frm.frame5 -side top -fill x

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame4 -side right

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame7 -side bottom -fill both -expand 1

      frame $frm.frame10 -borderwidth 1 -relief raised
      pack $frm.frame10 -in $frm.frame8 -side top -fill x

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame8 -side left -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame8 -side right -fill both -expand 1

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame11 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame11 -side top -fill both -expand 1

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame11 -side left -fill both -expand 1

      frame $frm.frame16 -borderwidth 0 -relief raised
      pack $frm.frame16 -in $frm.frame12 -side top -fill both -expand 1

      frame $frm.frame17 -borderwidth 0 -relief raised
      pack $frm.frame17 -in $frm.frame12 -side top -fill both -expand 1 -padx 20

      frame $frm.frame18 -borderwidth 0 -relief raised
      pack $frm.frame18 -in $frm.frame12 -side right -fill both -expand 1 -padx 20

      #--- Cree l'affichage des differents types de sites lunaires remarquables - Colonne de gauche
      set obj_lune(goto) "23"
      radiobutton $frm.frame1.rad1 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,reference)" -value 1 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad1 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad2 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,crateres)" -value 2 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad2 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad3 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,chaines_crateres)" -value 3 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad3 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad4 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,montagnes_isolees)" -value 4 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad4 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad5 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,chaines_montagnes)" -value 5 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad5 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad6 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,vallees)" -value 6 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad6 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad7 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,rainures)" -value 7 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad7 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad8 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,systemes_rainures)" -value 8 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad8 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad9 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,failles)" -value 9 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad9 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad10 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,dorsales)" -value 10 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad10 -side top -fill x -pady 2
      radiobutton $frm.frame1.rad11 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,systemes_dorsales)" -value 11 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame1.rad11 -side top -fill x -pady 2

      #--- Cree l'affichage des differents types de sites lunaires remarquables - Colonne de droite
      radiobutton $frm.frame2.rad12 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,domes)" -value 12 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad12 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad13 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,caps)" -value 13 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad13 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad14 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,marais)" -value 14 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad14 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad15 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,lacs)" -value 15 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad15 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad16 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,golfes)" -value 16 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad16 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad17 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,mers)" -value 17 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad17 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad18 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,ocean)" -value 18 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad18 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad19 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,plaine_basse)" -value 19 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad19 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad20 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,sites_alunissage)" -value 20 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad20 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad21 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,zone_albedo)" -value 21 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad21 -side top -fill x -pady 2
      radiobutton $frm.frame2.rad22 -anchor nw -width 25 -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(obj_lune,pheno_transitoires)" -value 22 -variable obj_lune(goto) \
         -command { ::obj_lune::affiche_cata_choisi ; obj_lune::AfficheInfoSite }
      pack $frm.frame2.rad22 -side top -fill x -pady 2

      #--- Cree l'affichage des sites lunaires du type choisi
      scrollbar $frm.frame3.scrollbar -orient vertical -command [list $frm.frame3.lb1 yview] -takefocus 1 -borderwidth 1
      pack $frm.frame3.scrollbar -side right -anchor ne -fill both
      listbox $frm.frame3.lb1 -width 24 -height 40 -borderwidth 2 -relief sunken \
         -font $audace(font,listbox) -yscrollcommand [list $frm.frame3.scrollbar set]
      pack $frm.frame3.lb1 -side right -anchor ne -fill both
      set zone(list_site) $frm.frame3.lb1

      #--- Cree l'affichage des origines du nom du site lunaire choisi
      label $frm.frame6.lab1  -text "$caption(obj_lune,origine)"
      pack $frm.frame6.lab1 -side top -fill both -expand 1

      text $frm.frame5.lb1 -width 30 -height 5 -borderwidth 2 -relief sunken \
         -font $audace(font,listbox) -yscrollcommand [list $frm.frame5.scrollbar set] -wrap word
      pack $frm.frame5.lb1 -side left -anchor nw -fill both -expand 1
      scrollbar $frm.frame5.scrollbar -orient vertical -command [list $frm.frame5.lb1 yview] \
         -takefocus 1 -borderwidth 1
      pack $frm.frame5.scrollbar -side left -fill y
      set zone(list_histoire) $frm.frame5.lb1

      #--- Cree l'affichage des caracteristiques du site lunaire choisi
      label $frm.frame10.lab1 -text "$caption(obj_lune,pos_caract)"
      pack $frm.frame10.lab1 -side bottom -fill both -expand 1

      label $frm.frame13.lab2 -text "$caption(obj_lune,latitude)"
      pack $frm.frame13.lab2 -side left -padx 0 -pady 1
      label $frm.frame13.lab2a -text "-"
      pack $frm.frame13.lab2a -side left -padx 0 -pady 1

      label $frm.frame14.lab3 -text "$caption(obj_lune,longitude)"
      pack $frm.frame14.lab3 -side left -padx 0 -pady 1
      label $frm.frame14.lab3a -text "-"
      pack $frm.frame14.lab3a -side left -padx 0 -pady 1

      label $frm.frame15.lab4 -text "$caption(obj_lune,dimension)"
      pack $frm.frame15.lab4 -side left -padx 0 -pady 1
      label $frm.frame15.lab4a -text "-"
      pack $frm.frame15.lab4a -side left -padx 0 -pady 1

      label $frm.frame16.lab5 -text "$caption(obj_lune,objectif)"
      pack $frm.frame16.lab5 -side left -padx 0 -pady 0

      label $frm.frame17.lab6 -text "$caption(obj_lune,ad)"
      pack $frm.frame17.lab6 -side left -padx 0 -pady 1
      label $frm.frame17.lab6a -text "-"
      pack $frm.frame17.lab6a -side left -padx 0 -pady 1

      label $frm.frame18.lab7 -text "$caption(obj_lune,dec)"
      pack $frm.frame18.lab7 -side left -padx 0 -pady 1
      label $frm.frame18.lab7a -text "-"
      pack $frm.frame18.lab7a -side left -padx 0 -pady 1

      label $frm.frame9.lab8 -text "$caption(obj_lune,carte_atlas)"
      pack $frm.frame9.lab8 -side left -padx 0 -pady 1
      label $frm.frame9.labURL8a -text "-"
      pack $frm.frame9.labURL8a -side left -padx 0 -pady 1

      #--- Initialisation du numero de la carte courante
      bind [Rnotebook:button $nn 1] <Button-1> {
         #--- Reaffiche les rectangles bleus uniquement
         ::obj_lune::AfficheRepereSite
         ::obj_lune::AfficheRepereSite_lib
         #--- Efface les numeros des cartes choisies et de la carte courante
         $frmm(Obj_Lune3).frame8.labURL7 configure -text "-"
         $frmm(Obj_Lune4).frame8.labURL7 configure -text "-"
      }

      #--- Selectionne un des 2 onglets de la cartographie
      bind $frm.frame9.labURL8a <ButtonPress-1> {
         for {set i 1} {$i <= 84} {incr i} {
            if { $i <= 76 } {
               if { $obj_lune(n1) == "$i" } {
                  set num_onglet "3"
                  set nn "$This.usr.book"
                  switch -exact -- $num_onglet { 3 { Rnotebook:raise $nn 3 } }
                  if { ($i >= "1") && ($i <= "9") } {
                     set obj_lune(carte_choisie) "ar0$obj_lune(n1)$obj_lune(extension_cartes)"
                  } else {
                     set obj_lune(carte_choisie) "ar$obj_lune(n1)$obj_lune(extension_cartes)"
                  }
                  ::obj_lune::EffaceRectangleBleu_Rouge_Carto
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
                  ::obj_lune::AfficheRepereSite_Bind
               }
            } else {
               if { $obj_lune(lib_n1) == "$i" } {
                  set num_onglet "4"
                  set nn "$This.usr.book"
                  switch -exact -- $num_onglet { 4 { Rnotebook:raise $nn 4 } }
                  set obj_lune(carte_choisie_lib) "lib$obj_lune(lib_n1)$obj_lune(extension_cartes)"
                  ::obj_lune::EffaceRectangleBleu_Rouge_Lib
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
                  ::obj_lune::AfficheRepereSite_lib_Bind
               }
            }
         }
      }
   }

   proc fillPage2 {nn} {
      global obj_lune
      global caption
      global audace
      global frmm

      #--- Initialisation
      set frmm(Obj_Lune2) [Rnotebook:frame $nn 2]
      set frm $frmm(Obj_Lune2)

      #--- Creation des differents frames
      frame $frm.frame0 -borderwidth 0 -relief raised
      pack $frm.frame0 -side left -fill both -expand 1

      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -in $frm.frame0 -anchor n -side left -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -in $frm.frame0 -side left -fill y -expand 0

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame16 -borderwidth 0 -relief raised
      pack $frm.frame16 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame17 -borderwidth 0 -relief raised
      pack $frm.frame17 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame18 -borderwidth 0 -relief raised
      pack $frm.frame18 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame19 -borderwidth 0 -relief raised
      pack $frm.frame19 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame20 -borderwidth 0 -relief raised
      pack $frm.frame20 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame21 -borderwidth 0 -relief raised
      pack $frm.frame21 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame22 -borderwidth 0 -relief raised
      pack $frm.frame22 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame23 -borderwidth 0 -relief flat
      pack $frm.frame23 -in $frm.frame2 -side top

      frame $frm.frame24 -borderwidth 0 -relief raised
      pack $frm.frame24 -in $frm.frame2 -anchor n -side left -fill x

      frame $frm.frame25 -borderwidth 0 -relief raised
      pack $frm.frame25 -in $frm.frame24 -side top -fill both -expand 1 -padx 10

      frame $frm.frame26 -borderwidth 0 -relief raised
      pack $frm.frame26 -in $frm.frame24 -side top -fill both -expand 1 -padx 10

      frame $frm.frame27 -borderwidth 0 -relief raised
      pack $frm.frame27 -in $frm.frame24 -side top -fill both -expand 1 -padx 10

      frame $frm.frame28 -borderwidth 0 -relief raised
      pack $frm.frame28 -in $frm.frame24 -side top -fill both -expand 1 -padx 10

      frame $frm.frame29 -borderwidth 0 -relief raised
      pack $frm.frame29 -in $frm.frame2 -anchor n -side right -fill x

      frame $frm.frame30 -borderwidth 0 -relief raised
      pack $frm.frame30 -in $frm.frame29 -side top -fill both -expand 1

      frame $frm.frame31 -borderwidth 0 -relief raised
      pack $frm.frame31 -in $frm.frame29 -side top -fill both -expand 1

      #--- Cree l'affichage des elements des ephemerides le la Lune
      label $frm.frame3.lab1 -text ""
      pack $frm.frame3.lab1 -side left -padx 0 -pady 0

      label $frm.frame4.lab2 -text "$caption(obj_lune,date)"
      pack $frm.frame4.lab2 -side left -padx 0 -pady 0
      label $frm.frame4.lab2a -textvariable "audace(tu_date,format,dmy)"
      pack $frm.frame4.lab2a -side left -padx 0 -pady 0

      label $frm.frame5.lab3 -text "$caption(obj_lune,heure)"
      pack $frm.frame5.lab3 -side left -padx 0 -pady 0
      label $frm.frame5.lab3a -textvariable "audace(tu,format,hmsint)"
      pack $frm.frame5.lab3a -side left -padx 0 -pady 0

      label $frm.frame6.lab4 -text ""
      pack $frm.frame6.lab4 -side left -padx 0 -pady 0

      label $frm.frame7.lab5 -text "$caption(obj_lune,pos_centre)"
      pack $frm.frame7.lab5 -side left -padx 0 -pady 0

      label $frm.frame8.lab6 -text "$caption(obj_lune,ad)"
      pack $frm.frame8.lab6 -side left -padx 0 -pady 0
      label $frm.frame8.lab6a -textvariable "obj_lune(ad)"
      pack $frm.frame8.lab6a -side left -padx 0 -pady 0

      label $frm.frame9.lab7 -text "$caption(obj_lune,dec)"
      pack $frm.frame9.lab7 -side left -padx 0 -pady 0
      label $frm.frame9.lab7a -textvariable "obj_lune(dec)"
      pack $frm.frame9.lab7a -side left -padx 0 -pady 0

      label $frm.frame10.lab8 \
         -text "                                                                                                "
      pack $frm.frame10.lab8 -side left -padx 0 -pady 0

      label $frm.frame11.lab9 -text "$caption(obj_lune,hauteur)"
      pack $frm.frame11.lab9 -side left -padx 0 -pady 0
      label $frm.frame11.lab9a -textvariable "obj_lune(hauteur)"
      pack $frm.frame11.lab9a -side left -padx 0 -pady 0

      label $frm.frame12.lab10 -text "$caption(obj_lune,azimut)"
      pack $frm.frame12.lab10 -side left -padx 0 -pady 0
      label $frm.frame12.lab10a -textvariable "obj_lune(azimut)"
      pack $frm.frame12.lab10a -side left -padx 0 -pady 0

      label $frm.frame13.lab11 -text "$caption(obj_lune,anglehoraire)"
      pack $frm.frame13.lab11 -side left -padx 0 -pady 0
      label $frm.frame13.lab11a -textvariable "obj_lune(anglehoraire)"
      pack $frm.frame13.lab11a -side left -padx 0 -pady 0

      label $frm.frame14.lab12 -text "$caption(obj_lune,diametre_apparent)"
      pack $frm.frame14.lab12 -side left -padx 0 -pady 0
      label $frm.frame14.lab12a -textvariable "obj_lune(diam_ap)"
      pack $frm.frame14.lab12a -side left -padx 0 -pady 0

      label $frm.frame15.lab13 -text "$caption(obj_lune,magnitude)"
      pack $frm.frame15.lab13 -side left -padx 0 -pady 0
      label $frm.frame15.lab13a -textvariable "obj_lune(mag)"
      pack $frm.frame15.lab13a -side left -padx 0 -pady 0

      label $frm.frame16.lab14 -text "$caption(obj_lune,fraction_eclairee)"
      pack $frm.frame16.lab14 -side left -padx 0 -pady 0
      label $frm.frame16.lab14a -textvariable "obj_lune(fraction_illu_%)"
      pack $frm.frame16.lab14a -side left -padx 0 -pady 0

      label $frm.frame17.lab15 -text "$caption(obj_lune,age)"
      pack $frm.frame17.lab15 -side left -padx 0 -pady 0
      label $frm.frame17.lab15a -textvariable "obj_lune(age_lune)"
      pack $frm.frame17.lab15a -side left -padx 0 -pady 0

      label $frm.frame18.lab16 -text "$caption(obj_lune,distance_terre)"
      pack $frm.frame18.lab16 -side left -padx 0 -pady 0
      label $frm.frame18.lab16a -textvariable "obj_lune(dist_Terre_Lune)"
      pack $frm.frame18.lab16a -side left -padx 0 -pady 0

      label $frm.frame19.lab17 -text "$caption(obj_lune,libration,n_s)"
      pack $frm.frame19.lab17 -side left -padx 0 -pady 0
      label $frm.frame19.lab17a -textvariable "obj_lune(Lib_lat)"
      pack $frm.frame19.lab17a -side left -padx 0 -pady 0

      label $frm.frame20.lab18 -text "$caption(obj_lune,libration,e_o)"
      pack $frm.frame20.lab18 -side left -padx 0 -pady 0
      label $frm.frame20.lab18a -textvariable "obj_lune(Lib_long)"
      pack $frm.frame20.lab18a -side left -padx 0 -pady 0

      label $frm.frame21.lab19 -text "$caption(obj_lune,long_terminateur)"
      pack $frm.frame21.lab19 -side left -padx 0 -pady 0
      label $frm.frame21.lab19a -textvariable "obj_lune(Long_terminateur)"
      pack $frm.frame21.lab19a -side left -padx 0 -pady 0

      label $frm.frame22.lab20 -text ""
      pack $frm.frame22.lab20 -side left -padx 0 -pady 0

      #--- Image de la Lune
      image create photo imageflag2a
      imageflag2a configure -file [file join $audace(rep_plugin) tool obj_lune image_obj_lune lune_photo.gif]

      #--- Creation d'un canvas pour l'affichage de cette image
      canvas $frm.frame23.image2a -width [ expr [image width imageflag2a] - 2 ] \
         -height [ expr [image height imageflag2a] - 2 ] \
         -borderwidth 0 -relief flat
      pack $frm.frame23.image2a -side left -anchor center -padx 0 -pady 0
      set zone(image2a) $frm.frame23.image2a

      #--- Affichage de cette image
      $zone(image2a) create image 0 0 -anchor nw -tag display
      $zone(image2a) itemconfigure display -image imageflag2a

      #--- Cree l'affichage des elements des phases le la Lune
      label $frm.frame25.lab21 -text "$caption(obj_lune,nl)"
      pack $frm.frame25.lab21 -side left -padx 0 -pady 0
      label $frm.frame25.lab21a -textvariable "obj_lune(date_phase_NL)"
      pack $frm.frame25.lab21a -side left -padx 0 -pady 0

      label $frm.frame26.lab22 -text "$caption(obj_lune,pq)"
      pack $frm.frame26.lab22 -side left -padx 0 -pady 0
      label $frm.frame26.lab22a -textvariable "obj_lune(date_phase_PQ)"
      pack $frm.frame26.lab22a -side left -padx 0 -pady 0

      label $frm.frame27.lab23 -text "$caption(obj_lune,pl)"
      pack $frm.frame27.lab23 -side left -padx 0 -pady 0
      label $frm.frame27.lab23a -textvariable "obj_lune(date_phase_PL)"
      pack $frm.frame27.lab23a -side left -padx 0 -pady 0

      label $frm.frame28.lab24 -text "$caption(obj_lune,dq)"
      pack $frm.frame28.lab24 -side left -padx 0 -pady 0
      label $frm.frame28.lab24a -textvariable "obj_lune(date_phase_DQ)"
      pack $frm.frame28.lab24a -side left -padx 0 -pady 0

      button $frm.frame30.plus -text "+" -relief raised -state normal -width 3 \
         -command { set obj_lune(change_mois) "+" ; ::obj_lune::precedant_suivant }
      pack $frm.frame30.plus -side left -padx 12 -pady 8 -fill x

      button $frm.frame31.moins -text "-" -relief raised -state normal -width 3 \
         -command { set obj_lune(change_mois) "-" ; ::obj_lune::precedant_suivant }
      pack $frm.frame31.moins -side left -padx 12 -pady 8 -fill x

      #--- Initialisation du numero de la carte courante
      bind [Rnotebook:button $nn 2] <Button-1> {
         $frmm(Obj_Lune3).frame8.labURL7 configure -text "-"
         $frmm(Obj_Lune4).frame8.labURL7 configure -text "-"
      }

      #--- Calcul et affichage des ephemerides et des dates des phases de la Lune
      ::obj_lune::Lune_Ephemerides
      ::obj_lune::Lune_Phases
   }

   proc fillPage3 {nn} {
      global audace
      global obj_lune
      global caption
      global zone
      global color
      global frmm

      #--- Initialisation
      set frmm(Obj_Lune3) [Rnotebook:frame $nn 3]
      set frm $frmm(Obj_Lune3)

      #--- Creation des differents frames
      frame $frm.frame0 -borderwidth 0 -relief raised
      pack $frm.frame0 -side top -fill both -expand 1

      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -in $frm.frame0 -side left -fill y

      frame $frm.frame2 -width 100 -borderwidth 1 -relief raised
      pack $frm.frame2 -in $frm.frame0 -side right -fill both -expand 1

      frame $frm.frame3 -borderwidth 1 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side top -fill x

      frame $frm.frame4 -borderwidth 1 -relief flat
      pack $frm.frame4 -in $frm.frame1 -side top

      frame $frm.frame5 -height 10 -borderwidth 1 -relief raised
      pack $frm.frame5 -in $frm.frame1 -anchor n -side top -fill x

      frame $frm.frame6 -height 10 -borderwidth 1 -relief raised
      pack $frm.frame6 -in $frm.frame1 -anchor n -side top -fill x

      frame $frm.frame7 -height 10 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame6 -side left -fill both -expand 1

      frame $frm.frame8 -height 10 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame6 -side right -fill both -expand 1

      #--- Image de la Lune avec les numeros des cartes de details
      image create photo imageflag1
      imageflag1 configure -file [file join $audace(rep_plugin) tool obj_lune image_obj_lune lune.gif]

      #--- Creation d'un canvas pour affichage de cette image
      canvas $frm.frame4.image_cartes_lune -width [ expr [image width imageflag1] - 2 ] \
         -height [ expr [image height imageflag1] - 2 ] \
         -cursor circle -borderwidth 0 -relief flat
      pack $frm.frame4.image_cartes_lune -side left -anchor center -padx 0 -pady 0
      set zone(image_cartes_lune) $frm.frame4.image_cartes_lune

      #--- Affichage de cette image
      $zone(image_cartes_lune) create image 0 0 -anchor nw -tag display
      $zone(image_cartes_lune) itemconfigure display -image imageflag1

      #--- Labels pour les cartes
      label $frm.frame3.lab1 -text "$caption(obj_lune,atlas)" -font $audace(font,arial_12_b)
      pack $frm.frame3.lab1 -anchor center -padx 0 -pady 3

      label $frm.frame5.lab2 -text "$caption(obj_lune,carte_choisies)"
      pack $frm.frame5.lab2 -side left -padx 5 -pady 0
      label $frm.frame5.labURL3 -text "-"
      pack $frm.frame5.labURL3 -side left -padx 0 -pady 0

      label $frm.frame7.lab4 -text "$caption(obj_lune,carte_choisie)"
      pack $frm.frame7.lab4 -side left -padx 5 -pady 0
      label $frm.frame7.labURL5 -text "-"
      pack $frm.frame7.labURL5 -side left -padx 0 -pady 0

      label $frm.frame8.lab6 -text "$caption(obj_lune,carte_courante)"
      pack $frm.frame8.lab6 -side left -padx 5 -pady 0
      label $frm.frame8.labURL7 -text "-"
      pack $frm.frame8.labURL7 -side left -padx 0 -pady 0

      #--- Cree le canevas pour l'image
      ::obj_lune::Lune_Scrolled_Canvas $frm.frame2.image1 -borderwidth 0 -relief flat \
         -width 1000 -height 1000 -scrollregion {0 0 0 0} -cursor crosshair
      $frm.frame2.image1.canvas configure -borderwidth 0
      $frm.frame2.image1.canvas configure -relief flat
      pack $frm.frame2.image1 \
         -in $frm.frame2 -expand 1 -side left -anchor center -fill both -padx 0 -pady 0
      set zone(image1) $frm.frame2.image1.canvas

      #--- Creation de l'image de la carte demandee
      image create photo imageflag2

      #--- Affichage du rectangle rouge de la carte courante choisie
      ::obj_lune::AfficheRectangleCarteChoisie

      #--- Initialisation du numero de la carte courante
      bind [Rnotebook:button $nn 3] <Button-1> {
         $frmm(Obj_Lune3).frame8.labURL7 configure -text "-"
         $frmm(Obj_Lune4).frame8.labURL7 configure -text "-"
      }
   }

   proc fillPage4 {nn} {
      global audace
      global obj_lune
      global caption
      global zone
      global color
      global frmm

      #--- Initialisation
      set frmm(Obj_Lune4) [Rnotebook:frame $nn 4]
      set frm $frmm(Obj_Lune4)

      #--- Creation des differents frames
      frame $frm.frame0 -borderwidth 0 -relief raised
      pack $frm.frame0 -side top -fill both -expand 1

      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -in $frm.frame0 -side left -fill y

      frame $frm.frame2 -width 100 -borderwidth 1 -relief raised
      pack $frm.frame2 -in $frm.frame0 -side right -fill both -expand 1

      frame $frm.frame3 -borderwidth 1 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side top -fill x

      frame $frm.frame4 -borderwidth 1 -relief flat
      pack $frm.frame4 -in $frm.frame1 -side top

      frame $frm.frame5 -height 10 -borderwidth 1 -relief raised
      pack $frm.frame5 -in $frm.frame1 -anchor n -side top -fill x

      frame $frm.frame6 -height 10 -borderwidth 1 -relief raised
      pack $frm.frame6 -in $frm.frame1 -anchor n -side top -fill x

      frame $frm.frame7 -height 10 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame6 -side left -fill both -expand 1

      frame $frm.frame8 -height 10 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame6 -side right -fill both -expand 1

      #--- Image de la Lune avec les numeros des cartes de details
      image create photo imageflag4a
      imageflag4a configure -file [file join $audace(rep_plugin) tool obj_lune image_obj_lune lune_lib.gif]

      #--- Creation d'un canvas pour affichage de cette image
      canvas $frm.frame4.image4a -width [ expr [image width imageflag4a] - 2 ] \
         -height [ expr [image height imageflag4a] - 2 ] \
         -cursor circle -borderwidth 0 -relief flat
      pack $frm.frame4.image4a -side left -anchor center -padx 0 -pady 0
      set zone(image4a) $frm.frame4.image4a

      #--- Affichage de cette image
      $zone(image4a) create image 0 0 -anchor nw -tag display
      $zone(image4a) itemconfigure display -image imageflag4a

      #--- Labels pour les cartes de libration
      label $frm.frame3.lab1 -text "$caption(obj_lune,atlas)" -font $audace(font,arial_12_b)
      pack $frm.frame3.lab1 -anchor center -padx 0 -pady 4

      label $frm.frame5.lab2 -text "$caption(obj_lune,carte_choisies)"
      pack $frm.frame5.lab2 -side left -padx 5 -pady 0
      label $frm.frame5.labURL3 -text "-"
      pack $frm.frame5.labURL3 -side left -padx 0 -pady 0

      label $frm.frame7.lab4 -text "$caption(obj_lune,carte_choisie)"
      pack $frm.frame7.lab4 -side left -padx 5 -pady 0
      label $frm.frame7.labURL5 -text "-"
      pack $frm.frame7.labURL5 -side left -padx 0 -pady 0

      label $frm.frame8.lab6 -text "$caption(obj_lune,carte_courante)"
      pack $frm.frame8.lab6 -side left -padx 5 -pady 0
      label $frm.frame8.labURL7 -text "-"
      pack $frm.frame8.labURL7 -side left -padx 0 -pady 0

      #--- Cree le canevas pour l'image
      ::obj_lune::Lune_Scrolled_Canvas $frm.frame2.image4b -borderwidth 0 -relief flat \
         -width 1000 -height 1000 -scrollregion {0 0 0 0} -cursor crosshair
      $frm.frame2.image4b.canvas configure -borderwidth 0
      $frm.frame2.image4b.canvas configure -relief flat
      pack $frm.frame2.image4b \
         -in $frm.frame2 -expand 1 -side left -anchor center -fill both -padx 0 -pady 0
      set zone(image4b) $frm.frame2.image4b.canvas

      #--- Creation de l'image de la carte demandee
      image create photo imageflag4b

      #--- Affichage du contour rouge de la carte courante choisie
      ::obj_lune::AffichePolygoneCarteChoisie

      #--- Initialisation du numero de la carte courante
      bind [Rnotebook:button $nn 4] <Button-1> {
         $frmm(Obj_Lune3).frame8.labURL7 configure -text "-"
         $frmm(Obj_Lune4).frame8.labURL7 configure -text "-"
      }
   }

   proc fillPage5 {nn} {
      global audace
      global obj_lune
      global caption
      global frmm

      #--- Initialisation
      set frmm(Obj_Lune5) [Rnotebook:frame $nn 5]
      set frm $frmm(Obj_Lune5)

      #--- Creation des differents frames
      frame $frm.frame0 -borderwidth 0 -relief raised
      pack $frm.frame0 -side left -fill both -expand 1

      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -in $frm.frame0 -anchor n -side left -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -in $frm.frame0 -anchor n -side left -fill y

      frame $frm.frame3 -borderwidth 0 -relief flat
      pack $frm.frame3 -in $frm.frame2 -side top

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side top -padx 10 -pady 2

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame16 -borderwidth 0 -relief raised
      pack $frm.frame16 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame17 -borderwidth 0 -relief raised
      pack $frm.frame17 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame18 -borderwidth 0 -relief raised
      pack $frm.frame18 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame19 -borderwidth 0 -relief raised
      pack $frm.frame19 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      frame $frm.frame20 -borderwidth 0 -relief raised
      pack $frm.frame20 -in $frm.frame1 -side top -fill both -expand 1 -padx 10

      #--- Image de la Lune
      image create photo imageflag5a
      imageflag5a configure -file [file join $audace(rep_plugin) tool obj_lune image_obj_lune lune_photo.gif]

      #--- Creation d'un canvas pour affichage de cette image
      canvas $frm.frame3.image5a -width [ expr [image width imageflag5a] - 2 ] \
         -height [ expr [image height imageflag5a] - 2 ] \
         -borderwidth 0 -relief flat
      pack $frm.frame3.image5a -side left -anchor center -padx 0 -pady 0
      set zone(image5a) $frm.frame3.image5a

      #--- Affichage de cette image
      $zone(image5a) create image 0 0 -anchor nw -tag display
      $zone(image5a) itemconfigure display -image imageflag5a

      #--- Labels des caracteristiques du site choisi
      label $frm.frame4.lab1 -text "$caption(obj_lune,nom)"
      pack $frm.frame4.lab1 -side left -padx 0 -pady 0
      label $frm.frame4.lab1a -text "-"
      pack $frm.frame4.lab1a -side left -padx 0 -pady 0

      label $frm.frame5.lab2 -text "$caption(obj_lune,latitude)"
      pack $frm.frame5.lab2 -side left -padx 0 -pady 0
      label $frm.frame5.lab2a -text "-"
      pack $frm.frame5.lab2a -side left -padx 0 -pady 0

      label $frm.frame6.lab3 -text "$caption(obj_lune,longitude)"
      pack $frm.frame6.lab3 -side left -padx 0 -pady 0
      label $frm.frame6.lab3a -text "-"
      pack $frm.frame6.lab3a -side left -padx 0 -pady 0

      button $frm.frame7.calcul -text "$caption(obj_lune,calculer)" -relief raised -state disabled \
         -width 15 -command { catch { ::obj_lune::Meilleures_Dates } }
      pack $frm.frame7.calcul -side top -padx 0 -pady 5 -ipady 5

      label $frm.frame8.lab4 -text "$caption(obj_lune,date)"
      pack $frm.frame8.lab4 -side left -padx 0 -pady 0
      label $frm.frame8.labURL4a -text "-"
      pack $frm.frame8.labURL4a -side left -padx 0 -pady 0

      label $frm.frame9.lab5 -text "$caption(obj_lune,heure)"
      pack $frm.frame9.lab5 -side left -padx 0 -pady 0
      label $frm.frame9.labURL5a -text "-"
      pack $frm.frame9.labURL5a -side left -padx 0 -pady 0

      label $frm.frame10.lab6 -text "$caption(obj_lune,long_terminateur)"
      pack $frm.frame10.lab6 -side left -padx 0 -pady 0
      label $frm.frame10.labURL6a -text "-"
      pack $frm.frame10.labURL6a -side left -padx 0 -pady 0

      label $frm.frame11.lab7 -text "$caption(obj_lune,libration,n_s)"
      pack $frm.frame11.lab7 -side left -padx 0 -pady 0
      label $frm.frame11.labURL7a -text "-"
      pack $frm.frame11.labURL7a -side left -padx 0 -pady 0

      label $frm.frame12.lab8 -text "$caption(obj_lune,libration,e_o)"
      pack $frm.frame12.lab8 -side left -padx 0 -pady 0
      label $frm.frame12.labURL8a -text "-"
      pack $frm.frame12.labURL8a -side left -padx 0 -pady 0

      label $frm.frame13.lab9 -text "$caption(obj_lune,fraction_eclairee)"
      pack $frm.frame13.lab9 -side left -padx 0 -pady 0
      label $frm.frame13.labURL9a -text "-"
      pack $frm.frame13.labURL9a -side left -padx 0 -pady 0

      label $frm.frame14.lab10 \
         -text "                                                                                                "
      pack $frm.frame14.lab10 -side left -padx 0 -pady 0

      label $frm.frame15.lab11 -text "$caption(obj_lune,date)"
      pack $frm.frame15.lab11 -side left -padx 0 -pady 0
      label $frm.frame15.labURL11a -text "-"
      pack $frm.frame15.labURL11a -side left -padx 0 -pady 0

      label $frm.frame16.lab12 -text "$caption(obj_lune,heure)"
      pack $frm.frame16.lab12 -side left -padx 0 -pady 0
      label $frm.frame16.labURL12a -text "-"
      pack $frm.frame16.labURL12a -side left -padx 0 -pady 0

      label $frm.frame17.lab13 -text "$caption(obj_lune,long_terminateur)"
      pack $frm.frame17.lab13 -side left -padx 0 -pady 0
      label $frm.frame17.labURL13a -text "-"
      pack $frm.frame17.labURL13a -side left -padx 0 -pady 0

      label $frm.frame18.lab14 -text "$caption(obj_lune,libration,n_s)"
      pack $frm.frame18.lab14 -side left -padx 0 -pady 0
      label $frm.frame18.labURL14a -text "-"
      pack $frm.frame18.labURL14a -side left -padx 0 -pady 0

      label $frm.frame19.lab15 -text "$caption(obj_lune,libration,e_o)"
      pack $frm.frame19.lab15 -side left -padx 0 -pady 0
      label $frm.frame19.labURL15a -text "-"
      pack $frm.frame19.labURL15a -side left -padx 0 -pady 0

      label $frm.frame20.lab16 -text "$caption(obj_lune,fraction_eclairee)"
      pack $frm.frame20.lab16 -side left -padx 0 -pady 0
      label $frm.frame20.labURL16a -text "-"
      pack $frm.frame20.labURL16a -side left -padx 0 -pady 0

      #--- Initialisation du numero de la carte courante
      bind [Rnotebook:button $nn 5] <Button-1> {
         $frmm(Obj_Lune3).frame8.labURL7 configure -text "-"
         $frmm(Obj_Lune4).frame8.labURL7 configure -text "-"
      }
   }
}

