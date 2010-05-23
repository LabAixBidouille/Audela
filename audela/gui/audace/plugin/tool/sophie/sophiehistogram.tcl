#
# Fichier : sophiehistogram.tcl
# Description : Fenetre affcihat l'histogramme des ecarts étoile/consigne
# Mise a jour $Id: sophiehistogram.tcl,v 1.2 2010-05-23 16:22:01 michelpujol Exp $
#

namespace eval ::sophie::histogram {
   variable private
   set private(fileName) ""
   set private(newValue) ""
}

# ------------------------------------------------------------
# run
#   affiche la fenetre de l'histogramme
# @param visuNo numero de la visu de la fenetre de l'outil eShel
# @public
#------------------------------------------------------------
proc ::sophie::histogram::run { visuNo { realTime 0}  } {
   variable private

   set ::caption(sophie,histogram,title) "Histogramme"
   set ::caption(sophie,alphaDiff) "Ecart alpha"
   set ::caption(sophie,deltaDiff) "Ecart delta"
   set ::caption(sophie,histogram,startDate) "Heure début"
   set ::caption(sophie,histogram,endDate)   "Heure fin"

   set private($visuNo,realTime)        $realTime
   set private($visuNo,alphaDiff,show)     1
   set private($visuNo,deltaDiff,show)     1
   set private($visuNo,startDate)        ""
   set private($visuNo,endDate)          ""

   #--- nom du fichier qui est affiche
   set private($visuNo,fileName) ""
   #--- pas des abcisses de l'histogramme
   set private(step)     0.05

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,histogram,position) ] }  { set ::conf(sophie,histogram,position) "300x200+250+75" }

   set private($visuNo,this)   ".audace.sophieHisto$visuNo"

   if { [winfo exists $private($visuNo,this) ] == 0 } {
      console::disp "create ::sophie::histogram::abcisse\n"
      ::blt::vector create ::sophie::histogram::abcisse
      ::blt::vector create ::sophie::histogram::alphaDiff
      ::blt::vector create ::sophie::histogram::deltaDiff

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

         console::disp "destroy ::sophie::histogram::abcisse\n"
         ::blt::vector destroy ::sophie::histogram::abcisse
         ::blt::vector destroy ::sophie::histogram::alphaDiff
         ::blt::vector destroy ::sophie::histogram::deltaDiff


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
      if { $private($visuNo,realTime) == 0 } {
         Menu           $menuNo "$::caption(audace,menu,file)"
         Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,charger)..." \
            "::sophie::histogram::onLoadFile $visuNo"
         Menu_Separator $menuNo "$::caption(audace,menu,file)"
      }
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,quitter)" \
        "::confGenerique::closeWindow $visuNo [namespace current] $private($visuNo,this)"

      Menu           $menuNo "$::caption(audace,menu,affichage)"
      Menu_Check     $menuNo "$::caption(audace,menu,affichage)" "$::caption(sophie,alphaDiff)" \
      "::sophie::histogram::private($visuNo,alphaDiff,show)" "::sophie::histogram::onDisplayLine $visuNo"
      Menu_Check     $menuNo "$::caption(audace,menu,affichage)" "$::caption(sophie,deltaDiff)" \
      "::sophie::histogram::private($visuNo,deltaDiff,show)" "::sophie::histogram::onDisplayLine $visuNo"

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
         -xdata ::sophie::histogram::abcisse \
         -ydata ::sophie::histogram::alphaDiff \
         -color blue -dash "2" -linewidth 3 \
         -symbol none -label $::caption(sophie,alpha)
   $frm.graph element create deltaDiff -mapy y \
         -xdata ::sophie::histogram::abcisse \
         -ydata ::sophie::histogram::deltaDiff \
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
   set filetypes [ list [ list "Log file" ".log" ] ]
   set parent [winfo toplevel $private($visuNo,frm)]
   set title  "::caption(sophie,histogram,title) $::caption(audace,menu,charger)"

   set fileName [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #--- je charge les donnees du modele de pointage
   if { $fileName != "" } {

      set loadDataError [catch {
         set data [loadData $fileName]
         ::sophie::histogram::abcisse set [lindex $data 0]
         ::sophie::histogram::alphaDiff set [lindex $data 1]
         ::sophie::histogram::deltaDiff set [lindex $data 2]

         set private($visuNo,startDate) [lindex $data 3]
         set private($visuNo,endDate) [lindex $data 4]

         wm title $private($visuNo,this) "$::caption(sophie,histogram,title) [file tail $fileName]"
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
# displayData { }
#  affiche l'histogramme du fichier du jour
#------------------------------------------------------------
proc ::sophie::histogram::displayData { visuNo } {
   variable private

   set fileName [getFileName]

   if { [file exists $fileName] } {
      set private($visuNo,fileName) $fileName
      set data [loadData $fileName]
      ::sophie::histogram::abcisse set [lindex $data 0]
      ::sophie::histogram::alphaDiff set [lindex $data 1]
      ::sophie::histogram::deltaDiff set [lindex $data 2]

      wm title $private($visuNo,this) "$::caption(sophie,histogram,title) [file tail $fileName]"
   }
}

# ------------------------------------------------------------
# loadData
#   lit un fichier de log
# @param fileName nom du fichier de log
# @public
#------------------------------------------------------------
proc ::sophie::histogram::loadData { fileName } {
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
      set step $private(step)
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
         lset xHisto $abcisse [incr [lindex $xHisto $abcisse]]
         set abcisse [expr round([lindex $point 1]/$step)*$step ]
         set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]
         #--- j'incremente
         lset yHisto $abcisse [incr [lindex $yHisto $abcisse]]
      }

   }]

   if { $catchResult ==1 } {
       if { $hFile != "" } {
          close $hFile
       }
       error $::errorInfo
   }

   return [list $abcisses $xHisto $yHisto $startDate $endDate]

}

