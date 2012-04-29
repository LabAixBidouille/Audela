#
# Fichier : vo_tools_go.tcl
# Description : Outil d'appel des fonctionnalites de l'observatoire virtuel
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace vo_tools
#    initialise le namespace
#============================================================
namespace eval ::vo_tools {
   package provide vo_tools 2.0

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
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""
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
   set panneau(vo_tools,titre5) "$caption(vo_tools_go,samp_menu_interop)"
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

         #--- Bouton du titre
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

      #--- Frame bouton Interop
      set frame $This.fra7
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre5) \
            -command "::vo_tools::InstallMenuInterop  $frame"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Mise a jour dynamique des couleurs et fontes
      ::confColor::applyColor $This
}

#------------------------------------------------------------
# ::vo_tools::handleBroadcastBtnState
#    Change l'etat des boutons de broadcast
# @param string args parametre transmis par le listener
#------------------------------------------------------------
proc ::vo_tools::handleBroadcastBtnState { args } {
   global audace caption menu
   set visuNo $::audace(visuNo)
   set stateImg "disabled"
   set stateTab "disabled"
   set stateSpe "disabled"

   # Determine l'etat
   if { $args ne "disabled" } {
      if {[::Samp::isConnected]} {
         # Test la presence d'une image 1D ou 2D
         if {[file exists [::confVisu::getFileName $visuNo]]} {
            set naxis [lindex [buf$::audace(bufNo) getkwd NAXIS] 1]
            if {$naxis == 1} {
               # C'est un spectre
               set stateImg "disabled"
               set stateSpe "normal"
            } else {
               # C'est une image
               set stateImg "normal"
               set stateSpe "disabled"
            }
         } else {
            set stateImg "disabled"
            set stateSpe "disabled"
         }
         # Test la presence en memoire d'une VOTable
         set err [catch {string length [::votableUtil::getVotable]} length]
         if {$err == 0 && $length > 0} {
            set stateTab "normal"
         } else {
            set stateTab "disabled"
         }
      }
   }
   # Configure le menu
   Menu_Configure $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastImg) "-state" $stateImg
   Menu_Configure $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastTab) "-state" $stateTab
   Menu_Configure $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastSpe) "-state" $stateSpe
}

#------------------------------------------------------------
# ::vo_tools::handleInteropBtnState
#    Change l'etat du menu Interop
# @param string args parametre transmis par le listener
#------------------------------------------------------------
proc ::vo_tools::handleInteropBtnState { args } {
   global audace caption menu
   set visuNo $::audace(visuNo)
   set colorBtn "#CC0000"

   # Determine l'etat
   if { $args ne "disabled" } {
      if {[::Samp::isConnected]} {
         set colorBtn "#00CC00"
      } else {
         set colorBtn "#CC0000"
      }
   }
   # Configure menu
   $menu(menubar$visuNo) entryconfigure [$menu(menubar$visuNo) index "Interop"] -foreground $colorBtn
}

#------------------------------------------------------------
# ::vo_tools::SampConnect
#    Connection au hub Samp
#------------------------------------------------------------
proc ::vo_tools::SampConnect {} {
   global caption
   if { [::Samp::check] == 1 } {
      ::console::affiche_resultat "$caption(vo_tools_go,samp_connected) \n"
      ::vo_tools::handleInteropBtnState
      ::vo_tools::handleBroadcastBtnState
   } else {
      ::console::affiche_erreur "$caption(vo_tools_go,samp_hubnotfound) \n"
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState "disabled"
   }
}

#------------------------------------------------------------
# ::vo_tools::SampDisConnect
#    Deconnection du hub Samp
#------------------------------------------------------------
proc ::vo_tools::SampDisconnect {} {
   ::Samp::destroy
   ::vo_tools::handleInteropBtnState "disabled"
   ::vo_tools::handleBroadcastBtnState "disabled"
}

#------------------------------------------------------------
# ::vo_tools::LoadVotable
#    Charge une VOTable locale et affiche les objets dans la visu
#------------------------------------------------------------
proc ::vo_tools::LoadVotable { } {
   global audace caption

   # Verifie qu'une image est presente dans le canvas
   set image [::confVisu::getFileName $::audace(visuNo)]
   if { [file exists $image] == 0 } {
      tk_messageBox -title "Error" -type ok -message $caption(vo_tools_go,samp_noimageloaded)
   } else {
      # Ok, charge la VOTable
      if {[::votableUtil::loadVotable ? $::audace(visuNo)]} {
         ::votableUtil::displayVotable [::votableUtil::votable2list] $::audace(visuNo) "orange" "oval"
      }
      Menu_Configure $::audace(visuNo) "Interop" $caption(vo_tools_go,samp_menu_broadcastTab) "-state" "normal"
   }
}

#------------------------------------------------------------
# ::vo_tools::ClearDisplay
#    Nettoie les objets affiches dans la visu a partir d'une VOTable
#------------------------------------------------------------
proc ::vo_tools::ClearDisplay { args } {
   ::votableUtil::clearDisplay
}

