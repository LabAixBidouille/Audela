#
# Fichier : exportfits.tcl
# Description : Export de fichier au format Fits
# Auteurs : Michel Pujol
# Mise a jour $Id: exportfits.tcl,v 1.1 2009-11-07 08:31:05 michelpujol Exp $
#

################################################################
# namespace ::eshel::exportfits
#
# commandes :
#  ::eshel::exportfits::run
#    affiche une fenetre pour selectionner et exporter les HDU vers un autre fichier FITS
#
################################################################

namespace eval ::eshel::exportfits {

}


#------------------------------------------------------------
# run
#    affiche la fenetre d'export des fichiers fits
# Parameters
#    visuNo          numero de la fenetre
#    inputFileName   nom du fichier d'entree
#    keywordHduIndex   numero du HDU contenant les mots clefs (1 pour le permier HDU)
#    keywordHduIndex   numero du HDU contenant les
# return
#   1 si la saisie est validee
#   0 si la saisie est abandonne
#------------------------------------------------------------
proc ::eshel::exportfits::run { visuNo inputFileName dataHduIndex} {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,exportfitsPosition) ] } { set ::conf(eshel,exportfitsPosition)     "420x440+100+15" }
   if { ! [ info exists ::conf(eshel,exportfits,outputDirectory) ] } { set ::conf(eshel,exportfits,outputDirectory)  $::audace(rep_images) }
   if { ! [ info exists ::conf(eshel,exportfits,outputBitpix) ] }    { set ::conf(eshel,exportfits,outputBitpix)  -32 }

   set private($visuNo,closeWindow) 1
   set private($visuNo,inputFileName) $inputFileName
   set private($visuNo,addKeyword) 1
   set private($visuNo,zipFile)    0
   set private($visuNo,hduList)    ""

   #--- je charge la liste des HDU
   set catchResult [catch {
      loadFile $visuNo $inputFileName $dataHduIndex
   } ]

   if { $catchResult == 1 } {
      #--- j'affiche un message d'erreut
      tk_messageBox -message  $::errorInfo -icon error -title $::caption(eshelvisu,exportfits,title)
      ::console::affiche_erreur "$::errorInfo\n"
      return
   }

   #--- j'affiche la fenetre de controle des mots clefs
   set tkBase [::confVisu::getBase $visuNo]
   set private($visuNo,This) "$tkBase.exportfits"
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::eshel::exportfits" \
      -modal 0 -geometry $::conf(eshel,exportfitsPosition) -resizable 1 ]

   #--- je purge la table
   $private($visuNo,hduTable) delete 0 end
   #--- j'ajoute les lignes dans la table
   foreach hduName $private($visuNo,hduList) {
      addRow $visuNo "end" $hduName
   }

   #--- je selectionne les profils
   return $result
}

#------------------------------------------------------------
# ::eshel::exportfits::getLabel
#   retourne le titre de la fenetre
#------------------------------------------------------------
proc ::eshel::exportfits::getLabel { } {
   return "$::caption(eshelvisu,title) - $::caption(eshelvisu,exportfits,title)"
}


