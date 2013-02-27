#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_go.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_go.tcl
# Description    : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::bddimages {
   package provide bddimages 1.0
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
      function     { return "file" }
      subfunction1 { return "display" }
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

   set bddconf(font,courier_10) "Courier 10 normal"
   set bddconf(font,arial_10)   "{Arial} 10 normal"
   set bddconf(font,arial_10_b) "{Arial} 10 bold"
   set bddconf(font,arial_12)   "{Arial} 12 normal"
   set bddconf(font,arial_12_b) "{Arial} 12 bold"
   set bddconf(font,arial_14_b) "{Arial} 14 bold"

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.tcl ]\""

   foreach param $::bddimages_config::allparams {
     if {[info exists conf(bddimages,$param)]} then { set bddconf($param) $conf(bddimages,$param) }
   }

   set bddconf(bufno)    $audace(bufNo)
   set bddconf(visuno)   $audace(visuNo)
   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
   set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]

   set bddconf(extension_bdd) ".fits.gz"
   set bddconf(extension_tmp) ".fit"
   
   if {[info exists bddconf(dirfits)]} {
      #gren_info "audace(rep_images) = bddconf(dirfits) = $bddconf(dirfits)\n"
      set  audace(rep_images)  $bddconf(dirfits)
   }
   if {[info exists bddconf(dirtmp)]} {
      #gren_info "audace(rep_travail) = bddconf(dirtmp) = $bddconf(dirtmp)\n"
      set  audace(rep_travail)  $bddconf(dirtmp)
   }

}

#------------------------------------------------------------
# ::bddimages::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
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
# ::bddimages::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::bddimages::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool bddimages bddimages_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdicalendar.tcl ]\""

   # Nouvelle facon de nommage des routines (separation gui et ligne de commande)

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_psf_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_psf_tools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_cata_gestion_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_cata_creation_gui.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_psf_popup.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_binast_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_binast_ihm.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_binast_tools.tcl ]\""


   # Anciennes facon de nommage des routines

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages gui_astrometry.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages tools_astrometry.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_status.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_sources.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_image.tcl ]\""

   # Ancienne facon de nomage des routines
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sql.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_header.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_xml.tcl ]\""
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

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.cap ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages utils astroid libastroid.tcl ]\""
   load libcatalog[info sharedlibextension]
   #gren_info "ressources\n"
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
   set panneau(bddimages,aide1)  "$caption(bddimages_go,help_titre1)"
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

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(bddimages,aide1)\n$panneau(bddimages,titre)" \
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
            -command "::bdi_gui_status::run $audace(base).status"
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
           -command "::testprocedure::run" -state disabled
        pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     pack $This.fra6 -side top -fill x


#     #---
#     frame $This.fra7 -borderwidth 1 -relief groove
#
#        #--- Bouton d'ouverture de l'outil
#        button $This.fra7.but1 -borderwidth 2 -text "IDENT" \
#           -command "::bddimages_identification::run $audace(base).bddimages_identification"
#        pack $This.fra7.but1 -in $This.fra7 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3
#
#     pack $This.fra7 -side top -fill x
#

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.ressource.but1 -borderwidth 2 -text $panneau(bddimages,titre6) \
            -command {::bddimages::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.ressource -side top -fill x

      #--- Bouton Interop
      frame $This.interop -borderwidth 1 -relief groove
      pack $This.interop -side top -fill x
         button $This.interop.but1 -borderwidth 2 -text "Interop" -command "::bddimages::InstallMenuInterop $This.interop"
         pack $This.interop.but1 -in $This.interop -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#------------------------------------------------------------
# ::bddimages::InstallMenuInterop
#    Installe le menu Interop dans la barre de menu d'Audace
#------------------------------------------------------------
proc ::bddimages::InstallMenuInterop { frame } {
   global audace caption menu
   set visuNo $::audace(visuNo)
   # Deploiement du menu Interop
   Menu $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_connect) ::vo_tools::SampConnect
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_disconnect) ::vo_tools::SampDisconnect
   Menu_Separator $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_loadvotable) ::vo_tools::LoadVotable
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_cleardisplay) ::vo_tools::ClearDisplay
   Menu_Separator $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastImg) ::vo_tools::SampBroadcastImage
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastSpe) ::vo_tools::SampBroadcastSpectrum
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastTab) ::vo_tools::SampBroadcastTable
   Menu_Separator $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_help) ::vo_tools::helpInterop
   #--- Mise a jour dynamique des couleurs et fontes
   ::confColor::applyColor [MenuGet $visuNo "Interop"]
   # Destruction du bouton Interop du panneau VO
   destroy $frame
   # Tentative de connexion au hub Samp
   ::vo_tools::SampConnect
   # Ajoute un binding sur le canvas pour broadcaster les coordonnees cliquees
   bind $::audace(hCanvas) <ButtonPress-1> {::SampTools::broadcastPointAtSky %W %x %y}
   # Active la mise a jour automatique de l'affichage quand on change d'image
   ::confVisu::addFileNameListener $visuNo "::vo_tools::handleBroadcastBtnState"
   ::confVisu::addFileNameListener $visuNo "::vo_tools::ClearDisplay"
}

