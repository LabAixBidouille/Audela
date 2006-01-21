#
# Fichier : skybot_resolver.tcl
# Description : Recherche d'objets dans le champ d'une image
# Auteur : Jerome BERTHIER, Robert DELMAS, Alain KLOTZ et Michel PUJOL
# Date de mise a jour : 03 decembre 2005
#

namespace eval skybot_Resolver {
   global audace
   global voconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_resolver.cap ]\""

   #
   # skybot_Resolver::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This
      variable column_format
      global caption

      array set column_format { }
      #---
      set column_format(Num)          [ list 9  "$caption(resolver,num)"        right ]
      set column_format(Name)         [ list 12 "$caption(resolver,name)"       left ]
      set column_format(RAh)          [ list 12 "$caption(resolver,rah)"        right ]
      set column_format(DEdeg)        [ list 14 "$caption(resolver,dedeg)"      right ]
      set column_format(Class)        [ list 8  "$caption(resolver,class)"      left ]
      set column_format(Mv)           [ list 8  "$caption(resolver,mv)"         right ]
      set column_format(Errarcsec)    [ list 12 "$caption(resolver,errarcsec)"  right ]
      set column_format(darcsec)      [ list 11 "$caption(resolver,darcsec)"    right ]
      set column_format(dRAarcsec/h)  [ list 15 "$caption(resolver,draarcsec)"  right ]
      set column_format(dDECarcsec/h) [ list 16 "$caption(resolver,ddecarcsec)" right ]
      set column_format(Dgua)         [ list 17 "$caption(resolver,dgua)"       right ]
      set column_format(Dhua)         [ list 17 "$caption(resolver,dhua)"       right ]
      #---
      set This $this
      createDialog 
      tkwait visibility $This
   }

   #
   # skybot_Resolver::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::skybot_Resolver::recup_position
      destroy $This
   }

   #
   # skybot_Resolver::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
   #
   proc recup_position { } {
      variable This
      global audace
      global conf
      global voconf

      set voconf(geometry_resolver) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $voconf(geometry_resolver) ] ]
      set fin [ string length $voconf(geometry_resolver) ]
      set voconf(position_resolver) "+[ string range $voconf(geometry_resolver) $deb $fin ]"
      #---
      set conf(vo_tools,position_resolver) $voconf(position_resolver)
   }

   #
   # skybot_Resolver::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global conf
      global voconf

      #--- Initialisation
      set voconf(nom_objet)               ""
      set voconf(date_ephemerides_calcul) ""
      set voconf(ad_objet)                ""
      set voconf(ad_objet_d)              ""
      set voconf(ad_objet_h)              ""
      set voconf(dec_objet)               ""
      set voconf(dec_objet_d)             ""
      set voconf(mag_v_objet)             ""
      set voconf(taille_champ_min)        ""

      #--- initConf
      if { ! [ info exists conf(vo_tools,position_resolver) ] } { set conf(vo_tools,position_resolver) "+80+40" }
      if { ! [ info exists voconf(choix_date) ] }               { set voconf(choix_date)               "1" }
      if { ! [ info exists voconf(option_champ) ] }             { set voconf(option_champ)             "1" }

      #--- confToWidget
      set voconf(position_resolver) $conf(vo_tools,position_resolver)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame12.but_fermer
         return
      }

      #---
      if { [ info exists voconf(geometry_resolver) ] } {
         set deb [ expr 1 + [ string first + $voconf(geometry_resolver) ] ]
         set fin [ string length $voconf(geometry_resolver) ]
         set voconf(position_resolver) "+[ string range $voconf(geometry_resolver) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This 530x450$voconf(position_resolver)
      wm resizable $This 1 1
      wm title $This $caption(resolver,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::skybot_Resolver::fermer }

      #--- Cree un frame
      frame $This.frame1 \
         -borderwidth 1 -relief raised -cursor arrow
      pack $This.frame1 \
         -in $This -anchor s -side top -expand 0 -fill x

         #--- Cree un frame pour selectionner l'objet
         frame $This.frame2 \
            -borderwidth 0 -cursor arrow
         pack $This.frame2 \
            -in $This.frame1 -anchor s -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame2.lab \
               -text "$caption(resolver,nom_objet)"
            pack $This.frame2.lab \
               -in $This.frame2 -side left -anchor center \
               -padx 3 -pady 3

            #--- Cree une ligne d'entree
            entry $This.frame2.ent \
               -textvariable voconf(nom_objet) -width 25 -justify center
            pack $This.frame2.ent \
               -in $This.frame2 -side left -anchor center \
               -padx 3 -pady 3

            #--- Cree un label
            label $This.frame2.lab_exemples \
               -text "$caption(resolver,exemples_noms)"
            pack $This.frame2.lab_exemples \
               -in $This.frame2 -side left -anchor center \
               -padx 3 -pady 3

         #--- Cree un frame pour selectionner une date pour le calcul des ephemerides
         frame $This.frame3 \
            -borderwidth 0 -cursor arrow
         pack $This.frame3 \
            -in $This.frame1 -anchor w -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame3.label_date_ephemeride \
               -text "$caption(resolver,date_ephemeride)" \
               -borderwidth 0 -relief flat
            pack $This.frame3.label_date_ephemeride \
               -in $This.frame3 -side left \
               -padx 3 -pady 3

         #--- Cree un frame pour la selection de la date courante
         frame $This.frame4 \
            -borderwidth 0 -cursor arrow
         pack $This.frame4 \
            -in $This.frame3 -anchor w -side top -expand 0 -fill x

            #--- Bouton radio Date courante
            radiobutton $This.frame4.radiobutton_date_courante -highlightthickness 0 -state normal \
               -text "$caption(resolver,date_courante)" -value 1 -variable voconf(choix_date) \
               -command {
                  $::skybot_Resolver::This.frame5.entry_date_ephemerides configure -state disabled
                  set voconf(date_ephemerides_calcul) ""
               }
	      pack $This.frame4.radiobutton_date_courante \
               -in $This.frame4 -side left -anchor center \
               -padx 3 -pady 3

            #--- Cree un label
            label $This.frame4.label_date_ephemeride \
               -text "$caption(resolver,format_date)" \
               -borderwidth 0 -relief flat
            pack $This.frame4.label_date_ephemeride \
               -in $This.frame4 -side right -anchor center \
               -padx 10 -pady 3

          #--- Cree un frame pour la selection d'une date au choix
         frame $This.frame5 \
            -borderwidth 0 -cursor arrow
         pack $This.frame5 \
            -in $This.frame3 -anchor w -side top -expand 0 -fill x

           #--- Bouton radio Choix de la date
            radiobutton $This.frame5.radiobutton_choix_date -highlightthickness 0 -state normal \
               -text "$caption(resolver,choix_date)" -value 2 -variable voconf(choix_date) \
               -command {
                  $::skybot_Resolver::This.frame5.entry_date_ephemerides configure -state normal
               }
	      pack $This.frame5.radiobutton_choix_date \
               -in $This.frame5 -side left -anchor center \
               -padx 3 -pady 3

            #--- Cree une ligne d'entree
            entry $This.frame5.entry_date_ephemerides \
               -textvariable voconf(date_ephemerides_calcul) \
               -borderwidth 1 -relief groove -width 25 -justify center -state disabled
            pack $This.frame5.entry_date_ephemerides \
               -in $This.frame5 -side right -anchor center \
               -padx 15 -pady 3

         #--- Cree un frame pour le bouton du calcul des ephemerides
         frame $This.frame6 \
            -borderwidth 0 -cursor arrow
         pack $This.frame6 \
            -in $This.frame1 -anchor w -side top -expand 0 -fill x

            #--- Creation du bouton
            button $This.frame6.but_ephemerides \
               -text "$caption(resolver,calcul_ephemerides)" -borderwidth 2 \
               -command { ::skybot_Resolver::cmdResolver }
            pack $This.frame6.but_ephemerides \
               -in $This.frame6 -side left -anchor w \
               -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Cree un frame pour l'ascension droite de l'objet
         frame $This.frame7 \
            -borderwidth 0 -cursor arrow
         pack $This.frame7 \
            -in $This.frame6 -anchor w -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame7.label_ad_objet \
               -text "$caption(resolver,ad_objet)" \
               -borderwidth 0 -relief flat
            pack $This.frame7.label_ad_objet \
               -in $This.frame7 -side left \
               -padx 3 -pady 3

            #--- Cree un label pour une variable
            label $This.frame7.data_ad_objet_hms \
               -textvariable voconf(ad_objet_h) \
               -borderwidth 0 -relief flat
            pack $This.frame7.data_ad_objet_hms \
               -in $This.frame7 -side left \
               -padx 0 -pady 3

         #--- Cree un frame pour la declinaison de l'objet
         frame $This.frame8 \
            -borderwidth 0 -cursor arrow
         pack $This.frame8 \
            -in $This.frame6 -anchor w -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame8.label_dec_objet \
               -text "$caption(resolver,dec_objet)" \
               -borderwidth 0 -relief flat
            pack $This.frame8.label_dec_objet \
               -in $This.frame8 -side left \
               -padx 3 -pady 3

            #--- Cree un label pour une variable
            label $This.frame8.data_dec_objet_dms \
               -textvariable voconf(dec_objet_d) \
               -borderwidth 0 -relief flat
            pack $This.frame8.data_dec_objet_dms \
               -in $This.frame8 -side left \
               -padx 0 -pady 3

         #--- Cree un frame pour la magnitude visuelle
         frame $This.frame8a \
            -borderwidth 0 -cursor arrow
         pack $This.frame8a \
            -in $This.frame6 -anchor w -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame8a.label_mag_v_objet \
               -text "$caption(resolver,mag_v)" \
               -borderwidth 0 -relief flat
            pack $This.frame8a.label_mag_v_objet \
               -in $This.frame8a -side left \
               -padx 3 -pady 3

            #--- Cree un label pour une variable
            label $This.frame8a.data_mag_v_objet \
               -textvariable voconf(mag_v_objet) \
               -borderwidth 0 -relief flat
            pack $This.frame8a.data_mag_v_objet \
               -in $This.frame8a -side left \
               -padx 0 -pady 3

      #--- Cree un frame pour le champ
      frame $This.frame9 \
         -borderwidth 1 -relief raised -cursor arrow
      pack $This.frame9 \
         -in $This -anchor s -side top -expand 0 -fill x

         #--- Cree un frame pour la taille du champ autour de l'objet
         frame $This.frame10 \
            -borderwidth 0 -cursor arrow
         pack $This.frame10 \
            -in $This.frame9 -anchor s -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame10.label_taille_champ \
               -text "$caption(resolver,taille_champ)" \
               -borderwidth 0 -relief flat
            pack $This.frame10.label_taille_champ \
               -in $This.frame10 -side left \
               -padx 3 -pady 3

            #--- Cree une ligne d'entree
            entry $This.frame10.entry_taille_champ \
               -textvariable voconf(taille_champ_min) \
               -borderwidth 1 -relief groove -width 6 -justify center
            pack $This.frame10.entry_taille_champ \
               -in $This.frame10 -side left \
               -padx 3 -pady 3

            #--- Cree un label
            label $This.frame10.label_sec_arc \
               -text "$caption(resolver,minutes_arc)" \
               -borderwidth 0 -relief flat
            pack $This.frame10.label_sec_arc \
               -in $This.frame10 -side left \
               -padx 3 -pady 3

            #--- Bouton radio Rayon du champ
            radiobutton $This.frame10.radiobutton_rayon_champ -highlightthickness 0 -state normal \
               -text "$caption(resolver,champ_rayon)" -value 1 -variable voconf(option_champ) \
               -command { }
	      pack $This.frame10.radiobutton_rayon_champ \
               -in $This.frame10 -side left \
               -padx 3 -pady 3

           #--- Bouton radio Diametre du champ
            radiobutton $This.frame10.radiobutton_diametre_champ -highlightthickness 0 -state normal \
               -text "$caption(resolver,champ_diametre)" -value 2 -variable voconf(option_champ) \
               -command { }
	      pack $This.frame10.radiobutton_diametre_champ \
               -in $This.frame10 -side left \
               -padx 3 -pady 3

         #--- Cree un frame pour la recherche des objets aux alentours
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This.frame9 -anchor s -side top -expand 0 -fill x

            #--- Creation du bouton
            button $This.frame11.but_recherche \
               -text "$caption(resolver,recherche)" -borderwidth 2 \
               -command { ::skybot_Resolver::cmdsearchResolver }
            pack $This.frame11.but_recherche \
               -in $This.frame11 -side left -anchor w \
               -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

            #--- Cree un label
            label $This.frame11.labURL_objet_trouve \
               -text "" -borderwidth 0 -relief flat
            pack $This.frame11.labURL_objet_trouve \
               -in $This.frame11 -side left \
               -padx 20 -pady 3

      #--- Cree un frame pour y mettre les boutons
      frame $This.frame12 \
         -borderwidth 0 -cursor arrow
      pack $This.frame12 \
         -in $This -anchor s -side bottom -expand 0 -fill x

         #--- Creation du bouton de recherche des caracteristiques de l'objet
         button $This.frame12.but_caract -state disabled \
            -text "$caption(resolver,caract_objet)" -borderwidth 2 \
            -command {
               set filename "http://vizier.u-strasbg.fr/cgi-bin/VizieR-5?-source=B/astorb/astorb&amp;Name===$voconf(name)"
               ::audace::Lance_Site_htm $filename
            }
         pack $This.frame12.but_caract \
            -in $This.frame12 -side left -anchor w \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton fermer
         button $This.frame12.but_fermer \
            -text "$caption(resolver,fermer)" -borderwidth 2 \
            -command { ::skybot_Resolver::fermer }
         pack $This.frame12.but_fermer \
            -in $This.frame12 -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton aide
         button $This.frame12.but_aide \
            -text "$caption(resolver,aide)" -borderwidth 2 \
            -command { ::audace::showHelpPlugin tool vo_tools vo_tools.htm }
         pack $This.frame12.but_aide \
            -in $This.frame12 -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      #--- Cree un frame pour l'affichage du resultat de la recherche
      frame $This.frame13
      pack $This.frame13 -expand yes -fill both

         #--- Cree un acsenseur vertical
         scrollbar $This.frame13.vsb -orient vertical \
            -command { $::skybot_Resolver::This.frame13.lst1 yview } -takefocus 1 -borderwidth 1
         pack $This.frame13.vsb \
            -in $This.frame13 -side right -fill y

         #--- Cree un acsenseur horizontal
         scrollbar $This.frame13.hsb -orient horizontal \
            -command { $::skybot_Resolver::This.frame13.lst1 xview } -takefocus 1 -borderwidth 1
         pack $This.frame13.hsb \
            -in $This.frame13 -side bottom -fill x

         #--- Creation de la table
         ::skybot_Resolver::createTbl $This.frame13
         pack $This.frame13.tbl \
            -in $This.frame13 -expand yes -fill both

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   #  skybot_Resolver::createTbl
   #  Affiche la table avec ses scrollbars dans un frame
   #
   proc createTbl { frame } {
      variable This
      global audace
      global caption
      global voconf

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl      
      set popupTbl $frame.popupTbl
      set menu $frame.menu

      #--- Table des objets
      set titre_colonnes { Num Name RA(h) DE(deg) Class Mv Err(arcsec) d(arcsec) dRA(arcsec/h) dDEC(arcsec/h) \
         Dg(ua) Dh(ua) }
      tablelist::tablelist $tbl \
         -labelcommand ::skybot_Resolver::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table 
      menu $popupTbl -tearoff no
      #--- Acces au mode Goto
      $popupTbl add command -label $caption(resolver,goto) -state disabled
      #--- Separateur
      $popupTbl add separator
      #--- Acces a l'aide
      $popupTbl add command -label $caption(resolver,aide) \
         -command { ::audace::showHelpPlugin "tool" "vo_tools" "vo_tools.htm" }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ] 
      bind $tbl <<ListboxSelect>>          [ list ::skybot_Resolver::cmdButton1Click $This.frame13 ]
   }

   #
   # skybot_Resolver::cmdSortColumn
   # Trie les lignes par ordre alphabetique de la colonne (est appele quand on clique sur le titre de la colonne)
   #
   proc cmdSortColumn { tbl col } {
      tablelist::sortByColumn $tbl $col
   }

   #
   # skybot_Resolver::cmdButton1Click
   # Charge l'item selectionne avec la souris dans la liste
   #
   proc cmdButton1Click { frame } {
      variable This
      global audace
      global catalogue
      global caption
      global voconf

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
         $::skybot_Resolver::This.frame12.but_caract configure -state disabled
         #--- Je desactive l'acces au mode Goto
         $popupTbl entryconfigure $caption(resolver,goto) -state disabled
      } else {
         #--- Gestion des boutons
         $::skybot_Resolver::This.frame12.but_caract configure -state normal
         #--- J'active l'acces au mode Goto
         $popupTbl entryconfigure $caption(resolver,goto) -state normal \
            -command {
               if { [ ::tel::list ] == "" } {
                  ::confTel::run 
                  tkwait window $audace(base).confTel
               }
               ::skybot_Resolver::affiche_Outil_Tlscp
               set catalogue(asteroide_choisi) $voconf(name)
               ::Tlscp::Gestion_Cata $caption(resolver,asteroide)
            }
      }
   }

   #
   # skybot_Resolver::affiche_Outil_Tlscp
   # Affiche l'outil Telescope
   #
   proc affiche_Outil_Tlscp { } {
      global audace
      global panneau

      #---
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         if { $m == "menu_name,Tlscp" } {
            if { [scan "$m" "menu_name,%s" ns] == "1" } {
               #--- Lancement automatique de l'outil Telescope
               ::confVisu::selectTool $audace(visuNo) ::$ns
            }
         }
      }
   }

   #
   # skybot_Resolver::cmdFormatColumn
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
   # skybot_Resolver::cmdResolver
   # Recherche les ephemerides d'un objet
   #
   proc cmdResolver { } {
      variable This
      global caption
      global color
      global voconf

      #--- Statut de la commande
      $This.frame11.labURL_objet_trouve configure -text "$caption(resolver,msg_attente)" -fg $color(red)

      #--- Gestion des boutons
      $::skybot_Resolver::This.frame6.but_ephemerides configure -relief groove -state disabled
      $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state disabled
      $::skybot_Resolver::This.frame12.but_caract configure -relief raised -state disabled

      #--- Traitement de la presence du nom de l'objet
      if { $voconf(nom_objet) == "" } {
         tk_messageBox -title $caption(resolver,msg_probleme) -type ok \
            -message "$caption(resolver,msg_pas_de_nom)"
         focus $This.frame2.ent
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }

      #--- Traitement de la date
      if { $voconf(choix_date) == "1" } {
         set voconf(date_ephemerides) [ mc_date2jd now ]
      } elseif { $voconf(choix_date) == "2" } {
         set voconf(date_ephemerides) [ mc_date2jd $voconf(date_ephemerides_calcul) ]
      }

      #--- Tests sur la date
      if { ( $voconf(date_ephemerides_calcul) == "" ) && ( $voconf(choix_date) == "2" ) } {
         tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_reel_date)
         set voconf(date_ephemerides_calcul) ""
         focus $This.frame5.entry_date_ephemerides
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }
      #---
      set date [ mc_date2jd $voconf(date_ephemerides) ]
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
            tk_messageBox -title $caption(resolver,msg_probleme) -type ok \
               -message "$caption(resolver,msg_reel_date>) $date_debut_"
            set voconf(date_ephemerides_calcul) ""
            focus $This.frame5.entry_date_ephemerides
            $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
            $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
            $This.frame11.labURL_objet_trouve configure -text ""
            return
         }
         #---
         if { $date >= $date_fin } {
            tk_messageBox -title $caption(resolver,msg_probleme) -type ok \
               -message "$caption(resolver,msg_reel_date<) $date_fin_"
            set voconf(date_ephemerides_calcul) ""
            focus $This.frame5.entry_date_ephemerides
            $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
            $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
            $This.frame11.labURL_objet_trouve configure -text ""
            return
         }
      }

      #--- RAZ de la liste
      $::skybot_Resolver::This.frame13.tbl delete 0 end
      if { [ $::skybot_Resolver::This.frame13.tbl columncount ] != "0" } {
         $::skybot_Resolver::This.frame13.tbl deletecolumns 0 end
      }

      #--- Traitement du nom des objets
      set voconf(nom_objet) [ suppr_accents $voconf(nom_objet) ]

      #--- Demande et extraction des ephemerides
      set erreur [ catch { vo_skybotresolver $voconf(date_ephemerides) $voconf(nom_objet) } liste ]
      if { $erreur == "0" } {
         set liste_titres [ lindex $liste 0 ]
         #--- Traitement d'une erreur particuliere, la requete repond 'item'
         if { $liste_titres == "item" } {
            $::skybot_Resolver::This.frame13.tbl insertcolumns end 100 "$caption(resolver,msg_erreur)" left
            $::skybot_Resolver::This.frame13.tbl insert end [ list $caption(resolver,msg_item) ]
            $::skybot_Resolver::This.frame13.tbl cellconfigure 0,0 -fg $color(red)
            set voconf(ad_objet)    ""
            set voconf(ad_objet_d)  ""
            set voconf(ad_objet_h)  ""
            set voconf(dec_objet)   ""
            set voconf(dec_objet_d) ""
            set voconf(mag_v_objet) ""
            #--- Statut de la commande
            $This.frame11.labURL_objet_trouve configure -text ""
         } else {
            regsub -all "\'" [ lindex $liste 1 ] "\"" liste_objet
            set voconf(ad_objet) [ lindex $liste_objet 2 ]
            set voconf(ad_objet_d) [ expr 15.0 * $voconf(ad_objet) ]
            set voconf(ad_objet_h) [ mc_angle2hms $voconf(ad_objet_d) 360 zero 2 auto string ]
            set voconf(dec_objet) [ lindex $liste_objet 3 ]
            set voconf(dec_objet_d) [ mc_angle2dms $voconf(dec_objet) 90 zero 2 + string ]
            set voconf(mag_v_objet) [ lindex $liste_objet 5 ]
            #--- Statut de la commande
            $This.frame11.labURL_objet_trouve configure -text "$caption(resolver,msg_terminee)" -fg $color(red)
         }
      } else {
         $::skybot_Resolver::This.frame13.tbl insertcolumns end 100 "$caption(resolver,msg_erreur)" left
         if { [ lindex [ lindex $liste 0 ] 0 ] == "SKYBOTResolver" } {
            set msg_erreur [ lindex $liste 1 ]
            $::skybot_Resolver::This.frame13.tbl insert end [ list $msg_erreur ]
            $::skybot_Resolver::This.frame13.tbl cellconfigure 0,0 -fg $color(red)
         } else {
            $::skybot_Resolver::This.frame13.tbl insert end [ list $caption(resolver,msg_internet) ]
            $::skybot_Resolver::This.frame13.tbl cellconfigure 0,0 -fg $color(red)
         }
         set voconf(ad_objet)    ""
         set voconf(ad_objet_d)  ""
         set voconf(ad_objet_h)  ""
         set voconf(dec_objet)   ""
         set voconf(dec_objet_d) ""
         set voconf(mag_v_objet) ""
         #--- Statut de la commande
         $This.frame11.labURL_objet_trouve configure -text ""
      }

      #--- Gestion des boutons
      $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
      $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # skybot_Resolver::cmdsearchResolver
   # Recherche les ephemerides des objets environnants
   #
   proc cmdsearchResolver { } {
      variable This
      global audace
      global caption
      global color
      global voconf

      #--- Statut de la commande
      $This.frame11.labURL_objet_trouve configure -text "$caption(resolver,msg_attente)" -fg $color(red)

      #--- Gestion des boutons
      $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state disabled
      $::skybot_Resolver::This.frame11.but_recherche configure -relief groove -state disabled
      $::skybot_Resolver::This.frame12.but_caract configure -relief raised -state disabled

      #--- Tests pour les donnees indispensables
      if { ( $voconf(ad_objet) == "" ) || ( $voconf(dec_objet) == "" ) } {
         tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_pas_de_donnees)
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }

      #--- Tests sur l'ascension droite
      if { ( [ string is double -strict $voconf(ad_objet_d) ] == "0" ) \
            || ( $voconf(ad_objet_d) == "" ) || ( $voconf(ad_objet_d) < "0.0" ) \
            || ( $voconf(ad_objet_d) > "360.0" ) } {
         tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_reel_ad)
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }

      #--- Tests sur la declinaison
      if { ( [ string is double -strict $voconf(dec_objet) ] == "0" ) \
            || ( $voconf(dec_objet) == "" ) || ( $voconf(dec_objet) < "-90.0" ) \
            || ( $voconf(dec_objet) > "90.0" ) } {
         tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_reel_dec)
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }

      #--- Tests sur la dimension du champ
      if { ( [ string is double -strict $voconf(taille_champ_min) ] == "0" ) \
            || ( $voconf(taille_champ_min) == "" ) || ( $voconf(taille_champ_min) <= "0" ) \
            || ( ( $voconf(taille_champ_min) > "600.0" ) && ( $voconf(option_champ) == "1" ) ) \
            || ( ( $voconf(taille_champ_min) > "1200.0" ) && ( $voconf(option_champ) == "2" ) ) } {
         if { $voconf(option_champ) == "1" } {
            tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_reel_champ_1)
         } elseif { $voconf(option_champ) == "2" } {
            tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_reel_champ_2)
         }
         set voconf(taille_champ_min) ""
         focus $This.frame10.entry_taille_champ
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }

      #--- Traitement de la date
      if { $voconf(choix_date) == "1" } {
         set voconf(date_ephemerides) [ mc_date2jd now ]
      } elseif { $voconf(choix_date) == "2" } {
         set voconf(date_ephemerides) [ mc_date2jd $voconf(date_ephemerides_calcul) ]
      }

      #--- Tests sur la date
      if { ( $voconf(date_ephemerides_calcul) == "" ) && ( $voconf(choix_date) == "2" ) } {
         tk_messageBox -title $caption(resolver,msg_probleme) -type ok -message $caption(resolver,msg_reel_date)
         set voconf(date_ephemerides_calcul) ""
         focus $This.frame5.entry_date_ephemerides
         $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
         $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
         $This.frame11.labURL_objet_trouve configure -text ""
         return
      }
      #---
      set date [ mc_date2jd $voconf(date_ephemerides) ]
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
            tk_messageBox -title $caption(resolver,msg_probleme) -type ok \
               -message "$caption(resolver,msg_reel_date>) $date_debut_"
            set voconf(date_ephemerides_calcul) ""
            focus $This.frame5.entry_date_ephemerides
            $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
            $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
            $This.frame11.labURL_objet_trouve configure -text ""
            return
         }
         #---
         if { $date >= $date_fin } {
            tk_messageBox -title $caption(resolver,msg_probleme) -type ok \
               -message "$caption(resolver,msg_reel_date<) $date_fin_"
            set voconf(date_ephemerides_calcul) ""
            focus $This.frame5.entry_date_ephemerides
            $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
            $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal
            $This.frame11.labURL_objet_trouve configure -text ""
            return
         }
      }

      #--- RAZ de la liste
      $::skybot_Resolver::This.frame13.tbl delete 0 end
      if { [ $::skybot_Resolver::This.frame13.tbl columncount ] != "0" } {
         $::skybot_Resolver::This.frame13.tbl deletecolumns 0 end
      }

      #--- Extraction, suppression des virgules et creation des colonnes du tableau
      set voconf(taille_champ) [ expr $voconf(taille_champ_min) * 60.0 / $voconf(option_champ) ]
      set erreur \
         [ catch { vo_skybot $voconf(date_ephemerides) $voconf(ad_objet_d) $voconf(dec_objet) \
         $voconf(taille_champ) } voconf(liste) ]
      if { $erreur == "0" } {
         set liste_titres [ lindex $voconf(liste) 0 ]
         regsub -all "," $liste_titres "" liste_titres
         for { set i 1 } { $i <= [ expr [ llength $liste_titres ] - 1 ] } { incr i } {
            set format [ ::skybot_Resolver::cmdFormatColumn [ lindex $liste_titres $i ] ]
            $::skybot_Resolver::This.frame13.tbl insertcolumns end [ lindex $format 0 ] [ lindex $format 1 ] \
               [ lindex $format 2 ]
         }
         #--- Traitement d'une erreur particuliere, la requete repond 'item'
         if { $liste_titres == "item" } {
            $::skybot_Resolver::This.frame13.tbl insertcolumns end 100 "$caption(resolver,msg_erreur)" left
            $::skybot_Resolver::This.frame13.tbl insert end [ list $caption(resolver,msg_item) ]
            $::skybot_Resolver::This.frame13.tbl cellconfigure 0,0 -fg $color(red)
            set voconf(ad_objet)    ""
            set voconf(ad_objet_d)  ""
            set voconf(ad_objet_h)  ""
            set voconf(dec_objet)   ""
            set voconf(dec_objet_d) ""
            set voconf(mag_v_objet) ""
            #--- Statut de la commande
            $This.frame11.labURL_objet_trouve configure -text ""
         } else {
            #--- Je classe les fichiers par ordre alphabetique sans tenir compte des majuscules/minuscules
            if { [ $::skybot_Resolver::This.frame13.tbl columncount ] != "0" } {
               $::skybot_Resolver::This.frame13.tbl columnconfigure 1 -sortmode dictionary
            }
            #--- Extraction du resultat
            for { set i 1 } { $i <= [ expr [ llength $voconf(liste) ] - 1 ] } { incr i } { 
               regsub -all "\'" [ lindex $voconf(liste) $i ] "\"" vo_objet($i)
               #--- Mise en forme de l'ascension droite
               set ad [ expr 15.0 * [ lindex $vo_objet($i) 2 ] ]
               #--- Mise en forme de la declinaison
               set dec [ lindex $vo_objet($i) 3 ]
               #--- Liste les objets qui sont sur l'image
               $::skybot_Resolver::This.frame13.tbl insert end $vo_objet($i)
            }
            #---
            if { [ $::skybot_Resolver::This.frame13.tbl columncount ] != "0" } {
               #--- Je trie par ordre alphabetique de la premiere colonne 
               ::skybot_Resolver::cmdSortColumn $::skybot_Resolver::This.frame13.tbl 0
               #--- Les noms des objets sont en bleu
               for { set i 0 } { $i <= [ expr [ llength $voconf(liste) ] - 2 ] } { incr i } {
                  $::skybot_Resolver::This.frame13.tbl cellconfigure $i,1 -fg $color(blue)
                  #--- Mise en forme de l'ascension droite
                  set ad [ $::skybot_Resolver::This.frame13.tbl cellcget $i,2 -text ]
                  set ad [ expr $ad * 15.0 ]
                  $::skybot_Resolver::This.frame13.tbl cellconfigure $i,2 -text [ mc_angle2hms $ad 360 zero 2 auto string ]
                  #--- Mise en forme de la declinaison
                  set dec [ $::skybot_Resolver::This.frame13.tbl cellcget $i,3 -text ]
                  $::skybot_Resolver::This.frame13.tbl cellconfigure $i,3 -text [ mc_angle2dms $dec 90 zero 2 + string ]
               }
               #--- Bilan des objets trouves dans l'image
               if { $i > "1" } {
                  #--- Statut de la commande
                  $This.frame11.labURL_objet_trouve configure -text "$caption(resolver,msg_nbre_objets) $i" -fg $color(red)
               } else {
                  #--- Statut de la commande
                  $This.frame11.labURL_objet_trouve configure -text "$caption(resolver,msg_nbre_objet) $i" -fg $color(red)
               }
            }
         }
      } else {
         $::skybot_Resolver::This.frame13.tbl insertcolumns end 100 "$caption(resolver,msg_erreur)" left
         if { [ lindex [ lindex $voconf(liste) 0 ] 0 ] == "SKYBOT" } {
            set msg_erreur [ lindex $voconf(liste) 1 ]
            $::skybot_Resolver::This.frame13.tbl insert end [ list $msg_erreur ]
            $::skybot_Resolver::This.frame13.tbl cellconfigure 0,0 -fg $color(red)
         } else {
            $::skybot_Resolver::This.frame13.tbl insert end [ list $caption(resolver,msg_internet) ]
            $::skybot_Resolver::This.frame13.tbl cellconfigure 0,0 -fg $color(red)
         }
         set voconf(ad_objet)    ""
         set voconf(ad_objet_d)  ""
         set voconf(ad_objet_h)  ""
         set voconf(dec_objet)   ""
         set voconf(dec_objet_d) ""
         set voconf(mag_v_objet) ""
         #--- Statut de la commande
         $This.frame11.labURL_objet_trouve configure -text ""
      }

      #--- Gestion des boutons
      $::skybot_Resolver::This.frame6.but_ephemerides configure -relief raised -state normal
      $::skybot_Resolver::This.frame11.but_recherche configure -relief raised -state normal

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

