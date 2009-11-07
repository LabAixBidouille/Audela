##
# @file processgui.tcl
# Description : Fentre de configuration des traitements eShel
# Auteur : Michel PUJOL
# Mise a jour $Id: processgui.tcl,v 1.1 2009-11-07 08:13:07 michelpujol Exp $
#

##------------------------------------------------------------
# namespace ::eshel::processgui
#
# @short Fenetre de configuration des traitements
#
# Fenetre de configuration des traitements
#
# Point d'entre principal
#  ::eshel::processgui::run
#------------------------------------------------------------
namespace eval ::eshel::processgui {
   variable private

   package require dom
   set private(frm) ""
}

##------------------------------------------------------------
# affiche la fenetre de configuration des traitements
#
# @param tkbase nom tk de la visu qui lance la fenetre
# @param visuNo numero visu qui lance la fenetre
# @return  rien
# @public
#------------------------------------------------------------
proc ::eshel::processgui::run { tkbase visuNo } {
   variable private

   package require Tablelist
   tablelist::addBWidgetComboBox

   set private(modifiedTable) 0
   set private(sortedColumn)  0

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,processWindowPosition) ] } { set ::conf(eshel,processWindowPosition)     "650x240+350+15" }


   #--- j'affiche la fenetre
   set private(This) "$tkbase.process"
   ::confGenerique::run  $visuNo $private(This) "::eshel::processgui" -modal 0 -geometry $::conf(eshel,processWindowPosition) -resizable 1
   wm minsize $private(This) 450 450
}

##------------------------------------------------------------
#   ferme la fenetre
# @param visuNo numero visu qui lance la fenetre
# @return  rien
# @public
#------------------------------------------------------------
proc ::eshel::processgui::closeWindow { visuNo } {
   variable private

   #--- je memoririse la position courante de la fenetre
   set ::conf(eshel,processWindowPosition) [ wm geometry $private(This) ]
}

##------------------------------------------------------------
# Affiche l'aide de cet outil
# @return  rien
# @public
#------------------------------------------------------------
proc ::eshel::processgui::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
      [::eshel::getPluginDirectory] [::eshel::getPluginHelp] "process"
}

##------------------------------------------------------------
# Retourne le titre de la fenetre de traitement
# @return titre de la fenetre de traitement
# @public
#------------------------------------------------------------
proc ::eshel::processgui::getLabel { } {
   return "$::caption(eshel,title) $::caption(eshel,process)"
}

##------------------------------------------------------------
# cree les onglets dans la fenetre
#
# @param frm nom tk de la frame cree par ::confgene::fillConfigPage
# @param visuNo numero visu qui lance la fenetre
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::fillConfigPage { frm visuNo } {
   variable private

   set private(frm) $frm

   #--- creation des boutons
   TitleFrame $frm.button -borderwidth 2 -relief ridge -text "$::caption(eshel,process,manualCommand)"
      Button  $frm.generateAndStart -text "$::caption(eshel,process,generateAndStart)" \
         -command "::eshel::processgui::generateAndStartStartScript"
      pack  $frm.generateAndStart  -in [$frm.button getframe] -side left -fill none -expand 1 -pady 4
      ##checkbutton $frm.auto -text "$::caption(eshel,processAuto)" \
      ##   -variable ::conf(eshel,processAuto) \
      ##   -command "::eshel::processgui::setProcessAuto"
      ##pack  $frm.auto  -in [$frm.button getframe] -side right -fill none -expand 0 -pady 4
      ###Button  $frm.stop -text "$::caption(eshel,process,stop)" \
      ###   -command "::eshel::processgui::stopScript"
      ###pack  $frm.stop  -in [$frm.button getframe] -side left -fill none -expand 1 -pady 4
   pack $frm.button -side top -fill x -expand 0


   #--- Creation des onglets
   set notebook [ NoteBook $frm.notebook ]
   ###$notebook insert end "main"  -text $::caption(eshel,process,title)
   $notebook insert end "roadmap"  -text $::caption(eshel,process,roadmap)
   $notebook insert end "nightlog" -text $::caption(eshel,process,rawImage)
   $notebook insert end "reference" -text $::caption(eshel,process,referenceImage)
   pack $frm.notebook  -side top -fill both -expand 1

   ###set private(mainFrame) [$notebook getframe "main"]
   set private(rawFrame) [$notebook getframe "nightlog"]
   set private(referenceFrame) [$notebook getframe "reference"]
   set private(roadmapFrame) [$notebook getframe "roadmap"]

   #--- j'affiche les wigdets dans les frames
   fillRawPage       $private(rawFrame)  $visuNo
   fillReferencePage $private(referenceFrame) $visuNo
   fillRoadmapPage   $private(roadmapFrame)   $visuNo

   pack $frm  -side top -fill both -expand 1

   #--- je mets a jour les widgets en fonction du mode de traitement
   setProcessAuto

   #--- je selectionne le premier onglet
   $notebook raise "roadmap"

   #--- j'affiche les traitements en cours
   ::eshel::processgui::copyRawToTable
   ::eshel::processgui::copyReferenceToTable
   ::eshel::processgui::copyRoadmapToTable

}


