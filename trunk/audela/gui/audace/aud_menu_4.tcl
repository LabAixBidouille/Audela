#
# Fichier : aud_menu_4.tcl
# Description : Script regroupant les fonctionnalites du menu Traitement
# Mise à jour $Id: aud_menu_4.tcl,v 1.20 2010-06-06 17:58:09 jacquesmichelet Exp $
#

namespace eval ::traiteFilters {

   #
   # ::traiteFilters::run type_filtre this
   # Lance la boite de dialogue pour les traitements sur une image
   # this : Chemin de la fenetre
   #
   proc run { type_filtre this } {
      variable This
      variable widget
      global traiteFilters

      #---
      ::traiteFilters::initConf
      ::traiteFilters::confToWidget
      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         if { [ info exists traiteFilters(geometry) ] } {
            set deb [ expr 1 + [ string first + $traiteFilters(geometry) ] ]
            set fin [ string length $traiteFilters(geometry) ]
            set widget(traiteFilters,position) "+[string range $traiteFilters(geometry) $deb $fin]"
         }
         createDialog
      }
      #---
      set traiteFilters(operation) "$type_filtre"
   }

   #
   # ::traiteFilters::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(coef_etal) ] }              { set conf(coef_etal)              "2.0" }
      if { ! [ info exists conf(coef_mult) ] }              { set conf(coef_mult)              "5.0" }
      if { ! [ info exists conf(traiteFilters,position) ] } { set conf(traiteFilters,position) "+350+75" }
      if { ! [ info exists conf(taille_noyau) ] }           { set conf(taille_noyau)           "3" }
      if { ! [ info exists conf(tfd_ordre) ] }              { set conf(tfd_ordre)              "tfd_centre" }
      if { ! [ info exists conf(tfd_format) ] }             { set conf(tfd_format)             "tfd_polaire" }

      return
   }

   #
   # ::traiteFilters::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(traiteFilters,position) "$conf(traiteFilters,position)"
   }

   #
   # ::traiteFilters::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(traiteFilters,position) "$widget(traiteFilters,position)"
   }

   #
   # ::traiteFilters::recup_position
   # Recupere la position de la fenetre
   #
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

   #
   # ::traiteFilters::createDialog
   # Creation de l'interface graphique
   #
    proc createDialog { } {

        variable This
        variable widget
        global audace caption color conf traiteFilters

        #--- Initialisation
        set traiteFilters(choix_mode) "0"
        set traiteFilters(image_in)   ""
        set traiteFilters(image_out)  ""
        set traiteFilters(image_out1)  ""
        set traiteFilters(image_out2)  ""
        set traiteFilters(image_in1)  ""
        set traiteFilters(image_in2)  ""

        #---
        set traiteFilters(avancement)     ""
        set traiteFilters(afficher_image) "$caption(traiteFilters,afficher_image_fin)"
        set traiteFilters(disp_1)         "1"

        #--- Liste des traitements disponibles
        set list_traiteFilters [ list \
         $caption(audace,menu,masque_flou) \
         $caption(audace,menu,filtre_passe-bas) \
         $caption(audace,menu,filtre_passe-haut) \
         $caption(audace,menu,filtre_median) \
         $caption(audace,menu,filtre_minimum) \
         $caption(audace,menu,filtre_maximum) \
         $caption(audace,menu,filtre_gaussien) \
         $caption(audace,menu,ond_morlet) \
         $caption(audace,menu,ond_mexicain) \
         $caption(audace,menu,log) \
         $caption(audace,menu,tfd) \
         $caption(audace,menu,tfdi) \
         $caption(audace,menu,acorr) \
         $caption(audace,menu,icorr) \
         $caption(audace,menu,convolution) \
        ]
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
            frame $This.usr.1 -borderwidth 1 -relief raised
                frame $This.usr.1.radiobutton -borderwidth 0 -relief raised
                #--- Bouton radio 'image affichee'
                    radiobutton $This.usr.1.radiobutton.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
                        -text "$caption(traiteFilters,image_affichee)" -value 0 -variable traiteFilters(choix_mode) \
                        -command {
                            ::traiteFilters::change n1 n2 op
                            ::traiteFilters::griser "$audace(base).traiteFilters"
                        }
                    pack $This.usr.1.radiobutton.rad0 -anchor w -side top -padx 10 -pady 5
                    #--- Bouton radio 'image a choisir sur le disque dur'
                    radiobutton $This.usr.1.radiobutton.rad1 \
                        -anchor nw \
                        -highlightthickness 0 \
                        -padx 0 \
                        -pady 0 \
                        -state normal \
                        -text "$caption(traiteFilters,image_a_choisir)" \
                        -value 1 \
                        -variable traiteFilters(choix_mode) \
                        -command {
                            ::traiteFilters::change n1 n2 op
                            ::traiteFilters::activer "$audace(base).traiteFilters"
                        }
                    pack $This.usr.1.radiobutton.rad1 -anchor w -side top -padx 10 -pady 5
                #pack $This.usr.1.radiobutton -side left -padx 10 -pady 5

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

                #---
                label $This.usr.1.lab1 -text "$caption(traiteFilters,filtres)"
                pack $This.usr.1.lab1 -side right -padx 10 -pady 5

            pack $This.usr.1 -side top -fill both -ipady 5

            frame $This.usr.2 -borderwidth 1 -relief raised
            pack $This.usr.2 -side top -fill both -ipady 5

            frame $This.usr.3 -borderwidth 0 -relief raised
                 frame $This.usr.3.1 -borderwidth 0 -relief flat
                     label $This.usr.3.1.lab1 -text "$caption(traiteFilters,entree)"
                     pack $This.usr.3.1.lab1 -side left -padx 5 -pady 5
                     entry $This.usr.3.1.ent1 -textvariable traiteFilters(image_in)
                     pack $This.usr.3.1.ent1 -side left -padx 10 -pady 5 -fill x -expand 1
                     button $This.usr.3.1.explore -text "$caption(traiteFilters,parcourir)" -width 1 \
                         -command { ::traiteFilters::parcourir 1 }
                     pack $This.usr.3.1.explore -side left -padx 10 -pady 5 -ipady 5
                 pack $This.usr.3.1 -side top -fill both
            # pack $This.usr.3 -side top -fill both

            frame $This.usr.4 -borderwidth 0 -relief raised
                frame $This.usr.4.1 -borderwidth 0 -relief flat
                    button $This.usr.4.1.but_defaut -text "$caption(traiteFilters,valeur_par_defaut)" \
                        -command { ::traiteFilters::val_defaut }
                # pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    entry $This.usr.4.1.ent2 -textvariable traiteFilters(coef_etal) -width 10
                    pack $This.usr.4.1.ent2 -side right -padx 10 -pady 5
                    label $This.usr.4.1.lab2 -text "$caption(traiteFilters,coef_etalement)"
                    pack $This.usr.4.1.lab2 -side right -padx 5 -pady 5
                    pack $This.usr.4.1 -side top -fill both
            # pack $This.usr.4 -side top -fill both

            frame $This.usr.5 -borderwidth 0 -relief raised
               frame $This.usr.5.1 -borderwidth 0 -relief flat
                  button $This.usr.5.1.but_defaut -text "$caption(traiteFilters,valeur_par_defaut)" \
                     -command { ::traiteFilters::val_defaut }
                 # pack $This.usr.5.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                  entry $This.usr.5.1.ent3 -textvariable traiteFilters(coef_mult) -width 10
                  pack $This.usr.5.1.ent3 -side right -padx 10 -pady 5
                  label $This.usr.5.1.lab3 -text "$caption(traiteFilters,coef_mult)"
                  pack $This.usr.5.1.lab3 -side right -padx 5 -pady 5
                  pack $This.usr.5.1 -side top -fill both
           # pack $This.usr.5 -side top -fill both

            frame $This.usr.6 -borderwidth 0 -relief raised
               frame $This.usr.6.1 -borderwidth 0 -relief flat
                  label $This.usr.6.1.lab4 -text "$caption(traiteFilters,coef_efficacite)"
                  pack $This.usr.6.1.lab4 -side left -padx 5 -pady 5
                  entry $This.usr.6.1.ent4 -textvariable traiteFilters(efficacite) -width 4
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
                     label $This.usr.6.2.2.lab5 -text "$caption(traiteFilters,efficacite_max)"
                     pack $This.usr.6.2.2.lab5 -side left -padx 7 -pady 5
                     label $This.usr.6.2.2.lab6 -text "$caption(traiteFilters,efficacite_min)"
                     pack $This.usr.6.2.2.lab6 -side right -padx 10 -pady 5
                  pack $This.usr.6.2.2 -side top -fill both
               pack $This.usr.6.2 -side right -fill both
           # pack $This.usr.6 -side top -fill both

            frame $This.usr.7 -borderwidth 0 -relief raised
               frame $This.usr.7.1 -borderwidth 0 -relief flat
                  entry $This.usr.7.1.ent5 -textvariable traiteFilters(offset) -width 10
                  pack $This.usr.7.1.ent5 -side right -padx 10 -pady 5
                  label $This.usr.7.1.lab7 -text "$caption(traiteFilters,offset)"
                  pack $This.usr.7.1.lab7 -side right -padx 5 -pady 5
               pack $This.usr.7.1 -side top -fill both
           # pack $This.usr.7 -side top -fill both

         frame $This.usr.8 -borderwidth 1 -relief raised
            frame $This.usr.8.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.8.1.che1 -text "$traiteFilters(afficher_image)" -variable traiteFilters(disp_1) \
                  -state disabled
               pack $This.usr.8.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.8.1 -side top -fill both
        # pack $This.usr.8 -side top -fill both

         frame $This.usr.9 -borderwidth 1 -relief raised
            frame $This.usr.9.1 -borderwidth 0 -relief flat
               label $This.usr.9.1.labURL1 -textvariable "traiteFilters(avancement)" -fg $color(blue)
               pack $This.usr.9.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.9.1 -side top -fill both
        # pack $This.usr.9 -side top -fill both

         frame $This.usr.10 -borderwidth 0 -relief raised
            frame $This.usr.10.1 -borderwidth 0 -relief flat
               label $This.usr.10.1.l -text "$caption(traiteFilters,taille_noyau)"
               pack $This.usr.10.1.l -side top -padx 5 -pady 5
            pack $This.usr.10.1 -side left -fill both
            frame $This.usr.10.2 -borderwidth 0 -relief flat
               foreach champ [list 3 5 7 9 11 13 15 17 19 21] {
                  radiobutton $This.usr.10.2.$champ -text $champ -value $champ -variable traiteFilters(taille_noyau)
                  pack $This.usr.10.2.$champ -side left
               }
            pack $This.usr.10.2 -side right -fill both

        set f [ frame $This.usr.tfd_ordre -borderwidth 0 -relief raised ]
        set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
        label ${g}.l -text "$caption(traiteFilters,tfd_ordre)"
        pack ${g}.l -side top -padx 5 -pady 5
        pack $g -side left -fill both
        set g [ frame ${f}.2 -borderwidth 0 -relief flat ]
        foreach champ [ list tfd_centre tfd_normal ] {
            radiobutton ${g}.$champ -text $caption(traiteFilters,${champ}) -value $champ -variable traiteFilters(tfd_ordre)
            pack ${g}.$champ -side left
        }
        pack $g -side right -fill both

        set f [ frame $This.usr.tfd_format -borderwidth 0 -relief raised ]
        set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
        label ${g}.l -text "$caption(traiteFilters,tfd_format)"
        pack ${g}.l -side top -padx 5 -pady 5
        pack $g -side left -fill both
        set g [ frame ${f}.2 -borderwidth 0 -relief flat ]
        foreach champ [ list tfd_polaire tfd_cartesien ] {
            radiobutton ${g}.$champ -text $caption(traiteFilters,${champ}) -value $champ -variable traiteFilters(tfd_format)
            pack ${g}.$champ -side left
        }
        pack $g -side right -fill both

        set f [ frame $This.usr.tfd_sortie2 -borderwidth 0 -relief raised ]
        set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
        label ${g}.l -text "$caption(traiteFilters,tfd_sortie1)"
        pack ${g}.l -side left -padx 5 -pady 5
        entry ${g}.e -textvariable traiteFilters(image_out1)
        pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${g}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::choix_nom_sauvegarde 3 }
        pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
        set h [ frame ${f}.2 -borderwidth 0 -relief flat ]
        label ${h}.l -text "$caption(traiteFilters,tfd_sortie2)"
        pack ${h}.l -side left -padx 5 -pady 5
        entry ${h}.e -textvariable traiteFilters(image_out2)
        pack ${h}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${h}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::choix_nom_sauvegarde 4 }
        pack ${h}.explore -side left -padx 10 -pady 5 -ipady 5
        pack $g $h -side top -fill both

        set f [ frame $This.usr.tfd_entree2 -borderwidth 0 -relief raised ]
        set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
        label ${g}.l -text "$caption(traiteFilters,tfd_entree1)"
        pack ${g}.l -side left -padx 5 -pady 5
        entry ${g}.e -textvariable traiteFilters(image_in1)
        pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${g}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::parcourir 5 }
        pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
        set h [ frame ${f}.2 -borderwidth 0 -relief flat ]
        label ${h}.l -text "$caption(traiteFilters,tfd_entree2)"
        pack ${h}.l -side left -padx 5 -pady 5
        entry ${h}.e -textvariable traiteFilters(image_in2)
        pack ${h}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${h}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::parcourir 6 }
        pack ${h}.explore -side left -padx 10 -pady 5 -ipady 5
        pack $g $h -side top -fill both

        set f [ frame $This.usr.tfd_sortie1 -borderwidth 0 -relief raised ]
        set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
        label ${g}.l -text "$caption(traiteFilters,sortie)"
        pack ${g}.l -side left -padx 5 -pady 5
        entry ${g}.e -textvariable traiteFilters(image_out)
        pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${g}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::parcourir 2 }
        pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
        pack $g -side top -fill both

        set f [ frame $This.usr.icorr_entree2 -borderwidth 0 -relief raised ]
        set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
        label ${g}.l -text "$caption(traiteFilters,icorr_entree1)"
        pack ${g}.l -side left -padx 5 -pady 5
        entry ${g}.e -textvariable traiteFilters(image_in1)
        pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${g}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::parcourir 5 }
        pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
        set h [ frame ${f}.2 -borderwidth 0 -relief flat ]
        label ${h}.l -text "$caption(traiteFilters,icorr_entree2)"
        pack ${h}.l -side left -padx 5 -pady 5
        entry ${h}.e -textvariable traiteFilters(image_in2)
        pack ${h}.e -side left -padx 10 -pady 5 -fill x -expand 1
        button ${h}.explore -text "$caption(traiteFilters,parcourir)" -width 1 -command { ::traiteFilters::parcourir 6 }
        pack ${h}.explore -side left -padx 10 -pady 5 -ipady 5
        pack $g $h -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(traiteFilters,ok)" -width 7 \
            -command { ::traiteFilters::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(traiteFilters,appliquer)" -width 8 \
            -command { ::traiteFilters::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(traiteFilters,fermer)" -width 7 \
            -command { ::traiteFilters::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(traiteFilters,aide)" -width 7 \
            -command { ::traiteFilters::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Entry actives ou non
      if { $traiteFilters(choix_mode) == "0" } {
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
      bind $This <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::traiteFilters::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      cmdApply
      cmdClose
   }

    #
    # ::traiteFilters::cmdApply
    # Procedure correspondant a l'appui sur le bouton Appliquer
    #
    proc cmdApply { } {
        global audace caption conf traiteFilters

        #---
        set traiteFilters(avancement) "$caption(traiteFilters,traitement_en_cours)"
        #---
        set audace(artifice) "@@@@"
        set image_in     $traiteFilters(image_in)
        set image_out    $traiteFilters(image_out)
        set image_out1   $traiteFilters(image_out1)
        set image_out2   $traiteFilters(image_out2)
        set image_in1    $traiteFilters(image_in1)
        set image_in2    $traiteFilters(image_in2)
        set coef_etal    $traiteFilters(coef_etal)
        set coef_mult    $traiteFilters(coef_mult)
        set efficacite   $traiteFilters(efficacite)
        set offset       $traiteFilters(offset)
        set taille_noyau $traiteFilters(taille_noyau)
        set tfd_ordre    $traiteFilters(tfd_ordre)
        set tfd_format   $traiteFilters(tfd_format)
        #--- Sauvegarde des reglages
        set conf(coef_etal)    $traiteFilters(coef_etal)
        set conf(coef_mult)    $traiteFilters(coef_mult)
        set conf(taille_noyau) $traiteFilters(taille_noyau)
        set conf(tfd_ordre)    $traiteFilters(tfd_ordre)
        set conf(tfd_format)   $traiteFilters(tfd_format)
        if { ( $traiteFilters(operation) == $caption(audace,menu,tfdi) )
         || ( $traiteFilters(operation) == $caption(audace,menu,icorr) )
         || ( $traiteFilters(operation) == $caption(audace,menu,convolution) ) } {
            # La TFD inverse, l'intercorrelation et la convolution requièrent 2 images en entrée
            if { ( $traiteFilters(image_in1) == "" ) || ( $traiteFilters(image_in2) == "" ) } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok -message $caption(traiteFilters,choix_image_dd)
                set traiteFilters(avancement) ""
                return
            }
        } else {
            #--- Il faut saisir la constante
            if { $traiteFilters(choix_mode) == "0" } {
                if { [ buf$audace(bufNo) imageready ] == "0" } {
                    tk_messageBox -title $caption(traiteFilters,attention) -type ok -message $caption(traiteFilters,header_noimage)
                    set traiteFilters(avancement) ""
                    return
                }
            } elseif { $traiteFilters(choix_mode) == "1" } {
                if { $traiteFilters(image_in) == "" } {
                    tk_messageBox -title $caption(traiteFilters,attention) -type ok -message $caption(traiteFilters,choix_image_dd)
                    set traiteFilters(avancement) ""
                    return
                }
            }
        }
        #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
        #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
        #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
        #--- que la commande switch continue sur la ligne suivante
        switch $traiteFilters(operation) \
        "$caption(audace,menu,masque_flou)" {
            #---
            if { ( $traiteFilters(coef_etal) == "" ) && ( $traiteFilters(coef_mult) == "" ) } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficients)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(coef_etal) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(coef_mult) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { ( [ string is double -strict $traiteFilters(coef_etal) ] == "0" ) && ( [ string is double -strict $traiteFilters(coef_mult) ] == "0" ) } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalides)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(coef_etal) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(coef_mult) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_masque_flou $image_in $coef_etal $coef_mult\n\n"
                bm_masque_flou $image_in $coef_etal $coef_mult
            } else {
                ::console::affiche_resultat "bm_masque_flou $caption(traiteFilters,_image_affichee_) $coef_etal $coef_mult\n\n"
                bm_masque_flou "$audace(artifice)" $coef_etal $coef_mult
            }
        } \
        "$caption(audace,menu,filtre_passe-bas)" {
            #---
            if { $traiteFilters(efficacite) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficient)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_passe_bas $image_in $efficacite $taille_noyau\n\n"
                bm_passe_bas $image_in $efficacite $taille_noyau
            } else {
                ::console::affiche_resultat "bm_passe_bas $caption(traiteFilters,_image_affichee_) $efficacite $taille_noyau\n\n"
                bm_passe_bas "$audace(artifice)" $efficacite $taille_noyau
            }
        } \
        "$caption(audace,menu,filtre_passe-haut)" {
            #---
            if { $traiteFilters(efficacite) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficient)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_passe_haut $image_in $efficacite\n\n"
                bm_passe_haut $image_in $efficacite $taille_noyau
            } else {
                ::console::affiche_resultat "bm_passe_haut $caption(traiteFilters,_image_affichee_) $efficacite\n\n"
                bm_passe_haut "$audace(artifice)" $efficacite $taille_noyau
            }
        } \
        "$caption(audace,menu,filtre_median)" {
            #---
            if { $traiteFilters(efficacite) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficient)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_filtre_median $image_in $efficacite\n\n"
                bm_filtre_median $image_in $efficacite $taille_noyau
            } else {
                ::console::affiche_resultat "bm_filtre_median $caption(traiteFilters,_image_affichee_) $efficacite\n\n"
                bm_filtre_median "$audace(artifice)" $efficacite $taille_noyau
            }
        } \
        "$caption(audace,menu,filtre_minimum)" {
            #---
            if { $traiteFilters(efficacite) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficient)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_filtre_min $image_in $efficacite\n\n"
                bm_filtre_min $image_in $efficacite $taille_noyau
            } else {
                ::console::affiche_resultat "bm_filtre_min $caption(traiteFilters,_image_affichee_) $efficacite\n\n"
                bm_filtre_min "$audace(artifice)" $efficacite $taille_noyau
            }
        } \
        "$caption(audace,menu,filtre_maximum)" {
            #---
            if { $traiteFilters(efficacite) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficient)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_filtre_max $image_in $efficacite\n\n"
                bm_filtre_max $image_in $efficacite $taille_noyau
            } else {
                ::console::affiche_resultat "bm_filtre_max $caption(traiteFilters,_image_affichee_) $efficacite\n\n"
                bm_filtre_max "$audace(artifice)" $efficacite $taille_noyau
            }
        } \
        "$caption(audace,menu,filtre_gaussien)" {
            #---
            if { $traiteFilters(coef_etal) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(coef_etal) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_filtre_gauss $image_in $coef_etal\n\n"
                bm_filtre_gauss $image_in $coef_etal
            } else {
                ::console::affiche_resultat "bm_filtre_gauss $caption(traiteFilters,_image_affichee_) $coef_etal\n\n"
                bm_filtre_gauss "$audace(artifice)" $coef_etal
            }
        } \
        "$caption(audace,menu,ond_morlet)" {
            #---
            if { $traiteFilters(coef_etal) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(coef_etal) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_ondelette_mor $image_in $coef_etal\n\n"
                bm_ondelette_mor $image_in $coef_etal
            } else {
                ::console::affiche_resultat "bm_ondelette_mor $caption(traiteFilters,_image_affichee_) $coef_etal\n\n"
                bm_ondelette_mor "$audace(artifice)" $coef_etal
            }
        } \
        "$caption(audace,menu,ond_mexicain)" {
            #---
            if { $traiteFilters(coef_etal) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(coef_etal) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_ondelette_mex $image_in $coef_etal\n\n"
                bm_ondelette_mex $image_in $coef_etal
            } else {
                ::console::affiche_resultat "bm_ondelette_mex $caption(traiteFilters,_image_affichee_) $coef_etal\n\n"
                bm_ondelette_mex "$audace(artifice)" $coef_etal
            }
        } \
        "$caption(audace,menu,log)" {
            #---
            if { ( $traiteFilters(coef_mult) == "" ) && ( $traiteFilters(offset) == "" ) } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,choix_coefficients)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(coef_mult) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(offset) == "" } {
                tk_messageBox -title $caption(traiteFilters,attention) -type ok \
                -message $caption(traiteFilters,coef_manquant)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { ( [ string is double -strict $traiteFilters(coef_mult) ] == "0" ) && ( [ string is double -strict $traiteFilters(offset) ] == "0" ) } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalides)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(coef_mult) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { [ string is double -strict $traiteFilters(offset) ] == "0" } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,coef_invalide)
                set traiteFilters(avancement) ""
                return
            }
            #---
            if { $traiteFilters(choix_mode) == "1" } {
                ::console::affiche_resultat "bm_logima $image_in $coef_mult $offset\n\n"
                bm_logima $image_in $coef_mult $offset
            } else {
                ::console::affiche_resultat "bm_logima $caption(traiteFilters,_image_affichee_) $coef_mult $offset\n\n"
                bm_logima "$audace(artifice)" $coef_mult $offset
            }
        } \
        "$caption(audace,menu,tfd)" {
            set dft_format "polar"
            if { $tfd_format == "tfd_cartesien" } { set dft_format "cartesian" }
            set dft_order "centered"
            if { $tfd_ordre == "tfd_normal" } { set dft_order "regular" }
            if { ( $image_out1 == $image_out2 ) && ( $traiteFilters(choix_mode) == "1" ) } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error \
                -message $caption(traiteFilters,tfd_images_differentes)
                set traiteFilters(avancement) ""
                return
            }
            if { $traiteFilters(choix_mode) == "1" } {
                if { [ catch { dft2d $image_in.fit $image_out1.fit $image_out2.fit $dft_format $dft_order } message_erreur ] } {
                    tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
                } else {
                    buf$audace(bufNo) load $image_out1.fit
                    ::confVisu::autovisu $::audace(visuNo) "-dovisu" $image_out1.fit
                }
            } else  {
                if { $dft_format == "polar" } {
                    set nom_1 [ file join $::audace(rep_images) modulus.fit ]
                    set nom_2 [ file join $::audace(rep_images) argument.fit ]
                } else {
                    set nom_1 [ file join $::audace(rep_images) real.fit ]
                    set nom_2 [ file join $::audace(rep_images) imaginary.fit ]
                }
                set nom [ file join $audace(rep_images) [ clock milliseconds ] ]
                append nom ".fit"
                buf$audace(bufNo) save $nom
                if { [ catch { dft2d $nom $nom_1 $nom_2 $dft_format $dft_order } message_erreur ] } {
                    tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
                } else {
                    buf$audace(bufNo) load $nom_1
                    ::confVisu::autovisu $::audace(visuNo) "-dovisu" $nom_1
                }
                file delete $nom
            }
        } \
        "$caption(audace,menu,tfdi)" {
            # Génération d'un nom aléatoire
            set dest [ file join $audace(rep_images) image.fit ]
            if { [ catch { idft2d $image_in1.fit $image_in2.fit $dest } message_erreur ] } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
            } else {
                buf$audace(bufNo) load $dest
                ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
            }
        } \
        "$caption(audace,menu,acorr)" {
            if { $traiteFilters(choix_mode) == "1" } {
                set dest [ file join $audace(rep_images) autocorrelation.fit ]
                if { [ catch { acorr2d ${image_in}.fit $dest } message_erreur ] } {
                    tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
                } else {
                    buf$audace(bufNo) load $dest
                    ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
                }
            } else  {
                # Génération d'un nom aléatoire
                set nom_s [ file join $audace(rep_images) [ clock milliseconds ] ]
                append nom_s ".fit"
                set nom_d [ file join $audace(rep_images) autocorrelation.fit ]
                buf$audace(bufNo) save $nom_s
                if { [ catch { acorr2d $nom_s $nom_d } message_erreur ] } {
                    tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
                } else {
                    buf$audace(bufNo) load $nom_d
                    ::confVisu::autovisu $::audace(visuNo) "-dovisu" $nom_d
                }
                file delete $nom_s
            }
        } \
        "$caption(audace,menu,icorr)" {
            set dest [ file join $audace(rep_images) crosscorrelation.fit ]
            if { [ catch { icorr2d ${image_in1}.fit ${image_in2}.fit $dest } message_erreur ] } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
            } else {
                buf$audace(bufNo) load $dest
                ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
            }
        } \
        "$caption(audace,menu,convolution)" {
            set dest [ file join $audace(rep_images) convolution.fit ]
            if { [ catch { conv2d ${image_in1}.fit ${image_in2}.fit $dest denorm } message_erreur ] } {
                tk_messageBox -title $caption(traiteFilters,attention) -icon error -message $message_erreur
            } else {
                buf$audace(bufNo) load $dest
                ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
            }
        }
        ::traiteFilters::recup_position
    }

   #
   # ::traiteFilters::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #

    proc afficheAide { } {
        global help caption traiteFilters

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
        } elseif { $traiteFilters(operation) == $caption(audace,menu,tfd) } {
            set traiteFilters(page_web) "1110TFD"
        } elseif { $traiteFilters(operation) == $caption(audace,menu,tfdi) } {
            set traiteFilters(page_web) "1120TFDInverse"
        } elseif { $traiteFilters(operation) == $caption(audace,menu,acorr) } {
            set traiteFilters(page_web) "1130autocorrelation"
        } elseif { $traiteFilters(operation) == $caption(audace,menu,icorr) } {
            set traiteFilters(page_web) "1140intercorrelation"
        } elseif { $traiteFilters(operation) == $caption(audace,menu,convolution) } {
            set traiteFilters(page_web) "1150convolution"
        }

        #---
        ::audace::showHelpItem "$help(dir,trait)" "$traiteFilters(page_web).htm"
    }

   #
   # ::traiteFilters::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
       variable This

       ::traiteFilters::recup_position
       destroy $This
       unset This
   }

    #
    # ::traiteFilters::change n1 n2 op
    # Adapte l'interface graphique en fonction du choix
    #
    proc change { n1 n2 op } {
        variable This
        global audace caption conf traiteFilters

        #--- Initialisation des variables
        set traiteFilters(avancement) ""
        set traiteFilters(coef_etal)    $conf(coef_etal)
        set traiteFilters(coef_mult)    $conf(coef_mult)
        set traiteFilters(taille_noyau) $conf(taille_noyau)
        set traiteFilters(tfd_ordre)    $conf(tfd_ordre)
        set traiteFilters(tfd_format)   $conf(tfd_format)
        #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
        #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
        #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
        #--- que la commande switch continue sur la ligne suivante
        switch $traiteFilters(operation) \
            "$caption(audace,menu,masque_flou)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack $This.usr.5 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack $This.usr.5 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,filtre_passe-bas)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,filtre_passe-haut)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,filtre_median)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,filtre_minimum)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                }
            } \
            "$caption(audace,menu,filtre_maximum)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack $This.usr.6 -in $This.usr.2 -side top -fill both
                    pack $This.usr.10 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,filtre_gaussien)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,ond_morlet)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,ond_mexicain)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4 -in $This.usr.2 -side top -fill both
                    pack $This.usr.4.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack forget $This.usr.7
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,log)" {
                if { [ buf$audace(bufNo) imageready ] == "1" } {
                    set traiteFilters(offset) [ lindex [ buf$audace(bufNo) autocuts ] 1 ]
                }
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack $This.usr.5 -in $This.usr.2 -side top -fill both
                    pack $This.usr.5.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack $This.usr.7 -in $This.usr.2 -side top -fill both
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack $This.usr.5 -in $This.usr.2 -side top -fill both
                    pack $This.usr.5.1.but_defaut -side left -padx 10 -pady 5 -ipadx 10 -ipady 5 -fill x
                    pack forget $This.usr.6
                    pack forget $This.usr.10
                    pack $This.usr.7 -in $This.usr.2 -side top -fill both
                    pack $This.usr.8 -in $This.usr -side top -fill both
                    pack $This.usr.9 -in $This.usr -side top -fill both
                    pack forget $This.usr.tfd_ordre
                    pack forget $This.usr.tfd_format
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.tfd_sortie2
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,tfd)" {
                if { $traiteFilters(choix_mode) == "0" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 $This.usr.tfd_sortie2 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.7
                    pack forget $This.usr.8
                    pack forget $This.usr.9
                    pack forget $This.usr.10
                    pack $This.usr.tfd_ordre -in $This.usr.2 -side top -fill both
                    pack $This.usr.tfd_format -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.icorr_entree2
                } elseif { $traiteFilters(choix_mode) == "1" } {
                    pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                    pack $This.usr.3 $This.usr.tfd_sortie2 -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.4
                    pack forget $This.usr.4.1.but_defaut
                    pack forget $This.usr.5
                    pack forget $This.usr.5.1.but_defaut
                    pack forget $This.usr.6
                    pack forget $This.usr.7
                    pack forget $This.usr.8
                    pack forget $This.usr.9
                    pack forget $This.usr.10
                    pack $This.usr.tfd_ordre -in $This.usr.2 -side top -fill both
                    pack $This.usr.tfd_format -in $This.usr.2 -side top -fill both
                    pack forget $This.usr.tfd_sortie1
                    pack forget $This.usr.tfd_entree2
                    pack forget $This.usr.icorr_entree2
                }
            } \
            "$caption(audace,menu,tfdi)" {
                pack forget $This.usr.1.radiobutton
                pack forget $This.usr.3
                pack $This.usr.tfd_entree2 -in $This.usr.2 -side top -fill both
                pack forget $This.usr.4
                pack forget $This.usr.4.1.but_defaut
                pack forget $This.usr.5
                pack forget $This.usr.5.1.but_defaut
                pack forget $This.usr.6
                pack forget $This.usr.7
                pack forget $This.usr.8
                pack forget $This.usr.9
                pack forget $This.usr.10
                pack forget $This.usr.tfd_ordre
                pack forget $This.usr.tfd_format
                pack forget $This.usr.tfd_sortie1
                pack forget $This.usr.tfd_sortie2
                pack forget $This.usr.icorr_entree2
            } \
            "$caption(audace,menu,acorr)" {
                pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
                pack $This.usr.3 -in $This.usr.2 -side top -fill both
                pack forget $This.usr.4
                pack forget $This.usr.4.1.but_defaut
                pack forget $This.usr.5
                pack forget $This.usr.5.1.but_defaut
                pack forget $This.usr.6
                pack forget $This.usr.7
                pack forget $This.usr.8
                pack forget $This.usr.9
                pack forget $This.usr.10
                pack forget $This.usr.tfd_ordre
                pack forget $This.usr.tfd_format
                pack forget $This.usr.tfd_entree2
                pack forget $This.usr.tfd_sortie1
                pack forget $This.usr.tfd_sortie2
                pack forget $This.usr.icorr_entree2
            } \
            "$caption(audace,menu,icorr)" {
                pack forget $This.usr.1.radiobutton
                pack forget $This.usr.3
                pack $This.usr.icorr_entree2 -in $This.usr.2 -side top -fill both
                pack forget $This.usr.4
                pack forget $This.usr.4.1.but_defaut
                pack forget $This.usr.5
                pack forget $This.usr.5.1.but_defaut
                pack forget $This.usr.6
                pack forget $This.usr.7
                pack forget $This.usr.8
                pack forget $This.usr.9
                pack forget $This.usr.10
                pack forget $This.usr.tfd_ordre
                pack forget $This.usr.tfd_format
                pack forget $This.usr.tfd_sortie1
                pack forget $This.usr.tfd_sortie2
                pack forget $This.usr.tfd_entree2
            } \
            "$caption(audace,menu,convolution)" {
                pack forget $This.usr.1.radiobutton
                pack forget $This.usr.3
                pack $This.usr.icorr_entree2 -in $This.usr.2 -side top -fill both
                pack forget $This.usr.4
                pack forget $This.usr.4.1.but_defaut
                pack forget $This.usr.5
                pack forget $This.usr.5.1.but_defaut
                pack forget $This.usr.6
                pack forget $This.usr.7
                pack forget $This.usr.8
                pack forget $This.usr.9
                pack forget $This.usr.10
                pack forget $This.usr.tfd_ordre
                pack forget $This.usr.tfd_format
                pack forget $This.usr.tfd_sortie1
                pack forget $This.usr.tfd_sortie2
                pack forget $This.usr.tfd_entree2
            }
    }

   #
   # ::traiteFilters::parcourir
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
        global audace traiteFilters

        #--- Fenetre parent
        set fenetre "$audace(base).traiteFilters"
        #--- Ouvre la fenetre de choix des images
        set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
        #--- Nom du fichier avec le chemin et sans son extension
        if { $In_Out == "1" } {
            set traiteFilters(image_in)  [ file rootname $filename ]
        } elseif { $In_Out == "2" } {
            set traiteFilters(image_out) [ file rootname $filename ]
        } elseif { $In_Out == "3" } {
            set traiteFilters(image_out1) [ file rootname $filename ]
        } elseif { $In_Out == "4" } {
            set traiteFilters(image_out2) [ file rootname $filename ]
        } elseif { $In_Out == "5" } {
            set traiteFilters(image_in1) [ file rootname $filename ]
        } elseif { $In_Out == "6" } {
            set traiteFilters(image_in2) [ file rootname $filename ]
        }
    }

   #
   # ::traiteFilters::choix_nom_sauvegarde
   # Ouvre un explorateur pour choisir un nom de fichier
   #
   proc choix_nom_sauvegarde { In_Out } {
        global audace traiteFilters

        #--- Fenetre parent
        set fenetre "$audace(base).traiteFilters"
        #--- Ouvre la fenetre de choix des images
        set filename [ ::tkutil::box_save $fenetre $audace(rep_images) $audace(bufNo) "1" ]
        #--- Nom du fichier avec le chemin et sans son extension
        if { $In_Out == "1" } {
            set traiteFilters(image_in)  [ file rootname $filename ]
        } elseif { $In_Out == "2" } {
            set traiteFilters(image_out) [ file rootname $filename ]
        } elseif { $In_Out == "3" } {
            set traiteFilters(image_out1) [ file rootname $filename ]
        } elseif { $In_Out == "4" } {
            set traiteFilters(image_out2) [ file rootname $filename ]
        } elseif { $In_Out == "5" } {
            set traiteFilters(image_in1) [ file rootname $filename ]
        } elseif { $In_Out == "6" } {
            set traiteFilters(image_in2) [ file rootname $filename ]
        }
    }

   #
   # ::traiteFilters::val_defaut
   # Affiche les valeurs par defaut des constantes
   #
   proc val_defaut { } {
      global caption traiteFilters

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

   #
   # ::traiteFilters::griser this
   # Grise les widgets disabled
   # this : Chemin de la fenetre
   #
   proc griser { this } {
      variable This
      global traiteFilters

      #--- Initialisation des variables
      set traiteFilters(avancement) ""
      #--- Fonction destinee a inhiber et griser des widgets
      set This $this
      $This.usr.3.1.explore configure -state disabled
      $This.usr.3.1.ent1 configure -state disabled
      $This.usr.tfd_sortie2.1.e configure -state disabled
      $This.usr.tfd_sortie2.1.explore configure -state disabled
      $This.usr.tfd_sortie2.2.e configure -state disabled
      $This.usr.tfd_sortie2.2.explore configure -state disabled
   }

   #
   # ::traiteFilters::activer this
   # Active les widgets
   # this : Chemin de la fenetre
   #
   proc activer { this } {
      variable This
      global traiteFilters

      #--- Initialisation des variables
      set traiteFilters(avancement) ""
      #--- Fonction destinee a activer des widgets
      set This $this
      $This.usr.3.1.explore configure -state normal
      $This.usr.3.1.ent1 configure -state normal
      $This.usr.tfd_sortie2.1.e configure -state normal
      $This.usr.tfd_sortie2.1.explore configure -state normal
      $This.usr.tfd_sortie2.2.e configure -state normal
      $This.usr.tfd_sortie2.2.explore configure -state normal
   }

}
########################## Fin du namespace traiteFilters ##########################

