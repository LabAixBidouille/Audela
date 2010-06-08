#
# Fichier : sophiehistogram.tcl
# Description : Fenetre affcihat l'histogramme des ecarts étoile/consigne
# Mise a jour $Id: sophiehistogram.tcl,v 1.6 2010-06-08 16:01:16 michelpujol Exp $
#

namespace eval ::sophie::histogram {
   variable private


   set private(realTimeFileName) ""
   set private(realTimeVisuNo) ""

}

# ------------------------------------------------------------
# run
#   affiche la fenetre de l'histogramme
# @param visuNo numero de la visu de la fenetre de l'outil eShel
# @public
#------------------------------------------------------------
proc ::sophie::histogram::run { visuNo } {
   variable private

   set ::caption(sophie,histogram,title) "Histogramme"
   set ::caption(sophie,alphaDiff) "Ecart alpha"
   set ::caption(sophie,deltaDiff) "Ecart delta"
   set ::caption(sophie,histogram,startDate) "Heure début"
   set ::caption(sophie,histogram,endDate)   "Heure fin"
   set ::caption(sophie,histogram,clipboard) "Copie vers presse papier"
   set ::caption(sophie,histogram,clear) "Raz affichage"

   set private($visuNo,alphaDiff,show)  1
   set private($visuNo,deltaDiff,show)  1
   set private($visuNo,startDate)       ""
   set private($visuNo,endDate)         ""
   #--- pas des abcisses de l'histogramme
   set private($visuNo,step)     0.2

   #--- nom du fichier qui est affiche
   set private($visuNo,fileName) ""


   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,histogram,position) ] }  { set ::conf(sophie,histogram,position) "300x200+250+75" }

   set private($visuNo,this)   ".audace.sophieHisto$visuNo"

   if { [winfo exists $private($visuNo,this) ] == 0 } {
      uplevel #0 ::blt::vector create ::sophieHistogramAbcisse
      uplevel #0 ::blt::vector create ::sophieHistogramAlphaDiff
      uplevel #0 ::blt::vector create ::sophieHistogramDeltaDiff

      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private($visuNo,this) [namespace current] -modal 0 \
         -geometry $::conf(sophie,histogram,position) \
         -resizable 1
      wm minsize $private($visuNo,this) 440 500

   } else {
      focus $private($visuNo,this)
   }
}


#------------------------------------------------------------
# getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::sophie::histogram::getLabel { } {
   return $::caption(sophie,histogram,title)
}

#------------------------------------------------------------
# showHelp
#  affiche l'aide de la fenêtre
#------------------------------------------------------------
###proc ::sophie::histogram::showHelp { } {
###   variable private
###
###   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::sophie::getPluginType ] ] \
###      [ ::sophie::getPluginDirectory ] [ ::sophie::getPluginHelp ]
###}
###

#------------------------------------------------------------
# closeWindow
#  recupere la position de l'outil apres appui sur Fermer
#
#------------------------------------------------------------
proc ::sophie::histogram::closeWindow { visuNo } {
   variable private

   if { [info  exists private($visuNo,frm)] } {
      if { [winfo exists $private($visuNo,frm)] } {
         ::blt::vector destroy ::sophieHistogramAbcisse
         ::blt::vector destroy ::sophieHistogramAlphaDiff
         ::blt::vector destroy ::sophieHistogramDeltaDiff

         set index [lsearch $private(realTimeVisuNo) $visuNo]
         if { $index != -1 } {
            #--- je supprime la visu de la liste d'abonnement
            set private(realTimeVisuNo) [lreplace $private(realTimeVisuNo) $index $index]
         }
         set private($visuNo,fileName) ""

         #--- je supprime le menubar et toutes ses entrees
         Menubar_Delete "sohpieHistogram${visuNo}"
         #--- je sauve la taille et la position de la fenetre
         set ::conf(sophie,histogram,position) [winfo geometry [winfo toplevel $private($visuNo,frm) ]]
         destroy [ winfo toplevel $private($visuNo,frm) ]
      }
   }
}

