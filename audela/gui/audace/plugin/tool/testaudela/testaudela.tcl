#
# Fichier : testaudela.tcl
# Description : Outil de test automatique pour AudeLA
# Auteurs : Michel Pujol
# Mise à jour $Id: testaudela.tcl,v 1.14 2010-10-15 20:18:28 michelpujol Exp $
#

#####################
#
#  Pour ajouter un fichier de test
#  ===============================
#   => creer ajouter un fichier dans le repertoire audace(rep_plugin)/testaudela/tests
#      Le nouveau fichier est détecte automatiquement au demarrage de l'outil
#      Si l'outil TestaAudela est déjà lancé , il faut cliquer sur le bouton Actualiser
#      pour faire apparaitre le nouveau fichier de test.
#
#  Pour ajouter un test dans un fichier de tests
#  =============================================
#  => ajouter une procedure "test" avec 5 parametres :
#       test_nom         : nom du test
#       test_description : courte description du test
#       test_contraintes : contraintes a respecter pour que le test soit execute
#       test_code        : code TCL du test
#       test_resultat    : resultat attendu du test retoune par la commande "return" dans le code du test
#   => exemple :
#       test test_nom {test_description} {test_contraintes} {
#          test_code
#       } test_resultat
#
#  Pour ajouter une contrainte utilisable pour filtrer le tests
#  =============================================================
#   => ajouter la contrainte dans la variable private(constraints) et recharger
#      le namespace ::testaudela avec la commande
#      source audace/scripts/testaudela.tcl
#
#######################

namespace eval ::testaudela {
   package provide testaudela 1.11

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] testaudela.cap ]
}