#------------------------------------------------------------
# config::apply
#   export les HDU selectionnes dans des fichiers separes
#------------------------------------------------------------
proc ::eshel::exportfits::apply { visuNo } {
   variable private
   variable widget

   set hFile ""
   set hOutputFile ""

   set ::conf(eshel,exportfits,outputDirectory) [file normalize $widget($visuNo,outputDirectory)]

   set catchResult [catch {
      #--- j'ouvre le fichier d'entree
      set hFile [fits open $private($visuNo,inputFileName)]
      set nbHdu [$hFile info nhdu]

      #--- je balaie la liste des HDU
      set hduNum 1
      foreach hduName $private($visuNo,hduList) {
         #--- je verifie si le HDU a ete selectionne
         if { $private(selectHdu,$hduName) == 1 } {
            #--- je pointe le hdu dans le fichier d'entree
            set extensionType [$hFile move $hduNum]
            #--- je copie le HDU dans le fichier de sortie
            set outpuFileName [file join $::conf(eshel,exportfits,outputDirectory) [file rootname [file tail $private($visuNo,inputFileName)]]]
            append outpuFileName "_$hduName"
            append outpuFileName [file extension $private($visuNo,inputFileName)]

            if { $extensionType == 0 } {
               #--- je verifie que c'est une image 1D
               set hduNaxes [$hFile info imgdim]
               set bitpix    [$hFile info imgType]
               if { [llength $hduNaxes] == 1 && $bitpix != $::conf(eshel,exportfits,outputBitpix) } {
                  #--- je convertis le profil en 32 bits
                  #--- je cree le fichier de sortie
                  file delete -force $outpuFileName
                  set hOutputFile [fits open $outpuFileName 2]
                  set bitpix $::conf(eshel,exportfits,outputBitpix)
                  #--- je cree le HDU
                  $hOutputFile insert image $bitpix "1" [lindex $hduNaxes 0]
                  #--- j'insere l'image
                  $hOutputFile put image 1 [$hFile get image]
                  #--- je copie les mots clefs
                  foreach keyword [$hFile get keyword] {
                     set keywordName [lindex $keyword 0]
                     set keywordValue [lindex $keyword 1]
                     set keywordComment [lindex $keyword 2]
                     if { [lsearch [list NAXIS NAXIS1 BITPIX GCOUNT PCOUNT XTENSION EXTNAME HDUVERS] $keywordName ] != -1 } {
                        continue
                     }
                     $hOutputFile put keyword "$keywordName $keywordValue $keywordComment"
                  }
                  $hOutputFile close
               } else {
                  #--- j'enregistre l'image telle que
                  $hFile copy $outpuFileName
               }
            } else {
               #--- la table est enregistree automatiquement dans le deuxième HDU
               $hFile copy $outpuFileName
            }

            update
         }
         incr hduNum
      }
      #--- je referme le fichier d'entree
      $hFile close

   } ]

   if { $catchResult == 1 } {
      if { $hFile != "" } {
         $hFile close
      }
      if { $hOutputFile != "" } {
         $hOutputFile close
      }
      #--- j'affiche un message d'erreur pour toutes autres erreurs non prevues
      ::tkutil::displayErrorInfo $::caption(eshelvisu,exportfits,title)
      set private($visuNo,closeWindow) 0
  } else {
      set private($visuNo,closeWindow) 1
      set message [format $::caption(eshelvisu,exportfits,exportDone) $::conf(eshel,exportfits,outputDirectory)]
      set choix [ tk_messageBox -type yesno -message $message -icon info -title $::caption(eshelvisu,exportfits,title)]
      if { $choix == "yes" } {
         #--- j'ouvre une fenetre pour afficher des profils
         set visuDir [::confVisu::create]
         #--- je selectionne l'outil eShel Visu
         confVisu::selectTool $visuDir ::eshelvisu
         #--- je pointe le repertoire des images brutes
         set ::eshelvisu::localTable::private($visuDir,directory) $::conf(eshel,exportfits,outputDirectory)
         #--- j'affiche le contenu du répertoire
         ::eshelvisu::localTable::fillTable $visuDir
      }
   }
}

#------------------------------------------------------------
# config::closeWindow
#   ferme la fentre si la commande apply n'a pas detecte d'erreur
#   sinon ne fait rien
# return
#   0  s'il ne faut pas fermer la fenetre
#   rien s'il faut fermer la fenetre
#------------------------------------------------------------
proc ::eshel::exportfits::closeWindow { visuNo } {
   variable private

   if { $private($visuNo,closeWindow) == 0 } {
      set private($visuNo,closeWindow) 1
      #--- je retourne 0 pour empecher la fermeture de la fenetre
      return 0
   }

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,exportfitsPosition) [ wm geometry $private($visuNo,This) ]

   return
}

