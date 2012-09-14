#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_go.tcl
#--------------------------------------------------
#
# Fichier        : av4l_go.tcl
# Description    : Acquisition Video For Linux
# Auteur         : Stephane Vaillant & Frederic Vachier
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace av4l
#    initialise le namespace
#============================================================
namespace eval ::av4l {
   package provide av4l 1.0
   variable This

   #--- Chargement des captions
   source [ file join [file dirname [info script]] av4l_go.cap ]
   source [ file join [file dirname [info script]] av4l_extraction.cap ]
}

#------------------------------------------------------------
# ::av4l::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::av4l::getPluginTitle { } {
   global caption

   return "$caption(av4l_go,titre)"
}

#------------------------------------------------------------
# ::av4l::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::av4l::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  ::av4l::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::av4l::getPluginOS { } {
   return [ list Linux Windows]
}

#------------------------------------------------------------
# ::av4l::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::av4l::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "video" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# ::av4l::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::av4l::initPlugin { tkbase } {
   global audace
   global conf
   global av4lconf

   set av4lconf(font,courier_10) "Courier 10 normal"
   set av4lconf(font,courier_10_b) "Courier 10 bold"
   set av4lconf(font,arial_10_b) "{Arial} 10 bold"
   set av4lconf(font,arial_12)   "{Arial} 12 normal"
   set av4lconf(font,arial_12_b) "{Arial} 12 bold"
   set av4lconf(font,arial_14_b) "{Arial} 14 bold"

   ::av4l::ressource

   # foreach param $::av4l_config::allparams {
   #   if {[info exists conf(av4l,$param)]} then { set av4lconf($param) $conf(av4l,$param) }
   # }

   set av4lconf(bufno)    $audace(bufNo)
   set av4lconf(rep_plug) [file join $audace(rep_plugin) tool av4l ]

   if { [catch {load libavi[info sharedlibextension] }] } {
          # ::console::affiche_erreur "La librairie libavi du plugin av4l n'a pas pu etre chargee\n"
   }
   # ::console::affiche_resultat [::hello]
}

#------------------------------------------------------------
# ::av4l::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::av4l::createPluginInstance { { in "" } { visuNo 1 } } {

   global audace caption conf panneau

   #--- Chargement des fichiers auxiliaires
   ::av4l::ressource

   #---
   set panneau(av4l,$visuNo,base) "$in"
   set panneau(av4l,$visuNo,This) "$in.av4l"

   set panneau(av4l,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(av4l,$visuNo,camNo)   [::confCam::getCamNo $panneau(av4l,$visuNo,camItem)]


   #--- Recuperation de la derniere configuration de l'outil
   ::av4l::chargerVariable $visuNo

   #--- Initialisation d'autres variables
   #set panneau(av4l,$visuNo,index)                "1"
   #set panneau(av4l,$visuNo,indexEndSerie)        ""
   #set panneau(av4l,$visuNo,nom_image)            ""
   #set panneau(av4l,$visuNo,indexEndSerieContinu) ""
   #set panneau(av4l,$visuNo,nom_image)            ""
   #set panneau(av4l,$visuNo,indexer)              "0"
   #set panneau(av4l,$visuNo,indexer)              "0"

   #--- Construction de l'interface
   ::av4l::BuildIF $visuNo

}

#------------------------------------------------------------
# ::av4l::ressource
#    ressource l ensemble des scripts
#------------------------------------------------------------
proc ::av4l::ressource {  } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool av4l av4l_go.cap ]
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_acq.tcl            ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_cdl_gui.tcl        ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_cdl.tcl            ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_cdl_tools.tcl      ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_extraction.tcl     ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_go.tcl             ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_ocr_gui.tcl        ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_ocr_tools.tcl      ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_ocr.tcl            ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_photom.tcl         ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_setup.tcl          ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_tools.tcl          ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_tools_avi.tcl      ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_tools_fits.tcl     ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_verif.tcl          ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l av4l_analysis_tools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool av4l test.tcl                ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_cdl.tcl ]\""

}





#------------------------------------------------------------
# ::av4l::chargerVariable
#    Chargement des variables
#------------------------------------------------------------
proc ::av4l::chargerVariable { visuNo } {

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) av4l.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::av4l_setup::initToConf $visuNo

}




#------------------------------------------------------------
# ::av4l::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::av4l::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::av4l::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::startTool { { visuNo 1 } } {
   global panneau

   variable This

   pack $panneau(av4l,$visuNo,This) -side left -fill y

}

