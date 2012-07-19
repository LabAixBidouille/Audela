#
# Fichier : horizon.tcl
# Description : fabrication de la ligne d'horizon
# Auteur : Michel Pujol
# Mise à jour $Id: horizon.tcl,v 1.7 2010-06-25 16:49:39 robertdelmas Exp $
#

namespace eval ::horizon {

}

#------------------------------------------------------------
# fillConfigPage { }
#  fenetre de horizon
#------------------------------------------------------------
proc ::horizon::run { visuNo {tkbase ""} } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(horizon,position) ] }            { set ::conf(horizon,position)            "450x200+250+75" }
   if { ! [ info exists ::conf(horizon,currentHorizon) ] }      { set ::conf(horizon,currentHorizon)      "default" }

   if { ! [ info exists ::conf(horizon,default,name) ] }        { set ::conf(horizon,default,name)        "default" }
   if { ! [ info exists ::conf(horizon,default,type) ] }        { set ::conf(horizon,default,type)        "ALTAZ" }
   if { ! [ info exists ::conf(horizon,default,coordinates) ] } { set ::conf(horizon,default,coordinates) {{0 0}} }

   set coordinates ""
   lappend coordinates [list  90 [mc_angle2deg 23h00] [mc_angle2deg 13h00]]
   lappend coordinates [list  80 [mc_angle2deg 21h45] [mc_angle2deg 12h50]]
   lappend coordinates [list  70 [mc_angle2deg 20h45] [mc_angle2deg 12h00]]
   lappend coordinates [list  60 [mc_angle2deg 20h00] [mc_angle2deg 11h30]]
   lappend coordinates [list  50 [mc_angle2deg 19h30] [mc_angle2deg 10h30]]
   lappend coordinates [list  40 [mc_angle2deg 18h30] [mc_angle2deg  9h00]]
   lappend coordinates [list  30 [mc_angle2deg 18h00] [mc_angle2deg  7h50]]
   lappend coordinates [list  20 [mc_angle2deg 19h00] [mc_angle2deg  7h00]]
   lappend coordinates [list  10 [mc_angle2deg 19h20] [mc_angle2deg  6h30]]
   lappend coordinates [list   0 [mc_angle2deg 20h00] [mc_angle2deg  6h00]]
   lappend coordinates [list -10 [mc_angle2deg 20h20] [mc_angle2deg  5h00]]
   lappend coordinates [list -20 [mc_angle2deg 21h00] [mc_angle2deg  3h30]]
   lappend coordinates [list -30 [mc_angle2deg 22h00] [mc_angle2deg  3h10]]
   lappend coordinates [list -40 [mc_angle2deg 23h00] [mc_angle2deg  2h30]]

   if { ! [ info exists ::conf(horizon,OHP_T193,name) ] }        { set ::conf(horizon,OHP_T193,name)        "OHP T193" }
   if { ! [ info exists ::conf(horizon,OHP_T193,type) ] }        { set ::conf(horizon,OHP_T193,type)        "HADEC" }
   if { ! [ info exists ::conf(horizon,OHP_T193,coordinates) ] } { set ::conf(horizon,OHP_T193,coordinates) $coordinates }

   set private($visuNo,this)   ".audace.horizon_$visuNo"

   if { [winfo exists $private($visuNo,this) ] == 0 } {
      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private($visuNo,this) [namespace current] -modal 0 \
         -geometry $::conf(horizon,position) \
         -resizable 1
   } else {
      focus $private($visuNo,this)
   }
}

#------------------------------------------------------------
# getLabel
#  retourne le nom de la fenetre de horizon
#------------------------------------------------------------
proc ::horizon::getLabel { } {
   global caption

   return $::caption(modpoi2,horizon,title)
}

#------------------------------------------------------------
# showHelp
#  affiche l'aide de la fenêtre de horizon
#------------------------------------------------------------
proc ::horizon::showHelp { } {
   variable private

   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::horizon::getPluginType ] ] \
      [ ::horizon::getPluginDirectory ] [ ::horizon::getPluginHelp ]
}

#------------------------------------------------------------
# closeWindow
#  recupere la position de l'outil apres appui sur Fermer
#------------------------------------------------------------
proc ::horizon::closeWindow { visuNo } {
   variable private

   #--- je sauve la taille et la position de la fenetre
   set ::conf(horizon,position) [winfo geometry [winfo toplevel $private($visuNo,frm) ]]

}

