## @file bddimages_go.tcl
#  @brief     Demarrage du plugin bddimages
#  @details   This class is used to demonstrate a number of section commands.
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_go.tcl]
#  @endcode
#  @todo      Normaliser l'ensemble des noms des fichiers sources 

# Mise à jour $Id$

#============================================================
## Declaration du namespace \c bddimages .
#  @brief     Creation et initialisation du plugin bddimages.
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Pour developpeur seulement
#
namespace eval ::bddimages {

   package provide bddimages 1.0

   global audace
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] bddimages_go.cap ]

}

#------------------------------------------------------------
## Retourne le titre du plugin dans la langue de l'utilisateur
#  @return  Titre du plugin
#  @sa      getPluginType
#
proc ::bddimages::getPluginTitle { } {
   global caption

   return "$caption(bddimages_go,titre)"
}

#------------------------------------------------------------
## Retourne le type de plugin
#  @return type de plugin
#
proc ::bddimages::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
## Recupere la valeur d'une propriete du plugin
#  @param propertyName Nom de la propriete
#  @return valeur de la propriete ou "" si la propriete n'existe pas
#
proc ::bddimages::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
## Initialisation du plugin
#  @param tkbase 
#  @return void
#
proc ::bddimages::initPlugin { tkbase } {

   global audace
   global conf
   global bddconf

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_config.tcl ]\""

   set bddconf(current_db) "?"

   set bddconf(font,courier_8)  "Courier  8 normal"
   set bddconf(font,courier_10) "Courier 10 normal"
   set bddconf(font,arial_10)   "{Arial} 10 normal"
   set bddconf(font,arial_10_b) "{Arial} 10 bold"
   set bddconf(font,arial_12)   "{Arial} 12 normal"
   set bddconf(font,arial_12_b) "{Arial} 12 bold"
   set bddconf(font,arial_14_b) "{Arial} 14 bold"

   set bddconf(bufno)    $audace(bufNo)
   set bddconf(visuno)   $audace(visuNo)
   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
   set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]

   set bddconf(extension_bdd) ".fits.gz"
   set bddconf(extension_tmp) ".fit"

}

#------------------------------------------------------------
## Creation d'une instance du plugin
# @param in string pathName du widget dans le quel s'insert le plugin
# @param visuNo int Numero de la Visu
# @return void
#
proc ::bddimages::createPluginInstance { { in "" } { visuNo 1 } } {

   global audace

   #--- Chargement des packages 
   package require tablelist
   package require math::statistics

   #--- Chargement des procedures
   ::bddimages::ressource

   #--- Mise en place de l'interface graphique
   ::bddimages::createPanel $in.bddimages

}

#------------------------------------------------------------
## Re-source l'ensemble des sources Tcl du plugin
# @return void
#
proc ::bddimages::ressource {  } {

   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool bddimages bddimages_go.cap ]

   #--- Chargement des fichiers externes
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""

   #--- Chargement des fichiers tools
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_calendar.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_image.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_jpl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_mpc.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_priam.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_sources.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_verifcata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_psf.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_methodes_psf.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astrometry.tcl ]\""


   #--- Chargement des fichiers gui
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_creation.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_set_ref_science.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_verifcata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_gestion_source.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_psf.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_astrometry.tcl ]\""


# TODO

   # Nouvelle facon de nommage des routines (separation gui et ligne de commande)
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_cata_gestion_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_binast_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_binast_ihm.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_binast_tools.tcl ]\""


   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]\""


   # Anciennes facon de nommage des routines

   
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sql.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_header.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin_image.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages gui_cdl_withwcs.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages tools_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages test.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.cap ]\""


   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages utils astroid libastroid.tcl ]\""
   load libcatalog[info sharedlibextension]

   ::Samp::destroy

}

#------------------------------------------------------------
## Detruit d'instance du plugin
# @param visuNo Numero de la Visu
# @return void
#
proc ::bddimages::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
## Initialisation de la creation du panneau bddimages
# @param this string pathName racine du panneau
# @return void
#
proc ::bddimages::createPanel { this } {

   variable This
   global caption panneau bddconf

   #--- Initialisation du nom de la fenetre
   set This $this

   #--- Chargement des noms des config disponibles de bddimages
   ::bdi_tools_config::load_config_names

   #--- Construction de l'interface
   ::bddimages::bddimagesBuildIF $This

}

#------------------------------------------------------------
## Affichage du panneau de bddimages
# @param visuNo int Numero de la Visu
# @return void
#
proc ::bddimages::startTool { visuNo } {

   variable This
   pack $This -side left -fill y

}

#------------------------------------------------------------
## Masquage du panneau de bddimages
# @param visuNo int Numero de la Visu
# @return void
#
proc ::bddimages::stopTool { visuNo } {

   variable This
   pack forget $This

}

