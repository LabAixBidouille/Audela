#
# Fichier : keyword.tcl
# Description : Procedures autour de l'en-tete FITS
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: keyword.tcl,v 1.32 2009-12-30 14:25:10 robertdelmas Exp $
#

namespace eval ::keyword {
}

#------------------------------------------------------------------------------
# header
#    Affiche l'en-tete FITS d'un fichier
#
# Parametres :
#    visuNo
#    args : valeurs fournies par le gestionnaire de listener
#------------------------------------------------------------------------------
proc ::keyword::header { visuNo args } {
   variable private

   #--- Initialisation
   set base [ ::confVisu::getBase $visuNo ]
   if { ! [ info exists ::conf(geometry_header_$visuNo) ] } { set ::conf(geometry_header_$visuNo) "632x303+3+75" }
   #---
   set private(geometry_header_$visuNo) $::conf(geometry_header_$visuNo)
   #---
   if { [ winfo exists $base.header ] == 0 } {
      toplevel $base.header
      wm transient $base.header $base
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
         wm minsize $base.header 632 303
      }
      wm resizable $base.header 1 1
      wm geometry $base.header $private(geometry_header_$visuNo)
      wm protocol $base.header WM_DELETE_WINDOW "::keyword::closeHeader $visuNo"
      Scrolled_Text $base.header.slb -width 150 -height 20
      pack $base.header.slb -fill y -expand true
      #--- Je declare le rafraichissement automatique des mots-cles si on charge une image
      ::confVisu::addFileNameListener $visuNo "::keyword::header $visuNo"
      #--- Je declare le rafraichissement automatique des mots-cles si on change de HDU de l'image FITS
      ::confVisu::addHduListener $visuNo "::keyword::header $visuNo"
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $base.header <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base.header
   } else {
      $base.header.slb.list delete 1.0 end
   }
   #---
   wm title $base.header "$::caption(keyword,header_title) (visu$visuNo) - [::confVisu::getFileName $visuNo]"
   #---
   if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
      $base.header.slb.list tag configure keyw -foreground $::color(blue)
      $base.header.slb.list tag configure egal -foreground $::color(black)
      $base.header.slb.list tag configure valu -foreground $::color(red)
      $base.header.slb.list tag configure comm -foreground $::color(green1)
      $base.header.slb.list tag configure unit -foreground $::color(orange)
      foreach kwd [ lsort -dictionary [ buf[ ::confVisu::getBufNo $visuNo ] getkwds ] ] {
         set liste [ buf[ ::confVisu::getBufNo $visuNo ] getkwd $kwd ]
         set koff 0
         if {[llength $liste]>5} {
            #--- Detourne un bug eventuel des mots longs (ne devrait jamais arriver !)
            set koff [expr [llength $liste]-5]
         }
         set keyword "$kwd"
         if {[string length $keyword]<=8} {
            set keyword "[format "%8s" $keyword]"
         }
         $base.header.slb.list insert end "$keyword " keyw
         $base.header.slb.list insert end "= " egal
         $base.header.slb.list insert end "[lindex $liste [expr $koff+1]] " valu
         $base.header.slb.list insert end "[lindex $liste [expr $koff+3]] " comm
         $base.header.slb.list insert end "[lindex $liste [expr $koff+4]]\n" unit
      }
   } else {
      $base.header.slb.list insert end "$::caption(keyword,header_noimage)"
   }
}

#------------------------------------------------------------------------------
# closeHeader
#    Ferme l'en-tete FITS d'un fichier
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::closeHeader { visuNo } {
   ::keyword::headerRecupPosition $visuNo
   ::confVisu::removeFileNameListener $visuNo "::keyword::header $visuNo"
   ::confVisu::removeHduListener $visuNo "::keyword::header $visuNo"
   destroy [ ::confVisu::getBase $visuNo ].header
}

#------------------------------------------------------------------------------
# headerRecupPosition
#    Permet de recuperer et de sauvegarder la dimension et la position de la fenetre de l'en-tete FITS
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::headerRecupPosition { visuNo } {
   variable private

   #---
   set private(geometry_header_$visuNo) [ wm geometry [ ::confVisu::getBase $visuNo ].header ]
   #---
   set ::conf(geometry_header_$visuNo) $private(geometry_header_$visuNo)
}

#########################################################################################################

#------------------------------------------------------------------------------
# addJDayOBSandEND
#    Ajoute les mots cles JDAY-OBS et JDAY-END
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::addJDayOBSandEND { } {
   #--- Rajoute la date de debut de pose en jour julien dans l'en-tete FITS
   set date_obs [ lindex [ buf$::audace(bufNo) getkwd DATE-OBS ] 1 ]
   set date_obs [ mc_date2jd $date_obs ]
   buf$::audace(bufNo) setkwd [list JDAY-OBS $date_obs string "Julian Day for begin of scan exposure" ""]

   #--- Rajoute la date de fin de pose en jour julien dans l'en-tete FITS
   set date_end [ lindex [ buf$::audace(bufNo) getkwd DATE-END ] 1 ]
   set date_end [ mc_date2jd $date_end ]
   buf$::audace(bufNo) setkwd [list JDAY-END $date_end string "Julian Day for end of scan exposure" ""]
}

#########################################################################################################