#------------------------------------------------------------
# ::vo_tools::SampBroadcastImage
#    Broadcast l'image courante
#------------------------------------------------------------
proc ::vo_tools::SampBroadcastImage {} {
   global audace caption
   set image [::confVisu::getFileName $::audace(visuNo)]

   if { [file exists $image] } {
      if { [::Samp::check] == 1 } {
         set imgFile [::Samp::convertEntities $image]
         set url "file://localhost/$imgFile"
         ::console::affiche_resultat "$caption(vo_tools_go,samp_imgtobroadcast) $image \n"
         set msg [::samp::m_imageLoadFits $::samp::key [list samp.mtype image.load.fits samp.params [list "name" "$url" "image-id" "$url" "url" "$url"] ]]
      } else {
         ::console::affiche_erreur $caption(vo_tools_go,samp_hubnotfound)
         ::vo_tools::handleInteropBtnState "disabled"
         ::vo_tools::handleBroadcastBtnState "disabled"
      }
   } else {
      ::console::affiche_erreur "$caption(vo_tools_go,samp_noimgtobroadcast) \n"
   }
}

#------------------------------------------------------------
# ::vo_tools::SampBroadcastTable
#    Broadcast l'image courante
#------------------------------------------------------------
proc ::vo_tools::SampBroadcastTable {} {
   global caption
   if { [info exists ::votableUtil::votBuf(file)] &&
         [file exists $::votableUtil::votBuf(file)] } {
      if { [::Samp::check] == 1 } {
         set imgTab [::Samp::convertEntities $::votableUtil::votBuf(file)]
         set url "file://localhost/$imgTab"
         ::console::affiche_resultat "$caption(vo_tools_go,samp_tabtobroadcast) $::votableUtil::votBuf(file)\n"
         set msg [::samp::m_tableLoadVotable $::samp::key [list samp.mtype table.load.votable samp.params [list "name" "$url" "table-id" "$url" "url" "$url"] ]]
      } else {
         ::console::affiche_erreur "$caption(vo_tools_go,samp_hubnotfound) \n"
         ::vo_tools::handleInteropBtnState "disabled"
         ::vo_tools::handleBroadcastBtnState "disabled"
      }
   } else {
      ::console::affiche_erreur "$caption(vo_tools_go,samp_notabtobroadcast) \n"
   }
}

#------------------------------------------------------------
# ::vo_tools::SampBroadcastSpectrum
#    Broadcast le spectre courant
#------------------------------------------------------------
proc ::vo_tools::SampBroadcastSpectrum {} {
   global audace caption
   set spectrum [::confVisu::getFileName $::audace(visuNo)]

   if { [file exists $spectrum] } {
      if { [::Samp::check] == 1 } {
         set speFile [::Samp::convertEntities $spectrum]
         set url "file://localhost/$speFile"
         ::console::affiche_resultat "$caption(vo_tools_go,samp_spetobroadcast) $spectrum \n"
         set msg [::samp::m_spectrumLoadSsaGeneric $::samp::key [list samp.mtype spectrum.load.ssa-generic samp.params [list "name" "$url" "spectrum-id" "$url" "url" "$url"] ]]
      } else {
         ::console::affiche_erreur $caption(vo_tools_go,samp_hubnotfound)
         ::vo_tools::handleInteropBtnState "disabled"
         ::vo_tools::handleBroadcastBtnState "disabled"
      }
   } else {
      ::console::affiche_erreur "$caption(vo_tools_go,samp_nospetobroadcast) \n"
   }
}

#------------------------------------------------------------
# ::vo_tools::SampBroadcastPointAtSky
#    Broadcast les coordonnees du point clique dans la visu
#------------------------------------------------------------
proc ::vo_tools::SampBroadcastPointAtSky { w x y } {
   global audace

   # Recupere la valeur courante du zoom
#   set zoom [visu$::audace(visuNo) zoom]
   set zoom [::confVisu::getZoom $::audace(visuNo)]
   # Recupere les dimensions de l'image en px
   set naxis1 [expr [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1] * $zoom]
   set naxis2 [expr [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1] * $zoom]
   # Converti les coord. pointees en coord. canvas
   set coord [::audace::screen2Canvas [list $x $y]]
   # Converti les coordonnees canvas en coordonnees x,y dans l'image
   set imgXY [::audace::canvas2Picture $coord]
   # Converti les coordonnees x,y dans l'image en coordonnees sur le ciel
   set err [catch {buf$audace(bufNo) xy2radec $imgXY} RADEC ]
gren_info "$w \n Audela->Samp RA DEC = [lindex $RADEC 0] [lindex $RADEC 1]  (Screen: $x $y ; Canva: $coord  ; Img: $imgXY)\n"
   if {$err == 0} {
      # Broadcast les coordonnees
      set msg [::samp::m_coordPointAtSky $::samp::key [list samp.mtype coord.pointAt.sky samp.params [list "ra" [lindex $RADEC 0] "dec" [lindex $RADEC 1]] ]]
   }

}

#------------------------------------------------------------
# ::vo_tools::helpInterop
#    Ouvre l'aide en ligne
#------------------------------------------------------------
proc ::vo_tools::helpInterop { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ] "field_7"
}

#------------------------------------------------------------
# ::vo_tools::InstallMenuInterop
#    Installe le menu Interop dans la barre de menu d'Audace
#------------------------------------------------------------
proc ::vo_tools::InstallMenuInterop { frame } {
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
   bind $::audace(hCanvas) <ButtonPress-1> {::vo_tools::SampBroadcastPointAtSky %W %x %y}
   # Active la mise a jour automatique de l'affichage quand on change d'image
   ::confVisu::addFileNameListener $visuNo "::vo_tools::handleBroadcastBtnState"
   ::confVisu::addFileNameListener $visuNo "::vo_tools::ClearDisplay"

}