# ------------------------------------------------------------
# writeGuidingStart
#    enregistre une donnée dans le fichier courant de log
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
}

# ------------------------------------------------------------
# writeGuidingStop
#    enregistre une donnée dans le fichier courant de log
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
#    enregistre une donnée dans le fichier courant de log
# @param alphaDiff       ecart RA etoile/consigne (arcsec)
# @param deltaDiff       ecart declinaison etoile/consigne (arcsec)
# @param alphaCorrection correction envoyee au telescope (arcsec)
# @param deltaCorrection correction envoyee au telescope (arcsec)
# @param ra              ascention droite du telescope
# @param dec             declinaison du telescope
# @retunr void
# @public
#------------------------------------------------------------
proc ::sophie::histogram::writeGuidingInformation { visuNo alphaDiff deltaDiff alphaCorrection deltaCorrection ra dec } {
   variable private

   set fileName [getFileName]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date DATA  $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection $ra $dec"
      close $hFile
   }

   return
   #--- j'ajoute la nouvelle valeur dans l'histogramme
   if { $private($visuNo,realTime) != 0 } {
      ####--- j'ajoute la valeur dans le graphe FwhmX

      set minAbcisse ::sophie::histogram::abcisse(min)
      set maxAbcisse ::sophie::histogram::abcisse(max)

      #--- je met a jour la courbe alphaDiff
      set abcisse [expr round($alphaDiff/$step)*$step]
      set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]

      if { $abcisse < $minAbcisse } {
         #--- j'ajoute des points à gauche de la courbe
         set abcisseList ""
         set alphaList   ""
         set deltaList   ""
         for { set a $abcisse } { $a < $minAbcisse } {set a [expr $a + $step] } {
             lappend abcisseList $a
             lappend alphaList 0
             lappend deltaList 0
         }
         ::sophie::histogram::abcisse   set [concat $abcisseList [::sophie::histogram::abcisse range 0 end]]
         ::sophie::histogram::alphaDiff set [concat $alphaList [::sophie::histogram::alphaDiff range 0 end]]
         ::sophie::histogram::deltaDiff set [concat $deltaList [::sophie::histogram::deltaDiff range 0 end]]

      } elseif { $abcisse > $maxAbcisse } {
         #--- j'ajoute des points à droite de la courbe
         for { set a [expr $maxAbcisse + $step]  } { $a <= $abcisse } {set a [expr $a + $step] } {
            ::sophie::histogram::abcisse append $a
            ::sophie::histogram::alphaDiff append 0
            ::sophie::histogram::deltaDiff append 0
         }
      }





      ###lset xHisto $abcisse [incr [lindex $xHisto $abcisse]]
      ###set abcisse [expr round([lindex $point 1]/$step)*$step ]
      ###set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]
      ####--- j'incremente
      ###lset yHisto $abcisse [incr [lindex $yHisto $abcisse]]


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

   if { $private(fileName) != ""  && $update == 0 } {
      return $private(fileName)
   } else {

      #--- Creation du nom de fichier log
      set nom_generique "histo-ecart-"
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
         puts  $hFile "# debut de session "
         close $hFile
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




