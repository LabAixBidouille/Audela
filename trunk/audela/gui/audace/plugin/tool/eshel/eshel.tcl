#
# Fichier : eshel.tcl
# Description : outil de fabrication des fichier Kit et de deploiement des plugin
# Auteurs : Michel Pujol
# Mise à jour $Id$
#

##------------------------------------------------------------
# namespace ::eshel
#
# @short Fentre principale de l'outil eShel
#
# Fenetre de configuration des traitements
#
# Point d'entre principal
#  ::eshel::processgui::run
#------------------------------------------------------------

namespace eval ::eshel {
   global caption
   package provide eshel 2.2

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] eshel.cap ]
}

#------------------------------------------------------------
#  ::eshel::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::eshel::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
# Parametres :
#    Aucun
# Return :
#    La liste des OS supportes par le plugin
#------------------------------------------------------------
proc ::eshel::getPluginOS { } {
   return [ list Windows ]
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::eshel::initPlugin { tkbase } {

}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le repertoire de plugin
#------------------------------------------------------------
proc ::eshel::getPluginDirectory { } {
   return "eshel"
}

#------------------------------------------------------------
# getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::eshel::getPluginHelp { } {
   return "eshel.htm"
}

#------------------------------------------------------------
#  ::eshel::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::eshel::getPluginTitle { } {
   global caption

   return $caption(eshel,title)
}

#------------------------------------------------------------
#  ::eshel::getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::eshel::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::eshel::deletePluginInstance { visuNo } {
   variable private

   #--- j'arrete les acquisitions en cours
   ::eshel::stopAcquisition $visuNo
   #--- je ferme le fichier de trace
   closeLogFile

   #--- je ferme le panneau
   destroy $private($visuNo,frm)
}

