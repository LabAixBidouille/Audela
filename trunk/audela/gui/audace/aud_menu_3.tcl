#
# Fichier : aud_menu_3.tcl
# Description : Script regroupant les fonctionnalites du menu Pretraitement
# Mise a jour $Id: aud_menu_3.tcl,v 1.3 2006-11-11 16:28:11 robertdelmas Exp $
#

namespace eval ::traiteImage {

   #
   # ::traiteImage::run type_pretraitement_image this
   # Lance la boite de dialogue pour les pretraitements sur une images
   #
   # this : Chemin de la fenetre
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

   #
   # ::traiteImage::initConf
   # Initialisation des variables de configuration
   #
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

   #
   # ::traiteImage::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(traiteImage,position) "$conf(traiteImage,position)"
   }

   #
   # ::traiteImage::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(traiteImage,position) "$widget(traiteImage,position)"
   }

   #
   # ::traiteImage::recup_position
   # Recupere la position de la fenetre
   #
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

   #
   # ::traiteImage::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf traiteImage

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
               button $This.usr.2.5.btn1 -text "$caption(traiteImage,parcourir)" -command ::traiteImage::parcourir
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
               button $This.usr.2.7.btn2 -text "$caption(traiteImage,parcourir)" -command ::traiteImage::parcourir
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
               button $This.usr.2.9.btn3 -text "$caption(traiteImage,parcourir)" -command ::traiteImage::parcourir
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
               button $This.usr.2.18.btn1 -text "$caption(traiteImage,parcourir)" -command { ::traiteImage::parcourir 1 }
               pack $This.usr.2.18.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.18.lab5 -text "$caption(audace,image,noir:)"
               pack $This.usr.2.18.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.18.ent5 -textvariable traiteImage(optWindow_dark_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.18.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.19 -side top -fill both 
            frame $This.usr.2.19 -borderwidth 0 -relief flat
               button $This.usr.2.19.btn1 -text "$caption(traiteImage,parcourir)" -command { ::traiteImage::parcourir 2 }
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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #---
      ::traiteImage::formule
   }

   #
   # ::traiteImage::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      ::traiteImage::cmdApply
      ::traiteImage::cmdClose
   }

   #
   # ::traiteImage::cmdApply [visuNo]
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { { visuNo "1" } } {
      global audace caption conf traiteImage

      #--- Il faut une image affichee
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] != "1" } {
         tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,header_noimage)
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

   #
   # ::traiteImage::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This

      ::traiteImage::recup_position
      destroy $This
      unset This
   }

   #
   # ::traiteImage::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global caption help traiteImage

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

   #
   # ::traiteImage::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This
      global caption traiteImage

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

   #
   # ::traiteImage::parcourir [option]
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { { option 1 } } {
      global audace caption traiteImage

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

   #
   # ::traiteImage::val_defaut
   # Affiche les valeurs par defaut des constantes
   #
   proc val_defaut { } {
      global caption traiteImage

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

   #
   # ::traiteImage::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption traiteImage

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

########################### Fin du namespace traiteImage ###########################

namespace eval ::traiteWindow {

   #
   # ::traiteWindow::run type_pretraitement this
   # Lance la boite de dialogue pour les pretraitements sur une images
   # this : Chemin de la fenetre
   #
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

   #
   # ::traiteWindow::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(multx) ] }                 { set conf(multx)                 "2.0" }
      if { ! [ info exists conf(multy) ] }                 { set conf(multy)                 "2.0" }
      if { ! [ info exists conf(traiteWindow,position) ] } { set conf(traiteWindow,position) "+350+75" }

      return
   }

   #
   # ::traiteWindow::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(traiteWindow,position) "$conf(traiteWindow,position)"
   }

   #
   # ::traiteWindow::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(traiteWindow,position) "$widget(traiteWindow,position)"
   }

   #
   # ::traiteWindow::recup_position
   # Recupere la position de la fenetre
   #
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

   #
   # ::traiteWindow::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf traiteWindow

      #--- Initialisation
      set traiteWindow(in)  ""
      set traiteWindow(out) ""

      #---
      set traiteWindow(scaleWindow_multx) $conf(multx)
      set traiteWindow(scaleWindow_multy) $conf(multy)

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
        # pack $This.usr.0 -in $This.usr -side top -fill both

         frame $This.usr.7 -borderwidth 1 -relief raised
            frame $This.usr.7.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.1.che1 -text "$caption(afficher,image,fin)" -variable traiteWindow(4,disp)
               pack $This.usr.7.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.7.1 -side top -fill both
        # pack $This.usr.7 -in $This.usr -side top -fill both

         frame $This.usr.6 -borderwidth 1 -relief raised
            frame $This.usr.6.1 -borderwidth 0 -relief flat
               label $This.usr.6.1.lab1 -text "$caption(valeur,resample,multx)"
               pack $This.usr.6.1.lab1 -side left -padx 10 -pady 10
               entry $This.usr.6.1.ent1 -textvariable traiteWindow(scaleWindow_multx) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.6.1.ent1 -side right -padx 10 -pady 10 
            pack $This.usr.6.1 -side top -fill x
            frame $This.usr.6.2 -borderwidth 0 -relief flat
               label $This.usr.6.2.lab2 -text "$caption(valeur,resample,multy)"
               pack $This.usr.6.2.lab2 -side left -padx 10 -pady 5
               entry $This.usr.6.2.ent2 -textvariable traiteWindow(scaleWindow_multy) -width 7 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.6.2.ent2 -side right -padx 10 -pady 5 
            pack $This.usr.6.2 -side top -fill x
            frame $This.usr.6.3 -borderwidth 0 -relief flat
               button $This.usr.6.3.but_defaut -text "$caption(audace,valeur_par_defaut)" \
                  -command { ::traiteWindow::val_defaut }
               pack $This.usr.6.3.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
            pack $This.usr.6.3 -side top -fill both
        # pack $This.usr.6 -in $This.usr -side top -fill both

         frame $This.usr.5 -borderwidth 1 -relief raised
            frame $This.usr.5.1 -borderwidth 0 -relief flat
               button $This.usr.5.1.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 4 }
               pack $This.usr.5.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.5.1.lab8 -text "$caption(audace,image,noir:)"
               pack $This.usr.5.1.lab8 -side left -padx 5 -pady 5
               entry $This.usr.5.1.ent8 -textvariable traiteWindow(3,dark) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.5.1.ent8 -side right -padx 10 -pady 5
            pack $This.usr.5.1 -side top -fill both
            frame $This.usr.5.2 -borderwidth 0 -relief flat
               button $This.usr.5.2.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 5 }
               pack $This.usr.5.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.5.2.lab9 -text "$caption(audace,log,offset)"
               pack $This.usr.5.2.lab9 -side left -padx 5 -pady 5
               entry $This.usr.5.2.ent9 -textvariable traiteWindow(3,offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.5.2.ent9 -side right -padx 10 -pady 5
            pack $This.usr.5.2 -side top -fill both
        # pack $This.usr.5 -in $This.usr -side top -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               button $This.usr.4.1.explore -text "$caption(traiteImage,parcourir)" -width 1 \
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
        # pack $This.usr.4 -in $This.usr -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               label $This.usr.3.1.lab5 -textvariable "traiteWindow(constante)"
               pack $This.usr.3.1.lab5 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent5 -textvariable traiteWindow(1,const) -width 7 -font $audace(font,arial_8_b)
               pack $This.usr.3.1.ent5 -side right -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -in $This.usr -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               button $This.usr.2.2.explore -text "$caption(traiteImage,parcourir)" -width 1 \
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
               button $This.usr.2.3.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 2 }
               pack $This.usr.2.3.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.3.lab4 -textvariable "traiteWindow(image_B)"
               pack $This.usr.2.3.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.3.ent4 -textvariable traiteWindow(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent4 -side right -padx 10 -pady 5
            pack $This.usr.2.3 -side top -fill both
        # pack $This.usr.2 -in $This.usr -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -text "$caption(audace,menu,operation_serie)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteWindow [ list $caption(audace,menu,scale) $caption(audace,menu,offset) \
               $caption(audace,menu,mult_cte) $caption(audace,menu,noffset) $caption(audace,menu,ngain) \
               $caption(audace,menu,addition) $caption(audace,menu,soust) $caption(audace,menu,division) \
               $caption(audace,optimisation,noir) $caption(audace,run,median) $caption(audace,image,somme) \
               $caption(audace,image,moyenne) $caption(audace,image,ecart_type) ]
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
        # pack $This.usr.1 -in $This.usr -side top -fill both
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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #---
      ::traiteWindow::formule
   }

   #
   # ::traiteWindow::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      ::traiteWindow::cmdApply
      ::traiteWindow::cmdClose
   }

   #
   # ::traiteWindow::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      variable This
      global audace caption traiteWindow

      #---
      set in  $traiteWindow(in)
      set out $traiteWindow(out)
      set nb  $traiteWindow(nb)
      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $traiteWindow(in) == "" } {
          tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_image_entree)
          return
      }
      if { $traiteWindow(nb) == "" } {
          tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_nbre_images)
          return
      }
      if { [ TestEntier $traiteWindow(nb) ] == "0" } {
         tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,nbre_entier)
         return
      }
      if { $traiteWindow(out) == "" } {
          tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_image_sortie)
          return
      }
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      if { ( $in != "" ) && ( $out != "" ) && ( $nb != "" ) } {
         switch $traiteWindow(operation) \
            "$caption(audace,menu,scale)" {
               #---
               set conf(multx) $traiteWindow(scaleWindow_multx)
               set conf(multy) $traiteWindow(scaleWindow_multy)
               #--- Tests les facteurs d'echelle
               if { $traiteWindow(scaleWindow_multx) == "" && $traiteWindow(scaleWindow_multy) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_coefficients)
                  return
               }
               if { $traiteWindow(scaleWindow_multx) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
                  return
               }
               if { $traiteWindow(scaleWindow_multy) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,coef_manquant)
                  return
               }
               if { [ string is double -strict $traiteWindow(scaleWindow_multx) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               if { [ string is double -strict $traiteWindow(scaleWindow_multy) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               ::console::affiche_resultat "Usage : scale2 in out number scale_x scale_y\n\n"
               catch {
                  set x $traiteWindow(scaleWindow_multx)
                  set y $traiteWindow(scaleWindow_multy)
                  set maxi "50"
                  if { [ expr $x ] == "0" } { set x "1" }
                  if { [ expr $x ] > "$maxi" } { set x "$maxi" }
                  if { [ expr $x ] < "-$maxi" } { set x "-$maxi" }
                  if { [ expr $y ] == "0" } { set y "1" }
                  if { [ expr $y ] > "$maxi" } { set y "$maxi" }
                  if { [ expr $y ] < "-$maxi" } { set y "-$maxi" }
                  scale2 $in $out $nb $x $y
               } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,scale) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,offset)" {
               #--- Tests sur la constante
               if { $traiteWindow(1,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
                  return
               }
               if { [ string is double -strict $traiteWindow(1,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "offset2 $in $out $const $nb\n\n"
               catch { offset2 $in $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,offset) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,mult_cte)" {
               #--- Tests sur la constante
               if { $traiteWindow(1,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
                  return
               }
               if { [ string is double -strict $traiteWindow(1,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "mult2 $in $out $const $nb\n\n"
               catch { mult2 $in $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,mult_cte) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,noffset)" {
               #--- Tests sur la constante
               if { $traiteWindow(1,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,fond_ciel)
                  return
               }
               if { [ string is double -strict $traiteWindow(1,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "noffset2 $in $out $const $nb\n\n"
               catch { noffset2 $in $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,noffset) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,ngain)" {
               #--- Tests sur la constante
               if { $traiteWindow(1,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,fond_ciel)
                  return
               }
               if { [ string is double -strict $traiteWindow(1,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set const $traiteWindow(1,const)
               ::console::affiche_resultat "ngain2 $in $out $const $nb\n\n"
               catch { ngain2 $in $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,ngain) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,addition)" {
               #--- Test sur l'operande
               if { $traiteWindow(2,operand) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,operande)
                  return
               }
               #--- Tests sur la constante
               if { $traiteWindow(2,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
                  return
               }
               if { [ string is double -strict $traiteWindow(2,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set operand $traiteWindow(2,operand)
               set const $traiteWindow(2,const)
               ::console::affiche_resultat "add2 $in $operand $out $const $nb\n\n"
               catch { add2 $in $operand $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,addition) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,soust)" {
               #--- Test sur l'operande
               if { $traiteWindow(2,operand) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,operande)
                  return
               }
               #--- Tests sur la constante
               if { $traiteWindow(2,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
                  return
               }
               if { [ string is double -strict $traiteWindow(2,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set operand $traiteWindow(2,operand)
               set const $traiteWindow(2,const)
               ::console::affiche_resultat "sub2 $in $operand $out $const $nb\n\n"
               catch { sub2 $in $operand $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,soust) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,division)" {
               #--- Test sur l'operande
               if { $traiteWindow(2,operand) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,operande)
                  return
               }
               #--- Tests sur la constante
               if { $traiteWindow(2,const) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
                  return
               }
               if { [ string is double -strict $traiteWindow(2,const) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set operand $traiteWindow(2,operand)
               set const $traiteWindow(2,const)
               ::console::affiche_resultat "div2 $in $operand $out $const $nb\n\n"
               catch { div2 $in $operand $out $const $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,division) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,optimisation,noir)" {
               #--- Test sur le noir
               if { $traiteWindow(3,dark) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,noir)
                  return
               }
               #--- Test sur l'offset
               if { $traiteWindow(3,offset) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,offset)
                  return
               }
               #---
               set dark $traiteWindow(3,dark)
               set offset $traiteWindow(3,offset)
               ::console::affiche_resultat "opt2 $in $dark $offset $out $nb\n\n"
               catch { opt2 $in $dark $offset $out $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,optimisation,noir) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,run,median)" {
               ::console::affiche_resultat "smedian $in $out $nb\n\n"
               catch { smedian $in $out $nb } m
               if { $m == "" } {
                  if { $traiteWindow(4,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,run,median) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,image,somme)" {
               ::console::affiche_resultat "sadd $in $out $nb\n\n"
               catch { sadd $in $out $nb } m
               if { $m == "" } {
                  if { $traiteWindow(4,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,image,somme) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,image,moyenne)" {
               ::console::affiche_resultat "smean $in $out $nb\n\n"
               catch { smean $in $out $nb } m
               if { $m == "" } {
                  if { $traiteWindow(4,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,image,moyenne) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,image,ecart_type)" {
               ::console::affiche_resultat "ssigma $in $out $nb bitpix=-32\n\n"
               catch { ssigma $in $out $nb "bitpix=-32" } m
               if { $m == "" } {
                  if { $traiteWindow(4,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,image,ecart_type) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            }
      }
      ::traiteWindow::recup_position
   }

   #
   # ::traiteWindow::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This

      ::traiteWindow::recup_position
      destroy $This
      unset This
   }

   #
   # ::traiteWindow::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global caption help traiteWindow

      #---
      if { $traiteWindow(operation) == $caption(audace,menu,scale) } {
         set traiteWindow(page_web) "1155serie_reechantillonner"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,offset) } {
         set traiteWindow(page_web) "1160serie_somme_cte"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,mult_cte) } {
         set traiteWindow(page_web) "1165serie_multiplier_cte"
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
      } elseif { $traiteWindow(operation) == $caption(audace,run,median) } {
         set traiteWindow(page_web) "1120serie_mediane"
      } elseif { $traiteWindow(operation) == $caption(audace,image,somme) } {
         set traiteWindow(page_web) "1130serie_somme"
      } elseif { $traiteWindow(operation) == $caption(audace,image,moyenne) } {
         set traiteWindow(page_web) "1140serie_moyenne"
      } elseif { $traiteWindow(operation) == $caption(audace,image,ecart_type) } {
         set traiteWindow(page_web) "1150serie_ecart_type"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$traiteWindow(page_web).htm"
   }

   #
   # ::traiteWindow::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This
      global caption traiteWindow

      #---
      ::traiteWindow::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteWindow(operation) \
         "$caption(audace,menu,scale)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,offset)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,mult_cte)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,noffset)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,ngain)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,addition)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,soust)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,division)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,optimisation,noir)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack $This.usr.5 -in $This.usr -side top -fill both
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,run,median)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack $This.usr.7 -in $This.usr -side top -fill both
         } \
         "$caption(audace,image,somme)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack $This.usr.7 -in $This.usr -side top -fill both
         } \
         "$caption(audace,image,moyenne)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack $This.usr.7 -in $This.usr -side top -fill both
         } \
         "$caption(audace,image,ecart_type)" {
            pack forget $This.usr.0
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack $This.usr.7 -in $This.usr -side top -fill both
         }
   }

   #
   # ::traiteWindow::parcourir In_Out
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      global audace traiteWindow

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

   #
   # ::traiteWindow::val_defaut
   # Affiche les valeurs par defaut des constantes
   #
   proc val_defaut { } {
      global caption traiteWindow

      #--- Re-initialise les coefficients conf()
      if { $traiteWindow(operation) == "$caption(audace,menu,scale)"  } {
         set traiteWindow(scaleWindow_multx) "2.0"
         set traiteWindow(scaleWindow_multy) "2.0"
      }
   }

   #
   # ::traiteWindow::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption traiteWindow

      if { $traiteWindow(operation) == "$caption(audace,menu,offset)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,ajouter)"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An + Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,mult_cte)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,multiplicative)"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An x Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,addition)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,ajouter)"
         set traiteWindow(operande)  "$caption(nom,image,ajouter-) ( C ) :"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An + C + Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,soust)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,ajouter)"
         set traiteWindow(operande)  "$caption(nom,image,soustraire-) ( C ) :"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = An - C + Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,division)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(constante) "$caption(image,constante,multiplicative)"
         set traiteWindow(operande)  "$caption(image,nom,diviser-) ( C ) :"
         set traiteWindow(formule)   "$caption(audace,formule) Bn = ( An / C ) x Cte"
      } elseif { $traiteWindow(operation) == "$caption(audace,image,somme)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(formule)   "$caption(audace,formule) B = A1 + A2 + ... + An"
      } elseif { $traiteWindow(operation) == "$caption(audace,image,moyenne)" } {
         set traiteWindow(image_A)   "$caption(audace,images,entree-) ( A ) :"
         set traiteWindow(nombre)    "$caption(audace,image,nombre-) ( n ) :"
         set traiteWindow(image_B)   "$caption(audace,images,sortie-) ( B ) :"
         set traiteWindow(formule)   "$caption(audace,formule) B = ( A1 + A2 + ... + An ) / n"
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

########################### Fin du namespace traiteWindow ###########################

namespace eval ::faireImageRef {

   #
   # ::faireImageRef::run type_image_reference this
   # Lance la boite de dialogue pour les pretraitements sur une images
   # this : Chemin de la fenetre
   #
   proc run { type_image_reference this } {
      variable This
      variable widget
      global faireImageRef

      #---
      ::faireImageRef::initConf
      ::faireImageRef::confToWidget
      #---
      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         if { [ info exists faireImageRef(geometry) ] } {
            set deb [ expr 1 + [ string first + $faireImageRef(geometry) ] ]
            set fin [ string length $faireImageRef(geometry) ]
            set widget(faireImageRef,position) "+[string range $faireImageRef(geometry) $deb $fin]"
         }
         createDialog
      }
      #---
      set faireImageRef(operation) "$type_image_reference"
   }

   #
   # ::faireImageRef::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(faireImageRef,position) ] } { set conf(faireImageRef,position) "+350+75" }

      return
   }

   #
   # ::faireImageRef::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(faireImageRef,position) "$conf(faireImageRef,position)"
   }

   #
   # ::faireImageRef::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(faireImageRef,position) "$widget(faireImageRef,position)"
   }

   #
   # ::faireImageRef::recup_position
   # Recupere la position de la fenetre
   #
   proc recup_position { } {
      variable This
      variable widget
      global faireImageRef

      set faireImageRef(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $faireImageRef(geometry) ] ]
      set fin [ string length $faireImageRef(geometry) ]
      set widget(faireImageRef,position) "+[string range $faireImageRef(geometry) $deb $fin]"
      #---
      ::faireImageRef::widgetToConf
   }

   #
   # ::faireImageRef::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace caption conf faireImageRef

      #--- Initialisation
      set faireImageRef(in)           ""
      set faireImageRef(out)          ""
      set faireImageRef(nb)           ""
      set faireImageRef(1,offset)     ""
      set faireImageRef(1,dark)       ""
      set faireImageRef(1,opt)        "0"
      set faireImageRef(1,flat-field) ""
      set faireImageRef(1,methode)    "2"
      set faireImageRef(1,norm)       ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,dialog,pretraitement)"
      wm geometry $This $widget(faireImageRef,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::faireImageRef::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised

         frame $This.usr.7 -borderwidth 1 -relief raised
            frame $This.usr.7.1 -borderwidth 0 -relief flat
               button $This.usr.7.1.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.7.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.7.1.lab6 -textvariable "faireImageRef(offset)"
               pack $This.usr.7.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.1.ent6 -textvariable faireImageRef(1,offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.7.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.7.1 -side top -fill both
            frame $This.usr.7.2 -borderwidth 0 -relief flat
               button $This.usr.7.2.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 4 }
               pack $This.usr.7.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.7.2.lab6 -textvariable "faireImageRef(dark)"
               pack $This.usr.7.2.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.2.ent6 -textvariable faireImageRef(1,dark) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.7.2.ent6 -side right -padx 10 -pady 5
            pack $This.usr.7.2 -side top -fill both
            frame $This.usr.7.3 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.3.opt -text "$caption(audace,optimisation,noir)" -variable faireImageRef(1,opt)
               pack $This.usr.7.3.opt -side right -padx 60 -pady 5
            pack $This.usr.7.3 -side top -fill both
            frame $This.usr.7.4 -borderwidth 0 -relief flat
               button $This.usr.7.4.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 5 }
               pack $This.usr.7.4.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.7.4.lab6 -textvariable "faireImageRef(flat-field)"
               pack $This.usr.7.4.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.4.ent6 -textvariable faireImageRef(1,flat-field) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.7.4.ent6 -side right -padx 10 -pady 5
            pack $This.usr.7.4 -side top -fill both
        # pack $This.usr.7 -side bottom -fill both

         frame $This.usr.6 -borderwidth 1 -relief raised
            frame $This.usr.6.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.6.1.che1 -text "$caption(afficher,image,fin)" -variable faireImageRef(1,disp)
               pack $This.usr.6.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.6.1 -side top -fill both
        # pack $This.usr.6 -side bottom -fill both

         frame $This.usr.5 -borderwidth 1 -relief raised
            frame $This.usr.5.1 -borderwidth 0 -relief flat
               label $This.usr.5.1.lab9 -text "$caption(audace,methode)"
               pack $This.usr.5.1.lab9 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad0 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,image,somme)" -value 0 -variable faireImageRef(1,methode)
               pack $This.usr.5.1.rad0 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad1 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,image,moyenne)" -value 1 -variable faireImageRef(1,methode)
               pack $This.usr.5.1.rad1 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad2 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,run,median)" -value 2 -variable faireImageRef(1,methode)
               pack $This.usr.5.1.rad2 -side left -padx 10 -pady 5
            pack $This.usr.5.1 -side top -fill both
        # pack $This.usr.5 -side bottom -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               button $This.usr.4.1.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.4.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.4.1.lab6 -textvariable "faireImageRef(offset)"
               pack $This.usr.4.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.1.ent6 -textvariable faireImageRef(1,offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.4.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both
            frame $This.usr.4.2 -borderwidth 0 -relief flat
               label $This.usr.4.2.lab7 -textvariable "faireImageRef(normalisation)"
               pack $This.usr.4.2.lab7 -side left -padx 5 -pady 5
               entry $This.usr.4.2.ent7 -textvariable faireImageRef(1,norm) -width 7 -font $audace(font,arial_8_b)
               pack $This.usr.4.2.ent7 -side right -padx 10 -pady 5
            pack $This.usr.4.2 -side top -fill both
        # pack $This.usr.4 -side bottom -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               button $This.usr.3.1.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.3.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.3.1.lab6 -textvariable "faireImageRef(offset)"
               pack $This.usr.3.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent6 -textvariable faireImageRef(1,offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.3.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -side bottom -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               button $This.usr.2.2.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 1 }
               pack $This.usr.2.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.2.lab3 -textvariable "faireImageRef(image_generique)"
               pack $This.usr.2.2.lab3 -side left -padx 5 -pady 5
               entry $This.usr.2.2.ent3 -textvariable faireImageRef(in) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.2.ent3 -side right -padx 10 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               entry $This.usr.2.1.ent2 -textvariable faireImageRef(nb) -width 7 -font $audace(font,arial_8_b)
               pack $This.usr.2.1.ent2 -side right -padx 10 -pady 5
               label $This.usr.2.1.lab2 -textvariable "faireImageRef(nombre)"
               pack $This.usr.2.1.lab2 -side right -padx 5 -pady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               button $This.usr.2.3.explore -text "$caption(traiteImage,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 2 }
               pack $This.usr.2.3.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.3.lab4 -textvariable "faireImageRef(image_sortie)"
               pack $This.usr.2.3.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.3.ent4 -textvariable faireImageRef(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent4 -side right -padx 10 -pady 5
            pack $This.usr.2.3 -side top -fill both
        # pack $This.usr.2 -side bottom -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            #--- Liste des pretraitements disponibles
            set list_faireImageRef [ list $caption(audace,menu,raw2cfa) $caption(audace,menu,faire_offset) \
               $caption(audace,menu,faire_dark) $caption(audace,menu,faire_flat_field) \
               $caption(audace,menu,pretraite) $caption(audace,menu,cfa2rgb) ]
            #---
            menubutton $This.usr.1.but1 -textvariable faireImageRef(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretraitement $list_faireImageRef {
               $m add radiobutton -label "$pretraitement" \
                -indicatoron "1" \
                -value "$pretraitement" \
                -variable faireImageRef(operation) \
                -command { }
            }
        # pack $This.usr.1 -side bottom -fill both -ipady 5

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conf,ok)" -width 7 \
            -command { ::faireImageRef::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(creer,dialogue,appliquer)" -width 8 \
            -command { ::faireImageRef::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(creer,dialogue,fermer)" -width 7 \
            -command { ::faireImageRef::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conf,aide)" -width 7 \
            -command { ::faireImageRef::afficheAide } 
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable faireImageRef(operation) w ::faireImageRef::change

      #---
      bind $This <Key-Return> {::faireImageRef::cmdOk}
      bind $This <Key-Escape> {::faireImageRef::cmdClose}

      #--- Focus
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #---
      ::faireImageRef::formule
   }

   #
   # ::faireImageRef::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      ::faireImageRef::cmdApply
      ::faireImageRef::cmdClose
   }

   #
   # ::faireImageRef::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      global audace caption conf faireImageRef

      #---
      set in $faireImageRef(in)
      set out $faireImageRef(out)
      set nb $faireImageRef(nb)
      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $faireImageRef(in) == "" } {
          tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,entree_generique)
          return
      }
      if { $faireImageRef(nb) == "" } {
          tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,choix_nbre_images)
          return
      }
      if { [ TestEntier $faireImageRef(nb) ] == "0" } {
         tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,nbre_entier)
         return
      }
      if { $faireImageRef(out) == "" } {
         if { $faireImageRef(operation) == $caption(audace,menu,raw2cfa) || $faireImageRef(operation) == $caption(audace,menu,pretraite) || $faireImageRef(operation) == $caption(audace,menu,cfa2rgb) } {
             tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,sortie_generique)
             return
         } else {
             tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,image_sortie)
             return
         }
      }
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      if { ( $in != "" ) && ( $out != "" ) && ( $nb != "" ) } {
         switch $faireImageRef(operation) \
            "$caption(audace,menu,raw2cfa)" {
               catch { raw2cfa $in $out $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,raw2cfa) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,faire_offset)" {
               catch { smedian $in $out $nb } m
               if { $m == "" } {
                  if { $faireImageRef(1,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,menu,faire_offset) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,faire_dark)" {
               #--- Test sur l'offset
               if { $faireImageRef(1,offset) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,offset)
                  return
               }
               #---
               set offset $faireImageRef(1,offset)
               set const "0"
               set temp "temp"
               catch { sub2 $in $offset $temp $const $nb } m
               if { $faireImageRef(1,methode) == "0" } {
                  #--- Somme
                  catch { sadd $temp $out $nb } m
               } elseif { $faireImageRef(1,methode) == "1" } {
                  #--- Moyenne
                  catch { smean $temp $out $nb } m
               } elseif { $faireImageRef(1,methode) == "2" } {
                  #--- Mediane
                  catch { smedian $temp $out $nb } m
               }
               catch { delete2 $temp $nb } m
               if { $m == "" } {
                  if { $faireImageRef(1,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,menu,faire_dark) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,faire_flat_field)" {
               #--- Test sur l'offset
               if { $faireImageRef(1,offset) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,offset)
                  return
               }
               #--- Tests sur la valeur de normalisation
               if { $faireImageRef(1,norm) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,constante)
                  return
               }
               if { [ string is double -strict $faireImageRef(1,norm) ] == "0" } {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $caption(audace,cte_invalide)
                  return
               }
               #---
               set offset $faireImageRef(1,offset)
               set norm   $faireImageRef(1,norm)
               set const  "0"
               set temp   "temp"
               set tempo  "tempo"
               catch { sub2 $in $offset $temp $const $nb } m
               catch { noffset2 $temp $tempo $norm $nb } m
               catch { smedian $tempo $out $nb } m
               catch { delete2 $temp $nb } m
               catch { delete2 $tempo $nb } m
               if { $m == "" } {
                  if { $faireImageRef(1,disp) == 1 } {
                     loadima $out
                     ::audace::autovisu $audace(visuNo)
                  }
                  tk_messageBox -title $caption(audace,menu,faire_flat_field) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,pretraite)" {
               #--- Test sur l'offset
               if { $faireImageRef(1,offset) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,offset)
                  return
               }
               #--- Test sur le dark
               if { $faireImageRef(1,dark) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,noir)
                  return
               }
               #--- Test sur le flat-field
               if { $faireImageRef(1,flat-field) == "" } {
                  tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,definir,flat-field)
                  return
               }
               #---
               set offset     $faireImageRef(1,offset)
               set dark       $faireImageRef(1,dark)
               set flat       $faireImageRef(1,flat-field)
               set const      "0"
               set const_mult "1"
               set temp       "temp"
               #--- Deux possibilites de pretraitement
               if { $faireImageRef(1,opt) == "0" } {
                  #--- Formule : Generique de sortie = [ Generique d'entree - ( Offset + Dark ) ] / Flat-field
                  #--- Realisation de X = ( Offset + Dark )
                  catch {
                     set buf_pretrait [::buf::create]
                     buf$buf_pretrait load $audace(rep_images)/$offset
                     buf$buf_pretrait add $audace(rep_images)/$dark $const
                     buf$buf_pretrait save $audace(rep_images)/offset+dark
                     ::buf::delete $buf_pretrait
                  } m
                  #--- Realisation de Y = [ Generique d'entree - ( X ) ]
                  catch { sub2 $in offset+dark $temp $const $nb } m
                  #--- Realisation de Z = Y / Flat-field
                  catch { div2 $temp $flat $out $const_mult $nb } m
                  #--- Suppression des fichiers intermediaires
                  catch { delete2 $temp $nb } m
                  catch { file delete [ file join $audace(rep_images) offset+dark$conf(extension,defaut) ] } m
               } else {
                  #--- Optimisation du noir
                  catch { opt2 $in $dark $offset $temp $nb } m
                  #--- Division par le flat
                  catch { div2 $temp $flat $out $const_mult $nb } m
                  #--- Suppression des fichiers intermediaires
                  catch { delete2 $temp $nb } m
               }
               #---
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,pretraite) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            } \
            "$caption(audace,menu,cfa2rgb)" {
               catch { cfa2rgb $in $out $nb } m
               if { $m == "" } {
                  tk_messageBox -title $caption(audace,menu,cfa2rgb) -type ok -message $caption(audace,fin_traitement)
               } else {
                  tk_messageBox -title $caption(audace,boite,attention) -icon error -message $m
               }
            }
      }
      ::faireImageRef::recup_position
   }

   #
   # ::faireImageRef::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This

      ::faireImageRef::recup_position
      destroy $This
      unset This
   }

   #
   # ::faireImageRef::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global caption help faireImageRef

      #---
      if { $faireImageRef(operation) == $caption(audace,menu,raw2cfa) } {
         set faireImageRef(page_web) "1112raw2cfa"
      } elseif { $faireImageRef(operation) == $caption(audace,menu,faire_offset) } {
         set faireImageRef(page_web) "1113faire_offset"
      } elseif { $faireImageRef(operation) == $caption(audace,menu,faire_dark) } {
         set faireImageRef(page_web) "1114faire_dark"
      } elseif { $faireImageRef(operation) == $caption(audace,menu,faire_flat_field) } {
         set faireImageRef(page_web) "1115faire_flat_field"
      } elseif { $faireImageRef(operation) == $caption(audace,menu,pretraite) } {
         set faireImageRef(page_web) "1116pretraitement"
      } elseif { $faireImageRef(operation) == $caption(audace,menu,cfa2rgb) } {
         set faireImageRef(page_web) "1117cfa2rgb"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$faireImageRef(page_web).htm"
   }

   #
   # ::faireImageRef::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This
      global caption faireImageRef

      #---
      ::faireImageRef::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $faireImageRef(operation) \
         "$caption(audace,menu,raw2cfa)" {
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,faire_offset)" {
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,faire_dark)" {
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack $This.usr.5 -in $This.usr -side top -fill both
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,faire_flat_field)" {
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
         } \
         "$caption(audace,menu,pretraite)" {
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack $This.usr.7 -in $This.usr -side top -fill both
         } \
         "$caption(audace,menu,cfa2rgb)" {
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
         }
   }

   #
   # ::faireImageRef::parcourir In_Out
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      global audace faireImageRef

      #--- Fenetre parent
      set fenetre "$audace(base).faireImageRef"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         set faireImageRef(in) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "2" } {
         set faireImageRef(out) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "3" } {
         set faireImageRef(1,offset) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "4" } {
         set faireImageRef(1,dark) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "5" } {
         set faireImageRef(1,flat-field) [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::faireImageRef::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption faireImageRef

      if { $faireImageRef(operation) == "$caption(audace,menu,raw2cfa)" } {
         set faireImageRef(image_generique) "$caption(audace,image_generique,entree)"
         set faireImageRef(nombre)          "$caption(audace,image,nombre)"
         set faireImageRef(image_sortie)    "$caption(audace,image_generique,sortie)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,faire_dark)" } {
         set faireImageRef(image_generique) "$caption(audace,image_generique,entree)"
         set faireImageRef(nombre)          "$caption(audace,image,nombre)"
         set faireImageRef(image_sortie)    "$caption(audace,image,sortie)"
         set faireImageRef(offset)          "$caption(audace,image,offset)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,faire_flat_field)" } {
         set faireImageRef(image_generique) "$caption(audace,image_generique,entree)"
         set faireImageRef(nombre)          "$caption(audace,image,nombre)"
         set faireImageRef(image_sortie)    "$caption(audace,image,sortie)"
         set faireImageRef(offset)          "$caption(audace,image,offset)"
         set faireImageRef(normalisation)   "$caption(audace,valeur_normalisation)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,pretraite)" } {
         set faireImageRef(image_generique) "$caption(audace,image_generique,entree)"
         set faireImageRef(nombre)          "$caption(audace,image,nombre)"
         set faireImageRef(image_sortie)    "$caption(audace,image_generique,sortie)"
         set faireImageRef(offset)          "$caption(audace,image,offset)"
         set faireImageRef(dark)            "$caption(audace,image,dark)"
         set faireImageRef(flat-field)      "$caption(audace,image,flat-field)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,cfa2rgb)" } {
         set faireImageRef(image_generique) "$caption(audace,image_generique,entree)"
         set faireImageRef(nombre)          "$caption(audace,image,nombre)"
         set faireImageRef(image_sortie)    "$caption(audace,image_generique,sortie)"
      } else {
         set faireImageRef(image_generique) "$caption(audace,image_generique,entree)"
         set faireImageRef(nombre)          "$caption(audace,image,nombre)"
         set faireImageRef(image_sortie)    "$caption(audace,image,sortie)"
      }
   }

}
########################## Fin du namespace faireImageRef ##########################

