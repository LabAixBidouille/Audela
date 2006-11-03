#
# Fichier : aud2.tcl
# Description : Interfaces graphiques pour les fonctions de traitement d'images :
#                 - scaleWindow   - subskyWindow   - clipWindow
#                 - offsetWindow  - multcteWindow  - noffsetWindow
#                 - ngainWindow   - addWindow      - subWindow
#                 - divWindow     - optWindow
# Mise a jour $Id: aud2.tcl,v 1.7 2006-11-03 16:30:31 robertdelmas Exp $
#

namespace eval ::traiteImage {
   variable This
   global traiteImage

   proc initConf { } {
      global conf

      if { ! [ info exists conf(back_kernel) ] }          { set conf(back_kernel)          "15" }
      if { ! [ info exists conf(back_threshold) ] }       { set conf(back_threshold)       "0.2" }
      if { ! [ info exists conf(clip_maxi) ] }            { set conf(clip_maxi)            "32767" }
      if { ! [ info exists conf(clip_mini) ] }            { set conf(clip_mini)            "0" }
      if { ! [ info exists conf(multx) ] }                { set conf(multx)                "2.0" }
      if { ! [ info exists conf(multy) ] }                { set conf(multy)                "2.0" }
      if { ! [ info exists conf(traiteImage,position) ] } { set conf(traiteImage,position) "+350+75" }

      return
   }

   proc confToWidget { } {  
      variable widget
      global conf

      set widget(traiteImage,position) "$conf(traiteImage,position)"
   }

   proc widgetToConf { } {   
      variable widget
      global conf

      set conf(traiteImage,position) "$widget(traiteImage,position)"
   }