#------------------------------------------------------------
# createPluginInstance
#  cree une instance l'outil
#  initialise les variables globales et locales par defaut
#  affiche les widgets dans le panneau de l'outil
#------------------------------------------------------------
proc ::eshel::createPluginInstance { {tkbase "" } { visuNo 1 } } {
   global audace caption conf
   variable private

   if { [llength [info commands eshel_*]] == 0 } {
      #--- si c'est la premiere instance, je charge le code TCL
      package require Tablelist
      set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
      source [ file join $dir process.tcl ]
      source [ file join $dir processgui.tcl ]
      source [ file join $dir processoption.tcl ]
      source [ file join $dir instrument.tcl ]
      source [ file join $dir instrumentgui.tcl ]
      source [ file join $dir session.tcl ]
      source [ file join $dir acquisition.tcl ]
      source [ file join $dir makeseries.tcl ]
      source [ file join $dir wizard.tcl ]
      source [ file join $dir eshelfile.tcl]
      source [ file join $dir visu.tcl]
      source [ file join $dir response.tcl]
      if { [file exists [ file join $dir libeshel.dll]]  } {
         set catchResult [ catch {
            load [ file join $dir libeshel.dll]
         } ]
         if { $catchResult == 1 } {
            ::console::affiche_erreur "$::errorInfo\n"
         }
      }
   }

   #--- je cree les variables globales si elles n'existaient pas
   if { ! [ info exists conf(eshel,mainDirectory) ] }     { set conf(eshel,mainDirectory)      "$::audace(rep_images)" }
   if { ! [ info exists conf(eshel,rawDirectory) ] }      { set conf(eshel,rawDirectory)       "$::audace(rep_images)/raw" }
   if { ! [ info exists conf(eshel,referenceDirectory)]}  { set conf(eshel,referenceDirectory) "$::audace(rep_images)/reference" }
   if { ! [ info exists conf(eshel,tempDirectory) ] }     { set conf(eshel,tempDirectory)      "$::audace(rep_images)/temp" }
   if { ! [ info exists conf(eshel,archiveDirectory) ] }  { set conf(eshel,archiveDirectory)   "$::audace(rep_images)/archive" }
   if { ! [ info exists conf(eshel,processedDirectory)]}  { set conf(eshel,processedDirectory) "$::audace(rep_images)/processed" }
   if { ! [ info exists conf(eshel,scriptFileName) ] }    { set conf(eshel,scriptFileName)     "process.tcl" }
   if { ! [ info exists conf(eshel,currentSequenceId) ] } { set conf(eshel,currentSequenceId)  "object"}
   if { ! [ info exists conf(eshel,expnb) ] }             { set conf(eshel,expnb)              1 }
   if { ! [ info exists conf(eshel,exptime) ] }           { set conf(eshel,exptime)            1 }
   if { ! [ info exists conf(eshel,objectList) ] }        { set conf(eshel,objectList)         "" }
   if { ! [ info exists conf(eshel,instrume) ] }          { set conf(eshel,instrume)           "eShel #001" }
   if { ! [ info exists conf(eshel,processAuto) ] }       { set conf(eshel,processAuto)        1 }
   if { ! [ info exists conf(eshel,binning) ] }           { set conf(eshel,binning)            "1x1" }
   if { ! [ info exists conf(eshel,repeat) ] }            { set conf(eshel,repeat)             1 }
   if { ! [ info exists conf(eshel,showProfile) ] }       { set conf(eshel,showProfile)        1 }
   if { ! [ info exists conf(eshel,enabledLogFile) ] }    { set conf(eshel,enabledLogFile)     1 }
   if { ! [ info exists conf(eshel,enableComment) ] }     { set conf(eshel,enableComment)      1 }
   if { ! [ info exists conf(eshel,enableGuidingUnit) ]}  { set conf(eshel,enableGuidingUnit)  1 }
   if { ! [ info exists conf(eshel,logFileName) ] }       { set conf(eshel,logFileName)        "eshellog.html" }
   if { ! [ info exists conf(eshel,keywordConfigName) ] } { set conf(eshel,keywordConfigName)  "default" }

   if { ! [ info exists conf(eshel,currentInstrument) ] } { set conf(eshel,currentInstrument)  "default" }

   #--- Parametres instrument par defaut
   set prefix "eshel,instrument,config,default"
   if { ! [ info exists conf($prefix,configName) ] }      { set conf($prefix,configName)       "default" }
   #------ Spectographe
   if { ! [ info exists conf($prefix,spectroName) ] }     { set conf($prefix,spectroName)      "eshel" }
   if { ! [ info exists conf($prefix,alpha) ] }           { set conf($prefix,alpha)            62.2 }
   if { ! [ info exists conf($prefix,beta) ] }            { set conf($prefix,beta)             0 }
   if { ! [ info exists conf($prefix,gamma) ] }           { set conf($prefix,gamma)            5.75 }
   if { ! [ info exists conf($prefix,grating) ] }         { set conf($prefix,grating)          79.0 }
   if { ! [ info exists conf($prefix,focale) ] }          { set conf($prefix,focale)           85.0 }
   if { ! [ info exists conf($prefix,distorsion) ] }      { set conf($prefix,distorsion)       "" }
   if { ! [ info exists conf($prefix,spectrograhLink) ] } { set conf($prefix,spectrograhLink)  "" }
   if { ! [ info exists conf($prefix,mirror,bit) ] }      { set conf($prefix,mirror,bit)       1 }
   if { ! [ info exists conf($prefix,thar,bit) ] }        { set conf($prefix,thar,bit)         2 }
   if { ! [ info exists conf($prefix,flat,bit) ] }        { set conf($prefix,flat,bit)         3 }
   if { ! [ info exists conf($prefix,tungsten,bit) ] }        { set conf($prefix,tungsten,bit)         4 }
   #------ Telescope
   if { ! [ info exists conf($prefix,telescopeName) ] }   { set conf($prefix,telescopeName)    "default telescope" }
   #------ Camera
   if { ! [ info exists conf($prefix,cameraName) ] }      { set conf($prefix,cameraName)       "Audine Kaf 400" }
   if { ! [ info exists conf($prefix,cameraLabel) ] }     { set conf($prefix,cameraLabel)      "Audine" }
   if { ! [ info exists conf($prefix,cameraNamespace)] }  { set conf($prefix,cameraNamespace)  "audine" }
   if { ! [ info exists conf($prefix,binning)] }          { set conf($prefix,binning)          [list 1 1 ] }
   if { ! [ info exists conf($prefix,pixelSize) ] }       { set conf($prefix,pixelSize)        0.009 }
   if { ! [ info exists conf($prefix,width) ] }           { set conf($prefix,width)            1530 }
   if { ! [ info exists conf($prefix,height) ] }          { set conf($prefix,height)           1020 }
   if { ! [ info exists conf($prefix,x1) ] }              { set conf($prefix,x1)               1 }
   if { ! [ info exists conf($prefix,y1) ] }              { set conf($prefix,y1)               1 }
   if { ! [ info exists conf($prefix,x2) ] }              { set conf($prefix,x2)               $conf($prefix,width) }
   if { ! [ info exists conf($prefix,y2) ] }              { set conf($prefix,y2)               $conf($prefix,height) }
   #------ Traitement
   if { ! [ info exists conf($prefix,quickProcess) ] }    { set conf($prefix,quickProcess)     1 }
   if { ! [ info exists conf($prefix,boxWide) ] }         { set conf($prefix,boxWide)          25 }
   if { ! [ info exists conf($prefix,wideOrder) ] }       { set conf($prefix,wideOrder)        12 }
   if { ! [ info exists conf($prefix,threshold) ] }       { set conf($prefix,threshold)        100 }
   if { ! [ info exists conf($prefix,minOrder) ] }        { set conf($prefix,minOrder)         33 }
   if { ! [ info exists conf($prefix,maxOrder) ] }        { set conf($prefix,maxOrder)         44 }
   if { ! [ info exists conf($prefix,refNum) ] }          { set conf($prefix,refNum)           34 }
   if { ! [ info exists conf($prefix,refX) ] }            { set conf($prefix,refX)             978 }
   if { ! [ info exists conf($prefix,refY) ] }            { set conf($prefix,refY)             826 }
   if { ! [ info exists conf($prefix,refLambda) ] }       { set conf($prefix,refLambda)        6583.906 }
   if { ! [ info exists conf($prefix,calibIter) ] }       { set conf($prefix,calibIter)        3 }
   if { ! [ info exists conf($prefix,hotPixelEnabled)] }  { set conf($prefix,hotPixelEnabled)  0 }
   if { ! [ info exists conf($prefix,hotPixelList) ] }    { set conf($prefix,hotPixelList)     [list ] }
   if { ! [ info exists conf($prefix,cosmicEnabled)] }    { set conf($prefix,cosmicEnabled)    0 }
   if { ! [ info exists conf($prefix,cosmicThreshold)] }  { set conf($prefix,cosmicThreshold)  400 }
   if { ! [ info exists conf($prefix,flatFieldEnabled)] } { set conf($prefix,flatFieldEnabled) 0 }
   if { ! [ info exists conf($prefix,responseOption)] }   { set conf($prefix,responseOption)   "NONE" }  ;# MANUAL , AUTO, NONE
   if { ! [ info exists conf($prefix,responseFileName)] } { set conf($prefix,responseFileName) "" }
   if { ! [ info exists conf($prefix,responsePerOrder)] } { set conf($prefix,responsePerOrder) 1 }      ; # 0=FULL spectrum 1=per order
   if { ! [ info exists conf($prefix,saveObjectImage)] }  { set conf($prefix,saveObjectImage)  1 }      ;# enregistre l'image 2D de l'OBJET dans le fichier de sortie
   #--- liste des mots clefs a mettre dans les acquisitions
   set conf(keyword,visu1,check) "1,check,IMAGETYP 1,check,SERIESID 1,check,DETNAM 1,check,TELESCOP 1,check,OBSERVER 1,check,OBJNAME 1,check,EXPOSURE 1,check,INSTRUME 1,check,SWCREATE 1,check,SITENAME 1,check,SITELONG 1,check,SITELAT 1,check,SITEELEV"

   if { ! [ info exists conf($prefix,orderDefinition) ] } {
      set conf($prefix,orderDefinition) { \
         { 30 25  1510 0.0 } \
         { 31 30  1510 0.0 } \
         { 32 35  1510 0.0 } \
         { 33 40  1510 0.0 } \
         { 34 50  1480 0.0 } \
         { 35 60  1470 0.0 } \
         { 36 75  1455 0.0 } \
         { 37 90  1440 0.0 } \
         { 38 105 1425 0.0 } \
         { 39 120 1410 0.0 } \
         { 40 135 1395 0.0 } \
         { 41 150 1380 0.0 } \
         { 42 165 1365 0.0 } \
         { 43 180 1350 0.0 } \
         { 44 195 1335 0.0 } \
         { 45 210 1320 0.0 } \
         { 46 225 1305 0.0 } \
         { 47 240 1290 0.0 } \
         { 48 260 1270 0.0 } \
         { 49 280 1250 0.0 } \
         { 50 300 1230 0.0 } \
         { 51 300 1230 0.0 } \
         { 52 300 1230 0.0 } \
         { 53 300 1230 0.0 } \
         { 54 300 1230 0.0 } \
      }
   }

   if { ! [ info exists conf($prefix,cropLambda) ] } {
     set conf($prefix,cropLambda) ""
   }

   if { ! [ info exists conf($prefix,lineList) ] } {
      set conf($prefix,lineList) { \
         6416.307 \
         6457.282 \
         6466.553 \
         6490.737 \
         6512.364 \
         6531.342 \
         6538.112 \
         6554.160 \
         6583.906 \
         6604.853 \
         6643.698 \
         6242.941 \
         6261.418 \
         6296.872 \
         6307.657 \
         6342.859 \
         6376.931 \
         6384.717 \
         6043.223 \
         6059.373 \
         6098.803 \
         6114.923 \
         6145.441 \
         6169.822 \
         6182.622 \
         6188.125 \
         6191.905 \
         6198.223 \
         6203.493 \
         6207.220 \
         6212.503 \
         6215.938 \
         6224.527 \
         6234.855 \
         6261.418 \
         5912.085 \
         5928.813 \
         5938.825 \
         5994.129 \
         6021.036 \
         6025.150 \
         6032.127 \
         5760.551 \
         5789.645 \
         5804.141 \
         5834.263 \
         5860.310 \
         5888.584 \
         5606.733 \
         5615.319 \
         5650.704 \
         5665.180 \
         5681.900 \
         5700.917 \
         5720.183 \
         5739.519 \
         5451.652 \
         5495.874 \
         5509.994 \
         5514.873 \
         5524.957 \
         5539.262 \
         5548.176 \
         5558.702 \
         5587.026 \
         5595.063 \
         5601.603 \
         6677.282 \
         6684.293 \
         6698.876 \
         6727.458 \
         6766.612 \
         6834.925 \
         6861.269 \
         6871.289 \
         5317.495 \
         5326.976 \
         5343.581 \
         5379.110 \
         5407.653 \
         5410.769 \
         5417.486 \
         5421.352 \
         5439.989 \
         5457.416 \
         5187.746 \
         5199.164 \
         5211.230 \
         5221.271 \
         5231.160 \
         5247.655 \
         5252.788 \
         5258.360 \
         5266.710 \
         5067.974 \
         5090.545 \
         5100.621 \
         5115.045 \
         5125.765 \
         5141.783 \
         5158.604 \
         4965.080 \
         4985.373 \
         5002.097 \
         5009.334 \
         5017.163 \
         5039.320 \
         5044.720 \
         5062.037 \
         4847.810 \
         4865.477 \
         4879.863 \
         4889.042 \
         4894.955 \
         4919.816 \
         4933.209 \
         4945.458 \
         4764.865 \
         4778.294 \
         4789.387 \
         4806.020 \
         4840.849 \
         4657.901 \
         4673.661 \
         4695.038 \
         4723.438 \
         4726.868 \
         4735.906 \
         4545.052 \
         4579.350 \
         4589.898 \
         4598.763 \
         4609.567 \
         4628.441 \
         4637.233 \
         4474.759 \
         4481.810 \
         4493.333 \
         4510.733 \
         4379.667 \
         4385.057 \
         4408.883 \
         4426.001 \
         4448.879 \
         4458.001 \
      }
   }

   #--- je verifie que toutes les configurations ont bien toutes les parametres ((en cas d'evolution de eShel))
   #--- si ce n'est pas le cas, je cree la variable avec la valeur de la configuration "defaut"
   foreach configPath [array names ::conf eshel,instrument,config,*,orderDefinition] {
      set configId [lindex [split $configPath "," ] 3]
      #--- je verifie que tous les parametres existent (necessaires pour les parametres qui seront ajoutes dans les futures versions)
      foreach paramFullName  [array names ::conf eshel,instrument,config,default,*] {
         set paramName [string range $paramFullName [string length "eshel,instrument,config,default,"] end]
         if { [ info exists ::conf(eshel,instrument,config,$configId,$paramName) ] == 0 } {
            #--- j'ajoute le parametre s'il n'existe pas
            if { $paramName == "configName" } {
               #--- je cree le nom s'il n'existe pas (evolution de la version 1.9 ajout du parametre configName)
               #--- je prends la valeur du configId de cette meme configuration
               set ::conf(eshel,instrument,config,$configId,configName) $configId
            } else {
               #--- je prends la valeur du parametres de la configuration "default"
               set ::conf(eshel,instrument,config,$configId,$paramName) $::conf(eshel,instrument,config,default,$paramName)
            }
         }
      }
   }

   if { ! [ info exists conf($prefix,currentSequence) ] }  { set conf($prefix,currentSequence)   "Reference"   }

   #--- je cree deux exemples de sequences de reference
   if { [array names ::conf  eshel,instrument,reference,* ] == "" } {
      set ::conf(eshel,instrument,reference,reference_debut,name)  "Reference debut"
      set ::conf(eshel,instrument,reference,reference_debut,state) 1
      set ::conf(eshel,instrument,reference,reference_debut,actionList) [list [list biasSerie [list expNb 5]] [list darkSerie [list expTime 15 expNb 5]]  [list darkSerie [list expTime 600 expNb 4]] [list flatSerie [list expTime 15 expNb 8]] [list wait [list expTime 8 ]] [list tharSerie [list expTime 60 expNb 2]] ]
      set ::conf(eshel,instrument,reference,reference_flat_thar,name) "Reference flat thar"
      set ::conf(eshel,instrument,reference,reference_flat_thar,state) 0
      set ::conf(eshel,instrument,reference,reference_flat_thar,actionList) [list [list flatSerie [list expTime 10 expNb 5]] [list tharSerie [list expTime 10 expNb 5]] ]
   }

   #--- je cree les variables locales
   set private($visuNo,frm)            "$tkbase.eshel"
   set private($visuNo,objname) ""
   set private($visuNo,sequenceState) ""
   set private($visuNo,status) ""
   set private(comment) ""

   #--- Petit raccourci bien pratique
   set frm $private($visuNo,frm)

   #--- Frame principale de l'outil
   frame $frm -borderwidth 1 -relief groove

   #--- Logo
   image create photo eshelLogo -file [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory] "logoshelyak.gif"  ]
   Button $frm.logo -borderwidth 0 -image "eshelLogo" -command "::audace::Lance_Site_htm http://www.shelyak.com"
   pack $frm.logo  -side top -fill x
   DynamicHelp::add $frm.logo -text "http://www.shelyak.com"

   #--- Frame Acquisition
   TitleFrame $frm.acq -borderwidth 2 -relief groove -text "$caption(eshel,acquisition)"
      #--- bouton session
      button $frm.acq.session -text "$caption(eshel,session)" -height 2 \
         -borderwidth 3 -pady 6 -command "::eshel::session::run $private($visuNo,frm) $visuNo"
      pack $frm.acq.session -in [$frm.acq getframe] -side top -fill x