#------------------------------------------------------------
# fillConfigPage { }
#  fenetre de horizon
#------------------------------------------------------------
proc ::horizon::fillConfigPage { frm visuNo } {
   variable private

   #--- Je memorise la reference de la frame
   set private($visuNo,frm)      $frm

   #--- Frame select config
   TitleFrame $frm.config -borderwidth 2 -relief ridge -text $::caption(modpoi2,horizon,selectHorizon)
      #--- Liste des horizons
      set horizonList [::horizon::getHorizonList]

      #--- Bouton create new horizon
      Button $frm.config.create -text $::caption(modpoi2,horizon,createHorizon) -command "::horizon::createHorizon $visuNo"
      pack $frm.config.create -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- j'affiche la liste des horizons
      ComboBox $frm.config.combo \
         -width 20 -height [ llength $horizonList ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -modifycmd "::horizon::onSelectHorizon $visuNo" \
         -values $horizonList
      pack $frm.config.combo -in [$frm.config getframe] -side left -fill none -padx 2
      if { [info exists ::conf(horizon,$::conf(horizon,currentHorizon),name)] != 0 } {
         set index [lsearch $horizonList $::conf(horizon,$::conf(horizon,currentHorizon),name)]
         if { $index == -1 } {
            #--- je selectionne la premiere horizon , si celle de la derniere utilisee n'existe plus
            set index 0
         }
      } else {
         #--- je selectionne la premiere horizon , si celle de la derniere utilisee n'existe plus
         set index 0
      }

      #--- je selectionne la horizon dans la combobox
      $frm.config.combo setvalue "@$index"

      #--- Bouton copy horizon
      Button $frm.config.copy -text $::caption(modpoi2,horizon,copyHorizon) -command "::horizon::copyHorizon $visuNo"
      pack $frm.config.copy -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton delete horizon
      Button $frm.config.delete -text $::caption(modpoi2,horizon,deleteHorizon) -command "::horizon::deleteHorizon $visuNo"
      pack $frm.config.delete -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton import horizon
      Button $frm.config.import -text $::caption(modpoi2,horizon,importHorizon) -command "::horizon::importHorizon $visuNo" -state disabled
      pack $frm.config.import -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton export horizon
      Button $frm.config.export -text $::caption(modpoi2,horizon,exportHorizon) -command "::horizon::exportHorizon $visuNo" -state disabled
      pack $frm.config.export -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

   pack $frm.config -side top -fill x -expand 0

   frame $frm.type -borderwidth 2 -relief ridge
      label $frm.type.label -text $::caption(modpoi2,horizon,type)
      pack $frm.type.label -side left -fill none -expand 0 -padx 2
      entry $frm.type.value -textvariable ::horizon::private(type) -state readonly
      pack $frm.type.value -side left -fill none -expand 0 -padx 2
   pack $frm.type -side top -fill x -expand 0

   ###set private($visuNo,coordTable) $frm.coord.table
   set private($visuNo,coordText) $frm.coord.text

   TitleFrame $frm.coord  -borderwidth 2 -relief ridge -text $::caption(modpoi2,horizon,coordinate)
      scrollbar $frm.coord.ysb -command "$private($visuNo,coordText) yview"
      scrollbar $frm.coord.xsb -command "$private($visuNo,coordText) xview" -orient horizontal

      text $frm.coord.text -yscrollcommand [list $frm.coord.ysb set] \
        -xscrollcommand [list $frm.coord.xsb set] -wrap word -width 50

      ####--- Table des reference
      ###::tablelist::tablelist $private($visuNo,coordTable) \
      ###   -columns [list \
      ###       0 $::caption(modpoi2,horizon,azimut) left \
      ###       0 $::caption(modpoi2,horizon,elevation) left] \
      ###   -xscrollcommand [list $frm.coord.xsb set] \
      ###   -yscrollcommand [list $frm.coord.ysb set] \
      ###   -exportselection 0 \
      ###   -activestyle none
      ###
      ####--- je donne un nom a chaque colonne
      ####--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      ####--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      ###$private($visuNo,coordTable) columnconfigure 0 -name state -editable yes -editwindow entry
      ###$private($visuNo,coordTable) columnconfigure 1 -name name -stretchable 1 -sortmode dictionary

      grid $frm.coord.text  -in [$frm.coord getframe] -row 0 -column 0 -sticky ewns
      grid $frm.coord.ysb  -in [$frm.coord getframe] -row 0 -column 1 -sticky nsew
      grid $frm.coord.xsb  -in [$frm.coord getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.coord getframe] 0 -weight 1
      grid columnconfig [$frm.coord getframe] 0 -weight 1

   pack $frm.coord -side top -fill both -expand 1

   #--- j'affiche les paramametres d'horizon courant
   onSelectHorizon $visuNo
}

#----------------------------------------------------------------------------
# apply
#    met à jour les variables et les widgets quand on applique les modifications d'une configuration
#----------------------------------------------------------------------------
proc ::horizon::apply { visuNo } {
   variable private
   variable widget

   set private(closeWindow) 1

   set horizonId $::conf(horizon,currentHorizon)

   #--- je recupere la liste des raies de reference
   set a [$private($visuNo,coordText) get 1.0 {end -1ch}]
   set b [split $a "\n"]
   set coordinates [list ]
   foreach line [split [$private($visuNo,coordText) get 1.0 {end -1ch}] "\n"] {
      if { $line == "" } {
         continue
      }
      if { [ llength $line ] != 2 && $private(type) == "ALTAZ"
        || [ llength $line ] != 3 && $private(type) == "HADEC"  } {
         continue
      }
      lappend coordinates $line
   }

   set ::conf(horizon,$horizonId,name)   $private(name)
   set ::conf(horizon,$horizonId,type)   $private(type)
   set ::conf(horizon,$horizonId,coordinates)   $coordinates

  ::horizon::displayHorizon $visuNo
}

proc ::horizon::onSelectHorizon { visuNo } {
   variable private
   set tkCombo $private($visuNo,frm).config.combo

   #--- je recupere l'identifiant de l'horizon correspondant la ligne selectionne dans la combobox
   set horizonId [getHorizonIdentifiant [$tkCombo get]]
   set ::conf(horizon,currentHorizon) $horizonId

   set private(name)         $::conf(horizon,$horizonId,name)
   set private(type)         $::conf(horizon,$horizonId,type)
   set private(coordinates)  $::conf(horizon,$horizonId,coordinates)

   $private($visuNo,coordText) delete 1.0 end
   if { $private(type)  == "ALTAZ" } {
     #--- j'affiche les coordonnées
     ###$private($visuNo,coordTable) delete 0 end

     foreach altaz $private(coordinates) {

        ###$private($visuNo,coordTable) insert end $altaz
        $private($visuNo,coordText) insert end "$altaz\n"
     }
   } else {
      ###$private($visuNo,coordTable) delete 0 end
      foreach coord $private(coordinates) {
         ###$private($visuNo,coordTable) insert end $coord
         $private($visuNo,coordText) insert end "$coord\n"
      }
   }

}

##------------------------------------------------------------
# Retourne la liste des horizons
#
# Exemple : { defaut {T60 Pic du Midi } {Saint Veran } }
# Remarque : cette procedure complete les proprietes de chaque configuration
#
# @return liste de configuration
# @public
#------------------------------------------------------------
proc ::horizon::getHorizonList { } {
   #--- Liste des configurations
   set horizonList [list]
   foreach configPath [array names ::conf horizon,*,name] {
      set horizonId [lindex [split $configPath "," ] 1]
      lappend horizonList $::conf(horizon,$horizonId,name)
   }
   #--- je trie par ordre alphabetique (l'option -dictionary est equivalente a nocase)
   return [lsort -dictionary $horizonList ]
}

proc ::horizon::createHorizon { visuNo } {
   variable private

   set parent [winfo toplevel $private($visuNo,frm)]
   set result [::horizon::nameDialog::run $parent $visuNo $::caption(modpoi2,horizon,createHorizon)]
   if { $result == 0 } {
      #--- j'abandonne la creation
      return
   }

   set horizonName $::horizon::nameDialog::private(name)

   #--- je verifie que le nom n'est pas vide
   if { $horizonName== "" } {
      tk_messageBox -message $::caption(modpoi2,horizon,errorEmptyName) -icon error -title $::caption(modpoi2,horizon,title)
      return
   }

   #--- je fabrique l'identifiant a partie du nom en replacant les caracteres interdits pas un "_"
   set horizonId [getHorizonIdentifiant $horizonName]

   #--- je verifie que cet horizon n'existe pas deja
   if { [info exists ::conf(horizon,$horizonId,name)] == 1 } {
      tk_messageBox -message $::caption(modpoi2,horizon,errorExistingName) -icon error -title $::caption(modpoi2,horizon,title)
     return
   }

   #--- j'initialise les parametres de l'horizon avec ceux de la horizon par defaut
   set ::conf(horizon,$horizonId,name) $horizonName
   set ::conf(horizon,$horizonId,type) "ALTAZ"
   set ::conf(horizon,$horizonId,coordinates) ""

   #--- j'ajoute la nouvelle config dans la combo
   set tkCombo $::horizon::private($visuNo,frm).config.combo
   set horizonList [$tkCombo cget -values]
   lappend horizonList $horizonName
   set horizonList [lsort $horizonList]
   $tkCombo configure -values $horizonList -height [ llength $horizonList ]

   #--- je selectionne la nouvelle liste dans la combo
   set index [lsearch $horizonList $horizonName]
   $tkCombo setvalue "@$index"
   #--- j'affiche les valeurs dans les widgets
   onSelectHorizon $visuNo
}

proc ::horizon::copyHorizon { visuNo } {

}

proc ::horizon::deleteHorizon { visuNo } {
   variable private

   #--- je recupere le nom de la configuration courante
   set horizonId $::conf(horizon,currentHorizon)

   #--- je verifie que ce n'est pas la configuration par defaut
   if { $horizonId == "default" } {
      #--- j'abandonne la suppression s'il s'agit de la configuration par defaut
      tk_messageBox -message $::caption(modpoi2,horizon,errorDefaultName) \
         -icon error -title $::caption(modpoi2,horizon,title)
      return
   }

   #--- je demande la confirmation de la suppression
   set result [tk_messageBox -message "$::caption(modpoi2,horizon,confirmDeleteConfig): $::conf(horizon,$horizonId,name)" \
       -type okcancel -icon question -title $::caption(modpoi2,horizon,title)]

   if { $result == "ok" } {
      #--- je supprime le nom de la configuration dans la combo
      set tkCombo $::horizon::private($visuNo,frm).config.combo
      set configList [$tkCombo cget -values]
      set index [lsearch $configList $::conf(horizon,$horizonId,name)]
      set configList [lreplace $configList $index $index]
      $tkCombo configure -values $configList -height [ llength $configList ]

      #--- je supprime les parametres de la configuration
      array unset ::conf horizon,$horizonId,*

      #--- je selectionne l'item suivant a la place de celui qui vient d'etre supprime
      if { $index == [llength $configList] } {
         #--- je decrement l'index si l'element supprim� etait le dernier de la liste
         incr index -1
      }
      $tkCombo setvalue "@$index"
      ::horizon::onSelectConfig $visuNo

   }
}

proc ::horizon::importHorizon { visuNo } {

}
proc ::horizon::exportHorizon { visuNo } {

}

proc ::horizon::displayHorizon { visuNo } {
   variable private

   set horizonId $::conf(horizon,currentHorizon)
   set type $::conf(horizon,$horizonId,type)
   set coordinates $::conf(horizon,$horizonId,coordinates)
   set horizons [mc_horizon $::conf(posobs,observateur,gps) $type $coordinates]

   #--- Visualise la carte des points d'amer
   ###set figureNo [expr $visuNo + 10]
   set figureNo [::plotxy::figure $visuNo]
   ::plotxy::clf $figureNo

   #--- visualisation de l'horizon
   set x [lindex $horizons 0]
   set y [lindex $horizons 1]
   ::plotxy::plot $x $y r
   ::plotxy::title  "$::caption(modpoi2,horizon,title)"
   ::plotxy::xlabel "$::caption(modpoi2,azimutDeg)"
   ::plotxy::ylabel "$::caption(modpoi2,elevationDeg)"
   ::plotxy::position {20 20 800 400}
   ::plotxy::hold on

   $::plotxy(fig$figureNo,parent).xy axis configure x -stepsize 30
   $::plotxy(fig$figureNo,parent).xy grid configure -hide no -dashes { 2 2 }
}

#------------------------------------------------------------
# getHorizonIdentifiant
#   retourne l'identifiant de l'horizon  en fonction de son nom
# Parameters
#   name : nom de la horizon
# Return :
#   identifiant de la horizon
#------------------------------------------------------------
proc ::horizon::getHorizonIdentifiant { name } {
   variable private

   #--- je fabrique l'identifiant a partie du nom en replacant les caracteres interdits pas un "_"
   set horizonId ""
   for { set i 0 } { $i < [string length $name] } { incr i } {
      set c [string index $name $i]
      if { [string is wordchar $c ] == 0 } {
         #--- je remplace le caractere par underscore, si le caractere n'est pas une lettre , un chiffre ou underscore
         set c "_"
      }
      append horizonId $c
   }
   return $horizonId
}

#------------------------------------------------------------
# getHorizon
#
# retourne l'horizon par defaut
#
# @param coordonnées GPS de l'observatoire
# @return liste de 5 elements :
#   horizon 0
#   horizon 1
#   horizon 2
#   horizon 3
#   horizon 4
#------------------------------------------------------------
proc ::horizon::getHorizon { home } {
   variable private

   set horizonId $::conf(horizon,currentHorizon)
   set type $::conf(horizon,$horizonId,type)
   set coordinates $::conf(horizon,$horizonId,coordinates)
   set horizons [mc_horizon $home $type $coordinates]
   return $horizons
}

#------------------------------------------------------------
# getHorizonName
#
# retourne le nom de l'horizon pas defaut
#
# @return nom de l'horizon
#------------------------------------------------------------
proc ::horizon::getHorizonName { } {
   variable private
   set horizonId $::conf(horizon,currentHorizon)
   return $::conf(horizon,$horizonId,name)
}

################################################################################

namespace eval ::horizon::nameDialog {
   variable private

}

#------------------------------------------------------------
# run
#    affiche la fenetre du traitement
# return
#   1 si la saisie est validee
#   0 si la saisie est abandonne
#------------------------------------------------------------
proc ::horizon::nameDialog::run { tkbase visuNo title } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(horizon,instrumentConfigPosition) ] } { set ::conf(horizon,instrumentConfigPosition)     "200x140+100+15" }
   set private($visuNo,This) "$tkbase.getname"
   set private(title) $title
   set private(type)  "ALTAZ"

   #--- j'affiche la fenetre modale et j'attend que l'utilisateur la referme
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::horizon::nameDialog" \
      -modal 1 -geometry $::conf(horizon,instrumentConfigPosition) -resizable 1 ]

   #--- je retourne 1 si l'utilisateur a valide la saisie, ou 0 si l'utilisateur a abandonne la saisie
   return $result
}

