#
# Fichier : instrument.tcl
# Description : commande des instruments de l'outil eShel
# Auteur : Michel PUJOL
# Mise a jour $Id: instrument.tcl,v 1.1 2009-11-07 08:13:07 michelpujol Exp $
#

namespace eval ::eshel::instrument {

}

##------------------------------------------------------------
# Retourne la liste des configurations
#
# Exemple : { defaut {T60 Pic du Midi } {Saint Veran } }
# Remarque : cette procedure complete les proprietes de chaque configuration
#
# @return liste de configuration
# @public
#------------------------------------------------------------
proc ::eshel::instrument::getConfigurationList { } {
   #--- Liste des configurations
   set configList [list]
   foreach configPath [array names ::conf eshel,instrument,config,*,configName] {
      set configId [lindex [split $configPath "," ] 3]
      lappend configList $::conf(eshel,instrument,config,$configId,configName)
   }
   #--- je trie par ordre alphabetique (l'option -dictionary est equivalente a nocase)
   return [lsort -dictionary $configList ]
}


#------------------------------------------------------------
# getCurrentConfig
#  retourne le nom de la configuration courante
#
# Parameters :
#    rien
# Return
#    identifiant de la configuration
#------------------------------------------------------------
proc ::eshel::instrument::getCurrentConfig { } {

   set configId $::conf(eshel,currentInstrument)
   return $::conf(eshel,instrument,config,$configId,configName)

}

#------------------------------------------------------------
# setCurrentConfig
#  selectionne la configuration courante
#
# Parameters :
#    nom de la configuration
# Return
#    rien
#------------------------------------------------------------
proc ::eshel::instrument::setCurrentConfig { } {

   #--- je verifie qu'il n'y a pas d'acqusition en cours
   if { [::eshel ::acquisition::getCurrentSeriesID] != "" } {
      error $caption(eshel,instrument,errorBusyConfig)
   }


   #--- je verifie qu'il n'y a pas de traitement en cours


   return $::conf(eshel,currentInstrument)
}


##------------------------------------------------------------
#  retourne une propriete de la configuration courante
# Liste des prorietes d'une configuration:
#  width
#  alpha
#  otherBit
#  flatBit
#  offsetNb
#  tharEnabled
#  cosmicThreshold
#  threshold
#  cosmicEnabled
#  height
#  cameraName
#  focale
#  grating
#  minOrder
#  wideOrder
#  spectroSerie
#  x1
#  x2
#  y1
#  y2
#  telescopeName
#  binning
#  tharNb
#  offsetExposure
#  darkEnabled
#  darkNb
#  calibIter
#  flatExposure
#  currentSequence
#  offsetEnabled
#  hotPixelEnabled
#  gamma
#  neon,bit
#  name
#  orderDefinition
#  tharExposure
#  pixelSize
#  flat,bit
#  refX
#  refY
#  refLambda
#  darkExposure
#  flatEnabled
#  spectroName
#  neonEnabled
#  neonNb
#  lineList
#  wideSky
#  flatNb
#  spectrograhLink
#  tharBit
#  refNum
#  stepOrder
#  mirror,bit
#  cameraLabel
#  configName
#  cameraBinning
#  boxWide
#  hotPixelList
#  neonExposure
#  thar,bit
#  cameraNamespace
#  maxOrder
#  responseOption
#  responseFileName
#
#
# @param propertyName nom de la propriete
# @return valeur de la propriete , ou une exception si la propriete n'existe pas
#------------------------------------------------------------
proc ::eshel::instrument::getConfigurationProperty { propertyName } {
   variable private

   set configId $::conf(eshel,currentInstrument)
   return $::conf(eshel,instrument,config,$configId,$propertyName)
}

##------------------------------------------------------------
#  retourne une propriete de la configuration courante
#
# @param propertyName : nom de la propriete
# @param propertyValue : valeur de la propriete
# @return rien
#------------------------------------------------------------
proc ::eshel::instrument::setConfigurationProperty { propertyName propertyValue} {
   variable private

   set configId $::conf(eshel,currentInstrument)
   set ::conf(eshel,instrument,config,$configId,$propertyName) $propertyValue
}


