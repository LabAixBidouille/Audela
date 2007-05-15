#
# Fichier : animate.tcl
# Description : Outil pour le controle des animations d'images
# Auteur : Alain KLOTZ
# Mise a jour $Id: animate.tcl,v 1.8 2007-05-15 21:51:10 robertdelmas Exp $
#

#============================================================
# Declaration du namespace anim
#    initialise le namespace
#============================================================
namespace eval ::anim {
   package provide animate 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] animate.cap ]
}

#------------------------------------------------------------
# ::anim::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::anim::getPluginTitle { } {
   global caption

   return "$caption(animate,animation)"
}

#------------------------------------------------------------
# ::anim::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::anim::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::anim::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::anim::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "utility" }
      subfunction1 { return "animate" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::anim::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::anim::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::anim::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::anim::createPluginInstance { { in "" } { visuNo 1 } } {
   ::anim::createPanel $in.anim
}

#------------------------------------------------------------
# ::anim::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::anim::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::anim::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::anim::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(anim,titre)           "$caption(animate,animation)"
   set panneau(anim,aide)            "$caption(animate,help_titre)"
   set panneau(anim,parcourir)       "$caption(animate,parcourir)"
   set panneau(anim,genericfilename) "$caption(animate,nom_generique)"
   set panneau(anim,nbimages)        "$caption(animate,nb_images)"
   set panneau(anim,delayms)         "$caption(animate,delai_ms)"
   set panneau(anim,nbloops)         "$caption(animate,nb_boucles)"
   set panneau(anim,go)              "$caption(animate,go_animation)"
   #--- Initialisation de variables
   if { [info exists panneau(anim,filename)] == "0" } { set panneau(anim,filename) "" }
   if { [info exists panneau(anim,nbi)] == "0" }      { set panneau(anim,nbi)      "3" }
   if { [info exists panneau(anim,ms)] == "0" }       { set panneau(anim,ms)       "300" }
   if { [info exists panneau(anim,nbl)] == "0" }      { set panneau(anim,nbl)      "5" }
   #--- Construction de l'interface
   ::anim::animBuildIF $This
}

#------------------------------------------------------------
# ::anim::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::anim::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::anim::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::anim::stopTool { visuNo } {
   variable This
   global audace

   pack forget $This
   if { [ winfo exists $audace(base).erreurfichier ] } {
      destroy $audace(base).erreurfichier
   }
}

#------------------------------------------------------------
# ::anim::cmdGo
#    lance l'animation
#------------------------------------------------------------
proc ::anim::cmdGo { } {
   variable This
   global audace panneau

   #--- Destruction de la fenetre d'erreur si elle existe
   if { [ winfo exists $audace(base).erreurfichier ] } {
      destroy $audace(base).erreurfichier
   }
   #--- Nettoyage de la visualisation
   visu$audace(visuNo) clear
   #--- Lancement de l'animation
   if { $panneau(anim,filename) != "" } {
      #--- Gestion du bouton Go Animation
      $This.fra6.but1 configure -relief groove -state disabled
      #--- Animation avec gestion des erreurs (absence d'images, images dans un autre repertoire, etc.)
      #--- supportee par la variable error retournee par la procedure animate du script aud1.tcl
      set error [ animate $panneau(anim,filename) $panneau(anim,nbi) $panneau(anim,ms) $panneau(anim,nbl) ]
      if { $error == "1" } {
         ::anim::erreurFichier
         }
      #--- Gestion du bouton Go Animation
      $This.fra6.but1 configure -relief raised -state normal
   }
}

#------------------------------------------------------------
# ::anim::erreurFichier
#    affiche un message d'erreur
#------------------------------------------------------------
proc ::anim::erreurFichier { } {
   global audace caption

   if { [ winfo exists $audace(base).erreurfichier ] } {
      destroy $audace(base).erreurfichier
   }
   toplevel $audace(base).erreurfichier
   wm transient $audace(base).erreurfichier $audace(base)
   wm title $audace(base).erreurfichier "$caption(animate,attention)"
   set posx_erreurfichier [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
   set posy_erreurfichier [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
   wm geometry $audace(base).erreurfichier +[ expr $posx_erreurfichier + 140 ]+[ expr $posy_erreurfichier + 75 ]
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

#------------------------------------------------------------
# ::anim::editNomGenerique
#    edite le nom generique du fichier
#------------------------------------------------------------
proc ::anim::editNomGenerique { } {
   global audace panneau

   #--- Fenetre parent
   set fenetre "$audace(base)"
   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
   #--- Extraction du nom generique
   set filenameAnimation      [ ::pretraitement::nom_generique [ file tail $filename ] ]
   set panneau(anim,filename) [ lindex $filenameAnimation 0 ]
   set panneau(anim,nbi)      [ lindex $filenameAnimation 1 ]
}

#------------------------------------------------------------
# ::anim::animBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::anim::animBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(anim,titre) \
            -command "::audace::showHelpPlugin tool animate animate.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(anim,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du nom generique
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour le nom generique
         label $This.fra2.lab1 -text $panneau(anim,genericfilename) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Entry pour le nom generique
         entry $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(anim,filename) \
            -width 14 -relief groove
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 1 -side left

         #--- Bouton parcourir
         button $This.fra2.but1 -borderwidth 2 -text $panneau(anim,parcourir) \
            -command { ::anim::editNomGenerique }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side left

      pack $This.fra2 -side top -fill x

      #--- Frame pour le nombre d'images
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour le nombre d'images
         label $This.fra3.lab1 -text $panneau(anim,nbimages) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

         #--- Entry pour le nombre d'images
         entry $This.fra3.ent1 -font $audace(font,arial_8_b) -textvariable panneau(anim,nbi) -relief groove \
            -width 4 -justify center
         pack $This.fra3.ent1 -in $This.fra3 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

      pack $This.fra3 -side top -fill x

      #--- Frame pour le delai
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Label pour le delai
         label $This.fra4.lab1 -text $panneau(anim,delayms) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

         #--- Entry pour le delai
         entry $This.fra4.ent1 -font $audace(font,arial_8_b) -textvariable panneau(anim,ms) -relief groove \
            -width 5 -justify center
         pack $This.fra4.ent1 -in $This.fra4 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

      pack $This.fra4 -side top -fill x

      #--- Frame pour le nb de boucles
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour le nb de boucles
         label $This.fra5.lab1 -text $panneau(anim,nbloops) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

         #--- Entry pour le nb de boucles
         entry $This.fra5.ent1 -font $audace(font,arial_8_b) -textvariable panneau(anim,nbl) -relief groove \
            -width 4 -justify center
         pack $This.fra5.ent1 -in $This.fra5 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

      pack $This.fra5 -side top -fill x

      #--- Lancement de l'animation
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Bouton GO Animation
         button $This.fra6.but1 -borderwidth 2 -text $panneau(anim,go) \
            -command { ::anim::cmdGo }
         pack $This.fra6.but1 -in $This.fra6 -anchor center -fill x -padx 5 -pady 5 -ipadx 5 -ipady 8

      pack $This.fra6 -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