#------------------------------------------------------------
# ::horizon::nameDialog::getLabel
#   retourne le titre de la fenetre
#------------------------------------------------------------
proc ::horizon::nameDialog::getLabel { } {
   variable private

   return "$::caption(modpoi2,horizon,title) - $private(title)"
}

#------------------------------------------------------------
# config::apply
#   enregistre la valeur des widgets
#------------------------------------------------------------
proc ::horizon::nameDialog::apply { visuNo } {
   variable private
   #--- rien a enregistrer
   #--- cette fonction existe pour faire apparaitre le bouton "OK"
}

#------------------------------------------------------------
# config::closeWindow
#   ferme la fenetre
#------------------------------------------------------------
proc ::horizon::nameDialog::closeWindow { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(horizon,instrumentConfigPosition) [ wm geometry $private($visuNo,This) ]
}

#------------------------------------------------------------
# config::fillConfigPage
#   cree les widgets de la fenetre
#
#   return rien
#------------------------------------------------------------
proc ::horizon::nameDialog::fillConfigPage { frm visuNo } {
   variable private

   set private(name)  ""

   #---Widget de saisie du nom de l'horizon.
   #--- le parametre -validatecommand renvoi vers une procedure qui controle le contenu du widget
   #---  afin d'ignorer les caracteres interdits
   LabelEntry $frm.name  -label $private(title)\
      -labeljustify left -width 5 -justify left -editable true \
      -textvariable ::horizon::nameDialog::private(name) \
      -validate all -validatecommand { ::horizon::nameDialog::validateConfigName %W %V %P %s }
   pack $frm.name  -side left -fill x -expand 1 -padx 2

   radiobutton $frm.altaz -highlightthickness 0 -padx 0 -pady 0 -state normal \
      -text $::caption(modpoi2,horizon,ALTAZ) \
      -value "ALTAZ" \
      -variable ::horizon::nameDialog::private(type)

   radiobutton $frm.hadec -highlightthickness 0 -padx 0 -pady 0 -state normal \
      -text $::caption(modpoi2,horizon,HADEC) \
      -value "HADEC" \
      -variable ::horizon::nameDialog::private(type)

}

#------------------------------------------------------------
# validateConfigName
#
#   verifie les caracteres saisis en temps reel d'un widget
#   et restaure le contenu precedent si un caractere interdit vient d'etre saisi
#   caracteres autorises : lettres, chiffres , underscore
#   return
#    1 : control OK
#    0 : contrl failed
#------------------------------------------------------------
proc ::horizon::nameDialog::validateConfigName {  win event X oldX  } {
   variable private

   switch $event {
      key {
         if { [string is print $X ] == 0 && $X != " " } {
            set X oldX
            bell
            return 0
         } else {
            return 1
         }
      }
      default {
          return 1
      }
   }
}
