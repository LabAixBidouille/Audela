#
# Fichier : skybot_statut.tcl
# Description : Affiche le statut de la base de donnees SkyBoT
# Auteur : Jerome BERTHIER, Robert DELMAS, Alain KLOTZ et Michel PUJOL
# Date de mise a jour : 27 octobre 2005
#

namespace eval skybot_Statut {
   global audace
   global voconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_statut.cap ]\""

   #
   # skybot_Statut::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog 
   }

   #
   # skybot_Statut::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::skybot_Statut::recup_position
      destroy $This
   }

   #
   # skybot_Statut::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
   #
   proc recup_position { } {
      variable This
      global audace
      global conf
      global voconf

      set voconf(geometry_statut) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $voconf(geometry_statut) ] ]
      set fin [ string length $voconf(geometry_statut) ]
      set voconf(position_statut) "+[ string range $voconf(geometry_statut) $deb $fin ]"
      #---
      set conf(vo_tools,position_statut) $voconf(position_statut)
   }

   #
   # skybot_Statut::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global voconf

      #--- initConf
      if { ! [ info exists conf(vo_tools,position_statut) ] } { set conf(vo_tools,position_statut) "+80+40" }

      #--- confToWidget
      set voconf(position_statut) $conf(vo_tools,position_statut)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         #--- Gestion du bouton
         $audace(base).vo_tools.fra5.but1 configure -relief raised -state normal
         return
      }

      #---
      if { [ info exists voconf(geometry_statut) ] } {
         set deb [ expr 1 + [ string first + $voconf(geometry_statut) ] ]
         set fin [ string length $voconf(geometry_statut) ]
         set voconf(position_statut) "+[ string range $voconf(geometry_statut) $deb $fin ]"
      }

      #--- Interrogation de la base de donnees
      set erreur [ catch { vo_skybotstatus } statut ]

      #---
      toplevel $This -class Toplevel
      wm geometry $This 350x310$voconf(position_statut)
      wm resizable $This 1 1
      wm title $This $caption(statut,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::skybot_Statut::fermer }

      #--- Gestion des erreurs
      if { $erreur == "0" } {

         #--- Mise en forme du resultat
         set statut [ lindex $statut 1 ]
         regsub -all "\'" $statut "\"" statut

         #--- Cree un frame pour afficher le statut de la base
         frame $This.frame1 \
            -borderwidth 0 -cursor arrow
         pack $This.frame1 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame1.statut_base -font $audace(font,arial_8_b) \
               -text "$caption(statut,titre1) [ lindex $statut 0 ]"
            pack $This.frame1.statut_base \
               -in $This.frame1 -side left \
               -padx 3 -pady 3  

         #--- Cree un frame pour afficher la periode de validite des donnees de la base
         frame $This.frame2 \
            -borderwidth 0 -cursor arrow
         pack $This.frame2 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame2.periode -font $audace(font,arial_8_b) \
               -text "$caption(statut,titre2)"
            pack $This.frame2.periode \
               -in $This.frame2 -side left \
               -padx 3 -pady 3

         #--- Cree un frame pour afficher la periode de validite des donnees de la base
         frame $This.frame3 \
            -borderwidth 0 -cursor arrow
         pack $This.frame3 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Date du debut
            set date [ mc_date2ymdhms [ lindex $statut 1 ] ]
            set date_debut [ format "%02d/%02d/%2s $caption(statut,titre6) %02d:%02d:%02.0f" [ lindex $date 2 ] \
               [ lindex $date 1 ] [ lindex $date 0 ] [ lindex $date 3 ] [ lindex $date  4 ] [ lindex $date  5 ] ]

            #--- Date de fin
            set date [ mc_date2ymdhms [ lindex $statut 2 ] ]
            set date_fin [ format "%02d/%02d/%2s $caption(statut,titre6) %02d:%02d:%02.0f" [ lindex $date 2 ] \
               [ lindex $date 1 ] [ lindex $date 0 ] [ lindex $date 3 ] [ lindex $date  4 ] [ lindex $date  5 ] ]

            #--- Cree un label
            label $This.frame3.periode_debut -font $audace(font,arial_8_b) \
               -text "     $date_debut $caption(statut,titre3) $date_fin"
            pack $This.frame3.periode_debut \
               -in $This.frame3 -side left \
               -padx 3 -pady 3

         #--- Cree un frame pour afficher le contenu de la base
         frame $This.frame4 \
            -borderwidth 0 -cursor arrow
         pack $This.frame4 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame4.contenu_base -font $audace(font,arial_8_b) \
               -text "$caption(statut,titre4)"
            pack $This.frame4.contenu_base \
               -in $This.frame4 -side left \
               -padx 3 -pady 3

         #--- Cree un frame pour afficher le nombre d'asteroides
         frame $This.frame5 \
            -borderwidth 0 -cursor arrow
         pack $This.frame5 \
            -in $This -anchor s -side top -expand 0 -fill x

         #--- Nombre d'asteroides
         set nbr_asteroides [ lindex $statut 3 ]

            #--- Cree un label
            if { $nbr_asteroides > "1" } {
               label $This.frame5.nb_asteroides -font $audace(font,arial_8_b) \
                  -text "     - $nbr_asteroides $caption(statut,asteroides)"
               pack $This.frame5.nb_asteroides \
                  -in $This.frame5 -side left \
                  -padx 3 -pady 3
            } else {
               label $This.frame5.nb_asteroides -font $audace(font,arial_8_b) \
                  -text "     - $nbr_asteroides $caption(statut,asteroide)"
               pack $This.frame5.nb_asteroides \
                  -in $This.frame5 -side left \
                  -padx 3 -pady 3
            }

         #--- Cree un frame pour afficher le nombre de planetes
         frame $This.frame6 \
            -borderwidth 0 -cursor arrow
         pack $This.frame6 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Nombre de planetes
            set nbr_planetes [ lindex $statut 4 ]

            #--- Cree un label
            if { $nbr_planetes > "1" } {
               label $This.frame6.nb_planetes -font $audace(font,arial_8_b) \
                  -text "     - $nbr_planetes $caption(statut,planetes)"
               pack $This.frame6.nb_planetes \
                  -in $This.frame6 -side left \
                  -padx 3 -pady 3
            } else {
               label $This.frame6.nb_planetes -font $audace(font,arial_8_b) \
                  -text "     - $nbr_planetes $caption(statut,planete)"
               pack $This.frame6.nb_planetes \
                  -in $This.frame6 -side left \
                  -padx 3 -pady 3
            }

         #--- Cree un frame pour afficher le nombre de satellites naturels
         frame $This.frame7 \
            -borderwidth 0 -cursor arrow
         pack $This.frame7 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Nombre de satellites naturels
            set nbr_satellites [ lindex $statut 5 ]

            #--- Cree un label
            if { $nbr_satellites > "1" } {
               label $This.frame7.nb_satellites_naturels -font $audace(font,arial_8_b) \
                  -text "     - $nbr_satellites $caption(statut,satellites)"
               pack $This.frame7.nb_satellites_naturels \
                  -in $This.frame7 -side left \
                  -padx 3 -pady 3
            } else {
               label $This.frame7.nb_satellites_naturels -font $audace(font,arial_8_b) \
                  -text "     - $nbr_satellites $caption(statut,satellite)"
               pack $This.frame7.nb_satellites_naturels \
                  -in $This.frame7 -side left \
                  -padx 3 -pady 3
            }

         #--- Cree un frame pour afficher le nombre de cometes
         frame $This.frame8 \
            -borderwidth 0 -cursor arrow
         pack $This.frame8 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Nombre de cometes
            set nbr_cometes [ lindex $statut 6 ]

            #--- Cree un label
            if { $nbr_cometes > "1" } {
               label $This.frame8.nb_cometes -font $audace(font,arial_8_b) \
                  -text "     - $nbr_cometes $caption(statut,cometes)"
               pack $This.frame8.nb_cometes \
                  -in $This.frame8 -side left \
                  -padx 3 -pady 3
            } else {
               label $This.frame8.nb_cometes -font $audace(font,arial_8_b) \
                  -text "     - $nbr_cometes $caption(statut,comete)"
               pack $This.frame8.nb_cometes \
                  -in $This.frame8 -side left \
                  -padx 3 -pady 3
            }

         #--- Cree un frame pour afficher la date de la derniere mise a jour de la base
         frame $This.frame9 \
            -borderwidth 0 -cursor arrow
         pack $This.frame9 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Cree un label
            label $This.frame9.mise_a_jour -font $audace(font,arial_8_b) \
               -text "$caption(statut,titre5)"
            pack $This.frame9.mise_a_jour \
               -in $This.frame9 -side left \
               -padx 3 -pady 3

         #--- Cree un frame pour afficher la date de la derniere mise a jour de la base
         frame $This.frame10 \
            -borderwidth 0 -cursor arrow
         pack $This.frame10 \
            -in $This -anchor s -side top -expand 0 -fill x

            #--- Date de mise a jour
            set date [ mc_date2ymdhms [ lindex $statut 7 ] ]
            set date_mise_a_jour [ format "%02d/%02d/%2s" [ lindex $date 2 ] [ lindex $date 1 ] [string range [ lindex $date 0 ] 2 3 ] ]

            #--- Cree un label
            label $This.frame10.date_mise_a_jour -font $audace(font,arial_8_b) \
               -text "     $date_mise_a_jour $caption(statut,titre6) [ lindex $statut 8 ]"
            pack $This.frame10.date_mise_a_jour \
               -in $This.frame10 -side left \
               -padx 3 -pady 3

      } else {

         #--- Cree un frame pour afficher le statut de la base
         frame $This.frame1 \
            -borderwidth 0 -cursor arrow
         pack $This.frame1 \
            -in $This -anchor s -side top -expand 1 -fill both

            #--- Cree un label
            label $This.frame1.labURLRed_statut_base -font $audace(font,arial_8_b) \
               -text "$caption(statut,msg_internet)" -fg $color(red)
            pack $This.frame1.labURLRed_statut_base \
               -in $This.frame1 -side left -anchor center -expand true \
               -padx 3 -pady 3  

      }

      #--- Cree un frame pour y mettre les boutons
      frame $This.frame11 \
         -borderwidth 0 -cursor arrow
      pack $This.frame11 \
         -in $This -anchor s -side bottom -expand 0 -fill x

         #--- Creation du bouton fermer
         button $This.frame11.but_fermer \
            -text "$caption(statut,fermer)" -borderwidth 2 \
            -command { ::skybot_Statut::fermer }
         pack $This.frame11.but_fermer \
            -in $This.frame11 -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton aide
         button $This.frame11.but_aide \
            -text "$caption(statut,aide)" -borderwidth 2 \
            -command { ::audace::showHelpPlugin tool vo_tools vo_tools.htm }
         pack $This.frame11.but_aide \
            -in $This.frame11 -side right -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      #--- Gestion du bouton
      $audace(base).vo_tools.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

