#
# Fichier : aud3.tcl
# Description : Interfaces graphiques pour les fonctions d'analyse d'images et de navigation dans les repertoires
# Date de mise a jour : 03 juillet 2005
#

namespace eval ::traiteWindow {
   variable This
   global traiteWindow

   proc initConf { } {
      global conf

      if { ! [ info exists conf(traiteWindow,position) ] } { set conf(traiteWindow,position) "+350+75" }

      return
   }

   proc confToWidget { } {  
      variable widget
      global conf

      set widget(traiteWindow,position) "$conf(traiteWindow,position)"
   }

   proc widgetToConf { } {   
      variable widget
      global conf

      set conf(traiteWindow,position) "$widget(traiteWindow,position)"
   }

   proc recup_position { } {
      variable This
      variable widget
      global traiteWindow

      set traiteWindow(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $traiteWindow(geometry) ] ]
      set fin [ string length $traiteWindow(geometry) ]
      set widget(traiteWindow,position) "+[string range $traiteWindow(geometry) $deb $fin]"
      #---
      ::traiteWindow::widgetToConf
   }	

   proc run { type_pretraitement this } {
      variable This
      variable widget
      global traiteWindow

      #---
      ::traiteWindow::initConf
      ::traiteWindow::confToWidget
      #---
      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         if { [ info exists traiteWindow(geometry) ] } {
            set deb [ expr 1 + [ string first + $traiteWindow(geometry) ] ]
            set fin [ string length $traiteWindow(geometry) ]
            set widget(traiteWindow,position) "+[string range $traiteWindow(geometry) $deb $fin]"     
         }
         createDialog
      }
      #---
      set traiteWindow(operation) "$type_pretraitement"
   }

   proc createDialog { } {
      variable This
      variable widget
      global audace
      global conf
      global caption
      global traiteWindow

      #--- Initialisation
      set traiteWindow(in)  ""
      set traiteWindow(out) ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,dialog,pretraitement)"
      wm geometry $This $widget(traiteWindow,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteWindow::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.0 -borderwidth 1 -relief raised
            label $This.usr.0.lab1 -textvariable "traiteWindow(formule)" -font $audace(font,arial_15_b)
            pack $This.usr.0.lab1 -padx 10 -pady 5
        # pack $This.usr.0 -side top -fill both

         frame $This.usr.6 -borderwidth 1 -relief raised
            frame $This.usr.6.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.6.1.che1 -text "$caption(afficher,image,fin)" -variable traiteWindow(4,disp)
               pack $This.usr.6.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.6.1 -side top -fill both
        # pack $This.usr.6 -side bottom -fill both

         frame $This.usr.5 -borderwidth 1 -relief raised
            frame $This.usr.5.1 -borderwidth 0 -relief flat
               button $This.usr.5.1.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 4 }
               pack $This.usr.5.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.5.1.lab8 -text "$caption(audace,image,noir:)"
               pack $This.usr.5.1.lab8 -side left -padx 5 -pady 5
               entry $This.usr.5.1.ent8 -textvariable traiteWindow(3,dark) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.5.1.ent8 -side right -padx 10 -pady 5
            pack $This.usr.5.1 -side top -fill both
            frame $This.usr.5.2 -borderwidth 0 -relief flat
               button $This.usr.5.2.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 5 }
               pack $This.usr.5.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.5.2.lab9 -text "$caption(audace,log,offset)"
               pack $This.usr.5.2.lab9 -side left -padx 5 -pady 5
               entry $This.usr.5.2.ent9 -textvariable traiteWindow(3,offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.5.2.ent9 -side right -padx 10 -pady 5
            pack $This.usr.5.2 -side top -fill both
        # pack $This.usr.5 -side bottom -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               button $This.usr.4.1.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 3 }
               pack $This.usr.4.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.4.1.lab6 -textvariable "traiteWindow(operande)"
               pack $This.usr.4.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.1.ent6 -textvariable traiteWindow(2,operand) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.4.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both
            frame $This.usr.4.2 -borderwidth 0 -relief flat
               label $This.usr.4.2.lab7 -textvariable "traiteWindow(constante)"
               pack $This.usr.4.2.lab7 -side left -padx 5 -pady 5
               entry $This.usr.4.2.ent7 -textvariable traiteWindow(2,const) -width 7 -font $audace(font,arial_8_b)
               pack $This.usr.4.2.ent7 -side right -padx 10 -pady 5
            pack $This.usr.4.2 -side top -fill both
        # pack $This.usr.4 -side bottom -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               label $This.usr.3.1.lab5 -textvariable "traiteWindow(constante)"
               pack $This.usr.3.1.lab5 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent5 -textvariable traiteWindow(1,const) -width 7 -font $audace(font,arial_8_b)
               pack $This.usr.3.1.ent5 -side right -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -side bottom -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               button $This.usr.2.2.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 1 }
               pack $This.usr.2.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.2.lab3 -textvariable "traiteWindow(image_A)"
               pack $This.usr.2.2.lab3 -side left -padx 5 -pady 5
               entry $This.usr.2.2.ent3 -textvariable traiteWindow(in) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.2.ent3 -side right -padx 10 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               entry $This.usr.2.1.ent2 -textvariable traiteWindow(nb) -width 7 -font $audace(font,arial_8_b)
               pack $This.usr.2.1.ent2 -side right -padx 10 -pady 5
               label $This.usr.2.1.lab2 -textvariable "traiteWindow(nombre)"
               pack $This.usr.2.1.lab2 -side right -padx 5 -pady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               button $This.usr.2.3.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 2 }
               pack $This.usr.2.3.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.3.lab4 -textvariable "traiteWindow(image_B)"
               pack $This.usr.2.3.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.3.ent4 -textvariable traiteWindow(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent4 -side right -padx 10 -pady 5
            pack $This.usr.2.3 -side top -fill both
         pack $This.usr.2 -side bottom -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -text "$caption(audace,menu,operation_serie)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteWindow [ list $caption(audace,run,median) $caption(audace,image,somme) \
               $caption(audace,image,moyenne) $caption(audace,image,ecart_type) $caption(audace,menu,offset) \
               $caption(audace,menu,noffset) $caption(audace,menu,ngain) $caption(audace,menu,addition) \
               $caption(audace,menu,soust) $caption(audace,menu,division) $caption(audace,optimisation,noir) ]
            #---
            menubutton $This.usr.1.but1 -textvariable traiteWindow(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretraitement $list_traiteWindow {
               $m add radiobutton -label "$pretraitement" \
                  -indicatoron "1" \
                  -value "$pretraitement" \
                  -variable traiteWindow(operation) \
                  -command { }
            }
         pack $This.usr.1 -side bottom -fill both -ipady 5
      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::traiteWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::traiteWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::traiteWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::traiteWindow::afficheAide } 
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable traiteWindow(operation) w ::traiteWindow::change

      #---
      bind $This <Key-Return> {::traiteWindow::cmdOk}
      bind $This <Key-Escape> {::traiteWindow::cmdClose}

      #--- Focus
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #---
      ::traiteWindow::formule
   }

   proc cmdOk { } {
      ::traiteWindow::cmdApply
      ::traiteWindow::cmdClose
   }

   proc cmdApply { } {
      variable This
      global audace
      global caption
      global traiteWindow

      #---
      set in $traiteWindow(in)
      set out $traiteWindow(out)
      set nb $traiteWindow(nb)

      #--- Switch pass� au format sur une seule ligne logique : les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'int�rieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      if { ( $in != "" ) && ( $out != "" ) && ( $nb != "" ) } {
         switch $traiteWindow(operation) \
            "$caption(audace,run,median)" {
               if { $out == "" } { set out "\#mediane" }
               smedian $in $out $nb
               if { $traiteWindow(4,disp) == 1 } {
                  loadima $out
                  ::audace::autovisu visu$audace(visuNo)
               }
            } \
            "$caption(audace,image,somme)" {
               if { $out == "" } { set out "\#somme" }
               sadd $in $out $nb
               if { $traiteWindow(4,disp) == 1 } {
                  loadima $out
                  ::audace::autovisu visu$audace(visuNo)
               }
            } \
            "$caption(audace,image,moyenne)" {
               if { $out == "" } { set out "\#moyenne" }
               smean $in $out $nb
               if { $traiteWindow(4,disp) == 1 } {
                  loadima $out
                  ::audace::autovisu visu$audace(visuNo)
               }
            } \
            "$caption(audace,image,ecart_type)" {
               if { $out == "" } { set out "\#sigma" }
               ssigma $in $out $nb "bitpix=-32"
               if { $traiteWindow(4,disp) == 1 } {
                  loadima $out
                  ::audace::autovisu visu$audace(visuNo)
               }
            } \
            "$caption(audace,menu,offset)" {
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "offset2 $in $out $const $nb"
               offset2 $in $out $const $nb
            } \
            "$caption(audace,menu,noffset)" {
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "noffset2 $in $out $const $nb"
               noffset2 $in $out $const $nb
            } \
            "$caption(audace,menu,ngain)" {
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "ngain2 $in $out $const $nb"
               ngain2 $in $out $const $nb
            } \
            "$caption(audace,menu,addition)" {
               set operand $traiteWindow(2,operand)
               set const $traiteWindow(2,const)
               ::console::affiche_resultat "add2 $in $operand $out $const $nb"
               add2 $in $operand $out $const $nb
            } \
            "$caption(audace,menu,soust)" {
               set operand $traiteWindow(2,operand)
               set const $traiteWindow(2,const)
               ::console::affiche_resultat "sub2 $in $operand $out $const $nb"
               sub2 $in $operand $out $const $nb
            } \
            "$caption(audace,menu,division)" {
               set operand $traiteWindow(2,operand)
               set const $traiteWindow(2,const)
               ::console::affiche_resultat "div2 $in $operand $out $const $nb"
               div2 $in $operand $out $const $nb
            } \
            "$caption(audace,optimisation,noir)" {
               set dark $traiteWindow(3,dark)
               set offset $traiteWindow(3,offset)
               ::console::affiche_resultat "opt2 $in $dark $offset $out $nb"
               opt2 $in $dark $offset $out $nb
            }
      }
      ::traiteWindow::recup_position
   }

   proc cmdClose { } {
      variable This

      ::traiteWindow::recup_position
      destroy $This
      unset This
   }

   proc afficheAide { } {
      global caption
      global help
      global traiteWindow

      #---
      if { $traiteWindow(operation) == $caption(audace,run,median) } {
         set traiteWindow(page_web) "1120serie_mediane"
      } elseif { $traiteWindow(operation) == $caption(audace,image,somme) } {
         set traiteWindow(page_web) "1130serie_somme"
      } elseif { $traiteWindow(operation) == $caption(audace,image,moyenne) } {
         set traiteWindow(page_web) "1140serie_moyenne"
      } elseif { $traiteWindow(operation) == $caption(audace,image,ecart_type) } {
         set traiteWindow(page_web) "1150serie_ecart_type"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,offset) } {
         set traiteWindow(page_web) "1160serie_somme_cte"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,noffset) } {
         set traiteWindow(page_web) "1170serie_norm_fond"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,ngain) } {
         set traiteWindow(page_web) "1180serie_norm_eclai"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,addition) } {
         set traiteWindow(page_web) "1190serie_addition"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,soust) } {
         set traiteWindow(page_web) "1200serie_soustraction"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,division) } {
         set traiteWindow(page_web) "1210serie_division"
      } elseif { $traiteWindow(operation) == $caption(audace,optimisation,noir) } {
         set traiteWindow(page_web) "1220serie_opt_noir"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$traiteWindow(page_web).htm"
   }

   proc change { n1 n2 op } {
      variable This
      global caption
      global traiteWindow

      #---
      ::traiteWindow::formule
      #---
      #--- Switch pass� au format sur une seule ligne logique : les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'int�rieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteWindow(operation) \
         "$caption(audace,run,median)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
         } \
         "$caption(audace,image,somme)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
         } \
         "$caption(audace,image,moyenne)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
         } \
         "$caption(audace,image,ecart_type)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
         } \
         "$caption(audace,menu,offset)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
         } \
         "$caption(audace,menu,noffset)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
         } \
         "$caption(audace,menu,ngain)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
         } \
         "$caption(audace,menu,addition)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack forget $This.usr.6
         } \
         "$caption(audace,menu,soust)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack forget $This.usr.6
         } \
         "$caption(audace,menu,division)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack forget $This.usr.6
         } \
         "$caption(audace,optimisation,noir)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack $This.usr.5 -in $This.usr -side top -fill both
            pack forget $This.usr.6
         }
     # ::console::affiche_erreur "$n1,$n2,$op,$traiteWindow(operation)\n"
   }

   proc parcourir { In_Out } {
      global audace
      global traiteWindow

      #--- Fenetre parent
      set fenetre "$audace(base).traiteWindow"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         set traiteWindow(in) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "2" } {
         set traiteWindow(out) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "3" } {
         set traiteWindow(2,operand) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "4" } {
         set traiteWindow(3,dark) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "5" } {
         set traiteWindow(3,offset) [ file rootname [ file tail $filename ] ]
      }
   }

   proc formule { } {
      global caption
      global traiteWindow

      if { $traiteWindow(operation) == "$caption(audace,image,somme)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(formule)   "$caption(audace,formule) B = A1 + A2 + ... + An"
      } elseif { $traiteWindow(operation) == "$caption(audace,image,moyenne)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(formule)   "$caption(audace,formule) B = ( A1 + A2 + ... + An ) / n"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,offset)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,ajouter)"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An + Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,addition)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,ajouter)"
         set traiteWindow(operande)  "$caption(audace,image,operande-) ( C ) :"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An + C + Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,soust)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,ajouter)"
         set traiteWindow(operande)  "$caption(audace,image,operande-) ( C ) :"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An - C + Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,division)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,multiplicative)"
         set traiteWindow(operande)  "$caption(audace,image,operande-) ( C ) :"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = ( An / C ) x Cte"
      } else {
         set traiteWindow(image_A)   "$caption(audace,images,entree)"
         set traiteWindow(nombre)    "$caption(audace,image,nombre)"
         set traiteWindow(image_B)   "$caption(audace,images,sortie)"
         set traiteWindow(constante) "$caption(valeur,fond,ciel)"
         set traiteWindow(operande)  "$caption(audace,image,operande)"
         set traiteWindow(formule)   ""
      }
   }

}