#------------------------------------------------------------
# getConfigIdentifiant
#   retourne l'identifiant d'une configuration  en fonction de son nom
# Parameters
#   configName : nom de la configuration
# Return :
#   identifiant de la configuration
#------------------------------------------------------------
proc ::eshel::instrument::getConfigIdentifiant { configName } {
   variable private

   #--- je fabrique l'identifiant a partie du nom en replacant les caracteres interdits pas un "_"
   set configId ""
   for { set i 0 } { $i < [string length $configName] } { incr i } {
      set c [string index $configName $i]
      if { [string is wordchar $c ] == 0 } {
         #--- je remplace le caractere par underscore, si le caractere n'est pas une lettre , un chiffre ou underscore
         set c "_"
      }
      append configId $c
   }
   return $configId
}

## importConfig------------------------------------------------------------
# importe une configuration a partir d'un fichier XML
#   retourne l'identifiant d'une configuration  en fonction de son nom
# @param fileName nom du fichier XML
# @param configName nom du fichier XML
# @return parametres de la config dans une liste de couples paramName,paramValue
# @public
#------------------------------------------------------------
proc ::eshel::instrument::importConfig { fileName } {
   variable private

   set hFile ""
   set paramList ""

   set catchResult [ catch {
      #--- je lis le fichier
      set hfile [open "$fileName" r]
      set contents [read $hfile]
      close $hfile
      set hfile ""
      #--- j'analyse le fichier
      set configDom [::dom::tcl::parse $contents]
      set configNode [::dom::tcl::document cget $configDom -documentElement]
      set paramNode [lindex [set [::dom::element getElementsByTagName $configNode "PARAMS" ]] 0]

      #--- je lis les parametres , et je les completes avec les valeurs par defaut s'il manquent
      foreach { defautParamName defautlParamValue } [array get ::conf eshel,instrument,config,default,*] {
         #--- je recupere le nom du parametre
         set paramName [lindex [split $defautParamName "," ] 4]
         set attributeNode [::dom::element getAttribute $paramNode $paramName]
         if { $attributeNode != "" } {
            #--- je recupere la valeur de la config importee
            set paramValue [::dom::element getAttribute $paramNode $paramName]
            lappend paramList $paramName $paramValue
         } else {
            lappend paramList $paramName $defautlParamValue
         }
      }
   }]

   if { $catchResult ==1 } {
      if { $hFile != "" } {
         close $hFile
      }
      error $::errorInfo
   }

   return $paramList
}