#------------------------------------------------------------
# fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::sophie::histogram::fillConfigPage { frm visuNo } {
   variable private

   package require BLT

   #--- je cree le menu
   set private($visuNo,menu) "$private($visuNo,this).menubar"
   set menuNo "sohpieHistogram${visuNo}"
   Menu_Setup $menuNo $private($visuNo,menu)
      Menu           $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,charger)..." \
         "::sophie::histogram::onLoadFile $visuNo"
      Menu_Separator $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,quitter)" \
        "::confGenerique::closeWindow $visuNo [namespace current]"

      Menu           $menuNo "$::caption(audace,menu,affichage)"
      Menu_Check     $menuNo "$::caption(audace,menu,affichage)" "$::caption(sophie,alphaDiff)" \
      "::sophie::histogram::private($visuNo,alphaDiff,show)" "::sophie::histogram::onDisplayLine $visuNo"
      Menu_Check     $menuNo "$::caption(audace,menu,affichage)" "$::caption(sophie,deltaDiff)" \
      "::sophie::histogram::private($visuNo,deltaDiff,show)" "::sophie::histogram::onDisplayLine $visuNo"
      Menu_Separator $menuNo "$::caption(audace,menu,affichage)"

      Menu_Command   $menuNo "$::caption(audace,menu,affichage)" "$::caption(sophie,histogram,clear)" \
      "::sophie::histogram::onClearDisplay $visuNo"
      Menu_Command   $menuNo "$::caption(audace,menu,affichage)" "$::caption(sophie,histogram,clipboard)" \
      "::sophie::histogram::onCopyClipboard $visuNo"
      Menu_Bind $menuNo $private($visuNo,this) <Control-c> "$::caption(audace,menu,affichage)" "$::caption(sophie,histogram,clipboard)" \
      "Ctrl-C"


    [MenuGet $menuNo $::caption(audace,menu,file)]      configure -tearoff 0
    [MenuGet $menuNo $::caption(audace,menu,affichage)] configure -tearoff 0


   #--- Je memorise la reference de la frame
   set private($visuNo,frm)      $frm


   frame $frm.file  -borderwidth 0
      #--- date debut
      label $frm.file.startDateLabel -text $::caption(sophie,histogram,startDate)
      pack $frm.file.startDateLabel -anchor w -side left -padx 2

      entry $frm.file.startDateValue -state readonly \
         -textvariable ::sophie::histogram::private($visuNo,startDate)
      pack $frm.file.startDateValue -side left -padx 2

      #--- date fin
      label $frm.file.endDateLabel -text $::caption(sophie,histogram,endDate)
      pack $frm.file.endDateLabel -anchor w -side left -padx 2

      entry $frm.file.endDateValue -state readonly \
         -textvariable ::sophie::histogram::private($visuNo,endDate)
      pack $frm.file.endDateValue -side left -padx 2
   pack $frm.file -side top -fill x -expand 0


   #--- je cree le graphique
   blt::graph $frm.graph
   pack $frm.graph -side top -fill both -expand 1

   after idle  ::sophie::histogram::configureGraph $visuNo
}


#------------------------------------------------------------
# configureGraph { }
#  configure l'histogramme
#------------------------------------------------------------
proc ::sophie::histogram::configureGraph { visuNo } {
   variable private

   set frm $private($visuNo,frm)
   $frm.graph configure  -plotbackground "white"
   $frm.graph crosshairs off
   $frm.graph crosshairs configure -color red -dashes 2
   $frm.graph axis configure x -hide no -title $::caption(sophie,arcsec)
   $frm.graph axis configure x2 -hide true
   $frm.graph axis configure y2 -hide true
   $frm.graph legend configure -hide yes
   $frm.graph grid configure -hide no -dashes { 2 2 }

   $frm.graph legend configure \
      -hide no -position plotarea -anchor nw -font $::conf(conffont,Label) \
      -borderwidth 0 -relief flat

   $frm.graph element create alphaDiff -mapy y \
         -xdata ::sophieHistogramAbcisse \
         -ydata ::sophieHistogramAlphaDiff \
         -color blue -dash "2" -linewidth 3 \
         -symbol none -label $::caption(sophie,alpha)
   $frm.graph element create deltaDiff -mapy y \
         -xdata ::sophieHistogramAbcisse \
         -ydata ::sophieHistogramDeltaDiff \
         -color orange -dash "" -linewidth 3 \
         -symbol none -label $::caption(sophie,delta)


}