##------------------------------------------------------------
# Cree les widgets dans l'onglet des images brutes
#
# @param frm nom tk de la frame cree par ::eshel::processgui::fillConfigPage
# @param visuNo numero visu qui lance la fenetre
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::fillRawPage { frm visuNo } {
   variable private

   #--- frame des boutons
   frame $frm.button -borderwidth 0 -relief raised
      button $frm.button.makeSerie -text $::caption(eshel,process,makeSerie) -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::makeSeries $visuNo"
      pack $frm.button.makeSerie  -side left -fill none -expand 0
      button $frm.button.removeSerie -text $::caption(eshel,process,remove) -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::removeSerie"
      pack $frm.button.removeSerie  -side left -fill none -expand 0

   pack $frm.button -side bottom -fill x -expand 0

   set paned [PanedWindow $frm.paned -side left]
   set paned1 [$frm.paned add]
   set private(serieTable) $paned1.serie.table
   set private(serieMenu)  $paned1.serie.menu

   #--- frame des series
   TitleFrame $paned1.serie -borderwidth 2 -relief ridge -text "$::caption(eshel,process,serie)"
      #--- scrollbars
      scrollbar $paned1.serie.ysb -command "$private(serieTable) yview"
      scrollbar $paned1.serie.xsb -command "$private(serieTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      foreach keywordName [::eshel::process::getSerieAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      ###tablelist::addBWidgetComboBox
      #--- Table des series
      ::tablelist::tablelist $private(serieTable) \
         -columns $columnList \
         -xscrollcommand [list $paned1.serie.xsb set] \
         -yscrollcommand [list $paned1.serie.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -editstartcommand "::eshel::processgui::onEditStartTable"  \
         -activestyle none

      #--- je donne un nom a chaque colonne
      set col 0
      foreach keywordName [::eshel::process::getSerieAttributeNames] {
         $private(serieTable) columnconfigure $col -name $keywordName
         incr col
      }

      $private(serieTable) columnconfigure FILES -editable yes -editwindow ComboBox

      #--- je place la table et les scrollbars dans la frame
      grid $private(serieTable) -in [$paned1.serie getframe] -row 0 -column 0 -sticky ewns
      grid $paned1.serie.ysb -in [$paned1.serie getframe] -row 0 -column 1 -sticky nsew
      grid $paned1.serie.xsb -in [$paned1.serie getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$paned1.serie getframe] 0 -weight 1
      grid columnconfig [$paned1.serie getframe] 0 -weight 1

   pack $paned1.serie -side top -fill both -expand 1

   #--- frame de la table des fichiers
   set paned2 [$frm.paned add]
   set private(fileTable) $paned2.file.table
   set private(fileMenu)  $paned2.file.menu

   TitleFrame $paned2.file -borderwidth 2 -relief ridge -text "$::caption(eshel,process,file)"
      #--- scrollbars
      scrollbar $paned2.file.ysb -command "$private(fileTable) yview"
      scrollbar $paned2.file.xsb -command "$private(fileTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      set columnList [list 0 FileName left ]
      foreach keywordName [::eshel::process::getFileAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      #--- Table des fichiers
      ::tablelist::tablelist $private(fileTable) \
         -columns $columnList \
         -xscrollcommand [list $paned2.file.xsb set] \
         -yscrollcommand [list $paned2.file.ysb set] \
         -labelcommand "::eshel::processgui::cmdSortColumn" \
         -exportselection 0 \
         -selectmode extended \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -editendcommand "::eshel::processgui::onEditEndTable"  \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private(fileTable) columnconfigure 0 -name "FILENAME" -align left
      set col 1
      foreach keywordName [::eshel::process::getFileAttributeNames] {
         $private(fileTable) columnconfigure $col -name $keywordName
         incr col
      }

      #--- je place la table et les scrollbars dans la frame
      grid $private(fileTable) -in [$paned2.file getframe] -row 0 -column 0 -sticky ewns
      grid $paned2.file.ysb -in [$paned2.file getframe] -row 0 -column 1 -sticky nsew
      grid $paned2.file.xsb -in [$paned2.file getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$paned2.file getframe] 0 -weight 1
      grid columnconfig [$paned2.file getframe] 0 -weight 1

   pack $paned2.file -side top -fill both -expand 1

   pack $paned -side top -fill both -expand 1

   #--- pop-up menu associe a la table des series
   menu $private(serieMenu) -tearoff no
   $private(serieMenu) add command -label $::caption(eshel,process,remove)  \
      -command "::eshel::processgui::removeSerie"

   bind [$private(serieTable) bodypath] <<Button3>> [list tk_popup $private(serieMenu) %X %Y]

   #--- pop-up menu associe a la table des fichiers ignores
   menu $private(fileMenu) -tearoff no
   $private(fileMenu) add command -label $::caption(eshel,process,makeSerie)  \
      -command "::eshel::processgui::makeSeries $visuNo"

   bind [$private(fileTable) bodypath] <<Button3>> [list tk_popup $private(fileMenu) %X %Y]

}

##------------------------------------------------------------
#   cree les widgets dans l'onglet des images de reference
# @param frm nom tk de la frame cree par ::eshel::processgui::fillConfigPage
# @param visuNo numero visu qui lance la fenetre
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::fillReferencePage { frm visuNo } {
   variable private

   set private(referenceTable) $frm.reference.table

   #--- frame des series
   TitleFrame $frm.reference -borderwidth 2 -relief ridge -text "$::caption(eshel,process,referenceImage)"
      #--- scrollbars
      scrollbar $frm.reference.ysb -command "$private(referenceTable) yview"
      scrollbar $frm.reference.xsb -command "$private(referenceTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      foreach keywordName [::eshel::process::getReferenceAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      #--- Table des series
      ::tablelist::tablelist $private(referenceTable) \
         -columns $columnList \
         -xscrollcommand [list $frm.reference.xsb set] \
         -yscrollcommand [list $frm.reference.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      set col 0
      foreach keywordName [::eshel::process::getReferenceAttributeNames] {
         $private(referenceTable) columnconfigure $col -name $keywordName
         incr col
      }
      $private(referenceTable) columnconfigure FILENAME -align left

      #--- je place la table et les scrollbars dans la frame
      grid $private(referenceTable) -in [$frm.reference getframe] -row 0 -column 0 -sticky ewns
      grid $frm.reference.ysb -in [$frm.reference getframe] -row 0 -column 1 -sticky nsew
      grid $frm.reference.xsb -in [$frm.reference getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.reference getframe] 0 -weight 1
      grid columnconfig [$frm.reference getframe] 0 -weight 1

   pack $frm.reference -side top -fill both -expand 1
}


##------------------------------------------------------------
#   cree les widgets dans l'onglet des traitements
# @param frm nom tk de la frame cree par ::eshel::processgui::fillConfigPage
# @param visuNo numero visu qui lance la fenetre
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::fillRoadmapPage { frm visuNo } {
   variable private
   set private(roadmapTable) $frm.roadmap.table

   #--- frame des boutons
   frame $frm.button -borderwidth 0 -relief raised
      Button  $frm.button.generate -text "$::caption(eshel,process,generateRoadmap)" \
         -command "::eshel::processgui::generateRoadmap "
      pack  $frm.button.generate -side left -fill none -expand 1 -pady 4
      Button $frm.button.editScript -text "$::caption(eshel,process,editScript)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::editScript"
      pack $frm.button.editScript  -side left -fill none -expand 0
      Button  $frm.button.startScript -text "$::caption(eshel,process,startScript)" \
         -command "::eshel::processgui::startScript"
      pack  $frm.button.startScript -side left -fill none -expand 1 -pady 4
   pack $frm.button -side bottom -fill x -expand 0

   #--- frame de la table
   TitleFrame $frm.roadmap -borderwidth 2 -relief ridge -text "$::caption(eshel,process,roadmap)"
      #--- scrollbars
      scrollbar $frm.roadmap.ysb -command "$private(roadmapTable) yview"
      scrollbar $frm.roadmap.xsb -command "$private(roadmapTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      set columnList [list 0 "PROCESS" left 0 "OUTPUTFILE" left 0 "STATUS" left 0 "COMMENT" left ]

      #--- Table des series
      ::tablelist::tablelist $private(roadmapTable) \
         -columns $columnList \
         -xscrollcommand [list $frm.roadmap.xsb set] \
         -yscrollcommand [list $frm.roadmap.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private(roadmapTable) columnconfigure 0 -name "PROCESS"
      $private(roadmapTable) columnconfigure 1 -name "OUTPUTFILE"
      $private(roadmapTable) columnconfigure 2 -name "STATUS"
      $private(roadmapTable) columnconfigure 3 -name "COMMENT"

      #--- je place la table et les scrollbars dans la frame
      grid $private(roadmapTable) -in [$frm.roadmap getframe] -row 0 -column 0 -sticky ewns
      grid $frm.roadmap.ysb -in [$frm.roadmap getframe] -row 0 -column 1 -sticky nsew
      grid $frm.roadmap.xsb -in [$frm.roadmap getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.roadmap getframe] 0 -weight 1
      grid columnconfig [$frm.roadmap getframe] 0 -weight 1

   pack $frm.roadmap -side top -fill both -expand 1
}




##----------------------------------------------------------------------------
#   - desactive les boutons manuels si le mode automatique est sélectionne
#   - active les boutons manuels si le mode manuel est sélectionne
# @return  rien
# @public
#----------------------------------------------------------------------------
proc ::eshel::processgui::setProcessAuto {  } {
   setFrameState
}


##------------------------------------------------------------------------------
#   trie les lignes par ordre alphabetique de la colonne
#   (est appele quand on clique sur le titre de la colonne)
# @return  rien
# @private
#------------------------------------------------------------------------------
proc ::eshel::processgui::cmdSortColumn { tbl col } {
   variable private
   set private(sortedColumn) $col
   tablelist::sortByColumn $tbl $col
}

##-----------------------------------------------------------
#   Genere et affiche la roadmap des traitements a faire.
#   Desactive les boutons manuels pendant le calcul de la roadmap
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::generateRoadmap { } {
   variable private

   set catchResult [catch {
      ::eshel::process::generateAll
   } ]

   if { $catchResult != 0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

##
#   affiche la liste des images brutes
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::copyRawToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   #--- je vide la table des fichiers ignores
   $private(fileTable)  delete 0 end
   #--- je vide la table des series identifiees
   $private(serieTable)  delete 0 end


   #--- je remplis les tables des fichiers bruts
   set filesNode [::eshel::process::getFilesNode]
   foreach fileNode [::dom::tcl::node children $filesNode] {
      if { [::dom::tcl::node cget $fileNode -nodeName] == "FILE" } {
         set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         #--- j'insere la nouvelle ligne à la fin de la table
         $private(fileTable) insert end $fileName
         foreach keywordName [::eshel::process::getFileAttributeNames] {
            set keywordValue [ ::dom::element getAttribute $fileNode $keywordName]
            #--- je copie l'attribut dans la colonne du mot clef
            $private(fileTable) cellconfigure end,$keywordName -text $keywordValue -editable 1
         }
      } else {
         if { [::dom::element getAttribute $fileNode "RAW"] == 1 } {
            #--- j'insere une ligne vide à la fin de la table
            $private(serieTable) insert end " "
            #--- je renseigne les cellules de la ligne vide
            foreach keywordName [::eshel::process::getSerieAttributeNames] {
               switch $keywordName {
                  "FILES" {
                     #--- j'affiche le nombre de fichiers
                     ##set firstFileNode [::dom::tcl::node cget $fileNode -firstChild ]
                     ##set firstFileName [::dom::element getAttribute $firstFileNode "FILENAME"]
                     set nbFiles [llength [::dom::tcl::node children $fileNode]]
                     #--- la cellule est editable pour pouvoir conculter son contenu (voir onEditStartTable)
                     $private(serieTable) cellconfigure end,$keywordName -text $nbFiles -editable 1
                  }
                  default {
                     set keywordValue [::dom::element getAttribute $fileNode $keywordName]
                     $private(serieTable) cellconfigure end,$keywordName -text $keywordValue
                  }
               }
            }
         }
      }
   }

   #--- je trie la table
   $private(fileTable) sortbycolumn  $private(sortedColumn) -increasing
}

##------------------------------------------------------------
#   affiche les images de référence
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::copyReferenceToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }
   #--- je vide la table des fichiers de reference
   $private(referenceTable)  delete 0 end

   #--- je remplis les tables des fichiers de reference
   set filesNode [::eshel::process::getFilesNode]
   foreach fileNode [::dom::tcl::node children $filesNode] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         #--- j'insere la nouvelle ligne à la fin de la table
         $private(referenceTable) insert end $fileName
         foreach keywordName [::eshel::process::getReferenceAttributeNames] {
            set keywordValue [ ::dom::element getAttribute $fileNode $keywordName]
            #--- je copie l'attribut dans la colonne du mot clef
            $private(referenceTable) cellconfigure end,$keywordName -text $keywordValue -editable 0
         }
         set nodeName [::dom::tcl::node cget $fileNode -nodeName]
         if { $nodeName == "BAD_REF" } {
            $private(referenceTable) rowconfigure end -foreground red
         }
      }
   }
}

##------------------------------------------------------------
#   affiche les processus  dans la table
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::copyRoadmapToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }
   #--- je vide la table des traitements
   $private(roadmapTable)  delete 0 end

   #--- je remplis les tables des fichiers de reference
   foreach processNode [::dom::tcl::node children [::eshel::process::getRoadmapNode]] {
      set nodeName [::dom::tcl::node cget $processNode -nodeName]
      #--- je recupere le premier node qui est l'image en sortie
      set fileName   [::dom::element getAttribute $processNode "FILENAME"]
      set status     [::dom::element getAttribute $processNode "STATUS"]
      set comment    [::dom::element getAttribute $processNode "COMMENT"]

      $private(roadmapTable) insert end [list $nodeName $fileName $status $comment ]
      #--- je donne un nom a la ligne = nom de l'image en sortie du traitement
      $private(roadmapTable) rowconfigure end -name $fileName
      #--- j'affiche le status et la couleur associee
      setProcessStatus $fileName $status
   }
}

