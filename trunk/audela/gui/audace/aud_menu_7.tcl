#
# Fichier : aud_menu_7.tcl
# Description : Script regroupant les fonctionnalites du menu Configuration
# Mise à jour $Id$
#

namespace eval ::cwdWindow {

   #
   # ::cwdWindow::run this
   # Lance la fenetre de dialogue pour la configuration des repertoires
   # this : Chemin de la fenetre
   #
   proc run { this } {
      variable This
      global audace cwdWindow

      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         set cwdWindow(dir_images)             [file nativename $::conf(rep_images)]
         set cwdWindow(rep_images,mode)        $::conf(rep_images,mode)
         set cwdWindow(rep_images,refModeAuto) $::conf(rep_images,refModeAuto)
         set cwdWindow(rep_images,subdir)      $::conf(rep_images,subdir)
         set cwdWindow(dir_travail)            [file nativename $::audace(rep_travail)]
         set cwdWindow(travail_images)         $::conf(rep_travail,travail_images)
         set cwdWindow(dir_scripts)            [file nativename $audace(rep_scripts)]
         set cwdWindow(dir_catalogues)         [file nativename $audace(rep_userCatalog)]
         set cwdWindow(dir_cata_microcat)      [file nativename $audace(rep_userCatalogMicrocat)]
         set cwdWindow(dir_cata_usnoa2)        [file nativename $audace(rep_userCatalogUsnoa2)]
         set cwdWindow(dir_cata_tycho2)        [file nativename $audace(rep_userCatalogTycho2)]
         set cwdWindow(dir_cata_ucac2)         [file nativename $audace(rep_userCatalogUcac2)]
         set cwdWindow(dir_cata_ucac3)         [file nativename $audace(rep_userCatalogUcac3)]
         set cwdWindow(dir_cata_ucac4)         [file nativename $audace(rep_userCatalogUcac4)]
         set cwdWindow(dir_cata_ppmx)          [file nativename $audace(rep_userCatalogPpmx)]
         set cwdWindow(dir_cata_ppmxl)         [file nativename $audace(rep_userCatalogPpmxl)]
         set cwdWindow(dir_cata_nomad1)        [file nativename $audace(rep_userCatalogNomad1)]
         set cwdWindow(dir_cata_2mass)         [file nativename $audace(rep_userCatalog2mass)]
         set cwdWindow(dir_archives)           [file nativename $audace(rep_archives)]
         set cwdWindow(long)                   [string length $cwdWindow(dir_images)]
         if {[string length $cwdWindow(dir_images)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_images)]
         }
         if {[string length $cwdWindow(dir_travail)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_travail)]
         }
         if {[string length $cwdWindow(dir_scripts)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_scripts)]
         }
         if {[string length $cwdWindow(dir_catalogues)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_catalogues)]
         }
         if {[string length $cwdWindow(dir_cata_microcat)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_microcat)]
         }
         if {[string length $cwdWindow(dir_cata_usnoa2)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_usnoa2)]
         }
         if {[string length $cwdWindow(dir_cata_tycho2)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_tycho2)]
         }
         if {[string length $cwdWindow(dir_cata_ucac2)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_ucac2)]
         }
         if {[string length $cwdWindow(dir_cata_ucac3)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_ucac3)]
         }
         if {[string length $cwdWindow(dir_cata_ucac4)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_ucac4)]
         }
         if {[string length $cwdWindow(dir_cata_ppmx)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_ppmx)]
         }
         if {[string length $cwdWindow(dir_cata_ppmxl)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_ppmxl)]
         }
         if {[string length $cwdWindow(dir_cata_nomad1)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_nomad1)]
         }
         if {[string length $cwdWindow(dir_cata_2mass)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_cata_2mass)]
         }
         if {[string length $cwdWindow(dir_archives)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_archives)]
         }

         #--- je calcule la date du jour (a partir de l'heure TU)
         if { $cwdWindow(rep_images,refModeAuto) == "0" } {
            set heure_nouveau_repertoire "0"
         } else {
            set heure_nouveau_repertoire "12"
         }
         set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
         if { $heure_courante < $heure_nouveau_repertoire } {
            #--- Si on est avant l'heure de changement, je prends la date de la veille
            set cwdWindow(sous_repertoire_date) [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y%m%d" ]
         } else {
            #--- Sinon, je prends la date du jour
            set cwdWindow(sous_repertoire_date) [ clock format [ clock seconds ] -format "%Y%m%d" ]
         }

         createDialog
      }
   }

   #
   # ::cwdWindow::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption conf cwdWindow

      #--- Nom du sous-repertoire
      set date [clock format [clock seconds] -format "%y%m%d"]
      set cwdWindow(sous_repertoire) $date

      #---
      toplevel $This
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This "$caption(cwdWindow,repertoire)"
      wm protocol $This WM_DELETE_WINDOW ::cwdWindow::cmdClose

      #--- Initialisation des variables de changement
      set cwdWindow(rep_images)      "0"
      set cwdWindow(rep_travail)     "0"
      set cwdWindow(rep_scripts)     "0"
      set cwdWindow(rep_userCatalog) "0"
      set cwdWindow(rep_archives)    "0"

      #--- Frame pour les repertoires
      frame $This.usr -borderwidth 0 -relief raised

         #--- Frame du repertoire images
         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.a -borderwidth 0 -relief raised
               label $This.usr.1.a.lab1 -text "$caption(cwdWindow,repertoire_images)"
               pack $This.usr.1.a.lab1 -side left -padx 5 -pady 5
               button $This.usr.1.a.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command ::cwdWindow::changeRepImages
               pack $This.usr.1.a.explore -side right -padx 5 -pady 5 -ipady 5
               entry $This.usr.1.a.ent1 -textvariable cwdWindow(dir_images) -width $cwdWindow(long)
               pack $This.usr.1.a.ent1 -side right -padx 5 -pady 5
            pack $This.usr.1.a -side top -fill both -expand 1
            #---
            frame $This.usr.1.subdir -borderwidth 0 -relief groove
               #--- pas de sous repertoire
               radiobutton $This.usr.1.subdir.noneButton -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,label_sous_rep,aucun)" \
                  -value "none" \
                  -variable cwdWindow(rep_images,mode) \
                  -command ::cwdWindow::changeState
               grid $This.usr.1.subdir.noneButton -row 0 -column 0 -sticky wn
               #--- sous repertoire manuel
               radiobutton $This.usr.1.subdir.manualButton -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,label_sous_rep,fixe)" \
                  -value "manual" \
                  -variable cwdWindow(rep_images,mode) \
                  -command ::cwdWindow::changeState
               grid $This.usr.1.subdir.manualButton -row 1 -column 0 -sticky wn
               #--- Entry nouveau sous-repertoire
               entry $This.usr.1.subdir.manualEntry -textvariable cwdWindow(sous_repertoire) -width 30
               grid $This.usr.1.subdir.manualEntry -row 1 -column 3 -sticky wn
               #--- sous repertoire automatique (date du jour)
               radiobutton $This.usr.1.subdir.dateButton -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,label_sous_rep,date)" \
                  -value "date" \
                  -variable cwdWindow(rep_images,mode) \
                  -command ::cwdWindow::changeState
               grid $This.usr.1.subdir.dateButton -row 2 -column 0 -sticky wn
               radiobutton $This.usr.1.subdir.changeDateButton0h -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,changement_0h)" \
                  -value "0" \
                  -variable cwdWindow(rep_images,refModeAuto) \
                  -command ::cwdWindow::changeDateJour
               grid $This.usr.1.subdir.changeDateButton0h -row 2 -column 1 -sticky wn
               radiobutton $This.usr.1.subdir.changeDateButton12h -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,changement_12h)" \
                  -value "12" \
                  -variable cwdWindow(rep_images,refModeAuto) \
                  -command ::cwdWindow::changeDateJour
               grid $This.usr.1.subdir.changeDateButton12h -row 2 -column 2 -sticky wn
               #--- Entry date sous-repertoire
               entry $This.usr.1.subdir.dateEntry -textvariable cwdWindow(sous_repertoire_date) -width 12 \
                  -state readonly
               grid $This.usr.1.subdir.dateEntry -row 2 -column 3 -sticky wn
            pack $This.usr.1.subdir -side top -fill x -padx 12
         pack $This.usr.1 -side top -fill both -expand 1

         #--- Frame du repertoire de travail
         frame $This.usr.1a -borderwidth 1 -relief raised
            frame $This.usr.1a.a -borderwidth 0 -relief raised
               label $This.usr.1a.a.lab1a -text "$caption(cwdWindow,repertoire_travail)"
               pack $This.usr.1a.a.lab1a -side left -padx 5 -pady 5
               button $This.usr.1a.a.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command ::cwdWindow::changeRepTravail
               pack $This.usr.1a.a.explore -side right -padx 5 -pady 5 -ipady 5
               entry $This.usr.1a.a.ent1a -textvariable cwdWindow(dir_travail) -width $cwdWindow(long)
               pack $This.usr.1a.a.ent1a -side right -padx 5 -pady 5
            pack $This.usr.1a.a -side top -fill both -expand 1
            frame $This.usr.1a.b -borderwidth 0 -relief raised
               checkbutton $This.usr.1a.b.check1 -text "$caption(cwdWindow,travail_images)" \
                  -highlightthickness 0 -variable cwdWindow(travail_images) \
                  -command ::cwdWindow::changeState
               pack $This.usr.1a.b.check1 -anchor w -side left -padx 20 -pady 5
            pack $This.usr.1a.b -side top -fill both -expand 1
         pack $This.usr.1a -side top -fill both -expand 1
         #--- Configuration des widgets du repertoire de travail
         ::cwdWindow::changeState

         #--- Frame du repertoire des scripts
         frame $This.usr.2 -borderwidth 1 -relief raised
            label $This.usr.2.lab2 -text "$caption(cwdWindow,repertoire_scripts)"
            pack $This.usr.2.lab2 -side left -padx 5 -pady 5
            button $This.usr.2.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command ::cwdWindow::changeRepScripts
            pack $This.usr.2.explore -side right -padx 5 -pady 5 -ipady 5
            entry $This.usr.2.ent2 -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long)
            pack $This.usr.2.ent2 -side right -padx 5 -pady 5
         pack $This.usr.2 -side top -fill both -expand 1

         #--- Frame du repertoire des catalogues
         frame $This.usr.3 -borderwidth 1 -relief raised
            #--- Frame du repertoire des catalogues
            frame $This.usr.3.catalogues -borderwidth 0 -relief raised
               label $This.usr.3.catalogues.lab3 -text "$caption(cwdWindow,repertoire_catalogues)"
               pack $This.usr.3.catalogues.lab3 -side left -padx 5 -pady 5
               button $This.usr.3.catalogues.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog catalogues"
               pack $This.usr.3.catalogues.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.catalogues.ent3 -textvariable cwdWindow(dir_catalogues) -width $cwdWindow(long)
               pack $This.usr.3.catalogues.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.catalogues -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue MicroCat
            frame $This.usr.3.cata_microcat -borderwidth 0 -relief raised
               label $This.usr.3.cata_microcat.lab3 -text "$caption(cwdWindow,repertoire_cata_microcat)"
               pack $This.usr.3.cata_microcat.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_microcat.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_microcat"
               pack $This.usr.3.cata_microcat.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_microcat.ent3 -textvariable cwdWindow(dir_cata_microcat) -width $cwdWindow(long)
               pack $This.usr.3.cata_microcat.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_microcat -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue USNO-A2
            frame $This.usr.3.cata_usnoa2 -borderwidth 0 -relief raised
               label $This.usr.3.cata_usnoa2.lab3 -text "$caption(cwdWindow,repertoire_cata_usnoa2)"
               pack $This.usr.3.cata_usnoa2.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_usnoa2.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_usnoa2"
               pack $This.usr.3.cata_usnoa2.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_usnoa2.ent3 -textvariable cwdWindow(dir_cata_usnoa2) -width $cwdWindow(long)
               pack $This.usr.3.cata_usnoa2.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_usnoa2 -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue TYCHO-2
            frame $This.usr.3.cata_tycho2 -borderwidth 0 -relief raised
               label $This.usr.3.cata_tycho2.lab3 -text "$caption(cwdWindow,repertoire_cata_tycho2)"
               pack $This.usr.3.cata_tycho2.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_tycho2.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_tycho2"
               pack $This.usr.3.cata_tycho2.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_tycho2.ent3 -textvariable cwdWindow(dir_cata_tycho2) -width $cwdWindow(long)
               pack $This.usr.3.cata_tycho2.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_tycho2 -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue UCAC2
            frame $This.usr.3.cata_ucac2 -borderwidth 0 -relief raised
               label $This.usr.3.cata_ucac2.lab3 -text "$caption(cwdWindow,repertoire_cata_ucac2)"
               pack $This.usr.3.cata_ucac2.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_ucac2.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_ucac2"
               pack $This.usr.3.cata_ucac2.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_ucac2.ent3 -textvariable cwdWindow(dir_cata_ucac2) -width $cwdWindow(long)
               pack $This.usr.3.cata_ucac2.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_ucac2 -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue UCAC3
            frame $This.usr.3.cata_ucac3 -borderwidth 0 -relief raised
               label $This.usr.3.cata_ucac3.lab3 -text "$caption(cwdWindow,repertoire_cata_ucac3)"
               pack $This.usr.3.cata_ucac3.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_ucac3.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_ucac3"
               pack $This.usr.3.cata_ucac3.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_ucac3.ent3 -textvariable cwdWindow(dir_cata_ucac3) -width $cwdWindow(long)
               pack $This.usr.3.cata_ucac3.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_ucac3 -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue UCAC4
            frame $This.usr.3.cata_ucac4 -borderwidth 0 -relief raised
               label $This.usr.3.cata_ucac4.lab3 -text "$caption(cwdWindow,repertoire_cata_ucac4)"
               pack $This.usr.3.cata_ucac4.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_ucac4.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_ucac4"
               pack $This.usr.3.cata_ucac4.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_ucac4.ent3 -textvariable cwdWindow(dir_cata_ucac4) -width $cwdWindow(long)
               pack $This.usr.3.cata_ucac4.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_ucac4 -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue PPMX
            frame $This.usr.3.cata_ppmx -borderwidth 0 -relief raised
               label $This.usr.3.cata_ppmx.lab3 -text "$caption(cwdWindow,repertoire_cata_ppmx)"
               pack $This.usr.3.cata_ppmx.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_ppmx.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_ppmx"
               pack $This.usr.3.cata_ppmx.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_ppmx.ent3 -textvariable cwdWindow(dir_cata_ppmx) -width $cwdWindow(long)
               pack $This.usr.3.cata_ppmx.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_ppmx -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue PPMXL
            frame $This.usr.3.cata_ppmxl -borderwidth 0 -relief raised
               label $This.usr.3.cata_ppmxl.lab3 -text "$caption(cwdWindow,repertoire_cata_ppmxl)"
               pack $This.usr.3.cata_ppmxl.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_ppmxl.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_ppmxl"
               pack $This.usr.3.cata_ppmxl.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_ppmxl.ent3 -textvariable cwdWindow(dir_cata_ppmxl) -width $cwdWindow(long)
               pack $This.usr.3.cata_ppmxl.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_ppmxl -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue NOMAD1
            frame $This.usr.3.cata_nomad1 -borderwidth 0 -relief raised
               label $This.usr.3.cata_nomad1.lab3 -text "$caption(cwdWindow,repertoire_cata_nomad1)"
               pack $This.usr.3.cata_nomad1.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_nomad1.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_nomad1"
               pack $This.usr.3.cata_nomad1.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_nomad1.ent3 -textvariable cwdWindow(dir_cata_nomad1) -width $cwdWindow(long)
               pack $This.usr.3.cata_nomad1.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_nomad1 -side top -fill both -expand 1
            #--- Frame du repertoire du catalogue 2MASS
            frame $This.usr.3.cata_2mass -borderwidth 0 -relief raised
               label $This.usr.3.cata_2mass.lab3 -text "$caption(cwdWindow,repertoire_cata_2mass)"
               pack $This.usr.3.cata_2mass.lab3 -side left -padx 20 -pady 5
               button $This.usr.3.cata_2mass.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRepUserCatalog cata_2mass"
               pack $This.usr.3.cata_2mass.explore -side right -padx 5 -pady 0 -ipady 5
               entry $This.usr.3.cata_2mass.ent3 -textvariable cwdWindow(dir_cata_2mass) -width $cwdWindow(long)
               pack $This.usr.3.cata_2mass.ent3 -side right -padx 5 -pady 5
            pack $This.usr.3.cata_2mass -side top -fill both -expand 1
         pack $This.usr.3 -side top -fill both -expand 1

         #--- Frame du repertoire des archives
         frame $This.usr.4 -borderwidth 1 -relief raised
            label $This.usr.4.lab4 -text "$caption(cwdWindow,repertoire_archives)"
            pack $This.usr.4.lab4 -side left -padx 5 -pady 5
            button $This.usr.4.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command ::cwdWindow::changeRepArchives
            pack $This.usr.4.explore -side right -padx 5 -pady 5 -ipady 5
            entry $This.usr.4.ent4 -textvariable cwdWindow(dir_archives) -width $cwdWindow(long)
            pack $This.usr.4.ent4 -side right -padx 5 -pady 5
         pack $This.usr.4 -side top -fill both -expand 1

      pack $This.usr -side top -fill both -expand 1

      #--- Frame pour les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_7,ok)" -width 7 \
            -command ::cwdWindow::cmdOk
         if { $conf(ok+appliquer)=="1" } {
           pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_7,appliquer)" -width 8 \
            -command ::cwdWindow::cmdApply
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_7,fermer)" -width 7 \
            -command ::cwdWindow::cmdClose
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_7,aide)" -width 7 \
            -command ::cwdWindow::afficheAide
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      bind $This <Key-Return> {::cwdWindow::cmdOk}
      bind $This <Key-Escape> {::cwdWindow::cmdClose}

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::cwdWindow::changeDateJour
   # Initialise la date de changement de jour
   #
   proc changeDateJour { } {
      #--- je calcule la date du jour (a partir de l'heure TU)
      if { $::cwdWindow(rep_images,refModeAuto) == "0" } {
         set heure_nouveau_repertoire "0"
      } else {
         set heure_nouveau_repertoire "12"
      }
      set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
      if { $heure_courante < $heure_nouveau_repertoire } {
         #--- Si on est avant l'heure de changement, je prends la date de la veille
         set ::cwdWindow(sous_repertoire_date) [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y%m%d" ]
      } else {
         #--- Sinon, je prends la date du jour
         set ::cwdWindow(sous_repertoire_date) [ clock format [ clock seconds ] -format "%Y%m%d" ]
      }
   }

   #
   # ::cwdWindow::changeRepImages
   # Ouvre le navigateur pour choisir le repertoire des images
   #
   proc changeRepImages { } {
     variable This
      global audace caption cwdWindow

      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) $audace(font,Entry)
      #--- Transformation de la police en italique
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_images) "1"
      $This.usr.1.a.ent1 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir [file normalize $cwdWindow(dir_images)]
      set title $caption(cwdWindow,repertoire_images)
      set cwdWindow(dir_images) [file nativename [ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]]
      $This.usr.1.a.ent1 configure -textvariable cwdWindow(dir_images) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.1
      if { $cwdWindow(travail_images) == "1" } {
         set cwdWindow(dir_travail) $cwdWindow(dir_images)
      }
   }

   #
   # ::cwdWindow::changeRepTravail
   # Ouvre le navigateur pour choisir le repertoire de travail
   #
   proc changeRepTravail { } {
      variable This
      global audace caption cwdWindow

      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) $audace(font,Entry)
      #--- Transformation de la police en italique
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_travail) "1"
      $This.usr.1a.a.ent1a configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir [file normalize $cwdWindow(dir_travail)]
      set title $caption(cwdWindow,repertoire_travail)
      set cwdWindow(dir_travail) [file nativename [::cwdWindow::tkplus_chooseDir $initialdir $title $This ]]
      $This.usr.1a.a.ent1a configure -textvariable cwdWindow(dir_travail) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.1a.a
   }

   #
   # ::cwdWindow::changeRepScripts
   # Ouvre le navigateur pour choisir le repertoire des scripts
   #
   proc changeRepScripts { } {
      variable This
      global audace caption cwdWindow

      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) $audace(font,Entry)
      #--- Transformation de la police en italique
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_scripts) "1"
      $This.usr.2.ent2 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir [file normalize $cwdWindow(dir_scripts)]
      set title $caption(cwdWindow,repertoire_scripts)
      set cwdWindow(dir_scripts) [file nativename [::cwdWindow::tkplus_chooseDir $initialdir $title $This ]]
      $This.usr.2.ent2 configure -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.2
   }

   #
   # ::cwdWindow::changeRepUserCatalog
   # Ouvre le navigateur pour choisir le repertoire des catalogues
   #
   proc changeRepUserCatalog { nomCata } {
      variable This
      global audace caption cwdWindow

      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) $audace(font,Entry)
      #--- Transformation de la police en italique
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_userCatalog) "1"
      $This.usr.3.$nomCata.ent3 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir [file normalize $cwdWindow(dir_$nomCata)]
      set title $caption(cwdWindow,repertoire_$nomCata)
      set cwdWindow(dir_$nomCata) [file nativename [ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]]
      $This.usr.3.$nomCata.ent3 configure -textvariable cwdWindow(dir_$nomCata) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.3
   }

   #
   # ::cwdWindow::changeRepArchives
   # Ouvre le navigateur pour choisir le repertoire des archives
   #
   proc changeRepArchives { } {
      variable This
      global audace caption cwdWindow

      #--- Recuperation de la police par defaut des entry
      set cwdWindow(rep_font) $audace(font,Entry)
      #--- Transformation de la police en italique
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]
      #---
      set cwdWindow(rep_archives) "1"
      $This.usr.4.ent4 configure -font $cwdWindow(rep_font_italic) -relief solid
      set initialdir [file normalize $cwdWindow(dir_archives)]
      set title $caption(cwdWindow,repertoire_archives)
      set cwdWindow(dir_archives) [file nativename [ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]]
      $This.usr.4.ent4 configure -textvariable cwdWindow(dir_archives) -width $cwdWindow(long) \
         -font $cwdWindow(rep_font) -relief sunken
      focus $This.usr.4
   }

   #
   # ::cwdWindow::changeState
   # Change l'etat du widget : Disabled - Normal
   #
   proc changeState { } {
      variable This
      global cwdWindow

      if { $cwdWindow(travail_images) == "0" } {
         $This.usr.1a.a.ent1a configure -state normal
         $This.usr.1a.a.explore configure -state normal
         set cwdWindow(dir_travail) [ file nativename $::audace(rep_travail) ]
      } elseif { $cwdWindow(travail_images) == "1" } {
         $This.usr.1a.a.ent1a configure -state disabled
         $This.usr.1a.a.explore configure -state disabled
         switch $cwdWindow(rep_images,mode) {
            "none" {
               set dirName $cwdWindow(dir_images)
            }
            "manual" {
               set dirName [ file join $cwdWindow(dir_images) $cwdWindow(sous_repertoire) ]
            }
            "date" {
               set dirName [ file join $cwdWindow(dir_images) $cwdWindow(sous_repertoire_date) ]
            }
         }
         set cwdWindow(dir_travail) [ file nativename $dirName ]
      }
   }

   #
   # ::cwdWindow::tkplus_chooseDir [inidir] [title] [parent]
   # Navigateur pour le choix des repertoires
   #
   proc tkplus_chooseDir { inidir title parent } {
      global cwdWindow

      if {$inidir=="."} {
         set inidir [pwd]
      }
      if { $cwdWindow(rep_images) == "1" } {
         set cwdWindow(rep_images) "0"
      } elseif { $cwdWindow(rep_travail) == "1" } {
         set cwdWindow(rep_travail) "0"
      } elseif { $cwdWindow(rep_scripts) == "1" } {
         set cwdWindow(rep_scripts) "0"
      } elseif { $cwdWindow(rep_userCatalog) == "1" } {
         set cwdWindow(rep_userCatalog) "0"
      } elseif { $cwdWindow(rep_archives) == "1" } {
         set cwdWindow(rep_archives) "0"
      }
      set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]
      if {$res==""} {
         return "$inidir"
      } else {
         return "$res"
      }
   }

   #
   # ::cwdWindow::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      if {[cmdApply] == 0} {
         cmdClose
      }
   }

   #
   # ::cwdWindow::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      global audace caption conf cwdWindow

      #--- Substituer les \ par des /
      set normalized_dir_images        [file normalize $cwdWindow(dir_images)]
      set normalized_dir_travail       [file normalize $cwdWindow(dir_travail)]
      set normalized_dir_scripts       [file normalize $cwdWindow(dir_scripts)]
      set normalized_dir_catalogues    [file normalize $cwdWindow(dir_catalogues)]
      set normalized_dir_cata_microcat [file normalize $cwdWindow(dir_cata_microcat)]
      set normalized_dir_cata_usnoa2   [file normalize $cwdWindow(dir_cata_usnoa2)]
      set normalized_dir_cata_tycho2   [file normalize $cwdWindow(dir_cata_tycho2)]
      set normalized_dir_cata_ucac2    [file normalize $cwdWindow(dir_cata_ucac2)]
      set normalized_dir_cata_ucac3    [file normalize $cwdWindow(dir_cata_ucac3)]
      set normalized_dir_cata_ucac4    [file normalize $cwdWindow(dir_cata_ucac4)]
      set normalized_dir_cata_ppmx     [file normalize $cwdWindow(dir_cata_ppmx)]
      set normalized_dir_cata_ppmxl    [file normalize $cwdWindow(dir_cata_ppmxl)]
      set normalized_dir_cata_nomad1   [file normalize $cwdWindow(dir_cata_nomad1)]
      set normalized_dir_cata_2mass    [file normalize $cwdWindow(dir_cata_2mass)]
      set normalized_dir_archives      [file normalize $cwdWindow(dir_archives)]

      set conf(rep_travail,travail_images) $cwdWindow(travail_images)

      if { ![file exists $normalized_dir_images] || ![file isdirectory $normalized_dir_images]} {
         set message "$cwdWindow(dir_images)"
         append message "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $message -title "$caption(cwdWindow,boite_erreur)"
         return -1
      } else {
         switch $cwdWindow(rep_images,mode) {
            "none" {
               #--- rien a faire
               set dirName $normalized_dir_images
            }
            "manual" {
               set dirName [file join $normalized_dir_images $cwdWindow(sous_repertoire) ]
               if { ![file exists $dirName] } {
                  #--- je cree le repertoire
                  set catchError [catch {
                     file mkdir $dirName
                     set conf(rep_images,subdir) $cwdWindow(sous_repertoire)
                  }]
                  if { $catchError != 0 } {
                     ::tkutil::displayErrorInfo "$::caption(cwdWindow,label_sous_rep)"
                     return -1
                  }
               }
            }
            "date" {
               set dirName [file join $normalized_dir_images $cwdWindow(sous_repertoire_date) ]
               if { ![file exists $dirName] } {
                  #--- je cree le repertoire
                  set catchError [catch {
                     file mkdir $dirName
                  }]
                  if { $catchError != 0 } {
                     ::tkutil::displayErrorInfo "$::caption(cwdWindow,label_sous_rep)"
                     return -1
                  }
               }
            }
         }
         set conf(rep_images)             $normalized_dir_images
         set conf(rep_images,mode)        $cwdWindow(rep_images,mode)
         set conf(rep_images,refModeAuto) $cwdWindow(rep_images,refModeAuto)
         set audace(rep_images)           $dirName
         if { $conf(rep_travail,travail_images) == "1" } {
            set conf(rep_travail)         $audace(rep_images)
            set audace(rep_travail)       $audace(rep_images)
            set cwdWindow(dir_travail)    $audace(rep_images)
            #--- On se place dans le nouveau repertoire de travail
            cd $audace(rep_travail)
         } else {
            if {[file exists $normalized_dir_travail] && [file isdirectory $normalized_dir_travail]} {
               set conf(rep_travail)   $normalized_dir_travail
               set audace(rep_travail) $normalized_dir_travail
               #--- On se place dans le nouveau repertoire de travail
               cd $audace(rep_travail)
            } else {
               set m "$cwdWindow(dir_travail)"
               append m "$caption(cwdWindow,pas_repertoire)"
               tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
               return -1
            }
         }
      }

      if {[file exists $normalized_dir_scripts] && [file isdirectory $normalized_dir_scripts]} {
         set conf(rep_scripts)   $normalized_dir_scripts
         set audace(rep_scripts) $normalized_dir_scripts
      } else {
         set m "$cwdWindow(dir_scripts)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_catalogues] && [file isdirectory $normalized_dir_catalogues]} {
         set conf(rep_userCatalog)   $normalized_dir_catalogues
         set audace(rep_userCatalog) $normalized_dir_catalogues
      } else {
         set m "$cwdWindow(dir_catalogues)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_microcat] && [file isdirectory $normalized_dir_cata_microcat]} {
         set conf(rep_userCatalogMicrocat)   $normalized_dir_cata_microcat
         set audace(rep_userCatalogMicrocat) $normalized_dir_cata_microcat
      } else {
         set m "$cwdWindow(dir_cata_microcat)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_usnoa2] && [file isdirectory $normalized_dir_cata_usnoa2]} {
         set conf(rep_userCatalogUsnoa2)   $normalized_dir_cata_usnoa2
         set audace(rep_userCatalogUsnoa2) $normalized_dir_cata_usnoa2
      } else {
         set m "$cwdWindow(dir_cata_usnoa2)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_tycho2] && [file isdirectory $normalized_dir_cata_tycho2]} {
         set conf(rep_userCatalogTycho2)   $normalized_dir_cata_tycho2
         set audace(rep_userCatalogTycho2) $normalized_dir_cata_tycho2
      } else {
         set m "$cwdWindow(dir_cata_tycho2)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_ucac2] && [file isdirectory $normalized_dir_cata_ucac2]} {
         set conf(rep_userCatalogUcac2)   $normalized_dir_cata_ucac2
         set audace(rep_userCatalogUcac2) $normalized_dir_cata_ucac2
      } else {
         set m "$cwdWindow(dir_cata_ucac2)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_ucac3] && [file isdirectory $normalized_dir_cata_ucac3]} {
         set conf(rep_userCatalogUcac3)   $normalized_dir_cata_ucac3
         set audace(rep_userCatalogUcac3) $normalized_dir_cata_ucac3
      } else {
         set m "$cwdWindow(dir_cata_ucac3)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_ucac4] && [file isdirectory $normalized_dir_cata_ucac4]} {
         set conf(rep_userCatalogUcac4)   $normalized_dir_cata_ucac4
         set audace(rep_userCatalogUcac4) $normalized_dir_cata_ucac4
      } else {
         set m "$cwdWindow(dir_cata_ucac4)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_ppmx] && [file isdirectory $normalized_dir_cata_ppmx]} {
         set conf(rep_userCatalogPpmx)   $normalized_dir_cata_ppmx
         set audace(rep_userCatalogPpmx) $normalized_dir_cata_ppmx
      } else {
         set m "$cwdWindow(dir_cata_ppmx)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_ppmxl] && [file isdirectory $normalized_dir_cata_ppmxl]} {
         set conf(rep_userCatalogPpmxl)   $normalized_dir_cata_ppmxl
         set audace(rep_userCatalogPpmxl) $normalized_dir_cata_ppmxl
      } else {
         set m "$cwdWindow(dir_cata_ppmxl)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_nomad1] && [file isdirectory $normalized_dir_cata_nomad1]} {
         set conf(rep_userCatalogNomad1)   $normalized_dir_cata_nomad1
         set audace(rep_userCatalogNomad1) $normalized_dir_cata_nomad1
      } else {
         set m "$cwdWindow(dir_cata_nomad1)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_cata_2mass] && [file isdirectory $normalized_dir_cata_2mass]} {
         set conf(rep_userCatalog2mass)   $normalized_dir_cata_2mass
         set audace(rep_userCatalog2mass) $normalized_dir_cata_2mass
      } else {
         set m "$cwdWindow(dir_cata_2mass)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      if {[file exists $normalized_dir_archives] && [file isdirectory $normalized_dir_archives]} {
         set conf(rep_archives)   $normalized_dir_archives
         set audace(rep_archives) $normalized_dir_archives
      } else {
         set m "$cwdWindow(dir_archives)"
         append m "$caption(cwdWindow,pas_repertoire)"
         tk_messageBox -message $m -title "$caption(cwdWindow,boite_erreur)"
         return -1
      }

      return 0
   }

   #
   # ::cwdWindow::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1020repertoire.htm"
   }

   #
   # ::cwdWindow::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This
      global cwdWindow

      set cwdWindow(geometry) [wm geometry $This]
      destroy $This
      unset This
   }

   #
   # ::cwdWindow::updateImageDirectory
   # Test de l'existence d'un repertoire avec creation du repertoire s'il n'existe pas
   #
   proc updateImageDirectory { } {
      if { $::conf(rep_images,mode) == "date" } {
         #--- Je calcule la date du jour (a partir de l'heure TU)
         if { $::conf(rep_images,refModeAuto) == "0" } {
            set heure_nouveau_repertoire "0"
         } else {
            set heure_nouveau_repertoire "12"
         }
         set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
         if { $heure_courante < $heure_nouveau_repertoire } {
            #--- Si on est avant l'heure de changement, je prends la date de la veille
            set ::cwdWindow(sous_repertoire_date) [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y%m%d" ]
         } else {
            #--- Sinon, je prends la date du jour
            set ::cwdWindow(sous_repertoire_date) [ clock format [ clock seconds ] -format "%Y%m%d" ]
         }

         #--- Substituer les \ par des /
         set normalized_dir_images [ file normalize $::conf(rep_images) ]

         #--- Creation du sous-repertoire du jour s'il n'existe pas
         set dirName [ file join $normalized_dir_images $::cwdWindow(sous_repertoire_date) ]
         if { ![ file exists $dirName ] } {
            #--- je cree le repertoire
            set catchError [catch {
               file mkdir $dirName
            }]
            if { $catchError != 0 } {
               ::tkutil::displayErrorInfo "$::caption(cwdWindow,label_sous_rep)"
               return
            }
         }
         set ::audace(rep_images) $dirName
      }
   }

}

