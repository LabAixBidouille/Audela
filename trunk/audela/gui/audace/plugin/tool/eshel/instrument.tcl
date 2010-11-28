#
# Fichier : instrument.tcl
# Description : commande des instruments de l'outil eShel
# Auteur : Michel PUJOL
# Mise à jour $Id: instrument.tcl,v 1.5 2010-11-28 17:34:34 michelpujol Exp $
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
#    selectionne la configuration courante
#
# @param configId : nom de la configuration identifiant de la configuration
# @return void
#------------------------------------------------------------
proc ::eshel::instrument::setCurrentConfig { configId } {

   #--- je verifie que la configuration existe
   if { [info exists ::conf(eshel,instrument,config,$configId,configName)] == 0 } {
      error "configId=$configId not found"
   }
   #--- je verifie qu'il n'y a pas d'acquisition en cours
   if { [::eshel::acquisition::getCurrentSeriesID] != "" } {
      error $caption(eshel,instrument,errorBusyConfig)
   }

   #--- je verifie qu'il n'y a pas de traitement en cours
   #--- TODO  (est ce bien n�cessaire ?)

   #--- j'ajoute les parametres manquants (en cas d'evolution de eShel)
   if { $configId != "default" } {
      foreach { defautParamName defautlParamValue } [array get ::conf eshel,instrument,config,default,*] {
         #--- je prepare le nom de la nouvelle variable
         set configParamName [string map [list ",default," ",$configId,"] $defautParamName ]
         if { [info exists ::conf($configParamName)] == 0 } {
            #--- j'ajoute le parametre s'il n'existe pas
            if { $defautParamName != "name" } {
               #--- je copie valeur de la configuration par defaut
               set ::conf($configParamName) $defautlParamValue
            } else {
               #--- copie l'identifiant dans le nom
               set ::conf($configParamName) $configId
            }
         }
      }
   }
   #---
   set ::conf(eshel,currentInstrument) $configId
   return ""
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
#  flatfieldEnabled
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
# lit une configuration a partir d'un fichier XML
# et retourne tous les parametres
#
# @param fileName nom du fichier XML
# @return parametres de la config dans une liste de couples paramName,paramValue array
# @public
#------------------------------------------------------------
proc ::eshel::instrument::readConfigFile { fileName } {
   variable private

   set hFile ""
   set paramList ""

   set catchResult [ catch {
      #--- je lis le fichier
      set hfile [open "$fileName" r]
      set contents [read $hfile]
      close $hfile
      set hfile ""
   }]

   if { $catchResult ==1 } {
      if { $hFile != "" } {
         close $hFile
      }
      error $::errorInfo
   }

   #--- je parse le contenu du fichier
   set configDom [::dom::tcl::parse $contents]
   set configNode [::dom::tcl::document cget $configDom -documentElement]
   #--- je recupere la liste des parametres
   set paramNode [lindex [set [::dom::element getElementsByTagName $configNode "PARAMS" ]] 0]
   array set attributArray [array get [ dom::node cget $paramNode -attributes]]
   #--- je copie seulement les parametres dont l'equivalent existe dans la configuration par defaut (en cas d'evolution de eShel)
   #--- si un parametre n'existe pas dans la nouvelle configuration, je le remplace par la valeur de configuraiton par defaut
   foreach { defautParamName defautlParamValue } [array get ::conf eshel,instrument,config,default,*] {
      #--- je recupere le nom du parametre
      set paramName [lindex [split $defautParamName "," ] 4]
      #--- je verifie que le parametre existe dans la nouvelle configuration
      if { [info exists attributArray($paramName)] == 1 } {
         #--- j'utilise la valeur du parametre de la configuration
         lappend paramList $paramName $attributArray($paramName)
      } else {
         #--- j'utilise la valeur du parametre de la configuration par defaut
         lappend paramList $paramName $defautlParamValue
      }
   }

   return $paramList
}

## importConfig------------------------------------------------------------
# importe une configuration dans la variable conf(eshel,instrument,config,$configId,*)
# a partir d'un fichier XML
#
# @param fileName nom du fichier XML
# @param configName nom du fichier XML
# @return identifiant de la configuration
# @public
#------------------------------------------------------------
proc ::eshel::instrument::importConfig { fileName } {
   variable private

   #--- je lis le fichier
   array set paramsArray [::eshel::instrument::readConfigFile $fileName]
   set configName $paramsArray(configName)
   set configId [::eshel::instrument::getConfigIdentifiant $configName]
   #--- je supprime les anciens parametres
   array unset ::conf eshel,instrument,config,$configId,*
   #--- je copie les parametres de la configuration dans la variable ::conf
   foreach { paramName paramValue } [array get paramsArray] {
      set ::conf(eshel,instrument,config,$configId,$paramName) $paramValue
   }
   return $configId
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
      #--- je transmets l'erreur en ajoutant le nom du mot cle
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