#------------------------------------------------------------
# ::bddimages::gunzip
#    Fonction gunzip compatible multi OS
#    fname_in  = nom complet du fichier a degziper /data/fi.fits.gz
#    fname_out = nom complet du fichier de sortie /data/fi.fits
#------------------------------------------------------------
proc ::bddimages::gunzip { fname_in {fname_out ""} } {
   #::console::affiche_resultat "::bddimages::gunzip <$fname_in> <$fname_out>\n"
   set ext [file extension $fname_in]
   if {$ext!=".gz"} {
      set fname_in ${fname_in}.gz
   }
   set ext [file extension $fname_out]
   if {$ext==".gz"} {
      set fname_out [file rootname $fname_out]
   }
   if {$fname_out==""} {
      set fname_out [file rootname $fname_in]
   }
   file delete -force -- $fname_out
   if { $::tcl_platform(os) == "Linux" } {
      set errnum [catch {
         exec gunzip -c $fname_in > $fname_out
      } msgzip ]
   } else {
      set errnum [catch {
         if {$fname_in!="${fname_out}.gz"} {
            file copy -force -- "$fname_in" "${fname_out}.gz"
            ::gunzip ${fname_out}.gz
         } else {
            ::gunzip "$fname_in"
         }
      } msgzip ]
   }
   return [list $errnum $msgzip]
}

#------------------------------------------------------------
# ::bddimages::gzip
#    Fonction gzip compatible multi OS
#    fname_in  = nom complet du fichier a gziper /data/fi.fits
#    fname_out = nom complet du fichier de sortie /data/fi.fits.gz
#------------------------------------------------------------
proc ::bddimages::gzip { fname_in {fname_out ""} } {
   #::console::affiche_resultat "::bddimages::gzip <$fname_in> <$fname_out>\n"
   set ext [file extension $fname_in]
   if {$ext == ".gz"} {
      set fname_in [file rootname $fname_in]
   }
   set ext [file extension $fname_out]
   if {$ext != ".gz"} {
      set fname_out ${fname_out}.gz
   }
   # Force l'effacement du fichier out
   if {$fname_out == ""} {
      set fname_out0 ${fname_in}.gz
   } else {
      set fname_out0 $fname_out
   }
   file delete -force -- $fname_out0
   # Zip le fichier
   if { $::tcl_platform(os) == "Linux" } {
      set errnum [catch {
         exec gzip -c $fname_in > $fname_out
      } msgzip ]
   } else {
      set errnum [catch {
         if {$fname_out!="${fname_in}.gz"} {
            file copy -force -- "$fname_in" "[file rootname $fname_out]"
         }
         ::gzip "[file rootname $fname_out]"
      } msgzip ]
   }
   return [list $errnum $msgzip]
}

proc gren_info { msg } {
   ::console::affiche_resultat "$msg" 
}
