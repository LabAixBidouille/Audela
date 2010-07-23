#
# Fichier : testaudela.tcl
# Description : outil de test automatique de audela
# Auteurs : Michel Pujol
# Mise a jour $Id: testaudela.tcl,v 1.1 2010-07-23 16:31:04 michelpujol Exp $
#

#####################
#
#  Pour ajouter un fichier de test
#  ===============================
#   => creer ajouter un fichier dans le repertoire audace(rep_plugin)/testaudela/tests
#      le nouveau fichier est détecté automatiquement
#
#  Pour ajouter un test dans un fichier de tests
#  =============================================
#  => ajouter une procedure "test" avec 5 parametres :
#       test_nom : nom du test
#       test_description : courte description du test
#       test_contraintes : contraintes arespecter pour que le test soit executé
#       test_code        : code TCL du test
#       test_resultat    : resultat attendu du test retouné par la commande "return" dans le code du test
#   => exemple :
#       test test_nom {test_description} {test_contraintes} {
#          test_code
#       } test_resultat
#
#  Pour ajouter une contrainte utilisable pour filtrer le tests
#  =============================================================
#   => ajouter la contrainte dans la variable private(constraints) et recharger
#      le namespace ::testaudela avec la commande
#       source audace/scripts/testaudela.tcl
#
#######################

namespace eval ::testaudela {
   global caption
   package provide testaudela 1.9

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   #source [ file join [file dirname [info script]] testaudela.cap ]
   set caption(testaudela,title) "Test AudeLA"
   package require audela 1.4.0
}

#------------------------------------------------------------
# ::testaudela::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::testaudela::getPluginTitle { } {
   global caption

   return "$caption(testaudela,title)"
}

#------------------------------------------------------------
# ::testaudela::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::testaudela::getPluginHelp { } {
   return "testaudela.htm"
}

#------------------------------------------------------------
# ::testaudela::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::testaudela::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::testaudela::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::testaudela::getPluginDirectory { } {
   return "testaudela"
}

#------------------------------------------------------------
# ::testaudela::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::testaudela::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::testaudela::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::testaudela::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "setup" }
      subfunction1 { return "" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::testaudela::initPlugin
#    initialise le plugin au demarrage de audace
#    eviter de charger trop de choses (penser a ceux qui n'utilisent pas spcaudace)
#------------------------------------------------------------
proc ::testaudela::initPlugin { tkbase } {
   #--- rien a faire car l'initalisation est faire par la procedure startTool
   #--- quand on lance l'outil la première fois
}

#------------------------------------------------------------
# ::testaudela::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::testaudela::createPluginInstance { { in ".audace" } { visuNo 1 } } {
   global conf
   global audace
   global caption
   variable private

   package require BWidget
   package require Tablelist
   package require tcltest 2.0

   #--- Charge le fichier caption
   #source [ file join $audace(rep_caption) testaudela.cap ]
   set caption(testaudela,title) "Test AudeLA"
   set caption(testaudela,files) "Fichiers de test"
   set caption(testaudela,directory) "Répertoire"
   set caption(testaudela,description) "Description du test"
   set caption(testaudela,refresh) "Actualiser"
   set caption(testaudela,selectAll) "Tous"
   set caption(testaudela,unselectAll) "Aucun"
   set caption(testaudela,save) "Enregistrer"
   set caption(testaudela,run) "Exécuter les tests"
   set caption(testaudela,detail) "Contenu du fichier sélectionné"
   set caption(testaudela,resultFile) "Résultat"
   set caption(testaudela,showResult) "Voir le résultat"
   set caption(testaudela,constraint) "Contraintes"
   set caption(testaudela,testCampagne) "Campagne de tests"

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists conf(testaudela,position) ] }  { set conf(testaudela,position)  "+250+75" }
   if { ! [ info exists conf(testaudela,directory) ] } { set conf(testaudela,directory) "$::audace(rep_plugin)/tool/testaudela" }
   if { ! [ info exists conf(testaudela,resultFile)]}  { set conf(testaudela,resultFile) "testresult.log" }
   if { ! [ info exists conf(testaudela,rep_images) ]}  { set conf(testaudela,rep_images)  "$::audace(rep_plugin)/tool/testaudela/images" }
   if { ! [ info exists conf(testaudela,testList) ] }   { set conf(testaudela,testList)  "audace_affichage.test" }
   if { ! [ info exists conf(testaudela,activeConstraintList) ] }   { set conf(testaudela,activeConstraintList)  "AUDACE" }
   #--- j'initialise la liste des contraintes
   set private(constraints) [list "AUDACE" "AUDINE" "APN" "ASCOM" "AUDINET" "ESHEL" "LX200" "QUICKREMOTE" "WEBCAM_RGB" "WEBCAM_NB" "CARTEDUCIELV3"]
   return ""

}

