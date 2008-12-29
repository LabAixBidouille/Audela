#
# Fichier : modpoi.tcl
# Description : Wizard pour calculer un modele de pointage pour telescope
# Auteur : Alain KLOTZ
# Mise a jour $Id: modpoi.tcl,v 1.21 2008-12-29 11:49:34 robertdelmas Exp $
#
# 1) Pour initialiser le script :
#    source modpoi.tcl
#    * La determination du modele de pointage est realisee a partir de n etoiles (n = 8).
#    * Lancer le wizard (cf. point 2).
#
# 2) Pour lancer le wizard :
#    modpoi_wiz
#    * A la fin :
#      ** Les 10 coefficients du modele sont ecrits dans le fichier modpoi_res.txt
#      ** Le fichier modpoi_test.txt est constitue de 8 lignes et comprend les 6
#         colonnes suivantes :
#         col-1 : angle horaire theorique (degres)
#         col-2 : declinaison theorique (degres)
#         col-3 : ecart sur RA  tel-cat observe (arcmin)
#         col-4 : ecart sur DEC tel-cat observe (arcmin)
#         col-5 : ecart sur RA  tel-cat calcule par le modele (arcmin)
#         col-6 : ecart sur DEC tel-cat calcule par le modele (arcmin)
#         La valeur des differences entre les colonnes 3 et 5 correspond a
#         l'erreur de pointage en RA une fois le modele applique.
#         La valeur des differences entre les colonnes 4 et 6 correspond a
#         l'erreur de pointage en DEC une fois le modele applique.
#      ** L'objet telescope effectuera automatiquement les corrections du modele
#         lors des pointages et des lectures des coordonnees.
#
# 3) Pour charger un modele de pointage existant
#    source modpoi.tcl
#    modpoi_load "modpoi_res.txt"
#    * Le fichier doit etre du type modpoi_res.txt genere par le wizard.
#    * L'objet telescope effectuera automatiquement les corrections du modele
#      lors des pointages et des lectures des coordonnees.
#
######################################################################################

#--- Chargement des captions
global audace
global modpoi

set modpoi(stars,nb) ""
source [ file join $audace(rep_plugin) tool modpoi modpoi.cap ]

proc Chargement_Var { } {
   variable parametres
   global audace modpoi

   #---
   if { [ info exists modpoi(var,home) ] == "0" } {
      if { [ info exists audace(posobs,observateur,gps) ] == "1" } {
         set modpoi(var,home) $audace(posobs,observateur,gps)
      } else {
         set modpoi(var,home) "GPS 2 E 48 0"
      }
   }
   #--- Ouverture du fichier de parametres
   set fichier [ file join $audace(rep_plugin) tool modpoi modpoi.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }
   if { ! [ info exists parametres(modpoi,position) ] }    { set parametres(modpoi,position)    "+130+10" }
   if { ! [ info exists parametres(modpoi,nb_stars) ] }    { set parametres(modpoi,nb_stars)    "8" }
   if { ! [ info exists parametres(modpoi,catalog) ] }     { set parametres(modpoi,catalog)     "cat_105_etoiles.txt" }
   if { ! [ info exists parametres(modpoi,heast) ] }       { set parametres(modpoi,heast)       "-60." }
   if { ! [ info exists parametres(modpoi,hwest) ] }       { set parametres(modpoi,hwest)       "60." }
   set latitude [ lindex $modpoi(var,home) 3 ]
   if { $latitude >= "0" } {
      if { ! [ info exists parametres(modpoi,decmax) ] }   { set parametres(modpoi,decmax)      "50." }
      set decmin [ expr 35.-( 90.-$latitude ) ]
      if { ! [ info exists parametres(modpoi,decmin) ] }   { set parametres(modpoi,decmin)      "$decmin" }
   } else {
      set decmax [ expr -35.-( -90.-$latitude ) ]
      if { ! [ info exists parametres(modpoi,decmax) ] }   { set parametres(modpoi,decmax)      "$decmax" }
      if { ! [ info exists parametres(modpoi,decmin) ] }   { set parametres(modpoi,decmin)      "-50." }
   }

   if { ! [ info exists parametres(centering,xc) ] }       { set parametres(centering,xc)       "0" }
   if { ! [ info exists parametres(centering,yc) ] }       { set parametres(centering,yc)       "0" }
   if { ! [ info exists parametres(centering,accuracy) ] } { set parametres(centering,accuracy) "1.5" }
   if { ! [ info exists parametres(centering,t0) ] }       { set parametres(centering,t0)       "2000" }
   if { ! [ info exists parametres(centering,binning) ] }  { set parametres(centering,binning)  "1" }
   if { ! [ info exists parametres(centering,exptime) ] }  { set parametres(centering,exptime)  "1" }
   if { ! [ info exists parametres(centering,nbmean) ] }   { set parametres(centering,nbmean)   "1" }
}

proc Enregistrement_Var { } {
   variable parametres
   global audace modpoi

   set parametres(modpoi,position)       $modpoi(toplevel,position)
   set parametres(modpoi,nb_stars)       $modpoi(stars,nb)
   set parametres(modpoi,catalog)        $modpoi(stars,catalog)
   set parametres(modpoi,heast)          $modpoi(stars,heast)
   set parametres(modpoi,hwest)          $modpoi(stars,hwest)
   set parametres(modpoi,decmax)         $modpoi(stars,decmax)
   set parametres(modpoi,decmin)         $modpoi(stars,decmin)

   if { $modpoi(centering,check) == "1" } {
      set parametres(centering,xc)       $modpoi(centering,xc)
      set parametres(centering,yc)       $modpoi(centering,yc)
      set parametres(centering,accuracy) $modpoi(centering,accuracy)
      set parametres(centering,t0)       $modpoi(centering,t0)
      set parametres(centering,binning)  $modpoi(centering,binning)
      set parametres(centering,exptime)  $modpoi(centering,exptime)
      set parametres(centering,nbmean)   $modpoi(centering,nbmean)
   }

   #--- Sauvegarde des parametres
   catch {
      set nom_fichier [ file join $audace(rep_plugin) tool modpoi modpoi.ini ]
      if [ catch { open $nom_fichier w } fichier ] {
         #---
      } else {
         foreach { a b } [ array get parametres ] {
         puts $fichier "set parametres($a) \"$b\""
      }
      close $fichier
      }
   }
}

#
# recup_position
# Permet de recuperer et de sauvegarder la position de la fenetre principale
#
proc recup_position { } {
   variable parametres
   global modpoi

   set modpoi(wm_geometry) [ wm geometry $modpoi(g,base) ]
   set deb [ expr 1 + [ string first + $modpoi(wm_geometry) ] ]
   set fin [ string length $modpoi(wm_geometry) ]
   set modpoi(toplevel,position) "+[ string range $modpoi(wm_geometry) $deb $fin ]"
   #---
   set parametres(modpoi,position) $modpoi(toplevel,position)
}

proc modpoi_wiz { { mode new } } {
   variable parametres
   global audace modpoi

   if {$mode=="new"} {
      catch {unset modpoi}
   }
   load libgsltcl[info sharedlibextension]
   #--- Detection of the Aud'ACE environnement
   if {[info exists modpoi(var,home)]==0} {
      if {[info exists audace(posobs,observateur,gps)]==1} {
         set modpoi(var,home) $audace(posobs,observateur,gps)
      } else {
         set modpoi(var,home) "GPS 2 E 48 0"
      }
   }

   #--- Mode de centrage (automatique ou manuel)
   set modpoi(centering,check) 0
   #--- Const init
   set modpoi(centering,star_index) 0
   #--- Param init
   #--- Nombre d'étoiles pointées
   set modpoi(stars,nb) "$parametres(modpoi,nb_stars)"
   #--- Accuracy of automatic recentering
   set modpoi(centering,accuracy) "$parametres(centering,accuracy)"
   #--- Initial delay of slew for calibration
   set modpoi(centering,t0) "$parametres(centering,t0)"
   #---
   set modpoi(centering,nbmean) "$parametres(centering,nbmean)"

   modpoi_paraminit

   set modpoi(starname,choosen) ""

   set modpoi(pi) 3.1415926535897
   set modpoi(deg2rad) [expr $modpoi(pi)/180.]
   set modpoi(rad2deg) [expr 180./$modpoi(pi)]

   #---
   set modpoi(toplevel,position) $parametres(modpoi,position)

   if {[info exists modpoi(wm_geometry)]==0} {
      if { $::tcl_platform(os) == "Linux" } {
         set modpoi(wm_geometry) "560x680$modpoi(toplevel,position)"
      } else {
         set modpoi(wm_geometry) "440x500$modpoi(toplevel,position)"
      }
   }
   set modpoi(g,base) $audace(base).modpoi_fntr

   if {$mode=="edit"} {
      modpoi_wiz5b
   } elseif {$mode=="new"} {
      modpoi_wiz1
   }
}

proc modpoi_wiz1 { } {
   global caption modpoi

   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #---
   if { [ info exists modpoi(wm_geometry) ] } {
      set deb [ expr 1 + [ string first + $modpoi(wm_geometry) ] ]
      set fin [ string length $modpoi(wm_geometry) ]
      set modpoi(toplevel,position) "+[ string range $modpoi(wm_geometry) $deb $fin ]"
   }
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) $caption(modpoi,wiz1,title)
   #--- Title
   label $modpoi(g,base).lab_title2 \
   -text $caption(modpoi,wiz1,title2) \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_title2 \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Describe
   label $modpoi(g,base).lab_desc \
   -text $caption(modpoi,wiz1,desc) -borderwidth 2 \
   -padx 20 -pady 10
   pack $modpoi(g,base).lab_desc \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- NEXT button
   button $modpoi(g,base).but_next \
   -text $caption(modpoi,wiz1,next) -borderwidth 2 \
   -padx 20 -pady 10 -command { modpoi_wiz1b }
   pack $modpoi(g,base).but_next \
   -side bottom -anchor center \
   -padx 5 -pady 10 -expand 0
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
}

