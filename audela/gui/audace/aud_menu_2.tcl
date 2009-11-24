#
# Fichier : aud_menu_2.tcl
# Description : Script regroupant les fonctionnalites du menu Affichage
# Mise a jour $Id: aud_menu_2.tcl,v 1.20 2009-11-24 17:55:52 robertdelmas Exp $
#

namespace eval ::audace {

   #
   # ::audace::MAJ_palette visuNo
   # Procedure de creation dynamique de la palette en fonction de la fonction de transfert
   #
   proc MAJ_palette { visuNo } {
      global audace conf tmp

      #--- On recupere le nom du fichier palette "de base"
      switch $conf(visu_palette,visu$visuNo,mode) {
         1 { set fichier_palette_in [ file join $audace(rep_audela) audace palette gray ] }
         2 { set fichier_palette_in [ file join $audace(rep_audela) audace palette inv ] }
         3 { set fichier_palette_in [ file join $audace(rep_audela) audace palette iris ] }
         4 { set fichier_palette_in [ file join $audace(rep_audela) audace palette rainbow ] }
      }

      switch $conf(fonction_transfert,visu$visuNo,mode) {
         1 {
            #--- Fonction de transfert lineaire : Pas besoin de creer une palette
            visu$visuNo paldir [file dirname $fichier_palette_in]
            visu$visuNo pal [file tail $fichier_palette_in]
         }
         2 {
            #--- Fonction de transfert log
            if { $conf(fonction_transfert,param2) == 0 } {
               #--- On est ramene au cas lineaire
               visu$visuNo pal $fichier_palette_in
            } else {
               set conf(fonction_transfert,param2) [expr abs($conf(fonction_transfert,param2))]
               #--- On determine quelle partie de la courbe log on utilise (abcisses [a b])
               #--- (celle au dessus de la droite d'equation y=x-1-param)
               set dicho 0.5
               set a 0.5
               while {$dicho>0.001} {
                  if {[expr log($a)]>[expr $a-1-$conf(fonction_transfert,param2)]} {
                     set a [expr $a-$dicho/2]
                  } else {
                     set a [expr $a+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set dicho $conf(fonction_transfert,param2)
               set b [expr $conf(fonction_transfert,param2)+1]
               while {$dicho>0.001} {
                  if {[expr log($b)]>[expr $b-1-$conf(fonction_transfert,param2)]} {
                     set b [expr $b+$dicho/2]
                  } else {
                     set b [expr $b+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set Ya [expr log($a)]
               set Yb [expr log($b)]
               set deltax [expr $b-$a]
               set deltaY [expr $Yb-$Ya]

               #--- Ouverture des fichiers de palette
               set palette_in [open ${fichier_palette_in}.pal r]
               set palette_ex [open ${tmp(fichier_palette)}.pal w]

               set k_in 0
               #--- Ecriture du fichier de palette sortant
               for {set k_ex 0} {$k_ex<256} {incr k_ex} {
                  set valeur [expr abs((log($a+1.*$k_ex*$deltax/255)-$Ya)*255/$deltaY)]

                  #--- Si $valeur n'est pas entier, il faut interpoler entre les entiers juste au
                  #--- dessous et juste au dessus de $valeur
                  #--- Meme s'il est entier, ca marche aussi
                  while {$k_in<$valeur} {
                     incr k_in
                     set entree-1_in [gets $palette_in]
                  }

                  if {[expr $k_in -1] < $valeur} {
                     #--- Test de securite : On ne continue que si $k_in < 255
                     if {$k_in < 255 } {
                        if { [ info exist entree_in ] } {
                           set entree-1_in $entree_in
                        }
                        set entree_in [gets $palette_in]
                        incr k_in
                     }
                  }

                  if { ! [info exist entree-1_in]} {
                     set entree-1_in $entree_in
                  }
                  puts $palette_ex [list [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 0]+(1-$valeur+int($valeur))*[lindex $entree_in 0]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 1]+(1-$valeur+int($valeur))*[lindex $entree_in 1]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 2]+(1-$valeur+int($valeur))*[lindex $entree_in 2]]]
               }

               close $palette_in
               close $palette_ex

               visu$visuNo paldir [file dirname $tmp(fichier_palette)]
               visu$visuNo pal [file tail $tmp(fichier_palette)]
            }
         }
         3 {
            #--- Fonction de transfert exp
            if { $conf(fonction_transfert,param3) == 0 } {
               #--- On est ramene au cas lineaire
               visu$visuNo pal $fichier_palette
            } else {
               set conf(fonction_transfert,param3) [expr abs($conf(fonction_transfert,param3))]

               #--- On determine quelle partie de la courbe exp on utilise (abcisses [a b])
               #--- (celle au dessus de la droite d'equation y=x+1+parametre_exp)
               set dicho [expr $conf(fonction_transfert,param3)+1]
               set a [expr -$conf(fonction_transfert,param3)-1]
               while {$dicho>0.001} {
                  if {[expr exp($a)]>[expr $a+1+$conf(fonction_transfert,param3)]} {
                     set a [expr $a+$dicho/2]
                  } else {
                     set a [expr $a-$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }
               set dicho [expr $conf(fonction_transfert,param3)+1]
               set b [expr $conf(fonction_transfert,param3)+1]
               while {$dicho>0.001} {
                  if {[expr exp($b)]>[expr $b+1+$conf(fonction_transfert,param3)]} {
                     set b [expr $b-$dicho/2]
                  } else {
                     set b [expr $b+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set Ya [expr exp($a)]
               set Yb [expr exp($b)]
               set deltax [expr $b-$a]
               set deltaY [expr $Yb-$Ya]

               #--- Ouverture des fichiers de palette
               set palette_in [open ${fichier_palette_in}.pal r]
               set palette_ex [open ${tmp(fichier_palette)}.pal w]

               set k_in 0
               #--- Ecriture du fichier de palette sortant
               for {set k_ex 0} {$k_ex<256} {incr k_ex} {
                  set valeur [expr abs((exp($a+1.*$k_ex*$deltax/255)-$Ya)*255/$deltaY)]

                  #--- Si $valeur n'est pas entier, il faut interpoler entre les entiers juste au
                  #--- dessous et juste au dessus de $valeur
                  #--- Meme s'il est entier, ca marche aussi
                  while {$k_in<$valeur} {
                     incr k_in
                     set entree-1_in [gets $palette_in]
                  }

                  if {[expr $k_in -1] < $valeur} {
                     #--- Test de securite : On ne continue que si $k_in < 255
                     if {$k_in < 255 } {
                        if {[info exist entree_in]} {
                           set entree-1_in $entree_in
                        }
                        set entree_in [gets $palette_in]
                        incr k_in
                     }
                  }

                  if { ! [ info exist entree-1_in ] } {
                     set entree-1_in $entree_in
                  }
                  puts $palette_ex [list [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 0]+(1-$valeur+int($valeur))*[lindex $entree_in 0]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 1]+(1-$valeur+int($valeur))*[lindex $entree_in 1]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 2]+(1-$valeur+int($valeur))*[lindex $entree_in 2]]]
               }

               close $palette_in
               close $palette_ex

               visu$visuNo paldir [file dirname $tmp(fichier_palette)]
               visu$visuNo pal [file tail $tmp(fichier_palette)]
            }
         }
         4 {
            #--- Fonction de transfert arctangente / sigmoïde
            if {$conf(fonction_transfert,param4)==0} {
               #--- On est ramene au cas lineaire
               visu$visuNo pal $fichier_palette
            } else {
               set conf(fonction_transfert,param4) [expr abs($conf(fonction_transfert,param4))]

               #--- On determine quelle partie de la courbe exp on utilise (abcisses [a b])
               #--- (celle coupant la droite d'equation y=x/(1+parametre_arc))
               set dicho [expr $conf(fonction_transfert,param4)+1]
               set a [expr -$conf(fonction_transfert,param4)-1]
               while {$dicho>0.001} {
                  if { [expr atan($a)]>[expr 1.*$a/(1+$conf(fonction_transfert,param4))] } {
                     set a [expr $a+$dicho/2]
                  } else {
                     set a [expr $a-$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set dicho [expr $conf(fonction_transfert,param4)+1]
               set b [expr $conf(fonction_transfert,param4)+1]
               while {$dicho>0.001} {
                  if { [expr atan($b)]>[expr 1.*$b+1+$conf(fonction_transfert,param4)] } {
                     set b [expr $b-$dicho/2]
                  } else {
                     set b [expr $b+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set Ya [expr atan($a)]
               set Yb [expr atan($b)]
               set deltax [expr $b-$a]
               set deltaY [expr $Yb-$Ya]

               #--- Ouverture des fichiers de palette
               set palette_in [open ${fichier_palette_in}.pal r]
               set palette_ex [open ${tmp(fichier_palette)}.pal w]

               set k_in 0
               #--- Ecriture du fichier de palette sortant
               for {set k_ex 0} {$k_ex<256} {incr k_ex} {
                  set valeur [expr abs((atan($a+1.*$k_ex*$deltax/255)-$Ya)*255/$deltaY)]

                  #--- Si $valeur n'est pas entier, il faut interpoler entre les entiers juste au
                  #--- dessous et juste au dessus de $valeur
                  #--- Meme s'il est entier, ca marche aussi
                  while {$k_in<$valeur} {
                     incr k_in
                     set entree-1_in [gets $palette_in]
                  }

                  if { [expr $k_in -1] < $valeur } {
                     #--- Test de securite : On ne continue que si $k_in < 255
                     if { $k_in < 255 } {
                        if { [info exist entree_in] } {
                           set entree-1_in $entree_in
                        }
                        set entree_in [gets $palette_in]
                        incr k_in
                     }
                  }

                  if { ! [info exist entree-1_in] } {
                     set entree-1_in $entree_in
                  }
                  puts $palette_ex [list [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 0]+(1-$valeur+int($valeur))*[lindex $entree_in 0]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 1]+(1-$valeur+int($valeur))*[lindex $entree_in 1]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 2]+(1-$valeur+int($valeur))*[lindex $entree_in 2]]]
               }

               close $palette_in
               close $palette_ex

               visu$visuNo paldir [file dirname $tmp(fichier_palette)]
               visu$visuNo pal [file tail $tmp(fichier_palette)]
            }
         }
      }
   }

   #
   # ::audace::fonction_transfert visuNo
   # Procedure d'affichage de la fenetre "fonctions de transfert"
   #
   proc fonction_transfert { visuNo } {
      global caption conf tmp

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)

      #---
      if { [ winfo exists $base.fonction_transfert ] == "0" } {
         #--- Creation de la fenetre
         toplevel $base.fonction_transfert
         wm geometry $base.fonction_transfert $conf(fonction_transfert,visu$visuNo,position)
         wm title $base.fonction_transfert "$caption(audace,menu,fcttransfert_titre) (visu$visuNo)"
         wm transient $base.fonction_transfert [ winfo parent $base.fonction_transfert ]
         wm protocol $base.fonction_transfert WM_DELETE_WINDOW " ::audace::fonction_transfertquit $visuNo "

         #--- Enregistrement des reglages courants
         set tmp(fonction_transfert,visu$visuNo,mode) $conf(fonction_transfert,visu$visuNo,mode)
         set tmp(fonction_transfert,param2)           $conf(fonction_transfert,param2)
         set tmp(fonction_transfert,param3)           $conf(fonction_transfert,param3)
         set tmp(fonction_transfert,param4)           $conf(fonction_transfert,param4)

         #--- Sous-trame reglage fonction de transfert
         frame $base.fonction_transfert.regl
         pack $base.fonction_transfert.regl -expand true

         frame $base.fonction_transfert.regl.1
         pack $base.fonction_transfert.regl.1 -fill x
         radiobutton $base.fonction_transfert.regl.1.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(audace,menu,fcttransfert_lin) -value 1
         pack $base.fonction_transfert.regl.1.but -side left
         frame $base.fonction_transfert.regl.2
         pack $base.fonction_transfert.regl.2 -fill x
         radiobutton $base.fonction_transfert.regl.2.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(audace,menu,fcttransfert_log) -value 2
         pack $base.fonction_transfert.regl.2.but -side left
         entry $base.fonction_transfert.regl.2.ent -textvariable conf(fonction_transfert,param2) \
            -width 4 -justify center
         pack $base.fonction_transfert.regl.2.ent -side right
         frame $base.fonction_transfert.regl.3
         pack $base.fonction_transfert.regl.3 -fill x
         radiobutton $base.fonction_transfert.regl.3.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(audace,menu,fcttransfert_exp) -value 3
         pack $base.fonction_transfert.regl.3.but -side left
         entry $base.fonction_transfert.regl.3.ent -textvariable conf(fonction_transfert,param3) \
            -width 4 -justify center
         pack $base.fonction_transfert.regl.3.ent -side right
         frame $base.fonction_transfert.regl.4
         pack $base.fonction_transfert.regl.4 -fill x
         radiobutton $base.fonction_transfert.regl.4.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(audace,menu,fcttransfert_arc) -value 4
         pack $base.fonction_transfert.regl.4.but -side left
         entry $base.fonction_transfert.regl.4.ent -textvariable conf(fonction_transfert,param4) \
            -width 4 -justify center
         pack $base.fonction_transfert.regl.4.ent -side right

         #--- Bouton Aide
         button $base.fonction_transfert.regl.aide -command ::audace::fonction_transfertaide \
            -text $caption(aud_menu_2,aide) -width 8
         pack $base.fonction_transfert.regl.aide -expand true -padx 10 -pady 10

         #--- Sous-trame boutons OK, previsu & quitter
         frame $base.fonction_transfert.buttons
         pack $base.fonction_transfert.buttons
         button $base.fonction_transfert.buttons.ok -command " ::audace::fonction_transfertok $visuNo " \
            -text $caption(aud_menu_2,ok)
         pack $base.fonction_transfert.buttons.ok -side left -expand true -padx 14 -pady 10 -ipadx 10
         button $base.fonction_transfert.buttons.previsu -command " ::audace::MAJ_palette $visuNo " \
            -text $caption(aud_menu_2,previsu)
         pack $base.fonction_transfert.buttons.previsu -side left -expand true -padx 14 -pady 10 -ipadx 10
         button $base.fonction_transfert.buttons.quit -command " ::audace::fonction_transfertquit $visuNo " \
            -text $caption(aud_menu_2,quitter)
         pack $base.fonction_transfert.buttons.quit -side left -expand true -padx 14 -pady 10 -ipadx 10

         #--- Focus
         focus $base.fonction_transfert

         #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
         bind $base.fonction_transfert <Key-F1> { ::console::GiveFocus }

         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $base.fonction_transfert
      } else {
         focus $base.fonction_transfert
      }
   }

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

   #
   # ::audace::fonction_transfertok visuNo
   # Procedure correspondant a l'appui sur le bouton OK de la fenetre "fonction de transfert"
   #
   proc fonction_transfertok { visuNo } {
      global conf tmp

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)
      #---
      set tmp(fonction_transfert,visu$visuNo,mode) $conf(fonction_transfert,visu$visuNo,mode)
      #--- Recuperation de la position de la fenetre de reglages
      fonction_transfert_recup_position $visuNo
      #---
      destroy $base.fonction_transfert
      ::audace::MAJ_palette $visuNo
   }

   #
   # ::audace::fonction_transfertquit visuNo
   # Procedure correspondant a l'appui sur bouton Quitter de la fenetre "fonction de transfert"
   #
   proc fonction_transfertquit { visuNo } {
      global conf tmp

      #--- On recupere les anciens parametres
      set conf(fonction_transfert,visu$visuNo,mode) $tmp(fonction_transfert,visu$visuNo,mode)
      set conf(fonction_transfert,param2)           $tmp(fonction_transfert,param2)
      set conf(fonction_transfert,param3)           $tmp(fonction_transfert,param3)
      set conf(fonction_transfert,param4)           $tmp(fonction_transfert,param4)
      fonction_transfertok $visuNo
   }

   #
   # ::audace::fonction_transfertaide
   # Procedure d'affichage de la fenetre d'aide pour le reglage de la "fonction de transfert"
   #
   proc fonction_transfertaide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1020transfert.htm"
   }

   #
   # ::audace::fonction_transfert_recup_position visuNo
   # Recupere les coordonnees de la fenetre de dialogue de la "fonction de transfert"
   #
   proc fonction_transfert_recup_position { visuNo } {
      global conf

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)
      #---
      set fonction_transfert(visu$visuNo,geometry) [ wm geometry $base.fonction_transfert ]
      set deb [ expr 1 + [ string first + $fonction_transfert(visu$visuNo,geometry) ] ]
      set fin [ string length $fonction_transfert(visu$visuNo,geometry) ]
      set conf(fonction_transfert,visu$visuNo,position) "+[string range $fonction_transfert(visu$visuNo,geometry) $deb $fin]"
   }

}
############################# Fin du namespace audace #############################

namespace eval ::seuilWindow {

   #
   # ::seuilWindow::run base visuNo
   # Lance la fenetre de dialogue de reglage des seuils de visualisation
   #
   proc run { base visuNo } {
      global seuilWindow

      ::seuilWindow::initConf $visuNo
      set seuilWindow($visuNo,This) $base.seuilwindow

      if { [ winfo exists $seuilWindow($visuNo,This) ] } {
         wm withdraw $seuilWindow($visuNo,This)
         wm deiconify $seuilWindow($visuNo,This)
         focus $seuilWindow($visuNo,This)
      } else {
         set seuilWindow($visuNo,max) $::confVisu::private($visuNo,maxdyn)
         set seuilWindow($visuNo,min) $::confVisu::private($visuNo,mindyn)
         createDialog $visuNo
      }
   }

   #
   # ::seuilWindow::initConf [visuNo]
   # Initialise les variables de configuration
   #
   proc initConf { { visuNo 1 } } {
      global conf

      if { ! [ info exists conf(seuils,auto_manuel) ] }      { set conf(seuils,auto_manuel)      "1" }
      if { ! [ info exists conf(seuils,%_dynamique) ] }      { set conf(seuils,%_dynamique)      "50" }
      if { ! [ info exists conf(seuils,irisautohaut) ] }     { set conf(seuils,irisautohaut)     "1000" }
      if { ! [ info exists conf(seuils,irisautobas) ] }      { set conf(seuils,irisautobas)      "200" }
      if { ! [ info exists conf(seuils,histoautohaut) ] }    { set conf(seuils,histoautohaut)    "99" }
      if { ! [ info exists conf(seuils,histoautobas) ] }     { set conf(seuils,histoautobas)     "3" }
   }

   #
   # ::seuilWindow::createDialog visuNo
   # Creation de l'interface graphique
   #
   proc createDialog { visuNo } {
      global caption conf seuilWindow tmp

      #---
      set seuilWindow($visuNo,choix_dynamique) "65535 32767 20000 10000 5000 2000 1000 500 200 0 -500 -1000 -32768"

      #---
      set seuilWindow($visuNo,intervalleSHSB)         $::confVisu::private($visuNo,intervalleSHSB)
      set seuilWindow($visuNo,seuilWindowAuto_Manuel) $conf(seuils,auto_manuel)
      set seuilWindow($visuNo,pourcentage_dynamique)  $conf(seuils,%_dynamique)

      #---
      if { ! [ info exists conf(seuils,visu$visuNo,position) ] } { set conf(seuils,visu$visuNo,position) "+0+0" }

      #---
      toplevel $seuilWindow($visuNo,This) -class $visuNo
      wm resizable $seuilWindow($visuNo,This) 0 0
      wm deiconify $seuilWindow($visuNo,This)
      wm title $seuilWindow($visuNo,This) "$caption(seuilWindow,titre) (visu$visuNo)"
      wm geometry $seuilWindow($visuNo,This) $conf(seuils,visu$visuNo,position)
      wm transient $seuilWindow($visuNo,This) [ winfo parent $seuilWindow($visuNo,This) ]
      wm protocol $seuilWindow($visuNo,This) WM_DELETE_WINDOW " ::seuilWindow::cmdClose $visuNo "

      #--- Sauvegarde des anciens reglages
      set tmp(seuils,visu$visuNo,mode)  $conf(seuils,visu$visuNo,mode)
      set tmp(seuils,irisautohaut)      $conf(seuils,irisautohaut)
      set tmp(seuils,irisautobas)       $conf(seuils,irisautobas)
      set tmp(seuils,histoautohaut)     $conf(seuils,histoautohaut)
      set tmp(seuils,histoautobas)      $conf(seuils,histoautobas)

      #--- Sauveagarde des reglages courants
      set tmp(seuils,visu$visuNo,mode_) $conf(seuils,visu$visuNo,mode)
      set tmp(seuils,irisautohaut_)     $conf(seuils,irisautohaut)
      set tmp(seuils,irisautobas_)      $conf(seuils,irisautobas)
      set tmp(seuils,histoautohaut_)    $conf(seuils,histoautohaut)
      set tmp(seuils,histoautobas_)     $conf(seuils,histoautobas)

      #---
      frame $seuilWindow($visuNo,This).usr1 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr1.affichage_intensites

            label $seuilWindow($visuNo,This).usr1.affichage_intensites.lab1 -text "$caption(seuilWindow,intensite)"
            pack $seuilWindow($visuNo,This).usr1.affichage_intensites.lab1 -side left -padx 10

         pack $seuilWindow($visuNo,This).usr1.affichage_intensites -side left -expand true

         frame $seuilWindow($visuNo,This).usr1.affichage_intensites.0

            radiobutton $seuilWindow($visuNo,This).usr1.affichage_intensites.0.but \
               -variable ::confVisu::private($visuNo,intensity) -value 1 \
               -text $caption(seuilWindow,intensite_avec_zero)
            pack $seuilWindow($visuNo,This).usr1.affichage_intensites.0.but -side left -padx 10

         pack $seuilWindow($visuNo,This).usr1.affichage_intensites.0 -side top -padx 10 -fill x

         frame $seuilWindow($visuNo,This).usr1.affichage_intensites.1

            radiobutton $seuilWindow($visuNo,This).usr1.affichage_intensites.1.but \
               -variable ::confVisu::private($visuNo,intensity) -value 0 \
               -text $caption(seuilWindow,intensite_sans_zero)
            pack $seuilWindow($visuNo,This).usr1.affichage_intensites.1.but -side left -padx 10

         pack $seuilWindow($visuNo,This).usr1.affichage_intensites.1 -side top -padx 10 -fill x

      pack $seuilWindow($visuNo,This).usr1 -side top -fill both -expand 1 -ipady 5

      frame $seuilWindow($visuNo,This).usr11 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr11.shsb

            label $seuilWindow($visuNo,This).usr11.shsb.lab1 -text "$caption(seuilWindow,intervalle_sh-sb)"
            pack $seuilWindow($visuNo,This).usr11.shsb.lab1 -side left -padx 10

            entry $seuilWindow($visuNo,This).usr11.shsb.intervalleSHSB -textvariable seuilWindow($visuNo,intervalleSHSB) \
               -width 8 -justify center
            pack $seuilWindow($visuNo,This).usr11.shsb.intervalleSHSB -side left -padx 0

         pack $seuilWindow($visuNo,This).usr11.shsb -side left

         frame $seuilWindow($visuNo,This).usr11.label1

            label $seuilWindow($visuNo,This).usr11.label1.lab2 -text "$caption(seuilWindow,exemple>x)"
            pack $seuilWindow($visuNo,This).usr11.label1.lab2 -side left -padx 0

         pack $seuilWindow($visuNo,This).usr11.label1 -side top -padx 10 -fill x

         frame $seuilWindow($visuNo,This).usr11.label2

            label $seuilWindow($visuNo,This).usr11.label2.lab2 -text "$caption(seuilWindow,exemple<x)"
            pack $seuilWindow($visuNo,This).usr11.label2.lab2 -side left -padx 0

         pack $seuilWindow($visuNo,This).usr11.label2 -side top -padx 10 -fill x

      pack $seuilWindow($visuNo,This).usr11 -side top -fill both -expand 1

      frame $seuilWindow($visuNo,This).usr2 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr2.1 -borderwidth 0 -relief flat

            label $seuilWindow($visuNo,This).usr2.1.lab1 -text "$caption(seuilWindow,dynamique)"
            pack $seuilWindow($visuNo,This).usr2.1.lab1 -side left -padx 10
            radiobutton $seuilWindow($visuNo,This).usr2.1.rad1 -variable seuilWindow($visuNo,seuilWindowAuto_Manuel) \
               -text $caption(seuilWindow,auto) -value 1 -command " ::seuilWindow::cmdseuilWindowAuto_Manuel $visuNo "
            pack $seuilWindow($visuNo,This).usr2.1.rad1 -side left -padx 10
            radiobutton $seuilWindow($visuNo,This).usr2.1.rad2 -variable seuilWindow($visuNo,seuilWindowAuto_Manuel) \
               -text $caption(seuilWindow,manuel) -value 2 -command " ::seuilWindow::cmdseuilWindowAuto_Manuel $visuNo "
            pack $seuilWindow($visuNo,This).usr2.1.rad2 -side left -padx 10

         pack $seuilWindow($visuNo,This).usr2.1 -side top -fill both

         frame $seuilWindow($visuNo,This).usr2.2 -borderwidth 0 -relief flat

            scale $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant -from 20 -to 300 -length 370 -orient horizontal \
               -showvalue true -tickinterval 20 -resolution 5 -borderwidth 2 -relief groove \
               -variable seuilWindow($visuNo,pourcentage_dynamique) -width 10
            pack $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant -side top -padx 10 -pady 7

            frame $seuilWindow($visuNo,This).usr2.2.1 -borderwidth 0 -relief flat
               label $seuilWindow($visuNo,This).usr2.2.1.lab1 -text "$caption(seuilWindow,dynamique_max)"
               pack $seuilWindow($visuNo,This).usr2.2.1.lab1 -side left -padx 10 -pady 5
               entry $seuilWindow($visuNo,This).usr2.2.1.ent1 -textvariable seuilWindow($visuNo,max) -width 10
               pack $seuilWindow($visuNo,This).usr2.2.1.ent1 -side left -padx 10 -pady 5
               menubutton $seuilWindow($visuNo,This).usr2.2.1.but -text $caption(seuilWindow,parcourir) -menu $seuilWindow($visuNo,This).usr2.2.1.but.menu \
                  -relief raised
               pack $seuilWindow($visuNo,This).usr2.2.1.but -side left -padx 10 -pady 5
               set m [ menu $seuilWindow($visuNo,This).usr2.2.1.but.menu -tearoff 0 ]
               foreach dynamique $seuilWindow($visuNo,choix_dynamique) {
                  $m add radiobutton -label "$dynamique" \
                     -indicatoron "1" \
                     -value "$dynamique" \
                     -variable seuilWindow($visuNo,max) \
                     -command { }
               }
            pack $seuilWindow($visuNo,This).usr2.2.1 -side top -fill both

            frame $seuilWindow($visuNo,This).usr2.2.2 -borderwidth 0 -relief flat
               label $seuilWindow($visuNo,This).usr2.2.2.lab1 -text "$caption(seuilWindow,dynamique_min)"
               pack $seuilWindow($visuNo,This).usr2.2.2.lab1 -side left -padx 10 -pady 5
               entry $seuilWindow($visuNo,This).usr2.2.2.ent1 -textvariable seuilWindow($visuNo,min) -width 10
               pack $seuilWindow($visuNo,This).usr2.2.2.ent1 -side left -padx 10 -pady 5
               menubutton $seuilWindow($visuNo,This).usr2.2.2.but -text $caption(seuilWindow,parcourir) -menu $seuilWindow($visuNo,This).usr2.2.2.but.menu \
                  -relief raised
               pack $seuilWindow($visuNo,This).usr2.2.2.but -side left -padx 10 -pady 5
               set m [ menu $seuilWindow($visuNo,This).usr2.2.2.but.menu -tearoff 0 ]
               foreach dynamique $seuilWindow($visuNo,choix_dynamique) {
                  $m add radiobutton -label "$dynamique" \
                     -indicatoron "1" \
                     -value "$dynamique" \
                     -variable seuilWindow($visuNo,min) \
                     -command { }
               }
            pack $seuilWindow($visuNo,This).usr2.2.2 -side top -fill both

         pack $seuilWindow($visuNo,This).usr2.2 -side top -fill both

      pack $seuilWindow($visuNo,This).usr2 -side top -fill both -expand 1 -ipady 5

      #--- Mise a jour de l'interface
      ::seuilWindow::cmdseuilWindowAuto_Manuel $visuNo

      frame $seuilWindow($visuNo,This).usr3 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr3.regl_seuils
         pack $seuilWindow($visuNo,This).usr3.regl_seuils -side left -expand true

         frame $seuilWindow($visuNo,This).usr3.regl_seuils.0
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.0 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.0.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,pas_de_calcul_auto) -value disable
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.0.but -side left -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.1
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.1 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.1.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,loadima) -value loadima
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.1.but -side left -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.2
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.2.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,iris) -value iris
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2.but -side left -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.2.enth -textvariable tmp(seuils,irisautohaut_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2.enth -side right -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.2.entb -textvariable tmp(seuils,irisautobas_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2.entb -side right -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.4
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.4.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,histoauto) -value histoauto
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4.but -side left -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.4.enth -textvariable tmp(seuils,histoautohaut_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4.enth -side right -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.4.entb -textvariable tmp(seuils,histoautobas_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4.entb -side right -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.6
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.6 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.6.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,initiaux) -value initiaux
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.6.but -side left -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.7
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.7 -fill x
         button $seuilWindow($visuNo,This).usr3.regl_seuils.7.but -text $caption(seuilWindow,previsu) \
            -command " ::seuilWindow::cmdPreview $visuNo "
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.7.but -side top -expand true -padx 10 -pady 5 -ipadx 10

      pack $seuilWindow($visuNo,This).usr3 -side top -fill both -expand 1 -ipady 5

      frame $seuilWindow($visuNo,This).cmd -borderwidth 1 -relief raised

         button $seuilWindow($visuNo,This).cmd.ok -text "$caption(seuilWindow,ok)" -width 7 \
            -command " ::seuilWindow::cmdOk $visuNo "
         if { $conf(ok+appliquer)=="1" } {
            pack $seuilWindow($visuNo,This).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $seuilWindow($visuNo,This).cmd.appliquer -text "$caption(seuilWindow,appliquer)" -width 8 \
            -command "::seuilWindow::cmdApply $visuNo "
         pack $seuilWindow($visuNo,This).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilWindow($visuNo,This).cmd.fermer -text "$caption(seuilWindow,fermer)" -width 7 \
            -command " ::seuilWindow::cmdClose $visuNo "
         pack $seuilWindow($visuNo,This).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilWindow($visuNo,This).cmd.aide -text "$caption(seuilWindow,aide)" -width 7 \
            -command " ::seuilWindow::afficheAide "
         pack $seuilWindow($visuNo,This).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $seuilWindow($visuNo,This).cmd -side top -fill x

      #---
      bind $seuilWindow($visuNo,This) <Key-Return> " ::seuilWindow::cmdOk $visuNo "
      bind $seuilWindow($visuNo,This) <Key-Escape> " ::seuilWindow::cmdClose $visuNo "

      #--- La fenetre est active
      focus $seuilWindow($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $seuilWindow($visuNo,This) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $seuilWindow($visuNo,This)
   }

   #
   # ::seuilWindow::cmdseuilWindowAuto_Manuel visuNo
   # Modifie l'interface graphique en fonction du choix (automatique ou manuel)
   #
   proc cmdseuilWindowAuto_Manuel { visuNo } {
      global seuilWindow

      if { $seuilWindow($visuNo,seuilWindowAuto_Manuel) == "1" } {
         pack $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant -side top -padx 10 -pady 7
         pack forget $seuilWindow($visuNo,This).usr2.2.1
         pack forget $seuilWindow($visuNo,This).usr2.2.1.lab1
         pack forget $seuilWindow($visuNo,This).usr2.2.1.ent1
         pack forget $seuilWindow($visuNo,This).usr2.2.1.but
         pack forget $seuilWindow($visuNo,This).usr2.2.2
         pack forget $seuilWindow($visuNo,This).usr2.2.2.lab1
         pack forget $seuilWindow($visuNo,This).usr2.2.2.ent1
         pack forget $seuilWindow($visuNo,This).usr2.2.2.but
      } else {
         pack forget $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant
         pack $seuilWindow($visuNo,This).usr2.2.1 -side top -fill both
         pack $seuilWindow($visuNo,This).usr2.2.1.lab1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.1.ent1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.1.but -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.2 -side top -fill both
         pack $seuilWindow($visuNo,This).usr2.2.2.lab1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.2.ent1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.2.but -side left -padx 10 -pady 5
      }
   }

   #
   # ::seuilWindow::cmdPreview visuNo
   # Fonction apercu
   #
   proc cmdPreview { visuNo } {
      global conf tmp

      #--- Copie des reglages courants
      set conf(seuils,visu$visuNo,mode) $tmp(seuils,visu$visuNo,mode_)
      set conf(seuils,irisautohaut)     $tmp(seuils,irisautohaut_)
      set conf(seuils,irisautobas)      $tmp(seuils,irisautobas_)
      set conf(seuils,histoautohaut)    $tmp(seuils,histoautohaut_)
      set conf(seuils,histoautobas)     $tmp(seuils,histoautobas_)
      #--- Visualisation avec les reglages courants
      ::audace::autovisu $visuNo
      #--- Recuperation des anciens reglages
      set conf(seuils,visu$visuNo,mode) $tmp(seuils,visu$visuNo,mode)
      set conf(seuils,irisautohaut)     $tmp(seuils,irisautohaut)
      set conf(seuils,irisautobas)      $tmp(seuils,irisautobas)
      set conf(seuils,histoautohaut)    $tmp(seuils,histoautohaut)
      set conf(seuils,histoautobas)     $tmp(seuils,histoautobas)
   }

   #
   # ::seuilWindow::cmdOk visuNo
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { visuNo } {
      cmdApply $visuNo
      cmdClose $visuNo
   }

   #
   # ::seuilWindow::cmdApply visuNo
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { visuNo } {
      global audace conf select seuilWindow tmp

      #--- Copie des seuils manuels maxi et mini
      if { $seuilWindow($visuNo,seuilWindowAuto_Manuel) == "2" } {
         set ::confVisu::private($visuNo,maxdyn) $seuilWindow($visuNo,max)
         set ::confVisu::private($visuNo,mindyn) $seuilWindow($visuNo,min)
      }
      #--- Copie des parametres du reglage
      set ::confVisu::private($visuNo,intervalleSHSB) $seuilWindow($visuNo,intervalleSHSB)
      set conf(seuils,auto_manuel)                    $seuilWindow($visuNo,seuilWindowAuto_Manuel)
      set conf(seuils,%_dynamique)                    $seuilWindow($visuNo,pourcentage_dynamique)
      #--- Copie des reglages courants
      set conf(seuils,visu$visuNo,mode) $tmp(seuils,visu$visuNo,mode_)
      set conf(seuils,histoautohaut)    $tmp(seuils,histoautohaut_)
      set conf(seuils,histoautobas)     $tmp(seuils,histoautobas_)
      set conf(seuils,irisautohaut)     $tmp(seuils,irisautohaut_)
      set conf(seuils,irisautobas)      $tmp(seuils,irisautobas_)
      #--- Visualisation avec les reglages courants dans la fenetre principale
      ::confVisu::autovisu $visuNo
      #--- Visualisation avec les reglages courants dans la fenetre de selection des images si elle existe
      if [ winfo exists $audace(base).select ] {
         ::audace::autovisu $select(visuNo)
      }
      #--- Recuperation de la position de la fenetre de reglages
      seuils_recup_position $visuNo
   }

   #
   # ::seuilWindow::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1030seuils.htm"
   }

   #
   # ::seuilWindow::cmdClose visuNo
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { visuNo } {
      global seuilWindow

      #--- Recuperation de la position de la fenetre de reglages
      seuils_recup_position $visuNo
      #---
      destroy $seuilWindow($visuNo,This)
      unset seuilWindow($visuNo,This)
   }

   #
   # ::seuilWindow::seuils_recup_position visuNo
   # Recupere les coordonnees de la fenetre de dialogue des seuils
   #
   proc seuils_recup_position { visuNo } {
      global conf seuilWindow

      set seuilWindow(seuils,$visuNo,geometry) [ wm geometry $seuilWindow($visuNo,This) ]
      set deb [ expr 1 + [ string first + $seuilWindow(seuils,$visuNo,geometry) ] ]
      set fin [ string length $seuilWindow(seuils,$visuNo,geometry) ]
      set conf(seuils,visu$visuNo,position) "+[string range $seuilWindow(seuils,$visuNo,geometry) $deb $fin]"
   }

}

########################### Fin du namespace seuilWindow ###########################

namespace eval ::seuilCouleur {

   #
   # ::seuilCouleur::run this
   # Lance la fenetre de dialogue pour le reglage de la balance RVB
   #
   proc run { base visuNo } {
      variable widget
      global seuilCouleur

      #---
      ::seuilCouleur::initConf $visuNo
      ::seuilCouleur::confToWidget $visuNo
      #---
      set seuilCouleur($visuNo,base) $base
      set seuilCouleur($visuNo,This) $base.seuilcouleur
      if { [ winfo exists $seuilCouleur($visuNo,This) ] } {
         wm withdraw $seuilCouleur($visuNo,This)
         wm deiconify $seuilCouleur($visuNo,This)
         focus $seuilCouleur($visuNo,This)
      } else {
         if { [ info exists seuilCouleur(seuils,$visuNo,geometry) ] } {
            set deb [ expr 1 + [ string first + $seuilCouleur(seuils,$visuNo,geometry) ] ]
            set fin [ string length $seuilCouleur(seuils,$visuNo,geometry) ]
            set widget(seuils,$visuNo,position) "+[string range $seuilCouleur(seuils,$visuNo,geometry) $deb $fin]"
         }
         ::seuilCouleur::createDialog $visuNo
      }
   }

   #
   # ::seuilCouleur::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { visuNo } {
      global conf

      if { ! [ info exists conf(seuilCouleur,visu$visuNo,position) ] } { set conf(seuilCouleur,visu$visuNo,position) "+350+75" }
   }

   #
   # ::seuilCouleur::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable widget
      global conf

      set widget(seuils,$visuNo,position) "$conf(seuilCouleur,visu$visuNo,position)"
   }

   #
   # ::seuilCouleur::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { visuNo } {
      variable widget
      global conf

      set conf(seuilCouleur,visu$visuNo,position) "$widget(seuils,$visuNo,position)"
   }

   #
   # ::seuilCouleur::recupPosition
   # Recupere la position de la fenetre
   #
   proc recupPosition { visuNo } {
      variable widget
      global seuilCouleur

      set seuilCouleur(seuils,$visuNo,geometry) [wm geometry $seuilCouleur($visuNo,This)]
      set deb [ expr 1 + [ string first + $seuilCouleur(seuils,$visuNo,geometry) ] ]
      set fin [ string length $seuilCouleur(seuils,$visuNo,geometry) ]
      set widget(seuils,$visuNo,position) "+[string range $seuilCouleur(seuils,$visuNo,geometry) $deb $fin]"
      #---
      ::seuilCouleur::widgetToConf $visuNo
   }

   #
   # ::seuilCouleur::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { visuNo } {
      variable widget
      global audace caption color conf seuilCouleur

      #--- Initialisation de variables
      set seuilCouleur(enregister) "0"
      set seuilCouleur(avancement) ""
      ::seuilCouleur::initSeuils

      #---
      toplevel $seuilCouleur($visuNo,This)
      wm resizable $seuilCouleur($visuNo,This) 0 0
      wm deiconify $seuilCouleur($visuNo,This)
      wm title $seuilCouleur($visuNo,This) "$caption(audace,menu,affichage) (visu$visuNo)"
      wm geometry $seuilCouleur($visuNo,This) $widget(seuils,$visuNo,position)
      wm transient $seuilCouleur($visuNo,This) $seuilCouleur($visuNo,base)
      wm protocol $seuilCouleur($visuNo,This) WM_DELETE_WINDOW "::seuilCouleur::cmdClose $visuNo"

      #---
      frame $seuilCouleur($visuNo,This).usr -borderwidth 0 -relief raised

         frame $seuilCouleur($visuNo,This).usr.1 -borderwidth 1 -relief raised
            label $seuilCouleur($visuNo,This).usr.1.lab1 \
               -textvariable "caption(seuilCouleur,image_affichee)"
            pack $seuilCouleur($visuNo,This).usr.1.lab1 -side left -padx 10 -pady 5
         pack $seuilCouleur($visuNo,This).usr.1 -side top -fill both

         frame $seuilCouleur($visuNo,This).usr.2 -borderwidth 1 -relief raised
            label $seuilCouleur($visuNo,This).usr.2.lab5 \
               -text "$caption(seuilCouleur,selection_zone_blanche)"
            pack $seuilCouleur($visuNo,This).usr.2.lab5 -side top -padx 5 -pady 10
            button $seuilCouleur($visuNo,This).usr.2.btn1 \
               -text "$caption(seuilCouleur,confirmer_zone_blanche)" \
               -command "::seuilCouleur::confirmerBlanc $visuNo"
            pack $seuilCouleur($visuNo,This).usr.2.btn1 -side top -ipadx 15 -ipady 5
            label $seuilCouleur($visuNo,This).usr.2.lab6 \
               -text "$caption(seuilCouleur,selection_zone_noire)"
            pack $seuilCouleur($visuNo,This).usr.2.lab6 -side top -padx 5 -pady 10
            button $seuilCouleur($visuNo,This).usr.2.btn2 \
               -text "$caption(seuilCouleur,confirmer_zone_noire)" \
               -command "::seuilCouleur::confirmerNoir $visuNo"
            pack $seuilCouleur($visuNo,This).usr.2.btn2 -side top -ipadx 15 -ipady 5
            checkbutton $seuilCouleur($visuNo,This).usr.2.che1 -justify left \
               -text "$caption(seuilCouleur,enregister_seuils)" -variable seuilCouleur(enregister)
            pack $seuilCouleur($visuNo,This).usr.2.che1 -side left -padx 10 -pady 10
         pack $seuilCouleur($visuNo,This).usr.2 -side top -fill both

         frame $seuilCouleur($visuNo,This).usr.3 -borderwidth 1 -relief raised
            label $seuilCouleur($visuNo,This).usr.3.labURL1 \
               -textvariable "seuilCouleur(avancement)" -fg $color(blue)
            pack $seuilCouleur($visuNo,This).usr.3.labURL1 -side top -padx 10 -pady 5
         pack $seuilCouleur($visuNo,This).usr.3 -side top -fill both

      pack $seuilCouleur($visuNo,This).usr -side top -fill both -expand 1

      frame $seuilCouleur($visuNo,This).cmd -borderwidth 1 -relief raised

         button $seuilCouleur($visuNo,This).cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command "::seuilCouleur::cmdOk $visuNo"
         if { $conf(ok+appliquer)=="1" } {
            pack $seuilCouleur($visuNo,This).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $seuilCouleur($visuNo,This).cmd.appliquer -text "$caption(aud_menu_3,appliquer)" \
            -width 8 -command "::seuilCouleur::cmdApply $visuNo"
         pack $seuilCouleur($visuNo,This).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilCouleur($visuNo,This).cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command "::seuilCouleur::cmdClose $visuNo"
         pack $seuilCouleur($visuNo,This).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilCouleur($visuNo,This).cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
            -command "::seuilCouleur::afficheAide"
         pack $seuilCouleur($visuNo,This).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $seuilCouleur($visuNo,This).cmd -side top -fill x

      #---
      bind $seuilCouleur($visuNo,This) <Key-Return> "::seuilCouleur::cmdOk $visuNo"
      bind $seuilCouleur($visuNo,This) <Key-Escape> "::seuilCouleur::cmdClose $visuNo"

      #---
      focus $seuilCouleur($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $seuilCouleur($visuNo,This) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $seuilCouleur($visuNo,This)
   }

   #
   # ::seuilCouleur::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { visuNo } {
      ::seuilCouleur::cmdApply $visuNo
      ::seuilCouleur::cmdClose $visuNo
   }

   #
   # ::seuilCouleur::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { visuNo } {
      global caption conf seuilCouleur

      #---
      set seuilCouleur(avancement) "$caption(seuilCouleur,en_cours)"
      update

      #--- Il faut une image affichee
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] != "1" } {
         tk_messageBox -title "$caption(seuilCouleur,attention)" -type ok \
            -message "$caption(seuilCouleur,header_noimage)"
         set seuilCouleur(avancement) ""
         return
      }

      #--- Traitement
      set catchError [ catch {
         #--- Affectation des niveaux maxi et mini pour le Rouge, le Vert et le Bleu
         set mycuts [ list $seuilCouleur(blanc_R) $seuilCouleur(noir_R) $seuilCouleur(blanc_V) $seuilCouleur(noir_V) $seuilCouleur(blanc_B) $seuilCouleur(noir_B) ]
         if { $seuilCouleur(blanc_R) == "" } {
            tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
               -message "$caption(seuilCouleur,pas_selection_blanc)"
            set seuilCouleur(avancement) ""
            return
         } elseif { $seuilCouleur(noir_R) == "" } {
            tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
               -message "$caption(seuilCouleur,pas_selection_noir)"
            set seuilCouleur(avancement) ""
            return
         } elseif { $seuilCouleur(blanc_V) == "" } {
            tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
               -message "$caption(seuilCouleur,pas_couleur)"
            ::seuilCouleur::initSeuils
            set seuilCouleur(avancement) ""
            return
         }
         visu$visuNo cut $mycuts
         #--- Affichage de l'image
         visu$visuNo disp
         #--- Enregistrement de l'image avec les nouveaux seuils
         if { $seuilCouleur(enregister) == "1" } {
            #--- Je recupere le numero du buffer de la visu
            set bufNo [ ::confVisu::getBufNo $visuNo ]
            #--- Je mets les mots cles des seuils a jour
            set kwds { "MIPS-HIR" "MIPS-LOR" "MIPS-HIG" "MIPS-LOG" "MIPS-HIB" "MIPS-LOB" }
            foreach kwd $kwds val $mycuts {
               #--- Je capture le mot cle existant
               set data [ buf$bufNo getkwd $kwd ]
               #--- Je remplace la valeur par la valeur actuelle
               set data [ lreplace $data 1 1 $val ]
               #--- Je sauve le mot cle modifie
               buf$bufNo setkwd $data
            }
            #--- J'enregistre l'image modifiee en changeant son nom
            ::audace::enregistrer_sous $visuNo
         }
         #---
         ::seuilCouleur::initSeuils
         set seuilCouleur(avancement) "$caption(seuilCouleur,fin_traitement)"
      } m ]
      if { $catchError == "1" } {
         tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error -message "$m"
         set seuilCouleur(avancement) ""
      }
      ::seuilCouleur::recupPosition $visuNo
   }

   #
   # ::seuilCouleur::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { visuNo } {
      global seuilCouleur

      ::seuilCouleur::recupPosition $visuNo
      destroy $seuilCouleur($visuNo,This)
      unset seuilCouleur($visuNo,This)
   }

   #
   # ::seuilCouleur::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1035balance_rvb.htm"
   }

   #
   # ::seuilCouleur::confirmerBlanc
   # Confirme la selection de la zone blanche de l'image
   #
   proc confirmerBlanc { visuNo } {
      global audace caption seuilCouleur

      #--- Retourne les coordonnees de la zone selectionnee avec la souris
      set box [ ::confVisu::getBox $visuNo ]
      if { $box == "" } {
         #--- J'initialise les seuils
         lassign [ list "" "" "" ] set seuilCouleur(blanc_R) seuilCouleur(blanc_V) seuilCouleur(blanc_B)
         #---
         tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
            -message "$caption(seuilCouleur,pas_selection_blanc)"
         return
      }

      #--- Calcule les coordonnees du centre de la zone selectionnee avec la souris
      set Xmoy [ expr int( ( [ lindex $box 2 ] + [ lindex $box 0 ] ) / 2. ) ]
      set Ymoy [ expr int( ( [ lindex $box 3 ] + [ lindex $box 1 ] ) / 2. ) ]

      #--- Je recupere le numero du buffer de la visu
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      #--- Retourne les intensites R, V et B du centre de la zone selectionnee avec la souris
      lassign [ buf$bufNo getpix [ list $Xmoy $Ymoy ] ] nihil seuilCouleur(blanc_R) seuilCouleur(blanc_V) seuilCouleur(blanc_B)

      #--- Suppression de la zone selectionnee avec la souris
      ::confVisu::deleteBox $visuNo
   }

   #
   # ::seuilCouleur::confirmerNoir
   # Confirme la selection de la zone noire de l'image
   #
   proc confirmerNoir { visuNo } {
      global audace caption seuilCouleur

      #--- Retourne les coordonnees de la zone selectionnee avec la souris
      set box [ ::confVisu::getBox $visuNo ]
      if { $box == "" } {
         #--- J'initialise les seuils
         lassign [ list "" "" "" ] set seuilCouleur(noir_R) seuilCouleur(noir_V) seuilCouleur(noir_B)
         #---
         tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
            -message "$caption(seuilCouleur,pas_selection_noir)"
         return
      }

      #--- Calcule les coordonnees du centre de la zone selectionnee avec la souris
      set Xmoy [ expr int( ( [ lindex $box 2 ] + [ lindex $box 0 ] ) / 2.0 ) ]
      set Ymoy [ expr int( ( [ lindex $box 3 ] + [ lindex $box 1 ] ) / 2.0 ) ]

      #--- Je recupere le numero du buffer de la visu
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      #--- Retourne les intensites R, V et B du centre de la zone selectionnee avec la souris
      lassign [ buf$bufNo getpix [ list $Xmoy $Ymoy ] ] nihil seuilCouleur(noir_R) seuilCouleur(noir_V) seuilCouleur(noir_B)

      #--- Suppression de la zone selectionnee avec la souris
      ::confVisu::deleteBox $visuNo
   }

   #
   # ::seuilCouleur::initSeuils
   # Initialise a vide les seuils maxi et mini de chaque couleur
   #
   proc initSeuils { } {
      global seuilCouleur

      lassign [ list "" "" "" "" "" "" ] seuilCouleur(blanc_R) seuilCouleur(blanc_V) \
         seuilCouleur(blanc_B) seuilCouleur(noir_R) seuilCouleur(noir_V) seuilCouleur(noir_B)
   }
}

########################## Fin du namespace seuilCouleur ##########################