#------------------------------------------------------------
# ::testaudela::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::testaudela::deletePluginInstance { visuNo } {
   #--- Rien a faire pour l'instant
   #--- Car spcaudace ne peut pas etre supprime de la memoire
}

#------------------------------------------------------------
# ::testaudela::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::testaudela::startTool { visuNo } {
   #---  j'importe les procedures de simulation des tests  ::testaudela::simul::*
   #---  quiremplacent temporairement les procedures de ::tcltest::*
   namespace import -force ::testaudela::simul::*

   #green image
   image create photo im_test1 -data "R0lGODlhDQAQAKIAAP///+Li4rGxsX37j05YSgAAAAAAAAAAACwAAAAADQAQAAADNEi6VPCPjDmJcFDSQcLNGwd4mEYxFmCGnBCsofWypwtv8l3PdMvTuZ5PV7GhUC6AYMlsuhIAOw=="
   #grey image
   image create photo im_test0 -data "R0lGODlhDQAQAKIAAP///+Li4t/e3rGxsSAgGwAAAAAAAAAAACwAAAAADQAQAAADNEi6VPCPiDnJcFBSQcLNGwd4mEYxFmCG3BCsofWypwtv8l3PdMvTuZ5PV7GhUC7AYMlsuhIAOw=="


   #--- j'affiche la fenetre
   ::confGenerique::run $visuNo "$::audace(base).testaudela" "::testaudela" -modal 0
}

#------------------------------------------------------------
# ::testaudela::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::testaudela::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

#------------------------------------------------------------
#  ::testaudela::getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::testaudela::getLabel { } {
   global caption

   return "$caption(testaudela,title)"
}

#------------------------------------------------------------
#  ::testaudela::showHelp
#  affiche l'aide de la fenêtre de configuration
#------------------------------------------------------------
proc ::testaudela::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::testaudela::getPluginType]] \
      [::testaudela::getPluginDirectory] [::testaudela::getPluginHelp]
}

#------------------------------------------------------------
#  ::testaudela::confToWidget { }
#     copie les parametres du tableau conf() dans les variables des widgets
#------------------------------------------------------------
proc ::testaudela::confToWidget { visuNo } {
   variable private
   global conf


}

