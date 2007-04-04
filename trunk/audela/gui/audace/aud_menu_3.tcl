#
# Fichier : aud_menu_3.tcl
# Description : Script regroupant les fonctionnalites du menu Pretraitement
# Mise a jour $Id: aud_menu_3.tcl,v 1.18 2007-04-04 17:32:37 robertdelmas Exp $
#

namespace eval ::pretraitement {

   #
   # ::pretraitement::run type_pretraitement this
   # Lance la boite de dialogue pour les pretraitements sur une images
   # this : Chemin de la fenetre
   #
   proc run { type_pretraitement this } {
      variable This
      variable widget
      global pretraitement

      #---
      ::pretraitement::initConf
      ::pretraitement::confToWidget
      #---
      if { [ info exists This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set This $this
         if { [ info exists pretraitement(geometry) ] } {
            set deb [ expr 1 + [ string first + $pretraitement(geometry) ] ]
            set fin [ string length $pretraitement(geometry) ]
            set widget(pretraitement,position) "+[string range $pretraitement(geometry) $deb $fin]"
         }
         createDialog
      }
      #---
      set pretraitement(operation) "$type_pretraitement"
   }

   #
   # ::pretraitement::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(multx) ] }                  { set conf(multx)                  "2.0" }
      if { ! [ info exists conf(multy) ] }                  { set conf(multy)                  "2.0" }
      if { ! [ info exists conf(clip_maxi) ] }              { set conf(clip_maxi)              "32767" }
      if { ! [ info exists conf(clip_mini) ] }              { set conf(clip_mini)              "0" }
      if { ! [ info exists conf(back_kernel) ] }            { set conf(back_kernel)            "15" }
      if { ! [ info exists conf(back_threshold) ] }         { set conf(back_threshold)         "0.2" }
      if { ! [ info exists conf(pretraitement,position) ] } { set conf(pretraitement,position) "+350+75" }

      return
   }