##----------------------------------------------------------------------------
# met à jour l'état de traitement d'un fichier
#   - todo    : traitement à faire
#   - running : traitement en cours
#   - done    : traitement termine correctement.
#   - error   :  erreur pendant le traitement
#
# @param fileName nom du fichier
# @param status   état du fichier
# @return  rien
# @public
#----------------------------------------------------------------------------
proc ::eshel::processgui::setProcessStatus { fileName status } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   #--- j'affiche le status
   $private(roadmapTable) cellconfigure $fileName,STATUS -text $status
   #--- je change la couleur
   switch $status {
      todo {
         $private(roadmapTable) rowconfigure $fileName -foreground black
      }
      running {
         $private(roadmapTable) rowconfigure $fileName -foreground blue
      }
      done {
         $private(roadmapTable) rowconfigure $fileName -foreground black
      }
      error {
         $private(roadmapTable) rowconfigure $fileName -foreground red
      }
   }
}



##------------------------------------------------------------
# copyTableToNightlog
#   enregistre les modifications des fichiers ignores faites par l'utilsateur
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::copyTableToNightlog { } {
   variable private

   #--- je copie les données de la table dans attributeList
   for { set rowIndex 0 } { $rowIndex < [$private(fileTable) size] } { incr rowIndex } {
      set attributeList ""
      set fileName  [$private(fileTable) cellcget $rowIndex,FILENAME -text]
      foreach keywordName [::eshel::process::getFileAttributeNames] {
         set keywordValue [string trim [$private(fileTable) cellcget $rowIndex,$keywordName -text]]
         lappend attributeList $keywordName $keywordValue
      }
      #--- je mets a jour les donnees de nightlog
      ::eshel::process::setFileAttributes $fileName $attributeList
   }
}