#------------------------------------------------------------
#  ::testaudela::fillConfigPage { }
#  fenetre de configuration
#
#------------------------------------------------------------
proc ::testaudela::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm
   set private(tree) $frm.files.tree
   set private(tableDescription) $frm.detail.description
   set private(constraintTable) $frm.detail.description

   #--- Je position la fenetre
   wm resizable [ winfo toplevel $private(frm) ] 1 1
   wm geometry [ winfo toplevel $private(frm) ] $::conf(testaudela,position)

   #--- J'initialise les variables des widgets
   confToWidget $visuNo

   #--- frame fichiers
   TitleFrame $frm.files -borderwidth 2 -text $caption(testaudela,files)
      #--- frame des boutons
      frame $frm.files.buttons -borderwidth 0
      Button $frm.files.buttons.refresh -text "$caption(testaudela,refresh)"  -command "::testaudela::fillTree"
      Button $frm.files.buttons.selectall -text "$caption(testaudela,selectAll)"  -command "::testaudela::selectAllFiles"
      Button $frm.files.buttons.unselectall -text "$caption(testaudela,unselectAll)"  -command "::testaudela::unselectAllFiles"
      grid $frm.files.buttons.refresh  -row 0 -column 0
      grid $frm.files.buttons.selectall -row 0 -column 1
      grid $frm.files.buttons.unselectall -row 0 -column 2

      #--- arbre des noms des fichiers
      Tree $frm.files.tree \
         -xscrollcommand "$frm.files.xsb set" -yscrollcommand "$frm.files.ysb set" \
         -selectcommand "::testaudela::showDescription"
      $frm.files.tree bindText   <Double-1>  "::testaudela::toggleTestSelection $frm.files.tree"
      $frm.files.tree bindText   <Button-3>  "::testaudela::editTestFile "
      $frm.files.tree bindImage  <Double-1>  "::testaudela::toggleTestSelection $frm.files.tree"
      scrollbar $frm.files.ysb -command "$frm.files.tree yview"
      scrollbar $frm.files.xsb -command "$frm.files.tree xview" -orient horizontal

      grid $frm.files.buttons   -in [$frm.files getframe] -row 0 -column 0 -sticky ewns
      grid $frm.files.tree      -in [$frm.files getframe] -row 1 -column 0 -sticky ewns
      grid $frm.files.ysb       -in [$frm.files getframe] -row 1 -column 1 -sticky nsew
      grid $frm.files.xsb       -in [$frm.files getframe] -row 3 -column 0 -sticky ew
      grid rowconfig [$frm.files getframe]    1 -weight 1
      grid columnconfig [$frm.files getframe] 0 -weight 1

   #--- frame description d'un test
   TitleFrame $frm.detail -borderwidth 2 -text $caption(testaudela,detail)
     tablelist::tablelist $frm.detail.description \
         -columns [ list \
            12 "Name"   left  \
            40 "Description"   left  \
            ] \
         -xscrollcommand [list $frm.detail.xsb set] -yscrollcommand [list $frm.detail.ysb set] \
         -selectmode extended \
         -activestyle none

      scrollbar $frm.detail.ysb -command "$frm.detail.description yview"
      scrollbar $frm.detail.xsb -command "$frm.detail.description xview" -orient horizontal

      grid $frm.detail.description $frm.detail.ysb -in [$frm.detail getframe] -sticky nsew
      grid $frm.detail.xsb -in [$frm.detail getframe] -sticky ew
      grid rowconfig    [$frm.detail getframe] 0 -weight 1
      grid columnconfig [$frm.detail getframe] 0 -weight 1

   #--- frame liste des contraintes
   TitleFrame $frm.constraints -borderwidth 2 -text "$caption(testaudela,constraint)"
      ScrollableFrame $frm.constraints.sf_color_invariant -width 200 -height 120 \
         -xscrollcommand "$frm.constraints.xsb set" -yscrollcommand "$frm.constraints.ysb set"

      scrollbar $frm.constraints.ysb -command "$frm.constraints.sf_color_invariant yview"
      scrollbar $frm.constraints.xsb -command "$frm.constraints.sf_color_invariant xview" -orient horizontal

      grid $frm.constraints.sf_color_invariant $frm.constraints.ysb -in [$frm.constraints getframe] -sticky nsew
      grid $frm.constraints.xsb -in [$frm.constraints getframe] -sticky ew
      grid rowconfig    [$frm.constraints getframe] 0 -weight 1
      grid columnconfig [$frm.constraints getframe] 0 -weight 1

      #--- j'ajoute les checkbox
      foreach constraintName $private(constraints)  {
         if { [lsearch $::conf(testaudela,activeConstraintList) $constraintName] != -1 } {
            set private(constraintState,$constraintName) 1
         } else {
            set private(constraintState,$constraintName) "0"
         }

         checkbutton $frm.constraints.sf_color_invariant.chk$constraintName -text "$constraintName" \
            -highlightthickness 0  -justify left \
            -variable ::testaudela::private(constraintState,$constraintName)
         pack $frm.constraints.sf_color_invariant.chk$constraintName  -in [$frm.constraints.sf_color_invariant getframe] -side top -padx 10  -fill none -expand 0 -anchor w
      }

   #--- frame parametres de la campagne de test
   TitleFrame $frm.campaign -borderwidth 2 -text "$caption(testaudela,testCampagne)"
      Entry $frm.campaign.resultFile  \
         -width 20 -justify left \
         -textvariable ::conf(testaudela,resultFile)
      Button $frm.campaign.run -text "$caption(testaudela,run)"  -command "::testaudela::onRunTests"
      Button $frm.campaign.show -text "$caption(testaudela,showResult)"  -command "::testaudela::showResult"

      grid $frm.campaign.run -in [$frm.campaign getframe] -row 0 -column 0 -sticky ew -padx 4 -pady 2
      grid $frm.campaign.show -in [$frm.campaign getframe] -row 0 -column 1 -sticky ew -padx 4 -pady 2
      grid $frm.campaign.resultFile -in [$frm.campaign getframe] -row 0 -column 2 -sticky ew -padx 4 -pady 2

   grid $frm.files        -row 0 -column 0 -rowspan 4 -sticky ewns
   grid $frm.detail       -row 0 -column 1 -rowspan 2 -sticky ewns
   grid $frm.constraints  -row 2 -column 1 -rowspan 2 -sticky ewns
   grid $frm.campaign     -row 4 -column 0 -rowspan 1 -columnspan 2 -sticky ewns

   grid rowconfig $frm 0 -weight 1
   grid columnconfig $frm 0 -weight 1
   grid columnconfig $frm 1 -weight 3

   ::testaudela::fillTree

}