## importFitsConfig------------------------------------------------------------
# importe une configuration a partir d'une image de caliration
#
# @param fileName nom du fichier XML
# @param configName nom du fichier XML
# @return parametres de la config dans une liste de couples paramName,paramValue
# @public
#------------------------------------------------------------
proc ::eshel::instrument::importCalibrationConfig { fileName } {
   variable private

   set hFile ""
   set paramList ""

   set catchResult [ catch {
      #--- j'ouvre l'image en mode lecture
      set hFile [fits open $fileName 0]
      set nbHdu [$hFile info nhdu]

      #--- je recupere les mots clefs du hdu PRIMARY
      $hFile move 1
      set param(configName)   [getKeyword $hFile CONFNAME]
      set param(spectroName)  [getKeyword $hFile INSTRUME]
      set param(binning)      [list [getKeyword $hFile BIN1 ] [getKeyword $hFile BIN2 ] ]
      set param(cameraName)   [getKeyword $hFile DETNAM]
      set param(width)        [getKeyword $hFile NAXIS1]
      set param(height)       [getKeyword $hFile NAXIS2]
      set param(telescopeName) [getKeyword $hFile TELESCOP]

      set found 0
      for { set i 1 } { $i <= $nbHdu && $found == 0 } { incr i } {
         $hFile move $i
         if { $i == 1 } {
            set hduName  "PRIMARY"
         } else {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         }
         if { $hduName == "ORDERS" } {
            set found  1
         }
      }
      if { $found == 0 } {
         error "ORDERS HDU not found"
      }

      #--- info spectro
      set param(minOrder)  [getKeyword $hFile MIN_ORDER]
      set param(maxOrder)  [getKeyword $hFile MAX_ORDER]
      set param(alpha)     [getKeyword $hFile ALPHA]
      set param(gamma)     [getKeyword $hFile GAMMA]
      set param(focale)    [getKeyword $hFile FOCLEN]
      set param(grating)   [getKeyword $hFile M]
      set param(pixelSize)  [getKeyword $hFile PIXEL]
      set param(pixelSize)  [getKeyword $hFile PIXEL]
      ###set param( )  [getKeyword $hFile DXREF]

      #--- info process
      set param(refNum)    [getKeyword $hFile REF_NUM]
      set param(refX)      [getKeyword $hFile REF_X]
      set param(refY)      [getKeyword $hFile REF_Y]
      set param(refLambda) [getKeyword $hFile REF_L]
      set param(threshold) [getKeyword $hFile THRESHOL]
      set param(stepOrder) [getKeyword $hFile Y_STEP]
      set param(boxWide)   [lindex [lindex [$hFile get table wide_x 1] 0] 0]
      set param(wideOrder) [lindex [lindex [$hFile get table wide_y 1] 0] 0]
      set param(wideSky)   [lindex [lindex [$hFile get table wide_sky 1] 0] 0]
      set param(orderDefinition) [$hFile get table [list order min_x max_x slant] ]

      set found 0
      for { set i 1 } { $i <= $nbHdu && $found == 0 } { incr i } {
         $hFile move $i
         if { $i == 1 } {
            set hduName  "PRIMARY"
         } else {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         }
         if { $hduName == "LINEGAP" } {
            set found  1
         }
      }
      if { $found == 0 } {
         error "LINEGAP HDU not found"
      }

      set linelist   [$hFile get table lambda_obs ]
      set param(lineList) [lsort -unique $linelist]


      #---- fenetrage par defaut
      set param(x1)        1
      set param(y1)        1
      set param(x2)        $param(width)
      set param(y2)        $param(height)

      #--- info pre process
      set param(hotPixelEnabled) 0
      set param(hotPixelList)    ""
      set param(cosmicEnabled)   0
      set param(cosmicThreshold) 400

      #--- lineList

      set param(spectrograhLink) ""
      set param(mirrorBit)       0
      set param(tharBit)         1
      set param(flatBit)         2
      set param(neonBit)         3

      $hFile close
      set hFile ""
   }]

   if { $catchResult ==1 } {
      if { $hFile != "" } {
         fits close $hFile
      }
      error $::errorInfo
   }

   return [array get param]
}

##------------------------------------------------------------
# retourne la valeur d'un mot clef
#
# @param   hFile          handle du fichier fitd
# @param   keywordName    nom du mot clef
#
# @return valeur du mot clef
# @private
#------------------------------------------------------------
proc ::eshel::instrument::getKeyword { hFile keywordName} {
   variable private

   #--- je recupere les mots clefs dans le nom contient la valeur keywordName
   #--- cette fonction retourne une liste de triplets { name value description }

   set catchResult [ catch {
      set keywords [$hFile get keyword $keywordName]
   }]
   if { $catchResult !=0 } {
      #--- je transmets l'erreur en ajoutant le nom du mot clé
      error "keyword $keywordName not found\n$::errorInfo"
   }

   #--- je cherche le mot cle qui a exactement le nom requis
   foreach keyword $keywords {
      set name [lindex $keyword 0]
      set value [lindex $keyword 1]
      if { $name == $keywordName } {
         #--- je supprime les apostrophes et les espaces qui entourent la valeur
         set value [string trim [string map {"'" ""} [lindex $keyword 1] ]]
         break
      }
   }
   if { $name != $keywordName } {
      #--- je retourne une erreur si le mot clef n'est pas trouve
      error "keyword $keywordName not found"
   }
   return $value
}


