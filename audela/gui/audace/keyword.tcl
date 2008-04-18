#
# Fichier : keyword.tcl
# Description : Procedures autour de l'en-tete FITS
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: keyword.tcl,v 1.1 2008-04-18 21:47:07 robertdelmas Exp $
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
   global audace caption color conf

   #--- Initialisation
   set base [ ::confVisu::getBase $visuNo ]
   if { ! [ info exists conf(geometry_header_$visuNo) ] } { set conf(geometry_header_$visuNo) "632x303+3+75" }
   #---
   set private(geometry_header_$visuNo) $conf(geometry_header_$visuNo)
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
      Scrolled_Text $base.header.slb -width 150 -font $audace(font,en_tete_1) -height 20
      pack $base.header.slb -fill y -expand true
      #--- Je declare le rafraichissement automatique des mots-cles si on charge une image
      ::confVisu::addFileNameListener $visuNo "::keyword::header $visuNo"
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $base.header <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base.header
   } else {
      $base.header.slb.list delete 1.0 end
   }
   #---
   wm title $base.header "$caption(audace,header_title) (visu$visuNo) - [::confVisu::getFileName $visuNo]"
   #---
   if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
      $base.header.slb.list tag configure keyw -foreground $color(blue)   -font $audace(font,en_tete_2)
      $base.header.slb.list tag configure egal -foreground $color(black)  -font $audace(font,en_tete_2)
      $base.header.slb.list tag configure valu -foreground $color(red)    -font $audace(font,en_tete_2)
      $base.header.slb.list tag configure comm -foreground $color(green1) -font $audace(font,en_tete_2)
      $base.header.slb.list tag configure unit -foreground $color(orange) -font $audace(font,en_tete_2)
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
      $base.header.slb.list insert end "$caption(audace,header_noimage)"
   }
   update
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
   global conf

   #---
   set private(geometry_header_$visuNo) [ wm geometry [ ::confVisu::getBase $visuNo ].header ]
   #---
   set conf(geometry_header_$visuNo) $private(geometry_header_$visuNo)
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
   if { ! [ info exists ::conf(keyword,geometry) ] } { set ::conf(keyword,geometry) "650x240+350+15" }

   #--- Initialisation de variables
   set private(instrument)        ""
   set private(diametre)          ""
   set private(focale_resultante) ""
   set private(cell_dim_x)        ""
   set private(cell_dim_y)        ""
   set private(temperature_ccd)   ""
   set private(equipement)        ""
   set private(objet)             ""
   set private(ra)                ""
   set private(dec)               ""
   set private(equinoxe)          ""
   set private(radecsys)          ""
   set private(typeImage)         ""
   set private(name_software)     "$::audela(name) $::audela(version)"
   set private(commentaire)       ""

   #--- On cree la liste des caracteristiques (nom, categorie, variable et procedure) des mots cles
   set private(infosMotsClefs) ""
   lappend private(infosMotsClefs) [ list "OBSERVER" $::caption(keyword,lieu)        ::conf(posobs,nom_observateur)        readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Observer name" "" ]
   lappend private(infosMotsClefs) [ list "SITENAME" $::caption(keyword,lieu)        ::conf(posobs,nom_observatoire)       readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Observatory name" "" ]
   lappend private(infosMotsClefs) [ list "IAU_CODE" $::caption(keyword,lieu)        ::conf(posobs,station_uai)            readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Observatory IAU Code" "" ]
   lappend private(infosMotsClefs) [ list "SITELONG" $::caption(keyword,lieu)        ::conf(posobs,estouest_long)          readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Observatory longitude" "degres, minutes, seconds" ]
   lappend private(infosMotsClefs) [ list "SITELAT"  $::caption(keyword,lieu)        ::conf(posobs,nordsud_lat)            readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Observatory latitude" "degres, minutes, seconds" ]
   lappend private(infosMotsClefs) [ list "SITEELEV" $::caption(keyword,lieu)        ::conf(posobs,altitude)               readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Height of the observatory above the sea level" "m: meter" ]
   lappend private(infosMotsClefs) [ list "GEODSYS"  $::caption(keyword,lieu)        ::conf(posobs,ref_geodesique)         readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs"       "string" "Geodetic datum for observatory position" "" ]
   lappend private(infosMotsClefs) [ list "TELESCOP" $::caption(keyword,instrument)  ::keyword::private(instrument)        readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                                 "string" "Telescop" "" ]
   lappend private(infosMotsClefs) [ list "APTDIA"   $::caption(keyword,instrument)  ::keyword::private(diametre)          readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                                 "float"  "Telescop diameter" "m: meter" ]
   lappend private(infosMotsClefs) [ list "FOCLEN"   $::caption(keyword,instrument)  ::keyword::private(focale_resultante) readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                                 "float"  "Resulting focal length of the telescop" "m: meter" ]
   lappend private(infosMotsClefs) [ list "XPIXSZ"   $::caption(keyword,instrument)  ::keyword::private(cell_dim_x)        readonly $::caption(keyword,parcourir)  "::confCam::run"                                     "float"  "Pixel width" "micron" ]
   lappend private(infosMotsClefs) [ list "YPIXSZ"   $::caption(keyword,instrument)  ::keyword::private(cell_dim_y)        readonly $::caption(keyword,parcourir)  "::confCam::run"                                     "float"  "Pixel height" "micron" ]
   lappend private(infosMotsClefs) [ list "SET_TEMP" $::caption(keyword,instrument)  ::conf(alaudine_nt,temp_ccd_souhaite) readonly $::caption(keyword,parcourir)  "::AlAudine_NT::run $::audace(base).alimAlAudineNT"  "float"  "Set CCD temperature" "degres Celsius" ]
   lappend private(infosMotsClefs) [ list "CCD_TEMP" $::caption(keyword,instrument)  ::keyword::private(temperature_ccd)   readonly $::caption(keyword,rafraichir) "::keyword::onChangeTemperature"                     "float"  "Actual CCD temperature" "degres Celsius" ]
   lappend private(infosMotsClefs) [ list "INSTRUME" $::caption(keyword,instrument)  ::keyword::private(equipement)        normal   $::caption(keyword,parcourir)  ""                                                   "string" "Instrument" "" ]
   lappend private(infosMotsClefs) [ list "OBJNAME"  $::caption(keyword,cible)       ::keyword::private(objet)             normal   ""                             ""                                                   "string" "Object name" "" ]
   lappend private(infosMotsClefs) [ list "RA"       $::caption(keyword,cible)       ::keyword::private(ra)                normal   ""                             ""                                                   "string" "Object Right Ascension" "degres" ]
   lappend private(infosMotsClefs) [ list "DEC"      $::caption(keyword,cible)       ::keyword::private(dec)               normal   ""                             ""                                                   "string" "Object Declination" "degres" ]
   lappend private(infosMotsClefs) [ list "EQUINOX"  $::caption(keyword,cible)       ::keyword::private(equinoxe)          normal   ""                             ""                                                   "string" "Coordinates equinox" "" ]
   lappend private(infosMotsClefs) [ list "RADECSYS" $::caption(keyword,cible)       ::keyword::private(radecsys)          normal   ""                             ""                                                   "string" "Coordinates system" "" ]
   lappend private(infosMotsClefs) [ list "IMAGETYP" $::caption(keyword,acquisition) ::keyword::private(typeImage)         normal   ""                             ""                                                   "string" "Image type" "" ]
   lappend private(infosMotsClefs) [ list "SWCREATE" $::caption(keyword,logiciel)    ::keyword::private(name_software)     readonly ""                             ""                                                   "string" "Acquisition software: http://www.audela.org/" "" ]
   lappend private(infosMotsClefs) [ list "SWMODIFY" $::caption(keyword,logiciel)    ::keyword::private(name_software)     readonly ""                             ""                                                   "string" "Processing software: http://www.audela.org/" "" ]
   lappend private(infosMotsClefs) [ list "COMMENT"  $::caption(keyword,divers)      ::keyword::private(commentaire)       normal   ""                             ""                                                   "string" "Comment" "" ]
}

#------------------------------------------------------------------------------
# run
#    Lance la boite de dialogue de configuration de l'en-tete FITS
#
# Parametres :
#    visuNo
#    this : Chemin de la fenetre
#------------------------------------------------------------------------------
proc ::keyword::run { visuNo this } {
   variable private

   #--- je charge le package Tablelist
   package require Tablelist

   #--- Creation des variables de la boite de configuration de l'en-tete FITS si elles n'existent pas
   if { ! [ info exists ::conf(keyword,visu$visuNo,check) ] } { set ::conf(keyword,visu$visuNo,check) "" }

   #--- j'ajoute un listener sur la configuration optique
   ::confOptic::addOpticListener [list ::keyword::onChangeConfOptic $visuNo]

   #--- j'ajoute un listener sur la camera
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeCellDim $visuNo]

   #--- je recupere la configuration optique
   onChangeConfOptic $visuNo

   #--- je recupere les dimensions des photosites
   onChangeCellDim $visuNo

   #--- je recupere la temperature du CCD
   onChangeTemperature $visuNo

   #--- je mets a jour la procedure a appeler pour rafraichir CCD_TEMP
   for { set i 0 } { $i < [ llength $private(infosMotsClefs) ] } { incr i } {
      set ligne [ lindex $private(infosMotsClefs) $i ]
      if { [ lindex $ligne 0 ] == "CCD_TEMP" } {
         set ligne [ lreplace $ligne 5 5 "::keyword::onChangeTemperature $visuNo" ]
         set private(infosMotsClefs) [ lreplace $private(infosMotsClefs) $i $i $ligne ]
         break
      }
   }

   #--- Creation de l'interface graphique
   set private($visuNo,frm) $this
   if { [ winfo exists $private($visuNo,frm) ] } {
      wm withdraw $private($visuNo,frm)
      wm deiconify $private($visuNo,frm)
      focus $private($visuNo,frm)
   } else {
      ::keyword::createDialog $visuNo
   }
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

   set combinaison [ ::confOptic::getConfOptic [ ::confVisu::getCamItem $visuNo ] ]

   set private(instrument)        [lindex $combinaison 0]
   set private(diametre)          [lindex $combinaison 1]
   set private(focale_resultante) [lindex $combinaison 2]
}

#------------------------------------------------------------------------------
# onChangeTemperature
#    met a jour les mots cles de la temperature
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

   set private(temperature_ccd) [ ::confCam::getTempCCD $camItem ]
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
# getCheckedKeywords
#    retourne la liste des mots cles coches
#
# Parametres :
#    visuNo
# Return :
#    retourne la liste des mots cles coches
#    exemple : {LATITUDE N43d39m59s} {OBSERVER mpujol} {SITENAME Beauzelle}
#------------------------------------------------------------------------------
proc ::keyword::getCheckedKeywords { visuNo } {
   variable private

   #--- Creation de la variable de la boite de configuration de l'en-tete FITS si elle n'existe pas
   if { ! [ info exists ::conf(keyword,visu$visuNo,check) ] } { set ::conf(keyword,visu$visuNo,check) "" }

   #--- je recupere la configuration optique
   onChangeConfOptic $visuNo

   #--- je recupere les dimensions des photosites
   onChangeCellDim $visuNo

   #--- je memorise les mots cles coches
   set result ""
   foreach name $::conf(keyword,visu$visuNo,check) {
      set motclef [lindex [split $name ","] 2]
      foreach infosMotClef $private(infosMotsClefs) {
         if { [ lindex $infosMotClef 0 ] == $motclef } {
            #--- je recupere la temperature du CCD
            if { $motclef == "CCD_TEMP" } {
               onChangeTemperature $visuNo
            }
            set textVariable [lindex $infosMotClef 2]
            set valeur       [set $textVariable]
            set type         [lindex $infosMotClef 6]
            set commentaire  [lindex $infosMotClef 7]
            set unite        [lindex $infosMotClef 8]
            break
         }
      }
      lappend result [list $motclef $valeur $type $commentaire $unite]
   }
   return $result
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
      grid $private($visuNo,table)        -row 0 -column 0 -sticky ewns
      grid $frm.fra1.ysb -row 0 -column 1 -sticky nsew
      grid $frm.fra1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $frm.fra1 0 -weight 1
      grid columnconfig $frm.fra1 0 -weight 1

      #--- ajoute les mots cles dans la table
      foreach motClef $private(infosMotsClefs) {
         ajouteLigne $visuNo [ lindex $motClef 0 ] [ lindex $motClef 1 ] [ lindex $motClef 2 ] [ lindex $motClef 3 ] [ lindex $motClef 4 ] [ lindex $motClef 5 ]
      }

      #--- je coche les lignes qui avaient ete cochees dans une session precedente
      foreach check $::conf(keyword,visu$visuNo,check) {
         set private($check) 1
      }

   pack $frm.fra1 -side top -fill both -expand 1

   #--- La fenetre est active
  focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------------------------
# ajouteLigne
#    ajoute une ligne dans la table
#
# Parametres :
#    visuNo
#    motclef       : nom du mot cles
#    categorie     : categorie du mot cles
#    textvariable  : variable contenant la valeur du mot cles
#    stateVariable : etat de l'entry
#    caption       : etiquette du bouton
#    command       : procedure a appeler quand on clique sur le bouton
#------------------------------------------------------------------------------
proc ::keyword::ajouteLigne { visuNo motclef categorie textvariable stateVariable caption command } {
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
}

#------------------------------------------------------------------------------
# createCheckbutton
#    cree un checkbutton dans la table
#
# Parametres :
#    visuNo
#    motclef      : nom du mot cles
#    tbl          : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::keyword::createCheckbutton { visuNo motclef tbl row col w } {
   variable private

   checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::keyword::private($visuNo,check,$motclef)
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

   #--- je memorise la configuration dans le tableau conf(...)
   set ::conf(keyword,geometry) $private($visuNo,geometry)
   #--- je sauvegarde la liste des mots cles coches
   set ::conf(keyword,visu$visuNo,check) ""
   foreach name [array names private $visuNo,check,*] {
      if { $private($name) == 1 } {
         lappend ::conf(keyword,visu$visuNo,check) [list $name]
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

   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeCellDim $visuNo]
   ::confOptic::removeOpticListener [list ::keyword::onChangeConfOptic $visuNo]
   ::keyword::recupPosDim $visuNo
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

#--- Initialisation
::keyword::init