#------------------------------------------------------------
#  ::testaudela::editTestFile
#
#  param : aucun
#------------------------------------------------------------
proc ::testaudela::editTestFile { fileName } {
      global audace caption conf confgene

   if { "$fileName" != ""} {
      catch {
         exec [file nativename $conf(editscript)] [file nativename "$::conf(testaudela,directory)/tests/$fileName"] &
      } msg
      if { $msg != "" } {
         console::affiche_erreur "Edit test file error: $msg\n"
      }
   }
}
#------------------------------------------------------------
#  ::testaudela::fillTree
#
#  param : aucun
#------------------------------------------------------------
proc ::testaudela::fillTree { } {
   variable private

   #--- je vide l'arbre
   $private(tree) selection clear
   $private(tree) delete [$private(tree) nodes root]

   set testFiles [lsort -dictionary [glob -nocomplain -dir "$::conf(testaudela,directory)/tests" "*.test"]]
   #--- je remplis l'arbre avec les fichiers trouves dans le repertoire
   foreach fullname $testFiles {
      set isdir [file isdir $fullname]
      set relativeName [string range $fullname [expr [string length "$::conf(testaudela,directory)/tests" ]+1] end]
      set shortname [file tail $fullname]
      if { $isdir == 1 } {
         set size ""
      } else {
         #--- je recherche l'etat du test qui avait ete sauvegarde
         if { [lsearch $::conf(testaudela,testList) $shortname ] != -1 } {
            set testState 1
         } else {
            set testState 0
         }

         $private(tree) insert end root "$relativeName" -text "$shortname"  \
             -image "im_test$testState" -data "$testState"
      }
   }
 }

#------------------------------------------------------------
#  ::testaudela::toggleTestSelection
#  bascule la selection du test
#  param :
#    w  :  nom de l'arbre appleant cette procedure (path TK)
#    node : identifiant du test dasn l'arbre (node)
#------------------------------------------------------------
proc ::testaudela::toggleTestSelection {w node} {
   set testState [$w itemcget $node -data ]

   #--- j'inver l'etat du noeud
   if { $testState == "1" } {
      set testState  "0"
   } else {
      set testState  "1"
   }

   $w itemconfigure $node -image "im_test$testState" -data "$testState"
 }

#------------------------------------------------------------
#  ::testaudela::selectAllTests
#  selectionne tous les fichiers de test
#  param :
#    aucun
#------------------------------------------------------------
proc ::testaudela::selectAllFiles {} {
   variable private
   foreach node [$private(tree) nodes root] {
      $private(tree) itemconfigure $node -image "im_test1" -data "1"
   }
}

#------------------------------------------------------------
#  ::testaudela::unselectAllFiles
#  supprime la selection de tous les fichiers de test
#  param :
#    aucun
#------------------------------------------------------------
proc ::testaudela::unselectAllFiles {} {
   variable private
   foreach node [$private(tree) nodes root] {
      $private(tree) itemconfigure $node -image "im_test0" -data "0"
   }
}


#------------------------------------------------------------
#  ::testaudela::showDescription
#  affiche la description des tests contenus dans un fichier
#  param :
#    w  :  nom de l'arbre appleant cette procedure (path TK)
#    fileName : nom du fichier (sans le repertoire)
#------------------------------------------------------------
proc ::testaudela::showDescription {w fileName} {
   variable private

   #--- je purge la description
   $private(tableDescription) delete 0 end

   set fullName "$::conf(testaudela,directory)/tests/$fileName"
   #--- je charge la description
   if { [file exists $fullName ] && [file isfile $fullName ] } {
      source "$::conf(testaudela,directory)/tests/$fileName"
   }
 }

#------------------------------------------------------------
#  ::testaudela::close
#  est appele quand on ferme la fenetre sans sauvegarder les modifications
#
#  param : aucun
#------------------------------------------------------------
proc ::testaudela::closeWindow { visuNo } {
   variable widget
   global audace
   global conf

   saveTestList
   saveConstraintList
   image delete "im_test0"
   image delete "im_test1"

}

