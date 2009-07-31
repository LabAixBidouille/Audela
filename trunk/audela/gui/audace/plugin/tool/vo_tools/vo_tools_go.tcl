#
# Fichier : vo_tools_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Robert DELMAS
# Mise a jour $Id: vo_tools_go.tcl,v 1.18 2009-07-31 08:02:41 svaillant Exp $
#

#============================================================
# Declaration du namespace vo_tools
#    initialise le namespace
#============================================================
namespace eval ::vo_tools {
   package provide vo_tools 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] vo_tools_go.cap ]
}

#------------------------------------------------------------
# ::vo_tools::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::vo_tools::getPluginTitle { } {
   global caption

   return "$caption(vo_tools_go,titre)"
}

#------------------------------------------------------------
# ::vo_tools::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::vo_tools::getPluginHelp { } {
   return "vo_tools.htm"
}

#------------------------------------------------------------
# ::vo_tools::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::vo_tools::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::vo_tools::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::vo_tools::getPluginDirectory { } {
   return "vo_tools"
}

#------------------------------------------------------------
# ::vo_tools::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::vo_tools::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::vo_tools::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::vo_tools::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "analysis" }
      function     { return "analysis" }
      subfunction1 { return "solar system" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::vo_tools::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::vo_tools::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::vo_tools::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::vo_tools::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require Tablelist
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_resolver.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_search.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_statut.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools vo_samp.tcl ]\""
   #--- Mise en place de l'interface graphique
   ::vo_tools::createPanel $in.vo_tools
}

#------------------------------------------------------------
# ::vo_tools::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::vo_tools::deletePluginInstance { visuNo } {
 ::Samp::destroy
}

#------------------------------------------------------------
# ::vo_tools::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(vo_tools,titre)  "$caption(vo_tools_go,vo_tools)"
   set panneau(vo_tools,aide)   "$caption(vo_tools_go,help_titre)"
   set panneau(vo_tools,aide1)  "$caption(vo_tools_go,help_titre1)"
   set panneau(vo_tools,titre1) "$caption(vo_tools_go,aladin)"
   set panneau(vo_tools,titre2) "$caption(vo_tools_go,cone-search)"
   set panneau(vo_tools,titre3) "$caption(vo_tools_go,resolver)"
   set panneau(vo_tools,titre4) "$caption(vo_tools_go,statut)"
   #--- Construction de l'interface
   ::vo_tools::vo_toolsBuildIF $This
}

#------------------------------------------------------------
# ::vo_tools::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::vo_tools::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::vo_tools::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::vo_tools::vo_toolsBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove
      set packoptions "-anchor center -expand 1 -fill both -side top -ipadx 5"

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(vo_tools,aide1)\n$panneau(vo_tools,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] \
               [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(vo_tools,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame CDS Aladin Multiview
      set frame $This.fra2
      frame $frame -borderwidth 2 -relief groove

         #--- Bouton d'ouverture de l'outil CDS Aladin Multiview
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre1) -state disabled \
            -command ""
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame des services SkyBoT
      set frame $This.fra3
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d'objets du Systeme Solaire dans le champ
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre2) \
            -command "::skybot_Search::run $audace(base).skybot_Search"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame du mode de calcul des ephemerides d'objets du Systeme Solaire
      set frame $This.fra4
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de calcul des ephemerides d'objets du Systeme Solaire
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre3) \
            -command "::skybot_Resolver::run $audace(base).skybot_Resolver"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame du mode de verification du statut de la base SkyBoT
      set frame $This.fra5
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de verification du statut de la base SkyBoT
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre4) \
            -command {
               #--- Gestion du bouton
               $::vo_tools::This.fra5.but1 configure -relief groove -state disabled
               #--- Lancement de la commande
               ::skybot_Statut::run "$audace(base).skybot_Statut"
            }
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame boutton Interop
      set frame $This.fra7
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton
         button $frame.but1 -borderwidth 1 -text "Interop Menu" \
            -command "::vo_tools::cmdInteropInstallMenu  $frame"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

proc ::vo_tools::cmdSampBroadcastImage {} {
 global audace
 if { [::Samp::check] == 1 } {
  set path [::confVisu::getFileName $audace(visuNo)]
  set url "file://localhost/$path"
  ::console::disp "#vo_tools::samp broadcasting image $path\n"
  set msg [::samp::m_imageLoadFits $::samp::key [list samp.mtype image.load.fits samp.params [list name $url "image-id" $url url $url] ]]
 } else {
  ::console::disp "#vo_tools::samp hub not found\n"
 }
}

proc ::vo_tools::cmdSampConnect {} {
 if { [::Samp::check] == 1 } {
  ::console::disp "#vo_tools::samp connected\n"
 } else {
  ::console::disp "#vo_tools::samp hub not found\n"
 }
}

proc ::vo_tools::cmdSampDisconnect {} {
 ::Samp::destroy
}


proc ::vo_tools::cmdInteropInstallMenu { frame } {
   #--- Ajout du menu SAMP au menu principal de l'application
   #--- Le nom est le meme que celui d'Aladin
   global caption
   set visuNo $::audace(visuNo)

   Menu  $visuNo Interop
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_help) ::vo_tools::cmdInteropHelp
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcast) ::vo_tools::cmdSampBroadcastImage
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_connect) ::vo_tools::cmdSampConnect
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_disconnect) ::vo_tools::cmdSampDisconnect
   ::confColor::applyColor [MenuGet $visuNo "Interop"]

   destroy $frame

  ::Samp::check
}

proc ::vo_tools::cmdInteropHelp { } {
 ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ] "field_7"
}