namespace eval ::traiteFilters {
   variable This
   global traiteFilters

   proc initConf { } {
      global conf

      if { ! [ info exists conf(coef_etal) ] }              { set conf(coef_etal)              "2.0" }
      if { ! [ info exists conf(coef_mult) ] }              { set conf(coef_mult)              "5.0" }
      if { ! [ info exists conf(traiteFilters,position) ] } { set conf(traiteFilters,position) "+350+75" }

      return
   }

   proc confToWidget { } {  
      variable widget
      global conf

      set widget(traiteFilters,position) "$conf(traiteFilters,position)"
   }

   proc widgetToConf { } {   
      variable widget
      global conf

      set conf(traiteFilters,position) "$widget(traiteFilters,position)"
   }

   proc recup_position { } {
      variable This
      variable widget
      global traiteFilters

      set traiteFilters(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $traiteFilters(geometry) ] ]
      set fin [ string length $traiteFilters(geometry) ]
      set widget(traiteFilters,position) "+[string range $traiteFilters(geometry) $deb $fin]"
      #---
      ::traiteFilters::widgetToConf
   }	

   proc run { type_filtre this } {
      variable This
      variable widget
      global conf
      global caption
      global traiteFilters

      #---
      ::traiteFilters::initConf
      ::traiteFilters::confToWidget
      #---
      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         if { [ info exists traiteFilters(geometry) ] } {
            set deb [ expr 1 + [ string first + $traiteFilters(geometry) ] ]
            set fin [ string length $traiteFilters(geometry) ]
            set widget(traiteFilters,position) "+[string range  $traiteFilters(geometry) $deb $fin]"     
         }
         createDialog
      }
      #---
      set traiteFilters(operation) "$type_filtre"
   }

   proc createDialog { } {
      variable This
      variable widget
      global audace
      global conf
      global caption
      global traiteFilters

      #--- Initialisation
      set traiteFilters(choix) "0"
      set traiteFilters(image) ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,traitement)"
      wm geometry $This $widget(traiteFilters,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteFilters::cmdClose
      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.0 -borderwidth 1 -relief raised
            #--- Bouton radio image_affichee
            radiobutton $This.usr.0.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
               -text "$caption(audace,image,image_affichee)" -value 0 -variable traiteFilters(choix) \
               -command { ::traiteFilters::griser "$audace(base).traiteFilters" }
	      pack $This.usr.0.rad0 -anchor center -side left -padx 5
            #--- Bouton radio image a choisir
            radiobutton $This.usr.0.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
               -text "$caption(audace,image,image_a_choisir)" -value 1 -variable traiteFilters(choix) \
               -command { ::traiteFilters::activer "$audace(base).traiteFilters" }
	      pack $This.usr.0.rad1 -anchor center -side right -padx 5
         pack $This.usr.0 -side top -fill both -ipady 5

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -text "$caption(audace,menu,filtres)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des traitements disponibles
            set list_traiteFilters [ list $caption(audace,menu,masque_flou) $caption(audace,menu,filtre_passe-bas) \
               $caption(audace,menu,filtre_passe-haut) $caption(audace,menu,filtre_median) \
               $caption(audace,menu,filtre_minimum) $caption(audace,menu,filtre_maximum) \
               $caption(audace,menu,filtre_gaussien) $caption(audace,menu,ond_morlet) $caption(audace,menu,ond_mexicain) \
               $caption(audace,menu,log) ]
            #---
            menubutton $This.usr.1.but1 -textvariable traiteFilters(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach traitement $list_traiteFilters {
               $m add radiobutton -label "$traitement" \
                  -indicatoron "1" \
                  -value "$traitement" \
                  -variable traiteFilters(operation) \
                  -command { }
            }
         pack $This.usr.1 -side top -fill both -ipady 5

         frame $This.usr.2 -borderwidth 1 -relief raised
           frame $This.usr.3a -borderwidth 0 -relief raised
               frame $This.usr.3a.1 -borderwidth 0 -relief flat
                  button $This.usr.3a.1.explore -text "$caption(script,parcourir)" -width 1 \
                     -command { ::traiteFilters::parcourir }
                  pack $This.usr.3a.1.explore -side left -padx 10 -pady 5 -ipady 5
                  label $This.usr.3a.1.lab1 -text "$caption(audace,image,entree)"
                  pack $This.usr.3a.1.lab1 -side left -padx 5 -pady 5
                  entry $This.usr.3a.1.ent1 -textvariable traiteFilters(image) -width 50 -font $audace(font,arial_8_b)
                  pack $This.usr.3a.1.ent1 -side right -padx 10 -pady 5
               pack $This.usr.3a.1 -side top -fill both
           # pack $This.usr.3a -side top -fill both

           frame $This.usr.3b -borderwidth 0 -relief raised
               frame $This.usr.3b.1 -borderwidth 0 -relief flat
                  button $This.usr.3b.1.explore -text "$caption(script,parcourir)" -width 1 \
                     -command { ::traiteFilters::parcourir }
                  pack $This.usr.3b.1.explore -side left -padx 10 -pady 5 -ipady 5
                  label $This.usr.3b.1.lab1 -text "$caption(audace,image,entree)"
                  pack $This.usr.3b.1.lab1 -side left -padx 5 -pady 5
                  entry $This.usr.3b.1.ent1 -textvariable traiteFilters(image) -width 50 -font $audace(font,arial_8_b)
                  pack $This.usr.3b.1.ent1 -side left -padx 10 -pady 5
               pack $This.usr.3b.1 -side top -fill both
           # pack $This.usr.3b -side top -fill both

            frame $This.usr.4 -borderwidth 0 -relief raised
               frame $This.usr.4.1 -borderwidth 0 -relief flat
                  button $This.usr.4.1.but_defaut -text "$caption(audace,valeur_par_defaut)" \
                     -command { ::traiteFilters::val_defaut }
                 # pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                  entry $This.usr.4.1.ent2 -textvariable traiteFilters(coef_etal) -width 10 -font $audace(font,arial_8_b)
                  pack $This.usr.4.1.ent2 -side right -padx 10 -pady 5
                  label $This.usr.4.1.lab2 -text "$caption(audace,coef,etalement)"
                  pack $This.usr.4.1.lab2 -side right -padx 5 -pady 5
               pack $This.usr.4.1 -side top -fill both
           # pack $This.usr.4 -side top -fill both

            frame $This.usr.5 -borderwidth 0 -relief raised
               frame $This.usr.5.1 -borderwidth 0 -relief flat
                  button $This.usr.5.1.but_defaut -text "$caption(audace,valeur_par_defaut)" \
                     -command { ::traiteFilters::val_defaut }
                 # pack $This.usr.5.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                  entry $This.usr.5.1.ent3 -textvariable traiteFilters(coef_mult) -width 10 -font $audace(font,arial_8_b)
                  pack $This.usr.5.1.ent3 -side right -padx 10 -pady 5
                  label $This.usr.5.1.lab3 -text "$caption(audace,coef,mult)"
                  pack $This.usr.5.1.lab3 -side right -padx 5 -pady 5
               pack $This.usr.5.1 -side top -fill both
           # pack $This.usr.5 -side top -fill both

            frame $This.usr.6 -borderwidth 0 -relief raised
               frame $This.usr.6.1 -borderwidth 0 -relief flat
                  label $This.usr.6.1.lab4 -text "$caption(audace,coef,efficacite)"
                  pack $This.usr.6.1.lab4 -side left -padx 5 -pady 5
                  entry $This.usr.6.1.ent4 -textvariable traiteFilters(efficacite) -width 4 -font $audace(font,arial_8_b)
                  pack $This.usr.6.1.ent4 -side left -padx 10 -pady 5
               pack $This.usr.6.1 -side left -fill both
               frame $This.usr.6.2 -borderwidth 0 -relief flat
                  frame $This.usr.6.2.1 -borderwidth 0 -relief flat
                     #--- Glissiere de reglage de l'efficacite du filtre
                     scale $This.usr.6.2.1.efficacite_variant -from 0 -to 1 -length 300 -orient horizontal \
                        -showvalue true -tickinterval 1 -resolution 0.01 -borderwidth 2 -relief groove \
                        -variable traiteFilters(efficacite) -width 10
                     pack $This.usr.6.2.1.efficacite_variant -side top -padx 7 -pady 5
                  pack $This.usr.6.2.1 -side top -fill both
                  frame $This.usr.6.2.2 -borderwidth 0 -relief flat
                     label $This.usr.6.2.2.lab5 -text "$caption(audace,efficacite,max)"
                     pack $This.usr.6.2.2.lab5 -side left -padx 7 -pady 5
                     label $This.usr.6.2.2.lab6 -text "$caption(audace,efficacite,min)"
                     pack $This.usr.6.2.2.lab6 -side right -padx 10 -pady 5
                  pack $This.usr.6.2.2 -side top -fill both
               pack $This.usr.6.2 -side right -fill both
           # pack $This.usr.6 -side top -fill both

            frame $This.usr.7 -borderwidth 0 -relief raised
               frame $This.usr.7.1 -borderwidth 0 -relief flat
                  entry $This.usr.7.1.ent5 -textvariable traiteFilters(offset) -width 10 -font $audace(font,arial_8_b)
                  pack $This.usr.7.1.ent5 -side right -padx 10 -pady 5
                  label $This.usr.7.1.lab7 -text "$caption(audace,log,offset)"
                  pack $This.usr.7.1.lab7 -side right -padx 5 -pady 5
               pack $This.usr.7.1 -side top -fill both
           # pack $This.usr.7 -side top -fill both
         pack $This.usr.2 -side top -fill both -ipady 5

      pack $This.usr -side top -fill both -expand 1
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::traiteFilters::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::traiteFilters::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::traiteFilters::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::traiteFilters::afficheAide } 
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $This.cmd -side top -fill x
      #--- Entry actives ou non
      if { $traiteFilters(choix) == "0" } {
         ::traiteFilters::griser "$audace(base).traiteFilters"
      } else {
         ::traiteFilters::activer "$audace(base).traiteFilters"
      }
      #---
      uplevel #0 trace variable traiteFilters(operation) w ::traiteFilters::change
      #---
      bind $This <Key-Return> {::traiteFilters::cmdOk}
      bind $This <Key-Escape> {::traiteFilters::cmdClose}
      #--- Focus
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   proc cmdApply { } {
      variable This
      global conf
      global audace
      global caption
      global traiteFilters

      #---
      set audace(artifice) "@@@@"
      set image $traiteFilters(image)
      set coef_etal $traiteFilters(coef_etal)
      set coef_mult $traiteFilters(coef_mult)
      set efficacite $traiteFilters(efficacite)
      set offset $traiteFilters(offset)
      #--- Sauvegarde des reglages
      set conf(coef_etal) $traiteFilters(coef_etal)
      set conf(coef_mult) $traiteFilters(coef_mult)
      #--- Switch pass� au format sur une seule ligne logique : les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'int�rieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteFilters(operation) \
         "$caption(audace,menu,masque_flou)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_masque_flou $image $coef_etal $coef_mult\n"
               bm_masque_flou $image $coef_etal $coef_mult
            } else {
               ::console::affiche_resultat "bm_masque_flou $caption(audace,filtre_image_affichee) $coef_etal $coef_mult\n"
               bm_masque_flou "$audace(artifice)" $coef_etal $coef_mult
            }
         } \
         "$caption(audace,menu,filtre_passe-bas)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_passe_bas $image $efficacite\n"
               bm_passe_bas $image $efficacite
            } else {
               ::console::affiche_resultat "bm_passe_bas $caption(audace,filtre_image_affichee) $efficacite\n"
               bm_passe_bas "$audace(artifice)" $efficacite
            }
         } \
         "$caption(audace,menu,filtre_passe-haut)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_passe_haut $image $efficacite\n"
               bm_passe_haut $image $efficacite
            } else {
               ::console::affiche_resultat "bm_passe_haut $caption(audace,filtre_image_affichee) $efficacite\n"
               bm_passe_haut "$audace(artifice)" $efficacite
            }
         } \
         "$caption(audace,menu,filtre_median)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_filtre_median $image $efficacite\n"
               bm_filtre_median $image $efficacite
            } else {
               ::console::affiche_resultat "bm_filtre_median $caption(audace,filtre_image_affichee) $efficacite\n"
               bm_filtre_median "$audace(artifice)" $efficacite
            }
         } \
         "$caption(audace,menu,filtre_minimum)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_filtre_min $image $efficacite\n"
               bm_filtre_min $image $efficacite
            } else {
               ::console::affiche_resultat "bm_filtre_min $caption(audace,filtre_image_affichee) $efficacite\n"
               bm_filtre_min "$audace(artifice)" $efficacite
            }
         } \
         "$caption(audace,menu,filtre_maximum)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_filtre_max $image $efficacite\n"
               bm_filtre_max $image $efficacite
            } else {
               ::console::affiche_resultat "bm_filtre_max $caption(audace,filtre_image_affichee) $efficacite\n"
               bm_filtre_max "$audace(artifice)" $efficacite
            }
         } \
         "$caption(audace,menu,filtre_gaussien)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_filtre_gauss $image $coef_etal\n"
               bm_filtre_gauss $image $coef_etal
            } else {
               ::console::affiche_resultat "bm_filtre_gauss $caption(audace,filtre_image_affichee) $coef_etal\n"
               bm_filtre_gauss "$audace(artifice)" $coef_etal
            }
         } \
         "$caption(audace,menu,ond_morlet)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_ondelette_mor $image $coef_etal\n"
               bm_ondelette_mor $image $coef_etal
            } else {
               ::console::affiche_resultat "bm_ondelette_mor $caption(audace,filtre_image_affichee) $coef_etal\n"
               bm_ondelette_mor "$audace(artifice)" $coef_etal
            }
         } \
         "$caption(audace,menu,ond_mexicain)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_ondelette_mex $image $coef_etal\n"
               bm_ondelette_mex $image $coef_etal
            } else {
               ::console::affiche_resultat "bm_ondelette_mex $caption(audace,filtre_image_affichee) $coef_etal\n"
               bm_ondelette_mex "$audace(artifice)" $coef_etal
            }
         } \
         "$caption(audace,menu,log)" {
            if { $traiteFilters(choix) == "1" } {
               ::console::affiche_resultat "bm_logima $image $coef_mult $offset\n"
               bm_logima $image $coef_mult $offset
            } else {
               ::console::affiche_resultat "bm_logima $caption(audace,filtre_image_affichee) $coef_mult $offset\n"
               bm_logima "$audace(artifice)" $coef_mult $offset
            }
         }
      ::traiteFilters::recup_position
   }

   proc afficheAide { } {
      global caption
      global help
      global traiteFilters

      #---
      if { $traiteFilters(operation) == $caption(audace,menu,masque_flou) } {
         set traiteFilters(page_web) "1010masque_flou"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,filtre_passe-bas) } {
         set traiteFilters(page_web) "1020passe_bas"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,filtre_passe-haut) } {
         set traiteFilters(page_web) "1030passe_haut"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,filtre_median) } {
         set traiteFilters(page_web) "1040median"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,filtre_minimum) } {
         set traiteFilters(page_web) "1050minimum"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,filtre_maximum) } {
         set traiteFilters(page_web) "1060maximum"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,filtre_gaussien) } {
         set traiteFilters(page_web) "1070gaussien"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,ond_morlet) } {
         set traiteFilters(page_web) "1080morlet"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,ond_mexicain) } {
         set traiteFilters(page_web) "1090mexicain"
      } elseif { $traiteFilters(operation) == $caption(audace,menu,log) } {
         set traiteFilters(page_web) "1100logarithme"
      }

      #---
      ::audace::showHelpItem "$help(dir,trait)" "$traiteFilters(page_web).htm"
   }

   proc cmdClose { } {
      variable This
      global traiteFilters

      ::traiteFilters::recup_position
      destroy $This
      unset This
   }

   proc change { n1 n2 op } {
      variable This
      global conf
      global audace
      global caption
      global traiteFilters

      #--- Initialisation des variables
      set traiteFilters(coef_etal) $conf(coef_etal)
      set traiteFilters(coef_mult) $conf(coef_mult)
      #--- Switch pass� au format sur une seule ligne logique : les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'int�rieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteFilters(operation) \
         "$caption(audace,menu,masque_flou)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3a -in $This.usr.2 -side top -fill both
            pack $This.usr.4 -in $This.usr.2 -side top -fill both
            pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
            pack $This.usr.5 -in $This.usr.2 -side top -fill both
         } \
         "$caption(audace,menu,filtre_passe-bas)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3b -in $This.usr.2 -side top -fill both
            pack $This.usr.6 -in $This.usr.2 -side top -fill both
         } \
         "$caption(audace,menu,filtre_passe-haut)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3b -in $This.usr.2 -side top -fill both
            pack $This.usr.6 -in $This.usr.2 -side top -fill both
         } \
         "$caption(audace,menu,filtre_median)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3b -in $This.usr.2 -side top -fill both
            pack $This.usr.6 -in $This.usr.2 -side top -fill both
         } \
         "$caption(audace,menu,filtre_minimum)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3b -in $This.usr.2 -side top -fill both
            pack $This.usr.6 -in $This.usr.2 -side top -fill both
         } \
         "$caption(audace,menu,filtre_maximum)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3b -in $This.usr.2 -side top -fill both
            pack $This.usr.6 -in $This.usr.2 -side top -fill both
         } \
         "$caption(audace,menu,filtre_gaussien)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3a -in $This.usr.2 -side top -fill both
            pack $This.usr.4 -in $This.usr.2 -side top -fill both
            pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
         } \
         "$caption(audace,menu,ond_morlet)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3a -in $This.usr.2 -side top -fill both
            pack $This.usr.4 -in $This.usr.2 -side top -fill both
            pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
         } \
         "$caption(audace,menu,ond_mexicain)" {
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3a -in $This.usr.2 -side top -fill both
            pack $This.usr.4 -in $This.usr.2 -side top -fill both
            pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
         } \
         "$caption(audace,menu,log)" {
            catch {
               set traiteFilters(offset) [ lindex [ buf$audace(bufNo) autocuts ] 1 ]
            }
            pack forget $This.usr.3a
            pack forget $This.usr.3b
            pack forget $This.usr.4
            pack forget $This.usr.4.1.but_defaut
            pack forget $This.usr.5
            pack forget $This.usr.5.1.but_defaut
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.3a -in $This.usr.2 -side top -fill both
            pack $This.usr.5 -in $This.usr.2 -side top -fill both
            pack $This.usr.5.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
            pack $This.usr.7 -in $This.usr.2 -side top -fill both
         }
   }

   proc parcourir { } {
      global audace
      global traiteFilters

      #--- Fenetre parent
      set fenetre "$audace(base).traiteFilters"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Nom du fichier avec le chemin et sans son extension
      set traiteFilters(image) [ file rootname $filename ]
   }

   proc val_defaut { } {
      variable This
      global caption
      global traiteFilters

      #--- Re-initialise les coefficients d'etalement et multiplicatif
      if { $traiteFilters(operation) == "$caption(audace,menu,masque_flou)" } {
         set traiteFilters(coef_etal) "0.8"
         set traiteFilters(coef_mult) "1.3"
      } elseif { $traiteFilters(operation) == "$caption(audace,menu,filtre_gaussien)" } {
         set traiteFilters(coef_etal) "0.5"
      } elseif { $traiteFilters(operation) == "$caption(audace,menu,ond_morlet)" } {
         set traiteFilters(coef_etal) "2.0"
      } elseif { $traiteFilters(operation) == "$caption(audace,menu,ond_mexicain)" } {
         set traiteFilters(coef_etal) "2.0"
      } elseif { $traiteFilters(operation) == "$caption(audace,menu,log)" } {
         set traiteFilters(coef_mult) "20.0"
      }
   }

   proc griser { this } {
      variable This

      #--- Fonction destinee a inhiber et griser des widgets
      set This $this
	$This.usr.3a.1.explore configure -state disabled
	$This.usr.3a.1.ent1 configure -state disabled
	$This.usr.3b.1.explore configure -state disabled
	$This.usr.3b.1.ent1 configure -state disabled
   }

   proc activer { this } {
      variable This

      #--- Fonction destinee a activer des widgets
      set This $this
	$This.usr.3a.1.explore configure -state normal
	$This.usr.3a.1.ent1 configure -state normal
	$This.usr.3b.1.explore configure -state normal
	$This.usr.3b.1.ent1 configure -state normal
   }

}