#------------------------------------------------------------
# config::fillConfigPage
#   cree les widgets de la fenetre de controle
#   return rien
#------------------------------------------------------------
proc ::eshel::exportfits::fillConfigPage { frm visuNo } {
   variable private
   variable widget

   set private($visuNo,frm) $frm

   set widget($visuNo,outputDirectory) [file nativename $::conf(eshel,exportfits,outputDirectory)]

   TitleFrame $frm.file -borderwidth 2 -relief ridge -text $::caption(eshelvisu,exportfits,exportedFile)

      #--- choix : copier dans un fichier ZIP
      checkbutton $frm.file.zip -text $::caption(eshelvisu,exportfits,zipFile) \
         -variable ::eshel::exportfits::private($visuNo,zipFile) -state disabled
      pack $frm.file.zip -in [$frm.file getframe] -side top -fill x -expand 1
      frame $frm.file.directory -borderwidth 0
         Label $frm.file.directory.label -text $::caption(eshelvisu,exportfits,outputDirectory)
         Entry $frm.file.directory.entry -textvariable ::eshel::exportfits::widget($visuNo,outputDirectory)
         Button $frm.file.directory.button -text "..." -command "::eshel::exportfits::selectOuputDirectory $visuNo"
         pack $frm.file.directory.label -side left -fill none -expand 0
         pack $frm.file.directory.entry -side left -fill x -expand 1
         pack $frm.file.directory.button -side left -fill none -expand 0
      pack $frm.file.directory -side bottom -fill x -expand 1
   pack $frm.file -side bottom -fill x -expand 0

   #--- choix des HDU a extraire
   #    un HDU  (par defaut HDU courant)
   #    profils non calibres
   #    profils calibres
   TitleFrame $frm.hdu -borderwidth 2 -relief ridge -text $::caption(eshelvisu,exportfits,selectHDU)
      set private($visuNo,hduTable) $frm.hdu.table
      scrollbar $frm.hdu.ysb -command "$private($visuNo,hduTable) yview"
      scrollbar $frm.hdu.xsb -command "$private($visuNo,hduTable) xview" -orient horizontal
      ::tablelist::tablelist $private($visuNo,hduTable) \
            -columns [ list \
               0   "Export" left  \
               0  "HDU"  center \
               ] \
            -xscrollcommand [list $frm.hdu.xsb set] -yscrollcommand [list $frm.hdu.ysb set] \
            -exportselection 0 \
            -setfocus 1 \
            -activestyle none
      #--- je donne un nom a chaque colonne
      $private($visuNo,hduTable) columnconfigure 0 -name hduSelect -editwindow checkbutton
      $private($visuNo,hduTable) columnconfigure 1 -name hduName -stretchable 1

      #--- Boutons de selection predefinie des HDU
      frame $frm.hdu.select
         button $frm.hdu.select.current -text $::caption(eshelvisu,exportfits,selectCurrent) \
            -command "::eshel::exportfits::selectHdu $visuNo CURRENT"
         button $frm.hdu.select.p1A -text $::caption(eshelvisu,exportfits,selectP1A) \
            -command "::eshel::exportfits::selectHdu $visuNo P1A"
         button $frm.hdu.select.p1B -text $::caption(eshelvisu,exportfits,selectP1B) \
            -command "::eshel::exportfits::selectHdu $visuNo P1B"
         button $frm.hdu.select.flat1A -text $::caption(eshelvisu,exportfits,selectFlat1A) \
            -command "::eshel::exportfits::selectHdu $visuNo FLAT1A"
         button $frm.hdu.select.flat1B -text $::caption(eshelvisu,exportfits,selectFlat1B) \
            -command "::eshel::exportfits::selectHdu $visuNo FLAT1B"
         button $frm.hdu.select.all -text $::caption(eshelvisu,exportfits,selectAll) \
            -command "::eshel::exportfits::selectHdu $visuNo ALL"
         button $frm.hdu.select.none -text $::caption(eshelvisu,exportfits,selectNone) \
            -command "::eshel::exportfits::selectHdu $visuNo NONE"
         pack $frm.hdu.select.current -side top -fill x -expand 0  -padx 2 -pady 2
         pack $frm.hdu.select.p1A  -side top -fill x -expand 0 -padx 2 -pady 2
         pack $frm.hdu.select.p1B  -side top -fill x -expand 0 -padx 2 -pady 2
         pack $frm.hdu.select.flat1A  -side top -fill x -expand 0 -padx 2 -pady 2
         pack $frm.hdu.select.flat1B  -side top -fill x -expand 0 -padx 2 -pady 2
         pack $frm.hdu.select.all  -side top -fill x -expand 0 -padx 2 -pady 2
         pack $frm.hdu.select.none -side top -fill x -expand 0 -padx 2 -pady 2

      #--- choix ajouter les mots clefs du premier HDU
      checkbutton $frm.hdu.keyword -text $::caption(eshelvisu,exportfits,keyword) \
         -variable ::eshel::exportfits::private($visuNo,addKeyword)

      #--- je positionne les widgets dans la frame
      grid $private($visuNo,hduTable) -in [$frm.hdu getframe] -row 0 -column 0 -sticky nsew
      grid $frm.hdu.ysb     -in [$frm.hdu getframe] -row 0 -column 1 -sticky nsew
      grid $frm.hdu.xsb     -in [$frm.hdu getframe] -row 1 -column 0 -sticky ew
      grid $frm.hdu.select  -in [$frm.hdu getframe] -row 0 -column 2 -columnspan 1 -sticky ewns
      grid $frm.hdu.keyword -in [$frm.hdu getframe] -row 2 -column 0 -columnspan 2 -sticky ew
      grid rowconfig    [$frm.hdu getframe]  0 -weight 1
      grid rowconfig    [$frm.hdu getframe]  1 -weight 0
      grid rowconfig    [$frm.hdu getframe]  2 -weight 0
      grid columnconfig [$frm.hdu getframe]  0 -weight 1
      grid columnconfig [$frm.hdu getframe]  1 -weight 0
      grid columnconfig [$frm.hdu getframe]  2 -weight 0
   pack $frm.hdu -side top -fill both -expand 1

}