#------------------------------------------------------------
#  ::testaudela::onRunTests
#------------------------------------------------------------
proc ::testaudela::onRunTests { } {
   variable private

   #--- je declare les procedures de ::tcltest a la place de celles de ::testaudela::simul
   namespace forget ::testaudela::simul::*

   #--- je declare les fichiers de test a utiliser
   set fileList [list ]
   foreach node1 [$private(tree) nodes root] {
      if { [$::testaudela::private(tree) itemcget $node1 -data] == 1 } {
         lappend fileList [file tail "$node1"]
      }
   }
   saveTestList
   saveConstraintList
   ::testaudela::runTests $fileList

   #--- j'affiche le resultat
   ::testaudela::showResult

   namespace import -force ::testaudela::simul::*

}

#------------------------------------------------------------
#  ::testaudela::runTests
#
#  @param fileList  liste des fichiers de test a prendre en compte
#  @param exitFlag  si "-exit"  , arrete audela et retourne le nombre de test ayant echoué
#  @return nombre de tests "failed" ou "-1" en cas d'erreur
#
#------------------------------------------------------------
proc ::testaudela::runTests { { fileList "all" }  } {
   variable private

   if { [info exists ::testaudela::private(constraints)] == 0 } {
      ::testaudela::createPluginInstance
   }
   namespace import -force ::tcltest::*
   set failed -1
   catch {
      if { $fileList == "all" } {
         set fileList "*.test"

      }
      #--- je declare la liste des fichiers de test
      ::tcltest::configure -file $fileList
      console::disp  "::tcltest::configure -file $fileList\n"
      #--- je declare les contraintes
      foreach constraintName $private(constraints) {
         if { [lsearch $::conf(testaudela,activeConstraintList) $constraintName] != -1 } {
            set constraintState 1
         } else {
            set constraintState 0
         }
         ::tcltest::testConstraint $constraintName $constraintState
      }
      #--- j'efface le fichier resultat
      ::tcltest::removeFile $::conf(testaudela,resultFile)
      #--- je configure la campagne de tests
      ::tcltest::configure -testdir "$::conf(testaudela,directory)/tests"
      ::tcltest::configure -verbose {pass error }
      ::tcltest::configure -debug 0
      ::tcltest::configure -outfile $::conf(testaudela,resultFile)
      ::tcltest::configure -singleproc 1
      ::tcltest::testConstraint interactive 1
      ::tcltest::testConstraint singleTestInterp 1

      #--- je lance les tests
      ::tcltest::runAllTests
      #--- je recupere le nombre de tests failed
      set hfile [open $::conf(testaudela,resultFile) r]
      if { $hfile != "-1" } {
         set testResult [read -nonewline $hfile ]
         #--- je decoupe le resultat en une liste de lignes
         set testResult [split $testResult "\n"]
         console::disp  "testResult=$testResult\n"
         #--- je recupere la ligne qui contient les nombres de tests
         set testResult [lsearch -inline -regexp $testResult ":\tTotal\t" ]
         console::disp  "testResult=$testResult\n"
         #--- je scanne les nombres de tests
         scan $testResult "[file tail [info script]]:\tTotal\t%d\tPassed\t%d\tSkipped\t%d\tFailed\t%d" total passed skipped failed
         console::disp  "failed=$failed\n"

      }
      ::close $hfile

   } msg
   if { $msg != "" } {
      console::disp "tcltest error: $msg\n"
   }

   #--- je ferme le fichier resultat
   ::tcltest::outputChannel stdout

   namespace forget ::tcltest::*
   #--- je retourne le nombre de test ayant echoue
   return $failed
}

#------------------------------------------------------------
#  ::testaudela::saveConstraintList
#------------------------------------------------------------
proc ::testaudela::saveConstraintList { } {
   variable private

   foreach constraintName $private(constraints)  {
      set constraintState $private(constraintState,$constraintName)
      if { $constraintState == 1 } {
         lappend ::conf(testaudela,activeConstraintList) $constraintName
      }
   }
   return
}


#------------------------------------------------------------
#  ::testaudela::saveTestList
#------------------------------------------------------------
proc ::testaudela::saveTestList { } {
   variable private

   set ::conf(testaudela,testList) ""
   foreach node1 [$private(tree) nodes root] {
      set testState [$::testaudela::private(tree) itemcget $node1 -data]
      if { $testState == 1 } {
         lappend ::conf(testaudela,testList)  $node1
      }
   }

   return
}