   #
   # ::pretraitement::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(pretraitement,position) "$conf(pretraitement,position)"
   }

   #
   # ::pretraitement::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(pretraitement,position) "$widget(pretraitement,position)"
   }

   #
   # ::pretraitement::recup_position
   # Recupere la position de la fenetre
   #
   proc recup_position { } {
      variable This
      variable widget
      global pretraitement

      set pretraitement(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $pretraitement(geometry) ] ]
      set fin [ string length $pretraitement(geometry) ]
      set widget(pretraitement,position) "+[string range $pretraitement(geometry) $deb $fin]"
      #---
      ::pretraitement::widgetToConf
   }

   #
   # ::pretraitement::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace caption color conf pretraitement

      #--- Initialisation des variables principales
      set pretraitement(choix_mode)     "0"
      set pretraitement(in)             ""
      set pretraitement(nb)             ""
      set pretraitement(valeur_indice)  "1"
      set pretraitement(out)            ""
      set pretraitement(disp_1)         "1"
      set pretraitement(disp_2)         "1"
      set pretraitement(afficher_image) "$caption(pretraitement,afficher_image_fin)"
      set pretraitement(avancement)     ""

      #--- Initialisation des variables de la fonction re-échantillonnage
      set pretraitement(scaleWindow_multx) $conf(multx)
      set pretraitement(scaleWindow_multy) $conf(multy)

      #--- Initialisation des variables de la fonction écrêtage
      set pretraitement(clipWindow_mini) $conf(clip_mini)
      set pretraitement(clipWindow_maxi) $conf(clip_maxi)

      #--- Initialisation des variables de la fonction soustraction du fond de ciel
      set pretraitement(subskyWindow_back_kernel)    $conf(back_kernel)
      set pretraitement(subskyWindow_back_threshold) $conf(back_threshold)

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,pretraite)"
      wm geometry $This $widget(pretraitement,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::pretraitement::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.0 -borderwidth 1 -relief raised
            label $This.usr.0.lab1 -textvariable "pretraitement(formule)" -font $audace(font,arial_15_b)
            pack $This.usr.0.lab1 -padx 10 -pady 5
        # pack $This.usr.0 -in $This.usr -side top -fill both

         frame $This.usr.9 -borderwidth 1 -relief raised
            frame $This.usr.9.1 -borderwidth 0 -relief flat
               label $This.usr.9.1.labURL1 -textvariable "pretraitement(avancement)" -font $audace(font,arial_12_b) \
                  -fg $color(blue)
               pack $This.usr.9.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.9.1 -side top -fill both
        # pack $This.usr.9 -in $This.usr -side top -fill both

         frame $This.usr.7 -borderwidth 1 -relief raised
            frame $This.usr.7.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.1.che1 -text "$pretraitement(afficher_image)" -variable pretraitement(disp_2)
               pack $This.usr.7.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.7.1 -side top -fill both
        # pack $This.usr.7 -in $This.usr -side top -fill both

         frame $This.usr.10 -borderwidth 1 -relief raised
            frame $This.usr.10.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.10.1.che1 -text "$pretraitement(afficher_image)" -variable pretraitement(disp_1) \
                  -state disabled
               pack $This.usr.10.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.10.1 -side top -fill both
        # pack $This.usr.10 -in $This.usr -side top -fill both

         frame $This.usr.6 -borderwidth 1 -relief raised
            frame $This.usr.6.1 -borderwidth 0 -relief flat
               label $This.usr.6.1.lab1 -text "$caption(pretraitement,multx)"
               pack $This.usr.6.1.lab1 -side left -padx 10 -pady 10
               entry $This.usr.6.1.ent1 -textvariable pretraitement(scaleWindow_multx) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.6.1.ent1 -side right -padx 10 -pady 10
            pack $This.usr.6.1 -side top -fill x
            frame $This.usr.6.2 -borderwidth 0 -relief flat
               label $This.usr.6.2.lab2 -text "$caption(pretraitement,multy)"
               pack $This.usr.6.2.lab2 -side left -padx 10 -pady 5
               entry $This.usr.6.2.ent2 -textvariable pretraitement(scaleWindow_multy) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.6.2.ent2 -side right -padx 10 -pady 5
            pack $This.usr.6.2 -side top -fill x
            frame $This.usr.6.3 -borderwidth 0 -relief flat
               button $This.usr.6.3.but_defaut -text "$caption(pretraitement,valeur_par_defaut)" \
                  -command { ::pretraitement::val_defaut }
               pack $This.usr.6.3.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
            pack $This.usr.6.3 -side top -fill both
        # pack $This.usr.6 -in $This.usr -side top -fill both

         frame $This.usr.11 -borderwidth 1 -relief raised
            frame $This.usr.11.1 -borderwidth 0 -relief flat
               label $This.usr.11.1.lab1 -text "$caption(pretraitement,grille_subsky)"
               pack $This.usr.11.1.lab1 -side left -padx 10 -pady 10
               entry $This.usr.11.1.ent1 -textvariable pretraitement(subskyWindow_back_kernel) -width 7 \
                  -justify center -font $audace(font,arial_8_b)
               pack $This.usr.11.1.ent1 -side right -padx 10 -pady 10
            pack $This.usr.11.1 -side top -fill x
            frame $This.usr.11.2 -borderwidth 0 -relief flat
               label $This.usr.11.2.lab2 -text "$caption(pretraitement,seuil_subsky)"
               pack $This.usr.11.2.lab2 -side left -padx 10 -pady 5
               entry $This.usr.11.2.ent2 -textvariable pretraitement(subskyWindow_back_threshold) -width 7 \
                  -justify center -font $audace(font,arial_8_b)
               pack $This.usr.11.2.ent2 -side right -padx 10 -pady 5
            pack $This.usr.11.2 -side top -fill x
            frame $This.usr.11.3 -borderwidth 0 -relief flat
               button $This.usr.11.3.but_defaut -text "$caption(pretraitement,valeur_par_defaut)" \
                  -command { ::pretraitement::val_defaut }
               pack $This.usr.11.3.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
            pack $This.usr.11.3 -side top -fill both
        # pack $This.usr.11 -in $This.usr -side top -fill both

         frame $This.usr.12 -borderwidth 1 -relief raised
            frame $This.usr.12.15 -borderwidth 0 -relief flat
               label $This.usr.12.15.lab1 -text "$caption(pretraitement,clip_min)"
               pack $This.usr.12.15.lab1 -side left -padx 10 -pady 10
               entry $This.usr.12.15.ent1 -textvariable pretraitement(clipWindow_mini) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.12.15.ent1 -side right -padx 10 -pady 10
            pack $This.usr.12.15 -side top -fill x
            frame $This.usr.12.16 -borderwidth 0 -relief flat
               label $This.usr.12.16.lab2 -text "$caption(pretraitement,clip_max)"
               pack $This.usr.12.16.lab2 -side left -padx 10 -pady 5
               entry $This.usr.12.16.ent2 -textvariable pretraitement(clipWindow_maxi) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.12.16.ent2 -side right -padx 10 -pady 5
            pack $This.usr.12.16 -side top -fill both
            frame $This.usr.12.17 -borderwidth 0 -relief flat
               button $This.usr.12.17.but_defaut -text "$caption(pretraitement,valeur_par_defaut)" \
                  -command { ::pretraitement::val_defaut }
               pack $This.usr.12.17.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
            pack $This.usr.12.17 -side top -fill both
        # pack $This.usr.12 -in $This.usr -side top -fill both

         frame $This.usr.5 -borderwidth 1 -relief raised
            frame $This.usr.5.1 -borderwidth 0 -relief flat
               button $This.usr.5.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 4 }
               pack $This.usr.5.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.5.1.lab8 -text "$caption(pretraitement,image_dark)"
               pack $This.usr.5.1.lab8 -side left -padx 5 -pady 5
               entry $This.usr.5.1.ent8 -textvariable pretraitement(3,dark) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.5.1.ent8 -side right -padx 10 -pady 5
            pack $This.usr.5.1 -side top -fill both
            frame $This.usr.5.2 -borderwidth 0 -relief flat
               button $This.usr.5.2.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 5 }
               pack $This.usr.5.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.5.2.lab9 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.5.2.lab9 -side left -padx 5 -pady 5
               entry $This.usr.5.2.ent9 -textvariable pretraitement(3,offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.5.2.ent9 -side right -padx 10 -pady 5
            pack $This.usr.5.2 -side top -fill both
        # pack $This.usr.5 -in $This.usr -side top -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               button $This.usr.4.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 3 }
               pack $This.usr.4.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.4.1.lab6 -textvariable "pretraitement(operande)"
               pack $This.usr.4.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.1.ent6 -textvariable pretraitement(2,operand) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.4.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both
            frame $This.usr.4.2 -borderwidth 0 -relief flat
               label $This.usr.4.2.lab7 -textvariable "pretraitement(constante)"
               pack $This.usr.4.2.lab7 -side left -padx 5 -pady 5
               entry $This.usr.4.2.ent7 -textvariable pretraitement(const) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.4.2.ent7 -side right -padx 10 -pady 5
            pack $This.usr.4.2 -side top -fill both
        # pack $This.usr.4 -in $This.usr -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               label $This.usr.3.1.lab5 -textvariable "pretraitement(constante)"
               pack $This.usr.3.1.lab5 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent5 -textvariable pretraitement(const) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.3.1.ent5 -side right -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -in $This.usr -side top -fill both

         frame $This.usr.8 -borderwidth 1 -relief raised
            frame $This.usr.8.1 -borderwidth 0 -relief flat
               button $This.usr.8.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 1 }
               pack $This.usr.8.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.8.1.lab1 -textvariable "pretraitement(image_A)"
               pack $This.usr.8.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.8.1.ent1 -textvariable pretraitement(in) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.8.1.ent1 -side right -padx 10 -pady 5
            pack $This.usr.8.1 -side top -fill both
            frame $This.usr.8.2 -borderwidth 0 -relief flat
               button $This.usr.8.2.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 2 }
               pack $This.usr.8.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.8.2.lab1 -textvariable "pretraitement(image_B)"
               pack $This.usr.8.2.lab1 -side left -padx 5 -pady 5
               entry $This.usr.8.2.ent1 -textvariable pretraitement(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.8.2.ent1 -side right -padx 10 -pady 5
            pack $This.usr.8.2 -side top -fill both
        # pack $This.usr.8 -in $This.usr -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               button $This.usr.2.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 1 }
               pack $This.usr.2.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.1.lab1 -textvariable "pretraitement(image_A)"
               pack $This.usr.2.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.2.1.ent1 -textvariable pretraitement(in) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.1.ent1 -side right -padx 10 -pady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               entry $This.usr.2.2.ent2 -textvariable pretraitement(nb) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.2.ent2 -side right -padx 10 -pady 5
               label $This.usr.2.2.lab2 -textvariable "pretraitement(nombre)"
               pack $This.usr.2.2.lab2 -side right -padx 5 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               entry $This.usr.2.3.ent3 -textvariable pretraitement(valeur_indice) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent3 -side right -padx 10 -pady 5
               label $This.usr.2.3.lab3 -textvariable "pretraitement(premier_indice)"
               pack $This.usr.2.3.lab3 -side right -padx 5 -pady 5
            pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               button $This.usr.2.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::pretraitement::parcourir 2 }
               pack $This.usr.2.4.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.4.lab4 -textvariable "pretraitement(image_B)"
               pack $This.usr.2.4.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.4.ent4 -textvariable pretraitement(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.4.ent4 -side right -padx 10 -pady 5
            pack $This.usr.2.4 -side top -fill both
        # pack $This.usr.2 -in $This.usr -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.radiobutton -borderwidth 0 -relief raised
               radiobutton $This.usr.1.radiobutton.rad1 -anchor nw -highlightthickness 0 \
                  -text "$caption(pretraitement,image_affichee:)" -value 0 -variable pretraitement(choix_mode) \
                  -command { ::pretraitement::change n1 n2 op }
               pack $This.usr.1.radiobutton.rad1 -side top -anchor w -padx 10 -pady 5
               radiobutton $This.usr.1.radiobutton.rad2 -anchor nw -highlightthickness 0 \
                  -text "$caption(pretraitement,image_sur_DD)" -value 1 -variable pretraitement(choix_mode) \
                  -command { ::pretraitement::change n1 n2 op }
               pack $This.usr.1.radiobutton.rad2 -side top -anchor w -padx 10 -pady 5
               radiobutton $This.usr.1.radiobutton.rad3 -anchor nw -highlightthickness 0 \
                  -text "$caption(pretraitement,operation_serie)" -value 2 -variable pretraitement(choix_mode) \
                  -command { ::pretraitement::change n1 n2 op }
               pack $This.usr.1.radiobutton.rad3 -side top -anchor w -padx 10 -pady 5
            pack $This.usr.1.radiobutton -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_pretraitement [ list $caption(audace,menu,scale) $caption(audace,menu,offset) \
               $caption(audace,menu,mult_cte) $caption(audace,menu,clip) $caption(audace,menu,subsky) \
               $caption(audace,menu,noffset) $caption(audace,menu,ngain) $caption(audace,menu,addition) \
               $caption(audace,menu,soust) $caption(audace,menu,division) $caption(audace,menu,opt_noir) ]
            #---
            menubutton $This.usr.1.but1 -textvariable pretraitement(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_pretraitement {
               $m add radiobutton -label "$pretrait" \
                -indicatoron "1" \
                -value "$pretrait" \
                -variable pretraitement(operation) \
                -command { }
            }
        # pack $This.usr.1 -in $This.usr -side top -fill both
      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command { ::pretraitement::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command { ::pretraitement::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command { ::pretraitement::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
            -command { ::pretraitement::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable pretraitement(operation) w ::pretraitement::change

      #---
      bind $This <Key-Return> {::pretraitement::cmdOk}
      bind $This <Key-Escape> {::pretraitement::cmdClose}

      #--- Focus
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #---
      ::pretraitement::formule
   }

   #
   # ::pretraitement::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      ::pretraitement::cmdApply
      ::pretraitement::cmdClose
   }

   #
   # ::pretraitement::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { { visuNo "1" } } {
      variable This
      global audace caption pretraitement

      #---
      set pretraitement(avancement) "$caption(pretraitement,en_cours)"
      update

      #---
      set in    $pretraitement(in)
      set nb    $pretraitement(nb)
      set first $pretraitement(valeur_indice)
      set out   $pretraitement(out)
      set end   [ expr $nb + ( $first - 1 ) ]

      #--- Tests sur les images
      if { $pretraitement(choix_mode) == "0" } {
         #--- Il faut une image affichee
         if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] != "1" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,header_noimage)
            set pretraitement(avancement) ""
            return
         }
      } elseif { $pretraitement(choix_mode) == "1" } {
         #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
         if { $pretraitement(in) == "" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,definir_image_entree)
            set pretraitement(avancement) ""
            return
         }
         if { $pretraitement(out) == "" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,definir_image_sortie)
            set pretraitement(avancement) ""
            return
         }
      } elseif { $pretraitement(choix_mode) == "2" } {
         #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
         if { $pretraitement(in) == "" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,definir_entree_generique)
            set pretraitement(avancement) ""
            return
         }
         if { $pretraitement(nb) == "" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,choix_nbre_images)
            set pretraitement(avancement) ""
            return
         }
         if { [ TestEntier $pretraitement(nb) ] == "0" } {
            tk_messageBox -title $caption(pretraitement,attention) -icon error \
               -message $caption(pretraitement,nbre_entier)
            set pretraitement(avancement) ""
            return
         }
         if { $pretraitement(out) == "" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,definir_sortie_generique)
            set pretraitement(avancement) ""
            return
         }
      }

      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $pretraitement(operation) \
         "$caption(audace,menu,scale)" {
            #---
            set conf(multx) $pretraitement(scaleWindow_multx)
            set conf(multy) $pretraitement(scaleWindow_multy)
            #--- Tests sur les facteurs d'echelle
            if { $pretraitement(scaleWindow_multx) == "" && $pretraitement(scaleWindow_multy) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,choix_coefficients)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(scaleWindow_multx) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,coef_manquant)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(scaleWindow_multy) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,coef_manquant)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(scaleWindow_multx) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(scaleWindow_multy) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch {
                  set x $pretraitement(scaleWindow_multx)
                  set y $pretraitement(scaleWindow_multy)
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
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               ::console::affiche_resultat "Usage: scale1 in out scale_x scale_y\n\n"
               catch {
                  set x $pretraitement(scaleWindow_multx)
                  set y $pretraitement(scaleWindow_multy)
                  set maxi "50"
                  if { [ expr $x ] == "0" } { set x "1" }
                  if { [ expr $x ] > "$maxi" } { set x "$maxi" }
                  if { [ expr $x ] < "-$maxi" } { set x "-$maxi" }
                  if { [ expr $y ] == "0" } { set y "1" }
                  if { [ expr $y ] > "$maxi" } { set y "$maxi" }
                  if { [ expr $y ] < "-$maxi" } { set y "-$maxi" }
                  scale1 $in $out $x $y
               } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               ::console::affiche_resultat "Usage: scale2 in out number scale_x scale_y ?first_index?\n\n"
               catch {
                  set x $pretraitement(scaleWindow_multx)
                  set y $pretraitement(scaleWindow_multy)
                  set maxi "50"
                  if { [ expr $x ] == "0" } { set x "1" }
                  if { [ expr $x ] > "$maxi" } { set x "$maxi" }
                  if { [ expr $x ] < "-$maxi" } { set x "-$maxi" }
                  if { [ expr $y ] == "0" } { set y "1" }
                  if { [ expr $y ] > "$maxi" } { set y "$maxi" }
                  if { [ expr $y ] < "-$maxi" } { set y "-$maxi" }
                  scale2 $in $out $nb $x $y $first
               } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,offset)" {
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_cte)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { offset $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error \
                     -message $caption(pretraitement,cte_invalide)
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: offset1 in out const\n\n"
               catch { offset1 $in $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: offset2 in out const number ?first_index?\n\n"
               catch { offset2 $in $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,mult_cte)" {
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_cte)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { mult $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error \
                     -message $caption(pretraitement,cte_invalide)
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: mult1 in out const\n\n"
               catch { mult1 $in $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: mult2 in out const number ?first_index?\n\n"
               catch { mult2 $in $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,clip)" {
            #---
            set conf(clip_mini) $pretraitement(clipWindow_mini)
            set conf(clip_maxi) $pretraitement(clipWindow_maxi)
            #--- Tests sur les constantes
            if { $pretraitement(clipWindow_mini) == "" && $pretraitement(clipWindow_maxi) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,choix_coefficients)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(clipWindow_mini) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,coef_manquant)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(clipWindow_maxi) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,coef_manquant)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(clipWindow_mini) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(clipWindow_maxi) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch {
                  if { $pretraitement(clipWindow_mini) != "" } {
                     buf$audace(bufNo) clipmin $pretraitement(clipWindow_mini)
                  }
                  if { $pretraitement(clipWindow_maxi) != "" } {
                     buf$audace(bufNo) clipmax $pretraitement(clipWindow_maxi)
                  }
               } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               catch {
                  set buf_clip [ ::buf::create ]
                  buf$buf_clip load $audace(rep_images)/$in
                  if { $pretraitement(clipWindow_mini) != "" } {
                     buf$buf_clip clipmin $pretraitement(clipWindow_mini)
                  }
                  if { $pretraitement(clipWindow_maxi) != "" } {
                     buf$buf_clip clipmax $pretraitement(clipWindow_maxi)
                  }
                  buf$buf_clip save $audace(rep_images)/$out
                  ::buf::delete $buf_clip
               } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               catch {
                  for { set index "$first" } { $index <= $end } { incr index } {
                     set buf_clip($index) [ ::buf::create ]
                     buf$buf_clip($index) load $audace(rep_images)/$in$index
                     if { $pretraitement(clipWindow_mini) != "" } {
                        buf$buf_clip($index) clipmin $pretraitement(clipWindow_mini)
                     }
                     if { $pretraitement(clipWindow_maxi) != "" } {
                        buf$buf_clip($index) clipmax $pretraitement(clipWindow_maxi)
                     }
                     buf$buf_clip($index) save $audace(rep_images)/$out$index
                  }
                  for { set index "$first" } { $index <= $end } { incr index } {
                     ::buf::delete $buf_clip($index)
                  }
               } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,subsky)" {
            #---
            set conf(back_kernel)    $pretraitement(subskyWindow_back_kernel)
            set conf(back_threshold) $pretraitement(subskyWindow_back_threshold)
            #--- Tests sur les constantes
            if { $pretraitement(subskyWindow_back_kernel) == "" && $pretraitement(subskyWindow_back_threshold) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,choix_coefficients)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(subskyWindow_back_kernel) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,coef_manquant)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(subskyWindow_back_threshold) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,coef_manquant)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(subskyWindow_back_kernel) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(subskyWindow_back_threshold) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch {
                  set k $pretraitement(subskyWindow_back_kernel)
                  set t $pretraitement(subskyWindow_back_threshold)
                  if { [ expr $k ] < "4" } { set k "3" }
                  if { [ expr $k ] > "50" } { set k "50" }
                  if { [ expr $t ] < "0" } { set t "0" }
                  if { [ expr $t ] > "1" } { set t "1" }
                  subsky $k $t
                  ::audace::autovisu $audace(visuNo)
               } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               ::console::affiche_resultat "Usage: subsky1 in out back_kernel back_threshold\n\n"
               catch {
                  set k $pretraitement(subskyWindow_back_kernel)
                  set t $pretraitement(subskyWindow_back_threshold)
                  if { [ expr $k ] < "4" } { set k "3" }
                  if { [ expr $k ] > "50" } { set k "50" }
                  if { [ expr $t ] < "0" } { set t "0" }
                  if { [ expr $t ] > "1" } { set t "1" }
                  subsky1 $in $out $k $t
               } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               ::console::affiche_resultat "Usage: subsky2 in out number back_kernel back_threshold ?first_index?\n\n"
               catch {
                  set k $pretraitement(subskyWindow_back_kernel)
                  set t $pretraitement(subskyWindow_back_threshold)
                  if { [ expr $k ] < "4" } { set k "3" }
                  if { [ expr $k ] > "50" } { set k "50" }
                  if { [ expr $t ] < "0" } { set t "0" }
                  if { [ expr $t ] > "1" } { set t "1" }
                  subsky2 $in $out $nb $k $t $first
               } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,noffset)" {
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_fond_ciel)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { noffset $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: noffset1 in out const\n\n"
               catch { noffset1 $in $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: noffset2 in out const number ?first_index? ?tt_options?\n\n"
               catch { noffset2 $in $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,ngain)" {
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_fond_ciel)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { ngain $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: ngain1 in out const\n\n"
               catch { ngain1 $in $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: ngain2 in out const number ?first_index? ?tt_options?\n\n"
               catch { ngain2 $in $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,addition)" {
            #--- Test sur l'operande
            if { $pretraitement(2,operand) == "" } {
               if { $pretraitement(choix_mode) == "0" } {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_image_B)
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_operande)
               }
               set pretraitement(avancement) ""
               return
            }
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_cte)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { add $pretraitement(2,operand) $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set operand $pretraitement(2,operand)
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: add1 in operand out const\n\n"
               catch { add1 $in $operand $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set operand $pretraitement(2,operand)
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: add2 in operand out const number ?first_index? ?tt_options?\n\n"
               catch { add2 $in $operand $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,soust)" {
            #--- Test sur l'operande
            if { $pretraitement(2,operand) == "" } {
               if { $pretraitement(choix_mode) == "0" } {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_image_B)
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_operande)
               }
               set pretraitement(avancement) ""
               return
            }
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_cte)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { sub $pretraitement(2,operand) $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set operand $pretraitement(2,operand)
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: sub1 in operand out const\n\n"
               catch { sub1 $in $operand $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set operand $pretraitement(2,operand)
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: sub2 in operand out const number ?first_index? ?tt_options?\n\n"
               catch { sub2 $in $operand $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,division)" {
            #--- Test sur l'operande
            if { $pretraitement(2,operand) == "" } {
               if { $pretraitement(choix_mode) == "0" } {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_image_B)
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_operande)
               }
               set pretraitement(avancement) ""
               return
            }
            #--- Tests sur la constante
            if { $pretraitement(const) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_cte)
               set pretraitement(avancement) ""
               return
            }
            if { [ string is double -strict $pretraitement(const) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { div $pretraitement(2,operand) $pretraitement(const) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set operand $pretraitement(2,operand)
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: div1 in operand out const\n\n"
               catch { div1 $in $operand $out $const } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set operand $pretraitement(2,operand)
               set const $pretraitement(const)
               ::console::affiche_resultat "Usage: div2 in operand out const number ?first_index? ?tt_options?\n\n"
               catch { div2 $in $operand $out $const $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         } \
         "$caption(audace,menu,opt_noir)" {
            #--- Test sur le noir
            if { $pretraitement(3,dark) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_noir)
               set pretraitement(avancement) ""
               return
            }
            #--- Test sur l'offset
            if { $pretraitement(3,offset) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_offset)
               set pretraitement(avancement) ""
               return
            }
            if { $pretraitement(choix_mode) == "0" } {
               #---
               catch { opt $pretraitement(3,dark) $pretraitement(3,offset) } m
               if { $m == "" } {
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "1" } {
               #---
               set dark $pretraitement(3,dark)
               set offset $pretraitement(3,offset)
               ::console::affiche_resultat "Usage: opt1 in dark offset out\n\n"
               catch { opt1 $in $dark $offset $out } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            } elseif { $pretraitement(choix_mode) == "2" } {
               #---
               set dark $pretraitement(3,dark)
               set offset $pretraitement(3,offset)
               ::console::affiche_resultat "Usage: opt2 in dark offset out number ?first_index? ?tt_options?\n\n"
               catch { opt2 $in $dark $offset $out $nb $first } m
               if { $m == "" } {
                  if { $pretraitement(disp_2) == 1 } {
                     loadima $out$end
                  }
                  set pretraitement(avancement) "$caption(pretraitement,fin_traitement)"
               } else {
                  tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
                  set pretraitement(avancement) ""
               }
            }
         }
      ::pretraitement::recup_position
   }

   #
   # ::pretraitement::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This

      ::pretraitement::recup_position
      destroy $This
      unset This
   }

   #
   # ::pretraitement::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global caption help pretraitement

      #---
      if { $pretraitement(operation) == $caption(audace,menu,scale) } {
         set pretraitement(page_web) "1020reechantillonner"
      } elseif { $pretraitement(operation) == $caption(audace,menu,offset) } {
         set pretraitement(page_web) "1030ajouter_cte"
      } elseif { $pretraitement(operation) == $caption(audace,menu,mult_cte) } {
         set pretraitement(page_web) "1040multiplier_cte"
      } elseif { $pretraitement(operation) == $caption(audace,menu,clip) } {
         set pretraitement(page_web) "1044ecreter"
      } elseif { $pretraitement(operation) == $caption(audace,menu,subsky) } {
         set pretraitement(page_web) "1046soust_fond_ciel"
      } elseif { $pretraitement(operation) == $caption(audace,menu,noffset) } {
         set pretraitement(page_web) "1050norm_fond"
      } elseif { $pretraitement(operation) == $caption(audace,menu,ngain) } {
         set pretraitement(page_web) "1060norm_eclai"
      } elseif { $pretraitement(operation) == $caption(audace,menu,addition) } {
         set pretraitement(page_web) "1070addition"
      } elseif { $pretraitement(operation) == $caption(audace,menu,soust) } {
         set pretraitement(page_web) "1080soustraction"
      } elseif { $pretraitement(operation) == $caption(audace,menu,division) } {
         set pretraitement(page_web) "1090division"
      } elseif { $pretraitement(operation) == $caption(audace,menu,opt_noir) } {
         set pretraitement(page_web) "1095opt_noir"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$pretraitement(page_web).htm"
   }

   #
   # ::pretraitement::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This
      global caption pretraitement

      #---
      if { $pretraitement(choix_mode) == "0" } {
         set pretraitement(afficher_image) "$caption(pretraitement,afficher_image_fin)"
      } elseif { $pretraitement(choix_mode) == "1" } {
         set pretraitement(afficher_image) "$caption(pretraitement,afficher_image_fin)"
      } elseif { $pretraitement(choix_mode) == "2" } {
         set pretraitement(afficher_image) "$caption(pretraitement,afficher_der_image_fin)"
      }
      $This.usr.7.1.che1 configure -text "$pretraitement(afficher_image)"
      #---
      set pretraitement(avancement)     ""
      set pretraitement(in)             ""
      set pretraitement(nb)             ""
      set pretraitement(valeur_indice)  "1"
      set pretraitement(out)            ""
      #---
      ::pretraitement::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $pretraitement(operation) \
         "$caption(audace,menu,scale)" {
            set pretraitement(const) ""
            if { $pretraitement(choix_mode) == "0" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack $This.usr.6 -in $This.usr -side top -fill both
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack $This.usr.6 -in $This.usr -side top -fill both
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack $This.usr.6 -in $This.usr -side top -fill both
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,offset)" {
            set pretraitement(const) "0"
            if { $pretraitement(choix_mode) == "0" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,mult_cte)" {
            set pretraitement(const) "1"
            if { $pretraitement(choix_mode) == "0" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,clip)" {
            set pretraitement(const) ""
            if { $pretraitement(choix_mode) == "0" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack $This.usr.12 -in $This.usr -side top -fill both
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack $This.usr.12 -in $This.usr -side top -fill both
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack $This.usr.12 -in $This.usr -side top -fill both
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,subsky)" {
            set pretraitement(const) ""
            if { $pretraitement(choix_mode) == "0" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack $This.usr.11 -in $This.usr -side top -fill both
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack $This.usr.11 -in $This.usr -side top -fill both
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack $This.usr.11 -in $This.usr -side top -fill both
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,noffset)" {
            set pretraitement(const) ""
            if { $pretraitement(choix_mode) == "0" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,ngain)" {
            set pretraitement(const) ""
            if { $pretraitement(choix_mode) == "0" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack $This.usr.3 -in $This.usr -side top -fill both
               pack forget $This.usr.4
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,addition)" {
            set pretraitement(const) "0"
            if { $pretraitement(choix_mode) == "0" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,soust)" {
            set pretraitement(const) "0"
            if { $pretraitement(choix_mode) == "0" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,division)" {
            set pretraitement(const) "1"
            if { $pretraitement(choix_mode) == "0" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack $This.usr.0 -in $This.usr -side top -fill both
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack $This.usr.4 -in $This.usr -side top -fill both
               pack forget $This.usr.5
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         } \
         "$caption(audace,menu,opt_noir)" {
            set pretraitement(const) ""
            if { $pretraitement(choix_mode) == "0" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack forget $This.usr.8
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack $This.usr.5 -in $This.usr -side top -fill both
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack forget $This.usr.7
               pack $This.usr.10 -in $This.usr -side top -fill both
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "1" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.2
               pack $This.usr.8 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack $This.usr.5 -in $This.usr -side top -fill both
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            } elseif { $pretraitement(choix_mode) == "2" } {
               pack forget $This.usr.0
               pack $This.usr.1 -in $This.usr -side top -fill both
               pack forget $This.usr.8
               pack $This.usr.2 -in $This.usr -side top -fill both
               pack forget $This.usr.3
               pack forget $This.usr.4
               pack $This.usr.5 -in $This.usr -side top -fill both
               pack forget $This.usr.6
               pack forget $This.usr.11
               pack forget $This.usr.12
               pack $This.usr.7 -in $This.usr -side top -fill both
               pack forget $This.usr.10
               pack $This.usr.9 -in $This.usr -side top -fill both
            }
         }
   }

   #
   # ::pretraitement::parcourir In_Out
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      global audace pretraitement

      #--- Fenetre parent
      set fenetre "$audace(base).pretraitement"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         if { $pretraitement(choix_mode) == "2" } {
            set pretraitement(info_filename_in)  [ ::pretraitement::nom_generique [ file rootname [ file tail $filename ] ] ]
            set pretraitement(in)                [ lindex $pretraitement(info_filename_in) 0 ]
            set pretraitement(nb)                [ lindex $pretraitement(info_filename_in) 1 ]
            set pretraitement(valeur_indice)     [ lindex $pretraitement(info_filename_in) 2 ]
         } else {
            set pretraitement(in)                [ file rootname [ file tail $filename ] ]
         }
      } elseif { $In_Out == "2" } {
         if { $pretraitement(choix_mode) == "2" } {
            set pretraitement(info_filename_out) [ ::pretraitement::nom_generique [ file rootname [ file tail $filename ] ] ]
            set pretraitement(out)               [ lindex $pretraitement(info_filename_out) 0 ]
         } else {
            set pretraitement(out)               [ file rootname [ file tail $filename ] ]
         }
      } elseif { $In_Out == "3" } {
         set pretraitement(2,operand) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "4" } {
         set pretraitement(3,dark) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "5" } {
         set pretraitement(3,offset) [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::pretraitement::val_defaut
   # Affiche les valeurs par defaut des constantes
   #
   proc val_defaut { } {
      global caption pretraitement

      #--- Re-initialise les coefficients conf()
      if { $pretraitement(operation) == "$caption(audace,menu,scale)" } {
         set pretraitement(scaleWindow_multx) "2.0"
         set pretraitement(scaleWindow_multy) "2.0"
      } elseif { $pretraitement(operation) == "$caption(audace,menu,clip)" } {
         set pretraitement(clipWindow_mini) "0"
         set pretraitement(clipWindow_maxi) "32767"
      } elseif { $pretraitement(operation) == "$caption(audace,menu,subsky)" } {
         set pretraitement(subskyWindow_back_kernel) "15"
         set pretraitement(subskyWindow_back_threshold) "0.2"
      }
   }

   #
   # ::pretraitement::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption pretraitement

      if { $pretraitement(operation) == "$caption(audace,menu,offset)" } {
         if { $pretraitement(choix_mode) == "0" } {
            set pretraitement(image_A)        ""
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        ""
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(formule)        "$caption(pretraitement,formule) A + Cte"
         } elseif { $pretraitement(choix_mode) == "1" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_entree-) ( A ) :"
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(formule)        "$caption(pretraitement,formule) B = A + Cte"
         } elseif { $pretraitement(choix_mode) == "2" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
            set pretraitement(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
            set pretraitement(premier_indice) "$caption(pretraitement,image_premier_indice)"
            set pretraitement(image_B)        "$caption(pretraitement,image_generique_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(formule)        "$caption(pretraitement,formule) Bn = An + Cte"
         }
      } elseif { $pretraitement(operation) == "$caption(audace,menu,mult_cte)" } {
         if { $pretraitement(choix_mode) == "0" } {
            set pretraitement(image_A)        ""
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        ""
            set pretraitement(constante)      "$caption(pretraitement,cte_mult)"
            set pretraitement(formule)        "$caption(pretraitement,formule) A x Cte"
         } elseif { $pretraitement(choix_mode) == "1" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_entree-) ( A ) :"
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,cte_mult)"
            set pretraitement(formule)        "$caption(pretraitement,formule) B = A x Cte"
         } elseif { $pretraitement(choix_mode) == "2" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
            set pretraitement(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
            set pretraitement(premier_indice) "$caption(pretraitement,image_premier_indice)"
            set pretraitement(image_B)        "$caption(pretraitement,image_generique_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,cte_mult)"
            set pretraitement(formule)        "$caption(pretraitement,formule) Bn = An x Cte"
         }
      } elseif { $pretraitement(operation) == "$caption(audace,menu,addition)" } {
         if { $pretraitement(choix_mode) == "0" } {
            set pretraitement(image_A)        ""
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        ""
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(operande)       "$caption(pretraitement,image_ajouter-) ( B ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) A + B + Cte"
         } elseif { $pretraitement(choix_mode) == "1" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_entree-) ( A ) :"
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(operande)       "$caption(pretraitement,image_ajouter-) ( C ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) B = A + C + Cte"
         } elseif { $pretraitement(choix_mode) == "2" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
            set pretraitement(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
            set pretraitement(premier_indice) "$caption(pretraitement,image_premier_indice)"
            set pretraitement(image_B)        "$caption(pretraitement,image_generique_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(operande)       "$caption(pretraitement,image_ajouter-) ( C ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) Bn = An + C + Cte"
         }
      } elseif { $pretraitement(operation) == "$caption(audace,menu,soust)" } {
         if { $pretraitement(choix_mode) == "0" } {
            set pretraitement(image_A)        ""
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        ""
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(operande)       "$caption(pretraitement,image_soustraire-) ( B ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) A - B + Cte"
         } elseif { $pretraitement(choix_mode) == "1" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_entree-) ( A ) :"
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(operande)       "$caption(pretraitement,image_soustraire-) ( C ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) B = A - C + Cte"
         } elseif { $pretraitement(choix_mode) == "2" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
            set pretraitement(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
            set pretraitement(premier_indice) "$caption(pretraitement,image_premier_indice)"
            set pretraitement(image_B)        "$caption(pretraitement,image_generique_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,ajouter_cte)"
            set pretraitement(operande)       "$caption(pretraitement,image_soustraire-) ( C ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) Bn = An - C + Cte"
         }
      } elseif { $pretraitement(operation) == "$caption(audace,menu,division)" } {
         if { $pretraitement(choix_mode) == "0" } {
            set pretraitement(image_A)        ""
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        ""
            set pretraitement(constante)      "$caption(pretraitement,cte_mult)"
            set pretraitement(operande)       "$caption(pretraitement,nom_diviser-) ( B ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) ( A / B ) x Cte"
         } elseif { $pretraitement(choix_mode) == "1" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_entree-) ( A ) :"
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,cte_mult)"
            set pretraitement(operande)       "$caption(pretraitement,nom_diviser-) ( C ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) B = ( A / C ) x Cte"
         } elseif { $pretraitement(choix_mode) == "2" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
            set pretraitement(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
            set pretraitement(premier_indice) "$caption(pretraitement,image_premier_indice)"
            set pretraitement(image_B)        "$caption(pretraitement,image_generique_sortie-) ( B ) :"
            set pretraitement(constante)      "$caption(pretraitement,cte_mult)"
            set pretraitement(operande)       "$caption(pretraitement,nom_diviser-) ( C ) :"
            set pretraitement(formule)        "$caption(pretraitement,formule) Bn = ( An / C ) x Cte"
         }
      } else {
         if { $pretraitement(choix_mode) == "0" } {
            set pretraitement(image_A)        ""
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        ""
            set pretraitement(constante)      "$caption(pretraitement,valeur_fond_ciel)"
            set pretraitement(operande)       "$caption(pretraitement,image_operande)"
            set pretraitement(formule)        ""
         } elseif { $pretraitement(choix_mode) == "1" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_entree)"
            set pretraitement(nombre)         ""
            set pretraitement(premier_indice) ""
            set pretraitement(image_B)        "$caption(pretraitement,image_sortie)"
            set pretraitement(constante)      "$caption(pretraitement,valeur_fond_ciel)"
            set pretraitement(operande)       "$caption(pretraitement,image_operande)"
            set pretraitement(formule)        ""
         } elseif { $pretraitement(choix_mode) == "2" } {
            set pretraitement(image_A)        "$caption(pretraitement,image_generique_entree)"
            set pretraitement(nombre)         "$caption(pretraitement,image_nombre)"
            set pretraitement(premier_indice) "$caption(pretraitement,image_premier_indice)"
            set pretraitement(image_B)        "$caption(pretraitement,image_generique_sortie)"
            set pretraitement(constante)      "$caption(pretraitement,valeur_fond_ciel)"
            set pretraitement(operande)       "$caption(pretraitement,image_operande)"
            set pretraitement(formule)        ""
         }
      }
   }

   #
   # ::pretraitement::nom_generique
   # Affiche le nom generique des fichiers d'une serie si c'en est une, le nombre
   # d'elements de la serie et le premier indice de la serie s'il est different de 1
   # Renumerote la serie s'il y a des trous ou si elle debute par un 0
   #
   proc nom_generique { filename } {
      global audace caption

      #--- Est-ce un nom générique de fichiers ?
      set nom_generique  [ lindex [ decomp $filename ] 1 ]
      set index_serie    [ lindex [ decomp $filename ] 2 ]
      set ext_serie      [ lindex [ decomp $filename ] 3 ]
      #--- J'extrais la liste des index de la serie
      set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
      if { $error == "0" } {
         #--- Pour une serie du type 1 - 2 - 3 - etc.
         set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
      } else {
         #--- Pour une serie du type 01 - 02 - 03 - etc.
         set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
      }
      #--- Longueur de la liste des index
      set longueur_serie [ llength $liste_serie ]
      if { $index_serie != "" && $longueur_serie > "1" } {
         tk_messageBox -title $caption(pretraitement,attention) -type ok \
            -message "$caption(pretraitement,nom_generique_ok)"
      } else {
         tk_messageBox -title $caption(pretraitement,attention) -type ok \
            -message "$caption(pretraitement,nom_generique_ko)"
         #--- Ce n'est pas un nom generique, sortie anticipee
         set nom_generique  ""
         set longueur_serie ""
         set indice_min     "1"
         ::console::disp "$caption(pretraitement,nom_generique) $nom_generique \n"
         ::console::disp "$caption(pretraitement,image_nombre) $longueur_serie \n"
         ::console::disp "$caption(pretraitement,image_premier_indice) $indice_min \n\n"
         return [ list $nom_generique $longueur_serie $indice_min ]
      }
      #--- Identification du type de numerotation
      set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
      if { $error == "0" } {
         #--- Pour une serie du type 1 - 2 - 3 - etc.
         set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
      } else {
         #--- Pour une serie du type 01 - 02 - 03 - etc.
         set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
      }
      #--- Longueur de la serie
      set longueur_serie [ llength $liste_serie ]
      #--- Premier indice de la serie
      set indice_min [ lindex $liste_serie 0 ]
      #--- La serie ne commence pas par 0
      if { $indice_min != "0" } {
         set new_indice_min [ string trimleft $indice_min 0 ]
         #--- La serie commence par 1
         if { $new_indice_min == "1" } {
            #--- Est-ce une serie avec des fichiers manquants ?
            set etat_serie [ numerotation_usuelle $nom_generique ]
            if { $etat_serie == "0" } {
               #--- Il manque des fichiers dans la serie, je renumerote la serie
               renumerote $nom_generique -rep "$audace(rep_images)" -ext "$ext_serie"
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message "$caption(pretraitement,renumerote_termine)"
            } else {
               #--- Il ne manque pas de fichiers dans la serie
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message "$caption(pretraitement,numerotation_ok)\n$caption(pretraitement,pas_fichier_manquant)"
            }
         } else {
            #--- La serie ne commence pas par 1
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message "$caption(pretraitement,renumerote_manuel)"
         }
      } else {
         #--- La serie commence par 0
         tk_messageBox -title $caption(pretraitement,attention) -type ok \
            -message "$caption(pretraitement,indice_pas_1)"
         #--- Je recherche le dernier indice de la liste
         set dernier_indice [ expr [ lindex $liste_serie [ expr $longueur_serie - 1 ] ] + 1 ]
         #--- Je renumerote le fichier portant l'indice 0
         set buf_pretrait [ ::buf::create ]
         buf$buf_pretrait load "$audace(rep_images)/$nom_generique$indice_min$ext_serie"
         buf$buf_pretrait save "$audace(rep_images)/$nom_generique$dernier_indice$ext_serie"
         ::buf::delete $buf_pretrait
         file delete [ file join $audace(rep_images) $nom_generique$indice_min$ext_serie ]
         #--- Est-ce une serie avec des fichiers manquants ?
         set etat_serie [ numerotation_usuelle $nom_generique ]
         if { $etat_serie == "0" } {
            #--- Il manque des fichiers dans la serie, je renumerote la serie
            renumerote $nom_generique -rep "$audace(rep_images)" -ext "$ext_serie"
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message "$caption(pretraitement,renumerote_termine)\n$caption(pretraitement,fichier_indice_0)"
         } else {
            #--- Il ne manque pas de fichiers dans la serie
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message "$caption(pretraitement,pas_fichier_manquant)\n$caption(pretraitement,fichier_indice_0)"
         }
      }
      #--- J'extrais la liste des index de la serie
      set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
      if { $error == "0" } {
         #--- Pour une serie du type 1 - 2 - 3 - etc.
         set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
      } else {
         #--- Pour une serie du type 01 - 02 - 03 - etc.
         set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
      }
      #--- J'extrais le dernier indice de la serie
      set longueur_serie [ llength $liste_serie ]
      set indice_max [ lindex $liste_serie [ expr $longueur_serie - 1 ] ]
      ::console::disp "$caption(pretraitement,liste_serie) $liste_serie \n\n"
      ::console::disp "$caption(pretraitement,nom_generique) $nom_generique \n"
      ::console::disp "$caption(pretraitement,image_nombre) $longueur_serie \n"
      ::console::disp "$caption(pretraitement,image_premier_indice) $indice_min \n\n"
      return [ list $nom_generique $longueur_serie $indice_min ]
   }

}