#
# cwdWindow -> Change Working Directory
#
namespace eval ::cwdWindow {
   variable This
   global cwdWindow

   proc run { this } {
      variable This
      global audace
      global cwdWindow

      #---
      if { [info exists This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
	   set cwdWindow(dir_images) $audace(rep_images)
	   set cwdWindow(dir_scripts) $audace(rep_scripts)
	   set cwdWindow(dir_catalogues) $audace(rep_catalogues)
	   set cwdWindow(long) [string length $cwdWindow(dir_images)]
	   if {[string length $cwdWindow(dir_scripts)] > $cwdWindow(long)} {
		set cwdWindow(long) [string length $cwdWindow(dir_scripts)]
	   }
	   if {[string length $cwdWindow(dir_catalogues)] > $cwdWindow(long)} {
		set cwdWindow(long) [string length $cwdWindow(dir_catalogues)]
	   }
	   set cwdWindow(long) [expr $cwdWindow(long) + 10]
         createDialog
      }
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global cwdWindow

      #--- Nom du sous-repertoire
      set date [clock format [clock seconds] -format "%y%m%d"]
      set cwdWindow(sous_repertoire) $date
      #---
      toplevel $This
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This "$caption(audace,menu,cwd)"
      wm protocol $This WM_DELETE_WINDOW ::cwdWindow::cmdClose
      #--- Initialisation des variables de changement
      set cwdWindow(rep_images)     "0"
      set cwdWindow(rep_scripts)    "0"
      set cwdWindow(rep_catalogues) "0"
      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.a -borderwidth 0 -relief raised
               button $This.usr.1.a.explore -text "$caption(script,parcourir)" -width 1 \
                  -command { ::cwdWindow::change_rep_images }
               pack $This.usr.1.a.explore -side left -padx 5 -pady 5 -ipady 5
               label $This.usr.1.a.lab1 -text "$caption(audace,dialog,repertoire_images)"
               pack $This.usr.1.a.lab1 -side left -padx 5 -pady 5
               entry $This.usr.1.a.ent1 -textvariable cwdWindow(dir_images) -width $cwdWindow(long)
               pack $This.usr.1.a.ent1 -side right -padx 5 -pady 5
            pack $This.usr.1.a -side top -fill both -expand 1
            frame $This.usr.1.b -borderwidth 0 -relief raised
              #--- Label nouveau sous-repertoire
               label $This.usr.1.b.label_sous_rep -text "$caption(audace,label_sous_rep)"
               pack $This.usr.1.b.label_sous_rep -side left -padx 5 -pady 5
               #--- Entry nouveau sous-repertoire
               entry $This.usr.1.b.ent_sous_rep -textvariable cwdWindow(sous_repertoire) -width 30
               pack $This.usr.1.b.ent_sous_rep -side left -padx 5 -pady 5
               #--- Button creation du sous-repertoire
               button $This.usr.1.b.button_sous_rep -text "$caption(audace,creation_sous_rep)" -width 7 \
                  -command { ::cwdWindow::cmdCreateSubDir }
               pack $This.usr.1.b.button_sous_rep -side left -padx 5 -pady 5 -ipady 5
            pack $This.usr.1.b -side top -fill both -expand 1
         pack $This.usr.1 -side top -fill both -expand 1
         frame $This.usr.2 -borderwidth 1 -relief raised
            button $This.usr.2.explore -text "$caption(script,parcourir)" -width 1 \
               -command { ::cwdWindow::change_rep_scripts }
            pack $This.usr.2.explore -side left -padx 5 -pady 5 -ipady 5
            label $This.usr.2.lab2 -text "$caption(audace,dialog,repertoire_scripts)"
            pack $This.usr.2.lab2 -side left -padx 5 -pady 5
            entry $This.usr.2.ent2 -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long)
            pack $This.usr.2.ent2 -side right -padx 5 -pady 5
         pack $This.usr.2 -side top -fill both -expand 1
         frame $This.usr.3 -borderwidth 1 -relief raised
            button $This.usr.3.explore -text "$caption(script,parcourir)" -width 1 \
               -command { ::cwdWindow::change_rep_catalogues }
            pack $This.usr.3.explore -side left -padx 5 -pady 5 -ipady 5
            label $This.usr.3.lab3 -text "$caption(audace,dialog,repertoire_catalogues)"
            pack $This.usr.3.lab3 -side left -padx 5 -pady 5
            entry $This.usr.3.ent3 -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long)
            pack $This.usr.3.ent3 -side right -padx 5 -pady 5
         pack $This.usr.3 -side top -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) [ $This.usr.1.a.ent1 cget -font ]
      #---
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::cwdWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::cwdWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::cwdWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::cwdWindow::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x
      #---
      bind $This <Key-Return> {::cwdWindow::cmdOk}
      bind $This <Key-Escape> {::cwdWindow::cmdClose}
      #--- La fenetre est active
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc cmdCreateSubDir { } {
      variable This
      global cwdWindow

      set subDirectory [ file join $cwdWindow(dir_images) $cwdWindow(sous_repertoire) ]
      set command "file mkdir $subDirectory"
      file mkdir $subDirectory
      set cwdWindow(dir_images) $subDirectory
      update
      focus $This.usr.1.a.ent1
      event generate $This.usr.1.a.ent1 <Control-e> 
   }

   proc tkplus_chooseDir { { inidir . } { title } { parent } } {
      global cwdWindow

	if {$inidir=="."} {
         set inidir [pwd]
	}
      if { $cwdWindow(rep_images) == "1" } {
         set cwdWindow(rep_images) "0"
      } elseif { $cwdWindow(rep_scripts) == "1" } {
         set cwdWindow(rep_scripts) "0"
      } elseif { $cwdWindow(rep_catalogues) == "1" } {
         set cwdWindow(rep_catalogues) "0"
      }
	set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]
	if {$res==""} {
         return "$inidir"
      } else {
         return "$res"
      }
   }

   proc change_rep_images { } {
      variable This
      global caption
      global cwdWindow

      #---
      set cwdWindow(rep_font) "$cwdWindow(rep_font) normal"
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_images) "1"
      $This.usr.1.a.ent1 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir $cwdWindow(dir_images)
      set title $caption(audace,dialog,repertoire_images)
      set cwdWindow(dir_images) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.1.a.ent1 configure -textvariable cwdWindow(dir_images) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.1
   }

   proc change_rep_scripts { } {
      variable This
      global caption
      global cwdWindow

      #---
      set cwdWindow(rep_font) "$cwdWindow(rep_font) normal"
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_scripts) "1"
      $This.usr.2.ent2 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir $cwdWindow(dir_scripts)
      set title $caption(audace,dialog,repertoire_scripts)
      set cwdWindow(dir_scripts) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.2.ent2 configure -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.2
   }

   proc change_rep_catalogues { } {
      variable This
      global caption
      global cwdWindow

      #---
      set cwdWindow(rep_font) "$cwdWindow(rep_font) normal"
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_catalogues) "1"
      $This.usr.3.ent3 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir $cwdWindow(dir_catalogues)
      set title $caption(audace,dialog,repertoire_catalogues)
      set cwdWindow(dir_catalogues) "[ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]"
      $This.usr.3.ent3 configure -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.3
   }

   proc cmdOk { } {
      if {[cmdApply] == 0} {
	   cmdClose
      }
   }

   proc cmdApply { } {
      global audace
      global conf
      global caption
      global cwdWindow

      #---
      save_cursor
      all_cursor watch
      #--- Substituer les \ par des /
      regsub -all {[\\]} $cwdWindow(dir_images) "/" cwdWindow(dir_images)
      regsub -all {[\\]} $cwdWindow(dir_scripts) "/" cwdWindow(dir_scripts)
      regsub -all {[\\]} $cwdWindow(dir_catalogues) "/" cwdWindow(dir_catalogues)

      if {[file exists "$cwdWindow(dir_images)"] && [file isdirectory "$cwdWindow(dir_images)"]} {
	  set conf(rep_images) "$cwdWindow(dir_images)"
	  set audace(rep_images) "$cwdWindow(dir_images)"
      } else {
	  set m "$cwdWindow(dir_images)"
	  append m "$caption(audace,boite,pas_repertoire)"
	  tk_messageBox -message $m -title "$caption(audace,boite,erreur)"
	  restore_cursor
	  return -1
      }

      if {[file exists "$cwdWindow(dir_scripts)"] && [file isdirectory "$cwdWindow(dir_scripts)"]} {
	  set conf(rep_scripts) "$cwdWindow(dir_scripts)"
	  set audace(rep_scripts) "$cwdWindow(dir_scripts)"
      } else {
	  set m "$cwdWindow(dir_scripts)"
	  append m "$caption(audace,boite,pas_repertoire)"
	  tk_messageBox -message $m -title "$caption(audace,boite,erreur)"
	  restore_cursor
	  return -1
      }

      if {[file exists "$cwdWindow(dir_catalogues)"] && [file isdirectory "$cwdWindow(dir_catalogues)"]} {
	  set conf(rep_catalogues) "$cwdWindow(dir_catalogues)"
	  set audace(rep_catalogues) "$cwdWindow(dir_catalogues)"
      } else {
	  set m "$cwdWindow(dir_catalogues)"
	  append m "$caption(audace,boite,pas_repertoire)"
	  tk_messageBox -message $m -title "$caption(audace,boite,erreur)"
	  restore_cursor
	  return -1
      }

      restore_cursor
      return 0
   }

   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1020repertoire.htm"
   }

   proc cmdClose { } {
      variable This
      global cwdWindow

      set cwdWindow(geometry) [wm geometry $This]
      destroy $This
      unset This
   }

}