########################### Fin du namespace cwdWindow ############################

namespace eval ::confEditScript {

   #
   # confEditScript::run this
   # Cree la fenetre de configuration de l'editeur de scripts, de fichiers pdf, de pages html et d'images
   # this : Chemin de la fenetre
   #
   proc run { this } {
      variable This
      global confgene

      set This $this

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      updateData
      createDialog
      focus $This

      if { [ info exists confgene(EditScript,geometry) ] } {
         wm geometry $This $confgene(EditScript,geometry)
      }

      tkwait visibility $This
      tkwait variable confgene(EditScript,ok)
      catch { destroy $This }

      return $confgene(EditScript,ok)
   }

   #
   # ::confEditScript::initConf
   # Initialisation de variables dans aud.tcl (::audace::loadSetup) pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      #--- Initialisation
      if { ! [ info exists conf(editsite_htm,selectHelp) ] } { set conf(editsite_htm,selectHelp) "0" }
   }

   #
   # ::confEditScript::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption conf confgene

      #--- Recuperation de la police par defaut des entry
      set confgene(EditScript,edit_font)        "$audace(font,Entry)"
      #--- Transformation de la police en italique
      set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
      #--- Changement de variable
      set confgene(EditScript,selectHelp)       "$conf(editsite_htm,selectHelp)"

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(confeditscript,logiciels_externes)"
      wm geometry $This +180+50
      wm protocol $This WM_DELETE_WINDOW ::confEditScript::cmdClose

      #--- Ecriture du chemin d'un repertoire et du nom d'un lecteur
      if { $::tcl_platform(os) == "Linux" } {
         set confgene(EditScript,path) [ file join / usr bin ]
      } else {
         set defaultpath [ file join C: "Program Files" ]
         catch {
            set testpath "$::env(ProgramFiles)"
            set kend [expr [string length $testpath]-1]
            for {set k 0} {$k<=$kend} {incr k} {
               set car [string index "$testpath" $k]
               if {$car=="\\"} {
                  set testpath [string replace "$testpath" $k $k /]
               }
            }
            set defaultpath "$testpath"
            }
         set confgene(EditScript,path)  "$defaultpath"
         set confgene(EditScript,drive) [ lindex [ file split "$confgene(EditScript,path)" ] 0 ]
      }

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Editeur de scripts
      frame $This.usr1 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_script) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr1.lab1 -text "$caption(confeditscript,edit_script)"
         pack $This.usr1.lab1 -side left -padx 5 -pady 5
         button $This.usr1.explore1 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr1.ent1 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_script) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "6" ]
               if { $confgene(EditScript,edit_script) == "" } {
                  set confgene(EditScript,edit_script) $conf(editscript)
               }
               focus $::confEditScript::This.usr1
               $::confEditScript::This.usr1.ent1 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr1.explore1 -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr1.ent1 -textvariable confgene(EditScript,edit_script) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr1.ent1 -side right -padx 5 -pady 5
      pack $This.usr1 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Editeur de documents pdf
      frame $This.usr2 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_pdf) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr2.lab2 -text "$caption(confeditscript,notice_pdf)"
         pack $This.usr2.lab2 -side left -padx 5 -pady 5
         button $This.usr2.explore2 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr2.ent2 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_pdf) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "7" ]
               if { $confgene(EditScript,edit_pdf) == "" } {
                  set confgene(EditScript,edit_pdf) $conf(editnotice_pdf)
               }
               focus $::confEditScript::This.usr2
               $::confEditScript::This.usr2.ent2 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr2.explore2 -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr2.ent2 -textvariable confgene(EditScript,edit_pdf) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr2.ent2 -side right -padx 5 -pady 5
      pack $This.usr2 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Navigateur de pages htm
      frame $This.usr3 -borderwidth 1 -relief raised
         frame $This.usr3.top -borderwidth 0 -relief raised
            #--- Positionne le bouton ... et la zone a renseigner
            if { $confgene(EditScript,error_htm) == "1" } {
               set font $confgene(EditScript,edit_font)
               set relief "sunken"
            } else {
               set font $confgene(EditScript,edit_font_italic)
               set relief "solid"
            }
            label $This.usr3.top.lab3 -text "$caption(confeditscript,navigateur_htm)"
            pack $This.usr3.top.lab3 -side left -padx 5 -pady 5
            button $This.usr3.top.explore3 -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command {
                  #--- Recuperation de la police par defaut des entry
                  set confgene(EditScript,edit_font)        "$audace(font,Entry)"
                  #--- Transformation de la police en italique
                  set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
                  #---
                  $::confEditScript::This.usr3.top.ent3 configure -font $confgene(EditScript,edit_font_italic) -relief solid
                  set fenetre "$::confEditScript::This"
                  set confgene(EditScript,edit_htm) \
                     [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "8" ]
                  if { $confgene(EditScript,edit_htm) == "" } {
                     set confgene(EditScript,edit_htm) $conf(editsite_htm)
                  }
                  focus $::confEditScript::This.usr3
                  $::confEditScript::This.usr3.top.ent3 configure -font $confgene(EditScript,edit_font) -relief sunken
               }
            pack $This.usr3.top.explore3 -side right -padx 5 -pady 5 -ipady 5
            entry $This.usr3.top.ent3 -textvariable confgene(EditScript,edit_htm) -width $confgene(EditScript,long) \
               -font $font -relief $relief
            pack $This.usr3.top.ent3 -side right -padx 5 -pady 5
         pack $This.usr3.top -side top -fill x -expand 1
         frame $This.usr3.bottom -borderwidth 0 -relief raised
            checkbutton $This.usr3.bottom.selectHelp -text "$caption(confeditscript,selectHelp)" \
               -highlightthickness 0 -variable confgene(EditScript,selectHelp)
            pack $This.usr3.bottom.selectHelp -anchor w -side bottom -padx 20 -pady 5
         pack $This.usr3.bottom -side top -fill x -expand 1
      pack $This.usr3 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Visualiseur d'images
      frame $This.usr4 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_viewer) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr4.lab4 -text "$caption(confeditscript,viewer)"
         pack $This.usr4.lab4 -side left -padx 5 -pady 5
         button $This.usr4.explore4 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr4.ent4 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_viewer) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "9" ]
               if { $confgene(EditScript,edit_viewer) == "" } {
                  set confgene(EditScript,edit_viewer) $conf(edit_viewer)
               }
               focus $::confEditScript::This.usr4
               $::confEditScript::This.usr4.ent4 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr4.explore4 -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr4.ent4 -textvariable confgene(EditScript,edit_viewer) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr4.ent4 -side right -padx 5 -pady 5
      pack $This.usr4 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Java
      frame $This.usr5 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_java) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr5.lab -text "$caption(confeditscript,exec_java)"
         pack $This.usr5.lab -side left -padx 5 -pady 5
         button $This.usr5.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr5.ent configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,exec_java) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "12" ]
               if { $confgene(EditScript,exec_java) == "" } {
                  set confgene(EditScript,exec_java) $conf(exec_java)
               }
               focus $::confEditScript::This.usr5
               $::confEditScript::This.usr5.ent configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr5.explore -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr5.ent -textvariable confgene(EditScript,exec_java) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr5.ent -side right -padx 5 -pady 5
      pack $This.usr5 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Aladin
      frame $This.usr6 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_aladin) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr6.lab -text "$caption(confeditscript,exec_aladin)"
         pack $This.usr6.lab -side left -padx 5 -pady 5
         button $This.usr6.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr6.ent configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,exec_aladin) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "13" ]
               if { $confgene(EditScript,exec_aladin) == "" } {
                  set confgene(EditScript,exec_aladin) $conf(exec_aladin)
               }
               focus $::confEditScript::This.usr6
               $::confEditScript::This.usr6.ent configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr6.explore -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr6.ent -textvariable confgene(EditScript,exec_aladin) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr6.ent -side right -padx 5 -pady 5
      pack $This.usr6 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Iris (pour Windows uniquement)
      if { $::tcl_platform(os) == "Windows NT" } {
         frame $This.usr7 -borderwidth 1 -relief raised
            #--- Positionne le bouton ... et la zone a renseigner
            if { $confgene(EditScript,error_iris) == "1" } {
               set font $confgene(EditScript,edit_font)
               set relief "sunken"
            } else {
               set font $confgene(EditScript,edit_font_italic)
               set relief "solid"
            }
            label $This.usr7.lab -text "$caption(confeditscript,exec_iris)"
            pack $This.usr7.lab -side left -padx 5 -pady 5
            button $This.usr7.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command {
                  #--- Recuperation de la police par defaut des entry
                  set confgene(EditScript,edit_font)        "$audace(font,Entry)"
                  #--- Transformation de la police en italique
                  set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
                  #---
                  $::confEditScript::This.usr7.ent configure -font $confgene(EditScript,edit_font_italic) -relief solid
                  set fenetre "$::confEditScript::This"
                  set confgene(EditScript,exec_iris) \
                     [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "12" ]
                  if { $confgene(EditScript,exec_iris) == "" } {
                     set confgene(EditScript,exec_iris $conf(exec_iris)
                  }
                  focus $::confEditScript::This.usr7
                  $::confEditScript::This.usr7.ent configure -font $confgene(EditScript,edit_font) -relief sunken
               }
            pack $This.usr7.explore -side right -padx 5 -pady 5 -ipady 5
            entry $This.usr7.ent -textvariable confgene(EditScript,exec_iris) -width $confgene(EditScript,long) \
               -font $font -relief $relief
            pack $This.usr7.ent -side right -padx 5 -pady 5
         pack $This.usr7 -side top -fill both -expand 1
      }

      #--- Cree un frame pour y mettre les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         #--- Cree le bouton 'OK'
         button $This.cmd.ok -text "$caption(aud_menu_7,ok)" -width 7 -command ::confEditScript::cmdOk
         pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Fermer'
         button $This.cmd.fermer -text "$caption(aud_menu_7,fermer)" -width 7 -command ::confEditScript::cmdClose
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Aide'
         button $This.cmd.aide -text "$caption(aud_menu_7,aide)" -width 7 -command ::confEditScript::afficheAide
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::confEditScript::updateData
   # Mise a jour automatique de la longueur des entry
   #
   proc updateData { } {
      global conf confgene

      catch {
         set confgene(EditScript,edit_script) $conf(editscript)
         set confgene(EditScript,long)        [ string length $confgene(EditScript,edit_script) ]
      }
      if { ! [ info exists confgene(EditScript,edit_script) ] } { set confgene(EditScript,long) "30" }
      catch {
         set confgene(EditScript,edit_pdf) $conf(editnotice_pdf)
         set confgene(EditScript,long_pdf) [ string length $confgene(EditScript,edit_pdf) ]
      }
      if { ! [ info exists confgene(EditScript,edit_pdf) ] } { set confgene(EditScript,long_pdf) "30" }
      catch {
         set confgene(EditScript,edit_htm) $conf(editsite_htm)
         set confgene(EditScript,long_htm) [ string length $confgene(EditScript,edit_htm) ]
      }
      if { ! [ info exists confgene(EditScript,edit_htm) ] } { set confgene(EditScript,long_htm) "30" }
      catch {
         set confgene(EditScript,edit_viewer) $conf(edit_viewer)
         set confgene(EditScript,long_viewer) [ string length $confgene(EditScript,edit_viewer) ]
      }
      if { ! [ info exists confgene(EditScript,edit_viewer) ] } { set confgene(EditScript,long_viewer) "30" }
      catch {
         set confgene(EditScript,exec_java) $conf(exec_java)
         set confgene(EditScript,long_java) [ string length $confgene(EditScript,exec_java) ]
      }
      if { ! [ info exists confgene(EditScript,exec_java) ] } { set confgene(EditScript,long_java) "30" }
      catch {
         set confgene(EditScript,exec_aladin) $conf(exec_aladin)
         set confgene(EditScript,long_aladin) [ string length $confgene(EditScript,exec_aladin) ]
      }
      if { ! [ info exists confgene(EditScript,exec_aladin) ] } { set confgene(EditScript,long_aladin) "30" }
      if { $::tcl_platform(os) == "Windows NT" } {
         catch {
            set confgene(EditScript,exec_iris) $conf(exec_iris)
            set confgene(EditScript,long_iris) [ string length $confgene(EditScript,exec_iris) ]
         }
         if { ! [ info exists confgene(EditScript,exec_iris) ] } { set confgene(EditScript,long_iris) "30" }
      }

      if { $confgene(EditScript,long_pdf) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_pdf)
      }
      if { $confgene(EditScript,long_htm) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_htm)
      }
      if { $confgene(EditScript,long_viewer) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_viewer)
      }
      if { $confgene(EditScript,long_java) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_java)
      }
      if { $confgene(EditScript,long_aladin) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_aladin)
      }
      if { $::tcl_platform(os) == "Windows NT" } {
         if { $confgene(EditScript,long_iris) > $confgene(EditScript,long) } {
            set confgene(EditScript,long) $confgene(EditScript,long_iris)
         }
      }
      set confgene(EditScript,long) [expr $confgene(EditScript,long) + 3]
   }

   #
   # ::confEditScript::destroyDialog
   # Procedure correspondant a la fermeture de la fenetre
  #
   proc destroyDialog { } {
      variable This
      global confgene

      set confgene(EditScript,geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

   #
   # ::confEditScript::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      global conf confgene

      #---
      set conf(editscript)                  "$confgene(EditScript,edit_script)"
      set conf(editnotice_pdf)              "$confgene(EditScript,edit_pdf)"
      set conf(editsite_htm)                "$confgene(EditScript,edit_htm)"
      set conf(editsite_htm,selectHelp)     "$confgene(EditScript,selectHelp)"
      set conf(edit_viewer)                 "$confgene(EditScript,edit_viewer)"
      set conf(exec_java)                   "$confgene(EditScript,exec_java)"
      set conf(exec_aladin)                 "$confgene(EditScript,exec_aladin)"
      if { $::tcl_platform(os) == "Windows NT" } {
         set conf(exec_iris)                "$confgene(EditScript,exec_iris)"
      }
      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      set confgene(EditScript,error_iris)   "1"
      #---
      set confgene(EditScript,ok)           "1"
      ::confEditScript::destroyDialog
   }

   #
   # ::confEditScript::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1030logiciels_externes.htm"
   }

   #
   # ::confEditScript::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      global confgene

      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      set confgene(EditScript,error_iris)   "1"
      #---
      set confgene(EditScript,ok)           "0"
      ::confEditScript::destroyDialog
   }

}