#------------------------------------------------------------
# ::testaudela::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::testaudela::getPluginTitle { } {
   return $::caption(testaudela,title)
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
      subfunction1 { return "test" }
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
   variable private
   global audace conf

   package require BWidget
   package require Tablelist
   package require tcltest 2.0

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists conf(testaudela,position) ] }             { set conf(testaudela,position)             "400x400+100+50" }
   if { ! [ info exists conf(testaudela,resultFile)] }            { set conf(testaudela,resultFile)           "testresult.log" }
   if { ! [ info exists conf(testaudela,rep_images) ] }           { set conf(testaudela,rep_images)           "$::audace(rep_images)/testaudela" }
   if { ! [ info exists conf(testaudela,testList) ] }             { set conf(testaudela,testList)             "audace_affichage.test" }
   if { ! [ info exists conf(testaudela,activeConstraintList) ] } { set conf(testaudela,activeConstraintList) "AUDACE" }

   #--- nettoyage des variables conf pour les versions antérieures au 19/09/2010
   if { [string first $::audace(rep_plugin) $::conf(testaudela,rep_images) ] != -1 } {
       #--- je reinitialise le repertoire des images si l'ancien chemin pointe dans audace(rep_plugin)
       set ::conf(testaudela,rep_images) "$::audace(rep_images)/testaudela"
   }
   if { [ info exists conf(testaudela,directory) ] == 1 } {
      #--- je supprime la variable conf(testaudela,directory)  qui n'est plus utilisée
      unset conf(testaudela,directory)
   }

   #--- j'initialise la liste des contraintes
   set private(constraints) [list "AUDACE" "AUDINE" "APN" "ASCOM" "AUDINET" "ESHEL" "LX200" "QUICKREMOTE" "WEBCAM_RGB" "WEBCAM_NB" "CARTEDUCIELV3" "IMAGINGSOURCE" ]
   set private(frm) ""
   set private(interrupt) 0
   #--- je memorise le repertoire contenant les scripts de test
   set private(testScriptDirectory) [file join \
      $audace(rep_plugin) \
      [::audace::getPluginTypeDirectory [::testaudela::getPluginType]] \
      [::testaudela::getPluginDirectory] \
      "tests"
   ]

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
   #--- j'importe les procedures de simulation des tests  ::testaudela::simul::*
   #--- qui remplacent temporairement les procedures de ::tcltest::*
   namespace import -force ::testaudela::simul::*

   #green image
   image create photo im_test1 -data "R0lGODlhDQAQAKIAAP///+Li4rGxsX37j05YSgAAAAAAAAAAACwAAAAADQAQAAADNEi6VPCPjDmJcFDSQcLNGwd4mEYxFmCGnBCsofWypwtv8l3PdMvTuZ5PV7GhUC6AYMlsuhIAOw=="
   #grey image
   image create photo im_test0 -data "R0lGODlhDQAQAKIAAP///+Li4t/e3rGxsSAgGwAAAAAAAAAAACwAAAAADQAQAAADNEi6VPCPiDnJcFBSQcLNGwd4mEYxFmCG3BCsofWypwtv8l3PdMvTuZ5PV7GhUC7AYMlsuhIAOw=="

   #--- j'affiche la fenetre
   ::confGenerique::run $visuNo "$::audace(base).testaudela" "::testaudela" -modal 0

   #--- je verifie que le repertoire des images existe
   verifyImageDirectory $::conf(testaudela,rep_images)
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
   return $::caption(testaudela,title)
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
   variable widget

   #--- Je memorise la reference de la frame
   set private(frm) $frm
   set private(tableDescription) $frm.detail.description
   set private(constraintTable) $frm.detail.description

   #--- Je position la fenetre
   wm resizable [ winfo toplevel $private(frm) ] 1 1
   wm geometry [ winfo toplevel $private(frm) ] $::conf(testaudela,position)

   #--- J'initialise les variables des widgets
   confToWidget $visuNo

   #--- je cree le menu
   set private($visuNo,menu) "[winfo toplevel $private(frm)].menubar"
   set menuNo "testaudela${visuNo}"
   Menu_Setup $menuNo $private($visuNo,menu)
      #--- menu file
      Menu           $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(testaudela,imageDirectory)..." \
         "::testaudela::setImageDirectory"
      ###Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(testaudela,ImageDirectory,installTitle)..." \
      ###   "::testaudela::downloadImageFile"
      Menu_Separator $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,quitter)" \
        "::confGenerique::closeWindow $visuNo [namespace current]"
  [MenuGet $menuNo $::caption(audace,menu,file)] configure -tearoff 0

   #--- frame fichiers
   TitleFrame $frm.files -borderwidth 2 -text $::caption(testaudela,files)
      #--- frame des boutons
      frame $frm.files.buttons -borderwidth 0
      Button $frm.files.buttons.refresh -text $::caption(testaudela,refresh)  -command "::testaudela::fillTree"
      Button $frm.files.buttons.selectall -text $::caption(testaudela,selectAll)  -command "::testaudela::selectAllFiles"
      Button $frm.files.buttons.unselectall -text $::caption(testaudela,unselectAll)  -command "::testaudela::unselectAllFiles"
      grid $frm.files.buttons.refresh -row 0 -column 0
      grid $frm.files.buttons.selectall -row 0 -column 1
      grid $frm.files.buttons.unselectall -row 0 -column 2

      #--- arbre des noms des fichiers
      set private(tree) $frm.files.tree
      Tree $frm.files.tree \
         -xscrollcommand "$frm.files.xsb set" -yscrollcommand "$frm.files.ysb set" \
         -selectcommand "::testaudela::showDescription"
      $frm.files.tree bindText   <Double-1>  "::testaudela::toggleTestSelection $frm.files.tree"
      $frm.files.tree bindImage  <Double-1>  "::testaudela::toggleTestSelection $frm.files.tree"
      $frm.files.tree bindText   <Button-3>  "::testaudela::editTestFile "
      scrollbar $frm.files.ysb -command "$frm.files.tree yview"
      scrollbar $frm.files.xsb -command "$frm.files.tree xview" -orient horizontal

      grid $frm.files.buttons   -in [$frm.files getframe] -row 0 -column 0 -sticky ewns
      grid $frm.files.tree      -in [$frm.files getframe] -row 1 -column 0 -sticky ewns
      grid $frm.files.ysb       -in [$frm.files getframe] -row 1 -column 1 -sticky nsew
      grid $frm.files.xsb       -in [$frm.files getframe] -row 3 -column 0 -sticky ew
      grid rowconfig [$frm.files getframe]    1 -weight 1
      grid columnconfig [$frm.files getframe] 0 -weight 1

   #--- frame description d'un test
   TitleFrame $frm.detail -borderwidth 2 -text $::caption(testaudela,detail)
      tablelist::tablelist $frm.detail.description \
         -columns [ list \
            12 $::caption(testaudela,name)        left \
            40 $::caption(testaudela,description) left \
            ] \
         -xscrollcommand [list $frm.detail.xsb set] -yscrollcommand [list $frm.detail.ysb set] \
         -selectmode extended \
         -activestyle none

      scrollbar $frm.detail.ysb -command "$frm.detail.description yview"
      scrollbar $frm.detail.xsb -command "$frm.detail.description xview" -orient horizontal
      Button $frm.detail.edit -text $::caption(testaudela,edit)  -command { ::testaudela::editTestFile [$::testaudela::private(tree) selection get] }

      grid $frm.detail.description -in [$frm.detail getframe] -row 0 -column 0  -sticky nsew
      grid $frm.detail.ysb -in [$frm.detail getframe] -row 0 -column 1 -sticky nsew
      grid $frm.detail.xsb -in [$frm.detail getframe] -sticky ew -row 1 -column 0 -columnspan 2
      grid $frm.detail.edit -in [$frm.detail getframe] -row 2 -column 0 -columnspan 2
      grid rowconfig    [$frm.detail getframe] 0 -weight 1
      grid columnconfig [$frm.detail getframe] 0 -weight 1

   #--- frame liste des contraintes
   TitleFrame $frm.constraints -borderwidth 2 -text $::caption(testaudela,constraint)
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
   TitleFrame $frm.campaign -borderwidth 2 -text $::caption(testaudela,testCampagne)
      Button $frm.campaign.run -text $::caption(testaudela,run)  -command "::testaudela::onRunTests"
      Button $frm.campaign.show -text $::caption(testaudela,showResult)  -command "::testaudela::showResult"

      grid $frm.campaign.run -in [$frm.campaign getframe] -row 0 -column 0 -sticky ew -padx 4 -pady 2
      grid $frm.campaign.show -in [$frm.campaign getframe] -row 0 -column 1 -sticky ew -padx 4 -pady 2

   grid $frm.files        -row 1 -column 0 -rowspan 2 -sticky ewns
   grid $frm.detail       -row 1 -column 1 -sticky ewns
   grid $frm.constraints  -row 2 -column 1 -sticky ewns
   grid $frm.campaign     -row 3 -column 0 -columnspan 2 -sticky ewns

   grid rowconfig $frm 1 -weight 1
   grid rowconfig $frm 2 -weight 1
   grid columnconfig $frm 0 -weight 1
   grid columnconfig $frm 1 -weight 1

   ::testaudela::fillTree

}