#------------------------------------------------------------
#  addRow
#     ajoute une ligne dans la table
#------------------------------------------------------------
proc ::eshel::exportfits::addRow { visuNo rowIndex hduName } {
   variable private

   $private($visuNo,hduTable) insert $rowIndex [list "" $hduName]
   $private($visuNo,hduTable) cellconfigure $rowIndex,hduSelect \
      -window [ list ::eshel::exportfits::createCheckbutton $hduName ] \
      -windowdestroy [ list ::eshel::exportfits::deleteCheckbutton ]
   $private($visuNo,hduTable) rowconfigure $rowIndex -name $hduName
}

#------------------------------------------------------------------------------
# createCheckbutton
#    cree un checkbutton dans la table
#
# Parametres :
#    rowName      : nom de la ligne (correspondant au nopm de l'étoile)
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::eshel::exportfits::createCheckbutton { hduName tkTable row col w } {
   variable private
   #--- je cree la variable qui contient l'état du checkbutton
   set private(selectHdu,$hduName) 0
   #--- je cree le checkbutton
   checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::eshel::exportfits::private(selectHdu,$hduName)
}

#------------------------------------------------------------------------------
# deleteCheckbutton
#    supprime un checkbutton dans la table
#
# Parametres :
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::eshel::exportfits::deleteCheckbutton { tkTable row col w } {
   variable private
   set hduName [$tkTable cellcget $row,hduName -text]
   #--- je supprime le checkbutton
   destroy $w
   #--- je supprime la variable qui contient l'etat du checkbutton
   unset private(selectHdu,$hduName)
}