#------------------------------------------------------------
# onLoadFile
#    ouvre le fichier de trace
#
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::sophie::histogram::onLoadFile { visuNo } {
   variable private

   #--- j'ouvre la fenetre de selection du modele de pointage
   set initialdir $::audace(rep_images)
   set filetypes [ list [ list "Log file" "histo*.log" ] ]
   set parent [winfo toplevel $private($visuNo,frm)]
   set title  "::caption(sophie,histogram,title) $::caption(audace,menu,charger)"

   set fileName [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #--- je charge les donnees du modele de pointage
   if { $fileName != "" } {
      set loadDataError [catch {
         displayData $visuNo $fileName
      }]
      if { $loadDataError != 0 } {
         ::tkutil::displayErrorInfo $title
      }
   }
}

#------------------------------------------------------------
# onDisplayLine
#    affiche ou masque les courbes
#
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::sophie::histogram::onDisplayLine { visuNo } {
   variable private

   set frm $private($visuNo,frm)
   $frm.graph element configure alphaDiff -hide [ expr !$private($visuNo,alphaDiff,show) ]
   $frm.graph element configure deltaDiff -hide [ expr !$private($visuNo,deltaDiff,show) ]
}

#------------------------------------------------------------
# onCopyClipboard
#    copy les donnees dans le presse papier
#
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::sophie::histogram::onCopyClipboard { visuNo } {
   variable private

   set len [::sophieHistogramAbcisse length]
   set data ""
   for { set i 0 } { $i < $len } {incr i } {
       append data "$::sophieHistogramAbcisse($i)\t$::sophieHistogramAlphaDiff($i)\t$::sophieHistogramDeltaDiff($i)\n"
   }
   clipboard clear
   clipboard append -type STRING $data
}


#------------------------------------------------------------
# onClearDisplay
#    efface les données affichées
#
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::sophie::histogram::onClearDisplay { visuNo } {
   variable private

   ::sophieHistogramAbcisse set ""
   ::sophieHistogramAlphaDiff set ""
   ::sophieHistogramDeltaDiff set ""
   set private($visuNo,startDate) [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   set private($visuNo,endDate)   ""
}


#------------------------------------------------------------
# displayData { }
#  affiche l'histogramme a parti d'un fichier
#------------------------------------------------------------
proc ::sophie::histogram::displayData { visuNo { fileName "" } } {
   variable private

   if { $fileName == "" } {
      ::sophieHistogramAbcisse set ""
      ::sophieHistogramAlphaDiff set ""
      ::sophieHistogramDeltaDiff set ""
      set private($visuNo,startDate) ""
      set private($visuNo,endDate)   ""
      wm title $private($visuNo,this) "$::caption(sophie,histogram,title) [file tail $fileName]"
      set private($visuNo,fileName) $fileName
   } elseif { [file exists $fileName] } {
      set data [loadData $fileName $private($visuNo,step) ]
      ::sophieHistogramAbcisse set [lindex $data 0]
      ::sophieHistogramAlphaDiff set [lindex $data 1]
      ::sophieHistogramDeltaDiff set [lindex $data 2]
      set private($visuNo,startDate) [lindex $data 3]
      set private($visuNo,endDate) [lindex $data 4]

      wm title $private($visuNo,this) "$::caption(sophie,histogram,title) [file tail $fileName]"
      set private($visuNo,fileName) $fileName

      #--- j'abonne la visu aux evenements temps réel
      set index [lsearch $private(realTimeVisuNo) $visuNo]
      if { $fileName == [getFileName] } {
          if { $index == -1 } {
             #--- j'ajoute la visu dans la liste d'abonnement
             lappend private(realTimeVisuNo) $visuNo
          }
      } else {
         if { $index != -1 } {
            #--- je supprime la visu de la liste d'abonnement
            set private(realTimeVisuNo) [lreplace $private(realTimeVisuNo) $index $index]
         }
      }
   }
}

# ------------------------------------------------------------
# loadData
#   lit un fichier de log
# @param fileName nom du fichier de log
# @public
#------------------------------------------------------------
proc ::sophie::histogram::loadData { fileName { step 0.05 } } {
   variable private

   set hFile ""
   set abcisses   ""
   set xHisto    ""
   set yHisto    ""

   set catchResult [ catch {
      set hfile [open $fileName r]
      set xMinDiff +9999
      set xMaxDiff -9999
      set yMinDiff +9999
      set yMaxDiff -9999
      set pointList ""
      set startDate ""
      set endDate ""

      gets $hfile line
      seek $hfile 0
      if { [string range $line 0 0 ]  == "\["} {
         #--- c'est un ancien format
         #--- je lis le fichier
         while { [gets $hfile line] >= 0} {
            if { [string range $line 0 0 ]  == "\["
               || [string range $line 0 0 ]  == "="
               || [string range $line 0 0 ]  == "-" } {
               continue
            }
            if { [string range $line 0 0 ]  == "-"} {
               continue
            }
            if { [llength $line ] == 3 } {
               if { $startDate == "" } {
                  set startDate [lindex $line 0 ]
               }
               set endDate [lindex $line 0 ]
               set xDiff [lindex $line 1 ]
               set yDiff [lindex $line 2 ]
               lappend pointList [ list $xDiff $yDiff ]
               if { $xDiff < $xMinDiff } {
                  set xMinDiff $xDiff
               }
               if { $xDiff > $xMaxDiff } {
                  set xMaxDiff $xDiff
               }
               if { $yDiff < $yMinDiff } {
                  set yMinDiff $yDiff
               }
               if { $yDiff > $yMaxDiff } {
                  set yMaxDiff $yDiff
               }
            }
         }

      } else {
         #--- je lis le fichier
         while { [gets $hfile line] >= 0} {
            if { [lindex $line 1 ] == "DATA" } {
               if { $startDate == "" } {
                  set startDate [lindex $line 0 ]
               }
               set endDate [lindex $line 0 ]
               set xDiff [lindex $line 2 ]
               set yDiff [lindex $line 3 ]
               lappend pointList [ list $xDiff $yDiff ]
               if { $xDiff < $xMinDiff } {
                  set xMinDiff $xDiff
               }
               if { $xDiff > $xMaxDiff } {
                  set xMaxDiff $xDiff
               }
               if { $yDiff < $yMinDiff } {
                  set yMinDiff $yDiff
               }
               if { $yDiff > $yMaxDiff } {
                  set yMaxDiff $yDiff
               }
            }
         }
      }
      close $hfile
      set hfile ""

      if { $xMinDiff < $yMinDiff } {
         set minAbcisse [expr round($xMinDiff/$step)*$step]
      } else {
         set minAbcisse [expr round($yMinDiff/$step)*$step]
      }
      if { $xMaxDiff > $yMaxDiff } {
         set maxAbcisse [expr round($xMaxDiff/$step)*$step]
      } else {
         set maxAbcisse [expr round($yMaxDiff/$step)*$step]
      }

      #-- j'initalise les vecteurs des abcisses et des ordonnées
      for { set a $minAbcisse } { $a <= $maxAbcisse } {set a [expr $a + $step] } {
          lappend abcisses $a
          lappend xHisto 0
          lappend yHisto 0
      }

      #--- je calcule l'histogramme
      foreach point $pointList {
         set abcisse [expr round([lindex $point 0]/$step)*$step]
         set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]
         #--- j'incremente l'histogramme alpha
         lset xHisto $abcisse [incr [lindex $xHisto $abcisse]]
         set abcisse [expr round([lindex $point 1]/$step)*$step ]
         set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]
         #--- j'incremente l'histogramme delta
         lset yHisto $abcisse [incr [lindex $yHisto $abcisse]]
      }

   }]

   if { $catchResult != 0 } {
       if { $hFile != "" } {
          close $hFile
       }
       error $::errorInfo
   }

   return [list $abcisses $xHisto $yHisto $startDate $endDate]

}