##------------------------------------------------------------
#   efface le contenu des tables
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::resetTables { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   set private(roadmapDate)   ""
   set private(validNb)       0
   set private(referenceNb)   0
   set private(ignoredNb)     0
   set private(processNb)     0

   #--- je vide la table des fichiers ignores
   $private(fileTable)  delete 0 end
   #--- je vide la table des series identifiees
   $private(serieTable)  delete 0 end
   #--- je vide la table des fichiers de reference
   $private(referenceTable)  delete 0 end
   #--- je vide la table des traitements
   $private(roadmapTable)  delete 0 end
   update

}


##------------------------------------------------------------
# onEditStartTable
#   affiche le details de fichiers dans la colonne FILES
#   de la table des series
#  Cette procedure est appellee par le ::tablelist quand l'utilisateur selectionne une cellule
# @param tktable nom tk de la table
# @param row      numero de ligne
# @param col      numero de colonne
# @param value    valeur de la cellule
# @return  valeur validee de la cellule
# @private
#------------------------------------------------------------
proc ::eshel::processgui::onEditStartTable { tktable row col value } {
   variable private
   set w [$tktable editwinpath]
   switch [$tktable columncget $col -name] {
      FILES {
         #--- petite astuce pour toujours afficher le nombre de fichier dans l'entry de la combobox
         $w configure -modifycmd "$w.e configure -text [$w get]" -editable 0
         #--- je recupere l'indentifant de la série
         set serieId [$tktable cellcget $row,SERIESID -text]
         #--- j'affiche la liste des fichiers de la serie
         set filesNode [::eshel::process::getFilesNode]
         foreach serieNode [::dom::tcl::node children $filesNode] {
            if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId } {
               foreach fileNode [::dom::tcl::node children $serieNode] {
                  $w insert end [::dom::element getAttribute $fileNode "FILENAME"]
               }
               break
            }
         }

      }
   }
   return $value
}

