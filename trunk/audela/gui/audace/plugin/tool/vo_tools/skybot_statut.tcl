#
# Fichier : skybot_statut.tcl
# Description : Affiche le statut de la base de donnees SkyBoT
# Auteur : Jerome BERTHIER
# Mise a jour $Id: skybot_statut.tcl,v 1.17 2009-07-11 08:05:12 robertdelmas Exp $
#

namespace eval skybot_Statut {
   global audace

   #--- Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::node {} ::dom::tcl::node
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
   }

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
      global conf
      global voconf

      set voconf(geometry_statut) [ wm geometry $This ]
      set conf(vo_tools,position_statut) $voconf(geometry_statut)
   }

   #
   # skybot_Statut::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global conf
      global voconf

      #--- initConf
      if { ! [ info exists conf(vo_tools,position_statut) ] } { set conf(vo_tools,position_statut) "670x250+80+40" }

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

      #--- Interrogation de la base de donnees
      set erreur [ catch { vo_skybotstatus votable } statut ]
      set flag [lindex $statut 1]
      set ticket [lindex $statut 3]
      set xml [lindex $statut 5]
      set votable [::dom::parse $xml]

      #--- Gestion des erreurs
      if { $erreur == "0" && $statut != "failed" && $statut != "error"} {

         #---
         toplevel $This -class Toplevel
         wm geometry $This $voconf(position_statut)
         wm resizable $This 1 1
         wm title $This $caption(statut,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::skybot_Statut::fermer }

         #--- Liste des tranches
         frame $This.frame0 -borderwidth 0 -cursor arrow
         pack $This.frame0 -in $This -anchor s -side top -expand yes -fill both
         #--- Cree un acsenseur horizontal
         scrollbar $This.frame0.hsb -orient horizontal \
            -command { $::skybot_Statut::This.frame0.tbl xview } -takefocus 1 -borderwidth 1
         pack $This.frame0.hsb -in $This.frame0 -side bottom -fill x

         label $This.frame0.titre -text "$caption(statut,titre)"
         pack $This.frame0.titre -in $This.frame0 -side top -padx 3 -pady 3
         set tbl $This.frame0.tbl
         tablelist::tablelist $tbl -stretch all \
          -xscrollcommand [ list $This.frame0.hsb set ] \
          -columns [list \
          0 $caption(statut,label_ok) \
          0 begin 0 end \
          0 $caption(statut,label_aster) 0 $caption(statut,label_planet) 0 $caption(statut,label_satnat) 0 $caption(statut,label_comet) 0 $caption(statut,label_maj) ]
         pack $tbl -in $This.frame0 -side top -padx 3 -pady 3 -fill both -expand yes
         foreach tr [::dom::selectNode $votable "descendant::TR"] {
          set row {}
          foreach td [::dom::selectNode $tr "descendant::TD/text()"] {
           lappend row [::dom::node stringValue $td]
          }
          $tbl insert end $row
         }

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