proc modpoi_wiz1b { } {
   variable parametres
   global audace caption modpoi

   #--- Parameters entries
   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #--- Initialisation des variables
   set modpoi(stars,heast)  "$parametres(modpoi,heast)"
   set modpoi(stars,hwest)  "$parametres(modpoi,hwest)"
   set modpoi(stars,decmin) "$parametres(modpoi,decmin)"
   set modpoi(stars,decmax) "$parametres(modpoi,decmax)"
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) $caption(modpoi,wiz1b,title)
   #--- Title
   label $modpoi(g,base).lab_title1b \
   -text $caption(modpoi,wiz1b,title2) \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_title1b \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #---
   #--- Limite angle horaire est, west
   #--- Limite declinaison nord, sud
   #--- Nombre d'etoiles (>=5 ?)
   #--- Centrage automatique
   #--- Binning, exptime
   #--- Coordonnées du centre de l'image (x,y)
   #---
   #--- Limite angle horaire est, west
   frame $modpoi(g,base).fra_hlim
      #--- Label heast
      label $modpoi(g,base).fra_hlim.lab_heast \
      -text "   $caption(modpoi,wiz1b,heast) " -borderwidth 2 \
      -padx 0 -pady 3
      pack $modpoi(g,base).fra_hlim.lab_heast \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry heast
      set modpoi(stars,heast) "[ format "%4.1f" $modpoi(stars,heast) ]"
      entry $modpoi(g,base).fra_hlim.ent_heast \
      -textvariable modpoi(stars,heast) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_hlim.ent_heast \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Label hwest
      label $modpoi(g,base).fra_hlim.lab_hwest \
      -text "    $caption(modpoi,wiz1b,hwest) " -borderwidth 2 \
      -padx 0 -pady 3
      pack $modpoi(g,base).fra_hlim.lab_hwest \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry hwest
      set modpoi(stars,hwest) "[ format "%4.1f" $modpoi(stars,hwest) ]"
      entry $modpoi(g,base).fra_hlim.ent_hwest \
      -textvariable modpoi(stars,hwest) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_hlim.ent_hwest \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_hlim \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Limit declination north, south
   frame $modpoi(g,base).fra_dlim
      #--- Label decinf
      label $modpoi(g,base).fra_dlim.lab_decinf \
      -text "   $caption(modpoi,wiz1b,decinf) " -borderwidth 2 \
      -padx 0 -pady 3
      pack $modpoi(g,base).fra_dlim.lab_decinf \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry decinf
      set modpoi(stars,decmin) "[ format "%4.1f" $modpoi(stars,decmin) ]"
      entry $modpoi(g,base).fra_dlim.ent_decinf \
      -textvariable modpoi(stars,decmin) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_dlim.ent_decinf \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Label decsup
      label $modpoi(g,base).fra_dlim.lab_decsup \
      -text "    $caption(modpoi,wiz1b,decsup) " -borderwidth 2 \
      -padx 0 -pady 3
      pack $modpoi(g,base).fra_dlim.lab_decsup \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry decsuo
      set modpoi(stars,decmax) "[ format "%4.1f" $modpoi(stars,decmax) ]"
      entry $modpoi(g,base).fra_dlim.ent_decsup \
      -textvariable modpoi(stars,decmax) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_dlim.ent_decsup \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_dlim \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Star catalog
   frame $modpoi(g,base).fra_star_catalog
      #--- Label nstars
      label $modpoi(g,base).fra_star_catalog.lab_star_catalog \
      -text "   $caption(modpoi,wiz1b,catalog) " -borderwidth 2 \
      -padx 0 -pady 10
      pack $modpoi(g,base).fra_star_catalog.lab_star_catalog \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Recherche des catalogues d'etoiles disponibles pour le calcul du modele de pointage
      set catamodpoi      ""
      set list_catamodpoi ""
      set list_fichier [ glob -nocomplain -dir [ file join $audace(rep_plugin) tool modpoi cata_modpoi ] *.txt ]
      for { set i 0 } { $i <= [ expr [ llength $list_fichier ] - 1 ] } { incr i } {
         set catamodpoi [ file tail [ lindex $list_fichier $i ] ]
         lappend list_catamodpoi "$catamodpoi"
      }
      #--- On utilise le catalogue d'etoiles de pointage enregistre
      set modpoi(stars,catalog) "$parametres(modpoi,catalog)"
      #--- Combobox star catalog
      set list_combobox "$list_catamodpoi"
      ComboBox $modpoi(g,base).fra_star_catalog.combobox_star_catalog \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable modpoi(stars,catalog) \
         -values $list_combobox \
         -modifycmd {
            set parametres(modpoi,catalog) "$modpoi(stars,catalog)"
         }
      pack $modpoi(g,base).fra_star_catalog.combobox_star_catalog \
      -side right -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_star_catalog \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Number of stars
   frame $modpoi(g,base).fra_nstars
      #--- Label nstars
      label $modpoi(g,base).fra_nstars.lab_nstars \
      -text "   $caption(modpoi,wiz1b,nstars) " -borderwidth 2 \
      -padx 0 -pady 3
      pack $modpoi(g,base).fra_nstars.lab_nstars \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry nstars
      entry $modpoi(g,base).fra_nstars.ent_nstars \
      -textvariable modpoi(stars,nb) \
      -borderwidth 2 -width 2 -justify center
      pack $modpoi(g,base).fra_nstars.ent_nstars \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_nstars \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Check if mount take refraction correction into account
   frame $modpoi(g,base).fra_refr
      if { [ ::confTel::getPluginProperty hasCorrectionRefraction ] == "1" } {
         label $modpoi(g,base).fra_refr.lab_refraction_1 \
         -text $caption(modpoi,wiz1b,refraction_1) -borderwidth 2 \
         -padx 0 -pady 3
         pack $modpoi(g,base).fra_refr.lab_refraction_1 \
         -side left -anchor center \
         -padx 0 -pady 3 -fill x
         set modpoi(corrections,refraction) "1"
      } else {
         label $modpoi(g,base).fra_refr.lab_refraction_2 \
         -text $caption(modpoi,wiz1b,refraction_2) -borderwidth 2 \
         -padx 0 -pady 3
         pack $modpoi(g,base).fra_refr.lab_refraction_2 \
         -side left -anchor center \
         -padx 0 -pady 3 -fill x
         set modpoi(corrections,refraction) "0"
      }
   pack $modpoi(g,base).fra_refr \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Check if centering will be auto or not
   frame $modpoi(g,base).fra_auto
      checkbutton $modpoi(g,base).fra_auto.chk -text "$caption(modpoi,wiz1b,acqauto)" \
      -highlightthickness 0 -variable modpoi(centering,check) \
      -command {
         if { $modpoi(centering,check) == "1" } {
            if { [ ::cam::list ] == "" } {
               #--- Ouverture de la fenetre de selection des cameras
               ::confCam::run
               tkwait window $audace(base).confCam
            }
            #---
            if {[::cam::list]!=""} {
               set dimxy [cam$audace(camNo) nbpix]
               set modpoi(centering,xc) [expr int([lindex $dimxy 0]/2.)]
               set modpoi(centering,yc) [expr int([lindex $dimxy 1]/2.)]
               set modpoi(centering,binning) $parametres(centering,binning)
               set modpoi(centering,exptime) $parametres(centering,exptime)
            } else {
               set modpoi(centering,xc) 0
               set modpoi(centering,yc) 0
               set modpoi(centering,binning) 1
               set modpoi(centering,exptime) 1
            }
         }
      }
      pack $modpoi(g,base).fra_auto.chk -side left -padx 0 -pady 3 -fill x -anchor center
   pack $modpoi(g,base).fra_auto \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Frame for bottom buttons
   set wiz wiz1b
   frame $modpoi(g,base).fra_bottom
      #--- PREVIOUS button
      button $modpoi(g,base).fra_bottom.but_prev \
      -text $caption(modpoi,$wiz,prev) -borderwidth 2 \
      -padx 20 -pady 10 -command { modpoi_wiz1 }
      pack $modpoi(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $modpoi(g,base).fra_bottom.but_next \
      -text $caption(modpoi,$wiz,next) -borderwidth 2 \
      -padx 20 -pady 10 \
      -command {
         if { ( $modpoi(stars,nb) >= "6" ) && ( $modpoi(stars,nb) <= "48" ) } {
            modpoi_paraminit $modpoi(stars,decmin) $modpoi(stars,decmax) $modpoi(stars,heast) $modpoi(stars,hwest)
            if {$modpoi(centering,check)==0} { modpoi_wiz2 } else { modpoi_wiz1c }
         } else {
            set choice [ tk_messageBox -message "$caption(modpoi,wiz1b,nstars1)" -title "$caption(modpoi,wiz1b,warning)" -icon question -type ok ]
            if { $choice == "ok" } {
               set modpoi(stars,nb) ""
            }
         }
      }
      pack $modpoi(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
   pack $modpoi(g,base).fra_bottom \
   -side bottom -anchor center \
   -padx 5 -pady 5 -expand 0
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
}

proc modpoi_wiz1c { } {
   global caption modpoi

   #--- Parameters entries
   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) $caption(modpoi,wiz1c,title)
   #--- Title
   label $modpoi(g,base).lab_title1b \
   -text $caption(modpoi,wiz1c,title2) \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_title1b \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #---
   #--- Binning, exptime
   #--- Coordonnées du centre de l'image (x,y)
   #--- Limite angle horaire est, west
   #--- Coordinates to center
   frame $modpoi(g,base).fra_c0
      #--- Label xyc
      label $modpoi(g,base).fra_c0.lab_xyc \
      -text "   $caption(modpoi,wiz1c,xyc) " -borderwidth 2 \
      -padx 0 -pady 0
      pack $modpoi(g,base).fra_c0.lab_xyc \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_c0 \
   -side top -anchor center \
   -padx 5 -pady 0 -expand 0
   frame $modpoi(g,base).fra_c
      #--- Label xc
      label $modpoi(g,base).fra_c.lab_xc \
      -text "   $caption(modpoi,wiz1c,xc) " -borderwidth 2 \
      -padx 0 -pady 0
      pack $modpoi(g,base).fra_c.lab_xc \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry xc
      entry $modpoi(g,base).fra_c.ent_xc \
      -textvariable modpoi(centering,xc) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_c.ent_xc \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Label yc
      label $modpoi(g,base).fra_c.lab_yc \
      -text "    $caption(modpoi,wiz1c,yc) " -borderwidth 2 \
      -padx 0 -pady 0
      pack $modpoi(g,base).fra_c.lab_yc \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry yc
      entry $modpoi(g,base).fra_c.ent_yc \
      -textvariable modpoi(centering,yc) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_c.ent_yc \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_c \
   -side top -anchor center \
   -padx 5 -pady 0 -expand 0
   #--- Accuracy of automatic centering
   frame $modpoi(g,base).fra_a
      #--- Label accuraccy
      label $modpoi(g,base).fra_a.lab \
      -text "   $caption(modpoi,wiz1c,accuracy) " -borderwidth 2 \
      -padx 0 -pady 0
      pack $modpoi(g,base).fra_a.lab \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
      #--- Entry accuracy
      entry $modpoi(g,base).fra_a.ent \
      -textvariable modpoi(centering,accuracy) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_a.ent \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
   pack $modpoi(g,base).fra_a \
   -side top -anchor center \
   -padx 5 -pady 0 -expand 0
   #--- Initial delay for drift calibration
   frame $modpoi(g,base).fra_r
      #--- Label initial delay
      label $modpoi(g,base).fra_r.lab \
      -text "   $caption(modpoi,wiz1c,initial_delay) " -borderwidth 2 \
      -padx 0 -pady 0
      pack $modpoi(g,base).fra_r.lab \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
      #--- Entry initial delay
      entry $modpoi(g,base).fra_r.ent \
      -textvariable modpoi(centering,t0) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_r.ent \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
   pack $modpoi(g,base).fra_r \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Binning et temps de pose
   frame $modpoi(g,base).fra_cam
      #--- Label binning
      label $modpoi(g,base).fra_cam.lab_bin \
      -text "   $caption(modpoi,wiz1c,binning) " -borderwidth 2 \
      -padx 0 -pady 10
      pack $modpoi(g,base).fra_cam.lab_bin \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry binning
      entry $modpoi(g,base).fra_cam.ent_bin \
      -textvariable modpoi(centering,binning) \
      -borderwidth 2 -width 3 -justify center
      pack $modpoi(g,base).fra_cam.ent_bin \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Label temps de pose
      label $modpoi(g,base).fra_cam.lab_exp \
      -text "    $caption(modpoi,wiz1c,exptime) " -borderwidth 2 \
      -padx 0 -pady 10
      pack $modpoi(g,base).fra_cam.lab_exp \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
      #--- Entry temps de pose
      entry $modpoi(g,base).fra_cam.ent_exp \
      -textvariable modpoi(centering,exptime) \
      -borderwidth 2 -width 6 -justify center
      pack $modpoi(g,base).fra_cam.ent_exp \
      -side left -anchor center \
      -padx 0 -pady 3 -expand 0
   pack $modpoi(g,base).fra_cam \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Nombre d'images a moyenner
   frame $modpoi(g,base).fra_comp
      #--- Label nombre d'images a moyenner
      label $modpoi(g,base).fra_comp.lab \
      -text "   $caption(modpoi,wiz1c,compositage) " -borderwidth 2 \
      -padx 0 -pady 0
      pack $modpoi(g,base).fra_comp.lab \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
      #--- Entry nombre d'images a moyenner
      entry $modpoi(g,base).fra_comp.ent \
      -textvariable modpoi(centering,nbmean) \
      -borderwidth 2 -width 3 -justify center
      pack $modpoi(g,base).fra_comp.ent \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
   pack $modpoi(g,base).fra_comp \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0

   #--- Frame for bottom buttons
   set wiz wiz1c
   frame $modpoi(g,base).fra_bottom
      #--- PREVIOUS button
      button $modpoi(g,base).fra_bottom.but_prev \
      -text $caption(modpoi,$wiz,prev) -borderwidth 2 \
      -padx 20 -pady 10 -command { modpoi_wiz1b }
      pack $modpoi(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $modpoi(g,base).fra_bottom.but_next \
      -text $caption(modpoi,$wiz,next) -borderwidth 2 \
      -padx 20 -pady 10 -command { modpoi_paraminit $modpoi(stars,decmin) $modpoi(stars,decmax) $modpoi(stars,heast) $modpoi(stars,hwest) ; modpoi_wiz2 }
      pack $modpoi(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
   pack $modpoi(g,base).fra_bottom \
   -side bottom -anchor center \
   -padx 5 -pady 5 -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
}

proc modpoi_wiz2 { } {
   global caption color modpoi

   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) $caption(modpoi,wiz2,title)
   #--- Title
   label $modpoi(g,base).lab_title2 \
   -text $caption(modpoi,wiz2,title2) \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_title2 \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Buttons
   set colonne 0
   set nk 0
   set nstars $modpoi(stars,nb)
   #--- Create frame for buttons
   frame $modpoi(g,base).star_bottom
   pack $modpoi(g,base).star_bottom \
   -side top -anchor center \
   -padx 5 -pady 5 -expand 0
   #--- Create colunm for buttons
   if { $nstars <= "12" } {
      frame $modpoi(g,base).star_bottom.1
      pack $modpoi(g,base).star_bottom.1 \
      -side left -anchor center \
      -padx 5 -pady 5 -expand 0
   } elseif { $nstars <= "24" } {
      for {set kk 1} {$kk<=2} {incr kk} {
         frame $modpoi(g,base).star_bottom.$kk
         pack $modpoi(g,base).star_bottom.$kk \
         -side left -anchor center \
         -padx 5 -pady 5 -expand 0
      }
   } elseif { $nstars <= "36" } {
      for {set kk 1} {$kk<=3} {incr kk} {
         frame $modpoi(g,base).star_bottom.$kk
         pack $modpoi(g,base).star_bottom.$kk \
         -side left -anchor center \
         -padx 5 -pady 5 -expand 0
      }
   } elseif { $nstars <= "48" } {
      for {set kk 1} {$kk<=4} {incr kk} {
         frame $modpoi(g,base).star_bottom.$kk
         pack $modpoi(g,base).star_bottom.$kk \
         -side left -anchor center \
         -padx 5 -pady 5 -expand 0
      }
   }
   #---
   for {set k 1} {$k<=$nstars} {incr k} {
      set kk [expr ${k}-1]
      if {$modpoi(centering,mode)=="manu"} {
         set command "modpoi_wiz3 [lindex $modpoi(stars,h0) $kk] [lindex $modpoi(stars,dec0) $kk] $k"
      } else {
         set command {}
      }
      if {[info exists modpoi(star$k,starname)]==1} {
         set lab "$modpoi(star$k,starname)"
         set col $color(lightgreen)
         incr nk
      } else {
         set lab "$caption(modpoi,wiz2,star) $k"
         set col $color(lightred)
      }
      #--- Put buttons in different columns
      if { $nstars <= "12" } {
         button $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
         -bg $col -activebackground $col \
         -text $lab -borderwidth 2 \
         -padx 10 -pady 0 -command $command
         pack $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
         -side top -anchor center \
         -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
      } elseif { $nstars <= "24" } {
         if { $colonne == "0" } {
            button $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "1"
         } else {
            button $modpoi(g,base).star_bottom.2.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.2.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "0"
         }
      } elseif { $nstars <= "36" } {
         if { $colonne == "0" } {
            button $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "1"
         } elseif { $colonne == "1" } {
            button $modpoi(g,base).star_bottom.2.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.2.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "2"
         } else {
            button $modpoi(g,base).star_bottom.3.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.3.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "0"
         }
      } elseif { $nstars <= "48" } {
         if { $colonne == "0" } {
            button $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.1.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "1"
         } elseif { $colonne == "1" } {
            button $modpoi(g,base).star_bottom.2.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.2.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "2"
         } elseif { $colonne == "2" } {
            button $modpoi(g,base).star_bottom.3.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.3.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "3"
         } else {
            button $modpoi(g,base).star_bottom.4.but_color_invariant_$k \
            -bg $col -activebackground $col \
            -text $lab -borderwidth 2 \
            -padx 10 -pady 0 -command $command
            pack $modpoi(g,base).star_bottom.4.but_color_invariant_$k \
            -side top -anchor center \
            -padx 5 -pady [expr int(4*4./$nstars)] -expand 0
            set colonne "0"
         }
      }
   }
   #--- Frame for bottom buttons
   if {$modpoi(centering,mode)=="manu"} {
      frame $modpoi(g,base).fra_bottom
      #--- PREVIOUS button
      button $modpoi(g,base).fra_bottom.but_prev \
      -text $caption(modpoi,wiz2,prev) -borderwidth 2 \
      -padx 20 -pady 10 -command { modpoi_wiz1 }
      pack $modpoi(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
      #--- NEXT button
      if {$nk==$nstars} {
         button $modpoi(g,base).fra_bottom.but_next \
         -text $caption(modpoi,wiz2,next) -borderwidth 2 \
         -padx 20 -pady 10 -command { modpoi_wiz5 }
         pack $modpoi(g,base).fra_bottom.but_next \
         -side right -anchor se \
         -padx 5 -pady 5 -expand 0
      }
      pack $modpoi(g,base).fra_bottom \
      -side bottom -anchor center \
      -padx 5 -pady 5 -expand 0
   }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
   if {$modpoi(centering,mode)=="auto"} {
      #--- Automatic centering procedure
      update
      after 1000
      if {$modpoi(centering,star_index)==$modpoi(stars,nb)} {
         modpoi_wiz5
         return
      }
      incr modpoi(centering,star_index)
      set k $modpoi(centering,star_index)
      set kk [expr ${k}-1]
      set command "modpoi_wiz3 [lindex $modpoi(stars,h0) $kk] [lindex $modpoi(stars,dec0) $kk] $k"
      eval $command
      return
   }
}

#--- Wizard de pointage d'une étoile
#--- h0, d0, meilleure position de l'étoile
proc modpoi_wiz3 { { h0 0 } { d0 0 } { starindex 1 } } {
   global caption modpoi

   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #--- Choose the star
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set star [modpoi_choose_beststar $h0 $d0 $now]
   #---
   set modpoi(star$starindex) $star
   set modpoi(starindex) $starindex
   set starname "[lindex $star 0]"
   set rae    [lindex $star 1]
   set dece   [lindex $star 2]
   set raadt  [lindex [lindex $star 3] 0]
   set decadt [lindex [lindex $star 3] 1]
   set rae    [mc_angle2hms $rae 360 nozero 1 auto string]
   set dece   [mc_angle2dms $dece 90 nozero 0 + string]
   set raadt  [mc_angle2hms $raadt 360 nozero 1 auto string]
   set decadt [mc_angle2dms $decadt 90 nozero 0 + string]
   #--- Stocke le résultat pour etoile $starindex
   set modpoi(star$starindex,starname0) "$starname"
   set modpoi(star$starindex,rae)       $rae
   set modpoi(star$starindex,dece)      $dece
   set modpoi(star$starindex,raadt)     $raadt
   set modpoi(star$starindex,decadt)    $decadt
   set wiz wiz3
   #----------------------------------------
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) "$caption(modpoi,$wiz,title) $starindex"
   #--- Title
   label $modpoi(g,base).lab_title2 \
   -text "$caption(modpoi,$wiz,title2) $starindex" \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_title2 \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Label for star name
   label $modpoi(g,base).lab_starname \
   -text $starname -borderwidth 2 \
   -padx 20 -pady 10
   pack $modpoi(g,base).lab_starname \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Label for J2000.0 coordinates
   label $modpoi(g,base).lab_j2000 \
   -text $caption(modpoi,$wiz,j2000) -borderwidth 2
   pack $modpoi(g,base).lab_j2000 \
   -side top -anchor center \
   -expand 0
   #--- Label for RADEC J2000.0 coordinates
   label $modpoi(g,base).lab_radecj2000 \
   -text "RA=$rae DEC=$dece" -borderwidth 2
   pack $modpoi(g,base).lab_radecj2000 \
   -side top -anchor center \
   -expand 0
   #--- Label for telescope coordinates
   label $modpoi(g,base).lab_tel \
   -text "\n$caption(modpoi,$wiz,tel)" -borderwidth 2
   pack $modpoi(g,base).lab_tel \
   -side top -anchor center \
   -expand 0
   #--- Label for RADEC telescope coordinates
   label $modpoi(g,base).lab_radectel \
   -text "RA=${raadt} DEC=${decadt}" -borderwidth 2
   pack $modpoi(g,base).lab_radectel \
   -side top -anchor center \
   -expand 0
   #--- Label for the comment
   if { [ ::confTel::getPluginProperty hasCorrectionRefraction ] == "0" } {
      label $modpoi(g,base).lab_comment_1 \
      -text $caption(modpoi,$wiz,comment_1) -borderwidth 2 \
      -padx 20 -pady 10
      pack $modpoi(g,base).lab_comment_1 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   } else {
      label $modpoi(g,base).lab_comment_2 \
      -text $caption(modpoi,$wiz,comment_2) -borderwidth 2 \
      -padx 20 -pady 10
      pack $modpoi(g,base).lab_comment_2 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   }
   set com_next "modpoi_goto $starindex ; modpoi_wiz4 "
   if {$modpoi(centering,mode)=="manu"} {
      #--- Frame for bottom buttons
      frame $modpoi(g,base).fra_bottom
      #--- PREVIOUS button
      button $modpoi(g,base).fra_bottom.but_prev \
      -text $caption(modpoi,$wiz,prev) -borderwidth 2 \
      -padx 20 -pady 10 -command { modpoi_wiz2 }
      pack $modpoi(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $modpoi(g,base).fra_bottom.but_next \
      -text $caption(modpoi,$wiz,next) -borderwidth 2 \
      -padx 20 -pady 10 -command $com_next
      pack $modpoi(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
      pack $modpoi(g,base).fra_bottom \
      -side bottom -anchor center \
      -padx 5 -pady 5 -expand 0
      #--- NON VISIBLE button
      set com_cannot "lappend modpoi(starname,choosen) \"$modpoi(starname,actual)\" ; modpoi_wiz3 [lindex $modpoi(stars,h0) $starindex] [lindex $modpoi(stars,dec0) $starindex] $starindex"
      button $modpoi(g,base).but_cannot \
      -text $caption(modpoi,$wiz,cannot) -borderwidth 2 \
      -padx 20 -pady 3 -command $com_cannot
      pack $modpoi(g,base).but_cannot \
      -side bottom -anchor center \
      -padx 10 -pady 0 -expand 0 -fill x
   }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
   #--- Case of autocentering
   if {$modpoi(centering,mode)=="auto"} {
      update
      after 1000
      eval $com_next
   }
}

proc modpoi_wiz4 { } {
   global audace caption modpoi

   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   set starindex $modpoi(starindex)
   set starname "$modpoi(star$starindex,starname0)"
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) "$caption(modpoi,wiz4,title) $starindex"
   #--- Title
   label $modpoi(g,base).lab_title2 \
   -text "$caption(modpoi,wiz4,title2) $starindex" \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_title2 \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Label for star name to center
   label $modpoi(g,base).lab_starname \
   -text "$caption(modpoi,wiz4,center) $starname" \
   -borderwidth 2 -padx 20 -pady 10
   pack $modpoi(g,base).lab_starname \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Label for the comment
   if {$modpoi(centering,mode)=="manu"} {
      set labtext "$caption(modpoi,wiz4,comment)"
   } else {
      set labtext "$caption(modpoi,wiz4,comment_auto)"
   }
   label $modpoi(g,base).lab_comment \
   -text "$labtext" -borderwidth 2 \
   -padx 20 -pady 10
   pack $modpoi(g,base).lab_comment \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0

   if {$modpoi(centering,mode)=="manu"} {
      #--- Frame for direction boutons
      frame $modpoi(g,base).fra -relief flat
      pack $modpoi(g,base).fra -anchor center
      #--- Create the button 'N'
      frame $modpoi(g,base).fra.n -width 54 -borderwidth 0 -relief flat
      pack $modpoi(g,base).fra.n -side top -fill x
      #--- Button-design 'N'
      button $modpoi(g,base).fra.n.canv1PoliceInvariant -borderwidth 4 \
         -font $audace(font,PoliceInvariant) \
         -text "$caption(modpoi,north)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $modpoi(g,base).fra.n.canv1PoliceInvariant -in $modpoi(g,base).fra.n -expand 1
      #--- Create the buttons 'E W'
      frame $modpoi(g,base).fra.we -width 54 -borderwidth 0 -relief flat
      pack $modpoi(g,base).fra.we -in $modpoi(g,base).fra -side top -fill x
      #--- Button-design 'E'
      button $modpoi(g,base).fra.we.canv1PoliceInvariant -borderwidth 4 \
         -font $audace(font,PoliceInvariant) \
         -text "$caption(modpoi,east)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $modpoi(g,base).fra.we.canv1PoliceInvariant -in $modpoi(g,base).fra.we -expand 1 -side left
      #--- Write the label of speed
      label $modpoi(g,base).fra.we.labPoliceInvariant -font $audace(font,PoliceInvariant) \
         -textvariable audace(telescope,labelspeed) -borderwidth 0 -relief flat -padx 20
      pack $modpoi(g,base).fra.we.labPoliceInvariant -in $modpoi(g,base).fra.we -expand 1 -side left
      #--- Button-design 'W'
      button $modpoi(g,base).fra.we.canv2PoliceInvariant -borderwidth 4 \
         -font $audace(font,PoliceInvariant) \
         -text "$caption(modpoi,west)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $modpoi(g,base).fra.we.canv2PoliceInvariant -in $modpoi(g,base).fra.we -expand 1 -side right
      #--- Create the button 'S'
      frame $modpoi(g,base).fra.s -width 54 -borderwidth 0 -relief flat
      pack $modpoi(g,base).fra.s -in $modpoi(g,base).fra -side top -fill x
      #--- Button-design 'S'
      button $modpoi(g,base).fra.s.canv1PoliceInvariant -borderwidth 4 \
         -font $audace(font,PoliceInvariant) \
         -text "$caption(modpoi,south)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $modpoi(g,base).fra.s.canv1PoliceInvariant -in $modpoi(g,base).fra.s -expand 1
      #---
      set zone(n) $modpoi(g,base).fra.n.canv1PoliceInvariant
      set zone(e) $modpoi(g,base).fra.we.canv1PoliceInvariant
      set zone(w) $modpoi(g,base).fra.we.canv2PoliceInvariant
      set zone(s) $modpoi(g,base).fra.s.canv1PoliceInvariant
      bind $modpoi(g,base).fra.we.labPoliceInvariant <ButtonPress-1> { modpoi_speed }
      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1> { catch { modpoi_move e } }
     # bind $zone(e).lab <ButtonPress-1> { catch { modpoi_move e } }
      bind $zone(e) <ButtonRelease-1> { modpoi_stop e }
     # bind $zone(e).lab <ButtonRelease-1> { modpoi_stop e }
      bind $zone(w) <ButtonPress-1> { catch { modpoi_move w } }
     # bind $zone(w).lab <ButtonPress-1> { catch { modpoi_move w } }
      bind $zone(w) <ButtonRelease-1> { modpoi_stop w }
     # bind $zone(w).lab <ButtonRelease-1> { modpoi_stop w }
      bind $zone(s) <ButtonPress-1> { catch { modpoi_move s } }
     # bind $zone(s).lab <ButtonPress-1> { catch { modpoi_move s } }
      bind $zone(s) <ButtonRelease-1> { modpoi_stop s }
     # bind $zone(s).lab <ButtonRelease-1> { modpoi_stop s }
      bind $zone(n) <ButtonPress-1> { catch { modpoi_move n } }
     # bind $zone(n).lab <ButtonPress-1> { catch { modpoi_move n } }
      bind $zone(n) <ButtonRelease-1> { modpoi_stop n }
     # bind $zone(n).lab <ButtonRelease-1> { modpoi_stop n }
      #--- Frame for bottom buttons
      frame $modpoi(g,base).fra_bottom
      #--- PREVIOUS button
      button $modpoi(g,base).fra_bottom.but_prev \
      -text $caption(modpoi,wiz4,prev) -borderwidth 2 \
      -padx 10 -pady 10 -command { modpoi_wiz2 }
      pack $modpoi(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $modpoi(g,base).fra_bottom.but_next \
      -text $caption(modpoi,wiz4,next) -borderwidth 2 \
      -padx 10 -pady 10 -command { modpoi_coord ; modpoi_wiz2 }
      pack $modpoi(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
      pack $modpoi(g,base).fra_bottom \
      -side bottom -anchor center \
      -padx 5 -pady 5 -expand 0
      #--- NON VISIBLE button
      set com_cannot "lappend modpoi(starname,choosen) \"$modpoi(starname,actual)\" ; modpoi_wiz3 [lindex $modpoi(stars,h0) $starindex] [lindex $modpoi(stars,dec0) $starindex] $starindex"
      button $modpoi(g,base).but_cannot \
      -text $caption(modpoi,wiz4,cannot) -borderwidth 2 \
      -padx 20 -pady 3 -command $com_cannot
      pack $modpoi(g,base).but_cannot \
      -side bottom -anchor center \
      -padx 10 -pady 0 -expand 0 -fill x
   } else {
      label $modpoi(g,base).lab_dist \
      -text " " -borderwidth 2 \
      -padx 10 -pady 10
      pack $modpoi(g,base).lab_dist \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
   #--- Case of autocentering
   if {$modpoi(centering,mode)=="auto"} {
      #--- Automatic centering procedure
      update
      after 1000
      #--- Call the procedure...
      modpoi_autocentering
      #set com_cannot "lappend modpoi(starname,choosen) \"$modpoi(starname,actual)\" ; modpoi_wiz3 [lindex $modpoi(stars,h0) $starindex] [lindex $modpoi(stars,dec0) $starindex] $starindex"
      #modpoi_wiz2
      #--- Call back the main menu
      modpoi_coord
      modpoi_wiz2
   }
}

proc modpoi_wiz5 { } {
   global caption modpoi

   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) $caption(modpoi,wiz5,title)
   #--- Compute the coefficients
   set res [modpoi_computecoef]
   set modpoi(vec) [lindex $res 0]
   set modpoi(chisq) [lindex $res 1]
   set modpoi(covar) [lindex $res 2]
   set res1 "\
   IH = [format "%.2f" [lindex $modpoi(vec) 0]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 1 1],2)]])\n\
   ($caption(modpoi,wiz5,IH))\n\n\
   ID = [format "%.2f" [lindex $modpoi(vec) 1]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 2 2],2)]])\n\
   ($caption(modpoi,wiz5,ID))\n\n\
   NP = [format "%.2f" [lindex $modpoi(vec) 2]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 3 3],2)]])\n\
   ($caption(modpoi,wiz5,NP))\n\n\
   CH = [format "%.2f" [lindex $modpoi(vec) 3]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 4 4],2)]])\n\
   ($caption(modpoi,wiz5,CH))\n\n\
   ME = [format "%.2f" [lindex $modpoi(vec) 4]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 5 5],2)]])\n\
   ($caption(modpoi,wiz5,ME))\n\n\
   MA = [format "%.2f" [lindex $modpoi(vec) 5]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 6 6],2)]])\n\
   ($caption(modpoi,wiz5,MA))\n\n\
   FO = [format "%.2f" [lindex $modpoi(vec) 6]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 7 7],2)]])\n\
   ($caption(modpoi,wiz5,FO))\n\n\
   MT = [format "%.2f" [lindex $modpoi(vec) 7]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 8 8],2)]])\n\
   ($caption(modpoi,wiz5,MT))\n\n\
   DAF = [format "%.2f" [lindex $modpoi(vec) 8]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 9 9],2)]])\n\
   ($caption(modpoi,wiz5,DAF))\n\n\
   TF = [format "%.2f" [lindex $modpoi(vec) 9]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 10 10],2)]])\n\
   ($caption(modpoi,wiz5,TF))\n\n\
   chisquare=$modpoi(chisq)\n\n"
   #--- Test du calcul direct
   set res [modpoi_testcoef $modpoi(vec) $modpoi(chisq) $modpoi(covar)]
   ::console::affiche_resultat "$res\n"
   #--- Display name
   label $modpoi(g,base).lab_name \
   -text "[ file rootname [ file tail $modpoi(Filename) ] ]" -borderwidth 2 \
   -padx 20 -pady 10
   pack $modpoi(g,base).lab_name \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Display the results
   label $modpoi(g,base).lab_res1 \
   -text "$res1" -borderwidth 2 \
   -padx 20 -pady 10
   pack $modpoi(g,base).lab_res1 \
   -side top -anchor center \
   -padx 5 -pady 3 -expand 0
   #--- Frame for bottom buttons
   frame $modpoi(g,base).fra_bottom
      #--- PREVIOUS button
      button $modpoi(g,base).fra_bottom.but_prev \
      -text $caption(modpoi,wiz5,prev) -borderwidth 2 \
      -padx 10 -pady 10 -command { modpoi_wiz2 }
      pack $modpoi(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $modpoi(g,base).fra_bottom.but_next \
      -text $caption(modpoi,wiz5,next) -borderwidth 2 \
      -padx 10 -pady 10 -command { recup_position ; modpoi_wiz11 }
      pack $modpoi(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
   pack $modpoi(g,base).fra_bottom \
   -side bottom -anchor center \
   -padx 5 -pady 5 -expand 0
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $modpoi(g,base)
}

proc modpoi_wiz11 { } {
   global modpoi

   #--- Sauvegarde les parametres s'ils ont change
   Enregistrement_Var
   #---
   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
}

proc modpoi_wiz5b { } {
   global caption modpoi

   if { [winfo exists $modpoi(g,base)] } {
      set modpoi(wm_geometry) [wm geometry $modpoi(g,base)]
      destroy $modpoi(g,base)
   }
   #--- New toplevel
   toplevel $modpoi(g,base) -class Toplevel
   wm geometry $modpoi(g,base) $modpoi(wm_geometry)
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $modpoi(g,base) 560 680
   } else {
      wm minsize $modpoi(g,base) 440 500
   }
   wm resizable $modpoi(g,base) 1 0
   wm title $modpoi(g,base) $caption(modpoi,wiz5,title1)
   #--- Compute the coefficients
   #set res [modpoi_computecoef]
   #set modpoi(vec) [lindex $res 0]
   #set modpoi(chisq) [lindex $res 1]
   #set modpoi(covar) [lindex $res 2]
   set num [catch {
      set res1 "\
      IH = [format "%.2f" [lindex $modpoi(vec) 0]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 1 1],2)]])\n\
      ($caption(modpoi,wiz5,IH))\n\n\
      ID = [format "%.2f" [lindex $modpoi(vec) 1]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 2 2],2)]])\n\
      ($caption(modpoi,wiz5,ID))\n\n\
      NP = [format "%.2f" [lindex $modpoi(vec) 2]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 3 3],2)]])\n\
      ($caption(modpoi,wiz5,NP))\n\n\
      CH = [format "%.2f" [lindex $modpoi(vec) 3]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 4 4],2)]])\n\
      ($caption(modpoi,wiz5,CH))\n\n\
      ME = [format "%.2f" [lindex $modpoi(vec) 4]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 5 5],2)]])\n\
      ($caption(modpoi,wiz5,ME))\n\n\
      MA = [format "%.2f" [lindex $modpoi(vec) 5]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 6 6],2)]])\n\
      ($caption(modpoi,wiz5,MA))\n\n\
      FO = [format "%.2f" [lindex $modpoi(vec) 6]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 7 7],2)]])\n\
      ($caption(modpoi,wiz5,FO))\n\n\
      MT = [format "%.2f" [lindex $modpoi(vec) 7]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 8 8],2)]])\n\
      ($caption(modpoi,wiz5,MT))\n\n\
      DAF = [format "%.2f" [lindex $modpoi(vec) 8]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 9 9],2)]])\n\
      ($caption(modpoi,wiz5,DAF))\n\n\
      TF = [format "%.2f" [lindex $modpoi(vec) 9]] arcmin ([format "%.2f" [expr pow([gsl_mindex $modpoi(covar) 10 10],2)]])\n\
      ($caption(modpoi,wiz5,TF))\n\n\
      chisquare=$modpoi(chisq)\n\n"
   } msg]
   if { $num!="1"} {
      #--- Display name
      if { [ info exists modpoi(modpoi_choisi) ] == "1" } {
         set name $modpoi(modpoi_choisi)
      } else {
         set name $modpoi(Filename)
      }
      label $modpoi(g,base).lab_name \
      -text "[ file rootname [ file tail $name ] ]" -borderwidth 2 \
      -padx 20 -pady 10
      pack $modpoi(g,base).lab_name \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
      #--- Display the results
      label $modpoi(g,base).lab_res1 \
      -text "$res1" -borderwidth 2 \
      -padx 20 -pady 10
      pack $modpoi(g,base).lab_res1 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $modpoi(g,base)
   } else {
      destroy $modpoi(g,base)
      tk_messageBox -title "$caption(modpoi,wiz1b,warning)" -message "$caption(modpoi,modele,editer)" -icon error
   }
}

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------


#=======================================================================
#=======================================================================
#=======================================================================
#=======================================================================

proc modpoi_paraminit { { decmin 1000 } { decmax 1000 } { hwest 1000 } { heast 1000 } } {
   global modpoi

   #--- Liste des positions optimales de pointage (angle horaire)
   #--- Limites
   if {($decmin==1000)&&($decmax==1000)} {
      set latitude [lindex $modpoi(var,home) 3]
      if {$latitude>=0} {
         set decmax 50
         set decmin [expr 35.-(90.-$latitude)]
      } else {
         set decmax [expr -35.-(-90.-$latitude)]
         set decmin -50
      }
   }
   set modpoi(stars,decmin) $decmin
   set modpoi(stars,decmax) $decmax
   if {$modpoi(stars,decmax)<$modpoi(stars,decmin)} {
      set a $modpoi(stars,decmax)
      set modpoi(stars,decmax) $modpoi(stars,decmin)
      set modpoi(stars,decmin) $a
   }

   if {($hwest==1000)&&($heast==1000)} {
      set hwest 60
      set heast -60
   } else {
      set hwest [mc_angle2deg $hwest 180]
      set heast [mc_angle2deg $heast 180]
   }
   set modpoi(stars,hwest) $hwest
   set modpoi(stars,heast) $heast
   if {$modpoi(stars,hwest)<$modpoi(stars,heast)} {
      set a $modpoi(stars,hwest)
      set modpoi(stars,hwest) $modpoi(stars,heast)
      set modpoi(stars,heast) $a
   }

   #--- Calcul
   set nquadrants [expr int(floor(($modpoi(stars,nb)-1)/2.))]
   set increment [expr 1.*($modpoi(stars,hwest)-$modpoi(stars,heast))/$nquadrants]
   set infsup sup
   set h $modpoi(stars,hwest)
   set modpoi(stars,h0) ""
   set modpoi(stars,dec0) ""
   for {set k 1} {$k<=$modpoi(stars,nb)} {incr k} {
      lappend modpoi(stars,h0) $h
      if {$infsup=="sup"} {
         lappend modpoi(stars,dec0) $modpoi(stars,decmax)
         set infsup inf
      } else {
         lappend modpoi(stars,dec0) $modpoi(stars,decmin)
         set infsup sup
         set h [expr $h-$increment]
      }
   }

   if {$modpoi(centering,check)==0} {
      set modpoi(centering,mode) manu
   } else {
      set modpoi(centering,mode) auto
   }
}

proc modpoi_goto { { numstar 1 } } {
   global audace modpoi

   if { [ ::tel::list ] == "" } {
   } else {
      set raadt $modpoi(star$numstar,raadt)
      set decadt $modpoi(star$numstar,decadt)
      tel$audace(telNo) radec goto [list $raadt $decadt]
   }

   set dummy [mc_angle2hms [lindex [lindex $modpoi(star$numstar) 3] 0]]
   set rae "[lindex $dummy 0]h[lindex $dummy 1]m[string range [lindex $dummy 2] 0 4]s"
   set dummy [mc_angle2dms [lindex [lindex $modpoi(star$numstar) 3] 1] 90]
   set dece "[lindex $dummy 0]d[lindex $dummy 1]m[string range [lindex $dummy 2] 0 4]s"

   set modpoi(var,radece) [list $rae $dece]
   ::telescope::afficheCoord
}

proc modpoi_move { { direction E } } {
   ::telescope::move $direction
}

proc modpoi_stop { { direction "" } } {
   ::telescope::stop $direction
}

proc modpoi_speed { } {
   ::telescope::incrementSpeed
}

proc modpoi_coord { } {
   global audace modpoi

   set starindex $modpoi(starindex)
   if { [ ::tel::list ] == "" } {
      set modpoi(star$starindex,ra_obs)  $modpoi(star$starindex,raadt)
      set modpoi(star$starindex,dec_obs) $modpoi(star$starindex,decadt)
   } else {
      set radecadtm [tel$audace(telNo) radec coord]
      set raadtm [lindex $radecadtm 0]
      set decadtm [lindex $radecadtm 1]
      set modpoi(star$starindex,ra_obs) $raadtm
      set modpoi(star$starindex,dec_obs) $decadtm
   }
   set modpoi(star$starindex,ra_cal) $modpoi(star$starindex,raadt)
   set modpoi(star$starindex,dec_cal) $modpoi(star$starindex,decadt)
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set modpoi(star$starindex,date) [mc_date2jd $now]
   set dummy [mc_radec2altaz $modpoi(star$starindex,ra_cal) $modpoi(star$starindex,dec_cal) $modpoi(var,home) $now]
   set modpoi(star$starindex,h_cal) [lindex $dummy 2]
   set modpoi(star$starindex,az_cal) [lindex $dummy 0]
   set modpoi(star$starindex,alt_cal) [lindex $dummy 1]
   set modpoi(star$starindex,starname) "$modpoi(starname,actual)"
   lappend modpoi(starname,choosen) "$modpoi(starname,actual)"
}

proc modpoi_catalogmean2apparent { rae dece equinox date { dra_dan "" } { ddec_dan "" } { epoch "" } } {
#--- Input
#--- rae,dece : coordinates J2000.0 (degrees)
#--- Output
#--- rav,decv : true coordinates (degrees)
#--- Hv : true hour angle (degrees)
#--- hv : true altitude altaz coordinate (degrees)
#--- azv : true azimut altaz coodinate (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Aberration annuelle
   set radec [mc_aberrationradec annual [list $rae $dece] $date ]
   #--- Correction de precession
   set radec [mc_precessradec $radec $equinox $date [list $dra_dan $ddec_dan $epoch]]
   #--- Correction de nutation
   set radec [mc_nutationradec $radec $date]
   #--- Aberration de l'aberration diurne
   set radec [mc_aberrationradec diurnal $radec $date $modpoi(var,home)]
   #--- Calcul de l'angle horaire et de la hauteur vraie
   set rav [lindex $radec 0]
   set decv [lindex $radec 1]
   set dummy [mc_radec2altaz ${rav} ${decv} $modpoi(var,home) $date]
   set azv [lindex $dummy 0]
   set hv [lindex $dummy 1]
   set Hv [lindex $dummy 2]
   #--- Return
   return [list $rav $decv $Hv $hv $azv]
}

proc modpoi_apparent2catalogmean { listv equinox date } {
#--- Input
#--- listv
#---   rav,decv : true coordinates (degrees)
#---   etc.
#--- equinox : J2000.0
#--- date
#--- Output
#--- rae,dece : coordinates J2000.0 (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Extract angles from the listvd
   set rav [lindex $listv 0]
   set decv [lindex $listv 1]
   #--- Aberration de l'aberration diurne
   set radec [mc_aberrationradec diurnal [list $rav $decv] $date $modpoi(var,home) -reverse]
   #--- Correction de nutation
   set radec [mc_nutationradec $radec $date -reverse]
   #--- Correction de precession
   set radec [mc_precessradec $radec $date $equinox]
   #--- Aberration annuelle
   set radec [mc_aberrationradec annual $radec $date -reverse]
   #--- Return
   return $radec
}

proc modpoi_apparent2observed { listvdt { pressure 101325 } { temperature 290 } { date now } } {
#--- Input
#--- listvdt : true coodinates list from modpoi_catalogmean2apparent (degrees)
#--- Output
#--- raadt,decadt : observed coordinates (degrees)
#--- Hadt : observed hour angle (degrees)
#--- hadt : observed altitude altaz coordinate (degrees)
#--- azadt : observed azimut altaz coordinate (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Extract angles from the listvd
   set ravdt [lindex $listvdt 0]
   set decvdt [lindex $listvdt 1]
   set Hvdt [lindex $listvdt 2]
   set hvdt [lindex $listvdt 3]
   set azvdt [lindex $listvdt 4]
   #--- Refraction correction
   set azadt $azvdt
   if {$hvdt>-1.} {
      set refraction [mc_refraction $hvdt out2in $temperature $pressure]
   } else {
      set refraction 0.
   }
   set hadt [expr $hvdt+$refraction]
   set res [mc_altaz2radec $azvdt $hadt $modpoi(var,home) $date]
   set raadt [lindex $res 0]
   set decadt [lindex $res 1]
   set res [mc_altaz2hadec $azvdt $hadt $modpoi(var,home) $date]
   set Hadt [lindex $res 0]
   return [list $raadt $decadt $Hadt $hadt $azadt]
}

proc modpoi_observed2apparent { rao deco { pressure 101325 } { temperature 290 } { date now } } {
#--- Input
#--- rao : observed (topocentric refracted) ra
#--- deco : observed (topocentric refracted) dec
#--- Output
#--- rav,decv : true coordinates (degrees)
#--- Hv : true hour angle (degrees)
#--- hv : true altitude altaz coordinate (degrees)
#--- azv : true azimut altaz coodinate (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Refraction correction inverse
   set res [mc_radec2altaz $rao $deco $modpoi(var,home) $date]
   set azo [lindex $res 0]
   set ho [lindex $res 1]
   if {$ho>0} {
      set refraction [mc_refraction $ho out2in $temperature $pressure]
   } else {
      set refraction 0.
   }
   set azv $azo
   set hv [expr $ho-$refraction]
   set res [mc_altaz2radec $azv $hv $modpoi(var,home) $date]
   set rav [lindex $res 0]
   set decv [lindex $res 1]
   set res [mc_altaz2hadec $azv $hv $modpoi(var,home) $date]
   set Hv [lindex $res 0]
   return [list $rav $decv $Hv $hv $azv]
}

proc modpoi_choose_beststar { { h0 0 } { dec0 80 } { date now } } {
   global audace caption modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)

   #---
   set filename [ file join $audace(rep_plugin) tool modpoi cata_modpoi $modpoi(stars,catalog) ]
   set msg 0
   catch {
      set f [open "$filename" r]
      set contents [split [read $f] \n]
      close $f
      set msg 1
   }
   set modpoi(stars,names) ""
   set modpoi(stars,coords) ""
   if {$msg==1} {
      if { $modpoi(stars,catalog) != "hip_1091_stars.txt" } {
         #--- Determine le nombre d'elements de la liste
         set len [expr [llength $contents]-1]
         #--- Isole les enregistrements
         for {set k 0} {$k<$len} {incr k} {
            set thestar [lindex $contents $k]
            set name "[string range $thestar 0 20]"
            set name [string trim "$name"]
            set designation "[string range $thestar 21 35]"
            set designation [string trim "$designation"]
            lappend modpoi(stars,names) "$name ($designation)"
            set rah "[string range $thestar 36 37]"
            set ram "[string range $thestar 39 40]"
            set ras "[string range $thestar 42 45]"
            set decd "[string range $thestar 50 52]"
            set decm "[string range $thestar 54 55]"
            set decs "[string range $thestar 57 58]"
            lappend modpoi(stars,coords) "${rah}h${ram}m${ras}s ${decd}d${decm}m${decs}s"
         }
      } else {
         #--- Determine le nombre d'elements de la liste du catalogue hip_1091_stars.txt
         set long [llength $contents]
         #--- Recherche le numero de la ligne de separation des commentaires avec le catalogue
         set search "#------;----------;----------;-----;------;--------;--------;-------"
         set ligne_en_trop "0"
         for {set j 0} {$j <= $long} {incr j} {
            set ligne [lindex $contents $j]
            if { [string compare [lindex $ligne 0] "$search"]=="0"} {
               set ligne_en_trop "1"
               break
            }
         }
         if { $ligne_en_trop == "1" } {
            #--- Supprime les 'j' lignes de commentaires
            set contents [lreplace $contents 0 $j]
         }
         #--- Determine le nombre d'elements de la nouvelle liste
         set len [expr [llength $contents]-1]
         #--- Isole les enregistrements
         for {set k 0} {$k<$len} {incr k} {
            set thestar [lindex $contents $k]
            set name "[string range $thestar 0 5]"
            set name [string trim "$name"]
            lappend modpoi(stars,names) "HIP $name"
            set rad "[string range $thestar 7 16]"
            set decd "[string range $thestar 18 27]"
            set decd_radian [ mc_angle2rad $decd ]
            set dra_mas "[string range $thestar 42 49]"
            set dra_dan [expr $dra_mas*1e-3/(3600.*cos($decd_radian))]
            set ddec_mas "[string range $thestar 51 58]"
            set ddec_dan [expr $ddec_mas*1e-3/3600.]
            lappend modpoi(stars,coords) "${rad}d ${decd}d ${dra_dan} ${ddec_dan}"
         }
      }
   } else {
      set modpoi(stars,names) { \
          "Gamma Peg" \
          "Beta Cet" \
          "Beta And" \
          "Gamma1 And" \
          "Alpha Ari" \
          "Alpha Cet" \
          "Alpha Per" \
          "Aldebaran" \
          "Rigel" \
          "Beta Tau" \
          "Procyon" \
          "Pollux" \
          "Alpha Lyn" \
          "Alpha Hya" \
          "Regulus" \
          "Mu Uma" \
          "Denebola" \
          "Gamma Crv" \
          "Alpha1 CVn" \
          "Spica" \
          "Arcturus" \
          "Alpha Ser" \
          "Beta1 Sco" \
          "Antares" \
          "Zeta Her" \
          "Beta Dra" \
          "Alpha Oph" \
          "Nu Oph" \
          "Vega" \
          "Altair" \
          "Beta Cap" \
          "Gamma Cyg" \
          "Enif" \
          "Delta Aqr" \
          "Beta Peg" \
          "Alpha Peg" }

      #--- Coordonnees selon J2000.0
      set modpoi(stars,coords) { \
          {0h13m14 15d11m1}\
          {0h43m35 -17d59m12}\
          {1h9m44 35d37m14}\
          {2h3m54 42d19m47}\
          {2h7m10 23d27m45}\
          {3h2m17 4d5m23}\
          {3h24m19 49d51m40}\
          {4h35m55 16d30m33}\
          {5h14m32 -8d12m6}\
          {5h26m18 28d36m27}\
          {7h39m18 5d13m30}\
          {7h45m19 28d1m34}\
          {9h21m3 34d23m33}\
          {9h27m35 -8d39m31}\
          {10h8m22 11d58m2}\
          {10h22m20 41d29m58}\
          {11h49m4 14d34m19}\
          {12h15m48 -17d32m31}\
          {12h56m1 38d18m52}\
          {13h25m12 -11d9m41}\
          {14h15m40 19d10m57}\
          {15h44m16 6d25m32}\
          {16h5m26 -19d48m20}\
          {16h29m24 -26d25m55}\
          {16h41m17 31d36m10}\
          {17h30m26 52d18m5}\
          {17h34m56 12d33m36}\
          {17h59m2 -9d46m25}\
          {18h36m56 38d47m1}\
          {19h50m47 8d52m6}\
          {20h21m1 -14d46m53}\
          {20h22m14 40d15m24}\
          {21h44m11 9d52m30}\
          {22h54m39 -15d49m15}\
          {23h3m46 28d4m58}\
          {23h4m46 15d12m19} }
   }
   #--- Calcule l'angle horaire de toutes les étoiles
   set home $modpoi(var,home)
   set radec_moon [lindex [mc_ephem moon [list [mc_date2tt [mc_date2jd [::audace::date_sys2ut]] ] ] {RA DEC} -topo "$home"] 0]
   catch {unset lcoords}
   set lcoords {}
   set k 0
   foreach star $modpoi(stars,coords) {
      set starname "[lindex $modpoi(stars,names) $k]"
      if {[lsearch $modpoi(starname,choosen) $starname]!=-1} {
         incr k
         continue
      }
      set rae [lindex $star 0]
      set dece [lindex $star 1]
      set dra_dan [lindex $star 2]
      set ddec_dan [lindex $star 3]
      set listv [modpoi_catalogmean2apparent $rae $dece J2000.0 $date $dra_dan $ddec_dan J1991.25]
      set hauteur [lindex $listv 3]
      set dummy [list [lindex $radec_moon 0] [lindex $radec_moon 1] $rae $dece]
      set sepmoon [lindex [mc_anglesep $dummy] 0]
      if {($hauteur>30)&&($sepmoon>10)} {
         #--- Case :
         #--- The telescope mount computes the refraction corrections
         #--- yes = 1 (case of the Meade LX200, Sky Sensor 2000, ...)
         #--- no  = 0 (case of the AudeCom, ...)
         if {$modpoi(corrections,refraction)==0} {
            set listv [modpoi_apparent2observed $listv 101325 290 $date]
         }
         set dummy [list "[lindex $modpoi(stars,names) $k]" $rae $dece $listv]
         lappend lcoords $dummy
      }
      incr k
   }
   if { $lcoords == "" } {
      #--- Cas ou l'on a atteind la fin de la liste
      #--- Alors on reste sur la meme etoile
      set k 0
      foreach star $modpoi(stars,coords) {
         set starname "[lindex $modpoi(stars,names) $k]"
         set rae [lindex $star 0]
         set dece [lindex $star 1]
         set listv [modpoi_catalogmean2apparent $rae $dece J2000.0 $date $dra_dan $ddec_dan J1991.25]
         set hauteur [lindex $listv 3]
         if {$starname=="$modpoi(starname,actual)"} {
            #--- Case :
            #--- The telescope mount computes the refraction corrections
            #--- yes = 1 (case of the Meade LX200, Sky Sensor 2000, ...)
            #--- no  = 0 (case of the AudeCom, ...)
            if {$modpoi(corrections,refraction)==0} {
               set listv [modpoi_apparent2observed $listv 101325 290 $date]
            }
            set dummy [list "[lindex $modpoi(stars,names) $k]" $rae $dece $listv]
            lappend lcoords $dummy
            break
         }
         incr k
      }
      set thestar [lindex $lcoords 0]
      set modpoi(starname,actual) "[lindex [lindex $lcoords 0] 0]"
      set over [tk_messageBox -type ok -message "$caption(modpoi,wiz3,pas_etoile)"]
      return $thestar
   }
   #--- Selectionne l'etoile la plus proche de h0 dec0
   set k 0
   set kmin 0
   set sepmin 360.
   foreach coords $lcoords {
      set h [lindex [lindex $coords 3] 2]
      set dec [lindex [lindex $coords 3] 1]
      set sep [lindex [mc_anglesep [list $h0 $dec0 $h $dec]] 0]
      if {$sep<$sepmin} {
         set kmin $k
         set sepmin $sep
      }
      incr k
   }
   set thestar [lindex $lcoords $kmin]
  ### ::console::affiche_resultat "$thestar\n"
   set modpoi(starname,actual) "[lindex [lindex $lcoords $kmin] 0]"
   return $thestar
}

proc modpoi_computecoef { {fileinp ""} } {
   global audace modpoi

   #--- Ouvre la fenetre pour donner un nom au modele de pointage
   set err [catch {run_name_modpoi} msg]
   if {$err==1} {
      set modpoi(Filename) [file tail $fileinp]
   }

   #--- Analyse chaque ligne
   set vecY ""
   set matX ""
   set vecW ""
   set texte ""
   for {set k 1} {$k<=$modpoi(stars,nb)} {incr k} {
      #--- Met en forme les valeurs
      set deltah [expr 60*[mc_anglescomp $modpoi(star$k,ra_obs) - $modpoi(star$k,ra_cal)]]
      set deltad [expr 60*[mc_anglescomp $modpoi(star$k,dec_obs) - $modpoi(star$k,dec_cal)]]
      set dec $modpoi(star$k,dec_cal)
      set h $modpoi(star$k,h_cal)
      set phi [lindex $modpoi(var,home) 3]
      #--- Ajoute deux lignes à la matrice
      ::console::affiche_resultat "$deltah $deltad $dec $h\n"
      set res [modpoi_addobs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $h $phi]
      set vecY [lindex $res 0]
      set matX [lindex $res 1]
      set vecW [lindex $res 2]
      #--- Dans un fichier
      append texte "$h [mc_angle2deg $dec 90] $deltah $deltad\n"
   }
   #--- Cree un fichier de resultats o-c
   set output [ open [ file join $audace(rep_plugin) tool modpoi test_modpoi $modpoi(Filename)_inp.txt ] w ]
   puts -nonewline $output $texte
   close $output
   #--- Calcul des coefficients
   set res [gsl_mfitmultilin $vecY $matX $vecW]
   set output [ open [ file join $audace(rep_plugin) tool modpoi model_modpoi $modpoi(Filename).txt ] w ]
   puts -nonewline $output "$res $modpoi(corrections,refraction)"
   close $output
   #--- Affecte le modèle pour l'objet télescope
   if { [ ::tel::list ] == "" } {
   } else {
      tel$audace(telNo) model modpoi_cat2tel modpoi_tel2cat
   }
   return $res
}

proc modpoi_addobs { vecY matX vecW deltah deltad dec h phi } {
   set tand [expr tan([mc_angle2rad $dec]) ]
   set cosh [expr cos([mc_angle2rad $h]) ]
   set sinh [expr sin([mc_angle2rad $h]) ]
   set cosd [expr cos([mc_angle2rad $dec]) ]
   set sind [expr sin([mc_angle2rad $dec]) ]
   set secd [expr 1./cos([mc_angle2rad $dec]) ]
   set sinphi [expr sin([mc_angle2rad $phi]) ]
   set cosphi [expr cos([mc_angle2rad $phi]) ]
   #---
   #--- dh
   set res ""
   lappend res 1
   lappend res 0
   lappend res $tand
   lappend res $secd
   lappend res [expr $sinh*$tand]
   lappend res [expr -1.*$cosh*$tand]
   lappend res 0
   lappend res [expr -1.*$sinh*$secd]                         ; #--- MT : Mount Flexure
   lappend res [expr -1.*$cosphi*$cosh-1.*$sinphi*$tand]      ; #--- DAF : Delta Axis Flexure
   lappend res [expr $cosphi*$sinh*$secd]                     ; #--- TF : Tube Flexure
   #---
   lappend matX $res
   lappend vecY $deltah
   lappend vecW 0.5
   #--- ddec
   set res ""
   lappend res 0
   lappend res 1
   lappend res 0
   lappend res 0
   lappend res $cosh
   lappend res $sinh
   lappend res $cosh                                          ; #--- Fo : Fork Flexure
   lappend res 0
   lappend res 0
   lappend res [expr $cosphi*$cosh*$sind-$sinphi*$cosd]
   #---
   lappend matX $res
   lappend vecY $deltad
   lappend vecW [expr 1.+.00000005]
   #---
   return [list $vecY $matX $vecW]
}

proc modpoi_testcoef { vec chisq covar } {
   global audace modpoi

   #--- Analyse chaque ligne
   set texte ""
   for {set k 1} {$k<=$modpoi(stars,nb)} {incr k} {
      set vecY ""
      set matX ""
      set vecW ""
      #--- Met en forme les valeurs
      set deltah [expr 60*[mc_anglescomp $modpoi(star$k,ra_obs) - $modpoi(star$k,ra_cal)]]
      set deltad [expr 60*[mc_anglescomp $modpoi(star$k,dec_obs) - $modpoi(star$k,dec_cal)]]
      set dec $modpoi(star$k,dec_cal)
      set h $modpoi(star$k,h_cal)
      set phi [lindex $modpoi(var,home) 3]
      #--- Ajoute deux lignes à la matrice
      set res [modpoi_addobs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $h $phi]
      set matX [lindex $res 1]
      #--- Calcul direct
      set res [gsl_mmult $matX $vec]
      set dra_c [lindex $res 0]
      set ddec_c [lindex $res 1]
      #--- Dans un fichier
      append texte "$h [mc_angle2deg $dec 90] $deltah $deltad $dra_c $ddec_c\n"
   }
   #--- Cree un fichier de resultats o-c
   set input [ open [ file join $audace(rep_plugin) tool modpoi test_modpoi $modpoi(Filename)_test.txt ] w ]
   puts -nonewline $input $texte
   close $input
   return $texte
}

proc modpoi_cat2tel { radec } {
   global modpoi

   #--- Catalog 2 observed
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set listv [modpoi_catalogmean2apparent [lindex $radec 0] [lindex $radec 1] J2000.0 $now]
   #--- Case :
   #--- The telescope mount computes the refraction corrections
   #--- yes = 1 (case of the Meade LX200, Sky Sensor 2000, ...)
   #--- no  = 0 (case of the AudeCom, ...)
   if {$modpoi(corrections,refraction)==0} {
      set listv [modpoi_apparent2observed $listv 101325 290 $now]
   }
   set radec [lrange $listv 0 1]
   #--- Observed 2 telescope
   return [modpoi_passage $radec cat2tel ]
}

proc modpoi_tel2cat { radec } {
   global modpoi

   #--- Telescope 2 observed
   set radec [modpoi_passage $radec tel2cat ]
   #--- Observed 2 catalog
   set now now
   catch {set now [::audace::date_sys2ut now]}
   #--- Case :
   #--- The telescope mount computes the refraction corrections
   #--- yes = 1 (case of the Meade LX200, Sky Sensor 2000, ...)
   #--- no  = 0 (case of the AudeCom, ...)
   if {$modpoi(corrections,refraction)==0} {
      set radec [modpoi_observed2apparent [lindex $radec 0] [lindex $radec 1] 101325 290 $now]
   }
   set radec [modpoi_apparent2catalogmean $radec J2000.0 $now]
   set ra [mc_angle2hms [lindex $radec 0] 360 zero 1 auto string]
   set dec [mc_angle2dms [lindex $radec 1] 90 zero 1 + string]
   return [list $ra $dec]
}

proc modpoi_passage { radec sens } {
   global modpoi

   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   if {$sens=="cat2tel"} {
      set signe +
   } else {
      set signe -
   }
   #--- Met en forme les valeurs
   set deltah 0
   set deltad 0
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set phi [lindex $modpoi(var,home) 3]
   set ra0 $ra
   set dec0 $dec
   #--- Calcule l'angle horaire
   set dummy [mc_radec2altaz $ra $dec $modpoi(var,home) $now]
   set h [lindex $dummy 2]
   #--- Ajoute deux lignes à la matrice
   set vecY ""
   set matX ""
   set vecW ""
   set res [modpoi_addobs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $h $phi]
   set matX [lindex $res 1]
   #--- Calcul direct
   set res [gsl_mmult $matX $modpoi(vec)]
   set dra_c [expr [lindex $res 0]/60.]
   set ddec_c [expr [lindex $res 1]/60.]
   set ra [mc_angle2hms [mc_anglescomp $ra0 $signe $dra_c] 360 nozero 1 auto string]
   set dec [mc_angle2dms [mc_anglescomp $dec0 $signe $ddec_c] 90 nozero 0 + string]
   if {$sens=="tel2cat"} {
      #--- On itere dans le sens inverse pour gagner la precision de
      #--- la derive lors de la difference tel-cat.
      #--- Calcule l'angle horaire
      set dummy [mc_radec2altaz $ra $dec $modpoi(var,home) $now]
      set h [lindex $dummy 2]
      #--- Ajoute deux lignes à la matrice
      set vecY ""
      set matX ""
      set vecW ""
      set res [modpoi_addobs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $h $phi]
      set matX [lindex $res 1]
      #--- Calcul direct
      set res [gsl_mmult $matX $modpoi(vec)]
      set dra_c [expr [lindex $res 0]/60.]
      set ddec_c [expr [lindex $res 1]/60.]
      set ra [mc_angle2hms [mc_anglescomp $ra0 $signe $dra_c] 360 nozero 1 auto string]
      set dec [mc_angle2dms [mc_anglescomp $dec0 $signe $ddec_c] 90 nozero 0 + string]
   }
   set ratel $ra
   set dectel $dec
   return [list $ratel $dectel]
}

proc modpoi_load { { fileres "modpoi_res.txt" } } {
   global audace caption modpoi

   set modpoi(modpoi_choisi) $fileres
   load libgsltcl[info sharedlibextension]
   set num [ catch { set input [ open [ file join $audace(rep_plugin) tool modpoi model_modpoi $fileres ] r ] } msg ]
   if { $num!="1"} {
      set res [read $input]
      close $input
      set modpoi(vec) [lindex $res 0]
      set modpoi(chisq) [lindex $res 1]
      set modpoi(covar) [lindex $res 2]
      catch { set modpoi(corrections,refraction) [lindex $res 3] }
      set modpoi(pi) 3.1415926535897
      set modpoi(deg2rad) [expr $modpoi(pi)/180.]
      set modpoi(rad2deg) [expr 180./$modpoi(pi)]
      if {[info exists audace(posobs,observateur,gps)]==1} {
         set modpoi(var,home) $audace(posobs,observateur,gps)
      } else {
         set modpoi(var,home) "GPS 2 E 48 0"
      }
      if { [ ::tel::list ] == "" } {
      } else {
         tel$audace(telNo) model modpoi_cat2tel modpoi_tel2cat
      }
      tk_messageBox -title "$caption(modpoi,wiz1b,warning)" -message "$caption(modpoi,modele_existe)" -type ok
      return $modpoi(vec)
   } else {
      if { [ info exists modpoi(vec) ] == "1" } {
         tk_messageBox -title "$caption(modpoi,wiz1b,warning)" -message "$caption(modpoi,modele_non_charge)\n\
            $caption(modpoi,modele_precedent)" -icon error
      } else {
         tk_messageBox -title "$caption(modpoi,wiz1b,warning)" -message "$caption(modpoi,modele_non_charge)" -icon error
      }
   }
}

proc modpoi_rien { } {
#--- Juste un petit script pour montrer la prise en compte dans tel$audace(telNo)
   global audace modpoi

   load libgsltcl[info sharedlibextension]
   source model.tcl
   tel$audace(telNo) model modpoi_cat2tel modpoi_tel2cat
   set modpoi(vec) {-17 -5 -20 19 -11 -1.5 19}
   tel$audace(telNo) radec coord
}

proc modpoi_recomputecoef { { fileinp "modpoi_inp.txt" } } {
#--- Recalcule le modele de pointage a partir du fichier modpoi_inp.txt
   global audace caption modpoi

   load libgsltcl[info sharedlibextension]
   set num [ catch { set input [ open [ file join $audace(rep_plugin) tool modpoi test_modpoi $fileinp ] r ] } msg ]
   if { $num!="1"} {
      set obs [split [read $input] \n]
      close $input
      set modpoi(stars,nb) [expr [llength $obs]-1]
      for {set k 1} {$k<=$modpoi(stars,nb)} {incr k} {
         set kk [expr $k-1]
         set ligne [lindex $obs $kk]
         set modpoi(star$k,ra_cal) [mc_angle2deg [lindex $ligne 0] 360]
         set modpoi(star$k,dec_cal) [mc_angle2deg [lindex $ligne 1] 90]
         set modpoi(star$k,ra_obs) [mc_angle2deg [expr $modpoi(star$k,ra_cal)+[lindex $ligne 2]/60.]]
         set modpoi(star$k,dec_obs) [mc_angle2deg [expr $modpoi(star$k,dec_cal)+[lindex $ligne 3]/60.]]
         set modpoi(star$k,h_cal) $modpoi(star$k,ra_cal)
      }
      #--- Calcul du modele de pointage
      set k [string last _ $fileinp]
      if {$k>0} {
         set fileinp2 [string range $fileinp 0 [expr $k-1]]
      } else {
         set fileinp2 manual
      }
      set res [modpoi_computecoef $fileinp2]
      set vec   [lindex $res 0]
      set chisq [lindex $res 1]
      set covar [lindex $res 2]
      modpoi_testcoef $vec $chisq $covar
      #--- Affichage joli
      modpoi_load
      modpoi_wiz edit
   } else {
      set datas no
      if {$datas=="yes"} {
         #--- Mesures (H,DEC)cat -> (H,DEC)->tel
         set obs {\
         {+00h36m09s -22d55m07s +00h35m48s -22d58m16s }\
         {+01h56m16s -10d11m30s +01h56m01s -10d10m56s }\
         {+00h10m12s -08d50m53s +00h09m53s -08d53m53s }\
         {+00h05m52s +04d08m02s +00h05m27s +04d05m23s }\
         {-01h40m48s +07d01m53s -01h41m02s +06d57m41s }\
         {-02h37m23s -09d35m59s -02h37m45s -09d40m10s }\
         {-01h54m01s -22d17m09s -01h54m26s -22d22m15s }\
         {+00h09m59s -23d34m06s +00h09m42s -23d37m28s }\
         {+02h29m50s -18d04m01s +02h29m47s -17d59m12s }\
         {+01h12m45s +02d47m13s +01h12m21s +02d45m49s } }
         #--- Conversion des mesures
         set modpoi(stars,nb) [llength $obs]
         for {set k 1} {$k<=$modpoi(stars,nb)} {incr k} {
            set kk [expr $k-1]
            set ligne [lindex $obs $kk]
            set modpoi(star$k,ra_cal) [mc_angle2deg [lindex $ligne 0] 360]
            set modpoi(star$k,dec_cal) [mc_angle2deg [lindex $ligne 1] 90]
            set modpoi(star$k,ra_obs) [mc_angle2deg [lindex $ligne 2] 360]
            set modpoi(star$k,dec_obs) [mc_angle2deg [lindex $ligne 3] 90]
            set modpoi(star$k,h_cal) $modpoi(star$k,ra_cal)
         }
         #--- Calcul du modele de pointage
         set k [string last _ $fileinp]
         if {$k>0} {
            set fileinp2 [string range $fileinp 0 [expr $k-1]]
         } else {
            set fileinp2 manual
         }
         set res [modpoi_computecoef $fileinp2]
         set vec   [lindex $res 0]
         set chisq [lindex $res 1]
         set covar [lindex $res 2]
         modpoi_testcoef $vec $chisq $covar
         #--- Affichage joli
         modpoi_load
         modpoi_wiz edit
      } else {
         tk_messageBox -title "$caption(modpoi,wiz1b,warning)" -message "$caption(modpoi,modele_non_charge)" -icon error
      }
   }
}

proc modpoi_autocentering { } {
   global audace caption modpoi

   #--- Center automaticaly the brightest star
   if {$modpoi(centering,mode)=="manu"} { return }
   if {[::tel::list]==""} { return }
   set xc0 $modpoi(centering,xc)
   set yc0 $modpoi(centering,yc)
   set sortie "no"
   set t0 $modpoi(centering,t0)
   set try 1
   set trymax 12
   set supertry 1
   set supertrymax 4
   set efficiency 0.5
   set calibrated "no"
   set t0lim [expr 4.*$t0]
   set texte "\n$caption(modpoi,consignes) ( $xc0 : $yc0 )\n"
   ::console::affiche_resultat "$texte"
   set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
   puts -nonewline $f "$texte"
   close $f
   set coord0 [tel$audace(telNo) radec coord]
   while {$sortie=="no"} {
      set res [modpoi_acqxy]
      set xc [lindex $res 0]
      set yc [lindex $res 1]
      if {$calibrated=="no"} {
         #--- Calibrate the matrix orientation
         set texte "$caption(modpoi,etalonnage)\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         set texte " $caption(modpoi,etat_initial) x=$xc y=$yc\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         ::telescope::setSpeed 2
         ::telescope::move e
         after $t0
         ::telescope::stop e
         set res [modpoi_acqxy]
         set xce [lindex $res 0]
         set yce [lindex $res 1]
         set texte " $caption(modpoi,shift-e) x=$xce y=$yce\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         ::telescope::move n
         after $t0
         ::telescope::stop n
         set res [modpoi_acqxy]
         set xcen [lindex $res 0]
         set ycen [lindex $res 1]
         set texte " $caption(modpoi,shift_n) x=$xcen y=$ycen\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         #---
         set dxe [expr $xce-$xc]
         set dye [expr $yce-$yc]
         set dxn [expr $xcen-$xce]
         set dyn [expr $ycen-$yce]
         set texte " dxe=$dxe dye=$dye\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         set texte " dxn=$dxn dyn=$dyn\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         #---
         set calibrated "yes"
      } else {
         #--- use calibration dx = te/t0*dxe + tn/t0*dxn
         #--- use calibration dy = te/t0*dye + tn/t0*dyn
         #--- (dy,dy) measured
         #--- (t0,dxe,dyn) knowns
         #--- (te,tn) are to be computed
         set texte "$caption(modpoi,iteration) $try :\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         set texte " xc=$xc yc=$yc\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         set dx [expr $xc-$xc0]
         set dy [expr $yc-$yc0]
         #---
         set dxa [expr abs($dx)]
         set dya [expr abs($dy)]
         #---
         set texte " dx=$dx dy=$dy\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
         $modpoi(g,base).lab_dist configure -text "$supertry : $try\ndx=$dx dy=$dy"
         update
         if {($dxa<=$modpoi(centering,accuracy))&&($dya<=$modpoi(centering,accuracy))} {
            set sortie yes
         } else {
            #---
            set deno [expr ($dxn*$dye-$dyn*$dxe)]
            if {$deno!=0} {
               set tn [expr $t0*($dx*$dye-$dy*$dxe)/($deno)]
               set te [expr $t0*($dx*$dyn-$dy*$dxn)/(-1.*$deno)]
            } else {
               set tn 0.
               set te 0.
            }
            #---
            set tnabs [expr int(abs($tn*$efficiency))]
            set teabs [expr int(abs($te*$efficiency))]
            #---
            if {$tnabs>$t0lim} {set tnabs [expr int($t0lim)]}
            if {$teabs>$t0lim} {set teabs [expr int($t0lim)]}
            #---
            if {$tn>0} {
               set dirn s
            } else {
               set dirn n
            }
            if {$te>0} {
               set dire w
            } else {
               set dire e
            }
            #---
            set texte " tn=$tn te=$te\n"
            ::console::affiche_resultat "$texte"
            set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
            puts -nonewline $f "$texte"
            close $f
            set texte " move : ${tnabs}$dirn ${teabs}$dire\n"
            ::console::affiche_resultat "$texte"
            set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
            puts -nonewline $f "$texte"
            close $f
            ::telescope::setSpeed 2
            ::telescope::move $dirn
            after $tnabs
            ::telescope::stop $dirn
            ::telescope::move $dire
            after $teabs
           ::telescope::stop $dire
        }
      }
      incr try
      if {$try>$trymax} {
         if {$supertry<$supertrymax} {
            incr supertry
            set sortie no
            tel$audace(telNo) radec goto $coord0
            set calibrated "no"
            set try 1
         } else {
            set sortie yes
            set calibrated "yes"
         }
         set texte "$caption(modpoi,non_centree)\n"
         ::console::affiche_resultat "$texte"
         set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
         puts -nonewline $f "$texte"
         close $f
      }
   }
}

proc modpoi_acqxy { } {
   #--- Acquire one image and return xc,yc of photocenter of the brightest star.
   global audace caption conf modpoi

   if {[::cam::list]!=""} {
      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$audace(camNo) nbcells ]
         cam$audace(camNo) window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }
      #---
      cam$audace(camNo) exptime $modpoi(centering,exptime)
      cam$audace(camNo) bin [list $modpoi(centering,binning) $modpoi(centering,binning)]
      #---
      set modpoi(centering,nbmean) [expr int($modpoi(centering,nbmean))]
      if {$modpoi(centering,nbmean)>5} { set modpoi(centering,nbmean) 5}
      if {$modpoi(centering,nbmean)<1} { set modpoi(centering,nbmean) 1}
      set nb $modpoi(centering,nbmean)
      for {set k 1} {$k<=$nb} {incr k} {
         cam$audace(camNo) acq
         vwait status_cam$audace(camNo)
         saveima i$k
      }
      if {$nb>1} {
         smean i i $nb
         loadima i
      }
      #---
      buf$audace(bufNo) imaseries "BACK back_kernel=10 back_threshold=0.2 sub"
      set dimxy [cam$audace(camNo) nbpix]
      set dimx [lindex $dimxy 0]
      set dimy [lindex $dimxy 1]
      set x1 2
      set y1 2
      set x2 [expr $dimx-2]
      set y2 [expr $dimy-2]
      set box [list $x1 $y1 $x2 $y2]
      set res [buf$audace(bufNo) centro $box]
      ::audace::autovisu $audace(visuNo)
      set filename [mc_date2jd now]
      saveima ${filename}w$conf(extension,defaut)
      set texte "$caption(modpoi,fichier) ${filename}w$conf(extension,defaut)\n"
      ::console::affiche_resultat "$texte"
      set f [ open [ file join $audace(rep_plugin) tool modpoi modpoi.log ] a ]
      puts -nonewline $f "$texte"
      close $f
      #---
      #::cam::create audine lpt1 -num 2
      #cam2 buf 1
      #cam2 exptime 0
      #cam2 bin {4 4}
      #cam2 acq
      #vwait status_cam2
      #saveima ${filename}a$conf(extension,defaut)
      #::cam::delete 2
      #---
   } else {
      set res {0. 0.}
   }
   return $res
}

proc run_name_modpoi { } {
   variable This
   global audace modpoi

   #---
   set This "$audace(base).modpoi_fntr.name_modpoi"
   #---
   createDialog_name_modpoi
   if { [ info exists modpoi(geometry,name_modpoi) ] } {
      wm geometry $This $modpoi(geometry,name_modpoi)
   }
   tkwait variable modpoi(flag)
   return $modpoi(Filename)
}

proc createDialog_name_modpoi { } {
   variable This
   global audace caption modpoi

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   toplevel $This
   wm resizable $This 0 0
   wm deiconify $This
   wm title $This "$caption(modpoi,define_mame_modpoi)"
   wm geometry $This +180+50
   wm transient $This $audace(base).modpoi_fntr
   wm protocol $This WM_DELETE_WINDOW cmdClose_name_modpoi

   #--- Cree un frame pour y mettre le bouton et la zone a renseigner
   frame $This.frame1 -borderwidth 1 -relief raised
      #--- Positionne le label, la zone a renseigner et le bouton
      label $This.frame1.lab1 -text "$caption(modpoi,name_modpoi)"
      pack $This.frame1.lab1 -side left -padx 5 -pady 5
      entry $This.frame1.ent1 -textvariable modpoi(Filename) -width 40
      pack $This.frame1.ent1 -side left -padx 5 -pady 5
      button $This.frame1.explore -text "$caption(modpoi,parcourir)" -width 1 -command {
         #--- Fenetre parent
         set fenetre "$audace(base).modpoi_fntr"
         #--- Repertoire contenant les modeles de pointage
         set initialdir [ file join $audace(rep_plugin) tool modpoi model_modpoi ]
         #--- Ouvre la fenetre de choix des modeles de pointage
         set modpoi(Filename) [ ::tkutil::box_load $fenetre $initialdir $audace(bufNo) "10" ]
         #--- Extraction du nom du fichier
         set modpoi(Filename) [ file rootname [ file tail $modpoi(Filename) ] ]
      }
      pack $This.frame1.explore -side left -padx 5 -pady 5 -ipady 5
   pack $This.frame1 -side top -fill both -expand 1

   #--- Cree un frame pour y mettre le bouton
   frame $This.frame2 -borderwidth 1 -relief raised
      #--- Cree le bouton 'OK'
      button $This.frame2.ok -text "$caption(modpoi,ok)" -width 8 -command { cmdOk_name_modpoi }
      pack $This.frame2.ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
   pack $This.frame2 -side top -fill x

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc cmdOk_name_modpoi { } {
   variable This
   global modpoi

   set modpoi(flag) "1"
   set modpoi(geometry,name_modpoi) [ wm geometry $This ]
   destroy $This
   unset modpoi(flag)
   unset This
}

proc cmdClose_name_modpoi { } {
   #--- Empeche de fermer la fenetre
}