## exportConfig ------------------------------------------------------------
# export une configuration dans un fichier XML
#
# @param fileName nom du fichier XML
# @return
# @public
#------------------------------------------------------------
proc ::eshel::instrument::exportConfig { fileName } {
   variable private

   set hFile ""
   set catchResult [ catch {
      set configId $::conf(eshel,currentInstrument)

      #--- je copie la configuration dans une structure DOM
      set configDom [::dom::DOMImplementation create]
      set configNode [::dom::document createElement $configDom ESHEL_CONFIG ]
      ::dom::element setAttribute $configNode "ESHEL_VERSION" [package present eshel]
      ::dom::element setAttribute $configNode "CONFIG_NAME"   $::conf(eshel,instrument,config,$configId,configName)
      set paramNode [::dom::document createElement $configNode "PARAMS" ]

      ###console::disp "[array get ::conf eshel,instrument,config,$configId,*]\n"
      foreach { paramName paramValue } [array get ::conf eshel,instrument,config,$configId,*] {
         #--- je recupere le nom du parametre
         set paramName [lindex [split $paramName "," ] 4]
         ::dom::element setAttribute $paramNode $paramName $paramValue
      }

      #--- j'enregistre la struture DOM dans le fichier
      set hfile [open "$fileName" w+]
      puts $hfile [::dom::tcl::serialize $configDom -indent true ]
      close $hfile
      set hfile ""
   }]
   if { $catchResult !=0 } {
      if { $hFile != "" } {
         close $hFile
      }
      #--- je transmets l'erreur a la procedure appelante
      error $::errorInfo
   }
}

#------------------------------------------------------------
# setSpectrographLamp
#  allume ou eteint une lampe du spectrographe
#
# Parameters :
#    commandName : mirror thar flat neon
#    state    : 1=allume 0=eteint
#------------------------------------------------------------
proc ::eshel::instrument::setSpectrographLamp { bonnetteLinkNo commandName state  } {
   variable private

   set currentInstrument $::conf(eshel,currentInstrument)

   switch $commandName {
      "mirror" -
      "thar" -
      "flat" -
      "neon" {
         link$bonnetteLinkNo bit $::conf(eshel,instrument,config,$currentInstrument,$commandName,bit) $state
         #--- je donne un
         after 500
      }
      default {
         error "Incorrect lamp $lampName . Must be (thar|flat|neon)\n"
      }
   }
}

#------------------------------------------------------------
# connectCamera
#    connecte la camera ( cette fonction devrait se trouver dans confCam.tcl)
#
# Parameters :
#    visuNo : numero de la visu de la fenetre de l'outil eShel
#
# return :
#    rien
#    genere une exception en cas d'erreur
#------------------------------------------------------------
proc ::eshel::instrument::connectCamera { visuNo } {
   variable private

   set camItem [::confVisu::getCamItem $visuNo]
   if { $camItem == "" } {
      set camItem "A"
   } else {
      #--- j'arrete la camera courante
      ::confCam::stopItem $camItem
   }
   set cameraLabel $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraLabel)
   set index [lsearch $::confCam::private(pluginLabelList) $cameraLabel]
   if { $index == -1 } {
       error "camera not found : $cameraLabel"
   }
   set cameraNamespace [lindex $::confCam::private(pluginNamespaceList) $index]

   set ::confCam::private($camItem,camName) $cameraNamespace
   set ::confCam::private(currentCamItem) $camItem
   set ::confCam::private($camItem,visuName) "visu$visuNo"
   ::confCam::configureCamera $camItem

   return
}

#------------------------------------------------------------
# getCameraBinningList
#    recupere les bing de la camerala camera ( cette fonction devrait se trouver dans confCam.tcl)
#
# Parameters :
#    visuNo : numero de la visu de la fenetre de l'outil eShel
#
# return :
#    rien
#    genere une exception en cas d'erreur
#------------------------------------------------------------
proc ::eshel::instrument::getCameraBinningList { visuNo } {
   variable private

   set camItem [::confVisu::getCamItem $visuNo]
   if { $camItem == "" } {
      set camItem "A"
   } else {
      #--- j'arrete la camera courante
      ::confCam::stopItem $camItem
   }
   set cameraLabel $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraLabel)
   set index [lsearch $::confCam::private(pluginLabelList) $cameraLabel]
   if { $index == -1 } {
       error "camera not found : $cameraLabel"
   }
   set cameraNamespace [lindex $::confCam::private(pluginNamespaceList) $index]

   set ::confCam::private($camItem,camName) $cameraNamespace
   set ::confCam::private(currentCamItem) $camItem
   set ::confCam::private($camItem,visuName) "visu$visuNo"
   ::confCam::configureCamera $camItem

   return
}