#------------------------------------------------------------------------------
# init
#    Initialisation
#
# Parametres :
#    aucun
#------------------------------------------------------------------------------
proc ::keyword::init { } {
   variable private

   #--- Charge le fichier caption
   source [ file join "$::audace(rep_caption)" keyword.cap ]

   #--- Creation de la variable de la boite de configuration de l'en-tete FITS si elle n'existe pas
   if { ! [ info exists ::conf(keyword,geometry) ] }          { set ::conf(keyword,geometry)          "650x240+350+15" }
   if { ! [ info exists ::conf(keyword,listTypeImage) ] }     { set ::conf(keyword,listTypeImage)     [ list Offset Dark Flat Object Lamp ] }
   if { ! [ info exists ::conf(keyword,GotoManuelAuto) ] }    { set ::conf(keyword,GotoManuelAuto)    "$::caption(keyword,manuel)" }
   if { ! [ info exists ::conf(keyword,GotoManuelAutoBis) ] } { set ::conf(keyword,GotoManuelAutoBis) "$::caption(keyword,manuel)" }
   if { ! [ info exists ::conf(keyword,GotoManuelAutoTer) ] } { set ::conf(keyword,GotoManuelAutoTer) "$::caption(keyword,manuel)" }
   if { ! [ info exists ::conf(keyword,typeImageSelected) ] } { set ::conf(keyword,typeImageSelected) "Object" }

   #--- Configuration par defaut
   if { ! [ info exists ::conf(keyword,default,configName) ] } {
      set ::conf(keyword,default,configName) "default"
   }
   if { ! [ info exists ::conf(keyword,default,check) ] } {
      if { [ info exists ::conf(keyword,visu1,check) ] } {
         set ::conf(keyword,default,check) $::conf(keyword,visu1,check)
         unset ::conf(keyword,visu1,check)
      } else {
         set ::conf(keyword,default,check) "1,check,DETNAM 1,check,EXPTIME 1,check,SWMODIFY 1,check,SWCREATE"
      }
   }

   #--- Initialisation de variables
   set private(nom_observateur)     ""
   set private(nom_observatoire)    ""
   set private(instrument)          ""
   set private(diametre)            ""
   set private(focale_resultante)   ""
   set private(cell_dim_x)          ""
   set private(cell_dim_y)          ""
   set private(set_temperature_ccd) ""
   set private(temperature_ccd)     ""
   set private(equipement)          ""
   set private(detectorName)        ""
   set private(objName)             ""
   set private(ra)                  ""
   set private(dec)                 ""
   set private(equinoxe)            ""
   set private(radecsys)            ""
   set private(typeImage)           "Object"
   set private(seriesId)            ""
   set private(expTime)             ""
   set private(raMean)              ""
   set private(raRms)               ""
   set private(decMean)             ""
   set private(decRms)              ""
   set private(seeing)              ""
   set private(skylevel)            ""
   set private(name_software)       "[ ::audela::getPluginTitle ] $::audela(version)"
   set private(name_software)       "[ ::keyword::headerFitsCompliant $::keyword::private(name_software) ]"
   set private(confName)            ""
   set private(commentaire)         ""

   #--- Liste pour les combobox
   set private(listTypeImage)       "$::conf(keyword,listTypeImage)"
   lappend private(listTypeImage)   "$::caption(keyword,newValue)"
   set private(listOutilsGoto)      [ list $::caption(keyword,manuel) $::caption(keyword,automatic) ]

   #--- On cree la liste des caracteristiques (nom, categorie, variable, procedure, etc.) des mots cles
   set private(infosMotsClefs) ""
   lappend private(infosMotsClefs) [ list "OBSERVER" $::caption(keyword,lieu)        ::keyword::private(nom_observateur)     readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Observer name"                                   "" ]
   lappend private(infosMotsClefs) [ list "SITENAME" $::caption(keyword,lieu)        ::keyword::private(nom_observatoire)    readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Observatory name"                                "" ]
   lappend private(infosMotsClefs) [ list "IAU_CODE" $::caption(keyword,lieu)        ::conf(posobs,station_uai)              readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Observatory IAU Code"                            "" ]
   lappend private(infosMotsClefs) [ list "SITELONG" $::caption(keyword,lieu)        ::conf(posobs,estouest_long)            readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Observatory longitude"                           "degres, minutes, seconds" ]
   lappend private(infosMotsClefs) [ list "SITELAT"  $::caption(keyword,lieu)        ::conf(posobs,nordsud_lat)              readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Observatory latitude"                            "degres, minutes, seconds" ]
   lappend private(infosMotsClefs) [ list "SITEELEV" $::caption(keyword,lieu)        ::conf(posobs,altitude)         readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Observatory elevation above the sea level"       "m: meter" ]
   lappend private(infosMotsClefs) [ list "GEODSYS"  $::caption(keyword,lieu)        ::conf(posobs,ref_geodesique)           readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                       "" "" "string" "Geodetic datum for observatory position"         "" ]
   lappend private(infosMotsClefs) [ list "TELESCOP" $::caption(keyword,instrument)  ::keyword::private(instrument)          readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                           ""                                  ""                                       "" "" "string" "Telescop"                                        "" ]
   lappend private(infosMotsClefs) [ list "APTDIA"   $::caption(keyword,instrument)  ::keyword::private(diametre)            readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                           ""                                  ""                                       "" "" "float"  "Telescop diameter"                               "m: meter" ]
   lappend private(infosMotsClefs) [ list "FOCLEN"   $::caption(keyword,instrument)  ::keyword::private(focale_resultante)   readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                           ""                                  ""                                       "" "" "float"  "Resulting focal length of the telescop"          "m: meter" ]
   lappend private(infosMotsClefs) [ list "XPIXSZ"   $::caption(keyword,instrument)  ::keyword::private(cell_dim_x)          readonly $::caption(keyword,parcourir)  "::confCam::run"                               ""                                  ""                                       "" "" "float"  "Pixel width"                                     "micron" ]
   lappend private(infosMotsClefs) [ list "YPIXSZ"   $::caption(keyword,instrument)  ::keyword::private(cell_dim_y)          readonly $::caption(keyword,parcourir)  "::confCam::run"                               ""                                  ""                                       "" "" "float"  "Pixel height"                                    "micron" ]
   lappend private(infosMotsClefs) [ list "SET_TEMP" $::caption(keyword,instrument)  ::keyword::private(set_temperature_ccd) readonly $::caption(keyword,parcourir)  "::keyword::openSetTemperature"                ""                                  ""                                       "" "" "float"  "Set CCD temperature"                             "degres Celsius" ]
   lappend private(infosMotsClefs) [ list "CCD_TEMP" $::caption(keyword,instrument)  ::keyword::private(temperature_ccd)     readonly $::caption(keyword,rafraichir) "::keyword::onChangeTemperature"               ""                                  ""                                       "" "" "float"  "Actual CCD temperature"                          "degres Celsius" ]
   lappend private(infosMotsClefs) [ list "INSTRUME" $::caption(keyword,instrument)  ::keyword::private(equipement)          normal   ""                             ""                                             ""                                  ""                                       "" "" "string" "Instrument"                                      "" ]
   lappend private(infosMotsClefs) [ list "DETNAM"   $::caption(keyword,instrument)  ::keyword::private(detectorName)        normal   ""                             ""                                             ""                                  ""                                       "" "" "string" "Detector"                                        "" ]
   lappend private(infosMotsClefs) [ list "OBJNAME"  $::caption(keyword,cible)       ::keyword::private(objName)             normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::conf(keyword,GotoManuelAuto)           0  "" "string" "Object observed"                                 "" ]
   lappend private(infosMotsClefs) [ list "RA"       $::caption(keyword,cible)       ::keyword::private(ra)                  normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::conf(keyword,GotoManuelAutoBis)        0  "" "float"  "Object Right Ascension"                          "degres" ]
   lappend private(infosMotsClefs) [ list "DEC"      $::caption(keyword,cible)       ::keyword::private(dec)                 normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::conf(keyword,GotoManuelAutoBis)        0  "" "float"  "Object Declination"                              "degres" ]
   lappend private(infosMotsClefs) [ list "EQUINOX"  $::caption(keyword,cible)       ::keyword::private(equinoxe)            normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::conf(keyword,GotoManuelAutoTer)        0  "" "float"  "Coordinates equinox"                             "" ]
   lappend private(infosMotsClefs) [ list "RADECSYS" $::caption(keyword,cible)       ::keyword::private(radecsys)            normal   ""                             ""                                             ""                                  ""                                       "" "" "string" "Coordinates system"                              "" ]
   lappend private(infosMotsClefs) [ list "IMAGETYP" $::caption(keyword,acquisition) ::keyword::private(typeImage)           readonly ""                             ""                                             $::keyword::private(listTypeImage)  ::conf(keyword,typeImageSelected)        0  "" "string" "Image type"                                      "" ]
   lappend private(infosMotsClefs) [ list "SERIESID" $::caption(keyword,acquisition) ::keyword::private(seriesId)            normal   ""                             ""                                             ""                                  ""                                       "" "" "string" "Series identifiant"                              "" ]
   lappend private(infosMotsClefs) [ list "EXPTIME"  $::caption(keyword,acquisition) ::keyword::private(expTime)             normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "Exposure time"                                   "s" ]
   lappend private(infosMotsClefs) [ list "RA_MEAN"  $::caption(keyword,acquisition) ::keyword::private(raMean)              normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "RA mean correction"                              "arsec" ]
   lappend private(infosMotsClefs) [ list "RA_RMS"   $::caption(keyword,acquisition) ::keyword::private(raRms)               normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "RA rms correction"                               "arsec" ]
   lappend private(infosMotsClefs) [ list "DEC_MEAN" $::caption(keyword,acquisition) ::keyword::private(decMean)             normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "DEC mean correction"                             "arsec" ]
   lappend private(infosMotsClefs) [ list "DEC_RMS"  $::caption(keyword,acquisition) ::keyword::private(decRms)              normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "DEC rms correction"                              "arsec" ]
   lappend private(infosMotsClefs) [ list "SEEING"   $::caption(keyword,acquisition) ::keyword::private(seeing)              normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "Seeing as stellar full-width at half-maximum"    "arsec" ]
   lappend private(infosMotsClefs) [ list "SKYLEVEL" $::caption(keyword,acquisition) ::keyword::private(skylevel)            normal   ""                             ""                                             ""                                  ""                                       "" "" "float"  "Sky backgound level"                             "ADU" ]
   lappend private(infosMotsClefs) [ list "SWCREATE" $::caption(keyword,logiciel)    ::keyword::private(name_software)       readonly ""                             ""                                             ""                                  ""                                       "" "" "string" "Acquisition software: http://www.audela.org/"    "" ]
   lappend private(infosMotsClefs) [ list "SWMODIFY" $::caption(keyword,logiciel)    ::keyword::private(name_software)       readonly ""                             ""                                             ""                                  ""                                       "" "" "string" "Processing software: http://www.audela.org/"     "" ]
   lappend private(infosMotsClefs) [ list "CONFNAME" $::caption(keyword,instrument)  ::keyword::private(confName)            normal   ""                             ""                                             ""                                  ""                                       "" "" "string" "Configuration name"                              "" ]
   lappend private(infosMotsClefs) [ list "COMMENT"  $::caption(keyword,divers)      ::keyword::private(commentaire)         normal   ""                             ""                                             ""                                  ""                                       "" "" "string" "Comment"                                         "" ]
}

#------------------------------------------------------------------------------
# run
#    Lance la boite de dialogue de configuration de l'en-tete FITS
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::run { visuNo configNameVariable } {
   variable private

   #--- je charge le package Tablelist
   package require Tablelist

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName)         [ set $configNameVariable ]
   set private($visuNo,configNameVariable) $configNameVariable

   #--- Creation des variables de la boite de configuration de l'en-tete FITS si elles n'existent pas
   if { ! [ info exists private($visuNo,disabled) ] } { set private($visuNo,disabled) "" }

   #--- j'ajoute un listener sur la configuration de l'observatoire
   ::confPosObs::addPosObsListener [list ::keyword::onChangeConfPosObs $visuNo]

   #--- j'ajoute un listener sur la configuration optique
   ::confOptic::addOpticListener [list ::keyword::onChangeConfOptic $visuNo]

   #--- j'ajoute des listeners sur la camera et l'AlAudine
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeConfOptic $visuNo]
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeCellDim $visuNo]
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeTemperature $visuNo]

   #--- je recupere la configuration de l'observateur et de l'observatoire
   onChangeConfPosObs $visuNo

   #--- je recupere la configuration optique
   onChangeConfOptic $visuNo

   #--- je recupere les dimensions des photosites
   onChangeCellDim $visuNo

   #--- je recupere la consigne et la temperature du CCD
   onChangeTemperature $visuNo

   #--- je recupere le nom de l'objet  (si mode automatique)
   onChangeObjname $visuNo

   #--- je recupere l'ascension droite et la declinaison l'objet (si mode automatique)
   onChangeRaDec $visuNo

   #--- je recupere l'equinoxe des coordonnees de l'objet  (si mode automatique)
   onChangeEquinox $visuNo

   #--- je mets a jour la procedure a appeler pour rafraichir CCD_TEMP
   for { set i 0 } { $i < [ llength $private(infosMotsClefs) ] } { incr i } {
      set ligne [ lindex $private(infosMotsClefs) $i ]
      if { [ lindex $ligne 0 ] == "CCD_TEMP" } {
         set ligne [ lreplace $ligne 5 5 "::keyword::onChangeTemperature $visuNo" ]
         set private(infosMotsClefs) [ lreplace $private(infosMotsClefs) $i $i $ligne ]
         break
      }
   }

   #--- je mets a jour la procedure a appeler pour ouvrir la fenetre de consigne de temperature
   for { set i 0 } { $i < [ llength $private(infosMotsClefs) ] } { incr i } {
      set ligne [ lindex $private(infosMotsClefs) $i ]
      if { [ lindex $ligne 0 ] == "SET_TEMP" } {
         set ligne [ lreplace $ligne 5 5 "::keyword::openSetTemperature $visuNo" ]
         set private(infosMotsClefs) [ lreplace $private(infosMotsClefs) $i $i $ligne ]
         break
      }
   }

   #--- Creation de l'interface graphique
   set tkParent [ ::confVisu::getBase $visuNo ]
   set private($visuNo,frm) $tkParent.keyword
   if { [ winfo exists $private($visuNo,frm) ] } {
      wm withdraw $private($visuNo,frm)
      wm deiconify $private($visuNo,frm)
      focus $private($visuNo,frm)
   } else {
      ::keyword::createDialog $visuNo
   }

   #--- Configuration relative aux combobox
   ::keyword::onChangeValueComboBox $visuNo
}

#------------------------------------------------------------------------------
# onChangeConfPosObs
#    met a jour les mots cles des noms de l'observateur et de l'observatoire
#
# Parametres :
#    visuNo
#    args : valeurs fournies par le gestionnaire de listener
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeConfPosObs { visuNo args } {
   variable private

   set private(nom_observateur)  [ ::keyword::headerFitsCompliant $::conf(posobs,nom_observateur) ]
   set private(nom_observatoire) [ ::keyword::headerFitsCompliant $::conf(posobs,nom_observatoire) ]
}

#------------------------------------------------------------------------------
# onChangeConfOptic
#    met a jour les mots cles de la configuration optique
#
# Parametres :
#    visuNo
#    args : valeurs fournies par le gestionnaire de listener
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeConfOptic { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]
   if { $camItem != "" } {
      set combinaison [ ::confOptic::getConfOptic $camItem ]
      set private(instrument)        [ ::keyword::headerFitsCompliant [lindex $combinaison 0] ]
      set private(diametre)          [lindex $combinaison 1]
      set private(focale_resultante) [lindex $combinaison 2]
   } else {
      set private(instrument)        ""
      set private(diametre)          ""
      set private(focale_resultante) ""
   }
}

#------------------------------------------------------------------------------
# onChangeTemperature
#    met a jour le mot cle de la temperature
#
# Parametres :
#    visuNo
#    args : valeurs fournies par le gestionnaire de listener
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeTemperature { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]

   set private(set_temperature_ccd) [ ::confCam::setTempCCD $camItem ]
   set private(temperature_ccd)     [ ::confCam::getTempCCD $camItem ]
}