#------------------------------------------------------------
# ::av4l::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::stopTool { { visuNo 1 } } {

   global panneau
   variable This


   pack forget $panneau(av4l,$visuNo,This)
}

#------------------------------------------------------------
# ::av4l::vo_toolsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::av4l::BuildIF { visuNo } {

      package require Img

      global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   set This $panneau(av4l,$visuNo,This)
   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove
      pack $This.fra1 -side top -fill x

         #--- Creation du bouton
         image create photo .help -format PNG -file [ file join $audace(rep_plugin) tool av4l img help.png ]
         button $This.fra1.help -image .help\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::audace::showHelpPlugin tool av4l av4l.htm"
         pack $This.fra1.help \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.help -text $caption(av4l_go,help_titre)


         #--- Creation du bouton
         image create photo .setup -format PNG -file [ file join $audace(rep_plugin) tool av4l img setup.png ]
         button $This.fra1.setup -image .setup\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::av4l_setup::run  $visuNo $base.av4l_setup"
         pack $This.fra1.setup \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.setup -text $caption(av4l_go,setup)


         #--- Creation du bouton
         image create photo .acq -format PNG -file [ file join $audace(rep_plugin) tool av4l img acquisition.png ]
         button $This.fra1.acq -image .acq\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::av4l_acq::run  $visuNo $base.av4l_acquisition"
         pack $This.fra1.acq \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.acq -text $caption(av4l_go,acquisition)


         #--- Creation du bouton
         image create photo .extract -format PNG -file [ file join $audace(rep_plugin) tool av4l img extraction.png ]
         button $This.fra1.extract -image .extract\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::av4l_extraction::run  $visuNo $base.av4l_extraction"
         pack $This.fra1.extract \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.extract -text $caption(av4l_go,extraction)


         #--- Creation du bouton
         image create photo .time -format PNG -file [ file join $audace(rep_plugin) tool av4l img time.png ]
         button $This.fra1.time -image .time\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::av4l_ocr::run  $visuNo $base.av4l_ocr"
         pack $This.fra1.time \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.time -text $caption(av4l_go,time)

         #--- Creation du bouton
         image create photo .cdl -format PNG -file [ file join $audace(rep_plugin) tool av4l img cdl.png ]
         button $This.fra1.cdl -image .cdl\
            -borderwidth 2 -width 48 -height 48 -compound center \
            -command "::av4l_cdl::run  $visuNo $base.av4l_cdl"
         pack $This.fra1.cdl \
            -in $This.fra1 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fra1.cdl -text $caption(av4l_go,cdl)


     if { $::av4l::parametres(av4l,$visuNo,mode_debug)==1 } {

      #--- Frame du titre
      frame $This.fradev -borderwidth 2 -relief groove
      pack $This.fradev -side top -fill x



         #--- Creation du bouton
         image create photo .analysis -format PNG -file [ file join $audace(rep_plugin) tool av4l img brain_mini.png ]
         button $This.fradev.analysis -image .analysis\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::av4l_gui_analysis::run"
         pack $This.fradev.analysis \
            -in $This.fradev \
            -side left -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev.analysis -text $caption(av4l_go,analysis)


         #--- Creation du bouton
         image create photo .test -format PNG -file [ file join $audace(rep_plugin) tool av4l img test_mini.png ]
         button $This.fradev.test -image .test\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::testprocedure::run"
         pack $This.fradev.test \
            -in $This.fradev \
            -side left -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev.test -text $caption(av4l_go,test)


         #--- Creation du bouton
         image create photo .ressource -format PNG -file [ file join $audace(rep_plugin) tool av4l img ressource_mini.png ]
         button $This.fradev.ressource -image .ressource\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::av4l::ressource"
         pack $This.fradev.ressource \
            -in $This.fradev \
            -side left -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev.ressource -text $caption(av4l_go,ressource)


      #--- Frame du titre
      frame $This.fradev2 -borderwidth 2 -relief groove
      pack $This.fradev2 -side top -fill x


         #--- Creation du bouton
         image create photo .verif -format PNG -file [ file join $audace(rep_plugin) tool av4l img verif.png ]
         button $This.fradev2.verif -image .verif\
            -borderwidth 2 -width 10 -height 10 -compound center \
            -command "::av4l_verif::run  $visuNo $base.av4l_verif"
         pack $This.fradev2.verif \
            -in $This.fradev2 \
            -side top -anchor w \
            -expand 0
         DynamicHelp::add $This.fradev2.verif -text $caption(av4l_go,verif)


     }



      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

proc gren_info { msg } { ::console::affiche_resultat "$msg" }