#
# seuilWindow -> Reglages lies aux seuils de visualisation
#
namespace eval ::seuilWindow {
   variable This
   global seuilWindow

   proc run { this } {
      variable This
      global audace
      global seuilWindow

      #---
      if { [info exists This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         set seuilWindow(max) $audace(maxdyn)
         set seuilWindow(min) $audace(mindyn)
         createDialog
      }
   }

   proc initConf { } {
      global conf

      if { ! [ info exists conf(seuils,auto_manuel) ] }        { set conf(seuils,auto_manuel)        "1" }
      if { ! [ info exists conf(pourcentage_dynamique) ] }     { set conf(pourcentage_dynamique)     "50" }
      if { ! [ info exists conf(seuils,mode) ] }               { set conf(seuils,mode)               "histoauto" }
      if { ! [ info exists conf(seuils,irisautohaut) ] }       { set conf(seuils,irisautohaut)       "1000" }
      if { ! [ info exists conf(seuils,irisautobas) ] }        { set conf(seuils,irisautobas)        "200" }
      if { ! [ info exists conf(seuils,histoautohaut) ] }      { set conf(seuils,histoautohaut)      "99" }
      if { ! [ info exists conf(seuils,histoautobas) ] }       { set conf(seuils,histoautobas)       "3" }
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global tmp
      global seuilWindow

      #---
      set seuilWindow(choix_dynamique) "65535 32767 20000 10000 5000 2000 1000 500 200 0 -500 -1000 -32768"

      #---
      set seuilWindow(seuilWindowAuto_Manuel) $conf(seuils,auto_manuel)
      set seuilWindow(pourcentage_dynamique)  $conf(pourcentage_dynamique)

      #---
      if { ! [ info exists conf(seuils,position) ] } { set conf(seuils,position) "+0+0" }

      if { [ info exists conf(fenseuils,geometry) ] } {
         set deb [ expr 1 + [ string first + $conf(fenseuils,geometry) ] ]
         set fin [ string length $conf(fenseuils,geometry) ]
         set conf(seuils,position) "+[string range $conf(fenseuils,geometry) $deb $fin]"     
      }

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(seuils,titre)"
      wm geometry $This $conf(seuils,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::seuilWindow::cmdClose

      #--- Sauvegarde des anciens reglages
      set tmp(seuils,mode)           $conf(seuils,mode)
      set tmp(seuils,irisautohaut)   $conf(seuils,irisautohaut)
      set tmp(seuils,irisautobas)    $conf(seuils,irisautobas)
      set tmp(seuils,histoautohaut)  $conf(seuils,histoautohaut)
      set tmp(seuils,histoautobas)   $conf(seuils,histoautobas)

      #--- Sauveagarde des r�glages courants
      set tmp(seuils,mode_)          $conf(seuils,mode)
      set tmp(seuils,irisautohaut_)  $conf(seuils,irisautohaut)
      set tmp(seuils,irisautobas_)   $conf(seuils,irisautobas)
      set tmp(seuils,histoautohaut_) $conf(seuils,histoautohaut)
      set tmp(seuils,histoautobas_)  $conf(seuils,histoautobas)

      #---
      frame $This.usr2 -borderwidth 1 -relief raised

         frame $This.usr2.1 -borderwidth 0 -relief flat
            label $This.usr2.1.lab1 -text "$caption(audace,dynamique)"
            pack $This.usr2.1.lab1 -side left -padx 10
            radiobutton $This.usr2.1.rad1 -variable seuilWindow(seuilWindowAuto_Manuel) \
               -text $caption(audace,seuil,auto) -value 1 -command { ::seuilWindow::cmdseuilWindowAuto_Manuel }
            pack $This.usr2.1.rad1 -side left -padx 10
            radiobutton $This.usr2.1.rad2 -variable seuilWindow(seuilWindowAuto_Manuel) \
               -text $caption(audace,seuil,manuel) -value 2 -command { ::seuilWindow::cmdseuilWindowAuto_Manuel }
            pack $This.usr2.1.rad2 -side left -padx 10
         pack $This.usr2.1 -side top -fill both

         frame $This.usr2.2 -borderwidth 0 -relief flat
            scale $This.usr2.2.bornesMinMax_variant -from 20 -to 300 -length 370 -orient horizontal \
               -showvalue true -tickinterval 20 -resolution 5 -borderwidth 2 -relief groove \
               -variable seuilWindow(pourcentage_dynamique) -width 10
            pack $This.usr2.2.bornesMinMax_variant -side top -padx 10 -pady 7

            frame $This.usr2.2.1 -borderwidth 0 -relief flat
               label $This.usr2.2.1.lab1 -text "$caption(audace,dynamique,max)"
               pack $This.usr2.2.1.lab1 -side left -padx 10 -pady 5
               entry $This.usr2.2.1.ent1 -textvariable seuilWindow(max) -width 10
               pack $This.usr2.2.1.ent1 -side left -padx 10 -pady 5
               menubutton $This.usr2.2.1.but -text $caption(script,parcourir) -menu $This.usr2.2.1.but.menu \
                  -relief raised
               pack $This.usr2.2.1.but -side left -padx 10 -pady 5
               set m [ menu $This.usr2.2.1.but.menu -tearoff 0 ]
               foreach dynamique $seuilWindow(choix_dynamique) {
                  $m add radiobutton -label "$dynamique" \
                     -indicatoron "1" \
                     -value "$dynamique" \
                     -variable seuilWindow(max) \
                     -command { }
               }
            pack $This.usr2.2.1 -side top -fill both

            frame $This.usr2.2.2 -borderwidth 0 -relief flat
               label $This.usr2.2.2.lab1 -text "$caption(audace,dynamique,min)"
               pack $This.usr2.2.2.lab1 -side left -padx 10 -pady 5
               entry $This.usr2.2.2.ent1 -textvariable seuilWindow(min) -width 10
               pack $This.usr2.2.2.ent1 -side left -padx 10 -pady 5
               menubutton $This.usr2.2.2.but -text $caption(script,parcourir) -menu $This.usr2.2.2.but.menu \
                  -relief raised
               pack $This.usr2.2.2.but -side left -padx 10 -pady 5
               set m [ menu $This.usr2.2.2.but.menu -tearoff 0 ]
               foreach dynamique $seuilWindow(choix_dynamique) {
                  $m add radiobutton -label "$dynamique" \
                     -indicatoron "1" \
                     -value "$dynamique" \
                     -variable seuilWindow(min) \
                     -command { }
               }
            pack $This.usr2.2.2 -side top -fill both
         pack $This.usr2.2 -side top -fill both

      pack $This.usr2 -side top -fill both -expand 1 -ipady 5

      #--- Mise a jour de l'interface
      ::seuilWindow::cmdseuilWindowAuto_Manuel

      frame $This.usr3 -borderwidth 1 -relief raised

         frame $This.usr3.regl_seuils
         pack $This.usr3.regl_seuils -side left -expand true

         frame $This.usr3.regl_seuils.0
         pack $This.usr3.regl_seuils.0 -fill x
         radiobutton $This.usr3.regl_seuils.0.but -variable tmp(seuils,mode_) \
            -text $caption(seuils,pas_de_calcul_auto) -value disable
         pack $This.usr3.regl_seuils.0.but -side left -padx 10
         frame $This.usr3.regl_seuils.1
         pack $This.usr3.regl_seuils.1 -fill x
         radiobutton $This.usr3.regl_seuils.1.but -variable tmp(seuils,mode_) \
            -text $caption(seuils,loadima) -value loadima
         pack $This.usr3.regl_seuils.1.but -side left -padx 10
         frame $This.usr3.regl_seuils.2
         pack $This.usr3.regl_seuils.2 -fill x
         radiobutton $This.usr3.regl_seuils.2.but -variable tmp(seuils,mode_) \
            -text $caption(seuils,iris) -value iris
         pack $This.usr3.regl_seuils.2.but -side left -padx 10
         entry $This.usr3.regl_seuils.2.enth -textvariable tmp(seuils,irisautohaut_) \
            -font $audace(font,arial_8_b) -width 10 -justify center
         pack $This.usr3.regl_seuils.2.enth -side right -padx 10
         entry $This.usr3.regl_seuils.2.entb -textvariable tmp(seuils,irisautobas_) \
            -font $audace(font,arial_8_b) -width 10 -justify center
         pack $This.usr3.regl_seuils.2.entb -side right -padx 10
         frame $This.usr3.regl_seuils.4
         pack $This.usr3.regl_seuils.4 -fill x
         radiobutton $This.usr3.regl_seuils.4.but -variable tmp(seuils,mode_) \
            -text $caption(seuils,histoauto) -value histoauto
         pack $This.usr3.regl_seuils.4.but -side left -padx 10
         entry $This.usr3.regl_seuils.4.enth -textvariable tmp(seuils,histoautohaut_) \
            -font $audace(font,arial_8_b) -width 10 -justify center
         pack $This.usr3.regl_seuils.4.enth -side right -padx 10
         entry $This.usr3.regl_seuils.4.entb -textvariable tmp(seuils,histoautobas_) \
            -font $audace(font,arial_8_b) -width 10 -justify center
         pack $This.usr3.regl_seuils.4.entb -side right -padx 10
         frame $This.usr3.regl_seuils.6
         pack $This.usr3.regl_seuils.6 -fill x
         radiobutton $This.usr3.regl_seuils.6.but -variable tmp(seuils,mode_) \
            -text $caption(seuils,initiaux) -value initiaux
         pack $This.usr3.regl_seuils.6.but -side left -padx 10
         frame $This.usr3.regl_seuils.7
         pack $This.usr3.regl_seuils.7 -fill x
         button $This.usr3.regl_seuils.7.but -text $caption(conf,previsu) \
            -command { ::seuilWindow::cmdPreview }
         pack $This.usr3.regl_seuils.7.but -side top -expand true -padx 10 -pady 5 -ipadx 10

      pack $This.usr3 -side top -fill both -expand 1 -ipady 5

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::seuilWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::seuilWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::seuilWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::seuilWindow::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      bind $This <Key-Return> { ::seuilWindow::cmdOk }
      bind $This <Key-Escape> { ::seuilWindow::cmdClose }

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc cmdseuilWindowAuto_Manuel { } {
      variable This
      global seuilWindow

      if { $seuilWindow(seuilWindowAuto_Manuel) == "1" } {
         pack $This.usr2.2.bornesMinMax_variant -side top -padx 10 -pady 7
         pack forget $This.usr2.2.1
         pack forget $This.usr2.2.1.lab1
         pack forget $This.usr2.2.1.ent1
         pack forget $This.usr2.2.1.but
         pack forget $This.usr2.2.2
         pack forget $This.usr2.2.2.lab1
         pack forget $This.usr2.2.2.ent1
         pack forget $This.usr2.2.2.but
      } else {
         pack forget $This.usr2.2.bornesMinMax_variant
         pack $This.usr2.2.1 -side top -fill both
         pack $This.usr2.2.1.lab1 -side left -padx 10 -pady 5
         pack $This.usr2.2.1.ent1 -side left -padx 10 -pady 5
         pack $This.usr2.2.1.but -side left -padx 10 -pady 5
         pack $This.usr2.2.2 -side top -fill both
         pack $This.usr2.2.2.lab1 -side left -padx 10 -pady 5
         pack $This.usr2.2.2.ent1 -side left -padx 10 -pady 5
         pack $This.usr2.2.2.but -side left -padx 10 -pady 5
      }
   }

   proc cmdPreview { } {
      global audace
      global conf
      global tmp

      #--- Copie des reglages courants
      set conf(seuils,mode)          $tmp(seuils,mode_)
      set conf(seuils,irisautohaut)  $tmp(seuils,irisautohaut_)
      set conf(seuils,irisautobas)   $tmp(seuils,irisautobas_)
      set conf(seuils,histoautohaut) $tmp(seuils,histoautohaut_)
      set conf(seuils,histoautobas)  $tmp(seuils,histoautobas_)
      #--- Visualisation avec les reglages courants
      ::audace::autovisu visu$audace(visuNo)
      #--- Recuperation des anciens reglages
      set conf(seuils,mode)          $tmp(seuils,mode)
      set conf(seuils,irisautohaut)  $tmp(seuils,irisautohaut)
      set conf(seuils,irisautobas)   $tmp(seuils,irisautobas)
      set conf(seuils,histoautohaut) $tmp(seuils,histoautohaut)
      set conf(seuils,histoautobas)  $tmp(seuils,histoautobas)
   }

   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   proc cmdApply { } {
      global audace
      global conf
      global snconfvisu
      global caption
      global num
      global selectWindow
      global seuilWindow
      global snvisu
      global tmp

      #---
      save_cursor
      all_cursor watch
      #---
      if { $seuilWindow(seuilWindowAuto_Manuel) == "2" } {
         set audace(maxdyn) $seuilWindow(max)
         set audace(mindyn) $seuilWindow(min)
      }
      #---
      set conf(seuils,auto_manuel)    $seuilWindow(seuilWindowAuto_Manuel)
      set conf(pourcentage_dynamique) $seuilWindow(pourcentage_dynamique)
      #--- Copie des reglages courants
      set conf(seuils,mode)           $tmp(seuils,mode_)
      set conf(seuils,histoautohaut)  $tmp(seuils,histoautohaut_)
      set conf(seuils,histoautobas)   $tmp(seuils,histoautobas_)
      set conf(seuils,irisautohaut)   $tmp(seuils,irisautohaut_)
      set conf(seuils,irisautobas)    $tmp(seuils,irisautobas_)
      #--- Visualisation avec les reglages courants dans la fenetre principale
      ::audace::autovisu visu$audace(visuNo)
      #--- Visualisation avec les reglages courants dans la fenetre de selection des images si elle existe
      if [ winfo exists $audace(base).select ] {
         ::audace::autovisu visu$selectWindow(visu)
      }
      #--- Visualisation avec les reglages courants dans la fenetre de recherche de supernova
      if [ winfo exists $audace(base).snvisu ] {
         ::audace::autovisu visu$num(visu_1)
         if { $snconfvisu(num_rep2_3) == "0" && $snvisu(ima_rep2_exist) == "1" } {
            ::audace::autovisu visu$num(visu_2)
         }
         if { $snconfvisu(num_rep2_3) == "1" && $snvisu(ima_rep3_exist) =="1" } {
            ::audace::autovisu visu$num(visu_2)
         }
      }
      #--- R�cup�ration de la position de la fen�tre de r�glages
      seuils_recup_position
      #---
      restore_cursor
   }

   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1030seuils.htm"
   }

   proc cmdClose { } {
      variable This

      #--- R�cup�ration de la position de la fen�tre de r�glages
      seuils_recup_position
      #---
      destroy $This
      unset This
   }

   proc seuils_recup_position { } {
      variable This
      global conf

      set conf(seuils,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $conf(seuils,geometry) ] ]
      set fin [ string length $conf(seuils,geometry) ]
      set conf(seuils,position) "+[string range $conf(seuils,geometry) $deb $fin]"       
   }

}
