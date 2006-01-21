#
# Fichier : skybot_search.tcl
# Description : Recherche d'objets dans le champ d'une image
# Auteur : Jerome BERTHIER, Robert DELMAS, Alain KLOTZ et Michel PUJOL
# Date de mise a jour : 15 novembre 2005
#

namespace eval skybot_Search {
   global audace
   global voconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_search.cap ]\""

   #
   # skybot_Search::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This
      variable column_format
      global caption

      array set column_format { }
      #---
      set column_format(Num)          [ list 9  "$caption(search,num)"        right ]
      set column_format(Name)         [ list 12 "$caption(search,name)"       left ]
      set column_format(RAh)          [ list 12 "$caption(search,rah)"        right ]
      set column_format(DEdeg)        [ list 14 "$caption(search,dedeg)"      right ]
      set column_format(Class)        [ list 8  "$caption(search,class)"      left ]
      set column_format(Mv)           [ list 8  "$caption(search,mv)"         right ]
      set column_format(Errarcsec)    [ list 12 "$caption(search,errarcsec)"  right ]
      set column_format(darcsec)      [ list 11 "$caption(search,darcsec)"    right ]
      set column_format(dRAarcsec/h)  [ list 15 "$caption(search,draarcsec)"  right ]
      set column_format(dDECarcsec/h) [ list 16 "$caption(search,ddecarcsec)" right ]
      set column_format(Dgua)         [ list 17 "$caption(search,dgua)"       right ]
      set column_format(Dhua)         [ list 17 "$caption(search,dhua)"       right ]
      #---
      set This $this
      createDialog 
      tkwait visibility $This
   }

   #
   # skybot_Search::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This
      global audace

      #--- Efface les reperes des objets
      $audace(hCanvas) delete cadres
      #---
      ::skybot_Search::recup_position
      destroy $This
   }

   #
   # skybot_Search::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
   #
   proc recup_position { } {
      variable This
      global audace
      global conf
      global voconf

      set voconf(geometry_search) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $voconf(geometry_search) ] ]
      set fin [ string length $voconf(geometry_search) ]
      set voconf(position_search) "+[ string range $voconf(geometry_search) $deb $fin ]"
      #---
      set conf(vo_tools,position_search) $voconf(position_search)
   }

   #
   # skybot_Search::charger
   # Permet de charger l'image a analyser
   #
   proc charger { } {
      variable This
      global audace
      global caption
      global voconf
      global current_object

      #--- Initialisation
      set voconf(image_existe)       "0"
      set voconf(centre_ad_image)    ""
      set voconf(centre_ad_image_h)  ""
      set voconf(centre_dec_image)   ""
      set voconf(centre_dec_image_d) ""
      set voconf(taille_champ_min)   ""
      set voconf(pose)               "0"
      set voconf(unite_pose)         "0"
      set voconf(origine_pose)       "0"
      set voconf(date_image)         ""
      set current_object(num)        "-1"

      #--- Efface les reperes des objets
      $audace(hCanvas) delete cadres

      #--- Gestion des boutons
      $::skybot_Search::This.frame6.but_recherche configure -relief raised -state disabled

      #--- Fenetre parent
      set fenetre "$This"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction et chargement du fichier
      set voconf(nom_image) $filename
      if { $voconf(nom_image) != "" } {
         loadima $voconf(nom_image)
      } else {
         return
      }

      #--- Verification de la calibration astrometrique de l'image
      set calibration [ ::skybot_Search::image_calibree_astrom ]

      #--- Il existe 2 cas
      if { $calibration == "1" } {
         #--- L'image est calibree astrometriquement

         #--- Gestion des boutons
         $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal

         #--- RAZ de la liste
         $::skybot_Search::This.frame7.tbl delete 0 end
         if { [ $::skybot_Search::This.frame7.tbl columncount ] != "0" } {
            $::skybot_Search::This.frame7.tbl deletecolumns 0 end
         }

         #--- Calcule les coordonnees equatoriales du centre de l'image
         ::skybot_Search::Centre&Champ

         #--- A-t-on choisi l'unite de la duree de pose ?
         if { $voconf(unite_pose) == "0" } {
            set choix [ tk_messageBox -title $caption(search,msg_attention) -type yesno \
               -message $caption(search,msg_unite_pose) ]
            if { $choix == "yes" } {
               set voconf(unite_pose) "1"
            } else {
               set voconf(unite_pose) "2"
            }
         }

         #--- A-t-on choisi l'origine de la date ?
         if { $voconf(origine_pose) == "0" } {
            set choix [ tk_messageBox -title $caption(search,msg_attention) -type yesno \
               -message $caption(search,msg_origine_pose) ]
            if { $choix == "yes" } {
               set voconf(origine_pose) "1"
            } else {
               set voconf(origine_pose) "2"
            }
         }

	 #--- Recherche du temps de pose de l'image (si non trouve alors 1s)
	 set voconf(pose) [ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]
	 if { [ string length $voconf(pose) ] == "0" } {
            set voconf(pose) [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
	 }
	 if { [ string length $voconf(pose) ] == "0" } {
            set voconf(pose) [ lindex [ buf$audace(bufNo) getkwd "EXP_TIME" ] 1 ]
	 }
	 if { [ string length $voconf(pose) ] == "0" } {
            set voconf(pose) 1
	 }

         #--- Affichage de la date de l'image
         ::skybot_Search::DateImage

         #--- Trace du chargement d'une image
         set voconf(image_existe) "1"

      } else {
         #--- L'image n'est pas calibree astrometriquement

         #--- Fermeture de l'interface
         ::skybot_Search::fermer

         #--- Execution de la calibration astrometrique
         ::astrometry::create

      }
   }

   #
   # skybot_Search::image_calibree_astrom
   # Permet de verifier qu'une image est calibree astrometriquement ou non
   #
   proc image_calibree_astrom { } {
      global audace
      global caption
      global voconf

      set calib "1"
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CRPIX1 ] 0 ] "" ] == "0" } {
         set calib "0"
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CRPIX2 ] 0 ] "" ] == "0" } {
         set calib "0"
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CRVAL1 ] 0 ] "" ] == "0" } {
         set calib "0"
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CRVAL2 ] 0 ] "" ] == "0" } {
         set calib "0"
      }
      set nouveau "0"
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CD1_1 ] 0 ] "" ] != "0" } {
         incr nouveau
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CD1_2 ] 0 ] "" ] != "0" } {
         incr nouveau
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CD2_1 ] 0 ] "" ] != "0" } {
         incr nouveau
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CD2_2 ] 0 ] "" ] != "0" } {
         incr nouveau
      }
      set classic "0"
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CDELT1 ] 0 ] "" ] != "0" } {
         incr classic
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CDELT2 ] 0 ] "" ] != "0" } {
         incr classic
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CROTA1 ] 0 ] "" ] != "0" } {
         incr classic
      }
      if { [ string compare [ lindex [ buf$audace(bufNo) getkwd CROTA2 ] 0 ] "" ] != "0" } {
         incr classic
      }
      if { ( ( $calib == "1" ) && ( $nouveau == "4" ) ) || ( ( $calib == "1" ) && ( $classic >= "3" ) ) } {
         tk_messageBox -title $caption(search,verif_calibration) -type ok -message $caption(search,calibr_astrom_oui)
         set calibration "1"
      } else {
         tk_messageBox -title $caption(search,verif_calibration) -type ok -message $caption(search,calibr_astrom_non)
         set calibration "0"
      }
      return $calibration
   }

   #
   # skybot_Search::Centre&Champ
   # Permet de calculer les coordonnees du centre de l'image et son champ
   #
   proc Centre&Champ { } {
      global audace
      global voconf

      #--- Coordonnees du centre de l'image
      #--- Dimensions de l'image en pixels
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      set naxis2 [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]

      #--- Coordonnees en pixels du centre de l'image
      set xc [ expr $naxis1/2. ]
      set yc [ expr $naxis2/2. ]

      #--- Coordonnees equatoriales du centre de l'image
      set AD_Dec_c [ buf$audace(bufNo) xy2radec [ list $xc $yc ] 2 ]
      set AD_c     [ lindex $AD_Dec_c 0 ]
      set AD_c_h   [ mc_angle2hms $AD_c 360 zero 2 auto string ]
      set Dec_c    [ lindex $AD_Dec_c 1 ]
      set Dec_c_d  [ mc_angle2dms $Dec_c 90 zero 2 + string ]

      #--- Coordonnees pour l'interface de l'outil
      set voconf(centre_ad_image)    [ format "%.4f" $AD_c ]
      set voconf(centre_dec_image)   [ format "%.4f" $Dec_c ]
      set voconf(centre_ad_image_h)  $AD_c_h
      set voconf(centre_dec_image_d) $Dec_c_d

      #--- Calcul du champ de l'image
      #--- Coordonnees du coin inferieur gauche de l'image
      set AD_Dec_1_1      [ buf$audace(bufNo) xy2radec [ list 1 1 ] 2 ]
      set AD_1_1          [ lindex $AD_Dec_1_1 0 ]
      set voconf(AD_1_1)  $AD_1_1
      set AD_1_1_h        [ mc_angle2hms $AD_1_1 360 zero 2 auto string ]
      set Dec_1_1         [ lindex $AD_Dec_1_1 1 ]
      set voconf(Dec_1_1) $Dec_1_1
      set Dec_1_1_d       [ mc_angle2dms $Dec_1_1 90 zero 2 + string ]

      #--- Coordonnees du coin superieur droit de l'image
      set AD_Dec_n_n      [ buf$audace(bufNo) xy2radec [ list $naxis1 $naxis2 ] 2 ]
      set AD_n_n          [ lindex $AD_Dec_n_n 0 ]
      set voconf(AD_n_n)  $AD_n_n
      set AD_n_n_h        [ mc_angle2hms $AD_n_n 360 zero 2 auto string ]
      set Dec_n_n         [ lindex $AD_Dec_n_n 1 ]
      set voconf(Dec_n_n) $Dec_n_n
      set Dec_n_n_d       [ mc_angle2dms $Dec_n_n 90 zero 2 + string ]

      #--- Dimension de la diagonale, donc du champ de l'image
      set d [ lindex [ mc_anglesep [ list $AD_1_1 $Dec_1_1 $AD_n_n $Dec_n_n ] ] 0 ]

      #--- Champ de l'image, diagonale de l'image
      set voconf(taille_champ_min) [ format "%.3f" [ expr $d * 60.0 ] ]
   }

   #
   # skybot_Search::DateImage
   # Permet de calculer la date de l'image
   #
   proc DateImage { } {
      global audace
      global voconf

      set exposure $voconf(pose)
      #--- Si la duree de pose est en minutes
      if { $voconf(unite_pose) == "2" } {
         set exposure [ expr $exposure * 60.0 ]
      }

      #--- Calcul de la date exacte
      set jd [ JourJulienImage ]
      if { $voconf(origine_pose) == "1" } {
         #--- Cas du début de pose (on rajoute le 1/2 temps de pose converti en Jour Julien)
         set voconf(date_image) [ expr $jd + ( $exposure / 172800.0 ) ]
      } else {
         #--- Cas du milieu de pose
         set voconf(date_image) $jd
      }
      #--- Date au format ISO8601 (en-tete FITS)
      set voconf(date_image) [ mc_date2iso8601 $voconf(date_image) ]
   }

   #
   # skybot_Search::JourJulienImage
   # Cette procedure recupere le Jour Julien de l'image active
   # Elle marche pour les images des logiciels suivants :
   # 1/ CCDSoft v5 : DATE-OBS = la date uniquement
   #                 TIME-OBS = l'heure de debut en TU
   #                 EXPOSURE = le temps d'exposition en secondes
   # 2/ PRISM v4   : DATE-OBS = date et heure de debut de pose
   #                 (format ISO 8601 : 'aaaa-mm-jjThh:mm:ss.sss')
   #                 UT-START & UT-END sont valides mais non utilisé
   #                 EXPOSURE = le temps d'exposition en minutes
   #
   proc JourJulienImage { } {
      global audace
      global caption

      #--- Recherche du mot clef DATE-OBS dans l'en-tete FITS
      set date [ lindex [ buf$audace(bufNo) getkwd DATE-OBS ] 1 ]
      #--- Si la date n'est pas au format ISO 8601 (date + heure)
      if { [ string range $date 10 10 ] != "T" } {
         #--- Recherche le mot clef TIME-OBS
         set time [ buf$audace(bufNo) getkwd TIME-OBS ]
         set time [ lindex $time 1 ]
         if { [ string length $time ] != "0" } {
            #--- ...convertit en format ISO 8601
            set date [ string range $date 0 9 ]
            set time [ string range $time 0 7 ]
            append date "T"
            append date $time
         } else {
            set time [ buf$audace(bufNo) getkwd UT-START ]
            set time [ lindex $time 1 ]
            if { [ string length $time ] != "0" } {
               #--- ...convertit en format ISO 8601
               set date [ string range $date 0 9 ]
               set time [ string range $time 0 7 ]
               append date "T"
               append date $time
            } else {
               tk_messageBox -title $caption(search,msg_erreur) -type ok -message $caption(search,msg_pas_heure)
            }
         }
      } else {
         set date [ string range $date 0 22 ]
      }

      #--- Conversion en Jour Julien
      set jd_instant [ mc_date2jd $date ]

      return $jd_instant
   }

   #
   # skybot_Search::GetInfo
   # Affichage d'un message sur le format d'une saisie
   #
   proc GetInfo { subject } {
      global caption
      global voconf
      switch $subject {
         ad          { set msg $caption(search,format_ad) }
         dec         { set msg $caption(search,format_dec) }
         taille      { set msg $caption(search,format_taille) }
         date        { set msg $caption(search,format_date) }
         fixecircle  { set msg $caption(search,format_fixecircle) }
         basecircle  { set msg $caption(search,format_basecircle) }
         scalecircle { set msg $caption(search,format_scalecircle) }
         basearrow   { set msg $caption(search,format_basearrow) }
         spin        { set msg $caption(search,[concat "format_spin$voconf(type_filtre)"]) }
         default     { set msg $caption(search,param_none) }
      }
      tk_messageBox -title $caption(search,msg_format) -type ok -message $msg
      return 1
   }

   #
   # skybot_Search::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global fov
      global audace
      global caption
      global conf
      global voconf

      #--- Initialisation
      set voconf(image_existe)       "0"
      set voconf(nom_image)          ""
      set voconf(centre_ad_image)    ""
      set voconf(centre_ad_image_h)  ""
      set voconf(centre_dec_image)   ""
      set voconf(centre_dec_image_d) ""
      set voconf(taille_champ_min)   ""
      set voconf(pose)               "0"
      set voconf(unite_pose)         "0"
      set voconf(origine_pose)       "0"
      set voconf(date_image)         ""

      #--- Valeurs min-max par defaut pour les filtres
      set voconf(min_mag) "-30"
      set voconf(max_mag) "30"
      set voconf(min_err) "0"
      set voconf(max_err) "1000"
      set voconf(min_dig) "0"
      set voconf(max_dig) "150"
      set voconf(min_dih) "0"
      set voconf(max_dih) "150"
      set voconf(min_ppm) "0"
      set voconf(max_ppm) "2000"
      #--- Rayon fixe des cercles materialisant les objets sur l'image
      set voconf(radius_fixe)  "10.0"
      #--- Rayon de base des cercles materialisant les objets filtres sur l'image
      set voconf(radius_base)  "2.0"
      #--- Facteur multiplicatif pour le calcul des rayons des cercles
      set voconf(radius_scale) "18.0"
      #--- Longueur de base des fleches materialisant le mvt propre des objets
      set voconf(arrow_base)   "5.0"
      #--- Trace un label pour les objets
      set voconf(label_objets) "1"

      #--- Efface les reperes des objets
      $audace(hCanvas) delete cadres

      #--- initConf
      if { ! [ info exists conf(vo_tools,position_search) ] } { set conf(vo_tools,position_search) "+80+40" }
      if { ! [ info exists voconf(trace_efface) ] } { set voconf(trace_efface) "1" }
      if { ! [ info exists voconf(type_filtre) ] } { set voconf(type_filtre) "none" }

      #--- confToWidget
      set voconf(position_search) $conf(vo_tools,position_search)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame6.but_fermer
         return
      }

      #---
      if { [ info exists voconf(geometry_search) ] } {
         set deb [ expr 1 + [ string first + $voconf(geometry_search) ] ]
         set fin [ string length $voconf(geometry_search) ]
         set voconf(position_search) "+[ string range $voconf(geometry_search) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This 600x500$voconf(position_search)
      wm resizable $This 1 1
      wm title $This $caption(search,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::skybot_Search::fermer }

      #--- Cree un frame pour selectionner et charger l'image a analyser
      frame $This.frame1 -borderwidth 0 
      pack $This.frame1 \
         -in $This -anchor s -side top -expand 0 -fill x

         #--- Cree un label
         label $This.frame1.lab \
            -text "$caption(search,nom_image)"
         pack $This.frame1.lab \
            -in $This.frame1 -side left -anchor center \
            -padx 3 -pady 3

         #--- Cree le bouton parcourir
         button $This.frame1.explore -text "$caption(search,parcourir)" -width 1 \
            -command { ::skybot_Search::charger }
         pack $This.frame1.explore -side left -padx 3 -pady 3 -ipady 1

         #--- Cree une ligne d'entree
         entry $This.frame1.ent \
            -textvariable voconf(nom_image) -width 70
         pack $This.frame1.ent \
            -in $This.frame1 -side left -anchor w -expand 1 \
            -padx 5 -pady 3

      #--- Cree un frame pour les caracteristiques de l'image
      frame $This.frame2 -borderwidth 0 
      pack $This.frame2 \
         -in $This -anchor s -side top -expand 0 -fill x \
         -pady 6

        #--- Cree un label pour le titre des caracteristiques de l'image
        label $This.frame2.titre \
          -text "$caption(search,caract_image)" \
          -borderwidth 0 -relief flat
        pack $This.frame2.titre \
          -in $This.frame2 -side top -anchor w \
          -padx 3 -pady 3

        #--- Cree un frame pour les labels des caracteristiques de l'image
        set img [frame $This.frame2.img -borderwidth 1 -relief solid]
        pack $img -in $This.frame2 -anchor w -side top -expand 0 -fill x -padx 10

          #--- Cree un subframe pour le bouton entete-fits
          frame $img.but -borderwidth 0 -relief flat
          pack $img.but \
            -in $img -anchor w -side left -expand 0 -fill x

            #--- Creation du bouton d'affichage de l'en-tete FITS
            button $img.but.but_en-tete_FITS -state normal \
               -text "$caption(search,en-tete_FITS)" -borderwidth 2 \
               -command { ::audace::header }
            pack $img.but.but_en-tete_FITS \
               -in $img.but -side left -anchor w \
               -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          #--- Cree un subframe pour les parametres 
          frame $img.par -borderwidth 0 -relief flat
          pack $img.par \
            -in $img -anchor w -side left -expand 0 -fill x

          #--- Cree un frame pour afficher le temps de pose
          set tdp [frame $img.par.tdp -borderwidth 0]
          pack $tdp -in $img.par -anchor s -side top -expand 0 -fill x

             #--- Cree un label
             label $tdp.label_temps_pose \
               -text "$caption(search,temps_de_pose)" \
               -borderwidth 0 -relief flat
             pack $tdp.label_temps_pose \
               -in $tdp -side left \
               -padx 3 -pady 3

            #--- Cree une ligne d'entree pour la variable temps de pose
            entry $tdp.data_temps_pose \
              -textvariable voconf(pose) \
              -borderwidth 1 -relief groove -width 15 -justify center
            pack $tdp.data_temps_pose \
              -in $tdp -side left -anchor w -padx 3

           #--- Cree un frame pour determiner l'unite du temps de pose
          set utdp [frame $img.par.utdp -borderwidth 0]
          pack $utdp -in $img.par -anchor s -side top -expand 0 -fill x

             #--- Cree un label
             label $utdp.label_unite_pose \
               -text "$caption(search,unite_de_la_pose)" \
               -borderwidth 0 -relief flat
             pack $utdp.label_unite_pose \
               -in $utdp -side left \
               -padx 3 -pady 3

            #--- Bouton radio Secondes
             radiobutton $utdp.radiobutton_secondes -highlightthickness 0 -state normal \
               -text "$caption(search,secondes)" -value 1 -variable voconf(unite_pose) \
               -command { if { $voconf(image_existe) == "1" } { ::skybot_Search::DateImage } }
             pack $utdp.radiobutton_secondes \
               -in $utdp -side left -anchor center \
               -padx 3 -pady 3

             #--- Bouton radio Minutes
             radiobutton $utdp.radiobutton_minutes -highlightthickness 0 -state normal \
               -text "$caption(search,minutes)" -value 2 -variable voconf(unite_pose) \
               -command { if { $voconf(image_existe) == "1" } { ::skybot_Search::DateImage } }
             pack $utdp.radiobutton_minutes \
               -in $utdp -side left -anchor center \
               -padx 3 -pady 3

          #--- Cree un frame pour determiner l'origine de la date
          set oda [frame $img.par.date -borderwidth 0]
          pack $oda -in $img.par -anchor s -side top -expand 0 -fill x

             #--- Cree un label
             label $oda.label_origine_pose \
               -text "$caption(search,debut_image)" \
               -borderwidth 0 -relief flat
             pack $oda.label_origine_pose \
               -in $oda -side left \
               -padx 3 -pady 3

             #--- Bouton radio Debut de pose
             radiobutton $oda.radiobutton_debut_pose -highlightthickness 0 -state normal \
               -text "$caption(search,debut_pose)" -value 1 -variable voconf(origine_pose) \
               -command { if { $voconf(image_existe) == "1" } { ::skybot_Search::DateImage } }
             pack $oda.radiobutton_debut_pose \
               -in $oda -side left -anchor center \
               -padx 3 -pady 3

             #--- Bouton radio Milieu de pose
             radiobutton $oda.radiobutton_milieu_pose -highlightthickness 0 -state normal \
               -text "$caption(search,milieu_pose)" -value 2 -variable voconf(origine_pose) \
               -command { if { $voconf(image_existe) == "1" } { ::skybot_Search::DateImage } }
             pack $oda.radiobutton_milieu_pose \
               -in $oda -side left -anchor center \
               -padx 3 -pady 3

      #--- Cree un frame pour les caracteristiques du FOV
      frame $This.frame3 -borderwidth 0
      pack $This.frame3 \
         -in $This -anchor w -side top -expand 0 -fill x \
         -pady 6

        #--- Cree un label pour le titre des caracteristiques du FOV
        label $This.frame3.titre \
          -text "$caption(search,caract_fov)" \
          -borderwidth 0 -relief flat
        pack $This.frame3.titre \
          -in $This.frame3 -side top -anchor w \
          -padx 3 -pady 3

        #--- Cree un frame pour les caracteristiques du FOV
        set fov [frame $This.frame3.fov -borderwidth 1 -relief solid]
        pack $fov -in $This.frame3 -anchor w -side top -expand 0 -fill x -padx 10

          #--- Cree un frame pour la variable ascension droite
          frame $fov.a -borderwidth 0 -relief flat
          pack $fov.a \
            -in $fov -anchor w -side top -expand 0 -fill both \
            -padx 3 -pady 3
            #--- Cree un label pour l'ascension droite du FOV
            label $fov.a.label_ad_image \
              -text "$caption(search,ad_image)" \
              -width 20 -anchor w -borderwidth 0 -relief flat
            pack $fov.a.label_ad_image \
              -in $fov.a -side left -anchor w -padx 3
            #--- Cree une ligne d'entree pour la variable ascension droite
            entry $fov.a.data_ad_hms \
              -textvariable voconf(centre_ad_image_h) \
              -borderwidth 1 -relief groove -width 25 -justify center
            pack $fov.a.data_ad_hms \
              -in $fov.a -side left -anchor w -padx 3
            #--- Cree un bouton pour une info sur le format de l'ascension droite du FOV
            button $fov.a.format_ad_image -state active \
               -borderwidth 0 -relief flat -anchor c \
               -text "$caption(search,info)" \
               -command { ::skybot_Search::GetInfo "ad" }
            pack $fov.a.format_ad_image \
              -in $fov.a -side left -anchor w -padx 5

          #--- Cree un frame pour la variable declinaison
          frame $fov.b -borderwidth 0 -relief flat
          pack $fov.b \
            -in $fov -anchor w -side top -expand 0 -fill both \
            -padx 3 -pady 3
            #--- Cree un label pour la declinaison du centre de l'image
            label $fov.b.label_dec_image \
              -text "$caption(search,dec_image)" \
              -width 20 -anchor w -borderwidth 0 -relief flat
            pack $fov.b.label_dec_image \
              -in $fov.b -side left -anchor w -padx 3 
            #--- Cree une ligne d'entree pour la variable declinaison
            entry $fov.b.data_dec_dms \
              -textvariable voconf(centre_dec_image_d) \
              -borderwidth 1 -relief groove -width 25 -justify center
            pack $fov.b.data_dec_dms \
              -in $fov.b -side left -anchor w -padx 3
            #--- Cree un label pour le format de la declinaison du FOV
            button $fov.b.format_dec_image -state active \
	       -borderwidth 0 -relief flat -anchor c \
               -text "$caption(search,info)" \
               -command { ::skybot_Search::GetInfo "dec" }
            pack $fov.b.format_dec_image \
              -in $fov.b -side left -anchor w -padx 5

          #--- Cree un frame pour la variable taille du champ
          frame $fov.c -borderwidth 0 -relief flat
          pack $fov.c \
            -in $fov -anchor w -side top -expand 0 -fill both \
            -padx 3 -pady 3
            #--- Cree un label pour la taille du champ (FOV) de l'image
            label $fov.c.label_taille_champ \
              -text "$caption(search,taille_champ)" \
              -width 20 -anchor w -borderwidth 0 -relief flat
            pack $fov.c.label_taille_champ \
              -in $fov.c -side left -anchor w -padx 3 
            #--- Cree une ligne d'entree pour la variable taille du champ
            entry $fov.c.data_taille_champ \
              -textvariable voconf(taille_champ_min) \
              -borderwidth 1 -relief groove -width 25 -justify center
            pack $fov.c.data_taille_champ \
              -in $fov.c -side left -anchor w -padx 3
            #--- Cree un label pour le format du rayon du FOV
            button $fov.c.format_taille_champ -state active \
	       -borderwidth 0 -relief flat -anchor c \
               -text "$caption(search,info)" \
               -command { ::skybot_Search::GetInfo "taille" }
            pack $fov.c.format_taille_champ \
              -in $fov.c -side left -anchor w -padx 5

          #--- Cree un frame pour la variable date
          frame $fov.d -borderwidth 0 -relief flat
          pack $fov.d \
            -in $fov -anchor w -side top -expand 0 -fill both \
            -padx 3 -pady 3
            #--- Cree un label pour la date d'acquisition du FOV
            label $fov.d.label_date_image \
              -text "$caption(search,date_image)" \
              -width 20 -anchor w -borderwidth 0 -relief flat
            pack $fov.d.label_date_image \
              -in $fov.d -side left -anchor w -padx 3
            #--- Cree une ligne d'entree pour la variable date d'acquisition du FOV
            entry $fov.d.entry_date_image \
              -textvariable voconf(date_image) \
              -borderwidth 1 -relief groove -width 25 -justify center
            pack $fov.d.entry_date_image \
              -in $fov.d -side left -anchor w -padx 3
            #--- Cree un label pour le format de la date d'acquisition du FOV
            button $fov.d.label_format_date -state active \
	       -borderwidth 0 -relief flat -anchor c \
               -text "$caption(search,info)" \
               -command { ::skybot_Search::GetInfo "date" }
            pack $fov.d.label_format_date \
              -in $fov.d -side left -anchor w -padx 5

      #--- Cree un frame pour y mettre les boutons
      frame $This.frame6 -borderwidth 0
      pack $This.frame6 \
         -in $This -anchor s -side bottom -expand 0 -fill x

         #--- Creation du bouton de recherche des objets
         button $This.frame6.but_recherche -relief raised -state normal \
            -text "$caption(search,recherche)" -borderwidth 2 \
            -command { ::skybot_Search::cmdSearch }
         pack $This.frame6.but_recherche \
            -in $This.frame6 -side left -anchor w \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton de recherche des caracteristiques de l'objet
         button $This.frame6.but_caract -relief raised -state disabled \
            -text "$caption(search,caract_objet)" -borderwidth 2 \
            -command {
               set filename "http://vizier.u-strasbg.fr/cgi-bin/VizieR-5?-source=B/astorb/astorb&amp;Name===$voconf(name)"
               ::audace::Lance_Site_htm $filename
            }
         pack $This.frame6.but_caract \
            -in $This.frame6 -side left -anchor w \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton de recherche des ephemerides de l'objet
         button $This.frame6.but_ephemerides -relief raised -state disabled \
            -text "$caption(search,ephemerides_objet)" -borderwidth 2 \
            -command {
               set date [ mc_date2ymdhms now ]
               set annee [ lindex $date 0 ]
               set mois [ lindex $date 1 ]
               set jour [ lindex $date 2 ]
               set filename "http://www.imcce.fr/cgi-bin/ephepos-aladin.cgi/calcul?planete=Aster&nomaster=$voconf(name)\
                  &scale=UTC&an=$annee&mois=$mois&jour=$jour&heure=12&minutes=00&secondes=00&nbdates=15"
               ::audace::Lance_Site_htm $filename
            }
         pack $This.frame6.but_ephemerides \
            -in $This.frame6 -side left -anchor w \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton fermer
         button $This.frame6.but_fermer \
            -text "$caption(search,fermer)" -borderwidth 2 \
            -command { ::skybot_Search::fermer }
         pack $This.frame6.but_fermer \
            -in $This.frame6 -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton aide
         button $This.frame6.but_aide \
            -text "$caption(search,aide)" -borderwidth 2 \
            -command { ::audace::showHelpPlugin tool vo_tools vo_tools.htm }
         pack $This.frame6.but_aide \
            -in $This.frame6 -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      #--- Cree un frame pour l'affichage du resultat de la recherche
      frame $This.frame7 -borderwidth 0
      pack $This.frame7 -expand yes -fill both -padx 3 -pady 6

         #--- Cree un acsenseur vertical
         scrollbar $This.frame7.vsb -orient vertical \
            -command { $::skybot_Search::This.frame7.lst1 yview } -takefocus 1 -borderwidth 1
         pack $This.frame7.vsb \
            -in $This.frame7 -side right -fill y

         #--- Cree un acsenseur horizontal
         scrollbar $This.frame7.hsb -orient horizontal \
            -command { $::skybot_Search::This.frame7.lst1 xview } -takefocus 1 -borderwidth 1
         pack $This.frame7.hsb \
            -in $This.frame7 -side bottom -fill x

         #--- Creation de la table
         ::skybot_Search::createTbl $This.frame7
         pack $This.frame7.tbl \
            -in $This.frame7 -expand yes -fill both

      #--- La fenetre est active
      focus $This

      #--- La touche Entree est equivalente au bouton "Lancement de la recherche"
      bind $This <Key-Return>  { ::skybot_Search::cmdSearch }

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #--- Choix par defaut du curseur
      $This configure -cursor arrow
   }

   #
   #  skybot_Search::createTbl
   #  Affiche la table avec ses scrollbars dans une frame et cree le menu pop-up associe
   #
   proc createTbl { frame } {
      variable This
      global audace
      global caption
      global voconf
      global popupTbl
      global paramwindow

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl      
      set popupTbl $frame.popupTbl
      set filtres $frame.popupTbl.filtres
      set paramwindow $This.param

      #--- Table des objets
      set titre_colonnes { Num Name RA(h) DE(deg) Class Mv Err(arcsec) d(arcsec) dRA(arcsec/h) dDEC(arcsec/h) \
         Dg(ua) Dh(ua) }
      tablelist::tablelist $tbl \
         -labelcommand ::skybot_Search::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table 
      menu $popupTbl -title $caption(search,popup_tbl)
        # Pour marquer les reperes sur les objets
        $popupTbl add radiobutton -label $caption(search,reperer) \
           -value "1" -state disabled \
           -variable voconf(trace_efface) \
           -command { ::skybot_Search::cmdRepere_Efface }
        # Pour effacer les reperes sur les objets
        $popupTbl add radiobutton -label $caption(search,effacer) \
           -value "0" -state disabled \
           -variable voconf(trace_efface) \
           -command { ::skybot_Search::cmdRepere_Efface }
        # Separateur
        $popupTbl add separator
        # Labels des objets dans l'image
        $popupTbl add checkbutton -label $caption(search,label_objets) -state disabled \
           -variable voconf(label_objets) \
           -command { ::skybot_Search::cmdRepere_Efface} 
        # Separateur
        $popupTbl add separator

        # Menu filtres
        $popupTbl add cascade -menu $filtres \
           -label $caption(search,filtres) -state disabled
          menu $filtres
          # aucun filtre
          $filtres add radiobutton -label $caption(search,filtre_none) \
             -value "none" \
             -variable voconf(type_filtre) \
             -command { if {[ winfo exists $paramwindow ]} { ::skybot_Search::ParamFiltres }
                        ::skybot_Search::cmdRepere_Efface }
          # magnitude
          $filtres add radiobutton -label $caption(search,filtre_mag) \
             -value "mag" \
             -variable voconf(type_filtre) \
             -command { if {[ winfo exists $paramwindow ]} { ::skybot_Search::ParamFiltres }
                        ::skybot_Search::cmdRepere_Efface }
          # erreur de position
          $filtres add radiobutton -label $caption(search,filtre_err) \
             -value "err" \
             -variable voconf(type_filtre) \
             -command { if {[ winfo exists $paramwindow ]} { ::skybot_Search::ParamFiltres }
                        ::skybot_Search::cmdRepere_Efface }
          # distance geocentrique
          $filtres add radiobutton -label $caption(search,filtre_dig) \
             -value "dig" \
             -variable voconf(type_filtre) \
             -command { if {[ winfo exists $paramwindow ]} { ::skybot_Search::ParamFiltres }
                        ::skybot_Search::cmdRepere_Efface }
          # distance heliocentrique
          $filtres add radiobutton -label $caption(search,filtre_dih) \
             -value "dih" \
             -variable voconf(type_filtre) \
             -command { if {[ winfo exists $paramwindow ]} { ::skybot_Search::ParamFiltres }
                        ::skybot_Search::cmdRepere_Efface }
          # mouvement propre
          $filtres add radiobutton -label $caption(search,filtre_ppm) \
             -value "ppm" \
             -variable voconf(type_filtre) \
             -command { if {[ winfo exists $paramwindow ]} { ::skybot_Search::ParamFiltres }
                        ::skybot_Search::cmdRepere_Efface }
        # Parametres pour les filtres
        $popupTbl add command -label $caption(search,filtre_param) -state disabled \
           -command { ::skybot_Search::ParamFiltres }
        # Separateur
        $popupTbl add separator
        # Acces au mode Goto
        $popupTbl add command -label $caption(search,goto) -state disabled
        # Separateur
        $popupTbl add separator
        # Acces a l'aide
        $popupTbl add command -label $caption(search,aide) \
           -command { ::audace::showHelpPlugin "tool" "vo_tools" "vo_tools.htm" }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ] 
      bind $tbl <<ListboxSelect>>          [ list ::skybot_Search::cmdButton1Click $This.frame7 ]

   }

   #
   # skybot_Search::ParamFiltres
   # Defini les parametres des filtres
   #
   proc ParamFiltres { } {
      variable This
      global caption
      global param
      global voconf
      global paramwindow

      #--- identite de la fenetre
      set paramwindow $This.param

      #--- filtre courant
      set filter $voconf(type_filtre)

      #--- Init. pour les spinbox
      switch $filter {
        mag { set valfrom "-30" 
              set valto   "40" }
        err { set valfrom "0" 
              set valto   "100000" }
        dig -
        dih { set valfrom "0" 
              set valto   "150" }
        ppm { set valfrom "0" 
              set valto   "10000" }
      }

      #--- si la fenetre existe deja... on la detruit pour la reconstruire
      if { [ winfo exists $paramwindow ] } { destroy $paramwindow }

      #--- creation de la fenetre
      toplevel $paramwindow
      wm geometry $paramwindow 480x170
      wm resizable $paramwindow 1 1
      wm title $paramwindow $caption(search,param_title)

      #--- Cree un frame pour la saisie des parametres
      frame $paramwindow.zparam -borderwidth 0 -relief flat
      pack $paramwindow.zparam \
         -in $paramwindow -anchor c -side top -expand 0 -fill x

        #--- Cree un label pour le titre
        label $paramwindow.zparam.titre \
          -text "$caption(search,param_title)" \
          -borderwidth 0 -relief flat
        pack $paramwindow.zparam.titre \
          -in $paramwindow.zparam -side top -anchor w \
          -padx 3 -pady 3

        #--- Cree un frame pour saisir les parametres
        set inputs [frame $paramwindow.zparam.in -borderwidth 1 -relief solid]
        pack $inputs -in $paramwindow.zparam -anchor w -side top -expand 0 -fill x -padx 10

        if { $filter != "none" } {
	  
          #--- Cree un frame pour les spinbox des min-max du parametre courant
          frame $inputs.s -borderwidth 0 -relief flat
          pack $inputs.s \
            -in $inputs -anchor w -side top -expand 0 -fill both \
            -padx 3 -pady 3

            #--- Cree un label 
            label $inputs.s.label_spin \
               -text "$caption(search,[concat "param_spin$filter"])" \
               -width 43 -anchor w -borderwidth 0 -relief flat
            pack $inputs.s.label_spin \
               -in $inputs.s -side left -anchor w -padx 3
            #--- Cree un spinbox pour la magnitude min
            spinbox $inputs.s.spinbox1 -width 4 \
               -textvariable voconf([concat "min_$filter"]) \
               -increment 1.0 -from $valfrom -to $valto
            pack $inputs.s.spinbox1 \
               -in $inputs.s -side left -anchor w -padx 3
            #--- Cree un spinbox pour la magnitude max
            spinbox $inputs.s.spinbox2 -width 4 \
               -textvariable voconf([concat "max_$filter"]) \
               -increment 1.0 -from $valfrom -to $valto
            pack $inputs.s.spinbox2 \
               -in $inputs.s -side left -anchor w -padx 3
            #--- Cree un bouton info 
            button $inputs.s.format_spin -state active \
               -borderwidth 0 -relief flat -anchor c \
               -text "$caption(search,info)" \
               -command { ::skybot_Search::GetInfo "spin" }
            pack $inputs.s.format_spin \
               -in $inputs.s -side left -anchor w -padx 5

          if { $filter != "ppm" } {

            #--- Cree un frame pour le rayon de base des cercles
            frame $inputs.a -borderwidth 0 -relief flat
            pack $inputs.a \
              -in $inputs -anchor w -side top -expand 0 -fill both \
              -padx 3 -pady 3
              #--- Cree un label 
              label $inputs.a.label_radius_base \
                -text "$caption(search,param_basecircle)" \
                -width 43 -anchor w -borderwidth 0 -relief flat
              pack $inputs.a.label_radius_base \
                -in $inputs.a -side left -anchor w -padx 3
              #--- Cree une ligne d'entree
              entry $inputs.a.radius_base \
                -textvariable voconf(radius_base) \
                -borderwidth 1 -relief groove -width 12 -justify center
              pack $inputs.a.radius_base \
                -in $inputs.a -side left -anchor w -padx 3
              #--- Cree un bouton info 
              button $inputs.a.format_radius_base -state active \
                 -borderwidth 0 -relief flat -anchor c \
                 -text "$caption(search,info)" \
                 -command { ::skybot_Search::GetInfo "basecircle" }
              pack $inputs.a.format_radius_base \
                -in $inputs.a -side left -anchor w -padx 5

            #--- Cree un frame pour le facteur d'echelle du rayon des cercles
            frame $inputs.b -borderwidth 0 -relief flat
            pack $inputs.b \
              -in $inputs -anchor w -side top -expand 0 -fill both \
              -padx 3 -pady 3
              #--- Cree un label 
              label $inputs.b.label_radius_scale \
                -text "$caption(search,param_scalecircle)" \
                -width 43 -anchor w -borderwidth 0 -relief flat
              pack $inputs.b.label_radius_scale \
                -in $inputs.b -side left -anchor w -padx 3
              #--- Cree une ligne d'entree
              entry $inputs.b.radius_scale \
                -textvariable voconf(radius_scale) \
                -borderwidth 1 -relief groove -width 12 -justify center
              pack $inputs.b.radius_scale \
                -in $inputs.b -side left -anchor w -padx 3
              #--- Cree un bouton info 
              button $inputs.b.format_radius_scale -state active \
                 -borderwidth 0 -relief flat -anchor c \
                 -text "$caption(search,info)" \
                 -command { ::skybot_Search::GetInfo "scalecircle" }
              pack $inputs.b.format_radius_scale \
                -in $inputs.b -side left -anchor w -padx 5

          } else {

            #--- Cree un frame pour la longueur des fleches de mvt propre
            frame $inputs.c -borderwidth 0 -relief flat
            pack $inputs.c \
              -in $inputs -anchor w -side top -expand 0 -fill both \
              -padx 3 -pady 3
              #--- Cree un label 
              label $inputs.c.label_arrow_base \
                -text "$caption(search,param_basearrow)" \
                -width 43 -anchor w -borderwidth 0 -relief flat
              pack $inputs.c.label_arrow_base \
                -in $inputs.c -side left -anchor w -padx 3
              #--- Cree une ligne d'entree
              entry $inputs.c.arrow_base \
                -textvariable voconf(arrow_base) \
                -borderwidth 1 -relief groove -width 12 -justify center
              pack $inputs.c.arrow_base \
                -in $inputs.c -side left -anchor w -padx 3
              #--- Cree un bouton info 
              button $inputs.c.format_arrow_base -state active \
                -borderwidth 0 -relief flat -anchor c \
                -text "$caption(search,info)" \
                -command { ::skybot_Search::GetInfo "basearrow" }
              pack $inputs.c.format_arrow_base \
                -in $inputs.c -side left -anchor w -padx 5

          }

        } else {

          #--- Cree un frame pour le rayon fixe des cercles
          frame $inputs.d -borderwidth 0 -relief flat
          pack $inputs.d \
            -in $inputs -anchor w -side top -expand 0 -fill both \
            -padx 3 -pady 3
            #--- Cree un label 
            label $inputs.d.label_radius_fixe \
              -text "$caption(search,param_fixecircle)" \
              -width 43 -anchor w -borderwidth 0 -relief flat
            pack $inputs.d.label_radius_fixe \
              -in $inputs.d -side left -anchor w -padx 3
            #--- Cree une ligne d'entree
            entry $inputs.d.radius_fixe \
              -textvariable voconf(radius_fixe) \
              -borderwidth 1 -relief groove -width 12 -justify center
            pack $inputs.d.radius_fixe \
              -in $inputs.d -side left -anchor w -padx 3
            #--- Cree un bouton info 
            button $inputs.d.format_radius_fixe -state active \
               -borderwidth 0 -relief flat -anchor c \
               -text "$caption(search,info)" \
               -command { ::skybot_Search::GetInfo "fixecircle" }
            pack $inputs.d.format_radius_fixe \
              -in $inputs.d -side left -anchor w -padx 5

	}

      #--- Cree un frame pour y mettre les boutons
      frame $paramwindow.boutons -borderwidth 0
      pack $paramwindow.boutons \
         -in $paramwindow -anchor s -side bottom -expand 0 -fill x

         #--- Creation du bouton appliquer
         button $paramwindow.boutons.but_apply \
            -text "$caption(search,appliquer)" -borderwidth 2 \
            -command { ::skybot_Search::cmdRepere_Efface }
         pack $paramwindow.boutons.but_apply \
            -in $paramwindow.boutons -side left -anchor w \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton defaut
         button $paramwindow.boutons.but_default \
            -text "$caption(search,default)" -borderwidth 2 \
            -command { set voconf(radius_fixe)  "10.0"
	               set voconf(radius_base)  "2.0"
                       set voconf(radius_scale) "18.0"
                       set voconf(arrow_base)   "5.0"
                       ::skybot_Search::cmdRepere_Efface }
         pack $paramwindow.boutons.but_default \
            -in $paramwindow.boutons -side left -anchor w \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton fermer
         button $paramwindow.boutons.but_fermer \
            -text "$caption(search,fermer)" -borderwidth 2 \
            -command { destroy $paramwindow }
         pack $paramwindow.boutons.but_fermer \
            -in $paramwindow.boutons -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton aide
         button $paramwindow.boutons.but_aide \
            -text "$caption(search,aide)" -borderwidth 2 \
            -command { ::audace::showHelpPlugin tool vo_tools vo_tools.htm }
         pack $paramwindow.boutons.but_aide \
            -in $paramwindow.boutons -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $paramwindow
   }

   #
   # skybot_Search::cmdSortColumn
   # Trie les lignes par ordre alphabetique de la colonne (est appele quand on clique sur le titre de la colonne)
   #
   proc cmdSortColumn { tbl col } {
      tablelist::sortByColumn $tbl $col
   }

   #
   # skybot_Search::cmdButton1Click
   # Charge l'item selectionne avec la souris dans la liste
   #
   proc cmdButton1Click { frame } {
      variable This
      global audace
      global caption
      global color
      global conf
      global panneau
      global voconf
      global current_object

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl      
      set popupTbl $frame.popupTbl

      #--- Selection d'une ligne
      set selection [ $tbl curselection ]

      #--- Retourne immediatemment si aucun item selectionne
      if { "$selection" == "" } {
         return
      }

      #--- Nom de l'objet selectionne
      set num_line [ lindex $selection 0 ]
      set erreur [ catch { lindex [ $tbl cellconfigure $num_line,1 -text ] 4 } voconf(name) ]
      if { $erreur == "1" } {
         set voconf(name) ""
         #--- Gestion des boutons
         $::skybot_Search::This.frame6.but_caract configure -relief raised -state disabled
         $::skybot_Search::This.frame6.but_ephemerides configure -relief raised -state disabled
         #--- Desactive l'acces au mode Goto
         $popupTbl entryconfigure $caption(search,goto) -state disabled
      } else {
         #--- Gestion des boutons
         $::skybot_Search::This.frame6.but_caract configure -relief raised -state normal
         $::skybot_Search::This.frame6.but_ephemerides configure -relief raised -state normal
         #--- Coordonnees equatoriales de l'objet
         set voconf(AD_objet) [ mc_angle2deg [ lindex [ $tbl cellconfigure $num_line,2 -text ] 4 ] ]
         set voconf(Dec_objet) [ mc_angle2deg [ lindex [ $tbl cellconfigure $num_line,3 -text ] 4 ] ]
         #--- Si une image est chargee alors on marque l'objet sur l'image
         if {$voconf(image_existe) == "1"} {
            #--- Coordonnees images de l'objet
            set img_xy [ buf$audace(bufNo) radec2xy [ list $voconf(AD_objet) $voconf(Dec_objet) ] ]
            #--- Transformation des coordonnees image en coordonnees canvas
            set can_xy [ ::audace::picture2Canvas $img_xy ]
            #--- Re-dessine en orange l'objet precedemment selectionne
        	    if { $current_object(num) >= 0 } {
               ::skybot_Search::Trace_Objet $tbl $current_object(num) $current_object(img) $current_object(can) "orange"
            }
            #--- Dessine l'objet selectionne en vert dans l'image
            ::skybot_Search::Trace_Objet $tbl $num_line $img_xy $can_xy "green"
            #--- et sauvegarde les coordonnees de l'objet courant tagge en vert
            set current_object(num) $num_line
            set current_object(img) $img_xy
            set current_object(can) $can_xy
            #--- Recupere les dimensions courantes du canvas .audace
            scan [wm geometry $audace(base)] "%ix%i" dim_canvas_x dim_canvas_y
            #--- Recupere les dimensions de l'image affichee
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
            set naxis2 [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]
            #--- Calcul les facteurs de deplacement pour positionner l'objet selectionne au centre du canvas
            set fracx [ expr ([lindex $img_xy 0] - $dim_canvas_x/2.0) / $naxis1 ]
            set fracy [ expr 1.0 - ([lindex $img_xy 1] + $dim_canvas_y/2.0) / $naxis2 ]
            #--- Positionne l'image pour visualiser l'objet selectionne au centre du canvas
            $audace(hCanvas) xview moveto $fracx
            $audace(hCanvas) yview moveto $fracy
            #--- Active l'acces au mode Goto
            $popupTbl entryconfigure $caption(search,goto) -state normal \
               -command { if { [ ::tel::list ] == "" } {
                             ::confTel::run 
                             tkwait window $audace(base).confTel
                          }
                          ::skybot_Resolver::affiche_Outil_Tlscp
                          set catalogue(asteroide_choisi) $voconf(name)
                          ::Tlscp::Gestion_Cata $caption(resolver,asteroide)
                        }
         }
      }
   }

   #
   # skybot_Search::cmdFormatColumn
   # Definit la largeur, la traduction du titre et la justification des colonnes
   #
   proc cmdFormatColumn { column_name } {
      variable column_format

      #--- Suppression des caracteres "(" et ")"
      regsub -all {[\(]} $column_name "" column_name
      regsub -all {[\)]} $column_name "" column_name
      #---
      set a [ array get column_format $column_name ]
      if { [ llength $a ] == "0" } {
         set format [ list 10 $column_name left ]
      } else {
         set format [ lindex $a 1 ]
      }
      return $format
   }

   #
   # skybot_Search::cmdSearch
   # Recherche les objets du champ
   #
   proc cmdSearch { } {
      variable This
      global fov popupTbl
      global audace
      global caption
      global color
      global voconf
      global valMinFiltre valMaxFiltre

      #--- Gestion des boutons
      $::skybot_Search::This configure -cursor watch
      $::skybot_Search::This.frame6.but_recherche configure -relief groove -state disabled
      $::skybot_Search::This.frame6.but_caract configure -relief raised -state disabled
      $::skybot_Search::This.frame6.but_ephemerides configure -relief raised -state disabled

      #--- Test sur la presence d'une image: si pas d'image alors on calcul les coord.
      #    du centre du champ a partir des saisies faites
      if {$voconf(image_existe) == "0"} {
         if {$voconf(centre_ad_image_h) == ""} {
            tk_messageBox -title $caption(search,msg_erreur) -type ok -message $caption(search,msg_saisir_ad)
            focus $fov.a.data_ad_hms
            $::skybot_Search::This configure -cursor arrow
            $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
            return
         } else {
            set voconf(centre_ad_image) [string trim [ mc_angle2deg $voconf(centre_ad_image_h) ]]
         }
          if {$voconf(centre_dec_image_d) == ""} {
            tk_messageBox -title $caption(search,msg_erreur) -type ok -message $caption(search,msg_saisir_dec)
            focus $fov.b.data_dec_dms
            $::skybot_Search::This configure -cursor arrow
            $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
            return
         } else {
            set voconf(centre_dec_image) [string trim [ mc_angle2deg $voconf(centre_dec_image_d) ]]
         }
      }

      #--- Tests sur l'ascension droite
      if { ( [ string is double -strict $voconf(centre_ad_image) ] == "0" ) \
            || ( $voconf(centre_ad_image) == "" ) || ( $voconf(centre_ad_image) < "0.0" ) \
            || ( $voconf(centre_ad_image) > "360.0" ) } {
         tk_messageBox -title $caption(search,msg_probleme) -type ok -message $caption(search,msg_reel_ad)
         focus $fov.a.data_ad_hms
         $::skybot_Search::This configure -cursor arrow
         $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
         return
      }

      #--- Tests sur la declinaison
      if { ( [ string is double -strict $voconf(centre_dec_image) ] == "0" ) \
            || ( $voconf(centre_dec_image) == "" ) || ( $voconf(centre_dec_image) < "-90.0" ) \
            || ( $voconf(centre_dec_image) > "90.0" ) } {
         tk_messageBox -title $caption(search,msg_probleme) -type ok -message $caption(search,msg_reel_dec)
         focus $fov.b.data_dec_dms
         $::skybot_Search::This configure -cursor arrow
         $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
         return
      }

      #--- Tests sur la dimension du champ
      if { ( [ string is double -strict $voconf(taille_champ_min) ] == "0" ) \
            || ( $voconf(taille_champ_min) == "" ) || ( $voconf(taille_champ_min) <= "0" ) \
            || ( $voconf(taille_champ_min) > "1200.0" ) } {
         tk_messageBox -title $caption(search,msg_probleme) -type ok -message $caption(search,msg_reel_champ)
         focus $fov.c.data_taille_champ
         $::skybot_Search::This configure -cursor arrow
         $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
         return
      }

      #--- Tests sur la date
      if { $voconf(date_image) == "" } {
         tk_messageBox -title $caption(search,msg_probleme) -type ok -message $caption(search,msg_reel_date)
         set voconf(date_image) ""
         focus $fov.d.entry_date_image
         $::skybot_Search::This configure -cursor arrow
         $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
         return
      }
      #---
      set date [ mc_date2jd $voconf(date_image) ]
      #--- Interrogation de la base de donnees
      set erreur [ catch { vo_skybotstatus } statut ]
      #---
      if { $erreur == "0" } {
         #--- Mise en forme du resultat
         set statut [ lindex $statut 1 ]
         regsub -all "\'" $statut "\"" statut
         #--- Date du debut
         set date_debut [ lindex $statut 1 ]
         set date_d [ mc_date2ymdhms $date_debut ]
         set date_debut_ [ format "%02d/%02d/%2s $caption(statut,titre6) %02d:%02d:%02.0f" [ lindex $date_d 2 ] \
            [ lindex $date_d 1 ] [ lindex $date_d 0 ] [ lindex $date_d 3 ] [ lindex $date_d  4 ] [ lindex $date_d  5 ] ]
         #--- Date de fin
         set date_fin [ lindex $statut 2 ]
         set date_f [ mc_date2ymdhms $date_fin ]
         set date_fin_ [ format "%02d/%02d/%2s $caption(statut,titre6) %02d:%02d:%02.0f" [ lindex $date_f 2 ] \
            [ lindex $date_f 1 ] [ lindex $date_f 0 ] [ lindex $date_f 3 ] [ lindex $date_f  4 ] [ lindex $date_f  5 ] ]
         #---
         if { $date <= $date_debut } {
            tk_messageBox -title $caption(search,msg_probleme) -type ok \
               -message "$caption(search,msg_reel_date>) $date_debut_"
            set voconf(date_image) ""
            focus $fov.d.entry_date_image
            $::skybot_Search::This configure -cursor arrow
            $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
            return
         }
         #---
         if { $date >= $date_fin } {
            tk_messageBox -title $caption(search,msg_probleme) -type ok \
               -message "$caption(search,msg_reel_date<) $date_fin_"
            set voconf(date_image) ""
            focus $fov.d.entry_date_image
            $::skybot_Search::This configure -cursor arrow
            $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal
            return
         }
      }

      #--- RAZ de la liste
      $::skybot_Search::This.frame7.tbl delete 0 end
      if { [ $::skybot_Search::This.frame7.tbl columncount ] != "0" } {
         $::skybot_Search::This.frame7.tbl deletecolumns 0 end
      }

      #--- Extraction, suppression des virgules et creation des colonnes du tableau
      set voconf(taille_champ) [ expr $voconf(taille_champ_min) * 60.0 / 2.0 ]
      set erreur \
         [ catch { vo_skybot $voconf(date_image) $voconf(centre_ad_image) $voconf(centre_dec_image) \
         $voconf(taille_champ) } voconf(liste) ]
      if { $erreur == "0" } {
         set liste_titres [ lindex $voconf(liste) 0 ]
         regsub -all "," $liste_titres "" liste_titres
         for { set i 1 } { $i <= [ expr [ llength $liste_titres ] - 1 ] } { incr i } {
            set format [ ::skybot_Search::cmdFormatColumn [ lindex $liste_titres $i ] ]
            $::skybot_Search::This.frame7.tbl insertcolumns end [ lindex $format 0 ] [ lindex $format 1 ] \
               [ lindex $format 2 ]
         }
         #--- Traitement d'une erreur particuliere, la requete repond 'item'
         if { $liste_titres == "item" } {
            $::skybot_Search::This.frame7.tbl insertcolumns end 100 "$caption(search,msg_erreur)" left
            $::skybot_Search::This.frame7.tbl insert end [ list $caption(search,msg_item) ]
            $::skybot_Search::This.frame7.tbl cellconfigure 0,0 -fg $color(red)
         } else {
            #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
            if { [ $::skybot_Search::This.frame7.tbl columncount ] != "0" } {
               $::skybot_Search::This.frame7.tbl columnconfigure 1 -sortmode dictionary
            }
            #--- Initialisations pour les filtres
            set valMinFiltre(mag) "99"
            set valMaxFiltre(mag) "-99"
            set valMinFiltre(err) "999999"
            set valMaxFiltre(err) "-999999"
            set valMinFiltre(dig) "999"
            set valMaxFiltre(dig) "0"
            set valMinFiltre(dih) "999"
            set valMaxFiltre(dih) "0"
            #--- Extraction du resultat
            set voconf(j) "0"
            for { set i 1 } { $i <= [ expr [ llength $voconf(liste) ] - 1 ] } { incr i } {
               regsub -all "\'" [ lindex $voconf(liste) $i ] "\"" vo_objet($i)
               #--- Mise en forme de l'ascension droite
               set ad [ expr 15.0 * [ lindex $vo_objet($i) 2 ] ]
               #--- Mise en forme de la declinaison
               set dec [ lindex $vo_objet($i) 3 ]
               #--- Recherche des valeurs min-max pour initialiser les filtres
                 # limites des magnitudes
               if { [ lindex $vo_objet($i) 5 ] < $valMinFiltre(mag) } { set valMinFiltre(mag) [ lindex $vo_objet($i) 5 ] }
               if { [ lindex $vo_objet($i) 5 ] > $valMaxFiltre(mag) } { set valMaxFiltre(mag) [ lindex $vo_objet($i) 5 ] }
                 # limites des erreurs de pos.
               if { [ lindex $vo_objet($i) 6 ] < $valMinFiltre(err) } { set valMinFiltre(err) [ lindex $vo_objet($i) 6 ] }
               if { [ lindex $vo_objet($i) 6 ] > $valMaxFiltre(err) } { set valMaxFiltre(err) [ lindex $vo_objet($i) 6 ] }
                 # limites des distances geoc.
               if { [ lindex $vo_objet($i) 10 ] < $valMinFiltre(dig) } { set valMinFiltre(dig) [ lindex $vo_objet($i) 10 ] }
               if { [ lindex $vo_objet($i) 10 ] > $valMaxFiltre(dig) } { set valMaxFiltre(dig) [ lindex $vo_objet($i) 10 ] }
                 # limites des distances helioc.
               if { [ lindex $vo_objet($i) 11 ] < $valMinFiltre(dih) } { set valMinFiltre(dih) [ lindex $vo_objet($i) 11 ] }
               if { [ lindex $vo_objet($i) 11 ] > $valMaxFiltre(dih) } { set valMaxFiltre(dih) [ lindex $vo_objet($i) 11 ] }
               #--- Si une image est chargee alors on recherche les objets qui sont sur l'image
               if {$voconf(image_existe) == "1"} {
                 if { $voconf(AD_1_1) > $voconf(AD_n_n) } {
                     if { ( $ad > $voconf(AD_n_n) ) && ( $ad < $voconf(AD_1_1) ) } {
                	#--- Je garde
                	set garde(ad) "1"
                     } else {
                	#--- Je ne garde pas
                	set garde(ad) "0"
                     }
                 } else {
                     if { ( $ad > $voconf(AD_1_1) ) && ( $ad < $voconf(AD_n_n) ) } {
                	#--- Je garde
                	set garde(ad) "1"
                     } else {
                	#--- Je ne garde pas
                	set garde(ad) "0"
                     }
                 }
                 if { $voconf(Dec_n_n) > $voconf(Dec_1_1) } {
                     if { ( $dec > $voconf(Dec_1_1) ) && ( $dec < $voconf(Dec_n_n) ) } {
                	#--- Je garde
                	set garde(dec) "1"
                     } else {
                	#--- Je ne garde pas
                	set garde(dec) "0"
                     }
                 } else {
                     if { ( $dec > $voconf(Dec_n_n) ) && ( $dec < $voconf(Dec_1_1) ) } {
                	#--- Je garde
                	set garde(dec) "1"
                     } else {
                	#--- Je ne garde pas
                	set garde(dec) "0"
                     }
                }
        	  #--- Liste les objets qui sont sur l'image
        	  if { ( $garde(ad) == "1" ) && ( $garde(dec) == "1" ) } {
                     incr voconf(j)
                     $::skybot_Search::This.frame7.tbl insert end $vo_objet($i)
        	  }
               } else {
               #--- sinon on garde tous les objets 
                 incr voconf(j)
                 $::skybot_Search::This.frame7.tbl insert end $vo_objet($i)
               }
            }
            #---
            if { [ $::skybot_Search::This.frame7.tbl columncount ] != "0" } {
               #--- Trie par ordre alphabetique de la premiere colonne 
               ::skybot_Search::cmdSortColumn $::skybot_Search::This.frame7.tbl 0
               #--- Les noms des objets sont en bleu
               for { set i 0 } { $i <= [ expr $voconf(j) - 1 ] } { incr i } {
                  $::skybot_Search::This.frame7.tbl cellconfigure $i,1 -fg $color(blue)
                  #--- Mise en forme de l'ascension droite
                  set ad [ $::skybot_Search::This.frame7.tbl cellcget $i,2 -text ]
                  set ad [ expr $ad * 15.0 ]
                  $::skybot_Search::This.frame7.tbl cellconfigure $i,2 -text [ mc_angle2hms $ad 360 zero 2 auto string ]
                  #--- Mise en forme de la declinaison
                  set dec [ $::skybot_Search::This.frame7.tbl cellcget $i,3 -text ]
                  $::skybot_Search::This.frame7.tbl cellconfigure $i,3 -text [ mc_angle2dms $dec 90 zero 2 + string ]
               }
               #--- Si une image est chargee alors on valide les entrees du popup 'bouton-3' de la table
               if {$voconf(image_existe) == "1"} {
                  $popupTbl entryconfigure $caption(search,reperer) -state normal
                  $popupTbl entryconfigure $caption(search,effacer) -state normal
                  $popupTbl entryconfigure $caption(search,filtres) -state normal
                  $popupTbl entryconfigure $caption(search,filtre_param) -state normal
                  $popupTbl entryconfigure $caption(search,label_objets) -state normal
               } else {
               #--- sinon on les rend inutilisables
                  $popupTbl entryconfigure $caption(search,reperer) -state disabled
                  $popupTbl entryconfigure $caption(search,effacer) -state disabled
                  $popupTbl entryconfigure $caption(search,filtres) -state disabled
                  $popupTbl entryconfigure $caption(search,filtre_param) -state disabled
                  $popupTbl entryconfigure $caption(search,label_objets) -state disabled
               }
               #--- Si une image est chargee alors on repere les objets sur l'image
               if {$voconf(image_existe) == "1"} { ::skybot_Search::cmdRepere_Efface }
               #--- Bilan des objets trouves dans le FOV
               if { $i > "1" } {
                  ::console::disp "$caption(search,msg_nbre_objets) $i \n\n"
               } else {
                  ::console::disp "$caption(search,msg_nbre_objet) $i \n\n"
               }
            }
         }
      } else {
         $::skybot_Search::This.frame7.tbl insertcolumns end 100 "$caption(search,msg_erreur)" left
         if { [ lindex [ lindex $voconf(liste) 0 ] 0 ] == "SKYBOT" } {
            set msg_erreur [ lindex $voconf(liste) 1 ]
            $::skybot_Search::This.frame7.tbl insert end [ list $msg_erreur ]
            $::skybot_Search::This.frame7.tbl cellconfigure 0,0 -fg $color(red)
         } else {
            $::skybot_Search::This.frame7.tbl insert end [ list $caption(search,msg_internet) ]
            $::skybot_Search::This.frame7.tbl cellconfigure 0,0 -fg $color(red)
         }
      }

      #--- Gestion du curseur
      $::skybot_Search::This configure -cursor arrow
      #--- Gestion des boutons
      $::skybot_Search::This.frame6.but_recherche configure -relief raised -state normal

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # skybot_Search::Trace_Objet
   # Materialise les objets du champ selon le filtre choisi
   #
   proc Trace_Objet { tbl idx img_xy can_xy mycolor } {
      global audace
      global color
      global voconf
      global valMinFiltre valMaxFiltre

      #--- Initialisations
      set radius_fixe $voconf(radius_fixe)
      set radius_base $voconf(radius_base)
      set radius_scale $voconf(radius_scale)
      set arrow_base $voconf(arrow_base)
      
      #--- Fonctions filtres
      set traceobjet 0
      switch $voconf(type_filtre) {
        mag     { set FormTrace "circle"
                  set objmag [ lindex [ $tbl cellconfigure $idx,5 -text ] 4 ]
                  if { $objmag >= $voconf(min_mag) && $objmag  <= $voconf(max_mag) } {
                     set traceobjet 1
                     set radius [ expr $radius_base + $radius_scale*(1.0 - ($objmag-$valMinFiltre(mag))/($valMaxFiltre(mag)-$valMinFiltre(mag))) ]
                  }
                 }
        err     { set FormTrace "circle"
                  set objerr [ lindex [ $tbl cellconfigure $idx,6 -text ] 4 ]
                  if { $objerr >= $voconf(min_err) && $objerr  <= $voconf(max_err) } {
                     set traceobjet 1
                     set radius [ expr $radius_base + $radius_scale*($objerr-$valMinFiltre(err))/($valMaxFiltre(err)-$valMinFiltre(err)) ] 
                  }
                 }
        dig     { set FormTrace "circle"
                  set objdig [ lindex [ $tbl cellconfigure $idx,10 -text ] 4 ]
                  if { $objdig >= $voconf(min_dig) && $objdig  <= $voconf(max_dig) } {
                     set traceobjet 1
                     set radius [ expr $radius_base + $radius_scale*($objdig-$valMinFiltre(dig))/($valMaxFiltre(dig)-$valMinFiltre(dig)) ] 
                  }
                 }
        dih     { set FormTrace "circle"
                  set objdih [ lindex [ $tbl cellconfigure $idx,11 -text ] 4 ]
                  if { $objdih >= $voconf(min_dih) && $objdih  <= $voconf(max_dih) } {
                     set traceobjet 1
                     set radius [ expr $radius_base + $radius_scale*($objdih-$valMinFiltre(dih))/($valMaxFiltre(dih)-$valMinFiltre(dih)) ] 
                  }
                 }
        ppm     { set FormTrace "arrow"
                  set objdra [ lindex [ $tbl cellconfigure $idx,8 -text ] 4 ]
                  set objdde [ lindex [ $tbl cellconfigure $idx,9 -text ] 4 ]
                  set objvit [ expr sqrt($objdra*$objdra + $objdde*$objdde) ]
                  if { $objvit >= $voconf(min_ppm) && $objvit <= $voconf(max_ppm) } {
                     set traceobjet 1
                     set objrap [ expr $voconf(AD_objet)  + $objdra/3600.0 ]
                     set objdep [ expr $voconf(Dec_objet) + $objdde/3600.0 ]
                     set img_xyp [ buf$audace(bufNo) radec2xy [ list $objrap $objdep ] ]
                     set dx [ expr $arrow_base * ([lindex $img_xyp 0] - [lindex $img_xy 0]) ]
                     set dy [ expr $arrow_base * ([lindex $img_xyp 1] - [lindex $img_xy 1]) ]
                  }
                 }
        default { set FormTrace "circle"
                  set traceobjet 1
                  set radius $radius_fixe
                 }
      }

      #--- Tracage des objets
      if { $traceobjet == 1 } {
         #--- Trace de la forme
         set x [lindex $can_xy 0]
         set y [lindex $can_xy 1]
         if {$FormTrace == "arrow"} {
            $audace(hCanvas) create line $x $y [expr $x + $dx ] [expr $y - $dy ] \
                -fill $color($mycolor) -tags cadres -width 2.0 -arrow last
         } else {
            $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
                -outline $color($mycolor) -tags cadres -width 2.0
         }
         #--- Designation des objets
         if { $voconf(label_objets) == 1 } {
            set voconf(name) [ lindex [ $tbl cellconfigure $idx,1 -text ] 4 ]
            $audace(hCanvas) create text [ expr $x - 20. ] [ expr $y - 20. ] -text $voconf(name) \
                -fill $color($mycolor) -tags cadres -font $audace(font,arial_10_n)
         }
      }

   }

   #
   # skybot_Search::cmdRepere_Efface
   # Repere et efface tous les objets du champ
   #
   proc cmdRepere_Efface { } {
      variable This
      global audace
      global color
      global voconf
      global valMinFiltre valMaxFiltre

      if { $voconf(trace_efface) == "1" } {

         #--- Repere les objets sur l'image
         $audace(hCanvas) delete cadres
         for { set i 0 } { $i <= [ expr $voconf(j) - 1 ] } { incr i } {
            #--- Quelques raccourcis
            set tbl $This.frame7.tbl      
            #--- Coordonnees equatoriales de l'objet
            set voconf(AD_objet) [ mc_angle2deg [ lindex [ $tbl cellconfigure $i,2 -text ] 4 ] ]
            set voconf(Dec_objet) [ mc_angle2deg [ lindex [ $tbl cellconfigure $i,3 -text ] 4 ] ]
            #--- Coordonnees images de l'objet
            set img_xy [ buf$audace(bufNo) radec2xy [ list $voconf(AD_objet) $voconf(Dec_objet) ] ]
            #--- Transformation des coordonnees image en coordonnees canvas
            set can_xy [ ::audace::picture2Canvas $img_xy ]
            #--- Materialisation des objets dans l'image
            ::skybot_Search::Trace_Objet $tbl $i $img_xy $can_xy "orange"
         }

      } else {

         #--- Efface les reperes des objets
         $audace(hCanvas) delete cadres

      }
   }

}