#------------------------------------------------------------------------------
# onChangeCellDim
#    met a jour les mots cles des dimensions des photosites
#
# Parametres :
#    visuNo
#    args : valeurs fournies par le gestionnaire de listener
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeCellDim { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]
   set camNo   [::confCam::getCamNo $camItem ]

   if { $camNo != 0 } {
      set private(cell_dim_x) [ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ]
      set private(cell_dim_y) [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]
   } else {
      set private(cell_dim_x) ""
      set private(cell_dim_y) ""
   }
}

#------------------------------------------------------------------------------
# onChangeObjname
#    met a jour le mot cle du nom de l'objet
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeObjname { visuNo } {
   variable private

   if { $::conf(keyword,GotoManuelAuto) == "$::caption(keyword,automatic)" } {
      set private(objName) $::audace(telescope,targetname)
   }
}

#------------------------------------------------------------------------------
# onChangeRaDec
#    met a jour les mots cles de l'ascension droite et de la declinaison de l'objet
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeRaDec { visuNo } {
   variable private

   if { $::conf(keyword,GotoManuelAutoBis) == "$::caption(keyword,automatic)" } {
      set private(ra)  $::audace(telescope,targetRa)
      set private(dec) $::audace(telescope,targetDec)
   }
}

#------------------------------------------------------------------------------
# onChangeEquinox
#    met a jour le mot cle de l'equinoxe des coordonnees de l'objet
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeEquinox { visuNo } {
   variable private

   if { $::conf(keyword,GotoManuelAutoTer) == "$::caption(keyword,automatic)" } {
      set private(equinoxe) $::audace(telescope,targetEquinox)
   }
}

#------------------------------------------------------------------------------
# openSetTemperature
#    ouvre la fenetre pour mettre a jour la consigne de temperature
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::openSetTemperature { visuNo } {
   set camItem [ ::confVisu::getCamItem $visuNo ]

   if { [ ::confCam::getPluginProperty $camItem hasSetTemp ] == "1" } {
      if { [ ::confLink::getLinkNamespace $::conf(audine,port) ] == "ethernaude" } {
         ::AlAudineNT::run $::audace(base).alimAlAudineNT
      } else {
         ::confCam::run
      }
   }
}