#------------------------------------------------------------
#  ::testaudela::showResult { }
#  affiche le fichier resulat des tests
#------------------------------------------------------------
proc ::testaudela::showResult { } {
   variable private

   set frm $private(frm)

   if {[winfo exists $frm.result ]} {
      $frm.result.sf_color_invariant.text  delete 1.0 end
      $frm.result.sf_color_invariant.text insert end [tcltest::viewFile $::conf(testaudela,resultFile)]
      update
      focus $frm.result
      return
   }

   Dialog $frm.result -modal none -parent $private(frm) \
      -title  $::conf(testaudela,resultFile) -cancel 0 -default 0

   TitleFrame $frm.result.sf_color_invariant  -borderwidth 0 -relief ridge
      scrollbar $frm.result.sf_color_invariant.ysb -command "$frm.result.sf_color_invariant.text yview"
      scrollbar $frm.result.sf_color_invariant.xsb -command "$frm.result.sf_color_invariant.text xview" -orient horizontal

      text $frm.result.sf_color_invariant.text -yscrollcommand [list $frm.result.sf_color_invariant.ysb set] \
        -xscrollcommand [list $frm.result.sf_color_invariant.xsb set] -wrap word -width 70

      grid $frm.result.sf_color_invariant.text  -in [$frm.result.sf_color_invariant getframe] -row 0 -column 0 -sticky ewns
      grid $frm.result.sf_color_invariant.ysb  -in [$frm.result.sf_color_invariant getframe] -row 0 -column 1 -sticky nsew
      grid $frm.result.sf_color_invariant.xsb  -in [$frm.result.sf_color_invariant getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.result.sf_color_invariant getframe] 0 -weight 1
      grid columnconfig [$frm.result.sf_color_invariant getframe] 0 -weight 1

      $frm.result.sf_color_invariant.text insert end [tcltest::viewFile $::conf(testaudela,resultFile)]

   pack $frm.result.sf_color_invariant -fill both -expand 1
   $private(frm).result draw
   update
   $frm.result.sf_color_invariant.text yview moveto 1.1
}

######################################################################
#  ::testaudela::simul
#     simulation du namespace ::tcltest
#     pour lire la description des tests sans les executer
########################################################################
namespace eval ::testaudela::simul {
   namespace export test
   namespace export testConstraint
}

proc ::testaudela::simul::test {name description args} {
  $::testaudela::private(tableDescription) insert end [list $name "$description"]
  ##console::disp  "test=$name description=$description \n"
  ##console::disp  "   arg0=[lindex $args 0]\n"
  ##console::disp  "   arg1=[lindex $args 1]\n"
  ##console::disp  "   arg2=[lindex $args 2]\n"
  ##console::disp  "   arg3=[lindex $args 3]\n"
}

proc ::testaudela::simul::testConstraint {name expression} {
  $::testaudela::private(tableDescription) insert end [list $name "$expression"]
  ###console::disp "Contraintes: $name\n"
}


######################################################################
#  utilitaires pour les interations avec les widgets TK
########################################################################
#----------------------------------------------------
#  ::testaudela::clicButton
#    simule un clic sur un bouton
# parametres :
#    buttonPath : chemin complet du bouton
#  exemples:
#     clicButton .audace.traiteImage.cmd.ok
#----------------------------------------------------
proc ::testaudela::clicButton { buttonPath } {
   $buttonPath invoke
}

#----------------------------------------------------
#  ::testaudela::clicCheckButton
#    simule un clic sur un checkbutton ou force le check a une valeur
# parametres :
#    buttonPath : chemin complet du bouton
#    state :  etat de la case a coche "1" , "0" , ou basculement si ce parametre est absent
#  exemples:
#    clicCheckButton  .audace.acqfc.mode.une.index.case
#           =>>> bascule le checkbutton
#    clicCheckButton  .audace.acqfc.mode.une.index.case "1"
#           =>>> coche le checkbutton
#    clicCheckButton .audace.acqfc.mode.une.index.case "0"
#           =>>> decoche le checkbutton
#----------------------------------------------------
proc ::testaudela::clicCheckButton { buttonPath { state "" } } {
   switch $state {
      "1" { $buttonPath select }
      "0" { $buttonPath deselect }
      default { $buttonPath toggle }
   }
   #--- je lance la procedure du CheckButton apres une selection
   eval [$buttonPath cget -command]

}