#------------------------------------------------------------
# ::eshel::process::loadFile
#    charge un fichier FITS Eshel
# Parameters
#    fileName   nom du fichier d'entree
#    keywordHduIndex   numero du HDU contenant les mots clefs (1 pour le permier HDU)
#    dataHduIndex      numero du HDU contenant le profil      (1 pour le permier HDU)
# return
#
#------------------------------------------------------------
proc ::eshel::exportfits::loadFile { visuNo inputFileName dataHduIndex} {
   variable private

   set hFile ""

   #--- j'ouvre le fichier
   set catchResult [catch {

      #--- j'ouvre le fichier d'entree
      set hFile [fits open $inputFileName]
      set nbHdu [$hFile info nhdu]

      #--- je verifie que le keywordHduIndex existe dans le fichier
      if { $dataHduIndex < 1 || $dataHduIndex > $nbHdu } {
         $hFile close
         error "Invalid HDU $dataHduIndex"
      }

      #--- prepare la liste des HDU
      set private($visuNo,hduList) ""
      for { set i 1 } { $i <= $nbHdu } { incr i } {
         $hFile move $i
         if { $i != 1 } {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         } else {
            set hduName "PRIMARY"
         }
         lappend private($visuNo,hduList) $hduName
         if { $i == $dataHduIndex } {
            set private($visuNo,currentHduName) $hduName
         }
      }
   } ]

   #--- je referme le fichier d'entree
   if { $hFile != "" } {
      $hFile close
   }

   #--- je traite les cas d'erreur
   if { $catchResult == 1 } {
      #--- je transmet l'erreur a la procedure appelante.
      error $::errorInfo
   }
}

#------------------------------------------------------------
# selectHdu
#   selectionne les profils a exporter
#
# Parameters
#    visuNo          nom du fichier d'entree
#    mode   : CURRENT_HDU = current HDU
#             CALIBRATED_PROFILES = calibrated profiles
# return
#   rien
#------------------------------------------------------------
proc ::eshel::exportfits::selectHdu { visuNo mode } {
   variable private

   switch $mode {
      CURRENT {
         #--- je coche le HDU courant
         foreach hduName $private($visuNo,hduList) {
            if { $hduName == $private($visuNo,currentHduName) } {
               set private(selectHdu,$hduName) 1
            } else {
               set private(selectHdu,$hduName) 0
            }
         }

      }
      P1A {
         #--- je coche les profils non calibres
         foreach hduName $private($visuNo,hduList) {
            if { [string equal -length 5 $hduName "P_1A_"] == 1 } {
               set private(selectHdu,$hduName) 1
            } else {
               set private(selectHdu,$hduName) 0
            }
         }
      }
      P1B {
         #--- je coche les profils calibres
         foreach hduName $private($visuNo,hduList) {
            if { [string equal -length 5 $hduName "P_1B_"] == 1 } {
               set private(selectHdu,$hduName) 1
            } else {
               set private(selectHdu,$hduName) 0
            }
         }
      }
      FLAT1A {
         #--- je coche les profils non calibres
         foreach hduName $private($visuNo,hduList) {
            if { [string equal -length 8 $hduName "FLAT_1A_"] == 1 } {
               set private(selectHdu,$hduName) 1
            } else {
               set private(selectHdu,$hduName) 0
            }
         }
      }
      FLAT1B {
         #--- je coche les profils calibres
         foreach hduName $private($visuNo,hduList) {
            if { [string equal -length 8 $hduName "FLAT_1B_"] == 1 } {
               set private(selectHdu,$hduName) 1
            } else {
               set private(selectHdu,$hduName) 0
            }
         }
      }
      ALL {
         #--- je decoche tout
         foreach hduName $private($visuNo,hduList) {
            set private(selectHdu,$hduName) 1
         }
      }
      NONE  {
         #--- je decoche tout
         foreach hduName $private($visuNo,hduList) {
            set private(selectHdu,$hduName) 0
         }
      }
   }
}

##------------------------------------------------------------
# selectOuputDirectory
#   selectionne le nom du fichier de sortie
# @param numéro de la visu
# @return rien
#------------------------------------------------------------
proc ::eshel::exportfits::selectOuputDirectory { visuNo } {
   variable private
   variable widget

   #--- j'ouvre la fenetre de choix du repertoire d'export FITS
   set outputDirectory [ tk_chooseDirectory -title $::caption(eshelvisu,exportfits,title)  \
      -initialdir $::conf(eshel,exportfits,outputDirectory) \
      -parent [winfo toplevel $private($visuNo,frm)] ]

   #--- j'abandonne si aucun nom de fichier n'a ete saisi
   if { $outputDirectory == "" } {
         return
   } else {
      set widget($visuNo,outputDirectory) [file nativename $outputDirectory]
   }
}

