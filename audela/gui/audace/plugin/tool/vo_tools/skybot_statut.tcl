#
# Fichier : skybot_statut.tcl
# Description : Affiche le statut de la base de donnees SkyBoT
# Auteur : Jerome BERTHIER, Robert DELMAS, Alain KLOTZ et Michel PUJOL
# Mise a jour $Id: skybot_statut.tcl,v 1.13 2008-12-01 18:13:43 robertdelmas Exp $
#

namespace eval skybot_Statut {
   global audace
   global voconf

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool vo_tools skybot_statut.cap ]

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
         $audace(base).tool.vo_tools.fra5.but1 configure -relief raised -state normal
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

      #--- Gestion des erreurs
      if { $erreur == "0" && $statut != "failed" && $statut != "error"} {

         #---
         toplevel $This -class Toplevel
         wm geometry $This $voconf(position_statut)
         wm resizable $This 1 1
         wm title $This $caption(statut,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::skybot_Statut::fermer }

         #--- Mise en forme du resultat
         set statut [lindex [split $statut ";"] 1]
         regsub -all "\'" $statut "" statut
         set statut [split $statut "|"]

           #--- Date du debut
           set date [ mc_date2ymdhms [lindex $statut 1] ]
           set date_debut [format "%2s-%02d-%02d %02d:%02d:%02.0f" [lindex $date 0] [lindex $date 1] [lindex $date 2] \
                                                                   [lindex $date 3] [lindex $date  4] [lindex $date  5] ]

           #--- Date de fin
           set date [ mc_date2ymdhms [lindex $statut 2] ]
           set date_fin [ format "%2s-%02d-%02d %02d:%02d:%02.0f" [lindex $date 0] [lindex $date 1] [lindex $date 2] \
                                                                  [lindex $date 3] [lindex $date  4] [lindex $date  5] ]

         #--- Cree un frame pour afficher le statut de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x

           #--- Cree un label pour le titre
           label $This.frame1.titre -font $audace(font,arial_10_b) \
                 -text "$caption(statut,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour afficher les resultats
           frame $This.frame1.statut \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.statut \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.statut.l -borderwidth 0]
             pack $intitle -in $This.frame1.statut -side left

               #--- Cree un label pour le statut
               label $intitle.ok -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_ok)"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour la periode
               label $intitle.pe -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_periode)"
               pack $intitle.pe -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour la date de MAJ
               label $intitle.dm -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_maj)"
               pack $intitle.dm -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nombre d'asteroides
               label $intitle.na -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_aster)"
               pack $intitle.na -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nombre de planetes
               label $intitle.np -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_planet)"
               pack $intitle.np -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nombre de satellites naturels
               label $intitle.ns -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_satnat)"
               pack $intitle.ns -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nombre de cometes
               label $intitle.nc -font $audace(font,en_tete_2) \
                     -text "$caption(statut,label_comet)"
               pack $intitle.nc -in $intitle -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.statut.v -borderwidth 0]
             pack $inparam -in $This.frame1.statut -side right -expand 1 -fill x

               #--- Cree un label pour le statut
               label $inparam.ok -font $audace(font,arial_8_n)\
                     -text [string trim [lindex $statut 0]] -fg $color(green)
               pack $inparam.ok -in $inparam -side top -pady 1 -anchor w
               if {[string trim [lindex $statut 0]] != "ok"} { $inparam.ok configure -fg $color(red) }
               #--- Cree un label pour la periode
               label $inparam.pe -font $audace(font,arial_8_n) \
                     -text [string trim [concat $date_debut - $date_fin]] -fg $color(blue)
               pack $inparam.pe -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour la date de MAJ
               label $inparam.dm -font $audace(font,arial_8_n) \
                     -text [string trim [lindex $statut 7]] -fg $color(blue)
               pack $inparam.dm -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nombre d'asteroides
               label $inparam.na -font $audace(font,arial_8_n) \
                     -text [string trim [lindex $statut 3]] -fg $color(blue)
               pack $inparam.na -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nombre de planetes
               label $inparam.np -font $audace(font,arial_8_n) \
                     -text [string trim [lindex $statut 4]] -fg $color(blue)
               pack $inparam.np -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nombre de satellites naturels
               label $inparam.ns -font $audace(font,arial_8_n) \
                     -text [string trim [lindex $statut 5]] -fg $color(blue)
               pack $inparam.ns -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nombre de cometes
               label $inparam.nc -font $audace(font,arial_8_n) \
                     -text [string trim [lindex $statut 6]] -fg $color(blue)
               pack $inparam.nc -in $inparam -side top -pady 1 -anchor w

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
              -command { ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] \
                 [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ] }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      } else {

         set msgError $caption(statut,msg_internet)
         if {$statut == "error"} {
            set msgError $caption(statut,msg_skybot)
         }
         tk_messageBox -title $caption(statut,msg_erreur) -type ok -message $msgError
         $audace(base).tool.vo_tools.fra5.but1 configure -relief raised -state normal
         return

      }

      #--- Gestion du bouton
      $audace(base).tool.vo_tools.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