#------------------------------------------------------------------------------
# onChangeValueComboBox
#    action coordonnee au changement de valeur dans la combobox
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::onChangeValueComboBox { visuNo } {
   variable private

   #--- Mot cle OBJNAME
   if { $::conf(keyword,GotoManuelAuto) == "$::caption(keyword,automatic)" } {
      #--- Je recupere le nomTK de l'entry
      set wOBJNAME [$::keyword::private($visuNo,table) windowpath OBJNAME,valeur ]
      #--- Je configure l'etat de l'entry
      $wOBJNAME configure -state disabled
      #--- Je recupere OBJNAME
      set private(objName) $::audace(telescope,targetname)
   } elseif { $::conf(keyword,GotoManuelAuto) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK de l'entry
      set wOBJNAME [$::keyword::private($visuNo,table) windowpath OBJNAME,valeur ]
      #--- Je configure l'etat de l'entry
      $wOBJNAME configure -state normal
      #--- Je vide le champ correspondant
      set private(objName) ""
   }

   #--- Mots cles RA et DEC
   if { $::conf(keyword,GotoManuelAutoBis) == "$::caption(keyword,automatic)" } {
      #--- Je recupere le nomTK des entry
      set wRA  [$::keyword::private($visuNo,table) windowpath RA,valeur ]
      set wDEC [$::keyword::private($visuNo,table) windowpath DEC,valeur ]
      #--- Je configure l'etat des entry
      $wRA  configure -state disabled
      $wDEC configure -state disabled
      #--- Je recupere les RA et DEC de la cible
      set private(ra)  $::audace(telescope,targetRa)
      set private(dec) $::audace(telescope,targetDec)
   } elseif { $::conf(keyword,GotoManuelAutoBis) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK des entry
      set wRA  [$::keyword::private($visuNo,table) windowpath RA,valeur ]
      set wDEC [$::keyword::private($visuNo,table) windowpath DEC,valeur ]
      #--- Je configure l'etat des entry
      $wRA  configure -state normal
      $wDEC configure -state normal
      #--- Je vide les champs correspondants
      set private(ra)  ""
      set private(dec) ""
   }

   #--- Mot cle EQUINOX
   if { $::conf(keyword,GotoManuelAutoTer) == "$::caption(keyword,automatic)" } {
      #--- Je recupere le nomTK de l'entry
      set wEQUINOX [$::keyword::private($visuNo,table) windowpath EQUINOX,valeur ]
     #--- Je configure l'etat de l'entry
      $wEQUINOX configure -state disabled
      #--- Je recupere l'equinoxe
      set private(equinoxe) $::audace(telescope,targetEquinox)
   } elseif { $::conf(keyword,GotoManuelAutoTer) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK de l'entry
      set wEQUINOX [$::keyword::private($visuNo,table) windowpath EQUINOX,valeur ]
      #--- Je configure l'etat de l'entry
      $wEQUINOX configure -state normal
     #--- Je vide le champ correspondant
      set private(equinoxe) ""
   }

   #--- Mot cle IMAGETYP
   if { $::conf(keyword,typeImageSelected) == "$::caption(keyword,newValue)" } {
      #--- Je choisis une valeur non disponible dans la liste
      set private(tempTypeImage) $private(typeImage)
      set private(typeImage)     ""
      ::keyword::newValueTypeImage $visuNo
   } else {
      if { [ info exists private(base) ] == 1 } {
         if { [ winfo exists $private(base) ] == 1 } {
            destroy $private(base)
         }
      }
      set private(typeImage) $::conf(keyword,typeImageSelected)
   }
}

#------------------------------------------------------------------------------
# newValueTypeImage
#    permet d'utiliser une valeur non propose dans la liste
#
# Parametres :
#    visuNo
# Return :
#    nouvelle valeur personnalisee de la combobox
#------------------------------------------------------------------------------
proc ::keyword::newValueTypeImage { visuNo } {
   variable private

   #--- Initialisation
   set private(base)              $::audace(base).newValue
   set private(newValueTypeImage) ""

   #--- Verifie si la Toplevel existe deja
   if { [ winfo exists $private(base) ] } {
      wm withdraw $private(base)
      wm deiconify $private(base)
      focus $private(base)
      return
   }

   #--- Toplevel
   toplevel $private(base) -class Toplevel
   wm title $private(base) $::caption(keyword,newValue)
   wm transient $private(base) $private($visuNo,frm)
   set posx [ lindex [ split [ wm geometry $private($visuNo,frm) ] "+" ] 1 ]
   set posy [ lindex [ split [ wm geometry $private($visuNo,frm) ] "+" ] 2 ]
   wm geometry $private(base) +[ expr $posx + 140 ]+[ expr $posy + 500 ]
   wm resizable $private(base) 0 0
   wm protocol $private(base) WM_DELETE_WINDOW "::keyword::cmdCancelNewValueTypeImage"
   #--- Label et entry
   frame $private(base).newValue -borderwidth 2 -relief raised
      label $private(base).newValue.lab1 -text "$::caption(keyword,saisirNewValue)"
      pack $private(base).newValue.lab1 -side left -anchor se -padx 5 -pady 5 -expand 0
      entry $private(base).newValue.ent1 -textvariable ::keyword::private(newValueTypeImage) \
         -width 15 -relief groove -justify center
      pack $private(base).newValue.ent1 -side left -anchor se -padx 5 -pady 5 -expand 0
   pack $private(base).newValue -side top -fill x -expand 0
   #--- Boutons
   frame $private(base).button -borderwidth 2 -relief raised
      #--- Button OK
      button $private(base).button.ok -text $::caption(keyword,ok) -borderwidth 2 \
         -command "::keyword::cmdOKNewValueTypeImage $visuNo"
      pack $private(base).button.ok -side left -anchor center -padx 10 -pady 5 \
         -ipadx 10 -ipady 5 -expand 0
      #--- Button Annuler
      button $private(base).button.annuler -text $::caption(keyword,annuler) -borderwidth 2 \
         -command "::keyword::cmdCancelNewValueTypeImage"
      pack $private(base).button.annuler -side right -anchor center -padx 10 -pady 5 \
         -ipadx 10 -ipady 5 -expand 0
   pack $private(base).button -side top -anchor center -fill x -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(base)
}

#------------------------------------------------------------------------------
# cmdOKNewValueTypeImage
#    fonction appelee par l'appui sur le boutton OK
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::cmdOKNewValueTypeImage { visuNo } {
   variable private

   if { $private(newValueTypeImage) != "" } {
      destroy $private(base)
      set private(typeImage)                $private(newValueTypeImage)
      set ::conf(keyword,typeImageSelected) $private(newValueTypeImage)
      #--- Je reconstitue la liste de la combobox
      lappend ::conf(keyword,listTypeImage) $private(newValueTypeImage)
      set private(listTypeImage)            $::conf(keyword,listTypeImage)
      lappend private(listTypeImage) $::caption(keyword,newValue)
      set w [ $private($visuNo,table) windowpath IMAGETYP,modification ]
      $w configure -values $private(listTypeImage)
   }
}

#------------------------------------------------------------------------------
# cmdCancelNewValueTypeImage
#    fonction appelee par l'appui sur le boutton Annuler
#
# Parametres :
#    visuNo
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::cmdCancelNewValueTypeImage { } {
   variable private

   destroy $private(base)
   set private(typeImage)                $private(tempTypeImage)
   set ::conf(keyword,typeImageSelected) $private(tempTypeImage)
}

#------------------------------------------------------------------------------
# setKeywordsObjRaDecAuto
#    fonction appelee par rendre la capture des mots cles OBJNAME, RA et DEC automatique
#
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordsObjRaDecAuto { } {
   set ::conf(keyword,GotoManuelAuto)    "$::caption(keyword,automatic)"
   set ::conf(keyword,GotoManuelAutoBis) "$::caption(keyword,automatic)"
}

#------------------------------------------------------------------------------
# setKeywordsObjRaDecManuel
#    fonction appelee par rendre la capture des mots cles OBJNAME, RA et DEC manuelle
#
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordsObjRaDecManuel { } {
   set ::conf(keyword,GotoManuelAuto)    "$::caption(keyword,manuel)"
   set ::conf(keyword,GotoManuelAutoBis) "$::caption(keyword,manuel)"
}

#------------------------------------------------------------------------------
# setKeywordsRaDecAuto
#    fonction appelee par rendre la capture des mots cles RA et DEC automatique
#
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordsRaDecAuto { } {
   set ::conf(keyword,GotoManuelAutoBis) "$::caption(keyword,automatic)"
}

#------------------------------------------------------------------------------
# setKeywordsRaDecManuel
#    fonction appelee par rendre la capture des mots cles RA et DEC manuelle
#
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordsRaDecManuel { } {
   set ::conf(keyword,GotoManuelAutoBis) "$::caption(keyword,manuel)"
}

#------------------------------------------------------------------------------
# setKeywordsEquinoxAuto
#    fonction appelee par rendre la capture du mot cle EQUINOX automatique
#
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordsEquinoxAuto { } {
   set ::conf(keyword,GotoManuelAutoTer) "$::caption(keyword,automatic)"
}

#------------------------------------------------------------------------------
# setKeywordsEquinoxManuel
#    fonction appelee par rendre la capture du mot cle EQUINOX manuelle
#
# Return :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordsEquinoxManuel { } {
   set ::conf(keyword,GotoManuelAutoTer) "$::caption(keyword,manuel)"
}