###      #--- Liste des sequences d'acquisition
###      ComboBox $frm.acq.sequence \
###         -width 4 -height [ llength $private($visuNo,sequenceNames) ] \
###         -relief sunken -borderwidth 1 -editable 0 \
###         -modifycmd "::eshel::adaptPanel $visuNo" \
###         -values $private($visuNo,sequenceNames)
###      pack $frm.acq.sequence -in [$frm.acq getframe] -side top -fill x
###      #--- je selectionne le mode
###      $frm.acq.sequence setvalue "@$::conf(eshel,currentSequenceNo)"

      #--- Liste des sequences d'acquisition (voir ::eshel::setSequenceList)
      ComboBox $frm.acq.sequence \
         -width 4  \
         -relief sunken -borderwidth 1 -editable 0 \
         -modifycmd "::eshel::adaptPanel $visuNo"
      pack $frm.acq.sequence -in [$frm.acq getframe] -side top -fill x

      #--- Nom de l'objet
      frame $frm.acq.object -borderwidth 2 -relief ridge
         label $frm.acq.object.lab1 -text $caption(eshel,objname) -justify left -anchor w
         pack  $frm.acq.object.lab1 -side left -fill none -padx 2
         ComboBox $frm.acq.object.combo \
            -width 10 -height [ llength $::conf(eshel,objectList) ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::eshel::private($visuNo,objname) \
            -validate all -validatecommand { ::eshel::validateString %W %V %P %s fits 1 68 ::eshel::private(error,objname) } \
            -modifycmd "::eshel::onModifyObject $visuNo" \
            -values $::conf(eshel,objectList)
         ###$frm.acq.object.combo.e configure -validate all -validatecommand { ::eshel::validateString %W %V %P %s fits 1 70 ::eshel::private(error,objname) }
          bind $frm.acq.object.combo.e <FocusOut> "::eshel::onModifyObject $visuNo"
         pack $frm.acq.object.combo -side left  -fill x -expand 1
      pack $frm.acq.object -in [$frm.acq getframe] -side top -fill x -expand 1
      #--- je selectionne la premiere valeur par defaut
      $frm.acq.sequence setvalue first

      #--- Temps de pose
      frame $frm.acq.exptime -borderwidth 2 -relief ridge
         label $frm.acq.exptime.lab1 -text $caption(eshel,exptime) -justify left -anchor w
         pack  $frm.acq.exptime.lab1 -side left -fill x -padx 2 -expand 1
         set list_combobox {0 0.5 1 3 5 10 15 30 60 120 180 300 600 900 }
         ComboBox $frm.acq.exptime.combo \
            -width 6  -height [ llength $list_combobox ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::conf(eshel,exptime) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s double 0 10000 ::eshel::private(error,exptime) } \
            -values $list_combobox
         pack $frm.acq.exptime.combo -side left -fill none -expand 0
      pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x

      #--- Nombre de poses
      frame $frm.acq.expnb -borderwidth 2 -relief ridge
         label $frm.acq.expnb.lab1 -text $caption(eshel,expnb) -justify left -anchor w
         pack  $frm.acq.expnb.lab1 -side left -fill x -padx 2 -expand 1
         set list_combobox [list 1 2 3 5 10 15 20 ]
         ComboBox $frm.acq.expnb.combo \
            -width 6 -height [ llength $list_combobox ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::conf(eshel,expnb) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 0 10000 ::eshel::private(error,expnb) } \
            -values $list_combobox
         pack $frm.acq.expnb.combo -side left  -fill none -expand 0
      pack $frm.acq.expnb -in [$frm.acq getframe] -side top -fill x

      #--- Binning
      frame $frm.acq.binning -borderwidth 2 -relief ridge
         label $frm.acq.binning.label -text $caption(eshel,binning) -justify left  -anchor w
         pack  $frm.acq.binning.label -side left -fill x -padx 2 -expand 1
         set binningList [list 1x1 ]
         ComboBox $frm.acq.binning.combo \
            -width 6  -height [ llength $binningList ] \
            -relief sunken -borderwidth 1 -editable 0 \
            -textvariable ::conf(eshel,binning) \
            -values $binningList
         pack $frm.acq.binning.combo -side left  -fill none -expand 0
      pack $frm.acq.binning -in [$frm.acq getframe] -side top -fill x

      #--- repeter
      frame $frm.acq.repeat -borderwidth 2 -relief ridge
         label $frm.acq.repeat.label -text $caption(eshel,repeat) -justify left -anchor w
         pack  $frm.acq.repeat.label -side left -fill x -padx 2 -expand 1
         set repeatList [list 1 2 3 5 10 20 100 1000 ]
         ComboBox $frm.acq.repeat.combo \
            -width 6  -height [ llength $repeatList ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::conf(eshel,repeat) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::private(error,repeat) } \
            -values $repeatList
         pack $frm.acq.repeat.combo -side right -fill none -expand 0
      pack $frm.acq.repeat -in [$frm.acq getframe] -side top -fill x

      #--- commentaire
      frame $frm.acq.comment -borderwidth 2 -relief ridge
         label $frm.acq.comment.label -text $caption(eshel,comment) -justify left -anchor w
         pack  $frm.acq.comment.label -side left -fill none -padx 2 -expand 0
         entry $frm.acq.comment.entry -textvariable ::eshel::private(comment) \
            -width 6 \
            -validate all -validatecommand { ::eshel::validateString %W %V %P %s fits 0 68 ::eshel::private(error,comment) }
         pack $frm.acq.comment.entry -side left -fill x -expand 1
      pack $frm.acq.comment -in [$frm.acq getframe] -side top -fill x

      #--- checkbox traitement automatique
      checkbutton $frm.acq.auto -text "$caption(eshel,processAuto)" \
         -variable ::conf(eshel,processAuto) \
         -command "::eshel::setProcessAuto"
      pack $frm.acq.auto -in [$frm.acq getframe] -fill x -padx 0 -pady 0

      #--- bouton go
      button $frm.acq.go -text "$caption(eshel,acq,go)" -height 2 \
        -borderwidth 3 -pady 6 -command "::eshel::onStartAcquisition $visuNo"
      pack $frm.acq.go -in [$frm.acq getframe] -fill x -padx 0 -pady 0

      #--- status
      label $frm.acq.status -textvariable ::eshel::private($visuNo,status)  -borderwidth 2 -relief ridge
      pack $frm.acq.status -in [$frm.acq getframe] -fill x -padx 0 -pady 0

   pack $frm.acq -side top -fill x -padx 2

   #--- Frame du traitement
   TitleFrame $frm.process -borderwidth 2 -relief groove -text "$caption(eshel,process)"
      button $frm.process.go -text "$caption(eshel,goProcess)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::run [winfo toplevel $private($visuNo,frm)] $visuNo"
      pack $frm.process.go -in [$frm.process getframe] -fill x -padx 0 -pady 0 -expand true

      #--- Profils
      button $frm.process.spectra -text "Images" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::showProfile"
      pack $frm.process.spectra -in [$frm.process getframe] -fill x -padx 2 -pady 2 -expand true
      #--- Aide
      button $frm.process.help -text "$caption(eshel,help)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command {
              ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
                 [::eshel::getPluginDirectory] [::eshel::getPluginHelp]
           }
      pack $frm.process.help -in [$frm.process getframe] -fill x -padx 2 -pady 2 -expand true
   pack $frm.process -side top -fill x -padx 2

   TitleFrame $frm.config -borderwidth 2 -relief groove -text "Administration"
      #--- Parametres instrument
      #button $frm.config.wizard -text "Assistant" -height 1 \
      #    -borderwidth 1 -padx 2 -pady 2 -command "::eshel::startWizard $visuNo"
      #pack $frm.config.wizard -in [$frm.config getframe] -fill x -padx 2 -pady 2 -expand true
      #--- Parametres instrument
      button $frm.config.instrument -text "$caption(eshel,instrument)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::instrumentgui::run [winfo toplevel $private($visuNo,frm)] $visuNo"
      pack $frm.config.instrument -in [$frm.config getframe] -fill x -padx 2 -pady 2 -expand true
      label $frm.config.version -text "eShel-[package present eshel]"
      pack $frm.config.version -in [$frm.config getframe] -fill x -padx 2 -pady 2 -expand true
   pack $frm.config -side bottom -fill x -padx 2

   #--- j'affiche la liste des sequences
   ::eshel::setSequenceList $visuNo

   #--- je mets a jour les widgets en fonction de la sequence courante
   ::eshel::adaptPanel $visuNo

   #--- je verifie les valeurs initiales
   $frm.acq.object.combo.e  validate
   $frm.acq.exptime.combo.e validate
   $frm.acq.expnb.combo.e   validate
   $frm.acq.comment.entry   validate
   $frm.acq.repeat.combo.e  validate
}

