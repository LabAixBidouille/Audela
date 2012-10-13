#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_go.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_go.tcl
# Description    : Demarrage du plugin ATOS
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_go.tcl 8110 2012-02-16 21:20:04Z fredvachier $
#

#============================================================
# Declaration du namespace atos
#    initialise le namespace
#============================================================
namespace eval ::atos {
   package provide atos 1.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] atos_go.cap ]
   source [ file join [file dirname [info script]] atos_extraction.cap ]
}

#------------------------------------------------------------
# ::atos::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::atos::getPluginTitle { } {
   global caption

   return "$caption(atos_go,titre)"
}

#------------------------------------------------------------
# ::atos::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::atos::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  ::atos::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::atos::getPluginOS { } {
   return [ list Linux Windows]
}

#------------------------------------------------------------
# ::atos::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::atos::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "video" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::atos::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::atos::initPlugin { tkbase } {
   global audace
   global conf
   global atosconf

   set atosconf(font,courier_10) "Courier 10 normal"
   set atosconf(font,courier_10_b) "Courier 10 bold"
   set atosconf(font,arial_10_b) "{Arial} 10 bold"
   set atosconf(font,arial_12)   "{Arial} 12 normal"
   set atosconf(font,arial_12_b) "{Arial} 12 bold"
   set atosconf(font,arial_14_b) "{Arial} 14 bold"

   ::atos::ressource

   # foreach param $::atos_config::allparams {
   #   if {[info exists conf(atos,$param)]} then { set atosconf($param) $conf(atos,$param) }
   # }

   set atosconf(bufno)    $audace(bufNo)
   set atosconf(rep_plug) [file join $audace(rep_plugin) tool atos ]

   if { [catch {load libavi[info sharedlibextension] }] } {
          # ::console::affiche_erreur "La librairie libavi du plugin atos n'a pas pu etre chargee\n"
   }
   # ::console::affiche_resultat [::hello]
}

#------------------------------------------------------------
# ::atos::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::atos::createPluginInstance { { in "" } { visuNo 1 } } {

   global audace caption conf panneau

   #--- Chargement des fichiers auxiliaires
   ::atos::ressource

   #---
   set panneau(atos,$visuNo,base) "$in"
   set panneau(atos,$visuNo,This) "$in.atos"

   set panneau(atos,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(atos,$visuNo,camNo)   [::confCam::getCamNo $panneau(atos,$visuNo,camItem)]


   #--- Recuperation de la derniere configuration de l'outil
   ::atos::chargerVariable $visuNo

   #--- Initialisation d'autres variables
   #set panneau(atos,$visuNo,index)                "1"
   #set panneau(atos,$visuNo,indexEndSerie)        ""
   #set panneau(atos,$visuNo,nom_image)            ""
   #set panneau(atos,$visuNo,indexEndSerieContinu) ""
   #set panneau(atos,$visuNo,nom_image)            ""
   #set panneau(atos,$visuNo,indexer)              "0"
   #set panneau(atos,$visuNo,indexer)              "0"

   #--- Construction de l'interface
   ::atos::BuildIF $visuNo

}

#------------------------------------------------------------
# ::atos::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::atos::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool atos atos_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_acq.tcl            ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_cdl_gui.tcl        ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_cdl.tcl            ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_cdl_tools.tcl      ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_extraction.tcl     ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_go.tcl             ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_ocr_gui.tcl        ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_ocr_tools.tcl      ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_ocr.tcl            ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_photom.tcl         ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_setup.tcl          ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_tools.tcl          ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_tools_avi.tcl      ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_tools_fits.tcl     ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_verif.tcl          ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_analysis_tools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_analysis_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos atos_analysis_gui_ihm.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool atos test.tcl                ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_cdl.tcl ]\""

}





#------------------------------------------------------------
# ::atos::chargerVariable
#    Chargement des variables
#------------------------------------------------------------
proc ::atos::chargerVariable { visuNo } {

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) atos.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::atos_setup::initToConf $visuNo

}




#------------------------------------------------------------
# ::atos::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::atos::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::atos::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::atos::startTool { { visuNo 1 } } {
   global panneau

   variable This

   pack $panneau(atos,$visuNo,This) -side left -fill y

}