#------------------------------------------------------------------------------
# getKeywords
#    retourne la liste des mots cles coches
#
# Parametres :
#    visuNo          : Numero de la visu:
#    keywordNameList : Liste des mots cles
# Return :
#    retourne la liste des mots cles coches
#    exemple : {LATITUDE N43d39m59s} {OBSERVER mpujol} {SITENAME Beauzelle}
#------------------------------------------------------------------------------
proc ::keyword::getKeywords { visuNo configName { keywordNameList "" } } {
   variable private

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName) $configName

   #--- je verifie que la visu existe
   ::confVisu::getBase $visuNo

   #--- je recupere la configuration de l'observateur et de l'observatoire
   onChangeConfPosObs $visuNo

   #--- je recupere la configuration optique
   onChangeConfOptic $visuNo

   #--- je recupere les dimensions des photosites
   onChangeCellDim $visuNo

   #--- je recupere le nom de l'objet (si mode automatique)
   onChangeObjname $visuNo

   #--- je recupere l'ascension droite et la declinaison l'objet (si mode automatique)
   onChangeRaDec $visuNo

   #--- je recupere l'equinoxe des coordonnees de l'objet (si mode automatique)
   onChangeEquinox $visuNo

   if { [llength $keywordNameList] == 0 } {
      #--- je recupere les mots cles coches
      set result ""
      foreach name $::conf(keyword,$private($visuNo,configName),check) {
         set motclef [lindex [split $name ","] 2]
         foreach infosMotClef $private(infosMotsClefs) {
            if { [ lindex $infosMotClef 0 ] == $motclef } {
               #--- je recupere la temperature du CCD
               if { $motclef == "CCD_TEMP" } {
                  onChangeTemperature $visuNo
               }
               set textVariable [lindex $infosMotClef 2]
               set valeur       [set $textVariable]
               set type         [lindex $infosMotClef 10]
               set commentaire  [lindex $infosMotClef 11]
               set unite        [lindex $infosMotClef 12]
               #--- je convertis RA et DEC en degres decimaux
               if { $motclef == "RA" } {
                  set valeur [ mc_angle2deg $valeur ]
               }
               if { $motclef == "DEC" } {
                  set valeur [ mc_angle2deg $valeur ]
               }
               #--- je mets en forme l'equinoxe
               if { $motclef == "EQUINOX" } {
                  set valeur [ ::keyword::equinoxCompliant $valeur ]
                  if { $valeur == "now" } {
                     set type "string"
                  } else {
                     set type "float"
                  }
               }
               #--- j'ajoute les mots cles dans le resultat
               lappend result [list $motclef $valeur $type $commentaire $unite]
               break
            }
         }
      }
   } else {
      #--- je recupere les mots cles de la liste fournie en parametre
      set result ""
      foreach keywordName $keywordNameList {
         foreach infosMotClef $private(infosMotsClefs) {
            if { [ lindex $infosMotClef 0 ] == $keywordName } {
               if { $keywordName == "CCD_TEMP" } {
                  #--- je recupere la temperature du CCD
                  onChangeTemperature $visuNo
               }
               set textVariable [lindex $infosMotClef 2]
               set valeur       [set $textVariable]
               set type         [lindex $infosMotClef 10]
               set commentaire  [lindex $infosMotClef 11]
               set unite        [lindex $infosMotClef 12]
               #--- j'ajoute les mots cles dans le resultat
               lappend result [list $keywordName $valeur $type $commentaire $unite]
               break
            }
         }
      }
   }
   return $result
}