#----------------------------------------------------
#  ::testaudela::clicCombobox
#    simule un clic sur une combobox
# parametres :
#    comboPath : chemin complet du bouton de la combobox
#    index : index de l'item selectionne
#            Le premier item est a l'index 0
#            Valeurs prédefinies : first last next previous
# exemples :
#    clicCheckButton .audace.acqfc.mode 0
#    clicCheckButton .audace.acqfc.mode first
#    clicCheckButton .audace.acqfc.mode last
#----------------------------------------------------
proc ::testaudela::clicCombobox { comboPath index} {
   if { [string first "$index" "first last next previous" ] == -1 } {
      #--- c'est un numero, il faut ajouter le prefixe "@"
      $comboPath.but  setvalue "@$index"
   } else {
      #--- c'est une valeur predefinie
      $comboPath.but  setvalue $index
   }
   #--- je lance la procedure de la combobox apres une selection
   eval [$comboPath.but cget -modifycmd]
}

#----------------------------------------------------
#  ::testaudela::clicMenu
#    simule un clic sur un menu
#  parametres :
#    visuNo : numero de la visu
#    menuName : nom du menu principal
#    menuLabel : libelle de l'item du menu principal
#  exemple :
#    clicMenu 1 "Affichage" "palette grise"
#----------------------------------------------------
proc ::testaudela::clicMenu { visuNo menuName menuLabel } {
   if [catch {MenuGet $visuNo "$menuName"} menuPath] {
      error "$menuName not in visu$visuNo"
   }
   if [catch {$menuPath index "$menuLabel"} menuIndex] {
      error "$menuLabel not in menu $menuName"
   }
   $menuPath invoke $menuIndex
}

#----------------------------------------------------
#  ::testaudela::clicMenuButton
#    simule un clic sur un clicMenuButton
#  parametres :
#    buttonPath : chemin complet du bouton
#    value : valeur de l'item a selectionner
#  Exemple :
#    ::testaudela::clicMenuButton  .audace.acqfc.mode.une.nom.extension ".jpg"
#----------------------------------------------------
proc ::testaudela::clicMenuButton { buttonPath value} {
   if { [$buttonPath cget -textvariable]  != "" } {
      set ::[$buttonPath cget -textvariable]  $value
   } else {
      #--- je cree une exception
      error "clicMenuButton error:  textvariable not found for $buttonPath"
   }
}


#----------------------------------------------------
#  ::testaudela::clicRadioButton
#    simule un clic sur un radiobutton
#  parametres :
#    buttonPath : chemin complet du bouton
#  Exemple :
#----------------------------------------------------
proc ::testaudela::clicRadioButton { buttonPath } {
   $buttonPath select
}

#----------------------------------------------------
#  ::testaudela::mouveMouse
#    simule le deplacement du curseur de la souris
#    vers un point x,y du canvas (x,y sont en coordonnees canvas)
#  parametres :
#    visuNo : numero de la visu
#    x_canvas y_canvas : coordonnees du curseur de la souris
#  Exemple :
#    mouveMouse 1 20 20
#----------------------------------------------------
proc ::testaudela::mouveMouse { visuNo x_canvas y_canvas } {
   set canvasPath [confVisu::getCanvas $visuNo]
   event generate $canvasPath <Motion> -x $x_canvas -y $y_canvas
}

#----------------------------------------------------
#  ::testaudela::selectNoteBook
#    simule la selection d'un onglet en fontion du titre de l'onglet
#  parametres :
#   buttonPath : chemin complet du gestionnaire d'onglet
#   title : nom de l'onglet
#  Exemple :
#    ::testaudela::selectNoteBook .audace.confcat.usr.onglet "carteducielv3"
#----------------------------------------------------
proc ::testaudela::selectNoteBook { notebookPath name } {
   $notebookPath raise "$name"
}

#----------------------------------------------------
#  ::testaudela::putEntry
#    simule la saisie dans un ENTRY
#  parametres :
#    entryPath : chemin complet du widget entry
#    value : valeur saisie
#  Exemple :
#    ::testaudela::putEntry .audace.acqfc.mode.une.nom.entr "m57"
#----------------------------------------------------
proc ::testaudela::putEntry { entryPath  value } {
   $entryPath delete 0 end
   $entryPath insert 0 $value
}