########################## Fin du namespace pretraitement ##########################

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
      global audace caption color conf traiteImage

      #--- Initialisation de la variable principale
      set traiteImage(avancement) ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,pretraite)"
      wm geometry $This $widget(traiteImage,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteImage::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.0 -borderwidth 1 -relief raised
            label $This.usr.0.lab1 -textvariable "traiteImage(formule)" -font $audace(font,arial_15_b)
            pack $This.usr.0.lab1 -padx 10 -pady 5
        # pack $This.usr.0 -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               label $This.usr.3.1.labURL1 -textvariable "traiteImage(avancement)" -font $audace(font,arial_12_b) \
                  -fg $color(blue)
               pack $This.usr.3.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -in $This.usr -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.20 -borderwidth 0 -relief flat
               button $This.usr.2.20.btn1 -text "$caption(pretraitement,parcourir)" -command { ::traiteImage::parcourir 1 }
               pack $This.usr.2.20.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.20.lab5 -text "$caption(pretraitement,image_gene_entree_r+v+b)"
               pack $This.usr.2.20.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.20.ent5 -textvariable traiteImage(rvbWindow_r+v+b_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.20.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.20 -side top -fill both
            frame $This.usr.2.21 -borderwidth 0 -relief flat
               button $This.usr.2.21.btn1 -text "$caption(pretraitement,parcourir)" -command { ::traiteImage::parcourir 2 }
               pack $This.usr.2.21.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.21.lab5 -text "$caption(pretraitement,image_sortie_rvb)"
               pack $This.usr.2.21.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.21.ent5 -textvariable traiteImage(rvbWindow_rvb_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.21.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.21 -side top -fill both
            frame $This.usr.2.22 -borderwidth 0 -relief flat
               button $This.usr.2.22.btn1 -text "$caption(pretraitement,parcourir)" -command { ::traiteImage::parcourir 1 }
               pack $This.usr.2.22.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.22.lab5 -text "$caption(pretraitement,image_entree_rvb)"
               pack $This.usr.2.22.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.22.ent5 -textvariable traiteImage(rvbWindow_rvb_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.22.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.22 -side top -fill both
            frame $This.usr.2.23 -borderwidth 0 -relief flat
               button $This.usr.2.23.btn1 -text "$caption(pretraitement,parcourir)" -command { ::traiteImage::parcourir 2 }
               pack $This.usr.2.23.btn1 -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.23.lab5 -text "$caption(pretraitement,image_gene_sortie_r+v+b)"
               pack $This.usr.2.23.lab5 -side left -padx 5 -pady 5
               entry $This.usr.2.23.ent5 -textvariable traiteImage(rvbWindow_r+v+b_filename) -width 20 \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.23.ent5 -side right -padx 10 -pady 5
           # pack $This.usr.2.23 -side top -fill both
        # pack $This.usr.2 -side bottom -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -textvariable "traiteImage(image_A)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteImage [ list $caption(audace,menu,r+v+b2rvb) $caption(audace,menu,rvb2r+v+b) \
               $caption(audace,menu,cfa2rgb) ]
            #---
            menubutton $This.usr.1.but1 -textvariable traiteImage(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_traiteImage {
               $m add radiobutton -label "$pretrait" \
                  -indicatoron "1" \
                  -value "$pretrait" \
                  -variable traiteImage(operation) \
                  -command { }
            }
        # pack $This.usr.1 -side top -fill both
      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command { ::traiteImage::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command { ::traiteImage::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command { ::traiteImage::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
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

      #---
      set traiteImage(avancement) "$caption(pretraitement,en_cours)"
      update

      #--- Il faut une image affichee
      if { ( $traiteImage(operation) != "$caption(audace,menu,r+v+b2rvb)" ) && ( $traiteImage(operation) != "$caption(audace,menu,rvb2r+v+b)" ) } {
         if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] != "1" } {
            tk_messageBox -title $caption(pretraitement,attention) -type ok \
               -message $caption(pretraitement,header_noimage)
            set traiteImage(avancement) ""
            return
         }
      }

      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteImage(operation) \
         "$caption(audace,menu,r+v+b2rvb)" {
            #--- Test sur le nom generique des images R, V et B
            if { $traiteImage(rvbWindow_r+v+b_filename) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_entree_generique)
               set traiteImage(avancement) ""
               return
            }
            #--- Test sur l'image RVB
            if { $traiteImage(rvbWindow_rvb_filename) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_image_sortie)
               set traiteImage(avancement) ""
               return
            }
            #---
            catch {
               fitsconvert3d $audace(rep_images)/$traiteImage(rvbWindow_r+v+b_filename) 3 .fit $audace(rep_images)/$traiteImage(rvbWindow_rvb_filename)
               loadima $traiteImage(rvbWindow_rvb_filename)
            } m
            if { $m == "" } {
               set traiteImage(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteImage(avancement) ""
            }
         } \
         "$caption(audace,menu,rvb2r+v+b)" {
            #--- Test sur l'image RVB
            if { $traiteImage(rvbWindow_rvb_filename) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_image_entree)
               set traiteImage(avancement) ""
               return
            }
            #--- Test sur le nom generique des images R, V et B
            if { $traiteImage(rvbWindow_r+v+b_filename) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_sortie_generique)
               set traiteImage(avancement) ""
               return
            }
            #---
            catch {
               buf$audace(bufNo) load3d "$audace(rep_images)/$traiteImage(rvbWindow_rvb_filename).fit" 1
               buf$audace(bufNo) save "$audace(rep_images)/$traiteImage(rvbWindow_r+v+b_filename)1.fit"
               buf$audace(bufNo) load3d "$audace(rep_images)/$traiteImage(rvbWindow_rvb_filename).fit" 2
               buf$audace(bufNo) save "$audace(rep_images)/$traiteImage(rvbWindow_r+v+b_filename)2.fit"
               buf$audace(bufNo) load3d "$audace(rep_images)/$traiteImage(rvbWindow_rvb_filename).fit" 3
               buf$audace(bufNo) save "$audace(rep_images)/$traiteImage(rvbWindow_r+v+b_filename)3.fit"
            } m
            if { $m == "" } {
               set traiteImage(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteImage(avancement) ""
            }
         } \
         "$caption(audace,menu,cfa2rgb)" {
            catch {
               buf$audace(bufNo) cfa2rgb 1
               ::audace::autovisu $audace(visuNo)
            } m
            if { $m == "" } {
               set traiteImage(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteImage(avancement) ""
            }
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
      if { $traiteImage(operation) == $caption(audace,menu,r+v+b2rvb) } {
         set traiteImage(page_web) "1014r+v+b2rvb"
      } elseif { $traiteImage(operation) == $caption(audace,menu,rvb2r+v+b) } {
         set traiteImage(page_web) "1016rvb2r+v+b"
      } elseif { $traiteImage(operation) == $caption(audace,menu,cfa2rgb) } {
         set traiteImage(page_web) "1117cfa2rvb"
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
      set traiteImage(avancement) ""
      #---
      ::traiteImage::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteImage(operation) \
         "$caption(audace,menu,r+v+b2rvb)" {
            pack forget $This.usr.0
            pack $This.usr.3 -side bottom -fill both
            pack $This.usr.2 -side bottom -fill both
            pack $This.usr.2.20 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.21 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.2.22
            pack forget $This.usr.2.23
            pack $This.usr.1 -side top -fill both
         } \
         "$caption(audace,menu,rvb2r+v+b)" {
            pack forget $This.usr.0
            pack $This.usr.3 -side bottom -fill both
            pack $This.usr.2 -side bottom -fill both
            pack forget $This.usr.2.20
            pack forget $This.usr.2.21
            pack $This.usr.2.22 -in $This.usr.2 -side top -fill both
            pack $This.usr.2.23 -in $This.usr.2 -side top -fill both
            pack $This.usr.1 -side top -fill both
         } \
         "$caption(audace,menu,cfa2rgb)" {
            pack forget $This.usr.0
            pack $This.usr.3 -side bottom -fill both
            pack forget $This.usr.2
            pack forget $This.usr.2.20
            pack forget $This.usr.2.21
            pack forget $This.usr.2.22
            pack forget $This.usr.2.23
            pack $This.usr.1 -side top -fill both
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
      if { $traiteImage(operation) == "$caption(audace,menu,r+v+b2rvb)" && $option == "1" } {
         set traiteImage(rvbWindow_r+v+b_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,menu,r+v+b2rvb)" && $option == "2" } {
         set traiteImage(rvbWindow_rvb_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,menu,rvb2r+v+b)" && $option == "1" } {
         set traiteImage(rvbWindow_rvb_filename) [ file rootname [ file tail $filename ] ]
      } elseif { $traiteImage(operation) == "$caption(audace,menu,rvb2r+v+b)" && $option == "2" } {
         set traiteImage(rvbWindow_r+v+b_filename) [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::traiteImage::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption traiteImage

      set traiteImage(formule) ""
      if { $traiteImage(operation) == "$caption(audace,menu,r+v+b2rvb)" } {
         set traiteImage(image_A) ""
      } elseif { $traiteImage(operation) == "$caption(audace,menu,rvb2r+v+b)" } {
         set traiteImage(image_A) ""
      } else {
         set traiteImage(image_A) "$caption(pretraitement,image_affichee:)"
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
      global audace caption color conf traiteWindow

      #--- Initialisation des variables principales
      set traiteWindow(in)            ""
      set traiteWindow(nb)            ""
      set traiteWindow(valeur_indice) "1"
      set traiteWindow(out)           ""
      set traiteWindow(disp)          "1"
      set traiteWindow(avancement)    ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,pretraite)"
      wm geometry $This $widget(traiteWindow,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteWindow::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised

         frame $This.usr.0 -borderwidth 1 -relief raised
            label $This.usr.0.lab1 -textvariable "traiteWindow(formule)" -font $audace(font,arial_15_b)
            pack $This.usr.0.lab1 -padx 10 -pady 5
        # pack $This.usr.0 -in $This.usr -side top -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               label $This.usr.4.1.labURL1 -textvariable "traiteWindow(avancement)" -font $audace(font,arial_12_b) \
                  -fg $color(blue)
               pack $This.usr.4.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both
        # pack $This.usr.4 -in $This.usr -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.3.1.che1 -text "$caption(pretraitement,afficher_image_fin)" \
                  -variable traiteWindow(disp)
               pack $This.usr.3.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -in $This.usr -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               button $This.usr.2.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 1 }
               pack $This.usr.2.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.1.lab1 -textvariable "traiteWindow(image_A)"
               pack $This.usr.2.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.2.1.ent1 -textvariable traiteWindow(in) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.1.ent1 -side right -padx 10 -pady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               entry $This.usr.2.2.ent2 -textvariable traiteWindow(nb) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.2.ent2 -side right -padx 10 -pady 5
               label $This.usr.2.2.lab2 -textvariable "traiteWindow(nombre)"
               pack $This.usr.2.2.lab2 -side right -padx 5 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               entry $This.usr.2.3.ent3 -textvariable traiteWindow(valeur_indice) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent3 -side right -padx 10 -pady 5
               label $This.usr.2.3.lab3 -textvariable "traiteWindow(premier_indice)"
               pack $This.usr.2.3.lab3 -side right -padx 5 -pady 5
            pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               button $This.usr.2.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 2 }
               pack $This.usr.2.4.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.4.lab4 -textvariable "traiteWindow(image_B)"
               pack $This.usr.2.4.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.4.ent4 -textvariable traiteWindow(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.4.ent4 -side right -padx 10 -pady 5
            pack $This.usr.2.4 -side top -fill both
        # pack $This.usr.2 -in $This.usr -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -text "$caption(pretraitement,operation_serie)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteWindow [ list $caption(audace,menu,mediane) $caption(audace,menu,somme) \
               $caption(audace,menu,moyenne) $caption(audace,menu,ecart_type) ]
            #---
            menubutton $This.usr.1.but1 -textvariable traiteWindow(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_traiteWindow {
               $m add radiobutton -label "$pretrait" \
                -indicatoron "1" \
                -value "$pretrait" \
                -variable traiteWindow(operation) \
                -command { }
            }
        # pack $This.usr.1 -in $This.usr -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      #---
      frame $This.cmd -borderwidth 1 -relief raised

         button $This.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command { ::traiteWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $This.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command { ::traiteWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command { ::traiteWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
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
      set traiteWindow(avancement) "$caption(pretraitement,en_cours)"
      update
      #---

      set in    $traiteWindow(in)
      set nb    $traiteWindow(nb)
      set first $traiteWindow(valeur_indice)
      set out   $traiteWindow(out)

      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $traiteWindow(in) == "" } {
          tk_messageBox -title $caption(pretraitement,attention) -type ok \
             -message $caption(pretraitement,definir_entree_generique)
          set traiteWindow(avancement) ""
          return
      }
      if { $traiteWindow(nb) == "" } {
          tk_messageBox -title $caption(pretraitement,attention) -type ok \
             -message $caption(pretraitement,choix_nbre_images)
          set traiteWindow(avancement) ""
          return
      }
      if { [ TestEntier $traiteWindow(nb) ] == "0" } {
         tk_messageBox -title $caption(pretraitement,attention) -icon error \
            -message $caption(pretraitement,nbre_entier)
          set traiteWindow(avancement) ""
         return
      }
      if { $traiteWindow(out) == "" } {
          tk_messageBox -title $caption(pretraitement,attention) -type ok \
             -message $caption(pretraitement,definir_image_sortie)
          set traiteWindow(avancement) ""
          return
      }

      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteWindow(operation) \
         "$caption(audace,menu,mediane)" {
            ::console::affiche_resultat "Usage: smedian in out number ?first_index? ?tt_options?\n\n"
            catch { smedian $in $out $nb $first } m
            if { $m == "" } {
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteWindow(avancement) ""
            }
         } \
         "$caption(audace,menu,somme)" {
            ::console::affiche_resultat "Usage: sadd in out number ?first_index? ?tt_options?\n\n"
            catch { sadd $in $out $nb $first } m
            if { $m == "" } {
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteWindow(avancement) ""
            }
         } \
         "$caption(audace,menu,moyenne)" {
            ::console::affiche_resultat "Usage: smean in out number ?first_index? ?tt_options?\n\n"
            catch { smean $in $out $nb $first } m
            if { $m == "" } {
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteWindow(avancement) ""
            }
         } \
         "$caption(audace,menu,ecart_type)" {
            ::console::affiche_resultat "Usage: ssigma in out number ?first_index? bitpix=-32\n\n"
            catch { ssigma $in $out $nb $first "bitpix=-32" } m
            if { $m == "" } {
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set traiteWindow(avancement) ""
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
      if { $traiteWindow(operation) == $caption(audace,menu,mediane) } {
         set traiteWindow(page_web) "1120serie_mediane"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,somme) } {
         set traiteWindow(page_web) "1130serie_somme"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,moyenne) } {
         set traiteWindow(page_web) "1140serie_moyenne"
      } elseif { $traiteWindow(operation) == $caption(audace,menu,ecart_type) } {
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
      set traiteWindow(avancement)    ""
      set traiteWindow(in)            ""
      set traiteWindow(nb)            ""
      set traiteWindow(valeur_indice) "1"
      set traiteWindow(out)           ""
      #---
      ::traiteWindow::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $traiteWindow(operation) \
         "$caption(audace,menu,mediane)" {
            pack forget $This.usr.0
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
         } \
         "$caption(audace,menu,somme)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
         } \
         "$caption(audace,menu,moyenne)" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
         } \
         "$caption(audace,menu,ecart_type)" {
            pack forget $This.usr.0
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
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
         set traiteWindow(info_filename_in) [ ::pretraitement::nom_generique [ file rootname [ file tail $filename ] ] ]
         set traiteWindow(in)               [ lindex $traiteWindow(info_filename_in) 0 ]
         set traiteWindow(nb)               [ lindex $traiteWindow(info_filename_in) 1 ]
         set traiteWindow(valeur_indice)    [ lindex $traiteWindow(info_filename_in) 2 ]
      } elseif { $In_Out == "2" } {
         set traiteWindow(out)              [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::traiteWindow::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption traiteWindow

      if { $traiteWindow(operation) == "$caption(audace,menu,somme)" } {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
         set traiteWindow(formule)        "$caption(pretraitement,formule) B = A1 + A2 + ... + An"
      } elseif { $traiteWindow(operation) == "$caption(audace,menu,moyenne)" } {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
         set traiteWindow(formule)        "$caption(pretraitement,formule) B = ( A1 + A2 + ... + An ) / n"
      } else {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree)"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre)"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_sortie)"
         set traiteWindow(formule)        ""
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
      global audace caption color conf faireImageRef

      #--- Initialisation des variables principales
      set faireImageRef(in)                          ""
      set faireImageRef(nb)                          ""
      set faireImageRef(valeur_indice)               "1"
      set faireImageRef(out)                         ""
      set faireImageRef(offset)                      ""
      set faireImageRef(dark)                        ""
      set faireImageRef(opt)                         "0"
      set faireImageRef(flat-field)                  ""
      set faireImageRef(methode)                     "2"
      set faireImageRef(norm)                        ""
      set faireImageRef(disp)                        "1"
      set faireImageRef(afficher_image)              "$caption(pretraitement,afficher_image_fin)"
      set faireImageRef(avancement)                  ""
      set faireImageRef(dark,no-offset)              "0"
      set faireImageRef(flat-field,no-offset)        "0"
      set faireImageRef(flat-field,no-dark)          "0"
      set faireImageRef(pretraitement,no-flat-field) "0"

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,pretraite)"
      wm geometry $This $widget(faireImageRef,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::faireImageRef::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised

         frame $This.usr.8 -borderwidth 1 -relief raised
            frame $This.usr.8.1 -borderwidth 0 -relief flat
               label $This.usr.8.1.labURL1 -textvariable "faireImageRef(avancement)" -font $audace(font,arial_12_b) \
                  -fg $color(blue)
               pack $This.usr.8.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.8.1 -side top -fill both
        # pack $This.usr.8 -side bottom -fill both

         frame $This.usr.7 -borderwidth 1 -relief raised
            frame $This.usr.7.1 -borderwidth 0 -relief flat
               button $This.usr.7.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.7.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.7.1.lab6 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.7.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.1.ent6 -textvariable faireImageRef(offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.7.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.7.1 -side top -fill both
            frame $This.usr.7.2 -borderwidth 0 -relief flat
               button $This.usr.7.2.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 4 }
               pack $This.usr.7.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.7.2.lab6 -text "$caption(pretraitement,image_dark)"
               pack $This.usr.7.2.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.2.ent6 -textvariable faireImageRef(dark) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.7.2.ent6 -side right -padx 10 -pady 5
            pack $This.usr.7.2 -side top -fill both
            frame $This.usr.7.3 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.3.opt -text "$caption(audace,menu,opt_noir)" -variable faireImageRef(opt)
               pack $This.usr.7.3.opt -side right -padx 60 -pady 5
            pack $This.usr.7.3 -side top -fill both
            frame $This.usr.7.4 -borderwidth 0 -relief flat
               button $This.usr.7.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 5 }
               pack $This.usr.7.4.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.7.4.lab6 -text "$caption(pretraitement,image_flat-field)"
               pack $This.usr.7.4.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.4.ent6 -textvariable faireImageRef(flat-field) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.7.4.ent6 -side right -padx 10 -pady 5
            pack $This.usr.7.4 -side top -fill both
            frame $This.usr.7.5 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.5.sans_flat -text "$caption(pretraitement,sans_image_flat-field)" \
                  -variable faireImageRef(pretraitement,no-flat-field) -command { ::faireImageRef::griser_activer_1 }
               pack $This.usr.7.5.sans_flat -side left -padx 10 -pady 5
            pack $This.usr.7.5 -side top -fill both
        # pack $This.usr.7 -side top -fill both

         frame $This.usr.6 -borderwidth 1 -relief raised
            frame $This.usr.6.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.6.1.che1 -text "$faireImageRef(afficher_image)" \
                  -variable faireImageRef(disp)
               pack $This.usr.6.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.6.1 -side top -fill both
        # pack $This.usr.6 -side top -fill both

         frame $This.usr.5 -borderwidth 1 -relief raised
            frame $This.usr.5.1 -borderwidth 0 -relief flat
               label $This.usr.5.1.lab9 -text "$caption(pretraitement,methode)"
               pack $This.usr.5.1.lab9 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad0 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,menu,somme)" -value 0 -variable faireImageRef(methode)
               pack $This.usr.5.1.rad0 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad1 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,menu,moyenne)" -value 1 -variable faireImageRef(methode)
               pack $This.usr.5.1.rad1 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad2 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,menu,mediane)" -value 2 -variable faireImageRef(methode)
               pack $This.usr.5.1.rad2 -side left -padx 10 -pady 5
            pack $This.usr.5.1 -side top -fill both
        # pack $This.usr.5 -side top -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.4.1.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(flat-field,no-offset) -command { ::faireImageRef::griser_activer_2 }
               pack $This.usr.4.1.che1 -side left -padx 10 -pady 5
               button $This.usr.4.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.4.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.4.1.lab6 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.4.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.1.ent6 -textvariable faireImageRef(offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.4.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both

            frame $This.usr.4.2 -borderwidth 0 -relief flat
               checkbutton $This.usr.4.2.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(flat-field,no-dark) -command { ::faireImageRef::griser_activer_3 }
               pack $This.usr.4.2.che1 -side left -padx 10 -pady 5
               button $This.usr.4.2.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 4 }
               pack $This.usr.4.2.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.4.2.lab6 -text "$caption(pretraitement,image_dark)"
               pack $This.usr.4.2.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.2.ent6 -textvariable faireImageRef(dark) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.4.2.ent6 -side right -padx 10 -pady 5
            pack $This.usr.4.2 -side top -fill both

            frame $This.usr.4.3 -borderwidth 0 -relief flat
               label $This.usr.4.3.lab7 -textvariable "faireImageRef(normalisation)"
               pack $This.usr.4.3.lab7 -side left -padx 5 -pady 5
               entry $This.usr.4.3.ent7 -textvariable faireImageRef(norm) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.4.3.ent7 -side right -padx 10 -pady 5
            pack $This.usr.4.3 -side top -fill both
        # pack $This.usr.4 -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.3.1.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(dark,no-offset) -command { ::faireImageRef::griser_activer_4 }
               pack $This.usr.3.1.che1 -side left -padx 10 -pady 5
               button $This.usr.3.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.3.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.3.1.lab6 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.3.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent6 -textvariable faireImageRef(offset) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.3.1.ent6 -side right -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               button $This.usr.2.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 1 }
               pack $This.usr.2.1.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.1.lab1 -textvariable "faireImageRef(image_generique)"
               pack $This.usr.2.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.2.1.ent1 -textvariable faireImageRef(in) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.1.ent1 -side right -padx 10 -pady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               entry $This.usr.2.2.ent2 -textvariable faireImageRef(nb) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.2.ent2 -side right -padx 10 -pady 5
               label $This.usr.2.2.lab2 -textvariable "faireImageRef(nombre)"
               pack $This.usr.2.2.lab2 -side right -padx 5 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               entry $This.usr.2.3.ent3 -textvariable faireImageRef(valeur_indice) -width 7 -justify center \
                  -font $audace(font,arial_8_b)
               pack $This.usr.2.3.ent3 -side right -padx 10 -pady 5
               label $This.usr.2.3.lab3 -textvariable "faireImageRef(premier_indice)"
               pack $This.usr.2.3.lab3 -side right -padx 5 -pady 5
            pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               button $This.usr.2.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 2 }
               pack $This.usr.2.4.explore -side left -padx 10 -pady 5 -ipady 5
               label $This.usr.2.4.lab4 -textvariable "faireImageRef(image_sortie)"
               pack $This.usr.2.4.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.4.ent4 -textvariable faireImageRef(out) -width 20 -font $audace(font,arial_8_b)
               pack $This.usr.2.4.ent4 -side right -padx 10 -pady 5
            pack $This.usr.2.4 -side top -fill both
        # pack $This.usr.2 -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            #--- Liste des pretraitements disponibles
           ### set list_faireImageRef [ list $caption(audace,menu,raw2cfa) $caption(audace,menu,faire_offset) \
           ###    $caption(audace,menu,faire_dark) $caption(audace,menu,faire_flat_field) \
           ###    $caption(audace,menu,pretraite) ]
            set list_faireImageRef [ list $caption(audace,menu,faire_offset) $caption(audace,menu,faire_dark) \
               $caption(audace,menu,faire_flat_field) $caption(audace,menu,pretraite) ]
            #---
            menubutton $This.usr.1.but1 -textvariable faireImageRef(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_faireImageRef {
               $m add radiobutton -label "$pretrait" \
                -indicatoron "1" \
                -value "$pretrait" \
                -variable faireImageRef(operation) \
                -command { }
            }
        # pack $This.usr.1 -side top -fill both -ipady 5

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command { ::faireImageRef::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command { ::faireImageRef::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command { ::faireImageRef::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
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
      set faireImageRef(avancement) "$caption(pretraitement,en_cours)"
      update

      #---
      set in    $faireImageRef(in)
      set nb    $faireImageRef(nb)
      set first $faireImageRef(valeur_indice)
      set out   $faireImageRef(out)
      set end   [ expr $nb + ( $first - 1 ) ]

      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $faireImageRef(in) == "" } {
          tk_messageBox -title $caption(pretraitement,attention) -type ok \
             -message $caption(pretraitement,definir_entree_generique)
          set faireImageRef(avancement) ""
          return
      }
      if { $faireImageRef(nb) == "" } {
          tk_messageBox -title $caption(pretraitement,attention) -type ok \
             -message $caption(pretraitement,choix_nbre_images)
          set faireImageRef(avancement) ""
          return
      }
      if { [ TestEntier $faireImageRef(nb) ] == "0" } {
         tk_messageBox -title $caption(pretraitement,attention) -icon error \
            -message $caption(pretraitement,nbre_entier)
          set faireImageRef(avancement) ""
         return
      }
      if { $faireImageRef(out) == "" } {
         if { $faireImageRef(operation) == $caption(audace,menu,raw2cfa) || $faireImageRef(operation) == $caption(audace,menu,pretraite) } {
             tk_messageBox -title $caption(pretraitement,attention) -type ok \
                -message $caption(pretraitement,definir_sortie_generique)
             set faireImageRef(avancement) ""
             return
         } else {
             tk_messageBox -title $caption(pretraitement,attention) -type ok \
                -message $caption(pretraitement,definir_image_sortie)
             set faireImageRef(avancement) ""
             return
         }
      }

      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $faireImageRef(operation) \
         "$caption(audace,menu,raw2cfa)" {
            catch { ### A developper } m
            if { $m == "" } {
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set faireImageRef(avancement) ""
            }
         } \
         "$caption(audace,menu,faire_offset)" {
            catch { smedian $in $out $nb $first } m
            if { $m == "" } {
               if { $faireImageRef(disp) == 1 } {
                  loadima $out
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set faireImageRef(avancement) ""
            }
         } \
         "$caption(audace,menu,faire_dark)" {
            #--- Test sur l'offset
            if { $faireImageRef(dark,no-offset) == "0" } {
               if { $faireImageRef(offset) == "" } {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_offset)
                  set faireImageRef(avancement) ""
                  return
               }
            }
            #---
            set offset $faireImageRef(offset)
            set const "0"
            set temp "temp"
            if { $faireImageRef(dark,no-offset) == "0" } {
               catch { sub2 $in $offset $temp $const $nb $first } m
               if { $faireImageRef(methode) == "0" } {
                  #--- Somme
                  catch { sadd $temp $out $nb $first } m
               } elseif { $faireImageRef(methode) == "1" } {
                  #--- Moyenne
                  catch { smean $temp $out $nb $first } m
               } elseif { $faireImageRef(methode) == "2" } {
                  #--- Mediane
                  catch { smedian $temp $out $nb $first } m
               }
               catch { delete2 $temp $nb } m
            } elseif { $faireImageRef(dark,no-offset) == "1" } {
               if { $faireImageRef(methode) == "0" } {
                  #--- Somme
                  catch { sadd $in $out $nb $first } m
               } elseif { $faireImageRef(methode) == "1" } {
                  #--- Moyenne
                  catch { smean $in $out $nb $first } m
               } elseif { $faireImageRef(methode) == "2" } {
                  #--- Mediane
                  catch { smedian $in $out $nb $first } m
               }
            }
            if { $m == "" } {
               if { $faireImageRef(disp) == 1 } {
                  loadima $out
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set faireImageRef(avancement) ""
            }
         } \
         "$caption(audace,menu,faire_flat_field)" {
            #--- Test sur l'offset
            if { $faireImageRef(flat-field,no-offset) == "0" } {
               if { $faireImageRef(offset) == "" } {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_offset)
                  set faireImageRef(avancement) ""
                  return
               }
            }
            #--- Test sur le dark
            if { $faireImageRef(flat-field,no-dark) == "0" } {
               if { $faireImageRef(dark) == "" } {
                  tk_messageBox -title $caption(pretraitement,attention) -type ok \
                     -message $caption(pretraitement,definir_noir)
                  set faireImageRef(avancement) ""
                  return
               }
            }
            #--- Tests sur la valeur de normalisation
            if { $faireImageRef(norm) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_cte)
               set faireImageRef(avancement) ""
               return
            }
            if { [ string is double -strict $faireImageRef(norm) ] == "0" } {
               tk_messageBox -title $caption(pretraitement,attention) -icon error \
                  -message $caption(pretraitement,cte_invalide)
               set faireImageRef(avancement) ""
               return
            }
            #---
            set offset $faireImageRef(offset)
            set dark   $faireImageRef(dark)
            set norm   $faireImageRef(norm)
            set const  "0"
            set temp   "temp"
            set tempo  "tempo"
            if { $faireImageRef(flat-field,no-offset) == "0" && $faireImageRef(flat-field,no-dark) == "0" } {
               #--- Realisation de l'image ( Offset + Dark )
               catch {
                  set buf_pretrait [ ::buf::create ]
                  buf$buf_pretrait load $audace(rep_images)/$offset
                  buf$buf_pretrait add $audace(rep_images)/$dark $const
                  buf$buf_pretrait save $audace(rep_images)/offset+dark
                  ::buf::delete $buf_pretrait
               } m
               #---
               catch { sub2 $in $offset+dark $temp $const $nb $first } m
               catch { noffset2 $temp $tempo $norm $nb $first } m
               catch { smedian $tempo $out $nb $first } m
               catch { delete2 $temp $nb } m
               catch { delete2 $tempo $nb } m
               #--- Suppression du fichier intermediaire
               catch { file delete [ file join $audace(rep_images) offset+dark$conf(extension,defaut) ] } m
            } else {
               if { $faireImageRef(flat-field,no-dark) == "1" } {
                  #---
                  catch { sub2 $in $offset $temp $const $nb $first } m
                  catch { noffset2 $temp $tempo $norm $nb $first } m
                  catch { smedian $tempo $out $nb $first } m
                  catch { delete2 $temp $nb } m
                  catch { delete2 $tempo $nb } m
               } elseif { $faireImageRef(flat-field,no-offset) == "1" } {
                  #---
                  catch { sub2 $in $dark $temp $const $nb $first } m
                  catch { noffset2 $temp $tempo $norm $nb $first } m
                  catch { smedian $tempo $out $nb $first } m
                  catch { delete2 $temp $nb } m
                  catch { delete2 $tempo $nb } m
               }
            }
            if { $m == "" } {
               if { $faireImageRef(disp) == 1 } {
                  loadima $out
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set faireImageRef(avancement) ""
            }
         } \
         "$caption(audace,menu,pretraite)" {
            #--- Test sur l'offset
            if { $faireImageRef(offset) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_offset)
               set faireImageRef(avancement) ""
               return
            }
            #--- Test sur le dark
            if { $faireImageRef(dark) == "" } {
               tk_messageBox -title $caption(pretraitement,attention) -type ok \
                  -message $caption(pretraitement,definir_noir)
               set faireImageRef(avancement) ""
               return
            }
            #--- Test sur le flat-field
            if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
               if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
                  if { $faireImageRef(flat-field) == "" } {
                     tk_messageBox -title $caption(pretraitement,attention) -type ok \
                        -message $caption(pretraitement,definir_flat-field)
                     set faireImageRef(avancement) ""
                     return
                  }
               }
            }
            #---
            set offset     $faireImageRef(offset)
            set dark       $faireImageRef(dark)
            set flat       $faireImageRef(flat-field)
            set const      "0"
            set const_mult "1"
            set temp       "temp"
            #--- Deux possibilites de pretraitement
            if { $faireImageRef(opt) == "0" } {
               #--- Formule : Generique de sortie = [ Generique d'entree - ( Offset + Dark ) ] / Flat-field
               #--- Realisation de X = ( Offset + Dark )
               catch {
                  set buf_pretrait [ ::buf::create ]
                  buf$buf_pretrait load $audace(rep_images)/$offset
                  buf$buf_pretrait add $audace(rep_images)/$dark $const
                  buf$buf_pretrait save $audace(rep_images)/offset+dark
                  ::buf::delete $buf_pretrait
               } m
               if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
                  #--- Realisation de Y = [ Generique d'entree - ( X ) ]
                  catch { sub2 $in offset+dark $temp $const $nb $first } m
                  #--- Realisation de Z = Y / Flat-field
                  catch { div2 $temp $flat $out $const_mult $nb $first } m
                  #--- Suppression des fichiers temporaires
                  catch { delete2 $temp $nb } m
               } else {
                  #--- Realisation de Y = [ Generique d'entree - ( X ) ]
                  catch { sub2 $in offset+dark $out $const $nb $first } m
               }
               #--- Suppression du fichier intermediaire
               catch { file delete [ file join $audace(rep_images) offset+dark$conf(extension,defaut) ] } m
            } else {
               if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
                  #--- Optimisation du noir
                  catch { opt2 $in $dark $offset $temp $nb $first } m
                  #--- Division par le flat
                  catch { div2 $temp $flat $out $const_mult $nb $first } m
                  #--- Suppression des fichiers temporaires
                  catch { delete2 $temp $nb } m
               } else {
                  #--- Optimisation du noir
                  catch { opt2 $in $dark $offset $out $nb $first } m
               }
            }
            #---
            if { $m == "" } {
               if { $faireImageRef(disp) == 1 } {
                  loadima $out$end
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } else {
               tk_messageBox -title $caption(pretraitement,attention) -icon error -message $m
               set faireImageRef(avancement) ""
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
      if { $faireImageRef(operation) == "$caption(audace,menu,pretraite)" } {
         set faireImageRef(afficher_image) "$caption(pretraitement,afficher_der_image_fin)"
      } else {
         set faireImageRef(afficher_image) "$caption(pretraitement,afficher_image_fin)"
      }
      $This.usr.6.1.che1 configure -text "$faireImageRef(afficher_image)"
      #---
      set faireImageRef(avancement)    ""
      set faireImageRef(in)            ""
      set faireImageRef(nb)            ""
      set faireImageRef(valeur_indice) "1"
      #---
      ::faireImageRef::formule
      #---
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $faireImageRef(operation) \
         "$caption(audace,menu,raw2cfa)" {
            set faireImageRef(out)           ""
            set faireImageRef(offset)        ""
            set faireImageRef(dark)          ""
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack forget $This.usr.6
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         } \
         "$caption(audace,menu,faire_offset)" {
            set faireImageRef(out)           "offset"
            set faireImageRef(offset)        ""
            set faireImageRef(dark)          ""
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         } \
         "$caption(audace,menu,faire_dark)" {
            set faireImageRef(out)           "dark"
            set faireImageRef(offset)        "offset"
            set faireImageRef(dark)          ""
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack $This.usr.5 -in $This.usr -side top -fill both
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         } \
         "$caption(audace,menu,faire_flat_field)" {
            set faireImageRef(out)           "flat"
            set faireImageRef(offset)        "offset"
            set faireImageRef(dark)          "dark-flat"
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         } \
         "$caption(audace,menu,pretraite)" {
            set faireImageRef(out)           ""
            set faireImageRef(offset)        "offset"
            set faireImageRef(dark)          "dark"
            set faireImageRef(flat-field)    "flat"
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.7 -in $This.usr -side top -fill both
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack $This.usr.8 -in $This.usr -side bottom -fill both
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
         set faireImageRef(info_filename_in)  [ ::pretraitement::nom_generique [ file rootname [ file tail $filename ] ] ]
         set faireImageRef(in)                [ lindex $faireImageRef(info_filename_in) 0 ]
         set faireImageRef(nb)                [ lindex $faireImageRef(info_filename_in) 1 ]
         set faireImageRef(valeur_indice)     [ lindex $faireImageRef(info_filename_in) 2 ]
      } elseif { $In_Out == "2" } {
         set faireImageRef(info_filename_out) [ ::pretraitement::nom_generique [ file rootname [ file tail $filename ] ] ]
         set faireImageRef(out)               [ lindex $faireImageRef(info_filename_out) 0 ]
      } elseif { $In_Out == "3" } {
         set faireImageRef(offset) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "4" } {
         set faireImageRef(dark) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "5" } {
         set faireImageRef(flat-field) [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::faireImageRef::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption faireImageRef

      if { $faireImageRef(operation) == "$caption(audace,menu,raw2cfa)" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_generique_sortie)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,faire_dark)" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_sortie)"
         set faireImageRef(offset)          "$caption(pretraitement,image_offset)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,faire_flat_field)" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_sortie)"
         set faireImageRef(offset)          "$caption(pretraitement,image_offset)"
         set faireImageRef(dark)            "$caption(pretraitement,image_dark)"
         set faireImageRef(normalisation)   "$caption(pretraitement,valeur_normalisation)"
      } elseif { $faireImageRef(operation) == "$caption(audace,menu,pretraite)" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_generique_sortie)"
         set faireImageRef(offset)          "$caption(pretraitement,image_offset)"
         set faireImageRef(dark)            "$caption(pretraitement,image_dark)"
         set faireImageRef(flat-field)      "$caption(pretraitement,image_flat-field)"
      } else {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_sortie)"
      }
   }

   #
   # ::faireImageRef::griser_activer_1
   # Fonction destinee a inhiber ou a activer l'affichage du champ flat-field de la boite pretraitement
   #
   proc griser_activer_1 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
         $This.usr.7.4.explore configure -state normal
         $This.usr.7.4.ent6 configure -state normal
      } else {
         $This.usr.7.4.explore configure -state disabled
         $This.usr.7.4.ent6 configure -textvariable faireImageRef(flat-field) -state disabled
      }
   }

   #
   # ::faireImageRef::griser_activer_2
   # Fonction destinee a inhiber ou a activer l'affichage du champ offset de la boite flat-field
   #
   proc griser_activer_2 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(flat-field,no-offset) == "0" } {
         $This.usr.4.1.explore configure -state normal
         $This.usr.4.1.ent6 configure -state normal
      } else {
         $This.usr.4.1.explore configure -state disabled
         $This.usr.4.1.ent6 configure -textvariable faireImageRef(offset) -state disabled
      }
   }

   #
   # ::faireImageRef::griser_activer_3
   # Fonction destinee a inhiber ou a activer l'affichage du champ dark de la boite flat-field
   #
   proc griser_activer_3 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(flat-field,no-dark) == "0" } {
         $This.usr.4.2.explore configure -state normal
         $This.usr.4.2.ent6 configure -state normal
      } else {
         $This.usr.4.2.explore configure -state disabled
         $This.usr.4.2.ent6 configure -textvariable faireImageRef(dark) -state disabled
      }
   }

   #
   # ::faireImageRef::griser_activer_4
   # Fonction destinee a inhiber ou a activer l'affichage du champ offset de la boite dark
   #
   proc griser_activer_4 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(dark,no-offset) == "0" } {
         $This.usr.3.1.explore configure -state normal
         $This.usr.3.1.ent6 configure -state normal
      } else {
         $This.usr.3.1.explore configure -state disabled
         $This.usr.3.1.ent6 configure -textvariable faireImageRef(offset) -state disabled
      }
   }

}
########################## Fin du namespace faireImageRef ##########################

