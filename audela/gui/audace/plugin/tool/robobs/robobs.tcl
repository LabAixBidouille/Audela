#---------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/plugin/tool/robobs/robobs.tcl
#---------------------------------------------------------------------
#
# Fichier        : robobs.tcl
# Description    : Outil pour piloter un observatoire robotique
# Auteur         : Alain Klotz
# Mise à jour $Id: robobs.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#============================================================
# Declaration du namespace robobs
#    initialise le namespace
#============================================================
namespace eval ::robobs {
   package provide robobs 1.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] robobs.cap ]
}

#------------------------------------------------------------
# ::robobs::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::robobs::getPluginTitle { } {
   global caption

   return "$caption(robobs,titre)"
}

#------------------------------------------------------------
# ::robobs::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::robobs::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::robobs::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::robobs::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::robobs::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::robobs::initPlugin { tkbase } {
   global audace
   global conf
   global robobsconf
   global robobs

   set robobsconf(font,courier_10) "Courier 10 normal"
   set robobsconf(font,arial_10_b) "{Arial} 10 bold"
   set robobsconf(font,arial_12)   "{Arial} 12 normal"
   set robobsconf(font,arial_12_b) "{Arial} 12 bold"
   set robobsconf(font,arial_14_b) "{Arial} 14 bold"

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_config.tcl ]\""
   # foreach param $::robobs_config::allparams {
   #   if {[info exists conf(robobs,$param)]} then { set robobsconf($param) $conf(robobs,$param) }
   # }

   set robobsconf(bufno)    $audace(bufNo)
   set robobsconf(rep_plug) [file join $audace(rep_plugin) tool robobs ]
   set cgi_config_file $audace(rep_install)/bin/cgi_root.tcl
   set robobsconf(webserver) 0
   if {[file exists $cgi_config_file]==1} {
      source $cgi_config_file
      set robobsconf(webserver,htdocs) $cgi(root,htdocs)
      set robobsconf(webserver,cgi-bin) $cgi(root,cgi-bin)
      set robobsconf(webserver) 1
   }

}

#------------------------------------------------------------
# ::robobs::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::robobs::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require tablelist
   ::robobs::ressource
   ::robobs::createPanel $in.robobs
}

#------------------------------------------------------------
# ::robobs::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::robobs::ressource {  } {
   global audace

	set cmds [info commands *robobs*]
	foreach cmd $cmds {
		if {[string first .audace.tool.robobs $cmd]>=0} {
			continue
		}		
		#catch {destroy $cmd}
	}
   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool robobs robobs.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_planif.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_acquisition.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_config.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_planif.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_acquisition.cap ]\""
   
   return ""
}

#------------------------------------------------------------
# ::robobs::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::robobs::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::robobs::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::robobs::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(robobs,titre)  "$caption(robobs,robobs)"
   set panneau(robobs,aide)   "$caption(robobs,help_titre)"
   set panneau(robobs,aide1)  "$caption(robobs,help_titre1)"
   set panneau(robobs,configuration) "$caption(robobs,configuration)"
   set panneau(robobs,planification) "$caption(robobs,planification)"
   set panneau(robobs,acquisition) "$caption(robobs,acquisition)"
   set panneau(robobs,resource) "$caption(robobs,resource)"
   #--- Construction de l'interface
   ::robobs::robobsBuildIF $This

}

#------------------------------------------------------------
# ::robobs::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::robobs::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# ::robobs::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::robobs::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# ::robobs::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::robobs::robobsBuildIF { This } {
   global audace panneau caption

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(robobs,aide1)\n$panneau(robobs,titre)" \
            -command "::audace::showHelpPlugin tool robobs robobs.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(robobs,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de configuration
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de configuration
         button $This.fra2.but1 -borderwidth 2 -text $panneau(robobs,configuration) \
            -command "::robobs_config::run $audace(base).robobs_config"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame de planification
      frame $This.planification -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.planification.but1 -borderwidth 2 -text $caption(robobs,planification) \
            -command "::robobs_planif::run $audace(base).robobs_planification"
         pack $This.planification.but1 -in $This.planification -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.planification -side top -fill x

      #--- Frame d'acquisition
      frame $This.acquisition -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de statut
         button $This.acquisition.but1 -borderwidth 2 -text $caption(robobs,acquisition) \
            -command "::robobs_acquisition::run $audace(base).robobs_acquisition"
         pack $This.acquisition.but1 -in $This.acquisition -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.acquisition -side top -fill x

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove

         #--- Bouton de rechargement des sources du plugin
         button $This.ressource.but1 -borderwidth 2 -text $panneau(robobs,resource) \
            -command {::robobs::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.ressource -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
      
}

#------------------------------------------------------------
# ::robobs::verbose
#    Regle le niveau de bavardage
#------------------------------------------------------------
proc ::robobs::verbose { {verbose_level ""} } {
   global audace panneau caption robobs
   variable This
   if {[info exists robobs(verbose_level)]==0} {
      set robobs(verbose_level) 100
   }
   if {$verbose_level==""} {
      return $robobs(verbose_level)
   } else {
      set robobs(verbose_level) $verbose_level
   }
}

#------------------------------------------------------------
# ::robobs::log
#    log et affiche un message
#------------------------------------------------------------
proc ::robobs::log { msg {verbose_level 0} } {
   global audace panneau caption robobs robobsconf
   variable This
   set level [::robobs::verbose]
   if {$verbose_level>=$robobs(verbose_level)} {
      return ""
   }
   set path $audace(rep_travail)
   set texte "[mc_date2iso8601 [::audace::date_sys2ut]] : $msg"
   ::console::affiche_resultat "$texte\n"
   catch {
      set f [open ${path}/robobs.log a]
      puts $f "$texte"
      close $f
   }
   if {$robobsconf(webserver)==1} {
      set path $robobsconf(webserver,htdocs)
      # --- historique des 30 dernieres lignes
      if {[info exists robobs(log,lasts)]==0} {
         set robobs(log,lasts) "$msg"
      } else {
         if {[info exists robobs(log,nlig_lasts)]==0} {
            set robobs(log,nlig_lasts) 30
         }
         set n [llength $robobs(log,lasts)]
         set kfin [expr $n-1]
         set kdeb [expr $kfin-$robobs(log,nlig_lasts)]
         if {$kdeb<0} { set kdeb 0 }
         set robobs(log,lasts) [lrange $robobs(log,lasts) $kdeb $kfin]
         lappend robobs(log,lasts) "$msg"
         set lignes ""
         foreach ligne $robobs(log,lasts) {
            append lignes "$ligne\n"
         }
            file mkdir ${path}/robobs/logs
            set fid [open "${path}/robobs/logs/acquisition_last.log" "w"]
            puts $fid $lignes
            close $fid
      }
      
   }
   
}