#------------------------------------------------------------------------------
# headerFitsCompliant
#    rend les mots cles FITS conformes a la norme
#
# Parametres :
#    stringInput : mots cles FITS
# Return
#    stringOutput : mots cles FITS conformes
#------------------------------------------------------------------------------
proc ::keyword::headerFitsCompliant { stringInput } {
   set res $stringInput
   set res [regsub -all {[é;ê;è;ë]} $res e]
   set res [regsub -all {[à;â;ä]} $res a]
   set res [regsub -all {[ï;î]} $res i]
   set res [regsub -all {[ö;ô]} $res o]
   set res [regsub -all {[ü;û;ù]} $res u]
   set res [regsub -all {[ç]} $res c]
   set res [regsub -all {[']} $res " "]
   set stringOutput $res
   return $stringOutput
}

#------------------------------------------------------------------------------
# equinoxCompliant
#    rend l'equinoxe conforme a la norme
#
# Parametres :
#    stringInput : equinoxe
# Return
#    stringOutput : equinoxe conforme
#------------------------------------------------------------------------------
proc ::keyword::equinoxCompliant { stringInput } {
   set res $stringInput
   set res [ regsub -all {[J]} $res "" ]
   set res [ regsub -all {[B]} $res "" ]
   set stringOutput $res
   return $stringOutput
}

#------------------------------------------------------------------------------
# createDialog
#    Creation de l'interface graphique
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::createDialog { visuNo } {
   variable private

   set frm $private($visuNo,frm)

   #--- Recupere la configuration dans le tableau private(...)
   set private($visuNo,geometry) $::conf(keyword,geometry)

   #--- Toplevel
   toplevel $frm
   wm geometry $frm $private($visuNo,geometry)
   wm minsize $frm 450 150
   wm resizable $frm 1 1
   wm title $frm "$::caption(keyword,titre) (visu$visuNo - $::caption(keyword,camera) [ ::confVisu::getCamItem $visuNo ])"
   wm protocol $frm WM_DELETE_WINDOW "::keyword::cmdClose $visuNo"

   #--- Frame de gestion de la configuration des mots cles
   frame $frm.config -borderwidth 1 -relief raised

      #--- Frame de la combobox de choix de la configuration des mots cles
      frame $frm.config.choix -borderwidth 0 -relief raised

         #--- Liste des configurations
         set configList [ ::keyword::getConfigurationList ]

         #--- Nom de la configuration
         label $frm.config.choix.labconfig -text "$::caption(keyword,nom_config)"
         pack $frm.config.choix.labconfig -anchor w -side left -padx 10 -pady 5

         ComboBox $frm.config.choix.configHeader \
            -width 42         \
            -height 10        \
            -relief sunken    \
            -borderwidth 2    \
            -editable 0       \
            -modifycmd "::keyword::cbCommand $visuNo" \
            -values $configList
         pack $frm.config.choix.configHeader -anchor w -side left -padx 10 -pady 5

         if { [info exists ::conf(keyword,$private($visuNo,configName),configName)] != 0 } {
            set index [ lsearch $configList $::conf(keyword,$private($visuNo,configName),configName) ]
            if { $index == -1 } {
               #--- je selectionne la premiere configuration, si celle de la derniere utilisee n'existe plus
               set index 0
            }
         } else {
            #--- je selectionne la premiere configuration, si celle de la derniere utilisee n'existe plus
            set index 0
         }

         #--- je selectionne la configuration dans la combobox
         $frm.config.choix.configHeader setvalue "@$index"

      pack $frm.config.choix -side top -fill x -expand 0

      #--- Frame des boutons
      frame $frm.config.but -borderwidth 0 -relief raised

         #--- Gestion des noms des configurations
         button $frm.config.but.add -text "$::caption(keyword,ajouter_config)" -borderwidth 2 \
            -command "::keyword::addConfig $visuNo"
         pack $frm.config.but.add -anchor center -side left -padx 5 -pady 5 -ipadx 5
         button $frm.config.but.del -text "$::caption(keyword,supprimer_config)" -borderwidth 2 \
            -command "::keyword::delConfig $visuNo"
         pack $frm.config.but.del -anchor center -side left -padx 5 -pady 5 -ipadx 5
         button $frm.config.but.copy -text "$::caption(keyword,copier_config)" -borderwidth 2 \
            -command "::keyword::copyConfig $visuNo"
         pack $frm.config.but.copy -anchor center -side left -padx 5 -pady 5 -ipadx 5

      pack $frm.config.but -side bottom -fill x -expand 0

   pack $frm.config -side top -fill x -expand 0

   #--- Frame des boutons
   frame $frm.cmd -borderwidth 1 -relief raised

      button $frm.cmd.ok -text "$::caption(keyword,ok)" -width 7 \
         -command "::keyword::cmdOk $visuNo"
      if { $::conf(ok+appliquer)=="1" } {
        pack $frm.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }
      button $frm.cmd.appliquer -text "$::caption(keyword,appliquer)" -width 8 \
         -command "::keyword::cmdApply $visuNo"
      pack $frm.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
      button $frm.cmd.fermer -text "$::caption(keyword,fermer)" -width 7 \
         -command "::keyword::cmdClose $visuNo"
      pack $frm.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
      button $frm.cmd.aide -text "$::caption(keyword,aide)" -width 7 \
         -command { ::keyword::afficheAide }
      pack $frm.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $frm.cmd -side bottom -fill x -expand 0

   #--- Frame des mots cles
   frame $frm.fra1 -borderwidth 0 -relief raised
      set private($visuNo,table) $frm.fra1.table
      scrollbar $frm.fra1.ysb -command "$private($visuNo,table) yview"
      scrollbar $frm.fra1.xsb -command "$private($visuNo,table) xview" -orient horizontal
      ::tablelist::tablelist $private($visuNo,table) \
         -columns [ list \
            0  ""                                      center \
            11 $::caption(keyword,colonne,categorie)   center \
            22 $::caption(keyword,colonne,description) left \
            11 $::caption(keyword,colonne,motclef)     left \
            35 $::caption(keyword,colonne,valeur)      left \
            0  ""                                      center \
            ] \
         -xscrollcommand [list $frm.fra1.xsb set] -yscrollcommand [list $frm.fra1.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private($visuNo,table) columnconfigure 0 -name available
      $private($visuNo,table) columnconfigure 1 -name categorie
      $private($visuNo,table) columnconfigure 2 -name description
      $private($visuNo,table) columnconfigure 3 -name motclef
      $private($visuNo,table) columnconfigure 4 -name valeur
      $private($visuNo,table) columnconfigure 5 -name modification

      #--- je place la table et les scrollbars dans la frame
      grid $private($visuNo,table) -row 0 -column 0 -sticky ewns
      grid $frm.fra1.ysb -row 0 -column 1 -sticky nsew
      grid $frm.fra1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $frm.fra1 0 -weight 1
      grid columnconfig $frm.fra1 0 -weight 1

      #--- ajoute les mots cles dans la table
      foreach motClef $private(infosMotsClefs) {
         ajouteLigne $visuNo [ lindex $motClef 0 ] [ lindex $motClef 1 ] [ lindex $motClef 2 ] [ lindex $motClef 3 ] [ lindex $motClef 4 ] [ lindex $motClef 5 ] [ lindex $motClef 6 ] [ lindex $motClef 7 ] [ lindex $motClef 8 ] [ lindex $motClef 9 ]
      }

      #--- je coche les lignes qui avaient ete cochees dans une session precedente
      foreach check $::conf(keyword,$private($visuNo,configName),check) {
         set private($check) 1
      }

   pack $frm.fra1 -side top -fill both -expand 1

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- je donne le temps au TK de creer les checkbutton dans la tablelist
   update

   #--- je mets a jour l'etat des checkbutton
   ::keyword::setCheckButtonState $visuNo

   #--- je mets a jour l'etat des widgets de la colonne modification
   ::keyword::setWidgetColumnModificationState $visuNo

   #--- je coche les mots cles de la configuration
   ::keyword::cbCommand $visuNo
}

#------------------------------------------------------------------------------
# ajouteLigne
#    ajoute une ligne dans la table
#
# Parametres :
#    visuNo        : numero de la visu
#    motclef       : nom du mot cle
#    categorie     : categorie du mot cle
#    textvariable  : variable contenant la valeur du mot cle
#    stateVariable : etat de l'entry
#    caption       : etiquette du bouton
#    command       : procedure a appeler quand on clique sur le bouton
#    listCombobox  : liste des valeurs de la combobox
#    textvariable  : nom de la variable contenant la valeur affichee
#    editable      : combobox editable ou non
#    cmdComboBox   : fonction appellee quand on change la valeur
#------------------------------------------------------------------------------
proc ::keyword::ajouteLigne { visuNo motclef categorie textvariable stateVariable caption command listCombobox textvarComboBox editable cmdComboBox } {
   variable private

   #--- je cree la ligne
   $private($visuNo,table) insert end [ list "" $categorie $::caption(keyword,description,$motclef) $motclef "" "" ]
   #--- je nomme la ligne
   $private($visuNo,table) rowconfigure end -name $motclef
   #--- je cree le checkbutton (non coche par defaut)
   set private($visuNo,check,$motclef) 0
   $private($visuNo,table) cellconfigure end,available -window [ list ::keyword::createCheckbutton $visuNo $motclef ]
   #--- je cree l'entry
   $private($visuNo,table) cellconfigure end,valeur -window [ list ::keyword::createEntry $textvariable $stateVariable ]
   #--- je cree le bouton
   if { $command != "" } {
      $private($visuNo,table) cellconfigure end,modification -window [ list ::keyword::createButton $caption $command ]
   }
   #--- je cree la combobox
   if { $listCombobox != "" } {
      $private($visuNo,table) cellconfigure end,modification -window [ list ::keyword::createComboBox $visuNo $listCombobox $textvarComboBox $editable $cmdComboBox ]
   }
}

#------------------------------------------------------------------------------
# createCheckbutton
#    cree un checkbutton dans la table
#
# Parametres :
#    visuNo       : numero de la visu
#    motclef      : nom du mot cle
#    tbl          : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::keyword::createCheckbutton { visuNo motclef tbl row col w } {
   variable private

   checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::keyword::private($visuNo,check,$motclef)

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
# createEntry
#    cree un entry dans la table
#
# Parametres :
#    textvariable : nom de la variable contenant la valeur affichee
#    state        : normal ou readonly
#    tbl          : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::keyword::createEntry { textvariable state tbl row col w } {
   entry $w -textvariable $textvariable -takefocus 0 -width 35 -state $state

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
# createButton
#    cree un bouton dans la table
#
# Parametres :
#    caption : etiquette du bouton
#    command : fonction appellee quand on clique sur le bouton
#    tbl     : nom Tk de la table
#    row     : numero de ligne
#    col     : numero de colonne
#    w       : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::keyword::createButton { caption command tbl row col w } {
   button $w -text $caption -highlightthickness 0 -takefocus 0 -command $command

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
# createComboBox
#    cree une combobox dans la table
#
# Parametres :
#    visuNo       : numero de la visu
#    listCombobox : liste des valeurs de la combobox
#    textvariable : nom de la variable contenant la valeur affichee
#    editable     : combobox editable (1) ou non (0)
#    cmdComboBox  : fonction appellee quand on change la valeur
#    tbl          : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::keyword::createComboBox { visuNo listCombobox textvarComboBox editable cmdComboBox tbl row col w } {
   ComboBox $w \
      -width [ ::tkutil::lgEntryComboBox $listCombobox ] \
      -height 6 \
      -relief sunken      \
      -borderwidth 1      \
      -textvariable $textvarComboBox \
      -editable $editable \
      -modifycmd "::keyword::onChangeValueComboBox $visuNo" \
      -values $listCombobox

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
# cmdOk
#    Procedure correspondant a l'appui sur le bouton OK
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::cmdOk { visuNo } {
   ::keyword::cmdApply $visuNo
   ::keyword::cmdClose $visuNo
}

#------------------------------------------------------------------------------
# cmdApply
#    Procedure correspondant a l'appui sur le bouton Appliquer
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::cmdApply { visuNo} {
   variable private

   #--- je recupere le nom de la configuration (attention il faut 2 $ !!!)
   set $private($visuNo,configNameVariable) $private($visuNo,configName)

   #--- je memorise la configuration dans le tableau conf(...)
   set ::conf(keyword,geometry) $private($visuNo,geometry)
   #--- je sauvegarde la liste des mots cles coches
   set ::conf(keyword,$private($visuNo,configName),check) ""
   foreach name [array names private $visuNo,check,*] {
      if { $private($name) == 1 } {
         lappend ::conf(keyword,$private($visuNo,configName),check) [list $name]
      }
   }
}

#------------------------------------------------------------------------------
# afficheAide
#    Procedure correspondant a l'appui sur le bouton Aide
#
# Parametres :
#    aucun
#------------------------------------------------------------------------------
proc ::keyword::afficheAide { } {
   ::audace::showHelpItem "$::help(dir,tool)" "keyword.htm"
}

#------------------------------------------------------------------------------
# cmdClose
#    Procedure correspondant a l'appui sur le bouton Fermer
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::cmdClose { visuNo } {
   variable private

   #--- je supprime des listeners sur la camera et l'AlAudine
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeTemperature $visuNo]
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeCellDim $visuNo]
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeConfOptic $visuNo]

   #--- je supprime un listener sur la configuration optique
   ::confOptic::removeOpticListener [list ::keyword::onChangeConfOptic $visuNo]

   #--- je supprime un listener sur la configuration de l'observatoire
   ::confPosObs::removePosObsListener [list ::keyword::onChangeConfPosObs $visuNo]

   #--- je recupere la geometrie de la fenetre
   ::keyword::recupPosDim $visuNo

   #--- je ferme la fenetre
   destroy $private($visuNo,frm)
}

#------------------------------------------------------------------------------
# recupPosDim
#    Permet de recuperer et de sauvegarder la position de la fenetre
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::recupPosDim { visuNo } {
   variable private

   set private($visuNo,geometry) [ wm geometry $private($visuNo,frm) ]
   set ::conf(keyword,geometry) $private($visuNo,geometry)
}

#------------------------------------------------------------
# getConfigurationList
#    retourne la liste des configurations
#
# Return :
#    la liste des configurations
#------------------------------------------------------------
proc ::keyword::getConfigurationList { } {
   #--- Liste des configurations
   set configList [list]
   foreach configPath [array names ::conf keyword,*,configName] {
      set configId [lindex [split $configPath "," ] 1]
      lappend configList $::conf(keyword,$configId,configName)
   }
   #--- je trie par ordre alphabetique (l'option -dictionary est equivalente a nocase)
   return [lsort -dictionary $configList ]
}

#------------------------------------------------------------
# getConfigurationIdentifiant
#   retourne l'identifiant d'une configuration en fonction de son nom
#
# Parametres
#   name : nom de la configuration
# Return :
#   identifiant de la configuration
#------------------------------------------------------------
proc ::keyword::getConfigurationIdentifiant { name } {
   variable private

   #--- je fabrique l'identifiant a partir du nom en remplacant les caracteres interdits pas un "_"
   set configId ""
   for { set i 0 } { $i < [string length $name] } { incr i } {
      set c [string index $name $i]
      if { [string is wordchar $c ] == 0 } {
         #--- je remplace le caractere par underscore, si le caractere n'est pas une lettre, un chiffre ou underscore
         set c "_"
      }
      append configId $c
   }
   return $configId
}

#------------------------------------------------------------------------------
# setKeywordValue
#   change la valeur d'un mot cle
#
# Parametres :
#    visuNo       numero de la visu
#    keywordName  nom du mot cle
#    keywordValue valeur du mot cle
# Return
#    rien
#------------------------------------------------------------------------------
proc ::keyword::setKeywordValue { visuNo configName keywordName keywordValue} {
   variable private

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName) $configName

   foreach infosMotClef $private(infosMotsClefs) {
      if { [ lindex $infosMotClef 0 ] == $keywordName } {
         set textVariable [lindex $infosMotClef 2]
         set $textVariable $keywordValue
         return
      }
   }
   #--- je retourne un message d'erreur si le mot cle n'a pas ete trouve
   error "keyword $keywordName unknown"
}

