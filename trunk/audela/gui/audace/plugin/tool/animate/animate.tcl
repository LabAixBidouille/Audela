#
# Fichier : animate.tcl
# Description : Outil pour le controle des animations
# Auteur : Alain KLOTZ
# Date de mise a jour : 13 janvier 2006
#

package provide animate 1.0

namespace eval ::Anim {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool animate animate.cap ]

   proc init { { in "" } } {
      createPanel $in.anim
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(menu_name,Anim)       "$caption(animate,animation)"
      set panneau(Anim,aide)            "$caption(animate,help_titre)"
      set panneau(Anim,genericfilename) "$caption(animate,nom_generique)"
      set panneau(Anim,nbimages)        "$caption(animate,nb_images)"
      set panneau(Anim,delayms)         "$caption(animate,delai_ms)"
      set panneau(Anim,nbloops)         "$caption(animate,nb_boucles)"
      set panneau(Anim,go)              "$caption(animate,go_animation)"
      AnimBuildIF $This
   }

   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
   }

   proc stopTool { visuNo } {
      variable This
      global audace

      pack forget $This
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
   }

   proc cmdGo { } {
      variable This
      global panneau audace

      #--- Nettoyage de la visualisation 
      visu$audace(visuNo) clear

      if { $panneau(Anim,encours) == "0" } {
         set panneau(Anim,encours) "1"
         grab $This.fra6.but1
         $This.fra6.but1 configure -relief groove
         update 
         #--- Gestion des erreurs, absence d'images ou dans un autre repertoire
         set num [ catch { animate $panneau(Anim,filename) $panneau(Anim,nbi) $panneau(Anim,ms) $panneau(Anim,nbl) } msg ]
         if { $num == "1" } {
            ::Anim::ErreurFichier
         } 
         #---
         grab release $This.fra6.but1
         $This.fra6.but1 configure -relief raised
         update 
         set panneau(Anim,encours) "0"
      }
   }

   proc ErreurFichier { } {
      global audace
      global caption

      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      toplevel $audace(base).erreurfichier
      wm transient $audace(base).erreurfichier $audace(base)
      wm title $audace(base).erreurfichier "$caption(animate,attention)"
      set posx_erreurfichier [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_erreurfichier [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).erreurfichier +[ expr $posx_erreurfichier + 120 ]+[ expr $posy_erreurfichier + 102 ]
      wm resizable $audace(base).erreurfichier 0 0

      #--- Cree l'affichage du message d'erreur
      label $audace(base).erreurfichier.lab1 -text "$caption(animate,erreur_fichier1)"
      pack $audace(base).erreurfichier.lab1 -padx 10 -pady 2
      label $audace(base).erreurfichier.lab2 -text "$caption(animate,erreur_fichier2)"
      pack $audace(base).erreurfichier.lab2 -padx 10 -pady 2
      label $audace(base).erreurfichier.lab3 -text "$caption(animate,erreur_fichier3)"
      pack $audace(base).erreurfichier.lab3 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).erreurfichier

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).erreurfichier
   }

   proc edit_nom_image { } {
      global audace
      global panneau

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom generique
      set panneau(Anim,filename) [ lindex [ decomp $filename ] 1 ]
   }

   proc Nom_gene { } {
      global audace
      global caption

      if { [ winfo exists $audace(base).nom_gene ] } {
         destroy $audace(base).nom_gene
      }
      toplevel $audace(base).nom_gene
      wm transient $audace(base).nom_gene $audace(base)
      wm title $audace(base).nom_gene "$caption(animate,attention)"
      set posx_nom_gene [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_nom_gene [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).nom_gene +[ expr $posx_nom_gene + 120 ]+[ expr $posy_nom_gene + 102 ]
      wm resizable $audace(base).nom_gene 0 0

      #--- Cree l'affichage du message
      label $audace(base).nom_gene.lab1 -text "$caption(animate,message1)"
      pack $audace(base).nom_gene.lab1 -padx 10 -pady 2
      label $audace(base).nom_gene.lab2 -text "$caption(animate,message2)"
      pack $audace(base).nom_gene.lab2 -padx 10 -pady 2
      label $audace(base).nom_gene.lab3 -text "$caption(animate,message3)"
      pack $audace(base).nom_gene.lab3 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).nom_gene

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).nom_gene
   }

}

proc AnimBuildIF { This } {
   global audace
   global panneau

   set panneau(Anim,encours) "0"
   if { [info exists panneau(Anim,filename)] == "0" } { set panneau(Anim,filename) "" }
   if { [info exists panneau(Anim,nbi)] == "0" }      { set panneau(Anim,nbi)      "3" }
   if { [info exists panneau(Anim,ms)] == "0" }       { set panneau(Anim,ms)       "300" }
   if { [info exists panneau(Anim,nbl)] == "0" }      { set panneau(Anim,nbl)      "5" }

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Anim) \
            -command {
               ::audace::showHelpPlugin tool animate animate.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Anim,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du nom generique
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour le nom generique
         label $This.fra2.lab1 -text $panneau(Anim,genericfilename) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Entry pour le nom generique
         entry $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Anim,filename) \
            -width 14 -relief groove
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 1
         bind $This.fra2.ent1 <Enter> { ::Anim::Nom_gene }
         bind $This.fra2.ent1 <Leave> { destroy $audace(base).nom_gene }

      pack $This.fra2 -side top -fill x

      #--- Frame pour le nombre d'images
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour le nombre d'images
         label $This.fra3.lab1 -text $panneau(Anim,nbimages) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand true -fill none -side left

         #--- Entry pour le nombre d'images
         entry $This.fra3.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Anim,nbi) -relief groove \
            -width 4 -justify center
         pack $This.fra3.ent1 -in $This.fra3 -anchor center -expand true -fill none -side left
   
      pack $This.fra3 -side top -fill x

      #--- Frame pour le delai
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Label pour le delai
         label $This.fra4.lab1 -text $panneau(Anim,delayms) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -expand true -fill none -side left

         #--- Entry pour le delai
         entry $This.fra4.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Anim,ms) -relief groove \
            -width 5 -justify center
         pack $This.fra4.ent1 -in $This.fra4 -anchor center -expand true -fill none -side left
   
      pack $This.fra4 -side top -fill x

      #--- Frame pour le nb de boucles
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour le nb de boucles
         label $This.fra5.lab1 -text $panneau(Anim,nbloops) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -expand true -fill none -side left

         #--- Entry pour le nb de boucles
         entry $This.fra5.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Anim,nbl) -relief groove \
            -width 4 -justify center
         pack $This.fra5.ent1 -in $This.fra5 -anchor center -expand true -fill none -side left
   
      pack $This.fra5 -side top -fill x

      #--- Lancement de l'animation
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Bouton GO Anim
         button $This.fra6.but1 -borderwidth 2 -text $panneau(Anim,go) \
            -command { ::Anim::cmdGo }
         pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -padx 2 -pady 5 -ipadx 5 -ipady 8

      pack $This.fra6 -side top -fill x

   #--- Binding pour afficher le nom generique des images
   bind $This.fra2.ent1 <Key-Escape> { ::Anim::edit_nom_image }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

global audace

::Anim::init $audace(base)