   proc recup_position { } {
      variable This
      variable widget
      global traiteImage

      set traiteImage(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $traiteImage(geometry) ] ]
      set fin [ string length $traiteImage(geometry) ]
      set widget(traiteImage,position) "+[string range $traiteImage(geometry) $deb $fin]"
      #---
      ::traiteImage::widgetToConf
   }

   proc run { type_pretraitement_image this } {
      variable This
      variable widget
      global traiteImage

      #---
      ::traiteImage::initConf
      ::traiteImage::confToWidget
      #---
      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         if { [ info exists traiteImage(geometry) ] } {
            set deb [ expr 1 + [ string first + $traiteImage(geometry) ] ]
            set fin [ string length $traiteImage(geometry) ]
            set widget(traiteImage,position) "+[string range $traiteImage(geometry) $deb $fin]"     
         }
         ::traiteImage::createDialog
      }
      #---
      set traiteImage(operation) "$type_pretraitement_image"
   }

   proc createDialog { } {
      variable This
      variable widget
      global audace
      global conf
      global caption
      global traiteImage

      #---
      set traiteImage(clipWindow_mini) $conf(clip_mini)
      set traiteImage(clipWindow_maxi) $conf(clip_maxi)

      #---
      set traiteImage(scaleWindow_multx) $conf(multx)
      set traiteImage(scaleWindow_multy) $conf(multy)

      #---
      set traiteImage(subskyWindow_back_kernel)    $conf(back_kernel)
      set traiteImage(subskyWindow_back_threshold) $conf(back_threshold)
      
      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,dialog,pretraitement)"
      wm geometry $This $widget(traiteImage,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteImage::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.0 -borderwidth 1 -relief raised
            label $This.usr.0.lab1 -textvariable "traiteImage(formule)" -font $audace(font,arial_15_b)
            pack $This.usr.0.lab1 -padx 10 -pady 5
        # pack $This.usr.0 -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               label $This.usr.2.1.lab1 -text "$caption(image,constante,ajouter)"
               pack $This.usr.2.1.lab1 -side left -padx 10 -pady 5
               entry $This.usr.2.1.ent1 -textvariable traiteImage(offsetWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.1.ent1 -side right -padx 10 -pady 5 
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               label $This.usr.2.2.lab2 -text "$caption(image,constante,multiplicative)"
               pack $This.usr.2.2.lab2 -side left -padx 10 -pady 5
               entry $This.usr.2.2.ent2 -textvariable traiteImage(multWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.2.ent2 -side right -padx 10 -pady 5 
           # pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               label $This.usr.2.3.lab3 -text "$caption(valeur,fond,ciel)"
               pack $This.usr.2.3.lab3 -side left -padx 10 -pady 5
               entry $This.usr.2.3.ent3 -textvariable traiteImage(noffsetWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent3 -side right -padx 10 -pady 5 
           # pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               label $This.usr.2.4.lab4 -text "$caption(valeur,fond,ciel)"
               pack $This.usr.2.4.lab4 -side left -padx 10 -pady 5
               entry $This.usr.2.4.ent4 -textvariable traiteImage(ngainWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.4.ent4 -side right -padx 10 -pady 5 
           # pack $This.usr.2.4 -side top -fill both
            frame $This.usr.2.5 -borderwidth 0 -relief flat
               button $This.usr.2.5.btn1 -text "$caption(script,parcourir)" -command ::traiteImage::parcourir
               pack $This.usr.2.5.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.5.lab5 -text "$caption(nom,image,ajouter)"
               pack $This.usr.2.5.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.5.ent5 -textvariable traiteImage(addWindow_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.5.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.5 -side top -fill both 
            frame $This.usr.2.6 -borderwidth 0 -relief flat
               label $This.usr.2.6.lab6 -text "$caption(image,constante,ajouter)"
               pack $This.usr.2.6.lab6 -side left -padx 10 -pady 5
               entry $This.usr.2.6.ent6 -textvariable traiteImage(addWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.6.ent6 -side right -padx 10 -pady 5
           # pack $This.usr.2.6 -side top -fill both 
            frame $This.usr.2.7 -borderwidth 0 -relief flat
               button $This.usr.2.7.btn2 -text "$caption(script,parcourir)" -command ::traiteImage::parcourir
               pack $This.usr.2.7.btn2 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.7.lab7 -text "$caption(nom,image,soustraire)"
               pack $This.usr.2.7.lab7 -side left -padx 5 -pady 5
               entry $This.usr.2.7.ent7 -textvariable traiteImage(subWindow_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.7.ent7 -side right -padx 10 -pady 5
           # pack $This.usr.2.7 -side top -fill both 
            frame $This.usr.2.8 -borderwidth 0 -relief flat
               label $This.usr.2.8.lab8 -text "$caption(image,constante,ajouter)"
               pack $This.usr.2.8.lab8 -side left -padx 10 -pady 5
               entry $This.usr.2.8.ent8 -textvariable traiteImage(subWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.8.ent8 -side right -padx 10 -pady 5
           # pack $This.usr.2.8 -side top -fill both 
            frame $This.usr.2.9 -borderwidth 0 -relief flat
               button $This.usr.2.9.btn3 -text "$caption(script,parcourir)" -command ::traiteImage::parcourir
               pack $This.usr.2.9.btn3 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.9.lab9 -text "$caption(image,nom,diviser)"
               pack $This.usr.2.9.lab9 -side left -padx 5 -pady 5
               entry $This.usr.2.9.ent9 -textvariable traiteImage(divWindow_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.9.ent9 -side right -padx 10 -pady 5
           # pack $This.usr.2.9 -side top -fill x 
            frame $This.usr.2.10 -borderwidth 0 -relief flat
               label $This.usr.2.10.lab10 -text "$caption(image,constante,multiplicative)"
               pack $This.usr.2.10.lab10 -side left -padx 10 -pady 5
               entry $This.usr.2.10.ent10 -textvariable traiteImage(divWindow_value) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.10.ent10 -side right -padx 10 -pady 5
           # pack $This.usr.2.10 -side top -fill x 
            frame $This.usr.2.11 -borderwidth 0 -relief flat
               label $This.usr.2.11.lab11 -text "$caption(valeur,resample,multx)"
               pack $This.usr.2.11.lab11 -side left -padx 10 -pady 10
               entry $This.usr.2.11.ent11 -textvariable traiteImage(scaleWindow_multx) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.11.ent11 -side right -padx 10 -pady 10 
           # pack $This.usr.2.11 -side top -fill x
            frame $This.usr.2.12 -borderwidth 0 -relief flat
               label $This.usr.2.12.lab12 -text "$caption(valeur,resample,multy)"
               pack $This.usr.2.12.lab12 -side left -padx 10 -pady 5
               entry $This.usr.2.12.ent12 -textvariable traiteImage(scaleWindow_multy) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.12.ent12 -side right -padx 10 -pady 5 
           # pack $This.usr.2.12 -side top -fill x
            frame $This.usr.2.13 -borderwidth 0 -relief flat
               label $This.usr.2.13.lab13 -text "$caption(valeur,subsky,grid)"
               pack $This.usr.2.13.lab13 -side left -padx 10 -pady 10
               entry $This.usr.2.13.ent13 -textvariable traiteImage(subskyWindow_back_kernel) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.13.ent13 -side right -padx 10 -pady 10 
           # pack $This.usr.2.13 -side top -fill x
            frame $This.usr.2.14 -borderwidth 0 -relief flat
               label $This.usr.2.14.lab14 -text "$caption(valeur,subsky,percent)"
               pack $This.usr.2.14.lab14 -side left -padx 10 -pady 5
               entry $This.usr.2.14.ent14 -textvariable traiteImage(subskyWindow_back_threshold) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.14.ent14 -side right -padx 10 -pady 5 
           # pack $This.usr.2.14 -side top -fill x
            frame $This.usr.2.15 -borderwidth 0 -relief flat
               label $This.usr.2.15.lab15 -text "$caption(valeur,clip,min)"
               pack $This.usr.2.15.lab15 -side left -padx 10 -pady 10
               entry $This.usr.2.15.ent15 -textvariable traiteImage(clipWindow_mini) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.15.ent15 -side right -padx 10 -pady 10 
           # pack $This.usr.2.15 -side top -fill x
            frame $This.usr.2.16 -borderwidth 0 -relief flat
               label $This.usr.2.16.lab16 -text "$caption(valeur,clip,max)"
               pack $This.usr.2.16.lab16 -side left -padx 10 -pady 5
               entry $This.usr.2.16.ent16 -textvariable traiteImage(clipWindow_maxi) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.16.ent16 -side right -padx 10 -pady 5 
           # pack $This.usr.2.16 -side top -fill both
            frame $This.usr.2.17 -borderwidth 0 -relief flat
               button $This.usr.2.17.but_defaut -text "$caption(audace,valeur_par_defaut)" \
                  -command { ::traiteImage::val_defaut }
               pack $This.usr.2.17.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
           # pack $This.usr.2.17 -side top -fill both
            frame $This.usr.2.18 -borderwidth 0 -relief flat
               button $This.usr.2.18.btn1 -text "$caption(script,parcourir)" -command { ::traiteImage::parcourir 1 }
               pack $This.usr.2.18.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.18.lab5 -text "$caption(audace,image,noir:)"
               pack $This.usr.2.18.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.18.ent5 -textvariable traiteImage(optWindow_dark_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.18.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.19 -side top -fill both 
            frame $This.usr.2.19 -borderwidth 0 -relief flat
               button $This.usr.2.19.btn1 -text "$caption(script,parcourir)" -command { ::traiteImage::parcourir 2 }
               pack $This.usr.2.19.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.19.lab5 -text "$caption(audace,log,offset)"
               pack $This.usr.2.19.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.19.ent5 -textvariable traiteImage(optWindow_offset_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.19.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.19 -side top -fill both 
         pack $This.usr.2 -side bottom -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -textvariable "traiteImage(image_A)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteImage [ list  $caption(audace,menu,subsky) $caption(audace,menu,clip) \
               $caption(audace,menu,scale) $caption(audace,menu,offset) $caption(audace,menu,mult_cte) \
               $caption(audace,menu,noffset) $caption(audace,menu,ngain) $caption(audace,menu,addition) \
               $caption(audace,menu,soust) $caption(audace,menu,division) $caption(audace,optimisation,noir) ]
            #---
            menubutton $This.usr.1.but1 -textvariable traiteImage(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretraitement $list_traiteImage {
               $m add radiobutton -label "$pretraitement" \
                  -indicatoron "1" \
                  -value "$pretraitement" \
                  -variable traiteImage(operation) \
                  -command { }
            }
         pack $This.usr.1 -side bottom -fill both
      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::traiteImage::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::traiteImage::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::traiteImage::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::traiteImage::afficheAide } 
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable traiteImage(operation) w ::traiteImage::change

      #---
      bind $This <Key-Return> {::traiteImage::cmdOk}
      bind $This <Key-Escape> {::traiteImage::cmdClose}

      #---
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #---
      ::traiteImage::formule
   }

   proc cmdOk { } {
      ::traiteImage::cmdApply
      ::traiteImage::cmdClose
   }

   proc cmdApply { { visuNo "1" } } {
      variable This
      global audace
      global conf
      global caption
      global traiteImage

      #--- Il faut une image affichee
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] != "1" } {
         tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,header,noimage)
         return
      }

      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteImage(operation) \
         "$caption(audace,menu,subsky)" {
            #---
            set conf(back_kernel)    $traiteImage(subskyWindow_back_kernel)
            set conf(back_threshold) $traiteImage(subskyWindow_back_threshold)
            #--- Tests sur les constantes
            if { $traiteImage(subskyWindow_back_kernel) == "" && $traiteImage(subskyWindow_back_threshold) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_coefficients)
               return
            }
            if { $traiteImage(subskyWindow_back_kernel) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
               return
            }
            if { $traiteImage(subskyWindow_back_threshold) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
               return
            }
            if { [ string is double -strict $traiteImage(subskyWindow_back_kernel) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            if { [ string is double -strict $traiteImage(subskyWindow_back_threshold) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch {
               set k $traiteImage(subskyWindow_back_kernel)
               set t $traiteImage(subskyWindow_back_threshold)
               if { [ expr $t ] < "0" } { set t "0" }
               if { [ expr $t ] > "1" } { set t "1" }
               if { [ expr $k ] < "4" } { set k "3" }
               if { [ expr $k ] > "50" } { set k "50" }
               buf$audace(bufNo) imaseries "back back_kernel=$k back_threshold=$t sub"
               ::audace::autovisu $audace(visuNo)
            } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,subsky) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,clip)" {
            #---
            set conf(clip_mini) $traiteImage(clipWindow_mini)
            set conf(clip_maxi) $traiteImage(clipWindow_maxi)
            #--- Tests sur les constantes
            if { $traiteImage(clipWindow_mini) == "" && $traiteImage(clipWindow_maxi) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_coefficients)
               return
            }
            if { $traiteImage(clipWindow_mini) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
               return
            }
            if { $traiteImage(clipWindow_maxi) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
               return
            }
            if { [ string is double -strict $traiteImage(clipWindow_mini) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            if { [ string is double -strict $traiteImage(clipWindow_maxi) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch {
               if { $traiteImage(clipWindow_mini) != "" } {
                  buf$audace(bufNo) clipmin $traiteImage(clipWindow_mini)
               }
               if { $traiteImage(clipWindow_maxi) != "" } {
                  buf$audace(bufNo) clipmax $traiteImage(clipWindow_maxi)
               }
               ::audace::autovisu $audace(visuNo)
            } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,clip) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,scale)" {
            #---
            set conf(multx) $traiteImage(scaleWindow_multx)
            set conf(multy) $traiteImage(scaleWindow_multy)
            #--- Tests sur les facteurs d'echelle
            if { $traiteImage(scaleWindow_multx) == "" && $traiteImage(scaleWindow_multy) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_coefficients)
               return
            }
            if { $traiteImage(scaleWindow_multx) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
               return
            }
            if { $traiteImage(scaleWindow_multy) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
               return
            }
            if { [ string is double -strict $traiteImage(scaleWindow_multx) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            if { [ string is double -strict $traiteImage(scaleWindow_multy) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch {
               set x $traiteImage(scaleWindow_multx)
               set y $traiteImage(scaleWindow_multy)
               set maxi "50"
               if { [ expr $x ] == "0" } { set x "1" }
               if { [ expr $x ] > "$maxi" } { set x "$maxi" }
               if { [ expr $x ] < "-$maxi" } { set x "-$maxi" }
               if { [ expr $y ] == "0" } { set y "1" }
               if { [ expr $y ] > "$maxi" } { set y "$maxi" }
               if { [ expr $y ] < "-$maxi" } { set y "-$maxi" }
               buf$audace(bufNo) scale [ list $x $y ] 1
               ::audace::autovisu $audace(visuNo)
            } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,scale) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,offset)" {
            #--- Test sur la constante
            if { $traiteImage(offsetWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            if { [ string is double -strict $traiteImage(offsetWindow_value) ] == "1" } {
               catch { offset $traiteImage(offsetWindow_value) } m
            } else {
               set m "error"
            }
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,offset) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,mult_cte)" {
            #--- Test sur la constante
            if { $traiteImage(multWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            if { [ string is double -strict $traiteImage(multWindow_value) ] == "1" } {
               catch { mult $traiteImage(multWindow_value) } m
            } else {
               set m "error"
            }
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,mult_cte) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,noffset)" {
            #--- Tests sur la constante
            if { $traiteImage(noffsetWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,fond_ciel)
               return
            }
            if { [ string is double -strict $traiteImage(noffsetWindow_value) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch { noffset $traiteImage(noffsetWindow_value) } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,noffset) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,ngain)" {
            #--- Tests sur la constante
            if { $traiteImage(ngainWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,fond_ciel)
               return
            }
            if { [ string is double -strict $traiteImage(ngainWindow_value) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch { ngain $traiteImage(ngainWindow_value) } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,ngain) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,addition)" {
            #--- Test sur l'image B
            if { $traiteImage(addWindow_filename) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,image_B)
               return
            }
            #--- Tests sur la constante
            if { $traiteImage(addWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
               return
            }
            if { [ string is double -strict $traiteImage(addWindow_value) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch { add $traiteImage(addWindow_filename) $traiteImage(addWindow_value) } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,addition) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,soust)" {
            #--- Tests sur l'image B
            if { $traiteImage(subWindow_filename) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,image_B)
               return
            }
            #--- Tests sur la constante
            if { $traiteImage(subWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
               return
            }
            if { [ string is double -strict $traiteImage(subWindow_value) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch { sub $traiteImage(subWindow_filename) $traiteImage(subWindow_value) } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,soust) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,menu,division)" {
            #--- Test sur l'image B
            if { $traiteImage(divWindow_filename) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,image_B)
               return
            }
            #--- Tests sur la constante
            if { $traiteImage(divWindow_value) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
               return
            }
            if { [ string is double -strict $traiteImage(divWindow_value) ] == "0" } {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch { div $traiteImage(divWindow_filename) $traiteImage(divWindow_value) } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,menu,division) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         } \
         "$caption(audace,optimisation,noir)" {
            #--- Test sur l'image de dark
            if { $traiteImage(optWindow_dark_filename) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,noir)
               return
            }
            #--- Test sur l'image d'offset
            if { $traiteImage(optWindow_offset_filename) == "" } {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,offset)
               return
            }
            #---
            save_cursor
            all_cursor watch
            #---
            catch { opt $traiteImage(optWindow_dark_filename) $traiteImage(optWindow_offset_filename) } m
            if { $m == "" } {
               tk_messageBox -title $caption(audace,optimisation,noir) -type ok -message $caption(audace,fin_traitement)
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
            }
            #---
            restore_cursor
         }
      ::traiteImage::recup_position
   }

   proc cmdClose { } {
      variable This

      ::traiteImage::recup_position
      destroy $This
      unset This
   }

   proc afficheAide { } {
      global caption
      global help
      global traiteImage

      #---
      if { $traiteImage(operation) == $caption(audace,menu,subsky) } {
         set traiteImage(page_web) "1100soust_fond_ciel"
      } elseif { $traiteImage(operation) == $caption(audace,menu,clip) } {
         set traiteImage(page_web) "1110ecreter"
      } elseif { $traiteImage(operation) == $caption(audace,menu,scale) } {
         set traiteImage(page_web) "1020reechantillonner"
      } elseif { $traiteImage(operation) == $caption(audace,menu,offset) } {
         set traiteImage(page_web) "1030ajouter_cte"
      } elseif { $traiteImage(operation) == $caption(audace,menu,mult_cte) } {
         set traiteImage(page_web) "1040multiplier_cte"
      } elseif { $traiteImage(operation) == $caption(audace,menu,noffset) } {
         set traiteImage(page_web) "1050norm_fond"
      } elseif { $traiteImage(operation) == $caption(audace,menu,ngain) } {
         set traiteImage(page_web) "1060norm_eclai"
      } elseif { $traiteImage(operation) == $caption(audace,menu,addition) } {
         set traiteImage(page_web) "1070addition"
      } elseif { $traiteImage(operation) == $caption(audace,menu,soust) } {
         set traiteImage(page_web) "1080soustraction"
      } elseif { $traiteImage(operation) == $caption(audace,menu,division) } {
         set traiteImage(page_web) "1090division"
      } elseif { $traiteImage(operation) == $caption(audace,optimisation,noir) } {
         set traiteImage(page_web) "1095opt_noir"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$traiteImage(page_web).htm"
   }

   proc change { n1 n2 op } {
      variable This
      global caption
      global traiteImage

      #---
      ::traiteImage::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteImage(operation) \
         "$caption(audace,menu,subsky)" {
            pack forget $This.usr.0
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack $This.usr.2.13 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.14 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack $This.usr.2.17 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,clip)" {
            pack forget $This.usr.0
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack $This.usr.2.15 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.16 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.17 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,scale)" {
            pack forget $This.usr.0
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack $This.usr.2.11 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.12 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack  $This.usr.2.17 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,offset)" {
            pack $This.usr.0 -side top -fill both
            pack $This.usr.2.1 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,mult_cte)" {
            pack $This.usr.0 -side top -fill both
            pack forget $This.usr.2.1
            pack $This.usr.2.2 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,noffset)" {
            pack forget $This.usr.0
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack $This.usr.2.3 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
        } \
         "$caption(audace,menu,ngain)" {
            pack forget $This.usr.0
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack $This.usr.2.4 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,addition)" {
            pack $This.usr.0 -side top -fill both
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack $This.usr.2.5 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.6 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.10
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,soust)" {
            pack $This.usr.0 -side top -fill both
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack $This.usr.2.7 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.8 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,menu,division)" {
            pack $This.usr.0 -side top -fill both
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack $This.usr.2.9 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.10 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack forget $This.usr.2.18
            pack forget $This.usr.2.19
         } \
         "$caption(audace,optimisation,noir)" {
            pack forget $This.usr.0
            pack forget $This.usr.2.1
            pack forget $This.usr.2.2
            pack forget $This.usr.2.3
            pack forget $This.usr.2.4
            pack forget $This.usr.2.5
            pack forget $This.usr.2.6
            pack forget $This.usr.2.7
            pack forget $This.usr.2.8
            pack forget $This.usr.2.9
            pack forget $This.usr.2.10
            pack forget $This.usr.2.11
            pack forget $This.usr.2.12
            pack forget $This.usr.2.13
            pack forget $This.usr.2.14
            pack forget $This.usr.2.15
            pack forget $This.usr.2.16
            pack forget $This.usr.2.17
            pack $This.usr.2.18 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.19 -in $This.usr.2 -side top -fill both
         }
   }

   proc parcourir { { option 1 } } {
      global audace
      global caption
      global traiteImage

      #--- Fenetre parent
      set fenetre "$audace(base).traiteImage"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom du fichier
      if { $traiteImage(operation) == "$caption(audace,menu,addition)" } {
         set traiteImage(addWindow_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,menu,soust)" } {
         set traiteImage(subWindow_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,menu,division)" } {
         set traiteImage(divWindow_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,optimisation,noir)" && $option == "1" } {
         set traiteImage(optWindow_dark_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,optimisation,noir)" && $option == "2" } {
         set traiteImage(optWindow_offset_filename) [ file rootname [ file tail $filename ] ]
      }
   }

   proc val_defaut { } {
      global caption
      global traiteImage

      #--- Re-initialise les coefficients conf()
      if { $traiteImage(operation) == "$caption(audace,menu,subsky)" } {
         set traiteImage(subskyWindow_back_kernel) "15"
         set traiteImage(subskyWindow_back_threshold) "0.2"
      } elseif { $traiteImage(operation) == "$caption(audace,menu,clip)" } {
         set traiteImage(clipWindow_mini) "0"
         set traiteImage(clipWindow_maxi) "32767"
      } elseif { $traiteImage(operation) == "$caption(audace,menu,scale)"  } {
         set traiteImage(scaleWindow_multx) "2.0"
         set traiteImage(scaleWindow_multy) "2.0"
      }
   }

   proc formule { } {
      global caption
      global traiteImage

      if { $traiteImage(operation) == "$caption(audace,menu,offset)" } {
         set traiteImage(image_A) "$caption(audace,image,image_affichee) ( A ) :"
         set traiteImage(formule) "$caption(audace,formule) A + Cte"
      } elseif { $traiteImage(operation) == "$caption(audace,menu,mult_cte)" } {
         set traiteImage(image_A) "$caption(audace,image,image_affichee) ( A ) :"
         set traiteImage(formule) "$caption(audace,formule) A x Cte"
      } elseif { $traiteImage(operation) == "$caption(audace,menu,addition)" } {
         set traiteImage(image_A) "$caption(audace,image,image_affichee) ( A ) :"
         set traiteImage(formule) "$caption(audace,formule) A + B + Cte"
      } elseif { $traiteImage(operation) == "$caption(audace,menu,soust)" } {
         set traiteImage(image_A) "$caption(audace,image,image_affichee) ( A ) :"
         set traiteImage(formule) "$caption(audace,formule) A - B + Cte"
      } elseif { $traiteImage(operation) == "$caption(audace,menu,division)" } {
         set traiteImage(image_A) "$caption(audace,image,image_affichee) ( A ) :"
         set traiteImage(formule) "$caption(audace,formule) ( A / B ) x Cte"
      } else {
         set traiteImage(image_A) "$caption(audace,image,image_affichee:)"
         set traiteImage(formule) ""
      }
   }

}