##------------------------------------------------------------
# onEditEndTable
#   positionne le flag quand la table des fichiers non identifiés
#    est modifiee
# @param tktable nom tk de la table
# @param row      numero de ligne
# @param col      numero de colonne
# @param value    valeur de la cellule
# @return  valeur validee de la cellule
# @private
#------------------------------------------------------------
proc ::eshel::processgui::onEditEndTable { tktable row col value } {
   variable private

   set private(modifiedTable) 1
   return $value
}

##------------------------------------------------------------
#   affiche le script avec l'editeur de texte par defaut definit dans la configuration d'Audela
#
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::editScript { } {

   set fileName [file join $::conf(eshel,tempDirectory) $::conf(eshel,scriptFileName)]
   if { [file exists $fileName] == 1 } {
      exec "$::conf(editscript)" "$fileName" &
   } else {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,editScript)" \
         -type ok -message $::caption(eshel,process,scriptNotFound) -icon error
   }
}

##------------------------------------------------------------
# Fabrique une serie avec les fichiers selectionnes pas l'utilisateur
#
# @param visuNo  numero de la visu
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::makeSeries { visuNo } {
   variable private

   #--- je recupere les index des fichiers selectionnes dans la table
   set fileIndexes [$private(fileTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileIndexes] < 1 } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" \
         -type ok -message $::caption(eshel,process,selectFiles) -icon error
      return
   }

   #--- j'affiche la fenetre de mise a jour des mots clefs
   set result [::eshel::makeseries::run $private(This) $visuNo $private(fileTable) $fileIndexes]

   if { $result == 0 } {
      #--- j'abandonne la saisie
      return
   }

   #--- j'enregistre les mots clefs modifiés
   ::eshel::processgui::copyTableToNightlog

   #--- je recupere les noms de fichiers
   set fileNames ""
   foreach fileIndex $fileIndexes  {
      lappend fileNames [$private(fileTable) cellcget $fileIndex,FILENAME -text]
   }

   #--- je constitue la serie
   set catchResult [catch {
      #--- je constitue la serie
      ::eshel::process::makeSerie $fileNames
      #--- je refraichis le contenu des tables
      copyRawToTable
      #--- j'enregistre les modifications des mots clés dans les images.
      ::eshel::process::updateFileKeywords
      #--- je supprime la roadmap (actualiser la raodmap prendrait trop de temps)
      ::eshel::process::deleteRoadmap
      ::eshel::processgui::copyRoadmapToTable
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

##------------------------------------------------------------
# modifie les mots clefs
#
# @param visuNo  numero de la visu
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::editKeyword { visuNo } {
   variable private

   #--- je recupere les index des fichiers selectionnes dans la table
   set fileIndexes [$private(fileTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileIndexes] < 1 } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" \
         -type ok -message $::caption(eshel,process,selectFiles) -icon error
      return
   }

   #--- j'affiche la fenetre de mise a jour des mots clefs
   set result [::eshel::makeseries::run $private(This) $visuNo $private(fileTable) $fileIndexes]

   if { $result == 0 } {
      #--- j'abandonne la saisie
      return
   }

   #--- j'enregistre les mots clefs modifiés
   ::eshel::processgui::copyTableToNightlog

   #--- je recupere les noms de fichiers
   set fileNames ""
   foreach fileIndex $fileIndexes  {
      lappend fileNames [$private(fileTable) cellcget $fileIndex,FILENAME -text]
   }

   #--- je constitue la serie
   set catchResult [catch {
      #--- je constitue la serie
      ::eshel::process::makeSerie $fileNames
      #--- je refraichis le contenu des tables
      copyRawToTable
      #--- je demande la confirmation de l'enregistrement des mots clefs dans les images
      ::eshel::process::updateFileKeywords
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}


##------------------------------------------------------------
# Supprime une serie
#   Le fichiers de la serie sont deplaces dans la table des
#   fichiers non identifies
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::removeSerie { } {
   variable private

   ###if { $private(modifiedTable) == 1 } {
   ###   copyTableToNightlog
   ###}

   #--- je recupere le nom de la serie
   set serieIndex [$private(serieTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { "$serieIndex" == "" } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" -type ok \
         -message $::caption(eshel,process,selectSeries) -icon error
      return
   }
   set serieId [$private(serieTable) cellcget $serieIndex,SERIESID -text]

   #--- je supprime la serie
   set catchResult [catch {
      ::eshel::process::removeSerie $serieId
      #--- je refraichis le contenu des tables des fichiers bruts
      copyRawToTable
      #--- je supprime la roadmap (actualiser la roadmap prendrait trop de temps)
      ::eshel::process::deleteRoadmap
      ::eshel::processgui::copyRoadmapToTable
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

##------------------------------------------------------------
# startScript
#   lance le traitement
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::startScript { } {
   variable private

   set catchResult [catch {
      #--- je lance le script
      ::eshel::process::startScript
   } ]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }

}

##------------------------------------------------------------
# generateAndStartStartScript
#   lance le traitement
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::generateAndStartStartScript { } {
   variable private

   #--- je lance la generation et letraitement
   ::eshel::process::startProcess
}

##------------------------------------------------------------
# stopScript
#   arrete le traitement
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshel::processgui::stopScript { } {
   variable private

   #--- j'arrete le script
   ::eshel::process::stopScript
}

##------------------------------------------------------------
# change l'etat des widgets dans les frames
# @param state etat des widgets (normal ou disabled ou stopping)
# @return  rien
# @public
#------------------------------------------------------------
proc ::eshel::processgui::setFrameState {  } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   if { $::conf(eshel,processAuto) == 1  } {
      set state "disabled"
   } else {
      switch [::eshel::process::getProcessState ] {
         "0" {
            set state "normal"
         }
         "1" {
            set state "running"
         }
         "generate" {
            set state "running"
         }
         "stopping" {
            set state "stopping"
         }
      }
   }

   switch $state {
      normal {
         $private(roadmapFrame).button.generate    configure -state normal
         $private(roadmapFrame).button.editScript  configure -state normal
         $private(roadmapFrame).button.startScript configure -state normal
         $private(rawFrame).button.makeSerie       configure -state normal
         $private(rawFrame).button.removeSerie     configure -state normal
         $private(frm).generateAndStart configure -state normal \
            -text $::caption(eshel,process,generateAndStart) \
            -command "::eshel::processgui::generateAndStartStartScript"
      }
      disabled {
         $private(roadmapFrame).button.generate    configure -state disabled
         $private(roadmapFrame).button.editScript  configure -state disabled
         $private(roadmapFrame).button.startScript configure -state disabled
         $private(rawFrame).button.makeSerie       configure -state disabled
         $private(rawFrame).button.removeSerie     configure -state disabled
         $private(frm).generateAndStart configure -state disabled
      }
      running {
         $private(roadmapFrame).button.generate    configure -state disabled
         $private(roadmapFrame).button.editScript  configure -state disabled
         $private(roadmapFrame).button.startScript configure -state disabled
         $private(rawFrame).button.makeSerie       configure -state disabled
         $private(rawFrame).button.removeSerie     configure -state disabled
         $private(frm).generateAndStart configure -state normal \
            -text $::caption(eshel,process,stopScript) \
            -command "::eshel::processgui::stopScript"
      }
      stopping {
         $private(roadmapFrame).button.generate    configure -state disabled
         $private(roadmapFrame).button.editScript  configure -state disabled
         $private(roadmapFrame).button.startScript configure -state disabled
         $private(rawFrame).button.makeSerie       configure -state disabled
         $private(rawFrame).button.removeSerie     configure -state disabled
         $private(frm).generateAndStart configure -state disabled \
            -text $::caption(eshel,process,stopping) \
            -command ""
      }
   }
   update
}