proc ::eshel::startWizard { visuNo } {
   variable private
   set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
   source "[ file join $dir wizard.tcl ]"
   source "[ file join $dir visu.tcl ]"
   source "[ file join $dir eshelfile.tcl ]"
   ::eshel::wizard::run [winfo toplevel $private($visuNo,frm)] $visuNo
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::eshel::startTool { visuNo } {
   variable private

   #--- j'affiche le panneau avec l'option expand=1 pour que le bouton d'administration soit tout a fait en bas)
   pack $private($visuNo,frm) -fill y -side top -expand 1

   #--- je m'abonne a la surveillance des changements de camera
   ::confVisu::addCameraListener $visuNo "::eshel::adaptPanel $visuNo"

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::eshel::configToolKeywords $visuNo

}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::eshel::stopTool { visuNo } {
   variable private

   #--- je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(eshel,keywordConfigName) ""

   #--- je supprime l'abonnement a la surveillance des changements de camera
   ::confVisu::removeCameraListener $visuNo "::eshel::adaptPanel $visuNo"

   #--- je masque le panneau
   pack forget $private($visuNo,frm)

}

#------------------------------------------------------------
# getNameKeywords
#    definit le nom de la configuration des mots cles FITS de l'outil
#    uniquement pour les outils qui configurent les mots cles selon des
#    exigences propres a eux
#------------------------------------------------------------
proc ::eshel::getNameKeywords { visuNo configName } {
   #--- Je definis le nom
   set ::conf(eshel,keywordConfigName) $configName
}

#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#------------------------------------------------------------
proc ::eshel::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(eshel,keywordConfigName)
   }

   #--- je selectionne les mots clefs optionnel a ajouter dans les images
   ::keyword::selectKeywords $visuNo $configName [list CRPIX1 CRPIX2 IMAGETYP OBJNAME SERIESID DETNAM INSTRUME TELESCOP CONFNAME OBSERVER SITENAME SITELONG SITELAT SWCREATE]

   #--- je selectionne la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $configName [list CRPIX1 CRPIX2 IMAGETYP OBJNAME SERIESID DETNAM INSTRUME TELESCOP CONFNAME ]

}