# ------------------------------------------------------------
# writeGuidingStart
#    enregistre l'evenement de debut de guidage dans le fichier courant de log
#
# @public
#------------------------------------------------------------
proc ::sophie::histogram::writeGuidingStart { } {
   variable private

   set fileName [getFileName 1]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date START ------------------------------------------------"
      close $hFile
   }

   #--- je met à jour les visus qui affichent le fichier de log courant
   foreach visuNo $private(realTimeVisuNo)  {
      if { $private($visuNo,startDate) == "" } {
         #--- je mets a jour la date de debut (cas ou la visu est affichée avant la création du fichier de log)
         set private($visuNo,startDate) $date
      }
   }
}

# ------------------------------------------------------------
# writeGuidingStop
#    enregistre un evenement de fin de guidage dans le fichier courant de log
#
# @public
#------------------------------------------------------------
proc ::sophie::histogram::writeGuidingStop { } {
   variable private

   set fileName [getFileName]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date STOP  ------------------------------------------------"
      close $hFile
   }
}


# ------------------------------------------------------------
# writeGuidingInformation
#    enregistre un evenement de correction de guidage dans le fichier courant de log
# @param alphaDiff       ecart RA etoile/consigne (arcsec)
# @param deltaDiff       ecart declinaison etoile/consigne (arcsec)
# @param alphaCorrection correction envoyee au telescope (arcsec)
# @param deltaCorrection correction envoyee au telescope (arcsec)
# @param ra              ascention droite du telescope
# @param dec             declinaison du telescope
# @retunr void
# @public
#------------------------------------------------------------
proc ::sophie::histogram::writeGuidingInformation { alphaDiff deltaDiff alphaCorrection deltaCorrection ra dec } {
   variable private

   set fileName [getFileName]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date DATA  $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection $ra $dec"
      close $hFile
   }

   #--- j'ajoute la nouvelle valeur dans l'histogramme
   foreach visuNo $private(realTimeVisuNo)  {
      set step $private($visuNo,step)

      if { [::sophieHistogramAbcisse length] == 0 } {
         ::sophieHistogramAbcisse set { 0 }
         ::sophieHistogramAlphaDiff set { 0 }
         ::sophieHistogramDeltaDiff set { 0 }
      }

      set minAbcisse $::sophieHistogramAbcisse(min)
      set maxAbcisse $::sophieHistogramAbcisse(max)

      if { $alphaDiff  < $deltaDiff } {
         set newMinAbcisse [expr round($alphaDiff / $step) * $step]
         set newMaxAbcisse [expr round($deltaDiff / $step) * $step]
      } else {
         set newMinAbcisse [expr round($deltaDiff / $step) * $step]
         set newMaxAbcisse [expr round($alphaDiff / $step) * $step]
      }

      #--- j'étends les abcisses si le point est en dehors dde l'intervalle des abcisses exitant
      if { $newMinAbcisse < $minAbcisse } {
         #--- j'ajoute des abcisses à gauche de l'intervalle
         set abcisseList ""
         set alphaList   ""
         set deltaList   ""
         for { set a $newMinAbcisse } { $a < $minAbcisse } {set a [expr $a + $step] } {
             lappend abcisseList $a
             lappend alphaList 0
             lappend deltaList 0
         }
         ::sophieHistogramAbcisse   set [concat $abcisseList [::sophieHistogramAbcisse range 0 end]]
         ::sophieHistogramAlphaDiff set [concat $alphaList [::sophieHistogramAlphaDiff range 0 end]]
         ::sophieHistogramDeltaDiff set [concat $deltaList [::sophieHistogramDeltaDiff range 0 end]]
         set minAbcisse $newMinAbcisse
      }

      if { $newMaxAbcisse > $maxAbcisse } {
         #--- j'ajoute des abcisses à droite de la courbe de l'intervalle
         for { set a [expr $maxAbcisse + $step]  } { $a <= $newMaxAbcisse } {set a [expr $a + $step] } {
            ::sophieHistogramAbcisse append $a
            ::sophieHistogramAlphaDiff append 0
            ::sophieHistogramDeltaDiff append 0
         }
         set maxAbcisse $newMaxAbcisse
      }

      #--- j'incremente les barres des histogrammes
      set alphaIndex [expr round(($alphaDiff - $minAbcisse) / $step) ]
      set ::sophieHistogramAlphaDiff($alphaIndex)  [expr $::sophieHistogramAlphaDiff($alphaIndex) + 1]
      set deltaIndex [expr round(($deltaDiff - $minAbcisse) / $step) ]
      set ::sophieHistogramDeltaDiff($deltaIndex) [expr $::sophieHistogramDeltaDiff($deltaIndex) + 1]

      set private($visuNo,endDate) $date
   }
}