#------------------------------------------------------------------------------
# selectKeywords
#    selectionne les mots cles a mettre dans les images
#
# Parametres :
#    visuNo
#    keywordNameList : liste des mots cles
#------------------------------------------------------------------------------
proc ::keyword::selectKeywords { visuNo configName keywordNameList } {
   variable private

   #--- Creation des variables de la boite de configuration de l'en-tete FITS si elles n'existent pas
   if { ! [ info exists private($visuNo,disabled) ] } { set private($visuNo,disabled) "" }

   foreach keywordName $keywordNameList {
      if { [ lsearch $::conf(keyword,$configName,check) "1,check,$keywordName" ] == -1 } {
         lappend ::conf(keyword,$configName,check) "1,check,$keywordName"
      }
   }
}

#------------------------------------------------------------------------------
# deselectKeywords
#    deselectionne des mots cles
#
# Parametres :
#    visuNo
#    keywordNameList : liste des mots cles
#------------------------------------------------------------------------------
proc ::keyword::deselectKeywords { visuNo configName keywordNameList } {
   variable private

   foreach keywordName $keywordNameList {
      set var "1,check,$keywordName"
      set idx [ lsearch -exact $::conf(keyword,$configName,check) $var ]
      set ::conf(keyword,$configName,check) [ lreplace $::conf(keyword,$configName,check) $idx $idx "" ]
   }
}

#------------------------------------------------------------------------------
# setKeywordState
#    definit les mots cles qui ne peuvent pas etre supprimes par l'utilisateur
#
# Parametres :
#    visuNo
#    keywordNameList : liste des mots cles
#------------------------------------------------------------------------------
proc ::keyword::setKeywordState { visuNo configName keywordNameList } {
   variable private

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName) $configName

   set private($visuNo,disabled) ""
   foreach keywordName $keywordNameList {
      lappend private($visuNo,disabled) "$keywordName"
   }

   if { [info exists private($visuNo,frm)] == 1 } {
      if { [winfo exists $private($visuNo,frm)] == 1 } {
         ::keyword::setCheckButtonState $visuNo
      }
   }
}

#------------------------------------------------------------------------------
# setCheckButtonState
#    met les checkbutton a l'etat disabled si leur nom est dans la variable
#    private($visuNo,disabled)
#    sinon met les checkbutton a l'etat normal
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::setCheckButtonState { visuNo } {
   variable private

   for {set i 0 } { $i < [$private($visuNo,table) size] } { incr i } {
      set keywordName [$private($visuNo,table) rowcget $i -name ]
      #--- je recupere le nomTK du checkbutton
      set w [$::keyword::private($visuNo,table) windowpath $i,available ]
      #--- je recupere la valeur
      if { [ lsearch $private($visuNo,disabled) $keywordName ] == -1 } {
         $w configure -state normal
      } else {
         $w configure -state disabled
      }
   }
}

#------------------------------------------------------------------------------
# setWidgetColumnModificationState
#    met les widgets de la colonne modification a l'etat disabled si leur nom est
#    dans la variable private($visuNo,disabled)
#    sinon met les widgets de la colonne modification a l'etat normal
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::setWidgetColumnModificationState { visuNo } {
   variable private

   for {set i 0 } { $i < [$private($visuNo,table) size] } { incr i } {
      set keywordName [$private($visuNo,table) rowcget $i -name ]
      #--- je recupere le nomTK de la combobox
      set w [$::keyword::private($visuNo,table) windowpath $i,modification ]
      #--- je recupere la valeur
      if { $w != "" } {
         if { [ lsearch $private($visuNo,disabled) $keywordName ] == -1 } {
            $w configure -state normal
         } else {
            $w configure -state disabled
         }
      }
   }
}

#------------------------------------------------------------------------------
# addConfig
#    Ajout d'une nouvelle configuration dans la liste
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::addConfig { visuNo } {
   variable private

   ::keyword::config::run $visuNo "add" $private($visuNo,configName)
}

#------------------------------------------------------------------------------
# delConfig
#    Suppression d'une configuration dans la liste
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::delConfig { visuNo } {
   variable private

   set ::keyword::config::private(action) "del"
   ::keyword::config::apply $visuNo
}

#------------------------------------------------------------------------------
# copyConfig
#    Copie d'une configuration de la liste
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::copyConfig { visuNo } {
   variable private

   ::keyword::config::run $visuNo "copy" $private($visuNo,configName)
}

#------------------------------------------------------------------------------
# cbCommand
#    Affiche les valeurs dans les widgets pour la configuration choisie
#    (appelee par la combobox a chaque changement de selection)
#
# Parametres :
#    cb : Element selectionne
#------------------------------------------------------------------------------
proc ::keyword::cbCommand { visuNo } {
   variable private

   #--- je recupere l'identifiant de la configuration correspondant a la ligne selectionnee dans la combobox
   set tkCombo $private($visuNo,frm).config.choix.configHeader
   set configId [ ::keyword::getConfigurationIdentifiant [ $tkCombo get ] ]
   set private($visuNo,configName) $configId

   #--- je decoche toutes les lignes
   foreach check [ array names ::keyword::private 1,check,* ] {
      set private($check) 0
   }

   #--- je configure les mots cles selon les exigences de l'outil
   set catchError [ catch {
      ::[ ::confVisu::getTool $visuNo ]::configToolKeywords $visuNo $private($visuNo,configName)
   } m ]
   if { $catchError == "1" } {
      #--- S'il n'y a pas d'exigences, on passe...
   }

   #--- je coche les lignes
   foreach check $::conf(keyword,$configId,check) {
      set private($check) 1
   }
}

#--- Namespace pour les fenetres de gestion des noms de configuration
namespace eval ::keyword::config {
}