#------------------------------------------------------------
#  ::eshel::getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::eshel::getLabel { } {
   global caption

   return "$caption(eshel,title)"
}

#------------------------------------------------------------
#  adaptPanel
#    Cette procedure est appellee automatiquement quand on change de sequence dans la combobox
#      memorise l'index de la sequence selectionnee
#      affiche les widgets necessaire pour saisir les parametres de la sequence
#  param : aucun
#------------------------------------------------------------
proc ::eshel::adaptPanel { visuNo args } {
   variable private

   #--- je recupere l'index de la sequence
   set index [$private($visuNo,frm).acq.sequence getvalue]
   #--- je recupere le type de la sequence
   set sequenceType [lindex [lindex $private($visuNo,sequenceList) $index ] 0]
   #--- je recupere l'indentifiant de la sequence
   set sequenceId   [lindex [lindex $private($visuNo,sequenceList) $index ] 1]
   #--- je recupere le nom de la sequence
   set ::conf(eshel,currentSequenceId) $sequenceId

   set frm  $private($visuNo,frm)
   set sequenceUseBinning 0

   #--- l'utilisateur peut choisir une autre sequence
   $frm.acq.sequence.e configure -state normal
   $frm.acq.sequence.a configure -state normal

   switch $sequenceType {
      objectSequence  {
         #--- l'utilisateur peut choisir le nom, le temps de pose, le nombre de poses
         pack $frm.acq.object  -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         pack $frm.acq.expnb   -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         pack $frm.acq.repeat  -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         set sequenceUseBinning 0
      }
      referenceSequence  {
         #--- l'utilisateur peut choisir rien
         pack forget $frm.acq.object
         pack forget $frm.acq.exptime
         pack forget $frm.acq.expnb
         pack forget $frm.acq.repeat
         set sequenceUseBinning 0
      }
      previewSequence {
         switch $sequenceId  {
            objectPreview  {
               #--- l'utilisateur peut choisir le nom, le temps de pose et le binning
               pack $frm.acq.object  -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack forget $frm.acq.expnb
               set sequenceUseBinning 1
               pack $frm.acq.binning -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack forget $frm.acq.repeat
            }
            darkPreview -
            flatPreview -
            tharPreview -
            tungstenPreview {
               #--- l'utilisateur peut choisir le temps de pose et le binning
               pack forget $frm.acq.object
               pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack forget $frm.acq.expnb
               pack forget $frm.acq.repeat
               set sequenceUseBinning 1
            }
            biasPreview {
               #--- l'utilisateur peut choisir le binning
               pack forget $frm.acq.object
               pack forget $frm.acq.exptime
               pack forget $frm.acq.expnb
               pack forget $frm.acq.repeat
               set sequenceUseBinning 1
            }
            default {
               #--- l'utilisateur peut choisir rien
               pack forget $frm.acq.object
               pack forget $frm.acq.exptime
               pack forget $frm.acq.repeat
               set sequenceUseBinning 0
            }
         }
      }
   }

   if { $sequenceUseBinning == 1 } {
      #--- je recupere la liste des binning de la camera
      set camItem [::confVisu::getCamItem $visuNo]
      #--- widget de binning
      if { [ ::confCam::getPluginProperty $camItem hasBinning ] == 1 } {
         set binningList [ ::confCam::getPluginProperty $camItem binningList ]
         $private($visuNo,frm).acq.binning.combo configure -values $binningList -height [llength $binningList ]

         #--- je verifie que le binning preselectionne existe dans la liste
         if { [lsearch $binningList $::conf(eshel,binning)] == -1 } {
            #--- si le binning n'existe pas je selectionne la premiere valeur par defaut
            set  ::conf(eshel,binning) [lindex $binningList 0]
         }
         #--- j'affiche la frame du binning
         pack $frm.acq.binning -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
      } else {
         #--- je masque la frame du binning
         pack forget $frm.acq.binning
      }
   } else {
      #--- je masque la frame du binning
      pack forget $frm.acq.binning
   }

   if { $::conf(eshel,enableComment)== 1 } {
      #--- j'affiche la zone de saisie des commentaires
      pack $frm.acq.comment -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
   } else {
      #--- je masque la frame du binning
      pack forget $frm.acq.comment
   }

}

#------------------------------------------------------------
#  onModifyObject
#    ajoute le nom de l'objet selectionne en tete dans la liste de la combobox
#    et supprime le onzieme objet si necessaire
#    cette procedure est appellee automatiquement quand on change le nom d'objet dans la combobox
#  param : aucun
#------------------------------------------------------------
proc ::eshel::onModifyObject { visuNo } {
   variable private

   set index [$private($visuNo,frm).acq.object.combo getvalue]

   #--- j'ajoute cet objet en tete de liste si c'est un nouvel objet
   if { $index == -1 && $private($visuNo,objname) != "" } {
      set ::conf(eshel,objectList) [linsert $::conf(eshel,objectList) 0 $private($visuNo,objname)]
   }

   if { [llength $::conf(eshel,objectList) ] > 10 } {
      #--- je supprime le dernier element s'il y a plus de 10 elements
      set ::conf(eshel,objectList) [lreplace $::conf(eshel,objectList) end end]
   }
   $private($visuNo,frm).acq.object.combo configure -values $::conf(eshel,objectList)
   ###console::disp "objname= $private($visuNo,objname)  \n"
   $private($visuNo,frm).acq.object.combo.e validate

}