#------------------------------------------------------------
# getFileName
#    retourne le nom courant du fichier de log
#    Si le parametre update=1 , le nom du fichier est mis a jour en fonction de
#    la date courante et un nouveau fichier est créé dans le répertoire audace(rep_images)
#    s'il n'existe pas.
#
# @param update 0=pas de changement du nom du fichier 1=recalcul du nom du fichier
# @return  nom complet du fichier (avec le repertoire)
#------------------------------------------------------------
proc ::sophie::histogram::getFileName { {update 0 } } {
   variable private

   if { $private(realTimeFileName) != ""  && $update == 0 } {
      return $private(realTimeFileName)
   } else {

      #--- Creation du nom de fichier log
      set nom_generique [file join $::audace(rep_images) "histo-ecart-"]
      #--- Heure a partir de laquelle on passe sur un nouveau fichier de log
      if { $::conf(rep_images,refModeAuto) == "0" } {
         set heure_nouveau_fichier "0"
      } else {
         set heure_nouveau_fichier "12"
      }

      set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
      if { $heure_courante < $heure_nouveau_fichier } {
         #--- Si on est avant l'heure de changement, je prends la date de la veille
         set formatdate [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y-%m-%d" ]
      } else {
         #--- Sinon, je prends la date du jour
         set formatdate [ clock format [ clock seconds ] -format "%Y-%m-%d" ]
      }
      append fileName $nom_generique $formatdate ".log"

      set catchResult [ catch {
         set hFile [ open $fileName a ]
         puts  -nonewline $hFile ""
         close $hFile
         set private(realTimeFileName) $fileName
      }]


      if { $catchResult ==1 } {
          if { $hFile != "" } {
             close $hFile
          }
          error $::errorInfo
      }

      return $fileName
   }
}