#------------------------------------------------------------
# ::atos::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::atos::stopTool { { visuNo 1 } } {

   global panneau
   variable This


   pack forget $panneau(atos,$visuNo,This)
}

#------------------------------------------------------------
# ::atos::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::atos::BuildIF { visuNo } {

      package require Img

      global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   set This $panneau(atos,$visuNo,This)
   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove
      pack $This.fra1 -side top -fill x

         #--- Creation du bouton
         image create photo .help -format PNG -file [ file join $audace(rep_plugin) tool atos img help.png ]
         button $This.fra1.help -image .help\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::audace::showHelpPlugin tool atos atos.htm"
         pack $This.fra1.help \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.help -text $caption(atos_go,help_titre)


         #--- Creation du bouton
         image create photo .setup -format PNG -file [ file join $audace(rep_plugin) tool atos img setup.png ]
         button $This.fra1.setup -image .setup\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::atos_setup::run  $visuNo $base.atos_setup"
         pack $This.fra1.setup \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.setup -text $caption(atos_go,setup)


         #--- Creation du bouton
         image create photo .acq -format PNG -file [ file join $audace(rep_plugin) tool atos img acquisition.png ]
         button $This.fra1.acq -image .acq\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::atos_acq::run  $visuNo $base.atos_acquisition"
         pack $This.fra1.acq \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.acq -text $caption(atos_go,acquisition)


         #--- Creation du bouton
         image create photo .extract -format PNG -file [ file join $audace(rep_plugin) tool atos img extraction.png ]
         button $This.fra1.extract -image .extract\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::atos_extraction::run  $visuNo $base.atos_extraction"
         pack $This.fra1.extract \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.extract -text $caption(atos_go,extraction)


         #--- Creation du bouton
         image create photo .time -format PNG -file [ file join $audace(rep_plugin) tool atos img time.png ]
         button $This.fra1.time -image .time\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::atos_ocr::run  $visuNo $base.atos_ocr"
         pack $This.fra1.time \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.time -text $caption(atos_go,time)

         #--- Creation du bouton
         image create photo .cdl -format PNG -file [ file join $audace(rep_plugin) tool atos img photom.png ]
         button $This.fra1.cdl -image .cdl\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::atos_cdl::run  $visuNo $base.atos_cdl"
         pack $This.fra1.cdl \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.cdl -text $caption(atos_go,cdl)

         #--- Creation du bouton
         image create photo .analysis -format PNG -file [ file join $audace(rep_plugin) tool atos img cdl.png ]
         button $This.fra1.analysis -image .analysis\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::atos_analysis_gui::run  $visuNo $base.atos_analysis"
         pack $This.fra1.analysis \
            -in $This.fra1 \
            -side left -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.analysis -text $caption(atos_go,analysis)



     if { $::atos::parametres(atos,$visuNo,mode_debug)==1 } {




      #--- Frame du titre
      frame $This.fradev -borderwidth 2 -relief groove
      pack $This.fradev -side top -fill x


         #--- Creation du bouton
         image create photo .test -format PNG -file [ file join $audace(rep_plugin) tool atos img test_mini.png ]
         button $This.fradev.test -image .test\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::testprocedure::run"
         pack $This.fradev.test \
            -in $This.fradev \
            -side left -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev.test -text $caption(atos_go,test)


         #--- Creation du bouton
         image create photo .ressource -format PNG -file [ file join $audace(rep_plugin) tool atos img ressource_mini.png ]
         button $This.fradev.ressource -image .ressource\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::atos::ressource"
         pack $This.fradev.ressource \
            -in $This.fradev \
            -side left -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev.ressource -text $caption(atos_go,ressource)


         #--- Creation du bouton
         image create photo .verif -format PNG -file [ file join $audace(rep_plugin) tool atos img verif.png ]
         button $This.fradev.verif -image .verif\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::atos_verif::run  $visuNo $base.atos_verif"
         pack $This.fradev.verif \
            -in $This.fradev \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev.verif -text $caption(atos_go,verif)


     }



      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

proc gren_info { msg } { ::console::affiche_resultat "$msg" }