#------------------------------------------------------------
#  onStartAcquisition
#    Cette procedure est appelee quand l'utilsateur clique sur le bouton GO
#    lance la sequence d'acquisition
# Parameters
#    visuNo   : numero de la visu
#------------------------------------------------------------
proc ::eshel::onStartAcquisition { visuNo args } {
   variable private

   #--- je recupere l'index de la sequence
   set index [$private($visuNo,frm).acq.sequence getvalue]
   #--- je recupere le nom et le type de la sequence
   set sequenceType [lindex [lindex $private($visuNo,sequenceList) $index ] 0]
   set sequenceId   [lindex [lindex $private($visuNo,sequenceList) $index ] 1]
   set sequenceName [lindex [lindex $private($visuNo,sequenceList) $index ] 2]

   #--- j'assemble les series de la sequence
   set actionList ""
   set binning    ""
   set repeat     1
   set comment    ""
   switch $sequenceType {
      objectSequence {
         #--- je verifie que le nom de l'objet est renseigne
         #if {  $private($visuNo,objname) == "" } {
         #    console::affiche_erreur "$::caption(eshel,acquisition,errorObject) \n"
         #   tk_messageBox -message "$::caption(eshel,acquisition,errorObject)" -icon error -title $::caption(eshel,title)
         #   return
         #}

         #--- je verifie que le nom de l'obet est correct
         if { [info exists ::eshel::private(error,objname)] } {
            set errorMessage "$::caption(eshel,objname): $private(error,objname)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }

         #--- j'ajoute une serie de plusieurs images
         set actionType  "objectSerie"
         set actionParam [list expTime $::conf(eshel,exptime) expNb $::conf(eshel,expnb) objectName "$private($visuNo,objname)" binning [::eshel::instrument::getConfigurationProperty "binning"] ]
         set actionList  [list [list $actionType $actionParam]]
         set repeat $::conf(eshel,repeat)
         set sequenceName $private($visuNo,objname)

         #--- je verifie le temps de pose
         if { [info exists ::eshel::private(error,exptime)] } {
            set errorMessage "$::caption(eshel,exptime): $private(error,exptime)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }

         #--- je verifie le nombre de poses
         if { [info exists ::eshel::private(error,expnb)] } {
            set errorMessage "$::caption(eshel,expnb): $private(error,expnb)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }
         #--- je verifie le nombre de repetitions
         if { [info exists ::eshel::private(error,repeat)] } {
            set errorMessage "$::caption(eshel,repeat): $private(error,repeat)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }
      }
      referenceSequence {
         #--- je recupere la liste des actions predefinie
         set actionList  $::conf(eshel,instrument,reference,$sequenceId,actionList)
      }
      previewSequence {
         set binning [list [string range $::conf(eshel,binning) 0 0] [string range $::conf(eshel,binning) 2 2]]

         #--- je verifie le temps de pose
         if { [info exists ::eshel::private(error,exptime)] } {
            set errorMessage "$::caption(eshel,exptime): $private(error,exptime)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }

         switch $sequenceId  {
            objectPreview {
               #--- je verifie que le nom de l'obet est correct
               if { [info exists ::eshel::private(error,objname)] } {
                  set errorMessage "$::caption(eshel,objname): $private(error,objname)"
                  tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
                  return
               }

               #--- j'ajoute une serie d'une image avec le temps de pose et le nom de l'objet choisi par l'utilisateur
               set actionType  "objectSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 objectName $private($visuNo,objname) binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            darkPreview {
               set actionType  "darkSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            flatfieldPreview {
               set actionType  "flatfieldSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $::conf(eshel,binning) ]
               set actionList  [list [list $actionType $actionParam]]
            }
            flatPreview {
               set actionType  "flatSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $::conf(eshel,binning) ]
               set actionList  [list [list $actionType $actionParam]]
            }
            tharPreview {
               set actionType  "tharSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            tungstenPreview {
               #--- j'ajoute une serie d'une image avec le temps de pose choisi par l'utilisateur
               set actionType  "tungstenSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            biasPreview {
               #--- j'ajoute une serie d'une image
               set actionType  "biasSerie"
               set actionParam [list expTime 0 expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
         } ;#--- fin switch sequenceName
      }
   } ;#--- fin switch sequenceType

   if { $::conf(eshel,enableComment)== 1  } {
      #--- je verifie que le commentaire est correct
      if { [info exists ::eshel::private(error,comment)] } {
         set errorMessage "$::caption(eshel,comment): $private(error,comment)"
         tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
         return
      }
      set comment $private(comment)
   }

   #--- je verrouille les widgets de la fenetre principale
   $private($visuNo,frm).acq.session configure -state disabled
   $private($visuNo,frm).acq.sequence.e configure -state disabled
   $private($visuNo,frm).acq.sequence.a configure -state disabled
   $private($visuNo,frm).acq.object.combo.e configure -state disabled
   $private($visuNo,frm).acq.object.combo.a configure -state disabled
   $private($visuNo,frm).acq.exptime.combo.e configure -state disabled
   $private($visuNo,frm).acq.exptime.combo.a configure -state disabled
   $private($visuNo,frm).acq.expnb.combo.e configure -state disabled
   $private($visuNo,frm).acq.expnb.combo.a configure -state disabled
   $private($visuNo,frm).acq.binning.combo.e configure -state disabled
   $private($visuNo,frm).acq.binning.combo.a configure -state disabled
   $private($visuNo,frm).acq.comment.entry configure -state disabled
   $private($visuNo,frm).acq.repeat.combo.e configure -state disabled
   $private($visuNo,frm).acq.repeat.combo.a configure -state disabled
      #--- je transforme le bouton GO en bouton STOP
   $private($visuNo,frm).acq.go configure -text $::caption(eshel,acq,stop) -command "::eshel::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::eshel::stopAcquisition $visuNo"

   #--- je lance la sequence d'acquisition
   set private($visuNo,sequenceState) "busy"

   set catchResult [ catch {
      ::eshel::acquisition::startSequence $visuNo $actionList $sequenceName $repeat $comment
   }]

   if { $catchResult != 0 } {
      if { $::errorCode != 5 } {
         ::tkutil::displayErrorInfo $::caption(eshel,title)
      }
   }

   set private($visuNo,sequenceState) ""

   #--- je deverrouille les widgets de la fenetre principale
   $private($visuNo,frm).acq.session configure -state normal
   $private($visuNo,frm).acq.sequence.e configure -state normal
   $private($visuNo,frm).acq.sequence.a configure -state normal
   $private($visuNo,frm).acq.object.combo.e configure -state normal
   $private($visuNo,frm).acq.object.combo.a configure -state normal
   $private($visuNo,frm).acq.exptime.combo.e configure -state normal
   $private($visuNo,frm).acq.exptime.combo.a configure -state normal
   $private($visuNo,frm).acq.expnb.combo.e configure -state normal
   $private($visuNo,frm).acq.expnb.combo.a configure -state normal
   $private($visuNo,frm).acq.binning.combo.e configure -state normal
   $private($visuNo,frm).acq.binning.combo.a configure -state normal
   $private($visuNo,frm).acq.comment.entry configure -state normal
   $private($visuNo,frm).acq.repeat.combo.e configure -state normal
   $private($visuNo,frm).acq.repeat.combo.a configure -state normal
   ::eshel::adaptPanel $visuNo
   #--- Je supprime l'association de la commande d'arret avec la touche ESCAPE
   bind all <Key-Escape> ""
   #--- je transforme le bouton STOP en bouton GO
   $private($visuNo,frm).acq.go configure -text $::caption(eshel,acq,go) -state normal -command "::eshel::onStartAcquisition $visuNo"
   set private($visuNo,sequenceState) ""
}

#------------------------------------------------------------
# stopAcquisition
#    Cette procedure est appelee quand l'utilsateur clique sur le bouton STOP
#    interrompt les acquisitions
#
# return :
#    rien
#------------------------------------------------------------
proc ::eshel::stopAcquisition { visuNo  } {
   variable private

   if { $private($visuNo,sequenceState) != "" } {
      #--- je desactive le bouton en attendant que l'aquisition soit completement terminee
      $private($visuNo,frm).acq.go configure -state disabled
      ::eshel::acquisition::stopSequence $visuNo
   } else {
      set private($visuNo,sequenceState) ""
   }
}

#------------------------------------------------------------
#  setStatus
#    affiche le status
#  Parameters
#    visuNo : numero de la visu
#    value  : valeur a afficher
#------------------------------------------------------------
proc ::eshel::setStatus { visuNo value} {
   variable private

   set private($visuNo,status) $value
}

#------------------------------------------------------------
#  setSequenceList
#    affiche les sequences dasn la combobox
#      avec les 7 sequences predefinies et les sequences de reference
#
#  la variable private($visuNo,sequenceList) contient une liste de triplets :
#     [list  [list sequenceType sequenceId sequenceName ] [list sequenceType sequenceId sequenceName] ... ]
#  Parameters
#    visuNo : numero de la visu
#    value  : valeur a afficher
#------------------------------------------------------------
proc ::eshel::setSequenceList { visuNo } {
   variable private

   #---- je construis la liste des sequences  (type sequence, nom sequence)
   set private($visuNo,sequenceList) ""

   #--- j'ajoute la sequence "object"
   lappend private($visuNo,sequenceList) [list "objectSequence" "object" $::caption(eshel,acquisition,objectSequence) ]

   #--- j'ajoute les sequences de reference
   foreach sequencePath [array names ::conf eshel,instrument,reference,*,name] {
      set sequenceId [lindex [split $sequencePath "," ] 3]
      set sequenceName   $::conf(eshel,instrument,reference,$sequenceId,name)
      set sequenceState  $::conf(eshel,instrument,reference,$sequenceId,state)
      if { $sequenceState == 1 } {
         lappend private($visuNo,sequenceList) [list "referenceSequence" $sequenceId $sequenceName  ]
      }
   }

   #--- j'ajoute les sequences "preview"
   foreach sequenceId [list objectPreview tharPreview flatPreview darkPreview biasPreview tungstenPreview]  {
      lappend private($visuNo,sequenceList) [list "previewSequence" $sequenceId $::caption(eshel,acquisition,$sequenceId)]
   }

   #--- je prepare la liste des noms des sequences
   set indexCurrentSequence -1
   set counter 0
   set nameList ""
   foreach item $private($visuNo,sequenceList) {
      #--- je recupere le nom de la sequence
      lappend nameList [lindex $item 2]
      #--- je repere l'index correspondant a l'indentifiant de la sequence courante
      if { [lindex $item 1] == $::conf(eshel,currentSequenceId) } {
         set indexCurrentSequence $counter
      }
      incr counter
   }
   #--- je copie la liste des noms des sequences dans la combobox
   $private($visuNo,frm).acq.sequence configure -values $nameList -height $counter

   #--- je selectionne le nom de la sequence courante
   if { $indexCurrentSequence != -1 } {
      #--- je selectionne la sequence courante
      $private($visuNo,frm).acq.sequence setvalue "@$indexCurrentSequence"
   } else {
      #--- la sequence courante n'existe pas dans la liste
      #--- je selectionne le premier item
      $private($visuNo,frm).acq.sequence setvalue "@0"
   }
}

#------------------------------------------------------------
#  setProcessAuto
#     lance le traitement automatique
#
#  param : aucun
#------------------------------------------------------------
proc ::eshel::setProcessAuto { } {

   ::eshel::processgui::setProcessAuto
}

#------------------------------------------------------------
# checkDirectory
#   verifie l'existance des repertoires
#------------------------------------------------------------
proc ::eshel::checkDirectory { } {

   #--- je verifie que le repertoire des fichiers bruts existe
   if {  [file exists $::conf(eshel,rawDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,rawDirectory)]
   }

   if {  [file exists $::conf(eshel,referenceDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,referenceDirectory)]
   }

   if {  [file exists $::conf(eshel,tempDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,tempDirectory)]
   }

   if {  [file exists $::conf(eshel,archiveDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,archiveDirectory)]
   }

   if {  [file exists $::conf(eshel,processedDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,processedDirectory)]
   }
}

#------------------------------------------------------------
# showRawDirectory
#   affiche le repertoire des images brutes
#------------------------------------------------------------
proc ::eshel::showRawDirectory { } {

   #--- je verifie que le repertoire des images brutes existe
   ::eshel::checkDirectory

   set visuDir [::confVisu::create]
   #--- je selectionne l'outil visionneuse bis
   confVisu::selectTool $visuDir ::eshelvisu
   #--- je pointe le repertoire des images brutes
   set ::eshelvisu::localTable::private($visuDir,directory)  $::conf(eshel,rawDirectory)
   #--- j'affiche le contenu du repertoire
   ::eshelvisu::localTable::fillTable $visuDir
}

#------------------------------------------------------------
# showProfile
#   affiche une fenetre pour afficher des profils
#------------------------------------------------------------
proc ::eshel::showProfile { } {
   #--- j'ouvre une fenetre pour afficher des profils
   ##set profileNo [::profilegui::run ]
   set visuDir [::confVisu::create]
   #--- je selectionne l'outil visionneuse bis
   #confVisu::selectTool $visuDir ::visio2
   #--- je selectionne l'outil eShel Visu
   confVisu::selectTool $visuDir ::eshelvisu
   #--- je pointe le repertoire des images brutes
   set ::eshelvisu::localTable::private($visuDir,directory) $::conf(eshel,mainDirectory)
   #--- j'affiche le contenu du repertoire
   ::eshelvisu::localTable::fillTable $visuDir
}

##------------------------------------------------------------
# showObjectProfile
# affiche le profil P_FULL d'un objet dans une nouvelle visu
#
# Le fichier est recherche dans le repertoire des profils traites.
#
# @param fileName nom du fichier
# @return rien
# @public
#------------------------------------------------------------
proc ::eshel::showObjectProfile { fileName } {
   #--- j'ouvre une fenetre pour afficher des profils
   set profileVisu [::confVisu::create]
   #--- je selectionne l'outil visionneuse bis
   #confVisu::selectTool $profileVisu ::visio2
   #--- je selectionne l'outil eShel Visu
   confVisu::selectTool $profileVisu ::eshelvisu
   #--- je pointe le repertoire des images brutes
   set ::eshelvisu::localTable::private($profileVisu,directory) $::conf(eshel,processedDirectory)
   #--- j'affiche le contenu du fichier
   :::eshelvisu::localTable::refresh $profileVisu $fileName "P_1C_FULL"
}

##------------------------------------------------------------
# setDirectory
#    selectionn le repertoire des images
#    et cree les sous reperoires raw, temp, archive reference et processed
#    s'ils n'exitent pas deja
#
# @param mainDirectory  repertoire principal
# @return none
#------------------------------------------------------------
proc ::eshel::setDirectory { mainDirectory } {

   if { $mainDirectory != "" } {
      #--- je normalise le nom du repertoire
      set mainDirectory [file normalize $mainDirectory]

      #--- je cree les sous repertoires
      set catchResult [ catch {
         set rawDirectory "$mainDirectory/raw"
         set tempDirectory "$mainDirectory/temp"
         set archiveDirectory "$mainDirectory/archive"
         set referenceDirectory "$mainDirectory/reference"
         set processedDirectory "$mainDirectory/processed"

         file mkdir "$mainDirectory"
         file mkdir "$rawDirectory"
         file mkdir "$tempDirectory"
         file mkdir "$archiveDirectory"
         file mkdir "$referenceDirectory"
         file mkdir "$processedDirectory"

         #--- je memorise les noms des sous repertoires
         set ::conf(eshel,mainDirectory)        $mainDirectory
         set ::conf(eshel,rawDirectory)         $rawDirectory
         set ::conf(eshel,referenceDirectory)   $referenceDirectory
         set ::conf(eshel,processedDirectory)   $processedDirectory
         set ::conf(eshel,archiveDirectory)     $archiveDirectory
         set ::conf(eshel,tempDirectory)        $tempDirectory
         }]

      if { $catchResult == 1 } {
         error $::errorInfo
      }
   } else {
      error $::caption(eshel,session,directoryError)
   }
}

##------------------------------------------------------------
#  ajoute une trace dans le fichier de trace
#
# @param fileName nom du fichier
# @return rien
# @public
#------------------------------------------------------------
proc ::eshel::logFile { message color } {
   variable hLogFile

   if { $::conf(eshel,enabledLogFile) == 0 } {
      return
   }

   set catchResult [ catch {
      set fileName [file join $::conf(eshel,mainDirectory) $::conf(eshel,logFileName) ]
      set hLogFile [open $fileName "a+" ]

      #--- j'ajoute la trace dans le fichier
      set date [clock format [clock seconds] -gmt 1 -format "%Y-%m-%dT%H:%M:%S"]
      puts $hLogFile  "<font color=$color>"
      #--- je remplce les retours cahriots par <BR>
      set message [string map { "\n" "<BR>\n" } $message]
      puts $hLogFile "$date $message"
      puts $hLogFile  "</font>"
      close  $hLogFile
   } ]

   if { $catchResult == 1 } {
      error $::errorInfo
   }
}

#------------------------------------------------------------
# ouvre le fichier de trace
#
# @return rien (remonte les exceptions)
# @public
#------------------------------------------------------------
proc ::eshel::openLogFile { } {
   variable private

   #--- j'ouvre le fichier de tarce
   ##set fileName [file join $::conf(eshel,mainDirectory) $::conf(eshel,logFileName) ]
   ##set private(hLogFile) [open $fileName "a+" ]
}

#------------------------------------------------------------
# ferme le fichier de trace
#
# @return rien (remonte les exceptions)
# @public
#------------------------------------------------------------
proc ::eshel::closeLogFile { } {
   variable private

}

## validateNumber --------------------------------------------------------------
#    verifie la valeur saisie dans un un widget
#    cette verification est activee avec l'option  -validatecommand { ::eshel::instrumentgui::validateNumber ... }
#
# <br>Exemple
# <br>  -validatecommand { ::eshel::instrumentgui::validateFloat %W %V %P %s  "numRef" integer -360 360 }
#
# @param  win
# @param  event
# @param  X
# @param  oldX
# @param  min
# @param  max
# @return
#   - 1 si OK
#   - 0 si erreur
# @public
#----------------------------------------------------------------------------
proc ::eshel::validateNumber { win event X oldX class min max { errorVariable "" }} {
   variable widget

   if { $event == "key" || $event == "focusout" || $event == "forced"  } {
      set weakCheck [expr [string is $class -failindex charIndex $X] ]
      # if weak check fails, continue with old value
      if {! $weakCheck} {
         set strongCheck $weakCheck
         if { $errorVariable != "" } {
            set $errorVariable  [format $::caption(eshel,badCharacter) "\"$X\"" "\"[string range $X $charIndex $charIndex]\"" ]
         }
      } else {
         # Make sure min<=max
         if {$min > $max} {
            set tmp $min; set min $max; set max $tmp
         }
         ###set strongCheck [expr {$weakCheck && ($X >= $min) && ($X <= $max)}]
         #--- je verifie la plage
         if {  $X < $min } {
            if { $errorVariable != "" } {
               set $errorVariable  [format $::caption(eshel,numberTooSmall) $X $min ]
            }
         } elseif {  $X > $max } {
            if { $errorVariable != "" } {
               set $errorVariable  [format $::caption(eshel,numberTooGreat) $X $max ]
            }
         } else {
            if { $errorVariable != "" } {
               if { [info exists $errorVariable] } {
                  unset $errorVariable
               }
            }
         }
         set strongCheck [expr {$weakCheck && ($X >= $min) && ($X <= $max)}]
      }
      if { $strongCheck == 0 } {
         #--- j'affiche en inverse video
         ###$win configure -bg $::audace(color,entryTextColor) -fg $::audace(color,entryBackColor)
         $win configure -bg $::audace(color,entryBackColor2) -fg $::audace(color,entryTextColor)
      } else {
         #--- j'affiche normalement
         $win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
      }
      return 1
   } else {
       return 1
   }

}

## ----------------------------------------------------------------------------
# validateString
#    verifie une de caracteres saisie dans  un widget
#    cette verification est activee avec l'option  -validatecommand { ::eshel::instrumentgui::validateString ... }
#
# <br>Exemple
# <br>  -validatecommand { ::eshel::instrumentgui::validateFloat %W %V %P %s  "numRef" integer -360 360 }
#
# @param  win
# @param  event evenement sur le widget (key, focusout)
# @param  X  valeur apres  l'evenement
# @param  oldX valeur avant  l'evenement
# @param  class classe de la valeur attendue (fits, )
# @param  minLength longueur minimale de la chaine
# @param  maxLength longueur maximale de la chaine
# @param  errorVariable  nom de la variable d'erreur associee au widget
# @return
#   - 1 si OK
#   - 0 si erreur
# @private
#----------------------------------------------------------------------------
proc ::eshel::validateString { win event X oldX class minLength maxLength errorVariable} {
   variable widget

   if { $event == "key" || $event == "focusout" || $event == "forced" } {
      if { $class == "fits" } {
         set weakCheck [expr [string is ascii -failindex charIndex $X] ]
         ###set weakCheck [expr [[regexp -all {[\u0000-\u0029]|[\u007F-\u00FF]} $X ] != 0 ] ]
      } else {
         set weakCheck [expr [string is $class -failindex charIndex $X] ]
      }
      # if weak check fails, continue with old value
      if {! $weakCheck} {
         set strongCheck $weakCheck
         set $errorVariable  [format $::caption(eshel,badCharacter) "\"$X\"" "\"[string range $X $charIndex $charIndex]\"" ]
      } else {
         # Make sure min<=max
         if {$minLength > $maxLength} {
            set tmp $minLength; set minLength $maxLength; set maxLength $tmp
         }
         #--- je verifie la longueur
         set xLength [string length $X]
         if {  $xLength < $minLength } {
            set $errorVariable [format $::caption(eshel,stringTooShort) "\"$X\"" $minLength]
            set strongCheck 0
         } elseif {  $xLength > $maxLength } {
            set $errorVariable [format $::caption(eshel,stringTooLarge) "\"$X\"" $maxLength]
            set strongCheck 0
         } else {
            if { [info exists  $errorVariable] } {
               unset $errorVariable
            }
            set strongCheck 1
         }
      }

      if { $strongCheck == 0 } {
         #--- j'affiche en inverse video
         ##$win configure -bg $::audace(color,entryTextColor) -fg $::audace(color,entryBackColor)
         $win configure -bg $::audace(color,entryBackColor2) -fg $::audace(color,entryTextColor)
      } else {
         #--- j'affiche normalement
         $win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
      }
      return 1
   } else {
       return 1
   }

}