#------------------------------------------------------------
#  ::testaudela::editTestFile
#
#  @param  fileName  nom du fichier de test a editer
#  @return none
#------------------------------------------------------------
proc ::testaudela::editTestFile { fileName } {
   variable private

   if { "$fileName" != ""} {
      set catchError [catch {
         exec [file nativename $::conf(editscript)] [file nativename [file join $private(testScriptDirectory) $fileName]] &
      } msg]
      if { $catchError != 0 } {
         console::affiche_erreur "Edit test file error: $msg\n"
      }
   }
}

#------------------------------------------------------------
#  ::testaudela::fillTree
#
#  @return none
#------------------------------------------------------------
proc ::testaudela::fillTree { } {
   variable private

   #--- je vide l'arbre
   $private(tree) selection clear
   $private(tree) delete [$private(tree) nodes root]

   set testFiles [lsort -dictionary [glob -nocomplain -dir $private(testScriptDirectory)  "*.test"]]
   #--- je remplis l'arbre avec les fichiers trouves dans le repertoire
   foreach fullname $testFiles {
      set isdir [file isdir $fullname]
      set relativeName [string range $fullname [expr [string length $private(testScriptDirectory) ]+1] end]
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
#  @param w   nom de l'arbre appleant cette procedure (path TK)
#  @param node  identifiant du test dasn l'arbre (node)
#------------------------------------------------------------
proc ::testaudela::toggleTestSelection { w node } {
   set testState [$w itemcget $node -data ]

   #--- j'inverse l'etat du noeud
   if { $testState == "1" } {
      set testState  "0"
   } else {
      set testState  "1"
   }

   #--- je change le nom de l'image (im_test0 grise ou im_test1 verte)
   #--- et je memmorise l'etat dans l'attribut "data du noeud
   $w itemconfigure $node -image "im_test$testState" -data "$testState"
}

#------------------------------------------------------------
#  verifyImageDirectory
#  Verifie que le repertoire des images existe et n'est pas vide
# @param imageDirectory  repertoire a veirifer
# @return 1=OK 0=erreur
#------------------------------------------------------------
proc ::testaudela::verifyImageDirectory { imageDirectory } {
   variable private
   variable widget

   if { [file exists $imageDirectory] == 0 } {
      set choix [tk_messageBox \
         -title $::caption(testaudela,imageDirectory) \
         -icon warning \
         -type yesno \
         -message "$::caption(testaudela,ImageDirectory,notFound)\n[file native $imageDirectory]\n\n$::caption(testaudela,ImageDirectory,installQuestion)" \
      ]
      if { $choix == "yes" } {
         #--- j'affiche la fenetre de telechargement des images de test
         ::testaudela::setImageDirectory
      }
      return 0
   }
   if { $imageDirectory == $::audace(rep_images) } {
      tk_messageBox \
         -title $::caption(testaudela,imageDirectory) \
         -icon warning \
         -type ok \
         -message "$::caption(testaudela,ImageDirectory,alreadyUsed)\n$imageDirectory"
      return 0
   } else {
      return 1
   }
}

#------------------------------------------------------------
#  setImageDirectory
#  Verifie que le repertoire des images existe et n'est pas vide
# @param imageDirectory  repertoire a veirifer
# @return 1=OK 0=erreur
#------------------------------------------------------------
proc ::testaudela::setImageDirectory { } {
   variable private
   variable widget

   set tkName "$private(frm).testAudelaDirectory"
   if { [ winfo exists $tkName ] } {
      focus $tkName
      return
   }

   ###toplevel $tkName
   ###wm title $tkName $::caption(testaudela,ImageDirectory,installTitle)
   ###wm resizable $tkName 1 1
   ###wm minsize $tkName 400 180
   ###
   set widget(imageDirectory)   [file native $::conf(testaudela,rep_images)]

   Dialog $tkName -modal none -parent $private(frm) \
     -title $::caption(testaudela,ImageDirectory,installTitle) -cancel 0 -default 0
   wm minsize $tkName 400 180

   TitleFrame $tkName.download -borderwidth 1 -text $::caption(testaudela,ImageDirectory,installTitle)
      #--- procedure1
      Label $tkName.download.procedure -text $::caption(testaudela,ImageDirectory,procedure1)
      pack $tkName.download.procedure -in [$tkName.download getframe] -side top -fill x -expand 0 -padx 2 -pady 2
      bind $tkName.download.procedure <Configure> [list ::testaudela::wrap %W %w]
      #--- lien hypertexte
      set url "http://www.audela.org/download/test-audela-image.zip"
      label $tkName.download.link_color_invariant -fg $::color(blue) -text $url
      pack $tkName.download.link_color_invariant -in [$tkName.download getframe] -fill x -pady 2 -side top -padx 10
      bind $tkName.download.link_color_invariant <Enter> "$tkName.download.link_color_invariant configure -cursor hand2"
      bind $tkName.download.link_color_invariant <Leave> "$tkName.download.link_color_invariant configure -cursor crosshair"
      bind $tkName.download.link_color_invariant  <ButtonPress-1> "::audace::Lance_Site_htm $url"

      #--- procedure2
      Label $tkName.download.procedure2 -text $::caption(testaudela,ImageDirectory,procedure2)
      pack $tkName.download.procedure2 -in [$tkName.download getframe] -side top -fill x -expand 0 -padx 2 -pady 2
      #--- directory
      frame $tkName.download.image -borderwidth 0
         #--- Entry pour le nom generique des images de simulation
         entry $tkName.download.image.directory -justify left -state readonly \
            -textvariable  ::testaudela::widget(imageDirectory)
         pack $tkName.download.image.directory -fill x -expand 1 -side left -padx 0 -pady 0
         #--- je cadre le nom repertoire à droite pour voir la fin
         $tkName.download.image.directory xview end
         #--- Bouton 'Parcourir'
         button $tkName.download.image.butParcourir -text "..." \
            -borderwidth 2 -command "::testaudela::selectImageDirectory $tkName.download.image.directory"
         pack $tkName.download.image.butParcourir -side left -padx 5 -pady 0
      pack $tkName.download.image -in [$tkName.download getframe] -side top -fill x -expand 0 -padx 0 -pady 0

   pack $tkName.download -anchor w -fill both -expand 0 -padx 2 -pady 2
   $tkName draw
   #--- La nouvelle fenetre est active
   focus $tkName

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $tkName
}

#------------------------------------------------------------
#  wrap
#  wrappe le texte affiche dans un widget (decoupe en plusieurs lignes )
# @param W  nom tk du widget
# @param w  largeur du widget (nombre de caracteres)
# @return none
#------------------------------------------------------------
proc ::testaudela::wrap {W w} {
   set px [$W cget -padx]

   if { [catch {$W cget -compound} side] } {
      set wl [expr {$w - (2 * $px)}]
   } else {
      switch -- $side {
         left -
         right {
            set image [$W cget -image]
            if { [string length $image] } {
              set iw [image width $image]
            } else {
              set iw 0
            }
            set wl [expr {$w - (3 * $px) - $iw}]
         }
         default {
            set wl [expr {$w - (2 * $px)}]
         }
      }
   }
   $W configure -wraplength $wl
}

#------------------------------------------------------------
#  selectImageDirectory
#  affiche la fenetre pour selectionner le repertoire des images de test
# @param tkEntry  nom tk du widget contenant le nom du repertoire
# @return none
#------------------------------------------------------------
proc ::testaudela::selectImageDirectory { tkEntry } {
   variable private
   variable widget

   #--- Ouvre la fenetre de choix des images
   set imageDirectory [ tk_chooseDirectory -title $::caption(testaudela,imageDirectory) \
      -initialdir $::conf(testaudela,rep_images) -parent [winfo toplevel $private(frm)]  ]

   if {$imageDirectory!=""} {
      if { [ verifyImageDirectory $imageDirectory] == 1 } {
         #--- j'affiche le noms du repertoire (syntaxe native de l'OS)
         set widget(imageDirectory) [file native $imageDirectory]
         #--- je cadre le nom repertoire à droite dans l'entry pour voir la fin
         $tkEntry xview end

         #--- je memorise le repertoire
         set ::conf(testaudela,rep_images) [file normalize $imageDirectory]
      }
   }
}



#------------------------------------------------------------
# selectAllTests
#  selectionne tous les fichiers de test
# @return none
#------------------------------------------------------------
proc ::testaudela::selectAllFiles { } {
   variable private

   foreach node [$private(tree) nodes root] {
      $private(tree) itemconfigure $node -image "im_test1" -data "1"
   }
}

#------------------------------------------------------------
#  unselectAllFiles
#  supprime la selection de tous les fichiers de test
# @return none
#------------------------------------------------------------
proc ::testaudela::unselectAllFiles { } {
   variable private

   foreach node [$private(tree) nodes root] {
      $private(tree) itemconfigure $node -image "im_test0" -data "0"
   }
}

#------------------------------------------------------------
#  showDescription
#  affiche la description des tests contenus dans un fichier
# @param w  nom tk de l'arbre appleant cette procedure (path TK)
# @param fileName  nom du fichier (sans le repertoire)
# @return none
#------------------------------------------------------------
proc ::testaudela::showDescription { w fileName } {
   variable private

   #--- je purge la description
   $private(tableDescription) delete 0 end

   set fullName [file join $private(testScriptDirectory) $fileName]
   #--- je charge la description
   if { [file exists $fullName ] && [file isfile $fullName ] } {
      source [file join $private(testScriptDirectory) $fileName]
   }
}

#------------------------------------------------------------
#  ::testaudela::close
#  est appele quand on ferme la fenetre sans sauvegarder les modifications
#
# @return none
#------------------------------------------------------------
proc ::testaudela::closeWindow { visuNo } {
   variable private

   saveTestList
   saveConstraintList
   image delete "im_test0"
   image delete "im_test1"

   set ::conf(testaudela,position) [winfo geometry [winfo toplevel $private(frm)]]
   #--- j'efface le resultat des tests s'il existe
   file delete -force [file join $::audace(rep_log) $::conf(testaudela,resultFile)]
   #--- je supprime le menubar et toutes ses entrees
   Menubar_Delete "testaudela${visuNo}"
   set private(frm) ""

}

#------------------------------------------------------------
#  ::testaudela::onRunTests
# lance les tests
# @return none
#------------------------------------------------------------
proc ::testaudela::onRunTests { } {
   variable private

   #--- je verifie que le repertoire des images existe
   if { [verifyImageDirectory $::conf(testaudela,rep_images)] == 0 } {
      return 0
   }

   #--- je declare les procedures de ::tcltest a la place de celles de ::testaudela::simul
   namespace forget ::testaudela::simul::*

   #--- je recupere la liste des fichiers de test a utiliser
   set fileList [list ]
   foreach node1 [$private(tree) nodes root] {
      if { [$::testaudela::private(tree) itemcget $node1 -data] == 1 } {
         lappend fileList [file tail "$node1"]
      }
   }
   #--- j'enregistre les parametres
   saveTestList
   saveConstraintList
   #--- je change le bouton "Executer en "Arreter"
   ###$private(frm).campaign.run configure -text $::caption(testaudela,stop)  -command "::testaudela::onStopTests"
   $private(frm).campaign.run configure -state disabled
   set private(interrupt) 0
   #--- je supprime le fichier de resultat precedent
   file delete -force [file join $::audace(rep_log) $::conf(testaudela,resultFile)]
   #--- j'affiche la fenetre du resultat
   ::testaudela::showResult
   #--- je lance les tests
   ::testaudela::runTests $fileList
   #--- je change le bouton "Arreter" en "Executer
   ###$private(frm).campaign.run configure -text $::caption(testaudela,run)  -command "::testaudela::onRunTests"
   $private(frm).campaign.run configure -state normal
   namespace import -force ::testaudela::simul::*
}

#------------------------------------------------------------
#  ::testaudela::onRunTests
#------------------------------------------------------------
proc ::testaudela::onStopTests { } {
   set ::testaudela::private(interrupt) 1

   update
}


#------------------------------------------------------------
#  ::testaudela::runTests
#
#  @param fileList  liste des fichiers de test a prendre en compte
#  @param exitFlag  si "-exit"  , arrete audela et retourne le nombre de test ayant echoué
#  @return nombre de tests "failed" ou "-1" en cas d'erreur
#------------------------------------------------------------
proc ::testaudela::runTests { { fileList "all" } } {
   variable private

   #--- je cree une instance si elle n'existe pas (cas d'un lancement des tests par script)
   if { [info exists ::testaudela::private(constraints)] == 0 } {
      ::testaudela::createPluginInstance
   }

   #--- j'importe les commandes de test afin de ne pas avoir a mettre le prefixe ::tcltest::
   #--- devant tous les noms de test
   namespace import -force ::tcltest::*

   set failed -1
   set private(hfile) ""
   set catchError [catch {
      if { $fileList == "all" } {
         set fileList "*.test"
      }
      #--- je declare la liste des fichiers de test
      ::tcltest::configure -file $fileList
      ###console::disp  "::tcltest::configure -file $fileList\n"
      #--- je declare les contraintes
      foreach constraintName $private(constraints) {
         if { [lsearch $::conf(testaudela,activeConstraintList) $constraintName] != -1 } {
            set constraintState 1
         } else {
            set constraintState 0
         }
         ::tcltest::testConstraint $constraintName $constraintState
      }

      #--- je configure la campagne de tests
      ::tcltest::configure -testdir $private(testScriptDirectory)
      ::tcltest::configure -verbose {pass error }
      ::tcltest::configure -debug 0
      ::tcltest::configure -singleproc 1
      ::tcltest::testConstraint interactive 1
      ::tcltest::testConstraint singleTestInterp 1
      #--- je supprime le fichier de resultat precedent
      file delete -force [file join $::audace(rep_log) $::conf(testaudela,resultFile)]
      if { $private(frm) == "" } {
         #--- s'il n'y a pas de fenetre ouverte, je declare le fichier de trace directement dans tcltest
         ::tcltest::configure -outfile [file join $::audace(rep_log) $::conf(testaudela,resultFile)]
         set private(hfile) ""
      } else {
         #--- s'il y a une fenetre ouverte, je redirige les traces dans la fenetre et mon fichier de trace
         ::testaudela::redefinePuts
         set private(hfile) [open [file join $::audace(rep_log) $::conf(testaudela,resultFile)] w]
      }

      #--- je lance les tests
      ::tcltest::runAllTests

      if { $private(hfile) != "" } {
         close $private(hfile)
         set private(hfile) ""
      }
      #--- je recupere le nombre de tests failed
      set hfile [open [file join $::audace(rep_log) $::conf(testaudela,resultFile)] r]
      if { $hfile != "-1" } {
         set testResult [read -nonewline $hfile ]
         close $hfile
         #--- je decoupe le resultat en une liste de lignes
         set testResult [split $testResult "\n"]
         #--- je recupere la ligne qui contient les nombres de tests
         set testResult [lsearch -inline -regexp $testResult ":\tTotal\t" ]
         #--- je scanne les nombres de tests
         scan $testResult "[file tail [info script]]:\tTotal\t%d\tPassed\t%d\tSkipped\t%d\tFailed\t%d" total passed skipped failed
      }
   }]
   if { $catchError != 0 } {
      console::affiche_erreur "tcltest error: $::errorInfo\n"
   }

   if { $private(frm) == "" } {
      #--- je ferme le fichier resultat
      ::tcltest::outputChannel stdout
   } else {
      #--- je restore la commande puts originale
      ::testaudela::restorePuts
      #--- je ferme le fichier resultat
      if { $private(hfile) != "" } {
         close $private(hfile)
         set private(hfile) ""
      }
      #--- je mets la fenetre du resultat au premier plan
      #--- la commande est executee en differe avec after car sinon la visu principale
      #--- peut reapparaitre au premier plan si le dernier test ne se termine pas par
      #--- une commande update.
      after idle "focus $private(frm)"

   }

   #--- je restaure mes procedures de simulation
   namespace forget ::tcltest::*
   #--- j'affiche un message dans la console
   console::disp  "Testaudela result failed=$failed\n"
   #--- je retourne le nombre de test ayant echoue
   return $failed
}

proc ::testaudela::redefinePuts { } {
    if { [llength [info command ::tcl::puts]]==0 } {
       rename ::puts ::tcl::puts
       rename ::testaudela::putsCommand ::puts
    }
 }

proc ::testaudela::restorePuts { } {
   if { [llength [info command ::tcl::puts]]==1 } {
      rename ::puts ::testaudela::putsCommand
      rename ::tcl::puts ::puts
   }
}

proc ::testaudela::putsCommand { args } {
   variable private

   eval ::tcl::puts $args
   if {[lindex $args 0]=="-nonewline"} {
      set newline ""
      set args [lrange $args 1 end]
   } else {
      set newline "\n"
   }
   if {[llength $args]==1} {
      set args [list stdout [join $args]]
   }
   foreach {channel data} $args {
      if {$channel=="stdout" || $channel=="stderr"} {
         if { $::testaudela::private(hfile) != "" } {
           ::tcl::puts -nonewline $::testaudela::private(hfile) $data$newline
         }
         #--- j'affiche les données dans le fentre du resultat
         $::testaudela::private(frm).result.text insert end $data$newline
         #--- je decale la fenetre pour voir les donnes
         $::testaudela::private(frm).result.text see end
      }
   }
   if { $::testaudela::private(interrupt) == 1 } {
      set message "user interrupt !"
      $::testaudela::private(frm).result.text insert end "$message\n"
      error $message
      ::tcltest::configure -skip *.test
   }

}

#------------------------------------------------------------
#  ::testaudela::saveConstraintList
#------------------------------------------------------------
proc ::testaudela::saveConstraintList { } {
   variable private

   set ::conf(testaudela,activeConstraintList) ""
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
#  affiche la fenetre de resultat des tests
#  Si la fenetre du resultat est deja affiche, le resultat est raffraichi a partir
#  du fichier de resulat
#------------------------------------------------------------
proc ::testaudela::showResult { } {
   variable private

   set frm $private(frm)

   if {[winfo exists $frm.result ] } {
      focus $frm.result
      #--- j'efface le contenu du widget
      $frm.result.text   delete 1.0 end
   } else {
      #--- je cree la fenetre de resultat
      Dialog $frm.result -modal none -parent $private(frm) \
         -title $::caption(testaudela,result) -cancel 0 -default 0
      scrollbar $frm.result.ysb -command "$frm.result.text yview"
      scrollbar $frm.result.xsb -command "$frm.result.text xview" -orient horizontal
      text $frm.result.text -yscrollcommand [list $frm.result.ysb set] \
        -xscrollcommand [list $frm.result.xsb set] -wrap word -width 70

      grid $frm.result.text -in [$frm.result getframe] -row 0 -column 0 -sticky ewns
      grid $frm.result.ysb  -in [$frm.result getframe] -row 0 -column 1 -sticky nsew
      grid $frm.result.xsb  -in [$frm.result getframe] -row 1 -column 0 -sticky ew
      grid rowconfig     [$frm.result getframe] 0 -weight 1
      grid columnconfig  [$frm.result getframe] 0 -weight 1

      ::confColor::applyColor $frm.result
      #--- j'affiche la boite de dialogue
      $private(frm).result draw
      update
   }

   #--- j'affiche le resultat des tests si le fichier existe
   #--- sinon le widget reste vide
   if {[file exists [file join $::audace(rep_log) $::conf(testaudela,resultFile)] ]} {
      #--- je recupere le resultat des tests
      set hfile [open [file join $::audace(rep_log) $::conf(testaudela,resultFile)] r]
      if { $hfile != "-1" } {
         set testResult [read -nonewline $hfile ]
         close $hfile
         #--- je copie le resulat dans le widget
         $frm.result.text  insert end $testResult
         update
      }
   }

   #--- je place le curseur sur le permier caracterer de la dernière ligne
   $frm.result.text yview moveto 1.1

}

##------------------------------------------------------------
# updateResult
#   lit et traite le message envoye par le PC Sophie.
#   Les messages sont :
#   - si RAZ_STAT  alors appelle resetStatistics
#   - si STAT_ON  alors appelle startStatistics
#   - si STAT_OFF  alors appelle stopStatistics
#   - si GET_STAT  alors appelle getStatistics et retourne les valeurs alphaMean alphaRms deltaMean deltaRms
#  @param channel  identifiant du channel de la socket
#------------------------------------------------------------
proc ::testaudela::updateResult { channel } {
   variable private

      set data ""
      ###gets $channel data
      if { $data != "" }  {
         ##$private(frm).result.text insert end $data
         ##console::disp "data=$data\n"
      }

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

proc ::testaudela::simul::test { name description args } {
   $::testaudela::private(tableDescription) insert end [list $name "$description"]
   ###console::disp  "test=$name description=$description \n"
   ###console::disp  "   arg0=[lindex $args 0]\n"
   ###console::disp  "   arg1=[lindex $args 1]\n"
   ###console::disp  "   arg2=[lindex $args 2]\n"
   ###console::disp  "   arg3=[lindex $args 3]\n"
}

proc ::testaudela::simul::testConstraint { name expression } {
   $::testaudela::private(tableDescription) insert end [list $name "$expression"]
   ###console::disp "$::caption(testaudela,constraint) : $name\n"
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
      $comboPath  setvalue "@$index"
   } else {
      #--- c'est une valeur predefinie
      $comboPath  setvalue $index
   }
   #--- je lance la procedure de la combobox apres une selection
   eval [$comboPath cget -modifycmd]
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
   $menuPath invoke$menuIndex
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

