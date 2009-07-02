# source audace/plugin/tool/bddimages/bddimages_go.tcl
#
# Fichier : bddimages_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Fr�d�ric Vachier
# 


#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::bddimages {
   package provide bddimages 1.0
   package require audela 1.5.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] bddimages_go.cap ]
}

#------------------------------------------------------------
# ::bddimages::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::bddimages::getPluginTitle { } {
   global caption

   return "$caption(bddimages_go,titre)"
}

#------------------------------------------------------------
# ::bddimages::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::bddimages::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::bddimages::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::bddimages::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "tool" }
      function     { return "analysis" }
      subfunction1 { return "solar system" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::bddimages::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::bddimages::initPlugin { tkbase } {
   global audace
   global conf
   global bddconf

   set audace(font,en_tete_1) [ list {Arial} 14 bold ]
   set audace(font,en_tete_2) [ list {Arial} 12 bold ]
   set audace(font,arial_10_b) [ list {Arial} 10 bold ]
   set audace(font,arial_6_n) [ list {Arial} 10 bold ]

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.tcl    ]\""

   foreach param $::bddimages_config::allparams  {
     if {[info exists conf(bddimages,$param)]} then { set bddconf($param) $conf(bddimages,$param) }
   }

   set bddconf(bufno)   $audace(bufNo)
   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages ]

}

#------------------------------------------------------------
# ::bddimages::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::bddimages::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require tablelist

   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sql.tcl    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_status.tcl    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages test.tcl ]\""
   #--- Mise en place de l'interface graphique
   ::bddimages::createPanel $in.bddimages
}

#------------------------------------------------------------
# ::bddimages::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::bddimages::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool bddimages bddimages_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_go.tcl    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sql.tcl    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.tcl    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_status.tcl    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.cap    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_status.cap    ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
}

#------------------------------------------------------------
# ::bddimages::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::bddimages::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::bddimages::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::bddimages::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(bddimages,titre)  "$caption(bddimages_go,bddimages)"
   set panneau(bddimages,aide)   "$caption(bddimages_go,help_titre)"
   set panneau(bddimages,titre1) "$caption(bddimages_go,configuration)"
   set panneau(bddimages,titre2) "$caption(bddimages_go,status)"
   set panneau(bddimages,titre3) "$caption(bddimages_go,insertion)"
   set panneau(bddimages,titre4) "$caption(bddimages_go,recherche)"
   set panneau(bddimages,titre5) "$caption(bddimages_go,test)"
   set panneau(bddimages,titre6) "$caption(bddimages_go,ressource)"
   #--- Construction de l'interface
   ::bddimages::bddimagesBuildIF $This
    
}

#------------------------------------------------------------
# ::bddimages::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::bddimages::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::bddimages::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::bddimages::stopTool { visuNo } {
   variable This
   
   pack forget $This
}

#------------------------------------------------------------
# ::bddimages::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::bddimages::bddimagesBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(bddimages,titre) \
            -command "::audace::showHelpPlugin tool bddimages bddimages.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(bddimages,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame des services  
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de configuration
         button $This.fra2.but1 -borderwidth 2 -text $panneau(bddimages,titre1) \
            -command "::bddimages_config::run $audace(base).bddimages_config"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame des services  
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.fra3.but1 -borderwidth 2 -text $panneau(bddimages,titre2) \
            -command "::bddimages_status::run $audace(base).bddimages_status"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Frame des services  
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil d'insertion des images
         button $This.fra4.but1 -borderwidth 2 -text $panneau(bddimages,titre3) \
            -command "::bddimages_insertion::run $audace(base).bddimages_insertion"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame des services  
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.fra5.but1 -borderwidth 2 -text $panneau(bddimages,titre4) \
            -command "::bddimages_recherche::run $audace(base).bddimages_recherche"
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra5 -side top -fill x

      #--- Frame des services  
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.fra6.but1 -borderwidth 2 -text $panneau(bddimages,titre5) \
            -command "::testprocedure::run"
         pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra6 -side top -fill x

      #--- 
      frame $This.fra7 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil 
         button $This.fra7.but1 -borderwidth 2 -text "IDENT" \
            -command "::bddimages_identification::run $audace(base).bddimages_identification"
         pack $This.fra7.but1 -in $This.fra7 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra7 -side top -fill x

      #--- Frame des services  
      frame $This.ressource -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.ressource.but1 -borderwidth 2 -text $panneau(bddimages,titre6) \
            -command {::bddimages::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.ressource -side top -fill x


      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}


proc gren_info { msg } { ::console::affiche_resultat "$msg" }