#------------------------------------------------------------------------------
# run
#    Cree les fenetres de gestion des noms de configuration
#
# Parametres :
#    visuNo
#    action : add ou copy
#------------------------------------------------------------------------------
proc ::keyword::config::run { visuNo action configId } {
   variable private

   set private(action)   $action
   set private(configId) $configId
   ::confGenerique::run "1" "$::audace(base).manageHeader" "::keyword::config" -modal 0
   set posx_config [ lindex [ split [ wm geometry $::keyword::private($visuNo,frm) ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::keyword::private($visuNo,frm) ] "+" ] 2 ]
   wm geometry $::audace(base).manageHeader +[ expr $posx_config + 0 ]+[ expr $posy_config + 90 ]
   wm transient $::audace(base).manageHeader $::keyword::private($visuNo,frm)
}

#------------------------------------------------------------------------------
# getLabel
#    Retourne le nom de la fenetre de configuration
#
# Parametres :
#    rien
#------------------------------------------------------------------------------
proc ::keyword::config::getLabel { } {
   variable private

   if { $private(action) == "add" } {
      return "$::caption(keyword,ajouter_config)"
   } elseif { $private(action) == "del" } {
      return "$::caption(keyword,supprimer_config)"
   } elseif { $private(action) == "copy" } {
      return "$::caption(keyword,copier_config)"
   }
}

#------------------------------------------------------------------------------
# fillConfigPage
#    Creation de l'interface graphique
#
# Parametres :
#    frm
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::config::fillConfigPage { frm visuNo } {
   variable private

   #--- Initialisation de variables
   set private(frame)              $frm
   set private(newNameConfig)      ""
   set private(nameConfigCopied)   ""
   set private($visuNo,applyError) "0"

   #--- Frame de la gestion des noms de configuration
   frame $frm.setup -borderwidth 0 -relief raised

      if { $private(action) == "add" } {

         label $frm.setup.addConfig -text $::caption(keyword,config_a_ajouter)
         pack $frm.setup.addConfig -anchor nw -side left -padx 10 -pady 10

         entry $frm.setup.nameAddConfig -textvariable ::keyword::config::private(newNameConfig) \
            -width 42
         pack $frm.setup.nameAddConfig  -anchor w -side left -padx 10 -pady 5

         focus $frm.setup.nameAddConfig

      } elseif { $private(action) == "copy" } {

         label $frm.setup.nameConfig -text $::caption(keyword,nom_nouvelle_config)
         pack $frm.setup.nameConfig -anchor nw -side left -padx 10 -pady 10

         entry $frm.setup.nameConfigCopied -textvariable ::keyword::config::private(nameConfigCopied) \
            -width 42
         pack $frm.setup.nameConfigCopied -anchor w -side left -padx 10 -pady 5

         focus $frm.setup.nameConfigCopied

      }

   pack $frm.setup -side top -fill both -expand 1
}

#------------------------------------------------------------------------------
# apply
#    Fonction 'Appliquer' pour memoriser et appliquer la configuration
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::config::apply { visuNo } {
   variable private

   if { $private(action) == "add" } {

      #--- je verifie que le nom n'est pas vide
      if { $private(newNameConfig) == "" } {
         tk_messageBox -message $::caption(keyword,errorEmptyName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      #--- je fabrique l'identifiant a partir du nom en remplacant les caracteres interdits pas un "_"
      set configId [ ::keyword::getConfigurationIdentifiant $private(newNameConfig) ]

      #--- je verifie que l'identifiant n'est pas deja attribue a une autre configuration
      if { [info exists ::conf(keyword,$configId,configName)] == 1 } {
         tk_messageBox -message $::caption(keyword,errorExistingName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      set ::conf(keyword,$configId,configName) $private(newNameConfig)
      set ::conf(keyword,$configId,check) ""

      #--- je configure les mots cles selon les exigences de l'outil
      set catchError [ catch {
         ::[ ::confVisu::getTool $visuNo ]::configToolKeywords $visuNo $private(newNameConfig)
      } m ]
      if { $catchError == "1" } {
         #--- S'il n'y a pas d'exigences, on passe...
      }

      #--- j'ajoute le nom de la configuration
      set ::keyword::private($visuNo,configName) $configId

      #--- j'ajoute la nouvelle configuration dans la combobox
      set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
      set configList [$tkCombo cget -values]
      lappend configList $private(newNameConfig)
      set configList [lsort $configList]
      $tkCombo configure -values $configList -height [ llength $configList ]

      #--- je selectionne la nouvelle liste dans la combobox
      set index [ lsearch $configList $private(newNameConfig) ]
      $tkCombo setvalue "@$index"
      ::keyword::cbCommand $visuNo

   } elseif { $private(action) == "del" } {

      #--- je recupere l'identifiant de la configuration correspondant a la ligne selectionnee dans la combobox
      set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
      set configId [ ::keyword::getConfigurationIdentifiant [ $tkCombo get ] ]
      set private(configId) $configId

      #--- je verifie que ce n'est pas la configuration par defaut
      if { $private(configId) == "default" } {
         #--- j'abandonne la suppression s'il s'agit de la configuration par defaut
         tk_messageBox -message $::caption(keyword,errorDefaultName) \
            -icon error -title $::caption(keyword,header_title)
         return
      }

      #--- je demande la confirmation de la suppression
      set result [ tk_messageBox -message "$::caption(keyword,confirmDeleteConfig) $::conf(keyword,$private(configId),configName)" \
          -type okcancel -icon question -title $::caption(keyword,supprimer_config)]

      if { $result == "ok" } {
         #--- je supprime le nom de la configuration dans la combobox
         set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
         set configList [$tkCombo cget -values]
         set index [ lsearch $configList $::conf(keyword,$private(configId),configName) ]
         set configList [lreplace $configList $index $index]
         $tkCombo configure -values $configList -height [ llength $configList ]

         #--- je supprime les parametres de la configuration
         unset ::conf(keyword,$private(configId),configName)
         unset ::conf(keyword,$private(configId),check)

         #--- je selectionne l'item suivant a la place de celui qui vient d'etre supprime
         if { $index == [llength $configList] } {
            #--- je decremente l'index si l'element supprimé etait le dernier de la liste
            incr index -1
         }
         $tkCombo setvalue "@$index"
         ::keyword::cbCommand $visuNo

         #--- je recupere le nom de la nouvelle configuration (attention il faut 2 $ !!!)
         #--- pour eviter un bug, si je quitte Aud'ACE sans appuyer sur le bouton OK ou
         #--- Appliquer de la fenetre de configuration des mots cles
         set $::keyword::private($visuNo,configNameVariable) $::keyword::private($visuNo,configName)

      }

   } elseif { $private(action) == "copy" } {

      #--- je verifie que le nom n'est pas vide
      if { $private(nameConfigCopied) == "" } {
         tk_messageBox -message $::caption(keyword,errorEmptyName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      #--- je fabrique l'identifiant a partir du nom en remplacant les caracteres interdits pas un "_"
      set configId [ ::keyword::getConfigurationIdentifiant $private(nameConfigCopied) ]

      #--- je verifie que l'identifiant n'est pas deja attribue a une autre configuration
      if { [info exists ::conf(keyword,$configId,configName)] == 1 } {
         tk_messageBox -message $::caption(keyword,errorExistingName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      set ::conf(keyword,$configId,configName) $private(nameConfigCopied)
      set ::conf(keyword,$configId,check) $::conf(keyword,$private(configId),check)

      #--- j'ajoute le nom de la configuration
      set ::keyword::private($visuNo,configName) $configId

      #--- j'ajoute la nouvelle configuration dans la combobox
      set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
      set configList [$tkCombo cget -values]
      lappend configList $private(nameConfigCopied)
      set configList [lsort $configList]
      $tkCombo configure -values $configList -height [ llength $configList ]

      #--- je selectionne la nouvelle liste dans la combobox
      set index [ lsearch $configList $private(nameConfigCopied) ]
      $tkCombo setvalue "@$index"
      ::keyword::cbCommand $visuNo

   }
}

#------------------------------------------------------------------------------
# closeWindow
#    Fonction appellee lors de l'appui sur le bouton 'Fermer'
#
# Parametres :
#    visuNo
#------------------------------------------------------------------------------
proc ::keyword::config::closeWindow { visuNo } {
   variable private

   #--- Retourne 0 pour empecher de fermer la fenetre
   if { $private($visuNo,applyError) == "1" } {
      set private($visuNo,applyError) 0
      return 0
   }
}

#--- Initialisation
::keyword::init