#------------------------------------------------------------
## Configuration des boutons et autres widgets du panneau
# @return void
#
proc ::bddimages::handleBddState { } {

   variable This
   global audace bddconf

   set visuNo $::audace(visuNo)

   if {$::bdi_tools_xml::is_config_loaded && $::bdi_tools_config::ok_mysql_connect} {
      set colorBtn "#00CC00"
      #--- Active les boutons
      $This.fra3.but1 configure -state active
      $This.fra4.but1 configure -state active
      $This.fra5.but1 configure -state active
   } else {
      set colorBtn "#DD0000"
      #--- De-Active les boutons
      $This.fra3.but1 configure -state disabled
      $This.fra4.but1 configure -state disabled
      $This.fra5.but1 configure -state disabled
   }

   # Configure menubutton du choix des bdd
   $This.fra1.but configure -bg $colorBtn

}

#------------------------------------------------------------
## Chargement de la config selectionnee a partir du menu-bouton config.
# @return void
#
proc ::bddimages::load_config_frombutton { } {

   variable This
   global audace bddconf

   if {[string compare $bddconf(current_config)  "?"] == 0} {
      ::bdi_gui_config::configuration $audace(base).bdi_gui_config
   } else {
      ::bdi_tools_config::load_config $bddconf(current_config)
      ::bddimages::handleBddState
   }

   #--- Initialisation des parametres des cata
   ::gui_cata_creation::inittoconf
   ::bdi_gui_astrometry::inittoconf

}

#------------------------------------------------------------
## Creation du panneau de bddimages
# @param This string pathName de la racine du panneau
# @return void
#
proc ::bddimages::bddimagesBuildIF { This } {

   global audace caption bddconf

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove
      pack $This.fra0 -side top -fill x

         #--- Bouton du titre
         button $This.fra0.but -borderwidth 1 \
            -text "$caption(bddimages_go,help_titre1)\n$caption(bddimages_go,bddimages)" \
            -command "::audace::showHelpPlugin tool bddimages bddimages.htm"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $caption(bddimages_go,help_titre)

      #--- Frame des services
      frame $This.fra1 -borderwidth 1 -relief groove
      pack $This.fra1 -side top -fill x

         button $This.fra1.but -relief raised -borderwidth 2 \
            -textvariable bddconf(current_config) \
            -command "::bddimages::load_config_frombutton"
         pack $This.fra1.but -in $This.fra1 -side top -padx 3 -pady 10 -ipadx 5 -ipady 2

      #--- Frame des services
      frame $This.fra2 -borderwidth 1 -relief groove
      pack $This.fra2 -side top -fill x

         #--- Bouton d'ouverture de la config
         button $This.fra2.but1 -borderwidth 2 -text $caption(bddimages_go,configuration) \
            -command "::bdi_gui_config::configuration $audace(base).bdi_gui_config"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.fra3 -borderwidth 1 -relief groove
      pack $This.fra3 -side top -fill x

         #--- Bouton d'ouverture de l'outil de statut
         button $This.fra3.but1 -borderwidth 2 -text $caption(bddimages_go,status) \
            -command "::bdi_gui_status::run $audace(base).status"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.fra4 -borderwidth 1 -relief groove
      pack $This.fra4 -side top -fill x

         #--- Bouton d'ouverture de l'outil d'insertion des images
         button $This.fra4.but1 -borderwidth 2 -text $caption(bddimages_go,insertion) \
            -command "::bddimages_insertion::run $audace(base).bddimages_insertion"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.fra5 -borderwidth 1 -relief groove
      pack $This.fra5 -side top -fill x

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.fra5.but1 -borderwidth 2 -text $caption(bddimages_go,recherche) \
            -command "::bddimages_recherche::run $audace(base).bddimages_recherche"
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     #--- Frame des services
     frame $This.fra6 -borderwidth 1 -relief groove
     pack $This.fra6 -side top -fill x

        #--- Bouton d'ouverture de l'outil de recherche d images
        button $This.fra6.but1 -borderwidth 2 -text $caption(bddimages_go,test) \
           -command "::testprocedure::run" -state disabled
        pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove
      pack $This.ressource -side top -fill x

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.ressource.but1 -borderwidth 2 -text $caption(bddimages_go,ressource) \
            -command {::bddimages::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
      #--- Coloration du menubouton du choix de la bdd
      $This.fra1.but configure -bg "#DD0000"
      #--- Desactive les boutons, qui seront actives apres chargement de la config
      $This.fra3.but1 configure -state disabled
      $This.fra4.but1 configure -state disabled
      $This.fra5.but1 configure -state disabled

}


#------------------------------------------------------------
## Impression d'un message d'info dans la console
# @return void
#
proc gren_info { msg } {
   ::console::affiche_resultat "$msg" 
}


#------------------------------------------------------------
## Impression d'un message d'erreur dans la console
# @return void
#
proc gren_erreur { msg } {
   ::console::affiche_erreur "$msg" 
}