######################### Fin du namespace confEditScript #########################

namespace eval ::audace {

   #
   # ::audace::enregistrerConfiguration
   # Demande la confirmation pour enregistrer la configuration
   #
   proc enregistrerConfiguration { } {
      variable private
      global audace caption conf

      #---
      menustate disabled
      #--- Positions et tailles des fenetres
      #--- Je recupere les visuNo des visu ouvertes
      set list_visuNo [list ]
      foreach visuNo [::visu::list] {
         lappend list_visuNo "$visuNo"
      }
      foreach visuNo $list_visuNo {
         if { $visuNo == 1 } {
            set conf(audace,visu$visuNo,wmgeometry) [ wm geometry $audace(base) ]
         } else {
            set conf(audace,visu$visuNo,wmgeometry) [ wm geometry $::confVisu::private($visuNo,This) ]
         }
      }
      set conf(console,wmgeometry) [ wm geometry $audace(Console) ]

      #---
      set filename [ file join $::audace(rep_home) audace.ini ]
      set filebak  [ file join $::audace(rep_home) audace.bak ]
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ini_getArrayFromFile $filename]

      if {[ini_fileNeedWritten file_conf conf]} {
         set choice [ tk_messageBox -message "$caption(audace,enregistrer_config3)" \
            -title "$caption(audace,enregistrer_config1)" -icon question -type yesno ]
         if { $choice == "yes" } {
            #--- Enregistrer la configuration
            ini_writeIniFile $filename2 conf
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            ::console::affiche_resultat "$caption(audace,enregistrer_config2)\n\n"
         }
      } else {
         #--- Pas d'enregistrement
         ::console::affiche_resultat "$caption(audace,enregistrer_config2)\n\n"
      }
      #---
      menustate normal
      #---
      focus $audace(base)
   }

}

############################# Fin du namespace audace #############################

